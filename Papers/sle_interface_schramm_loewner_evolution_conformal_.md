# Computational Evidence: Conformal Transport of Interface Laws

## Small finite models

A finite curve space provides a direct model of chart transport: a law is a vector
of nonnegative masses and a chart is a permutation of coordinates. The following
examples were used to test the proposed identities.

| law on three curves | first chart | second chart | transition-invariant? | induced laws agree? |
|---|---|---|---|---|
| `(1/3, 1/3, 1/3)` | identity | 3-cycle | yes | yes |
| `(1/2, 1/3, 1/6)` | identity | swap 1 and 2 | no | no |
| `(1/2, 1/4, 1/4)` | identity | swap 2 and 3 | yes | yes |

Composing a permutation with its inverse returned every tested mass vector to
itself. By contrast, replacing a chart by a non-injective map merged coordinates;
subsequent transport could not recover their separate masses. This rules out an
unguarded inverse-transport theorem for general measurable maps.

## Sequence and database search

No integer sequence is intrinsic to the chart-independence claim, so an OEIS or
LMFDB search is not applicable. The numerical content is finite-dimensional
probability transport rather than arithmetic data.

## Counterexample hunt

Two weakened universal claims were tested against finite spaces.

1. **Chart independence without transition invariance is false.** On a two-point
   standard space with masses `(1/3, 2/3)`, identity and coordinate-swap charts
   induce different laws.
2. **Recovery after a non-bijective map is false.** Mapping two points to one
   loses the individual point masses, so no inverse map can recover every law.

These failures identify the indispensable assumptions in the final theorems:
measurable equivalence for reversible transport, and preservation of the
standard law by chart transitions for chart independence.

## Exceptional-event transport

For a permutation of a finite sample space, membership in each image event is
pointwise equivalent to membership in its preimage. Hence the set of points
belonging to infinitely many events is permuted without changing its mass. This
supports transporting summable exceptional-event conclusions across charts.
