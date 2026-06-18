# Summary of changes for run 0ee64cc4-f66d-4edf-8483-800a5ec786a0
## Summary

### Task
Prove the Lifting-the-Exponent (LTE) Lemma for Fibonacci numbers and use it to close the last sorry in `Shared/CarmichaelProof.lean` (composite n > 10000).

### What was accomplished

**1. New file: `Shared/FibPrimitive.lean`** — Contains the foundational infrastructure for Fibonacci primitive prime divisors, with the following fully proved results:

- **`fib_bridge`**: Bridge lemma — if p | F(n) and p ∤ F(d) for every proper divisor d of n, then p ∤ F(k) for any 0 < k < n. Uses `Nat.fib_gcd`.
- **`fib_gcd_eq`**: The identity gcd(F(a), F(b)) = F(gcd(a,b)).
- **`fib_coprime_of_coprime`**: For coprime a, b: F(a) and F(b) are coprime.
- **`fib_mul_dvd_of_coprime`**: For coprime a, b: F(a)·F(b) divides F(a·b).
- **Entry point theory** (`fibEp`, `fibEp_spec`, `fibEp_min`, `fibEp_dvd`, `dvd_fib_of_fibEp_dvd`): Complete formalization of the Fibonacci entry point (rank of apparition) — the smallest k > 0 with p | F(k) — including existence via the pigeonhole principle, minimality, and the key property that the entry point divides n iff p | F(n).
- **Theorem statements** for `fib_primitive_semiprime`, `fib_primitive_prime_power`, and `fib_primitive_composite` (with sorries for the proofs).

**2. New file: `Shared/FibLTE.lean`** — Additional infrastructure including:

- **`fib_ge_self`**: F(n) ≥ n for n ≥ 5.
- **`fib_strict_mono`**: F is strictly monotone for n ≥ 2.
- **`fib_mul_dvd_of_coprime`**: F(a)·F(b) | F(ab) for coprime a, b.
- Complete entry point theory (duplicate of FibPrimitive, with independent proofs).
- Additional sorry'd lemmas for the quotient analysis.

**3. Updated `Shared/CarmichaelProof.lean`** — Added detailed comments at the sorry explaining the mathematical approach needed:
- The LTE for Fibonacci: v_r(F(pm)) = v_r(F(m)) + v_r(p) for primes r ≥ 5
- The coprimality consequence: gcd(F(pm)/F(m), F(m)) divides p^∞
- The semiprime case: F(pq)/(F(p)·F(q)) has all primitive factors
- The prime power case: F(p^k)/F(p^{k-1}) has all primitive factors

### What remains (the sorry)

The sorry in `Shared/CarmichaelProof.lean` line 138 for composite n > 10000 remains open. This is Carmichael's theorem — a deep result in number theory. The proof requires:

1. **The Fibonacci LTE**: For prime r with entry point z(r) dividing m: v_r(F(mn)) = v_r(F(m)) + v_r(n). This follows from the congruence F(mn) ≡ n·F(m)·F(m-1)^(n-1) (mod F(m)²), which itself follows from the Fibonacci matrix identity A^m = F(m-1)·I + F(m)·A.

2. **Coprimality of quotients**: The LTE implies that for distinct primes p, q: the quotient F(pq)/(F(p)·F(q)) is coprime to F(p)·F(q), so every prime factor has entry point exactly pq.

3. **General composite case**: Reduction via the Fibonacci cyclotomic number Ψ(n) = ∏_{d|n} F(d)^{μ(n/d)}, showing Ψ(n) > 1 for composite n ≥ 13.

The infrastructure built here (entry point theory, bridge lemma, coprimality results) provides the necessary foundation. The remaining work is formalizing the matrix congruence and the Möbius product analysis.