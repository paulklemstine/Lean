import Mathlib
import Tropical.GroebnerBases
import Tropical.TropicalPointIdeal

/-!
# A nontrivial instance of the tropical Buchberger machinery

`Catalog/Tropical/GroebnerBases.lean` develops tropical ideals as subsemimodules
of the tropical polynomial semiring together with a terminating Buchberger
completion process, but supplies no nontrivial tropical ideal to run it on.
This file closes that gap: the vanishing set of a point (proved to be an ideal in
`Catalog/Tropical/TropicalPointIdeal.lean`, and a *tropical* ideal in the
Maclagan–Rincón sense in the same file) is packaged as a
`TropicalGroebner.TropicalIdeal`, and the finite Buchberger completion theorem is
instantiated on it.

Main results:

* `vanishingSubmodule` : the vanishing set of a point as a subsemimodule of the
  tropical polynomial semiring over the tropical coefficient semiring.
* `exists_buchberger_completion_vanishing` : Buchberger completion terminates on
  the vanishing ideal of a point, producing a Gröbner basis relative to any
  finite test set after at most `U.card` steps.
* `groebnerBasis_of_vanishing_fixedPoint` : being a Gröbner basis for the
  vanishing ideal is exactly being a fixed point of the completion step.
-/

open MvPolynomial

noncomputable section

namespace TropicalPointIdeal

variable {σ : Type*} [Nonempty σ] [DecidableEq σ] (w : σ → ℚ)

/-- The vanishing set of a point as a tropical ideal in the sense of
`Catalog/Tropical/GroebnerBases.lean`: a subsemimodule of the tropical polynomial
semiring over the tropical coefficient semiring. -/
def vanishingSubmodule : TropicalGroebner.TropicalIdeal TropCoeff σ where
  carrier := {f | VanishesAt w f}
  add_mem' := fun hf hg => vanishesAt_add w hf hg
  zero_mem' := vanishesAt_zero w
  smul_mem' := fun c f hf => by
    have h := vanishesAt_mul_left w hf (C c)
    rwa [MvPolynomial.smul_eq_C_mul, mul_comm]

theorem mem_vanishingSubmodule {f : MvPolynomial σ TropCoeff} :
    f ∈ vanishingSubmodule w ↔ VanishesAt w f := Iff.rfl

/-- The two packagings of the vanishing set — as an ideal of the polynomial
semiring and as a subsemimodule over the coefficient semiring — have the same
members. -/
theorem mem_vanishingSubmodule_iff_mem_vanishingIdeal {f : MvPolynomial σ TropCoeff} :
    f ∈ vanishingSubmodule w ↔ f ∈ vanishingIdeal w := Iff.rfl

open scoped MonomialOrder

variable [DecidableEq (MvPolynomial σ TropCoeff)]

/-- **Buchberger completion terminates on the vanishing ideal of a point.**

Starting from any finite family of vanishing polynomials inside a finite test set
`U`, at most `U.card` completion steps produce a Gröbner basis of the vanishing
ideal relative to `U`. -/
theorem exists_buchberger_completion_vanishing (m : MonomialOrder σ)
    (U G₀ : Finset (MvPolynomial σ TropCoeff)) (hG₀U : G₀ ⊆ U)
    (hG₀ : ∀ g ∈ G₀, VanishesAt w g) :
    ∃ n ≤ U.card,
      TropicalGroebner.IsGroebnerBasisOn m (vanishingSubmodule w) U
        (TropicalGroebner.buchbergerIterate m (vanishingSubmodule w) U n G₀) := by
  classical
  exact TropicalGroebner.exists_buchberger_completion m (vanishingSubmodule w) U G₀ hG₀U hG₀

/-- Gröbner bases of the vanishing ideal are exactly the fixed points of the
completion step. -/
theorem groebnerBasis_of_vanishing_fixedPoint (m : MonomialOrder σ)
    (U G : Finset (MvPolynomial σ TropCoeff)) (hGU : G ⊆ U)
    (hG : ∀ g ∈ G, VanishesAt w g) :
    TropicalGroebner.IsGroebnerBasisOn m (vanishingSubmodule w) U G ↔
      TropicalGroebner.buchbergerStep m (vanishingSubmodule w) U G = G :=
  TropicalGroebner.isGroebnerBasisOn_iff_buchberger_fixedPoint m
    (vanishingSubmodule w) hGU hG

end TropicalPointIdeal