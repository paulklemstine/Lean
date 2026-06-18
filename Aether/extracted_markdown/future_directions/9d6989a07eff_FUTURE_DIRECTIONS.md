# Future Directions: The Logic–Physics Bridge

The file `Catalog/Bridges/LogicPhysicsBridge.lean` formalizes an abstract framework
relating *physical realizability* (a theory having a model — a world that satisfies it)
to *proof-theoretic consistency* (non-derivability of falsum). It proves the asymmetry
between the two notions: physical consistency implies mathematical consistency
(`physical_implies_mathematical`), but not conversely (`math_consistency_not_sufficient`).
It isolates the exact strength the bridge needs — falsum-soundness rather than full
soundness (`model_implies_consistency_weak`, `falsum_sound_strictly_weaker`) — and sketches
two structural extensions: the completeness collapse (`completeness_collapse`) and a
superposition-closed quantum strengthening (`quantum_strictly_stronger`).

The directions below extend that frontier. Each is stated so it can be falsified by a
single counterexample inside the existing framework (`ProofSystem`, `Semantics`,
`HasModel`, `Sound`, `FalsumSound`, `QSemantics`).

## Direction 1: A canonical-model construction that internalizes the completeness collapse

We proved `completeness_collapse`: for a sound *and* complete semantics, `Consistent T ↔
PhysicallyConsistent T`. But completeness is currently an external hypothesis. The next step
is to *build* a witness: a generic "Lindenbaum/term-model" functor `term : ProofSystem S →
Semantics P` whose worlds are maximal consistent extensions of `T`, together with a proof
that `term P` is automatically sound and complete whenever `P` is closed under a small set of
structural rules (cut, negation introduction).

**The key insight is** that the gap between consistency and satisfiability collapses exactly
when the proof system can name its own maximal consistent extensions — so completeness is not
an extra axiom but a *closure property* of the consequence relation, and `completeness_collapse`
becomes a theorem about all sufficiently closed systems rather than an implication from an
assumed `Complete M`.

**Why now?** We already have `Complete`, `Sound`, and the collapse theorem as a target; the
only missing piece is the constructor `term` and the verification that it satisfies them.
**If true:** the phase boundary between logic and physics is pinned down by an explicit,
checkable structural-closure condition. **If false:** there is a closed proof system whose
term model is sound but incomplete, exposing a genuinely semantic obstruction to realizability.

## Direction 2: Consistency-strength towers via an internal provability predicate

Extend `ProofSystem` with a unary `con : S → S` (an internal "consistency sentence" operator)
satisfying an abstract Hilbert–Bernays/Löb-style discipline, and conjecture that for any
consistent `T` the sentence `con(⊥-of-T)` is *unprovable* from `T`, so
`proper_extension_new_theorem` yields a strict tower `T ⊊ T ∪ {con T} ⊊ T ∪ {con(T ∪ {con T})}
⊊ ⋯` of ever-stronger consistent extensions.

**The key insight is** that our `proper_extension_new_theorem` already supplies the *structural*
step (an unprovable sentence makes a proper, theorem-gaining extension); all that is missing is
the *independence* of the consistency sentence, which is precisely the content of Gödel's second
incompleteness theorem and can be axiomatized abstractly as a fixed-point property of `con`.

**Why now?** The extension machinery is proven and reusable; isolating the diagonal/independence
property as a single hypothesis lets us derive the whole tower without re-encoding arithmetic.
**If true:** a formal, framework-level consistency-strength hierarchy emerges for free. **If
false:** our abstract proof systems are too weak to host Gödelian self-reference, identifying the
minimal expressiveness needed for incompleteness.

## Direction 3: Compositionality of consistency over disjoint vocabularies

Define a "vocabulary restriction" of a `ProofSystem` (a sub-`Set S` closed under `Proves`) and
conjecture: if `T₁` and `T₂` are consistent and their vocabularies share only falsum, then
`T₁ ∪ T₂` is consistent. Disprove or prove using a Craig-interpolation-style separation of
derivations.

**The key insight is** that a derivation of falsum from `T₁ ∪ T₂` must, by interpolation, route
through a sentence in the shared vocabulary; if the only shared sentence is `⊥` itself, no genuine
interaction is possible, so consistency must compose — formalizing the physical intuition that
non-interacting subsystems cannot jointly create a contradiction.

**Why now?** We have `Consistent` and `consistency_antimono` (monotonicity); composition is the
natural dual structural property, and the empty-world separation already shows our framework is
expressive enough to host genuine counterexamples. **If true:** a formal basis for modular
physical theory-building. **If false:** the counterexample reveals how "independent" theories
secretly interact through shared logical scaffolding.

## Direction 4: Strictness of the full quantum hierarchy and a superposition-soundness bridge

We proved `quantum_implies_physical` and `quantum_strictly_stronger` (quantum ⊊ physical).
Combined with `math_consistency_not_sufficient` this gives a three-level chain
`Quantum ⊊ Physical ⊊ Mathematical`. The next step is to (a) prove the chain *as a single
strict tower* over one fixed framework, and (b) identify a "superposition-soundness" rule on
`QSemantics` under which `QuantumPhysicallyConsistent` itself implies `Consistent` via the same
falsum-soundness argument, so the quantum layer plugs into the bridge with no extra hypotheses.

**The key insight is** that `QSemantics` already parameterizes a *structured* space of worlds, so
adding a single algebraic law (`superpose` preserves `sat` on a designated closed set) turns the
ad-hoc closure clause of `QuantumPhysicallyConsistent` into a soundness condition, making the
quantum notion a genuine refinement of `Sound` rather than a separate definition.

**Why now?** Both endpoints of the chain are already theorems; only the unifying single-framework
strictness and the superposition-soundness lemma remain. **If true:** a clean hierarchy of
realizability strengths with one proof technique throughout. **If false:** superposition closure
is orthogonal to consistency strength, meaning quantum structure constrains *which* models exist
but not *whether* contradictions are derivable.

## Direction 5: Computable realizability as an intermediate layer

Specialize `Semantics` to `ComputableSemantics`, where `World` carries a `Encodable`/`Primrec`
structure and `sat` is decidable, and conjecture a strict three-way separation: there are
theories that are consistent with no model at all (`math_consistency_not_sufficient`), theories
with a model but no *computable* model, and theories with a computable model.

**The key insight is** that physical realizability has a finer grain than "having a model":
computability inserts a third level between syntax and semantics, exactly mirroring the gap
between classical and constructive existence, and our framework is already parametric over the
world type, so restricting to computable interpretations is a clean specialization rather than a
redesign.

**Why now?** Mathlib's `Encodable`/`Computable` API makes `ComputableSemantics` definable today,
and the empty-world separation gives the bottom of the hierarchy for free. **If true:** physical
realizability (computability) is formally established as an intermediate notion between
provability and satisfiability. **If false:** for decidable proof systems every model can be made
computable — a form of effective completeness with consequences for automated model-building.
