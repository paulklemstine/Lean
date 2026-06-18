# Future Directions: The Probabilistic Method, Made Honest

The new file `RamseyLowerBound.lean` replaces the catalog's placeholder Ramsey
statements (`ProbabilisticMethod.erdos_ramsey_counting`, whose conclusion was the
vacuous `∃ i : Fin (2 ^ n.choose 2), True`, and `constructive_ramsey_conjecture`)
with theorems whose conclusions carry genuine combinatorial content:

* `erdos_ramsey_exists` — if `2 * (n choose k) < 2 ^ (k choose 2)` then **there
  is an explicit 2-coloring of the edges of `K_n` with no monochromatic `K_k`**.
* `ramsey_lower_bound` — the same witness avoids both a red and a blue `K_k`,
  i.e. `R(k,k) > n`.
* `erdos_ramsey_asymmetric` — the off-diagonal strengthening: under the
  cleared-denominator hypothesis `C(n,s)·2^(E-C(s,2)) + C(n,t)·2^(E-C(t,2)) < 2^E`
  there is a coloring with no red `K_s` and no blue `K_t`, i.e. `R(s,t) > n`.
* `mono_clique_k2` — the sharp boundary: for `k = 2` every coloring is bad, so
  some hypothesis on `n, k` is genuinely necessary.

These are built on the catalog's first-moment philosophy
(`Speculative/ProbabilisticMethod/Core.lean`: `first_moment_principle`,
`union_bound_existence`, `weighted_pigeonhole`) but instantiated with the actual
clique-counting cardinalities (`edge_card`, `coloring_card`, `inside_card`,
`card_monoOn_le`, `card_constOn_le`). The following directions extend this base.

## Direction 1: A Ramsey *number* object and the bound `R(k,k) > ⌊2^(k/2)⌋`

Define `ramseyNumber k := sInf {n | every 2-coloring of K_n has a mono K_k}` (or
the Fin-indexed analogue) and prove `erdos_ramsey_exists` implies the closed-form
inequality `R(k,k) > 2 ^ (k/2)` by discharging the arithmetic
`2 * (m choose k) < 2 ^ (k choose 2)` at `m = ⌊2^(k/2)⌋` for all `k ≥ 3`.

The key insight is that the arithmetic inequality, not the combinatorics, is the
only remaining obstacle: `card_monoOn_le` already supplies the combinatorial
core, so the closed form reduces to a single `Nat`/real estimate
`(m choose k) ≤ m^k / k!` combined with `k! ≥ 2^(k-1)`.

Why now? The combinatorial existence theorem is finished and axiom-clean, and
Mathlib has no general diagonal Ramsey lower bound, so the closed form is the
natural and immediately reachable next milestone.

## Direction 2: Derandomization by conditional expectations (constructive Ramsey)

Replace the counting existence proof with an explicit greedy algorithm: color the
edges one at a time, each time choosing the color that keeps the conditional
expected number of monochromatic `K_k` below `1`. Formalize the invariant
`condExp (partial coloring) < 1` and prove it is preserved, yielding a
*computable* good coloring rather than a mere existence statement.

The key insight is that the first-moment bound `card_monoOn_le` is exactly the
`condExp` of the empty partial coloring, so the algorithm is just maintaining
the inequality the existence proof establishes once — Erdős's existence proof is
literally an algorithm with the loop unrolled.

Why now? `erdos_ramsey_exists` already proves the base inequality; turning the
union bound into a step-by-step invariant is a refactor of an in-hand proof, and
it directly tests the concept's headline claim that "the probabilistic method is
constructive."

## Direction 3: Property B and the symmetric Lovász Local Lemma

Generalize from cliques to `k`-uniform hypergraphs (cf.
`ProbabilisticMethod.Advanced.property_B_bound`) and prove the symmetric LLL in
its combinatorial-counting form: if each bad event touches at most `d` others and
`e · p · (d+1) ≤ 1`, a simultaneous avoidance exists. Formalize the
Moser–Tardos resampling process as a `Nat`-indexed state machine and bound its
expected step count, giving a constructive LLL.

The key insight is that the dependency structure can be encoded as a finite graph
on the events and the LLL inequality as a fixed-point of the per-event "escape
probability" recurrence `x_i ≥ p_i ∏_{j∼i}(1 - x_j)`, so the whole statement
becomes a finite system of `Nat`/rational inequalities amenable to the same
union-bound machinery used here.

Why now? The single-set count `card_constOn_le` is the `d = 0` (independent)
special case of the LLL bound; with it proved, the dependency-aware version is the
clear generalization, and `property_B_bound` already shows the hypergraph
encoding compiles in this catalog.

## Direction 4: Turán meets Ramsey — Ramsey–Turán type thresholds

Combine this file with Mathlib's `SimpleGraph.turanGraph` /
`isTuranMaximal_turanGraph`: study colorings of `K_n` whose color classes are
each `K_{r+1}`-free, and prove an edge-counting threshold below which a
`K_{r+1}`-free-classes coloring with no monochromatic `K_k` exists. This is a
genuine cross-domain bridge between extremal graph theory (Turán) and the
probabilistic method (Ramsey).

The key insight is that the Turán bound caps the number of edges any single color
class can carry, which sharpens the per-class first-moment count
`card_monoOn_le` — fewer admissible edges means a strictly smaller bad set, so
the existence threshold improves quantitatively.

Why now? Turán is already fully available in Mathlib and the Ramsey side is now
proved here, so the bridge requires no new foundational theory, only the
combination of two finished results.

## Direction 5: The deletion (alteration) method as a quantitative improvement

Strengthen `erdos_ramsey_exists` via deletion: when the expected number of
monochromatic `K_k` is `m ≥ 1` (so the plain union bound fails), delete one
vertex from each monochromatic clique to obtain a clique-free coloring on
`≥ n - m` vertices, recovering the classical `R(k,k) > c · k · 2^(k/2)` constant
improvement. Formalize the deletion step (cf.
`ProbabilisticMethod.deletion_method_vertices`) as an operation on `Coloring`.

The key insight is that the bad set `B` counted in `erdos_ramsey_exists` doubles
as the *expected deletion count*: the same cardinality bound that proves
existence when `B.card < total` also bounds how many vertices must be removed when
it does not, so one inequality serves both regimes.

Why now? Both ingredients — the bad-set cardinality bound and a `Nat`-level
deletion lemma — already exist in the catalog, so the alteration method is an
assembly of proved pieces that yields a strictly stronger Ramsey constant.
