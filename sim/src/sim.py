import sys

# exits with message
def error(message):
    print "\033[1m\033[91m[!] %s!\033[0m" % message
    sys.exit()

# main
if len(sys.argv) < 2:
    error("Enter one file")
if len(sys.argv) > 2:
    error("Don't enter more than one file")

source = sys.argv[1]
with open(source) as f:
    source = [x.strip() for x in f.readlines()]

# read into memory
memory = [0xFFFF] * 0x10000 # 2-byte addressable memory
location = 0
for line in source:
    if len(line) == 0:
        continue
    if line[0] == '@':      # sets location of following instructions
        location = int(line[1:], 16)
        continue
    if location >= 0x10000:
        error("Memory address doesn't exist")
    memory[location] = int(line, 16) & 0xFFFF
    location += 1

# set up our registers
registers = [0x00] * 16
def sr(which, value):
    if which == 0:
        sys.stdout.write(chr(value & 0xFF,))
    else:
        registers[which] = value & 0xFFFF

def gr(which):
    return registers[which] if which != 0 and which < 16 else 0

def unpack(instruction):
    o = instruction >> 12
    a = instruction >> 8
    b = instruction >> 4
    t = instruction
    v = ((a << 4) | b)
    return (o & 0xF, a & 0xF, b & 0xF, t & 0xF, v & 0xFF)

pc = 0
for _ in xrange(100000):
    is_jumping = False
    o, a, b, t, v = unpack(memory[pc])
    if   o == 0b0010:                  # add
        sr(t, gr(a) + gr(b))
    elif o == 0b0001:                  # mul
        sr(t, gr(a) * gr(b))
    elif o == 0b0000:                  # sub
        sr(t, gr(a) - gr(b))
    elif o == 0b1000:                  # mol
        sr(t, ((v ^ 0x80) - 0x80) & 0xFFFF)
    elif o == 0b1001:                  # moh
        sr(t, (gr(t) & 0x00FF) | ((v & 0xFF) << 8))
    elif o == 0b1110 and b <= 0b0011:  # jz/jnz/js/jns
        is_jumping = any([b == 0b0000 and gr(a) == 0,
                          b == 0b0001 and gr(a) != 0,
                          b == 0b0010 and gr(a) & 0x8000 == 0x8000,
                          b == 0b0011 and gr(a) & 0x8000 != 0x8000])
    elif o == 0b1111 and b <= 0x0001:  # lod/sto
        if b == 0b0000:
            sr(t, memory[gr(a)])
        if b == 0b0001:
            memory[gr(a)] = gr(t)
    else:
        break

    pc = gr(t) / 2 if is_jumping else pc + 1
else:
    error("Exceeded 100,000 cycle limit")
