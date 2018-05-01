import sys

hd = '0123456789ABCDEF'

def comment(message):
    return "\033[1m\033[90m%s\033[0m" % message

def warning(message):
    return "\033[0;33;40m%s\033[0m" % message

def notice(message):
    return "\033[0;32;40m%s\033[0m" % message

# main
source = sys.argv[1]
with open(source) as f:
    source = [x.strip() for x in f.readlines()]

def unpack(instruction):
    o = instruction >> 12
    a = instruction >> 8
    b = instruction >> 4
    t = instruction
    v = ((a << 4) | b)
    return (o & 0xF, a & 0xF, b & 0xF, t & 0xF, v & 0xFF)

def get_asm(o, a, b, t, v):
    if      o == 0b0000:
        result = "sub %%r%d, %%r%d, %%r%d" % (t, a, b)
    elif o == 0b1000:
        result = "mol %%r%d, %d" % (t, v)
    elif o == 0b1001:
        result = "moh %%r%d, %d" % (t, v)
    elif o == 0b1110 and b <= 3:
        if      b == 0b0000:
            result = "jz %%r%d, %%r%d" % (t, a)
        elif b == 0b0001:
            result = "jnz %%r%d, %%r%d" % (t, a)
        elif b == 0b0010:
            result = "js %%r%d, %%r%d" % (t, a)
        elif b == 0b0011:
            result = "jns %%r%d, %%r%d" % (t, a)
    elif o == 0b1111 and b <= 1:
        if      b == 0b0000:
            result = "lod %%r%d, %%r%d" % (t, a)
        elif b == 0b0001:
            result = "sto %%r%d, %%r%d" % (t, a)
    else:
        result = "hlt"

    return result

pc = 0
output = len(sys.argv) == 3 and (sys.argv[2] == "-o" or sys.argv[2] == "--output")
if output:
    print "_main:"

for line in source:
    if line[0] == '@':
        pc = int(line[1:], 16)
        continue

    instruction = int(line, 16)
    o, a, b, t, v = unpack(instruction)
    hex_ins = hd[o] + hd[a] + ' ' + hd[b] + hd[t]
    asm_ins = get_asm(o, a, b, t, v)

    if output:
        print '\t' + asm_ins
    else:
        print "%4d %s %s %s" % (pc, warning(hex_ins), comment('->'), notice(asm_ins))

    pc += 1
