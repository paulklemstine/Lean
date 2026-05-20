import Mathlib
import Algebra.CodingTheory.Defs

/-!
# Algebraic Coding Theory: Core Theorems

This file contains the main theorems of our algebraic coding theory development:

1. **Structural BCH Bound** (`bch_bound_structural`): Any nonzero vector with
   vanishing consecutive syndromes has Hamming weight ≥ δ.

2. **Unique Decoding Radius** (`unique_decode_of_lt_half_distance`): Two codewords
   within distance t of a received word must coincide when 2t < minimum distance.

3. **Locator Annihilates Syndromes** (`locator_annihilates_syndromeSeq`): The error
   locator polynomial annihilates the syndrome sequence of any error pattern.

4. **Syndrome Linear Dependence** (`syndrome_linear_dependence`): When the error weight
   is at most t, there exists a low-degree annihilator for the syndrome sequence.

5. **Hankel Rank Bound** (`hankel_rank_le_weight`): The rank of the syndrome Hankel
   matrix is at most the Hamming weight of the error.
-/

open Polynomial Finset BigOperators Matrix AlgCoding

noncomputable section

namespace AlgCoding

/-! ## Theorem 1: Structural BCH Bound -/

/-
**Structural BCH Bound**: If a vector c has all syndromes vanishing at
    δ-1 consecutive powers of an injective element α, then c = 0 or wt(c) ≥ δ.
    This is the core distance guarantee of BCH codes.
-/
set_option maxHeartbeats 400000 in
theorem bch_bound_structural {K : Type*} [Field K] [DecidableEq K] {n δ : ℕ}
    (α : K) (b : ℕ)
    (hα_ne : α ≠ 0)
    (hα_inj : ∀ i j : Fin n, α ^ i.val = α ^ j.val → i = j)
    (_hδ : δ ≤ n + 1)
    (c : Fin n → K)
    (hc : BCHParityCheck α b δ c) :
    c = 0 ∨ δ ≤ hammingWeight c := by
  by_contra h_contra;
  -- Let S = support c = univ.filter(fun i => c i ≠ 0). Then S.card < δ.
  set S := support c with hS_def
  have hS_card : S.card < δ := by
    exact lt_of_not_ge fun h => h_contra <| Or.inr h;
  -- Use Finset.orderEmbOfFin to index S by Fin S.card, getting an injective function e : Fin S.card → Fin n with range S.
  obtain ⟨e, he_inj, he_range⟩ : ∃ e : Fin S.card → Fin n, Function.Injective e ∧ Set.range e = S := by
    have hS_card : Nonempty (Fin S.card ≃ S) := by
      exact ⟨ Fintype.equivOfCardEq <| by simp +decide ⟩;
    obtain ⟨ e ⟩ := hS_card;
    refine' ⟨ fun i => e i, _, _ ⟩ <;> simp +decide [ Function.Injective, Set.range_eq_iff ];
    exact fun b hb => ⟨ e.symm ⟨ b, hb ⟩, by simp +decide ⟩;
  -- Define w : Fin S.card → K := fun ℓ => c (e ℓ) * α ^ (b * (e ℓ).val) and x : Fin S.card → K := fun ℓ => α ^ (e ℓ).val.
  set w : Fin S.card → K := fun ℓ => c (e ℓ) * α ^ (b * (e ℓ).val)
  set x : Fin S.card → K := fun ℓ => α ^ (e ℓ).val;
  -- The BCH parity check gives: for each j < S.card (since S.card < δ implies S.card ≤ δ-1), ∑ ℓ, w ℓ * (x ℓ)^j = 0.
  have h_parity_check : ∀ j : Fin S.card, ∑ ℓ : Fin S.card, w ℓ * (x ℓ) ^ (j : ℕ) = 0 := by
    intro j
    have h_sum : ∑ ℓ : Fin S.card, w ℓ * (x ℓ) ^ (j : ℕ) = ∑ i ∈ S, c i * α ^ ((b + j) * i.val) := by
      have h_sum : ∑ ℓ : Fin S.card, w ℓ * (x ℓ) ^ (j : ℕ) = ∑ i ∈ Finset.image e Finset.univ, c i * α ^ ((b + j) * i.val) := by
        rw [ Finset.sum_image <| by tauto ] ; congr ; ext ; ring;
      rw [ h_sum, show image e Finset.univ = S from ?_ ];
      simp_all +decide [ Finset.ext_iff, Set.ext_iff ];
    rw [ h_sum, Finset.sum_subset ( Finset.subset_univ S ) ];
    · exact hc j ( Nat.lt_of_lt_of_le j.2 ( Nat.le_sub_one_of_lt hS_card ) );
    · simp +contextual [ S, support ];
  -- Build the Vandermonde matrix V[i,j] = x j ^ i. Its determinant is nonzero because the x values are distinct.
  have h_vandermonde_det : Matrix.det (Matrix.of (fun i j : Fin S.card => x j ^ (i : ℕ))) ≠ 0 := by
    erw [ Matrix.det_transpose, Matrix.det_vandermonde ];
    simp +decide [ Finset.prod_eq_zero_iff, sub_eq_zero ];
    exact fun i j hij => fun h => hij.ne <| he_inj <| hα_inj _ _ h.symm;
  -- Since V is invertible and V * w = 0, we get w = 0.
  have h_w_zero : w = 0 := by
    have h_w_zero : Matrix.mulVec (Matrix.of (fun i j : Fin S.card => x j ^ (i : ℕ))) w = 0 := by
      exact funext fun i => by simpa [ Matrix.mulVec, dotProduct, mul_comm ] using h_parity_check i;
    exact Matrix.eq_zero_of_mulVec_eq_zero h_vandermonde_det h_w_zero;
  simp_all +decide [ funext_iff ];
  exact h_contra.1.elim fun i hi => hi <| by have := he_range.symm.subset ( Finset.mem_coe.mpr <| Finset.mem_filter.mpr ⟨ Finset.mem_univ i, hi ⟩ ) ; obtain ⟨ j, hj ⟩ := this; specialize h_w_zero j; aesop;

/-! ## Theorem 2: Unique Decoding Radius -/

/-
Hamming distance equals Hamming weight of the difference (for additive groups).
-/
theorem hammingDist_eq_weight_sub {K : Type*} [AddGroup K] [DecidableEq K] {n : ℕ}
    (x y : Fin n → K) : hammingDist x y = hammingWeight (x - y) := by
  -- By definition of Hamming distance and weight, we have:
  simp [hammingDist, hammingWeight];
  simp +decide only [sub_eq_zero]

/-
**Unique Decoding**: Two codewords within radius t of a received word must be
    equal when 2t is strictly less than the code's minimum distance.
-/
theorem unique_decode_of_lt_half_distance
    {K : Type*} [Field K] [DecidableEq K]
    {n : ℕ} {C : Set (Fin n → K)} {r c₁ c₂ : Fin n → K} {t d : ℕ}
    (hmin : ∀ c ∈ C, c ≠ 0 → d ≤ hammingWeight c)
    (hlin : IsLinearCode C)
    (hd₁ : hammingDist r c₁ ≤ t)
    (hd₂ : hammingDist r c₂ ≤ t)
    (hc₁ : c₁ ∈ C) (hc₂ : c₂ ∈ C)
    (hlt : 2 * t < d) :
    c₁ = c₂ := by
  contrapose! hlt;
  refine' le_trans ( hmin ( c₁ - c₂ ) _ _ ) _;
  · exact hlin.2 _ _ hc₁ hc₂ |>.2;
  · exact sub_ne_zero_of_ne hlt;
  · rw [ ← hammingDist_eq_weight_sub ];
    exact le_trans ( hammingDist_triangle c₁ r c₂ ) ( by linarith [ hammingDist_comm r c₁ ] )

/-! ## Theorem 3: Error Locator Annihilates Syndrome Sequence -/

/-
Auxiliary: the syndrome sequence decomposes as a sum of geometric progressions
    indexed by the support of e.
-/
theorem syndromeSeq_eq_sum_geom {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) (k : ℕ) :
    syndromeSeq α e k = ∑ i ∈ support e, e i * (α ^ i.val) ^ k := by
  simp +decide [ syndromeSeq, support ];
  rw [ Finset.sum_filter_of_ne ] ; aesop

/-
**Locator Annihilates Syndromes**: The reversed error locator polynomial
    Λ_rev(z) = ∏_{i ∈ supp(e)} (z - α^i) annihilates the syndrome sequence.
    This is because Λ_rev(α^j) = 0 for every error position j, so the convolution
    ∑_l Λ_rev_l · s_{k+l} = ∑_j e_j (α^j)^k Λ_rev(α^j) = 0.
-/
theorem locator_annihilates_syndromeSeq
    {K : Type*} [Field K] [DecidableEq K] {n : ℕ}
    (α : K) (e : Fin n → K) :
    annihilatesSyndromeSeq α e (errorLocatorPolyRev α e) := by
  -- By definition of polynomial evaluation, we can write the evaluation of the error locator polynomial at α^j as the sum of its coefficients multiplied by (α^j)^l.
  have h_eval : ∀ j : Fin n, j ∈ support e → ∑ l ∈ Finset.range ((errorLocatorPolyRev α e).natDegree + 1), ((errorLocatorPolyRev α e).coeff l) * (α ^ j.val) ^ l = 0 := by
    intro j hj;
    convert errorLocatorPolyRev_eval_zero α e j hj using 1;
    rw [ Polynomial.eval_eq_sum_range ];
  intro k
  have h_sum : ∑ l ∈ Finset.range ((errorLocatorPolyRev α e).natDegree + 1), ((errorLocatorPolyRev α e).coeff l) * (syndromeSeq α e (k + l)) = ∑ j ∈ support e, e j * (α ^ j.val) ^ k * (∑ l ∈ Finset.range ((errorLocatorPolyRev α e).natDegree + 1), ((errorLocatorPolyRev α e).coeff l) * (α ^ j.val) ^ l) := by
    simp +decide only [syndromeSeq_eq_sum_geom, Finset.mul_sum _ _ _, mul_left_comm];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
  exact h_sum.trans ( Finset.sum_eq_zero fun j hj => by rw [ h_eval j hj, MulZeroClass.mul_zero ] )

/-! ## Theorem 4: Syndrome Linear Dependence from Bounded Weight -/

/-- **Syndrome Linear Dependence**: When the error weight is at most t,
    there exists a nonzero polynomial of degree ≤ t that annihilates the
    syndrome sequence. -/
theorem syndrome_linear_dependence
    {K : Type*} [Field K] [DecidableEq K] {n t : ℕ}
    (α : K) (e : Fin n → K)
    (hw : hammingWeight e ≤ t) :
    ∃ Λ : K[X], Λ ≠ 0 ∧ Λ.natDegree ≤ t ∧ annihilatesSyndromeSeq α e Λ := by
  exact ⟨errorLocatorPolyRev α e, errorLocatorPolyRev_ne_zero α e,
    le_trans (errorLocatorPolyRev_natDegree_le α e) hw,
    locator_annihilates_syndromeSeq α e⟩

/-! ## Theorem 5: Hankel Rank Bound -/

/-- The Vandermonde column vector for error location x. -/
def vandermondeCol {K : Type*} [CommRing K] (x : K) (m : ℕ) : Fin m → K :=
  fun j => x ^ j.val

/-
The syndrome Hankel matrix factors as A * B where
    A[i,j] = e_j · (α^j)^i and B[j,k] = (α^j)^k.
-/
theorem syndromeHankel_factored {K : Type*} [Field K] [DecidableEq K] {n m : ℕ}
    (α : K) (e : Fin n → K) :
    syndromeHankelMatrix (syndromeSeq α e) m =
      (Matrix.of fun (i : Fin m) (j : Fin n) => e j * (α ^ j.val) ^ i.val) *
      (Matrix.of fun (i : Fin n) (j : Fin m) => (α ^ i.val) ^ j.val) := by
  unfold syndromeHankelMatrix syndromeSeq; ext i j; simp +decide [ Matrix.mul_apply, pow_add ] ; ring;
  exact Finset.sum_congr rfl fun _ _ => by ring;

/-
**Hankel Rank Bound**: The rank of the syndrome Hankel matrix is at most
    the Hamming weight of the error vector.

    This is the bridge between coding theory and structured low-rank matrix theory.
-/
theorem hankel_rank_le_weight {K : Type*} [Field K] [DecidableEq K] {n m : ℕ}
    (α : K) (e : Fin n → K) :
    (syndromeHankelMatrix (syndromeSeq α e) m).rank ≤ hammingWeight e := by
  -- By definition of syndromeHankelMatrix, we can write it as a product of two matrices.
  have h_prod : syndromeHankelMatrix (syndromeSeq α e) m = (Matrix.of fun (i : Fin m) (j : Fin n) => (α ^ j.val) ^ i.val) * (Matrix.diagonal (fun j => e j)) * (Matrix.of fun (i : Fin n) (j : Fin m) => (α ^ i.val) ^ j.val) := by
    ext i j;
    simp +decide [ Matrix.mul_apply, syndromeHankelMatrix, syndromeSeq ];
    simp +decide [ Matrix.diagonal, pow_add, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
  refine' h_prod ▸ le_trans ( Matrix.rank_mul_le_left _ _ ) _;
  convert Matrix.rank_mul_le_right _ _ |> le_trans <| Matrix.rank_diagonal ( fun j => e j ) |> le_of_eq using 1;
  rw [ Fintype.subtype_card ];
  rfl

end AlgCoding

end