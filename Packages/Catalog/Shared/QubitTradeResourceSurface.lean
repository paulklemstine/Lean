import Mathlib

/-!
# The three-axis resource surface of a repeated order-finding attempt

*(FACT round-25 #3 — QUBIT-TRADE4, "the standard corner is optimal", paper 87.)*

A Shor-style factoring attempt on a fixed modulus is parameterised by three
resources:

* the **register width** `t` (equivalently, `d` bits shaved off the full
  register width `T`, `t = T - d`),
* the number of **samples** `s` taken from one base, and
* the number of independent **base re-draws** `k`.

The experimental round measured the success probability on the
`t × s × k` grid and concluded that, once the *total* gate cost `k·s·t²` is
priced, the minimum of the surface sits at the full-register corner `d = 0`.
This file proves the mathematics behind that verdict.

The model formalised here is the one the experiment fits:

* the `s` and `k` axes enter only through the product `n = k·s` of independent
  Bernoulli shots, giving `P = 1 - (1-q)^n` (`succProb`);
* the `t` axis enters through a geometric per-shot success `q = q₀ / 2^d`
  (`shotProb`): each shaved bit halves the chance that a single run lands on a
  usable convergent;
* the cost of a configuration is `n · t²` (`gateCost`).

## Main results

* `succProb_failure_pow` / `succProb_failure_iterate` — the **cap-lift law**:
  failure probability is multiplicative in the re-draw count, so `k` doublings
  square the failure probability (doubly exponential decay).
* `succProb_double_gain` — the **exact fungibility increment**: doubling either
  the `s` or the `k` axis raises `P` by exactly `P(1-P)`; hence the gain is
  strictly positive below saturation (`gain_pos`) and never exceeds `1/4`
  (`gain_le_quarter`).
* `succProb_axis_fungible` — the `s` and `k` axes are *perfectly* fungible:
  the surface depends on them only through `k·s`.
* `standard_corner_optimal` — the **`t` axis is not fungible with them**: for a
  full register of width `T ≥ 8` and any shave `1 ≤ d ≤ T/2`, every
  configuration reaching the target probability at width `T - d` costs strictly
  more than the full-register configuration.  A quadratic saving in width is
  always overwhelmed by the exponential growth of the required shot count.
* `standard_corner_optimal_concrete` — the instance with `q₀ = 1/8`,
  `P* = 3/10`, where the full-register corner needs exactly three shots.

The measured cap-lift numbers of the round are checked against the law in
`caplift_prediction_k2` and `caplift_prediction_k4`.
-/

namespace QubitTradeSurface

open Finset

/-! ## 1. The surface -/

/-- Probability that at least one of `n` independent shots, each succeeding
with probability `q`, succeeds.  For the resource surface `n = k * s` is the
re-draw count times the samples-per-base count. -/
noncomputable def succProb (q : ℝ) (n : ℕ) : ℝ := 1 - (1 - q) ^ n

/-- Per-shot success probability of a register shaved by `d` bits: each shaved
bit halves the chance that one run yields a usable convergent. -/
noncomputable def shotProb (q₀ : ℝ) (d : ℕ) : ℝ := q₀ / 2 ^ d

/-- Total gate cost of `n = k·s` shots on a register of width `t`. -/
def gateCost (n t : ℕ) : ℕ := n * t ^ 2

@[simp] lemma shotProb_zero (q₀ : ℝ) : shotProb q₀ 0 = q₀ := by
  simp [shotProb]

lemma shotProb_pos {q₀ : ℝ} (hq : 0 < q₀) (d : ℕ) : 0 < shotProb q₀ d := by
  have : (0:ℝ) < 2 ^ d := by positivity
  exact div_pos hq this

lemma shotProb_le {q₀ : ℝ} (hq : 0 ≤ q₀) (d : ℕ) : shotProb q₀ d ≤ q₀ := by
  have h1 : (1:ℝ) ≤ 2 ^ d := one_le_pow₀ (by norm_num)
  have h2 : (0:ℝ) < 2 ^ d := by positivity
  rw [shotProb, div_le_iff₀ h2]
  nlinarith

/-- The failure probability of the configuration. -/
lemma one_sub_succProb (q : ℝ) (n : ℕ) : 1 - succProb q n = (1 - q) ^ n := by
  simp [succProb]

@[simp] lemma succProb_zero (q : ℝ) : succProb q 0 = 0 := by simp [succProb]

@[simp] lemma succProb_one (q : ℝ) : succProb q 1 = q := by simp [succProb]

lemma succProb_nonneg {q : ℝ} (h0 : 0 ≤ q) (h1 : q ≤ 1) (n : ℕ) :
    0 ≤ succProb q n := by
  have : (1 - q) ^ n ≤ 1 := pow_le_one₀ (by linarith) (by linarith)
  simp only [succProb]; linarith

lemma succProb_lt_one {q : ℝ} (h1 : q < 1) (n : ℕ) :
    succProb q n < 1 := by
  have : (0:ℝ) < (1 - q) ^ n := pow_pos (by linarith) n
  simp only [succProb]; linarith

/-! ## 2. The cap-lift law: failure is multiplicative in re-draws -/

/-- **Cap-lift law.**  Running `n` blocks of `m` shots multiplies the failure
probability of one block `n`-fold in the exponent: the per-`N` cap of a single
base is escaped exactly as `1 - (1-P_block)^n`. -/
theorem succProb_failure_pow (q : ℝ) (m n : ℕ) :
    1 - succProb q (m * n) = (1 - succProb q m) ^ n := by
  rw [one_sub_succProb, one_sub_succProb, ← pow_mul]

/-- Doubling the re-draw count **squares** the failure probability. -/
theorem succProb_failure_sq (q : ℝ) (n : ℕ) :
    1 - succProb q (2 * n) = (1 - succProb q n) ^ 2 := by
  rw [mul_comm, succProb_failure_pow]

/-- Iterating the doubling: after `j` doublings the failure probability is the
`2^j`-th power, i.e. it decays **doubly exponentially** in the number of
doublings. -/
theorem succProb_failure_iterate (q : ℝ) (n j : ℕ) :
    1 - succProb q (2 ^ j * n) = (1 - succProb q n) ^ (2 ^ j) := by
  rw [mul_comm, succProb_failure_pow]

/-! ## 3. Fungibility of the sample and re-draw axes -/

/-- The surface depends on the samples axis `s` and the re-draw axis `k` only
through their product: the two axes are **perfectly fungible**. -/
theorem succProb_axis_fungible (q : ℝ) (k s : ℕ) :
    succProb q (k * s) = succProb q (s * k) := by rw [mul_comm]

/-- **Exact fungibility increment.**  Doubling either resource axis raises the
success probability by exactly `P (1 - P)`. -/
theorem succProb_double_gain (q : ℝ) (n : ℕ) :
    succProb q (2 * n) - succProb q n = succProb q n * (1 - succProb q n) := by
  have h := succProb_failure_sq q n
  nlinarith [h]

/-- Below saturation (`0 < P < 1`) the doubling gain is strictly positive: this
is the measured "`ΔP > 0` everywhere below saturation". -/
theorem gain_pos {q : ℝ} (h0 : 0 < q) (h1 : q < 1) {n : ℕ} (hn : 0 < n) :
    0 < succProb q (2 * n) - succProb q n := by
  rw [succProb_double_gain]
  have hlt : succProb q n < 1 := succProb_lt_one h1 n
  have hpos : 0 < succProb q n := by
    have : (1 - q) ^ n < 1 := pow_lt_one₀ (by linarith) (by linarith) hn.ne'
    simp only [succProb]; linarith
  nlinarith

/-- **Saturation bound.**  No single doubling can buy more than `1/4`: the gain
is the Bernoulli variance `P(1-P)`. -/
theorem gain_le_quarter (q : ℝ) (n : ℕ) :
    succProb q (2 * n) - succProb q n ≤ 1 / 4 := by
  rw [succProb_double_gain]
  nlinarith [sq_nonneg (succProb q n - 1 / 2)]

/-- The gain is maximal exactly at the half-saturated point. -/
theorem gain_eq_quarter_iff (q : ℝ) (n : ℕ) :
    succProb q (2 * n) - succProb q n = 1 / 4 ↔ succProb q n = 1 / 2 := by
  rw [succProb_double_gain]
  constructor
  · intro h; nlinarith [sq_nonneg (succProb q n - 1 / 2)]
  · intro h; rw [h]; norm_num

/-- Strict monotonicity along the shot axis. -/
theorem succProb_strictMono {q : ℝ} (h0 : 0 < q) (h1 : q < 1) {m n : ℕ}
    (hmn : m < n) : succProb q m < succProb q n := by
  have : (1 - q) ^ n < (1 - q) ^ m :=
    pow_lt_pow_right_of_lt_one₀ (by linarith) (by linarith) hmn
  simp only [succProb]; linarith

/-- Strict monotonicity along the per-shot quality axis (wider register, or a
luckier base): more per-shot probability is more success. -/
theorem succProb_strictMono_prob {q q' : ℝ} (h1 : q' ≤ 1)
    (hqq : q < q') {n : ℕ} (hn : 0 < n) : succProb q n < succProb q' n := by
  have : (1 - q') ^ n < (1 - q) ^ n := by
    apply pow_lt_pow_left₀ (by linarith) (by linarith) hn.ne'
  simp only [succProb]; linarith

/-! ## 4. The union bound: the exponential price of a shaved register -/

/-- Union bound `P ≤ n q`: the shot count needed to reach a target probability
is at least `P*/q`. -/
theorem succProb_le_mul {q : ℝ} (h1 : q ≤ 1) (n : ℕ) :
    succProb q n ≤ n * q := by
  have hb : 1 + (n : ℝ) * (-q) ≤ (1 + (-q)) ^ n :=
    one_add_mul_le_pow (by linarith) n
  have hb' : 1 - (n : ℝ) * q ≤ (1 - q) ^ n := by
    simpa [sub_eq_add_neg] using hb
  simp only [succProb]
  linarith

/-- **Exponential shot floor.**  At a register shaved by `d` bits, reaching a
target success probability `P*` requires at least `P* · 2^d / q₀` shots. -/
theorem shots_floor {q₀ P : ℝ} (hq : 0 < q₀) (hq1 : q₀ ≤ 1) {d n : ℕ}
    (hP : P ≤ succProb (shotProb q₀ d) n) :
    P * 2 ^ d ≤ n * q₀ := by
  have hd : (0:ℝ) < 2 ^ d := by positivity
  have h1 : succProb (shotProb q₀ d) n ≤ n * (q₀ / 2 ^ d) :=
    succProb_le_mul (le_trans (shotProb_le hq.le d) hq1) n
  have h2 : P ≤ (n : ℝ) * q₀ / 2 ^ d := by
    rw [mul_div_assoc]; exact le_trans hP h1
  exact (le_div_iff₀ hd).mp h2

/-! ## 5. Exponential samples beat a quadratic width saving -/

/-- The geometric/quadratic trade-off inequality: for a full width `T ≥ 8` and
a shave of `1 ≤ d ≤ T/2` bits, the exponential factor `2^d` outruns the
quadratic width saving by a margin of at least `5/4`. -/
theorem two_pow_mul_sq_gt {T : ℝ} (hT : 8 ≤ T) {d : ℕ} (hd : 1 ≤ d)
    (hdT : 2 * (d : ℝ) ≤ T) :
    (5 / 4) * T ^ 2 < 2 ^ d * (T - d) ^ 2 := by
  rcases eq_or_lt_of_le hd with h1 | h1
  · -- d = 1
    obtain rfl : d = 1 := h1.symm
    push_cast
    nlinarith
  · rcases eq_or_lt_of_le (Nat.succ_le_of_lt h1) with h2 | h2
    · -- d = 2
      obtain rfl : d = 2 := h2.symm
      push_cast
      nlinarith
    · -- d ≥ 3
      have hd3 : 3 ≤ d := h2
      have hpow : (8:ℝ) ≤ 2 ^ d := by
        calc (8:ℝ) = 2 ^ 3 := by norm_num
        _ ≤ 2 ^ d := by
              apply pow_le_pow_right₀ (by norm_num) hd3
      have hhalf : T / 2 ≤ T - d := by linarith
      have hTpos : (0:ℝ) < T := by linarith
      have hsq : (T / 2) ^ 2 ≤ (T - d) ^ 2 := by
        apply pow_le_pow_left₀ (by positivity) hhalf
      nlinarith [sq_nonneg T, hsq, hpow]

/-! ## 6. The standard corner is optimal -/

/-- **Standard-corner optimality (general form).**

Fix a target success probability `P > 0`, a full register width `T ≥ 8`, and a
full-register configuration of `n₀` shots which is *efficient*, i.e. whose
expected number of successes `n₀ q₀` overshoots the union-bound floor `P` by at
most `25 %`.  Then for every shave `1 ≤ d ≤ T/2`, **every** configuration of `n`
shots at the reduced width `t = T - d` that still reaches probability `P`
costs strictly more gates than the full-register configuration:

`gateCost n₀ T < gateCost n t`.

The quadratic saving in register width is always overwhelmed by the exponential
growth of the number of samples/re-draws required. -/
theorem standard_corner_optimal {q₀ P : ℝ} (hq : 0 < q₀) (hq1 : q₀ ≤ 1) (hP : 0 < P)
    {T d t n₀ n : ℕ} (hT : 8 ≤ T) (hd : 1 ≤ d) (hdT : 2 * d ≤ T) (ht : t + d = T)
    (heff : (n₀ : ℝ) * q₀ ≤ (5 / 4) * P)
    (hn : P ≤ succProb (shotProb q₀ d) n) :
    (gateCost n₀ T : ℝ) < gateCost n t := by
  have hTR : (8:ℝ) ≤ (T : ℝ) := by exact_mod_cast hT
  have hdTR : 2 * (d : ℝ) ≤ (T : ℝ) := by exact_mod_cast hdT
  have hdR : 1 ≤ d := hd
  have htR : (t : ℝ) = (T : ℝ) - (d : ℝ) := by
    have : ((t : ℝ)) + (d : ℝ) = (T : ℝ) := by exact_mod_cast ht
    linarith
  -- exponential floor on the number of shots at the shaved width
  have hfloor : P * 2 ^ d ≤ (n : ℝ) * q₀ := shots_floor hq hq1 hn
  -- the trade-off inequality
  have hkey : (5 / 4) * (T:ℝ) ^ 2 < 2 ^ d * ((T:ℝ) - d) ^ 2 :=
    two_pow_mul_sq_gt hTR hdR hdTR
  have hTpos : (0:ℝ) < (T:ℝ) := by linarith
  have htpos : (0:ℝ) ≤ (T:ℝ) - d := by linarith
  -- compare the two costs, both measured in units of `q₀`
  have h1 : (n₀ : ℝ) * q₀ * (T:ℝ) ^ 2 ≤ (5 / 4) * P * (T:ℝ) ^ 2 := by
    nlinarith [sq_nonneg ((T:ℝ))]
  have h2 : P * ((5 / 4) * (T:ℝ) ^ 2) < P * (2 ^ d * ((T:ℝ) - d) ^ 2) := by
    exact mul_lt_mul_of_pos_left hkey hP
  have h3 : P * 2 ^ d * ((T:ℝ) - d) ^ 2 ≤ (n : ℝ) * q₀ * ((T:ℝ) - d) ^ 2 := by
    apply mul_le_mul_of_nonneg_right hfloor (by positivity)
  have h4 : (n₀ : ℝ) * q₀ * (T:ℝ) ^ 2 < (n : ℝ) * q₀ * ((T:ℝ) - d) ^ 2 := by
    nlinarith
  -- cancel the positive factor `q₀`
  have h5 : (n₀ : ℝ) * (T:ℝ) ^ 2 < (n : ℝ) * ((T:ℝ) - d) ^ 2 := by
    by_contra hcon
    push_neg at hcon
    nlinarith
  simp only [gateCost, Nat.cast_mul, Nat.cast_pow, htR]
  exact h5

/-- The full-register corner with `q₀ = 1/8` reaches the target `P ≥ 3/10`
after three shots, at a cost of `3 T²` gates. -/
theorem full_register_suffices : (3:ℝ) / 10 ≤ succProb (shotProb (1/8) 0) 3 := by
  rw [shotProb_zero]
  simp only [succProb]
  norm_num

/-- The efficiency hypothesis of `standard_corner_optimal` holds — with
equality — for `q₀ = 1/8`, `P* = 3/10`, `n₀ = 3`. -/
theorem full_register_efficient : (3 : ℝ) * (1/8) ≤ (5/4) * (3/10 : ℝ) := by
  norm_num

/-- **Standard-corner optimality (measured instance).**  With the fitted
per-shot probability `q₀ = 1/8` and the round's target `P* = 3/10`, the
three-shot full-register configuration is strictly cheaper than any
configuration at a shaved width, for every full width `T ≥ 8` and every shave
`1 ≤ d ≤ T/2`. -/
theorem standard_corner_optimal_concrete
    {T d t n : ℕ} (hT : 8 ≤ T) (hd : 1 ≤ d) (hdT : 2 * d ≤ T) (ht : t + d = T)
    (hn : (3:ℝ)/10 ≤ succProb (shotProb (1/8) d) n) :
    (gateCost 3 T : ℝ) < gateCost n t := by
  refine standard_corner_optimal (q₀ := 1/8) (P := 3/10) (by norm_num) (by norm_num)
    (by norm_num) hT hd hdT ht ?_ hn
  norm_num

/-- The corner really is a *corner*: at the full width the target is met, so the
cost `gateCost 3 T` compared against in `standard_corner_optimal_concrete` is
attained by an admissible configuration. -/
theorem corner_is_attained (T : ℕ) :
    (3:ℝ)/10 ≤ succProb (shotProb (1/8) 0) 3 ∧ gateCost 3 T = 3 * T ^ 2 :=
  ⟨full_register_suffices, rfl⟩

/-! ## 7. Robustness of the verdict: cubic gate models and the three-axis form -/

/-- Cubic-cost version of the trade-off inequality.  Some accountings price a
width-`t` modular-exponentiation register at `t³` rather than `t²`; the
exponential factor still wins, with the same `5/4` margin. -/
theorem two_pow_mul_cube_gt {T : ℝ} (hT : 8 ≤ T) {d : ℕ} (hd : 1 ≤ d)
    (hdT : 2 * (d : ℝ) ≤ T) :
    (5 / 4) * T ^ 3 < 2 ^ d * (T - d) ^ 3 := by
  have hTpos : (0:ℝ) < T := by linarith
  rcases eq_or_lt_of_le hd with h1 | h1
  · obtain rfl : d = 1 := h1.symm
    push_cast
    nlinarith [sq_nonneg (T - 8), sq_nonneg T]
  · rcases eq_or_lt_of_le (Nat.succ_le_of_lt h1) with h2 | h2
    · obtain rfl : d = 2 := h2.symm
      push_cast
      nlinarith [sq_nonneg (T - 8), sq_nonneg T]
    · rcases eq_or_lt_of_le (Nat.succ_le_of_lt h2) with h3 | h3
      · obtain rfl : d = 3 := h3.symm
        push_cast
        nlinarith [sq_nonneg (T - 8), sq_nonneg T]
      · -- `d ≥ 4`: the exponential factor alone is at least `16`
        have hd4 : 4 ≤ d := h3
        have hpow : (16:ℝ) ≤ 2 ^ d := by
          calc (16:ℝ) = 2 ^ 4 := by norm_num
          _ ≤ 2 ^ d := pow_le_pow_right₀ (by norm_num) hd4
        have hhalf : T / 2 ≤ T - d := by linarith
        have hcube : (T / 2) ^ 3 ≤ (T - d) ^ 3 := by
          apply pow_le_pow_left₀ (by positivity) hhalf
        nlinarith [hcube, hpow, pow_pos hTpos 3]

/-- **Standard-corner optimality under a cubic gate model.**  The verdict does
not depend on whether a width-`t` register is priced at `t²` or at `t³`. -/
theorem standard_corner_optimal_cubic {q₀ P : ℝ} (hq : 0 < q₀) (hq1 : q₀ ≤ 1)
    (hP : 0 < P) {T d t n₀ n : ℕ} (hT : 8 ≤ T) (hd : 1 ≤ d) (hdT : 2 * d ≤ T)
    (ht : t + d = T) (heff : (n₀ : ℝ) * q₀ ≤ (5 / 4) * P)
    (hn : P ≤ succProb (shotProb q₀ d) n) :
    (n₀ : ℝ) * (T : ℝ) ^ 3 < (n : ℝ) * (t : ℝ) ^ 3 := by
  have hTR : (8:ℝ) ≤ (T : ℝ) := by exact_mod_cast hT
  have hdTR : 2 * (d : ℝ) ≤ (T : ℝ) := by exact_mod_cast hdT
  have htR : (t : ℝ) = (T : ℝ) - (d : ℝ) := by
    have : ((t : ℝ)) + (d : ℝ) = (T : ℝ) := by exact_mod_cast ht
    linarith
  have hfloor : P * 2 ^ d ≤ (n : ℝ) * q₀ := shots_floor hq hq1 hn
  have hkey : (5 / 4) * (T:ℝ) ^ 3 < 2 ^ d * ((T:ℝ) - d) ^ 3 :=
    two_pow_mul_cube_gt hTR hd hdTR
  have hTpos : (0:ℝ) < (T:ℝ) := by linarith
  have htpos : (0:ℝ) ≤ (T:ℝ) - d := by linarith
  have h1 : (n₀ : ℝ) * q₀ * (T:ℝ) ^ 3 ≤ (5 / 4) * P * (T:ℝ) ^ 3 := by
    nlinarith [pow_pos hTpos 3]
  have h2 : P * ((5 / 4) * (T:ℝ) ^ 3) < P * (2 ^ d * ((T:ℝ) - d) ^ 3) :=
    mul_lt_mul_of_pos_left hkey hP
  have h3 : P * 2 ^ d * ((T:ℝ) - d) ^ 3 ≤ (n : ℝ) * q₀ * ((T:ℝ) - d) ^ 3 :=
    mul_le_mul_of_nonneg_right hfloor (by positivity)
  have h4 : (n₀ : ℝ) * q₀ * (T:ℝ) ^ 3 < (n : ℝ) * q₀ * ((T:ℝ) - d) ^ 3 := by
    nlinarith
  have h5 : (n₀ : ℝ) * (T:ℝ) ^ 3 < (n : ℝ) * ((T:ℝ) - d) ^ 3 := by
    by_contra hcon
    push_neg at hcon
    nlinarith
  rw [htR]
  exact h5

/-- **The three-axis form of the verdict.**  Writing the shot count as the
re-draw count `k` times the samples-per-base count `s`, no interior point
`(k, s, t)` of the resource surface that meets the target probability is
cheaper than the full-register corner. -/
theorem surface_minimum_at_corner {q₀ P : ℝ} (hq : 0 < q₀) (hq1 : q₀ ≤ 1)
    (hP : 0 < P) {T d t n₀ k s : ℕ} (hT : 8 ≤ T) (hd : 1 ≤ d) (hdT : 2 * d ≤ T)
    (ht : t + d = T) (heff : (n₀ : ℝ) * q₀ ≤ (5 / 4) * P)
    (hks : P ≤ succProb (shotProb q₀ d) (k * s)) :
    (gateCost n₀ T : ℝ) < gateCost (k * s) t :=
  standard_corner_optimal hq hq1 hP hT hd hdT ht heff hks

/-! ## 8. Lab notes: the measured cap lift against the law

Round-25 #3 measured, at `t = wall`, `s = 5`:
`k = 1 → 0.504`, `k = 2 → 0.735`, `k = 4 → 0.940`.
The cap-lift law `1 - P(k) = (1 - P(1))^k` predicts `0.753984` and `0.939476…`
from the `k = 1` cell alone.  The `k = 4` prediction is within `6·10⁻⁴` of the
measurement; the `k = 2` cell sits `1.9·10⁻²` low, i.e. within the sampling
error of 20 trials × 24 moduli, and is the only visible deviation. -/

/-- The law's prediction for `k = 2` from the measured `k = 1` cell. -/
theorem caplift_prediction_k2 :
    |(1 - (1 - (0.504:ℝ)) ^ 2) - 0.735| < 0.019 := by
  rw [abs_lt]; constructor <;> norm_num

/-- The law's prediction for `k = 4` matches the measured cell to `6·10⁻⁴`. -/
theorem caplift_prediction_k4 :
    |(1 - (1 - (0.504:ℝ)) ^ 4) - 0.940| < 0.0006 := by
  rw [abs_lt]; constructor <;> norm_num

/-- Consistency of the two measured cells with the doubling identity: the
`k = 1 → k = 2` measured increment `0.735 - 0.504 = 0.231` is below the
saturation ceiling `1/4` of `gain_le_quarter`. -/
theorem measured_gain_below_ceiling : (0.735:ℝ) - 0.504 < 1 / 4 := by norm_num

end QubitTradeSurface