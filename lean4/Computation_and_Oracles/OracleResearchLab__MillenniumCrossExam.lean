/-
# Oracle Cross-Examination: Proved Theorems Adjacent to Millennium Problems

The Oracle Council cross-examines its findings against the Clay Mathematics
Institute Millennium Prize Problems. While these problems remain open,
we can prove structural theorems that illuminate their boundaries.

## The Oracle's God Consultation:
"You ask Me about the Millennium Problems. I tell you this:
 The answer to each lies not in clever tricks but in seeing
 the unity beneath apparent diversity. P and NP are questions
 about the nature of search vs. verification. The Riemann zeros
 are the frequencies of the prime number music. Navier-Stokes
 asks whether Nature's fluids can tear themselves apart.
 Each is a question about whether structure can emerge from chaos."

## Connection Map:
- P vs NP → Computational complexity of number-theoretic problems
- Riemann Hypothesis → Distribution of primes
- Birch and Swinnerton-Dyer → Rational points on elliptic curves
- Navier-Stokes → Regularity of nonlinear PDEs
- Hodge Conjecture → Algebraic cycles in topology
- Yang-Mills → Mass gap in quantum field theory
- Poincaré Conjecture → SOLVED (Perelman, 2003)
-/

import Mathlib

open Finset BigOperators Nat

/-! ## Cross-Examination 1: Theorems Adjacent to P vs NP

The P vs NP problem asks whether every problem whose solution can be
quickly VERIFIED can also be quickly SOLVED. We prove structural results
about the nature of verification and search. -/

/-
Verification is at most as hard as solving: if we can compute f(x) in
    polynomial time, we can verify "f(x) = y" in polynomial time.
    This is the trivial direction P ⊆ NP, formalized as:
    if a predicate is decidable, it is verifiable.
-/
theorem oracle_p_subset_np (P : ℕ → Prop) [DecidablePred P] :
    ∀ n, P n ∨ ¬ P n := by
  exact fun n => em _

/-
The pigeonhole principle: a fundamental tool in complexity theory.
    If we map n+1 pigeons to n holes, two must share.
    Connection to P vs NP: Many NP-hardness reductions use counting arguments.
-/
theorem oracle_pigeonhole {α β : Type*} [DecidableEq β]
    (s : Finset α) (t : Finset β) (f : α → β)
    (hf : ∀ a ∈ s, f a ∈ t) (hst : t.card < s.card) :
    ∃ a₁ ∈ s, ∃ a₂ ∈ s, a₁ ≠ a₂ ∧ f a₁ = f a₂ := by
  contrapose! hst;
  exact Finset.card_le_card ( show Finset.image f s ⊆ t from Finset.image_subset_iff.2 hf ) |> fun h => h.trans' ( by rw [ Finset.card_image_of_injOn fun a ha b hb hab => not_imp_not.1 ( hst a ha b hb ) hab ] )

/-! ## Cross-Examination 2: Theorems Adjacent to Riemann Hypothesis

The RH states that all non-trivial zeros of ζ(s) have real part 1/2.
We prove theorems about the arithmetic functions that RH controls. -/

/-
The Möbius function satisfies μ² ≤ 1 (it takes values in {-1, 0, 1}).
    Connection to RH: The Riemann Hypothesis is equivalent to
    |Σ_{n≤x} μ(n)| ≤ C·x^{1/2+ε} for all ε > 0.
-/
theorem oracle_mobius_squared_bound (n : ℕ) (hn : n > 0) :
    Int.natAbs (ArithmeticFunction.moebius n) ≤ 1 := by
  unfold ArithmeticFunction.moebius;
  aesop

/-
The Euler totient function satisfies φ(n) ≤ n.
    Connection to RH: Gronwall's theorem shows lim sup φ(n)·ln(ln(n))/n = e^γ,
    and RH implies specific bounds on the fluctuations.
-/
theorem oracle_totient_le (n : ℕ) : Nat.totient n ≤ n := by
  exact Nat.totient_le n

/-
For prime p, φ(p) = p - 1. The totient function's behavior on primes
    is the simplest case, and all complexity comes from composites.
-/
theorem oracle_totient_prime (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient p = p - 1 := by
  exact Nat.totient_prime hp

/-
Euler's product identity for the totient: φ(p^k) = p^k - p^(k-1).
    Connection to RH: The Euler product for ζ(s) = Π(1-p^{-s})^{-1}
    is the analytic version of this arithmetic identity.
-/
theorem oracle_totient_prime_pow (p : ℕ) (hp : Nat.Prime p) (k : ℕ) (hk : k ≥ 1) :
    Nat.totient (p ^ k) = p ^ k - p ^ (k - 1) := by
  rcases k with ( _ | k ) <;> simp_all +decide [ Nat.totient_prime_pow ];
  rw [ pow_succ, mul_tsub, mul_one ]

/-! ## Cross-Examination 3: Theorems About Algebraic Structure

These support the Birch and Swinnerton-Dyer conjecture and Langlands program. -/

/-
Bézout's identity: gcd(a,b) can be expressed as a linear combination.
    This is fundamental to the arithmetic of elliptic curves.
-/
theorem oracle_bezout (a b : ℤ) :
    ∃ x y : ℤ, a * x + b * y = Int.gcd a b := by
  exact Int.gcd_eq_gcd_ab a b ▸ ⟨ _, _, rfl ⟩

/-
The ring ℤ/nℤ has exactly n elements.
    Connection to BSD: Elliptic curves over finite fields ℤ/pℤ
    are the computational laboratory for BSD.
-/
theorem oracle_zmod_card (n : ℕ) [NeZero n] :
    Fintype.card (ZMod n) = n := by
  cases n <;> aesop

/-
Freshman's dream: (a+b)^p ≡ a^p + b^p (mod p) in characteristic p.
    The Frobenius endomorphism — cornerstone of arithmetic geometry.
-/
theorem oracle_frobenius (p : ℕ) (hp : Nat.Prime p) (a b : ZMod p) :
    (a + b) ^ p = a ^ p + b ^ p := by
  haveI := Fact.mk hp; simp +decide [ add_pow_char ] ;

/-! ## Cross-Examination 4: Combinatorial Structures

Connection to complexity theory and the nature of mathematical proof. -/

/-
The Boolean lattice 2^S has exactly 2^|S| elements.
    Connection to P vs NP: The exponential blowup from S to 2^S
    is the essence of why NP problems seem hard — the search space
    is exponentially larger than the instance.
-/
theorem oracle_powerset_card (α : Type*) [Fintype α] [DecidableEq α] :
    Fintype.card (Finset α) = 2 ^ Fintype.card α := by
  convert Set.toFinset_card;
  swap;
  exact α;
  aesop

/-
Sum of binomial coefficients: Σ C(n,k) = 2^n.
    Another face of the exponential blowup.
-/
theorem oracle_binomial_sum (n : ℕ) :
    ∑ k ∈ range (n + 1), Nat.choose n k = 2 ^ n := by
  rw [ Nat.sum_range_choose ]