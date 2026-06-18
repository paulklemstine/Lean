# Summary of changes for run c980835f-9a48-4228-8bdd-503f650ad675
I formalized "Hyperbolic Number Theory: Arithmetic on the Poincaré Disk" as a self-contained, fully-verified Lean 4 file plus a research roadmap.

**New file:** `Catalog/Logic/HyperbolicDiskArithmetic.lean` (builds cleanly against Mathlib; verified with the project build).

It develops the algebra of the disk automorphisms `mob a z = (z - a)/(1 - conj a * z)` — the "hyperbolic translations" that generate the group action underlying the hyperbolic integers — and proves, with no `sorry` on any main result:

- `mob_key`: the fundamental defect identity `|1 - āz|² − |z − a|² = (1 − |a|²)(1 − |z|²)`, the engine for every positivity/distance fact.
- `mob_maps_disk`: disk automorphisms map the open unit disk into itself.
- `mob_left_inv`: `mob (-a)` is a left inverse of `mob a`, exhibiting the invertible group structure (hyperbolic addition).
- `mob_sub` and `mob_denom`: the difference and Hermitian-pairing cocycle identities.
- `pseudohyperbolic_invariant` (main theorem): the pseudohyperbolic distance `|z−w|²/|1−z̄w|²` is invariant under every disk automorphism — the Schwarz–Pick core, which is exactly what makes the hyperbolic "size" `|n|_H` a well-defined arithmetic invariant.
- `hyperbolicDist_invariant`: as a corollary, the genuine hyperbolic distance `d_H = 2·artanh(ρ)` is invariant, i.e. hyperbolic translations are isometries.

It also includes worked `example` blocks, simp lemmas (`mob_self`, `mob_zero_left`, `pdistSq_self`), a boundary-failure example showing the open-disk hypotheses are sharp, and one clearly-marked frontier generalization (`pseudohyperbolic_triangle`, the metric triangle inequality) left as `sorry` for the next cycle. Each theorem carries a brief proof sketch in the requested `-- !-- ... -- !--` format.

**`FUTURE_DIRECTIONS.md`** lists five falsifiable conjectures extending the work (closing the triangle-inequality sorry, orbit discreteness and counting, the non-associative Möbius "addition" loop, hyperbolic-zeta convergence with a geometric critical line, and a Schwarz–Pick contraction theorem), each with a "The key insight is…" sentence and a "Why now?" justification grounded in the lemmas already proven.

The grand original claims (a provable Riemann Hypothesis, an `R²/(2 log R)` prime asymptotic) are not established — those are speculative; the roadmap instead replaces them with the geometrically honest statements (exponential orbit growth, critical line from volume growth) that the proven invariance results actually support.