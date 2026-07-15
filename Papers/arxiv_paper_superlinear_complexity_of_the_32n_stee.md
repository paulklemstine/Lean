# Computational evidence

The file `Catalog/Computation/ThreeHalvesSteering.lean` contains kernel-checked finite calculations for the selected nearest-integer convention

`m_n = (2·3^n + 2^n) / (2·2^n)`.

## Small cases

For `n = 0,…,11`, the rounded values are

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| m_n | 1 | 2 | 2 | 3 | 5 | 8 | 11 | 17 | 26 | 38 | 58 | 86 |

The corresponding corrections `t_n = 2m_{n+1} - 3m_n` for `n = 0,…,10` are

`1, -2, 0, 1, 1, -2, 1, 1, -2, 2, -2`.

These calculations are proved by `ThreeHalvesSteeringCore.roundedThreeHalves_first_values` and `ThreeHalvesSteeringCore.steering_first_values`.

## OEIS search

No OEIS identification is asserted. An external OEIS query was not used, so recording an identifier would be unreliable.

## Counterexample hunt

The first eleven corrections all lie in `{-2,-1,0,1,2}`, consistent with the general theorem `ThreeHalvesSteeringCore.steering_five_symbol_alphabet`. The appearance of both `-2` and `2` shows that the tempting smaller alphabet `{-1,0,1}` is false for these initial values.

Finite data cannot test the asymptotic superlinearity claim. Accordingly, no asymptotic conclusion is drawn from this table.
