# Future Directions — The Geometry of Consensus: Arrow's Theorem as Curvature

## Synthesis

This cycle treated the **Condorcet curvature** of a preference profile — the directed
3-cycle count of its majority tournament (`CondorcetCurvature`, shown literally equal to
`Tournament.cycleCount` in `Extensions.lean`) — as a discrete Riemannian curvature on the
space of preference profiles. Two complementary results anchor the picture.

1. **The vacuity of "curvature everywhere."** The previously open `arrow_curvature_conjecture`
   in `Defs.lean` carried the global premise `∀ P, 0 < CondorcetCurvature P`. We discharged it
   by exposing that this premise is *self-contradictory*: the constant (unanimous) profile is
   always flat, so no configuration space can be curved everywhere. The honest Arrow obstruction
   therefore lives in the *reachable* configuration space, not in the axioms — exactly the
   distinction `Extensions.unrestricted_domain_impossible` already records, now with the sorry
   closed.

2. **Curvature is a natural invariant.** We proved that `CondorcetCurvature` is invariant under
   the full symmetry group `Sym(k) × Sym(n) × ℤ/2` of the voting configuration space:
   anonymity (`condorcetCurvature_permuteVoters`), neutrality (`condorcetCurvature_relabel`),
   and orientation reversal (`condorcetCurvature_reverseAll`). A Condorcet cycle is an
   *unlabelled* geometric object; its count is therefore a class function on the orbit space.
   This is the precise sense in which curvature is "intrinsic" while a social-welfare function
   (e.g. a dictator) is allowed to break these symmetries.

## Results Summary (all `sorry`-free, axioms = propext / Classical.choice / Quot.sound)

- `arrow_curvature_conjecture` — closed; the unrestricted-domain premise is vacuous.
- `PreferenceProfile.supportCount_permuteVoters / _relabel / _reverseAll` — transformation laws
  for the majority 1-cochain under each group action.
- `condorcetCurvature_permuteVoters` — **anonymity** of curvature.
- `condorcetCurvature_relabel` — **neutrality** of curvature.
- `condorcetCurvature_reverseAll` — **orientation symmetry** of curvature.

These build on and extend the catalog results `curvature_zero_iff_no_majority_cycle`,
`zero_curvature_majority_transitive`, `unanimous_curvature_zero` (Defs) and
`condorcetCurvature_eq_cycleCount`, `Tournament.transitive_iff_has_potential` (Extensions).

## Falsifiable Research Directions

### 1. Curvature is a complete invariant of the symmetry orbit (and only the orbit).
Conjecture: two profiles `P, Q` on the same `(n, k)` have a common value of *every* localized
curvature statistic (the curvature of all alternative-subsets) **iff** they lie in the same
`Sym(k) × Sym(n) × ℤ/2` orbit, for `n ≤ 4`. The key insight is that the invariances proved this
cycle are *necessary*; the open question is whether the refined curvature spectrum is also
*sufficient* to separate orbits. Why now? We have the three invariances in hand, so the
falsifier is concrete and finite: exhibit two non-orbit-equivalent profiles with identical
curvature spectra (a Lean `decide` search over `n = 3, k ≤ 5` either refutes it or yields strong
evidence).

### 2. A quantitative Black's theorem via curvature collapse.
Conjecture: if every voter's ballot is single-peaked on a common axis (`IsSinglePeaked`), then
`CondorcetCurvature P = 0` for all odd `k`, and conversely a *positive* lower bound on curvature
forces a quantified failure of single-peakedness (at least one "value-restriction" triple is
violated). The key insight is that single-peakedness is a discrete *flatness/convexity*
hypothesis, and flatness should kill holonomy exactly. Why now? `Defs.lean` already contains the
`IsSinglePeaked` and `IsSinglePeakedAt` definitions and `zero_curvature_majority_transitive`;
the forward direction is a clean next target, and the converse gives a falsifiable bound.

### 3. McGarvey realizability: every curvature pattern is achievable.
Conjecture: for `n ≥ 3` and all sufficiently large odd `k`, every tournament on `Fin n` (hence
every admissible value of `CondorcetCurvature` between `0` and the max 3-cycle count) is the
majority tournament of some profile. The key insight is McGarvey's classical construction —
pairs of mirror-image voters cancel except on one chosen edge — which lets one *prescribe* the
majority margin sign on every pair independently. Why now? `exists_positive_curvature_profile`
already realizes one curved profile; generalizing from "some cycle" to "any prescribed
tournament" is the natural and highly falsifiable strengthening (a single non-realizable
tournament refutes it).

### 4. A discrete Gauss–Bonnet bound for Condorcet curvature.
Conjecture: the total curvature is bounded by the combinatorics of the alternative set,
`CondorcetCurvature P ≤ (n.choose 3)` with equality exactly for "maximally cyclic" tournaments,
and the parity of the 3-cycle count is determined by the score sequence. The key insight is that
each unordered triple contributes at most one directed 3-cycle, so curvature is a sum of local
`{0,1}` contributions — a discrete integral of a curvature density. Why now? Curvature is now
known to be the tournament cycle count (`condorcetCurvature_eq_cycleCount`), so this becomes a
pure tournament-theory inequality amenable to `Finset.card` bounds.

### 5. Holonomy spectrum and higher cycles as higher curvature.
Conjecture: define `kCycleCount T` for directed `k`-cycles; then transitivity is equivalent to
`kCycleCount T = 0` for *all* `k ≥ 3` simultaneously, and in fact the vanishing of the 3-cycle
count already forces every higher cycle count to vanish (3-cycles generate all holonomy). The
key insight is the discrete Ambrose–Singer phenomenon already isolated in
`tournament_trans_iff_no_3cycle`: the shortest loop controls all loops. Why now? With the
3-cycle theory complete and symmetry-invariant, extending the curvature functional to a graded
"holonomy spectrum" and proving 3-cycles dominate is the structurally cleanest generalization,
and is falsified by any tournament that is 3-cycle-free yet contains a longer directed cycle.
