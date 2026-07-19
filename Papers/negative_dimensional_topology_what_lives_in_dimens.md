# Computational Evidence

## Small-case calculations

For a pure object with `c` components in dimension `-n`, the proposed value is `(-1)^n c`.

| `n` | formal dimension | `c = 1` | `c = 2` | `c = 3` | `c = 4` |
|---:|---:|---:|---:|---:|---:|
| 0 | 0 | 1 | 2 | 3 | 4 |
| 1 | -1 | -1 | -2 | -3 | -4 |
| 2 | -2 | 1 | 2 | 3 | 4 |
| 3 | -3 | -1 | -2 | -3 | -4 |
| 4 | -4 | 1 | 2 | 3 | 4 |
| 5 | -5 | -1 | -2 | -3 | -4 |

A suspension changes the sign once. Stabilization from `-n` to `n` uses `2n` suspensions, so the tested multiplier is `(-1)^(2n) = 1` for `0 ≤ n ≤ 5`.

## Sequence identification

For one component, the Euler sequence by codimension is

`1, -1, 1, -1, 1, -1, …`.

This is the elementary alternating-sign sequence; no external sequence identification is needed for the argument.

## Counterexample hunt

The unrestricted statement for mixed-dimensional virtual objects was tested conceptually against two cells in adjacent degrees. One cell in degree `-2` and one in degree `-1` has Euler characteristic `1 - 1 = 0`, although its total component multiplicity is `2`. Thus the formula `χ = (-1)^n |π₀|` cannot hold for arbitrary data described only by a maximum or minimum dimension. Purity, or an equivalent concentration hypothesis, is necessary.

For pure objects with nonnegative finite component multiplicity, no counterexample occurs: character evaluation on a single degree is exactly one parity sign times the multiplicity.

## Stabilization table

| start | number of suspensions | endpoint | Euler multiplier |
|---:|---:|---:|---:|
| 0 | 0 | 0 | 1 |
| -1 | 2 | 1 | 1 |
| -2 | 4 | 2 | 1 |
| -3 | 6 | 3 | 1 |
| -4 | 8 | 4 | 1 |

These calculations motivate the general even-shift theorem and the stagewise pro-spectrum stabilization law.
