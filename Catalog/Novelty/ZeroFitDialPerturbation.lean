import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialU76

/-!
# The corruption budget: how much re-ranking a dial move costs

Cycle 2 of the round-65 (bitlen-76) investigation.

`Novelty.ZeroFitDialU76` proves that the *tie geometry* of the zero-count statistic
is flat: between bitlen 72 and bitlen 76 the attainable Spearman ceiling moves by
less than `10^{-43}`, and between bitlen 64 and 76 by less than `10^{-30}` times the
recorded drop `0.648 → 0.608`.  So whatever moves the dial is not tie granularity —
it must act on the *ranks themselves*.

This file quantifies that alternative.  Working with raw rank vectors
`R, S : Fin n → ℚ` and the Spearman coefficient in `d²` form
`ρ = 1 - 6·Σᵢ(Rᵢ-Sᵢ)²/(n³-n)`, we prove:

* `sumSqD_sub_eq` — localisation: if `S` and `S'` agree off a set `A`, the `Σd²`
  difference is supported on `A`;
* `abs_sumSqD_sub_le` — each disagreeing coordinate can move `Σd²` by at most
  `(n-1)²`, hence `|Σd²(R,S) - Σd²(R,S')| ≤ |A|(n-1)²`;
* `abs_rho_sub_le` and `abs_rho_sub_le_div` — the **rank-perturbation Lipschitz law**
  `|ρ(R,S) - ρ(R,S')| ≤ 6|A|(n-1)/(n(n+1)) ≤ 6|A|/n`;
* `corruption_budget` — the contrapositive **budget law**: a dial move of size `δ`
  requires at least `δn/6` re-ranked observations;
* `u76_corruption_budget` — applied to the recorded `0.648 → 0.608` drop: at least
  `n/150` of the sample (0.67%) must be re-ranked;
* `sumSqD_swap_exact` and `rho_swap_exact` — sharpness: a single transposition
  changes `Σd²` by *exactly* `-2(Rᵢ-Rⱼ)(Sᵢ-Sⱼ)`, and transposing the two extreme
  ranks realises the per-coordinate bound `(n-1)²` exactly, so the Lipschitz law
  above is tight up to the constant 2.

Nothing here assumes the ranks come from any particular statistic: the bound holds
for *every* mechanism acting by re-ranking, which is what makes it a budget.
-/

open Finset

namespace Catalog.Novelty.ZeroFitDialPerturbation

/-- `n³ - n > 0` for a sample of size at least two. -/
lemma cube_sub_self_pos' {n : ℕ} (hn : 2 ≤ n) : (0 : ℚ) < (n : ℚ) ^ 3 - (n : ℚ) := by
  have hnq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hfac : (n : ℚ) ^ 3 - (n : ℚ) = (n : ℚ) * ((n : ℚ) - 1) * ((n : ℚ) + 1) := by ring
  rw [hfac]
  exact mul_pos (mul_pos (by linarith) (by linarith)) (by linarith)

/-- The Spearman `Σd²` statistic of two rank vectors. -/
def sumSqD {n : ℕ} (R S : Fin n → ℚ) : ℚ := ∑ i, (R i - S i) ^ 2

/-- Spearman's rank correlation in `d²` form. -/
def rhoRank {n : ℕ} (R S : Fin n → ℚ) : ℚ := 1 - 6 * sumSqD R S / ((n : ℚ) ^ 3 - n)

/-- `R` is a rank vector: all its entries lie in `[1, n]`. -/
def IsRankVec (n : ℕ) (R : Fin n → ℚ) : Prop := ∀ i, 1 ≤ R i ∧ R i ≤ (n : ℚ)

/-! ## 1. Localisation and the per-coordinate bound -/

/-- If two response vectors agree off a set `A`, the `Σd²` difference is supported on `A`. -/
theorem sumSqD_sub_eq {n : ℕ} (R S S' : Fin n → ℚ) (A : Finset (Fin n))
    (hagree : ∀ i ∉ A, S i = S' i) :
    sumSqD R S - sumSqD R S' = ∑ i ∈ A, ((R i - S i) ^ 2 - (R i - S' i) ^ 2) := by
  have hsplit : ∑ i ∈ A, ((R i - S i) ^ 2 - (R i - S' i) ^ 2)
      = ∑ i ∈ (univ : Finset (Fin n)), ((R i - S i) ^ 2 - (R i - S' i) ^ 2) := by
    refine Finset.sum_subset (Finset.subset_univ A) ?_
    intro i _ hi
    rw [hagree i hi]
    ring
  rw [hsplit, Finset.sum_sub_distrib]
  rfl

/-- A single coordinate can move `Σd²` by at most `(n-1)²`. -/
theorem abs_term_le {n : ℕ} (a s s' : ℚ) (ha : 1 ≤ a ∧ a ≤ (n : ℚ))
    (hs : 1 ≤ s ∧ s ≤ (n : ℚ)) (hs' : 1 ≤ s' ∧ s' ≤ (n : ℚ)) :
    |(a - s) ^ 2 - (a - s') ^ 2| ≤ ((n : ℚ) - 1) ^ 2 := by
  obtain ⟨ha1, ha2⟩ := ha
  obtain ⟨hs1, hs2⟩ := hs
  obtain ⟨hs1', hs2'⟩ := hs'
  rw [abs_le]
  constructor <;> nlinarith [sq_nonneg (a - s), sq_nonneg (a - s'), sq_nonneg (s - s')]

/-- **Localised stability of `Σd²`.**  Changing the response ranking on a set `A`
moves `Σd²` by at most `|A|·(n-1)²`. -/
theorem abs_sumSqD_sub_le {n : ℕ} (R S S' : Fin n → ℚ) (hR : IsRankVec n R)
    (hS : IsRankVec n S) (hS' : IsRankVec n S') (A : Finset (Fin n))
    (hagree : ∀ i ∉ A, S i = S' i) :
    |sumSqD R S - sumSqD R S'| ≤ (A.card : ℚ) * ((n : ℚ) - 1) ^ 2 := by
  rw [sumSqD_sub_eq R S S' A hagree]
  calc |∑ i ∈ A, ((R i - S i) ^ 2 - (R i - S' i) ^ 2)|
      ≤ ∑ i ∈ A, |(R i - S i) ^ 2 - (R i - S' i) ^ 2| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i ∈ A, ((n : ℚ) - 1) ^ 2 := by
        refine Finset.sum_le_sum ?_
        intro i _
        exact abs_term_le (R i) (S i) (S' i) (hR i) (hS i) (hS' i)
    _ = (A.card : ℚ) * ((n : ℚ) - 1) ^ 2 := by
        rw [Finset.sum_const, nsmul_eq_mul]

/-! ## 2. The rank-perturbation Lipschitz law -/

/-- **Rank-perturbation Lipschitz law.**  Re-ranking the response on a set `A` moves
Spearman's `ρ` by at most `6|A|(n-1)/(n(n+1))`. -/
theorem abs_rho_sub_le {n : ℕ} (hn : 2 ≤ n) (R S S' : Fin n → ℚ) (hR : IsRankVec n R)
    (hS : IsRankVec n S) (hS' : IsRankVec n S') (A : Finset (Fin n))
    (hagree : ∀ i ∉ A, S i = S' i) :
    |rhoRank R S - rhoRank R S'|
      ≤ 6 * (A.card : ℚ) * ((n : ℚ) - 1) ^ 2 / ((n : ℚ) ^ 3 - n) := by
  have hnq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hden : (0 : ℚ) < (n : ℚ) ^ 3 - n := cube_sub_self_pos' hn
  have hdiff : rhoRank R S - rhoRank R S'
      = 6 * (sumSqD R S' - sumSqD R S) / ((n : ℚ) ^ 3 - n) := by
    rw [rhoRank, rhoRank]
    field_simp
    ring
  rw [hdiff, abs_div, abs_of_pos hden, div_le_div_iff_of_pos_right hden]
  have hbase := abs_sumSqD_sub_le R S S' hR hS hS' A hagree
  have hsym : |sumSqD R S' - sumSqD R S| = |sumSqD R S - sumSqD R S'| := abs_sub_comm _ _
  calc |6 * (sumSqD R S' - sumSqD R S)| = 6 * |sumSqD R S' - sumSqD R S| := by
        rw [abs_mul]; norm_num
    _ = 6 * |sumSqD R S - sumSqD R S'| := by rw [hsym]
    _ ≤ 6 * ((A.card : ℚ) * ((n : ℚ) - 1) ^ 2) := by linarith
    _ = 6 * (A.card : ℚ) * ((n : ℚ) - 1) ^ 2 := by ring

/-- The clean form of the Lipschitz law: `|Δρ| ≤ 6|A|/n`. -/
theorem abs_rho_sub_le_div {n : ℕ} (hn : 2 ≤ n) (R S S' : Fin n → ℚ) (hR : IsRankVec n R)
    (hS : IsRankVec n S) (hS' : IsRankVec n S') (A : Finset (Fin n))
    (hagree : ∀ i ∉ A, S i = S' i) :
    |rhoRank R S - rhoRank R S'| ≤ 6 * (A.card : ℚ) / (n : ℚ) := by
  have hnq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hden : (0 : ℚ) < (n : ℚ) ^ 3 - n := cube_sub_self_pos' hn
  have hcard : (0 : ℚ) ≤ (A.card : ℚ) := by positivity
  have h1 := abs_rho_sub_le hn R S S' hR hS hS' A hagree
  have h2 : 6 * (A.card : ℚ) * ((n : ℚ) - 1) ^ 2 / ((n : ℚ) ^ 3 - n)
      ≤ 6 * (A.card : ℚ) / (n : ℚ) := by
    rw [div_le_div_iff₀ hden (by linarith)]
    nlinarith [mul_nonneg hcard (sub_nonneg.mpr hnq)]
  linarith

/-! ## 3. The budget law -/

/-- **Corruption budget.**  A rank-level mechanism that moves the dial by `δ` must
re-rank at least `δn/6` of the sample.  (Contrapositive of the Lipschitz law.) -/
theorem corruption_budget {n : ℕ} (hn : 2 ≤ n) (R S S' : Fin n → ℚ) (hR : IsRankVec n R)
    (hS : IsRankVec n S) (hS' : IsRankVec n S') (A : Finset (Fin n))
    (hagree : ∀ i ∉ A, S i = S' i) (delta : ℚ)
    (hdelta : delta ≤ |rhoRank R S - rhoRank R S'|) :
    delta * (n : ℚ) / 6 ≤ (A.card : ℚ) := by
  have hnq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have h := abs_rho_sub_le_div hn R S S' hR hS hS' A hagree
  have hle : delta ≤ 6 * (A.card : ℚ) / (n : ℚ) := le_trans hdelta h
  rw [le_div_iff₀ (by linarith)] at hle
  linarith

/-- **Applied budget for the recorded bitlen 64 → 76 drop.**  The dial fell from
`0.648` to `0.608`, i.e. by `δ = 0.04`.  By the budget law any rank-level mechanism
producing that drop must re-rank at least `n/150` of the sample — a *fixed positive
fraction*, not a vanishing one.  Together with `dial_flat_72_76` this pins the cause
of the bitlen dependence: not tie geometry, but a mechanism touching ≳ 0.67% of draws. -/
theorem u76_corruption_budget {n : ℕ} (hn : 2 ≤ n) (R S S' : Fin n → ℚ) (hR : IsRankVec n R)
    (hS : IsRankVec n S) (hS' : IsRankVec n S') (A : Finset (Fin n))
    (hagree : ∀ i ∉ A, S i = S' i)
    (hdrop : Catalog.Novelty.ZeroFitDialU64.pooled - Catalog.Novelty.ZeroFitDialU76.pooled76
      ≤ |rhoRank R S - rhoRank R S'|) :
    (n : ℚ) / 150 ≤ (A.card : ℚ) := by
  have hval : Catalog.Novelty.ZeroFitDialU64.pooled
      - Catalog.Novelty.ZeroFitDialU76.pooled76 = 4 / 100 := by
    norm_num [Catalog.Novelty.ZeroFitDialU64.pooled, Catalog.Novelty.ZeroFitDialU76.pooled76]
  rw [hval] at hdrop
  have h := corruption_budget hn R S S' hR hS hS' A hagree (4 / 100) hdrop
  linarith

/-! ## 4. Sharpness: the exact transposition increment -/

/-- **Exact transposition increment.**  Swapping the response ranks of two observations
changes `Σd²` by exactly `-2(Rᵢ-Rⱼ)(Sᵢ-Sⱼ)`. -/
theorem sumSqD_swap_exact {n : ℕ} (R S S' : Fin n → ℚ) (i j : Fin n) (hij : i ≠ j)
    (hi : S' i = S j) (hj : S' j = S i) (hrest : ∀ k, k ≠ i → k ≠ j → S k = S' k) :
    sumSqD R S - sumSqD R S' = -2 * (R i - R j) * (S i - S j) := by
  have hagree : ∀ k ∉ ({i, j} : Finset (Fin n)), S k = S' k := by
    intro k hk
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hk
    exact hrest k hk.1 hk.2
  rw [sumSqD_sub_eq R S S' ({i, j} : Finset (Fin n)) hagree,
    Finset.sum_insert (by simpa using hij), Finset.sum_singleton, hi, hj]
  ring

/-- The transposition increment is maximal — equal to `2(n-1)²` — when the two swapped
observations carry the extreme ranks `1` and `n` on both sides.  Hence the constant in
`abs_sumSqD_sub_le` is sharp up to the factor `2` coming from `|A| = 2`. -/
theorem sumSqD_swap_extreme {n : ℕ} (R S S' : Fin n → ℚ) (i j : Fin n) (hij : i ≠ j)
    (hi : S' i = S j) (hj : S' j = S i) (hrest : ∀ k, k ≠ i → k ≠ j → S k = S' k)
    (hRi : R i = 1) (hRj : R j = (n : ℚ)) (hSi : S i = 1) (hSj : S j = (n : ℚ)) :
    sumSqD R S' - sumSqD R S = 2 * ((n : ℚ) - 1) ^ 2 := by
  have h := sumSqD_swap_exact R S S' i j hij hi hj hrest
  rw [hRi, hRj, hSi, hSj] at h
  nlinarith [h]

/-- The corresponding exact change in `ρ`: one extreme transposition moves the
coefficient by `12(n-1)/(n(n+1))`, i.e. `Θ(1/n)`, matching the Lipschitz law's rate. -/
theorem rho_swap_exact {n : ℕ} (hn : 2 ≤ n) (R S S' : Fin n → ℚ) (i j : Fin n) (hij : i ≠ j)
    (hi : S' i = S j) (hj : S' j = S i) (hrest : ∀ k, k ≠ i → k ≠ j → S k = S' k)
    (hRi : R i = 1) (hRj : R j = (n : ℚ)) (hSi : S i = 1) (hSj : S j = (n : ℚ)) :
    rhoRank R S - rhoRank R S' = 12 * ((n : ℚ) - 1) / ((n : ℚ) * ((n : ℚ) + 1)) := by
  have hnq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hd := sumSqD_swap_extreme R S S' i j hij hi hj hrest hRi hRj hSi hSj
  have hden : (0 : ℚ) < (n : ℚ) ^ 3 - n := cube_sub_self_pos' hn
  have hne : ((n : ℚ) ^ 3 - n) ≠ 0 := ne_of_gt hden
  have hn0 : (n : ℚ) ≠ 0 := by positivity
  have hn1 : (n : ℚ) + 1 ≠ 0 := by positivity
  have hfac : (n : ℚ) ^ 3 - n = (n : ℚ) * ((n : ℚ) + 1) * ((n : ℚ) - 1) := by ring
  have hnm : (n : ℚ) - 1 ≠ 0 := ne_of_gt (by linarith)
  rw [rhoRank, rhoRank]
  have hsub : sumSqD R S' = sumSqD R S + 2 * ((n : ℚ) - 1) ^ 2 := by linarith
  rw [hsub, hfac]
  field_simp
  ring

end Catalog.Novelty.ZeroFitDialPerturbation