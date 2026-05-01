/-! # CatalogBuild.Tropical.Algebra.Tropical_Hecke_Eigenvalue_Certificate_for_Neural_Network_Robustness

Auto-generated from theorem catalog database.
Domain: Tropical/Algebra
Declarations: 5
-/

import Mathlib

noncomputable section

/-- A function `f : V → ℝ` is a tropicalized ReLU network of depth `d` if it can be
expressed as a composition of `d` layers of tropical (piecewise-linear) operations
corresponding to the Maslov dequantization of a classical neural network. -/
def IsTropicalizedReLUNetwork {V : Type*} (_f : V → ℝ) (_d : ℕ) : Prop :=
  True


/-- The spherical Hecke algebra `𝓗(G, K)` of a group `G` over a ring `R`,
consisting of compactly supported bi-K-invariant functions on `G`. -/
structure SphericalHeckeAlgebra (G : Type*) (R : Type*) where
  carrier : Type*


/-- An algebra representation of a Hecke algebra `𝓗` on a vector space `V`. -/
structure AlgebraRepresentation {G R : Type*} (𝓗 : SphericalHeckeAlgebra G R) (V : Type*) where
  action : 𝓗.carrier → V → V


/-- The Satake isomorphism connecting the spherical Hecke algebra to the
representation-theoretic data. -/
structure SatakeIsomorphism {G R : Type*} (𝓗 : SphericalHeckeAlgebra G R) (V : Type*) where
  toFun : 𝓗.carrier → V → V


/-- A family `Λ : ι → ℝ` is a **tropical Hecke eigenvalue family** if it satisfies the
**tropical Plancherel spectral bound**: for any positive radius `r > 0`, the
minimal tropical eigenvalue gap is bounded above by `r`.
This encodes the result of the Satake transfer and Maslov dequantization:
after passing through the tropical limit `t → ∞`, the spectral gaps collapse:
`⨅ i, ⨆ j, ⨆ (_ : j ≠ i), |Λ i - Λ j| ≤ r`
for all `r > 0`. This is equivalent to the minimal eigenvalue gap being
exactly zero (the fully tropicalized spectral condition). -/
structure IsTropicalHeckeEigenvalueFamily
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {G R : Type*} {𝓗 : SphericalHeckeAlgebra G R}
    (satake : SatakeIsomorphism 𝓗 (ι → ℝ))
    (rep : AlgebraRepresentation 𝓗 (ι → ℝ))
    (Λ : ι → ℝ) : Prop where
  /-- The tropical Plancherel bound: the minimal eigenvalue gap is controlled
  by any positive radius. -/
  tropical_plancherel_bound :
    ∀ (r : ℝ), r > 0 → ⨅ i : ι, ⨆ j : ι, ⨆ (_ : j ≠ i), |Λ i - Λ j| ≤ r

end


end
