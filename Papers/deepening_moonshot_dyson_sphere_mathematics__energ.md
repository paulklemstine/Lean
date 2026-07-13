# Computational Evidence — Stellar Energy Collection (Dyson Sphere / Swarm)

Before formalizing, we sanity-checked every claim numerically. All quantities are
in units where the stellar luminosity `L = 1` unless stated otherwise; `π ≈ 3.14159`.

## 1. The inverse-square flux law

`flux(L, R) = L / (4πR²)`.

| R    | 4πR²      | flux = 1/(4πR²) |
|------|-----------|-----------------|
| 0.5  | 3.1416    | 0.31831         |
| 1.0  | 12.566    | 0.07958         |
| 2.0  | 50.265    | 0.01989         |
| 4.0  | 201.06    | 0.004974        |

Doubling `R` divides flux by 4, confirming `flux_inverse_square` and the strict
antitonicity `flux_strictAnti`.

## 2. A complete shell captures the full output — at every radius

`collectedPower(L, R, 4πR²) = 4πR² · L/(4πR²) = L`.

| R    | area 4πR² | flux      | area × flux |
|------|-----------|-----------|-------------|
| 0.5  | 3.1416    | 0.31831   | 1.0000      |
| 1.0  | 12.566    | 0.07958   | 1.0000      |
| 4.0  | 201.06    | 0.004974  | 1.0000      |

Independent of `R`: this is `sphere_captures_all` and
`sphere_captures_all_scale_invariant`.

## 3. Collection depends only on solid angle

`collectedPower = L · (A/R²)/(4π)`. For example a `A = 1` collector:

| R   | solidAngle A/R² | captured = solidAngle/(4π) |
|-----|-----------------|----------------------------|
| 1   | 1.000           | 0.07958                    |
| 2   | 0.250           | 0.01989                    |

A collector at `R=1, A=1` and one at `R=2, A=4` subtend the same solid angle
(`1`) and capture the same power (`0.07958`) — verifying
`collectedPower_eq_solidAngle` and the factorization behind `swarmPower_eq`.

## 4. No swarm beats the sphere (coverage bound)

Total captured fraction = (total solid angle)/(4π). With total solid angle ≤ 4π
the captured power is ≤ L. Example swarm at `R=1`:

| # collectors | each area | total area | total solid angle | captured |
|--------------|-----------|------------|-------------------|----------|
| 4            | π         | 4π ≈12.566 | 4π                | 1.000    |
| 4            | π/2       | 2π         | 2π                | 0.500    |

The 4×π arrangement reaches total area `4π ≈ 12.566 = 4πR²`, capturing exactly
`L`. This is the equality case of `swarmPower_le_luminosity` and the content of
`swarm_common_radius_full`.

## 5. Concentration principle

Fixed total area `A_tot = 4`, all collectors at radius ≥ `Rmin`:

| Rmin | bound = A_tot/(4π Rmin²) |
|------|--------------------------|
| 1    | 0.3183                   |
| 2    | 0.0796                   |

Placing area closer (smaller `Rmin`) captures strictly more, matching
`swarmPower_le_minRadius`.

## 6. Counterexample hunt

- *Does full capture ever need area other than `4πR²` at a common radius?* Tested
  totals `{0.9·4πR², 4πR², 1.1·4πR²}`: only the exact `4πR²` gives captured `= L`.
  No counterexample to the `iff`.
- *Can a physical (≤ full-sky) swarm exceed `L`?* No configuration with total
  solid angle ≤ 4π produced captured > L. The formula only exceeds `L` when the
  unphysical constraint total solid angle > 4π is violated — consistent with the
  guarded hypothesis in `swarmPower_le_luminosity`.

## Conclusion

The computational landscape matches the conjectures exactly, with the sole
subtlety that the optimality bound requires the physical coverage constraint
(total solid angle ≤ 4π), which we encode explicitly as a hypothesis.
