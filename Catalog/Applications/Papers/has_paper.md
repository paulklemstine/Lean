# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize in Lean 4 (Mathlib v4.28.0) a theorem establishing that every composite natural number admits a non-trivial factorization. The original conjecture—that every integer n > 1 factors as a product of two integers both exceeding 1—is shown to be **false** for prime inputs. We provide a corrected statement adding the hypothesis that n is not prime, and give a complete, machine-verified proof using Mathlib's `Nat.exists_dvd_of_not_prime2`, which constructs a divisor d with 1 < d < n for any composite n > 1. The factorization n = d × (n/d) then satisfies all required bounds. While elementary, this result illustrates how formal verification catches subtle errors in mathematical claims that may appear plausible at first glance.

## 2. MOTIVATION

Integer factorization lies at the heart of computational number theory and cryptographic security. RSA encryption, for instance, relies on the computational difficulty of factoring large semiprimes. Formally verifying that composite numbers admit non-trivial factorizations—and equally importantly, that primes do not—provides foundational guarantees for cryptographic proof frameworks. This work also demonstrates the power of interactive theorem provers to catch false mathematical statements before they propagate into security-critical systems.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is **prime** if n ≥ 2 and its only divisors are 1 and n.
- A natural number n > 1 is **composite** if it is not prime, equivalently if there exists d with 1 < d < n and d | n.
- The **minimal factor** `Nat.minFac n` is the smallest prime divisor of n.

**Key Mathlib Lemma:**
- `Nat.exists_dvd_of_not_prime2 : n > 1 → ¬ Nat.Prime n → ∃ k, k ∣ n ∧ 1 < k ∧ k < n`

This lemma directly witnesses a non-trivial divisor for any composite number.

## 4. PROOF OVERVIEW

1. **Input:** n > 1, ¬ Nat.Prime n.
2. **Step 1:** Apply `Nat.exists_dvd_of_not_prime2` to obtain a divisor k with k | n, 1 < k, and k < n.
3. **Step 2:** Construct the factorization: set a = k and b = n / k.
4. **Step 3:** Verify a * b = n using `Nat.div_mul_cancel` (since k | n).
5. **Step 4:** Verify a > 1 (immediate from 1 < k) and b > 1 (since k < n and k | n imply n/k > 1, established via `nlinarith`).

The proof is a single tactic line leveraging Mathlib's number-theoretic infrastructure.

## 5. NOVELTY ANALYSIS

The primary novelty is **negative**: the original claim (without the compositeness hypothesis) is false, and our formalization catches this error. This exemplifies a common pattern in mathematical research where plausible-sounding universal statements fail at boundary cases (here, primes). The formal verification provides an unimpeachable certificate that the corrected statement holds.

The proof itself, while elementary, demonstrates clean integration of Mathlib's `Nat` divisibility API with the `nlinarith` tactic for bound verification.

## 6. OPEN PROBLEMS

1. **Efficient Witness Extraction:** Can Lean's computation kernel efficiently extract the actual factors for specific large composite numbers, or is `Nat.exists_dvd_of_not_prime2` computationally intractable for practical inputs?

2. **p-Adic Factoring Formalization:** Can Hensel's lemma in Mathlib's `Padic` library be used to construct a certified p-adic factoring algorithm, formalizing the Newton polygon approach to finding roots of polynomials over ℚₚ?

3. **Unique Factorization Certificate:** Can the proof be extended to produce the full prime factorization of n with a formal uniqueness certificate (i.e., a constructive proof of the Fundamental Theorem of Arithmetic with explicit factor extraction)?

## 7. REFERENCES

1. The Mathlib Community. *Mathlib4: The Lean 4 Mathematics Library.* https://github.com/leanprover-community/mathlib4, 2024.

2. Avigad, J., de Moura, L., and Kong, S. "Theorem Proving in Lean 4." *Microsoft Research*, 2024.

3. Crandall, R. and Pomerance, C. *Prime Numbers: A Computational Perspective.* 2nd edition, Springer, 2005.

4. Hardy, G. H. and Wright, E. M. *An Introduction to the Theory of Numbers.* 6th edition, Oxford University Press, 2008.
