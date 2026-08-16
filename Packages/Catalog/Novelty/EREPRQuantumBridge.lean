import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EREPRBridge

/-!
# From qubits to throats: quantitative ER=EPR for many Bell pairs

`Novelty.EREPRBridge` matches a single entangled qubit pair with a single bulk
throat.  This file makes the dictionary quantitative and extends it to many
pairs.

* `linearEntropy_eq_concurrence_sq`: for a normalised real two-qubit pure state
  the *linear entanglement entropy* `2(1 - Tr ρ²)` of either marginal equals the
  square of the concurrence.  Hence the throat area assigned to the pair in the
  ER=EPR dictionary is exactly the square root of the linear entropy of the
  state, and `mutualInfo² = 4 · linearEntropy`.

* `matchingModel`: the bulk geometry of `n` independent Bell pairs, a perfect
  matching of `2n` boundary cells by throats of prescribed areas.  We prove that
  partners have mutual information twice the throat area
  (`matching_partner_mutualInfo`), that non-partners are exactly unentangled
  (`matching_cross_mutualInfo`), that a bridge joins two cells precisely when
  they are partners with a positive throat (`matching_bridge_iff`), and that the
  whole geometry is reconstructed from the pairwise entanglement data
  (`matching_reconstruction`).
-/

noncomputable section

namespace EmergentGeometry

open Finset EmergentSpacetime

/-! ## Linear entanglement entropy of a real two-qubit state -/

/-- Purity `Tr ρ²` of the left marginal of a real two-qubit pure state. -/
def marginalPurity (ψ : TwoQubitState) : ℝ :=
  ∑ i, ∑ k, (leftReduced ψ i k) ^ 2

/-- Linear entanglement entropy `2(1 - Tr ρ²)` of a real two-qubit pure state. -/
def linearEntropy (ψ : TwoQubitState) : ℝ := 2 * (1 - marginalPurity ψ)

/-- **The throat area is the square root of the linear entropy.**  For a
normalised real two-qubit pure state, the linear entanglement entropy of either
marginal equals the square of the concurrence, i.e. the square of the area of
the Einstein–Rosen throat assigned to the pair. -/
theorem linearEntropy_eq_concurrence_sq (ψ : TwoQubitState)
    (hnorm : ∑ i, ∑ j, (ψ i j) ^ 2 = 1) :
    linearEntropy ψ = (concurrence ψ) ^ 2 := by
  have hdet : (concurrence ψ) ^ 2 = 4 * (Matrix.det ψ) ^ 2 := by
    simp only [concurrence, entanglementDet, mul_pow, sq_abs]
    ring
  simp only [linearEntropy, marginalPurity, leftReduced, hdet, Matrix.det_fin_two,
    Fin.sum_univ_two] at *
  nlinarith [hnorm, sq_nonneg (ψ 0 0), sq_nonneg (ψ 1 1)]

/-- The mutual information of the emergent throat is determined by the linear
entropy of the state: `I² = 4 · linearEntropy`. -/
theorem mutualInfo_sq_eq_linearEntropy (ψ : TwoQubitState)
    (hnorm : ∑ i, ∑ j, (ψ i j) ^ 2 = 1) :
    (mutualInfo (pairModel (concurrence ψ) (concurrence_nonneg ψ))
        (single 0) (single 1)) ^ 2 = 4 * linearEntropy ψ := by
  rw [pairModel_mutualInfo, linearEntropy_eq_concurrence_sq ψ hnorm]
  ring

/-! ## The geometry of `n` Bell pairs -/

variable {n : ℕ}

/-- The bulk geometry of `n` independent Bell pairs: `2n` boundary cells joined
in pairs by throats of area `w i`. -/
def matchingModel (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) : HoloModel (Fin n × Bool) where
  weight := fun p q => if p.1 = q.1 ∧ p.2 ≠ q.2 then w p.1 else 0
  weight_symm := by
    intro p q
    by_cases h : p.1 = q.1 ∧ p.2 ≠ q.2
    · rw [if_pos h, if_pos ⟨h.1.symm, fun hh => h.2 hh.symm⟩, h.1]
    · rw [if_neg h, if_neg (fun hh => h ⟨hh.1.symm, fun k => hh.2 k.symm⟩)]
  weight_nonneg := by
    intro p q
    by_cases h : p.1 = q.1 ∧ p.2 ≠ q.2
    · rw [if_pos h]; exact hw _
    · rw [if_neg h]
  bdry := fun _ => true

lemma matchingModel_noBulk (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) :
    NoBulk (matchingModel w hw) := fun _ => rfl

/-- Partners are entangled in proportion to the area of their throat. -/
theorem matching_partner_mutualInfo (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (i : Fin n) :
    mutualInfo (matchingModel w hw) (single (i, false)) (single (i, true)) = 2 * w i := by
  have hne : ((i, false) : Fin n × Bool) ≠ (i, true) := by simp
  have h := weight_eq_half_mutualInfo (matchingModel_noBulk w hw) hne
  have hval : (matchingModel w hw).weight (i, false) (i, true) = w i := by
    simp [matchingModel]
  rw [hval] at h
  linarith

/-- Positive-area steps in the matching geometry never leave a pair. -/
lemma matching_adj_fst {w : Fin n → ℝ} {hw : ∀ i, 0 ≤ w i} {p q : Fin n × Bool}
    (h : BulkAdj (matchingModel w hw).toBulkGraph p q) : p.1 = q.1 := by
  by_contra hne
  have : (matchingModel w hw).weight p q = 0 := by
    simp only [matchingModel]
    exact if_neg (fun hh => hne hh.1)
  rw [BulkAdj, this] at h
  exact lt_irrefl 0 h

/-- Bulk paths in the matching geometry never leave a pair. -/
lemma matching_path_fst {w : Fin n → ℝ} {hw : ∀ i, 0 ≤ w i} {p q : Fin n × Bool}
    (h : BulkPath (matchingModel w hw).toBulkGraph p q) : p.1 = q.1 := by
  induction h with
  | refl => rfl
  | tail _ hlast ih => exact ih.trans (matching_adj_fst hlast)

/-- **Non-partners are exactly unentangled**: cells belonging to different Bell
pairs have vanishing mutual information, because no bulk bridge joins them. -/
theorem matching_cross_mutualInfo (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i)
    {i j : Fin n} (hij : i ≠ j) (b c : Bool) :
    mutualInfo (matchingModel w hw) (single (i, b)) (single (j, c)) = 0 := by
  refine mutualInfo_eq_zero_of_no_bridge _ _ ?_
  intro p q hp hq hpath
  have hp' : p = (i, b) := by simpa [single] using hp
  have hq' : q = (j, c) := by simpa [single] using hq
  subst hp'; subst hq'
  exact hij (matching_path_fst hpath)

/-- **Bridges are exactly the entangled pairs.**  Two cells of the matching
geometry are joined by an Einstein–Rosen bridge precisely when they are partners
across a throat of positive area. -/
theorem matching_bridge_iff (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (i : Fin n) :
    BulkPath (matchingModel w hw).toBulkGraph (i, false) (i, true) ↔ 0 < w i := by
  constructor
  · intro hp
    by_contra hnp
    have hzero : w i = 0 := le_antisymm (not_lt.1 hnp) (hw i)
    have hmi : mutualInfo (matchingModel w hw) (single (i, false)) (single (i, true)) = 0 := by
      rw [matching_partner_mutualInfo, hzero]; ring
    have hall : ∀ p q : Fin n × Bool, (matchingModel w hw).weight p q = 0 ∨ p.1 ≠ i := by
      intro p q
      by_cases hpi : p.1 = i
      · left
        by_cases h : p.1 = q.1 ∧ p.2 ≠ q.2
        · simp only [matchingModel]
          rw [if_pos h, hpi, hzero]
        · simp only [matchingModel]
          exact if_neg h
      · exact Or.inr hpi
    rcases Relation.ReflTransGen.cases_tail hp with hcon | ⟨c, hbefore, hlast⟩
    · exact absurd hcon (by simp)
    · have hc : c.1 = i := (matching_path_fst hbefore).symm
      rcases hall c (i, true) with hz | hne
      · rw [BulkAdj, hz] at hlast; exact lt_irrefl 0 hlast
      · exact hne hc
  · intro hpos
    refine Relation.ReflTransGen.single ?_
    show (0:ℝ) < (matchingModel w hw).weight (i, false) (i, true)
    simpa [matchingModel] using hpos

/-- **Reconstruction of the multi-throat geometry.**  All throat areas of the
`n`-pair geometry are read off from the pairwise mutual informations of the
boundary cells. -/
theorem matching_reconstruction (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (i : Fin n) :
    w i = mutualInfo (matchingModel w hw) (single (i, false)) (single (i, true)) / 2 := by
  rw [matching_partner_mutualInfo]
  ring

/-- **ER = EPR for `n` pairs.**  The geometry of `n` Bell pairs consists of
exactly the bridges joining entangled partners: partners with positive throat
area are bridged and entangled, non-partners are neither. -/
theorem matching_ER_EPR (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (i j : Fin n) (b c : Bool) :
    (i = j ∧ b ≠ c ∧ 0 < w i →
        BulkPath (matchingModel w hw).toBulkGraph (i, b) (j, c) ∧
        0 < mutualInfo (matchingModel w hw) (single (i, b)) (single (j, c)))
      ∧ (i ≠ j →
        ¬ BulkPath (matchingModel w hw).toBulkGraph (i, b) (j, c) ∧
        mutualInfo (matchingModel w hw) (single (i, b)) (single (j, c)) = 0) := by
  constructor
  · rintro ⟨rfl, hbc, hpos⟩
    have hb : b = !c := by cases b <;> cases c <;> simp_all
    have hstep : BulkPath (matchingModel w hw).toBulkGraph (i, b) (i, c) := by
      refine Relation.ReflTransGen.single ?_
      show (0:ℝ) < (matchingModel w hw).weight (i, b) (i, c)
      have : (matchingModel w hw).weight (i, b) (i, c) = w i := by
        simp [matchingModel, hbc]
      rw [this]; exact hpos
    refine ⟨hstep, ?_⟩
    have hne : ((i, b) : Fin n × Bool) ≠ (i, c) := by simp [hbc]
    have h := weight_eq_half_mutualInfo (matchingModel_noBulk w hw) hne
    have hval : (matchingModel w hw).weight (i, b) (i, c) = w i := by
      simp [matchingModel, hbc]
    rw [hval] at h
    linarith
  · intro hij
    refine ⟨fun hpath => hij (matching_path_fst hpath), matching_cross_mutualInfo w hw hij b c⟩

end EmergentGeometry