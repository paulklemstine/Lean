/-
  # Hadamard Matrices and Coding Theory

  This file establishes the bridge between Hadamard matrices and binary codes:
  - Sign-to-bit conversion
  - Hamming distance for ±1 vectors via dot products
  - The fundamental identity: dot(x,y) = n - 2 * d_H(x,y) for sign vectors
  - Hadamard rows form equidistant codes with distance n/2
  - Row sum properties of Hadamard matrices
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Core Hadamard definition (self-contained) -/

def IsHadamardC {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-! ## Sign vectors and disagreement counting -/

/-- Whether a ±1 vector has value -1 at index k (for conversion to binary). -/
def signToBit (x : ℤ) : ℕ := if x = 1 then 0 else 1

/-- Count of positions where two ±1 vectors disagree. -/
def signDisagree {n : ℕ} (x y : Fin n → ℤ) : ℕ :=
  (Finset.univ.filter fun k => x k ≠ y k).card

/-- Count of positions where two ±1 vectors agree. -/
def signAgree {n : ℕ} (x y : Fin n → ℤ) : ℕ :=
  (Finset.univ.filter fun k => x k = y k).card

/-! ## The fundamental dot product / Hamming distance identity -/

/-
For ±1 vectors, agree + disagree = n.
-/
theorem agree_add_disagree {n : ℕ} (x y : Fin n → ℤ)
    (hx : ∀ k, x k = 1 ∨ x k = -1) (hy : ∀ k, y k = 1 ∨ y k = -1) :
    signAgree x y + signDisagree x y = n := by
      convert Finset.card_add_card_compl ( Finset.filter ( fun k => x k = y k ) Finset.univ );
      · exact congr_arg Finset.card ( by ext; aesop );
      · norm_num

/-
For ±1 vectors, the dot product equals agree - disagree.
-/
theorem dot_eq_agree_sub_disagree {n : ℕ} (x y : Fin n → ℤ)
    (hx : ∀ k, x k = 1 ∨ x k = -1) (hy : ∀ k, y k = 1 ∨ y k = -1) :
    ∑ k, x k * y k = (signAgree x y : ℤ) - (signDisagree x y : ℤ) := by
      convert Finset.sum_congr rfl fun i _ => show x i * y i = 1 - ( if x i = y i then 0 else 2 ) from ?_ using 1;
      · simp +decide [ signAgree, signDisagree, Finset.sum_ite ];
        simp +decide [ Finset.filter_not, Finset.card_sdiff ];
        rw [ Nat.cast_sub ( le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ] ; ring;
      · grind

/-
**Fundamental identity**: for ±1 vectors x, y of length n,
    dot(x, y) = n - 2 * disagree(x, y).
    This is the key bridge between linear algebra and Hamming distance.
-/
theorem dot_eq_n_sub_two_disagree {n : ℕ} (x y : Fin n → ℤ)
    (hx : ∀ k, x k = 1 ∨ x k = -1) (hy : ∀ k, y k = 1 ∨ y k = -1) :
    ∑ k, x k * y k = (n : ℤ) - 2 * (signDisagree x y : ℤ) := by
      convert dot_eq_agree_sub_disagree x y hx hy using 1 ; ring;
      linarith [ agree_add_disagree x y hx hy ]

/-! ## Hadamard rows are equidistant -/

/-
For a Hadamard matrix, distinct rows have dot product 0.
-/
theorem hadamard_row_orthogonal {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamardC H) (i j : Fin n) (hij : i ≠ j) :
    ∑ k, H i k * H j k = 0 := by
      simpa [ Matrix.mul_apply, hij ] using congr_arg ( fun m => m i j ) hH.2

/-
**Equidistant code theorem**: Distinct rows of a Hadamard matrix of order n
    disagree in exactly n/2 positions. Since Hamming distance equals disagreement
    count, this shows the rows form an equidistant code with distance n/2.

    This is the fundamental coding-theory consequence: Hadamard matrices
    produce optimal binary codes for communication.
-/
theorem hadamard_rows_equidistant {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamardC H) (i j : Fin n) (hij : i ≠ j) :
    signDisagree (fun k => H i k) (fun k => H j k) = n / 2 := by
      -- By the fundamental identity, we have that the dot product of two distinct rows of a Hadamard matrix is zero.
      have h_dot_zero : ∑ k, H i k * H j k = (n : ℤ) - 2 * (signDisagree (fun k => H i k) fun k => H j k : ℤ) := by
        exact dot_eq_n_sub_two_disagree _ _ ( fun k => hH.1 i k ) ( fun k => hH.1 j k );
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_two ( by linarith [ hadamard_row_orthogonal hH i j hij ] ) )

/-! ## Row self-dot-product -/

/-
Each row of a Hadamard matrix has self-dot-product equal to n.
-/
theorem hadamard_row_self_dot {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamardC H) (i : Fin n) :
    ∑ k, H i k * H i k = (n : ℤ) := by
      convert congr_arg ( fun x : Matrix ( Fin n ) ( Fin n ) ℤ => x i i ) hH.2 using 1;
      simp +decide [ Matrix.smul_eq_diagonal_mul ]

/-! ## Column orthogonality (transpose is Hadamard) -/

/-
Distinct columns of a Hadamard matrix are orthogonal.
-/
theorem hadamard_col_orthogonal {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamardC H) (j₁ j₂ : Fin n) (hj : j₁ ≠ j₂) :
    ∑ i, H i j₁ * H i j₂ = 0 := by
      convert congr_arg ( fun m : Matrix ( Fin n ) ( Fin n ) ℤ => m j₂ j₁ ) ( hH.2 ) using 1;
      · have h_inv : (H.map (fun x => x : ℤ → ℚ)) * (H.map (fun x => x : ℤ → ℚ)).transpose = (n : ℚ) • 1 := by
          ext i j; simp +decide [ Matrix.mul_apply, hH.2 ] ;
          convert congr_arg ( fun m : Matrix ( Fin n ) ( Fin n ) ℤ => m i j ) hH.2 using 1 ; norm_cast;
          simp +decide [ Matrix.mul_apply, Matrix.one_apply ];
          norm_cast;
        have h_inv : (H.map (fun x => x : ℤ → ℚ)).transpose * (H.map (fun x => x : ℤ → ℚ)) = (n : ℚ) • 1 := by
          have h_inv : Invertible (H.map (fun x => x : ℤ → ℚ)) := by
            convert Matrix.invertibleOfDetInvertible _;
            convert invertibleOfNonzero _;
            intro h; have := congr_arg Matrix.det h_inv; norm_num [ h ] at this;
            exact absurd this ( by norm_cast; exact ne_of_lt ( pow_pos ( Fin.pos j₁ ) _ ) );
          have h_inv : (H.map (fun x => x : ℤ → ℚ)).transpose * (H.map (fun x => x : ℤ → ℚ)) = (H.map (fun x => x : ℤ → ℚ))⁻¹ * ((H.map (fun x => x : ℤ → ℚ)) * (H.map (fun x => x : ℤ → ℚ)).transpose) * (H.map (fun x => x : ℤ → ℚ)) := by
            simp +decide [ mul_assoc, h_inv.2 ];
          simp_all +decide [ mul_assoc, Matrix.mul_nonsing_inv ];
        replace h_inv := congr_arg ( fun m => m j₂ j₁ ) h_inv ; simp_all +decide [ Matrix.mul_apply, mul_comm ] ;
        simp_all +decide [ Matrix.one_apply, eq_comm ];
        norm_cast at h_inv; have := congr_arg ( fun m : Matrix ( Fin n ) ( Fin n ) ℤ => m j₁ j₂ ) hH.2; simp_all +decide [ Matrix.mul_apply, mul_comm ] ;
        norm_num [ ← h_inv ];
      · simp +decide [ hj.symm ]