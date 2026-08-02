import Mathlib

/-!
# Quaternionic Hopf concurrence and its sharp maximizers

A two-qubit vector is a pair of complex rows.  Its quaternionic Hopf
coordinate has a distinguished complex component, the determinant.  This file
uses its canonically normalized modulus as a real-valued functional and proves
a rigid equality classification: on the unit sphere it is one exactly when
the coefficient rows are orthogonal and have equal squared norm.
-/

open Complex ComplexConjugate

noncomputable section

namespace QuaternionicConcurrence

/-- A pure two-qubit coefficient vector, arranged as a `2 × 2` matrix. -/
structure State where
  a : ℂ
  b : ℂ
  c : ℂ
  d : ℂ

namespace State

/-- Squared Hilbert norm of a two-qubit coefficient vector. -/
def normSq (ψ : State) : ℝ :=
  Complex.normSq ψ.a + Complex.normSq ψ.b +
    Complex.normSq ψ.c + Complex.normSq ψ.d

/-- The determinant (the exterior-square, or Plücker, coordinate). -/
def determinant (ψ : State) : ℂ := ψ.a * ψ.d - ψ.b * ψ.c

/-- Canonically normalized real Hopf functional.  On normalized states this is
standard pure-state concurrence.  The zero vector is assigned value zero. -/
def hopfFunctional (ψ : State) : ℝ :=
  if ψ.normSq = 0 then 0 else 2 * ‖ψ.determinant‖ / ψ.normSq

/-- Hermitian inner product of the two coefficient rows. -/
def rowInner (ψ : State) : ℂ := conj ψ.a * ψ.c + conj ψ.b * ψ.d

/-- Squared norm of the first coefficient row. -/
def firstRowNormSq (ψ : State) : ℝ :=
  Complex.normSq ψ.a + Complex.normSq ψ.b

/-- Squared norm of the second coefficient row. -/
def secondRowNormSq (ψ : State) : ℝ :=
  Complex.normSq ψ.c + Complex.normSq ψ.d

/-- The two-dimensional complex Lagrange identity.  It identifies determinant
magnitude with the part of one row orthogonal to the other. -/
theorem lagrange_identity (ψ : State) :
    Complex.normSq ψ.determinant + Complex.normSq ψ.rowInner =
      ψ.firstRowNormSq * ψ.secondRowNormSq := by
  simp [determinant, rowInner, firstRowNormSq, secondRowNormSq, Complex.normSq_add,
    Complex.normSq_sub, Complex.normSq_mul, Complex.mul_re, Complex.mul_im,
    Complex.conj_re, Complex.conj_im]
  ring

/-- The functional is unchanged by multiplication of all amplitudes by a
nonzero complex scalar, so it descends from the unit sphere to projective/Hopf
geometry. -/
theorem hopfFunctional_scale_invariant (ψ : State) (z : ℂ) (hz : z ≠ 0) :
    hopfFunctional ⟨z * ψ.a, z * ψ.b, z * ψ.c, z * ψ.d⟩ =
      hopfFunctional ψ := by
  unfold hopfFunctional
  have hz2 : ‖z‖^2 > 0 := sq_pos_of_pos (norm_pos_iff.mpr hz)
  have normSq_scale : (⟨z * ψ.a, z * ψ.b, z * ψ.c, z * ψ.d⟩ : State).normSq = ‖z‖^2 * ψ.normSq := by
    unfold normSq
    simp [Complex.normSq_mul]
    rw [Complex.normSq_eq_norm_sq]
    ring
  have det_scale : (⟨z * ψ.a, z * ψ.b, z * ψ.c, z * ψ.d⟩ : State).determinant = z^2 * ψ.determinant := by
    unfold State.determinant
    ring
  have det_norm_scale : ‖(⟨z * ψ.a, z * ψ.b, z * ψ.c, z * ψ.d⟩ : State).determinant‖ = ‖z‖^2 * ‖ψ.determinant‖ := by
    rw [det_scale, norm_mul, norm_pow]
  by_cases h : ψ.normSq = 0
  · simp [h, normSq_scale]
  · simp [h, hz2.ne', normSq_scale, det_norm_scale]
    field_simp [hz2.ne']

/-- Exact classification of sharp determinant maximizers.  This strengthens
the mere upper bound: a normalized state has functional value one exactly when
its two coefficient rows are Hermitian-orthogonal and both have squared norm
`1/2`. -/
theorem hopfFunctional_eq_one_iff (ψ : State) (hnorm : ψ.normSq = 1) :
    ψ.hopfFunctional = 1 ↔
      ψ.rowInner = 0 ∧ ψ.firstRowNormSq = 1 / 2 ∧ ψ.secondRowNormSq = 1 / 2 := by
  unfold hopfFunctional
  simp [hnorm]
  -- Now goal is: 2 * ‖ψ.determinant‖ = 1 ↔ ψ.rowInner = 0 ∧ ψ.firstRowNormSq = 1/2 ∧ ψ.secondRowNormSq = 1/2
  have h₁ : 2 * ‖ψ.determinant‖ = 1 ↔ Complex.normSq ψ.determinant = 1/4 := by
    constructor
    · intro h
      have : ‖ψ.determinant‖ = 1/2 := by linarith
      rw [Complex.normSq_eq_norm_sq, this]
      ring
    · intro h
      have : ‖ψ.determinant‖^2 = 1/4 := by rwa [Complex.normSq_eq_norm_sq] at h
      have hpos : 0 ≤ ‖ψ.determinant‖ := norm_nonneg _
      nlinarith [sq_nonneg ‖ψ.determinant‖]
  rw [h₁]
  -- Key facts from definitions
  have hfirst_nonneg : 0 ≤ ψ.firstRowNormSq := by
    simp only [firstRowNormSq]
    exact add_nonneg (Complex.normSq_nonneg _) (Complex.normSq_nonneg _)
  have hsecond_nonneg : 0 ≤ ψ.secondRowNormSq := by
    simp only [secondRowNormSq]
    exact add_nonneg (Complex.normSq_nonneg _) (Complex.normSq_nonneg _)
  have hrowInner_nonneg : 0 ≤ Complex.normSq ψ.rowInner := Complex.normSq_nonneg _
  have hdet_nonneg : 0 ≤ Complex.normSq ψ.determinant := Complex.normSq_nonneg _
  have hsum : ψ.firstRowNormSq + ψ.secondRowNormSq = 1 := by
    simp only [normSq, firstRowNormSq, secondRowNormSq] at hnorm ⊢
    linarith
  have lagrange := ψ.lagrange_identity
  -- Now: Complex.normSq ψ.determinant = 1/4 ↔ ψ.rowInner = 0 ∧ ψ.firstRowNormSq = 2⁻¹ ∧ ψ.secondRowNormSq = 2⁻¹
  constructor
  · -- Forward direction: det.normSq = 1/4 implies the conditions
    intro hdet
    -- From Lagrange: 1/4 + rowInner.normSq = first * second
    have hlhs : Complex.normSq ψ.determinant = 1/4 := hdet
    have hprod_eq : Complex.normSq ψ.rowInner = ψ.firstRowNormSq * ψ.secondRowNormSq - 1/4 := by
      linarith
    -- AM-GM: first * second ≤ ((first + second)/2)^2 = 1/4
    have h_amgm : ψ.firstRowNormSq * ψ.secondRowNormSq ≤ 1/4 := by
      nlinarith [sq_nonneg (ψ.firstRowNormSq - ψ.secondRowNormSq)]
    -- So rowInner.normSq = first*second - 1/4 ≤ 0, hence rowInner.normSq = 0
    have h_rowInner_zero : Complex.normSq ψ.rowInner = 0 := by linarith
    have h_rowInner : ψ.rowInner = 0 := Complex.normSq_eq_zero.mp h_rowInner_zero
    have hprod : ψ.firstRowNormSq * ψ.secondRowNormSq = 1/4 := by linarith
    -- And first * second = 1/4 with first + second = 1 implies first = second = 1/2
    have hfirst_half : ψ.firstRowNormSq = 2⁻¹ := by
      have h1 : ψ.firstRowNormSq = 1/2 := by
        nlinarith [sq_nonneg (ψ.firstRowNormSq - ψ.secondRowNormSq)]
      norm_num [h1]
    have hsecond_half : ψ.secondRowNormSq = 2⁻¹ := by linarith
    exact ⟨h_rowInner, hfirst_half, hsecond_half⟩
  · -- Backward direction
    intro ⟨hrw, hfirst, hsecond⟩
    simp [hrw] at lagrange
    rw [hfirst, hsecond] at lagrange
    linarith

/-- On normalized states the canonical functional lies in the unit interval. -/
theorem hopfFunctional_mem_unitInterval (ψ : State) (hnorm : ψ.normSq = 1) :
    0 ≤ ψ.hopfFunctional ∧ ψ.hopfFunctional ≤ 1 := by
  unfold hopfFunctional
  simp [hnorm]
  -- Need to prove 2 * ‖ψ.determinant‖ ≤ 1
  -- Using Lagrange identity: ‖determinant‖² + ‖rowInner‖² = firstRowNormSq * secondRowNormSq
  -- So ‖determinant‖² ≤ firstRowNormSq * secondRowNormSq
  -- And firstRowNormSq + secondRowNormSq = normSq = 1
  -- By AM-GM: firstRowNormSq * secondRowNormSq ≤ 1/4
  have h1 : ψ.firstRowNormSq + ψ.secondRowNormSq = 1 := by
    unfold State.firstRowNormSq State.secondRowNormSq
    simp only [State.normSq] at hnorm
    linarith
  -- Use Lagrange identity
  have h2 := lagrange_identity ψ
  -- ‖determinant‖² ≤ firstRowNormSq * secondRowNormSq
  have h3 : ‖ψ.determinant‖^2 ≤ ψ.firstRowNormSq * ψ.secondRowNormSq := by
    rw [Complex.normSq_eq_norm_sq] at h2
    linarith [Complex.normSq_nonneg ψ.rowInner]
  -- By AM-GM: firstRowNormSq * secondRowNormSq ≤ (1/2)² = 1/4
  have h4 : ψ.firstRowNormSq * ψ.secondRowNormSq ≤ 1 / 4 := by
    have := sq_nonneg (ψ.firstRowNormSq - ψ.secondRowNormSq)
    nlinarith
  -- Therefore ‖determinant‖² ≤ 1/4
  have h5 : ‖ψ.determinant‖^2 ≤ 1 / 4 := le_trans h3 h4
  -- So ‖determinant‖ ≤ 1/2
  have h6 : ‖ψ.determinant‖ ≤ 1 / 2 := by
    have := Real.sqrt_le_sqrt h5
    rw [Real.sqrt_sq (norm_nonneg _)] at this
    norm_num at this
    exact this
  linarith

/-- The zero locus is exactly the determinant-zero (rank-one/product) locus. -/
theorem hopfFunctional_eq_zero_iff (ψ : State) :
    ψ.hopfFunctional = 0 ↔ ψ.determinant = 0 := by
  unfold hopfFunctional
  split_ifs with hnorm
  · -- Case: normSq ψ = 0
    have h : ψ.a = 0 ∧ ψ.b = 0 ∧ ψ.c = 0 ∧ ψ.d = 0 := by
      simp only [normSq] at hnorm
      have ha : Complex.normSq ψ.a = 0 := by linarith [Complex.normSq_nonneg ψ.a, Complex.normSq_nonneg ψ.b, Complex.normSq_nonneg ψ.c, Complex.normSq_nonneg ψ.d]
      have hb : Complex.normSq ψ.b = 0 := by linarith [Complex.normSq_nonneg ψ.a, Complex.normSq_nonneg ψ.b, Complex.normSq_nonneg ψ.c, Complex.normSq_nonneg ψ.d]
      have hc : Complex.normSq ψ.c = 0 := by linarith [Complex.normSq_nonneg ψ.a, Complex.normSq_nonneg ψ.b, Complex.normSq_nonneg ψ.c, Complex.normSq_nonneg ψ.d]
      have hd : Complex.normSq ψ.d = 0 := by linarith [Complex.normSq_nonneg ψ.a, Complex.normSq_nonneg ψ.b, Complex.normSq_nonneg ψ.c, Complex.normSq_nonneg ψ.d]
      exact ⟨Complex.normSq_eq_zero.mp ha, Complex.normSq_eq_zero.mp hb, Complex.normSq_eq_zero.mp hc, Complex.normSq_eq_zero.mp hd⟩
    simp [determinant, h]
  · -- Case: normSq ψ ≠ 0
    rw [div_eq_zero_iff, mul_eq_zero, norm_eq_zero]
    simp [hnorm]

end State
end QuaternionicConcurrence