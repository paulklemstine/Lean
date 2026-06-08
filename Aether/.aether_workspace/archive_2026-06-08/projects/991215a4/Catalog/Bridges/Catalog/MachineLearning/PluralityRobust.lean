/-
# Plurality Robustness Theorems for Multiclass Ensembles

This module proves the compositional robustness theorem: if a subset S of
experts are individually certified to strictly maintain their decision
throughout an L∞ ball, and S is large enough to outvote every rival class,
then the plurality winner is preserved throughout the ball.

The use of `StrictDecides` (strict maximizer) is essential: it ensures
that an expert voting for the winner class cannot simultaneously be counted
as voting for a rival, which is the key to the disjointness argument.
-/
import Mathlib
import MachineLearning.TropicalDefs

open Finset BigOperators Classical

noncomputable section

attribute [local instance] Classical.propDecidable

variable {n C d : ℕ} [NeZero C]

/-! ## Frozen-voter lower bound -/

/-- If every expert in `S` decides `c` at `z`, then `voteCount ≥ |S|`. -/
theorem card_le_voteCount_of_subset_decides
    (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (z : Fin d → ℝ) (c : Fin C)
    (S : Finset (Fin n))
    (hS : ∀ i ∈ S, decides (F i z) c) :
    S.card ≤ voteCount F z c := by
  exact Finset.card_le_card fun x hx => by aesop

/-! ## Disjointness: a strict decider for cstar cannot vote for a rival -/

/-- A strict decision for `c` precludes a (non-strict) decision for `c' ≠ c`. -/
theorem not_decides_of_strictDecides_ne
    {C : ℕ} [NeZero C] (s : Fin C → ℝ) (c c' : Fin C)
    (hne : c' ≠ c) (h : StrictDecides s c) :
    ¬ decides s c' := by
  exact fun h' => lt_irrefl _ (lt_of_le_of_lt (h' _) (h _ hne))

/-! ## Rival vote bound -/

/-- If every expert in `S` strictly decides `cstar` at `z`, then the vote
count for any rival `c ≠ cstar` is at most `|univ \ S|`. -/
theorem rival_voteCount_le_complement
    (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (z : Fin d → ℝ) (c cstar : Fin C)
    (hne : c ≠ cstar)
    (S : Finset (Fin n))
    (hStrict : ∀ i ∈ S, StrictDecides (F i z) cstar) :
    voteCount F z c ≤ (Finset.univ \ S).card := by
  refine' le_trans (Finset.card_le_card _) _
  exact Finset.univ \ S
  · intro i hi; specialize hStrict i; simp_all +decide
    exact fun hi' => not_decides_of_strictDecides_ne _ _ _ hne (hStrict hi') hi
  · rfl

/-! ## Main structural theorem -/

/-- **Plurality Robustness from Frozen Winner-Voters.**

If a set `S` of experts all *strictly* decide `cstar` throughout the L∞ ball,
and `S` forms a strict majority of the ensemble (`|univ \ S| < |S|`),
then `cstar` is the strict plurality winner on the whole ball.

**Proof sketch.** Fix `z` in the ball and a rival class `c ≠ cstar`.
1. *Winner lower bound:* Every `i ∈ S` decides `cstar` at `z`
   (since `StrictDecides` implies `decides`), so `|S| ≤ voteCount F z cstar`.
2. *Rival upper bound:* Every `i ∈ S` strictly decides `cstar` at `z`,
   so `i` cannot vote for `c` (disjointness). Thus voters for `c` at `z`
   lie in `univ \ S`, giving `voteCount F z c ≤ |univ \ S|`.
3. *Combine:* `voteCount F z c ≤ |univ \ S| < |S| ≤ voteCount F z cstar`. -/
theorem plurality_robust_of_frozen_winner_voters
    (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (x : Fin d → ℝ)
    (cstar : Fin C)
    (r : ℝ)
    (S : Finset (Fin n))
    (_hSsubset : S ⊆ winnerVoters F x cstar)
    (hstable : ∀ ⦃i : Fin n⦄, i ∈ S →
      ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r → StrictDecides (F i z) cstar)
    (hplurality : (Finset.univ \ S).card < S.card) :
    ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r →
      ∀ c : Fin C, c ≠ cstar → voteCount F z c < voteCount F z cstar := by
  intro z hz c hc
  calc voteCount F z c
      ≤ (Finset.univ \ S).card :=
        rival_voteCount_le_complement F z c cstar hc S fun i hi => hstable hi hz
    _ < S.card := hplurality
    _ ≤ voteCount F z cstar :=
        card_le_voteCount_of_subset_decides F z cstar S
          fun i hi => (hstable hi hz).decides

/-! ## Quantitative variant -/

/-- Wrapper of the main theorem with an explicit cardinality bound `M`. -/
theorem plurality_robust_exists_frozen_subset
    (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (x : Fin d → ℝ)
    (cstar : Fin C)
    (r : ℝ)
    (S : Finset (Fin n))
    (hSsubset : S ⊆ winnerVoters F x cstar)
    (hstable : ∀ ⦃i : Fin n⦄, i ∈ S →
      ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r → StrictDecides (F i z) cstar)
    (hScard : (Finset.univ \ S).card < S.card) :
    ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r →
      ∀ c : Fin C, c ≠ cstar → voteCount F z c < voteCount F z cstar :=
  plurality_robust_of_frozen_winner_voters F x cstar r S hSsubset hstable hScard

/-! ## Certificate radius and stable winner voters -/

/-- The certified radius for expert `f` at input `x` for class `c`. -/
noncomputable def certRadius
    (f : (Fin d → ℝ) → Fin C → ℝ) (K : ℝ) (x : Fin d → ℝ) (c : Fin C)
    (hC : 1 < C) : ℝ :=
  scoreGap f x c hC / (2 * K * (d : ℝ))

/-- The subset of winner-voters whose certified radius exceeds `r`. -/
noncomputable def stableWinnerVoters
    (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (K : Fin n → ℝ) (x : Fin d → ℝ) (c : Fin C) (r : ℝ)
    (hC : 1 < C) : Finset (Fin n) :=
  Finset.univ.filter (fun i =>
    decides (F i x) c ∧ r < certRadius (F i) (K i) x c hC)

/-- `stableWinnerVoters` is a subset of `winnerVoters`. -/
theorem stableWinnerVoters_subset_winnerVoters
    (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (K : Fin n → ℝ) (x : Fin d → ℝ) (c : Fin C) (r : ℝ)
    (hC : 1 < C) :
    stableWinnerVoters F K x c r hC ⊆ winnerVoters F x c := by
  intro i hi
  simp only [stableWinnerVoters, winnerVoters, Finset.mem_filter] at *
  exact ⟨hi.1, hi.2.1⟩

/-- Members of `stableWinnerVoters` have score gap exceeding the threshold. -/
theorem gap_of_mem_stableWinnerVoters
    (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (K : Fin n → ℝ) (x : Fin d → ℝ) (c : Fin C) (r : ℝ)
    (hC : 1 < C)
    (hK : ∀ i, 0 < K i)
    (hd : 0 < d)
    {i : Fin n}
    (hi : i ∈ stableWinnerVoters F K x c r hC) :
    scoreGap (F i) x c hC > 2 * K i * (d : ℝ) * r := by
  have := Finset.mem_filter.mp hi
  unfold certRadius at this
  rw [lt_div_iff₀] at this <;>
    nlinarith [hK i, show (d : ℝ) > 0 by positivity,
      mul_pos (hK i) (show (d : ℝ) > 0 by positivity)]

/-- **Plurality Robustness from Expert Gap Certificates.**

Uses the analytic per-expert lemma (`strictDecides_of_gap_gt`) to verify
that each expert in `stableWinnerVoters` remains frozen throughout the ball,
then invokes the structural plurality theorem.

Requires:
- `hK`: each Lipschitz constant is positive,
- `hd`: the input dimension is positive,
- `hLip`: each expert is coordinatewise `K i`-Lipschitz,
- `hmajority`: the stable winner-voters form a strict majority. -/
theorem plurality_robust_of_expert_gap_certificates
    (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (K : Fin n → ℝ)
    (x : Fin d → ℝ)
    (cstar : Fin C)
    (r : ℝ)
    (hC : 1 < C)
    (hK : ∀ i, 0 < K i)
    (hd : 0 < d)
    (hLip : ∀ i, CoordLipschitz (F i) (K i))
    (hmajority : (Finset.univ \ stableWinnerVoters F K x cstar r hC).card
      < (stableWinnerVoters F K x cstar r hC).card) :
    ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r →
      ∀ c : Fin C, c ≠ cstar → voteCount F z c < voteCount F z cstar := by
  apply plurality_robust_of_frozen_winner_voters (S := stableWinnerVoters F K x cstar r hC)
  · exact stableWinnerVoters_subset_winnerVoters F K x cstar r hC
  · intro i hi z hz
    exact strictDecides_of_gap_gt (F i) (K i) r x z cstar hC (le_of_lt (hK i)) (hLip i) hz
      (gap_of_mem_stableWinnerVoters F K x cstar r hC hK hd hi)
  · exact hmajority