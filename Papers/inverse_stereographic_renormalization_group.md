# Computational Evidence

## Small cases

For the zero-field one-dimensional Ising model, use the high-temperature
coupling `g = tanh K`. Exact decimation of alternate spins gives

`R(g) = g²`.

The table below is proved by `computational_evidence` in
`Physics/InverseStereographicRenormalizationGroup.lean`.

| `g` | `R(g)` | discrete beta `R(g)-g` |
|---:|---:|---:|
| 0 | 0 | 0 |
| 1/4 | 1/16 | -3/16 |
| 1/2 | 1/4 | -1/4 |
| 3/4 | 9/16 | -3/16 |
| 1 | 1 | 0 |

The corresponding inverse stereographic points are transformed by the
rational circle map

`C(x,y) = (x²/(2-x²), 2y/(1+y²))`.

The Lean connector theorem proves `S(R(g)) = C(S(g))` for every real `g`, so
these are not merely sampled numerical coincidences.

## OEIS search

No integer sequence is intrinsic to this continuous dynamical statement, so
an OEIS search is not applicable.

## Counterexample hunt

The finite fixed-point claim was tested algebraically rather than by sampling:
Lean proves `R(g)-g = 0` iff `g = 0` or `g = 1` over all real numbers. Thus no
counterexample exists to that formal claim.

The broader proposed identification with the perturbative beta function of
four-dimensional `phi^4` theory is not supported by this calculation. It is
not formalized as a theorem here: a beta function depends on a specified RG
scheme and normalization, while the derivative of a stereographic map depends
on chart and pole choices.

## Plot/table interpretation

On the physical interval `0 < g < 1`, `g² < g`, so decimation flows toward the
high-temperature fixed point `g = 0`. The endpoint `g = 1` is the zero-temperature
fixed point. Under inverse stereography this same dynamics is represented
exactly by `C` on the circle.
