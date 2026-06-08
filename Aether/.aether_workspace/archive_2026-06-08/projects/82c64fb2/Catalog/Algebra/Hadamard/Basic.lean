/-
  # Hadamard Matrix Theory — Core Definitions and Basic Lemmas

  This file establishes the foundational definitions for Hadamard matrix theory:
  - `IsHadamard`: a ±1 matrix H such that H * Hᵀ = n • I
  - `IsNormalizedHadamard`: a Hadamard matrix with first row and column all 1s
  - `HadamardOrder`: existence predicate on orders
  - Basic algebraic consequences (entry squares, dot products, transpose)
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Core Definitions -/

/-- A matrix is Hadamard if all entries are ±1 and H * Hᵀ = n • I. -/
def IsHadamard {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- A normalized Hadamard matrix has first row and column all 1s. -/
def IsNormalizedHadamard {n : ℕ} [NeZero n] (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  IsHadamard H ∧
  (∀ i, H 0 i = 1) ∧
  (∀ i, H i 0 = 1)

/-- An order n admits a Hadamard matrix. -/
def HadamardOrder (n : ℕ) : Prop :=
  ∃ H : Matrix (Fin n) (Fin n) ℤ, IsHadamard H

/-! ## Entry-level consequences -/

/-
Every entry of a Hadamard matrix squares to 1.
-/
theorem IsHadamard.entries_sq_eq_one
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) :
    ∀ i j, H i j ^ 2 = 1 := by
      exact fun i j => by rcases hH.1 i j with h | h <;> rw [ h ] <;> norm_num;

/-
The absolute value of every entry of a Hadamard matrix is 1.
-/
theorem IsHadamard.entries_abs_eq_one
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) :
    ∀ i j, |H i j| = 1 := by
      exact fun i j => by rcases hH.1 i j with h | h <;> rw [ h ] <;> norm_num;

/-! ## Dot-product characterization -/

/-
Each row of a Hadamard matrix has self-dot-product equal to n.
-/
theorem IsHadamard.row_dot_self
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) :
    ∀ i, dotProduct (H i) (H i) = (n : ℤ) := by
      intro i; have := hH.2; replace := congr_arg ( fun m => m i i ) this; simp_all +decide [ Matrix.mul_apply, dotProduct ] ;

/-
Distinct rows of a Hadamard matrix are orthogonal.
-/
theorem IsHadamard.row_dot_ne_zero
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H)
    (i j : Fin n) (hij : i ≠ j) :
    dotProduct (H i) (H j) = 0 := by
      convert congr_arg ( fun m : Matrix ( Fin n ) ( Fin n ) ℤ => m i j ) hH.2 using 1;
      simp +decide [ hij, Matrix.smul_eq_diagonal_mul ]

/-! ## Transpose -/

/-
The transpose of a Hadamard matrix is Hadamard.
-/
theorem IsHadamard.transpose
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) :
    IsHadamard H.transpose := by
      refine' ⟨ _, _ ⟩;
      · exact fun i j => hH.1 j i;
      · have h_inv : Invertible (Matrix.map H (fun x => x : ℤ → ℚ)) := by
          convert Matrix.invertibleOfDetInvertible _;
          have h_det : (Matrix.map H (fun x => x : ℤ → ℚ)) * (Matrix.map H (fun x => x : ℤ → ℚ)).transpose = (n : ℚ) • 1 := by
            ext i j; have := congr_fun ( congr_fun hH.2 i ) j; simp_all +decide [ Matrix.mul_apply ] ;
            norm_cast;
            simp_all +decide [ Matrix.one_apply ];
          convert invertibleOfNonzero _;
          intro h; have := congr_arg Matrix.det h_det; norm_num [ h ] at this;
          cases n <;> norm_num at *;
          exact absurd this ( by positivity );
        -- Since $H$ is invertible, we have $H^T * H = n * I$.
        have h_transpose_mul : (H.map (fun x => x : ℤ → ℚ)).transpose * (H.map (fun x => x : ℤ → ℚ)) = (n : ℚ) • 1 := by
          have h_transpose_mul : (H.map (fun x => x : ℤ → ℚ)) * (H.map (fun x => x : ℤ → ℚ)).transpose = (n : ℚ) • 1 := by
            have := congr_arg ( fun m => m.map ( fun x : ℤ => ( x : ℚ ) ) ) hH.2; simp_all +decide [ ← Matrix.ext_iff ] ;
            simp_all +decide [ Matrix.mul_apply, Matrix.one_apply ];
            intro i j; specialize this i j; norm_cast; aesop;
          convert congr_arg ( fun x => ( H.map fun x : ℤ => ( x : ℚ ) ) ⁻¹ * x * ( H.map fun x : ℤ => ( x : ℚ ) ) ) h_transpose_mul using 1 <;> norm_num [ mul_assoc ];
        rw [ ← Matrix.ext_iff ] at *;
        simp_all +decide [ Matrix.mul_apply, Matrix.smul_eq_diagonal_mul ];
        simp_all +decide [ Matrix.one_apply ];
        exact_mod_cast h_transpose_mul

/-! ## Equivalence operations -/

/-
Permuting rows and columns of a Hadamard matrix gives a Hadamard matrix.
-/
theorem IsHadamard.submatrix
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (σ τ : Equiv.Perm (Fin n))
    (hH : IsHadamard H) :
    IsHadamard (H.submatrix σ τ) := by
      constructor;
      · exact fun i j => hH.1 _ _;
      · convert congr_arg ( fun m => m.submatrix σ σ ) hH.2 using 1;
        · ext i j; simp +decide [ Matrix.mul_apply, Matrix.submatrix_apply ] ;
          conv_rhs => rw [ ← Equiv.sum_comp τ ] ;
        · ext i j; simp +decide [ Matrix.smul_eq_diagonal_mul ] ;
          by_cases hij : i = j <;> aesop

/-! ## Trivial orders -/

/-
Order 1 is a Hadamard order.
-/
theorem hadamardOrder_one : HadamardOrder 1 := by
  -- For order 1, the matrix [1] itself is a Hadamard matrix. We can verify that it satisfies the conditions.
  use 1
  simp [IsHadamard]

/-
Order 2 is a Hadamard order.
-/
theorem hadamardOrder_two : HadamardOrder 2 := by
  exists !![1, 1; 1, -1]

/-! ## Necessary condition: 4 | n for n > 2 -/

/-
If n > 2 admits a Hadamard matrix, then 4 ∣ n.
-/
theorem four_dvd_of_hadamardOrder
    {n : ℕ}
    (hn : HadamardOrder n)
    (hgt : 2 < n) :
    4 ∣ n := by
      obtain ⟨ H, hH ⟩ := hn;
      -- Since H is Hadamard, we have H * Hᵀ = n • I. Let's denote the first three rows of H as r1, r2, and r3.
      obtain ⟨r1, r2, r3, hr1, hr2, hr3, hr1r2, hr1r3, hr2r3⟩ : ∃ r1 r2 r3 : Fin n → ℤ, (∀ i, r1 i = 1 ∨ r1 i = -1) ∧ (∀ i, r2 i = 1 ∨ r2 i = -1) ∧ (∀ i, r3 i = 1 ∨ r3 i = -1) ∧ (∑ i, r1 i * r2 i = 0) ∧ (∑ i, r1 i * r3 i = 0) ∧ (∑ i, r2 i * r3 i = 0) ∧ (∑ i, r1 i ^ 2 = n) ∧ (∑ i, r2 i ^ 2 = n) ∧ (∑ i, r3 i ^ 2 = n) := by
        obtain ⟨r1, r2, r3, hr1, hr2, hr3, hr1r2, hr1r3, hr2r3⟩ : ∃ r1 r2 r3 : Fin n → ℤ, (∀ i, r1 i = 1 ∨ r1 i = -1) ∧ (∀ i, r2 i = 1 ∨ r2 i = -1) ∧ (∀ i, r3 i = 1 ∨ r3 i = -1) ∧ (∑ i, r1 i * r2 i = 0) ∧ (∑ i, r1 i * r3 i = 0) ∧ (∑ i, r2 i * r3 i = 0) := by
          use H ⟨0, by linarith⟩, H ⟨1, by linarith⟩, H ⟨2, by linarith⟩;
          exact ⟨ fun i => hH.1 _ _, fun i => hH.1 _ _, fun i => hH.1 _ _, by simpa [ Matrix.mul_apply ] using congr_fun ( congr_fun hH.2 ⟨ 0, by linarith ⟩ ) ⟨ 1, by linarith ⟩, by simpa [ Matrix.mul_apply ] using congr_fun ( congr_fun hH.2 ⟨ 0, by linarith ⟩ ) ⟨ 2, by linarith ⟩, by simpa [ Matrix.mul_apply ] using congr_fun ( congr_fun hH.2 ⟨ 1, by linarith ⟩ ) ⟨ 2, by linarith ⟩ ⟩;
        exact ⟨ r1, r2, r3, hr1, hr2, hr3, hr1r2, hr1r3, hr2r3, by rw [ Finset.sum_congr rfl fun i _ => by rcases hr1 i with ( h | h ) <;> rw [ h ] ; norm_num ] ; norm_num, by rw [ Finset.sum_congr rfl fun i _ => by rcases hr2 i with ( h | h ) <;> rw [ h ] ; norm_num ] ; norm_num, by rw [ Finset.sum_congr rfl fun i _ => by rcases hr3 i with ( h | h ) <;> rw [ h ] ; norm_num ] ; norm_num ⟩;
      -- Let's denote the number of columns where r1, r2, and r3 have the same sign as a, and where they have different signs as b.
      set a := ∑ i, (1 + r1 i * r2 i) * (1 + r1 i * r3 i) / 4
      set b := ∑ i, (1 + r1 i * r2 i) * (1 - r1 i * r3 i) / 4
      set c := ∑ i, (1 - r1 i * r2 i) * (1 + r1 i * r3 i) / 4
      set d := ∑ i, (1 - r1 i * r2 i) * (1 - r1 i * r3 i) / 4;
      have h_eq : a + b + c + d = n ∧ a + b = n / 2 ∧ a + c = n / 2 ∧ a - b - c + d = 0 := by
        have h_sum : ∑ i, (1 + r1 i * r2 i) * (1 + r1 i * r3 i) / 4 + ∑ i, (1 + r1 i * r2 i) * (1 - r1 i * r3 i) / 4 + ∑ i, (1 - r1 i * r2 i) * (1 + r1 i * r3 i) / 4 + ∑ i, (1 - r1 i * r2 i) * (1 - r1 i * r3 i) / 4 = n := by
          rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ];
          rw [ Finset.sum_congr rfl fun i _ => ?_ ];
          rotate_left;
          use fun i => 1;
          · rcases hr1 i with ha | ha <;> rcases hr2 i with hb | hb <;> rcases hr3 i with hc | hc <;> norm_num [ ha, hb, hc ];
          · norm_num
        have h_sum2 : ∑ i, (1 + r1 i * r2 i) * (1 + r1 i * r3 i) / 4 + ∑ i, (1 + r1 i * r2 i) * (1 - r1 i * r3 i) / 4 = n / 2 := by
          have h_sum2 : ∑ i, (1 + r1 i * r2 i) * (1 + r1 i * r3 i) / 4 + ∑ i, (1 + r1 i * r2 i) * (1 - r1 i * r3 i) / 4 = ∑ i, (1 + r1 i * r2 i) / 2 := by
            rw [ ← Finset.sum_add_distrib ];
            refine' Finset.sum_congr rfl fun i _ => _;
            rcases hr1 i with ha | ha <;> rcases hr2 i with hb | hb <;> rcases hr3 i with hc | hc <;> norm_num [ ha, hb, hc ];
          have h_sum2 : ∑ i, (1 + r1 i * r2 i) / 2 = (∑ i, (1 + r1 i * r2 i)) / 2 := by
            rw [ Int.ediv_eq_of_eq_mul_left ] <;> norm_num;
            rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_congr rfl fun i hi => by rcases hr1 i with ha | ha <;> rcases hr2 i with hb | hb <;> rw [ ha, hb ] <;> norm_num;
          simp_all +decide [ Finset.sum_add_distrib ]
        have h_sum3 : ∑ i, (1 + r1 i * r2 i) * (1 + r1 i * r3 i) / 4 + ∑ i, (1 - r1 i * r2 i) * (1 + r1 i * r3 i) / 4 = n / 2 := by
          have h_sum3 : ∑ i, (1 + r1 i * r2 i) * (1 + r1 i * r3 i) / 4 + ∑ i, (1 - r1 i * r2 i) * (1 + r1 i * r3 i) / 4 = ∑ i, (1 + r1 i * r3 i) / 2 := by
            rw [ ← Finset.sum_add_distrib ] ; congr ; ext i ; rcases hr1 i with ha | ha <;> rcases hr2 i with hb | hb <;> rcases hr3 i with hc | hc <;> norm_num [ ha, hb, hc ] ;
          have h_sum3 : ∑ i, (1 + r1 i * r3 i) / 2 = (∑ i, (1 + r1 i * r3 i)) / 2 := by
            rw [ Int.ediv_eq_of_eq_mul_left ] <;> norm_num;
            rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_congr rfl fun i hi => by rcases hr1 i with ha | ha <;> rcases hr3 i with hb | hb <;> rw [ ha, hb ] <;> norm_num;
          simp_all +decide [ Finset.sum_add_distrib ]
        have h_sum4 : ∑ i, (1 + r1 i * r2 i) * (1 + r1 i * r3 i) / 4 - ∑ i, (1 + r1 i * r2 i) * (1 - r1 i * r3 i) / 4 - ∑ i, (1 - r1 i * r2 i) * (1 + r1 i * r3 i) / 4 + ∑ i, (1 - r1 i * r2 i) * (1 - r1 i * r3 i) / 4 = 0 := by
          rw [ ← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib ];
          convert hr2r3.1 using 2 ; ring;
          rcases hr1 ‹_› with ha | ha <;> rcases hr2 ‹_› with hb | hb <;> rcases hr3 ‹_› with hc | hc <;> rw [ ha, hb, hc ] <;> norm_num
        exact ⟨ h_sum, h_sum2, h_sum3, h_sum4 ⟩;
      exact Int.natCast_dvd_natCast.mp ( show 4 ∣ ( n : ℤ ) from by omega )