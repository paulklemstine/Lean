# Build status report

Total `.lean` files under `Catalog/`: 1756
Files that reference at least one non-existent internal module (directly): 277
Distinct non-existent internal modules referenced: 232

## Verified findings

* **Zero `sorry`/`admit`** remain in code across all files (comment/docstring
  occurrences of the word "sorry", e.g. "sorry-free", are not code).
* The mission deliverable `output-final_aristotle/Applications/CentralGraphAVD/`
  (`Basic.lean`, `Regular.lean`) compiles cleanly (0 errors, 0 `sorry`).
* Four files carried a corrupted trailing "auto-dedup merge" block (leaked
  docstrings, stripped signatures, a truncated `def` at EOF). These blocks were
  removed; the preserved content is complete. `Cryptography/CSIFiShAdvanced.lean`
  and `Pythagorean/UniversalSupportTutte.lean` now compile; the two `Fano.lean`
  files are clean but still blocked by a genuinely-absent import (below).

## Pre-existing structural breakage (out of scope of the proof work)

The remaining obstacle to a whole-catalog `end-to-end` build is that many
auto-generated files `import` sibling modules that were never generated. These
cannot be repaired without inventing the absent modules. Modules with no file
anywhere in the repository:

* `ABC.Radical`
* `Algebra.`
* `Bridges.ValuationDepthTropicalFunctor`
* `Combinatorics.List.NonCircular`
* `Computation.BinarySearchVerified`
* `Computation.ReversibleTropicalThermodynamics`
* `Computation.TropicalLife.StillLife`
* `Cryptography.NoncommModuleLWE.TVDContraction`
* `Cryptography.ReedMuller.SchwartzZippel`
* `EML.PolynomialMethod.LineRestriction`
* `EML.PolynomialMethod.MultivariateVanishing`
* `EML.PolynomialMethod.UnivariateVanishing`
* `EMLDeep.UniformApprox`
* `Geometry.ErdosSzekeres.CupsCaps`
* `Logic.LobFixedPoint`
* `Logic.LobNatModel`
* `Logic.Propositional`
* `MachineLearning.FixedPoint.Parametric`
* `MachineLearning.ReLUDepthWidth.Oscillation`
* `Novelty.CertifiedNovelty`
* `Novelty.FibonacciEntryPointDuality`
* `PadicInfoGeom.PadicCramerRao`
* `Physics.QuantumInfo.VonNeumannEntropy`
* `Physics.TropicalThermodynamics.Circuit`
* `Physics.TropicalThermodynamics.Landauer`
* `Pythagorean.BoundedBetaDefs`
* `Pythagorean.CauchyBinet`
* `Pythagorean.HardyHierarchy.DiffClosure`
* `Pythagorean.HelfgottGrowth`
* `Pythagorean.LorentzianPermutohedra.EhrhartIDP`
* `Pythagorean.STLCDefs`
* `Pythagorean.SandwichDefs`
* `Pythagorean.TropicalBridge.DefectTheory`
* `Pythagorean.TropicalUniversality`
* `Shared.E`
* `Shared.Sublevel`
* `Speculative.AutoResearch.FibonacciApparition`
* `Speculative.AutoResearch.FibonacciEntryPointCharacterization`
* `Speculative.AutoResearch.ValuationDepthDeepening`
* `Speculative.AutoResearch.ValuationDepthFollowups`
* `Speculative.Collatz.Accelerated`
* `Speculative.OddPerfect.SigmaParity`
* `Tropical.Core.TropicalFactoring`
* `Tropical.Grassmannian.FanoAlgebra`
* `Tropical.HardnessRandomness.HybridArgument`
* `Tropical.Langlands.ArthurSelbergGL2`
* `Tropical.LegendreDuality`
* `Tropical.OrbitPRG.HybridArgument`
* `Tropical.OrbitPRG.StatDist`

(49 genuinely-absent modules; a further 183 referenced
modules share a basename with a file elsewhere in the tree but are not at the
imported path.)


# Computational evidence

## Object

For a `d`‑regular graph `G` that is not complete, the central graph `C(G)` has
vertex set `V ⊕ E`, where every original vertex `v` has degree `|V| − 1` and every
subdivision vertex has degree `2`. A total colouring is a proper colouring of the
total graph `T(C(G))`; it is AVD when adjacent vertices get distinct colour sets.

## Small cases

| `G`            | `d` | `|V|` | non‑complete? | `d+2` | `d+3` | star clique at an original vertex | lower bounds proved |
|----------------|-----|-------|---------------|-------|-------|-----------------------------------|---------------------|
| `C₃ = K₃`      | 2   | 3     | no            | 4     | 5     | size 3                            | (complete: excluded)|
| `C₄`           | 2   | 4     | yes           | 4     | 5     | size 4                            | `≥ d+3 = 5`; `≥ |V|+1 = 5` |
| `C₅`           | 2   | 5     | yes           | 4     | 5     | size 5                            | `≥ d+3 = 5`; `≥ |V|+1 = 6` |
| `C₆`           | 2   | 6     | yes           | 4     | 5     | size 6                            | `≥ d+3 = 5`; `≥ |V|+1 = 7` |
| `K₄ − PM` (`K_{2,2,...}`) | 2 | 4 | yes         | 4     | 5     | size 4                            | `d+3 = |V|+1 = 5` (extremal) |
| `Petersen`     | 3   | 10    | yes           | 5     | 6     | size 10                           | `≥ d+3 = 6`; `≥ |V|+1 = 11` |

Key structural computations (all reflected in the Lean proofs):

* **Vertex count.** In a `d`‑regular graph with a non‑adjacent pair `a, b`, the
  set `{a, b} ∪ N(a)` has `2 + d` distinct elements (`b ∉ N(a)` since `a, b`
  non‑adjacent, `a ∉ N(a)`), so `|V| ≥ d + 2`. Equality forces `Ḡ` to be
  `1`‑regular (a perfect matching).

* **Star clique.** At an original vertex `v`, the vertex `v` together with its
  `|V| − 1` incident edges of `C(G)` forms a clique of size `|V|` in `T(C(G))`, so
  a proper total colouring needs `≥ |V|` colours. With only `d + 2` colours this is
  possible **only if** `|V| = d + 2`, and then the two ends of the non‑edge have
  equal colour set (the whole palette), breaking AVD. Hence no AVD total colouring
  uses `≤ d + 2` colours: `χ''ₐ(C(G)) ≥ d + 3`.

## Counterexample hunt (to the *equality* `χ''ₐ = d + 3`)

The equality claim fails whenever `|V| > d + 2`. The smallest witness is `C₅`:
`d = 2` predicts `χ''ₐ = 5`, but the `|V|`‑based obstruction (`Basic.lean`,
`central_no_avd_of_not_complete`) already gives `χ''ₐ(C(C₅)) ≥ |V| + 1 = 6 > 5`.
So the conjectured value is a **lower bound**, exact only in the extremal regime
`|V| = d + 2`. This is the mathematical content driving `avd_total_ge_regular`
(the honest, provable half of the conjecture).

## Note

No external numerical software was used; the finite facts above are the exact ones
discharged symbolically in `Regular.lean` (e.g. `cycleGraph_five_regular` by
`decide`, degrees by explicit counting), so the "evidence" and the proofs coincide.
