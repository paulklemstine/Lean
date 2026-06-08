/-
# Tropical Monotone Circuits: Definitions

This file defines the core data structures for tropical monotone circuits:
a syntax-level inductive circuit language, evaluation semantics, size/depth
measures, and the Boolean monotone formula language with its translation
into tropical circuits.

## Main Definitions

* `TropCircuit n` — Inductive type for tropical monotone circuits over `n` variables
* `TropCircuit.eval` — Evaluation of a circuit at a given input vector
* `TropCircuit.size` — Number of nodes in the circuit
* `TropCircuit.depth` — Depth (longest root-to-leaf path) of the circuit
* `BoolMonoFormula n` — Boolean monotone formulas (and/or/var/top/bot)
* `BoolMonoFormula.eval` — Boolean evaluation
* `translate` — Translation from Boolean monotone formulas to tropical circuits
* `TropAffine n` — Affine forms for normal-form representation
* `normalForms` — Extract the set of affine forms from a circuit
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Tropical Circuit Syntax -/

/-- A tropical monotone circuit over `n` input variables.
Gates are binary `min` and binary `+`, with leaves being variables or real constants. -/
inductive TropCircuit (n : ℕ) : Type
  | var   : Fin n → TropCircuit n
  | const : ℝ → TropCircuit n
  | add   : TropCircuit n → TropCircuit n → TropCircuit n
  | min   : TropCircuit n → TropCircuit n → TropCircuit n
  deriving Inhabited

namespace TropCircuit

/-! ## Evaluation -/

/-- Evaluate a tropical circuit at input vector `x : Fin n → ℝ`. -/
def eval {n : ℕ} : TropCircuit n → (Fin n → ℝ) → ℝ
  | var i,   x => x i
  | const c, _ => c
  | add a b, x => eval a x + eval b x
  | min a b, x => Min.min (eval a x) (eval b x)

/-! ## Size and Depth -/

/-- Number of nodes in the circuit (leaves count as 1). -/
def size {n : ℕ} : TropCircuit n → ℕ
  | var _     => 1
  | const _   => 1
  | add a b   => 1 + size a + size b
  | min a b   => 1 + size a + size b

/-- Depth of the circuit (longest root-to-leaf path). -/
def depth {n : ℕ} : TropCircuit n → ℕ
  | var _     => 0
  | const _   => 0
  | add a b   => 1 + max (depth a) (depth b)
  | min a b   => 1 + max (depth a) (depth b)

/-! ## Basic evaluation lemmas -/

@[simp]
theorem eval_var {n : ℕ} (i : Fin n) (x : Fin n → ℝ) :
    eval (var i) x = x i := rfl

@[simp]
theorem eval_const {n : ℕ} (c : ℝ) (x : Fin n → ℝ) :
    eval (const c) x = c := rfl

@[simp]
theorem eval_add {n : ℕ} (C D : TropCircuit n) (x : Fin n → ℝ) :
    eval (add C D) x = eval C x + eval D x := rfl

@[simp]
theorem eval_min {n : ℕ} (C D : TropCircuit n) (x : Fin n → ℝ) :
    eval (min C D) x = Min.min (eval C x) (eval D x) := rfl

end TropCircuit

/-! ## Boolean Monotone Formulas -/

/-- Boolean monotone formulas over `n` variables. -/
inductive BoolMonoFormula (n : ℕ) : Type
  | var : Fin n → BoolMonoFormula n
  | top : BoolMonoFormula n
  | bot : BoolMonoFormula n
  | and : BoolMonoFormula n → BoolMonoFormula n → BoolMonoFormula n
  | or  : BoolMonoFormula n → BoolMonoFormula n → BoolMonoFormula n
  deriving Inhabited

namespace BoolMonoFormula

/-- Evaluate a Boolean monotone formula at assignment `σ`. -/
def eval {n : ℕ} : BoolMonoFormula n → (Fin n → Bool) → Bool
  | var i,   σ => σ i
  | top,     _ => true
  | bot,     _ => false
  | and a b, σ => eval a σ && eval b σ
  | or a b,  σ => eval a σ || eval b σ

end BoolMonoFormula

/-! ## Boolean-Tropical Encoding -/

/-- Encode `Bool` into `ℝ` for tropical computation: `true ↦ 0`, `false ↦ 1`. -/
def encodeBool : Bool → ℝ
  | true  => 0
  | false => 1

/-- Decode a real number back to `Bool`: values `≤ 0` decode to `true`. -/
def decodeBool (r : ℝ) : Bool := decide (r ≤ 0)

/-! ## Translation from Boolean Formulas to Tropical Circuits -/

/-- Translate a Boolean monotone formula into a tropical circuit.
- Variables map to variables.
- `top` maps to constant `0` (= true).
- `bot` maps to constant `1` (= false).
- `or` maps to `min` (minimum of {0,1} values gives logical OR).
- `and` maps to `add` (sum of {0,1} values, with threshold decoding for AND). -/
def BoolMonoFormula.toTropCircuit {n : ℕ} : BoolMonoFormula n → TropCircuit n
  | BoolMonoFormula.var i   => TropCircuit.var i
  | BoolMonoFormula.top     => TropCircuit.const 0
  | BoolMonoFormula.bot     => TropCircuit.const 1
  | BoolMonoFormula.and a b => TropCircuit.add (toTropCircuit a) (toTropCircuit b)
  | BoolMonoFormula.or a b  => TropCircuit.min (toTropCircuit a) (toTropCircuit b)

/-! ## Tropical Affine Forms for Normal-Form Representation -/

/-- An affine form in tropical algebra: represents `const + Σᵢ coeff(i) * xᵢ`. -/
structure TropAffine (n : ℕ) where
  coeff : Fin n → ℕ
  const : ℝ

namespace TropAffine

/-- Evaluate an affine form at input `x`. -/
def eval {n : ℕ} (a : TropAffine n) (x : Fin n → ℝ) : ℝ :=
  a.const + ∑ i : Fin n, (a.coeff i : ℝ) * x i

end TropAffine

/-! ## Normal Form Extraction

For any tropical circuit (which is a formula/tree by construction),
we can extract a finite multiset of affine forms such that the circuit
evaluates to their minimum. -/

/-- Extract the normal-form affine family from a tropical circuit.
- `var i` yields a singleton with coefficient 1 at position `i`.
- `const c` yields a singleton with constant `c` and zero coefficients.
- `min a b` yields the union of the normal forms.
- `add a b` yields the pairwise sum (tropical convolution). -/
def normalForms {n : ℕ} : TropCircuit n → Multiset (TropAffine n)
  | TropCircuit.var i =>
      {⟨Function.update (fun _ => 0) i 1, 0⟩}
  | TropCircuit.const c =>
      {⟨fun _ => 0, c⟩}
  | TropCircuit.min a b =>
      normalForms a + normalForms b
  | TropCircuit.add a b =>
      (normalForms a).bind fun fa =>
        (normalForms b).map fun fb =>
          ⟨fun j => fa.coeff j + fb.coeff j, fa.const + fb.const⟩

/-! ## Max-Plus (Dual) Tropical Circuits -/

/-- A max-plus tropical circuit: uses `max` and `+` instead of `min` and `+`. -/
inductive MaxTropCircuit (n : ℕ) : Type
  | var   : Fin n → MaxTropCircuit n
  | const : ℝ → MaxTropCircuit n
  | add   : MaxTropCircuit n → MaxTropCircuit n → MaxTropCircuit n
  | max   : MaxTropCircuit n → MaxTropCircuit n → MaxTropCircuit n
  deriving Inhabited

namespace MaxTropCircuit

/-- Evaluate a max-plus tropical circuit. -/
def eval {n : ℕ} : MaxTropCircuit n → (Fin n → ℝ) → ℝ
  | var i,   x => x i
  | const c, _ => c
  | add a b, x => eval a x + eval b x
  | max a b, x => Max.max (eval a x) (eval b x)

end MaxTropCircuit

/-- Syntactic duality: negate constants and swap min↔max. -/
def TropCircuit.dual {n : ℕ} : TropCircuit n → MaxTropCircuit n
  | TropCircuit.var i   => MaxTropCircuit.var i
  | TropCircuit.const c => MaxTropCircuit.const (-c)
  | TropCircuit.add a b => MaxTropCircuit.add (dual a) (dual b)
  | TropCircuit.min a b => MaxTropCircuit.max (dual a) (dual b)

end