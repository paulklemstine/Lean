# Future Directions — The Geometry of Consensus

## Synthesis

We set out to test the bold conjecture that **Arrow's impossibility theorem is a
curvature statement**, and to extract from it something a machine can actually
verify. The decisive reframing was to identify *curvature* with the **failure of
transitivity** of the social relation, and *holonomy* with a **directed 3-cycle**
(the Condorcet cycle). Under this dictionary, parallel transport around the loop
`a → b → c → a` "rotates" the social preference exactly when majority rule produces a
Condorcet cycle.

With this lens, `ConsensusGeometry.lean` proves both poles of Arrow's dichotomy as a
single geometric phenomenon:

- **Curvature is real (`positive_curvature_m3`).** With three alternatives the
  pairwise–majority tournament carries a genuine directed 3-cycle. The democratic map
  has nonzero holonomy: the preference space is "sphere-like."
- **Projections are flat (`dictator_acyclic`).** A dictatorship — the projection onto
  one voter — inherits that voter's transitive strict order, hence is holonomy-free
  for *every* number of alternatives.
- **Low dimension is flat (`flat_curvature_m2`).** Two alternatives admit no 3-cycle
  at all (the May / median-voter regime).
- **Consensus is flat (`consensus_no_holonomy`).** A unimodal electorate (everyone
  shares one ranking) kills the cycle: polarization curves the space, consensus
  flattens it.
- **Majority is still forward-looking (`majority_pareto`).** Majority satisfies the
  Pareto / "forward-looking" axiom; its *only* defect is the holonomy of Theorem 1.

## Results Summary

| Theorem | Geometric content |
|---|---|
| `noCycle3_of_trans_irrefl` | transitive + irreflexive ⇒ zero holonomy (flat) |
| `positive_curvature_m3` | majority develops a 3-cycle at `m = 3` (positive curvature) |
| `flat_curvature_m2` | no 3-cycle at `m = 2` (flat) |
| `dictator_acyclic` | projections are flat on every `m` |
| `consensus_no_holonomy` | unimodal electorate ⇒ flat |
| `majority_pareto` | majority is forward-looking |
| `beats_asymm` | the majority relation is a tournament |

All proofs are `sorry`-free and the Condorcet witness is certified by `decide`.

---

## Direction 1 — Holonomy quantization: a discrete Gauss–Bonnet for tournaments

**Conjecture.** Define the *holonomy number* `h(P)` of a profile as the number of
directed 3-cycles in its majority tournament. Then `h(P)` is constrained by a
Gauss–Bonnet–type identity: for the complete tournament on `m` alternatives,
`h(P) = C(m,3) - Σ_a C(s_a, 2)`, where `s_a` is the number of alternatives that `a`
beats (its "score"). In particular `h(P) = 0` iff the tournament is transitive
(flat), and `h(P)` is maximized by rotation-symmetric (maximally polarized) profiles.

*The key insight is* that total curvature is not a soft analogy but a **counting
identity**: summing the local "score defects" `C(s_a,2)` over all vertices recovers the
global cycle count, exactly as integrating local curvature recovers a topological
invariant.

*Why now?* We already have `beats` as a decidable tournament and `Cycle3` as the unit
of holonomy; the score function and the binomial bookkeeping are immediately
expressible, and the identity is a finite, fully decidable target reachable by
induction on `m` plus `decide` base cases — a natural next theorem.

## Direction 2 — May's theorem as the flat (`m = 2`) classification

**Conjecture.** On the flat space (`m = 2`), simple majority is the *unique* social
welfare function that is anonymous, neutral, and monotone (May's theorem). Equivalently:
flatness forces a unique geodesic "straight-line" aggregator, whereas curvature
(`m ≥ 3`) destroys uniqueness.

*The key insight is* that `flat_curvature_m2` is the obstruction-free half of a
classification: where there is no holonomy, the aggregator is pinned down, so Arrow's
*impossibility* and May's *possibility* are the `m ≥ 3` and `m = 2` faces of one
curvature trichotomy.

*Why now?* `flat_curvature_m2` already isolates the flat regime; anonymity (invariance
under permuting voters) and monotonicity are one-line predicates over the existing
`Profile`/`beats` API, making the uniqueness statement a self-contained finite proof.

## Direction 3 — Arrow proper via decisive coalitions = parallel-transport groups

**Conjecture.** A social welfare function that is forward-looking (`majority_pareto`-style
Pareto) and local (IIA) must, on the curved space `m ≥ 3`, concentrate all decisiveness
on a single voter (dictator). The set of *decisive coalitions* forms an **ultrafilter**,
and the ultrafilter is exactly the structure group of allowed parallel transports: a
principal (fixed) ultrafilter ⇔ a projection ⇔ zero holonomy.

*The key insight is* that the classical "field expansion / contagion" lemmas of Arrow's
proof are precisely the statement that *holonomy must be transported consistently around
every loop*, which on a finite voter set forces the decisive family to be a principal
ultrafilter (a single voter).

*Why now?* `dictator_acyclic` already shows projections are the flat survivors;
formalizing decisive coalitions as a `Filter` on `Fin n` and proving the upset/field-
expansion lemmas turns the dichotomy we proved into the full uniqueness theorem, with
Mathlib's `Ultrafilter` API doing the algebraic heavy lifting.

## Direction 4 — Polarization → curvature: a measured connection

**Conjecture.** Equip profiles with a polarization scalar `π(P)` (e.g. the variance of
the rank a fixed alternative receives, or the distance from the unanimous profile).
Then holonomy is *monotone* in polarization on average: bimodal/polarized profiles
maximize `h(P)` while unimodal/consensus profiles achieve `h(P) = 0`
(`consensus_no_holonomy` is the boundary case `π = 0`).

*The key insight is* that the conjectured "curvature = polarization" link becomes a
**provable monotonicity** once both sides are finite functionals: the curvature side is
the cycle count of Direction 1, the polarization side is an explicit dispersion
statistic, and consensus is their common zero.

*Why now?* `consensus_no_holonomy` already nails the `π = 0` endpoint; defining `π` over
the existing `Voter`/`Profile` types and checking the monotone trend on enumerated
small profiles via `decide` gives immediate, falsifiable experimental traction.

## Direction 5 — Continuous lift: from tournaments to a genuine Fisher metric

**Conjecture.** Replace `ℕ`-valued utilities by points of the open simplex `Δ^{m-1}`
with the Fisher information metric. Then the discrete invariants above are the leading
terms of genuine Riemannian data: the Condorcet 3-cycle is the lowest-order holonomy of
the Levi-Civita connection on `(Δ^{m-1})ⁿ`, and the sign of the sectional curvature
along the "majority direction" matches the sign of the discrete holonomy number `h(P)`.

*The key insight is* that the finite combinatorics we proved are not a toy but the
**`0`-jet** of the Riemannian story: a smooth aggregator's holonomy, expanded around a
profile, must reproduce the tournament cycle structure to lowest order.

*Why now?* Mathlib's growing differential-geometry library (manifolds, connections,
inner-product structure) finally makes the smooth side tractable; anchoring it to the
already-verified discrete theorems gives a rigorous ladder from combinatorics to
curvature rather than a leap of faith.
