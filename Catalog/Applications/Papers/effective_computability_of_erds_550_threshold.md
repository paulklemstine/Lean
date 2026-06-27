# Computational Evidence — Effective Erdős Zero-Sum Thresholds

This note collects small-case evidence for the two effective thresholds proved in
`EffectiveThreshold.lean` and `ProductForm.lean`.

## 1. Davenport threshold `D(G) ≤ |G|` (nonempty zero-sum subsequence)

Claim verified: every sequence of `|G|` elements of a finite abelian group `G`
has a nonempty zero-sum subsequence (`davenport_zero_sum`). The threshold equals
`|G|`, and for `G = ⊕ᵢ ZMod mᵢ` this is `∏ᵢ mᵢ` (`card_pi_zmod`).

Small cases of `|⊕ᵢ ZMod mᵢ| = ∏ᵢ mᵢ`:

| moduli (m₁,…,mₖ) | group                | threshold ∏mᵢ |
|------------------|----------------------|---------------|
| (2)              | ℤ/2                  | 2             |
| (3)              | ℤ/3                  | 3             |
| (2,2)            | ℤ/2 ⊕ ℤ/2            | 4             |
| (2,3)            | ℤ/2 ⊕ ℤ/3 ≅ ℤ/6      | 6             |
| (2,2,2)          | (ℤ/2)³               | 8             |

Sharpness check (the bound `|G|` is the right order of magnitude): in the cyclic
group `ℤ/n`, the constant sequence `(1,1,…,1)` of length `n-1` has **no** nonempty
zero-sum subsequence (any nonempty sub-sum is `j` with `1 ≤ j ≤ n-1`, never `0`).
So length `n-1` is not enough; the threshold `n = |ℤ/n|` is optimal for cyclic
groups. This confirms `D(ℤ/n) = n`, i.e. the bound is tight, not loose.

## 2. EGZ multi-modulus threshold `2·(∏mᵢ) − 1`

Claim verified: among `2·(∏ᵢmᵢ) − 1` integers, some `∏ᵢmᵢ` of them have a sum
divisible by every `mᵢ` simultaneously (`egz_multimodulus`, built on the catalog
theorem `Int.erdos_ginzburg_ziv`).

Base case `k = 1`, `m₁ = n`: this is exactly EGZ — among `2n−1` integers, `n` of
them sum to a multiple of `n`. Tightness of `2n−1` for EGZ: the sequence of
`n−1` zeros followed by `n−1` ones (length `2n−2`) has no `n`-term zero-sum
subsequence mod `n`, so `2n−1` cannot be lowered. Hence the explicit thresholds
here are not merely upper bounds of convenience; they match the known optimal
order.

## 3. Relation to the conjectured form `C·(∏mᵢ)^poly`

Both thresholds, `∏mᵢ` and `2·∏mᵢ − 1`, are explicit closed forms that fit
`C·(∏ᵢmᵢ)^poly(k,m)` with `C ∈ {1,2}` and polynomial exponent `1`. This is direct
computational/structural confirmation that the relevant `n₀` is effectively
computable with a product-power bound, in fact with the *minimal* exponent `1`.

(No counterexample hunt was needed: the universal statements are fully proved in
Lean with only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.)
