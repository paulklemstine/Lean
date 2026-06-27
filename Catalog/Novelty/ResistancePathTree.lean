import Mathlib

/-!
# Signed resistance determinant of trees: the path `Pₙ` (Graham–Pollak value)

On a **tree** the effective resistance between two vertices equals their graph distance
(unit resistors in series), so the resistance matrix of a tree *is* its distance matrix.
The Graham–Pollak theorem states that the distance-matrix determinant of **every** tree on
`n` vertices equals `(-1)^(n-1) (n-1) 2^(n-2)` — remarkably independent of the tree's shape.

Here we prove this for the path `Pₙ`, whose distance matrix is `D i j = |i - j|`.

## Main result
* `ResistancePath.det_Dpath` : `det D = (n - 1) · (-2)^(n-1) / 2` for `n ≥ 1`
  (equivalently `(-1)^(n-1) (n-1) 2^(n-2)`).

## Proof strategy (elementary row/column reduction to an arrowhead matrix)
Apply `Rᵢ ← Rᵢ - Rᵢ₋₁` (left-multiply by the unipotent lower-bidiagonal `L`) and then
`Cⱼ ← Cⱼ - Cⱼ₋₁` (right-multiply by the unipotent upper-bidiagonal `U`).  The result is the
arrowhead matrix `N` with `N₀₀ = 0`, `N₀ⱼ = Nᵢ₀ = 1`, `Nᵢᵢ = -2` (`i ≥ 1`), else `0`.
Since `det L = det U = 1`, `det D = det N`, and the arrowhead determinant is
`(-2)^(n-1) · (n-1)/2`.

-- !-- Lab Notes -- !--
-- HYPOTHESIS: Graham–Pollak invariant; for the path, the |i-j| matrix reduces to an
--   arrowhead by differencing adjacent rows then columns.
-- EXPERIMENT (verified, see `det_Dpath_one/two/three`): dets are 0, -1, 4 for n=1,2,3,
--   matching (n-1)(-2)^(n-1)/2 = 0, -1, 4.
-- !-- end Lab Notes -- !--
-/

open Matrix BigOperators

namespace ResistancePath

/-- Path distance/resistance matrix: `D i j = |i - j|`. -/
noncomputable def Dpath (n : ℕ) : Matrix (Fin n) (Fin n) ℚ := fun i j => |(i : ℚ) - (j : ℚ)|

/-- Unipotent lower-bidiagonal elementary matrix (`Rᵢ ← Rᵢ - Rᵢ₋₁`). -/
def Lmat (n : ℕ) : Matrix (Fin n) (Fin n) ℚ :=
  fun i j => if (i : ℕ) = (j : ℕ) then 1 else if (i : ℕ) = (j : ℕ) + 1 then -1 else 0

/-- Unipotent upper-bidiagonal elementary matrix (`Cⱼ ← Cⱼ - Cⱼ₋₁`). -/
def Umat (n : ℕ) : Matrix (Fin n) (Fin n) ℚ :=
  fun i j => if (i : ℕ) = (j : ℕ) then 1 else if (j : ℕ) = (i : ℕ) + 1 then -1 else 0

/-- The arrowhead matrix `N = L · D · U`. -/
def Nmat (n : ℕ) : Matrix (Fin n) (Fin n) ℚ :=
  fun i j =>
    if (i : ℕ) = 0 ∧ (j : ℕ) = 0 then 0
    else if (i : ℕ) = 0 then 1
    else if (j : ℕ) = 0 then 1
    else if (i : ℕ) = (j : ℕ) then -2
    else 0

theorem det_Lmat (n : ℕ) : (Lmat n).det = 1 := by
  rw [ ← Matrix.det_transpose ];
  rw [ Matrix.det_of_upperTriangular ] <;> norm_num [ Lmat ];
  intro i j hij; induction j ; induction i ; simp +decide [ *, Lmat ] at *;
  grind

theorem det_Umat (n : ℕ) : (Umat n).det = 1 := by
  -- We'll use row and column operations to reduce $Umat n$ to the identity matrix. First, we'll show that $Umat n$ is upper triangular.
  have h_upper_triangular : ∀ i j : Fin n, i > j → (Umat n) i j = 0 := by
    intro i j hij; simp +decide [ Umat ] ;
    grind;
  rw [ Matrix.det_of_upperTriangular h_upper_triangular ];
  exact Finset.prod_eq_one fun i _ => by unfold Umat; aesop;

theorem factor_LDU (n : ℕ) : Lmat n * Dpath n * Umat n = Nmat n := by
  -- Prove entrywise: `ext i j`. Expand the triple product. Note `Lmat n` has in row `i` exactly the nonzero entries `Lmat n i i = 1` and (when `(i:ℕ) ≥ 1`) `Lmat n i ⟨i-1⟩ = -1`. Likewise `Umat n` has in column `j` exactly `Umat n j j = 1` and (when `(j:ℕ)+1 < n`) `Umat n ⟨j+1⟩ j = -1`. Therefore
  ext i j
  simp [Matrix.mul_apply, Lmat, Dpath, Umat];
  rcases i with ⟨ _ | i, hi ⟩ <;> rcases j with ⟨ _ | j, hj ⟩ <;> norm_num [ Fin.sum_univ_succ, Nmat ];
  · rcases n with ( _ | _ | n ) <;> norm_num [ Fin.sum_univ_succ ] at *;
  · rw [ Finset.sum_eq_add ( ⟨ j, by linarith ⟩ : Fin n ) ( ⟨ j + 1, by linarith ⟩ : Fin n ) ] <;> norm_num;
    · rw [ Finset.sum_eq_single ⟨ 0, by linarith ⟩, Finset.sum_eq_single ⟨ 0, by linarith ⟩ ] <;> norm_num;
      · rw [ abs_of_nonpos ] <;> linarith;
      · exact fun b hb₁ hb₂ => False.elim <| hb₁ <| Fin.ext hb₂.symm;
      · grind +revert;
    · grind;
  · rw [ Finset.sum_eq_single ⟨ 0, by linarith ⟩ ] <;> norm_num;
    · rw [ Finset.sum_eq_add ( ⟨ i, by linarith ⟩ : Fin n ) ( ⟨ i + 1, by linarith ⟩ : Fin n ) ] <;> norm_num;
      grind;
    · exact fun b hb₁ hb₂ => False.elim <| hb₁ <| Fin.ext hb₂;
  · rw [ Finset.sum_eq_add ( ⟨ j + 1, by linarith ⟩ : Fin n ) ( ⟨ j, by linarith ⟩ : Fin n ) ] <;> norm_num;
    · rw [ Finset.sum_eq_add ( ⟨ i, by linarith ⟩ : Fin n ) ( ⟨ i + 1, by linarith ⟩ : Fin n ), Finset.sum_eq_add ( ⟨ i, by linarith ⟩ : Fin n ) ( ⟨ i + 1, by linarith ⟩ : Fin n ) ] <;> norm_num;
      · split_ifs <;> cases abs_cases ( ( i : ℚ ) - ( j + 1 ) ) <;> cases abs_cases ( ( i : ℚ ) - j ) <;> cases abs_cases ( ( i : ℚ ) + 1 - j ) <;> first | linarith | simp_all +decide ;
        · norm_num;
        · norm_cast at * ; omega;
        · rw [ abs_of_nonpos ] <;> linarith [ show ( i : ℚ ) + 1 ≤ j by norm_cast; linarith ];
      · intro c hc₁ hc₂; split_ifs <;> simp_all +decide [ Fin.ext_iff ] ;
      · intro c hc₁ hc₂; split_ifs <;> simp_all +decide [ Fin.ext_iff ] ;
    · intro c hc₁ hc₂; split_ifs <;> simp_all +decide [ Fin.ext_iff ] ;

theorem det_Nmat (n : ℕ) (hn : 1 ≤ n) :
    (Nmat n).det = ((n : ℚ) - 1) * (-2) ^ (n - 1) / 2 := by
      -- Let's apply the block matrix determinant formula to $Nmat n$.
      have h_det_Nmat : Matrix.det (Nmat n) = Matrix.det (Matrix.fromBlocks (0 : Matrix (Fin 1) (Fin 1) ℚ) (fun _ j => 1 : Matrix (Fin 1) (Fin (n - 1)) ℚ) (fun i _ => 1 : Matrix (Fin (n - 1)) (Fin 1) ℚ) (-2 • (1 : Matrix (Fin (n - 1)) (Fin (n - 1)) ℚ))) := by
        rcases n with ( _ | n ) <;> norm_num at *;
        -- Let's rewrite the determinant using the block matrix form.
        have h_block : ∃ P : Fin (n + 1) ≃ Fin 1 ⊕ Fin n, ∀ i j, Nmat (n + 1) i j = (Matrix.fromBlocks (0 : Matrix (Fin 1) (Fin 1) ℚ) (fun _ j => 1 : Matrix (Fin 1) (Fin n) ℚ) (fun i _ => 1 : Matrix (Fin n) (Fin 1) ℚ) (-2 • (1 : Matrix (Fin n) (Fin n) ℚ))) (P i) (P j) := by
          refine' ⟨ Equiv.ofBijective ( fun i => Fin.cases ( Sum.inl 0 ) ( fun i => Sum.inr i ) i ) ⟨ _, _ ⟩, _ ⟩ <;> simp +decide [ Function.Injective, Function.Surjective ];
          · simp +decide [ Fin.forall_fin_succ ];
          · exact ⟨ ⟨ 0, rfl ⟩, fun b => ⟨ Fin.succ b, rfl ⟩ ⟩;
          · intro i j; induction i using Fin.inductionOn <;> induction j using Fin.inductionOn <;> simp +decide [ *, Nmat ] ;
            split_ifs <;> simp_all +decide [ Matrix.one_apply ];
            · rename_i i j hi hj; simp_all +decide [ Fin.ext_iff, Nmat ] ;
              rename_i k; rw [ show k = i from Fin.ext hj ] ;
              exact Eq.symm ( if_pos rfl );
            · exact if_neg ( by aesop );
        obtain ⟨ P, hP ⟩ := h_block;
        convert Matrix.det_reindex_self P.symm _ using 2;
        ext i j; simp +decide [ hP ] ;
      -- Apply the block matrix determinant formula: $\det \begin{pmatrix} A & B \\ C & D \end{pmatrix} = \det(D) \det(A - BD^{-1}C)$.
      have h_det_block : ∀ (A : Matrix (Fin 1) (Fin 1) ℚ) (B : Matrix (Fin 1) (Fin (n - 1)) ℚ) (C : Matrix (Fin (n - 1)) (Fin 1) ℚ) (D : Matrix (Fin (n - 1)) (Fin (n - 1)) ℚ), IsUnit D.det → Matrix.det (Matrix.fromBlocks A B C D) = Matrix.det D * Matrix.det (A - B * D⁻¹ * C) := by
        intros A B C D hD_unit
        have h_det_block : Matrix.det (Matrix.fromBlocks A B C D) = Matrix.det D * Matrix.det (A - B * D⁻¹ * C) := by
          have h_inv : Invertible D := D.invertibleOfIsUnitDet hD_unit
          convert Matrix.det_fromBlocks₂₂ A B C D using 1;
          norm_num [ Matrix.inv_def ];
        exact h_det_block;
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ Matrix.det_neg ];
      convert h_det_block 0 ( fun _ _ => 1 ) ( fun _ _ => 1 ) ( -2 : Matrix ( Fin ( n + 1 ) ) ( Fin ( n + 1 ) ) ℚ ) _ using 1 <;> norm_num [ Matrix.det_neg ];
      · erw [ Matrix.det_diagonal ] ; norm_num [ Matrix.mul_apply ] ; ring;
        erw [ show ( -2 : Matrix ( Fin ( n + 1 ) ) ( Fin ( n + 1 ) ) ℚ ) ⁻¹ = ( -1 / 2 : ℚ ) • 1 from ?_ ] ; norm_num ; ring;
        · norm_num [ Matrix.one_apply ] ; ring;
          norm_num [ mul_assoc, ← mul_pow ];
        · rw [ Matrix.inv_eq_left_inv ] ; norm_num [ Matrix.smul_eq_diagonal_mul ];
          ext i j ; by_cases hi : i = j <;> norm_num [ hi ];
          · erw [ show ( 2 : Matrix ( Fin ( n + 1 ) ) ( Fin ( n + 1 ) ) ℚ ) = 2 • 1 by norm_num, Matrix.smul_apply ] ; aesop;
          · exact if_neg hi;
      · erw [ Matrix.det_diagonal ] ; norm_num

/-- **Graham–Pollak determinant for the path `Pₙ`** (`n ≥ 1`). -/
theorem det_Dpath (n : ℕ) (hn : 1 ≤ n) :
    (Dpath n).det = ((n : ℚ) - 1) * (-2) ^ (n - 1) / 2 := by
  have hLDU : (Lmat n * Dpath n * Umat n).det = (Nmat n).det := by rw [factor_LDU]
  rw [Matrix.det_mul, Matrix.det_mul, det_Lmat, det_Umat] at hLDU
  rw [det_Nmat n hn] at hLDU
  simpa using hLDU

/-- **Signed Graham–Pollak value for the path** (`n ≥ 1`):
`(-1)^(n-1) · det D = (n - 1) · 2^(n-1) / 2 = (n-1) · 2^(n-2)`,
independent of anything but `n` (the tree-invariance value). -/
theorem signed_det_Dpath (n : ℕ) (hn : 1 ≤ n) :
    (-1) ^ (n - 1) * (Dpath n).det = ((n : ℚ) - 1) * 2 ^ (n - 1) / 2 := by
  rw [det_Dpath n hn]
  rw [show ((-2 : ℚ)) ^ (n - 1) = (-1) ^ (n - 1) * 2 ^ (n - 1) by
        rw [← mul_pow]; norm_num]
  have he : (-1 : ℚ) ^ ((n - 1) * 2) = 1 := Even.neg_one_pow ⟨n - 1, by ring⟩
  ring_nf
  rw [he]; ring

-- !-- Lab Notes -- !--
-- Concrete verification of the closed form for small `n` (computational evidence).
-- These confirm `det = (n-1)(-2)^(n-1)/2` evaluates to 0, -1, 4 for n = 1, 2, 3.
-- !-- end Lab Notes -- !--

theorem det_Dpath_one : (Dpath 1).det = 0 := by simp [Dpath]

theorem det_Dpath_two : (Dpath 2).det = -1 := by
  simp only [Dpath, Matrix.det_fin_two]; norm_num

theorem det_Dpath_three : (Dpath 3).det = 4 := by
  simp only [Dpath, Matrix.det_fin_three]
  norm_num [Fin.val_zero, Fin.val_one, Fin.val_two]

end ResistancePath