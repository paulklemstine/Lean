/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The regret tail: median blindness and the failure of mean-based elimination

Companion to `Probability.PortfolioRegretCore`.  Two phenomena observed in
experiment 560 are isolated and proved here.

* **Median blindness.**  Every scheduling strategy in the experiment had median
  regret ratio exactly `1.000`, while the *mean* regret was large: the loss lives
  entirely in a thin tail.  `median_one_mean_unbounded` shows this is not an
  artifact — for every prescribed level `M` there is a portfolio whose *optimal
  static* strategy has median regret ratio `1` and mean regret ratio `> M`.
  Hence the median is a provably uninformative statistic for portfolio
  selection.

* **Failure of mean-based elimination (the "H3" ledger entry).**  Eliminating a
  portfolio member because its *mean* cost is larger is not a
  dominance-in-distribution argument.  `ev_le_of_stochDom` proves the valid
  direction (stochastic dominance implies a mean inequality, via an exact finite
  layer-cake identity `ev_nat_layercake`), while `mean_lt_not_stochDom` exhibits
  a variance-tail counterexample to the converse.
-/
import Mathlib
import Probability.PortfolioRegretCore

namespace Probability.PortfolioRegret

open Finset

variable {Ω S : Type*}

/-! ## Probabilities, ratios and medians -/

/-- Probability of an event under the weights `w`. -/
def Pr [Fintype Ω] (w : Ω → ℚ) (A : Ω → Prop) [DecidablePred A] : ℚ :=
  ∑ ω ∈ univ.filter A, w ω

/-- Instancewise regret ratio of a fixed strategy against the oracle. -/
noncomputable def regretRatio [Fintype S] [Nonempty S] (cost : Ω → S → ℚ) (s : S) (ω : Ω) : ℚ :=
  cost ω s / oracleCost cost ω

/-- On a two-member portfolio the oracle is the pointwise minimum. -/
theorem oracleCost_fin_two (cost : Ω → Fin 2 → ℚ) (ω : Ω) :
    oracleCost cost ω = min (cost ω 0) (cost ω 1) := by
  refine le_antisymm ?_ (Finset.le_inf' _ _ ?_)
  · exact le_min (Finset.inf'_le _ (mem_univ 0)) (Finset.inf'_le _ (mem_univ 1))
  · intro i _
    fin_cases i
    · exact min_le_left _ _
    · exact min_le_right _ _

/-- The regret ratio is at least one whenever the oracle cost is positive. -/
theorem one_le_regretRatio [Fintype S] [Nonempty S] (cost : Ω → S → ℚ) (s : S) (ω : Ω)
    (hpos : 0 < oracleCost cost ω) : 1 ≤ regretRatio cost s ω := by
  rw [regretRatio, le_div_iff₀ hpos, one_mul]
  exact Finset.inf'_le _ (mem_univ s)

/-- The two-instance tail portfolio at level `M`: strategy `0` ties the oracle on
mass `3/4` but pays `4M+4` on the remaining quarter, while strategy `1` is
uniformly expensive on the bulk. -/
def tailCost (M : ℚ) : Fin 2 → Fin 2 → ℚ := ![![1, 8 * M + 8], ![4 * M + 4, 1]]

/-- The weights of the tail portfolio: `3/4` on the bulk, `1/4` on the tail. -/
def tailW : Fin 2 → ℚ := ![3/4, 1/4]

theorem oracleCost_tailCost {M : ℚ} (hM : 0 ≤ M) (ω : Fin 2) : oracleCost (tailCost M) ω = 1 := by
  fin_cases ω
  · rw [oracleCost_fin_two]
    show min (1 : ℚ) (8 * M + 8) = 1
    exact min_eq_left (by linarith)
  · rw [oracleCost_fin_two]
    show min (4 * M + 4) (1 : ℚ) = 1
    exact min_eq_right (by linarith)

theorem ev_tailCost_zero (M : ℚ) : EV tailW (fun ω => tailCost M ω 0) = M + 7/4 := by
  simp [EV, tailW, tailCost, Fin.sum_univ_two]
  ring

theorem ev_tailCost_one (M : ℚ) : EV tailW (fun ω => tailCost M ω 1) = 6 * M + 25/4 := by
  simp [EV, tailW, tailCost, Fin.sum_univ_two]
  ring

/-- **Median blindness of regret.**  For every level `M` there is a two-instance,
two-member portfolio whose *optimal static* strategy ties the oracle on more than
half of the mass (median regret ratio `1`) and yet has mean regret ratio above
`M`.  No median-based diagnostic can see the tail. -/
theorem median_one_mean_unbounded (M : ℚ) (hM : 0 ≤ M) :
    (∀ ω, 0 ≤ tailW ω) ∧ (∑ ω, tailW ω = 1) ∧
    (∀ ω, 0 < oracleCost (tailCost M) ω) ∧
    bestConstant tailW (tailCost M) = EV tailW (fun ω => tailCost M ω 0) ∧
    1 / 2 ≤ Pr tailW (fun ω => tailCost M ω 0 = oracleCost (tailCost M) ω) ∧
    M < EV tailW (regretRatio (tailCost M) 0) := by
  classical
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro ω; fin_cases ω <;> norm_num [tailW]
  · norm_num [tailW, Fin.sum_univ_two]
  · intro ω; rw [oracleCost_tailCost hM]; norm_num
  · -- the best constant strategy is strategy `0`
    refine le_antisymm (Finset.inf'_le _ (mem_univ 0)) (Finset.le_inf' _ _ ?_)
    intro i _
    fin_cases i
    · exact le_of_eq rfl
    · show EV tailW (fun ω => tailCost M ω 0) ≤ EV tailW (fun ω => tailCost M ω 1)
      rw [ev_tailCost_zero, ev_tailCost_one]; linarith
  · -- the median regret ratio is `1`: strategy `0` ties the oracle on mass `3/4`
    have hfil : (univ.filter
        (fun ω : Fin 2 => tailCost M ω 0 = oracleCost (tailCost M) ω)) = {0} := by
      ext ω
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton,
        oracleCost_tailCost hM]
      fin_cases ω
      · show tailCost M 0 0 = 1 ↔ (0 : Fin 2) = 0
        simp [tailCost]
      · show tailCost M 1 0 = 1 ↔ (1 : Fin 2) = 0
        rw [show tailCost M 1 0 = 4 * M + 4 from rfl]
        constructor
        · intro h; exfalso; linarith
        · intro h; exact absurd h (by decide)
    rw [Pr, hfil]
    norm_num [tailW]
  · -- but the mean regret ratio is `M + 7/4`
    have heq : EV tailW (regretRatio (tailCost M) 0) = M + 7/4 := by
      have hr : regretRatio (tailCost M) 0 = fun ω => tailCost M ω 0 :=
        funext fun ω => by rw [regretRatio, oracleCost_tailCost hM, div_one]
      rw [hr]
      exact ev_tailCost_zero M
    rw [heq]; linarith

/-! ## Layer cake and stochastic dominance -/

/-- Upper tail probability of an `ℕ`-valued cost. -/
def PrGT [Fintype Ω] (w : Ω → ℚ) (X : Ω → ℕ) (t : ℕ) : ℚ :=
  Pr w (fun ω => t < X ω)

/-- `X` is stochastically dominated by `Y`: a genuine dominance-in-distribution
statement, as opposed to a comparison of means. -/
def StochDom [Fintype Ω] (w : Ω → ℚ) (X Y : Ω → ℕ) : Prop :=
  ∀ t : ℕ, PrGT w X t ≤ PrGT w Y t

/-- **Exact finite layer cake.**  For a cost bounded by `B`, the expectation is
the sum of the first `B` upper tail probabilities. -/
theorem ev_nat_layercake [Fintype Ω] (w : Ω → ℚ) (X : Ω → ℕ) (B : ℕ) (hB : ∀ ω, X ω ≤ B) :
    ∑ ω, w ω * (X ω : ℚ) = ∑ t ∈ range B, PrGT w X t := by
  classical
  have hstep : ∀ t : ℕ, PrGT w X t = ∑ ω, if t < X ω then w ω else 0 := by
    intro t; simp [PrGT, Pr, Finset.sum_filter]
  rw [Finset.sum_congr rfl (fun t _ => hstep t), Finset.sum_comm]
  refine Finset.sum_congr rfl fun ω _ => ?_
  have hset : (range B).filter (fun t => t < X ω) = range (X ω) := by
    ext t
    simp only [Finset.mem_filter, Finset.mem_range]
    constructor
    · rintro ⟨-, h⟩; exact h
    · intro h; exact ⟨lt_of_lt_of_le h (hB ω), h⟩
  rw [← Finset.sum_filter, hset, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_comm]

/-- **The valid direction.**  Stochastic dominance implies the mean inequality. -/
theorem ev_le_of_stochDom [Fintype Ω] (w : Ω → ℚ) (X Y : Ω → ℕ) (B : ℕ)
    (hX : ∀ ω, X ω ≤ B) (hY : ∀ ω, Y ω ≤ B) (h : StochDom w X Y) :
    ∑ ω, w ω * (X ω : ℚ) ≤ ∑ ω, w ω * (Y ω : ℚ) := by
  rw [ev_nat_layercake w X B hX, ev_nat_layercake w Y B hY]
  exact Finset.sum_le_sum fun t _ => h t

/-- **The invalid direction (the H3 refutation).**  A strictly smaller mean does
*not* imply dominance in distribution: a two-valued cost with a heavy upper tail
has a smaller mean than a constant cost yet exceeds it with positive probability.
Eliminating a portfolio member on a mean comparison is therefore not a
dominance argument. -/
theorem mean_lt_not_stochDom :
    ∃ (w : Fin 2 → ℚ) (X Y : Fin 2 → ℕ),
      (∀ i, 0 ≤ w i) ∧ (∑ i, w i = 1) ∧
      (∑ i, w i * (X i : ℚ)) < (∑ i, w i * (Y i : ℚ)) ∧
      ¬ StochDom w X Y := by
  classical
  refine ⟨![1/2, 1/2], ![0, 10], ![6, 6], ?_, ?_, ?_, ?_⟩
  · intro i; fin_cases i <;> norm_num
  · simp [Fin.sum_univ_two]; norm_num
  · simp [Fin.sum_univ_two]; norm_num
  · intro h
    have h6 := h 6
    have hX : PrGT ![1/2, 1/2] ![0, 10] 6 = 1/2 := by
      have : (univ.filter (fun i : Fin 2 => 6 < (![0, 10] : Fin 2 → ℕ) i)) = {1} := by
        ext i; fin_cases i <;> simp
      simp [PrGT, Pr, this]
    have hY : PrGT ![1/2, 1/2] ![6, 6] 6 = 0 := by
      have : (univ.filter (fun i : Fin 2 => 6 < (![6, 6] : Fin 2 → ℕ) i)) = ∅ := by
        ext i; fin_cases i <;> simp
      simp [PrGT, Pr, this]
    rw [hX, hY] at h6
    linarith

end Probability.PortfolioRegret