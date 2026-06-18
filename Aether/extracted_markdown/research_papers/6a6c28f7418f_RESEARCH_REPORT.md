# Non-Archimedean Factoring Oracle: A Formal Correction and Proof

## 1. ABSTRACT

We examine a proposed "p-adic factoring oracle" that claims every integer n > 1 factors non-trivially as a product a · b with a, b > 1. We show this statement is **false** — prime numbers provide immediate counterexamples. We then formalize two corrected variants in Lean 4 with Mathlib: (1) every n > 1 is either prime or admits a non-trivial factorization, and (2) every composite n admits such a factorization. The proofs use Mathlib's `Nat.exists_dvd_of_not_prime2`, which provides a divisor in the interval (1, n) for composite numbers, combined with the division algorithm. Both proofs are machine-verified and use only standard axioms (propext, Classical.choice, Quot.sound).

## 2. MOTIVATION

Integer factorization is a cornerstone of computational number theory and modern cryptography. The security of RSA and related cryptosystems rests on the computational hardness of factoring large semiprimes. While efficient quantum algorithms (Shor's algorithm) threaten this assumption, the classical complexity of factoring remains open. Formalizing the *existence* of factorizations — as opposed to their efficient *computation* — provides a foundation for verified cryptographic reasoning. Machine-checked proofs ensure that security reductions and protocol analyses rest on solid mathematical ground.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n > 1 is **prime** if its only divisors are 1 and n itself.
- A natural number n > 1 is **composite** if it is not prime, equivalently, if there exists a divisor d with 1 < d < n.
- A **non-trivial factorization** of n is a pair (a, b) with a, b > 1 and a · b = n.

**Key Mathlib lemma:**
```
Nat.exists_dvd_of_not_prime2 : n > 1 → ¬ Nat.Prime n → ∃ d, d ∣ n ∧ 1 < d ∧ d < n
```
This provides a witness divisor for composite numbers in the interval (1, n).

## 4. PROOF OVERVIEW

**Corrected Theorem 1** (prime-or-factor dichotomy):
- Case split on `Nat.Prime n` using classical decidability.
- If prime, take the left disjunct.
- If composite, apply `Nat.exists_dvd_of_not_prime2` to get a divisor d with 1 < d < n and d ∣ n.
- Set a = d, b = n/d. Then a · b = n by the division lemma, a > 1 by hypothesis, and b > 1 since d < n implies n/d > 1.

**Corrected Theorem 2** (composite factorization):
- Identical to the composite branch of Theorem 1, using the hypothesis ¬ Nat.Prime n directly.

## 5. NOVELTY ANALYSIS

The primary contribution is **negative**: we identify that the originally proposed "p-adic factoring oracle" theorem is false as stated. The p-adic parameter p plays no role in the corrected statements — the result is purely about natural number arithmetic. This illustrates a common pitfall in speculative formalization: conflating the *existence* of factorizations (which is elementary) with the *computational complexity* of finding them (which is genuinely deep). The formal verification in Lean 4 provides certainty that the corrected statements are true and the original is not.

## 6. OPEN PROBLEMS

1. **Efficient witness extraction**: Can the proof be made constructive in a way that extracts an efficient factoring algorithm? The current proof uses `Nat.minFac` (trial division), which is exponential-time. Formalizing a polynomial-time factoring algorithm (conditional on quantum computation) remains open in Lean.

2. **p-Adic factoring theory**: Can Hensel's lemma and Newton polygons over Q_p be used to formalize a genuine *computational* relationship between p-adic analysis and integer factoring? The Hasse-Minkowski theorem and p-adic methods in algebraic number theory suggest this direction.

3. **Complexity-theoretic formalization**: Can the statement "integer factoring is not in P" (assuming standard conjectures) be formalized in Lean? This would require formalizing complexity classes and oracle Turing machines.

## 7. REFERENCES

1. Hardy, G. H., & Wright, E. M. (2008). *An Introduction to the Theory of Numbers* (6th ed.). Oxford University Press.

2. Gouvêa, F. Q. (1997). *p-adic Numbers: An Introduction* (2nd ed.). Springer.

3. The Mathlib Community. (2024). *Mathlib4: Mathematics in Lean 4*. https://leanprover-community.github.io/mathlib4_docs/

4. Shor, P. W. (1997). Polynomial-time algorithms for prime factorization and discrete logarithms on a quantum computer. *SIAM Journal on Computing*, 26(5), 1484–1509.
