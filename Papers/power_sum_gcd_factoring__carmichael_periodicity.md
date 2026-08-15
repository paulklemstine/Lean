# Computational Evidence — Power-Sum GCD Factoring and Carmichael Periodicity

All numbers below were produced by `#eval` inside Lean 4 (kernel evaluation, not an
external script), with

```lean
def F (N k : ℕ) : ℕ := ∑ a ∈ Finset.Icc 1 N, a ^ k
```

## 1. Factor reveal at `k = p - 1`

For each test semiprime `N = p·q` (with `p < q`, so `(q-1) ∤ (p-1)` automatically):

```lean
#eval [(3,5),(3,7),(5,7),(5,11),(7,13),(11,13),(13,17),(97,101)].map (fun (p,q) =>
  (p*q, Nat.gcd (F (p*q) (p-1)) (p*q), q, Nat.lcm (p-1) (q-1)))
```

| N | p | q | `gcd(F(N,p-1), N)` | predicted | λ(N)=lcm(p-1,q-1) |
|---|---|---|---|---|---|
| 15 | 3 | 5 | 5 | 5 | 4 |
| 21 | 3 | 7 | 7 | 7 | 6 |
| 35 | 5 | 7 | 7 | 7 | 12 |
| 55 | 5 | 11 | 11 | 11 | 20 |
| 91 | 7 | 13 | 13 | 13 | 12 |
| 143 | 11 | 13 | 13 | 13 | 60 |
| 221 | 13 | 17 | 17 | 17 | 48 |
| 9797 | 97 | 101 | 101 | 101 | 2400 |

8/8 agree with Theorem 1 (`gcd_powerSum_eq_factor`).

## 2. Periodicity and the exact period

`g(k) = gcd(F(N,k), N)` for `k = 1 … 13`:

* `N = 15 = 3·5`, λ = lcm(2,4) = 4:
  `[15, 5, 15, 1, 15, 5, 15, 1, 15, 5, 15, 1, 15]`
  — period exactly 4, and `g(k) = 1` exactly at `k ∈ {4, 8, 12}`, i.e. `λ ∣ k`.
* `N = 35 = 5·7`, λ = lcm(4,6) = 12:
  `[35, 35, 35, 7, 35, 5, 35, 7, 35, 35, 35, 1, 35]`
  — `g(k)=7` at `k ≡ 0 mod 4` but `k ≢ 0 mod 6`; `g(k)=5` at `k ≡ 0 mod 6`,
  `k ≢ 0 mod 4`; `g(k)=1` first at `k = 12 = λ`.

Both tables match the closed formula
`g(k) = (if (p-1) ∣ k then 1 else p) · (if (q-1) ∣ k then 1 else q)`
proved as `gcd_powerSum_semiprime`.

## 3. Counterexample hunt: the claimed recovery `p + q = N − λ(N) + 1`

For `N = 15`: `N − λ + 1 = 15 − 4 + 1 = 12`, whereas `p + q = 8`. **False.**
For `N = 35`: `35 − 12 + 1 = 24`, whereas `p + q = 12`. **False.**

The correct identity is `p + q = N + 1 − (p−1)(q−1) = N + 1 − λ(N)·gcd(p−1,q−1)`.
Since `p, q` are odd, `gcd(p−1,q−1) ≥ 2`, so the naive formula *always* overshoots
for odd semiprimes. This is formalised (both the corrected identity and the strict
inequality refuting the naive one) in `Catalog/Novelty/PowerSumGCDCarmichael.lean`.

## 4. Pollard `p−1` bad bases vs. the power sum

`N = 15`, `p = 3`, exponent `p − 1 = 2`, base `a = 4`:
`gcd(4² − 1, 15) = gcd(15,15) = 15` — Pollard's step returns `N`, i.e. **failure**,
while `gcd(F(15,2), 15) = 5` succeeds. `a = 4 ≡ 1 (mod 3)`, `a ≡ −1 (mod 5)` is exactly
the CRT-constructed bad base of `exists_pollard_bad_base`.

## 5. OEIS

`F(N,1) = N(N+1)/2` are the triangular numbers (A000217); the two-parameter family
`F(N,k)` is Faulhaber's power sum and has no single OEIS entry. No new sequence is
claimed here.
