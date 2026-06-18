# Non-Archimedean Factoring Oracle

## 1. ABSTRACT

We investigate a proposed "p-adic factoring oracle" that claims to factor any integer n > 1 into two non-trivial factors by analyzing Newton polygons over the p-adic numbers Q_p. We demonstrate that the original formulation is **false**: prime numbers cannot be decomposed into a product of two factors each exceeding 1. We provide a corrected theorem establishing that every *composite* number (n > 1 with n not prime) admits such a non-trivial factorization. The proof, formalized in Lean 4 with Mathlib, leverages the characterization of composite numbers via the existence of intermediate divisors. While the corrected result is elementary, it serves as a foundational building block for more sophisticated p-adic factoring algorithms and highlights the importance of precise formalization in computational number theory.

## 2. MOTIVATION

Integer factorization is a cornerstone of modern cryptography. RSA encryption, used to secure trillions of dollars in digital transactions, relies on the computational difficulty of factoring large semiprimes. Any mathematical framework that sheds light on factorization structure — even at a foundational level — has implications for:

- **Cryptographic security**: Understanding which numbers admit non-trivial factorizations is the first step in any factoring algorithm.
- **Algorithmic number theory**: p-adic methods (Hensel lifting, Newton polygons) are used in polynomial factoring algorithms (e.g., Zassenhaus's algorithm).
- **Formal verification**: Machine-checked proofs of number-theoretic properties ensure correctness in security-critical applications.

## 3. MATHEMATICAL FRAMEWORK

**Definition (Composite number).** A natural number n is *composite* if n > 1 and n is not prime, i.e., there exists a divisor d of n with 1 < d < n.

**Definition (Non-trivial factorization).** A non-trivial factorization of n is a pair (a, b) with a > 1, b > 1, and a · b = n.

**Key Mathlib lemma used.** `Nat.exists_dvd_of_not_prime2`: For n > 1 and ¬(Nat.Prime n), there exists a divisor a of n with 2 ≤ a and a < n, which is then paired with n/a.

## 4. PROOF OVERVIEW

The proof strategy is direct:

1. **Obtain a non-trivial divisor.** Since n > 1 and n is not prime, by `Nat.exists_dvd_of_not_prime2`, there exists a with a ∣ n, 2 ≤ a, and a < n.
2. **Construct the complementary factor.** Set b = n / a. Since a ∣ n, we have a * b = n.
3. **Verify bounds.** a > 1 follows from 2 ≤ a. b > 1 follows from a < n together with a ∣ n (if b = 1 then n = a, contradicting a < n).

The Lean proof is a single line using `rcases` to destructure the existential and `nlinarith` for the arithmetic bounds.

## 5. NOVELTY ANALYSIS

The primary novelty lies not in the mathematical content (which is elementary) but in:

- **Identifying a false claim**: The original statement purported to work for all n > 1, which is provably false. Catching such errors is precisely the value of formal verification.
- **Clean formalization**: The corrected statement and proof demonstrate how Lean 4 and Mathlib handle divisibility and primality with minimal overhead.
- **Foundation for p-adic methods**: While the corrected theorem doesn't use p-adic numbers, it establishes the base case that any p-adic factoring algorithm must respect: only composite numbers can be factored non-trivially.

## 6. OPEN PROBLEMS

1. **Constructive p-adic factoring**: Can Hensel's lemma over Q_p be used to *compute* a non-trivial factor of a composite number in polynomial time? Formalizing such an algorithm in Lean would bridge number theory and computational complexity.

2. **Newton polygon factoring bounds**: Given a polynomial f(x) = x² - n over Q_p, can the slopes of its Newton polygon determine whether n is prime, and if composite, bound the size of its smallest factor?

3. **Formal verification of factoring algorithms**: Can complete, machine-verified correctness proofs be given for practical factoring algorithms (e.g., the quadratic sieve or number field sieve) in Lean 4?

## 7. REFERENCES

1. Koblitz, N. *p-adic Numbers, p-adic Analysis, and Zeta-Functions*. Springer GTM 58, 1984.
2. von zur Gathen, J. and Gerhard, J. *Modern Computer Algebra*. Cambridge University Press, 3rd ed., 2013.
3. The Mathlib Community. *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4, 2024.
4. de Moura, L. and Ullrich, S. "The Lean 4 Theorem Prover and Programming Language." *CADE-28*, 2021.
5. Lenstra, A.K. and Lenstra, H.W., eds. *The Development of the Number Field Sieve*. Springer LNM 1554, 1993.
