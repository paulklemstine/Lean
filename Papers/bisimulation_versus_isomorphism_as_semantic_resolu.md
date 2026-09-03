# Computational evidence — bisimulation versus isomorphism as semantic resolution

All numbers below were produced inside Lean by
`Catalog/NumberTheory/BisimulationEvidence.lean` (`lake build
NumberTheory.BisimulationEvidence`), using the same `satF` semantics that the theorems
are stated in.  They are *evidence*, not proof; every claim they support is separately
proved without `sorry` in the files listed at the end.

## 1. The enumeration

`allForms k` builds all modal formulas over one atom (`atom 0`) and one tag (`box 0`)
in `k` layers, each layer closing the previous list under `imp` and `box 0`:

| layer `k` | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| `(allForms k).length` | 2 | 8 | 80 | 6560 |

Layer 3 already contains all formulas of box depth `≤ 3` built from `⊥`, `atom 0`,
`imp` and `box 0` in that shape, which is far more than the depth needed to separate
any two worlds of the 5- and 6-world witness frames.

## 2. Counterexample hunt: separating formulas

`sepCount R V R' V' m n k` counts the formulas of layer `k` whose truth value at the
pointed model `(R, V, m)` differs from that at `(R', V', n)`.

| pair | frames | `sepCount … 3` |
|---|---|---|
| multiplicity witness `3` vs `4` | `multR` vs `multR` | **0** |
| sharing witness `5` vs `5` | `shareR` vs `treeR` | **0** |
| control: chain worlds `1` vs `2` | `chainR` vs `chainR` | 90 |
| control: `multR` worlds `3` vs `1` | `multR` vs `multR` | 90 |

So an exhaustive search over 6560 formulas finds **no** separating observation for
either witness pair, while the two controls (worlds that really do differ
behaviourally) are separated by 90 formulas each.  This is exactly what the proved
theorems assert: `MultGap.modEq_three_four` and `Beyond.modEq_share_tree` state the
absence of a separator for *all* formulas, of every depth.

## 3. The multiplicity data

| observation | value |
|---|---|
| `outDeg multR 0 3`, `outDeg multR 0 4` | `2`, `1` |
| `outDeg shareR 0 5`, `outDeg treeR 0 5` | `2`, `2` |
| `outDeg shareR 0 3`, `outDeg treeR 0 4` | `1`, `1` |

The first line is the multiplicity gap of cycle 1: two modally indistinguishable worlds
with different out-degrees.  The second and third lines are the cycle-2 refutation: the
shared diamond and its unravelling are multiplicity-matched at every related pair
(proved in general as `Beyond.outDeg_share_eq_tree`), yet they are not isomorphic
(`Beyond.isEmpty_pointedIso_share_tree`) — the shared diamond has 4 reachable worlds,
its unravelling 5.

## 4. Axiom audit

`#print axioms` on the main results reports only

```
[propext, Classical.choice, Quot.sound]
```

for `bisimilar_iff_modEq`, `modalInvariant_iff_bisimInvariant`, `multiplicity_gap`,
`full_resolution_hierarchy`, `multiplicity_does_not_close_the_gap`, `two_step_ladder`,
`glTheory_cannot_detect_sharing`, `nominal_budget_threshold` and
`collapse_threshold_sharp`.  No `sorry`, no custom axiom, no `native_decide`.

## 5. OEIS

No integer sequence is intrinsic to this project (the enumeration counts
`a(k+1) = a(k)² + 2·a(k)` with `a(0) = 2`, an artefact of the chosen grammar, not of the
mathematics), so no OEIS identification is claimed.

## Files

* `Catalog/NumberTheory/BisimulationResolution.lean`
* `Catalog/NumberTheory/BisimulationMultiplicityGap.lean`
* `Catalog/NumberTheory/BisimulationDepthHierarchy.lean`
* `Catalog/NumberTheory/BisimulationBeyondMultiplicity.lean`
* `Catalog/NumberTheory/BisimulationTheoryTransfer.lean`
* `Catalog/NumberTheory/BisimulationNominalBudget.lean`
* `Catalog/NumberTheory/BisimulationCollapseThreshold.lean`
* `Catalog/NumberTheory/BisimulationEvidence.lean` (this evidence script)
