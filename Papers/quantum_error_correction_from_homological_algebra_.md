# Computational Evidence: Hypercube Homological Codes

## Small-case calculations

The hypercube graph `Qₙ` has `V = 2ⁿ` vertices and `E = n·2ⁿ⁻¹` edges and is
connected, so its first Betti number (circuit rank), equal to the number of
logical qubits of `HQECC(Qₙ)`, is `β₁ = E − V + 1`:

| n | V = 2ⁿ | E = n·2ⁿ⁻¹ | β₁ = E − V + 1 | closed form 2ⁿ⁻¹(n−2)+1 |
|---|--------|------------|----------------|--------------------------|
| 0 | 1      | 0          | 0              | —                        |
| 1 | 2      | 1          | 0              | 2⁰·(−1)+1 = 0            |
| 2 | 4      | 4          | **1**          | 2¹·0+1 = 1               |
| 3 | 8      | 12         | 5              | 2²·1+1 = 5               |
| 4 | 16     | 32         | **17**         | 2³·2+1 = 17             |
| 5 | 32     | 80         | 49             | 2⁴·3+1 = 49             |
| 6 | 64     | 192        | **129**        | 2⁵·4+1 = 129           |
| 7 | 128    | 448        | 321            | 2⁶·5+1 = 321           |
| 8 | 256    | 1024       | **769**        | 2⁷·6+1 = 769           |

The mission's test cases `Q₄, Q₆, Q₈` give `17, 129, 769` logical qubits — **not**
`1`. The value `β₁ = 1` occurs uniquely at `n = 2` (the 4-cycle).

## Counterexample hunt

The universal claim "HQECC(Qₙ) encodes 1 qubit for all n" is refuted by the very
first non-boundary case `n = 3` (β₁ = 5) and every larger `n`. The claim's only
truthful instance is the boundary case `n = 2`. This is captured formally by
`Hypercube.betti1_eq_one_iff` (`β₁ = 1 ↔ n = 2`) and `Hypercube.betti1_ge_five`
(`n ≥ 3 ⟹ β₁ ≥ 5`).

## OEIS

The Betti sequence `0, 0, 1, 5, 17, 49, 129, 321, 769, …` is
`a(n) = (n−2)·2ⁿ⁻¹ + 1` (for `n ≥ 1`), matching the circuit rank of the
`n`-cube graph.

## Method

All entries above are reproduced by evaluating the defined function `betti1` and
are certified by the accompanying proofs (`betti1_closed`, and the exact
evaluations `betti1_four`, `betti1_six`, `betti1_eight`). The distance parameter
is left to `FUTURE_DIRECTIONS.md`; the encoded-dimension parameter, the focus of
this cycle, is fully settled.
