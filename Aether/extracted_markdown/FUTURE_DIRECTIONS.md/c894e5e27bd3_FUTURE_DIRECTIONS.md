# Future Directions — Vaught's Conjecture / The Vaught Dichotomy

## Synthesis

This cycle attacked Vaught's Conjecture not head-on (it is open) but through its
**topological skeleton**, the structure that every modern proof attempt actually uses:
the *perfect set property* for closed sets in Polish spaces. The decisive structural
insight is that the conjecture's hard content is entirely about **quotienting by
isomorphism** — i.e. counting *orbits* of the logic action of the infinite symmetric
group `S_∞` — whereas the *raw* set of countable models of a theory always sits inside a
Polish space (Cantor space `ℕ → Bool` of atomic facts) as a closed/Borel set, where the
"countable or `2^ℵ₀`" dichotomy is a ZFC theorem. We isolated this boundary precisely:
`vaughtDichotomy_isClosed` (provable) versus `topologicalVaughtConjecture` (open) differ
only by passing from points to orbits.

Two reusable engines emerged. First, `polish_uncountable_mk_eq_continuum` shows that the
two-sided estimate `𝔠 ≤ |α| ≤ 𝔠` collapses to a single equality via the standard-Borel
isomorphism theorem (`measurableEquivNatBoolOfNotCountable`), which is sharper and cleaner
than separately bounding above and below. Second, `continuum_le_mk_of_isClosed_not_countable`
records the *constructive* half: the perfect-set theorem hands us an explicit continuous
injection of Cantor space, so the continuum lower bound is witnessed, not merely counted.
The "gap" reformulation `vaughtDichotomy_no_intermediate` ("no closed set has cardinality
strictly between `ℵ₀` and `𝔠`") turned out to be the most generalization-friendly target,
and it immediately yields the model-count corollary `modelCount_no_intermediate`.

What did *not* work / what we deliberately left open: a ZFC-provable counterexample to the
dichotomy is impossible, because all its failures (an uncountable set of size `< 𝔠`) are
independence phenomena requiring `¬CH`. Instead the Critic's role was satisfied by pinning
down the exact hypothesis that cannot be dropped (`IsClosed`) and by exhibiting
`vaughtDichotomy_countable_witness`, a concrete countable closed set proving the left
branch is non-vacuous. The analytic-set extension (Suslin's theorem, a genuine ZFC result
absent from Mathlib) and the orbit-counting conjecture are the two natural frontiers.

## Results Summary

- `mk_natBool_eq_continuum`: proved — Cantor space `ℕ → Bool` has cardinality exactly `𝔠`; the anchor for every later (in)equality.
- `continuum_le_mk_of_isClosed_not_countable`: proved — constructive perfect-set lower bound: an uncountable closed set in a Polish space embeds Cantor space, so has `≥ 𝔠` points.
- `polish_uncountable_mk_eq_continuum`: proved — every uncountable Polish space has cardinality exactly `𝔠` (sharp two-sided estimate via the standard-Borel isomorphism).
- `vaughtDichotomy_isClosed`: proved (MAIN) — every closed subset of a Polish space is countable or has cardinality `𝔠`; the topological backbone of Vaught's conjecture.
- `vaughtDichotomy_no_intermediate`: proved — gap form: no closed subset has cardinality strictly between `ℵ₀` and `𝔠`.
- `vaughtDichotomy_cantor_univ`: proved — Cantor space realizes the continuum branch; canonical home of countable-structure spaces.
- `vaughtDichotomy_countable_witness`: proved — boundary witness (`{0} ∪ {1/(n+1)}`) showing the countable branch is genuinely realized.
- `mk_models_of_closed_satisfaction`: proved — model-theoretic corollary: a closed model class on a Polish coding space has countably-or-continuum many members.
- `modelCount_no_intermediate`: proved — any cardinal realized as the size of a closed model class avoids the open interval `(ℵ₀, 𝔠)`.
- `topologicalVaughtConjecture`: conjecture (`sorry`) — orbit count of a continuous Polish group action is countable or `𝔠`; with `G = S_∞` this *is* Vaught's conjecture, open.
- `vaughtDichotomy_analytic`: conjecture (`sorry`) — perfect set property for analytic sets (continuous images of Baire space); a ZFC theorem of Suslin not yet in Mathlib.

## Research Directions

### Direction 1: Perfect set property for analytic sets (Suslin)
**Hypothesis**: For Polish `α` and continuous `f : (ℕ → ℕ) → α`, `Set.range f` is countable
or has cardinality `𝔠` (statement `vaughtDichotomy_analytic`).
**Test**: Prove it in Lean by building the Cantor–Bendixson analysis for the Suslin
operation: either formalize that an uncountable analytic set contains a perfect set
(Mathlib has `MeasurableSet.analyticSet` and Cantor schemes — assemble a perfect subtree),
or reduce to `vaughtDichotomy_isClosed` via a closed graph trick.
**Why now**: We already own the closed-set case and the Cantor-scheme injection machinery
(`exists_nat_bool_injection`); analytic sets are the *first* genuinely new layer above
closed sets and the next rung descriptive set theory always climbs.
**If true**: Mathlib gains the perfect set property for analytic sets — a foundational
descriptive-set-theory theorem — and the dichotomy covers all sets that arise as model
classes of first-order *sentences* (which are Borel, hence analytic).
**If false**: Impossible in ZFC for analytic sets; a failed proof would instead reveal a
missing regularity hypothesis, sharpening exactly which definable classes obey the dichotomy.

### Direction 2: From points to orbits — the `S_∞` action
**Hypothesis**: For the logic action of `S_∞` on a closed invariant `X ⊆ ℕ → Bool`, the
orbit equivalence relation is Borel and the number of orbits is countable or `𝔠`
(a special case of `topologicalVaughtConjecture`).
**Test**: Formalize `S_∞` as a Polish group, the logic action, and prove the
orbit-counting dichotomy under the *extra* hypothesis that the orbit equivalence relation
is *smooth* (admits a Borel transversal) — the smooth case is provable and isolates the
hard kernel.
**Why now**: `mk_models_of_closed_satisfaction` already counts raw models; the only missing
ingredient is the quotient, and the smooth case sidesteps the open difficulty while
exercising all needed infrastructure.
**If true**: Vaught's conjecture is reduced, in Lean, to the non-smooth case — exactly the
reduction Becker–Kechris use; the project would host the first formal statement of that
reduction.
**If false**: A counterexample would be a smooth relation with intermediate orbit count,
i.e. a `¬CH` artifact — teaching that smoothness alone is not the right ZFC hypothesis.

### Direction 3: Topological Glimm–Effros dichotomy
**Hypothesis**: A Borel `S_∞`-action either has countably many orbits or contains a copy of
`E_0` (eventual-equality on `2^ℕ`), in which case it has `𝔠` orbits.
**Test**: State `E_0` as a Borel equivalence relation, prove `2^ℕ / E_0` has cardinality
`𝔠`, and show any continuous embedding of `E_0` forces the continuum branch — reusing
`continuum_le_mk_of_isClosed_not_countable`.
**Why now**: Our continuum lower bound is exactly the tool that turns "contains `E_0`" into
"`≥ 𝔠` orbits"; the embedding side is the only new content.
**If true**: Gives the structural *reason* for the dichotomy (a concrete obstruction), far
stronger than the cardinal statement, and is the modern engine behind Vaught's conjecture.
**If false**: Would contradict a known ZFC theorem, so any failure localizes a definability
gap in the formalization of `E_0` rather than a mathematical error.

### Direction 4: Sharpening the cardinality bound to Polish spaces in higher universes
**Hypothesis**: `polish_uncountable_mk_eq_continuum` holds for Polish spaces in any
universe via cardinal lifting, not only `Type 0`.
**Test**: Re-prove the lemma with `Cardinal.lift` inserted at the Cantor-space comparison,
removing the current `Type` (universe-0) restriction inherited from `mk_congr`.
**Why now**: The proof is complete and short; the only obstruction is a universe mismatch
in `mk_congr`, a mechanical `lift` refactor that we now understand precisely.
**If true**: The whole file becomes universe-polymorphic and reusable by downstream
catalog files (e.g. `Logic/PathCardinal.lean`, which lives in the continuum-cardinality
world) without universe friction.
**If false**: A genuine obstruction would expose that "Polish space" implicitly fixes a
universe — a useful piece of metatheory for the catalog's cardinality lemmas.

### Direction 5: Cross-domain bridge — model counts as a cardinal invariant
**Hypothesis**: The map sending a closed model class to its cardinality factors through the
two-point lattice `{≤ℵ₀, 𝔠}`, making "model count mod the Vaught gap" a monoid homomorphism
under disjoint unions and products of theories.
**Test**: Define the quotient invariant, prove `modelCount_no_intermediate` makes it
well-defined, and verify additivity/multiplicativity using `Cardinal` arithmetic
(`𝔠 + 𝔠 = 𝔠`, `𝔠 * 𝔠 = 𝔠`).
**Why now**: `modelCount_no_intermediate` already proves the codomain is exactly two-valued
on closed classes; turning a dichotomy into an *algebraic* invariant is the natural
generalization step and connects logic to the catalog's algebra domain.
**If true**: Yields a compositional calculus of model counts — combine theories and read off
whether the result is countable or continuum without recomputing.
**If false**: A failure of additivity would pinpoint a theory whose model class is closed
but whose union/product escapes closedness, mapping the limits of the closed-set method.
