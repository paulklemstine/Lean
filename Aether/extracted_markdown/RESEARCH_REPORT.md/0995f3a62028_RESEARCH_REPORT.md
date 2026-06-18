# Non-Archimedean Factoring Oracle: Research Report

## 1. ABSTRACT

We investigate a proposed "p-adic factoring oracle" that claims to factor any integer n > 1 into nontrivial components by analyzing Newton polygons over the p-adic numbers Q_p. We formally verify in Lean 4 (Mathlib v4.28.0) that the original statement is **false**: primes constitute immediate counterexamples, since any factorization of a prime p = a · b with a, b ∈ ℕ forces one factor to equal 1. We provide a machine-checked disproof (`pAdic_factoring_oracle_false`) using n = 2 as a counterexample, and a corrected theorem (`pAdic_factoring_oracle_corrected`) establishing that every *composite* number n > 1 admits a nontrivial factorization. The corrected statement adds the hypothesis ¬Nat.Prime n, which is both necessary and sufficient. This work highlights the importance of formal verification in validating number-theoretic claims.

## 2. MOTIVATION

Integer factorization is central to modern cryptography — the security of RSA and related schemes rests on the computational difficulty of factoring large semiprimes. The idea of a "factoring oracle" based on p-adic analysis is theoretically appealing: Newton polygons encode valuative information about polynomial roots, and Hensel's lemma provides a powerful lifting mechanism. However, no such oracle can exist as an unconditional statement about all integers greater than 1, because the existence of prime numbers is a fundamental obstruction. This formal verification serves as a cautionary tale about the gap between algorithmic intuition and rigorous mathematical truth.

## 3. MATHEMATICAL FRAMEWORK

**Definitions and notation:**
- ℕ denotes the natural numbers {0, 1, 2, ...}.
- Nat.Prime n means n ≥ 2 and the only divisors of n are 1 and n itself.
- A *nontrivial factorization* of n is a pair (a, b) with a > 1, b > 1, and a · b = n.
- Q_p denotes the p-adic completion of Q with respect to the p-adic valuation v_p.

**Key lemma (Mathlib):** `Nat.exists_dvd_of_not_prime2` — if n > 1 and n is not prime, then there exists k with k ∣ n and 1 < k < n.

**Counterexample construction:** For the disproof, we instantiate p = 2 and n = 2. If a > 1 and b > 1 then a ≥ 2, b ≥ 2, so a · b ≥ 4 > 2, contradicting a · b = 2.

## 4. PROOF OVERVIEW

### Disproof of the original statement
1. Negate the universal statement to obtain an existential goal.
2. Provide the witness p = 2, n = 2 with the proof that 2 is prime and 2 > 1.
3. For any proposed a, b with a · b = 2 and a > 1, b > 1: since a ≥ 2 and b ≥ 2, we have a · b ≥ 4, contradicting a · b = 2.

### Corrected theorem
1. From hn : n > 1 and hc : ¬ Nat.Prime n, apply `Nat.exists_dvd_of_not_prime2` to obtain a divisor k with k ∣ n and 1 < k < n.
2. Set a := k and b := n / k.
3. Verify a · b = n using `Nat.mul_div_cancel'`.
4. Verify a > 1 (immediate from 1 < k).
5. Verify b > 1: since k < n and k ∣ n, we have n / k ≥ 2.

## 5. NOVELTY ANALYSIS

The novelty lies not in the mathematical content (which is elementary) but in the **formal verification methodology**:
- We demonstrate that formal proof assistants can catch false conjectures before they propagate through a research pipeline.
- The disproof is fully machine-checked, leaving no room for error.
- The corrected theorem precisely identifies the missing hypothesis, illustrating how formal methods sharpen mathematical statements.
- The work shows that even "obvious" number-theoretic claims require careful formulation.

## 6. OPEN PROBLEMS

1. **Algorithmic p-adic factoring:** Can Newton polygon analysis over Q_p yield a polynomial-time factoring algorithm for specific families of integers (e.g., integers of the form p^k ± 1)?

2. **Formal complexity bounds:** Can we formalize in Lean a proof that integer factorization is in NP ∩ co-NP, and state the open question of whether it is in P?

3. **Hensel lifting for factorization:** Can Hensel's lemma be used to formally verify the correctness of p-adic lifting algorithms (such as those used in polynomial factorization over Z) in Lean/Mathlib?

## 7. REFERENCES

1. Gouvêa, F. Q. (1997). *p-adic Numbers: An Introduction*. Springer-Verlag. (Universitext series.)
2. Neukirch, J. (1999). *Algebraic Number Theory*. Springer-Verlag. (Grundlehren der mathematischen Wissenschaften, Vol. 322.)
3. The Mathlib Community. (2020–2026). *Mathlib: The Lean Mathematical Library*. https://github.com/leanprover-community/mathlib4
4. Cohn, H. (1980). *Advanced Number Theory*. Dover Publications.
5. Lenstra, A. K., Lenstra, H. W., Lovász, L. (1982). Factoring polynomials with rational coefficients. *Mathematische Annalen*, 261(4), 515–534.
