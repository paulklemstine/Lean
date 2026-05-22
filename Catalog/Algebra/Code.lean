/-
  # Hadamard Codes and Cross-Domain Theorems

  This file establishes the connection between Hadamard matrices and coding theory:
  - Defines the binary code associated to a Hadamard matrix
  - Proves that distinct rows of a Hadamard matrix yield codewords
    at Hamming distance exactly n/2
  - Proves the Walsh-Hadamard energy identity
-/
import Algebra.Hadamard.Defs

open Matrix Finset BigOperators

/-! ## Hamming distance -/

/-- Hamming distance between two functions to Bool. -/
noncomputable def hammingDistBool {n : ℕ} (f g : Fin n → Bool) : ℕ :=
  Finset.card (Finset.univ.filter fun i => f i ≠ g i)

/-! ## Hadamard code -/

/-- Convert a ±1 integer to a Bool: 1 ↦ false, -1 ↦ true. -/
def pmOneToBool (x : ℤ) : Bool := x == -1

/-- The binary code obtained from a Hadamard matrix by mapping 1 ↦ 0, -1 ↦ 1. -/
def hadamardCode {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) (i : Fin n) : Fin n → Bool :=
  fun j => pmOneToBool (H i j)

/-! ## Hadamard code distance theorem -/

/-- For a Hadamard matrix, the Hamming distance between the codes of distinct rows is n/2. -/
theorem hadamard_code_distance {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H)
    (i j : Fin n) (hij : i ≠ j) :
    hammingDistBool (hadamardCode H i) (hadamardCode H j) = n / 2 := by
  unfold hammingDistBool;
  have h_eq_iff : ∀ k, hadamardCode H i k ≠ hadamardCode H j k ↔ H i k * H j k = -1 := by
    intro k; cases hH.1 i k <;> cases hH.1 j k <;> simp +decide [ *, hadamardCode, pmOneToBool ] ;
  have h_card : ∑ k, (H i k * H j k) = ∑ k, (if H i k * H j k = -1 then -1 else 1) := by
    exact Finset.sum_congr rfl fun k _ => by rcases hH.1 i k with ha | ha <;> rcases hH.1 j k with hb | hb <;> rw [ ha, hb ] <;> norm_num;
  simp_all +decide [ Finset.sum_ite ];
  exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_two ( by have := hH.2; have := Finset.card_add_card_compl ( Finset.filter ( fun x => H i x * H j x = -1 ) Finset.univ ) ; norm_num at * ; linarith [ hH.row_orthogonal i j hij ] ) )

/-! ## Column orthogonality -/

/-
Column orthogonality of a Hadamard matrix: ∑ᵢ H i k * H i l = n * δ_{kl}.
    This follows from the row orthogonality of the transpose, which is also Hadamard.
-/
theorem IsHadamard.col_orthogonal {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (k l : Fin n) (hkl : k ≠ l) :
    ∑ i, H i k * H i l = 0 := by
  -- Construct the ℚ-valued matrix H_ℚ corresponding to H.
  let H_ℚ : Matrix (Fin n) (Fin n) ℚ := fun i j => (H i j : ℚ);
  -- From HHᵀ = nI, we get H_ℚ * H_ℚᵀ = n * I in ℚ.
  have hH_ℚ : H_ℚ * H_ℚ.transpose = (n : ℚ) • (1 : Matrix (Fin n) (Fin n) ℚ) := by
    convert congr_arg ( fun m : Matrix ( Fin n ) ( Fin n ) ℤ => fun i j => ( m i j : ℚ ) ) hH.2;
    · simp +decide [ H_ℚ, Matrix.mul_apply ];
    · simp +decide [ Matrix.one_apply ];
  -- Since H_ℚ is invertible, we can multiply both sides of H_ℚ * H_ℚᵀ = n * I by H_ℚ⁻¹ to get H_ℚᵀ * H_ℚ = n * I.
  have h_inv : H_ℚ.transpose * H_ℚ = (n : ℚ) • (1 : Matrix (Fin n) (Fin n) ℚ) := by
    rcases n with ( _ | n ) <;> simp_all +decide [ Matrix.mul_eq_one_comm ];
    have := Matrix.mul_eq_one_comm.mp ( show H_ℚ * ( ( n + 1 : ℚ ) ⁻¹ • H_ℚᵀ ) = 1 from ?_ );
    · convert congr_arg ( fun x => ( n + 1 : ℚ ) • x ) this using 1 <;> norm_num [ mul_assoc, smul_smul ];
      rw [ mul_inv_cancel₀ ( by positivity ), one_smul ];
    · convert congr_arg ( fun x => ( n + 1 : ℚ ) ⁻¹ • x ) hH_ℚ using 1 <;> norm_num [ mul_smul_comm ];
      rw [ smul_smul, inv_mul_cancel₀ ( by linarith ), one_smul ];
  replace h_inv := congr_fun ( congr_fun h_inv k ) l; simp_all +decide [ Matrix.mul_apply ] ;
  rw [ ← @Int.cast_inj ℚ ] ; aesop

/-
Column self-dot-product of a Hadamard matrix.
-/
theorem IsHadamard.col_dot_self {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (k : Fin n) :
    ∑ i, H i k * H i k = (n : ℤ) := by
  -- Since each entry of H is either 1 or -1, squaring each entry gives 1. Therefore, the sum of the squares of the entries in any column is just the sum of 1's, which is n.
  have h_sq : ∀ i, H i k * H i k = 1 := by
    exact fun i => by rcases hH.1 i k with h | h <;> rw [ h ] <;> norm_num;
  aesop

/-! ## Walsh-Hadamard Transform Energy Identity -/

/-
The Walsh-Hadamard energy identity: ‖H·x‖² = n·‖x‖² where norms are over ℤ.
-/
theorem hadamard_energy_identity {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (x : Fin n → ℤ) :
    ∑ i, (∑ k, H i k * x k) ^ 2 = n * ∑ k, x k ^ 2 := by
  -- Expand: ∑ᵢ (∑ₖ Hᵢₖ xₖ)² = ∑ᵢ ∑ₖ ∑ₗ Hᵢₖ xₖ Hᵢₗ xₗ
  -- Swap: = ∑ₖ ∑ₗ xₖ xₗ (∑ᵢ Hᵢₖ Hᵢₗ)
  -- By column orthogonality: ∑ᵢ Hᵢₖ Hᵢₗ = n δₖₗ
  -- Result: = ∑ₖ n xₖ² = n ∑ₖ xₖ²
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ i, (∑ k, H i k * x k) ^ 2 = ∑ k, ∑ l, (∑ i, H i k * H i l) * x k * x l := by
    simp +decide only [sq, Finset.sum_mul _ _ _, mul_sum, mul_left_comm, mul_comm];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) );
  -- By the properties of the Hadamard matrix, we know that $\sum_{i} H_{ik} H_{il} = n \delta_{kl}$.
  have h_hadamard : ∀ k l, (∑ i, H i k * H i l) = if k = l then (n : ℤ) else 0 := by
    intro k l; split_ifs with hkl <;> simp_all +decide [ IsHadamard.col_orthogonal, IsHadamard.col_dot_self ] ;
  simp_all +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, sq, mul_assoc, Finset.mul_sum _ _ _ ]

/-! ## Hadamard Excess -/

/-
The excess of a Hadamard matrix of order n satisfies σ(H)² ≤ n³.
    This follows from applying the energy identity to the all-ones vector.
-/
theorem hadamard_excess_sq_le {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) :
    hadamardExcess H ^ 2 ≤ (n : ℤ) ^ 3 := by
  -- Let $s_i = \sum_{j=0}^{n-1} H_{ij}$ for each $i$.
  set s : Fin n → ℤ := fun i => ∑ j, H i j
  have hs : (∑ i, s i) ^ 2 ≤ n * ∑ i, s i ^ 2 := by
    have h_cauchy_schwarz : ∀ (u v : Fin n → ℤ), (∑ i, u i * v i) ^ 2 ≤ (∑ i, u i ^ 2) * (∑ i, v i ^ 2) := by
      exact?;
    simpa using h_cauchy_schwarz 1 s;
  -- By the energy identity, we have $\sum_{i=0}^{n-1} s_i^2 = n^2$.
  have h_energy : ∑ i, s i ^ 2 = n ^ 2 := by
    convert hadamard_energy_identity hH ( fun _ => 1 ) using 1 ; norm_num ; ring;
    norm_num [ sq ];
  convert hs using 1 ; rw [ h_energy ] ; ring!