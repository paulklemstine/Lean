import Mathlib

/-!
# Algebraic Coding Theory: Core Definitions

This file establishes the foundational definitions for algebraic coding theory
over arbitrary fields, including:
- Hamming weight and distance
- BCH syndrome sequences and consecutive root structures
- Error locator polynomials
- Syndrome annihilation predicates
- Syndrome Hankel matrices

These definitions support the structural BCH bound, unique decoding theorems,
and the connection between coding theory and structured linear algebra.
-/

open Polynomial Finset BigOperators Matrix

noncomputable section

namespace AlgCoding

/-! ## Hamming Weight and Distance -/

/-- Hamming weight: the number of nonzero coordinates. -/
def hammingWeight {α : Type*} [Zero α] [DecidableEq α] {n : ℕ}
    (x : Fin n → α) : ℕ :=
  (Finset.univ.filter fun i => x i ≠ 0).card

/-- The support of a vector as a `Finset`. -/
def support {α : Type*} [Zero α] [DecidableEq α] {n : ℕ}
    (x : Fin n → α) : Finset (Fin n) :=
  Finset.univ.filter fun i => x i ≠ 0

theorem hammingWeight_eq_support_card {α : Type*} [Zero α] [DecidableEq α] {n : ℕ}
    (x : Fin n → α) : hammingWeight x = (support x).card := rfl

/-- Hamming distance between two vectors. -/
def hammingDist {α : Type*} [Zero α] [DecidableEq α] {n : ℕ}
    (x y : Fin n → α) : ℕ :=
  (Finset.univ.filter fun i => x i ≠ y i).card

/-- The zero vector has weight zero. -/
@[simp]
theorem hammingWeight_zero {α : Type*} [Zero α] [DecidableEq α] {n : ℕ} :
    hammingWeight (0 : Fin n → α) = 0 := by
  unfold hammingWeight
  simp

/-- Weight is at most n. -/
theorem hammingWeight_le {α : Type*} [Zero α] [DecidableEq α] {n : ℕ}
    (x : Fin n → α) : hammingWeight x ≤ n := by
  unfold hammingWeight
  calc (Finset.univ.filter fun i => x i ≠ 0).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = n := Finset.card_fin n

/-- Zero weight iff zero vector. -/
theorem hammingWeight_eq_zero_iff {α : Type*} [Zero α] [DecidableEq α] {n : ℕ}
    (x : Fin n → α) : hammingWeight x = 0 ↔ x = 0 := by
  constructor
  · intro h
    unfold hammingWeight at h
    rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff] at h
    ext i; exact not_not.mp (h (Finset.mem_univ i))
  · intro h; subst h; exact hammingWeight_zero

/-- Triangle inequality for Hamming distance. -/
theorem hammingDist_triangle {α : Type*} [Zero α] [DecidableEq α] {n : ℕ}
    (x y z : Fin n → α) :
    hammingDist x z ≤ hammingDist x y + hammingDist y z := by
  unfold hammingDist
  calc (univ.filter fun i => x i ≠ z i).card
      ≤ ((univ.filter fun i => x i ≠ y i) ∪ (univ.filter fun i => y i ≠ z i)).card := by
        apply Finset.card_le_card
        intro i hi
        simp only [Finset.mem_filter, Finset.mem_union, Finset.mem_univ, true_and] at hi ⊢
        by_contra h; push_neg at h
        exact hi (by rw [h.1, h.2])
    _ ≤ (univ.filter fun i => x i ≠ y i).card + (univ.filter fun i => y i ≠ z i).card :=
        Finset.card_union_le _ _

/-- Hamming distance is symmetric. -/
theorem hammingDist_comm {α : Type*} [Zero α] [DecidableEq α] {n : ℕ}
    (x y : Fin n → α) : hammingDist x y = hammingDist y x := by
  simp [hammingDist, ne_comm]

/-! ## Consecutive Root Structures for BCH Codes -/

/-- A polynomial has consecutive roots at powers α^(b+j) for j = 0, …, δ-2. -/
def HasConsecutiveRoots {K : Type*} [CommRing K] (f : K[X])
    (α : K) (b δ : ℕ) : Prop :=
  ∀ j : ℕ, j < δ - 1 → Polynomial.eval (α ^ (b + j)) f = 0

/-- Structure packaging a consecutive root set for BCH codes. -/
structure ConsecutiveRootSet (K : Type*) [Field K] where
  /-- Length of the code -/
  n : ℕ
  /-- Primitive root of unity -/
  α : K
  /-- Starting offset for consecutive roots -/
  offset : ℕ
  /-- Designed distance -/
  designedDistance : ℕ
  /-- α is a primitive n-th root of unity -/
  h_primitive : IsPrimitiveRoot α n
  /-- n is positive -/
  h_pos : 0 < n

/-! ## BCH Syndrome Sequences -/

/-- BCH syndrome: the j-th syndrome of vector e with respect to root α and offset b. -/
def syndrome {K : Type*} [CommRing K] {n : ℕ}
    (α : K) (b : ℕ) (e : Fin n → K) (j : ℕ) : K :=
  ∑ i : Fin n, e i * α ^ ((b + j) * i.val)

/-- Syndrome sequence starting from offset b. -/
def syndromeSeq {K : Type*} [CommRing K] {n : ℕ}
    (α : K) (e : Fin n → K) : ℕ → K :=
  fun k => ∑ i : Fin n, e i * (α ^ i.val) ^ k

/-- BCH parity check: syndromes 0 through δ-2 vanish. -/
def BCHParityCheck {K : Type*} [CommRing K] {n : ℕ}
    (α : K) (b δ : ℕ) (c : Fin n → K) : Prop :=
  ∀ j : ℕ, j < δ - 1 → syndrome α b c j = 0

/-- A vector is a BCH codeword if all its syndromes vanish. -/
def IsBCHCodeword {K : Type*} [CommRing K] {n : ℕ}
    (α : K) (b δ : ℕ) (c : Fin n → K) : Prop :=
  BCHParityCheck α b δ c

/-! ## Error Locator Polynomial -/

/-- The error locator polynomial: Λ(z) = ∏_{i ∈ support(e)} (1 - α^i · z).
    Its roots are the inverses of α^i for each error position i. -/
def errorLocatorPoly {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) : K[X] :=
  ∏ i ∈ support e, (1 - Polynomial.C (α ^ i.val) * Polynomial.X)

/-- The error locator polynomial is monic when the support is nonempty
    (with appropriate sign conventions). We use the reversed convention:
    Λ_rev(z) = ∏_{i ∈ support(e)} (z - α^i). -/
def errorLocatorPolyRev {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) : K[X] :=
  ∏ i ∈ support e, (Polynomial.X - Polynomial.C (α ^ i.val))

/-
The reversed error locator polynomial is nonzero.
-/
theorem errorLocatorPolyRev_ne_zero {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) : errorLocatorPolyRev α e ≠ 0 := by
  exact Finset.prod_ne_zero_iff.mpr fun i _ => Polynomial.X_sub_C_ne_zero _

/-
The degree of errorLocatorPolyRev equals the Hamming weight.
-/
theorem errorLocatorPolyRev_natDegree {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) : (errorLocatorPolyRev α e).natDegree = hammingWeight e := by
  convert Polynomial.natDegree_prod _ _ _;
  · simp +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ];
    rfl;
  · infer_instance;
  · exact fun i _ => Polynomial.X_sub_C_ne_zero _

/-- The degree of errorLocatorPolyRev is at most the Hamming weight. -/
theorem errorLocatorPolyRev_natDegree_le {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) : (errorLocatorPolyRev α e).natDegree ≤ hammingWeight e := by
  exact le_of_eq (errorLocatorPolyRev_natDegree α e)

/-
The reversed error locator polynomial is monic.
-/
theorem errorLocatorPolyRev_monic {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) : (errorLocatorPolyRev α e).Monic := by
  exact Polynomial.monic_prod_of_monic _ _ fun i _ => Polynomial.monic_X_sub_C _

/-
The reversed error locator vanishes at each error location α^j for j ∈ support(e).
-/
theorem errorLocatorPolyRev_eval_zero {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) (j : Fin n) (hj : j ∈ support e) :
    Polynomial.eval (α ^ j.val) (errorLocatorPolyRev α e) = 0 := by
  unfold errorLocatorPolyRev;
  rw [ Polynomial.eval_prod, Finset.prod_eq_zero hj ] ; simp +decide

/-! ## Syndrome Annihilation -/

/-- A polynomial Λ annihilates a syndrome prefix of length N if
    ∑_{l=0}^{deg Λ} Λ_l · s_{k+l} = 0 for k = 0, …, N - deg Λ - 1. -/
def annihilatesPrefix {K : Type*} [CommRing K] (s : ℕ → K) (N : ℕ)
    (Λ : K[X]) : Prop :=
  ∀ k : ℕ, k + Λ.natDegree ≤ N →
    ∑ l ∈ Finset.range (Λ.natDegree + 1), Λ.coeff l * s (k + l) = 0

/-- A polynomial annihilates the full syndrome sequence of a vector e. -/
def annihilatesSyndromeSeq {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) (Λ : K[X]) : Prop :=
  ∀ k : ℕ, ∑ l ∈ Finset.range (Λ.natDegree + 1),
    Λ.coeff l * syndromeSeq α e (k + l) = 0

/-! ## Syndrome Hankel Matrix -/

/-- The syndrome Hankel matrix: H[i,j] = s(i+j). -/
def syndromeHankelMatrix {K : Type*} [CommRing K]
    (s : ℕ → K) (m : ℕ) : Matrix (Fin m) (Fin m) K :=
  Matrix.of fun i j => s (i.val + j.val)

/-! ## Minimum Distance of a Code -/

/-- A code is a subset of Fin n → K. -/
def IsLinearCode {K : Type*} [Field K] {n : ℕ}
    (C : Set (Fin n → K)) : Prop :=
  (0 : Fin n → K) ∈ C ∧
  ∀ c₁ c₂ : Fin n → K, c₁ ∈ C → c₂ ∈ C → (c₁ + c₂) ∈ C ∧ (c₁ - c₂) ∈ C

/-- Minimum distance of a code: smallest weight of a nonzero codeword. -/
def hasMinDist {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (C : Set (Fin n → K)) (d : ℕ) : Prop :=
  (∀ c ∈ C, c ≠ 0 → d ≤ hammingWeight c) ∧
  (∃ c ∈ C, c ≠ 0 ∧ hammingWeight c = d)

/-! ## Polynomial-to-Word Conversion -/

/-- Convert a polynomial to a word of length n by evaluating coefficients. -/
def polyToWord {K : Type*} [Semiring K] (n : ℕ) (f : K[X]) : Fin n → K :=
  fun i => f.coeff i.val

end AlgCoding

end