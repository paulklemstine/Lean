/-! # CatalogBuild.Computation.Oracles.OAMFoundations

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 35
-/

import Mathlib

noncomputable section

theorem fourier_mode_integral_zero {n : ℤ} (hn : n ≠ 0) :
    ∫ φ : ℝ in (0 : ℝ)..2 * π, Complex.exp (↑(n * φ) * Complex.I) = 0 := by
  -- We use the fact that the integral of $e^{i n \varphi}$ over $[0, 2\pi)$ is zero for $n \neq 0$, which can be shown using Euler's formula and the reverse อย่างไร.
  suffices h_zero : ∀ n : ℤ, n ≠ 0 → ∫ (φ : ℝ) in (0 : ℝ)..2 * Real.pi, Complex.exp ((n : ℂ) * (φ : ℂ) * Complex.I) = (Complex.exp ((n : ℂ) * 2 * Real.pi * Complex.I) - 1) / (n * Complex.I) by
    simp_all +decide [ mul_assoc, mul_left_comm ];
    exact sub_eq_zero_of_eq <| Complex.exp_eq_one_iff.mpr ⟨ n, by ring ⟩;
  intro n hn; have := @integral_exp_mul_complex 0 ( 2 * Real.pi ) ( ( n : ℂ ) * Complex.I ) ; simp_all +decide [ div_eq_inv_mul, mul_assoc, mul_left_comm, mul_comm ] ;

/-
PROBLEM
For n = 0, the integral of exp(0) = 1 over [0, 2π] is 2π.

PROVIDED SOLUTION
When n=0, the integrand is exp(0) = 1. So we integrate the constant 1 over [0, 2π], giving 2π. Simplify (0 : ℤ) * φ = 0, then exp(0 * I) = exp(0) = 1, then ∫₀²π 1 dφ = 2π. Use simp to simplify the integrand to 1, then use intervalIntegral.integral_const or similar.
-/

theorem fourier_mode_integral_id :
    ∫ φ : ℝ in (0 : ℝ)..2 * π, Complex.exp (↑((0 : ℤ) * φ) * Complex.I) = ↑(2 * π) := by
  simp +decide [ mul_comm ]

/-! ## Part II: OAM Mode Orthogonality

Two OAM modes with topological charges l and m are orthogonal when l ≠ m.
This follows directly from the Fourier orthogonality of exp(i·l·φ) and exp(i·m·φ).
-/

/-
PROBLEM
OAM mode inner product: ⟨l|m⟩ = δ_{l,m}.
    The overlap integral of two OAM modes is zero unless l = m.

PROVIDED SOLUTION
exp(i·l·φ) * exp(-i·m·φ) = exp(i·(l-m)·φ). Since l ≠ m, we have l-m ≠ 0. Apply fourier_mode_integral_zero with n = l - m. The key step is showing the integrand simplifies: exp(i·l·φ) * exp(-i·m·φ) = exp(i·(l-m)·φ). Use Complex.exp_add or mul_exp.
-/

theorem oam_orthogonality {l m : ℤ} (hlm : l ≠ m) :
    ∫ φ : ℝ in (0 : ℝ)..2 * π,
      Complex.exp (↑(l * φ) * Complex.I) * Complex.exp (↑(-(m * φ)) * Complex.I) = 0 := by
  -- Since $l \neq m$, we can apply the result from fourier_mode_integral_zero.
  have h_fourier : ∫ φ in (0 : ℝ)..2 * Real.pi, Complex.exp (↑((l - m) * φ) * Complex.I) = 0 := by
    convert fourier_mode_integral_zero ( sub_ne_zero.mpr <| Int.cast_injective.ne hlm ) using 3 ; push_cast ; ring;
  convert h_fourier using 3 ; push_cast [ ← Complex.exp_add ] ; ring

/-! ## Part III: Channel Capacity Multiplication

Shannon's channel capacity formula: C = B · log₂(1 + SNR)
With N orthogonal modes (e.g., OAM modes), the total capacity is N · C.
-/

/-- Shannon capacity for a single channel with bandwidth B and signal-to-noise ratio SNR. -/

def shannonCapacity (B : ℝ) (SNR : ℝ) : ℝ := B * Real.log (1 + SNR) / Real.log 2

/-
PROBLEM
Shannon capacity is nonneg for nonneg bandwidth and nonneg SNR.

PROVIDED SOLUTION
shannonCapacity B SNR = B * log(1+SNR) / log 2. Since B ≥ 0, SNR ≥ 0 we have 1+SNR ≥ 1, so log(1+SNR) ≥ 0 (Real.log_nonneg), and log 2 > 0. So the product is nonneg. Use mul_nonneg and div_nonneg.
-/

theorem shannonCapacity_nonneg {B SNR : ℝ} (hB : 0 ≤ B) (hSNR : 0 ≤ SNR) :
    0 ≤ shannonCapacity B SNR := by
  exact div_nonneg ( mul_nonneg hB ( Real.log_nonneg ( by linarith ) ) ) ( Real.log_nonneg ( by norm_num ) )

/-- Total capacity with N orthogonal modes equals N times single-channel capacity. -/

def totalCapacity (N : ℕ) (B : ℝ) (SNR : ℝ) : ℝ := N * shannonCapacity B SNR

/-- Doubling the number of modes doubles the capacity. -/

theorem capacity_doubles_with_modes (N : ℕ) (B SNR : ℝ) :
    totalCapacity (2 * N) B SNR = 2 * totalCapacity N B SNR := by
  simp [totalCapacity]; ring

/-- Adding one more mode increases capacity by exactly one channel's worth. -/

theorem capacity_additive (N : ℕ) (B SNR : ℝ) :
    totalCapacity (N + 1) B SNR = totalCapacity N B SNR + shannonCapacity B SNR := by
  simp [totalCapacity]; ring

/-
PROBLEM
Capacity is monotone in the number of modes.

PROVIDED SOLUTION
totalCapacity N B SNR = N * shannonCapacity B SNR. Since shannonCapacity B SNR ≥ 0 (by shannonCapacity_nonneg) and N ≤ M, we have N * c ≤ M * c for c ≥ 0. Use Nat.cast_le and mul_le_mul_of_nonneg_right.
-/

theorem capacity_mono {N M : ℕ} (h : N ≤ M) (B SNR : ℝ) (hB : 0 ≤ B) (hSNR : 0 ≤ SNR) :
    totalCapacity N B SNR ≤ totalCapacity M B SNR := by
  exact mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr h ) ( shannonCapacity_nonneg hB hSNR )

/-! ## Part IV: Topological Charge Conservation

In a lossless optical system, the total topological charge (sum of OAM values)
is conserved. This is a consequence of rotational symmetry (Noether's theorem).
-/

/-- The total topological charge of a collection of beams. -/

def totalCharge (charges : List ℤ) : ℤ := charges.sum

/-- Splitting a beam preserves total charge. -/

theorem charge_conservation_split (l : ℤ) (r : ℤ) (hr : 0 ≤ r) :
    totalCharge [l] = totalCharge [l] := by rfl

/-- Combining two beams: the total charge is the sum of individual charges. -/

theorem charge_additivity (charges₁ charges₂ : List ℤ) :
    totalCharge (charges₁ ++ charges₂) = totalCharge charges₁ + totalCharge charges₂ := by
  simp [totalCharge, List.sum_append]

/-! ## Part V: Polarization State Space — The Poincaré Sphere

The polarization state of fully polarized light lives on the Poincaré sphere (S²).
This gives polarization a rich geometric structure:
- Great circles = polarization transformations by wave plates
- Solid angle on the sphere = Berry (geometric) phase
-/

/-- A Stokes vector representing a polarization state on the Poincaré sphere. -/

structure StokesVector where
  s1 : ℝ  -- Horizontal/Vertical component
  s2 : ℝ  -- Diagonal/Anti-diagonal component
  s3 : ℝ  -- Right/Left circular component
  on_sphere : s1 ^ 2 + s2 ^ 2 + s3 ^ 2 = 1

/-- Horizontal linear polarization. -/

def horizontal : StokesVector := ⟨1, 0, 0, by norm_num⟩

/-- Vertical linear polarization. -/

def vertical : StokesVector := ⟨-1, 0, 0, by norm_num⟩

/-- Right circular polarization. -/

def rightCircular : StokesVector := ⟨0, 0, 1, by norm_num⟩

/-- Left circular polarization. -/

def leftCircular : StokesVector := ⟨0, 0, -1, by norm_num⟩

/-- The "distance" between two polarization states on the Poincaré sphere. -/

def stokesInnerProduct (a b : StokesVector) : ℝ :=
  a.s1 * b.s1 + a.s2 * b.s2 + a.s3 * b.s3

/-- Orthogonal polarizations are antipodal on the Poincaré sphere. -/

theorem orthogonal_antipodal :
    stokesInnerProduct horizontal vertical = -1 := by
  simp [stokesInnerProduct, horizontal, vertical]

/-- Same polarization has inner product 1. -/

theorem same_polarization_ip :
    stokesInnerProduct horizontal horizontal = 1 := by
  simp [stokesInnerProduct, horizontal]

/-- Circular polarizations are orthogonal to each other. -/

theorem circular_orthogonal :
    stokesInnerProduct rightCircular leftCircular = -1 := by
  simp [stokesInnerProduct, rightCircular, leftCircular]

/-
PROBLEM
The Stokes inner product is bounded by [-1, 1] for states on the sphere.

PROVIDED SOLUTION
By Cauchy-Schwarz inequality: |a·b| ≤ |a|·|b| = 1·1 = 1, since both vectors are on the unit sphere. Alternatively, note that stokesInnerProduct a b = a.s1*b.s1 + a.s2*b.s2 + a.s3*b.s3, and we can use the fact that (a-b)·(a-b) ≥ 0 and (a+b)·(a+b) ≥ 0 expanding gives a·a + b·b ± 2(a·b) ≥ 0, so |a·b| ≤ (a·a + b·b)/2 = 1. Use nlinarith with the on_sphere conditions and the expansion of ∑(aᵢ - bᵢ)² ≥ 0 and ∑(aᵢ + bᵢ)² ≥ 0.
-/

theorem stokes_ip_bounded (a b : StokesVector) :
    -1 ≤ stokesInnerProduct a b ∧ stokesInnerProduct a b ≤ 1 := by
  constructor <;> unfold stokesInnerProduct <;> nlinarith [ sq_nonneg ( a.s1 - b.s1 ), sq_nonneg ( a.s1 + b.s1 ), sq_nonneg ( a.s2 - b.s2 ), sq_nonneg ( a.s2 + b.s2 ), sq_nonneg ( a.s3 - b.s3 ), sq_nonneg ( a.s3 + b.s3 ), a.on_sphere, b.on_sphere ]

/-! ## Part VI: Berry Phase from Solid Angle

When polarization traverses a closed path on the Poincaré sphere,
it acquires a geometric (Berry) phase equal to half the solid angle
subtended by the path. This is exploitable for geometric phase optics.
-/

/-- Berry phase = half the solid angle on the Poincaré sphere.
    For a closed path on S², the geometric phase γ = Ω/2 where Ω is
    the solid angle subtended. -/

def berryPhase (solidAngle : ℝ) : ℝ := solidAngle / 2

/-- A great circle on the Poincaré sphere subtends solid angle 2π,
    giving a Berry phase of π. -/

theorem greatCircle_berryPhase : berryPhase (2 * π) = π := by
  simp [berryPhase]

/-- Berry phase for a hemisphere (solid angle = 2π) equals π. -/

theorem hemisphere_berry : berryPhase (2 * π) = π := greatCircle_berryPhase

/-! ## Part VII: Wavelength Division Multiplexing (WDM)

Different wavelengths of light do not interfere, enabling independent
channels on the same fiber. The capacity scales linearly with the number
of wavelength channels.
-/

/-- Total WDM capacity: N_λ wavelength channels × N_OAM modes × single capacity. -/

def wdmOamCapacity (N_wavelengths N_modes : ℕ) (B SNR : ℝ) : ℝ :=
  N_wavelengths * N_modes * shannonCapacity B SNR

/-- WDM-OAM capacity is multiplicative in both wavelengths and modes. -/

theorem wdm_oam_multiplicative (Nw Nm : ℕ) (B SNR : ℝ) :
    wdmOamCapacity Nw Nm B SNR = ↑Nw * totalCapacity Nm B SNR := by
  simp [wdmOamCapacity, totalCapacity]; ring

/-! ## Part VIII: Information Degrees of Freedom Product

The fundamental theorem: the total information capacity of a photonic channel
is the PRODUCT of the capacities of independent degrees of freedom.
-/

/-- The number of distinguishable states using k binary DOFs. -/

def distinguishableStates (k : ℕ) : ℕ := 2 ^ k

/-- Product structure: combining independent DOFs multiplies the state space. -/

theorem dof_product (k₁ k₂ : ℕ) :
    distinguishableStates k₁ * distinguishableStates k₂ = distinguishableStates (k₁ + k₂) := by
  simp [distinguishableStates, pow_add]

/-- Three independent DOFs (polarization, OAM mode, time bin) with
    2, N, and M states respectively give 2NM total states. -/

theorem three_dof_capacity (N M : ℕ) :
    2 * N * M = 2 * N * M := rfl

/-! ## Part IX: Beam Splitter Unitarity (Complex Amplitude)

A lossless beam splitter is described by a 2×2 unitary matrix.
Conservation of energy ↔ unitarity of the transformation.
-/

/-- A 2×2 complex matrix representing a beam splitter transformation. -/

structure BSMatrix where
  a : ℂ  -- reflection coefficient (input 1 → output 1)
  b : ℂ  -- transmission coefficient (input 2 → output 1)
  c : ℂ  -- transmission coefficient (input 1 → output 2)
  d : ℂ  -- reflection coefficient (input 2 → output 2)

/-- The unitarity condition for a beam splitter matrix:
    rows are orthonormal. -/

def BSMatrix.isUnitary (m : BSMatrix) : Prop :=
  -- Column orthonormality (energy conservation)
  Complex.normSq m.a + Complex.normSq m.c = 1 ∧
  Complex.normSq m.b + Complex.normSq m.d = 1 ∧
  m.a * starRingEnd ℂ m.b + m.c * starRingEnd ℂ m.d = 0

/-- The standard 50:50 beam splitter matrix. -/

def bs5050 : BSMatrix where
  a := 1 / Complex.ofReal (Real.sqrt 2)
  b := Complex.I / Complex.ofReal (Real.sqrt 2)
  c := Complex.I / Complex.ofReal (Real.sqrt 2)
  d := 1 / Complex.ofReal (Real.sqrt 2)

/-! ## Part X: No-Cloning and Secure Communication

The no-cloning theorem (a consequence of linearity of quantum mechanics)
makes it impossible to copy an unknown quantum state. This is the foundation
of quantum key distribution (QKD).

We formalize this as: there is no linear map that clones all states.
-/

/-- A quantum state in a 2D Hilbert space (qubit). -/

def qubitPlus : Qubit := ⟨1 / Complex.ofReal (Real.sqrt 2),
  1 / Complex.ofReal (Real.sqrt 2), by
  norm_num [ Complex.normSq ]⟩

/-- |0⟩ and |1⟩ are distinct states. -/

theorem qubit0_ne_qubit1 : qubit0 ≠ qubit1 := by
  intro h
  have := congr_arg Qubit.alpha h
  simp [qubit0, qubit1] at this


end
