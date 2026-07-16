import Mathlib

/-!
# Schur-product quantum Latin squares and the order-six bound

A quantum Latin square is an array of vectors whose rows and columns are orthonormal
bases.  This chapter isolates two structural mechanisms used by order-six constructions:
pointwise products of Hadamard columns and the combinatorial bound forced by symmetry.

The cardinality of an array means the number of distinct labels in its range.  A label may
in particular be a ray, so vectors differing by a nonzero global phase receive one label.
-/

open scoped BigOperators ComplexConjugate
open Finset

namespace QuantumLatinOrderSix

/-- The coordinate inner product on a finite complex vector space. -/
noncomputable def innerSum {ι : Type*} [Fintype ι] (v w : ι → ℂ) : ℂ :=
  ∑ x, conj (v x) * w x

/-- An array is a quantum Latin square when each row and column is orthonormal. -/
def IsQuantumLatin {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A : ι → ι → (ι → ℂ)) : Prop :=
  (∀ i j k, innerSum (A i j) (A i k) = if j = k then 1 else 0) ∧
  (∀ i j k, innerSum (A j i) (A k i) = if j = k then 1 else 0)

/-- Pointwise products of columns, with a common normalizing scalar. -/
def schurArray {ι : Type*} (κ : ℂ) (u : ι → ι → ℂ) : ι → ι → (ι → ℂ) :=
  fun i j x => κ * (u i x * u j x)

/-
Hadamard orthogonality plus unimodular coordinates makes the normalized Schur array
quantum Latin.  The scalar equation is exactly the normalization condition.
-/
theorem schurArray_isQuantumLatin {ι : Type*} [Fintype ι] [DecidableEq ι]
    (κ : ℂ) (u : ι → ι → ℂ)
    (hphase : ∀ i x, conj (u i x) * u i x = 1)
    (horth : ∀ j k, innerSum (u j) (u k) = if j = k then (Fintype.card ι : ℂ) else 0)
    (hnorm : conj κ * κ * (Fintype.card ι : ℂ) = 1) :
    IsQuantumLatin (schurArray κ u) := by
  constructor <;> intro i j k;
  · unfold innerSum schurArray;
    convert congr_arg ( fun x : ℂ => ( starRingEnd ℂ ) κ * κ * x ) ( horth j k ) using 1;
    · unfold innerSum; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;
      grind;
    · grind;
  · convert congr_arg ( fun x : ℂ => ( starRingEnd ℂ ) κ * κ * x ) ( horth j k ) using 1 <;> simp +decide [ mul_assoc, mul_comm, mul_left_comm, innerSum, schurArray ];
    · simp +decide only [Finset.mul_sum _ _ _];
      grind;
    · grind

/-- The index set of unordered pairs, represented by their upper-triangular elements. -/
def upperPairs (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.univ.filter fun p => p.1 ≤ p.2

/-
A symmetric array has the same range as its restriction to unordered index pairs.
-/
theorem range_symmetric_eq_upper {n : ℕ} {R : Type*} [DecidableEq R]
    (A : Fin n → Fin n → R) (hsym : ∀ i j, A i j = A j i) :
    Finset.univ.image (fun p : Fin n × Fin n => A p.1 p.2) =
      (upperPairs n).image (fun p => A p.1 p.2) := by
  ext; simp [upperPairs];
  exact ⟨ fun ⟨ i, j, h ⟩ => if hij : i ≤ j then ⟨ i, j, hij, h ⟩ else ⟨ j, i, le_of_not_ge hij, hsym i j ▸ h ⟩, fun ⟨ i, j, hij, h ⟩ => ⟨ i, j, h ⟩ ⟩

/-
Symmetry bounds the number of distinct labels by the number of unordered pairs.
-/
theorem symmetric_range_card_le_upper {n : ℕ} {R : Type*} [DecidableEq R]
    (A : Fin n → Fin n → R) (hsym : ∀ i j, A i j = A j i) :
    (Finset.univ.image (fun p : Fin n × Fin n => A p.1 p.2)).card ≤ (upperPairs n).card := by
  exact range_symmetric_eq_upper A hsym ▸ Finset.card_image_le

/-- There are exactly twenty-one unordered pairs of six indices. -/
theorem upperPairs_six_card : (upperPairs 6).card = 21 := by
  native_decide

/-- **Order-six symmetric Schur bound.** Any symmetric six-by-six ray labeling has at
most twenty-one distinct rays. -/
theorem orderSix_symmetric_cardinality_bound {R : Type*} [DecidableEq R]
    (A : Fin 6 → Fin 6 → R) (hsym : ∀ i j, A i j = A j i) :
    (Finset.univ.image (fun p : Fin 6 × Fin 6 => A p.1 p.2)).card ≤ 21 := by
  rw [← upperPairs_six_card]
  exact symmetric_range_card_le_upper A hsym

/-- Pointwise multiplication makes the Schur array symmetric in its two indices. -/
theorem schurArray_symmetric {ι : Type*} (κ : ℂ) (u : ι → ι → ℂ) (i j : ι) :
    schurArray κ u i j = schurArray κ u j i := by
  funext x
  dsimp [schurArray]
  rw [mul_comm (u i x)]

-- !-- Lab Notes -- !--
/-
Hypothesis: normalized pointwise products of unimodular orthogonal columns always form a
quantum Latin square, and commutativity imposes an order-six ceiling of twenty-one rays.

Experiment: the upper triangle of a six-by-six array contains 6+5+4+3+2+1 = 21 cells.
The proof maps every lower-triangular cell to its transpose and separately checks that
Hadamard phase multiplication preserves all row and column inner products.

Analysis: the analytic and combinatorial ingredients are independent. Orthogonality gives
the quantum Latin property; commutativity alone gives the cardinality bound, even after an
arbitrary ray-label map.

Critique: the bound does not assert that twenty-one labels are attained, nor does it verify
a particular numerical Hadamard matrix. It identifies the structural obstruction that any
construction exceeding twenty-one must evade.

Synthesis: Schur constructions are certified abstractly, and their sharp universal
order-six range bound is established in a form usable for phase-equivalence labels.
-/
-- !-- Lab Notes -- !--

end QuantumLatinOrderSix