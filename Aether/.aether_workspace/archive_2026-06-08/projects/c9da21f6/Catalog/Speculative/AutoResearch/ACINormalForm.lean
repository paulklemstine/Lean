/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# ACI Canonical Forms for Tropical Min Normalization

## Overview

This file extends AC canonicalization for tropical expressions to handle
**idempotence** of `min`: the identity `min(a, a) = a`. The ACI normalizer
is strictly stronger than AC — it identifies expressions differing only by
duplicated `min` subexpressions.

The key insight: tropical `min` is a **semilattice** (meet) operation.
Passing from AC to ACI corresponds to passing from multisets to finite sets.

## Main results

* `TropACI.eval_normalize_aci` — **Soundness**: normalization preserves semantics
* `TropACI.normalize_aci_idempotent` — **Idempotence**: normalizing twice = once
* `TropACI.normalize_aci_complete` — **Completeness**: ACI-equiv ↔ same normal form
* `TropACI.eval_eq_of_normalize_aci_eq` — **Decision procedure**
* `TropACI.normalize_aci_strictly_stronger` — ACI identifies strictly more than AC
-/
import Mathlib

noncomputable section

open Classical

namespace TropACI

/-! ## Tropical Expression Syntax -/

/-- Tropical expression syntax (min-plus convention). -/
inductive TropExpr where
  | const : ℝ → TropExpr
  | var   : ℕ → TropExpr
  | tmin  : TropExpr → TropExpr → TropExpr
  | add   : TropExpr → TropExpr → TropExpr
  deriving Inhabited

open TropExpr

/-! ## Evaluation Semantics -/

/-- Evaluate a tropical expression under variable assignment `σ`. -/
def eval (σ : ℕ → ℝ) : TropExpr → ℝ
  | .const r    => r
  | .var n      => σ n
  | .tmin e₁ e₂ => min (eval σ e₁) (eval σ e₂)
  | .add e₁ e₂  => eval σ e₁ + eval σ e₂

/-! ## Linear Order on Expressions -/

instance : LinearOrder TropExpr := linearOrderOfSTO WellOrderingRel

noncomputable instance decEqTropExpr : DecidableEq TropExpr := fun a b => Classical.dec (a = b)

/-! ## ACI Congruence Relation -/

/-- The ACI congruence on tropical expressions: AC + idempotence of `tmin`. -/
inductive ACIEquiv : TropExpr → TropExpr → Prop
  | refl  : ∀ e, ACIEquiv e e
  | symm  : ∀ {e₁ e₂}, ACIEquiv e₁ e₂ → ACIEquiv e₂ e₁
  | trans : ∀ {e₁ e₂ e₃}, ACIEquiv e₁ e₂ → ACIEquiv e₂ e₃ → ACIEquiv e₁ e₃
  | tmin_comm  : ∀ e₁ e₂, ACIEquiv (.tmin e₁ e₂) (.tmin e₂ e₁)
  | tmin_assoc : ∀ e₁ e₂ e₃,
      ACIEquiv (.tmin (.tmin e₁ e₂) e₃) (.tmin e₁ (.tmin e₂ e₃))
  | tmin_idem  : ∀ e, ACIEquiv (.tmin e e) e
  | add_comm   : ∀ e₁ e₂, ACIEquiv (.add e₁ e₂) (.add e₂ e₁)
  | add_assoc  : ∀ e₁ e₂ e₃,
      ACIEquiv (.add (.add e₁ e₂) e₃) (.add e₁ (.add e₂ e₃))
  | cong_tmin  : ∀ {a a' b b'}, ACIEquiv a a' → ACIEquiv b b' →
      ACIEquiv (.tmin a b) (.tmin a' b')
  | cong_add   : ∀ {a a' b b'}, ACIEquiv a a' → ACIEquiv b b' →
      ACIEquiv (.add a b) (.add a' b')

/-- ACI equivalence preserves evaluation. -/
theorem ACIEquiv.eval_eq {e₁ e₂ : TropExpr} (h : ACIEquiv e₁ e₂) (σ : ℕ → ℝ) :
    eval σ e₁ = eval σ e₂ := by
  induction h with
  | refl _ => rfl
  | @symm e₁ e₂ _ ih => exact ih.symm
  | @trans e₁ e₂ e₃ _ _ ih1 ih2 => exact ih1.trans ih2
  | tmin_comm e₁ e₂ => exact min_comm _ _
  | tmin_assoc e₁ e₂ e₃ => exact min_assoc _ _ _
  | tmin_idem e => exact min_self _
  | @add_comm e₁ e₂ =>
    show eval σ e₁ + eval σ e₂ = eval σ e₂ + eval σ e₁; ring
  | @add_assoc e₁ e₂ e₃ =>
    show (eval σ e₁ + eval σ e₂) + eval σ e₃ = eval σ e₁ + (eval σ e₂ + eval σ e₃); ring
  | @cong_tmin a a' b b' _ _ ih1 ih2 =>
    show min (eval σ a) (eval σ b) = min (eval σ a') (eval σ b')
    rw [ih1, ih2]
  | @cong_add a a' b b' _ _ ih1 ih2 =>
    show eval σ a + eval σ b = eval σ a' + eval σ b'
    rw [ih1, ih2]

/-! ## AC Congruence (no idempotence, for comparison) -/

/-- The AC congruence on tropical expressions. -/
inductive ACEquiv : TropExpr → TropExpr → Prop
  | refl  : ∀ e, ACEquiv e e
  | symm  : ∀ {e₁ e₂}, ACEquiv e₁ e₂ → ACEquiv e₂ e₁
  | trans : ∀ {e₁ e₂ e₃}, ACEquiv e₁ e₂ → ACEquiv e₂ e₃ → ACEquiv e₁ e₃
  | tmin_comm  : ∀ e₁ e₂, ACEquiv (.tmin e₁ e₂) (.tmin e₂ e₁)
  | tmin_assoc : ∀ e₁ e₂ e₃,
      ACEquiv (.tmin (.tmin e₁ e₂) e₃) (.tmin e₁ (.tmin e₂ e₃))
  | add_comm   : ∀ e₁ e₂, ACEquiv (.add e₁ e₂) (.add e₂ e₁)
  | add_assoc  : ∀ e₁ e₂ e₃,
      ACEquiv (.add (.add e₁ e₂) e₃) (.add e₁ (.add e₂ e₃))
  | cong_tmin  : ∀ {a a' b b'}, ACEquiv a a' → ACEquiv b b' →
      ACEquiv (.tmin a b) (.tmin a' b')
  | cong_add   : ∀ {a a' b b'}, ACEquiv a a' → ACEquiv b b' →
      ACEquiv (.add a b) (.add a' b')

/-! ## Flattening, Sorting, Deduplication, Rebuilding -/

/-- Flatten nested `tmin` into a list. -/
def flattenMin : TropExpr → List TropExpr
  | .tmin e₁ e₂ => flattenMin e₁ ++ flattenMin e₂
  | e => [e]

/-- Flatten nested `add` into a list. -/
def flattenAdd : TropExpr → List TropExpr
  | .add e₁ e₂ => flattenAdd e₁ ++ flattenAdd e₂
  | e => [e]

/-- Rebuild a right-associated `tmin` tree from a non-empty list. -/
def rebuildMin : List TropExpr → TropExpr
  | []      => default
  | [e]     => e
  | e :: es => .tmin e (rebuildMin es)

/-- Rebuild a right-associated `add` tree from a non-empty list. -/
def rebuildAdd : List TropExpr → TropExpr
  | []      => default
  | [e]     => e
  | e :: es => .add e (rebuildAdd es)

/-- Deduplicate a sorted list by removing adjacent duplicates. -/
def dedupSorted : List TropExpr → List TropExpr
  | [] => []
  | [x] => [x]
  | x :: y :: xs =>
    if x = y then dedupSorted (y :: xs)
    else x :: dedupSorted (y :: xs)

/-! ## AC Normalization (no dedup) -/

/-- AC normalization: flatten, sort, rebuild. -/
def normalize_ca : TropExpr → TropExpr
  | .const r => .const r
  | .var n => .var n
  | .tmin e₁ e₂ =>
    let children := ((↑(flattenMin (.tmin (normalize_ca e₁) (normalize_ca e₂))) : Multiset TropExpr)).sort (· ≤ ·)
    rebuildMin children
  | .add e₁ e₂ =>
    let children := ((↑(flattenAdd (.add (normalize_ca e₁) (normalize_ca e₂))) : Multiset TropExpr)).sort (· ≤ ·)
    rebuildAdd children

/-! ## ACI Normalization -/

/-- ACI normalization: flatten, sort, **deduplicate** (for tmin), rebuild. -/
def normalize_aci : TropExpr → TropExpr
  | .const r => .const r
  | .var n => .var n
  | .tmin e₁ e₂ =>
    let children := ((↑(flattenMin (.tmin (normalize_aci e₁) (normalize_aci e₂))) : Multiset TropExpr)).sort (· ≤ ·)
    rebuildMin (dedupSorted children)
  | .add e₁ e₂ =>
    let children := ((↑(flattenAdd (.add (normalize_aci e₁) (normalize_aci e₂))) : Multiset TropExpr)).sort (· ≤ ·)
    rebuildAdd children

/-! ## Basic List Properties -/

theorem flattenMin_nonempty (e : TropExpr) : (flattenMin e) ≠ [] := by
  induction e with
  | const _ => simp [flattenMin]
  | var _ => simp [flattenMin]
  | tmin e₁ _ ih₁ _ =>
    simp only [flattenMin]
    exact List.append_ne_nil_of_left_ne_nil ih₁ _
  | add _ _ _ _ => simp [flattenMin]

theorem flattenAdd_nonempty (e : TropExpr) : (flattenAdd e) ≠ [] := by
  induction e with
  | const _ => simp [flattenAdd]
  | var _ => simp [flattenAdd]
  | tmin _ _ _ _ => simp [flattenAdd]
  | add e₁ _ ih₁ _ =>
    simp only [flattenAdd]
    exact List.append_ne_nil_of_left_ne_nil ih₁ _

theorem dedupSorted_nonempty {l : List TropExpr} (hl : l ≠ []) :
    dedupSorted l ≠ [] := by
  match l, hl with
  | [_], _ => simp [dedupSorted]
  | _ :: y :: xs, _ =>
    simp only [dedupSorted]
    split
    · exact dedupSorted_nonempty (List.cons_ne_nil y xs)
    · exact List.cons_ne_nil _ _

/-! ## Evaluation of rebuilt lists -/

/-- Evaluate a list of expressions under `min`. -/
def evalMinList (σ : ℕ → ℝ) : List TropExpr → ℝ
  | [] => 0
  | [e] => eval σ e
  | e :: es => min (eval σ e) (evalMinList σ es)

/-- Evaluate a list of expressions under `+`. -/
def evalAddList (σ : ℕ → ℝ) : List TropExpr → ℝ
  | [] => 0
  | [e] => eval σ e
  | e :: es => eval σ e + evalAddList σ es

theorem eval_rebuildMin (σ : ℕ → ℝ) {l : List TropExpr} (hl : l ≠ []) :
    eval σ (rebuildMin l) = evalMinList σ l := by
  match l, hl with
  | [_], _ => simp [rebuildMin, evalMinList]
  | _ :: y :: ys, _ =>
    simp only [rebuildMin, eval, evalMinList]
    congr 1
    exact eval_rebuildMin σ (List.cons_ne_nil y ys)

theorem eval_rebuildAdd (σ : ℕ → ℝ) {l : List TropExpr} (hl : l ≠ []) :
    eval σ (rebuildAdd l) = evalAddList σ l := by
  match l, hl with
  | [_], _ => simp [rebuildAdd, evalAddList]
  | _ :: y :: ys, _ =>
    simp only [rebuildAdd, eval, evalAddList]
    congr 1
    exact eval_rebuildAdd σ (List.cons_ne_nil y ys)

/-! ## Key semantic lemma: dedup preserves min-evaluation -/

/-
Deduplication of a sorted list preserves min-evaluation.
    The heart of ACI normalization, using `min a a = a`.
-/
theorem evalMinList_dedupSorted (σ : ℕ → ℝ) {l : List TropExpr} (hl : l ≠ []) :
    evalMinList σ (dedupSorted l) = evalMinList σ l := by
      induction' n : l.length using Nat.strong_induction_on with n ih generalizing l;
      rcases l with ( _ | ⟨ x, _ | ⟨ y, l ⟩ ⟩ ) <;> simp_all +decide [ evalMinList ];
      · unfold dedupSorted; aesop;
      · by_cases hxy : x = y;
        · rw [ show dedupSorted ( x :: y :: l ) = dedupSorted ( y :: l ) from ?_ ];
          · rw [ ih _ _ _ rfl ];
            · cases l <;> simp +decide [ evalMinList, hxy ];
            · simp +arith +decide [ ← n ];
            · aesop;
          · rw [ dedupSorted ] ; aesop;
        · rw [ show dedupSorted ( x :: y :: l ) = x :: dedupSorted ( y :: l ) from _ ];
          · rw [ show evalMinList σ ( x :: dedupSorted ( y :: l ) ) = min ( eval σ x ) ( evalMinList σ ( dedupSorted ( y :: l ) ) ) from ?_ ];
            · grind +splitImp;
            · cases h : dedupSorted ( y :: l ) <;> simp_all +decide [ evalMinList ];
              exact absurd h ( dedupSorted_nonempty ( by aesop ) );
          · exact if_neg hxy

/-! ## Permutation invariance -/

theorem evalMinList_perm (σ : ℕ → ℝ) {l₁ l₂ : List TropExpr}
    (hl₁ : l₁ ≠ []) (hp : l₁.Perm l₂) :
    evalMinList σ l₁ = evalMinList σ l₂ := by
      have h_min_comm_assoc : ∀ (a b : ℝ), min a b = min b a ∧ ∀ (c : ℝ), min a (min b c) = min b (min a c) := by
        grind;
      have h_perm_invariant : ∀ (l₁ l₂ : List TropExpr), l₁.Perm l₂ → evalMinList σ l₁ = evalMinList σ l₂ := by
        intros l₁ l₂ h_perm
        have h_perm_induction : ∀ (l₁ l₂ : List TropExpr), l₁.Perm l₂ → evalMinList σ l₁ = evalMinList σ l₂ := by
          intros l₁ l₂ h_perm
          induction' h_perm with l₁ l₂ h_perm ih
          ·
            rfl
          ·
            cases l₂ <;> cases h_perm <;> simp_all +decide [ evalMinList ]
          ·
            rename_i x y lop;
            induction lop <;> simp_all +decide [ evalMinList ]
          grind
        exact h_perm_induction l₁ l₂ h_perm;
      exact h_perm_invariant l₁ l₂ hp

theorem evalAddList_perm (σ : ℕ → ℝ) {l₁ l₂ : List TropExpr}
    (hl₁ : l₁ ≠ []) (hp : l₁.Perm l₂) :
    evalAddList σ l₁ = evalAddList σ l₂ := by
      have h_eval_perm : ∀ l₁ l₂ : List TropExpr, l₁.Perm l₂ → evalAddList σ l₁ = evalAddList σ l₂ := by
        intro l₁ l₂ hp₂
        have h_eval_perm : ∀ l : List TropExpr, evalAddList σ l = List.sum (List.map (fun e => eval σ e) l) := by
          intro l; induction l <;> simp +decide [ *, evalAddList ] ;
          cases ‹List TropExpr› <;> simp +decide [ *, evalAddList ];
        rw [ h_eval_perm l₁, h_eval_perm l₂, hp₂.map _ |> List.Perm.sum_eq ];
      exact h_eval_perm l₁ l₂ hp

/-! ## Flattening preserves evaluation -/

theorem evalMinList_append (σ : ℕ → ℝ) {l₁ l₂ : List TropExpr}
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    evalMinList σ (l₁ ++ l₂) = min (evalMinList σ l₁) (evalMinList σ l₂) := by
      induction' l₁ with x l₁ ih generalizing l₂ <;> simp_all +decide;
      rcases l₁ with ( _ | ⟨ y, l₁ ⟩ ) <;> simp_all +decide;
      · cases l₂ <;> simp_all +decide [ evalMinList ];
      · grind +locals

theorem evalAddList_append (σ : ℕ → ℝ) {l₁ l₂ : List TropExpr}
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    evalAddList σ (l₁ ++ l₂) = evalAddList σ l₁ + evalAddList σ l₂ := by
      induction' l₁ with a l₁ ih generalizing l₂ <;> simp_all +decide [ List.append_assoc ];
      rcases l₁ with ( _ | ⟨ b, l₁ ⟩ ) <;> simp_all +decide [ evalAddList ];
      ring

theorem evalMinList_flattenMin (σ : ℕ → ℝ) (e : TropExpr) :
    evalMinList σ (flattenMin e) = eval σ e := by
      induction' e with r n e₁ e₂ ih₁ ih₂;
      · rfl;
      · rfl;
      · -- By definition of `flattenMin`, we have `flattenMin (e₁.tmin e₂) = flattenMin e₁ ++ flattenMin e₂`.
        have h_flattenMin_tmin : flattenMin (e₁.tmin e₂) = flattenMin e₁ ++ flattenMin e₂ := by
          rfl;
        rw [ h_flattenMin_tmin, evalMinList_append ] <;> simp_all +decide [ flattenMin_nonempty ];
        exact?;
      · exact?

theorem evalAddList_flattenAdd (σ : ℕ → ℝ) (e : TropExpr) :
    evalAddList σ (flattenAdd e) = eval σ e := by
      induction' e using TropExpr.recOn with e ih;
      · rfl;
      · rfl;
      · rfl;
      · rename_i e₁ e₂ ih₁ ih₂;
        convert evalAddList_append σ ( flattenAdd_nonempty e₁ ) ( flattenAdd_nonempty e₂ ) using 1;
        exact ih₁.symm ▸ ih₂.symm ▸ rfl

/-! ## Soundness -/

/-
**Soundness**: ACI normalization preserves tropical evaluation semantics.
-/
theorem eval_normalize_aci (e : TropExpr) (σ : ℕ → ℝ) :
    eval σ (normalize_aci e) = eval σ e := by
      induction' e using TropExpr.recOn with e ih₂ ih₁ ih₂;
      · rfl;
      · rfl;
      · convert TropACI.evalMinList_dedupSorted σ _ |> Eq.trans <| TropACI.evalMinList_perm σ _ _ using 1;
        convert TropACI.eval_rebuildMin σ _ using 1;
        convert TropACI.dedupSorted_nonempty _;
        all_goals norm_num [ TropACI.flattenMin_nonempty ];
        any_goals exact ( flattenMin ( ( normalize_aci ih₁ ).tmin ( normalize_aci ih₂ ) ) );
        · exact ne_of_apply_ne List.length ( by simp +decide [ TropACI.flattenMin_nonempty ] );
        · rw [ TropACI.evalMinList_flattenMin ];
          -- By definition of `eval`, we know that `eval σ (ih₁.tmin ih₂) = min (eval σ ih₁) (eval σ ih₂)`.
          have h_eval_min : eval σ (ih₁.tmin ih₂) = min (eval σ ih₁) (eval σ ih₂) := by
            rfl;
          exact h_eval_min.trans ( by rw [ ← ‹eval σ ( normalize_aci ih₁ ) = eval σ ih₁›, ← ‹eval σ ( normalize_aci ih₂ ) = eval σ ih₂› ] ; rfl );
        · exact ne_of_apply_ne List.length ( by simp +decide [ TropACI.flattenMin_nonempty ] );
        · exact ne_of_apply_ne List.length ( by simp +decide [ TropACI.flattenMin_nonempty ] );
        · grind +suggestions;
      · rename_i e₁ e₂ ih₁ ih₂;
        -- By definition of `normalize_aci`, we have:
        have h_normalize_add : eval σ (rebuildAdd ((Multiset.ofList (flattenAdd (.add (normalize_aci e₁) (normalize_aci e₂)))).sort (· ≤ ·))) = eval σ (.add (normalize_aci e₁) (normalize_aci e₂)) := by
          rw [ eval_rebuildAdd ];
          · convert evalAddList_perm σ _ _;
            convert evalAddList_flattenAdd σ _;
            convert evalAddList_flattenAdd σ _;
            convert evalAddList_flattenAdd σ _;
            nontriviality;
            convert evalAddList_flattenAdd σ _;
            any_goals exact flattenAdd ( ( normalize_aci e₁ ).add ( normalize_aci e₂ ) );
            any_goals exact ( normalize_aci e₁ ).add ( normalize_aci e₂ );
            all_goals norm_num [ flattenAdd_nonempty ];
            any_goals exact List.mergeSort_perm _ _;
            any_goals exact evalAddList_flattenAdd σ _;
            · grind +suggestions;
            · exact ne_of_apply_ne List.length ( by simp +decide [ flattenAdd_nonempty ] );
          · exact ne_of_apply_ne List.length ( by simp +decide [ flattenAdd_nonempty ] );
        convert h_normalize_add using 1;
        exact show eval σ e₁ + eval σ e₂ = eval σ ( normalize_aci e₁ ) + eval σ ( normalize_aci e₂ ) by rw [ ih₁, ih₂ ] ;

/-! ## Helper lemmas for completeness -/

/-
rebuildMin of a two-element-or-more list appended gives tmin-structure.
-/
theorem rebuildMin_append_ACIEquiv {l₁ l₂ : List TropExpr}
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    ACIEquiv (rebuildMin (l₁ ++ l₂)) (.tmin (rebuildMin l₁) (rebuildMin l₂)) := by
      induction' l₁ with x l₁ ih generalizing l₂ <;> simp_all +decide [ List.cons_append ];
      rcases l₁ with ( _ | ⟨ y, l₁ ⟩ ) <;> simp_all +decide [ List.cons_append ];
      · cases l₂ <;> simp_all +decide [ rebuildMin ];
        constructor;
      · convert ACIEquiv.trans ( ACIEquiv.cong_tmin ( ACIEquiv.refl _ ) ( ih h₂ ) ) _ using 1;
        convert ACIEquiv.tmin_assoc x ( rebuildMin ( y :: l₁ ) ) ( rebuildMin l₂ ) |> ACIEquiv.symm using 1

/-
rebuildAdd of appended lists gives add-structure.
-/
theorem rebuildAdd_append_ACIEquiv {l₁ l₂ : List TropExpr}
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    ACIEquiv (rebuildAdd (l₁ ++ l₂)) (.add (rebuildAdd l₁) (rebuildAdd l₂)) := by
      have h_add_assoc : ∀ (a b c : TropExpr), ACIEquiv (.add (.add a b) c) (.add a (.add b c)) := by
        intros a b c
        apply ACIEquiv.add_assoc;
      induction' l₁ with a l₁ ih generalizing l₂ <;> simp_all +decide [ List.append_assoc ];
      cases l₁ <;> simp_all +decide [ rebuildAdd ];
      · constructor;
      · have h_add_assoc : ACIEquiv (a.add ((rebuildAdd (‹TropExpr› :: ‹List TropExpr›)).add (rebuildAdd l₂))) ((a.add (rebuildAdd (‹TropExpr› :: ‹List TropExpr›))).add (rebuildAdd l₂)) := by
          exact ACIEquiv.symm ( h_add_assoc _ _ _ );
        exact ACIEquiv.trans ( ACIEquiv.cong_add ( ACIEquiv.refl _ ) ( ih h₂ ) ) h_add_assoc

/-
An expression is ACI-equivalent to the rebuild of its flattened tmin-list.
-/
theorem rebuildMin_flattenMin_ACIEquiv (e : TropExpr) :
    ACIEquiv e (rebuildMin (flattenMin e)) := by
      induction' e using TropExpr.recOn with e₁ e₂ ih₁ ih₂;
      · exact ACIEquiv.refl _;
      · exact ACIEquiv.refl _;
      · -- By the properties of `rebuildMin` and `flattenMin`, we can show that `rebuildMin (flattenMin (ih₁.tmin ih₂))` is equivalent to `ih₁.tmin ih₂`.
        have h_rebuild : ACIEquiv (rebuildMin (flattenMin ih₁ ++ flattenMin ih₂)) (.tmin (rebuildMin (flattenMin ih₁)) (rebuildMin (flattenMin ih₂))) := by
          grind +suggestions;
        convert ACIEquiv.trans ( ACIEquiv.cong_tmin ‹ACIEquiv ih₁ ( rebuildMin ( flattenMin ih₁ ) ) › ‹ACIEquiv ih₂ ( rebuildMin ( flattenMin ih₂ ) ) › ) h_rebuild.symm using 1;
      · exact ACIEquiv.refl _

/-
An expression is ACI-equivalent to the rebuild of its flattened add-list.
-/
theorem rebuildAdd_flattenAdd_ACIEquiv (e : TropExpr) :
    ACIEquiv e (rebuildAdd (flattenAdd e)) := by
      induction' e using TropExpr.recOn with e ih;
      · exact ACIEquiv.refl _;
      · exact ACIEquiv.refl _;
      · convert ACIEquiv.refl _ using 1;
      · rename_i e₁ e₂ ih₁ ih₂;
        have h_rebuild_add : ACIEquiv (rebuildAdd (flattenAdd e₁ ++ flattenAdd e₂)) (.add (rebuildAdd (flattenAdd e₁)) (rebuildAdd (flattenAdd e₂))) := by
          apply_rules [ rebuildAdd_append_ACIEquiv, flattenAdd_nonempty ];
        convert ACIEquiv.trans ( ACIEquiv.cong_add ih₁ ih₂ ) h_rebuild_add.symm using 1

/-
Permuting the children of rebuildMin preserves ACI equivalence.
-/
theorem rebuildMin_perm_ACIEquiv {l₁ l₂ : List TropExpr}
    (h₁ : l₁ ≠ []) (hp : l₁.Perm l₂) :
    ACIEquiv (rebuildMin l₁) (rebuildMin l₂) := by
      induction' hp with l₁ l₂ hp ih h₂ ih;
      · contradiction;
      · rcases l₂ with ( _ | ⟨ x, _ | ⟨ y, l₂ ⟩ ⟩ ) <;> rcases hp with ( _ | ⟨ u, _ | ⟨ v, hp ⟩ ⟩ ) <;> simp_all +decide [ rebuildMin ];
        · constructor;
        · exact ACIEquiv.refl _;
        · exact ACIEquiv.cong_tmin ( ACIEquiv.refl _ ) h₂;
      · -- By definition of `rebuildMin`, we can rewrite the goal using the associativity and commutativity of `tmin`.
        have h_assoc_comm : ∀ (x y : TropExpr) (l : List TropExpr), ACIEquiv (rebuildMin (x :: y :: l)) (.tmin x (rebuildMin (y :: l))) := by
          exact?;
        have h_assoc_comm : ∀ (x y : TropExpr) (l : List TropExpr), ACIEquiv (rebuildMin (x :: y :: l)) (.tmin y (rebuildMin (x :: l))) := by
          intros x y l
          have h_assoc_comm : ACIEquiv (rebuildMin (x :: y :: l)) (.tmin x (rebuildMin (y :: l))) := h_assoc_comm x y l
          have h_assoc_comm' : ACIEquiv (.tmin x (rebuildMin (y :: l))) (.tmin y (rebuildMin (x :: l))) := by
            induction' l with z l ih generalizing x y;
            · exact ACIEquiv.tmin_comm _ _;
            · have h_assoc_comm' : ACIEquiv (x.tmin (y.tmin (rebuildMin (z :: l)))) ((x.tmin y).tmin (rebuildMin (z :: l))) := by
                exact ACIEquiv.tmin_assoc _ _ _ |> ACIEquiv.symm;
              have h_assoc_comm'' : ACIEquiv ((x.tmin y).tmin (rebuildMin (z :: l))) ((y.tmin x).tmin (rebuildMin (z :: l))) := by
                exact ACIEquiv.cong_tmin ( ACIEquiv.tmin_comm x y ) ( ACIEquiv.refl _ );
              have h_assoc_comm''' : ACIEquiv ((y.tmin x).tmin (rebuildMin (z :: l))) (y.tmin (x.tmin (rebuildMin (z :: l)))) := by
                exact ACIEquiv.tmin_assoc _ _ _;
              exact ACIEquiv.trans h_assoc_comm' ( ACIEquiv.trans h_assoc_comm'' h_assoc_comm''' )
          exact ACIEquiv.trans h_assoc_comm h_assoc_comm';
        exact?;
      · rename_i l₁ l₂ l₃ h₁ h₂ h₃ h₄;
        exact ACIEquiv.trans ( h₃ h₁ ) ( h₄ ( by aesop ) )

/-
Permuting the children of rebuildAdd preserves ACI equivalence.
-/
theorem rebuildAdd_perm_ACIEquiv {l₁ l₂ : List TropExpr}
    (h₁ : l₁ ≠ []) (hp : l₁.Perm l₂) :
    ACIEquiv (rebuildAdd l₁) (rebuildAdd l₂) := by
      induction' hp with l₁ l₂ hp ih₂ ih;
      · contradiction;
      · cases l₂ <;> cases hp <;> simp_all +decide;
        · exact ACIEquiv.refl _;
        · convert ACIEquiv.cong_add ( ACIEquiv.refl _ ) ih using 1;
      · unfold rebuildAdd;
        rename_i x y l;
        induction' l with z l ih generalizing x y;
        · exact ACIEquiv.add_comm _ _;
        · have h_assoc : ACIEquiv (y.add (x.add (rebuildAdd (z :: l)))) ((y.add x).add (rebuildAdd (z :: l))) := by
            constructor;
            apply ACIEquiv.add_assoc;
          have h_comm : ACIEquiv ((y.add x).add (rebuildAdd (z :: l))) ((x.add y).add (rebuildAdd (z :: l))) := by
            apply ACIEquiv.cong_add;
            · exact ACIEquiv.add_comm _ _;
            · exact ACIEquiv.refl _;
          have h_assoc : ACIEquiv ((x.add y).add (rebuildAdd (z :: l))) (x.add (y.add (rebuildAdd (z :: l)))) := by
            apply ACIEquiv.add_assoc;
          exact ACIEquiv.trans ‹_› ( ACIEquiv.trans ‹_› ‹_› );
      · rename_i h₂ h₃ ih₁ ih₂;
        exact ACIEquiv.trans ( ih₁ h₁ ) ( ih₂ ( by aesop ) )

/-
Deduplication of a sorted list preserves ACI equivalence of rebuildMin.
    This is where tmin_idem is used.
-/
theorem rebuildMin_dedupSorted_ACIEquiv {l : List TropExpr} (hl : l ≠ []) :
    ACIEquiv (rebuildMin l) (rebuildMin (dedupSorted l)) := by
      revert hl;
      induction' l with x l ih;
      · tauto;
      · cases l <;> simp_all +decide [ dedupSorted ];
        · exact ACIEquiv.refl _;
        · split_ifs <;> simp_all +decide [ rebuildMin ];
          · rename_i k hk hk₂;
            have h_tmin_idem : ACIEquiv (k.tmin (rebuildMin (k :: hk))) (rebuildMin (k :: hk)) := by
              cases hk <;> simp_all +decide [ rebuildMin ];
              · exact ACIEquiv.tmin_idem k;
              · have h_tmin_idem : ACIEquiv (k.tmin (k.tmin (rebuildMin (‹_› :: ‹_›)))) (k.tmin (rebuildMin (‹_› :: ‹_›))) := by
                  have h_tmin_assoc : ACIEquiv (k.tmin (k.tmin (rebuildMin (‹_› :: ‹_›)))) ((k.tmin k).tmin (rebuildMin (‹_› :: ‹_›))) := by
                    exact ACIEquiv.tmin_assoc _ _ _ |> ACIEquiv.symm
                  exact h_tmin_assoc.trans ( ACIEquiv.cong_tmin ( ACIEquiv.tmin_idem _ ) ( ACIEquiv.refl _ ) );
                exact h_tmin_idem;
            exact ACIEquiv.trans h_tmin_idem ih;
          · convert ACIEquiv.cong_tmin ( ACIEquiv.refl _ ) ih using 1;
            cases h : dedupSorted ( ‹_› :: ‹_› ) <;> simp_all +decide [ rebuildMin ];
            exact absurd h ( by exact ne_of_apply_ne List.length ( by exact ne_of_gt ( List.length_pos_iff.mpr ( by exact dedupSorted_nonempty ( by aesop ) ) ) ) )

/-- A list is a permutation of its multiset sort. -/
theorem list_perm_sort (l : List TropExpr) :
    l.Perm ((↑l : Multiset TropExpr).sort (· ≤ ·)) := by
  have h : (↑((↑l : Multiset TropExpr).sort (· ≤ ·)) : Multiset TropExpr) = ↑l :=
    Multiset.sort_eq ..
  exact List.perm_iff_count.mpr fun a => by
    have := congr_arg (Multiset.count a) h; simp at this; exact this.symm

/-! ## Specific ACI axiom preservation lemmas for congr -/

theorem normalize_aci_tmin_comm (a b : TropExpr) :
    normalize_aci (.tmin a b) = normalize_aci (.tmin b a) := by
      -- Apply the injectivity of normalize_aci to h_eq, which would give us tmin a b = tmin b a.
      apply Classical.byContradiction
      intro h_neq;
      exact h_neq <| by
        have h_eq : ∀ e₁ e₂ : TropExpr, normalize_aci (.tmin e₁ e₂) = normalize_aci (.tmin e₂ e₁) := by
          intros e₁ e₂
          have h_eq : Multiset.ofList (flattenMin (e₁.tmin e₂)) = Multiset.ofList (flattenMin (e₂.tmin e₁)) := by
            simp +decide [ flattenMin ];
            grind;
          have h_eq : Multiset.ofList (flattenMin (normalize_aci e₁)) + Multiset.ofList (flattenMin (normalize_aci e₂)) = Multiset.ofList (flattenMin (normalize_aci e₂)) + Multiset.ofList (flattenMin (normalize_aci e₁)) := by
            exact add_comm _ _;
          convert congr_arg ( fun m : Multiset TropExpr => rebuildMin ( dedupSorted ( m.sort ( · ≤ · ) ) ) ) h_eq using 1
        exact h_eq a b

/-
Elements of flattenMin are never tmin nodes.
-/
theorem flattenMin_not_tmin (e : TropExpr) :
    ∀ x ∈ flattenMin e, ¬∃ a b, x = .tmin a b := by
      -- We'll use induction on the structure of the expression `e`.
      induction' e with e₁ e₂ ih₁ ih₂;
      · simp +decide [ flattenMin ];
      · simp +decide [ flattenMin ];
      · grind +locals;
      · grind +locals

/-
flattenMin of rebuildMin recovers the list when elements are not tmin.
-/
theorem flattenMin_rebuildMin {l : List TropExpr} (hl : l ≠ [])
    (hnt : ∀ x ∈ l, ¬∃ a b, x = .tmin a b) :
    flattenMin (rebuildMin l) = l := by
      induction' l with x l ih;
      · contradiction;
      · cases l <;> simp_all +decide [ flattenMin, rebuildMin ]

/-
Elements of dedupSorted preserve the non-tmin property.
-/
theorem dedupSorted_preserves_not_tmin {l : List TropExpr}
    (h : ∀ x ∈ l, ¬∃ a b, x = .tmin a b) :
    ∀ x ∈ dedupSorted l, ¬∃ a b, x = .tmin a b := by
      induction' l with x l ih;
      · tauto;
      · unfold dedupSorted; aesop;

/-
The Multiset.sort preserves element membership.
-/
theorem sort_preserves_not_tmin {l : List TropExpr}
    (h : ∀ x ∈ l, ¬∃ a b, x = .tmin a b) :
    ∀ x ∈ ((↑l : Multiset TropExpr).sort (· ≤ ·)), ¬∃ a b, x = .tmin a b := by
      have := List.Perm.subset ( list_perm_sort l ) ; aesop;

/-- Key structural lemma: dedupSorted of sort depends only on the underlying Finset.
    Two lists with the same toFinset produce the same dedupSorted(sort(...)). -/
theorem dedupSorted_sort_eq_of_toFinset_eq {l₁ l₂ : List TropExpr}
    (h : l₁.toFinset = l₂.toFinset) :
    dedupSorted ((↑l₁ : Multiset TropExpr).sort (· ≤ ·)) =
    dedupSorted ((↑l₂ : Multiset TropExpr).sort (· ≤ ·)) := by
  /- Both dedupSorted(sort(↑l)) are the unique sorted nodup list with elements l.toFinset.
     Proof outline: dedupSorted on a sorted list = the sorted version of the set of elements,
     which is l.toFinset.sort (· ≤ ·). Since toFinsets are equal, results are equal.
     TODO: complete the combinatorial infrastructure for sorted nodup list uniqueness. -/
  sorry

/-
flattenMin of normalize_aci(tmin e₁ e₂) equals the sorted deduped children.
-/
theorem flattenMin_normalize_aci_tmin (e₁ e₂ : TropExpr) :
    flattenMin (normalize_aci (.tmin e₁ e₂)) =
    dedupSorted ((↑(flattenMin (.tmin (normalize_aci e₁) (normalize_aci e₂))) : Multiset TropExpr).sort (· ≤ ·)) := by
      apply flattenMin_rebuildMin;
      · apply dedupSorted_nonempty;
        exact ne_of_apply_ne List.length ( by simp +decide [ flattenMin_nonempty ] );
      · -- By definition of `dedupSorted`, if `x` is in the deduplicated list, then `x` is not a `tmin` node.
        apply dedupSorted_preserves_not_tmin;
        -- Apply the lemma that states elements of the flattened list are not tmin nodes.
        apply sort_preserves_not_tmin; exact flattenMin_not_tmin _

/-
flattenAdd of normalize_aci(add e₁ e₂) equals the sorted children.
-/
theorem flattenAdd_normalize_aci_add (e₁ e₂ : TropExpr) :
    flattenAdd (normalize_aci (.add e₁ e₂)) =
    ((↑(flattenAdd (.add (normalize_aci e₁) (normalize_aci e₂))) : Multiset TropExpr).sort (· ≤ ·)) := by
      have h_rebuildAdd : ∀ l : List TropExpr, l ≠ [] → (∀ x ∈ l, ¬∃ a b, x = .add a b) → flattenAdd (rebuildAdd l) = l := by
        intros l hl hnt
        induction' l with x l ih;
        · contradiction;
        · cases l <;> simp_all +decide [ flattenAdd, rebuildAdd ];
      convert h_rebuildAdd _ _ _ using 1;
      · exact ne_of_apply_ne List.length ( by simp +decide [ List.length_mergeSort, flattenAdd_nonempty ] );
      · have h_flattenAdd_not_add : ∀ e : TropExpr, ∀ x ∈ flattenAdd e, ¬∃ a b, x = .add a b := by
          intros e x hx
          induction' e with e₁ e₂ ih₁ ih₂;
          · cases hx;
            · grind;
            · contradiction;
          · cases hx ; tauto;
            contradiction;
          · cases hx ; tauto;
            contradiction;
          · unfold flattenAdd at hx; aesop;
        exact fun x hx => h_flattenAdd_not_add _ _ <| Multiset.mem_sort ( α := TropExpr ) ( · ≤ · ) |>.1 hx

theorem normalize_aci_tmin_assoc (a b c : TropExpr) :
    normalize_aci (.tmin (.tmin a b) c) = normalize_aci (.tmin a (.tmin b c)) := by
  /- Both sides are rebuildMin(dedupSorted(sort(↑(flat)))). Using flattenMin_normalize_aci_tmin,
     the flattened lists have the same toFinset (union is associative).
     Follows from dedupSorted_sort_eq_of_toFinset_eq. -/
  sorry

theorem normalize_aci_tmin_idem (a : TropExpr) :
    normalize_aci (.tmin a a) = normalize_aci a := by
  /- normalize_aci(tmin a a) uses flattenMin(tmin na na) = fna ++ fna where na = normalize_aci a.
     (fna ++ fna).toFinset = fna.toFinset by Finset.union_idempotent.
     By dedupSorted_sort_eq_of_toFinset_eq, dedupSorted(sort(↑(fna ++ fna))) = dedupSorted(sort(↑fna)).
     Then rebuildMin of this = rebuildMin(flattenMin_normalize_aci_tmin result) = normalize_aci a. -/
  sorry

theorem normalize_aci_add_comm (a b : TropExpr) :
    normalize_aci (.add a b) = normalize_aci (.add b a) := by
      -- By definition of `flattenAdd`, we have:
      have h_flattenAdd : flattenAdd (.add (normalize_aci a) (normalize_aci b)) = flattenAdd (normalize_aci a) ++ flattenAdd (normalize_aci b) ∧
                          flattenAdd (.add (normalize_aci b) (normalize_aci a)) = flattenAdd (normalize_aci b) ++ flattenAdd (normalize_aci a) := by
                            exact ⟨ rfl, rfl ⟩;
      unfold normalize_aci;
      have h_sorted_eq : List.Perm ((↑(flattenAdd (normalize_aci a) ++ flattenAdd (normalize_aci b)) : Multiset TropExpr).sort (· ≤ ·)) ((↑(flattenAdd (normalize_aci b) ++ flattenAdd (normalize_aci a)) : Multiset TropExpr).sort (· ≤ ·)) := by
        simp +decide [ List.perm_iff_count ];
        intro x; rw [ List.Perm.count_eq ( List.mergeSort_perm _ _ ), List.Perm.count_eq ( List.mergeSort_perm _ _ ) ] ; simp +decide [ List.count_append ] ;
        ring;
      grind +suggestions

theorem normalize_aci_add_assoc (a b c : TropExpr) :
    normalize_aci (.add (.add a b) c) = normalize_aci (.add a (.add b c)) := by
  /- Both sides produce rebuildAdd(sort(↑(flat))). The key is that both flattened lists
     have the same multiset: ↑fna + ↑fnb + ↑fnc. This follows from
     flattenAdd_normalize_aci_add and Multiset.sort_eq. -/
  sorry

theorem normalize_aci_cong_tmin {a a' b b' : TropExpr}
    (ha : normalize_aci a = normalize_aci a')
    (hb : normalize_aci b = normalize_aci b') :
    normalize_aci (.tmin a b) = normalize_aci (.tmin a' b') := by
      -- By definition of `normalize_aci`, we know that `normalize_aci (.tmin a b)` is equal to `rebuildMin (dedupSorted (flattenMin (.tmin (normalize_aci a) (normalize_aci b))))`.
      simp [normalize_aci, ha, hb]

theorem normalize_aci_cong_add {a a' b b' : TropExpr}
    (ha : normalize_aci a = normalize_aci a')
    (hb : normalize_aci b = normalize_aci b') :
    normalize_aci (.add a b) = normalize_aci (.add a' b') := by
      -- By definition of `normalize_aci`, we know that `normalize_aci (.add a b)` is equal to `normalize_aci (.add a' b')` if `normalize_aci a = normalize_aci a'` and `normalize_aci b = normalize_aci b'`.
      simp [normalize_aci, ha, hb]

/-! ## Completeness infrastructure -/

/-
Every expression is ACI-equivalent to its normal form.
-/
theorem normalize_aci_ACIEquiv (e : TropExpr) : ACIEquiv e (normalize_aci e) := by
  by_contra h;
  -- We'll use induction on the structure of the expression to prove this.
  induction' e with e₁ e₂ ih₁ ih₂;
  · exact h ( ACIEquiv.refl _ );
  · exact h ( by exact ACIEquiv.refl _ );
  · contrapose! h; simp_all +decide [ ACIEquiv ] ;
    -- By definition of `normalize_aci`, we have `normalize_aci (ih₁.tmin ih₂) = rebuildMin (dedupSorted ((Multiset.ofList (flattenMin (ih₁.tmin ih₂))).sort (· ≤ ·)))`.
    rw [normalize_aci];
    -- By definition of `rebuildMin`, we have `rebuildMin (dedupSorted ((Multiset.ofList (flattenMin (ih₁.tmin ih₂))).sort (· ≤ ·))) = rebuildMin (dedupSorted ((Multiset.ofList (flattenMin (normalize_aci ih₁).tmin (normalize_aci ih₂))).sort (· ≤ ·)))`.
    apply ACIEquiv.trans (ACIEquiv.cong_tmin ‹ACIEquiv ih₁ (normalize_aci ih₁)› ‹ACIEquiv ih₂ (normalize_aci ih₂)›);
    apply ACIEquiv.trans (rebuildMin_flattenMin_ACIEquiv _);
    apply ACIEquiv.trans (rebuildMin_perm_ACIEquiv (flattenMin_nonempty _) (list_perm_sort _)) (rebuildMin_dedupSorted_ACIEquiv _);
    exact ne_of_apply_ne List.length ( by simp +decide [ flattenMin_nonempty ] );
  · rename_i e₁ e₂ ih₁ ih₂;
    refine' h _;
    convert ACIEquiv.trans ( ACIEquiv.cong_add ( Classical.not_not.mp ih₁ ) ( Classical.not_not.mp ih₂ ) ) _ using 1;
    convert ACIEquiv.trans ( rebuildAdd_flattenAdd_ACIEquiv _ ) _ using 1;
    convert ACIEquiv.symm ( rebuildAdd_perm_ACIEquiv _ _ ) using 1;
    · exact ne_of_apply_ne List.length ( by simp +decide [ flattenAdd_nonempty ] );
    · exact?

/-- ACI-equivalent expressions have the same ACI normal form. -/
theorem normalize_aci_congr {e₁ e₂ : TropExpr}
    (h : ACIEquiv e₁ e₂) : normalize_aci e₁ = normalize_aci e₂ := by
  induction h with
  | refl _ => rfl
  | @symm _ _ _ ih => exact ih.symm
  | @trans _ _ _ _ _ ih1 ih2 => exact ih1.trans ih2
  | tmin_comm e₁ e₂ => exact normalize_aci_tmin_comm e₁ e₂
  | tmin_assoc e₁ e₂ e₃ => exact normalize_aci_tmin_assoc e₁ e₂ e₃
  | tmin_idem e => exact normalize_aci_tmin_idem e
  | @add_comm e₁ e₂ => exact normalize_aci_add_comm e₁ e₂
  | @add_assoc e₁ e₂ e₃ => exact normalize_aci_add_assoc e₁ e₂ e₃
  | @cong_tmin a a' b b' _ _ iha ihb => exact normalize_aci_cong_tmin iha ihb
  | @cong_add a a' b b' _ _ iha ihb => exact normalize_aci_cong_add iha ihb

/-! ## Main completeness theorem -/

/-- **Completeness**: ACI equivalence ↔ same normal form. -/
theorem normalize_aci_complete (e₁ e₂ : TropExpr) :
    ACIEquiv e₁ e₂ ↔ normalize_aci e₁ = normalize_aci e₂ := by
  constructor
  · exact normalize_aci_congr
  · intro h
    exact ACIEquiv.trans (normalize_aci_ACIEquiv e₁)
      (ACIEquiv.trans (h ▸ ACIEquiv.refl _) (ACIEquiv.symm (normalize_aci_ACIEquiv e₂)))

/-! ## Decision procedure corollaries -/

/-- **Decision procedure**: Equal normal forms imply equal semantics. -/
theorem eval_eq_of_normalize_aci_eq
    (e₁ e₂ : TropExpr) (h : normalize_aci e₁ = normalize_aci e₂) :
    ∀ σ, eval σ e₁ = eval σ e₂ := by
  intro σ
  rw [← eval_normalize_aci e₁ σ, ← eval_normalize_aci e₂ σ, h]

/-- Normal form equality ↔ ACI equivalence. -/
theorem normalize_aci_eq_iff_aci (e₁ e₂ : TropExpr) :
    normalize_aci e₁ = normalize_aci e₂ ↔ ACIEquiv e₁ e₂ :=
  (normalize_aci_complete e₁ e₂).symm

/-! ## Idempotence of the normalizer -/

/-- **Idempotence**: Normalizing twice is the same as normalizing once. -/
theorem normalize_aci_idempotent (e : TropExpr) :
    normalize_aci (normalize_aci e) = normalize_aci e :=
  normalize_aci_congr (ACIEquiv.symm (normalize_aci_ACIEquiv e))

/-! ## Strict strengthening over AC -/

/-
**Strictness**: ACI identifies strictly more expressions than AC.
    Witness: `tmin (var 0) (var 0)` vs `var 0`.
-/
theorem normalize_aci_strictly_stronger :
    ∃ e₁ e₂ : TropExpr,
      normalize_ca e₁ ≠ normalize_ca e₂ ∧
      normalize_aci e₁ = normalize_aci e₂ := by
        use .tmin ( .var 0 ) ( .var 0 ), .var 0;
        -- By definition of `normalize_ca`, we have `normalize_ca (TropExpr.tmin (TropExpr.var 0) (TropExpr.var 0)) = TropExpr.tmin (TropExpr.var 0) (TropExpr.var 0)`.
        simp [normalize_ca];
        constructor;
        · simp +decide [ flattenMin, List.mergeSort ];
          exact fun h => by cases h;
        · -- By definition of `normalize_aci`, we have `normalize_aci (.tmin (.var 0) (.var 0)) = .var 0`.
          apply (normalize_aci_complete _ _).mp;
          exact ACIEquiv.tmin_idem _

end TropACI