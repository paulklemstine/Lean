/-
# The Boltzmann Bridge IX — Representation and Edge-Realization of the Isometry

This file goes **deeper** than Boltzmann Bridge VIII
(`Applications.BoltzmannBridge.InterleavingIsometry`), which proved the isometry
formula

> `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`
> (`eInterleavingDist_eq_weightSupEDist`).

Bridge VIII's Lab Notebook flagged two open frontiers; this file discharges both.

## The arc so far

* **IV — `BottleneckStability`**: the interleaving preorder, `WeightCloseBy`, CESH
  stability `stability_supDist`, and the explicit distance-matrix layer
  (`diamWeightOf`, `diamFiltrationOf`, `diamWeightOf_dist_le`,
  `vr_stability_interleaved`).
* **V — `InterleavingMetric`**: the `ℝ≥0∞`-valued `eInterleavingDist`.
* **VII — `InterleavingClosure`**: `eInterleavingDist = 0 ↔ F = G` (a genuine
  `EMetricSpace`).
* **VIII — `InterleavingIsometry`**: `interleaved_iff_weightCloseBy`,
  `weightSupEDist`, and the isometry `eInterleavingDist_eq_weightSupEDist`.

## The deepening (this file)

### Direction A — the representation is a *bijection* (range characterization).

Bridge VIII showed the weight map is an **isometric embedding**.  We upgrade this
to a full **representation theorem**: the weight map is a *bijection* of
`Filtration α` onto the subtype of weight functions that are grounded at `∅` and
monotone under inclusion (`filtrationEquivWeight`).  Persistence is thus not merely
an isometry *into* `(Finset α → ℝ)`; its image is *exactly* the cone of admissible
weights, and `eInterleavingDist` is transported to the sup-distance there
(`eInterleavingDist_eq_repr_supEDist`).

### Direction B — *realizing the sup at a single edge* for Vietoris–Rips.

Bridge VIII deferred "turning `⨆ σ` over simplices into `⨆ x y` over the underlying
distance matrices — which needs the diameter sup to be attained at a single edge."
We settle this for genuine (symmetric, grounded, nonnegative) distance matrices: the
isometry sup over *all* simplices collapses onto the sup over *edges*,

> **`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
>   = ⨆ (x y), ENNReal.ofReal |d₁ x y - d₂ x y|`**  (`vr_eInterleavingDist_eq_edgeSup`).

The `≤` half is the `1`-Lipschitz estimate `diamWeightOf_dist_le` (no hypotheses);
the `≥` half is the edge-realization `diamWeightOf_pair` (every two-vertex simplex
`{x,y}` has diameter exactly `d x y`), so the maximizing edge is itself a simplex.

As a corollary, the concrete `3`-point cloud certificate of Bridge IV/V is upgraded
from an *inequality* to an **exact equality**
(`cloud_eInterleavingDist_eq` : the distance is *exactly* `1/10`).

## Main results

* `filtrationEquivWeight` — filtrations ≃ grounded-monotone weight functions
* `eInterleavingDist_eq_repr_supEDist` — distance transported across the bijection
* `diamWeightOf_pair` — two-vertex diameter = the single edge length
* `vr_eInterleavingDist_eq_edgeSup` — **the edge-realization of the isometry**
* `cloud_eInterleavingDist_eq` — the concrete cloud distance is *exactly* `1/10`
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## Direction A — the representation bijection -/

-- !-- Both maps are the identity on the underlying weight (with proof-irrelevant
-- !-- side conditions repackaged), so `left_inv`/`right_inv` are `rfl` by structure
-- !-- and subtype eta. -- !--
/-- **The representation bijection.**  The weight map identifies `Filtration α`
with the subtype of weight functions that are grounded at `∅` (`w ∅ ≤ 0`) and
monotone under inclusion.  Combined with Bridge VIII's isometry, this is the full
representation theorem: persistence is an isometric *bijection* onto the cone of
admissible weights, not merely an embedding. -/
def filtrationEquivWeight :
    Filtration α ≃ {w : Finset α → ℝ // w ∅ ≤ 0 ∧ ∀ σ τ : Finset α, σ ⊆ τ → w σ ≤ w τ} where
  toFun F := ⟨F.weight, F.weight_empty, fun _ _ h => F.weight_mono h⟩
  invFun w := ⟨w.1, w.2.1, fun {_ _} h => w.2.2 _ _ h⟩
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl

-- !-- `(filtrationEquivWeight F).1` is definitionally `F.weight`, so this is exactly
-- !-- Bridge VIII's `eInterleavingDist_eq_weightSupEDist`. -- !--
/-- **The distance is transported across the representation bijection.**  Under
`filtrationEquivWeight`, the extended interleaving distance becomes the extended
sup-distance of the represented weight functions. -/
theorem eInterleavingDist_eq_repr_supEDist (F G : Filtration α) :
    eInterleavingDist F G
      = ⨆ σ : Finset α,
          ENNReal.ofReal |(filtrationEquivWeight F).1 σ - (filtrationEquivWeight G).1 σ| :=
  eInterleavingDist_eq_weightSupEDist F G

end Filtration

/-! ## Direction B — edge-realization for Vietoris–Rips -/

section VR

variable {α : Type*} [DecidableEq α]

/-- A bare **distance matrix**: nonnegative, with zero diagonal and symmetric.
No `PseudoMetricSpace` structure or triangle inequality is required — only the
algebra needed to realize the diameter at a single edge. -/
structure IsDistMatrix (d : α → α → ℝ) : Prop where
  nonneg : ∀ i j, 0 ≤ d i j
  diag : ∀ i, d i i = 0
  symm : ∀ i j, d i j = d j i

-- !-- `le_antisymm` of `sup'_le` (each pairwise value of `{x,y}` is `0`, `d x y`,
-- !-- `d y x = d x y`, or `0`, all `≤ d x y` by `nonneg`/`diag`/`symm`) and
-- !-- `le_sup'` applied to the pair `(x,y) ∈ {x,y} ×ˢ {x,y}`. -- !--
/-- **Edge-realization of the diameter.**  For a distance matrix, the diameter
weight of the two-vertex simplex `{x, y}` is exactly the single edge length
`d x y`.  (When `x = y` both sides are `0`.)  Hence every edge is realized by a
simplex, the key to collapsing the simplex-sup onto the edge-sup. -/
theorem diamWeightOf_pair (d : α → α → ℝ) (hd : IsDistMatrix d) (x y : α) :
    diamWeightOf d ({x, y} : Finset α) = d x y := by
  refine le_antisymm (Finset.sup'_le _ _ ?_) ?_
  · simp +decide [Finset.mem_insert, Finset.mem_image]
    refine ⟨hd.nonneg x y, ?_⟩
    rintro a u v (rfl | rfl) (rfl | rfl) rfl <;> simp +decide [hd.diag, hd.symm] <;>
      exact hd.nonneg _ _
  · exact Finset.le_sup' (fun p => id p) (by aesop)

/-- The **edge sup-distance** of two distance matrices: the `ℝ≥0∞`-valued supremum
of `ENNReal.ofReal |d₁ x y - d₂ x y|` over all ordered pairs `(x, y)`. -/
noncomputable def edgeSupEDist (d₁ d₂ : α → α → ℝ) : ℝ≥0∞ :=
  ⨆ p : α × α, ENNReal.ofReal |d₁ p.1 p.2 - d₂ p.1 p.2|

-- !-- If `edgeSupEDist = ⊤`, `le_top`.  Else every pair gap is `≤ E.toReal`
-- !-- (`le_iSup` + `toReal_mono`), so `diamWeightOf_dist_le` gives every simplex gap
-- !-- `≤ E.toReal`; then `iSup_le` and `ofReal_toReal` close it. -- !--
omit [DecidableEq α] in
/-- **Upper half of the edge-realization (the `1`-Lipschitz estimate).**  The
weight-sup distance of the VR filtrations is at most the edge sup-distance — every
simplex gap is dominated by the worst edge gap.  Requires no hypotheses on the
matrices. -/
theorem weightSupEDist_diam_le_edgeSup (d₁ d₂ : α → α → ℝ) :
    Filtration.weightSupEDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
      ≤ edgeSupEDist d₁ d₂ := by
  by_contra h_contra
  by_cases hE_top : edgeSupEDist d₁ d₂ = ⊤
  · aesop
  · have h_pair_bound : ∀ x y, |d₁ x y - d₂ x y| ≤ (edgeSupEDist d₁ d₂).toReal := by
      intro x y
      have h_pair_bound : ENNReal.ofReal |d₁ x y - d₂ x y| ≤ edgeSupEDist d₁ d₂ :=
        le_iSup_of_le (x, y) le_rfl
      convert ENNReal.toReal_mono hE_top h_pair_bound using 1
      simp +decide [ENNReal.toReal_ofReal (abs_nonneg _)]
    refine h_contra (le_trans ?_ (le_of_eq (ENNReal.ofReal_toReal hE_top)))
    refine iSup_le fun σ => ?_
    exact ENNReal.ofReal_le_ofReal
      (diamWeightOf_dist_le d₁ d₂ σ ENNReal.toReal_nonneg fun x _ y _ => h_pair_bound x y)

-- !-- For each pair `(x,y)`, `ofReal |d₁ x y - d₂ x y| = ofReal |diam d₁ {x,y} -
-- !-- diam d₂ {x,y}|` by `diamWeightOf_pair`, which is `≤ weightSupEDist` via
-- !-- `le_iSup` at `σ = {x,y}`; then `iSup_le`. -- !--
/-- **Lower half of the edge-realization (the maximizing edge is a simplex).**  For
distance matrices, the edge sup-distance is at most the weight-sup distance of the
VR filtrations: each edge `{x,y}` is itself a simplex realizing the gap
`|d₁ x y - d₂ x y|`. -/
theorem edgeSup_le_weightSupEDist_diam (d₁ d₂ : α → α → ℝ)
    (hd₁ : IsDistMatrix d₁) (hd₂ : IsDistMatrix d₂) :
    edgeSupEDist d₁ d₂
      ≤ Filtration.weightSupEDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) := by
  refine iSup_le fun p => ?_
  refine le_iSup_of_le {p.1, p.2} ?_
  simp +decide [diamFiltrationOf, diamWeightOf_pair d₁ hd₁, diamWeightOf_pair d₂ hd₂]

-- !-- Rewrite with Bridge VIII's `eInterleavingDist_eq_weightSupEDist`, then
-- !-- `le_antisymm` of `weightSupEDist_diam_le_edgeSup` and
-- !-- `edgeSup_le_weightSupEDist_diam`. -- !--
/-- **The edge-realization of the isometry (Bridge VIII, Direction B).**  For two
distance matrices, the extended interleaving distance of their Vietoris–Rips
filtrations equals the edge sup-distance of the matrices:

> `eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
>   = ⨆ (x y), ENNReal.ofReal |d₁ x y - d₂ x y|`.

The supremum over *all* simplices collapses onto the supremum over *edges* — the
diameter sup is attained at a single edge. -/
theorem vr_eInterleavingDist_eq_edgeSup (d₁ d₂ : α → α → ℝ)
    (hd₁ : IsDistMatrix d₁) (hd₂ : IsDistMatrix d₂) :
    Filtration.eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
      = edgeSupEDist d₁ d₂ := by
  rw [Filtration.eInterleavingDist_eq_weightSupEDist]
  exact le_antisymm (weightSupEDist_diam_le_edgeSup d₁ d₂)
    (edgeSup_le_weightSupEDist_diam d₁ d₂ hd₁ hd₂)

end VR

/-! ## The concrete point-cloud certificate, sharpened to an equality -/

section Cloud

-- !-- `cloud₁` is a distance matrix: `constructor` then an `aesop`/`split` check of
-- !-- nonnegativity, zero diagonal, and symmetry. -- !--
/-- The unit-triangle cloud `cloud₁` is a distance matrix. -/
theorem cloud₁_isDistMatrix : IsDistMatrix cloud₁ := by
  constructor <;> intros <;> unfold cloud₁ <;> aesop

-- !-- Same check for `cloud₂`. -- !--
/-- The perturbed cloud `cloud₂` is a distance matrix. -/
theorem cloud₂_isDistMatrix : IsDistMatrix cloud₂ := by
  constructor <;> norm_num [cloud₂]
  · exact fun i j => by split_ifs <;> norm_num
  · grind

-- !-- `vr_eInterleavingDist_eq_edgeSup` reduces to `edgeSupEDist cloud₁ cloud₂`;
-- !-- the off-diagonal gaps are all `1/10` and the diagonal gaps `0`, so the `⨆`
-- !-- over `Fin 3 × Fin 3` is `ofReal (1/10)` (`le_iSup` at `(0,1)` for `≥`,
-- !-- `iSup_le` with `cloud_distortion` for `≤`). -- !--
/-- **The concrete cloud distance is *exactly* `1/10`.**  Bridge IV/V proved only
`≤ 1/10`; the edge-realization upgrades this to an equality, since the worst edge
gap `|cloud₁ 0 1 - cloud₂ 0 1| = 1/10` is realized by the simplex `{0, 1}`. -/
theorem cloud_eInterleavingDist_eq :
    Filtration.eInterleavingDist (diamFiltrationOf cloud₁) (diamFiltrationOf cloud₂)
      = ENNReal.ofReal (1/10) := by
  rw [vr_eInterleavingDist_eq_edgeSup cloud₁ cloud₂ cloud₁_isDistMatrix cloud₂_isDistMatrix,
    eq_comm]
  refine le_antisymm ?_ ?_
  · refine le_iSup_of_le (0, 1) ?_
    norm_num [cloud₁, cloud₂]
  · exact iSup_le fun p => ENNReal.ofReal_le_ofReal (cloud_distortion p.1 p.2)

end Cloud

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridge VIII closed the metric theory with the isometry `eInterleavingDist F G =
⨆ σ, ofReal |F.weight σ - G.weight σ|`, but left two frontiers open: (A) is the
isometric *embedding* actually a *bijection* onto a recognizable space of weights,
and (B) for the Vietoris–Rips functor, can the simplex-indexed sup be collapsed to
an edge-indexed sup over the raw distance matrices?

## Result
Both confirmed.  (A) `filtrationEquivWeight` exhibits `Filtration α` as *exactly*
the grounded-monotone weight functions, and `eInterleavingDist_eq_repr_supEDist`
transports the distance — persistence is an isometric bijection, with the image
pinned down.  (B) For genuine distance matrices (`IsDistMatrix`),
`vr_eInterleavingDist_eq_edgeSup` collapses the simplex-sup to the edge-sup
`⨆ (x y), ofReal |d₁ x y - d₂ x y|`.  The corollary `cloud_eInterleavingDist_eq`
sharpens the catalog's `≤ 1/10` cloud certificate to an exact `= 1/10`.

## Insight
The edge-realization is a clean duality between *two ways of measuring a sup*: the
`≤` direction is the diameter being `1`-Lipschitz in the data
(`diamWeightOf_dist_le`), while the `≥` direction is the one-line fact that *every
edge is already a simplex* (`diamWeightOf_pair`: `diam {x,y} = d x y`).  Symmetry
and the zero diagonal are exactly what make the two-vertex diameter equal the
single edge length, so no triangle inequality — and no metric-space structure — is
needed; a bare matrix suffices.  This is why the VR persistence distance is
*literally* the `ℓ∞` distance of the distance matrices.

## Failure analysis
The edge-realization is sharp only for symmetric, zero-diagonal, nonnegative `d`:
without symmetry the diameter still ignores orientation, and a negative or nonzero-
diagonal entry would let `diam {x,y}` collapse to `0` (the inserted constant),
breaking `diamWeightOf_pair`.  These are precisely the defining axioms of a
(pseudo)distance, so the result is exactly as general as the data deserves.  The
remaining frontier is the *higher-order* analogue: realizing the sup of a
`k`-dimensional persistence weight at a single `(k+1)`-clique rather than an edge —
deferred to the next cycle.
-/

end BoltzmannBridge