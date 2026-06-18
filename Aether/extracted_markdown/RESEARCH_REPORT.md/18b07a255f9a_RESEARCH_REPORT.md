# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize in Lean 4 (Mathlib v4.28.0) a theorem establishing that every composite natural number admits a nontrivial factorization. The original conjecture—that every integer n > 1 factors as a product of two integers each exceeding 1—is shown to be false, since prime numbers constitute immediate counterexamples. We provide a corrected statement adding the hypothesis of compositeness (¬ Nat.Prime n) and prove it using Mathlib's `Nat.exists_dvd_of_not_prime2`, which extracts a nontrivial divisor from the compositeness condition. The proof is concise, purely number-theoretic, and verified by the Lean kernel with only standard axioms (propext, Classical.choice, Quot.sound). While the mathematical content is elementary, the formalization exercise highlights the gap between informal "factoring oracle" intuitions and rigorous provability.

## 2. MOTIVATION

Integer factorization lies at the heart of computational number theory and modern cryptography. RSA encryption, for instance, relies on the computational difficulty of factoring large semiprimes. While the *existence* of factors for composite numbers is trivial mathematically, formalizing this in a proof assistant ensures:

- **Correctness of specifications**: Cryptographic libraries can link formal guarantees to implementation.
- **Foundation for complexity theory**: A formally verified factoring existence theorem is a prerequisite for formalizing NP-hardness results about factoring.
- **Pedagogical value**: The counterexample to the original (false) statement illustrates why formal verification catches errors that informal reasoning overlooks.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is *prime* (`Nat.Prime n`) if n ≥ 2 and its only divisors are 1 and n.
- A natural number n > 1 is *composite* if it is not prime, i.e., ¬ Nat.Prime n ∧ n > 1.

**Key Mathlib lemma:**
- `Nat.exists_dvd_of_not_prime2 : n > 1 → ¬ Nat.Prime n → ∃ k, k ∣ n ∧ 1 < k ∧ k < n`

This lemma extracts a nontrivial divisor k from the compositeness of n. Given k, the complementary factor n/k is also nontrivial.

**Notation:** We write a ∣ b for divisibility, and n / k for natural number (truncated) division.

## 4. PROOF OVERVIEW

1. **Apply** `Nat.exists_dvd_of_not_prime2` with hypotheses `hn : n > 1` and `hc : ¬ Nat.Prime n` to obtain a divisor k with `k ∣ n`, `1 < k`, and `k < n`.
2. **Construct witnesses**: Set a := k and b := n / k.
3. **Verify a * b = n**: By `Nat.mul_div_cancel'`, since k ∣ n, we have k * (n / k) = n.
4. **Verify a > 1**: Directly from `1 < k`.
5. **Verify b > 1**: Since k < n and k ∣ n, the quotient n / k must exceed 1. This follows by `nlinarith` from `Nat.div_mul_cancel` and the bounds.

The entire proof is a single tactic invocation after the existential elimination.

## 5. NOVELTY ANALYSIS

The primary novelty is *negative*: we demonstrate that the originally proposed theorem (every n > 1 has a nontrivial factorization) is **false** and provide a minimal correction. This is a cautionary example for automated conjecture generation—the statement sounds plausible in the context of "p-adic factoring oracles" but fails for the simplest inputs (primes).

The corrected proof, while mathematically elementary, showcases the power of Lean 4 and Mathlib's number theory library: a one-line proof term suffices for a statement that requires careful reasoning about divisibility, bounds, and natural number division.

## 6. OPEN PROBLEMS

1. **Formal complexity of factoring**: Can we formalize the statement that integer factoring is not known to be in P, or prove conditional hardness results (e.g., under the assumption that RSA is hard)?

2. **Constructive factoring**: The current proof uses classical logic (`Classical.choice`). Can we give a fully constructive proof that computes the factors, e.g., via trial division, and verify its correctness?

3. **p-Adic factoring algorithms**: Can Hensel's lemma in Mathlib be used to formalize the p-adic lifting step in algorithms like the number field sieve, providing verified bounds on lift convergence?

## 7. REFERENCES

1. Ireland, K. and Rosen, M. *A Classical Introduction to Modern Number Theory*. Springer, 1990.
2. The Mathlib Community. *Mathlib4: Mathematics in Lean 4*. https://leanprover-community.github.io/mathlib4_docs/
3. Crandall, R. and Pomerance, C. *Prime Numbers: A Computational Perspective*. Springer, 2nd edition, 2005.
4. de Moura, L. and Ullrich, S. "The Lean 4 Theorem Prover and Programming Language." *CADE-28*, 2021.
