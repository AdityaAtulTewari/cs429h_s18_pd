`timescale 1ps/1ps

module main();

    // Legacy, 1
    //reg [15:0]pc = 16'h0000;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0,main);
    end

    // clock
    wire clk;
    clock c0(clk);

    reg halt = 0;

    counter ctr(halt,clk);

    reg branch_predictor_ON = 1;

    ////////////
    // Memory //
    ////////////

    wire [15:1] mem_raddr0; // = pc sometimes
    wire [15:0] mem_rdata0;

    wire [15:1] mem_raddr1;
    wire [15:0] mem_rdata1;

    wire mem_should_write;
    wire [15:1] mem_waddr;
    wire [15:0] mem_wdata;

    mem mem(clk,
         mem_raddr0,mem_rdata0,
         mem_raddr1,mem_rdata1,
         mem_should_write,mem_waddr,mem_wdata);
    
    ///////////////
    // Registers //
    ///////////////

    wire [3:0] regs_raddr0;
    wire [15:0] regs_rdata0;

    wire [3:0] regs_raddr1;
    wire [15:0] regs_rdata1;

    wire regs_should_write;
    wire [3:0] regs_waddr;
    wire [15:0] regs_wdata;

    
    regs regs(clk,
        regs_raddr0,regs_rdata0,
        regs_raddr1,regs_rdata1,
        regs_should_write,regs_waddr,regs_wdata);

    ////////////
    // Branch //
    ////////////

    reg branch_V = 0;
    reg [15:0] branch_PC = 0;
    reg [15:0] branch_jump_to = 0;


    ////////
    // f0 //
    ////////

    wire f0_V = load_mis ? 0 : 1; 
    reg [15:0] f0_PC = 16'h0000; // by default, first instruction at mem addr 0
    wire [15:0] f0_nextpc = wb_flush_should ? wb_flush_to
                        : load_mis ? f0_PC 
                        : f0_mis ? f0_PC+1
                        : branch_V && f0_PC == branch_PC ? branch_jump_to
                        : f0_PC + 2;

    wire f0_mis = f0_V && f0_PC[0];

    // TODO: fix misaligned PC, for now ignore
    assign mem_raddr0 = load_mis ? (load_mem_regs_rdata0[15:1] + 1) % 32768
                    : f1_mis ? f1_PC[15:1]+1 % 32768
                    : f0_PC[15:1] % 32768;

    always @(posedge clk) begin
        f0_PC <= f0_nextpc;
        f1_mis <= f0_mis;
    end

    //////// This stage does nothing but wait an additional cycle so 
    // f1 // that we can get stuff back from memory.
    ////////
    
    reg f1_V = 0; // by default, we haven't waited a cycle for f1
    reg f1_mis = 0;
    reg [15:0] f1_PC;

    always @(posedge clk) begin
        if (wb_flush_should)
            f1_V <= 0;
        else 
            f1_V <= f0_mis ? 0 : f0_V;

        f1_PC <= f0_PC; // to reflect which PC we're waiting on
        dec_mis <= f1_mis;
    end

    //////////// decode ensures that regs/mem is all loaded
    // Decode // so that we can execute the instructions
    ////////////
    
    reg dec_V = 0;
    reg dec_mis;
    reg [15:0] dec_PC;
    wire [15:0] dec_ins = load_mis_prev ? {load_ins[7:0], mem_rdata0[15:8]} : mem_rdata0;


    // decoding instruction, copied from p7
    wire [3:0] dec_opcode = dec_ins[15:12];
    wire [3:0] dec_dest = dec_ins[3:0];

    wire [7:0] dec_src = dec_ins[11:4];
    wire [3:0] dec_src_hi = dec_ins[11:8];
    wire [3:0] dec_src_lo = dec_ins[7:4];

    wire dec_is_sub = dec_opcode == 0;
    wire dec_is_movl = dec_opcode == 8;
    wire dec_is_movh = dec_opcode == 9;
    wire dec_is_jump = dec_opcode == 14 && (dec_src_lo >= 0 && dec_src_lo <= 3);
    wire dec_is_ld = dec_opcode == 15 && dec_src_lo == 0;
    wire dec_is_st = dec_opcode == 15 && dec_src_lo == 1;

    // cases where we need to load some regs
    assign regs_raddr0 =  dec_is_sub ? dec_src_hi
                        : dec_is_movh ? dec_dest 
                        : dec_is_jump ? dec_src_hi
                        : dec_is_ld ? dec_src_hi
                        : dec_is_st ? dec_src_hi
                        : 0;

    assign regs_raddr1 =  dec_is_sub ? dec_src_lo
                        : dec_is_movh ? 0
                        : dec_is_jump ? dec_dest
                        : dec_is_ld ? 0
                        : dec_is_st ? dec_dest
                        : 0;

    always @(posedge clk) begin
        if (wb_flush_should)
            dec_V <= 0;
        else
            dec_V <= f1_V;

        dec_PC <= f1_PC;

        // pass on instruction to next stage
        load_ins <= dec_ins;
        load_mis_prev <= dec_mis;
    end

    //////////
    // Load // waiting a cycle to get an ins back from load
    //////////

    reg load_V = 0;
    reg [15:0] load_PC;
    reg [15:0] load_ins;
    reg load_mis_prev;

    wire [15:0] load_regs_rdata0 = regs_rdata0;
    wire [15:0] load_regs_rdata1 = regs_rdata1;

    wire [15:0] load_regs_fwd_rdata0 = load2_V && load2_reg_should && load2_reg_addr == load_regs0_needed ? load2_reg_data
                        : wb_V && wb_reg_should && wb_reg_addr == load_regs0_needed ? wb_reg_data 
                        : load_regs_rdata0;
    wire [15:0] load_regs_fwd_rdata1 = load2_V && load2_reg_should && load2_reg_addr == load_regs1_needed ? load2_reg_data
                        : wb_V && wb_reg_should && wb_reg_addr == load_regs1_needed ? wb_reg_data 
                        : load_regs_rdata1;

    wire [3:0] load_regs0_needed =  load_is_sub ? load_src_hi
                        : load_is_movh ? load_dest 
                        : load_is_jump ? load_src_hi
                        : load_is_ld ? load_src_hi
                        : load_is_st ? load_src_hi
                        : 0;

    wire[3:0] load_regs1_needed =  load_is_sub ? load_src_lo
                        : load_is_movh ? 0
                        : load_is_jump ? load_dest
                        : load_is_ld ? 0
                        : load_is_st ? load_dest
                        : 0;

    // decoding ins    
    // assign branches
    //assign branch_PC = wb_jump_should ? wb_PC : branch_PC;
    //assign branch_jump_to = wb_jump_should ? wb_jump_to : branch_jump_to;


    wire [3:0] load_opcode = load_ins[15:12];
    wire [3:0] load_dest = load_ins[3:0];

    wire [7:0] load_src = load_ins[11:4];
    wire [3:0] load_src_hi = load_ins[11:8];
    wire [3:0] load_src_lo = load_ins[7:4];

    wire load_is_sub = load_opcode == 0;
    wire load_is_movl = load_opcode == 8;
    wire load_is_movh = load_opcode == 9;
    wire load_is_jump = load_opcode == 14 && (load_src_lo >= 0 && load_src_lo <= 3);
    wire load_is_ld = load_opcode == 15 && load_src_lo == 0;
    wire load_is_st = load_opcode == 15 && load_src_lo == 1;

    // super corner case where I need to start loading, but i cant because
    // i need to get forwarded a register value that I won't get until next
    // cycle
    wire load_is_screwed = load_V && load_is_ld && load2_V && load2_is_ld && load2_reg_should && load2_reg_addr == load_regs0_needed && load2_is_ld ||
                        load_V && load_is_ld && load2_V && load2_is_ld && load2_reg_should && load2_reg_addr == load_regs1_needed && load2_is_ld;


    // assign load to memory wires
    wire [15:0] load_mem_regs_rdata0 = load_src_hi == 0 ? 0 : load_regs_fwd_rdata0;
    wire load_mis = load_V && (load_is_ld || load_is_st) && !(load_mem_regs_rdata0[0]===1'bX) && load_mem_regs_rdata0[0];

    assign mem_raddr1 = load_mem_regs_rdata0[15:1] % 32768; // TODO: load misalign

    always @(posedge clk) begin
        if (wb_flush_should) 
            load_V <= 0;
        else
            load_V <= dec_V;
        load_PC <= dec_PC;

        load2_ins <= load_ins;
        load2_regs_rdata0 <= load_regs_fwd_rdata0;
        load2_regs_rdata1 <= load_regs_fwd_rdata1;
        load2_mis <= load_mis;

        load2_past_wen0 <= mem_should_write;
        load2_past_waddr0 <= mem_waddr;
        load2_past_wdata0 <= mem_wdata;

        load2_is_screwed <= load_is_screwed;
    end 


    ////////////
    // Load 2 //
    ////////////

    reg load2_V = 0;
    reg [15:0] load2_PC;
    reg [15:0] load2_ins;
    reg load2_mis = 0;
    reg load2_is_screwed = 0;

    reg [15:0] load2_regs_rdata0;
    reg [15:0] load2_regs_rdata1;

    reg load2_past_wen0;
    reg [15:1] load2_past_waddr0;
    reg [15:0] load2_past_wdata0;

    wire [15:0] load2_regs_fwd_rdata0 = wb_V && wb_reg_should && wb_reg_addr == load2_regs0_needed ? wb_reg_data : load2_regs_rdata0;
    wire [15:0] load2_regs_fwd_rdata1 = wb_V && wb_reg_should && wb_reg_addr == load2_regs1_needed ? wb_reg_data : load2_regs_rdata1;

    wire [3:0] load2_regs0_needed =  load2_is_sub ? load2_src_hi
                        : load2_is_movh ? load2_dest 
                        : load2_is_jump ? load2_src_hi
                        : load2_is_ld ? load2_src_hi
                        : load2_is_st ? load2_src_hi
                        : 0;

    wire[3:0] load2_regs1_needed =  load2_is_sub ? load2_src_lo
                        : load2_is_movh ? 0
                        : load2_is_jump ? load2_dest
                        : load2_is_ld ? 0
                        : load2_is_st ? load2_dest
                        : 0;

    // decoding ins
    wire [3:0] load2_opcode = load2_ins[15:12];
    wire [3:0] load2_dest = load2_ins[3:0];

    wire [7:0] load2_src = load2_ins[11:4];
    wire [3:0] load2_src_hi = load2_ins[11:8];
    wire [3:0] load2_src_lo = load2_ins[7:4];

    wire load2_is_sub = load2_opcode == 0;
    wire load2_is_movl = load2_opcode == 8;
    wire load2_is_movh = load2_opcode == 9;
    wire load2_is_jump = load2_opcode == 14 && (load2_src_lo >= 0 && load2_src_lo <= 3);
    wire load2_is_ld = load2_opcode == 15 && load2_src_lo == 0;
    wire load2_is_st = load2_opcode == 15 && load2_src_lo == 1;

    // needed for register forwarding
    wire [15:0] load2_sub_tmp1 = load2_src_hi == 0 ? 0 : load2_regs_fwd_rdata0;
    wire [15:0] load2_sub_tmp2 = load2_src_lo == 0 ? 0 : load2_regs_fwd_rdata1;
    wire [15:0] load2_sub_res = load2_sub_tmp1 - load2_sub_tmp2;

    wire [15:0] load2_movl_res = { {8{load2_src[7]}}, load2_src[7:0] };
    wire [15:0] load2_movh_tmp = load2_dest == 0 ? 0 
                            //: (^load2_regs_rdata0[15:8] === 1'bX) ? 0
                            : load2_regs_fwd_rdata0;
    wire [15:0] load2_movh_res = { load2_src[7:0], load2_movh_tmp[7:0] };

    wire load2_reg_should = load2_V && load2_dest != 0 && (load2_is_sub || load2_is_movl || load2_is_movh || load2_is_ld);
    wire [3:0] load2_reg_addr = load2_dest;
    wire [15:0] load2_reg_data = load2_is_sub ? load2_sub_res
                    : load2_is_movl ? load2_movl_res
                    : load2_is_movh ? load2_movh_res
                    : load2_is_ld ? 0
                    : 1;


    always @(posedge clk) begin
        if (wb_flush_should)
            load2_V <= 0;
        else
            load2_V <= load_V;
        load2_PC <= load_PC;

        wb_ins <= load2_ins;
        wb_regs_rdata0 <= load2_regs_fwd_rdata0;
        wb_regs_rdata1 <= load2_regs_fwd_rdata1;
        wb_mis <= load2_mis;

        wb_past_wen0 <= load2_past_wen0;
        wb_past_waddr0 <= load2_past_waddr0;
        wb_past_wdata0 <= load2_past_wdata0;

        wb_past_wen1 <= mem_should_write;
        wb_past_waddr1 <= mem_waddr;
    //wire wb_st_mis = wb_V && wb_is_st && wb_mem_reg1[0];
    //wire [15:0] wb_st_mis_addr = wb_mem_reg1;
        wb_past_wdata1 <= mem_wdata;

        wb_is_screwed <= load2_is_screwed;

    end


    ///////////////
    // Writeback //
    ///////////////

    reg wb_V = 0;
    reg [15:0] wb_PC;
    reg [15:0] wb_ins;
    reg wb_mis;
    reg wb_is_screwed;

    reg [15:0] wb_regs_rdata0;
    reg [15:0] wb_regs_rdata1;


    reg wb_past_wen0 = 0;
    reg [15:1] wb_past_waddr0;
    reg [15:0] wb_past_wdata0;
    reg wb_past_wen1 = 0;
    reg [15:1] wb_past_waddr1;
    reg [15:0] wb_past_wdata1;

    // decoding instruction, copied from p7
    wire [3:0] wb_opcode = wb_ins[15:12];
    wire [3:0] wb_dest = wb_ins[3:0];

    wire [7:0] wb_src = wb_ins[11:4];
    wire [3:0] wb_src_hi = wb_ins[11:8];
    wire [3:0] wb_src_lo = wb_ins[7:4];

    wire wb_is_sub = wb_opcode == 0;
    wire wb_is_movl = wb_opcode == 8;
    wire wb_is_movh = wb_opcode == 9;
    wire wb_is_jump = wb_opcode == 14 && (wb_src_lo >= 0 && wb_src_lo <= 3);
    wire wb_is_ld = wb_opcode == 15 && wb_src_lo == 0;
    wire wb_is_st = wb_opcode == 15 && wb_src_lo == 1;

    wire wb_should_halt = !(wb_is_sub || wb_is_movl || wb_is_movh || wb_is_jump || wb_is_ld || wb_is_st);

    // some intermediate wires
    wire [15:0] wb_sub_tmp1 = wb_src_hi == 0 ? 0 : wb_regs_rdata0;
    wire [15:0] wb_sub_tmp2 = wb_src_lo == 0 ? 0 : wb_regs_rdata1;
    //wire wb_st_mis = wb_V && wb_is_st && wb_mem_reg1[0];
    //wire [15:0] wb_st_mis_addr = wb_mem_reg1;
    wire [15:0] wb_sub_res = wb_sub_tmp1 - wb_sub_tmp2;

    wire [15:0] wb_movl_res = { {8{wb_src[7]}}, wb_src[7:0] };
    wire [15:0] wb_movh_tmp = wb_dest == 0 ? 0 
                            //: (^wb_regs_rdata0[15:8] === 1'bX) ? 0
                            : wb_regs_rdata0;
    wire [15:0] wb_movh_res = { wb_src[7:0], wb_movh_tmp[7:0] };
    wire [15:0] wb_jmp_fixed_data = wb_src_hi == 0 ? 0 : wb_regs_rdata0;
    wire wb_jmp_cond = wb_src_lo == 0 ? $signed(wb_jmp_fixed_data)==0 
                : wb_src_lo == 1 ? $signed(wb_jmp_fixed_data)!=0
                : wb_src_lo == 2 ? $signed(wb_jmp_fixed_data) < 0
                : wb_src_lo == 3 ? $signed(wb_jmp_fixed_data) >= 0
                : 1;

    wire [15:0] wb_mem_rdata1 = sm_V && sm_write && mem_waddr == (wb_regs_rdata0[15:1] % 32678) ? mem_wdata
                            : wb_past_wen1 && wb_past_waddr1 == (wb_regs_rdata0[15:1] % 32768) ? wb_past_wdata1
                            : wb_past_wen0 && wb_past_waddr0 == (wb_regs_rdata0[15:1] % 32768) ? wb_past_wdata0
                            : mem_rdata1;

    wire [15:0] wb_mem_rdata0 = sm_V && sm_write && mem_waddr == ((wb_regs_rdata0[15:1]+1) % 32768) ? mem_wdata
                            : wb_past_wen1 && wb_past_waddr1 == ((wb_regs_rdata0[15:1]+1) % 32768) ? wb_past_wdata1
                            : wb_past_wen0 && wb_past_waddr0 == ((wb_regs_rdata0[15:1]+1) % 32768) ? wb_past_wdata0
                            : mem_rdata0;

    wire [15:0] wb_ld_res = wb_mis ? {wb_mem_rdata1[7:0], wb_mem_rdata0[15:8]}
                            : wb_mem_rdata1;

    // cases where we need to print
    wire wb_print_should = wb_dest == 0 && (wb_is_sub || wb_is_movl || wb_is_movh || wb_is_ld);
    wire [15:0] wb_print_this = wb_is_sub ? wb_sub_res
                            : wb_is_movl ? wb_movl_res
                            : wb_is_movh ? wb_movh_res
                            : wb_is_ld ? wb_ld_res
                            : 1;

    // cases where we need to set reg
    wire wb_reg_should = wb_dest != 0 && (wb_is_sub || wb_is_movl || wb_is_movh || wb_is_ld);
    wire [3:0] wb_reg_addr = wb_dest;
    wire [15:0] wb_reg_data = wb_is_sub ? wb_sub_res
                    : wb_is_movl ? wb_movl_res
                    : wb_is_movh ? wb_movh_res
                    : wb_is_ld ? wb_ld_res
                    : 1;

    // if we're executing, set write wires
    assign regs_should_write = wb_V && wb_reg_should;
    assign regs_waddr = wb_V && wb_reg_should ? wb_reg_addr
                    : 0;
    assign regs_wdata = wb_V && wb_reg_should ? wb_reg_data
                    : 0;


    // intermediate wires for memory
    wire [15:0] wb_mem_reg1 = wb_src_hi == 0 ? 0 : wb_regs_rdata0;
    wire [15:0] wb_mem_reg2 = wb_dest == 0 ? 0 : wb_regs_rdata1;

    wire wb_mem_write_isvalid = !(^mem_waddr === 1'bX);

    // assign write to memory wires
    assign mem_should_write = wb_V && wb_is_st && wb_mem_write_isvalid || sm_V && sm_write; //|| sm2_V && sm2_write || sm3_V && sm3_write;
    assign mem_waddr = wb_V && wb_is_st ? wb_mem_reg1[15:1] % 32768
                    //: sm3_V && sm3_write ? sm3_waddr
                    //: sm2_V && sm2_write ? sm3_waddr
                    : sm_V && sm_write ? sm_waddr
                    : 0;
    assign mem_wdata = wb_V && wb_is_st ? wb_mem_data
                    //: sm3_V && sm3_write ? sm3_wdata
                    //: sm2_V && sm2_write ? sm2_wdata
                    : sm_V && sm_write ? sm_wdata
                    : 0;

    wire [15:8] wb_temp_mis_1 = (^wb_mem_rdata1[15:8] === 1'bX) ? 0 : wb_mem_rdata1[15:8];
    wire [15:8] wb_temp_mis_2 = (^wb_mem_rdata0[7:0] === 1'bX) ? 0 : wb_mem_rdata0[7:0];
    wire [15:0] wb_mem_data = wb_mis ? { wb_temp_mis_1, wb_mem_reg2[15:8] }
                            : wb_mem_reg2;

    wire wb_st_mis = wb_V && wb_is_st && wb_mem_write_isvalid && wb_mis;
    wire [15:1] wb_mem_addr_2 = (wb_mem_reg1[15:1] + 1) % 32768;
    wire [15:0] wb_mem_data_2 = { wb_mem_reg2[7:0], wb_temp_mis_2 };

    // FLUSHES 
    // flush condition #1, jmping
    wire wb_jump_should = wb_V && wb_is_jump && wb_jmp_cond && wb_jump_to != load2_PC;
    wire [15:0] wb_jump_to = wb_dest == 0 ? 0 : wb_regs_rdata1;

    // flush condition #N, jmp mispredict flase
    wire wb_jump_mispredict = wb_V && wb_is_jump && !wb_jmp_cond && load2_PC != wb_PC+2;
    wire [15:0] wb_jump_mis_to = wb_PC+2;


    // flush condiiton #2, store new PC
    // if we wrote to something f0 already loaded but hasnt been executed
    wire wb_st_overwriting_mem = wb_V && mem_should_write && $signed(wb_mem_reg1) <= f0_PC && $signed(wb_mem_reg1) > wb_PC
                                || wb_V && wb_st_mis && $signed(wb_mem_addr_2) <= f0_PC && $signed(wb_mem_addr_2) > wb_PC;
    wire [15:0] wb_st_overwriting_mem_to = wb_PC + 2;

    // flush condition #3, store misalign
    wire wb_ld_flush_condition = wb_V && wb_is_st && wb_mis;
    wire [15:0] wb_ld_flush_condition_to = wb_PC + 2;

    // set flushing parameters for f0
    wire wb_flush_should = wb_V && (wb_jump_should || wb_st_overwriting_mem || wb_ld_flush_condition || load2_is_screwed || wb_jump_mispredict); // || wb_is_screwed;
    wire [15:0] wb_flush_to = wb_jump_should ? wb_jump_to
                            : wb_st_overwriting_mem ? wb_st_overwriting_mem_to
                            : wb_ld_flush_condition ? wb_ld_flush_condition_to
                            : wb_jump_mispredict ? wb_jump_mis_to 
                            : load2_is_screwed ? wb_PC + 2
                            : 1;

    always @(posedge clk) begin
        wb_V <= load2_V;
        wb_PC <= load2_PC;

        sm_write <= wb_st_mis;
        sm_waddr <= wb_mem_addr_2;
        sm_wdata <= wb_mem_data_2;
    
        if (halt != 1 && wb_V) begin
            if (wb_print_should)
                $write("%c", wb_print_this);

            if (wb_flush_should) begin
                wb_V <= 0;
                load2_V <= 0;
                load_V <= 0;
                dec_V <= 0;
                f1_V <= 0;
            end

            if (wb_jump_should) begin
                branch_V <= branch_predictor_ON;
                branch_PC <= wb_PC;
                branch_jump_to <= wb_jump_to;
            end
        end 

        if (wb_V && wb_should_halt)
            halt <= 1;
    end

    ////////////////////
    // Store Misalign //
    ///////////////////

    //////////
    // SM 1 //
    //////////
    
    reg sm_V = 0;
    reg sm_write;
    reg [15:1] sm_waddr;
    reg [15:0] sm_wdata;

    wire sm_did_it = sm_V && sm_write && !(wb_V && wb_is_st) && !(sm2_V && sm2_write) && !(sm3_write && sm3_V);

    always @(posedge clk) begin
        sm_V <= wb_V;

        sm2_write <= sm_did_it ? 0 : sm_write;
        sm2_waddr <= sm_waddr;
        sm2_wdata <= sm_wdata;
    end

    //////////
    // SM 2 //
    //////////

    reg sm2_V = 0;
    reg sm2_write;
    reg [15:1] sm2_waddr;
    reg [15:0] sm2_wdata;

    wire sm2_did_it = sm_V && sm2_write && !(wb_V && wb_is_st) && !sm3_write;

    always @(posedge clk) begin
        sm2_V <= sm_V;

        sm3_write <= sm2_did_it ? 0 : sm2_write;
        sm3_waddr <= sm2_waddr;
        sm3_wdata <= sm2_wdata;
    end

    //////////
    // SM 3 //
    //////////

    reg sm3_V = 0;
    reg sm3_write;
    reg [15:1] sm3_waddr;
    reg [15:0] sm3_wdata;

    wire sm3_did_it = sm3_V && sm3_write && !(wb_V && wb_is_st);

    always @(posedge clk) begin
        sm3_V <= sm2_V;
    end

endmodule



