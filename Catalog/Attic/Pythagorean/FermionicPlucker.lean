/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.CauchyBinet

/-!
# Fermionic Plücker Coordinates and Quantum Matroid Geometry

This file establishes the mathematical foundation connecting representable matroids,
Grassmannian geometry, and fermionic quantum mechanics through Plücker coordinates
and Cauchy–Binet determinant identities.

## Mathematical Overview

For a real matrix `A ∈ ℝ^{r×n}` and weights `w : [n] → ℝ`, we define:

- **Plücker amplitudes**: `ψ_A(S) = det(A_S)` for each `r`-subset `S ⊆ [n]`
- **Weighted Plücker mass**: `∑_{|S|=r} (det A_S)² · ∏_{i∈S} w_i`
- **Slater basis distribution**: the normalized squared-amplitude law

The central identity (Cauchy–Binet) is:
  `det(A · D_w · Aᵀ) = ∑_{|S|=r} (det A_S)² · ∏_{i∈S} w_i`

This identifies the weighted basis-generating polynomial of a representable matroid
with a Gram determinant — the algebraic signature of free-fermion solvability.

## Main Results

1. `pluckerMass_nonneg`: Positivity of the Plücker mass for nonneg weights
2. `pluckerMass_pos`: Strict positivity under a nonzero-minor condition
3. `det_gram_eq_pluckerMass`: Cauchy–Binet weighted Plücker expansion
4. `sum_sq_minor_eq_det_gram`: Born rule for Slater amplitudes
5. `slater_prob_sum_eq_one`: Probability normalization
6. `gram_unit_weights`: Unit-weight Gram simplification
7. `det_minor_column_scaled`: Minor determinant under column scaling

## Cross-Domain Bridges

- **Matroid theory ↔ quantum physics**: Bases = occupation-number sectors;
  Plücker coordinates = Slater amplitudes; basis probabilities = Born probabilities
- **Combinatorics ↔ algebraic geometry**: Represented matroid encoded by
  Grassmannian point; basis support = Plücker support
- **Linear algebra ↔ probabilistic algorithms**: Gram determinants → DPP samplers

## Application Keywords

representable matroids, Grassmannian, Plücker coordinates, Cauchy–Binet,
exterior algebra, Slater determinant, fermionic Gaussian state, matchgate circuit,
determinantal point process, basis-generating polynomial, occupation-number measurement,
Gram determinant, quantum state preparation, combinatorial sampling, many-body physics

## References

* Adiprasito–Huh–Katz, "Hodge theory for combinatorial geometries", 2018
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators Matrix

noncomputable section

namespace FermionicPlucker

/-! ## Section 1: Definitions -/

/-- Extract the `r × r` minor of `A : Matrix (Fin r) (Fin n) ℝ` by selecting
    columns indexed by a finset `S ⊆ Fin n` of cardinality `r`. -/
def minorMatrix {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (S : Finset (Fin n)) (hS : S.card = r) : Matrix (Fin r) (Fin r) ℝ :=
  A.submatrix id (S.orderEmbOfFin hS)

/-- The Plücker amplitude: `det(A_S)` — the coordinate of a decomposable
    wedge vector in the occupation-number basis. -/
def pluckerAmplitude {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (S : Finset (Fin n)) (hS : S.card = r) : ℝ :=
  (minorMatrix A S hS).det

/-- The collection of all `r`-element subsets of `Fin n`. -/
def rSubsets (r n : ℕ) : Finset (Finset (Fin n)) :=
  Finset.powersetCard r (Finset.univ : Finset (Fin n))

/-- Every element of `rSubsets r n` has cardinality `r`. -/
lemma mem_rSubsets_card {r n : ℕ} {S : Finset (Fin n)} (hS : S ∈ rSubsets r n) :
    S.card = r := by
  simp only [rSubsets, Finset.mem_powersetCard] at hS
  exact hS.2

/-- Helper: the summand for the Plücker mass. -/
def pluckerSummand {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) (w : Fin n → ℝ)
    (S : Finset (Fin n)) : ℝ :=
  if h : S.card = r then
    (minorMatrix A S h).det ^ 2 * ∏ i ∈ S, w i
  else 0

/-- The **weighted Plücker mass**:
    `pluckerMass(A, w) = ∑_{S ⊆ [n], |S|=r} (det A_S)² · ∏_{i∈S} w_i` -/
def pluckerMass {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) (w : Fin n → ℝ) : ℝ :=
  (rSubsets r n).sum (pluckerSummand A w)

/-- Unfolding lemma for `pluckerSummand` when the cardinality matches. -/
lemma pluckerSummand_of_card_eq {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (w : Fin n → ℝ) (S : Finset (Fin n)) (hS : S.card = r) :
    pluckerSummand A w S = (minorMatrix A S hS).det ^ 2 * ∏ i ∈ S, w i := by
  simp [pluckerSummand, hS]

/-- At an `rSubsets` member, the summand unfolds correctly. -/
lemma pluckerSummand_mem {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (w : Fin n → ℝ) (S : Finset (Fin n)) (hS : S ∈ rSubsets r n) :
    pluckerSummand A w S =
      (minorMatrix A S (mem_rSubsets_card hS)).det ^ 2 * ∏ i ∈ S, w i :=
  pluckerSummand_of_card_eq A w S (mem_rSubsets_card hS)

/-- A **Slater basis distribution**: a probability law arising from
    normalized squared Plücker amplitudes of a decomposable fermionic state. -/
structure SlaterBasisDistribution (r n : ℕ) where
  repr : Matrix (Fin r) (Fin n) ℝ
  prob : Finset (Fin n) → ℝ
  gram_pos : 0 < (repr * repr.transpose).det
  prob_spec : ∀ (S : Finset (Fin n)) (hS : S ∈ rSubsets r n),
    prob S = (pluckerAmplitude repr S (mem_rSubsets_card hS))^2 /
      (repr * repr.transpose).det
  prob_zero_outside : ∀ S, S ∉ rSubsets r n → prob S = 0

/-! ## Section 2: Positivity Theorems -/

/-
Each summand of `pluckerMass` is nonneg when weights are nonneg.
-/
lemma pluckerSummand_nonneg {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (S : Finset (Fin n)) :
    0 ≤ pluckerSummand A w S := by
      -- Since the determinant is squared, it is always non-negative. The product of non-negative numbers is non-negative.
      have h_det_nonneg : ∀ S : Finset (Fin n), 0 ≤ (if hS : S.card = r then (minorMatrix A S hS).det ^ 2 * ∏ i ∈ S, w i else 0) := by
        exact fun S => by split_ifs <;> [ exact mul_nonneg ( sq_nonneg _ ) ( Finset.prod_nonneg fun _ _ => hw _ ) ; exact le_rfl ] ;
      convert h_det_nonneg S using 1

/-
**Theorem 1: Positivity of Plücker mass**.
    If all weights are nonnegative, then `0 ≤ pluckerMass(A, w)`.
-/
theorem pluckerMass_nonneg {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) :
    0 ≤ pluckerMass A w := by
      exact Finset.sum_nonneg fun S hS => pluckerSummand_nonneg A w hw S

/-
**Theorem 2: Strict positivity**.
    If some r-subset has nonzero minor and positive weight product, then
    `pluckerMass` is strictly positive.
-/
theorem pluckerMass_pos {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hex : ∃ (S : Finset (Fin n)) (hS : S ∈ rSubsets r n),
      (minorMatrix A S (mem_rSubsets_card hS)).det ≠ 0 ∧
      0 < ∏ i ∈ S, w i) :
    0 < pluckerMass A w := by
      obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := hex;
      refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun x _ => _ ) hS₁ );
      · exact ( by rw [ pluckerSummand_mem A w S hS₁ ] ; exact mul_pos ( sq_pos_of_ne_zero hS₂ ) hS₃ );
      · exact pluckerSummand_nonneg A w hw x

/-! ## Section 3: Cauchy–Binet and Gram Determinant Theorems -/

/-
**Theorem 3: Gram unit weights**.
    `A * diag(1) * Aᵀ = A * Aᵀ`.
-/
theorem gram_unit_weights {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) :
    A * diagonal (fun (_ : Fin n) => (1 : ℝ)) * Aᵀ = A * Aᵀ := by
      cases r <;> cases n <;> aesop

/-- **Theorem 4: Cauchy–Binet weighted Plücker expansion**.
    `det(A · D_w · Aᵀ) = pluckerMass(A, w)`.

    This is the central identity: it identifies the weighted basis-generating
    polynomial with a Gram determinant, the algebraic signature of
    free-fermion solvability. -/
theorem det_gram_eq_pluckerMass {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (w : Fin n → ℝ) :
    (A * diagonal w * Aᵀ).det = pluckerMass A w := by
  -- Use Cauchy–Binet: det((A*D_w) * Aᵀ) = ∑_S cbSummand
  -- Note: A * diagonal w * Aᵀ is parsed as (A * diagonal w) * Aᵀ (left-assoc)
  rw [show A * diagonal w * Aᵀ = (A * diagonal w) * Aᵀ from rfl,
      CauchyBinet.det_mul_rect]
  -- Show the sums are equal
  unfold pluckerMass rSubsets
  congr 1; ext S
  simp only [CauchyBinet.cbSummand, pluckerSummand]
  split_ifs with h
  · -- Show: det((A*D_w)_S) * det((Aᵀ)^S) = det(A_S)² * ∏_{i∈S} w_i
    have hAt : Aᵀ.submatrix (⇑(S.orderEmbOfFin h)) id = (A.submatrix id (⇑(S.orderEmbOfFin h)))ᵀ := by
      rw [Matrix.transpose_submatrix]
    have hAw : (A * diagonal w).submatrix id (⇑(S.orderEmbOfFin h)) =
      A.submatrix id (⇑(S.orderEmbOfFin h)) * diagonal (fun j => w (S.orderEmbOfFin h j)) := by
      ext i j; simp [Matrix.submatrix, Matrix.mul_apply, Matrix.diagonal]
    rw [hAw, hAt, det_mul, Matrix.det_transpose, Matrix.det_diagonal]
    simp only [minorMatrix]
    rw [sq]; ring_nf
    congr 1
    -- Show ∏ j : Fin r, w(e j) = ∏ i ∈ S, w i
    rw [← S.prod_coe_sort w]
    apply Fintype.prod_equiv (Finset.orderIsoOfFin S h).toEquiv
    intro j
    simp only [Finset.orderIsoOfFin, RelIso.coe_fn_toEquiv]
    rfl
  · rfl

/-- The unweighted Plücker mass. -/
def pluckerNorm {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) : ℝ :=
  pluckerMass A (fun _ => 1)

/-
**Theorem 5: Born rule for Slater determinants**.
    `∑_{|S|=r} (det A_S)² = det(A Aᵀ)`.

    The sum of squared Plücker amplitudes equals the Gram determinant.
    This is the normalization constant for the fermionic occupation state.
-/
theorem sum_sq_minor_eq_det_gram {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) :
    pluckerNorm A = (A * Aᵀ).det := by
      convert det_gram_eq_pluckerMass A ( fun _ => 1 ) |> Eq.symm using 1;
      exact congr_arg Matrix.det ( by ext i j; simp +decide [ Matrix.mul_apply ] )

/-! ## Section 4: Probability Normalization -/

/-- The Slater probability of an r-subset. -/
def slaterProb {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (S : Finset (Fin n)) (hS : S.card = r) : ℝ :=
  (minorMatrix A S hS).det ^ 2 / (A * Aᵀ).det

/-- **Theorem 6: Slater probability normalization**.
    When `det(AAᵀ) > 0`, the Slater probabilities sum to 1. -/
theorem slater_prob_sum_eq_one {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (hpos : 0 < (A * Aᵀ).det) :
    (rSubsets r n).sum (fun S =>
      if h : S.card = r then slaterProb A S h else 0) = 1 := by
  -- slaterProb A S h = det(A_S)^2 / det(AAᵀ)
  -- Sum = (∑_S det(A_S)^2) / det(AAᵀ) = pluckerNorm A / det(AAᵀ) = det(AAᵀ) / det(AAᵀ) = 1
  have key : (rSubsets r n).sum (fun S =>
      if h : S.card = r then slaterProb A S h else 0) =
    (rSubsets r n).sum (fun S =>
      if h : S.card = r then (minorMatrix A S h).det ^ 2 else 0) / (A * Aᵀ).det := by
    rw [Finset.sum_div]
    congr 1; ext S
    split_ifs with h
    · rfl
    · simp
  rw [key]
  -- The numerator is pluckerNorm A = pluckerMass A 1
  have hnum : (rSubsets r n).sum (fun S =>
      if h : S.card = r then (minorMatrix A S h).det ^ 2 else 0) = (A * Aᵀ).det := by
    rw [← sum_sq_minor_eq_det_gram]
    unfold pluckerNorm pluckerMass
    congr 1; ext S
    simp only [pluckerSummand]
    split_ifs with h
    · simp
    · rfl
  rw [hnum, div_self (ne_of_gt hpos)]

/-! ## Section 5: Column Scaling -/

/-
**Theorem 7: Minor determinant under column scaling**.
    Scaling columns of `A` by weights multiplies the minor determinant
    by the product of corresponding weights.
-/
theorem det_minor_column_scaled {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (w : Fin n → ℝ) (S : Finset (Fin n)) (hS : S.card = r) :
    (minorMatrix (fun i j => A i j * w j) S hS).det =
    (minorMatrix A S hS).det * ∏ j : Fin r, w (S.orderEmbOfFin hS j) := by
      convert Matrix.det_mul ?_ ?_ using 1 ;
      convert rfl;
      rotate_left;
      congr! 1;
      rotate_left;
      exact Matrix.diagonal fun i => w ( S.orderEmbOfFin hS i );
      · unfold minorMatrix; aesop;
      · rw [ Matrix.det_diagonal ]

/-- Each squared minor is nonneg. -/
theorem sq_minor_nonneg {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
    (S : Finset (Fin n)) (hS : S.card = r) :
    0 ≤ (minorMatrix A S hS).det ^ 2 :=
  sq_nonneg _

end FermionicPlucker