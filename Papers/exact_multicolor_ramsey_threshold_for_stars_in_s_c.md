# Computational Evidence — Exact star–Ramsey threshold

All claims below are *proved* in `Threshold.lean` / `Graphs.lean`; this note records the
small-case sanity checks that guided the formalization.

## 1. Local threshold `(∑_j (t_j − 1)) + 1`

A vertex with `d` incident edges, `q`-coloured, is forced to contain a monochromatic star
`K_{1,t_j}` for some colour `j` **iff** `d ≥ (∑_j (t_j − 1)) + 1`
(`StarRamsey.star_threshold`).

| `q` | `t`            | `∑(t_j−1)` | forcing degree `d ≥` | largest avoidable degree |
|-----|----------------|-----------:|---------------------:|-------------------------:|
| 1   | `(t₁)`         | `t₁−1`     | `t₁`                 | `t₁−1`                   |
| 2   | `(2,2)`        | `2`        | `3`                  | `2`                      |
| 2   | `(3,5)`        | `6`        | `7`                  | `6`                      |
| 3   | `(2,2,2)`      | `3`        | `4`                  | `3`                      |
| 3   | `(1,1,t₃)`     | `t₃−1`     | `t₃`                 | `t₃−1`                   |

* Avoidance is *constructive*: pack the `d` edges into the `∑(t_j−1)` capacity slots
  `Σ_j Fin(t_j−1)`; e.g. `q=2, t=(2,2), d=2` colours the two edges with colours `1,2`, giving
  one edge of each colour — no `K_{1,2}` in either colour. Adding a third edge (`d=3`) forces
  two same-coloured edges.

## 2. Complete graph `K_N`

`StarRamsey.Graph.completeGraph_hasMonoStar`: `K_N` forces a monochromatic star once
`N ≥ (∑_j (t_j − 1)) + 2` (degree `N−1 ≥ (∑_j (t_j − 1)) + 1`).

| `q` | `t`     | forcing `N ≥` |
|-----|---------|--------------:|
| 2   | `(2,2)` | `4`           |
| 2   | `(3,3)` | `6`           |
| 3   | `(2,2,2)` | `5`         |

## 3. Counterexample hunt against the proposed global formula

The mission's conjecture proposes the threshold
`N ≥ ∑_j (t_j − 1) + max{2s, s + max_j t_j}`. Reading `s` minimal (`s = 1`, complete graph)
gives `N ≥ ∑_j (t_j − 1) + max{2, 1 + max_j t_j} = ∑_j (t_j − 1) + 1 + max_j t_j` whenever
`max_j t_j ≥ 1`.

For `q=2, t=(2,2)`: the formula predicts forcing only at `N ≥ 2 + 1 + 2 = 5`. But the
per-vertex pigeonhole already forces a monochromatic `K_{1,2}` at `N = 4` (each vertex has
degree `3 = ∑(t_j−1)+1`), and this is *proved* in `completeGraph_hasMonoStar`. So the `+max_j t_j`
slack is **not** present at the local/complete-graph level: any extra slack in the conjecture
must come from genuinely global `s`-connector structure (edge sharing), not from a single
vertex. This is the central analytic finding of the cycle and is recorded in the Lab Notes and
`FUTURE_DIRECTIONS.md`.

## 4. OEIS

No new integer sequence; the threshold `∑(t_j−1)+1` is the affine pigeonhole bound and does not
warrant an OEIS entry.
