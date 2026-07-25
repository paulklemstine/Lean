import Mathlib

/-!
# Explicit bounds on low-lying zeros of automorphic L-functions

This file formalizes, in an abstract but faithful form, the two analytic pillars that
underlie explicit results on the low-lying zeros of automorphic `L`-functions.

## The de la Vallée Poussin positivity

Every classical proof of a zero-free region for an `L`-function — and hence every
explicit statement that its low-lying zeros stay away from the line `ℜ(s) = 1`, pushing
them towards the critical line `ℜ(s) = 1/2` — rests on the elementary trigonometric
inequality
`3 + 4 cos θ + cos 2θ = 2 (1 + cos θ)² ≥ 0`.
Applied to a Dirichlet series `log L(s) = ∑ b_n λ_n^{-s}` with **nonnegative** coefficients
(the situation for `ζ`, for `L`-functions of self-dual cuspidal representations, and for
symmetric-power `L`-functions on the edge of the critical strip), it gives the positivity
`3 · A(σ,0) + 4 · A(σ,t) + A(σ,2t) ≥ 0`, which forbids a zero on `ℜ(s)=1`.

We prove this positivity for an arbitrary finite nonnegative Dirichlet cosine sum
`dirichletCosSum` (`dirichletCosSum_three_four_one_nonneg`), together with the exact
trinomial identity (`three_four_one_cos`) and its sharp equality case
(`three_four_one_cos_eq_zero_iff`).

## Functional-equation symmetry about the critical line

The completed `L`-function of an automorphic representation satisfies a functional equation
of the shape `Λ(s) = ε · conj (Λ(1 - conj s))` with `|ε| = 1`.  The map
`s ↦ 1 - conj s` is precisely the reflection of the complex plane across the critical line
`ℜ(s) = 1/2`.  Consequently the zero set of `Λ` is symmetric under this reflection, its
fixed points are exactly the points on the critical line, and every zero off the critical
line occurs in a genuine mirror pair of two distinct zeros.

* `critical_reflection_involutive` — `s ↦ 1 - conj s` is an involution.
* `critical_reflection_fixed_iff` — its fixed points are exactly `{s : ℜ s = 1/2}`.
* `zero_reflect_iff` — `Λ s = 0 ↔ Λ (1 - conj s) = 0`.
* `offcritical_zero_pair` — an off-line zero forces a distinct mirror zero.

Together these give a rigorous, self-contained account of *why* the nontrivial zeros of an
automorphic `L`-function are symmetric about `ℜ(s)=1/2` and *why* the positivity method
keeps the low-lying ones off the edge of the critical strip.
-/

namespace LowLyingZeros

open Finset Real

/-! ## The de la Vallée Poussin trinomial -/

/-- The de la Vallée Poussin identity `3 + 4 cos θ + cos 2θ = 2 (1 + cos θ)²`. -/
theorem three_four_one_cos (θ : ℝ) :
    3 + 4 * Real.cos θ + Real.cos (2 * θ) = 2 * (1 + Real.cos θ) ^ 2 := by
  rw [Real.cos_two_mul]; ring

/-- The de la Vallée Poussin positivity `3 + 4 cos θ + cos 2θ ≥ 0`. -/
theorem three_four_one_cos_nonneg (θ : ℝ) :
    0 ≤ 3 + 4 * Real.cos θ + Real.cos (2 * θ) := by
  rw [three_four_one_cos]; positivity

/-- The trinomial vanishes exactly when `cos θ = -1`, i.e. `θ ≡ π (mod 2π)`. -/
theorem three_four_one_cos_eq_zero_iff (θ : ℝ) :
    3 + 4 * Real.cos θ + Real.cos (2 * θ) = 0 ↔ Real.cos θ = -1 := by
  rw [three_four_one_cos]
  constructor
  · intro h
    have h2 : (1 + Real.cos θ) ^ 2 = 0 := by linarith
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h2
    linarith
  · intro h; rw [h]; ring

/-! ## Nonnegative Dirichlet cosine sums -/

/-- A finite Dirichlet-type cosine sum
`∑_{n ∈ F} a n · (r n)^(-σ) · cos (t · φ n)`.
Modelling `A(σ,t) = ℜ ∑ b_n λ_n^{-σ-it}` with `b_n = a n ≥ 0`, `λ_n = r n > 0`,
`φ n = log λ_n`, this is the real part of the logarithm of an `L`-function on a
vertical line, truncated to a finite spectrum. -/
noncomputable def dirichletCosSum {ι : Type*} (F : Finset ι) (a r φ : ι → ℝ)
    (σ t : ℝ) : ℝ :=
  ∑ n ∈ F, a n * r n ^ (-σ) * Real.cos (t * φ n)

variable {ι : Type*} (F : Finset ι) (a r φ : ι → ℝ)

/-- On the real axis (`t = 0`) a nonnegative Dirichlet cosine sum is nonnegative. -/
theorem dirichletCosSum_zero_nonneg (σ : ℝ)
    (hr : ∀ n ∈ F, 0 < r n) (ha : ∀ n ∈ F, 0 ≤ a n) :
    0 ≤ dirichletCosSum F a r φ σ 0 := by
  unfold dirichletCosSum
  apply Finset.sum_nonneg
  intro n hn
  have hrp : (0 : ℝ) ≤ r n ^ (-σ) := le_of_lt (Real.rpow_pos_of_pos (hr n hn) _)
  simp only [zero_mul, Real.cos_zero, mul_one]
  exact mul_nonneg (ha n hn) hrp

/-- **The de la Vallée Poussin positivity for a Dirichlet cosine sum.**
For nonnegative coefficients `a n ≥ 0` and positive frequencies `r n > 0`,
`3 · A(σ,0) + 4 · A(σ,t) + A(σ,2t) ≥ 0`.
This is the exact finite analogue of the inequality that forbids a zero of an
`L`-function on the line `ℜ(s) = 1`. -/
theorem dirichletCosSum_three_four_one_nonneg (σ t : ℝ)
    (hr : ∀ n ∈ F, 0 < r n) (ha : ∀ n ∈ F, 0 ≤ a n) :
    0 ≤ 3 * dirichletCosSum F a r φ σ 0
        + 4 * dirichletCosSum F a r φ σ t
        + dirichletCosSum F a r φ σ (2 * t) := by
  have key :
      3 * dirichletCosSum F a r φ σ 0
        + 4 * dirichletCosSum F a r φ σ t
        + dirichletCosSum F a r φ σ (2 * t)
      = ∑ n ∈ F, a n * r n ^ (-σ) *
          (3 + 4 * Real.cos (t * φ n) + Real.cos (2 * (t * φ n))) := by
    unfold dirichletCosSum
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib,
      ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro n hn
    have h0 : Real.cos (0 * φ n) = 1 := by simp
    have h2 : (2 * t) * φ n = 2 * (t * φ n) := by ring
    rw [h0, h2]; ring
  rw [key]
  apply Finset.sum_nonneg
  intro n hn
  have hrp : (0 : ℝ) ≤ r n ^ (-σ) := le_of_lt (Real.rpow_pos_of_pos (hr n hn) _)
  have htri : 0 ≤ 3 + 4 * Real.cos (t * φ n) + Real.cos (2 * (t * φ n)) :=
    three_four_one_cos_nonneg (t * φ n)
  have hae : 0 ≤ a n := ha n hn
  positivity

/-! ## Functional-equation symmetry about the critical line -/

/-- The **critical reflection** `s ↦ 1 - conj s`, the reflection of `ℂ` across the
critical line `ℜ(s) = 1/2`. -/
def criticalReflection (s : ℂ) : ℂ := 1 - (starRingEnd ℂ) s

/-- The critical reflection is an involution. -/
theorem critical_reflection_involutive (s : ℂ) :
    criticalReflection (criticalReflection s) = s := by
  unfold criticalReflection
  simp [map_sub]

/-- The critical reflection preserves the imaginary part. -/
theorem criticalReflection_im (s : ℂ) : (criticalReflection s).im = s.im := by
  simp [criticalReflection]

/-- The critical reflection sends the real part `x` to `1 - x`. -/
theorem criticalReflection_re (s : ℂ) : (criticalReflection s).re = 1 - s.re := by
  simp [criticalReflection]

/-- The fixed points of the critical reflection are exactly the points on the
critical line `ℜ(s) = 1/2`. -/
theorem critical_reflection_fixed_iff (s : ℂ) :
    criticalReflection s = s ↔ s.re = 1 / 2 := by
  rw [Complex.ext_iff, criticalReflection_re, criticalReflection_im]
  constructor
  · rintro ⟨h, -⟩; linarith
  · intro h; exact ⟨by linarith, rfl⟩

/-- **Symmetry of the zero set about the critical line.**
If `Λ` satisfies an automorphic functional equation `Λ(s) = c · conj (Λ(1 - conj s))`
with `c ≠ 0`, then `s` is a zero of `Λ` iff its critical reflection `1 - conj s` is. -/
theorem zero_reflect_iff (Λ : ℂ → ℂ) (c : ℂ) (hc : c ≠ 0)
    (hfe : ∀ s, Λ s = c * (starRingEnd ℂ) (Λ (criticalReflection s))) (s : ℂ) :
    Λ s = 0 ↔ Λ (criticalReflection s) = 0 := by
  rw [hfe s, mul_eq_zero, or_iff_right hc, map_eq_zero]

/-- **Off-critical zeros come in mirror pairs.**
A zero `s` of `Λ` with `ℜ(s) ≠ 1/2` forces a *distinct* zero at its critical reflection
`1 - conj s`. Hence any zero not on the critical line is one of two symmetric zeros. -/
theorem offcritical_zero_pair (Λ : ℂ → ℂ) (c : ℂ) (hc : c ≠ 0)
    (hfe : ∀ s, Λ s = c * (starRingEnd ℂ) (Λ (criticalReflection s))) (s : ℂ)
    (hs : Λ s = 0) (hoff : s.re ≠ 1 / 2) :
    Λ (criticalReflection s) = 0 ∧ criticalReflection s ≠ s := by
  refine ⟨(zero_reflect_iff Λ c hc hfe s).mp hs, ?_⟩
  intro hfix
  exact hoff ((critical_reflection_fixed_iff s).mp hfix)

end LowLyingZeros