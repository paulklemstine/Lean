# Computational Evidence — Isolation Lemma tightness under arbitrary edge offsets

Setting: the singleton hypergraph on `n` vertices with integer edge offset
`f : Fin n → ℤ`. Edge `{v}` has weight `f v + w v`, and an assignment
`w ∈ [d]^n` is *isolating* when a unique vertex attains the strict minimum of
`v ↦ f v + w v`. We write `I(n,d,f)` for the number of isolating assignments.

## 1. Small-case calculations

Direct enumeration (all `d^n` assignments) gives:

| n | d | offset f            | I(n,d,f) | offset-free `n·∑_{j<d} j^{n-1}` |
|---|---|---------------------|----------|---------------------------------|
| 3 | 4 | (0,0,0)             | 42       | 42                              |
| 3 | 4 | (7,7,7)             | 42       | 42                              |
| 3 | 3 | (0,0,0)             | 15       | 15                              |
| 3 | 3 | (0,1,5)             | 21       | 15                              |
| 2 | 2 | (0,0)               | 2        | 2                               |
| 2 | 2 | (0,3)               | 4        | 2                               |
| 3 | 4 | (0,4,8)  [= i·d]    | 64       | 42                              |
| 2 | 2 | (0,2)    [= i·d]    | 4        | 2                               |

Observations:
* **Constant offsets** reproduce the offset-free extremal value exactly.
* **Generic offsets** (e.g. `(0,1,5)`) strictly exceed it.
* **Separated offsets** `f i = i·d` isolate *every* assignment: `I = d^n`.

## 2. Per-vertex product formula

For every sampled offset the identity

`I(n,d,f) = ∑_i ∑_{m<d} ∏_{j≠i} #{k<d : f i + m < f j + k}`

matched brute force on `(n,d,f)` in
`{(3,4,(0,1,5)), (2,3,(2,0)), (3,3,(0,0,0)), (4,3,(0,1,2,1))}` — all `true`.

## 3. Counterexample hunt (is the extremal value offset-invariant?)

Refuted immediately: `I(2,2,(0,3)) = 4 ≠ 2 = I(2,2,(0,0))`. Hence the
Faber–Harris extremal value `n·∑_{j<d} j^{n-1}` is **not** an offset invariant; it
is the value of the symmetric (constant-offset) regime.

## 4. Sequence note

The offset-free diagonal `n·∑_{j<d} j^{n-1}` for `n=3` is `0,0,3,15,42,90,…`
(the value `3·∑_{j<d} j^2`). Constant offsets leave this fixed; separated offsets
send it to the maximal `d^n`.

All computations above are reproduced by the `#eval`/`decide` checks embedded in
`IsolationLemmaTightness.lean`.
