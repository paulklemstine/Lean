import Mathlib

/-!
# Hydrogen Atom: Angular Momentum and Spherical Harmonics

Formalizes the angular part of the hydrogen atom eigenvalue problem:
azimuthal eigenfunctions, orthogonality, angular momentum commutation
relations in the l=1 matrix representation, and the Casimir operator.

## Main Results

* `azimuthal_eigenfunction_periodic`: periodicity of e^{imφ}
* `azimuthal_orthogonality`: orthogonality integral
* `angular_momentum_comm_xy`: [Lx, Ly] = i Lz
* `Lsq_is_scalar_l1`: L² = 2I in l=1 representation
* `angular_momentum_ladder_comm`: [Lz, L±] = ±L± ladder relation
-/

noncomputable section

open Complex Real MeasureTheory Set Filter
open scoped BigOperators

/-! ## Azimuthal Eigenfunctions -/

/-- The unnormalized azimuthal eigenfunction e^{imφ}. -/
def azimuthalExp (m : ℤ) (φ : ℝ) : ℂ :=
  Complex.exp (↑(m * φ) * Complex.I)

/-
Azimuthal eigenfunctions are periodic with period 2π.
-/
theorem azimuthal_eigenfunction_periodic (m : ℤ) (φ : ℝ) :
    azimuthalExp m (φ + 2 * Real.pi) = azimuthalExp m φ := by
  -- By definition of azimuthalExp, we have azimuthalExp m (φ + 2 * π) = Complex.exp (↑(m * (φ + 2 * π)) * Complex.I).
  simp [azimuthalExp];
  exact Complex.exp_eq_exp_iff_exists_int.mpr ⟨ m, by ring ⟩

/-
The conjugate of the azimuthal eigenfunction.
-/
theorem azimuthalExp_conj (m : ℤ) (φ : ℝ) :
    starRingEnd ℂ (azimuthalExp m φ) = azimuthalExp (-m) φ := by
  unfold azimuthalExp; norm_num [ Complex.ext_iff, Complex.exp_re, Complex.exp_im ] ;

/-! ## Azimuthal Orthogonality -/

/-
Integral of e^{inφ} over a full period vanishes for n ≠ 0.
-/
theorem integral_cexp_ne_zero {n : ℤ} (hn : n ≠ 0) :
    ∫ φ in (0 : ℝ)..(2 * Real.pi), Complex.exp (↑(n * φ) * Complex.I) = 0 := by
  rw [ intervalIntegral.integral_deriv_eq_sub' ];
  case f => exact fun x => Complex.exp ( ( n * x ) * Complex.I ) / ( ( n : ℂ ) * Complex.I );
  · norm_num [ Complex.ext_iff, Complex.exp_re, Complex.exp_im ];
    norm_num [ Complex.div_re, Complex.div_im, Complex.exp_re, Complex.exp_im, div_eq_mul_inv ];
    exact ⟨ Or.inl <| Real.sin_eq_zero_iff.mpr ⟨ n * 2, by push_cast; ring ⟩, by simp +decide [ hn ] ⟩;
  · ext1 x; norm_num [ div_eq_iff, Complex.exp_ne_zero, hn ] ;
    convert HasDerivAt.deriv ( HasDerivAt.comp x ( Complex.hasDerivAt_exp _ ) ( HasDerivAt.mul ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_id _ |> HasDerivAt.ofReal_comp ) ) ( hasDerivAt_const _ _ ) ) ) using 1 ; norm_num;
  · exact fun x hx => DifferentiableAt.div_const ( Complex.differentiableAt_exp.comp x <| DifferentiableAt.mul ( DifferentiableAt.mul ( differentiableAt_const _ ) <| Complex.ofRealCLM.differentiableAt ) <| differentiableAt_const _ ) _;
  · fun_prop

/-
Azimuthal orthogonality: ∫₀²π e^{-im₁φ} e^{im₂φ} dφ = 2π δ_{m₁,m₂}.
-/
theorem azimuthal_orthogonality (m₁ m₂ : ℤ) :
    ∫ φ in (0 : ℝ)..(2 * Real.pi),
      starRingEnd ℂ (azimuthalExp m₁ φ) * azimuthalExp m₂ φ
    = if m₁ = m₂ then ↑(2 * Real.pi) else 0 := by
  -- Split the integral based on whether m₁ equals m₂.
  by_cases h : m₁ = m₂;
  · simp +decide [ ← h, Complex.exp_neg, Complex.exp_ne_zero, mul_assoc, mul_left_comm, mul_comm ( Complex.exp _ ) ];
    unfold azimuthalExp; norm_num [ Complex.mul_conj, Complex.normSq_eq_norm_sq, Complex.norm_exp ] ;
    norm_num [ Complex.exp_ne_zero, mul_assoc, mul_comm, mul_left_comm, ← Complex.exp_add ];
    norm_num [ Complex.mul_conj, Complex.normSq_eq_norm_sq, Complex.norm_exp ];
  · -- When m₁ ≠ m₂, the integrand is e^{i(m₂-m₁)φ} with m₂-m₁ ≠ 0.
    have h_integrand : ∀ φ, (starRingEnd ℂ (azimuthalExp m₁ φ)) * (azimuthalExp m₂ φ) = Complex.exp (↑((m₂ - m₁) * φ) * Complex.I) := by
      intro φ; rw [ azimuthalExp_conj ] ; rw [ azimuthalExp ] ; rw [ azimuthalExp ] ; rw [ ← Complex.exp_add ] ; push_cast; ring;
    convert integral_cexp_ne_zero ( show ( m₂ - m₁ : ℤ ) ≠ 0 by exact sub_ne_zero.mpr <| Ne.symm h ) using 3 ; push_cast [ h_integrand ] ; ring;
    aesop

/-! ## Angular Momentum Matrices (l=1 representation) -/

/-- The matrix representation of Lx in the l=1 basis. -/
def Lx_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  !![0, 1/Real.sqrt 2, 0;
     1/Real.sqrt 2, 0, 1/Real.sqrt 2;
     0, 1/Real.sqrt 2, 0]

/-- The matrix representation of Ly. -/
def Ly_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  !![0, -Complex.I/Real.sqrt 2, 0;
     Complex.I/Real.sqrt 2, 0, -Complex.I/Real.sqrt 2;
     0, Complex.I/Real.sqrt 2, 0]

/-- The matrix representation of Lz. -/
def Lz_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  !![1, 0, 0;
     0, 0, 0;
     0, 0, -1]

/-- The commutator of two matrices. -/
def matCommutator {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℂ) :
    Matrix (Fin n) (Fin n) ℂ :=
  A * B - B * A

/-
[Lx, Ly] = i Lz — the defining relation of so(3).
-/
theorem angular_momentum_comm_xy :
    matCommutator Lx_matrix Ly_matrix = Complex.I • Lz_matrix := by
  ext i j fin_cases i ; fin_cases j <;> norm_num [ matCommutator, Lx_matrix, Ly_matrix, Lz_matrix, Matrix.mul_apply ] <;> ring_nf <;> norm_num [ Complex.ext_iff, sq ] ;
  · fin_cases i <;> norm_num [ Complex.normSq, Complex.ext_iff ];
    ring_nf; norm_num;
  · fin_cases i <;> norm_num [ Matrix.vecHead, Matrix.vecTail ] at * <;> first | linarith | aesop | trivial;
  · fin_cases i <;> norm_num [ Complex.normSq, Complex.div_re, Complex.div_im, mul_assoc, mul_comm, mul_left_comm ] ; ring_nf ;
    norm_num [ Complex.ext_iff, sq ] at * <;> first | linarith | aesop | assumption;

/-
[Ly, Lz] = i Lx.
-/
theorem angular_momentum_comm_yz :
    matCommutator Ly_matrix Lz_matrix = Complex.I • Lx_matrix := by
  unfold matCommutator Lx_matrix Ly_matrix Lz_matrix;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, Fin.sum_univ_succ ] <;> ring!

/-
[Lz, Lx] = i Ly.
-/
theorem angular_momentum_comm_zx :
    matCommutator Lz_matrix Lx_matrix = Complex.I • Ly_matrix := by
  unfold matCommutator Lz_matrix Lx_matrix Ly_matrix;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ Complex.ext_iff, Matrix.mul_apply ];
  · grind;
  · norm_num [ Real.sqrt_div_self ];
  · grind;
  · norm_num [ Real.sqrt_div_self ]

/-! ## Ladder Operators -/

/-- The raising operator L+ = Lx + iLy in the l=1 representation. -/
def Lplus_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  Lx_matrix + Complex.I • Ly_matrix

/-- The lowering operator L- = Lx - iLy in the l=1 representation. -/
def Lminus_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  Lx_matrix - Complex.I • Ly_matrix

/-
**Novel theorem**: The ladder operator commutation relation [Lz, L+] = L+.
This is the algebraic engine behind angular momentum quantization:
the ladder operators shift the magnetic quantum number by ±1.
-/
theorem angular_momentum_ladder_comm_plus :
    matCommutator Lz_matrix Lplus_matrix = Lplus_matrix := by
  unfold matCommutator Lplus_matrix Lz_matrix Lx_matrix Ly_matrix;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ div_eq_mul_inv, Matrix.mul_apply ] <;> ring_nf <;> norm_num [ Complex.ext_iff, sq ] at * <;> first | linarith | aesop | assumption;

/-
The ladder operator commutation relation [Lz, L-] = -L-.
-/
theorem angular_momentum_ladder_comm_minus :
    matCommutator Lz_matrix Lminus_matrix = -Lminus_matrix := by
  unfold matCommutator Lminus_matrix;
  unfold Lz_matrix Lx_matrix Ly_matrix; ext i j; fin_cases i <;> fin_cases j <;> norm_num [ Complex.ext_iff, Matrix.mul_apply ] ;
  · grind;
  · grind

/-! ## Casimir Operator -/

/-- L² = Lx² + Ly² + Lz² in the l=1 representation. -/
def Lsq_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  Lx_matrix * Lx_matrix + Ly_matrix * Ly_matrix + Lz_matrix * Lz_matrix

/-
L² = l(l+1)·I = 2I in the l=1 irreducible representation.
This is the matrix form of the eigenvalue equation L²Y_l^m = l(l+1)Y_l^m.
-/
theorem Lsq_is_scalar_l1 : Lsq_matrix = (2 : ℂ) • (1 : Matrix (Fin 3) (Fin 3) ℂ) := by
  unfold Lsq_matrix Lx_matrix Ly_matrix Lz_matrix;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ div_eq_mul_inv, Matrix.mul_apply ] <;> ring_nf <;> norm_num [ Complex.ext_iff, sq ] ;
  · ring_nf; norm_num;
  · ring_nf; norm_num;
  · ring_nf; norm_num;

/-
L² commutes with Lz — the Casimir operator commutes with all generators.
-/
theorem Lsq_comm_Lz : matCommutator Lsq_matrix Lz_matrix = 0 := by
  simp [ matCommutator, Lsq_is_scalar_l1 ]

/-! ## Magnetic Quantum Number Count -/

/-
For angular momentum l, the number of valid magnetic quantum numbers
m ∈ {-l, …, l} is 2l + 1.
-/
theorem magnetic_count (l : ℕ) :
    (Finset.Icc (-↑l : ℤ) (↑l : ℤ)).card = 2 * l + 1 := by
  convert Int.card_Icc ( -l : ℤ ) l using 1 ; ring;
  norm_cast

end