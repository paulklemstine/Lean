# Computational evidence

## Scope correction

The proposed claim that a polynomial over a finite field generically has abstract Galois
group `S_n` is false for `n ≥ 3`: every finite-field Galois group is cyclic.  The
appropriate random-permutation object is the Frobenius permutation on geometric roots,
whose cycle type records factorization degrees.

The formal development therefore tests and proves the exact first-moment connection:
the number of roots of a random monic degree-`n` polynomial and the number of fixed
points of a random permutation both have expectation one.

## Small cases

The following values are kernel-checked in `StochasticGalois/ComputationalChecks.lean`.

| model | sample-space size | total incidences | mean |
|---|---:|---:|---:|
| monic quadratics over `F₂` | 4 | 4 roots | 1 |
| monic quadratics over `F₃` | 9 | 9 roots | 1 |
| permutations in `S₃` | 6 | 6 fixed points | 1 |

The same file checks the cleared-denominator bridge for degree three over `F₃`:
`27 · 6 = 6 · 27` after replacing each factor by its corresponding incidence sum.

## Counterexample hunt

The universal `S_n` Galois-group claim does not merely have sporadic counterexamples.
For every finite extension `L/K` of finite fields its Galois group is cyclic, while
`S_n` is noncommutative for `n ≥ 3`.  Hence every such extension is a counterexample to
the proposed abstract-group claim in those degrees.  This obstruction is proved in
`finite_field_galois_group_not_symmetric`.

## OEIS search

No OEIS identification is needed: the two incidence totals are the standard closed-form
sequences `q^n` and `n!`, and the result concerns their normalized first moments rather
than a newly observed integer sequence.

## Table versus plot

A plot would obscure an exact identity.  The table above is the relevant visualization:
both normalized totals are identically one, not merely asymptotic.
