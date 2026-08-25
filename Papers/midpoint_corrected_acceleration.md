# Computational evidence — midpoint-corrected Euler–Mascheroni acceleration

All numbers below were produced with exact rational arithmetic plus 50–60 digit decimal
logarithms (Python `decimal`) using the reference value

`γ = 0.577215664901532860606512090082402431042159335939923598805767…`

They are *exploratory* evidence only. Every claim that survives is stated and proved in Lean
in `Catalog/Computation/EulerMascheroniMidpointAcceleration.lean`,
`Catalog/Computation/EulerMascheroniQuarticAcceleration.lean` and
`Catalog/Computation/EulerMascheroniSixthOrderAcceleration.lean`; the numerics below are not
a substitute for those proofs.

Notation: `m = n + 1`, `seq n = harmonic n - log (n+1)` (Mathlib's `Real.eulerMascheroniSeq`),

* `accelerated  n = seq n + 1/(2m)`
* `accelerated2 n = seq n + 1/(2m) + 1/(12m²)`
* `accelerated3 n = seq n + 1/(2m) + 1/(12m²) - 1/(120m⁴)`

## 1. First order: is `1/(12 m²)` the right constant, and from which `n` on?

| n | γ − accelerated n | 1/(12m²) | ratio |
|---|---|---|---|
| 0 | 7.722e-02 | 8.333e-02 | 0.926588 |
| 1 | 2.036e-02 | 2.083e-02 | 0.977417 |
| 2 | 9.161e-03 | 9.259e-03 | 0.989419 |
| 3 | 5.177e-03 | 5.208e-03 | 0.993925 |
| 5 | 2.308e-03 | 2.315e-03 | 0.997258 |
| 10 | 6.881e-04 | 6.887e-04 | 0.999177 |
| 50 | 3.204e-05 | 3.204e-05 | 0.999962 |
| 100 | 8.169e-06 | 8.169e-06 | 0.999990 |
| 1000 | 8.317e-08 | 8.317e-08 | 1.000000 |

**Findings.** (i) The error is *positive* for every sampled `n` — `accelerated n < γ` always.
(ii) The ratio is `< 1` everywhere and increases monotonically to `1`. So the threshold
asked for in the mission is `n ≥ 0`: no threshold is needed, and the constant `1/12` is not
improvable. This motivated proving the two-sided statement
`1/(12m²) − 1/(36m³) ≤ γ − accelerated n ≤ 1/(12m²)` rather than a bound valid only for
large `n`.

## 2. Counterexample hunt

Searched for a sign violation or a ratio `> 1` over `n = 0 … 2000` (and the sampled decades
above): none found. The closest approach to the bound from below is at `n = 0`
(ratio 0.9266), which is exactly the case a "sufficiently large n" formulation would have
thrown away.

## 3. Second order: what is the residual after subtracting `1/(12m²)`?

| n | accelerated2 n − γ | 1/(120 m⁴) | ratio |
|---|---|---|---|
| 0 | 6.1177e-03 | 8.3333e-03 | 0.734120 |
| 1 | 4.7049e-04 | 5.2083e-04 | 0.903337 |
| 2 | 9.7972e-05 | 1.0288e-04 | 0.952291 |
| 5 | 6.3474e-06 | 6.4300e-06 | 0.987140 |
| 10 | 5.6696e-07 | 5.6918e-07 | 0.996098 |
| 100 | 8.0078e-11 | 8.0082e-11 | 0.999953 |
| 1000 | 8.3001e-15 | 8.3001e-15 | 1.000000 |

**Finding.** The `m⁻³` term is *absent*: the error jumps straight from `Θ(m⁻²)` to
`Θ(m⁻⁴)`, and `accelerated2` overshoots (`γ < accelerated2 n`). The empirical constant is
`1/120`. Both facts are proved.

## 4. Third order

| n | γ − accelerated3 n | 1/(252 m⁶) | ratio |
|---|---|---|---|
| 0 | 2.2157e-03 | 3.9683e-03 | 0.55835 |
| 1 | 5.0345e-05 | 6.2004e-05 | 0.81197 |
| 2 | 4.9083e-06 | 5.4434e-06 | 0.90169 |
| 5 | 8.2689e-08 | 8.5053e-08 | 0.97220 |
| 10 | 2.2208e-09 | 2.2400e-09 | 0.99145 |
| 100 | 3.7379e-15 | 3.7383e-15 | 0.99990 |

**Finding.** Again one full pair of powers is gained and the constant is `1/252`.

## 5. The pattern (OEIS)

The observed constants `1/2, 1/12, 0, −1/120, 0, 1/252, …` are the coefficients
`B_{2k}/(2k)` of the Bernoulli numbers `B₂ = 1/6`, `B₄ = −1/30`, `B₆ = 1/42`; the
denominators `2, 12, 120, 252, 240, 132, …` are OEIS **A006953** (denominators of
`B_{2n}/(2n)`); the Bernoulli numerators/denominators themselves are **A000367** /
**A002445**. The odd-index terms vanish, which is what makes each correction gain *two*
powers of `m` rather than one.

## 6. What the numerics did **not** settle

The sharpness of the sixth-order constant (`252 m⁶ (γ − accelerated3 n) → 1`) is strongly
suggested by the table in §4 but is *not* proved in the Lean development; only the upper
bound `≤ 1/(252 m⁶)` and positivity are. It appears as a conjecture in
`FUTURE_DIRECTIONS.md`.
