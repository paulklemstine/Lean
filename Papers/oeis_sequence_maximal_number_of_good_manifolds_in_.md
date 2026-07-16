# Computational evidence

## Identification and indexing

An exact OEIS search for the supplied prefix identifies **OEIS A212351**, “Maximal number of ‘good’ manifolds in an n-nice polytope.” Its offset is 1. OEIS records

`6, 8, 12, 24, 40, 80, 128, 256, 512, 1024, 2048, ...`

and the formula `a(n) = 2^n for n >= 7`. Thus, with zero-based Lean indices `j = n - 1`, the tail formula is `candidate j = 2^(j+1)` for `j >= 6`.

## Small-case table

| OEIS index n | supplied / OEIS value | `2^n` | tail formula applies? |
|---:|---:|---:|:---|
| 1 | 6 | 2 | no |
| 2 | 8 | 4 | no |
| 3 | 12 | 8 | no |
| 4 | 24 | 16 | no |
| 5 | 40 | 32 | no |
| 6 | 80 | 64 | no |
| 7 | 128 | 128 | yes |
| 8 | 256 | 256 | yes |
| 9 | 512 | 512 | yes |
| 10 | 1024 | 1024 | yes |
| 20 | 1048576 | 1048576 | yes |
| 21 | 2097152 | 2097152 | yes |

## Counterexample / transcription-error hunt

The provided final term is `20971`. At that position the established numerical pattern and current OEIS entry both give `2097152 = 2^21`. Therefore `20971` is a counterexample to interpreting the entire supplied string literally as A212351; it is most plausibly a truncated transcription of `2097152`.

The Lean theorem `terminal_discrepancy` verifies both the extrapolated value and its inequality with `20971`. Theorems `supplied_prefix_checks`, `tail_recurrence`, and `tail_block_sum` provide additional independent consequences checked by the kernel.

## Scope

This evidence concerns the numerical sequence and OEIS formula. The prompt supplies no definitions of “good manifold” or “n-nice polytope,” so it cannot support a formal proof that the numerical candidate equals the geometric/combinatorial maximum. That requires definitions and the argument behind the cited polytope result.
