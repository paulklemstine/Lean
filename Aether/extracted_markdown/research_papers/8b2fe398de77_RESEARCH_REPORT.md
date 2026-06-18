# Non-Archimedean Factoring Oracle: Research Report

## 1. ABSTRACT

We investigate a proposed "p-adic factoring oracle" claiming that every integer n > 1 admits a non-trivial factorization into two factors each greater than 1, parameterized by a prime p. We formally prove in Lean 4 (Mathlib) that this statement is **false**: prime numbers serve as immediate counterexamples. We provide a corrected formalization establishing that every *composite* number n > 1 admits such a factorization, using the minimal factor `Nat.minFac` and Mathlib's `Nat.exists_dvd_of_not_prime2` characterization. Additionally, we supply a machine-verified disproof of the original claim by exhibiting n = 2 as a counterexample. This work illustrates the critical role of formal verification in catching subtle errors in mathematical claims, even those inspired by deep p-adic analytic techniques.

## 2. MOTIVATION

Integer factorization is central to computational number theory and underpins the security of RSA and related cryptosystems. The idea of using p-adic analysis (Hensel's lemma, Newton polygons) to construct factoring algorithms is theoretically attractive. However, any factoring oracle must distinguish between prime and composite inputs — a distinction the original formulation failed to make. This work matters because:

- **Cryptographic security**: Correct formal statements about factorization complexity are essential for rigorous security proofs.
- **Formal verification**: Demonstrates how proof assistants catch errors that informal reasoning misses.
- **p-adic methods**: Clarifies the scope of what p-adic lifting can achieve — it can split composite numbers but cannot factor primes (by definition).

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is *prime* if n > 1 and its only divisors are 1 and n itself.
- A natural number n > 1 is *composite* if it is not prime, equivalently, there exist a, b > 1 with a · b = n.
- The *minimal factor* `Nat.minFac n` is the smallest factor of n greater than 1.

**Key Mathlib lemma:**
- `Nat.exists_dvd_of_not_prime2`: If n > 1 and n is not prime, then there exists k with k ∣ n, 2 ≤ k, and k² ≤ n. This provides a non-trivial divisor from which both factors can be extracted.

## 4. PROOF OVERVIEW

### Corrected theorem (`pAdic_factoring_oracle_corrected`)
Given n > 1 and ¬ Nat.Prime n:
1. Apply `Nat.exists_dvd_of_not_prime2` to obtain a divisor k with k ∣ n, k ≥ 2, and k² ≤ n.
2. Set a = k, b = n / k.
3. Verify a · b = n via `Nat.mul_div_cancel'`.
4. Show a > 1 (since k ≥ 2) and b > 1 (since k² ≤ n implies n/k ≥ k ≥ 2).

### Disproof (`pAdic_factoring_oracle_false`)
1. Instantiate with p = 2, n = 2.
2. Note 2 > 1 is satisfied.
3. For any a, b > 1, we have a ≥ 2 and b ≥ 2, hence a · b ≥ 4 > 2, contradicting a · b = 2.

## 5. NOVELTY ANALYSIS

The primary novelty is methodological rather than mathematical:
- **Formal disproof**: We machine-verify that the original statement is false, providing a concrete counterexample with a complete proof.
- **Minimal correction**: The addition of a single hypothesis (¬ Nat.Prime n) transforms a false claim into a correct and useful theorem.
- **Pedagogical value**: This example illustrates a common error pattern in mathematical formalization — omitting necessary hypotheses that seem "obvious" informally.

## 6. OPEN PROBLEMS

1. **Efficient p-adic factoring**: Can Hensel's lemma be used to construct a polynomial-time factoring algorithm for integers, given an appropriate polynomial whose roots encode the factors? Formalize the complexity analysis.

2. **Newton polygon factorization**: Formalize the relationship between the Newton polygon of a polynomial over ℚ_p and the factorization pattern of the polynomial, including a verified implementation.

3. **Certified factoring oracles**: Can we formalize in Lean a complete certified factoring algorithm (e.g., the number field sieve) with verified correctness guarantees, producing machine-checked factorization certificates?

## 7. REFERENCES

1. Gouvêa, F.Q. *p-adic Numbers: An Introduction*. Springer Universitext, 2nd edition, 1997.
2. Cassels, J.W.S. *Local Fields*. London Mathematical Society Student Texts, Cambridge University Press, 1986.
3. The Mathlib Community. *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4, 2024.
4. Cohn, H. *A Classical Invitation to Algebraic Numbers and Class Fields*. Springer, 1978.
5. Lenstra, A.K. and Lenstra, H.W. Jr. (eds.). *The Development of the Number Field Sieve*. Lecture Notes in Mathematics 1554, Springer, 1993.
