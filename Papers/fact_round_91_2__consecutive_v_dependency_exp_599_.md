# Computational evidence

All numbers below were produced by exact rational (`ℚ`) computation inside Lean
(`#eval`), on scratch models mirroring the definitions of
`Catalog/Bridges/ConsecutiveVDependency.lean` and
`Catalog/Bridges/PositionalAutocorrelationBias.lean`.  They are *exploratory
checks* that guided and cross-validated the formal statements; the statements
themselves are proved in the two Lean files (0 sorries, only the standard
axioms).  Evaluations are exact, not floating point.

## 1. The product-Bernoulli model on a smooth hump curve

Scan length `n = 6`, rate curve
`p i = 1/2 + (i/60 for i ≤ 3, (6-i)/60 otherwise)` — a smooth hump inside
`[0.45, 0.55]`, the C2 control shape.

| quantity | computed value | prediction |
|---|---|---|
| total mass `Σ_s w(s)` | `1` | `1` (`bernExp_mass`) |
| `E[X₂]` | `8/15` | `p 2 = 8/15` (`bernExp_hit`) |
| `E[Σᵢ (Xᵢ-pᵢ)(Xᵢ₊₁-pᵢ₊₁)]`, lag 1, m = 5 | `0` | `0` (`bernExp_detrended_pairSum_eq_zero`) |
| same at lag 2, m = 4 | `0` | `0` |
| `E[(detrended lag-1 sum)²]` | `200839/648000 ≈ 0.30994` | `Σᵢ vᵢ vᵢ₊₁ = 200839/648000` (`bernExp_centeredPairSum_sq`) |

The variance identity matched **exactly**, including the overlapping pairs
`(i, i+1)` and `(i+1, i+2)` that share a position — the case that makes the
uncorrelatedness argument nontrivial.

## 2. How much autocorrelation the density curve can fake (control C2)

Same curve, literal (global-mean) centring at `p̄ = 21/40`:

* `E[raw lag-1 sum] = 7/14400 ≈ 4.86e-4`;
* normalised by `m·v` with `v = 99/400`: `7/17820 ≈ 3.9e-4`.

The proved uniform bound is `δ²/v = (1/20)²/(99/400) ≈ 0.0101`
(`spurious_autocorrelation_bound`), five times below the pre-registered `0.05`
bar (`curvature_cannot_fake_H1`).  The realised value is another order of
magnitude smaller, consistent with the reported C2 outcome (max `.014` on the
synthetic hump).

## 3. The Markov alternative (control C3)

Two-state chain, `a = P(0→1) = 1/5`, `b = P(1→0) = 1/4`, so `λ = 11/20`:

```
ρ(1..6) = [11/20, 121/400, 1331/8000, 14641/160000, 161051/3200000, 1771561/64000000]
λ^(1..6) = identical
```

Exact geometric decay, argmax at lag 1 (`markovCorr_eq_lambda_pow`,
`markov_profile_peaks_at_lag_one`).  Calibrating to the injected value of the
experiment, `a = b = 663/2000` gives `λ = 337/1000` and

```
ρ(1) = 0.337,  ρ(2) = 0.113569 = 0.337²,
```

i.e. exactly the injected lag-1 amplitude with the argmax at lag 1 — the shape
control C3 recovered.

## 3b. The coincidence (MA-1) scan

Latent independent scan of length `8` with constant rate `q = 2/5`, coincidence
observable `Y i = X i · X (i+1)`:

| quantity | computed | prediction |
|---|---|---|
| `E[Y₀]` | `4/25` | `q² ` (`bernExp_maHit`) |
| lag-1 autocovariance | `24/625` | `q³(1-q) = 24/625` (`maCov_lag_one`, proved for an arbitrary latent rate curve) |
| lag-2 autocovariance | `0` | `0` (`maCov_lag_ge_two`) |
| lag-3 autocovariance | `0` | `0` |
| lag-1 autocorrelation | `2/7` | `q/(1+q) = 2/7` (`maCorr_lag_one_const`) |

A one-spike profile: nonzero at lag 1, exactly zero afterwards — a shape no
Markov chain can produce (`ma_scan_not_markov`).

## 4. The mean-centring artefact

Cyclic record of length `n = 11` with support `{1,2,3,5,8}` (a cyclic
`(11,5,2)` difference set):

```
ρ(k) for k = 1..10 : [-1/10, -1/10, -1/10, -1/10, -1/10, -1/10, -1/10, -1/10, -1/10, -1/10]
average over nonzero lags : -1/10
```

Every lag sits at exactly `-1/(n-1) = -1/10`, with **no dependence whatsoever**
in the record: the profile is as flat and as negative as arithmetic allows.
This is the extreme case of `mean_autocorrelation_eq_neg_inv` and
`constant_profile_eq_neg_inv`, and it is the mechanism behind the recorded
"uniform ≈ −0.01 offset, 12/20 CIs excluding zero on the negative side": on a
window of about a hundred positions the forced level is `-1/100 = -0.01`
(`flat_profile_level_of_window`).

## 5. Noise-floor sanity check

`detrended_noise_floor` gives `P(|Σ| ≥ t·m) ≤ 1/(16 m t²)`.  At the
experiment's `m = 9594` and `t = 0.05` this is `25/9594 ≈ 0.0026`
(`detrended_noise_floor_experiment` states the rounded bound `≤ 0.003`).

## 6. No OEIS sequence

No integer sequence arises: all objects here are rational-valued statistics of a
rate curve, so an OEIS lookup is not applicable.

## 7. Counterexample hunt

The two claims most at risk of being false were tested before formalising:

* *"raw (global-mean) autocorrelation is zero under pure density"* — **false**,
  as the `7/14400 ≠ 0` computation above shows.  The formal statement was
  therefore weakened to the exact identity `bernExp_centeredPairSum` plus the
  bound `spurious_autocorrelation_bound`; only the *detrended* version is
  exactly zero.
* *"heterogeneity always lowers the alternation count"* — not true in general
  (the sign of the first-order term is `1 - 2c`), so
  `altCount_heterogeneity_bound` is stated as a two-sided bound with the
  `|1 - 2c|` factor, which vanishes at `c = 1/2`.

## 8. Difference-set record `{0, 1, 3} ⊆ ZMod 7`

The support has size `3`; its difference multiplicities `d_S(k) = #{a ∈ S : a + k ∈ S}`
are, for `k = 0, 1, …, 6`:

| k | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| d_S(k) | 3 | 1 | 1 | 1 | 1 | 1 | 1 |

so the mean-centred cyclic autocovariance `C(k) = d_S(k) − 9/7` is `12/7` at lag
`0` and `−2/7` at each of the six nonzero lags, giving a profile that is
*constant* at `(−2/7)/(12/7) = −1/6 = −1/(n−1)`.  This matches
`difference_set_profile_eq_neg_inv` exactly and is checked inside Lean by
`decide` in `fano_difference_set_diffMult` / `fano_difference_set_profile`
(`Catalog/Bridges/DifferenceSetFlatProfile.lean`) — a fully deterministic record
whose measured lag profile is flat and slightly negative, with no dependence
present.

## 9. Coincidence spike heights (exact rational evaluation)

With `rho a b c = c(1-b)/(1-ab)` — the closed form proved in
`maCorrProfile_lag_one_eq` for the lag-1 autocorrelation of the coincidence scan
with latent rates `a = p i`, `b = p (i+1)`, `c = p (i+2)` — exact `Rat`
evaluation gives

| (a, b, c) | rho | note |
|---|---|---|
| (1/2, 1/2, 1/2) | 1/3 | constant rate `q = 1/2`, matches `q/(1+q)` |
| (3/4, 1/4, 3/4) | 9/13 | alternating on `[1/4, 3/4]`, matches `u(1-l)/(1-ul)` |
| (9/10, 1/10, 9/10) | 81/91 | alternating on `[1/10, 9/10]`, above the homogeneous cap `1/2` |
| (99/100, 1/100, 99/100) | 9801/9901 | supremum `1` approached as the window opens |

Every entry agrees with `spikeBound l u = u(1-l)/(1-ul)` at `(a,b,c) = (u,l,u)`,
confirming `spikeBound_attained`, and the last row illustrates
`spike_amplitude_sup_one` (`9801/9901 > 1 - 1/99`) together with
`maCorrProfile_lag_one_lt_one` (still `< 1`).
