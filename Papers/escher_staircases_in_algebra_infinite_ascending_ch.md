# Computational evidence: powers-of-two divisibility filtration

## Small cases

For
\[
D_n=\{f: f(z)\in 2^n\mathbb Z\text{ for every }z\in\mathbb Z\},
\]
the first levels impose divisibility by `1, 2, 4, 8, 16, 32`.

| level `n` | required divisor | constant witness in `D_n \ D_{n+1}` |
|---:|---:|---:|
| 0 | 1 | 1 |
| 1 | 2 | 2 |
| 2 | 4 | 4 |
| 3 | 8 | 8 |
| 4 | 16 | 16 |
| 5 | 32 | 32 |

Thus each tested containment is `D_(n+1) ⊊ D_n`, not `D_n ⊊ D_(n+1)`.
The same constant polynomials are elements of the ring of integer-valued
polynomials, so the direction test applies there as well.

## OEIS search

The divisors form the standard powers-of-two sequence
`1, 2, 4, 8, 16, 32, ...` (OEIS A000079).  No new enumerative sequence is
needed for the formal result.

## Counterexample hunt

The constant polynomial `2^n` is a counterexample to the proposed inclusion
`D_n ⊆ D_(n+1)` for every tested `n`: all of its values are divisible by `2^n`
but not by `2^(n+1)`.  This pattern is proved for every natural `n` in
`Catalog/Novelty/EscherStaircase.lean`.

The phrase “`I_1` is an element of the infinite intersection” is ill-typed for
ordinary ideals: the intersection contains ring elements, whereas `I_1` is an
ideal.  If the intended element is zero, then the condition is automatic for
any family of ideals.

## Relevant table

For a sample integer `x = 24`, divisibility across the first levels is:

| divisor | 1 | 2 | 4 | 8 | 16 | 32 |
|---:|:---:|:---:|:---:|:---:|:---:|:---:|
| divides 24? | yes | yes | yes | yes | no | no |

Every nonzero integer eventually fails the test because powers of two become
larger than its absolute value.  Pointwise, this explains why the intersection
of all levels is zero; the Lean development proves this and then proves that an
integer-valued rational polynomial vanishing on every integer is the zero
polynomial.
