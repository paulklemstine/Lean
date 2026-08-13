# Computational Evidence — Round-3 Factoring Closures

All numbers below were produced by `#eval` inside Lean 4 (kernel-level
evaluation of the definitions shown), before the corresponding theorems in
`Catalog/Computation/Factoring/` were formalized.  They are exploratory data,
not proofs; the proofs are the Lean files themselves.

---

## 1. RS-MIND — minimum distance of the evaluation code over `ℤ/N`

Brute-force minimum Hamming weight over all nonzero codewords
`(f(0),…,f(N-1))`, `deg f < k`:

| `N = p·q` | `k` | measured `d(C_k)` | `N − (k−1)·max(p,q)` |
|---|---|---|---|
| 15 = 3·5 | 2 | **10** | 15 − 5 = 10 ✓ |
| 15 = 3·5 | 3 | **5**  | 15 − 2·5 = 5 ✓ |
| 21 = 3·7 | 2 | **14** | 21 − 7 = 14 ✓ |
| 21 = 3·7 | 3 | **7**  | 21 − 2·7 = 7 ✓ |
| 33 = 3·11 | 2 | **22** | 33 − 11 = 22 ✓ |

The formula `d(C_k) = N − (k−1)·max(p,q)` is confirmed exactly in every case
tested.  Formalized as `RSMind.card_zeroSet_le` (the `≥` half, for all `k`) and
`RSMind.min_distance_two` / `RSMind.exists_zeroSet_card_eq_max` (exactness at
`k = 2`).

## 2. MODPAR-CERT — the divisor-parity pattern

`P(N,m,a) = #{d proper divisor of N : d ≡ a (mod m)} mod 2`, tabulated over
`a = 0,…,m−1`:

| `N` | `m` | pattern `P(N,m,·)` | support | interpretation |
|---|---|---|---|---|
| 15 = 3·5 | 7 | `[0,1,0,1,0,1,0]` | `{1,3,5}` | `{1, p, q}` — factor residues recovered |
| 91 = 7·13 | 5 | `[0,1,1,1,0]` | `{1,2,3}` | `7≡2`, `13≡3` recovered |
| 91 = 7·13 | 4 | `[0,0,0,1]` | `{3}` | collision `13 ≡ 1 (mod 4)`: the two merged classes cancel |
| 35 = 5·7 | 6 | `[0,0,0,0,0,1]` | `{5}` | collision `7 ≡ 1 (mod 6)`: only `5` survives |

Exactly the behaviour proved in `ModPar.support_eq` (non-collision) and
`ModPar.collision_support` (merged classes).  Note the support has 3 elements
out of `m` — the `3/m` density behind the adversary bound.

## 3. BURAU-ORD — order of the braid element in the reduced Burau image

`M(a) = r(σ₁)r(σ₂) = [[0,−a],[a,−a]] (mod N)`, measured multiplicative order
`ord_N(a)` and matrix order `ord(M(a))`:

| `N` | `a` | `ord_N(a)` | measured `ord(M(a))` | `lcm(3, ord_N(a))` |
|---|---|---|---|---|
| 21 | 2 | 6 | **6** | 6 ✓ |
| 21 | 5 | 6 | **6** | 6 ✓ |
| 21 | 4 | 3 | **3** | 3 ✓ |
| 35 | 2 | 12 | **12** | 12 ✓ |
| 35 | 3 | 12 | **12** | 12 ✓ |
| 143 | 2 | 60 | **60** | 60 ✓ |
| 15 | 4 | 2 | **6** | 6 ✓ |
| 15 | 11 | 2 | **6** | 6 ✓ |
| 35 | 6 | 2 | **6** | 6 ✓ |
| 35 | 34 | 2 | **6** | 6 ✓ |

The last four rows are the informative ones: when `3 ∤ ord(a)` the braid order
is `3·ord(a)`, exactly `lcm(3, ord(a))`.  Formalized as `Burau.orderOf_bm`.
CRT check: `ord₃(5) = 2`, `ord₇(5) = 6`, `lcm = 6 = ord₂₁(5)`
(`Burau.orderOf_crt`).

## 4. CONG-DIV — payoff landscape of the divisor congestion game

`N = 91`, `w(d) = 91/d` if `d ∣ 91`, else `−91`, for `d = 2..21`:

```
(2,-91) (3,-91) (4,-91) (5,-91) (6,-91) (7, 13) (8,-91) (9,-91) (10,-91)
(11,-91) (12,-91) (13, 7) (14,-91) ... (21,-91)
```

The landscape is flat (`−91`) except at the two divisors; the maximum is at
`d = 7 = minFac(91)` with payoff `13 = 91/7`.  Formalized as
`CongDiv.payoff_constant_off_divisors`, `CongDiv.best_response_unique` and
`CongDiv.equilibrium_factors`.

## 5. DENS-SUB — residue classes do not discriminate

Semiprimes `N ∈ [100,400]` with their least prime factor, split by `N mod 8`:

* `N ≡ 1 (mod 8)`: (129,3) (145,5) (161,7) (177,3) (185,5) (201,3) (209,11)
  (217,7) (249,3) (265,5) (305,5) (321,3) (329,7) (377,13)
* `N ≡ 3 (mod 8)`: (115,5) (123,3) (155,5) (187,11) (203,7) (219,3) (235,5)
  (259,7) (267,3) (291,3) (299,13) (323,17) (339,3) (355,5)

Both classes carry the same spread of least prime factors `{3,5,7,11,13,17}`;
neither class is "easier".  The theorem `DensSub.no_residue_detector` proves the
corresponding impossibility for *every* modulus `m > 1` and *every* purported
detector, using Dirichlet's theorem on primes in arithmetic progressions.

## 6. No OEIS hit is claimed

The quantities involved (`N − (k−1)max(p,q)`, `lcm(3, ord_N(a))`) depend on the
factorization of `N`, not on `N` alone, so they are not sequences in `N`; no
OEIS identification was attempted.
