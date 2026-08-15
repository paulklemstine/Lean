/-
# Odd cyclic orders above the one-bit cap

The exact-value files show the type-pair channel `Ipair n` breaking the one-bit
binary-fork cap at `n = 4, 6, 8, 10, 12, 16`, and staying below it at the odd
orders `3, 5, 9, 15` (`odd_orders_below_cap`).  That coincidence suggested that
the order-two element of the cyclic group is what pushes the channel above the
cap.  This file **refutes** that reading:

`one_lt_Ipair_odd_order` exhibits an explicit **odd** cyclic order

  `M = 9 · 5 · 7 · 11 · 13 · 17 · 19 · 23 · 29 · 31 = 300840735195`

with `1 < Ipair M`.  So the cap is broken by odd orders too; evenness is not the
mechanism.  What *is* the mechanism is CRT additivity (`Ipair_mul_of_coprime`)
together with the fact that every prime-order channel is strictly positive: the
channel of a squarefree-ish odd order is a *sum* of small positive prime
contributions.  The accumulation is *tight*: the prime-order values decay like
`Ipair p ≈ (log₂ p + 2/ln 2)/p²`, so the total over all odd prime powers
converges (numerically to `≈ 1.084`), and the ten primary parts used here
already give `1.0052…` — no odd order can exceed `1.09`, and only a long tail of
primes gets past `1` at all.

The proof is a chain of three ingredients, all already formal:

* `Ipair_prime` — the closed form for a prime cyclic order;
* `Ipair_val_9` — the exact value of the prime-power order `9`;
* `Ipair_mul_of_coprime` — CRT additivity.

Each prime contribution is bounded below by an explicit rational number obtained
from integer inequalities `2 ^ a ≤ x ^ 4096` and `x ^ 4096 ≤ 2 ^ c`
(`logb_ge_of_pow_le`, `logb_le_of_le_pow`); summing the ten bounds gives
`Ipair M ≥ 1.0052… > 1`.
-/
import Shared.CyclicTypeChannelPrime

namespace CyclicTypeChannel

set_option exponentiation.threshold 100000

/-! ## 1. Rational bounds for binary logarithms -/

/-- If `2 ^ a ≤ x ^ b` then `a / b ≤ log₂ x`: a rational lower bound for a binary
logarithm, certified by an integer inequality. -/
lemma logb_ge_of_pow_le {x : ℝ} (hx : 0 < x) {a b : ℕ} (hb : 0 < b)
    (h : (2 : ℝ) ^ a ≤ x ^ b) : (a : ℝ) / (b : ℝ) ≤ Real.logb 2 x := by
  have h1 : Real.logb 2 ((2 : ℝ) ^ a) ≤ Real.logb 2 (x ^ b) :=
    (Real.logb_le_logb (by norm_num) (by positivity) (by positivity)).2 h
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num)] at h1
  have hb' : (0 : ℝ) < (b : ℝ) := by exact_mod_cast hb
  rw [div_le_iff₀ hb']
  nlinarith [h1]

/-- If `x ^ b ≤ 2 ^ a` then `log₂ x ≤ a / b`. -/
lemma logb_le_of_le_pow {x : ℝ} (hx : 0 < x) {a b : ℕ} (hb : 0 < b)
    (h : x ^ b ≤ (2 : ℝ) ^ a) : Real.logb 2 x ≤ (a : ℝ) / (b : ℝ) := by
  have h1 : Real.logb 2 (x ^ b) ≤ Real.logb 2 ((2 : ℝ) ^ a) :=
    (Real.logb_le_logb (by norm_num) (by positivity) (by positivity)).2 h
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num)] at h1
  have hb' : (0 : ℝ) < (b : ℝ) := by exact_mod_cast hb
  rw [le_div_iff₀ hb']
  nlinarith [h1]

/-! ## 2. Explicit rational lower bounds for the odd prime-order channels

Each bound is the closed form `Ipair_prime` evaluated with the two-sided
rational bounds of Section 1 at denominator `4096`. -/

/-- A rational lower bound for the prime-power value `Ipair 9 = -100/81 + (10/9) log₂ 3`. -/
lemma Ipair_lb_nine : (21835 / 41472 : ℝ) ≤ Ipair 9 := by
  have h3 : ((6492 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 3 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h3
  rw [Ipair_val_9]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 5`. -/
lemma Ipair_lb_five : (10371 / 51200 : ℝ) ≤ Ipair 5 := by
  have h := Ipair_prime (p := 5) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((9510 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 5 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 4 ≤ ((8192 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((6492 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 3 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 7`. -/
lemma Ipair_lb_seven : (2845 / 25088 : ℝ) ≤ Ipair 7 := by
  have h := Ipair_prime (p := 7) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((11498 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 7 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 6 ≤ ((10589 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((9510 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 5 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 11`. -/
lemma Ipair_lb_eleven : (25539 / 495616 : ℝ) ≤ Ipair 11 := by
  have h := Ipair_prime (p := 11) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((14169 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 11 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 10 ≤ ((13607 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((12984 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 9 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 13`. -/
lemma Ipair_lb_thirteen : (26341 / 692224 : ℝ) ≤ Ipair 13 := by
  have h := Ipair_prime (p := 13) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((15157 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 13 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 12 ≤ ((14685 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((14169 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 11 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 17`. -/
lemma Ipair_lb_seventeen : (14083 / 591872 : ℝ) ≤ Ipair 17 := by
  have h := Ipair_prime (p := 17) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((16742 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 17 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 16 ≤ ((16384 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((16002 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 15 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 19`. -/
lemma Ipair_lb_nineteen : (28145 / 1478656 : ℝ) ≤ Ipair 19 := by
  have h := Ipair_prime (p := 19) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((17399 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 19 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 18 ≤ ((17081 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((16742 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 17 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 23`. -/
lemma Ipair_lb_twentythree : (3669 / 270848 : ℝ) ≤ Ipair 23 := by
  have h := Ipair_prime (p := 23) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((18528 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 23 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 22 ≤ ((18266 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((17990 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 21 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 29`. -/
lemma Ipair_lb_twentynine : (15619 / 1722368 : ℝ) ≤ Ipair 29 := by
  have h := Ipair_prime (p := 29) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((19898 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 29 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 28 ≤ ((19691 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((19476 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 27 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-- A rational lower bound for the prime-order value `Ipair 31`. -/
lemma Ipair_lb_thirtyone : (15351 / 1968128 : ℝ) ≤ Ipair 31 := by
  have h := Ipair_prime (p := 31) (by norm_num)
  push_cast at h
  norm_num at h
  have h1 : ((20292 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 31 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 30 ≤ ((20099 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) :=
    logb_le_of_le_pow (by norm_num) (by norm_num) (by norm_num)
  have h3 : ((19898 : ℕ) : ℝ) / ((4096 : ℕ) : ℝ) ≤ Real.logb 2 29 :=
    logb_ge_of_pow_le (by norm_num) (by norm_num) (by norm_num)
  push_cast at h1 h2 h3
  rw [h]
  linarith

/-! ## 3. An odd cyclic order above the one-bit cap -/

/-- **An odd cyclic order strictly above the one-bit binary-fork cap.**

`M = 9 · 5 · 7 · 11 · 13 · 17 · 19 · 23 · 29 · 31 = 300840735195`
is odd and satisfies `Ipair M > 1`.  Together with `odd_orders_below_cap` (all
small odd orders are below the cap) this shows the cap is broken by accumulating
enough odd primary parts, not by the presence of an order-two element. -/
theorem one_lt_Ipair_odd_order : 1 < Ipair 300840735195 := by
  have e45 : Ipair 45 = Ipair 9 + Ipair 5 := by
    rw [show (45 : ℕ) = 9 * 5 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have e315 : Ipair 315 = Ipair 45 + Ipair 7 := by
    rw [show (315 : ℕ) = 45 * 7 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have e3465 : Ipair 3465 = Ipair 315 + Ipair 11 := by
    rw [show (3465 : ℕ) = 315 * 11 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have e45045 : Ipair 45045 = Ipair 3465 + Ipair 13 := by
    rw [show (45045 : ℕ) = 3465 * 13 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have e765765 : Ipair 765765 = Ipair 45045 + Ipair 17 := by
    rw [show (765765 : ℕ) = 45045 * 17 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have e14549535 : Ipair 14549535 = Ipair 765765 + Ipair 19 := by
    rw [show (14549535 : ℕ) = 765765 * 19 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have e334639305 : Ipair 334639305 = Ipair 14549535 + Ipair 23 := by
    rw [show (334639305 : ℕ) = 14549535 * 23 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have e9704539845 : Ipair 9704539845 = Ipair 334639305 + Ipair 29 := by
    rw [show (9704539845 : ℕ) = 334639305 * 29 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have e300840735195 : Ipair 300840735195 = Ipair 9704539845 + Ipair 31 := by
    rw [show (300840735195 : ℕ) = 9704539845 * 31 from by norm_num]
    exact Ipair_mul_of_coprime (by norm_num) (by norm_num) (by norm_num)
  have b9 := Ipair_lb_nine
  have bfive := Ipair_lb_five
  have bseven := Ipair_lb_seven
  have beleven := Ipair_lb_eleven
  have bthirteen := Ipair_lb_thirteen
  have bseventeen := Ipair_lb_seventeen
  have bnineteen := Ipair_lb_nineteen
  have btwentythree := Ipair_lb_twentythree
  have btwentynine := Ipair_lb_twentynine
  have bthirtyone := Ipair_lb_thirtyone
  rw [e300840735195, e9704539845, e334639305, e14549535, e765765, e45045, e3465, e315, e45]
  linarith

/-- The above-cap phenomenon does not need an even cyclic order. -/
theorem exists_odd_order_above_cap : ∃ n : ℕ, Odd n ∧ 1 < Ipair n :=
  ⟨300840735195, Nat.odd_iff.2 (by norm_num), one_lt_Ipair_odd_order⟩

/-- The witness is composite with ten primary parts, consistent with
`above_cap_imp_not_prime`: no prime order can break the cap. -/
theorem odd_above_cap_not_prime : ¬ (300840735195 : ℕ).Prime :=
  above_cap_imp_not_prime one_lt_Ipair_odd_order

end CyclicTypeChannel