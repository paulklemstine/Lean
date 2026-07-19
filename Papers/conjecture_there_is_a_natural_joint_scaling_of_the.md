# Computational Evidence: Finite Prime Occupation Tails

## Small-case calculations

For the retained prime modes `2, 3, 5`, set `q_p = 1/p`.  The completed finite
Euler product is

\[
C=\prod_{p\in\{2,3,5\}}(1-q_p)^{-1}=15/4.
\]

The table compares the occupation product
`T_N = ∏ₚ ∑_{n=0}^N qₚⁿ`, its defect, the normalized defect, and the proposed
additive bound `B_N = ∑ₚ qₚ^(N+1)`.

| `N` | `T_N` | `C-T_N` | `(C-T_N)/C` | `B_N` |
|---:|---:|---:|---:|---:|
| 0 | `1` | `11/4` | `11/15 ≈ 0.733333` | `31/30 ≈ 1.033333` |
| 1 | `12/5` | `27/20` | `9/25 = 0.36` | `361/900 ≈ 0.401111` |
| 2 | `2821/900` | `277/450` | `554/3375 ≈ 0.164148` | `4591/27000 ≈ 0.170037` |
| 3 | `52/15` | `17/60` | `17/225 ≈ 0.075556` | `61921/810000 ≈ 0.076446` |
| 4 | `2929531/810000` | `107969/810000` | `107969/3037500 ≈ 0.035545` | `867151/24300000 ≈ 0.035685` |
| 5 | `138229/37500` | `599/9375` | `2396/140625 ≈ 0.017038` | `12437281/729000000 ≈ 0.017061` |

The exact computations support both nonnegativity of the defect and
`(C-T_N)/C ≤ B_N`.  They also show the union bound becoming asymptotically sharp
as the occupation ceiling increases.

## Counterexample hunt

A rational-arithmetic sweep over all nonempty subsets of `{2,3,5,7,11}` and
occupation ceilings `0 ≤ N ≤ 8` found no violation of the occupation-tail bound.
The hypotheses cannot simply be dropped: allowing a local weight above one can
make `(1-q)⁻¹` negative, so neither positivity nor the stated one-sided estimate
has the intended meaning.

## Sequence databases

No new integer sequence is intrinsic to this estimate: the quantities are
finite products and sums parameterized by an arbitrary retained prime set.
Consequently, an OEIS identification was not pursued.

## Plot-level trend

On a logarithmic vertical scale, the defects for `{2,3,5}` are nearly linear in
`N`, with the slowest local mode `q=1/2` governing the eventual decay.  The bound
tracks this slope and differs only by higher-order products of local tails.
