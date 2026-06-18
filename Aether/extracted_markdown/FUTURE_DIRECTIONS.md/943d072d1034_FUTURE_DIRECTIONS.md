# Future Directions: Provability Logic as a Fixed-Point Theory

## Synthesis of this cycle

This cycle built the **order-theoretic core of Gödel–Löb provability logic GL** as a
self-contained, axiom-clean Lean development across two files.

* `Catalog/Logic/LobFixedPoint.lean` introduces the typeclass `GLOperator` — a
  Heyting algebra with a provability operator `□` satisfying only `□⊤ = ⊤`,
  `□(a ⊓ b) = □a ⊓ □b`, and **Löb's axiom** `□(□a ⇨ a) ≤ □a`. From these three
  equations *alone* we derive the whole skeleton of GL:
  - `box_mono` — monotonicity is a *theorem*, squeezed out of meet-preservation;
  - `loeb_fixed_point` — the **de Jongh–Sambin fixed point** `□(□a ⇨ a) = □a`;
  - `loeb_rule` — **Löb's theorem**, `□a ≤ a → a = ⊤` ("no nontrivial reflexive
    points");
  - `box_transitive` — **modal axiom 4** `□a ≤ □□a` is *derived* (Sambin's diagonal
    `a ⊓ □a`), not assumed;
  - `godel_second` / `consistency_unprovable` — **Gödel's Second Incompleteness
    Theorem** as the `a = ⊥` instance of the fixed point.

* `Catalog/Logic/LobNatModel.lean` realises the typeclass in the concrete
  converse-well-founded frame `(ℕ, >)`: `natBox S = {n | ∀ m < n, m ∈ S}`. Here we
  go beyond mere existence and *compute*:
  - `natBox_loeb` + the `GLOperator (Set ℕ)` instance `NatGL`;
  - `natGL_consistent` — the model is consistent (`□⊥ = {0} ≠ ⊤`);
  - `natBox_iterate_eq_Iio` — **the provability-rank computation**
    `□^k⊥ = Set.Iio k`: frame depth and iteration index coincide;
  - `consistency_strength_strictMono` — the consistency strengths `k ↦ □^k⊥` form a
    **strictly increasing** chain that never reaches `⊤`;
  - `godel_hierarchy` — **graded Gödel II**: every nontrivial `k`-fold consistency
    statement `□^{k+1}⊥ ⇨ ⊥` is unprovable, an explicit unprovability spectrum.

The development is cross-linked with the existing catalog: `GLOperator`'s box is the
algebraic shadow of `GLFrame.boxSet` (`Catalog/Logic/GLKripke.lean`), and the rank
computation makes the "time-stamped" intuition of `Catalog/Logic/TemporalGL.lean`
(`godel_second_at_time`) quantitative.

## Results summary

| Theorem | File | Content |
|---|---|---|
| `GLOperator.loeb_fixed_point` | LobFixedPoint | `□(□a ⇨ a) = □a` |
| `GLOperator.loeb_rule` | LobFixedPoint | `□a ≤ a → a = ⊤` |
| `GLOperator.box_transitive` | LobFixedPoint | axiom 4 derived from Löb |
| `GLOperator.godel_second` | LobFixedPoint | Gödel II at `⊥` |
| `natBox_iterate_eq_Iio` | LobNatModel | `□^k⊥ = Iio k` |
| `consistency_strength_strictMono` | LobNatModel | strictly increasing consistency chain |
| `godel_hierarchy` | LobNatModel | graded Gödel II / unprovability spectrum |

All main results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

---

## Direction 1 — Uniqueness of modal fixed points (de Jongh–Sambin in algebra)

**Conjecture.** In any `GLOperator`, the box-guarded operator `x ↦ □(x ⇨ a)` has a
*unique* fixed point, and it is `□a`. More generally, any operator `F(x)` in which
every occurrence of `x` lies under a `□` admits a unique fixed point expressible
without `x`. Formally: `□(x ⇨ a) = x → x = □a`, and the minimal-instance uniqueness
should be provable directly from `loeb_fixed_point` and `loeb_rule`.

*The key insight is* that Löb's axiom is exactly the contraction condition that turns
`x ↦ □(x ⇨ a)` into an attracting map in the well-founded order: `loeb_rule` already
forbids nontrivial reflexive points, so two fixed points must collapse to one. We
proved *existence* (`loeb_fixed_point`); uniqueness is the missing antisymmetry step,
and it should reduce to applying `loeb_rule` to the bi-implication of two solutions.

*Why now?* The fixed point itself is already formalised (`loeb_fixed_point`), and
`box_mono` plus `loeb_rule` give precisely the monotonicity-and-rigidity pair a
uniqueness proof needs. The catalog's `BanachFixedPointBridge` makes the
"contraction ⇒ unique fixed point" analogy literal: transporting the well-founded
descent of `natBox` into that uniform-space statement is a concrete next file.

## Direction 2 — Completeness against finite well-founded models

**Conjecture.** An inequality `s ≤ t` between `□`-terms holds in *every* `GLOperator`
iff it holds in every `NatGL`-style model cut down to a finite initial segment
`Set (Fin n)` with the `>`-box. Equivalently, the finite converse-well-founded frames
are complete for the equational theory of `GLOperator`.

*The key insight is* that `box_transitive` shows every `GLOperator` is internally K4,
so the canonical-model construction collapses onto finite well-founded quotients —
exactly the frames our `natBox` instance exemplifies. Soundness is immediate from the
instance; the hard half is a filtration argument.

*Why now?* Both halves of the bridge are in place: the abstract algebra
(`GLOperator`) and a working concrete model (`NatGL`, `natBox_iterate_eq_Iio`). The
remaining step is to quotient an arbitrary algebra by a finite set of subformulas and
embed the quotient into a finite `natBox`-style frame.

## Direction 3 — The Magari functor as a monad

**Conjecture.** The assignment sending a Heyting algebra to its free `GLOperator` is a
monad on the category of Heyting algebras, whose Eilenberg–Moore algebras are exactly
the `GLOperator` structures; GL is the internal propositional logic of that
Eilenberg–Moore category.

*The key insight is* that `box_top` and `box_inf` make `□` a finite-meet-preserving
endofunctor on the algebra-viewed-as-thin-category, and Löb's axiom is a dinatural
"diagonal" condition — so the package assembles into a (co)monad rather than a bare
operator. `box_transitive` is then the comultiplication law in disguise.

*Why now?* Mathlib supports monads and Eilenberg–Moore categories directly, and
`GLOperator` is phrased so the forgetful functor and its laws can be read off without
redefinition. The free construction on the one-generator Boolean algebra would be the
Lindenbaum algebra of GL — a concrete, testable target.

## Direction 4 — Ordinal provability rank beyond `ω`

**Conjecture.** The rank computation `□^k⊥ = Iio k` extends transfinitely: defining
`□^α⊥` for ordinals `α` by `□^{α}⊥ = ⋃_{β<α} □(□^β⊥)` in a complete `GLOperator`, the
canonical model on `Set Ordinal` (with the `>`-box) satisfies `□^α⊥ = Iio α`, giving a
proper class of strictly increasing unprovable consistency strengths indexed by the
ordinals.

*The key insight is* that `natBox_iterate_eq_Iio` already identifies provability rank
with the identity on `ℕ`; the only obstruction to climbing past `ω` is taking suprema,
which a *complete* Heyting algebra supplies. `consistency_strength_strictMono` is the
`< ω` fragment, and ordinal well-foundedness is exactly the converse-well-foundedness
Löb's axiom encodes.

*Why now?* The finite hierarchy is fully proved and the limit step is a single
`iSup`/`Set.Iio` computation on `Ordinal`. Mathlib's `Ordinal` library has the
well-founded recursion and `Iio` lemmas needed, so this is a clean continuation
rather than new foundations.

## Direction 5 — Provability box as a well-founded nucleus (closure/interior duality)

**Conjecture.** The de Morgan dual `◇a := (□aᶜ)ᶜ` of a `GLOperator` is a *well-founded
co-closure* — deflationary, join-preserving, idempotent on its image — and the fixed
points of `□` form a frame on which `◇` acts as the nucleus of a sublocale. In `NatGL`
this is the locale of upward-closed (here: downward-determined) subsets of `(ℕ, >)`.

*The key insight is* that `box_transitive` gives `□a ≤ □□a` (inflationary on theorems)
while `loeb_rule` forbids reflexive points (strictly contracting off them): precisely
the signature of a *well-founded* nucleus, a structure with no analogue among ordinary
topological closure operators. `box_inf` supplies the finite-meet preservation a
nucleus requires.

*Why now?* The catalog already develops closure operators and locale-style dualities;
recasting `□` in that language is cross-domain unification rather than new groundwork,
and `NatGL` (with `natBox_iterate_eq_Iio`) supplies a concrete, computable locale to
test every nucleus law against.
