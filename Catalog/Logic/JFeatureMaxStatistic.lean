/-
# Max-statistic calibration: why a scan over many cells needs its own null

The j-feature sweep of paper 248 produced a raw maximum of `R = 1.5578`
(cell `j ≡ 73 mod 105`, `n = 1022`, 26 hits) which nevertheless sits *below* the
null distribution's own median max-of-105-ratios (`1.6334`), giving a global
permutation p-value of `0.754`.  This file proves the four facts that make that
inference airtight, in a finite ensemble model.

Let `Ω` be a finite ensemble of null draws (the permutation replicates) and
`T : Ω → ℝ` a statistic.  The one-sided permutation p-value of an observed
value `t` is `pval T t = #{ω : T ω ≥ t} / #Ω`.

* `pval_ge_half_of_le_median` : **the median argument.**  If the observed value
  lies at or below a median of the null statistic, the p-value is at least
  `1/2` — no calibration constant, no distributional assumption.  This is the
  exact inference used to dismiss `R = 1.5578 < 1.6334`.
* `pval_eq_one_of_floor` : **the uncalibrated max test has size 1.**  Since the
  selection floor of `Logic.JFeatureMarginalBlindness` forces every null draw's
  max ratio to be at least `1`, testing "is the max ratio `> 1`?" rejects with
  probability `1` under the null.  Calibration is not optional.
* `pval_max_le_sum_pval` and `bonferroni_valid` : the union bound over cells,
  and the validity of the Bonferroni adjustment `min 1 (K * p)`.
* `perm_pval_valid` : **exact finite-sample validity** of the permutation
  p-value: `#{ω : pval T (T ω) ≤ α} ≤ α * #Ω` for every `α ≥ 0`, with no
  assumption on `T` whatsoever.  This is what licenses the max-statistic
  calibration in the first place.
-/
import Mathlib

namespace Logic.JFeature

open Finset

section MaxStatistic

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- One-sided permutation p-value of the observed value `t` for the statistic
`T` evaluated on the null ensemble `Ω`. -/
noncomputable def pval (T : Ω → ℝ) (t : ℝ) : ℝ :=
  ((univ.filter (fun w => t ≤ T w)).card : ℝ) / (Fintype.card Ω : ℝ)

/-- `m` is a median of `T` on the null ensemble. -/
def IsMedian (T : Ω → ℝ) (m : ℝ) : Prop :=
  Fintype.card Ω ≤ 2 * (univ.filter (fun w => m ≤ T w)).card ∧
    Fintype.card Ω ≤ 2 * (univ.filter (fun w => T w ≤ m)).card

lemma card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
  have : 0 < Fintype.card Ω := Fintype.card_pos
  exact_mod_cast this

lemma pval_nonneg (T : Ω → ℝ) (t : ℝ) : 0 ≤ pval T t := by
  unfold pval; positivity

lemma pval_le_one (T : Ω → ℝ) (t : ℝ) : pval T t ≤ 1 := by
  rw [pval, div_le_one card_pos]
  have := Finset.card_filter_le (univ : Finset Ω) (fun w => t ≤ T w)
  simpa [Finset.card_univ] using (by exact_mod_cast this : ((univ.filter (fun w => t ≤ T w)).card : ℝ) ≤ (Fintype.card Ω : ℝ))

/-- The p-value is antitone in the observed value: a smaller observation is
less significant. -/
lemma pval_antitone (T : Ω → ℝ) {t t' : ℝ} (h : t ≤ t') : pval T t' ≤ pval T t := by
  rw [pval, pval, div_le_div_iff_of_pos_right card_pos]
  have hsub : univ.filter (fun w => t' ≤ T w) ⊆ univ.filter (fun w => t ≤ T w) := by
    intro w hw
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hw ⊢
    exact le_trans h hw
  exact_mod_cast Finset.card_le_card hsub

/-- **The median argument.**  An observation at or below a median of the null
distribution has permutation p-value at least `1/2`.  Applied to the sweep:
`R = 1.5578` against a null median max of `1.6334` can never be significant. -/
theorem pval_ge_half_of_le_median {T : Ω → ℝ} {m t : ℝ} (hm : IsMedian T m)
    (ht : t ≤ m) : 1 / 2 ≤ pval T t := by
  have h1 : pval T m ≤ pval T t := pval_antitone T ht
  have h2 : 1 / 2 ≤ pval T m := by
    rw [pval, le_div_iff₀ card_pos]
    have := hm.1
    have hR : (Fintype.card Ω : ℝ) ≤ 2 * ((univ.filter (fun w => m ≤ T w)).card : ℝ) := by
      exact_mod_cast this
    linarith
  linarith

/-- **The uncalibrated max test has size one.**  If every null draw already
produces a statistic at least `1` — which the pigeonhole selection floor
guarantees for max-of-cells enrichment ratios — then the threshold `1` rejects
on the entire null ensemble. -/
theorem pval_eq_one_of_floor {T : Ω → ℝ} (h : ∀ w, 1 ≤ T w) : pval T 1 = 1 := by
  have hfil : univ.filter (fun w => (1:ℝ) ≤ T w) = univ := by
    ext w; simp [h w]
  rw [pval, hfil, Finset.card_univ]
  exact div_self (ne_of_gt card_pos)

/-! ### Scanning many cells: union bound and Bonferroni -/

variable {κ : Type*} [Fintype κ]

/-- The max-of-cells statistic. -/
noncomputable def maxStat (T : κ → Ω → ℝ) (hκ : (univ : Finset κ).Nonempty) (w : Ω) : ℝ :=
  (univ : Finset κ).sup' hκ (fun c => T c w)

/-- **Union bound over the scanned cells.**  The p-value of the max statistic is
at most the sum of the per-cell p-values — the exact content of the Bonferroni
correction, and the reason a per-cell `p = 0.36` says nothing about a scan. -/
theorem pval_max_le_sum_pval (T : κ → Ω → ℝ) (hκ : (univ : Finset κ).Nonempty) (t : ℝ) :
    pval (maxStat T hκ) t ≤ ∑ c : κ, pval (T c) t := by
  classical
  have hsub : univ.filter (fun w => t ≤ maxStat T hκ w)
      ⊆ (univ : Finset κ).biUnion (fun c => univ.filter (fun w => t ≤ T c w)) := by
    intro w hw
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, maxStat,
      Finset.le_sup'_iff] at hw
    obtain ⟨c, hc⟩ := hw
    exact Finset.mem_biUnion.2 ⟨c, Finset.mem_univ c, by simp [hc]⟩
  have hcard : ((univ.filter (fun w => t ≤ maxStat T hκ w)).card : ℝ)
      ≤ ∑ c : κ, ((univ.filter (fun w => t ≤ T c w)).card : ℝ) := by
    have h1 := Finset.card_le_card hsub
    have h2 := Finset.card_biUnion_le (s := (univ : Finset κ))
      (t := fun c => univ.filter (fun w => t ≤ T c w))
    have : (univ.filter (fun w => t ≤ maxStat T hκ w)).card
        ≤ ∑ c : κ, (univ.filter (fun w => t ≤ T c w)).card := le_trans h1 h2
    exact_mod_cast this
  rw [pval]
  calc ((univ.filter (fun w => t ≤ maxStat T hκ w)).card : ℝ) / (Fintype.card Ω : ℝ)
      ≤ (∑ c : κ, ((univ.filter (fun w => t ≤ T c w)).card : ℝ)) / (Fintype.card Ω : ℝ) := by
        gcongr
    _ = ∑ c : κ, pval (T c) t := by
        rw [Finset.sum_div]; rfl

/-- **Bonferroni validity.**  If some cell's raw p-value would reject at level
`α / K`, the max statistic's p-value is still bounded by `α`. -/
theorem bonferroni_valid (T : κ → Ω → ℝ) (hκ : (univ : Finset κ).Nonempty) (t α : ℝ)
    (h : ∀ c, pval (T c) t ≤ α / (Fintype.card κ : ℝ)) :
    pval (maxStat T hκ) t ≤ α := by
  have hK : (0 : ℝ) < (Fintype.card κ : ℝ) := by
    have : 0 < Fintype.card κ := Finset.card_pos.2 hκ
    exact_mod_cast this
  refine le_trans (pval_max_le_sum_pval T hκ t) ?_
  have : ∑ _c : κ, α / (Fintype.card κ : ℝ) = α := by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp
  calc ∑ c : κ, pval (T c) t ≤ ∑ _c : κ, α / (Fintype.card κ : ℝ) :=
        Finset.sum_le_sum fun c _ => h c
    _ = α := this

/-! ### Exact finite-sample validity of the permutation p-value -/

/-- **Validity of the permutation p-value.**  For every statistic `T`, every
finite null ensemble and every level `α ≥ 0`, at most an `α`-fraction of the
ensemble has self-p-value below `α`.  No exchangeability beyond the ensemble
itself, and no distributional assumption, is needed. -/
theorem perm_pval_valid (T : Ω → ℝ) {α : ℝ} (hα : 0 ≤ α) :
    (((univ.filter (fun w => pval T (T w) ≤ α)).card : ℝ)) ≤ α * (Fintype.card Ω : ℝ) := by
  classical
  set S := univ.filter (fun w => pval T (T w) ≤ α) with hS
  rcases S.eq_empty_or_nonempty with hemp | hne
  · rw [hemp]
    simp only [Finset.card_empty, Nat.cast_zero]
    positivity
  · obtain ⟨w₀, hw₀S, hw₀min⟩ := S.exists_min_image T hne
    have hw₀ : pval T (T w₀) ≤ α := by
      have := Finset.mem_filter.1 (hS ▸ hw₀S)
      exact this.2
    have hsub : S ⊆ univ.filter (fun w => T w₀ ≤ T w) := by
      intro w hw
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact hw₀min w hw
    have hcard : ((S.card : ℝ)) ≤ ((univ.filter (fun w => T w₀ ≤ T w)).card : ℝ) := by
      exact_mod_cast Finset.card_le_card hsub
    have hpv : ((univ.filter (fun w => T w₀ ≤ T w)).card : ℝ)
        = pval T (T w₀) * (Fintype.card Ω : ℝ) := by
      rw [pval, div_mul_cancel₀]
      exact ne_of_gt card_pos
    rw [hpv] at hcard
    have := mul_le_mul_of_nonneg_right hw₀ (le_of_lt (card_pos (Ω := Ω)))
    linarith

/-- **The sweep verdict, formally.**  If the observed max-of-cells statistic
lies at or below a median of the null max distribution, then the scan cannot be
significant at any level below `1/2`; and separately, the naive threshold `1`
would have rejected on the whole ensemble. -/
theorem max_statistic_calibration {T : Ω → ℝ} {m t : ℝ}
    (hm : IsMedian T m) (ht : t ≤ m) (hfloor : ∀ w, 1 ≤ T w) {α : ℝ} (hα : α < 1 / 2) :
    ¬ (pval T t ≤ α) ∧ pval T 1 = 1 := by
  refine ⟨fun hcon => ?_, pval_eq_one_of_floor hfloor⟩
  have := pval_ge_half_of_le_median hm ht
  linarith

end MaxStatistic

end Logic.JFeature