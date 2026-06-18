# Non-Archimedean Factoring Oracle: A Formal Verification of Composite Number Decomposition

## 1. ABSTRACT

We formalize and verify in Lean 4 (Mathlib4) the theorem that every composite natural number admits a non-trivial factorization into two factors, each strictly greater than one. The original conjecture — that *every* integer greater than one can be so factored — is false, as prime numbers constitute precisely the counterexamples. We prove the corrected statement using Mathlib's `Nat.exists_dvd_of_not_prime2`, which provides a divisor d with 2 ≤ d < n for any composite n ≥ 2. The complementary factor n/d is shown to exceed 1 via divisibility arithmetic. The proof is machine-checked with only standard axioms (propext, Classical.choice, Quot.sound), providing absolute certainty. This work illustrates how formal verification catches subtle errors in "obviously true" mathematical claims.

## 2. MOTIVATION

Integer factorization sits at the crossroads of number theory, computational complexity, and cryptography. The security of RSA and related cryptosystems rests on the *computational* difficulty of factoring, not on the *existential* question of whether factors exist. Nevertheless, formalizing the existence of non-trivial factorizations for composite numbers is foundational:

- **Cryptographic foundations**: Any formal treatment of RSA correctness must first establish that composite numbers have factors.
- **Verified algorithms**: Proving factoring algorithm correctness requires a formal guarantee that composite inputs always have non-trivial divisors to find.
- **Pedagogical value**: The gap between the false universal claim and the correct composite-restricted claim illustrates the precision demanded by formal mathematics.
- **p-adic methods**: The framing via p-adic valuations connects to analytic number theory approaches to factoring (e.g., p-adic Newton polygons), even though the core existence result is elementary.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is *prime* if n ≥ 2 and its only divisors are 1 and n.
- A natural number n > 1 is *composite* if it is not prime, equivalently, if there exists d with 1 < d < n and d | n.

**Key Mathlib lemma:**
- `Nat.exists_dvd_of_not_prime2`: For n ≥ 2, if n is not prime, then there exists m such that m | n, 2 ≤ m, and m < n.

**Notation:** We write a | b for "a divides b" in ℕ. Given a | b, the quotient b / a is exact (no truncation).

## 4. PROOF OVERVIEW

**Strategy:** Given composite n > 1, we construct an explicit factorization n = k × (n/k) with both factors > 1.

1. **Obtain a non-trivial divisor.** Apply `Nat.exists_dvd_of_not_prime2` to the hypotheses n > 1 and ¬Prime(n) to get k with k | n, 2 ≤ k, and k < n.

2. **Form the complementary factor.** Set the two factors as a = k and b = n / k.

3. **Verify the product.** Since k | n, we have k × (n/k) = n by `Nat.mul_div_cancel'`.

4. **Verify a > 1.** From 2 ≤ k, immediately k > 1.

5. **Verify b > 1.** Since k < n and k | n, the quotient n/k must be at least 2. This follows from `Nat.div_mul_cancel` and linear arithmetic.

**Key insight:** The proof is constructive in the sense that it identifies the minimal factor (or any factor) as the witness, though the existential is non-constructive in its Lean formalization via Classical.choice.

## 5. NOVELTY ANALYSIS

- **Falsification of the original claim:** The most novel contribution is identifying that the proposed theorem (factoring all n > 1) is false and providing the precise corrected statement.
- **Machine verification:** While the mathematical content is elementary, the formal verification in Lean 4 with Mathlib provides a level of certainty unattainable by informal proof.
- **p-adic framing:** Although the corrected proof does not require p-adic methods, the original problem's framing via Newton polygons over ℚ_p suggests deeper connections between non-Archimedean analysis and factoring — connections that remain largely unexplored in formal mathematics.

## 6. OPEN PROBLEMS

1. **Constructive factoring bounds:** Can one formalize in Lean a *constructive* version that computes a non-trivial factor in polynomial time (assuming appropriate computational models), connecting to the complexity of factoring?

2. **p-adic Newton polygon formalization:** Can Hensel's lemma and p-adic Newton polygons be formalized in Mathlib to provide an alternative, analytic proof of the existence of factors via polynomial root-lifting?

3. **Unique factorization formalization:** Extend this result to a full formal proof of the Fundamental Theorem of Arithmetic (unique prime factorization) using only Mathlib primitives, and verify its equivalence with the formalization in `Nat.Factorization`.

## 7. REFERENCES

1. Hardy, G. H., & Wright, E. M. (2008). *An Introduction to the Theory of Numbers* (6th ed.). Oxford University Press.

2. The Mathlib Community. (2024). *Mathlib4: Mathematics in Lean 4*. https://github.com/leanprover-community/mathlib4

3. Neukirch, J. (1999). *Algebraic Number Theory*. Springer. (For p-adic valuation theory and Hensel's lemma.)

4. de Moura, L., & Ullrich, S. (2021). The Lean 4 Theorem Prover and Programming Language. *CADE-28*, Lecture Notes in Computer Science, vol 12699.

5. Gouvêa, F. Q. (1997). *p-adic Numbers: An Introduction* (2nd ed.). Springer. (For Newton polygons and p-adic factoring.)
