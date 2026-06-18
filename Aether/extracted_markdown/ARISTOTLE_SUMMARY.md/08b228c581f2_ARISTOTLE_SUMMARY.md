# Summary of changes for run af159029-fbd2-4f91-9cf6-c371a6e8bd11
Added a new self-contained Lean module `Cryptography/CollatzPreimageStructure.lean` (in the `Catalog` package) that extends the existing `Cryptography/CollatzOWF.lean` development of Collatz-based one-way functions. It builds cleanly and contains **zero `sorry`s on all results** (verified via `lake build` and `#print axioms` — only the standard `propext`, `Classical.choice`, `Quot.sound` are used).

Theorems proved (all complete):
1. `preimage_mem_pair` — every one-step Collatz preimage of `n` is one of two explicit values `2*n` or `(n-1)/3`.
2. `preimage_ncard_le_two` — the sharp upper bound: any value has at most two one-step preimages. This is the missing complement to the catalog's lower bound `at_least_one_preimage`.
3. `preimage_branching` — combining the two bounds, the preimage count is exactly 1 or 2 (the rigorous form of the "2-to-1 on average" heuristic).
4. `preimage_zero_ncard` — boundary case: `0` has exactly one preimage.
5. `iterate_collision` / `iterate_not_injective` — unconditional collision: `T^a(1) = T^a(8)` for all `a ≥ 1`, so the iterated map is never injective (no compression hypothesis needed, unlike the catalog's pigeonhole result).
6. `hash_not_collision_resistant` — the iterated Collatz hash is provably NOT collision resistant.

Honest correction to the source concept: the originating idea conjectured a *collision-resistant* hash from iterated Collatz maps; theorem 6 shows this is false, so the defensible cryptographic claim is one-wayness (hardness of inversion), not collision freedom. This is documented in the module docstring.

Each theorem carries a brief proof-sketch comment in the requested `-- !-- ... -- !--` form.

Also added `Cryptography/FUTURE_DIRECTIONS.md` with five falsifiable, narrative research directions (exact preimage-count residue criterion, the `2^d` preimage-tree cardinality law, a formal one-wayness inversion-cost lower bound, a provably injective keyed even-branch variant, and collision abundance), each with a "key insight" and a "Why now?" justification, all building directly on the proved theorems and the catalog foundations.