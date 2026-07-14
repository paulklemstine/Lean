# Computational Evidence: exact count of ℤ₂-maps between combinatorial spheres

We study `N(m, n) := |Z2Map m n|`, the number of antipodally-equivariant simplicial
vertex maps between the octahedral spheres `Sᵐ → Sⁿ`.

## 1. Small-case calculations

The closed form conjectured (and proved) is

    N(m, n) = 2^(m+1) · (n+1)^{falling (m+1)}          (falling factorial)

with the convention that the falling factorial `(n+1)(n)···(n-m+1)` is `0` when `m > n`.

| m \ n | 0 | 1 | 2  | 3   |
|-------|---|---|----|-----|
| 0     | 2 | 4 | 6  | 8   |
| 1     | 0 | 8 | 24 | 48  |
| 2     | 0 | 0 | 48 | 192 |
| 3     | 0 | 0 | 0  | 384 |

Checks:
* `N(0,0) = 2^1·1 = 2` — the two self-maps of `S⁰` (identity and antipodal swap).
* `N(1,1) = 2^2·2 = 8`, `N(2,2) = 2^3·6 = 48`, `N(3,3) = 2^4·24 = 384`.
* `N(3,2) = 0` — a quantitative Borsuk–Ulam obstruction (no `ℤ₂`-map `S³ → S²`).

## 2. OEIS search

The diagonal `N(n, n) = 2^(n+1)·(n+1)!` gives `2, 8, 48, 384, 3840, …`.
This is **OEIS A000165** (`a(k) = 2^k · k!`, "double factorial of even numbers"),
shifted: `N(n,n) = A000165(n+1)`.  This is exactly the order of the **hyperoctahedral
group** `B_{n+1}` — the signed permutation group and full symmetry group of the
`(n+1)`-dimensional cross-polytope — confirming that every `ℤ₂`-self-map of `Sⁿ`
is a signed permutation of coordinate axes.

## 3. Counterexample hunt (naive invariance conjecture)

A tempting guess is that the count is invariant along the suspension tower,
`N(m+k, n+k) = N(m, n)`.  This is **false**: `N(1,1) = 8 ≠ 2 = N(0,0)`.  The count
strictly increases up the tower.  What *does* survive is the divisor `2^(m+1)`
(the free antipodal action) and the *existence* invariance `N > 0 ⇔ m ≤ n`.

## 4. Structural reading

`N(m,n)` factors as (independent signs) × (axis injections):
`2^(m+1)` choices of sign per source axis, times the number of injections
`Fin (m+1) ↪ Fin (n+1)`.  Positivity of the injection count is `m ≤ n`, recovering
the coindex criterion `coind(Sⁿ) = n` as a corollary of the enumeration.


# Compilation / reconstruction status

## Completed in this pass

* **No `sorry` remains** anywhere in the catalog source (all `sorry` tokens live only in
  third-party dependency test files under `.lake/`).
* **Current research-cycle deliverables build cleanly** (`Novelty/Z2CoindexSuspension.lean`,
  `Novelty/Z2CoindexSuspensionTower.lean`, `Novelty/Z2CoindexEnumeration.lean`) and
  `FUTURE_DIRECTIONS.md` is finalized (five conjectures, each with a key insight and a
  "why now").
* **Systematic import bug fixed.** 132 files used a non-resolving `import Catalog.…`
  prefix (the package source root is `Catalog/`, so modules are `Novelty.…`,
  `Shared.…`, etc.). All were rewritten to the correct module path.
* **Reconstructed `Bridges/ToposTheoreticML/Foundations.lean`** (a file that had been
  deleted while `Bridges/VCCompactness.lean` still imported it). The API
  (`ConceptFamily`, `shatters`, `vcDimBound`, `CompactRank`, `CryptoHardnessWitness`,
  `sauerShelahBound`, `sampleComplexityBound`, `TransferMorphism`, `SieveOn` with its
  bounded partial order) was recovered from its usage; `VCCompactness` now compiles.
* Fixed a broken sibling import in the `Algebra/2ff65a6a_retry1_aristotle/…`
  `FundamentalTheorem` tree and removed a dead import in
  `MachineLearning/MulticlassMargin.lean`.

## Pre-existing structural breakage NOT resolved

34 files in the default build tree import 37 sibling modules that are **absent from the
repository** (deleted in earlier cycles). These are genuine mathematical dependencies —
the importing files reference definitions and *proved lemmas* from the missing modules
(e.g. `Tropical.LegendreDuality` supplies the Legendre-transform lemmas used by
`Tropical/FenchelMoreau.lean`; `Computation.BinarySearchVerified` supplies
`bsearch_steps_le`). They cannot be faithfully restored without the original content, and
reconstructing them by guesswork would risk introducing unsound or vacuous statements, so
they were left untouched.

Files still blocked (each `<file> :: <missing module(s)>`):

```
Bridges/BanachFixedPointBridge.lean          :: MachineLearning.SelfImproving.ResNetLipschitz
Bridges/GronwallDiscreteBridge.lean          :: MachineLearning.SelfImproving.ResNetLipschitz
Bridges/MultiClassCertificationBridge.lean   :: MachineLearning.SelfImproving.ResNetLipschitz
Bridges/RecursiveCriticalPairSaturation.lean :: Pythagorean.HOCriticalPairs
Bridges/ResNetTropicalCertified.lean         :: MachineLearning.SelfImproving.ResNetLipschitz
Bridges/StrongChromaticFibonacci.lean        :: Combinatorics.StrongChromaticBipartite
Computation/BinarySearchFactoradicBridge.lean:: Computation.BinarySearchVerified
Computation/IIT/TensorNetworkMultiCut.lean   :: Computation.IIT.TensorNetworkSchmidt
Computation/LandauerLowerBound.lean          :: Computation.ReversibleTropicalThermodynamics
Computation/TropicalLife/RectStillLife.lean  :: Computation.TropicalLife.Basic, .StillLife
Cryptography/HybridTelescope.lean            :: Cryptography.ModuleLWE.Defs, Cryptography.NoncommModuleLWE.TVDContraction
Cryptography/HypergraphRamseyTheorems.lean   :: Cryptography.HypergraphRamseyDefs
Cryptography/Security.lean                   :: Cryptography.LWE.Defs
Geometry/DreamLogic/Topology.lean            :: Speculative.BenfordQuadratic.Defs, .Bounds, .Convergence
Logic/Freivalds.lean                         :: Logic.LobFixedPoint, Logic.LobNatModel
MachineLearning/ChromaticPolynomial/Basic.lean:: Speculative.ChromaticPolynomial.Defs
MachineLearning/Cycles.lean                  :: Speculative.Collatz.Accelerated
MachineLearning/Evaluation.lean              :: Speculative.ChromaticPolynomial.Defs
MachineLearning/ReLUDepthWidth/CrossingCount.lean :: MachineLearning.ReLUDepthWidth.Oscillation
MachineLearning/Stability.lean               :: MachineLearning.TopKRobustness.Defs
Physics/CategoricalPhysics/Theorems.lean     :: Physics.CategoricalPhysics.Defs
Physics/ConsciousFixedPointsBridge.lean      :: Speculative.ConsciousFixedPoints
Physics/HolevoCapacity.lean                  :: Physics.QuantumInfo.VonNeumannEntropy
Physics/SpectralLinkHomology/ConeAcyclic.lean:: Physics.SpectralLinkHomology.Core
Pythagorean/AsymptoticCompactness.lean       :: Pythagorean.SandwichDefs
Pythagorean/Duality.lean                     :: Pythagorean.LorentzianBerggren.Core
Pythagorean/HigherOrderCompletion.lean       :: Pythagorean.HOCriticalPairs, Pythagorean.ConcreteTermAlgebra
Pythagorean/QuotientClosure.lean             :: Pythagorean.HardyHierarchy.DiffClosure
Pythagorean/TropicalAction/Spectrum.lean     :: Pythagorean.TropicalAction.Basic
Tropical/ComputationalHybrid.lean            :: Tropical.HardnessRandomness.Defs, .HybridArgument, .PRGSecurity
Tropical/DiffConstraints.lean                :: Tropical.Convexity.Basic
Tropical/FenchelMoreau.lean                  :: Tropical.LegendreDuality
Tropical/FiberEntropy.lean                   :: Tropical.OrbitPRG.StatDist, .HybridArgument
Tropical/PRGSecurity.lean                    :: Tropical.HardnessRandomness.Defs, .HybridArgument
```

(Additional files outside the default build tree, under `Applications/`, `NumberTheory/`,
`Combinatorics/`, `Probability/`, and `output-final_aristotle/`, reference further absent
modules and are similarly affected.)
