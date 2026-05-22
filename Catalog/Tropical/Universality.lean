/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Computational Universality of Tropical Cellular Automata

This file proves the central universality theorem: given a certified library
of collision gadgets with an isolation/composition property, every finite
Boolean circuit can be compiled into a CA configuration whose evolution
computes the circuit.

## Main results

* `not_from_nand`, `and_from_nand`, `or_from_nand` — NAND generates common gates
* `BoolExpr` — recursive Boolean expression type with `eval`
* `var_realizable` — input variable compilation
* `single_nand_realizable` — single NAND gate compilation
* `nand_basis_universal` — **every Boolean expression is realizable**
* `binary_bool_fn_expressible` — NAND functional completeness (2 vars)
* `full_binary_universality` — every binary Boolean function is realizable
* `composition_from_isolation` — composition from isolation property
-/
import Tropical.CA.Defs

namespace TropicalCA

/-! ## NAND Generates Common Gates -/

lemma not_from_nand (a : Bool) : !a = !(a && a) := by cases a <;> rfl

lemma and_from_nand (a b : Bool) : (a && b) = !(!(a && b) && !(a && b)) := by
  cases a <;> cases b <;> rfl

lemma or_from_nand (a b : Bool) :
    (a || b) = !(!(a && a) && !(b && b)) := by
  cases a <;> cases b <;> rfl

/-! ## Recursive Boolean Expressions -/

/-- A Boolean expression built from input variables and NAND gates. -/
inductive BoolExpr (n : ℕ) : Type where
  | var : Fin n → BoolExpr n
  | nand : BoolExpr n → BoolExpr n → BoolExpr n
  deriving Repr

/-- Evaluate a Boolean expression given input values. -/
def BoolExpr.eval {n : ℕ} : BoolExpr n → (Fin n → Bool) → Bool
  | .var i, input => input i
  | .nand e₁ e₂, input => !(e₁.eval input && e₂.eval input)

def BoolExpr.not {n : ℕ} (e : BoolExpr n) : BoolExpr n := .nand e e
def BoolExpr.and {n : ℕ} (e₁ e₂ : BoolExpr n) : BoolExpr n :=
  .nand (.nand e₁ e₂) (.nand e₁ e₂)
def BoolExpr.or {n : ℕ} (e₁ e₂ : BoolExpr n) : BoolExpr n :=
  .nand (.nand e₁ e₁) (.nand e₂ e₂)

theorem BoolExpr.eval_not {n : ℕ} (e : BoolExpr n) (input : Fin n → Bool) :
    (BoolExpr.not e).eval input = !(e.eval input) := by
  simp [BoolExpr.not, BoolExpr.eval]

theorem BoolExpr.eval_and {n : ℕ} (e₁ e₂ : BoolExpr n) (input : Fin n → Bool) :
    (BoolExpr.and e₁ e₂).eval input = (e₁.eval input && e₂.eval input) := by
  simp only [BoolExpr.and, BoolExpr.eval, Bool.not_and, Bool.not_or, Bool.not_not,
    Bool.or_self]

theorem BoolExpr.eval_or {n : ℕ} (e₁ e₂ : BoolExpr n) (input : Fin n → Bool) :
    (BoolExpr.or e₁ e₂).eval input = (e₁.eval input || e₂.eval input) := by
  simp only [BoolExpr.or, BoolExpr.eval, Bool.not_and]
  cases e₁.eval input <;> cases e₂.eval input <;> rfl

/-! ## Realizability (Prop-valued) -/

/-- A Boolean expression is realizable by a CA step function if there exist
    a runtime, encoding, and decoding such that evolution computes the expression. -/
def IsRealizable (S : Type*) (m n : ℕ) (step : Config S m n → Config S m n)
    {k : ℕ} (e : BoolExpr k) : Prop :=
  ∃ (runtime : ℕ) (encode : (Fin k → Bool) → Config S m n)
    (decode : Config S m n → Bool),
    ∀ input : Fin k → Bool,
      decode (evolve step runtime (encode input)) = e.eval input

/-! ## Base Cases -/

/-- An input variable is realizable from the wire gadget. -/
theorem var_realizable {S : Type*} {m n k : ℕ}
    {step : Config S m n → Config S m n}
    (lib : GadgetLibrary S m n step) (i : Fin k) :
    IsRealizable S m n step (BoolExpr.var i) := by
  refine ⟨lib.wireGadget.runtime,
    fun input => lib.wireGadget.encode (input i),
    lib.wireGadget.decode,
    fun input => ?_⟩
  simp only [BoolExpr.eval]
  rw [lib.wireGadget.correct]
  simp [lib.wire_correct]

/-- A single NAND gate is realizable from the gadget library. -/
theorem single_nand_realizable {S : Type*} {m n : ℕ}
    {step : Config S m n → Config S m n}
    (lib : GadgetLibrary S m n step) :
    IsRealizable S m n step (BoolExpr.nand (.var (0 : Fin 2)) (.var 1)) := by
  refine ⟨lib.nandGadget.runtime,
    fun input => lib.nandGadget.encode (input 0) (input 1),
    lib.nandGadget.decode,
    fun input => ?_⟩
  simp only [BoolExpr.eval]
  rw [lib.nandGadget.correct]
  have h := lib.nand_correct
  change lib.nandGadget.gateFn (input 0) (input 1) = _
  rw [h]

/-! ## Composition Principle -/

/-- A composition principle: NAND of two realizable expressions is realizable. -/
def CompositionPrinciple (S : Type*) (m n : ℕ)
    (step : Config S m n → Config S m n) (k : ℕ) : Prop :=
  ∀ (e₁ e₂ : BoolExpr k),
    IsRealizable S m n step e₁ →
    IsRealizable S m n step e₂ →
    IsRealizable S m n step (BoolExpr.nand e₁ e₂)

/-! ## Main Universality Theorem -/

/-- **Universality Theorem (NAND basis).**

    Given a certified NAND gadget library with a composition principle,
    every Boolean expression is realizable by CA evolution.

    The proof is by structural induction on the Boolean expression. -/
theorem nand_basis_universal {S : Type*} {m n : ℕ}
    {step : Config S m n → Config S m n}
    (lib : GadgetLibrary S m n step)
    {k : ℕ}
    (comp : CompositionPrinciple S m n step k) :
    ∀ (e : BoolExpr k), IsRealizable S m n step e := by
  intro e
  induction e with
  | var i => exact var_realizable lib i
  | nand e₁ e₂ ih₁ ih₂ => exact comp e₁ e₂ ih₁ ih₂

/-! ## Binary Function Realizability -/

/-- Every binary Boolean function is realizable, given completeness and composition. -/
theorem every_binary_bool_fn_realizable {S : Type*} {m n : ℕ}
    {step : Config S m n → Config S m n}
    (lib : GadgetLibrary S m n step)
    (comp : CompositionPrinciple S m n step 2)
    (f : Bool → Bool → Bool)
    (hf : ∃ e : BoolExpr 2, ∀ x y,
      e.eval (fun i => if i = 0 then x else y) = f x y) :
    ∃ (T : ℕ) (enc : Bool → Bool → Config S m n) (dec : Config S m n → Bool),
      ∀ a b, dec (evolve step T (enc a b)) = f a b := by
  obtain ⟨e, he⟩ := hf
  obtain ⟨T, enc, dec, hcorr⟩ := nand_basis_universal lib comp e
  exact ⟨T,
    fun a b => enc (fun i => if i = 0 then a else b),
    dec,
    fun a b => by rw [hcorr]; exact he a b⟩

/-! ## Functional Completeness -/

/-- Build a BoolExpr from a truth table (values at tt, tf, ft, ff). -/
def buildBoolExpr (a b c d : Bool) : BoolExpr 2 :=
  let x : BoolExpr 2 := .var 0
  let y : BoolExpr 2 := .var 1
  let nx := BoolExpr.nand x x
  let ny := BoolExpr.nand y y
  let ct := BoolExpr.nand nx x
  let cf := BoolExpr.nand ct ct
  let andE (e1 e2 : BoolExpr 2) := BoolExpr.nand (.nand e1 e2) (.nand e1 e2)
  let orE (e1 e2 : BoolExpr 2) := BoolExpr.nand (.nand e1 e1) (.nand e2 e2)
  match a, b, c, d with
  | true, true, true, true => ct
  | false, false, false, false => cf
  | true, true, true, false => orE x y
  | true, true, false, false => x
  | true, false, true, false => y
  | true, false, false, false => andE x y
  | false, true, true, true => .nand x y
  | false, false, true, true => nx
  | false, true, false, true => ny
  | false, false, false, true => andE nx ny
  | false, true, false, false => andE x ny
  | false, false, true, false => andE nx y
  | true, false, false, true => orE (andE x y) (andE nx ny)
  | false, true, true, false => orE (andE x ny) (andE nx y)
  | true, true, false, true => orE x ny
  | true, false, true, true => orE nx y

/-- The truth-table builder is correct: it produces the right value
    for every combination of inputs. Verified by `native_decide`. -/
lemma buildBoolExpr_correct : ∀ (a b c d x y : Bool),
    (buildBoolExpr a b c d).eval (fun i => if i = 0 then x else y) =
    if x then (if y then a else b) else (if y then c else d) := by
  native_decide

/-- **Functional completeness of NAND.**
    Every Boolean function of two variables can be expressed as a BoolExpr
    built from NAND gates. The proof constructs an explicit DNF-like expression
    from the function's truth table. -/
theorem binary_bool_fn_expressible (f : Bool → Bool → Bool) :
    ∃ e : BoolExpr 2, ∀ x y,
      e.eval (fun i => if i = 0 then x else y) = f x y := by
  refine ⟨buildBoolExpr (f true true) (f true false) (f false true) (f false false),
    fun x y => ?_⟩
  rw [buildBoolExpr_correct]
  cases x <;> cases y <;> simp

/-- **Full universality for binary functions.** -/
theorem full_binary_universality {S : Type*} {m n : ℕ}
    {step : Config S m n → Config S m n}
    (lib : GadgetLibrary S m n step)
    (comp : CompositionPrinciple S m n step 2) :
    ∀ (f : Bool → Bool → Bool),
      ∃ (T : ℕ) (enc : Bool → Bool → Config S m n) (dec : Config S m n → Bool),
        ∀ a b, dec (evolve step T (enc a b)) = f a b := by
  intro f
  exact every_binary_bool_fn_realizable lib comp f (binary_bool_fn_expressible f)

/-! ## Composition from Isolation -/

/-- The composition principle follows from an isolation/layout hypothesis. -/
theorem composition_from_isolation {S : Type*} {m n k : ℕ}
    {step : Config S m n → Config S m n}
    (layout : ∀ (f₁ f₂ : (Fin k → Bool) → Bool)
      (T₁ : ℕ) (enc₁ : (Fin k → Bool) → Config S m n) (dec₁ : Config S m n → Bool)
      (T₂ : ℕ) (enc₂ : (Fin k → Bool) → Config S m n) (dec₂ : Config S m n → Bool),
      (∀ input, dec₁ (evolve step T₁ (enc₁ input)) = f₁ input) →
      (∀ input, dec₂ (evolve step T₂ (enc₂ input)) = f₂ input) →
      ∃ (T : ℕ) (enc : (Fin k → Bool) → Config S m n) (dec : Config S m n → Bool),
        ∀ input, dec (evolve step T (enc input)) = !(f₁ input && f₂ input)) :
    CompositionPrinciple S m n step k := by
  intro e₁ e₂ ⟨T₁, enc₁, dec₁, h₁⟩ ⟨T₂, enc₂, dec₂, h₂⟩
  obtain ⟨T, enc, dec, hcorr⟩ :=
    layout (e₁.eval) (e₂.eval) T₁ enc₁ dec₁ T₂ enc₂ dec₂ h₁ h₂
  exact ⟨T, enc, dec, fun input => by
    rw [hcorr]; simp [BoolExpr.eval]⟩

end TropicalCA