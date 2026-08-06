# Computational evidence

Numerical checks performed before formalising the theorems in
`Catalog/Probability/NeuralCoding/`.  Enumerative checks marked *(Lean)* were run
inside Lean with `#eval` on the actual definitions used in the proofs; the
floating-point checks were exploratory and are *not* part of the verified
artifact (the corresponding statements are all proved symbolically in Lean).

## 1. Refractory spike trains (`RefractorySpikeTrains.lean`) *(Lean)*

`#eval` of `(Temporal.trains n).card` against `Nat.fib (n+2)`:

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|---|----|----|
| `card (trains n)` | 1 | 2 | 3 | 5 | 8 | 13 | 21 | 34 | 55 | 89 | 144 | 233 |
| `fib (n+2)`       | 1 | 2 | 3 | 5 | 8 | 13 | 21 | 34 | 55 | 89 | 144 | 233 |

The counting sequence 1, 2, 3, 5, 8, 13, … is the Fibonacci sequence
(OEIS A000045, shifted).  Rate check `fib (5m+2) ≤ 16^m`:

| m | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| `fib (5m+2)` | 1 | 13 | 144 | 1597 | 17711 | 196418 |
| `16^m` | 1 | 16 | 256 | 4096 | 65536 | 1048576 |

so the `4/5`-bit-per-bin bound holds with room to spare (true rate
`log₂ φ ≈ 0.694`).

## 2. `q`-ary energy type classes (`QaryNeuralCode.lean`) *(Lean)*

`#eval` of `card {c : Fin 4 → ZMod 3 | weight c = k}` against
`C(4,k)·2^k`:

| k | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| enumerated | 1 | 8 | 24 | 32 | 16 |
| `C(4,k)·(q-1)^k` | 1 | 8 | 24 | 32 | 16 |

## 3. Entropy bound for sparse codes (`SparseEntropyBound.lean`)

Ratio `S / exp(N·H(k/N))` with `S = ∑_{j ≤ k} C(N,j)` (exploratory, floating point):

| N | k | S | `exp(N H(k/N))` | ratio |
|---|---|---|---|---|
| 20 | 3 | 1351 | 4.70e3 | 0.288 |
| 100 | 1 | 101 | 2.71e2 | 0.373 |
| 100 | 10 | 1.94e13 | 1.31e14 | 0.148 |
| 200 | 2 | 20101 | 7.32e4 | 0.275 |
| 1000 | 10 | 2.66e23 | 2.10e24 | 0.127 |
| 50 | 25 | 6.26e14 | 1.13e15 | 0.556 |

The bound holds in all sampled cases (no counterexample found), is never off by
more than a polynomial factor, and is tightest at `k/N = 1/2`, as the
Chernoff-style proof predicts.

One-percent sparsity (`k = N/100`), checking `log₂ S ≤ 0.09 N`:

| N | `log₂ S` | `0.09 N` |
|---|---|---|
| 200 | 14.3 | 18 |
| 500 | 37.9 | 45 |
| 1000 | 77.8 | 90 |
| 2000 | 158.1 | 180 |

`binEntropy(1/100) ≈ 0.0560 < 0.06`, which is the constant proved in
`binEntropy_one_percent_lt`.

## 4. Cramér–Rao sharpness (`FisherCramerRao.lean`)

For the two-response family `p(θ)(true) = 1/2 + θ` with decoder `T = ±1/2`:
`I(0) = 4`, `Var(T) = 1/4`, product `= 1`.  Equality, so the bound proved is
sharp.  (This is proved symbolically in Lean, not only computed.)

## 5. Counterexample hunt for the smooth manifold statement

Sampling smooth curves `t ↦ (t, t²)`, `t ↦ (t, t², t³)` shows the linear span of
the image of a `1`-parameter smooth family can have dimension `2`, `3`, …, so
the linear neural-manifold theorem (`span dimension ≤ d`) *fails* for smooth
parametrisations.  The `d = 1`, span `= 2` instance is formalised as
`exists_smooth_span_gt_dof`; only the tangent-rank bound survives.

## 6. Generalised refractory period (`RefractoryGeneralized.lean`) *(Lean)*

`#eval` of `(trainsR r n).card` for `n = 0, …, 10`:

| r | counts |
|---|---|
| 1 | 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144 (Fibonacci, A000045 shifted) |
| 2 | 1, 2, 3, 4, 6, 9, 13, 19, 28, 41, 60 (Narayana's cows, OEIS A000930) |
| 3 | 1, 2, 3, 4, 5, 7, 10, 14, 19, 26, 36 (OEIS A003269, `a(n)=a(n-1)+a(n-4)`) |

Each row satisfies the proved recursion `c_r(n+r+1) = c_r(n+r) + c_r(n)`, and the
`r = 2` window of length `4` enumerates to exactly the six admissible words
`0000, 0001, 0010, 0100, 1000, 1001`, matching `mem_trainsR_iff`.  Growth rates:
`60^{1/10} = 1.466` (r = 2) versus the root `λ_2 = 1.4656…` of `x³ = x² + 1`, and
`36^{1/10} = 1.435` (r = 3) versus `λ_3 = 1.3803…` (slow convergence from above,
as expected for a linear recursion with a positive leading coefficient).

## 7. Isolated-vertex first moment (`ErdosRenyiThreshold.lean`)

`n (1 - p_n)^{n-1}` with `p_n = (log n + c)/n` (floating point, exploratory):

| c \ n | 10 | 100 | 1000 | 10⁴ | 10⁵ | limit `e^{-c}` |
|---|---|---|---|---|---|---|
| 0 | 0.949 | 0.940 | 0.983 | 0.997 | 0.9995 | 1 |
| 1 | 0.271 | 0.331 | 0.359 | 0.366 | 0.3676 | 0.3679 |
| −1 | 2.848 | 2.638 | 2.687 | 2.711 | 2.717 | 2.7183 |

The convergence to `e^{-c}` is clearly visible and is proved symbolically in
`tendsto_expected_isolated`; the exact identity
`E[#isolated] = n (1-p)^{n-1}` is proved in `expected_isolated_count`.

## 8. Growth rate of refractory codes (`RefractoryGrowthRate.lean`)

Root `λ_r` of `x^{r+1} = x^r + 1` (bisection, exploratory) and the corresponding
bit rate `log₂ λ_r`:

| r | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| `λ_r` | 2.000000 | 1.618034 | 1.465571 | 1.380278 | 1.324718 | 1.285199 | 1.255423 | 1.232055 |
| `log₂ λ_r` | 1.000 | 0.694 | 0.551 | 0.465 | 0.406 | 0.362 | 0.328 | 0.301 |

The sequence is strictly decreasing (proved: `lamR_strictAnti`) and tends to `1`
(proved: `tendsto_lamR_one`), so the rate decreases to `0`.  The `r = 2` entry
confirms `1.46 < λ_2 < 1.47` (proved: `lamR_two_bounds`) and
`log₂ λ_2 = 0.551 < 2/3` (proved: `logb_lamR_two_lt`), i.e. the earlier
`temporal_rate_two_le` bound is not tight.

Ratio `c_r(n) / λ_r^n`, which the proved two-sided bound
`λ_r^{-r} ≤ c_r(n)/λ_r^n ≤ r + 1` forces into a bounded window:

| r | n = 10 | n = 20 | n = 40 | n = 80 | proved window |
|---|---|---|---|---|---|
| 1 | 1.171 | 1.171 | 1.171 | 1.171 | [0.618, 2] |
| 2 | 1.312 | 1.313 | 1.313 | 1.313 | [0.466, 3] |
| 3 | 1.434 | 1.440 | 1.440 | 1.440 | [0.380, 4] |

and the `n`-th roots `c_r(n)^{1/n}` (1.6437, 1.6308, 1.6244, 1.6212 for `r = 1`)
descend towards `λ_1 = 1.61803`, as proved in `tendsto_card_trainsR_rpow`.

## 9. Sharpness of the sparse entropy estimate (`SparseEntropyLowerBound.lean`)

`log S - N·binEntropy(k/N)` with `S = ∑_{j ≤ k} C(N,j)`, compared with the proved
window `[-log (N+1), 0]`:

| N | k | `log S - N H` | `-log (N+1)` |
|---|---|---|---|
| 20 | 5 | −1.262 | −3.045 |
| 50 | 25 | −0.587 | −3.932 |
| 100 | 10 | −1.911 | −4.615 |
| 200 | 2 | −1.292 | −5.303 |
| 1000 | 10 | −2.063 | −6.909 |

No sampled case leaves the window (no counterexample found), and the observed
gap grows like `½ log N`, consistent with conjecture D1 below.
