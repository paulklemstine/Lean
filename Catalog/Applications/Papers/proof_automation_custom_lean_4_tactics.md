# Computational Evidence — Strong Divisibility Sequence Bridges

All claims below were checked numerically (by hand / `#eval`) before being formalized
in `Catalog/Bridges/StrongDivSeq*.lean`. Every formalized theorem is now machine-verified
with 0 sorries and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## 1. Coprime propagation (`coprime_of_coprime`, `fib_coprime_of_coprime`)

Claim: `Coprime m n ⇒ Coprime (fib m) (fib n)`.

| m | n | fib m | fib n | gcd | coprime? |
|---|---|-------|-------|-----|----------|
| 3 | 4 | 2 | 3 | 1 | ✓ |
| 4 | 5 | 3 | 5 | 1 | ✓ |
| 5 | 6 | 5 | 8 | 1 | ✓ |
| 5 | 9 | 5 | 34 | 1 | ✓ |

OEIS: Fibonacci numbers = A000045.

## 2. Join sub-law (`fib_lcm_dvd`)

Claim: `lcm (fib m) (fib n) ∣ fib (lcm m n)`.

| m | n | lcm(fib) | lcm(m,n) | fib(lcm) | divides? |
|---|---|----------|----------|----------|----------|
| 2 | 3 | 2 | 6 | 8 | ✓ |
| 4 | 6 | 24 | 12 | 144 | ✓ |
| 3 | 4 | 6 | 12 | 144 | ✓ |

Note the inequality is strict in general (e.g. `lcm(fib 4, fib 6)=24 < 144=fib 12`),
confirming the join law is only a *divisibility*, never an equality — the structural
asymmetry recorded in the lab notes.

## 3. Product law (`fib_prod_dvd`)

Claim: pairwise-coprime indices ⇒ `∏ fib(g i) ∣ fib(∏ g i)`.

| indices | ∏ fib | ∏ indices | fib(∏) | divides? |
|---------|-------|-----------|--------|----------|
| {2,3} | 1·2=2 | 6 | 8 | ✓ |
| {3,4} | 2·3=6 | 12 | 144 | ✓ |
| {4,5} | 3·5=15 | 20 | 6765 | ✓ (6765/15=451) |

## 4. Mersenne gcd law (`mersenne_gcd_coprime`)

Claim: `Coprime m n ⇒ gcd (b^m-1) (b^n-1) = b-1`.

| b | m | n | b^m-1 | b^n-1 | gcd | b-1 |
|---|---|---|-------|-------|-----|-----|
| 2 | 2 | 3 | 3 | 7 | 1 | 1 |
| 3 | 2 | 3 | 8 | 26 | 2 | 2 |
| 2 | 3 | 5 | 7 | 31 | 1 | 1 |

This is exactly `(mersenneSDS b).a 1 = b-1`, explaining why coprimality does **not**
propagate for Mersenne numbers (the lattice top `1` maps to `b-1 ≠ 1`).

## 5. Mersenne order embedding (`mersenne_dvd_iff`)

Claim: for `b ≥ 2`, `(b^m-1) ∣ (b^n-1) ↔ m ∣ n`.

| b | m | n | divides indices? | divides values? |
|---|---|---|------------------|-----------------|
| 2 | 2 | 6 | ✓ (2∣6) | 3∣63 ✓ |
| 2 | 3 | 6 | ✓ | 7∣63 ✓ |
| 2 | 4 | 6 | ✗ (4∤6) | 15∤63 ✗ |
| 3 | 2 | 4 | ✓ | 8∣80 ✓ |

Both directions agree on every sample — no counterexamples found.

## Counterexample hunt summary

No counterexamples were found for any formalized claim. The only "near miss" is that
the join law and the Mersenne coprimality fail to be *equalities*; both are stated and
proved at the correct strength (divisibility / residual `b-1`).
