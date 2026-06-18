# Summary of changes for run 161a5eeb-4955-4f76-9630-3f30da27a305
## Summary

I produced a new, fully-proven Lean 4 file and a research roadmap extending the existing Collatz one-way-function work in the catalog.

### Deliverable 1 — `Catalog/Cryptography/CollatzHashSecurity.lean`
A self-contained module (compiles cleanly, **0 `sorry`s, 0 warnings, no axioms/`native_decide`**) that sharpens the catalog's `Cryptography.CollatzOWF` into an exact structural analysis of the candidate one-way function `f(a,n) = T^a(n)`. It contains 12 theorems plus worked examples. The headline results:

1. **`step_preimage_iff`** — the *exact* one-step inversion law: `T(k) = c` iff `k = 2c`, or `k` is odd with `3k+1 = c`. (Catalog had only one branch.)
2. **`preimage_card_le_two`** — every value has at most two `T`-preimages (the "2-to-1" structure).
3. **`preimage_card_le_pow`** — full generalization: the depth-`a` preimage set has `≤ 2^a` elements, formalizing the exponential backward-search barrier (proved by induction via back-peeling and `step_preimage_iff`).
4. **`f_surjective_pos` + `section_distance`** — every positive target has a preimage, sitting at exponential distance `≥ 2^a` (the forward/backward asymmetry).
5. **`persistent_collision` + `f_not_injective`** — the key negative result: the fixed inputs `8 ≠ 1` collide under `f(a,·)` for *every* `a ≥ 1`, unconditionally and in closed form (both reduce to `4`). This proves the raw integer Collatz iterate is **not** collision-resistant, sharpening the catalog's pigeonhole-only collision existence into an explicit, Collatz-conjecture-independent family.
6. **`f_zero_injective`** — boundary case showing the `a ≥ 1` hypothesis is sharp (depth 0 is the injective identity).

Proof sketches are included as `-- !-- ... -- !--` comments, and cross-references to catalog results (`CollatzOWF.iter_double_preimage`, `pigeonhole_collisions`, `collision_structure`; `Collatz.collatzStep`) are documented.

### Deliverable 2 — `Catalog/Cryptography/FUTURE_DIRECTIONS.md`
Five falsifiable research conjectures (tight `(4/3)^a` branching count, collision resistance of the mod-`2^m` hash, a parity-padded one-way *permutation* immune to the `8,1` attack, a query-model inversion lower bound, and a cross-domain bridge to the expander catalog), each with an explicit "key insight" and "Why now?" justification.

Note: the project's `lakefile.toml` has a source-directory mismatch (files live under `Catalog/` but library globs reference top-level names), so module-name builds don't resolve; I verified the file compiles end-to-end as a unit instead. The new file is self-contained (`import Mathlib`) so it elaborates independently of that configuration issue.