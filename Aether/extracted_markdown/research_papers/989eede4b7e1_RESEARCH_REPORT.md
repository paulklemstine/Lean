# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize in Lean 4 (Mathlib v4.28.0) a theorem establishing that every composite natural number admits a non-trivial factorization. Given a prime p and a natural number n > 1 that is not prime, we constructively produce factors a, b > 1 with a · b = n. The proof leverages Mathlib's `Nat.exists_dvd_of_not_prime2`, which extracts a proper divisor from the negation of primality, and combines divisibility arithmetic with nonlinear reasoning. While the factoring *existence* result is elementary, we frame it within the context of p-adic number theory, where Hensel's lemma and Newton polygons provide algorithmic strategies for lifting approximate factorizations over ℚ_p to exact ones over ℤ. The original conjecture—that *every* n > 1 factors non-trivially—is false (primes are counterexamples), and we document this correction.

## 2. MOTIVATION

Integer factorization is central to computational number theory and modern cryptography. RSA encryption relies on the computational difficulty of factoring large semiprimes. Understanding the *existence* of non-trivial factorizations for composite numbers is a prerequisite for any factoring algorithm, whether classical (trial division, quadratic sieve, number field sieve) or p-adic (Hensel lifting). Formalizing such results in proof assistants like Lean 4 provides machine-verified guarantees that are immune to human error—an increasingly important standard in both pure mathematics and security-critical software verification.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is *prime* if n ≥ 2 and its only divisors are 1 and n itself.
- A natural number n > 1 is *composite* if it is not prime, equivalently if there exists d | n with 1 < d < n.
- The *p-adic valuation* v_p(n) is the largest power of p dividing n.

**Key Mathlib declarations used:**
- `Nat.Prime`: Defined as `Irreducible` in the `ℕ` monoid.
- `Nat.exists_dvd_of_not_prime2`: If n > 1 and n is not prime, there exists k with k | n and 1 < k < n.
- `Nat.mul_div_cancel'`: If k | n, then k * (n / k) = n.

**Notation:** We write a | b for divisibility in ℕ, and use standard Lean 4 / Mathlib conventions.

## 4. PROOF OVERVIEW

**High-level strategy:**

1. **Extract a proper divisor.** Since n > 1 and ¬ Nat.Prime n, apply `Nat.exists_dvd_of_not_prime2` to obtain k such that k | n and 1 < k < n.

2. **Construct the factorization.** Set a := k and b := n / k. By `Nat.mul_div_cancel'`, we have a * b = n.

3. **Verify both factors exceed 1.**
   - a > 1: Immediate from the extracted bounds (k > 1).
   - b > 1: Since k < n and k | n, we have n / k > 1. This follows by nonlinear arithmetic from the divisibility relation.

**Key lemma:** `Nat.exists_dvd_of_not_prime2` encapsulates the combinatorial content—every non-prime above 1 has a divisor strictly between 1 and itself.

## 5. NOVELTY ANALYSIS

The mathematical content is classical and elementary. The novelty lies in:

1. **Formal verification:** Providing a machine-checked proof in Lean 4 with Mathlib, ensuring complete rigor.

2. **Correcting a false conjecture:** The original statement omitted the compositionality hypothesis. Identifying and documenting this error is itself valuable—formal verification forces precision that informal mathematics sometimes elides.

3. **Framing within p-adic theory:** While the proof does not require p-adic methods, the theorem serves as the *specification* that any p-adic factoring oracle must satisfy: given a composite n, produce witnesses a, b > 1 with a * b = n. The p-adic parameter p in the signature anticipates extensions where the factoring method (not just the existence) is formalized.

## 6. OPEN PROBLEMS

1. **Formalize Hensel lifting for factorization:** Can one formalize in Lean 4 a constructive algorithm that, given n composite and a prime p, uses Hensel's lemma over ℤ_p to compute the factorization? This would connect the existence result to an algorithmic p-adic method.

2. **Newton polygon factorization:** Formalize the theorem that the Newton polygon of a polynomial f ∈ ℚ_p[x] determines a factorization of f into factors whose degrees correspond to the polygon's edge lengths. Apply this to the polynomial x² − n to extract square-root-like factorizations.

3. **Complexity-theoretic formalization:** Can one formalize in Lean 4 a proof that integer factorization is in NP ∩ co-NP? The existence theorem provides the NP certificate; the co-NP direction requires AKS primality testing, which has been partially formalized.

## 7. REFERENCES

1. Neukirch, J. *Algebraic Number Theory*. Springer-Verlag, 1999. (Standard reference for p-adic valuations and Hensel's lemma.)

2. Gouvêa, F. Q. *p-adic Numbers: An Introduction*. 2nd ed., Springer, 1997. (Accessible introduction to p-adic analysis and Newton polygons.)

3. The Mathlib Community. *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4, 2024. (Source for all formal declarations used.)

4. Crandall, R. and Pomerance, C. *Prime Numbers: A Computational Perspective*. 2nd ed., Springer, 2005. (Comprehensive treatment of factoring algorithms.)

5. de Moura, L. and Ullrich, S. "The Lean 4 Theorem Prover and Programming Language." *CADE-28*, 2021. (Description of the Lean 4 proof assistant.)
