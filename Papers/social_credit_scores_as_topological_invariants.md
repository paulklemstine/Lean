# Computational evidence

## Small cases

For the affine contraction `f(x) = x/2` starting from `x = 8`, the first iterates are:

| n | 0 | 1 | 2 | 3 | 4 |
|---|---:|---:|---:|---:|---:|
| fⁿ(8) | 8 | 4 | 2 | 1 | 1/2 |

The nontrivial entries are certified exactly by `half_score_first_iterates` in
`SocialCreditDynamics.lean`; they illustrate convergence to the unique fixed point 0.

## Counterexample hunt

The universal fixed-point claim fails immediately on two representative spaces:

* On the ordered continuum `ℝ`, the continuous update `x ↦ x + 1` has no fixed point.
* On the two-point finite discrete ordered space `Fin 2`, swapping 0 and 1 is continuous
  and has no fixed point.

Both counterexamples are formally certified in the Lean file. They show that neither
total order, continuity, nor finiteness supplies the missing fixed-point hypothesis.

For a connected population with a binary score range `{0,1}`, an attempted nonconstant
sample would have endpoint values 0 and 1. The intermediate value 1/2 is then forced,
contradicting the stated range. This obstruction is also formally proved.

## OEIS search

No integer sequence central to the conjectures arises. The geometric orbit above is a
standard real-valued dynamical sequence, so an OEIS identification would not contribute
to testing the topological claims.

## Qualitative phase-transition table

For `hardThreshold(x) = 0` when `x < 0` and `1` otherwise:

| x | -1 | -0.1 | -0.001 | 0 | 0.001 |
|---|---:|---:|---:|---:|---:|
| hardThreshold(x) | 0 | 0 | 0 | 1 | 1 |

The jump is not continuous; `hardThreshold_not_continuous` proves this rather than
merely relying on the table.
