# Summary of changes for run 9b25cd3c-a374-4b8d-b0c8-8f06382dea37
Delivered a new, fully formal core for the **Entropy-Bounded Computation (EBC)** framework.

**New Lean file:** `Catalog/Computation/EntropyBoundedComputation.lean` (module `Computation.EntropyBoundedComputation`). It defines `EBC.entropy S := logb 2 (Fintype.card S)` — the Shannon entropy in bits of the uniform distribution over a finite state space — and proves 7 theorems with **zero `sorry`** and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

1. `entropy_nonneg` — nonempty finite state spaces have nonnegative entropy.
2. `entropy_eq_zero_of_card_one` — a single-state machine stores no information.
3. `entropy_reversible_invariant` — bijective (reversible) computation preserves entropy.
4. `entropy_prod` — entropy is additive over independent product state spaces.
5. `entropy_le_of_surjective` — a deterministic surjective map cannot create entropy (data-processing / second-law inequality).
6. `landauer_erasure_pos` — erasing a state space with ≥ 2 states to one state has strictly positive entropy cost (Landauer's principle).
7. `landauer_erasure_eq` — the entropy released by erasure equals the source entropy and is nonnegative.

Each theorem carries a one–two sentence proof-sketch comment and a docstring. The work extends the existing `Computation/EntropyBridge.lean` (which only bounds cardinality via injective encodings) by promoting log-cardinality to a real-valued entropy functional with proven structural laws.

**`FUTURE_DIRECTIONS.md`** lists 5 falsifiable research conjectures extending the framework (exact entropy defect of arbitrary maps, additive cost along pipelines, a quantitative Landauer lower bound, the jump from uniform to general Shannon entropy via maximum-entropy, and reversible Bennett embeddings), each with a "key insight" and "Why now?" justification.

**Build fix:** the project's `lakefile.toml` was missing `srcDir = "Catalog"`, so no module name resolved and nothing built. I added that line; existing modules and the new file now build cleanly (`lake build Computation.EntropyBoundedComputation` succeeds with 0 sorries).