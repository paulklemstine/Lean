# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize the fundamental theorem that every composite natural number admits a nontrivial factorization — that is, for any n > 1 that is not prime, there exist integers a, b > 1 with a · b = n. While mathematically elementary, this result is the logical foundation upon which all factoring algorithms rest. Our Lean 4 formalization uses Mathlib's `Nat.exists_dvd_of_not_prime2` to extract a nontrivial divisor, then constructs the complementary factor via integer division. The original proposed statement (claiming *every* n > 1 factors nontrivially) was identified as false — primes are the precise obstruction — and we provide a corrected formalization with a machine-verified proof. This illustrates how formal verification catches subtle errors in mathematical specifications, even those motivated by sophisticated p-adic and Newton polygon heuristics.

## 2. MOTIVATION

Integer factorization lies at the heart of computational number theory and modern cryptography. RSA encryption, one of the most widely deployed public-key systems, derives its security from the assumed computational difficulty of factoring large semiprimes. Formally verifying the *existence* of nontrivial factorizations for composite numbers is a prerequisite for reasoning about the correctness of factoring algorithms (trial division, Pollard's rho, quadratic sieve, number field sieve) in a proof assistant. Furthermore, the p-adic perspective on factoring — analyzing Newton polygons of polynomials over Qₚ and applying Hensel's lemma — connects elementary number theory to deep algebraic structures, suggesting that formal verification of factoring theory may benefit from the rich algebraic infrastructure in Mathlib.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is *prime* if n ≥ 2 and its only positive divisors are 1 and n.
- A natural number n > 1 is *composite* if it is not prime, equivalently if there exists some d with 1 < d < n and d | n.
- The *minimal factor* `n.minFac` is the smallest prime dividing n.

**Key Mathlib lemma:**
- `Nat.exists_dvd_of_not_prime2`: For n > 1 with ¬ n.Prime, there exists k such that k | n and 1 < k < n.

**Notation:** We work entirely in ℕ with Lean 4 / Mathlib conventions. Division is truncating (`Nat.div`), and `Nat.mul_div_cancel'` recovers `k * (n / k) = n` when `k | n`.

## 4. PROOF OVERVIEW

**Strategy:** The proof proceeds in three steps:

1. **Extract a nontrivial divisor.** Since n > 1 and n is not prime, `Nat.exists_dvd_of_not_prime2` yields a factor k with k | n and 1 < k < n.

2. **Construct the complementary factor.** Set a = k and b = n / k. Since k | n, we have a * b = k * (n / k) = n by `Nat.mul_div_cancel'`.

3. **Verify both factors exceed 1.** We have a = k > 1 directly. For b = n / k > 1, we use the fact that k < n together with divisibility: n / k ≥ 2 because k < n and k | n, so n / k ≠ 1 (else n = k, contradicting k < n). The `nlinarith` tactic closes both goals automatically.

## 5. NOVELTY ANALYSIS

The mathematical content is classical, but the formalization highlights several important points:

- **Specification debugging:** The original statement was false (it omitted the compositeness hypothesis). Formal verification caught this immediately — no proof exists for the original statement because primes are counterexamples. This demonstrates formal methods as a *specification* tool, not just a verification tool.

- **Lean 4 / Mathlib ecosystem:** The proof leverages `Nat.exists_dvd_of_not_prime2`, a relatively recent Mathlib addition that cleanly packages the divisor-extraction step, and `nlinarith` for the arithmetic bounds.

- **Bridge to p-adic methods:** While the final proof is elementary, the motivating framework — Newton polygons over Qₚ and Hensel lifting — points toward formalizing deeper connections between p-adic analysis and integer factorization, an area largely untouched in current proof assistant libraries.

## 6. OPEN PROBLEMS

1. **Formal complexity of factoring:** Can we formalize in Lean that no known polynomial-time classical algorithm exists for integer factorization, and state the relationship to the P vs NP problem precisely?

2. **Hensel lifting formalization:** Mathlib contains Hensel's lemma for complete local rings. Can this be instantiated over Zₚ to produce a verified p-adic factoring procedure that lifts modular factorizations to factorizations over the integers?

3. **Newton polygon infrastructure:** Can one formalize Newton polygons of polynomials over Qₚ in Lean 4 and prove the classical theorem relating slopes of the Newton polygon to p-adic valuations of roots?

## 7. REFERENCES

1. Neukirch, J. (1999). *Algebraic Number Theory*. Springer-Verlag. (Standard reference for p-adic numbers and Hensel's lemma.)

2. Gouvêa, F. Q. (1997). *p-adic Numbers: An Introduction* (2nd ed.). Springer. (Accessible treatment of p-adic analysis.)

3. Crandall, R., & Pomerance, C. (2005). *Prime Numbers: A Computational Perspective* (2nd ed.). Springer. (Comprehensive treatment of factoring algorithms.)

4. The Mathlib Community. (2020–2025). *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4

5. Lenstra, A. K., & Lenstra, H. W., Jr. (Eds.). (1993). *The Development of the Number Field Sieve*. Lecture Notes in Mathematics, vol. 1554, Springer.
