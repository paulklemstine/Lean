/-! # CatalogBuild.Tropical.Satake.Defs

Auto-generated from theorem catalog database.
Domain: Tropical/Satake
Declarations: 8
-/

import Mathlib

noncomputable section

/-- The tropical semiring: min-plus algebra over integers with ⊤.
Addition is min, multiplication is +. -/
abbrev T := Tropical (WithTop ℤ)


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


/-- The tropical polynomial ring in 3 variables. -/
noncomputable abbrev TropPoly := MvPolynomial (Fin 3) T


/-- The k-th tropical elementary symmetric polynomial. -/
noncomputable def tropicalESymm (k : ℕ) : TropPoly :=
  MvPolynomial.esymm (Fin 3) T k


/-- The tropical monomial for a coweight mu and permutation σ:
x₁^{μ_{σ(1)}} · x₂^{μ_{σ(2)}} · x₃^{μ_{σ(3)}} -/
noncomputable def tropicalMonomialPerm (mu : DominantCoweight) (σ : Equiv.Perm (Fin 3)) :
    TropPoly :=
  ∏ i : Fin 3, MvPolynomial.X (R := T) i ^ (mu.val (σ i)).toNat


/-- The tropical Satake transform sends a double-coset indicator 𝟙_{Kλ(π)K}
to the tropical Schur polynomial s_λ^{trop}(x₁,x₂,x₃). -/
noncomputable def tropicalSatakeMap (mu : DominantCoweight) : TropPoly :=
  tropicalSchurPolynomial mu

end
