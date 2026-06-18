
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: This cycle hardened the foundation the previous cycle was *resting on but had no
**Domain**: Applications
**Mathematical framing**: # Future Directions — Closing the Equivalence Calculus and the Universality of Interchange

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

**Concept description**: # Future Directions — Closing the Equivalence Calculus and the Universality of Interchange

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

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
