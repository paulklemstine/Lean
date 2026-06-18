# Future Directions — Closing the Equivalence Calculus and the Universality of Interchange

## Synthesis

This cycle hardened the foundation the previous cycle was *resting on but had not
actually committed to the tree*, and then pushed the equivalence calculus to its
purely-formal limits. Concretely, the synthetic-HoTT foundation
`Logic.HomotopyTypeTheory` (the home of `HoTT.IsContr`, `HoTT.IsMereProp`,
`HoTT.HFiber`, `HoTT.Magma`/`MagmaHom`/`MagmaIso`, and the named transports
`HoTT.magma_comm_transport` / `HoTT.magma_assoc_transport`) was authored and verified,
so that last cycle's `PathSpaceHLevels` and `EquivalenceCalculus` now compile
end-to-end. On top of that repaired base, four new `sorry`-free files were added under
`Speculative/AutoResearch/`, each resolving one of last cycle's falsifiable questions:

* `EquivalenceTwoOutOfSix.lean` — the **2-out-of-6 law** for fibrewise equivalences
  (`HoTT.isEquiv_two_out_of_six`), with the crux isolated as
  `HoTT.isEquiv_middle_of_six`: the middle map is pinned down with *no* extra section.
* `HalfAdjointEquiv.lean` — the **property ↔ structure bridge**
  `HoTT.isEquiv_iff_nonempty_isHEquiv`, the uniqueness of the inverse
  (`HoTT.IsHEquiv.inv_unique`), and the structured groupoid laws.
* `EckmannHilton.lean` — the abstract **Eckmann–Hilton engine**: two unital
  operations sharing a unit and satisfying interchange coincide
  (`EckmannHilton.same_op`), are commutative (`EckmannHilton.comm`,
  `EckmannHilton.comm₂`), and associative (`EckmannHilton.assoc`).
* `UnivalenceLiteEquationalTheory.lean` — **uniform transport for an arbitrary
  equational theory** via the `HoTT.FreeMagma` term datatype: naturality of
  evaluation (`HoTT.evalMagma_hom`) and the universal transport theorem
  (`HoTT.equation_transport`), recovering commutativity/associativity transport as
  one-line corollaries.

The unifying theme remains **representation/duality**: every homotopical question
about equivalences is faithfully represented by `Function.Bijective`, every algebraic
axiom is represented by a `FreeMagma` term, and the interchange law is the
representation of "two compositions on the same higher cells". Three of last cycle's
sharp questions are now answered in the affirmative — 2-out-of-6 holds *verbatim*,
`IsEquiv` *is* the property shadow of structured inverse data, and equational
transport is *balancedness-blind*.

## Results summary

Fully proved this cycle (`sorry = 0`; axioms ⊆ {`propext`, `Classical.choice`,
`Quot.sound`}):

* `HoTT.isEquiv_middle_of_six`, `HoTT.isEquiv_two_out_of_six` — the 2-out-of-6 law.
* `HoTT.IsHEquiv` (structure), `HoTT.IsHEquiv.bijective`, `HoTT.IsHEquiv.isEquiv`,
  `HoTT.IsHEquiv.inv_unique`, `HoTT.IsHEquiv.comp`, `HoTT.isHEquiv_id`,
  `HoTT.isEquiv_iff_nonempty_isHEquiv` — the structured equivalence layer and bridge.
* `EckmannHilton.same_op`, `EckmannHilton.comm`, `EckmannHilton.comm₂`,
  `EckmannHilton.assoc` — the Eckmann–Hilton engine.
* `HoTT.evalMagma`, `HoTT.evalMagma_hom`, `HoTT.equation_transport`,
  `HoTT.comm_transport_of_universal`, `HoTT.assoc_transport_of_universal` —
  univalence-lite for arbitrary equational theories.
* Foundation: `HoTT.IsContr`, `HoTT.IsMereProp`, `HoTT.HFiber`,
  `HoTT.bijective_of_contr_fibers`, `HoTT.Magma`, `HoTT.MagmaHom`, `HoTT.MagmaIso`,
  `HoTT.magma_comm_transport`, `HoTT.magma_assoc_transport`.

## Direction 1 — A concrete non-degenerate Eckmann–Hilton model and `π₂` abelian

The abstract engine (`EckmannHilton.same_op`/`comm`/`assoc`) is now `sorry`-free, but
in Lean's *strict* equality the only double-loop `2`-cell at a fixed base is `rfl`, so
the naive loop-space instance is degenerate. The bold target is to instantiate
`EckmannHiltonData` on a genuinely *non-trivial* model — e.g. the endomorphism monoid
of a commutative monoid under composition versus pointwise product, or the centre of a
monoid with two compatible products — and thereby produce an honest abelian-ness
theorem that is *not* vacuous. **The key insight is** that the interchange law, not the
ambient topology, is the entire mathematical content, so any pair of operations with a
shared unit and the medial law furnishes a model, decoupling "Eckmann–Hilton" from
literal homotopy groups. **Why now?** The engine is proven and the obstruction is
exactly identified (strict equality kills the topological instance), so the next step
is the targeted, falsifiable search for a model whose two operations are provably
distinct before the argument forces them equal — turning the slogan "interchange ⇒
commutative" into a theorem about a structure one can actually compute in.

## Direction 2 — The half-adjoint coherence and contractibility of inverse data

`HalfAdjointEquiv.lean` proves `IsEquiv f ↔ Nonempty (IsHEquiv f)` and that the
inverse *function* is unique (`IsHEquiv.inv_unique`). The next layer is to upgrade
bi-invertibility to the *half-adjoint* notion (adding the triangle coherence
`adj : ∀ a, right_inv (f a) = congrArg f (left_inv a)`) and to prove the sharper
statement that **the whole type `IsHEquiv f` of inverse data is a mere proposition**
(`HoTT.IsMereProp (IsHEquiv f)`), hence contractible when `f` is an equivalence.
**The key insight is** that `inv_unique` already collapses the `inv` component, so what
remains is the proof-irrelevance of the two `left_inv`/`right_inv` homotopy fields,
which is automatic in Lean's `Prop`-valued equality — the only genuinely
proof-relevant datum is the inverse, and that is unique. **Why now?** With the bridge
and inverse-uniqueness in hand, the contractibility statement is the precise formal
content of "being an equivalence is a property, not extra structure", and it is the
last coherence needed before the structured layer can replace `IsEquiv` everywhere
without changing any downstream theorem.

## Direction 3 — A 2-out-of-`n` ladder and the saturation of weak equivalences

2-out-of-3 (last cycle) and 2-out-of-6 (this cycle) are the first two rungs; the
conjecture is a uniform **2-out-of-`n` ladder**: for any finite composable chain
`f₁, …, fₙ`, if every *adjacent pair composite* `fᵢ₊₁ ∘ fᵢ` is an equivalence then
every map and every sub-composite in the chain is an equivalence. **The key insight is**
that `isEquiv_middle_of_six` generalises verbatim — each interior map `fᵢ` is squeezed
between the two adjacent composites, giving injectivity from one side and surjectivity
from the other — so the whole ladder reduces to an induction over the chain length with
the bijection dictionary doing the work at each step. **Why now?** The base case
(`n = 3`) and the decisive middle-map lemma (`n = 6` interior) are both proven, so the
remaining content is purely the inductive packaging over `List`/`Fin n`-indexed chains,
a clean falsifiable claim (does adjacency suffice, or does one need every *non-adjacent*
composite as a hypothesis?).

## Direction 4 — Multi-sorted and higher-arity universal transport

`HoTT.equation_transport` transports every *single-sorted, binary* equational axiom
along a magma isomorphism. The structural generalisation is a transport theorem for an
**arbitrary algebraic signature** — finitely many operations of arbitrary arities,
possibly multi-sorted — yielding "group structure transports", "ring structure
transports", and "module structure transports" as instances of one theorem. **The key
insight is** that `evalMagma_hom` (homomorphisms commute with term evaluation) is
already arity-agnostic in spirit: replacing `FreeMagma`'s single binary `op` by a
signature-indexed family of operation symbols leaves the structural induction and the
`surjInv` pullback untouched. **Why now?** The binary prototype is `sorry`-free and the
proof never used arity `2` except in the `op` constructor, so the generalisation is a
mechanical re-indexing of the term datatype — a sharp, falsifiable target (does the
uniform transport survive operations of arity `0`, i.e. constants/units, which a
surjection-pullback must also respect?).

## Direction 5 — Localisation: inverting the equivalences and the homotopy category

All the machinery above (2-out-of-3, 2-out-of-6, structured inverses, transport)
describes a *class* `W` of weak equivalences closed under the groupoid laws. The bold
unifying step is to construct the **localisation** `Type[W⁻¹]` that universally inverts
`W` and to prove its universal property: any functor sending `W` to isomorphisms
factors uniquely through it, and the localisation of `Type` at `IsEquiv` is the
homotopy category in which contractible types become terminal (linking back to
`HoTT.isContr_unique_equiv` and `maps_to_contractible_homotopic`). **The key insight is**
that the 2-out-of-3 / 2-out-of-6 laws are *exactly* the closure conditions a calculus of
fractions requires, so the localisation can be built by formal zig-zags whose
composability is guaranteed by the laws already proven. **Why now?** The class `W` is now
proven to satisfy every closure law a localisation needs, and the terminal-object
picture of contractibility is in place, so the localisation is the natural capstone that
converts a collection of point-wise equivalence lemmas into a single universal
construction — a falsifiable claim that the abstract `IsEquiv` calculus is *complete*
enough to support a calculus of fractions with no further hypotheses.
