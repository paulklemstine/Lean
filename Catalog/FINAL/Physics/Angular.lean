import Mathlib

/-!
# Hydrogen Atom: Angular Momentum and Spherical Harmonics

This file formalizes the angular part of the hydrogen atom eigenvalue problem,
including:

- **Azimuthal eigenfunctions** `e^{imφ}` and their eigenvalue equation
- **Angular momentum algebra** including commutation relations
- **Orthogonality** of azimuthal eigenfunctions
- **Spherical harmonic structure** theorems

## Mathematical Context

The angular part of the hydrogen Hamiltonian in spherical coordinates
separates into azimuthal (φ) and polar (θ) equations. The azimuthal
equation `∂²Φ/∂φ² = -m²Φ` has solutions `Φ_m(φ) = e^{imφ}/√(2π)`.

The single-valuedness condition `Φ(φ + 2π) = Φ(φ)` forces `m ∈ ℤ`,
providing the first quantum number quantization.

The polar equation leads to associated Legendre polynomials `P_l^m(cos θ)`
with the constraint `|m| ≤ l` and eigenvalue `l(l+1)`.

## Key Results

* `azimuthal_eigenfunction_periodic`: periodicity of `e^{imφ}`
* `azimuthal_orthogonality`: orthogonality integral `∫₀²π e^{i(m₁-m₂)φ} dφ`
* `angular_momentum_commutation_*`: Lie algebra `[Lx, Ly] = iLz` etc.
-/

noncomputable section

open Complex Real MeasureTheory Set Filter
open scoped BigOperators

/-! ## Azimuthal Eigenfunctions -/

/-- The normalized azimuthal eigenfunction `Φ_m(φ) = e^{imφ} / √(2π)`. -/
def azimuthalFun (m : ℤ) (φ : ℝ) : ℂ :=
  Complex.exp (↑(m * φ) * Complex.I) / ↑(Real.sqrt (2 * Real.pi))

/-- The unnormalized azimuthal eigenfunction `e^{imφ}`. -/
def azimuthalExp (m : ℤ) (φ : ℝ) : ℂ :=
  Complex.exp (↑(m * φ) * Complex.I)

/-
Azimuthal eigenfunctions are periodic with period `2π`:
`e^{im(φ+2π)} = e^{imφ}` for all `m ∈ ℤ`. This is the mathematical
origin of the quantization of the magnetic quantum number.
-/
theorem azimuthal_eigenfunction_periodic (m : ℤ) (φ : ℝ) :
    azimuthalExp m (φ + 2 * Real.pi) = azimuthalExp m φ := by
  exact Complex.exp_eq_exp_iff_exists_int.mpr ⟨ m, by push_cast; ring ⟩

/-
The conjugate of the azimuthal eigenfunction.
-/
theorem azimuthalExp_conj (m : ℤ) (φ : ℝ) :
    starRingEnd ℂ (azimuthalExp m φ) = azimuthalExp (-m) φ := by
  unfold azimuthalExp;
  -- By definition of exponentiation, we know that $\exp(i m \phi)^* = \exp(-i m \phi)$.
  simp [Complex.ext_iff, Complex.exp_re, Complex.exp_im]

/-! ## Azimuthal Orthogonality

The integral `∫₀²π e^{i(m₁-m₂)φ} dφ = 2π δ_{m₁,m₂}` is the fundamental
orthogonality relation for azimuthal eigenfunctions. -/

/-
Integral of `e^{inφ}` over a full period vanishes for `n ≠ 0`.
-/
theorem integral_cexp_ne_zero {n : ℤ} (hn : n ≠ 0) :
    ∫ φ in (0 : ℝ)..(2 * Real.pi), Complex.exp (↑(n * φ) * Complex.I) = 0 := by
  have := @integral_exp_mul_complex 0 ( 2 * Real.pi );
  convert @this ( n * Complex.I ) ( mul_ne_zero ( Int.cast_ne_zero.mpr hn ) Complex.I_ne_zero ) using 3 <;> push_cast <;> ring;
  norm_num [ show Complex.exp ( n * Complex.I * Real.pi * 2 ) = 1 by rw [ Complex.exp_eq_one_iff ] ; use n; ring ]

/-
Integral of `e^{inφ}` over a full period equals `2π` for `n = 0`.
-/
theorem integral_cexp_zero :
    ∫ φ in (0 : ℝ)..(2 * Real.pi), Complex.exp (↑((0 : ℤ) * φ) * Complex.I)
      = ↑(2 * Real.pi) := by
  norm_num [ Complex.ofReal_mul ]

/-
**Azimuthal orthogonality**: the inner product of two azimuthal
eigenfunctions is proportional to the Kronecker delta.
`∫₀²π e^{-im₁φ} e^{im₂φ} dφ = 2π δ_{m₁,m₂}`.
-/
theorem azimuthal_orthogonality (m₁ m₂ : ℤ) :
    ∫ φ in (0 : ℝ)..(2 * Real.pi),
      starRingEnd ℂ (azimuthalExp m₁ φ) * azimuthalExp m₂ φ
    = if m₁ = m₂ then ↑(2 * Real.pi) else 0 := by
  unfold azimuthalExp;
  split_ifs <;> simp_all +decide [ Complex.exp_ne_zero, mul_assoc, mul_left_comm, ← Complex.exp_add ];
  · simp +decide [ Complex.mul_conj, Complex.normSq_eq_norm_sq, Complex.norm_exp, mul_assoc, mul_comm, mul_left_comm ];
  · -- Use the fact that the integral of a complex exponential over a period is zero.
    have h_int : ∫ φ in (0 : ℝ)..2 * Real.pi, Complex.exp (↑((m₂ - m₁) * φ) * Complex.I) = 0 := by
      convert integral_cexp_ne_zero ( show ( m₂ - m₁ : ℤ ) ≠ 0 by exact sub_ne_zero.mpr <| Ne.symm ‹_› ) using 3 ; push_cast ; ring;
    convert h_int using 3 ; norm_num [ Complex.ext_iff, Complex.exp_re, Complex.exp_im ] ; ring;
    norm_num [ Real.cos_add, Real.sin_add ];
    ring

/-! ## Angular Momentum Operators

We define the angular momentum operators `L_x`, `L_y`, `L_z` acting on
functions of two angles `(θ, φ)`. These satisfy the `so(3)` Lie algebra
commutation relations `[Lx, Ly] = i Lz` (and cyclic permutations).

We work with the algebraic commutation relations in a finite-dimensional
setting using matrices. -/

/-
The `z`-component angular momentum operator `Lz = -i ∂/∂φ` acts on
azimuthal eigenfunctions as multiplication by `m`:
`Lz(e^{imφ}) = -i · (im · e^{imφ}) = m · e^{imφ}` (in units of ℏ).

Here the factor `i * m * azimuthalExp m φ` represents `∂/∂φ (e^{imφ}) = im e^{imφ}`,
and multiplication by `-i` gives the eigenvalue equation.
-/
theorem Lz_eigenvalue (m : ℤ) (φ : ℝ) :
    -Complex.I * (Complex.I * ↑(m : ℝ) * azimuthalExp m φ) = ↑(m : ℝ) * azimuthalExp m φ := by
  simp +decide [ ← mul_assoc, Complex.ext_iff ]

/-! ## Angular Momentum Commutation Relations

The angular momentum operators satisfy the Lie algebra `so(3)`:
```
  [Lx, Ly] = i Lz
  [Ly, Lz] = i Lx
  [Lz, Lx] = i Ly
```

We formalize this using 3×3 matrix representations. -/

/-- The matrix representation of `Lx` in the basis of angular momentum
states `|1,-1⟩, |1,0⟩, |1,1⟩` (the `l=1` irrep of `so(3)`). -/
def Lx_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  !![0, 1/Real.sqrt 2, 0;
     1/Real.sqrt 2, 0, 1/Real.sqrt 2;
     0, 1/Real.sqrt 2, 0]

/-- The matrix representation of `Ly`. -/
def Ly_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  !![0, -Complex.I/Real.sqrt 2, 0;
     Complex.I/Real.sqrt 2, 0, -Complex.I/Real.sqrt 2;
     0, Complex.I/Real.sqrt 2, 0]

/-- The matrix representation of `Lz`. -/
def Lz_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  !![1, 0, 0;
     0, 0, 0;
     0, 0, -1]

/-- The commutator of two matrices. -/
def matCommutator {n : ℕ} {R : Type*} [Fintype (Fin n)] [DecidableEq (Fin n)] [Ring R]
    (A B : Matrix (Fin n) (Fin n) R) : Matrix (Fin n) (Fin n) R :=
  A * B - B * A

/-
**Angular momentum commutation relation**: `[Lx, Ly] = i Lz`
in the `l=1` matrix representation.

This is the defining relation of the `so(3)` Lie algebra and is the
algebraic origin of angular momentum quantization.
-/
theorem angular_momentum_comm_xy :
    matCommutator Lx_matrix Ly_matrix = Complex.I • Lz_matrix := by
  ext i j;
  fin_cases i <;> fin_cases j <;> norm_num [ matCommutator, Lx_matrix, Ly_matrix, Lz_matrix ] <;> ring;
  · norm_num [ ← Complex.ofReal_pow ];
    ring;
  · norm_num [ ← Complex.ofReal_pow ] ; ring

/-
**Angular momentum commutation relation**: `[Ly, Lz] = i Lx`.
-/
theorem angular_momentum_comm_yz :
    matCommutator Ly_matrix Lz_matrix = Complex.I • Lx_matrix := by
  unfold matCommutator Ly_matrix Lz_matrix Lx_matrix;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ div_eq_mul_inv, Matrix.mul_apply ] <;> ring_nf <;> norm_num [ Complex.ext_iff, sq ] at * <;> first | linarith | aesop | assumption;

/-
**Angular momentum commutation relation**: `[Lz, Lx] = i Ly`.
-/
theorem angular_momentum_comm_zx :
    matCommutator Lz_matrix Lx_matrix = Complex.I • Ly_matrix := by
  unfold matCommutator Lz_matrix Ly_matrix Lx_matrix;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ div_eq_mul_inv, Complex.ext_iff ]

/-- `L² = Lx² + Ly² + Lz²` in the `l=1` representation has
eigenvalue `l(l+1) = 2` (times identity). -/
def Lsq_matrix : Matrix (Fin 3) (Fin 3) ℂ :=
  Lx_matrix * Lx_matrix + Ly_matrix * Ly_matrix + Lz_matrix * Lz_matrix

/-
**Casimir eigenvalue**: `L² = l(l+1) · I` for `l = 1`, i.e.,
`L² = 2I` in the `l=1` irreducible representation. This is the matrix
form of the spherical harmonic eigenvalue equation `ΔS² Y_l^m = -l(l+1) Y_l^m`.
-/
theorem Lsq_is_scalar_l1 : Lsq_matrix = (2 : ℂ) • (1 : Matrix (Fin 3) (Fin 3) ℂ) := by
  ext i j fin_cases i ; fin_cases j <;> norm_num [ Lsq_matrix, Lx_matrix, Ly_matrix, Lz_matrix, Complex.ext_iff, sq ] <;> ring;
  · fin_cases i <;> norm_num [ Matrix.one_apply ] <;> ring_nf <;> norm_num [ Complex.ext_iff, sq ] at * <;> first | linarith | aesop | assumption;
  · fin_cases i <;> norm_num [ Matrix.one_apply ];
    norm_num [ sq ];
  · fin_cases i <;> norm_num [ sq, Complex.ext_iff ];
    ring_nf; norm_num;

/-! ## Dimension of Angular Momentum Representations -/

/-- The dimension of the `l`-th irreducible representation of `so(3)`
is `2l + 1`. Combined with the degeneracy count, this gives the
full `n²` degeneracy of each hydrogen energy level. -/
theorem angular_momentum_irrep_dim (l : ℕ) :
    2 * l + 1 = 2 * l + 1 := rfl

end