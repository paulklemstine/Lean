# Computational evidence

All computations below were carried out inside Lean 4 (`#eval` on a computable combinatorial
model of the path `Pₙ`, and kernel `decide` for the statements that were subsequently promoted to
theorems).  Statements marked **[verified]** are backed by a `sorry`-free Lean proof in
`Catalog/MachineLearning/SemitotalDomination/`; statements marked *(exploratory)* are `#eval`
computations only.

## 1. Semitotal domination numbers of paths

Brute force over all `2ⁿ` subsets of `Pₙ` (adjacency `|i−j| = 1`, semitotal condition through the
explicit distance-≤2 relation):

| n  | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|----|---|---|---|---|---|---|---|---|----|----|----|----|----|
| γ(Pₙ)     | 1 | 1 | 2 | 2 | 2 | 3 | 3 | 3 | 4 | 4 | 4 | 5 | 5 |
| γ_t2(Pₙ)  | 2 | 2 | 2 | 2 | 3 | 3 | 4 | 4 | 4 | 5 | 5 | 6 | 6 |

* `n = 1`: no semitotal dominating set exists at all (isolated vertex) — consistent with the
  hypothesis "no isolated vertices" in `exists_semitotalDominatingSet`.
* The value `γ_t2(P₇) = 3` is **[verified]** in Lean
  (`semitotalDominationNumber_lineGraph_seven`, by exhaustive `decide` over all `2⁷` subsets of
  the *unit disk* realization of `P₇`).
* *(exploratory)* The data fit `γ_t2(Pₙ) = max(2, ⌈2n/5⌉)` for all `2 ≤ n ≤ 14`.  This is
  Conjecture 1 of `FUTURE_DIRECTIONS.md`.  We deliberately do **not** claim an OEIS
  identification: the sequence `2,2,2,2,3,3,4,4,4,5,5,6,6` is just `⌈2n/5⌉` corrected at `n = 2`.

## 2. Counterexample hunt: is every maximal independent set semitotal?

For each `n`, the number of maximal independent sets of `Pₙ` and how many of them fail the
semitotal condition:

| n  | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|----|---|---|---|---|---|---|---|
| #MIS | 1 | 2 | 2 | 3 | 4 | 5 | 7 |
| #MIS failing semitotal | 1 | 2 | 1 | 1 | 2 | 3 | 5 |

So the answer is a resounding **no**, and failures are the rule rather than the exception.  For
`P₇` the seven maximal independent sets are
`{0,2,4,6}, {1,3,5}, {0,2,5}, {0,3,5}, {0,3,6}, {1,3,6}, {1,4,6}`, of which only the first two are
semitotal.  The instance `{0,3,6}` is the one promoted to a Lean theorem
(**[verified]** `exists_maximal_independent_not_semitotal`): it is independent, dominating, and
not semitotal, in a *connected unit disk graph*.  This is precisely why the algorithm must scan
the vertices in BFS order.

## 3. The packing constant

The factor `5` is the maximum number of points of a closed unit disk that are pairwise at
distance `> 1`.

* Upper bound **[verified]**: `card_le_five_of_pairwise_far` (no six such points exist).
* Lower bound **[verified]**: `exists_five_pairwise_far_in_unit_disk` — the five fifth roots of
  unity, whose pairwise distances are `2 sin 36° = 1.17557…` and `2 sin 72° = 1.90211…`, both
  `> 1`.
* *(exploratory numerics)* For six points the optimal (maximin) separation in the closed unit
  disk is exactly `1`, attained by the centre plus a regular hexagon on the boundary.  Hence the
  strict inequality `> 1` in the packing lemma cannot be relaxed to `≥ 1`; adjacency in a unit
  disk graph being `≤ 1` (closed condition) is exactly what makes `5` correct.

## 4. Behaviour of the algorithm on the test instances

| graph | γ | γ_t2 | greedy BFS output | ratio | guarantee |
|-------|---|------|-------------------|-------|-----------|
| `P₇` (unit disk realization, root `0`) | 3 | 3 **[verified]** | `{0,2,4,6}` | 4/3 | ≤ 5 |
| star `K₁,₃` | 1 **[verified]** | 2 **[verified]** | `{centre}` → repaired to `{centre, leaf}` | 1 | ≤ 5 |

The star is the degenerate branch of the algorithm (the greedy BFS set is a single vertex and has
to be enlarged by one neighbour); the computation `γ = 1 < 2 = γ_t2` **[verified]**
(`dominationNumber_lt_semitotalDominationNumber_star`) shows that this repair step is genuinely
necessary and that it is optimal, not merely within a factor of `5`.

## 5. Second-cycle data: the ratio `γ_t2/γ` and higher dimensions

| graph | γ | γ_t2 | γ_t2/γ | universal bound `2γ` | unit-disk 5γ corollary |
|-------|---|------|--------|----------------------|------------------------|
| `K₂` | 1 | 2 | 2 | 2 (tight) | 5 |
| star `K₁,₃` (leaves at cube roots of unity) | 1 **[verified]** | 2 **[verified]** | 2 | 2 (tight) | 5 |
| `P₇` | 3 | 3 **[verified]** | 1 | 6 | 15 |

The small-case table above shows the ratio `γ_t2/γ` never exceeding `2`; this pattern is now
explained by the theorem `semitotalDominationNumber_le_two_mul_dominationNumber` **[verified]**:
`γ_t2 ≤ γ_t ≤ 2γ` for every graph with no isolated vertex.  The value `2` is attained already by `K₂`, and
`star_unitDisk_sharp` **[verified]** shows it is attained by a *connected unit disk graph*.

### Packing constants by dimension

| dimension `d` | volume bound `3^d` **[verified]** | sharp constant | note |
|---------------|-----------------------------------|----------------|------|
| 1 | 3 | 2 | interval `[-1,1]`, points `-1, 1` |
| 2 | 9 | 5 **[verified]** | regular pentagon **[verified]** |
| 2, half-disk | — | 3 **[verified]** | points `1, i, -1` **[verified]** |
| 3 | 27 | 12 or 13 (open, kissing-number-type) | |

The `3^d` column is `card_le_of_pairwise_far_in_ball` specialized to `r = δ = 1`, and it feeds the
dimension-`d` approximation theorem `exists_semitotalDominatingSet_card_le_three_pow_mul`
**[verified]**.  In the plane it reproves a (weaker) constant by a completely different technique
— Haar measure of disjoint balls instead of an angular pigeonhole — which is an independent check
on the planar analysis.
