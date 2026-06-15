# Summary of changes for run fa7d021a-1af5-47b6-af52-16446a999677
Created and completed `Catalog/Probability/SpeciesBoltzmannBridge.lean`. The file (and its parent `Catalog/Probability/` directory) did not previously exist in the project — a prior attempt had not produced it — so I authored the intended linear-order species Boltzmann development from scratch and proved every result, with no `sorry`s and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

The file is self-contained (`import Mathlib`) and contains the requested proof chain:

- `linOrderSpeciesCard n = n!` and `linOrderWeight x n = xⁿ`, with `linOrderWeight_eq` recording that the labeled Boltzmann weight `(|L[n]|/n!)·xⁿ` simplifies to `xⁿ` (since `|L[n]| = n!`).
- `boltzmannPartition_linearOrderSpecies`: the closed-form partition function `∑ₙ xⁿ = (1 - x)⁻¹` for `0 ≤ x < 1`, via `tsum_geometric_of_lt_one`.
- `boltzmannPMF_linearOrderSpecies`: the explicit Boltzmann pmf `p(n) = xⁿ (1 - x)` (the geometric distribution), obtained by rewriting the existing pmf definition using the partition closed form.
- `linOrderSpecies_boltzmann_mean`: the mean `E[N] = x / (1 - x)`, reducing the expectation `∑ₙ n·xⁿ(1-x)` to the geometric-derivative identity `∑ₙ n xⁿ = x/(1-x)²` (`tsum_coe_mul_geometric_of_norm_lt_one`) and simplifying.

I verified the complete file compiles cleanly and contains no `sorry`. No other files were modified.