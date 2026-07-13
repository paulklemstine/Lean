# Computational Evidence — Sharp dichotomy for the total d-Hoggatt numbers

All computations below were run in Lean 4 / Mathlib (`catalan`, `Nat.centralBinom`,
`Nat.choose`) so the numbers are exact, not floating point.

## 1. The three total sequences

| d | `H_d(n)` name | first terms (n = 0,1,2,…) | OEIS |
|---|---------------|---------------------------|------|
| 1 | powers of two | 1, 2, 4, 8, 16, 32, 64, … | A000079 |
| 2 | Catalan       | 1, 1, 2, 5, 14, 42, 132, 429, … | A000108 |
| 3 | Baxter        | 1, 1, 2, 6, 22, 92, 422, 2074, 10754, … | A001181 |

## 2. Log-behaviour of the discriminant `Δ_n = H(n+1)² − H(n)·H(n+2)`

* **d = 1 (`2^n`).** `Δ_n = (2^{n+1})² − 2^n·2^{n+2} = 2^{2n+2} − 2^{2n+2} = 0` for
  every `n`. The sequence is **log-linear** (equality), hence log-concave and
  log-convex simultaneously, and *not* strictly log-convex.

* **d = 2 (Catalan).** Computed `(C(n+1)², C(n)·C(n+2))` for `n = 0..6`:

  ```
  (1,2) (4,5) (25,28) (196,210) (1764,1848) (17424,18018) (184041,188760)
  ```

  In every case `C(n+1)² < C(n)·C(n+2)`, so `Δ_n < 0`: **strictly log-convex**.
  The exact gap is governed by the discriminant identity
  `(2n+1)(n+3)·C(n)·C(n+2) = (n+2)(2n+3)·C(n+1)²`, and since
  `(n+2)(2n+3) − (2n+1)(n+3) = 3 > 0`, strictness holds for all `n`.

* **d = 3 (Baxter).** Checking `B(n+1)² < B(n)·B(n+2)` on the exact Baxter
  numbers `1,1,2,6,22,92,422,2074,10754`:

  ```
  1<2, 4<6, 36<44, 484<552, 8464<9724, ...   all true
  ```

  Empirically strictly log-convex, matching Conjecture 1 for `d = 3`.

## 3. Ratio monotonicity (the mechanism, Conjecture 2)

For Catalan, `r(n) = C(n+1)/C(n) = 2(2n+1)/(n+2) = 4 − 6/(n+2)` is strictly
increasing in `n`; strictly increasing consecutive ratios force strict
log-convexity. This is exactly the general criterion
`strictLogConvex_real_of_ratio_strictMono` proved in the Lean file.

## 4. Tropical dequantization (Conjecture 5)

With `v_n = −log H(n)`: for `d = 1`, `v_n = −n·log 2` is affine; for `d = 2`,
strict log-convexity of `H` is strict concavity of `v` (equivalently strict
convexity of `log H`). This equivalence is formalized as
`strictLogConvex_iff_log`.

## What is proved formally (in `HoggattTotals.lean`)

* `pow_two_logLinear`, `pow_two_not_strictLogConvex` — the `d = 1` side.
* `catalan_rec`, `catalan_discriminant`, `catalan_strictLogConvex`,
  `catalan_not_logConcave` — the `d = 2` side.
* `sharp_dichotomy` — the combined dichotomy.
* `strictLogConvex_real_of_ratio_strictMono` — the general mechanism.
* `catalan_ratio_strictMono` — the Catalan ratios `Cₙ₊₁/Cₙ` are strictly
  increasing over `ℝ`, the concrete instance of that mechanism.
* `strictLogConvex_iff_log` — the tropical/logarithmic reformulation.

The `d ≥ 3` universal claim (Conjecture 1) is left as computational evidence
only; the Baxter data is consistent with it but no general proof is given here.
