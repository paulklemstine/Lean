# Computational Evidence — 2-adic valuation of coefficients of `f(x)^m`

Let `f(x) = ∏_{n≥0} (1 - x^{2^n}) = ∑_n (-1)^{s₂(n)} x^n` (signed Prouhet–Thue–Morse
sequence; `s₂` = binary digit sum). Write `f(x)^m = ∑_n t_m(n) x^n`. Equivalently
`t_m` is the `m`-fold additive convolution of the sign sequence `τ(n) = (-1)^{s₂(n)}`.

All numbers below were produced by a short reference enumeration (m-fold
convolution over ℤ) and then re-derived/locked down in Lean.

## 1. Small cases

`τ(n)` for `n = 0..7`:  `1, -1, -1, 1, -1, 1, 1, -1`  (this is OEIS A106400, the
`±1` Thue–Morse sequence; the bit `s₂(n) mod 2` is A010060).

`t₂(n)` for `n = 0..9`:  `1, -2, -1, 4, -3, 2, 3, -8, 5, -6`.
2-adic valuations `ν₂(t₂(n))`:  `0, 1, 0, 2, 0, 1, 0, 3, 0, 1`.

Observe `t₂(2N+1) = -2·t₂(N)` (e.g. `t₂(7) = -8 = -2·t₂(3) = -2·4`) and
`t₂(2N+2) = t₂(N+1)+t₂(N)` (e.g. `t₂(4) = -3 = t₂(2)+t₂(1) = -1 + (-2)`).
Both are proved in `ThueMorsePowerValuation.lean`.

## 2. The Mersenne witnesses `n = 2^k - 1`

`ν₂(t_m(2^k - 1))` for `k = 1..9`:

| m \ k | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|------:|---|---|---|---|---|---|---|---|---|
| 2     | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| 3     | 0 | 3 | 3 | 6 | 6 | 9 | 9 |12 |12 |
| 4     | 2 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| 5     | 0 | 0 | 3 | 4 | 7 | 8 |11 |12 |15 |
| 6     | 1 | 4 | 4 | 5 | 6 | 7 | 8 | 9 |10 |
| 7     | 0 | 1 | 1 | 4 | 4 | 7 | 7 |10 |10 |
| 8     | 3 | 3 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |

For `m = 2` we have *exactly* `t₂(2^k-1) = (-2)^k`, so `ν₂ = k` (proved:
`t2_mersenne`, `main_unbounded_sharp`).

For every tested `m` (2..8), `ν₂(t_m(2^k-1)) → ∞` as `k → ∞`, supporting the
Gawron–Miska–Ulas conjecture: the Mersenne indices already witness unboundedness.

## 3. Maximum finite valuation observed (n ≤ 600)

`max_{n≤600, t_m(n)≠0} ν₂(t_m(n))`:
`m=2: 9`, `m=3: 12`, `m=4: 9`, `m=5: 15`, `m=6: 10`, `m=7: 12`, `m=8: 9`.
These grow with the search range, consistent with unboundedness (no finite ceiling).

## 4. Counterexample hunt

The claim under test is universal: "for all `m ≥ 2`, `k ≥ 0`, `∃ n` with
`ν₂(t_m(n)) ≥ k`." Over all `m ∈ {2,…,8}` and `n ≤ 600`, no `m` showed a 2-adic
ceiling; for each `m` the Mersenne subsequence already realises arbitrarily large
`ν₂` within range. No counterexample found.

A genuine subtlety: with the Lean/`padicValInt` convention `ν₂(0) = 0`, zero
coefficients do NOT count as "large valuation". The `m = 2` theorem sidesteps this
entirely because `t₂(2^k-1) = (-2)^k ≠ 0`. (Zeros do occur for some odd `m`,
e.g. `m = 3` has 15 zeros for `n ≤ 600`, which is why the convention matters.)

## 5. The mod-2 shadow (all m)

Modulo 2, `τ ≡ 1`, hence `f ≡ 1/(1-x)` and `f^{m+1} ≡ 1/(1-x)^{m+1}`, giving the
closed form `t_{m+1}(n) ≡ C(n+m, m) (mod 2)` (proved: `tconv_succ_zmod2`). Spot
checks: `t₂(n) ≡ n+1`, `t₃(n) ≡ C(n+2,2)`, all confirmed against the enumeration.
This explains why `m = 1` is all-odd (`ν₂ ≡ 0`) and why `m ≥ 2` is required.
