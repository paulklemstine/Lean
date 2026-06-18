# Future Directions: The Geometry of Consensus, Continued

## Synthesis of this cycle

The Arrow–Curvature bridge (`Catalog/Bridges/ArrowCurvature/`) introduced the
*Condorcet curvature* of a preference profile — the count of directed majority
3-cycles — as a discrete analogue of Riemannian curvature, and showed that the
*single point* (a unanimous profile) is flat (`unanimous_curvature_zero`). What
it advertised but did not prove was Black's theorem, the positive counterpart to
Arrow's impossibility.

This cycle closes that gap in `Catalog/Bridges/SinglePeakedFlatness.lean`. The
new results are:

* `single_peaked_never_worst` — single-peakedness implies Sen's *value
  restriction*: the axis-middle alternative of any triple is never ranked last.
* `cross_beats` — a *transfer of decisiveness*: across a never-worst middle,
  a flank that beats the middle by majority also beats the far flank.
* `single_peaked_no_majority_cycle` — no Condorcet cycle on a single-peaked
  profile.
* `single_peaked_curvature_zero` — **Black's theorem, geometric form**: the
  whole single-peaked *submanifold* is flat (`CondorcetCurvature P = 0`),
  strengthening `unanimous_curvature_zero` from a point to a submanifold.
* `single_peaked_majority_transitive` — **Black's theorem, classical form**:
  majority rule is transitive on single-peaked domains with an odd electorate.

The conceptual payoff is a clean dictionary: *value restriction = flatness*, and
*transfer-of-decisiveness = parallel transport with trivial holonomy*. A notable
finding is that acyclicity (the geometric statement) needs **no parity
hypothesis**; oddness enters only to make the tie-broken `majorityTournament`
well-defined.

The directions below are deliberately falsifiable and build on the now-proven
flatness theorems and the existing catalog (`ArrowCurvature`, `BorsukUlamArrow`,
`TopologicalArrowImpossibility`).

## 1. Median-voter Condorcet winner as the center of the flat submanifold

We proved that single-peaked profiles have zero curvature, but we did not yet
exhibit the *Condorcet winner*. Black's full theorem says the median voter's peak
beats every alternative pairwise.

**Testable conjecture.** For a single-peaked profile with an odd number of voters,
let `m*` be the alternative that is the median of the voters' peaks (under the
axis order on `Fin n`). Then `m*` is a Condorcet winner: for every `b ≠ m*`,
`P.majorityBeats m* b`. Equivalently, `m*` is the unique source of the (now known
to be transitive) majority tournament.

**The key insight is** that our `cross_beats` lemma already transfers decisiveness
*outward* from a never-worst middle; iterating it from the median peak should push
decisiveness all the way to the boundary of the axis, pinning the winner at the
median. Flatness guarantees the iteration cannot loop back on itself.

**Why now?** With `single_peaked_majority_transitive` proven, the tournament is a
strict linear order, so a unique maximum exists; the only remaining work is to
*name* it as the median peak, a finite median computation over `Fin k` peaks that
Mathlib's order API supports directly.

## 2. Value restriction is exactly the flat locus (a converse to Black)

Black's theorem is a one-way implication: single-peaked ⟹ flat. Sen's framework
suggests the deeper equivalence is with value restriction, not single-peakedness.

**Testable conjecture.** Define a profile to be *triple-value-restricted* if on
every triple some alternative is never-worst, never-best, or never-middle for all
voters. Then `CondorcetCurvature P = 0` for *every* sub-electorate obtained by
deleting voters in pairs (preserving oddness) **iff** `P` is
triple-value-restricted. Single-peakedness is the special "never-worst-middle"
case; the conjecture is falsifiable by exhibiting a flat profile that is not
value-restricted on some triple and yet becomes cyclic after deleting a voter
pair.

**The key insight is** that `cross_beats` used only the never-worst property of
the middle, never the geometry of the axis — so the real hypothesis powering
flatness is value restriction, and curvature should detect exactly its failure.

**Why now?** Our proof already isolates value restriction as a standalone Lean
predicate (`single_peaked_never_worst` produces it); generalizing the engine to
the never-best and never-middle cases is a symmetric re-run of the same
`Finset.card_le_card` argument.

## 3. Curvature is monotone under domain restriction (a curvature comparison theorem)

Geometrically, restricting to a submanifold can only decrease curvature. The
voting analogue would be a monotonicity law for Condorcet curvature under
shrinking the admissible domain.

**Testable conjecture.** If `D' ⊆ D` are two domains of admissible rankings and
every profile drawn from `D'` is also admissible in `D`, then the maximum
Condorcet curvature over `D'` is ≤ the maximum over `D`. In particular, any
domain sandwiched between a single-peaked domain and the full domain has curvature
that interpolates monotonically. Falsifiable by finding a sub-domain whose worst
profile has strictly more 3-cycles than the worst profile of a larger domain.

**The key insight is** that `CondorcetCurvature` is a cardinality of a filtered
finset of triples, and domain restriction removes profiles without adding triples,
so monotonicity should reduce to `Finset.card_le_card` at the level of
profile-indexed families — the same tactic that powered `cross_beats`.

**Why now?** The curvature is already a `Finset.card`, and `unrestricted_domain_impossible`
(in `Extensions`) shows the full domain is never uniformly flat; a comparison
theorem would organize the whole spectrum between flat (single-peaked) and maximal
(unrestricted) into a single monotone invariant.

## 4. Two-dimensional axes obstruct flatness (a dimension/curvature threshold)

Single-peakedness lives on a one-dimensional axis. Multidimensional preference
models (e.g. peaks in `Fin n × Fin n`) are the standard setting where Condorcet
cycles reappear — the chaos theorems of McKelvey and Schofield.

**Testable conjecture.** There is no analogue of `single_peaked_curvature_zero`
for genuinely two-dimensional single-peaked domains: for every `n ≥ 3` there is a
profile that is single-peaked with respect to *each coordinate axis* of
`Fin n × Fin n` separately, yet has strictly positive Condorcet curvature.
Falsifiable by proving (against expectation) that coordinatewise single-peakedness
forces flatness.

**The key insight is** that our flatness proof crucially used a *total* order on
alternatives to define "the middle"; in two dimensions betweenness is not a total
relation, so the never-worst-middle hypothesis of `cross_beats` cannot be
supplied, and the transfer engine breaks exactly where geometry predicts.

**Why now?** The `Defs` machinery is parametric in the alternative type `Fin n`;
swapping in `Fin n × Fin n` with a product order is a small definitional change,
making the dimension threshold directly testable in the existing framework.

## 5. Flatness as a topological retraction onto the median axis

The catalog's `BorsukUlamArrow` and `TopologicalArrowImpossibility` files frame
social choice topologically. Our flatness result should have a topological face:
on a single-peaked domain, majority aggregation is a *retraction* onto the
one-dimensional axis of peaks.

**Testable conjecture.** The majority-rule social welfare function, restricted to
single-peaked profiles, is idempotent (`F ∘ diag` followed by re-aggregation
returns the same social order) and its image is order-isomorphic to the axis
`Fin n`. Hence it is a deformation retraction of the (contractible) single-peaked
profile space onto the axis — no Borsuk–Ulam obstruction arises, which is *why*
the impossibility of the unrestricted case vanishes. Falsifiable by exhibiting a
single-peaked profile where iterated majority aggregation fails to stabilize.

**The key insight is** that `single_peaked_majority_transitive` makes the majority
output a genuine linear order, so aggregation lands back in the admissible domain;
a transitive image plus a contractible domain is precisely the situation in which
the topological obstruction theorems return "no obstruction".

**Why now?** Both the topological Arrow files and the order-theoretic flatness
results now coexist in the catalog; bridging them turns the qualitative slogan
"single-peaked escapes Arrow" into a precise statement about retractions, the
natural next cross-domain theorem.
