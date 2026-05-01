/-
# Tropical Satake Isomorphism for GL₃: Core Definitions

This file defines the core structures needed for the tropical Satake isomorphism:
- The tropical semiring T = Tropical(WithTop ℤ) (min-plus algebra)
- Dominant coweights for GL₃
- Tropical symmetric polynomials
- The tropical Hecke algebra (combinatorial model)
- The tropical Satake transform
-/
import Mathlib

open scoped BigOperators

set_option maxHeartbeats 800000

/-! ## The tropical semiring -/

/-- The tropical semiring: min-plus algebra over integers with ⊤.
    Addition is min, multiplication is +. -/
abbrev T := Tropical (WithTop ℤ)

noncomputable instance : CommSemiring T := inferInstance

/-! ## Dominant coweights for GL₃ -/

/-- A dominant coweight for GL₃ is a weakly decreasing triple of integers (λ₁ ≥ λ₂ ≥ λ₃). -/
structure DominantCoweight where
  val : Fin 3 → ℤ
  decreasing : val 0 ≥ val 1 ∧ val 1 ≥ val 2
  deriving DecidableEq

namespace DominantCoweight

/-- The fundamental coweight ω₁ = (1,0,0). -/
def omega1 : DominantCoweight where
  val := ![1, 0, 0]
  decreasing := by decide

/-- The fundamental coweight ω₂ = (1,1,0). -/
def omega2 : DominantCoweight where
  val := ![1, 1, 0]
  decreasing := by decide

/-- The fundamental coweight ω₃ = (1,1,1). -/
def omega3 : DominantCoweight where
  val := ![1, 1, 1]
  decreasing := by decide

/-- The zero coweight (0,0,0). -/
def zero : DominantCoweight where
  val := ![0, 0, 0]
  decreasing := by decide

/-- Addition of dominant coweights (componentwise). -/
def add (mu nu : DominantCoweight) : DominantCoweight where
  val := mu.val + nu.val
  decreasing := by
    constructor <;> simp [Pi.add_apply]
    · exact add_le_add mu.decreasing.1 nu.decreasing.1
    · exact add_le_add mu.decreasing.2 nu.decreasing.2

instance : Add DominantCoweight := ⟨add⟩

end DominantCoweight

/-! ## Tropical polynomial ring and symmetric polynomials -/

/-- The tropical polynomial ring in 3 variables. -/
noncomputable abbrev TropPoly := MvPolynomial (Fin 3) T

/-- The k-th tropical elementary symmetric polynomial. -/
noncomputable def tropicalESymm (k : ℕ) : TropPoly :=
  MvPolynomial.esymm (Fin 3) T k

/-! ## Tropical monomial symmetric polynomials -/

/-- The tropical monomial for a coweight mu and permutation σ:
    x₁^{μ_{σ(1)}} · x₂^{μ_{σ(2)}} · x₃^{μ_{σ(3)}} -/
noncomputable def tropicalMonomialPerm (mu : DominantCoweight) (σ : Equiv.Perm (Fin 3)) :
    TropPoly :=
  ∏ i : Fin 3, MvPolynomial.X (R := T) i ^ (mu.val (σ i)).toNat

/-- The tropical monomial symmetric polynomial (orbit sum) for a dominant coweight.
    This is the tropicalization of the classical monomial symmetric polynomial. -/
noncomputable def tropicalSchurPolynomial (mu : DominantCoweight) : TropPoly :=
  ∑ σ : Equiv.Perm (Fin 3), tropicalMonomialPerm mu σ

/-! ## The tropical Satake transform -/

/-- The tropical Satake transform sends a double-coset indicator 𝟙_{Kλ(π)K}
    to the tropical Schur polynomial s_λ^{trop}(x₁,x₂,x₃). -/
noncomputable def tropicalSatakeMap (mu : DominantCoweight) : TropPoly :=
  tropicalSchurPolynomial mu