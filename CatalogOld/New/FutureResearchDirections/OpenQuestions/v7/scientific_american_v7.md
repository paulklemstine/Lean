# The Secret Lives of Numbers: How Ancient Mathematics Could Break Modern Encryption

*A machine-verified journey from Fibonacci's rabbits to the foundations of internet security*

---

## The Code That Guards Your Secrets

Every time you check your bank balance, send a private message, or enter a password online, a mathematical riddle stands between your data and the world. The riddle is deceptively simple: given a large number — say, one with 600 digits — find the two prime numbers that multiply together to make it.

For humans and classical computers, this problem is essentially impossible for large numbers. That impossibility is the bedrock of RSA encryption, the system that has protected digital communications for nearly half a century.

But what if there were hidden mathematical structures — woven into the very fabric of numbers — that could unravel this protection? A growing body of research, now backed by over 130 computer-verified proofs, suggests that such structures exist, lurking in places mathematicians have been studying for centuries.

## The Fibonacci Connection

In 1202, Leonardo of Pisa — better known as Fibonacci — posed a simple puzzle about rabbit populations. The sequence that emerged, 1, 1, 2, 3, 5, 8, 13, 21, ..., where each number is the sum of the previous two, has since been found in sunflower spirals, galaxy arms, and financial markets.

Now researchers have discovered a startling connection to cryptography. Take any prime number p (other than 2 and 5), and compute F(p) — the p-th Fibonacci number. Square it and divide by p. The remainder is always 1.

This isn't just a curiosity. It's a compositeness test: if a number n fails this test — if F(n)² mod n ≠ 1 — then n is definitely composite, and the hunt for its factors can begin.

"What's remarkable," explains the research team, "is that we've proven this rigorously in a computer proof assistant. The proof requires constructing the algebraic closure of a finite field, applying the Frobenius endomorphism, and using Fermat's little theorem in a way that's never been machine-verified before."

## The Divisor Sum Oracle

Perhaps the most striking result in the new work concerns a function mathematicians have studied for millennia: σ₁(n), the sum of all divisors of n. For example, σ₁(12) = 1 + 2 + 3 + 4 + 6 + 12 = 28.

The team has now formally proven that if you could somehow compute σ₁(n) efficiently, you could factor n instantly. The logic is elegant:

For n = p × q (two primes), σ₁(n) = 1 + p + q + pq. From this single number, you can recover p + q = σ₁(n) − n − 1, and since you know both p + q and p × q, the primes are the roots of a simple quadratic equation. The discriminant is always a perfect square — (p − q)² — so the factors pop out immediately.

This means that computing σ₁(n) is exactly as hard as factoring n. Not approximately — exactly. And they've extended this to products of three primes: σ₁(pqr) = 1 + p + q + r + pq + pr + qr + pqr.

## Energy Landscapes and the Geography of Divisors

Imagine plotting the "energy" of each number from 1 to N, where the energy at position x is simply the remainder when N is divided by x. The resulting landscape is jagged and irregular, but it has a beautiful property: the valleys — the points where the energy drops to zero — are precisely the divisors of N.

The new research proves that these zero-energy points are genuine local minima in a rigorous mathematical sense, that the discrete "curvature" at each divisor is always non-negative, and that the landscape can be studied using Morse theory — a branch of topology that connects the shape of a surface to the topology of the space it lives in.

"Think of it like a topographic map," one researcher explains. "The divisors of N are the low points, and the energy landscape tells you exactly where they are. If you could efficiently navigate this landscape, you could factor any number."

## Perfect Numbers: A 2,300-Year-Old Mystery

Euclid proved around 300 BCE that if 2ᵖ − 1 is prime, then 2ᵖ⁻¹(2ᵖ − 1) is "perfect" — its divisors sum to twice itself. (The smallest examples: 6, 28, 496, 8128.)

Euler proved the converse 2,000 years later: every even perfect number has this form. The new work has now formalized key steps of Euler's direction:

- The "key equation": for an even perfect 2ᵏ · m with m odd, (2ᵏ⁺¹ − 1) · σ₁(m) = 2ᵏ⁺¹ · m
- The Mersenne factor must divide m: (2ᵏ⁺¹ − 1) | m
- And m must be prime: σ₁(m) = m + 1 characterizes primes

These proofs, verified line by line by a computer, bring us closer to a full formalization of one of number theory's most beautiful classical results.

Whether odd perfect numbers exist remains the oldest unsolved problem in all of mathematics.

## Quaternion Factoring: Beyond Two Squares

In 1770, Lagrange proved that every positive integer can be written as a sum of four squares: 7 = 1² + 1² + 1² + 2², for instance. The new work exploits this universality.

Two different four-square representations of the same number N are connected by the Euler identity — a 16-term algebraic miracle that makes the product of two sums-of-four-squares into another sum of four squares. By computing cross-terms between different representations and taking GCDs with N, factors emerge.

The researchers have proven this works for composites that can't be expressed as sums of two squares — a class of numbers that previous algebraic factoring methods couldn't touch.

## The Pisano Period: Fibonacci Meets the Chinese Remainder Theorem

The Fibonacci sequence modulo any number m repeats with a period called the Pisano period π(m). For example, the Fibonacci numbers mod 2 cycle as 0, 1, 1, 0, 1, 1, ... with period 3.

The team has now proven that for coprime m₁ and m₂, the Pisano period of their product divides the least common multiple of their individual periods: π(m₁m₂) | lcm(π(m₁), π(m₂)).

For a semiprime N = pq, this means computing π(N) and examining its divisors can reveal the individual Pisano periods π(p) and π(q), which in turn constrain the factors. A computational demo successfully factors numerous semiprimes using this approach.

## Machine-Verified Mathematics

What sets this research apart is its rigor. Every theorem — from the Fibonacci square criterion to the σ₁ reduction chain — is proven in Lean 4, a programming language designed for mathematical proof. The computer checks every logical step, every algebraic manipulation, every case distinction.

"In traditional mathematics, errors can hide in 'obvious' steps for decades," notes the team. "With machine verification, if the proof compiles, it's correct. Period."

The project now comprises over 130 verified theorems across dozens of Lean files, with 45 new results in the latest version alone.

## What's Next?

The research opens several exciting avenues:

- **Can the Pisano period be computed efficiently?** If so, it would give a new factoring algorithm fundamentally different from existing methods.
- **What do the "barcode diagrams" of energy landscapes look like?** Persistent homology — a tool from topological data analysis — could reveal hidden structure.
- **Can quantum computers exploit quaternion representations?** A quantum search over four-square decompositions might factor numbers faster than any known classical algorithm.
- **Do neural networks learn σ₁?** If a neural network could predict even an approximate value of σ₁(N) from the binary digits of N, it would break RSA.

The mathematics of factoring is far from exhausted. In fact, the more we look, the more connections we find — between 800-year-old number sequences, 2,300-year-old theorems about perfect numbers, and the encryption systems that guard our digital lives today.

---

*The complete codebase, including all Lean proofs, Python demonstrations, and SVG visualizations, is available in the Gravitational Factoring Research repository.*
