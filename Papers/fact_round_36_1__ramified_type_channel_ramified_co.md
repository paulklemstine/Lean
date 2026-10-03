# Computational evidence — RAMIFIED-CONTRIBUTION-IS-NEGLIGIBLE (paper 128)

**Status:** these numbers come from an exploratory floating-point `#eval` script that is
not part of the catalog. They are evidence only, not a formal verification. The formal
results are the theorems in `Catalog/Probability/RamifiedTypeChannel*.lean`.

## Setup

- Polynomial `x² − 3`, discriminant 12. The ramified primes are `{2, 3}`.
- Splitting type `T(p)`: *ramified* for p ∈ {2,3}, *split* if `p ≡ ±1 (mod 12)`, *inert*
  otherwise.
- Channel: `I(T ; p mod 12)`, the counting mutual information (`CyclicTypeChannel.mutInfo`)
  under the uniform law on the primes below X.
- `bound` = `ramifiedBound 2 N = (2/N)(3 log₂ N + 2/ln 2)`, the formally proved bound
  (`ramified_contribution_le_bound`).

## Results

| X | N = #primes < X | I (all primes) | I (unramified only) | Δ = I_all − I_unram | proved bound |
|---|---|---|---|---|---|
| 1 000 | 168 | 1.078678 | 0.997381 | 0.081298 | 0.298361 |
| 10 000 | 1 229 | 1.015712 | 0.999919 | 0.015793 | 0.054801 |
| 50 000 | 5 133 | 1.004571 | 0.999986 | 0.004585 | 0.015532 |

## Observations

1. **No counterexample.** Δ stayed below the proved bound in every case, with room to spare
   (about a factor of 3.4 at N = 5133).
2. **The rate is log N / N.** Δ·N / log₂ N is ≈ 0.9 to 1.6 across the sample, and Δ is close
   to `(r/N) log₂(N/r)` with r = 2 (0.0044 predicted, 0.0046 observed at N = 5133). The
   extremal construction (`ramified_contribution_sharp`) shows the `log N` factor cannot be
   removed.
3. **Paper-128 regime.** The reported increment of +0.0020 bits is the size this table
   predicts for N ≈ 10⁴ primes. The formal instance `two_ramified_primes_negligible` gives
   Δ ≤ 0.002 for every channel once N ≥ 2¹⁶.
4. The unramified channel approaches exactly 1 bit. This is because `p mod 12` determines
   split/inert and Dirichlet balance makes the two classes equally likely.
   `D5TypeChannelCore.fibreProd_mutInfo` reduces the balanced model to the Galois-group
   channel of `C₂`, which is 1 bit.

No OEIS sequence is relevant: the quantities are real-valued entropies.
