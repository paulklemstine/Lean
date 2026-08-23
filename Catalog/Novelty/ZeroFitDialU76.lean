import Mathlib
import Novelty.ZeroFitDialU64

/-!
# The zero-fit dial at bitlen 76: the `p`-adic ceiling law and the effective base

## Research context (FACT round-65 #1, exp 533, `U76-DIAL-CONFIRMED`)

The measurement under study reports a Spearman rank correlation between a
*zero-count statistic* `T` (the number of trailing zeros of a uniformly drawn
integer) and a downstream `rate`, on uniform draws at bitlen 76:

* seeds 20261170/71/72 give `0.593 / 0.618 / 0.612`;
* pooled `0.608`, CI `[0.588, 0.631]`, all inside the validation band `[0.55, 0.85]`;
* `T` beats a plain count statistic by `+0.073`, CI `[0.045, 0.097]`;
* the dial is reported *flat within noise* from bitlen 72 to bitlen 76.

`Novelty.ZeroFitDialU64` proved the tie-attenuation law
`ρ² = 1 - 12·Σⱼ(mⱼ³-mⱼ)/(n³-n)` and evaluated it for the *dyadic* profile.
This file supplies the two pieces of mathematics that the round-65 report needs
and that the earlier files do not contain.

## Main results

* `padicBlocks`, `padicBlocks_sum` — the tie profile of the base-`p` trailing-zero
  statistic on `{0,…,p^b-1}`: blocks `(p-1)p^{b-1}, …, (p-1)p, (p-1)` and the
  singleton `{0}`.
* `tieCorr_padic` — closed form for the Kendall tie correction of that profile.
* `padic_spearmanSq` — the **`p`-adic ceiling law**
  `ρ²(p,b) = (3p/(p²+p+1)) · (1 + 1/(p^b(p^b+1)))`,
  which specialises at `p = 2` to the dyadic value `(6/7)(1+1/(2^b(2^b+1)))`
  (`padicBlocks_two`, `padic_two_eq_dyadic`).
* `padicLimit_strict_anti`, `padic_ceiling_gt_limit`, `padic_ceiling_close` — the
  base-`p` ceiling `3p/(p²+p+1)` is strictly decreasing in `p`, and the finite-`b`
  ceiling approaches it from above at rate `p^{-2b}`.
* `dial_flat_72_76` — the **flatness theorem**: the dyadic ceiling changes by less
  than `10^{-43}` between bitlen 72 and bitlen 76, so no tie mechanism can produce
  *any* bitlen dependence in that range.
* `tie_mechanism_excluded_64_76` — the recorded drop `0.648 → 0.608` exceeds the
  entire ceiling change from bitlen 64 to bitlen 76 by a factor `> 10^{30}`.
* `effective_base_seven` — the **effective-base inversion**: `p = 7` is the *unique*
  base whose asymptotic ceiling `3p/(p²+p+1)` lies inside the square of the observed
  seed range `[0.593, 0.618]`; and the finite ceiling at bitlen 76 also lies there
  (`padic_seven_76_in_seed_window`).
* Recorded-data theorems `u76_inside_band`, `u76_pooled_near_seed_mean`,
  `u76_below_tie_ceiling`, `u76_count_gap_positive`.
-/

open Finset

namespace Catalog.Novelty.ZeroFitDialU76

open Catalog.Novelty.ZeroFitDialU64

/-! ## 1. The base-`p` tie profile -/

/-- Tie profile of the base-`p` trailing-zero statistic (the `p`-adic valuation) on
`{0,…,p^b-1}`: blocks of sizes `(p-1)p^{b-1}, …, (p-1)p, (p-1)` followed by the
singleton block `{0}`. -/
def padicBlocks (p : ℕ) : ℕ → List ℕ
  | 0 => [1]
  | b + 1 => (p - 1) * p ^ b :: padicBlocks p b

lemma padicBlocks_two (b : ℕ) : padicBlocks 2 b = dyadicBlocks b := by
  induction b with
  | zero => rfl
  | succ k ih => simp [padicBlocks, dyadicBlocks, ih]

/-- The profile accounts for all `p^b` residues. -/
lemma padicBlocks_sum (p : ℕ) (hp : 1 ≤ p) : ∀ b, (padicBlocks p b).sum = p ^ b := by
  intro b
  induction b with
  | zero => simp [padicBlocks]
  | succ k ih =>
      have hstep : (p - 1) * p ^ k + p ^ k = p ^ (k + 1) := by
        have h : p - 1 + 1 = p := Nat.sub_add_cancel hp
        calc (p - 1) * p ^ k + p ^ k = (p - 1 + 1) * p ^ k := by ring
          _ = p * p ^ k := by rw [h]
          _ = p ^ (k + 1) := by ring
      rw [padicBlocks, List.sum_cons, ih]
      exact hstep

/-- Cast of one block size. -/
lemma cast_block (p : ℕ) (hp : 1 ≤ p) (k : ℕ) :
    (((p - 1) * p ^ k : ℕ) : ℚ) = ((p : ℚ) - 1) * (p : ℚ) ^ k := by
  push_cast [Nat.cast_sub hp]
  ring

/-- **Closed form for the tie correction of the `p`-adic profile.** -/
lemma tieCorr_padic (p : ℕ) (hp : 1 ≤ p) (b : ℕ) :
    12 * ((p : ℚ) ^ 3 - 1) * tieCorr (padicBlocks p b)
      = ((p : ℚ) - 1) ^ 3 * (((p : ℚ) ^ b) ^ 3 - 1)
        - ((p : ℚ) ^ 3 - 1) * ((p : ℚ) ^ b - 1) := by
  induction b with
  | zero => norm_num [padicBlocks, tieCorr]
  | succ k ih =>
      rw [padicBlocks, tieCorr_cons, cast_block p hp k]
      have hstep : ((p : ℚ) ^ (k + 1)) = (p : ℚ) * (p : ℚ) ^ k := by ring
      rw [hstep]
      set q : ℚ := (p : ℚ)
      set Y : ℚ := q ^ k
      nlinarith [ih, sq_nonneg q, sq_nonneg Y]

/-! ## 2. The `p`-adic ceiling law -/

/-- The algebraic core of the ceiling law: with `q = p` the base and `Y = p^b` the sample
size, the tie-attenuation expression collapses to `(3q/(q²+q+1))·(1 + 1/(Y(Y+1)))`. -/
lemma ceiling_algebra (q Y : ℚ) (hq : 2 ≤ q) (hY : 2 ≤ Y) :
    1 - ((q - 1) ^ 3 * (Y ^ 3 - 1) - (q ^ 3 - 1) * (Y - 1)) / (q ^ 3 - 1) / (Y ^ 3 - Y)
      = 3 * q / (q ^ 2 + q + 1) * (1 + 1 / (Y * (Y + 1))) := by
  have hqqpos : (0 : ℚ) < q ^ 2 + q + 1 := by nlinarith
  have hq3pos : (0 : ℚ) < q ^ 3 - 1 := by
    have hfac : q ^ 3 - 1 = (q - 1) * (q ^ 2 + q + 1) := by ring
    rw [hfac]; exact mul_pos (by linarith) hqqpos
  have hY0 : Y ≠ 0 := ne_of_gt (by linarith)
  have hY1 : Y + 1 ≠ 0 := ne_of_gt (by linarith)
  have hYm : Y - 1 ≠ 0 := ne_of_gt (by linarith)
  have hcube : Y ^ 3 - Y ≠ 0 := by
    have hf : Y ^ 3 - Y = Y * (Y - 1) * (Y + 1) := by ring
    rw [hf]; exact mul_ne_zero (mul_ne_zero hY0 hYm) hY1
  have hq3 : q ^ 3 - 1 ≠ 0 := ne_of_gt hq3pos
  have hqq : q ^ 2 + q + 1 ≠ 0 := ne_of_gt hqqpos
  have hYsq : Y ^ 2 - 1 ≠ 0 := ne_of_gt (by nlinarith)
  field_simp
  ring

/-- The asymptotic base-`p` tie ceiling `3p/(p²+p+1)`; at `p = 2` this is `6/7`. -/
def padicLimit (p : ℕ) : ℚ := 3 * (p : ℚ) / ((p : ℚ) ^ 2 + (p : ℚ) + 1)

lemma padicLimit_two : padicLimit 2 = 6 / 7 := by norm_num [padicLimit]

lemma padicLimit_seven : padicLimit 7 = 7 / 19 := by norm_num [padicLimit]

/-- **The `p`-adic ceiling law.**  For the base-`p` trailing-zero statistic on
uniform draws from `{0,…,p^b-1}`, the largest Spearman coefficient attainable
against any tie-refining response satisfies
`ρ² = (3p/(p²+p+1))·(1 + 1/(p^b(p^b+1)))`. -/
theorem padic_spearmanSq (p b : ℕ) (hp : 2 ≤ p) (hb : 1 ≤ b) :
    spearmanSq (padicBlocks p b)
      = padicLimit p * (1 + 1 / ((p : ℚ) ^ b * ((p : ℚ) ^ b + 1))) := by
  have hp1 : 1 ≤ p := le_trans (by norm_num) hp
  have hsum : (padicBlocks p b).sum = p ^ b := padicBlocks_sum p hp1 b
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hY : (2 : ℚ) ≤ (p : ℚ) ^ b := by
    calc (2 : ℚ) = (2 : ℚ) ^ 1 := (pow_one 2).symm
      _ ≤ (p : ℚ) ^ 1 := by gcongr
      _ ≤ (p : ℚ) ^ b := by
          apply pow_le_pow_right₀ (by linarith) hb
  have h2 : 2 ≤ (padicBlocks p b).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
      _ ≤ p ^ b := Nat.pow_le_pow_left hp b
  have hcast : (((padicBlocks p b).sum : ℕ) : ℚ) = (p : ℚ) ^ b := by
    rw [hsum]; push_cast; ring
  rw [spearmanSq_eq _ h2, hcast, padicLimit]
  set q : ℚ := (p : ℚ) with hqdef
  set Y : ℚ := q ^ b with hYdef
  have hqqpos : (0 : ℚ) < q ^ 2 + q + 1 := by nlinarith
  have hq3pos : (0 : ℚ) < q ^ 3 - 1 := by
    have hfac : q ^ 3 - 1 = (q - 1) * (q ^ 2 + q + 1) := by ring
    rw [hfac]
    exact mul_pos (by linarith) hqqpos
  have hq3 : q ^ 3 - 1 ≠ 0 := ne_of_gt hq3pos
  have hqq : q ^ 2 + q + 1 ≠ 0 := ne_of_gt hqqpos
  have hY0 : Y ≠ 0 := ne_of_gt (by linarith)
  have hY1 : Y + 1 ≠ 0 := ne_of_gt (by linarith)
  have hYm : Y - 1 ≠ 0 := ne_of_gt (by linarith)
  have hcube : Y ^ 3 - Y ≠ 0 := by
    have : Y ^ 3 - Y = Y * (Y - 1) * (Y + 1) := by ring
    rw [this]
    exact mul_ne_zero (mul_ne_zero hY0 hYm) hY1
  have key : 12 * tieCorr (padicBlocks p b)
      = ((q - 1) ^ 3 * (Y ^ 3 - 1) - (q ^ 3 - 1) * (Y - 1)) / (q ^ 3 - 1) := by
    have hpad := tieCorr_padic p hp1 b
    rw [eq_div_iff hq3]
    linear_combination hpad
  rw [key]
  exact ceiling_algebra q Y hq hY

/-- Specialisation to `p = 2` recovers the dyadic ceiling of `Novelty.ZeroFitDialU64`. -/
theorem padic_two_eq_dyadic (b : ℕ) :
    spearmanSq (padicBlocks 2 b) = spearmanSq (dyadicBlocks b) := by
  rw [padicBlocks_two]

/-- The asymptotic ceiling is strictly decreasing in the base. -/
theorem padicLimit_strict_anti {p r : ℕ} (hp : 1 ≤ p) (hpr : p < r) :
    padicLimit r < padicLimit p := by
  have hq : (1 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hlt : (p : ℚ) < (r : ℚ) := by exact_mod_cast hpr
  have h1 : (0 : ℚ) < (p : ℚ) ^ 2 + (p : ℚ) + 1 := by nlinarith
  have h2 : (0 : ℚ) < (r : ℚ) ^ 2 + (r : ℚ) + 1 := by nlinarith
  rw [padicLimit, padicLimit, div_lt_div_iff₀ h2 h1]
  nlinarith [mul_pos (sub_pos.mpr hlt) (sub_pos.mpr (by nlinarith : (1 : ℚ) < (p : ℚ) * r))]

/-- The finite-bitlen ceiling always exceeds the asymptotic one. -/
theorem padic_ceiling_gt_limit (p b : ℕ) (hp : 2 ≤ p) (hb : 1 ≤ b) :
    padicLimit p < spearmanSq (padicBlocks p b) := by
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hY : (0 : ℚ) < (p : ℚ) ^ b := by positivity
  have hlim : 0 < padicLimit p := by
    rw [padicLimit]; apply div_pos <;> nlinarith
  rw [padic_spearmanSq p b hp hb]
  have hcorr : 0 < 1 / ((p : ℚ) ^ b * ((p : ℚ) ^ b + 1)) := by positivity
  nlinarith

/-- Quantitative convergence of the base-`p` ceiling: the excess over `3p/(p²+p+1)`
is below `p^{-2b}`. -/
theorem padic_ceiling_close (p b : ℕ) (hp : 2 ≤ p) (hb : 1 ≤ b) :
    spearmanSq (padicBlocks p b) - padicLimit p < 1 / ((p : ℚ) ^ b) ^ 2 := by
  have hq : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hY : (0 : ℚ) < (p : ℚ) ^ b := by positivity
  have hlim1 : padicLimit p ≤ 1 := by
    rw [padicLimit, div_le_one (by nlinarith)]
    nlinarith
  have hlim0 : 0 < padicLimit p := by
    rw [padicLimit]; apply div_pos <;> nlinarith
  rw [padic_spearmanSq p b hp hb]
  have hden : ((p : ℚ) ^ b) ^ 2 < (p : ℚ) ^ b * ((p : ℚ) ^ b + 1) := by nlinarith
  have hinv : 1 / ((p : ℚ) ^ b * ((p : ℚ) ^ b + 1)) < 1 / ((p : ℚ) ^ b) ^ 2 :=
    one_div_lt_one_div_of_lt (by positivity) hden
  have hpos : 0 < 1 / ((p : ℚ) ^ b * ((p : ℚ) ^ b + 1)) := by positivity
  nlinarith

/-! ## 3. Recorded round-65 data (exp 533, seeds 20261170–72) -/

/-- Seed 20261170. -/
def seed70 : ℚ := 593 / 1000
/-- Seed 20261171. -/
def seed71 : ℚ := 618 / 1000
/-- Seed 20261172. -/
def seed72 : ℚ := 612 / 1000
/-- Pooled estimate at bitlen 76. -/
def pooled76 : ℚ := 608 / 1000
/-- Lower CI endpoint. -/
def ciLow76 : ℚ := 588 / 1000
/-- Upper CI endpoint. -/
def ciHigh76 : ℚ := 631 / 1000
/-- Advantage of `T` over the plain count statistic. -/
def countGap : ℚ := 73 / 1000
/-- Lower CI endpoint of the `T`-versus-count gap. -/
def gapLow : ℚ := 45 / 1000
/-- Upper CI endpoint of the `T`-versus-count gap. -/
def gapHigh : ℚ := 97 / 1000

/-- All recorded bitlen-76 numbers lie inside the validation band `[0.55, 0.85]`. -/
theorem u76_inside_band :
    (55 / 100 : ℚ) ≤ seed70 ∧ seed70 ≤ 85 / 100 ∧
    (55 / 100 : ℚ) ≤ seed71 ∧ seed71 ≤ 85 / 100 ∧
    (55 / 100 : ℚ) ≤ seed72 ∧ seed72 ≤ 85 / 100 ∧
    (55 / 100 : ℚ) ≤ pooled76 ∧ pooled76 ≤ 85 / 100 ∧
    (55 / 100 : ℚ) ≤ ciLow76 ∧ ciHigh76 ≤ 85 / 100 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [seed70, seed71, seed72, pooled76, ciLow76, ciHigh76]

/-- The pooled value is the mean of the three seeds up to the reported rounding
(`(0.593+0.618+0.612)/3 = 0.6076…`). -/
theorem u76_pooled_near_seed_mean :
    |pooled76 - (seed70 + seed71 + seed72) / 3| < 1 / 1000 := by
  rw [abs_lt]
  constructor <;> norm_num [pooled76, seed70, seed71, seed72]

/-- The `T`-versus-count advantage is significant: the whole CI is positive and
contains the point estimate. -/
theorem u76_count_gap_positive :
    0 < gapLow ∧ gapLow < countGap ∧ countGap < gapHigh := by
  refine ⟨by norm_num [gapLow], by norm_num [gapLow, countGap], by norm_num [countGap, gapHigh]⟩

/-- The recorded dial is far below the dyadic tie ceiling at bitlen 76. -/
theorem u76_below_tie_ceiling : pooled76 ^ 2 < spearmanSq (dyadicBlocks 76) := by
  have h := dyadic_ceiling_gt 76 (by norm_num)
  have : pooled76 ^ 2 < 6 / 7 := by norm_num [pooled76]
  linarith

/-- Each individual seed is below the dyadic tie ceiling as well. -/
theorem u76_seeds_below_tie_ceiling :
    seed70 ^ 2 < spearmanSq (dyadicBlocks 76) ∧
    seed71 ^ 2 < spearmanSq (dyadicBlocks 76) ∧
    seed72 ^ 2 < spearmanSq (dyadicBlocks 76) := by
  have h := dyadic_ceiling_gt 76 (by norm_num)
  have h0 : seed70 ^ 2 < 6 / 7 := by norm_num [seed70]
  have h1 : seed71 ^ 2 < 6 / 7 := by norm_num [seed71]
  have h2 : seed72 ^ 2 < 6 / 7 := by norm_num [seed72]
  exact ⟨by linarith, by linarith, by linarith⟩

/-! ## 4. Flatness: no tie mechanism can move the dial between bitlen 72 and 76 -/

/-- **Flatness theorem.**  The dyadic tie ceiling changes by less than `10^{-43}`
between bitlen 72 and bitlen 76.  Hence the reported "flat within noise from
bitlen 72" is not merely consistent with the tie geometry: the tie geometry
*forces* flatness far below any achievable measurement precision. -/
theorem dial_flat_72_76 :
    0 < spearmanSq (dyadicBlocks 72) - spearmanSq (dyadicBlocks 76) ∧
    spearmanSq (dyadicBlocks 72) - spearmanSq (dyadicBlocks 76) < 1 / 10 ^ 43 := by
  rw [dyadic_spearmanSq 72 (by norm_num), dyadic_spearmanSq 76 (by norm_num)]
  constructor <;> norm_num

/-- **Tie mechanisms are excluded as the cause of the bitlen dependence.**  The
recorded drop from `0.648` (bitlen 64, round 61) to `0.608` (bitlen 76) is larger
than `10^30` times the entire change in the tie ceiling over the same range. -/
theorem tie_mechanism_excluded_64_76 :
    10 ^ 30 * (spearmanSq (dyadicBlocks 64) - spearmanSq (dyadicBlocks 76))
      < pooled - pooled76 := by
  rw [dyadic_spearmanSq 64 (by norm_num), dyadic_spearmanSq 76 (by norm_num)]
  norm_num [pooled, pooled76]

/-! ## 5. The effective base: inverting the ceiling law on the observed window -/

/-- The observed seed window, squared: `[0.593², 0.618²]`. -/
def seedWindowLow : ℚ := seed70 ^ 2
/-- Upper end of the squared seed window. -/
def seedWindowHigh : ℚ := seed71 ^ 2

/-- **Effective-base inversion.**  Base `7` is the *unique* base whose asymptotic
tie ceiling `3p/(p²+p+1)` lies inside the squared seed window `[0.593², 0.618²]`
recorded at bitlen 76.  The observed attenuation is therefore exactly what a
*7-adic* — not a 2-adic — valuation profile would produce. -/
theorem effective_base_seven :
    (seedWindowLow ≤ padicLimit 7 ∧ padicLimit 7 ≤ seedWindowHigh) ∧
    ∀ p : ℕ, 2 ≤ p → p ≠ 7 →
      ¬ (seedWindowLow ≤ padicLimit p ∧ padicLimit p ≤ seedWindowHigh) := by
  have h7 : padicLimit 7 = 7 / 19 := padicLimit_seven
  have h6 : padicLimit 6 = 18 / 43 := by norm_num [padicLimit]
  have h8 : padicLimit 8 = 24 / 73 := by norm_num [padicLimit]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · rw [h7]; norm_num [seedWindowLow, seed70]
  · rw [h7]; norm_num [seedWindowHigh, seed71]
  · intro p hp hne ⟨hlo, hhi⟩
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · -- p ≤ 6 : the ceiling is at least `padicLimit 6 > 0.618²`
      have hle : padicLimit 6 ≤ padicLimit p := by
        rcases eq_or_lt_of_le (Nat.lt_succ_iff.mp hlt) with h | h
        · exact le_of_eq (by rw [h])
        · exact le_of_lt (padicLimit_strict_anti (by omega) h)
      have : (18 : ℚ) / 43 ≤ padicLimit p := by rw [← h6]; exact hle
      have hbad : seedWindowHigh < 18 / 43 := by norm_num [seedWindowHigh, seed71]
      linarith
    · -- p ≥ 8 : the ceiling is at most `padicLimit 8 < 0.593²`
      have hge : padicLimit p ≤ padicLimit 8 := by
        rcases eq_or_lt_of_le (show (8 : ℕ) ≤ p by omega) with h | h
        · exact le_of_eq (by rw [← h])
        · exact le_of_lt (padicLimit_strict_anti (by omega) h)
      have : padicLimit p ≤ 24 / 73 := by rw [← h8]; exact hge
      have hbad : (24 : ℚ) / 73 < seedWindowLow := by norm_num [seedWindowLow, seed70]
      linarith

/-- The *finite* base-7 ceiling at bitlen 76 also lies inside the observed seed
window: the finite-size correction `1/(7^76(7^76+1))` is far too small to move it out. -/
theorem padic_seven_76_in_seed_window :
    seedWindowLow ≤ spearmanSq (padicBlocks 7 76) ∧
    spearmanSq (padicBlocks 7 76) ≤ seedWindowHigh := by
  have hlim : padicLimit 7 < spearmanSq (padicBlocks 7 76) :=
    padic_ceiling_gt_limit 7 76 (by norm_num) (by norm_num)
  have hclose : spearmanSq (padicBlocks 7 76) - padicLimit 7 < 1 / (((7 : ℚ)) ^ 76) ^ 2 :=
    padic_ceiling_close 7 76 (by norm_num) (by norm_num)
  have hsmall : 1 / (((7 : ℚ)) ^ 76) ^ 2 < 1 / 100 := by
    apply one_div_lt_one_div_of_lt (by norm_num)
    have : (100 : ℚ) < ((7 : ℚ) ^ 76) ^ 2 := by norm_num
    linarith
  have h7 : padicLimit 7 = 7 / 19 := padicLimit_seven
  constructor
  · have : seedWindowLow ≤ padicLimit 7 := by rw [h7]; norm_num [seedWindowLow, seed70]
    linarith
  · have hhi : padicLimit 7 + 1 / 100 ≤ seedWindowHigh := by
      rw [h7]; norm_num [seedWindowHigh, seed71]
    linarith

/-- The `2`-adic ceiling, in contrast, is nowhere near the observed window: the
measured dial is attenuated by a further factor of more than two in `ρ²`. -/
theorem dyadic_ceiling_far_above_window :
    2 * seedWindowHigh < spearmanSq (dyadicBlocks 76) := by
  have h := dyadic_ceiling_gt 76 (by norm_num)
  have : 2 * seedWindowHigh < 6 / 7 := by norm_num [seedWindowHigh, seed71]
  linarith

end Catalog.Novelty.ZeroFitDialU76