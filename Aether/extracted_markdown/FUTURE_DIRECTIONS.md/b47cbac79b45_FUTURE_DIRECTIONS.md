# Future Directions: The Soundness–Consistency Frontier

The module `Catalog/Logic/ConsistencyFramework.lean` builds a minimal,
semantics-agnostic framework for propositional theories — a `Theory` is just a
type of sentences, a negation map, and a provability predicate — and proves a
sharp picture of how three properties relate:

* `Theory.sound_imp_consistent`: soundness implies consistency, for *every*
  theory (depends only on `propext`).
* `Theory.consistent_complete_imp_sound`: the converse holds for
  negation-complete theories via the canonical model `val := Provable` (an
  abstract Lindenbaum/Henkin construction, axiom-free).
* `pathologicalTheory_consistent` / `pathologicalTheory_not_sound`: a consistent
  theory that is **not** sound — the separator is exactly the theory where
  negation is the identity, and it fails negation-completeness
  (`pathologicalTheory_not_negComplete`).
* `consistent_imp_sound_extension`: the headline strengthening — if negation is
  an involution **without fixed points**, every consistent theory extends to a
  consistent, negation-complete, and *sound* theory on the same sentences. The
  fixed point of negation is therefore the *only* obstruction to upgrading
  consistency to soundness.
* `Interpretation.relativeConsistency` together with `Interpretation.id` /
  `Interpretation.comp`: negation-respecting interpretations transfer
  consistency backwards and form a preorder on theories.

The following conjectures extend this frontier. Each is stated so that it could
be added to the framework as a new `theorem` and discharged (or refuted) by
direct construction inside the existing `Theory` abstraction.

## 1. The exact obstruction: a fixed-point/orbit dichotomy for completeness

We proved that *involutive, fixed-point-free* negation lets consistency imply
soundness, and that the identity negation (every sentence is its own negation)
blocks it. Conjecture: for an arbitrary negation map `neg`, a consistent theory
can be extended to a sound one **iff** no provable-forced "bad orbit" of `neg`
exists — precisely, iff for every `φ` the orbit `{φ, neg φ, neg (neg φ), …}`
admits a 2-coloring with `neg φ` always the opposite color of `φ`, which is
exactly the condition that `neg` has no odd cycle and no fixed point on the
provability-relevant sentences.

**The key insight is** that `consistent_imp_sound_extension` only used
involutivity to guarantee each negation-pair `{φ, neg φ}` is a genuine
2-element set selectable by the well-ordering `WellOrderingRel`; replacing
"involution without fixed points" by "the functional graph of `neg` is
bipartite" should be both necessary and sufficient, turning a sufficient
condition into a characterization.

**Why now?** The selector construction in `consistent_imp_sound_extension`
already isolates the combinatorial core (choosing one member of each pair). The
generalization is a graph-2-coloring statement over `neg`, and Mathlib's
`SimpleGraph` bipartiteness and `WellOrderingRel` machinery provide exactly the
tools to phrase and prove the dichotomy without leaving the current abstraction.

## 2. Well-foundedness of the interpretability preorder on a natural subclass

`Interpretation.relativeConsistency`, `Interpretation.id`, and
`Interpretation.comp` make theories into a preorder under interpretability. The
empirical observation that natural theories are *linearly and well-ordered* by
consistency strength suggests a formal counterpart.

**The key insight is** that one can attach to each theory `T` in a suitable
subclass an ordinal rank (a proof-theoretic ordinal surrogate) such that an
interpretation `T → S` forces `rank T ≤ rank S`; well-foundedness of `Ordinal`
then immediately yields well-foundedness of the strict interpretability order on
that subclass.

**Why now?** The `Interpretation` structure already gives the order-preserving
map; the only missing ingredient is a monotone `rank : Theory → Ordinal` on a
restricted class, and Mathlib's `Ordinal` arithmetic and well-foundedness
(`Ordinal.lt_wf`) are fully available to host the conclusion.

## 3. Spectral models: a non-commutative soundness/consistency split

Our `Model` replaces truth by a Prop-valued valuation `val` inverting negation.
Replacing `val : Sentence → Prop` by a projection in a C*-algebra (truth =
spectral membership of a self-adjoint element, negation = `1 - p`) gives a
non-commutative semantics.

**The key insight is** that `sound_imp_consistent` survives verbatim — a
projection `p` and its complement `1 - p` cannot both dominate the same provable
element — but the converse fails *more richly* than in the classical case:
non-commuting projections create consistent theories with no commutative
(classical) model, a strictly larger counterexample space than
`pathologicalTheory`.

**Why now?** The `Model` structure was deliberately built around a single
negation-inverting valuation, so swapping `Prop` for projections in a
`CStarAlgebra` is a local change; Mathlib's `Analysis.CStarAlgebra` and
`ContinuousFunctionalCalculus` give projections and spectra to make "spectral
membership" precise.

## 4. Computable interpretations and the complexity of the translation image

`Interpretation.translate` is an arbitrary function. Real interpretations between
arithmetic theories are computable, and the *image* of a translation is a
decision problem.

**The key insight is** that restricting to `translate` with a `Computable`
witness refines `relativeConsistency` into an *effective* relative-consistency
statement, and the complexity of deciding membership in `range translate`
stratifies the interpretability preorder by computational hardness — a refinement
invisible to the purely logical order.

**Why now?** Lean 4's `Computable` / `Primrec` hierarchy lets us add a
computability field to `Interpretation` without changing its logical content, so
the effective version of `relativeConsistency` is a conservative extension of the
present proof plus a decidability obligation on the image.

## 5. Physical realizability between consistency and soundness

`pathologicalTheory` shows consistency is strictly weaker than soundness. Adding a
*computability predicate on models* (a model is "physically realizable" if its
valuation is decidable) carves out an intermediate notion.

**The key insight is** that "has a decidable model" sits strictly between
"consistent" and "sound": `consistent_imp_sound_extension` produces a model from
a non-constructive well-ordering, so the sound theory it builds need not be
*decidably* sound — yielding a Tennenbaum-style gap where extensions preserve
soundness but destroy physical realizability.

**Why now?** The canonical model in `consistent_complete_imp_sound` is literally
`val := Provable`, so realizability becomes exactly decidability of `Provable`;
adding a `DecidablePred` field to `Model` turns the gap into a precise, checkable
hierarchy directly atop the current definitions.
