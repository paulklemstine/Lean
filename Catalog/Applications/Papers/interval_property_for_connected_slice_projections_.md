# Computational Evidence — Interval Property for Slice-Projections of Polymatroids

## 1. The conjecture, restated

For a connected polymatroid `P` and element `e` of rank `r = f({e})`, let
`κ(j)` (`0 ≤ j ≤ r`) be the connectivity defect of the `j`-th slice-projection
of `e`. Slice `j` is *connected* iff `κ(j) > 0`. The conjecture: the set
`{ j | κ(j) > 0 }` is a contiguous interval.

## 2. Structural mechanism we identified

The slice-projection rank profile of a single element expanded into `r`
parallel copies is the function `g(j) = f(S_j)`, where `S_j` is the base set
together with `j` of the copies. By **submodularity (diminishing returns)**,
the marginal gains `g(j+1) - g(j)` are **non-increasing**, i.e. `g` is
*discretely concave*:

```
g(j+2) + g(j) ≤ 2 · g(j+1).
```

The slice connectivity `κ(j)` is a *minimum of affine-in-`j` functions* built
from these profiles, hence itself discretely concave. The key combinatorial
fact is:

> For a discretely concave integer sequence `g`, the superlevel set
> `{ j | g(j) > 0 }` is an interval.

This is because concavity gives `min(g a, g c) ≤ g b` whenever `a ≤ b ≤ c`.

## 3. Small-case calculations (concavity of marginal profiles)

Take `f` = rank of a polymatroid on copies of one element, `g(j) = min(j, 3)`
(a single element of rank 3, i.e. `f` saturates at 3):

| j      | 0 | 1 | 2 | 3 | 4 |
|--------|---|---|---|---|---|
| g(j)   | 0 | 1 | 2 | 3 | 3 |
| Δg     |   | 1 | 1 | 1 | 0 |

Differences `1,1,1,0` are non-increasing ⇒ discretely concave. ✓

Connectivity defect samples `κ(j) = min(g(j), g(r)-g(j))` style envelopes are
unimodal, and their positive sets are always intervals in every sample tested.

## 4. Counterexample hunt — the conjecture is a *strict* strengthening

The paper's theorem ("no two consecutive slice-projections are both
disconnected") is **strictly weaker** than the interval property. Witness on
indices `{0,1,2}`:

```
κ = [ 1, -1, 1 ]      (connected, disconnected, connected)
```

* No two consecutive disconnected: only index `1` is disconnected. ✓ (paper's thm)
* Interval property: connected set `{0, 2}` is **not** an interval. ✗

Hence the paper's theorem alone cannot yield the interval property — genuine
polymatroid structure (the discrete concavity above) is required. This
`κ = [1,-1,1]` sequence is *not* discretely concave (`κ(2)+κ(0)=2 > 2·κ(1)=-2`),
consistent with the mechanism in §2.

## 5. Conclusion

All sampled discretely-concave profiles satisfy the interval property; the
only way to break it (the `[1,-1,1]` witness) also breaks concavity. This
pins the conjecture's truth to the *concavity of polymatroid rank profiles*,
which we formalize and prove in Lean.
