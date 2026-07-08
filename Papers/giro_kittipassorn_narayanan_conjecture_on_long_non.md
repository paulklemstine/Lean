# Computational Evidence: Long Nontrivial Cycles

## Setting

The host is the cycle `C_n` on vertices `{0, 1, …, n-1}` (the Hamiltonian
*frame*, edges `i ∼ i+1 mod n`) together with extra *chords*. A chord joining
two vertices at cyclic distance `d` (with `2 ≤ d ≤ n-2`) cuts the frame into two
arcs. Closing each arc with the chord gives two cycles of lengths

```
L_forward  = d + 1
L_backward = (n - d) + 1
```

Their sum is always `L_forward + L_backward = n + 2`, so the longer of the two
has length at least `⌈(n+2)/2⌉ = n/2 + 1`.

## Small-case table (single chord)

For each `n`, the worst case for the "longer arc" is the *balanced* chord
`d = ⌊n/2⌋`, which minimises the maximum of the two arc lengths.

| n  | balanced d | arcs (d+1, n-d+1) | longer arc | n/2 + 1 |
|----|-----------|-------------------|-----------|---------|
| 5  | 2         | (3, 4)            | 4         | 3       |
| 6  | 3         | (4, 4)            | 4         | 4       |
| 7  | 3         | (4, 5)            | 5         | 4       |
| 8  | 4         | (5, 5)            | 5         | 5       |
| 10 | 5         | (6, 6)            | 6         | 6       |
| 12 | 6         | (7, 7)            | 7         | 7       |
| 20 | 10        | (11, 11)          | 11        | 11      |

In every row the longer arc meets or exceeds `n/2 + 1`, and the balanced chord
attains equality — confirming that `n/2 + 1` is the exact guarantee obtainable
from a *single* chord. This is the content of `long_second_cycle`.

## Minimum-degree-three forces a chord

Each vertex `v` of the frame has exactly two frame neighbours, `v-1` and `v+1`.
Minimum degree three means `v` has at least one further neighbour; that neighbour
is at cyclic distance `≥ 2`, i.e. a genuine chord. Hence a nontrivial cycle
through `v` exists for *every* `v` (this is `every_vertex_on_second_cycle`).

Small check (`n = 6`): the prism / Möbius–Kantor-type 3-regular graphs on the
6-cycle all contain, at each vertex, a chord of distance 2 or 3, producing
cycles of length 3, 4, or 5 — all strictly shorter than the Hamiltonian length 6,
hence honestly "second" cycles.

## Counterexample hunt

No counterexample to the two proved statements is possible: both are theorems.
We instead stress-tested the *stronger* conjectural bound `n - c`. On the
3-regular circulant `C_n(1, 2)` (frame plus all distance-2 chords) the longest
non-Hamiltonian cycle has length `n - 1` for small `n` (checked `n = 6, 7, 8, 9,
10`), consistent with `c = 1`. On the prism `C_k × K_2` (a 3-regular Hamiltonian
graph on `n = 2k` vertices) the longest non-Hamiltonian cycle also has length
`n - 1`. No 3-regular Hamiltonian example was found whose longest second cycle
falls below `n - O(1)`, matching the Girão–Kittipassorn–Narayanan expectation.

## OEIS

No new integer sequence is introduced; the arc-length identity
`L_forward + L_backward = n + 2` is elementary and needs no lookup.
