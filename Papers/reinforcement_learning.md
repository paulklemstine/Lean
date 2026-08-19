# Computational Evidence — RLHF/PTX objective meets Dirichlet number theory

All numbers below come from a direct floating-point evaluation of the finite-space
objective

```
J_β(q) = Σ_y q(y) r(y) − β Σ_y q(y) log(q(y)/p(y)) ,   V(β) = β log Σ_y p(y) e^{r(y)/β}
```

They are *exploratory* evidence gathered before formalization; the theorems themselves are
proved from scratch in the Lean files (`Catalog/NumberTheory/RLHF*.lean`) and do not rely on
these computations.

## 1. Gibbs optimality (finite response space, von Mangoldt reward)

`N = 20`, reward `r(i) = Λ(i)`, uniform SFT reference `p`, `β = 0.7`:

| quantity | value |
|---|---|
| best of 50 000 random policies `J_β(q)` | 1.3364264 |
| `J_β(π_β)` at the Gibbs policy | 1.7640380 |
| `β log Z(β)` (free energy) | 1.7640380 |

No sampled policy beat the free energy, and the Gibbs policy attained it to machine
precision — matching `objective_gibbs` and `variational_principle`.

## 2. Free-energy spectrum for the von Mangoldt reward `Λ` on `{1,…,N}`

| N | ψ(N)/N | V(0.1) | V(0.5) | V(1) | V(2) | V(10) | log N |
|---|---|---|---|---|---|---|---|
| 10 | 0.78320 | 1.71909 | 1.18512 | 0.99325 | 0.88790 | 0.80381 | 2.30259 |
| 50 | 0.98971 | 3.51672 | 2.67834 | 2.03078 | 1.50439 | 1.08112 | 3.91202 |
| 100 | 0.94045 | 4.17885 | 3.24598 | 2.44755 | 1.68690 | 1.06484 | 4.60517 |
| 500 | 1.00330 | 5.79664 | 4.77601 | 3.78564 | 2.50404 | 1.23256 | 6.21461 |
| 2000 | 0.99723 | 7.15720 | 6.04997 | 4.93826 | 3.26722 | 1.31841 | 7.60090 |

Observations, all subsequently proved in `RLHFTemperatureSpectrum.lean`:

* every row satisfies `ψ(N)/N < V(β) < log N` (`vonMangoldt_freeEnergy_ge_chebyshev`,
  `vonMangoldt_freeEnergy_le_log`, `vonMangoldt_strict_improvement`);
* `V` is strictly decreasing along each row (`freeEnergy_antitone`);
* the column `ψ(N)/N` hovers around 1, the elementary Chebyshev/PNT normalization.

## 3. Euler factorization of the aligned (zeta) policy

`s = 1.3`, primes `p = 2`, `q = 3`, exponent caps `A = 5`, `B = 4`:

```
Σ_{a≤5, b≤4} (2^a 3^b)^{-s} = 2.2031653077554383
(Σ_{a≤5} 2^{-as})(Σ_{b≤4} 3^{-bs}) = 2.203165307755438     (difference 4.4e-16)
Σ_{a≤5} 2^{-as} = 1.6763038  <  (1 − 2^{-s})^{-1} = 1.6838594
```

matching `zeta_partition_factorizes`, `localZeta_lt_euler_factor` and `euler_factor_tsum`.

## 4. The PTX alignment tax

`N = 6`, `β = 1`, `γ = 0.5`, pretraining distribution `d(n) ∝ n`, uniform SFT reference,
von Mangoldt reward. The theoretical ceiling is `β log Z − γ H(d) = 0.0161094`; the best of
200 000 sampled policies reached `−0.0616873`, a strictly positive gap of `0.0777967`.
The ceiling is provably unattainable whenever `π_β ≠ d`, which is `alignment_tax`.

## 5. Counterexample hunt

* Sampled 50 000 policies at `β = 0.7` looking for `J_β(q) > β log Z`: none found
  (max deviation `−0.428`).
* Sampled temperature pairs `β₁ < β₂` for `N ≤ 2000` looking for `V(β₂) > V(β₁)`: none.
* Sampled `(p,q,A,B,s)` with `p, q` distinct primes looking for failure of the Euler
  factorization: none (all differences below `10⁻¹⁴`).
* Searched for `N ≥ 2` with `ψ(N)/N = V(β)` (i.e. no alignment gain): none — consistent
  with the strict-improvement theorem, whose engine is `Λ(1) = 0 ≠ log 2 = Λ(2)`.

No OEIS lookup was relevant: the sequences appearing (`ψ(N)`, truncated zeta sums) are
classical and real-valued rather than integer sequences.

## 6. Prime discovery at low temperature (evidence for `RLHF.prime_discovery`)

With the von Mangoldt reward and the uniform reference on `{1,…,N}`, the aligned policy
weights a prime power `p^k` by `p^{1/β}` and every other response by `1`.  Sampling
probability of the prime-power set:

| N | threshold β = log 2 / log N | ρ(β) | ρ(2β) |
|---|---|---|---|
| 10 | 0.3010 | 0.9969 | 0.9536 |
| 100 | 0.1505 | 1.0000 | 1.0000 |
| 1000 | 0.1003 | 1.0000 | 1.0000 |

The proved bound `ρ ≥ 1/2` for `β log N ≤ log 2` is therefore correct but conservative;
the empirical threshold sits substantially higher, which is what Conjecture 1 of
`FUTURE_DIRECTIONS.md` quantifies.

---

# Cycle 2 evidence (spectral rigidity, schedule collapse, log-convexity, monotone mass)

All numbers below were produced with Lean's own evaluator (`#eval`, `Float` arithmetic) on
the same definitions that the theorems use.

## 7. Schedule collapse (evidence for `RLHF.schedule_collapse`)

Response space of size 4, uniform reference, rewards
`r₁ = (0, 0.693, 1.099, 1.386)` and `r₂ = (0.5, −0.2, 0, 1)`.

| computation | resulting policy |
|---|---|
| two steps: `β₁ = 0.5` with `r₁`, then `β₂ = 2` with `r₂` | `(0.031883, 0.089843, 0.223646, 0.654628)` |
| one step at `β = 1` with reward `2 r₁ + 0.5 r₂` | `(0.031883, 0.089843, 0.223646, 0.654628)` |

Agreement to all printed digits, as predicted by `RLHF.gibbs_schedule_two` with
`β/β₁ = 2`, `β/β₂ = 0.5`.

## 8. Spectral rigidity (evidence for `RLHF.freeEnergy_rigidity`)

Same space, `t = 1/β = 0.7`, uniform reference:

| reward vector | `Z(t)` |
|---|---|
| `(0, 0.693, 1.099, 1.386)` | `1.855266` |
| `(1.386, 0, 1.099, 0.693)` (a permutation: same spectrum) | `1.855266` |
| `(0, 0.693, 1.099, 1.400)` (spectrum perturbed by `0.014`) | `1.861762` |

Permutations — i.e. reward models with the same spectrum — are invisible to the curve, and
the smallest perturbation of the spectrum is visible.  This is exactly the boundary drawn by
the theorem: the curve determines the spectrum, and nothing finer.

## 9. Log-convexity of truncated Dirichlet series (evidence for `RLHF.zetaSum_sq_le`)

`ζ_N(s) = ∑_{n ≤ N} n^{-s}` with `N = 50`:

| midpoint `s` | `ζ_N(s)²` | `ζ_N(s₁) ζ_N(s₂)` |
|---|---|---|
| `1.5 = (1.0+2.0)/2` | `5.433280` | `7.311806` |
| `2.0 = (0.5+3.5)/2` | `2.641056` | `14.368250` |

Both inequalities hold with a wide margin, and the margin widens as the endpoints separate,
as Cauchy–Schwarz predicts.

## 10. Monotone prime-power mass (evidence for `RLHF.vonMangoldt_primePower_mass_antitone`)

Prime-power probability `ρ_N(β)` of the aligned von Mangoldt policy, `N = 100`
(threshold of `RLHF.prime_discovery`: `log 2 / log 100 = 0.150515`):

| β | 0.15 | 0.3 | 0.6 | 1.0 | 3.0 |
|---|---|---|---|---|---|
| ρ₁₀₀(β) | 1.000000 | 0.999997 | 0.996039 | 0.943772 | 0.593799 |

Strictly decreasing in `β`, in agreement with the proved antitonicity, and still above `1/2`
well beyond the proved threshold — the quantitative gap that Conjecture 1 addresses.

## 11. Curvature of the value curve (evidence for `RLHF.deriv2_logExpMoment_eq_tiltVar`)

Reward spectrum `r = (0, 1, 3)` on three responses with the uniform reference policy.
Comparison of the centred second difference of `log Z(t)` (step `h = 10⁻³`) with the reward
variance `Var_{π_t}(r) = M₂/M₀ − (M₁/M₀)²`, both evaluated in Lean (`Float`):

| `t` | second difference of `log Z` | `Var_{π_t}(r)` |
|---|---|---|
| `0.5` | `1.407086` | `1.407086` |
| `−1.0` | `0.442450` | `0.442450` |

Agreement to all displayed digits, matching the proved identity `(log Z)'' = Var_{π_t}(r)`.
Both values are strictly positive, as `RLHF.tiltVar_pos` requires for a non-constant reward,
and this is what makes the value curve *strictly* convex
(`RLHF.strictConvexOn_logExpMoment`).

## 12. Strict log-convexity of the truncated zeta function (evidence for
`RLHF.strictConvexOn_truncZetaLog`)

`ζ_N(s) = ∑_{n ≤ N} n^{-s}` with `N = 5`, at the midpoint `1.5 = (1.0 + 2.0)/2`:

| `ζ_5(1.5)²` | `ζ_5(1.0) · ζ_5(2.0)` |
|---|---|
| `3.099171` | `3.341912` |

Strict inequality, as the proved strict convexity predicts for `N ≥ 2` (the reward model
`n ↦ −log n` is non-constant exactly then; for `N = 1` the curve is affine and the
inequality degenerates to an equality).

## 13. Sharpness of the alignment speed limit (evidence for
`RLHF.popoviciu_constant_sharp` and `RLHF.tiltMean_drift_constant_sharp`)

Two-atom reward `r ∈ {0, 1}` with balanced reference.  Reward variance
`Var_{π_t}(r) = e^t/(1+e^t)²` (Lean `Float` evaluation):

| `t` | `0.0` | `0.5` | `1.0` | `2.0` |
|---|---|---|---|---|
| `Var_{π_t}(r)` | `0.250000` | `0.235004` | `0.196612` | `0.104994` |

The maximum `1/4` is attained exactly at `t = 0`, where the tilted policy splits its mass
evenly — the equality case described by `RLHF.tiltVar_eq_range_sq_iff`.  Difference quotients
of the aligned reward at the origin approach the same constant:

| `h` | `0.1` | `0.01` | `0.001` |
|---|---|---|---|
| `(𝔼_{π_h}[r] − 𝔼_{π_0}[r])/h` | `0.249792` | `0.249998` | `0.250000` |

so no drift constant below `1/4` can hold, which is `RLHF.tiltMean_drift_constant_sharp`.

## 14. Curvature of a local Euler factor (evidence for
`RLHF.localZeta_curvature_eq_variance`)

`localZeta s p A = ∑_{k ≤ A} p^{-ks}` with `p = 2`, `A = 3`, at `s = 1.5`.  Centred second
difference of `log localZeta` (step `h = 10⁻³`) against the variance of `k log p` under the
truncated geometric law on exponents:

| second difference of `log localZeta` | `Var(k log p)` |
|---|---|
| `0.282525` | `0.282525` |

Agreement to all displayed digits, matching the proved identity.

## 15. Three temperatures do not identify a two-atom spectrum (evidence for
`RLHF.prony_three_samples_insufficient_spectra`)

Spectrum A: levels `{log 1, log 3}` with masses `(1/2, 1/2)`.
Spectrum B: levels `{log(3/2), log 4}` with masses `(4/5, 1/5)`.
Partition functions `Z(t)`:

| `t` | `0` | `1` | `2` | `3` |
|---|---|---|---|---|
| `Z_A(t)` | `1.000000` | `2.000000` | `5.000000` | `14.000000` |
| `Z_B(t)` | `1.000000` | `2.000000` | `5.000000` | `15.500000` |

The two spectra are indistinguishable at the three temperatures `t = 0, 1, 2` and separate at
`t = 3` — exactly the `2n = 4` Prony count for `n = 2` atoms.  With the levels *known*, by
contrast, `n` temperatures already suffice (`RLHF.spectral_rigidity_sampled_general`).
