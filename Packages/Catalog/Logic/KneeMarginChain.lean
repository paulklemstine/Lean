/-
# The margin chain of a five-doubling knee ladder: an exact robustness radius, the
# certification depth of a chain, and what a razor-thin margin costs (NET-45)

Round NET-45 closes the seed-1 cell at the longest context of the programme,
`(d = 4, ctx = 2048)`.  The measured object is the same threshold functional as in
`Logic.KneeFluctuationTwoSeed`: the knee `k*` is the least budget on the sweep grid at
which retained accuracy reaches `0.98` of the full model's held-out accuracy.

**Lab notes (round NET-45, speed axis).**
Harness byte-identical to NET-37/NET-44: `CausalTF`, `d_model = 64`, 4 heads, Gutenberg
corpus, vocab 4097, 2000 AdamW steps, `d = 4`, `ctx = 2048`, seed 1, chunked evaluation
(`CHUNK = 8`), held-out last `10 %`, data-free top-`k`.  Full accuracy `0.1543`, bar
`0.1512`, full loss `5.2047`, train `18436 s`.  Binomial standard error `≈ 0.11 %`
accuracy.

| `k`  | 96 | 128 | 160 | 192 | 224 | **256** | 288 | 384 | 512 | 768 | 1024 |
|------|----|-----|-----|-----|-----|---------|-----|-----|-----|-----|------|
| ret. |.939|.951 |.963 |.970 |.976 |**.9813**|.984 |.993 |.997 |.996 |.998  |
| pass | ✗  | ✗   | ✗   | ✗   | ✗   | **✓**   | ✓   | ✓   | ✓   | ✓   | ✓    |

so `k*(s1) = 256 = d·ctx/32` exactly, the fifth consecutive rung of the chain
`16/32/64/128/256` across `ctx = 128 … 2048`.  The margin at the knee is
`0.9813 - 0.98 = 0.0013`, the smallest of the whole chain (`0.007 / 0.010 / 0.003 /
0.006` at the four earlier rungs), and the deficit at the preceding grid point `224` is
`0.004`.

**Two features of this sweep that the earlier rounds did not have, and that this file
makes precise.**

1.  *The measured curve is not monotone*: `c 512 = 0.997 > 0.996 = c 768`
    (`KneeMarginChain.net45_curve_not_monotone`).  The catalog's knee machinery survives
    this — `KneeFluctuation.IsKnee` never uses monotonicity, and
    `KneeMarginChain.net45_knee` is proved from the raw numbers — but the *robustness*
    theory does, so the perturbations below are constructed explicitly rather than
    obtained from `KneeFluctuation.margins_of_robustKnee`.

2.  *The margin is razor thin*, and this file computes its exact price:
    `KneeMarginChain.net45_robustness_radius` shows the knee claim `k* = 256` is
    `η`-robust **iff** `η ≤ 0.0013`.  Both directions are proved; the failure direction
    is by an explicit monotone curve within `η` of the measurement whose knee is not
    `256`.  At `η = 0.006`, the inter-seed spread later measured at this very cell,
    an admissible monotone curve reads `224` (`net45_spread_perturbation_reads_224`) —
    the one-grid-step drop is inside the round's own noise before any second seed is run.

**Certification depth.**  A chain of exact rungs is only as strong as its weakest
margin.  `KneeMarginChain.CertDepth m η n` says the first `n` rungs of a margin ladder
survive noise `η` and the `n`-th does not; it is unique (`CertDepth.unique`), antitone in
the noise (`certDepth_antitone`), and for the NET-45 ladder it collapses fast:
depth `5` at `η = 0.0013`, `4` at `0.002`, `2` at `0.004` and at `0.006`, and `0` at
`0.010` (`net45_depth_*`).  **At the inter-seed spread of the neighbouring rung the
five-doubling chain certifies two doublings, not five.**

**Deployment and significance.**  `speedup_const_iff_productLaw` : the product law
`k = d·ctx/32` holds *iff* the deployable speedup is the context-independent constant
`32/d`; the exactness claim and the "guarantee equal to the knee" observation are the
same statement.  `net45_reported_speedup_at_224_is_inconsistent` records an arithmetic
error in the round's own report: at `k = 224` the speedup is `2048/224 = 64/7 ≈ 9.14`,
not the reported `10.3`.  Finally `chain_null_probability` counts the null model: under
an unbiased per-rung coin, one ladder in `2^n` is exact at every rung, so the five-rung
chain has null probability `1/32 < 0.05` — unlike the two-cell replication of NET-46
(`1/4`), a five-rung chain *is* significant at the conventional level.
-/

import Mathlib
import Logic.KneeFluctuationTwoSeed

namespace KneeMarginChain

open Finset KneeFluctuation

/-! ## 1.  The NET-45 measurement at `(d = 4, ctx = 2048)`, seed 1 -/

/-- The NET-45 sweep grid at `ctx = 2048`. -/
def grid2048 : Finset ℕ := {96, 128, 160, 192, 224, 256, 288, 384, 512, 768, 1024}

/-- The measured seed-1 retained-accuracy curve at `(d = 4, ctx = 2048)`.  **No
monotonicity is assumed**: the measurement itself is not monotone. -/
structure Sweep2048S1 (c : ℕ → ℝ) : Prop where
  at96 : c 96 = 0.939
  at128 : c 128 = 0.951
  at160 : c 160 = 0.963
  at192 : c 192 = 0.970
  at224 : c 224 = 0.976
  at256 : c 256 = 0.9813
  at288 : c 288 = 0.984
  at384 : c 384 = 0.993
  at512 : c 512 = 0.997
  at768 : c 768 = 0.996
  at1024 : c 1024 = 0.998

/-- The measured curve, as an explicit function: the record is realisable, so every
theorem below has content. -/
noncomputable def measured : ℕ → ℝ := fun k =>
  if k ≤ 96 then 0.939 else if k ≤ 128 then 0.951 else if k ≤ 160 then 0.963 else
  if k ≤ 192 then 0.970 else if k ≤ 224 then 0.976 else if k ≤ 256 then 0.9813 else
  if k ≤ 288 then 0.984 else if k ≤ 384 then 0.993 else if k ≤ 512 then 0.997 else
  if k ≤ 768 then 0.996 else 0.998

theorem sweep2048S1_nonvacuous : Sweep2048S1 measured := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [measured]

/-- **The knee is `256`**, exactly the product law `d·ctx/32 = 4·2048/32`.  Note that the
proof uses only the measured values: `KneeFluctuation.IsKnee` needs no monotonicity. -/
theorem net45_knee {c : ℕ → ℝ} (h : Sweep2048S1 c) : IsKnee grid2048 bar c 256 := by
  obtain ⟨h96, h128, h160, h192, h224, h256, h288, h384, h512, h768, h1024⟩ := h
  refine ⟨by decide, by rw [h256]; norm_num [bar], ?_⟩
  intro j hj hpass
  fin_cases hj <;> simp_all [bar] <;> linarith

/-- **The measured curve is not monotone**: retained accuracy *drops* from `0.997` at
`k = 512` to `0.996` at `k = 768`.  Every robustness statement below is therefore proved
by explicit construction rather than by the monotone criterion
`KneeFluctuation.margins_of_robustKnee`. -/
theorem net45_curve_not_monotone {c : ℕ → ℝ} (h : Sweep2048S1 c) : ¬ Monotone c := by
  intro hmono
  have := hmono (show (512 : ℕ) ≤ 768 by norm_num)
  rw [h.at512, h.at768] at this
  norm_num at this

/-- The margin at the knee: `0.0013`, the tightest of the five-doubling chain. -/
theorem net45_margin_at_knee {c : ℕ → ℝ} (h : Sweep2048S1 c) : c 256 - bar = 0.0013 := by
  rw [h.at256]; norm_num [bar]

/-- The deficit at the preceding grid point `224`: `0.004`. -/
theorem net45_deficit_at_224 {c : ℕ → ℝ} (h : Sweep2048S1 c) : bar - c 224 = 0.004 := by
  rw [h.at224]; norm_num [bar]

/-- The five recorded margins of the seed-1 chain, and the fact that the `16×` rung is
strictly the tightest. -/
theorem net45_margin_is_tightest :
    (0.0013 : ℝ) < 0.003 ∧ (0.0013 : ℝ) < 0.006 ∧ (0.0013 : ℝ) < 0.007 ∧
      (0.0013 : ℝ) < 0.010 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-! ## 2.  Monotone envelopes of the measurement -/

/-- A single upward step: the building block of the monotone curves used below. -/
noncomputable def step (t : ℕ) (v : ℝ) : ℕ → ℝ := fun x => if t ≤ x then v else 0

theorem step_mono (t : ℕ) {v : ℝ} (hv : 0 ≤ v) : Monotone (step t v) := by
  intro a b hab
  simp only [step]
  split_ifs with h1 h2 h2
  · exact le_rfl
  · exact absurd (h1.trans hab) h2
  · exact hv
  · exact le_rfl

/-- The **upper** monotone envelope of the measurement: equal to the measured values
everywhere on the grid except at `k = 768`, where the non-monotone dip `0.996` is raised
to `0.997`. -/
noncomputable def envUp : ℕ → ℝ := fun x =>
  0.939 + step 128 0.012 x + step 160 0.012 x + step 192 0.007 x + step 224 0.006 x
    + step 256 0.0053 x + step 288 0.0027 x + step 384 0.009 x + step 512 0.004 x
    + step 1024 0.001 x

/-- The **lower** monotone envelope: equal to the measured values everywhere on the grid
except at `k = 512`, where `0.997` is lowered to `0.996`. -/
noncomputable def envDown : ℕ → ℝ := fun x =>
  0.939 + step 128 0.012 x + step 160 0.012 x + step 192 0.007 x + step 224 0.006 x
    + step 256 0.0053 x + step 288 0.0027 x + step 384 0.009 x + step 512 0.003 x
    + step 1024 0.002 x

theorem envUp_mono : Monotone envUp :=
  ((((((((monotone_const.add (step_mono 128 (by norm_num))).add
    (step_mono 160 (by norm_num))).add (step_mono 192 (by norm_num))).add
    (step_mono 224 (by norm_num))).add (step_mono 256 (by norm_num))).add
    (step_mono 288 (by norm_num))).add (step_mono 384 (by norm_num))).add
    (step_mono 512 (by norm_num))).add (step_mono 1024 (by norm_num))

theorem envDown_mono : Monotone envDown :=
  ((((((((monotone_const.add (step_mono 128 (by norm_num))).add
    (step_mono 160 (by norm_num))).add (step_mono 192 (by norm_num))).add
    (step_mono 224 (by norm_num))).add (step_mono 256 (by norm_num))).add
    (step_mono 288 (by norm_num))).add (step_mono 384 (by norm_num))).add
    (step_mono 512 (by norm_num))).add (step_mono 1024 (by norm_num))

/-- The upper envelope agrees with the measurement on the grid except at `768`, where it
is `0.001` higher. -/
theorem envUp_close {c : ℕ → ℝ} (h : Sweep2048S1 c) :
    ∀ j ∈ grid2048, 0 ≤ envUp j - c j ∧ envUp j - c j ≤ 0.001 := by
  obtain ⟨h96, h128, h160, h192, h224, h256, h288, h384, h512, h768, h1024⟩ := h
  intro j hj
  fin_cases hj <;> constructor <;> simp_all [envUp, step] <;> norm_num

/-- The lower envelope agrees with the measurement on the grid except at `512`, where it
is `0.001` lower. -/
theorem envDown_close {c : ℕ → ℝ} (h : Sweep2048S1 c) :
    ∀ j ∈ grid2048, 0 ≤ c j - envDown j ∧ c j - envDown j ≤ 0.001 := by
  obtain ⟨h96, h128, h160, h192, h224, h256, h288, h384, h512, h768, h1024⟩ := h
  intro j hj
  fin_cases hj <;> constructor <;> simp_all [envDown, step] <;> norm_num

/-! ## 3.  The exact robustness radius of the `16×` knee -/

/-- **Sufficiency.**  Every perturbation of size at most the margin `0.0013` leaves the
knee at `256`: the deficits below the knee (`0.041, 0.029, 0.017, 0.010, 0.004`) all
exceed it. -/
theorem net45_robust_at_margin {c : ℕ → ℝ} (h : Sweep2048S1 c) {η : ℝ}
    (hle : η ≤ 0.0013) : RobustKnee grid2048 bar c 256 η := by
  obtain ⟨h96, h128, h160, h192, h224, h256, h288, h384, h512, h768, h1024⟩ := h
  refine robustKnee_of_margins (by decide) (by rw [h256]; norm_num [bar]; linarith) ?_
  intro j hj hlt
  fin_cases hj <;> simp_all [bar] <;> linarith

/-- **Necessity.**  For any noise strictly above the margin there is a *monotone* curve
within `η` of the measurement on the grid whose retained accuracy at `256` is below the
bar; the knee claim therefore fails.  Together with the previous theorem this pins the
robustness radius of the `16×` cell at exactly `0.0013`. -/
theorem net45_not_robust_above_margin {c : ℕ → ℝ} (h : Sweep2048S1 c) {η : ℝ}
    (hη : 0.0013 < η) : ¬ RobustKnee grid2048 bar c 256 η := by
  intro hrob
  have hclose : ∀ j ∈ grid2048, |(envUp j - η) - c j| ≤ η := by
    intro j hj
    obtain ⟨hlo, hhi⟩ := envUp_close h j hj
    rw [abs_le]
    constructor <;> linarith
  have hknee := hrob (fun x => envUp x - η)
    (fun a b hab => by simpa using sub_le_sub_right (envUp_mono hab) η) hclose
  have hval : envUp 256 = 0.9813 := by norm_num [envUp, step]
  have := hknee.2.1
  simp only at this
  rw [hval] at this
  norm_num [bar] at this
  linarith

/-- **The robustness radius of the `16×` knee is exactly the margin.**  A sharp
characterisation: `k* = 256` survives every `η`-perturbation iff `η ≤ 0.0013`. -/
theorem net45_robustness_radius {c : ℕ → ℝ} (h : Sweep2048S1 c) {η : ℝ} :
    RobustKnee grid2048 bar c 256 η ↔ η ≤ 0.0013 := by
  refine ⟨fun hrob => ?_, net45_robust_at_margin h⟩
  by_contra hcon
  exact net45_not_robust_above_margin h (not_le.mp hcon) hrob

/-- **The one-grid-step drop is inside the round's own noise.**  At `η = 0.006`, the
inter-seed spread later measured at this very cell, there is a monotone curve within `η`
of the seed-1 measurement whose knee is `224` — the seed-2 reading of NET-46 is predicted
by the seed-1 sweep alone, before any second seed is run. -/
theorem net45_spread_perturbation_reads_224 {c : ℕ → ℝ} (h : Sweep2048S1 c) :
    ∃ c' : ℕ → ℝ, Monotone c' ∧ (∀ j ∈ grid2048, |c' j - c j| ≤ 0.006) ∧
      IsKnee grid2048 bar c' 224 := by
  refine ⟨fun x => envDown x + 0.006,
    fun a b hab => by simpa using add_le_add_right (envDown_mono hab) 0.006, ?_, ?_⟩
  · intro j hj
    obtain ⟨hlo, hhi⟩ := envDown_close h j hj
    rw [abs_le]
    constructor <;> linarith
  · refine ⟨by decide, by show bar ≤ envDown 224 + 0.006; norm_num [envDown, step, bar], ?_⟩
    intro j hj hpass
    fin_cases hj <;> simp_all [envDown, step, bar] <;> try norm_num at hpass

/-! ## 4.  Certification depth of a margin chain -/

/-- The margin ladder of the seed-1 chain: rungs `0 … 4` are `ctx = 128 … 2048`, and
unmeasured rungs carry margin `0` (nothing is certified there). -/
noncomputable def marginS1 : ℕ → ℝ := fun i =>
  if i = 0 then 0.007 else if i = 1 then 0.010 else if i = 2 then 0.003 else
  if i = 3 then 0.006 else if i = 4 then 0.0013 else 0

/-- `CertDepth m η n` : exactly the first `n` rungs of the margin ladder `m` survive
noise `η`.  This is the knee functional again, applied to the ladder instead of the
sweep: the least rung whose margin is below the noise. -/
def CertDepth (m : ℕ → ℝ) (η : ℝ) (n : ℕ) : Prop :=
  (∀ i < n, η ≤ m i) ∧ ¬ (η ≤ m n)

/-- The certification depth is unique. -/
theorem CertDepth.unique {m : ℕ → ℝ} {η : ℝ} {n n' : ℕ}
    (h : CertDepth m η n) (h' : CertDepth m η n') : n = n' := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · exact h.2 (h'.1 n hlt)
  · exact h'.2 (h.1 n' hlt)

/-- **More noise certifies fewer doublings.**  The certification depth is antitone in the
noise level: evidence of larger spread can only shorten the certified chain. -/
theorem certDepth_antitone {m : ℕ → ℝ} {η η' : ℝ} {n n' : ℕ} (hle : η ≤ η')
    (h : CertDepth m η n) (h' : CertDepth m η' n') : n' ≤ n := by
  by_contra hcon
  push_neg at hcon
  exact h.2 (le_trans hle (h'.1 n hcon))

/-- **A chain is only as long as its weakest margin.**  If some rung `i < n` has margin
below `η`, the chain is not certified to depth `n`. -/
theorem certDepth_lt_of_margin_lt {m : ℕ → ℝ} {η : ℝ} {n i d : ℕ} (hi : i < n)
    (hmargin : m i < η) (h : CertDepth m η d) : d < n := by
  by_contra hcon
  push_neg at hcon
  exact absurd (h.1 i (lt_of_lt_of_le hi hcon)) (not_le.mpr hmargin)

/-- At the round's own margin the whole five-doubling chain is certified. -/
theorem net45_depth_at_margin : CertDepth marginS1 0.0013 5 := by
  refine ⟨?_, by norm_num [marginS1]⟩
  intro i hi
  interval_cases i <;> norm_num [marginS1]

/-- One thousandth of extra noise already costs the `16×` rung. -/
theorem net45_depth_at_two_thousandths : CertDepth marginS1 0.002 4 := by
  refine ⟨?_, by norm_num [marginS1]⟩
  intro i hi
  interval_cases i <;> norm_num [marginS1]

/-- At the deficit scale of the deciding grid point the chain certifies two doublings. -/
theorem net45_depth_at_four_thousandths : CertDepth marginS1 0.004 2 := by
  refine ⟨?_, by norm_num [marginS1]⟩
  intro i hi
  interval_cases i <;> norm_num [marginS1]

/-- **At the inter-seed spread measured at this cell, the five-doubling chain certifies
two doublings.** -/
theorem net45_depth_at_spread : CertDepth marginS1 0.006 2 := by
  refine ⟨?_, by norm_num [marginS1]⟩
  intro i hi
  interval_cases i <;> norm_num [marginS1]

/-- At the NET-44 spread `0.010` nothing at all is certified. -/
theorem net45_depth_at_net44_spread : CertDepth marginS1 0.010 0 := by
  refine ⟨by omega, by norm_num [marginS1]⟩

/-- **The collapse, in one statement.**  The chain that is exact at five doublings is
certified at five only at its own margin; at the spread already measured between seeds it
is certified at two, and the depth is antitone in between. -/
theorem net45_chain_collapse :
    CertDepth marginS1 0.0013 5 ∧ CertDepth marginS1 0.006 2 ∧
      ∀ n n' : ℕ, CertDepth marginS1 0.0013 n → CertDepth marginS1 0.006 n' → n' ≤ n :=
  ⟨net45_depth_at_margin, net45_depth_at_spread,
    fun _ _ h h' => certDepth_antitone (by norm_num) h h'⟩

/-! ## 5.  The product law is exactly context-independence of the speedup -/

/-- **The product law and the constant-speedup law are the same statement.**  For a
positive depth, context and budget, `k = d·ctx/32` holds *iff* the deployable speedup
`ctx/k` equals the context-independent constant `32/d`. -/
theorem speedup_const_iff_productLaw {d ctx k : ℝ} (hd : 0 < d) (hctx : 0 < ctx)
    (hk : 0 < k) : k = d * ctx / 32 ↔ speedup ctx k = 32 / d := by
  rw [speedup]
  constructor
  · intro hkey
    rw [hkey]
    field_simp
  · intro hkey
    field_simp at hkey ⊢
    linarith

/-- The NET-45 deployment reading: `8×` at the knee, the product-law guarantee. -/
theorem net45_speedup : speedup 2048 256 = 8 := by norm_num [speedup]

/-- **Critic: the round's alternative reading is mis-quoted.**  If the second seed reads
`224`, the speedup is `2048/224 = 64/7 ≈ 9.14`, not the reported `10.3`; the discrepancy
exceeds one whole multiple. -/
theorem net45_reported_speedup_at_224_is_inconsistent :
    speedup 2048 224 = 64 / 7 ∧ (64 : ℝ) / 7 < 10.3 ∧ (1 : ℝ) < 10.3 - 64 / 7 := by
  refine ⟨by norm_num [speedup], by norm_num, by norm_num⟩

/-! ## 6.  How surprising is a five-rung exact chain? -/

/-- Under the one-grid-step null model — each rung independently reads either the
predicted budget or one grid step below it — exactly one ladder out of `2^n` is exact at
every rung. -/
theorem allExact_card (n : ℕ) :
    ((univ : Finset (Fin n → Bool)).filter (fun f => ∀ i, f i = true)).card = 1 := by
  classical
  refine Finset.card_eq_one.2 ⟨fun _ => true, ?_⟩
  ext f
  simp only [mem_filter, mem_univ, true_and, mem_singleton]
  constructor
  · intro hf; funext i; exact hf i
  · intro hf i; rw [hf]

/-- The null probability of an exact `n`-rung chain is `2^{-n}`. -/
theorem chain_null_probability (n : ℕ) :
    (((univ : Finset (Fin n → Bool)).filter (fun f => ∀ i, f i = true)).card : ℝ)
      / (Fintype.card (Fin n → Bool) : ℝ) = (1 / 2) ^ n := by
  rw [allExact_card]
  simp

/-- **The five-rung chain is significant, the two-cell replication is not.**  At `n = 5`
the null probability is `1/32 < 0.05`; at `n = 2` — the NET-46 replication — it is
`1/4 > 0.05`. -/
theorem chain_significance :
    ((1 : ℝ) / 2) ^ 5 = 1 / 32 ∧ ((1 : ℝ) / 2) ^ 5 < 0.05 ∧ 0.05 < ((1 : ℝ) / 2) ^ 2 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

end KneeMarginChain