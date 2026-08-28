import Mathlib

/-!
# Sequential hint pricing IV: net economics of buying adaptive hints

The compounding law of `Pythagorean/SeqHint/Adaptive.lean` says `k` adaptive
hints divide the downstream cost `T₀` by `2 ^ k`.  Hints are not free: each query
costs `c`.  The *net* cost of a `k`-query run is therefore

  `netCost c T₀ k = c * k + T₀ * 2 ^ (-k)`,

a strictly convex mixture of a linear price and a geometric payoff.  This file
proves the optimum of that trade-off, which is the `H3` prediction of the
experiment,

  `k_opt = log₂ (T₀ * ln 2 / c)`,

and the two facts that make it usable: the cost is unimodal around `k_opt`
(decreasing to the left, increasing to the right), so the best *integer* budget
is `⌊k_opt⌋` or `⌈k_opt⌉` — never further away.

Results:

* `netCost_eq_rpow` — the exponential form used in the proofs agrees with the
  `2 ^ (-k)` form.
* `two_rpow_kOpt` — the prediction formula: `2 ^ k_opt = T₀ ln 2 / c`.
* `netCost_ge_kOpt` — `k_opt` is a global minimiser.
* `netCost_antitone_left`, `netCost_monotone_right` — unimodality.
* `netCost_int_argmin` — the integer optimum is `⌊k_opt⌋` or `⌈k_opt⌉`.
-/

namespace Pythagorean.SeqHint

open Real

/-- Net cost of a `k`-query hinted run: `k` queries at price `c`, plus the
downstream scan `T` divided by the geometric adaptive speedup `2 ^ k`. -/
noncomputable def netCost (c T x : ℝ) : ℝ := c * x + T * Real.exp (-(x * Real.log 2))

/-- The predicted optimal budget `log₂ (T ln 2 / c)`. -/
noncomputable def kOpt (c T : ℝ) : ℝ := Real.log (T * Real.log 2 / c) / Real.log 2

lemma log_two_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)

/-- The exponential form of `netCost` is the `2 ^ (-x)` form. -/
theorem netCost_eq_rpow (c T x : ℝ) : netCost c T x = c * x + T * (2 : ℝ) ^ (-x) := by
  unfold netCost
  rw [Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 2)]
  ring_nf

/-- **The prediction formula.**  At the optimum, `2 ^ k_opt = T ln 2 / c`, i.e.
`k_opt = log₂ (T ln 2 / c)`. -/
theorem two_rpow_kOpt (c T : ℝ) (hc : 0 < c) (hT : 0 < T) :
    (2 : ℝ) ^ (kOpt c T) = T * Real.log 2 / c := by
  have hL := log_two_pos
  have hX : 0 < T * Real.log 2 / c := by positivity
  rw [Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 2)]
  have h1 : Real.log 2 * kOpt c T = Real.log (T * Real.log 2 / c) := by
    unfold kOpt
    field_simp
  rw [h1, Real.exp_log hX]

/-- At the optimum the residual downstream cost equals `c / ln 2`: the marginal
query exactly pays for itself. -/
lemma downstream_at_kOpt (c T : ℝ) (hc : 0 < c) (hT : 0 < T) :
    T * Real.exp (-(kOpt c T * Real.log 2)) = c / Real.log 2 := by
  have hL := log_two_pos
  have hX : 0 < T * Real.log 2 / c := by positivity
  have h1 : kOpt c T * Real.log 2 = Real.log (T * Real.log 2 / c) := by
    unfold kOpt
    field_simp
  rw [h1, Real.exp_neg, Real.exp_log hX]
  field_simp

/-- The cost written relative to the optimum: `netCost` at `k_opt + d` is
`c * k_opt + c * d + (c / ln 2) * exp (-(d ln 2))`. -/
lemma netCost_shift (c T : ℝ) (hc : 0 < c) (hT : 0 < T) (d : ℝ) :
    netCost c T (kOpt c T + d)
      = c * kOpt c T + c * d + (c / Real.log 2) * Real.exp (-(d * Real.log 2)) := by
  have hkey := downstream_at_kOpt c T hc hT
  unfold netCost
  have hexp : Real.exp (-((kOpt c T + d) * Real.log 2))
      = Real.exp (-(kOpt c T * Real.log 2)) * Real.exp (-(d * Real.log 2)) := by
    rw [← Real.exp_add]
    ring_nf
  rw [hexp, ← mul_assoc, hkey]
  ring

/-- Convexity of `exp` in the form used below: `exp b * (a - b) ≤ exp a - exp b`. -/
lemma exp_sub_ge (a b : ℝ) : Real.exp b * (a - b) ≤ Real.exp a - Real.exp b := by
  have hkey : (a - b) + 1 ≤ Real.exp (a - b) := Real.add_one_le_exp _
  have h := mul_le_mul_of_nonneg_left hkey (le_of_lt (Real.exp_pos b))
  rw [← Real.exp_add] at h
  have hba : b + (a - b) = a := by ring
  rw [hba] at h
  calc Real.exp b * (a - b) = Real.exp b * ((a - b) + 1) - Real.exp b := by ring
    _ ≤ Real.exp a - Real.exp b := by linarith

/-- Comparison of the net cost at two offsets from `k_opt`, driven purely by the
exponential inequality relating the two downstream terms. -/
lemma netCost_shift_le (c T : ℝ) (hc : 0 < c) (hT : 0 < T) {d₁ d₂ : ℝ}
    (hexp : (d₂ - d₁) * Real.log 2
      ≤ Real.exp (-(d₁ * Real.log 2)) - Real.exp (-(d₂ * Real.log 2))) :
    netCost c T (kOpt c T + d₂) ≤ netCost c T (kOpt c T + d₁) := by
  have hL := log_two_pos
  rw [netCost_shift c T hc hT d₁, netCost_shift c T hc hT d₂]
  have hK0 : 0 < c / Real.log 2 := by positivity
  have hmul := mul_le_mul_of_nonneg_left hexp (le_of_lt hK0)
  have h1 : (c / Real.log 2) * ((d₂ - d₁) * Real.log 2) = c * d₂ - c * d₁ := by
    field_simp
  have h2 : (c / Real.log 2) *
      (Real.exp (-(d₁ * Real.log 2)) - Real.exp (-(d₂ * Real.log 2)))
      = (c / Real.log 2) * Real.exp (-(d₁ * Real.log 2))
        - (c / Real.log 2) * Real.exp (-(d₂ * Real.log 2)) := by ring
  rw [h1, h2] at hmul
  linarith

/-- **`k_opt` is the global minimiser of the net cost.** -/
theorem netCost_ge_kOpt (c T : ℝ) (hc : 0 < c) (hT : 0 < T) (x : ℝ) :
    netCost c T (kOpt c T) ≤ netCost c T x := by
  have hL := log_two_pos
  have hx : x = kOpt c T + (x - kOpt c T) := by ring
  have h0 : kOpt c T = kOpt c T + 0 := by ring
  set d := x - kOpt c T with hd
  have hexp : (0 - d) * Real.log 2
      ≤ Real.exp (-(d * Real.log 2)) - Real.exp (-(0 * Real.log 2)) := by
    have hle := Real.add_one_le_exp (-(d * Real.log 2))
    simp only [zero_mul, neg_zero, Real.exp_zero]
    linarith
  calc netCost c T (kOpt c T) = netCost c T (kOpt c T + 0) := by rw [← h0]
    _ ≤ netCost c T (kOpt c T + d) := netCost_shift_le c T hc hT hexp
    _ = netCost c T x := by rw [← hx]

/-- Below the optimum the net cost is decreasing: buying another hint pays. -/
theorem netCost_antitone_left (c T : ℝ) (hc : 0 < c) (hT : 0 < T) {x y : ℝ}
    (hxy : x ≤ y) (hy : y ≤ kOpt c T) : netCost c T y ≤ netCost c T x := by
  have hL := log_two_pos
  set d₁ := x - kOpt c T with hd₁
  set d₂ := y - kOpt c T with hd₂
  have hx : x = kOpt c T + d₁ := by rw [hd₁]; ring
  have hy' : y = kOpt c T + d₂ := by rw [hd₂]; ring
  have h12 : d₁ ≤ d₂ := by rw [hd₁, hd₂]; linarith
  have h2neg : d₂ ≤ 0 := by rw [hd₂]; linarith
  have hE2 : 1 ≤ Real.exp (-(d₂ * Real.log 2)) := Real.one_le_exp (by nlinarith)
  have hbase := exp_sub_ge (-(d₁ * Real.log 2)) (-(d₂ * Real.log 2))
  have hdiff : 0 ≤ (d₂ - d₁) * Real.log 2 := by nlinarith
  have hexp : (d₂ - d₁) * Real.log 2
      ≤ Real.exp (-(d₁ * Real.log 2)) - Real.exp (-(d₂ * Real.log 2)) := by
    nlinarith [hbase, hE2, hdiff]
  calc netCost c T y = netCost c T (kOpt c T + d₂) := by rw [← hy']
    _ ≤ netCost c T (kOpt c T + d₁) := netCost_shift_le c T hc hT hexp
    _ = netCost c T x := by rw [← hx]

/-- Above the optimum the net cost is increasing: further hints are overpriced. -/
theorem netCost_monotone_right (c T : ℝ) (hc : 0 < c) (hT : 0 < T) {x y : ℝ}
    (hx : kOpt c T ≤ x) (hxy : x ≤ y) : netCost c T x ≤ netCost c T y := by
  have hL := log_two_pos
  set d₁ := x - kOpt c T with hd₁
  set d₂ := y - kOpt c T with hd₂
  have hx' : x = kOpt c T + d₁ := by rw [hd₁]; ring
  have hy' : y = kOpt c T + d₂ := by rw [hd₂]; ring
  have h12 : d₁ ≤ d₂ := by rw [hd₁, hd₂]; linarith
  have h1nonneg : 0 ≤ d₁ := by rw [hd₁]; linarith
  have hE1 : Real.exp (-(d₁ * Real.log 2)) ≤ 1 := Real.exp_le_one_iff.2 (by nlinarith)
  have hbase := exp_sub_ge (-(d₂ * Real.log 2)) (-(d₁ * Real.log 2))
  have hdiff : 0 ≤ (d₂ - d₁) * Real.log 2 := by nlinarith
  have hexp : (d₁ - d₂) * Real.log 2
      ≤ Real.exp (-(d₂ * Real.log 2)) - Real.exp (-(d₁ * Real.log 2)) := by
    nlinarith [hbase, hE1, hdiff, Real.exp_pos (-(d₁ * Real.log 2))]
  calc netCost c T x = netCost c T (kOpt c T + d₁) := by rw [← hx']
    _ ≤ netCost c T (kOpt c T + d₂) := netCost_shift_le c T hc hT hexp
    _ = netCost c T y := by rw [← hy']

/-- **The integer optimum sits next to the prediction.**  For every integer
budget `n`, the cost of `⌊k_opt⌋` or of `⌈k_opt⌉` is at least as good: the
measured optimal budget can never be more than one query away from
`log₂ (T ln 2 / c)`. -/
theorem netCost_int_argmin (c T : ℝ) (hc : 0 < c) (hT : 0 < T) (n : ℤ) :
    min (netCost c T ⌊kOpt c T⌋) (netCost c T ⌈kOpt c T⌉) ≤ netCost c T n := by
  rcases le_or_gt (n : ℝ) (kOpt c T) with hn | hn
  · have hle : (n : ℝ) ≤ ((⌊kOpt c T⌋ : ℤ) : ℝ) := by
      exact_mod_cast Int.le_floor.2 hn
    have hfl : ((⌊kOpt c T⌋ : ℤ) : ℝ) ≤ kOpt c T := Int.floor_le _
    exact le_trans (min_le_left _ _) (netCost_antitone_left c T hc hT hle hfl)
  · have hce : kOpt c T ≤ ((⌈kOpt c T⌉ : ℤ) : ℝ) := Int.le_ceil _
    have hle : ((⌈kOpt c T⌉ : ℤ) : ℝ) ≤ (n : ℝ) := by
      exact_mod_cast Int.ceil_le.2 (le_of_lt hn)
    exact le_trans (min_le_right _ _) (netCost_monotone_right c T hc hT hce hle)

end Pythagorean.SeqHint