/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Arithmetic: Syntax, Semantics, and Undecidability Threshold

This file establishes the foundational definitions for a **computability threshold theorem**
in tropical (min-plus) arithmetic. We define:

1. `TropTerm` — terms built from variables, integer constants, min, addition, and optionally
   multiplication.
2. `TropAtom` — atomic formulas (equations and inequalities between terms).
3. `TropExistsCNF` — existential conjunctions of atoms.
4. Evaluation semantics over integer valuations.
5. The `MulFree` predicate, which characterizes the "basic" fragment without multiplication.

The key discovery is that multiplication is the **exact threshold** for undecidability:
- **Without multiplication**: satisfiability reduces to integer linear feasibility (decidable).
- **With multiplication**: satisfiability encodes Diophantine equations (undecidable by DPRM).
-/

import Mathlib

/-! ## Tropical Terms -/

/-- Tropical terms built from variables, integer constants, binary min, addition,
    and multiplication. The `mul` constructor is the critical enrichment that
    crosses the undecidability threshold. -/
inductive TropTerm : Type
  | var   : ℕ → TropTerm
  | const : ℤ → TropTerm
  | add   : TropTerm → TropTerm → TropTerm
  | tmin  : TropTerm → TropTerm → TropTerm
  | mul   : TropTerm → TropTerm → TropTerm
  deriving Repr, DecidableEq

namespace TropTerm

/-- A tropical term is **mul-free** if it uses only var, const, add, and tmin. -/
def MulFree : TropTerm → Bool
  | var _    => true
  | const _  => true
  | add s t  => s.MulFree && t.MulFree
  | tmin s t => s.MulFree && t.MulFree
  | mul _ _  => false

/-- Evaluate a tropical term under an integer valuation. -/
def eval (v : ℕ → ℤ) : TropTerm → ℤ
  | var n    => v n
  | const c  => c
  | add s t  => eval v s + eval v t
  | tmin s t => min (eval v s) (eval v t)
  | mul s t  => eval v s * eval v t

@[simp] theorem eval_var (v : ℕ → ℤ) (n : ℕ) : (var n).eval v = v n := rfl
@[simp] theorem eval_const (v : ℕ → ℤ) (c : ℤ) : (const c).eval v = c := rfl
@[simp] theorem eval_add (v : ℕ → ℤ) (s t : TropTerm) :
    (add s t).eval v = s.eval v + t.eval v := rfl
@[simp] theorem eval_tmin (v : ℕ → ℤ) (s t : TropTerm) :
    (tmin s t).eval v = min (s.eval v) (t.eval v) := rfl
@[simp] theorem eval_mul (v : ℕ → ℤ) (s t : TropTerm) :
    (mul s t).eval v = s.eval v * t.eval v := rfl

/-- Addition distributes over min in tropical term evaluation (left). -/
theorem eval_add_tmin_left (v : ℕ → ℤ) (s t₁ t₂ : TropTerm) :
    (add s (tmin t₁ t₂)).eval v = min ((add s t₁).eval v) ((add s t₂).eval v) := by
  simp only [eval_add, eval_tmin, add_min]

/-- Addition distributes over min in tropical term evaluation (right). -/
theorem eval_add_tmin_right (v : ℕ → ℤ) (t₁ t₂ s : TropTerm) :
    (add (tmin t₁ t₂) s).eval v = min ((add t₁ s).eval v) ((add t₂ s).eval v) := by
  simp only [eval_add, eval_tmin, min_add]

end TropTerm

/-! ## Atomic Formulas -/

/-- Atomic formulas in the min-plus language: equations and inequalities. -/
inductive TropAtom : Type
  | eq : TropTerm → TropTerm → TropAtom
  | le : TropTerm → TropTerm → TropAtom
  deriving Repr, DecidableEq

namespace TropAtom

/-- An atom holds under valuation `v`. -/
def Holds (v : ℕ → ℤ) : TropAtom → Prop
  | eq s t => s.eval v = t.eval v
  | le s t => s.eval v ≤ t.eval v

@[simp] theorem holds_eq (v : ℕ → ℤ) (s t : TropTerm) :
    (TropAtom.eq s t).Holds v ↔ s.eval v = t.eval v := Iff.rfl

@[simp] theorem holds_le (v : ℕ → ℤ) (s t : TropTerm) :
    (TropAtom.le s t).Holds v ↔ s.eval v ≤ t.eval v := Iff.rfl

/-- An atom is mul-free if both its terms are mul-free. -/
def MulFree : TropAtom → Bool
  | eq s t => s.MulFree && t.MulFree
  | le s t => s.MulFree && t.MulFree

end TropAtom

/-! ## Existential Conjunctive Formulas -/

/-- An existential conjunctive normal form tropical formula:
    "∃ v₀, ..., v_{n-1} ∈ ℤ, ⋀ atoms". -/
structure TropExistsCNF where
  numVars : ℕ
  atoms   : List TropAtom
  deriving Repr, DecidableEq

namespace TropExistsCNF

/-- A formula is satisfiable if there exists a valuation making all atoms true. -/
def Satisfiable (φ : TropExistsCNF) : Prop :=
  ∃ v : ℕ → ℤ, ∀ a ∈ φ.atoms, a.Holds v

/-- A formula is mul-free if all its atoms are mul-free. -/
def IsMulFree (φ : TropExistsCNF) : Bool :=
  φ.atoms.all TropAtom.MulFree

/-- The empty formula (no atoms) is trivially satisfiable. -/
theorem satisfiable_empty : (⟨0, []⟩ : TropExistsCNF).Satisfiable :=
  ⟨fun _ => 0, fun _ h => by simp at h⟩

/-- Adding a satisfied atom preserves satisfiability. -/
theorem satisfiable_cons {n : ℕ} {a : TropAtom} {as : List TropAtom}
    (h : (⟨n, a :: as⟩ : TropExistsCNF).Satisfiable) :
    (⟨n, as⟩ : TropExistsCNF).Satisfiable := by
  obtain ⟨v, hv⟩ := h
  exact ⟨v, fun b hb => hv b (List.mem_cons_of_mem a hb)⟩

end TropExistsCNF

/-! ## Integer Polynomial Expressions -/

/-- Integer polynomial expressions — a purely algebraic fragment without min. -/
inductive IntExpr : Type
  | var   : ℕ → IntExpr
  | const : ℤ → IntExpr
  | add   : IntExpr → IntExpr → IntExpr
  | mul   : IntExpr → IntExpr → IntExpr
  deriving Repr, DecidableEq

namespace IntExpr

/-- Evaluate an integer polynomial expression under a valuation. -/
def eval (v : ℕ → ℤ) : IntExpr → ℤ
  | var n   => v n
  | const c => c
  | add s t => eval v s + eval v t
  | mul s t => eval v s * eval v t

@[simp] theorem eval_var (v : ℕ → ℤ) (n : ℕ) : (var n).eval v = v n := rfl
@[simp] theorem eval_const (v : ℕ → ℤ) (c : ℤ) : (const c).eval v = c := rfl
@[simp] theorem eval_add (v : ℕ → ℤ) (s t : IntExpr) :
    (add s t).eval v = s.eval v + t.eval v := rfl
@[simp] theorem eval_mul (v : ℕ → ℤ) (s t : IntExpr) :
    (mul s t).eval v = s.eval v * t.eval v := rfl

/-- Embed an integer expression into a tropical term (using the mul constructor). -/
def toTropTerm : IntExpr → TropTerm
  | var n   => .var n
  | const c => .const c
  | add s t => .add s.toTropTerm t.toTropTerm
  | mul s t => .mul s.toTropTerm t.toTropTerm

/-- The embedding preserves evaluation exactly. -/
@[simp] theorem toTropTerm_eval (v : ℕ → ℤ) (e : IntExpr) :
    e.toTropTerm.eval v = e.eval v := by
  induction e with
  | var n => simp [toTropTerm]
  | const c => simp [toTropTerm]
  | add s t ihs iht => simp [toTropTerm, ihs, iht]
  | mul s t ihs iht => simp [toTropTerm, ihs, iht]

end IntExpr

/-! ## Polynomial System Encoding -/

/-- Encode a system of polynomial equations e₁ = 0, ..., eₖ = 0
    as a tropical existential formula. -/
def encodePolySystem (exprs : List IntExpr) : TropExistsCNF where
  numVars := 0  -- variables are unbounded in this formulation
  atoms := exprs.map fun e => TropAtom.eq e.toTropTerm (.const 0)

/-- The encoding correctly captures polynomial satisfiability:
    the system has an integer solution iff the tropical formula is satisfiable. -/
theorem poly_system_iff_tropical (exprs : List IntExpr) :
    (∃ v : ℕ → ℤ, ∀ e ∈ exprs, e.eval v = 0) ↔
    (encodePolySystem exprs).Satisfiable := by
  constructor
  · rintro ⟨v, hv⟩
    refine ⟨v, fun a ha => ?_⟩
    simp only [encodePolySystem, List.mem_map] at ha
    obtain ⟨e, he, rfl⟩ := ha
    simp [TropAtom.Holds, hv e he]
  · rintro ⟨v, hv⟩
    refine ⟨v, fun e he => ?_⟩
    have := hv (TropAtom.eq e.toTropTerm (.const 0))
      (by simp [encodePolySystem, List.mem_map]; exact ⟨e, he, rfl⟩)
    simpa [TropAtom.Holds] using this