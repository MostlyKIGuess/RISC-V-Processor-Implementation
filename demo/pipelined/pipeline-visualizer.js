document.addEventListener("DOMContentLoaded", function () {
  let currentCycle = 0;
  let isPlaying = false;
  let playInterval = null;
  let animationOffset = 0;

  const cpuDiagram = document.getElementById("cpu-diagram");
  const cycleDisplay = document.getElementById("cycle-display");
  const prevButton = document.getElementById("prev");
  const nextButton = document.getElementById("next");
  const playPauseButton = document.getElementById("play-pause");
  const speedSelect = document.getElementById("speed");
  const pipelineStatus = document.getElementById("pipeline-status");
  const hazardInfo = document.getElementById("hazard-info");
  const registerView = document.getElementById("register-view");
  const memoryView = document.getElementById("memory-view");

  const svg = d3
    .select("#cpu-diagram")
    .append("svg")
    .attr("width", "100%")
    .attr("height", "100%")
    .attr("viewBox", "0 0 800 500");

  setupArrowMarkers();

  function setupArrowMarkers() {
    const defs = svg.append("defs");

    // Standard arrow marker
    defs
      .append("marker")
      .attr("id", "arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 8)
      .attr("refY", 0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-5L10,0L0,5Z")
      .attr("fill", "#6b7280");

    // Forwarding path arrow
    defs
      .append("marker")
      .attr("id", "forward-arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 8)
      .attr("refY", 0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-5L10,0L0,5Z")
      .attr("fill", "#10b981");

    // Branch arrow marker
    defs
      .append("marker")
      .attr("id", "branch-arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 8)
      .attr("refY", 0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-5L10,0L0,5Z")
      .attr("fill", "#ef4444");

    // Control signal arrow
    defs
      .append("marker")
      .attr("id", "control-arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 8)
      .attr("refY", 0)
      .attr("markerWidth", 5)
      .attr("markerHeight", 5)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-4L8,0L0,4Z")
      .attr("fill", "#9ca3af");
  }

  function drawPipelinedCPU() {
    drawPanel(20, 100, 760, 160, "#f0f9ff", "Pipeline Stages");
    drawPanel(20, 280, 760, 120, "#ecfdf5", "Components");

    drawPipelineStage("IF", 80, 130);
    drawPipelineStage("ID", 230, 130);
    drawPipelineStage("EX", 380, 130);
    drawPipelineStage("MEM", 530, 130);
    drawPipelineStage("WB", 680, 130);

    drawPipelineConnection("IF", "ID");
    drawPipelineConnection("ID", "EX");
    drawPipelineConnection("EX", "MEM");
    drawPipelineConnection("MEM", "WB");

    drawHazardUnit();

    drawComponent("PC", 80, 310, 80, 60);
    drawComponent("RegFile", 230, 310, 100, 60);
    drawComponent("ALU", 380, 310, 100, 60);
    drawComponent("DMem", 530, 310, 100, 60);
    drawComponent("Forwarding\nUnit", 380, 420, 120, 50);

    drawComponentConnection("PC", "IF");
    drawComponentConnection("RegFile", "ID");
    drawComponentConnection("ALU", "EX");
    drawComponentConnection("DMem", "MEM");

    drawForwardingPath("EX", "ID", "EX-to-ID");
    drawForwardingPath("MEM", "ID", "MEM-to-ID");
    drawHazardConnections();
    drawForwardingUnitConnections();
    drawBranchPaths();
  }
  function drawBranchPaths() {
    // Resolution path (from EX to IF) - shows what happens when branch is resolved
    const branchPath = svg
      .append("path")
      .attr("class", "control-signal branch-path")
      .attr("d", `M380,170 C350,140 250,110 150,110`)
      .attr("stroke", "#ef4444")
      .attr("stroke-width", 2)
      .attr("fill", "none")
      .attr("stroke-dasharray", "5,3")
      .attr("marker-end", "url(#branch-arrow)");

    // Prediction path (from IF stage back to PC) - shows branch prediction flow
    const predictionPath = svg
      .append("path")
      .attr("class", "control-signal prediction-path")
      .attr(
        "d",
        `M110,130 C90,115 70,100 70,90 C70,70 60,60 40,60 C20,60 20,90 20,110 C20,140 50,150 80,150`
      )
      .attr("stroke", "#10b981")
      .attr("stroke-width", 2)
      .attr("fill", "none")
      .attr("stroke-dasharray", "3,2")
      .attr("marker-end", "url(#forward-arrow)");

    svg
      .append("text")
      .attr("class", "path-label branch-label")
      .attr("x", 280)
      .attr("y", 130)
      .attr("text-anchor", "end")
      .text("Branch Resolution");

    svg
      .append("text")
      .attr("class", "path-label prediction-label")
      .attr("x", 40)
      .attr("y", 70)
      .text("Branch Prediction");
  }

  function drawHazardConnections() {
    svg
      .append("path")
      .attr("class", "control-signal hazard-detect")
      .attr("d", "M230,170 C180,170 170,300 180,420 L230,420")
      .attr("stroke", "#f59e0b")
      .attr("stroke-width", 1.5)
      .attr("fill", "none")
      .attr("stroke-dasharray", "3,2")
      .attr("marker-end", "url(#control-arrow)");

    svg
      .append("path")
      .attr("class", "control-signal pc-stall")
      .attr(
        "d",
        "M305,420 C320,420 320,380 300,380 C280,380 140,380 120,380 C100,380 100,250 120,210"
      )
      .attr("stroke", "#9ca3af")
      .attr("stroke-width", 1.5)
      .attr("fill", "none")
      .attr("stroke-dasharray", "3,2")
      .attr("marker-end", "url(#control-arrow)");

    svg
      .append("path")
      .attr("class", "control-signal if-id-stall")
      .attr(
        "d",
        "M350,435 C360,435 370,400 370,380 C370,360 300,350 240,350 C180,350 170,240 170,135"
      )
      .attr("stroke", "#ef4444")
      .attr("stroke-width", 1.5)
      .attr("fill", "none")
      .attr("stroke-dasharray", "4,2")
      .attr("marker-end", "url(#control-arrow)");

    svg
      .append("text")
      .attr("class", "path-label")
      .attr("x", 200)
      .attr("y", 300)
      .attr("text-anchor", "end")
      .text("Hazard Detection");

    svg
      .append("text")
      .attr("class", "path-label")
      .attr("x", 200)
      .attr("y", 380)
      .attr("text-anchor", "end")
      .text("PC Stall");

    svg
      .append("text")
      .attr("class", "path-label")
      .attr("x", 250)
      .attr("y", 350)
      .attr("text-anchor", "end")
      .text("Pipeline Flush");
  }

  function drawForwardingUnitConnections() {
    svg
      .append("path")
      .attr("class", "control-signal")
      .attr("d", "M380,170 L360,170 L360,430 L380,430")
      .attr("stroke", "#10b981")
      .attr("stroke-width", 1.5)
      .attr("fill", "none")
      .attr("stroke-dasharray", "3,2")
      .attr("marker-end", "url(#forward-arrow)");

    svg
      .append("path")
      .attr("class", "control-signal")
      .attr("d", "M530,170 L520,170 L520,440 L500,440")
      .attr("stroke", "#10b981")
      .attr("stroke-width", 1.5)
      .attr("fill", "none")
      .attr("stroke-dasharray", "3,2")
      .attr("marker-end", "url(#forward-arrow)");

    svg
      .append("path")
      .attr("class", "control-signal")
      .attr("d", "M440,420 L440,380 L280,380 L280,210")
      .attr("stroke", "#10b981")
      .attr("stroke-width", 1.5)
      .attr("fill", "none")
      .attr("stroke-dasharray", "3,2")
      .attr("marker-end", "url(#forward-arrow)");
  }

  function drawPanel(x, y, width, height, color, title) {
    svg
      .append("rect")
      .attr("x", x)
      .attr("y", y)
      .attr("width", width)
      .attr("height", height)
      .attr("rx", 10)
      .attr("ry", 10)
      .attr("fill", color)
      .attr("fill-opacity", 0.2)
      .attr("stroke", color)
      .attr("stroke-opacity", 0.5)
      .attr("stroke-width", 1);

    svg
      .append("text")
      .attr("x", x + 10)
      .attr("y", y + 20)
      .attr("fill", "#4b5563")
      .attr("font-size", "12px")
      .attr("font-weight", "500")
      .text(title);
  }

  function drawPipelineStage(stage, x, y) {
    svg
      .append("rect")
      .attr("class", "pipeline-module")
      .attr("id", `stage-${stage}`)
      .attr("x", x)
      .attr("y", y)
      .attr("width", 100)
      .attr("height", 80)
      .attr("rx", 6)
      .attr("ry", 6);

    svg
      .append("text")
      .attr("class", "pipeline-stage-label")
      .attr("x", x + 50)
      .attr("y", y + 45)
      .text(stage);
  }

  function drawPipelineConnection(from, to) {
    const fromX = parseFloat(d3.select(`#stage-${from}`).attr("x")) + 100;
    const fromY = parseFloat(d3.select(`#stage-${from}`).attr("y")) + 40;
    const toX = parseFloat(d3.select(`#stage-${to}`).attr("x"));
    const toY = parseFloat(d3.select(`#stage-${to}`).attr("y")) + 40;

    svg
      .append("path")
      .attr("class", `path-${from}-${to}`)
      .attr("d", `M${fromX},${fromY} L${toX},${toY}`)
      .attr("stroke", "#9ca3af")
      .attr("stroke-width", 2)
      .attr("fill", "none")
      .attr("marker-end", "url(#arrow)");

    const regX = fromX + (toX - fromX) / 2 - 10;
    const regY = fromY - 15;

    svg
      .append("rect")
      .attr("class", "pipeline-register")
      .attr("x", regX)
      .attr("y", regY)
      .attr("width", 20)
      .attr("height", 30)
      .attr("rx", 3)
      .attr("ry", 3);

    svg
      .append("text")
      .attr("class", "component-text")
      .attr("x", regX + 10)
      .attr("y", regY + 15)
      .attr("font-size", "10px")
      .text(`${from}/${to}`);
  }

  function drawComponentConnection(comp, stage) {
    const compElem = d3.select(`#component-${comp}`);
    const stageElem = d3.select(`#stage-${stage}`);

    const compX =
      parseFloat(compElem.attr("x")) + parseFloat(compElem.attr("width")) / 2;
    const compY = parseFloat(compElem.attr("y"));
    const stageX =
      parseFloat(stageElem.attr("x")) + parseFloat(stageElem.attr("width")) / 2;
    const stageY =
      parseFloat(stageElem.attr("y")) + parseFloat(stageElem.attr("height"));

    svg
      .append("path")
      .attr("class", "data-path")
      .attr(
        "d",
        `M${compX},${compY} L${compX},${compY - 15} L${stageX},${
          compY - 15
        } L${stageX},${stageY}`
      )
      .attr("stroke", "#9ca3af")
      .attr("stroke-width", 1.5)
      .attr("fill", "none")
      .attr("stroke-dasharray", "3,2")
      .attr("marker-end", "url(#arrow)");
  }

  function drawForwardingPath(from, to, id) {
    const fromX = parseFloat(d3.select(`#stage-${from}`).attr("x")) + 50;
    const fromY = parseFloat(d3.select(`#stage-${from}`).attr("y")) + 80;
    const toX = parseFloat(d3.select(`#stage-${to}`).attr("x")) + 50;
    const toY = parseFloat(d3.select(`#stage-${to}`).attr("y")) + 80;

    svg
      .append("path")
      .attr("class", `forward-path ${id}`)
      .attr(
        "d",
        `M${fromX},${fromY} C${fromX},${fromY + 40} ${toX},${
          toY + 40
        } ${toX},${toY}`
      )
      .attr("stroke", "#10b981")
      .attr("stroke-width", 2)
      .attr("fill", "none")
      .attr("stroke-dasharray", "3,2")
      .attr("marker-end", "url(#forward-arrow)");
  }

  function drawHazardUnit() {
    svg
      .append("rect")
      .attr("class", "hazard-unit")
      .attr("x", 230)
      .attr("y", 420)
      .attr("width", 150)
      .attr("height", 50)
      .attr("rx", 6)
      .attr("ry", 6);

    svg
      .append("text")
      .attr("class", "component-text")
      .attr("x", 305)
      .attr("y", 445)
      .text("Hazard Unit");
  }

  function drawComponent(name, x, y, width, height) {
    svg
      .append("rect")
      .attr("class", "component")
      .attr("id", `component-${name}`)
      .attr("x", x)
      .attr("y", y)
      .attr("width", width)
      .attr("height", height)
      .attr("rx", 6)
      .attr("ry", 6);

    svg
      .append("text")
      .attr("class", "component-text")
      .attr("x", x + width / 2)
      .attr("y", y + height / 2)
      .text(name);
  }

  function decodeInstruction(instruction) {
    if (
      !instruction ||
      instruction === "undefined" ||
      instruction === "0x0" ||
      instruction === "0x00000000"
    ) {
      return "No instruction (NOP)";
    }

    let instructionStr = String(instruction).trim();
    if (instructionStr.startsWith("0x") || instructionStr.startsWith("0X")) {
      instructionStr = instructionStr.substring(2);
    }

    while (instructionStr.length < 8) {
      instructionStr = "0" + instructionStr;
    }

    const instructionInt = parseInt(instructionStr, 16);
    const opcode = instructionInt & 0x7f;
    const rd = (instructionInt >> 7) & 0x1f;
    const funct3 = (instructionInt >> 12) & 0x7;
    const rs1 = (instructionInt >> 15) & 0x1f;
    const rs2 = (instructionInt >> 20) & 0x1f;
    const funct7 = (instructionInt >> 25) & 0x7f;

    switch (opcode) {
      case 0x33: // R-type
        switch (funct3) {
          case 0:
            return funct7 === 0
              ? `add x${rd}, x${rs1}, x${rs2}`
              : `sub x${rd}, x${rs1}, x${rs2}`;
          case 6:
            return `or x${rd}, x${rs1}, x${rs2}`;
          case 7:
            return `and x${rd}, x${rs1}, x${rs2}`;
          default:
            return `Unknown R-type (0x${instructionStr})`;
        }

      case 0x13: // I-type (addi)
        const imm_i = (instructionInt >> 20) & 0xfff;
        const imm_i_signed = imm_i & 0x800 ? imm_i - 0x1000 : imm_i;
        return `addi x${rd}, x${rs1}, ${imm_i_signed}`;

      case 0x3: // I-type (load)
        const imm_load = (instructionInt >> 20) & 0xfff;
        const imm_load_signed = imm_load & 0x800 ? imm_load - 0x1000 : imm_load;
        return `ld x${rd}, ${imm_load_signed}(x${rs1})`;

      case 0x23: // S-type (store)
        const imm_s_11_5 = (instructionInt >> 25) & 0x7f;
        const imm_s_4_0 = (instructionInt >> 7) & 0x1f;
        let imm_s = (imm_s_11_5 << 5) | imm_s_4_0;
        const imm_s_signed = imm_s & 0x800 ? imm_s - 0x1000 : imm_s;
        return `sd x${rs2}, ${imm_s_signed}(x${rs1})`;

      case 0x63: // B-type (branch)
        const imm_b_12 = (instructionInt >> 31) & 0x1;
        const imm_b_11 = (instructionInt >> 7) & 0x1;
        const imm_b_10_5 = (instructionInt >> 25) & 0x3f;
        const imm_b_4_1 = (instructionInt >> 8) & 0xf;
        let imm_b =
          (imm_b_12 << 12) |
          (imm_b_11 << 11) |
          (imm_b_10_5 << 5) |
          (imm_b_4_1 << 1);
        if (imm_b & 0x1000) imm_b = imm_b - 0x2000;
        return `beq x${rs1}, x${rs2}, ${imm_b}`;

      case 0:
        return "NOP";

      default:
        return `Unknown instruction: 0x${instructionStr}`;
    }
  }

  function updateDisplay() {
    if (
      typeof pipelineData === "undefined" ||
      !pipelineData.cycles ||
      pipelineData.cycles.length === 0
    ) {
      console.error("No pipeline data available");
      return;
    }

    const cycleData = pipelineData.cycles[currentCycle];
    cycleDisplay.textContent = `Cycle: ${currentCycle + 1} of ${
      pipelineData.cycles.length
    }`;

    updatePipelineStatus(cycleData);
    updateHazardInfo(cycleData);
    updateRegisters(cycleData);
    updateMemory(cycleData);
    highlightActivePaths(cycleData);

    prevButton.disabled = currentCycle === 0;
    nextButton.disabled = currentCycle === pipelineData.cycles.length - 1;
  }

  function updatePipelineStatus(cycleData) {
    let statusHTML = "<ul class='pipeline-status-list'>";

    // IF Stage
    const ifInstruction = cycleData.instruction
      ? decodeInstruction(cycleData.instruction)
      : "No instruction";
    statusHTML += `<li class="stage-status ${
      cycleData.if_stalled ? "stalled" : ""
    }">
      <div class="stage-name">IF:</div> 
      <div class="stage-info">
        ${cycleData.pc_current ? "PC: 0x" + cycleData.pc_current : "Idle"}
        ${
          cycleData.instruction
            ? `<div class="instruction-text">${ifInstruction}</div>`
            : ""
        }
        ${
          cycleData.if_stalled
            ? '<span class="status-alert">STALLED</span>'
            : ""
        }
      </div>
    </li>`;

    // ID Stage
    const idInstruction = cycleData.if_id_instruction
      ? decodeInstruction(cycleData.if_id_instruction)
      : "No instruction";
    statusHTML += `<li class="stage-status ${
      cycleData.id_stalled ? "stalled" : ""
    }">
      <div class="stage-name">ID:</div>
      <div class="stage-info">
        ${
          cycleData.rs1 !== undefined
            ? `Rs1=x${cycleData.rs1}, Rs2=x${cycleData.rs2}`
            : "Idle"
        }
        ${
          cycleData.if_id_instruction
            ? `<div class="instruction-text">${idInstruction}</div>`
            : ""
        }
        ${
          cycleData.id_stalled
            ? '<span class="status-alert">STALLED</span>'
            : ""
        }
      </div>
    </li>`;

    // EX Stage
    const exInstruction = cycleData.id_ex_instruction
      ? decodeInstruction(cycleData.id_ex_instruction)
      : "No instruction";
    statusHTML += `<li class="stage-status">
      <div class="stage-name">EX:</div>
      <div class="stage-info">
        ${
          cycleData.alu_result !== undefined
            ? `ALU: ${cycleData.alu_result}`
            : "Idle"
        }
        ${
          cycleData.id_ex_instruction
            ? `<div class="instruction-text">${exInstruction}</div>`
            : ""
        }
        ${
          cycleData.ex_forwarding
            ? '<span class="status-notice">FORWARDING OUT</span>'
            : ""
        }
      </div>
    </li>`;

    // MEM Stage
    const memInstruction = cycleData.ex_mem_instruction
      ? decodeInstruction(cycleData.ex_mem_instruction)
      : "No instruction";
    statusHTML += `<li class="stage-status">
      <div class="stage-name">MEM:</div>
      <div class="stage-info">
        ${
          cycleData.mem_read
            ? "Reading memory"
            : cycleData.mem_write
            ? "Writing memory"
            : "No memory access"
        }
        ${
          cycleData.ex_mem_instruction
            ? `<div class="instruction-text">${memInstruction}</div>`
            : ""
        }
        ${
          cycleData.mem_forwarding
            ? '<span class="status-notice">FORWARDING OUT</span>'
            : ""
        }
      </div>
    </li>`;

    // WB Stage
    const wbInstruction = cycleData.mem_wb_instruction
      ? decodeInstruction(cycleData.mem_wb_instruction)
      : "No instruction";
    statusHTML += `<li class="stage-status">
      <div class="stage-name">WB:</div>
      <div class="stage-info">
        ${
          cycleData.reg_write
            ? `Writing to x${cycleData.reg_rd}`
            : "No write-back"
        }
        ${
          cycleData.mem_wb_instruction
            ? `<div class="instruction-text">${wbInstruction}</div>`
            : ""
        }
      </div>
    </li>`;

    // Branch prediction status if available
    if (cycleData.branch) {
      statusHTML += `<li class="branch-status ${
        cycleData.branch_mispredicted ? "mispredicted" : "correct"
      }">
        <div class="stage-name">Branch:</div>
        <div class="stage-info">
          ${
            cycleData.branch_mispredicted
              ? "MISPREDICTED - Pipeline Flush"
              : "Correctly predicted"
          }
          ${
            cycleData.branch_target
              ? `<div>Target: 0x${cycleData.branch_target}</div>`
              : ""
          }
          ${
            cycleData.branch_pc
              ? `<div>at PC=0x${cycleData.branch_pc}</div>`
              : ""
          }
          ${
            cycleData.branch_prediction
              ? `<div>Prediction: ${cycleData.branch_prediction}</div>`
              : ""
          }
        </div>
      </li>`;
    }

    statusHTML += "</ul>";
    document.getElementById("pipeline-status").innerHTML = statusHTML;
  }

  function updateHazardInfo(cycleData) {
    let html = "";

    // Better load-use hazard detection
    const loadHazard =
      cycleData.load_hazard ||
      cycleData.stall ||
      (cycleData.if_stalled && cycleData.id_stalled);

    // Enhanced forwarding detection
    const exForwarding =
      cycleData.ex_forwarding ||
      cycleData.forwardA === "10" ||
      cycleData.forwardB === "10";

    const memForwarding =
      cycleData.mem_forwarding ||
      cycleData.forwardA === "01" ||
      cycleData.forwardB === "01";

    // Improved branch misprediction detection
    const branchMispredicted =
      cycleData.branch_mispredicted ||
      cycleData.flush ||
      cycleData.flush_occurred ||
      (cycleData.branch_taken && cycleData.branch_prediction === "not taken");

    // Store inferences back for highlighting
    cycleData.load_hazard = loadHazard;
    cycleData.ex_forwarding = exForwarding;
    cycleData.mem_forwarding = memForwarding;
    cycleData.branch_mispredicted = branchMispredicted;

    // Generate detailed HTML for hazard display
    if (loadHazard) {
      html += `<div class="hazard data-hazard">
                  <div class="hazard-title">Load-Use Hazard Detected</div>
                  <div class="hazard-resolution">Resolution: Pipeline Stall</div>
                  <div class="hazard-detail">
                    Memory access followed by dependent instruction requires stalling
                  </div>
              </div>`;
    }

    if (exForwarding) {
      html += `<div class="hazard data-hazard">
                  <div class="hazard-title">Data Hazard Detected</div>
                  <div class="hazard-resolution">Resolution: EX → EX Forwarding</div>
                  <div class="hazard-detail">
                    ALU result forwarded from previous instruction
                  </div>
              </div>`;
    }

    if (memForwarding) {
      html += `<div class="hazard data-hazard">
                  <div class="hazard-title">Data Hazard Detected</div>
                  <div class="hazard-resolution">Resolution: MEM → EX Forwarding</div>
                  <div class="hazard-detail">
                    Memory or ALU result forwarded from older instruction
                  </div>
              </div>`;
    }

    if (branchMispredicted) {
      html += `<div class="hazard control-hazard">
                  <div class="hazard-title">Branch Misprediction Detected</div>
                  <div class="hazard-resolution">Resolution: Pipeline Flush</div>
                  <div class="hazard-detail">
                    ${
                      cycleData.branch_pc
                        ? `Branch at PC=${cycleData.branch_pc}`
                        : "Branch prediction was incorrect"
                    }
                    ${
                      cycleData.branch_prediction
                        ? `(Predicted: ${cycleData.branch_prediction})`
                        : ""
                    }
                  </div>
              </div>`;
    }

    // Show no hazards message if none detected
    hazardInfo.innerHTML =
      html || "<div class='no-hazard'>No hazards detected</div>";
  }
  function updateRegisters(cycleData) {
    const registers = [];

    // Create register state array
    for (let i = 0; i < 32; i++) {
      // Get register value from cycle data
      const regName = `x${i}`;
      const regValue =
        cycleData[regName] !== undefined ? cycleData[regName] : 0;

        const writtenThisCycle =
        cycleData.mem_wb_reg_write === true &&  // using wb here
        cycleData.mem_wb_rd !== undefined &&    // Use WB stage destination
        cycleData.mem_wb_rd === i &&
        i !== 0;

      const markedAsChanged = cycleData[`${regName}_changed`] === true;

      registers.push({
        num: i,
        value: regValue,
        changed: writtenThisCycle || markedAsChanged,
      });
    }

    // Generate HTML for register display
    let html = "";
    for (let i = 0; i < registers.length; i++) {
      if (i % 8 === 0) html += "<div class='register-row'>";
      html += `
            <div class="register ${
              registers[i].changed ? "register-changed" : ""
            }">
                <span>x${i}</span>
                <span>${registers[i].value}</span>
            </div>`;
      if (i % 8 === 7 || i === registers.length - 1) html += "</div>";
    }

    registerView.innerHTML = html;
  }

  function updateMemory(cycleData) {
    // For demo, show memory addresses 0-32
    let html = "";
    for (let addr = 0; addr < 32; addr += 4) {
      const value = cycleData[`mem_${addr}`] || 0;
      const isChanged =
        cycleData.mem_write && cycleData.mem_write_address === addr;

      html += `
          <div class="memory-cell ${isChanged ? "memory-changed" : ""}">
            <span>mem[${addr}]</span>
            <span>${value}</span>
          </div>`;
    }

    memoryView.innerHTML = html;
  }

  function highlightActivePaths(cycleData) {
    // Reset all paths and highlights
    svg
      .selectAll(".data-path, .control-signal, .branch-path, .prediction-path")
      .classed("active", false)
      .classed("mispredicted", false);

    svg
      .selectAll(".pipeline-module")
      .classed("flushed", false)
      .attr("stroke", null);

    // Highlight standard pipeline paths
    if (cycleData.instruction && cycleData.instruction !== "xxxxxxxx")
      svg.select(".path-IF-ID").classed("active", true);

    if (
      cycleData.if_id_instruction &&
      cycleData.if_id_instruction !== "xxxxxxxx"
    )
      svg.select(".path-ID-EX").classed("active", true);

    if (
      cycleData.id_ex_instruction &&
      cycleData.id_ex_instruction !== "xxxxxxxx"
    )
      svg.select(".path-EX-MEM").classed("active", true);

    if (
      cycleData.ex_mem_instruction &&
      cycleData.ex_mem_instruction !== "xxxxxxxx"
    )
      svg.select(".path-MEM-WB").classed("active", true);

    // Branch-specific path highlighting
    if (cycleData.branch) {
      if (!cycleData.branch_mispredicted) {
        // Correctly predicted branch - show prediction path
        svg
          .select(".prediction-path")
          .classed("active", true)
          .attr("stroke-dasharray", "5,2")
          .attr("stroke-dashoffset", animationOffset);
      } else {
        // Mispredicted branch - show both paths to illustrate the mistake
        svg
          .select(".prediction-path")
          .classed("mispredicted", true)
          .attr("stroke-dasharray", "3,2");

        svg
          .select(".branch-path")
          .classed("active", true)
          .attr("stroke-dasharray", "3,2")
          .attr("stroke-dashoffset", -animationOffset);

        // Highlight the pipeline flush
        svg
          .selectAll(".pipeline-module")
          .filter((d, i, nodes) => {
            const id = d3.select(nodes[i]).attr("id");
            return id === "stage-IF" || id === "stage-ID" || id === "stage-EX";
          })
          .classed("flushed", true);
      }
    }

    // Hazard highlighting
    if (cycleData.load_hazard) {
      svg.select(".hazard-detect").classed("active", true);
      svg.select(".pc-stall").classed("active", true);
      svg.select(".if-id-stall").classed("active", true);

      // Visual indication of stalled stages
      svg.select("#stage-IF").attr("stroke", "#f59e0b");
      svg.select("#stage-ID").attr("stroke", "#f59e0b");
    }

    // Forwarding path highlights with animation
    if (cycleData.ex_forwarding) {
      svg
        .select(".EX-to-ID")
        .classed("active", true)
        .attr("stroke-dasharray", "4,2")
        .attr("stroke-dashoffset", animationOffset);
    }

    if (cycleData.mem_forwarding) {
      svg
        .select(".MEM-to-ID")
        .classed("active", true)
        .attr("stroke-dasharray", "4,2")
        .attr("stroke-dashoffset", animationOffset);
    }

    // Animate the offset for flowing dash effect
    animationOffset = (animationOffset + 1) % 20;
  }

  // Event listeners for buttons
  prevButton.addEventListener("click", function () {
    if (currentCycle > 0) {
      currentCycle--;
      updateDisplay();
    }
  });

  nextButton.addEventListener("click", function () {
    if (currentCycle < pipelineData.cycles.length - 1) {
      currentCycle++;
      updateDisplay();
    }
  });

  playPauseButton.addEventListener("click", function () {
    if (isPlaying) {
      clearInterval(playInterval);
      playPauseButton.textContent = "Play";
      isPlaying = false;
    } else {
      playInterval = setInterval(function () {
        if (currentCycle < pipelineData.cycles.length - 1) {
          currentCycle++;
          updateDisplay();
        } else {
          clearInterval(playInterval);
          playPauseButton.textContent = "Play";
          isPlaying = false;
        }
      }, parseInt(speedSelect.value));
      playPauseButton.textContent = "Pause";
      isPlaying = true;
    }
  });

  function initializeMemory() {
    // If pipelineData doesn't exist yet, wait for it to load
    if (typeof pipelineData === "undefined" || !pipelineData.cycles || pipelineData.cycles.length === 0) {
      setTimeout(initializeMemory, 100);
      return;
    }
    
    // Set initial memory values for all cycles
    for (let i = 0; i < pipelineData.cycles.length; i++) {
      // Set memory[0] = 10 for Fibonacci n value
      pipelineData.cycles[i]["mem_0"] = 10;
    }
    
    // Update display to show initial memory values
    if (currentCycle === 0) {
      updateMemory(pipelineData.cycles[0]);
    }
  }
  // Initialize
  drawPipelinedCPU();
  updateDisplay();
  initializeMemory();

});
