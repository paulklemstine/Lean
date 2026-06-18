# Answers to Open Questions — Version 8

## Questions Answered in v8

### Q1: Does m = 2^(k+1) - 1 in the Euler direction?
**ANSWER: YES** ✓

**Theorem** (`euler_m_equals_mersenne`): For any even perfect number n = 2^k · m with m odd, if (2^(k+1)-1) | m and the Euler key equation holds, then m = 2^(k+1) - 1.

**Proof**: If m = (2^(k+1)-1)·q with q ≥ 2, then σ₁(m) ≥ 1 + q + (2^(k+1)-1)q, which exceeds 2^(k+1)·q = σ₁(m), a contradiction. Therefore q = 1.

### Q2: If 2^p - 1 is prime, must p be prime?
**ANSWER: YES** ✓

**Theorem** (`mersenne_prime_exponent_prime`): If 2^n - 1 is prime and n > 1, then n is prime.

**Proof**: If n = ab with a, b > 1, then (2^a - 1) | (2^n - 1) gives a nontrivial factorization.

### Q3: Are 1093 and 3511 Wieferich primes?
**ANSWER: YES** ✓

**Theorems** (`wieferich_1093`, `wieferich_3511`): Verified by `native_decide` — modular exponentiation confirms 2^1092 ≡ 1 (mod 1093²) and 2^3510 ≡ 1 (mod 3511²).

### Q4: Does the Wall-Sun-Sun conjecture hold for small primes?
**ANSWER: YES** (for p ≤ 29) ✓

**Theorems** (`wss_check_7` through `wss_check_29`): For each prime p ∈ {7, 11, 13, 17, 19, 23, 29}, we verified p² ∤ F(p-1)·F(p+1) by `native_decide`.

### Q5: Is the product of quadratic residues a quadratic residue?
**ANSWER: YES** ✓

**Theorem** (`qr_mul_qr`): If a ≡ x² and b ≡ y² (mod n), then ab ≡ (xy)² (mod n).

### Q6: Are products of smooth numbers smooth?
**ANSWER: YES** ✓

**Theorem** (`smooth_mul`): If all prime factors of a and b are ≤ B, then all prime factors of ab are ≤ B.

### Q7: Is σ₁(n) > n for all n > 1?
**ANSWER: YES** ✓

**Theorem** (`sigma1_gt_self'`): Since 1 and n are distinct divisors of n > 1, σ₁(n) ≥ 1 + n > n.

### Q8: Are divisors global minima of the energy landscape?
**ANSWER: YES** ✓

**Theorem** (`energy_global_min_at_divisor`): E(N,d) = 0 ≤ E(N,y) for any d | N and any y.

### Q9: Does the Euler characteristic at level 0 equal τ(N)?
**ANSWER: YES** ✓

**Theorem** (`sublevel_zero_eq_divisors`): |{x ∈ [1,N] : E(N,x) = 0}| = |Div(N)|.

### Q10: Are all primes deficient?
**ANSWER: YES** ✓

**Theorem** (`prime_is_deficient'`): σ₁(p) = p + 1 < 2p for any prime p ≥ 2.

---

## Previously Answered Questions (v1-v7)

### Q11: Can σ₁(N) be efficiently approximated? → EQUIVALENT TO FACTORING ✓
### Q12: Does F(p)² ≡ 1 mod p? → YES ✓
### Q13: Do Pisano periods satisfy CRT? → YES ✓
### Q14: Is the discrete Laplacian nonneg at divisors? → YES ✓
### Q15: Do even perfect numbers satisfy the Euler key equation? → YES ✓
### Q16: Is σ₁ multiplicative for coprimes? → YES ✓
### Q17: Does (2^(k+1)-1) | m in the Euler direction? → YES ✓
### Q18: Is the Lipschitz norm multiplicative? → YES ✓
### Q19: Does every number have a 4-square representation? → YES ✓
### Q20: Is π(p) | p²-1 for primes p ≠ 5? → YES ✓
### Q21: Is σ₁_no4(n) = σ₁(n) for odd n? → YES ✓
### Q22: Are divisors local minima of E(x)? → YES ✓
### Q23: Is the sublevel set at N-1 equal to [1,N]? → YES ✓

---

## Remaining Open Questions

### Q24: Do odd perfect numbers exist?
**STATUS: OPEN** — No odd perfect below 10^1500 (Ochem & Rao). Most mathematicians conjecture none exist.

### Q25: Do Wall-Sun-Sun primes exist?
**STATUS: OPEN** — None found below ~10^14 computationally. Our formal verification covers p < 30.

### Q26: Are there more than two Wieferich primes?
**STATUS: OPEN** — Only 1093 and 3511 known. Heuristic arguments suggest infinitely many should exist.

### Q27: Can factoring be done in polynomial time classically?
**STATUS: OPEN** — The central question. Most experts believe P ≠ NP implies no poly-time factoring.

### Q28: Is the energy landscape phase transition sharp?
**STATUS: OPEN** — Numerical evidence suggests a transition near x ∼ √N, but no formal proof.

### Q29: Can persistent homology detect factors efficiently?
**STATUS: OPEN** — The Euler characteristic result is encouraging but insufficient.

### Q30: What is the exact density of Fibonacci pseudoprimes?
**STATUS: OPEN** — Numerical experiments suggest very low density (~10^-5 to 10^-4).

### Q31: Is the Coppersmith N^(1/d) bound optimal?
**STATUS: OPEN** — For degree d, the bound |x₀| < N^(1/d) is believed tight.

### Q32: Can the quadratic sieve be formally verified end-to-end?
**STATUS: OPEN** — Foundations now in place (v8); full formalization estimated at 4-8 weeks.

### Q33: Do quantum algorithms exploit 4-square representations?
**STATUS: OPEN** — Promising but no concrete algorithm proposed.

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Questions answered in v8 | 10 |
| Questions answered in v1-v7 | 13 |
| **Total answered** | **23** |
| Questions remaining open | 10 |
| **Total questions tracked** | **33** |
