# Computational Evidence

All numerical claims below were produced by brute-force enumeration *before* the Lean
formalisation, and every one of them is now backed by a `sorry`-free Lean theorem in
`Catalog/Pythagorean/`.  Nothing in this file is used as a substitute for a proof; it is
the exploratory data that shaped the conjectures.

## 1. Kernel spectra of `∑_{i<k} xᵢ² = y²` by dimension

Enumerating all leg tuples with entries `≤ 60` (`≤ 30` for `k = 4`), computing the canonical
equality pattern `canon` of the extended tuple `(x₀,…,x_{k-1}, y)`, and collecting the
distinct patterns:

| legs `k` | patterns available `bell(k+1)` | patterns realised | defect |
|---|---|---|---|
| 1 | 2 | 1 | 1 |
| 2 | 5 | 4 | 1 |
| 3 | 15 | 8 | 7 |
| 4 | 52 | 20 | 32 |

(The rows `k = 1, 2, 3` are fully formalised; the row `k = 4` is **exploratory data only**
and is not backed by a Lean proof in this project.)

The realised counts `1, 4, 8, 20` are **not** a shifted Bell sequence and were not found in
OEIS as an existing entry under this description; the closest structural description we
found is the split proved in Lean:

* hypotenuse-merged patterns: exactly `k + 1` for `k ≥ 2`
  (`HigherPythGen.card_mergedPart`) — giving `3, 4, 5` for `k = 2, 3, 4`;
* hypotenuse-separated patterns: `1, 4, 15` for `k = 2, 3, 4`, i.e. all leg-partitions
  except (for `k = 2, 3`) the "all legs equal" one, which is blocked exactly when `k` is not
  a square (`HigherPythGen.constant_legs_ne_hyp_iff`).

Indeed `3 + 1 = 4`, `4 + 4 = 8`, `5 + 15 = 20`, matching the table.

For `k = 3` the search returns the eight realised patterns

```
(0,0,0,0) (0,0,2,2) (0,0,2,3) (0,1,0,1) (0,1,0,3) (0,1,1,0) (0,1,1,3) (0,1,2,3)
```

and the seven missing ones

```
(0,0,0,3) (0,0,2,0) (0,1,0,0) (0,1,1,1) (0,1,2,0) (0,1,2,1) (0,1,2,2)
```

exactly as proved in `HigherPyth.pyth3_kernel_spectrum`.  Sample witnesses used in the
Lean proof: `(2,3,6,7)`, `(2,2,1,3)`, `(2,1,2,3)`, `(1,2,2,3)`, `(0,0,1,1)`, `(0,1,0,1)`,
`(1,0,0,1)`, `(0,0,0,0)`.

## 2. The conic pencil `x² + y² = C z²`

Scanning `C ≤ 100` and testing the four non-trivial patterns:

| `C` | `![0,1,2]` | `![0,0,2]` | `![0,1,0]` | `![0,1,1]` | spectrum size | defect |
|---|---|---|---|---|---|---|
| 1 | ✓ `(3,4,5)` | ✗ (`2` not a square) | ✓ `(1,0,1)` | ✓ `(0,1,1)` | 4 | 1 |
| 2 | ✓ `(1,7,5)` | ✗ (diagonal `A+B=C`) | ✗ | ✗ | 2 | 3 |
| 3 | ✗ (3-adic descent) | ✗ (`6` not a square) | ✗ (`2` not a square) | ✗ | 1 | 4 |
| 8 | ✓ `(2,14,5)` | ✓ `(2,2,1)` | ✗ (`7` not a square) | ✗ | 3 | 2 |
| 50 | ✓ `(17,31,5)` | ✓ `(5,5,1)` | ✓ `(1,7,1)` | ✓ `(7,1,1)` | 5 | 0 |

Every value `0,1,2,3,4` of the defect occurs, which is
`ConicKernel.conicDefect_range_eq`.  The counterexample hunt for "the defect is constant on
the pencil" therefore succeeded immediately at `C = 2`.

Checks of the individual identities: `1+49 = 50 = 2·25`; `4+196 = 200 = 8·25`;
`289+961 = 1250 = 50·25`; `25+25 = 50 = 50·1`; `1+49 = 50 = 50·1`.

## 3. The cubic pencil `x³ + y³ = C z³`

The equal-legs criterion proved in Lean is: `(A+B)·C^{p-1}` a `p`-th power **and**
`A+B ≠ C`.  For `p = 3`, `A = B = 1` this reads: `2C²` a cube and `C ≠ 2`.

| `C` | `2C²` | cube? | `C = 2`? | equal legs realised |
|---|---|---|---|---|
| 1 | 2 | no | no | no |
| 2 | 8 | **yes** | **yes** | no (degeneracy) |
| 4 | 32 | no | no | no |
| 16 | 512 = 8³ | yes | no | **yes**, `2³+2³ = 16·1³` |
| 54 | 5832 = 18³ | yes | no | yes, `3³+3³ = 54·1³` |

This is the data behind `FermatConic.cubic_pencil_trichotomy`: the two obstructions
(power obstruction and diagonal degeneracy) are independent, since `C = 2` fails only the
second and `C = 1` fails only the first.

## 4. Counterexample hunt against the universal claims

* "The kernel spectrum is order-convex in the partition lattice" — **false**, refuted by
  the chain `![0,1,2] ≺ ![0,0,2] ≺ ![0,0,0]` already at `k = 2`
  (`KernelStructure.pythSpectrum_not_convex`).
* "The equal-legs pattern is blocked for every exponent `p ≥ 2`" — true for `C = 1`, but
  **false** for the pencil: `C = 16`, `p = 3` is a counterexample
  (`FermatConic.isosceles_cubic_sixteen`).
* "The defect is constant along a family of cones" — **false**, defect `0,1,2,3,4` all
  occur.
* "Some pattern other than the all-equal one is realised by every cone" — **false**,
  `x² + y² = 3z²` realises only the all-equal pattern.
