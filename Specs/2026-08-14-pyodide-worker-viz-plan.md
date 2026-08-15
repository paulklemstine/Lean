# Pyodide Web Worker — Non-Blocking Visualization Generation: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move all Pyodide Python execution into a Web Worker so visualization generation and interactive demos never freeze the browser tab, with a 45s warning + Cancel control for long runs.

**Architecture:** `Packages/js/pyodide-worker.js` (new) loads Pyodide and executes wrapped Python, returning result strings via `postMessage`. `Packages/js/pyodide-runner.js` becomes a main-thread orchestrator: it keeps every code transform (module inlining, matplotlib/plotly wrapping, LaTeX fixes), the serialization queue, and DOM rendering; it adds a 45s "Still generating… Cancel" warning. The engine-ready flag moves from `pyodideInstance` to `pyodideReady`.

**Tech Stack:** Vanilla JS, Web Workers, Pyodide v0.25.0 (CDN), Firebase Hosting (`docs/` is deployed; `Packages/` is source of truth).

## Global Constraints

- `Packages/` is the single source of truth for frontend code. Never edit `docs/` directly — sync via `rsync -a Packages/js/ docs/js/` + `rsync -a Packages/index.html docs/index.html` after each task that touches them.
- Keep Pyodide pinned to `https://cdn.jsdelivr.net/pyodide/v0.25.0/full/` (matches current index.html).
- Do not change rendered output formats: plotly HTML, base64 PNG data URI, or `SVG_CONTENT:`-prefixed SVG — the rendering block in `runVisualization` is preserved verbatim.
- All Python execution must live behind the worker; the main thread must never call `runPythonAsync`/`loadPyodide`.
- Worker `indexURL` must be passed explicitly (`loadPyodide({ indexURL: 'https://cdn.jsdelivr.net/pyodide/v0.25.0/full/' })`) — in a worker `document.currentScript` is unavailable.
- No cross-origin isolation / SharedArrayBuffer is assumed. Cancel aborts via `worker.terminate()` + respawn.
- Every JS change is syntax-checked with `node --check`.

---

### Task 1: Engine-ready flag + remove main-thread Pyodide script

**Files:**
- Modify: `Packages/js/state.js:6-7`
- Modify: `Packages/index.html:35`
- Sync: `docs/js/state.js`, `docs/index.html`

**Interfaces:**
- Consumes: nothing.
- Produces: `window.Aether.pyodideReady` (boolean, starts `false`) and `window.Aether.isPyodideLoading` (boolean, kept) — later tasks set/read these. `window.Aether.pyodideInstance` no longer exists.

- [ ] **Step 1: Update the state flag**

In `Packages/js/state.js`, replace:

```js
    pyodideInstance: null,
    isPyodideLoading: false,
```

with:

```js
    pyodideReady: false,
    isPyodideLoading: false,
```

- [ ] **Step 2: Remove the main-thread Pyodide script tag**

In `Packages/index.html`, delete line 35:

```html
    <script src="https://cdn.jsdelivr.net/pyodide/v0.25.0/full/pyodide.js"></script>
```

(The worker imports the same file itself; nothing else on the main thread calls `loadPyodide` after the refactor.)

- [ ] **Step 3: Verify**

Run: `node --check Packages/js/state.js`
Expected: no output (syntax OK).

Run: `grep -n "loadPyodide\|pyodideInstance" Packages/index.html Packages/js/state.js`
Expected: no matches (the only remaining `loadPyodide` references will be the new worker file from Task 2).

- [ ] **Step 4: Sync to docs/ and commit**

```bash
rsync -a Packages/js/ docs/js/
rsync -a Packages/index.html docs/index.html
git add Packages/js/state.js Packages/index.html docs/js/state.js docs/index.html
git commit -m "feat(viz): move pyodide engine flag to pyodideReady; drop main-thread pyodide script"
```

Note: the repo's pre-commit hook auto-bumps `version.js` in `Packages/` and `docs/` — include those files in the commit if the hook stages them.

---

### Task 2: Create the Pyodide worker

**Files:**
- Create: `Packages/js/pyodide-worker.js`
- Sync: `docs/js/pyodide-worker.js`

**Interfaces:**
- Consumes: nothing (self-contained).
- Produces: worker that answers messages:
  - `{ type: 'run', id: number, steps: Array<{ code: string, tolerant: boolean }> }`
  - On pyodide loaded → `{ type: 'ready' }`.
  - On completion → `{ type: 'done', id, result: any, stdout: string }`.
  - On failure → `{ type: 'error', id, message: string }`.
  - On a missing-module install → `{ type: 'status', message: string }`.
  - On load failure → `{ type: 'fatal', message: string }`.

- [ ] **Step 1: Write the worker file**

Create `Packages/js/pyodide-worker.js` with exactly this content:

```js
// Aether — Pyodide Web Worker
// Runs all Python execution (interactive demos + visualizations) off the
// main thread so the page stays responsive during heavy generation.
importScripts('https://cdn.jsdelivr.net/pyodide/v0.25.0/full/pyodide.js');

const PYODIDE_INDEX_URL = 'https://cdn.jsdelivr.net/pyodide/v0.25.0/full/';

let pyodide = null;
let initPromise = null;

async function init() {
    if (!initPromise) {
        initPromise = (async () => {
            pyodide = await loadPyodide({ indexURL: PYODIDE_INDEX_URL });
            await pyodide.loadPackage('micropip');
            return pyodide;
        })();
    }
    return initPromise;
}

// Run one code string, auto-loading any missing modules (retry up to 2x).
async function runWithRetry(code) {
    await pyodide.loadPackagesFromImports(code);
    let attempts = 0;
    while (true) {
        try {
            return await pyodide.runPythonAsync(code);
        } catch (runErr) {
            const match = String(runErr).match(/ModuleNotFoundError.*module '(\w+)'/);
            if (match && attempts < 2) {
                const modName = match[1];
                attempts++;
                self.postMessage({ type: 'status', message: `Loading ${modName}...` });
                try {
                    await pyodide.loadPackage(modName);
                } catch {
                    try {
                        await pyodide.runPythonAsync(`import micropip; await micropip.install("${modName}")`);
                    } catch {}
                }
            } else {
                throw runErr;
            }
        }
    }
}

async function runSteps(steps) {
    let stdout = '';
    pyodide.setStdout({ batched: (msg) => { stdout += msg + '\n'; } });
    pyodide.setStderr({ batched: (msg) => { stdout += msg + '\n'; } });
    let result;
    for (const step of steps) {
        try {
            result = await runWithRetry(step.code);
        } catch (err) {
            if (step.tolerant) {
                stdout += '\n' + String(err && err.message || err);
            } else {
                throw err;
            }
        }
    }
    return { result, stdout };
}

self.onmessage = async (e) => {
    const msg = e.data;
    if (msg && msg.type === 'run') {
        try {
            await init();
            const { result, stdout } = await runSteps(msg.steps);
            self.postMessage({ type: 'done', id: msg.id, result, stdout });
        } catch (err) {
            self.postMessage({ type: 'error', id: msg.id, message: String(err && err.message || err) });
        }
    }
};

init().then(() => {
    self.postMessage({ type: 'ready' });
}).catch((err) => {
    self.postMessage({ type: 'fatal', message: String(err && err.message || err) });
});
```

- [ ] **Step 2: Verify syntax**

Run: `node --check Packages/js/pyodide-worker.js`
Expected: no output (syntax OK; `importScripts`/`self` are globals that only need to exist at runtime).

- [ ] **Step 3: Sync and commit**

```bash
rsync -a Packages/js/ docs/js/
git add Packages/js/pyodide-worker.js docs/js/pyodide-worker.js
git commit -m "feat(viz): add pyodide web worker executor"
```

---

### Task 3: Refactor `pyodide-runner.js` into a main-thread orchestrator

**Files:**
- Modify: `Packages/js/pyodide-runner.js` (whole file rewritten; the transform functions and DOM code are preserved verbatim)
- Sync: `docs/js/pyodide-runner.js`

**Interfaces:**
- Consumes: `window.Aether.pyodideReady` / `window.Aether.isPyodideLoading` (Task 1); worker protocol (Task 2).
- Produces (public API unchanged):
  - `window.runVisualization(code, outputContainer, buttonEl, description)`
  - `window.runDemo(runBtn, editor, output)`
  - `window.renderInteractiveDemos(containerId, items)`
  - Internal helpers: `startWorker()`, `runInWorker(steps, onStatus)`, `cancelActiveRun()`, `enqueueWorkerTask(taskFn)`, `runningVizCards` (WeakMap of button → cancel entry).

- [ ] **Step 1: Rewrite the engine-orchestration block (lines 1–31 and 213–233)**

Replace the top-of-file `initPyodide()` block and the `_pyodideTaskQueue`/`enqueuePyodideTask` block with worker machinery:

```js
// Aether — Pyodide Interactive Demo Runner
// Main-thread orchestrator. All Python execution happens in a Web Worker
// (js/pyodide-worker.js) so heavy generation never freezes the page.

// ---- Worker lifecycle ------------------------------------------------------
let _worker = null;
let _engineReady = null;   // Promise<void> for the current worker
let _readyResolve = null;
let _readyReject = null;
let _activeRun = null;     // { resolve, reject, onStatus } for the in-flight run
let _taskQueue = Promise.resolve();

function startWorker() {
    if (_worker) return;
    window.Aether.isPyodideLoading = true;
    window.Aether.pyodideReady = false;
    _worker = new Worker('js/pyodide-worker.js');
    _engineReady = new Promise((res, rej) => { _readyResolve = res; _readyReject = rej; });
    _worker.onmessage = (e) => {
        const msg = e.data;
        switch (msg.type) {
            case 'ready':
                window.Aether.pyodideReady = true;
                window.Aether.isPyodideLoading = false;
                if (_readyResolve) { _readyResolve(); _readyResolve = null; }
                // Re-enable run buttons now that the engine is up
                document.querySelectorAll('.run-btn').forEach(btn => {
                    btn.disabled = false;
                    if (!btn.classList.contains('viz-generate-btn')) {
                        btn.textContent = 'Run Code';
                    }
                });
                break;
            case 'fatal':
                window.Aether.isPyodideLoading = false;
                if (_readyReject) { _readyReject(new Error(msg.message)); _readyReject = null; }
                break;
            case 'done':
                if (_activeRun) { const r = _activeRun; _activeRun = null; r.resolve(msg.result); }
                break;
            case 'error':
                if (_activeRun) { const r = _activeRun; _activeRun = null; r.reject(new Error(msg.message)); }
                break;
            case 'status':
                if (_activeRun && _activeRun.onStatus) _activeRun.onStatus(msg.message);
                break;
        }
    };
    _worker.onerror = (e) => {
        window.Aether.isPyodideLoading = false;
        if (_readyReject) { _readyReject(new Error('Python engine failed to load: ' + (e.message || 'worker error'))); _readyReject = null; }
    };
}

function enqueueWorkerTask(taskFn) {
    const next = _taskQueue.then(taskFn);
    _taskQueue = next.catch(() => {});
    return next;
}

async function runInWorker(steps, onStatus) {
    if (!_worker) startWorker();
    await _engineReady; // rethrows if the worker failed to load
    return await new Promise((resolve, reject) => {
        _activeRun = { resolve, reject, onStatus };
        _worker.postMessage({ type: 'run', id: Date.now(), steps });
    });
}

function cancelActiveRun() {
    if (!_worker) return false;
    const old = _activeRun;
    _activeRun = null;
    _worker.terminate();
    _worker = null;
    startWorker(); // respawn immediately; pyodide reloads in the background
    if (old) old.reject(new Error('Cancelled'));
    return true;
}

// Track which Generate buttons currently have a run in flight, so a second
// click on the same button means "Cancel" instead of a duplicate run.
const runningVizCards = new WeakMap();

document.addEventListener('DOMContentLoaded', () => {
    startWorker();
});
```

Note: `id: Date.now()` is fine on the main thread (this is browser JS, not the workflow sandbox); the worker echoes it back for tracing. Only one run is in flight at a time, so dispatch is by `_activeRun`, not by `id`.

- [ ] **Step 2: Rewire `window.runDemo`**

Replace the body of `window.runDemo` (the function currently spanning old lines 236–318) with:

```js
    window.runDemo = async (runBtn, editor, output) => {
        output.classList.remove('hidden');
        output.classList.remove('error');
        output.textContent = 'Queued...';
        runBtn.disabled = true;

        return enqueueWorkerTask(async () => {
            output.textContent = 'Preparing environment...';
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

                const steps = [{ code: codeToRun, tolerant: false }];
                // Many Aristotle demos define `def main()` guarded by
                // `if __name__ == "__main__":` which does not run under Pyodide.
                // Detect that pattern and call main() explicitly.
                const hasMain = /\bdef main\s*\(/.test(editor.value);
                const hasGuard = /if\s+__name__\s*==\s*['"]__name__['"]/.test(editor.value);
                if (hasMain && hasGuard) {
                    steps.push({ code: 'main()', tolerant: true });
                }

                output.textContent = 'Running...';
                const { result, stdout } = await runInWorker(steps);
                let text = stdout;
                if (result !== undefined && result !== null) {
                    text += result + '\n';
                }
                output.textContent = text || 'Done. (No output)';
            } catch (err) {
                output.classList.add('error');
                output.textContent = err.toString();
            } finally {
                runBtn.disabled = false;
            }
        });
    };
```

- [ ] **Step 3: Update the run-button state check in `renderInteractiveDemos`**

In `renderInteractiveDemos`, replace the old `if (!window.Aether.pyodideInstance) {` block with:

```js
                if (!window.Aether.pyodideReady) {
                    runBtn.disabled = true;
                    runBtn.textContent = 'Loading Engine...';
                } else {
                    runBtn.textContent = 'Run Code';
                }
```

- [ ] **Step 4: Rewire `window.runVisualization` with warning + Cancel**

Replace the body of `window.runVisualization` (old lines 414–736) with the version below. The transforms and rendering are preserved from the current implementation; only the execution path changes and the 45s warning/Cancel is added.

```js
    window.runVisualization = async function(code, outputContainer, buttonEl, description) {
        if (!window.Aether.pyodideReady) {
            outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted);">Engine still loading — will generate automatically when ready.</div>';
            if (buttonEl) buttonEl.disabled = true;
            return;
        }

        // A second click on the same Generate button while a run is in flight
        // means Cancel.
        if (buttonEl && runningVizCards.has(buttonEl)) {
            runningVizCards.get(buttonEl).cancel();
            return;
        }

        const runEntry = { cancel: () => cancelActiveRun() };
        if (buttonEl) runningVizCards.set(buttonEl, runEntry);

        if (buttonEl) {
            buttonEl.disabled = true;
            buttonEl.textContent = 'Queued...';
        }
        outputContainer.innerHTML = '<div class="viz-loading">Queued visualization...</div>';

        return enqueueWorkerTask(async () => {
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
                processedCode = processedCode.replace(
                    /plt\.subplots\(([^)]*)\)/g,
                    (match, args) => {
                        const hrMatch = args.match(/height_ratios\s*=\s*(\[[\d,\s]+\])/);
                        const wrMatch = args.match(/width_ratios\s*=\s*(\[[\d,\s]+\])/);
                        if (!hrMatch && !wrMatch) return match;
                        let cleanedArgs = args
                            .replace(/,\s*height_ratios\s*=\s*\[[\d,\s]+\]/g, '')
                            .replace(/,\s*width_ratios\s*=\s*\[[\d,\s]+\]/g, '')
                            .replace(/height_ratios\s*=\s*\[[\d,\s]+\]\s*,\s*/g, '')
                            .replace(/width_ratios\s*=\s*\[[\d,\s]+\]\s*,\s*/g, '');
                        const gsEntries = [];
                        if (hrMatch) gsEntries.push(`'height_ratios': ${hrMatch[1]}`);
                        if (wrMatch) gsEntries.push(`'width_ratios': ${wrMatch[1]}`);
                        const gsMatch = cleanedArgs.match(/gridspec_kw\s*=\s*\{([^}]*)\}/);
                        if (gsMatch) {
                            const existing = gsMatch[1].trim();
                            const merged = existing ? `${existing}, ${gsEntries.join(', ')}` : gsEntries.join(', ');
                            cleanedArgs = cleanedArgs.replace(
                                /gridspec_kw\s*=\s*\{[^}]*\}/,
                                `gridspec_kw={${merged}}`
                            );
                        } else {
                            cleanedArgs = cleanedArgs.trimEnd();
                            if (cleanedArgs && !cleanedArgs.endsWith(',')) cleanedArgs += ',';
                            cleanedArgs += ` gridspec_kw={${gsEntries.join(', ')}}`;
                        }
                        return `plt.subplots(${cleanedArgs})`;
                    }
                );
                // Fix unbraced \fracXY in LaTeX strings (e.g., \frac12 -> \frac{1}{2})
                processedCode = processedCode.replace(/\\frac([a-zA-Z0-9])([a-zA-Z0-9])/g, '\\frac{$1}{$2}');

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

                outputContainer.innerHTML = '<div class="viz-loading">Running visualization...</div>';

                // 45s warning: surface a Cancel control, keep running in the background
                let warned = false;
                const warnTimer = setTimeout(() => {
                    warned = true;
                    if (buttonEl) {
                        buttonEl.disabled = false;
                        buttonEl.textContent = 'Cancel';
                    }
                    outputContainer.innerHTML = '<div class="viz-loading">Still generating… click Cancel to stop (page stays usable).</div>';
                }, 45000);

                let result;
                try {
                    result = await runInWorker([{ code: fullCode, tolerant: false }], (status) => {
                        outputContainer.innerHTML = `<div class="viz-loading">${window.escapeHtml(status)}</div>`;
                    });
                } finally {
                    clearTimeout(warnTimer);
                }

                // result is either a base64 PNG string (matplotlib) or plotly HTML
                if (isPlotly) {
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
                                const allImgs = document.querySelectorAll('.gallery-img-container img');
                                pkg._vizImages = Array.from(allImgs).map((i, idx) => ({
                                    data: i.src,
                                    name: i.closest('.viz-container')?.querySelector('.code-title')?.textContent || `Visualization ${idx + 1}`
                                }));
                                window.Aether.currentPackage = pkg;
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
                if (String(err && err.message || err) === 'Cancelled') {
                    outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted); padding: 12px 0;">Cancelled — click Generate to run again.</div>';
                } else {
                    outputContainer.innerHTML = `<pre class="code-output error">${window.escapeHtml(String(err && err.message || err))}</pre>`;
                }
            } finally {
                if (buttonEl) {
                    buttonEl.disabled = false;
                    buttonEl.textContent = 'Generate';
                    runningVizCards.delete(buttonEl);
                }
            }
        });
    };
```

- [ ] **Step 5: Verify**

Run: `node --check Packages/js/pyodide-runner.js`
Expected: no output.

Run: `grep -n "pyodideInstance\|runPythonAsync\|loadPyodide" Packages/js/pyodide-runner.js`
Expected: no matches (all Python execution now goes through `runInWorker`).

Run: `grep -n "window.runVisualization\|window.runDemo\|window.renderInteractiveDemos\|buildLocalModuleCode\|buildAlgorithmStubs\|extractFutureImports\|startWorker\|runInWorker\|cancelActiveRun\|runningVizCards" Packages/js/pyodide-runner.js | head -30`
Expected: each name defined exactly once.

- [ ] **Step 6: Sync and commit**

```bash
rsync -a Packages/js/ docs/js/
git add Packages/js/pyodide-runner.js docs/js/pyodide-runner.js
git commit -m "feat(viz): run pyodide in a web worker; add 45s warning + Cancel"
```

---

### Task 4: Swap the engine flag in `packages.js`

**Files:**
- Modify: `Packages/js/packages.js:824`
- Sync: `docs/js/packages.js`

**Interfaces:**
- Consumes: `window.Aether.pyodideReady` (Task 1).
- Produces: nothing new.

- [ ] **Step 1: Swap the flag**

In `Packages/js/packages.js`, replace:

```js
                if (!window.Aether.pyodideInstance) {
```

with:

```js
                if (!window.Aether.pyodideReady) {
```

- [ ] **Step 2: Verify**

Run: `node --check Packages/js/packages.js`
Expected: no output.

Run: `grep -rn "pyodideInstance" Packages/`
Expected: no matches anywhere in `Packages/`.

- [ ] **Step 3: Sync and commit**

```bash
rsync -a Packages/js/ docs/js/
git add Packages/js/packages.js docs/js/packages.js
git commit -m "feat(viz): reference pyodideReady flag in package renderer"
```

---

### Task 5: Sync, smoke-test, commit, push

**Files:**
- Sync: whole `Packages/` → `docs/` via the pipeline's canonical command.

**Interfaces:**
- Consumes: all prior tasks.

- [ ] **Step 1: Rebuild the package index and sync**

```bash
cd /home/raver1975/lean/Packages && python3 update_index.py && cd /home/raver1975/lean
rsync -a --delete Packages/ docs/
```

If `update_index.py` produces a large/undesired diff (package data unchanged), skip it and sync only the frontend files:

```bash
rsync -a Packages/js/ docs/js/
rsync -a Packages/index.html docs/index.html
```

- [ ] **Step 2: Verify the sync**

Run: `diff -q Packages/js/pyodide-worker.js docs/js/pyodide-worker.js && diff -q Packages/js/pyodide-runner.js docs/js/pyodide-runner.js && diff -q Packages/js/packages.js docs/js/packages.js && diff -q Packages/js/state.js docs/js/state.js && diff -q Packages/index.html docs/index.html`
Expected: no output (files identical).

- [ ] **Step 3: Browser smoke test (manual — user)**

Serve `Packages/` locally and open a package page with visualizations:

```bash
cd /home/raver1975/lean/Packages && python3 -m http.server 8090
```

Open `http://localhost:8090/<a-package-with-viz>.json` (clean-path routing maps `/slug` to the JSON). Confirm:
1. Page loads; scroll and tab-switching stay responsive while vizzes generate.
2. A slow viz (e.g. `cyclic_cubic_fork_fork_pinning__fork_in_the_abelia`) shows "Still generating… click Cancel" after ~45s; the page is still interactive.
3. Clicking **Cancel** stops the run and resets the button to Generate.
4. Plotly, base64 PNG, and SVG output paths still render.
5. An Interactive Python demo ("Run Code") still executes and prints output.

- [ ] **Step 4: Commit and push**

```bash
git add -A
git commit -m "chore(viz): sync pyodide worker changes to docs/"
git push
```

---

## Self-Review Notes

- **Spec coverage:** worker creation (Task 2), orchestrator + timeout/Cancel (Task 3), flag swap (Tasks 1 & 4), index.html script removal (Task 1), deploy sync (Task 5) — all spec sections covered.
- **Type consistency:** `runInWorker(steps, onStatus)` is defined once (Task 3) and consumed in the same file; `runningVizCards` is defined and used only in Task 3; `pyodideReady` is produced in Task 1 and consumed in Tasks 3/4. The worker protocol types match between Tasks 2 and 3.
- **Placeholder scan:** every code step contains full, runnable code; verification steps name exact commands and expected outputs.
