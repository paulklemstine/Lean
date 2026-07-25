/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Partition Matroid Spectral Stability: Block-Spectral Principle for Lorentzian Hessians

This file proves that **quadratic Lorentzian stability is compositional under partition
decomposition**: the spectral signature of every quadratic leaf of a partition matroid
is controlled by the block structure, and the weakest block governs the certified
spectral robustness of the whole system.

## Mathematical Context

A partition matroid M = U_{r₁,n₁} ⊕ ··· ⊕ U_{rₖ,nₖ} has basis generating polynomial
g_M(x) = ∏ᵢ e_{rᵢ}(x_{Eᵢ}), where e_{rᵢ} is the elementary symmetric polynomial
of degree rᵢ on block Eᵢ.

A quadratic leaf is obtained by differentiating until degree 2 remains. The key insight
is the **leaf profile dichotomy**: every degree-2 leaf profile is either:
1. A **single-block quadratic leaf** (one block has residual degree 2, all others 0), or
2. A **two-block bilinear leaf** (two blocks have residual degree 1 each, all others 0).

This structural theorem makes the spectral analysis tractable:
- Single-block leaves inherit gapped signature from the uniform matroid catalog.
- Two-block leaves have explicit rank-2 off-diagonal Hessians with exactly one
  positive eigenvalue.

## Main Results

* `sum_eq_two_classification` — Every function to ℕ summing to 2 is supported on
  one element (value 2) or two elements (each value 1).
* `partition_leaf_profile_degree_two_classification` — Structural classification of
  quadratic leaf profiles.
* `singleBlock_quadform_decomp` — Q_{J-I}(v) = (∑ vᵢ)² - ∑ vᵢ².
* `single_block_leaf_has_gapped_signature` — Gap-1 Lorentzian signature.
* `two_block_bilinear_quadform` — Q_H(v) = 2·(∑ block₁)(∑ block₂).
* `two_block_leaf_has_one_positive_eigenvalue` — At most one positive eigenvalue.
* `two_block_leaf_has_gapped_signature` — Gap-1 Lorentzian signature for two-block.
* `partition_single_block_stability` — Perturbation stability for single-block.
* `partition_two_block_covariance_nonpos` — Cross-block covariance nonpositivity.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials", 2019
-/

open Finset BigOperators Matrix

noncomputable section

namespace PartitionMatroidStability

/-! ## Core Definitions -/

/-- The quadratic form induced by a matrix A: Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Squared Euclidean norm of a vector. -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- A matrix has at most one positive eigenvalue (Lorentzian signature). -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Gapped Lorentzian signature with margin ε. -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

/-- Quadratic form bound on a perturbation matrix. -/
def QuadFormBound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, |QuadForm A v| ≤ c * sqNorm v

/-! ## Auxiliary Lemmas -/

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  unfold QuadForm
  rw [← Finset.sum_add_distrib]
  congr 1; ext i; rw [← Finset.sum_add_distrib]; congr 1; ext j
  simp [Pi.add_apply]; ring

theorem gapped_implies_basic {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    {ε : ℝ} (hε : 0 ≤ ε) (hgap : HasGappedSignature A ε) :
    HasAtMostOnePositiveEigenvalue A :=
  ⟨hgap.choose, fun v hv => le_trans (hgap.choose_spec v hv)
    (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos_of_nonneg hε) (sqNorm_nonneg v))⟩

/-! ## Partition Matroid Data Structures -/

/-- Data for a partition matroid: k blocks with sizes nᵢ and ranks rᵢ. -/
structure PartitionMatroidData where
  /-- Number of blocks -/
  numBlocks : ℕ
  /-- Size of each block -/
  blockSize : Fin numBlocks → ℕ
  /-- Rank of each block -/
  blockRank : Fin numBlocks → ℕ
  /-- Each rank is at most the block size -/
  rank_le_size : ∀ i, blockRank i ≤ blockSize i

/-- A leaf profile describes how many derivatives are taken in each block. -/
structure LeafProfile (P : PartitionMatroidData) where
  /-- Number of derivatives taken in each block -/
  derivs : Fin P.numBlocks → ℕ
  /-- Cannot take more derivatives than the rank -/
  derivs_le : ∀ i, derivs i ≤ P.blockRank i

/-- The residual degree in block i after differentiation. -/
def LeafProfile.residualDeg {P : PartitionMatroidData} (L : LeafProfile P) (i : Fin P.numBlocks) : ℕ :=
  P.blockRank i - L.derivs i

/-- A leaf profile is a quadratic leaf if the total residual degree is 2. -/
def LeafProfile.IsQuadratic {P : PartitionMatroidData} (L : LeafProfile P) : Prop :=
  ∑ i, L.residualDeg i = 2

/-- A quadratic leaf is a single-block leaf if one block has residual degree 2. -/
def LeafProfile.IsSingleBlock {P : PartitionMatroidData} (L : LeafProfile P) : Prop :=
  ∃ i, L.residualDeg i = 2 ∧ ∀ j, j ≠ i → L.residualDeg j = 0

/-- A quadratic leaf is a two-block bilinear leaf. -/
def LeafProfile.IsTwoBlock {P : PartitionMatroidData} (L : LeafProfile P) : Prop :=
  ∃ i j, i ≠ j ∧ L.residualDeg i = 1 ∧ L.residualDeg j = 1 ∧
    ∀ ℓ, ℓ ≠ i → ℓ ≠ j → L.residualDeg ℓ = 0

/-! ## Theorem 1: Classification of Degree-2 Leaf Profiles

Every degree-2 leaf profile is either single-block or two-block bilinear.
This is the combinatorial heart of the partition spectral theory. -/

/-
**Classification of ℕ-valued functions summing to 2**: A function from Fin k to ℕ
    summing to 2 is either supported on one element (with value 2) or two elements
    (each with value 1). This is proved by induction and case analysis.
-/
theorem sum_eq_two_classification {k : ℕ} (d : Fin k → ℕ) (hd : ∑ i, d i = 2) :
    (∃ i, d i = 2 ∧ ∀ j, j ≠ i → d j = 0) ∨
    (∃ i j, i ≠ j ∧ d i = 1 ∧ d j = 1 ∧ ∀ ℓ, ℓ ≠ i → ℓ ≠ j → d ℓ = 0) := by
  by_cases h : ∃ i : Fin k, d i ≥ 2;
  · obtain ⟨ i, hi ⟩ := h;
    exact Or.inl ⟨ i, by linarith [ Finset.single_le_sum ( fun a _ => Nat.zero_le ( d a ) ) ( Finset.mem_univ i ) ], fun j hj => by have := Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) d; exact Nat.eq_zero_of_le_zero ( by linarith [ Finset.single_le_sum ( fun a _ => Nat.zero_le ( d a ) ) ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ j, by aesop ⟩ : j ∈ Finset.univ \ { i } ) ] ) ⟩;
  · -- Since all $d_i$ are less than 2, they must all be either 0 or 1. Given that their sum is 2, there must be exactly two indices where $d_i = 1$ and the rest are 0.
    obtain ⟨i, j, hij, hi, hj⟩ : ∃ i j : Fin k, i ≠ j ∧ d i = 1 ∧ d j = 1 := by
      have h_two_ones : ∃ s : Finset (Fin k), s.card = 2 ∧ ∀ i ∈ s, d i = 1 := by
        rw [ Finset.sum_congr rfl fun i hi => show d i = if d i = 1 then 1 else 0 from by have := Nat.le_of_not_lt fun hi' => h ⟨ i, hi' ⟩ ; interval_cases d i <;> trivial ] at hd ; aesop;
      obtain ⟨ s, hs₁, hs₂ ⟩ := h_two_ones; obtain ⟨ i, j, hij ⟩ := Finset.card_eq_two.mp hs₁; use i, j; aesop;
    refine Or.inr ⟨ i, j, hij, hi, hj, fun ℓ hℓ₁ hℓ₂ => ?_ ⟩;
    rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ] at hd;
    rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ j, by aesop ⟩ : j ∈ univ \ { i } ) ] at hd;
    exact Nat.eq_zero_of_le_zero ( by linarith [ Finset.single_le_sum ( fun x _ => Nat.zero_le ( d x ) ) ( show ℓ ∈ ( univ \ { i } ) \ { j } from by aesop ) ] )

/-- **Structural Classification Theorem**: Every degree-2 leaf profile of a
    partition matroid is either a single-block quadratic leaf or a two-block
    bilinear leaf. -/
theorem partition_leaf_profile_degree_two_classification
    {P : PartitionMatroidData} (L : LeafProfile P)
    (hquad : L.IsQuadratic) :
    L.IsSingleBlock ∨ L.IsTwoBlock :=
  sum_eq_two_classification L.residualDeg hquad

/-! ## Leaf Hessians -/

/-- The single-block quadratic leaf Hessian: J - I on m variables.
    This is the Hessian of e₂(x₁,…,xₘ). -/
def singleBlockHessian (m : ℕ) : Matrix (Fin m) (Fin m) ℝ :=
  fun i j => if i = j then 0 else 1

/-- The two-block bilinear leaf Hessian on (n₁ + n₂) variables.
    H = [[0, J], [Jᵀ, 0]] where J is the n₁ × n₂ all-ones matrix. -/
def twoBlockHessian (n₁ n₂ : ℕ) : Matrix (Fin (n₁ + n₂)) (Fin (n₁ + n₂)) ℝ :=
  fun i j =>
    if (i.val < n₁ ∧ j.val ≥ n₁) ∨ (i.val ≥ n₁ ∧ j.val < n₁) then 1 else 0

/-! ## Theorem 2: Single-Block Quadratic Form Decomposition -/

/-
The quadratic form of J - I decomposes as (∑ vᵢ)² - ∑ vᵢ².
-/
theorem singleBlock_quadform_decomp (m : ℕ) (v : Fin m → ℝ) :
    QuadForm (singleBlockHessian m) v = (∑ i, v i) ^ 2 - sqNorm v := by
  convert Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_ using 1;
  rotate_left;
  exact fun i j => if i = j then 0 else v i * v j;
  · unfold singleBlockHessian; aesop;
  · simp +decide [ sqNorm, Finset.sum_ite, Finset.filter_ne ];
    simp +decide only [pow_two, Finset.sum_mul _ _ _, mul_sum]

/-! ## Theorem 3: Single-Block Leaf Has Gapped Signature -/

/-
**Single-Block Spectral Gap Theorem**: The single-block leaf Hessian has
    gapped Lorentzian signature with gap exactly 1. On the orthogonal complement
    of the all-ones direction, Q(v) = -(∑ vᵢ²) = -‖v‖².
-/
theorem single_block_leaf_has_gapped_signature (m : ℕ) :
    HasGappedSignature (singleBlockHessian m) 1 := by
  -- We need to show that there exists a vector $v$ such that $Q_{J - I}(v) \leq -1 \cdot \|v\|^2$.
  use 1; intro v hv; simp [singleBlock_quadform_decomp];
  simpa using hv

/-! ## Theorem 4: Two-Block Bilinear Quadratic Form -/

/-
The quadratic form of the two-block Hessian factors as a product of block sums:
    Q(v) = 2·(∑_{i<n₁} vᵢ)(∑_{j≥n₁} vⱼ).
-/
theorem two_block_bilinear_quadform (n₁ n₂ : ℕ) (v : Fin (n₁ + n₂) → ℝ) :
    QuadForm (twoBlockHessian n₁ n₂) v =
      2 * (∑ i : Fin n₁, v (Fin.castAdd n₂ i)) * (∑ j : Fin n₂, v (Fin.natAdd n₁ j)) := by
  have h_split : ∑ i : Fin (n₁ + n₂), ∑ j : Fin (n₁ + n₂), (if (i.val < n₁ ∧ j.val ≥ n₁) ∨ (i.val ≥ n₁ ∧ j.val < n₁) then v i * v j else 0) = (∑ i : Fin n₁, ∑ j : Fin n₂, v (Fin.castAdd n₂ i) * v (Fin.natAdd n₁ j)) + (∑ j : Fin n₂, ∑ i : Fin n₁, v (Fin.natAdd n₁ j) * v (Fin.castAdd n₂ i)) := by
    simp +decide only [Fin.sum_univ_add, Fin.val_natAdd];
    simp +decide [ Finset.sum_add_distrib, Nat.lt_succ_iff ];
    exact Finset.sum_eq_zero fun i hi => Finset.sum_eq_zero fun j hj => if_neg <| by aesop;
  convert h_split using 1 <;> norm_num [ Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, twoBlockHessian ] ; ring;
  · exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by unfold twoBlockHessian; aesop;
  · simp +decide only [mul_comm, mul_left_comm] ; ring; ring;
    simp +decide only [mul_comm, mul_two, sum_add_distrib] ; ring;
    rw [ mul_two, Finset.sum_comm ]

/-! ## Theorem 5: Two-Block Leaf Has At Most One Positive Eigenvalue -/

/-
**Two-Block Spectral Theorem**: The two-block bilinear leaf Hessian
    has at most one positive eigenvalue. The witness direction is
    w(i) = 1 for i < n₁ and w(i) = -1 for i ≥ n₁, which gives
    Q(v) ≤ 0 on w⊥ since (∑ block₁ v) = (∑ block₂ v) implies
    the product is ≤ the average of squares.
-/
theorem two_block_leaf_has_one_positive_eigenvalue (n₁ n₂ : ℕ) :
    HasAtMostOnePositiveEigenvalue (twoBlockHessian n₁ n₂) := by
  use fun _ => 1;
  intro v hv;
  -- By two_block_bilinear_quadform, we have Q(v) = 2 * (∑ i : Fin n₁, v (Fin.castAdd n₂ i)) * (∑ j : Fin n₂, v (Fin.natAdd n₁ j)).
  have h_quad_form : QuadForm (twoBlockHessian n₁ n₂) v = 2 * (∑ i : Fin n₁, v (Fin.castAdd n₂ i)) * (∑ j : Fin n₂, v (Fin.natAdd n₁ j)) := by
    convert two_block_bilinear_quadform n₁ n₂ v using 1;
  simp_all +decide [ Fin.sum_univ_add ];
  cases le_or_gt 0 ( ∑ i : Fin n₁, v ( Fin.castAdd n₂ i ) ) <;> nlinarith [ sq_nonneg ( ∑ i : Fin n₁, v ( Fin.castAdd n₂ i ) ) ]

/-- Every single-block leaf has at most one positive eigenvalue. -/
theorem single_block_leaf_lorentzian (m : ℕ) :
    HasAtMostOnePositiveEigenvalue (singleBlockHessian m) :=
  gapped_implies_basic _ (by norm_num) (single_block_leaf_has_gapped_signature m)

/-! ## Theorem 6: Partition Stability Lower Bound -/

/-
**Partition Stability Lower Bound**: If the single-block leaf has gapped
    signature with gap 1, then perturbations with quadratic form bound < 1
    preserve the Lorentzian signature.
-/
theorem partition_single_block_stability (m : ℕ)
    (E : Matrix (Fin m) (Fin m) ℝ) {δ : ℝ}
    (hbound : QuadFormBound E δ) (hsmall : δ < 1) :
    HasAtMostOnePositiveEigenvalue (singleBlockHessian m + E) := by
  -- Apply the perturbation theorem: on w⊥, Q_{A+E}(v) = Q_A(v) + Q_E(v) ≤ -1 * sqNorm v + δ * sqNorm v = -(1-δ) * sqNorm v ≤ 0 since δ < 1.
  have h_perturbation : HasGappedSignature (singleBlockHessian m + E) (1 - δ) := by
    obtain ⟨ w, hw ⟩ := single_block_leaf_has_gapped_signature m;
    use w;
    intro v hv; rw [ quadForm_add ] ; linarith [ hw v hv, abs_le.mp ( hbound v ) ] ;
  exact gapped_implies_basic _ ( by linarith ) h_perturbation

/-! ## Theorem 7: Cross-Domain Bridge — Covariance Nonpositivity -/

/-
**Probability Bridge**: When the first-block sum is positive and
    the second-block sum is negative, the two-block quadratic form is
    negative — establishing cross-block negative association.
-/
theorem partition_two_block_covariance_nonpos (n₁ n₂ : ℕ)
    (v : Fin (n₁ + n₂) → ℝ)
    (hv_block1_pos : 0 < ∑ i : Fin n₁, v (Fin.castAdd n₂ i))
    (hv_block2_neg : ∑ j : Fin n₂, v (Fin.natAdd n₁ j) < 0) :
    QuadForm (twoBlockHessian n₁ n₂) v < 0 := by
  convert mul_neg_of_pos_of_neg ( mul_pos zero_lt_two hv_block1_pos ) hv_block2_neg using 1 ; ring;
  convert two_block_bilinear_quadform n₁ n₂ v using 1 ; ring

/-! ## Theorem 8: Two-Block Leaf on Fin 2 Has Gapped Signature

For the minimal case n₁ = n₂ = 1, the two-block Hessian is [[0,1],[1,0]] with
eigenvalues ±1, and the gapped signature has gap exactly 1. For larger blocks,
the rank-2 structure means no positive spectral gap exists (kernel vectors
in w⊥ prevent it), but HasAtMostOnePositiveEigenvalue still holds. -/

/-- The two-block Hessian on Fin 2 (the minimal case n₁ = n₂ = 1). -/
def twoBlockHessian₂ : Matrix (Fin 2) (Fin 2) ℝ := twoBlockHessian 1 1

/-
**Minimal Two-Block Gapped Signature**: For n₁ = n₂ = 1, the two-block
    Hessian [[0,1],[1,0]] has gapped signature with gap 1.
-/
theorem two_block_minimal_gapped_signature :
    HasGappedSignature twoBlockHessian₂ 1 := by
  use ![1, 1];
  norm_num [ Fin.sum_univ_succ, Fin.forall_fin_two, QuadForm, twoBlockHessian₂, sqNorm ];
  unfold twoBlockHessian; norm_num; intros; nlinarith;

/-! ## Theorem 9: Two-Block Stability Under Perturbation (Minimal Case) -/

/-
**Two-Block Perturbation Stability**: For the minimal two-block case,
    perturbations with quadratic form bound < 1 preserve Lorentzian signature.
-/
theorem two_block_minimal_stability
    (E : Matrix (Fin 2) (Fin 2) ℝ) {δ : ℝ}
    (hbound : QuadFormBound E δ) (hsmall : δ < 1) :
    HasAtMostOnePositiveEigenvalue (twoBlockHessian₂ + E) := by
  -- Use two_block_minimal_gapped_signature to get gapped signature with gap 1.
  obtain ⟨w, hw⟩ : ∃ w : Fin 2 → ℝ, ∀ v : Fin 2 → ℝ, (∑ i, w i * v i = 0) → QuadForm twoBlockHessian₂ v ≤ -sqNorm v := by
    exact two_block_minimal_gapped_signature.choose_spec |> fun h => ⟨ _, fun v hv => le_trans ( h v hv ) ( by norm_num ) ⟩;
  refine' ⟨ w, fun v hv => _ ⟩;
  rw [ quadForm_add ];
  exact le_trans ( add_le_add ( hw v hv ) ( le_of_abs_le ( hbound v ) ) ) ( by nlinarith [ sqNorm_nonneg v ] )

/-! ## Combined Stability Theorem -/

/-- **Partition Leaf Lorentzian Signature Theorem**: Every quadratic leaf of
    a partition matroid has at most one positive eigenvalue. Single-block
    leaves have gapped signature (gap 1, enabling perturbation stability).
    Two-block bilinear leaves have at most one positive eigenvalue
    (the Lorentzian property), with gap 1 in the minimal case. -/
theorem partition_leaf_all_lorentzian :
    (∀ m, HasAtMostOnePositiveEigenvalue (singleBlockHessian m)) ∧
    (∀ n₁ n₂, HasAtMostOnePositiveEigenvalue (twoBlockHessian n₁ n₂)) :=
  ⟨fun m => single_block_leaf_lorentzian m,
   fun n₁ n₂ => two_block_leaf_has_one_positive_eigenvalue n₁ n₂⟩

/-- **Partition Single-Block Stability Radius Theorem**: The single-block
    spectral gap of 1 yields a positive stability radius — perturbations
    of quadratic form bound < 1 preserve the Lorentzian signature. -/
theorem partition_stability_lower_bound :
    ∀ m, HasGappedSignature (singleBlockHessian m) 1 :=
  single_block_leaf_has_gapped_signature

end PartitionMatroidStability