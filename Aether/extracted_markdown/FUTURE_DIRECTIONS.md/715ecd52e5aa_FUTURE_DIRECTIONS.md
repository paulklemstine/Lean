# Future Directions: The Logic–Physics Bridge

## Synthesis

This cycle built, from scratch and with zero `sorry`, an abstract framework for
the relationship between **physical realizability** (a theory *has a model* in
an ambient space of "worlds") and **proof-theoretic consistency** (a theory does
not *prove falsum*). The artifact lives in
`Catalog/Speculative/AutoResearch/LogicPhysicsBridge.lean` and exports six
machine-checked theorems built on a tiny, reusable vocabulary: `ProofSystem`,
`Semantics`, `HasModel`, `Consistent`, `PhysicallyConsistent`, `FalsumSound`,
`Sound`, and `PhysicallyComplete`.

The central narrative is an asymmetry. The *physics → logic* direction,
`physical_implies_mathematical`, holds under a strikingly weak hypothesis:
**falsum-soundness**, the demand that the semantics never validate a *satisfied*
falsum derived from a *satisfied* premise set. It does not require full
soundness, as `sound_implies_falsum_sound` and the separating witness
`falsum_sound_strictly_weaker` (a rogue deduction rule that is honest about
contradictions yet lies about an atom) together establish. The converse
*logic → physics* direction fails outright: `math_consistency_not_sufficient`
exhibits a syntactically consistent theory with no model, realized by an empty
world type. Physical consistency is a *semantic certificate*; mathematical
consistency is a *syntactic property*; the gap between them is precisely the gap
between satisfiability and non-contradiction.

The new structural result of the cycle is `completeness_collapse`: for a
falsum-sound, *physically complete* proof system (one whose every consistent
theory has a model), the syntactic and semantic notions become provably
equivalent. This isolates the exact extra hypothesis — physical completeness —
that closes the gap, an abstract shadow of Gödel's completeness theorem and a
precise statement of the "phase boundary" at which logic and physics coincide.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|--------------|
| `consistency_antimono` | proved (no axioms) | Consistency is anti-monotone under extension; foundational for modular theory building |
| `sound_implies_falsum_sound` | proved (no axioms) | Full soundness ⊃ falsum-soundness |
| `physical_implies_mathematical` | proved (no axioms) | Core physics→logic bridge: model + falsum-soundness → consistency |
| `math_consistency_not_sufficient` | proved (no axioms) | Separation: mathematical consistency ↛ physical consistency (empty-world counterexample) |
| `completeness_collapse` | proved (no axioms) | **New:** falsum-soundness + physical completeness ⟹ the two notions coincide |
| `falsum_sound_strictly_weaker` | proved (standard axioms) | The generalization is proper: falsum-soundness ⊊ full soundness |

## Research Directions

### Direction 1: A constructive physical-completeness witness (Lindenbaum/term models)
The collapse theorem `completeness_collapse` is currently *conditional*: it
assumes `PhysicallyComplete ps sem`. The natural next step is to *manufacture*
that hypothesis. **The key insight is** that a Henkin/Lindenbaum-style term model
can be built directly inside our abstract `ProofSystem`: take the worlds to be
maximally consistent extensions of `T`, with `satisfies w φ := φ ∈ w`, so that
"having a model" is literally "extending to a maximal consistent set." Proving
`PhysicallyComplete` for this canonical `sem` would upgrade the collapse theorem
from a conditional to an unconditional equivalence for systems closed under a
modest deduction calculus. *Why now?* We already have `consistency_antimono` and
the `mono`/`assumption` structural rules; the only missing ingredient is a
Zorn's-lemma extension to a maximal consistent set, which Mathlib supports
directly. *If true*, it yields a fully internal completeness theorem; *if false*,
the obstruction will pinpoint exactly which closure rule the abstract
`ProofSystem` is missing.

### Direction 2: Consistency under theory composition with disjoint vocabularies
Define a notion of *disjoint vocabularies* (two sentence sets whose only shared
element is falsum, with no cross-derivations) and ask whether the union of two
consistent theories is consistent. **The key insight is** that Craig
interpolation predicts consistency should compose for non-interacting theories,
formalizing the physical intuition that independent subsystems do not
manufacture contradictions when combined. Concretely: state
`Consistent ps T₁ → Consistent ps T₂ → (vocabulary-disjoint) → Consistent ps (T₁ ∪ T₂)`,
and on the semantic side build a *product world* from the two models. *Why now?*
We have `HasModel`, anti-monotonicity, and the bridge theorems; product
constructions on `Semantics.W` are architecturally clean. *If false*, the
counterexample reveals how shared logical structure (a common falsum) can couple
nominally independent theories.

### Direction 3: A consistency-strength tower via an internal provability predicate
Extend `ProofSystem` with a *provability predicate*: a map `Con : Set S → S`
together with the soundness-style axiom that `T` proves `Con T` iff
`Consistent ps T`. **The key insight is** that Gödel's second incompleteness
theorem makes `Con T` independent of `T` for sufficiently expressive systems, and
a small `proper_extension` lemma (a non-provable sentence yields a strictly
stronger consistent extension) then bootstraps an infinite tower
`T ⊊ T ∪ {Con T} ⊊ T ∪ {Con T, Con (T ∪ {Con T})} ⊊ ⋯`. *Why now?* The
structural extension step is one short lemma away from `consistency_antimono`;
the genuinely hard part — independence of `Con T` — can first be *assumed* as a
hypothesis to get the tower, then discharged in a later cycle via a diagonal
lemma. *If false*, our abstract proof systems are too weak to host Gödelian
self-reference, which is itself a sharp characterization worth recording.

### Direction 4: Computable physical realizability — a third level between syntax and semantics
Specialize `Semantics` to *computable* worlds: require `satisfies` to be
decidable and the witnessing world to be presented effectively. Define
`ComputablyConsistent` and ask for a three-way strict separation
`ComputablyConsistent ⊊ PhysicallyConsistent ⊊ Consistent`. **The key insight is**
that computability inserts an intermediate notion between pure syntax and pure
semantics: a theory may be consistent, even have a model, yet have no *computable*
model — the proof-theoretic analogue of classical-but-not-constructive existence.
*Why now?* Our framework is already parametric over `Semantics.W`; restricting to
`DecidablePred (sem.satisfies w)` is a clean, low-cost specialization, and the
strict separation at the top is exactly `math_consistency_not_sufficient`. *If
false* — i.e. if every model can be made computable for decidable systems — we
obtain a surprising *effective completeness* phenomenon.

### Direction 5: Quantum / multi-world physical consistency under superposition closure
Endow `Semantics.W` with algebraic structure (a lattice or vector space) and
define `QuantumPhysicallyConsistent` to require not a single model but a family of
worlds closed under a *superposition* operation: for any two models `w₁, w₂`
there is a combined model. Prove the strict hierarchy
`QuantumPhysicallyConsistent ⊊ PhysicallyConsistent ⊊ Consistent`. **The key
insight is** that quantum mechanics demands not one realization but a *structured
space* of realizations, and superposition closure is the minimal algebraic
shadow of that demand. *Why now?* `Semantics` already abstracts the world type, so
adding a `[Lattice sem.W]` or `[Module ℝ sem.W]` constraint plus a closure axiom
is a direct extension, and the bridge theorems transfer verbatim to the stronger
notion. *If false*, superposition closure is orthogonal to consistency strength,
suggesting quantum structure constrains *dynamics* rather than *realizability* —
a clean negative result that redirects the program.
