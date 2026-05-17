/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Soundness of the Tropical ACI Normalizer

This file proves that the computable normalizer `cnormalize_ca` preserves
evaluation semantics: for every expression `e` and environment `σ`,

  `eval σ (cnormalize_ca e) = eval σ e`

This is the foundational theorem enabling proof by reflection.
-/

import Tropical.Defs

open CTropExpr

/-! ## List-evaluation helper lemmas -/

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
  rfl

theorem evalAddList_cons_cons (σ : ℕ → ℝ) (e f : CTropExpr) (es : List CTropExpr) :
    evalAddList σ (e :: f :: es) = eval σ e + evalAddList σ (f :: es) := by
  rfl

theorem evalMinList_append (σ : ℕ → ℝ) (l₁ l₂ : List CTropExpr)
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    evalMinList σ (l₁ ++ l₂) = min (evalMinList σ l₁) (evalMinList σ l₂) := by
  induction' l₁ with x l₁ ih generalizing l₂ <;> cases l₂ <;> simp_all +decide [ List.append ];
  cases l₁ <;> simp_all +decide [ evalMinList_cons_cons ];
  · rfl;
  · rw [ min_assoc ]

theorem evalAddList_append (σ : ℕ → ℝ) (l₁ l₂ : List CTropExpr)
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    evalAddList σ (l₁ ++ l₂) = evalAddList σ l₁ + evalAddList σ l₂ := by
  induction' l₂ with x l₂ ih generalizing l₁ <;> induction' l₁ with x' l₁ ih' <;> norm_num at *;
  rcases l₁ with ( _ | ⟨ y, l₁ ⟩ ) <;> simp_all +decide [ evalAddList_cons_cons ];
  · rfl;
  · ring

theorem eval_flattenMin (σ : ℕ → ℝ) (e : CTropExpr) :
    evalMinList σ (flattenMin e) = eval σ e := by
  -- By definition of `flattenMin`, we know that `flattenMin e` is a list of `e` if `e` is a variable.
  induction' e with e ih;
  · rfl;
  · rw [ show ( ih.tmin _ ).flattenMin = ih.flattenMin ++ _ from rfl, evalMinList_append ] <;> simp_all +decide [ flattenMin_ne ];
    rfl;
  · exact?

theorem eval_flattenAdd (σ : ℕ → ℝ) (e : CTropExpr) :
    evalAddList σ (flattenAdd e) = eval σ e := by
  -- We proceed by induction on the structure of the expression `e`.
  induction' e with e ih_e;
  · rfl;
  · exact?;
  · rename_i a b ha hb;
    convert evalAddList_append σ ( CTropExpr.flattenAdd a ) ( CTropExpr.flattenAdd b ) ( by exact? ) ( by exact? ) using 1;
    exact ha.symm ▸ hb.symm ▸ rfl

theorem evalMinList_dedup (σ : ℕ → ℝ) (l : List CTropExpr) (h : l ≠ []) :
    evalMinList σ (dedup l) = evalMinList σ l := by
  induction' l with x l ih;
  · contradiction;
  · rcases l with ( _ | ⟨ y, l ⟩ ) <;> simp_all +decide;
    · rfl;
    · by_cases h : x = y <;> simp_all +decide [ dedup ];
      · cases l <;> simp +decide [ evalMinList ];
      · cases h' : dedup ( y :: l ) <;> cases h'' : y :: l <;> simp_all +decide [ evalMinList_cons_cons ];
        exact absurd h' ( dedup_ne _ ( by aesop ) )

theorem evalMinList_perm (σ : ℕ → ℝ) {l₁ l₂ : List CTropExpr}
    (hp : l₁.Perm l₂) (h₁ : l₁ ≠ []) :
    evalMinList σ l₁ = evalMinList σ l₂ := by
  induction' hp with l₁ l₂ hp ih;
  · rfl;
  · rcases l₂ with ( _ | ⟨ a, _ | ⟨ b, l₂ ⟩ ⟩ ) <;> simp_all +decide [ evalMinList_cons_cons ];
    cases hp <;> simp_all +decide [ evalMinList_cons_cons ];
  · induction' ‹List CTropExpr› with z l ih <;> simp_all +decide [ evalMinList_cons_cons, min_assoc, min_comm, min_left_comm ];
    exact min_comm _ _;
  · aesop

theorem evalAddList_perm (σ : ℕ → ℝ) {l₁ l₂ : List CTropExpr}
    (hp : l₁.Perm l₂) (h₁ : l₁ ≠ []) :
    evalAddList σ l₁ = evalAddList σ l₂ := by
  -- By the properties of add and the permutation, we can show that the evaluations are equal.
  have h_eval_add_perm : ∀ (l₁ l₂ : List CTropExpr), l₁.Perm l₂ → l₁ ≠ [] → evalAddList σ l₁ = evalAddList σ l₂ := by
    intros l₁ l₂ hp h₁;
    induction' hp with l₁ l₂ hp ih;
    · contradiction;
    · cases l₂ <;> cases hp <;> simp_all +decide [ evalAddList_cons_cons ];
    · unfold evalAddList; ring;
      induction' ‹List CTropExpr› with z l ih <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ];
      · unfold evalAddList; ring;
      · unfold evalAddList; ring;
    · aesop;
  exact h_eval_add_perm l₁ l₂ hp h₁

theorem eval_buildMin_eq (σ : ℕ → ℝ) (l : List CTropExpr) (hne : l ≠ []) :
    eval σ (buildMin l) = evalMinList σ l := by
  induction' l with a l ih;
  · grobner;
  · induction' l with b l ih generalizing a;
    · rfl;
    · simp_all +decide [ buildMin, evalMinList_cons_cons ];
      exact ih.symm ▸ rfl

theorem eval_buildAdd_eq (σ : ℕ → ℝ) (l : List CTropExpr) (hne : l ≠ []) :
    eval σ (buildAdd l) = evalAddList σ l := by
  rcases l with ( _ | ⟨ e, _ | ⟨ f, l ⟩ ⟩ ) <;> simp_all +decide;
  · rfl;
  · induction' l with l ih generalizing e f;
    · rfl;
    · convert congr_arg₂ ( · + · ) rfl ( ‹∀ ( e f : CTropExpr ), eval σ ( buildAdd ( e :: f :: ih ) ) = evalAddList σ ( e :: f :: ih ) › f l ) using 1

theorem mergeSort_ne_of_ne (l : List CTropExpr) (h : l ≠ []) :
    l.mergeSort ble ≠ [] := by
  exact List.ne_nil_of_length_pos ( by rw [ List.length_mergeSort ] ; exact List.length_pos_iff.mpr h )

/-! ## Main Soundness Theorem -/

/-
**Soundness**: the computable ACI normalizer preserves evaluation semantics.
-/
theorem cnormalize_ca_sound (σ : ℕ → ℝ) (e : CTropExpr) :
    eval σ (cnormalize_ca e) = eval σ e := by
  induction' e using CTropExpr.recOn with e₁ e₂ ih₁ ih₂;
  · rfl;
  · convert eval_buildMin_eq σ _ _ using 1;
    · have h_perm : List.Perm (List.mergeSort (flattenMin (CTropExpr.tmin (cnormalize_ca e₂) (cnormalize_ca ih₁))) ble) (flattenMin (CTropExpr.tmin (cnormalize_ca e₂) (cnormalize_ca ih₁))) := by
        grind +suggestions;
      convert evalMinList_perm σ h_perm _ using 1;
      · convert evalMinList_perm σ h_perm _ |> Eq.symm using 1;
        · rw [ eval_flattenMin ];
          rw [ show eval σ ( e₂.tmin ih₁ ) = min ( eval σ e₂ ) ( eval σ ih₁ ) by rfl, show eval σ ( e₂.cnormalize_ca.tmin ih₁.cnormalize_ca ) = min ( eval σ e₂.cnormalize_ca ) ( eval σ ih₁.cnormalize_ca ) by rfl, ih₂, ‹eval σ ih₁.cnormalize_ca = eval σ ih₁› ];
        · exact mergeSort_ne_of_ne _ ( flattenMin_ne _ );
      · grind +suggestions;
      · exact mergeSort_ne_of_ne _ ( flattenMin_ne _ );
    · apply dedup_ne;
      exact mergeSort_ne_of_ne _ ( flattenMin_ne _ );
  · -- Unfold cnormalize_ca for add: it builds buildAdd (mergeSort (flattenAdd (add a' b')) ble) where a' = cnormalize_ca a, b' = cnormalize_ca b.
    have h_add : ∀ a b : CTropExpr, eval σ (buildAdd ((flattenAdd (a.add b)).mergeSort ble)) = eval σ (a.add b) := by
      intros a b
      have h_add : eval σ (buildAdd ((flattenAdd (a.add b)).mergeSort ble)) = evalAddList σ ((flattenAdd (a.add b)).mergeSort ble) := by
        apply eval_buildAdd_eq;
        exact mergeSort_ne_of_ne _ ( flattenAdd_ne _ );
      rw [ h_add, ← eval_flattenAdd ];
      grind +suggestions;
    convert h_add _ _ using 1;
    unfold eval; aesop;