/-
# NET-74, statistical side: an exact audit of the three reported Spearman
# coefficients

Round 25 of the limited-memory axis (paper 159) reports, for five domains and
three structural predictors of the attention knee `k*@512`, the table

| domain   | entropy | top-8 mass | head agreement | k\*@512 |
|----------|---------|------------|----------------|---------|
| code     | 3.798   | 0.488      | 0.083          | 12      |
| prose-en | 3.801   | 0.488      | 0.082          | 16      |
| math     | 3.615   | 0.526      | 0.086          | 16      |
| prose-de | 3.752   | 0.502      | 0.080          | 20      |
| prose-fr | 3.864   | 0.473      | 0.079          | >24     |

together with the claim

* `entropy ↔ k* = −0.60` (P1 "partial: right sign"),
* `top8 ↔ k* = +0.80` (P2 "confirmed: strongest correlate"),
* `headvar ↔ k* = −0.40` (P3 "refuted: constant, not a differentiator").

This file recomputes the three coefficients *from the tabulated numbers*, in
exact arithmetic, with the standard midrank (average-rank) Spearman estimator.
The verdict does not survive:

* `spearman_entropy_kstar_eq` — entropy ↔ k\* `= 7 / (2√95) ≈ +0.359`:
  **positive**, so the reported `−0.60` has the wrong sign
  (`net74_P1_sign_refuted`) and the wrong magnitude
  (`net74_P1_below_threshold`).
* `spearman_top8_kstar_eq` — top-8 mass ↔ k\* `= −11/38 ≈ −0.289`:
  **negative** and far below the `0.7` bar, so P2's `+0.80` is refuted both in
  sign and in magnitude (`net74_P2_refuted`).
* `spearman_headAgr_kstar_eq` — head agreement ↔ k\* `= −8/√95 ≈ −0.821`:
  head agreement is in fact the **strongest** of the three correlates and does
  clear the `0.7` bar (`net74_P3_refuted`).
* `net74_predictor_ranking_inverted` — the true ordering of the three
  |Spearman| values is `head agreement > entropy > top-8 mass`, the exact
  reverse of the reported ranking.

Two robustness theorems keep the audit honest:

* `rcov_top8_kstarOf` / `rcov_headAgr_kstarOf` — prose-fr's knee is only known
  to satisfy `k* > 24`; *every* value `> 20` produces the same ranks and hence
  the same coefficients.
* `top8_knee_negative_under_every_tiebreak`,
  `entropy_knee_positive_under_every_tiebreak`,
  `headAgr_knee_strong_under_every_tiebreak` — the midrank convention is not
  doing the work: for *every* ordinal ranking compatible with the table (both
  ties broken arbitrarily) the three signs, and the `|ρ| ≥ 0.7` verdict for
  head agreement, are unchanged.

Nothing here is about whether the attention-knee mechanism is real; it is about
what the five tabulated rows can support.  The companion file
`Physics/NET74TailMechanism.lean` shows, structurally, why a head-mass
statistic could not have carried the mechanism in the first place.
-/
import Mathlib

namespace Catalog.NET74

open Finset

/-! ## 1. The measured table -/

/-- The five sampled domains: `code`, `prose-en`, `math`, `prose-de`,
`prose-fr`, in the order of the NET-74 table. -/
abbrev Dom := Fin 5

/-- Mean attention entropy per domain (nats). -/
def entropy : Dom → ℚ := ![3798/1000, 3801/1000, 3615/1000, 3752/1000, 3864/1000]

/-- Mean top-8 attention mass per domain. -/
def top8 : Dom → ℚ := ![488/1000, 488/1000, 526/1000, 502/1000, 473/1000]

/-- Mean cross-head agreement per domain. -/
def headAgr : Dom → ℚ := ![83/1000, 82/1000, 86/1000, 80/1000, 79/1000]

/-- The measured knee `k*@512`.  prose-fr is recorded as `>24`; the value `24`
is the smallest admissible reading and `rcov_top8_kstarOf` shows every larger
reading gives the same answer. -/
def kstar : Dom → ℚ := ![12, 16, 16, 20, 24]

/-! ## 2. Midrank Spearman -/

/-- The midrank (average rank) of `x i` inside the five-point sample: one plus
the number of strictly smaller entries, plus half the number of entries tied
with it (excluding itself).  This is the standard tie correction. -/
def rk (x : Dom → ℚ) (i : Dom) : ℚ :=
  1 + (∑ j, if x j < x i then (1 : ℚ) else 0)
    + ((∑ j, if x j = x i then (1 : ℚ) else 0) - 1) / 2

/-- Mean rank of a column. -/
def rmean (x : Dom → ℚ) : ℚ := (∑ i, rk x i) / 5

/-- Rank covariance `S_xy = ∑ (r_x - r̄_x)(r_y - r̄_y)`. -/
def rcov (x y : Dom → ℚ) : ℚ := ∑ i, (rk x i - rmean x) * (rk y i - rmean y)

/-- Spearman's rank correlation coefficient: the Pearson correlation of the
midranks. -/
noncomputable def spearman (x y : Dom → ℚ) : ℝ :=
  (rcov x y : ℝ) / Real.sqrt ((rcov x x : ℝ) * (rcov y y : ℝ))

/-- Evaluate a data column at a numeral index. -/
local macro "data_eval" : tactic =>
  `(tactic| (simp only [kstar, top8, entropy, headAgr, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
      Matrix.cons_val_four, Matrix.tail_cons]; norm_num))

local macro "rk_eval" : tactic =>
  `(tactic| (simp only [rk, kstar, top8, entropy, headAgr, Fin.sum_univ_five,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.tail_cons]; norm_num))

lemma rk_kstar_0 : rk kstar 0 = 1 := by rk_eval
lemma rk_kstar_1 : rk kstar 1 = 5/2 := by rk_eval
lemma rk_kstar_2 : rk kstar 2 = 5/2 := by rk_eval
lemma rk_kstar_3 : rk kstar 3 = 4 := by rk_eval
lemma rk_kstar_4 : rk kstar 4 = 5 := by rk_eval

lemma rk_top8_0 : rk top8 0 = 5/2 := by rk_eval
lemma rk_top8_1 : rk top8 1 = 5/2 := by rk_eval
lemma rk_top8_2 : rk top8 2 = 5 := by rk_eval
lemma rk_top8_3 : rk top8 3 = 4 := by rk_eval
lemma rk_top8_4 : rk top8 4 = 1 := by rk_eval

lemma rk_entropy_0 : rk entropy 0 = 3 := by rk_eval
lemma rk_entropy_1 : rk entropy 1 = 4 := by rk_eval
lemma rk_entropy_2 : rk entropy 2 = 1 := by rk_eval
lemma rk_entropy_3 : rk entropy 3 = 2 := by rk_eval
lemma rk_entropy_4 : rk entropy 4 = 5 := by rk_eval

lemma rk_headAgr_0 : rk headAgr 0 = 4 := by rk_eval
lemma rk_headAgr_1 : rk headAgr 1 = 3 := by rk_eval
lemma rk_headAgr_2 : rk headAgr 2 = 5 := by rk_eval
lemma rk_headAgr_3 : rk headAgr 3 = 2 := by rk_eval
lemma rk_headAgr_4 : rk headAgr 4 = 1 := by rk_eval

local macro "rcov_eval" : tactic =>
  `(tactic| (simp only [rcov, rmean, Fin.sum_univ_five,
      rk_kstar_0, rk_kstar_1, rk_kstar_2, rk_kstar_3, rk_kstar_4,
      rk_top8_0, rk_top8_1, rk_top8_2, rk_top8_3, rk_top8_4,
      rk_entropy_0, rk_entropy_1, rk_entropy_2, rk_entropy_3, rk_entropy_4,
      rk_headAgr_0, rk_headAgr_1, rk_headAgr_2, rk_headAgr_3, rk_headAgr_4]; norm_num))

/-- The knee column has one tie (prose-en and math both at `k* = 16`), giving
rank variance `19/2` instead of `10`. -/
theorem rcov_kstar_self : rcov kstar kstar = 19/2 := by rcov_eval

theorem rcov_top8_self : rcov top8 top8 = 19/2 := by rcov_eval

theorem rcov_entropy_self : rcov entropy entropy = 10 := by rcov_eval

theorem rcov_headAgr_self : rcov headAgr headAgr = 10 := by rcov_eval

/-- Entropy and the knee **co**vary positively on the tabulated data. -/
theorem rcov_entropy_kstar : rcov entropy kstar = 7/2 := by rcov_eval

/-- Top-8 mass and the knee covary **negatively** on the tabulated data. -/
theorem rcov_top8_kstar : rcov top8 kstar = -11/4 := by rcov_eval

/-- Head agreement and the knee covary strongly negatively. -/
theorem rcov_headAgr_kstar : rcov headAgr kstar = -8 := by rcov_eval

/-! ## 3. The three coefficients, and what they refute -/

private lemma sqrt95_pos : 0 < Real.sqrt 95 := Real.sqrt_pos.mpr (by norm_num)

private lemma sqrt95_sq : Real.sqrt 95 ^ 2 = 95 := Real.sq_sqrt (by norm_num)

private lemma sqrt95_lt : Real.sqrt 95 < 10 := by
  nlinarith [sqrt95_sq, sqrt95_pos]

private lemma sqrt95_gt : 9 < Real.sqrt 95 := by
  nlinarith [sqrt95_sq, sqrt95_pos]

/-- Entropy vs. the knee: `+7/(2√95) ≈ +0.359`. -/
theorem spearman_entropy_kstar_eq :
    spearman entropy kstar = 7 / (2 * Real.sqrt 95) := by
  have h : ((rcov entropy entropy : ℚ) : ℝ) * ((rcov kstar kstar : ℚ) : ℝ) = 95 := by
    rw [rcov_entropy_self, rcov_kstar_self]; norm_num
  rw [spearman, h, rcov_entropy_kstar]
  push_cast
  ring

/-- **P1 is refuted in sign.**  The reported coefficient is `−0.60`; the table
gives a *positive* value.  Entropy and the knee move together here: prose-fr
has both the largest entropy and the largest knee. -/
theorem net74_P1_sign_refuted : 0 < spearman entropy kstar := by
  rw [spearman_entropy_kstar_eq]
  positivity

/-- ... and in magnitude: the true value is well below the `0.7` bar. -/
theorem net74_P1_below_threshold : spearman entropy kstar < 7/10 := by
  rw [spearman_entropy_kstar_eq]
  rw [div_lt_iff₀ (by positivity)]
  nlinarith [sqrt95_gt]

/-- Top-8 mass vs. the knee.  Both columns have exactly one tie, so the
normalisation is rational and the coefficient is exactly `−11/38`. -/
theorem spearman_top8_kstar_eq : spearman top8 kstar = -11/38 := by
  have h : ((rcov top8 top8 : ℚ) : ℝ) * ((rcov kstar kstar : ℚ) : ℝ) = (19/2) ^ 2 := by
    rw [rcov_top8_self, rcov_kstar_self]; norm_num
  rw [spearman, h, rcov_top8_kstar, Real.sqrt_sq (by norm_num)]
  push_cast
  norm_num

/-- **P2 is refuted.**  The headline claim `top8 ↔ k* = +0.80 > 0.7` fails on
both counts: the tabulated coefficient is negative, and its magnitude
`11/38 ≈ 0.29` is the *smallest* of the three. -/
theorem net74_P2_refuted :
    spearman top8 kstar < 0 ∧ |spearman top8 kstar| < 7/10 := by
  rw [spearman_top8_kstar_eq]
  constructor
  · norm_num
  · rw [abs_of_neg (by norm_num)]; norm_num

/-- Head agreement vs. the knee: `−8/√95 ≈ −0.821`. -/
theorem spearman_headAgr_kstar_eq :
    spearman headAgr kstar = -(8 / Real.sqrt 95) := by
  have h : ((rcov headAgr headAgr : ℚ) : ℝ) * ((rcov kstar kstar : ℚ) : ℝ) = 95 := by
    rw [rcov_headAgr_self, rcov_kstar_self]; norm_num
  rw [spearman, h, rcov_headAgr_kstar]
  push_cast
  ring

/-- **P3 is refuted, and reversed.**  Cross-head agreement was declared a
non-differentiator at `−0.40`; on the tabulated numbers it is the one predictor
that clears the pre-registered `|ρ| ≥ 0.7` bar. -/
theorem net74_P3_refuted : spearman headAgr kstar < -(7/10) := by
  rw [spearman_headAgr_kstar_eq]
  have h : (7:ℝ)/10 < 8 / Real.sqrt 95 := by
    rw [lt_div_iff₀ sqrt95_pos]
    nlinarith [sqrt95_lt]
  linarith

/-- **The reported ranking of the three predictors is exactly inverted.**
Measured on the table, `|ρ_headAgr| > |ρ_entropy| > |ρ_top8|`, whereas NET-74
reports top-8 mass strongest and head agreement weakest. -/
theorem net74_predictor_ranking_inverted :
    |spearman top8 kstar| < |spearman entropy kstar| ∧
    |spearman entropy kstar| < |spearman headAgr kstar| := by
  have hs := sqrt95_pos
  have hlt := sqrt95_lt
  have hgt := sqrt95_gt
  have e1 : |spearman top8 kstar| = 11/38 := by
    rw [spearman_top8_kstar_eq, abs_of_neg (by norm_num : (-11:ℝ)/38 < 0)]
    norm_num
  have e2 : |spearman entropy kstar| = 7 / (2 * Real.sqrt 95) := by
    rw [spearman_entropy_kstar_eq, abs_of_pos (by positivity)]
  have e3 : |spearman headAgr kstar| = 8 / Real.sqrt 95 := by
    rw [spearman_headAgr_kstar_eq, abs_neg, abs_of_pos (by positivity)]
  rw [e1, e2, e3]
  refine ⟨?_, ?_⟩
  · rw [div_lt_div_iff₀ (by norm_num) (by positivity)]
    nlinarith [hlt]
  · rw [div_lt_div_iff₀ (by positivity) hs]
    nlinarith [hs]

/-! ## 4. Robustness in prose-fr's censored knee -/

/-- The knee column with prose-fr's censored reading `>24` left as a free
parameter `v`. -/
def kstarOf (v : ℚ) : Dom → ℚ := ![12, 16, 16, 20, v]

local macro "rk_evalOf" : tactic =>
  `(tactic| (simp only [rk, kstarOf, top8, entropy, headAgr, Fin.sum_univ_five,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.tail_cons]))

section Censored

variable {v : ℚ} (hv : 20 < v)
include hv

private lemma lt12 : (12:ℚ) < v := by linarith
private lemma lt16 : (16:ℚ) < v := by linarith
private lemma lt20 : (20:ℚ) < v := hv
private lemma nlt12 : ¬ (v < 12) := by linarith
private lemma nlt16 : ¬ (v < 16) := by linarith
private lemma nlt20 : ¬ (v < 20) := by linarith
private lemma ne12 : ¬ ((12:ℚ) = v) := by intro h; linarith
private lemma ne16 : ¬ ((16:ℚ) = v) := by intro h; linarith
private lemma ne20 : ¬ ((20:ℚ) = v) := by intro h; linarith
private lemma ne12' : ¬ (v = (12:ℚ)) := by intro h; linarith
private lemma ne16' : ¬ (v = (16:ℚ)) := by intro h; linarith
private lemma ne20' : ¬ (v = (20:ℚ)) := by intro h; linarith

local macro "censor_simp" h:term : tactic =>
  `(tactic| (simp only [lt12 $h, lt16 $h, lt20 $h, nlt12 $h, nlt16 $h, nlt20 $h,
      ne12 $h, ne16 $h, ne20 $h, ne12' $h, ne16' $h, ne20' $h, if_true, if_false,
      eq_self_iff_true, not_false_iff]; norm_num))

lemma rk_kstarOf_0 : rk (kstarOf v) 0 = 1 := by rk_evalOf; censor_simp hv
lemma rk_kstarOf_1 : rk (kstarOf v) 1 = 5/2 := by rk_evalOf; censor_simp hv
lemma rk_kstarOf_2 : rk (kstarOf v) 2 = 5/2 := by rk_evalOf; censor_simp hv
lemma rk_kstarOf_3 : rk (kstarOf v) 3 = 4 := by rk_evalOf; censor_simp hv
lemma rk_kstarOf_4 : rk (kstarOf v) 4 = 5 := by rk_evalOf; censor_simp hv

local macro "rcovOf_eval" h:term : tactic =>
  `(tactic| (simp only [rcov, rmean, Fin.sum_univ_five,
      rk_kstarOf_0 $h, rk_kstarOf_1 $h, rk_kstarOf_2 $h, rk_kstarOf_3 $h, rk_kstarOf_4 $h,
      rk_top8_0, rk_top8_1, rk_top8_2, rk_top8_3, rk_top8_4,
      rk_entropy_0, rk_entropy_1, rk_entropy_2, rk_entropy_3, rk_entropy_4,
      rk_headAgr_0, rk_headAgr_1, rk_headAgr_2, rk_headAgr_3, rk_headAgr_4]; norm_num))

/-- Whatever the true prose-fr knee is, as long as it exceeds the prose-de knee
the top-8 covariance is unchanged — so the negative sign of P2 is not an
artefact of reading `>24` as `24`. -/
theorem rcov_top8_kstarOf : rcov top8 (kstarOf v) = -11/4 := by rcovOf_eval hv

theorem rcov_entropy_kstarOf : rcov entropy (kstarOf v) = 7/2 := by rcovOf_eval hv

theorem rcov_headAgr_kstarOf : rcov headAgr (kstarOf v) = -8 := by rcovOf_eval hv

end Censored

/-! ## 5. Robustness in the tie-breaking convention -/

/-- An *ordinal ranking* of a column: a bijection onto `{1,…,5}` (encoded as
bounded, pairwise distinct integers) that respects the strict order of the
data.  Tied entries may be ordered either way, so this covers every ranking
convention at once. -/
def IsOrdinalRank (x : Dom → ℚ) (r : Dom → ℤ) : Prop :=
  (∀ i, 1 ≤ r i ∧ r i ≤ 5) ∧ (∀ i j, i ≠ j → r i ≠ r j) ∧ (∀ i j, x i < x j → r i < r j)

/-- Rank covariance of two ordinal rankings.  The mean of `{1,…,5}` is `3`, and
the rank variance of any such ranking is `10`, so Spearman's `ρ` is
`zcov r s / 10`. -/
def zcov (r s : Dom → ℤ) : ℤ := ∑ i, (r i - 3) * (s i - 3)

private lemma kstar_ranks {s : Dom → ℤ} (hs : IsOrdinalRank kstar s) :
    s 0 = 1 ∧ s 3 = 4 ∧ s 4 = 5 ∧ ((s 1 = 2 ∧ s 2 = 3) ∨ (s 1 = 3 ∧ s 2 = 2)) := by
  obtain ⟨hb, hd, ho⟩ := hs
  have b0 := hb 0; have b1 := hb 1; have b2 := hb 2; have b3 := hb 3; have b4 := hb 4
  have d01 := hd 0 1 (by decide); have d02 := hd 0 2 (by decide)
  have d03 := hd 0 3 (by decide); have d04 := hd 0 4 (by decide)
  have d12 := hd 1 2 (by decide); have d13 := hd 1 3 (by decide)
  have d14 := hd 1 4 (by decide); have d23 := hd 2 3 (by decide)
  have d24 := hd 2 4 (by decide); have d34 := hd 3 4 (by decide)
  have o01 : s 0 < s 1 := ho 0 1 (by data_eval)
  have o02 : s 0 < s 2 := ho 0 2 (by data_eval)
  have o13 : s 1 < s 3 := ho 1 3 (by data_eval)
  have o23 : s 2 < s 3 := ho 2 3 (by data_eval)
  have o34 : s 3 < s 4 := ho 3 4 (by data_eval)
  omega

private lemma top8_ranks {r : Dom → ℤ} (hr : IsOrdinalRank top8 r) :
    r 4 = 1 ∧ r 3 = 4 ∧ r 2 = 5 ∧ ((r 0 = 2 ∧ r 1 = 3) ∨ (r 0 = 3 ∧ r 1 = 2)) := by
  obtain ⟨hb, hd, ho⟩ := hr
  have b0 := hb 0; have b1 := hb 1; have b2 := hb 2; have b3 := hb 3; have b4 := hb 4
  have d01 := hd 0 1 (by decide); have d02 := hd 0 2 (by decide)
  have d03 := hd 0 3 (by decide); have d04 := hd 0 4 (by decide)
  have d12 := hd 1 2 (by decide); have d13 := hd 1 3 (by decide)
  have d14 := hd 1 4 (by decide); have d23 := hd 2 3 (by decide)
  have d24 := hd 2 4 (by decide); have d34 := hd 3 4 (by decide)
  have o40 : r 4 < r 0 := ho 4 0 (by data_eval)
  have o41 : r 4 < r 1 := ho 4 1 (by data_eval)
  have o03 : r 0 < r 3 := ho 0 3 (by data_eval)
  have o13 : r 1 < r 3 := ho 1 3 (by data_eval)
  have o32 : r 3 < r 2 := ho 3 2 (by data_eval)
  omega

private lemma entropy_ranks {r : Dom → ℤ} (hr : IsOrdinalRank entropy r) :
    r 2 = 1 ∧ r 3 = 2 ∧ r 0 = 3 ∧ r 1 = 4 ∧ r 4 = 5 := by
  obtain ⟨hb, hd, ho⟩ := hr
  have b0 := hb 0; have b1 := hb 1; have b2 := hb 2; have b3 := hb 3; have b4 := hb 4
  have o23 : r 2 < r 3 := ho 2 3 (by data_eval)
  have o30 : r 3 < r 0 := ho 3 0 (by data_eval)
  have o01 : r 0 < r 1 := ho 0 1 (by data_eval)
  have o14 : r 1 < r 4 := ho 1 4 (by data_eval)
  omega

private lemma headAgr_ranks {r : Dom → ℤ} (hr : IsOrdinalRank headAgr r) :
    r 4 = 1 ∧ r 3 = 2 ∧ r 1 = 3 ∧ r 0 = 4 ∧ r 2 = 5 := by
  obtain ⟨hb, hd, ho⟩ := hr
  have b0 := hb 0; have b1 := hb 1; have b2 := hb 2; have b3 := hb 3; have b4 := hb 4
  have o43 : r 4 < r 3 := ho 4 3 (by data_eval)
  have o31 : r 3 < r 1 := ho 3 1 (by data_eval)
  have o10 : r 1 < r 0 := ho 1 0 (by data_eval)
  have o02 : r 0 < r 2 := ho 0 2 (by data_eval)
  omega

/-- **Tie-break robustness for P2.**  Under *every* ordinal ranking of the two
tied columns, the top-8/knee rank covariance is negative (`ρ ≤ −1/10`).  No
tie-breaking convention can turn the tabulated data into `+0.80`. -/
theorem top8_knee_negative_under_every_tiebreak {r s : Dom → ℤ}
    (hr : IsOrdinalRank top8 r) (hs : IsOrdinalRank kstar s) : zcov r s ≤ -1 := by
  obtain ⟨r4, r3, r2, hr01⟩ := top8_ranks hr
  obtain ⟨s0, s3, s4, hs12⟩ := kstar_ranks hs
  simp only [zcov, Fin.sum_univ_five, r2, r3, r4, s0, s3, s4]
  rcases hr01 with ⟨a, b⟩ | ⟨a, b⟩ <;> rcases hs12 with ⟨c, d⟩ | ⟨c, d⟩ <;>
    rw [a, b, c, d] <;> norm_num

/-- **Tie-break robustness for P1.**  Under every ordinal ranking the
entropy/knee covariance is positive (`ρ ≥ 1/5`), never the reported `−0.60`. -/
theorem entropy_knee_positive_under_every_tiebreak {r s : Dom → ℤ}
    (hr : IsOrdinalRank entropy r) (hs : IsOrdinalRank kstar s) : 2 ≤ zcov r s := by
  obtain ⟨r2, r3, r0, r1, r4⟩ := entropy_ranks hr
  obtain ⟨s0, s3, s4, hs12⟩ := kstar_ranks hs
  simp only [zcov, Fin.sum_univ_five, r0, r1, r2, r3, r4, s0, s3, s4]
  rcases hs12 with ⟨c, d⟩ | ⟨c, d⟩ <;> rw [c, d] <;> norm_num

/-- **Tie-break robustness for P3.**  Under every ordinal ranking the
head-agreement/knee covariance is at most `−7`, i.e. `ρ ≤ −0.7`: the predictor
declared "constant, not a differentiator" is the only one that meets the
pre-registered bar, whichever way the ties are broken. -/
theorem headAgr_knee_strong_under_every_tiebreak {r s : Dom → ℤ}
    (hr : IsOrdinalRank headAgr r) (hs : IsOrdinalRank kstar s) : zcov r s ≤ -7 := by
  obtain ⟨r4, r3, r1, r0, r2⟩ := headAgr_ranks hr
  obtain ⟨s0, s3, s4, hs12⟩ := kstar_ranks hs
  simp only [zcov, Fin.sum_univ_five, r0, r1, r2, r3, r4, s0, s3, s4]
  rcases hs12 with ⟨c, d⟩ | ⟨c, d⟩ <;> rw [c, d] <;> norm_num

/-- **Audit summary.**  On the NET-74 table, in exact arithmetic: entropy is
positively associated with the knee, top-8 mass negatively and weakly, and head
agreement strongly negatively — and all three statements survive every
tie-breaking convention and every reading of prose-fr's censored knee. -/
theorem net74_audit :
    0 < spearman entropy kstar ∧
    spearman top8 kstar = -11/38 ∧
    spearman headAgr kstar < -(7/10) ∧
    (∀ r s : Dom → ℤ, IsOrdinalRank top8 r → IsOrdinalRank kstar s → zcov r s < 0) ∧
    (∀ r s : Dom → ℤ, IsOrdinalRank headAgr r → IsOrdinalRank kstar s → zcov r s ≤ -7) :=
  ⟨net74_P1_sign_refuted, spearman_top8_kstar_eq, net74_P3_refuted,
    fun _ _ hr hs => lt_of_le_of_lt (top8_knee_negative_under_every_tiebreak hr hs) (by norm_num),
    fun _ _ hr hs => headAgr_knee_strong_under_every_tiebreak hr hs⟩

end Catalog.NET74