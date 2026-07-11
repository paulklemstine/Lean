# Computational Evidence: Chordal interference graphs are perfect

Target theorem: a graph with a **perfect elimination ordering (PEO)** satisfies
`χ(G) = ω(G)`, and greedy colouring along the order uses exactly `ω(G)` colours.
This is the structural fact behind optimal register allocation for SSA-form
programs (whose interference graphs are chordal).

## 1. Small-case calculations

We model live ranges `[lo i, hi i]` and the interval interference graph
(interfere ⇔ overlapping ranges). For sorted starts (`lo` monotone) this graph is
chordal via the "earlier neighbours are a clique" ordering, so `χ = ω`.

| Program (ranges)                          | max overlap ω | greedy colours | χ |
|-------------------------------------------|:-------------:|:--------------:|:-:|
| `[]` (empty)                              | 0             | 0              | 0 |
| `[0,2]`                                   | 1             | 1              | 1 |
| `[0,2],[1,3]`                             | 2             | 2              | 2 |
| `[0,4],[1,2],[3,5]`                       | 2             | 2              | 2 |
| `[0,5],[1,2],[1,3],[2,4]` (deep at t=1..2)| 3             | 3              | 3 |
| triangle `K₃` (`[0,2],[1,3],[2,4]`)       | 3             | 3              | 3 |

In every case the number of registers produced by the "process largest-index
first" greedy scan equals the maximum number of simultaneously live variables
(the clique number). This is exactly `χ = ω`.

## 2. Beyond intervals: genuine chordal graphs

Chordal graphs strictly contain interval graphs. The star `K_{1,3}` (a claw) plus
any tree is chordal but not necessarily an interval graph; all trees are chordal,
with `ω = 2` and `χ = 2`, matching the theorem. The general theorem
`chromaticNumber_eq_cliqueNum_of_peo` covers these directly (any graph with a PEO),
whereas the earlier interval-only analysis does not.

## 3. Counterexample hunt (necessity of chordality)

The claim `χ = ω` is FALSE for general graphs, so chordality is essential:

* Odd cycle `C₅`: `ω = 2` but `χ = 3`. `C₅` has NO perfect elimination ordering
  (every ordering leaves some vertex whose two earlier neighbours are non-adjacent),
  so the hypothesis `IsPerfectElimOrder` correctly fails and the theorem does not
  apply. No counterexample to the theorem itself.
* Petersen graph: `ω = 2`, `χ = 3` — again not chordal, hypothesis fails.

These confirm the theorem is non-vacuous and that the `IsPerfectElimOrder`
hypothesis is doing real work: it is exactly the dividing line between graphs where
greedy is optimal and graphs where it is not.

## 4. The greedy bound is tight

At the deepest program point the simultaneously-live variables form a clique of
size `ω`, so no colouring can use fewer than `ω` colours
(`cliqueNum_le_chromaticNumber`). Combined with the greedy upper bound this pins
`χ = ω` exactly — not merely up to the `Δ + 1` slack of the classical greedy
degree bound.


# Computational Evidence: Chordal interference graphs are perfect

Target theorem: a graph with a **perfect elimination ordering (PEO)** satisfies
`χ(G) = ω(G)`, and greedy colouring along the order uses exactly `ω(G)` colours.
This is the structural fact behind optimal register allocation for SSA-form
programs (whose interference graphs are chordal).

## 1. Small-case calculations

We model live ranges `[lo i, hi i]` and the interval interference graph
(interfere ⇔ overlapping ranges). For sorted starts (`lo` monotone) this graph is
chordal via the "earlier neighbours are a clique" ordering, so `χ = ω`.

| Program (ranges)                          | max overlap ω | greedy colours | χ |
|-------------------------------------------|:-------------:|:--------------:|:-:|
| `[]` (empty)                              | 0             | 0              | 0 |
| `[0,2]`                                   | 1             | 1              | 1 |
| `[0,2],[1,3]`                             | 2             | 2              | 2 |
| `[0,4],[1,2],[3,5]`                       | 2             | 2              | 2 |
| `[0,5],[1,2],[1,3],[2,4]` (deep at t=1..2)| 3             | 3              | 3 |
| triangle `K₃` (`[0,2],[1,3],[2,4]`)       | 3             | 3              | 3 |

In every case the number of registers produced by the "process largest-index
first" greedy scan equals the maximum number of simultaneously live variables
(the clique number). This is exactly `χ = ω`.

## 2. Beyond intervals: genuine chordal graphs

Chordal graphs strictly contain interval graphs. The star `K_{1,3}` (a claw) plus
any tree is chordal but not necessarily an interval graph; all trees are chordal,
with `ω = 2` and `χ = 2`, matching the theorem. The general theorem
`chromaticNumber_eq_cliqueNum_of_peo` covers these directly (any graph with a PEO),
whereas the earlier interval-only analysis does not.

## 3. Counterexample hunt (necessity of chordality)

The claim `χ = ω` is FALSE for general graphs, so chordality is essential:

* Odd cycle `C₅`: `ω = 2` but `χ = 3`. `C₅` has NO perfect elimination ordering
  (every ordering leaves some vertex whose two earlier neighbours are non-adjacent),
  so the hypothesis `IsPerfectElimOrder` correctly fails and the theorem does not
  apply. No counterexample to the theorem itself.
* Petersen graph: `ω = 2`, `χ = 3` — again not chordal, hypothesis fails.

These confirm the theorem is non-vacuous and that the `IsPerfectElimOrder`
hypothesis is doing real work: it is exactly the dividing line between graphs where
greedy is optimal and graphs where it is not.

## 4. The greedy bound is tight

At the deepest program point the simultaneously-live variables form a clique of
size `ω`, so no colouring can use fewer than `ω` colours
(`cliqueNum_le_chromaticNumber`). Combined with the greedy upper bound this pins
`χ = ω` exactly — not merely up to the `Δ + 1` slack of the classical greedy
degree bound.
