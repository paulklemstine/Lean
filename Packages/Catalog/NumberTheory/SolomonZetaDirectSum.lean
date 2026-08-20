/-
# Möbius weights of direct sums (towards conjecture D3)

Conjecture **D3** of the Solomon-zeta thread predicts that for a decomposable lattice
`M = ⊕ Mᵢ` the Möbius weight `Σ_{Y ≤ X} μ(Y, X)·#Hom(M, Y)` is determined by the Hom-count
functions `Y ↦ #Hom(Mᵢ, Y)` of the summands.  This file proves exactly that, in the two forms
needed downstream:

* `SolomonZeta.card_hom_pi` — `#Hom(⊕_{i<m} Mᵢ, Y) = ∏_i #Hom(Mᵢ, Y)`, so Hom-counts are
  multiplicative along finite direct sums;
* `SolomonZeta.mobiusWeight_pi` — hence
  `Σ_{Y ≤ X} μ(Y, X)·#Hom(⊕Mᵢ, Y) = Σ_{Y ≤ X} μ(Y, X)·∏_i #Hom(Mᵢ, Y)`;
* `SolomonZeta.mobiusWeight_congr_of_card_hom_eq` — the Möbius weight of `(M, X)` depends on `M`
  only through the function `Y ↦ #Hom(M, Y)` on the submodule poset of `X`.

Together these reduce the Solomon coefficients of a decomposable lattice — over any commutative ring, in
particular over `ℤ_p[ℤ/pℤ]`, where every lattice is a direct sum of three indecomposables — to
the Hom-count functions of the indecomposable summands.
-/
import Catalog.Shared.SolomonZeta.Core

namespace SolomonZeta

open Finset IncidenceAlgebra

variable {R : Type*} [CommRing R] {X : Type*} [AddCommGroup X] [Module R X]

/-- **Hom-counts are multiplicative along finite direct sums.** -/
theorem card_hom_pi {m : ℕ} (M : Fin m → Type*) [∀ i, AddCommGroup (M i)]
    [∀ i, Module R (M i)] (Y : Type*) [AddCommGroup Y] [Module R Y] :
    Nat.card ((∀ i, M i) →ₗ[R] Y) = ∏ i, Nat.card (M i →ₗ[R] Y) := by
  rw [← Nat.card_pi]
  exact Nat.card_congr (LinearMap.lsum R M R).symm.toEquiv

/-- **The Möbius weight of a direct sum.**  The weight of `⊕_{i<m} Mᵢ` at `X` is the Möbius sum
of the products of the Hom-counts of the summands. -/
theorem mobiusWeight_pi [Finite X] {m : ℕ} (M : Fin m → Type*) [∀ i, AddCommGroup (M i)]
    [∀ i, Module R (M i)] :
    mobiusWeight R (∀ i, M i) X
      = ∑ Y ∈ Finset.Iic (⊤ : Submodule R X),
          mu ℤ Y ⊤ * ∏ i, (Nat.card (M i →ₗ[R] Y) : ℤ) := by
  refine Finset.sum_congr rfl fun Y _ => ?_
  rw [card_hom_pi M (Y : Type _)]
  push_cast
  ring

/-- **The Möbius weight sees `M` only through its Hom-counts.**  If two modules have the same
number of homomorphisms into every submodule of `X`, their Möbius weights at `X` agree. -/
theorem mobiusWeight_congr_of_card_hom_eq [Finite X] {M M' : Type*} [AddCommGroup M] [Module R M]
    [AddCommGroup M'] [Module R M']
    (h : ∀ Y : Submodule R X, Nat.card (M →ₗ[R] Y) = Nat.card (M' →ₗ[R] Y)) :
    mobiusWeight R M X = mobiusWeight R M' X :=
  Finset.sum_congr rfl fun Y _ => by rw [h Y]

/-- The two-summand case: `#Hom(M₁ ⊕ M₂, Y) = #Hom(M₁, Y)·#Hom(M₂, Y)`. -/
theorem card_hom_prod {M₁ M₂ : Type*} [AddCommGroup M₁] [Module R M₁] [AddCommGroup M₂]
    [Module R M₂] (Y : Type*) [AddCommGroup Y] [Module R Y] :
    Nat.card ((M₁ × M₂) →ₗ[R] Y) = Nat.card (M₁ →ₗ[R] Y) * Nat.card (M₂ →ₗ[R] Y) := by
  rw [← Nat.card_prod]
  exact Nat.card_congr (LinearMap.coprodEquiv R).symm.toEquiv

/-- The Möbius weight of a two-fold direct sum. -/
theorem mobiusWeight_prod [Finite X] {M₁ M₂ : Type*} [AddCommGroup M₁] [Module R M₁]
    [AddCommGroup M₂] [Module R M₂] :
    mobiusWeight R (M₁ × M₂) X
      = ∑ Y ∈ Finset.Iic (⊤ : Submodule R X),
          mu ℤ Y ⊤ * ((Nat.card (M₁ →ₗ[R] Y) : ℤ) * (Nat.card (M₂ →ₗ[R] Y) : ℤ)) := by
  refine Finset.sum_congr rfl fun Y _ => ?_
  rw [card_hom_prod (Y : Type _)]
  push_cast
  ring

end SolomonZeta