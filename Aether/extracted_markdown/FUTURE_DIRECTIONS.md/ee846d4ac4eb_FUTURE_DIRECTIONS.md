# Future Directions — The Geometry of Consensus

Derived from this cycle's verified Lean results in
`Combinatorics/ArrowCurvature.lean`, `Combinatorics/ArrowImpossibilityBridge.lean`,
and `Combinatorics/ConsensusFlat.lean`.

This cycle established, with machine-checked proofs, a discrete dictionary:

- **Condorcet winner = consensus = flat fixed point** of majority rule.
- **Rotation invariance of the majority tournament = nonzero holonomy = positive
  curvature**, and we proved it forces a Condorcet cycle (no consensus) by
  reduction to the *free* `ZMod 3` action (`zmod_add_free`) from the catalog's
  impossibility theory.
- **A shared top choice held by a strict majority = zero curvature**, and we
  proved it makes majority rule converge to that choice
  (`consensusMajorityWinner`).

The conjectures below extend this dictionary.

---

## Conjecture 1 — Rotational symmetry of any social-welfare function forces a cycle on `ZMod m`.

For `m ≥ 3`, any tournament on `ZMod m` invariant under the full cyclic rotation
group has no Condorcet winner, and in fact its "score sequence" is constant.

**The key insight is** that a Condorcet winner is a fixed point of the symmetry
group, so a *transitive* (i.e. free, fixed-point-free) symmetry of the majority
relation is an exact obstruction to consensus — the same obstruction
`zmod_add_free` provides for `m = 3`, now conjectured for all `m`.

**Why now?** We have already isolated the freeness mechanism for `m = 3` and
routed it through the catalog's `zmod_add_free`, which is stated for arbitrary
`n`. Generalizing `rotInvariant_no_winner` from `ZMod 3` to `ZMod m` is a direct
next step that only needs uniqueness-of-winner plus the existing freeness lemma.

---

## Conjecture 2 — Curvature is exactly value restriction (a sharp dichotomy).

A profile over 3 alternatives yields an acyclic majority tournament **iff** it is
value-restricted (some alternative is never ranked last by anyone, or never
first, or never middle). Equivalently: *curvature is zero iff the electorate has
a shared structural agreement*, and positive otherwise.

**The key insight is** that the only obstruction to flatness is the cyclic
(rotation-symmetric) configuration we exhibited as `cyclicProfile`; every
non-cyclic value-restricted profile collapses the holonomy to the identity and
admits a winner, exactly as `consensusMajorityWinner` does for a shared peak.

**Why now?** We have both endpoints in Lean — a concrete curved profile
(`cyclic_no_majority_winner`) and a concrete flat sufficient condition
(`consensusMajorityWinner`). The dichotomy is the statement that these two
regimes are *exhaustive* for 3 alternatives, which is Sen's value-restriction
theorem recast geometrically and is now within formalization reach.

---

## Conjecture 3 — Dictatorship is the unique nonzero-curvature-preserving map.

Among social-welfare functions that are local (IIA), forward-looking (Pareto),
and defined on the full (positively curved) domain, the only ones whose induced
tournament is *always* acyclic are the projections onto a single voter
(dictatorships).

**The key insight is** that demanding acyclicity on a positively curved domain
is demanding a global flat section of a bundle with nonzero holonomy, and the
only such sections are the constant projections — the discrete analogue of "flat
sections exist only along the fibers of a projection."

**Why now?** Our framework already encodes IIA-locality (the tournament depends
only on pairwise data), Pareto (unanimity ⇒ majority, a special case of
`consensusMajorityWinner`), and curvature (rotation invariance). Combining them
with the catalog's `no_equivariant_orbit_section` is a concrete path to a
fully formal Arrow's theorem expressed entirely in curvature language.

---

## Conjecture 4 — A quantitative "polarization = curvature" inequality.

Define the *holonomy defect* of a profile as the number of distinct 3-cycles in
its majority tournament. Then the holonomy defect is monotone in a polarization
statistic (e.g. the variance of voters' top choices across the cyclic axis):
more bimodal electorates have strictly more cycles.

**The key insight is** that each 3-cycle is a loop around which parallel
transport fails to close, so counting cycles counts curvature quanta — turning
the qualitative "polarized ⇒ curved" slogan into a measurable inequality.

**Why now?** `cyclic_majority_succ` gives the maximal-curvature endpoint (one
full cycle from a perfectly bimodal/rotational profile) and
`consensusMajorityWinner` gives the zero-curvature endpoint. Interpolating with a
counting functional is the natural quantitative bridge, and all the ingredients
(finite ballots, decidable cycle counting) are already in place.
