# Summary of changes for run 47f07e0e-5716-4835-892a-bd2e6ba90c42
## Cellular Automata as Fixed-Point Varieties — Phase A research cycle complete

I ran the full scientific-team loop on the conjecture that an ECA's fixed-point variety dimension correlates with its Wolfram complexity class, and **refuted it** with fully proved Lean 4 theorems (0 sorries, kernel-admissible axioms only).

### Deliverables
- `Catalog/Shared/CellularAutomataVariety.lean` (main results)
- `Catalog/Bridges/CellularAutomataGardenBridge.lean` (cross-domain bridge)
- `FUTURE_DIRECTIONS.md` (5 bold, falsifiable conjectures, each with a "The key insight is…" and "Why now?")

### What was proved
Modelling each elementary CA rule as a global update map `caStep r` on `ZMod n → Bool` (a `GF(2)` state vector) and defining `fixedCard n r = |{s | caStep r s = s}|`:
- `rule110_fix_zero`: the Turing-complete Rule 110 has the **all-zero** configuration as its only fixed point on every cycle `n ≥ 1` (proved via a zero-propagation identity `R110 l false r = r` plus cyclic induction and `by_contra`).
- `rule204_fixedCard = 2^n` (identity rule, maximal variety), `rule0_fixedCard = 1`, `rule110_fixedCard = 1`, `rule51_fixedCard = 0`.
- `turing_complete_not_maximal`: Rule 110 (Class 4) has **strictly fewer** fixed points than the trivial identity Rule 204 (Class 2) — the opposite of the conjecture.
- `class4_eq_class1`: Rule 110 (Class 4) has the **same** fixed-point count as the trivial Rule 0 (Class 1).

Conclusion of the analysis: fixed-point "dimension" measures algebraic triviality (closeness to the identity / linearity), not computational complexity.

### Cross-domain bridge (mandate satisfied)
The bridge file combines the **Shared** domain (`Shared.CellularAutomataVariety`, this cycle) with the **Bridges** domain (`Bridges.GardenOfEden`), using `exists_garden_of_eden_iff_not_surjective` to prove that the maximal-variety identity rule is surjective (no Garden of Eden) while the minimal-variety Rule 0 is not (it has an explicit unreachable all-ones state). This reframes the refuted slogan as a true statement: maximal fixed-point variety ⇔ identity ⇔ reversible ⇔ Garden-of-Eden-free.

Each file contains `-- !-- Lab Notes -- !--` blocks documenting Hypothesis/Experiment/Analysis/Critique/Synthesis, including the computational data (fixed-point counts for rules 0/204/110/51/90/150/30 over n=1..8) that drove the refutation.

### Build note
The project's root `lakefile.toml` was missing `srcDir = "Catalog"`, so module paths did not resolve and a root build was impossible; I added that one line. Both new modules now build successfully in-project (verified via `lake build`). A pre-existing unrelated file (`Algebra/Jacobian/DruzkowskiTheory.lean`) imports a non-existent `Algebra.Jacobian.Defs`; it is untouched and not depended on by the new work.