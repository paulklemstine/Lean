/-
# Order statistics of a seed ensemble: quota budgets, the median law, and the logical
# independence of point-prediction from centre-prediction (NET-48)

`Logic.KneeFluctuationTwoSeed` formalised the *knee* `k*` of a sweep as a threshold
functional on a finite grid, and `Logic.KneeSeedEnsembleBracket` formalised what an
ensemble of seeds certifies: the **maximum** of the measured knees, i.e. the all-seeds-safe
budget.  Round NET-48 completes the three-seed ensemble at the longest cell and forces a
new object into the theory — the **median**, and more generally the *quota budget*.

**Lab notes (round NET-48, speed axis).**  Cell `(d = 4, ctx = 2048)`, seed 3.  Harness as
in NET-37/44/45/46: `CausalTF`, `d_model = 64`, 4 heads, Gutenberg word corpus, vocab 4097,
held-out last 10 %, data-free top-`k` attention truncation, bar `= 0.98` of full accuracy.
Full acc `0.1546`, bar `0.1516`, full loss `5.2199`, train `14566 s`.

| budget `k` | 96 | 128 | **160** | 192 | 224 | 240 | 256 | 288 | 384 | 512 | 768 | 1024 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| retained, seed 3 | 0.963 | 0.973 | **0.981** | 0.984 | 0.986 | 0.987 | 0.990 | 0.993 | 0.999 | 1.000 | 1.003 | 1.003 |

So `k*(s3) = 160`, with a razor-thin margin `0.001` at the knee.  The four pre-registered
point predictions (`192, 224, 240, 256`) all *pass the bar* and are therefore all refuted as
knee values.  The completed three-seed knee set at this cell is `{256, 224, 160}`
(seeds 1, 2, 3), whose **median is `224 = (7/8)·(d·ctx/32)`**, replicating the `ctx = 1024`
median `112 = (7/8)·128` from knee set `{128, 112, 96}`.

**What this file proves.**

*Order statistics (§1–§2).*
* `KneeMedian.med3_breakdown` : one arbitrary seed can never move the three-seed median
  outside the interval spanned by the other two — the median has a positive breakdown point.
* `KneeMedian.max3_unbounded` : the certified (all-seeds-safe) budget has breakdown point
  zero: a single seed moves it arbitrarily far.  Robustness and safety are in tension.
* `KneeMedian.med3_stable_iff` : the exact family of third-seed values leaving the median
  put: with seeds `224 < 256` recorded, `med3 x 224 256 = 224 ↔ x ≤ 224`
  (`net48_median_stability_family`).
* `KneeMedian.quotaBudget` : the least budget at which at least `m` of the seeds clear the
  bar.  `quotaBudget_mono`, `quotaBudget_full`, `quotaBudget_mem_range`,
  `quotaBudget_eq_certifiedBudget` (the catalog's certified budget is the full-quota case),
  `quotaBudget_three_median` / `quotaBudget_three_all` / `quotaBudget_three_one`: for three
  seeds the quota ladder is exactly `min ≤ median ≤ max`.

*The measurement (§3).*
* `KneeMedian.net48_seed3_knee` : from the measured sweep, `k*(s3) = 160`.
* `KneeMedian.net48_horns_all_pass` and `net48_horns_refuted` : each of `192, 224, 240, 256`
  clears the bar and hence is *not* the knee — 0/4 point predictions.
* `KneeMedian.net48_seed3_knee_not_robust` : the knee margin `0.001` is far below the
  inter-seed spread `0.010`, so the reading is not `spread`-robust — the honest statement of
  "razor-thin".  `net48_lower_bracket_robust` : `96` is nevertheless protected
  (deficit `0.017 > 0.010`), so the robust content is `k* ∈ (96, 160]`.

*The law (§4).*
* `KneeMedian.net48_median_law` and `net44_median_law` : the medians are exactly
  `(7/8)·(d·ctx/32)` at both contexts, and `median_law_ratio_unique` shows `7/8` is the
  *unique* ratio fitting both.
* `KneeMedian.min_has_no_ratio_law` : no single ratio fits the two low tails
  (`3/4` vs `5/8`) — the low tail is genuinely context-dependent, so among the three order
  statistics exactly the median and the maximum admit a context-free ratio law
  (`quota_ratio_dichotomy`).
* `KneeMedian.spread_widens` and `spread_ge_one_eighth` : the ratio spread grows
  `1/4 → 3/8`, and given a pinned upper edge and the `7/8` median the spread is `≥ 1/8`
  with equality iff the low tail is itself `7/8`.

*Deployment (§5).*
* `KneeMedian.median_budget_unsafe` : the median budget is *not* a guarantee — every seed
  whose knee exceeds it fails the bar there (`net48_median_budget_fails_seed1`).
* `KneeMedian.median_speedup_context_free` and `product_speedup_context_free` : both the
  guaranteed speedup `32/d` and the median speedup `256/(7d)` are independent of the
  context, while the best case is not (`best_case_speedup_grows`: `32/3 → 12.8`).

*Point vs centre (§6).*
* `KneeMedian.point_center_independent` : hitting a pre-registered point prediction and
  hitting the predicted distribution centre are logically independent — all four
  combinations are realised by admissible third-seed values against the recorded
  `{224, 256}`.  This is the exact sense in which NET-48 is `0/4` on horns and `1/1` on the
  law.
-/

import Mathlib
import Logic.KneeSeedEnsembleBracket

namespace KneeMedian

open Finset KneeFluctuation

/-! ## 1.  The three-seed median and its breakdown behaviour -/

/-- The median of three budgets. -/
def med3 (a b c : ℕ) : ℕ := max (min a b) (min (max a b) c)

/-- The median is one of the sampled values: it is an order statistic, not an average. -/
theorem med3_mem (a b c : ℕ) : med3 a b c = a ∨ med3 a b c = b ∨ med3 a b c = c := by
  unfold med3; omega

/-- On a sorted sample the median is the middle value. -/
theorem med3_of_sorted {a b c : ℕ} (hab : a ≤ b) (hbc : b ≤ c) : med3 a b c = b := by
  unfold med3; omega

theorem med3_swap₁₂ (a b c : ℕ) : med3 a b c = med3 b a c := by unfold med3; omega

theorem med3_swap₂₃ (a b c : ℕ) : med3 a b c = med3 a c b := by unfold med3; omega

/-- The median is sandwiched by the extremes. -/
theorem med3_between (a b c : ℕ) :
    min a (min b c) ≤ med3 a b c ∧ med3 a b c ≤ max a (max b c) := by
  unfold med3; omega

/-- **Breakdown point of the median.**  However badly one seed misbehaves, the median stays
inside the interval spanned by the other two.  A single outlier cannot move it. -/
theorem med3_breakdown (x b c : ℕ) : min b c ≤ med3 x b c ∧ med3 x b c ≤ max b c := by
  unfold med3; omega

/-- **The certified budget has breakdown point zero.**  The all-seeds-safe budget is the
maximum, and one seed drags it past any bound: safety is unboundedly sensitive to a single
seed, exactly where the median is insensitive. -/
theorem max3_unbounded (b c B : ℕ) : ∃ x, B < max x (max b c) :=
  ⟨B + 1, by omega⟩

/-- **The exact stability family.**  With two seeds already recorded at `b < c`, the third
seed leaves the median at `b` precisely when it does not exceed `b`. -/
theorem med3_stable_iff {b c : ℕ} (h : b < c) (x : ℕ) : med3 x b c = b ↔ x ≤ b := by
  unfold med3
  constructor
  · intro h2; omega
  · intro h2; omega

/-! ## 2.  Quota budgets: the order-statistic ladder of an ensemble -/

section Quota

variable {ι : Type*} [Fintype ι]

/-- The seeds that clear the bar at budget `b`, given their knees `K`. -/
def passSet (K : ι → ℕ) (b : ℕ) : Finset ι := univ.filter (fun i => K i ≤ b)

theorem passSet_mono (K : ι → ℕ) {b b' : ℕ} (h : b ≤ b') : passSet K b ⊆ passSet K b' := by
  intro i hi
  simp only [passSet, mem_filter, mem_univ, true_and] at hi ⊢
  exact hi.trans h

/-- **The quota budget**: the least budget at which at least `m` of the seeds clear the
bar.  `m = card ι` is the certified (all-seeds-safe) budget of
`KneeEnsemble.certifiedBudget`; `m = ⌈n/2⌉` is the median. -/
noncomputable def quotaBudget (K : ι → ℕ) (m : ℕ) : ℕ := sInf {b | m ≤ (passSet K b).card}

theorem passSet_sup (K : ι → ℕ) : passSet K (univ.sup K) = univ := by
  ext i; simp [passSet, le_sup (f := K) (mem_univ i)]

theorem quotaBudget_le_of_card {K : ι → ℕ} {m b : ℕ} (h : m ≤ (passSet K b).card) :
    quotaBudget K m ≤ b := Nat.sInf_le h

/-- At the quota budget the quota really is met (for feasible quotas). -/
theorem card_passSet_quotaBudget {K : ι → ℕ} {m : ℕ} (hm : m ≤ Fintype.card ι) :
    m ≤ (passSet K (quotaBudget K m)).card := by
  have hne : {b | m ≤ (passSet K b).card}.Nonempty := by
    refine ⟨univ.sup K, ?_⟩
    show m ≤ (passSet K (univ.sup K)).card
    rw [passSet_sup]
    simpa using hm
  simpa [quotaBudget] using Nat.sInf_mem hne

/-- **The quota ladder is monotone.**  Demanding more seeds can only cost more budget. -/
theorem quotaBudget_mono {K : ι → ℕ} {m m' : ℕ} (hmm : m ≤ m') (hm' : m' ≤ Fintype.card ι) :
    quotaBudget K m ≤ quotaBudget K m' :=
  quotaBudget_le_of_card (hmm.trans (card_passSet_quotaBudget hm'))

/-- **Full quota = maximum knee.**  The top of the ladder is the all-seeds-safe budget. -/
theorem quotaBudget_full (K : ι → ℕ) : quotaBudget K (Fintype.card ι) = univ.sup K := by
  refine le_antisymm (quotaBudget_le_of_card (by simp [passSet_sup])) ?_
  have h := card_passSet_quotaBudget (K := K) (m := Fintype.card ι) le_rfl
  have huniv : passSet K (quotaBudget K (Fintype.card ι)) = univ :=
    Finset.eq_univ_of_card _ (le_antisymm (card_le_univ _) h)
  refine Finset.sup_le fun i _ => ?_
  have hi : i ∈ passSet K (quotaBudget K (Fintype.card ι)) := huniv ▸ mem_univ i
  simpa [passSet] using hi

/-- Every quota budget is an actually measured knee: the ladder never leaves the sample. -/
theorem quotaBudget_mem_range [Nonempty ι] {K : ι → ℕ} {m : ℕ} (hm1 : 1 ≤ m)
    (hm : m ≤ Fintype.card ι) : ∃ i, K i = quotaBudget K m := by
  set q := quotaBudget K m with hq
  have hcard : m ≤ (passSet K q).card := card_passSet_quotaBudget hm
  by_contra hcon
  push_neg at hcon
  have hsub : passSet K q ⊆ passSet K (q - 1) := by
    intro i hi
    simp only [passSet, mem_filter, mem_univ, true_and] at hi ⊢
    have := hcon i
    omega
  have hstep : m ≤ (passSet K (q - 1)).card := hcard.trans (card_le_card hsub)
  have hle : q ≤ q - 1 := quotaBudget_le_of_card hstep
  have hq0 : q ≠ 0 := by
    intro h0
    rw [h0] at hcard
    obtain ⟨i, hi⟩ := Finset.card_pos.mp (lt_of_lt_of_le hm1 hcard)
    simp only [passSet, mem_filter, mem_univ, true_and, Nat.le_zero] at hi
    exact hcon i (by omega)
  omega

/-- **Bridge to the catalog.**  `KneeEnsemble.certifiedBudget` is the full-quota budget. -/
theorem quotaBudget_eq_certifiedBudget [Nonempty ι] (K : ι → ℕ) :
    quotaBudget K (Fintype.card ι) = KneeEnsemble.certifiedBudget K := by
  rw [quotaBudget_full]
  refine le_antisymm (Finset.sup_le fun i _ => KneeEnsemble.le_certifiedBudget K i) ?_
  obtain ⟨i, hi⟩ := KneeEnsemble.certifiedBudget_mem_range K
  rw [hi]
  exact le_sup (f := K) (mem_univ i)

/-- **Deployment semantics of a quota budget.**  If at least `m` seeds have knees at or
below `b` and `b` is on the grid, then at least `m` seeds clear the bar at `b`. -/
theorem quota_seeds_pass {c : ι → ℕ → ℝ} {K : ι → ℕ} {G : Finset ℕ} {bar : ℝ} {b : ℕ}
    (hmono : ∀ i, Monotone (c i)) (hknee : ∀ i, IsKnee G bar (c i) (K i))
    (i : ι) (hi : i ∈ passSet K b) : bar ≤ c i b := by
  simp only [passSet, mem_filter, mem_univ, true_and] at hi
  exact (hknee i).2.1.trans (hmono i hi)

end Quota

/-- The pass count of a three-seed ensemble, written out. -/
theorem card_passSet_three (K : Fin 3 → ℕ) (b : ℕ) :
    (passSet K b).card
      = (if K 0 ≤ b then 1 else 0) + (if K 1 ≤ b then 1 else 0) + (if K 2 ≤ b then 1 else 0) := by
  rw [passSet, Finset.card_filter, Fin.sum_univ_three]

/-- **Median = majority budget.**  For three seeds the quota-2 budget is exactly the
median: the median is the least budget at which a majority of seeds clears the bar. -/
theorem quotaBudget_three_median (K : Fin 3 → ℕ) :
    quotaBudget K 2 = med3 (K 0) (K 1) (K 2) := by
  refine le_antisymm (quotaBudget_le_of_card ?_) ?_
  · rw [card_passSet_three]
    unfold med3
    split_ifs <;> omega
  · have h := card_passSet_quotaBudget (K := K) (m := 2) (by simp)
    rw [card_passSet_three] at h
    unfold med3
    revert h
    split_ifs <;> omega

/-- Quota 3 of three seeds is the maximum: the certified budget. -/
theorem quotaBudget_three_all (K : Fin 3 → ℕ) :
    quotaBudget K 3 = max (K 0) (max (K 1) (K 2)) := by
  refine le_antisymm (quotaBudget_le_of_card ?_) ?_
  · rw [card_passSet_three]; split_ifs <;> omega
  · have h := card_passSet_quotaBudget (K := K) (m := 3) (by simp)
    rw [card_passSet_three] at h
    revert h
    split_ifs <;> omega

/-- Quota 1 of three seeds is the minimum: the best-case (single-seed) reading. -/
theorem quotaBudget_three_one (K : Fin 3 → ℕ) :
    quotaBudget K 1 = min (K 0) (min (K 1) (K 2)) := by
  refine le_antisymm (quotaBudget_le_of_card ?_) ?_
  · rw [card_passSet_three]; split_ifs <;> omega
  · have h := card_passSet_quotaBudget (K := K) (m := 1) (by simp)
    rw [card_passSet_three] at h
    revert h
    split_ifs <;> omega

/-- **The ladder of a three-seed ensemble is `min ≤ median ≤ max`.** -/
theorem quota_ladder_three (K : Fin 3 → ℕ) :
    quotaBudget K 1 ≤ quotaBudget K 2 ∧ quotaBudget K 2 ≤ quotaBudget K 3 :=
  ⟨quotaBudget_mono (by norm_num) (by simp), quotaBudget_mono (by norm_num) (by simp)⟩

/-! ## 3.  The NET-48 measurement at `(d = 4, ctx = 2048)` -/

/-- The NET-48 sweep grid at the `16×` cell. -/
def grid16 : Finset ℕ := {96, 128, 160, 192, 224, 240, 256, 288, 384, 512, 768, 1024}

/-- The measured seed-3 retained-accuracy curve at `(d = 4, ctx = 2048)`. -/
structure Seed3Data (c : ℕ → ℝ) : Prop where
  mono : Monotone c
  at96 : c 96 = 0.963
  at128 : c 128 = 0.973
  at160 : c 160 = 0.981
  at192 : c 192 = 0.984
  at224 : c 224 = 0.986
  at240 : c 240 = 0.987
  at256 : c 256 = 0.990
  at288 : c 288 = 0.993
  at384 : c 384 = 0.999
  at512 : c 512 = 1.000
  at768 : c 768 = 1.003
  at1024 : c 1024 = 1.003

/-- A single upward step of height `a` just after budget `t`. -/
noncomputable def stepUp (t : ℕ) (a : ℝ) : ℕ → ℝ := fun k => if t < k then a else 0

theorem stepUp_mono (t : ℕ) {a : ℝ} (ha : 0 ≤ a) : Monotone (stepUp t a) := by
  intro x y hxy
  simp only [stepUp]
  split_ifs with h1 h2 h2
  · exact le_rfl
  · omega
  · exact ha
  · exact le_rfl

/-- The measured seed-3 curve, realised as a sum of upward steps. -/
noncomputable def seed3Curve : ℕ → ℝ := fun k =>
  0.963 + stepUp 96 0.010 k + stepUp 128 0.008 k + stepUp 160 0.003 k + stepUp 192 0.002 k +
    stepUp 224 0.001 k + stepUp 240 0.003 k + stepUp 256 0.003 k + stepUp 288 0.006 k +
    stepUp 384 0.001 k + stepUp 512 0.003 k

/-- **Non-vacuity.**  An explicit monotone step curve realises the NET-48 record, so every
theorem with a `Seed3Data` hypothesis has content. -/
theorem seed3Data_nonvacuous : Seed3Data seed3Curve := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · unfold seed3Curve
    exact ((((((((((monotone_const.add (stepUp_mono 96 (by norm_num))).add
      (stepUp_mono 128 (by norm_num))).add (stepUp_mono 160 (by norm_num))).add
      (stepUp_mono 192 (by norm_num))).add (stepUp_mono 224 (by norm_num))).add
      (stepUp_mono 240 (by norm_num))).add (stepUp_mono 256 (by norm_num))).add
      (stepUp_mono 288 (by norm_num))).add (stepUp_mono 384 (by norm_num))).add
      (stepUp_mono 512 (by norm_num)))
  all_goals norm_num [seed3Curve, stepUp]

/-- **Seed 3's knee is `160`.**  `96` and `128` miss the bar, `160` clears it. -/
theorem net48_seed3_knee {c : ℕ → ℝ} (h : Seed3Data c) : IsKnee grid16 bar c 160 := by
  obtain ⟨hm, h96, h128, h160, -, -, -, -, -, -, -, -, -⟩ := h
  refine ⟨by decide, by rw [h160]; norm_num [bar], ?_⟩
  intro j hj hpass
  fin_cases hj <;> simp_all [bar] <;> linarith

/-- **All four pre-registered point predictions clear the bar.**  Each of `192, 224, 240,
256` is a passing budget, hence an upper bound for the knee — none of them is the knee. -/
theorem net48_horns_all_pass {c : ℕ → ℝ} (h : Seed3Data c) :
    bar ≤ c 192 ∧ bar ≤ c 224 ∧ bar ≤ c 240 ∧ bar ≤ c 256 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [h.at192]; norm_num [bar]
  · rw [h.at224]; norm_num [bar]
  · rw [h.at240]; norm_num [bar]
  · rw [h.at256]; norm_num [bar]

/-- **0/4 on the horns.**  No pre-registered value is the measured knee. -/
theorem net48_horns_refuted {c : ℕ → ℝ} (h : Seed3Data c) :
    ¬ IsKnee grid16 bar c 192 ∧ ¬ IsKnee grid16 bar c 224 ∧
      ¬ IsKnee grid16 bar c 240 ∧ ¬ IsKnee grid16 bar c 256 := by
  have hk := net48_seed3_knee h
  refine ⟨fun hc => ?_, fun hc => ?_, fun hc => ?_, fun hc => ?_⟩ <;>
    · have := hk.unique hc; norm_num at this

/-- **The product point passes.**  `k = d·ctx/32 = 256` clears the bar at seed 3, so the
product law survives as an upper bound at this seed too. -/
theorem net48_product_point_safe {c : ℕ → ℝ} (h : Seed3Data c) :
    bar ≤ c 256 ∧ IsKnee grid16 bar c 160 ∧ 160 ≤ 256 :=
  ⟨(net48_horns_all_pass h).2.2.2, net48_seed3_knee h, by norm_num⟩

/-- **The `160` read is razor-thin.**  The margin at the knee is `0.001`, an order of
magnitude below the inter-seed spread `0.010`, so the knee value is not `spread`-robust. -/
theorem net48_seed3_knee_not_robust {c : ℕ → ℝ} (h : Seed3Data c) :
    ¬ RobustKnee grid16 bar c 160 spread := by
  intro hrob
  have hm := margins_of_robustKnee h.mono (by norm_num [spread]) hrob
  rw [h.at160] at hm
  have := hm.1
  norm_num [bar, spread] at this

/-- **But the lower end is protected.**  Every grid point at or below `96` misses the bar by
more than the spread, so no `spread`-perturbation of the seed-3 curve can push the knee down
to `96`: the robust content of the reading is `k* ∈ (96, 160]`. -/
theorem net48_lower_bracket_robust {c c' : ℕ → ℝ} (h : Seed3Data c) {k : ℕ}
    (hclose : ∀ j ∈ grid16, |c' j - c j| ≤ spread) (hk : IsKnee grid16 bar c' k) : 96 < k := by
  refine knee_gt_of_robust_deficit (c := c) (b := 96) ?_ hclose hk
  intro j hj hj96
  have hle : c j ≤ 0.963 := h.at96 ▸ h.mono hj96
  norm_num [bar, spread]
  linarith

/-! ## 4.  The `7/8` median law at two contexts -/

/-- The product-law budget `d·ctx/32`. -/
def productPoint (d ctx : ℕ) : ℕ := d * ctx / 32

theorem productPoint_16x : productPoint 4 2048 = 256 := by norm_num [productPoint]

theorem productPoint_8x : productPoint 4 1024 = 128 := by norm_num [productPoint]

/-- The three-seed knee sample at `ctx = 2048` (seeds 1, 2, 3 of NET-45/46/48). -/
def knees16 : Fin 3 → ℕ := ![256, 224, 160]

/-- The three-seed knee sample at `ctx = 1024` (NET-37/44 and its third seed). -/
def knees8 : Fin 3 → ℕ := ![128, 112, 96]

/-- **The `16×` median is exactly `(7/8)·(d·ctx/32)`.** -/
theorem net48_median_law :
    med3 (knees16 0) (knees16 1) (knees16 2) = 224 ∧
      (224 : ℚ) = 7 / 8 * (productPoint 4 2048 : ℚ) := by
  refine ⟨by decide, by norm_num [productPoint]⟩

/-- **The `8×` median is exactly `(7/8)·(d·ctx/32)`** — the same law one context down. -/
theorem net44_median_law :
    med3 (knees8 0) (knees8 1) (knees8 2) = 112 ∧
      (112 : ℚ) = 7 / 8 * (productPoint 4 1024 : ℚ) := by
  refine ⟨by decide, by norm_num [productPoint]⟩

/-- The medians are the majority (quota-2) budgets of the two ensembles. -/
theorem median_is_majority_budget :
    quotaBudget knees16 2 = 224 ∧ quotaBudget knees8 2 = 112 := by
  constructor
  · rw [quotaBudget_three_median]; decide
  · rw [quotaBudget_three_median]; decide

/-- The certified (quota-3) budgets are the product points themselves. -/
theorem certified_is_product_point :
    quotaBudget knees16 3 = productPoint 4 2048 ∧ quotaBudget knees8 3 = productPoint 4 1024 := by
  constructor
  · rw [quotaBudget_three_all, productPoint_16x]; decide
  · rw [quotaBudget_three_all, productPoint_8x]; decide

/-- **`7/8` is the unique ratio fitting both medians.**  A one-parameter law
`median = α·(d·ctx/32)` is identifiable from the two contexts, and `α = 7/8`. -/
theorem median_law_ratio_unique (α : ℚ) :
    (α * 128 = 112 ∧ α * 256 = 224) ↔ α = 7 / 8 := by
  constructor
  · rintro ⟨h1, -⟩; linarith
  · rintro rfl; norm_num

/-- **The low tail obeys no ratio law.**  `96/128 = 3/4` but `160/256 = 5/8`: no single `α`
fits both minima, so the minimum is genuinely context-dependent. -/
theorem min_has_no_ratio_law : ¬ ∃ α : ℚ, α * 128 = 96 ∧ α * 256 = 160 := by
  rintro ⟨α, h1, h2⟩
  have : α = 3 / 4 := by linarith
  rw [this] at h2
  norm_num at h2

/-- The upper edge obeys the ratio law with `α = 1` (the product law as an upper bound). -/
theorem max_ratio_law (α : ℚ) : (α * 128 = 128 ∧ α * 256 = 256) ↔ α = 1 := by
  constructor
  · rintro ⟨h1, -⟩; linarith
  · rintro rfl; norm_num

/-- **Dichotomy on the quota ladder.**  Across the two contexts, quotas `2` and `3` admit
context-free ratios (`7/8` and `1`) and quota `1` does not.  The robust, extrapolable
content of a three-seed sweep lives at the top two rungs of the ladder. -/
theorem quota_ratio_dichotomy :
    (∃! α : ℚ, α * 128 = 112 ∧ α * 256 = 224) ∧
      (∃! α : ℚ, α * 128 = 128 ∧ α * 256 = 256) ∧
      ¬ ∃ α : ℚ, α * 128 = 96 ∧ α * 256 = 160 := by
  refine ⟨⟨7 / 8, (median_law_ratio_unique _).2 rfl, fun α h => (median_law_ratio_unique α).1 h⟩,
    ⟨1, (max_ratio_law _).2 rfl, fun α h => (max_ratio_law α).1 h⟩, min_has_no_ratio_law⟩

/-- **The spread widens with context.**  Measured as a fraction of the product point, the
knee spread grows from `1/4` at `ctx = 1024` to `3/8` at `ctx = 2048`. -/
theorem spread_widens :
    ((128 : ℚ) - 96) / 128 = 1 / 4 ∧ ((256 : ℚ) - 160) / 256 = 3 / 8 ∧ (1 : ℚ) / 4 < 3 / 8 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- **Rigidity of the widening.**  With the upper edge pinned at the product point and the
median at `7/8`, the ratio spread is at least `1/8`, with equality exactly when the low tail
is `7/8` too.  So all widening beyond `1/8` is low-tail motion. -/
theorem spread_ge_one_eighth (lo : ℚ) (hlo : lo ≤ 7 / 8) :
    1 / 8 ≤ 1 - lo ∧ (1 - lo = 1 / 8 ↔ lo = 7 / 8) := by
  refine ⟨by linarith, ⟨fun h => by linarith, fun h => by rw [h]; norm_num⟩⟩

/-! ## 5.  Deployment: what the median does and does not guarantee -/

/-- **The median budget is not a guarantee.**  Any seed whose knee lies above the median
fails the bar at the median. -/
theorem median_budget_unsafe {G : Finset ℕ} {barv : ℝ} {c : ℕ → ℝ} {k m : ℕ}
    (h : IsKnee G barv c k) (hm : m ∈ G) (hlt : m < k) : c m < barv :=
  h.fails_below hm hlt

/-- Instance: at the median budget `224` the seed-1 curve (knee `256`) misses the bar. -/
theorem net48_median_budget_fails_seed1 {c : ℕ → ℝ} (h : IsKnee grid16 bar c 256) :
    c 224 < bar :=
  median_budget_unsafe h (by decide) (by norm_num)

/-- **Non-vacuity of the seed-1 record.**  A monotone curve with knee exactly `256` on the
`16×` grid exists, so the previous theorem is not empty. -/
theorem knee256_nonvacuous :
    ∃ c : ℕ → ℝ, Monotone c ∧ IsKnee grid16 bar c 256 := by
  refine ⟨fun k => 0.9 + stepUp 240 0.1 k, monotone_const.add (stepUp_mono 240 (by norm_num)),
    by decide, ?_, ?_⟩
  · norm_num [stepUp, bar]
  · intro j hj hpass
    fin_cases hj <;> simp_all [stepUp, bar] <;> norm_num at hpass

/-- **The measurement determines the law.**  Given the three recorded `16×` seeds — knees
`256` and `224` at seeds 1 and 2 and the seed-3 sweep — the majority (median) budget of the
ensemble is `224` and the certified budget is the product point `256`, whatever the curves
are.  Knee uniqueness does all the work. -/
theorem net48_three_seed_ladder {c : Fin 3 → ℕ → ℝ} {K : Fin 3 → ℕ}
    (hk : ∀ i, IsKnee grid16 bar (c i) (K i)) (h1 : IsKnee grid16 bar (c 0) 256)
    (h2 : IsKnee grid16 bar (c 1) 224) (h3 : Seed3Data (c 2)) :
    quotaBudget K 2 = 224 ∧ quotaBudget K 3 = productPoint 4 2048 := by
  have e0 : K 0 = 256 := (hk 0).unique h1
  have e1 : K 1 = 224 := (hk 1).unique h2
  have e2 : K 2 = 160 := (hk 2).unique (net48_seed3_knee h3)
  rw [quotaBudget_three_median, quotaBudget_three_all, productPoint_16x, e0, e1, e2]
  exact ⟨by decide, by decide⟩

/-- **Majority safety at the median budget.**  Two of the three seeds do clear the bar at
`224`; by `net48_median_budget_fails_seed1` the third does not.  The median budget is a
majority guarantee and nothing more. -/
theorem net48_median_budget_majority_safe {c₂ c₃ : ℕ → ℝ} (h2 : IsKnee grid16 bar c₂ 224)
    (h3 : Seed3Data c₃) : bar ≤ c₂ 224 ∧ bar ≤ c₃ 224 :=
  ⟨h2.2.1, (net48_horns_all_pass h3).2.1⟩

/-- **The guaranteed speedup is context-free.**  Deploying the product budget gives `32/d`
at every context — `8×` at `d = 4`. -/
theorem product_speedup_context_free (d ctx : ℝ) (hd : 0 < d) (hctx : 0 < ctx) :
    speedup ctx (d * ctx / 32) = 32 / d := by
  rw [speedup]
  field_simp

/-- **The median speedup is context-free too**, and strictly better: `256/(7d)`, i.e.
`64/7 ≈ 9.14×` at `d = 4`, at both measured contexts. -/
theorem median_speedup_context_free (d ctx : ℝ) (hd : 0 < d) (hctx : 0 < ctx) :
    speedup ctx (7 / 8 * (d * ctx / 32)) = 256 / (7 * d) := by
  rw [speedup]
  field_simp
  ring

/-- The two measured median speedups agree, as the context-free law predicts. -/
theorem measured_median_speedups :
    speedup 1024 112 = 64 / 7 ∧ speedup 2048 224 = 64 / 7 := by
  constructor <;> norm_num [speedup]

/-- **The best case is *not* context-free**: it grows from `32/3 ≈ 10.67×` to `12.8×`.
Only the low tail carries the context dependence, matching `min_has_no_ratio_law`. -/
theorem best_case_speedup_grows :
    speedup 1024 96 = 32 / 3 ∧ speedup 2048 160 = 12.8 ∧ (32 : ℝ) / 3 < 12.8 := by
  refine ⟨by norm_num [speedup], by norm_num [speedup], by norm_num⟩

/-- The `16×` deployment reading: guarantee `8×`, median `64/7`, best `12.8×`, ordered. -/
theorem net48_deployment_window :
    speedup 2048 256 = 8 ∧ speedup 2048 224 = 64 / 7 ∧ speedup 2048 160 = 12.8 ∧
      (8 : ℝ) < 64 / 7 ∧ (64 : ℝ) / 7 < 12.8 := by
  refine ⟨by norm_num [speedup], by norm_num [speedup], by norm_num [speedup], by norm_num,
    by norm_num⟩

/-! ## 6.  Point predictions versus centre predictions -/

/-- The four pre-registered point predictions for the third seed. -/
def horns : Finset ℕ := {192, 224, 240, 256}

/-- **The family of third-seed values that preserve the median.**  Against the recorded
seeds `224` and `256`, the median stays at `224` exactly for `x ≤ 224`; in particular the
measured `160`, and also `192` and `224`, all confirm the law, while `240` and `256` would
not. -/
theorem net48_median_stability_family :
    (∀ x, med3 x 224 256 = 224 ↔ x ≤ 224) ∧
      med3 160 224 256 = 224 ∧ med3 192 224 256 = 224 ∧ med3 224 224 256 = 224 ∧
      med3 240 224 256 ≠ 224 := by
  refine ⟨fun x => med3_stable_iff (by norm_num) x, by decide, by decide, by decide, by decide⟩

/-- **Point-accuracy and centre-accuracy are logically independent.**  Against the recorded
pair `{224, 256}` and the four pre-registered horns, all four combinations of "the new seed
hits a horn" and "the completed sample has the predicted median" are realised by admissible
third-seed values.  NET-48 realises the first: `0/4` on the horns, `1/1` on the law. -/
theorem point_center_independent :
    (∃ x, x ∉ horns ∧ med3 x 224 256 = 224) ∧
      (∃ x, x ∈ horns ∧ med3 x 224 256 = 224) ∧
      (∃ x, x ∈ horns ∧ med3 x 224 256 ≠ 224) ∧
      (∃ x, x ∉ horns ∧ med3 x 224 256 ≠ 224) :=
  ⟨⟨160, by decide, by decide⟩, ⟨224, by decide, by decide⟩,
    ⟨240, by decide, by decide⟩, ⟨288, by decide, by decide⟩⟩

/-- **Why the centre survived where the points failed.**  Refuting a point prediction only
needs the third seed to differ from it; refuting the median needs the third seed to exceed
the *second* recorded knee.  The centre is protected by a whole interval of outcomes — the
quantitative form of `med3_breakdown`. -/
theorem center_harder_to_refute (x : ℕ) (hx : x ∉ horns) (hle : x ≤ 224) :
    (∀ p ∈ horns, x ≠ p) ∧ med3 x 224 256 = 224 := by
  refine ⟨fun p hp hxp => hx (hxp ▸ hp), (med3_stable_iff (by norm_num) x).2 hle⟩

end KneeMedian