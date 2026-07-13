import Mathlib

/-!
# Sharp dichotomy for the total d-Hoggatt numbers

The *total* d-Hoggatt numbers are `H_d(n) = ∑_k H_d(n,k)`.  Classical
identifications of the row sums of the d-Hoggatt triangle give
* `H_1(n) = 2 ^ n`   (row sums of Pascal's triangle),
* `H_2(n) = Cₙ`      (Catalan numbers, row sums of the Catalan / ballot triangle),
* `H_3(n)`           (Baxter numbers).

This file proves a **sharp dichotomy** between `d = 1` and `d = 2`:

* the `d = 1` totals `2 ^ n` are **log-linear** — `H(n+1)² = H(n)·H(n+2)`,
  hence log-concave *and* log-convex with equality, and in particular *not*
  strictly log-convex;
* the `d = 2` totals `Cₙ` are **strictly log-convex** — `H(n+1)² < H(n)·H(n+2)`
  — and *not* log-concave.

The engine behind the Catalan case is an exact *discriminant identity*
`(2n+1)(n+3)·Cₙ·Cₙ₊₂ = (n+2)(2n+3)·Cₙ₊₁²`, whose coefficients differ by the
positive constant `3`.  We also isolate the general mechanism as a
ratio-monotonicity criterion over `ℝ`, and record the "tropical / dequantized"
reformulation of log-convexity as strict convexity of `log` (equivalently strict
concavity of the valuation `v = -log a`), matching Conjecture 5 of the thread.
-/

namespace HoggattTotals

/-- A nonnegative integer sequence `a` is *strictly log-convex*:
`a(n+1)² < a(n)·a(n+2)` for all `n`. -/
def StrictLogConvex (a : ℕ → ℕ) : Prop := ∀ n, a (n + 1) ^ 2 < a n * a (n + 2)

/-- A nonnegative integer sequence `a` is *log-concave*:
`a(n)·a(n+2) ≤ a(n+1)²` for all `n`. -/
def LogConcave (a : ℕ → ℕ) : Prop := ∀ n, a n * a (n + 2) ≤ a (n + 1) ^ 2

/-- A nonnegative integer sequence `a` is *log-linear*:
`a(n+1)² = a(n)·a(n+2)` for all `n`. -/
def LogLinear (a : ℕ → ℕ) : Prop := ∀ n, a (n + 1) ^ 2 = a n * a (n + 2)

/-- A log-linear sequence is log-concave. -/
theorem LogLinear.logConcave {a : ℕ → ℕ} (h : LogLinear a) : LogConcave a := by
  intro n; rw [h n]

/-- A strictly log-convex sequence is never log-concave. -/
theorem StrictLogConvex.not_logConcave {a : ℕ → ℕ} (h : StrictLogConvex a) :
    ¬ LogConcave a := by
  intro hc
  have := h 0
  have := hc 0
  omega

/-! ## d = 1 : the totals `2 ^ n` are log-linear -/

/-
The `d = 1` totals `2 ^ n` are log-linear: `(2^{n+1})² = 2^n · 2^{n+2}`.
-/
theorem pow_two_logLinear : LogLinear (fun n => 2 ^ n) := by
  exact fun n => by ring;

/-- The `d = 1` totals `2 ^ n` are log-concave. -/
theorem pow_two_logConcave : LogConcave (fun n => 2 ^ n) :=
  pow_two_logLinear.logConcave

/-
The `d = 1` totals `2 ^ n` are *not* strictly log-convex.
-/
theorem pow_two_not_strictLogConvex : ¬ StrictLogConvex (fun n => 2 ^ n) := by
  intro h; specialize h 0; norm_num at h;

/-! ## d = 2 : the Catalan totals -/

/-
Positivity of Catalan numbers.
-/
theorem catalan_pos (n : ℕ) : 0 < catalan n := by
  rw [ catalan_eq_centralBinom_div ];
  exact Nat.div_pos ( Nat.le_of_dvd ( Nat.centralBinom_pos _ ) ( Nat.dvd_of_mod_eq_zero ( by rw [ Nat.mod_eq_zero_of_dvd ] ; simpa using Nat.succ_dvd_centralBinom n ) ) ) ( Nat.succ_pos _ )

/-
Multiplicative recurrence for Catalan numbers:
`(n+2)·Cₙ₊₁ = 2(2n+1)·Cₙ`.
-/
theorem catalan_rec (n : ℕ) :
    (n + 2) * catalan (n + 1) = 2 * (2 * n + 1) * catalan n := by
      convert Nat.mul_div_cancel' ( Nat.succ_dvd_centralBinom ( n + 1 ) ) using 1;
      · rw [ catalan_eq_centralBinom_div ];
      · rw [ catalan_eq_centralBinom_div ];
        nlinarith [ Nat.div_mul_cancel ( show n + 1 ∣ n.centralBinom from Nat.succ_dvd_centralBinom n ), Nat.succ_mul_centralBinom_succ n ]

/-
**Discriminant identity** for the Catalan totals:
`(2n+1)(n+3)·Cₙ·Cₙ₊₂ = (n+2)(2n+3)·Cₙ₊₁²`.
The two coefficients `(n+2)(2n+3) = 2n²+7n+6` and `(2n+1)(n+3) = 2n²+7n+3`
differ by the positive constant `3`, which is the source of strict
log-convexity.
-/
theorem catalan_discriminant (n : ℕ) :
    (2 * n + 1) * (n + 3) * (catalan n * catalan (n + 2))
      = (n + 2) * (2 * n + 3) * catalan (n + 1) ^ 2 := by
        grind +suggestions

/-
The `d = 2` totals (Catalan numbers) are **strictly log-convex**.
-/
theorem catalan_strictLogConvex : StrictLogConvex catalan := by
  intro n
  have := catalan_discriminant n
  have h_pos : 0 < catalan (n + 1) := catalan_pos (n + 1)
  nlinarith [h_pos, show 0 < (2 * n + 1) * (n + 3) by positivity]

/-- The `d = 2` totals (Catalan numbers) are *not* log-concave. -/
theorem catalan_not_logConcave : ¬ LogConcave catalan :=
  catalan_strictLogConvex.not_logConcave

/-! ## The sharp dichotomy -/

/-- **Sharp dichotomy `d = 1` vs `d = 2`.**
The `d = 1` totals `2 ^ n` are log-linear (hence log-concave, and not strictly
log-convex), while the `d = 2` totals `Cₙ` are strictly log-convex (hence not
log-concave). -/
theorem sharp_dichotomy :
    (LogLinear (fun n => 2 ^ n) ∧ ¬ StrictLogConvex (fun n => 2 ^ n)) ∧
    (StrictLogConvex catalan ∧ ¬ LogConcave catalan) :=
  ⟨⟨pow_two_logLinear, pow_two_not_strictLogConvex⟩,
   ⟨catalan_strictLogConvex, catalan_not_logConcave⟩⟩

/-! ## The general mechanism: ratio monotonicity -/

/-
**Ratio-monotonicity criterion** (Conjecture 2 mechanism).
A positive real sequence with strictly increasing consecutive ratios is strictly
log-convex.
-/
theorem strictLogConvex_real_of_ratio_strictMono {a : ℕ → ℝ}
    (hpos : ∀ n, 0 < a n)
    (hmono : ∀ n, a (n + 1) / a n < a (n + 2) / a (n + 1)) :
    ∀ n, a (n + 1) ^ 2 < a n * a (n + 2) := by
      exact fun n => by have := hmono n; rw [ div_lt_div_iff₀ ( hpos _ ) ( hpos _ ) ] at this; linarith;

/-
**The Catalan ratios are strictly increasing over `ℝ`.**
This is the concrete instance of the ratio-monotonicity mechanism: strict
log-convexity of the Catalan totals is exactly `Cₙ₊₁/Cₙ < Cₙ₊₂/Cₙ₊₁`, so together
with `strictLogConvex_real_of_ratio_strictMono` it exhibits the Catalan case as a
special case of the general growth-ratio criterion.
-/
theorem catalan_ratio_strictMono (n : ℕ) :
    (catalan (n + 1) : ℝ) / catalan n < catalan (n + 2) / catalan (n + 1) := by
  have hn : (0 : ℝ) < catalan n := by exact_mod_cast catalan_pos n
  have hn1 : (0 : ℝ) < catalan (n + 1) := by exact_mod_cast catalan_pos (n + 1)
  have hslc : (catalan (n + 1) : ℝ) ^ 2 < (catalan n : ℝ) * catalan (n + 2) := by
    exact_mod_cast catalan_strictLogConvex n
  rw [div_lt_div_iff₀ hn hn1]
  nlinarith [hslc]

/-! ## Tropical dequantization (Conjecture 5) -/

/-
**Tropical dequantization.**  For a positive real sequence, strict
log-convexity `a(n+1)² < a(n)·a(n+2)` is exactly strict convexity of the
sequence `log a`, i.e. strict concavity of the valuation `v = -log a`.
-/
theorem strictLogConvex_iff_log {a : ℕ → ℝ} (hpos : ∀ n, 0 < a n) (n : ℕ) :
    a (n + 1) ^ 2 < a n * a (n + 2)
      ↔ 2 * Real.log (a (n + 1)) < Real.log (a n) + Real.log (a (n + 2)) := by
  rw [ ← Real.log_rpow, ← Real.log_mul, Real.log_lt_log_iff ] <;> norm_cast <;> norm_num [ hpos ];
  · linarith [ hpos n ];
  · linarith [ hpos ( n + 2 ) ]

end HoggattTotals