# Computational evidence: completeness versus strong completeness

## Candidate and small cases

The contrarian candidate is

\[
E_1=\{n\in\mathbb N:n\text{ is even}\}\cup\{1\}.
\]

For the first several natural numbers at or above the eventual threshold `2`, distinct-summand representations are:

| `n` | subset of `E₁` | sum |
|---:|:---|---:|
| 2 | `{2}` | 2 |
| 3 | `{1,2}` | 3 |
| 4 | `{4}` | 4 |
| 5 | `{1,4}` | 5 |
| 6 | `{6}` | 6 |
| 7 | `{1,6}` | 7 |
| 8 | `{8}` | 8 |
| 9 | `{1,8}` | 9 |
| 10 | `{10}` | 10 |
| 11 | `{1,10}` | 11 |
| 12 | `{12}` | 12 |

The pattern gives a symbolic proof for every `n ≥ 2`: use `{n}` if `n` is even and `{1,n-1}` if `n` is odd.

## Counterexample hunt

Delete the finite set `{1}`. Every remaining element is even, hence every finite subset sum is even. Thus every odd target fails—not merely a small exceptional target—so the remainder is not complete. This disproves the universal conjecture

> Every complete subset of `ℕ` is strongly complete.

The Lean development certifies both completeness of `E₁` and failure of its strong completeness.

## OEIS search

No OEIS search is relevant: the object is the elementary set of even numbers with one exceptional element, and the argument concerns representability and finite deletion rather than a newly generated integer sequence.

## Plot/table note

The table above is the relevant finite visualization. A numerical plot would add no information because deletion of `1` creates the exact parity obstruction “all odd numbers are missing.”
