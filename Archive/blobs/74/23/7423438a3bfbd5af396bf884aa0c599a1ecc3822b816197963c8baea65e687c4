# Future Directions — The Eckmann–Hilton Bridge (Objects, Morphisms, Products)

## Synthesis

This cycle takes the catalog's single-carrier Eckmann–Hilton engine
(`Geometry.HomotopyTypeTheory.StratifiedInterchange`, namespace `HoTT`, whose
`StratifiedInterchangeAlgebra` derives `vcomp_eq_hcomp` and `vcomp_comm` from a
*shared-unit* interchange law) and promotes it from a theorem *about a fixed structure*
into a self-contained **dictionary** between two-dimensional unital interchange algebra
and one-dimensional commutative-monoid algebra. Three new files, all built on top of the
catalog idea, close the three most load-bearing gaps:

1. **`EckmannHiltonBiunital.lean` (minimal axioms).** The catalog *assumes* the two
   operations share a unit. We drop that: `BiunitalInterchange` gives each operation its
   own two-sided unit (`e₁` for `op₁`, `e₂` for `op₂`), and `unit_eq` derives `e₂ = e₁`
   from the interchange law alone via the four-term collapse
   `e₁ = e₁·e₁ = (e₂∘e₁)·(e₁∘e₂) = (e₂·e₁)∘(e₁·e₂) = e₂∘e₂ = e₂`.
   We then recover `ops_eq` and `comm`, and — *beyond* the catalog, which axiomatizes
   associativity of vertical composition — we *prove* `assoc` from the medial law
   specialised at a unit slot, packaging the carrier as a genuine `CommMonoid`
   (`toCommMonoid`). So a bi-unital interchange datum **is** a commutative monoid; the
   shared-unit hypothesis was never an axiom.

2. **`EckmannHiltonMorphism.lean` (morphisms).** `morphism_rigidity` shows a carrier map
   preserving the first operation automatically preserves the second — the morphism
   analogue of the catalog's object rigidity — and `preserves_iff` records that the two
   preservation conditions (`Preserves₁`, `Preserves₂`) are literally equivalent.

3. **`EckmannHiltonFibrewise.lean` (products / local-to-global).** A family of bi-unital
   systems glues pointwise (`piSystem`); interchange glues fibrewise (`pi_interchange`);
   the section operation is commutative (`pi_comm`) by quoting the object-level `comm` on
   the glued datum; and the section system is faithfully represented by its fibres
   (`eval_preserves`, `pi_faithful`).

Together: objects (rigidity + `CommMonoid`), morphisms (rigidity + equivalence), and
products (gluing + faithful representation) — a complete object/morphism/product
dictionary, all `sorry`-free and reusing the catalog idea rather than reproving it.

## Results summary

* `BiunitalInterchange.unit_eq` — the two a-priori distinct units coincide
  (axioms: `propext` only).
* `BiunitalInterchange.ops_eq` / `.comm` / `.assoc` — operation equality, commutativity,
  and associativity, the last new relative to the catalog (which assumes it).
* `BiunitalInterchange.toCommMonoid` — the carrier is a commutative monoid.
* `morphism_rigidity` / `preserves_iff` — preserving one operation forces (and is
  equivalent to) preserving the other.
* `piSystem` / `pi_interchange` / `pi_comm` / `eval_preserves` / `pi_faithful` — the
  section system and its faithful fibrewise representation.

---

## Direction 1 — Package the dictionary as an isomorphism of categories

Define the category of Eckmann–Hilton data (objects = `BiunitalInterchange` data,
morphisms = first-operation-preserving carrier maps, with composition the underlying
function composition) and exhibit `toCommMonoid` together with the obvious inverse as
functors to/from `CommMonCat` witnessing an **isomorphism of categories on the nose**,
not merely an equivalence.

**The key insight is** that every ingredient is already an algebraic lemma here —
objects are pinned by their first operation (`ops_eq`), morphisms by their action on that
operation (`morphism_rigidity`/`preserves_iff`), and the functor laws are `rfl` because
all operations are stored as plain functions. **Why now?** With object rigidity, morphism
rigidity, and `toCommMonoid` all `sorry`-free, the categorical wrapper carries zero
remaining mathematical content; it merely repackages pointwise lemmas into one reusable
`CategoryTheory.Equivalence`. Falsifiable form: an Eckmann–Hilton structure map that is
*not* a `toCommMonoid`-monoid homomorphism would refute the isomorphism.

## Direction 2 — Braided Eckmann–Hilton and the forced syllepsis

Replace the strict `interchange` field of `BiunitalInterchange` by interchange holding
only up to a fixed self-map `β` of the carrier (a "braiding"). Conjecture: for `β = id`
one recovers strict `comm` exactly, while for general `β` one obtains a *braided*
commutativity `op₁ a b = β (op₁ b a)` together with the **forced coherence** `β ∘ β = id`.

**The key insight is** that `comm` is produced by reading the unit-specialised
interchange in two ways; with a braided interchange the two readings apply `β` and its
formal inverse to the same element, so their agreement *forces* `β² = id` — the syllepsis
appears as a derived equation, not an assumed one. **Why now?** A hypothesis audit
confirms every field of `BiunitalInterchange` is load-bearing (drop any unit law and
`unit_eq` already fails to telescope), so perturbing exactly the interchange field is a
controlled experiment isolating where strict commutativity is born. Falsifiable form: a
braided model with `β² ≠ id` whose two unit-readings still agree would refute the
prediction.

## Direction 3 — A homotopical instantiation through `Path.Homotopic.Quotient`

`piSystem`/`pi_comm` cover *product* carriers; the natural next target is a non-product,
genuinely topological example. On `Path.Homotopic.Quotient` of a based loop space,
vertical and horizontal concatenation descend to the homotopy quotient and satisfy
interchange there; feeding them to `BiunitalInterchange.comm` should yield commutativity
of the relevant homotopy monoid — the first homotopical payoff of the abstract engine.

**The key insight is** that interchange *fails on the nose but holds on the homotopy
quotient*, because homotopy is an equivalence relation compatible with both
concatenations — exactly the equational shape `BiunitalInterchange` consumes, and the
bi-unital engine now even tolerates each loop space's *own* constant-path unit. **Why
now?** Mathlib already supplies the `Path.Homotopic` quotient API and this cycle supplies
the bi-unital engine, so both halves are in scope and `sorry`-free. Falsifiable form: a
space whose descended concatenations violate interchange on the quotient would sharpen
exactly which spaces the bridge covers.

## Direction 4 — Faithful representation as an injective monoid homomorphism

Promote `eval_preserves`/`pi_faithful` from a *family* of projections to a single
**injective monoid homomorphism**
`(piSystem S).toCommMonoid ↪ ∀ i, (S i).toCommMonoid`.
This realises the section commutative monoid as a submonoid of the product of its fibres
— the algebraic analogue of a Stone/Gelfand "points separate elements" representation.

**The key insight is** that `eval_preserves` makes evaluation a homomorphism by `rfl` and
`pi_faithful` makes separation of points definitional (`funext`), so injectivity needs no
maximal ideals or characters — it is built in. **Why now?** Both ingredients already
exist and are `sorry`-free; bundling them into one `MonoidHom` with a
`Function.Injective` proof converts "the section monoid is determined by its fibres" from
a slogan into a representation theorem. Falsifiable form: two distinct sections agreeing
under every evaluation would break injectivity.

## Direction 5 — Minimise the interchange law to its unit-specialisations

The proofs of `unit_eq`, `ops_eq`, and `comm` only ever invoke `interchange` where two
of the four slots are units; only `assoc` consumes a genuinely quaternary instance.
Conjecture: an engine requiring interchange **only** on the specialised families
`interchange a e e b` and `interchange e a b e` still yields `unit_eq`, `ops_eq`, and
`comm`, and a single extra specialised instance recovers `assoc`.

**The key insight is** that each of `unit_eq`/`ops_eq`/`comm` is a single rewrite of one
unit-specialised interchange instance, so the full quaternary law is *consumed* only in
`assoc`; quantifying precisely which instances `assoc` needs exposes the true minimal
interchange skeleton. **Why now?** A hypothesis-by-hypothesis audit is cheap and
immediately widens the applicability of every downstream corollary (more models satisfy
fewer required instances). Falsifiable form: a model satisfying only the two specialised
interchange families but with `op₁ ≠ op₂` would refute the reduction and show the full
interchange law is necessary.
