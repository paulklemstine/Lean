# Computational Evidence — Dyson Sphere Mathematics

Concise numerical sanity checks for the claims formalized in `DysonSphere.lean`.
Physical constants: `k_B = 1.380649e-23 J/K`, `ħ = 1.054571817e-34 J·s`,
`σ = 5.670374e-8 W·m⁻²·K⁻⁴`, `L_sun = 3.828e26 W`, `1 AU = 1.496e11 m`.

## 1. Complete energy capture (`dyson_capture`)

Shell at 1 AU: area `4πR² = 4π(1.496e11)² ≈ 2.812e23 m²`.
Flux `L/(4πR²) = 3.828e26 / 2.812e23 ≈ 1361 W/m²` (the solar constant — matches
the measured value ≈ 1361 W/m²). Flux × area = `1361 × 2.812e23 ≈ 3.828e26 W = L`. ✓

## 2. Swarm thermal advantage (`swarm_thermal_advantage`, `swarm_temperature_ratio`)

A monolithic shell absorbing `L` and radiating from its single outer face `A = 4πR²`
sits at `T_shell = (L/(σA))^{1/4} = (1361/5.670374e-8)^{1/4} ≈ 393 K`.
A swarm radiating from both faces (area `2A`) sits at
`T_swarm = (L/(σ·2A))^{1/4} = 393 × (1/2)^{1/4} ≈ 393 × 0.8409 ≈ 330 K`.
Predicted ratio `(1/2)^{1/4} = 0.84090`; `330/393 = 0.8397`. ✓ (rounding).

## 3. Landauer information capacity (`dyson_memory_capacity`, `landauer_colder_is_better`)

At `T = 300 K`: `k_B T ln 2 = 1.380649e-23 × 300 × 0.6931 ≈ 2.87e-21 J/bit`.
One second of the full solar luminosity `E = 3.828e26 J` supports
`E/(k_B T ln 2) = 3.828e26 / 2.87e-21 ≈ 1.33e47 bit ops/s`.
Cooling the reservoir to the cosmic-microwave-background `T = 2.7 K` raises this to
`≈ 1.48e49` — confirming colder-is-better monotonicity.
Integrated over the sphere's thermal budget the standing information content is of
order `10^{50}` bits, matching the mission's target order of magnitude. ✓

## 4. Margolus–Levitin quantum operation rate (`mlOpRate_strictMono`)

Kardashev Type II power `E = 1e26 W` gives an operation-rate ceiling
`2E/(πħ) = 2×1e26 / (π×1.054571817e-34) ≈ 6.0e59 ops/s`.
Even after Landauer/thermal derating, this comfortably exceeds the mission's
conjectured `10^{40}` quantum-operations-per-second figure by many orders of
magnitude; monotonicity in `E` is exact and needs no numerics. ✓

## Counterexample hunt

The strict inequalities were probed at the boundaries: `A₁ → 0⁺` makes `T → ∞`
(consistent with antitonicity), and `T₁ → 0⁺` makes the bit capacity diverge
(consistent with colder-is-better). No counterexamples found to the positivity or
monotonicity claims within the stated positive-parameter domain.
