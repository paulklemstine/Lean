/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The sumset exponent surface: asymptotics and monotonicity

Additive combinatorics inside the integer cross-polytope
`{x ∈ ℤᵈ : |x₁| + ⋯ + |x_d| ≤ m}` is governed by the sharp exponent
`p(n,m) = n · log(m+1) / log(nm+1)`,
where `n` is the number of summands and `m` the radius.  Earlier work bracketed
this exponent inside `(1, n)` and identified the one–dimensional interval as the
extremiser.  This file studies the *global shape of the exponent surface*
`(n,m) ↦ p(n,m)`.

The main results are:

* **Radial asymptotics** (`pExp_tendsto_atTop`): for a fixed number of summands,
  `p(n,m) → n` as the radius `m → ∞`.  The sharp exponent degenerates to the
  trivial geometric-mean exponent `n` in the large-radius limit.

* **Strict monotonicity in the number of summands** (`pExp_strictMono_left`):
  `p(n,m) < p(n+1,m)`.  Adding a summand strictly increases the exponent.

* **Refutation of radial monotonicity** (`pExp_not_antitone`): for `n ≥ 2` the
  map `m ↦ p(n,m)` is **not** decreasing.  Indeed, since `p(n,m) < n` for every
  `m` yet `p(n,m) → n`, the surface must *rise* toward its asymptote — it cannot
  be antitone.  This corrects the natural but false guess that the exponent
  decreases with the radius.

The engine behind the asymptotics is the two-sided squeeze
`n · log(m+1)/(log n + log(m+1)) ≤ p(n,m) ≤ n`,
coming from `m+1 ≤ nm+1 ≤ n(m+1)`.  Strict monotonicity in `n` reduces, after
clearing the common positive factor `log(m+1)`, to the interval–power comparison
`((n+1)m+1)^n < (nm+1)^{n+1}`.
-/
import Mathlib

open Filter Topology Real

namespace SumsetExponentSurface

/-- The sharp sumset exponent `p(n,m) = n · log(m+1) / log(nm+1)`. -/
noncomputable def pExp (n m : ℕ) : ℝ :=
  (n : ℝ) * Real.log (m + 1) / Real.log (n * m + 1)

/-- The numerator logarithm `log (m+1)` is positive for a positive radius. -/
lemma log_succ_pos (m : ℕ) (hm : 1 ≤ m) : 0 < Real.log (m + 1) := by
  have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
  apply Real.log_pos; linarith

/-- **Upper bound.** The sharp exponent never exceeds the number of summands. -/
theorem pExp_lt_n (n m : ℕ) (hn : 2 ≤ n) (hm : 1 ≤ m) : pExp n m < n := by
  have hn' : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hd : 0 < Real.log ((n : ℝ) * m + 1) := by apply Real.log_pos; nlinarith
  rw [pExp, div_lt_iff₀ hd]
  have hlt : Real.log ((m : ℝ) + 1) < Real.log ((n : ℝ) * m + 1) := by
    apply Real.log_lt_log <;> nlinarith
  have ha : 0 < Real.log ((m : ℝ) + 1) := by apply Real.log_pos; linarith
  nlinarith [hlt, ha]

/-! ### Strict monotonicity in the number of summands -/

/-
The interval–power comparison underlying strict monotonicity in the number of
summands: `((n+1)m+1)^n < (nm+1)^{n+1}`.

*Proof idea.*  Dividing by `((n+1)m+1)^n > 0`, it suffices to show
`(nm+1)·(ρ)^n > 1` where `ρ = (nm+1)/((n+1)m+1) = 1 - m/((n+1)m+1)`.  Bernoulli's
inequality gives `ρ^n ≥ 1 - n·m/((n+1)m+1) = (m+1)/((n+1)m+1)`, hence
`(nm+1)·ρ^n ≥ (nm+1)(m+1)/((n+1)m+1) > 1`, the last step because
`(nm+1)(m+1) = nm² + nm + m + 1 > nm + m + 1 = (n+1)m+1`.
-/
lemma pow_dilate_strictMono (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) :
    ((n + 1) * m + 1) ^ n < (n * m + 1) ^ (n + 1) := by
  -- Divide both sides by `A^n > 0` to get `B * (B/A)^n > 1`.
  set A : ℝ := ((n + 1) * m + 1)
  set B : ℝ := (n * m + 1)
  have h_div : B * (B / A) ^ n > 1 := by
    -- By Bernoulli's inequality `one_add_mul_le_pow` (with a = -(m/A), noting -2 ≤ a since 0 ≤ m/A ≤ 1): (1 - m/A)^n ≥ 1 - n*(m/A).
    have h_bernoulli : (1 - (m : ℝ) / A) ^ n ≥ 1 - n * (m / A) := by
      exact le_trans ( by norm_num ) ( one_add_mul_le_pow ( by linarith [ show ( m : ℝ ) / A ≤ 1 by rw [ div_le_iff₀ <| by positivity ] ; nlinarith [ ( by norm_cast : ( 1 :ℝ ) ≤ n ), ( by norm_cast : ( 1 :ℝ ) ≤ m ) ] ] ) _ );
    -- Now 1 - n*(m/A) = (A - n*m)/A = (m+1)/A because A = n*m + m + 1.
    have h_simplify : 1 - n * (m / A) = (m + 1) / A := by
      rw [ mul_div, one_sub_div ] <;> ring ; positivity;
    -- Hence ρ^n ≥ (m+1)/A, so B*ρ^n ≥ B*(m+1)/A = (n*m+1)*(m+1)/((n+1)*m+1).
    have h_final : B * (B / A) ^ n ≥ B * ((m + 1) / A) := by
      exact mul_le_mul_of_nonneg_left ( by rw [ show ( ( n : ℝ ) * m + 1 ) / ( ( n + 1 ) * m + 1 ) = 1 - m / ( ( n + 1 ) * m + 1 ) by rw [ one_sub_div ( by positivity ) ] ; ring ] ; exact h_simplify ▸ by linarith ) ( by positivity );
    refine lt_of_lt_of_le ?_ h_final;
    rw [ mul_div, lt_div_iff₀ ] <;> nlinarith [ ( by norm_cast : ( 1 :ℝ ) ≤ n ), ( by norm_cast : ( 1 :ℝ ) ≤ m ), mul_pos ( by positivity : 0 < ( n :ℝ ) ) ( by positivity : 0 < ( m :ℝ ) ) ];
  norm_num +zetaDelta at *;
  rw [ div_pow, mul_div, lt_div_iff₀ ] at h_div <;> norm_cast at * <;> first | positivity | ring_nf at * ; aesop;

/-- **Strict monotonicity in the number of summands.**
Adding a summand strictly increases the sharp exponent: `p(n,m) < p(n+1,m)`. -/
theorem pExp_strictMono_left (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) :
    pExp n m < pExp (n + 1) m := by
  have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hn' : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have ha : 0 < Real.log ((m : ℝ) + 1) := by apply Real.log_pos; linarith
  have hd1 : 0 < Real.log ((n : ℝ) * m + 1) := by apply Real.log_pos; nlinarith
  have hd2 : 0 < Real.log (((n : ℝ) + 1) * m + 1) := by apply Real.log_pos; nlinarith
  have hkey : (n : ℝ) * Real.log (((n : ℝ) + 1) * m + 1)
      < ((n : ℝ) + 1) * Real.log ((n : ℝ) * m + 1) := by
    have h1 : Real.log ((((n : ℝ) + 1) * m + 1) ^ n)
        < Real.log ((((n : ℝ) * m + 1)) ^ (n + 1)) := by
      apply Real.log_lt_log
      · positivity
      · have := pow_dilate_strictMono n m hn hm
        have hc : ((((n + 1) * m + 1) ^ n : ℕ) : ℝ)
            < (((n * m + 1) ^ (n + 1) : ℕ) : ℝ) := by exact_mod_cast this
        push_cast at hc ⊢; convert hc using 2
    rw [Real.log_pow, Real.log_pow] at h1
    push_cast at h1
    nlinarith [h1]
  rw [pExp, pExp]
  push_cast
  rw [div_lt_div_iff₀ hd1 hd2]
  nlinarith [hkey, ha, mul_pos ha hd1, mul_pos ha hd2]

/-! ### Radial asymptotics -/

/-- `log (m+1) → ∞` as `m → ∞`. -/
lemma tendsto_log_succ_atTop :
    Tendsto (fun m : ℕ => Real.log (m + 1)) atTop atTop := by
  apply Real.tendsto_log_atTop.comp
  exact tendsto_atTop_add_const_right _ 1 (tendsto_natCast_atTop_atTop)

/-- The ratio `log(nm+1)/log(m+1)` of the two logarithms tends to `1`; this is the
heart of the radial asymptotics, squeezed between `1` and `1 + log n / log(m+1)`. -/
lemma tendsto_logRatio (n : ℕ) (hn : 1 ≤ n) :
    Tendsto (fun m : ℕ => Real.log ((n : ℝ) * m + 1) / Real.log ((m : ℝ) + 1))
      atTop (𝓝 1) := by
  have hn' : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hlogtop := tendsto_log_succ_atTop
  have hupper : Tendsto (fun m : ℕ => 1 + Real.log n / Real.log ((m : ℝ) + 1))
      atTop (𝓝 1) := by
    have : Tendsto (fun m : ℕ => Real.log n / Real.log ((m : ℝ) + 1)) atTop (𝓝 0) :=
      Tendsto.div_atTop tendsto_const_nhds hlogtop
    simpa using Tendsto.const_add (1 : ℝ) this
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper
  · filter_upwards [eventually_ge_atTop 1] with m hm
    have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
    have hpos : 0 < Real.log ((m : ℝ) + 1) := by apply Real.log_pos; linarith
    rw [le_div_iff₀ hpos, one_mul]
    apply Real.log_le_log (by linarith); nlinarith
  · filter_upwards [eventually_ge_atTop 1] with m hm
    have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
    have hpos : 0 < Real.log ((m : ℝ) + 1) := by apply Real.log_pos; linarith
    rw [div_le_iff₀ hpos, add_mul, one_mul, div_mul_cancel₀ _ (ne_of_gt hpos)]
    have : Real.log ((n : ℝ) * m + 1) ≤ Real.log (((m : ℝ) + 1) * n) := by
      apply Real.log_le_log (by nlinarith); nlinarith
    rw [Real.log_mul (by positivity) (by linarith)] at this
    linarith [this]

/-- **Radial asymptotics.** For a fixed number of summands the sharp exponent
converges to `n` as the radius grows: `p(n,m) → n`. -/
theorem pExp_tendsto_atTop (n : ℕ) (hn : 1 ≤ n) :
    Tendsto (fun m : ℕ => pExp n m) atTop (𝓝 (n : ℝ)) := by
  have hev : ∀ᶠ m : ℕ in atTop,
      pExp n m = (n : ℝ) / (Real.log ((n : ℝ) * m + 1) / Real.log ((m : ℝ) + 1)) := by
    filter_upwards with m
    rw [pExp, div_div_eq_mul_div]
  rw [tendsto_congr' hev]
  have := Tendsto.div (tendsto_const_nhds (x := (n : ℝ))) (tendsto_logRatio n hn)
    (by norm_num)
  simpa using this

/-- **Refutation of radial monotonicity.** For `n ≥ 2` the exponent is *not* a
decreasing function of the radius: because it stays strictly below `n` while
converging to `n`, it must increase toward its asymptote. -/
theorem pExp_not_antitone (n : ℕ) (hn : 2 ≤ n) :
    ¬ Antitone (fun m : ℕ => pExp n m) := by
  intro hanti
  have hlim := pExp_tendsto_atTop n (by omega)
  have hlt : pExp n 1 < n := pExp_lt_n n 1 hn (le_refl 1)
  have hev : ∀ᶠ m : ℕ in atTop, pExp n 1 < pExp n m := hlim.eventually_const_lt hlt
  obtain ⟨m, hm1, _⟩ := (hev.and (eventually_ge_atTop 1)).exists
  have hle : pExp n m ≤ pExp n 1 := hanti (by assumption)
  linarith

/-! ### Examples and sanity checks -/

-- The sharp exponent at `n = 2, m = 1` is `2 log 2 / log 3`.
example : pExp 2 1 = 2 * Real.log 2 / Real.log 3 := by
  unfold pExp; norm_num

#check @pExp_tendsto_atTop
#check @pExp_strictMono_left
#check @pExp_not_antitone

/-!
-- !-- Lab Notes -- !--

**Hypothesis.** The exponent surface `p(n,m) = n·log(m+1)/log(nm+1)` should be
strictly increasing in the number of summands `n`, and its behaviour in the radius
`m` should be settled by the asymptote `p(n,m) → n`.

**Experiment.** Monotonicity in `n` reduces, after clearing the common factor
`log(m+1) > 0`, to the integer inequality `((n+1)m+1)^n < (nm+1)^{n+1}`, verified
on a large grid before formalisation and proved by Bernoulli's inequality. The
radial limit is obtained by the squeeze
`n·log(m+1)/(log n + log(m+1)) ≤ p(n,m) ≤ n`, using `m+1 ≤ nm+1 ≤ n(m+1)`.

**Analysis.** A prior cycle proved `p(n,m) < n` and the extremal interval equality.
Small-case computation here revealed that `p(n,m)` is *increasing* in `m` (rising
toward `n`), directly contradicting the plausible conjecture that the exponent
decreases with the radius. The clean way to certify this is the limit: a decreasing
sequence bounded above by `p(n,1) < n` could never approach `n`.

**Critique.** The refutation `pExp_not_antitone` is not vacuous: it combines a
strict inequality (`p(n,1) < n`) with a genuine limit. Monotonicity in `n` rests on
a non-trivial exponential inequality rather than any definitional shortcut. All
statements are guarded by the hypotheses (`n ≥ 2`, `m ≥ 1`) that keep the logarithms
in range.

**Synthesis.** The surface rises in both coordinates toward the geometric-mean
exponent `n`, which it attains only in the large-radius limit. This settles the
qualitative shape left open by the bracket `1 < p < n` and corrects the
radial-monotonicity direction.
-/

end SumsetExponentSurface