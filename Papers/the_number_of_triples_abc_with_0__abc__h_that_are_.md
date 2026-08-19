# Computational evidence

All numbers below were produced by `#eval` inside Lean 4 (mathlib4, toolchain v4.28.0),
in `Catalog/MachineLearning/BerggrenBoxAudit.lean`, and are reproduced verbatim from the
build log.  They are *evidence*, not proof; every claim that is asserted as a theorem is
proved separately and `#print axioms`-checked (see the same file).

## 1. Small cases: the Berggren tree in a box

`nodeCount H` counts primitive Pythagorean triples with odd first leg and all entries
`≤ H`, i.e. `#(boxNode H)`, computed directly from Euclid parameters.

| `H` | proved lower bound `H/128` | `nodeCount H` | proved upper bound `H` |
|---|---|---|---|
| 64 | 0 | 9 | 64 |
| 128 | 1 | 20 | 128 |
| 256 | 2 | 39 | 256 |
| 512 | 4 | 83 | 512 |
| 1024 | 8 | 161 | 1024 |
| 2048 | 16 | 327 | 2048 |
| 4096 | 32 | 652 | 4096 |

The two proved bounds (`boxNode_card_ge`, `boxNode_card_le`) bracket the data at every
height, and the data grows visibly linearly — consistent with `Θ(H)`.

## 2. The linear constant

`10000 · nodeCount H / H` (integer division):

| `H` | 256 | 1024 | 4096 | 16384 |
|---|---|---|---|---|
| ratio ×10⁴ | 1523 | 1572 | 1591 | 1588 |

The classical constant is `1/(2π) = 0.159154…`, i.e. `1592` in these units.  The proved
interval is `[1/128, 1] = [78, 10000]`, which comfortably contains it; the true constant
sits near the *lower* end, confirming that the linear upper bound `H` is the crude side
and the linear lower bound is the substantive one.

## 3. Density of coprime opposite-parity pairs (the sieve input)

`10⁶ · #coprimePairs N / N²`:

| `N` | 16 | 64 | 256 | 512 |
|---|---|---|---|---|
| density ×10⁶ | 214843 | 206787 | 203430 | 203163 |

The limit is `2/π² = 0.2026423…`.  The theorem `card_coprimePairs_lower` proves the
explicit bound `≥ 1/16 = 0.0625`, so the proved constant is about a factor `3.2` from
optimal — as expected from the deliberately crude telescoping estimate
`∑_{k≥3} k⁻² ≤ 1/2` (true value `π²/6 − 1 − 1/4 = 0.394934…`).

## 4. Free growth of the tree

The three Euclid-coordinate branches `A(m,n) = (2m−n, m)`, `B(m,n) = (2m+n, m)`,
`C(m,n) = (m+2n, n)` applied `4` times to the root `(2,1)` produce `3⁴ = 81` distinct
parameter pairs (`#eval` returns `81`).  This is the numerical shadow of the proved
freeness theorem `applyGens_root_injective`, and combined with §1 it is what forces
`depth_forces_hypotenuse`: `81` nodes at depth `4` cannot all fit below height `81`.

## 5. OEIS

The counting sequence of §1 is the partial-sum sequence of the number of primitive
Pythagorean triples by hypotenuse; the underlying "number of primitive Pythagorean
triangles with hypotenuse `n`" sequence is A024361, and its partial sums grow like
`n/(2π)`.  The parity-pair counts of §3 are the partial sums of Euler's totient restricted
to opposite-parity pairs, with density `2/π²`; the unrestricted analogue is A015614
(density `3/π²`).  No new integer sequence appears to be involved.

## 6. Counterexample hunt

* The claim "`#(Berggren triples in the box) = (1 − o(1)) · #(primitive triples in the
  box)`" was tested for the **single** seed `(3,4,5)`: at every `H` the ratio is exactly
  `1/2` (each primitive triple with an even first leg is missed).  This is not a
  numerical accident; it is proved as `card_boxPPT_eq_two_mul`, and it *refutes* the
  single-seed reading of the mission statement.
* With the two seeds `(3,4,5)` and `(4,3,5)` the ratio is exactly `1` for every `H`
  (`boxBerggren_eq_boxPPT`), which is stronger than `1 − o(1)`.
* No counterexample was found to any statement that is asserted as a theorem below.

## 7. Cycle 4: the ratios as statements about real numbers

The set-level results of §6 were promoted to genuine ratio statements in
`Catalog/MachineLearning/BerggrenBoxRatio.lean`, where the denominators are shown to be
non-zero (`boxPPT_card_pos`, from the fact that the seed `(3,4,5)` itself lies in the cube
whenever `H ≥ 5`):

* `single_seed_ratio` : `#(boxNode H) / #(boxPPT H) = 1/2` in `ℝ`, for every `H ≥ 5`.
* `two_seed_ratio`    : `#(boxNode H ∪ boxNodeSwap H) / #(boxPPT H) = 1` in `ℝ`, for every
  `H ≥ 5`.
* `boxPPT_card_theta` : `H ≤ 64 · #(boxPPT H)` and `#(boxPPT H) ≤ 2H` for `H ≥ 32`, so the
  primitive Pythagorean triples of the cube are `Θ(H)` as well.
* `boxPPT_density_zero` : `#(boxPPT H)/H³ → 0`.

Numerically, `#(boxPPT H) = 2 · nodeCount H`, so the table of §1 doubles: at `H = 4096` the
cube holds `4096³ ≈ 6.87 · 10^10` triples, of which `1304` are primitive Pythagorean and
`652` are generated from the single seed `(3,4,5)`.
