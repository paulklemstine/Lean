/-
# Cycle 2: equivariance, breakdown, and extrapolation of quota budgets (NET-48 follow-up)

`Logic.KneeMedianLaw` introduced the quota ladder of a seed ensemble — `quotaBudget K m`,
the least budget at which at least `m` seeds clear the bar — showed that for three seeds it
reads `min ≤ median ≤ max`, and recorded the NET-48 measurement: knee set `{256, 224, 160}`
at `(d = 4, ctx = 2048)` with median `224 = (7/8)·(d·ctx/32)`, matching the `ctx = 1024`
median `112 = (7/8)·128`.

This file is the second turn of the loop.  Three structural questions are raised by the
round and answered here in full generality.

**(1) Is the median law an artefact of the sweep grid?**  No, and the reason is
equivariance: order statistics commute with *every* monotone map (`med3L_map`).  Grid
quantisation `κ ↦ s⌈κ/s⌉` is monotone, so the measured (quantised) median is exactly the
quantisation of the true median (`gridKnee_med3`): the grid can shift the median by less
than one step (`gridKnee_med3_error`) but cannot manufacture or destroy the law.

**(2) How far can one seed move a quota budget?**  Exactly one rung
(`quotaBudget_update_le`, `quotaBudget_le_update`, `quota_one_seed_breakdown`): replacing a
single seed moves the `m`-quota budget into the interval
`[quotaBudget K (m-1), quotaBudget K (m+1)]` of the *original* ensemble.  For three seeds
and `m = 2` this is exactly the median's breakdown property, and it also shows the top rung
— the certified budget — has no protection at all, since its `m+1` rung does not exist.
The general form (`card_passSet_agree_le`, `quotaBudget_agree_le`) gives the classical
breakdown point: corrupting any `m` of `2m + 1` seeds keeps the median rung inside the
clean ensemble's range (`median_breakdown_half`), and `m + 1` corruptions already make it
arbitrary (`three_seed_breakdown_sharp`), so `1/2` is sharp.  Safety and robustness are
genuinely in tension: `quota_safe_iff_full` proves a quota budget is safe for *all* seeds
iff it is the full-quota budget.

**(3) What does the two-context data predict at `32×`?**  The median and the maximum are
exactly the order statistics whose two-context fits are *intercept-free*
(`intercept_free_dichotomy`), i.e. genuine ratio laws (`7/8` and `1`); the low tail is not
(`96 = 1024/16 + 32`, `160 = 2048/16 + 32`).  The two admissible low-tail families —
constant ratio `5/8` versus the affine fit — therefore split at every longer context, with
gap `ctx/64 - 32` (`lowtail_extrapolation_gap`): `0` at `2048` (where they were fitted),
exactly one grid step `32` at `4096`, and growing thereafter.  This is a falsifiable
pre-registration for the next cell.  Under the affine reading the best-case speedup is the
bounded hyperbola `16·ctx/(ctx + 512)` (`affine_best_case_speedup`,
`affine_best_case_mono`), so the observed `32/3 → 12.8` growth saturates below `16×`.

**(4) The pre-registered four-seed test.**  With the recorded knees `{256, 224, 160}` and a
fourth seed `x`, the upper-median (quota-3) budget stays at `224` **iff** `x ≤ 224`
(`fourSeed_upper_median_iff`), the lower-median (quota-2) budget is
`min 224 (max 160 x)` (`fourSeed_lower_median`), and the certified budget is `max 256 x`
(`fourSeed_certified`).  The `7/8` law's four-seed form is thus decided by a single
inequality, stated before the run.
-/

import Mathlib
import Logic.KneeMedianLaw

namespace KneeQuota

open Finset KneeMedian KneeFluctuation

/-! ## 1.  Order statistics are equivariant under monotone maps -/

/-- The median of three elements of any linear order. -/
def med3L {α : Type*} [LinearOrder α] (a b c : α) : α := max (min a b) (min (max a b) c)

theorem med3L_nat (a b c : ℕ) : med3L a b c = med3 a b c := rfl

/-- **Equivariance.**  A monotone reparametrisation of the budget axis commutes with the
median.  Order statistics are intrinsic to the sample, not to the scale it is read on. -/
theorem med3L_map {α β : Type*} [LinearOrder α] [LinearOrder β] {f : α → β} (hf : Monotone f)
    (a b c : α) : med3L (f a) (f b) (f c) = f (med3L a b c) := by
  simp [med3L, hf.map_min, hf.map_max]

/-- The grid-quantisation map of a sweep of step `s` is monotone. -/
theorem gridKnee_mono {s : ℝ} (hs : 0 < s) : Monotone (gridKnee s) := by
  intro x y hxy
  have h : (⌈x / s⌉₊ : ℝ) ≤ (⌈y / s⌉₊ : ℝ) := by
    exact_mod_cast Nat.ceil_le_ceil (by gcongr)
  simpa [gridKnee] using mul_le_mul_of_nonneg_left h hs.le

/-- **The measured median is the quantisation of the true median.**  Sweeping on a grid of
step `s` and then taking the median of the three reported knees gives exactly the same
number as taking the median of the three true knees and then quantising.  The `7/8` median
law is therefore not a grid artefact. -/
theorem gridKnee_med3 {s : ℝ} (hs : 0 < s) (a b c : ℝ) :
    med3L (gridKnee s a) (gridKnee s b) (gridKnee s c) = gridKnee s (med3L a b c) :=
  med3L_map (gridKnee_mono hs) a b c

/-- The quantisation error of the measured median is the quantisation error of the true
median: nonnegative and strictly less than one grid step. -/
theorem gridKnee_med3_error {s : ℝ} (hs : 0 < s) {a b c : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) :
    0 ≤ med3L (gridKnee s a) (gridKnee s b) (gridKnee s c) - med3L a b c ∧
      med3L (gridKnee s a) (gridKnee s b) (gridKnee s c) - med3L a b c < s := by
  have hmed0 : 0 ≤ med3L a b c := le_max_of_le_left (le_min ha hb)
  rw [gridKnee_med3 hs]
  exact ⟨by linarith [le_gridKnee (s := s) (κ := med3L a b c) hs],
    gridKnee_overshoot_lt_step hs hmed0⟩

/-! ## 2.  How far one seed can move a quota budget -/

section Perturbation

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Replacing one seed changes the pass count by at most one. -/
theorem card_passSet_update_le (K : ι → ℕ) (i₀ : ι) (x b : ℕ) :
    (passSet (Function.update K i₀ x) b).card ≤ (passSet K b).card + 1 := by
  have hsub : passSet (Function.update K i₀ x) b ⊆ insert i₀ (passSet K b) := by
    intro i hi
    simp only [passSet, mem_filter, mem_univ, true_and] at hi
    by_cases h : i = i₀
    · subst h
      exact mem_insert_self i (passSet K b)
    · refine mem_insert_of_mem ?_
      simp only [passSet, mem_filter, mem_univ, true_and]
      rwa [Function.update_of_ne h] at hi
  exact (card_le_card hsub).trans (card_insert_le _ _)

/-- **One seed cannot lower a quota budget by more than one rung.** -/
theorem quotaBudget_update_le (K : ι → ℕ) (i₀ : ι) (x m : ℕ)
    (hm : m + 1 ≤ Fintype.card ι) :
    quotaBudget K m ≤ quotaBudget (Function.update K i₀ x) (m + 1) := by
  have h := card_passSet_quotaBudget (K := Function.update K i₀ x) (m := m + 1) hm
  have h2 := card_passSet_update_le K i₀ x (quotaBudget (Function.update K i₀ x) (m + 1))
  exact quotaBudget_le_of_card (by omega)

/-- **…and cannot raise it by more than one rung either.** -/
theorem quotaBudget_le_update (K : ι → ℕ) (i₀ : ι) (x m : ℕ)
    (hm : m + 1 ≤ Fintype.card ι) :
    quotaBudget (Function.update K i₀ x) m ≤ quotaBudget K (m + 1) := by
  have hback : Function.update (Function.update K i₀ x) i₀ (K i₀) = K := by
    rw [Function.update_idem, Function.update_eq_self]
  have h := quotaBudget_update_le (Function.update K i₀ x) i₀ (K i₀) m hm
  rwa [hback] at h

/-- **General breakdown theorem for quota budgets.**  Replacing a single seed moves the
`m`-quota budget no further than the neighbouring rungs of the *original* ensemble.  For
three seeds and `m = 2` this is the median's robustness; for the top rung `m = card ι`
there is no rung above, which is precisely why the certified budget has no protection. -/
theorem quota_one_seed_breakdown (K : ι → ℕ) (i₀ : ι) (x m : ℕ)
    (hm : m + 1 ≤ Fintype.card ι) :
    quotaBudget K m ≤ quotaBudget (Function.update K i₀ x) (m + 1) ∧
      quotaBudget (Function.update K i₀ x) m ≤ quotaBudget K (m + 1) :=
  ⟨quotaBudget_update_le K i₀ x m hm, quotaBudget_le_update K i₀ x m hm⟩

/-- Corrupting the seeds in a set `S` changes the pass count by at most `#S`. -/
theorem card_passSet_agree_le (K K' : ι → ℕ) (S : Finset ι) (hagree : ∀ i ∉ S, K i = K' i)
    (b : ℕ) : (passSet K' b).card ≤ (passSet K b).card + S.card := by
  have hsub : passSet K' b ⊆ passSet K b ∪ S := by
    intro i hi
    simp only [passSet, mem_filter, mem_univ, true_and] at hi
    by_cases h : i ∈ S
    · exact mem_union_right _ h
    · refine mem_union_left _ ?_
      simp only [passSet, mem_filter, mem_univ, true_and]
      rwa [hagree i h]
  calc (passSet K' b).card ≤ (passSet K b ∪ S).card := card_le_card hsub
    _ ≤ (passSet K b).card + S.card := card_union_le _ _

/-- **`r` corrupted seeds move a quota budget by at most `r` rungs.**  The one-seed case is
`quotaBudget_update_le`; this is the general form used for breakdown points. -/
theorem quotaBudget_agree_le (K K' : ι → ℕ) (S : Finset ι) (hagree : ∀ i ∉ S, K i = K' i)
    (m₀ : ℕ) (h : m₀ + S.card ≤ Fintype.card ι) :
    quotaBudget K m₀ ≤ quotaBudget K' (m₀ + S.card) := by
  have h1 := card_passSet_quotaBudget (K := K') (m := m₀ + S.card) h
  have h2 := card_passSet_agree_le K K' S hagree (quotaBudget K' (m₀ + S.card))
  exact quotaBudget_le_of_card (by omega)

omit [DecidableEq ι] in
/-- **Safety forces the top rung.**  A quota budget covers every seed iff it coincides with
the full-quota (certified) budget.  Any strictly cheaper rung — the median in particular —
leaves some seed below the bar. -/
theorem quota_safe_iff_full [Nonempty ι] (K : ι → ℕ) (m : ℕ) (hm : m ≤ Fintype.card ι) :
    (∀ i, K i ≤ quotaBudget K m) ↔ quotaBudget K m = quotaBudget K (Fintype.card ι) := by
  constructor
  · intro hall
    refine le_antisymm (quotaBudget_mono hm le_rfl) ?_
    refine quotaBudget_le_of_card ?_
    have huniv : passSet K (quotaBudget K m) = univ := by
      ext i; simpa [passSet] using hall i
    simp [huniv]
  · intro heq i
    rw [heq, quotaBudget_full]
    exact le_sup (f := K) (mem_univ i)

end Perturbation

/-- Instance of the breakdown theorem at the three-seed cell: whatever the third seed
reports, the majority budget stays between the best and the worst of the other two. -/
theorem three_seed_median_breakdown (a b x : ℕ) :
    min a b ≤ med3 x a b ∧ med3 x a b ≤ max a b := med3_breakdown x a b

/-- **The median rung has breakdown point `1/2`.**  For `2m + 1` seeds, corrupting any `m`
of them leaves the median rung inside the range of the *clean* ensemble: it can never be
pushed below the clean best case nor above the clean guarantee. -/
theorem median_breakdown_half {m : ℕ} (K K' : Fin (2 * m + 1) → ℕ) (S : Finset (Fin (2 * m + 1)))
    (hS : S.card ≤ m) (hagree : ∀ i ∉ S, K i = K' i) :
    quotaBudget K 1 ≤ quotaBudget K' (m + 1) ∧
      quotaBudget K' (m + 1) ≤ quotaBudget K (2 * m + 1) := by
  have hcard : Fintype.card (Fin (2 * m + 1)) = 2 * m + 1 := by simp
  constructor
  · have hle := quotaBudget_agree_le K K' S hagree 1 (by omega)
    have hmono : quotaBudget K' (1 + S.card) ≤ quotaBudget K' (m + 1) :=
      quotaBudget_mono (by omega) (by omega)
    exact hle.trans hmono
  · have hagree' : ∀ i ∉ S, K' i = K i := fun i hi => (hagree i hi).symm
    have hle := quotaBudget_agree_le K' K S hagree' (m + 1) (by omega)
    have hmono : quotaBudget K (m + 1 + S.card) ≤ quotaBudget K (2 * m + 1) :=
      quotaBudget_mono (by omega) (by omega)
    exact hle.trans hmono

/-- **And the breakdown point is sharp.**  With `m + 1` corrupted seeds out of `2m + 1` the
median is unconstrained: already at three seeds, corrupting two of them puts the median at
any prescribed value. -/
theorem three_seed_breakdown_sharp (K : Fin 3 → ℕ) (B : ℕ) :
    ∃ K' : Fin 3 → ℕ, ∃ S : Finset (Fin 3), S.card = 2 ∧ (∀ i ∉ S, K i = K' i) ∧
      med3 (K' 0) (K' 1) (K' 2) = B := by
  refine ⟨![B, B, K 2], {0, 1}, by decide, ?_, ?_⟩
  · intro i hi
    fin_cases i <;> simp_all
  · simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
    unfold med3
    omega

/-! ## 3.  Ratio laws versus affine laws: what the two contexts predict at `32×` -/

/-- An affine budget law `ctx ↦ α·ctx + β`. -/
def affineLaw (α β ctx : ℚ) : ℚ := α * ctx + β

/-- **The median's two-context fit is intercept-free**, i.e. it *is* the ratio law
`median = (7/8)·(d·ctx/32)` with `d = 4`, namely `median = (7/64)·ctx`. -/
theorem median_fit_intercept_free (α β : ℚ)
    (h1 : affineLaw α β 1024 = 112) (h2 : affineLaw α β 2048 = 224) :
    α = 7 / 64 ∧ β = 0 := by
  unfold affineLaw at h1 h2
  constructor <;> linarith

/-- The maximum's fit is intercept-free too: the product law `max = ctx/8`. -/
theorem max_fit_intercept_free (α β : ℚ)
    (h1 : affineLaw α β 1024 = 128) (h2 : affineLaw α β 2048 = 256) :
    α = 1 / 8 ∧ β = 0 := by
  unfold affineLaw at h1 h2
  constructor <;> linarith

/-- **The low tail's fit is not intercept-free**: `96` and `160` force `β = 32 ≠ 0`.
Together with the previous two lemmas this is the affine form of the quota dichotomy — the
top two rungs of the ladder scale, the bottom rung does not. -/
theorem lowtail_fit_has_intercept (α β : ℚ)
    (h1 : affineLaw α β 1024 = 96) (h2 : affineLaw α β 2048 = 160) :
    α = 1 / 16 ∧ β = 32 ∧ β ≠ 0 := by
  unfold affineLaw at h1 h2
  have hbeta : β = 32 := by linarith
  exact ⟨by linarith, hbeta, by rw [hbeta]; norm_num⟩

/-- **The dichotomy, packaged.**  Exactly the median and the maximum admit intercept-free
(pure ratio) two-context laws. -/
theorem intercept_free_dichotomy :
    (∀ α β : ℚ, affineLaw α β 1024 = 112 → affineLaw α β 2048 = 224 → β = 0) ∧
      (∀ α β : ℚ, affineLaw α β 1024 = 128 → affineLaw α β 2048 = 256 → β = 0) ∧
      (∀ α β : ℚ, affineLaw α β 1024 = 96 → affineLaw α β 2048 = 160 → β ≠ 0) :=
  ⟨fun α β h1 h2 => (median_fit_intercept_free α β h1 h2).2,
    fun α β h1 h2 => (max_fit_intercept_free α β h1 h2).2,
    fun α β h1 h2 => (lowtail_fit_has_intercept α β h1 h2).2.2⟩

/-- The constant-ratio prediction for the low tail: `(5/8)·(d·ctx/32) = (5/64)·ctx`. -/
def lowtailRatioPred (ctx : ℚ) : ℚ := 5 / 64 * ctx

/-- The affine prediction for the low tail, fitted at the two measured contexts. -/
def lowtailAffinePred (ctx : ℚ) : ℚ := affineLaw (1 / 16) 32 ctx

/-- **The two low-tail families are indistinguishable exactly at the fitted contexts and
split linearly beyond them.**  The gap is `ctx/64 - 32`: zero at `1024` and `2048`, exactly
one grid step (`32`) at `ctx = 4096`, and growing. -/
theorem lowtail_extrapolation_gap (ctx : ℚ) :
    lowtailRatioPred ctx - lowtailAffinePred ctx = ctx / 64 - 32 := by
  unfold lowtailRatioPred lowtailAffinePred affineLaw
  ring

/-- The falsifiable next-cell numbers: at `ctx = 4096` the ratio family predicts a low tail
of `320`, the affine family `288`, one grid step apart — a single `32×` run decides. -/
theorem lowtail_prediction_32x :
    lowtailRatioPred 4096 = 320 ∧ lowtailAffinePred 4096 = 288 ∧
      lowtailRatioPred 4096 - lowtailAffinePred 4096 = 32 := by
  refine ⟨by norm_num [lowtailRatioPred], by norm_num [lowtailAffinePred, affineLaw], ?_⟩
  rw [lowtail_extrapolation_gap]
  norm_num

/-- The two families agree at the context where the ratio was read off, so nothing measured
*at that cell* separates them: the split at `4096` is genuinely a prediction. -/
theorem lowtail_families_agree_at_16x :
    lowtailRatioPred 2048 = lowtailAffinePred 2048 := by
  norm_num [lowtailRatioPred, lowtailAffinePred, affineLaw]

/-- **The constant-ratio reading of the low tail already fails backwards.**  Holding the
`16×` ratio `5/8` fixed retrodicts a low tail of `80` at `ctx = 1024`, where `96` was
measured — the quantitative form of `KneeMedian.min_has_no_ratio_law`.  The affine fit, by
construction, reproduces both. -/
theorem lowtail_ratio_fails_backwards :
    lowtailRatioPred 1024 = 80 ∧ (80 : ℚ) ≠ 96 ∧ lowtailAffinePred 1024 = 96 := by
  refine ⟨by norm_num [lowtailRatioPred], by norm_num, by norm_num [lowtailAffinePred, affineLaw]⟩

/-- The median law extrapolated to `32×`: `(7/8)·512 = 448`, and the guarantee end stays at
the product point `512`.  Both are ratio predictions, so both are already pinned by the two
measured contexts. -/
theorem median_prediction_32x :
    (7 : ℚ) / 64 * 4096 = 448 ∧ (1 : ℚ) / 8 * 4096 = 512 ∧ (448 : ℚ) = 7 / 8 * 512 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- **The affine low tail makes the best-case speedup saturate.**  If the low tail really
is `ctx/16 + 32`, the best-case speedup is `16·ctx/(ctx + 512)`, which is strictly below
`16×` at every context — the observed jump `32/3 → 12.8` is then the start of a bounded
hyperbola, not of unbounded growth. -/
theorem affine_best_case_speedup (ctx : ℝ) (h : 0 < ctx) :
    speedup ctx (ctx / 16 + 32) = 16 * ctx / (ctx + 512) ∧
      speedup ctx (ctx / 16 + 32) < 16 := by
  have hpos : 0 < ctx + 512 := by linarith
  have h1 : ctx / 16 + 32 ≠ 0 := ne_of_gt (by linarith)
  have h2 : ctx + 512 ≠ 0 := ne_of_gt hpos
  have heq : speedup ctx (ctx / 16 + 32) = 16 * ctx / (ctx + 512) := by
    rw [speedup, div_eq_div_iff h1 h2]
    ring
  refine ⟨heq, ?_⟩
  rw [heq, div_lt_iff₀ hpos]
  linarith

/-- …and it is strictly increasing in the context, matching `32/3 < 12.8`. -/
theorem affine_best_case_mono {c₁ c₂ : ℝ} (h₁ : 0 < c₁) (h₁₂ : c₁ < c₂) :
    16 * c₁ / (c₁ + 512) < 16 * c₂ / (c₂ + 512) := by
  have hp₁ : 0 < c₁ + 512 := by linarith
  have hp₂ : 0 < c₂ + 512 := by linarith
  rw [div_lt_div_iff₀ hp₁ hp₂]
  nlinarith

/-- The two measured best cases are exactly the affine hyperbola's values. -/
theorem affine_best_case_measured :
    16 * (1024 : ℝ) / (1024 + 512) = 32 / 3 ∧ 16 * (2048 : ℝ) / (2048 + 512) = 12.8 := by
  constructor <;> norm_num

/-! ## 4.  The pre-registered four-seed test at `ctx = 2048` -/

/-- The four-seed ensemble: the three recorded knees plus an unknown fourth seed. -/
def knees16four (x : ℕ) : Fin 4 → ℕ := ![256, 224, 160, x]

theorem card_passSet_four (K : Fin 4 → ℕ) (b : ℕ) :
    (passSet K b).card = (if K 0 ≤ b then 1 else 0) + (if K 1 ≤ b then 1 else 0) +
      (if K 2 ≤ b then 1 else 0) + (if K 3 ≤ b then 1 else 0) := by
  rw [passSet, Finset.card_filter, Fin.sum_univ_four]

/-- The pass count of the four-seed ensemble, written out. -/
theorem card_passSet_knees16four (x b : ℕ) :
    (passSet (knees16four x) b).card = (if 256 ≤ b then 1 else 0) + (if 224 ≤ b then 1 else 0) +
      (if 160 ≤ b then 1 else 0) + (if x ≤ b then 1 else 0) := by
  rw [card_passSet_four]
  simp [knees16four]

/-- The upper-median (quota-3) budget of the four-seed ensemble. -/
theorem fourSeed_upper_median (x : ℕ) :
    quotaBudget (knees16four x) 3 = max 224 (min 256 x) := by
  refine le_antisymm (quotaBudget_le_of_card ?_) ?_
  · rw [card_passSet_knees16four]; split_ifs <;> omega
  · have h := card_passSet_quotaBudget (K := knees16four x) (m := 3) (by simp)
    rw [card_passSet_knees16four] at h
    revert h
    split_ifs <;> omega

/-- **The four-seed low-tail test.**  The upper-median (quota-3) budget of the completed
four-seed ensemble stays at the `7/8` value `224` precisely when the fourth seed does not
exceed `224`.  Stated before the run: this single inequality decides whether the `7/8` law
survives a fourth seed at `16×`. -/
theorem fourSeed_upper_median_iff (x : ℕ) :
    quotaBudget (knees16four x) 3 = 224 ↔ x ≤ 224 := by
  rw [fourSeed_upper_median]; omega

/-- The lower-median (quota-2) budget of the four-seed ensemble. -/
theorem fourSeed_lower_median (x : ℕ) :
    quotaBudget (knees16four x) 2 = min 224 (max 160 x) := by
  refine le_antisymm (quotaBudget_le_of_card ?_) ?_
  · rw [card_passSet_knees16four]; split_ifs <;> omega
  · have h := card_passSet_quotaBudget (K := knees16four x) (m := 2) (by simp)
    rw [card_passSet_knees16four] at h
    revert h
    split_ifs <;> omega

/-- The certified budget of the four-seed ensemble: `max 256 x`.  A fourth seed can only
raise the guarantee — the top rung is unprotected, exactly as `quota_one_seed_breakdown`
predicts. -/
theorem fourSeed_certified (x : ℕ) : quotaBudget (knees16four x) 4 = max 256 x := by
  refine le_antisymm (quotaBudget_le_of_card ?_) ?_
  · rw [card_passSet_knees16four]; split_ifs <;> omega
  · have h := card_passSet_quotaBudget (K := knees16four x) (m := 4) (by simp)
    rw [card_passSet_knees16four] at h
    revert h
    split_ifs <;> omega

/-- **The pre-registration, in one statement.**  If the fourth seed lands at or below `224`
(in particular at the announced low-tail candidates `160` or `192`) the four-seed median
window is `[min 224 (max 160 x), 224]`, still centred on the `7/8` value; if it lands above
`224` the upper median moves off `224` and the `7/8` law is refuted at four seeds. -/
theorem fourSeed_preregistration (x : ℕ) :
    (x ≤ 224 → quotaBudget (knees16four x) 3 = 224 ∧
      quotaBudget (knees16four x) 2 = min 224 (max 160 x)) ∧
      (224 < x → quotaBudget (knees16four x) 3 ≠ 224) := by
  refine ⟨fun hx => ⟨(fourSeed_upper_median_iff x).2 hx, fourSeed_lower_median x⟩, fun hx hc => ?_⟩
  have := (fourSeed_upper_median_iff x).1 hc
  omega

end KneeQuota