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
                // Preserve the text of visualization Generate buttons; only
                // interactive Python demos use 'Run Code'.
                if (!btn.classList.contains('viz-generate-btn')) {
                    btn.textContent = 'Run Code';
                }
            });

        } catch (err) {
            console.error("Failed to load Pyodide:", err);
        }
        window.Aether.isPyodideLoading = false;
    }

    // Start loading Pyodide immediately
    initPyodide();

    function extractFutureImports(code) {
        const lines = code.split('\n');
        const futureLines = [];
        const cleanedLines = [];
        for (const line of lines) {
            if (/^\s*from\s+__future__\s+import\b/.test(line)) {
                futureLines.push(line);
            } else {
                cleanedLines.push(line);
            }
        }
        return {
            futureImports: futureLines.join('\n'),
            cleanedCode: cleanedLines.join('\n')
        };
    }

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

    // Single-threaded task queue to prevent concurrent Pyodide / micropip / matplotlib execution deadlocks
    let _pyodideTaskQueue = Promise.resolve();

    function enqueuePyodideTask(taskFn, timeoutMs = 45000) {
        const nextTask = _pyodideTaskQueue.then(async () => {
            let timeoutId;
            const timeoutPromise = new Promise((_, reject) => {
                timeoutId = setTimeout(() => {
                    reject(new Error(`Pyodide execution timed out after ${timeoutMs / 1000}s`));
                }, timeoutMs);
            });
            try {
                return await Promise.race([taskFn(), timeoutPromise]);
            } finally {
                clearTimeout(timeoutId);
            }
        });

        _pyodideTaskQueue = nextTask.catch(() => {});
        return nextTask;
    }

    // Global demo runner used by click handlers and by the Pyodide init auto-run queue.
    window.runDemo = async (runBtn, editor, output) => {
        if (!window.Aether.pyodideInstance) return;

        output.classList.remove('hidden');
        output.classList.remove('error');
        output.textContent = 'Queued...';
        runBtn.disabled = true;

        return enqueuePyodideTask(async () => {
            output.textContent = 'Preparing environment...';
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

                const { futureImports, cleanedCode } = extractFutureImports(codeToRun);
                codeToRun = futureImports ? futureImports + '\n' + cleanedCode : cleanedCode;

                await window.Aether.pyodideInstance.loadPackagesFromImports(codeToRun);

                output.textContent = 'Running...';

                const result = await window.Aether.pyodideInstance.runPythonAsync(codeToRun);
                if (result !== undefined && result !== null) {
                    stdout += result + "\n";
                }

                // Many Aristotle demos define `def main()` guarded by `if __name__ == "__main__":`,
                // which does not execute under Pyodide's runPythonAsync. Detect that pattern and
                // append an explicit main() call so the demo actually produces output.
                const hasMain = /\bdef main\s*\(/.test(editor.value);
                const hasGuard = /if\s+__name__\s*==\s*['"]__main__['"]/.test(editor.value);
                if (hasMain && hasGuard) {
                    try {
                        await window.Aether.pyodideInstance.runPythonAsync("main()");
                    } catch (mainErr) {
                        stdout += "\n" + mainErr.toString();
                    }
                }

                output.textContent = stdout || "Done. (No output)";
            } catch (err) {
                output.classList.add('error');
                output.textContent = stdout + "\n" + err.toString();
            } finally {
                runBtn.disabled = false;
            }
        });
    };

    window.renderInteractiveDemos = function(containerId, items) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';

        if (items && items.length > 0) {
            const sectionTitle = document.createElement('h3');
            sectionTitle.className = 'section-title';
            sectionTitle.textContent = 'Python Demos';
            sectionTitle.style.cssText = 'margin-bottom: 16px; color: var(--accent-color, #7c3aed); border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-top: 32px;';
            container.appendChild(sectionTitle);

            items.forEach(item => {
                const card = document.createElement('div');
                card.className = 'code-card';

                const header = document.createElement('div');
                header.className = 'code-header';

                const title = document.createElement('span');
                title.className = 'code-title';
                title.textContent = item.name || 'Interactive Python Demo';

                const btnGroup = document.createElement('div');
                btnGroup.className = 'code-header-buttons';

                const toggleBtn = document.createElement('button');
                toggleBtn.className = 'source-toggle';
                toggleBtn.textContent = 'Show Source';

                const runBtn = document.createElement('button');
                runBtn.className = 'run-btn';
                if (!window.Aether.pyodideInstance) {
                    runBtn.disabled = true;
                    runBtn.textContent = 'Loading Engine...';
                } else {
                    runBtn.textContent = 'Run Code';
                }

                btnGroup.appendChild(toggleBtn);
                btnGroup.appendChild(runBtn);

                header.appendChild(title);
                header.appendChild(btnGroup);

                const editor = document.createElement('textarea');
                editor.className = 'code-editor collapsed';
                editor.spellcheck = false;
                editor.cols = 80;
                editor.value = item.code || '';

                // Auto-size editor when shown: fit to content
                const autoSizeEditor = () => {
                    editor.style.height = 'auto';
                    editor.style.height = editor.scrollHeight + 'px';
                };

                toggleBtn.addEventListener('click', () => {
                    if (editor.classList.contains('collapsed')) {
                        editor.classList.remove('collapsed');
                        toggleBtn.textContent = 'Hide Source';
                        autoSizeEditor();
                    } else {
                        editor.classList.add('collapsed');
                        toggleBtn.textContent = 'Show Source';
                    }
                });

                const output = document.createElement('pre');
                output.className = 'code-output hidden';

                runBtn.addEventListener('click', () => window.runDemo(runBtn, editor, output));

                card.appendChild(header);
                card.appendChild(editor);
                card.appendChild(output);

                if (item.description) {
                    const descDiv = document.createElement('div');
                    descDiv.className = 'viz-description';
                    descDiv.style.cssText = 'margin-top: 12px; padding: 0 12px; font-size: 0.95em; color: var(--text-muted); text-align: justify; line-height: 1.5;';
                    descDiv.innerHTML = window.renderMarkdownWithMath ? window.renderMarkdownWithMath(item.description) : item.description;
                    card.appendChild(descDiv);
                }

                container.appendChild(card);
            });
        } else {
            container.innerHTML = '<p style="color:var(--text-muted)">No interactive demos provided.</p>';
        }
    };

    // --- Visualization Execution ---
    // Runs a Python visualization script (matplotlib or plotly) and renders the output inline.
    // Auto-runs on page load. Auto-detects library and captures output.
    window.runVisualization = async function(code, outputContainer, buttonEl, description) {
        if (!window.Aether.pyodideInstance) {
            outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted);">Engine still loading — click the button again in a moment.</div>';
            return;
        }

        if (buttonEl) {
            buttonEl.disabled = true;
            buttonEl.textContent = 'Queued...';
        }
        outputContainer.innerHTML = '<div class="viz-loading">Queued visualization...</div>';

        return enqueuePyodideTask(async () => {
            const isPlotly = /plotly|go\.Figure|go\.Scatter|go\.Bar|go\.Heatmap|go\.Surface|go\.Contour|px\./.test(code);
            const isMatplotlib = /matplotlib|plt\./.test(code);

            if (buttonEl) {
                buttonEl.disabled = true;
                buttonEl.textContent = 'Generating...';
            }
            outputContainer.innerHTML = '<div class="viz-loading">Installing packages...</div>';

        try {
            // Handle local module imports (algorithms, demo, etc.) by inlining their code
            let processedCode = code;
            const localModuleRe = /^(from|import)\s+(algorithms|demo)\b/m;
            if (localModuleRe.test(processedCode)) {
                const moduleCode = buildLocalModuleCode(processedCode, window.Aether.currentPackage);
                const localMods = ['algorithms', 'demo'];
                const lines = processedCode.split('\n');
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
                processedCode = moduleCode + '\n' + filtered.join('\n');
            }

            // Fix common matplotlib pattern: plt.subplots() doesn't accept
            // height_ratios/width_ratios as direct kwargs — they must go
            // inside gridspec_kw. Aristotle-generated code often does:
            //   plt.subplots(2, 1, height_ratios=[7, 1], gridspec_kw={...})
            // which raises AttributeError on newer matplotlib.
            processedCode = processedCode.replace(
                /plt\.subplots\(([^)]*)\)/g,
                (match, args) => {
                    // Extract height_ratios and width_ratios from args
                    const hrMatch = args.match(/height_ratios\s*=\s*(\[[\d,\s]+\])/);
                    const wrMatch = args.match(/width_ratios\s*=\s*(\[[\d,\s]+\])/);
                    if (!hrMatch && !wrMatch) return match; // nothing to fix

                    // Remove them from args
                    let cleanedArgs = args
                        .replace(/,\s*height_ratios\s*=\s*\[[\d,\s]+\]/g, '')
                        .replace(/,\s*width_ratios\s*=\s*\[[\d,\s]+\]/g, '')
                        .replace(/height_ratios\s*=\s*\[[\d,\s]+\]\s*,\s*/g, '')
                        .replace(/width_ratios\s*=\s*\[[\d,\s]+\]\s*,\s*/g, '');

                    // Build gridspec_kw entries
                    const gsEntries = [];
                    if (hrMatch) gsEntries.push(`'height_ratios': ${hrMatch[1]}`);
                    if (wrMatch) gsEntries.push(`'width_ratios': ${wrMatch[1]}`);

                    // Check if gridspec_kw already exists
                    const gsMatch = cleanedArgs.match(/gridspec_kw\s*=\s*\{([^}]*)\}/);
                    if (gsMatch) {
                        // Merge into existing gridspec_kw
                        const existing = gsMatch[1].trim();
                        const merged = existing ? `${existing}, ${gsEntries.join(', ')}` : gsEntries.join(', ');
                        cleanedArgs = cleanedArgs.replace(
                            /gridspec_kw\s*=\s*\{[^}]*\}/,
                            `gridspec_kw={${merged}}`
                        );
                    } else {
                        // Add new gridspec_kw
                        cleanedArgs = cleanedArgs.trimEnd();
                        if (cleanedArgs && !cleanedArgs.endsWith(',')) cleanedArgs += ',';
                        cleanedArgs += ` gridspec_kw={${gsEntries.join(', ')}}`;
                    }
                    return `plt.subplots(${cleanedArgs})`;
                }
            );
            // Fix unbraced \fracXY in LaTeX strings (e.g., \frac12 -> \frac{1}{2})
            processedCode = processedCode.replace(/\\frac([a-zA-Z0-9])([a-zA-Z0-9])/g, '\\frac{$1}{$2}');

            // Build the wrapped code so the final expression returns the rendered output.
            // Returning the value avoids relying on the global stdout capture, which is
            // racy when several visualizations/demos auto-run concurrently on load.
            const { futureImports, cleanedCode } = extractFutureImports(processedCode);
            const futureHeader = futureImports ? futureImports + '\n' : '';

            const indentedCleanedCode = cleanedCode.trim()
                ? cleanedCode.split('\n').map(line => '    ' + line).join('\n')
                : '    pass';

            let fullCode;
            if (isPlotly) {
                fullCode = `${futureHeader}import plotly.io as pio
import plotly.graph_objects as go

${cleanedCode}

_viz_figs_ = [obj for obj in globals().values() if isinstance(obj, go.Figure)]
if _viz_figs_:
    fig = _viz_figs_[-1]
    pio.to_html(fig, full_html=False, include_plotlyjs='cdn')
else:
    raise RuntimeError("No plotly Figure object found. Assign your figure to a variable named 'fig'.")
`;
            } else {
                fullCode = `${futureHeader}import matplotlib
matplotlib.use('AGG')
import matplotlib.pyplot as plt
import io
import base64
import os
import re

# Patch matplotlib MathTextParser to handle malformed LaTeX (e.g. unbraced \\frac) gracefully
try:
    import matplotlib.mathtext as _mathtext
    if hasattr(_mathtext, 'MathTextParser') and not hasattr(_mathtext, '_aether_patched'):
        _mathtext._aether_patched = True
        _orig_mathtext_parse = _mathtext.MathTextParser.parse
        def _safe_mathtext_parse(self, s, *args, **kwargs):
            try:
                return _orig_mathtext_parse(self, s, *args, **kwargs)
            except Exception:
                cleaned = re.sub(r'\\\\frac([a-zA-Z0-9])([a-zA-Z0-9])', r'\\\\frac{\\1}{\\2}', s)
                try:
                    return _orig_mathtext_parse(self, cleaned, *args, **kwargs)
                except Exception:
                    plain = s.replace('$', '')
                    try:
                        return _orig_mathtext_parse(self, plain, *args, **kwargs)
                    except Exception:
                        return _orig_mathtext_parse(self, 'text', *args, **kwargs)
        _mathtext.MathTextParser.parse = _safe_mathtext_parse
except Exception:
    pass

# Record initial files in working directory so we can detect any images saved to disk
_initial_files = set(os.listdir('.'))

# Track closed figures in case plt.close() was called without saving to disk
_closed_figs = []
_orig_close = plt.close
_orig_show = plt.show

def _viz_close(*args, **kwargs):
    try:
        fig = plt.gcf()
        if fig and fig not in _closed_figs:
            _closed_figs.append(fig)
    except Exception:
        pass
    try:
        return _orig_close(*args, **kwargs)
    except Exception:
        pass

def _viz_show(*args, **kwargs):
    pass

plt.close = _viz_close
plt.show = _viz_show

try:
${indentedCleanedCode}
finally:
    plt.close = _orig_close
    plt.show = _orig_show

# Check for newly generated image files on disk (.png, .jpg, .jpeg, .svg, .webp)
_img_exts = ('.png', '.jpg', '.jpeg', '.svg', '.webp')
_new_files = [f for f in os.listdir('.') if f not in _initial_files and f.lower().endswith(_img_exts)]

if _new_files:
    # Sort by modification time to get the latest generated files
    _new_files.sort(key=lambda f: os.path.getmtime(f) if os.path.exists(f) else 0)
    _target_file = _new_files[-1]
    
    if _target_file.lower().endswith('.svg'):
        with open(_target_file, 'r', encoding='utf-8') as f:
            _viz_result = 'SVG_CONTENT:' + f.read()
    else:
        _ext = _target_file.split('.')[-1].lower()
        if _ext == 'jpg': _ext = 'jpeg'
        with open(_target_file, 'rb') as f:
            _b64 = base64.b64encode(f.read()).decode('utf-8')
        _viz_result = f'data:image/{_ext};base64,{_b64}'
        
    for f in _new_files:
        try:
            os.remove(f)
        except Exception:
            pass
else:
    # No files saved to disk: capture active figure or last closed figure
    buf = io.BytesIO()
    _fig_to_save = None
    if plt.get_fignums():
        _fig_to_save = plt.gcf()
    elif _closed_figs:
        _fig_to_save = _closed_figs[-1]
        
    if _fig_to_save is not None:
        _fig_to_save.savefig(buf, format='png', dpi=100, bbox_inches='tight', facecolor='white')
        buf.seek(0)
        _viz_result = 'data:image/png;base64,' + base64.b64encode(buf.read()).decode('utf-8')
    else:
        _viz_result = ''

plt.close('all')
_viz_result
`;
            }

            // Load all packages detected from imports (numpy, scipy, pandas, etc.)
            await window.Aether.pyodideInstance.loadPackagesFromImports(fullCode);

            outputContainer.innerHTML = '<div class="viz-loading">Running visualization...</div>';

            // Run the wrapped code, retrying on missing module errors
            let result;
            let attempts = 0;
            while (attempts < 3) {
                try {
                    result = await window.Aether.pyodideInstance.runPythonAsync(fullCode);
                    break;
                } catch (runErr) {
                    const match = runErr.toString().match(/ModuleNotFoundError.*module '(\w+)'/);
                    if (match && attempts < 2) {
                        const modName = match[1];
                        console.log(`Auto-loading missing module: ${modName}`);
                        outputContainer.innerHTML = `<div class="viz-loading">Loading ${modName}...</div>`;
                        try {
                            await window.Aether.pyodideInstance.loadPackage(modName);
                        } catch {
                            try {
                                await window.Aether.pyodideInstance.runPythonAsync(`import micropip; await micropip.install("${modName}")`);
                            } catch {}
                        }
                        attempts++;
                    } else {
                        throw runErr;
                    }
                }
            }

            // result is either a base64 PNG string (matplotlib) or plotly HTML
            if (isPlotly) {
                // Remove any non-HTML lines before the plotly div, just in case
                const htmlData = String(result || '');
                const plotlyStart = htmlData.indexOf('<div');
                const cleanHtml = plotlyStart >= 0 ? htmlData.substring(plotlyStart) : htmlData;
                outputContainer.innerHTML = cleanHtml;
            } else if (result && typeof result === 'string' && result.startsWith('SVG_CONTENT:')) {
                const svgData = result.substring('SVG_CONTENT:'.length);
                outputContainer.innerHTML = svgData;
                const svgEl = outputContainer.querySelector('svg');
                if (svgEl) {
                    svgEl.style.cssText = 'max-width: 100%; height: auto; display: block; margin: 0 auto; border-radius: 8px;';
                }
            } else {
                const imgData = String(result || '').trim();
                if (!imgData) {
                    outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted); padding: 12px 0;">No image output generated by visualization.</div>';
                } else {
                    const img = document.createElement('img');
                    img.src = imgData.startsWith('data:') ? imgData : ('data:image/png;base64,' + imgData);
                    img.alt = description || '';
                    img.style.cssText = 'width: 100%; border-radius: 8px; cursor: pointer; display: block;';
                    img.title = 'Click to view full size';
                    img.addEventListener('click', () => {
                        if (window.openLightbox) {
                            const pkg = window.Aether.currentPackage || {};
                            // Build _vizImages from all generated images currently on the page
                            const allImgs = document.querySelectorAll('.gallery-img-container img');
                            pkg._vizImages = Array.from(allImgs).map((i, idx) => ({
                                data: i.src,
                                name: i.closest('.viz-container')?.querySelector('.code-title')?.textContent || `Visualization ${idx + 1}`
                            }));
                            window.Aether.currentPackage = pkg;
                            // Find this image's index
                            const myIndex = pkg._vizImages.findIndex(v => v.data === img.src);
                            window.Aether.currentVizIndex = myIndex >= 0 ? myIndex : 0;
                            window.openLightbox(window.Aether.currentVizIndex);
                        }
                    });
                    outputContainer.innerHTML = '';
                    outputContainer.appendChild(img);
                }
            }
        } catch (err) {
            outputContainer.innerHTML = `<pre class="code-output error">${err.toString()}</pre>`;
        } finally {
            if (buttonEl) {
                buttonEl.disabled = false;
                buttonEl.textContent = 'Generate';
            }
        }
        });
    };
});