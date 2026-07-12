/-
# A Burnside ↔ Orbit–Stabilizer Bridge, applied to GL(n,2)-orbits of Boolean forms

This file builds a *connector* between two classically distinct areas of mathematics:

* **Group theory / linear algebra over finite fields** — the action of the general
  linear group `GL(n, 2)` on the space of Boolean functions in `n` variables; and
* **Enumerative combinatorics** — the problem of *counting orbits* of such an action.

The bridge itself is the **orbit-counting theorem** ("Burnside's lemma") together with
the **orbit–stabilizer theorem**.  Both are packaged in Mathlib, but the fact that they
give *the same* orbit count via two genuinely different summations
(`∑_g |Fix g|` versus `∑_x |Stab x|`) is the content of the connector proved here
(`sum_fixedBy_eq_sum_stabilizer` and `orbitCount_two_ways`).

The motivating research statement (from *Classification of Boolean Cubic Forms in Ten
Variables*) is that the number of nonzero `GL(10,2)`-orbits of Boolean cubic forms is
exactly `3 691 560`, and that this count is confirmed by **both** Burnside's lemma and the
orbit–stabilizer theorem.  We formalise the *logical core* of that verification:

* the general two-methods-agree bridge (`orbitCount_two_ways`);
* the division principle by which a Burnside fixed-point sum determines the orbit count
  (`card_orbits_of_fixedBy_sum`);
* a fully computed concrete instance — the `GL(2,2) ≅ S₃` action, whose single nonzero
  orbit is *derived from the bridge* (`sthree_on_fin3_orbitCount`);
* the specialisation of the machinery to the actual `GL(n,2)` action on Boolean functions
  (`glTwo_boolFun_orbitCount`), and the resulting statement pinning the number
  `3 691 560` from its Burnside sum (`booleanCubic10_orbitCount_of_burnside`), plus the
  arithmetic structure of that number (`orbitCount10_factorization`).

Everything is `sorry`-free and self-contained (`import Mathlib`).
-/

import Mathlib

open scoped BigOperators
open MulAction Matrix

namespace BooleanCubicBurnside

/-! ## Part 1 — The general bridge: Burnside ⇄ orbit–stabilizer

We work with a finite group `G` acting on a finite type `X`.  We abbreviate the orbit
space by `Ω`.
-/

section GeneralBridge

variable (G X : Type*) [Group G] [MulAction G X]

/-- The set of "incident pairs" `(g, x)` with `g • x = x` can be sliced two ways:
by the first coordinate it is `Σ g, fixedBy X g`, and by the second coordinate it is
`Σ x, stabilizer G x`.  This equivalence is the combinatorial heart of the statement that
Burnside's lemma and the orbit–stabilizer theorem count the *same* thing. -/
noncomputable def fixedByStabilizerEquiv :
    (Σ g : G, fixedBy X g) ≃ Σ x : X, stabilizer G x :=
  calc (Σ g : G, fixedBy X g)
      ≃ {p : G × X // p.1 • p.2 = p.2} :=
        (Equiv.subtypeProdEquivSigmaSubtype (fun (g : G) (x : X) => g • x = x)).symm
    _ ≃ {p : X × G // p.2 • p.1 = p.1} :=
        (Equiv.prodComm G X).subtypeEquiv (fun _ => Iff.rfl)
    _ ≃ Σ x : X, {g : G // g • x = x} :=
        Equiv.subtypeProdEquivSigmaSubtype (fun (x : X) (g : G) => g • x = x)
    _ ≃ Σ x : X, stabilizer G x :=
        Equiv.sigmaCongrRight (fun _ =>
          Equiv.subtypeEquivRight (fun _ => (mem_stabilizer_iff).symm))

variable [Fintype G] [Fintype X]
  [∀ g : G, Fintype (fixedBy X g)] [∀ x : X, Fintype (stabilizer G x)]

/-- **The connector.** The sum of the sizes of the fixed-point sets `Fix(g)` (over group
elements — the Burnside side) equals the sum of the sizes of the stabilizers `Stab(x)`
(over points — the orbit–stabilizer side). -/
theorem sum_fixedBy_eq_sum_stabilizer :
    (∑ g : G, Fintype.card (fixedBy X g)) = ∑ x : X, Fintype.card (stabilizer G x) := by
  rw [← Fintype.card_sigma, ← Fintype.card_sigma]
  exact Fintype.card_congr (fixedByStabilizerEquiv G X)

/-- Abbreviation for the orbit space of the action. -/
abbrev OrbitSpace := Quotient (orbitRel G X)

variable [Fintype (OrbitSpace G X)]

/-- **Both counting methods agree.** The number of orbits multiplied by `|G|` equals the
Burnside fixed-point sum `∑_g |Fix g|` *and* the orbit–stabilizer sum `∑_x |Stab x|`.
This is the precise formal sense in which the orbit count is "verified by both Burnside's
lemma and the orbit–stabilizer theorem". -/
theorem orbitCount_two_ways :
    (∑ g : G, Fintype.card (fixedBy X g)) = Fintype.card (OrbitSpace G X) * Fintype.card G ∧
    (∑ x : X, Fintype.card (stabilizer G x)) = Fintype.card (OrbitSpace G X) * Fintype.card G := by
  refine ⟨?_, ?_⟩
  · exact sum_card_fixedBy_eq_card_orbits_mul_card_group G X
  · rw [← sum_fixedBy_eq_sum_stabilizer G X]
    exact sum_card_fixedBy_eq_card_orbits_mul_card_group G X

omit [Fintype X] [∀ x : X, Fintype (stabilizer G x)] in
/-- **Division principle.** If the Burnside fixed-point sum equals `N · |G|`, then the
number of orbits is exactly `N`.  This is the arithmetic step that turns a fixed-point
computation into an orbit count — precisely the inference used to certify a classification
result such as the `3 691 560` figure. -/
theorem card_orbits_of_fixedBy_sum (N : ℕ) (hpos : 0 < Fintype.card G)
    (h : (∑ g : G, Fintype.card (fixedBy X g)) = N * Fintype.card G) :
    Fintype.card (OrbitSpace G X) = N := by
  have hb := sum_card_fixedBy_eq_card_orbits_mul_card_group G X
  rw [h] at hb
  exact Nat.eq_of_mul_eq_mul_right hpos hb.symm

end GeneralBridge

/-! ## Part 2 — A fully computed instance: `GL(2,2) ≅ S₃` acting on `Fin 3`

The general linear group `GL(2,2)` is isomorphic to the symmetric group `S₃`, acting on
the three nonzero vectors of `𝔽₂²`.  We model this as `Equiv.Perm (Fin 3)` acting on
`Fin 3`.  The action is transitive, so there is exactly one orbit.  We *do not* assume
this: we compute the Burnside sum `∑_g |Fix g| = 6` by `decide`, and then read off the
orbit count `= 1` from the bridge (`card_orbits_of_fixedBy_sum`).  This exhibits the whole
Burnside → orbit-count pipeline end-to-end on a concrete example. -/

section ConcreteExample

/-- The Burnside fixed-point sum for `S₃` acting on `Fin 3`: the identity fixes all `3`
points, each of the `3` transpositions fixes `1` point, and each of the `2` three-cycles
fixes none, giving `3 + 3·1 + 2·0 = 6`. -/
theorem sthree_fixedBy_sum :
    (∑ g : Equiv.Perm (Fin 3), Fintype.card (fixedBy (Fin 3) g)) = 6 := by decide

/-- The number of `S₃`-orbits on `Fin 3` is `1`, obtained from the bridge: the Burnside
sum equals `6 = 1 · |S₃| = 1 · 6`, and the division principle yields the orbit count. -/
theorem sthree_on_fin3_orbitCount :
    Fintype.card (OrbitSpace (Equiv.Perm (Fin 3)) (Fin 3)) = 1 := by
  apply card_orbits_of_fixedBy_sum (Equiv.Perm (Fin 3)) (Fin 3) 1
  · exact Fintype.card_pos
  · rw [sthree_fixedBy_sum]
    decide

end ConcreteExample

/-! ## Part 3 — The `GL(n,2)` action on Boolean functions

A **Boolean function** in `n` variables is a map `(Fin n → 𝔽₂) → 𝔽₂`.  The Boolean
*cubic forms* studied in the classification are elements of the graded piece of degree
three (Reed–Muller layer `RM(3,n)/RM(2,n)`), a `GL(n,2)`-invariant sub-quotient of this
function space, of dimension `C(n,3)`.  Here we set up the honest ambient action of
`GL(n,2)` on all Boolean functions by linear substitution `f ↦ f ∘ g⁻¹`, which restricts
to the cubic layer, and then specialise the bridge of Part 1 to it. -/

section GLAction

/-- Vectors of `𝔽₂ⁿ`. -/
abbrev Vec (n : ℕ) := Fin n → ZMod 2

/-- Boolean functions in `n` variables. -/
abbrev BoolFun (n : ℕ) := Vec n → ZMod 2

/-- `GL(n,2)` acts on Boolean functions by linear substitution `(g • f) v = f (g⁻¹ • v)`.
This is the standard (contravariant) action of the general linear group on functions of
its module; it preserves the degree filtration and hence acts on Boolean cubic forms. -/
noncomputable instance boolFunAction (n : ℕ) :
    MulAction (GL (Fin n) (ZMod 2)) (BoolFun n) where
  smul g f := fun v => f (g⁻¹ • v)
  one_smul f := by funext v; show f (1⁻¹ • v) = f v; rw [inv_one, one_smul]
  mul_smul g h f := by
    funext v
    show f ((g * h)⁻¹ • v) = f (h⁻¹ • (g⁻¹ • v))
    rw [_root_.mul_inv_rev]
    exact congrArg f (SemigroupAction.mul_smul _ _ _)

/-- `GL(n,2)` is a nonempty finite group, so its order is positive. -/
theorem card_GL_pos (n : ℕ) : 0 < Fintype.card (GL (Fin n) (ZMod 2)) :=
  Fintype.card_pos

/-- Specialisation of the bridge: for the `GL(n,2)` action on Boolean functions, the
number of orbits times `|GL(n,2)|` equals the Burnside fixed-point sum *and* the
orbit–stabilizer sum.  This is the exact formula by which orbit classifications over
`𝔽₂` (such as the cubic-forms count) are computed and cross-checked. -/
theorem glTwo_boolFun_orbitCount (n : ℕ)
    [Fintype (OrbitSpace (GL (Fin n) (ZMod 2)) (BoolFun n))] :
    (∑ g : GL (Fin n) (ZMod 2), Fintype.card (fixedBy (BoolFun n) g))
        = Fintype.card (OrbitSpace (GL (Fin n) (ZMod 2)) (BoolFun n))
          * Fintype.card (GL (Fin n) (ZMod 2)) ∧
    (∑ f : BoolFun n, Fintype.card (stabilizer (GL (Fin n) (ZMod 2)) f))
        = Fintype.card (OrbitSpace (GL (Fin n) (ZMod 2)) (BoolFun n))
          * Fintype.card (GL (Fin n) (ZMod 2)) :=
  orbitCount_two_ways (GL (Fin n) (ZMod 2)) (BoolFun n)

end GLAction

/-! ## Part 4 — The number `3 691 560`

The classification result states that the number of nonzero `GL(10,2)`-orbits of Boolean
cubic forms is `3 691 560`.  We record this number and prove:

* the exact inference by which it follows from a Burnside fixed-point sum
  (`booleanCubic10_orbitCount_of_burnside`), stated for an *abstract* finite `GL(10,2)`-set
  `C` standing for the space of cubic forms — this is faithful to the paper's method and
  free of any unproven numerical assumption inside its statement; and
* the arithmetic factorisation of the number (`orbitCount10_factorization`), which shows
  `3 691 560 = 2³ · 3 · 5 · 30763` with `30763` prime.
-/

section TheNumber

/-- The number of nonzero `GL(10,2)`-orbits of Boolean cubic forms in ten variables,
the main classification result. -/
def orbitCount10 : ℕ := 3691560

/-- The **inference step of the classification**, stated abstractly and faithfully: for any
finite `GL(10,2)`-set `C` (to be read as the space of Boolean cubic forms), if its Burnside
fixed-point sum equals `3 691 560 · |GL(10,2)|`, then it has exactly `3 691 560` orbits.
This is precisely how the paper converts the (large) fixed-point computation into the
orbit count, and it is where Burnside's lemma and the orbit–stabilizer theorem jointly
certify the answer. -/
theorem booleanCubic10_orbitCount_of_burnside
    (C : Type*) [MulAction (GL (Fin 10) (ZMod 2)) C] [Fintype C]
    [∀ g : GL (Fin 10) (ZMod 2), Fintype (fixedBy C g)]
    [∀ x : C, Fintype (stabilizer (GL (Fin 10) (ZMod 2)) x)]
    [Fintype (OrbitSpace (GL (Fin 10) (ZMod 2)) C)]
    (h : (∑ g : GL (Fin 10) (ZMod 2), Fintype.card (fixedBy C g))
        = orbitCount10 * Fintype.card (GL (Fin 10) (ZMod 2))) :
    Fintype.card (OrbitSpace (GL (Fin 10) (ZMod 2)) C) = orbitCount10 :=
  card_orbits_of_fixedBy_sum (GL (Fin 10) (ZMod 2)) C orbitCount10 (card_GL_pos 10) h

/-- `30763` is prime. -/
theorem prime_30763 : Nat.Prime 30763 := by norm_num

/-- The factorisation `3 691 560 = 2³ · 3 · 5 · 30763`, with the prime `30763`. In
particular `3 691 560 = 120 · 30763`, exhibiting the factor `120 = 5!`. -/
theorem orbitCount10_factorization :
    orbitCount10 = 2 ^ 3 * 3 * 5 * 30763 ∧ orbitCount10 = 120 * 30763 ∧ Nat.Prime 30763 :=
  ⟨by norm_num [orbitCount10], by norm_num [orbitCount10], prime_30763⟩

end TheNumber

end BooleanCubicBurnside