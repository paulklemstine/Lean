# Computational Evidence — the "prime fractal" `P = {1/log p : p prime} ⊂ ℝ`

All numbers below come from an exploratory Python sieve (primes up to `10^7`) and are
**not** machine-verified; they were used only to choose the right conjectures before
formalising.  Every mathematical claim in `Catalog/NumberTheory/PrimeFractal*.lean`
is proved in Lean 4 with no `sorry` and no extra axioms.

## 1. Box counting for the prime fractal

At scale `1/m` we count the boxes `[k/m, (k+1)/m)` that contain a point `1/log p`,
i.e. the number of distinct values `⌊m / log p⌋`.

* `N_obs(m)` — distinct values of `⌊m/log p⌋` over primes `p ≤ 10^7`.
* `k_min = ⌊m / log 10^7⌋` — boxes with index `< k_min` can only be reached by primes
  larger than `10^7`; they are (heuristically, and provably for `k` small) all occupied.
* `N_full = N_obs + (unseen boxes below k_min)`.

| m | N_obs(m) | k_min | N_full(m) | log N_full / log m | N_full · log m / m |
|---:|---:|---:|---:|---:|---:|
| 10^2 | 32 | 6 | 38 | 0.7899 | 1.7500 |
| 10^3 | 165 | 62 | 227 | 0.7853 | 1.5681 |
| 10^4 | 953 | 620 | 1573 | 0.7992 | 1.4488 |
| 10^5 | 5635 | 6204 | 11839 | 0.8147 | 1.3630 |
| 10^6 | 32443 | 62042 | 94485 | 0.8292 | 1.3054 |
| 10^7 | 164545 | 620420 | 784965 | 0.8421 | 1.2652 |

Two readings:

1. `N(m) · log m / m` stays in the narrow band `1.3 ± 0.2` and decreases slowly —
   strong evidence for `N(m) = Θ(m / log m)`, which is exactly what
   `PrimeFractal.eventually_boxCount_le` (`N(m) ≤ 5m/log m`) and
   `PrimeFractal.eventually_boxCount_ge` (`N(m) ≥ m/(16 (log m)^4)`) bracket.
2. The naive box-dimension estimate `log N(m)/log m` is **0.84 at m = 10^7**, and
   `1 − log log m / log m = 0.828` fits it to two decimals.  So the empirical
   exponent creeps up to `1` only logarithmically:

   | m | predicted `1 − log log m / log m` |
   |---:|---:|
   | 10^7 | 0.828 |
   | 10^12 | 0.880 |
   | 10^100 | 0.976 |

   **The mission's proposed test ("box-count up to `10^12` and check the dimension is
   close to 1, or slightly above") would have returned ≈ 0.88, never a value > 1.**
   The limit is nevertheless exactly `1` (`PrimeFractal.tendsto_boxCount_log_div`).

## 2. Total `d`-length of the primes

The mission claims `∑_{p ≤ x} d(p, next p) ∼ log log x → ∞`.  The sum telescopes:

`∑_{i<n} (1/log p_i − 1/log p_{i+1}) = 1/log 2 − 1/log p_n → 1/log 2 = 1.442695…`

Numerically, with `p_n` the largest prime below `10^7`, the partial sum is
`1.442695 − 1/16.118 = 1.380655`, and the truncation error decays like `1/log x`.
Formalised as `PrimeFractal.tendsto_primeFractal_length`.
(The mission also mis-identifies `∑_p 1/(p log p)`, which converges, with
`∑_p 1/p ∼ log log x`, which diverges.)

## 3. Twin-prime scale

For a twin pair `(p, p+2)`, `d = 1/log p − 1/log(p+2)`:

| p | d(p, p+2) | 1/(p log p) | 2/(p (log p)^2) |
|---:|---:|---:|---:|
| 11 | 2.716e-2 | 3.791e-2 | 3.162e-2 |
| 101 | 9.167e-4 | 2.145e-3 | 9.297e-4 |
| 1000003 | 1.048e-8 | 7.238e-8 | 1.048e-8 |

The mission's stated twin scale `1/(p log p)` is too large by a factor `≍ log p`;
the correct scale is `2/(p (log p)^2)`, proved as `PrimeFractal.twin_dist_le`.

## 4. Counterexample hunt (Hausdorff dimension)

No search is needed: `P` is countable, and every countable subset of a metric space
has Hausdorff dimension `0` — a one-line consequence of countable stability of
Hausdorff measure.  This is `PrimeFractal.dimH_primeFractal`, and it kills the
conjecture `dim_H = 1` and every variant `dim_H = 1 + ε`.  The interesting content
therefore had to migrate to the *box-counting* dimension, where the answer is `1`
exactly, with a logarithmic defect (§1) and no `ε`.

## 5. OEIS

The sequence of occupied-box counts `N_obs(m)` for `m = 10^e` (32, 165, 953, 5635,
32443, 164545) is scale-dependent bookkeeping rather than a canonical integer
sequence; no OEIS match was expected or found.  The underlying arithmetic sequence
is simply `π(x)` (A000720).
