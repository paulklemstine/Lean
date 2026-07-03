# Computational Evidence — Phantom Topologies

## Setup

A *phantom topology* is a family `T : ι → Top(X)` of topologies ("observers").
The *consensus* (real) topology is the supremum `⨆ i, T i` in Mathlib's lattice of
topologies, whose open sets are exactly the sets that are open for **every**
observer (`isOpen_iSup_iff`). Note the lattice order convention: `t ≤ s` means `t`
is *finer* (has more open sets), so each observer satisfies `T i ≤ consensus T`.

## Test 1 — R = lower-limit ∨ upper-limit (two observers)

Observers on `ℝ`:
- lower-limit (Sorgenfrey): `U` open iff each `x ∈ U` has `[x, b) ⊆ U` for some `b > x`.
- upper-limit: `U` open iff each `x ∈ U` has `(a, x] ⊆ U` for some `a < x`.

Key finite/logical check (the "squeeze"): for `a < x < b`,

    (a, x] ∪ [x, b) = (a, b),   x ∈ (a, b).

So if `U` is open for both observers at `x`, there is a two-sided open interval
`(a,b) ∋ x` with `(a,b) ⊆ U`; hence `U` is Euclidean-open. Conversely a Euclidean
ball `(x-ε, x+ε)` contains both `[x, x+ε)` and `(x-ε, x]`, so any Euclidean-open
set is open for both observers. This confirms `consensus = Euclidean` **exactly**.

Sample checks of the squeeze identity (all consistent):

| a  | x | b | (a,x] ∪ [x,b) | (a,b) |
|----|---|---|---------------|-------|
| -1 | 0 | 1 | (-1,1)        | (-1,1)|
| 0  | 1 | 3 | (0,3)         | (0,3) |
| 2  | 2.5 | 2.6 | (2,2.6)   | (2,2.6)|

## Test 2 — one observer is not enough (over-resolution)

The half-open set `[0,1)` is open for the lower-limit observer (take `b=1` at every
point) but is **not** Euclidean-open: any Euclidean ball around `0` contains points
`< 0` (e.g. `-ε/2`) that are outside `[0,1)`. Symmetrically `(0,1]` is upper-open
but not Euclidean-open (ball around `1` contains `1+ε/2`). So each single observer
resolves "phantom" open sets that reality does not: each observer is **strictly**
finer than the consensus.

Counterexample hunt for "one observer suffices": since the consensus of a single
observer `t` is `t` itself (`⨆_{Unit} t = t`), a one-observer representation equal to
Euclidean `ℝ` forces the observer to *be* Euclidean `ℝ`. No non-trivial one-observer
representation exists → the (strict) phantom number of `ℝ` is exactly 2.

## Notes on the general conjectures

- "Every second-countable space is a 2-observer consensus" — in the raw lattice
  sense every topology `τ` equals `τ ⊔ τ`, so the substantive content is requiring
  the observers to be **strictly finer** (genuine phantoms). The `ℝ` result is a
  clean witness of the strict, non-trivial version.
- "Non-metrizable ⇒ ≥ 3 observers" — the Zariski/cofinite formulation is delicate
  (the lower bound is representation-dependent); it is left as a future direction
  rather than claimed. The verified content here is the exact phantom number of the
  Euclidean line.

All qualitative claims above are discharged as `0`-sorry Lean theorems in
`Catalog/Novelty/PhantomTopology.lean` and `Catalog/Novelty/PhantomTopologyNumber.lean`.
