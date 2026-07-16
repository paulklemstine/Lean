# Computational Evidence

The main claims are structural rather than numerical, so exhaustive computation is not the proof method. Small finite approximations nevertheless clarify the proposed fixed point.

## Small cases

For the unary self-loop unravelling, let `p_n` be the address consisting of `n` zeros. The formally proved theorem `selfUnravelling_spine` yields:

| depth `n` | address `p_n` | label present? |
|---:|---|---|
| 0 | `[]` | yes |
| 1 | `[0]` | yes |
| 2 | `[0,0]` | yes |
| 3 | `[0,0,0]` | yes |
| 4 | `[0,0,0,0]` | yes |
| 5 | `[0,0,0,0,0]` | yes |

An address containing a nonzero child index is absent by the definition of `selfUnravelling`. The depth-`n` truncation therefore contains exactly the unary prefix through depth `n`.

For a proposed strict ordinal ranking of a directed cycle of length `k`, the edges demand

`r(v₁) < r(v₀), …, r(v₀) < r(vₖ₋₁)`.

Already for lengths 1, 2, 3, and 4, transitivity closes this into `r(v₀) < r(v₀)`. The Lean theorem `no_ranked_cycle` proves this uniformly for every finite length, rather than by bounded testing.

## OEIS search

No OEIS search is applicable. The only elementary count in the unary example is one observed node at each depth, the constant sequence `1,1,1,…`; sequence identification would add no mathematical evidence.

## Counterexample hunt

The universal suggestion that “a self-reference converges if it occurs at a strictly smaller ordinal” fails at the smallest representative case: a one-node self-loop would require `rank(i) < rank(i)`. `self_loop_has_no_ranking` is a kernel-checked general proof of this counterexample for every node type and every dependency relation containing such a loop.

The claim that `P → P` requires a non-well-founded proof also fails under ordinary natural deduction: introduction followed by the hypothesis rule has height exactly one, as proved by `identityDerivation_height`.
