/-
# A Cross-Domain Bridge: Fifth Roots of Unity ↔ Fibonacci and Lucas Numbers

This file establishes, in a fully self-contained way, the algebraic bridge that
underlies the study of `σ₅(n)`, the minimal absolute value of a non-vanishing sum
of `n` fifth roots of unity.

The key objects are the two *Gaussian periods* of the fifth cyclotomic field:

* `p ζ = ζ + ζ⁴`
* `q ζ = ζ² + ζ³`

for a primitive fifth root of unity `ζ`.  These are real quadratic irrationals and
are exactly the two roots of `x² + x - 1 = 0`, i.e. `{-φ, -ψ}` where `φ` is the golden
ratio and `ψ = goldenConj` its conjugate.  This is the bridge between:

* **fifth roots of unity** (cyclotomic / algebraic number theory), and
* **the golden ratio, Fibonacci and Lucas numbers** (combinatorial number theory).

Main results (all unconditional in the choice of primitive root `ζ`):

* `periods_sum_prod`  : `p ζ + q ζ = -1` and `p ζ * q ζ = -1`.
* `periods_golden`    : `{p ζ, q ζ} = {-φ, -ψ}`.
* `fifthRoots_lucas_bridge` : `(p ζ)^n + (q ζ)^n = (-1)^n · Lₙ`  (Lucas numbers).
* `fifthRoots_fib_bridge`   : `((p ζ)^n - (q ζ)^n)² = 5 · (Fₙ)²`  (Fibonacci numbers).
* `golden_ratio_is_modulus` : `{‖p ζ‖, ‖q ζ‖} = {φ, φ⁻¹}`, so the golden ratio is
  realized *exactly* as the modulus of a sum of two fifth roots of unity — and `φ⁻¹`
  is the minimal such modulus, which is precisely `σ₅(2)`.
* `sigma5_two` : `IsLeast {‖ζ^i + ζ^j‖ | i j} φ⁻¹`, a fully formal statement that `φ⁻¹`
  is the least modulus among *all* two-term sums of fifth roots of unity, i.e. the value
  `σ₅(2) = φ⁻¹`.

The full monotonicity / jump characterization of `σ₅(n)` (with jumps located at
`5Fₘ, Lₘ, 2Lₘ`) is discussed in `FUTURE_DIRECTIONS.md`; this file proves the exact
algebraic connection that makes Fibonacci and Lucas numbers appear in that problem.
-/
import Mathlib

open Real

namespace FifthRootsGolden

/-! ## Lucas numbers and their Binet formula -/

/-- The Lucas numbers `L₀ = 2, L₁ = 1, Lₙ₊₂ = Lₙ₊₁ + Lₙ`. -/
def lucas : ℕ → ℤ
  | 0 => 2
  | 1 => 1
  | (n + 2) => lucas (n + 1) + lucas n

/-- Binet's formula for the Lucas numbers: `Lₙ = φⁿ + ψⁿ`. -/
theorem lucas_binet (n : ℕ) : (lucas n : ℝ) = goldenRatio ^ n + goldenConj ^ n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => norm_num [lucas]
    | 1 => simp only [lucas, goldenRatio, goldenConj]; push_cast; ring
    | (k + 2) =>
      have h1 := ih (k + 1) (by omega)
      have h2 := ih k (by omega)
      have e1 : goldenRatio ^ 2 = goldenRatio + 1 := goldenRatio_sq
      have e2 : goldenConj ^ 2 = goldenConj + 1 := goldenConj_sq
      have hrec : lucas (k + 2) = lucas (k + 1) + lucas k := rfl
      rw [hrec]; push_cast [h1, h2]
      have g1 : goldenRatio ^ (k + 2) = goldenRatio ^ k * goldenRatio ^ 2 := by ring
      have g2 : goldenConj ^ (k + 2) = goldenConj ^ k * goldenConj ^ 2 := by ring
      rw [g1, g2, e1, e2]; ring

/-! ## The Gaussian periods of the fifth cyclotomic field -/

/-- The Gaussian period `p ζ = ζ + ζ⁴`. -/
noncomputable def p (ζ : ℂ) : ℂ := ζ + ζ ^ 4

/-- The Gaussian period `q ζ = ζ² + ζ³`. -/
noncomputable def q (ζ : ℂ) : ℂ := ζ ^ 2 + ζ ^ 3

/-- The two Gaussian periods have sum `-1` and product `-1`; hence each is a root of
`x² + x - 1 = 0`, the (negated) minimal polynomial of the golden ratio. -/
theorem periods_sum_prod (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) :
    p ζ + q ζ = -1 ∧ p ζ * q ζ = -1 := by
  have h5 : ζ ^ 5 = 1 := h.pow_eq_one
  have hsum : 1 + ζ + ζ ^ 2 + ζ ^ 3 + ζ ^ 4 = 0 := by
    have := h.geom_sum_eq_zero (by norm_num)
    simp [Finset.sum_range_succ] at this
    linear_combination this
  refine ⟨by simp only [p, q]; linear_combination hsum, ?_⟩
  simp only [p, q]; linear_combination hsum + (ζ + ζ ^ 2) * h5

/-- The set of Gaussian periods is exactly `{-φ, -ψ}`, giving the explicit bridge to
the golden ratio.  (Which period equals which root depends on the choice of `ζ`.) -/
theorem periods_golden (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) :
    (p ζ = -((goldenRatio : ℝ) : ℂ) ∧ q ζ = -((goldenConj : ℝ) : ℂ)) ∨
    (p ζ = -((goldenConj : ℝ) : ℂ) ∧ q ζ = -((goldenRatio : ℝ) : ℂ)) := by
  obtain ⟨hsum, hprod⟩ := periods_sum_prod ζ h
  set a : ℂ := ((goldenRatio : ℝ) : ℂ) with ha
  set b : ℂ := ((goldenConj : ℝ) : ℂ) with hb
  have hs : a + b = 1 := by
    rw [ha, hb, ← Complex.ofReal_add, goldenRatio_add_goldenConj]; norm_num
  have hproot : p ζ ^ 2 + p ζ - 1 = 0 := by
    have hq : q ζ = -1 - p ζ := by linear_combination hsum
    rw [hq] at hprod; linear_combination -hprod
  have hpval : p ζ = -a ∨ p ζ = -b := by
    have hp2 : a * b = -1 := by
      rw [ha, hb, ← Complex.ofReal_mul, goldenRatio_mul_goldenConj]; norm_num
    have factored : (p ζ + a) * (p ζ + b) = 0 := by
      have e : (p ζ + a) * (p ζ + b) = p ζ ^ 2 + p ζ - 1 := by
        linear_combination (p ζ) * hs + hp2
      rw [e, hproot]
    rcases mul_eq_zero.1 factored with h1 | h1
    · left; linear_combination h1
    · right; linear_combination h1
  have hqval : q ζ = -1 - p ζ := by linear_combination hsum
  rcases hpval with hp | hp
  · left; refine ⟨hp, ?_⟩; rw [hqval, hp]; linear_combination hs
  · right; refine ⟨hp, ?_⟩; rw [hqval, hp]; linear_combination hs

/-! ## The cross-domain bridge theorems -/

/-- **Lucas bridge.**  For any primitive fifth root of unity `ζ`, the symmetric power
sum of the two Gaussian periods is a signed Lucas number:
`(ζ + ζ⁴)ⁿ + (ζ² + ζ³)ⁿ = (-1)ⁿ · Lₙ`. -/
theorem fifthRoots_lucas_bridge (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) (n : ℕ) :
    (p ζ) ^ n + (q ζ) ^ n = (-1) ^ n * (lucas n : ℂ) := by
  have key : ((goldenRatio : ℝ) : ℂ) ^ n + ((goldenConj : ℝ) : ℂ) ^ n = (lucas n : ℂ) := by
    rw [← Complex.ofReal_pow, ← Complex.ofReal_pow, ← Complex.ofReal_add, ← lucas_binet]
    push_cast; ring
  rcases periods_golden ζ h with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · rw [h1, h2, neg_pow, neg_pow]; linear_combination ((-1 : ℂ)) ^ n * key
  · rw [h1, h2, neg_pow, neg_pow]; linear_combination ((-1 : ℂ)) ^ n * key

/-- **Fibonacci bridge.**  For any primitive fifth root of unity `ζ`, the square of the
antisymmetric power difference of the two Gaussian periods is `5 Fₙ²`:
`((ζ + ζ⁴)ⁿ - (ζ² + ζ³)ⁿ)² = 5 · Fₙ²`. -/
theorem fifthRoots_fib_bridge (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) (n : ℕ) :
    ((p ζ) ^ n - (q ζ) ^ n) ^ 2 = 5 * (Nat.fib n : ℂ) ^ 2 := by
  -- `φⁿ - ψⁿ = √5 · Fₙ`, hence `(φⁿ - ψⁿ)² = 5 Fₙ²` over `ℂ`.
  have key : (((goldenRatio : ℝ) : ℂ) ^ n - ((goldenConj : ℝ) : ℂ) ^ n) ^ 2
      = 5 * (Nat.fib n : ℂ) ^ 2 := by
    have hfib : goldenRatio ^ n - goldenConj ^ n = Real.sqrt 5 * (Nat.fib n : ℝ) := by
      have := Real.coe_fib_eq n
      field_simp at this ⊢
      linear_combination -this
    rw [← Complex.ofReal_pow, ← Complex.ofReal_pow, ← Complex.ofReal_sub, hfib]
    rw [Complex.ofReal_mul, mul_pow, ← Complex.ofReal_pow,
      Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 5)]
    push_cast; ring
  -- The square is symmetric under negating both periods.
  have hswap : ∀ x y : ℂ, ((-x) ^ n - (-y) ^ n) ^ 2 = (x ^ n - y ^ n) ^ 2 := by
    intro x y
    rw [neg_pow x n, neg_pow y n, ← mul_sub, mul_pow, ← pow_mul, mul_comm n 2, pow_mul,
      neg_one_sq, one_pow, one_mul]
  rcases periods_golden ζ h with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · rw [h1, h2, hswap]; exact key
  · rw [h1, h2, hswap,
      show (((goldenConj : ℝ) : ℂ) ^ n - ((goldenRatio : ℝ) : ℂ) ^ n) ^ 2
        = (((goldenRatio : ℝ) : ℂ) ^ n - ((goldenConj : ℝ) : ℂ) ^ n) ^ 2 by ring]
    exact key

/-! ## The golden ratio as a modulus of a sum of fifth roots of unity -/

/-- `|goldenConj| = φ⁻¹`. -/
theorem abs_goldenConj : |goldenConj| = goldenRatio⁻¹ := by
  have hneg : goldenConj < 0 := goldenConj_neg
  rw [abs_of_neg hneg]
  have h' : goldenRatio * (-goldenConj) = 1 := by linear_combination -goldenRatio_mul_goldenConj
  exact (inv_eq_of_mul_eq_one_right h').symm

/-- **Golden ratio modulus bridge.**  For any primitive fifth root of unity `ζ`, the two
Gaussian periods have moduli `{φ, φ⁻¹}`.  In particular the golden ratio is realized
exactly as the modulus of a sum of two fifth roots of unity, and the *smaller* value
`φ⁻¹` is `σ₅(2)`, the minimal modulus of a non-vanishing sum of two fifth roots of
unity. -/
theorem golden_ratio_is_modulus (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) :
    ({‖p ζ‖, ‖q ζ‖} : Set ℝ) = {goldenRatio, goldenRatio⁻¹} := by
  have hgr : (0 : ℝ) ≤ goldenRatio := le_of_lt goldenRatio_pos
  have hnormφ : ‖-((goldenRatio : ℝ) : ℂ)‖ = goldenRatio := by
    rw [norm_neg, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hgr]
  have hnormψ : ‖-((goldenConj : ℝ) : ℂ)‖ = goldenRatio⁻¹ := by
    rw [norm_neg, Complex.norm_real, Real.norm_eq_abs, abs_goldenConj]
  rcases periods_golden ζ h with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · rw [h1, h2, hnormφ, hnormψ]
  · rw [h1, h2, hnormφ, hnormψ, Set.pair_comm]

/-- Existential form of the bridge: the golden ratio is the modulus of a sum of two
fifth roots of unity. -/
theorem exists_fifthRoots_modulus_golden (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) :
    ‖p ζ‖ = goldenRatio ∨ ‖q ζ‖ = goldenRatio := by
  have hgr : (0 : ℝ) ≤ goldenRatio := le_of_lt goldenRatio_pos
  have hnormφ : ‖-((goldenRatio : ℝ) : ℂ)‖ = goldenRatio := by
    rw [norm_neg, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hgr]
  rcases periods_golden ζ h with ⟨h1, _⟩ | ⟨_, h2⟩
  · left; rw [h1, hnormφ]
  · right; rw [h2, hnormφ]

/-! ## `σ₅(2) = φ⁻¹`: the golden ratio inverse is the minimal two-term modulus -/

/-- For any primitive fifth root of unity `ζ` and any `e`, the real symmetric expression
`ζ^e + (ζ^e)^4 = ζ^e + conj(ζ^e) = 2·Re(ζ^e)` is one of the three values `2`, `p ζ`, `q ζ`
(according to `e mod 5`). This is the finite trichotomy underlying the two-term modulus. -/
theorem re_period (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) (e : ℕ) :
    ζ ^ e + (ζ ^ e) ^ 4 = 2 ∨ ζ ^ e + (ζ ^ e) ^ 4 = p ζ ∨ ζ ^ e + (ζ ^ e) ^ 4 = q ζ := by
  have h5 : ζ ^ 5 = 1 := h.pow_eq_one
  have hpow : ζ ^ e = ζ ^ (e % 5) := by
    conv_lhs => rw [← Nat.div_add_mod e 5]
    rw [pow_add, pow_mul, h5, one_pow, one_mul]
  rw [hpow]
  have hlt : e % 5 < 5 := Nat.mod_lt _ (by norm_num)
  interval_cases (e % 5)
  · left; norm_num
  · right; left; simp only [p]; ring
  · right; right; simp only [q]
    have he2 : (ζ ^ 2) ^ 4 = ζ ^ 3 := by
      have : (ζ ^ 2) ^ 4 = (ζ ^ 5) * ζ ^ 3 := by ring
      rw [this, h5, one_mul]
    rw [he2]
  · right; right; simp only [q]
    have he3 : (ζ ^ 3) ^ 4 = ζ ^ 2 := by
      have : (ζ ^ 3) ^ 4 = (ζ ^ 5) ^ 2 * ζ ^ 2 := by ring
      rw [this, h5, one_pow, one_mul]
    rw [he3]; ring
  · right; left; simp only [p]
    have he4 : (ζ ^ 4) ^ 4 = ζ := by
      have : (ζ ^ 4) ^ 4 = (ζ ^ 5) ^ 3 * ζ := by ring
      rw [this, h5, one_pow, one_mul]
    rw [he4]; ring

/-- **Lower bound for two-term sums.** The modulus of *any* two-term sum of fifth roots
of unity `ζ^i + ζ^j` is at least `φ⁻¹`. Since `5` is odd, such a sum can never vanish,
so `φ⁻¹` bounds the modulus of every (automatically non-vanishing) two-term sum. -/
theorem two_term_modulus_ge (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) (i j : ℕ) :
    goldenRatio⁻¹ ≤ ‖ζ ^ i + ζ ^ j‖ := by
  have h5 : ζ ^ 5 = 1 := h.pow_eq_one
  have hnorm : ‖ζ‖ = 1 := by
    have hn : ‖ζ‖ ^ 5 = 1 := by rw [← norm_pow, h5, norm_one]
    have hnn : (0 : ℝ) ≤ ‖ζ‖ := norm_nonneg ζ
    nlinarith [hn, hnn, sq_nonneg (‖ζ‖ - 1), pow_nonneg hnn 3, pow_nonneg hnn 4]
  have hns : Complex.normSq ζ = 1 := by
    have := Complex.normSq_eq_norm_sq ζ; rw [this, hnorm]; norm_num
  have hconj : (starRingEnd ℂ) ζ = ζ ^ 4 := by
    have hinv : ζ⁻¹ = (starRingEnd ℂ) ζ := by rw [Complex.inv_def, hns]; simp
    have hmul : ζ * ζ ^ 4 = 1 := by rw [← pow_succ']; exact h5
    rw [← hinv, inv_eq_of_mul_eq_one_right hmul]
  have hnsp : ∀ k : ℕ, Complex.normSq (ζ ^ k) = 1 := by
    intro k; rw [Complex.normSq_eq_norm_sq, norm_pow, hnorm]; simp
  have hcj : (starRingEnd ℂ) (ζ ^ j) = ζ ^ (4 * j) := by
    rw [map_pow, hconj, ← pow_mul, Nat.mul_comm]
  set e := i + 4 * j with he
  have hprod : ζ ^ i * (starRingEnd ℂ) (ζ ^ j) = ζ ^ e := by rw [hcj, ← pow_add]
  have hre : ((2 * (ζ ^ e).re : ℝ) : ℂ) = ζ ^ e + (ζ ^ e) ^ 4 := by
    have hc : (starRingEnd ℂ) (ζ ^ e) = (ζ ^ e) ^ 4 := by
      rw [map_pow, hconj, ← pow_mul, ← pow_mul, Nat.mul_comm 4 e]
    have hadd := Complex.add_conj (ζ ^ e)
    rw [hc] at hadd
    exact hadd.symm
  have hexp : Complex.normSq (ζ ^ i + ζ ^ j) = 2 + 2 * (ζ ^ e).re := by
    rw [Complex.normSq_add, hnsp, hnsp, hprod]; ring
  have hval := re_period ζ h e
  have key : (2 * (ζ ^ e).re : ℝ) = 2 ∨ (2 * (ζ ^ e).re : ℝ) = (p ζ).re ∨
      (2 * (ζ ^ e).re : ℝ) = (q ζ).re := by
    rcases hval with hh | hh | hh
    · left
      have hcast : ((2 * (ζ ^ e).re : ℝ) : ℂ) = 2 := by rw [hre, hh]
      exact_mod_cast hcast
    · right; left
      have hcast : ((2 * (ζ ^ e).re : ℝ) : ℂ) = p ζ := by rw [hre, hh]
      have := congrArg Complex.re hcast; simpa using this
    · right; right
      have hcast : ((2 * (ζ ^ e).re : ℝ) : ℂ) = q ζ := by rw [hre, hh]
      have := congrArg Complex.re hcast; simpa using this
  have hφ : (1 : ℝ) < goldenRatio := Real.one_lt_goldenRatio
  have hψ : goldenConj < 0 := Real.goldenConj_neg
  have hbound : 2 - goldenRatio ≤ Complex.normSq (ζ ^ i + ζ ^ j) := by
    rw [hexp]
    rcases periods_golden ζ h with ⟨hp, hq⟩ | ⟨hp, hq⟩ <;>
      rw [hp, hq] at key <;> simp only [Complex.neg_re, Complex.ofReal_re] at key <;>
      rcases key with k | k | k <;> rw [k] <;> nlinarith
  have hsq : (goldenRatio⁻¹) ^ 2 = 2 - goldenRatio := by
    have hg : goldenRatio ^ 2 = goldenRatio + 1 := Real.goldenRatio_sq
    have hprod1 : (2 - goldenRatio) * goldenRatio ^ 2 = 1 := by nlinarith [hg]
    rw [inv_pow]; exact inv_eq_of_mul_eq_one_left hprod1
  have hns2 : ‖ζ ^ i + ζ ^ j‖ ^ 2 = Complex.normSq (ζ ^ i + ζ ^ j) := by
    rw [Complex.normSq_eq_norm_sq]
  have hsqle : (goldenRatio⁻¹) ^ 2 ≤ ‖ζ ^ i + ζ ^ j‖ ^ 2 := by rw [hsq, hns2]; exact hbound
  have hnn : (0 : ℝ) ≤ goldenRatio⁻¹ := by positivity
  calc goldenRatio⁻¹ = Real.sqrt ((goldenRatio⁻¹) ^ 2) := (Real.sqrt_sq hnn).symm
    _ ≤ Real.sqrt (‖ζ ^ i + ζ ^ j‖ ^ 2) := Real.sqrt_le_sqrt hsqle
    _ = ‖ζ ^ i + ζ ^ j‖ := Real.sqrt_sq (norm_nonneg _)

/-- The value `φ⁻¹` is attained as the modulus of a concrete two-term sum: one of the two
Gaussian periods has modulus exactly `φ⁻¹`. -/
theorem exists_two_term_modulus_golden_inv (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) :
    ‖p ζ‖ = goldenRatio⁻¹ ∨ ‖q ζ‖ = goldenRatio⁻¹ := by
  have hnormψ : ‖-((goldenConj : ℝ) : ℂ)‖ = goldenRatio⁻¹ := by
    rw [norm_neg, Complex.norm_real, Real.norm_eq_abs, abs_goldenConj]
  rcases periods_golden ζ h with ⟨_, h2⟩ | ⟨h1, _⟩
  · right; rw [h2, hnormψ]
  · left; rw [h1, hnormψ]

/-- **`σ₅(2) = φ⁻¹`.** The inverse golden ratio `φ⁻¹` is the *least* modulus among all
two-term sums of fifth roots of unity: it is attained (by a Gaussian period) and is a
lower bound for every two-term sum. This is exactly `σ₅(2)`, the minimal modulus of a
non-vanishing sum of two fifth roots of unity. -/
theorem sigma5_two (ζ : ℂ) (h : IsPrimitiveRoot ζ 5) :
    IsLeast {r : ℝ | ∃ i j : ℕ, ‖ζ ^ i + ζ ^ j‖ = r} goldenRatio⁻¹ := by
  constructor
  · rcases exists_two_term_modulus_golden_inv ζ h with hp | hq
    · exact ⟨1, 4, by rw [pow_one]; exact hp⟩
    · exact ⟨2, 3, hq⟩
  · rintro r ⟨i, j, rfl⟩
    exact two_term_modulus_ge ζ h i j

/-! ## Non-vacuity: a concrete primitive fifth root of unity -/

/-- The canonical primitive fifth root of unity `exp(2πi/5)`. -/
noncomputable def zeta5 : ℂ := Complex.exp (2 * ↑Real.pi * Complex.I / 5)

theorem zeta5_isPrimitiveRoot : IsPrimitiveRoot zeta5 5 := by
  have := Complex.isPrimitiveRoot_exp 5 (by norm_num)
  simpa [zeta5] using this

/-- A concrete instance of the Lucas bridge for the canonical root, witnessing that the
bridge theorems are not vacuous. -/
theorem zeta5_lucas_bridge (n : ℕ) :
    (p zeta5) ^ n + (q zeta5) ^ n = (-1) ^ n * (lucas n : ℂ) :=
  fifthRoots_lucas_bridge zeta5 zeta5_isPrimitiveRoot n

/-- A concrete instance of the golden-ratio modulus bridge for the canonical root. -/
theorem zeta5_modulus :
    ({‖p zeta5‖, ‖q zeta5‖} : Set ℝ) = {goldenRatio, goldenRatio⁻¹} :=
  golden_ratio_is_modulus zeta5 zeta5_isPrimitiveRoot

/-- A concrete instance of `σ₅(2) = φ⁻¹` for the canonical root. -/
theorem zeta5_sigma5_two :
    IsLeast {r : ℝ | ∃ i j : ℕ, ‖zeta5 ^ i + zeta5 ^ j‖ = r} goldenRatio⁻¹ :=
  sigma5_two zeta5 zeta5_isPrimitiveRoot

end FifthRootsGolden