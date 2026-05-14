import Mathlib

/-!
# Tropical Orbit Complexity from Spectral Data

This file develops the theory connecting tropical matrix powers to orbit complexity,
proving that spectral bounds on entry growth force bounded orbit cardinality and
zero asymptotic orbit entropy.

## Main results

* `tropMulMat` — tropical (max-plus) matrix multiplication over ℤ
* `tropPow` — tropical matrix powers
* `tropMatVecMul` — tropical matrix-vector multiplication
* `normalizedTropPow` — normalized tropical power (subtract linear drift)
* `orbitSetNormalized` — the finite set of distinct normalized powers up to time N
* `finset_card_le_of_bounded_entries` — finite box counting lemma
* `orbit_card_bound_of_box_bound` — bounded entries ⟹ polynomially bounded orbit count
* `trop_entry_le_of_eigenvector` — eigenvector ⟹ individual entry bound
* `trop_power_entry_upper_bound_of_eigenvector` — eigenvector ⟹ power entry bound
* `orbit_entropy_upper_bound_zero` — bounded orbit ⟹ vanishing entropy rate

## Strategy

We work over ℤ to get exact finite-state counting. The key insight:
1. Define tropical matrix multiplication as (A ⊗ B)ᵢⱼ = max_k (Aᵢₖ + Bₖⱼ)
2. If all entries of G^⊗k lie within kρ ± C, normalized entries lie in [-C, C]
3. Integer matrices with entries in [-C, C] form a finite set of size ≤ (2C+1)^(n²)
4. Therefore the normalized orbit is bounded by (2C+1)^(n²)
-/

noncomputable section

open Finset Matrix

/-! ## Tropical matrix operations over ℤ -/

/-- Tropical (max-plus) matrix multiplication: (A ⊗ B)ᵢⱼ = max_k (Aᵢₖ + Bₖⱼ). -/
def tropMulMat {n : ℕ} [NeZero n] (A B : Matrix (Fin n) (Fin n) ℤ) :
    Matrix (Fin n) (Fin n) ℤ :=
  fun i j => Finset.sup' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)

/-- Tropical matrix power: G^⊗k under max-plus multiplication. -/
def tropPow {n : ℕ} [NeZero n] (G : Matrix (Fin n) (Fin n) ℤ) :
    ℕ → Matrix (Fin n) (Fin n) ℤ
  | 0 => fun i j => if i = j then 0 else 0
  | 1 => G
  | k + 1 => tropMulMat (tropPow G k) G

/-- Tropical matrix-vector multiplication: (A ⊗ v)ᵢ = max_j (Aᵢⱼ + vⱼ). -/
def tropMatVecMul {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℤ)
    (v : Fin n → ℤ) : Fin n → ℤ :=
  fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun j => A i j + v j)

/-- Normalized tropical power: subtract the linear drift kρ from each entry. -/
def normalizedTropPow {n : ℕ} [NeZero n] (G : Matrix (Fin n) (Fin n) ℤ)
    (ρ : ℤ) (k : ℕ) : Matrix (Fin n) (Fin n) ℤ :=
  fun i j => tropPow G k i j - k * ρ

/-- The set of distinct normalized tropical powers from step 1 to step N. -/
def orbitSetNormalized {n : ℕ} [NeZero n] (G : Matrix (Fin n) (Fin n) ℤ)
    (ρ : ℤ) (N : ℕ) : Finset (Matrix (Fin n) (Fin n) ℤ) :=
  (Finset.range N).image (fun k => normalizedTropPow G ρ (k + 1))

/-! ## Helper lemmas for tropical multiplication -/

/-- In tropical multiplication, the result entry is at least any particular summand. -/
lemma tropMulMat_entry_le {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℤ) (i j : Fin n) (k : Fin n) :
    A i k + B k j ≤ tropMulMat A B i j := by
  simp only [tropMulMat]
  exact Finset.le_sup' (fun k => A i k + B k j) (Finset.mem_univ k)

/-- The tropical product entry equals some particular summand (the maximum). -/
lemma tropMulMat_entry_eq {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℤ) (i j : Fin n) :
    ∃ k : Fin n, tropMulMat A B i j = A i k + B k j := by
  simp only [tropMulMat]
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty (fun k => A i k + B k j)
  exact ⟨k, hk⟩

/-- The tropical product entry is bounded above by the max of all summands. -/
lemma tropMulMat_entry_ub {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℤ) (i j : Fin n)
    (bound : ℤ) (h : ∀ k : Fin n, A i k + B k j ≤ bound) :
    tropMulMat A B i j ≤ bound := by
  simp only [tropMulMat]
  apply Finset.sup'_le
  intro k _
  exact h k

/-! ## Finite box counting -/

/-
Any Finset of n×n integer matrices with entries bounded by C in absolute value
has cardinality at most (2C+1)^(n*n). This is the key finite box counting lemma:
each of n² entries has at most 2C+1 possible values.
-/
lemma finset_card_le_of_bounded_entries {n : ℕ}
    (S : Finset (Matrix (Fin n) (Fin n) ℤ)) (C : ℕ)
    (h : ∀ M ∈ S, ∀ i j : Fin n, |M i j| ≤ (C : ℤ)) :
    S.card ≤ (2 * C + 1) ^ (n * n) := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun x : Fin n → Fin n → Fin ( 2 * C + 1 ) => fun i j => ( x i j : ℤ ) - C ) ( Finset.univ );
  · intro M hM; use Finset.mem_image.mpr ⟨ fun i j => ⟨ Int.toNat ( M i j + C ), by linarith [ abs_le.mp ( h M hM i j ), Int.toNat_of_nonneg ( by linarith [ abs_le.mp ( h M hM i j ) ] : 0 ≤ M i j + C ) ] ⟩, Finset.mem_univ _, ?_ ⟩ ; ext i j; simp +decide [ Int.toNat_of_nonneg ( by linarith [ abs_le.mp ( h M hM i j ) ] : 0 ≤ M i j + C ) ] ;
  · refine' Finset.card_image_le.trans _ ; norm_num [ Finset.card_univ ] ; ring_nf ; aesop;

/-! ## Primary Theorem A: Orbit cardinality bound from entry bounds -/

/-
**Orbit cardinality bound (Theorem A)**: If all normalized tropical power entries
lie in [-C, C] (in absolute value), then the number of distinct normalized powers
up to any time N is at most (2C+1)^(n²).

This converts spectral linear growth bounds into a finite-state dynamical system.
-/
theorem orbit_card_bound_of_box_bound
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) ℤ)
    (ρ : ℤ) (C : ℕ)
    (hbound : ∀ k : ℕ, 1 ≤ k →
      ∀ i j : Fin n, |tropPow G k i j - (k : ℤ) * ρ| ≤ (C : ℤ)) :
    ∀ N : ℕ,
      (orbitSetNormalized G ρ N).card ≤ (2 * C + 1) ^ (n * n) := by
  intro N
  apply finset_card_le_of_bounded_entries;
  unfold orbitSetNormalized; aesop;

/-! ## Primary Theorem B: Eigenvector implies entry upper bound -/

/-
Auxiliary: tropical eigenvector equation implies individual entry bound.
From max_j (G i j + v j) = ρ + v i, we get G i j + v j ≤ ρ + v i for each j,
hence G i j ≤ ρ + v i - v j.
-/
lemma trop_entry_le_of_eigenvector
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) ℤ)
    (v : Fin n → ℤ) (ρ : ℤ)
    (heig : ∀ i : Fin n, (tropMatVecMul G v) i = ρ + v i)
    (i j : Fin n) :
    G i j ≤ ρ + v i - v j := by
  exact le_tsub_of_add_le_right ( heig i ▸ Finset.le_sup' ( fun k => G i k + v k ) ( Finset.mem_univ j ) )

/-
**Spectral-to-orbit bridge (Theorem B)**: If v is a tropical eigenvector of G
with eigenvalue ρ (meaning max_j (G_{ij} + v_j) = ρ + v_i for all i), then every
entry of the k-th tropical power satisfies G^⊗k_{ij} ≤ kρ + v_i - v_j.

The proof is by induction on k:
- Base case k=1: tropPow G 1 = G, and G i j ≤ ρ + v i - v j by `trop_entry_le_of_eigenvector`.
- Inductive step: tropPow G (k+1) = tropMulMat (tropPow G k) G.
  For each intermediate index l:
    tropPow G k i l + G l j ≤ (k*ρ + v i - v l) + (ρ + v l - v j)
                             = (k+1)*ρ + v i - v j
  Taking the max over l preserves this upper bound.
-/
theorem trop_power_entry_upper_bound_of_eigenvector
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) ℤ)
    (v : Fin n → ℤ) (ρ : ℤ)
    (heig : ∀ i : Fin n, (tropMatVecMul G v) i = ρ + v i) :
    ∀ k : ℕ, 1 ≤ k → ∀ i j : Fin n,
      tropPow G k i j ≤ (k : ℤ) * ρ + v i - v j := by
  intro k hk;
  induction' k with k ih;
  · contradiction;
  · rcases k with ( _ | k ) <;> simp_all +decide;
    · exact fun i j => trop_entry_le_of_eigenvector (tropPow G 1) v ρ heig i j;
    · intro i j;
      -- By definition of tropPow, we have tropPow G (k + 2) i j = tropMulMat (tropPow G (k + 1)) G i j.
      have h_tropPow_succ : tropPow G (k + 2) i j = tropMulMat (tropPow G (k + 1)) G i j := by
        rfl;
      exact h_tropPow_succ ▸ tropMulMat_entry_ub _ _ _ _ _ fun l => by linarith [ ih i l, trop_entry_le_of_eigenvector G v ρ heig l j ] ;

/-! ## Primary Theorem C: Zero entropy from bounded orbit -/

/-
**Entropy collapse (Theorem C)**: If the normalized orbit cardinality is uniformly
bounded by K, then for any ε > 0, log(card)/N ≤ ε for sufficiently large N.
This is the finite-step version of zero asymptotic orbit entropy.
-/
theorem orbit_entropy_upper_bound_zero
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) ℤ)
    (ρ : ℤ) (K : ℕ)
    (hK : ∀ N : ℕ, (orbitSetNormalized G ρ N).card ≤ K) :
    ∀ ε : ℝ, 0 < ε → ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N →
      Real.log ((orbitSetNormalized G ρ N).card : ℝ) / (N : ℝ) ≤ ε := by
  -- Given K bounding the orbit cardinality for all N, we need: for any ε > 0, there exists N₀ such that for N ≥ N₀, log(card)/N ≤ ε.
  intros ε hεpos
  use Nat.ceil (Real.log (K : ℝ) / ε) + 1;
  intro N hN;
  rw [ div_le_iff₀ ];
  · rcases eq_or_ne K 0 <;> rcases eq_or_ne ( # ( orbitSetNormalized G ρ N ) ) 0 <;> simp_all +decide;
    exact le_trans ( Real.log_le_log ( Nat.cast_pos.mpr <| Finset.card_pos.mpr <| Finset.nonempty_of_ne_empty ‹_› ) <| Nat.cast_le.mpr <| hK N ) <| by nlinarith [ Nat.lt_of_ceil_lt hN, mul_div_cancel₀ ( Real.log K ) hεpos.ne' ] ;
  · exact Nat.cast_pos.mpr ( by linarith )

end