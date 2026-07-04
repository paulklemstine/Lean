/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Escher Height, part III: how the staircase transfers between rings

This file extends `Algebra.EscherStaircase` (the definition `Escher.EscherStaircase`
and the ACC characterisation `Escher.escherStaircase_iff_not_isNoetherianRing`) with
the *structural* behaviour of Escher staircases under the three basic ring
operations: taking a finite product, adjoining a single variable, and passing to an
overring.  The point of view is that "admits an Escher staircase" is a ring
*invariant* (it is exactly non-Noetherianity), so it should have clean functorial
transfer laws — and the surprises come from where those laws *fail*.

## Main results

* `Escher.escherStaircase_prod_iff` :
    `EscherStaircase (R × S) ↔ EscherStaircase R ∨ EscherStaircase S`.
    The impossible staircase is a **local-to-global** obstruction: a finite product
    has one iff some factor does.
* `Escher.escherStaircase_polynomial_iff` :
    `EscherStaircase R[X] ↔ EscherStaircase R`.
    Adjoining a *single* variable is **neutral**: it neither creates nor destroys the
    staircase.  Combined with the sibling files this pins the phenomenon precisely on
    the *infinitude* of the variable set, not on any single variable.
* `Escher.exists_escher_subring_of_no_escher` and its concrete witness
    `Escher.mvPolynomialRat_fractionRing_escher_collapse` : the **impossible
    architecture** literalised.  There is an injective ring homomorphism from a ring
    *with* an Escher staircase into a ring with **none** — the infinite ascending
    chain that climbs forever inside the subring simply *collapses* once you pass to
    the (Noetherian) overring.  Concretely `ℚ[x₀, x₁, …] ↪ Frac(ℚ[x₀, x₁, …])`, a
    non-Noetherian domain sitting inside a field.

-- !-- Lab Notes -- !--
### Hypothesis (Hypothesizer)
With the invariant `EscherStaircase R ↔ ¬ IsNoetherianRing R` in hand we ask how the
invariant transfers along ring operations:
  H1. (product) `R × S` has a staircase iff `R` or `S` does.  Non-Noetherianity of a
      finite product is detected factorwise.                                   [kept]
  H2. (single variable) `R[X]` has a staircase iff `R` does — Hilbert's basis theorem
      one way, the evaluation surjection `R[X] ↠ R` the other.                 [kept]
  H3. (surprising) A ring *with* a staircase can embed in a ring with **none**: the
      chain is not preserved by injective ring maps.  A non-Noetherian domain lives
      inside its fraction field, which — being a field — is Noetherian.        [kept]
  H4. (counter-intuitive, rejected) "Escher height is monotone under subrings."
      FALSE by H3: the subring `ℚ[x₀,x₁,…]` has infinite height while the overfield
      `Frac(…)` has none.  Subrings can be *further* from Noetherian than their
      overrings, the opposite of the naive expectation.                        [rejected]

### Experiment (Experimenter)
* Product: the projections `RingHom.fst`, `RingHom.snd` are surjective, so a
  Noetherian product forces Noetherian factors; the converse is the standard product
  instance.  Test values `R = ℚ[x₀,x₁,…]` (staircase), `S = ℚ` (none): `R × S` has a
  staircase, exactly as predicted.
* Polynomial: `Polynomial.evalRingHom 0 : R[X] ↠ R` is surjective (right inverse `C`),
  giving `R[X]` Noetherian ⇒ `R` Noetherian; `Polynomial.isNoetherianRing` gives the
  reverse.
* Subring collapse: `ℚ[x₀,x₁,…]` is a domain, so it injects into `Frac(…)`, and a
  field is Noetherian — the staircase `⟨x₀⟩ ⊊ ⟨x₀,x₁⟩ ⊊ ⋯` has no analogue there.

### Analysis (Analyst)
All three reduce, through `escherStaircase_iff_not_isNoetherianRing`, to transfer laws
for Noetherianity.  The load-bearing lemma is `isNoetherianRing_of_surjective`
(non-Noetherianity is inherited by any ring that *surjects onto* a non-Noetherian
one), used for both the product projections and the polynomial evaluation.  The
subring result shows the invariant is emphatically **not** inherited by subrings:
injective maps carry information the *wrong* way for ACC.

### Critique (Critic)
* Non-triviality: `escherStaircase_polynomial_iff` genuinely needs the Hilbert basis
  theorem in one direction; the product law needs surjectivity of both projections;
  the subring collapse needs `IsFractionRing.injective`, the domain instance, and the
  ℕ-variable staircase from the sibling file.  None is `simp`/`decide`.
* Vacuity: the subring witness uses `ℚ` (a genuine field) and `ℚ[x₀,x₁,…]` (a genuine
  non-Noetherian ring), so both sides have content; the embedding is a real injection.

### Synthesis (PI)
Escher staircases transfer *covariantly along surjections* (products, single-variable
adjunction) but can be **created by passing to a subring**: the impossible staircase
is a property of how far a ring is from Noetherian, and shrinking a ring can only move
it further away.  This is the precise algebraic sense of Escher's illusion — the
staircase that exists downstairs vanishes the moment you step up to the overring.
-- !-- Lab Notes -- !--
-/
import Mathlib
import Algebra.EscherStaircase
import Algebra.EscherStaircasePolynomial

open Polynomial

namespace Escher

variable {R : Type*} [CommRing R] {S : Type*} [CommRing S]

/-! ### Product rings: a local-to-global obstruction -/

/-- A finite product of commutative rings is Noetherian iff both factors are.
The forward direction uses that each projection `R × S ↠ R` is a surjection, so a
Noetherian product forces Noetherian factors; the reverse is the product instance. -/
theorem isNoetherianRing_prod_iff :
    IsNoetherianRing (R × S) ↔ IsNoetherianRing R ∧ IsNoetherianRing S := by
  constructor
  · intro h
    refine ⟨?_, ?_⟩
    · exact isNoetherianRing_of_surjective (R × S) R (RingHom.fst R S) Prod.fst_surjective
    · exact isNoetherianRing_of_surjective (R × S) S (RingHom.snd R S) Prod.snd_surjective
  · rintro ⟨hR, hS⟩
    haveI := hR; haveI := hS
    infer_instance

/-- **Main theorem (local-to-global).** A finite product of rings admits an Escher
staircase iff at least one factor does.  The impossible ascending chain of a product
is always witnessed inside a single coordinate. -/
theorem escherStaircase_prod_iff :
    EscherStaircase (R × S) ↔ EscherStaircase R ∨ EscherStaircase S := by
  rw [escherStaircase_iff_not_isNoetherianRing, escherStaircase_iff_not_isNoetherianRing,
    escherStaircase_iff_not_isNoetherianRing, isNoetherianRing_prod_iff]
  tauto

/-! ### Adjoining a single variable is neutral -/

/-- `R[X]` is Noetherian iff `R` is.  Forward: `Polynomial.evalRingHom 0 : R[X] ↠ R`
is surjective (with right inverse `C`), so a Noetherian polynomial ring forces a
Noetherian base.  Reverse: the **Hilbert basis theorem** `Polynomial.isNoetherianRing`. -/
theorem isNoetherianRing_polynomial_iff :
    IsNoetherianRing (Polynomial R) ↔ IsNoetherianRing R := by
  constructor
  · intro h
    refine isNoetherianRing_of_surjective (Polynomial R) R (Polynomial.evalRingHom 0) ?_
    intro a; exact ⟨Polynomial.C a, by simp⟩
  · intro h
    haveI := h
    exact Polynomial.isNoetherianRing

/-- **Main theorem (single variable is neutral).** The polynomial ring `R[X]` admits
an Escher staircase iff `R` does.  Adjoining one variable can neither manufacture nor
dissolve the impossible staircase — only passing to *infinitely* many variables can
(see the sibling files). -/
theorem escherStaircase_polynomial_iff :
    EscherStaircase (Polynomial R) ↔ EscherStaircase R := by
  rw [escherStaircase_iff_not_isNoetherianRing, escherStaircase_iff_not_isNoetherianRing,
    isNoetherianRing_polynomial_iff]

/-! ### The impossible architecture: a staircase that collapses in an overring -/

/-- **The concrete Escher collapse.** The non-Noetherian domain `ℚ[x₀, x₁, x₂, …]`
(which carries the infinite-height variable staircase of the sibling file) embeds, via
the fraction-field inclusion, into its field of fractions `Frac(ℚ[x₀, x₁, …])`.  The
overring is a **field**, hence Noetherian, hence has **no** Escher staircase: the
infinite ascending chain that climbs forever downstairs collapses to nothing upstairs. -/
theorem mvPolynomialRat_fractionRing_escher_collapse :
    EscherStaircase (MvPolynomial ℕ ℚ) ∧
      ¬ EscherStaircase (FractionRing (MvPolynomial ℕ ℚ)) ∧
      Function.Injective
        (algebraMap (MvPolynomial ℕ ℚ) (FractionRing (MvPolynomial ℕ ℚ))) := by
  refine ⟨escherStaircase_mvPolynomial_nat, ?_, IsFractionRing.injective _ _⟩
  rw [escherStaircase_iff_not_isNoetherianRing, not_not]
  infer_instance

/-- **Main theorem (Escher's illusion is realisable).** There exist commutative rings
`A` and `B` and an **injective** ring homomorphism `A ↪ B` such that `A` admits an
Escher staircase while `B` admits none.  In other words, an infinite strictly ascending
chain of ideals can live inside a subring and yet have no counterpart in the ambient
ring: climbing forever downstairs, the staircase simply is not there upstairs.  The
witness is `ℚ[x₀, x₁, …] ↪ Frac(ℚ[x₀, x₁, …])`. -/
theorem exists_escher_collapse :
    ∃ (A B : Type) (_ : CommRing A) (_ : CommRing B) (f : A →+* B),
      Function.Injective f ∧ EscherStaircase A ∧ ¬ EscherStaircase B := by
  obtain ⟨hstair, hno, hinj⟩ := mvPolynomialRat_fractionRing_escher_collapse
  exact ⟨MvPolynomial ℕ ℚ, FractionRing (MvPolynomial ℕ ℚ), _, _,
    algebraMap _ _, hinj, hstair, hno⟩

end Escher