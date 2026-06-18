# Summary of changes for run 50918116-434e-4ceb-b842-1c64b39c1f20
Extended the proof-theoretic ordinal-analysis framework with a new, fully verified Lean file and a research roadmap.

**New file** `Pythagorean/ProofTheoreticOrdinalsLattice.lean` (builds cleanly, zero `sorry`, only standard axioms `propext`/`Classical.choice`/`Quot.sound`). It is self-contained: because the existing `Catalog/Pythagorean/ProofTheoreticOrdinals.lean` is a reference module outside the build's search path, the minimal core (the `OrdinalTheory` structure, `pto`, `ofOrdinal`, `join`, `depthDist`, `pto_monotone`) is reproduced and all new results build on it. Each theorem carries a 1–2 sentence proof sketch in `-- !-- ... -- !--` blocks, and there are example blocks.

Main new theorems:
- `provablyWO_subset_total` / `le_total_theory` — the inclusion order on theories is **total** (downward-closed ordinal sets are nested); the space of theories is a chain. This sharpens the catalog's observation that `pto` is not an order embedding.
- `pto_meet_eq_min` (with the recovered `pto_join_eq_max`) — `pto` is a **lattice homomorphism** to the ordinals, after defining the meet (intersection) of theories and its universal property (`meet_le_left/right`, `le_meet`).
- `depthDist_chain_additive` — along a chain `T₁ ≤ T₂ ≤ T₃`, the depth metric is **exactly additive**, not just sub-additive (resolves Future Direction 2 in the strong form); `depthDist_directed_triangle` is the corollary.
- `depthDist_triangle_general_false` — a proven **counterexample**: with PTOs ω+1, ω, 0 the unconditional triangle inequality fails because `1 + ω = ω`, so `depthDist` is a directed quasi-metric, not a pseudometric. Supported by computed PTOs (`pto_ofOrdinal_succ`, `pto_ofOrdinal_zero`, `pto_ofOrdinal_omega0`).
- `pto_constant_on_interval` — the fibers of the PTO map are **order-convex** intervals (resolves Future Direction 3).

A notable discovery: while exploring the metric geometry, the originally conjectured unconditional triangle inequality turned out to be false (the directed/chain version holds as exact equality), which is captured by the counterexample theorem.

**`FUTURE_DIRECTIONS.md`** gives five testable, falsifiable conjectures (LinearOrder/complete-lattice quotient by PTO-equivalence; a Hessenberg-natural-sum pseudometric that repairs the triangle inequality; the `ONote` bridge below ε₀; fast-growing-hierarchy witnesses of PTO; and an isometric invariant on the PTO-quotient), each with a "The key insight is..." sentence and a "Why now?" justification, building on the theorems just proved.