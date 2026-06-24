# Computational Evidence — Necessity of the Homological Condition

Topic: if a pure `r`-complex saturates `q_{r-1}(K) = t·n − (t−1)(r+1)`, the links
of `(r−t)`-faces must be acyclic (`H̃_t(lk_K σ) = 0`). We formalize the elementary
*necessary numerical shadow* of acyclicity: a cone / apex forces the reduced Euler
characteristic `χ̃ = Σ_σ (−1)^{dim σ}` of the link to vanish.

## 1. Reduced Euler characteristic of small cones

Let `χ̃(K) = Σ_{F face} (−1)^{|F|−1}` (empty face has dimension −1). For a cone
`v ∗ K` with fresh apex `v`, every face `F` of `K` is paired with `F ∪ {v}`, whose
cardinality is one larger.

| base `K`                    | faces of `v∗K` (incl. ∅)                  | χ̃(v∗K) |
|-----------------------------|-------------------------------------------|---------|
| empty complex `{∅}`         | ∅, {v}                                     | 0       |
| single vertex `{∅,{a}}`     | ∅,{a},{v},{a,v}                            | 0       |
| two vertices `{∅,{a},{b}}`  | ∅,{a},{b},{v},{a,v},{b,v}                  | 0       |
| edge `{∅,{a},{b},{a,b}}`    | ∅,{a},{b},{a,b},{v},{a,v},{b,v},{a,b,v}    | 0       |

Each column sums to `0` because `(−1)^{|F|−1} + (−1)^{|F∪{v}|−1} = 0`. This is the
content of `ASC.reducedEuler_cone`.

## 2. The bound `q = t·n − (t−1)(r+1)` and its factorization

Verified identity (`qBound_factor`): `q = (t−1)(n−r−1) + n`.

| t | n | r | q = tn−(t−1)(r+1) | (t−1)(n−r−1)+n |
|---|---|---|-------------------|-----------------|
| 2 | 5 | 2 | 10 − 3 = 7        | 1·2 + 5 = 7     |
| 3 | 6 | 2 | 18 − 6 = 12       | 2·3 + 6 = 12    |
| 2 | 6 | 3 | 12 − 4 = 8        | 1·2 + 6 = 8     |
| 3 | 7 | 3 | 21 − 8 = 13       | 2·3 + 7 = 13    |

Discrete derivatives (`qBound_succ_n`, `qBound_succ_r`): `Δ_n q = t`,
`Δ_r q = −(t−1)`. Confirmed in every row above.

## 3. Codimension bookkeeping (`link_facet_codim`)

For an `(r−t)`-face `σ` (so `|σ| = r−t+1`) inside an `r`-facet `F` (`|F| = r+1`)
with `t ≤ r`: `|F \ σ| = t`. So the link of `σ` inside that facet is a
`(t−1)`-simplex and the homology degree in question is `t`.

| r | t | |σ|=r−t+1 | |F|=r+1 | |F\σ|=t |
|---|---|----------|---------|---------|
| 3 | 1 | 3        | 4       | 1       |
| 4 | 2 | 3        | 5       | 2       |
| 5 | 3 | 3        | 6       | 3       |

## 4. Counterexample hunt

The claim "apex ⇒ χ̃ = 0" was tested against the sign-reversing involution
`F ↦ F △ {w}` on all small complexes above; no counterexample exists because the
toggle is fixed-point-free and parity-flipping. The *converse* fails (χ̃ = 0 does
not imply acyclicity — e.g. a wedge of cancelling cells), which is exactly why the
formal results are stated as *necessary* conditions, never sufficient.

## 5. OEIS

The signed face counts here reduce to the alternating-sum identity
`Σ_k (−1)^k C(m,k) = 0` (the all-cancelling binomial identity), not a new
sequence; no OEIS entry is implicated.
