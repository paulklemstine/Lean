/-
  # Normalization and Equivalence for Hadamard Matrices

  Proves that every Hadamard matrix can be normalized (first row and column all 1s)
  by sign-flipping rows and columns. Also proves that Hadamard equivalence
  preserves the Hadamard property.
-/
import Algebra.Hadamard.Defs

open Matrix Finset BigOperators

/-! ## Sign-flipping preserves Hadamard property -/

/-
Flipping the sign of row i (multiplying all entries in row i by -1)
    preserves the Hadamard property.
-/
theorem IsHadamard.neg_row {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (i₀ : Fin n) :
    IsHadamard (fun i j => if i = i₀ then -H i j else H i j) := by
  constructor;
  · intro i j; specialize hH; have := hH.1 i j; aesop;
  · rcases hH with ⟨ h₁, h₂ ⟩;
    ext i j; by_cases hi : i = i₀ <;> by_cases hj : j = i₀ <;> simp +decide [ *, Matrix.mul_apply ] ;
    · replace h₂ := congr_fun ( congr_fun h₂ i₀ ) i₀; simp_all +decide [ Matrix.mul_apply, Matrix.one_apply ] ;
    · replace h₂ := congr_fun ( congr_fun h₂ i₀ ) j; simp_all +decide [ Matrix.mul_apply, Matrix.one_apply ] ;
      grind +qlia;
    · replace h₂ := congr_fun ( congr_fun h₂ i ) i₀; simp_all +decide [ Matrix.mul_apply ] ;
    · simpa [ Matrix.mul_apply, Matrix.one_apply ] using congr_fun ( congr_fun h₂ i ) j

/-
Flipping the sign of column j (multiplying all entries in column j by -1)
    preserves the Hadamard property.
-/
theorem IsHadamard.neg_col {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (j₀ : Fin n) :
    IsHadamard (fun i j => if j = j₀ then -H i j else H i j) := by
  constructor;
  · intro i j; specialize hH; rcases hH.1 i j with ha | ha <;> by_cases hj : j = j₀ <;> simp +decide [ * ] ;
    · grind;
    · grind;
  · convert hH.2 using 1;
    ext i j; simp +decide [ Matrix.mul_apply, Finset.sum_ite ] ;
    simp +decide [ Finset.filter_eq', Finset.filter_ne' ]

/-! ## Normalization existence -/

/-
Every Hadamard matrix is equivalent to a normalized one (first row and column all 1s).
-/
theorem exists_normalized_of_isHadamard {n : ℕ} [NeZero n]
    {H : Matrix (Fin n) (Fin n) ℤ} (hH : IsHadamard H) :
    ∃ H' : Matrix (Fin n) (Fin n) ℤ, IsNormalizedHadamard H' := by
  -- Define H' i j = H 0 0 * H i 0 * H 0 j * H i j.
  use fun i j => H 0 0 * H i 0 * H 0 j * H i j;
  have hH' : IsHadamard (fun i j => H 0 0 * H i 0 * H 0 j * H i j) := by
    constructor;
    · intro i j; rcases hH.1 0 0 with ha | ha <;> rcases hH.1 i 0 with hb | hb <;> rcases hH.1 0 j with hc | hc <;> rcases hH.1 i j with hd | hd <;> norm_num [ ha, hb, hc, hd ] ;
    · ext i j; simp +decide [ Matrix.mul_apply, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, mul_comm ] ;
      convert congr_arg ( fun x : ℤ => x * ( H i 0 * H j 0 * H 0 0 * H 0 0 ) ) ( congr_fun ( congr_fun hH.2 i ) j ) using 1 <;> ring;
      · simp +decide [ Matrix.mul_apply, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
        exact Finset.sum_congr rfl fun x _ => by rw [ show H 0 x ^ 2 = 1 by exact hH.1 0 x |> Or.rec ( fun h => by rw [ h ] ; norm_num ) fun h => by rw [ h ] ; norm_num ] ; ring;
      · have := hH.1 i 0; have := hH.1 j 0; have := hH.1 0 0; norm_num at *; rcases this with ( h | h ) <;> rcases this with ( h' | h' ) <;> rcases this with ( h'' | h'' ) <;> simp_all +decide ;
        · have := hH.2; replace := congr_fun ( congr_fun this i ) 0; simp_all +decide [ Matrix.mul_apply ] ;
          simp_all +decide [ Matrix.one_apply ];
          grind;
        · have := hH.2; replace := congr_fun ( congr_fun this i ) j; simp_all +decide [ Matrix.mul_apply, Finset.sum_ite ] ;
          by_cases hij : i = j <;> simp_all +decide [ Matrix.one_apply ];
        · have := hH.2; replace := congr_fun ( congr_fun this i ) j; simp_all +decide [ Matrix.mul_apply, Finset.sum_ite ] ;
          by_cases hij : i = j <;> simp_all +decide [ Matrix.one_apply ];
        · have := hH.2; replace := congr_fun ( congr_fun this i ) j; simp_all +decide [ Matrix.mul_apply, Finset.sum_ite ] ;
          by_cases hij : i = j <;> simp_all +decide [ Matrix.one_apply ];
  exact ⟨ hH', fun j => by cases hH.1 0 0 <;> cases hH.1 0 j <;> simp +decide [ * ], fun i => by cases hH.1 0 0 <;> cases hH.1 i 0 <;> simp +decide [ * ] ⟩

/-! ## Equivalence preserves Hadamard property -/

/-
Hadamard equivalence preserves the Hadamard property.
-/
theorem hadamard_equiv_preserves {n : ℕ}
    {H K : Matrix (Fin n) (Fin n) ℤ}
    (heq : HadamardEquivalent H K) :
    IsHadamard H → IsHadamard K := by
  obtain ⟨ σ, τ, d₁, d₂, hd₁, hd₂, h ⟩ := heq;
  intro hHard;
  constructor;
  · intro i j; specialize h i j; rcases hd₁ i with ha | ha <;> rcases hd₂ j with hb | hb <;> rcases hHard.1 ( σ i ) ( τ j ) with hc | hc <;> rw [ h, ha, hb, hc ] <;> norm_num;
  · -- By definition of matrix multiplication and the properties of Hadamard matrices, we can expand the product K * Kᵀ.
    have h_expand : ∀ i j, (K * Kᵀ) i j = ∑ k, (d₁ i * H (σ i) (τ k) * d₂ k) * (d₁ j * H (σ j) (τ k) * d₂ k) := by
      simp +decide [ h, Matrix.mul_apply ];
    -- Since $d₂ k^2 = 1$ for all $k$, we can simplify the expression.
    have h_simplify : ∀ i j, (K * Kᵀ) i j = d₁ i * d₁ j * ∑ k, H (σ i) k * H (σ j) k := by
      intro i j; rw [ h_expand i j ] ; rw [ Finset.mul_sum _ _ _ ] ; refine' Finset.sum_bij ( fun x _ => τ x ) _ _ _ _ <;> simp +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
      · exact τ.surjective;
      · intro a; specialize hd₂ a; rcases hd₂ with ( hd₂ | hd₂ ) <;> norm_num [ hd₂ ] ;
    -- Since $H$ is a Hadamard matrix, we know that $\sum_{k} H (σ i) k * H (σ j) k = n$ if $i = j$ and $0$ otherwise.
    have h_orthogonal : ∀ i j, ∑ k, H (σ i) k * H (σ j) k = if i = j then n else 0 := by
      intro i j; split_ifs <;> simp_all +decide [ IsHadamard.row_dot_self, IsHadamard.row_orthogonal ] ;
    ext i j; by_cases hij : i = j <;> simp +decide [ hij, h_simplify, h_orthogonal ] ;
    cases hd₁ j <;> simp +decide [ * ]

/-- Hadamard equivalence is reflexive. -/
theorem HadamardEquivalent.refl {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) :
    HadamardEquivalent H H := by
  exact ⟨Equiv.refl _, Equiv.refl _, fun _ => 1, fun _ => 1,
    fun _ => Or.inl rfl, fun _ => Or.inl rfl, fun i j => by simp⟩