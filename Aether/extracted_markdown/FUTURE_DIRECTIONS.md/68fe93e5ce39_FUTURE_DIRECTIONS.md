# Future Directions — Tangled Hierarchies (GL-Kripke geometry of self-soundness)

Derived from this cycle's findings in `Core.lean`, `SelfSoundness.lean`,
`Examples.lean`. This cycle established, on finite transitive irreflexive
(well-founded) Kripke geometries:

* the *untangled* reflection schema `□S → S` collapses (`reflection_collapse`);
* the *tangled* fixed-point principle `□(□S → S) → □S` (Löb) is always valid;
* the consistency sentence is its **own** Gödel fixed point `Con = ¬□Con`
  (`consistency_is_godel_fixed_point`), giving a geometric Gödel II
  (`godel_second_incompleteness`).

The conjectures below are bold, falsifiable refinements.

---

## Conjecture 1 — Bounded Tangling (one diagonal, never a schema)

A consistent GL geometry hosts a self-referential soundness predicate for the
*single* target `⊥` (its consistency sentence), but no consistent geometry can
host a self-referential predicate `Sound` satisfying `Sound = ¬□Sound` together
with the *global* soundness schema `□S → S` restricted to any infinite,
nontrivially-closed family of `S`.

**The key insight is** that `reflection_collapse` forbids a sound schema while
`canonicalSelfSound` provides exactly one diagonal sentence — tangling is real
but *measure-zero*: it never spreads from one fixed point to a whole hierarchy.

**Why now?** We already have both the impossibility (`reflection_collapse`) and
the single witness (`canonicalSelfSound`) compiled in the same namespace; the
conjecture is the precise frontier between them and is a finite combinatorial
statement amenable to the same well-founded induction used for Löb.

---

## Conjecture 2 — Rank-Graded Consistency Strength

Define the rank `ρ(w)` of a world as its height in the well-founded
accessibility geometry (`wf_flip`). Then a world validates the `n`-fold iterated
consistency assertion `□ⁿ Con` **iff** `ρ(w) ≥ n`. In particular the maximal
number of nested "I am consistent" assertions a world can carry is exactly its
rank.

**The key insight is** that each `□` step strips one level of the well-founded
geometry (the Gödel-II step `□Con → □⊥` consumes one rank), so iterated
provability is literally a ruler measuring geometric depth.

**Why now?** `godel_two_frame` already encodes the single-step descent; turning
it into a rank function is the natural induction, and `wf_flip` supplies the
recursion principle out of the box.

---

## Conjecture 3 — Uniqueness of Tangled Fixed Points (de Jongh–Sambin, frame form)

Every *box-modalized* set operator `Φ : Set World → Set World` (one where
membership of `w` in `Φ S` depends on `S` only through successors of `w`) has a
**unique** fixed point on each GL geometry, and that fixed point is explicitly
computable by well-founded recursion along `wf_flip`.

**The key insight is** that the very well-foundedness that powers Löb's theorem
also makes the diagonal recursion well-defined and rigid: there is no room for a
second solution because successors are strictly lower in the geometry.

**Why now?** The consistency sentence is the special case `Φ S = (□S)ᶜ` already
proven to be a fixed point; generalizing the explicit construction to all
modalized `Φ` reuses the identical `wf_flip` recursion.

---

## Conjecture 4 — Polymodal Tangling Is Strictly Worse

On a geometry carrying two transitive irreflexive relations `R₁, R₂` (two
provability operators `□₁, □₂`), the *joint* consistency sentence
`Con₁₂ = (□₁⊥)ᶜ ∩ (□₂⊥)ᶜ` is generally **not** a fixed point of either single
"not-provable" operator; a genuine fixed point exists only for the relation that
contains the other. Hence relative interpretability is detectable purely from
which single box can diagonalize the joint consistency sentence.

**The key insight is** that Gödel II (`godel_two_frame`) is relation-specific:
seeing a `R₁`-dead-end is unrelated to seeing a `R₂`-dead-end, so tangling
fragments across modalities and exposes their ordering.

**Why now?** The catalog already gestures at polymodal GL (`Logic/PolymodalGL`);
our `godel_two_frame` is stated for a single abstract `R`, so instantiating it
twice and comparing is immediate.

---

## Conjecture 5 — Self-Sound Frames Form a Reflective Subcategory

Frame morphisms (bounded p-morphisms) between GL geometries lift to morphisms of
`SelfSoundFrame`, and `canonicalSelfSound` is the right adjoint (coreflector)
sending each geometry to its canonical self-referential soundness predicate;
every self-sound frame maps uniquely to a canonical one preserving `Con`.

**The key insight is** that the consistency fixed point is *natural* — it is
defined uniformly as `(□⊥)ᶜ` with no choices — so it must be functorial, and
universality follows from uniqueness (Conjecture 3).

**Why now?** `canonicalSelfSound` is already a total, choice-free construction in
`SelfSoundness.lean`; only the morphism layer is missing, and the catalog's
`Geometry/CategoricalTower` provides the categorical scaffolding to reuse.
