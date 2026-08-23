# Computational evidence

All numbers below were produced inside Lean by the `#eval` harness
`Catalog/Pythagorean/PrefixEvidence.lean` (run with the project's own Mathlib).  They are
*evidence about finite prefixes* — which is exactly the epistemic point of this cycle — while
every asymptotic statement in the `.lean` files is a proved theorem.

## 1. The three witness digit sequences (first 40 fractional digits)

| witness | digits |
|---|---|
| `sparseSeq` (`sparseReal`) | `1101000100000001000000000000000100000000` |
| `denseSeq` (`denseReal`)   | `2212111211111112111111111111111211111111` |
| `altSeq` (`altReal`)       | `2313121312121213121212121212121312121212` |

The support of the "bumps" is `{2^i − 1} = 0, 1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, 2047, …`
(Mersenne numbers, OEIS **A000225**); equivalently the digit indicator of `sparseSeq` is the
characteristic function of the powers of two shifted by one.

## 2. Nonzero-digit counts versus the proved logarithmic bound

`Pyth.nonzeroCount_sparseGraft_le` proves `#nonzero digits below M ≤ n + log₂ M + 1`.  With
prefix length `n = 0`:

| `M` | measured nonzero count | `log₂ M + 1` |
|---|---|---|
| 10 | 4 | 4 |
| 100 | 7 | 7 |
| 1000 | 10 | 10 |
| 10000 | 14 | 14 |

The bound is attained exactly at these values, so the `log₂` counting lemma is sharp, and the
observed density `10/1000 = 0.01`, `14/10000 = 0.0014` is consistent with the proved limit `0`.

## 3. Autocorrelation counts

`agreeCountFin d r M = #{m < M : d(m) = d(m+r)}`.

| sequence | lag | `M = 100` | `M = 1000` |
|---|---|---|---|
| `altSeq` | 1 | 0 | 0 |
| `altSeq` | 2 | 90 | 984 |
| `denseSeq` | 1 | — | 983 |
| `denseSeq` | 3 | — | 984 |
| `denseSeq` | 7 | — | 985 |
| `sparseSeq` | 1 | — | 983 |
| `sparseSeq` | 2 | — | 984 |

Two numbers that can be made to share *any* prescribed finite prefix therefore exhibit
completely different lag-1 autocorrelation (`0` versus `≈ 0.98`), and one and the same number
(`altReal`) exhibits autocorrelation `0` at lag 1 and `≈ 1` at lag 2.  These are the finite
shadows of the theorems `Pyth.agreeDensity_altGraft_one`, `Pyth.agreeDensity_altGraft_two`
and `Pyth.agreeDensity_denseGraft`.

## 4. Counterexample hunt

The universal claims we set out to prove are of the form "for every `x` and every `n` there
exist witnesses …".  A counterexample would be a prefix length for which the construction
fails, i.e. a position `k < n` where the graft's digit differs from that of `x`, or a lacunary
tail whose digit read-back disagrees with the prescribed sequence.  The digit read-back was
checked against the definition for the first 40 positions of all three witnesses (table 1) and
no discrepancy appears; the general statements are proved in
`Pyth.digits_ofDigits` and `Pyth.digits_graft_of_lt` / `Pyth.digits_graft_of_ge`.

One genuinely instructive near-counterexample: digit recovery *fails* without the hypothesis
`digit ≤ 8`, since the sequence `9,9,9,…` sums to `1.000…`, whose digits are all `0`.  This is
why every construction here keeps the digits in `{0,1,2,3}`.

## 5. What the data does **not** show

Nothing here is evidence about `π`, `e` or `√2`.  Their prefixes are compatible — by the
theorems of this cycle — with density `0`, with density `1`, with rationality, with lag-1
autocorrelation `0` and with lag-1 autocorrelation `1`.  Finite-prefix statistics of those
constants are data about the prefix, never about the constant.
