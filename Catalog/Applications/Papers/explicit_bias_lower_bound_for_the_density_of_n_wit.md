# Computational Evidence — Cusick density bias for `s₂(n+t) ≥ s₂(n)`

All computations use the binary sum-of-digits function `s₂(n) = (Nat.digits 2 n).sum`
and the finite count `cc t N = #{ n < N : s₂(n) ≤ s₂(n+t) }`. They were run inside
Lean via `#eval` (so the numbers below are reproducible with the project toolchain),
and each conclusion that we formalize is independently kernel-checked in
`CusickDoublingInvariance.lean`.

## 1. Doubling invariance (the formalized mechanism)

For all sampled `n < 768`, `t < 30`:

* `s₂(n) ≤ s₂(n+t)  ↔  s₂(2n)   ≤ s₂(2n   + 2t)`  — holds with no exception.
* `s₂(n) ≤ s₂(n+t)  ↔  s₂(2n+1) ≤ s₂(2n+1 + 2t)`  — holds with no exception.

Consequently `cc (2t) (2N) = 2 · cc t N`, checked numerically:
`cc 4 (4·N) = 4 · cc 1 N` gave `(120,120), (112,112), (104,104)` for `N=40,40,40`
across `t∈{1,3,5}`. Formalized as `cusickCount_two_mul` / `cusickCount_two_pow_mul`.

## 2. Exact density `3/4` for every power of two `t = 2^k`

`cc (2^k) (2^{k+2}·3)` for `k = 0,1,2,3` returned `9, 18, 36, 72`, i.e. exactly
`3·2^k·3`. Pointwise rule `s₂(n) ≤ s₂(n+2^k) ↔ (n / 2^k) % 4 ≠ 3` verified on
`n < 200`, `k < 4`. Formalized exactly as `cusick_pow2_iff` and
`cusick_pow2_density` (density `3/4`, bias `1/4`).

## 3. Densities for small odd shifts (NOT yet formalized — see FUTURE_DIRECTIONS)

`cc t (2^N)` stabilizes to an exact dyadic rational already at finite `N`:

| t | `cc t (2^N)` for N=6,8,10,12,14 | stable density `c_t` |
|---|----------------------------------|----------------------|
| 1 | 48,192,768,3072,12288            | 3/4   = 0.7500       |
| 3 | 44,176,704,2816,11264            | 11/16 = 0.6875       |
| 5 | 40,160,640,2560,10240            | 5/8   = 0.6250       |
| 7 | 43,172,688,2752,11008            | 43/64 = 0.671875     |

Observations:
* Each density is `> 1/2` (consistent with Cusick), with explicit bias
  `1/4, 3/16, 1/8, 11/64` for `t = 1,3,5,7`.
* The ratio is *exactly* constant from a finite level onward
  (`cc t (2^{N+2}) = 4 · cc t (2^N)` for the sampled range), and the denominator
  is a power of two `2^{2 s₂(t)}` for these `t` (`16, 16, 64` for `t=3,5,7`).
* Unlike `t = 2^k`, the predicate for `t` with `s₂(t) ≥ 2` is **not** a function of
  finitely many low bits (carry chains propagate arbitrarily far, e.g. `n=13, t=3`
  yields 4 carries), so these exact values require a recursion/transfer-operator
  argument rather than a residue count. They are recorded as conjectures.

## OEIS

The good-set counts `cc 1 (2^N) = 3·2^{N-2}` are the trivial `3·2^{N-2}` sequence.
The mixed values `c_t · 2^{2 s₂(t)}` (numerators `3, 11, 43` for `t=1,3,7` at
denominator scale) were not matched to a single catalog entry; recording the
`(t, numerator, 2-power denominator)` table here for future cross-referencing.
