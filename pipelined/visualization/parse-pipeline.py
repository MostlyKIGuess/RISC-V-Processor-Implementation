import re
import json
import sys

def parse_pipeline_output(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    cycles = []
    cycle_blocks = content.split("--------------------------------")
    
    # Parse the cycle-by-cycle data
    for block in cycle_blocks:
        if "Time=" not in block:
            continue
            
        cycle_data = {}
        
        # Extract cycle number
        cycle_match = re.search(r"Cycle=(\d+)", block)
        if cycle_match:
            cycle_data["cycle"] = int(cycle_match.group(1))
        
        # Extract IF stage data
        pc_match = re.search(r"IF Stage: PC=([0-9a-fA-Fx]+)", block)
        if pc_match:
            cycle_data["pc_current"] = pc_match.group(1)
            
        inst_match = re.search(r"Instruction=([0-9a-fA-Fx]+)", block)
        if inst_match:
            cycle_data["instruction"] = inst_match.group(1)
        
        # Extract pipeline register contents
        if_id_inst_match = re.search(r"IF/ID: .*?Instruction=([0-9a-fA-Fx]+)", block)
        if if_id_inst_match:
            cycle_data["if_id_instruction"] = if_id_inst_match.group(1)
            
        id_ex_inst_match = re.search(r"ID/EX: .*?Instruction=([0-9a-fA-Fx]+)", block)
        if id_ex_inst_match:
            cycle_data["id_ex_instruction"] = id_ex_inst_match.group(1)
            
        ex_mem_inst_match = re.search(r"EX/MEM: .*?Instruction=([0-9a-fA-Fx]+)", block)
        if ex_mem_inst_match:
            cycle_data["ex_mem_instruction"] = ex_mem_inst_match.group(1)
            
        mem_wb_inst_match = re.search(r"MEM/WB: .*?Instruction=([0-9a-fA-Fx]+)", block)
        if mem_wb_inst_match:
            cycle_data["mem_wb_instruction"] = mem_wb_inst_match.group(1)
            
        # Extract ID stage data
        id_match = re.search(r"ID Stage: rs1=x(\d+) \((-?\d+)\), rs2=x(\d+) \((-?\d+)\), rd=x(\d+)", block)
        if id_match:
            cycle_data["rs1"] = int(id_match.group(1))
            cycle_data["reg_read_data1"] = int(id_match.group(2))
            cycle_data["rs2"] = int(id_match.group(3))
            cycle_data["reg_read_data2"] = int(id_match.group(4))
            cycle_data["reg_rd"] = int(id_match.group(5))
        
        # Extract register operand values and destination registers
        reg_values_match = re.search(r"ID/EX: .*?rs1=x(\d+), rs2=x(\d+), rd=x(\d+)", block)
        if reg_values_match:
            cycle_data["id_ex_rs1"] = int(reg_values_match.group(1))
            cycle_data["id_ex_rs2"] = int(reg_values_match.group(2))
            cycle_data["id_ex_rd"] = int(reg_values_match.group(3))
        
        ex_mem_rd_match = re.search(r"EX/MEM: .*?rd=x(\d+)", block)
        if ex_mem_rd_match:
            cycle_data["ex_mem_rd"] = int(ex_mem_rd_match.group(1))
        
        mem_wb_rd_match = re.search(r"MEM/WB: .*?rd=x(\d+)", block)
        if mem_wb_rd_match:
            cycle_data["mem_wb_rd"] = int(mem_wb_rd_match.group(1))
            
        # Extract EX stage data
        ex_match = re.search(r"EX Stage: ALU Result=([0-9a-fA-Fx]+)", block)
        if ex_match:
            cycle_data["alu_result"] = ex_match.group(1)
            
        # Extract control signals
        control_match = re.search(r"Control signals: branch=(\d), mem_read=(\d), mem_to_reg=(\d), mem_write=(\d), alu_src=(\d), reg_write=(\d)", block)
        if control_match:
            cycle_data["branch"] = bool(int(control_match.group(1)))
            cycle_data["mem_read"] = bool(int(control_match.group(2)))
            cycle_data["mem_to_reg"] = bool(int(control_match.group(3)))
            cycle_data["mem_write"] = bool(int(control_match.group(4)))
            cycle_data["alu_src"] = bool(int(control_match.group(5)))
            cycle_data["reg_write"] = bool(int(control_match.group(6)))
            
        # Extract WB activity (register writes)
        wb_match = re.search(r"WB Stage: Writing (-?\d+) to register x(\d+)", block)
        if wb_match:
            cycle_data["reg_write_data"] = int(wb_match.group(1))
            cycle_data["reg_write_rd"] = int(wb_match.group(2))
            
        # Extract memory access information
        mem_read_match = re.search(r"MEM Stage: Reading from address (-?\d+), value=(-?\d+)", block)
        if mem_read_match:
            cycle_data["mem_read_address"] = int(mem_read_match.group(1))
            cycle_data["mem_read_data"] = int(mem_read_match.group(2))
            
        mem_write_match = re.search(r"MEM Stage: Writing (-?\d+) to address (-?\d+)", block)
        if mem_write_match:
            cycle_data["mem_write_data"] = int(mem_write_match.group(1))
            cycle_data["mem_write_address"] = int(mem_write_match.group(2))
            
        # Detect stall signals
        if "stall detected" in block.lower() or "stalling pipeline" in block.lower():
            cycle_data["if_stalled"] = True
            cycle_data["id_stalled"] = True
        
        # Check for load-use hazard keywords
        if "hazard detected" in block.lower() or "stalling pipeline" in block.lower():
            cycle_data["stall"] = True
            cycle_data["load_hazard"] = True

        # Detect forwarding
        if "forwarding active" in block.lower():
            # Check for specific forwarding types
            if "ex → ex forwarding" in block.lower():
                cycle_data["ex_forwarding"] = True
                cycle_data["forwardA"] = "10"  # If showing rs1
            
            if "mem → ex forwarding" in block.lower():
                cycle_data["mem_forwarding"] = True
                cycle_data["forwardA"] = "01"  # If showing rs1

        # Detect branch misprediction
        if "branch mispredicted" in block.lower() or "pipeline flush" in block.lower():
            cycle_data["branch_mispredicted"] = True
            cycle_data["flush"] = True
            
        # Check for load-use hazard keywords
        if "load-use hazard" in block.lower() or "load hazard" in block.lower():
            cycle_data["load_hazard"] = True
        
        # Detect forwarding
        if "forwarding from ex" in block.lower() or "ex → ex forwarding" in block.lower():
            cycle_data["ex_forwarding"] = True
            
        if "forwarding from mem" in block.lower() or "mem → ex forwarding" in block.lower():
            cycle_data["mem_forwarding"] = True
            
        # Extract forwarding specific info
        ex_forward_match = re.search(r"forwardA=2'b10|forwardB=2'b10", block)
        if ex_forward_match:
            cycle_data["ex_forwarding"] = True
            
        mem_forward_match = re.search(r"forwardA=2'b01|forwardB=2'b01", block)
        if mem_forward_match:
            cycle_data["mem_forwarding"] = True
            
        # Detect branch misprediction
        if "branch misprediction" in block.lower() or "pipeline flush" in block.lower() or "branch_mispredicted" in block.lower():
            cycle_data["branch_mispredicted"] = True
            cycle_data["id_flushed"] = True
            cycle_data["ex_flushed"] = True
            
        # Additional branch info
        if "branch at pc=" in block.lower() and "mispredicted" in block.lower():
            cycle_data["branch_mispredicted"] = True
            
        
        # More specific branch information parsing
        branch_target_match = re.search(r"Branch at PC=([0-9a-fA-Fx]+): Taking branch", block)
        if branch_target_match:
            cycle_data["branch_taken"] = True
            cycle_data["branch_pc"] = branch_target_match.group(1)

        branch_prediction_match = re.search(r"Branch prediction: ([A-Za-z]+)", block)
        if branch_prediction_match:
            cycle_data["branch_prediction"] = branch_prediction_match.group(1).lower()

        # Find branch source and target addresses
        branch_addr_match = re.search(r"beq .* (-?\d+)", block)
        if branch_addr_match and cycle_data.get("pc_current"):
            try:
                offset = int(branch_addr_match.group(1))
                pc = int(cycle_data["pc_current"], 16)
                cycle_data["branch_target_addr"] = pc + offset
            except:
                pass

        # Track control flow more precisely
        if "taking branch" in block.lower():
            cycle_data["control_flow_changed"] = True
            
        if "pipeline flushed" in block.lower():
            cycle_data["flush_occurred"] = True
            cycle_data["pipeline_recovery"] = True
        
 
        cycles.append(cycle_data)
    
    # Parse final register and memory state
    final_registers = {}
    final_memory = {}
    
    # Extract final register values
    reg_section = re.search(r"Register file contents:(.*?)Memory contents:", content, re.DOTALL)
    if reg_section:
        reg_content = reg_section.group(1)
        reg_matches = re.findall(r"x(\d+) = (-?\d+)", reg_content)
        for match in reg_matches:
            reg_num = int(match[0])
            reg_value = int(match[1])
            final_registers[f"x{reg_num}"] = reg_value
    
    # Extract final memory values
    mem_section = re.search(r"Memory contents:(.*?)Data memory contents written", content, re.DOTALL)
    if mem_section:
        mem_content = mem_section.group(1)
        mem_matches = re.findall(r"mem\[(\d+)\] = (-?\d+)", mem_content)
        for match in mem_matches:
            mem_addr = int(match[0])
            mem_value = int(match[1])
            final_memory[f"mem_{mem_addr}"] = mem_value
    
    # Add the final register and memory values to the last cycle
    if cycles and final_registers:
        for reg_name, reg_value in final_registers.items():
            cycles[-1][reg_name] = reg_value
            
    if cycles and final_memory:
        for mem_name, mem_value in final_memory.items():
            cycles[-1][mem_name] = mem_value
    
    return {"cycles": cycles}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python parse_pipeline.py <simulation_output.txt>")
        sys.exit(1)
        
    pipeline_data = parse_pipeline_output(sys.argv[1])
    
    with open("visualization/pipeline-data.js", "w") as f:
        f.write("const pipelineData = " + json.dumps(pipeline_data, indent=2) + ";")
    
    print(f"Generated pipeline-data.js with {len(pipeline_data['cycles'])} cycles of data")
