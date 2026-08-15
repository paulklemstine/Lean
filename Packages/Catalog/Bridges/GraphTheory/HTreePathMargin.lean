/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.HTreeRobust
/-!
# Path Margin and Certificate Radius for Elimination Trees

This file defines the `pathMargin` of an elimination tree — the minimum score
margin along the realized winner path — and proves that it provides a valid
certified robustness radius.

## Key insight: tournament winners maximize scores

A crucial structural fact is that the winner of any subtree has the globally
highest score among all leaves in that subtree. This is because at each
comparison, the higher-scoring class advances. Consequently, the pathwise
margin (along the winner path only) is sufficient for robustness.

## Main results

- `HTree.eval_score_ge`: The tournament winner has score ≥ every leaf.
- `HTree.pathMargins`: The list of margins along the realized winner path.
- `HTree.pathMargin_sufficient`: The pathMargin gives a valid robustness
  certificate when combined with a Lipschitz bound.
-/

open Classical

noncomputable section

namespace HTree

variable {α : Type}

/-
The tournament winner has score ≥ every leaf in the subtree.
-/
theorem eval_score_ge [DecidableEq α] (T : HTree α) (s : α → ℝ) :
    ∀ c ∈ T.classes, s c ≤ s (T.eval s) := by
  induction' T with L R hL hR;
  · aesop;
  · simp_all +decide [ HTree.eval, HTree.classes ];
    grind

/-- The list of score margins along the realized winner path. -/
def pathMargins : HTree α → (α → ℝ) → List ℝ
  | .leaf _, _ => []
  | .node L R, s =>
    let u := L.eval s
    let v := R.eval s
    |s u - s v| :: (if s u ≥ s v then L.pathMargins s else R.pathMargins s)

/-
Every element of pathMargins is nonneg (absolute values).
-/
theorem pathMargins_nonneg (T : HTree α) (s : α → ℝ) :
    ∀ m ∈ T.pathMargins s, 0 ≤ m := by
  induction T <;> simp_all +decide [ pathMargins ];
  grind

/-
If δ < every margin in pathMargins, then PathDominates holds.
-/
theorem pathMargins_bound_implies_pathDominates [DecidableEq α]
    (T : HTree α) (s : α → ℝ) (δ : ℝ)
    (hbound : ∀ m ∈ T.pathMargins s, δ < m) :
    T.PathDominates s δ := by
  induction' T with L R hL hR;
  · trivial;
  · by_cases h : s ( R.eval s ) ≥ s ( hL.eval s ) <;> simp_all +decide [ HTree.PathDominates ];
    · refine' ⟨ _, hR _ ⟩;
      · intro c hc;
        have := hbound ( |s ( R.eval s ) - s ( hL.eval s )| ) ?_;
        · cases abs_cases ( s ( R.eval s ) - s ( hL.eval s ) ) <;> linarith [ show s c ≤ s ( hL.eval s ) from eval_score_ge hL s c hc ];
        · exact List.mem_cons_self;
      · intro m hm; specialize hbound m; simp_all +decide [ HTree.pathMargins ] ;
    · simp_all +decide [ HTree.pathMargins ];
      split_ifs at * <;> simp_all +decide [ abs_of_neg ];
      · linarith;
      · exact fun c hc => by linarith [ eval_score_ge R s c hc ] ;

/-
The pathMargin gives a valid robustness certificate.
-/
theorem pathMargin_sufficient [DecidableEq α]
    {X : Type}
    (T : HTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (L r : ℝ)
    (hL : 0 ≤ L)
    (hLip : ∀ u v x y,
      |(score u x - score v x) - (score u y - score v y)| ≤ L * D x y)
    {x y : X}
    (hy : D x y ≤ r)
    (hpath : ∀ m ∈ T.pathMargins (fun a => score a x), L * r < m) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x) := by
  apply eval_stable_of_pathDom;
  exact fun u v => le_trans ( hLip u v x y ) ( mul_le_mul_of_nonneg_left hy hL );
  exact pathMargins_bound_implies_pathDominates T (fun a => score a x) (L * r) hpath

end HTree

end