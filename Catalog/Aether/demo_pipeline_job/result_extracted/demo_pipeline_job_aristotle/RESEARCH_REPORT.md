# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize in Lean 4 / Mathlib the fundamental theorem guaranteeing nontrivial factorization of composite integers. The original conjecture—that every integer greater than 1 admits a nontrivial splitting—is shown to be false (it fails for primes). We provide a corrected statement: every composite integer n > 1 can be written as n = a · b with a, b > 1. The proof proceeds by extracting the minimal factor of n via `Nat.exists_dvd_of_not_prime2`, which supplies a divisor k with 1 < k < n, and then reconstructing the complementary factor n/k. The formalization is fully machine-verified, uses only standard axioms (propext, Classical.choice, Quot.sound), and leverages Mathlib's number-theory infrastructure for divisibility and primality.

## 2. MOTIVATION

Integer factorization underpins modern public-key cryptography (RSA, Diffie–Hellman over ℤ/nℤ). While efficient classical factoring algorithms remain elusive—and the hardness of factoring is a foundational conjecture in computational complexity—the *existence* of nontrivial factors for composite numbers is a prerequisite that must be established before any algorithmic analysis. This formalization contributes to the growing library of machine-verified number theory, providing a certified foundation for reasoning about factoring in proof assistants. It also illustrates the subtlety of correctly stating theorems: the original (false) conjecture is a cautionary example of how informal mathematical reasoning can silently introduce errors that formal verification catches immediately.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is *prime* if n ≥ 2 and its only divisors are 1 and n.
- A natural number n > 1 is *composite* if it is not prime, equivalently if there exists k with 1 < k < n and k | n.

**Key Mathlib declarations used:**
- `Nat.exists_dvd_of_not_prime2 : n > 1 → ¬ Nat.Prime n → ∃ k, k ∣ n ∧ ...` — extracts a nontrivial divisor of a composite number.
- `Nat.mul_div_cancel'` — reconstructs n from a divisor and its cofactor.
- `Nat.one_lt_iff_ne_zero_and_ne_one` — characterization of integers > 1.

## 4. PROOF OVERVIEW

1. **Input:** n > 1 and ¬ Nat.Prime n.
2. **Extract divisor:** Apply `Nat.exists_dvd_of_not_prime2` to obtain k with k ∣ n and 1 < k < n.
3. **Construct witnesses:** Set a := k and b := n / k.
4. **Verify product:** By `Nat.mul_div_cancel'`, a * b = k * (n / k) = n.
5. **Verify bounds:** a = k > 1 by construction. For b = n / k > 1: since k < n and k > 1, the quotient n / k must also exceed 1 (verified via `nlinarith` using `Nat.div_mul_cancel`).

## 5. NOVELTY ANALYSIS

The primary novelty lies in the *correction* of a plausible but false conjecture and its machine-verified formalization:
- The original statement omitted the compositeness hypothesis, making it provably false for primes.
- The corrected theorem, while mathematically elementary, demonstrates the value of formal verification in catching subtle errors in theorem statements.
- The proof showcases effective use of Mathlib's `Nat.exists_dvd_of_not_prime2`, a lemma that directly provides the nontrivial divisor structure needed.

## 6. OPEN PROBLEMS

1. **Certified complexity bounds:** Can one formalize in Lean that trial division factors n in O(√n) steps, providing both a factor and a verified proof of correctness?

2. **Unique factorization formalization:** While Mathlib contains the fundamental theorem of arithmetic (`Nat.UniqueFactorizationMonoid`), can one formalize a constructive version that computes the complete prime factorization alongside a certificate?

3. **p-adic factoring algorithms:** Can Hensel's lemma over ℚ_p be formalized in Lean to certify p-adic lifting steps in algorithms such as the number field sieve, where p-adic analysis plays a genuine role?

## 7. REFERENCES

1. de Bruijn, N. G. "The mathematical language AUTOMATH, its usage, and some of its extensions." *Symposium on Automatic Demonstration*, Lecture Notes in Mathematics 125, Springer (1970).

2. The Mathlib Community. "Mathlib4: The Lean 4 Mathematical Library." https://leanprover-community.github.io/mathlib4_docs/

3. Hardy, G. H. and Wright, E. M. *An Introduction to the Theory of Numbers*, 6th ed. Oxford University Press (2008).

4. Avigad, J., de Moura, L., and Kong, S. "Theorem proving in Lean." Carnegie Mellon University (2024). https://lean-lang.org/theorem_proving_in_lean4/
