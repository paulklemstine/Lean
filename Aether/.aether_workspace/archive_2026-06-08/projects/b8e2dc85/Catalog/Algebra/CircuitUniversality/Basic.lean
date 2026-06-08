/-
Copyright (c) 2025 Circuit Universality Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Circuit Universality: NAND Gate Functional Completeness

This file formalizes boolean circuits built from NAND gates and proves that
every boolean function on `n` bits can be realized by such a circuit.

The proof proceeds via Disjunctive Normal Form (DNF) synthesis:
1. Express NOT, AND, OR in terms of NAND.
2. Build literal and minterm circuits.
3. Construct a DNF circuit from satisfying assignments.
4. Prove correctness of the synthesis.

## Main results

* `nand_universal` — Every boolean function `f : (Fin n → Bool) → Bool` is
  computed by some NAND circuit.
-/

import Mathlib

open Finset

/-! ## Boolean function type -/

/-- A boolean function on `n` input bits. -/
abbrev BFun (n : ℕ) := (Fin n → Bool) → Bool

/-! ## Circuit definition -/

/-- A circuit built from projections, constants, and binary NAND gates. -/
inductive Circuit (n : ℕ) : Type where
  | input : Fin n → Circuit n
  | const : Bool → Circuit n
  | nand  : Circuit n → Circuit n → Circuit n
  deriving Repr, DecidableEq

namespace Circuit

/-- Evaluate a circuit on an input assignment. -/
def eval {n : ℕ} : Circuit n → (Fin n → Bool) → Bool
  | input i, σ => σ i
  | const b, _ => b
  | nand a b, σ => !(eval a σ && eval b σ)

/-- Size of a circuit (number of nodes). -/
def size {n : ℕ} : Circuit n → ℕ
  | input _ => 1
  | const _ => 1
  | nand a b => 1 + size a + size b

/-- Depth of a circuit. -/
def depth {n : ℕ} : Circuit n → ℕ
  | input _ => 0
  | const _ => 0
  | nand a b => 1 + max (depth a) (depth b)

/-! ## Derived gates from NAND -/

/-- NOT gate: `¬a = nand(a, a)` -/
def notC {n : ℕ} (c : Circuit n) : Circuit n := nand c c

/-- AND gate: `a ∧ b = ¬(nand(a, b))` -/
def andC {n : ℕ} (a b : Circuit n) : Circuit n := notC (nand a b)

/-- OR gate: `a ∨ b = nand(¬a, ¬b)` -/
def orC {n : ℕ} (a b : Circuit n) : Circuit n := nand (notC a) (notC b)

/-! ## Evaluation lemmas for derived gates -/

@[simp]
theorem eval_input {n : ℕ} (i : Fin n) (σ : Fin n → Bool) :
    eval (input i) σ = σ i := rfl

@[simp]
theorem eval_const {n : ℕ} (b : Bool) (σ : Fin n → Bool) :
    eval (const b) σ = b := rfl

@[simp]
theorem eval_nand {n : ℕ} (a b : Circuit n) (σ : Fin n → Bool) :
    eval (nand a b) σ = !(eval a σ && eval b σ) := rfl

@[simp]
theorem eval_notC {n : ℕ} (c : Circuit n) (σ : Fin n → Bool) :
    eval (notC c) σ = !eval c σ := by
  unfold notC; simp [eval]

@[simp]
theorem eval_andC {n : ℕ} (a b : Circuit n) (σ : Fin n → Bool) :
    eval (andC a b) σ = (eval a σ && eval b σ) := by
  unfold andC; simp [eval_notC, eval_nand]

@[simp]
theorem eval_orC {n : ℕ} (a b : Circuit n) (σ : Fin n → Bool) :
    eval (orC a b) σ = (eval a σ || eval b σ) := by
  unfold orC; simp [eval_notC, eval_nand]

/-! ## Literal circuits -/

/-- A literal circuit: outputs `true` iff input `i` equals `b`. -/
def literalC {n : ℕ} (i : Fin n) (b : Bool) : Circuit n :=
  match b with
  | true  => input i
  | false => notC (input i)

@[simp]
theorem eval_literalC {n : ℕ} (i : Fin n) (b : Bool) (σ : Fin n → Bool) :
    eval (literalC i b) σ = (σ i == b) := by
  cases b <;> simp [literalC, eval_notC]

/-! ## Conjunction of all literals (minterm) -/

/-- Conjunction of a list of circuits. Uses constant `true` for empty list. -/
def andList {n : ℕ} : List (Circuit n) → Circuit n
  | []      => const true
  | [c]     => c
  | c :: cs => andC c (andList cs)

theorem eval_andList {n : ℕ} (cs : List (Circuit n)) (σ : Fin n → Bool) :
    eval (andList cs) σ = cs.foldr (fun c acc => eval c σ && acc) true := by
  induction cs with
  | nil => simp [andList]
  | cons c cs ih =>
    cases cs with
    | nil => simp [andList, List.foldr]
    | cons d ds =>
      simp only [andList, eval_andC, List.foldr, ih]

/-- Minterm circuit: outputs `true` iff the input equals `τ`. -/
def mintermC {n : ℕ} (τ : Fin n → Bool) : Circuit n :=
  andList (List.ofFn (fun i => literalC i (τ i)))

theorem eval_mintermC {n : ℕ} (τ σ : Fin n → Bool) :
    eval (mintermC τ) σ = true ↔ σ = τ := by
  have h_minterm : ∀ (σ τ : Fin n → Bool), (mintermC τ).eval σ = true → σ = τ := by
    intros σ τ hσ
    have h_minterm : ∀ i : Fin n, (literalC i (τ i)).eval σ = true := by
      have h_minterm : (mintermC τ).eval σ = List.foldr (fun c acc => eval c σ && acc) true (List.ofFn (fun i => literalC i (τ i))) := by
        convert eval_andList _ _;
      simp_all +decide [ List.ofFn_eq_map ];
      have h_minterm : ∀ (l : List (Circuit n)), (List.foldr (fun c acc => eval c σ && acc) true l) = true → ∀ c ∈ l, eval c σ = true := by
        intros l hl c hc; induction l <;> aesop;
      intro i; specialize h_minterm _ hσ ( literalC i ( τ i ) ) ; aesop;
    exact funext fun i => by specialize h_minterm i; cases h : τ i <;> simp_all +decide [ eval_literalC ] ;
  have h_minterm : ∀ (τ : Fin n → Bool), (mintermC τ).eval τ = true := by
    intro τ
    simp [mintermC, eval_andList];
    simp +decide [ List.ofFn_eq_map, List.foldr_map ];
  grind +splitImp

/-! ## Disjunction of a list of circuits -/

/-- Disjunction of a list of circuits. Uses constant `false` for empty list. -/
def orList {n : ℕ} : List (Circuit n) → Circuit n
  | []      => const false
  | [c]     => c
  | c :: cs => orC c (orList cs)

theorem eval_orList {n : ℕ} (cs : List (Circuit n)) (σ : Fin n → Bool) :
    eval (orList cs) σ = cs.foldr (fun c acc => eval c σ || acc) false := by
  induction cs with
  | nil => simp [orList]
  | cons c cs ih =>
    cases cs with
    | nil => simp [orList, List.foldr]
    | cons d ds =>
      simp only [orList, eval_orC, List.foldr, ih]

theorem eval_orList_eq_true {n : ℕ} (cs : List (Circuit n)) (σ : Fin n → Bool) :
    eval (orList cs) σ = true ↔ ∃ c ∈ cs, eval c σ = true := by
  rw [eval_orList]
  induction cs with
  | nil => simp [List.foldr]
  | cons c cs ih =>
    simp only [List.foldr, List.mem_cons, exists_eq_or_imp]
    rw [Bool.or_eq_true]
    exact or_congr_right ih

/-! ## DNF synthesis -/

/-- The list of all satisfying assignments for a boolean function. -/
noncomputable def satAssignments {n : ℕ} (f : BFun n) : List (Fin n → Bool) :=
  (Finset.univ.filter (fun σ => f σ = true)).toList

/-- The DNF circuit: disjunction of minterms for each satisfying assignment. -/
noncomputable def dnfCircuit {n : ℕ} (f : BFun n) : Circuit n :=
  orList (satAssignments f |>.map mintermC)

theorem eval_dnfCircuit {n : ℕ} (f : BFun n) (σ : Fin n → Bool) :
    eval (dnfCircuit f) σ = f σ := by
  -- By definition of $dnfCircuit$, we know that its evaluation is true if and only if there exists a satisfying assignment $\tau$ such that $mintermC \tau$ evaluates to true on $\sigma$.
  have h_eval : (dnfCircuit f).eval σ = true ↔ ∃ τ ∈ (Finset.univ.filter (fun σ => f σ = true)).toList, (mintermC τ).eval σ = true := by
    convert eval_orList_eq_true _ _ using 1;
    unfold satAssignments; aesop;
  simp_all +decide [ eval_mintermC ]

/-! ## Main universality theorem -/

/-- **NAND universality**: every boolean function on `n` bits can be computed
by a circuit built from projections, constants, and NAND gates. -/
theorem nand_universal {n : ℕ} (f : (Fin n → Bool) → Bool) :
    ∃ c : Circuit n, ∀ σ : Fin n → Bool, eval c σ = f σ :=
  ⟨dnfCircuit f, eval_dnfCircuit f⟩

end Circuit