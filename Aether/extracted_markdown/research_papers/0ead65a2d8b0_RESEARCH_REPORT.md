# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate the formalization of a "factoring oracle" theorem inspired by p-adic number theory. The original conjecture — that every integer n > 1 admits a non-trivial factorization — is false, as prime numbers provide immediate counterexamples. We provide a machine-verified proof (in Lean 4 with Mathlib) of the corrected statement: every composite integer n > 1 can be decomposed as a product a · b where both a > 1 and b > 1. We additionally formalize a counterexample (n = 2) demonstrating the falsity of the original claim. The proof leverages `Nat.exists_dvd_of_not_prime2` from Mathlib, which extracts a non-trivial divisor from the compositeness hypothesis. While the corrected result is elementary, the exercise illuminates the gap between heuristic p-adic intuitions about factoring and rigorous formalization.

## 2. MOTIVATION

Integer factorization sits at the intersection of computational number theory and cryptography. RSA encryption rests on the computational hardness of factoring large semiprimes. Any mathematical "oracle" that could factor arbitrary integers would break RSA. Understanding the precise logical content of factoring statements — distinguishing what is provably true from what is merely conjectured — is essential for:

- **Cryptographic security**: Formally verified bounds on what factoring guarantees are possible.
- **Algorithm correctness**: Ensuring that factoring algorithms have correct specifications.
- **Formal methods in security**: Machine-checked proofs that factoring oracles satisfy their contracts.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n > 1 is *prime* if its only divisors are 1 and n itself.
- A natural number n > 1 is *composite* if it is not prime, equivalently, if there exists a divisor d with 1 < d < n.
- A *non-trivial factorization* of n is a pair (a, b) with a > 1, b > 1, and a · b = n.

**Key Mathlib lemma:**
- `Nat.exists_dvd_of_not_prime2 : n > 1 → ¬ Nat.Prime n → ∃ k, k ∣ n ∧ 1 < k ∧ k < n`

This lemma extracts a non-trivial divisor from the compositeness hypothesis, which we then use to construct both factors.

## 4. PROOF OVERVIEW

**Corrected theorem:** Given n > 1 and ¬ Nat.Prime n, produce a, b > 1 with a · b = n.

**Strategy:**
1. Apply `Nat.exists_dvd_of_not_prime2` to obtain k with k ∣ n, 1 < k, and k < n.
2. Set a = k and b = n / k.
3. Since k ∣ n, we have k · (n / k) = n by `Nat.mul_div_cancel'`.
4. We have a = k > 1 by hypothesis.
5. Since k < n and k > 0, we get n / k > 1 (if n / k = 1 then k = n, contradicting k < n).

**Counterexample (n = 2):** If a > 1 and b > 1, then a ≥ 2 and b ≥ 2, so a · b ≥ 4 > 2, contradiction.

## 5. NOVELTY ANALYSIS

The primary novelty lies not in the mathematics (which is elementary) but in the *formalization process*:

- **Detecting false conjectures**: The original statement, despite being inspired by sophisticated p-adic theory, was provably false. Formal verification caught this immediately.
- **Correcting specifications**: We demonstrate how to recover the intended mathematical content from an incorrect formalization.
- **Machine-verified counterexample**: The falsity of the original claim is itself formally proven, not just argued informally.

This illustrates a key benefit of formal methods: even "obvious" mathematical claims can be wrong, and mechanized proof assistants serve as an infallible sanity check.

## 6. OPEN PROBLEMS

1. **Certified factoring algorithms**: Can Pollard's rho or the quadratic sieve be formalized in Lean with machine-verified correctness and complexity bounds?

2. **P-adic factoring formalization**: The Newton polygon method for p-adic polynomials is well-understood mathematically. Can Hensel's lemma in Mathlib be applied to construct a formally verified p-adic factoring procedure for polynomials over ℚ_p?

3. **Computational hardness formalization**: Can the conjectured hardness of integer factorization be stated as a formal theorem about the non-existence of polynomial-time algorithms (relative to a suitable computational model formalized in Lean)?

## 7. REFERENCES

1. Neukirch, J. (1999). *Algebraic Number Theory*. Springer-Verlag.
2. Gouvêa, F. Q. (1997). *p-adic Numbers: An Introduction*. Springer.
3. The Mathlib Community. (2024). *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4
4. Crandall, R., & Pomerance, C. (2005). *Prime Numbers: A Computational Perspective*. Springer.
5. de Moura, L., & Ullrich, S. (2021). The Lean 4 Theorem Prover and Programming Language. *CADE-28*.
