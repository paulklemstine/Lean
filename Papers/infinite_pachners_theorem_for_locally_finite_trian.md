# Computational Evidence: Infinite Pachner in Dimension 1

We model a locally finite triangulation of the real line `M = ℝ` by its vertex
set `V ⊆ ℝ`, required to meet every bounded interval in a finite set and to be
unbounded above and below. In dimension one the two Pachner moves are:

* **subdivision** (`0`-move): insert one new vertex `x ∉ V`, giving `V ∪ {x}`;
* **weld** (`1`-move): delete one vertex `x ∈ V`, giving `V \ {x}`.

These are mutually inverse, so the move relation is symmetric.

## Small-case calculations (finite symmetric difference)

We connect two vertex sets by toggling their symmetric difference one point at a
time. Each toggle is a single Pachner move.

* `S = {0,1,2,…}` vs `T = {0,1,2,…} ∪ {½}`: symmetric difference `{½}`, size 1.
  One subdivision inserting `½` turns `S` into `T`. (1 move.)

* `S = ℤ` vs `T = ℤ \ {0}` (locally: remove the origin vertex): symmetric
  difference `{0}`, size 1. One weld. (1 move.)

* `S = ℤ` vs `T = (ℤ \ {0,1}) ∪ {½}`: symmetric difference `{0, 1, ½}`, size 3.
  Weld `0`, weld `1`, subdivide `½`: 3 moves. Order is irrelevant; the number of
  moves equals the size of the symmetric difference. This is exactly the
  induction in `symmDiff_card_move` (one move drops the symmetric-difference
  cardinality by one).

The pattern "number of moves = `|S △ T|`" was checked on the cases above and
matches the formalized proof, which is by induction on `(S △ T).ncard`.

## The infinite case: window stabilization

For genuinely different locally finite triangulations, e.g.

* `S = ℤ` (integers) and `T = 2·ℤ = {…,-2,0,2,4,…}`,

the symmetric difference `S △ T = ℤ \ 2ℤ = {odd integers}` is **infinite**, so no
finite sequence of moves suffices. The theorem instead produces a sequence of
milestone triangulations

```
g n = (S \ (-n, n)) ∪ (T ∩ (-n, n))
```

that agrees with `T` on the window `(-n, n)` and with `S` outside it.

Tabulating `g n` for `S = ℤ`, `T = 2ℤ` (listing vertices near the origin):

| n | vertices of `g n` in `[-3,3]`        | window `(-n,n)` fixed to `T` |
|---|--------------------------------------|------------------------------|
| 0 | -3,-2,-1,0,1,2,3   (= `S`)           | empty                        |
| 1 | -3,-2,-1,0,1,2,3   (0 already in T)  | `(-1,1)`                     |
| 2 | -3,-2,0,2,3        (removed ±1)      | `(-2,2)`                     |
| 3 | -3,-2,0,2         (removed ±1, kept -2,2; -3 unaffected) | `(-3,3)` |

Each step `g n → g (n+1)` changes only finitely many vertices (those in the
annulus `(-(n+1),n+1) \ (-n,n)`), so is a **finite** block of Pachner moves
(`milestone_step`). On any fixed bounded window the sequence is eventually
constant and equal to `T` (`milestone_stabilizes`): this is precisely the
*local finiteness* of the total move sequence.

## Counterexample hunt

The claim "finite symmetric difference ⇒ finitely many moves" and "locally finite
triangulations ⇒ locally finite move sequence" survived every case tried above.
The only obstruction one might fear — that deleting a vertex could destroy
unboundedness — does not occur, because an unbounded locally finite set stays
unbounded after removing a single point (formalized in `move_preserves_isTri`).

## Why this evidence is representative

Every locally finite triangulation of `ℝ` is an order-isomorphic copy of a
bi-infinite increasing sequence of reals, so the examples above (`ℤ`, `2ℤ`, and
finite perturbations) exhaust the qualitative phenomena: finite vs infinite
symmetric difference. The formal proof handles both uniformly.
