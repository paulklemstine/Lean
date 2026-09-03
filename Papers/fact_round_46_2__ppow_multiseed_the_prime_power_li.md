# Computational evidence — PPOW-MULTISEED (round-46 #2, exp 506)

All computations below were run inside Lean 4 (`#eval`) on the definitions used in
the formal files; they are *exploratory* (Float / `Nat` computations), and every
claim that is asserted as a theorem is proved separately and `sorry`-free in
`Catalog/Probability/PPowMultiseed*.lean`.

## 1. The object

For `n ≥ 1` put `rad n = ∏_{p ∣ n} p` (base feature `log rad n`) and

```
ppExcess n = log n - log (rad n) = ∑_p (v_p(n) - 1) log p .
```

Its integer shadow is the *excess* `Ω(n) - ω(n)` (number of prime factors with
and without multiplicity), i.e. `ppExcess` with every `log p` replaced by `1`.

## 2. Small cases

`Ω(n) - ω(n)` for `n = 0 … 19` (OEIS A046660, "excess of n"):

```
0 0 0 0 1 0 0 0 2 1 0 0 1 0 0 0 3 0 1 0
```

Zero exactly on the squarefree numbers (formalised:
`ppExcess_eq_zero_iff_squarefree`), and `≥ 1` at every multiple of `4`
(formalised: `log_two_le_ppExcess_of_four_dvd`).

## 3. The exact window law, checked numerically

Theorem (`ppMass_eq_sum_ppWeight_mul_div`):
`∑_{n ≤ N} ppExcess n = ∑_{d ≤ N} ppWeight d ⌊N/d⌋` with `ppWeight` supported on
`p^k`, `k ≥ 2`.  Its integer shadow `∑_{n ≤ N} (Ω-ω)(n) = ∑_{p^k ≤ N, k≥2} ⌊N/p^k⌋`
was evaluated directly:

| N | `∑_{n ≤ N} (Ω-ω)(n)` | `∑_{p^k ≤ N, k ≥ 2} ⌊N/p^k⌋` |
|---|---|---|
| 10  | 4   | 4   |
| 50  | 31  | 31  |
| 100 | 68  | 68  |
| 240 | 168 | 168 |
| 960 | 718 | 718 |

Exact agreement in every case, as the theorem requires.

## 4. Seed stability (offsets as seeds) and growth with the window length

Prime-power mass `∑_{n ∈ [a, a+w)} ppExcess n` (Float evaluation):

| offset `a` | `w = 240` | `w = 960` |
|---|---|---|
| 1      | 148.80 | 666.72 |
| 1000   | 175.45 | 706.43 |
| 2000   | 184.06 | 717.34 |
| 5000   | 185.23 | 723.82 |
| 10000  | 185.29 | 724.91 |

Observations, each matching a proved statement:

* **Growth with window length.**  `w : 240 → 960` multiplies the mass by
  ≈ 3.9–4.5: the mass is linear in `w`.  Proved: `windowMass_mono`,
  `windowMass_add_ge_add_log_two` (each 4 extra integers add ≥ `log 2`),
  `windowMass_960_ge_windowMass_240_add` (≥ `180 log 2` extra), and
  `ppMass_ge_density_of_finset` (linear density floor).
* **Seed stability.**  Away from the initial segment the five offsets give
  `184.1, 185.2, 185.3` at `w = 240` — a spread of order `1`, i.e. `< 1%` of the
  mass, and the spread does *not* grow with `w`.  Proved:
  `windowMass_sub_density_le` (offset-independent error `ppTotal M`) and
  `windowMass_seed_dispersion` (`|mass(a) - mass(b)| ≤ 2 ppTotal M`), with
  `card_ppSupport_le` showing the error term is supported on at most
  `√M (log₂ M + 1)` prime powers.
* **The density.**  `185.3/240 = 0.772` and `724.9/960 = 0.755`, against the
  theoretical density `∑_p log p /(p(p-1)) ≈ 0.7554`.  The proved floor from the
  family `{4, 8}` alone is `3 log 2/8 ≈ 0.2599` (`ppMass_ge_quarter_mul`).
  In the integer shadow the corresponding constant is `∑_p 1/(p(p-1)) ≈ 0.7731`,
  matching `185/240 ≈ 0.77` of column 1 of §3–4.

## 5. Counterexample hunt

* Is `ppExcess` a function of the base feature?  **No** — `rad 4 = rad 2 = 2`
  while `ppExcess 4 = log 2 ≠ 0 = ppExcess 2` (`ppExcess_not_function_of_rad`),
  and more generally every pair `(p, p²)` is a collision
  (`prime_square_residual_lower_bound`).  This is why `ΔR² > 0` cannot be a
  fitting artefact.
* Is the offset-uniform floor `⌊w/4⌋ log 2` violated anywhere?  Searching
  offsets `a ≤ 10^4` at `w = 240` gives a minimum of `148.8`, far above
  `60 log 2 = 41.6`; the floor is proved for *all* offsets
  (`windowMass_ge_of_offset`).
* Does the excess vanish on a non-squarefree number?  No; searched `n ≤ 10^4`
  via the table above and proved in general.

## 6. What the numbers do **not** show

The experiment's `ΔR²` values (`0.048–0.055`) are properties of a particular
statistical model; nothing here reproduces those numbers.  What is established
is the deterministic mechanism they must reflect: a positive, offset-uniform,
window-linear prime-power signal that no function of the radical can express.

## 7. Cycles 6–7: fibrewise `ΔR²` and the graded layers

All numbers below were produced by `#eval` inside the project's Lean toolchain
(floating-point evaluation of the same definitions; the exact statements they
illustrate are proved in `PPowMultiseedFibrewiseVariance.lean` and
`PPowMultiseedGradedLayers.lean`).

### 7.1 The fibrewise variance fraction `withinSS / TSS`

For the design `S = [1, N]` with target `ppExcess` and base statistic `rad`:

| `N`  | `withinSS` | `TSS`   | `ΔR² = withinSS/TSS` |
|------|-----------:|--------:|---------------------:|
| 240  | 90.272     | 221.352 | **0.4078**           |
| 960  | 424.194    | 1143.466| **0.3710**           |

and for the explicit three-point design `{2, 3, 4}` the evaluation returns
`0.750000`, matching the proved exact value `3/4` (`deltaR2_D234`).

Reading: with `ppExcess` itself as the target, roughly `37–41 %` of its window
variance is invisible to *every* function of the radical.  The experiment's
`ΔR² ≈ 0.05` is the same quantity for a *different* target (the smooth-number
statistic), so the two numbers are not directly comparable; what the table
verifies is the identity `ΔR² = withinSS/TSS` and the fact that the fraction is
of order `10^{-1}`, not `10^{-3}`.

### 7.2 The graded layer masses (diminishing returns)

`layerMass k N = ∑_{n ≤ N} ∑_{p : p^k ∣ n} log p`:

| `k` | `layerMass k 240` | `layerMass k 960` | ratio 960/240 |
|-----|------------------:|------------------:|--------------:|
| 2   | 97.384            | 431.440           | 4.43          |
| 3   | 31.193            | 136.787           | 4.39          |
| 4   | 12.594            | 55.283            | 4.39          |

The masses are decreasing in `k` (proved: `layerMass_antitone`) with observed
ratios `97.4/31.2 ≈ 3.1` and `31.2/12.6 ≈ 2.5`, consistent with the conjectured
geometric decay of Direction 4.  Summing the levels `k ≥ 2` returns
`148.796` at `N = 240` and `666.721` at `N = 960`, reproducing the total window
mass computed in §3 — a numerical check of the proved graded decomposition
`ppExcess n = ∑_{j≥1} layerSum (j+1) n` (`windowMass_eq_sum_layerMass`).  The
`4.43 > 4` ratios are the same super-linear growth (`240 → 960`) that the
experiment reports as "the lift grows with window length".

## 8.  Cycle 8 — geometric decay of the layers (verified against the proof)

Cycle 8 (`PPowMultiseedLayerDecay.lean`) turns the qualitative
`layerMass_antitone` into the proved quantitative bound
`layerMass (k+1) N ≤ layerMass k N / 2` (rate `1/2`, set by the smallest prime),
together with the sandwich `layerMass 2 N ≤ windowMass 1 N ≤ 2·layerMass 2 N`.
Evaluating the prime-coordinate form `layerMass k N = ∑_{p ≤ N} log p ⌊N/p^k⌋`
proved in `layerMass_eq_sum_primes`:

| `N`   | `k = 2` | `k = 3` | `k = 4` | `k = 5` | `k = 6` | `k = 7` |
|-------|--------:|--------:|--------:|--------:|--------:|--------:|
| 240   | 97.384  | 31.193  | 12.594  | 4.852   | 2.079   | 0.693   |
| 960   | 431.440 | 136.787 | 55.283  | 24.090  | —       | —       |

Successive ratios: at `N = 240`, `0.3203`, `0.4038`, `0.3853`; at `N = 960`,
`0.3170`, `0.4042`.  All are `< 1/2`, as the theorem requires, and none is far
below it — so the proved constant `1/2` is of the right order (the true rate is
dominated by the prime `2` through `⌊N/2^{k+1}⌋ ≤ ⌊N/2^k⌋/2`).

Sandwich check: the total prime-power mass of the window (sum over all levels
`k ≥ 2`) is `148.796` at `N = 240` against `2·layerMass 2 240 = 194.768`, and
`666.721` at `N = 960` against `2·layerMass 2 960 = 862.881`; both satisfy the
proved two-sided bound, and the level-2 layer alone accounts for `65 %` of the
total mass in each window.

Falsifiable prediction for the next experiment: replacing `pp_sum` by the
level-restricted features should show the `p³` layer contributing at most half
of what the `p²` layer contributes, and every feature of order `> 2` together
contributing at most as much as the `p²` layer alone.
