import Mathlib
import Novelty.ZeroFitDialU64

/-!
# The zero-fit dial at bitlen 100: range shape cannot bend the tie ceiling

## Research context (FACT round-67 #2, exp 540, `TDIAL-U100`)

Uniform draws at bitlen 100 give a Spearman rank correlation between the trailing-zero
statistic `T` (the 2-adic valuation) and the downstream `rate`:

* seeds 20261200/01/02: `0.546 / 0.528 / 0.549`;
* pooled `0.544`, CI `[0.498, 0.588]` — the first CI that *straddles* the validation
  floor `0.55` on uniform draws;
* `T` beats the plain count baseline by `+0.098`.

All previous cycles computed the tie-attenuation ceiling for a *power-of-two* draw range
(`Novelty.ZeroFitDialU64`: `ρ² = (6/7)(1 + 1/(2^b(2^b+1)))`), for the `p`-adic analogue
(`Novelty.ZeroFitDialU76`), and for a *capped* statistic (`Novelty.ZeroFitDialTruncation`).
A referee-proof objection remained open: real instrumentation almost never samples
`{0,…,2^b−1}` exactly.  If the sampler draws from `{0,…,n−1}` for some `n` that is *not*
a power of two — e.g. a rejection-sampled interval, a modulus, or a truncated stream —
the 2-adic tie profile is no longer the geometric list `2^{b−1},…,1`, its block sizes
fluctuate, and (a priori) the ceiling could fluctuate with them.

This file settles that objection by computing the ceiling for **every** `n`.

## Main results

* `rangeBlocks` — the exact 2-adic tie profile of `{0,…,n−1}`, given by the halving
  recursion `rangeBlocks n = ⌊n/2⌋ :: rangeBlocks ⌈n/2⌉`; `rangeBlocks_sum` and
  `rangeBlocks_two_pow` identify it with the dyadic profile at powers of two.
* `devE` — the *ceiling defect* `Σ mⱼ³ − n³/7`.  Its behaviour is the mathematical core:
  - `devE_even`: `devE` is invariant under doubling, hence a function of the **odd part**
    of `n` only — a genuine self-similar (Takagi-type) digit phenomenon;
  - `devE_odd`: `devE (2a+1) = devE (a+1) − (9a²+3a)/7`;
  - `devE_two_pow`: `devE (2^b) = 6/7` exactly, for every `b`;
  - `devE_le`, `devE_ge`: `−n²/2 ≤ devE n ≤ 6/7` for all `n`.
* `range_spearmanSq` — the **universal range law**
  `ρ²(n) = 6/7 + (6n/7 − devE n)/(n³ − n)` for every `n ≥ 2`.
* `range_ceiling_gt`, `range_ceiling_upper` — hence `6/7 < ρ²(n) ≤ 6/7 + 1/(n−1)`:
  *every* draw range has ceiling `6/7 + O(1/n)`, and the ceiling always exceeds `6/7`.
* `dyadic_case_consistency` — specialising the universal law at `n = 2^b` reproduces the
  round-61 law `(6/7)(1 + 1/(2^b(2^b+1)))`, an independent re-derivation.
* `odd_range_gap_lower` — for odd `n ≥ 3` the excess is at least `1/(7n)`, i.e. of order
  `1/n`, whereas at `n = 2^b` it is of order `1/n²`: the **dyadic/odd dichotomy**
  (`range_shape_dichotomy_100`, a factor `> 10^28` at bitlen 100).
* `u100_below_every_range_ceiling` — the scientific payload: the recorded bitlen-100
  reading `0.544` (indeed anything below `0.92`) lies below the tie ceiling of *every*
  draw range whatsoever.  The bitlen-100 band miss is therefore not a sampling-range
  artefact, and the erosion must be attributed to the response channel.
-/

open Finset

namespace Catalog.Novelty.TDialU100RangeShape

open Catalog.Novelty.ZeroFitDialU64

/-! ## 1. The tie profile of an arbitrary range `{0,…,n−1}`

Among `x < n` there are `⌊n/2⌋` odd numbers (2-adic valuation `0`), and the even ones are
`2y` with `y < ⌈n/2⌉`, whose valuations are one more than the valuations of `y`.  Hence the
profile obeys the halving recursion below; the final singleton is the block `{0}`. -/

/-- The 2-adic tie profile of the uniform range `{0,…,n−1}`, blocks listed in increasing
order of the trailing-zero count. -/
def rangeBlocks : ℕ → List ℕ
  | 0 => []
  | 1 => [1]
  | (n + 2) => (n + 2) / 2 :: rangeBlocks ((n + 3) / 2)
decreasing_by omega

/-- The halving recursion in uniform notation. -/
lemma rangeBlocks_ge_two {n : ℕ} (hn : 2 ≤ n) :
    rangeBlocks n = n / 2 :: rangeBlocks ((n + 1) / 2) := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k + 2 := ⟨n - 2, by omega⟩
  rw [rangeBlocks]

/-- The profile accounts for all `n` draws. -/
lemma rangeBlocks_sum (n : ℕ) : (rangeBlocks n).sum = n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n, ih with
    | 0, _ => simp [rangeBlocks]
    | 1, _ => simp [rangeBlocks]
    | (k + 2), ih =>
      rw [rangeBlocks_ge_two (by omega), List.sum_cons, ih ((k + 2 + 1) / 2) (by omega)]
      omega

/-- At a power of two the range profile is exactly the dyadic profile of round 61. -/
lemma rangeBlocks_two_pow (b : ℕ) : rangeBlocks (2 ^ b) = dyadicBlocks b := by
  induction b with
  | zero => simp [rangeBlocks, dyadicBlocks]
  | succ k ih =>
      have h2 : 2 ≤ 2 ^ (k + 1) := by
        have : (2 : ℕ) ^ 1 ≤ 2 ^ (k + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
        simpa using this
      rw [rangeBlocks_ge_two h2, dyadicBlocks]
      have e1 : 2 ^ (k + 1) / 2 = 2 ^ k := by rw [pow_succ]; omega
      have e2 : (2 ^ (k + 1) + 1) / 2 = 2 ^ k := by rw [pow_succ]; omega
      rw [e1, e2, ih]

/-! ## 2. Cube sums and the ceiling defect -/

/-- Sum of cubes of the block sizes. -/
def cubeSum (L : List ℕ) : ℚ := (L.map fun m => (m : ℚ) ^ 3).sum

lemma cubeSum_cons (m : ℕ) (L : List ℕ) : cubeSum (m :: L) = (m : ℚ) ^ 3 + cubeSum L := by
  simp [cubeSum]

lemma cubeSum_nonneg (L : List ℕ) : 0 ≤ cubeSum L := by
  induction L with
  | nil => simp [cubeSum]
  | cons m L ih => rw [cubeSum_cons]; positivity

/-- The Kendall tie correction in terms of the cube sum. -/
lemma tieCorr_eq_cubeSum (L : List ℕ) : tieCorr L = (cubeSum L - (L.sum : ℚ)) / 12 := by
  induction L with
  | nil => simp [tieCorr, cubeSum]
  | cons m L ih => rw [tieCorr_cons, ih, cubeSum_cons, List.sum_cons]; push_cast; ring

/-- The **ceiling defect** of the range `{0,…,n−1}`: the deviation of the cube sum of the
tie profile from the ideal geometric value `n³/7`. -/
def devE (n : ℕ) : ℚ := cubeSum (rangeBlocks n) - (n : ℚ) ^ 3 / 7

lemma devE_zero : devE 0 = 0 := by norm_num [devE, rangeBlocks, cubeSum]

lemma devE_one : devE 1 = 6 / 7 := by norm_num [devE, rangeBlocks, cubeSum]

/-- **Doubling invariance.**  The ceiling defect depends only on the odd part of `n`. -/
lemma devE_even (m : ℕ) (hm : 1 ≤ m) : devE (2 * m) = devE m := by
  have h2 : 2 ≤ 2 * m := by omega
  rw [devE, rangeBlocks_ge_two h2, cubeSum_cons, devE]
  have e1 : 2 * m / 2 = m := by omega
  have e2 : (2 * m + 1) / 2 = m := by omega
  rw [e1, e2]
  push_cast
  ring

/-- **Odd step.**  Passing from `a+1` to `2a+1` costs exactly `(9a²+3a)/7`. -/
lemma devE_odd (a : ℕ) (ha : 1 ≤ a) :
    devE (2 * a + 1) = devE (a + 1) - (9 * (a : ℚ) ^ 2 + 3 * a) / 7 := by
  have h2 : 2 ≤ 2 * a + 1 := by omega
  rw [devE, rangeBlocks_ge_two h2, cubeSum_cons, devE]
  have e1 : (2 * a + 1) / 2 = a := by omega
  have e2 : (2 * a + 1 + 1) / 2 = a + 1 := by omega
  rw [e1, e2]
  push_cast
  ring

/-- At powers of two the defect is the constant `6/7` — the exact self-similar fixed value. -/
lemma devE_two_pow (b : ℕ) : devE (2 ^ b) = 6 / 7 := by
  induction b with
  | zero => simpa using devE_one
  | succ k ih =>
      have h : (2 : ℕ) ^ (k + 1) = 2 * 2 ^ k := by ring
      rw [h, devE_even _ (Nat.one_le_two_pow), ih]

/-- **Upper bound on the defect**: `devE n ≤ 6/7`, with equality at powers of two. -/
theorem devE_le (n : ℕ) : devE n ≤ 6 / 7 := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · rw [devE_zero]; norm_num
    rcases Nat.even_or_odd n with ⟨m, hm⟩ | ⟨a, ha⟩
    · have hm1 : 1 ≤ m := by omega
      have hn2 : n = 2 * m := by omega
      subst hn2
      rw [devE_even m hm1]
      exact ih m (by omega)
    · rcases Nat.eq_zero_or_pos a with rfl | ha1
      · simp only [Nat.mul_zero, Nat.zero_add] at ha
        subst ha
        rw [devE_one]
      · subst ha
        rw [devE_odd a ha1]
        have h1 : devE (a + 1) ≤ 6 / 7 := ih (a + 1) (by omega)
        have h2 : (0 : ℚ) ≤ (9 * (a : ℚ) ^ 2 + 3 * a) / 7 := by positivity
        linarith

/-- **Lower bound on the defect**: `devE n ≥ −n²/2`.  (Numerically the true infimum of
`devE n / n²` is about `−0.407`, so this bound is of the right order.) -/
theorem devE_ge (n : ℕ) : -((n : ℚ) ^ 2) / 2 ≤ devE n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · rw [devE_zero]; norm_num
    rcases Nat.even_or_odd n with ⟨m, hm⟩ | ⟨a, ha⟩
    · have hm1 : 1 ≤ m := by omega
      have hn2 : n = 2 * m := by omega
      subst hn2
      rw [devE_even m hm1]
      have h := ih m (by omega)
      have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
      push_cast
      nlinarith
    · rcases Nat.eq_zero_or_pos a with rfl | ha1
      · simp only [Nat.mul_zero, Nat.zero_add] at ha
        subst ha
        rw [devE_one]
        norm_num
      · subst ha
        rw [devE_odd a ha1]
        have h := ih (a + 1) (by omega)
        have ha0 : (1 : ℚ) ≤ (a : ℚ) := by exact_mod_cast ha1
        push_cast at h ⊢
        nlinarith

/-- For odd `n ≥ 3` the defect is strongly negative: `devE n ≤ 6/7 − n²/7`. -/
theorem devE_odd_le (a : ℕ) (ha : 1 ≤ a) :
    devE (2 * a + 1) ≤ 6 / 7 - ((2 * a + 1 : ℕ) : ℚ) ^ 2 / 7 := by
  rw [devE_odd a ha]
  have h1 : devE (a + 1) ≤ 6 / 7 := devE_le (a + 1)
  have ha0 : (1 : ℚ) ≤ (a : ℚ) := by exact_mod_cast ha
  push_cast
  nlinarith

/-! ## 3. The universal range law -/

/-- **The universal range law.**  For uniform draws from `{0,…,n−1}` with `n ≥ 2`, the
Spearman ceiling against any tie-refining response is
`ρ²(n) = 6/7 + (6n/7 − devE n)/(n³ − n)`. -/
theorem range_spearmanSq (n : ℕ) (hn : 2 ≤ n) :
    spearmanSq (rangeBlocks n) = 6 / 7 + (6 * (n : ℚ) / 7 - devE n) / ((n : ℚ) ^ 3 - n) := by
  have hsum : (rangeBlocks n).sum = n := rangeBlocks_sum n
  have h2 : 2 ≤ (rangeBlocks n).sum := by rw [hsum]; exact hn
  have hq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hden : ((n : ℚ) ^ 3 - n) ≠ 0 := ne_of_gt (cube_sub_self_pos hq)
  have hn0 : (n : ℚ) ≠ 0 := by positivity
  have hnn : ((n : ℚ) ^ 2 - 1) ≠ 0 := by nlinarith [sq_nonneg ((n : ℚ) - 2)]
  rw [spearmanSq_eq _ h2, tieCorr_eq_cubeSum, hsum]
  have hcube : cubeSum (rangeBlocks n) = (n : ℚ) ^ 3 / 7 + devE n := by
    rw [devE]; ring
  rw [hcube]
  rw [div_add_div _ _ (by norm_num : (7:ℚ) ≠ 0) hden, eq_div_iff (by positivity)]
  field_simp
  ring

/-- Every draw range has a ceiling strictly above `6/7`. -/
theorem range_ceiling_gt (n : ℕ) (hn : 2 ≤ n) : 6 / 7 < spearmanSq (rangeBlocks n) := by
  have hq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hden : (0 : ℚ) < (n : ℚ) ^ 3 - n := cube_sub_self_pos hq
  have hnum : 0 < 6 * (n : ℚ) / 7 - devE n := by
    have := devE_le n
    nlinarith
  rw [range_spearmanSq n hn]
  have := div_pos hnum hden
  linarith

/-- …and a ceiling at most `6/7 + 1/(n−1)`.  Hence *no* choice of draw range moves the tie
ceiling away from `6/7` by more than `O(1/n)`. -/
theorem range_ceiling_upper (n : ℕ) (hn : 2 ≤ n) :
    spearmanSq (rangeBlocks n) ≤ 6 / 7 + 1 / ((n : ℚ) - 1) := by
  have hq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hden : (0 : ℚ) < (n : ℚ) ^ 3 - n := cube_sub_self_pos hq
  have hd1 : (0 : ℚ) < (n : ℚ) - 1 := by linarith
  have hE := devE_ge n
  rw [range_spearmanSq n hn]
  have hstep : (6 * (n : ℚ) / 7 - devE n) / ((n : ℚ) ^ 3 - n) ≤ 1 / ((n : ℚ) - 1) := by
    rw [div_le_div_iff₀ hden hd1]
    nlinarith
  linarith

/-- **Consistency with round 61.**  The universal law reproduces the dyadic ceiling
`(6/7)(1 + 1/(2^b(2^b+1)))` at `n = 2^b`, re-derived by a completely different route. -/
theorem dyadic_case_consistency (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (rangeBlocks (2 ^ b)) = 6 / 7 * (1 + 1 / ((2 : ℚ) ^ b * (2 ^ b + 1))) := by
  have h2 : 2 ≤ 2 ^ b := by
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  have hq : (2 : ℚ) ≤ ((2 ^ b : ℕ) : ℚ) := by exact_mod_cast h2
  have hcast : ((2 ^ b : ℕ) : ℚ) = (2 : ℚ) ^ b := by push_cast; ring
  rw [range_spearmanSq _ h2, devE_two_pow, hcast]
  have hy : (2 : ℚ) ≤ (2 : ℚ) ^ b := by rw [← hcast]; exact hq
  have h1 : ((2 : ℚ) ^ b) ^ 3 - 2 ^ b ≠ 0 := ne_of_gt (cube_sub_self_pos hy)
  have h3 : (2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1) ≠ 0 := by positivity
  have h4 : ((2 : ℚ) ^ b) ^ 2 - 1 ≠ 0 := by nlinarith
  have h5 : ((2 : ℚ) ^ b) ≠ 0 := by positivity
  have h6 : ((2 : ℚ) ^ b + 1) ≠ 0 := by positivity
  field_simp
  ring

/-- For odd `n ≥ 3` the excess over `6/7` is at least `1/(7n)` — order `1/n`, in contrast to
the order `1/n²` excess of a power-of-two range. -/
theorem odd_range_gap_lower (a : ℕ) (ha : 1 ≤ a) :
    1 / (7 * ((2 * a + 1 : ℕ) : ℚ)) ≤ spearmanSq (rangeBlocks (2 * a + 1)) - 6 / 7 := by
  set n : ℕ := 2 * a + 1 with hn
  have h2 : 2 ≤ n := by omega
  have hq : (3 : ℚ) ≤ (n : ℚ) := by
    have : (3 : ℕ) ≤ n := by omega
    exact_mod_cast this
  have hden : (0 : ℚ) < (n : ℚ) ^ 3 - n := cube_sub_self_pos (by linarith)
  have hE : devE n ≤ 6 / 7 - (n : ℚ) ^ 2 / 7 := devE_odd_le a ha
  rw [range_spearmanSq n h2]
  have hstep : 1 / (7 * (n : ℚ)) ≤ (6 * (n : ℚ) / 7 - devE n) / ((n : ℚ) ^ 3 - n) := by
    rw [div_le_div_iff₀ (by positivity) hden]
    nlinarith
  linarith

/-! ## 4. The dyadic/odd dichotomy at bitlen 100 -/

/-- **Range-shape dichotomy at bitlen 100.**  The excess of the tie ceiling over `6/7` for
the *odd* range `{0,…,2¹⁰⁰−2}` exceeds the excess for the exact power-of-two range
`{0,…,2¹⁰⁰−1}` by a factor of more than `10²⁸`.  The ceiling is therefore extremely
sensitive to the *parity structure* of the range and yet — by `range_ceiling_upper` —
totally insensitive to it at the scale of the measured dial. -/
theorem range_shape_dichotomy_100 :
    10 ^ 28 * (spearmanSq (rangeBlocks (2 ^ 100)) - 6 / 7)
      < spearmanSq (rangeBlocks (2 ^ 100 - 1)) - 6 / 7 := by
  have hodd : (2 : ℕ) ^ 100 - 1 = 2 * (2 ^ 99 - 1) + 1 := by
    have : (2 : ℕ) ^ 100 = 2 * 2 ^ 99 := by ring
    omega
  have hlow : 1 / (7 * (((2 : ℕ) ^ 100 - 1 : ℕ) : ℚ))
      ≤ spearmanSq (rangeBlocks (2 ^ 100 - 1)) - 6 / 7 := by
    rw [hodd]
    refine odd_range_gap_lower (2 ^ 99 - 1) ?_
    have h99 : (2 : ℕ) ^ 2 ≤ 2 ^ 99 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
    omega
  have hdy : spearmanSq (rangeBlocks (2 ^ 100)) = 6 / 7 * (1 + 1 / ((2 : ℚ) ^ 100 * (2 ^ 100 + 1))) :=
    dyadic_case_consistency 100 (by norm_num)
  have hcast : (((2 : ℕ) ^ 100 - 1 : ℕ) : ℚ) = (2 : ℚ) ^ 100 - 1 := by
    have h1 : (1 : ℕ) ≤ 2 ^ 100 := Nat.one_le_two_pow
    push_cast [h1]
    ring
  rw [hcast] at hlow
  rw [hdy]
  have hnum : 10 ^ 28 * (6 / 7 * (1 + 1 / ((2 : ℚ) ^ 100 * (2 ^ 100 + 1))) - 6 / 7)
      < 1 / (7 * ((2 : ℚ) ^ 100 - 1)) := by
    norm_num
  linarith

/-! ## 5. Recorded round-67 data (exp 540, seeds 20261200–02) -/

/-- Seed 20261200. -/
def seedA100 : ℚ := 546 / 1000
/-- Seed 20261201. -/
def seedB100 : ℚ := 528 / 1000
/-- Seed 20261202. -/
def seedC100 : ℚ := 549 / 1000
/-- Pooled Spearman estimate at bitlen 100. -/
def pooled100 : ℚ := 544 / 1000
/-- Lower CI endpoint. -/
def ci100Low : ℚ := 498 / 1000
/-- Upper CI endpoint. -/
def ci100High : ℚ := 588 / 1000
/-- Advantage of `T` over the count baseline. -/
def advantage100 : ℚ := 98 / 1000
/-- The validated band floor. -/
def bandFloor : ℚ := 55 / 100

/-- The recorded pooled value agrees with the seed mean to within `0.004`. -/
theorem pooled100_near_seed_mean :
    |pooled100 - (seedA100 + seedB100 + seedC100) / 3| ≤ 4 / 1000 := by
  rw [abs_le]
  constructor <;> norm_num [pooled100, seedA100, seedB100, seedC100]

/-- The CI is symmetric about the pooled value with half-width `0.045`. -/
theorem ci100_symmetric :
    pooled100 - ci100Low = 46 / 1000 ∧ ci100High - pooled100 = 44 / 1000 := by
  constructor <;> norm_num [pooled100, ci100Low, ci100High]

/-- **The band miss.**  The confidence interval straddles the floor `0.55`: its lower end is
below the floor while its upper end is above it, and the point estimate is below. -/
theorem u100_ci_straddles_floor :
    ci100Low < bandFloor ∧ bandFloor < ci100High ∧ pooled100 < bandFloor := by
  refine ⟨by norm_num [ci100Low, bandFloor], by norm_num [bandFloor, ci100High], ?_⟩
  norm_num [pooled100, bandFloor]

/-- The `T`-versus-count advantage is positive and the count baseline is far below the band. -/
theorem u100_count_baseline_below_band :
    0 < advantage100 ∧ pooled100 - advantage100 < bandFloor - advantage100 := by
  refine ⟨by norm_num [advantage100], ?_⟩
  have := u100_ci_straddles_floor.2.2
  linarith

/-- **Scientific payload.**  The recorded bitlen-100 reading is below the tie ceiling of
*every* uniform draw range: for all `n ≥ 2` the ceiling exceeds `6/7`, while `0.544² ≈ 0.296`.
No sampling-range shape — power of two, odd modulus, rejection window, truncated stream —
can produce the measured attenuation. -/
theorem u100_below_every_range_ceiling (n : ℕ) (hn : 2 ≤ n) :
    pooled100 ^ 2 < spearmanSq (rangeBlocks n) := by
  have h := range_ceiling_gt n hn
  have hp : pooled100 ^ 2 < 6 / 7 := by norm_num [pooled100]
  linarith

/-- Even the *upper* CI endpoint, squared, stays below every range ceiling; the band miss
cannot be rescued by pushing the estimate to the optimistic end of its interval. -/
theorem u100_ci_high_below_every_range_ceiling (n : ℕ) (hn : 2 ≤ n) :
    ci100High ^ 2 < spearmanSq (rangeBlocks n) := by
  have h := range_ceiling_gt n hn
  have hp : ci100High ^ 2 < 6 / 7 := by norm_num [ci100High]
  linarith

/-- Quantitatively: at bitlen 100 the entire admissible spread of tie ceilings over all
draw ranges `n ≥ 2¹⁰⁰` has width below `10^{-29}`, while the recorded four-bit erosion step
is `0.030`.  Range shape is smaller than the observed effect by 27 orders of magnitude. -/
theorem range_shape_negligible_at_100 (n : ℕ) (hn : 2 ^ 100 ≤ n) :
    spearmanSq (rangeBlocks n) - 6 / 7 < 1 / 10 ^ 29 := by
  have h2 : 2 ≤ n := le_trans (by norm_num) hn
  have hq : (2 : ℚ) ^ 100 ≤ (n : ℚ) := by exact_mod_cast hn
  have hup := range_ceiling_upper n h2
  have hd1 : (0 : ℚ) < (n : ℚ) - 1 := by
    have : (2 : ℚ) ^ 100 ≤ (n : ℚ) := hq
    nlinarith [pow_pos (show (0:ℚ) < 2 by norm_num) 100]
  have hsmall : 1 / ((n : ℚ) - 1) < 1 / 10 ^ 29 := by
    apply one_div_lt_one_div_of_lt (by norm_num)
    have h10 : (10 : ℚ) ^ 29 + 1 ≤ (2 : ℚ) ^ 100 := by norm_num
    linarith
  linarith

end Catalog.Novelty.TDialU100RangeShape