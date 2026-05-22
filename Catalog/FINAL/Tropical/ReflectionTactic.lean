/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Reflection Tactic: A Certified Decision Procedure

This file builds a **reflection-based decision procedure** for the additive-commutative-
idempotent (ACI) fragment of tropical (min-plus) algebra.

## Main results

- `cnormalize_ca_sound`: normalization preserves evaluation semantics
- `cnormalize_ca_eq_implies_semantic_eq`: equal normal forms ⟹ semantic equality
- `prove_tropical_eq_by_norm`: decidable tactic kernel certificate
- Several nontrivial demonstration theorems proved purely through the reflection pipeline
-/

import Mathlib

/-! ## Computable Tropical Expression Type -/

/-- A fully computable tropical expression type. -/
inductive CTropExpr where
  | var  : ℕ → CTropExpr
  | tmin : CTropExpr → CTropExpr → CTropExpr
  | add  : CTropExpr → CTropExpr → CTropExpr
  deriving DecidableEq, Repr

namespace CTropExpr

/-! ## Computable Comparison -/

/-- Computable total order on `CTropExpr` for sorting. -/
def cmp : CTropExpr → CTropExpr → Ordering
  | .var n₁, .var n₂ => compare n₁ n₂
  | .var _, _ => .lt
  | .tmin _ _, .var _ => .gt
  | .tmin a₁ b₁, .tmin a₂ b₂ =>
    match cmp a₁ a₂ with | .eq => cmp b₁ b₂ | r => r
  | .tmin _ _, .add _ _ => .lt
  | .add _ _, .var _ => .gt
  | .add _ _, .tmin _ _ => .gt
  | .add a₁ b₁, .add a₂ b₂ =>
    match cmp a₁ a₂ with | .eq => cmp b₁ b₂ | r => r

/-- Boolean ≤ from comparison. -/
def ble (e₁ e₂ : CTropExpr) : Bool :=
  match cmp e₁ e₂ with | .gt => false | _ => true

/-! ## Flatten / Build / Dedup -/

def flattenMin : CTropExpr → List CTropExpr
  | .tmin a b => flattenMin a ++ flattenMin b
  | e => [e]

def flattenAdd : CTropExpr → List CTropExpr
  | .add a b => flattenAdd a ++ flattenAdd b
  | e => [e]

/-- Remove consecutive duplicates from a sorted list. -/
def dedup : List CTropExpr → List CTropExpr
  | [] => []
  | [x] => [x]
  | x :: y :: rest =>
    if x = y then dedup (y :: rest) else x :: dedup (y :: rest)

def buildMin : List CTropExpr → CTropExpr
  | [] => .var 0
  | [e] => e
  | e :: es => .tmin e (buildMin es)

def buildAdd : List CTropExpr → CTropExpr
  | [] => .var 0
  | [e] => e
  | e :: es => .add e (buildAdd es)

/-! ## Computable ACI Normalizer -/

/-- Computable ACI normalizer: ACI for `min`, AC for `+`. -/
def cnormalize_ca : CTropExpr → CTropExpr
  | .var n => .var n
  | .tmin a b =>
    let a' := cnormalize_ca a
    let b' := cnormalize_ca b
    buildMin (dedup ((flattenMin (.tmin a' b')).mergeSort ble))
  | .add a b =>
    let a' := cnormalize_ca a
    let b' := cnormalize_ca b
    buildAdd ((flattenAdd (.add a' b')).mergeSort ble)

/-! ## Semantic Evaluation -/

noncomputable def eval (σ : ℕ → ℝ) : CTropExpr → ℝ
  | .var n => σ n
  | .tmin a b => min (eval σ a) (eval σ b)
  | .add a b => eval σ a + eval σ b

noncomputable def evalMinList (σ : ℕ → ℝ) : List CTropExpr → ℝ
  | [] => 0
  | [e] => eval σ e
  | e :: es => min (eval σ e) (evalMinList σ es)

noncomputable def evalAddList (σ : ℕ → ℝ) : List CTropExpr → ℝ
  | [] => 0
  | [e] => eval σ e
  | e :: es => eval σ e + evalAddList σ es

/-! ## Helper Lemmas -/

theorem flattenMin_ne (e : CTropExpr) : flattenMin e ≠ [] := by
  cases e <;> simp [flattenMin, flattenMin_ne]

theorem flattenAdd_ne (e : CTropExpr) : flattenAdd e ≠ [] := by
  cases e <;> simp [flattenAdd, flattenAdd_ne]

theorem dedup_ne (l : List CTropExpr) (h : l ≠ []) : dedup l ≠ [] := by
  induction l with
  | nil => contradiction
  | cons x t ih =>
    cases t with
    | nil => simp [dedup]
    | cons y rest =>
      simp only [dedup]; split
      · exact ih (by simp)
      · simp

theorem evalMinList_cons_cons (σ : ℕ → ℝ) (e f : CTropExpr) (es : List CTropExpr) :
    evalMinList σ (e :: f :: es) = min (eval σ e) (evalMinList σ (f :: es)) := by
  simp [evalMinList]

theorem evalAddList_cons_cons (σ : ℕ → ℝ) (e f : CTropExpr) (es : List CTropExpr) :
    evalAddList σ (e :: f :: es) = eval σ e + evalAddList σ (f :: es) := by
  simp [evalAddList]

theorem evalMinList_append (σ : ℕ → ℝ) (l₁ l₂ : List CTropExpr)
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    evalMinList σ (l₁ ++ l₂) = min (evalMinList σ l₁) (evalMinList σ l₂) := by
  induction' l₁ with a t₁ ih generalizing l₂ <;> cases l₂ <;> simp_all +decide [ evalMinList_cons_cons ];
  cases t₁ <;> simp_all +decide [ evalMinList_cons_cons ];
  · exact Real.ext_cauchy rfl;
  · rw [ min_assoc ]

theorem evalAddList_append (σ : ℕ → ℝ) (l₁ l₂ : List CTropExpr)
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    evalAddList σ (l₁ ++ l₂) = evalAddList σ l₁ + evalAddList σ l₂ := by
  induction' l₁ with a l₁ ih generalizing l₂ <;> simp_all +decide;
  cases l₁ <;> cases l₂ <;> simp_all +decide [ evalAddList_cons_cons ];
  · rfl;
  · ring

theorem eval_flattenMin (σ : ℕ → ℝ) (e : CTropExpr) :
    evalMinList σ (flattenMin e) = eval σ e := by
  induction' e using CTropExpr.recOn with e ih;
  · rfl;
  · -- By definition of `evalMinList`, we can split the list into the two parts and apply the induction hypothesis.
    have h_split : evalMinList σ (flattenMin ih ++ flattenMin ‹_›) = min (evalMinList σ (flattenMin ih)) (evalMinList σ (flattenMin ‹_›)) := by
      grind +suggestions;
    aesop;
  · unfold CTropExpr.flattenMin; aesop;

theorem eval_flattenAdd (σ : ℕ → ℝ) (e : CTropExpr) :
    evalAddList σ (flattenAdd e) = eval σ e := by
  induction e <;> simp_all +decide [ CTropExpr.flattenAdd ];
  · rfl;
  · unfold evalAddList; aesop;
  · rename_i a b ha hb;
    by_cases ha' : a.flattenAdd = [] <;> by_cases hb' : b.flattenAdd = [] <;> simp_all +decide [ evalAddList_append ];
    · exact absurd ha' ( flattenAdd_ne a );
    · exact absurd ha' ( flattenAdd_ne a );
    · exact absurd hb' ( flattenAdd_ne _ );
    · grind +locals

theorem evalMinList_dedup (σ : ℕ → ℝ) (l : List CTropExpr) (h : l ≠ []) :
    evalMinList σ (dedup l) = evalMinList σ l := by
  induction' l with x l ih;
  · grind;
  · rcases l with ( _ | ⟨ y, l ⟩ ) <;> simp_all +decide;
    · rfl;
    · by_cases h : x = y <;> simp_all +decide [ dedup ];
      · cases l <;> simp_all +decide [ evalMinList_cons_cons ];
        rfl;
      · cases h' : dedup ( y :: l ) <;> cases h'' : y :: l <;> simp_all +decide [ evalMinList_cons_cons ];
        have h_nonempty : dedup (‹CTropExpr› :: ‹List CTropExpr›) ≠ [] := by
          apply dedup_ne;
          aesop;
        contradiction

theorem evalMinList_perm (σ : ℕ → ℝ) {l₁ l₂ : List CTropExpr}
    (hp : l₁.Perm l₂) (h₁ : l₁ ≠ []) :
    evalMinList σ l₁ = evalMinList σ l₂ := by
  -- We can prove this by induction on the length of the list.
  induction' hp with a l₁ l₂ hp ih;
  · rfl;
  · cases l₁ <;> cases l₂ <;> simp_all +decide [ evalMinList_cons_cons ];
  · -- By definition of evalMinList, we can split the list into the first element and the rest.
    simp [evalMinList_cons_cons];
    induction' ‹List CTropExpr› with z l ih generalizing σ <;> simp_all +decide [ evalMinList_cons_cons ];
    · exact min_comm _ _;
    · grind;
  · rename_i l₁ l₂ l₃ h₁ h₂ h₃ h₄;
    by_cases h₂ : l₂ = [] <;> aesop

theorem evalAddList_perm (σ : ℕ → ℝ) {l₁ l₂ : List CTropExpr}
    (hp : l₁.Perm l₂) (h₁ : l₁ ≠ []) :
    evalAddList σ l₁ = evalAddList σ l₂ := by
  induction' hp with l₁ l₂ hp ih;
  · lia;
  · cases l₂ <;> cases hp <;> simp_all +decide [ evalAddList_cons_cons ];
  · induction' ‹List CTropExpr› using List.reverseRecOn with l ih <;> simp_all +decide [ evalAddList_cons_cons ];
    · exact add_comm _ _;
    · grind +suggestions;
  · by_cases h₂ : ‹List CTropExpr› = [] <;> aesop

theorem eval_buildMin_eq (σ : ℕ → ℝ) (l : List CTropExpr) (hne : l ≠ []) :
    eval σ (buildMin l) = evalMinList σ l := by
  induction' l with e l ih;
  · contradiction;
  · rcases l with ( _ | ⟨ f, l ⟩ ) <;> simp_all +decide;
    · rfl;
    · convert congr_arg₂ ( fun x y => min ( eval σ e ) y ) rfl ih using 1;
      exact True;
      trivial

theorem eval_buildAdd_eq (σ : ℕ → ℝ) (l : List CTropExpr) (hne : l ≠ []) :
    eval σ (buildAdd l) = evalAddList σ l := by
  induction' l with e l ih;
  · contradiction;
  · rcases l with ( _ | ⟨ f, l ⟩ ) <;> simp_all +decide [ buildAdd, evalAddList ];
    exact ih ▸ rfl

theorem mergeSort_ne_of_ne (l : List CTropExpr) (h : l ≠ []) :
    l.mergeSort ble ≠ [] := by
  intro hs
  apply h
  have hlen := (List.mergeSort_perm l ble).length_eq
  rw [hs] at hlen
  simp at hlen
  exact List.eq_nil_of_length_eq_zero hlen.symm

/-! ## Main Soundness Theorem -/

/-
**Soundness**: the computable ACI normalizer preserves evaluation semantics.
-/
theorem cnormalize_ca_sound (σ : ℕ → ℝ) (e : CTropExpr) :
    eval σ (cnormalize_ca e) = eval σ e := by
  induction' e using CTropExpr.recOn with e ih ih_a ih_b;
  · rfl;
  · -- By definition of `cnormalize_ca`, we have `cnormalize_ca (tmin a b) = buildMin (dedup (mergeSort (flattenMin (tmin a b)) ble))`.
    have h_cnormalize_ca_tmin : eval σ (CTropExpr.cnormalize_ca (CTropExpr.tmin ih ih_a)) = eval σ (CTropExpr.buildMin (CTropExpr.dedup (List.mergeSort (CTropExpr.flattenMin (CTropExpr.tmin (CTropExpr.cnormalize_ca ih) (CTropExpr.cnormalize_ca ih_a))) CTropExpr.ble))) := by
      rfl;
    -- By definition of `buildMin`, we have `eval σ (buildMin (dedup (mergeSort (flattenMin (tmin a b)) ble))) = evalMinList σ (dedup (mergeSort (flattenMin (tmin a b)) ble))`.
    have h_buildMin : eval σ (CTropExpr.buildMin (CTropExpr.dedup (List.mergeSort (CTropExpr.flattenMin (CTropExpr.tmin (CTropExpr.cnormalize_ca ih) (CTropExpr.cnormalize_ca ih_a))) CTropExpr.ble))) = evalMinList σ (CTropExpr.dedup (List.mergeSort (CTropExpr.flattenMin (CTropExpr.tmin (CTropExpr.cnormalize_ca ih) (CTropExpr.cnormalize_ca ih_a))) CTropExpr.ble)) := by
      apply eval_buildMin_eq;
      apply dedup_ne;
      exact ne_of_apply_ne List.length ( by simp +decide [ flattenMin_ne ] );
    -- By definition of `evalMinList`, we have `evalMinList σ (dedup (mergeSort (flattenMin (tmin a b)) ble)) = evalMinList σ (flattenMin (tmin a b))`.
    have h_evalMinList : evalMinList σ (CTropExpr.dedup (List.mergeSort (CTropExpr.flattenMin (CTropExpr.tmin (CTropExpr.cnormalize_ca ih) (CTropExpr.cnormalize_ca ih_a))) CTropExpr.ble)) = evalMinList σ (CTropExpr.flattenMin (CTropExpr.tmin (CTropExpr.cnormalize_ca ih) (CTropExpr.cnormalize_ca ih_a))) := by
      have hsne : (flattenMin (.tmin (cnormalize_ca ih) (cnormalize_ca ih_a))).mergeSort ble ≠ [] :=
        mergeSort_ne_of_ne _ (flattenMin_ne _)
      rw [evalMinList_dedup _ _ hsne]
      exact evalMinList_perm σ (List.mergeSort_perm _ _) hsne
    have h_evalMinList_tmin : evalMinList σ (CTropExpr.flattenMin (CTropExpr.tmin (CTropExpr.cnormalize_ca ih) (CTropExpr.cnormalize_ca ih_a))) = min (eval σ (CTropExpr.cnormalize_ca ih)) (eval σ (CTropExpr.cnormalize_ca ih_a)) := by
      convert eval_flattenMin σ ( CTropExpr.tmin ( CTropExpr.cnormalize_ca ih ) ( CTropExpr.cnormalize_ca ih_a ) ) using 1;
    aesop;
  · rename_i a b ha hb;
    -- By definition of `buildAdd`, we can rewrite the left-hand side of the equation.
    have h_buildAdd : eval σ (buildAdd ((flattenAdd (a.cnormalize_ca.add b.cnormalize_ca)).mergeSort ble)) = evalAddList σ ((flattenAdd (a.cnormalize_ca.add b.cnormalize_ca)).mergeSort ble) := by
      apply eval_buildAdd_eq;
      exact ne_of_apply_ne List.length ( by simp +decide [ flattenAdd_ne ] );
    -- By definition of `flattenAdd`, we can rewrite the left-hand side of the equation.
    have h_flattenAdd : evalAddList σ ((flattenAdd (a.cnormalize_ca.add b.cnormalize_ca)).mergeSort ble) = eval σ (a.cnormalize_ca.add b.cnormalize_ca) := by
      have hsne : (flattenAdd (a.cnormalize_ca.add b.cnormalize_ca)).mergeSort ble ≠ [] :=
        mergeSort_ne_of_ne _ (flattenAdd_ne _)
      rw [← eval_flattenAdd]
      exact evalAddList_perm σ (List.mergeSort_perm _ _) hsne
    convert h_buildAdd.trans h_flattenAdd using 1;
    exact show eval σ a + eval σ b = eval σ a.cnormalize_ca + eval σ b.cnormalize_ca from by rw [ ha, hb ] ;

/-! ## Core Reflection Theorems -/

/-- **Reflection theorem: equal normal forms imply semantic equality.** -/
theorem cnormalize_ca_eq_implies_semantic_eq
    (e₁ e₂ : CTropExpr) (h : cnormalize_ca e₁ = cnormalize_ca e₂) :
    ∀ σ : ℕ → ℝ, eval σ e₁ = eval σ e₂ := by
  intro σ
  calc eval σ e₁ = eval σ (cnormalize_ca e₁) := (cnormalize_ca_sound σ e₁).symm
    _ = eval σ (cnormalize_ca e₂) := by rw [h]
    _ = eval σ e₂ := cnormalize_ca_sound σ e₂

/-- **Decidable reflection theorem.** -/
theorem cnormalize_ca_decide_sound
    (e₁ e₂ : CTropExpr) (h : decide (cnormalize_ca e₁ = cnormalize_ca e₂) = true) :
    ∀ σ : ℕ → ℝ, eval σ e₁ = eval σ e₂ :=
  cnormalize_ca_eq_implies_semantic_eq e₁ e₂ (of_decide_eq_true h)

/-- **Tactic kernel certificate.** -/
theorem prove_tropical_eq_by_norm
    (e₁ e₂ : CTropExpr)
    (h : decide (cnormalize_ca e₁ = cnormalize_ca e₂) = true) :
    ∀ σ : ℕ → ℝ, eval σ e₁ = eval σ e₂ :=
  cnormalize_ca_decide_sound e₁ e₂ h

/-! ## Demonstration Theorems -/

theorem tropical_assoc_comm_example (a b c d : ℝ) :
    min (a + b) (min (c + d) (a + b)) = min (min (d + c) (b + a)) (a + b) := by
  exact cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.add (.var 0) (.var 1)) (.tmin (.add (.var 2) (.var 3)) (.add (.var 0) (.var 1))))
    (.tmin (.tmin (.add (.var 3) (.var 2)) (.add (.var 1) (.var 0))) (.add (.var 0) (.var 1)))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | 2 => c | _ => d)

theorem tropical_flatten_example (a b c d : ℝ) :
    min (min a b) (min c d) = min a (min b (min c d)) := by
  exact cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.tmin (.var 0) (.var 1)) (.tmin (.var 2) (.var 3)))
    (.tmin (.var 0) (.tmin (.var 1) (.tmin (.var 2) (.var 3))))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | 2 => c | _ => d)

theorem tropical_duplicate_elim_example (a b c : ℝ) :
    min (a + b) (min (a + b) c) = min c (b + a) := by
  exact cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.add (.var 0) (.var 1)) (.tmin (.add (.var 0) (.var 1)) (.var 2)))
    (.tmin (.var 2) (.add (.var 1) (.var 0)))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | _ => c)

theorem tropical_semiring_AC_normal_form (a b c : ℝ) :
    min (a + (b + c)) ((c + b) + a) = a + (b + c) := by
  exact cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.add (.var 0) (.add (.var 1) (.var 2)))
           (.add (.add (.var 2) (.var 1)) (.var 0)))
    (.add (.var 0) (.add (.var 1) (.var 2)))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | _ => c)

theorem tropical_five_var (a b c d e : ℝ) :
    min (min (a + b) (c + d)) (min (d + c) (min (b + a) e))
    = min (min (a + b) e) (c + d) := by
  exact cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.tmin (.add (.var 0) (.var 1)) (.add (.var 2) (.var 3)))
           (.tmin (.add (.var 3) (.var 2)) (.tmin (.add (.var 1) (.var 0)) (.var 4))))
    (.tmin (.tmin (.add (.var 0) (.var 1)) (.var 4)) (.add (.var 2) (.var 3)))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | 2 => c | 3 => d | _ => e)

theorem tropical_deep_nesting (a b c : ℝ) :
    min (min (a + b + c) (b + a + c)) (c + (b + a))
    = min (a + b + c) (c + (a + b)) := by
  exact cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.tmin (.add (.add (.var 0) (.var 1)) (.var 2))
                  (.add (.add (.var 1) (.var 0)) (.var 2)))
           (.add (.var 2) (.add (.var 1) (.var 0))))
    (.tmin (.add (.add (.var 0) (.var 1)) (.var 2))
           (.add (.var 2) (.add (.var 0) (.var 1))))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | _ => c)

theorem tropical_triple_redundancy (a b : ℝ) :
    min (a + b) (min (b + a) (a + b)) = a + b := by
  exact cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.add (.var 0) (.var 1))
           (.tmin (.add (.var 1) (.var 0)) (.add (.var 0) (.var 1))))
    (.add (.var 0) (.var 1))
    (by native_decide)
    (fun n => match n with | 0 => a | _ => b)

theorem tropical_six_subexpr (a b c d : ℝ) :
    min (min (a + b) (c + d)) (min (b + a) (d + c))
    = min (a + b) (c + d) := by
  exact cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.tmin (.add (.var 0) (.var 1)) (.add (.var 2) (.var 3)))
           (.tmin (.add (.var 1) (.var 0)) (.add (.var 3) (.var 2))))
    (.tmin (.add (.var 0) (.var 1)) (.add (.var 2) (.var 3)))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | 2 => c | _ => d)

end CTropExpr