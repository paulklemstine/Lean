# FUTURE_DIRECTIONS — Hilbert 6: Axiomatization of Physics (Probability layer)

## Synthesis

This cycle extends the existing axiomatic Kolmogorov core
(`Catalog/Physics/KolmogorovAxioms.lean`, providing the finitely-additive
`KolmogorovSpace` structure and its derived calculus: `prob_compl`,
`prob_mono`, `prob_modular`, `prob_union_le`, `prob_biUnion_le`) in two
complementary directions, each a separate Lean file built *only* from the three
finite-additivity axioms K1–K3 — no measure theory.

The first direction (`KolmogorovConditional.lean`) builds the **inferential**
layer of Hilbert's sixth problem: conditional probability, the multiplication
rule, the law of total probability, Bayes' theorem, and the algebra of
stochastic independence (including stability under complementation and the
"conditioning is inert under independence" law). The structural insight is that
the entire Bayesian update calculus is *purely algebraic* over K1–K3 once one
adds the single division operation defining `cond`; the only nondegeneracy ever
needed is `P B ≠ 0`.

The second direction (`KolmogorovBellMetric.lean`) is the cycle's headline
**cross-domain bridge** (classical probability ↔ quantum foundations). We
isolate the symmetric-difference pseudometric `d(A,B) = P(A △ B)` on the Boolean
algebra of events and prove it satisfies the metric axioms. The decisive
observation is that the *triangle inequality of this classical pseudometric is
itself a Bell inequality*: it, and the equivalent one-sided form
`P(A∩Cᶜ) ≤ P(A∩Bᶜ) + P(B∩Cᶜ)` (Bell 1964), are constraints every classical
(local hidden-variable) assignment must satisfy and that entangled quantum
states violate. What failed/needed care: the three symmetric differences are not
disjoint, so a direct additive decomposition is impossible — the working route is
the Boolean inclusion `A△C ⊆ (A△B)∪(B△C)` followed by monotonicity and
two-event subadditivity, both inherited from the base file. This reframes the
classical/quantum boundary as a *measurable metric defect*.

## Results Summary

- `KolmogorovSpace.total_prob`: proved — law of total probability for the partition `{B, Bᶜ}`, the atom of marginalization.
- `KolmogorovSpace.cond_mul`: proved — multiplication rule `P(A|B)·P(B) = P(A∩B)`, the definitional core of conditioning.
- `KolmogorovSpace.bayes`: proved — Bayes' theorem in symmetric multiplicative form, the engine of constructive Bayesian inference.
- `KolmogorovSpace.indep_compl_right`: proved — independence is stable under negating the conditioning event.
- `KolmogorovSpace.indep_comm`: proved — independence is symmetric.
- `KolmogorovSpace.indep_cond`: proved — conditioning on an independent event is inert (`P(A|B)=P A`).
- `KolmogorovSpace.eventDist_self`: proved — the event pseudometric vanishes on the diagonal.
- `KolmogorovSpace.eventDist_comm`: proved — the event pseudometric is symmetric.
- `KolmogorovSpace.eventDist_nonneg`: proved — nonnegativity (axiom K1).
- `KolmogorovSpace.eventDist_triangle`: proved — triangle inequality = Bell inequality (symmetric-difference form).
- `KolmogorovSpace.bell_chain`: proved — symmetric three-term Bell/CHSH chain bound.
- `KolmogorovSpace.bell_inequality`: proved — Bell's 1964 inequality in event/probability form.

## Research Directions

### Direction 1: Tsirelson-style quantitative violation gap
**Hypothesis**: Define, over a fixed `KolmogorovSpace`, the Bell defect
`δ(A,B,C) = eventDist A C - (eventDist A B + eventDist B C)`. Then for every
classical `KolmogorovSpace`, `δ ≤ 0` (already proved), and there exists an
abstract "quantum valuation" relaxing K3 (additivity replaced by a Cauchy–Schwarz
bound) for which `δ` can reach but not exceed a fixed positive bound `2(√2 − 1)`
times a normalization.
**Test**: Formalize a `QuasiKolmogorovSpace` weakening `additive` to subadditive
plus an inner-product correlation, and prove the sharp positive upper bound on
`δ`; disprove by exhibiting a state exceeding it.
**Why now**: The triangle inequality proof already localizes *exactly* the axiom
used (additivity via `prob_union_le`), so the minimal weakening that breaks it is
explicit.
**If true**: A purely order-theoretic, measure-free statement of Tsirelson's
bound inside the catalog.
**If false**: It pinpoints that nonclassicality needs more than relaxing
additivity (e.g. genuine noncommutativity).

### Direction 2: The event pseudometric as a genuine `PseudoMetricSpace`
**Hypothesis**: `eventDist` upgrades to a Mathlib `PseudoMetricSpace` instance on
the quotient of `Set Ω` by `P(A△B)=0`, yielding a genuine `MetricSpace` of
"events modulo null sets" with completeness for σ-additive `K`.
**Test**: Provide the instance using `eventDist_self`, `eventDist_comm`,
`eventDist_triangle`, `eventDist_nonneg`; quotient by the null relation; connect
to `MeasureTheory.MeasureSpace` for the σ-additive case.
**Why now**: All four pseudometric axioms are now proved; only the quotient
plumbing remains.
**If true**: Bridges the finitely-additive axiomatic layer to Mathlib's
measure-theoretic stack, letting later cycles import topology for free.
**If false** (e.g. triangle fails on the quotient): reveals a hidden
non-additivity obstruction worth isolating.

### Direction 3: n-event inclusion–exclusion and Bonferroni hierarchy
**Hypothesis**: `prob_modular` generalizes to full inclusion–exclusion
`P(⋃ Aᵢ) = Σ(-1)^{|S|+1} P(⋂_{i∈S} Aᵢ)`, with the Bonferroni truncations giving
alternating upper/lower bounds that refine `prob_biUnion_le`.
**Test**: Prove by `Finset` induction, using `prob_modular` as the two-set step;
verify Bonferroni truncation sign via parity induction.
**Why now**: `prob_modular` and `prob_biUnion_le` already supply the base and the
crude bound; only the alternating bookkeeping is missing.
**If true**: Completes the elementary finite probability calculus axiomatically.
**If false**: would expose that finite additivity alone is too weak for signed
sums (it is not — so failure would signal a formalization bug, itself instructive).

### Direction 4: Conditional independence and the chain rule
**Hypothesis**: Define `CondIndep K A B C` via `cond (A∩B) C = cond A C · cond B C`
and prove the graphoid axioms (symmetry, decomposition, weak union, contraction)
hold for `KolmogorovSpace` with the relevant denominators nonzero.
**Test**: Prove each graphoid axiom from `cond_mul`, `bayes`, and `total_prob`;
disprove the converse (intersection) axiom by an explicit `diracSpace`-based
counterexample.
**Why now**: `cond_mul`, `bayes`, and `indep_*` give the full conditioning
algebra needed to even state the graphoid laws.
**If true**: A foundational, measure-free account of Bayesian-network semantics.
**If false**: identifies which graphoid axiom genuinely needs σ-additivity or
regular conditional probabilities.

### Direction 5: Topos/locale valuation correspondence
**Hypothesis**: Every `KolmogorovSpace` is exactly a normalized lattice
*valuation* on the Boolean algebra `Set Ω` (a map satisfying the modular law and
monotonicity), and conversely every monotone normalized modular functional with
`v ∅ = 0` is a `KolmogorovSpace`; this is the precise bridge to topos-theoretic
(internal-locale) probability.
**Test**: State and prove the round-trip equivalence
`KolmogorovSpace Ω ≃ {v : Set Ω → ℝ // valuation laws}` using `prob_modular`
(forward) and reconstructing `additive` from modularity + `v ∅ = 0` (backward).
**Why now**: `prob_modular` already shows one direction; the catalog explicitly
flags this modular law as "the bridge to topos-theoretic valuations".
**If true**: Realizes the topos-physics half of Hilbert 6 as a clean
type-equivalence, connecting to the catalog's locale/sheaf machinery.
**If false**: shows finite additivity is strictly stronger than modularity (it is
not for two-valued cases, so failure would localize where Boolean structure is
essential).
