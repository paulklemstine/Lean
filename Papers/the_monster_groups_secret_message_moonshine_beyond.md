# Computational Evidence — Monstrous Moonshine arithmetic

All computations below were performed in Lean (`#eval` on `ℕ`) and are the exact
values later proved in `MonsterMoonshine.lean`.

## 1. Order of the Monster

Factored form:

```
|M| = 2^46 · 3^20 · 5^9 · 7^6 · 11^2 · 13^3 · 17 · 19 · 23 · 29 · 31 · 41 · 47 · 59 · 71
```

`#eval` gives

```
|M| = 808017424794512875886459904961710757005754368000000000   (≈ 8.08 × 10^53)
|M| mod 24 = 0
|M| / 24   = 33667392699771369828602496040071281541906432000000000
```

So `24 ∣ |M|` and the "moonshine weight" `|M|/24` is the integer above.
(Proved: `monsterOrder_value`, `twentyfour_dvd_monsterOrder`, `monsterOrder_eq_24_mul`.)

## 2. Ogg's observation (prime divisors = supersingular primes)

The primes appearing in the factorization are exactly

```
2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71     (15 primes).
```

Counterexample hunt for the *forward* claim "every prime factor is in this list":
none exists — a prime dividing a product of prime powers must equal one of the
bases. Spot checks that primes *not* in the list fail to divide `|M|`:

```
|M| mod 37 = 21     |M| mod 43 = 13     |M| mod 67 = 14   (all ≠ 0)
```

These 15 primes are precisely the supersingular primes (primes `p` for which
`X₀(p)⁺` has genus 0), which is Ogg's original moonshine observation.
(Proved: `prime_dvd_monsterOrder_iff`, `primeFactors_monsterOrder`,
`card_primeFactors_monsterOrder`, `thirtyseven_not_dvd_monsterOrder`,
`no_large_prime_dvd`.)

## 3. McKay head decompositions (the `j`-function coefficients)

`j(q) = q^{-1} + 744 + Σ c(n) qⁿ`. First coefficients `c(n)` and the first
Monster irreducible degrees `dᵢ`:

```
c(1) = 196884           d₁ = 1
c(2) = 21493760         d₂ = 196883
c(3) = 864299970        d₃ = 21296876
c(4) = 20245856256      d₄ = 842609326
c(5) = 333202640600     d₅ = 18538750076
                        d₆ = 19360062527
                        d₇ = 293553734298
```

Verified decompositions (each `#eval ... == ...` returned `true`):

```
c(1) = d₁ + d₂                                            = 1 + 196883
c(2) = d₁ + d₂ + d₃
c(3) = 2 d₁ + 2 d₂ + d₃ + d₄
c(4) = 3 d₁ + 3 d₂ + d₃ + 2 d₄ + d₅
c(5) = 4 d₁ + 5 d₂ + 3 d₃ + 2 d₄ + d₅ + d₆ + d₇
```

The famous first coincidence `196884 = 196883 + 1` is the tip of the iceberg.
(Proved: `moonshine_head_decomposition`, `mckay_first`.)

## 4. OEIS references

* `c(n)` (coefficients of `j`): OEIS **A000521** — `1, 744, 196884, 21493760,
  864299970, 20245856256, 333202640600, …`
* Degrees of Monster irreducibles: OEIS **A001379** — `1, 196883, 21296876,
  842609326, 18538750076, 19360062527, 293553734298, …`
* Supersingular primes: OEIS **A002267** — `2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
  31, 41, 47, 59, 71`.

All three sequences match the values used above.
