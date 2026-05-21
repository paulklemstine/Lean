/-
# Zero-Free Region Infrastructure for Zeta-Like Functions

This module defines the core structures and definitions for a formal framework
that transfers zero-free region hypotheses to arithmetic consequences.

The key abstraction is `LogZeroFreeDatum`, which packages a meromorphic function
with a logarithmic zero-free region of the classical form:
  F(s) ≠ 0 for Re(s) > 1 - c / log(|Im(s)| + 2)

This is deliberately abstract to support future instantiation to:
- The Riemann zeta function
- Dirichlet L-functions
- Selberg zeta functions
- Dynamical zeta functions
-/

import Mathlib

open Complex Real Filter Asymptotics Topology

/-! ## Core Structure: Logarithmic Zero-Free Datum -/

/-- A `LogZeroFreeDatum` packages a complex-valued function `F` together with
a logarithmic zero-free region hypothesis. The region is of the classical form:
  F(s) ≠ 0 whenever |Im(s)| ≥ T₀ and Re(s) > 1 - c / log(|Im(s)| + 2).

This is the standard shape of zero-free regions for the Riemann zeta function
and Dirichlet L-functions, with `c` being the zero-free region constant. -/
structure LogZeroFreeDatum where
  /-- The complex-valued function (e.g., Riemann zeta, Dirichlet L-function) -/
  F : ℂ → ℂ
  /-- Zero-free region constant -/
  c : ℝ
  /-- Height threshold below which the zero-free region may not apply -/
  T0 : ℝ
  /-- The constant is positive -/
  c_pos : 0 < c
  /-- The height threshold is nonneg -/
  T0_nonneg : 0 ≤ T0
  /-- The zero-free region: F(s) ≠ 0 in the specified region -/
  zero_free :
    ∀ s : ℂ, T0 ≤ |s.im| →
      1 - c / Real.log (|s.im| + 2) < s.re →
      F s ≠ 0

/-! ## No-Zeros Predicate -/

/-- `NoZerosUpToHeight F σ T` means F has no zeros in the half-strip
  { s : ℂ | Re(s) > σ and |Im(s)| ≤ T }. -/
def NoZerosUpToHeight (F : ℂ → ℂ) (σ T : ℝ) : Prop :=
  ∀ s : ℂ, σ < s.re → |s.im| ≤ T → F s ≠ 0

/-! ## Prime Error Profile -/

/-- A `PrimeErrorProfile E` asserts that the error function E satisfies
  |E(x)| ≤ x · exp(-√(log x) / 10) for x ≥ 2.
This is the shape of the prime-counting error in the prime number theorem
with classical zero-free region. -/
def PrimeErrorProfile (E : ℝ → ℝ) : Prop :=
  ∀ x : ℝ, 2 ≤ x → |E x| ≤ x * Real.exp (-Real.sqrt (Real.log x) / 10)

/-! ## Prime Counting Transfer Datum -/

/-- A `PrimeCountingTransferDatum` packages a prime-counting error function
together with an exponential decay bound. This is the abstract version of the
classical de la Vallée-Poussin error term. -/
structure PrimeCountingTransferDatum where
  /-- The error in ψ(x) - x (Chebyshev psi minus identity) -/
  psiError : ℝ → ℝ
  /-- Leading constant -/
  A : ℝ
  /-- Decay rate constant -/
  B : ℝ
  /-- A is positive -/
  A_pos : 0 < A
  /-- B is positive -/
  B_pos : 0 < B
  /-- The transfer bound: |ψ(x) - x| ≤ A · x · exp(-B · √(log x)) -/
  transfer :
    ∀ x : ℝ, 2 ≤ x →
      |psiError x| ≤ A * x * Real.exp (-B * Real.sqrt (Real.log x))

/-! ## Riemann-von Mangoldt Asymptotic -/

/-- `IsRiemannVonMangoldtAsymptotic N` asserts that the zero-counting function
N(T) satisfies the Riemann-von Mangoldt asymptotic:
  N(T) ~ (T/(2π)) · log(T/(2πe)) as T → ∞. -/
noncomputable def rvmMainTerm (T : ℝ) : ℝ :=
  (T / (2 * Real.pi)) * Real.log (T / (2 * Real.pi * Real.exp 1))

def IsRiemannVonMangoldtAsymptotic (N : ℝ → ℝ) : Prop :=
  Tendsto (fun T => N T / rvmMainTerm T) atTop (𝓝 1)

/-! ## Riemann Zeta Zero-Free Region -/

/-- `RiemannZetaZeroFreeRegion c T0` is the proposition that the Riemann zeta
function has no zeros in the region
  Re(s) > 1 - c / log(|Im(s)| + 2) for |Im(s)| ≥ T0. -/
def RiemannZetaZeroFreeRegion (c T0 : ℝ) : Prop :=
  0 < c ∧ 0 ≤ T0 ∧
  ∀ s : ℂ, T0 ≤ |s.im| →
    1 - c / Real.log (|s.im| + 2) < s.re →
    riemannZeta s ≠ 0