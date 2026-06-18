# Summary of changes for run d9e67ec8-c39d-49f3-b314-dfbb062808ab
Created `Catalog/Novelty/InfiniteChess/Basic.lean` — a fully formalized theory of pursuit-evasion on the infinite integer grid ℤ × ℤ, with **7 proved theorems and 0 sorries**.

### Main Results (5 non-trivial theorems + 2 structural helpers)

1. **`totalThreat_finite`**: Finitely many pieces with finite threat ranges cover only finitely many squares. (Finite union of finite sets is finite.)

2. **`infinite_safe_squares`**: The set of safe (unthreatened) squares is always infinite. (Complement of finite in infinite is infinite — the foundational escape theorem.)

3. **`king_path_exists`**: Any two squares on ℤ × ℤ are connected by a king path (Chebyshev-adjacent moves). Proved via horizontal/vertical decomposition with integer induction.

4. **`king_escape_exists`**: A king can always reach a safe square from any starting position, given finitely many pieces with finite threat ranges. Combines theorems 2 and 3.

5. **`rook_finite_no_domination`**: No finite set of rook-type pieces (threatening entire rows/columns) can dominate ℤ × ℤ. Uses a constructive witness: pick coordinates exceeding the sum of absolute values of all piece coordinates.

Plus `KingPath.trans` (transitivity), `king_path_horizontal`, and `king_path_vertical` as structural helpers.

### PEGB Coverage
Each major theorem includes Proof (complete Lean 4), Example, Generalization direction, and Boundary case documentation in the docstrings.

### Infrastructure
- Added `Novelty` lean_lib to `lakefile.toml` with glob `Catalog.Novelty.InfiniteChess.+`
- File builds cleanly with no warnings and no sorries
- FUTURE DIRECTIONS block lists 5 falsifiable conjectures for follow-up work