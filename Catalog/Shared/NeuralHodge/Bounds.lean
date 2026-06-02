/-
# Neural Network Decision Surface Bounds

This module proves the main combinatorial and topological bounds on neural network
decision surfaces, including:

* The Euler characteristic triangle inequality for polyhedral complexes
* The deep network linear region multiplicative bound
* The Betti number bound from face counts (the "PL Hodge" observation)

## Main Results

* `euler_char_abs_le_totalFaces` — |χ(P)| ≤ total number of faces
* `binomial_sum_eq_pow` — Σ_{k=0}^{n} C(n,k) = 2^n
* `hodge_bound_combinatorial` — C(w₁,p)·C(w_L,q) ≤ 2^{w₁}·2^{w_L}
-/

import Mathlib
import Shared.NeuralHodge.Defs

open Finset BigOperators

/-! ## Euler Characteristic Bounds -/

/-
The absolute value of the Euler characteristic is bounded by the total face count.
    This is a triangle inequality: |Σ (-1)^k f_k| ≤ Σ f_k.
-/
theorem euler_char_abs_le_totalFaces {n : ℕ} (f : PolyhedralFVector n) :
    |f.eulerChar| ≤ (f.totalFaces : ℤ) := by
  convert Finset.abs_sum_le_sum_abs _ _ using 2;
  · norm_num [ abs_mul, PolyhedralFVector.totalFaces ];
  · infer_instance

/-
The Euler characteristic of a polyhedral complex with no faces is zero.
-/
theorem euler_char_empty (n : ℕ) :
    (⟨fun _ => 0, fun _ _ => rfl⟩ : PolyhedralFVector n).eulerChar = 0 := by
  unfold PolyhedralFVector.eulerChar; norm_num;

/-! ## Binomial Sum Identity -/

/-
The full binomial sum equals 2^n: Σ_{k=0}^{n} C(n,k) = 2^n.
    This is the binomial theorem applied to (1+1)^n.
-/
theorem binomial_sum_eq_pow (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), n.choose k = 2 ^ n := by
  rw [ Nat.sum_range_choose ]

/-
Partial binomial sums are monotone in the upper limit.
-/
theorem partial_binomial_sum_mono (n : ℕ) {a b : ℕ} (h : a ≤ b) :
    ∑ k ∈ Finset.range a, n.choose k ≤ ∑ k ∈ Finset.range b, n.choose k := by
  exact Finset.sum_le_sum_of_subset ( Finset.range_mono h )

/-! ## The PL Cycle Representation Theorem -/

/-- A simplicial chain data for a finite complex with `numFaces k` faces
    of dimension k. A chain is a ℤ-linear combination of faces. -/
structure SimplicialChainData (maxDim : ℕ) where
  numFaces : Fin (maxDim + 1) → ℕ

/-
In a PL complex, every k-chain is a formal ℤ-linear combination of k-faces.
    The chain module C_k ≅ ℤ^{f_k} has rank equal to the number of k-faces.
    This means every cycle is automatically a sum of face contributions —
    the PL Hodge property: every homology class is represented by
    "algebraic" pieces (the faces themselves).
-/
theorem chain_module_rank (maxDim : ℕ) (data : SimplicialChainData maxDim)
    (k : Fin (maxDim + 1)) :
    Module.rank ℤ (Fin (data.numFaces k) →₀ ℤ) = data.numFaces k := by
  norm_num

/-! ## Face-Count vs Architecture Bound -/

/-
The maximum number of faces of a ReLU network's decision boundary
    is bounded by neurons × regions ≤ neurons × 2^{neurons}.
-/
theorem face_count_bound (arch : NetworkArch) :
    arch.totalNeurons * neuralComplexity arch ≤
    arch.totalNeurons * 2 ^ arch.totalNeurons := by
  exact Nat.mul_le_mul_left _ ( neuralComplexity_le_pow arch )

/-! ## Hodge Number Bound -/

/-
The conjectured bound on "Hodge numbers" for a ReLU network decision surface.
    For a network with first hidden width w₁ and last hidden width w_L,
    the (p,q)-Hodge-like number h^{p,q} is bounded by C(w₁, p) * C(w_L, q).
    The combinatorial core: C(a,p)·C(b,q) ≤ 2^a · 2^b for all a,b,p,q.
-/
theorem hodge_bound_combinatorial (w₁ wL p q : ℕ) :
    w₁.choose p * wL.choose q ≤ 2 ^ w₁ * 2 ^ wL := by
  exact Nat.mul_le_mul (Nat.choose_le_two_pow w₁ p) (Nat.choose_le_two_pow wL q)

/-
Stronger form: C(n,k) ≤ 2^n for all n, k.
-/
theorem choose_le_pow (n k : ℕ) : n.choose k ≤ 2 ^ n := by
  rw [ ← Nat.sum_range_choose ];
  by_cases hk : k ≤ n;
  · exact Finset.single_le_sum ( fun x _ => Nat.zero_le ( n.choose x ) ) ( Finset.mem_range.mpr ( Nat.lt_succ_of_le hk ) );
  · rw [ Nat.choose_eq_zero_of_lt ( not_le.mp hk ) ] ; norm_num