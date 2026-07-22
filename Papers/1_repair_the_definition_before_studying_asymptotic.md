# Computational evidence for global additive avoidance

Starting from `a(0)=1`, at each stage the candidate must exceed the current value and avoid every sum of two values already present, with repeated summands allowed.

| stage `n` | prior values | forbidden pair sums | least admissible next value |
|---:|---|---|---:|
| 0 | 1 | 2 | 3 |
| 1 | 1, 3 | 2, 4, 6 | 5 |
| 2 | 1, 3, 5 | 2, 4, 6, 8, 10 | 7 |
| 3 | 1, 3, 5, 7 | 2, 4, 6, 8, 10, 12, 14 | 9 |
| 4 | 1, 3, 5, 7, 9 | 2, 4, 6, 8, 10, 12, 14, 16, 18 | 11 |

The observed trajectory begins `1, 3, 5, 7, 9, 11`, suggesting the exact law `a(n)=2n+1`. The mechanism is stable: sums of prior odd values are even; `a(n)+1` is forbidden as `1+a(n)`, while `a(n)+2` is odd and hence admissible.

No OEIS identification is needed: the candidate is the elementary odd-number sequence. A counterexample hunt against the displayed prefix `1,1,2,4,7,...` terminates immediately, since the repaired rule requires strict increase from the first step and also forbids `2=1+1`.
