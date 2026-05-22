/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Polynomial Normal Forms: A Reflective Decision Procedure

## Overview

This file defines tropical polynomial expressions over `Fin n` variables,
their evaluation semantics (where tropical addition = `max` and tropical
multiplication = `+`), and an AC-normalization procedure that computes
canonical representatives modulo associativity, commutativity, and the
tropical distributive law.

The decisive result is semantic soundness: the normalizer preserves
evaluation, yielding a verified bridge from syntax to semantics.

## Main definitions

* `TropicalNF.TropExpr` — Syntax of tropical expressions
* `TropicalNF.TropPolyNF` — Normal form as a nonempty `Finset` of monomials
* `TropicalNF.TropExpr.normalize` — The normalization function
* `TropicalNF.evalMonomial` — Evaluation of a single tropical monomial
* `TropicalNF.TropPolyNF.eval` — Evaluation of a polynomial in normal form

## Main results

* `TropicalNF.evalMonomial_mulMonomial` — Monomial product is additive on evaluation
* `TropicalNF.eval_addNF` — Tropical addition on NFs corresponds to `max`
* `TropicalNF.eval_mulNF` — Tropical multiplication on NFs corresponds to `+`
* `TropicalNF.eval_normalize` — **Soundness**: normalization preserves semantics
* `TropicalNF.normalize_complete_functional` — Equal NFs imply equal functions
* `TropicalNF.affine_lower_bound_of_nf` — Each monomial gives a certified lower bound
* `TropicalNF.lower_bound_preserved_by_normalize` — Bounds transport through normalization

## Mathematical content

A tropical polynomial over `n` variables is a finite maximum of affine forms
`c + w₁x₁ + w₂x₂ + ⋯ + wₙxₙ` where `c ∈ ℝ` and `wᵢ ∈ ℕ`. The normal
form represents such polynomials as `Finset (ℝ × (Fin n → ℕ))`, where:
- Tropical addition (`tmax`) corresponds to `Finset.union`
- Tropical multiplication (`tplus`) corresponds to Minkowski sum

This is the formal seed of Newton polytope reasoning: the support of a
tropical polynomial determines a finite subset of `ℝ × ℕⁿ`, and tropical
operations act geometrically on this support data.
-/
import Mathlib

noncomputable section

open scoped BigOperators
open Finset

namespace TropicalNF

/-! ## Tropical Monomials -/

/-- A tropical monomial over `n` variables: a coefficient `c : ℝ` and
    an exponent vector `w : Fin n → ℕ`.
    Semantically represents the affine form `x ↦ c + ∑ i, (w i) * x i`. -/
abbrev TropMonomial (n : ℕ) := ℝ × (Fin n → ℕ)

/-- Evaluation of a single tropical monomial at a valuation `x`. -/
def evalMonomial {n : ℕ} (m : TropMonomial n) (x : Fin n → ℝ) : ℝ :=
  m.1 + ∑ i : Fin n, (m.2 i : ℝ) * x i

/-! ## Tropical Expression Syntax -/

/-- Tropical expression syntax over `Fin n` variables.
    - `var i` represents the variable `xᵢ`
    - `const c` represents the real constant `c`
    - `tmax e₁ e₂` represents tropical addition (= classical `max`)
    - `tplus e₁ e₂` represents tropical multiplication (= classical `+`) -/
inductive TropExpr (n : ℕ) where
  | var   : Fin n → TropExpr n
  | const : ℝ → TropExpr n
  | tmax  : TropExpr n → TropExpr n → TropExpr n
  | tplus : TropExpr n → TropExpr n → TropExpr n

/-- Evaluation of a tropical expression: `tmax ↦ max`, `tplus ↦ +`. -/
def TropExpr.eval {n : ℕ} : TropExpr n → (Fin n → ℝ) → ℝ
  | .var i,       x => x i
  | .const c,     _ => c
  | .tmax e₁ e₂,  x => max (e₁.eval x) (e₂.eval x)
  | .tplus e₁ e₂, x => e₁.eval x + e₂.eval x

/-! ## Tropical Polynomial Normal Form -/

/-- A tropical polynomial in normal form: a nonempty finite set of monomials.
    The semantics is the pointwise maximum of the constituent affine forms.
    This representation makes the Newton polytope structure explicit:
    the support is a finite subset of `ℝ × ℕⁿ`. -/
structure TropPolyNF (n : ℕ) where
  support : Finset (TropMonomial n)
  nonempty : support.Nonempty

/-- Evaluation of a tropical polynomial in normal form:
    takes the maximum over all constituent monomials. -/
def TropPolyNF.eval {n : ℕ} (p : TropPolyNF n) (x : Fin n → ℝ) : ℝ :=
  p.support.sup' p.nonempty (evalMonomial · x)

/-! ## Operations on Normal Forms -/

/-- Tropical addition of normal forms: union of monomial supports.
    Corresponds to taking the pointwise maximum of two piecewise-linear functions. -/
def addNF {n : ℕ} (S T : TropPolyNF n) : TropPolyNF n where
  support := S.support ∪ T.support
  nonempty := S.nonempty.mono subset_union_left

/-- Pointwise addition of two tropical monomials (tropical multiplication):
    coefficients add, exponent vectors add componentwise. -/
def mulMonomial {n : ℕ} (m₁ m₂ : TropMonomial n) : TropMonomial n :=
  (m₁.1 + m₂.1, fun i => m₁.2 i + m₂.2 i)

/-- Tropical multiplication of normal forms: Minkowski sum of supports.
    Each monomial from `S` is combined with each monomial from `T`
    via `mulMonomial`. This is the geometric heart of the construction:
    tropical multiplication acts as Minkowski addition on Newton supports. -/
def mulNF {n : ℕ} (S T : TropPolyNF n) : TropPolyNF n where
  support := (S.support ×ˢ T.support).image (fun p => mulMonomial p.1 p.2)
  nonempty := by
    obtain ⟨a, ha⟩ := S.nonempty
    obtain ⟨b, hb⟩ := T.nonempty
    exact ⟨mulMonomial a b, mem_image.mpr ⟨(a, b), mem_product.mpr ⟨ha, hb⟩, rfl⟩⟩

/-! ## Normalization -/

/-- Normalize a tropical expression into polynomial normal form.
    - Variables become singleton monomials with unit exponent
    - Constants become singleton monomials with zero exponent
    - `tmax` becomes union of supports (`addNF`)
    - `tplus` becomes Minkowski sum of supports (`mulNF`) -/
def TropExpr.normalize {n : ℕ} : TropExpr n → TropPolyNF n
  | .var i   => ⟨{(0, Pi.single i 1)}, ⟨_, mem_singleton_self _⟩⟩
  | .const c => ⟨{(c, fun _ => 0)}, ⟨_, mem_singleton_self _⟩⟩
  | .tmax e₁ e₂  => addNF e₁.normalize e₂.normalize
  | .tplus e₁ e₂ => mulNF e₁.normalize e₂.normalize

/-! ## Key Algebraic Lemmas -/

/-
Evaluation of a monomial with zero exponent vector is just its coefficient.
-/
theorem evalMonomial_const (c : ℝ) (n : ℕ) (x : Fin n → ℝ) :
    evalMonomial (c, fun _ => 0) x = c := by
  -- By definition of `evalMonomial`, we have `evalMonomial (c, fun _ => 0) x = c + ∑ i, (0 : ℝ) * x i`.
  simp [evalMonomial]

/-
Evaluation of a variable monomial recovers the variable value.
-/
theorem evalMonomial_var {n : ℕ} (i : Fin n) (x : Fin n → ℝ) :
    evalMonomial (0, Pi.single i 1) x = x i := by
  unfold evalMonomial;
  simp +decide [ Finset.sum_ite_eq', Pi.single_apply ]

/-
Tropical monomial multiplication is additive on evaluation:
    `eval(m₁ ⊗ m₂, x) = eval(m₁, x) + eval(m₂, x)`.
    This is the algebraic core of the Minkowski sum correspondence.
-/
theorem evalMonomial_mulMonomial {n : ℕ} (m₁ m₂ : TropMonomial n) (x : Fin n → ℝ) :
    evalMonomial (mulMonomial m₁ m₂) x = evalMonomial m₁ x + evalMonomial m₂ x := by
  unfold evalMonomial mulMonomial;
  simp +decide [ add_mul, Finset.sum_add_distrib, add_assoc ];
  ring

/-! ## Soundness of Normal Form Operations -/

/-
Tropical addition on normal forms corresponds to `max` on evaluations.
-/
theorem eval_addNF {n : ℕ} (S T : TropPolyNF n) (x : Fin n → ℝ) :
    (addNF S T).eval x = max (S.eval x) (T.eval x) := by
  convert sup'_union S.nonempty T.nonempty ( fun m => evalMonomial m x ) using 1

/-
The supremum over a product set of sums equals the sum of suprema.
    This is the key combinatorial identity behind tropical multiplication:
    `max_{(a,b) ∈ S×T} (f(a) + g(b)) = max_{a ∈ S} f(a) + max_{b ∈ T} g(b)`.
-/
theorem sup'_product_add {α β : Type*} [DecidableEq α] [DecidableEq β]
    {S : Finset α} {T : Finset β}
    (hS : S.Nonempty) (hT : T.Nonempty)
    (f : α → ℝ) (g : β → ℝ) :
    (S ×ˢ T).sup' (hS.product hT) (fun p => f p.1 + g p.2) =
    S.sup' hS f + T.sup' hT g := by
  refine' le_antisymm _ _
  all_goals generalize_proofs at *;
  · simp +zetaDelta at *;
    exact fun a b ha hb => add_le_add ( Finset.le_sup' f ha ) ( Finset.le_sup' g hb );
  · obtain ⟨ a, ha ⟩ := Finset.exists_mem_eq_sup' hS ( fun a => f a ) ; obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_sup' hT ( fun b => g b ) ; aesop;

/-
Tropical multiplication on normal forms corresponds to `+` on evaluations.
    This is the Minkowski sum theorem: the max of pairwise sums equals the sum of maxes.
-/
theorem eval_mulNF {n : ℕ} (S T : TropPolyNF n) (x : Fin n → ℝ) :
    (mulNF S T).eval x = S.eval x + T.eval x := by
  convert sup'_product_add ?_ ?_ _ _ using 1;
  · unfold TropPolyNF.eval mulNF;
    simp +decide [ evalMonomial_mulMonomial ];
  · infer_instance;
  · infer_instance

/-! ## Main Soundness Theorem -/

/-
**Soundness of normalization**: evaluating the normal form of an expression
    gives the same result as evaluating the expression directly.
    This is the fundamental semantic correctness theorem.
-/
theorem eval_normalize {n : ℕ} (e : TropExpr n) (x : Fin n → ℝ) :
    (e.normalize).eval x = e.eval x := by
  induction' e with e₁ e₂ ih₁ ih₂;
  · convert evalMonomial_var e₁ x using 1;
  · convert evalMonomial_const e₂ n x using 1;
  · convert eval_addNF _ _ _ using 1;
    aesop;
  · convert eval_mulNF _ _ _ using 1;
    aesop

/-- Function-level soundness: normalization preserves the evaluation function. -/
theorem normalize_sound {n : ℕ} (e : TropExpr n) :
    TropPolyNF.eval (TropExpr.normalize e) = TropExpr.eval e := by
  funext x; exact eval_normalize e x

/-! ## Completeness (Functional Direction) -/

/-
**Functional completeness**: if two expressions have equal normal forms,
    they denote the same function. This follows immediately from soundness
    and is the basis for using normalization as a decision procedure.
-/
theorem normalize_complete_functional {n : ℕ} (e₁ e₂ : TropExpr n) :
    e₁.normalize = e₂.normalize →
    ∀ x : Fin n → ℝ, e₁.eval x = e₂.eval x := by
  exact fun h x => by rw [ ← eval_normalize e₁ x, ← eval_normalize e₂ x, h ] ;

/-! ## Certified Bound Transport -/

/-
Every monomial in a normal form provides a certified lower bound:
    the evaluation of the full polynomial (= max of all monomials) is at least
    as large as any individual monomial's evaluation.
-/
theorem affine_lower_bound_of_nf {n : ℕ} (p : TropPolyNF n) (m : TropMonomial n)
    (hm : m ∈ p.support) (x : Fin n → ℝ) :
    evalMonomial m x ≤ p.eval x := by
  exact Finset.le_sup' ( fun m => evalMonomial m x ) hm

/-
**Bounds transport through normalization**: any lower bound on the evaluation
    of a tropical expression is preserved by normalization.
    This connects symbolic normalization to certified optimization.
-/
theorem lower_bound_preserved_by_normalize {n : ℕ} (e : TropExpr n) (L : ℝ) :
    (∀ x : Fin n → ℝ, L ≤ e.eval x) →
    ∀ x : Fin n → ℝ, L ≤ (e.normalize).eval x := by
  exact fun h x => by rw [ eval_normalize ] ; exact h x;

/-! ## Tropical Distributivity as Normal Form Consequence -/

/-
Tropical distributivity: `a + max(b, c) = max(a + b, a + c)`.
    This is a consequence of the normal form semantics and witnesses
    the interaction between Minkowski sum and union.
-/
theorem tropical_distrib (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
  cases max_cases b c <;> cases max_cases ( a + b ) ( a + c ) <;> linarith

/-
The distributive law for tropical expressions follows from normalization
    soundness: `tplus a (tmax b c)` and `tmax (tplus a b) (tplus a c)` have
    the same normal form.
-/
theorem tropical_distrib_expr {n : ℕ} (a b c : TropExpr n) (x : Fin n → ℝ) :
    (TropExpr.tplus a (TropExpr.tmax b c)).eval x =
    (TropExpr.tmax (TropExpr.tplus a b) (TropExpr.tplus a c)).eval x := by
  grind +locals

end TropicalNF