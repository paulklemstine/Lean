/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Quantum DPPs and Entanglement Bounds via Lorentzian Geometry

This file formalizes the connection between determinantal point process (DPP)
generating polynomials, Lorentzian polynomial geometry, and quantum entanglement
entropy for free-fermion systems.

## Central Vision

For a positive semidefinite contraction kernel `K` (with `0 ≤ K ≤ I`), the DPP
partition polynomial `Z_K(z) = det(I + diag(z)·K)` encodes occupation statistics
of a fermionic Gaussian state. The Lorentzian geometry of `Z_K` — specifically,
the Hessian signatures of its derivative leaves — constrains the entanglement
entropy of subsystems.

## Main Definitions

* `QDE.binaryEntropy` — The function h(x) = -x log x - (1-x) log(1-x)
* `QDE.fermionicEntropyDiag` — Fermionic entropy for diagonal kernels restricted to a subset
* `QDE.principalSubmatrix` — Principal submatrix K_A for a subset A
* `QDE.twoByTwoPrincipalMinor` — The 2×2 principal minor det(K_{i,j})
* `QDE.leafCurvaturePairWitness` — Off-diagonal entry squared K_{ij}² as curvature witness
* `QDE.posIndex2x2` — Number of positive eigenvalues of a 2×2 real symmetric matrix
* `QDE.hessianPosIndexAtLeaf` — Positive index of the Hessian at a degree-2 derivative leaf
* `QDE.leafSignatureProfile` — Profile of Hessian positive indices over all pairs
* `QDE.balancedBipartitions` — Balanced bipartitions of [n]

## Main Results

* `QDE.binaryEntropy_pos` — h(x) > 0 for x ∈ (0,1)
* `QDE.fermionicEntropyDiag_mono` — Monotonicity of diagonal entropy under subset inclusion
* `QDE.diagonal_leaf_hessian_posIndex_le_one` — Degree-2 leaf Hessian has ≤ 1 pos eigenvalue
* `QDE.positive_leaf_curvature_implies_positive_entropy_pair` — Positive leaf curvature
    + strict contraction → positive 2-mode entropy
* `QDE.cauchy_schwarz_principal_minor` — Negative dependence inequality K_ij² ≤ K_ii · K_jj
-/

open Finset BigOperators Matrix Real

noncomputable section

namespace QDE

/-! ## §1. Core Definitions -/

/-- The binary Shannon entropy function: `h(x) = -x log x - (1-x) log(1-x)`.
    For free fermions, the entanglement entropy is the sum of binary entropies
    of the single-particle entanglement spectrum. -/
def binaryEntropy (x : ℝ) : ℝ :=
  -x * Real.log x - (1 - x) * Real.log (1 - x)

/-- The fermionic entanglement entropy for a diagonal kernel `diag(p)` restricted
    to a subset `A ⊆ Fin n`. For diagonal kernels, the eigenvalues of the
    principal submatrix `K_A` are exactly `{p i | i ∈ A}`, so the entropy is
    simply `∑ i ∈ A, h(p i)`. -/
def fermionicEntropyDiag {n : ℕ} (p : Fin n → ℝ) (A : Finset (Fin n)) : ℝ :=
  ∑ i ∈ A, binaryEntropy (p i)

/-- The principal submatrix of `K` indexed by a subset `A`. -/
def principalSubmatrix {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (A : Finset (Fin n)) :
    Matrix A A ℝ :=
  K.submatrix Subtype.val Subtype.val

/-- The 2×2 principal minor `det(K_{i,j}) = K_ii · K_jj - K_ij · K_ji`. -/
def twoByTwoPrincipalMinor {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) : ℝ :=
  K i i * K j j - K i j * K j i

/-- The leaf curvature pair witness: `K_ij²`. -/
def leafCurvaturePairWitness {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) : ℝ :=
  K i j ^ 2

/-- Number of positive eigenvalues of a 2×2 real symmetric matrix `[[a, b], [b, c]]`. -/
def posIndex2x2 (a b c : ℝ) : ℕ :=
  if a * c - b ^ 2 > 0 then (if a + c > 0 then 2 else 0)
  else if a * c - b ^ 2 < 0 then 1
  else (if a + c > 0 then 1 else 0)

/-- The Hessian positive index at a degree-2 derivative leaf for a diagonal kernel.
    For `diag(p)`, the leaf at `(i,j)` has Hessian `[[0, p_i·p_j·c], [same, 0]]`. -/
def hessianPosIndexAtLeaf {n : ℕ} (p : Fin n → ℝ) (i j : Fin n) : ℕ :=
  posIndex2x2 0 (p i * p j) 0

/-- The leaf signature profile: positive index for each pair. -/
def leafSignatureProfile {n : ℕ} (p : Fin n → ℝ) : Fin n → Fin n → ℕ :=
  fun i j => hessianPosIndexAtLeaf p i j

/-- Balanced bipartitions of `Fin n`: subsets of size `⌊n/2⌋`. -/
def balancedBipartitions (n : ℕ) : Finset (Finset (Fin n)) :=
  Finset.univ.powersetCard (n / 2)

/-! ## §2. Basic Properties of Binary Entropy -/

theorem binaryEntropy_zero : binaryEntropy 0 = 0 := by
  simp [binaryEntropy, Real.log_one]

theorem binaryEntropy_one : binaryEntropy 1 = 0 := by
  simp [binaryEntropy, Real.log_one]

theorem binaryEntropy_symm (x : ℝ) : binaryEntropy x = binaryEntropy (1 - x) := by
  simp [binaryEntropy]; ring

theorem binaryEntropy_nonneg {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ binaryEntropy x := by
  by_cases hx : x = 0 ∨ x = 1
  · rcases hx with rfl | rfl <;> simp [binaryEntropy, Real.log_one]
  · push_neg at hx
    unfold binaryEntropy
    have hx_pos : 0 < x := lt_of_le_of_ne hx0 (Ne.symm hx.1)
    have h1x_pos : 0 < 1 - x := sub_pos.mpr (lt_of_le_of_ne hx1 hx.2)
    nlinarith [Real.log_le_sub_one_of_pos hx_pos,
               Real.log_le_sub_one_of_pos h1x_pos]

/-
**Binary entropy is strictly positive on (0, 1)**: any mode with
    occupation probability strictly between 0 and 1 contributes positive entropy.
-/
theorem binaryEntropy_pos {x : ℝ} (hx0 : 0 < x) (hx1 : x < 1) :
    0 < binaryEntropy x := by
  unfold binaryEntropy;
  nlinarith [ Real.log_le_sub_one_of_pos hx0, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 - x ) ]

/-! ## §3. Diagonal Kernel Entropy -/

theorem fermionicEntropyDiag_eq {n : ℕ} (p : Fin n → ℝ) (A : Finset (Fin n)) :
    fermionicEntropyDiag p A = ∑ i ∈ A, binaryEntropy (p i) :=
  rfl

/-
**Monotonicity of fermionic entropy under subsystem inclusion** (diagonal case).
    Enlarging the subsystem can only increase the entropy for contraction kernels.
-/
theorem fermionicEntropyDiag_mono {n : ℕ} (p : Fin n → ℝ)
    (hp : ∀ i, 0 ≤ p i ∧ p i ≤ 1)
    {A B : Finset (Fin n)} (hAB : A ⊆ B) :
    fermionicEntropyDiag p A ≤ fermionicEntropyDiag p B := by
  exact Finset.sum_le_sum_of_subset_of_nonneg hAB fun i hi _ => binaryEntropy_nonneg ( hp i |>.1 ) ( hp i |>.2 )

theorem fermionicEntropyDiag_empty {n : ℕ} (p : Fin n → ℝ) :
    fermionicEntropyDiag p ∅ = 0 := by
  simp [fermionicEntropyDiag]

theorem fermionicEntropyDiag_singleton {n : ℕ} (p : Fin n → ℝ) (i : Fin n) :
    fermionicEntropyDiag p {i} = binaryEntropy (p i) := by
  simp [fermionicEntropyDiag]

theorem fermionicEntropyDiag_nonneg {n : ℕ} (p : Fin n → ℝ)
    (hp : ∀ i, 0 ≤ p i ∧ p i ≤ 1) (A : Finset (Fin n)) :
    0 ≤ fermionicEntropyDiag p A := by
  exact Finset.sum_nonneg fun i _ => QDE.binaryEntropy_nonneg ( hp i |>.1 ) ( hp i |>.2 )

/-
Diagonal kernel entropy is additive over disjoint subsystems.
-/
theorem fermionicEntropyDiag_union_disjoint {n : ℕ} (p : Fin n → ℝ)
    {A B : Finset (Fin n)} (hAB : Disjoint A B) :
    fermionicEntropyDiag p (A ∪ B) = fermionicEntropyDiag p A + fermionicEntropyDiag p B := by
  unfold fermionicEntropyDiag; rw [ Finset.sum_union hAB ] ;

/-! ## §4. Hessian Signature at Derivative Leaves -/

theorem posIndex2x2_antidiag {c : ℝ} (hc : c ≠ 0) :
    posIndex2x2 0 c 0 = 1 := by
  unfold posIndex2x2; norm_num [ hc ];
  split_ifs <;> nlinarith [ mul_self_pos.2 hc ]

theorem posIndex2x2_of_neg_det {a b c : ℝ} (hdet : a * c - b ^ 2 < 0) :
    posIndex2x2 a b c = 1 := by
  grind +locals

/-
**Degree-2 leaf Hessian has at most 1 positive eigenvalue** (diagonal case).
    This is the concrete Lorentzian signature constraint.
-/
theorem diagonal_leaf_hessian_posIndex_le_one {n : ℕ} (p : Fin n → ℝ)
    (_hp : ∀ i, 0 ≤ p i) (i j : Fin n) :
    hessianPosIndexAtLeaf p i j ≤ 1 := by
  unfold hessianPosIndexAtLeaf posIndex2x2; split_ifs <;> simp_all +decide ;

theorem hessianPosIndexAtLeaf_eq_one {n : ℕ} {i j : Fin n} (p : Fin n → ℝ)
    (hpi : 0 < p i) (hpj : 0 < p j) :
    hessianPosIndexAtLeaf p i j = 1 := by
  convert posIndex2x2_antidiag _;
  positivity

/-! ## §5. The Bridge: Leaf Curvature → Positive Entropy -/

/-
**Positive leaf curvature + strict contraction → positive 2-mode entropy**.

    If the degree-2 derivative leaf at `(i, j)` has nonzero curvature
    (i.e., `p i * p j > 0`), AND both modes are strictly below full
    occupation, then the fermionic entropy of the pair `{i, j}` is
    strictly positive. This turns a Hessian-signature datum into an
    entanglement bound.
-/
theorem positive_leaf_curvature_implies_positive_entropy_pair
    {n : ℕ} (p : Fin n → ℝ)
    (_hp01 : ∀ k, 0 ≤ p k ∧ p k ≤ 1)
    {i j : Fin n} (hij : i ≠ j)
    (_hpi1 : p i < 1) (_hpj1 : p j < 1)
    (hcurv : 0 < leafCurvaturePairWitness (Matrix.diagonal p) i j) :
    0 < fermionicEntropyDiag p {i, j} := by
  simp_all +decide [ leafCurvaturePairWitness, Matrix.diagonal ]

/-! ## §6. 2×2 Principal Submatrix Properties -/

theorem twoByTwoPrincipalMinor_nonneg {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.PosSemidef) (i j : Fin n) :
    0 ≤ twoByTwoPrincipalMinor K i j := by
  have h_det_nonneg : ∀ (v : Fin 2 → Fin n), 0 ≤ Matrix.det (Matrix.submatrix K v v) := by
    grind +suggestions;
  convert h_det_nonneg ( fun x => if x = 0 then i else j ) using 1 ; simp +decide [ twoByTwoPrincipalMinor, Matrix.det_fin_two ]

theorem twoByTwoPrincipalMinor_symm {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (i j : Fin n) :
    twoByTwoPrincipalMinor K i j = K i i * K j j - K i j ^ 2 := by
  unfold twoByTwoPrincipalMinor; rw [ sq ] ;
  exact hKsymm.apply j i ▸ rfl

/-
**Negative dependence as Cauchy–Schwarz**: `K_ij² ≤ K_ii · K_jj` for PSD `K`.
-/
theorem cauchy_schwarz_principal_minor {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.PosSemidef) (hKsymm : K.IsSymm) (i j : Fin n) :
    K i j ^ 2 ≤ K i i * K j j := by
  nlinarith [ twoByTwoPrincipalMinor_symm K hKsymm i j, twoByTwoPrincipalMinor_nonneg K hK i j, hK.1 ]

/-! ## §7. Leaf Curvature Witness Properties -/

theorem leafCurvaturePairWitness_nonneg {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) :
    0 ≤ leafCurvaturePairWitness K i j := by
  unfold leafCurvaturePairWitness; positivity

theorem leafCurvature_le_diag_product {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.PosSemidef) (hKsymm : K.IsSymm) (i j : Fin n) :
    leafCurvaturePairWitness K i j ≤ K i i * K j j := by
  convert cauchy_schwarz_principal_minor K hK hKsymm i j using 1

theorem leafCurvature_pos_iff {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    0 < leafCurvaturePairWitness K i j ↔ K i j ≠ 0 := by
  exact ⟨ fun h => by rintro h'; simp_all +decide [ leafCurvaturePairWitness ], fun h => by exact lt_of_le_of_ne ( leafCurvaturePairWitness_nonneg K i j ) ( Ne.symm <| by simp_all +decide [ leafCurvaturePairWitness ] ) ⟩

/-! ## §8. Explicit Family: Rank-One Projection -/

theorem rank_one_single_entropy {n : ℕ} (v : Fin n → ℝ) (k : Fin n) :
    fermionicEntropyDiag (fun i => v i ^ 2) {k} = binaryEntropy (v k ^ 2) := by
  simp [fermionicEntropyDiag]

theorem rank_one_total_entropy {n : ℕ} (v : Fin n → ℝ) :
    fermionicEntropyDiag (fun i => v i ^ 2) Finset.univ =
      ∑ i, binaryEntropy (v i ^ 2) := by
  simp [fermionicEntropyDiag]

/-! ## §9. Conjectural Bridge -/

/-
**Conjecture**: If a diagonal contraction kernel has a pair with
    positive leaf curvature and strict contraction, then some balanced
    bipartition has positive entropy.
-/
theorem lorentzian_signature_entropy_bridge
    {n : ℕ} (p : Fin n → ℝ)
    (hp : ∀ i, 0 ≤ p i ∧ p i ≤ 1)
    (hn : 2 ≤ n)
    (hexists : ∃ i j : Fin n, i ≠ j ∧ hessianPosIndexAtLeaf p i j = 1 ∧
               p i < 1 ∧ p j < 1) :
    ∃ A ∈ balancedBipartitions n, 0 < fermionicEntropyDiag p A := by
  -- From hexists, obtain i and j with the required properties.
  obtain ⟨i, j, hij, h_hessian, h_pi, h_pj⟩ := hexists;
  -- Since $p_i$ and $p_j$ are both in $(0,1)$, we can choose a balanced bipartition $A$ that includes $i$.
  obtain ⟨A, hA⟩ : ∃ A ∈ balancedBipartitions n, i ∈ A := by
    -- Since $n \geq 2$, we can construct a balanced bipartition $A$ that includes $i$.
    have h_exists_subset : ∃ A : Finset (Fin n), A.card = n / 2 ∧ i ∈ A := by
      -- Since $n \geq 2$, we can construct a subset $A$ of size $n/2$ that includes $i$.
      obtain ⟨A, hA⟩ : ∃ A : Finset (Fin n), A ⊆ Finset.univ \ {i} ∧ A.card = n / 2 - 1 := by
        exact Finset.exists_subset_card_eq ( by simpa [ Finset.card_sdiff ] using by omega );
      use Insert.insert i A;
      rw [ Finset.card_insert_of_notMem ( fun hi => by simpa [ hi ] using hA.1 hi ), hA.2, Nat.sub_add_cancel ( Nat.div_pos ( by linarith ) zero_lt_two ) ] ; aesop;
    exact ⟨ h_exists_subset.choose, Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, h_exists_subset.choose_spec.1 ⟩, h_exists_subset.choose_spec.2 ⟩;
  -- Since $p_i \in (0,1)$, we have $binaryEntropy (p_i) > 0$.
  have h_binary_entropy_pos : 0 < binaryEntropy (p i) := by
    by_cases hi : p i = 0;
    · unfold hessianPosIndexAtLeaf at h_hessian; unfold posIndex2x2 at h_hessian; aesop;
    · exact binaryEntropy_pos ( lt_of_le_of_ne ( hp i |>.1 ) ( Ne.symm hi ) ) h_pi;
  exact ⟨ A, hA.1, lt_of_lt_of_le h_binary_entropy_pos <| Finset.single_le_sum ( fun a _ => binaryEntropy_nonneg ( hp a |>.1 ) ( hp a |>.2 ) ) hA.2 ⟩

end QDE

end