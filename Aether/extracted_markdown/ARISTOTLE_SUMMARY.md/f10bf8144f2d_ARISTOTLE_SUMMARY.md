# Summary of changes for run 7ed910b1-5a83-4c67-a803-c4b5b8c3a0c5
## What was delivered

**New Lean file:** `Catalog/Pythagorean/OrderPreservingTree.lean` — a self-contained, `sorry`-free development that extends the existing `Pythagorean/Core.lean` (namespace `PythagoreanThermo`, the Berggren tree of primitive Pythagorean triples). It resolves the cycle's research target — *"construct an order-preserving map relating the tree structure to a linear order"* — by identifying the tree's natural **ancestor order** with the suffix order `<:+` on Berggren paths and proving it embeds into the integers via geometric invariants.

**Theorems proved (0 sorry on all results; axioms confined to the allowed set `propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler`):**
- `pathTriple_append` — the Berggren matrix action factors along path concatenation (`pathTriple (pre ++ σ) = pathMatrix pre • pathTriple σ`).
- `perim_step_lt`, `hyp_le_append`, `perim_le_append` — single-step and chain monotonicity of the perimeter and hypotenuse.
- `hyp_lt_of_proper_suffix`, `perim_lt_of_proper_suffix` — the two headline **order-preserving maps**: hypotenuse and perimeter are strictly monotone on the ancestor order.
- `tree_order_embedding` — the pair `(hyp, perim)` is an order embedding of the ancestor order into `ℤ × ℤ` (the conceptual unifier).
- `hyp_ne_of_proper_suffix` — a single invariant already separates a node from all of its proper ancestors/descendants.

Each result carries a `-- !-- ... -- !--` proof-sketch comment, and the file opens with a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis — including the documented negative result that individual legs are *not* per-step monotone, forcing the use of symmetric invariants). The work builds on and cites Core lemmas (`hyp_strictly_increasing`, `pathTriple_pos`, `pathTriple_pythagorean`, `pathMatrix`) rather than reproving them.

**`Catalog/Pythagorean/FUTURE_DIRECTIONS.md`** — a narrative synthesis, a results-summary table, and 5 falsifiable research directions (upgrade to a Mathlib `OrderEmbedding`; a logarithmic ordinal-scale order-isomorphism via the spectral constant `3+2√2`; monotonicity of the full invariant lattice incl. the inradius `a+b−c`; decidable comparability and an antichain census; and a ζ-function/Dirichlet-series comparison bridge). Each includes a "The key insight is..." sentence and a "Why now?" justification.

**Build fix (necessary):** the project's `lakefile.toml` was missing `srcDir = "Catalog"`, so modules such as `Pythagorean.Core` did not resolve to their files under `Catalog/Pythagorean/` and the project did not compile. I added that one line; the project and the new module now build cleanly.

Verification: `lean_build` of `Pythagorean.OrderPreservingTree` succeeds with no warnings, a `sorry` grep returns zero, and `#print axioms` on every main theorem shows only allowed axioms.