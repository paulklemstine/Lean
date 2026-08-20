/-
# Freeness over `ℤ_p[G]` is detected by the Solomon–Möbius weights

This file combines the two results of the present cycle:

* conjecture **D2** (`SolomonZeta.isLocalRing_padicMonoidAlgebra`): for a finite commutative
  group `G` of exponent a power of `p`, the group ring `Λ = ℤ_p[G]` is a local ring with residue
  field `𝔽_p`;
* conjecture **D5** (`SolomonZeta.nonempty_linearEquiv_free_iff_mobiusWeight_eq`): over a
  noetherian local ring with finite residue field, the Möbius weights of a finitely generated
  module characterise freeness.

The missing link is that `Λ` is noetherian, which follows from module-finiteness over the
noetherian ring `ℤ_p` (`IsNoetherianRing.of_finite`).  The outcome
(`SolomonZeta.nonempty_linearEquiv_free_iff_mobiusWeight_eq_padicMonoidAlgebra`) is a purely
counting criterion for freeness over a non-maximal, non-domain arithmetic order: a finitely
generated `Λ`-module `M` is free of rank `n` if and only if for every finite `Λ`-module `X`

  `Σ_{Y ≤ X} μ(Y, X)·#Hom(M, Y) = (∏_{i<d}(pⁿ - p^i))·#(𝔪X)ⁿ`,   `d = dim_{𝔽_p} X/𝔪X`,

i.e. iff `M` has the Solomon coefficients of `Λⁿ`.  Specialised to `Λ = ℤ_p[ℤ/pℤ]` this
separates the free lattice `Λ` from the two other indecomposable `Λ`-lattices `ℤ_p` and
`ℤ_p[ζ_p]` by a Möbius-weight computation alone.
-/
import Catalog.NumberTheory.SolomonZetaPadicGroupRing
import Catalog.NumberTheory.SolomonZetaFreenessCriterion

namespace SolomonZeta

open IsLocalRing Module

variable {p : ℕ} [Fact p.Prime] {G : Type} [CommMonoid G]

/-- `ℤ_p[G]` is a noetherian ring for `G` finite: it is module-finite over `ℤ_p`. -/
theorem isNoetherianRing_padicMonoidAlgebra [Finite G] :
    IsNoetherianRing (MonoidAlgebra ℤ_[p] G) :=
  IsNoetherianRing.of_finite ℤ_[p] _

/-- **Freeness over the group ring `Λ = ℤ_p[G]` is detected by the Möbius weights.**  Let `p` be
a prime, `G` a finite commutative group of exponent dividing `pᵉ`, and `M` a finitely generated
`Λ`-module.  Then `M` is free of rank `n` if and only if for every finite `Λ`-module `X`

  `Σ_{Y ≤ X} μ(Y, X)·#Hom(M, Y) = (∏_{i<d}(pⁿ - p^i))·#(𝔪X)ⁿ`,   `d = dim_{𝔽_p} X/𝔪X`,

that is, iff `M` has the Solomon coefficients of the free lattice `Λⁿ`. -/
theorem nonempty_linearEquiv_free_iff_mobiusWeight_eq_padicMonoidAlgebra [Finite G] {e : ℕ}
    (hG : ∀ g : G, g ^ p ^ e = 1)
    (M : Type) [AddCommGroup M] [Module (MonoidAlgebra ℤ_[p] G) M]
    [Module.Finite (MonoidAlgebra ℤ_[p] G) M] (n : ℕ) :
    letI := isLocalRing_padicMonoidAlgebra (p := p) (G := G) hG
    Nonempty (M ≃ₗ[MonoidAlgebra ℤ_[p] G] (Fin n → MonoidAlgebra ℤ_[p] G)) ↔
      ∀ (X : Type) [AddCommGroup X] [Module (MonoidAlgebra ℤ_[p] G) X] [Finite X]
        [Module.Finite (MonoidAlgebra ℤ_[p] G) X],
        mobiusWeight (MonoidAlgebra ℤ_[p] G) M X
          = ((∏ i : Fin (finrank (ResidueField (MonoidAlgebra ℤ_[p] G))
                (ResQuot (MonoidAlgebra ℤ_[p] G) X)), (p ^ n - p ^ (i : ℕ)))
              * Nat.card ↥((maximalIdeal (MonoidAlgebra ℤ_[p] G))
                  • (⊤ : Submodule (MonoidAlgebra ℤ_[p] G) X)) ^ n : ℕ) := by
  letI := isLocalRing_padicMonoidAlgebra (p := p) (G := G) hG
  letI eqf := residueFieldPadicMonoidAlgebraEquiv (p := p) (G := G) hG
  letI : Fintype (ResidueField (MonoidAlgebra ℤ_[p] G)) :=
    Fintype.ofEquiv (ZMod p) eqf.toEquiv.symm
  haveI := isNoetherianRing_padicMonoidAlgebra (p := p) (G := G)
  have hcard : Fintype.card (ResidueField (MonoidAlgebra ℤ_[p] G)) = p := by
    rw [Fintype.card_congr eqf.toEquiv, ZMod.card]
  have hfw : ∀ (X : Type) [AddCommGroup X] [Module (MonoidAlgebra ℤ_[p] G) X],
      freeMobiusWeight (MonoidAlgebra ℤ_[p] G) n X
        = (∏ i : Fin (finrank (ResidueField (MonoidAlgebra ℤ_[p] G))
              (ResQuot (MonoidAlgebra ℤ_[p] G) X)), (p ^ n - p ^ (i : ℕ)))
            * Nat.card ↥((maximalIdeal (MonoidAlgebra ℤ_[p] G))
                • (⊤ : Submodule (MonoidAlgebra ℤ_[p] G) X)) ^ n := by
    intro X _ _
    rw [freeMobiusWeight, hcard]
  constructor
  · intro h X _ _ _ _
    have := (nonempty_linearEquiv_free_iff_mobiusWeight_eq_of_isNoetherianRing
      (R := MonoidAlgebra ℤ_[p] G) (M := M) n).1 h X
    rwa [hfw X] at this
  · intro h
    refine (nonempty_linearEquiv_free_iff_mobiusWeight_eq_of_isNoetherianRing
      (R := MonoidAlgebra ℤ_[p] G) (M := M) n).2 ?_
    intro X _ _ _ _
    rw [hfw X]
    exact h X

/-- **The case `Λ = ℤ_p[ℤ/pℤ]`.**  A finitely generated module over the group ring of the cyclic
group of order `p` over `ℤ_p` is free of rank `n` exactly when its Möbius weights coincide with
the Solomon coefficients of `Λⁿ` at every finite quotient type. -/
theorem nonempty_linearEquiv_free_iff_mobiusWeight_eq_padicCyclic
    (M : Type) [AddCommGroup M]
    [Module (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) M]
    [Module.Finite (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) M] (n : ℕ) :
    letI := isLocalRing_padicMonoidAlgebra (p := p) (G := Multiplicative (ZMod p))
      pow_card_multiplicative_zmod
    Nonempty (M ≃ₗ[MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))]
        (Fin n → MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p)))) ↔
      ∀ (X : Type) [AddCommGroup X]
        [Module (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X] [Finite X]
        [Module.Finite (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X],
        mobiusWeight (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) M X
          = ((∏ i : Fin (finrank
                (ResidueField (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))))
                (ResQuot (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X)),
                  (p ^ n - p ^ (i : ℕ)))
              * Nat.card ↥((maximalIdeal (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))))
                  • (⊤ : Submodule (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X)) ^ n : ℕ) :=
  nonempty_linearEquiv_free_iff_mobiusWeight_eq_padicMonoidAlgebra
    pow_card_multiplicative_zmod M n

end SolomonZeta