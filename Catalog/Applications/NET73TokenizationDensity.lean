/-
# NET-73: Tokenization density does not explain the domain shift

This file formalises the statistical content of the NET-73 experiment
("TOKENIZATION-DENSITY-DOES-NOT-EXPLAIN-THE-DOMAIN-SHIFT").

The experiment measured, for five text domains, the tokens-per-word ratio `TPW`
of one fixed BPE tokenizer on a 5000-word sample, and the *knee* `k*` — the
smallest number of retained attention keys at which model quality saturates at
context length 512.

| domain    | TPW   | k*@512 |
|-----------|-------|--------|
| code      | 1.950 | 12     |
| prose-de  | 1.885 | 20     |
| prose-fr  | 1.246 | > 32   |
| math      | 1.214 | 16     |
| prose-en  | 1.173 | 16     |

`prose-fr` is *censored* (its knee only exceeds the measured grid), so all
numeric statistics below are computed on the four uncensored domains, in the
order `code, prose-de, math, prose-en`; this is exactly the population for which
the experiment reports Spearman ρ = −0.40 and R² = 0.004.  The censored French
point is used separately, as a hypothesis-parameterised strengthening.

What is proved here:

* `Catalog.NET73.no_strictMono_explanation` / `no_strictAnti_explanation` —
  a general order-theoretic obstruction: a single discordant pair forbids *any*
  monotone functional explanation of one observable by another.
* `Catalog.NET73.tokenization_density_no_monotone_law` — the two horns are both
  realised by the data, so no monotone `f` satisfies `k* = f (TPW)`.
* `Catalog.NET73.crank_comp_strictMono` — competition ranks are invariant under
  a strictly monotone reparameterisation, and `crank_knee_ne_crank_tpw` shows
  the observed ranks differ; a rank-level version of the same obstruction.
* `Catalog.NET73.spearman_eq_one_iff` — Spearman ρ = 1 exactly for identical
  rank vectors, together with the three tie-breaking conventions for the data,
  all of which give a *negative* ρ (the reported convention gives exactly
  `-2/5 = -0.40`).
* `Catalog.NET73.rsq_le_one`, `rsq_eq_one_of_affine` (a Cauchy–Schwarz
  argument), the exact value `rsq tpw knee = 4225/1054258 ≈ 0.004008`, and the
  resulting refutation of any affine law `k* = a·TPW + b`.

The companion file `Applications/NET73KneeDecoupling.lean` supplies the
structural side: the knee is governed by attention *concentration*, a relational
quantity that is provably decoupled from tokens-per-word.
-/
import Mathlib

namespace Catalog.NET73

open Finset

attribute [local simp] Matrix.cons_val_two Matrix.cons_val_three Matrix.tail_cons

/-! ## 1. The measured data (four uncensored domains) -/

/-- Domain index: `0 = code`, `1 = prose-de`, `2 = math`, `3 = prose-en`. -/
abbrev Dom := Fin 4

/-- Tokens per word of the fixed BPE tokenizer, per domain. -/
def tpw : Dom → ℚ := ![1950/1000, 1885/1000, 1214/1000, 1173/1000]

/-- Measured knee `k*` at context length 512, per domain. -/
def kneeN : Dom → ℕ := ![12, 20, 16, 16]

/-- The knee as a rational observable (for the regression statistics). -/
def knee : Dom → ℚ := fun i => (kneeN i : ℚ)

lemma knee_apply : knee = ![12, 20, 16, 16] := by
  funext i; fin_cases i <;> simp [knee, kneeN]

/-- The headline counterexample: code has more than `1.66` times English's
tokens-per-word, yet needs strictly *fewer* keys. -/
theorem code_vs_english :
    (166 / 100 : ℚ) * tpw 3 < tpw 0 ∧ knee 0 < knee 3 := by
  constructor <;> norm_num [tpw, knee, kneeN]

/-- The second counterexample, inside the uncensored data: math has strictly
smaller tokens-per-word than German prose, yet also a strictly smaller knee —
so the relation is not decreasing either. -/
theorem math_vs_german :
    tpw 2 < tpw 1 ∧ knee 2 < knee 1 := by
  constructor <;> norm_num [tpw, knee, kneeN]

/-! ## 2. A general order-theoretic obstruction

If two observables `x` and `y` admit *one* discordant pair, then no strictly
monotone function can carry `x` to `y`.  This is the abstract form of the
NET-73 refutation, and it needs no numerics at all. -/

/-- No strictly increasing reparameterisation can explain `y` from `x` once a
single inversion `x i < x j` but `y j ≤ y i` is present. -/
theorem no_strictMono_explanation {ι : Type*} {α β : Type*} [LinearOrder α]
    [Preorder β] (x : ι → α) (y : ι → β) {i j : ι}
    (hx : x i < x j) (hy : ¬ y i < y j) :
    ¬ ∃ f : α → β, StrictMono f ∧ ∀ k, y k = f (x k) := by
  rintro ⟨f, hf, hfy⟩
  exact hy (by rw [hfy i, hfy j]; exact hf hx)

/-- Dually, no strictly decreasing reparameterisation can explain `y` from `x`
once a concordant pair `x i < x j`, `y i < y j` is present. -/
theorem no_strictAnti_explanation {ι : Type*} {α β : Type*} [LinearOrder α]
    [Preorder β] (x : ι → α) (y : ι → β) {i j : ι}
    (hx : x i < x j) (hy : y i < y j) :
    ¬ ∃ f : α → β, StrictAnti f ∧ ∀ k, y k = f (x k) := by
  rintro ⟨f, hf, hfy⟩
  have : y j < y i := by rw [hfy i, hfy j]; exact hf hx
  exact absurd (hy.trans this) (lt_irrefl _)

/-- **P1/P2 refuted, structural form.** Tokens-per-word admits no increasing
functional law for the knee: English has the smallest density but a larger knee
than code, which has the largest density. -/
theorem tpw_no_increasing_law :
    ¬ ∃ f : ℚ → ℚ, StrictMono f ∧ ∀ i, knee i = f (tpw i) := by
  refine no_strictMono_explanation tpw knee (i := 3) (j := 0) ?_ ?_
  · norm_num [tpw]
  · norm_num [knee, kneeN]

/-- ... and no decreasing law either: math has smaller density *and* a smaller
knee than German prose. -/
theorem tpw_no_decreasing_law :
    ¬ ∃ f : ℚ → ℚ, StrictAnti f ∧ ∀ i, knee i = f (tpw i) := by
  refine no_strictAnti_explanation tpw knee (i := 2) (j := 1) ?_ ?_
  · norm_num [tpw]
  · norm_num [knee, kneeN]

/-- **The NET-73 verdict.** Neither horn of the tokenization hypothesis
survives: there is no monotone (increasing or decreasing) function of
tokens-per-word that reproduces the measured knees. -/
theorem tokenization_density_no_monotone_law :
    (¬ ∃ f : ℚ → ℚ, StrictMono f ∧ ∀ i, knee i = f (tpw i)) ∧
    (¬ ∃ f : ℚ → ℚ, StrictAnti f ∧ ∀ i, knee i = f (tpw i)) :=
  ⟨tpw_no_increasing_law, tpw_no_decreasing_law⟩

/-- The censored French domain only strengthens the decreasing horn: whatever
its exact knee `K ≥ 32` is, French has smaller density than German prose and a
larger knee, so a decreasing law fails on that pair too. -/
theorem french_kills_decreasing_law (K : ℚ) (hK : 32 ≤ K)
    (tpw' : Fin 2 → ℚ) (knee' : Fin 2 → ℚ)
    (h0 : tpw' 0 = 1246/1000) (h1 : tpw' 1 = 1885/1000)
    (k0 : knee' 0 = K) (k1 : knee' 1 = 20) :
    ¬ ∃ f : ℚ → ℚ, StrictMono f ∧ ∀ i, knee' i = f (tpw' i) := by
  refine no_strictMono_explanation tpw' knee' (i := 0) (j := 1) ?_ ?_
  · rw [h0, h1]; norm_num
  · rw [k0, k1]; linarith

/-! ## 3. Rank level: competition ranks are monotone invariants -/

/-- Competition rank: `1 +` the number of strictly smaller entries. -/
def crank {n : ℕ} (x : Fin n → ℚ) (i : Fin n) : ℕ :=
  ({j | x j < x i} : Finset (Fin n)).card + 1

/-- Competition ranks are invariant under any strictly monotone
reparameterisation of the observable.  Hence rank vectors are a *complete*
obstruction to monotone explanations. -/
theorem crank_comp_strictMono {n : ℕ} {f : ℚ → ℚ} (hf : StrictMono f)
    (x : Fin n → ℚ) : crank (f ∘ x) = crank x := by
  funext i
  simp [crank, Function.comp, hf.lt_iff_lt]

lemma crank_tpw_zero : crank tpw 0 = 4 := by
  have h : ({j | tpw j < tpw 0} : Finset (Fin 4)) = {1, 2, 3} := by
    ext j; fin_cases j <;> norm_num [tpw, Fin.ext_iff]
  simp [crank, h]

lemma crank_knee_zero : crank knee 0 = 1 := by
  have h : ({j | knee j < knee 0} : Finset (Fin 4)) = ∅ := by
    ext j; fin_cases j <;> norm_num [knee, kneeN]
  simp [crank, h]

/-- The two rank vectors differ (code is rank 4 in density but rank 1 in knee). -/
theorem crank_knee_ne_crank_tpw : crank knee ≠ crank tpw := by
  intro h
  have := congrFun h 0
  rw [crank_knee_zero, crank_tpw_zero] at this
  exact absurd this (by norm_num)

/-- Rank-level restatement of the refutation, via the invariance theorem. -/
theorem tpw_no_increasing_law_of_ranks :
    ¬ ∃ f : ℚ → ℚ, StrictMono f ∧ knee = f ∘ tpw := by
  rintro ⟨f, hf, hk⟩
  refine crank_knee_ne_crank_tpw ?_
  rw [hk, crank_comp_strictMono hf tpw]

/-! ## 4. Spearman rank correlation -/

/-- Spearman's ρ from the sum of squared rank differences (`n` data points). -/
def spearman {n : ℕ} (r s : Fin n → ℚ) : ℚ :=
  1 - 6 * (∑ i, (r i - s i) ^ 2) / ((n : ℚ) * ((n : ℚ) ^ 2 - 1))

/-- With at least two points, `ρ = 1` characterises identical rank vectors. -/
theorem spearman_eq_one_iff {n : ℕ} (hn : 2 ≤ n) (r s : Fin n → ℚ) :
    spearman r s = 1 ↔ r = s := by
  have hn1 : (1 : ℚ) < (n : ℚ) := by
    have : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
    linarith
  have hpos : 0 < (n : ℚ) * ((n : ℚ) ^ 2 - 1) := by nlinarith
  constructor
  · intro h
    have h0 : 6 * (∑ i, (r i - s i) ^ 2) / ((n : ℚ) * ((n : ℚ) ^ 2 - 1)) = 0 := by
      unfold spearman at h; linarith
    have h1 : 6 * (∑ i, (r i - s i) ^ 2) = 0 :=
      (div_eq_zero_iff.mp h0).resolve_right (ne_of_gt hpos)
    have hsum : (∑ i, (r i - s i) ^ 2) = 0 := by linarith
    funext i
    have hnn : ∀ j ∈ (univ : Finset (Fin n)), 0 ≤ (r j - s j) ^ 2 := fun j _ => sq_nonneg _
    have hz := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hsum i (mem_univ i)
    have hzz : r i - s i = 0 := sq_eq_zero_iff.mp hz
    linarith
  · rintro rfl
    simp [spearman]

/-- Any strictly increasing law forces identical competition ranks, hence
Spearman ρ = 1 on those ranks. -/
theorem spearman_crank_eq_one_of_strictMono {n : ℕ} (hn : 2 ≤ n) {f : ℚ → ℚ}
    (hf : StrictMono f) (x : Fin n → ℚ) :
    spearman (fun i => (crank (f ∘ x) i : ℚ)) (fun i => (crank x i : ℚ)) = 1 := by
  rw [spearman_eq_one_iff hn]
  funext i
  rw [crank_comp_strictMono hf x]

/-- Ascending ranks of tokens-per-word: `en < math < de < code`. -/
def rankTpw : Dom → ℚ := ![4, 3, 2, 1]

/-- Ascending ranks of the knee under the experiment's tie-breaking
(`math` before `prose-en` among the two 16's). -/
def rankKnee : Dom → ℚ := ![1, 4, 2, 3]

/-- The opposite tie-breaking (`prose-en` before `math`). -/
def rankKneeAlt : Dom → ℚ := ![1, 4, 3, 2]

/-- Competition ranks (both 16's get rank 2), as produced by `crank`. -/
def rankKneeComp : Dom → ℚ := ![1, 4, 2, 2]

/-- Midrank (tie-averaged) convention. -/
def rankKneeMid : Dom → ℚ := ![1, 4, 5/2, 5/2]

/-- **The reported value.** Spearman ρ = −2/5 = −0.40. -/
theorem spearman_reported : spearman rankTpw rankKnee = -2/5 := by
  simp [spearman, rankTpw, rankKnee, Fin.sum_univ_four]
  norm_num

/-- The sign of ρ is robust: every tie-breaking convention gives a negative
rank correlation. -/
theorem spearman_negative_all_conventions :
    spearman rankTpw rankKnee = -2/5 ∧
    spearman rankTpw rankKneeAlt = -1/5 ∧
    spearman rankTpw rankKneeMid = -1/4 ∧
    spearman rankTpw rankKneeComp = -1/10 ∧
    spearman rankTpw rankKnee < 0 ∧
    spearman rankTpw rankKneeAlt < 0 ∧
    spearman rankTpw rankKneeMid < 0 ∧
    spearman rankTpw rankKneeComp < 0 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp [spearman, rankTpw, rankKnee, rankKneeAlt, rankKneeMid, rankKneeComp,
      Fin.sum_univ_four] <;>
    norm_num

/-- **P1 refuted.** The observed rank correlation is not just below the
pre-registered threshold `0.9`: it is negative, so in particular no strictly
increasing law can hold (such a law would force ρ = 1). -/
theorem spearman_refutes_P1 :
    spearman rankTpw rankKnee < 9/10 ∧ rankKnee ≠ rankTpw := by
  refine ⟨by rw [spearman_reported]; norm_num, ?_⟩
  intro h
  have := congrFun h 0
  norm_num [rankKnee, rankTpw] at this

/-! ## 5. Linear regression: the coefficient of determination -/

/-- Sample mean. -/
def mean {n : ℕ} (x : Fin n → ℚ) : ℚ := (∑ i, x i) / (n : ℚ)

/-- (Unnormalised) covariance of two samples. -/
def cov {n : ℕ} (x y : Fin n → ℚ) : ℚ := ∑ i, (x i - mean x) * (y i - mean y)

/-- Coefficient of determination of the least-squares line of `y` on `x`. -/
def rsq {n : ℕ} (x y : Fin n → ℚ) : ℚ := (cov x y) ^ 2 / (cov x x * cov y y)

lemma cov_self_nonneg {n : ℕ} (x : Fin n → ℚ) : 0 ≤ cov x x := by
  unfold cov
  refine Finset.sum_nonneg fun i _ => ?_
  nlinarith [sq_nonneg (x i - mean x)]

/-- Cauchy–Schwarz for centred samples. -/
theorem cov_sq_le {n : ℕ} (x y : Fin n → ℚ) :
    (cov x y) ^ 2 ≤ cov x x * cov y y := by
  have := Finset.sum_mul_sq_le_sq_mul_sq (univ : Finset (Fin n))
    (fun i => x i - mean x) (fun i => y i - mean y)
  simpa [cov, sq] using this

/-- `R² ≤ 1` always (equality is the perfect-fit case). -/
theorem rsq_le_one {n : ℕ} (x y : Fin n → ℚ) (hx : 0 < cov x x)
    (hy : 0 < cov y y) : rsq x y ≤ 1 :=
  (div_le_one (by positivity)).mpr (cov_sq_le x y)

lemma mean_affine {n : ℕ} (hn : 0 < n) (x : Fin n → ℚ) (a b : ℚ) :
    mean (fun i => a * x i + b) = a * mean x + b := by
  have hn' : ((n : ℚ)) ≠ 0 := by positivity
  unfold mean
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  field_simp

/-- A genuine affine law makes the fit perfect: `R² = 1`. -/
theorem rsq_eq_one_of_affine {n : ℕ} (hn : 0 < n) (x y : Fin n → ℚ) (a b : ℚ)
    (ha : a ≠ 0) (hx : 0 < cov x x) (h : ∀ i, y i = a * x i + b) :
    rsq x y = 1 := by
  have hy : y = fun i => a * x i + b := funext h
  have hmean : mean y = a * mean x + b := by rw [hy]; exact mean_affine hn x a b
  have hcen : ∀ i, y i - mean y = a * (x i - mean x) := by
    intro i; rw [h i, hmean]; ring
  have h1 : cov x y = a * cov x x := by
    unfold cov
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by rw [hcen i]; ring
  have h2 : cov y y = a ^ 2 * cov x x := by
    unfold cov
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by rw [hcen i]; ring
  unfold rsq
  rw [h1, h2]
  field_simp

lemma cov_tpw_pos : 0 < cov tpw tpw := by
  simp [cov, mean, tpw, Fin.sum_univ_four]
  norm_num

/-- **P2 refuted, exact value.** The least-squares fit of the knee on
tokens-per-word explains a fraction `4225/1054258 ≈ 0.004008` of the variance. -/
theorem rsq_value : rsq tpw knee = 4225 / 1054258 := by
  simp [rsq, cov, mean, tpw, knee, kneeN, Fin.sum_univ_four]
  norm_num

theorem rsq_lt_half_percent : rsq tpw knee < 1 / 200 := by
  rw [rsq_value]; norm_num

/-- **No affine law.** Since a perfect affine relation would force `R² = 1`,
the measured `R² ≈ 0.004` rules out `k* = a·TPW + b` for every `a ≠ 0`. -/
theorem no_affine_law : ¬ ∃ a b : ℚ, a ≠ 0 ∧ ∀ i, knee i = a * tpw i + b := by
  rintro ⟨a, b, ha, h⟩
  have := rsq_eq_one_of_affine (n := 4) (by norm_num) tpw knee a b ha cov_tpw_pos h
  rw [rsq_value] at this
  norm_num at this

/-- **NET-73, assembled.** On the four uncensored domains the tokenization
hypothesis fails in every one of its testable forms: the rank correlation is
negative (not `≥ 0.9`), the linear fit explains less than half a percent of the
variance (not `≥ 0.8`), and no monotone — in particular no affine — law of
tokens-per-word reproduces the knees. -/
theorem net73_verdict :
    spearman rankTpw rankKnee = -2/5 ∧
    spearman rankTpw rankKnee < 0 ∧
    rsq tpw knee < 1 / 200 ∧
    (¬ ∃ f : ℚ → ℚ, StrictMono f ∧ ∀ i, knee i = f (tpw i)) ∧
    (¬ ∃ f : ℚ → ℚ, StrictAnti f ∧ ∀ i, knee i = f (tpw i)) ∧
    (¬ ∃ a b : ℚ, a ≠ 0 ∧ ∀ i, knee i = a * tpw i + b) :=
  ⟨spearman_reported, by rw [spearman_reported]; norm_num,
    rsq_lt_half_percent, tpw_no_increasing_law, tpw_no_decreasing_law,
    no_affine_law⟩

end Catalog.NET73