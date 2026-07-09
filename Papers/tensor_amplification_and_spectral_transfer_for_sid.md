# Computational Evidence: Tensor Amplification and Spectral Transfer

All computations use the weighted-graph model: a weighted graph on `n` vertices is a symmetric
`n × n` matrix `A`, with edge density `t(K₂,A) = (∑ᵢⱼ Aᵢⱼ)/n²` and cycle density
`t(Cₖ,A) = tr(Aᵏ)/nᵏ`.

## 1. Small-case calculations

Take the symmetric weighted graph
```
A = [ 1  2 ]
    [ 2  3 ]      (n = 2)
```
Then `∑ᵢⱼ Aᵢⱼ = 8`, `tr(A²) = 18`, `tr(A⁴) = 322`, so

| quantity            | value |
|---------------------|-------|
| edge density `t(K₂)`| `8/4 = 2` |
| `C₂` density `t(C₂)`| `18/4 = 9/2` |
| `C₄` density `t(C₄)`| `322/16 = 161/8` |

* **C₂ surplus** `t(C₂) − t(K₂)² = 9/2 − 4 = 1/2 > 0`  ✔
* **C₄ surplus** `t(C₄) − t(K₂)⁴ = 161/8 − 16 = 33/8 > 0`  ✔

Both even-cycle Sidorenko inequalities hold strictly on this example, consistent with
`sidorenko_two` and `sidorenko_four`.

## 2. Spectral transfer (tensor multiplicativity)

For the same `A`, direct computation gives
```
tr((A ⊗ A)³) − tr(A³)²  =  0
tr((A ⊗ A)⁴) − tr(A⁴)²  =  0
```
confirming the identity `tr((A ⊗ B)ᵏ) = tr(Aᵏ)·tr(Bᵏ)` (theorem `homCycle_kron`) — the algebraic
heart of the framework.

## 3. Amplification

Because the Sidorenko ratio `R = t(Cₖ)/t(K₂)ᵏ` is multiplicative under the tensor product, the
self-tensor square satisfies `R(A ⊗ A) = R(A)²`. For the example above with `k = 4`,
`R(A) = (161/8)/16 = 161/128 ≈ 1.258 > 1`, and `R(A ⊗ A) = R(A)² ≈ 1.582 > R(A)`: a genuine
surplus is strictly amplified, matching `sidRatio_amplify_gt`. A deficit `0 < R < 1` would instead
be driven towards `0` (`sidRatio_amplify_lt`).

## 4. Counterexample hunt

The even-cycle claims were tested on random symmetric integer matrices of sizes `n = 2,3,4`
(including matrices with negative entries): the `C₂` and `C₄` surpluses were nonnegative in every
case, in agreement with the sign-free proofs. Odd cycles were deliberately excluded — `C₃` violates
Sidorenko for suitable weightings, matching the classical bipartite restriction — so no odd-cycle
claim is made.

## Summary

The computational evidence supports (a) both even-cycle base inequalities, (b) exact tensor
multiplicativity of closed-walk counts, and (c) the multiplicative amplification law for the
Sidorenko ratio. All three are established rigorously in the accompanying development.
