# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate a theorem inspired by the idea of using p-adic analysis to factor composite integers. The original conjecture — that every integer n > 1 admits a non-trivial factorization — is shown to be **false**, since prime numbers are, by definition, irreducible. We provide a corrected and formally verified statement: every composite integer n > 1 (i.e., n > 1 and ¬ n.Prime) can be written as a product a · b with both a > 1 and b > 1. The proof is mechanically verified in Lean 4 using Mathlib's `Nat.exists_dvd_of_not_prime2`, which extracts a non-trivial divisor from the negation of primality. While the final result is elementary, the exercise highlights the critical role of precise hypotheses when bridging analytic number theory intuitions (Newton polygons, Hensel lifting) with rigorous formal verification.

## 2. MOTIVATION

Integer factorization is central to computational number theory and modern cryptography (RSA, Diffie–Hellman over ℤ/nℤ). The idea of a "factoring oracle" — a black-box that decomposes any composite number — is a fundamental abstraction in complexity theory. While p-adic methods (Hensel's lemma, Newton polygons over ℚ_p) play a genuine role in polynomial factorization algorithms (e.g., the Zassenhaus algorithm), any claim that they provide unconditional integer factoring must be stated carefully. This work demonstrates the value of formal verification: the original statement, plausible-sounding in informal mathematics, is immediately caught as false by the Lean type-checker, forcing a precise correction.

## 3. MATHEMATICAL FRAMEWORK

**Definitions and notation:**

- **ℕ**: the natural numbers {0, 1, 2, …}.
- **Nat.Prime n**: n ≥ 2 and the only divisors of n are 1 and n itself.
- **Composite**: n > 1 and ¬ Nat.Prime n, equivalently ∃ a b > 1, a · b = n.
- **p-adic valuation** v_p(n): the exponent of p in the prime factorization of n.
- **Hensel's lemma**: if f(x) ≡ 0 (mod p) has a simple root, it lifts to ℤ_p.

**Key Mathlib declarations used:**

- `Nat.exists_dvd_of_not_prime2 : n > 1 → ¬ n.Prime → ∃ k, k ∣ n ∧ 1 < k ∧ k < n`
- `Nat.mul_div_cancel' : k ∣ n → k * (n / k) = n`

## 4. PROOF OVERVIEW

1. **Input**: n > 1, ¬ n.Prime.
2. **Extract a non-trivial divisor**: By `Nat.exists_dvd_of_not_prime2`, obtain k with k ∣ n, 1 < k, and k < n.
3. **Construct the cofactor**: Set a = k, b = n / k. Since k ∣ n, we have a * b = n.
4. **Verify bounds**: a > 1 is immediate (1 < k). For b > 1: since k < n and k ∣ n, the quotient n / k ≥ 2.

The proof is a single tactic line using `rcases` to destructure the existential and then assembling the witness.

## 5. NOVELTY ANALYSIS

The primary novelty is **negative**: the original conjecture (that every n > 1 factors non-trivially) is false, and the formal verification system immediately detects this. This illustrates:

- **Formal verification as a research tool**: catching false conjectures before they propagate.
- **The gap between analytic intuition and discrete reality**: p-adic methods genuinely help with polynomial factoring but do not magically factor primes.
- **Precise hypothesis engineering**: the single additional hypothesis ¬ n.Prime transforms a false statement into a true (and useful) one.

## 6. OPEN PROBLEMS

1. **Efficient witness extraction**: Can Hensel lifting over ℚ_p be formalized in Lean to provide a *computationally efficient* factoring algorithm for specific families of composites (e.g., n = p · q with p, q of known size)?

2. **Newton polygon formalization**: Mathlib lacks a complete theory of Newton polygons for polynomials over valued fields. Formalizing this would connect p-adic analysis to factoring algorithms (Zassenhaus, LLL).

3. **Complexity-theoretic oracle separation**: Can the statement "a factoring oracle exists" be formalized in a way that distinguishes P ≠ NP from the unconditional existence of the factorization itself? What is the Lean formalization of oracle Turing machines?

## 7. REFERENCES

1. Neukirch, J. *Algebraic Number Theory*. Springer, 1999. (Standard reference for p-adic fields and Hensel's lemma.)
2. von zur Gathen, J. and Gerhard, J. *Modern Computer Algebra*, 3rd ed. Cambridge University Press, 2013. (Polynomial factoring via Hensel lifting.)
3. The Mathlib Community. *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4, 2024.
4. Lenstra, A.K. and Lenstra, H.W., Jr., eds. *The Development of the Number Field Sieve*. Lecture Notes in Mathematics 1554, Springer, 1993.
