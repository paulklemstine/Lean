import Mathlib
import Catalog.Novelty.UnitDistanceGraph
import Catalog.Novelty.IndependenceRatioChromatic
import Catalog.Novelty.G27CriticalAugmentation

/-!
# The critical two-vertex augmentation, realised geometrically

This file lands the abstract *critical-augmentation dichotomy* of
`Catalog.Novelty.G27CriticalAugmentation` inside the genuine class of planar unit-distance
graphs, matching the geometric setting of the `G27 → G29` construction.

The bridge is a single structural identity: passing to a sub-configuration commutes with the
unit-distance-graph construction.  Precisely, if `p : W → ℝ²` is a point configuration and
`f : V ↪ W` selects a sub-configuration, then the induced subgraph of `unitDistanceGraph p` on
the image of `f` is *exactly* the unit-distance graph of the restricted configuration
`p ∘ f` (`comap_unitDistanceGraph`).  Injectivity of `f` is essential: it is what identifies
`f u ≠ f v` with `u ≠ v`.

With this identity, the arithmetic core transfers verbatim:

* `unitDistance_critical_augmentation` — a `29`-point planar configuration whose unit-distance
  graph has independence number `7`, extending a `27`-point sub-configuration whose unit-distance
  graph *also* has independence number `7` (a critical augmentation adding no independent set),
  has geometric fractional chromatic number `> 4`, while the `27`-point base does not meet the
  threshold at all.

This is the exact combinatorial content that the (open) geometric conjecture asserts is
uniquely realisable up to isometry.  We prove the mechanism; the remaining, genuinely hard,
input is the *existence and uniqueness* of an actual planar configuration realising the
independence-number-preserving two-point extension.

* `comap_unitDistanceGraph` — restriction/augmentation commutes with the construction.
* `unitDistance_indepNum_mono` — augmenting a configuration can only increase the independence
  number of its unit-distance graph.
* `unitDistance_critical_augmentation` — the geometric dichotomy.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the abstract dichotomy is not lost when we restrict to unit-distance
graphs, because "being a unit-distance graph" is preserved under taking sub-configurations.  So
the whole `7/27 vs 7/29` threshold argument should apply to `unitDistanceGraph p` with no extra
geometric hypothesis beyond the two independence-number equalities.
Experiment (Experimenter): prove `(unitDistanceGraph p).comap f = unitDistanceGraph (p ∘ f)` by
`ext` and `simp` with `comap_adj`, `unitDistanceGraph_adj`, and `f.injective.eq_iff` to collapse
`f u ≠ f v ↔ u ≠ v`; then rewrite and invoke `critical_augmentation_dichotomy`.  Monotonicity of
the independence number follows from `indepNum_comap_le` after the same rewrite.
Analysis (Analyst): the formalisation cleanly separates the *combinatorial skeleton* (proved
here in full) from the *geometric realisability* (the open part).  The identity
`comap ∘ unitDistanceGraph = unitDistanceGraph ∘ restrict` is the precise reason the plane's
fractional chromatic number can be attacked through finite sub-configurations.
Critique (Critic): the hypotheses `hbase` and `hcrit` are exactly the two facts a genuine
`G27/G29` witness supplies; neither is vacuous, and `unitDistance_indepNum_mono` certifies that
`hcrit` is a real constraint (augmentation could have increased `α`).  Injectivity of the
embedding is load-bearing in `comap_unitDistanceGraph`.
Synthesis (PI): together with `G27CriticalAugmentation`, this file reduces the geometric
conjecture "the two-vertex augmentation of `G27` raising `χ_f` above `4` is unique up to
isometry" to the sharply-stated realisability/uniqueness question about independence-number
preserving two-point extensions of a `27`-point unit-distance configuration.
-- !-- end Lab Notes -- !--
-/

open scoped Classical
open SimpleGraph

namespace UnitDistance

/-- **Restriction commutes with the unit-distance construction.**  The induced subgraph of a
unit-distance graph along an embedding `f` is the unit-distance graph of the restricted point
configuration `p ∘ f`. -/
theorem comap_unitDistanceGraph {V W : Type*} (f : V ↪ W)
    (p : W → EuclideanSpace ℝ (Fin 2)) :
    (unitDistanceGraph p).comap f = unitDistanceGraph (p ∘ f) := by
  ext u v
  simp only [comap_adj, unitDistanceGraph_adj, Function.comp_apply, ne_eq, f.injective.eq_iff]

/-- **Augmentation only increases the independence number.**  Adding points to a planar
configuration can only enlarge the maximum independent set of its unit-distance graph. -/
theorem unitDistance_indepNum_mono {V W : Type*} [Fintype V] [Fintype W]
    (f : V ↪ W) (p : W → EuclideanSpace ℝ (Fin 2)) :
    (unitDistanceGraph (p ∘ f)).indepNum ≤ (unitDistanceGraph p).indepNum := by
  rw [← comap_unitDistanceGraph f p]
  exact indepNum_comap_le f (unitDistanceGraph p)

/-- **Geometric critical two-vertex augmentation.**  Let `p : W → ℝ²` be a `29`-point planar
configuration and `f : V ↪ W` a `27`-point sub-configuration.  Assume the `27`-point
unit-distance graph has independence number `7`, and the `29`-point augmentation is *critical*,
i.e. it does not change the independence number.  Then:

* the `27`-point base is not forced above `4` (its independence ratio `7/27 > 1/4`), while
* the `29`-point augmentation has geometric fractional chromatic number `> 4`: every fractional
  colouring of `unitDistanceGraph p` has value strictly greater than `4`.

This realises the `G27 → G29` mechanism inside the class of genuine planar unit-distance
graphs. -/
theorem unitDistance_critical_augmentation {V W : Type*} [Fintype V] [Fintype W]
    (f : V ↪ W) (p : W → EuclideanSpace ℝ (Fin 2))
    (hV : Fintype.card V = 27) (hW : Fintype.card W = 29)
    (hbase : (unitDistanceGraph (p ∘ f)).indepNum = 7)
    (hcrit : (unitDistanceGraph p).indepNum = (unitDistanceGraph (p ∘ f)).indepNum) :
    (¬ (unitDistanceGraph (p ∘ f)).indepRatio < 1 / 4) ∧
      (∀ F : (unitDistanceGraph p).FracColoring, 4 < F.value) := by
  have key := critical_augmentation_dichotomy f (unitDistanceGraph p) hV hW
    (by rw [comap_unitDistanceGraph]; exact hbase)
    (by rw [comap_unitDistanceGraph]; exact hcrit)
  rw [comap_unitDistanceGraph] at key
  exact key

end UnitDistance