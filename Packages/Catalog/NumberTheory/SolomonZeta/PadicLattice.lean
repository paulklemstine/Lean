/-
# Solomon coefficients of free `ℤ_p`-lattices

Specialisation of the local formula of `Shared.SolomonZeta.LocalOrder` to the maximal order
`ℤ_p` of the nonarchimedean local field `ℚ_p`, which is the base case of the paper's setting:
for every finite `ℤ_p`-module `X` and every rank `n`,

  `#Aut(X) · #{N ≤ ℤ_pⁿ : ℤ_pⁿ/N ≅ X}  =  (∏_{i<d} (pⁿ - p^i)) · #(pX)ⁿ`,   `d = dim_{𝔽_p} X/pX`.

So the refined Solomon coefficient of a free lattice over the maximal order is completely
determined by the two residual invariants `#pX` and `dim_{𝔽_p} X/pX` of the quotient type; the
`p`-adic valuation of `#X` enters only through `#pX`.

Main results:
* `SolomonZeta.autCard_mul_quotIsoCount_padic_free` — the formula above;
* `SolomonZeta.autCard_mul_quotIsoCount_padic_free_of_smul_eq_bot` — the elementary abelian
  case `pX = 0`, where the coefficient is exactly the Gaussian-binomial numerator;
* `SolomonZeta.quotIsoCount_padic_free_eq_zero` — vanishing when `X` needs more than `n`
  generators.
-/
import Catalog.Shared.SolomonZeta.LocalOrder

namespace SolomonZeta

open IsLocalRing Module

variable (p : ℕ) [Fact p.Prime] (X : Type*) [AddCommGroup X] [Module ℤ_[p] X] [Finite X]
  [Module.Finite ℤ_[p] X]

/-- The residue field of `ℤ_p` is `𝔽_p`, in particular finite. -/
noncomputable instance fintypeResidueFieldPadicInt : Fintype (ResidueField ℤ_[p]) :=
  Fintype.ofEquiv (ZMod p) PadicInt.residueField.symm.toEquiv

theorem card_residueField_padicInt : Fintype.card (ResidueField ℤ_[p]) = p := by
  rw [Fintype.card_congr PadicInt.residueField.toEquiv, ZMod.card]

/-- **Solomon coefficients of the free `ℤ_p`-lattice of rank `n`.**  For every finite
`ℤ_p`-module `X`,

  `#Aut(X) · #{N ≤ ℤ_pⁿ : ℤ_pⁿ/N ≅ X} = (∏_{i<d}(pⁿ - p^i)) · #(pX)ⁿ`,

where `d = dim_{𝔽_p} X/pX` is the minimal number of generators of `X`. -/
theorem autCard_mul_quotIsoCount_padic_free (n : ℕ) :
    autCard ℤ_[p] X * quotIsoCount ℤ_[p] (Fin n → ℤ_[p]) X
      = (∏ i : Fin (finrank (ResidueField ℤ_[p]) (ResQuot ℤ_[p] X)), (p ^ n - p ^ (i : ℕ)))
        * Nat.card ↥((Ideal.span {(p : ℤ_[p])}) • (⊤ : Submodule ℤ_[p] X)) ^ n := by
  have hrad : Nat.card ↥((maximalIdeal ℤ_[p]) • (⊤ : Submodule ℤ_[p] X))
      = Nat.card ↥((Ideal.span {(p : ℤ_[p])}) • (⊤ : Submodule ℤ_[p] X)) := by
    rw [PadicInt.maximalIdeal_eq_span_p]
  rw [autCard_mul_quotIsoCount_free_local, card_residueField_padicInt, hrad]

/-- If `pX = 0`, i.e. `X` is an `𝔽_p`-vector space of dimension `d`, the Solomon coefficient of
`ℤ_pⁿ` at `X` is the Gaussian-binomial numerator `∏_{i<d}(pⁿ - p^i)`. -/
theorem autCard_mul_quotIsoCount_padic_free_of_smul_eq_bot (n : ℕ)
    (h : (Ideal.span {(p : ℤ_[p])}) • (⊤ : Submodule ℤ_[p] X) = ⊥) :
    autCard ℤ_[p] X * quotIsoCount ℤ_[p] (Fin n → ℤ_[p]) X
      = ∏ i : Fin (finrank (ResidueField ℤ_[p]) (ResQuot ℤ_[p] X)), (p ^ n - p ^ (i : ℕ)) := by
  have hone : Nat.card ↥((Ideal.span {(p : ℤ_[p])}) • (⊤ : Submodule ℤ_[p] X)) = 1 := by
    rw [h]
    simp
  rw [autCard_mul_quotIsoCount_padic_free, hone, one_pow, mul_one]

/-- A finite `ℤ_p`-module needing more than `n` generators is not a quotient of `ℤ_pⁿ`. -/
theorem quotIsoCount_padic_free_eq_zero (n : ℕ)
    (hn : n < finrank (ResidueField ℤ_[p]) (ResQuot ℤ_[p] X)) :
    quotIsoCount ℤ_[p] (Fin n → ℤ_[p]) X = 0 :=
  quotIsoCount_free_local_eq_zero n hn

end SolomonZeta