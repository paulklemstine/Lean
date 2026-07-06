# Computational Evidence — Colorful Carathéodory for Spanning k-trees

This note records the small-case computational checks that motivated the formal
development in `ColorfulCaratheodoryLine.lean`, `ColorfulJoinReduction.lean`, and
`ColorfulJoinSpanningNecessary.lean`.

## 1. Sign-extraction on the line

Claim: if a finite set `S ⊆ ℝ` has `0 ∈ conv(S)`, then `S` contains a point `≤ 0`
and a point `≥ 0`.

| S            | conv(S)      | has ≤0? | has ≥0? | 0 ∈ conv(S)? |
|--------------|--------------|---------|---------|--------------|
| {-1, 3}      | [-1, 3]      | yes     | yes     | yes          |
| {2, 5}       | [2, 5]       | no      | yes     | no           |
| {-4, -1}     | [-4, -1]     | yes     | no      | no           |
| {0}          | {0}          | yes     | yes     | yes          |

The pattern is exact: `0 ∈ conv(S) ⇔ (∃ x∈S, x≤0) ∧ (∃ y∈S, y≥0)`.  The forward
direction is what `exists_le_zero_of_zero_mem_convexHull` and its dual formalize,
via separating `0` from a one-signed set by the halfline `(0, ∞)`.

## 2. Rainbow edge on the line (d = 1 colorful Carathéodory)

Color classes `V₁, V₂ ⊆ ℝ`, each straddling `0`.  We seek `a ∈ V₁, b ∈ V₂` with
`0 ∈ [a, b]` (as a segment).

| V₁        | V₂        | rainbow edge (a, b) | 0 ∈ [a,b]? |
|-----------|-----------|---------------------|------------|
| {-1, 3}   | {2, -5}   | (-1, 2)             | yes        |
| {-2, 1}   | {-3, 4}   | (-2, 4)             | yes        |
| {-1, 3}   | {1, 4}    | — (V₂ one-signed)   | hypothesis fails |

Whenever both classes straddle `0`, taking a nonpositive vertex of one color and a
nonnegative vertex of the other yields an edge whose segment contains `0`.  This is
`colorful_caratheodory_line`.

## 3. Join membership of rainbow transversals (any dimension)

Two colors, `V₁ = {a₀, a₁}`, `V₂ = {b₀, b₁}`.  Spanning complexes contain all four
singletons.  Enumerating faces of the join `T₁ * T₂`, every transversal `{aᵢ, bⱼ}`
appears as a face:

```
{a0,b0}, {a0,b1}, {a1,b0}, {a1,b1}   — all present (spanning)
```

This confirms `transversal_mem_join`: for spanning complexes, a rainbow transversal
is always a face.  The dimension plays no role in this combinatorial fact.

## 4. Counterexample hunt — is spanning necessary?

We drop spanning: keep only the *positive* vertex of each color (a point complex).

```
V₁ = {-1, +1}, T₁ = subsets of {+1}      (not spanning: {-1} missing)
V₂ = {-1, +1}, T₂ = subsets of {+1}      (not spanning: {-1} missing)
```

Both classes still satisfy `0 ∈ conv(Vᵢ) = [-1, 1]`.  But every face of the join is
a subset of `{+1 vertices}`, whose image is `⊆ {+1}`; hence `0` is separated from
every face image by the halfline `(0, ∞)`.  **No face contains `0`.**  This is the
content of `spanning_is_necessary`: the spanning hypothesis is load-bearing.

## Conclusion

All finite checks are consistent with the three formalized theorems.  No
counterexample to the spanning-hypothesis versions was found; a clean counterexample
to the *non*-spanning version was found and formalized.
