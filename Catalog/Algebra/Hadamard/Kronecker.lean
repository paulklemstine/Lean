/-
  # Kronecker Product Closure for Hadamard Matrices

  The tensor (Kronecker) product of two Hadamard matrices is Hadamard.
  This gives a multiplicative semigroup structure on Hadamard orders.
-/
import Algebra.Hadamard.Basic

open Matrix Finset BigOperators

/-! ## Kronecker product of Hadamard matrices -/

/-
The Kronecker product of two Hadamard matrices is Hadamard.
-/
theorem IsHadamard.kronecker
    {m n : ℕ}
    {A : Matrix (Fin m) (Fin m) ℤ}
    {B : Matrix (Fin n) (Fin n) ℤ}
    (hA : IsHadamard A)
    (hB : IsHadamard B) :
    IsHadamard ((A.kroneckerMap (· * ·) B).submatrix
      finProdFinEquiv.symm finProdFinEquiv.symm) := by
        refine' ⟨ _, _ ⟩;
        · intro i j; have := hA.1 ( finProdFinEquiv.symm i |>.1 ) ( finProdFinEquiv.symm j |>.1 ) ; have := hB.1 ( finProdFinEquiv.symm i |>.2 ) ( finProdFinEquiv.symm j |>.2 ) ; aesop;
        · have h_kronecker : (kroneckerMap (fun x1 x2 => x1 * x2) A B) * (kroneckerMap (fun x1 x2 => x1 * x2) A B).transpose = (m * n : ℤ) • 1 := by
            have h_kronecker : (kroneckerMap (fun x1 x2 => x1 * x2) A B) * (kroneckerMap (fun x1 x2 => x1 * x2) A B).transpose = kroneckerMap (fun x1 x2 => x1 * x2) (A * A.transpose) (B * B.transpose) := by
              grind +suggestions;
            have := hA.2; have := hB.2; aesop;
          convert congr_arg ( fun M => M.submatrix ( finProdFinEquiv.symm ) ( finProdFinEquiv.symm ) ) h_kronecker using 1;
          · ext i j; simp +decide [ Matrix.mul_apply, Matrix.submatrix_apply ] ;
            refine' Finset.sum_bij ( fun x _ => ( x.divNat, x.modNat ) ) _ _ _ _ <;> simp +decide [ Fin.ext_iff ];
            · exact fun a₁ a₂ h₁ h₂ => by nlinarith [ Nat.mod_add_div a₁ n, Nat.mod_add_div a₂ n ] ;
            · intro a b; use ⟨ a * n + b, by nlinarith [ Fin.is_lt a, Fin.is_lt b ] ⟩ ; simp +decide [ Nat.add_mod, Nat.mod_eq_of_lt ] ;
              rw [ Nat.add_div ] <;> norm_num [ Nat.div_eq_of_lt, Fin.is_lt ];
              · cases n <;> simp_all +decide [ Nat.div_eq_of_lt, Nat.mod_eq_of_lt ];
                · exact Fin.elim0 b;
                · exact Nat.le_of_lt_succ ( Nat.mod_lt _ ( Nat.succ_pos _ ) );
              · exact Fin.pos b;
          · ext i j; simp +decide [ Matrix.smul_eq_diagonal_mul ] ;
            by_cases hij : i = j <;> simp +decide [ hij, Matrix.one_apply ];
            rw [ diagonal_apply ] ; contrapose! hij ; simp_all +decide [ Fin.ext_iff, Fin.divNat, Fin.modNat ];
            rw [ ← Nat.div_add_mod i n, ← Nat.div_add_mod j n, hij.1, hij.2.1 ]

/-
The product of two Hadamard orders is a Hadamard order.
-/
theorem hadamardOrder_mul
    {m n : ℕ}
    (hm : HadamardOrder m)
    (hn : HadamardOrder n) :
    HadamardOrder (m * n) := by
      -- By definition of HadamardOrder, there exist matrices A and B such that A is an m×m Hadamard matrix and B is an n×n Hadamard matrix.
      obtain ⟨A, hA⟩ := hm
      obtain ⟨B, hB⟩ := hn;
      -- By definition of HadamardOrder, there exist matrices A and B such that A is an m×m Hadamard matrix and B is an n×n Hadamard matrix. We can form their Kronecker product C = A.kroneckerMap (·*·) B, which is an (m×n)×(m×n) matrix.
      set C := (A.kroneckerMap (·*·) B).submatrix (finProdFinEquiv.symm) (finProdFinEquiv.symm) with hC_def;
      -- We need to show that C is a Hadamard matrix. We'll use the fact that the Kronecker product of two Hadamard matrices is Hadamard.
      have hC : IsHadamard C := by
        convert IsHadamard.kronecker hA hB using 1;
      exact ⟨ C, hC ⟩