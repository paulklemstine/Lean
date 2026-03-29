/-
  The Algebraic Theory of Magnetism — Formal Verification in Lean 4
  ===================================================================

  We formalize key algebraic results underlying the theory of magnetism:

  1. The operator space decomposition dimension formula:
     Σ_{k=0}^{n} (2k+1) = (n+1)²

  2. The exchange tensor decomposition: 1 + 3 + 5 = 9 = 3 × 3

  3. The Clebsch-Gordan dimension formula

  4. The Casimir eigenvalue monotonicity

  Author: The Oracle Council
-/

import Mathlib

/-
PROBLEM
============================================================================
Part 1: The Multipole Decomposition Dimension Formula
============================================================================

The key dimension formula for the multipole decomposition of End(V_s).

  For spin quantum number s (encoded as n = 2s, a natural number),
  the operator space End(V_s) has dimension (2s+1)² = (n+1)².
  Under the adjoint action of su(2), it decomposes as:

    End(V_s) ≅ V_0 ⊕ V_1 ⊕ ... ⊕ V_n

  with dim V_k = 2k+1. The dimension formula is:

    Σ_{k=0}^{n} (2k+1) = (n+1)²

  This is the foundational result for Prediction 1 (higher multipole magnets):
  it proves that for spin s, there exist exactly 2s+1 distinct multipole sectors,
  each providing a possible order parameter.

PROVIDED SOLUTION
Use induction on n. Base case: sum over range 1 = 2*0+1 = 1 = 1^2. Inductive step: sum over range (n+2) = sum over range (n+1) + (2*(n+1)+1) = (n+1)^2 + 2n+3 = n^2+2n+1+2n+3 = n^2+4n+4 = (n+2)^2. Alternatively, this is a well-known identity about the sum of odd numbers. Try Finset.sum_range_succ and ring, or omega, or simp with relevant lemmas.
-/
theorem multipole_decomposition_dim (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), (2 * k + 1) = (n + 1) ^ 2 := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-
PROBLEM
The number of independent multipole channels available for a spin-s system
  is exactly n = 2s (excluding the trivial monopole k=0).

PROVIDED SOLUTION
Finset.range (n+1) \ {0} has card (n+1) - 1 = n when 0 is in range (n+1). Use Finset.card_sdiff_of_subset or similar.
-/
theorem multipole_channels (n : ℕ) :
    (Finset.range (n + 1) \ {0}).card = n := by
  rw [ Finset.card_sdiff ] ; norm_num [ Finset.card_range ]

/-
============================================================================
Part 2: The Exchange Tensor Decomposition
============================================================================

The exchange tensor decomposition under O(3):
  R^{3×3} = R^1 (isotropic) ⊕ R^3 (antisymmetric/DM) ⊕ R^5 (traceless symmetric)

  Dimension count: 1 + 3 + 5 = 9 = 3 × 3

  This proves that 9 parameters completely classify all bilinear magnetic
  interactions, which is the foundation of Prediction 3 (designer magnets).
-/
theorem exchange_tensor_decomposition : 1 + 3 + 5 = 3 * 3 := by
  norm_num +zetaDelta at *

/-
More generally, a rank-2 tensor in d dimensions decomposes as:
  The antisymmetric part has dimension d*(d-1)/2.
  For d = 3: 3*(3-1)/2 = 3 (the DM vector).
-/
theorem antisymmetric_dim : 3 * (3 - 1) / 2 = 3 := by
  grind

/-
PROBLEM
============================================================================
Part 3: The Clebsch-Gordan Dimension Formula
============================================================================

The Clebsch-Gordan dimension formula (special case for equal spins).

  For V_s ⊗ V_s (i.e. a = b = n), the tensor product dimension is:
    (n+1)² = Σ_{k=0}^{n} (2n - 2k + 1)

  This is equivalent to the multipole decomposition formula and confirms
  that End(V_s) ≅ V_s ⊗ V_s* decomposes correctly.

PROVIDED SOLUTION
Induction on n. The sum Σ_{k=0}^{n} (2n-2k+1) = Σ_{j=0}^{n} (2j+1) by substitution j = n-k. This equals (n+1)^2 by the sum-of-odd-numbers formula. Use the already proven multipole_decomposition_dim after a suitable index substitution.
-/
theorem clebsch_gordan_equal (n : ℕ) :
    (n + 1) * (n + 1) = ∑ k ∈ Finset.range (n + 1), (2 * n - 2 * k + 1) := by
  exact Nat.recOn n ( by norm_num ) fun m ih => by simp_all +decide [ Nat.mul_succ, Finset.sum_range_succ', add_mul ] ; linarith [ Nat.sub_add_cancel <| show 2 * m ≤ 2 * m + 2 by linarith ] ;

/-
PROBLEM
============================================================================
Part 4: Casimir Eigenvalue Properties
============================================================================

The Casimir eigenvalue s(s+1) is a monotonically increasing function of s.
  For natural numbers encoding 2s: n(n+2) is strictly increasing in n.

  This ensures that the Curie temperature T_c = zJ·s(s+1)/3 increases with spin,
  predicting that higher-spin materials have higher ordering temperatures.

PROVIDED SOLUTION
n*(n+2) is strictly increasing for natural numbers. Since n₁ < n₂, we have n₁ + 1 ≤ n₂, so n₁*(n₁+2) < n₂*(n₂+2). Use nlinarith or omega.
-/
theorem casimir_monotone (n₁ n₂ : ℕ) (h : n₁ < n₂) :
    n₁ * (n₁ + 2) < n₂ * (n₂ + 2) := by
  nlinarith

/-
The dimension of the operator space for spin s is (2s+1)² = (n+1)².
  This grows quadratically, meaning higher-spin systems have
  proportionally more room for exotic multipole order parameters.
-/
theorem operator_space_grows (n : ℕ) :
    (n + 1) ^ 2 / (n + 1) = n + 1 := by
  norm_num [ sq ]

/-
PROBLEM
============================================================================
Part 5: Commutant Bounds (Prediction 2: Spin Liquids)
============================================================================

For a Hamiltonian on an N-dimensional Hilbert space,
  the commutant dimension satisfies: N ≤ N².
  (N for all-distinct eigenvalues, N² for fully degenerate)

PROVIDED SOLUTION
N ≤ N^2 for N ≥ 1. Use nlinarith or omega with hN.
-/
theorem commutant_bounds (N : ℕ) (hN : N ≥ 1) :
    N ≤ N ^ 2 := by
  nlinarith

/-
PROBLEM
============================================================================
Part 6: Key Combinatorial Identity
============================================================================

The sum of first n natural numbers: Σ_{k=0}^{n-1} k = n(n-1)/2.
  Used in computing dimensions of antisymmetric tensor spaces.

PROVIDED SOLUTION
Standard identity: 2 * Σ_{k=0}^{n-1} k = n*(n-1). Use induction on n with Finset.sum_range_succ, or use Gauss sum formula from Mathlib.
-/
theorem sum_naturals (n : ℕ) :
    2 * ∑ k ∈ Finset.range n, k = n * (n - 1) := by
  exact Eq.symm ( Nat.recOn n ( by norm_num ) fun n ih => by cases n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith )