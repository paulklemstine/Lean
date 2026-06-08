/-
Copyright (c) 2025. All rights reserved.
Shadow Profile Convolution and Circuit Complexity Bounds

This file defines the shadow profile of finite subsets of ℕ^n and the
shadow complexity invariant, establishing the foundational definitions
for shadow geometry in algebraic complexity theory.
-/
import Mathlib

namespace ShadowComplexity

open Finset

/-- Total degree of a multi-index vector: |v| = Σᵢ vᵢ. -/
def totalDeg {n : ℕ} (v : Fin n → ℕ) : ℕ := ∑ i, v i

/-- The standard basis vector eᵢ in ℕ^n: 1 at position i, 0 elsewhere. -/
def stdBasis {n : ℕ} (i : Fin n) : Fin n → ℕ :=
  fun j => if j = i then 1 else 0

/-- The lower shadow of a finset S ⊆ ℕ^n: all vectors obtainable by
    reducing exactly one coordinate of some element of S by 1.
    ∂(S) = {v - eᵢ | v ∈ S, vᵢ > 0}. -/
def lowerShadow {n : ℕ} (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.biUnion fun v =>
    (Finset.univ.filter fun i : Fin n => v i > 0).biUnion fun i =>
      {v - stdBasis i}

/-- Iterated lower shadow: ∂ᵏ(S) = ∂(∂ᵏ⁻¹(S)). -/
def shadow_iter {n : ℕ} (S : Finset (Fin n → ℕ)) : ℕ → Finset (Fin n → ℕ)
  | 0 => S
  | k + 1 => lowerShadow (shadow_iter S k)

/-- Maximum total degree of any element of S. -/
noncomputable def maxDegree {n : ℕ} (S : Finset (Fin n → ℕ)) : ℕ :=
  S.sup fun v => totalDeg v

/-- The shadow profile at level k: aₖˢ = |∂ᵏ(S)|. -/
noncomputable def shadowProfile {n : ℕ} (S : Finset (Fin n → ℕ)) (k : ℕ) : ℕ :=
  (shadow_iter S k).card

/-- Shadow complexity: total mass of the shadow profile.
    Σ(S) = Σₖ₌₀^{maxDeg} |∂ᵏ(S)|.
    Measures how "spread out" a support set is through its iterated shadows. -/
noncomputable def shadowComplexity {n : ℕ} (S : Finset (Fin n → ℕ)) : ℕ :=
  (Finset.range (maxDegree S + 1)).sum fun k => (shadow_iter S k).card

/-- Minkowski sum of two finsets of multi-indices:
    A + B = {a + b | a ∈ A, b ∈ B}, with pointwise addition. -/
def minkowskiSum {n : ℕ} (A B : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  A.biUnion fun a => B.image fun b => a + b

/-- Membership characterization for Minkowski sum. -/
theorem mem_minkowskiSum {n : ℕ} {A B : Finset (Fin n → ℕ)} {c : Fin n → ℕ} :
    c ∈ minkowskiSum A B ↔ ∃ a ∈ A, ∃ b ∈ B, c = a + b := by
  simp [minkowskiSum, mem_biUnion, mem_image]
  constructor
  · rintro ⟨a, ha, b, hb, rfl⟩; exact ⟨a, ha, b, hb, rfl⟩
  · rintro ⟨a, ha, b, hb, rfl⟩; exact ⟨a, ha, b, hb, rfl⟩

/-- Membership characterization for lower shadow. -/
theorem mem_lowerShadow {n : ℕ} {S : Finset (Fin n → ℕ)} {v' : Fin n → ℕ} :
    v' ∈ lowerShadow S ↔ ∃ v ∈ S, ∃ i : Fin n, v i > 0 ∧ v' = v - stdBasis i := by
  simp only [lowerShadow, mem_biUnion, mem_filter, mem_univ, true_and, mem_singleton]

/-- The shadow of a subset is a subset of the shadow. -/
theorem lowerShadow_mono {n : ℕ} {S T : Finset (Fin n → ℕ)} (h : S ⊆ T) :
    lowerShadow S ⊆ lowerShadow T := by
  intro v' hv'
  rw [mem_lowerShadow] at hv' ⊢
  obtain ⟨v, hv, i, hi, rfl⟩ := hv'
  exact ⟨v, h hv, i, hi, rfl⟩

/-- Iterated shadow is monotone. -/
theorem shadow_iter_mono {n : ℕ} {S T : Finset (Fin n → ℕ)} (h : S ⊆ T) (k : ℕ) :
    shadow_iter S k ⊆ shadow_iter T k := by
  induction k with
  | zero => exact h
  | succ k ih => exact lowerShadow_mono ih

/-- Shadow of a union is subset of union of shadows. -/
theorem lowerShadow_union_subset {n : ℕ} (A B : Finset (Fin n → ℕ)) :
    lowerShadow (A ∪ B) ⊆ lowerShadow A ∪ lowerShadow B := by
  intro v' hv'
  rw [mem_lowerShadow] at hv'
  obtain ⟨v, hv, i, hi, rfl⟩ := hv'
  simp only [mem_union] at hv ⊢
  cases hv with
  | inl h => left; rw [mem_lowerShadow]; exact ⟨v, h, i, hi, rfl⟩
  | inr h => right; rw [mem_lowerShadow]; exact ⟨v, h, i, hi, rfl⟩

/-- Union of shadows is subset of shadow of union. -/
theorem union_lowerShadow_subset {n : ℕ} (A B : Finset (Fin n → ℕ)) :
    lowerShadow A ∪ lowerShadow B ⊆ lowerShadow (A ∪ B) := by
  intro v' hv'
  simp only [mem_union] at hv'
  rw [mem_lowerShadow]
  cases hv' with
  | inl h =>
    rw [mem_lowerShadow] at h
    obtain ⟨v, hv, i, hi, rfl⟩ := h
    exact ⟨v, mem_union_left B hv, i, hi, rfl⟩
  | inr h =>
    rw [mem_lowerShadow] at h
    obtain ⟨v, hv, i, hi, rfl⟩ := h
    exact ⟨v, mem_union_right A hv, i, hi, rfl⟩

/-- Shadow distributes over union. -/
theorem lowerShadow_union {n : ℕ} (A B : Finset (Fin n → ℕ)) :
    lowerShadow (A ∪ B) = lowerShadow A ∪ lowerShadow B := by
  ext v'
  constructor
  · exact fun h => lowerShadow_union_subset A B h
  · exact fun h => union_lowerShadow_subset A B h

/-- Iterated shadow distributes over union. -/
theorem shadow_iter_union {n : ℕ} (A B : Finset (Fin n → ℕ)) (k : ℕ) :
    shadow_iter (A ∪ B) k = shadow_iter A k ∪ shadow_iter B k := by
  induction k with
  | zero => rfl
  | succ k ih =>
    simp only [shadow_iter]
    rw [ih, lowerShadow_union]

end ShadowComplexity