# Future Directions — The Eckmann–Hilton Bridge, Cycle II (Morphisms, Bi-unitality, Fibres)

## Synthesis

The previous cycle pinned down the *object-level* content of the Eckmann–Hilton
argument: the catalog file `Speculative.AutoResearch.EckmannHilton` isolated the
equational engine (`EckmannHiltonData` with `same_op` / `comm` / `assoc`), and
`Speculative.AutoResearch.EckmannHiltonMonoid` showed the engine lands *exactly* on
the theory of commutative monoids (`toCommMonoid` / `ofCommMonoid` /
`eh_iff_commMonoid`), with object rigidity (`structure_rigidity`: the vertical
operation `m₁` determines the unit and the horizontal operation `m₂`).

This cycle closes three of the open loops left by that work, all in the
"duality / representation" spirit of translating a structure into its shadow and back:

1. **`EckmannHiltonClassical.lean` (Direction 4 — minimal axioms).** The catalog
   assumed the two operations *share* a unit. We removed that assumption: a
   `BiunitalInterchange` datum gives each operation its *own* two-sided unit, and
   `unit_eq` proves they must coincide (the classical four-term collapse
   `e₁ = e₁·e₁ = (e₂∘e₁)·(e₁∘e₂) = (e₂·e₁)∘(e₁·e₂) = e₂∘e₂ = e₂`). The shared-unit
   hypothesis is therefore *derivable*, not an axiom — the whole catalog engine is
   recovered by transport (`toEH`), and with it `same_op` / `comm` / `assoc` /
   `toCommMonoid`.
2. **`EckmannHiltonMorphism.lean` (Direction 1 — morphisms).** We supplied the
   morphism half of the object-level bridge. `morphism_rigidity` shows a carrier map
   preserving `m₁` automatically preserves `m₂` (the morphism analogue of
   `structure_rigidity`); `toMonoidHom` and `monoidHom_to_morphism` exhibit
   "Eckmann–Hilton structure map" and "commutative-monoid homomorphism" as literally
   the same notion.
3. **`EckmannHiltonFibrewise.lean` (Direction 5 — local-to-global).** An indexed
   family of Eckmann–Hilton structures glues pointwise (`piData`) into one structure
   on the sections `∀ b, X b`; the section monoid is commutative (`pi_comm`) and is
   *represented fibrewise* by the evaluation homomorphisms `evalHom`.

Together these turn the cycle-I object equivalence into a complete dictionary —
objects, morphisms, and products — between two-dimensional unital algebra and
one-dimensional commutative-monoid algebra.

## Results summary

* `BiunitalInterchange.unit_eq` — two a-priori-distinct units coincide (axioms:
  `propext` only).
* `BiunitalInterchange.toEH` / `.same_op` / `.comm` / `.assoc` / `.toCommMonoid` —
  the classical conclusions, obtained by transport into the catalog engine.
* `EckmannHiltonMorphism.morphism_rigidity` — `m₁`-preservation forces
  `m₂`-preservation.
* `EckmannHiltonMorphism.toMonoidHom` / `monoidHom_to_morphism` — the two notions of
  morphism coincide.
* `EckmannHiltonFibrewise.piData` / `pi_comm` / `eval_preserves` / `evalHom` — the
  section monoid and its fibrewise representation.

All results are `sorry`-free and reuse the catalog declarations directly rather than
reproving them.

---

## Direction 1 — Package the dictionary as an honest isomorphism of categories

We now have object rigidity (`structure_rigidity`), morphism rigidity
(`morphism_rigidity`), and a two-way translation of morphisms
(`toMonoidHom` / `monoidHom_to_morphism`). The remaining step is purely
organisational: define the category of Eckmann–Hilton data (with structure maps as
morphisms), the category `CommMonCat` (already in Mathlib), and exhibit
`toCommMonoid` / `ofCommMonoid` as functors witnessing an **isomorphism of
categories on the nose** (not merely an equivalence).

**The key insight is** that every ingredient of a category isomorphism is already
proved as an algebraic lemma — objects are determined by `m₁` (`structure_rigidity`),
morphisms are determined by their action on `m₁` (`morphism_rigidity`), and the
functor laws are `rfl` because all operations are stored as the *same* underlying
function. **Why now?** With both rigidity lemmas and both translation directions in
hand, the categorical wrapper has zero remaining mathematical content; it converts a
pile of pointwise lemmas into a single reusable `CategoryTheory.Equivalence` that any
downstream functorial construction can cite.

Falsifiable form: there exists an Eckmann–Hilton structure map that is **not** a
`toCommMonoid`-monoid homomorphism. A single such map would refute the isomorphism.

## Direction 2 — Graded / braided Eckmann–Hilton and the syllepsis

Replace the strict interchange field of `EckmannHiltonData` by an interchange that
holds only up to a fixed involution `β` of the carrier (a "braiding"). Conjecture: in
the trivially-graded case `β = id` one recovers strict commutativity exactly (our
`comm`), while for general `β` one obtains a *braided* commutativity
`m₁ a b = β (m₁ b a)` with the forced coherence `β ∘ β = id` (the syllepsis).

**The key insight is** that `comm` is produced by reading the unit-specialised
interchange in two ways; with a braided interchange those two readings give `β` and
`β⁻¹` applied to the same element, so their agreement *forces* `β² = id`. **Why
now?** Our `BiunitalInterchange`/`EckmannHiltonData` engine has every field
load-bearing and minimal (Direction 4 confirmed the unit count is tight), so
perturbing exactly the interchange field is a controlled experiment that isolates
precisely where strict commutativity is born.

Falsifiable form: a braided model with `β² ≠ id` whose two unit-readings still agree
would refute the syllepsis prediction.

## Direction 3 — A genuinely topological instantiation through `ContinuousMap`

The fibrewise file makes `piData` and `evalHom` available for *product* spaces; the
natural next target is a non-product topological example. On
`Path.Homotopic.Quotient` of a based loop space, or on `π₀` of a topological monoid,
vertical and horizontal concatenation descend to the homotopy quotient and there
satisfy interchange. Feeding them to `BiunitalInterchange`/`monoid_comm_of_second_interchange`
should yield commutativity of the relevant `π`, the first homotopical payoff of the
abstract engine.

**The key insight is** that interchange *fails on the nose* but *holds on the
homotopy quotient*, because `ContinuousMap.Homotopic` is an equivalence relation
compatible with both concatenation and pointwise multiplication — exactly the setting
`EckmannHiltonData` was designed to consume. **Why now?** The sibling
`PathSpaceHLevels.lean` already supplies the homotopy-quotient API (`Homotopic` as an
equivalence, contractible targets terminal), and this cycle supplies the bi-unital
engine that tolerates each loop space's *own* constant-path unit — so both halves of
the bridge are `sorry`-free and in scope.

Falsifiable form: a topological monoid whose `π₀` is non-commutative would show the
descended interchange silently fails, sharpening which spaces the bridge covers.

## Direction 4 — Faithfulness of the fibrewise representation (a Stone-flavoured embedding)

`evalHom` gives, for each base point, a monoid homomorphism from the section monoid to
a fibre. Conjecture: the *combined* map `f ↦ (fun b => evalHom E b f)` is an
**injective** monoid homomorphism `toCommMonoid (piData E) ↪ ∀ b, toCommMonoid (E b)`
— i.e. the section commutative monoid is faithfully represented as a submonoid of the
product of its fibres, the algebraic analogue of a Stone/Gelfand "points separate
elements" representation.

**The key insight is** that `evalHom` is literally evaluation, so two sections with
the same image under every `evalHom` are equal by `funext` — separation of points is
*definitional* here, not a theorem requiring maximal ideals or characters. **Why
now?** `evalHom` and `piData` are already built and `sorry`-free; promoting the family
of evaluations to a single faithful representation is the precise statement that makes
"the section monoid is determined by its fibres" a representation theorem rather than
a slogan.

Falsifiable form: two distinct sections agreeing under every `evalHom` would break
injectivity and refute faithfulness.

## Direction 5 — Can interchange itself be weakened to a single specialisation?

Direction 4 of cycle I (now resolved for units) suggests a further minimisation: the
proofs of `same_op` and `comm` only ever use interchange at arguments where two of the
four slots are units. Conjecture: an engine requiring interchange **only** for the
specialised families `interchange a unit unit b` and `interchange unit a b unit`
(rather than for all four arguments) still yields `same_op`, `comm`, and — together
with one extra specialisation — `assoc`.

**The key insight is** that the catalog proofs of `same_op`/`comm` are each a single
rewrite of one unit-specialised interchange instance, so the full quaternary
interchange law is *consumed* only in `assoc`; quantifying exactly which instances
`assoc` needs reveals the true minimal interchange skeleton. **Why now?** A
hypothesis-by-hypothesis audit of the engine is cheap and immediately widens the
applicability of every downstream corollary (especially
`monoid_comm_of_second_interchange`, where fewer required instances = more models).

Falsifiable form: a model satisfying only the two specialised interchange families but
with `m₁ ≠ m₂` would refute the reduction and show full interchange is necessary.
