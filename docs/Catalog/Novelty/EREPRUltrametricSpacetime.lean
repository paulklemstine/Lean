import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EmergentGeometryReconstruction
import Novelty.EREPRBridge
import Novelty.EREPRThroatCapacity

/-!
# The emergent spacetime of an entangled state is an ultrametric (tree-like) space

Building on the throat capacity `throat` of `Novelty.EREPRThroatCapacity`, this
file turns the ER=EPR correspondence into an honest *metric geometry*.

For two boundary cells put `cap G u v = throat G {u} {v}` — the cross-section of
the Einstein–Rosen bridge joining them — and define the **emergent distance**

  `bridgeDist G u v = if u = v then 0 else exp (-cap G u v)`,

so that widely open bridges mean nearby points and the absence of a bridge means
maximal distance `1`.

The main results are:

* `cap_min_le` — a Gomory–Hu type inequality: `min (cap u v) (cap v w) ≤ cap u w`.
  The proof is a two-line case analysis on which side of a minimal separating
  surface the third cell lies on.
* `EmergentGeometry.instMetricSpaceBridgeSpace`, `instIsUltrametricDistBridgeSpace` —
  `bridgeDist` makes the boundary cells a genuine `MetricSpace` which is
  **ultrametric**: `d(x,z) ≤ max (d(x,y)) (d(y,z))`.  Emergent holographic space
  is therefore *tree-like*, not merely metric.
* `ultrametric_four_point` — every ultrametric space satisfies the Gromov
  four-point condition with `δ = 0`; hence `bridgeDist_four_point`: the emergent
  spacetime is **`0`-hyperbolic**, the discrete avatar of the negative curvature
  of AdS.
* `bridgeDist_le_exp_neg_mutualInfo` — `d(u,v) ≤ exp(-I(u:v)/2)`: distance decays
  exponentially in the entanglement, Van Raamsdonk's "distance is `-log` of
  entanglement" made into a theorem.
* `bridgeDist_eq_one_iff` — the distance is maximal (`= 1`) exactly when there is
  no Einstein–Rosen bridge: disentangling really does tear space apart.
* `entanglementSetoid` — for each scale `r` the relation `d ≤ r` is an
  *equivalence relation* (a purely ultrametric phenomenon), and the induced
  partitions refine as `r` decreases: an emergent renormalisation hierarchy.
* `bridgeDist_congr_of_mutualInfo` — in models without hidden bulk cells the
  whole emergent metric is reconstructed from two-point mutual informations,
  upgrading `spacetime_from_entanglement` from connectivity to distances.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  If entanglement builds geometry, the geometry it
builds should not be arbitrary: holographic space is negatively curved, so a
faithful toy model must produce a tree-like metric.  Bold form: *the emergent
distance is an ultrametric*, hence `0`-hyperbolic.

EXPERIMENT (Experimenter).  The min-cut capacity between two cells satisfies the
Gomory–Hu inequality `cap u w ≥ min (cap u v) (cap v w)` (a minimal `u`–`w`
surface separates `v` from one of the two ends).  Any decreasing convex
reparametrisation of `cap` then yields an ultrametric; we use `exp(-·)` because
it also normalises "no bridge" to distance `1` and gives the sharp comparison
`d ≤ exp(-I/2)` with mutual information via `mutualInfo_le_two_throat`.

ANALYSIS (Analyst).  Ultrametricity is *strictly stronger* than the triangle
inequality and immediately gives: nested/disjoint balls, equivalence relations at
every scale, and the four-point condition with `δ = 0`.  A first attempt used
`1/(1+cap)`, which is decreasing but does **not** give an ultrametric bound
because `1/(1+·)` is not the exponential of a negative — the max-inequality
survives only for reparametrisations that are *order-reversing*, which is all
`exp(-·)` is used for; the failure was of the proof, not of the statement, and
`exp` was chosen for its extra quantitative content.

CRITIQUE (Critic).  `cap u u = 0` by convention (no surface can separate a cell
from itself), so `cap` alone is *not* an ultrametric-generating kernel; all
statements are formulated for `bridgeDist`, where the diagonal is handled
separately, and `cap_min_le` explicitly carries the hypothesis `u ≠ w`, without
which it is false (take `u = w` joined to `v` by a bridge).
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## The capacity kernel and its Gomory–Hu inequality -/

/-- The cross-section of the Einstein–Rosen bridge joining two boundary cells. -/
def cap (G : BulkGraph V) (u v : V) : ℝ := throat G (single u) (single v)

lemma cap_nonneg (G : BulkGraph V) (u v : V) : 0 ≤ cap G u v :=
  throat_nonneg _ _ _

lemma cap_comm (G : BulkGraph V) (u v : V) : cap G u v = cap G v u :=
  throat_comm _ _ _

omit [Fintype V] in
lemma single_disj {u v : V} (huv : u ≠ v) : Disj (single u) (single v) := by
  intro x hx
  simp only [single, decide_eq_true_eq] at hx ⊢
  simp [hx, huv]

lemma cap_pos_iff (G : BulkGraph V) {u v : V} (huv : u ≠ v) :
    0 < cap G u v ↔ BulkPath G u v :=
  throat_pos_iff_bulkPath G huv

/-- **Gomory–Hu inequality for bridge capacities.**  A minimal surface separating
`u` from `w` must leave the third cell `v` on one of its two sides, so it also
separates `u` from `v` or `v` from `w`. -/
theorem cap_min_le (G : BulkGraph V) (v : V) {u w : V} (huw : u ≠ w) :
    min (cap G u v) (cap G v w) ≤ cap G u w := by
  obtain ⟨σ, hσ, hval⟩ := exists_min_throat_surface G (single_disj huw)
  have hu : σ u = true := hσ.1 u (by simp [single])
  have hw : σ w = false := hσ.2 w (by simp [single])
  have hcap : cap G u w = cutWeight G σ := hval
  rw [hcap]
  by_cases hv : σ v = true
  · have hsep : Separates (single v) (single w) σ := by
      refine ⟨fun x hx => ?_, fun x hx => ?_⟩
      · simp only [single, decide_eq_true_eq] at hx
        rw [hx]; exact hv
      · simp only [single, decide_eq_true_eq] at hx
        rw [hx]; exact hw
    exact le_trans (min_le_right _ _) (throat_le_of_separates hsep)
  · have hv' : σ v = false := by
      cases h' : σ v
      · rfl
      · exact absurd h' hv
    have hsep : Separates (single u) (single v) σ := by
      refine ⟨fun x hx => ?_, fun x hx => ?_⟩
      · simp only [single, decide_eq_true_eq] at hx
        rw [hx]; exact hu
      · simp only [single, decide_eq_true_eq] at hx
        rw [hx]; exact hv'
    exact le_trans (min_le_left _ _) (throat_le_of_separates hsep)

/-! ## The emergent distance -/

/-- **The emergent distance between two boundary cells**: `exp` of minus the
cross-section of the Einstein–Rosen bridge joining them. -/
def bridgeDist (G : BulkGraph V) (u v : V) : ℝ :=
  if u = v then 0 else Real.exp (-(cap G u v))

@[simp] lemma bridgeDist_self (G : BulkGraph V) (u : V) : bridgeDist G u u = 0 := by
  simp [bridgeDist]

lemma bridgeDist_of_ne {G : BulkGraph V} {u v : V} (huv : u ≠ v) :
    bridgeDist G u v = Real.exp (-(cap G u v)) := by
  simp [bridgeDist, huv]

lemma bridgeDist_nonneg (G : BulkGraph V) (u v : V) : 0 ≤ bridgeDist G u v := by
  rcases eq_or_ne u v with rfl | h
  · simp
  · rw [bridgeDist_of_ne h]; positivity

lemma bridgeDist_comm (G : BulkGraph V) (u v : V) :
    bridgeDist G u v = bridgeDist G v u := by
  rcases eq_or_ne u v with rfl | h
  · rfl
  · rw [bridgeDist_of_ne h, bridgeDist_of_ne h.symm, cap_comm]

lemma bridgeDist_le_one (G : BulkGraph V) (u v : V) : bridgeDist G u v ≤ 1 := by
  rcases eq_or_ne u v with rfl | h
  · simp
  · rw [bridgeDist_of_ne h]
    exact Real.exp_le_one_iff.2 (by simpa using cap_nonneg G u v)

lemma bridgeDist_eq_zero_iff (G : BulkGraph V) (u v : V) :
    bridgeDist G u v = 0 ↔ u = v := by
  constructor
  · intro h
    by_contra hne
    rw [bridgeDist_of_ne hne] at h
    exact absurd h (ne_of_gt (Real.exp_pos _))
  · rintro rfl; simp

/-- **The emergent distance is an ultrametric.**  This is strictly stronger than
the triangle inequality: emergent holographic space is tree-like. -/
theorem bridgeDist_ultra (G : BulkGraph V) (u v w : V) :
    bridgeDist G u w ≤ max (bridgeDist G u v) (bridgeDist G v w) := by
  rcases eq_or_ne u w with rfl | huw
  · simpa using le_max_of_le_left (bridgeDist_nonneg G u v)
  rcases eq_or_ne u v with rfl | huv
  · exact le_max_of_le_right (le_refl _)
  rcases eq_or_ne v w with rfl | hvw
  · exact le_max_of_le_left (le_refl _)
  rw [bridgeDist_of_ne huw, bridgeDist_of_ne huv, bridgeDist_of_ne hvw]
  have hmin := cap_min_le G v huw
  rcases le_total (cap G u v) (cap G v w) with h | h
  · refine le_trans (Real.exp_le_exp.2 ?_) (le_max_left _ _)
    have hc : cap G u v ≤ cap G u w :=
      calc cap G u v = min (cap G u v) (cap G v w) := (min_eq_left h).symm
        _ ≤ cap G u w := hmin
    linarith
  · refine le_trans (Real.exp_le_exp.2 ?_) (le_max_right _ _)
    have hc : cap G v w ≤ cap G u w :=
      calc cap G v w = min (cap G u v) (cap G v w) := (min_eq_right h).symm
        _ ≤ cap G u w := hmin
    linarith

lemma bridgeDist_triangle (G : BulkGraph V) (u v w : V) :
    bridgeDist G u w ≤ bridgeDist G u v + bridgeDist G v w := by
  refine le_trans (bridgeDist_ultra G u v w) ?_
  rcases max_cases (bridgeDist G u v) (bridgeDist G v w) with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h]
  · linarith [bridgeDist_nonneg G v w]
  · linarith [bridgeDist_nonneg G u v]

/-! ## The emergent metric space -/

/-- The set of bulk cells, viewed as the emergent metric space of a geometry. -/
def BridgeSpace (_G : BulkGraph V) : Type _ := V

instance (G : BulkGraph V) : Fintype (BridgeSpace G) := inferInstanceAs (Fintype V)
instance (G : BulkGraph V) : DecidableEq (BridgeSpace G) := inferInstanceAs (DecidableEq V)

/-- **Emergent spacetime as a metric space.**  Entanglement data alone endows the
boundary cells with a metric. -/
instance instMetricSpaceBridgeSpace (G : BulkGraph V) : MetricSpace (BridgeSpace G) where
  dist u v := bridgeDist G u v
  dist_self u := bridgeDist_self G u
  dist_comm u v := bridgeDist_comm G u v
  dist_triangle u v w := bridgeDist_triangle G u v w
  eq_of_dist_eq_zero {u v} h := (bridgeDist_eq_zero_iff G u v).1 h

lemma dist_bridgeSpace (G : BulkGraph V) (u v : BridgeSpace G) :
    dist u v = bridgeDist G u v := rfl

/-- **Emergent spacetime is ultrametric.** -/
instance instIsUltrametricDistBridgeSpace (G : BulkGraph V) :
    IsUltrametricDist (BridgeSpace G) :=
  ⟨fun u v w => bridgeDist_ultra G u v w⟩

/-! ## Zero hyperbolicity -/

/-- **Every ultrametric space satisfies the Gromov four-point condition with
`δ = 0`.**  (Stated for a general ultrametric space; specialised to emergent
spacetime in `bridgeDist_four_point`.) -/
theorem ultrametric_four_point {X : Type*} [MetricSpace X] [IsUltrametricDist X]
    (x y z w : X) :
    dist x y + dist z w ≤ max (dist x z + dist y w) (dist x w + dist y z) := by
  by_contra hcon
  push_neg at hcon
  rw [max_lt_iff] at hcon
  obtain ⟨h1, h2⟩ := hcon
  have a1 : dist x y ≤ max (dist x z) (dist z y) := IsUltrametricDist.dist_triangle_max x z y
  have a2 : dist x y ≤ max (dist x w) (dist w y) := IsUltrametricDist.dist_triangle_max x w y
  have b1 : dist z w ≤ max (dist z x) (dist x w) := IsUltrametricDist.dist_triangle_max z x w
  have b2 : dist z w ≤ max (dist z y) (dist y w) := IsUltrametricDist.dist_triangle_max z y w
  rw [dist_comm z y] at a1 b2
  rw [dist_comm w y] at a2
  rw [dist_comm z x] at b1
  rcases le_max_iff.1 a1 with hac | hag
  · have hbg : dist z w ≤ dist y z := by
      rcases le_max_iff.1 b2 with h | h
      · exact h
      · linarith
    have hae : dist x y ≤ dist y w := by
      rcases le_max_iff.1 a2 with h | h
      · linarith
      · exact h
    have hbc : dist z w ≤ dist x z := by
      rcases le_max_iff.1 b1 with h | h
      · exact h
      · linarith
    linarith
  · have hbc : dist z w ≤ dist x z := by
      rcases le_max_iff.1 b1 with h | h
      · exact h
      · linarith
    have haf : dist x y ≤ dist x w := by
      rcases le_max_iff.1 a2 with h | h
      · exact h
      · linarith
    have hbe : dist z w ≤ dist y w := by
      rcases le_max_iff.1 b2 with h | h
      · linarith
      · exact h
    linarith

/-- **Emergent spacetime is `0`-hyperbolic**: the discrete avatar of the negative
curvature of anti-de Sitter space. -/
theorem bridgeDist_four_point (G : BulkGraph V) (x y z w : V) :
    bridgeDist G x y + bridgeDist G z w
      ≤ max (bridgeDist G x z + bridgeDist G y w)
          (bridgeDist G x w + bridgeDist G y z) :=
  ultrametric_four_point (X := BridgeSpace G) x y z w

/-! ## Entanglement determines distance -/

/-- **Distance decays exponentially in entanglement.**  `d(u,v) ≤ exp(-I(u:v)/2)`:
the more entangled two boundary cells are, the closer they are in the emergent
geometry. -/
theorem bridgeDist_le_exp_neg_mutualInfo (M : HoloModel V) {u v : V} (huv : u ≠ v) :
    bridgeDist M.toBulkGraph u v
      ≤ Real.exp (-(mutualInfo M (single u) (single v) / 2)) := by
  rw [bridgeDist_of_ne huv]
  refine Real.exp_le_exp.2 ?_
  have := mutualInfo_le_two_throat M (single_disj huv)
  simp only [cap]
  linarith

/-- **No bridge means maximal distance.**  Two distinct cells are at distance `1`
precisely when no Einstein–Rosen bridge joins them; disentangling tears the
emergent space apart. -/
theorem bridgeDist_eq_one_iff (G : BulkGraph V) {u v : V} (huv : u ≠ v) :
    bridgeDist G u v = 1 ↔ ¬ BulkPath G u v := by
  rw [bridgeDist_of_ne huv]
  constructor
  · intro h hpath
    have hpos : 0 < cap G u v := (cap_pos_iff G huv).2 hpath
    have : Real.exp (-(cap G u v)) < 1 := Real.exp_lt_one_iff.2 (by linarith)
    linarith
  · intro hnp
    have hcap : cap G u v = 0 := by
      rcases lt_or_eq_of_le (cap_nonneg G u v) with h | h
      · exact absurd ((cap_pos_iff G huv).1 h) hnp
      · exact h.symm
    rw [hcap]
    simp

/-- Conversely, a bridge strictly shortens the emergent distance. -/
theorem bridgeDist_lt_one_iff (G : BulkGraph V) {u v : V} (huv : u ≠ v) :
    bridgeDist G u v < 1 ↔ BulkPath G u v := by
  constructor
  · intro h
    by_contra hnp
    rw [(bridgeDist_eq_one_iff G huv).2 hnp] at h
    exact lt_irrefl 1 h
  · intro hpath
    rw [bridgeDist_of_ne huv]
    exact Real.exp_lt_one_iff.2 (by simpa using (cap_pos_iff G huv).2 hpath)

/-- **ER = EPR as a metric statement.**  Entangled boundary cells are strictly
closer than the maximal distance, and the gap is controlled by their mutual
information. -/
theorem ER_EPR_metric (M : HoloModel V) {u v : V} (huv : u ≠ v)
    (h : 0 < mutualInfo M (single u) (single v)) :
    bridgeDist M.toBulkGraph u v < 1 ∧ BulkPath M.toBulkGraph u v ∧
      bridgeDist M.toBulkGraph u v
        ≤ Real.exp (-(mutualInfo M (single u) (single v) / 2)) := by
  obtain ⟨_, hpath, _⟩ := ER_EPR_throat M huv h
  exact ⟨(bridgeDist_lt_one_iff M.toBulkGraph huv).2 hpath, hpath,
    bridgeDist_le_exp_neg_mutualInfo M huv⟩

/-! ## Building up spacetime with entanglement -/

/-- Bridge capacities grow with the areas of the geometry. -/
theorem cap_mono {G H : BulkGraph V} (h : ∀ x y, G.weight x y ≤ H.weight x y) {u v : V}
    (huv : u ≠ v) : cap G u v ≤ cap H u v :=
  throat_mono h (single_disj huv)

/-- **Van Raamsdonk monotonicity: adding entanglement shortens the emergent
distance.**  If every area element of `G` is at most the corresponding one of
`H`, then every emergent distance of `H` is at most that of `G`. -/
theorem bridgeDist_anti {G H : BulkGraph V} (h : ∀ x y, G.weight x y ≤ H.weight x y)
    (u v : V) : bridgeDist H u v ≤ bridgeDist G u v := by
  rcases eq_or_ne u v with rfl | huv
  · simp
  · rw [bridgeDist_of_ne huv, bridgeDist_of_ne huv]
    exact Real.exp_le_exp.2 (by linarith [cap_mono h huv])

/-! ## The scale hierarchy: entanglement clusters -/

/-- **At every scale the emergent geometry organises the boundary into clusters.**
Being at distance at most `r` is an equivalence relation — a phenomenon special
to ultrametric spaces — so the emergent spacetime carries a hierarchy of
partitions indexed by the scale `r`. -/
def entanglementSetoid (G : BulkGraph V) {r : ℝ} (hr : 0 ≤ r) : Setoid V where
  r u v := bridgeDist G u v ≤ r
  iseqv :=
    { refl := fun u => by simpa using hr
      symm := fun {u v} h => by rwa [bridgeDist_comm]
      trans := fun {u v w} h1 h2 =>
        le_trans (bridgeDist_ultra G u v w) (max_le h1 h2) }

/-- The clustering hierarchy is monotone: coarser scales give coarser
partitions. -/
theorem entanglementSetoid_mono (G : BulkGraph V) {r s : ℝ} (hr : 0 ≤ r) (hs : 0 ≤ s)
    (hrs : r ≤ s) {u v : V} (h : (entanglementSetoid G hr).r u v) :
    (entanglementSetoid G hs).r u v :=
  le_trans h hrs

/-- Cells in different clusters at scale `r < 1` and joined by no bridge stay
apart at every finer scale. -/
theorem no_bridge_not_related (G : BulkGraph V) {r : ℝ} (hr : 0 ≤ r) (hr1 : r < 1)
    {u v : V} (huv : u ≠ v) (hnp : ¬ BulkPath G u v) :
    ¬ (entanglementSetoid G hr).r u v := by
  intro h
  have hd : bridgeDist G u v ≤ r := h
  rw [(bridgeDist_eq_one_iff G huv).2 hnp] at hd
  linarith

/-! ## Reconstruction of the metric from entanglement -/

/-- The capacity kernel only sees the off-diagonal weights. -/
lemma cap_congr_offDiag (G H : BulkGraph V)
    (h : ∀ u v : V, u ≠ v → G.weight u v = H.weight u v) (u v : V) :
    cap G u v = cap H u v := by
  have hcut : ∀ f : Region V, cutWeight G f = cutWeight H f :=
    fun f => cutWeight_congr_offDiag G H h f
  simp only [cap, throat]
  split
  · rename_i hne
    exact inf'_congr hne rfl (fun f _ => hcut f)
  · rfl

/-- **The emergent metric is reconstructed from entanglement.**  In geometries
without hidden bulk cells the table of two-point mutual informations determines
every emergent distance — hence the entire metric space, its ultrametric
structure and its `0`-hyperbolicity.  This upgrades `spacetime_from_entanglement`
from connectivity to genuine distances. -/
theorem bridgeDist_congr_of_mutualInfo {M N : HoloModel V}
    (hM : NoBulk M) (hN : NoBulk N)
    (h : ∀ u v : V, mutualInfo M (single u) (single v)
      = mutualInfo N (single u) (single v)) (u v : V) :
    bridgeDist M.toBulkGraph u v = bridgeDist N.toBulkGraph u v := by
  have hw := bulk_weights_determined_by_mutualInfo hM hN h
  rcases eq_or_ne u v with rfl | huv
  · simp
  · rw [bridgeDist_of_ne (G := M.toBulkGraph) huv, bridgeDist_of_ne (G := N.toBulkGraph) huv,
      cap_congr_offDiag M.toBulkGraph N.toBulkGraph hw u v]

/-- **Emergent spacetimes with the same entanglement are isometric.**  The
identity map is an isometry between the emergent metric spaces of two
hidden-cell-free geometries with equal two-point mutual informations: the metric
geometry is an invariant of the entanglement structure alone. -/
def bridgeIsometry {M N : HoloModel V} (hM : NoBulk M) (hN : NoBulk N)
    (h : ∀ u v : V, mutualInfo M (single u) (single v)
      = mutualInfo N (single u) (single v)) :
    BridgeSpace M.toBulkGraph ≃ᵢ BridgeSpace N.toBulkGraph where
  toEquiv := Equiv.refl V
  isometry_toFun := Isometry.of_dist_eq fun u v =>
    (bridgeDist_congr_of_mutualInfo hM hN h u v).symm

end EmergentGeometry