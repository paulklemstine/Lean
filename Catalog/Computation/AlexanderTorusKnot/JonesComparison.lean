/-
# Cycle 11: Jones versus Alexander — the honest separation

Conjecture 2 of the research thread claimed that the Jones polynomial of `T(a,b)` determines
`{a,b}` from `O(1)` nonzero coefficients, whereas the Alexander polynomial spreads the same
information over `Θ(ab)` coefficients. The adversarial review of this cycle **refutes the
`O(1)` half** and proves the corrected statement.

Working with the normalized Jones polynomial (the classical
`V_{T(a,b)}(t) = t^{(a-1)(b-1)/2}(1 - t^{a+1} - t^{b+1} + t^{a+b})/(1-t²)` divided by its
monomial prefactor), we define for odd `a`

  `J_{a,b} = ∑_{k < (a+1)/2} X^{2k} - X^{b+1} ∑_{k < (a-1)/2} X^{2k}`

and prove

* `jones_spec`      : `(1 - X²)·J_{a,b} = 1 - X^{a+1} - X^{b+1} + X^{a+b}`, so `J` really is
  the quotient — the rational expression is an honest polynomial;
* `jones_symm`      : `J_{a,b} = J_{b,a}` for odd `a, b`, although the formula is not
  manifestly symmetric;
* `jones_eval_one`  : `J_{a,b}(1) = 1`, the classical normalization of the Jones polynomial;
* `jones_natDegree` : `deg J_{a,b} = a + b - 2`;
* `jones_alexander_recover` : `a + b = deg J + 2` and `a·b = deg Δ + deg J + 1`.

The last item is the real bridge: the *pair* of degrees `(deg Δ_{a,b}, deg J_{a,b})` is
equivalent to the pair `(a+b, ab)`, hence to `{a,b}` — a knot-theoretic Vieta. And the honest
separation between the two invariants is one of **degree**, `Θ(a+b)` against `Θ(ab)`, not of
support: `J_{5,7} = 1 + X² + X⁴ - X⁸ - X^{10}` already has `5` nonzero coefficients, and in
general `J_{a,b}` has `Θ(a)` of them. What is genuinely `O(1)` is the four-term *numerator*
`1 - X^{a+1} - X^{b+1} + X^{a+b}` — but the Alexander polynomial has an equally short
description `(X^{ab}-1)(X-1)/((X^a-1)(X^b-1))`, so no complexity separation survives.
-/
import Computation.AlexanderTorusKnot.Readout

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-- The four-term numerator of the Jones polynomial of `T(a,b)`. -/
noncomputable def jonesNum (a b : ℕ) : ℤ[X] := 1 - X ^ (a + 1) - X ^ (b + 1) + X ^ (a + b)

/-- The normalized Jones polynomial of the torus knot `T(a,b)` (for odd `a`), with the
monomial prefactor `t^{(a-1)(b-1)/2}` removed. -/
noncomputable def jones (a b : ℕ) : ℤ[X] :=
  (∑ k ∈ Finset.range ((a + 1) / 2), X ^ (2 * k))
    - X ^ (b + 1) * ∑ k ∈ Finset.range ((a - 1) / 2), X ^ (2 * k)

lemma geom_sq_mul (m : ℕ) :
    ((X : ℤ[X]) ^ 2 - 1) * ∑ k ∈ Finset.range m, X ^ (2 * k) = X ^ (2 * m) - 1 := by
  have h := geom_sum_mul ((X : ℤ[X]) ^ 2) m
  simp only [← pow_mul] at h
  rw [mul_comm]
  simpa [mul_comm 2] using h

/-- **The Jones polynomial is the quotient of its four-term numerator by `1 - X²`.** -/
theorem jones_spec {a b : ℕ} (ha : Odd a) :
    ((1 : ℤ[X]) - X ^ 2) * jones a b = jonesNum a b := by
  have h1 : 2 * ((a + 1) / 2) = a + 1 := by
    obtain ⟨m, rfl⟩ := ha; omega
  have h2 : 2 * ((a - 1) / 2) = a - 1 := by
    obtain ⟨m, rfl⟩ := ha; omega
  have hA := geom_sq_mul ((a + 1) / 2)
  have hB := geom_sq_mul ((a - 1) / 2)
  rw [h1] at hA
  rw [h2] at hB
  have hpow : (X : ℤ[X]) ^ (b + 1) * X ^ (a - 1) = X ^ (a + b) := by
    rw [← pow_add]
    congr 1
    obtain ⟨m, rfl⟩ := ha
    omega
  rw [jones, jonesNum]
  have hexp : ((1 : ℤ[X]) - X ^ 2) *
      ((∑ k ∈ Finset.range ((a + 1) / 2), X ^ (2 * k))
        - X ^ (b + 1) * ∑ k ∈ Finset.range ((a - 1) / 2), X ^ (2 * k))
      = -(((X : ℤ[X]) ^ 2 - 1) * ∑ k ∈ Finset.range ((a + 1) / 2), X ^ (2 * k))
        + X ^ (b + 1) * (((X : ℤ[X]) ^ 2 - 1) * ∑ k ∈ Finset.range ((a - 1) / 2), X ^ (2 * k)) := by
    ring
  rw [hexp, hA, hB]
  rw [mul_sub, hpow]
  ring

/-- The numerator is symmetric in `a` and `b`. -/
lemma jonesNum_comm (a b : ℕ) : jonesNum a b = jonesNum b a := by
  rw [jonesNum, jonesNum, Nat.add_comm a b]
  ring

/-- Although the defining formula is not symmetric, `J_{a,b} = J_{b,a}` for odd `a, b`. -/
theorem jones_symm {a b : ℕ} (ha : Odd a) (hb : Odd b) : jones a b = jones b a := by
  have hne : ((1 : ℤ[X]) - X ^ 2) ≠ 0 := by
    intro h
    have := congrArg (Polynomial.eval (0 : ℤ)) h
    simp at this
  refine mul_left_cancel₀ hne ?_
  rw [jones_spec ha, jones_spec hb, jonesNum_comm]

/-- The classical normalization `V_K(1) = 1` of the Jones polynomial. -/
theorem jones_eval_one {a b : ℕ} (ha : Odd a) : (jones a b).eval 1 = 1 := by
  obtain ⟨m, rfl⟩ := ha
  have h1 : (2 * m + 1 + 1) / 2 = m + 1 := by omega
  have h2 : (2 * m + 1 - 1) / 2 = m := by omega
  simp only [jones, h1, h2, eval_sub, eval_mul, eval_pow, eval_X, eval_finset_sum, one_pow,
    Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
  push_cast
  ring

lemma jonesNum_natDegree {a b : ℕ} (ha : 1 < a) (hb : 1 < b) :
    (jonesNum a b).natDegree = a + b := by
  have h1 : ¬(a = 0 ∧ b = 0) := by omega
  have h2 : b ≠ 1 := by omega
  have h3 : a + b ≠ b + 1 := by omega
  rw [jonesNum]
  compute_degree!
  · simp only [h1, h2, h3, if_false, Nat.cast_zero]
    decide
  · omega
  · omega
  · omega

/-- **The degree of the Jones polynomial of `T(a,b)` is `a + b - 2`** — linear in the
parameters, against the quadratic `(a-1)(b-1)` of the Alexander polynomial. -/
theorem jones_natDegree {a b : ℕ} (ha : Odd a) (ha1 : 1 < a) (hb : 1 < b) :
    (jones a b).natDegree = a + b - 2 := by
  have hspec := jones_spec (b := b) ha
  have hnum : (jonesNum a b).natDegree = a + b := jonesNum_natDegree ha1 hb
  have hnumne : jonesNum a b ≠ 0 := by
    intro h
    rw [h] at hnum
    simp at hnum
    omega
  have hJne : jones a b ≠ 0 := by
    intro h
    rw [h, mul_zero] at hspec
    exact hnumne hspec.symm
  have hfne : ((1 : ℤ[X]) - X ^ 2) ≠ 0 := by
    intro h
    have := congrArg (Polynomial.eval (0 : ℤ)) h
    simp at this
  have hfdeg : ((1 : ℤ[X]) - X ^ 2).natDegree = 2 := by
    compute_degree!
  have := congrArg Polynomial.natDegree hspec
  rw [Polynomial.natDegree_mul hfne hJne, hfdeg, hnum] at this
  omega

/-- **Knot-theoretic Vieta.** The two degrees `deg J_{a,b}` and `deg Δ_{a,b}` are equivalent
data to the elementary symmetric functions `a + b` and `a·b` of the torus-knot parameters,
hence determine `{a, b}` as the roots of `Y² - (a+b)Y + ab`. -/
theorem jones_alexander_recover {a b : ℕ} (hab : Nat.Coprime a b) (ha : Odd a) (ha1 : 1 < a)
    (hb : 1 < b) :
    a + b = (jones a b).natDegree + 2 ∧
      a * b = (torusAlexander a b).natDegree + (jones a b).natDegree + 1 := by
  have hJ : (jones a b).natDegree = a + b - 2 := jones_natDegree ha ha1 hb
  have hΔ : (torusAlexander a b).natDegree = (a - 1) * (b - 1) :=
    torusAlexander_natDegree hab (by omega) (by omega)
  have hprod : (a - 1) * (b - 1) = a * b - a - b + 1 := by
    obtain ⟨a₀, rfl⟩ : ∃ a₀, a = a₀ + 2 := ⟨a - 2, by omega⟩
    obtain ⟨b₀, rfl⟩ : ∃ b₀, b = b₀ + 2 := ⟨b - 2, by omega⟩
    have e1 : a₀ + 2 - 1 = a₀ + 1 := by omega
    have e2 : b₀ + 2 - 1 = b₀ + 1 := by omega
    have e3 : (a₀ + 1) * (b₀ + 1) = a₀ * b₀ + a₀ + b₀ + 1 := by ring
    have e4 : (a₀ + 2) * (b₀ + 2) = a₀ * b₀ + 2 * a₀ + 2 * b₀ + 4 := by ring
    rw [e1, e2, e3, e4]
    omega
  have hmn : a + b ≤ a * b := Nat.add_le_mul ha1 hb
  rw [hJ, hΔ, hprod]
  omega

/-! ## Lab notes: the Jones polynomial is *not* `O(1)`-sparse

`J_{5,7} = 1 + X² + X⁴ - X⁸ - X^{10}` has five nonzero coefficients, and the count grows
like `a`. The four-term object is the numerator, not the polynomial. -/

example : jones 5 7 = 1 + X ^ 2 + X ^ 4 - X ^ 8 - X ^ 10 := by
  simp [jones, Finset.sum_range_succ]
  ring

example : jones 3 2 = 1 + X ^ 2 - X ^ 3 := by
  simp [jones, Finset.sum_range_succ]

example : jones 3 5 = 1 + X ^ 2 - X ^ 6 := by
  simp [jones, Finset.sum_range_succ]

example : jones 7 9 = 1 + X ^ 2 + X ^ 4 + X ^ 6 - X ^ 10 - X ^ 12 - X ^ 14 := by
  simp [jones, Finset.sum_range_succ]
  ring

end Computation.AlexanderTorusKnot