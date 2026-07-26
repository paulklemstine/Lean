import Mathlib

/-!
# The Mega-Sphere III (Deepening): the Bernoulli generating function and Faulhaber

This file deepens `MegaSphereBernoulli.lean`.  The "all dimensions at once"
principle for Bernoulli numbers is the **single exponential generating
function** `∑ₙ Bₙ xⁿ / n! = x / (eˣ − 1)`, which packages *every* Bernoulli
number into one power-series identity.  We record it (via Mathlib's
`bernoulliPowerSeries`) and extract consequences, together with a contrarian
disproof and a higher Faulhaber power sum.

Main results:

* `MegaSphereBernoulliDeep.mega_generating_function` — the mega identity
  `bernoulliPowerSeries ℚ * (exp ℚ − 1) = X`, the single object encoding all
  Bernoulli numbers simultaneously.
* `MegaSphereBernoulliDeep.bernoulli_one` — `B₁ = −1/2`.
* `MegaSphereBernoulliDeep.not_all_odd_bernoulli_vanish` — a **contrarian
  disproof**: the bold conjecture "*all odd-indexed Bernoulli numbers vanish*"
  is false, since `B₁ ≠ 0`.  (Only odd indices `≥ 3` vanish.)
* `MegaSphereBernoulliDeep.faulhaber_four` — the Bernoulli-driven closed form for
  `∑_{k<n} k⁴`.
* `MegaSphereBernoulliDeep.faulhaber_isPolynomial` — for every exponent `p`, the
  cumulative power sum `n ↦ ∑_{k<n} kᵖ` is given by a single polynomial in `n`
  (the strongest "all stages at once" shadow of Faulhaber).
-/

namespace MegaSphereBernoulliDeep

open Finset PowerSeries

/-! ## The mega generating function -/

/-- **The mega generating function.**  A single power-series identity encoding
all Bernoulli numbers at once: `(∑ₙ Bₙ Xⁿ / n!) · (eˣ − 1) = X`. -/
theorem mega_generating_function :
    bernoulliPowerSeries ℚ * (PowerSeries.exp ℚ - 1) = PowerSeries.X :=
  bernoulliPowerSeries_mul_exp_sub_one ℚ

/-! ## The contrarian disproof: odd Bernoulli numbers do not all vanish -/

/--
`B₁ = −1/2`.
-/
theorem bernoulli_one : bernoulli 1 = -1 / 2 := by
  convert _root_.bernoulli_one using 1

/--
**Contrarian disproof.**  The bold conjecture "*every odd-indexed Bernoulli
number is zero*" is **false**: `B₁ = −1/2 ≠ 0`.  (The correct statement is that
odd Bernoulli numbers vanish only from index `3` onward.)
-/
theorem not_all_odd_bernoulli_vanish :
    ¬ (∀ n : ℕ, Odd n → bernoulli n = 0) := by
  intro h
  have h1 : bernoulli 1 = 0 := h 1 odd_one
  rw [bernoulli_one] at h1
  norm_num at h1

/-! ## A higher Faulhaber power sum -/

/--
`B₄ = −1/30`.
-/
theorem bernoulli_four : bernoulli 4 = -1 / 30 := by
  have h3 : bernoulli 3 = 0 := by
    rw [bernoulli_eq_bernoulli'_of_ne_one (by omega),
      bernoulli'_eq_zero_of_odd ⟨1, by ring⟩ (by omega)]
  have h := sum_bernoulli 5
  simp [Finset.sum_range_succ, bernoulli_zero, bernoulli_two, h3,
    Nat.choose] at h
  linarith [h]

/-
**Faulhaber, `p = 4`.**  `∑_{k<n} k⁴ = (n-1)·n·(2n-1)·(3n²-3n-1)/30`, driven
by `B₀, B₁, B₂, B₃ = 0, B₄`.
-/
theorem faulhaber_four (n : ℕ) :
    ∑ k ∈ range n, (k : ℚ) ^ 4
      = (n - 1) * n * (2 * n - 1) * (3 * n ^ 2 - 3 * n - 1) / 30 := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-! ## Faulhaber is polynomial: one object for all stages -/

/-
**Faulhaber is polynomial.**  For every exponent `p` there is a *single*
polynomial `P` over `ℚ` such that the cumulative power sum at every stage `n` is
`P.eval n`: `∑_{k<n} kᵖ = P(n)`.  This is the sharpest "all dimensions at once"
form of Faulhaber's theorem — one algebraic object captures the lattice-point
count of every stage of the tower simultaneously.
-/
theorem faulhaber_isPolynomial (p : ℕ) :
    ∃ P : Polynomial ℚ, ∀ n : ℕ, ∑ k ∈ range n, (k : ℚ) ^ p = P.eval (n : ℚ) := by
  -- The sum of powers can be expressed as a polynomial in n. For example, the sum of the first n integers is n(n+1)/2, which is a polynomial.
  have h_sum_poly : ∃ P : Polynomial ℚ, ∀ n : ℕ, ∑ k ∈ Finset.range n, (k : ℚ) ^ p = P.eval (n : ℚ) := by
    have h_sum_formula : ∀ n : ℕ, ∑ k ∈ Finset.range n, (k : ℚ) ^ p = ∑ i ∈ Finset.range (p + 1), (bernoulli i : ℚ) * (p + 1).choose i * (n : ℚ) ^ (p + 1 - i) / (p + 1) := by
      have := @sum_range_pow;
      exact fun n => this n p
    use ∑ i ∈ Finset.range (p + 1), Polynomial.C ((bernoulli i : ℚ) * (p + 1).choose i / (p + 1)) * Polynomial.X ^ (p + 1 - i);
    simp_all +decide [ Polynomial.eval_finset_sum, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm ];
  exact h_sum_poly

end MegaSphereBernoulliDeep