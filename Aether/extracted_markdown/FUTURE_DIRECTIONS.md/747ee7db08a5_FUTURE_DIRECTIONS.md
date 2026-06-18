# Future Directions — The Eckmann–Hilton Bridge (Homotopy & Path-Spaces cycle)

## Synthesis

This cycle delivered `Catalog/Speculative/AutoResearch/EckmannHiltonMonoid.lean`, a
`sorry`-free file that pins down the *exact* algebraic content of the Eckmann–Hilton
argument. The catalog already contained the abstract engine
(`EckmannHiltonData` with `EckmannHilton.same_op` / `comm` / `assoc`) and a parallel
synthetic-homotopy development (`PathSpaceHLevels.lean`: contractibility of path
spaces, h-level closure, "equivalence ⇔ contractible fibres"). What was missing was
the statement that closes the loop: the interchange law does not merely *collapse*
two operations, it lands them precisely on the theory of **commutative monoids** —
nothing weaker, nothing stronger — and the resulting two-dimensional data is rigidly
determined by its one-dimensional shadow.

## Results summary

* `toCommMonoid` / `ofCommMonoid` — a round trip between `EckmannHiltonData X` and
  `CommMonoid X`.
* `eh_iff_commMonoid` — the operation-level equivalence of the two equational
  theories: an operation-with-unit is the vertical composition of some Eckmann–Hilton
  structure **iff** it is the multiplication of a commutative monoid.
* `pi_two_commutative` — the abstract "the second homotopy group is abelian"
  corollary (`m₁ a b = m₂ b a`).
* `structure_rigidity` — the vertical operation `m₁` alone determines the unit and
  the horizontal operation `m₂`: the 2-dimensional bookkeeping carries no extra
  information.
* `monoid_comm_of_second_interchange` — a Mathlib-grounded corollary: a monoid that
  admits a *second* unital operation interchanging with its multiplication is forced
  to be commutative (the "homotopy-commutativity of a double loop space", made
  one-line).

All results build on the catalog foundation by `import
Speculative.AutoResearch.EckmannHilton` and reuse `EckmannHilton.assoc/comm/same_op`
directly rather than reproving them.

---

## Direction 1 — A `CommMonoid ≃ EckmannHiltonData` equivalence of *categories*, not just operations

`eh_iff_commMonoid` is stated at the level of (operation, unit) pairs. The bold next
step is to upgrade it to an honest equivalence of categories: build the category of
Eckmann–Hilton structures with structure-preserving maps, the category of commutative
monoids with monoid homomorphisms, and exhibit `toCommMonoid`/`ofCommMonoid` as an
adjoint equivalence (in fact an isomorphism of categories on the nose, by
`structure_rigidity`).

**The key insight is** that `structure_rigidity` already proves the functors are
essentially injective on objects, so the only remaining content is functoriality on
morphisms — and a morphism of Eckmann–Hilton data is *forced* to be a monoid
homomorphism for `m₁`, again by `same_op`. **Why now?** The rigidity lemma is the
hard part and it is already in hand; the categorical wrapper is a mechanical but
high-value packaging that makes the result reusable by any downstream functorial
construction.

Falsifiable form: there is **no** Eckmann–Hilton structure morphism that fails to be
an `m₁`-monoid homomorphism. A single counterexample would refute the conjecture.

## Direction 2 — Graded / higher Eckmann–Hilton and the loss of strict commutativity

In dimension `n ≥ 2` the classical statement is "`πₙ` is abelian", but in the
*graded* / *braided* world (e.g. `E₂` algebras) commutativity weakens to a braiding.
Conjecture: a graded analogue of `EckmannHiltonData`, where the interchange law holds
only up to a fixed permutation of indices, yields exactly **commutative** structures
when the grading is trivial and **braided** ones otherwise, and the braiding is
forced to square to the identity (the "syllepsis").

**The key insight is** that the single equation `interchange`, specialised at the
unit, is what produces commutativity; replacing strict interchange by a *natural*
interchange isomorphism should produce a braiding whose two derivations (the two ways
of reading the unit specialisation) must agree, forcing `β² = id`. **Why now?** We
have a fully formal, minimal-hypothesis engine (`EckmannHiltonData`) whose every
field is load-bearing; perturbing exactly one field (interchange → interchange-iso) is
a controlled experiment that isolates where strict commutativity comes from.

Falsifiable form: the perturbed engine produces a braiding with `β² ≠ id` for some
model — which would contradict the syllepsis prediction.

## Direction 3 — A concrete topological instantiation via `ContinuousMap` and path concatenation

`PathSpaceHLevels.lean` already proves contractible targets are terminal up to
homotopy. Combine this with the Eckmann–Hilton engine to produce a *concrete*
witness: on `π₀` of a topological monoid (or on `Path.Homotopic.Quotient` of a loop
space), vertical and horizontal concatenation give genuine `EckmannHiltonData`, so
`monoid_comm_of_second_interchange` yields commutativity of the relevant `π`.

**The key insight is** that Mathlib's `ContinuousMap.Homotopic` is an equivalence
relation compatible with both pointwise multiplication and concatenation, so the
interchange law holds *on the quotient* even though it fails on the nose — exactly the
setting the abstract engine was designed for. **Why now?** Both halves exist and are
`sorry`-free in this catalog (the engine here, the homotopy API in
`PathSpaceHLevels`); the bridge is the first genuinely *topological* payoff of the
abstract result and validates that the engine is not vacuous.

Falsifiable form: exhibit a topological monoid whose `π₀` is **non**-commutative — it
would show the interchange hypothesis silently fails, sharpening exactly which spaces
the bridge applies to.

## Direction 4 — Minimal axioms: can the four unit laws be cut to two?

`EckmannHiltonData` carries four unit laws (`m₁`/`m₂` × left/right). Conjecture:
two-sided unitality of *one* operation plus *one-sided* unitality of the other still
forces `same_op`, hence the full conclusion; i.e. two of the four unit fields are
derivable.

**The key insight is** that `same_op` only ever specialises interchange at the shared
unit, and tracking which unit law is consumed in each rewrite suggests at least one is
redundant once the other operation is known to share the unit. **Why now?** A
`lean_minimal_hypotheses`-style audit of the engine is cheap and immediately tells us
the true axiomatic core, which then tightens every downstream theorem (including
`monoid_comm_of_second_interchange`, where fewer hypotheses = wider applicability).

Falsifiable form: a model satisfying the *reduced* axioms but with `m₁ ≠ m₂` would
refute the reduction and show all four laws are independent.

## Direction 5 — Eckmann–Hilton over a base: fibrewise commutativity and local-to-global

Index the engine over a base type `B`: a family `E : B → EckmannHiltonData (X b)` of
fibrewise structures. Conjecture: fibrewise Eckmann–Hilton data assembles to a
`CommMonoid` structure on the section type `∀ b, X b`, and the assignment
`b ↦ toCommMonoid (E b)` is a sheaf of commutative monoids whenever the base carries a
topology and the operations vary continuously.

**The key insight is** that `isContr_fun` and `isContr_sigma` from
`PathSpaceHLevels.lean` already show the h-level hierarchy is closed under dependent
products and sums, so commutative-monoid structure — being an h-prop-valued algebraic
predicate on a *fixed* operation — should glue fibrewise by the same mechanism.
**Why now?** This is the cross-domain fusion the catalog is built for: it marries the
algebraic rigidity proved here with the fibrewise/contractibility toolkit proved in
the sibling path-space file, turning a pointwise theorem into a local-to-global one.

Falsifiable form: a continuously-varying family whose section monoid is
non-commutative would break the gluing and expose a missing continuity hypothesis.
