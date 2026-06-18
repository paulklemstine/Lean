# Summary of changes for run e6139773-b2f5-4cdb-bd4c-35c2f7956ee7
I produced a self-contained Lean 4 development formalizing the homological construction of topological quantum error-correcting (CSS) codes, plus a research roadmap.

**New files**
- `Speculative/TopologicalQuantumCodes.lean` — the deliverable, building cleanly against Mathlib with **zero `sorry`** and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
- `Speculative/FUTURE_DIRECTIONS.md` — five falsifiable research conjectures, each with a "The key insight is…" sentence and a "Why now?" justification.

**Mathematical content.** A length-three chain complex `C₂ →d₂ C₁ →d₁ C₀` over a field models a CSS code: `C₁` = physical qubits, `d₁`/`d₂` = Z-/X-stabilizer (boundary) maps, and the logical qubits are the first homology `H₁ = ker d₁ / im d₂` (`HomologyH1`). Theorems proved:

1. `css_valid_iff` — the CSS commutation condition `d₁ ∘ d₂ = 0` is equivalent to `im d₂ ⊆ ker d₁`, i.e. to well-definedness of homology.
2. `css_logical_dimension` (core) — the number of logical qubits satisfies `k + rank(d₁) + rank(d₂) = dim C₁`, i.e. `k = n − rank(d₁) − rank(d₂)`, proved from rank–nullity and the quotient rank formula.
3. `css_euler_characteristic` — the Euler characteristic of the chain complex equals that of its homology (a topological invariant), derived from the dimension formula.
4. `surface_code_logical_count` — the genus-`g` surface code (minimal cellulation, all `ZMod 2` boundary maps zero) encodes exactly `2g` logical qubits; the torus (`g=1`) gives the 2-qubit toric code (checked via an `example`).
5. `logical_operator_exists_iff` and `distance_realized_by_logical` — a nontrivial logical operator exists iff `dim H₁ > 0`.
6. `minimal_cellulation_weight_one` (boundary case) — the minimal cellulation, while optimal in qubit count, admits a weight-one logical operator (distance 1), showing that maximal `k` does not imply good distance and motivating finer lattices.

Each theorem carries a brief proof sketch in `-- !-- … -- !--` comments. The "distance = systole" claim and the `O(√g)` distance scaling for higher genus are deliberately recorded as conjectures in `FUTURE_DIRECTIONS.md` (Directions 1–3), together with hypergraph-product constant-rate codes (4) and a functorial/categorical organization of codes (5).

**Build/integration note.** The repository's active Lean package root (with Mathlib prebuilt) resolves library sources at the top level matching the lakefile globs, so the new `Speculative.TopologicalQuantumCodes` module was placed under `Speculative/` and verified to build there; building it explicitly reports success with no warnings.