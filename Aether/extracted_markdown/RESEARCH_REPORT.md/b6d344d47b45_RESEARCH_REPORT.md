# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate a theorem inspired by the idea of using p-adic analytic methods to construct integer factoring oracles. The original formulation — that every integer greater than 1 admits a non-trivial factorization — is false, as it fails for all prime numbers. We provide a corrected statement: every composite integer n > 1 (i.e., one that is not prime) can be expressed as a product a · b with both a > 1 and b > 1. The corrected theorem is proved formally in Lean 4 using Mathlib's `Nat.exists_dvd_of_not_prime2`, which extracts a non-trivial divisor from the compositeness hypothesis. While the core result is elementary number theory, the surrounding motivation — using p-adic valuations and Newton polygons to guide factoring — connects to deep ideas in algorithmic number theory.

## 2. MOTIVATION

Integer factorization is a cornerstone of modern cryptography. RSA encryption relies on the computational hardness of factoring large semiprimes. Understanding the mathematical structure of factorability — distinguishing primes from composites, and extracting factors from composites — is therefore of direct relevance to:

- **Cryptography**: Any oracle that factors integers in polynomial time would break RSA, Rabin, and related cryptosystems.
- **Algorithmic Number Theory**: Methods based on p-adic analysis (Hensel lifting, Newton polygons) provide alternative perspectives on factoring algorithms like the number field sieve.
- **Formal Verification**: Machine-checked proofs of number-theoretic facts provide the highest assurance for security-critical code.

## 3. MATHEMATICAL FRAMEWORK

**Definitions and Notation:**
- Let n ∈ ℕ with n > 1.
- n is *prime* if its only divisors are 1 and n itself.
- n is *composite* if it is not prime and n > 1, meaning ∃ d | n with 1 < d < n.
- For a prime p, the *p-adic valuation* v_p(n) is the largest power of p dividing n.

**Key Mathlib Lemma:**
- `Nat.exists_dvd_of_not_prime2`: For n > 1 and ¬ Prime n, there exists k with k ∣ n, 1 < k, and k < n.

**Thematic Context (Newton Polygons):**
Given a polynomial f(x) = Σ aᵢ xⁱ over ℚ_p, the Newton polygon is the lower convex hull of the points (i, v_p(aᵢ)). Its slopes determine the p-adic valuations of the roots (by the theory of Hensel's lemma). In the factoring context, one associates to n a polynomial whose Newton polygon structure reflects the prime decomposition of n.

## 4. PROOF OVERVIEW

**High-level strategy:**

1. **Input**: n > 1 and ¬ Nat.Prime n.
2. **Extract a non-trivial divisor**: Apply `Nat.exists_dvd_of_not_prime2` to obtain k with k ∣ n, 1 < k, and k < n.
3. **Construct the factorization**: Set a = k and b = n / k. Since k ∣ n, we have k * (n / k) = n.
4. **Verify bounds**: a = k > 1 by the lemma. For b = n / k, since k < n and k > 1, we get n / k > 1 (proved via `nlinarith` and `Nat.div_mul_cancel`).

The proof is three lines in Lean, leveraging Mathlib's compositeness API.

## 5. NOVELTY ANALYSIS

The original statement was provably false — it omitted the essential hypothesis that n is not prime. The corrected theorem, while elementary, demonstrates:

- **The importance of precise formalization**: The "p-adic factoring oracle" framing can mislead one into believing a stronger (false) statement.
- **Formal verification as a guardrail**: The Lean proof assistant immediately rejects the original statement, forcing the mathematician to confront the logical gap.
- **Clean API usage**: The proof showcases Mathlib's `Nat.exists_dvd_of_not_prime2` as an elegant interface for compositeness reasoning.

## 6. OPEN PROBLEMS

1. **Formalize p-adic factoring algorithms**: Can Hensel's lemma (already in Mathlib) be combined with Newton polygon analysis to produce a verified factoring algorithm for polynomials over ℚ_p, and can this be connected to integer factoring?

2. **Complexity-theoretic formalization**: Can one formalize in Lean the statement that integer factoring is in NP ∩ coNP, using Pratt certificates and AKS primality?

3. **Tropical factoring**: The Newton polygon is the tropicalization of the polynomial's root structure. Can tropical geometry methods yield new factoring heuristics, and can their correctness be formally verified?

## 7. REFERENCES

1. Neukirch, J. *Algebraic Number Theory*. Springer, 1999. (p-adic valuations and Hensel's lemma)
2. Gouvêa, F. Q. *p-adic Numbers: An Introduction*. 2nd ed., Springer, 1997.
3. The Mathlib Community. *Mathlib4: Mathematics in Lean 4*. https://leanprover-community.github.io/mathlib4_docs/
4. Crandall, R. and Pomerance, C. *Prime Numbers: A Computational Perspective*. 2nd ed., Springer, 2005.
5. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
