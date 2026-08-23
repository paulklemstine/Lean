import Mathlib

/-!
# The zero-fit dial at bitlen 64: an exact tie-attenuation ceiling for Spearman correlation

## Research context (FACT round-61 #1, exp 530, `U64-DIAL-HOLDS-COUNT-PARITY`)

The measurement under study reports a Spearman rank correlation between a
*zero-count statistic* `T` (the number of trailing binary zeros, i.e. the 2-adic
valuation, of a uniformly drawn integer) and a downstream `rate`, on uniform
draws at bitlen 64:

* seeds 20261140/41/42 give `0.658 / 0.642 / 0.643`;
* pooled `0.648`, CI `[0.629, 0.665]`, all inside the validation band `[0.55, 0.85]`;
* the dial declines gently from `≈ 0.78` at bitlen 44 to `≈ 0.65` at bitlen 64.

This file supplies the *mathematics* that such a dial needs: an exact,
closed-form ceiling for any Spearman coefficient measured between a tied
discrete statistic and any tie-refining response, together with the explicit
evaluation of that ceiling for the dyadic (2-adic valuation) tie profile of
uniform `b`-bit draws.

## Main results

* `sp_eq_ssR` — the *midrank collapse identity*: if the response ranking refines
  the blocks of the tied statistic, the centred cross-product equals the
  between-block sum of squares.  (Probabilistically: `Cov(R,S) = Var(R)` because
  `R = E[S | block]`.)
* `ssS_eq_ssR_add` — the *tie decomposition*: total centred sum of squares
  = between-block part + `Σⱼ (mⱼ³ - mⱼ)/12`.
* `spearmanSq_eq` — the **tie-attenuation law**
  `ρ² = 1 - 12·Σⱼ(mⱼ³ - mⱼ) / (n³ - n)`, and `spearman_eq_sqrt` for `ρ` itself.
* `spearman_eq_one_iff` — `ρ = 1` exactly when there are no ties.
* `dyadic_spearmanSq` — for the 2-adic tie profile of uniform `b`-bit draws
  (`b ≥ 1`) the ceiling is **exactly** `ρ² = (6/7)·(1 + 1/(2^b(2^b+1)))`.
* `dyadic_ceiling_strict_anti`, `dyadic_ceiling_gt`, `dyadic_ceiling_tendsto` —
  the ceiling decreases strictly in the bitlen and converges to `6/7`
  (`ρ → √(6/7) ≈ 0.92582`) from above.
* `card_two_adic_block`, `dyadicBlocks_eq_valuation_profile` — the arithmetic
  bridge: the tie blocks of the trailing-zero statistic on `range (2^b)` have
  cardinalities `2^(b-1-k)` (plus the singleton `{0}`), which is exactly the
  dyadic profile used above.
* `u64_inside_band`, `u64_below_tie_ceiling`, `tie_ceiling_insufficient`,
  `count_parity_gap` — the recorded round-61 numbers checked against the theory.

## The scientific payload

`tie_ceiling_insufficient` is the sharp negative result: between bitlen 44 and
bitlen 64 the tie-attenuation ceiling can drop by **less than `10⁻²⁶`**, while
the recorded dial drops by `0.78 → 0.648` (i.e. `≈ 0.188` in `ρ²`).  Hence the
observed monotone decline of the zero-fit dial is *not* a tie/quantisation
artefact: the 2-adic tie profile is scale-invariant to within `O(4^{-b})`, and
any explanation of the decline must come from the response, not from the
granularity of the zero-count statistic.
-/

open Finset

namespace Catalog.Novelty.ZeroFitDialU64

/-! ## 1. Elementary rank sums -/

/-- Gauss sum, shifted to ranks `1, …, m`. -/
lemma sum_rank (m : ℕ) : ∑ t ∈ range m, ((t : ℚ) + 1) = (m : ℚ) * (m + 1) / 2 := by
  induction m with
  | zero => simp
  | succ k ih => rw [sum_range_succ, ih]; push_cast; ring

/-- Sum of squares of the ranks `1, …, m`. -/
lemma sum_rank_sq (m : ℕ) :
    ∑ t ∈ range m, ((t : ℚ) + 1) ^ 2 = (m : ℚ) * (m + 1) * (2 * m + 1) / 6 := by
  induction m with
  | zero => simp
  | succ k ih => rw [sum_range_succ, ih]; push_cast; ring

/-- `x³ - x ≥ 0` for `x ≥ 1`. -/
lemma cube_sub_self_nonneg {x : ℚ} (h : 1 ≤ x) : 0 ≤ x ^ 3 - x := by
  have h1 : (0 : ℚ) ≤ x * (x - 1) * (x + 1) :=
    mul_nonneg (mul_nonneg (by linarith) (by linarith)) (by linarith)
  linarith [h1]

/-- `x³ - x > 0` for `x ≥ 2`. -/
lemma cube_sub_self_pos {x : ℚ} (h : 2 ≤ x) : 0 < x ^ 3 - x := by
  have h1 : (0 : ℚ) < x * (x - 1) * (x + 1) :=
    mul_pos (mul_pos (by linarith) (by linarith)) (by linarith)
  linarith [h1]

/-- Within a tie block of size `m`, the ranks have centred sum of squares `(m³ - m)/12`. -/
lemma block_centered_sq (m : ℕ) :
    ∑ t ∈ range m, (((t : ℚ) + 1) - ((m : ℚ) + 1) / 2) ^ 2 = ((m : ℚ) ^ 3 - m) / 12 := by
  have h : ∀ t ∈ range m, (((t : ℚ) + 1) - ((m : ℚ) + 1) / 2) ^ 2
      = ((t : ℚ) + 1) ^ 2 - ((m : ℚ) + 1) * ((t : ℚ) + 1) + ((m : ℚ) + 1) ^ 2 / 4 := by
    intros; ring
  rw [sum_congr rfl h, sum_add_distrib, sum_sub_distrib, ← mul_sum, sum_const, card_range,
    sum_rank, sum_rank_sq, nsmul_eq_mul]
  ring

/-- Within a tie block the centred ranks sum to zero. -/
lemma block_centered_zero (m : ℕ) :
    ∑ t ∈ range m, (((t : ℚ) + 1) - ((m : ℚ) + 1) / 2) = 0 := by
  rw [sum_sub_distrib, sum_rank, sum_const, card_range, nsmul_eq_mul]; ring

/-- Parallel-axis decomposition inside a single tie block. -/
lemma block_shift (m : ℕ) (d : ℚ) :
    ∑ t ∈ range m, (((t : ℚ) + 1) + d) ^ 2
      = (m : ℚ) * (((m : ℚ) + 1) / 2 + d) ^ 2 + ((m : ℚ) ^ 3 - m) / 12 := by
  have h : ∀ t ∈ range m, (((t : ℚ) + 1) + d) ^ 2
      = (((t : ℚ) + 1) - ((m : ℚ) + 1) / 2) ^ 2
        + 2 * (((m : ℚ) + 1) / 2 + d) * (((t : ℚ) + 1) - ((m : ℚ) + 1) / 2)
        + (((m : ℚ) + 1) / 2 + d) ^ 2 := by
    intros; ring
  rw [sum_congr rfl h, sum_add_distrib, sum_add_distrib, ← mul_sum, block_centered_sq,
    block_centered_zero, sum_const, card_range, nsmul_eq_mul]
  ring

/-! ## 2. Tie profiles and the three centred sums

A *tie profile* is the list `L` of block sizes of the tied statistic `T`, listed in
increasing order of the `T`-value; `n = L.sum` is the sample size.  The response
`Y` is assumed to *refine* the blocks: its rank vector `S` is a bijection onto
`{1,…,n}` which, restricted to each block, uses exactly the ranks of that block.
The `T`-side rank vector `R` is the usual midrank vector, constant on blocks. -/

/-- Between-block (midrank) centred sum of squares, `n · Var R`, with block offset `c`. -/
def ssR (mu : ℚ) : List ℕ → ℚ → ℚ
  | [], _ => 0
  | m :: L, c => (m : ℚ) * ((c + ((m : ℚ) + 1) / 2) - mu) ^ 2 + ssR mu L (c + m)

/-- Total centred sum of squares of the raw ranks, `n · Var S`. -/
def ssS (mu : ℚ) : List ℕ → ℚ → ℚ
  | [], _ => 0
  | m :: L, c => (∑ t ∈ range m, ((c + (t : ℚ) + 1) - mu) ^ 2) + ssS mu L (c + m)

/-- Centred cross product of midranks against raw ranks, `n · Cov (R, S)`. -/
def sp (mu : ℚ) : List ℕ → ℚ → ℚ
  | [], _ => 0
  | m :: L, c =>
      (∑ t ∈ range m, ((c + ((m : ℚ) + 1) / 2) - mu) * ((c + (t : ℚ) + 1) - mu)) + sp mu L (c + m)

/-- The Kendall tie correction `Σⱼ (mⱼ³ - mⱼ)/12`. -/
def tieCorr (L : List ℕ) : ℚ := (L.map fun m => ((m : ℚ) ^ 3 - m) / 12).sum

lemma tieCorr_cons (m : ℕ) (L : List ℕ) :
    tieCorr (m :: L) = ((m : ℚ) ^ 3 - m) / 12 + tieCorr L := by
  simp [tieCorr]

/-- Each tie-correction term is nonnegative. -/
lemma tieCorr_term_nonneg (m : ℕ) : 0 ≤ ((m : ℚ) ^ 3 - m) / 12 := by
  rcases Nat.eq_zero_or_pos m with hz | hz
  · simp [hz]
  · have h1 : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hz
    have := cube_sub_self_nonneg h1
    linarith

/-- A block of size at least two contributes strictly. -/
lemma tieCorr_term_pos {m : ℕ} (h : 2 ≤ m) : 0 < ((m : ℚ) ^ 3 - m) / 12 := by
  have h1 : (2 : ℚ) ≤ (m : ℚ) := by exact_mod_cast h
  have := cube_sub_self_pos h1
  linarith

lemma tieCorr_nonneg (L : List ℕ) : 0 ≤ tieCorr L := by
  induction L with
  | nil => simp [tieCorr]
  | cons m L ih =>
      rw [tieCorr_cons]
      have := tieCorr_term_nonneg m
      linarith

lemma tieCorr_eq_zero_iff (L : List ℕ) : tieCorr L = 0 ↔ ∀ m ∈ L, m ≤ 1 := by
  induction L with
  | nil => simp [tieCorr]
  | cons m L ih =>
      rw [tieCorr_cons]
      constructor
      · intro h
        have h2 := tieCorr_nonneg L
        have hm : 0 ≤ ((m : ℚ) ^ 3 - m) / 12 := tieCorr_term_nonneg m
        have hm0 : ((m : ℚ) ^ 3 - m) / 12 = 0 := by linarith
        have hL0 : tieCorr L = 0 := by linarith
        have hmle : m ≤ 1 := by
          by_contra hc
          push_neg at hc
          have := tieCorr_term_pos hc
          linarith
        intro x hx
        rcases List.mem_cons.1 hx with rfl | hx'
        · exact hmle
        · exact (ih.1 hL0) x hx'
      · intro h
        have hm : m ≤ 1 := h m (List.mem_cons_self ..)
        have hL : tieCorr L = 0 := ih.2 fun x hx => h x (List.mem_cons_of_mem _ hx)
        interval_cases m <;> simp [hL]

/-- **Midrank collapse identity.**  Because the midrank vector is the conditional mean of the
refining response ranks, the centred cross product equals the between-block sum of squares:
`Cov (R, S) = Var R`. -/
theorem sp_eq_ssR (mu : ℚ) (L : List ℕ) (c : ℚ) : sp mu L c = ssR mu L c := by
  induction L generalizing c with
  | nil => rfl
  | cons m L ih =>
      simp only [sp, ssR, ih]
      congr 1
      have h : ∀ t ∈ range m, ((c + ((m : ℚ) + 1) / 2) - mu) * ((c + (t : ℚ) + 1) - mu)
          = ((c + ((m : ℚ) + 1) / 2) - mu) * (((t : ℚ) + 1) + (c - mu)) := by intros; ring
      rw [sum_congr rfl h, ← mul_sum, sum_add_distrib, sum_rank, sum_const, card_range,
        nsmul_eq_mul]
      ring

/-- **Tie decomposition.**  Total variability splits into the between-block part plus the
Kendall tie correction. -/
theorem ssS_eq_ssR_add (mu : ℚ) (L : List ℕ) (c : ℚ) : ssS mu L c = ssR mu L c + tieCorr L := by
  induction L generalizing c with
  | nil => simp [ssS, ssR, tieCorr]
  | cons m L ih =>
      simp only [ssS, ssR, ih, tieCorr_cons]
      have h : ∀ t ∈ range m, ((c + (t : ℚ) + 1) - mu) ^ 2 = (((t : ℚ) + 1) + (c - mu)) ^ 2 := by
        intros; ring
      rw [sum_congr rfl h, block_shift]
      ring

lemma ssS_eq_range (mu : ℚ) (L : List ℕ) (c : ℚ) :
    ssS mu L c = ∑ t ∈ range L.sum, ((c + (t : ℚ) + 1) - mu) ^ 2 := by
  induction L generalizing c with
  | nil => simp [ssS]
  | cons m L ih =>
      simp only [ssS, ih, List.sum_cons, Finset.sum_range_add]
      congr 1
      refine sum_congr rfl ?_
      intro t _
      push_cast
      ring

lemma ssR_nonneg (mu : ℚ) (L : List ℕ) (c : ℚ) : 0 ≤ ssR mu L c := by
  induction L generalizing c with
  | nil => simp [ssR]
  | cons m L ih =>
      have h1 : (0 : ℚ) ≤ (m : ℚ) * ((c + ((m : ℚ) + 1) / 2) - mu) ^ 2 :=
        mul_nonneg (by positivity) (sq_nonneg _)
      have := ih (c + m)
      simp only [ssR]
      linarith

/-- The grand mean of the ranks `1, …, n`. -/
def gmean (L : List ℕ) : ℚ := ((L.sum : ℚ) + 1) / 2

/-- The total centred sum of squares of the ranks is `(n³ - n)/12`. -/
theorem ssS_total (L : List ℕ) : ssS (gmean L) L 0 = ((L.sum : ℚ) ^ 3 - L.sum) / 12 := by
  rw [ssS_eq_range]
  rw [← block_centered_sq L.sum]
  refine sum_congr rfl ?_
  intro t _
  simp [gmean]

/-- The squared Spearman coefficient of a tie profile: `Cov(R,S)² / (Var R · Var S)`,
which by `sp_eq_ssR` equals `Var R / Var S`. -/
def spearmanSq (L : List ℕ) : ℚ := ssR (gmean L) L 0 / ssS (gmean L) L 0

/-- Normalisation step used in the tie-attenuation law. -/
lemma sub_div_twelve (D t : ℚ) (hD : D ≠ 0) : (D / 12 - t) / (D / 12) = 1 - 12 * t / D := by
  field_simp

/-- **Tie-attenuation law.**  For any tie profile with `n ≥ 2` observations,
`ρ² = 1 - 12·Σⱼ(mⱼ³ - mⱼ)/(n³ - n)`.  Nothing about the response enters beyond the
assumption that its ranking refines the tie blocks. -/
theorem spearmanSq_eq (L : List ℕ) (h : 2 ≤ L.sum) :
    spearmanSq L = 1 - 12 * tieCorr L / ((L.sum : ℚ) ^ 3 - L.sum) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : ((L.sum : ℚ) ^ 3 - L.sum) ≠ 0 := ne_of_gt (cube_sub_self_pos hn)
  have hssS : ssS (gmean L) L 0 = ((L.sum : ℚ) ^ 3 - L.sum) / 12 := ssS_total L
  have hssR : ssR (gmean L) L 0 = ssS (gmean L) L 0 - tieCorr L := by
    have := ssS_eq_ssR_add (gmean L) L 0; linarith
  rw [spearmanSq, hssR, hssS]
  exact sub_div_twelve _ _ hden

/-- The tie ceiling never exceeds one. -/
theorem spearmanSq_le_one (L : List ℕ) (h : 2 ≤ L.sum) : spearmanSq L ≤ 1 := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - L.sum := cube_sub_self_pos hn
  rw [spearmanSq_eq L h]
  have : 0 ≤ 12 * tieCorr L / ((L.sum : ℚ) ^ 3 - L.sum) := by
    apply div_nonneg _ (le_of_lt hden)
    have := tieCorr_nonneg L; linarith
  linarith

theorem spearmanSq_nonneg (L : List ℕ) : 0 ≤ spearmanSq L := by
  rcases le_or_gt (ssS (gmean L) L 0) 0 with h | h
  · have h0 : ssS (gmean L) L 0 = 0 := by
      have := ssS_eq_ssR_add (gmean L) L 0
      have h1 := ssR_nonneg (gmean L) L 0
      have h2 := tieCorr_nonneg L
      linarith
    simp [spearmanSq, h0]
  · exact div_nonneg (ssR_nonneg _ _ _) (le_of_lt h)

/-- Equality in the tie-attenuation law holds precisely when the statistic has no ties. -/
theorem spearmanSq_eq_one_iff (L : List ℕ) (h : 2 ≤ L.sum) :
    spearmanSq L = 1 ↔ ∀ m ∈ L, m ≤ 1 := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - L.sum := cube_sub_self_pos hn
  rw [spearmanSq_eq L h, ← tieCorr_eq_zero_iff]
  constructor
  · intro hEq
    have hzero : 12 * tieCorr L / ((L.sum : ℚ) ^ 3 - L.sum) = 0 := by linarith
    have h12 : 12 * tieCorr L = 0 :=
      (div_eq_zero_iff.1 hzero).resolve_right (by linarith)
    linarith
  · intro hEq; rw [hEq]; simp

/-! ## 3. The Spearman coefficient itself (real-valued) -/

/-- Spearman's rank correlation `Cov(R,S)/(σ_R σ_S)` of a tie profile against a refining
response. -/
noncomputable def spearman (L : List ℕ) : ℝ :=
  (sp (gmean L) L 0 : ℝ) /
    (Real.sqrt ((ssR (gmean L) L 0 : ℚ) : ℝ) * Real.sqrt ((ssS (gmean L) L 0 : ℚ) : ℝ))

theorem spearman_eq_sqrt (L : List ℕ) (h : 2 ≤ L.sum) :
    spearman L = Real.sqrt ((spearmanSq L : ℚ) : ℝ) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hSpos : (0 : ℚ) < ssS (gmean L) L 0 := by
    rw [ssS_total]
    have := cube_sub_self_pos hn
    linarith
  set a : ℝ := ((ssR (gmean L) L 0 : ℚ) : ℝ) with ha
  set s : ℝ := ((ssS (gmean L) L 0 : ℚ) : ℝ) with hs
  have ha0 : 0 ≤ a := by rw [ha]; exact_mod_cast ssR_nonneg (gmean L) L 0
  have hs0 : 0 < s := by rw [hs]; exact_mod_cast hSpos
  have hq : ((spearmanSq L : ℚ) : ℝ) = a / s := by
    rw [spearmanSq]; push_cast; rfl
  have hsp : (sp (gmean L) L 0 : ℝ) = a := by rw [ha, sp_eq_ssR]
  rw [spearman, hsp, hq, Real.sqrt_div ha0, ← ha, ← hs]
  rcases eq_or_lt_of_le ha0 with h0 | h0
  · rw [← h0]; simp
  · rw [div_eq_div_iff]
    · nlinarith [Real.sq_sqrt ha0, Real.sqrt_nonneg a, Real.sqrt_nonneg s,
        Real.sqrt_pos.2 hs0, Real.sq_sqrt (le_of_lt hs0)]
    · positivity
    · exact ne_of_gt (Real.sqrt_pos.2 hs0)

theorem spearman_le_one (L : List ℕ) (h : 2 ≤ L.sum) : spearman L ≤ 1 := by
  rw [spearman_eq_sqrt L h]
  have : ((spearmanSq L : ℚ) : ℝ) ≤ 1 := by exact_mod_cast spearmanSq_le_one L h
  calc Real.sqrt ((spearmanSq L : ℚ) : ℝ) ≤ Real.sqrt 1 := Real.sqrt_le_sqrt this
    _ = 1 := Real.sqrt_one

/-- The dial reads a perfect `1` exactly when the zero-count statistic is tie-free. -/
theorem spearman_eq_one_iff (L : List ℕ) (h : 2 ≤ L.sum) :
    spearman L = 1 ↔ ∀ m ∈ L, m ≤ 1 := by
  rw [spearman_eq_sqrt L h, ← spearmanSq_eq_one_iff L h]
  constructor
  · intro hEq
    have h1 : ((spearmanSq L : ℚ) : ℝ) = 1 := by
      have := congrArg (fun x : ℝ => x ^ 2) hEq
      simpa [Real.sq_sqrt (by exact_mod_cast spearmanSq_nonneg L : (0:ℝ) ≤ ((spearmanSq L : ℚ):ℝ))]
        using this
    exact_mod_cast h1
  · intro hEq; rw [hEq]; simp

/-! ## 4. The dyadic tie profile of trailing-zero counts -/

/-- Tie profile of the trailing-zero statistic on `{0, …, 2^b - 1}`:
blocks of sizes `2^(b-1), 2^(b-2), …, 2, 1` followed by the singleton `{0}`. -/
def dyadicBlocks : ℕ → List ℕ
  | 0 => [1]
  | b + 1 => 2 ^ b :: dyadicBlocks b

lemma dyadicBlocks_sum (b : ℕ) : (dyadicBlocks b).sum = 2 ^ b := by
  induction b with
  | zero => simp [dyadicBlocks]
  | succ k ih => simp [dyadicBlocks, ih, pow_succ]; ring

/-- Cube of a power of two. -/
lemma pow_two_cube (k : ℕ) : ((2 : ℚ) ^ k) ^ 3 = 8 ^ k := by
  rw [← pow_mul, mul_comm, pow_mul]; norm_num

lemma tieCorr_dyadic (b : ℕ) :
    12 * tieCorr (dyadicBlocks b) = ((8 : ℚ) ^ b - 1) / 7 - (2 ^ b - 1) := by
  induction b with
  | zero => norm_num [dyadicBlocks, tieCorr]
  | succ k ih =>
      rw [dyadicBlocks, tieCorr_cons, mul_add, ih]
      push_cast
      rw [pow_succ (8 : ℚ) k, pow_succ (2 : ℚ) k]
      linarith [pow_two_cube k]

/-- **Exact tie ceiling for uniform `b`-bit draws.**  With the 2-adic tie profile, the largest
Spearman coefficient attainable against any refining response satisfies
`ρ² = (6/7)·(1 + 1/(2^b(2^b+1)))`. -/
theorem dyadic_spearmanSq (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (dyadicBlocks b) = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ b * (2 ^ b + 1))) := by
  have hsum : (dyadicBlocks b).sum = 2 ^ b := dyadicBlocks_sum b
  have h2 : 2 ≤ (dyadicBlocks b).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := by
          apply pow_le_pow_right₀ (by norm_num) hb
  have hcast : (((dyadicBlocks b).sum : ℕ) : ℚ) = (2 : ℚ) ^ b := by rw [hsum]; push_cast; ring
  rw [spearmanSq_eq _ h2, hcast]
  have htc : 12 * tieCorr (dyadicBlocks b)
      = (((2 : ℚ) ^ b) ^ 3 - 1) / 7 - ((2 : ℚ) ^ b - 1) := by
    rw [tieCorr_dyadic b, pow_two_cube b]
  rw [htc]
  set x : ℚ := (2 : ℚ) ^ b with hxdef
  have h1 : x ≠ 0 := by linarith
  have h2' : x + 1 ≠ 0 := by linarith
  have h3 : x - 1 ≠ 0 := by intro hcon; linarith
  have hx3 : x ^ 3 - x = x * (x - 1) * (x + 1) := by ring
  rw [hx3]
  field_simp
  ring

/-- The tie ceiling is strictly decreasing in the bitlen. -/
theorem dyadic_ceiling_strict_anti {b c : ℕ} (hb : 1 ≤ b) (hbc : b < c) :
    spearmanSq (dyadicBlocks c) < spearmanSq (dyadicBlocks b) := by
  have hc : 1 ≤ c := le_trans hb (le_of_lt hbc)
  rw [dyadic_spearmanSq b hb, dyadic_spearmanSq c hc]
  have h1 : (0 : ℚ) < (2 : ℚ) ^ b := by positivity
  have h2 : (2 : ℚ) ^ b < (2 : ℚ) ^ c := by
    exact pow_lt_pow_right₀ (by norm_num) hbc
  have hlt : (2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1) < (2 : ℚ) ^ c * ((2 : ℚ) ^ c + 1) := by nlinarith
  have hpos : (0 : ℚ) < (2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1) := by positivity
  have := one_div_lt_one_div_of_lt hpos hlt
  linarith

/-- The tie ceiling always exceeds `6/7`; the limiting ceiling is `ρ = √(6/7) ≈ 0.92582`. -/
theorem dyadic_ceiling_gt (b : ℕ) (hb : 1 ≤ b) : 6 / 7 < spearmanSq (dyadicBlocks b) := by
  rw [dyadic_spearmanSq b hb]
  have hpos : (0 : ℚ) < (2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1) := by positivity
  have : (0 : ℚ) < 1 / ((2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1)) := by positivity
  linarith

/-- Quantitative convergence: the ceiling is within `4^{-b}` of `6/7`. -/
theorem dyadic_ceiling_close (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (dyadicBlocks b) - 6 / 7 < (1 / 4 : ℚ) ^ b := by
  rw [dyadic_spearmanSq b hb]
  have h4 : (0 : ℚ) < (4 : ℚ) ^ b := by positivity
  have hsq : ((2 : ℚ) ^ b) ^ 2 = 4 ^ b := by rw [← pow_mul, mul_comm, pow_mul]; norm_num
  have hpos : (0 : ℚ) < (2 : ℚ) ^ b := by positivity
  have hgt : (4 : ℚ) ^ b < (2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1) := by nlinarith
  have hinv : 1 / ((2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1)) < 1 / (4 : ℚ) ^ b :=
    one_div_lt_one_div_of_lt h4 hgt
  have hkey : (6 / 7 : ℚ) * (1 / ((2 : ℚ) ^ b * (2 ^ b + 1))) < 1 / (4 : ℚ) ^ b := by
    have hpos' : (0 : ℚ) < 1 / ((2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1)) := by positivity
    nlinarith
  have hpow : (1 / 4 : ℚ) ^ b = 1 / (4 : ℚ) ^ b := by rw [div_pow]; norm_num
  rw [hpow]
  linarith

/-! ## 5. Arithmetic bridge: the tie blocks really are the 2-adic ones -/

/-- The `k`-th trailing-zero block of `{0, …, 2^b - 1}`. -/
def twoAdicBlock (b k : ℕ) : Finset ℕ :=
  (range (2 ^ b)).filter fun x => 2 ^ k ∣ x ∧ ¬ 2 ^ (k + 1) ∣ x

/-- **Block cardinality.**  Exactly `2^(b-1-k)` of the integers below `2^b` have precisely `k`
trailing binary zeros. -/
theorem card_two_adic_block (b k : ℕ) (hk : k < b) :
    (twoAdicBlock b k).card = 2 ^ (b - 1 - k) := by
  have himg : twoAdicBlock b k
      = (range (2 ^ (b - 1 - k))).image fun m => 2 ^ k * (2 * m + 1) := by
    ext x
    simp only [twoAdicBlock, mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hx, ⟨u, rfl⟩, hnd⟩
      have hu : ¬ (2 ∣ u) := by
        rintro ⟨v, rfl⟩
        exact hnd ⟨v, by ring⟩
      obtain ⟨m, rfl⟩ : ∃ m, u = 2 * m + 1 := by
        rcases Nat.even_or_odd u with he | ho
        · exact absurd he.two_dvd hu
        · exact ⟨u / 2, by omega⟩
      refine ⟨m, ?_, rfl⟩
      have hb : b = k + 1 + (b - 1 - k) := by omega
      rw [hb, pow_add] at hx
      have h2 : 2 ^ (k + 1) = 2 ^ k * 2 := by rw [pow_succ]
      rw [h2] at hx
      have hpk : 0 < 2 ^ k := pow_pos (by norm_num) k
      nlinarith [hx, hpk]
    · rintro ⟨m, hm, rfl⟩
      have hpk : 0 < 2 ^ k := pow_pos (by norm_num) k
      refine ⟨?_, ⟨2 * m + 1, rfl⟩, ?_⟩
      · have hb : b = k + 1 + (b - 1 - k) := by omega
        rw [hb, pow_add, pow_succ]
        nlinarith [hm, hpk]
      · rintro ⟨v, hv⟩
        rw [pow_succ] at hv
        have hv' : 2 ^ k * (2 * m + 1) = 2 ^ k * (2 * v) := by rw [hv]; ring
        have := Nat.eq_of_mul_eq_mul_left hpk hv'
        omega
  rw [himg, card_image_of_injective _ ?_, card_range]
  intro a b hab
  have hpk : 0 < 2 ^ k := pow_pos (by norm_num) k
  simp only at hab
  nlinarith [hab, hpk]

/-- The dyadic profile is literally the list of 2-adic block sizes, capped by the singleton
block `{0}`. -/
theorem dyadicBlocks_eq_valuation_profile (b : ℕ) :
    dyadicBlocks b = ((List.range b).map fun k => (twoAdicBlock b k).card) ++ [1] := by
  have hcard : ∀ k ∈ List.range b, (twoAdicBlock b k).card = 2 ^ (b - 1 - k) := by
    intro k hk
    exact card_two_adic_block b k (List.mem_range.1 hk)
  rw [List.map_congr_left hcard]
  clear hcard
  induction b with
  | zero => simp [dyadicBlocks]
  | succ n ih =>
      rw [dyadicBlocks, List.range_succ_eq_map, List.map_cons, List.map_map, List.cons_append]
      simp only [Nat.succ_sub_one, Nat.sub_zero]
      congr 1
      have hfun : ((fun a => 2 ^ (n - a)) ∘ Nat.succ) = (fun k : ℕ => 2 ^ (n - 1 - k)) := by
        funext k
        simp only [Function.comp_apply]
        congr 1
        omega
      rw [hfun]
      exact ih

/-- The 2-adic blocks together with `{0}` exhaust `{0, …, 2^b - 1}`: the profile sums to `2^b`. -/
theorem two_adic_profile_sum (b : ℕ) :
    (((List.range b).map fun k => (twoAdicBlock b k).card) ++ [1]).sum = 2 ^ b := by
  rw [← dyadicBlocks_eq_valuation_profile b]; exact dyadicBlocks_sum b

/-! ## 6. The recorded round-61 measurement, checked against the theory -/

/-- Recorded Spearman values (three seeds and the pooled estimate) at bitlen 64. -/
def seed40 : ℚ := 658 / 1000
def seed41 : ℚ := 642 / 1000
def seed42 : ℚ := 643 / 1000
def pooled : ℚ := 648 / 1000
def ciLow : ℚ := 629 / 1000
def ciHigh : ℚ := 665 / 1000
/-- The bitlen-44 anchor of the validation grid. -/
def dial44 : ℚ := 78 / 100

/-- All recorded readings lie strictly inside the validation band `[0.55, 0.85]`. -/
theorem u64_inside_band :
    (55 / 100 : ℚ) < seed40 ∧ seed40 < 85 / 100 ∧
    (55 / 100 : ℚ) < seed41 ∧ seed41 < 85 / 100 ∧
    (55 / 100 : ℚ) < seed42 ∧ seed42 < 85 / 100 ∧
    (55 / 100 : ℚ) < pooled ∧ pooled < 85 / 100 ∧
    (55 / 100 : ℚ) < ciLow ∧ ciHigh < 85 / 100 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [seed40, seed41, seed42, pooled, ciLow, ciHigh]

/-- The pooled estimate is the ordinary mean of the three seeds up to `5·10⁻⁴`
(the exact discrepancy is `1/3000 ≈ 3.34·10⁻⁴`, i.e. pure rounding of the reported digits). -/
theorem pooled_is_seed_mean :
    |pooled - (seed40 + seed41 + seed42) / 3| < 5 / 10000 := by
  rw [abs_lt]
  constructor <;> norm_num [pooled, seed40, seed41, seed42]

/-- The measurement sits strictly below the exact 2-adic tie ceiling at bitlen 64: the dial
has genuine headroom, so the reading is not a ceiling artefact. -/
theorem u64_below_tie_ceiling : pooled ^ 2 < spearmanSq (dyadicBlocks 64) := by
  have h := dyadic_ceiling_gt 64 (by norm_num)
  have : pooled ^ 2 < 6 / 7 := by norm_num [pooled]
  linarith

/-- Every recorded seed reading is below the tie ceiling as well. -/
theorem u64_seeds_below_tie_ceiling :
    seed40 ^ 2 < spearmanSq (dyadicBlocks 64) ∧
    seed41 ^ 2 < spearmanSq (dyadicBlocks 64) ∧
    seed42 ^ 2 < spearmanSq (dyadicBlocks 64) := by
  have h := dyadic_ceiling_gt 64 (by norm_num)
  have h40 : seed40 ^ 2 < 6 / 7 := by norm_num [seed40]
  have h41 : seed41 ^ 2 < 6 / 7 := by norm_num [seed41]
  have h42 : seed42 ^ 2 < 6 / 7 := by norm_num [seed42]
  exact ⟨by linarith, by linarith, by linarith⟩

/-- **Tie-ceiling insufficiency.**  Between bitlen 44 and bitlen 64 the exact tie ceiling drops by
less than `10⁻²⁶`, whereas the recorded dial drops by more than `0.18` in `ρ²`.  Therefore the
observed monotone decline of the zero-fit dial cannot be an artefact of tie granularity. -/
theorem tie_ceiling_insufficient :
    0 < spearmanSq (dyadicBlocks 44) - spearmanSq (dyadicBlocks 64) ∧
    spearmanSq (dyadicBlocks 44) - spearmanSq (dyadicBlocks 64) < 1 / 10 ^ 26 ∧
    18 / 100 < dial44 ^ 2 - pooled ^ 2 := by
  refine ⟨?_, ?_, ?_⟩
  · have := dyadic_ceiling_strict_anti (b := 44) (c := 64) (by norm_num) (by norm_num)
    linarith
  · have h1 : spearmanSq (dyadicBlocks 44) - 6 / 7 < (1 / 4 : ℚ) ^ 44 :=
      dyadic_ceiling_close 44 (by norm_num)
    have h2 : 6 / 7 < spearmanSq (dyadicBlocks 64) := dyadic_ceiling_gt 64 (by norm_num)
    have h3 : ((1 : ℚ) / 4) ^ 44 < 1 / 10 ^ 26 := by norm_num
    linarith
  · norm_num [dial44, pooled]

/-- **Count parity.**  With the H2 baseline `β = 0.580`, the strict `+0.05` bar is cleared by all
three seed point estimates and by the pooled point estimate, but the pooled CI lower bound clears
only `+0.049` — missing the bar by exactly `0.001`.  This is the recorded "count parity" verdict:
point-estimate evidence passes, interval evidence does not. -/
theorem count_parity_gap :
    let base : ℚ := 580 / 1000
    let bar : ℚ := base + 5 / 100
    base + 5 / 100 ≤ seed40 ∧ base + 5 / 100 ≤ seed41 ∧ base + 5 / 100 ≤ seed42 ∧
    base + 5 / 100 ≤ pooled ∧
    ciLow < bar ∧ ciLow - base = 49 / 1000 ∧ bar - ciLow = 1 / 1000 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [seed40, seed41, seed42, pooled, ciLow]

/-- **Majority-versus-pooled bound.**  If two of three seed readings clear a bar `τ` and the third
is at least the band floor `lo`, then the pooled (mean) reading cannot fall below
`τ - (τ - lo)/3`.  So a "count parity" verdict — majority passes, pooled fails — is confined to a
window of width `(τ - lo)/3`; it can never be a gross discordance. -/
theorem majority_pooled_bound (a b c tau lo : ℚ) (hlo : lo ≤ a) (hb : tau ≤ b) (hc : tau ≤ c) :
    tau - (tau - lo) / 3 ≤ (a + b + c) / 3 := by
  linarith

/-- Applied to the recorded round-61 numbers with band floor `0.55` and bar `0.63`: the pooled
value could not have fallen below `0.6033…`, and in fact reads `0.648`. -/
theorem u64_majority_pooled_window :
    (63 / 100 : ℚ) - ((63 / 100 : ℚ) - 55 / 100) / 3 ≤ (seed40 + seed41 + seed42) / 3 ∧
      (seed40 + seed41 + seed42) / 3 < pooled + 1 / 1000 := by
  constructor
  · apply majority_pooled_bound <;> norm_num [seed40, seed41, seed42]
  · norm_num [seed40, seed41, seed42, pooled]

/-!
## Lab notes (exp 530, seeds 20261140–42)

Recorded measurement (uniform draws, bitlen 64):

| seed | Spearman(T, rate) |
|---|---|
| 20261140 | 0.658 |
| 20261141 | 0.642 |
| 20261142 | 0.643 |
| pooled | 0.648, CI [0.629, 0.665] |

Validation band `[0.55, 0.85]`: all four readings inside (`u64_inside_band`).
H2 bar `baseline + 0.05` with baseline `0.580`: cleared by all three point estimates and
by the pooled point estimate; the pooled CI lower bound clears only `+0.049`, missing the
bar by `0.001` — the recorded *count parity* verdict (`count_parity_gap`).

Exact-rational cross-checks performed while developing this file (Lean `#eval`, exact `ℚ`):

| tie profile | brute-force `ρ²` | closed form `1 - 12T/(n³-n)` |
|---|---|---|
| `[2,1,1]` | 9/10 | 9/10 |
| `[4,2,1,1]` | 73/84 | 73/84 |
| `[3,3,3]` | 9/10 | 9/10 |
| `[5,2,2,1]` | 13/15 | 13/15 |
| `[8,4,2,1,1]` | 117/136 | 117/136 |
| `[2,2,2,2]` | 20/21 | 20/21 |
| `[6,1,1,1,1]` | 26/33 | 26/33 |

Dyadic ceiling `ρ` by bitlen: `b=2: 0.948683`, `b=3: 0.932227`, `b=4: 0.927520`,
`b=8: 0.925827`, `b=16, 44, 64: 0.925820…` — monotone decline to `√(6/7) = 0.9258200…`,
total movement above `b = 16` smaller than `10⁻¹⁰`.  The recorded dial moves by `0.13`
over the same range, which is the content of `tie_ceiling_insufficient`.
-/

end Catalog.Novelty.ZeroFitDialU64