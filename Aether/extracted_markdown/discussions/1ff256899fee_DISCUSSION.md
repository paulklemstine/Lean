# The Hidden Primes in Fibonacci's Sequence

*How a 1913 theorem reveals that every sufficiently large Fibonacci number carries a unique prime signature*

---

When Leonardo of Pisa introduced his famous sequence in 1202 — 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ... — he probably didn't imagine that mathematicians would still be uncovering deep structure in it 800 years later. Yet in 1913, the American mathematician Robert Carmichael proved something remarkable: starting from the 13th Fibonacci number onward, each one contains a "new" prime factor that has never appeared before in the sequence.

## A Prime Discovery

Consider the Fibonacci numbers and their prime factorizations:

| n | F(n) | Factorization | New Prime |
|---|------|---------------|-----------|
| 1 | 1 | — | — |
| 2 | 1 | — | — |
| 3 | 2 | 2 | 2 |
| 4 | 3 | 3 | 3 |
| 5 | 5 | 5 | 5 |
| 6 | 8 | 2³ | *none!* |
| 7 | 13 | 13 | 13 |
| 12 | 144 | 2⁴ × 3² | *none!* |
| 13 | 233 | 233 | 233 |
| 24 | 46368 | 2⁵ × 3² × 7 × 23 | 23 |

Notice something: F(6) = 8 = 2³ introduces no new prime — 2 already appeared in F(3). Similarly, F(12) = 144 = 2⁴ × 3² uses only primes from F(3) and F(4). But from F(13) onward, every Fibonacci number introduces at least one brand-new prime factor. Carmichael proved this is not a coincidence — it's a theorem.

## The GCD Identity: Fibonacci's Hidden Structure

The key to understanding why this works lies in a beautiful identity discovered in the 19th century:

**gcd(F(m), F(n)) = F(gcd(m, n))**

In words: the greatest common divisor of two Fibonacci numbers is itself a Fibonacci number, corresponding to the GCD of their indices. This identity means that the Fibonacci sequence "remembers" the divisibility structure of the natural numbers.

For example, gcd(F(12), F(8)) = gcd(144, 21) = 3 = F(4) = F(gcd(12, 8)). The shared prime factors of F(12) and F(8) are exactly those of F(4).

## Why Primes Make It Easy

When n is prime, Carmichael's theorem is almost trivial. If p is a prime number and q is any prime dividing F(p), then q also divides F(gcd(p, k)) = F(1) = 1 for any k < p (since gcd(p, k) = 1 when p is prime). But no prime divides 1! So every prime factor of F(p) is automatically "new."

This is why F(13) = 233 (which is itself prime) trivially satisfies the theorem — its only prime factor, 233, can't appear in any earlier Fibonacci number.

## The Composite Case: Where It Gets Interesting

When n is composite, things are more subtle. Consider n = 24. Its divisors include 1, 2, 3, 4, 6, 8, 12. The Fibonacci numbers at these positions are:

F(1) = 1, F(2) = 1, F(3) = 2, F(4) = 3, F(6) = 8, F(8) = 21, F(12) = 144

Now F(24) = 46368 = 2⁵ × 3² × 7 × 23. The primes 2, 3, and 7 all appear in earlier Fibonacci numbers (F(3), F(4), and F(8) respectively). But 23? Its "entry point" — the first Fibonacci number it divides — is exactly F(24). The prime 23 is F(24)'s primitive divisor.

## The Exceptions: Why 6 and 12 Are Special

Carmichael identified exactly four exceptions: n = 1, 2, 6, and 12. These are the only indices where F(n) has *no* primitive prime divisor. For F(6) = 8 = 2³, the only prime is 2, which already divides F(3). For F(12) = 144 = 2⁴ × 3², both primes 2 and 3 appeared earlier. After n = 12, the exponential growth of Fibonacci numbers overwhelms the "recycling" of old primes.

## The Primitive Part: A Number-Theoretic Fingerprint

Mathematicians define the "primitive part" Φ(n) as the portion of F(n) contributed by its new prime factors. Using the Möbius function μ, it can be expressed as:

Φ(n) = ∏_{d | n} F(d)^{μ(n/d)}

Remarkably, Φ(n) ≈ φ^{φ(n)}, where φ = (1+√5)/2 ≈ 1.618 is the golden ratio and φ(n) is Euler's totient function. Since φ(n) ≥ 6 for all composite n ≥ 13, we get Φ(n) ≈ 1.618⁶ ≈ 18, ensuring the primitive part is always substantial.

## Formalizing the Proof

Our Lean 4 formalization proves Carmichael's theorem in three stages:

1. **Prime case**: A clean 5-line proof using the GCD identity
2. **Computational verification**: `native_decide` confirms the theorem for all composite n up to 10,000
3. **The frontier**: The remaining case (composite n > 10,000) requires the "Lifting-the-Exponent Lemma" for Fibonacci numbers — a result not yet in Lean's mathematical library

The computational verification is fascinating in its own right: for each composite n, we compute F(n) (numbers with thousands of digits) and strip away all factors shared with F(d) for proper divisors d. If anything remains, we've found a primitive divisor.

## Connections to Modern Mathematics

Carmichael's theorem connects to several active areas of research:

- **Zsygmondy's theorem**: The Fibonacci version is a special case of a general result about algebraic integers
- **ABC conjecture**: Primitive divisors are related to the radical of Fibonacci numbers
- **Cryptography**: The entry points of primes in the Fibonacci sequence connect to the Pisano period, used in some pseudorandom generators
- **Tropical geometry**: The "min-plus" structure of Fibonacci divisibility mirrors tropical algebraic operations

## The Bigger Picture

Carmichael's theorem tells us something profound: the Fibonacci sequence is not just growing — it's growing in a way that continually introduces new prime structure. Each F(n) for n ≥ 13 carries at least one prime that is uniquely "born" at that index. The primes threading through the Fibonacci sequence form an ever-expanding tapestry, with new colors appearing at every step.

In the age of computer-verified mathematics, we can now confirm such theorems with absolute certainty — at least up to any finite bound. The challenge of extending our formal proof beyond n = 10,000 to all natural numbers highlights both the power and the current limitations of interactive theorem proving. The mathematics is settled; the formalization frontier continues to advance.
