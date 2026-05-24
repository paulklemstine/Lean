/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Ehrhart Theory of Lorentzian Permutohedra — Core Definitions

This file introduces the foundational infrastructure connecting M-convex sets,
generalized permutohedra, Lorentzian polynomial support geometry, and
Ehrhart-theoretic positivity phenomena.

## Main Definitions

* `finsetMinkowskiSum` — Minkowski sum of two finsets of lattice points
* `finsetDilate` — t-fold Minkowski sum (lattice dilation)
* `IntegerDecompositionProperty` — IDP: every point in tP decomposes into t points of P
* `IsMConvex` — M-convex exchange property for finsets
* `LorentzianSupportSet` — Discrete proxy for Lorentzian polynomial support
* `IsLogConcave` — Log-concavity for sequences
* `IsUnimodal` — Unimodality for sequences
* `sliceCount` — Counting points by coordinate value
* `ehrhartCount` — Lattice point counting function under dilation

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Postnikov, "Permutohedra, associahedra, and beyond", IMRN, 2009
* Stanley, "Decompositions of rational convex polytopes", AIHP, 1980
-/

open Finset BigOperators Function

noncomputable section

namespace EhrhartIDP

/-! ## Lattice Points and Minkowski Sums -/

/-- Pointwise addition of lattice points. -/
def latticeAdd {n : ℕ} (a b : Fin n → ℤ) : Fin n → ℤ :=
  fun i => a i + b i

@[simp]
theorem latticeAdd_apply {n : ℕ} (a b : Fin n → ℤ) (i : Fin n) :
    latticeAdd a b i = a i + b i := rfl

/-- Minkowski sum of two finsets of lattice points:
    A + B = {a + b | a ∈ A, b ∈ B}. -/
def finsetMinkowskiSum {n : ℕ} (A B : Finset (Fin n → ℤ)) :
    Finset (Fin n → ℤ) :=
  (A ×ˢ B).image (fun p => latticeAdd p.1 p.2)

theorem mem_finsetMinkowskiSum {n : ℕ} {A B : Finset (Fin n → ℤ)}
    {x : Fin n → ℤ} :
    x ∈ finsetMinkowskiSum A B ↔
      ∃ a ∈ A, ∃ b ∈ B, x = latticeAdd a b := by
  simp only [finsetMinkowskiSum, Finset.mem_image, Finset.mem_product]
  constructor
  · rintro ⟨⟨a, b⟩, ⟨ha, hb⟩, rfl⟩
    exact ⟨a, ha, b, hb, rfl⟩
  · rintro ⟨a, ha, b, hb, rfl⟩
    exact ⟨⟨a, b⟩, ⟨ha, hb⟩, rfl⟩

/-- t-fold Minkowski sum: the set of all sums of t points from P.
    Defined recursively: 0P = {0}, (t+1)P = P + tP. -/
def finsetDilate {n : ℕ} : ℕ → Finset (Fin n → ℤ) → Finset (Fin n → ℤ)
  | 0, _ => {fun _ => 0}
  | t + 1, P => finsetMinkowskiSum P (finsetDilate t P)

@[simp]
theorem finsetDilate_zero {n : ℕ} (P : Finset (Fin n → ℤ)) :
    finsetDilate 0 P = {fun _ => 0} := rfl

@[simp]
theorem finsetDilate_succ {n : ℕ} (t : ℕ) (P : Finset (Fin n → ℤ)) :
    finsetDilate (t + 1) P = finsetMinkowskiSum P (finsetDilate t P) := rfl

theorem mem_finsetDilate_succ {n : ℕ} {t : ℕ} {P : Finset (Fin n → ℤ)}
    {x : Fin n → ℤ} :
    x ∈ finsetDilate (t + 1) P ↔
      ∃ y ∈ P, ∃ z ∈ finsetDilate t P, x = latticeAdd y z := by
  simp [finsetDilate_succ, mem_finsetMinkowskiSum]

/-! ## Integer Decomposition Property -/

/-- The **Integer Decomposition Property** (IDP) for a finset of lattice points:
    every point in the t-fold Minkowski sum decomposes as a sum of t points from P.

    This is the key property connecting M-convex geometry to Ehrhart positivity:
    if P has IDP, then the h*-vector of P has nonneg coefficients (Stanley, 1980). -/
def IntegerDecompositionProperty {n : ℕ} (P : Finset (Fin n → ℤ)) : Prop :=
  ∀ t : ℕ, 1 ≤ t →
    ∀ x ∈ finsetDilate t P,
      ∃ xs : Fin t → (Fin n → ℤ),
        (∀ i, xs i ∈ P) ∧ x = ∑ i, xs i

/-! ## M-Convex Sets -/

/-- Edge direction: the vector eᵢ - eⱼ in ℤⁿ. -/
def edgeDir {n : ℕ} (i j : Fin n) : Fin n → ℤ :=
  fun k => if k = i then 1 else if k = j then -1 else 0

/-- The **symmetric exchange property** for M-convex sets (Murota).
    For any α, β ∈ S with αᵢ > βᵢ, there exists j with αⱼ < βⱼ
    such that α - eᵢ + eⱼ ∈ S. -/
def IsMConvex {n : ℕ} (S : Finset (Fin n → ℤ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : Fin n,
    α i > β i →
    ∃ j : Fin n, α j < β j ∧
      (fun k => α k - edgeDir i j k) ∈ S

/-- M-convex sets have constant coordinate sum. -/
def HasConstantSum {n : ℕ} (S : Finset (Fin n → ℤ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∑ k, α k = ∑ k, β k

/-! ## Lorentzian Support Sets -/

/-- A **Lorentzian support set** is a discrete proxy for the support of a
    Lorentzian polynomial. It captures:
    1. Nonemptiness and finiteness (automatic from Finset)
    2. Constant total degree (all points have the same coordinate sum)
    3. M-convex exchange property (the key structural axiom)

    This is the combinatorial essence of Lorentzian polynomials without
    needing to formalize the full analytic theory. By Brändén–Huh (2020),
    the support of a Lorentzian polynomial is M-convex, so this definition
    captures the relevant combinatorial structure. -/
structure LorentzianSupportSet (n : ℕ) where
  support : Finset (Fin n → ℕ)
  nonempty : support.Nonempty
  /-- All support points have the same total degree -/
  constDeg : ∀ α ∈ support, ∀ β ∈ support, ∑ k, α k = ∑ k, β k
  /-- The symmetric exchange property in ℕ coordinates -/
  exchange : ∀ α ∈ support, ∀ β ∈ support, ∀ i : Fin n,
    α i > β i →
    ∃ j : Fin n, α j < β j ∧
      (fun k => α k - (if k = i then 1 else 0) + (if k = j then 1 else 0)) ∈ support

/-! ## Sequence Properties -/

/-- A finite sequence is **log-concave** if aₖ² ≥ aₖ₋₁ · aₖ₊₁ for all interior k. -/
def IsLogConcave (a : ℕ → ℕ) (len : ℕ) : Prop :=
  ∀ k, 1 ≤ k → k + 1 < len → a k * a k ≥ a (k - 1) * a (k + 1)

/-- A list is **unimodal** if it increases then decreases. -/
def IsUnimodal (a : List ℕ) : Prop :=
  ∃ m : ℕ, m < a.length ∧
    (∀ i j, i ≤ j → j ≤ m → (hj : j < a.length) → (hi : i < a.length) →
      a.get ⟨i, hi⟩ ≤ a.get ⟨j, hj⟩) ∧
    (∀ i j, m ≤ i → i ≤ j → (hj : j < a.length) → (hi : i < a.length) →
      a.get ⟨j, hj⟩ ≤ a.get ⟨i, hi⟩)

/-! ## Slice Counting -/

/-- Count the number of points in a finset with coordinate i equal to k. -/
def sliceCount {n : ℕ} (hn : 0 < n) (S : Finset (Fin n → ℤ)) (k : ℤ) : ℕ :=
  (S.filter (fun v => v ⟨0, hn⟩ = k)).card

/-! ## Ehrhart Counting -/

/-- The **Ehrhart counting function**: number of lattice points in the t-fold
    Minkowski sum of P. For lattice polytopes, this is a polynomial in t. -/
def ehrhartCount {n : ℕ} (P : Finset (Fin n → ℤ)) (t : ℕ) : ℕ :=
  (finsetDilate t P).card

/-- Ehrhart count at t=0 is always 1 (the origin). -/
theorem ehrhartCount_zero {n : ℕ} (P : Finset (Fin n → ℤ)) :
    ehrhartCount P 0 = 1 := by
  simp [ehrhartCount, finsetDilate]

/-! ## Generalized Permutohedron Lattice Structure -/

/-- A finset of lattice points forms a **generalized permutohedron** if
    every pair of points is connected by exchange-direction steps. -/
structure IsGenPermutohedronLattice {n : ℕ} (S : Finset (Fin n → ℤ)) : Prop where
  constSum : HasConstantSum S
  nonempty : S.Nonempty
  edgeDirs : ∀ α ∈ S, ∀ β ∈ S,
    ∃ (m : ℕ) (steps : Fin m → Fin n × Fin n),
      ∀ k, β k = α k + ∑ t, edgeDir (steps t).1 (steps t).2 k

end EhrhartIDP