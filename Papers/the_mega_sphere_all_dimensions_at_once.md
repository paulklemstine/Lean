# Computational Evidence

## Small-case calculations

For the finite Boolean stages `X_n = 𝔽₂^(n+1)`, the first cardinalities are:

| stage `n` | coordinates | cardinality |
|---:|---:|---:|
| 0 | 1 | 2 |
| 1 | 2 | 4 |
| 2 | 3 | 8 |
| 3 | 4 | 16 |
| 4 | 5 | 32 |

The bonding map deletes the last coordinate. Every vector in `X_n` has exactly two lifts to `X_(n+1)`, obtained by appending either `0` or `1`. A coherent point is therefore determined by one new Boolean choice at each stage.

The first Bernoulli numbers relevant to the generating package are
`B₀ = 1`, `B₁ = -1/2`, `B₂ = 1/6`, `B₃ = 0`, and `B₄ = -1/30`.
The first Stiefel–Whitney monomials in the polynomial model are
`1, w, w², w³, w⁴`; none vanishes.

## OEIS search results

The stage-cardinality sequence `2, 4, 8, 16, 32, …` is OEIS A000079 with its initial `1` omitted. The Bernoulli numerators and denominators are standard Bernoulli-number sequences, but no sequence identification is needed by the stated results.

## Counterexample hunt

The literal proposal that ordinary spheres of all dimensions automatically form an inverse system fails at the specification level: an inverse limit requires selected bonding maps `S^(n+1) → S^n`, and no such maps were supplied. Different choices can yield different limits.

Two representative pathological controls are already known. Zero bonding maps can make an inverse limit trivial even when every stage is nontrivial, and multiplication by `2` on integer stages also produces a trivial limit. These controls motivate the surjective coordinate-deletion maps used here.

## Structural table

| proposal | outcome | reason |
|---|---|---|
| finite Boolean coordinate tower | survives | bonding maps are explicit and surjective |
| one coherent object recovers every finite Boolean stage | survives | extension by zero proves projection surjectivity |
| limit equals countable Boolean product | survives | diagonal extraction and assembly are inverse |
| Bernoulli numbers literally are homology groups of this limit | rejected | no supporting homology construction or grading match |
| polynomial Stiefel–Whitney model as an independent universal package | survives | every generator power is nonzero |
