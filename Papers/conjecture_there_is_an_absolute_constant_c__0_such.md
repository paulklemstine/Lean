# Computational Evidence — Snake-in-the-Box rigidity

Target statement (Conjecture 2 of the research direction):

> For every `n ≥ 3`, a snake (chordless / induced path) in the hypercube `Q_n`
> omits at least `2^(n-2)` vertices.

Equivalently, a snake with `L` edges has `m = L + 1 ≤ 3 · 2^(n-2)` vertices.

## 1. Exhaustive small-case search

An exhaustive depth-first search over induced paths starting at `0…0`
(a vertex may be appended only if it has exactly one already-used neighbour)
gives the maximum snake length `s(n)`:

| n | s(n) (edges) | m = s(n)+1 | ceiling `3·2^(n-2)` | omitted `2^n − m` | required `2^(n-2)` |
|---|---|---|---|---|---|
| 1 | 1  | 2  | –  | 0  | –  |
| 2 | 2  | 3  | 3  | 1  | 1  |
| 3 | 4  | 5  | 6  | 3  | 2  |
| 4 | 7  | 8  | 12 | 8  | 4  |
| 5 | 13 | 14 | 24 | 18 | 8  |

These agree with the classical values `1, 2, 4, 7, 13, 26, 50, 98, 190` of the
snake-in-the-box sequence (OEIS **A099155**, longest induced path in `Q_n`;
the closely related coil sequence is A000937). The conjectured omission bound
holds in every computed case, with increasing slack, and the counting ceiling
`3·2^(n-2)` proved in the Lean file is above the true optimum for all `n ≥ 2`
(tight only in the trivial regime `n = 2`).

## 2. Why the bound is provable — the mechanism found computationally

For every snake found in the search, each snake vertex has **at most two**
snake vertices among its `n` cube neighbours (exactly the chordlessness
condition). Consequently the number of cube edges from the snake vertex set
`S` to its complement is at least `(n−2)·|S|`, while the complement can absorb
at most `n·(2^n − |S|)` such edges. This double count gives

```
(n − 2)·m + n·m ≤ n·2^n     ⟹     m ≤ n·2^n / (2n − 2) ≤ 3·2^(n-2)   (n ≥ 3).
```

Numerically, `n·2^n/(2n−2)` equals `6, 10.7, 20, 38.4, 74.7, 146.3` for
`n = 3,…,8`, always above the true numbers of snake vertices
`5, 8, 14, 27, 51, 99` and always at most `3·2^(n-2) = 6, 12, 24, 48, 96, 192`.
The inequality `n·2^n/(2n−2) ≤ 3·2^(n-2)` is equivalent to `4n ≤ 6n − 6`, i.e.
`n ≥ 3`, with equality exactly at `n = 3`.

## 3. Counterexample hunt

No counterexample exists among the exhaustively enumerated snakes for
`n ≤ 5` (all induced paths, not just maximal ones, satisfy the degree
condition by definition, and the derived ceiling is respected). The formal
Lean proof in `Computation/SnakeInTheBox.lean` settles all `n` unconditionally.

## 4. Non-vacuity check

The explicit path `000 → 001 → 011 → 111 → 110` is a snake of length `4` in
`Q_3` (all six non-consecutive pairs are at Hamming distance ≥ 2), and it
embeds into `Q_n` for every `n ≥ 3`. This is formalised as `snake3` and
`exists_snake_four`, so the rigidity theorem is not vacuous.

## 5. The sharpened count and the low-dimensional optima

Accounting for the two path endpoints exactly (each has only one snake
neighbour, so the vertex set spans exactly `L` cube edges) upgrades the double
count to

```
2n·m ≤ n·2^n + 2(m − 1),   i.e.   (2n − 2)·m + 2 ≤ n·2^n     (m = L + 1).
```

The resulting ceilings on `m = L + 1`, against the true maxima, are:

| n | ceiling from the sharpened count | true `m = s(n)+1` |
|---|---|---|
| 2 | 3  | 3  |
| 3 | 5  | 5  |
| 4 | 10 | 8  |
| 5 | 19 | 14 |
| 6 | 38 | 27 |

The bound is exact for `n = 2, 3`, which is what makes the Lean theorems
`snake_max_dim_two` and `snake_max_dim_three` (exact optima `s(2) = 2`,
`s(3) = 4`) possible: the counting ceiling meets the explicit snakes `snake2`
and `snake3`. From `n = 4` on the ceiling is strictly above the record values,
so exact determination in higher dimensions needs additional local structure or
a verified search. These table values come from an exploratory search script;
the general inequalities and the two exact optima are what is machine-verified.

## Lower bound from the fresh-coordinate lift

The lift `Snake.lift` (formalised in `Computation/SnakeMax.lean`) adds one edge
per new dimension, and the two-sided lift `Snake.lift2` adds two, so from the
seed `s(3) = 4` they certify `s(n) ≥ n + 1` and `s(n) ≥ 2n − 2` respectively.
Against the known maxima both are very weak, which is worth recording
explicitly:

| n | one-sided lift `n+1` | two-sided lift `2n−2` | true `s(n)` |
|---|---|---|---|
| 3 | 4  | 4  | 4  |
| 4 | 5  | 6  | 7  |
| 5 | 6  | 8  | 13 |
| 6 | 7  | 10 | 26 |
| 7 | 8  | 12 | 50 |

Both lifts are tight only at the seed dimension: any approach to the density
conjecture must multiply, rather than increment, the length when a dimension is
added. The `s(n)` column comes from the classical snake-in-the-box values used
in the exploratory search above; the two lower-bound columns are what is
machine-verified.
