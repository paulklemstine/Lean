# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize in Lean 4 (Mathlib v4.28.0) the statement that every composite integer *n > 1* admits a non-trivial factorization *n = a · b* with *a > 1* and *b > 1*. The original conjecture, which omitted the compositeness hypothesis, is shown to be **false** — prime numbers are immediate counterexamples. Our corrected theorem retains the p-adic context parameter from the original formulation while providing a clean, machine-verified proof via Mathlib's `Nat.exists_dvd_of_not_prime2`. The proof extracts a non-trivial divisor guaranteed by the negation of primality and constructs the complementary factor by exact division. The result, though elementary in classical number theory, serves as a verified building block for future formalized work connecting p-adic analysis to computational number theory.

## 2. MOTIVATION

Integer factorization sits at the intersection of pure mathematics, computational complexity, and cryptographic security. While efficient factoring algorithms remain elusive (and the hardness of factoring underpins RSA and related cryptosystems), the *existence* of non-trivial factorizations for composite numbers is a foundational prerequisite for any factoring algorithm's correctness proof. Formalizing this existence result in a proof assistant provides:

- A verified foundation for formalizing more complex factoring algorithms (Pollard's ρ, quadratic sieve, number field sieve).
- A case study in handling false conjectures gracefully within formal verification workflows.
- A stepping stone toward formalizing connections between p-adic analysis (Newton polygons, Hensel lifting) and factorization.

## 3. MATHEMATICAL FRAMEWORK

**Definitions.** A natural number *n* is *prime* if *n ≥ 2* and its only divisors are 1 and *n*. A natural number *n > 1* is *composite* if it is not prime — equivalently, if there exists a divisor *d* with *1 < d < n*.

**Key Mathlib declarations used:**
- `Nat.Prime`: the predicate asserting primality.
- `Nat.exists_dvd_of_not_prime2`: for *n > 1* and *¬ Nat.Prime n*, produces a divisor *k* with *k ∣ n*, *k ≠ 1*, and *k ≠ n*.
- `Nat.div_mul_cancel`: for *k ∣ n*, asserts *n / k * k = n*.

**Notation.** We write ℕ for the natural numbers and ∣ for divisibility.

## 4. PROOF OVERVIEW

1. **Counterexample analysis.** The original statement `∀ n > 1, ∃ a b > 1, a · b = n` fails for any prime *n* (e.g., *n = 2*). We add the hypothesis `¬ Nat.Prime n`.

2. **Divisor extraction.** By `Nat.exists_dvd_of_not_prime2`, since *n > 1* and *n* is not prime, there exists *k* with *k ∣ n*, *1 < k*, and *k < n*.

3. **Factor construction.** Set *a = k* and *b = n / k*. Then:
   - *a · b = k · (n / k) = n* by `Nat.div_mul_cancel`.
   - *a > 1* directly from the extracted bound on *k*.
   - *b > 1* because *k < n* implies *n / k ≥ 2* (verified by `nlinarith`).

The proof is three lines of tactic-mode Lean.

## 5. NOVELTY ANALYSIS

The mathematical content is classical, but the contribution lies in:

- **Falsification and correction.** Demonstrating, within a formal verification pipeline, that the original conjecture is false and providing a minimal corrective hypothesis. This workflow — attempted proof → counterexample discovery → hypothesis strengthening — is a model for robust automated theorem generation.
- **Minimality.** The proof uses exactly one non-trivial Mathlib lemma (`Nat.exists_dvd_of_not_prime2`), keeping the trusted base small.
- **Parametric generality.** Retaining the unused p-adic parameter `{p : ℕ} [Fact p.Prime]` documents the intended (but ultimately unnecessary) mathematical context, preserving traceability to the original research question.

## 6. OPEN PROBLEMS

1. **Formalize p-adic factoring algorithms.** Can Hensel's lemma in ℚ_p be used to construct *efficient* factoring procedures, and can their correctness be formalized in Lean with verified complexity bounds?

2. **Newton polygon certificates.** Given a polynomial *f ∈ ℤ[x]* with *f(0) = n*, can the Newton polygon of *f* over ℚ_p certify a non-trivial factorization of *n*? Formalizing this would connect p-adic geometry to computational number theory.

3. **Compositeness witnesses.** The current proof is non-constructive (it uses `Classical.choice`). Can a constructive version be given that produces an explicit divisor, perhaps via trial division or a Miller–Rabin-style witness?

## 7. REFERENCES

1. Neukirch, J. *Algebraic Number Theory*. Springer, 1999. (p-adic valuations and Hensel's lemma)
2. Gouvêa, F. Q. *p-adic Numbers: An Introduction*. 2nd ed., Springer, 1997.
3. The Mathlib Community. *Mathlib4: Mathematics in Lean 4*. https://github.com/leanprover-community/mathlib4
4. Crandall, R. and Pomerance, C. *Prime Numbers: A Computational Perspective*. 2nd ed., Springer, 2005. (Factoring algorithms and compositeness tests)
5. Cassels, J. W. S. *Local Fields*. Cambridge University Press, 1986.
