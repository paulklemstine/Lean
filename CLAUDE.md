# Aether Project Instructions

## Tool discipline
- **Always set a `timeout` on `Bash` tool calls** (and on `subprocess.run` / `subprocess.check_*` in code). The default harness timeout is not always sufficient for long-running git, rsync, or build operations in this repository.
- Keep git operation timeouts generous (≥120 s for commits/pushes/merges that touch large catalogs).
- If a shell command can hang (e.g., waiting for input, network, or a lock), prefer a bounded `timeout` and report the failure rather than letting it stall.
- **Frontend changes**: The canonical source for frontend code (HTML, JS, CSS) is `Packages/`. Do NOT edit files in `docs/` directly, as they are regenerated and synchronized from the Catalog during Aether ticks.
