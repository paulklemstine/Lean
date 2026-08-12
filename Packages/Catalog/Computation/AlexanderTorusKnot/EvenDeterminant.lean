/-
# Cycle 8: the determinant of a torus knot always returns a *parameter*, never a factor

Cycle 7 computed the knot determinant `|Δ_{a,b}(-1)|` in the two extreme cases: both
parameters odd (determinant `1`) and the catalog pencil `T(2,N)` (determinant `N`). This
cycle closes the remaining case — one parameter even — and does so by a completely
different, purely algebraic route that replaces the strong induction on `Φ_n(-1)` by a
single cancellation in `ℤ[X]`:

  `Δ_{a,b} · (X^a - 1) = (∑_{i < a} X^{b i}) · (X - 1)`  (`torusAlexander_mul_geom`).

Evaluating at `-1` with `a` odd immediately gives `Δ_{a,b}(-1) = ∑_{i<a} (-1)^{b i}`, hence

* `torusAlexander_eval_neg_one`  : `Δ_{a,b}(-1) = a` if `b` is even, `= 1` if `b` is odd;
* `torusAlexander_comm`          : `Δ_{a,b} = Δ_{b,a}` (the spectrum is symmetric);
* `torus_determinant_trichotomy` : for coprime positive `a, b` the determinant of `T(a,b)`
  is `1` (both odd), `a` (`a` odd, `b` even) or `b` (`a` even, `b` odd).

**The sharpened "catch".** The determinant is the one invariant of `T(a,b)` that is cheap to
evaluate, and `torus_determinant_neg` records what it costs us: the value is always one of
the two *given* parameters, never a nontrivial divisor of `ab`. All factorization content of
the knot therefore lives in the divisor spectrum (Cycles 1–4), not in any point evaluation.
-/
import Computation.AlexanderTorusKnot.Determinant

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-- The spectrum is symmetric in its two arguments. -/
lemma spectrum_comm (a b : ℕ) : spectrum a b = spectrum b a := by
  ext d
  simp only [mem_spectrum, mul_comm a b]
  tauto

/-- `T(a,b)` and `T(b,a)` are the same knot, and have the same Alexander polynomial. -/
theorem torusAlexander_comm (a b : ℕ) : torusAlexander a b = torusAlexander b a := by
  rw [torusAlexander, torusAlexander, spectrum_comm]

/-- **The cancelled form of the defining identity.** For coprime positive `a, b`,
`Δ_{a,b} · (X^a - 1) = (∑_{i<a} X^{b i}) · (X - 1)`; the factor `X^b - 1` present on both
sides of `torusAlexander_spec` has been removed. -/
theorem torusAlexander_mul_geom {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    torusAlexander a b * (X ^ a - 1 : ℤ[X])
      = (∑ i ∈ Finset.range a, (X : ℤ[X]) ^ (b * i)) * (X - 1) := by
  have hgeom : (∑ i ∈ Finset.range a, (X : ℤ[X]) ^ (b * i)) * ((X : ℤ[X]) ^ b - 1)
      = (X : ℤ[X]) ^ (a * b) - 1 := by
    have := geom_sum_mul ((X : ℤ[X]) ^ b) a
    simp only [← pow_mul] at this
    rw [show a * b = b * a from mul_comm a b]
    simpa [mul_comm] using this
  have hne : ((X : ℤ[X]) ^ b - 1) ≠ 0 := by
    intro h
    have := congrArg (Polynomial.eval (0 : ℤ)) h
    simp [zero_pow hb.ne'] at this
  have hspec := torusAlexander_spec hab ha hb
  refine mul_right_cancel₀ hne ?_
  calc torusAlexander a b * (X ^ a - 1 : ℤ[X]) * ((X : ℤ[X]) ^ b - 1)
      = torusAlexander a b * ((X ^ a - 1) * (X ^ b - 1)) := by ring
    _ = (X ^ (a * b) - 1 : ℤ[X]) * (X - 1) := hspec.symm
    _ = (∑ i ∈ Finset.range a, (X : ℤ[X]) ^ (b * i)) * ((X : ℤ[X]) ^ b - 1) * (X - 1) := by
          rw [hgeom]
    _ = (∑ i ∈ Finset.range a, (X : ℤ[X]) ^ (b * i)) * (X - 1) * ((X : ℤ[X]) ^ b - 1) := by
          ring

/-- With `a` odd, the determinant of `T(a,b)` is the character sum `∑_{i<a} (-1)^{b i}`. -/
theorem torusAlexander_eval_neg_one_sum {a b : ℕ} (hab : Nat.Coprime a b) (ha : Odd a)
    (hb : 0 < b) :
    (torusAlexander a b).eval (-1) = ∑ i ∈ Finset.range a, (-1 : ℤ) ^ (b * i) := by
  have hapos : 0 < a := ha.pos
  have h := congrArg (Polynomial.eval (-1 : ℤ)) (torusAlexander_mul_geom hab hapos hb)
  simp only [eval_mul, eval_sub, eval_pow, eval_X, eval_one, eval_finset_sum] at h
  rw [ha.neg_one_pow] at h
  have h2 : (-1 : ℤ) - 1 = -2 := by norm_num
  rw [h2] at h
  exact mul_right_cancel₀ (show (-2 : ℤ) ≠ 0 by norm_num) h

/-- **The determinant of a torus knot.** For coprime positive `a, b` with `a` odd,
`Δ_{a,b}(-1) = a` when `b` is even and `= 1` when `b` is odd. -/
theorem torusAlexander_eval_neg_one {a b : ℕ} (hab : Nat.Coprime a b) (ha : Odd a) (hb : 0 < b) :
    (torusAlexander a b).eval (-1) = if Even b then (a : ℤ) else 1 := by
  rw [torusAlexander_eval_neg_one_sum hab ha hb]
  by_cases hbe : Even b
  · simp only [hbe, if_true]
    have : ∀ i ∈ Finset.range a, (-1 : ℤ) ^ (b * i) = 1 := by
      intro i _
      exact (hbe.mul_right i).neg_one_pow
    rw [Finset.sum_congr rfl this]
    simp
  · simp only [hbe, if_false]
    have hbo : Odd b := Nat.odd_iff.2 (Nat.not_even_iff.1 hbe)
    have : ∀ i ∈ Finset.range a, (-1 : ℤ) ^ (b * i) = (-1 : ℤ) ^ i := by
      intro i _
      rw [pow_mul]
      rw [hbo.neg_one_pow]
    rw [Finset.sum_congr rfl this, neg_one_geom_sum]
    simp [Nat.not_even_iff_odd.2 ha]

/-- **Even parameter: the determinant is the odd parameter.** -/
theorem torusAlexander_det_even {a b : ℕ} (hab : Nat.Coprime a b) (ha : Odd a) (hb : Even b)
    (hbpos : 0 < b) : (torusAlexander a b).eval (-1) = (a : ℤ) := by
  rw [torusAlexander_eval_neg_one hab ha hbpos, if_pos hb]

/-- **Trichotomy for the knot determinant of `T(a,b)`.** For coprime positive parameters, the
determinant is `1` if both are odd, and otherwise equals whichever parameter is odd. -/
theorem torus_determinant_trichotomy {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    (torusAlexander a b).eval (-1) = 1 ∨ (torusAlexander a b).eval (-1) = (a : ℤ) ∨
      (torusAlexander a b).eval (-1) = (b : ℤ) := by
  rcases Nat.even_or_odd a with hae | hao
  · -- `a` even forces `b` odd by coprimality
    have hbo : Odd b := by
      rcases Nat.even_or_odd b with hbe | hbo
      · exfalso
        have h2 : (2 : ℕ) ∣ Nat.gcd a b :=
          Nat.dvd_gcd hae.two_dvd hbe.two_dvd
        rw [Nat.Coprime] at hab
        rw [hab] at h2
        omega
      · exact hbo
    rw [torusAlexander_comm]
    right; right
    exact torusAlexander_det_even hab.symm hbo hae ha
  · rcases Nat.even_or_odd b with hbe | hbo
    · exact Or.inr (Or.inl (torusAlexander_det_even hab hao hbe hb))
    · left
      exact torusAlexander_eval_neg_one_odd hao hbo

/-- **The determinant never sees a nontrivial factor.** If `a, b > 1` are coprime, the
determinant of `T(a,b)` is one of `1, a, b` — never a proper divisor of `ab` other than the
two given parameters. This is the sharpest form of the "catch" in the knot–number bridge:
the only cheaply computable invariant of the Alexander polynomial returns exactly the input
data. -/
theorem torus_determinant_no_new_factor {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a)
    (hb : 0 < b) :
    (torusAlexander a b).eval (-1) ∈ ({1, (a : ℤ), (b : ℤ)} : Set ℤ) := by
  rcases torus_determinant_trichotomy hab ha hb with h | h | h
  · exact Or.inl h
  · exact Or.inr (Or.inl h)
  · exact Or.inr (Or.inr h)

/-! ## Lab notes: determinants of small torus knots

`det T(3,2) = 3` (trefoil), `det T(5,2) = 5` (cinquefoil), `det T(7,2) = 7`, while
`det T(3,5) = det T(3,7) = 1`: the two-odd-parameter knots are invisible to the determinant.
-/

example : (torusAlexander 3 2).eval (-1) = 3 :=
  torusAlexander_det_even (by decide) (by decide) (by decide) (by norm_num)

example : (torusAlexander 5 2).eval (-1) = 5 :=
  torusAlexander_det_even (by decide) (by decide) (by decide) (by norm_num)

example : (torusAlexander 7 2).eval (-1) = 7 :=
  torusAlexander_det_even (by decide) (by decide) (by decide) (by norm_num)

example : (torusAlexander 3 5).eval (-1) = 1 :=
  torusAlexander_eval_neg_one_odd (by decide) (by decide)

example : (torusAlexander 3 7).eval (-1) = 1 :=
  torusAlexander_eval_neg_one_odd (by decide) (by decide)

end Computation.AlexanderTorusKnot