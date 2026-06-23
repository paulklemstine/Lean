# Computational Evidence — Attention Mechanisms

Concise pre-proof sanity checks for the formal results in this directory.

## 1. Softmax realizes the open simplex (`softmax_realizes_simplex`)
Take `p = (0.2, 0.3, 0.5)`. Then `log p ≈ (-1.609, -1.204, -0.693)`.
`exp(log p) = (0.2, 0.3, 0.5)`, and `∑ exp(log p) = 1`, so
`softmax(log p) = (0.2, 0.3, 0.5) = p`. The identity holds exactly (no temperature),
confirming surjectivity onto the strictly-positive simplex. The boundary (`p_i = 0`)
is unreachable since every softmax weight is `> 0`.

## 2. Attention-sink lower bound (`attention_sink_lower_bound`)
Weights `w_i = exp(z_i)/∑ exp(z_j)` with a dominant token `i₀` having gap `g` over all
others. Bound: `w_{i₀} ≥ 1/(1 + (n-1) e^{-g})`. Small cases:

| n   | g = log n        | (n-1)e^{-g}=(n-1)/n | bound 1/(1+(n-1)/n) |
|-----|------------------|---------------------|---------------------|
| 2   | 0.693            | 0.500               | 0.667               |
| 10  | 2.303            | 0.900               | 0.526               |
| 100 | 4.605            | 0.990               | 0.503               |
| 1e6 | 13.816           | ≈1.000              | 0.500⁺              |

So with a *logarithmic* gap `g = log n` the sink keeps `> 1/2` of the attention mass for
every context length — matching `attention_sink_persists`. Without the gap (uniform logits)
each weight is exactly `1/n → 0` (`softmax_uniform`, `softmax_uniform_dilution`).

This is the sharp contrast underlying the "attention sink": dilution `1/n` for generic
tokens vs. `Ω(1)` persistence for a token whose logit lead grows like `log n`.

## 3. Rank collapse (`attnMatrix_constRows_rank_le_one`)
If all queries are identical, every row of the `n×n` attention matrix equals the same
stochastic vector `r`, i.e. `A = 1·rᵀ`, an outer product of rank ≤ 1. Numerically, for
`r = (0.2,0.3,0.5)` the 3×3 matrix with all rows `r` has determinant 0 and a single
nonzero singular value, confirming rank 1.

## 4. Hull confinement (`attnOutput_mem_Icc`)
With values `V = (1, 5, 3)` (one coordinate) and any weights summing to 1, the output
`∑ w_j V_j` always lies in `[1, 5]`; e.g. weights `(0.5,0.1,0.4)` give `2.2 ∈ [1,5]`.
A convex combination cannot escape the coordinatewise min/max — the Nadaraya–Watson
kernel-smoother property.

No counterexamples were found; all conjectures proceeded to formal proof.
