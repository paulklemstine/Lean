# Computational Evidence: Objective Reduction Timescales

Concise numerical support for the formal claims in `OrchestratedReduction.lean`.

## 1. Energy–time reciprocity `E · t = ℏ`

With `ℏ ≈ 1.0546 × 10⁻³⁴` J·s:

| collapse time t (s) | self-energy E = ℏ/t (J) | product E·t |
|---------------------|-------------------------|-------------|
| 0.5   (gamma window) | 2.11 × 10⁻³⁴            | 1.0546 × 10⁻³⁴ |
| 10⁻³               | 1.05 × 10⁻³¹            | 1.0546 × 10⁻³⁴ |
| 10⁻⁶               | 1.05 × 10⁻²⁸            | 1.0546 × 10⁻³⁴ |

The product is constant to machine precision — matching `orEnergy_mul_time`.

## 2. Inverse square-root tubulin scaling `t(N) = ℏ / (E·√N)`

Fix `E = 10⁻²¹` J (≈ thermal `kT` at body temperature). Then:

| N       | √N       | t(N) (s)   | t(N)/t(N₀) |
|---------|----------|------------|------------|
| 10⁴     | 10²      | 1.05 × 10⁻¹⁵ | 1     |
| 4·10⁴   | 2·10²    | 5.27 × 10⁻¹⁶ | 1/2   |
| 16·10⁴  | 4·10²    | 2.64 × 10⁻¹⁶ | 1/4   |

Quadrupling `N` halves `t`, confirming `cohTime_sqrt_scaling` (`t(k²N)=t(N)/k`).

## 3. Whole-brain estimate (`cohTime_wholeBrain_bound`)

For `N = 10¹¹`, `√N ≈ 3.16 × 10⁵`. With `ℏ ≤ 2 × 10⁻³⁴` and `E ≥ 10⁻²¹`:

    t ≤ (2 × 10⁻³⁴) / (10⁻²¹ · 3.16 × 10⁵) ≈ 6.3 × 10⁻¹⁹ s  <  10⁻¹⁷ s.

This is ~16 orders of magnitude below the ~0.5 s gamma window — the decoherence
catastrophe, and the exact inequality proved formally.

## 4. Decoherence limit (`cohTime_tendsto_zero`)

Sampling `t(N)` for `N = 10⁴, 10⁶, …, 10¹²` gives a strictly decreasing sequence
tending to `0`, consistent with the proved `Tendsto … (𝓝 0)`.

## 5. Non-enumerability

No counterexample hunt applies: `no_configuration_enumeration` is the Cantor
diagonal, valid for every type, so the claim is universal rather than empirical.
