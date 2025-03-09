const pipelineData = {
  "cycles": [
    {
      "cycle": 1,
      "pc_current": "0000000000000000",
      "instruction": "00300093",
      "if_id_instruction": "00000000",
      "id_ex_instruction": "00000000",
      "ex_mem_instruction": "00000000",
      "mem_wb_instruction": "00000000",
      "rs1": 0,
      "reg_read_data1": 0,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 0,
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 0,
      "ex_mem_rd": 0,
      "mem_wb_rd": 0,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 2,
      "pc_current": "0000000000000004",
      "instruction": "00700113",
      "if_id_instruction": "00300093",
      "id_ex_instruction": "00000000",
      "ex_mem_instruction": "00000000",
      "mem_wb_instruction": "00000000",
      "rs1": 0,
      "reg_read_data1": 0,
      "rs2": 3,
      "reg_read_data2": 0,
      "reg_rd": 0,
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 0,
      "ex_mem_rd": 0,
      "mem_wb_rd": 0,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": true,
      "reg_write": true
    },
    {
      "cycle": 3,
      "pc_current": "0000000000000008",
      "instruction": "00008863",
      "if_id_instruction": "00700113",
      "id_ex_instruction": "00300093",
      "ex_mem_instruction": "00000000",
      "mem_wb_instruction": "00000000",
      "rs1": 0,
      "reg_read_data1": 0,
      "rs2": 7,
      "reg_read_data2": 0,
      "reg_rd": 0,
      "id_ex_rs1": 0,
      "id_ex_rs2": 3,
      "id_ex_rd": 1,
      "ex_mem_rd": 0,
      "mem_wb_rd": 0,
      "alu_result": "3",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": true,
      "reg_write": true,
      "branch_target_addr": 24
    },
    {
      "cycle": 4,
      "pc_current": "0000000000000018",
      "instruction": "00000000",
      "if_id_instruction": "00008863",
      "id_ex_instruction": "00700113",
      "ex_mem_instruction": "00300093",
      "mem_wb_instruction": "00000000",
      "rs1": 1,
      "reg_read_data1": 0,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 0,
      "id_ex_rs1": 0,
      "id_ex_rs2": 7,
      "id_ex_rd": 2,
      "ex_mem_rd": 1,
      "mem_wb_rd": 0,
      "alu_result": "7",
      "branch": true,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 5,
      "pc_current": "000000000000001c",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "00000000",
      "id_ex_instruction": "00008863",
      "ex_mem_instruction": "00700113",
      "mem_wb_instruction": "00300093",
      "rs1": 0,
      "reg_read_data1": 0,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 1,
      "id_ex_rs1": 1,
      "id_ex_rs2": 0,
      "id_ex_rd": 16,
      "ex_mem_rd": 2,
      "mem_wb_rd": 1,
      "alu_result": "3",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "mem_forwarding": true,
      "forwardA": "01"
    },
    {
      "cycle": 6,
      "pc_current": "000000000000000c",
      "instruction": "00110133",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "00000000",
      "ex_mem_instruction": "00008863",
      "mem_wb_instruction": "00700113",
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 0,
      "ex_mem_rd": 16,
      "mem_wb_rd": 2,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 7,
      "pc_current": "0000000000000010",
      "instruction": "fff08093",
      "if_id_instruction": "00110133",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "00000000",
      "mem_wb_instruction": "00008863",
      "rs1": 2,
      "reg_read_data1": 7,
      "rs2": 1,
      "reg_read_data2": 3,
      "reg_rd": 16,
      "ex_mem_rd": 0,
      "mem_wb_rd": 16,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": true,
      "reg_write_data": 3,
      "reg_write_rd": 16
    },
    {
      "cycle": 8,
      "pc_current": "0000000000000014",
      "instruction": "fe000ae3",
      "if_id_instruction": "fff08093",
      "id_ex_instruction": "00110133",
      "ex_mem_instruction": "xxxxxxxx",
      "mem_wb_instruction": "00000000",
      "rs1": 1,
      "reg_read_data1": 3,
      "rs2": 31,
      "reg_read_data2": 0,
      "reg_rd": 0,
      "id_ex_rs1": 2,
      "id_ex_rs2": 1,
      "id_ex_rd": 2,
      "mem_wb_rd": 0,
      "alu_result": "a",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": true,
      "reg_write": true,
      "branch_target_addr": 8
    },
    {
      "cycle": 9,
      "pc_current": "0000000000000008",
      "instruction": "00008863",
      "if_id_instruction": "fe000ae3",
      "id_ex_instruction": "fff08093",
      "ex_mem_instruction": "00110133",
      "mem_wb_instruction": "xxxxxxxx",
      "id_ex_rs1": 1,
      "id_ex_rs2": 31,
      "id_ex_rd": 1,
      "ex_mem_rd": 2,
      "alu_result": "2",
      "branch": true,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "branch_target_addr": 24
    },
    {
      "cycle": 10,
      "pc_current": "0000000000000018",
      "instruction": "00000000",
      "if_id_instruction": "00008863",
      "id_ex_instruction": "fe000ae3",
      "ex_mem_instruction": "fff08093",
      "mem_wb_instruction": "00110133",
      "rs1": 1,
      "reg_read_data1": 3,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 2,
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 21,
      "ex_mem_rd": 1,
      "mem_wb_rd": 2,
      "alu_result": "0",
      "branch": true,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "branch_taken": true,
      "branch_pc": "0000000000000018",
      "control_flow_changed": true
    },
    {
      "cycle": 11,
      "pc_current": "000000000000001c",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "00000000",
      "id_ex_instruction": "00008863",
      "ex_mem_instruction": "fe000ae3",
      "mem_wb_instruction": "fff08093",
      "rs1": 0,
      "reg_read_data1": 0,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 1,
      "id_ex_rs1": 1,
      "id_ex_rs2": 0,
      "id_ex_rd": 16,
      "ex_mem_rd": 21,
      "mem_wb_rd": 1,
      "alu_result": "2",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "mem_forwarding": true,
      "forwardA": "01"
    },
    {
      "cycle": 12,
      "pc_current": "000000000000000c",
      "instruction": "00110133",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "00000000",
      "ex_mem_instruction": "00008863",
      "mem_wb_instruction": "fe000ae3",
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 0,
      "ex_mem_rd": 16,
      "mem_wb_rd": 21,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 13,
      "pc_current": "0000000000000010",
      "instruction": "fff08093",
      "if_id_instruction": "00110133",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "00000000",
      "mem_wb_instruction": "00008863",
      "rs1": 2,
      "reg_read_data1": 10,
      "rs2": 1,
      "reg_read_data2": 2,
      "reg_rd": 16,
      "ex_mem_rd": 0,
      "mem_wb_rd": 16,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": true,
      "reg_write_data": 2,
      "reg_write_rd": 16
    },
    {
      "cycle": 14,
      "pc_current": "0000000000000014",
      "instruction": "fe000ae3",
      "if_id_instruction": "fff08093",
      "id_ex_instruction": "00110133",
      "ex_mem_instruction": "xxxxxxxx",
      "mem_wb_instruction": "00000000",
      "rs1": 1,
      "reg_read_data1": 2,
      "rs2": 31,
      "reg_read_data2": 0,
      "reg_rd": 0,
      "id_ex_rs1": 2,
      "id_ex_rs2": 1,
      "id_ex_rd": 2,
      "mem_wb_rd": 0,
      "alu_result": "c",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": true,
      "reg_write": true,
      "branch_target_addr": 8
    },
    {
      "cycle": 15,
      "pc_current": "0000000000000008",
      "instruction": "00008863",
      "if_id_instruction": "fe000ae3",
      "id_ex_instruction": "fff08093",
      "ex_mem_instruction": "00110133",
      "mem_wb_instruction": "xxxxxxxx",
      "id_ex_rs1": 1,
      "id_ex_rs2": 31,
      "id_ex_rd": 1,
      "ex_mem_rd": 2,
      "alu_result": "1",
      "branch": true,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "branch_target_addr": 24
    },
    {
      "cycle": 16,
      "pc_current": "0000000000000018",
      "instruction": "00000000",
      "if_id_instruction": "00008863",
      "id_ex_instruction": "fe000ae3",
      "ex_mem_instruction": "fff08093",
      "mem_wb_instruction": "00110133",
      "rs1": 1,
      "reg_read_data1": 2,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 2,
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 21,
      "ex_mem_rd": 1,
      "mem_wb_rd": 2,
      "alu_result": "0",
      "branch": true,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "branch_taken": true,
      "branch_pc": "0000000000000018",
      "control_flow_changed": true
    },
    {
      "cycle": 17,
      "pc_current": "000000000000001c",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "00000000",
      "id_ex_instruction": "00008863",
      "ex_mem_instruction": "fe000ae3",
      "mem_wb_instruction": "fff08093",
      "rs1": 0,
      "reg_read_data1": 0,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 1,
      "id_ex_rs1": 1,
      "id_ex_rs2": 0,
      "id_ex_rd": 16,
      "ex_mem_rd": 21,
      "mem_wb_rd": 1,
      "alu_result": "1",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "mem_forwarding": true,
      "forwardA": "01"
    },
    {
      "cycle": 18,
      "pc_current": "000000000000000c",
      "instruction": "00110133",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "00000000",
      "ex_mem_instruction": "00008863",
      "mem_wb_instruction": "fe000ae3",
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 0,
      "ex_mem_rd": 16,
      "mem_wb_rd": 21,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 19,
      "pc_current": "0000000000000010",
      "instruction": "fff08093",
      "if_id_instruction": "00110133",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "00000000",
      "mem_wb_instruction": "00008863",
      "rs1": 2,
      "reg_read_data1": 12,
      "rs2": 1,
      "reg_read_data2": 1,
      "reg_rd": 16,
      "ex_mem_rd": 0,
      "mem_wb_rd": 16,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": true,
      "reg_write_data": 1,
      "reg_write_rd": 16
    },
    {
      "cycle": 20,
      "pc_current": "0000000000000014",
      "instruction": "fe000ae3",
      "if_id_instruction": "fff08093",
      "id_ex_instruction": "00110133",
      "ex_mem_instruction": "xxxxxxxx",
      "mem_wb_instruction": "00000000",
      "rs1": 1,
      "reg_read_data1": 1,
      "rs2": 31,
      "reg_read_data2": 0,
      "reg_rd": 0,
      "id_ex_rs1": 2,
      "id_ex_rs2": 1,
      "id_ex_rd": 2,
      "mem_wb_rd": 0,
      "alu_result": "d",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": true,
      "reg_write": true,
      "branch_target_addr": 8
    },
    {
      "cycle": 21,
      "pc_current": "0000000000000008",
      "instruction": "00008863",
      "if_id_instruction": "fe000ae3",
      "id_ex_instruction": "fff08093",
      "ex_mem_instruction": "00110133",
      "mem_wb_instruction": "xxxxxxxx",
      "id_ex_rs1": 1,
      "id_ex_rs2": 31,
      "id_ex_rd": 1,
      "ex_mem_rd": 2,
      "alu_result": "0",
      "branch": true,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "branch_taken": true,
      "branch_pc": "0000000000000008",
      "branch_target_addr": 24,
      "control_flow_changed": true
    },
    {
      "cycle": 22,
      "pc_current": "0000000000000018",
      "instruction": "00000000",
      "if_id_instruction": "00008863",
      "id_ex_instruction": "fe000ae3",
      "ex_mem_instruction": "fff08093",
      "mem_wb_instruction": "00110133",
      "rs1": 1,
      "reg_read_data1": 1,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 2,
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 21,
      "ex_mem_rd": 1,
      "mem_wb_rd": 2,
      "alu_result": "0",
      "branch": true,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "branch_taken": true,
      "branch_pc": "0000000000000018",
      "control_flow_changed": true
    },
    {
      "cycle": 23,
      "pc_current": "000000000000001c",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "00000000",
      "id_ex_instruction": "00008863",
      "ex_mem_instruction": "fe000ae3",
      "mem_wb_instruction": "fff08093",
      "rs1": 0,
      "reg_read_data1": 0,
      "rs2": 0,
      "reg_read_data2": 0,
      "reg_rd": 1,
      "id_ex_rs1": 1,
      "id_ex_rs2": 0,
      "id_ex_rd": 16,
      "ex_mem_rd": 21,
      "mem_wb_rd": 1,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false,
      "mem_forwarding": true,
      "forwardA": "01"
    },
    {
      "cycle": 24,
      "pc_current": "xxxxxxxxxxxxxxxx",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "00000000",
      "ex_mem_instruction": "00008863",
      "mem_wb_instruction": "fe000ae3",
      "id_ex_rs1": 0,
      "id_ex_rs2": 0,
      "id_ex_rd": 0,
      "ex_mem_rd": 16,
      "mem_wb_rd": 21,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 25,
      "pc_current": "xxxxxxxxxxxxxxxx",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "00000000",
      "mem_wb_instruction": "00008863",
      "ex_mem_rd": 0,
      "mem_wb_rd": 16,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 26,
      "pc_current": "xxxxxxxxxxxxxxxx",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "xxxxxxxx",
      "mem_wb_instruction": "00000000",
      "mem_wb_rd": 0,
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 27,
      "pc_current": "xxxxxxxxxxxxxxxx",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "xxxxxxxx",
      "mem_wb_instruction": "xxxxxxxx",
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 28,
      "pc_current": "xxxxxxxxxxxxxxxx",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "xxxxxxxx",
      "mem_wb_instruction": "xxxxxxxx",
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 29,
      "pc_current": "xxxxxxxxxxxxxxxx",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "xxxxxxxx",
      "mem_wb_instruction": "xxxxxxxx",
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    },
    {
      "cycle": 30,
      "pc_current": "xxxxxxxxxxxxxxxx",
      "instruction": "xxxxxxxx",
      "if_id_instruction": "xxxxxxxx",
      "id_ex_instruction": "xxxxxxxx",
      "ex_mem_instruction": "xxxxxxxx",
      "mem_wb_instruction": "xxxxxxxx",
      "alu_result": "0",
      "branch": false,
      "mem_read": false,
      "mem_to_reg": false,
      "mem_write": false,
      "alu_src": false,
      "reg_write": false
    }
  ]
};