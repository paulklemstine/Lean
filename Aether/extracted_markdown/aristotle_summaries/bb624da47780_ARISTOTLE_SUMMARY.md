# Summary of changes for run c31a2c86-d362-462c-8761-8aee731d5300
Delivered a complete, compiling research cycle on the **functorial bridge from combinatorial-species generating functions to probability laws** (Domain: Probability), extending the catalog's `Applications/CombinatorialSpecies.lean` EGF dictionary.

## New Lean files (all main theorems proved, 0 sorries, axioms only propext/Classical.choice/Quot.sound)
- `Catalog/Probability/SpeciesBoltzmannBridge.lean` — defines the **Boltzmann distribution** of a counting sequence/species (`boltzmannWeight`, `boltzmannPartition`, `boltzmannPMFReal`, `boltzmannMean`) and proves:
  - `boltzmann_tsum_eq_one` (it is a genuine probability distribution), `boltzmann_nonneg`, `boltzmann_le_one`;
  - `boltzmann_eq_poisson` / `setSpecies_boltzmann_eq_poisson` — **headline bridge:** the Boltzmann law of the species of sets `E` equals Mathlib's `ProbabilityTheory.poissonPMFReal`;
  - `boltzmannMean_eq` — the mean equals (pointed EGF)/EGF, the probabilistic shadow of the catalog's Euler operator `X·d/dX` (`EGF_pointedSpecies`); `setSpecies_boltzmann_mean` gives mean `x`.
- `Catalog/Probability/SpeciesGeometricBridge.lean` — second bridge: the species of linear orders `L` ↦ **geometric** law (`boltzmann_eq_geometric`/`linOrderSpecies_boltzmann_eq_geometric` = `geometricPMFReal (1-x)`), partition `(1-x)⁻¹`, and mean `x/(1-x)`.

Both genuinely **consume the catalog** via `CombinatorialSpecies.setSpecies`, `linearOrderSpecies`, and their `coeffSeq` lemmas. Each file contains `-- !-- Lab Notes -- !--` blocks (Hypothesis / Experiment / Analysis / Critique / Synthesis).

- `Catalog/Probability/FUTURE_DIRECTIONS.md` — five bold, falsifiable conjectures (cycles↦logarithmic/Ewens, exponential-formula-as-compound-Poissonization, Boltzmann moments as logarithmic derivatives, critical samplers/heavy tails, max-entropy characterization), each with a "The key insight is..." sentence and a "Why now?" justification.

## Build configuration fix
The project root `lakefile.toml` was missing `srcDir = "Catalog"` (so no library source was being located) and lacked library entries for the `Applications`/`Probability` source trees. I added `srcDir = "Catalog"`, declared the `Applications` and `Probability` libraries, and added `Probability` to the default targets; the new files build cleanly against the cached Mathlib (`lake build Probability.SpeciesBoltzmannBridge Probability.SpeciesGeometricBridge` succeeds). The same additions were mirrored into `Catalog/lakefile.toml`.

## On the `CarmichaelComposite` priority target
The only genuine `sorry` in the catalog is the *infinite-tail* case (composite `n > 10000`) of `fib_carmichael_composite` in `Catalog/Shared/CarmichaelProof.lean`. This is the genuinely hard direction of Carmichael's primitive-divisor theorem for Fibonacci numbers; closing it requires a lower bound on the primitive part / homogeneous cyclotomic value `Φ_n(φ,ψ)` plus the Birkhoff–Vandiver intrinsic-prime bound — cyclotomic/Lucas-sequence machinery not present in Mathlib — so it remains open and is now documented in place. I did repair that file's build: it previously imported a non-existent module `Shared.CarmichaelHelper` (so it could not elaborate at all); I commented out that unused import (the file only needs Mathlib), and it now elaborates with just the single documented tail `sorry` remaining.