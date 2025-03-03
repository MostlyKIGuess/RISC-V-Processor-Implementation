
#!/usr/bin/env python3

import os
import re
import json
import sys
from collections import defaultdict

def parse_simulation_output(output_file):
    """Parse the simulation output and extract CPU state for each cycle"""
    try:
        with open(output_file, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: File '{output_file}' not found.")
        sys.exit(1)
    
    # memory dump 
    memory = [0] * 256  # Initialize with zeros
    memory_section = re.search(r"Memory contents:(.*?)(?=\n\n|\Z)", content, re.DOTALL)
    if memory_section:
        memory_lines = memory_section.group(1).strip().split('\n')
        for line in memory_lines:
            # Parse lines like: mem[22] = 255 [0xff]
            mem_match = re.search(r"mem\[(\d+)\] = (-?\d+) \[0x([0-9a-fA-F]+)\]", line)
            if mem_match:
                addr = int(mem_match.group(1))
                value = int(mem_match.group(2))
                if addr < len(memory):
                    memory[addr] = value
    
    
    cycle_pattern = r"--------------------------------(.*?)(?=--------------------------------|\Z)"
    cycle_matches = re.findall(cycle_pattern, content, re.DOTALL)
    
    cycles = []
    registers = [0] * 32 #all start with 0
    
    for cycle_text in cycle_matches:
        cycle_data = {}
        
        # time 
        time_match = re.search(r"Time=(\d+)", cycle_text)
        if time_match:
            cycle_data['time'] = int(time_match.group(1))
        
        # PC value 
        pc_match = re.search(r"PC=([0-9a-fA-Fx]+)", cycle_text)
        if pc_match:
            pc_text = pc_match.group(1)
            if 'x' not in pc_text:  # Handle binary/hex format
                cycle_data['pc'] = int(pc_text, 16)
            else:
                cycle_data['pc'] = 0  # x's mean undefined
        
        # instruction value
        inst_match = re.search(r"Instruction=([0-9a-fA-Fx]+)", cycle_text)
        if inst_match:
            inst_text = inst_match.group(1)
            if 'x' not in inst_text:  # Handle binary/hex format
                cycle_data['instruction'] = int(inst_text, 16)
            else:
                cycle_data['instruction'] = 0  # x's mean undefined
        
        # decoded instruction
        decoded_match = re.search(r"Executing: (.*)", cycle_text)
        if decoded_match:
            cycle_data['decodedInstruction'] = decoded_match.group(1).strip()
        
        # control sigs
        control_match = re.search(r"Control signals:.*?branch=(\d+), mem_read=(\d+), mem_to_reg=(\d+), mem_write=(\d+), alu_src=(\d+), reg_write=(\d+)", cycle_text, re.DOTALL)
        if control_match:
            cycle_data['controlSignals'] = {
                'branch': bool(int(control_match.group(1))),
                'mem_read': bool(int(control_match.group(2))),
                'mem_to_reg': bool(int(control_match.group(3))),
                'mem_write': bool(int(control_match.group(4))),
                'alu_src': bool(int(control_match.group(5))),
                'reg_write': bool(int(control_match.group(6)))
            }
        
        reg_write_match = re.search(r"Writing to rd\(x(\d+)\)=(-?\d+)", cycle_text)
        changed_regs = []
        
        if reg_write_match:
            rd = int(reg_write_match.group(1))
            value = int(reg_write_match.group(2))
            if rd > 0:  # x0 is always 0
                registers[rd] = value
                changed_regs.append(rd)
        
        cycle_data['registers'] = registers.copy()
        if changed_regs:
            cycle_data['changedRegisters'] = changed_regs
        
        mem_write_match = re.search(r"Memory write: address=(\d+), data=(-?\d+)", cycle_text)
        changed_mem = []
        
        if mem_write_match:
            address = int(mem_write_match.group(1))
            value = int(mem_write_match.group(2))
            
            for i in range(8):  # Store 8 bytes (64 bits)
                if address + i < len(memory):
                    memory[address + i] = (value >> (i * 8)) & 0xFF
                    changed_mem.append(address + i)
        
        cycle_data['memory'] = memory.copy()
        if changed_mem:
            cycle_data['changedMemory'] = changed_mem
        
        # alu result
        alu_match = re.search(r"ALU result=(-?\d+)", cycle_text)
        if alu_match:
            cycle_data['aluResult'] = int(alu_match.group(1))
        
        cycles.append(cycle_data)
    
    return {
        'cycles': cycles
    }

def main():
    if len(sys.argv) < 2:
        print("Usage: python data_converter.py <simulation_output_file>")
        sys.exit(1)
    
    output_file = sys.argv[1]
    cpu_data = parse_simulation_output(output_file)
    
    # this has the json data of runnning programme
    js_output = f"const cpuData = {json.dumps(cpu_data, indent=2)};"
    
    with open("visualization/cpu-data.js", "w") as f:
        f.write(js_output)
    
    print(f"Converted {len(cpu_data['cycles'])} cycles of CPU data to visualization/cpu-data.js")

if __name__ == "__main__":
    main()
