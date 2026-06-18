# Summary of changes for run b6df1f8c-c1fc-489c-8703-948b751456f5
Created a new, fully verified Lean 4 file `Cryptography/UniqueGamesMaxCut.lean` formalizing the combinatorial core of unique two-prover label-cover games over the Boolean alphabet `ZMod 2`, MAX-CUT, and the canonical SDP/integrality gap. The referenced file did not exist (cold start), so it was built from first principles, self-contained over `import Mathlib`. It compiles cleanly as module `Cryptography.UniqueGamesMaxCut` with **0 sorries** and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Key idea: a unique (permutation) constraint over a 2-element alphabet is one of exactly two bijections, so every constraint collapses to a `ℤ/2`-affine equation `x i + x j = b`; MAX-CUT is the all-`b = 1` fragment.

Theorems proved (all complete):
- `value_flipAll` — the value is invariant under the global `ℤ/2` gauge symmetry (flip every vertex).
- `selfLoop_unsat` — a "must differ" self-loop is never satisfiable.
- `two_mul_card_sat` — exactly half of all `2ⁿ` assignments satisfy any binary constraint, proved via a fixed-point-free single-coordinate involution.
- `two_mul_sum_value` — the averaging identity `2·Σ value = m·2ⁿ`.
- `exists_half` — the unconditional factor-2 bound: every instance with distinct endpoints admits an assignment satisfying ≥ half the constraints (the classical `|E|/2` cut for MAX-CUT).
- `triangle_gap` — the triangle (smallest odd cycle) has optimum exactly `2 < 3 = m`, the canonical integrality gap, tightly matching the half-bound's `⌈3/2⌉ = 2`.

The single `ℤ/2` involution `Function.update x i (x i + 1)` is the unifying engine behind both the gauge symmetry and the half-count. The file includes the required `-- !-- ... -- !--` proof-sketch comments and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis), plus catalog synthesis notes linking to the existing `Cryptography/CutCryptography.lean` material.

Also added `FUTURE_DIRECTIONS.md` with a synthesis, a results summary table, and 5 falsifiable research directions (odd-cycle frustration index, tightness rigidity of the half-bound, a `ℤ/p` generalization with a `1−1/p` bound, the explicit triangle SDP relaxation value, and a gauge-quotient cohomological satisfiability dichotomy), each with a "The key insight is…" sentence and a "Why now?" justification.