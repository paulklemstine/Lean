/-
  # Cycle 4: From Two Qubits to Qubit ⊗ Qudit

  The `2 × 2` theory of the previous files is driven by one determinant.  In
  `ℂ² ⊗ ℂ^ι` a state is a pair of rows `(a, b)` and the single determinant is
  replaced by the family of **Plücker coordinates** `Δ_{kl} = a_k b_l − a_l b_k`.
  This file shows that the entire quantitative picture survives verbatim, with
  the classical **Lagrange identity** playing the role that the Hopf gap
  identity played for two qubits.

  Main results.

  * `lagrange_complex` — for arbitrary finite `ι`,
    `Σ_{k,l} |a_k b_l − a_l b_k|² = 2[(Σ|a_k|²)(Σ|b_k|²) − |Σ a_k b̄_k|²]`.
    This is the general Bloch-gap identity: the left side is the squared
    generalised concurrence, the right side twice the Gram determinant of the
    reduced state.
  * `cauchy_schwarz_of_lagrange` — Cauchy–Schwarz drops out as a corollary,
    with the defect *identified* rather than merely bounded.
  * `qqConcurrence_sq_eq_gap`, `qqConcurrence_le_one` — the generalised
    concurrence squared equals `4·(pq − |⟨a,b⟩|²)` and is `≤ 1` on normalised
    states, exactly as in the two-qubit case.
  * `minors_zero_iff_isProduct` — the Segre/Plücker criterion: the state is a
    product iff every Plücker coordinate vanishes.
  * `qqConcurrence_eq_zero_iff_isProduct` — generalised concurrence detects
    entanglement in every dimension.
  * `qqConcurrence_two_qubit` — the definition restricts to the catalogue's
    two-qubit concurrence, so this really is an extension of the core result.
-/
import Mathlib
import Bridges.QuantumSystems.QuantumEntanglementLinkingNumber
import Pythagorean.HopfEntanglementGeometry

open Complex Finset

noncomputable section

namespace QubitQudit

variable {ι : Type*} [Fintype ι]

/-- **Lagrange's identity over `ℂ`.**  The sum of squared Plücker coordinates
equals twice the Gram determinant of the two rows. -/
theorem lagrange_complex (a b : ι → ℂ) :
    ∑ k, ∑ l, Complex.normSq (a k * b l - a l * b k)
      = 2 * ((∑ k, Complex.normSq (a k)) * (∑ k, Complex.normSq (b k))
          - Complex.normSq (∑ k, a k * (starRingEnd ℂ) (b k))) := by
  set w : ι → ℂ := fun k => a k * (starRingEnd ℂ) (b k) with hw
  have expand : ∀ k l : ι, Complex.normSq (a k * b l - a l * b k)
      = Complex.normSq (a k) * Complex.normSq (b l)
        + Complex.normSq (a l) * Complex.normSq (b k)
        - 2 * (w k * (starRingEnd ℂ) (w l)).re := by
    intro k l
    simp [hw, Complex.normSq_apply, Complex.mul_re, Complex.mul_im, Complex.sub_re,
      Complex.sub_im]
    ring
  have hS : Complex.normSq (∑ k, w k) = ((∑ k, w k) * (starRingEnd ℂ) (∑ l, w l)).re := by
    rw [Complex.mul_conj]; simp
  have hdouble : ∑ i, ∑ j, (w i * (starRingEnd ℂ) (w j)).re
      = ((∑ k, w k) * (starRingEnd ℂ) (∑ l, w l)).re := by
    rw [map_sum, Finset.sum_mul_sum, Complex.re_sum]
    exact Finset.sum_congr rfl fun i _ => (Complex.re_sum _ _).symm
  calc ∑ k, ∑ l, Complex.normSq (a k * b l - a l * b k)
      = ∑ k, ∑ l, (Complex.normSq (a k) * Complex.normSq (b l)
          + Complex.normSq (a l) * Complex.normSq (b k)
          - 2 * (w k * (starRingEnd ℂ) (w l)).re) :=
        Finset.sum_congr rfl fun k _ => Finset.sum_congr rfl fun l _ => expand k l
    _ = 2 * ((∑ k, Complex.normSq (a k)) * (∑ k, Complex.normSq (b k))
          - Complex.normSq (∑ k, w k)) := by
        simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul,
          ← Finset.mul_sum]
        rw [hS, hdouble]
        ring

/-- **Cauchy–Schwarz with an exact defect.** -/
theorem cauchy_schwarz_of_lagrange (a b : ι → ℂ) :
    Complex.normSq (∑ k, a k * (starRingEnd ℂ) (b k))
      ≤ (∑ k, Complex.normSq (a k)) * (∑ k, Complex.normSq (b k)) := by
  have h := lagrange_complex a b
  have hnn : 0 ≤ ∑ k, ∑ l, Complex.normSq (a k * b l - a l * b k) :=
    Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _
  linarith [h, hnn]

/-! ## Generalised concurrence -/

/-- The Plücker coordinates of the qubit–qudit state `|0⟩⊗a + |1⟩⊗b`. -/
def plucker (a b : ι → ℂ) (k l : ι) : ℂ := a k * b l - a l * b k

/-- The generalised concurrence `C = √(2 Σ_{k,l} |Δ_{kl}|²)`. -/
def qqConcurrence (a b : ι → ℂ) : ℝ :=
  Real.sqrt (2 * ∑ k, ∑ l, Complex.normSq (plucker a b k l))

lemma sum_plucker_nonneg (a b : ι → ℂ) :
    0 ≤ ∑ k, ∑ l, Complex.normSq (plucker a b k l) :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _

lemma qqConcurrence_nonneg (a b : ι → ℂ) : 0 ≤ qqConcurrence a b := Real.sqrt_nonneg _

lemma qqConcurrence_sq (a b : ι → ℂ) :
    (qqConcurrence a b) ^ 2 = 2 * ∑ k, ∑ l, Complex.normSq (plucker a b k l) :=
  Real.sq_sqrt (by linarith [sum_plucker_nonneg a b])

/-- **The Bloch gap in arbitrary dimension.**  `C² = 4(pq − |⟨a,b⟩|²)`. -/
theorem qqConcurrence_sq_eq_gap (a b : ι → ℂ) :
    (qqConcurrence a b) ^ 2
      = 4 * ((∑ k, Complex.normSq (a k)) * (∑ k, Complex.normSq (b k))
          - Complex.normSq (∑ k, a k * (starRingEnd ℂ) (b k))) := by
  rw [qqConcurrence_sq]
  simp only [plucker]
  rw [lagrange_complex]
  ring

/-- On a normalised state (`p + q = 1`) the generalised concurrence is at most
one, by the same AM–GM argument as in the two-qubit case. -/
theorem qqConcurrence_le_one (a b : ι → ℂ)
    (h : (∑ k, Complex.normSq (a k)) + (∑ k, Complex.normSq (b k)) = 1) :
    qqConcurrence a b ≤ 1 := by
  set p := ∑ k, Complex.normSq (a k)
  set q := ∑ k, Complex.normSq (b k)
  have hgap := qqConcurrence_sq_eq_gap a b
  have hcs := cauchy_schwarz_of_lagrange a b
  have hnnS : 0 ≤ Complex.normSq (∑ k, a k * (starRingEnd ℂ) (b k)) := Complex.normSq_nonneg _
  have hsq : (qqConcurrence a b) ^ 2 ≤ 1 := by
    have h4 : 4 * (p * q) ≤ 1 := by nlinarith [sq_nonneg (p - q)]
    nlinarith [hgap, hnnS, h4]
  nlinarith [qqConcurrence_nonneg a b, hsq]

/-! ## The Segre / Plücker criterion -/

/-- The state factors as `(c,d) ⊗ v`. -/
def IsProductQQ (a b : ι → ℂ) : Prop :=
  ∃ (c d : ℂ) (v : ι → ℂ), (∀ k, a k = c * v k) ∧ (∀ k, b k = d * v k)

/-- **Segre criterion.**  A qubit–qudit pure state is a product state iff all its
Plücker coordinates vanish. -/
theorem minors_zero_iff_isProduct (a b : ι → ℂ) :
    (∀ k l, plucker a b k l = 0) ↔ IsProductQQ a b := by
  constructor
  · intro h
    by_cases ha : ∀ k, a k = 0
    · exact ⟨0, 1, b, by simpa using ha, by simp⟩
    · push_neg at ha
      obtain ⟨k₀, hk₀⟩ := ha
      refine ⟨1, b k₀ / a k₀, a, by simp, ?_⟩
      intro k
      have hkl := h k₀ k
      simp only [plucker] at hkl
      field_simp
      linear_combination hkl
  · rintro ⟨c, d, v, ha, hb⟩ k l
    simp only [plucker, ha, hb]
    ring

/-- **Generalised concurrence detects entanglement in every dimension.** -/
theorem qqConcurrence_eq_zero_iff_isProduct (a b : ι → ℂ) :
    qqConcurrence a b = 0 ↔ IsProductQQ a b := by
  rw [← minors_zero_iff_isProduct]
  constructor
  · intro h
    have hsq : (qqConcurrence a b) ^ 2 = 0 := by rw [h]; ring
    rw [qqConcurrence_sq] at hsq
    have hzero : ∑ k, ∑ l, Complex.normSq (plucker a b k l) = 0 := by linarith
    intro k l
    have h1 : ∀ k' ∈ (Finset.univ : Finset ι),
        ∑ l', Complex.normSq (plucker a b k' l') = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg
        (fun k' _ => Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _)).1 hzero
    have h2 := (Finset.sum_eq_zero_iff_of_nonneg
      (fun l' _ => Complex.normSq_nonneg (plucker a b k l'))).1 (h1 k (Finset.mem_univ k))
    exact Complex.normSq_eq_zero.1 (h2 l (Finset.mem_univ l))
  · intro h
    have : ∑ k, ∑ l, Complex.normSq (plucker a b k l) = 0 := by
      apply Finset.sum_eq_zero
      intro k _
      apply Finset.sum_eq_zero
      intro l _
      rw [h k l]
      simp
    simp [qqConcurrence, this]

/-! ## Consistency with the two-qubit catalogue -/

open TwoQubitState

/-- **The generalised concurrence restricts to the two-qubit concurrence.**
With `a = (α, β)` and `b = (γ, δ)` one recovers `C(ψ) = 2‖αδ − βγ‖`. -/
theorem qqConcurrence_two_qubit (ψ : TwoQubitState) :
    qqConcurrence ![ψ.α, ψ.β] ![ψ.γ, ψ.δ] = ψ.concurrence := by
  have hsum : ∑ k : Fin 2, ∑ l : Fin 2,
      Complex.normSq (plucker ![ψ.α, ψ.β] ![ψ.γ, ψ.δ] k l)
      = 2 * Complex.normSq ψ.entanglementDet := by
    simp [Fin.sum_univ_two, plucker, TwoQubitState.entanglementDet]
    rw [show ψ.β * ψ.γ - ψ.α * ψ.δ = -(ψ.α * ψ.δ - ψ.β * ψ.γ) by ring, Complex.normSq_neg]
    ring
  have hn : Complex.normSq ψ.entanglementDet = ‖ψ.entanglementDet‖ ^ 2 :=
    Complex.normSq_eq_norm_sq _
  rw [qqConcurrence, hsum, hn]
  rw [show (2 : ℝ) * (2 * ‖ψ.entanglementDet‖ ^ 2) = (2 * ‖ψ.entanglementDet‖) ^ 2 by ring]
  rw [Real.sqrt_sq (by positivity)]
  rfl

end QubitQudit