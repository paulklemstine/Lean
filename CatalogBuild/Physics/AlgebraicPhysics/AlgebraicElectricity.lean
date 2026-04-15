/-! # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicElectricity

Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 21
-/

import Mathlib

noncomputable section

/-- The parallel combination of two impedances (harmonic addition). -/
noncomputable def parallelImpedance (Z₁ Z₂ : ℂ) : ℂ := (Z₁ * Z₂) / (Z₁ + Z₂)

/-- Parallel combination is commutative. -/

theorem parallelImpedance_comm (Z₁ Z₂ : ℂ) :
    parallelImpedance Z₁ Z₂ = parallelImpedance Z₂ Z₁ := by
  unfold parallelImpedance
  ring

/-
PROBLEM
Parallel combination equals the harmonic sum (inverse of sum of inverses),
    when both impedances are nonzero and their sum is nonzero.

PROVIDED SOLUTION
Unfold parallelImpedance. Use field_simp to clear denominators, then ring.
-/

theorem parallelImpedance_eq_inv_sum_inv (Z₁ Z₂ : ℂ) (h1 : Z₁ ≠ 0) (h2 : Z₂ ≠ 0)
    (h3 : Z₁ + Z₂ ≠ 0) :
    parallelImpedance Z₁ Z₂ = (Z₁⁻¹ + Z₂⁻¹)⁻¹ := by
  rw [ inv_add_inv, inv_div ] <;> aesop

/-- Series combination (addition) has identity element 0 (short circuit). -/

theorem series_identity (Z : ℂ) : Z + 0 = Z := add_zero Z

/-- In the extended picture, parallel with zero gives zero (short circuit dominates). -/

theorem parallel_zero (Z : ℂ) : parallelImpedance Z 0 = 0 := by
  unfold parallelImpedance
  ring

/-
PROBLEM
Parallel of equal impedances gives half, when 2Z ≠ 0.

PROVIDED SOLUTION
Unfold parallelImpedance. field_simp with h, then ring.
-/

theorem parallel_self (Z : ℂ) (h : Z + Z ≠ 0) :
    parallelImpedance Z Z = Z / 2 := by
  convert parallelImpedance_eq_inv_sum_inv _ _ _ _ _ using 1 <;> ring ; aesop;
  · aesop;
  · aesop;
  · rwa [ mul_two ]

/-! ## Section 2: Three-Phase Symmetry

In three-phase power, the voltages are separated by 120° = 2π/3.
The algebraic content is that the cube roots of unity sum to zero:
1 + ω + ω² = 0 where ω = e^{2πi/3}. -/

/-- The primitive cube root of unity. -/

noncomputable def cubeRootOfUnity : ℂ := Complex.exp (2 * Real.pi * I / 3)

/-
PROBLEM
Third roots of unity: ω³ = 1.

PROVIDED SOLUTION
cubeRootOfUnity = exp(2πi/3). So ω³ = exp(2πi) = cos(2π) + i·sin(2π) = 1. Use Complex.exp_nat_mul or similar, and the fact that exp(2πi) = 1.
-/

theorem cube_root_cubed : cubeRootOfUnity ^ 3 = 1 := by
  rw [ show cubeRootOfUnity = Complex.exp ( 2 * Real.pi * Complex.I / 3 ) by rfl, ← Complex.exp_nat_mul, mul_comm, Complex.exp_eq_one_iff ] ; use 1 ; ring_nf

/-
PROBLEM
The fundamental three-phase identity: 1 + ω + ω² = 0.
    This is the algebraic reason balanced three-phase voltages sum to zero.

PROVIDED SOLUTION
Use the algebraic identity: for any cube root of unity ω with ω³ = 1 and ω ≠ 1, we have 1 + ω + ω² = (ω³ - 1)/(ω - 1) = 0. Alternatively, compute directly using exp(2πi/3).
-/

theorem three_phase_sum_zero :
    1 + cubeRootOfUnity + cubeRootOfUnity ^ 2 = 0 := by
  norm_num [ cubeRootOfUnity ];
  norm_num [ Complex.ext_iff, sq, Complex.exp_re, Complex.exp_im ];
  rw [ show 2 * Real.pi / 3 = Real.pi - Real.pi / 3 by ring ] ; norm_num ; ring ; norm_num;

/-! ## Section 3: Gauge Invariance (d² = 0)

The key algebraic identity underlying gauge invariance is d² = 0:
the exterior derivative applied twice is zero. In a discrete setting,
this becomes ∂₁ ∘ ∂₂ = 0 for the boundary operators of a chain complex.

We formalize this as: if F = dA (the field is the derivative of the potential),
then dF = 0 automatically (the Bianchi identity). -/

/-
PROBLEM
In any chain complex, the composition of consecutive boundary maps is zero.
    This is the algebraic core of gauge invariance: if F = dA, then dF = d(dA) = 0.

PROVIDED SOLUTION
Intro x. Use the hypothesis h: d₁ ∘ₗ d₂ = 0. Apply LinearMap.ext_iff or use the fact that (d₁ ∘ₗ d₂) x = 0 follows from h by applying the zero linear map at x.
-/

theorem boundary_squared_zero {R : Type*} [CommRing R] {M₀ M₁ M₂ : Type*}
    [AddCommGroup M₀] [Module R M₀]
    [AddCommGroup M₁] [Module R M₁]
    [AddCommGroup M₂] [Module R M₂]
    (d₁ : M₁ →ₗ[R] M₀) (d₂ : M₂ →ₗ[R] M₁)
    (h : d₁ ∘ₗ d₂ = 0) :
    ∀ x : M₂, d₁ (d₂ x) = 0 := by
  exact fun x => LinearMap.congr_fun h x

/-! ## Section 4: Kirchhoff's Current Law as a Cycle Condition

KCL states that at each node, the sum of currents is zero.
Algebraically, this means the current vector lies in the kernel of the
incidence matrix (boundary operator). -/

/-
PROBLEM
KCL: if the incidence matrix maps currents to net flow at nodes,
    then a valid current distribution lies in the kernel.

PROVIDED SOLUTION
The hypothesis hKCL says B.mulVec I = 0. By definition, (B.mulVec I) node = ∑ edge, B node edge * I edge. Since this equals the zero function, each component is 0.
-/

theorem kirchhoff_current_law {n m : ℕ}
    (B : Matrix (Fin n) (Fin m) ℝ)
    (I : Fin m → ℝ)
    (hKCL : B.mulVec I = 0) :
    ∀ node : Fin n, ∑ edge : Fin m, B node edge * I edge = 0 := by
  exact fun node => by simpa only [ Matrix.mulVec, dotProduct ] using congr_fun hKCL node;

/-! ## Section 5: Thévenin-Norton Duality

Every one-port network can be represented as either a Thévenin equivalent
(voltage source + series impedance) or a Norton equivalent (current source +
parallel impedance). The transformation is an involution. -/

/-- A one-port network representation. -/

structure OnePort where
  /-- Open-circuit voltage (Thévenin voltage) -/
  V_th : ℂ
  /-- Internal impedance -/
  Z_th : ℂ
  /-- Z_th is nonzero -/
  hZ : Z_th ≠ 0

/-- Norton current: I_N = V_th / Z_th -/

noncomputable def OnePort.nortonCurrent (p : OnePort) : ℂ := p.V_th / p.Z_th

/-
PROBLEM
The Thévenin-Norton duality is an involution:
    converting Thévenin → Norton → Thévenin gives back the original.

PROVIDED SOLUTION
Unfold OnePort.nortonCurrent. Use div_mul_cancel₀ with p.hZ.
-/

theorem thevenin_norton_involution (p : OnePort) :
    p.nortonCurrent * p.Z_th = p.V_th := by
  exact div_mul_cancel₀ _ p.hZ

/-! ## Section 6: Ohm's Law as Field Multiplication

The most basic algebraic fact: V = IR is multiplication in ℝ (or ℂ for AC). -/

/-- Ohm's law: voltage equals current times resistance (field multiplication). -/

def ohmsLaw (I R : ℝ) : ℝ := I * R

/-- Ohm's law is linear in current (for fixed R). -/

theorem ohmsLaw_linear (R : ℝ) : ∀ I₁ I₂ : ℝ,
    ohmsLaw (I₁ + I₂) R = ohmsLaw I₁ R + ohmsLaw I₂ R := by
  intro I₁ I₂
  unfold ohmsLaw
  ring

/-- Power dissipation P = I²R (derived from V = IR and P = VI). -/

def powerDissipation (I R : ℝ) : ℝ := I ^ 2 * R

/-
PROBLEM
Power is non-negative for non-negative resistance.

PROVIDED SOLUTION
Unfold powerDissipation. I^2 is nonneg (sq_nonneg), and R ≥ 0 by hypothesis, so their product is nonneg (mul_nonneg).
-/

theorem power_nonneg (I R : ℝ) (hR : 0 ≤ R) : 0 ≤ powerDissipation I R := by
  exact mul_nonneg ( sq_nonneg I ) hR

/-! ## Section 7: The Betti Number Formula

For a connected graph with n nodes and m edges, the first Betti number
(number of independent loops) is β₁ = m - n + 1. -/

/-- The first Betti number of a connected graph. -/

def bettiOne (n_nodes n_edges : ℕ) : ℤ := n_edges - n_nodes + 1

/-
PROBLEM
For a tree (connected graph with no loops), β₁ = 0,
    which means m = n - 1.

PROVIDED SOLUTION
Unfold bettiOne. This reduces to (n-1 : ℤ) - n + 1 = 0. Use omega, being careful about the ℕ to ℤ coercion of n-1.
-/

theorem tree_betti_zero (n : ℕ) (hn : 0 < n) :
    bettiOne n (n - 1) = 0 := by
  grind +locals

/-
PROBLEM
Adding an edge to a connected graph increases β₁ by 1.

PROVIDED SOLUTION
Unfold bettiOne. The goal becomes (m+1:ℤ) - n + 1 = (m:ℤ) - n + 1 + 1. omega.
-/

theorem add_edge_increases_betti (n m : ℕ) :
    bettiOne n (m + 1) = bettiOne n m + 1 := by
  unfold bettiOne; omega;

end
