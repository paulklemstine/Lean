/-
# INTERVAL-HINTS-TWO-NUMBERS: interval hints priced by coverage and width (FACT round 39 #5)

An oracle names a window of `W` of the `M` candidate cells that contains the target `J` with
reliability `α`.  Under truthful conditioning the posterior is `α / W` per window cell and
`(1-α)/(M-W)` per outside cell; the *committed procedure* scans the window first.

## Main results
* `probeCost_le_of_antitone` — greedy (non-increasing posterior) order is Bayes-optimal among
  all `n!` orders (rearrangement inequality).
* `hintedCost_eq`, **`speedup_eq`** — exact law `S = (M + 1) / ((1-α) M + W + 1)`.
* **`committed_bayes_optimal`** / **`committed_not_optimal`** — the committed procedure is
  Bayes-optimal **iff** `α ≥ W / M` (explicit improving swap otherwise).
* `speedup_le_coverage_ceiling` (`S ≤ 1/(1-α)`), `speedup_le_width_ceiling`,
  `speedup_eq_iff` (exchange rate: coverage deficit and width trade one-for-one),
  `speedup_tendsto` (continuum law `S = 1/(1 - α + w)`).
* `crossing_calibration`, `ninety_percent_overprices` — under the uniform prior a `5.19×`
  gain from a `2–5%` window corresponds to `α ∈ (0.82, 0.86)`, not `0.9`.
* `card_min_eq`, `minLaw_sum`, `minLaw_strictAnti`, `minLaw_mean` — the min-law
  `P(J = j) = (2(M-j)+1)/M²`, its Bayes-optimal blind cost `(M+1)(2M+1)/(6M)`.
* **`minLaw_block_cost`**, **`minLaw_block_speedup`** — perfect-coverage block hints under the
  min-law: cost `(W+1)(3M-W+1)/(6M)`, speedup → `2/(w(3-w))`.
* `optCost_concave`, `optCost_eq_of_antitone`, `hintedCost_eq_optCost` — information never
  hurts (concavity of the Bayes cost); the committed cost *is* the Bayes cost when `α ≥ w`.
* `misspecified_coverage_regret`, `misspecified_strict_regret` — trusting a claimed coverage `α`
  when the truth is `β` costs exactly `(α-β)M/2` extra probes; strictly Bayes-suboptimal if `β < w`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): (H1) the hint's value is a function of two numbers; (H2) the committed
  procedure is Bayes-optimal in every cell; (H3) the 5.19× crossing sits at ~90% reliability.
Experiment (Stage 2): brute force over all `720` orders at `M = 6, W = 2`: `α = 1/2, 1/3`
  committed = optimum (`3`, `7/2`); `α = 1/4` committed `15/4` > optimum `13/4`.  Exact
  min-law block speedups at `M = 10⁴`: `33.39 / 13.53 / 6.89 / 3.57` at `w = .02/.05/.10/.20`.
Analysis (Stage 3): (H1) true and exact in the uniform model, but the two numbers enter as
  the *sum* `1 - α + w`, not a product.  (H2) true only for `α ≥ w` (sharp).  (H3) false under
  the uniform prior (`α ∈ (0.82, 0.86)`).
Critique (Stage 4): the reported table uses a min-law prior and a window parametrised by
  `μ/M`; our min-law theorem covers perfect coverage with aligned blocks only, and its
  `w = 0.02` value (`33.4`) sits next to the reported MC value `34.0`, not the grid `29.13`.
-/
import Mathlib

namespace IntervalHintsTwoNumbers

open Finset Filter Topology

/-! ## 1. Probe cost of an order, and Bayes optimality of the greedy order -/

/-- Expected number of probes of the search order `σ` (probe `i` inspects cell `σ i`)
when the target sits in cell `j` with probability `q j`. -/
noncomputable def probeCost {n : ℕ} (q : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) : ℝ :=
  ∑ i : Fin n, (((i : ℕ) : ℝ) + 1) * q (σ i)

/-- **Greedy is Bayes-optimal.**  Any order that visits cells in non-increasing posterior
probability minimizes the expected number of probes among all orders. -/
theorem probeCost_le_of_antitone {n : ℕ} (q : Fin n → ℝ) (τ : Equiv.Perm (Fin n))
    (hτ : Antitone (q ∘ τ)) (σ : Equiv.Perm (Fin n)) :
    probeCost q τ ≤ probeCost q σ := by
  have hf : Monotone (fun i : Fin n => (((i : ℕ) : ℝ) + 1)) := by
    intro i j hij
    have : (i : ℕ) ≤ j := hij
    simp only
    exact_mod_cast Nat.add_le_add_right this 1
  have hanti : Antivary (fun i : Fin n => (((i : ℕ) : ℝ) + 1)) (q ∘ τ) := hf.antivary hτ
  have key := hanti.sum_mul_le_sum_mul_comp_perm (σ := σ.trans τ.symm)
  unfold probeCost
  convert key using 2 with i
  simp

/-! ## 2. Exact sums -/

lemma sum_range_succ_cast (W : ℕ) :
    ∑ i ∈ range W, ((i : ℝ) + 1) = (W : ℝ) * (W + 1) / 2 := by
  induction W with
  | zero => simp
  | succ k ih => rw [sum_range_succ, ih]; push_cast; ring

/-- Probe cost of the window-first order under a two-level weight profile. -/
lemma window_sum (M W : ℕ) (hWM : W ≤ M) (a b : ℝ) :
    ∑ i ∈ range M, ((i : ℝ) + 1) * (if i < W then a else b)
      = a * ((W : ℝ) * (W + 1) / 2) + b * (((M : ℝ) - W) * (M + W + 1) / 2) := by
  induction M, hWM using Nat.le_induction with
  | base =>
    rw [← sum_range_succ_cast, mul_sum]
    simp only [sub_self, zero_mul, zero_div, mul_zero, add_zero]
    refine sum_congr rfl fun i hi => ?_
    rw [if_pos (mem_range.mp hi)]; ring
  | succ k hk ih =>
    rw [sum_range_succ, ih, if_neg (by omega)]
    push_cast; ring

/-! ## 3. The interval-hint model (uniform prior on `M` cells) -/

/-- Truthful posterior after an interval hint covering the window `{0, …, W-1}` with
reliability `α`: mass `α` spread over the window, mass `1-α` over the complement. -/
noncomputable def hintPosterior (M W : ℕ) (α : ℝ) (j : Fin M) : ℝ :=
  if (j : ℕ) < W then α / W else (1 - α) / ((M : ℝ) - W)

/-- The posterior is a probability vector. -/
theorem hintPosterior_sum (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ) :
    ∑ j, hintPosterior M W α j = 1 := by
  unfold hintPosterior
  rw [Fin.sum_univ_eq_sum_range (fun j => if j < W then α / W else (1 - α) / ((M : ℝ) - W))]
  have h1 : ∀ N, W ≤ N → ∑ j ∈ range N, (if j < W then α / W else (1 - α) / ((M : ℝ) - W))
      = α + ((N : ℝ) - W) * ((1 - α) / ((M : ℝ) - W)) := by
    intro N hN
    induction N, hN using Nat.le_induction with
    | base =>
      have hW' : (W : ℝ) ≠ 0 := by exact_mod_cast hW.ne'
      rw [sum_congr rfl (fun i hi => if_pos (mem_range.mp hi)), sum_const, card_range,
        nsmul_eq_mul]
      field_simp; ring
    | succ k hk ih => rw [sum_range_succ, ih, if_neg (by omega)]; push_cast; ring
  rw [h1 M hWM.le]
  have : (M : ℝ) - W ≠ 0 := by
    have : (W : ℝ) < M := by exact_mod_cast hWM
    linarith
  field_simp; ring

/-- The committed procedure: scan the hinted window first, then the rest (in order). -/
noncomputable def hintedCost (M W : ℕ) (α : ℝ) : ℝ :=
  probeCost (hintPosterior M W α) (Equiv.refl _)

/-- Blind scan under the uniform prior. -/
noncomputable def blindCost (M : ℕ) : ℝ :=
  probeCost (fun _ : Fin M => 1 / (M : ℝ)) (Equiv.refl _)

theorem blindCost_eq (M : ℕ) (hM : 0 < M) : blindCost M = ((M : ℝ) + 1) / 2 := by
  unfold blindCost probeCost
  rw [Fin.sum_univ_eq_sum_range (fun i => ((i : ℝ) + 1) * (1 / (M : ℝ))), ← sum_mul,
    sum_range_succ_cast]
  have : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  field_simp

/-- **Exact hinted cost.**  `E[probes] = (W + 1 + (1-α) M) / 2`. -/
theorem hintedCost_eq (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ) :
    hintedCost M W α = ((W : ℝ) + 1 + (1 - α) * M) / 2 := by
  unfold hintedCost probeCost hintPosterior
  simp only [Equiv.refl_apply]
  rw [Fin.sum_univ_eq_sum_range
    (fun i => ((i : ℝ) + 1) * (if i < W then α / W else (1 - α) / ((M : ℝ) - W))),
    window_sum M W hWM.le]
  have hW' : (W : ℝ) ≠ 0 := by exact_mod_cast hW.ne'
  have hMW : (M : ℝ) - W ≠ 0 := by
    have : (W : ℝ) < M := by exact_mod_cast hWM
    linarith
  field_simp; ring

/-- Speedup of the committed procedure over the blind scan. -/
noncomputable def speedup (M W : ℕ) (α : ℝ) : ℝ := blindCost M / hintedCost M W α

/-- **INTERVAL-HINTS-TWO-NUMBERS (exact).**
`speedup = (M + 1) / ((1 - α) M + W + 1)`. -/
theorem speedup_eq (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ) :
    speedup M W α = ((M : ℝ) + 1) / ((1 - α) * M + W + 1) := by
  unfold speedup
  rw [blindCost_eq M (hW.trans hWM), hintedCost_eq M W hW hWM]
  rw [show (W : ℝ) + 1 + (1 - α) * M = (1 - α) * M + W + 1 by ring]
  rw [div_div_div_cancel_right₀ (two_ne_zero)]

/-! ## 4. Bayes optimality of the committed procedure, with its exact boundary -/

/-- **Bayes optimality.**  If the hint is at least as reliable as it is wide
(`W ≤ α M`, i.e. `α ≥ w`), scanning the window first is optimal among *all* `M!` orders. -/
theorem committed_bayes_optimal (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ)
    (hα : (W : ℝ) ≤ α * M) (σ : Equiv.Perm (Fin M)) :
    hintedCost M W α ≤ probeCost (hintPosterior M W α) σ := by
  apply probeCost_le_of_antitone
  have hW' : (0 : ℝ) < W := by exact_mod_cast hW
  have hMW : (0 : ℝ) < (M : ℝ) - W := by
    have : (W : ℝ) < M := by exact_mod_cast hWM
    linarith
  have hab : (1 - α) / ((M : ℝ) - W) ≤ α / W := by
    rw [div_le_div_iff₀ hMW hW']; nlinarith
  intro i j hij
  have hij' : (i : ℕ) ≤ j := hij
  simp only [Function.comp_apply, Equiv.refl_apply, hintPosterior]
  split_ifs with h1 h2 h2 <;> first | exact le_rfl | exact hab | omega

/-- **The boundary is sharp.**  If the hint is less reliable than it is wide (`α M < W`),
swapping the last window cell with the first outside cell strictly lowers the expected
cost: the committed procedure is then *not* Bayes-optimal. -/
theorem committed_not_optimal (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ)
    (hα : α * M < W) :
    probeCost (hintPosterior M W α)
        (Equiv.swap (⟨W - 1, by omega⟩ : Fin M) ⟨W, hWM⟩) < hintedCost M W α := by
  have hW' : (0 : ℝ) < W := by exact_mod_cast hW
  have hMW : (0 : ℝ) < (M : ℝ) - W := by
    have : (W : ℝ) < M := by exact_mod_cast hWM
    linarith
  have hab : α / W < (1 - α) / ((M : ℝ) - W) := by
    rw [div_lt_div_iff₀ hW' hMW]; nlinarith
  set x : Fin M := ⟨W - 1, by omega⟩
  set y : Fin M := ⟨W, hWM⟩
  have hxy : x ≠ y := by simp [x, y, Fin.ext_iff]; omega
  unfold hintedCost probeCost
  set q := hintPosterior M W α
  -- split off the two swapped probes
  have hsplit : ∀ f : Fin M → ℝ, ∑ i, f i = f x + f y + ∑ i ∈ (univ.erase x).erase y, f i := by
    intro f
    rw [← add_sum_erase _ _ (mem_univ x), ← add_sum_erase _ _ (mem_erase.mpr ⟨hxy.symm,
      mem_univ y⟩)]
    ring
  rw [hsplit, hsplit (fun i => (((i : ℕ) : ℝ) + 1) * q ((Equiv.refl (Fin M)) i))]
  have hrest : ∑ i ∈ (univ.erase x).erase y, (((i : ℕ) : ℝ) + 1) * q ((Equiv.swap x y) i)
      = ∑ i ∈ (univ.erase x).erase y, (((i : ℕ) : ℝ) + 1) * q ((Equiv.refl (Fin M)) i) := by
    refine sum_congr rfl fun i hi => ?_
    have h1 := ne_of_mem_erase hi
    have h2 := ne_of_mem_erase (mem_of_mem_erase hi)
    rw [Equiv.swap_apply_of_ne_of_ne h2 h1]; rfl
  rw [hrest]
  simp only [Equiv.swap_apply_left, Equiv.swap_apply_right, Equiv.refl_apply]
  have qx : q x = α / W := by simp [q, hintPosterior, x]; omega
  have qy : q y = (1 - α) / ((M : ℝ) - W) := by simp [q, hintPosterior, y]
  have cx : ((x : ℕ) : ℝ) + 1 = W := by
    simp only [x]; rw [Nat.cast_sub (by omega)]; push_cast; ring
  have cy : ((y : ℕ) : ℝ) + 1 = W + 1 := by simp [y]
  rw [qx, qy, cx, cy]
  nlinarith

/-! ## 5. The two-number law: ceilings, exchange rate, continuum limit -/

/-- **Coverage ceiling.**  No window, however narrow, beats `1 / (1 - α)`. -/
theorem speedup_le_coverage_ceiling (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ)
    (hα0 : 0 ≤ α) (hα : α < 1) : speedup M W α ≤ 1 / (1 - α) := by
  rw [speedup_eq M W hW hWM]
  have h1 : (0 : ℝ) < 1 - α := by linarith
  have hM : (0 : ℝ) ≤ M := by positivity
  have hW0 : (0 : ℝ) ≤ W := by positivity
  have hW1 : (1 : ℝ) ≤ W := by exact_mod_cast hW
  rw [div_le_div_iff₀ (by nlinarith) h1]
  nlinarith

/-- **Width ceiling.**  No reliability, however high, beats `(M + 1) / (W + 1)`. -/
theorem speedup_le_width_ceiling (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ)
    (hα : α ≤ 1) : speedup M W α ≤ ((M : ℝ) + 1) / (W + 1) := by
  rw [speedup_eq M W hW hWM]
  have hM : (0 : ℝ) ≤ M := by positivity
  apply div_le_div_of_nonneg_left (by positivity) (by positivity)
  nlinarith

/-- Perfect coverage attains the width ceiling. -/
theorem speedup_full_coverage (M W : ℕ) (hW : 0 < W) (hWM : W < M) :
    speedup M W 1 = ((M : ℝ) + 1) / (W + 1) := by
  rw [speedup_eq M W hW hWM]; ring_nf

/-- **Exchange rate.**  Two hints give the same speedup iff
`(1-α) M + W = (1-α') M + W'`: one cell of width trades for exactly `1/M` of coverage. -/
theorem speedup_eq_iff (M W W' : ℕ) (hW : 0 < W) (hWM : W < M) (hW2 : 0 < W') (hWM2 : W' < M)
    (α α' : ℝ) (hα : α ≤ 1) (hα' : α' ≤ 1) :
    speedup M W α = speedup M W' α' ↔ (1 - α) * M + W = (1 - α') * M + W' := by
  rw [speedup_eq M W hW hWM, speedup_eq M W' hW2 hWM2]
  have hM : (0 : ℝ) ≤ M := by positivity
  have h1 : (0 : ℝ) < (1 - α) * M + W + 1 := by nlinarith
  have h2 : (0 : ℝ) < (1 - α') * M + W' + 1 := by nlinarith
  rw [div_eq_div_iff h1.ne' h2.ne']
  constructor
  · intro h
    have hM1 : (0 : ℝ) < M + 1 := by linarith
    have := mul_left_cancel₀ hM1.ne' h
    linarith
  · intro h; rw [h]

/-- Speedup is strictly increasing in reliability. -/
theorem speedup_strictMono_alpha (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α α' : ℝ)
    (hαα' : α < α') (hα' : α' ≤ 1) : speedup M W α < speedup M W α' := by
  rw [speedup_eq M W hW hWM, speedup_eq M W hW hWM]
  have hM : (0 : ℝ) < M := by exact_mod_cast hW.trans hWM
  have h2 : (0 : ℝ) < (1 - α') * M + W + 1 := by
    have : (0 : ℝ) ≤ (1 - α') * M := by nlinarith
    positivity
  apply div_lt_div_of_pos_left (by positivity) h2
  nlinarith

/-- The continuum two-number law `S(α, w) = 1 / (1 - α + w)`. -/
noncomputable def continuumSpeedup (α w : ℝ) : ℝ := 1 / (1 - α + w)

/-- **Continuum limit.**  If the window occupies a fraction `w` of the cells asymptotically,
the exact speedup converges to `1 / (1 - α + w)`: coverage and width are the only two numbers. -/
theorem speedup_tendsto (α w : ℝ) (hpos : 0 < 1 - α + w) (Wseq : ℕ → ℕ)
    (hlim : Tendsto (fun M : ℕ => (Wseq M : ℝ) / M) atTop (𝓝 w)) :
    Tendsto (fun M : ℕ => ((M : ℝ) + 1) / ((1 - α) * M + Wseq M + 1)) atTop
      (𝓝 (continuumSpeedup α w)) := by
  have hinv : Tendsto (fun M : ℕ => (1 : ℝ) / M) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hnum : Tendsto (fun M : ℕ => 1 + (1 : ℝ) / M) atTop (𝓝 (1 + 0)) :=
    tendsto_const_nhds.add hinv
  have hden : Tendsto (fun M : ℕ => (1 - α) + (Wseq M : ℝ) / M + 1 / M) atTop
      (𝓝 ((1 - α) + w + 0)) := (tendsto_const_nhds.add hlim).add hinv
  have hq := hnum.div hden (by simpa using hpos.ne')
  unfold continuumSpeedup
  simp only [add_zero] at hq
  refine hq.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with M hM
  have hM' : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  simp only [Pi.div_apply]
  field_simp

/-- **Crossing calibration (uniform prior).**  A gain of `5.19×` from a window of width
`w ∈ [0.02, 0.05]` requires reliability strictly between `0.82` and `0.86` in the continuum
two-number law; in particular a `90%`-reliable window of such width over-prices it. -/
theorem crossing_calibration (α w : ℝ) (hw1 : 0.02 ≤ w) (hw2 : w ≤ 0.05)
    (hpos : 0 < 1 - α + w) (hS : continuumSpeedup α w = 5.19) :
    0.82 < α ∧ α < 0.86 := by
  unfold continuumSpeedup at hS
  rw [div_eq_iff hpos.ne'] at hS
  constructor <;> nlinarith

theorem ninety_percent_overprices (w : ℝ) (hw1 : 0.02 ≤ w) (hw2 : w ≤ 0.05) :
    5.19 < continuumSpeedup 0.9 w := by
  unfold continuumSpeedup
  rw [lt_div_iff₀ (by linarith)]
  nlinarith

/-! ## 6. The min-law prior (`J = min(p, q)`, `p, q` uniform on `{1, …, M}`) -/

/-- `P(J = i + 1) = (2 (M - 1 - i) + 1) / M²`, indexed from `0`. -/
noncomputable def minLaw (M : ℕ) (i : ℕ) : ℝ := (2 * ((M : ℝ) - 1 - i) + 1) / (M : ℝ) ^ 2

/-- Counting identity behind the min-law: exactly `2 (M - j) + 1` ordered pairs in
`{1..M}²` have minimum `j`. -/
theorem card_min_eq (M j : ℕ) (hj : 1 ≤ j) (hjM : j ≤ M) :
    #{x ∈ Icc 1 M ×ˢ Icc 1 M | min x.1 x.2 = j} = 2 * (M - j) + 1 := by
  have hset : {x ∈ Icc 1 M ×ˢ Icc 1 M | min x.1 x.2 = j}
      = ({j} ×ˢ Icc j M) ∪ (Icc (j + 1) M ×ˢ {j}) := by
    ext ⟨p, q⟩
    simp only [mem_filter, mem_product, mem_Icc, mem_union, mem_singleton]
    constructor
    · rintro ⟨⟨⟨h1, h2⟩, h3, h4⟩, h5⟩
      rcases le_total p q with h | h
      · rw [min_eq_left h] at h5; left; omega
      · rw [min_eq_right h] at h5
        rcases eq_or_lt_of_le h with h' | h'
        · left; omega
        · right; omega
    · rintro (⟨h1, h2, h3⟩ | ⟨⟨h1, h2⟩, h3⟩)
      · subst h1; refine ⟨⟨⟨hj, hjM⟩, by omega, h3⟩, min_eq_left h2⟩
      · subst h3; refine ⟨⟨⟨by omega, h2⟩, hj, hjM⟩, min_eq_right (by omega)⟩
  rw [hset, card_union_of_disjoint]
  · simp only [card_product, card_singleton, Nat.card_Icc]; omega
  · rw [disjoint_left]
    rintro ⟨p, q⟩ h1 h2
    simp only [mem_product, mem_singleton, mem_Icc] at h1 h2
    omega

lemma minLaw_partial_sum (M N : ℕ) :
    ∑ i ∈ range N, (2 * ((M : ℝ) - 1 - i) + 1) = N * (2 * M - N) := by
  induction N with
  | zero => simp
  | succ k ih => rw [sum_range_succ, ih]; push_cast; ring

theorem minLaw_sum (M : ℕ) (hM : 0 < M) : ∑ i ∈ range M, minLaw M i = 1 := by
  unfold minLaw
  rw [← sum_div, minLaw_partial_sum]
  have : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  field_simp; ring

/-- The min-law is strictly decreasing: ascending scan is the Bayes-optimal blind order, and
conditioning on a hit inside any window of width `≥ 2` is *not* uniform. -/
theorem minLaw_strictAnti (M : ℕ) (hM : 0 < M) : StrictAnti (minLaw M) := by
  intro i j hij
  unfold minLaw
  have : (0 : ℝ) < (M : ℝ) ^ 2 := by positivity
  apply div_lt_div_of_pos_right _ this
  have : (i : ℝ) < j := by exact_mod_cast hij
  linarith

/-- **Min-law baseline.**  The Bayes-optimal blind (ascending) scan costs
`E[J] = (M + 1)(2M + 1) / (6M) ≈ M/3`. -/
theorem minLaw_mean (M : ℕ) (hM : 0 < M) :
    ∑ i ∈ range M, ((i : ℝ) + 1) * minLaw M i = ((M : ℝ) + 1) * (2 * M + 1) / (6 * M) := by
  have key : ∀ N : ℕ, ∑ i ∈ range N, ((i : ℝ) + 1) * (2 * ((M : ℝ) - 1 - i) + 1)
      = N * (N + 1) * ((2 * M + 1) / 2 - (2 * N + 1) / 3) := by
    intro N
    induction N with
    | zero => simp
    | succ k ih => rw [sum_range_succ, ih]; push_cast; ring
  unfold minLaw
  simp_rw [mul_div_assoc']
  rw [← sum_div, key]
  have : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  field_simp; ring

/-! ## 7. Perfect-coverage block hints under the min-law

The oracle partitions the `M = k W` cells into `k` consecutive blocks of width `W` and
names the block containing `J`; the committed procedure scans that block in ascending order
(Bayes-optimal inside it, by `minLaw_strictAnti`). -/

lemma inner_block_sum (A : ℝ) (N : ℕ) :
    ∑ r ∈ range N, ((r : ℝ) + 1) * (A - 2 * r)
      = A * (N * (N + 1) / 2) - 2 * (((N : ℝ) - 1) * N * (N + 1) / 3) := by
  induction N with
  | zero => simp
  | succ n ih => rw [sum_range_succ, ih]; push_cast; ring

lemma outer_block_sum (M W K : ℕ) :
    ∑ b ∈ range K, ((2 * (M : ℝ) - 1 - 2 * (b * W)) * (W * (W + 1) / 2)
        - 2 * (((W : ℝ) - 1) * W * (W + 1) / 3))
      = K * (((2 * (M : ℝ) - 1) * (W * (W + 1) / 2) - 2 * (((W : ℝ) - 1) * W * (W + 1) / 3))
        - (K - 1) * W * (W * (W + 1) / 2)) := by
  induction K with
  | zero => simp
  | succ n ih => rw [sum_range_succ, ih]; push_cast; ring

/-- **Exact block-hint cost under the min-law.**  With perfect coverage and blocks of width
`W` (`M = k W`), the expected number of probes is `(W + 1)(3M - W + 1) / (6M)`. -/
theorem minLaw_block_cost (k W : ℕ) (hk : 0 < k) (hW : 0 < W) :
    ∑ b ∈ range k, ∑ r ∈ range W, ((r : ℝ) + 1) * minLaw (k * W) (b * W + r)
      = ((W : ℝ) + 1) * (3 * (k * W : ℕ) - W + 1) / (6 * (k * W : ℕ)) := by
  have hinner : ∀ b : ℕ, ∑ r ∈ range W, ((r : ℝ) + 1) * minLaw (k * W) (b * W + r)
      = (((2 * ((k * W : ℕ) : ℝ) - 1 - 2 * (b * W)) * (W * (W + 1) / 2)
        - 2 * (((W : ℝ) - 1) * W * (W + 1) / 3))) / ((k * W : ℕ) : ℝ) ^ 2 := by
    intro b
    unfold minLaw
    rw [← inner_block_sum, sum_div]
    refine sum_congr rfl fun r _ => ?_
    push_cast; ring
  simp_rw [hinner]
  rw [← sum_div, outer_block_sum]
  have hk' : (k : ℝ) ≠ 0 := by exact_mod_cast hk.ne'
  have hW' : (W : ℝ) ≠ 0 := by exact_mod_cast hW.ne'
  push_cast
  field_simp
  ring

/-- **Block-hint speedup under the min-law** (perfect coverage, against the Bayes-optimal
ascending blind scan of `minLaw_mean`):
`S = (M + 1)(2M + 1) / ((W + 1)(3M - W + 1))`, whose continuum limit is `2 / (w (3 - w))`. -/
theorem minLaw_block_speedup (k W : ℕ) (hk : 0 < k) (hW : 0 < W) :
    (∑ i ∈ range (k * W), ((i : ℝ) + 1) * minLaw (k * W) i) /
      (∑ b ∈ range k, ∑ r ∈ range W, ((r : ℝ) + 1) * minLaw (k * W) (b * W + r))
      = (((k * W : ℕ) : ℝ) + 1) * (2 * (k * W : ℕ) + 1)
          / (((W : ℝ) + 1) * (3 * (k * W : ℕ) - W + 1)) := by
  have hM : 0 < k * W := Nat.mul_pos hk hW
  rw [minLaw_mean _ hM, minLaw_block_cost k W hk hW]
  have hM' : ((k * W : ℕ) : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  have hWle : (W : ℝ) ≤ ((k * W : ℕ) : ℝ) := by
    exact_mod_cast Nat.le_mul_of_pos_left W hk
  have hden : ((W : ℝ) + 1) * (3 * (k * W : ℕ) - W + 1) ≠ 0 := by
    apply mul_ne_zero (by positivity)
    have : (0 : ℝ) ≤ W := by positivity
    linarith
  rw [div_div_div_eq, div_eq_div_iff (by positivity) hden]
  ring

/-- Continuum min-law block speedup `2 / (w (3 - w))`: at `w = 0.02` it exceeds `33`
(compare the reported grid value `29.13` and Monte-Carlo value `34.0`). -/
theorem minLaw_continuum_at_two_percent : 33 < 2 / ((0.02 : ℝ) * (3 - 0.02)) := by
  rw [lt_div_iff₀ (by norm_num)]; norm_num

/-! ## 8. Information never hurts: concavity of the Bayes-optimal cost -/

/-- Bayes-optimal expected cost under the weight vector `q`. -/
noncomputable def optCost {n : ℕ} (q : Fin n → ℝ) : ℝ :=
  univ.inf' univ_nonempty (fun σ : Equiv.Perm (Fin n) => probeCost q σ)

lemma probeCost_mix {n : ℕ} (q₁ q₂ : Fin n → ℝ) (t : ℝ) (σ : Equiv.Perm (Fin n)) :
    probeCost (fun j => t * q₁ j + (1 - t) * q₂ j) σ
      = t * probeCost q₁ σ + (1 - t) * probeCost q₂ σ := by
  unfold probeCost
  rw [mul_sum, mul_sum, ← sum_add_distrib]
  refine sum_congr rfl fun i _ => ?_
  ring

/-- **Concavity / value of information.**  Splitting a prior into two truthful posteriors
(a hint) can only lower the Bayes-optimal expected cost:
`optCost (t q₁ + (1-t) q₂) ≥ t optCost q₁ + (1-t) optCost q₂`. -/
theorem optCost_concave {n : ℕ} (q₁ q₂ : Fin n → ℝ) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    t * optCost q₁ + (1 - t) * optCost q₂ ≤ optCost (fun j => t * q₁ j + (1 - t) * q₂ j) := by
  unfold optCost
  apply le_inf'
  intro σ _
  rw [probeCost_mix]
  have h1 := inf'_le (fun σ : Equiv.Perm (Fin n) => probeCost q₁ σ) (mem_univ σ)
  have h2 := inf'_le (fun σ : Equiv.Perm (Fin n) => probeCost q₂ σ) (mem_univ σ)
  have : 0 ≤ 1 - t := by linarith
  exact add_le_add (mul_le_mul_of_nonneg_left h1 ht0) (mul_le_mul_of_nonneg_left h2 this)

/-- The Bayes-optimal cost is attained by any greedy (non-increasing) order. -/
theorem optCost_eq_of_antitone {n : ℕ} (q : Fin n → ℝ) (τ : Equiv.Perm (Fin n))
    (hτ : Antitone (q ∘ τ)) : optCost q = probeCost q τ := by
  apply le_antisymm (inf'_le _ (mem_univ τ))
  exact le_inf' _ _ fun σ _ => probeCost_le_of_antitone q τ hτ σ

/-- In the uniform interval-hint model with `α ≥ w`, the committed procedure's cost *is* the
Bayes-optimal cost. -/
theorem hintedCost_eq_optCost (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ)
    (hα : (W : ℝ) ≤ α * M) : optCost (hintPosterior M W α) = hintedCost M W α :=
  le_antisymm (inf'_le _ (mem_univ _))
    (le_inf' _ _ fun σ _ => committed_bayes_optimal M W hW hWM α hα σ)

/-! ## 9. Misspecified coverage -/

/-- **Misspecified-coverage regret.**  The window-first order does not depend on the claimed
reliability `α`; if the true coverage is `β`, the realized expected cost exceeds the advertised
one by exactly `(α - β) M / 2` probes, and the realized speedup is `(M+1)/((1-β)M+W+1)`. -/
theorem misspecified_coverage_regret (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α β : ℝ) :
    probeCost (hintPosterior M W β) (Equiv.refl _) - hintedCost M W α = (α - β) * M / 2 ∧
      blindCost M / probeCost (hintPosterior M W β) (Equiv.refl _)
        = ((M : ℝ) + 1) / ((1 - β) * M + W + 1) := by
  refine ⟨?_, speedup_eq M W hW hWM β⟩
  have h := hintedCost_eq M W hW hWM β
  unfold hintedCost at h
  rw [h, hintedCost_eq M W hW hWM α]
  ring

/-- **Over-trusting a wide hint is strictly suboptimal.**  If the true coverage `β` satisfies
`β M < W`, the committed (window-first) procedure costs strictly more than the Bayes optimum
under the true posterior, whatever reliability the oracle claimed. -/
theorem misspecified_strict_regret (M W : ℕ) (hW : 0 < W) (hWM : W < M) (β : ℝ)
    (hβ : β * M < W) : optCost (hintPosterior M W β) < hintedCost M W β :=
  lt_of_le_of_lt (inf'_le _ (mem_univ _)) (committed_not_optimal M W hW hWM β hβ)

end IntervalHintsTwoNumbers