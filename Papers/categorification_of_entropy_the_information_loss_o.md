# Computational Evidence

## Small-case calculations

For a uniform map with `n = mk` source states, `m` attained outputs, and fibers of size `k`, each output has probability `1/m`. Hence the output entropy is `log m`, the expected logarithmic fiber size is `log k`, and their sum is `log n`.

| Source states | Attained outputs | Fiber size | Output entropy | Fiber loss |
|---:|---:|---:|---:|---:|
| 6 | 3 | 2 | `log 3` | `log 2` |
| 8 | 4 | 2 | `log 4` | `log 2` |
| 12 | 3 | 4 | `log 3` | `log 4` |
| 12 | 1 | 12 | `0` | `log 12` |

The six-to-three residue channel is included as a concrete theorem: all three residue classes have exactly two elements.

## Counterexample hunt

Three proposed identifications fail on elementary finite examples.

1. The expression `-∑ p log p` is not information loss. A constant map has one output of probability one, so this expression is zero, although all source ambiguity remains. Its fiber loss is `log n`.
2. For a uniform `k`-to-one map onto `m` outputs, output entropy is `log m`, not `log k` or `log(n/m)` unless `m = k` accidentally.
3. Zero object loss cannot characterize categorical faithfulness: faithfulness concerns injectivity on morphisms, while object loss only sees the object function.

No counterexample was found to the corrected finite chain rule or to the characterization of zero fiber loss by injectivity of the object map; both are established in the accompanying development.

## OEIS search results

No OEIS search is relevant: the central data are arbitrary finite fiber partitions rather than a distinguished integer sequence.

## Tables and plots

The table above is the relevant finite profile. A plot would duplicate the elementary logarithmic dependence without adding discriminatory evidence.
