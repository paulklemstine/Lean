# Research Report: Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate the claim that p-adic methods yield a universal factoring oracle for natural numbers greater than 1. Specifically, we examine the theorem that every n > 1 admits a non-trivial factorization n = a · b with a, b > 1. We demonstrate that this statement is **false** as originally posed—primes are obvious counterexamples. We then prove a corrected version: every **composite** number n > 1 (equivalently, n > 1 and ¬Prime(n)) factors non-trivially. The proof is formalized in Lean 4 with Mathlib, using the characterization of composite numbers via the existence of a divisor d with 1 < d < n. While the p-adic framing is mathematically suggestive, the corrected result is a purely number-theoretic fact about the integers.

## 2. MOTIVATION

Integer factorization is a central problem in computational number theory and underpins the security of RSA and related cryptographic systems. Understanding the **existence** of non-trivial factorizations is a prerequisite for any algorithmic approach. While the existence result itself is elementary, its formal verification in a proof assistant like Lean 4 contributes to the growing library of machine-checked number theory. The p-adic perspective, though not needed for the existence proof, connects to deeper ideas: Newton polygons over Q_p can reveal factorizations of polynomials, and Hensel's lemma lifts approximate roots to exact ones—techniques that have genuine algorithmic applications in computational algebra.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is **prime** if n ≥ 2 and its only divisors are 1 and n.
- A natural number n > 1 is **composite** if it is not prime, equivalently, if there exists d with d ∣ n and 1 < d < n.
- The **minimal factor** `Nat.minFac n` is the smallest factor of n greater than 1.

**Key Lemma (Mathlib):**
`Nat.exists_dvd_of_not_prime2`: If n > 1 and ¬Prime(n), then there exists k such that k ∣ n and 1 < k < n.

**Notation:** We write a ∣ b for divisibility, and use standard Lean/Mathlib conventions for natural number arithmetic.

## 4. PROOF OVERVIEW

The proof proceeds as follows:

1. **Assume** n > 1 and n is not prime.
2. **Extract** a non-trivial divisor: By `Nat.exists_dvd_of_not_prime2`, there exists k with k ∣ n and 1 < k < n.
3. **Construct** the factorization: Set a = k and b = n / k. Since k ∣ n, we have k · (n/k) = n.
4. **Verify bounds**: a = k > 1 by construction. For b = n/k > 1: since k < n and k ∣ n, we have n/k ≥ 2 (because if n/k = 1 then n = k, contradicting k < n).

The Lean proof uses `Nat.mul_div_cancel'` for the factorization identity and `nlinarith` with `Nat.div_mul_cancel` for the bound on b.

## 5. NOVELTY ANALYSIS

The mathematical content is classical and well-known. The novelty lies in:

- **Falsification of the original claim**: The original statement omitted the compositionality hypothesis, making it false. Identifying and correcting this error is itself a contribution.
- **Machine verification**: The corrected theorem is fully verified in Lean 4 with Mathlib, contributing to the corpus of formally verified number theory.
- **Conciseness**: The proof is a single tactic block, leveraging Mathlib's existing infrastructure for prime factorization.

## 6. OPEN PROBLEMS

1. **Algorithmic content**: Can the Lean proof be made computationally extractable, yielding an actual factoring algorithm (even if exponential-time) via program extraction?

2. **P-adic factorization of polynomials**: Can Hensel's lemma over Q_p be formalized in Lean/Mathlib to give a verified algorithm for factoring polynomials over the p-adics, and can this be connected to integer factorization?

3. **Complexity bounds**: Can one formalize in Lean the statement that integer factorization is in NP ∩ co-NP, leveraging the AKS primality test (already partially formalized in Mathlib)?

## 7. REFERENCES

1. Gouvêa, F. Q. *p-adic Numbers: An Introduction*. 2nd ed., Springer, 2003.
2. Neukirch, J. *Algebraic Number Theory*. Springer, 1999.
3. The Mathlib Community. *Mathlib4: A Unified Library of Mathematics Formalized in Lean 4*. https://github.com/leanprover-community/mathlib4, 2024.
4. Avigad, J., de Moura, L., and Kong, S. "Theorem proving in Lean." *Carnegie Mellon University*, 2017.
5. Cohen, H. *A Course in Computational Algebraic Number Theory*. Springer, 1993.
