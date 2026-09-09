# Computational evidence — "Constrained = penalised" (Tropical, cycle v19c)

**Status of this document.** Everything below is *exploratory* double-precision numerics used to
choose and sanity-check the statements before formalising them. It is **not** a verification.
The verified content is the two Lean files, which build with `0` sorries and depend only on
`propext`, `Classical.choice`, `Quot.sound`:

* `Catalog/Tropical/ConstrainedEqualsPenalised.lean`
* `Catalog/Tropical/ConstrainedPenalisedFrontier.lean`

Setting: finite outcome set, reference (SFT) policy `π₀` with `π₀(i) > 0`, reward `r`,
tilted family `p_t(i) ∝ π₀(i) e^{t r(i)}` with `t = 1/β`,
`k(t) = KL(p_t‖π₀)`, `V(t) = 𝔼_{p_t}[r]`,
tropical ceiling `L = -log π₀(argmax r)`.

## 1. Small-case sweeps

### A. `π₀ = (1/2, 1/2)`, `r = (0, 1)` — `max r = 1`, argmax mass `0.5`, `L = 0.693147`

| t | k(t) | V(t) | log Z(t)/t |
|---|------|------|-----------|
| 0.00 | 0.000000 | 0.500000 | – |
| 0.25 | 0.007752 | 0.562177 | 0.531169 |
| 0.50 | 0.030300 | 0.622459 | 0.561860 |
| 1.00 | 0.110944 | 0.731059 | 0.620115 |
| 2.00 | 0.327813 | 0.880797 | 0.716890 |
| 4.00 | 0.603052 | 0.982014 | 0.831251 |
| 8.00 | 0.690129 | 0.999665 | 0.913399 |
| 16.0 | 0.693145 | 1.000000 | 0.956678 |
| 32.0 | 0.693147 | 1.000000 | 0.978339 |

### B. `π₀ = (0.7, 0.2, 0.1)`, `r = (0, 1, 3)` — argmax mass `0.1`, `L = 2.302585 = log 10`

| t | k(t) | V(t) | log Z(t)/t |
|---|------|------|-----------|
| 0.25 | 0.035097 | 0.763287 | 0.622901 |
| 1.00 | 0.840620 | 2.019955 | 1.179335 |
| 2.00 | 2.012213 | 2.881102 | 1.874995 |
| 4.00 | 2.295992 | 2.998530 | 2.424532 |
| 16.0 | 2.302585 | 3.000000 | 2.856088 |

### C. Degenerate argmax, `π₀` uniform on 4 points, `r = (0,1,1,2)` — `L = log 4 = 1.386294`

| t | k(t) | V(t) |
|---|------|------|
| 1 | 0.221888 | 1.462117 |
| 4 | 1.206105 | 1.964028 |
| 16 | 1.386291 | 2.000000 |

### D. **Tied** maximiser, `π₀ = (0.5,0.3,0.2)`, `r = (2,2,0)` — argmax mass `0.8`, `L = 0.223144`

| t | k(t) | V(t) |
|---|------|------|
| 1 | 0.124416 | 1.934547 |
| 4 | 0.222389 | 1.999832 |
| 16 | 0.223144 | 2.000000 |

This case is the one that fixes the *right* form of the ceiling: `L` is **not** `-log min π₀`
and **not** `log n`; it is `-log π₀(argmax r)`, here `-log 0.8 = 0.2231`, and the numerics agree
to 6 digits. A ceiling of the naive form `log n = log 3 = 1.0986` would be badly wrong.

Observations, all consistent with the formalised theorems:

* `k` is strictly increasing and `V` is strictly increasing in `t`
  (`klCurve_strictMonoOn`, `expect_tilted_mono`);
* `k(t) < L` always, and `k(t) → L` (`klCurve_lt_tropicalCeiling`,
  `klCurve_tendsto_tropicalCeiling`);
* `V(t) → max r` (`expect_tendsto_rewardMax`);
* `log Z(t)/t → max r` (`tropical_limit_of_logPartition`, Maslov dequantization).

Caveat: at `t ≳ 32` the printed test `k(t) < L` flips to `False` in a handful of rows.
This is double-precision saturation (`k(t)` and `L` agree to all 53 bits), **not** a
counterexample: the strict inequality is a theorem, `klCurve_lt_tropicalCeiling`.

## 2. Counterexample hunt

Random instances (`n ∈ {2,…,5}`, `π₀` random on the simplex with entries `≥ 0.05/S`,
`r` uniform on `[-3,3]`), 20 000 trials each:

| claim tested | violations |
|---|---|
| shadow-price bracket `s·ΔV ≤ Δk ≤ t·ΔV` for `0 < s ≤ t` | **0 / 20000** |
| frontier concavity `(k_u-k_t)(V_t-V_s) ≥ (k_t-k_s)(V_u-V_t)` for `s ≤ t ≤ u` | **0 / 20000** |

Both are now theorems (`shadow_price_bracket`, `frontier_concave`); the search was used
beforehand to confirm the inequality directions and to discover that the bracket needs
**no** ordering hypothesis at all (it holds for arbitrary `s, t`), which is how the final
Lean statement is phrased.

## 3. Falsified variants (why the statements look the way they do)

* *"`k(t) ≤ log n` is the right ceiling."* False for case D (`k(t)` saturates at `0.223`,
  far below `log 3`). Replaced by the tropical ceiling.
* *"`k` is strictly increasing for every reward."* False for constant `r`: then `p_t = π₀`
  for all `t` and `k ≡ 0`. Hence the non-constancy hypothesis `∃ i j, r i ≠ r j`, which
  `tilted_eq_imp_reward_const` shows is exactly the obstruction.
* *"The achievable range is closed, `[0, L]`."* False: `L` is a supremum that is never
  attained at finite `β`, which is why the main theorem is stated on `0 < k < L`.

## 4. No OEIS entry

No integer sequence arises here: all quantities are transcendental functions of the
temperature. An OEIS search was therefore not applicable.
