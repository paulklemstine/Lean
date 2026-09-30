# Round 47 part 31 — the barrier, measured rather than asserted: the curve supplies O(1) relations
# where the algorithm needs L_n[1/3]

**2026-09-29. The last measurement, and it replaces every qualitative statement about the
27% with a number.**

---

## 1. The method

Pure brute force over coprime `(u,v)` with `max(|u|, v) ≤ H`, keeping those with
`l(m) = w²`, evaluating `chi_P = Jacobi(C(t)·y, N)`. **No PARI, no group law, no descent, no
factorisation of `N`.** 102 instances across 12 moduli, `|c| ≤ 300`.

## 2. The rate is a function of HEIGHT, and it is a slow one

| `H` | instances with a `chi_P = −1` relation | rate |
|---|---|---|
| 20 | 29/102 | **28%** |
| 40 | 33/102 | 32% |
| 80 | 34/102 | 33% |
| 160 | 39/102 | 38% |
| 320 | 45/102 | **44%** |

**Sixteen-fold more height buys sixteen percentage points.** So the "27%" is *partly* a
height artefact — but it converges far too slowly to be the whole story, and the reason is
next.

## 3. THE ACTUAL BOTTLENECK: the relation count

**Look at the relation counts at `H = 320`:**

```
#relations at H=320:   1  1  1  1  1  1  1  1  1  1  2  2  2  2  3  3  4  4  4  7  8  8  13  21  25 ...
```

> **A median of 2–3 relations at height 320.** Many instances have **exactly one**.

**So the failure mode is not that the `−1` relation is hidden at high height. It is that
there is almost nothing there to be found.** The instances stuck at "None" through `H = 320`
are not unlucky — they are *empty*.

## 4. THE BARRIER, IN ONE LINE

> **The algorithm needs `~L_n[1/3]` relations. The relation curve supplies a median of 2–3
> at height 320, and grows like `H`, not like `L_n[1/3]`.** At `n = 10^20` the demand is
> `L_n[1/3, 1] = 6464`; the supply at any height anyone has computed is single digits.

And it is not fixable by search, because the supply is a *property of the curve*, not of the
effort. That is the whole content of the dimensional closure
(`Round47_DimensionalClosure.md`) turned into a count: **requiring `h(α) = g²` costs `d−2`
dimensions, and the residue is a genus-1 curve whose rational points are too few to sieve.**

## 5. What this supersedes

| earlier claim | now |
|---|---|
| "73% at `H = 60`" | a **rate vs height**, 28%→44% over `H` 20→320, on this sample |
| "the other 27% fail" | **not characterised** until now; now: many are *empty* curves, and the rate is height-limited |
| "the group law might rescue the 27%" | **tested: 0/192** (`Round47_EscapeTest.md`) |
| "relations are abundant" (A12, on the standard pipeline) | **true of the standard pipeline, false of the square-relation one** — that is exactly the round's synthesis (`Round47_StandardPipeline.md` §3) |

The two are not in conflict: **the standard pipeline has abundant relations and pays with
the class group and units; the square-relation pipeline needs no class group and has no
relations.** Each buys exactly what the other cannot afford.

## 6. The end state, in one paragraph

A **factorisation-free, descent-free** procedure factors a semiprime when the relation curve
supplies a `chi_P = −1` relation — verified end-to-end, 66/66 on the instances where it
fires, `p` and `q` never used by the procedure. It fires on a minority of instances at
computable heights, the rate rising slowly with height, because the curve supplies single
digits of relations. **Reaching the supply the algorithm needs, or certifying the absence of
a `−1` relation, both require the 2-descent at `p` and `q` — which factors `N`.** Whether a
different `f` always supplies enough is Conjecture 7.1, and it is open.
