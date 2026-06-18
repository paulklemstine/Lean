# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate a theorem concerning the nontrivial factorization of composite natural numbers, originally motivated by the idea of using p-adic Newton polygons as a factoring oracle. The original statement—that every integer n > 1 admits a factorization into two factors both exceeding 1—is false for primes. We correct the statement by adding a compositeness hypothesis and provide a fully machine-verified proof in Lean 4 using Mathlib. The corrected theorem establishes that every composite n > 1 can be expressed as n = a · b with a, b > 1, leveraging the minimum-factor decomposition from Mathlib's `Nat.exists_dvd_of_not_prime2`. While elementary, this result serves as a foundational building block for more sophisticated p-adic factoring algorithms and illustrates how formal verification catches subtle errors in mathematical claims.

## 2. MOTIVATION

Integer factorization is central to modern cryptography (RSA, Diffie–Hellman over finite fields), computational number theory, and complexity theory. The question of whether efficient factoring algorithms exist remains one of the deepest open problems in computer science. P-adic methods—leveraging Hensel lifting and Newton polygons over the p-adic integers—offer a tantalizing alternative to classical sieve methods. While the theorem proved here is elementary, it establishes the logical foundation that every composite number *does* have a nontrivial factorization, a prerequisite for any factoring algorithm's correctness proof. The formal verification aspect is equally important: as factoring algorithms grow in complexity, machine-checked correctness becomes essential to ensure cryptographic security claims rest on solid mathematical ground.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is *prime* if n ≥ 2 and its only divisors are 1 and n.
- A natural number n > 1 is *composite* if it is not prime, equivalently if there exist a, b > 1 with a · b = n.
- The *minimum factor* `minFac(n)` is the smallest factor of n greater than 1.

**Key Mathlib declarations used:**
- `Nat.exists_dvd_of_not_prime2`: For n > 1 and ¬Prime(n), there exists k | n with 1 < k < n.
- `Nat.mul_div_cancel'`: If k | n then k * (n / k) = n.

## 4. PROOF OVERVIEW

The proof proceeds in three steps:

1. **Extract a nontrivial divisor.** Since n > 1 and n is not prime, `Nat.exists_dvd_of_not_prime2` yields a divisor k with k | n, 1 < k, and k < n.

2. **Construct the complementary factor.** Set a = k and b = n / k. Since k | n, we have a * b = n by `Nat.mul_div_cancel'`.

3. **Verify both factors exceed 1.** We have a = k > 1 directly. For b = n / k > 1, note that k < n and k | n together imply n / k ≥ 2 (since if n / k = 1 then n = k, contradicting k < n).

The proof is two lines in Lean, using `obtain` for existential elimination and `nlinarith` for the arithmetic bound on b.

## 5. NOVELTY ANALYSIS

The primary novelty lies not in the mathematical content (which is elementary) but in three aspects:

1. **Formal falsification of the original claim.** The original theorem omitted the compositeness hypothesis, making it false for primes. This demonstrates the value of formal verification in catching "obvious" errors.

2. **Minimal proof via Mathlib infrastructure.** The two-line proof showcases the maturity of Mathlib's number theory library, where deep infrastructure (minimum factors, divisibility calculus) makes elementary results nearly automatic.

3. **Foundation for p-adic factoring formalization.** This corrected statement provides a verified starting point for formalizing more sophisticated p-adic factoring algorithms (Hensel lifting, Newton polygon analysis).

## 6. OPEN PROBLEMS

1. **Formalize Hensel's lemma for factoring:** Can one formally verify a p-adic lifting algorithm that, given a factorization modulo p, lifts it to a factorization over ℤ? This would connect the "oracle" to actual p-adic machinery.

2. **Complexity bounds in Lean:** Can one formalize the polynomial-time complexity of p-adic Hensel lifting for integer factorization, proving that lifting requires O(log n) steps?

3. **Newton polygon factorization:** Formalize the theorem that the Newton polygon of a polynomial over ℚ_p determines a factorization into components corresponding to the polygon's edges, and verify its application to integer factoring.

## 7. REFERENCES

1. Neukirch, J. *Algebraic Number Theory*. Springer, 1999. (Chapter II: p-adic valuations and Hensel's lemma.)
2. Knuth, D.E. *The Art of Computer Programming, Vol. 2: Seminumerical Algorithms*. Addison-Wesley, 1997. (Section 4.5.4: Factoring into primes.)
3. The Mathlib Community. *Mathlib4: Mathematics in Lean 4*. https://github.com/leanprover-community/mathlib4, 2024.
4. Gouvêa, F.Q. *p-adic Numbers: An Introduction*. Springer, 1997. (Newton polygons and factorization over p-adic fields.)
