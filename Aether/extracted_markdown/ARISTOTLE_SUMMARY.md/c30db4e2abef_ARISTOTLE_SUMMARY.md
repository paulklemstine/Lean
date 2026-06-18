# Summary of changes for run 0ec44057-9d17-4a44-a713-a09b0029b8dc
## Cycle complete — Unique Games, the `1/k` soundness floor, and the MAX-CUT bridge

This was a cold start: the referenced file did not exist, so I created the full development from scratch.

### Deliverables
- **`Cryptography/UniqueGamesMaxCut.lean`** — a self-contained Lean 4 file (≈240 lines, `import Mathlib`) that builds cleanly with **zero `sorry`** on every theorem and depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`).
- **`FUTURE_DIRECTIONS.md`** — with the required `## Synthesis`, `## Results Summary`, and 5 falsifiable `## Research Directions` (each with a "key insight" and "Why now?").

### Theorems (all proved, no sorry)
1. `edge_sat_card` — exactly `k` of the `k²` label pairs satisfy a permutation constraint (the per-edge `1/k` probability).
2. `edge_constraint_card` — the technical core: an explicit coordinate-freeing bijection `Fin k × {sat assignments} ≃ (V → Fin k)` shows a no-self-loop constraint is satisfied by exactly a `1/k` fraction of all assignments (`k·#sat = k^{|V|}`).
3. `k_mul_sum_satCount` — the exact double-count `k·Σ_a satCount = |G|·k^{|V|}` (list induction).
4. `exists_assignment_sat_ge` — soundness floor (integer form), by pigeonhole on the exact double-count.
5. `exists_value_ge_inv_k` — soundness floor (value form): every no-self-loop game has `value ≥ 1/k`.
6. `maxCut_sat_iff_cut` — the MAX-CUT bridge: a swap-constraint edge is satisfied iff its endpoints differ.
7. `maxCut_exists_cut_half` — the classical MAX-CUT `1/2` bound, recovered as the `k = 2` case of the floor.
8. `trivialGame_perfect` — completeness witness (`value = 1`) for equality CSPs.

The file pins the two endpoints (completeness `1`, soundness floor `1/k`) between which the Unique Games Conjecture hardness gap lives, and includes per-theorem `-- !-- Lab Notebook -- !--` blocks (Hypothesis/Result/Insight/Failure analysis) plus `-- !--` proof sketches.

### Notes
- The new module lives at `Cryptography/UniqueGamesMaxCut.lean`, matching the lakefile glob `Cryptography.+`, and compiles as part of the project build.
- The structural insight that emerged: the entire soundness floor reduces to one counting bijection plus pigeonhole (no probability theory needed, since the expectation is computed exactly), and the MAX-CUT `1/2` bound is literally the `1/k` floor at `k = 2`. `FUTURE_DIRECTIONS.md` records this and seeds the next cycle (concentration/tightness, SDP integrality gap, Goemans–Williamson rounding, parallel repetition, dictatorship tests).