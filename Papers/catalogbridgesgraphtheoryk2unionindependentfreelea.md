# Computational evidence

This note records the exploratory computations that guided the two new Lean files

* `Catalog/Combinatorics/K2UnionK1FreeInvariants.lean`
* `Catalog/Combinatorics/K2UnionK1FreeHierarchy.lean`

**Status of the numbers below.** They come from ad-hoc Python enumeration (brute force over
labelled graphs) and are *not* machine-checked. Every statement that is claimed as a theorem
in this project is proved in Lean, independently of these computations; the tables only
explain why the theorems were stated the way they are and which further statements look
plausible. Whenever a small finite fact is used as a *regression test*, it was additionally
formalized in Lean (see the "Finite regression tests" sections of the two files, all of which
are discharged by `decide` plus explicit combinatorial arguments — no `native_decide`).

## 1. Conventions being tested

For a non-complete graph `G`,

```
τ(G) = min { |S| / c(G − S) : S ⊆ V(G), c(G − S) ≥ 2 },
```

and `τ(K_n) = ∞`. In Lean this is encoded by the *predicates* `ToughAtLeast G t` (`τ ≥ t`)
and `ToughGreaterThan G t` (`τ > t`), quantified over all vertex sets `S` with
`compCount G S ≥ 2`; complete graphs then satisfy every such predicate vacuously, which is
the convention `τ = ∞`.

`G` is `(K₂ ∪ kK₁)`-free when no edge `uv` has `k` independent vertices anticomplete to
`{u, v}`.

## 2. Exhaustive enumeration of labelled graphs

All connected labelled graphs on `n` vertices were enumerated; complete graphs were skipped
(`τ = ∞`).

| `n` | connected | non-complete with `τ > 1` | violations of `2α(G) < n` | violations of `δ(G) ≥ 3` | non-Hamilton-connected with `τ > 1` |
|----|-----------|---------------------------|---------------------------|--------------------------|-------------------------------------|
| 3  | 4         | 0                         | 0                         | 0                        | 0 |
| 4  | 38        | 0                         | 0                         | 0                        | 0 |
| 5  | 728       | 25                        | 0                         | 0                        | 0 |
| 6  | 26 704    | 1 617                     | 0                         | 0                        | 0 |
| 7  | —         | 202 975                   | 0                         | 0                        | 0 |

(For `n = 7` only graphs with `δ ≥ 3` were enumerated, which is harmless: the `δ ≥ 3` column
shows `δ ≥ 3` is forced by `τ > 1` at these orders, and this is now a theorem —
`three_le_minDegree_of_toughGreaterThan_one`.)

Two of these columns became Lean theorems:

* `2α(G) < n` for `τ(G) > 1`, `n ≥ 3` — `two_mul_indepNum_lt`;
* `δ(G) ≥ 3` for `τ(G) > 1`, `n ≥ 4` — `three_le_minDegree_of_toughGreaterThan_one`
  (and `δ(G) ≥ 2` already for `τ(G) ≥ 1`, `n ≥ 3`).

Maximum independence number among graphs with `τ > 1`:

| `n` | max `α` | `⌊(n−1)/2⌋` |
|----|--------|-------------|
| 5  | 2      | 2 |
| 6  | 2      | 2 |
| 7  | 3      | 3 |

so the proved bound `2α < n` looks sharp for every order.

## 3. The headline hypotheses (paper Theorem 1)

Hypotheses tested: `(k+1)`-connected, `(K₂ ∪ kK₁)`-free, `τ(G) > 1`, `δ(G) ≥ 2k`.

| `n` | instances satisfying the hypotheses (`k ≤ 3`) | non-Hamilton-connected among them |
|----|-----------------------------------------------|-----------------------------------|
| 5  | 25                                            | 0 |
| 6  | 150                                           | 0 |
| 7  | 16 446                                        | 0 |

No counterexample; moreover at these orders *every* non-complete graph with `τ > 1` is already
Hamilton-connected, so small graphs cannot separate the hypotheses. The separating example
must be larger.

## 4. Counterexample hunt: the Petersen graph

| invariant | value |
|-----------|-------|
| order | 10 |
| degrees | all `3` |
| vertex connectivity | 3 |
| `τ` | `4/3 > 1` |
| `α` | 4 (so `2α = 8 < 10`, consistent with the proved bound) |
| smallest `k` with `(K₂ ∪ kK₁)`-freeness | 3 |
| Hamiltonian | no |
| Hamilton-connected | no |

So the Petersen graph is a `3`-connected, `(K₂ ∪ 3K₁)`-free graph with `τ > 1` that is not
Hamilton-connected. For `k = 3` it fails exactly two of the headline hypotheses, namely
`δ ≥ 2k = 6` (it has `δ = 3`) and `(k+1) = 4`-connectivity (it is only `3`-connected); so it
witnesses that `τ > 1` plus `(K₂ ∪ kK₁)`-freeness alone is *not* sufficient, and that the two
remaining hypotheses cannot both be dropped.

Petersen is *not* `(K₂ ∪ 2K₁)`-free, which is why it does not contradict Conjecture 2 below.

## 5. Small graphs used as Lean regression tests

| graph | fact | Lean name |
|-------|------|-----------|
| `P₃` | is `(K₂ ∪ K₁)`-free | `pathGraph_three_free` |
| `P₄` | is *not* `(K₂ ∪ K₁)`-free | `pathGraph_four_not_free` |
| `P₃` | not `1`-tough (deleting the middle vertex leaves 2 components) | `pathGraph_three_not_toughAtLeast_one` |
| `3K₁` | has 3 components | `compCount_bot_fin_three` |
| `C₅` | not `(K₂ ∪ K₁)`-free | `cycleGraph_five_not_free_one` |
| `C₅` | is `(K₂ ∪ 2K₁)`-free | `cycleGraph_five_free_two` |
| `C₅` | `τ(C₅) ≤ 1`, i.e. not `τ > 1` | `cycleGraph_five_not_toughGreaterThan_one` |
| `K₂ ∪ kK₁` | `(K₂ ∪ (k+1)K₁)`-free but not `(K₂ ∪ kK₁)`-free | `hierarchy_strict` |

## 6. OEIS

No new integer sequence arose; the counts in §2 are counts of labelled graphs with a toughness
condition and were not matched against OEIS (they depend on the labelled model and on the
`τ > 1` convention, and are not expected to be catalogued).

## 7. Reproducing

The enumeration used plain Python (no external packages): brute force over edge subsets,
union-find/DFS component counts, exact `Fraction` toughness, Held–Karp bitmask DP for
Hamilton paths between every ordered pair of vertices. Runtime: a few minutes for `n ≤ 7`.

## 8. Addendum for the follow-up cycle

The follow-up cycle added

* `Catalog/Combinatorics/K2UnionK1FreeToughnessBounds.lean`,
* `Catalog/Combinatorics/K2UnionK1FreeParameter.lean`,
* `Catalog/Combinatorics/HamiltonConnectedDegree.lean`.

No new external enumeration was run: the new theorems generalize the `t = 1` statements that
the tables above already supported (`δ ≥ 3` becomes `δ ≥ ⌊2t⌋ + 1`, `2α < n` becomes
`(t+1)α < n`), or are structural statements whose small-case checks are themselves formalized
in Lean. The finite facts newly promoted to machine-checked Lean statements are:

| graph | fact | Lean name |
|-------|------|-----------|
| `K₅` | `4`-connected (in the `VertexConnAtLeast` sense) | `top_fin_five_vertexConnAtLeast_four` |
| `K₅` | `δ = 4` | `top_fin_five_minDegree` |
| `C₅` | `δ = 2` | `cycleGraph_five_minDegree` |
| `C₅` | freeness parameter `= 2` | `freeParam_cycleGraph_five` |
| `K₂ ∪ kK₁` | freeness parameter `= k + 1` | `freeParam_k2UnionK1` |
| `Kₙ` (`n ≥ 2`) | freeness parameter `= 1` | `freeParam_top_eq_one` |
| `P₃` | not Hamilton-connected | `pathGraph_three_not_isHamiltonConnected` |
| `C₅` | not Hamilton-connected | `cycleGraph_five_not_isHamiltonConnected` |

The Petersen data of §4 is used only as evidence for the conjectures in
`FUTURE_DIRECTIONS.md` and remains an unverified external computation.

## 9. Addendum for the metric cycle

This cycle added

* `Catalog/Combinatorics/K2UnionK1FreeDiameter.lean`,
* `Catalog/Combinatorics/LongestPathExchange.lean`.

Two new scans were run to test the conjectures stated in `FUTURE_DIRECTIONS.md`. Both are
plain Python brute force (all labelled graphs for small `n`; uniformly random edge subsets
otherwise), with exact `Fraction` toughness, BFS diameter, and `freeParam` computed as
`1 + max_e α(anti(e))`, the maximum being over the edges `e` of the graph and `anti(e)` the
set of vertices adjacent to neither endpoint of `e`. **These enumerations are external and
not machine-verified**, in contrast with the Lean theorems.

| scan | range | result |
|------|-------|--------|
| `diam ≤ freeParam` for non-complete `τ > 1` | all graphs, `n ≤ 6` | **false**: `25` counterexamples at `n = 5` (e.g. `τ = 3/2`, `diam = 2`, `freeParam = 1`), `75` at `n = 6` |
| `diam ≤ freeParam + 1` for non-complete `τ > 1` | all graphs `n ≤ 6`; `4000` random graphs at `n = 7, 8` | no counterexample (Conjecture 4) |
| `3·freeParam ≤ n` for non-complete `τ > 1` | random graphs at `n = 8` | **false**: `freeParam = 3`, `τ = 4/3`, `n = 8` |
| `n ≥ 2·freeParam + 2` for non-complete `τ > 1` | all graphs `n ≤ 6`; `3000` random graphs at `n = 7, 8, 9` | no counterexample (Conjecture 5); observed maxima `freeParam = 2` (`n = 6, 7`), `freeParam = 3` (`n = 8, 9`) |

The metric facts that are now machine-checked in Lean rather than merely enumerated are the
general statements themselves: `diam(G) ≤ 2k` for `(K₂ ∪ kK₁)`-free graphs
(`dist_le_two_mul_of_free`), `diam(G) ≤ 2·freeParam(G)` (`dist_le_two_mul_freeParam`),
`diam(G) < 2·α(G)` (`dist_lt_two_mul_indepNum`), and the sharpness pair
`pathGraph_free` / `pathGraph_dist_eq` for the paths `P_{2k+1}` — so the extremal family for
the diameter bound is verified for every `k`, not only for the small cases reachable by
enumeration.
