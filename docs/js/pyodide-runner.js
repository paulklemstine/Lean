// Aether — Pyodide Interactive Demo Runner
document.addEventListener('DOMContentLoaded', () => {
    // Initialize Pyodide asynchronously
    async function initPyodide() {
        if (window.Aether.pyodideInstance || window.Aether.isPyodideLoading) return;
        window.Aether.isPyodideLoading = true;
        try {
            console.log("Loading Pyodide...");
            window.Aether.pyodideInstance = await loadPyodide();
            // Load micropip so we can install packages later
            await window.Aether.pyodideInstance.loadPackage("micropip");
            console.log("Pyodide + micropip loaded!");

            document.querySelectorAll('.run-btn').forEach(btn => {
                btn.disabled = false;
                btn.textContent = 'Run Code';
            });

            // Auto-run any pending visualizations
            if (window.Aether.pendingVisualizations) {
                for (const viz of window.Aether.pendingVisualizations) {
                    window.runVisualization(viz.code, viz.outputContainer, viz.buttonEl);
                }
                window.Aether.pendingVisualizations = [];
            }
        } catch (err) {
            console.error("Failed to load Pyodide:", err);
        }
        window.Aether.isPyodideLoading = false;
    }

    // Start loading Pyodide immediately
    initPyodide();

    function buildLocalModuleCode(code, pkgData) {
        const knownLocalModules = ['algorithms', 'demo'];
        const localModuleRe = /^from\s+(\w+)\s+import\s+/gm;
        const bareImportRe = /^\s*import\s+(\w+)\s*$/gm;
        const neededModules = new Set();
        let match;
        while ((match = localModuleRe.exec(code)) !== null) {
            if (knownLocalModules.includes(match[1])) {
                neededModules.add(match[1]);
            }
        }
        while ((match = bareImportRe.exec(code)) !== null) {
            if (knownLocalModules.includes(match[1])) {
                neededModules.add(match[1]);
            }
        }

        if (neededModules.size === 0) return '';

        let preamble = '';

        for (const modName of neededModules) {
            if (pkgData && pkgData.modules && pkgData.modules[modName]) {
                preamble += `# --- ${modName} module (from Aristotle output) ---\n`;
                preamble += pkgData.modules[modName];
                preamble += `\n\n# --- Register ${modName} module ---\n`;
                preamble += 'import types as _types_' + modName + '\n';
                preamble += 'import sys as _sys_' + modName + '\n';
                preamble += `_mod_${modName} = _types_${modName}.ModuleType("${modName}")\n`;
                preamble += `for _n in list(globals().keys()):\n`;
                preamble += `    if not _n.startswith("_") and _n not in ("_types_${modName}", "_sys_${modName}", "_mod_${modName}"):\n`;
                preamble += `        try:\n`;
                preamble += `            setattr(_mod_${modName}, _n, globals()[_n])\n`;
                preamble += `        except Exception:\n`;
                preamble += `            pass\n`;
                preamble += `_sys_${modName}.modules["${modName}"] = _mod_${modName}\n`;
                preamble += `# --- End ${modName} module ---\n\n`;
                continue;
            }

            if (modName === 'algorithms' && pkgData && pkgData.algorithms) {
                const codeParts = [];
                const seenCode = new Set();
                for (const algo of pkgData.algorithms) {
                    if (algo.code && !seenCode.has(algo.code)) {
                        seenCode.add(algo.code);
                        codeParts.push(algo.code.trim());
                    }
                }
                if (codeParts.length > 0) {
                    preamble += `# --- algorithms module (from code fields) ---\n`;
                    preamble += codeParts.join('\n\n');
                    preamble += `\n\n# --- Register algorithms module ---\n`;
                    preamble += 'import types as _types_algorithms\n';
                    preamble += 'import sys as _sys_algorithms\n';
                    preamble += '_mod_algorithms = _types_algorithms.ModuleType("algorithms")\n';
                    preamble += 'for _n in list(globals().keys()):\n';
                    preamble += '    if not _n.startswith("_") and _n not in ("_types_algorithms", "_sys_algorithms", "_mod_algorithms"):\n';
                    preamble += '        try:\n';
                    preamble += '            setattr(_mod_algorithms, _n, globals()[_n])\n';
                    preamble += '        except Exception:\n';
                    preamble += '            pass\n';
                    preamble += '_sys_algorithms.modules["algorithms"] = _mod_algorithms\n';
                    preamble += '# --- End algorithms module ---\n\n';
                    continue;
                }
            }

            if (modName === 'algorithms') {
                preamble += buildAlgorithmStubs(code, pkgData);
                continue;
            }

            console.warn(`No source code for module '${modName}'`);
        }

        return preamble;
    }

    function buildAlgorithmStubs(code, pkgData) {
        const fromImportRe = /^from\s+algorithms\s+import\s+(.+?)$/gm;
        const bareImportRe = /^\s*import\s+algorithms\b/m;

        const importedNames = new Set();
        let match;
        while ((match = fromImportRe.exec(code)) !== null) {
            match[1].split(',').forEach(name => {
                const clean = name.trim().replace(/\s+as\s+\w+$/, '').trim();
                if (clean) importedNames.add(clean);
            });
        }

        let stubs = '# --- Auto-generated algorithm stubs ---\n';

        if (importedNames.size === 0 && bareImportRe.test(code)) {
            stubs += 'import types\nalgorithms = types.ModuleType("algorithms")\n';
            stubs += 'import sys\nsys.modules["algorithms"] = algorithms\n';
            return stubs;
        }

        if (importedNames.size === 0) return '';

        const pseudocodeMap = {};
        if (pkgData && pkgData.algorithms) {
            pkgData.algorithms.forEach(algo => {
                const name = algo.name ? algo.name.replace(/[^a-zA-Z0-9_]/g, '_') : '';
                if (name && algo.pseudocode) {
                    pseudocodeMap[name] = algo.pseudocode;
                }
            });
        }

        for (const name of importedNames) {
            const isClass = /^[A-Z]/.test(name);

            if (isClass) {
                stubs += `class ${name}:\n`;
                stubs += `    def __init__(self, *args, **kwargs):\n`;
                stubs += `        print(f"[stub] ${name} created")\n`;
                stubs += `    def __getattr__(self, attr):\n`;
                stubs += `        return lambda *a, **kw: print(f"[stub] ${name}.{attr} called")\n`;
            } else {
                const pcode = pseudocodeMap[name];
                if (pcode) {
                    let pyCode = pcode
                        .replace(/^(function|procedure|def)\s+/i, '')
                        .replace(/^return\s+/gm, 'return ')
                        .trim();
                    stubs += `def ${name}(*args, **kwargs):\n`;
                    stubs += `    # Algorithm: ${name}\n`;
                    const lines = pyCode.split('\n');
                    for (const line of lines) {
                        const trimmed = line.trim();
                        if (trimmed) {
                            stubs += `    ${trimmed}\n`;
                        }
                    }
                    stubs += `    pass  # fallback\n\n`;
                } else {
                    stubs += `def ${name}(*args, **kwargs):\n`;
                    stubs += `    # [auto-stub] ${name} - see Algorithms tab for details\n`;
                    stubs += `    import math, random\n`;
                    stubs += `    if args:\n`;
                    stubs += `        if isinstance(args[0], (list, tuple)) and len(args) >= 2:\n`;
                    stubs += `            return random.randint(1, 100)\n`;
                    stubs += `        if isinstance(args[0], int):\n`;
                    stubs += `            return random.randint(1, 100)\n`;
                    stubs += `    return []\n\n`;
                }
            }
        }

        stubs += 'import types as _types\n';
        stubs += '_alg_mod = _types.ModuleType("algorithms")\n';
        for (const name of importedNames) {
            stubs += `_alg_mod.${name} = ${name}\n`;
        }
        stubs += 'import sys as _sys\n';
        stubs += '_sys.modules["algorithms"] = _alg_mod\n';
        stubs += '# --- End auto-generated stubs ---\n\n';

        return stubs;
    }

    window.renderInteractiveDemos = function(containerId, items) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';

        if (items && items.length > 0) {
            items.forEach(item => {
                const card = document.createElement('div');
                card.className = 'code-card';

                const header = document.createElement('div');
                header.className = 'code-header';

                const title = document.createElement('span');
                title.className = 'code-title';
                title.textContent = item.name || 'Interactive Python Demo';

                const runBtn = document.createElement('button');
                runBtn.className = 'run-btn';
                if (!window.Aether.pyodideInstance) {
                    runBtn.disabled = true;
                    runBtn.textContent = 'Loading Engine...';
                } else {
                    runBtn.textContent = 'Run Code';
                }

                header.appendChild(title);
                header.appendChild(runBtn);

                const editor = document.createElement('textarea');
                editor.className = 'code-editor';
                editor.spellcheck = false;
                editor.value = item.code || '';

                const output = document.createElement('pre');
                output.className = 'code-output hidden';

                runBtn.addEventListener('click', async () => {
                    if (!window.Aether.pyodideInstance) return;

                    output.classList.remove('hidden');
                    output.classList.remove('error');
                    output.textContent = 'Preparing environment...';
                    runBtn.disabled = true;

                    let stdout = "";
                    window.Aether.pyodideInstance.setStdout({ batched: (msg) => { stdout += msg + "\n"; } });
                    window.Aether.pyodideInstance.setStderr({ batched: (msg) => { stdout += msg + "\n"; } });

                    try {
                        let codeToRun = editor.value;

                        const localModuleRe = /^(from|import)\s+(algorithms|demo)\b/m;
                        if (localModuleRe.test(codeToRun)) {
                            const moduleCode = buildLocalModuleCode(codeToRun, window.Aether.currentPackage);
                            const localMods = ['algorithms', 'demo'];
                            const lines = codeToRun.split('\n');
                            const filtered = [];
                            let inLocalImport = false;
                            for (const line of lines) {
                                if (inLocalImport) {
                                    if (line.includes(')')) {
                                        inLocalImport = false;
                                    }
                                    continue;
                                }
                                const trimmed = line.trim();
                                let skip = false;
                                for (const mod of localMods) {
                                    if (trimmed.startsWith('from ' + mod + ' import ') || trimmed.startsWith('import ' + mod)) {
                                        skip = true;
                                        if (trimmed.includes('(') && !trimmed.includes(')')) {
                                            inLocalImport = true;
                                        }
                                        break;
                                    }
                                }
                                if (!skip) {
                                    filtered.push(line);
                                }
                            }
                            codeToRun = moduleCode + '\n' + filtered.join('\n');
                        }

                        await window.Aether.pyodideInstance.loadPackagesFromImports(codeToRun);

                        output.textContent = 'Running...';

                        const result = await window.Aether.pyodideInstance.runPythonAsync(codeToRun);
                        if (result !== undefined && result !== null) {
                            stdout += result + "\n";
                        }
                        output.textContent = stdout || "Done. (No output)";
                    } catch (err) {
                        output.classList.add('error');
                        output.textContent = stdout + "\n" + err.toString();
                    } finally {
                        runBtn.disabled = false;
                    }
                });

                card.appendChild(header);
                card.appendChild(editor);
                card.appendChild(output);
                container.appendChild(card);
            });
        } else {
            container.innerHTML = '<p style="color:var(--text-muted)">No interactive demos provided.</p>';
        }
    };

    // --- Visualization Execution ---
    // Runs a Python visualization script (matplotlib or plotly) and renders the output inline.
    // Auto-runs on page load. Auto-detects library and captures output.
    window.runVisualization = async function(code, outputContainer, buttonEl) {
        if (!window.Aether.pyodideInstance) {
            // Queue for auto-run once Pyodide finishes loading
            window.Aether.pendingVisualizations = window.Aether.pendingVisualizations || [];
            window.Aether.pendingVisualizations.push({ code, outputContainer, buttonEl });
            outputContainer.innerHTML = '<div class="viz-loading">Waiting for Pyodide...</div>';
            return;
        }

        const isPlotly = /plotly|go\.Figure|go\.Scatter|go\.Bar|go\.Heatmap|go\.Surface|go\.Contour|px\./.test(code);
        const isMatplotlib = /matplotlib|plt\./.test(code);

        if (buttonEl) {
            buttonEl.disabled = true;
            buttonEl.textContent = 'Generating...';
        }
        outputContainer.innerHTML = '<div class="viz-loading">Installing packages...</div>';

        let stdout = "";
        window.Aether.pyodideInstance.setStdout({ batched: (msg) => { stdout += msg + "\n"; } });
        window.Aether.pyodideInstance.setStderr({ batched: (msg) => { stdout += msg + "\n"; } });

        try {
            // Auto-detect and load all packages from the code imports
            // Build the full wrapped code first so loadPackagesFromImports can scan it
            let fullCode;
            if (isPlotly) {
                fullCode = `
import plotly.io as pio
import plotly.graph_objects as go

${code}

_viz_figs_ = [obj for obj in globals().values() if isinstance(obj, go.Figure)]
if _viz_figs_:
    fig = _viz_figs_[-1]
    _html_out = pio.to_html(fig, full_html=False, include_plotlyjs='cdn')
    print("VIZHTML:" + _html_out)
else:
    print("VIZERROR:No plotly Figure object found. Assign your figure to a variable named 'fig'.")
`;
            } else {
                fullCode = `
import matplotlib
matplotlib.use('AGG')
import matplotlib.pyplot as plt
import io
import base64

${code}

buf = io.BytesIO()
plt.savefig(buf, format='png', dpi=100, bbox_inches='tight', facecolor='white')
buf.seek(0)
img_data = base64.b64encode(buf.read()).decode('utf-8')
plt.close('all')
print("VIZIMG:" + img_data)
`;
            }

            // Load all packages detected from imports (numpy, scipy, pandas, etc.)
            await window.Aether.pyodideInstance.loadPackagesFromImports(fullCode);

            outputContainer.innerHTML = '<div class="viz-loading">Running visualization...</div>';

            // Run the pre-built wrapped code
            await window.Aether.pyodideInstance.runPythonAsync(fullCode);

            // Parse output for VIZIMG: or VIZHTML: markers
            if (stdout.includes('VIZIMG:')) {
                const imgData = stdout.substring(stdout.indexOf('VIZIMG:') + 7).trim();
                const img = document.createElement('img');
                img.src = 'data:image/png;base64,' + imgData;
                img.style.cssText = 'width: 100%; border-radius: 8px; cursor: pointer; display: block;';
                img.title = 'Click to view full size';
                img.addEventListener('click', () => {
                    if (window.openLightbox) {
                        window.Aether.currentVizIndex = 0;
                        window.Aether.currentPackage = window.Aether.currentPackage || {};
                        window.Aether.currentPackage._vizImages = window.Aether.currentPackage._vizImages || [{src: img.src, name: 'Visualization'}];
                        window.openLightbox(0);
                    }
                });
                outputContainer.innerHTML = '';
                outputContainer.appendChild(img);
            } else if (stdout.includes('VIZHTML:')) {
                const htmlData = stdout.substring(stdout.indexOf('VIZHTML:') + 8);
                // Remove any non-HTML lines before the plotly div
                const plotlyStart = htmlData.indexOf('<div');
                const cleanHtml = plotlyStart >= 0 ? htmlData.substring(plotlyStart) : htmlData;
                outputContainer.innerHTML = cleanHtml;
            } else if (stdout.includes('VIZERROR:')) {
                const errMsg = stdout.substring(stdout.indexOf('VIZERROR:') + 10).split('\n')[0];
                outputContainer.innerHTML = `<div class="code-output error">${errMsg}</div>`;
            } else {
                // Fallback: show text output
                outputContainer.innerHTML = `<pre class="code-output">${stdout || 'Done. (No visualization output)'}</pre>`;
            }
        } catch (err) {
            outputContainer.innerHTML = `<pre class="code-output error">${stdout}\n${err.toString()}</pre>`;
        } finally {
            if (buttonEl) {
                buttonEl.disabled = false;
                buttonEl.textContent = 'Regenerate';
            }
        }
    };
});