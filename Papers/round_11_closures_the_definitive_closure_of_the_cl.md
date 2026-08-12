# Computational Evidence — Round-11 Closures (Combinatorics)

All computations below were run inside Lean 4 / Mathlib with `#eval` on the
definitions that the formal theorems use (`Round11.fpr`, `Round11.mobRaw`), plus
brute-force reference implementations of the multiplicative order and of the
orbit count.  They preceded (and guided) the formal proofs; every claim that they
support is now a `sorry`-free theorem in `Catalog/Combinatorics/Round11*.lean`.

## 1. The cycle-index fingerprint `F(c) = gcd(b^c − 1, N)`

`N = 143 = 11·13`, `b = 2` (`ord_11 2 = 10`, `ord_13 2 = 12`, `d* = 10`):

| c | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|---|
| F(c) | 143 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |

`F ≡ 1` on `1 ≤ c < d*`, exactly as `Round11.fpr_eq_one_of_lt_dstar` asserts.

`N = 15 = 3·5`, `b = 2` versus `N = 21 = 3·7`, `b = 2`:

| c | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| F(c) mod 15 | 1 | 3 | 1 | 15 | 1 |
| F(c) mod 21 | 1 | 3 | 7 | 3 | 1 |

The first divergence is at `c = 3 = ord_7 2`; this is the instance pair used in
the sharpness theorem `Round11.cifinger_informative_at_order_scale`.

## 2. The raw Möbius spectrum `M_d = Σ_{c ∣ d} μ(d/c) F(c)`

`N = 143`, `b = 2`, `d = 1 … 13`:

```
[1, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 12, 0]
```

Nonzero exactly at `d = 1` (mass 1), `d = 10 = ord_11 2` (mass `11 − 1`) and
`d = 12 = ord_13 2` (mass `13 − 1`) — the pattern proved in full generality by
`Round11.mobRaw_eq` (the fourth atom, mass `φ(N)`, sits at `d = ord_N b = 60`).

## 3. Counterexample hunt (140 instances)

Instance set: all `(p, q, b)` with `p < q` in `{3,5,7,11,13,17,19,23}` and
`2 ≤ b ≤ 7` coprime to `N = pq` — **140 instances**.  For each we tested

1. the Burnside/GROUPOID identity
   `C(b)·n = n + (p−1)(n/ord_p b) + (q−1)(n/ord_q b) + (p−1)(q−1)`,
   with `C(b)` computed by brute-force orbit enumeration on `ℤ/N`;
2. the raw Möbius spectrum formula of `Round11.mobRaw_eq` for `1 ≤ d ≤ 30`;
3. triviality of the fingerprint below the order scale, `F(c) = 1` for
   `1 ≤ c < d*`.

**Counterexamples found: 0 / 140 in each of the three tests.**

Sample of the orbit-count data (`d_p = ord_p b`, `d_q = ord_q b`, `n = ord_N b`):

| p | q | b | d_p | d_q | n | C(b) |
|---|---|---|-----|-----|---|------|
| 3 | 5 | 2 | 2 | 4 | 4 | 5 |
| 3 | 7 | 2 | 2 | 3 | 6 | 6 |
| 5 | 11 | 3 | 4 | 5 | 20 | 6 |
| 7 | 13 | 16 | 3 | 3 | 3 | 31 |
| 11 | 13 | 2 | 10 | 12 | 60 | 5 |

The row `(7, 13, 16)` is a *balanced* instance (`d_p = d_q = 3`): there
`C·d = 3 + 90 = 93 = d + N − 1`, the collapse proved in
`Round11.groupoid_balanced_no_leak` — the orbit count depends on `N` and `ord_N b`
only, and so reveals nothing about the factorization.

## 4. Where the order scale sits (`b = 2`)

| N | d* = min(ord_p 2, ord_q 2) | ⌊√N⌋ |
|---|---------------------------|------|
| 10403 = 101·103 | 51 | 101 |
| 47053 = 211·223 | 37 | 216 |
| 95477 = 307·311 | 102 | 308 |
| 164009 = 401·409 | 200 | 404 |
| 256027 = 503·509 | 251 | 505 |

`d*` always divides `p − 1` or `q − 1`, so it is `Θ(√N)` up to the divisor
structure of `p−1`, `q−1` (the `47053` row shows the smooth-order exception the
paper flags).  This is the empirical content of "the informative coefficient sits
at the order scale"; the formal statements avoid any unproved size claim and
instead prove the exact dichotomy (`fpr_eq_one_of_lt_dstar` /
`isLeast_informative_index` / `fpr_dstar_splits`).

## 5. OEIS

No OEIS lookup was performed (no network access in this environment); no sequence
claim is made anywhere in the formal development.
