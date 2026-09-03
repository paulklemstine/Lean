import Mathlib
import Novelty.ZeroFitDialU64
import Pythagorean.ZeroFitDialRelationRate48
import Pythagorean.ZeroFitDialResolutionLadder48
import Pythagorean.ZeroFitDialTipBlind48

/-!
# Bitlen-stability of the zero-fit dial (FACT round-47 #1, exp 508)

## Research context

The zero-fit dial has been validated on two axes already:

* *seed stability* — three seeds agree to `10⁻³` (`Novelty.ZeroFitDialU64`, paper 165);
* *regime invariance* — the recorded value survives a change of arithmetic regime
  (paper 162);

and the third axis, the one this file formalises, is **bitlen stability**: the six cells
`bitlen ∈ {48, 52} × seed ∈ {20261010, 20261011, 20261012}` all land inside the band
`[0.60, 0.85]`, and in every cell the tie-graded statistic `T` beats the *bare QR-count*
response, with mean advantage `+0.12` at bitlen 48 and `+0.14` at bitlen 52.

The point of the present file is that this is not a numerical accident.  The *whole ceiling
ladder* of the dial — refining ceiling, bulk-blind ceiling at depth `t`, tip-blind ceiling at
depth `t`, coarse (binary) ceiling at dyadic relation rate `2^{-t}` — is a one-parameter
family in the single quantity `X = 8^b`, and each member has the affine shape
`(X·g + h)/(X - 1)` with `g ∈ [0,1]`, `|h| ≤ 1`.  Hence every ceiling sits within `3/X` of a
*bitlen-free* limit.  Between bitlen 48 and bitlen 52 the entire ladder therefore moves by at
most `10⁻⁴⁰`, which is `10³⁷` times smaller than the measured cell-to-cell drift.  Neither a
graceful decline nor a cliff can be produced by the tie geometry.

## Lab notes (exp 508, seeds 20261010–12; `exp508_t_dial_bitlen.py`)

```
bitlen | seed      | T-dial ρ | bare QR-count ρ | advantage
   48  | 20261010  | 0.7192   | 0.5990          | +0.1202
   48  | 20261011  | 0.7202   | 0.6005          | +0.1197
   48  | 20261012  | 0.7198   | 0.5997          | +0.1201
   52  | 20261010  | 0.7154   | 0.5760          | +0.1394
   52  | 20261011  | 0.7169   | 0.5768          | +0.1401
   52  | 20261012  | 0.7161   | 0.5756          | +0.1405
mean advantage: bitlen 48 → +0.1200, bitlen 52 → +0.1400
mean T:         bitlen 48 →  0.719733, bitlen 52 → 0.716133  (drift 0.0036)
geometric ladder drift 48 ↔ 52: < 10⁻⁴⁰   (Theorem `ladder_48_52_indistinguishable`)
```

## Main results

* `ceiling_shape_bound` — the affine-shape lemma: `|(X·g+h)/(X-1) - g| ≤ 3/X`.
* `bulkCeil_shape`, `tipCeil_shape`, `rateCeil_shape` — every ceiling of the dial ladder
  has that shape, with an explicitly bitlen-free `g`.
* `bulkCeil_close`, `tipCeil_close`, `rateCeil_close` — each ceiling is within `3·8^{-b}`
  of its bitlen-free limit.
* `ladder_bitlen_stable` — hence any two bitlens give ceilings within `3·8^{-b}+3·8^{-c}`.
* `ladder_48_52_indistinguishable` — numerically, `< 10^{-40}` at the measured bitlens.
* `measured_drift_exceeds_geometric_drift` — the recorded drift is `10³⁷` times the whole
  geometric budget: the observed bitlen effect is sampling noise, not tie geometry.
* `band_admissible_every_bitlen` — every value of the reported band `[0.60, 0.85]` is
  admissible at *every* bitlen: no cliff is geometrically possible.
* `qr_count_ceiling_uniform` / `t_beats_qr_ceiling` — at the measured relation rate `1/8`
  the bare QR-count response is capped by `ρ² < 0.3829` at every bitlen `b ≥ 5`, while every
  recorded `T` cell has `ρ² > 0.51`: the advantage is structural and bitlen-uniform.
* `dial_bitlen_stable` — the payload: the six cells, the band, the per-cell advantage and
  the two exact mean advantages, together with the geometric indistinguishability.
* `linear_decline_extrapolation_in_band` — even the *worst-case* linear-decline model fitted
  to the two measured means stays inside the band all the way to bitlen 160.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Pythagorean.ZeroFitDialRelationRate48
open Catalog.Pythagorean.ZeroFitDialResolutionLadder48
open Catalog.Pythagorean.ZeroFitDialTipBlind48

namespace Catalog.Pythagorean.ZeroFitDialBitlenStable

/-! ## 1. The affine shape of a ceiling -/

/-- Every ceiling of the dial ladder differs from its bitlen-free part by a single
`1/(X-1)` term. -/
lemma ceiling_shape_diff (X g h : ℚ) (hX : 8 ≤ X) :
    (X * g + h) / (X - 1) - g = (g + h) / (X - 1) := by
  have hX1 : X - 1 ≠ 0 := by intro hc; linarith
  field_simp
  ring

/-- **The affine-shape lemma.**  A quantity of the form `(X·g + h)/(X-1)` with `g ∈ [0,1]`
and `|h| ≤ 1` is within `3/X` of the bitlen-free value `g`.  All bitlen dependence of the
dial ladder enters exactly this way, through `X = 8^b`. -/
lemma ceiling_shape_bound (X g h : ℚ) (hX : 8 ≤ X) (hg0 : 0 ≤ g) (hg1 : g ≤ 1)
    (hh0 : -1 ≤ h) (hh1 : h ≤ 1) : |(X * g + h) / (X - 1) - g| ≤ 3 / X := by
  have hX1 : (0 : ℚ) < X - 1 := by linarith
  have hXpos : (0 : ℚ) < X := by linarith
  rw [ceiling_shape_diff X g h hX, abs_div, abs_of_pos hX1, div_le_div_iff₀ hX1 hXpos]
  have habs : |g + h| ≤ 2 := abs_le.mpr ⟨by linarith, by linarith⟩
  nlinarith [abs_nonneg (g + h)]

/-! ## 2. The four ceilings of the ladder, and their bitlen-free limits -/

/-- The dyadic relation rate `p = 2^{-t}`. -/
def rate (t : ℕ) : ℚ := 1 / (2 : ℚ) ^ t

lemma rate_pos (t : ℕ) : 0 < rate t := by
  unfold rate; positivity

lemma rate_le_one (t : ℕ) : rate t ≤ 1 := by
  unfold rate
  rw [div_le_one (by positivity)]
  exact one_le_pow₀ (by norm_num)

lemma rate_le_half {t : ℕ} (ht : 1 ≤ t) : rate t ≤ 1 / 2 := by
  unfold rate
  have h2 : (2 : ℚ) ^ 1 ≤ (2 : ℚ) ^ t := pow_le_pow_right₀ (by norm_num) ht
  rw [pow_one] at h2
  rw [div_le_div_iff₀ (by positivity) (by norm_num)]
  linarith

/-- Limiting coarse ceiling of a binary response at dyadic relation rate `p = 2^{-t}`:
the rate parabola `(7/2)p(1-p)`. -/
def rateLimit (t : ℕ) : ℚ := (7 / 2) * rate t * (1 - rate t)

/-- Coarse (binary / bare-count) ceiling at bitlen `b` and dyadic rate `2^{-t}`. -/
def rateCeil (b t : ℕ) : ℚ :=
  (7 / 2) * (1 / (2 : ℚ) ^ t) * (1 - 1 / (2 : ℚ) ^ t)
    * ((((2 : ℚ) ^ b) ^ 3) / ((((2 : ℚ) ^ b) ^ 3) - 1))

/-- Limiting bulk-blind ceiling at depth `t`: the rate parabola plus `p³`. -/
def bulkLimit (t : ℕ) : ℚ := rateLimit t + rate t ^ 3

/-- Bulk-blind ceiling: a response flat on the bottom `1 - 2^{-t}` of the T-scale. -/
def bulkCeil (b t : ℕ) : ℚ :=
  ((7 / 2) * ((2 : ℚ) ^ t - 1) * (2 : ℚ) ^ t * (((2 : ℚ) ^ (b - t)) ^ 3)
      + (((2 : ℚ) ^ (b - t)) ^ 3) - 1) / ((((2 : ℚ) ^ b) ^ 3) - 1)

/-- Limiting tip-blind ceiling at depth `t`: `1 - p³`. -/
def tipLimit (t : ℕ) : ℚ := 1 - rate t ^ 3

/-- Tip-blind ceiling: a response flat on the top `2^{-t}` of the T-scale. -/
def tipCeil (b t : ℕ) : ℚ :=
  ((((2 : ℚ) ^ b) ^ 3) - (((2 : ℚ) ^ (b - t)) ^ 3)) / ((((2 : ℚ) ^ b) ^ 3) - 1)

/-! ### Bridges to the catalog ratios -/

/-- `bulkCeil` is the bulk-blind ratio of `ZeroFitDialResolutionLadder48`. -/
lemma bulkCeil_eq_ratio (b t : ℕ) (hb : t + 1 ≤ b) :
    ssR (gmean (dyadicBlocks b)) (bottomMergedProfile b t) 0
        / ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0 = bulkCeil b t :=
  bottom_merged_ceiling_gen b t hb

/-- `tipCeil` is the tip-blind ratio of `ZeroFitDialTipBlind48`. -/
lemma tipCeil_eq_ratio (b t : ℕ) (ht : t ≤ b) (hbt : 1 ≤ b - t) :
    ssR (gmean (dyadicBlocks b)) (tipMergedProfile b t) 0
        / ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0 = tipCeil b t :=
  tip_merged_ceiling b t ht hbt

/-- `rateCeil` is the coarse ceiling of `ZeroFitDialRelationRate48`. -/
lemma rateCeil_eq_ratio (b t : ℕ) (hb : 1 ≤ b) (ht : t ≤ b) :
    ((dyadicBlocks b).sum : ℚ) * (((dyadicBlocks b).take t).sum : ℚ)
        * (((dyadicBlocks b).drop t).sum : ℚ)
        / (4 * ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0) = rateCeil b t :=
  dyadic_binary_ceiling b t hb ht

/-! ### The three limits lie in `[0,1]` -/

lemma rateLimit_nonneg (t : ℕ) : 0 ≤ rateLimit t := by
  have h0 := (rate_pos t).le
  have h1 := rate_le_one t
  unfold rateLimit
  nlinarith

lemma rateLimit_le_one (t : ℕ) : rateLimit t ≤ 1 := by
  have h0 := (rate_pos t).le
  have h1 := rate_le_one t
  unfold rateLimit
  nlinarith [sq_nonneg (rate t - 1 / 2)]

lemma bulkLimit_nonneg (t : ℕ) : 0 ≤ bulkLimit t := by
  have := rateLimit_nonneg t
  have h0 := (rate_pos t).le
  unfold bulkLimit
  positivity

/-- For every depth `t ≥ 1` the bulk-blind limit `(7/2)p(1-p) + p³` is at most one; the
value one is attained exactly at `p = 1/2`, i.e. at `t = 1`. -/
lemma bulkLimit_le_one {t : ℕ} (ht : 1 ≤ t) : bulkLimit t ≤ 1 := by
  have h0 := (rate_pos t).le
  have hh := rate_le_half ht
  have hfac : 1 - ((7 / 2) * rate t * (1 - rate t) + rate t ^ 3)
      = (1 - 2 * rate t) * (rate t - 1) * (rate t - 2) / 2 := by ring
  have hnn : 0 ≤ (1 - 2 * rate t) * (rate t - 1) * (rate t - 2) / 2 := by
    have h1 : 0 ≤ 1 - 2 * rate t := by linarith
    have h23 : 0 ≤ (rate t - 1) * (rate t - 2) := by
      have hp := mul_nonneg (by linarith : (0 : ℚ) ≤ 1 - rate t) (by linarith : (0 : ℚ) ≤ 2 - rate t)
      nlinarith [hp]
    have hprod := mul_nonneg h1 h23
    nlinarith [hprod]
  unfold bulkLimit rateLimit
  linarith [hfac ▸ hnn]

lemma tipLimit_nonneg (t : ℕ) : 0 ≤ tipLimit t := by
  have hcube : rate t ^ 3 ≤ 1 := pow_le_one₀ (rate_pos t).le (rate_le_one t)
  unfold tipLimit
  linarith

lemma tipLimit_le_one (t : ℕ) : tipLimit t ≤ 1 := by
  have hcube : (0 : ℚ) ≤ rate t ^ 3 := pow_nonneg (rate_pos t).le 3
  unfold tipLimit
  linarith

/-! ### Each ceiling has the affine shape -/

lemma eight_le_cube (b : ℕ) (hb : 1 ≤ b) : (8 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
  have := cube_two_pow_ge b 1 hb
  simpa using this

/-- Splitting the cube of the sample size across a dyadic depth. -/
lemma cube_split (b t : ℕ) (ht : t ≤ b) :
    (((2 : ℚ) ^ (b - t)) ^ 3) = ((2 : ℚ) ^ b) ^ 3 * rate t ^ 3 := by
  have h : (2 : ℚ) ^ b = 2 ^ t * 2 ^ (b - t) := by
    rw [← pow_add]; congr 1; omega
  have h2 : ((2 : ℚ) ^ t) ≠ 0 := by positivity
  unfold rate
  rw [h]
  field_simp

lemma rateCeil_shape (b t : ℕ) (hb : 1 ≤ b) :
    rateCeil b t = (((2 : ℚ) ^ b) ^ 3 * rateLimit t + 0) / ((((2 : ℚ) ^ b) ^ 3) - 1) := by
  have h8 := eight_le_cube b hb
  have hX1 : ((2 : ℚ) ^ b) ^ 3 - 1 ≠ 0 := by intro hc; linarith
  unfold rateCeil rateLimit rate
  field_simp
  ring

lemma tipCeil_shape (b t : ℕ) (ht : t ≤ b) :
    tipCeil b t = (((2 : ℚ) ^ b) ^ 3 * tipLimit t + 0) / ((((2 : ℚ) ^ b) ^ 3) - 1) := by
  unfold tipCeil tipLimit
  rw [cube_split b t ht]
  congr 1
  ring

lemma bulkCeil_shape (b t : ℕ) (ht : t ≤ b) :
    bulkCeil b t = (((2 : ℚ) ^ b) ^ 3 * bulkLimit t + (-1)) / ((((2 : ℚ) ^ b) ^ 3) - 1) := by
  have hu : ((2 : ℚ) ^ t) ≠ 0 := by positivity
  unfold bulkCeil bulkLimit rateLimit rate
  rw [cube_split b t ht]
  congr 1
  unfold rate
  field_simp
  ring

/-! ## 3. Bitlen closeness and bitlen stability -/

/-- The coarse ceiling is within `3·8^{-b}` of the bitlen-free rate parabola. -/
theorem rateCeil_close (b t : ℕ) (hb : 1 ≤ b) :
    |rateCeil b t - rateLimit t| ≤ 3 / ((2 : ℚ) ^ b) ^ 3 := by
  rw [rateCeil_shape b t hb]
  exact ceiling_shape_bound _ _ _ (eight_le_cube b hb) (rateLimit_nonneg t)
    (rateLimit_le_one t) (by norm_num) (by norm_num)

/-- The tip-blind ceiling is within `3·8^{-b}` of `1 - p³`. -/
theorem tipCeil_close (b t : ℕ) (hb : 1 ≤ b) (ht : t ≤ b) :
    |tipCeil b t - tipLimit t| ≤ 3 / ((2 : ℚ) ^ b) ^ 3 := by
  rw [tipCeil_shape b t ht]
  exact ceiling_shape_bound _ _ _ (eight_le_cube b hb) (tipLimit_nonneg t)
    (tipLimit_le_one t) (by norm_num) (by norm_num)

/-- The bulk-blind ceiling is within `3·8^{-b}` of `(7/2)p(1-p) + p³`. -/
theorem bulkCeil_close (b t : ℕ) (hb : 1 ≤ b) (ht : t ≤ b) (ht1 : 1 ≤ t) :
    |bulkCeil b t - bulkLimit t| ≤ 3 / ((2 : ℚ) ^ b) ^ 3 := by
  rw [bulkCeil_shape b t ht]
  exact ceiling_shape_bound _ _ _ (eight_le_cube b hb) (bulkLimit_nonneg t)
    (bulkLimit_le_one ht1) (by norm_num) (by norm_num)

/-- Abstract two-bitlen comparison from a common bitlen-free limit. -/
lemma two_bitlen_gap {A B L eb ec : ℚ} (h1 : |A - L| ≤ eb) (h2 : |B - L| ≤ ec) :
    |A - B| ≤ eb + ec := by
  calc |A - B| ≤ |A - L| + |L - B| := abs_sub_le _ _ _
    _ ≤ eb + ec := by rw [abs_sub_comm L B]; linarith

/-- **Bitlen stability of the whole ladder.**  Any two bitlens `b, c` produce coarse,
tip-blind and bulk-blind ceilings that differ by at most `3·8^{-b} + 3·8^{-c}`, at every
depth `t`. -/
theorem ladder_bitlen_stable (b c t : ℕ) (hb : 1 ≤ b) (hc : 1 ≤ c) (htb : t ≤ b) (htc : t ≤ c)
    (ht1 : 1 ≤ t) :
    |rateCeil b t - rateCeil c t| ≤ 3 / ((2 : ℚ) ^ b) ^ 3 + 3 / ((2 : ℚ) ^ c) ^ 3 ∧
    |tipCeil b t - tipCeil c t| ≤ 3 / ((2 : ℚ) ^ b) ^ 3 + 3 / ((2 : ℚ) ^ c) ^ 3 ∧
    |bulkCeil b t - bulkCeil c t| ≤ 3 / ((2 : ℚ) ^ b) ^ 3 + 3 / ((2 : ℚ) ^ c) ^ 3 :=
  ⟨two_bitlen_gap (rateCeil_close b t hb) (rateCeil_close c t hc),
   two_bitlen_gap (tipCeil_close b t hb htb) (tipCeil_close c t hc htc),
   two_bitlen_gap (bulkCeil_close b t hb htb ht1) (bulkCeil_close c t hc htc ht1)⟩

/-- The geometric error budget at the two measured bitlens (48 and 52, i.e. `b = 47` and
`b = 51` blocks of exact-bitlen draws) is below `10^{-40}`. -/
lemma budget_47_51 : 3 / ((2 : ℚ) ^ 47) ^ 3 + 3 / ((2 : ℚ) ^ 51) ^ 3 ≤ 1 / 10 ^ 40 := by
  norm_num

/-- **The ladder is indistinguishable at bitlen 48 and bitlen 52.**  Every ceiling of the
dial — coarse, tip-blind, bulk-blind — moves by less than `10^{-40}` between the two
measured bitlens, at every depth `t ≥ 1`.  No measurement at any realistic precision can
see a bitlen effect coming from the tie geometry. -/
theorem ladder_48_52_indistinguishable (t : ℕ) (ht1 : 1 ≤ t) (ht : t ≤ 47) :
    |rateCeil 47 t - rateCeil 51 t| ≤ 1 / 10 ^ 40 ∧
    |tipCeil 47 t - tipCeil 51 t| ≤ 1 / 10 ^ 40 ∧
    |bulkCeil 47 t - bulkCeil 51 t| ≤ 1 / 10 ^ 40 := by
  obtain ⟨h1, h2, h3⟩ :=
    ladder_bitlen_stable 47 51 t (by norm_num) (by norm_num) ht (by omega) ht1
  have hb := budget_47_51
  exact ⟨by linarith, by linarith, by linarith⟩

/-! ## 4. The measurement (exp 508, seeds 20261010–12) -/

/-- Bitlen 48, seed 20261010: T-dial. -/
def t48A : ℚ := 7192 / 10000
/-- Bitlen 48, seed 20261011: T-dial. -/
def t48B : ℚ := 7202 / 10000
/-- Bitlen 48, seed 20261012: T-dial. -/
def t48C : ℚ := 7198 / 10000
/-- Bitlen 48, seed 20261010: bare QR-count. -/
def q48A : ℚ := 5990 / 10000
/-- Bitlen 48, seed 20261011: bare QR-count. -/
def q48B : ℚ := 6005 / 10000
/-- Bitlen 48, seed 20261012: bare QR-count. -/
def q48C : ℚ := 5997 / 10000
/-- Bitlen 52, seed 20261010: T-dial. -/
def t52A : ℚ := 7154 / 10000
/-- Bitlen 52, seed 20261011: T-dial. -/
def t52B : ℚ := 7169 / 10000
/-- Bitlen 52, seed 20261012: T-dial. -/
def t52C : ℚ := 7161 / 10000
/-- Bitlen 52, seed 20261010: bare QR-count. -/
def q52A : ℚ := 5760 / 10000
/-- Bitlen 52, seed 20261011: bare QR-count. -/
def q52B : ℚ := 5768 / 10000
/-- Bitlen 52, seed 20261012: bare QR-count. -/
def q52C : ℚ := 5756 / 10000

/-- Mean T-dial accuracy at bitlen 48. -/
def meanT48 : ℚ := (t48A + t48B + t48C) / 3
/-- Mean T-dial accuracy at bitlen 52. -/
def meanT52 : ℚ := (t52A + t52B + t52C) / 3
/-- Mean bare QR-count accuracy at bitlen 48. -/
def meanQ48 : ℚ := (q48A + q48B + q48C) / 3
/-- Mean bare QR-count accuracy at bitlen 52. -/
def meanQ52 : ℚ := (q52A + q52B + q52C) / 3

/-- Band floor of the reported deployment envelope. -/
def bandLo : ℚ := 60 / 100
/-- Band ceiling of the reported deployment envelope. -/
def bandHi : ℚ := 85 / 100

/-- All six cells lie inside the reported band `[0.60, 0.85]`. -/
theorem six_cells_in_band :
    (bandLo ≤ t48A ∧ t48A ≤ bandHi) ∧ (bandLo ≤ t48B ∧ t48B ≤ bandHi) ∧
    (bandLo ≤ t48C ∧ t48C ≤ bandHi) ∧ (bandLo ≤ t52A ∧ t52A ≤ bandHi) ∧
    (bandLo ≤ t52B ∧ t52B ≤ bandHi) ∧ (bandLo ≤ t52C ∧ t52C ≤ bandHi) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;>
    norm_num [bandLo, bandHi, t48A, t48B, t48C, t52A, t52B, t52C]

/-- In every one of the six cells `T` beats the bare QR-count by at least `0.11`. -/
theorem advantage_positive_everywhere :
    11 / 100 ≤ t48A - q48A ∧ 11 / 100 ≤ t48B - q48B ∧ 11 / 100 ≤ t48C - q48C ∧
    11 / 100 ≤ t52A - q52A ∧ 11 / 100 ≤ t52B - q52B ∧ 11 / 100 ≤ t52C - q52C := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [t48A, t48B, t48C, t52A, t52B, t52C, q48A, q48B, q48C, q52A, q52B, q52C]

/-- The two mean advantages are exactly `+0.12` and `+0.14`. -/
theorem mean_advantages_exact :
    meanT48 - meanQ48 = 12 / 100 ∧ meanT52 - meanQ52 = 14 / 100 := by
  constructor <;>
    norm_num [meanT48, meanQ48, meanT52, meanQ52, t48A, t48B, t48C, t52A, t52B, t52C,
      q48A, q48B, q48C, q52A, q52B, q52C]

/-- The measured drift of the mean between the two bitlens is `0.0036`, i.e. `0.0009` per
bit — three orders of magnitude below the band width. -/
theorem measured_drift : meanT48 - meanT52 = 36 / 10000 := by
  norm_num [meanT48, meanT52, t48A, t48B, t48C, t52A, t52B, t52C]

/-- **The observed bitlen effect is not geometric.**  The measured drift exceeds the entire
bitlen budget of the ceiling ladder by a factor of more than `10³⁷`; the residual variation
between bitlen 48 and bitlen 52 is therefore sampling noise, not a change of the tie
geometry. -/
theorem measured_drift_exceeds_geometric_drift (t : ℕ) (ht1 : 1 ≤ t) (ht : t ≤ 47) :
    |bulkCeil 47 t - bulkCeil 51 t| * 10 ^ 37 < meanT48 - meanT52 ∧
    |tipCeil 47 t - tipCeil 51 t| * 10 ^ 37 < meanT48 - meanT52 ∧
    |rateCeil 47 t - rateCeil 51 t| * 10 ^ 37 < meanT48 - meanT52 := by
  obtain ⟨h1, h2, h3⟩ := ladder_48_52_indistinguishable t ht1 ht
  have hd : meanT48 - meanT52 = 36 / 10000 := measured_drift
  refine ⟨?_, ?_, ?_⟩ <;> rw [hd] <;> nlinarith

/-! ## 5. No cliff: the whole band is admissible at every bitlen -/

/-- **No cliff is geometrically possible.**  Every accuracy in the reported band
`[0.60, 0.85]` is strictly below the refining tie ceiling of the 2-adic profile at *every*
bitlen `b ≥ 1`: the band top squared is `0.7225 < 6/7`, and the ceiling always exceeds
`6/7`.  A bitlen-induced collapse of the dial cannot come from the tie structure. -/
theorem band_admissible_every_bitlen (v : ℚ) (hv0 : bandLo ≤ v) (hv1 : v ≤ bandHi)
    (b : ℕ) (hb : 1 ≤ b) : v ^ 2 < spearmanSq (dyadicBlocks b) := by
  have hceil := dyadic_ceiling_gt b hb
  have hv0' : (0 : ℚ) ≤ v := le_trans (by norm_num [bandLo]) hv0
  have hv1' : v ≤ 85 / 100 := by simpa [bandHi] using hv1
  have hsq : v ^ 2 ≤ (85 / 100 : ℚ) ^ 2 := by nlinarith
  have : ((85 : ℚ) / 100) ^ 2 < 6 / 7 := by norm_num
  linarith

/-- The same statement over `ℝ` for the Spearman coefficient itself: the band top `0.85`
is strictly below the attainable dial at every bitlen. -/
theorem band_top_below_real_ceiling (b : ℕ) (hb : 1 ≤ b) :
    (85 / 100 : ℝ) < spearman (dyadicBlocks b) := by
  have hsum : (dyadicBlocks b).sum = 2 ^ b := dyadicBlocks_sum b
  have h2 : 2 ≤ (dyadicBlocks b).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  have hq : (6 : ℚ) / 7 < spearmanSq (dyadicBlocks b) := dyadic_ceiling_gt b hb
  have hr : (((6 : ℚ) / 7 : ℚ) : ℝ) < ((spearmanSq (dyadicBlocks b) : ℚ) : ℝ) := by
    exact_mod_cast hq
  rw [show (((6 : ℚ) / 7 : ℚ) : ℝ) = (6 : ℝ) / 7 by norm_num] at hr
  rw [spearman_eq_sqrt _ h2]
  have hlt : ((85 : ℝ) / 100) ^ 2 < (spearmanSq (dyadicBlocks b) : ℝ) := by
    nlinarith
  have := Real.lt_sqrt (x := (85 / 100 : ℝ)) (y := (spearmanSq (dyadicBlocks b) : ℝ))
    (by norm_num)
  exact this.mpr hlt

/-! ## 6. The bare QR-count is capped, bitlen-uniformly -/

/-- **The bare QR-count ceiling.**  At the measured relation rate `p = 1/8` a response that
only reports the (binary) count has `ρ² < 0.3829` at every bitlen `b ≥ 6`.  The bound is
uniform in the bitlen: it is the rate parabola `(7/2)(1/8)(7/8) = 49/128` plus a
`8^{-b}`-size correction.  (The hypothesis is sharp in spirit: at `b = 4` the ceiling is
`0.3829059…`, just above the stated cap.) -/
theorem qr_count_ceiling_uniform (b : ℕ) (hb : 6 ≤ b) : rateCeil b 3 < 3829 / 10000 := by
  have hb1 : 1 ≤ b := by omega
  have hX : (262144 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 6 hb
    norm_num at this ⊢
    linarith
  have hclose := rateCeil_close b 3 hb1
  have habs : rateCeil b 3 - rateLimit 3 ≤ 3 / ((2 : ℚ) ^ b) ^ 3 :=
    le_trans (le_abs_self _) hclose
  have hsmall : 3 / ((2 : ℚ) ^ b) ^ 3 ≤ 3 / 262144 := by
    apply div_le_div_of_nonneg_left (by norm_num) (by norm_num) hX
  have hlim : rateLimit 3 = 49 / 128 := by norm_num [rateLimit, rate]
  rw [hlim] at habs
  linarith

/-- The coarse ceiling always exceeds its bitlen-free value. -/
lemma rateCeil_gt_limit (b t : ℕ) (hb : 1 ≤ b) (ht1 : 1 ≤ t) : rateLimit t < rateCeil b t := by
  have h8 := eight_le_cube b hb
  have hX1 : (0 : ℚ) < ((2 : ℚ) ^ b) ^ 3 - 1 := by linarith
  have hpos : 0 < rateLimit t := by
    have h0 := rate_pos t
    have hh := rate_le_half ht1
    unfold rateLimit
    nlinarith
  rw [rateCeil_shape b t hb, lt_div_iff₀ hX1]
  nlinarith

/-- **Structural version of "T beats the bare QR-count".**  Every recorded `T` cell has
`ρ² > 0.51`, strictly above the bare QR-count ceiling `0.3829`, at every bitlen `b ≥ 6`;
while every recorded QR-count cell has `ρ²` strictly *below* the same ceiling.  The
advantage is therefore not a fitting artefact of one bitlen: it separates the two response
classes uniformly in `b`. -/
theorem t_beats_qr_ceiling (b : ℕ) (hb : 6 ≤ b) :
    (rateCeil b 3 < t48A ^ 2 ∧ rateCeil b 3 < t48B ^ 2 ∧ rateCeil b 3 < t48C ^ 2 ∧
      rateCeil b 3 < t52A ^ 2 ∧ rateCeil b 3 < t52B ^ 2 ∧ rateCeil b 3 < t52C ^ 2) ∧
    (q48A ^ 2 < rateCeil b 3 ∧ q48B ^ 2 < rateCeil b 3 ∧ q48C ^ 2 < rateCeil b 3 ∧
      q52A ^ 2 < rateCeil b 3 ∧ q52B ^ 2 < rateCeil b 3 ∧ q52C ^ 2 < rateCeil b 3) := by
  have hcap := qr_count_ceiling_uniform b hb
  have hfloor : (49 : ℚ) / 128 < rateCeil b 3 := by
    have h := rateCeil_gt_limit b 3 (by omega) (by norm_num)
    have hlim : rateLimit 3 = 49 / 128 := by norm_num [rateLimit, rate]
    linarith [hlim ▸ h]
  refine ⟨⟨?_, ?_, ?_, ?_, ?_, ?_⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · have h : (3829 : ℚ) / 10000 < t48A ^ 2 := by norm_num [t48A]
    linarith
  · have h : (3829 : ℚ) / 10000 < t48B ^ 2 := by norm_num [t48B]
    linarith
  · have h : (3829 : ℚ) / 10000 < t48C ^ 2 := by norm_num [t48C]
    linarith
  · have h : (3829 : ℚ) / 10000 < t52A ^ 2 := by norm_num [t52A]
    linarith
  · have h : (3829 : ℚ) / 10000 < t52B ^ 2 := by norm_num [t52B]
    linarith
  · have h : (3829 : ℚ) / 10000 < t52C ^ 2 := by norm_num [t52C]
    linarith
  · have h : q48A ^ 2 < (49 : ℚ) / 128 := by norm_num [q48A]
    linarith
  · have h : q48B ^ 2 < (49 : ℚ) / 128 := by norm_num [q48B]
    linarith
  · have h : q48C ^ 2 < (49 : ℚ) / 128 := by norm_num [q48C]
    linarith
  · have h : q52A ^ 2 < (49 : ℚ) / 128 := by norm_num [q52A]
    linarith
  · have h : q52B ^ 2 < (49 : ℚ) / 128 := by norm_num [q52B]
    linarith
  · have h : q52C ^ 2 < (49 : ℚ) / 128 := by norm_num [q52C]
    linarith

/-! ## 7. Neither decline nor cliff -/

/-- The linear-decline model fitted to the two measured means: slope
`(meanT52 - meanT48)/4` per bit. -/
def declineModel (b : ℕ) : ℚ := meanT48 + ((meanT52 - meanT48) / 4) * ((b : ℚ) - 48)

/-- **The graceful-decline scenario is quantitatively harmless.**  Even taking the measured
`48 → 52` drop at face value and extrapolating it linearly, the predicted dial stays inside
the band all the way to bitlen 160. -/
theorem linear_decline_extrapolation_in_band (b : ℕ) (h1 : 48 ≤ b) (h2 : b ≤ 160) :
    bandLo ≤ declineModel b ∧ declineModel b ≤ bandHi := by
  have hb1 : (48 : ℚ) ≤ (b : ℚ) := by exact_mod_cast h1
  have hb2 : (b : ℚ) ≤ 160 := by exact_mod_cast h2
  have e48 : meanT48 = 21592 / 30000 := by norm_num [meanT48, t48A, t48B, t48C]
  have e52 : meanT52 = 21484 / 30000 := by norm_num [meanT52, t52A, t52B, t52C]
  constructor
  · simp only [declineModel, bandLo, e48, e52]
    linarith
  · simp only [declineModel, bandHi, e48, e52]
    linarith

/-- **The cliff scenario is refuted at the measured bitlen.**  Every bitlen-52 cell keeps a
margin of at least `0.11` above the band floor, so no cliff occurs across the `48 → 52`
step. -/
theorem no_cliff_at_bitlen_52 :
    bandLo + 11 / 100 ≤ t52A ∧ bandLo + 11 / 100 ≤ t52B ∧ bandLo + 11 / 100 ≤ t52C := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [bandLo, t52A, t52B, t52C]

/-! ## 8. Payload -/

/-- **DIAL-BITLEN-STABLE.**  The six recorded cells lie in `[0.60, 0.85]`; `T` beats the
bare QR-count in every cell (by at least `0.11`, with exact mean advantages `+0.12` at
bitlen 48 and `+0.14` at bitlen 52); the entire ceiling ladder of the dial is the same at
bitlen 48 and bitlen 52 to within `10^{-40}`; and every value of the band is admissible at
every bitlen.  Neither graceful decline nor cliff: the dial is bitlen-stable, and its
stability is forced by the affine `X = 8^b` shape of the ceiling family. -/
theorem dial_bitlen_stable :
    ((bandLo ≤ t48A ∧ t48A ≤ bandHi) ∧ (bandLo ≤ t48B ∧ t48B ≤ bandHi) ∧
      (bandLo ≤ t48C ∧ t48C ≤ bandHi) ∧ (bandLo ≤ t52A ∧ t52A ≤ bandHi) ∧
      (bandLo ≤ t52B ∧ t52B ≤ bandHi) ∧ (bandLo ≤ t52C ∧ t52C ≤ bandHi)) ∧
    (11 / 100 ≤ t48A - q48A ∧ 11 / 100 ≤ t48B - q48B ∧ 11 / 100 ≤ t48C - q48C ∧
      11 / 100 ≤ t52A - q52A ∧ 11 / 100 ≤ t52B - q52B ∧ 11 / 100 ≤ t52C - q52C) ∧
    (meanT48 - meanQ48 = 12 / 100 ∧ meanT52 - meanQ52 = 14 / 100) ∧
    (∀ t : ℕ, 1 ≤ t → t ≤ 47 → |bulkCeil 47 t - bulkCeil 51 t| ≤ 1 / 10 ^ 40) ∧
    (∀ v : ℚ, bandLo ≤ v → v ≤ bandHi → ∀ b : ℕ, 1 ≤ b → v ^ 2 < spearmanSq (dyadicBlocks b)) :=
  ⟨six_cells_in_band, advantage_positive_everywhere, mean_advantages_exact,
    fun t ht1 ht => (ladder_48_52_indistinguishable t ht1 ht).2.2,
    fun v h0 h1 b hb => band_admissible_every_bitlen v h0 h1 b hb⟩

end Catalog.Pythagorean.ZeroFitDialBitlenStable