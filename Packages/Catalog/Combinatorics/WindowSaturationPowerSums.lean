/-
# Cycle 5b: the power sums behind the exponent dial

`Combinatorics.WindowSaturationExponentDial` reduced everything about the
`α`-dial to the two power sums

  `P_α(B) = ∑_{i=1}^{B} i^{-α}`   and   `P_{2α}(B) = ∑_{i=1}^{B} i^{-2α}`,

through `ess (dial α) B = P_α(B)² / P_{2α}(B)`.  This file supplies the
quantitative control of those sums that the rescaling law needs, from scratch
and with explicit constants:

* `rpow_concave_step` / `rpow_convex_step` — the two one-step comparison
  inequalities `p (x+1)^{p-1} ≤ (x+1)^p - x^p` (for `0 < p < 1`) and
  `r (x+1)^{-r-1} ≤ x^{-r} - (x+1)^{-r}` (for `r > 0`).  The first is weighted
  AM–GM, the second is `log (1+s) ≥ s/(1+s)` in exponential form.  They replace
  an integral comparison by a telescoping sum.
* `wsum_dial_ge`, `wsum_dial_le` — the two-sided bound
  `B^{1-α} ≤ P_α(B) ≤ B^{1-α}/(1-α)` for `0 < α < 1`.
* `wsum_dial_bdd` — `P_q(B) ≤ q/(q-1)` for `q > 1`: **the square mass of the
  dial saturates exactly when `α > 1/2`**.
* `harmonic_dyadic_lower`, `harmonic_dyadic_upper` — the Oresme bounds
  `1 + k/2 ≤ P_1(2^k) ≤ 1 + k`, giving the logarithmic growth of the harmonic
  dial without leaving rational arithmetic.

The `α = 1/2` boundary is visible already here: `P_{2α}` is bounded uniformly in
`B` for `α > 1/2` and grows like `log B` at `α = 1/2`.  That single dichotomy is
what produces the rescaling law and its failure.
-/
import Combinatorics.WindowSaturationExponentDial

open Finset

namespace WindowSaturation

namespace Dial

/-! ## Two one-step comparison inequalities -/

/-- **Concavity step.**  For `0 < p < 1` the increment of `x ↦ x^p` dominates
the derivative at the right endpoint. -/
lemma rpow_concave_step {p x : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (hx : 0 ≤ x) :
    p * (x + 1) ^ (p - 1) ≤ (x + 1) ^ p - x ^ p := by
  have hx1 : (0:ℝ) < x + 1 := by linarith
  have hber : (x / (x + 1)) ^ p ≤ p * (x / (x + 1)) + (1 - p) := by
    have := Real.geom_mean_le_arith_mean2_weighted hp0.le (by linarith : (0:ℝ) ≤ 1 - p)
      (div_nonneg hx hx1.le) zero_le_one (by ring)
    simpa using this
  have hxu : x ^ p = (x + 1) ^ p * (x / (x + 1)) ^ p := by
    rw [Real.div_rpow hx hx1.le]
    field_simp
  have hpow : (x + 1) ^ (p - 1) = (x + 1) ^ p / (x + 1) := by
    rw [Real.rpow_sub hx1, Real.rpow_one]
  have hpos : (0:ℝ) < (x + 1) ^ p := Real.rpow_pos_of_pos hx1 p
  have hmul := mul_le_mul_of_nonneg_left hber hpos.le
  have h2 : (x + 1) ^ p * (p * (x / (x + 1)) + (1 - p))
      = (x + 1) ^ p - p * ((x + 1) ^ p / (x + 1)) := by
    field_simp
    ring
  rw [hxu, hpow]
  linarith [hmul, h2.le, h2.ge]

/-- **Convexity step.**  For `r > 0` the decrement of `x ↦ x^{-r}` dominates the
derivative at the right endpoint. -/
lemma rpow_convex_step {r x : ℝ} (hr : 0 < r) (hx : 0 < x) :
    r * (x + 1) ^ (-r - 1) ≤ x ^ (-r) - (x + 1) ^ (-r) := by
  have hx1 : (0:ℝ) < x + 1 := by linarith
  set s : ℝ := 1 / x with hs
  have hs0 : 0 < s := by positivity
  have hkey : Real.exp (s / (1 + s)) ≤ 1 + s := by
    have h1 : (1:ℝ) / (1 + s) ≤ Real.exp (-(s / (1 + s))) := by
      have hE := Real.add_one_le_exp (-(s / (1 + s)))
      have h2 : -(s / (1 + s)) + 1 = 1 / (1 + s) := by
        field_simp; ring
      linarith [hE, h2.le, h2.ge]
    have h3 : Real.exp (-(s / (1 + s))) = 1 / Real.exp (s / (1 + s)) := by
      rw [Real.exp_neg]; ring
    rw [h3] at h1
    have hE : 0 < Real.exp (s / (1 + s)) := Real.exp_pos _
    rw [div_le_div_iff₀ (by linarith) hE] at h1
    linarith
  have hpow : Real.exp (r * s / (1 + s)) ≤ (1 + s) ^ r := by
    have h := Real.rpow_le_rpow (Real.exp_pos _).le hkey hr.le
    rw [← Real.exp_mul] at h
    have he : s / (1 + s) * r = r * s / (1 + s) := by ring
    rwa [he] at h
  have hge : 1 + r * s / (1 + s) ≤ (1 + s) ^ r :=
    le_trans (by linarith [Real.add_one_le_exp (r * s / (1 + s))]) hpow
  have h1s : 1 + s = (x + 1) / x := by rw [hs]; field_simp
  have hratio : ((x + 1) / x) ^ r = (x + 1) ^ r / x ^ r := Real.div_rpow hx1.le hx.le r
  have hrs : r * s / (1 + s) = r / (x + 1) := by
    rw [hs]; field_simp
  rw [hrs, h1s, hratio] at hge
  have hxr : (0:ℝ) < x ^ r := Real.rpow_pos_of_pos hx r
  have hx1r : (0:ℝ) < (x + 1) ^ r := Real.rpow_pos_of_pos hx1 r
  have hneg1 : x ^ (-r) = 1 / x ^ r := by rw [Real.rpow_neg hx.le]; ring
  have hneg2 : (x + 1) ^ (-r) = 1 / (x + 1) ^ r := by rw [Real.rpow_neg hx1.le]; ring
  have hneg3 : (x + 1) ^ (-r - 1) = 1 / ((x + 1) ^ r * (x + 1)) := by
    rw [show -r - 1 = -(r + 1) by ring, Real.rpow_neg hx1.le, Real.rpow_add hx1, Real.rpow_one]
    ring
  rw [hneg1, hneg2, hneg3]
  have hAX : (1:ℝ) / x ^ r - 1 / (x + 1) ^ r = ((x + 1) ^ r / x ^ r - 1) / (x + 1) ^ r := by
    field_simp
  have hL : r * (1 / ((x + 1) ^ r * (x + 1))) = (r / (x + 1)) / (x + 1) ^ r := by
    field_simp
  rw [hAX, hL]
  gcongr
  linarith

/-! ## Elementary properties of the dial power sums -/

lemma wsum_dial_nonneg (alpha : ℝ) (B : ℕ) : 0 ≤ wsum (dial alpha) B :=
  Finset.sum_nonneg fun i _ => (dial_pos (i := i + 1) (by omega)).le

lemma wsum_dial_mono (alpha : ℝ) {B C : ℕ} (h : B ≤ C) :
    wsum (dial alpha) B ≤ wsum (dial alpha) C := by
  refine Finset.sum_le_sum_of_subset_of_nonneg
    (Finset.range_subset.mpr fun x hx => Finset.mem_range.mpr (lt_of_lt_of_le hx h)) ?_
  intro i _ _
  exact (dial_pos (i := i + 1) (by omega)).le

/-- The first column contributes exactly `1` to every dial. -/
lemma one_le_wsum_dial (alpha : ℝ) {B : ℕ} (hB : 1 ≤ B) : 1 ≤ wsum (dial alpha) B := by
  have h0 : dial alpha 1 = 1 := by
    simp [dial]
  calc (1:ℝ) = dial alpha (0 + 1) := by simpa using h0.symm
    _ ≤ wsum (dial alpha) B :=
        Finset.single_le_sum (f := fun i => dial alpha (i + 1))
          (fun i _ => (dial_pos (i := i + 1) (by omega)).le) (Finset.mem_range.mpr hB)

lemma wsum_dial_pos (alpha : ℝ) {B : ℕ} (hB : 1 ≤ B) : 0 < wsum (dial alpha) B :=
  lt_of_lt_of_le zero_lt_one (one_le_wsum_dial alpha hB)

/-! ## The two-sided power bound for `0 < α < 1` -/

/-- **Lower power bound.**  `B^{1-α} ≤ P_α(B)`: the window mass of the dial is at
least `B` copies of its smallest weight. -/
theorem wsum_dial_ge {alpha : ℝ} (ha : 0 ≤ alpha) {B : ℕ} (hB : 1 ≤ B) :
    (B : ℝ) ^ (1 - alpha) ≤ wsum (dial alpha) B := by
  have hB0 : (0:ℝ) < B := by exact_mod_cast hB
  have hterm : ∀ i ∈ range B, dial alpha B ≤ dial alpha (i + 1) := by
    intro i hi
    have hi' := Finset.mem_range.mp hi
    exact dial_anti ha (by omega) (by omega : i + 1 ≤ B)
  have hcard : ((B : ℝ)) * dial alpha B ≤ wsum (dial alpha) B := by
    calc (B : ℝ) * dial alpha B = ∑ _i ∈ range B, dial alpha B := by simp
      _ ≤ ∑ i ∈ range B, dial alpha (i + 1) := Finset.sum_le_sum hterm
      _ = wsum (dial alpha) B := rfl
  have hid : (B : ℝ) ^ (1 - alpha) = (B : ℝ) * dial alpha B := by
    rw [dial, Real.rpow_sub hB0, Real.rpow_one, Real.rpow_neg hB0.le]
    field_simp
  rw [hid]
  exact hcard

/-- **Upper power bound.**  `P_α(B) ≤ B^{1-α}/(1-α)` for `0 < α < 1`, by
telescoping the concavity step. -/
theorem wsum_dial_le {alpha : ℝ} (h0 : 0 < alpha) (h1 : alpha < 1) (B : ℕ) :
    wsum (dial alpha) B ≤ (B : ℝ) ^ (1 - alpha) / (1 - alpha) := by
  induction B with
  | zero =>
      rw [wsum_zero, Nat.cast_zero, Real.zero_rpow (by linarith)]
      simp
  | succ k ih =>
      have hstep := rpow_concave_step (p := 1 - alpha) (x := (k : ℝ))
        (by linarith) (by linarith) (Nat.cast_nonneg k)
      have hpk : (1 - alpha) - 1 = -alpha := by ring
      rw [hpk] at hstep
      have hdial : dial alpha (k + 1) = ((k : ℝ) + 1) ^ (-alpha) := by
        rw [dial]
        norm_num
      have hcast : (((k + 1 : ℕ) : ℝ)) = (k : ℝ) + 1 := by push_cast; ring
      rw [wsum_succ, hdial, hcast]
      have hih' : wsum (dial alpha) k * (1 - alpha) ≤ (k : ℝ) ^ (1 - alpha) :=
        (le_div_iff₀ (by linarith)).mp ih
      rw [le_div_iff₀ (by linarith : (0:ℝ) < 1 - alpha)]
      nlinarith [hstep, hih']

/-- **Bounded square mass.**  For `q > 1` the power sum `P_q` is bounded by
`q/(q-1)` uniformly in the window edge.  With `q = 2α` this is exactly the
condition `α > 1/2`. -/
theorem wsum_dial_bdd {q : ℝ} (hq : 1 < q) (B : ℕ) : wsum (dial q) B ≤ q / (q - 1) := by
  have hr : 0 < q - 1 := by linarith
  -- strengthened statement, proved by induction
  have key : ∀ N : ℕ, 1 ≤ N →
      wsum (dial q) N ≤ 1 + (1 - (N : ℝ) ^ (-(q - 1))) / (q - 1) := by
    intro N hN
    induction N with
    | zero => omega
    | succ k ih =>
        rcases Nat.eq_zero_or_pos k with hk | hk
        · subst hk
          rw [wsum_succ, wsum_zero]
          have : dial q (0 + 1) = 1 := by simp [dial]
          rw [this]
          norm_num
        · have hk1 : (0:ℝ) < (k : ℝ) := by exact_mod_cast hk
          have hstep := rpow_convex_step (r := q - 1) (x := (k : ℝ)) hr hk1
          have hexp : -(q - 1) - 1 = -q := by ring
          rw [hexp] at hstep
          have hdial : dial q (k + 1) = ((k : ℝ) + 1) ^ (-q) := by
            rw [dial]; norm_num
          have hcast : (((k + 1 : ℕ) : ℝ)) = (k : ℝ) + 1 := by push_cast; ring
          rw [wsum_succ, hdial, hcast]
          have hih := ih hk
          have h1 : wsum (dial q) k - 1 ≤ (1 - (k : ℝ) ^ (-(q - 1))) / (q - 1) := by
            linarith
          have hih' := (le_div_iff₀ hr).mp h1
          have hgoal : wsum (dial q) k + ((k : ℝ) + 1) ^ (-q) - 1
              ≤ (1 - ((k : ℝ) + 1) ^ (-(q - 1))) / (q - 1) := by
            rw [le_div_iff₀ hr]
            nlinarith [hstep, hih']
          linarith [hgoal]
  rcases Nat.eq_zero_or_pos B with hB | hB
  · subst hB
    rw [wsum_zero]
    positivity
  · have h := key B hB
    have hpos : (0:ℝ) ≤ (B : ℝ) ^ (-(q - 1)) :=
      Real.rpow_nonneg (Nat.cast_nonneg B) _
    have hle2 : (1 - (B : ℝ) ^ (-(q - 1))) / (q - 1) ≤ 1 / (q - 1) :=
      (div_le_div_iff_of_pos_right hr).mpr (by linarith)
    have hqq : 1 + 1 / (q - 1) = q / (q - 1) := by
      field_simp
      ring
    linarith [h, hle2, hqq.le, hqq.ge]

/-! ## The harmonic dial: dyadic (Oresme) bounds -/

lemma dial_one_eq (i : ℕ) (hi : 1 ≤ i) : dial 1 i = 1 / (i : ℝ) := dial_one_apply hi

/-- Splitting the window at a dyadic edge. -/
lemma wsum_split (w : ℕ → ℝ) {a b : ℕ} (hab : a ≤ b) :
    wsum w b = wsum w a + ∑ i ∈ Ico a b, w (i + 1) := by
  simp only [wsum, Finset.range_eq_Ico]
  exact (Finset.sum_Ico_consecutive (fun i => w (i + 1)) (Nat.zero_le a) hab).symm

/-- **Oresme lower bound.**  `1 + k/2 ≤ P_1(2^k)`. -/
theorem harmonic_dyadic_lower (k : ℕ) : 1 + (k : ℝ) / 2 ≤ wsum (dial 1) (2 ^ k) := by
  induction k with
  | zero =>
      have : wsum (dial 1) 1 = 1 := by
        rw [wsum_succ, wsum_zero]
        simp [dial]
      simp [this]
  | succ n ih =>
      have hle : 2 ^ n ≤ 2 ^ (n + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
      rw [wsum_split (dial 1) hle]
      have hblock : (1:ℝ) / 2 ≤ ∑ i ∈ Ico (2 ^ n) (2 ^ (n + 1)), dial 1 (i + 1) := by
        have hterm : ∀ i ∈ Ico (2 ^ n) (2 ^ (n + 1)),
            (1:ℝ) / (2 ^ (n + 1) : ℕ) ≤ dial 1 (i + 1) := by
          intro i hi
          have hi2 := (Finset.mem_Ico.mp hi).2
          rw [dial_one_eq (i + 1) (by omega)]
          apply one_div_le_one_div_of_le
          · positivity
          · exact_mod_cast Nat.succ_le_of_lt hi2
        have hcard := Finset.card_nsmul_le_sum (Ico (2 ^ n) (2 ^ (n + 1)))
          (fun i => dial 1 (i + 1)) ((1:ℝ) / (2 ^ (n + 1) : ℕ)) hterm
        rw [Nat.card_Ico] at hcard
        have hc : ((2 ^ (n + 1) - 2 ^ n : ℕ) : ℝ) = (2 ^ n : ℕ) := by
          have : (2:ℕ) ^ (n + 1) - 2 ^ n = 2 ^ n := by
            rw [pow_succ]; omega
          rw [this]
        rw [nsmul_eq_mul, hc] at hcard
        refine le_trans (le_of_eq ?_) hcard
        push_cast
        rw [pow_succ]
        field_simp
      push_cast
      linarith [ih, hblock]

/-- **Oresme upper bound.**  `P_1(2^k) ≤ 1 + k`. -/
theorem harmonic_dyadic_upper (k : ℕ) : wsum (dial 1) (2 ^ k) ≤ 1 + (k : ℝ) := by
  induction k with
  | zero =>
      have : wsum (dial 1) 1 = 1 := by
        rw [wsum_succ, wsum_zero]
        simp [dial]
      simp [this]
  | succ n ih =>
      have hle : 2 ^ n ≤ 2 ^ (n + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
      rw [wsum_split (dial 1) hle]
      have hblock : (∑ i ∈ Ico (2 ^ n) (2 ^ (n + 1)), dial 1 (i + 1)) ≤ 1 := by
        have hterm : ∀ i ∈ Ico (2 ^ n) (2 ^ (n + 1)),
            dial 1 (i + 1) ≤ (1:ℝ) / (2 ^ n : ℕ) := by
          intro i hi
          have hi1 := (Finset.mem_Ico.mp hi).1
          rw [dial_one_eq (i + 1) (by omega)]
          apply one_div_le_one_div_of_le
          · positivity
          · exact_mod_cast Nat.le_succ_of_le hi1
        have hcard := Finset.sum_le_card_nsmul (Ico (2 ^ n) (2 ^ (n + 1)))
          (fun i => dial 1 (i + 1)) ((1:ℝ) / (2 ^ n : ℕ)) hterm
        rw [Nat.card_Ico] at hcard
        have hc : ((2 ^ (n + 1) - 2 ^ n : ℕ) : ℝ) = (2 ^ n : ℕ) := by
          have : (2:ℕ) ^ (n + 1) - 2 ^ n = 2 ^ n := by
            rw [pow_succ]; omega
          rw [this]
        rw [nsmul_eq_mul, hc] at hcard
        refine le_trans hcard (le_of_eq ?_)
        have h2n : (0:ℝ) < ((2 ^ n : ℕ) : ℝ) := by positivity
        rw [mul_one_div, div_self (ne_of_gt h2n)]
      push_cast
      linarith [ih, hblock]

end Dial

end WindowSaturation