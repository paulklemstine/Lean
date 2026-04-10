/-
# Eigenvalue Repulsion: The Coulomb Gas Analogy

Why do eigenvalues of random matrices repel each other like charged particles?

## The Answer: The Vandermonde Determinant Is the Bridge

When we diagonalize a random symmetric/Hermitian matrix M = U D U*, the change of
variables from matrix entries to (eigenvalues, eigenvectors) produces a Jacobian
that is exactly the Vandermonde determinant:

  J = ∏_{i < j} |λ_j - λ_i|^β

For the Gaussian ensembles, the joint eigenvalue density becomes:

  p(λ₁, ..., λₙ) ∝ ∏_{i<j} |λ_j - λ_i|^β · exp(-∑ᵢ λᵢ²/2)

Taking the negative logarithm gives:

  E(λ₁,...,λₙ) = -β ∑_{i<j} log|λ_j - λ_i| + ½ ∑ᵢ λᵢ²

This IS the 2D Coulomb energy. The Vandermonde determinant, arising purely from
the geometry of diagonalization, IS the Boltzmann weight of a Coulomb system.
-/

import Mathlib

open Matrix Finset BigOperators

-- The Vandermonde determinant equals the product of all pairwise differences.
theorem vandermonde_det_eq_prod_diff {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det = ∏ i : Fin n, ∏ j ∈ Ioi i, (v j - v i) :=
  Matrix.det_vandermonde v

/-
PROBLEM
Eigenvalue repulsion: the Vandermonde determinant vanishes
iff two eigenvalues coincide.

PROVIDED SOLUTION
Rewrite using det_vandermonde, then the product is zero iff some factor is zero, iff v j - v i = 0 for some i < j, iff v i = v j for some i ≠ j. Use Finset.prod_eq_zero_iff and sub_eq_zero.
-/
theorem vandermonde_det_zero_iff {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det = 0 ↔ ∃ i j : Fin n, i ≠ j ∧ v i = v j := by
  -- By definition of Vandermonde determinant, if two eigenvalues are equal, say $v^i = v^j$ for some $i < j$, then the determinant is zero due to repeated columns.
  suffices h_suff : ∏ i : Fin n, ∏ j ∈ Finset.Ioi i, (v j - v i) = 0 ↔ ∃ i j, i < j ∧ v i = v j by
    rw [ vandermonde_det_eq_prod_diff, h_suff ];
    exact ⟨ fun ⟨ i, j, hij, h ⟩ => ⟨ i, j, ne_of_lt hij, h ⟩, fun ⟨ i, j, hij, h ⟩ => if hij' : i < j then ⟨ i, j, hij', h ⟩ else ⟨ j, i, lt_of_le_of_ne ( le_of_not_gt hij' ) ( Ne.symm hij ), h.symm ⟩ ⟩;
  norm_num [ Finset.prod_eq_zero_iff, sub_eq_zero ] ; aesop;

/-
PROBLEM
The squared Vandermonde determinant is the product of squared pairwise distances.

PROVIDED SOLUTION
Rewrite using det_vandermonde, then use Finset.prod_pow and distribute the square into the double product.
-/
theorem vandermonde_det_sq {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det ^ 2 = ∏ i : Fin n, ∏ j ∈ Ioi i, (v j - v i) ^ 2 := by
  simp +decide only [vandermonde_det_eq_prod_diff, prod_pow]

-- Non-negative Boltzmann weight.
theorem vandermonde_det_sq_nonneg {n : ℕ} (v : Fin n → ℝ) :
    0 ≤ (vandermonde v).det ^ 2 := sq_nonneg _

/-
PROBLEM
Strictly ordered eigenvalues yield a positive Vandermonde determinant.

PROVIDED SOLUTION
Rewrite using det_vandermonde. The product is positive because each factor (v j - v i) is positive when j > i and v is strictly monotone. Use Finset.prod_pos.
-/
theorem vandermonde_det_pos_of_strictMono {n : ℕ} (v : Fin n → ℝ)
    (hv : StrictMono v) : 0 < (vandermonde v).det := by
  rw [ vandermonde_det_eq_prod_diff v ] ; exact Finset.prod_pos fun i hi => Finset.prod_pos fun j hj => sub_pos.2 <| hv <| Finset.mem_Ioi.1 hj;

/-
PROBLEM
The log of the absolute Vandermonde determinant decomposes as a sum
of pairwise log-distances: the Coulomb energy decomposition.

PROVIDED SOLUTION
Rewrite det using det_vandermonde. Since v is strictly monotone, each factor (v j - v i) > 0 for j > i, so the absolute value of the product is just the product. Then use Real.log_prod and Real.log_prod for the inner sums. The key steps: |∏ f| = ∏ |f| = ∏ f (since each f > 0), then log (∏ f) = ∑ log f.
-/
theorem log_abs_vandermonde_eq_sum {n : ℕ} (v : Fin n → ℝ)
    (hv : StrictMono v) :
    Real.log |(vandermonde v).det| =
      ∑ i : Fin n, ∑ j ∈ Ioi i, Real.log (v j - v i) := by
  rw [ Matrix.det_vandermonde ];
  rw [ Finset.abs_prod, Real.log_prod ];
  · rw [ Finset.sum_congr rfl ] ; intros ; rw [ Finset.abs_prod ] ; rw [ Real.log_prod ] ; aesop;
    exact fun i hi => ne_of_gt <| abs_pos.mpr <| sub_ne_zero.mpr <| hv.injective.ne <| ne_of_gt <| Finset.mem_Ioi.mp hi;
  · exact fun i _ => ne_of_gt <| abs_pos.mpr <| Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero.mpr <| hv.injective.ne <| ne_of_gt <| Finset.mem_Ioi.mp hj

/-
PROBLEM
Higher β means stronger suppression near coincidence.

PROVIDED SOLUTION
Use Real.rpow_lt_rpow_of_exponent_gt since 0 < x < 1 and β₁ < β₂.
-/
theorem repulsion_stronger_at_higher_beta {x : ℝ} (hx0 : 0 < x) (hx1 : x < 1)
    {β₁ β₂ : ℝ} (hβ : β₁ < β₂) (hβ₁ : 0 < β₁) :
    x ^ β₂ < x ^ β₁ := by
  exact Real.rpow_lt_rpow_of_exponent_gt hx0 hx1 hβ

/-
PROBLEM
The 2×2 Vandermonde determinant is simply the eigenvalue gap.

PROVIDED SOLUTION
Unfold the 2x2 Vandermonde matrix and compute its determinant using det_fin_two or by simp with Matrix.det_vandermonde for n=2. The result is b - a. Try: simp [det_vandermonde, Fin.prod_univ_two, Finset.Ioi]; ring
-/
theorem vandermonde_two (a b : ℝ) :
    (vandermonde ![a, b]).det = b - a := by
  norm_num [ vandermonde, Matrix.det_fin_two ]

-- Symmetry of the squared gap under eigenvalue exchange.
theorem eigenvalue_gap_sq_symm (a b : ℝ) :
    (a - b) ^ 2 = (b - a) ^ 2 := by ring