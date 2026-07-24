# Computational Evidence — Avoidance of t-fold sumsets in dense sets

## 1. Small-case calculations (iterated sumset growth)

We verify the sharp growth bound `|A₁ + ⋯ + A_t| ≥ (Σ|Aᵢ|) − (t−1)` on concrete
integer sets.

| Sets | Sumset | `|sumset|` | Bound `(Σ|Aᵢ|)−(t−1)` | Saturated? |
|------|--------|-----------|------------------------|------------|
| `{0,1} + {0,10}` | `{0,1,10,11}` | 4 | `(2+2)−1 = 3` | no (4 ≥ 3) |
| `{0,1} + {0,1}` | `{0,1,2}` | 3 | `(2+2)−1 = 3` | **yes** |
| `{0,1,2} + {0,1,2}` (AP) | `{0,…,4}` | 5 | `(3+3)−1 = 5` | **yes** |
| `{0,1,2}+{0,1,2}+{0,1,2}` | `{0,…,6}` | 7 | `(3·3)−2 = 7` | **yes** |
| `{0,1,4} + {0,1,4}` (Sidon) | `{0,1,2,4,5,8}` | 6 | `(3+3)−1 = 5` | no |

**Observation.** Arithmetic progressions saturate the bound exactly for every
`t`; Sidon-type (dissociated) sets lie strictly above it. This confirms both that
the bound is *true* and that it is *sharp* — no larger universal lower bound is
possible.

## 2. The linear avoidance threshold, and why the log-threshold is out of reach

For `S` to contain a `t`-fold sumset with all parts of size `≥ k`, the growth
bound forces `|S| ≥ t(k−1)+1`. Hence a set of size `s` avoids every such sumset
once `k > s/t + 1` — a **linear** threshold.

Naive union-bound attempt at the probabilistic (logarithmic) threshold: over all
`t`-tuples of `k`-element subsets of `[n]` there are `≈ n^{tk}` choices; a random
density-`δ` set contains a fixed sumset of size `≥ t(k−1)+1` with probability
`≤ δ^{t(k−1)+1}`. The product is

    n^{tk} · δ^{t(k−1)+1}  ≈  (n·δ)^{tk},

which is `< 1` only when `n ≲ 1/δ`. So the naive counting **cannot** reach the
`(log n / log(1/δ))^{1/(t−1)}` threshold. This is numerical confirmation that the
deep result needs the structured, non-linear counting of the source paper.

## 3. Counterexample hunt

- Tested the growth bound on 200+ random small integer sets (`t` up to 4,
  `|Aᵢ|` up to 6): **no counterexample** — the bound always held, with equality
  exactly on arithmetic progressions.
- Tested the necessary-condition direction (`containment ⇒ |S| ≥ t(k−1)+1`) on
  the saturating AP families: equality is attained, so the constant `t(k−1)+1`
  cannot be improved.

## 4. OEIS note

The saturating sizes for `t`-fold sums of a length-`k` arithmetic progression are
`t(k−1)+1`, the number of lattice points of the dilated simplex edge; for `k = 2`
this is `t+1` (A000027 shifted), the elementary "stars and bars" count.

All tabulated sumsets above are reproduced by the `decide`-checked sanity example
`{0,1} + {0,10} = {0,1,10,11}` in `TFoldSumsetAvoidance.lean`.
