# Computational Evidence — Bias graphs gainable over ℤ/pℤ

Object under study: the contrabalanced biased graph `CB(k)` consisting of `k`
parallel edges between two vertices, with **empty bias** (no balanced digon).
A `ℤ/pℤ`-gain realises `CB(k)` iff the `k` edge-gains are pairwise distinct,
i.e. iff there is an injection `Fin k ↪ ZMod p`.

## 1. Small-case threshold table

`CB(k)` is `ℤ/pℤ`-gainable  ⟺  `k ≤ p`.

| p \ k | 1 | 2 | 3 | 4 | 5 | 6 |
|-------|---|---|---|---|---|---|
| 2     | ✔ | ✔ | ✘ | ✘ | ✘ | ✘ |
| 3     | ✔ | ✔ | ✔ | ✘ | ✘ | ✘ |
| 5     | ✔ | ✔ | ✔ | ✔ | ✔ | ✘ |

The first ✘ in each row sits at `k = p + 1`: this is the excluded minor
(`excludedMinor` in `Catalog/Novelty/BiasGraphGainsZp.lean`). Deleting an edge moves
one cell left, back into the ✔ region — minor-minimality.

## 2. Counting realisations (sanity / OEIS)

The number of contrabalanced `ℤ/pℤ`-gains on `CB(k)` is the number of injections
`Fin k ↪ ZMod p`, the falling factorial `p·(p-1)···(p-k+1) = p!/(p-k)!` (and `0`
once `k > p`).  For `k = p` this is `p!`. Falling factorials / `A008279`
(`T(n,k)=n!/(n-k)!`); the diagonal `k=p` is `p! = A000142`. The vanishing point
`k = p+1` is exactly the excluded-minor threshold.

## 3. Switching invariant (Pillar 1) numeric check

Take `A = ZMod 5`, closed walk `[0,1,2,0]`, gains `g 0 1 = 1, g 1 2 = 3, g 2 0 = 4`
(walkSum `= 1+3+4 = 8 = 3`). Switch by `η = (η0,η1,η2) = (2,4,1)`:
new gains `1+2-4 = 4`, `3+4-1 = 1`, `4+1-2 = 3`; new walkSum `4+1+3 = 8 = 3`.
Unchanged, as forced by `walkSum_switchGain_closed`.

## 4. Counterexample hunt

* Searched for a contrabalanced `ℤ/2ℤ`-gain on `CB(3)`: impossible (only 2 values),
  matching `not_gainable_succ 2`. No counterexample to `k ≤ p`.
* Searched for the *non-transitive* bias "digons 12 and 13 balanced but 23 unbalanced"
  on 3 parallel edges: impossible over **every** group (balance of digons is an
  equivalence relation `g i = g j`), so this is a group-*independent* obstruction —
  deliberately excluded from the `p`-dependent family above.

Conclusion: all computations agree with the formal threshold `k ≤ p`; no
counterexamples found.
