/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Probability.TropicalSocialChoiceOligarchy

/-!
# Tropical social choice VII: strategy-proofness is not restrictive

Conjecture 3 of `FUTURE_DIRECTIONS.md` proposed a tropical Gibbard–Satterthwaite theorem:
calling `f : TRⁿ → TR` *tropically strategy-proof* when raising one voter's reported cost
never lowers the social cost, it conjectured that tropically strategy-proof, unanimous,
tropically linear rules are exactly the coalition rules.

This file settles the conjecture: **the monotonicity condition has no bite at all.**

## Main results

* `TropStrategyProof`, `IsTropLinear.tropStrategyProof` : every tropical linear form is
  tropically strategy-proof, so the axiom is implied by linearity and adds nothing.
* `weightedRule_tropStrategyProof`, `weightedRule_ne_tropCoalition` : the handicapped rule
  `f (x₀, x₁) = min (x₀, 1 + x₁)` (voter `1` carries a unit cost penalty) is tropically
  linear, unanimous and strategy-proof, but is not a coalition rule.
* `not_tropical_gibbard_satterthwaite` : Conjecture 3 refuted.  Adding tropical
  strategy-proofness to tropical linearity and unanimity does not force a coalition rule;
  diagonal idempotence (`oligarchy_iff`) genuinely is a stronger requirement.
-/

namespace TropicalSocialChoice

open Tropical Finset

section StrategyProof

variable {n : ℕ}

/-- **Tropical strategy-proofness.**  If one voter reports a weakly higher cost and nobody
else changes their report, the social cost does not decrease: no voter gains by
understating a cost. -/
def TropStrategyProof (f : (Fin n → TR) → TR) : Prop :=
  ∀ (i : Fin n) (x x' : Fin n → TR), (∀ l, l ≠ i → x l = x' l) → x i ≤ x' i → f x ≤ f x'

/-- Every tropical linear form is tropically strategy-proof: the axiom is a consequence of
linearity, not an extra restriction. -/
theorem IsTropLinear.tropStrategyProof {f : (Fin n → TR) → TR} (hlin : IsTropLinear f) :
    TropStrategyProof f := by
  intro i x x' hrest hle
  refine hlin.mono fun l => ?_
  by_cases h : l = i
  · subst h; exact hle
  · exact le_of_eq (hrest l h)

/-- The handicapped two-voter rule `min (x₀, 1 + x₁)`: voter `1`'s reported cost carries a
unit penalty. -/
noncomputable def weightedRule : (Fin 2 → TR) → TR := tropForm ![1, ofReal 1]

theorem weightedRule_isTropLinear : IsTropLinear weightedRule := ⟨![1, ofReal 1], fun _ => rfl⟩

theorem one_le_ofReal_one : (1 : TR) ≤ ofReal 1 := by
  rw [← untrop_le_iff]
  have h : untrop (1 : TR) = ((0 : ℝ) : WithTop ℝ) := rfl
  rw [h]
  simp only [ofReal, untrop_trop]
  exact_mod_cast (by norm_num : (0 : ℝ) ≤ 1)

theorem weightedRule_tropPareto : TropPareto weightedRule := by
  rw [weightedRule, tropPareto_tropForm_iff, Fin.sum_univ_two]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
  exact Tropical.add_eq_left one_le_ofReal_one

theorem weightedRule_tropStrategyProof : TropStrategyProof weightedRule :=
  weightedRule_isTropLinear.tropStrategyProof

/-- The handicap makes the rule differ from every coalition rule: on the profile where
voter `0` is unavailable (cost `⊤`) and voter `1` reports the neutral cost, the rule
returns the penalised cost `1`, which no coalition rule ever produces. -/
theorem weightedRule_ne_tropCoalition (s : Finset (Fin 2)) : weightedRule ≠ tropCoalition s := by
  classical
  intro hs
  have hval : weightedRule ![0, 1] = ofReal 1 := by
    rw [weightedRule, tropForm, Fin.sum_univ_two]
    simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
    rw [mul_zero, mul_one, zero_add]
  rw [hs] at hval
  have h0 : (![0, 1] : Fin 2 → TR) 0 = 0 := rfl
  have h1 : (![0, 1] : Fin 2 → TR) 1 = 1 := rfl
  have hne0 : ofReal 1 ≠ (0 : TR) := by
    intro h
    have := congrArg untrop h
    simp only [ofReal, untrop_trop] at this
    exact WithTop.coe_ne_top this
  have hne1 : ofReal 1 ≠ (1 : TR) := by
    intro h
    have : (1 : ℝ) = 0 := ofReal_injective (by rw [h]; rfl)
    norm_num at this
  have hcases : ∀ t : Finset (Fin 2), t = ∅ ∨ t = {0} ∨ t = {1} ∨ t = {0, 1} := by decide
  rcases hcases s with rfl | rfl | rfl | rfl
  · rw [tropCoalition, Finset.sum_empty] at hval
    exact hne0 hval.symm
  · rw [tropCoalition, Finset.sum_singleton, h0] at hval
    exact hne0 hval.symm
  · rw [tropCoalition, Finset.sum_singleton, h1] at hval
    exact hne1 hval.symm
  · rw [tropCoalition, show ({0, 1} : Finset (Fin 2)) = Finset.univ from rfl, Fin.sum_univ_two,
      h0, h1, zero_add] at hval
    exact hne1 hval.symm

/-- **Conjecture 3 refuted.**  There is a tropically linear, unanimous, tropically
strategy-proof rule on two voters which is not a coalition rule.  Tropical
strategy-proofness is implied by linearity (`IsTropLinear.tropStrategyProof`) and therefore
cannot substitute for diagonal idempotence in the oligarchy theorem. -/
theorem not_tropical_gibbard_satterthwaite :
    ∃ f : (Fin 2 → TR) → TR,
      IsTropLinear f ∧ TropPareto f ∧ TropStrategyProof f ∧
        ∀ s : Finset (Fin 2), f ≠ tropCoalition s :=
  ⟨weightedRule, weightedRule_isTropLinear, weightedRule_tropPareto,
    weightedRule_tropStrategyProof, weightedRule_ne_tropCoalition⟩

/-- Every rule satisfying the tropical Arrow axioms is strategy-proof, so within that
axiom system strategy-proofness is free — the dictator is the unique solution anyway. -/
theorem tropDictator_tropStrategyProof (k : Fin n) : TropStrategyProof (tropDictator k) :=
  (tropDictator_isTropLinear k).tropStrategyProof

end StrategyProof

end TropicalSocialChoice