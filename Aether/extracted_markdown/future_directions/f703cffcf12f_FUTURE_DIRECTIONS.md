# Future Directions: Provability Logic as a Fixed-Point Theory

The file `Logic/LobFixedPoint.lean` isolates the purely order-theoretic core of
the Gödel–Löb provability logic GL. A **Gödel–Löb algebra** is a Heyting algebra
with a provability operator `□` satisfying `□⊤ = ⊤`, `□(a ⊓ b) = □a ⊓ □b`, and the
Löb axiom `□(□a ⇨ a) ≤ □a`. From these three axioms alone we proved:

* `loeb_rule` — Löb's theorem as the statement that `□` has *no nontrivial reflexive
  points*: `□a ≤ a → a = ⊤`;
* `loeb_fixed_point` — `□(□a ⇨ a) = □a`, the de Jongh–Sambin fixed point;
* `box_transitive` — modal axiom 4 (`□a ≤ □□a`) is *derived*, not assumed;
* `godel_second` — Gödel's Second Incompleteness Theorem as the instance of
  `loeb_fixed_point` at `a = ⊥`;
* a concrete consistent model `NatGL` on `Set ℕ` from the well-founded frame `(ℕ, <)`.

The following directions extend this skeleton. Each is stated so that it could be
formalized as Lean theorems building directly on `GLAlgebra`.

## Direction 1 — Uniqueness of modal fixed points (de Jongh–Sambin in algebra)

**Conjecture.** In any Gödel–Löb algebra, if a one-variable "box-guarded" term
`F(x)` is built so that every occurrence of `x` lies inside a `□`, then the fixed
point equation `x = F(x)` has a *unique* solution, and it is expressible without
`x`. The minimal instance `F(x) = □(x ⇨ a)` already has the explicit unique
solution `□a` (this is `loeb_fixed_point`).

*The key insight is* that the Löb axiom is exactly the contraction condition making
the operator `x ↦ □(x ⇨ a)` a Banach-style attracting map in the well-founded
order, so its fixed point is forced and computable rather than merely existent.

*Why now?* The two-element case is already proved (`loeb_fixed_point`); the project
catalog already contains a `BanachFixedPointBridge`, so the contraction analogy can
be made literal by transporting the well-founded descent into a metric/uniform
fixed-point statement and reusing that bridge.

## Direction 2 — Soundness and completeness against finite well-founded models

**Conjecture.** An inequality `s ≤ t` between `□`-terms holds in *every* Gödel–Löb
algebra iff it holds in every `NatGL`-style model built from a finite, irreflexive,
transitive frame. Equivalently, the finite converse-well-founded frames are
*complete* for the equational theory of `GLAlgebra`.

*The key insight is* that `box_transitive` already shows every Gödel–Löb algebra is
internally K4, so the canonical-model construction collapses to finite well-founded
quotients, exactly the frames our `NatGL` instance exemplifies.

*Why now?* We have both halves of the bridge available: the abstract algebra
(`GLAlgebra`) and a working concrete frame model (`NatGL`, `natBox_loeb`). The
remaining step is a filtration argument quotienting an arbitrary algebra by a finite
set of subformulas.

## Direction 3 — The Magari functor and a categorical internal-logic statement

**Conjecture.** The assignment sending a Heyting algebra to its free Gödel–Löb
algebra is a monad whose algebras are exactly the `GLAlgebra` structures, and GL is
the internal propositional logic of the Eilenberg–Moore category of this monad. The
free construction on the one-generator Boolean algebra is the Lindenbaum algebra of
GL.

*The key insight is* that `box_inf` plus `box_top` make `□` a finite-meet-preserving
endofunctor on the algebra-as-thin-category, and the Löb axiom is a dinatural
"diagonal" condition, so the whole package assembles into a (co)monad rather than a
bare operator.

*Why now?* Mathlib's category-theory library supports monads and Eilenberg–Moore
categories directly, and our `GLAlgebra` structure is already phrased so that the
forgetful functor and its axioms can be read off without redefinition.

## Direction 4 — Quantitative Gödel II: provability rank and unprovability spectra

**Conjecture.** Define the *provability rank* of `a` as the least `k` with
`□^{k}a = □^{k+1}a`. In `NatGL` the rank of `⊥` equals its frame depth, and
`godel_second` generalizes to: for every `k`, the `k`-fold consistency statement
`□^{k}⊥ ⇨ ⊥` is unprovable whenever `□^{k}⊥ ≠ ⊤`. There is a strictly increasing
hierarchy of unprovable consistency strengths.

*The key insight is* that iterating `loeb_fixed_point` yields `□(□^{k}⊥ ⇨ ⊥) =
□^{k}⊥` for every `k`, turning the single Gödel II statement into a graded family
indexed by ordinal consistency strength.

*Why now?* `godel_second` is the `k = 1` case and is already proved; the iteration
is a clean induction over `k` that reuses `loeb_fixed_point` verbatim, and `NatGL`
gives a concrete model in which the ranks are explicitly the natural numbers.

## Direction 5 — Cross-domain bridge: provability operators as closure/interior duality

**Conjecture.** The de Morgan dual `◇a := ¬□¬a` of a Gödel–Löb provability operator
is a *well-founded co-closure* (a deflationary, idempotent-on-its-image, join-
preserving operator), and the fixed points of `□` form a frame (locale) on which
`◇` acts as the nucleus of a sublocale. This connects provability logic to the
pointfree-topology and closure-operator material already present in the catalog.

*The key insight is* that `box_transitive` gives `□a ≤ □□a` while `loeb_rule`
forbids reflexive points, so `□` is simultaneously inflationary on theorems and
strictly contracting off them — precisely the signature of a *well-founded* nucleus,
a structure with no analogue among ordinary topological closure operators.

*Why now?* The catalog already develops closure operators and locale-style dualities
in several files; recasting `□` in that language is a direct cross-domain
unification rather than new foundational work, and `NatGL` supplies a testable
concrete locale of upward-closed sets.
