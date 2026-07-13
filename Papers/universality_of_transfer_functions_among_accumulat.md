# Computational Evidence

We model `Π^k_ℓ` as the additive subgroup `ℓ · ℤ[1/k] = { ℓ·a/kᵐ : a ∈ ℤ, m ∈ ℕ } ⊆ ℝ`
and a *transfer function* as a translation `x ↦ x + c` with `c ∈ Π^k_ℓ`. The claim is:
between any two accumulation points `α, β ∈ Π^k_ℓ` there is a transfer function with
`f α = β`.

## 1. Small cases

Every point of `Π^k_ℓ` is an accumulation point (the set is dense in `ℝ`), so the claim
reduces to: for `α, β ∈ Π^k_ℓ`, the translation by `c = β − α` sends `α` to `β` and
preserves `Π^k_ℓ`. This requires `β − α ∈ Π^k_ℓ`, i.e. that `Π^k_ℓ` is closed under
subtraction. Sample checks (`k = 3, ℓ = 1`, so `Π = ℤ[1/3]`):

| α        | β        | c = β − α      | c ∈ Π ?                      |
|----------|----------|----------------|------------------------------|
| 1/3      | 2/9      | −1/9           | yes (a=−1, m=2)              |
| 5/27     | 1        | 22/27          | yes (a=22, m=3)              |
| 4/9      | −7/3     | −25/9          | yes (a=−25, m=2)             |

For `k = 4, ℓ = 2` (`Π = 2·ℤ[1/4]`, elements `2a/4ᵐ`):

| α        | β        | c = β − α      | c = 2a/4ᵐ ?                  |
|----------|----------|----------------|------------------------------|
| 2        | 1/2      | −3/2           | yes: 2·(−3)/4¹ = −3/2        |
| 2/16     | 6/4      | 22/16          | yes: 2·11/4² = 22/16         |

In every case `c` lies back in the set, confirming closure under subtraction, which is the
only nontrivial ingredient of universality.

## 2. Density spacing

For the perfectness/accumulation claim, the grid `Π^k_ℓ` at "resolution" `m` has spacing
`ℓ/kᵐ`, which tends to `0` since `k ≥ 2`. Hence every real is approximated arbitrarily
well: for target `x` and tolerance `r`, choosing `m` with `ℓ/kᵐ < r` and
`a = ⌊x·kᵐ/ℓ⌋` gives `|ℓa/kᵐ − x| < ℓ/kᵐ < r`. Example (`k=3, ℓ=1`, `x=π`):

| m | ℓ/3ᵐ    | nearest ⌊π·3ᵐ⌋/3ᵐ | error       |
|---|---------|-------------------|-------------|
| 1 | 0.333   | 9/3 = 3.000       | 0.1416      |
| 3 | 0.037   | 84/27 ≈ 3.1111    | 0.0305      |
| 6 | 0.00137 | 2290/729 ≈ 3.1413 | 0.00027     |

The error stays below the spacing, as predicted.

## 3. Counterexample hunt

The only way universality could fail is if `β − α ∉ Π^k_ℓ` for some `α, β ∈ Π^k_ℓ`.
Since `Π^k_ℓ = ℓ·ℤ[1/k]` is an additive subgroup of `ℝ`, this never happens: for any
`ℓa/kᵐ, ℓb/kⁿ` their difference is `ℓ(a·kⁿ − b·kᵐ)/kᵐ⁺ⁿ ∈ Π^k_ℓ`. No counterexample
exists. This closure identity is exactly what `sub_mem_Pi` proves in Lean.

## Conclusion

The numerics support both halves of the formal result: (i) `Π^k_ℓ` is a dense subgroup, so
every element is an accumulation point; (ii) translation by `β − α` is a transfer function
carrying `α` to `β`. Both are proved with `0` sorries in
`Applications/TransferUniversality.lean`.
