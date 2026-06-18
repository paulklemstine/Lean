# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate a theorem inspired by the idea of using p-adic analysis to factor integers. The original conjecture — that every integer n > 1 admits a non-trivial factorization — is false, as it fails for primes. We formalize a corrected version: every composite integer n > 1 (i.e., n > 1 and ¬ Prime n) can be written as a product a · b with a > 1 and b > 1. The proof exploits the minimal factor function `Nat.minFac` and divisibility arithmetic in Lean 4 / Mathlib. While the corrected statement is elementary, the investigation highlights an important tension between the suggestive power of p-adic methods in number theory and the need for rigorous formalization to catch hidden assumptions.

## 2. MOTIVATION

Integer factorization is central to computational number theory and underpins the security of RSA and related cryptographic protocols. The idea of a "factoring oracle" — a black-box that decomposes integers — connects to deep questions about computational complexity (e.g., whether factoring is in P). P-adic methods, including Hensel's lemma and Newton polygons, are powerful tools in algebraic number theory. While they do not directly yield efficient factoring algorithms, exploring their connection to factorization reveals structural insights about how primes and composites differ.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n > 1 is *prime* if its only divisors are 1 and n.
- A natural number n > 1 is *composite* if it is not prime, equivalently if there exists d with 1 < d < n and d | n.
- `Nat.minFac n` returns the smallest factor of n greater than 1.

**Key Lemma (Nat.exists_dvd_of_not_prime2):** If n > 1 and n is not prime, then there exists k with k | n and 2 ≤ k ≤ n/k (hence both k > 1 and n/k > 1).

## 4. PROOF OVERVIEW

1. **Hypothesis:** We are given n > 1 and ¬ Nat.Prime n.
2. **Factor extraction:** By `Nat.exists_dvd_of_not_prime2`, there exists k such that k | n and 2 ≤ k ≤ n/k.
3. **Witnesses:** Set a = k and b = n/k. Then a * b = n by `Nat.mul_div_cancel'`.
4. **Bounds:** From 2 ≤ k we get a > 1. From k ≤ n/k and k ≥ 2 we get b ≥ k ≥ 2, so b > 1.

The proof is a single tactic line using `obtain`, `exact`, and `nlinarith`.

## 5. NOVELTY ANALYSIS

The original statement (without the compositeness hypothesis) represents a common pitfall in automated conjecture generation: conflating "most integers can be factored non-trivially" with "all integers can." The formal verification in Lean catches this error immediately. The corrected theorem, while elementary, demonstrates:
- The power of interactive theorem provers to catch false conjectures before they propagate.
- The clean interface Mathlib provides for elementary number theory.
- How p-adic intuition (every p-adic integer has a valuation decomposition) does not directly translate to a universal factoring statement.

## 6. OPEN PROBLEMS

1. **Efficient witnesses:** Can Hensel's lemma in Qₚ be used to construct polynomial-time factoring algorithms for integers with known structure (e.g., Carmichael numbers)?
2. **Newton polygon factoring:** Given a polynomial f(x) ∈ ℤ[x] whose Newton polygon over Qₚ has multiple slopes, can the resulting factorization of f in Qₚ[x] be lifted to a factorization over ℤ[x]? Under what conditions?
3. **Formalized complexity:** Can the computational complexity of integer factoring be stated and studied within Lean/Mathlib, connecting existence proofs like this one to algorithmic bounds?

## 7. REFERENCES

1. Gouvêa, F. Q. *p-adic Numbers: An Introduction*. Springer, Universitext, 2nd ed., 1997.
2. Cohen, H. *A Course in Computational Algebraic Number Theory*. Springer, Graduate Texts in Mathematics 138, 1993.
3. The Mathlib Community. *Mathlib: The Lean Mathematical Library*. https://leanprover-community.github.io/mathlib4_docs/
4. Neukirch, J. *Algebraic Number Theory*. Springer, Grundlehren der mathematischen Wissenschaften 322, 1999.
