# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize and prove a theorem asserting that every composite natural number n > 1 admits a non-trivial factorization into two factors both strictly greater than 1. The original conjecture—that *every* n > 1 factors non-trivially—is false (primes are counterexamples), and we document this correction. The proof leverages Mathlib's `Nat.exists_dvd_of_not_prime2`, which extracts a divisor d with 1 < d < n from the hypothesis that n is composite. From d we recover the complementary factor n/d, verifying both exceed 1. While elementary in isolation, this result anchors a broader program connecting p-adic analysis (Hensel lifting, Newton polygons) to integer factorization, serving as the foundational "oracle guarantee" that composite inputs always yield non-trivial splits.

## 2. MOTIVATION

Integer factorization underpins the security of RSA and other public-key cryptosystems. A formal, machine-verified guarantee that composite numbers *can* always be split is a prerequisite for reasoning about factoring algorithms in a proof assistant. Moreover, the p-adic framing motivates future formalization of Hensel's lemma–based lifting strategies (used in the number field sieve and p-adic methods for polynomial root-finding), bridging algebraic number theory and computational algebra within Lean/Mathlib.

## 3. MATHEMATICAL FRAMEWORK

**Definitions.** A natural number n is *prime* if n ≥ 2 and its only divisors are 1 and n. It is *composite* if n > 1 and ¬Prime(n).

**Key Mathlib lemma.** `Nat.exists_dvd_of_not_prime2 : n > 1 → ¬ Nat.Prime n → ∃ k, k ∣ n ∧ 1 < k ∧ k < n` provides a witness divisor k.

**Notation.** Given k ∣ n, the complementary factor is n / k (exact natural division).

## 4. PROOF OVERVIEW

1. From `hn : n > 1` and `hc : ¬ Nat.Prime n`, invoke `Nat.exists_dvd_of_not_prime2` to obtain k with `k ∣ n`, `1 < k`, and `k < n`.
2. Set a := k and b := n / k.
3. Verify a * b = n via `Nat.mul_div_cancel'`.
4. Verify a > 1 (directly from `1 < k`).
5. Verify b > 1: since k < n and k ∣ n, we have n / k ≥ 2, established by `nlinarith` using `Nat.div_mul_cancel`.

## 5. NOVELTY ANALYSIS

The novelty lies not in the mathematical content (which is elementary) but in:
- **Correction of the original false statement**: Identifying that the universally quantified claim fails for primes, and providing the minimal corrective hypothesis.
- **Machine-verified formalization**: A complete, sorry-free Lean 4 proof using only standard axioms (propext, Classical.choice, Quot.sound).
- **Anchoring a p-adic program**: The theorem serves as the formal starting point for a broader effort to mechanize p-adic factoring methods.

## 6. OPEN PROBLEMS

1. **Formalize Hensel's lemma for ℤ_p and apply it to construct explicit factoring lifts.** Can one mechanize the p-adic Newton polygon algorithm in Lean and prove its correctness?

2. **Complexity-theoretic formalization.** Can one state and prove in Lean that no polynomial-time algorithm is known for integer factorization (relative to standard complexity assumptions)?

3. **Certified factoring algorithms.** Formalize the correctness of trial division, Pollard's rho, or the quadratic sieve in Lean, producing verified factor certificates for arbitrary composites.

## 7. REFERENCES

1. Gouvêa, F. Q. *p-adic Numbers: An Introduction*. Springer Universitext, 2nd ed., 1997.
2. The Mathlib Community. *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4, 2024.
3. Crandall, R. and Pomerance, C. *Prime Numbers: A Computational Perspective*. Springer, 2nd ed., 2005.
4. Neukirch, J. *Algebraic Number Theory*. Grundlehren der mathematischen Wissenschaften, Vol. 322, Springer, 1999.
