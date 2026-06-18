# Summary of changes for run ada9ce87-524c-4189-a52e-ed8d253df041
Created and fully proved `Bridges/NeuralPseudometricProofSpectrumFunctorDeep.lean`, completing the two conjectural strands (F1 and F2) of the neural-pseudometric / proof-spectrum bridge. The file builds successfully against its imports (`Bridges/CoalgebraicNeuralMyhillNerode`, `Algebra/ProofSpectra/Core`, `Bridges/NeuralPseudometricProofSpectrumFunctor`) and contains no `sorry`; all main results depend only on the standard axioms.

F1 — graded ultrametric:
- `sepSet` / `sepDepth`: the set of separating depths and the least observation depth that distinguishes two states (via `Nat.sInf`), with supporting lemmas `sepSet_nonempty`, `sepDepth_mem`, `sepDepth_le`, `sepSet_comm`, `sepDepth_comm`.
- `gradedDist N x y`: `0` if behaviorally equivalent, else `(1/2)^(sepDepth N x y)` (i.e. `2^(-d)`).
- Proved: `gradedDist_nonneg`, `gradedDist_self`, `gradedDist_comm`, `gradedDist_eq_zero_iff` (kernel = behavioral equivalence), `gradedDist_strong_triangle` (the strong/ultrametric triangle inequality `gradedDist x z ≤ max (gradedDist x y) (gradedDist y z)`), `gradedDist_le_one`, `gradedDist_refines_obsDist` (pointwise refinement of the discrete pseudometric), plus `gradedDist_kernel_eq_obsDist_kernel` and `gradedDist_kernel_eq_congruence` showing both pseudometrics cut out the same proof-spectrum congruence.

F2 — primality:
- `faithfulPoint N w₀`: an observation context whose readout separates every pair of behaviorally inequivalent states, with `faithfulPoint_zero_iff` detecting behavioral nullity at that point.
- `behaviorCongruence_prime`: under a faithful point and a zero-divisor-free (integral-domain) output semiring (`[NoZeroDivisors K]`, the minimal hypothesis used), the behavior congruence is prime.
- `behaviorPrimeCongruence` / `behaviorSpectrumPoint`: package this as a `PrimeSRCong R`, i.e. a genuine point of the proof spectrum `ProofSpectrum R`.

Note: the full `Catalog` project does not build as a whole due to a pre-existing missing file unrelated to this task (`Algebra/SumThreeCubes/Defs.lean`, referenced by `Algebra/SumThreeCubes/BrauerManin.lean`); the target module here was verified by building it directly.