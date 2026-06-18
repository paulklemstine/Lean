# Summary of changes for run 037b361f-4bab-4a5b-874a-cdfd5f206496
I added a new, fully proved (zero `sorry`) Lean 4 development that deepens the project's existing Razborov–Rudich natural-proofs barrier work.

**New file:** `Speculative/AutoResearch/NaturalProofsHybrid.lean`

It builds on the catalog's `Speculative/AutoResearch/NaturalProofsBarrier.lean` (the quantitative distinguisher: large + useful ⇒ advantage ≥ δ) and `Computation/BarrierFramework.lean`/`Computation/CircuitBarriers.lean` (the barrier/algebrization skeletons), and extends them to the **hybrid (iterated-construction) setting** — the device that makes the barrier bite against real PRF/PRG constructions built by iterating an elementary step `g₀ → g₁ → ⋯ → g_m`.

STEP 1 — Theorem declarations (all `proved`, no `sorry` on any result):
1. `randomProb_le_one`, `pseudoProb_le_one`, `advantage_le_one` — the test probabilities and the distinguishing advantage are genuine probabilities (≤ 1).
2. `advantage_sub_le` — reverse-triangle stability: changing the ensemble changes the advantage by at most the change in pseudorandom mass.
3. `telescoping_abs_le` — telescoping triangle inequality for any rational sequence.
4. `exists_large_step` — pigeonhole core: a total endpoint gap ≥ δ across m steps forces one adjacent gap ≥ δ/m.
5. `hybrid_argument` — distinguishing the endpoints g₀, g_m with advantage ≥ δ forces some adjacent pair distinguished with advantage ≥ δ/m (Goldwasser–Micali–Yao reduction).
6. `natural_proofs_hybrid_barrier` (headline) — a large property useful against the end of an ideal-anchored construction distinguishes some single elementary step with advantage ≥ δ/m.
7. `hybrid_barrier_contradiction` — a natural property cannot be useful against a construction whose every step is (δ/m)-secure.
8. `hybrid_needs_nonconstant` (boundary case) — against a constant construction the barrier collapses (δ ≤ 0), so a genuine multi-step construction is indispensable.
Plus supporting lemmas (`pseudoProb_eq_zero_of_useful`, nonnegativity, `stepAdvantage_comm/self`).

STEP 2 — Completeness: every theorem compiles with a complete proof. The "best" theorem (`hybrid_argument`) is accompanied by a strengthening/generalization (`exists_large_step`, stated for arbitrary ℚ-sequences) and a boundary case (`hybrid_needs_nonconstant`).

**Verification:** the file builds cleanly via `lake build` (module `Speculative.AutoResearch.NaturalProofsHybrid`) with no errors, no warnings, and no remaining `sorry`/`admit`. `#print axioms` on the main theorems shows dependence only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

**Also added:** `Speculative/AutoResearch/FUTURE_DIRECTIONS.md` with five falsifiable research conjectures extending the work (tightness of the δ/m hybrid loss; the amplification/composition direction step-security ⇒ total-security; quantitative/Chebyshev largeness; algebrization of the hybrid argument; and a bridge to Karchmer–Wigderson communication-complexity lower bounds), each with a "key insight" and "Why now?" justification.

Proof sketches are included inline as `-- !-- ... -- !--` comment blocks, and the existing catalog results are cited by name throughout the docstrings. No existing files were modified or deleted.