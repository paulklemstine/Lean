# Build status of the wider catalog

The five files of this research thread build cleanly and are free of `sorry`:

* `Catalog/Bridges/ECMSelfDestructionWall.lean`
* `Catalog/Bridges/ECMWallThresholdFormula.lean`
* `Catalog/Bridges/FactorLocalExponentPlane.lean`
* `Catalog/Bridges/FermatArmDerivative.lean`
* `Catalog/Bridges/FactorLocalExponentRigidity.lean`

## Repairs made to pre-existing catalog files

A full `lake build` of the catalog exposed compilation errors that predate this thread.
The following classes were fixed and each repaired file now compiles:

1. **Unresolvable `import Catalog.*` prefixes** (39 files). The library roots are
   `Bridges`, `Shared`, ... so `import Catalog.Shared.X` never resolved; the prefix was
   dropped. This is what had been keeping the thread's own `Shared/ECMStage1*` modules
   from building.
2. **Four mistyped module names**: `Shared.NumberTheory.CarmichaelHelper` →
   `...CarmichaelHelpers`, `Shared.PosetTheory.HalfPeriodDigitSum` →
   `Shared.HalfPeriodDigitSum`, `Shared.PosetTheory.TreeComplexity` →
   `Shared.TreeComplexity`, `Speculative.AutoResearch.TropicalWalkPerron` →
   `Bridges.TropicalWalkPerron`.
3. **Auto-generated files missing their own definitions or with declarations out of
   dependency order** — the `NeuralCoding/Softplus_*` family (9 files), the
   `AbstractAlgebra/Spb*` family (8 files), `IdempotentTheory`, `LogisticSigmoid*`,
   `Sublevel_full`, `CanonicalKernelDefs`, `KLDivergence`, `Eml`, `EmlDiag`,
   `Root_is_pyth`, `SpbH_bounded`, `DifferentialGeometry/Foundation`,
   `InformationTheory/RepresentableDimension`, `NeuralCoding/EigenvalueRepulsion`,
   `PosetTheory/NewHypotheses`, `BreakthroughDirections`. The missing definitions were
   taken verbatim from the sibling modules that already contained them, or (for
   `IsProb`/`klDiv`/`idempotent_complement`) written out and proved; no statement was
   weakened and no `sorry` was introduced.
4. **Scope/`end` mismatches** in `Bridges/Core.lean` and `Bridges/GraphTheory/Core.lean`.
5. **`Bridges/LFunctions/CanonicalKernelTheorems.lean`**: an auto-merged tail had kept the
   doc-comments of `CanonicalKernelDefs.lean` but dropped the declarations they belonged
   to, so it was not parseable. It is preserved verbatim as comments with a note.

## Still failing (pre-existing, not part of this thread)

The following legacy modules remain broken. They are auto-generated catalog files whose
declarations, definitions or proofs are incomplete in the repository as delivered
(missing statements, references to modules that do not exist, or proofs that no longer
close). Repairing them requires reconstructing mathematics that is not recoverable from
the files themselves, so they were left untouched rather than patched speculatively.

* `Catalog/Bridges/AbstractAlgebra/Euclid_parametrization.lean`
* `Catalog/Bridges/AbstractAlgebra/Ghost.lean`
* `Catalog/Bridges/AbstractAlgebra/MatrixRepresentation.lean`
* `Catalog/Bridges/AbstractAlgebra/SPBFiniteFields.lean`
* `Catalog/Bridges/BerggrenChronometricEntropy.lean`
* `Catalog/Bridges/BerggrenTrees/SpectralTheory.lean`
* `Catalog/Bridges/CarmichaelCompositeEntryPoint.lean`
* `Catalog/Bridges/CategoricalBridges.lean`
* `Catalog/Bridges/CellularAutomata/BetaClassCanonicity.lean`
* `Catalog/Bridges/Characters.lean`
* `Catalog/Bridges/Decoder.lean`
* `Catalog/Bridges/DenseSumsetFree/MultiFold.lean`
* `Catalog/Bridges/DenseSumsetFree/Scales.lean`
* `Catalog/Bridges/DenseSumsetFree/Sharpness.lean`
* `Catalog/Bridges/DenseSumsetFree/Triple.lean`
* `Catalog/Bridges/DifferentialGeometry/NewTheorems.lean`
* `Catalog/Bridges/DynamicProgramming.lean`
* `Catalog/Bridges/EntropyBounds.lean`
* `Catalog/Bridges/ExtremalPoly.lean`
* `Catalog/Bridges/FiberRestriction.lean`
* `Catalog/Bridges/FiniteRateDistortion/TropicalEnvelope.lean`
* `Catalog/Bridges/FiniteRiesz.lean`
* `Catalog/Bridges/FutureTheorems.lean`
* `Catalog/Bridges/GameTheory/CanonicalPathBisimulation.lean`
* `Catalog/Bridges/GraphTheory/UniversalApproxComplexity.lean`
* `Catalog/Bridges/HigherCategoricalBridges.lean`
* `Catalog/Bridges/HilbertSpace/FibonacciAnyonChain.lean`
* `Catalog/Bridges/IdempotentNoether.lean`
* `Catalog/Bridges/InvertedTreeAdvanced.lean`
* `Catalog/Bridges/LFunctions/SpectralGap.lean`
* `Catalog/Bridges/LowerEnvelope.lean`
* `Catalog/Bridges/Minimality.lean`
* `Catalog/Bridges/Mod12Pareto/MetricLemmas.lean`
* `Catalog/Bridges/Network.lean`
* `Catalog/Bridges/NeuralCoding/KTheoryNeuralCore.lean`
* `Catalog/Bridges/NeuralCoding/LanglandsGL2.lean`
* `Catalog/Bridges/NeuralCoding/TropicalFactoring.lean`
* `Catalog/Bridges/NeuralCoding/TropicalQuantumBrain.lean`
* `Catalog/Bridges/PosetTheory/ApparitionOrderBridge.lean`
* `Catalog/Bridges/PosetTheory/BasicOpen.lean`
* `Catalog/Bridges/PosetTheory/BisimMinimization.lean`
* `Catalog/Bridges/PosetTheory/BoundedHOCompletionBeta.lean`
* `Catalog/Bridges/PosetTheory/Bridge4_Pointfree.lean`
* `Catalog/Bridges/PosetTheory/MomentMethodAdvanced.lean`
* `Catalog/Bridges/PosetTheory/QuantumGraphCodes.lean`
* `Catalog/Bridges/PosetTheory/SheafAdvanced.lean`
* `Catalog/Bridges/PosetTheory/SinglePeakedFlatness.lean`
* `Catalog/Bridges/PosetTheory/StrongDivSeqFinsetLattice.lean`
* `Catalog/Bridges/PosetTheory/StrongDivSeqLatticeBridge.lean`
* `Catalog/Bridges/PosetTheory/StrongDivSeqOrderEmbedding.lean`
* `Catalog/Bridges/PosetTheory/TropicalClauseSpace.lean`
* `Catalog/Bridges/PosetTheory/UniversalApproximation.lean`
* `Catalog/Bridges/QuantumDagger.lean`
* `Catalog/Bridges/Representer.lean`
* `Catalog/Bridges/Rigidity.lean`
* `Catalog/Bridges/Search.lean`
* `Catalog/Bridges/SheafCompressionFiniteSite.lean`
* `Catalog/Bridges/Spectral.lean`
* `Catalog/Bridges/SplitGeometry/PhaseStructure.lean`
* `Catalog/Bridges/Stereographic/StereographicBridge.lean`
* `Catalog/Bridges/TransferLearning.lean`
* `Catalog/Bridges/TropicalAlgebra/AdvancedTropicalSPB.lean`
* `Catalog/Bridges/TropicalAlgebra/KruskalTMS.lean`
* `Catalog/Bridges/TropicalAlgebra/NewtonHodgePolygon.lean`
* `Catalog/Bridges/TropicalAlgebra/TropicalSatakeSurjectivity.lean`
* `Catalog/Bridges/TropicalAlgebra/TropicalSemiring.lean`
* `Catalog/Bridges/TropicalAlgebra/TropicalViTFormalization.lean`
* `Catalog/Bridges/TropicalChoquetVoronoiDuality.lean`
* `Catalog/Bridges/TropicalCounterpoint/Penalties.lean`
* `Catalog/Bridges/TropicalDeepLearningTheory.lean`
* `Catalog/Bridges/TropicalLanglandsVarieties.lean`
* `Catalog/Bridges/TropicalProofCertificates/ConcreteExample.lean`
* `Catalog/Bridges/TropicalProofCertificates/Extraction.lean`
* `Catalog/Bridges/UnifiedFramework.lean`
* `Catalog/Bridges/UniversalApproximation.lean`
* `Catalog/Speculative/AutoResearch/MachineLearning/PACBayes/KLProperties.lean`


# Computational evidence — the ECM wall, its exact threshold, and the exponent plane

All numbers below were computed by brute force in exact integer arithmetic (no floating
point, no sampling) before the Lean statements were written; every claim that appears as
a theorem in `Catalog/Bridges/` is proved there without `sorry`.

Notation: `k(B) = ∏_{q ≤ B prime} q^{⌊log_q B⌋} = lcm(1,…,B)` is the stage-1 scalar
(`ECMStage1.stage1Scalar` in the catalog), and the integer Hasse window at `p` is
`W(p) = [p+1-2(⌊√p⌋+1), p+1+2(⌊√p⌋+1)]`, a superset of `[p+1-2√p, p+1+2√p]`
(proved: `ECMWall.mem_hasseWindow_of_abs_le`).

## 1. The wall, and where it actually sits

`B*(p) = min { B : every n ∈ W(p) divides k(B) }` computed exactly:

| p   | window W(p)  | largest prime in W(p) | **B\*(p)** | hasseUpper(p) |
|-----|--------------|-----------------------|------------|---------------|
| 19  | [10, 30]     | 29                    | 29         | 30            |
| 29  | [18, 42]     | 41                    | 41         | 42            |
| 53  | [38, 70]     | 67                    | 67         | 70            |
| 101 | [80, 124]    | 113                   | **121**    | 124           |
| 211 | [182, 242]   | 241                   | 241        | 242           |
| 401 | [360, 444]   | 443                   | 443        | 444           |

Two things are visible and both became theorems:

1. `B*(p) ≤ hasseUpper(p) ≈ p + 2√p` always — the wall certainly exists
   (`ECMWall.allDegenerate_of_hasseUpper_le`, `ECMWall.wall_degenerate`).
2. At `p = 101` the wall is at `121 = 11²`, **not** at the largest prime `113` of the
   window. The threshold is a prime *power*. This is exactly what
   `ECMWall.allDegenerate_iff_windowMaxPP_le` /`ECMWall.isLeast_wall` prove in general:
   `B*(p) = max_{n ∈ W(p)} maxPrimePow(n)`, and `ECMWall.wall_101_exact_sandwich`
   records the `p = 101` case (nothing degenerates below 121; everything degenerates at
   124).

## 2. The dose–response of the firing count across the window

`firingCount(p,B) = #{ n ∈ W(p) : n ∣ k(B) }` (`ECMWall.firingCount`):

| p   | B   | firingCount / |W(p)| | first few firing orders |
|-----|-----|----------------------|--------------------------|
| 53  | 10  | 7 / 33               | 40, 42, 45, 56, 60, 63, 70 |
| 101 | 10  | 4 / 45               | 84, 90, 105, 120 |
| 101 | 20  | 17 / 45              | 80, 84, 85, 88, 90, 91, 95, 99, … |
| 101 | 50  | 32 / 45              | 80, 82, 84, 85, 86, 87, 88, 90, … |
| 101 | 113 | 44 / 45              | everything except 121 |
| 101 | 121 | 45 / 45              | saturated — the wall |

The last two rows are the numerical form of the saturation theorem
`ECMWall.firingCount_saturates_iff`: the count reaches `|W(p)|` exactly when
`B ≥ windowMaxPP p`. Note again that `B = 113` leaves precisely one survivor, `121`.

## 3. Counterexample hunt: can `lpf`/`ω` predict firing? (H2b)

Search over all pairs `m ≠ m'` with `m, m' ≤ 300` having equal largest prime factor and
equal number of distinct prime factors, at bound `B = 4` (`k(4) = 12`): the smallest
witness is `(m, m') = (2, 8)`, and `(4, 8)` is another — `lpf = 2`, `ω = 1` for both,
`4 ∣ 12`, `8 ∤ 12`.
Generalising the witness to `(2^{⌊log₂B⌋}, 2^{⌊log₂B⌋+1})` gives a counterexample for
**every** `B ≥ 2`; that is the proved statement
`ECMWall.lpf_omega_blind_to_firing`. So no statistic that factors through `(lpf, ω)`
can determine stage-1 firing, while `maxPrimePow` (powersmoothness) determines it
exactly (`ECMWall.powersmooth_iff_maxPrimePow_le`).

## 4. The three cost laws

* **Trial division.** For every semiprime tested, the number of trial divisors examined
  equals the smaller prime exactly: `minFac(p·q) = p` for `p ≤ q` — no fitted constant.
  Proved: `FactorPlane.td_cost_semiprime`, `FactorPlane.td_exponent_exact`
  (`log_p cost = 1`).
* **Fermat.** For `N = p·q` with odd primes `p < q`, scanning `x = ⌈√N⌉, ⌈√N⌉+1, …`
  the first `x` with `x² − N` a perfect square was `(p+q)/2` in every case tested
  (e.g. `N = 3·7 = 21 → x = 5`; `N = 11·23 = 253 → x = 17`;
  `N = 101·211 = 21311 → x = 156`). Proved in general:
  `FactorPlane.fermat_halts_exactly`.
  The real gap `(p+q)/2 − √(pq) = (√q − √p)²/2` is `Θ(p)` on bounded-ratio arms
  (`0.0858p` at `q = 2p`, `0.5p` at `q = 4p`), matching the measured `α ≈ 0.993`
  and the proved sandwich `p/12 ≤ gap ≤ 5p/2`.
* **Pollard rho / birthday.** The no-collision probability
  `m^{\underline t}/m^t` at `m = 10^4` is `0.9955, 0.6086, 0.3710, 0.1349` at
  `t = 10, 100, 141, 200`, bracketed at every point by
  `1 − t(t−1)/2m ≤ ratio ≤ exp(−t(t−1)/2m)` — the two proved bounds
  (`FactorPlane.one_sub_le_noCollisionRatio`, `FactorPlane.noCollisionRatio_le_exp`),
  which pin the constant-probability threshold to `[√m, 1 + 1.178√m]`
  (`FactorPlane.birthday_threshold_two_sided`), i.e. exponent `1/2`.

## 5. What the evidence did *not* support

No unconditional lower bound of the form `B*(p) ≥ c·p` is available from these data
without a prime (or prime power) in the Hasse window, whose existence is a Legendre-type
open problem. The Lean development therefore states the "wall cannot switch on early"
results conditionally on an explicit prime power lying in the window
(`ECMWall.not_allDegenerate_of_primePow_in_window`) and unconditionally as the exact
formula `B*(p) = windowMaxPP p`.
