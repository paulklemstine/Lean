# Summary of changes for run 10bd21be-1383-44c7-98ac-a36fdce20f6a
## Completed: Tropical Canonical Forms Induce Karchmer–Wigderson Protocols

### Lean file: `Catalog/Bridges/TropicalKW.lean`

A self-contained, fully proven (0 sorries) Lean 4 file establishing a bridge between tropical/max-plus piecewise-affine maps and Karchmer–Wigderson-style communication protocols.

### Theorem Declarations

1. **`separating_witness_exists`** — If the pointwise maximum of affine pieces at `y` exceeds that at `x`, some piece separates. *Status: proved.* Key insight: the argmax piece at `y` must beat all pieces at `x`.

2. **`tropicalKWProtocol_valid`** — The linear-scan protocol correctly outputs a separating piece index whenever the tropical evaluations differ. *Status: proved.* Key insight: combines witness existence with inductive correctness of the linear scan.

3. **`tropicalKWProtocol_run_mem_leafLabels`** — Protocol output is always a valid leaf label. *Status: proved.* Structural induction on the tree.

4. **`tropicalLinearProtocol_depth`** — Protocol depth ≤ number of affine pieces. *Status: proved.* Direct from the recursive depth bound `mkLinearTree_depth`.

5. **`tropical_kw_bridge`** (main bridge theorem) — For any nonempty list of tropical affine pieces, there exists a protocol tree that is valid, has depth ≤ piece count, and whose outputs are always leaf labels. *Status: proved.* Packages theorems 1–4.

### Supporting lemmas (all proved)
- `piece_le_tropMaxEval` — each piece is ≤ the max
- `tropMaxEval_eq_some_piece` — the max equals some piece's value
- `mkLinearTree_depth` — recursive depth bound
- `mkLinearTree_finds_separator` — the linear scan finds a separator if one exists
- `TropKWTree.run_mem_leafLabels` — tree output is in leaf labels

### Axiom verification
All theorems depend only on `propext`, `Classical.choice`, and `Quot.sound` — standard Lean axioms.

### Future directions: `FUTURE_DIRECTIONS.md`
Five falsifiable research conjectures extending this work:
1. Logarithmic depth via balanced splitting (⌈log₂ n⌉ bound)
2. Invariance under canonical tropical reduction
3. Multivariate extension to ℝⁿ → ℝ tropical polynomials
4. Communication lower bounds via essential piece counting
5. Bridge to neural network verification via tropical rational forms