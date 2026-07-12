# Computational Evidence — Neural Coding Theorems

All claims formalized in `NeuralCoding.lean` are exact combinatorial / algebraic
identities, so the "evidence" below is small-case verification of the closed
forms before formalization.

## 1. Coding capacity `2^N` and the doubling law

| N | #codes `Fin N → Bool` = 2^N |
|---|-----------------------------|
| 0 | 1  |
| 1 | 2  |
| 2 | 4  |
| 3 | 8  |
| 4 | 16 |
| 5 | 32 |

Each step doubles (`card_neuralCode_succ`). Sequence = OEIS A000079 (powers of 2).

## 2. Weight-`k` (sparse) code counts = `C(N, k)`

For `N = 4`, counting `c : Fin 4 → Bool` by number of `true`s:

| weight k | count | C(4,k) |
|----------|-------|--------|
| 0 | 1 | 1 |
| 1 | 4 | 4 |
| 2 | 6 | 6 |
| 3 | 4 | 4 |
| 4 | 1 | 1 |

Row sums to 16 = 2^4 (Pascal's triangle, OEIS A007318). Confirms `card_sparse`
and `card_grandmother` (weight 1 → N codes).

## 3. Total / average weight

Sum of weights over all 2^N codes:

| N | Σ weight | N·2^(N-1) | average = N/2 |
|---|----------|-----------|---------------|
| 1 | 1  | 1  | 0.5 |
| 2 | 4  | 4  | 1.0 |
| 3 | 12 | 12 | 1.5 |
| 4 | 32 | 32 | 2.0 |

Matches `total_weight` and `average_weight` (mean dense energy `= N/2`).
(For N=4: Σ = 0·1+1·4+2·6+3·4+4·1 = 32.) Sequence N·2^(N-1) = OEIS A001787.

## 4. Population precision `∝ 1/√N`

`popPrecision v N = √v / √N`. With `v = 1`:

| N | 1/√N | 4N halving check |
|---|------|------------------|
| 1 | 1.000 | popPrecision(4) = 0.5 = popPrecision(1)/2 ✓ |
| 4 | 0.500 | popPrecision(16) = 0.25 = popPrecision(4)/2 ✓ |
| 16| 0.250 | |

Confirms `popPrecision_quarter` and monotone decrease `popPrecision_antitone`.

## 5. Sparse energy efficiency (bits per spike)

* Dense rate = `log₂(2^N) / (N/2) = N / (N/2) = 2` bits/spike (constant).
* One-hot sparse rate = `log₂ N / 1 = log₂ N` bits/spike.

| N | dense rate | sparse rate log₂N | sparse wins? |
|---|-----------|-------------------|--------------|
| 4 | 2 | 2.00 | tie |
| 5 | 2 | 2.32 | yes |
| 8 | 2 | 3.00 | yes |
| 16| 2 | 4.00 | yes |
| 1024 | 2 | 10.00 | yes |

Crossover at N = 4, strict advantage for N ≥ 5 (`sparse_more_efficient`),
unbounded as N → ∞ (`sparse_rate_tendsto_atTop`).

## 6. Manifold dimension bound

`neural_manifold_dim_le_dof`: for a linear behaviour→activity map
`ℝ^d → ℝ^N`, `dim(range) ≤ d`. E.g. a 2-DOF reaching task (d=2) recorded from
N=100 neurons has neural activity confined to a subspace of dimension ≤ 2.
This is the rank–nullity bound and needs no numerical search.

## Counterexample hunt

No universal claim admitted a counterexample in the ranges checked (N up to a few
thousand for the numeric rates; all algebraic identities are exact). The
crossover point N = 4 for dense-vs-sparse efficiency was located exactly and is
reflected in the `5 ≤ N` hypothesis of `sparse_more_efficient`.
