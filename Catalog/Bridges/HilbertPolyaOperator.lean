import Mathlib

/-! # CatalogBuild.Bridges.HilbertPolyaOperator

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15
-/

noncomputable section

/-- A self-adjoint (Hermitian) matrix over ℝ. -/
structure SelfAdjointMatrix (n : ℕ) where
  mat : Matrix (Fin n) (Fin n) ℝ
  symmetric : mat.IsSymm

/-- The graph Laplacian is self-adjoint. -/
theorem laplacian_is_selfadjoint {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsSymm)
    (D : Matrix (Fin n) (Fin n) ℝ) (hD : D.IsSymm) :
    (D - A).IsSymm :=
  Matrix.IsSymm.sub hD hA

/-- [Section: # CatalogBuild.Bridges.HilbertPolyaOperator
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15] -/
theorem laplacian_psd {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hA_symm : A.IsSymm)
    (hA_nonneg : ∀ i j, A i j ≥ 0)
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hD : ∀ i, D i i = ∑ j, A i j)
    (hD_diag : ∀ i j, i ≠ j → D i j = 0) :
    ∀ v : Fin n → ℝ, v ⬝ᵥ ((D - A).mulVec v) ≥ 0 := by
  intro v
  have h_sum : v ⬝ᵥ (D - A).mulVec v = (1 / 2) * ∑ i, ∑ j, A i j * (v i - v j) ^ 2 := by
    have h_sum : v ⬝ᵥ (D - A).mulVec v = ∑ i, ∑ j, A i j * v i * (v i - v j) := by
      simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, mul_assoc, mul_sub, sub_mul, mul_comm, mul_left_comm, Finset.sum_mul, hD, hD_diag ];
      rw [ Finset.sum_congr rfl ];
      intro i hi; rw [ Finset.sum_congr rfl fun j hj => by rw [ show D i j = if i = j then ∑ k, A i k else 0 by aesop ] ] ; simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ] ;
    have h_sum_symm : ∑ i, ∑ j, A i j * v i * (v i - v j) = ∑ i, ∑ j, A j i * v j * (v j - v i) := by
      rw [ Finset.sum_comm ];
    have h_sum_symm : ∑ i, ∑ j, A i j * v i * (v i - v j) + ∑ i, ∑ j, A j i * v j * (v j - v i) = ∑ i, ∑ j, A i j * (v i - v j) ^ 2 := by
      rw [ ← Finset.sum_add_distrib ] ; refine' Finset.sum_congr rfl fun i hi => _ ; rw [ ← Finset.sum_add_distrib ] ; refine' Finset.sum_congr rfl fun j hj => _ ; rw [ ← hA_symm.apply ] ; ring;
    linarith;
  exact h_sum.symm ▸ mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => mul_nonneg ( hA_nonneg i j ) ( sq_nonneg _ ) )

/-- [Section: # CatalogBuild.Bridges.HilbertPolyaOperator
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15] -/
theorem laplacian_zero_eigenvalue {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hD_diag : ∀ i, D i i = ∑ j, A i j)
    (hD_off : ∀ i j, i ≠ j → D i j = 0) :
    (D - A).mulVec (fun _ => (1 : ℝ)) = 0 := by
  ext i;
  simp_all +decide [ Matrix.mulVec, dotProduct ];
  rw [ sub_eq_zero, Finset.sum_eq_single i ] <;> aesop

/-- An oriented edge of a graph. -/
structure OrientedEdge (n : ℕ) where
  source : Fin n
  target : Fin n
  ne : source ≠ target

/-- The Hashimoto (edge adjacency) operator. -/
def hashimotoMatrix {n m : ℕ}
    (edges : Fin m → OrientedEdge n) : Matrix (Fin m) (Fin m) ℝ :=
  fun e1 e2 =>
    if (edges e1).target = (edges e2).source ∧
       ¬((edges e1).source = (edges e2).target ∧ (edges e1).target = (edges e2).source)
    then 1 else 0

/-- For regular graphs, the determinant formula simplifies. -/
theorem ihara_det_simplification {n : ℕ} (q : ℕ)
    (A : Matrix (Fin n) (Fin n) ℝ) (u : ℝ) :
    (1 : Matrix (Fin n) (Fin n) ℝ) - u • A + ((q : ℝ) * u ^ 2) • (1 : Matrix (Fin n) (Fin n) ℝ) =
    (1 + (q : ℝ) * u ^ 2) • (1 : Matrix (Fin n) (Fin n) ℝ) - u • A := by
  ext i j
  simp only [Matrix.sub_apply, Matrix.add_apply, Matrix.smul_apply, Matrix.one_apply, smul_eq_mul]
  ring

theorem ramanujan_critical_line (q : ℕ) (hq : q ≥ 1) (ev : ℝ)
    (h_ram : |ev| ≤ 2 * Real.sqrt q) :
    ev ^ 2 - 4 * q ≤ 0 := by
  nlinarith [ abs_le.mp h_ram, Real.mul_self_sqrt ( Nat.cast_nonneg q ) ]

theorem vieta_sum_of_roots (q : ℕ) (hq : q ≥ 1) (ev u1 u2 : ℝ)
    (h1 : 1 - u1 * ev + (q : ℝ) * u1 ^ 2 = 0)
    (h2 : 1 - u2 * ev + (q : ℝ) * u2 ^ 2 = 0)
    (hne : u1 ≠ u2) :
    u1 + u2 = ev / q := by
  exact eq_div_of_mul_eq ( by positivity ) ( mul_left_cancel₀ ( sub_ne_zero_of_ne hne ) <| by linarith )

/-- The "Hilbert-Pólya operator" for a graph: the normalized adjacency matrix A/√q. -/
def hilbertPolyaOperator {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (q : ℕ) :
    Matrix (Fin n) (Fin n) ℝ :=
  (1 / Real.sqrt q) • A

/-- The Hilbert-Pólya operator is self-adjoint when A is symmetric. -/
theorem hilbertPolya_selfadjoint {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm) (q : ℕ) :
    (hilbertPolyaOperator A q).IsSymm :=
  Matrix.IsSymm.smul hA _

theorem hilbertPolya_ramanujan_bound (q : ℕ) (hq : q ≥ 1)
    (ev : ℝ) (h_ram : |ev| ≤ 2 * Real.sqrt q) :
    |ev / Real.sqrt q| ≤ 2 := by
  rwa [ abs_div, abs_of_nonneg ( Real.sqrt_nonneg _ ), div_le_iff₀ ( by positivity ) ]

/-- The heat kernel trace: Tr(e^{-tL}) = Σ e^{-tλᵢ}. -/
def heatTrace (eigenvalues : List ℝ) (t : ℝ) : ℝ :=
  eigenvalues.map (fun ev => Real.exp (-t * ev)) |>.sum

/-- Each term of the heat trace is positive. -/
theorem heat_trace_term_pos (t ev : ℝ) :
    Real.exp (-t * ev) > 0 :=
  Real.exp_pos _

/-- The spectral zeta function of the Laplacian. -/
def spectralZeta (eigenvalues : List ℝ) (s : ℝ) : ℝ :=
  (eigenvalues.filter (· > 0)).map (fun ev => ev ^ (-s)) |>.sum

end