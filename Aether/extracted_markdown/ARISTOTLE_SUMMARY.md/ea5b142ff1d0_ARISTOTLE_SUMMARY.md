# Summary of changes for run 1d789fa6-f840-4e91-901b-4ac572fb41c0
This research cycle on **stable tropical curves and the moduli cone complex `M_{g,n}^trop`** delivers one new Lean 4 file plus the required notes.

## New files
- `Catalog/Tropical/StableCurveEdgeBounds.lean` — compiles cleanly (full elaboration via `lake env lean`), `sorry`-free on all results, and every main theorem depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`. It includes per-theorem `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) and one-line `-- !-- ... -- !--` proof sketches.
- `FUTURE_DIRECTIONS.md` — narrative with `## Synthesis`, `## Results Summary`, and 5 falsifiable research directions (each with a "key insight" and "Why now?").

## Theorem declarations (Step 1) and status
All under namespace `TropicalModuli.Stable.MarkedCombType`, built on a new `MarkedCombType` abstraction (vertices, bounded-edge count `E`, leg/marked-point count `n`, valence function, and the handshaking axiom `∑ deg = 2E + n`):
1. `handshake_lower` — stability `deg(v) ≥ 3` ⇒ `3V ≤ 2E + n` — proved — the arithmetic core.
2. `marked_edge_bound` — `|E| ≤ 3g − 3 + n` (dimension of the top cone of `M_{g,n}^trop`) — proved.
3. `edge_bound_unmarked` — `n = 0` case `|E| ≤ 3g − 3` (the originally targeted bound) — proved.
4. `handshake_eq_trivalent` / `trivalent_edge_eq` — trivalent types attain the bound with equality (maximal cones) — proved.
5. `stable_global_stability` / `stable_global_stability_pos` — local stability ⇒ global Deligne–Mumford stability `2g − 2 + n ≥ V ≥ 1` — proved.
6. `genus_ge_two_unmarked` — every nonempty unmarked stable tropical curve has `g ≥ 2` (boundary/critique result, via integer parity) — proved.
7. `genus_contract_nonloop` / `genus_contract_loop` — non-loop edge contraction preserves genus, loop contraction drops it by 1 (graded poset structure) — proved.
8. `theta` + `theta_trivalent` / `theta_genus` / `theta_attains_bound` — the theta graph as an explicit genus-2 trivalent witness attaining `|E| = 3g − 3` — proved.

## Catalog synthesis
This extends the catalog's `Catalog/Tropical/ModuliCompactification.lean` (`graphGenus`, `tree_genus_zero`, `genus_connected`), reusing its genus convention `g = E − V + 1` but moving from `SimpleGraph` — which cannot carry the multi-edges/loops of stable curves — to the lightweight `MarkedCombType` record. The key structural discovery is that the sharp dimension bound `|E| ≤ 3g − 3 + n` is *literally* the inequality `3V ≤ 2E + n`, i.e. handshaking + pointwise stability; everything else is linear arithmetic over ℤ (with one omega-only parity step forcing `g ≥ 2`).

The marked case generalizes the unmarked `|E| ≤ 3g − 3` to `|E| ≤ 3g − 3 + n`, exactly the program set out in the research direction.