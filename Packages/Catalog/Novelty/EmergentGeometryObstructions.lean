import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EREPRBridge

/-!
# Obstructions and stability for emergent geometry

Three complementary results about which quantum states can have a geometric
(bulk) dual, and how robust the emergent geometry is.

* **Obstruction.** `no_geometric_dual_of_ghz_type` shows that the entropy
  pattern in which every one-, two- and three-party marginal of a four-party
  state has entropy `1` — the pattern of the four-party GHZ state — is realised
  by *no* bulk geometry whatsoever.  Entanglement alone does not build
  spacetime: only entanglement obeying monogamy does.

* **Stability.** `entropy_lipschitz` shows that the entanglement entropies
  depend Lipschitz-continuously on the bulk geometry: perturbing all areas by a
  total of `ε` perturbs every entropy by at most `ε/2`.  Emergent geometry is
  therefore not an artefact of fine tuning.

* **Identification of the two connectivity notions.**
  `bulkPath_iff_entanglementPath` shows that, in a model without hidden cells,
  the bulk connectivity relation is *exactly* the transitive closure of pairwise
  entanglement: the Einstein–Rosen network and the EPR network coincide as
  graphs.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## A state with no geometric dual -/

/-- **Monogamy as an obstruction to holography.**  No bulk geometry produces the
entropy pattern of the four-party GHZ state, in which the three single-party
marginals, the three two-party marginals and the three-party marginal all have
entropy `1`.  (For the four-party GHZ state `(|0000⟩+|1111⟩)/√2` these are the
standard values, so that state has no geometric dual.) -/
theorem no_geometric_dual_of_ghz_type (M : HoloModel V) (A B C : Region V)
    (hAB : ∀ v, A v = true → B v = false)
    (hBC : ∀ v, B v = true → C v = false)
    (hAC : ∀ v, A v = true → C v = false)
    (hA : entropy M A = 1) (hB : entropy M B = 1) (hC : entropy M C = 1)
    (hABe : entropy M (fun v => A v || B v) = 1)
    (hBCe : entropy M (fun v => B v || C v) = 1)
    (hACe : entropy M (fun v => A v || C v) = 1)
    (hABCe : entropy M (fun v => A v || B v || C v) = 1) : False := by
  have h := entropy_monogamy M A B C hAB hBC hAC
  rw [hA, hB, hC, hABe, hBCe, hACe, hABCe] at h
  linarith

/-- The general form of the obstruction: a geometric state has nonpositive
tripartite information, so any state with `I₃ > 0` has no bulk dual. -/
theorem no_geometric_dual_of_tripartite_pos (M : HoloModel V) (A B C : Region V)
    (hAB : ∀ v, A v = true → B v = false)
    (hBC : ∀ v, B v = true → C v = false)
    (hAC : ∀ v, A v = true → C v = false)
    (hpos : 0 < tripartiteInfo M A B C) : False :=
  absurd (tripartiteInfo_nonpos M A B C hAB hBC hAC) (not_le.2 hpos)

/-! ### The obstruction is genuinely new: monogamy is strictly stronger than the
general quantum entropy inequalities -/

/-- The four-party GHZ entropy pattern on three parties: every nonempty
marginal has entropy `1`. -/
def ghzVector (s : Finset (Fin 3)) : ℚ := if s = ∅ then 0 else 1

/-- The GHZ pattern is subadditive. -/
theorem ghzVector_subadditive :
    ∀ s t : Finset (Fin 3), ghzVector (s ∪ t) ≤ ghzVector s + ghzVector t := by
  decide +kernel

/-- The GHZ pattern satisfies strong subadditivity in its submodular form. -/
theorem ghzVector_strong_subadditive :
    ∀ s t : Finset (Fin 3),
      ghzVector (s ∪ t) + ghzVector (s ∩ t) ≤ ghzVector s + ghzVector t := by
  decide +kernel

/-- ... yet it violates monogamy of mutual information.  Together with
`entropy_monogamy` this shows that the geometric constraint proved here is
strictly stronger than the inequalities valid for all quantum states, and that
`no_geometric_dual_of_ghz_type` is not vacuous. -/
theorem ghzVector_violates_monogamy :
    ¬ (ghzVector {0} + ghzVector {1} + ghzVector {2} + ghzVector {0, 1, 2}
      ≤ ghzVector {0, 1} + ghzVector {1, 2} + ghzVector {0, 2}) := by
  decide +kernel

/-! ## Stability of the emergent geometry -/

/-- Total area discrepancy between two bulk geometries. -/
def geometryDist (G G' : BulkGraph V) : ℝ :=
  (∑ u, ∑ v, |G.weight u v - G'.weight u v|) / 2

omit [DecidableEq V] in
lemma geometryDist_nonneg (G G' : BulkGraph V) : 0 ≤ geometryDist G G' :=
  div_nonneg (sum_nonneg fun _ _ => sum_nonneg fun _ _ => abs_nonneg _) (by norm_num)

omit [DecidableEq V] in
/-- Cut areas are Lipschitz in the geometry. -/
lemma cutWeight_dist_le (G G' : BulkGraph V) (f : Region V) :
    |cutWeight G f - cutWeight G' f| ≤ geometryDist G G' := by
  have hsub : cutWeight G f - cutWeight G' f
      = (∑ u, ∑ v, (sepBit (f u) (f v) : ℝ) * (G.weight u v - G'.weight u v)) / 2 := by
    simp only [cutWeight]
    rw [← sub_div]
    congr 1
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun u _ => ?_
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun v _ => ?_
    ring
  rw [hsub, geometryDist, abs_div, abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2)]
  have habs : |∑ u, ∑ v, (sepBit (f u) (f v) : ℝ) * (G.weight u v - G'.weight u v)|
      ≤ ∑ u, ∑ v, |G.weight u v - G'.weight u v| := by
    calc |∑ u, ∑ v, (sepBit (f u) (f v) : ℝ) * (G.weight u v - G'.weight u v)|
      ≤ ∑ u, |∑ v, (sepBit (f u) (f v) : ℝ) * (G.weight u v - G'.weight u v)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ u, ∑ v, |G.weight u v - G'.weight u v| := by
        refine Finset.sum_le_sum fun u _ => ?_
        refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
        refine Finset.sum_le_sum fun v _ => ?_
        rw [abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ (sepBit (f u) (f v) : ℝ))]
        have hle : (sepBit (f u) (f v) : ℝ) ≤ 1 := by
          unfold sepBit; split <;> norm_num
        nlinarith [abs_nonneg (G.weight u v - G'.weight u v)]
  linarith

/-- **Stability of emergent geometry.**  Two bulk geometries on the same
boundary that differ by a total area `ε` give entanglement entropies differing
by at most `ε/2`; in particular the map from geometries to entropy data is
continuous. -/
theorem entropy_lipschitz (M M' : HoloModel V) (hb : M.bdry = M'.bdry)
    (A : Region V) :
    |entropy M A - entropy M' A| ≤ geometryDist M.toBulkGraph M'.toBulkGraph := by
  have hadm : ∀ f, Admissible M A f ↔ Admissible M' A f := by
    intro f
    constructor <;> intro h v hv
    · exact h v (by rw [hb]; exact hv)
    · exact h v (by rw [← hb]; exact hv)
  obtain ⟨f, hf, hval⟩ := exists_minimal_surface M A
  obtain ⟨g, hg, hval'⟩ := exists_minimal_surface M' A
  have h1 : entropy M A ≤ cutWeight M.toBulkGraph g :=
    entropy_le_of_admissible ((hadm g).2 hg)
  have h2 : entropy M' A ≤ cutWeight M'.toBulkGraph f :=
    entropy_le_of_admissible ((hadm f).1 hf)
  have b1 := cutWeight_dist_le M.toBulkGraph M'.toBulkGraph f
  have b2 := cutWeight_dist_le M.toBulkGraph M'.toBulkGraph g
  rw [abs_le] at b1 b2 ⊢
  exact ⟨by rw [hval] at *; linarith [b1.1, h2, hval], by
    rw [hval'] at *; linarith [b2.2, h1, hval']⟩

/-! ## The Einstein–Rosen network is the EPR network -/

/-- Two boundary cells are *directly entangled* when their mutual information is
positive. -/
def EntangledPair (M : HoloModel V) (u v : V) : Prop :=
  0 < mutualInfo M (single u) (single v)

/-- **The two networks coincide.**  In a model without hidden bulk cells, two
cells are joined by a bulk path (a chain of Einstein–Rosen throats) exactly when
they are joined by a chain of directly entangled pairs. -/
theorem bulkPath_iff_entanglementPath {M : HoloModel V} (h : NoBulk M) (u v : V) :
    BulkPath M.toBulkGraph u v ↔ Relation.ReflTransGen (EntangledPair M) u v := by
  have hstep : ∀ x y : V, x ≠ y → (BulkAdj M.toBulkGraph x y ↔ EntangledPair M x y) := by
    intro x y hxy
    rw [BulkAdj, EntangledPair, weight_eq_half_mutualInfo h hxy]
    constructor <;> intro hh <;> linarith
  constructor
  · intro hp
    induction hp with
    | refl => exact Relation.ReflTransGen.refl
    | tail hbefore hlast ih =>
      rename_i b c
      rcases eq_or_ne b c with rfl | hbc
      · exact ih
      · exact ih.tail ((hstep b c hbc).1 hlast)
  · intro hp
    induction hp with
    | refl => exact Relation.ReflTransGen.refl
    | tail hbefore hlast ih =>
      rename_i b c
      rcases eq_or_ne b c with rfl | hbc
      · exact ih
      · exact ih.tail ((hstep b c hbc).2 hlast)

end EmergentGeometry