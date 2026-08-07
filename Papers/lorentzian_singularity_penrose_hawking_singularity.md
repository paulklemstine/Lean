# Computational Evidence — Lorentzian Singularity Theorems

All numbers below come from a forward-Euler integration of the Raychaudhuri
differential inequality in its equality (worst) case

```
θ'(t) = -θ(t)²/m + c      (c = constant energy-condition defect; c = -ε for strict energy)
```

written in Lean and evaluated with `#eval` on `Float` (step count 3·10⁶–6·10⁶ over the
displayed window, blow-up detected at `|θ| > 10⁶`).  **These are numerics, not verified
computations** — they were used to select and stress-test the conjectures before proving
them; every claim that is asserted as a theorem is proved separately in Lean with no
`sorry` and no `native_decide`.

## 1. Penrose focusing bound is attained (`focusing_domain_bound`)

| m | c | θ₀ | predicted bound `m/|θ₀|` | numerical blow-up time |
|---|---|-----|--------------------------|------------------------|
| 2 | 0 | −1  | **2.000000**             | **2.000012**           |

The exact Riccati solution `θ(t) = mθ₀/(m + θ₀t)` blows up precisely at `m/|θ₀|`; this is
formalized as `riccatiSol_sharp` and `exactTrappedSurface_saturates`.  The bound is
therefore *attained*, not merely valid.

## 2. Energy-condition defect: valid but non-optimal quadratic bound

| m | c   | θ₀   | quadratic bound `m|θ₀|/(θ₀²−mc)` | log bound `(m/2a)·ln((θ₀−a)/(θ₀+a))`, `a=√(mc)` | numerical blow-up |
|---|-----|------|----------------------------------|--------------------------------------------------|-------------------|
| 2 | 0.5 | −1.5 | 2.400000                         | **1.609438** (= ln 5)                            | **1.609450**      |

This experiment is what motivated proving the *sharp* logarithmic bound
(`sharp_defect_focusing_bound`) after the first, cruder estimate
(`focusing_domain_bound_of_energy_defect`).  The numerics agree with `ln 5` to 5 decimal
places, i.e. the logarithmic bound is saturated, while the quadratic estimate overshoots
by 49 %.

## 3. The threshold `θ₀² = m c` genuinely destroys focusing

| m | c   | θ₀ | integrated to t = 40 | θ(40)      |
|---|-----|----|----------------------|------------|
| 2 | 0.5 | −1 | no blow-up           | −1.000000  |

Exactly at `θ₀² = m c = 1` the solution is the constant `θ ≡ −1` and lives forever.  This
counterexample is formalized (as an exact solution of the Raychaudhuri equation, not just
of the inequality) in `defect_threshold_eternal` / `trapped_focusing_dichotomy`, and shows
the strict inequality `m c < θ₀²` cannot be weakened.

## 4. Bonnet–Myers / Hawking bound with strict energy `Ric ≥ ε`

| m | ε | θ₀ | refined bound `(m/a)(arctan(θ₀/a)+π/2)`, `a=√(mε)` | universal bound `π√(m/ε)` | numerical blow-up |
|---|---|----|----------------------------------------------------|---------------------------|-------------------|
| 2 | 1 | 0  | **2.221441** (= (π/2)√2)                            | 4.442883                  | **2.221453**      |
| 2 | 1 | +5 | **4.052704**                                        | 4.442883                  | **4.053076**      |

Both rows saturate the *refined* Prüfer bound `myers_domain_bound_refined` to 4–5 decimal
places, and the second row shows that the universal constant `π√(m/ε)` is approached but
not attained for finite initial expansion — consistent with the proof, in which the loss
is exactly the missing phase `π/2 − arctan(θ₀/a)`.  Row 1 is realized in Lean by the exact
solution `tanSol` (`tanSol_sharp`).

## 5. Counterexample hunt

* Trapped surface without an energy condition (`c` unbounded): the constant solution of
  item 3 already shows no bound can exist; formalized.
* Averaged energy condition with zero total energy (`r ≡ 0`, defect rate `q ≡ a²/m`):
  the ANEC bound `L ≤ (m/a)(π + Dmax/a)` degenerates to `L ≤ 2π m/a + L`, i.e. becomes
  vacuous — as it must, since Minkowski space is geodesically complete.  The theorem is
  therefore not "too strong"; it bites exactly when the accumulated defect grows
  sublinearly in the affine parameter.

## No OEIS entry

The objects here are continuous (ODE blow-up times), so no integer sequence arises and no
OEIS search applies.

---

# Appendix (this cycle): stability, sharp oscillation spacing, energy shortfall

The runs below were produced with an independent explicit integrator (fixed-step
Euler/RK4, step `10⁻⁵`–`10⁻⁷`) of the Raychaudhuri equation in its equality case
`θ' = -θ²/m - p(t)` and were used to select the constants that were then proved.
**They are numerics, not verified computations**; every asserted theorem is proved in
Lean with no `sorry` and no `native_decide`.

## 6. The stability constant of `penrose_stability` is asymptotically sharp

`m = 1`, `θ₀ = -1`, `t₀ = 0.5`; model value `θ_model(t₀) = -2`, scale `U = 1/2`.
The theorem asserts `P t₀ ≤ δ/(1 - δU)²` where `P t₀ = ∫₀^{t₀} p` and
`δ = θ_model(t₀) - θ(t₀)`.

Constant defect rate `p ≡ const`:

| p | θ(t₀) | δ | `P t₀` | bound `δ/(1-δU)²` | bound / actual |
|------|-----------|----------|--------|--------------------|------|
| 0.001| −2.001167 | 0.001167 | 0.0005 | 0.001168 | 2.34 |
| 0.01 | −2.011686 | 0.011686 | 0.005  | 0.011824 | 2.37 |
| 0.1  | −2.118676 | 0.118676 | 0.05   | 0.134120 | 2.68 |
| 1.0  | −3.408223 | 1.408223 | 0.5    | 16.08    | 32.2 |

Defect of *fixed total* `P t₀ = 0.01` concentrated in the last `w` of `[0, t₀]`:

| w | δ | bound | bound / actual |
|-------|----------|----------|------|
| 0.5   | 0.023412 | 0.023970 | 2.40 |
| 0.2   | 0.014547 | 0.014761 | 1.48 |
| 0.05  | 0.011035 | 0.011158 | 1.12 |
| 0.01  | 0.010201 | 0.010306 | 1.03 |
| 0.002 | 0.010040 | 0.010141 | **1.01** |

The ratio tends to `1` as the defect concentrates just before `t₀` — exactly the extremal
configuration predicted by the proof (the weight `1/θ²` is largest where `|θ|` is
smallest, i.e. at the very end of the interval).  The bound is therefore not merely valid
but asymptotically attained, and the linear-in-`δ` scaling is visible in the first table.

## 7. Localized energy-condition violation (`localized_violation_bound`)

`m = 1`, `ε = 1`, `θ(0) = 0`, `Ric = 1` outside a window `[t₁, t₂]` and `Ric = -c` inside.
The theorem gives `L ≤ π + (1 + c)τ` with `τ = t₂ - t₁`.

| t₁ | t₂ | c | numerical blow-up `L` | bound `π + (1+c)τ` |
|-----|-----|-----|------------------------|---------------------|
| 0.5 | 0.6 | 0   | 1.6470 | 3.2416 |
| 0.5 | 0.6 | 1   | 1.7297 | 3.3416 |
| 0.2 | 0.3 | 5   | 2.1578 | 3.7416 |
| 0.5 | 1.0 | 2   | 2.9614 | 4.6416 |

The bound holds in every case with a comfortable margin: for `θ(0) = 0` the *unperturbed*
blow-up time is already only `π/2`, so the extra room `(1+c)τ` is a genuine over-estimate
here.  It is not wasteful in general — a window placed where the expansion is close to
zero can delay focusing by an amount of the same order as `(1 + c/ε)τ` — but no example
saturating it was found numerically, so the constant is *not* claimed to be sharp.

## 8. Conjugate-point spacing (`exists_zero_Ioc_of_length_ge`)

For `k ≡ ε/m` the solution `sin(√(ε/m) t)` has consecutive zeros exactly
`B = π √(m/ε)` apart, so a closed interval of length `B` always contains a zero, while
`cos(√(ε/m)(t - midpoint))` is strictly positive on every interval of length `< B`.
No numerics are needed: both statements are exact and both are formalized
(`exists_zero_Ioc_of_length_ge`, `cos_model_positive_of_short_interval`), pinning the
threshold from both sides.
