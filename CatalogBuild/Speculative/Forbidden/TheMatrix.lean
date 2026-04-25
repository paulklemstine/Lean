/-! # CatalogBuild.Speculative.Forbidden.TheMatrix

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 8
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Forbidden.TheMatrix
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 8] -/
theorem matrix_reality_criterion (a b c d : ℝ) :
    (a + d)^2 ≥ 4 * (a * d - b * c) ↔
    (a - d)^2 + 4 * b * c ≥ 0 := by
  constructor <;> intro h <;> linarith


/-- [Section: # CatalogBuild.Speculative.Forbidden.TheMatrix
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 8] -/
theorem trace_sq_symmetric (n : ℕ) (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm) :
    Matrix.trace (A * A) = ∑ i : Fin n, ∑ j : Fin n, A i j * A i j := by
  rw [ Matrix.trace ];
  simp +decide [ Matrix.mul_apply, Matrix.diag ];
  exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ ← hA.apply ] ;


/-- [Section: # CatalogBuild.Speculative.Forbidden.TheMatrix
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 8] -/
theorem commutator_traceless (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.trace (A * B - B * A) = 0 := by
  rw [ Matrix.trace_sub, Matrix.trace_mul_comm, sub_self ]


theorem cayley_hamilton_1x1 (a : ℝ) :
    !![a] - a • (1 : Matrix (Fin 1) (Fin 1) ℝ) = 0 := by
  ext i j ; fin_cases i ; fin_cases j ; norm_num


theorem det_composition (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.det (A * B) = Matrix.det A * Matrix.det B := by
  exact Matrix.det_mul A B


theorem idempotent_trace_eq_rank_nat (n : ℕ) (P : Matrix (Fin n) (Fin n) ℚ)
    (hP : P * P = P) :
    ∃ k : ℕ, Matrix.trace P = (k : ℚ) := by
  -- Consider the linear map $P$ as a projection from $\mathbb{Q}^n$ to a subspace $V$.
  set V := LinearMap.range (Matrix.mulVecLin P) with hV;
  -- Since $P$ is a projection, we have $P = I_V$, where $I_V$ is the identity map on $V$.
  have h_proj : ∀ v : (Fin n) → ℚ, Matrix.mulVec P v ∈ V := by
    exact fun v => LinearMap.mem_range_self _ v;
  -- Since $P$ is a projection, we have $P = I_V$, where $I_V$ is the identity map on $V$. Thus, $\text{tr}(P) = \text{dim}(V)$.
  have h_trace_proj : LinearMap.trace ℚ (Fin n → ℚ) (Matrix.mulVecLin P) = Module.finrank ℚ V := by
    -- Since $P$ is a projection, we have $P = I_V$, where $I_V$ is the identity map on $V$. Thus, $\text{tr}(P) = \text{dim}(V)$ by definition of the trace.
    have h_trace_proj : LinearMap.trace ℚ (Fin n → ℚ) (Matrix.mulVecLin P) = LinearMap.trace ℚ V (LinearMap.id) := by
      have h_trace_proj : LinearMap.trace ℚ (Fin n → ℚ) (Matrix.mulVecLin P) = LinearMap.trace ℚ V (LinearMap.comp (LinearMap.codRestrict V (Matrix.mulVecLin P) h_proj) (LinearMap.range (Matrix.mulVecLin P)).subtype) := by
        grind +suggestions;
      convert h_trace_proj using 2;
      ext; aesop;
    aesop;
  use Module.finrank ℚ V;
  convert h_trace_proj using 1;
  convert LinearMap.trace_eq_matrix_trace _ _ _;
  any_goals exact Pi.basisFun ℚ ( Fin n );
  rotate_right;
  exact Matrix.mulVecLin P;
  all_goals try infer_instance;
  simp +decide [ Matrix.trace, LinearMap.toMatrix_apply ];
  rw [ eq_comm ]


theorem det_transpose_eq (n : ℕ) (A : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.det A.transpose = Matrix.det A := by
  apply Matrix.det_transpose


theorem trace_additive (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.trace (A + B) = Matrix.trace A + Matrix.trace B := by
  exact?


end
