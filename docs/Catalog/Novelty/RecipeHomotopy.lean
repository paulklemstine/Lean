import Mathlib

/-!
# Recipe substitution spaces

This file gives a finite, combinatorial model of the proposed recipe spaces.  A recipe has
an observable `Core` (its flavor profile) and an unobserved `Optional` component (choices
such as nuts).  The fiber over a fixed flavor is proved equivalent to `Optional`.

For `n` independent binary substitutions, recipes form the vertices of an `n`-cube.
A method is a list of substitutions.  Its endpoint is completely classified by a Boolean
parity vector (`signature`).  This also proves cancellation and commuting-square laws,
the elementary path and 2-cell structure of the cube.
-/

namespace RecipeHomotopy

structure Recipe (Core Optional : Type*) where
  core : Core
  optional : Optional

variable {Core Optional : Type*}

def flavor (r : Recipe Core Optional) : Core := r.core

def FlavorFiber (d : Core) := {r : Recipe Core Optional // flavor r = d}

/-- Recipes with fixed flavor `d` are exactly their optional ingredient data. -/
def fiberEquiv (d : Core) : FlavorFiber (Optional := Optional) d ≃ Optional where
  toFun r := r.1.optional
  invFun o := ⟨⟨d, o⟩, rfl⟩
  left_inv := by
    intro r
    apply Subtype.ext
    cases r with
    | mk r h =>
      cases r with
      | mk c o =>
        simp only [flavor] at h
        cases h
        rfl
  right_inv := by intro o; rfl

/-- A cookie model with one binary optional choice has exactly two recipes in each fiber. -/
theorem cookie_fiber_card (d : Core) :
    @Fintype.card (FlavorFiber (Optional := Bool) d)
      (Fintype.ofEquiv Bool (fiberEquiv (Optional := Bool) d).symm) = 2 := by
  rw [Fintype.ofEquiv_card]
  rfl

/-- With `n` independent binary substitutions, a flavor fiber has `2^n` vertices. -/
theorem binary_fiber_card (d : Core) (n : ℕ) :
    @Fintype.card (FlavorFiber (Optional := Fin n → Bool) d)
      (Fintype.ofEquiv (Fin n → Bool)
        (fiberEquiv (Optional := Fin n → Bool) d).symm) = 2 ^ n := by
  rw [Fintype.ofEquiv_card]
  simp

abbrev CubeRecipe (n : ℕ) := Fin n → Bool
abbrev Method (n : ℕ) := List (Fin n)

/-- Toggle one binary ingredient choice. -/
def toggle {n : ℕ} (i : Fin n) (r : CubeRecipe n) : CubeRecipe n :=
  fun j => if j = i then !r j else r j

/-- Execute a substitution method from left to right. -/
def follow {n : ℕ} : CubeRecipe n → Method n → CubeRecipe n
  | r, [] => r
  | r, i :: p => follow (toggle i r) p

/-- The parity vector of a method: which choices it toggles an odd number of times. -/
def signature {n : ℕ} : Method n → CubeRecipe n
  | [] => fun _ => false
  | i :: p => toggle i (signature p)

lemma toggle_apply {n : ℕ} (i j : Fin n) (r : CubeRecipe n) :
    toggle i r j = (r j ^^ (j == i)) := by
  by_cases h : j = i
  · subst j
    simp [toggle]
  · simp only [toggle, if_neg h]
    have heq : (j == i) = false := by simp [h]
    rw [heq, Bool.xor_false]

lemma toggle_comm {n : ℕ} (i j : Fin n) (r : CubeRecipe n) :
    toggle i (toggle j r) = toggle j (toggle i r) := by
  funext k
  simp only [toggle_apply]
  rw [Bool.xor_assoc, Bool.xor_assoc]
  congr 1
  exact Bool.xor_comm _ _

lemma toggle_involutive {n : ℕ} (i : Fin n) (r : CubeRecipe n) :
    toggle i (toggle i r) = r := by
  funext j
  simp only [toggle_apply]
  rw [Bool.xor_assoc, Bool.xor_self, Bool.xor_false]

lemma follow_append {n : ℕ} (r : CubeRecipe n) (p q : Method n) :
    follow r (p ++ q) = follow (follow r p) q := by
  induction p generalizing r with
  | nil => rfl
  | cons i p ih =>
    simp only [List.cons_append, follow]
    exact ih (toggle i r)

/-- Endpoint formula: a method acts by XOR with its parity signature. -/
theorem follow_eq_xor_signature {n : ℕ} (r : CubeRecipe n) (p : Method n) (j : Fin n) :
    follow r p j = (r j ^^ signature p j) := by
  induction p generalizing r with
  | nil => simp [follow, signature]
  | cons i p ih =>
    rw [follow]
    rw [ih]
    simp only [signature, toggle_apply]
    simp [Bool.xor_comm]

/-- Complete classification: two methods have the same endpoint from any fixed recipe
exactly when they toggle every ingredient with the same parity. -/
theorem methods_same_endpoint_iff_signature {n : ℕ} (r : CubeRecipe n)
    (p q : Method n) :
    follow r p = follow r q ↔ signature p = signature q := by
  constructor
  · intro h
    funext j
    have hj := congrFun h j
    rw [follow_eq_xor_signature, follow_eq_xor_signature] at hj
    exact (Bool.xor_right_inj).mp hj
  · intro h
    funext j
    rw [follow_eq_xor_signature, follow_eq_xor_signature, h]

/-- Independent substitutions form a commuting square: two syntactically distinct
methods have the same endpoint. -/
theorem substitution_square {n : ℕ} (r : CubeRecipe n) (i j : Fin n) :
    follow r [i, j] = follow r [j, i] := by
  simp only [follow]
  exact (toggle_comm i j r).symm

/-- Repeating a substitution immediately cancels. -/
theorem substitution_backtrack {n : ℕ} (r : CubeRecipe n) (i : Fin n) :
    follow r [i, i] = r := by
  simp only [follow]
  exact toggle_involutive i r

/-- A method is a loop precisely when every substitution occurs with even parity. -/
theorem loop_iff_zero_signature {n : ℕ} (r : CubeRecipe n) (p : Method n) :
    follow r p = r ↔ signature p = fun _ => false := by
  simpa [follow, signature] using methods_same_endpoint_iff_signature r p []

/-- Every method followed by its reversal is a loop. -/
theorem method_reverse_is_loop {n : ℕ} (r : CubeRecipe n) (p : Method n) :
    follow r (p ++ p.reverse) = r := by
  induction p generalizing r with
  | nil => rfl
  | cons i p ih =>
    rw [List.reverse_cons, List.cons_append, follow, ← List.append_assoc,
      follow_append, ih]
    simpa [follow] using toggle_involutive i r

end RecipeHomotopy