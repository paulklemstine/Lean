# Computational evidence — profile form (exp 579 / paper 229 re-analysis)

All numbers below were produced with Lean `#eval` (`Float` arithmetic) before the
formal statements were fixed; they are *exploratory*, and every claim that made
it into a theorem is separately proved in
`Catalog/NumberTheory/ProfileForm*.lean` with 0 sorries (axioms:
`propext, Classical.choice, Quot.sound` only).

## 1. The fitted residual `R̂(x) = 4/5 + (59/90)x − (5/9)x²`

This is the concave quadratic pinned at the reported end deficits
`R̂(0)=0.80`, `R̂(1)=0.90` with the reported interior vertex `0.59`.

| x | 0 | 0.25 | 0.50 | 0.59 | 0.67 | 0.75 | 1 |
|---|---|------|------|------|------|------|---|
| R̂(x) | 0.800000 | 0.929167 | 0.988889 | **0.993389** | 0.989833 | 0.979167 | 0.900000 |

* hump ratio over the small-`j` wall end: `R̂(0.59)/R̂(0) = 1.241736`
  (reported "±20 %", reported max `1.23`);
* hump ratio over the far end: `R̂(0.59)/R̂(1) = 1.103765`.

Formalised as `residualFit_hump_ratio_left` (`≥ 6/5`) and
`residualFit_hump_ratio_right` (`≥ 11/10`), plus the exact vertex value
`R̂(59/100) = 17881/18000` and the interior-max/non-monotonicity package
`residualFit_peak`.

## 2. Curvature sweep: where does the peak survive?

For the endpoint-pinned family `R_c(x) = 4/5 + (1/10 − c)x + c x²`
(apex `v(c) = (1/10−c)/(−2c)`, apex height `h(c) = 4/5 − (1/10−c)²/(4c)`):

| c | −0.62 | −0.5556 (fit) | −0.14 | −0.11 | −0.10 | −0.05 |
|---|-------|---------------|-------|-------|-------|-------|
| v(c) | 0.5806 | 0.5900 | 0.8571 | 0.9545 | **1.0000** | 1.5000 |
| h(c) | 1.0090 | 0.9934 | 0.9029 | 0.9002 | 0.9000 | 0.9125 |
| h(c)/0.8 | 1.2613 | 1.2418 | 1.1286 | 1.1253 | 1.1250 | 1.1406 |

The apex crosses the right endpoint exactly at `c = −1/10`.  This is the sharp
threshold proved in `residualQuadVertex_threshold`,
`residualQuad_vertex_mem_Ioo` (peaked side), `residualQuad_monotoneOn_of_ge`
(monotone side) and `residualQuad_peak_invariant_over_CI`: the reported
curvature CI `[−0.62, −0.14]` clears the threshold by `0.04`.
The uniform apex bounds `h(c) > 0.9` and `h(c) ≥ 1.12 · R_c(0)` seen in the last
two rows are `residualQuad_peak_gt_right_end` and `residualQuad_hump_ratio_ge`.

## 3. Model selection

`w(d₁,d₂,d₃) = 1/(1 + e^{−d₁/2} + e^{−d₂/2} + e^{−d₃/2})` at the reported gaps
`(9.2, 11.5, 16.9)`:

```
e^-4.6 = 0.010052,  e^-5.75 = 0.003183,  e^-8.45 = 0.000214
w(9.2, 11.5, 16.9) = 0.986730          (paper reports 0.9866)
```

The proved statement is the conservative rigorous bound
`akaikeWeight_exp579_gt : 0.98 < akaikeWeight 9.2 11.5 16.9`, obtained from
`exp 4 ≥ 54.59` and `1 + x ≤ exp x`.  (Reproducing `0.9866` formally would need
sharper `exp` bounds; the qualitative verdict does not depend on them.)

## 4. Decline across the window and absorption

Raw decline factor of the power law over `x ∈ [0,2]` is `3^b`:

```
3^0.991 = 2.970,  3^1.104 = 3.363,  3^1.218 = 3.812
```

The measured raw decline `3.25` lies inside; the proved bracket
`declineFactor_bracket` is the (rigorous, slightly looser) `(2.8, 4.1)`.

Absorption, with the mixture baseline `M(x) = (1 − e^{−x})/x` and `b = 1.104`,
over `x ∈ [1,3]`:

```
M(1)/M(3)          = 1.9957   (baseline decline)
T(1)/T(3)          = 2.1495   (raw profile decline)
R(1)/R(3)          = 1.0771   (residual decline)
```

so the baseline really does eat the gradient.  The proved, parameter-free
version is `residual_decline_le_two_thirds_raw`: `R(1)/R(3) ≤ (2/3)·T(1)/T(3)`
for every amplitude and exponent (here `2/3 · 2.1495 = 1.433 ≥ 1.077`).

## 5. Counterexample hunt

* *Is the peak an artefact of the particular fit?*  No — swept over `c` in §2;
  it survives on the whole reported CI and fails only for `c > −1/10`, which the
  CI excludes.  The failure region is stated as a theorem rather than hidden
  (`residualQuad_monotoneOn_of_ge`).
* *Could the residual itself be a power law (i.e. the layers collapse)?*  No —
  power-law profiles are monotone on the window, contradicting the interior
  peak (`residualFit_ne_powerProfile`, `peak_forces_nonPowerLaw_baseline`).
* *Does an interior peak rule out a positive scale-mixture baseline?*  **No —
  counterexample found and formalised.**  With `b = 1.104` and the two-atom
  mixture `M(x) = (e^{-x/20} + e^{-8x})/2`, the ratio `T/M` evaluates to

  | x | 0 | 0.1 | 0.2 | 0.3 | 0.4 | 0.6 | 0.8 | 1.0 |
  |---|---|-----|-----|-----|-----|-----|-----|-----|
  | R(x) | 1.000 | 1.247 | 1.373 | **1.393** | 1.353 | 1.219 | 1.089 | 0.981 |

  a clear interior hump.  Formalised (with `b = 11/10`) as
  `twoAtomResidual_peak` and `mixture_baseline_peak_possible` in
  `ProfileFormMixturePeak.lean`.
* *Is the uniform Dickman surrogate `M(x) = (1−e^{−x})/x` immune, i.e. can it
  never hump?*  **No — refuted on a wider window.**  On `x ∈ [0.1, 1.1]` the
  ratio does decrease monotonically (0.946 → 0.727), which is what suggested the
  fallback conjecture; but continuing past the fitted window with `b = 1.104`
  the ratio turns around:

  | x | 1 | 3 | 5 | 8 | 10 | 12 | 20 | 50 | 100 |
  |---|---|---|---|---|----|----|----|----|-----|
  | R(x) | 0.736 | 0.683 | 0.696 | 0.7075 | **0.7085** | 0.7070 | 0.694 | 0.651 | 0.613 |

  a shallow but genuine interior hump.  Its location tracks the heuristic
  crossing `x* = 1/(b−1) ≈ 9.6` (grid argmax 9.5), obtained by equating the logarithmic
  derivatives `−b/(1+x)` of the profile and `−1/x + e^{−x}/(1−e^{−x})` of the
  baseline in the large-`x` regime where the exponential term is negligible.
  Formalised (with `b = 11/10`, window `[3,100]`) as `uniformResidual_peak` and
  `peak_is_window_dependent` in `ProfileFormUniformMixturePeak.lean`.  The
  consequence is that peakedness of `R` is **window-relative**, so the reported
  hump certifies a feature of the analysed range rather than a defect of the
  baseline.
* *Could the winner be an exponential / logistic / linear profile in disguise?*
  No — the log-midpoint defect `f(t−h)f(t+h) − f(t)²` is strictly positive for a
  power law with `b > 0` and `≤ 0` for all three rivals
  (`powerProfile_ne_expProfile`, `..._ne_logisticProfile`, `..._ne_affineProfile`).
* *Does the bootstrap interval decide the total mass of the profile?*  No — it
  straddles the integrability threshold `b = 1`
  (`exponent_bootstrap_straddles_threshold`).  This is a *negative* finding
  extracted from the data, and it is the sharpest falsifiable prediction of the
  cycle: pushing the CI strictly above `1` is what would settle it.

## 5b. Exponent sweep: the hump switches off

Sweeping `b` and locating the sign change of the exact log-derivative
`g(x) = 1/x - b/(1+x) - 1/(e^x - 1)` (bisection on a logarithmic grid, plain
floating point — **not** a formal verification) shows that the hump of the
uniform-mixture residual exists only for small `b`:

| b | 1.02 | 1.05 | 1.104 | 1.15 | 1.16 | 1.17 | 1.2 | 1.5 |
|---|------|------|-------|------|------|------|-----|-----|
| hump? | yes | yes | yes | yes | yes | no | no | no |
| hump position | 50.0 | 20.0 | 9.55 | — | — | — | — | — |
| `1/(b-1)` | 50.0 | 20.0 | 9.62 | 6.67 | 6.25 | 5.88 | 5.0 | 2.0 |

Two things are visible.  First, wherever a hump exists its position agrees with
the closed form `1/(b-1)` to within `0.07`, and the agreement improves as
`b → 1⁺` — this is the content of the proved `tailResidual_unique_max`
(`x* = 1/(b-1)` exactly for the elementary factor) together with the
`1 - e^{-x₀}` transfer bound of `uniformResidual_hump_confined`.  Second, the
hump disappears between `b = 1.16` and `b = 1.17`; the same bisection puts the
critical exponent at `b_c ≈ 1.1605`.

The *proved* statements bracketing this are `uniformResidual_peak` (a hump at
`b = 11/10`) and `uniformMixtureResidual_strictAntiOn` (strict decrease on all
of `(0,∞)` for every `b ≥ 3/2`), so `b_c ∈ (1.1, 1.5)` is rigorous while the
value `1.1605` is not.  The measured exponent `1.104` and the bootstrap interval
`[0.991, 1.218]` straddle the numerical `b_c`.

## 6. Sequences

No integer sequence is generated by this analysis (all objects are real-valued
profiles), so no OEIS lookup applies.  The one discrete object that does appear,
the harmonic partial sum of the critical profile `b = 1`, is `H_n` (OEIS A001008
/ A002805 for numerators/denominators); the proved statement about it is
`harmonic_sum_ge_log : log (n+1) ≤ ∑_{j<n} 1/(j+1)`.
