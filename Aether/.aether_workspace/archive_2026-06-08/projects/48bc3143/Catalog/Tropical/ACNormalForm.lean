/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Canonical Forms for Tropical AC Normalization

## Overview

This file defines a canonicalization procedure for tropical expressions under
associativity and commutativity (AC) of `min` and `+`. The key result is a
certified decision procedure: two AC-equivalent tropical expressions normalize
to the same canonical form.

## Main definitions

* `TropicalAC.TropExpr` — Syntax of tropical expressions (min-plus convention)
* `TropicalAC.eval` — Evaluation semantics: `tmin ↦ min`, `add ↦ +`
* `TropicalAC.ACEquiv` — The AC congruence relation on expressions
* `TropicalAC.normalize_ca` — The AC canonicalization function

## Main results

* `TropicalAC.eval_normalize_ca` — **Soundness**: normalization preserves semantics
* `TropicalAC.normalize_ca_idempotent` — **Idempotence**: normalizing twice = once
* `TropicalAC.normalize_ca_complete` — **Completeness**: AC-equivalent expressions
  have the same normal form

## Why completeness holds only for the AC fragment

The distributive law `a + min(b,c) = min(a+b, a+c)` holds semantically in `(ℝ, min, +)`
but is NOT part of the AC congruence. Full semantic completeness would require
quotienting by distributivity as well, which requires a fundamentally different
normal form (tropical polynomial normal form).

The AC canonicalization handles the purely structural equalities (commutativity
and associativity) orthogonal to algebraic identities.
-/
import Mathlib

noncomputable section

open Classical

namespace TropicalAC

/-! ## Tropical Expression Syntax -/

/-- Tropical expression syntax (min-plus convention). -/
inductive TropExpr where
  | const : ℝ → TropExpr
  | var   : ℕ → TropExpr
  | tmin  : TropExpr → TropExpr → TropExpr
  | add   : TropExpr → TropExpr → TropExpr

/-! ## Evaluation Semantics -/

/-- Evaluate a tropical expression under a variable assignment `σ`. -/
def eval (σ : ℕ → ℝ) : TropExpr → ℝ
  | .const r     => r
  | .var n       => σ n
  | .tmin e₁ e₂  => min (eval σ e₁) (eval σ e₂)
  | .add e₁ e₂   => eval σ e₁ + eval σ e₂

/-! ## AC Congruence Relation -/

/-- The AC congruence on tropical expressions. -/
inductive ACEquiv : TropExpr → TropExpr → Prop
  | refl (e : TropExpr) : ACEquiv e e
  | symm {e₁ e₂ : TropExpr} : ACEquiv e₁ e₂ → ACEquiv e₂ e₁
  | trans {e₁ e₂ e₃ : TropExpr} : ACEquiv e₁ e₂ → ACEquiv e₂ e₃ → ACEquiv e₁ e₃
  | tmin_comm (e₁ e₂ : TropExpr) : ACEquiv (.tmin e₁ e₂) (.tmin e₂ e₁)
  | tmin_assoc (e₁ e₂ e₃ : TropExpr) :
      ACEquiv (.tmin (.tmin e₁ e₂) e₃) (.tmin e₁ (.tmin e₂ e₃))
  | add_comm (e₁ e₂ : TropExpr) : ACEquiv (.add e₁ e₂) (.add e₂ e₁)
  | add_assoc (e₁ e₂ e₃ : TropExpr) :
      ACEquiv (.add (.add e₁ e₂) e₃) (.add e₁ (.add e₂ e₃))
  | cong_tmin {a a' b b' : TropExpr} :
      ACEquiv a a' → ACEquiv b b' → ACEquiv (.tmin a b) (.tmin a' b')
  | cong_add {a a' b b' : TropExpr} :
      ACEquiv a a' → ACEquiv b b' → ACEquiv (.add a b) (.add a' b')

/-
AC equivalence preserves evaluation semantics.
-/
theorem ACEquiv.eval_eq {e₁ e₂ : TropExpr} (h : ACEquiv e₁ e₂) (σ : ℕ → ℝ) :
    eval σ e₁ = eval σ e₂ := by
  induction h;
  all_goals norm_num [ eval ];
  all_goals try linarith;
  · grind +splitImp;
  · exact min_assoc _ _ _;
  · grind +splitImp

/-! ## Linear Order on TropExpr -/

instance : LinearOrder TropExpr := linearOrderOfSTO WellOrderingRel

/-! ## Flattening and Rebuilding -/

/-- Flatten a `tmin` tree into a list of non-`tmin` children. -/
def flattenMin : TropExpr → List TropExpr
  | .tmin a b => flattenMin a ++ flattenMin b
  | e => [e]

/-- Flatten an `add` tree into a list of non-`add` children. -/
def flattenAdd : TropExpr → List TropExpr
  | .add a b => flattenAdd a ++ flattenAdd b
  | e => [e]

/-- Rebuild a right-associated `tmin` chain from a list. -/
def rebuildMin : List TropExpr → TropExpr
  | [] => .const 0
  | [e] => e
  | e :: es => .tmin e (rebuildMin es)

/-- Rebuild a right-associated `add` chain from a list. -/
def rebuildAdd : List TropExpr → TropExpr
  | [] => .const 0
  | [e] => e
  | e :: es => .add e (rebuildAdd es)

/-! ## Normalization -/

/-- AC-canonicalize a tropical expression. -/
def normalize_ca : TropExpr → TropExpr
  | .const r => .const r
  | .var n   => .var n
  | .tmin a b =>
      let a' := normalize_ca a
      let b' := normalize_ca b
      let children := (↑(flattenMin a') + ↑(flattenMin b') : Multiset TropExpr)
      rebuildMin (children.sort (· ≤ ·))
  | .add a b =>
      let a' := normalize_ca a
      let b' := normalize_ca b
      let children := (↑(flattenAdd a') + ↑(flattenAdd b') : Multiset TropExpr)
      rebuildAdd (children.sort (· ≤ ·))

/-! ## Structural predicates -/

def notTmin : TropExpr → Prop
  | .tmin _ _ => False
  | _ => True

def notAdd : TropExpr → Prop
  | .add _ _ => False
  | _ => True

/-! ## Helper lemmas for flattening -/

theorem flattenMin_nonempty (e : TropExpr) : (flattenMin e) ≠ [] := by
  cases e <;> simp [flattenMin]
  case tmin a b =>
    intro h
    exact absurd h (flattenMin_nonempty a)

theorem flattenAdd_nonempty (e : TropExpr) : (flattenAdd e) ≠ [] := by
  cases e <;> simp [flattenAdd]
  case add a b =>
    intro h
    exact absurd h (flattenAdd_nonempty a)

theorem flattenMin_length_pos (e : TropExpr) : (flattenMin e).length ≥ 1 := by
  rcases hl : flattenMin e with _ | ⟨h, t⟩
  · exact absurd hl (flattenMin_nonempty e)
  · simp

theorem flattenAdd_length_pos (e : TropExpr) : (flattenAdd e).length ≥ 1 := by
  rcases hl : flattenAdd e with _ | ⟨h, t⟩
  · exact absurd hl (flattenAdd_nonempty e)
  · simp

theorem flattenMin_notTmin (e : TropExpr) : ∀ x ∈ flattenMin e, notTmin x := by
  induction e with
  | tmin a b iha ihb =>
    simp [flattenMin]
    intro x hx
    rcases hx with h | h
    · exact iha x h
    · exact ihb x h
  | _ => simp [flattenMin, notTmin]

theorem flattenAdd_notAdd (e : TropExpr) : ∀ x ∈ flattenAdd e, notAdd x := by
  induction e with
  | add a b iha ihb =>
    simp [flattenAdd]
    intro x hx
    rcases hx with h | h
    · exact iha x h
    · exact ihb x h
  | _ => simp [flattenAdd, notAdd]

theorem flattenMin_of_notTmin {e : TropExpr} (h : notTmin e) : flattenMin e = [e] := by
  cases e <;> simp_all [flattenMin, notTmin]

theorem flattenAdd_of_notAdd {e : TropExpr} (h : notAdd e) : flattenAdd e = [e] := by
  cases e <;> simp_all [flattenAdd, notAdd]

/-! ## Flatten-rebuild round-trip -/

theorem flattenMin_rebuildMin {l : List TropExpr} (hl : l ≠ [])
    (hnt : ∀ x ∈ l, notTmin x) : flattenMin (rebuildMin l) = l := by
  rcases l with ( _ | ⟨ e, _ | ⟨ e', l ⟩ ⟩ ) <;> simp_all +decide;
  · -- By definition of `rebuildMin`, we have `rebuildMin [e] = e`.
    have h_rebuild : rebuildMin [e] = e := by
      rfl
    rw [h_rebuild];
    exact?;
  · induction' l with l ih generalizing e e' <;> simp_all +decide [ flattenMin, rebuildMin ];
    · rw [ flattenMin_of_notTmin hnt.1, flattenMin_of_notTmin hnt.2 ];
      rfl;
    · rw [ flattenMin_of_notTmin hnt.1 ] ; aesop

theorem flattenAdd_rebuildAdd {l : List TropExpr} (hl : l ≠ [])
    (hna : ∀ x ∈ l, notAdd x) : flattenAdd (rebuildAdd l) = l := by
  rcases l with ( _ | ⟨ x, _ | ⟨ y, l ⟩ ⟩ ) <;> simp_all +decide;
  · exact?;
  · induction' l with z l ih generalizing x y <;> simp_all +decide [ flattenAdd, rebuildAdd ];
    · rw [ flattenAdd_of_notAdd hna.1, flattenAdd_of_notAdd hna.2 ];
      rfl;
    · cases x <;> cases y <;> cases z <;> tauto

/-! ## List evaluation -/

def evalMinList (σ : ℕ → ℝ) : List TropExpr → ℝ
  | [] => 0
  | [e] => eval σ e
  | e :: es => min (eval σ e) (evalMinList σ es)

def evalAddList (σ : ℕ → ℝ) : List TropExpr → ℝ
  | [] => 0
  | [e] => eval σ e
  | e :: es => eval σ e + evalAddList σ es

theorem eval_rebuildMin (σ : ℕ → ℝ) {l : List TropExpr} (hl : l ≠ []) :
    eval σ (rebuildMin l) = evalMinList σ l := by
  -- We proceed by induction on the length of the list `l`.
  induction' l with x xs ih
  all_goals generalize_proofs at *;
  · contradiction;
  · rcases xs with ( _ | ⟨ y, ys ⟩ ) <;> simp_all +decide [ evalMinList ];
    · rfl;
    · exact?

theorem eval_rebuildAdd (σ : ℕ → ℝ) {l : List TropExpr} (hl : l ≠ []) :
    eval σ (rebuildAdd l) = evalAddList σ l := by
  induction' l with e l ih;
  · contradiction;
  · cases l <;> simp_all +decide [ rebuildAdd, evalAddList ];
    exact ih ▸ rfl

theorem evalMinList_perm (σ : ℕ → ℝ) {l₁ l₂ : List TropExpr}
    (hl₁ : l₁ ≠ [])
    (hp : l₁.Perm l₂) :
    evalMinList σ l₁ = evalMinList σ l₂ := by
  induction' hp with l₁ l₂ hp ih₂ ih;
  · rfl;
  · rcases l₂ with ( _ | ⟨ a, _ | ⟨ b, l₂ ⟩ ⟩ ) <;> simp_all +decide [ evalMinList ];
    · cases hp <;> aesop;
    · cases hp <;> simp_all +decide [ evalMinList ];
  · induction' ‹List TropExpr› with z l ih <;> simp +decide [ evalMinList, * ];
    · exact min_comm _ _;
    · grind;
  · grind +suggestions

theorem evalAddList_perm (σ : ℕ → ℝ) {l₁ l₂ : List TropExpr}
    (hl₁ : l₁ ≠ [])
    (hp : l₁.Perm l₂) :
    evalAddList σ l₁ = evalAddList σ l₂ := by
  induction' hp with l₁ l₂ hp ih₂ ih;
  · rfl;
  · by_cases h : l₂ = [] <;> simp_all +decide [ evalAddList ];
    grind +locals;
  · rename_i x y l;
    -- By definition of `evalAddList`, we can expand both sides.
    have h_expand : evalAddList σ (y :: x :: l) = eval σ y + evalAddList σ (x :: l) ∧ evalAddList σ (x :: y :: l) = eval σ x + evalAddList σ (y :: l) := by
      exact ⟨ rfl, rfl ⟩;
    have h_expand : evalAddList σ (x :: l) = eval σ x + evalAddList σ l ∧ evalAddList σ (y :: l) = eval σ y + evalAddList σ l := by
      cases l <;> simp +decide [ evalAddList ];
    linarith;
  · aesop

theorem evalMinList_append (σ : ℕ → ℝ) {l₁ l₂ : List TropExpr}
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    evalMinList σ (l₁ ++ l₂) = min (evalMinList σ l₁) (evalMinList σ l₂) := by
  induction' l₁ with a l ih generalizing l₂ <;> simp +decide [ *, evalMinList ];
  · contradiction;
  · cases l <;> simp_all +decide [ evalMinList ];
    rw [ min_assoc ]

theorem evalAddList_append (σ : ℕ → ℝ) {l₁ l₂ : List TropExpr}
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    evalAddList σ (l₁ ++ l₂) = evalAddList σ l₁ + evalAddList σ l₂ := by
  induction' l₁ with a l₁ ih generalizing l₂ <;> simp_all +decide [ List.append_assoc ];
  rcases l₁ with ( _ | ⟨ b, l₁ ⟩ ) <;> simp_all +decide [ evalAddList ];
  ring

theorem evalMinList_flattenMin (σ : ℕ → ℝ) (e : TropExpr) :
    evalMinList σ (flattenMin e) = eval σ e := by
  -- By definition of `flattenMin`, we know that `flattenMin e` is a list of `tmin`-free expressions.
  induction' e with e₁ e₂ ih₁ ih₂;
  · rfl;
  · rfl;
  · -- By definition of `flattenMin`, we know that `flattenMin (ih₁.tmin ih₂) = flattenMin ih₁ ++ flattenMin ih₂`.
    have h_flattenMin_tmin : flattenMin (ih₁.tmin ih₂) = flattenMin ih₁ ++ flattenMin ih₂ := by
      rfl;
    -- By definition of `evalMinList`, we know that `evalMinList σ (flattenMin ih₁ ++ flattenMin ih₂)` is the minimum of `evalMinList σ (flattenMin ih₁)` and `evalMinList σ (flattenMin ih₂)`.
    have h_evalMinList_append : evalMinList σ (flattenMin ih₁ ++ flattenMin ih₂) = min (evalMinList σ (flattenMin ih₁)) (evalMinList σ (flattenMin ih₂)) := by
      grind +suggestions;
    aesop;
  · unfold evalMinList; aesop;

theorem evalAddList_flattenAdd (σ : ℕ → ℝ) (e : TropExpr) :
    evalAddList σ (flattenAdd e) = eval σ e := by
  -- We'll use induction on `e`.
  induction' e with e ih;
  · rfl;
  · rfl;
  · exact?;
  · rename_i a b ha hb;
    rw [ show flattenAdd ( a.add b ) = flattenAdd a ++ flattenAdd b from ?_ ];
    · rw [ evalAddList_append ];
      · exact ha.symm ▸ hb.symm ▸ rfl;
      · exact?;
      · exact?;
    · rfl

/-! ## Main theorems -/

/-
**Soundness**: normalization preserves evaluation semantics.
-/
theorem eval_normalize_ca (σ : ℕ → ℝ) (e : TropExpr) :
    eval σ (normalize_ca e) = eval σ e := by
  -- We proceed by induction on the structure of `e`.
  induction' e with e ih_e;
  · rfl;
  · rfl;
  · rename_i a b ha hb;
    -- By definition of `normalize_ca`, we have:
    have h_normalize_tmin : normalize_ca (a.tmin b) = rebuildMin ((↑(flattenMin (normalize_ca a)) + ↑(flattenMin (normalize_ca b)) : Multiset TropExpr).sort (· ≤ ·)) := by
      rfl;
    -- By definition of `rebuildMin`, we have:
    have h_rebuildMin : eval σ (rebuildMin ((↑(flattenMin (normalize_ca a)) + ↑(flattenMin (normalize_ca b)) : Multiset TropExpr).sort (· ≤ ·))) = evalMinList σ ((↑(flattenMin (normalize_ca a)) + ↑(flattenMin (normalize_ca b)) : Multiset TropExpr).sort (· ≤ ·)) := by
      apply eval_rebuildMin;
      exact ne_of_apply_ne List.length ( by simp +decide [ List.length_mergeSort, flattenMin_nonempty ] );
    -- By definition of `evalMinList`, we have:
    have h_evalMinList : evalMinList σ ((↑(flattenMin (normalize_ca a)) + ↑(flattenMin (normalize_ca b)) : Multiset TropExpr).sort (· ≤ ·)) = evalMinList σ (flattenMin (normalize_ca a) ++ flattenMin (normalize_ca b)) := by
      apply evalMinList_perm;
      · exact ne_of_apply_ne List.length ( by simp +decide [ List.length_mergeSort, flattenMin_nonempty ] );
      · have h_perm : Multiset.ofList ((↑(flattenMin (normalize_ca a)) + ↑(flattenMin (normalize_ca b)) : Multiset TropExpr).sort (· ≤ ·)) = Multiset.ofList (flattenMin (normalize_ca a) ++ flattenMin (normalize_ca b)) := by
          grind +suggestions;
        exact Multiset.coe_eq_coe.mp h_perm;
    have h_evalMinList_append : evalMinList σ (flattenMin (normalize_ca a) ++ flattenMin (normalize_ca b)) = min (evalMinList σ (flattenMin (normalize_ca a))) (evalMinList σ (flattenMin (normalize_ca b))) := by
      grind +suggestions;
    have h_evalMinList_flattenMin : evalMinList σ (flattenMin (normalize_ca a)) = eval σ (normalize_ca a) ∧ evalMinList σ (flattenMin (normalize_ca b)) = eval σ (normalize_ca b) := by
      exact ⟨ evalMinList_flattenMin σ _, evalMinList_flattenMin σ _ ⟩;
    aesop;
  · rename_i a b ha hb;
    -- By definition of `normalize_ca`, we have:
    have h_norm_add : eval σ (normalize_ca (a.add b)) = evalAddList σ ((↑(flattenAdd (normalize_ca a)) + ↑(flattenAdd (normalize_ca b)) : Multiset TropExpr).sort (· ≤ ·)) := by
      apply eval_rebuildAdd;
      exact ne_of_apply_ne List.length ( by simp +decide [ List.length_mergeSort, flattenAdd_nonempty ] );
    -- By definition of `evalAddList`, we have:
    have h_eval_add : evalAddList σ ((↑(flattenAdd (normalize_ca a)) + ↑(flattenAdd (normalize_ca b)) : Multiset TropExpr).sort (· ≤ ·)) = evalAddList σ (flattenAdd (normalize_ca a) ++ flattenAdd (normalize_ca b)) := by
      apply evalAddList_perm;
      · exact ne_of_apply_ne List.length ( by simp +decide [ flattenAdd_nonempty ] );
      · simp +decide;
        exact?;
    rw [ h_norm_add, h_eval_add, evalAddList_append ];
    · rw [ evalAddList_flattenAdd, evalAddList_flattenAdd, ha, hb, show eval σ ( a.add b ) = eval σ a + eval σ b from rfl ];
    · exact?;
    · grind +suggestions

/-! ## Key multiset lemmas for completeness -/

/-
The multiset.sort of a nonempty multiset is nonempty.
-/
theorem sort_ne_nil {m : Multiset TropExpr} (hm : m ≠ 0) :
    m.sort (· ≤ ·) ≠ [] := by
  exact fun h => hm <| by simpa using congr_arg List.length h;

/-
All elements of sort inherit the property from the multiset.
-/
theorem sort_forall_notTmin {m : Multiset TropExpr}
    (hm : ∀ x ∈ m, notTmin x) : ∀ x ∈ m.sort (· ≤ ·), notTmin x := by
  exact fun x hx => hm x <| Multiset.mem_sort ( α := TropExpr ) ( · ≤ · ) |>.1 hx

theorem sort_forall_notAdd {m : Multiset TropExpr}
    (hm : ∀ x ∈ m, notAdd x) : ∀ x ∈ m.sort (· ≤ ·), notAdd x := by
  exact fun x hx => hm x <| Multiset.mem_sort ( α := TropExpr ) ( · ≤ · ) |>.1 hx

/-
Flattening normalize_ca (tmin a b) gives back the combined multiset.
-/
theorem flattenMin_normalize_ca_tmin (a b : TropExpr) :
    (↑(flattenMin (normalize_ca (.tmin a b))) : Multiset TropExpr) =
    ↑(flattenMin (normalize_ca a)) + ↑(flattenMin (normalize_ca b)) := by
  convert congr_arg _ ( flattenMin_rebuildMin _ _ ) using 1;
  · simp +zetaDelta at *;
    exact?;
  · simp +decide [ List.eq_nil_iff_forall_not_mem ];
    exact ⟨ Classical.choose ( List.length_pos_iff_exists_mem.mp ( flattenMin_length_pos ( normalize_ca b ) ) ), fun h => Classical.choose_spec ( List.length_pos_iff_exists_mem.mp ( flattenMin_length_pos ( normalize_ca b ) ) ) ⟩;
  · exact fun x hx => by simpa using sort_forall_notTmin ( fun y hy => by cases Multiset.mem_add.mp hy <;> [ exact flattenMin_notTmin _ _ ‹_› ; exact flattenMin_notTmin _ _ ‹_› ] ) x hx;

/-
Flattening normalize_ca (add a b) gives back the combined multiset.
-/
theorem flattenAdd_normalize_ca_add (a b : TropExpr) :
    (↑(flattenAdd (normalize_ca (.add a b))) : Multiset TropExpr) =
    ↑(flattenAdd (normalize_ca a)) + ↑(flattenAdd (normalize_ca b)) := by
  convert congr_arg _ ( flattenAdd_rebuildAdd _ _ ) using 1;
  · simp +zetaDelta at *;
    exact?;
  · convert sort_ne_nil _;
    simp +zetaDelta at *;
    exact fun h => absurd h ( flattenAdd_nonempty _ );
  · simp +zetaDelta at *;
    rintro x ( hx | hx ) <;> [ exact flattenAdd_notAdd _ _ hx; exact flattenAdd_notAdd _ _ hx ]

/-! ## Completeness -/

/-
**Completeness for AC**: AC-equivalent expressions have the same normal form.
-/
theorem normalize_ca_complete {e₁ e₂ : TropExpr}
    (h : ACEquiv e₁ e₂) : normalize_ca e₁ = normalize_ca e₂ := by
  induction' h with e₁ e₂ h ih;
  all_goals repeat' aesop;
  nontriviality;
  rename_i e₁ e₂;
  rename_i e₃;
  -- By definition of `normalize_ca`, we know that `normalize_ca (e₃.tmin e₁)` and `normalize_ca (e₁.tmin e₃)` are equal because `tmin` is commutative.
  have h_comm : Multiset.ofList (flattenMin (normalize_ca e₃)) + Multiset.ofList (flattenMin (normalize_ca e₁)) = Multiset.ofList (flattenMin (normalize_ca e₁)) + Multiset.ofList (flattenMin (normalize_ca e₃)) := by
    exact add_comm _ _;
  unfold normalize_ca;
  grind;
  · -- By definition of `normalize_ca`, we can expand both sides.
    have h_expand : ∀ e : TropExpr, normalize_ca e = match e with
      | .const r => .const r
      | .var n => .var n
      | .tmin a b =>
        let a' := normalize_ca a
        let b' := normalize_ca b
        let children := (↑(flattenMin a') + ↑(flattenMin b') : Multiset TropExpr)
        rebuildMin (children.sort (· ≤ ·))
      | .add a b =>
        let a' := normalize_ca a
        let b' := normalize_ca b
        let children := (↑(flattenAdd a') + ↑(flattenAdd b') : Multiset TropExpr)
        rebuildAdd (children.sort (· ≤ ·)) := by
          intro e;
          cases e <;> rfl;
    rw [ h_expand, h_expand ];
    simp +decide [ flattenMin_normalize_ca_tmin ];
  · unfold normalize_ca;
    grind +suggestions;
  · unfold normalize_ca;
    simp_all +decide [ flattenAdd_normalize_ca_add ];
  · unfold normalize_ca;
    aesop;
  · unfold normalize_ca; aesop;

/-! ## ACEquiv from normalization (for idempotence) -/

/-
Rebuilding a permuted list gives an ACEquiv result (for tmin).
-/
theorem rebuildMin_perm_ACEquiv {l₁ l₂ : List TropExpr}
    (hl : l₁ ≠ []) (hp : l₁.Perm l₂) :
    ACEquiv (rebuildMin l₁) (rebuildMin l₂) := by
  induction' hp with l₁ l₂ hp ih hl₂ ih;
  · contradiction;
  · rcases l₂ with ( _ | ⟨ x, _ | ⟨ y, l₂ ⟩ ⟩ ) <;> simp_all +decide [ ACEquiv.refl ];
    convert ACEquiv.cong_tmin ( ACEquiv.refl l₁ ) hl₂ using 1;
    cases hp <;> aesop;
  · rename_i k hk;
    by_cases h : hk = [] <;> simp_all +decide [ rebuildMin ];
    · exact ACEquiv.tmin_comm _ _;
    · have h_assoc : ACEquiv (k.tmin (ih.tmin (rebuildMin hk))) ((k.tmin ih).tmin (rebuildMin hk)) := by
        exact ACEquiv.tmin_assoc _ _ _ |> ACEquiv.symm;
      have h_comm : ACEquiv ((k.tmin ih).tmin (rebuildMin hk)) ((ih.tmin k).tmin (rebuildMin hk)) := by
        exact ACEquiv.cong_tmin ( ACEquiv.tmin_comm _ _ ) ( ACEquiv.refl _ );
      have h_assoc : ACEquiv ((ih.tmin k).tmin (rebuildMin hk)) (ih.tmin (k.tmin (rebuildMin hk))) := by
        apply ACEquiv.tmin_assoc;
      exact ACEquiv.trans ‹_› ( ACEquiv.trans ‹_› ‹_› );
  · rename_i h₁ h₂ h₃ h₄;
    exact ACEquiv.trans ( h₃ hl ) ( h₄ ( by aesop ) )

/-
Rebuilding a permuted list gives an ACEquiv result (for add).
-/
theorem rebuildAdd_perm_ACEquiv {l₁ l₂ : List TropExpr}
    (hl : l₁ ≠ []) (hp : l₁.Perm l₂) :
    ACEquiv (rebuildAdd l₁) (rebuildAdd l₂) := by
  induction' hp with l₁ l₂ hp ih₂ ih;
  · contradiction;
  · rcases l₂ with ( _ | ⟨ e₁, _ | ⟨ e₂, l₂ ⟩ ⟩ ) <;> rcases hp with ( _ | ⟨ f₁, _ | ⟨ f₂, hp ⟩ ⟩ ) <;> simp_all +decide [ACEquiv];
    · constructor;
    · exact ACEquiv.refl _;
    · exact ACEquiv.cong_add ( ACEquiv.refl _ ) ih;
  · unfold rebuildAdd;
    rename_i a b l;
    induction' l with c l ihizing a b;
    · exact ACEquiv.add_comm _ _;
    · unfold rebuildAdd at *;
      have h_assoc : ACEquiv (b.add (a.add (rebuildAdd (c :: l)))) ((b.add a).add (rebuildAdd (c :: l))) := by
        exact ACEquiv.add_assoc _ _ _ |> ACEquiv.symm;
      have h_assoc : ACEquiv ((b.add a).add (rebuildAdd (c :: l))) (a.add (b.add (rebuildAdd (c :: l)))) := by
        have h_assoc : ACEquiv ((b.add a).add (rebuildAdd (c :: l))) (a.add (b.add (rebuildAdd (c :: l)))) := by
          have h_assoc : ACEquiv ((b.add a).add (rebuildAdd (c :: l))) ((a.add b).add (rebuildAdd (c :: l))) := by
            apply ACEquiv.cong_add;
            · exact ACEquiv.add_comm _ _;
            · exact ACEquiv.refl _
          exact ACEquiv.trans h_assoc ( ACEquiv.add_assoc _ _ _ );
        exact h_assoc;
      exact ACEquiv.trans ‹_› ‹_›;
  · rename_i h₁ h₂ h₃ h₄;
    exact ACEquiv.trans ( h₃ hl ) ( h₄ ( by aesop ) )

/-
Flattening+rebuilding is ACEquiv to the original (for tmin).
-/
theorem rebuildMin_flattenMin_ACEquiv (e : TropExpr) :
    ACEquiv e (rebuildMin (flattenMin e)) := by
  -- By induction on the structure of `e`.
  induction' e with e ih;
  · exact ACEquiv.refl _;
  · exact ACEquiv.refl _;
  · rename_i a b ha hb;
    have h_assoc : ∀ (l₁ l₂ : List TropExpr), l₁ ≠ [] → l₂ ≠ [] → ACEquiv (TropExpr.tmin (rebuildMin l₁) (rebuildMin l₂)) (rebuildMin (l₁ ++ l₂)) := by
      intros l₁ l₂ hl₁ hl₂;
      induction' l₁ with x l₁ ih generalizing l₂ <;> simp_all +decide [ rebuildMin ];
      cases l₁ <;> simp_all +decide [ rebuildMin ];
      · constructor;
      · exact ACEquiv.trans ( ACEquiv.tmin_assoc _ _ _ ) ( ACEquiv.cong_tmin ( ACEquiv.refl _ ) ( ih _ hl₂ ) );
    convert ACEquiv.cong_tmin ha hb |> ACEquiv.trans <| h_assoc ( flattenMin a ) ( flattenMin b ) ( flattenMin_nonempty a ) ( flattenMin_nonempty b ) using 1;
  · exact?

/-
Flattening+rebuilding is ACEquiv to the original (for add).
-/
theorem rebuildAdd_flattenAdd_ACEquiv (e : TropExpr) :
    ACEquiv e (rebuildAdd (flattenAdd e)) := by
  have h_flatten_add_rules : ∀ (e : TropExpr), ACEquiv e (rebuildAdd (flattenAdd e)) := by
    intro e;
    induction' e using TropExpr.recOn with e ih;
    · exact ACEquiv.refl _;
    · exact ACEquiv.refl _;
    · exact?;
    · rename_i a b ha hb;
      -- By definition of `flattenAdd`, we have `flattenAdd (a.add b) = flattenAdd a ++ flattenAdd b`.
      have h_flatten_add : flattenAdd (a.add b) = flattenAdd a ++ flattenAdd b := by
        rfl;
      -- By definition of `rebuildAdd`, we have `rebuildAdd (flattenAdd a ++ flattenAdd b) = rebuildAdd (flattenAdd a) + rebuildAdd (flattenAdd b)`.
      have h_rebuild_add : ACEquiv (rebuildAdd (flattenAdd a ++ flattenAdd b)) (rebuildAdd (flattenAdd a) |>.add (rebuildAdd (flattenAdd b))) := by
        have h_rebuild_add : ∀ (l₁ l₂ : List TropExpr), l₁ ≠ [] → l₂ ≠ [] → ACEquiv (rebuildAdd (l₁ ++ l₂)) (rebuildAdd l₁ |>.add (rebuildAdd l₂)) := by
          intros l₁ l₂ hl₁ hl₂;
          induction' l₁ with l₁_head l₁_tail ih generalizing l₂ <;> simp_all +decide [ rebuildAdd ];
          rcases l₁_tail with ( _ | ⟨ l₁_tail_head, l₁_tail_tail ⟩ ) <;> simp_all +decide [ rebuildAdd ];
          · constructor;
          · have h_assoc : ∀ (a b c : TropExpr), ACEquiv (a.add (b.add c)) ((a.add b).add c) := by
              exact fun a b c => ACEquiv.symm ( ACEquiv.add_assoc a b c );
            have h_cong : ∀ (a b c d : TropExpr), ACEquiv a b → ACEquiv c d → ACEquiv (a.add c) (b.add d) := by
              exact fun a b c d hab hcd => ACEquiv.cong_add hab hcd;
            exact h_cong _ _ _ _ ( ACEquiv.refl _ ) ( ih _ hl₂ ) |> ACEquiv.trans <| h_assoc _ _ _;
        exact h_rebuild_add _ _ ( flattenAdd_nonempty _ ) ( flattenAdd_nonempty _ );
      rw [ h_flatten_add ];
      apply ACEquiv.trans;
      exact ACEquiv.cong_add ha hb;
      exact ACEquiv.symm h_rebuild_add;
  exact h_flatten_add_rules e

/-
**Normalization is ACEquiv to the original**: every expression is AC-equivalent
    to its normal form. This is the key lemma for idempotence.
-/
theorem normalize_ca_ACEquiv (e : TropExpr) : ACEquiv e (normalize_ca e) := by
  by_contra h;
  -- Apply the theorem that states any two AC-equivalent expressions are equal in their normalized forms.
  have h_eq : ∀ e : TropExpr, ACEquiv (normalize_ca e) e := by
    intro e
    apply ACEquiv.symm;
    induction' e using TropExpr.recOn with e ih;
    · exact ACEquiv.refl _;
    · exact ACEquiv.refl _;
    · rename_i a b ha hb
      have h_tmin : ACEquiv (.tmin a b) (.tmin (normalize_ca a) (normalize_ca b)) := by
        exact ACEquiv.cong_tmin ha hb
      have h_rebuild : ACEquiv (.tmin (normalize_ca a) (normalize_ca b)) (rebuildMin (flattenMin (normalize_ca (.tmin a b)))) := by
        have h_rebuild : ACEquiv (.tmin (normalize_ca a) (normalize_ca b)) (rebuildMin (flattenMin (normalize_ca a) ++ flattenMin (normalize_ca b))) := by
          convert rebuildMin_flattenMin_ACEquiv _ using 1;
        have h_sort : List.Perm (flattenMin (normalize_ca (.tmin a b))) (flattenMin (normalize_ca a) ++ flattenMin (normalize_ca b)) := by
          have h_sort : Multiset.ofList (flattenMin (normalize_ca (.tmin a b))) = Multiset.ofList (flattenMin (normalize_ca a) ++ flattenMin (normalize_ca b)) := by
            convert flattenMin_normalize_ca_tmin a b using 1;
          exact Multiset.coe_eq_coe.mp h_sort;
        have h_rebuild : ACEquiv (rebuildMin (flattenMin (normalize_ca a) ++ flattenMin (normalize_ca b))) (rebuildMin (flattenMin (normalize_ca (.tmin a b)))) := by
          apply rebuildMin_perm_ACEquiv;
          · exact List.ne_nil_of_mem ( List.mem_append_left _ ( Classical.choose_spec ( List.length_pos_iff_exists_mem.mp ( by linarith [ flattenMin_length_pos ( normalize_ca a ) ] ) ) ) );
          · exact h_sort.symm;
        exact ACEquiv.trans ‹_› ‹_›
      have h_final : ACEquiv (.tmin a b) (rebuildMin (flattenMin (normalize_ca (.tmin a b)))) := by
        exact ACEquiv.trans h_tmin h_rebuild
      exact h_final.trans (by
      convert ACEquiv.symm ( rebuildMin_flattenMin_ACEquiv ( normalize_ca ( a.tmin b ) ) ) using 1);
    · rename_i a b ha hb;
      -- By definition of `normalize_ca`, we know that `normalize_ca (a.add b)` is the rebuild of the sorted list of the flatten of `normalize_ca a` and `normalize_ca b`.
      have h_normalize_ca_add : normalize_ca (a.add b) = rebuildAdd ((↑(flattenAdd (normalize_ca a)) + ↑(flattenAdd (normalize_ca b)) : Multiset TropExpr).sort (· ≤ ·)) := by
        grind +locals;
      -- By definition of `flattenAdd`, we know that `flattenAdd (normalize_ca a)` and `flattenAdd (normalize_ca b)` are the lists of the flatten of `normalize_ca a` and `normalize_ca b`, respectively.
      have h_flattenAdd : ACEquiv (a.add b) (rebuildAdd (flattenAdd (normalize_ca a) ++ flattenAdd (normalize_ca b))) := by
        have h_flattenAdd : ACEquiv (a.add b) ((normalize_ca a).add (normalize_ca b)) := by
          exact ACEquiv.cong_add ha hb;
        have h_flattenAdd : ACEquiv ((normalize_ca a).add (normalize_ca b)) (rebuildAdd (flattenAdd (normalize_ca a) ++ flattenAdd (normalize_ca b))) := by
          have h_flattenAdd : ACEquiv ((normalize_ca a).add (normalize_ca b)) (rebuildAdd (flattenAdd ((normalize_ca a).add (normalize_ca b)))) := by
            grind +suggestions
          convert h_flattenAdd using 1;
        exact ACEquiv.trans ‹_› ‹_›;
      convert ACEquiv.trans h_flattenAdd _ using 1;
      convert rebuildAdd_perm_ACEquiv _ _ using 1;
      · exact List.ne_nil_of_mem ( List.mem_append_left _ ( List.head_mem ( flattenAdd_nonempty _ ) ) );
      · simp +decide;
        exact?;
  exact h ( ACEquiv.symm ( h_eq e ) )

/-
**Idempotence**: normalizing twice gives the same result as normalizing once.
    Follows from completeness + the fact that e is ACEquiv to normalize_ca e.
-/
theorem normalize_ca_idempotent (e : TropExpr) :
    normalize_ca (normalize_ca e) = normalize_ca e := by
  apply Eq.symm; exact (by
  apply normalize_ca_complete;
  -- Apply the theorem that states any expression is ACEquiv to its normalized form.
  apply normalize_ca_ACEquiv)

/-! ## Corollaries -/

/-- Normalized AC-equivalent expressions have equal evaluations. -/
theorem normalize_ca_iff_ACEquiv_eval {e₁ e₂ : TropExpr}
    (h : ACEquiv e₁ e₂) : ∀ σ, eval σ e₁ = eval σ e₂ :=
  fun σ => by rw [← eval_normalize_ca σ e₁, ← eval_normalize_ca σ e₂,
                   normalize_ca_complete h]

/-! ## Boundary: distributivity lies outside AC -/

/-- Tropical distributivity: the semantic identity outside the AC fragment. -/
theorem tropical_add_min_distrib (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith

end TropicalAC

end