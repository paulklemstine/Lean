# Computational Evidence — `q`-ary Coset-Guesswork Exponent

This note records the small-case checks that preceded the formal development in
`QaryCosetExponent.lean`.

## 1. The base-`q` power-sum sandwich

Claim: for integer base `q ≥ 2`, exponent `ρ ≥ 0` and `j ≥ 1`,

```
q^{(j-1)(ρ+1)}  ≤  Σ_{k=1}^{q^j} k^ρ  ≤  q^{j(ρ+1)}.
```

Direct evaluation with `ρ = 3` (so `Σ_{k=1}^N k^3 = (N(N+1)/2)^2`):

| `q` | `j` | `N = q^j` | lower `q^{(j-1)(ρ+1)}` | `Σ k^3` | upper `q^{j(ρ+1)}` |
|----:|----:|----------:|-----------------------:|--------:|-------------------:|
| 3   | 2   | 9         | `3^4 = 81`             | `2025`  | `3^8 = 6561`       |
| 4   | 2   | 16        | `4^4 = 256`            | `18496` | `4^8 = 65536`      |
| 2   | 3   | 8         | `2^8 = 256`            | `1296`  | `2^12 = 4096`      |

All three rows satisfy `lower ≤ Σ ≤ upper`, confirming the growth exponent `ρ+1`.
(Reproduced in Lean with `#eval` over `ℚ`.)

## 2. The redundancy shift

Normalising to base `q`, the constrained moment `M_q(k_m) = q^{-k_m} Σ_{j=1}^{q^{k_m}} j^ρ`
has `(1/m) log_q M_q(k_m) → ρR` when `k_m/m → R`. Numerically, with `ρ = 2`, `q = 3`,
`R = 1/2`, taking `m = k_m·2` and `k_m` growing, the finite-`m` estimate approaches
`ρR = 1`, matching the closed form. The unconstrained case `R = 1` approaches `ρ = 2`,
so the observed gap is `ρ - ρR = 1 = ρ(1-R)`.

## 3. Rényi entropy of the uniform law

For the uniform law on `q` letters, `Σ_i (1/q)^α = q^{1-α}`, hence
`H_α^{(b)} = (1-α)^{-1} log_b q^{1-α} = log_b q`, independent of `α`. Checked for
`q ∈ {2,3,4}`, `α ∈ {1/2, 1/3, 2}`: the ratio `H_α^{(q)}` equals `1` in every case, i.e.
one symbol's worth of entropy per symbol, as expected at maximal entropy.

## 4. OEIS / counterexample hunt

No new integer sequence is introduced; the objects are the classical power sums
`Σ k^ρ` (for integer `ρ`, e.g. `A000537` for `ρ = 3`). A sweep over
`q ∈ {2,…,6}`, `j ∈ {1,…,5}`, `ρ ∈ {1,2,3}` found **no** violation of the sandwich,
supporting the universal claim that the exponent shift is alphabet-independent.
