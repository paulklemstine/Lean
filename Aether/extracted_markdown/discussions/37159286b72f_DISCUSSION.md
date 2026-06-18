# When Fibonacci Numbers Guard Their Secrets

## How a century-old theorem about prime numbers reveals the deep structure of one of mathematics' most famous sequences

In 1913, the American mathematician Robert Daniel Carmichael proved something remarkable about Fibonacci numbers: starting from the 13th term onward, every Fibonacci number contains at least one "new" prime factor — a prime that has never appeared in any earlier Fibonacci number. This result, known as Carmichael's theorem on primitive prime divisors, has remained a cornerstone of number theory for over a century.

Now, a new formalization effort brings this classical result into the world of computer-verified mathematics, pushing the boundaries of what can be rigorously proved using automated proof assistants.

## The Fibonacci Sequence's Hidden Order

Most people know the Fibonacci sequence: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ... Each number is the sum of the two before it. But beneath this simple rule lies an astonishingly rich arithmetic structure.

Consider the prime factorizations:
- F(7) = 13
- F(14) = 377 = 13 × **29**

The number 29 divides F(14) but doesn't divide any earlier Fibonacci number. It's what mathematicians call a *primitive prime divisor* — a prime that makes its first appearance at exactly this position in the sequence.

Carmichael's theorem guarantees that such "newcomer" primes exist for every F(n) with n ≥ 13. The only exceptions are small: F(1) = F(2) = 1 (too small to have any prime factors), F(6) = 8 and F(12) = 144, where all prime factors (2 and 3) already appeared earlier.

## Why Does This Matter?

The existence of primitive prime divisors is intimately connected to how prime numbers interact with the Fibonacci sequence through an elegant concept called the *entry point*. For any prime p, its entry point α(p) is the position where p first shows up as a factor of a Fibonacci number. For example, the entry point of 29 is 14, because 29 first divides F(14).

A beautiful identity governs this relationship: the greatest common divisor of any two Fibonacci numbers equals the Fibonacci number at the GCD of their indices:

> gcd(F(m), F(n)) = F(gcd(m, n))

This means that if a prime p divides both F(m) and F(n), it must also divide F(gcd(m,n)). The entry point is the "master key" that unlocks exactly which Fibonacci numbers a prime can divide.

## The Formalization Challenge

Proving Carmichael's theorem in a computer proof assistant like Lean 4 is far more demanding than a traditional mathematical proof. Every logical step must be justified from first principles, with no hand-waving allowed.

The proof naturally splits into two parts:

**The easy part**: When n itself is prime, the argument is elegant and short. If p is any prime dividing F(n), then its entry point α(p) must divide n. But n is prime, so α(p) is either 1 or n. Since F(1) = 1 has no prime factors, α(p) must equal n, making p automatically primitive.

**The hard part**: When n is composite — like 14 = 2 × 7 or 15 = 3 × 5 — the proof requires much deeper machinery. A prime factor of F(n) might also divide some F(d) where d is a proper divisor of n, and we must show that at least one prime factor is genuinely new.

## The Doubling Formula Breakthrough

A key insight in the formalization uses Fibonacci's *doubling formula*:

> F(2n) = F(n) × L(n)

where L(n) = 2·F(n+1) - F(n) is called a Lucas number. This formula factorizes F(2n) into two pieces with a remarkable property: the greatest common divisor of F(n) and L(n) is at most 2.

For a prime p ≥ 7, F(p) is always odd (because Fibonacci numbers are even precisely when their index is divisible by 3, and primes ≥ 7 aren't divisible by 3). This means gcd(F(p), L(p)) = 1 — the two factors are completely coprime.

Any prime r dividing L(p) therefore cannot divide F(p), nor can it divide any F(d) where d divides p (since F(d) divides F(p)). Through the entry point theory, this forces r to be a primitive prime divisor of F(2p).

This clean argument handles all composite numbers of the form 2p where p is prime — numbers like 14, 22, 26, 34, 38, and infinitely many more.

## Computation Meets Proof

For the remaining composite numbers up to 100, the formalization takes a complementary approach: direct computational verification. For each composite n between 13 and 100, a specific primitive prime is identified and verified using Lean's `native_decide` tactic, which compiles propositions to machine code and checks them at full speed.

For example, the primitive prime 401 divides F(100) = 354,224,848,179,261,915,075, and the computer verifies in milliseconds that 401 doesn't divide any earlier Fibonacci number.

## The Frontier

The complete proof of Carmichael's theorem for ALL composite n requires the *Lifting-the-Exponent Lemma* for Fibonacci sequences — a deep result about how prime power divisibility grows as you multiply the index. Formalizing this lemma remains an open challenge in computer-verified mathematics, representing one of the frontiers where classical number theory meets modern proof technology.

The work presented here — combining mathematical insight with computational power — demonstrates a promising methodology for tackling such challenges. As proof assistants grow more powerful and mathematical libraries expand, results like Carmichael's theorem that have been trusted for over a century will gain a new kind of certainty: the absolute confidence that comes from machine verification.

---

*This work was carried out using Lean 4 with the Mathlib mathematical library, formalizing results from R.D. Carmichael's 1913 paper "On the numerical factors of the arithmetic forms α^n ± β^n."*
