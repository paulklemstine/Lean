# Computational Evidence

The investigation concerns symbolic asymptotic and order-theoretic laws rather than a single numerical deductive system. Small cases nevertheless expose the relevant competing behaviors.

## Small-case calculations

For ambient growth `k = 4`, derivable growth `a = 2`, and prefactor `C = 1`, the comparison density is `(a/k)^n = 2^{-n}`:

| `n` | ambient count `4^n` | derivable bound `2^n` | ratio bound |
|---:|---:|---:|---:|
| 0 | 1 | 1 | 1 |
| 1 | 4 | 2 | 1/2 |
| 2 | 16 | 4 | 1/4 |
| 3 | 64 | 8 | 1/8 |
| 4 | 256 | 16 | 1/16 |
| 5 | 1024 | 32 | 1/32 |

At level `ε = 0.1`, the last index at or above the level is `c = 3`; every `n > 3` is below it. This illustrates the least-crossing construction used in the threshold theorem.

For the normalized geometric length law with `k = 2`, the first weights are `1/2, 1/4, 1/8, 1/16, 1/32`. Their successive ratio is always `1/2 = exp(-log 2)`.

## Sequence search

The ambient exact-length counts are geometric sequences, and the cumulative counts are geometric sums. No specialized sequence identification is needed: the formulas determine all terms directly.

## Counterexample hunt

Two overstrong claims fail immediately.

1. Monotonicity alone does not force a crossing: the constant sequence `r(n) = 1` never crosses `ε = 1/2`.
2. A geometric law is not a power law in length: its successive ratio is constant below one, whereas `(n+1)^{-α}/n^{-α}` tends to one for every fixed positive `α`.

These counterexamples motivate the convergence hypothesis in the finite-threshold theorem and the rejection of a direct power-law interpretation.

## Table of qualitative outcomes

| Candidate claim | Outcome | Boundary |
|---|---|---|
| Sparse derivability with positive ambient entropy | Survives | Requires separated exponential rates |
| Exact finite crossing | Survives | Requires convergence to zero, antitonicity, and a positive level |
| Unique critical index | Survives | Requires a strict one-step crossing |
| Geometric tail is a power law in length | Fails | A mixture of entropy rates may produce heavy tails |
| Named major theorems define a universal threshold | Undetermined | Requires an encoding and structural counting hypotheses |
