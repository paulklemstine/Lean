import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset

/-!
# Two-set inclusion-exclusion for the combinatorial Euler characteristic

This file defines the combinatorial Euler characteristic of a finite set of faces
(each face being a `Finset V`) and proves the two-set inclusion-exclusion formula

`eulerChar (A ∪ B) = eulerChar A + eulerChar B - eulerChar (A ∩ B)`.

The proof relies only on `Finset.sum_union_inter`; it does not use any general
inclusion-exclusion theorem.
-/

open Finset

variable {V : Type*}

/-- The combinatorial Euler characteristic of a finite face set `X`,
defined as `∑ σ ∈ X, (-1) ^ σ.card`. -/
def eulerChar (X : Finset (Finset V)) : ℤ :=
  X.sum (fun σ => (-1 : ℤ) ^ σ.card)

@[simp] lemma eulerChar_empty : eulerChar (∅ : Finset (Finset V)) = 0 := by
  simp [eulerChar]

@[simp] lemma eulerChar_singleton (σ : Finset V) :
    eulerChar ({σ} : Finset (Finset V)) = (-1 : ℤ) ^ σ.card := by
  simp [eulerChar]

/-- Two-set inclusion-exclusion for the combinatorial Euler characteristic. -/
theorem eulerChar_union_eq_add_sub_inter [DecidableEq V] (A B : Finset (Finset V)) :
    eulerChar (A ∪ B) = eulerChar A + eulerChar B - eulerChar (A ∩ B) := by
  have h := Finset.sum_union_inter (s₁ := A) (s₂ := B)
      (f := fun σ => (-1 : ℤ) ^ σ.card)
  unfold eulerChar
  omega