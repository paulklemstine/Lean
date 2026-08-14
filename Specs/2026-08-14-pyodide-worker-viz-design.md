# Pyodide Web Worker — Non-Blocking Visualization Generation

**Date:** 2026-08-14
**Status:** Approved design (in spec review)
**Author:** Claude (with Paul Klemstine)

## Problem

Opening a package page that contains visualizations can freeze the browser tab.
Chrome eventually shows its "page is unresponsive — wait or kill" dialog, and
the rest of the package information cannot be browsed until the run finishes.
Example triggering URL: `https://alethean.org/cyclic_cubic_fork_fork_pinning__fork_in_the_abelia`

## Root cause

Three compounding problems, all confirmed by reading `Packages/js/`:

1. **Python runs on the browser's main thread.** `loadPyodide()` and every
   `runPythonAsync` call execute on the main thread (`pyodide-runner.js`).
   CPU-bound visualization code (matplotlib / numpy / plotly) blocks all UI:
   scrolling, tab switching, clicking.
2. **Visualizations auto-run on package load.** `renderVisualizations`
   (`packages.js`) calls `runViz()` automatically for every resolved viz, and
   this happens eagerly in `loadPackage` — before the Interactive tab is even
   opened. Heavy vizzes run serially, each freezing the tab.
3. **The existing 45 s "timeout" is cosmetic.** `enqueuePyodideTask` races a
   JS `setTimeout` against the Python run, but a JS timer cannot fire while
   Python is blocking the main thread. The timeout rejects the caller's
   promise, but Python keeps running and the page stays frozen.

A timeout-and-abort fix alone cannot work while Python shares the main thread;
the abort signal can never be delivered. Background execution is required.

## Goal

- The page must stay fully responsive while visualizations (and interactive
  Python demos) generate — the user can browse the rest of the package.
- Keep the current auto-run behavior: vizzes still generate automatically on
  load, but non-blockingly.
- Long-running visualizations surface a warning after 45 s with a Cancel
  control; runs keep going until done or cancelled (no auto-abort).
- Same rendered output as today: plotly HTML, base64 PNG, or inline SVG.

## Non-goals

- No change to what vizzes render or how they are wrapped.
- No auto-abort / resource cap.
- No change to the click-to-run Interactive Python demos' behavior beyond
  making them non-blocking too (they share the same engine).
- No change to the deploy pipeline.

## Architecture

Python execution moves into a dedicated Web Worker. The main thread keeps all
DOM work, the serialization queue, and all pure-string code transforms (they
do not require Pyodide).

```
┌───────────────────────────── Main thread ─────────────────────────────┐
│  pyodide-runner.js (orchestrator)                                      │
│   • create Worker                                                     │
│   • serialization queue (one run at a time)                           │
│   • wrap code (module inlining, matplotlib/plotly wrapper, fixes)     │
│   • 45 s warning → Cancel on Generate button                          │
│   • render result (plotly HTML / base64 img / SVG)                    │
│   • Cancel = terminate worker + respawn                               │
│        │  postMessage({id, steps})                                    │
│        ▼                                                              │
└───────────────┐                                        ┌──────────────┘
                │  postMessage({id, done|error, result}) │
                ▼                                        │
┌────────────────────────────────── Worker ─────────────────────────────┐
│  pyodide-worker.js                                                     │
│   • importScripts pyodide from CDN; loadPyodide() in worker            │
│   • per message: loadPackagesFromImports → run each step → return      │
│     result string (base64 PNG data URI, plotly HTML, or SVGS)          │
│   • missing-module retry loop lives here                               │
└────────────────────────────────────────────────────────────────────────┘
```

### Message protocol

Main → Worker:
- `{ type: 'run', id, steps: string[] }` — run `steps` sequentially in one
  Python environment; return combined stdout and the last step's result.
  (Demos may need `[mainCode, 'main()']`; vizzes always one step.)

Worker → Main:
- `{ type: 'ready' }` — pyodide finished loading (sets `pyodideReady`).
- `{ type: 'done', id, result, stdout }` — run completed; `result` is a
  string (plotly HTML or base64/SVG data).
- `{ type: 'error', id, message }` — run failed.
- `{ type: 'status', id, message }` — optional progress (package installs).

### Timeout and Cancel

- A 45 s wall-clock timer runs on the (free) main thread per viz run.
- On fire: the card's Generate button changes to **Cancel** and the spinner
  text becomes "Still generating…".
- Cancel: `worker.terminate()`, mark engine not-ready, spawn a fresh worker,
  reject the in-flight run (card shows "Cancelled — Run again"). Runs queued
  behind it await the fresh worker's `ready` before posting.
- The Generate button resets to its normal state after a run ends or is
  cancelled.

### Engine readiness

`window.Aether.pyodideInstance` is replaced by `window.Aether.pyodideReady`
(a boolean set when the worker posts `ready`). The existing "engine loading,
will generate automatically" poll in `packages.js` keeps working against the
new flag.

## Files

| File | Change |
|------|--------|
| `Packages/js/pyodide-worker.js` | **New.** Pyodide executor (load, run steps, retry missing modules, report). |
| `Packages/js/pyodide-runner.js` | Refactor to orchestrator. Keep all transforms and DOM; replace direct pyodide calls with messages; add warning/Cancel. |
| `Packages/js/state.js` | `pyodideInstance` → `pyodideReady` flag. |
| `Packages/js/packages.js` | Line ~824 engine check swaps to `pyodideReady`. |
| `Packages/index.html` | Remove main-thread pyodide `<script>` (only the worker needs it now). |

## Edge cases

- **Worker fails to load pyodide** → `error` with a retry affordance; page
  remains interactive.
- **Run queued behind a cancelled run** → waits for fresh worker `ready`.
- **`main()` demo auto-call** → second step in the same message; queue
  semantics preserved.
- **stdout capture** → moves to the worker; returned with the `done` message.
- **No cross-origin isolation** → SharedArrayBuffer is not required; Cancel
  uses worker termination (pyodide reloads from browser cache, ~seconds).

## Verification

1. `node --check` on all edited/new JS files.
2. Serve `Packages/` locally (same-origin), open a package page with
   visualizations, confirm: page scrolls/tabs stay responsive while a viz
   generates; 45 s warning + Cancel appear on a slow viz; Cancel recovers;
   plotly/base64/SVG render paths still work.
3. User tests the live site after deploy.

## Deployment

`Packages/` is the source of truth. After edits:
1. `python3 Packages/update_index.py` (from `Packages/`).
2. `rsync -a --delete Packages/ docs/`.
3. Normal firebase deploy of `docs/`.
