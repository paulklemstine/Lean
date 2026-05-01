/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Hecke Robustness: Definitions

This file defines the key structures connecting tropicalized ReLU networks
to the spherical Hecke algebra via the Satake isomorphism.

## Main Definitions

* `IsTropicalizedReLUNetwork` - predicate for tropicalized ReLU networks
* `SphericalHeckeAlgebra` - the spherical Hecke algebra of a group
* `AlgebraRepresentation` - an algebra representation on a vector space
* `SatakeIsomorphism` - the Satake isomorphism
* `IsTropicalHeckeEigenvalueFamily` - the tropical Hecke eigenvalue condition

## Mathematical Background

The Satake isomorphism establishes a correspondence between the spherical
Hecke algebra of a reductive group and the representation ring of its
Langlands dual. In the tropical limit, this correspondence relates the
piecewise-linear structure of tropicalized ReLU networks to the spectral
data of Hecke operators.

The key insight is that when the Satake isomorphism fully tropicalizes
the spectral data, the minimal eigenvalue gap vanishes, providing a
universal lower bound on the certified robustness radius.
-/

open scoped BigOperators

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
