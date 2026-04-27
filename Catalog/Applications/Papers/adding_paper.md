# Non-Archimedean Factoring Oracle: Research Report

## 1. ABSTRACT

We investigate a proposed "p-adic factoring oracle" that claims to factor any integer n > 1 into two non-trivial factors by analyzing Newton polygons over the p-adic numbers Q_p. We demonstrate that the original conjecture is **false as stated**: prime numbers constitute immediate counterexamples, since any product of two integers each exceeding 1 must be at least 4. We provide a machine-verified disproof in Lean 4 using Mathlib, together with a corrected theorem establishing that every **composite** number n > 1 admits a non-trivial factorization. The corrected result follows from the existence of a minimal factor via `Nat.exists_dvd_of_not_prime2`. This work clarifies the boundary between trivially factorable composites and irreducible primes, a distinction that any purported factoring oracle must respect.

## 2. MOTIVATION

Integer factorization is central to computational number theory and underpins the security of RSA and related cryptosystems. Proposals for factoring oracles—algorithms that could efficiently decompose any integer—are of tremendous theoretical and practical interest. The p-adic approach, leveraging Hensel's lemma and Newton polygon analysis, represents a creative attempt to exploit non-Archimedean structure for factoring. However, any such scheme must contend with the fundamental fact that primes have no non-trivial factorizations. Our formalization highlights the importance of precise mathematical statements in cryptographic research.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- **Natural number factorization:** For n ∈ ℕ, a *non-trivial factorization* is a pair (a, b) with a > 1, b > 1, and a · b = n.
- **Prime number:** A natural number p > 1 is prime if its only divisors are 1 and p.
- **Composite number:** A natural number n > 1 that is not prime.

**Key Mathlib API:**
- `Nat.exists_dvd_of_not_prime2`: If n > 1 and n is not prime, then there exists k with 1 < k < n and k ∣ n.
- `Nat.div_mul_cancel`: If k ∣ n, then n / k * k = n.

## 4. PROOF OVERVIEW

### Counterexample (Original Statement is False)
We exhibit n = 3 as a counterexample. For any a, b > 1 (so a ≥ 2, b ≥ 2), we have a · b ≥ 4 > 3, contradicting a · b = 3. This is verified by `nlinarith`.

### Corrected Theorem
For composite n > 1:
1. Apply `Nat.exists_dvd_of_not_prime2` to obtain k with 1 < k < n and k ∣ n.
2. Set a = k and b = n/k.
3. Verify a · b = n (via `Nat.div_mul_cancel`).
4. Verify a > 1 (from 1 < k) and b > 1 (from k < n and divisibility).

## 5. NOVELTY ANALYSIS

The primary novelty lies in the **formal disproof** of a plausible-sounding conjecture and its machine-verified correction. While the mathematical content is elementary, the exercise demonstrates:
- The power of formal verification to catch subtle errors in mathematical claims.
- How p-adic motivation, while mathematically rich, does not circumvent the prime/composite dichotomy.
- A clean decomposition of the corrected result using Mathlib's number theory API.

## 6. OPEN PROBLEMS

1. **Efficient factoring via p-adic methods:** Can Hensel lifting over Q_p provide a polynomial-time algorithm for factoring *composites*, even if it cannot factor primes?
2. **Newton polygon certificates:** Can the Newton polygon of x^n - 1 over Q_p certify compositeness of n in a formally verifiable way?
3. **Formalization of p-adic factoring algorithms:** Can a complete p-adic factoring algorithm (e.g., based on Coppola–Murty) be formalized and verified in Lean/Mathlib?

## 7. REFERENCES

1. Gouvêa, F. Q. *p-adic Numbers: An Introduction*. Springer, 2nd edition, 1997.
2. Neukirch, J. *Algebraic Number Theory*. Springer, 1999.
3. The Mathlib Community. *Mathlib4: A Unified Library of Mathematics in Lean 4*. https://github.com/leanprover-community/mathlib4.
4. Cohen, H. *A Course in Computational Algebraic Number Theory*. Springer, 1993.
