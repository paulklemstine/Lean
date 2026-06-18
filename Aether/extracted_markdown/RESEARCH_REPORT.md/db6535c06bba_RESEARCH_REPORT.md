# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate a theorem inspired by p-adic methods for integer factorization. The original claim—that every integer n > 1 admits a non-trivial factorization—is false, as primes are counterexamples. We provide a corrected formalization: every **composite** integer n > 1 can be written as a product a · b with both a > 1 and b > 1. While this corrected result is elementary, its formal verification in Lean 4 with Mathlib demonstrates how number-theoretic primitives (minimal factors, divisibility) interact with proof automation. The proof leverages `Nat.exists_dvd_of_not_prime2`, which extracts a non-trivial divisor from the hypothesis that n is not prime, combined with divisor arithmetic to bound both factors. This work illustrates the importance of precise statement formulation in formal mathematics—a lesson that carries over to more sophisticated p-adic factoring algorithms.

## 2. MOTIVATION

Integer factorization is central to modern cryptography: the security of RSA and related systems rests on the computational difficulty of factoring large semiprimes. Understanding the **existence** of factorizations (as opposed to their efficient computation) is the logical foundation upon which complexity-theoretic hardness results are built. Formal verification of such foundational statements ensures that cryptographic security arguments rest on solid mathematical ground. Furthermore, p-adic methods have genuine applications in algorithmic number theory—Hensel lifting is used in polynomial factorization over ℤ, and Newton polygons over ℚ_p guide factorization strategies.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is **prime** if n ≥ 2 and its only divisors are 1 and n.
- A natural number n > 1 is **composite** if it is not prime.
- The **minimal factor** `minFac(n)` is the smallest prime dividing n.

**Key Properties (Mathlib):**
- `Nat.exists_dvd_of_not_prime2`: If n > 1 and n is not prime, then there exists k with k ∣ n and 2 ≤ k < n.
- `Nat.mul_div_cancel'`: If k ∣ n, then k * (n / k) = n.
- `Nat.div_mul_cancel`: If k ∣ n, then n / k * k = n.

## 4. PROOF OVERVIEW

**High-level strategy:**

1. Since n > 1 and n is not prime, apply `Nat.exists_dvd_of_not_prime2` to obtain a divisor k with 1 < k < n and k ∣ n.
2. Set a = k and b = n / k.
3. The product a * b = k * (n / k) = n follows from `Nat.mul_div_cancel'`.
4. We have a = k > 1 by construction.
5. For b = n / k > 1: since k < n and k ≥ 2, we get n / k ≥ 2 > 1 (using the divisibility relation and arithmetic bounds).

The proof is a one-liner in Lean, combining case analysis with arithmetic reasoning via `nlinarith`.

## 5. NOVELTY ANALYSIS

The primary novelty lies not in the mathematical content (which is elementary) but in the **diagnosis and correction** of the original false statement. The original theorem omitted the compositeness hypothesis, rendering it unprovable. This illustrates a common pitfall in automated theorem generation: conflating the existence of factorization algorithms with the universal existence of non-trivial factorizations. The corrected formalization demonstrates rigorous statement engineering in formal proof assistants.

## 6. OPEN PROBLEMS

1. **Efficient certified factorization:** Can one formalize in Lean a polynomial-time factoring algorithm for specific number classes (e.g., smooth numbers) with a verified correctness proof?

2. **P-adic factoring bounds:** Can Hensel's lemma be used to formally derive complexity bounds for lifting-based factoring algorithms over ℚ_p?

3. **Unique factorization formalization:** While Mathlib contains `Nat.UniqueFactorizationMonoid`, can one formalize the connection between Newton polygon analysis over ℚ_p and the factorization of univariate polynomials over ℤ, yielding integer factorization as a corollary?

## 7. REFERENCES

1. Gouvêa, F. Q. *p-adic Numbers: An Introduction*. Springer, Universitext, 2nd edition, 1997.
2. Cohen, H. *A Course in Computational Algebraic Number Theory*. Springer, Graduate Texts in Mathematics, Vol. 138, 1993.
3. The mathlib Community. *mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4, 2024.
4. Coppel, W. A. *Number Theory: An Introduction to Mathematics*. Springer, 2nd edition, 2009.
