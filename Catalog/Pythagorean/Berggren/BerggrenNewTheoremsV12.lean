/-! # CatalogBuild.Pythagorean.Berggren.BerggrenNewTheoremsV12

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 19
-/

import Mathlib

/-- [Section: ## Matrix Definitions] -/
def BN₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenNewTheoremsV12
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 19] -/
def BN₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]


def BN₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]



/-- Closed-form formula for B₁ⁿ -/
def BN₁_pow_closed (n : ℕ) : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -(2 * ↑n), 2 * ↑n;
     2 * ↑n, 1 - 2 * (↑n : ℤ)^2, 2 * (↑n : ℤ)^2;
     2 * ↑n, -(2 * (↑n : ℤ)^2), 1 + 2 * (↑n : ℤ)^2]



/-- [Section: ## Closed-Form Matrix for B₁ⁿ
B₁ⁿ entries are polynomial in n:
(0,0)=1      (0,1)=-2n      (0,2)=2n
(1,0)=2n     (1,1)=1-2n²    (1,2)=2n²
(2,0)=2n     (2,1)=-2n²     (2,2)=1+2n²] -/
theorem BN₁_pow_eq_closed (n : ℕ) : BN₁ ^ n = BN₁_pow_closed n := by
  induction' n with n ih;
  · native_decide +revert;
  · simp_all +decide [ pow_succ, BN₁_pow_closed ];
    simp +decide [ BN₁, Matrix.vecMul ] ; ring_nf ; aesop;



/-- [Section: ## Determinant formulas for ALL n] -/
theorem det_BN₁_pow (n : ℕ) : Matrix.det (BN₁ ^ n) = 1 := by
  induction n <;> simp_all +decide [ pow_succ, Matrix.det_fin_three ]



theorem det_BN₂_pow (n : ℕ) : Matrix.det (BN₂ ^ n) = (-1) ^ n := by
  induction n <;> simp_all +decide [ pow_succ, Matrix.det_fin_three ];
  simp_all +decide [ BN₂ ]



theorem det_BN₃_pow (n : ℕ) : Matrix.det (BN₃ ^ n) = 1 := by
  induction n <;> simp_all +decide [ pow_succ' ]



/-- [Section: ## Infinite order] -/
theorem BN₁_infinite_order (n : ℕ) (hn : 0 < n) : BN₁ ^ n ≠ 1 := by
  -- By definition of $BN₁_pow_closed$, we know that its (0,1) entry is $-2n$.
  have h_entry : (BN₁_pow_closed n) 0 1 = -2 * n := by
    exact?;
  rw [ BN₁_pow_eq_closed ];
  exact ne_of_apply_ne ( fun m => m 0 1 ) ( by norm_num; linarith )



theorem BN₃_infinite_order (n : ℕ) (hn : 0 < n) : BN₃ ^ n ≠ 1 := by
  -- By induction on $n$, we can show that the $(0,1)$ entry of $BN₃^n$ is $2n$.
  have h_entry : ∀ n : ℕ, (BN₃ ^ n) 0 1 = 2 * n := by
    intro n;
    induction n <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
    simp_all +decide [ Fin.sum_univ_succ, BN₃ ];
    rename_i k hk;
    have h_ind : ∀ k : ℕ, (Matrix.of ![![(-1 : ℤ), 2, 2], ![-2, 1, 2], ![-2, 2, 3]] ^ k) 0 0 + (Matrix.of ![![(-1 : ℤ), 2, 2], ![-2, 1, 2], ![-2, 2, 3]] ^ k) 0 2 = 1 := by
      intro k; induction k <;> simp_all +decide [ pow_succ, Matrix.mul_apply ] ;
      norm_num [ Fin.sum_univ_succ ] at * ; linarith!;
    linarith [ h_ind k ];
  exact ne_of_apply_ne ( fun m => m 0 1 ) ( by simp +decide [ h_entry, hn.ne' ] )



theorem BN₂_infinite_order (n : ℕ) (hn : 0 < n) : BN₂ ^ n ≠ 1 := by
  -- By induction, we can show that the (0,2) entry of BN₂^n is always positive.
  have h_pos : ∀ n > 0, 0 < (BN₂ ^ n) 0 2 := by
    intro n hn; induction hn <;> simp_all +decide [ pow_succ', Matrix.mul_apply ] ;
    simp_all +decide [ Fin.sum_univ_three, BN₂ ];
    -- By definition of matrix multiplication and the properties of the matrix BN₂, we know that all entries of BN₂^m are non-negative.
    have h_nonneg : ∀ m : ℕ, ∀ i j : Fin 3, 0 ≤ (BN₂ ^ m) i j := by
      intro m i j; induction' m with m ih generalizing i j <;> simp_all +decide [ pow_succ', Matrix.mul_apply ] ;
      · fin_cases i <;> fin_cases j <;> norm_num;
      · exact Finset.sum_nonneg fun k _ => mul_nonneg ( by fin_cases i <;> fin_cases k <;> trivial ) ( ih _ _ );
    exact add_pos_of_pos_of_nonneg ( add_pos_of_pos_of_nonneg ‹_› ( mul_nonneg zero_le_two ( h_nonneg _ _ _ ) ) ) ( mul_nonneg zero_le_two ( h_nonneg _ _ _ ) );
  exact fun h => by simpa [ h ] using h_pos n hn;



/-- Pell sequence -/
def pellN : ℕ → ℤ
  | 0 => 1
  | 1 => 2
  | n + 2 => 2 * pellN (n + 1) + pellN n



/-- [Section: ## Pell Sequence Properties] -/
theorem pell_sq_sum_recurrence (n : ℕ) :
    pellN (n + 2) ^ 2 + pellN (n + 3) ^ 2 =
    6 * (pellN (n + 1) ^ 2 + pellN (n + 2) ^ 2) -
    (pellN n ^ 2 + pellN (n + 1) ^ 2) := by
  erw [ show pellN ( n + 3 ) = 2 * pellN ( n + 2 ) + pellN ( n + 1 ) from rfl, show pellN ( n + 2 ) = 2 * pellN ( n + 1 ) + pellN n from rfl ] ; ring



/-- [Section: ## Lorentz form preservation for all n] -/
def QN : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]



theorem BN₁_lorentz : BN₁ᵀ * QN * BN₁ = QN := by native_decide



theorem BN₁_pow_lorentz (n : ℕ) : (BN₁ ^ n)ᵀ * QN * (BN₁ ^ n) = QN := by
  induction n <;> simp_all +decide [ pow_succ', Matrix.mul_assoc ];
  simp_all +decide [ ← Matrix.mul_assoc, BN₁_lorentz ]



theorem BN₂_pow_lorentz (n : ℕ) : (BN₂ ^ n)ᵀ * QN * (BN₂ ^ n) = QN := by
  induction n <;> simp_all +decide [ pow_succ, ← mul_assoc ];
  simp_all +decide [ mul_assoc ]



/-- [Section: ## C-branch odd legs mod 4] -/
theorem C_odd_leg_mod4 (n : ℕ) :
    ((2 * (↑n : ℤ) + 1) * (2 * ↑n + 3)) % 4 = 3 := by
  ring_nf; norm_num [ Int.add_emod, Int.mul_emod ] ;



/-- [Section: ## Verification] -/
theorem BN₁_pow_closed_check :
    BN₁_pow_closed 0 = 1 ∧
    BN₁_pow_closed 1 = BN₁ ∧
    BN₁_pow_closed 2 = !![1, (-4 : ℤ), 4; 4, -7, 8; 4, -8, 9] := by
  constructor
  · ext i j; fin_cases i <;> fin_cases j <;> simp [BN₁_pow_closed]
  constructor
  · ext i j; fin_cases i <;> fin_cases j <;> simp [BN₁_pow_closed, BN₁]
  · ext i j; fin_cases i <;> fin_cases j <;> simp [BN₁_pow_closed]

