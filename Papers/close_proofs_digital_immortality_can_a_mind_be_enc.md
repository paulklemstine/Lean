# Computational Evidence — Mind Encoding, Refined

All claims are combinatorial identities/inequalities about the connectome model
`synapseSlots N = C(N,2)`. They are cheap to check numerically; the checks below
are also encoded as `decide`-verified `example`s inside
`Catalog/Novelty/MindEncodingRefined.lean`.

## 1. Slot counts `synapseSlots N = C(N,2)`

| N  | synapseSlots N | 2^slots (# connectomes) |
|----|----------------|-------------------------|
| 0  | 0              | 1                       |
| 1  | 0              | 1                       |
| 2  | 1              | 2                       |
| 3  | 3              | 8                       |
| 4  | 6              | 64                      |
| 5  | 10             | 1024                    |
| 6  | 15             | 32768                   |
| 10 | 45             | 2^45 ≈ 3.5e13           |

Quadratic growth is evident; `2·slots` is sandwiched by `(N-1)^2` and `N^2`.
This is OEIS A000217-shifted (triangular numbers): `C(N,2) = 0,0,1,3,6,10,15,...`
(A000217 offset). The connectome counts `1,1,2,8,64,1024,32768,...` are
`2^A000217`.

## 2. Superadditivity of merging `C(M+N,2) = C(M,2)+C(N,2)+M·N`

| M | N | C(M,2) | C(N,2) | M·N | sum | C(M+N,2) |
|---|---|--------|--------|-----|-----|----------|
| 3 | 4 | 3      | 6      | 12  | 21  | 21       |
| 5 | 5 | 10     | 10     | 25  | 45  | 45       |
| 2 | 7 | 1      | 21     | 14  | 36  | 36       |

The identity holds in every sampled case (and is proved in general as
`synapseSlots_add`). The `M·N` term is exactly the number of new cross-brain
synapse slots created by merging.

## 3. Directionality squares the count `2^(N(N-1)) = (2^C(N,2))^2`

| N | directedSlots = N(N-1) | 2^directed | (2^C(N,2))^2 |
|---|------------------------|------------|--------------|
| 3 | 6                      | 64         | 8^2 = 64     |
| 4 | 12                     | 4096       | 64^2 = 4096  |

Matches (proved as `directed_count_sq`).

## 4. Incompressibility counting bound

For an injective code `enc : Connectome N → ℕ`, the number of connectomes with
`enc c < B` is at most `B` (a pigeonhole into `range B`). Hence at least
`2^C(N,2) − B` connectomes have `enc c ≥ B`. Sampled at `N=4` (64 connectomes),
`B=32`: at most 32 fall below 32, so ≥ 32 sit at or above — a full half, matching
`most_incompressible`.

## 5. Counterexample hunt

No counterexamples were found for any of the universal statements on
`0 ≤ M,N ≤ 30`. The edge cases `N = 0, 1` (zero slots) are exactly where the
real bound `((N:ℝ)-1)^2` is tightest and motivate the `1 ≤ N` hypothesis in the
physical corollaries `neuron_count_bound` / `neuron_count_sqrt_bound`.
