# Suggested Commands

## Build
- `lake build Catalog` — Build the entire Catalog library
- `lake build <LibName>` — Build a specific library target (e.g., `lake build EML`, `lake build Pythagorean`)

## Development
- `lake env printPaths` — Show Lean environment paths
- `lake exe cache get` — Download cached oleans from Mathlib CI
- `lake update` — Update dependencies

## Testing/Verification
- Lean 4 projects typically don't have a separate test suite — correctness is verified by the type checker
- `lake build` serves as both compilation and verification
- `lake check` — Check for errors without building

## Formatting/Linting
- `lake fmt` — Format Lean source files using leanformat
- No separate linter; Lean's type checker catches most issues

## Git
- Standard git commands: `git status`, `git add`, `git commit`, `git push`
- Main branch: `master`

## System Utilities
- `ls`, `cat`, `grep`, `find` — standard Linux utilities
- `wc -l` — count lines
- All standard Unix utilities available on Linux/WSL2