# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We formalize the fundamental dichotomy for natural numbers: every integer greater than 1 is either prime or admits a non-trivial factorization into two factors, each exceeding 1. The original conjecture — that *every* n > 1 factors non-trivially over the p-adic integers — is refuted by any prime counterexample. We provide a machine-verified Lean 4 proof of the corrected composite-case theorem and the prime-or-composite dichotomy, leveraging Mathlib's `Nat.exists_dvd_of_not_prime2` and the minimal factor machinery. While elementary, this result serves as a foundational building block for more sophisticated p-adic approaches to integer factorization, and its formalization highlights the value of proof assistants in catching subtle logical errors in mathematical conjectures.

## 2. MOTIVATION

Integer factorization underpins the security of RSA and related cryptographic protocols. Any "factoring oracle" — a procedure that decomposes integers into non-trivial factors — would have profound consequences for computational number theory and cryptography. Understanding the precise logical boundary between primality and compositeness is essential before deploying more advanced analytic machinery (p-adic methods, Newton polygons, Hensel lifting). This formalization ensures that the foundational claim is stated correctly and proved rigorously, preventing downstream errors in more complex p-adic factoring algorithms.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n > 1 is *prime* if its only divisors are 1 and n.
- A *non-trivial factorization* of n is a pair (a, b) with a > 1, b > 1, and a · b = n.
- The *minimal factor* `minFac(n)` is the smallest prime dividing n.

**Key Mathlib ingredients:**
- `Nat.exists_dvd_of_not_prime2`: if n > 1 and n is not prime, then n has a divisor a with 2 ≤ a and a² ≤ n.
- `Nat.mul_div_cancel'`: if a ∣ n then a * (n / a) = n.

## 4. PROOF OVERVIEW

**Composite case (`pAdic_factoring_oracle_composite`):**
Given n > 1 and ¬Prime(n), apply `Nat.exists_dvd_of_not_prime2` to obtain a divisor a with 2 ≤ a ≤ √n. Set b = n / a. Then a · b = n by exact division, a > 1 by hypothesis, and b > 1 because n is not prime (if b = 1 then n = a, contradicting ¬Prime(n) since a would be prime).

**Dichotomy (`pAdic_factoring_oracle_dichotomy`):**
By excluded middle on `Nat.Prime n`: if prime, take the left disjunct; if composite, apply the composite case for the right disjunct.

## 5. NOVELTY ANALYSIS

The mathematical content is classical, but the novelty lies in:
1. **Identifying the error** in the original "p-adic factoring oracle" conjecture — the statement universally quantified over all n > 1, which is false for primes.
2. **Machine verification** — the corrected statement is proved in Lean 4 with Mathlib, ensuring no logical gaps.
3. **Foundation for p-adic methods** — this formalized dichotomy can serve as the base case for more sophisticated Hensel-lifting factoring algorithms in future formalization efforts.

## 6. OPEN PROBLEMS

1. **Formalize polynomial-time primality testing** (AKS) in Lean 4 to complement the factoring oracle with an efficient decision procedure.
2. **Formalize Hensel's lemma for ℤ_p** and connect it to actual p-adic factoring algorithms (e.g., lifting modular roots to p-adic precision).
3. **Prove complexity lower bounds** for factoring in a formal proof assistant — can one formalize the reduction from factoring to discrete logarithm?

## 7. REFERENCES

1. Hardy, G.H. and Wright, E.M. *An Introduction to the Theory of Numbers*, 6th ed., Oxford University Press, 2008.
2. Koblitz, N. *p-adic Numbers, p-adic Analysis, and Zeta-Functions*, 2nd ed., Springer GTM 58, 1984.
3. The Mathlib Community. *Mathlib4: Mathematics in Lean 4*. https://github.com/leanprover-community/mathlib4, 2024.
4. Lenstra, A.K. and Lenstra, H.W. *The Development of the Number Field Sieve*, Lecture Notes in Mathematics 1554, Springer, 1993.
