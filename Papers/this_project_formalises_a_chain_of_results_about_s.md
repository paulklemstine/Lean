# Computational evidence

All computations below were used *only* to find candidate objects and to test
conjectures before formalising them.  Everything that is claimed as a result in
this project is proved in Lean 4 with no `sorry`, no `native_decide` and no
extra axioms; the explicit snakes are re-checked inside Lean by kernel
computation (`decide`).

## 1. Longest chordless induced paths found by depth-first search

A randomised DFS over `Q n` (vertices as bitmasks, a candidate `w` is admissible
if no already-used vertex other than the current endpoint is adjacent to `w`)
gives, from the start vertex `0`:

| `n` | best length found | known optimum `s(n)` | used in Lean |
|-----|-------------------|----------------------|--------------|
| 4   | 7                 | 7                    | –            |
| 5   | 13                | 13                   | –            |
| 6   | **26**            | 26                   | `snake6 : Snake 6 26` |
| 7   | **47**            | 50                   | `snake7 : Snake 7 47` |

The two snakes actually formalised are

```
Q6 : 0 2 3 7 15 14 12 44 36 38 54 22 20 21 29 61 63 59 27 26 24 56 48 49 33 41 9
Q7 : 0 8 24 88 120 112 48 52 36 44 108 76 68 69 65 73 105 41 57 59 63 47 15 7 6
     22 30 94 126 118 102 103 99 35 34 42 106 74 66 82 83 19 17 21 29 93 125 117
```

(vertices written as integers, bit `k` = coordinate `k`).  Both were verified in
Python first and then *re-verified inside Lean* — `snake6_chord_fin` and
`snake7_chord_fin` check all `27²` resp. `48²` index pairs by kernel evaluation.
No optimality is claimed for either: only their existence is used.

The known sequence of optima is `s(n) = 1, 2, 4, 7, 13, 26, 50, 98` for
`n = 1, …, 8` (OEIS A099155, the "snake-in-the-box" numbers; the closely related
coil numbers `c(n) = 4, 6, 8, 14, 26, 48` for `n = 2, …, 7` are OEIS A000937).
Our verified lower bounds `s(6) ≥ 26` and `s(7) ≥ 47` are consistent with it.

## 2. Testing the concatenation conjecture `s(m+n) ≥ s(m) + s(n)`

Putting snake `A` of `Q m` in the first coordinate block with the second block
frozen at `b₀`, and then snake `B` of `Q n` in the second block with the first
block frozen at `a_L`, was tested on all pairs from the list above:

| `(m, n)` | `L + M` | concatenation is chordless |
|----------|---------|----------------------------|
| (2,2)    | 4       | yes |
| (3,3)    | 8       | yes |
| (3,4)    | 11      | yes |
| (4,4)    | 14      | yes |

No counterexample was found, and the two-line reason (a cross chord would have
to be short in both blocks at once) generalises — this is now the theorem
`Snake.concat` / `maxLen_superadditive`.

## 3. Testing the rectangle conjecture `c(m+n) ≥ 2 (s(m) + s(n))`

The cycle `A × {b₀} → {a_L} × B → A⁻¹ × {b_M} → {a₀} × B⁻¹` was tested the same
way:

| `(m, n)` | cycle length `2(L+M)` | induced cycle |
|----------|-----------------------|---------------|
| (2,2)    | 8                     | yes |
| (3,3)    | 16                    | yes |
| (2,3)    | 12                    | yes |
| (3,4)    | 22                    | yes |
| (4,6)    | 66                    | yes |

Again no counterexample; the obstruction one might fear — the two "long
diagonals" `d(a₀, a_L)` and `d(b₀, b_M)` — is exactly what the chord conditions
of the two snakes rule out when `L, M ≥ 2`.  This is now `Snake.rectangle`.

## 4. Small-case data behind the exact classifications

Exhaustive inspection of `Q 2` and `Q 3` (16 and 256 subsets of the relevant
sizes) matches the formal statements:

* induced cycle lengths in `Q 2`: `{4}` — `coil_max_dim_two`;
* induced cycle lengths in `Q 3`: `{4, 6}` — `coil_max_dim_three`;
* the maximum size of a vertex set of `Q 3` inducing a subgraph of maximum
  degree two is `6`, attained by the hexagon — `density_bound_sharp_dim_three`
  shows the general bound `3 · 2^(n-2)` is attained there.

## 5. Where the counting bound stands

For the bounded-degree density theorem `(2n - d)|S| ≤ n 2ⁿ`:

| `n` | bound for `d = 2` | best snake `s(n)+1` | best coil `c(n)` |
|-----|-------------------|---------------------|------------------|
| 3   | 6                 | 5                   | **6** (tight)    |
| 4   | 10                | 8                   | 8                |
| 5   | 20                | 14                  | 14               |
| 6   | 38                | 27                  | 26               |

so the bound is tight only at `n = 3` (by the hexagon, not by a snake) and the
gap grows: closing it is the open direction recorded in `FUTURE_DIRECTIONS.md`.

## 6. The grid comb (evidence for the product theorem)

The comb through the `(2q+1) × (M+1)` grid spanned by two snakes visits
`q(M+2) + M + 1` of the `(2q+1)(M+1)` grid vertices — asymptotically half of
them.  Instantiating it with the small snakes already in the catalog and
comparing against the known values `s(n) = 4, 7, 13, 26, 50` for `n = 3,…,7`:

| `s` (in `Q m`)   | `t` (in `Q n`) | comb length in `Q (m+n)` | known `s(m+n)` |
|------------------|----------------|--------------------------|----------------|
| `snake2 : Q2, L=2` | a 1-edge snake of `Q1` | `1·3 + 1 = 4` in `Q 3`   | 4 (tight)      |
| `snake2 : Q2, L=2` | `snake2 : Q2, M=2` | `1·4 + 2 = 6` in `Q 4`   | 7              |
| `snake3 : Q3, L=4` | `snake2 : Q2, M=2` | `2·4 + 2 = 10` in `Q 5`  | 13             |
| `snake3 : Q3, L=4` | `snake3 : Q3, M=4` | `2·6 + 4 = 16` in `Q 6`  | 26             |
| `snake6 : Q6, L=26`| `snake7 : Q7, M=47`| `13·49 + 47 = 684` in `Q 13` | ≥ 2687   |

No entry exceeds a known value, and the first row is exactly tight
(`maxLen 3 = 4`).  Evaluating the construction in Lean for the second row gives
the explicit `6`-edge snake of `Q 4`

```
0000 → 0001 → 0011 → 0111 → 1111 → 1101 → 1100
```

whose pairwise Hamming distances are all `≥ 2` at index distance `≥ 2`, as the
formal proof requires.

## 7. Growth rates compared

| bound                    | source file            | value at `n = 30` |
|--------------------------|------------------------|-------------------|
| `2n - 2`                 | catalog                | 58                |
| `6n - 19`                | `SnakeSeedSeven.lean`  | 161               |
| `n² / 5`                 | `SnakeQuadratic.lean`  | 180               |
| `23 ^ ⌊n/7⌋`             | `SnakeGridComb.lean`   | 279 841           |
| ceiling `3·2^(n-2)`      | catalog                | 805 306 368       |

The last two rows are both exponential in `n`, with bases `23^{1/7} ≈ 1.56` and
`2`; the ratio between them is `(2 / 23^{1/7})^n ≈ 1.28ⁿ`, which is exactly the
remaining gap (the true value is believed to sit at base `2` with a constant
factor about `0.3`).

## 8. Cycle 3: the exact small values, and the growth constant

The two dimensions that the catalog had not pinned down are trivial to compute
directly, and they are what makes `maxLen` strictly monotone at the bottom of
the range:

| `n`        | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|------------|---|---|---|---|---|---|---|---|
| `maxLen n` | 0 | 1 | 2 | 4 | 7 | 13 | 26 | 50 |
| proved     | `= 0` | `= 1` | `= 2` | `= 4` | `≥ 6` | `≥ 8` | `≥ 26` | `≥ 47` |

(The literature values `7, 13, 26, 50` are the classical snake-in-the-box
numbers `s(4), …, s(7)`; the "proved" row records what is formalised here.)
`maxLen 0 = 0` because `Q 0` has one vertex and no edge, and `maxLen 1 = 1`
because `Q 1` is a single edge — with these, every consecutive pair
`maxLen n < maxLen (n+1)` is strict, which is what
`Catalog/Novelty/SnakeSupport.lean` needs.

The growth constant of `Catalog/Novelty/SnakeGrowthConstant.lean` is bracketed
numerically by

| quantity                    | value      |
|-----------------------------|------------|
| `23^{1/7}` (from `Q 7` seed)| `1.5637…`  |
| `49^{1/8}` (would-be `Q 8` seed) | `1.6266…` |
| `(50/2)^{1/7}` (true `s(7)`)| `1.5838…`  |
| ceiling base                | `2`        |

so the proved bracket is `1.5637… ≤ snakeGrowth ≤ 2`, and the seed-based lower
bound is within `1.3%` of what the true value of `s(7)` would give through the
same product theorem. This is the numerical content behind sub-conjecture 2 of
`FUTURE_DIRECTIONS.md`.

For coils the same table applies asymptotically: `maxCoil n` is squeezed between
`maxLen (n-3)` and `3·maxLen n`, and at `n = 30` these differ by a factor of
about `3 · 23^{3/7} ≈ 11`, a constant — invisible on the exponential scale, which
is why the two growth constants coincide.

## 9. Cycle 4: the search for an eight-dimensional seed, and the sharpened comb

### 9.1 What the sharp comb changes numerically

`Snake.comb` turns a snake of even length `2q` in `Q m` and a snake of length
`M` in `Q n` into a snake of length `q(M+2)+M` in `Q (m+n)`.  The previous
cycle recorded this only in the rounded form `maxLen m · maxLen n ≤ 2·maxLen (m+n)`,
i.e. it dropped the summands `2·maxLen m + maxLen n`.  Keeping them multiplies
the maximal length by `(N+2)/2` instead of `N/2` per block of `k` dimensions:

| seed                | rounded base `(N/2)^{1/k}` | sharp base `((N+2)/2)^{1/k}` |
|---------------------|----------------------------|------------------------------|
| `Q 7`, `N = 46`     | `23^{1/7} = 1.5637…`       | `24^{1/7} = 1.5747…`         |
| `Q 8`, `N = 86`     | `43^{1/8} = 1.6003…`       | `44^{1/8} = 1.6047…`         |
| `Q 8`, `N = 98` (true `s(8)`) | `49^{1/8} = 1.6266…` | `50^{1/8} = 1.6307…`      |

### 9.2 The search

The eight-dimensional seed was produced by an iterated depth-first search with
random restarts over transition sequences of `Q 8` (start at `0`, extend to a
vertex whose only visited neighbour is the current endpoint, restart from a
random prefix of the incumbent with a bounded node budget).  Observed best
lengths over ten-to-thirty minute runs, per method:

| method                                   | `Q 7` | `Q 8` |
|------------------------------------------|-------|-------|
| plain randomised DFS                      | 45    | 76    |
| random rollouts (greedy / Warnsdorff-type)| 46    | 77    |
| beam search (width 2000)                  | 39    | —     |
| lexicographic DFS + reachability pruning  | 48    | —     |
| **restart-from-prefix DFS (used here)**   | 48    | **86**|

The `86`-edge path found this way is the one in
`Catalog/Novelty/SnakeSeedEight.lean`; it was re-checked outside Lean (all `87`
vertices distinct, consecutive Hamming distances `1`, all non-consecutive
distances `≥ 2`) and then verified inside Lean by kernel computation
(`decide`, 87 × 87 index pairs, about a minute of elaboration).  The known
optima are `s(7) = 50` and `s(8) = 98`, so the seed is not optimal; the search
plateaued at `86` across sixteen independent runs.

### 9.3 Resulting brackets

| quantity                       | previous cycle | this cycle |
|--------------------------------|----------------|------------|
| exponential lower bound        | `23^{⌊n/7⌋}`   | `44^{⌊n/8⌋}` |
| base of the lower bound        | `1.5637…`      | `1.6047…`  |
| proved bound on `snakeGrowth`  | `≥ 23^{1/7}`, `> 3/2` | `≥ 43^{1/8}`, `> 1.6` |
| ceiling                        | `≤ 2`          | `≤ 2`      |

A better seed would move the bracket further with no change to the proofs: the
lemmas `maxLen_exp_of_seed` and `snakeGrowth_ge_of_maxLen` take the seed as a
parameter.  With the true `s(8) = 98` they would give `50^{⌊n/8⌋}` and
`snakeGrowth ≥ 49^{1/8} = 1.6266…`.
