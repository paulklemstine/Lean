# Computational evidence: distinct-summand repair

## Small cases

Starting from `a(0)=1`, at each stage choose the least larger natural number that
is not `a(i)+a(j)` for distinct earlier indices `i<j`. Direct enumeration gives:

| index `n` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `a(n)` | 1 | 2 | 4 | 7 | 10 | 13 | 16 | 19 | 22 | 25 |
| increment | – | 1 | 2 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |

For example, after `1,2,4`, the candidates `5=1+4` and `6=2+4` are
forbidden, while `7` is admissible. The same seed mechanism repeats thereafter.

## OEIS search

No reliable OEIS identification was recorded. The sequence is elementary after
its transient: `a(0)=1`, `a(1)=2`, and `a(n)=3n-2` for `n≥2`; an OEIS match
would not by itself add evidence beyond this proposed closed form.

## Counterexample hunt

The proposed closed form was checked by direct enumeration through index 200.
No counterexample occurred. At each stable stage, the two values immediately
after the current term were forbidden by pairing it with `1` and `2`, while the
third candidate was congruent to `1 mod 3` and was not a sum of two distinct
prior values.

## Residue table

| kind of prior pair | residue modulo 3 |
|---|---:|
| `1 + 2` | 0 |
| `2 + (3k+1)` | 0 |
| `(3k+1) + (3l+1)` | 2 |

Thus residue `1` is absent from every distinct pair sum. The table also exposes
why distinctness matters: using the exceptional value `2` twice would produce
`4`, destroying the claimed trajectory at its second nontrivial term.
