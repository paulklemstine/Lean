# Computational evidence

All experiments below were run with `#eval` inside Lean 4 (Mathlib v4.28.0) on computable
models of the objects that are later formalised in `Catalog/Bridges/InfiniteCubicMatchings*.lean`.
The graph used is the doubly infinite ladder `L` on `ℤ × Bool`
(rungs `(n,b) — (n,¬b)`, rails `(n,b) — (n+1,b)`), truncated to a symmetric window
`{-k,…,k} × Bool` when a finite computation is required.

Four candidate partner maps were tested:

| name | definition |
|---|---|
| `rungP` | `(n,b) ↦ (n,¬b)` |
| `evenP` | `(n,b) ↦ (n+1,b)` if `n` even, `(n−1,b)` otherwise |
| `oddP`  | `(n,b) ↦ (n−1,b)` if `n` even, `(n+1,b)` otherwise |
| `shiftP`| bottom row uses `evenP`, top row uses `oddP` |

## 1. Are these perfect matchings?

Check on the window `k = 20` (82 vertices) that `p` is adjacent to `f p` and `f (f p) = p`:

```
#eval (checkMatching rungP 20, checkMatching evenP 20, checkMatching oddP 20, checkMatching shiftP 20)
-- (true, true, true, true)
```

All four maps are fixed-point-free involutions along edges, i.e. perfect matchings.
This is what the Lean definitions `rung`, `evenRail`, `oddRail` (ladder file) and `shifted`
(sharpness file) prove for all of `ℤ`.

## 2. Proper 3-edge-colouring

Every edge of the window `k = 8` lies in exactly one of `rungP`, `evenP`, `oddP`:

```
#eval ((colourCount 8).all (fun n => n == 1), (allEdges 8).length)
-- (true, 49)
```

49 edges in the window, each covered exactly once.  Formalised as
`ladder_properThreeEdgeColoring`.

## 3. Berge–Fulkerson multiplicities

Doubling the three colour classes yields the six matchings of a Berge–Fulkerson family; the
multiset of edge multiplicities collapses to a single value:

```
#eval (multiplicities of all edges of window 8).dedup
-- [2]
```

Every edge is covered exactly twice — matching `ProperThreeEdgeColoring.bergeFulkerson`.

## 4. Parity lemma: `|M ∩ ∂S| ≡ |S| (mod 2)` for finite `S`

`testParity S` returns, for the four matchings, the pair `(|S| mod 2, |M ∩ ∂S| mod 2)`.

| `S` | `|S|` | result (all four matchings) |
|---|---|---|
| `{(0,f)}` | 1 | `(1,1)` |
| `{(0,f),(0,t),(1,f)}` | 3 | `(1,1)` |
| `{(0,f),(0,t),(1,f),(1,t),(2,f)}` | 5 | `(1,1)` |
| first 7 vertices of window 3 | 7 | `(1,1)` |
| first 11 vertices of window 4 | 11 | `(1,1)` |
| `{(0,f),(0,t)}` | 2 | `(0,0)` |
| `{(0,f),(1,t),(3,f),(7,t)}` | 4 | `(0,0)` |
| first 10 vertices of window 4 | 10 | `(0,0)` |

No counterexample was found; the parity is always exactly `|S| mod 2`.  Formalised in full
generality as `PerfectMatching.card_inter_cutEdges_odd`.

## 5. Counterexample hunt: cuts with two infinite sides

Take `S = {p | p.1 ≤ 0} ∪ {(1,false)}`, whose two sides are both infinite.  Its cut is
computed to be

```
#eval cutEdgesW 6
-- [((0,true),(1,true)), ((1,false),(1,true)), ((1,false),(2,false))]
```

i.e. **three** edges — an odd cut.  How many of them does each matching use?

```
#eval (cutEdgesW 6).countP (fun e => shiftP e.1 == e.2)  -- 0
#eval (cutEdgesW 6).countP (fun e => rungP  e.1 == e.2)  -- 1
#eval (cutEdgesW 6).countP (fun e => evenP  e.1 == e.2)  -- 1
```

The `shiftP` matching meets this odd cut in **zero** edges.  This is a genuine counterexample
to the naive parity lemma when the finiteness of one side is dropped, and it is exactly the
content of the theorem `parity_fails_for_cuts_with_two_infinite_sides`, which is proved in
Lean (no truncation, the real infinite ladder).

## 6. OEIS

No integer sequence of independent interest arises here: the relevant counts are the constants
`6`, `3`, `2` from the statements of the conjectures and the edge multiplicity `2`.  No OEIS
lookup was performed.

## Status

Items 1–5 are exploratory computations on truncated windows.  Each of them is superseded by a
`sorry`-free Lean theorem about the genuinely infinite graph, listed in the files
`Catalog/Bridges/InfiniteCubicMatchingsLadder.lean` and
`Catalog/Bridges/InfiniteCubicMatchingsParitySharp.lean`.

## 5. The Petersen graph: exhaustive search for perfect matchings

The base graph of the infinite lift of `Catalog/Bridges/InfiniteCubicMatchingsPetersenLift.lean`
is the Petersen graph (outer 5-cycle `0..4`, inner pentagram `5..9`, spokes `i — i+5`).
Brute force over all 5-element subsets of its 15 edges (3003 candidates), inside Lean:

```
#eval edges.length                       -- 15
#eval allPMs.length                      -- 6
#eval edges.map (fun e => (allPMs.filter (fun m => m.contains e)).length)
-- [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
```

So the Petersen graph has **exactly six** perfect matchings, and each of its 15 edges lies in
**exactly two** of them — the Berge–Fulkerson family is unique and forced.  The six matchings
found are

```
[(0,5), (1,6), (2,7), (3,8), (4,9)]
[(0,5), (1,2), (3,4), (6,8), (7,9)]
[(0,4), (1,6), (2,3), (5,8), (7,9)]
[(0,4), (1,2), (3,8), (5,7), (6,9)]
[(0,1), (2,7), (3,4), (5,8), (6,9)]
[(0,1), (2,3), (4,9), (5,7), (6,8)]
```

These are exactly the six partner tables `petersenPM 0 … petersenPM 5` used in the Lean file;
the checks

```
#eval (List.finRange 6).all (fun i => (List.finRange 10).all (fun v =>
  (petersenPM i (petersenPM i v) = v) && (petersenPM i v ∈ nbr v)))    -- true
#eval edges.map (fun e => ((List.finRange 6).filter (fun i => petersenPM i e.1 = e.2)).length)
-- [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
```

confirm that each table is a fixed-point-free involution along edges and that the resulting
family covers every edge twice.  Both facts are then *proved* (not merely evaluated) in
`petersenMatching` and `petersen_bergeFulkerson` by kernel computation (`decide`), and lifted
to the infinite ℤ-voltage cover in `petersenLift_bergeFulkerson`.

Note the contrast with the ladder: the Petersen graph is **not** 3-edge-colourable, so this
example is not covered by `ProperThreeEdgeColoring.bergeFulkerson`; the covering theorem
`BergeFulkerson.of_covering` is what makes the infinite lift work.
