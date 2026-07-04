# Computational Evidence: choosability vs. colourability

## 1. The topic conjecture is false (small-case reasoning)

The mission conjecture — *every 3-colourable planar graph is 4-choosable* — is refuted by
Mirzakhani's explicit 63-vertex planar graph, which is 3-colourable but not 4-choosable.
We therefore reframed the study around the honest question: **which parameter, if any,
bounds the list chromatic number**, and produced a small fully-verified witness of the
divergence between colourability and choosability.

## 2. `K_{2,4}` is 2-colourable but not 2-choosable (hand computation)

Vertices: small side `{a, b}`, big side `{c0, c1, c2, c3}`; every small–big pair is adjacent.

Diagonal list assignment (all lists size 2):

| vertex | list      |
|--------|-----------|
| a      | {0, 1}    |
| b      | {2, 3}    |
| c0     | {0, 2}    |
| c1     | {0, 3}    |
| c2     | {1, 2}    |
| c3     | {1, 3}    |

Enumerate the small-side choice `(α, β)` with `α ∈ {0,1}`, `β ∈ {2,3}`:

| α | β | blocked big-side vertex (list = {α,β}) |
|---|---|----------------------------------------|
| 0 | 2 | c0 = {0,2}  |
| 0 | 3 | c1 = {0,3}  |
| 1 | 2 | c2 = {1,2}  |
| 1 | 3 | c3 = {1,3}  |

In every case the blocked vertex has both of its two colours forbidden by its two neighbours,
so no proper list colouring exists ⇒ **not 2-choosable**. It is 2-colourable because it is
bipartite. This is the `k = 2` analogue of the (false) topic conjecture, and `K_{2,4}` is
planar — a planar, 2-colourable graph that is not 2-choosable.

## 3. Greedy / degree bound (small-case checks)

Claim: maximum degree `< k` ⇒ `k`-choosable.

- Path `P_n` (Δ = 2): 3-choosable. Colour left-to-right; each vertex has ≤ 2 coloured
  neighbours, list size 3 ⇒ a colour is free. ✓
- Cycle `C_n` (Δ = 2): 3-choosable by the same greedy sweep. ✓
- Star `K_{1,m}` (centre degree `m`): the bound gives `(m+1)`-choosable; in fact stars are
  2-choosable, consistent with (not tight for) the bound. ✓

These match the general theorem `choosable_of_degree_lt`.

## 4. OEIS / sequence note

No integer sequence is central here; the objects are a fixed small graph and a structural
inequality. The relevant "sequence" is the list chromatic number of `K_{k, m}`, which grows
without bound in `m` for fixed `k` (e.g. `K_{2,4}` already exceeds 2), underscoring that
bipartiteness (χ = 2) places no ceiling on choosability.

## 5. Counterexample hunt for the *degree* bound

We attempted to break `choosable_of_degree_lt` by searching for a graph with all degrees
`< k` that is not `k`-choosable: none exists, because the greedy argument is a proof, not a
heuristic. The finite checks above all succeeded, and the Lean proof discharges the general
case.
