# Computational Evidence

## Small-case calculations

For a single gate `r(x) = max(0,x)`, the values at `x = -2,-1,0,1,2` are `0,0,0,1,2`. Thus the zero set contains the negative half-line, while the change of slope remains concentrated at zero. This separates “zero set is a hypersurface” from “nondifferentiability set is a hypersurface.”

For the balanced expression `max(max(a,b),max(c,d))`, the tropical depth is `2`. Applying the two-input log-sum-exp estimate at each level predicts a uniform smoothing error at most `2 log(2)/β`. For an unbalanced expression `max(a,max(b,max(c,d)))`, the corresponding depth bound is `3 log(2)/β`, showing that tree shape, not only leaf count, controls the compositional estimate.

The layerwise recurrence `R([])=1` and `R(w::ws)=2wR(ws)` gives:

| widths | recurrence value | `2^L ∏w_i` |
|---|---:|---:|
| `[]` | 1 | 1 |
| `[1]` | 2 | 2 |
| `[2]` | 4 | 4 |
| `[2,3]` | 24 | 24 |
| `[2,3,4]` | 192 | 192 |

## OEIS search results

No canonical one-variable sequence is intrinsic to the multivariate width recurrence. Specializing all widths to one yields powers of two, but this specialization discards the architectural information of interest, so no OEIS identification is used.

## Counterexample hunt

Two minimal boundary cases were checked:

1. The scalar ReLU zero set contains every `x<0`, contradicting an unconditional claim that every ReLU decision zero set is codimension one.
2. At width one, `choose(1,2)=0`, yet scalar ReLU has different one-sided linear behavior around zero. Therefore a universal singularity bound based only on a product of pair counts cannot count ordinary ReLU kinks without additional conventions or hypotheses.

These cases are incorporated as general symbolic theorems rather than left as numerical observations.

## Tables and plots

No plot is needed for the one-dimensional obstruction: the exact formulas `r(-ε)=0` and `r(ε)=ε` for every `ε>0` completely describe the relevant local geometry.
