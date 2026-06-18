# Future Directions — Time-Travel Consistency as a Fixed-Point Theorem

Derived from the research cycle formalized in
`Catalog/Computation/NovikovConsistency.lean` and
`Catalog/Computation/NovikovPolynomial.lean`, where Novikov's self-consistency
principle is realized as the Banach fixed point of a causal *round-trip* map
`T : X → X` (a self-consistent history is exactly a fixed point `T x = x`), with the
topological existence half reusing the catalog's
`brouwer_fixedPoint_Icc_general`.

The cycle established a sharp **existence/uniqueness gap**: existence of a
self-consistent history is *topological* (it holds for any continuous self-map of an
interval, and even pins an interior, irrational golden-ratio history for `x ↦ 1 - x²`),
whereas *uniqueness* is *metric* and fails the moment the loop stops contracting
(`x ↦ x²` carries two consistent histories `0` and `1`). The directions below push on
exactly that gap.

## 1. Quantitative paradox index from the spectral gap `1 - K`

**Conjecture.** Define the *paradox index* of a guessed history `x` as
`P(x) = dist x (T x)` (its one-step inconsistency). Then for a contracting causal map
the realized history is within `P(x)/(1-K)` of consistency, and this bound is *tight*
for affine maps: `dist x x* = P(x)/(1+a)` when `a < 0`.

*The key insight is...* that `novikov_error_bound` already turns "how paradoxical is
this guess?" into a single scalar controlled by the spectral gap `1 - K`, so the gap
itself is a measurable, falsifiable physical observable rather than a metaphor.

*Why now?* `novikov_error_bound` and `affine_contracting` are proved; the tightness
claim is a finite affine computation (`field_simp`/`nlinarith`) that the current file
is one lemma away from.

## 2. Bifurcation of consistent histories at the contraction boundary `K = 1`

**Conjecture.** Parameterize causal maps by gain `r` (e.g. logistic `r·x·(1-x)`). The
number of self-consistent histories in `[0,1]` is `1` for `r ≤ 1` and `≥ 2` for
`r > 1`, with the new branch born exactly at the loss of contraction (`K → 1`).

*The key insight is...* that `logistic_carrying_capacity_consistent` exhibits the
second (nonzero) history `1 - 1/r` appearing precisely as `r` crosses `1`, mirroring a
transcritical bifurcation — uniqueness is destroyed at the same threshold where
contraction is lost.

*Why now?* The two logistic histories (`0` and `1 - 1/r`) are already formalized; what
remains is to prove there are *exactly* these for `r ∈ (1,3]`, a real-root-counting
argument within reach of `polyrith`/`nlinarith`.

## 3. Multidimensional Novikov: consistent field histories on `ℝⁿ`

**Conjecture.** For a causal map `T : ℝⁿ → ℝⁿ` that is `K`-Lipschitz with `K < 1` in
the Euclidean metric (e.g. an affine map `x ↦ A x + b` with `‖A‖ < 1`), there is a
unique self-consistent field history, given by `(I - A)⁻¹ b`.

*The key insight is...* that the abstract `novikov_unique_consistent` is already stated
over an arbitrary complete metric space, so the entire content is the spectral
criterion `‖A‖ < 1 ⟹ ContractingWith ‖A‖ (A·+b)` — a matrix-norm lemma, not new
fixed-point theory.

*Why now?* `novikov_unique_consistent` is domain-agnostic and proved; Mathlib's
operator-norm API (`ContinuousLinearMap.opNorm`) makes the `ℝⁿ` instantiation a
self-contained next step.

## 4. Necessity is generic: most degree-≥2 causal maps break uniqueness

**Conjecture.** A real polynomial causal map of degree `d ≥ 2` whose leading
coefficient is positive has at least two real fixed points (hence is never a
contraction on all of `ℝ`) for an open, dense set of coefficient vectors.

*The key insight is...* that `square_no_contraction` is not an isolated pathology: the
fixed-point equation `p(x) = x` is itself a degree-`d` polynomial, so generically it
has multiple real roots, making the failure of Novikov uniqueness the *typical* case
for nonlinear causal maps.

*Why now?* `square_no_contraction` gives the d=2 witness and the proof template
(two fixed points ⇒ no contraction, via `fixedPoint_unique'`); generalizing needs only
a root-existence count for `p(x) - x`.

## 5. Approximate Novikov: ε-consistent histories always exist on compacta

**Conjecture.** Even when no exact contraction holds, every continuous causal map on a
compact state space admits, for each `ε > 0`, an *ε-self-consistent* history with
`dist (T x) x ≤ ε`; and if the space is additionally convex these upgrade to an exact
consistent history.

*The key insight is...* that the catalog already contains the compactness upgrade
principle (`exists_fixedPoint_of_approx_fixedPoint_compactness`), so approximate
self-consistency — the physically realistic notion under measurement error — is the
right weakening that survives the loss of contraction.

*Why now?* `novikov_exists_interval` connects this file to the catalog's fixed-point
core; wiring in the compactness-upgrade lemma extends Novikov existence from intervals
to arbitrary compact convex history spaces with no new heavy machinery.
