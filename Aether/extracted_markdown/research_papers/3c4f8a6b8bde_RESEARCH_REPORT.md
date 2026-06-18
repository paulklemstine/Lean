# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize a "factoring oracle" theorem in Lean 4 with Mathlib, originally framed in the language of p-adic analysis. The intended statement — that every integer n > 1 admits a non-trivial factorization — is **false** as stated, since prime numbers are counterexamples. We identify this error, provide a concrete counterexample (n = 2), and prove a corrected version: every composite integer n > 1 (i.e., n > 1 and ¬ Nat.Prime n) admits a factorization n = a · b with a, b > 1. We additionally prove a classification theorem: every n > 1 is either prime or admits such a non-trivial factorization. The proofs leverage Mathlib's `Nat.exists_dvd_of_not_prime2` and basic divisibility arithmetic, demonstrating how formal verification catches subtle but critical errors in mathematical claims.

## 2. MOTIVATION

Integer factorization is foundational to computational number theory and modern cryptography. RSA encryption, for instance, relies on the computational hardness of factoring large semiprimes. While the *existence* of non-trivial factors for composite numbers is elementary, formally verifying such statements matters because:

- **Cryptographic correctness:** Security proofs in cryptography depend on precise statements about factorization. A misstatement (e.g., claiming all n > 1 factor non-trivially) could invalidate a security argument.
- **Proof engineering:** This example illustrates the value of formal verification: the original statement looked plausible but was false. Machine-checked proofs prevent such errors from propagating.
- **Foundation for p-adic methods:** While the corrected theorem is elementary, it serves as a building block for more sophisticated p-adic factoring algorithms (e.g., Hensel lifting).

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is *prime* if n ≥ 2 and its only divisors are 1 and n.
- A natural number n > 1 is *composite* if it is not prime, equivalently, if there exists a divisor d of n with 1 < d < n.
- A *non-trivial factorization* of n is a pair (a, b) with a · b = n and a, b > 1.

**Key Mathlib declarations used:**
- `Nat.exists_dvd_of_not_prime2`: For n > 1 with ¬ Nat.Prime n, there exists k with k ∣ n, 1 < k, and k < n.
- `Nat.mul_div_cancel'`: If k ∣ n, then k * (n / k) = n.
- `Nat.div_mul_cancel`: If k ∣ n, then n / k * k = n.

## 4. PROOF OVERVIEW

**Main Theorem (corrected):** For composite n > 1, ∃ a b > 1, a · b = n.

*Strategy:*
1. Since n > 1 and ¬ Nat.Prime n, apply `Nat.exists_dvd_of_not_prime2` to obtain a divisor k with k ∣ n, 1 < k < n.
2. Set a = k, b = n / k. Then a · b = n by `Nat.mul_div_cancel'`.
3. We have a > 1 directly. For b > 1, use the bound k < n together with divisibility to conclude n / k > 1.

**Classification Theorem:** Every n > 1 is prime or composite.

*Strategy:* By classical logic (`Classical.or_iff_not_imp_left`), either n is prime (left disjunct) or not, in which case apply the main theorem.

## 5. NOVELTY ANALYSIS

The primary novelty is **negative**: we identified that the originally proposed "p-adic factoring oracle" theorem is false and provided a machine-verified correction. This illustrates:

- The importance of formal verification in catching errors that informal reasoning might overlook.
- That the p-adic framing (the `{p : ℕ} [Fact p.Prime]` parameter) is a red herring — the corrected theorem is purely about natural number arithmetic.
- A clean decomposition into a factoring theorem and a classification theorem.

## 6. OPEN PROBLEMS

1. **Effective p-adic factoring:** Can Hensel's lemma in Qₚ be formally used to construct an algorithm that, given a polynomial f(x) ≡ 0 (mod p) with a simple root, lifts this to a factorization of a related integer? Formalizing this in Lean would connect the p-adic framing to actual factoring.

2. **Complexity bounds:** The existence proof gives no information about the *size* of the factors. Can one formalize the statement that the smallest non-trivial factor of n is at most √n?

3. **Unique factorization:** Extend this to a formal proof that every n > 1 admits a *unique* factorization into primes (the Fundamental Theorem of Arithmetic is in Mathlib, but connecting it to this factoring oracle form would be instructive).

## 7. REFERENCES

- de Bruijn, N.G. "The Mathematical Language AUTOMATH." *Symposium on Automatic Demonstration*, Lecture Notes in Mathematics 125, Springer, 1970.
- The Mathlib Community. *Mathlib4: The Lean 4 Mathematical Library.* https://github.com/leanprover-community/mathlib4
- Gouvêa, F.Q. *p-adic Numbers: An Introduction.* Universitext, Springer, 1997.
- Crandall, R. and Pomerance, C. *Prime Numbers: A Computational Perspective.* 2nd ed., Springer, 2005.
