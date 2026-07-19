# Computational Evidence

The claims are linear-geometric, so small exact examples suffice to expose the key possibilities; the general results are proved symbolically in Lean.

## Small-case correction calculation

Take truth `0`, initial theory `T₀ = 1`, and corrections

| n | correction c(n) | partial theory after n terms | wrongness |
|---:|---:|---:|---:|
| 0 | 1 | 1 | 1 |
| 1 | -2 | 2 | 2 |
| 2 | 0 thereafter | 0 | 0 |

The correction sum is `1 + (-2) = -1 = truth - T₀`. Hence the series reaches truth, but wrongness increases from 1 to 2 at its first step. This exact calculation is certified by `convergent_correction_can_initially_worsen`.

## Two-dimensional geometry

Let truth be `(0,0)`, wrong theory error `a = (1,0)`, and rival error `b = (1,1)`. The Gram–Schmidt residual is

`u = b - (<b,a>/<a,a>)a = (0,1)`.

Then `<a,u> = 0`, while `<b,u> = 1`. Thus the wrong theory is exact on `u` and the rival is not. The Lean theorem proves this construction in every real inner-product space under nonparallelity.

For the counterexample to uniform dominance, choose the phenomenon `u = a`. Truth's error is zero, while the wrong theory's error is `<a,a> = ||a||² > 0`.

## Counterexample hunt

The universal claim fails immediately whenever the comparison class contains truth, because truth's prediction error is zero for every phenomenon. It also fails as a claim of uniform dominance for every nonzero error vector, using that error vector itself as the phenomenon. Both counterexamples are proved parametrically rather than only sampled.

## OEIS

No integer sequence arises from this continuous linear-geometric formulation, so an OEIS search is not applicable.
