# Computational evidence

All numbers below were produced with IEEE binary64 arithmetic (`u = 2⁻⁵³`) and
exact rational / 200-digit decimal reference arithmetic, before the Lean
development was written.  They test the two quantitative predictions of the
formalised theorems.

## 1. Local defect certificate (`hornerFl_forward_defect`, `flOrbit_isPseudoOrbit`)

Prediction for the logistic map `4x(1-x)` evaluated by Horner in binary64 on
`[0,1]`:

```
per-step defect  ≤  γ₆(u) · Σ|aᵢ| · 1ⁱ  =  ((1+2⁻⁵³)⁶ − 1) · 8  =  5.329·10⁻¹⁵
                 ≤  2⁻⁴⁶                                        = 1.421·10⁻¹⁴   (the bound proved in Lean)
```

Measured, orbit of `x₀ = 0.1`, 30 steps, defect `|fl(f(xₙ)) − f(xₙ)|` computed
exactly in ℚ:

| n | flₙ | ‖flₙ − exactₙ‖ | step defect |
|---|------|----------------|-------------|
| 1 | 0.36000000000000004 | 2.44e-17 | 2.44e-17 |
| 2 | 0.9216 | 4.51e-17 | 7.25e-17 |
| 3 | 0.28901376000000006 | 1.31e-16 | 2.11e-17 |
| 4 | 0.8219392261226498 | 3.15e-16 | 9.41e-17 |
| 5 | 0.5854205387341974 | 8.34e-16 | 2.20e-17 |
| 8 | 0.4019738492975123 | 7.01e-15 | 3.07e-18 |
| 10 | 0.1478365599132853 | 1.99e-14 | 6.38e-18 |
| 20 | 0.8200138733909665 | 2.24e-11 | 4.05e-17 |
| 30 | 0.3203424751858141 | 2.79e-08 | 1.25e-17 |

**Maximum observed per-step defect over 30 steps: `1.124·10⁻¹⁶`**, comfortably
below the certified `1.421·10⁻¹⁴`, and of the same order as `u·8 = 8.9·10⁻¹⁶`.
No counterexample to the certificate was found in any run.

## 2. Growth of the shadowing gap (`finite_shadowing`, `finite_shadowing_sharp`)

The proved forward bound is `δ·(4ⁿ−1)/3`, i.e. growth rate `4ⁿ`, using the global
Lipschitz constant `4` on `[0,1]`.  The measured gap grows like `≈ 2ⁿ`
(2.8·10⁻⁸ at `n = 30`, versus `10⁻¹⁶·2³⁰ ≈ 10⁻⁷`), reflecting the Lyapunov
exponent `ln 2` of the `r = 4` logistic map rather than `ln 4`.  So the bound is
correct and conservative for *typical* orbits; `finite_shadowing_sharp`
nevertheless shows the rate `Lⁿ` cannot be improved in general (it is attained by
`z ↦ L z` with constant defect `δ`).

## 3. Expanding cubic, uniform-in-time bound (`cubic_fl_shadowed_uniformly`)

For `p(z) = z³ + 2z` and `B = 2` the certified per-step defect is
`γ₈(u)(2B + B³) = 1.066·10⁻¹⁴`.  Measured defects, `x₀ = 0.3`:

| n | flₙ | step defect |
|---|-----|-------------|
| 1 | 0.627 | 2.70e-17 |
| 2 | 1.500491883 | 2.06e-17 |
| 3 | 6.379305065138997 | 4.92e-16 |
| 4 | 272.3678306536393 | 5.59e-15 |
| 5 | 2.0205943938967165e7 | 7.20e-10 |
| 6 | 8.249686235801401e21 | 4.21e5 |

Consistent with the theorem: the defect tracks `γ₈(u)(2|x| + |x|³)`, so the
certificate is only useful while the observed magnitudes stay bounded — exactly
the hypothesis `|xₙ| ≤ B` of `cubic_fl_shadowed_uniformly` (the map is expanding
and every nonzero orbit eventually overflows, which is the "avoid overflow"
hypothesis biting).

## 4. Counterexample hunt

20 random seeds `x₀ ∈ [0,1]`, 10⁴ binary64 logistic steps each (2·10⁵ steps in
total), all defects evaluated exactly in ℚ:

* maximum per-step defect `1.653·10⁻¹⁶` — below the certified `2⁻⁴⁶ =
  1.421·10⁻¹⁴`; no orbit ever left `[0,1]`;
* for the structural claim `flLogisticStep_parameter_backward`, the implied
  perturbed parameter `r' = fl-step / (x(1-x))` satisfied
  `|r' − 4|/4 ≤ 1.758·10⁻¹⁶` throughout, below the certified
  `γ₃(u) = 3.331·10⁻¹⁶`.

No counterexample was found.  (These are exploratory numerics, not a
verification; the verified statements are the Lean theorems.)

## 5. OEIS

No integer sequence arises in this development (all quantities are real-valued
error bounds), so no OEIS search applies.
