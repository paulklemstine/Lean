# Computational evidence

## Literal interpretation tested

The recurrence says that, given the two preceding values `x,y`, the next value is the least positive integer unequal to the single number `x+y`. Thus it is `2` only when `x+y=1`, and otherwise it is `1`.

Starting from `1,1`, the first values are therefore:

| index n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 10 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A(n) | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| A(n)/n² (n>0) | — | 1 | 1/4 | 1/9 | 1/16 | 1/25 | 1/36 | 1/100 |

The exact value at `n = 10^6` is formally proved in Lean to be `10^-12`.

## Counterexample hunt

A counterexample occurs immediately: the stated rule gives `A(2)=1`, not the displayed `A(2)=2`. It also gives `A(3)=1`, not `4`. This is not a large-index numerical issue but a mismatch between the recurrence and the claimed data.

The proposed quadratic limit is consequently false under the literal definition. The Lean development proves that the normalized sequence tends to `0` and cannot tend to `1/4`.

## Sequence identification

The literal recurrence produces the constant-one sequence. No external sequence-database identification is needed for the proof, and no unverified OEIS claim is used.

The displayed list `1,1,2,4,7,11,16,...` instead has successive differences `0,1,2,3,4,5,...`, suggesting `1 + n(n-1)/2`, which grows like `n²/2`, not `n²/4`. This observation is diagnostic only; the provided finite prefix does not define all later terms.

## Connection tested

If time indices are joined whenever their sequence values sum to `2`, every pair is joined because every value is `1`. The resulting graph is complete, with exactly `n choose 2` edges. This finite combinatorial consequence is proved for every `n` in Lean rather than tested only on samples.
