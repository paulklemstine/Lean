# Computational evidence

The formal target is symbolic, but exact small cases help check the energy-density sign and scaling convention. For `κ = 1` and transverse derivative vector `(dy,dz) = (3,4)`, its squared Euclidean norm is `3²+4²=25`, so the model gives:

| speed `v` | density `-v²(3²+4²)` |
|---:|---:|
| 0 | 0 |
| 1 | -25 |
| 2 | -100 |
| 3 | -225 |

These four values are proved in Lean by `energyDensity_small_cases`; they are not merely external calculations. They exhibit the exact quadratic speed law later proved for arbitrary parameters and arbitrary finite quadrature.

## OEIS search

No OEIS lookup is relevant: the values above are a rescaled negative-square sequence used only as a sanity check, not a newly conjectured integer sequence.

## Counterexample hunt

The proposed linear scaling `E ~ M vₛ c` is incompatible with this fixed-profile energy-density model as an exact universal law. Doubling speed multiplies the density (and the proved finite sampled total energy) by four, not two. This does not refute every possible physical model involving ship mass, radius, wall thickness, or speed-dependent profiles; it shows that those additional dependencies would be necessary to obtain linear speed scaling.

For chronology, a finite future-directed chain whose global time strictly increases at each link cannot close. This is proved for arbitrary chain length, so finite numerical sampling adds no evidence beyond the symbolic theorem.
