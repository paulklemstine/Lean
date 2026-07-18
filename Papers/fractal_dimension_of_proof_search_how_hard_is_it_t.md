# Computational Evidence

## Small-case calculations

For periodic pruning with period `3` and free residues `{0,1}`, the numbers of free decision levels at depths `0` through `12` are:

| depth `n` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| free levels | 0 | 1 | 2 | 2 | 3 | 4 | 4 | 5 | 6 | 6 | 7 | 8 | 8 |
| successful prefixes | 1 | 2 | 4 | 4 | 8 | 16 | 16 | 32 | 64 | 64 | 128 | 256 | 256 |

At depths `3, 6, 9, 12`, the logarithmic estimate is exactly `2/3`. The theorem `finiteEstimate_at_periods` establishes this equality for every complete period and every admissible residue set.

For period `2` with one free residue, successful-prefix counts begin `1, 2, 2, 4, 4, 8, 8`; complete even depths have estimate exactly `1/2`.

## Counterexample hunt

The proposed `D > 1` regime was tested against the normalization `log₂(successful prefixes at depth n)/n`. Since there are at most `2^n` binary prefixes, every finite estimate is at most `1`, and the limiting upper dimension is at most `1`. Thus every positive candidate excess `1 + ε` is excluded, not merely absent from a finite sample.

The claim that dimension determines shortest-proof length also fails without extra compatibility assumptions. The same successful-prefix profile can be paired with any designated terminal length. This is represented by `SearchInstance`, and `dimension_does_not_determine_length` proves the resulting family for every rational dimension in `[0,1]` and every natural length.

## OEIS search results

No OEIS signal was supplied, and these periodic count sequences are elementary powers of two with periodic exponents rather than evidence for an unidentified integer sequence. An OEIS attribution was therefore unnecessary.

## Interpretation

The calculations support using codimension `1-D` as a pruning exponent. They do not support inferring runtime from dimension alone: a traversal policy and a law relating successful prefixes to terminal proofs are additional required data.
