# Non-Archimedean Factoring Oracle: A Corrected Formalization

## 1. ABSTRACT

We investigate the formalization of a proposed "p-adic factoring oracle" — a theorem claiming that every integer greater than 1 admits a non-trivial factorization. We demonstrate that the original statement is **false** as formulated (it fails for prime numbers) and provide two corrected formalizations in Lean 4 with Mathlib. The corrected theorems establish the fundamental dichotomy: every integer n > 1 is either prime or composite, and composite numbers admit non-trivial factorizations. While the p-adic motivation is mathematically rich, the core factoring claim reduces to elementary number theory. Our machine-verified proofs use Mathlib's `Nat.exists_dvd_of_not_prime2` and demonstrate the value of formal verification in catching subtle mathematical errors before they propagate.

## 2. MOTIVATION

Integer factorization is central to computational number theory and cryptography. The security of RSA and related cryptosystems rests on the computational difficulty of factoring large semiprimes. While p-adic methods (Hensel lifting, Newton polygons) do play roles in algebraic number theory and some factoring algorithms (e.g., p-adic root lifting in Berlekamp-Zassenhaus), the existence of non-trivial factorizations for composite numbers is a prerequisite fact that must be stated correctly. This work illustrates how formal verification catches errors in mathematical claims — even "obvious" ones — that might otherwise propagate through research pipelines.

## 3. MATHEMATICAL FRAMEWORK

**Definitions:**
- A natural number n is **prime** if n ≥ 2 and its only divisors are 1 and n itself. In Lean/Mathlib: `Nat.Prime n`.
- A natural number n > 1 is **composite** if it is not prime, equivalently, if there exist a, b > 1 with a · b = n.
- The **minimal factor** `Nat.minFac n` is the smallest prime factor of n, which provides a constructive witness for factorization.

**Key Mathlib lemma used:**
- `Nat.exists_dvd_of_not_prime2 : n > 1 → ¬Nat.Prime n → ∃ m, m ∣ n ∧ 2 ≤ m ∧ m < n`

This lemma yields a proper divisor m of n, from which both factors m and n/m are strictly between 1 and n.

## 4. PROOF OVERVIEW

**Original claim (false):** ∀ n > 1, ∃ a b > 1, a · b = n.

**Counterexample:** n = 2 (or any prime).

**Corrected Theorem 1 (prime-or-composite dichotomy):**
For n > 1, either n is prime or there exist a, b > 1 with a · b = n.

*Proof strategy:* Case split on `Nat.Prime n`. The prime case is immediate. For the composite case, apply `Nat.exists_dvd_of_not_prime2` to obtain a proper divisor k with 2 ≤ k < n and k ∣ n. Then a = k and b = n/k satisfy the requirements, with the bound b > 1 following from k < n.

**Corrected Theorem 2 (composite factoring):**
For n > 1 with ¬Nat.Prime n, there exist a, b > 1 with a · b = n.

*Proof:* Same as the composite branch above.

## 5. NOVELTY ANALYSIS

The mathematical content is classical and well-known. The novelty lies in:

1. **Error detection:** The formal verification process caught a false theorem statement that might pass informal review, demonstrating the value of proof assistants as mathematical quality control.
2. **Clean formalization:** The corrected proofs are concise (3-4 lines each) and leverage Mathlib's API effectively.
3. **Methodological lesson:** Even when p-adic or other advanced frameworks motivate a result, the formalization must stand on its own logical merits.

## 6. OPEN PROBLEMS

1. **Constructive factoring bounds:** Can we formalize in Lean that the minimal factor of n is at most √n, and use this to give complexity bounds on trial division?

2. **P-adic Hensel lifting formalization:** Formalize Hensel's lemma for ℤ_p in Lean/Mathlib and use it to lift factorizations of polynomials modulo p to factorizations over ℤ_p. This connects to the original p-adic motivation.

3. **Newton polygon formalization:** Formalize the Newton polygon of a polynomial over ℚ_p and prove that its slopes determine the p-adic valuations of the roots, providing a bridge between combinatorial geometry and p-adic analysis.

## 7. REFERENCES

1. Neukirch, J. *Algebraic Number Theory*. Springer, 1999. (Hensel's lemma and p-adic methods)
2. Gouvêa, F.Q. *p-adic Numbers: An Introduction*. Springer, 2nd ed., 1997. (Newton polygons, p-adic valuations)
3. The Mathlib Community. *Mathlib4 documentation*. https://leanprover-community.github.io/mathlib4_docs/ (Lean 4 formalization library)
4. Cohen, H. *A Course in Computational Algebraic Number Theory*. Springer, 1993. (Factoring algorithms)
5. Cohn, P.M. "The complement of a finitely generated direct summand of an abelian group." *Proc. Amer. Math. Soc.* 7 (1956), 520–521. (Irreducibility and factorization in commutative monoids)
