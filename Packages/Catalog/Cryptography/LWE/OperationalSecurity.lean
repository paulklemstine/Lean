import Mathlib

/-!
# Operational Statistical Security for LWE Hybrids

This file turns the `ℓ¹` game distance used by the finite LWE IND-CPA
formalization into an operational statement about every bounded distinguisher.
It also isolates the ring-theoretic uniformity fact used in ring-LWE hybrids:
multiplication by a unit, followed by addition of an error, permutes the ring.
-/

open Finset BigOperators

noncomputable section

namespace LWEOperational

/-- A probability mass function on a finite transcript space. -/
structure FinitePMF (Ω : Type*) [Fintype Ω] where
  mass : Ω → ℝ
  nonneg : ∀ x, 0 ≤ mass x
  sum_mass : ∑ x, mass x = 1

/-- The `ℓ¹` gap between two finite experiments. -/
def l1Gap {Ω : Type*} [Fintype Ω] (P Q : FinitePMF Ω) : ℝ :=
  ∑ x, |P.mass x - Q.mass x|

/-- The two challenge ensembles of an encryption experiment. -/
structure EncryptionExperiment (Ω : Type*) [Fintype Ω] where
  challenge : Bool → FinitePMF Ω

/-- The standard common-ideal game hop. -/
theorem gap_of_common_ideal {Ω : Type*} [Fintype Ω]
    (E : EncryptionExperiment Ω) (ideal : FinitePMF Ω) (ε₀ ε₁ : ℝ)
    (hzero : l1Gap (E.challenge false) ideal ≤ ε₀)
    (hone : l1Gap (E.challenge true) ideal ≤ ε₁) :
    l1Gap (E.challenge false) (E.challenge true) ≤ ε₀ + ε₁ := by
  simp_rw [l1Gap] at *
  have h₁ : ∑ x, |(E.challenge false).mass x - ideal.mass x| ≤ ε₀ := hzero
  have h₂ : ∑ x, |(E.challenge true).mass x - ideal.mass x| ≤ ε₁ := hone
  refine le_trans ?_ (add_le_add h₁ h₂)
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro a _
  have h := abs_add_le ((E.challenge false).mass a - ideal.mass a)
    (ideal.mass a - (E.challenge true).mass a)
  convert h using 2 <;> [ring_nf; rw [abs_sub_comm]]

/-- The expectation of a real-valued test in a finite experiment. -/
def expectation {Ω : Type*} [Fintype Ω] (P : FinitePMF Ω) (test : Ω → ℝ) : ℝ :=
  ∑ x, P.mass x * test x

/-- **Operational meaning of the LWE hybrid distance.** Every test taking values
in `[0,1]` has distinguishing advantage at most the `ℓ¹` gap. -/
theorem expectation_sub_le_l1Gap {Ω : Type*} [Fintype Ω]
    (P Q : FinitePMF Ω) (test : Ω → ℝ)
    (htest : ∀ x, 0 ≤ test x ∧ test x ≤ 1) :
    |expectation P test - expectation Q test| ≤ l1Gap P Q := by
  rw [expectation, expectation, l1Gap, ← Finset.sum_sub_distrib]
  calc
    |∑ x, (P.mass x * test x - Q.mass x * test x)|
        ≤ ∑ x, |P.mass x * test x - Q.mass x * test x| :=
          Finset.abs_sum_le_sum_abs _ _
    _ = ∑ x, |P.mass x - Q.mass x| * |test x| := by
          apply Finset.sum_congr rfl
          intro x _
          rw [← abs_mul]
          congr 1
          ring
    _ ≤ ∑ x, |P.mass x - Q.mass x| := by
          apply Finset.sum_le_sum
          intro x _
          rw [abs_of_nonneg (htest x).1]
          exact mul_le_of_le_one_right (abs_nonneg _) (htest x).2

/-- A deterministic Boolean adversary's acceptance-probability advantage is
bounded by the `ℓ¹` gap between its two input ensembles. -/
theorem boolean_distinguisher_advantage {Ω : Type*} [Fintype Ω]
    (P Q : FinitePMF Ω) (adversary : Ω → Bool) :
    |(∑ x with adversary x = true, P.mass x) -
      (∑ x with adversary x = true, Q.mass x)| ≤ l1Gap P Q := by
  let test : Ω → ℝ := fun x => if adversary x = true then 1 else 0
  have htest : ∀ x, 0 ≤ test x ∧ test x ≤ 1 := by
    intro x
    simp only [test]
    split_ifs <;> norm_num
  have h := expectation_sub_le_l1Gap P Q test htest
  simpa [expectation, test, Finset.sum_filter] using h

/-- Consequently, the common-ideal LWE game hop bounds every deterministic
Boolean IND-CPA adversary by the sum of the two replacement errors. -/
theorem boolean_advantage_of_common_ideal {Ω : Type*} [Fintype Ω]
    (E : EncryptionExperiment Ω) (ideal : FinitePMF Ω) (ε₀ ε₁ : ℝ)
    (hzero : l1Gap (E.challenge false) ideal ≤ ε₀)
    (hone : l1Gap (E.challenge true) ideal ≤ ε₁)
    (adversary : Ω → Bool) :
    |(∑ x with adversary x = true, (E.challenge false).mass x) -
      (∑ x with adversary x = true, (E.challenge true).mass x)| ≤ ε₀ + ε₁ := by
  exact (boolean_distinguisher_advantage
    (E.challenge false) (E.challenge true) adversary).trans
      (gap_of_common_ideal E ideal ε₀ ε₁ hzero hone)

end LWEOperational

namespace RingLWE

variable {R : Type*} [CommRing R]

/-- Multiplication by a unit is a permutation of every finite commutative ring. -/
theorem mul_bijective_of_isUnit (a : R) (ha : IsUnit a) :
    Function.Bijective (fun x : R => a * x) := by
  obtain ⟨u, hu⟩ := ha
  rw [← hu]
  exact u.mulLeft_bijective

/-- **Ring-LWE affine uniformity.** For a unit public multiplier `a`, adding any
fixed error `e` after multiplication preserves the uniform distribution on the
finite ring, because `s ↦ a*s+e` is a permutation. -/
theorem affine_bijective_of_isUnit (a e : R) (ha : IsUnit a) :
    Function.Bijective (fun s : R => a * s + e) := by
  exact (AddGroup.addRight_bijective e).comp (mul_bijective_of_isUnit a ha)

/-- Summing a statistic over ring-LWE affine samples with a unit multiplier is
identical to summing it over the underlying ring. -/
theorem sum_affine_eq_of_isUnit [Fintype R] (a e : R) (ha : IsUnit a) (f : R → ℝ) :
    ∑ s, f (a * s + e) = ∑ y, f y := by
  exact Equiv.sum_comp (Equiv.ofBijective _ (affine_bijective_of_isUnit a e ha)) f

end RingLWE

end

#print axioms LWEOperational.expectation_sub_le_l1Gap
#print axioms LWEOperational.boolean_advantage_of_common_ideal
#print axioms RingLWE.sum_affine_eq_of_isUnit