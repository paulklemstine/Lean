# Computational evidence: the lines, curves and stars of the Berggren picture

All numbers below were produced with `#eval` inside the project's Lean toolchain (floating point
for the transcendental quantities, exact `Nat`/`Int` arithmetic elsewhere). They are *evidence*,
not proof; each item that survived was subsequently proved in
`Catalog/Cryptography/BerggrenStars/`.

Notation: a Euclid seed is `(m, n)` with `0 < n < m`, `gcd(m,n)=1`, `m+n` odd; the half-plane
node is `z(m,n) = (n+i)/m`; the hypotenuse is `c = m²+n²`.

## 1. What the rays are: distance to a vertical geodesic

Conjecture tested: the visible straight lines out of the boundary point `0` are the level sets of
the hyperbolic distance to the imaginary axis, and that distance is `arsinh n`.

| seed | `d(z, {Re=0})` (numeric) | `arsinh n` |
|---|---|---|
| (2,1) | 0.881374 | 0.881374 |
| (4,1) | 0.881374 | 0.881374 |
| (10,1) | 0.881374 | 0.881374 |
| (3,2) | 1.443635 | 1.443635 |
| (9,2) | 1.443635 | 1.443635 |
| (7,4) | 2.094713 | 2.094713 |
| (11,4) | 2.094713 | 2.094713 |

Exact agreement for all 27 seeds with `m < 12`. Same experiment at the boundary point `1` gives
`arsinh (m-n)` for all 27 seeds. **Proved**: `spoke_dist`, `costar_dist`, and the general
`distVLine_hpoint` (boundary point `p/q`, value `arsinh(|qn-pm|/q)`).

## 2. Which Berggren move slides along which ray

* `B₃ : (7,4) → (15,4) → (23,4)`: distances to `{Re=0}` all `2.094713` — the move slides along
  one ray. **Proved**: `seedR_preserves_spoke`.
* `B₁ : (7,4) → (10,7)`: distances to `{Re=1}` both `1.818446`. **Proved**:
  `seedL_preserves_costar`.
* `B₂` preserves neither, but negates the Pell form `m²-2mn-n²`:
  `(2,1)↦(5,2)`: `-1 ↦ 1`; `(5,2)↦(12,5)`: `1 ↦ -1`; `(29,12)`: `1 ↦ -1`; `(7,4)`: `-23 ↦ 23`.
  **Proved**: `seedM_pell_flip`, and `seedM_sinh_relation` identifies the Pell form with
  `sinh²d₁ - 2 sinh²d₀`.

## 3. Census of the star: how many rays are visible in a ball of radius R

Enumerating all seeds with `m < 3000` and counting distinct spoke indices `n` occurring at
hyperbolic distance `≤ R` from `i`:

| R | # distinct rays | `cosh R - 1` | `e^R` | max index |
|---|---|---|---|---|
| 2 | 3 | 2.762 | 7.39 | — |
| 3 | 9 | 9.068 | 20.09 | 9 |
| 4 | 27 | 26.308 | 54.60 | — |
| 5 | 74 | 73.210 | 148.41 | 74 |
| 6 | 201 | 200.716 | 403.43 | — |
| 7 | 548 | 547.317 | 1096.63 | 548 |

Two things are visible: the count is `cosh R + O(1)`, and *max index = count*, i.e. the realized
spoke indices form an initial interval `{1,…,K}`. Both were then proved:
`spoke_realized_iff` (exact criterion `(n²+n+1)/(n+1) ≤ cosh R`, optimal representative the
left-spine seed `(n+1,n)`), `card_spokeSet_ge`, `card_spokeSet_le`.

## 4. Horocycle occupation numbers (OEIS A000010)

Counting seeds with a fixed `m` (i.e. nodes on the horocycle `Im = 1/m`):

| m | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| count | 1 | 1 | 2 | 2 | 2 | 3 | 4 | 3 | 4 | 5 | 4 | 6 | 6 | 4 |
| `φ(m)` | 1 | 2 | 2 | 4 | 2 | 6 | 4 | 6 | 4 | 10 | 4 | 12 | 6 | 8 |

The pattern `count = φ(m)` for even `m` and `2·count = φ(m)` for odd `m` holds throughout the
range (φ is OEIS A000010). **Proved**: `card_horocycleSeeds_even`, `card_horocycleSeeds_odd`.

## 5. Collisions

`65 = 8² + 1² = 7² + 4²`: the two nodes have radii `2.095186` and `2.232301` (a thin annulus)
but sit on the very different rays `arsinh 1 = 0.881` and `arsinh 4 = 2.095`. Euler's datum
`G = 8·7 + 1·4 = 60` gives `gcd(65,60) = 5`. **Proved**: `collision_65_spokes`,
`dist_ge_spoke_gap` (angular separation is a lower bound for the hyperbolic distance) and
`euler_datum_from_dist` (`G² = N² + m₁² + m₂² - 2m₁m₂ cosh d`).

## 6. Counterexample hunt

* Tested whether the residual-style monotonicity of the *radial* coordinate could fail for
  distance-to-geodesic: no; the star distances are exactly constant along `B₃`/`B₁`, by the
  linear-form identity, so no counterexample is possible.
* Tested `1/m < ε` in the density construction: dyadic seeds `(2^j, n)` with `n` odd exist for
  every odd `n < 2^j`, verified for `j ≤ 10`; no parity or coprimality failures.
* Tested whether nodes can come arbitrarily close to a rational geodesic `p/q`: the minimum of
  `|qn - pm|` over seeds off the geodesic is `1` in every sampled range, matching the proved
  bound `arsinh(1/q)` (`arsinh_inv_le_distVLine`).

---

## Cycle 2 evidence

### Ray population inside a ball (`RayDensity.lean`)

Exhaustive enumeration of Euclid seeds `(m,n)` with `(m²+n²+1)/(2m) ≤ cosh R`, counted per ray
index `n`, against the two proved bounds `(cosh R − (n+1))/(2n) ≤ #ray ≤ 2 cosh R`:

| `R` | `cosh R` | `n=1` | `n=2` | `n=3` | `n=5` | lower bounds (`n=1,2,3,5`) | upper bound |
|---|---|---|---|---|---|---|---|
| 3 | 10.07 | 10 | 9 | 5 | 6 | 4.03, 1.77, 1.01, 0.41 | 20 |
| 4 | 27.31 | 27 | 26 | 17 | 20 | 12.65, 6.08, 3.88, 2.13 | 55 |
| 5 | 74.21 | 74 | 73 | 49 | 58 | 36.10, 17.80, 11.70, 6.82 | 148 |
| 6 | 201.72 | 201 | 201 | 133 | 159 | 99.86, 49.68, 32.95, 19.57 | 403 |

Both bounds hold in every case. The true counts are close to `cosh R · (density of admissible
`m` on the ray)`, which is why the `n = 1` column tracks `cosh R` almost exactly and the `n = 3`
column tracks `(2/3) cosh R` — the missing constant is the open part of conjecture C5.

### Star coordinates (`StarCoordinates.lean`)

* **Dictionary check.** For all `1 ≤ u, v ≤ 79`: "`gcd(u,v) = 1` and `v` odd" holds exactly when
  `(m,n) = (u+v, u)` is a Euclid seed. Mismatches found: **0**. (Formalized as
  `isSeed_iff_isStarPair`.)
* **Descent versus breadth-first search.** The star descent
  `u > v ↦ (u−v, v)`, `u < v < 2u ↦ (v−u, 2u−v)`, `v > 2u ↦ (u, v−2u)`
  terminates at `(1,1)` for every star pair tested, and its step count agrees with the
  breadth-first depth in the Berggren tree for **every** seed with `m ≤ 400`: mismatches
  found **0**. (Formalized as `exists_depth_of_isStarPair` and `starReaches_unique_depth`.)
* Sample depths: `(2,1) ↦ 0`, `(3,2) ↦ 1`, `(4,1) ↦ 1`, `(5,2) ↦ 1`, `(4,3) ↦ 2`, `(6,1) ↦ 2`,
  `(8,3) ↦ 2`, `(8,5) ↦ 2`, `(5,4) ↦ 3`.
