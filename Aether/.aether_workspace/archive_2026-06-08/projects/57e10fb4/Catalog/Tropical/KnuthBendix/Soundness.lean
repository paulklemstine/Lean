/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Normal Form Soundness

We prove that the normalization procedure for tropical expressions
is semantically sound: evaluating a normalized expression yields
the same function as the original expression. This is the tropical
analogue of the soundness of polynomial normal forms in commutative
algebra, or DNF conversion in Boolean logic.

## Main Results

* `AffineForm.eval_add` — adding affine forms corresponds to adding their evaluations
* `AffineForm.eval_ofConst` — constant affine form evaluates to the constant
* `AffineForm.eval_ofVar` — variable affine form evaluates to the variable
* `TropNF.eval_mergeMin` — merging normal forms corresponds to taking the minimum
* `TropNF.eval_addNF` — adding normal forms corresponds to adding and distributing
* `normalize_sound` — the main soundness theorem
* `exists_tropical_nf` — every tropical expression has an equivalent normal form

## Key Technique

The core distributivity identity used is:
  `a + min(b, c) = min(a + b, a + c)`
which is the tropical analogue of ring distributivity. This identity is iterated
to push `+` below `min`, yielding the "minimum of affine forms" normal form.
-/

import Tropical.KnuthBendix.Defs

noncomputable section

open Finset BigOperators

/-! ## Affine Form Evaluation Lemmas -/

namespace AffineForm

@[simp]
theorem eval_ofConst {n : ℕ} (c : ℝ) (x : Fin n → ℝ) :
    (AffineForm.ofConst c).eval x = c := by
  simp [eval, ofConst]

@[simp]
theorem eval_ofVar {n : ℕ} (i : Fin n) (x : Fin n → ℝ) :
    (AffineForm.ofVar i).eval x = x i := by
  unfold AffineForm.eval ofVar;
  aesop

/-
Adding two affine forms adds their evaluations.
-/
theorem eval_add {n : ℕ} (a b : AffineForm n) (x : Fin n → ℝ) :
    (AffineForm.add a b).eval x = a.eval x + b.eval x := by
  unfold AffineForm.eval;
  simp +decide [AffineForm.add, add_mul, Finset.sum_add_distrib, add_assoc, add_left_comm]

end AffineForm

/-! ## TropNF Evaluation Lemmas -/

namespace TropNF

/-- Evaluation of a cons list. -/
theorem eval_cons {n : ℕ} (a : AffineForm n) (as : TropNF n) (x : Fin n → ℝ)
    (has : as ≠ []) :
    TropNF.eval (a :: as) x = min (a.eval x) (TropNF.eval as x) := by
  cases as with
  | nil => exact absurd rfl has
  | cons b bs => simp [eval]

/-- Evaluation of a singleton list. -/
@[simp]
theorem eval_singleton {n : ℕ} (a : AffineForm n) (x : Fin n → ℝ) :
    TropNF.eval [a] x = a.eval x := by
  simp [eval]

/-
Merging two normal forms computes the minimum of their evaluations,
    provided both lists are nonempty.
-/
theorem eval_mergeMin {n : ℕ} (N₁ N₂ : TropNF n) (x : Fin n → ℝ)
    (h1 : N₁ ≠ []) (h2 : N₂ ≠ []) :
    TropNF.eval (mergeMin N₁ N₂) x = min (TropNF.eval N₁ x) (TropNF.eval N₂ x) := by
  induction' N₁ with a as ih generalizing N₂ <;> simp +decide [ *, TropNF.mergeMin ];
  · contradiction;
  · rcases as with ⟨ ⟨ ⟩ ⟩ <;> simp_all +decide [ TropNF.mergeMin ];
    · cases N₂ <;> tauto;
    · grind +suggestions

/-
Adding a single affine form to each element of a normal form,
    then evaluating, gives the affine form's value plus the normal form's value.
-/
theorem eval_map_add_single {n : ℕ} (a : AffineForm n) (N : TropNF n) (x : Fin n → ℝ)
    (hN : N ≠ []) :
    TropNF.eval (N.map (fun b => AffineForm.add a b)) x =
    a.eval x + TropNF.eval N x := by
  induction' N with d N ih generalizing x;
  · contradiction;
  · by_cases hN' : N = [] <;> simp_all +decide;
    · exact AffineForm.eval_add a d x
    · rw [ TropNF.eval_cons, TropNF.eval_cons ];
      · rw [ ih, AffineForm.eval_add ];
        grind;
      · assumption;
      · aesop

/-
The core soundness lemma for `addNF`: distributing addition over normal forms.
-/
theorem eval_addNF {n : ℕ} (N₁ N₂ : TropNF n) (x : Fin n → ℝ)
    (h1 : N₁ ≠ []) (h2 : N₂ ≠ []) :
    TropNF.eval (addNF N₁ N₂) x = TropNF.eval N₁ x + TropNF.eval N₂ x := by
  induction' N₁ with a as ih generalizing x;
  · contradiction;
  · by_cases has : as = [] <;> simp_all +decide [ TropNF.addNF ];
    · exact eval_map_add_single a N₂ x h2
    · convert TropNF.eval_mergeMin ( List.map ( fun b => a.add b ) N₂ ) ( List.flatMap ( fun a => List.map ( fun b => a.add b ) N₂ ) as ) x _ _ using 1;
      · rw [ eval_cons _ _ _ has, ih ];
        rw [ TropNF.eval_map_add_single ];
        · rw [ min_add_add_right ];
        · assumption;
      · aesop;
      · cases as <;> aesop

end TropNF

/-! ## Normalization Nonemptiness -/

/-
The normalization of any expression produces a nonempty list.
-/
theorem TropExpr.normalize_ne_nil {n : ℕ} (e : TropExpr n) :
    TropExpr.normalize e ≠ [] := by
  induction' e using TropExpr.recOn with e ih₂ e₁ e₂ ih₁ ih₂;
  · exact List.cons_ne_nil _ _;
  · exact List.getLast?_isSome.mp rfl
  · exact List.ne_nil_of_mem ( List.mem_append_left _ ( List.head_mem ih₁ ) );
  · simp_all +decide [ TropExpr.normalize ];
    simp_all +decide [ TropNF.addNF ];
    exact List.length_pos_iff_exists_mem.mp ( List.length_pos_iff.mpr ‹_› )

/-! ## Main Soundness Theorem -/

/-
**Tropical normalization soundness**: evaluating a tropical expression
    and evaluating its normal form yield the same function.

    This is the core theorem of the tropical Knuth–Bendix normalization pipeline.
    It says that every tropical expression built from constants, variables, `min`,
    and `+` can be faithfully compiled into a "minimum of affine forms"
    representation, where the compilation preserves semantics exactly.

    The proof proceeds by structural induction on the expression:
    - Constants and variables are trivially their own normal forms.
    - `min` corresponds to list concatenation (`mergeMin`), which preserves
      the minimum semantics.
    - `+` corresponds to the pairwise Minkowski sum of affine forms (`addNF`),
      which distributes `+` over `min` using the tropical distributivity identity
      `a + min(b, c) = min(a + b, a + c)`.
-/
theorem normalize_sound {n : ℕ} (e : TropExpr n) :
    TropExpr.eval e = TropNF.eval (TropExpr.normalize e) := by
  funext x;
  induction' e with e₁ e₂ ih₁ ih₂;
  · -- The evaluation of a constant expression is just the constant itself.
    simp [TropExpr.eval, TropExpr.normalize];
  · -- By definition of `TropExpr.var`, we have `TropExpr.var e₂ = AffineForm.ofVar e₂`.
    simp [TropExpr.normalize];
    rfl;
  · convert congr_arg₂ ( · ⊓ · ) ‹ih₁.eval x = ih₁.normalize.eval x› ‹ih₂.eval x = ih₂.normalize.eval x› using 1;
    exact TropNF.eval_mergeMin _ _ _ ( TropExpr.normalize_ne_nil _ ) ( TropExpr.normalize_ne_nil _ );
  · rename_i e₁ e₂ ih₁ ih₂;
    convert congr_arg₂ ( · + · ) ih₁ ih₂ using 1;
    convert TropNF.eval_addNF ( TropExpr.normalize e₁ ) ( TropExpr.normalize e₂ ) x ( TropExpr.normalize_ne_nil e₁ ) ( TropExpr.normalize_ne_nil e₂ ) using 1

/-- **Existence of tropical normal forms**: every tropical expression
    is semantically equivalent to some tropical normal form (a finite
    minimum of affine forms with natural-number multiplicities).

    This is the tropical analogue of the theorem that every Boolean
    formula has an equivalent DNF, or that every polynomial expression
    can be expanded into a canonical polynomial. -/
theorem exists_tropical_nf {n : ℕ} (e : TropExpr n) :
    ∃ N : TropNF n, ∀ x, TropExpr.eval e x = TropNF.eval N x := by
  exact ⟨TropExpr.normalize e, fun x => congr_fun (normalize_sound e) x⟩

/-! ## Connection to Tropical Distributivity -/

/-- The tropical distributivity identity, which is the semantic certificate
    underlying the entire normalization procedure.
    This is equivalent to `tropical_add_min_distrib` from Foundations.lean. -/
theorem tropical_distrib_certificate (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith

/-- Right-handed version of tropical distributivity. -/
theorem tropical_distrib_right (a b c : ℝ) :
    min a b + c = min (a + c) (b + c) := by
  simp [min_def]; split_ifs <;> linarith

/-! ## Soundness implies semantic decidability (forward direction) -/

/-- If two expressions normalize to the same normal form, they are
    semantically equal. This is the "completeness" direction that follows
    trivially from soundness. -/
theorem normalize_eq_implies_eval_eq {n : ℕ} (e₁ e₂ : TropExpr n)
    (h : TropExpr.normalize e₁ = TropExpr.normalize e₂) :
    TropExpr.eval e₁ = TropExpr.eval e₂ := by
  rw [normalize_sound e₁, normalize_sound e₂, h]

end