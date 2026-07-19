# Computational Evidence

## Small-case calculations

For an alphabet of size `q` and aligned words of length `m`, the exact word-space size is `q^m`. Consequently the first universal aligned collision threshold is `q^m + 1` sampled blocks.

| Alphabet size `q` | Word length `m` | Possible words `q^m` | Samples forcing collision | Bases covered by aligned samples |
|---:|---:|---:|---:|---:|
| 2 | 2 | 4 | 5 | 10 |
| 2 | 3 | 8 | 9 | 27 |
| 4 | 1 | 4 | 5 | 5 |
| 4 | 2 | 16 | 17 | 34 |
| 4 | 3 | 64 | 65 | 195 |
| 4 | 4 | 256 | 257 | 1028 |
| 4 | 6 | 4096 | 4097 | 24582 |

For multiplicity `r+1`, more than `r q^m` aligned samples suffice. For DNA four-mers this yields 513 samples for three copies and 769 samples for four copies.

## Sequence identification

The values `q^m` for fixed `q` are elementary geometric progressions. No OEIS lookup is needed for the proof or interpretation; sequence identification would not add information beyond the exact formula.

## Counterexample hunt and definition audit

Several informal numerical claims fail dimensional or definitional checks:

1. `256 log 256` is approximately 1419 with the natural logarithm and 2048 with logarithm base 2, not approximately 5000.
2. A collision among 4097 six-mers refers to 4097 sampled six-mers. If they are disjoint aligned blocks, they occupy 24582 bases; if they are consecutive sliding windows, 4102 bases are needed. A sequence of 4097 bases alone does not contain 4097 contiguous six-mers.
3. “Every subsequence of length 4 contains a repeated 4-mer” is not meaningful without specifying whether a 4-mer is contiguous in the original sequence, contiguous inside the chosen subsequence, or itself a scattered word, and without specifying how two occurrences are represented.
4. The assertion about every 1000-base human-genome window requires chromosome data, treatment of ambiguous bases, and a precise window statistic. It is therefore an empirical hypothesis, not a consequence of the finite-alphabet argument.

No counterexample exists to the aligned collision bound: it follows from the exact finite word-space cardinality, and sequences listing every possible word show that `q^m + 1` samples is sharp when samples are treated as independently chosen aligned blocks.

## Evidence boundary

The finite table supports only universal combinatorial thresholds. It does not verify a factor-of-five human-versus-random compression. Testing that claim requires an explicit genome assembly, a random-source model, and a reproducible definition of the repetition statistic.
