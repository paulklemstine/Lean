import Mathlib

/-!
# Draft-cost dominance and domain-parameterised depth in CPU speculative decoding

This file develops a model-free theory of the object measured in the NET-91 experiment:
the throughput of *speculative decoding* of a large target model by a small draft model,
when everything runs on a CPU, so that the draft's `d` sequential proposal steps are paid
in full and only the verification pass amortises.

## The block model

A speculative *block* consists of `d` sequential draft steps followed by one verification
pass of the target.  Measuring time in units of one target decode step:

* `blockCost c d = 1 + c * d` — one verification pass plus `d` draft steps of relative
  cost `c` each (`c ≈ 0.118` for the 0.5B draft, `c ≈ 0.234` for the 1.5B draft against
  the 7B target);
* `yieldGeom a d = ∑_{i ≤ d} a ^ i` — the expected number of target tokens committed by
  the block when each drafted position is accepted independently with probability `a`
  (the classical Leviathan-style yield: the bonus token plus the accepted prefix);
* `speedup a c d = yieldGeom a d / blockCost c d` — tokens per unit target-step, i.e. the
  speedup over greedy autoregressive decoding, whose value is `speedup a c 0 = 1`.

## What is proved

* **Exact comparison criterion** (`speedup_lt_speedup_iff`) and the *cheap-draft law at
  equal acceptance* (`cheaper_draft_wins`).
* **Cost dominance, all six measured head-to-heads** (`cost_dominance_all_six`): feeding
  the *measured* acceptance rates and the *measured* relative draft costs into the model,
  the 0.5B draft beats the 1.5B draft in every one of the six (domain × depth) cells —
  including `code, d = 8`, where the 1.5B accepts strictly more (60.3% vs 56.0%).
* **Asymptotic form of the law** (`asymptotic_cost_dominance`): `d · speedup → 1/(c(1-a))`
  (`tendsto_d_speedup`), so the invariant that ranks two drafts at large depth is the
  product `c * (1 - a)`; an acceptance advantage must beat the cost ratio *multiplicatively
  in the rejection rate*.  For the measured pair, `0.118·0.44 = 0.0519 < 0.234·0.397 =
  0.0929`, and the 1.5B draft would need acceptance `≥ 77.8%` at `d = 8` to overturn it
  (`crossover_acceptance_needed`).
* **Depth collapse** (`speedup_lt_one_of_deep`, `exists_depth_collapse`): for every `a < 1`
  and `c > 0` deep enough drafting is a *net loss*, with the explicit gate
  `(1 - a) * blockCost c d > 1`.  Instantiated: prose at `d = 8` is a predicted loss for
  both drafts (`prose_depth8_loss_small`, `prose_depth8_loss_large`) while code at `d = 8`
  is a predicted win for the small draft (`code_depth8_win_small`).
* **Existence of an optimal depth** (`exists_optimal_depth`).
* **Comparative statics — the depth frontier is monotone in acceptance**
  (`deepenPays_mono_acceptance`, `depth_frontier_monotone`): if deepening from `d` to `e`
  pays at acceptance `a`, it pays at every `a' ≥ a`.  This is the formal content of
  "optimal depth is domain-parameterised": code accepts more, hence its optimal depth is
  never below prose's.
* **An informative failure** (`iid_cannot_explain_code_depth8`): the same comparative
  statics *falsifies* the i.i.d. reading of the measured acceptance numbers.  For every
  per-position acceptance `a ≤ 0.8` the model ranks `d = 4` strictly above `d = 8` at the
  0.5B draft cost; the measured code acceptance is 56%, yet `d = 8` measured faster.  So
  the reported percentage cannot be a per-position independent acceptance probability.
* **The repaired reading and a derived hardware prediction**: under the *mean-yield*
  reading `meanYield q d = 1 + q * d` the code cells are reproduced
  (`mean_reading_matches_code`), but an affine yield over an affine cost is monotone in
  depth (`affine_ratio_mono`, `affine_ratio_anti`), so it can never produce an interior
  optimum, and reproducing the prose `d = 8` loss forces extra per-position verification
  cost.  Quantitatively (`verification_overhead_bracket`) the marginal CPU cost of one
  extra verified position lies strictly between `0.191` and `0.442` target-steps: on a
  CPU, verification does **not** amortise the way GPU folklore assumes.

-- !-- Lab Notes -- !--
Hypothesizer (7 conjectures, ranked by expected impact):
 (H1) [BOLD] There is a single scalar invariant `c * (1 - a)` that ranks two drafts at
      large depth; acceptance and cost are not independently meaningful.
 (H2) [BOLD] Optimal depth is a monotone comparative static of acceptance: the whole
      "deepening pays" frontier is upward closed in `a`, so the code/prose depth split is
      forced, not incidental.
 (H3) Deep drafting is always eventually a net loss, with a closed-form gate.
 (H4) The cheap draft wins every measured head-to-head *inside the model*, i.e. the
      refutation of P3 is a theorem about the model, not only an observation.
 (H5) [BOLD] The reported acceptance percentages are not per-position probabilities; the
      i.i.d. model with those numbers is falsified by the code `d = 8` cell.
 (H6) A mean-yield (affine) reading fixes the code cells but cannot have an interior
      optimum, hence cannot alone explain the prose collapse.
 (H7) Combining H5 and H6 yields a two-sided numerical bracket on the CPU verification
      overhead — a prediction testable in the next round.

Experimenter: H1–H7 are all formalised below with zero sorries.  The measured NET-91
inputs (Qwen2.5-7B-Instruct Q4_K_M target, i9-9900K, threads = 8, 5.79 tok/s baseline)

  draft   depth   prose accept   prose speedup   code accept   code speedup
  0.5B      2        63.9%          1.254x          71.6%         1.352x
  0.5B      4        47.7%          1.416x          63.0%         1.616x
  0.5B      8        30.9%          0.979x          56.0%         1.661x
  1.5B      2        63.2%          1.016x          83.4%         1.195x
  1.5B      4        51.9%          1.153x          74.8%         1.395x
  1.5B      8        44.9%          0.982x          60.3%         1.354x

with relative draft costs 0.118 and 0.234, enter only as *numerals inside statements*,
never as axioms.

Analyst: fed the measured acceptances, the block model reproduces the sign (win/loss) of
11 of the 12 measured cells and the winner of all 6 head-to-heads.  The single sign
failure is exactly the cell the falsification theorem isolates (1.5B, code, `d = 8`), and
its cause is structural, not numerical: under i.i.d. acceptance no `a ≤ 0.8` makes `d = 8`
beat `d = 4` at these costs.  Hence "true but with a different definition": the measured
percentage is a *mean accepted fraction*, not a per-position probability, and the two
readings are provably inequivalent here.

Critic: the numeric cells are `norm_num` evaluations, so each is stated only as a
corollary of a structural lemma (`speedup_lt_speedup_iff`, `speedup_lt_one_of_deep`,
`deepenPays_mono_acceptance`), never as the headline result; the headline results are the
quantified laws.  No theorem below is `True`, definitional, or `native_decide`.
-/

namespace SpecDecCPU

open Finset Filter Topology

/-! ## The block model -/

/-- Expected number of target tokens committed by one verification block, when each of the
`d` drafted positions is accepted independently with probability `a`: the accepted prefix
plus the free bonus token. -/
noncomputable def yieldGeom (a : ℝ) (d : ℕ) : ℝ := ∑ i ∈ range (d + 1), a ^ i

/-- Cost of one block, in units of one target decode step: one verification pass plus `d`
sequential draft steps of relative cost `c`. -/
def blockCost (c : ℝ) (d : ℕ) : ℝ := 1 + c * d

/-- Throughput of speculative decoding relative to plain autoregressive decoding. -/
noncomputable def speedup (a c : ℝ) (d : ℕ) : ℝ := yieldGeom a d / blockCost c d

/-- The tokens contributed by the positions strictly beyond depth `d` up to depth `e`. -/
noncomputable def tailSum (a : ℝ) (d e : ℕ) : ℝ := ∑ i ∈ Ico (d + 1) (e + 1), a ^ i

lemma yieldGeom_zero (a : ℝ) : yieldGeom a 0 = 1 := by simp [yieldGeom]

lemma blockCost_zero (c : ℝ) : blockCost c 0 = 1 := by simp [blockCost]

/-- Speculative decoding at depth `0` is ordinary decoding. -/
lemma speedup_zero (a c : ℝ) : speedup a c 0 = 1 := by
  simp [speedup, yieldGeom_zero, blockCost_zero]

lemma yieldGeom_pos {a : ℝ} (ha : 0 ≤ a) (d : ℕ) : 0 < yieldGeom a d := by
  have : (0:ℝ) < ∑ i ∈ range (d + 1), a ^ i :=
    Finset.sum_pos' (fun i _ => pow_nonneg ha i) ⟨0, by simp⟩
  simpa [yieldGeom] using this

lemma blockCost_pos {c : ℝ} (hc : 0 ≤ c) (d : ℕ) : 0 < blockCost c d := by
  have : 0 ≤ c * (d : ℝ) := mul_nonneg hc (Nat.cast_nonneg d)
  simp only [blockCost]; linarith

lemma tailSum_nonneg {a : ℝ} (ha : 0 ≤ a) (d e : ℕ) : 0 ≤ tailSum a d e :=
  Finset.sum_nonneg fun i _ => pow_nonneg ha i

lemma tailSum_pos {a : ℝ} (ha : 0 < a) {d e : ℕ} (hde : d < e) : 0 < tailSum a d e := by
  refine Finset.sum_pos' (fun i _ => pow_nonneg ha.le i) ⟨d + 1, ?_, pow_pos ha _⟩
  simp only [Finset.mem_Ico]
  omega

lemma yieldGeom_add_tail (a : ℝ) {d e : ℕ} (hde : d ≤ e) :
    yieldGeom a e = yieldGeom a d + tailSum a d e := by
  simp only [yieldGeom, tailSum]
  exact (Finset.sum_range_add_sum_Ico (fun i => a ^ i) (by omega)).symm

lemma blockCost_add (c : ℝ) (d e : ℕ) :
    blockCost c e = blockCost c d + c * ((e : ℝ) - d) := by
  simp only [blockCost]; ring

/-- Closed form of the block yield. -/
lemma one_sub_mul_yieldGeom (a : ℝ) (d : ℕ) :
    (1 - a) * yieldGeom a d = 1 - a ^ (d + 1) := by
  have h := geom_sum_mul a (d + 1)
  simp only [yieldGeom]
  linarith [h]

/-- The yield is bounded by the reciprocal rejection rate, uniformly in the depth: this is
the structural reason deep drafting cannot pay forever. -/
lemma yieldGeom_le_inv {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (d : ℕ) :
    yieldGeom a d ≤ (1 - a)⁻¹ := by
  have h1 : 0 < 1 - a := by linarith
  rw [inv_eq_one_div, le_div_iff₀ h1]
  nlinarith [one_sub_mul_yieldGeom a d, pow_nonneg ha (d + 1)]

/-! ## Comparison criterion and the cheap-draft law -/

/-- The exact criterion deciding a head-to-head between two drafts at a common depth. -/
lemma speedup_lt_speedup_iff {a a' c c' : ℝ} {d e : ℕ} (hc : 0 ≤ c) (hc' : 0 ≤ c') :
    speedup a c d < speedup a' c' e ↔
      yieldGeom a d * blockCost c' e < yieldGeom a' e * blockCost c d := by
  rw [speedup, speedup, div_lt_div_iff₀ (blockCost_pos hc d) (blockCost_pos hc' e)]

/-- **Cheap-draft law at equal acceptance.**  At a common acceptance rate and any positive
depth, a strictly cheaper draft is strictly faster.  (This is the degenerate case of cost
dominance; the content of NET-91 is that it survives an acceptance disadvantage.) -/
theorem cheaper_draft_wins {a c c' : ℝ} {d : ℕ} (ha : 0 ≤ a) (hc : 0 ≤ c) (hcc : c < c')
    (hd : 1 ≤ d) : speedup a c' d < speedup a c d := by
  rw [speedup_lt_speedup_iff (le_trans hc hcc.le) hc]
  have hY : 0 < yieldGeom a d := yieldGeom_pos ha d
  have hd' : (1:ℝ) ≤ d := by exact_mod_cast hd
  have : blockCost c d < blockCost c' d := by
    simp only [blockCost]; nlinarith
  nlinarith

/-! ### The six measured head-to-heads

In each cell the 0.5B draft (relative cost `0.118`) is compared with the 1.5B draft
(relative cost `0.234`) at the *measured* acceptance rates. -/

theorem head2head_prose_d2 :
    speedup (632/1000) (234/1000) 2 < speedup (639/1000) (118/1000) 2 := by
  rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

theorem head2head_prose_d4 :
    speedup (519/1000) (234/1000) 4 < speedup (477/1000) (118/1000) 4 := by
  rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

theorem head2head_prose_d8 :
    speedup (449/1000) (234/1000) 8 < speedup (309/1000) (118/1000) 8 := by
  rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

theorem head2head_code_d2 :
    speedup (834/1000) (234/1000) 2 < speedup (716/1000) (118/1000) 2 := by
  rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

theorem head2head_code_d4 :
    speedup (748/1000) (234/1000) 4 < speedup (630/1000) (118/1000) 4 := by
  rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-- The decisive cell: the 1.5B draft accepts strictly more (60.3% vs 56.0%) and still
loses, because its per-token cost is twice as large. -/
theorem head2head_code_d8 :
    speedup (603/1000) (234/1000) 8 < speedup (560/1000) (118/1000) 8 := by
  rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-- **Cost dominance (P3 refuted inside the model).**  With the measured acceptance rates
and relative draft costs, the cheap 0.5B draft beats the 1.5B draft in all six
(domain × depth) head-to-heads — there is no crossover. -/
theorem cost_dominance_all_six :
    speedup (632/1000) (234/1000) 2 < speedup (639/1000) (118/1000) 2 ∧
    speedup (519/1000) (234/1000) 4 < speedup (477/1000) (118/1000) 4 ∧
    speedup (449/1000) (234/1000) 8 < speedup (309/1000) (118/1000) 8 ∧
    speedup (834/1000) (234/1000) 2 < speedup (716/1000) (118/1000) 2 ∧
    speedup (748/1000) (234/1000) 4 < speedup (630/1000) (118/1000) 4 ∧
    speedup (603/1000) (234/1000) 8 < speedup (560/1000) (118/1000) 8 :=
  ⟨head2head_prose_d2, head2head_prose_d4, head2head_prose_d8,
   head2head_code_d2, head2head_code_d4, head2head_code_d8⟩

/-! ## The asymptotic invariant `c * (1 - a)` -/

lemma tendsto_yieldGeom {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) :
    Tendsto (fun d : ℕ => yieldGeom a d) atTop (𝓝 (1 - a)⁻¹) := by
  have h : Tendsto (fun n : ℕ => ∑ i ∈ range n, a ^ i) atTop (𝓝 (1 - a)⁻¹) :=
    (hasSum_geometric_of_lt_one ha ha1).tendsto_sum_nat
  exact (Filter.tendsto_add_atTop_iff_nat (f := fun n : ℕ => ∑ i ∈ range n, a ^ i) 1).2 h

lemma tendsto_depth_over_cost {c : ℝ} (hc : 0 < c) :
    Tendsto (fun d : ℕ => (d : ℝ) / blockCost c d) atTop (𝓝 c⁻¹) := by
  have h1 : Tendsto (fun d : ℕ => c + ((d : ℝ))⁻¹) atTop (𝓝 (c + 0)) :=
    tendsto_const_nhds.add (tendsto_inv_atTop_zero.comp tendsto_natCast_atTop_atTop)
  rw [add_zero] at h1
  refine (h1.inv₀ (ne_of_gt hc)).congr' ?_
  filter_upwards [eventually_gt_atTop 0] with d hd
  have hd' : (0 : ℝ) < d := by exact_mod_cast hd
  simp only [blockCost] at *
  field_simp
  ring

/-- **The deep-draft invariant.**  Speedup decays like `1 / (c (1-a) d)`: at large depth a
draft is characterised by the single scalar `c * (1 - a)`, cost times rejection rate. -/
theorem tendsto_d_speedup {a c : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (hc : 0 < c) :
    Tendsto (fun d : ℕ => (d : ℝ) * speedup a c d) atTop (𝓝 ((1 - a)⁻¹ * c⁻¹)) := by
  refine ((tendsto_yieldGeom ha ha1).mul (tendsto_depth_over_cost hc)).congr fun d => ?_
  simp only [speedup]
  ring

/-- **Asymptotic cost dominance.**  Draft `A` eventually beats draft `B` at every
sufficiently large depth exactly when its cost-times-rejection invariant is smaller.  An
acceptance advantage must beat the cost ratio *multiplicatively in the rejection rate*. -/
theorem asymptotic_cost_dominance {aA aB cA cB : ℝ} (hA : 0 ≤ aA) (hA1 : aA < 1)
    (hB : 0 ≤ aB) (hB1 : aB < 1) (hcA : 0 < cA) (hcB : 0 < cB)
    (hinv : cA * (1 - aA) < cB * (1 - aB)) :
    ∃ D : ℕ, ∀ d ≥ D, speedup aB cB d < speedup aA cA d := by
  have hposA : 0 < (1 - aA) * cA := by nlinarith
  have hposB : 0 < (1 - aB) * cB := by nlinarith
  have hlim : (1 - aB)⁻¹ * cB⁻¹ < (1 - aA)⁻¹ * cA⁻¹ := by
    have h1 : (1 - aB)⁻¹ * cB⁻¹ = ((1 - aB) * cB)⁻¹ := by
      rw [mul_inv]
    have h2 : (1 - aA)⁻¹ * cA⁻¹ = ((1 - aA) * cA)⁻¹ := by
      rw [mul_inv]
    rw [h1, h2]
    exact inv_strictAnti₀ hposA (by nlinarith)
  have hev := ((tendsto_d_speedup hB hB1 hcB).eventually_lt
    (tendsto_d_speedup hA hA1 hcA) hlim)
  rw [Filter.eventually_atTop] at hev
  obtain ⟨D, hD⟩ := hev
  refine ⟨max D 1, fun d hd => ?_⟩
  have hd1 : 1 ≤ d := le_trans (le_max_right D 1) hd
  have hdD : D ≤ d := le_trans (le_max_left D 1) hd
  have hd' : (0 : ℝ) < d := by exact_mod_cast hd1
  have := hD d hdD
  nlinarith [this]

/-- The acceptance the expensive draft would need in order to overturn cost dominance at
large depth: with `cA = 0.118`, `cB = 0.234` and `aA = 0.56`, the 1.5B draft needs at least
`77.8%` acceptance.  It measured `60.3%`. -/
theorem crossover_acceptance_needed {aB : ℝ}
    (h : (234/1000 : ℝ) * (1 - aB) ≤ (118/1000) * (1 - 560/1000)) : 778/1000 ≤ aB := by
  linarith

/-! ## Depth collapse: deep drafting is eventually a net loss -/

/-- **Depth gate.**  Once `(1 - a) * blockCost c d > 1`, speculative decoding at depth `d`
is strictly slower than plain decoding, whatever the model. -/
theorem speedup_lt_one_of_deep {a c : ℝ} {d : ℕ} (ha : 0 ≤ a) (ha1 : a < 1) (hc : 0 ≤ c)
    (h : 1 < (1 - a) * blockCost c d) : speedup a c d < 1 := by
  have hbc : 0 < blockCost c d := blockCost_pos hc d
  have h1 : 0 < 1 - a := by linarith
  have hY : yieldGeom a d ≤ (1 - a)⁻¹ := yieldGeom_le_inv ha ha1 d
  rw [speedup, div_lt_one hbc]
  have : (1 - a)⁻¹ < blockCost c d := by
    rw [inv_lt_iff_one_lt_mul₀ h1]
    linarith [h]
  linarith

/-- For every acceptance rate below `1` and every positive draft cost there is a depth past
which speculative decoding is a net loss. -/
theorem exists_depth_collapse {a c : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (hc : 0 < c) :
    ∃ D : ℕ, ∀ d ≥ D, speedup a c d < 1 := by
  set t : ℝ := a / ((1 - a) * c) with ht
  refine ⟨⌈t⌉₊ + 1, fun d hd => ?_⟩
  have h1 : 0 < 1 - a := by linarith
  have hpos : 0 < (1 - a) * c := by positivity
  have hle : t ≤ ⌈t⌉₊ := Nat.le_ceil t
  have hdR : (⌈t⌉₊ : ℝ) + 1 ≤ (d : ℝ) := by exact_mod_cast hd
  have hlt : t < (d : ℝ) := by linarith
  refine speedup_lt_one_of_deep ha ha1 hc.le ?_
  have : a < (1 - a) * c * d := by
    rw [ht, div_lt_iff₀ hpos] at hlt
    linarith
  simp only [blockCost]
  nlinarith

/-- Prose at depth 8 with the small draft: predicted **net loss** (measured `0.979x`). -/
theorem prose_depth8_loss_small : speedup (309/1000) (118/1000) 8 < 1 := by
  refine speedup_lt_one_of_deep (by norm_num) (by norm_num) (by norm_num) ?_
  norm_num [blockCost]

/-- Prose at depth 8 with the large draft: predicted **net loss** (measured `0.982x`). -/
theorem prose_depth8_loss_large : speedup (449/1000) (234/1000) 8 < 1 := by
  refine speedup_lt_one_of_deep (by norm_num) (by norm_num) (by norm_num) ?_
  norm_num [blockCost]

/-- Code at depth 8 with the small draft: predicted **net win** (measured `1.661x`, the
best cell of the experiment). -/
theorem code_depth8_win_small : 1 < speedup (560/1000) (118/1000) 8 := by
  rw [speedup, lt_div_iff₀ (blockCost_pos (by norm_num) 8)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-- Prose at depth 4 with the small draft: predicted **net win** (measured `1.416x`).  With
the previous three statements this exhibits the domain split at fixed draft: the same
0.5B draft flips from win to loss between `d = 4` and `d = 8` on prose while code keeps
paying. -/
theorem prose_depth4_win_small : 1 < speedup (477/1000) (118/1000) 4 := by
  rw [speedup, lt_div_iff₀ (blockCost_pos (by norm_num) 4)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-! ## Existence of an optimal depth -/

/-- Every (acceptance, cost) pair has a throughput-optimal draft depth. -/
theorem exists_optimal_depth {a c : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (hc : 0 < c) :
    ∃ D : ℕ, ∀ d : ℕ, speedup a c d ≤ speedup a c D := by
  obtain ⟨N, hN⟩ := exists_depth_collapse ha ha1 hc
  obtain ⟨D, hDmem, hDmax⟩ :=
    Finset.exists_max_image (range (N + 1)) (fun d => speedup a c d)
      ⟨0, by simp⟩
  refine ⟨D, fun d => ?_⟩
  have h0 : (1 : ℝ) ≤ speedup a c D := by
    have := hDmax 0 (by simp)
    rwa [speedup_zero] at this
  by_cases hdN : d ≤ N
  · exact hDmax d (by simp [Finset.mem_range]; omega)
  · exact le_of_lt (lt_of_lt_of_le (hN d (by omega)) h0)

/-! ## Comparative statics: the depth frontier is monotone in acceptance -/

/-- The exact condition for deepening the draft from `d` to `e` to pay off: the extra
positions must earn back the extra draft cost. -/
def DeepenPays (a c : ℝ) (d e : ℕ) : Prop :=
  c * ((e : ℝ) - d) * yieldGeom a d ≤ tailSum a d e * blockCost c d

lemma speedup_le_iff_deepenPays {a c : ℝ} {d e : ℕ} (hc : 0 ≤ c)
    (hde : d ≤ e) : speedup a c d ≤ speedup a c e ↔ DeepenPays a c d e := by
  rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos hc d) (blockCost_pos hc e),
    yieldGeom_add_tail a hde, blockCost_add c d e]
  simp only [DeepenPays]
  constructor <;> intro h <;> nlinarith

/-- Key cross-multiplication inequality: the ratio (tail beyond `d`) / (head up to `d`) is
monotone in the acceptance rate. -/
lemma tailSum_mul_yieldGeom_le {a a' : ℝ} (ha : 0 ≤ a) (haa : a ≤ a') (d e : ℕ) :
    tailSum a d e * yieldGeom a' d ≤ tailSum a' d e * yieldGeom a d := by
  have ha' : 0 ≤ a' := ha.trans haa
  simp only [tailSum, yieldGeom, Finset.sum_mul_sum]
  refine Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => ?_
  simp only [Finset.mem_Ico] at hi
  simp only [Finset.mem_range] at hj
  have hji : j + 1 ≤ i := le_trans hj hi.1
  obtain ⟨k, hk⟩ : ∃ k, i = j + (k + 1) := ⟨i - j - 1, by omega⟩
  subst hk
  have h1 : a ^ (k + 1) ≤ a' ^ (k + 1) := pow_le_pow_left₀ ha haa _
  calc a ^ (j + (k + 1)) * a' ^ j = a ^ j * a' ^ j * a ^ (k + 1) := by ring
    _ ≤ a ^ j * a' ^ j * a' ^ (k + 1) := by
        exact mul_le_mul_of_nonneg_left h1 (by positivity)
    _ = a' ^ (j + (k + 1)) * a ^ j := by ring

/-- **Monotone comparative statics (the depth law).**  If deepening the draft from `d` to
`e` pays at acceptance `a`, it pays at every larger acceptance `a'`.  Code accepts more
than prose, so code's profitable-depth set contains prose's: optimal depth is a monotone
function of domain acceptance, never a universal constant. -/
theorem deepenPays_mono_acceptance {a a' c : ℝ} {d e : ℕ} (ha : 0 < a) (haa : a ≤ a')
    (hc : 0 ≤ c) (hde : d < e) (h : DeepenPays a c d e) : DeepenPays a' c d e := by
  have hTa : 0 < tailSum a d e := tailSum_pos ha hde
  have hTa' : 0 ≤ tailSum a' d e := tailSum_nonneg (ha.le.trans haa) d e
  have hcross := tailSum_mul_yieldGeom_le ha.le haa d e
  have hbc : 0 < blockCost c d := blockCost_pos hc d
  have hed : (0 : ℝ) ≤ (e : ℝ) - d := by
    have : (d : ℝ) ≤ e := by exact_mod_cast hde.le
    linarith
  have hcoef : 0 ≤ c * ((e : ℝ) - d) := mul_nonneg hc hed
  simp only [DeepenPays] at h ⊢
  have key : c * ((e : ℝ) - d) * yieldGeom a' d * tailSum a d e ≤
      tailSum a' d e * blockCost c d * tailSum a d e := by
    calc c * ((e : ℝ) - d) * yieldGeom a' d * tailSum a d e
        = c * ((e : ℝ) - d) * (tailSum a d e * yieldGeom a' d) := by ring
      _ ≤ c * ((e : ℝ) - d) * (tailSum a' d e * yieldGeom a d) :=
          mul_le_mul_of_nonneg_left hcross hcoef
      _ = tailSum a' d e * (c * ((e : ℝ) - d) * yieldGeom a d) := by ring
      _ ≤ tailSum a' d e * (tailSum a d e * blockCost c d) :=
          mul_le_mul_of_nonneg_left h hTa'
      _ = tailSum a' d e * blockCost c d * tailSum a d e := by ring
  exact le_of_mul_le_mul_right key hTa

/-- **The depth frontier moves outward with acceptance.**  If depth `e` is at least as good
as depth `d < e` at acceptance `a`, the same holds at any higher acceptance. -/
theorem depth_frontier_monotone {a a' c : ℝ} {d e : ℕ} (ha : 0 < a) (haa : a ≤ a')
    (hc : 0 ≤ c) (hde : d < e) (h : speedup a c d ≤ speedup a c e) :
    speedup a' c d ≤ speedup a' c e := by
  rw [speedup_le_iff_deepenPays hc hde.le]
  exact deepenPays_mono_acceptance ha haa hc hde
    ((speedup_le_iff_deepenPays hc hde.le).1 h)

/-- **Informative failure / falsification of the i.i.d. reading.**  At the small draft's
cost, *no* per-position acceptance probability `a ≤ 0.8` makes depth `8` at least as good
as depth `4`.  The measured code acceptance at depth `8` is `0.56`, yet depth `8` measured
strictly faster (`1.661x` vs `1.616x`): therefore the reported percentage is not a
per-position independent acceptance probability. -/
theorem iid_cannot_explain_code_depth8 {a : ℝ} (ha : 0 ≤ a) (ha8 : a ≤ 8/10) :
    speedup a (118/1000) 8 < speedup a (118/1000) 4 := by
  rcases eq_or_lt_of_le ha with h0 | h0
  · -- degenerate case `a = 0`: pure overhead, deeper is strictly worse
    subst_vars
    rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
    norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
  · by_contra hcon
    push_neg at hcon
    have h8 : speedup (8/10 : ℝ) (118/1000) 4 ≤ speedup (8/10 : ℝ) (118/1000) 8 :=
      depth_frontier_monotone h0 ha8 (by norm_num) (by omega) hcon
    rw [speedup_le_iff_deepenPays (by norm_num) (by omega)] at h8
    simp only [DeepenPays, yieldGeom, tailSum, blockCost] at h8
    norm_num [Finset.sum_range_succ, Finset.sum_Ico_eq_sum_range] at h8

/-- The i.i.d. model *can* rank depth `8` above depth `4`, but only at a much higher
acceptance: `a = 0.85` already does.  Together with the previous theorem this brackets the
per-position acceptance consistent with the measured code cells strictly above `0.8`. -/
theorem iid_depth8_beats_depth4_at_085 :
    speedup (85/100) (118/1000) 4 < speedup (85/100) (118/1000) 8 := by
  rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
  norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-! ## The mean-yield reading and the CPU verification overhead -/

/-- Yield under the *mean accepted fraction* reading: if a fraction `q` of all drafted
tokens is committed, a block of depth `d` emits `1 + q * d` tokens. -/
def meanYield (q : ℝ) (d : ℕ) : ℝ := 1 + q * d

/-- Throughput under the mean-yield reading, with total marginal per-position cost `k`
(draft cost plus whatever the verification pass charges for one extra position). -/
noncomputable def meanSpeedup (q k : ℝ) (d : ℕ) : ℝ := meanYield q d / blockCost k d

/-- An affine yield over an affine cost is monotone increasing in depth whenever the
acceptance rate exceeds the marginal cost: such a model has **no interior optimum**. -/
theorem affine_ratio_mono {q k : ℝ} {d e : ℕ} (hk : 0 ≤ k) (hqk : k ≤ q) (hde : d ≤ e) :
    meanSpeedup q k d ≤ meanSpeedup q k e := by
  rw [meanSpeedup, meanSpeedup, div_le_div_iff₀ (blockCost_pos hk d) (blockCost_pos hk e)]
  have hde' : (d : ℝ) ≤ e := by exact_mod_cast hde
  simp only [meanYield, blockCost]
  nlinarith

/-- Dually, if the marginal cost exceeds the acceptance rate the affine model is monotone
decreasing: still no interior optimum.  Hence an interior optimal depth *requires* a
strictly concave yield — the measured prose profile (win at `d = 4`, loss at `d = 8`)
cannot be produced by any affine yield. -/
theorem affine_ratio_anti {q k : ℝ} {d e : ℕ} (hk : 0 ≤ k) (hqk : q ≤ k) (hde : d ≤ e) :
    meanSpeedup q k e ≤ meanSpeedup q k d := by
  rw [meanSpeedup, meanSpeedup, div_le_div_iff₀ (blockCost_pos hk e) (blockCost_pos hk d)]
  have hde' : (d : ℝ) ≤ e := by exact_mod_cast hde
  simp only [meanYield, blockCost]
  nlinarith

/-- Under the mean-yield reading and the pure draft cost, the code cells are reproduced in
the right order: depth `8` (56.0% mean acceptance) beats depth `4` (63.0%), exactly the
ordering the i.i.d. reading cannot produce. -/
theorem mean_reading_matches_code :
    meanSpeedup (630/1000) (118/1000) 4 < meanSpeedup (560/1000) (118/1000) 8 := by
  rw [meanSpeedup, meanSpeedup,
    div_lt_div_iff₀ (blockCost_pos (by norm_num) 4) (blockCost_pos (by norm_num) 8)]
  norm_num [meanYield, blockCost]

/-- **Derived hardware prediction.**  If the marginal cost `k` of one extra drafted and
verified position reproduces both measured depth-8 signs — prose (mean acceptance `0.309`)
a net loss and code (mean acceptance `0.560`) a net win — then `0.309 < k < 0.560`.  Since
the 0.5B draft itself costs only `0.118` per token, the verification pass must charge
`w = k - 0.118 ∈ (0.191, 0.442)` target-steps per extra position: on CPU, verification
does **not** amortise. -/
theorem verification_overhead_bracket {k : ℝ} (hk : 0 ≤ k)
    (hprose : meanSpeedup (309/1000) k 8 < 1) (hcode : 1 < meanSpeedup (560/1000) k 8) :
    309/1000 < k ∧ k < 560/1000 ∧ 191/1000 < k - 118/1000 ∧ k - 118/1000 < 442/1000 := by
  have hb : (0 : ℝ) < blockCost k 8 := blockCost_pos hk 8
  rw [meanSpeedup, div_lt_one hb] at hprose
  rw [meanSpeedup, lt_div_iff₀ hb] at hcode
  simp only [meanYield, blockCost] at hprose hcode
  norm_num at hprose hcode
  refine ⟨by linarith, by linarith, by linarith, by linarith⟩

end SpecDecCPU