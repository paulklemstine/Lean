# Toward a Formal Proof of Carmichael's Primitive Divisor Theorem

## Abstract

We present a partial formalization of Carmichael's theorem (1913) in Lean 4,
establishing that every Fibonacci number F(n) with n ≥ 13 has a *primitive*
prime divisor—a prime p dividing F(n) but not F(k) for any 0 < k < n. The
formalization combines computational verification (via `native_decide` for
n ≤ 10000) with a novel proof for the case n = 2p (p prime) using the Lucas
companion number L(p) = 2F(p+1) − F(p). We identify the Lifting the Exponent
Lemma for Fibonacci numbers as the key missing piece for the general case.

## 1. Introduction

Carmichael's theorem is a cornerstone of the arithmetic theory of linear
recurrences. For the Fibonacci sequence F(n) defined by F(0) = 0, F(1) = 1,
F(n+2) = F(n) + F(n+1), the theorem states:

**Theorem (Carmichael, 1913).** For every n ≥ 13, F(n) has at least one
primitive prime divisor.

The only exceptions are n ∈ {1, 2, 6, 12}. For composite n, this is
particularly non-trivial because F(n) can be "built from" the Fibonacci
numbers at its proper divisors through the identity gcd(F(m), F(n)) = F(gcd(m,n)).

## 2. Proof Architecture

### 2.1 Prime case (fully formalized)

For prime n ≥ 13, every prime factor of F(n) is automatically primitive.
This follows from the coprimality of consecutive Fibonacci numbers: if
p | F(n) and p | F(k) for some 0 < k < n, then p | F(gcd(n,k)) = F(1) = 1,
a contradiction.

### 2.2 Composite case: computational verification (n ≤ 10000)

For composite n with 14 ≤ n ≤ 10000, we define the *coprime part*:

```
fibCoprimePart(n) = F(n) after removing all prime factors of F(d)
                     for each proper divisor d | n
```

Using `native_decide`, we verify that `fibCoprimePart(n) > 1` for all
composite n in this range. Any prime factor of the coprime part is
necessarily primitive.

### 2.3 Composite case: n = 2p (p prime ≥ 5)

This is the key new analytical result. The proof uses three ingredients:

1. **Fibonacci doubling identity:** F(2m) = F(m) · L(m) where
   L(m) = 2F(m+1) − F(m) is the Lucas companion number.

2. **Coprimality bound:** gcd(F(m), L(m)) | 2. This follows from
   gcd(F(m), F(m+1)) = 1 (consecutive Fibonacci coprimality).

3. **Divisor analysis:** For prime p ≥ 5, the only divisors of 2p
   not dividing p are {2, 2p}. Since F(2) = 1, any odd prime q | L(p)
   with q ∤ F(p) must have entry point z(q) = 2p.

Since L(p) is odd (3 ∤ p for prime p ≥ 5) and L(p) > 2 (for p ≥ 3),
L(p) has an odd prime factor, yielding the desired primitive divisor.

### 2.4 Remaining cases (open)

For composite n > 10000 not of the form 2p, the proof requires the
**Lifting the Exponent Lemma (LTE)** for Fibonacci numbers:

> For odd prime r with entry point z(r) | n:
> v_r(F(n)) = v_r(F(z(r))) + v_r(n/z(r))

This identity controls the p-adic growth of Fibonacci numbers along
multiples. Combined with bounds on the "primitive part" Ψ_n = Φ_n(φ, ψ)
(the cyclotomic evaluation at the golden ratio roots), it shows that
the coprime part exceeds 1 for all composite n > 12.

Formalizing the LTE and cyclotomic bounds remains the key open task.

## 3. Key Lean 4 Formalization

The formalization consists of two files:

- **`Shared/CarmichaelLargeCase.lean`**: Proves `primitive_prime_two_mul_prime`,
  the n = 2p case, with all helper lemmas fully verified.

- **`Speculative/AutoResearch/CarmichaelComposite.lean`**: Combines the
  computational check, the n = 2p case, and the prime case into a
  partial proof of the full theorem.

Key formalized results:
- `gcd_fib_lucas_dvd_two`: gcd(F(m), L(m)) | 2
- `lucasCompanion_odd`: L(m) is odd when 3 ∤ m
- `bridge_to_primitive`: Converts "no proper divisor divides" to full primitivity
- `primitive_prime_two_mul_prime`: The complete n = 2p case

## 4. Discussion (Scientific American style)

### Every Fibonacci Number Carries a Unique Signature

Imagine the Fibonacci sequence as an ever-growing family tree of numbers:
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ...

Each Fibonacci number F(n) can be factored into primes—its "DNA." For
instance, F(12) = 144 = 2⁴ × 3², and F(7) = 13 is itself prime.

Carmichael's theorem, proved in 1913, says something remarkable: starting
from n = 13, every Fibonacci number carries at least one *new* prime
factor—a prime that has never appeared in any earlier Fibonacci number
that divides it. This new prime is the number's "genetic fingerprint,"
unique to that position in the sequence.

Think of it this way: F(12) = 144 shares all its prime factors (2 and 3)
with smaller Fibonacci numbers (F(3) = 2 and F(4) = 3). It has no
fingerprint of its own—it's the last Fibonacci number with this property.
From F(13) = 233 onward, every Fibonacci number introduces at least one
prime that is entirely its own.

### The Lucas Companion Trick

The proof for the simplest cases uses a beautiful algebraic identity.
When n = 2p for a prime p, we can write:

F(2p) = F(p) × L(p)

where L(p) = 2F(p+1) − F(p) is the "Lucas companion." The magic is that
F(p) and L(p) share almost no prime factors—their greatest common
divisor divides 2. So any odd prime dividing L(p) is completely new and
doesn't appear in F(p). Since p is prime, a quick analysis of divisors
forces this new prime's "birth index" to be exactly 2p.

### Connections and Future Directions

Carmichael's theorem is a special case of the broader Zsygmondy–Birkhoff–
Vandiver theorem for Lucas sequences, which itself generalizes to
algebraic number fields. The primitive part Ψ_n of F(n) connects to
cyclotomic polynomials evaluated at the golden ratio—a bridge between
combinatorics and algebraic number theory.

Formalizing the full theorem in Lean 4 would establish a reusable pattern
for lifting computational small-case checks to infinite results via
p-adic valuation control, with applications to:

1. Formal verification of primality certificates
2. Certified bounds in Diophantine geometry
3. Machine-verified algebraic number theory

## 5. References

1. R. D. Carmichael, "On the numerical factors of the arithmetic
   forms αⁿ ± βⁿ," *Annals of Mathematics* 15 (1913), 30–48.

2. K. Zsygmondy, "Zur Theorie der Potenzreste," *Monatshefte für
   Mathematik und Physik* 3 (1892), 265–284.

3. Y. Bilu, G. Hanrot, P. M. Voutier, "Existence of primitive divisors
   of Lucas and Lehmer numbers," *J. reine angew. Math.* 539 (2001), 75–122.
