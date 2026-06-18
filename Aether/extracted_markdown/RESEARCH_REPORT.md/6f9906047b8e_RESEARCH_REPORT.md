# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate the formalization of integer factorization through the lens of p-adic number theory. The original conjecture — that every integer greater than 1 admits a non-trivial factorization into two factors each exceeding 1 — is shown to be **false**, as it fails for prime numbers. We provide a corrected statement: every *composite* integer n > 1 (equivalently, n > 1 with ¬ Nat.Prime n) can be expressed as a product a · b with a > 1 and b > 1. The corrected theorem is formalized and machine-verified in Lean 4 using Mathlib's `Nat.exists_dvd_of_not_prime2`, which extracts a non-trivial divisor from the compositeness hypothesis. This work highlights the importance of formal verification in catching subtle errors in mathematical statements, even when they are motivated by sophisticated frameworks such as Newton polygons and p-adic lifting.

## 2. MOTIVATION

Integer factorization is central to computational number theory and modern cryptography. The security of RSA, one of the most widely deployed public-key cryptosystems, rests on the assumption that factoring large semiprimes is computationally hard. While p-adic methods (Hensel lifting, Newton polygons) are powerful tools in algebraic number theory, their application to factoring algorithms requires precise mathematical formulations. Formal verification ensures that such formulations are logically consistent before any computational implementation is attempted. This work demonstrates how formalization can serve as a "sanity check" for speculative mathematical frameworks, catching a false universal claim before it propagates into algorithm design.

## 3. MATHEMATICAL FRAMEWORK

**Definitions and Notation:**
- Let n ∈ ℕ with n > 1.
- n is *prime* if its only divisors in ℕ are 1 and n itself (formalized as `Nat.Prime n`).
- n is *composite* if n > 1 and ¬ Nat.Prime n.
- A *non-trivial factorization* of n is a pair (a, b) ∈ ℕ² with a · b = n, a > 1, and b > 1.

**Key Mathlib Lemma:**
- `Nat.exists_dvd_of_not_prime2`: For n > 1 with ¬ Nat.Prime n, there exists k with k ∣ n and 1 < k < n.

**Preliminaries:**
Given such k, we set a = k and b = n / k. Since k ∣ n, we have k · (n / k) = n. The bound 1 < k is immediate, and n / k > 1 follows from k < n and k ∣ n.

## 4. PROOF OVERVIEW

1. **Identify the error:** The original statement quantifies over all n > 1, including primes, which have no non-trivial factorization.
2. **Correct the statement:** Add the hypothesis ¬ Nat.Prime n (compositeness).
3. **Extract a divisor:** Apply `Nat.exists_dvd_of_not_prime2` to obtain k with k ∣ n and 1 < k < n.
4. **Construct factors:** Set a = k and b = n / k.
5. **Verify conditions:**
   - a · b = n: by `Nat.mul_div_cancel'` (since k ∣ n).
   - a > 1: directly from the bound on k.
   - b > 1: from k < n and divisibility, via `nlinarith`.

The proof is concise (5 lines of tactic-mode Lean) and relies entirely on Mathlib's natural number arithmetic library.

## 5. NOVELTY ANALYSIS

The primary novelty is **negative**: we demonstrate that the originally proposed "p-adic factoring oracle" theorem is false as stated. This is instructive because:

- It shows that even mathematically sophisticated motivations (Newton polygons, Hensel's lemma) can lead to incorrectly formulated statements when the connection to the formal claim is not rigorous.
- The correction is minimal — a single additional hypothesis (compositeness) — illustrating how formal verification pinpoints exactly what is missing.
- The verified proof serves as a baseline formalization for composite factorization, upon which more substantive p-adic factoring algorithms could be built.

## 6. OPEN PROBLEMS

1. **Formalize Hensel's lemma for factoring:** Can one formalize in Lean a proof that Hensel lifting in ℤ_p can be used to lift approximate factorizations of polynomials mod p to exact factorizations, and apply this to integer factorization?

2. **Newton polygon factorization:** Formalize the theorem that the Newton polygon of a polynomial f ∈ ℚ_p[x] determines the p-adic valuations of its roots, and use this to give a certified factorization algorithm.

3. **Complexity-theoretic formalization:** Can one formalize in Lean a proof that integer factorization is in NP ∩ co-NP, connecting the existential factorization statement to computational complexity classes?

## 7. REFERENCES

1. Neukirch, J. (1999). *Algebraic Number Theory*. Springer-Verlag. (Standard reference for p-adic numbers and Hensel's lemma.)

2. Gouvêa, F. Q. (1997). *p-adic Numbers: An Introduction*. Springer Universitext. (Accessible introduction to p-adic analysis.)

3. The Mathlib Community. (2020–2025). *Mathlib: The Lean Mathematical Library*. https://github.com/leanprover-community/mathlib4

4. Crandall, R., & Pomerance, C. (2005). *Prime Numbers: A Computational Perspective*. Springer. (Comprehensive treatment of factoring algorithms.)

5. de Moura, L., & Ullrich, S. (2021). "The Lean 4 Theorem Prover and Programming Language." *CADE-28*. (Description of the Lean 4 proof assistant.)
