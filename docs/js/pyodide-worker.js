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
