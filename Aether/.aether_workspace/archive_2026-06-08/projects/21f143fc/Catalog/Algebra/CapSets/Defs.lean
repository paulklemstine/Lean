/-
Copyright (c) 2026. All rights reserved.

# Cap Sets: Core Definitions and Basic Properties

This file establishes the foundational definitions for the theory of cap sets
and progression-free subsets of 𝔽₃ⁿ, building infrastructure for the polynomial
method in finite fields.

## Main Definitions

* `F3Vec n` — The vector space 𝔽₃ⁿ modeled as `Fin n → ZMod 3`
* `CapSet.IsCapSet` — Cap-set predicate using Mathlib's `ThreeAPFree`
* `CapSet.TernaryExponent` — Reduced exponent vectors with entries in {0,1,2}
* `CapSet.reducedMonomialsLE` — Finite set of reduced monomials of bounded total degree
-/

import Mathlib

open Finset BigOperators

/-- The vector space 𝔽₃ⁿ modeled as functions from `Fin n` to `ZMod 3`. -/
abbrev F3Vec (n : ℕ) := Fin n → ZMod 3

namespace CapSet

/-- A finset `A ⊆ 𝔽₃ⁿ` is a **cap set** if it contains no nontrivial 3-term arithmetic
progression. Wraps Mathlib's `ThreeAPFree` on the coercion to `Set`. -/
def IsCapSet {n : ℕ} (A : Finset (F3Vec n)) : Prop :=
  ThreeAPFree (A : Set (F3Vec n))

/-- In `ZMod 3`, every element doubled equals its negation: `a + a = -a`. -/
theorem ZMod3.add_self_eq_neg (a : ZMod 3) : a + a = -a := by
  fin_cases a <;> decide

/-- The 3-AP equation `x + z = y + y` is equivalent to `x + y + z = 0` in `ZMod 3`. -/
theorem threeAP_iff_sum_zero {x y z : ZMod 3} :
    x + z = y + y ↔ x + y + z = 0 := by
  rw [ZMod3.add_self_eq_neg]
  constructor
  · intro h
    have h1 : (x + z) + y = -y + y := congr_arg (· + y) h
    rw [neg_add_cancel] at h1
    have : x + y + z = x + z + y := by abel
    rw [this]; exact h1
  · intro h
    have : x + z = -(y) + (x + y + z) := by abel
    rw [h, add_zero] at this; exact this

/-- Pointwise version for `F3Vec n`: the 3-AP equation is equivalent to sum-zero. -/
theorem threeAP_iff_sum_zero_vec {n : ℕ} {x y z : F3Vec n} :
    x + z = y + y ↔ x + y + z = 0 := by
  constructor
  · intro h
    funext i
    have hi := congr_fun h i
    simp only [Pi.add_apply, Pi.zero_apply] at hi ⊢
    exact threeAP_iff_sum_zero.mp hi
  · intro h
    funext i
    have hi := congr_fun h i
    simp only [Pi.add_apply, Pi.zero_apply] at hi ⊢
    exact threeAP_iff_sum_zero.mpr hi

/-- A ternary exponent vector: each coordinate takes values in `{0, 1, 2}`. -/
abbrev TernaryExponent (n : ℕ) := Fin n → Fin 3

/-- The total degree of a ternary exponent vector. -/
def TernaryExponent.totalDeg {n : ℕ} (e : TernaryExponent n) : ℕ :=
  ∑ i, (e i : ℕ)

/-- The set of ternary exponent vectors with total degree at most `d`. -/
def reducedMonomialsLE (n d : ℕ) : Finset (TernaryExponent n) :=
  Finset.univ.filter (fun e => TernaryExponent.totalDeg e ≤ d)

/-- The number of all ternary exponent vectors in `n` variables is `3^n`. -/
theorem card_ternaryExponent (n : ℕ) :
    Fintype.card (TernaryExponent n) = 3 ^ n := by
  simp [TernaryExponent, Fintype.card_fin]

/-- The number of reduced monomials is at most `3^n`. -/
theorem reducedMonomialsLE_card_le (n d : ℕ) :
    (reducedMonomialsLE n d).card ≤ 3 ^ n := by
  calc (reducedMonomialsLE n d).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = Fintype.card (TernaryExponent n) := by rfl
    _ = 3 ^ n := card_ternaryExponent n

/-- The empty set is a cap set. -/
theorem isCapSet_empty {n : ℕ} : IsCapSet (∅ : Finset (F3Vec n)) := by
  intro x hx; simp at hx

/-- Any singleton is a cap set. -/
theorem isCapSet_singleton {n : ℕ} (v : F3Vec n) :
    IsCapSet ({v} : Finset (F3Vec n)) := by
  intro x hx y hy _ _ _
  simp at hx hy
  rw [hx, hy]

/-- Any subset of a cap set is a cap set (monotonicity). -/
theorem IsCapSet.mono {n : ℕ} {A B : Finset (F3Vec n)}
    (hA : IsCapSet A) (hBA : B ⊆ A) : IsCapSet B :=
  ThreeAPFree.mono (Finset.coe_subset.mpr hBA) hA

end CapSet