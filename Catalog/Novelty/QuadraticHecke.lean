/-
# Quadratic Hecke characters and the unique quadratic subfield (GL(1) Langlands)

This file isolates the **order-2 (quadratic) part** of the GL(1) correspondence at a prime
conductor `p`.  The classical statements it captures:

* there are exactly **two** quadratic Dirichlet (= finite-order Hecke) characters mod an odd
  prime `p` — the trivial character and the Legendre symbol;
* correspondingly there are exactly **two** order-≤2 representations of `Gal(ℚ(ζₚ)/ℚ)` — the
  trivial one and the quadratic character cutting out the unique quadratic subfield `ℚ(√p*)`
  of `ℚ(ζₚ)`.

Both counts equal the number of square roots of `1` in `(ZMod p)ˣ`, which is `2` for odd `p`
(a field has only `±1` as square roots of unity, and `1 ≠ -1` when `p ≠ 2`).  This is the
GL(1) shadow of the fact that `ℚ(ζₚ)/ℚ` has a *unique* quadratic subextension.

Main results:

* `LanglandsQuadratic.card_sq_eq_one_congr` — a group isomorphism preserves the number of
  square roots of `1` (the transport principle linking the two sides).
* `LanglandsQuadratic.card_units_sq_eq_one_prime` — `#{x ∈ (ZMod p)ˣ : x² = 1} = 2` for odd
  prime `p`.
* `LanglandsQuadratic.card_quadratic_dirichlet_prime` — there are exactly `2` Dirichlet
  characters `χ` mod `p` with `χ² = 1`.
* `LanglandsQuadratic.card_quadratic_galois_reps_prime` — there are exactly `2` complex
  representations `ρ` of `Gal(ℚ(ζₚ)/ℚ)` with `ρ² = 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the GL(1) correspondence should match torsion levels, not just
total counts.  Boldest specialization: at the order-2 level the count is *exactly two* for
every odd prime, mirroring the unique quadratic subfield of `ℚ(ζₚ)` — a clean, prime-uniform
invariant that the bare totient `φ(p) = p - 1` hides.

Experiment (Experimenter): square roots of `1` are stable under any `MulEquiv`, giving a
transport lemma `card_sq_eq_one_congr`.  The anchor count is computed in the *field* `ZMod p`:
`mul_self_eq_one_iff` forces `x = 1 ∨ x = -1`, and `1 ≠ -1` for `p ≠ 2`, so exactly two
solutions.  Transporting along `MulChar.mulEquivToUnitHom` (Hecke side) and along
`galoisRepsEquivGalois ∘ artinIso` (Galois side) yields the two matching counts of `2`.

Analysis (Analyst): the result is genuinely structural — it is *not* `decide`d on a fixed
prime but holds uniformly via the field axioms and the duality isomorphisms.  The "unique
quadratic subfield" is visible here as the *single nontrivial* solution to `χ² = 1`.  Failure
mode avoided: at `p = 2` the count collapses to `1` (`1 = -1`), so the odd hypothesis is
load-bearing, exactly as in the mathematics.

Critique (Critic): is this trivial?  No — the transport lemma is a real `Nat.card_congr`
argument, and the anchor count uses the integral-domain structure of `ZMod p`.  The Galois
count is obtained by composing two nontrivial isomorphisms (Artin reciprocity and Pontryagin
self-duality), not recomputed.  The hypothesis `p ≠ 2` is necessary and stated.

Synthesis (PI): the quadratic stratum of GL(1) is pinned down: two Hecke characters, two
Galois representations, one nontrivial each — the analytic fingerprint of the unique quadratic
subfield of the prime cyclotomic field.
-/
import Mathlib
import Catalog.NumberTheory.Langlands.GaloisDuality

open Polynomial

namespace LanglandsQuadratic

/-- A group isomorphism preserves the number of square roots of `1`. -/
theorem card_sq_eq_one_congr {G H : Type*} [Group G] [Group H] (e : G ≃* H) :
    Nat.card {x : G // x ^ 2 = 1} = Nat.card {y : H // y ^ 2 = 1} := by
  apply Nat.card_congr
  exact
    { toFun := fun x => ⟨e x, by rw [← map_pow, x.2, map_one]⟩
      invFun := fun y => ⟨e.symm y, by rw [← map_pow, y.2, map_one]⟩
      left_inv := fun x => by ext; simp
      right_inv := fun y => by ext; simp }

/-
**The square roots of `1` in `(ZMod p)ˣ`.**  For an odd prime `p`, exactly two units square
to `1`, namely `±1`.  (At `p = 2` they coincide, giving `1`.)
-/
theorem card_units_sq_eq_one_prime (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2) :
    Nat.card {x : (ZMod p)ˣ // x ^ 2 = 1} = 2 := by
  -- Since `ZMod p` is a field, for a unit `x` we have `x ^ 2 = 1 ↔ x = 1 ∨ x = -1` (note `-1 : (ZMod p)ˣ` exists).
  have h_solutions : {x : (ZMod p)ˣ | x^2 = 1} = {1, -1} := by
    simp +decide [ Set.ext_iff ];
    intro x; exact ⟨ fun hx => by exact Units.eq_or_eq_neg_of_sq_eq_sq _ _ <| by simpa using hx, fun hx => by rcases hx with ( rfl | rfl ) <;> simp +decide ⟩ ;
  -- Show that `(1 : (ZMod p)ˣ) ≠ -1`.
  have h_ne : (1 : (ZMod p)ˣ) ≠ -1 := by
    norm_num [ Units.ext_iff ];
    rw [ eq_neg_iff_add_eq_zero ] ; norm_num;
    erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( lt_of_le_of_ne ( Nat.Prime.two_le Fact.out ) ( Ne.symm hp ) );
  rw [ show { x : ( ZMod p ) ˣ // x ^ 2 = 1 } = { x : ( ZMod p ) ˣ | x ^ 2 = 1 } from rfl, h_solutions, Nat.card_eq_fintype_card ] ; aesop;

/-- The Hecke ⇄ unit-character identification at conductor `p`. -/
noncomputable def dirichletEquivUnits (p : ℕ) [NeZero p] :
    DirichletCharacter ℂ p ≃* (ZMod p)ˣ :=
  MulChar.mulEquivToUnitHom.trans
    (Classical.choice (CommGroup.monoidHom_mulEquiv_of_hasEnoughRootsOfUnity (ZMod p)ˣ ℂ))

/-- **Quadratic Hecke characters at a prime.**  For an odd prime `p`, there are exactly two
Dirichlet characters mod `p` whose square is trivial: the trivial character and the Legendre
symbol. -/
theorem card_quadratic_dirichlet_prime (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2) :
    Nat.card {χ : DirichletCharacter ℂ p // χ ^ 2 = 1} = 2 := by
  haveI : NeZero p := ⟨(Fact.out : Nat.Prime p).ne_zero⟩
  rw [card_sq_eq_one_congr (dirichletEquivUnits p), card_units_sq_eq_one_prime p hp]

/-- The Galois-representation ⇄ unit identification at conductor `p`, composing Pontryagin
self-duality with Artin reciprocity. -/
noncomputable def galoisRepsEquivUnits (p : ℕ) [NeZero p] (L : Type*) [Field L] [Algebra ℚ L]
    [IsCyclotomicExtension {p} ℚ L] : ((L ≃ₐ[ℚ] L) →* ℂˣ) ≃* (ZMod p)ˣ :=
  (LanglandsGaloisDuality.galoisRepsEquivGalois p L).trans
    (LanglandsGaloisDuality.artinIso p L)

/-- **Quadratic Galois representations at a prime.**  For an odd prime `p`, there are exactly
two 1-dimensional complex representations of `Gal(ℚ(ζₚ)/ℚ)` whose square is trivial — the
trivial one and the quadratic character of the unique quadratic subfield of `ℚ(ζₚ)`. -/
theorem card_quadratic_galois_reps_prime (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2)
    (L : Type*) [Field L] [Algebra ℚ L] [IsCyclotomicExtension {p} ℚ L] :
    Nat.card {ρ : (L ≃ₐ[ℚ] L) →* ℂˣ // ρ ^ 2 = 1} = 2 := by
  haveI : NeZero p := ⟨(Fact.out : Nat.Prime p).ne_zero⟩
  rw [card_sq_eq_one_congr (galoisRepsEquivUnits p L), card_units_sq_eq_one_prime p hp]

end LanglandsQuadratic