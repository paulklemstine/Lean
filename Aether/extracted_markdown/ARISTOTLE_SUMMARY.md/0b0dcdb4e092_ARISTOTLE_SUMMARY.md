# Summary of changes for run e0ba59a9-12b4-471b-90b6-085549da3e70
Completed a new research cycle extending the Hodge–Laplacian message-passing (spectral depth threshold) program.

**New Lean file:** `Speculative/AutoResearch/HodgeMessagePassingDynamics.lean` (self-contained, `import Mathlib` only, matching the convention of the other AutoResearch Hodge files). It re-states the four supporting catalog facts it builds on (`mpStep`, `mpStep_iterate_fixes_harmonic`, `quadform_iterate_bound`, `spectral_depth_threshold`) and then proves eight new theorems, all `sorry`-free and depending only on the standard axioms `propext, Classical.choice, Quot.sound` (verified via `#print axioms`):

- `mpStep_add`, `mpStep_smul`, `mpStep_sub` — the message-passing layer is a linear operator.
- `mpStep_iterate_add`, `mpStep_iterate_sub` — its depth-`k` iterate is linear.
- `hodge_decomposition_dynamics` — the Hodge decomposition flow: for harmonic `h`, `(mpStep)^[k](h+r) = h + (mpStep)^[k] r` (the harmonic/cohomological part is frozen, the residual evolves independently).
- `oversmoothing_limit` — oversmoothing as convergence to the harmonic projection: under a residual contraction `ρ < 1`, every signal is driven within any `ε` of its harmonic component in finitely many layers.
- `trajectory_stability` — any two input trajectories converge with geometric rate `ρ^k`.

The conceptual upshot, recorded in the in-file Lab Notebook (`-- !-- Lab Notebook -- !--`): oversmoothing is not a defect but the exact statement of a discrete Hodge decomposition for the message-passing semigroup — its fixed set is the harmonic kernel and the complement is uniformly contracted. Each theorem carries a brief `!--`-marked proof sketch.

**FUTURE_DIRECTIONS.md** (`Speculative/AutoResearch/FUTURE_DIRECTIONS.md`): a narrative synthesis, results summary, and five falsifiable conjectures (explicit depth-rate inversion; a two-sided spectral sandwich; heat-semigroup `e^{-tL}` consistency; residual connections provably defeating oversmoothing; and the cross-domain capstone lifting to the full Hodge Laplacian so that deep simplicial networks compute cohomology, fusing with the catalog's `HodgeBettiRank` / `HodgeFullDecomposition` results). Each direction includes a "The key insight is…" sentence and a "Why now?" justification.

All results were verified with `lake build` (the target module compiles cleanly with no warnings and no remaining `sorry`).

Note: the project's pre-existing `sorry` in `Shared/CarmichaelProof.lean` (the asymptotic tail of Carmichael's primitive-prime-divisor theorem for Fibonacci numbers, composite n > 10000) is a deep classical result requiring a Lifting-the-Exponent development that is out of scope for this cycle; it was left untouched. The full-project default build also has a pre-existing broken reference to a missing `Algebra/Jacobian/Defs.lean`, unrelated to this work; the new file was verified by building its own module target.