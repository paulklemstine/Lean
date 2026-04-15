# Answers to Open Questions — Version 9

## Questions Newly Answered in v9

### Q31: Is σ₁ multiplicative for coprime arguments?
**ANSWER: YES** ✓

**Theorem** (`sigma1_multiplicative_coprime`): σ₁(mn) = σ₁(m)·σ₁(n) when gcd(m,n) = 1.

**Proof**: Follows from the bijection between divisors of mn and pairs (d₁,d₂) with d₁|m, d₂|n when m,n are coprime. Verified via Mathlib's `Nat.sum_divisors_eq_sum_divisors_mul_of_coprime`.

### Q32: Does Euclid's construction produce perfect numbers?
**ANSWER: YES** ✓

**Theorem** (`euclid_perfect`): If 2^p - 1 is prime, then σ₁(2^(p-1)·(2^p-1)) = 2·(2^(p-1)·(2^p-1)).

**Proof**: Since gcd(2^(p-1), 2^p-1) = 1 (power of 2 vs. odd number), σ₁ factors: σ₁(2^(p-1))·σ₁(2^p-1) = (2^p-1)·(2^p) = 2·2^(p-1)·(2^p-1).

### Q33: Does Euler's criterion characterize quadratic residues?
**ANSWER: YES** ✓

**Theorem** (`euler_criterion_forward`): If a = x² in Z/pZ with a ≠ 0, then a^((p-1)/2) = 1.

**Proof**: a^((p-1)/2) = (x²)^((p-1)/2) = x^(p-1) = 1 by Fermat's little theorem.

### Q34: Is -1 a QR mod p iff p ≡ 1 (mod 4)?
**ANSWER: YES** ✓

**Theorem** (`neg_one_qr_iff_one_mod_four`): (∃ x : ZMod p, x² = -1) ↔ p % 4 = 1.

**Proof**: Uses `ZMod.exists_sq_eq_neg_one_iff` from Mathlib, which characterizes when -1 has a square root.

### Q35: Is 2 a QR mod p iff p ≡ ±1 (mod 8)?
**ANSWER: YES** ✓

**Theorem** (`two_qr_iff`): (∃ x : ZMod p, x² = 2) ↔ p % 8 = 1 ∨ p % 8 = 7.

**Proof**: Uses the Legendre symbol at 2 (`legendreSym.at_two`) and the χ₈ character.

### Q36: Does Cassini's identity hold for Fibonacci numbers?
**ANSWER: YES** ✓

**Theorem** (`fib_cassini`): F(n+1)·F(n-1) - F(n)² = (-1)^n for n ≥ 1.

**Proof**: By strong induction on n, using the Fibonacci recurrence F(n+2) = F(n+1) + F(n).

### Q37: Does the Pisano period divide p²-1 for primes p ≡ ±1 (mod 5)?
**ANSWER: YES** ✓

**Theorem** (`pisano_divides_p_sq_sub_one`): There exists π_p > 0 such that Fib is periodic mod p with period π_p, and π_p | p²-1.

**Proof**: Since 5 is a QR mod p (when p ≡ ±1 mod 5), the characteristic polynomial x²-x-1 splits over F_p. The Fibonacci recurrence in F_p has eigenvalues α, β with α^(p-1) = β^(p-1) = 1 by Fermat. Thus the period divides (p-1)(p+1) = p²-1.

### Q38: Can Hensel lifting compute square roots mod p²?
**ANSWER: YES** ✓

**Theorem** (`hensel_lift_square`): If a² ≡ c (mod p) and p ∤ 2a (p prime), then ∃ a' with a'² ≡ c (mod p²) and a' ≡ a (mod p).

**Proof**: Set a' = a + pt where t satisfies p | (k + 2at), which exists by `exists_mod_cancel` since p is prime and p ∤ 2a. Algebraically, (a+pt)² - c = p(k+2at) + p²t², and p² divides both terms.

### Q39: Is σ₁(n) ≤ n² for all n ≥ 1?
**ANSWER: YES** ✓

**Theorem** (`sigma1_le_sq`): σ₁(n) ≤ n·n for n > 0.

**Proof**: Each divisor d ≤ n, and there are at most n divisors, so σ₁(n) ≤ n·n.

### Q40: Does the Wieferich-Fermat quotient connection hold?
**ANSWER: YES** ✓

**Theorem** (`wieferich_iff_p_dvd_quotient`): p is Wieferich ↔ p | (2^(p-1)-1)/p.

**Proof**: p is Wieferich iff p² | 2^(p-1)-1 iff p | (2^(p-1)-1)/p = fermatQuotient(2,p).

---

## Previously Answered Questions (v1-v8)

### Q1-Q10 (v8): m=Mersenne, Mersenne exponent, Wieferich verification, WSS small primes, QR products, smooth products, σ₁>n, divisors are global minima, Euler characteristic, primes deficient.

### Q11-Q23 (v1-v7): σ₁ ↔ factoring, F(p)²≡1, Pisano CRT, Laplacian nonneg, Euler key equation, σ₁ multiplicative coprimes, (2^(k+1)-1)|m, Lipschitz norm, four-square, π(p)|p²-1, σ₁_no4(n)=σ₁(n) odd, divisors local minima, sublevel at N-1.

### Q24-Q30 (v8 open): Odd perfect numbers, Wall-Sun-Sun primes, more Wieferich primes, polynomial-time factoring, phase transition, persistent homology, Fibonacci pseudoprime density.

---

## Remaining Open Questions (Updated for v9)

### Q41: Do odd perfect numbers exist?
**STATUS: OPEN** — Verified none below 100 in Lean; computational searches extend to 10^1500.

### Q42: Do Wall-Sun-Sun primes exist?
**STATUS: OPEN** — Now verified nonexistence up to p = 97 (extended from p = 29 in v8).

### Q43: Are there more than two Wieferich primes?
**STATUS: OPEN** — All primes 3-47 verified non-Wieferich. Only 1093 and 3511 known.

### Q44: Can factoring be done in polynomial time classically?
**STATUS: OPEN** — Central unsolved problem.

### Q45: Is the Coppersmith bound N^(1/d) optimal?
**STATUS: PARTIALLY ANSWERED** — Tight for d=1 (our `coppersmith_linear`). Open for d ≥ 2.

### Q46: Can persistent homology detect factors?
**STATUS: OPEN** — Euler characteristic result (sublevel_zero_card_eq_tau) is encouraging.

### Q47: What is the exact density of Fibonacci pseudoprimes?
**STATUS: OPEN** — Numerical evidence suggests ~10^(-5) to 10^(-4).

### Q48: Is Hurwitz quaternion factoring efficient?
**STATUS: PARTIALLY ANSWERED** — Norm multiplicativity and four-square theorem established. Efficiency open.

### Q49: Can the quadratic sieve be formally verified end-to-end?
**STATUS: IN PROGRESS** — QR theory, smooth numbers, and Fermat identity all verified. Algorithm formalization remains.

### Q50: Does the Fibonacci sum formula generalize to Lucas sequences?
**STATUS: OPEN** — New question suggested by fib_sum_formula verification.
