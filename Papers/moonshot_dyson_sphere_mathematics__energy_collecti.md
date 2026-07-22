# Computational Evidence

## Small-case calculations

For total collecting area `A`, equal partition into `n` collectors gives quadratic thermal load

| Collectors `n` | Area per collector | Total quadratic load |
|---:|---:|---:|
| 1 | `A` | `A²` |
| 2 | `A/2` | `A²/2` |
| 4 | `A/4` | `A²/4` |
| 10 | `A/10` | `A²/10` |

The checked concrete instance with four collectors of area `3` has total area `12` and quadratic load `36`, compared with load `144` for one collector of area `12`.

The Type-II scaling identity is exact:

`10^40 operations/s × 10^-14 joules/operation = 10^26 joules/s`.

Thus `10^-14` joules per operation is the precise threshold at which a `10^26` watt source supports `10^40` operations per second in the stated energy-accounting model.

## OEIS search results

No integer sequence arises naturally from the continuous area-allocation, inverse-square flux, or energy-division statements. Consequently, no OEIS identifier is asserted. The panel-count law `A²/n` is a rational scaling family rather than an integer sequence without an additional discretization convention.

## Counterexample hunt

Several boundary cases were tested conceptually against the universal versions of the claims:

- At orbital radius zero, radiant flux divides by zero, so a full-capture theorem requires nonzero sphere area.
- With one collector, equal partition gives no strict thermal improvement over a shell represented by one panel.
- If “thermal management” is left undefined, equal collecting area alone does not imply any advantage. The result becomes testable only after choosing the quadratic concentration metric.
- Radius alone does not determine bit capacity. At fixed radius, changing operating duration or temperature changes the energetic capacity, so an unconditional `10^50`-bit conclusion is underdetermined.
- A `10^26` watt budget does not support `10^40` operations per second for arbitrary operation cost; costs above `10^-14` joules violate the budget.

These counterexamples determined the guards and calibrated hypotheses in the accompanying theorems.

## Numerical table

For a normalized total area `A = 1`, the optimal quadratic load is:

| `n` | 1 | 2 | 4 | 8 | 16 | 32 |
|---:|---:|---:|---:|---:|---:|---:|
| minimum load | 1 | 0.5 | 0.25 | 0.125 | 0.0625 | 0.03125 |

The inverse-linear trend is proved for every positive finite collector count, not inferred from the table.