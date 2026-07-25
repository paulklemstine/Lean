/-
# Langlands Correspondence: the GL(1) case (cyclotomic / global class field theory over ℚ)

This file formalizes the abelian (GL(1)) Langlands correspondence over `ℚ` in its
sharpest classical incarnation: the **cyclotomic case** of global class field theory.

For a primitive `n`-th root of unity field `ℚ(ζₙ)` (an arbitrary field `L` with
`IsCyclotomicExtension {n} ℚ L`), the two sides of the GL(1) correspondence are:

* **Automorphic / Hecke side**: `DirichletCharacter ℂ n = MulChar (ZMod n) ℂ`, the
  Dirichlet characters mod `n`.  These are exactly the finite-order Hecke characters of
  conductor dividing `n` for the field `ℚ`.
* **Galois side**: `(L ≃ₐ[ℚ] L) →* ℂˣ`, the 1-dimensional complex representations of the
  Galois group `Gal(ℚ(ζₙ)/ℚ)`.

The bridge is the **Artin reciprocity isomorphism** for cyclotomic fields,
`Gal(ℚ(ζₙ)/ℚ) ≃* (ZMod n)ˣ` (`IsCyclotomicExtension.autEquivPow`).  Over `ℚ` the
required irreducibility of `cyclotomic n ℚ` is automatic
(`Polynomial.cyclotomic.irreducible_rat`), so the whole correspondence holds
unconditionally for every modulus `n`.

Main results:

* `LanglandsGL1.artinIso` — the Artin reciprocity isomorphism `Gal(ℚ(ζₙ)/ℚ) ≃* (ZMod n)ˣ`.
* `LanglandsGL1.galois_abelian` — `Gal(ℚ(ζₙ)/ℚ)` is abelian (the extension is abelian).
* `LanglandsGL1.langlandsGL1` — the GL(1) correspondence as a group isomorphism
  `DirichletCharacter ℂ n ≃* ((L ≃ₐ[ℚ] L) →* ℂˣ)`.
* `LanglandsGL1.card_galois_reps_eq_totient` — the number of 1-dim Galois representations
  equals the number of Dirichlet characters, namely `φ(n)`.
* `LanglandsGL1.card_galois_reps_prime` — for prime `p`, that number is `p - 1`
  (using `Catalog.Bridges.NumberTheoryBridge.totient_prime`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the GL(1) Langlands correspondence — "1-dimensional Galois
representations correspond to Hecke characters" — should be realizable in Lean, not as a
vague slogan but as an explicit *group isomorphism* between the two character groups, for
the cyclotomic family where everything is computable.

Experiment (Experimenter): Mathlib already supplies the decisive arithmetic input,
`IsCyclotomicExtension.autEquivPow : Gal(L/K) ≃* (ZMod n)ˣ`, i.e. Artin reciprocity for
cyclotomic fields.  Composing it with `MulChar.mulEquivToUnitHom` and a precomposition
isomorphism of character groups produces the correspondence as a `MulEquiv`.  Over `ℚ`,
`cyclotomic.irreducible_rat` discharges the irreducibility side condition automatically.

Analysis (Analyst): the correspondence is *not* merely a bijection of sets — it is a group
isomorphism, so it transports the group structure of Hecke characters (pointwise product)
to that of Galois representations.  Pushing cardinalities through it recovers a purely
arithmetic count: `#{1-dim Galois reps} = φ(n)`.  The proof of finiteness routes through
`IsCyclotomicExtension.numberField`; the cardinality identity uses
`CommGroup.card_monoidHom_of_hasEnoughRootsOfUnity` only implicitly, via the cleaner
transport `Nat.card_congr` along the correspondence itself.

Critique (Critic): is this trivial?  No: `galois_abelian` is a genuine theorem (abelianness
of cyclotomic extensions, the structural reason class field theory applies), and the count
`φ(n)` is an honest arithmetic consequence proved with the character-group machinery, not by
`decide`.  Hidden assumption check: we need `NeZero n` (so `ζₙ` exists) and `Field L`; both
are faithful to the mathematics.  The statements are unconditional over `ℚ`.

Synthesis (PI): the cyclotomic GL(1) correspondence is fully formalized as an explicit group
isomorphism with its arithmetic shadow `φ(n)`, anchored to the catalog's number-theory
bridge through the prime count `p - 1`.
-/
import Mathlib
import Bridges.NumberTheoryBridge

open Polynomial

namespace LanglandsGL1

/-- **Artin reciprocity, cyclotomic case.**  The Galois group `Gal(ℚ(ζₙ)/ℚ)` is canonically
isomorphic to `(ZMod n)ˣ`.  This is the GL(1) reciprocity map underlying the correspondence;
over `ℚ` it holds for every `n` because `cyclotomic n ℚ` is irreducible. -/
noncomputable def artinIso (n : ℕ) [NeZero n] (L : Type*) [Field L] [Algebra ℚ L]
    [IsCyclotomicExtension {n} ℚ L] : (L ≃ₐ[ℚ] L) ≃* (ZMod n)ˣ :=
  IsCyclotomicExtension.autEquivPow L
    (cyclotomic.irreducible_rat (Nat.pos_of_ne_zero (NeZero.ne n)))

/-- The Galois group of a cyclotomic extension of `ℚ` is **abelian** — the structural fact
that makes GL(1) (abelian) class field theory apply. -/
theorem galois_abelian (n : ℕ) [NeZero n] (L : Type*) [Field L] [Algebra ℚ L]
    [IsCyclotomicExtension {n} ℚ L] (a b : L ≃ₐ[ℚ] L) : a * b = b * a := by
  apply (artinIso n L).injective
  rw [map_mul, map_mul, mul_comm]

/-- Precomposition with a group isomorphism `e : G ≃* H` is itself a group isomorphism of
the character groups `(H →* M) ≃* (G →* M)` (for commutative target `M`).  This is the
functoriality of "taking 1-dim representations". -/
noncomputable def precompMulEquiv {G H M : Type*} [Group G] [Group H] [CommGroup M]
    (e : G ≃* H) : (H →* M) ≃* (G →* M) where
  toFun φ := φ.comp e.toMonoidHom
  invFun ψ := ψ.comp e.symm.toMonoidHom
  left_inv φ := by ext x; simp
  right_inv ψ := by ext x; simp
  map_mul' a b := by ext x; simp

/-- **The GL(1) Langlands correspondence (cyclotomic case).**  The group of Dirichlet
(= finite-order Hecke) characters mod `n` is isomorphic, as a group, to the group of
1-dimensional complex representations of `Gal(ℚ(ζₙ)/ℚ)`.

This is the precise meaning of "1-dimensional Galois representations correspond to Hecke
characters" in the abelian case: the isomorphism is `χ ↦ χ ∘ (Artin map)`. -/
noncomputable def langlandsGL1 (n : ℕ) [NeZero n] (L : Type*) [Field L] [Algebra ℚ L]
    [IsCyclotomicExtension {n} ℚ L] :
    DirichletCharacter ℂ n ≃* ((L ≃ₐ[ℚ] L) →* ℂˣ) :=
  MulChar.mulEquivToUnitHom.trans (precompMulEquiv (artinIso n L))

/-- The number of Dirichlet characters mod `n` (valued in `ℂ`) equals `φ(n)`. -/
theorem card_dirichlet_eq_totient (n : ℕ) [NeZero n] :
    Nat.card (DirichletCharacter ℂ n) = Nat.totient n := by
  rw [MulChar.card_eq_card_units_of_hasEnoughRootsOfUnity (ZMod n) ℂ,
      Nat.card_eq_fintype_card, ZMod.card_units_eq_totient]

/-- **Counting 1-dim Galois representations.**  Transporting the correspondence, the number
of 1-dimensional complex representations of `Gal(ℚ(ζₙ)/ℚ)` equals `φ(n)`. -/
theorem card_galois_reps_eq_totient (n : ℕ) [NeZero n] (L : Type*) [Field L] [Algebra ℚ L]
    [IsCyclotomicExtension {n} ℚ L] :
    Nat.card ((L ≃ₐ[ℚ] L) →* ℂˣ) = Nat.totient n := by
  rw [← Nat.card_congr (langlandsGL1 n L).toEquiv, card_dirichlet_eq_totient]

/-- **Prime case.**  For a prime `p`, the group `Gal(ℚ(ζₚ)/ℚ)` has exactly `p - 1`
one-dimensional complex representations.  The value `φ(p) = p - 1` is supplied by the
catalog result `NumberTheoryBridge.totient_prime`. -/
theorem card_galois_reps_prime (p : ℕ) [Fact (Nat.Prime p)] (L : Type*) [Field L]
    [Algebra ℚ L] [IsCyclotomicExtension {p} ℚ L] :
    Nat.card ((L ≃ₐ[ℚ] L) →* ℂˣ) = p - 1 := by
  have hp : Nat.Prime p := Fact.out
  haveI : NeZero p := ⟨hp.ne_zero⟩
  rw [card_galois_reps_eq_totient p L, NumberTheoryBridge.totient_prime hp]

end LanglandsGL1