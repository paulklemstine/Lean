# Summary of changes for run cc9ef2e1-1a0b-469f-93d4-6dc67006d7d6
## Tropical Cryptocurrency: Mining on the Min-Plus Semiring

I produced a new, self-contained Lean 4 file `Catalog/Tropical/TropicalMining.lean` formalizing the tropical hash `TSHA h m = min_i (m_i + h_i)` over the min-plus semiring and its two-key strengthening `TSHA2`, plus `FUTURE_DIRECTIONS.md` at the project root.

### Theorems proved (sorry = 0; verified to depend only on `propext`, `Classical.choice`, `Quot.sound`)
- `TSHA_le` / `TSHA_realized` — forward computation: the hash lower-bounds every coordinate term and is realized at an argmin (the single `O(k)` evaluation pass).
- `TSHA_lipschitz` — the hash is `1`-Lipschitz in the sup-norm (smoothness), via an inlined discrete contraction lemma `abs_inf'_sub_inf'_le_sup'`.
- `TSHA_tropical_additive` — `TSHA h (m ⊓ m') = TSHA h m ⊓ TSHA h m'`: min-plus additivity (the hash is a tropical linear functional).
- `TSHA_translation` — `TSHA h (m + c) = TSHA h m + c`: tropical scalar equivariance.
- `TSHA_collision_abundant` — the one-wayness obstruction: any slack (non-argmin) coordinate can be raised arbitrarily to give a distinct message with the same hash, so `TSHA` has unboundedly many preimages.
- `TSHA2_detects_collision` — two independent keys: a `TSHA`-collision created by raising a coordinate that is the strict argmin of the second key is detected by `TSHA2`.

### Catalog synthesis
The work extends the catalog's `Tropical/MinPlusAlgebra.lean` (the matrix-level min-plus theory: `tropMatVecMul`, `abs_inf_sub_inf_le_sup`, `tropMatMul_lipschitz`) from matrix products to the single-functional hash, and is framed through the requested local-to-global / sheaf lens: collision abundance is presented as the failure of a single local (argmin) generator to determine the global message, and `TSHA2` as a coarser cover that resolves more of that obstruction.

### Deliverable format
- `-- !--` proof-sketch blocks accompany each theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) appears in the file header.
- `FUTURE_DIRECTIONS.md` is a freeform narrative with a Synthesis, Results Summary, and 5 falsifiable research directions, each with a "The key insight is…" sentence and a "Why now?" justification (a slack-sheaf `H¹` obstruction class, exact preimage-fiber dimension counting, a probabilistic `1 − O(1/k)` collision bound, the shortest-path reduction, and an `r`-key stalk-separation injectivity threshold).

The file builds cleanly (`lake build Tropical.TropicalMining`) within the `Catalog` Lean project, with no remaining `sorry`/`admit`.

Note: the broader catalog has a pre-existing broken import (`Algebra.Jacobian.Defs` is referenced but the file is absent), so building all default targets fails independently of this work; the new module itself builds and verifies in isolation.