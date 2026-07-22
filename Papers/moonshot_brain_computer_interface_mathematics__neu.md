# Computational Evidence

## Small cases

For `N` binary neurons, exhaustive counting gives the following values. The dense mean energy uses one unit per active neuron, and the last column is the relative population error for unit per-neuron variance.

| `N` | all patterns `2^N` | one-hot patterns | dense mean energy `N/2` | error `1/√N` |
|---:|---:|---:|---:|---:|
| 1 | 2 | 1 | 0.5 | 1.0000 |
| 2 | 4 | 2 | 1 | 0.7071 |
| 4 | 16 | 4 | 2 | 0.5000 |
| 8 | 256 | 8 | 4 | 0.3536 |
| 16 | 65536 | 16 | 8 | 0.2500 |

For ten neurons, the exact-weight counts at weights `0,1,2,3` are `1,10,45,120`, agreeing with `10.choose k`.

## Sequence identification

The total pattern counts are the powers of two, OEIS A000079: `1, 2, 4, 8, 16, 32, ...` when indexed from `N = 0`. The one-hot counts are the positive integers, OEIS A000027. Fixed-weight counts are binomial-coefficient diagonals in Pascal's triangle.

## Counterexample and formulation check

The literal phrase “`O(N log N)` concepts per unit energy” does not match the natural one-hot model: it represents exactly `N` concepts at one spike each, while its information per spike is `log₂ N` bits. For exactly `k` active neurons, the raw concept count per spike is `N.choose k / k`, which is not generally `O(N log N)` when `k` grows proportionally to `N`. The formal development therefore proves the coherent information-theoretic statement: one-hot sparse coding has `log₂ N` bits per spike, versus two bits per average spike for the full dense codebook, and this sparse rate tends to infinity.

No counterexample was found to the finite identities formalized in Lean; they are established symbolically for every natural `N` (and every weight `k` where applicable), rather than inferred from this table.
