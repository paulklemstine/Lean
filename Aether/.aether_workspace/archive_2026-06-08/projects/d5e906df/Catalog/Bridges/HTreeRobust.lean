/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.HTreeDefs

/-!
# Hierarchical Classifier Robustness via Tournament Margin Decomposition

This file proves certified robustness theorems for hierarchical multiclass
classifiers built from pairwise score comparisons in a binary elimination tree.

## Main results

### Atomic comparison stability
- `ge_iff_of_abs_sub_lt`: If two differences have perturbation less than the
  absolute gap, the comparison direction is preserved.

### Global margin robustness
- `HTree.AllMarginsAbove`: Predicate that every internal node has margin > δ.
- `HTree.eval_stable`: The tournament winner is preserved if all margins exceed
  the perturbation bound.
- `HTree.eval_stable_of_lip`: Lipschitz-parameterized version.

### Pathwise domination robustness (sharper certificate)
- `HTree.PathDominates`: At each node on the winner path, the winner's score
  exceeds ALL classes in the losing subtree by more than δ.
- `HTree.eval_stable_of_pathDom`: The tournament winner is preserved under
  the pathwise domination condition. This is strictly sharper than the global
  margin certificate because it only requires margins along the realized path.

## Key insight

The pathwise certificate `PathDominates` is genuinely sharper than `AllMarginsAbove`
because it does not require stability of comparisons in subtrees that are never
reached by the winner. However, at each node on the winner path, the domination
condition must be against ALL classes in the losing subtree (not just the subtree
winner), because the losing subtree's tournament winner can change under perturbation.
-/

open Classical

noncomputable section

/-! ### Atomic comparison stability -/

/-
If two differences have perturbation bounded by `δ` and the original gap
    exceeds `δ`, then the comparison direction is preserved.
    This is the atomic robustness step for pairwise score comparisons.
-/
lemma ge_iff_of_abs_sub_lt {a b a' b' δ : ℝ}
    (hpert : |(a - b) - (a' - b')| ≤ δ)
    (hgap : δ < |a - b|) :
    (a ≥ b ↔ a' ≥ b') := by
  constructor <;> intro <;> cases abs_cases ( a - b ) <;> cases abs_cases ( a' - b' ) <;> linarith [ abs_le.mp hpert ]

/-
Variant: if the score difference perturbation is bounded and the gap is
    positive, the sign of the difference is preserved.
-/
lemma sub_nonneg_iff_of_abs_sub_lt {d d' δ : ℝ}
    (hpert : |d - d'| ≤ δ)
    (hgap : δ < |d|) :
    (0 ≤ d ↔ 0 ≤ d') := by
  grind

/-
If `δ < a - b` and `|(a - b) - (a' - b')| ≤ δ`, then `a' > b'`.
-/
lemma gt_of_sub_gt_abs_perturbation {a b a' b' δ : ℝ}
    (hgap : δ < a - b)
    (hpert : |(a - b) - (a' - b')| ≤ δ) :
    a' > b' := by
  linarith [ abs_le.mp hpert ]

namespace HTree

variable {α : Type} {X : Type}

/-! ### Global margin robustness -/

/-- Recursive predicate: every internal node of the tree has absolute score margin
    strictly exceeding `δ`. This descends into BOTH children at each node. -/
def AllMarginsAbove : HTree α → (α → ℝ) → ℝ → Prop
  | .leaf _, _, _ => True
  | .node L R, s, δ =>
    δ < |s (L.eval s) - s (R.eval s)| ∧
    L.AllMarginsAbove s δ ∧
    R.AllMarginsAbove s δ

@[simp]
theorem allMarginsAbove_leaf (a : α) (s : α → ℝ) (δ : ℝ) :
    (HTree.leaf a).AllMarginsAbove s δ = True := rfl

theorem allMarginsAbove_node (L R : HTree α) (s : α → ℝ) (δ : ℝ) :
    (HTree.node L R).AllMarginsAbove s δ ↔
      (δ < |s (L.eval s) - s (R.eval s)| ∧
       L.AllMarginsAbove s δ ∧
       R.AllMarginsAbove s δ) := by
  simp [AllMarginsAbove]

/-
**Global margin robustness theorem**: If every internal node has margin exceeding
    the perturbation bound `δ`, and score differences are perturbed by at most `δ`,
    then the tournament winner is unchanged.

    The proof proceeds by induction on the tree structure. At each node, the
    induction hypothesis guarantees both children produce the same winners,
    and the gap condition ensures the root comparison is preserved.
-/
theorem eval_stable
    (T : HTree α)
    (s s' : α → ℝ)
    (δ : ℝ)
    (hpert : ∀ u v, |(s u - s v) - (s' u - s' v)| ≤ δ)
    (hmargin : T.AllMarginsAbove s δ) :
    T.eval s' = T.eval s := by
  induction' T with L R hL hR;
  · rfl;
  · cases hmargin;
    rw [ HTree.eval_node, HTree.eval_node ];
    split_ifs <;> simp_all +decide [ abs_le ];
    · cases abs_cases ( s ( R.eval s ) - s ( hL.eval s ) ) <;> linarith [ hpert ( R.eval s ) ( hL.eval s ) ];
    · cases abs_cases ( s ( R.eval s ) - s ( hL.eval s ) ) <;> linarith [ hpert ( R.eval s ) ( hL.eval s ) ]

/-
**Lipschitz version**: robustness under a global Lipschitz condition on
    score differences and a distance bound.
-/
theorem eval_stable_of_lip
    (T : HTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (L r : ℝ)
    (hL : 0 ≤ L)
    (hLip : ∀ u v x y,
      |(score u x - score v x) - (score u y - score v y)| ≤ L * D x y)
    {x y : X}
    (hy : D x y ≤ r)
    (hmargin : T.AllMarginsAbove (fun a => score a x) (L * r)) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x) := by
  apply eval_stable T (fun a => score a x) (fun a => score a y) (L * r);
  · exact fun u v => le_trans ( hLip u v x y ) ( mul_le_mul_of_nonneg_left hy hL );
  · assumption

/-! ### Pathwise domination robustness (sharper certificate) -/

/-- **Pathwise domination predicate**: At each node on the winner path, the winner's
    score exceeds ALL class labels in the losing subtree by more than `δ`.

    This is sharper than `AllMarginsAbove` because:
    1. It only constrains nodes on the realized winner path.
    2. At each such node, the margin condition is against the subtree winner,
       but to ensure correctness when the losing subtree's winner changes under
       perturbation, we require domination over ALL classes in the losing subtree. -/
def PathDominates [DecidableEq α] : HTree α → (α → ℝ) → ℝ → Prop
  | .leaf _, _, _ => True
  | .node L R, s, δ =>
    let u := L.eval s
    let v := R.eval s
    if s u ≥ s v then
      (∀ c ∈ R.classes, δ < s u - s c) ∧ L.PathDominates s δ
    else
      (∀ c ∈ L.classes, δ < s v - s c) ∧ R.PathDominates s δ

/-
**Pathwise domination robustness theorem**: If the winner at each node on
    the realized path dominates all classes in the losing subtree by more than
    the perturbation bound, the tournament winner is preserved.

    This gives a strictly sharper certificate than `eval_stable` because it does
    not require any margins from comparisons in subtrees that the winner never
    visits. The key structural insight is that the losing subtree's internal
    tournament outcome is irrelevant — only the winning subtree needs recursive
    stability.
-/
theorem eval_stable_of_pathDom [DecidableEq α]
    (T : HTree α)
    (s s' : α → ℝ)
    (δ : ℝ)
    (hpert : ∀ u v, |(s u - s v) - (s' u - s' v)| ≤ δ)
    (hdom : T.PathDominates s δ) :
    T.eval s' = T.eval s := by
  induction' T with L R hL hR;
  · rfl;
  · unfold HTree.PathDominates at hdom;
    simp_all +decide [ HTree.eval_node ];
    split_ifs at * <;> simp_all +decide [ abs_le ];
    · contrapose! hdom;
      intro h; have := h ( R.eval s' ) ( eval_mem_classes R s' ) ; (
      linarith [ hpert ( hL.eval s ) ( R.eval s' ) ]);
    · have := hdom.1 ( hL.eval s' ) ( eval_mem_classes hL s' );
      linarith [ hpert ( R.eval s ) ( hL.eval s' ) ]

/-
`AllMarginsAbove` implies `PathDominates`: the global condition is stronger.
-/
theorem allMarginsAbove_implies_pathDominates [DecidableEq α]
    (T : HTree α) (s : α → ℝ) (δ : ℝ)
    (h : T.AllMarginsAbove s δ) :
    T.PathDominates s δ := by
  induction' T with L R IH1 IH2 generalizing s δ;
  · trivial;
  · cases' h with h₁ h₂;
    cases abs_cases ( s ( R.eval s ) - s ( IH1.eval s ) ) <;> simp_all +decide [ HTree.PathDominates ];
    · have h_ind : ∀ (T : HTree α) (s : α → ℝ) (δ : ℝ), T.AllMarginsAbove s δ → ∀ c ∈ T.classes, s (T.eval s) - s c ≥ 0 := by
        intros T s δ hT c hc; induction' T with L R IH1 IH2 generalizing s δ; aesop;
        cases hT ; simp_all +decide [ HTree.eval ];
        grind;
      exact fun c hc => by linarith [ h_ind _ _ _ h₂.2 c hc ] ;
    · have h_dom : ∀ c ∈ R.classes, s c ≤ s (R.eval s) := by
        have h_dom : ∀ T : HTree α, ∀ s : α → ℝ, ∀ c ∈ T.classes, s c ≤ s (T.eval s) := by
          intros T s c hc; induction' T with L R IH1 IH2 generalizing s c; aesop;
          simp_all +decide [ HTree.eval, HTree.classes ];
          grind;
        exact h_dom R s;
      grind

/-! ### Certified radius -/

/-
The certified robustness radius: the minimum score margin across all internal
    nodes divided by the Lipschitz constant. Within this radius, the tournament
    winner is guaranteed to be preserved.
-/
theorem robust_radius_spec
    (T : HTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (K d : ℝ)
    (hK : 0 < K)
    (hd : 0 < d)
    (hLip : ∀ u v x y,
      |(score u x - score v x) - (score u y - score v y)| ≤ 2 * K * d * D x y)
    (x y : X)
    (hmargin : T.AllMarginsAbove (fun a => score a x) (2 * K * d * r))
    (hy : D x y ≤ r) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x) := by
  apply eval_stable_of_lip T score D (2 * K * d) r (by positivity) hLip hy hmargin

end HTree

end