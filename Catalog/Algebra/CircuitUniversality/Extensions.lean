/-
# Circuit Universality: Extensions

This file extends the basic NAND universality theorem to:
1. NOR gate universality
2. Universality from NOT + AND
3. Universality from NOT + OR
4. Non-universality of affine gates (AND is not affine)
-/

import Algebra.CircuitUniversality.Basic

open Finset

/-! ## NOR Circuit -/

/-- A circuit built from projections, constants, and binary NOR gates. -/
inductive NorCircuit (n : ℕ) : Type where
  | input : Fin n → NorCircuit n
  | const : Bool → NorCircuit n
  | nor   : NorCircuit n → NorCircuit n → NorCircuit n

namespace NorCircuit

def eval {n : ℕ} : NorCircuit n → (Fin n → Bool) → Bool
  | input i, σ => σ i
  | const b, _ => b
  | nor a b, σ => !(eval a σ || eval b σ)

/-- NOT from NOR: `¬a = nor(a, a)` -/
def notC {n : ℕ} (c : NorCircuit n) : NorCircuit n := nor c c

/-- OR from NOR: `a ∨ b = ¬(nor(a, b))` -/
def orC {n : ℕ} (a b : NorCircuit n) : NorCircuit n := notC (nor a b)

/-- AND from NOR: `a ∧ b = nor(¬a, ¬b)` -/
def andC {n : ℕ} (a b : NorCircuit n) : NorCircuit n := nor (notC a) (notC b)

@[simp] theorem eval_input {n : ℕ} (i : Fin n) (σ : Fin n → Bool) :
    eval (input i) σ = σ i := rfl
@[simp] theorem eval_const {n : ℕ} (b : Bool) (σ : Fin n → Bool) :
    eval (const b) σ = b := rfl
@[simp] theorem eval_nor {n : ℕ} (a b : NorCircuit n) (σ : Fin n → Bool) :
    eval (nor a b) σ = !(eval a σ || eval b σ) := rfl

@[simp] theorem eval_notC {n : ℕ} (c : NorCircuit n) (σ : Fin n → Bool) :
    eval (notC c) σ = !eval c σ := by
  unfold notC; simp [eval]

@[simp] theorem eval_andC {n : ℕ} (a b : NorCircuit n) (σ : Fin n → Bool) :
    eval (andC a b) σ = (eval a σ && eval b σ) := by
  unfold andC; simp [eval_notC, eval_nor]

/-- Convert a NAND circuit to a NOR circuit.
  NAND(a,b) = ¬(a ∧ b). We express AND as NOR(¬a, ¬b), so
  NAND(a,b) = ¬(NOR(¬a, ¬b)) = notC(andC a b). -/
def ofNandCircuit {n : ℕ} : Circuit n → NorCircuit n
  | Circuit.input i => input i
  | Circuit.const b => const b
  | Circuit.nand a b => notC (andC (ofNandCircuit a) (ofNandCircuit b))

theorem eval_ofNandCircuit {n : ℕ} (c : Circuit n) (σ : Fin n → Bool) :
    eval (ofNandCircuit c) σ = Circuit.eval c σ := by
  induction c with
  | input i => rfl
  | const b => rfl
  | nand a b iha ihb =>
    simp [ofNandCircuit, eval_notC, eval_andC, iha, ihb]

/-- **NOR universality**: every boolean function on `n` bits can be computed
by a circuit built from projections, constants, and NOR gates. -/
theorem nor_universal {n : ℕ} (f : (Fin n → Bool) → Bool) :
    ∃ c : NorCircuit n, ∀ σ : Fin n → Bool, eval c σ = f σ := by
  obtain ⟨c, hc⟩ := Circuit.nand_universal f
  exact ⟨ofNandCircuit c, fun σ => by rw [eval_ofNandCircuit, hc]⟩

end NorCircuit

/-! ## NOT + AND universality -/

/-- A circuit using NOT and AND gates. -/
inductive NACircuit (n : ℕ) : Type where
  | input : Fin n → NACircuit n
  | const : Bool → NACircuit n
  | notG  : NACircuit n → NACircuit n
  | andG  : NACircuit n → NACircuit n → NACircuit n

namespace NACircuit

def eval {n : ℕ} : NACircuit n → (Fin n → Bool) → Bool
  | input i, σ => σ i
  | const b, _ => b
  | notG a, σ => !eval a σ
  | andG a b, σ => eval a σ && eval b σ

/-- Convert a NAND circuit to a NOT+AND circuit. -/
def ofNandCircuit {n : ℕ} : Circuit n → NACircuit n
  | Circuit.input i => input i
  | Circuit.const b => const b
  | Circuit.nand a b => notG (andG (ofNandCircuit a) (ofNandCircuit b))

@[simp] theorem eval_input {n : ℕ} (i : Fin n) (σ : Fin n → Bool) :
    eval (input i) σ = σ i := rfl
@[simp] theorem eval_const {n : ℕ} (b : Bool) (σ : Fin n → Bool) :
    eval (const b) σ = b := rfl
@[simp] theorem eval_notG {n : ℕ} (a : NACircuit n) (σ : Fin n → Bool) :
    eval (notG a) σ = !eval a σ := rfl
@[simp] theorem eval_andG {n : ℕ} (a b : NACircuit n) (σ : Fin n → Bool) :
    eval (andG a b) σ = (eval a σ && eval b σ) := rfl

theorem eval_ofNandCircuit {n : ℕ} (c : Circuit n) (σ : Fin n → Bool) :
    eval (ofNandCircuit c) σ = Circuit.eval c σ := by
  induction c with
  | input i => rfl
  | const b => rfl
  | nand a b iha ihb => simp [ofNandCircuit, iha, ihb]

/-- **NOT + AND universality**: NOT and AND together generate every boolean function. -/
theorem not_and_universal {n : ℕ} (f : (Fin n → Bool) → Bool) :
    ∃ c : NACircuit n, ∀ σ : Fin n → Bool, eval c σ = f σ := by
  obtain ⟨c, hc⟩ := Circuit.nand_universal f
  exact ⟨ofNandCircuit c, fun σ => by rw [eval_ofNandCircuit, hc]⟩

end NACircuit

/-! ## NOT + OR universality -/

/-- A circuit using NOT and OR gates. -/
inductive NOCircuit (n : ℕ) : Type where
  | input : Fin n → NOCircuit n
  | const : Bool → NOCircuit n
  | notG  : NOCircuit n → NOCircuit n
  | orG   : NOCircuit n → NOCircuit n → NOCircuit n

namespace NOCircuit

def eval {n : ℕ} : NOCircuit n → (Fin n → Bool) → Bool
  | input i, σ => σ i
  | const b, _ => b
  | notG a, σ => !eval a σ
  | orG a b, σ => eval a σ || eval b σ

/-- Convert a NAND circuit to a NOT+OR circuit.
  NAND(a,b) = ¬(a ∧ b) = ¬a ∨ ¬b by De Morgan -/
def ofNandCircuit {n : ℕ} : Circuit n → NOCircuit n
  | Circuit.input i => input i
  | Circuit.const b => const b
  | Circuit.nand a b => orG (notG (ofNandCircuit a)) (notG (ofNandCircuit b))

@[simp] theorem eval_input {n : ℕ} (i : Fin n) (σ : Fin n → Bool) :
    eval (input i) σ = σ i := rfl
@[simp] theorem eval_const {n : ℕ} (b : Bool) (σ : Fin n → Bool) :
    eval (const b) σ = b := rfl
@[simp] theorem eval_notG {n : ℕ} (a : NOCircuit n) (σ : Fin n → Bool) :
    eval (notG a) σ = !eval a σ := rfl
@[simp] theorem eval_orG {n : ℕ} (a b : NOCircuit n) (σ : Fin n → Bool) :
    eval (orG a b) σ = (eval a σ || eval b σ) := rfl

theorem eval_ofNandCircuit {n : ℕ} (c : Circuit n) (σ : Fin n → Bool) :
    eval (ofNandCircuit c) σ = Circuit.eval c σ := by
  induction c with
  | input i => rfl
  | const b => rfl
  | nand a b iha ihb =>
    simp [ofNandCircuit, iha, ihb]

/-- **NOT + OR universality**: NOT and OR together generate every boolean function. -/
theorem not_or_universal {n : ℕ} (f : (Fin n → Bool) → Bool) :
    ∃ c : NOCircuit n, ∀ σ : Fin n → Bool, eval c σ = f σ := by
  obtain ⟨c, hc⟩ := Circuit.nand_universal f
  exact ⟨ofNandCircuit c, fun σ => by rw [eval_ofNandCircuit, hc]⟩

end NOCircuit

/-! ## Invariant-based non-universality: Affine functions -/

/-- A boolean function on `n` bits is affine over GF(2) if it equals
    `c ⊕ (a₁ ∧ x₁) ⊕ (a₂ ∧ x₂) ⊕ ... ⊕ (aₙ ∧ xₙ)` for some constant `c`
    and coefficients `aᵢ`. -/
def IsAffine {n : ℕ} (f : BFun n) : Prop :=
  ∃ (c : Bool) (coeffs : Fin n → Bool),
    ∀ σ : Fin n → Bool,
      f σ = List.foldr (· ^^ ·) c (List.ofFn (fun i => σ i && coeffs i))

/-
XOR on two bits is affine: `x₁ ⊕ x₂ = false ⊕ (x₁ ∧ true) ⊕ (x₂ ∧ true)`.
-/
theorem xor_isAffine : IsAffine (n := 2) (fun σ => σ 0 ^^ σ 1) := by
  -- Let's choose the constant $c = \text{false}$ and the coefficients $a_0 = a_1 = \text{true}$.
  use false, fun _ => true;
  decide +revert

/-
AND on two bits is not affine.
-/
theorem and_not_affine : ¬ IsAffine (n := 2) (fun σ => σ 0 && σ 1) := by
  rintro ⟨ c, coeffs, h ⟩;
  fin_cases c <;> fin_cases coeffs <;> trivial

/-
NAND on two bits is not affine.
-/
theorem nand_not_affine : ¬ IsAffine (n := 2) (fun σ => !(σ 0 && σ 1)) := by
  rintro ⟨ c, coeffs, h ⟩;
  cases c <;> fin_cases coeffs <;> simp +decide at h