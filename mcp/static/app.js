const UNIT_DEFINITIONS = {
    activity: {
        base: 'Ci',
        options: [
            { unit: 'Ci', label: 'Curies', factor: 1 },
            { unit: 'Bq', label: 'Becquerels', factor: 3.7e10 },
            { unit: 'mCi', label: 'Milli Curies', factor: 1e3 },
            { unit: 'uCi', label: 'Micro Curies', factor: 1e6 },
            { unit: 'nCi', label: 'Nano Curies', factor: 1e9 },
            { unit: 'pCi', label: 'Pico Curies', factor: 1e12 },
            { unit: 'MBq', label: 'Mega Becquerels', factor: 3.7e4 },
            { unit: 'kBq', label: 'Kilo Becquerels', factor: 3.7e7 },
            { unit: 'GBq', label: 'Giga Becquerels', factor: 3.7e1 },
            { unit: 'TBq', label: 'Tera Becquerels', factor: 3.7e-2 },
            { unit: 'dps', label: 'DPS', factor: 3.7e10 },
            { unit: 'dpm', label: 'DPM', factor: 2.22e12 }
        ]
    },
    distance: {
        base: 'cm',
        options: [
            { unit: 'cm', label: 'Centimeter', factor: 1 },
            { unit: 'm', label: 'Meter', factor: 0.01 },
            { unit: 'inch', label: 'Inch', factor: 1 / 2.54 },
            { unit: 'foot', label: 'Foot', factor: 1 / (2.54 * 12) },
            { unit: 'yard', label: 'Yard', factor: 1 / (2.54 * 12 * 3) }
        ]
    },
    dose: {
        base: 'Rem',
        options: [
            { unit: 'Rem', label: 'Rem', factor: 1 },
            { unit: 'mRem', label: 'mRem', factor: 1000 },
            { unit: 'uRem', label: 'uRem', factor: 1e6 }
        ]
    },
    energy: {
        base: 'mev',
        options: [
            { unit: 'mev', label: 'MeV', factor: 1 },
            { unit: 'kev', label: 'keV', factor: 1000 }
        ]
    },
    exposure: {
        base: 'R',
        options: [
            { unit: 'R', label: 'R', factor: 1 },
            { unit: 'mR', label: 'mR', factor: 1000 },
            { unit: 'uR', label: 'uR', factor: 1e6 }
        ]
    },
    exposure_rate: {
        base: 'R/hr',
        options: [
            { unit: 'R/hr', label: 'R/hr', factor: 1 },
            { unit: 'mR/hr', label: 'mR/hr', factor: 1000 },
            { unit: 'uR/hr', label: 'uR/hr', factor: 1e6 }
        ]
    },
    time: {
        base: 's',
        options: [
            { unit: 's', label: 'Seconds', factor: 1 },
            { unit: 'min', label: 'Minutes', factor: 1 / 60 },
            { unit: 'hr', label: 'Hours', factor: 1 / (60 * 60) },
            { unit: 'd', label: 'Days', factor: 1 / (60 * 60 * 24) },
            { unit: 'y', label: 'Years', factor: 1 / (60 * 60 * 24 * 365.25) }
        ]
    }
};

let activeTool = null;
let chartInstance = null;
let cachedTools = [];

document.addEventListener('DOMContentLoaded', async () => {
    // Basic router setup
    document.getElementById('nav-links').addEventListener('click', (e) => {
        if (e.target.tagName === 'A') {
            e.preventDefault();
            const target = e.target.getAttribute('data-target');
            if (target) {
                navigateTo(target);
                // Close sidebar on mobile
                const sidebar = document.getElementById('sidebar');
                if (sidebar) sidebar.classList.remove('open');
            }
        }
    });

    // Mobile menu toggle
    const menuBtn = document.getElementById('mobile-menu-btn');
    const sidebar = document.getElementById('sidebar');
    if (menuBtn && sidebar) {
        menuBtn.addEventListener('click', () => {
            sidebar.classList.toggle('open');
        });
    }

    try {
        // Update MCP config URL based on current location
        const configCode = document.getElementById('mcp-config-http');
        if (configCode) {
            const currentUrl = window.location.origin + '/mcp/sse';
            configCode.textContent = configCode.textContent.replace('http://localhost:8080/mcp/sse', currentUrl);
        }

        const res = await fetch('/api/tools');
        const tools = await res.json();
        cachedTools = tools;

        buildSidebar(tools);
        buildOverviewGrid(tools);
    } catch (e) {
        console.error("Failed to load tools", e);
    }
});

function buildSidebar(tools) {
    const nav = document.getElementById('nav-links');
    tools.forEach(tool => {
        const a = document.createElement('a');
        a.href = "#";
        a.className = "nav-item";
        a.setAttribute('data-target', tool.name);
        a.textContent = formatToolName(tool.name);
        nav.appendChild(a);
    });
}

function buildOverviewGrid(tools) {
    const grid = document.getElementById('tools-overview-grid');
    tools.forEach(tool => {
        const card = document.createElement('div');
        card.className = "card tool-card";
        card.innerHTML = `
            <div class="tool-name">${formatToolName(tool.name)}</div>
            <div class="tool-desc">${tool.description}</div>
        `;
        card.onclick = () => navigateTo(tool.name);
        grid.appendChild(card);
    });
}

function navigateTo(target) {
    // Update nav links
    document.querySelectorAll('.nav-item').forEach(el => {
        el.classList.toggle('active', el.getAttribute('data-target') === target);
    });

    // Toggle sections
    document.querySelectorAll('.page-section').forEach(el => el.classList.remove('active'));

    if (target === 'home') {
        document.getElementById('home').classList.add('active');
        activeTool = null;
    } else if (target === 'mcp-server') {
        document.getElementById('mcp-server').classList.add('active');
        activeTool = null;
    } else {
        document.getElementById('tool-view').classList.add('active');
        loadToolView(target);
    }
}

function formatToolName(name) {
    return name.replace('_calc', '').replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
}

function loadToolView(toolName) {
    const tool = cachedTools.find(t => t.name === toolName);
    if (!tool) return;
    activeTool = tool;

    document.getElementById('tool-title').textContent = formatToolName(tool.name);
    document.getElementById('tool-description').textContent = tool.description;

    // Hide results and charts initially
    document.getElementById('results-area').style.display = 'none';
    document.getElementById('chart-area').style.display = 'none';

    // Build Form
    const form = document.getElementById('calc-form');
    form.innerHTML = ''; // clear

    if (tool.isConversion) {
        const units = UNIT_DEFINITIONS[tool.unit_type].options;
        const container = document.createElement('div');
        container.className = 'dual-converter';

        container.innerHTML = `
            <div class="converter-row">
                <label>Input</label>
                <div class="input-with-unit">
                    <input type="number" step="any" id="conv_from_val" placeholder="0" value="1">
                    <select id="conv_from_unit">
                        ${units.map(u => `<option value="${u.unit}">${u.unit}</option>`).join('')}
                    </select>
                </div>
            </div>
            <div class="converter-equals">⇅</div>
            <div class="converter-row">
                <label>Output</label>
                <div class="input-with-unit">
                    <input type="number" step="any" id="conv_to_val" placeholder="0">
                    <select id="conv_to_unit">
                        ${units.map((u, i) => `<option value="${u.unit}" ${i === 1 ? 'selected' : ''}>${u.unit}</option>`).join('')}
                    </select>
                </div>
            </div>
        `;

        form.appendChild(container);

        const fromInput = document.getElementById('conv_from_val');
        const fromUnit = document.getElementById('conv_from_unit');
        const toInput = document.getElementById('conv_to_val');
        const toUnit = document.getElementById('conv_to_unit');

        const convert = (direction) => {
            const def = UNIT_DEFINITIONS[tool.unit_type];
            if (direction === 'to') {
                const val = parseFloat(fromInput.value);
                if (isNaN(val)) { toInput.value = ''; return; }
                const f1 = def.options.find(o => o.unit === fromUnit.value).factor;
                const f2 = def.options.find(o => o.unit === toUnit.value).factor;
                // Base = Val / f1 => Result = Base * f2
                toInput.value = (val / f1 * f2).toPrecision(6);
            } else {
                const val = parseFloat(toInput.value);
                if (isNaN(val)) { fromInput.value = ''; return; }
                const f1 = def.options.find(o => o.unit === fromUnit.value).factor;
                const f2 = def.options.find(o => o.unit === toUnit.value).factor;
                // Base = Val / f2 => Result = Base * f1
                fromInput.value = (val / f2 * f1).toPrecision(6);
            }
        };

        fromInput.oninput = () => convert('to');
        fromUnit.onchange = () => convert('to');
        toInput.oninput = () => convert('from');
        toUnit.onchange = () => convert('to');

        // Initial conversion
        convert('to');
        return;
    }

    // Standard Calculator UI
    if (tool.solve_for_options) {
        const solveForGroup = document.createElement('div');
        solveForGroup.className = 'form-group';
        solveForGroup.innerHTML = `
            <label>Solve For</label>
            <select id="solve_for" name="solve_for">
                ${tool.solve_for_options.map(opt => `<option value="${opt}">${opt.replace(/_/g, ' ').toUpperCase()}</option>`).join('')}
            </select>
        `;
        form.appendChild(solveForGroup);
    }

    // Add input fields
    tool.fields.forEach(field => {
        const div = document.createElement('div');
        div.className = 'form-group';
        div.id = `group_${field.name}`;

        const unitInfo = UNIT_DEFINITIONS[field.type];
        if (unitInfo) {
            div.innerHTML = `
                <label>${field.name.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}</label>
                <div class="input-with-unit">
                    <input type="number" step="any" id="${field.name}" name="${field.name}">
                    <select name="${field.name}_unit">
                        ${unitInfo.options.map(o => `<option value="${o.unit}">${o.unit}</option>`).join('')}
                    </select>
                </div>
            `;
        } else {
            div.innerHTML = `
                <label>${field.name.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}</label>
                <input type="number" step="any" id="${field.name}" name="${field.name}">
            `;
        }
        form.appendChild(div);
    });

    const submitBtn = document.createElement('button');
    submitBtn.type = "submit";
    submitBtn.textContent = "Calculate";
    form.appendChild(submitBtn);

    // Form logic to disable the solving field
    const solveSelect = document.getElementById('solve_for');
    if (solveSelect) {
        const updateDisabledField = () => {
            const solving = solveSelect.value;
            tool.fields.forEach(field => {
                const input = document.getElementById(field.name);
                const dropdown = document.querySelector(`select[name="${field.name}_unit"]`);
                if (field.name === solving) {
                    input.value = '';
                    input.disabled = true;
                    input.placeholder = "Calculating...";
                    if (dropdown) dropdown.disabled = true;
                } else {
                    input.disabled = false;
                    input.placeholder = "";
                    if (dropdown) dropdown.disabled = false;
                }
            });
        };

        solveSelect.addEventListener('change', updateDisabledField);
        updateDisabledField(); // initial state
    }

    form.onsubmit = handleCalculate;
}

async function handleCalculate(e) {
    e.preventDefault();
    if (!activeTool) return;

    const formData = new FormData(e.target);
    const data = { solve_for: formData.get('solve_for') };

    activeTool.fields.forEach(field => {
        if (field.name === data.solve_for) return;

        let val = formData.get(field.name);
        if (!val) return;
        val = parseFloat(val);

        const unit = formData.get(`${field.name}_unit`);
        if (unit) {
            // Convert to base unit
            const def = UNIT_DEFINITIONS[field.type];
            const factor = def.options.find(o => o.unit === unit).factor;
            data[field.name] = val / factor;
        } else {
            data[field.name] = val;
        }
    });

    try {
        const res = await fetch(`/api/calculate/${activeTool.name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        if (!res.ok) throw new Error(await res.text());

        const json = await res.json();

        document.getElementById('results-area').style.display = 'block';

        // Convert result back to selected unit if applicable
        let displayValue = json.result;
        const solving = data.solve_for;
        const solvingField = activeTool.fields.find(f => f.name === solving);
        const solvingUnit = formData.get(`${solving}_unit`);

        if (solvingField && solvingUnit && UNIT_DEFINITIONS[solvingField.type]) {
            const def = UNIT_DEFINITIONS[solvingField.type];
            const factor = def.options.find(o => o.unit === solvingUnit).factor;
            displayValue = displayValue * factor;
        }

        document.getElementById('result-value').textContent = Number(displayValue).toPrecision(6);
        document.getElementById('result-explanation').textContent = json.explanation || '';

        renderVisualization(activeTool.name, data, json.result);

    } catch (err) {
        alert("Error: " + err.message);
    }
}

// Very basic visualization logic
function renderVisualization(toolName, inputParams, result) {
    const chartArea = document.getElementById('chart-area');

    // Destroy previous chart
    if (chartInstance) {
        chartInstance.destroy();
        chartInstance = null;
    }

    // Only visualize half life for now
    if (toolName === 'half_life_calc' && inputParams.solve_for !== 'half_life') {
        chartArea.style.display = 'block';
        const ctx = document.getElementById('vizChart').getContext('2d');

        // Generate exponential decay curve
        const labels = [];
        const dataValues = [];

        const hl = inputParams.half_life || 1;
        const ia = inputParams.solve_for === 'initial_activity' ? result : (inputParams.initial_activity || 100);

        for (let i = 0; i <= 5; i += 0.5) {
            labels.push(`${(i * hl).toFixed(1)}t`);
            dataValues.push(ia * Math.pow(0.5, i));
        }

        chartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Activity over Time',
                    data: dataValues,
                    borderColor: '#3b82f6',
                    tension: 0.1,
                    fill: true,
                    backgroundColor: 'rgba(59, 130, 246, 0.1)'
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });
    } else {
        chartArea.style.display = 'none';
    }
}
