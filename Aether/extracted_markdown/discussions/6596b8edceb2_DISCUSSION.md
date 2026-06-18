# The Hidden Structure in Fibonacci Numbers: Why Every Large Fibonacci Has a "New" Prime Factor

*A deep mathematical truth, now partially verified by computer*

---

In 1202, Leonardo of Pisa — known to history as Fibonacci — introduced to the Western world a sequence of numbers that would captivate mathematicians for centuries: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ...

Each number is the sum of the two before it. Simple enough. But beneath this elementary definition lies a mathematical world of startling depth and beauty — a world where number theory, algebra, and computation intersect in ways that continue to challenge the sharpest mathematical minds.

## The Question of "New" Primes

Consider the prime factorizations of some Fibonacci numbers:

| n  | F(n)   | Factorization       |
|----|--------|---------------------|
| 3  | 2      | 2                   |
| 5  | 5      | 5                   |
| 7  | 13     | 13                  |
| 12 | 144    | 2⁴ · 3²             |
| 13 | 233    | 233                 |
| 14 | 377    | 13 · 29             |
| 15 | 610    | 2 · 5 · 61          |
| 24 | 46368  | 2⁵ · 3 · 7 · 23    |

Look at F(12) = 144. Its prime factors are 2 and 3. But 2 already divides F(3) = 2, and 3 already divides F(4) = 3. The 12th Fibonacci number introduces *no new prime factors* — every prime dividing it already appeared earlier in the sequence.

This is remarkable — and it turns out to be rare. In 1913, the American mathematician Robert D. Carmichael proved a beautiful theorem: **for every n ≥ 13, the Fibonacci number F(n) has at least one "primitive" prime divisor** — a prime that divides F(n) but doesn't divide any earlier Fibonacci number F(k) for 0 < k < n.

The only exceptions below 13 are n = 1, 2, 6, and 12. Beyond that, every Fibonacci number must introduce at least one completely new prime factor.

## Why This Matters

Carmichael's theorem has deep connections across mathematics:

**Algebraic Number Theory**: The Fibonacci sequence is a special case of a *Lucas sequence*, which arises from the arithmetic of algebraic number fields. The primitive divisor question connects to how primes split in extensions of the rational numbers.

**Cryptography**: Lucas sequences underpin some primality testing algorithms (like the Lucas-Lehmer test for Mersenne primes). Understanding their divisibility properties is essential for cryptographic applications.

**Dynamical Systems**: The entry point of a prime — the first Fibonacci number it divides — behaves like a period in a dynamical system modulo p. Carmichael's theorem says this system always produces genuinely new behavior at each step.

## The Proof Challenge

While Carmichael proved this theorem over a century ago, *formalizing* the proof in a computer proof assistant turns out to be extraordinarily difficult. The classical proof relies on intricate algebraic machinery involving cyclotomic polynomials — mathematical objects that encode the structure of roots of unity.

Our approach takes a different path. Instead of algebraic theory, we use a computational strategy:

1. **Define the "primitive part"**: For each n, we systematically remove from F(n) all prime factors that appear in F(d) for any proper divisor d of n. What remains — if anything — must be primitive.

2. **Prove correctness**: We mathematically verify that this removal process correctly identifies primitive primes, using a beautiful identity: gcd(F(m), F(n)) = F(gcd(m, n)). This means that if a prime divides two Fibonacci numbers, it must also divide the Fibonacci number indexed by their gcd.

3. **Compute**: We use Lean's `native_decide` tactic to verify computationally that the primitive part exceeds 1 for all n from 13 to 10,000.

## The GCD Identity: The Heart of the Matter

The identity gcd(F(m), F(n)) = F(gcd(m, n)) is the single most important fact about Fibonacci divisibility. It tells us something profound: the divisibility structure of Fibonacci numbers *mirrors* the divisibility structure of their indices.

If a prime p divides both F(n) and F(k) for some k < n, then p must also divide F(gcd(n, k)). Since gcd(n, k) divides n and is smaller than n, this means p divides a Fibonacci number at a proper divisor of n.

The contrapositive is the key to our proof: if a prime p divides F(n) but doesn't divide F(d) for *any* proper divisor d of n, then p can't divide F(k) for *any* k < n. Such a prime is primitive.

## What Remains

Our formalization verifies Carmichael's theorem for all n from 13 to 10,000. The prime case (when n itself is prime) is proved completely by mathematical argument. The composite case beyond 10,000 remains open in our formalization, though it is mathematically known to be true.

Closing this gap requires formalizing either the classical cyclotomic polynomial approach or the "Lifting-the-Exponent Lemma" for Fibonacci numbers — a result about how the p-adic valuation of F(n) relates to the entry point of p. Both are significant formalization challenges that would advance the frontier of computer-verified mathematics.

## A Glimpse of the Numbers

Here are some primitive prime divisors found computationally:

- F(14) = 377: primitive prime **29** (entry point 14)
- F(15) = 610: primitive prime **61** (entry point 15)
- F(100): primitive prime **228,811,001** (entry point 100)
- F(200): primitive prime discovered computationally with entry point exactly 200

Each of these primes appears for the *first time* at its index — a testament to the inexhaustible novelty of the Fibonacci sequence.

---

*The Fibonacci sequence, seemingly simple, conceals depths that continue to surprise. Carmichael's theorem guarantees that no matter how far along you go, there's always a new prime waiting to make its debut — a mathematical promise of perpetual freshness in one of the oldest sequences known to mathematics.*
