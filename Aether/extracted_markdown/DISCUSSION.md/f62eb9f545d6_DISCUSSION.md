# The Hidden Structure of Fibonacci Numbers: Why Every Large Fibonacci Has a "New" Prime Factor

*A discussion of Carmichael's Primitive Divisor Theorem and its formalization*

---

In 1913, the American mathematician Robert D. Carmichael discovered something remarkable about Fibonacci numbers — those familiar numbers (1, 1, 2, 3, 5, 8, 13, 21, 34, ...) where each term is the sum of the two before it. He proved that starting from the 13th Fibonacci number, every single one introduces at least one entirely "new" prime factor that hasn't appeared in any earlier Fibonacci number.

## What Makes a Prime "Primitive"?

Consider the Fibonacci numbers with their prime factorizations:

| n  | F(n) | Factorization | New prime? |
|----|------|---------------|-----------|
| 3  | 2    | 2             | **2** (first appearance) |
| 4  | 3    | 3             | **3** |
| 5  | 5    | 5             | **5** |
| 6  | 8    | 2³            | No new prime! |
| 7  | 13   | 13            | **13** |
| 8  | 21   | 3 × 7         | **7** |
| 9  | 34   | 2 × 17        | **17** |
| 10 | 55   | 5 × 11        | **11** |
| 11 | 89   | 89            | **89** |
| 12 | 144  | 2⁴ × 3²      | No new prime! |
| 13 | 233  | 233           | **233** |
| 14 | 377  | 13 × 29       | **29** |

A prime p is called a *primitive divisor* of F(n) if p divides F(n) but doesn't divide any earlier Fibonacci number F(k) for 0 < k < n. Carmichael showed that the only exceptions — the only Fibonacci numbers without a new prime — are F(1), F(2), F(6), and F(12). From F(13) onward, there's always at least one brand-new prime.

## The Key Insight: A Hidden GCD Structure

The proof relies on a beautiful property that connects Fibonacci numbers to the greatest common divisor (GCD):

> **gcd(F(m), F(n)) = F(gcd(m, n))**

This formula, sometimes called the "strong divisibility" property, means that the Fibonacci sequence mirrors the divisibility structure of the integers themselves. If you want to know what F(12) and F(8) have in common, you just need to look at F(gcd(12, 8)) = F(4) = 3.

This leads to the concept of the *entry point* (or *rank of apparition*) of a prime p: the smallest positive integer k such that p divides F(k). By the GCD property, if p divides F(n), then the entry point of p must divide n. This means every prime factor of a Fibonacci number "knows about" the divisibility structure of its index.

## The Prime Case: Elegantly Simple

When n is prime, the proof is particularly elegant. If n is a prime number ≥ 13, then for any 0 < k < n, we have gcd(n, k) = 1 (since n is prime and k < n). So if a prime p divides both F(n) and F(k), it would also divide F(gcd(n, k)) = F(1) = 1. But no prime divides 1, giving us a contradiction. Therefore, *every* prime factor of F(n) is primitive when n is prime.

This argument works for all prime n ≥ 3, not just n ≥ 13. It tells us that Fibonacci numbers at prime indices are especially "rich" in new prime factors.

## The Composite Case: Where Things Get Deep

The hard part is showing that composite numbers n ≥ 14 also always yield new primes in F(n). This requires showing that the Fibonacci number F(n) can't be "explained away" entirely by prime factors that already appeared in F(d) for proper divisors d of n.

The proof strategy involves defining the *primitive part* of F(n) — the portion of F(n) that remains after removing all prime factors shared with smaller Fibonacci numbers F(d) for d dividing n. Carmichael's theorem amounts to showing this primitive part is always greater than 1 for n ≥ 13.

For our formalization, we verified this computationally for all composite n up to 50,000. The full theoretical proof for arbitrarily large composite n requires algebraic number theory — specifically, the theory of cyclotomic polynomials applied to the algebraic integers (1+√5)/2 and (1−√5)/2.

## Connections to Deeper Mathematics

Carmichael's theorem connects to several areas of modern mathematics:

**Algebraic Number Theory.** The Fibonacci numbers arise from the ring ℤ[(1+√5)/2], and the primitive part corresponds to the evaluation of cyclotomic polynomials at specific algebraic integers. The fact that these evaluations are always > 1 for n ≥ 3 follows from properties of roots of unity in the complex plane.

**Zsigmondy's Theorem.** Carmichael's result is a special case of a broader theorem about sequences of the form αⁿ − βⁿ. Zsigmondy proved in 1892 that such sequences (under mild conditions) always have primitive prime divisors, with only finitely many exceptions.

**Elliptic Curves.** Analogous "primitive divisor" questions arise for elliptic divisibility sequences, where the theory becomes much harder and remains an active area of research.

## The Formalization Challenge

Translating Carmichael's theorem into machine-verified mathematics (using the Lean 4 proof assistant) reveals the enormous gap between an argument that convinces a mathematician and one that convinces a computer. Our formalization required:

- Careful construction of the "coprime part" function that strips shared prime factors
- Proofs that this function preserves divisibility and achieves coprimality
- Computational verification via compiled native code for tens of thousands of cases
- The fundamental GCD identity for Fibonacci numbers (available in Mathlib)

The remaining challenge — proving the result for all composite n beyond our computational bound — would require formalizing either cyclotomic theory for Lucas sequences or the algebraic bound |α − ζβ| > 1 for primitive roots of unity ζ. This represents an interesting open formalization problem at the frontier of computer-verified number theory.

## A Living Theorem

Carmichael's theorem reminds us that even in the most familiar mathematical sequences, deep structural patterns await discovery. Every Fibonacci number from the 13th onward carries within it at least one prime factor that the sequence has never produced before — an endless source of mathematical novelty encoded in the simplest of recurrences: each number is the sum of the two before it.

---

*This discussion accompanies the Lean 4 formalization in `CarmichaelPrimitiveDivisor.lean`.*
