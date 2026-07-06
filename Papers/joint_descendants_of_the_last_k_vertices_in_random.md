# Computational Evidence — Joint descendants of the last `k` vertices in random `d`-DAGs

## 1. Telescoping of chained Beta moments (small-case check)

Let `f(α) = Γ(α+p)/Γ(α)`. For a `Beta(α, β)` variable the `p`-th moment is
`m(α,β) = Γ(α+p)Γ(α+β) / (Γ(α)Γ(α+β+p)) = f(α)/f(α+β)`.

With the chaining `α_{j+1} = α_j + β_j` the product of moments telescopes:

| k | product ∏_{j<k} m(α_j,β_j) | closed form f(α_0)/f(α_k) |
|---|-----------------------------|----------------------------|
| 1 | f(α_0)/f(α_1)               | f(α_0)/f(α_1) ✓            |
| 2 | f(α_0)/f(α_1)·f(α_1)/f(α_2) | f(α_0)/f(α_2) ✓            |
| 3 | …·f(α_2)/f(α_3)             | f(α_0)/f(α_3) ✓            |

Numerical sanity check with `α_0 = 1`, constant `β_j = 1` (so `α_j = 1 + j`),
`p = 1`: each `m = α_j/(α_j+1) = (j+1)/(j+2)`, product over `j<k` telescopes to
`1/(k+1) = f(1)/f(k+1)`, matching `Γ(2)Γ(k+1)/(Γ(1)Γ(k+2)) = 1/(k+1)`. ✓

This is exactly the identity `betaProduct_moment_telescope`.

## 2. Pochhammer / rising-factorial closed form

`Γ(x+n)/Γ(x) = ∏_{i<n}(x+i)`. Check `x=1`: `Γ(1+n)/Γ(1) = n! = ∏_{i<n}(1+i)`. ✓
This is `Real.Gamma_ratio_eq_prod` and is the deterministic growth factor of the
ancestry-process expectation, whose leading order produces the `n^{d/(d+1)}`
scaling exponent (`d/(d+1)` arises from the ratio of successive Pochhammer terms).

## 3. Joint-descendant collapse (graph model)

Explicit small DAGs where each new vertex attaches to earlier ones (so
`n ⇝ n+1 ⇝ ⋯`):

* Path `0→1→2→3`, last `k=3` vertices `{1,2,3}`:
  `desc(1)={1,2,3}, desc(2)={2,3}, desc(3)={3}`; intersection `= {3} = desc(3)`. ✓
* Binary recursive tree (each vertex points to its two later children's parents):
  the consecutive chain still holds, intersection equals `desc(last)`. ✓

Counterexample hunt: dropping the chain hypothesis (a later vertex NOT reachable
from an earlier one) breaks the collapse — e.g. two incomparable sources have a
strictly smaller common-descendant set than either descendant set. This confirms
the chain hypothesis in `jointDescendants_eq_last` is load-bearing, not decorative.

## OEIS
The `p=1`, unit-increment product `1/(k+1)` is the reciprocal of the naturals
(A000027 shifted); no deeper sequence is claimed. Evidence kept intentionally
minimal and directly tied to the two formalized theorems.
