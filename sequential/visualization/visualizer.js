document.addEventListener('DOMContentLoaded', function() {
    let currentCycle = 0;
    let isPlaying = false;
    let playInterval = null;

    const cpuDiagram = document.getElementById('cpu-diagram');
    const cycleDisplay = document.getElementById('cycle-display');
    const prevButton = document.getElementById('prev');
    const nextButton = document.getElementById('next');
    const playPauseButton = document.getElementById('play-pause');
    const speedSelect = document.getElementById('speed');
    const instructionInfo = document.getElementById('instruction-info');
    const controlSignals = document.getElementById('control-signals');
    const registerView = document.getElementById('register-view');
    const memoryView = document.getElementById('memory-view');

        //  main drawing
    const svg = d3.select('#cpu-diagram')
        .append('svg')
        .attr('width', '100%')
        .attr('height', '100%')
        .attr('viewBox', '0 0 800 600');

    function drawCPU() {
        // PC
        svg.append('rect')
            .attr('class', 'component')
            .attr('id', 'pc')
            .attr('x', 50)
            .attr('y', 120)
            .attr('width', 80)
            .attr('height', 60);

        svg.append('text')
            .attr('class', 'component-text')
            .attr('x', 90)
            .attr('y', 150)
            .text('PC');

        // Instructions
        svg.append('rect')
            .attr('class', 'component')
            .attr('id', 'imem')
            .attr('x', 200)
            .attr('y', 100)
            .attr('width', 100)
            .attr('height', 100);

        svg.append('text')
            .attr('class', 'component-text')
            .attr('x', 250)
            .attr('y', 150)
            .text('I-Mem');

        // registers
        svg.append('rect')
            .attr('class', 'component')
            .attr('id', 'regfile')
            .attr('x', 200)
            .attr('y', 300)
            .attr('width', 100)
            .attr('height', 120);

        svg.append('text')
            .attr('class', 'component-text')
            .attr('x', 250)
            .attr('y', 360)
            .text('Registers');

        // ALU 
        svg.append('rect')
            .attr('class', 'component')
            .attr('id', 'alu')
            .attr('x', 400)
            .attr('y', 280)
            .attr('width', 120)
            .attr('height', 120);

        svg.append('text')
            .attr('class', 'component-text')
            .attr('x', 460)
            .attr('y', 340)
            .text('ALU');

        // Data MEm
        svg.append('rect')
            .attr('class', 'component')
            .attr('id', 'dmem')
            .attr('x', 600)
            .attr('y', 300)
            .attr('width', 100)
            .attr('height', 120);

        svg.append('text')
            .attr('class', 'component-text')
            .attr('x', 650)
            .attr('y', 360)
            .text('D-Mem');

        // Control Unit
        svg.append('rect')
            .attr('class', 'component')
            .attr('id', 'control')
            .attr('x', 400)
            .attr('y', 480)
            .attr('width', 120)
            .attr('height', 80);

        svg.append('text')
            .attr('class', 'component-text')
            .attr('x', 460)
            .attr('y', 520)
            .text('Control');

        // Draw data paths 
        drawDataPaths();
        
        // control signals
        drawControlSignals();
        
        
        addLabels();
    }

    function addLabels() {
        
        svg.append('text')
            .attr('class', 'path-label')
            .attr('x', 150)
            .attr('y', 130)
            .text('Fetch');

        svg.append('text')
            .attr('class', 'path-label')
            .attr('x', 250)
            .attr('y', 230)
            .text('Decode');

        svg.append('text')
            .attr('class', 'path-label')
            .attr('x', 350)
            .attr('y', 300)
            .text('Execute');

        svg.append('text')
            .attr('class', 'path-label')
            .attr('x', 530)
            .attr('y', 330)
            .text('Memory');

        svg.append('text')
            .attr('class', 'path-label')
            .attr('x', 560)
            .attr('y', 380)
            .text('Write Back');
    }

    function drawDataPaths() {
        drawPath('pc-to-imem', 'M130,150 H200', false);
        drawPath('imem-to-regfile', 'M250,200 V300', false);
        drawPath('imem-to-control', 'M250,200 V520 H400', false);
        drawPath('regfile-to-alu1', 'M300,320 H400', false);
        drawPath('regfile-to-alu2', 'M300,360 H400', false);
        drawPath('alu-to-dmem', 'M520,340 H600', false);
        drawPath('dmem-to-regfile', 'M600,400 H350 V420 H250 V420', false);
        drawPath('alu-to-regfile', 'M460,400 V450 H180 V360', false);
        drawPath('branch-path', 'M400,320 H380 V240 H90 V150', false);
    }

    function drawControlSignals() {
        drawPath('ctrl-reg_write', 'M410,480 V420 H180 V330', true);
        drawPath('ctrl-alu_src', 'M460,480 V430', true);
        drawPath('ctrl-mem_write', 'M500,480 V460 H650 V420', true);
        drawPath('ctrl-mem_read', 'M510,480 V470 H660 V420', true);
        drawPath('ctrl-mem_to_reg', 'M440,480 V440 H350 V400', true);
        drawPath('ctrl-branch', 'M400,490 H350 V220 H90 V170', true);
    }

    function drawPath(id, path, isControl) {
        svg.append('path')
            .attr('id', id)
            .attr('class', isControl ? 'control-signal' : 'data-path')
            .attr('d', path);
    }

    function updateDisplay() {
        if (!cpuData || !cpuData.cycles || cpuData.cycles.length === 0) {
            console.error("No CPU data available");
            return;
        }

        const cycleData = cpuData.cycles[currentCycle];
        cycleDisplay.textContent = `Cycle: ${currentCycle + 1} of ${cpuData.cycles.length}`;
        
        // updates pc instrucion
        updateInstructionInfo(cycleData);
        
        // control sigs
        updateControlSignals(cycleData);
        
        updateRegisters(cycleData);
        
        updateMemory(cycleData);
        
        highlightActivePaths(cycleData);
        
        prevButton.disabled = currentCycle === 0;
        nextButton.disabled = currentCycle === cpuData.cycles.length - 1;
    }

    function updateInstructionInfo(cycleData) {
        let instructionText = `<div>PC: 0x${cycleData.pc.toString(16).padStart(8, '0')}</div>`;
        instructionText += `<div>Instruction: 0x${cycleData.instruction.toString(16).padStart(8, '0')}</div>`;
        
        if (cycleData.decodedInstruction) {
            instructionText += `<div class="decoded">Executing: ${cycleData.decodedInstruction}</div>`;
        }
        
        instructionInfo.innerHTML = instructionText;
    }

    function updateControlSignals(cycleData) {
        const signals = cycleData.controlSignals || {};
        let signalsText = '';
        for (const [key, value] of Object.entries(signals)) {
            signalsText += `<div class="signal ${value ? 'active' : 'inactive'}">
                ${key}: <span class="signal-value">${value ? '1' : '0'}</span>
            </div>`;
        }
        controlSignals.innerHTML = signalsText;
    }

    function updateRegisters(cycleData) {
        const registers = cycleData.registers || [];
        let registersText = '';
        
        for (let i = 0; i < registers.length; i++) {
            const value = registers[i];
            const isChanged = cycleData.changedRegisters && cycleData.changedRegisters.includes(i);
            
            registersText += `<div class="register ${isChanged ? 'register-changed' : ''}">
                <span>x${i}</span>
                <span>${value} [0x${value.toString(16).padStart(16, '0')}]</span>
            </div>`;
        }
        
        registerView.innerHTML = registersText;
    }

    function updateMemory(cycleData) {
        const memory = cycleData.memory || [];
        let memoryText = '';
        
        for (let i = 0; i < Math.min(32, memory.length); i += 8) {
            const address = i;
            const value = memory.slice(i, i+8).reduce((acc, val, idx) => acc + (val << (idx * 8)), 0);
            const isChanged = cycleData.changedMemory && cycleData.changedMemory.includes(i);
            
            memoryText += `<div class="memory-cell ${isChanged ? 'register-changed' : ''}">
                <span>mem[${address}]</span>
                <span>${value} [0x${value.toString(16).padStart(16, '0')}]</span>
            </div>`;
        }
        
        memoryView.innerHTML = memoryText;
    }

    function highlightActivePaths(cycleData) {
        d3.selectAll('.data-path').classed('active', false);
        d3.selectAll('.control-signal').classed('active', false);
        
        if (cycleData.instruction) {
            const opcode = (cycleData.instruction & 0x7f);
            
            // these are always active on all instructoins
            d3.select('#pc-to-imem').classed('active', true);
            d3.select('#imem-to-regfile').classed('active', true);
            d3.select('#imem-to-control').classed('active', true);
            d3.select('#regfile-to-alu1').classed('active', true);
            
            // R-type instruction
            if (opcode === 0x33) { // 0110011
                d3.select('#regfile-to-alu2').classed('active', true);
                d3.select('#alu-to-regfile').classed('active', true);
            } 
            // I-type instruction (addi)
            else if (opcode === 0x13) { // 0010011
                d3.select('#alu-to-regfile').classed('active', true);
            }
            // I-type instruction (ld)
            else if (opcode === 0x03) { // 0000011
                d3.select('#alu-to-dmem').classed('active', true);
                d3.select('#dmem-to-regfile').classed('active', true);
            }
            // S-type instruction (sd)
            else if (opcode === 0x23) { // 0100011
                d3.select('#regfile-to-alu2').classed('active', true);
                d3.select('#alu-to-dmem').classed('active', true);
            }
            // B-type instruction (beq)
            else if (opcode === 0x63) { // 1100011
                d3.select('#regfile-to-alu2').classed('active', true);
                d3.select('#branch-path').classed('active', true);
            }
        }
        
        const signals = cycleData.controlSignals || {};
        for (const [key, value] of Object.entries(signals)) {
            if (value) {
                d3.select(`#ctrl-${key}`).classed('active', true);
            }
        }
    }

    prevButton.addEventListener('click', function() {
        if (currentCycle > 0) {
            currentCycle--;
            updateDisplay();
        }
    });

    nextButton.addEventListener('click', function() {
        if (currentCycle < cpuData.cycles.length - 1) {
            currentCycle++;
            updateDisplay();
        }
    });

    playPauseButton.addEventListener('click', function() {
        if (isPlaying) {
            clearInterval(playInterval);
            playPauseButton.textContent = 'Play';
            isPlaying = false;
        } else {
            playInterval = setInterval(function() {
                if (currentCycle < cpuData.cycles.length - 1) {
                    currentCycle++;
                    updateDisplay();
                } else {
                    clearInterval(playInterval);
                    playPauseButton.textContent = 'Play';
                    isPlaying = false;
                }
            }, parseInt(speedSelect.value));
            playPauseButton.textContent = 'Pause';
            isPlaying = true;
        }
    });

    speedSelect.addEventListener('change', function() {
        if (isPlaying) {
            clearInterval(playInterval);
            playInterval = setInterval(function() {
                if (currentCycle < cpuData.cycles.length - 1) {
                    currentCycle++;
                    updateDisplay();
                } else {
                    clearInterval(playInterval);
                    playPauseButton.textContent = 'Play';
                    isPlaying = false;
                }
            }, parseInt(speedSelect.value));
        }
    });

    drawCPU();
    
    if (typeof cpuData !== 'undefined') {
        updateDisplay();
    } else {
        console.error("CPU data not loaded!");
        instructionInfo.innerHTML = "<div class='error'>Error: CPU data not available.</div>";
    }
});
