# Future Directions: Fibonacci Entry Points and Carmichael's Theorem

This document describes five research directions extending the formalized
Fibonacci entry point theory (`Shared/FibonacciEntryPoint.lean`) and
Carmichael's theorem infrastructure (`Shared/CarmichaelHelper.lean`,
`Shared/CarmichaelProof.lean`).

---

## 1. The Fibonacci Lifting-the-Exponent Lemma (LTE)

For an odd prime p with entry point α(p) = m, the p-adic valuation of
Fibonacci numbers satisfies:

  v_p(F(m·k)) = v_p(F(m)) + v_p(k)

whenever gcd(k, p) = 1. This identity is the key missing ingredient for
closing the asymptotic case of Carmichael's theorem (n > 50000 composite).

The key insight is that the Fibonacci LTE follows from the standard LTE
for integers (available as `padicValNat.pow_sub_pow` in Mathlib) applied
to the eigenvalues of the companion matrix in the p-adic integers ℤ_p[√5].
When 5 is a quadratic residue mod p, the eigenvalues live in ℤ_p directly;
otherwise they live in the unramified extension ℤ_p[√5].

Why now? Mathlib's p-adic infrastructure (`Padic`, `PadicInt`, `padicValNat`)
is mature enough to formalize this argument. The entry point theory we've
proved provides the necessary divisibility properties. Proving the LTE would
immediately close the last `sorry` in `CarmichaelProof.lean` and complete
the full formalization of Carmichael's 1913 theorem.

---

## 2. The Fibonacci Cyclotomic Polynomial

Define the "Fibonacci cyclotomic polynomial" Ψ_n by the Möbius product:

  F(n) = ∏_{d|n} Ψ_d

where Ψ_n = ∏_{d|n} F(d)^{μ(n/d)}. Any prime dividing Ψ_n is a primitive
prime divisor of F(n). The conjecture is:

  **Conjecture:** Ψ_n is a positive integer for all n ≥ 1, and Ψ_n > 1
  for all n ≥ 13.

The key insight is that log(Ψ_n) = φ(n) · log(φ) + O(log n) where φ is the
golden ratio and φ(n) is Euler's totient. For n ≥ 13 composite, φ(n) ≥ 4,
giving Ψ_n ≥ φ^4/n > 1. This provides an alternative proof of Carmichael's
theorem that avoids the LTE entirely.

Why now? The Möbius function and arithmetic functions are well-developed in
Mathlib (`ArithmeticFunction`). The integrality of Ψ_n follows from the
strong divisibility of Fibonacci, which we've already formalized.

---

## 3. Entry Point Congruences and Quadratic Reciprocity

The entry point α(p) satisfies deep congruence properties:

  - α(p) | p - 1 if p ≡ ±1 (mod 5) (i.e., 5 is a QR mod p)
  - α(p) | p + 1 if p ≡ ±2 (mod 5) (i.e., 5 is a QNR mod p)
  - α(5) = 5

This means F(p) ≡ (5/p) (mod p) where (5/p) is the Legendre symbol.
The conjecture to formalize:

  **Conjecture:** For every prime p, fibEntry p divides
  p - legendreSym 5 p (interpreting the Legendre symbol as ±1).

The key insight is that this follows from applying the Frobenius endomorphism
to the Fibonacci eigenvalues in the finite field F_{p²}. When 5 is a QR,
the eigenvalues live in F_p and are fixed by Frobenius; when 5 is a QNR,
Frobenius swaps them. This gives M^p = M^{±1} mod p (where M is the
companion matrix), hence F(p±1) ≡ 0 mod p.

Why now? Mathlib has `legendreSym`, `ZMod`, and `GaloisField`. The entry
point infrastructure is now in place to state and verify this cleanly.

---

## 4. Wall-Sun-Sun Primes and the Fibonacci Wieferich Problem

A Wall-Sun-Sun prime is a prime p such that F(p - (5/p)) ≡ 0 (mod p²).
No Wall-Sun-Sun prime has been found, and their non-existence would imply
the first case of Fermat's Last Theorem.

  **Conjecture:** There are no Wall-Sun-Sun primes below 10^{17}.

The key insight is that the condition F(p - (5/p)) ≡ 0 (mod p²) is equivalent
to v_p(F(α(p))) ≥ 2, where α(p) is the entry point. Using the Fibonacci LTE,
this is equivalent to α(p) | p - (5/p) with v_p(F(α(p))) = 1 (the generic
case) being violated.

Why now? The computational verification up to large bounds is feasible with
`native_decide` on a suitable checker (similar to our primitive divisor
checker). The formal infrastructure for p-adic valuations of Fibonacci
numbers would enable stating the problem precisely.

---

## 5. Generalized Strong Divisibility Sequences

The Fibonacci sequence is a special case of a Lucas sequence of the first
kind U_n(P, Q). The entry point theory generalizes: for any Lucas sequence
U_n(P, Q) with discriminant D = P² - 4Q:

  - gcd(U_m, U_n) = U_{gcd(m,n)} (strong divisibility)
  - α_U(p) | p - (D/p) for primes p ∤ 2Q

  **Conjecture:** The full entry point theory (existence, divisibility
  characterization, primitive divisor existence for n ≥ 13) extends to
  all non-degenerate Lucas sequences U_n(P, Q) with |P| ≥ 1.

The key insight is that the proofs in `FibonacciEntryPoint.lean` use only
the strong divisibility property `gcd(F(m), F(n)) = F(gcd(m,n))` and the
existence of an entry point. Both generalize to Lucas sequences. The
primitive divisor result (Bilu-Hanrot-Voutier 2001) shows that for
non-degenerate Lucas sequences, primitive divisors exist for all n > 30.

Why now? Mathlib has infrastructure for polynomial recurrences and Lucas
sequences (`Nat.lucas`). Our entry point theory is modular — it depends
on `Nat.fib_gcd` and `Nat.fib_dvd` which have Lucas sequence analogues.
Abstracting the proofs to a typeclass for strong divisibility sequences
would unify Fibonacci, Lucas, Lehmer, and other sequences.
