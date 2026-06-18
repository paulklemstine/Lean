# Future Directions — Arrow's Theorem as Curvature of Preference Space

## Synthesis of this cycle

This cycle took the Arrow–curvature programme of `Bridges/ArrowCurvature/Extensions.lean`
— where *Condorcet curvature* of a preference profile was identified with the
directed-3-cycle count of its majority tournament, and flatness was given a
cohomological reading (the majority margin is a coboundary `f b < f a` of an integer
potential exactly when curvature vanishes) — and made the geometry **intrinsic and
quantitative**.

Two new self-contained files were produced.

* `Curvature.lean` develops tournament curvature from scratch (`Tournament` = complete
  asymmetric `beats`; curvature = `cycleCount`, the directed-3-cycle count) and proves
  six theorems, culminating in a **discrete Gauss–Bonnet identity**

  > `cycleCount + 3 · Σ_v C(score v, 2) = 3 · C(n, 3)`.

  Total curvature plus the per-vertex *local* (Copeland-score) energy is a topological
  constant depending only on the number of alternatives. Flatness is exactly the case
  where the local term saturates the global budget. The supporting results are
  `sum_score` (Σ score = C(n,2), the conservation law), the flatness ⇔ zero-curvature
  obstruction theorem, the coboundary/potential characterisation, Copeland-score
  injectivity of flat tournaments, and existence of a Condorcet winner under flatness.

* `Profiles.lean` reconnects this to preference space: with an **odd** electorate the
  pairwise majority relation is a genuine tournament, the Condorcet paradox is exhibited
  with its curvature **computed by `decide`** to equal `3` (a constructive witness that
  preference space is curved, saturating `3·C(3,3) = 3`), and zero curvature is shown to
  force a Condorcet winner.

## Results summary

| Theorem | Statement |
|---|---|
| `Tournament.sum_score` | `Σ_v score v = C(n,2)` |
| `Tournament.isTransitive_iff_cycleCount_zero` | flatness ⇔ zero curvature |
| `Tournament.transitive_iff_has_potential` | flatness ⇔ margin is a coboundary |
| `Tournament.transitive_score_injective` | flat ⇒ Copeland scores are distinct |
| `Tournament.exists_condorcet_winner` | flat ⇒ a Condorcet winner exists |
| `Tournament.gauss_bonnet` | `cycleCount + 3·Σ_v C(score v,2) = 3·C(n,3)` |
| `PreferenceProfile.majorityTournament` | odd-voter majority is a tournament |
| `PreferenceProfile.condorcet_paradox_curved` | the paradox has positive curvature (`decide`) |
| `PreferenceProfile.condorcet_paradox_curvature_eq` | its curvature is exactly `3` |
| `PreferenceProfile.flat_profile_has_condorcet_winner` | zero curvature ⇒ Condorcet winner |

All main results have `sorry = 0` and use only `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — Extremal curvature and the Gauss–Bonnet bound

**Conjecture.** For every tournament on `n` vertices, the (ordered) curvature satisfies
`cycleCount ≤ 3 · ( C(n,3) − n · C((n-1)/2, 2) )` for odd `n`, with equality **iff** the
tournament is *doubly regular* (every vertex has out-degree `(n-1)/2`); for even `n` the
extremiser is near-regular. Equivalently, curvature is maximised exactly when the local
energy `Σ_v C(score v,2)` is minimised, which by convexity happens at the most balanced
score sequence.

The key insight is that the Gauss–Bonnet identity `cycleCount + 3·Σ_v C(score v,2) =
3·C(n,3)` turns a curvature-*maximisation* problem into a local-energy *minimisation*
problem over score sequences constrained by `Σ_v score v = C(n,2)` (`sum_score`), and
`C(·,2)` is convex so the minimiser is the flattest admissible score vector — a pure
consequence of the two conservation laws already proved.

Why now? Both ingredients — the global identity and the score conservation law — are now
formalised, so the extremal statement reduces to a finite convexity/Jensen argument over
integer score sequences rather than any new combinatorial geometry. This is the natural
"isoperimetric" companion to the Gauss–Bonnet theorem and is falsifiable by exhibiting a
single tournament beating the bound.

## Direction 2 — McGarvey realizability: every curvature pattern comes from voters

**Conjecture.** For every tournament `T` on `n` alternatives there is an odd electorate
of at most `n(n-1)` voters and a `PreferenceProfile` whose `majorityTournament` equals
`T`. Consequently every achievable curvature value `cycleCount T` is realised by an actual
preference profile, and the curvature *spectrum* of preference space on `n` alternatives
is exactly the set of tournament 3-cycle counts.

The key insight is that a single ordered pair `(a,b)` can be given a net majority margin
of `+1` by adding two antithetical voters who agree only on `a > b`, so tournaments are
built edge-by-edge; the `majorityTournament` constructor and the `prefer_counts_add`
partition lemma already isolate exactly the counting bookkeeping such a construction
needs.

Why now? `Profiles.lean` makes `majorityTournament` a first-class object with a proven
no-ties (oddness) mechanism, so McGarvey's classical construction can be transcribed
directly and then *composed* with the intrinsic theory — every theorem about
`cycleCount` immediately becomes a theorem about real electorates. Falsifiable: a
tournament provably not arising from any profile would refute it.

## Direction 3 — Higher curvature and a `k`-cycle Gauss–Bonnet hierarchy

**Conjecture.** Define `kCycleCount` as the number of directed `k`-cycles. Then for each
fixed `k` there is a Gauss–Bonnet-type identity expressing `kCycleCount` as a fixed
global term minus a sum of *local* statistics of the score sequence (degree moments), and
a tournament is transitive iff `kCycleCount = 0` for some (equivalently every) `k ≥ 3`.
In particular `3`-cycle-freeness already forces `k`-cycle-freeness for all `k`.

The key insight is that `isTransitive_iff_cycleCount_zero` shows the 3-cycle is the
*complete* obstruction to flatness, so all higher cyclic obstructions must be functionally
dependent on it; the score sequence (which by `transitive_score_injective` is `{0,…,n-1}`
in the flat case) should parametrise the entire `k`-cycle profile.

Why now? The `n=3` identity is proved and its proof is a clean partition of distinct
triples by their unique source vertex; the same "classify by dominant sub-structure"
template generalises to `k`-tuples, and the flat-case score characterisation gives an
exact target to check the general formula against.

## Direction 4 — Expected curvature of random preference profiles

**Conjecture.** Under the impartial-culture model (each of an odd number `m` of voters
draws a uniformly random ranking), the expected normalised curvature of the majority
tournament converges, as `m → ∞`, to that of the uniform random tournament, namely
`E[cycleCount]/(3·C(n,3)) → 1/4`; moreover the probability that preference space is flat
(a Condorcet winner exists) decays and is governed by the same local-energy functional
appearing in Gauss–Bonnet.

The key insight is that Gauss–Bonnet linearises curvature into per-edge and per-vertex
contributions whose expectations are independent indicator computations, so the expected
curvature is computable in closed form without touching the joint distribution of
triangles — the identity does the variance-reduction for free.

Why now? `condorcet_paradox_curvature_eq` shows curvature is an exactly computable finite
statistic, and `gauss_bonnet` plus `sum_score` give the linear functionals whose
expectations are elementary; this makes a fully formal probabilistic Arrow-type
statement tractable rather than asymptotically hand-waved. Falsifiable by simulation
disagreeing with the `1/4` constant.

## Direction 5 — A quantitative (stability) Arrow theorem via curvature

**Conjecture.** There is a constant `c_n > 0` such that any social-welfare function that
is unanimous and independent of irrelevant alternatives, yet not a dictatorship, must
produce a cyclic (positively curved) social outcome on a set of profiles of measure at
least `c_n`; and the minimal such "amount of curvature forced" is monotone in the
distance from dictatorship measured by influence.

The key insight is that classical Arrow is the *qualitative* statement "non-dictatorship
⇒ some curved outcome", whereas the Gauss–Bonnet budget quantifies *how much* curvature a
rule must spend, converting impossibility into a measurable conserved quantity — the same
move that turns Gauss–Bonnet from existence into accounting.

Why now? With curvature defined as a concrete, computable, conserved integer
(`cycleCount`, tied to profiles by `majorityTournament`), the Kalai-style Fourier/stability
program can be phrased entirely against this invariant, and the flat-case Condorcet-winner
theorem `flat_profile_has_condorcet_winner` supplies the exact boundary (`curvature = 0`)
that a quantitative bound must interpolate away from. Falsifiable: a non-dictatorial rule
achieving zero forced curvature would refute it.
