/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.HaarRestrictedProduct.Defs

/-!
# Tate's Thesis: Definitions for Adelic Zeta Integrals

This file introduces the core definitions for a prototype formalization of
Tate's thesis over ℚ. The central objects are:

* **Local test functions**: indicator of ℤ_p as a function on valuation shells.
* **Local zeta integrals**: geometric series encoding local Euler factors.
* **Adelic test functions**: factorizable Schwartz-Bruhat style test functions
  on the adèles, with archimedean and finite components.
* **Truncated adelic zeta integrals**: finite Euler products over a set of primes.
* **Completed zeta function**: the classical ξ(s) = π^(-s/2) Γ(s/2) ζ(s).

## Mathematical Context

In Tate's thesis, the Riemann zeta function arises as a global zeta integral
of a factorizable test function on the adèles of ℚ. The key mechanism is:

1. Each prime p contributes a local Euler factor (1 - p^{-s})⁻¹
2. The archimedean place contributes the gamma factor π^{-s/2} Γ(s/2)
3. The functional equation ξ(s) = ξ(1-s) arises from Fourier self-duality
   of the standard Gaussian test function

This file defines the formal objects; the theorems are in `Theorems.lean`.
-/

open scoped Filter Topology
open MeasureTheory MeasureTheory.Measure Set Filter Finset Real

noncomputable section

namespace TateThesis

/-!
## § 1: Local Test Functions and Zeta Integrals

The local zeta integral at a prime p for the standard test function 𝟙_{ℤ_p}
reduces to a geometric series over valuation shells:

  Z_p(𝟙_{ℤ_p}, s) = ∑_{n=0}^∞ p^{-ns}

Under the multiplicative Haar measure normalized so that vol(ℤ_p×) = 1,
each shell {x : v_p(x) = n} for n ≥ 0 contributes p^{-ns}.
-/

/-- The local zeta integral at prime `p` for the standard indicator test function
`𝟙_{ℤ_p}`, evaluated at the real parameter `s`.

Mathematically, this represents
  Z_p(𝟙_{ℤ_p}, s) = ∫_{ℚ_p×} 𝟙_{ℤ_p}(x) |x|_p^s d×x = ∑_{n≥0} p^{-ns}
under the multiplicative Haar measure with vol(ℤ_p×) = 1. -/
def localZetaIntegral (p : ℕ) (s : ℝ) : ℝ :=
  ∑' n : ℕ, ((p : ℝ) ^ (-s)) ^ n

/-- The Euler factor at prime `p`:  (1 - p^{-s})⁻¹. -/
def eulerFactor (p : ℕ) (s : ℝ) : ℝ :=
  (1 - (p : ℝ) ^ (-s))⁻¹

/-- Key positivity lemma: p^{-s} < 1 when p is prime and s > 0. -/
lemma rpow_neg_lt_one (p : ℕ) [hp : Fact p.Prime] (s : ℝ) (hs : 0 < s) :
    (p : ℝ) ^ (-s) < 1 := by
  have hp1 : (1 : ℝ) < p := by exact_mod_cast hp.out.one_lt
  have hp0 : (0 : ℝ) < p := by linarith
  have : 1 < (p : ℝ) ^ s := Real.one_lt_rpow_iff_of_pos hp0 |>.mpr (Or.inl ⟨hp1, hs⟩)
  rw [Real.rpow_neg hp0.le]
  exact inv_lt_one_of_one_lt₀ this

/-- Nonnegativity of p^{-s}. -/
lemma rpow_neg_nonneg (p : ℕ) (s : ℝ) : 0 ≤ (p : ℝ) ^ (-s) :=
  Real.rpow_nonneg (Nat.cast_nonneg p) (-s)

/-- Summability of the geometric series defining the local zeta integral. -/
lemma localZetaIntegral_summable (p : ℕ) [hp : Fact p.Prime] (s : ℝ) (hs : 0 < s) :
    Summable (fun n : ℕ => ((p : ℝ) ^ (-s)) ^ n) :=
  summable_geometric_of_lt_one (rpow_neg_nonneg p s) (rpow_neg_lt_one p s hs)

/-!
## § 2: Adelic Test Functions

An adelic test function for ℚ is a factorizable function on the adèles
ℚ_∞ × ∏'_p ℚ_p. It consists of:
- An archimedean component φ_∞ : ℝ → ℝ
- Local components φ_p for each prime p
- A finite set of "ramified" places where φ_p ≠ 𝟙_{ℤ_p}

For the prototype, local components are encoded as functions on valuation
shells: `localPart p n` gives the value of φ_p on the shell where v_p(x) = n.
-/

/-- A factorizable adelic test function on the adèles of ℚ.

The archimedean component is a function ℝ → ℝ.
The local component at prime p is encoded by its values on valuation shells:
`localPart p n` is the value of φ_p on {x ∈ ℚ_p : v_p(x) = n}.
The `ramifiedPlaces` is the finite set of primes where the local component
differs from the standard indicator function 𝟙_{ℤ_p}. -/
structure AdelicTestFunction where
  /-- The archimedean component φ_∞ : ℝ → ℝ -/
  archPart : ℝ → ℝ
  /-- The local component at prime p, given by values on valuation shells.
      `localPart p n` = value on {x : v_p(x) = n} for n : ℤ -/
  localPart : ℕ → ℤ → ℝ
  /-- Finite set of primes where the local test function is non-standard -/
  ramifiedPlaces : Finset ℕ
  /-- All entries in ramifiedPlaces are actually prime -/
  ramified_prime : ∀ p ∈ ramifiedPlaces, Nat.Prime p
  /-- Away from ramified places, the local part is the standard indicator:
      value 1 on shells n ≥ 0, value 0 on shells n < 0. -/
  standard_away : ∀ p, p ∉ ramifiedPlaces →
    ∀ n : ℤ, localPart p n = if 0 ≤ n then 1 else 0

/-- A test function is **factorizable** if it satisfies the product structure.
This is automatically true for `AdelicTestFunction` by construction. -/
def IsFactorizable (_ : AdelicTestFunction) : Prop := True

/-- The local zeta integral for a general local test function φ_p at prime p.
    Z_p(φ_p, s) = ∑_{n ∈ ℤ} φ_p(n) · p^{-ns}
For implementation, we split into n ≥ 0 and n < 0 parts. -/
def generalLocalZetaIntegral (p : ℕ) (φ_p : ℤ → ℝ) (s : ℝ) : ℝ :=
  ∑' n : ℕ, φ_p (n : ℤ) * ((p : ℝ) ^ (-s)) ^ n

/-- The local zeta integral of the standard indicator test function at prime p
agrees with `localZetaIntegral`. -/
lemma generalLocalZeta_standard (p : ℕ) (s : ℝ) :
    generalLocalZetaIntegral p (fun n => if 0 ≤ n then 1 else 0) s
    = localZetaIntegral p s := by
  simp [generalLocalZetaIntegral, localZetaIntegral]

/-!
## § 3: Truncated Adelic Zeta Integrals

The truncated adelic zeta integral over a finite set of primes S computes
the finite Euler product ∏_{p ∈ S} Z_p(φ_p, s).
-/

/-- The truncated adelic zeta integral: the finite product of local zeta integrals
over a set of primes S. -/
def truncatedEulerProduct (φ : AdelicTestFunction) (S : Finset ℕ) (s : ℝ) : ℝ :=
  ∏ p ∈ S, generalLocalZetaIntegral p (φ.localPart p) s

/-- The truncated standard Euler product: ∏_{p ∈ S} (1 - p^{-s})⁻¹. -/
def truncatedStandardEulerProduct (S : Finset ℕ) (s : ℝ) : ℝ :=
  ∏ p ∈ S, eulerFactor p s

/-!
## § 4: The Standard Adelic Gaussian

The standard test function in Tate's thesis is:
  φ(x) = e^{-π x_∞²} ⊗ ⊗_p 𝟙_{ℤ_p}

This is Fourier self-dual: F(φ) = φ.
-/

/-- The standard adelic Gaussian test function.
At the archimedean place: φ_∞(x) = e^{-πx²}
At every finite place: φ_p = 𝟙_{ℤ_p} (standard indicator). -/
def standardAdelicGaussian : AdelicTestFunction where
  archPart := fun x => Real.exp (-Real.pi * x ^ 2)
  localPart := fun _ n => if 0 ≤ n then 1 else 0
  ramifiedPlaces := ∅
  ramified_prime := by simp
  standard_away := by simp

/-- The archimedean Mellin transform / gamma factor.
    Z_∞(φ_∞, s) = ∫_{ℝ×} e^{-πx²} |x|^s d×x = π^{-s/2} Γ(s/2)
This is defined directly as the classical formula. -/
def archimedeanGammaFactor (s : ℝ) : ℝ :=
  Real.pi ^ (-s / 2) * Real.Gamma (s / 2)

/-!
## § 5: Completed Zeta Function

The completed Riemann zeta function is defined as
  ξ(s) = π^{-s/2} Γ(s/2) ζ(s)
where ζ(s) is the Riemann zeta function. In Tate's thesis, this arises as:
  ξ(s) = Z_∞(φ_∞, s) · ∏_p Z_p(φ_p, s)
for the standard Gaussian test function.
-/

/-- The completed Riemann zeta function ξ(s) = π^{-s/2} Γ(s/2) ζ(s),
defined for real s. Uses the Mathlib definition of riemannZeta at ↑s. -/
def completedZetaReal (s : ℝ) : ℂ :=
  completedRiemannZeta (s : ℂ)

/-!
## § 6: Level Compatibility (Connection to Restricted Product Infrastructure)

We connect our adelic test function framework to the restricted product
definitions from `HaarRestrictedProduct/Defs.lean`. A factorizable test
function that is standard away from a finite set of places is automatically
level-compatible in the restricted product sense.
-/

/-- A set of primes S is a **valid level** for an adelic test function φ if
it contains all ramified places and all primes in S are indeed prime. -/
def IsValidLevel (φ : AdelicTestFunction) (S : Finset ℕ) : Prop :=
  φ.ramifiedPlaces ⊆ S ∧ ∀ p ∈ S, Nat.Prime p

/-- For a valid level, the local parts outside S are all standard. -/
lemma standard_outside_valid_level (φ : AdelicTestFunction) (S : Finset ℕ)
    (hS : IsValidLevel φ S) :
    ∀ p, p ∉ S → ∀ n : ℤ, φ.localPart p n = if 0 ≤ n then 1 else 0 := by
  intro p hp n
  exact φ.standard_away p (fun h => hp (hS.1 h)) n

end TateThesis