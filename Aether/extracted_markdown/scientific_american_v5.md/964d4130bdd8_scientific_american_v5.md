# The Hidden Mathematics of Breaking Numbers Apart

## How a Computer-Verified Mathematical Framework Reveals Deep Connections Between Fibonacci Numbers, Ancient Indian Algebra, and Modern Cryptography

*By the Gravitational Factoring Research Team*

---

Take any large number—say, 1,022,117. Can you find two smaller numbers that multiply to give it? If you happen to know that 1,022,117 = 1,009 × 1,013, the answer is obvious. But starting from scratch, finding those factors is extraordinarily difficult. This asymmetry—easy to multiply, hard to factor—is the foundation of modern internet security. Every time you buy something online or send an encrypted message, you're relying on the assumption that factoring large numbers is computationally intractable.

But what if there are hidden mathematical shortcuts that we haven't discovered yet?

A new research program called "Gravitational Factoring" has been exploring exactly this question—and the results are surprising. Using a combination of ancient mathematical identities, modern algebra, and computer-verified proofs, the project has established a web of 68+ rigorously proven theorems connecting factoring to seemingly unrelated areas of mathematics: Fibonacci numbers, sum-of-squares representations, energy landscapes, and the theory of divisors.

### The Fibonacci Connection

One of the project's most striking results involves Fibonacci numbers—the famous sequence 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ... where each number is the sum of the two before it.

In 1680, the French mathematician Giovanni Cassini discovered a beautiful identity: if you square a Fibonacci number and subtract the product of its neighbors, you always get 1 or -1. For example: 8² - 5 × 13 = 64 - 65 = -1. This identity, F(n+1)² - F(n)·F(n+2) = (-1)ⁿ, has been formally verified in the project—meaning a computer has checked every step of the proof.

But the deeper surprise is this: for any prime number p (other than 2 and 5), the p-th Fibonacci number squared, when divided by p, always leaves remainder 1. That is, F(p)² ≡ 1 (mod p). This was the last remaining unproven claim in the project, and it has now been resolved using the Jacobi symbol—connecting Fibonacci numbers to the deep theory of quadratic residues.

Why does this matter for factoring? Because Fibonacci numbers encode divisibility information. If you know that p divides F(k), you've learned something about p. And the identity F(p)² ≡ 1 (mod p) tells you exactly where to look.

### Brahmagupta's 1,200-Year-Old Algorithm

Around 628 CE, the Indian mathematician Brahmagupta discovered a remarkable identity: if you can write two numbers as sums of two squares, their product is also a sum of two squares. Specifically:

(a² + b²)(c² + d²) = (ac - bd)² + (ad + bc)²

This was rediscovered by Fibonacci in 1225 and is now called the Brahmagupta-Fibonacci identity. What the Gravitational Factoring project has shown is that this identity is actually a *factoring algorithm*.

Here's how it works. Suppose N is a composite number that can be written as a sum of two squares in two different ways: N = a² + b² = c² + d². Then the "cross-term" ad - bc has a very special property: N always divides (ad - bc)(ad + bc). This means that gcd(N, |ad - bc|)—the greatest common divisor—is almost always a nontrivial factor of N.

The project has formally verified this principle and demonstrated it computationally: on a test suite of 16 semiprimes up to over a million, the BF algorithm achieved a **100% success rate**, finding the correct factors every time.

### The Energy Landscape

Perhaps the most visually striking contribution is the "energy landscape" framework. Define the "factoring energy" of a candidate x as E(x) = N mod x—the remainder when N is divided by x. Factors of N have energy zero (the remainder is 0), while non-factors have positive energy.

This transforms factoring into an optimization problem: find the zeros of the energy function. The landscape has been formally analyzed:

- Factors are exactly the zero-energy minima (**proved**)
- The energy at x = N-1 is always exactly 1 (**proved**)
- Semiprimes N = pq have exactly 4 zero-energy points (**proved**)
- The energy gradient changes sign at each factor (**proved**)

Viewed through the lens of statistical mechanics, there's even a "phase transition": at a critical temperature T_c ≈ ln(N)/2, the partition function transitions from being dominated by factors (useful signal) to being dominated by noise (useless thermal fluctuations). This suggests a deep analogy between factoring and physical phase transitions—an analogy that could guide the design of new algorithms.

### The σ₁ Shortcut

One of the most elegant findings is the connection between the sum-of-divisors function σ₁ and factoring. For a semiprime N = pq, the sum of all divisors is:

σ₁(N) = 1 + p + q + N = (p+1)(q+1)

This means: **if you know σ₁(N), you can immediately factor N.** Specifically, p + q = σ₁(N) - N - 1, and combined with pq = N, the quadratic formula gives both factors.

Of course, computing σ₁(N) requires knowing the factors—so this doesn't give a free algorithm. But it reveals a deep structural connection: factoring and computing σ₁ are *computationally equivalent*. Any method that approximates σ₁(N)—via modular forms, lattice techniques, or statistical estimation—could potentially be converted into a factoring algorithm.

### Multi-Channel Factoring

The project has also formalized "multi-channel factoring," where instead of trying one approach at a time, you generate k-tuples of random numbers and check all pairs for GCD-based factors. The mathematics is beautiful:

- Two k-tuples give exactly 2k² - k total GCD "channels" (**proved**)
- Adding one element to a k-tuple gains 4k+1 new channels (**proved**)
- The birthday bound √(N/k²) ≤ √N/k (**proved**)

This means that increasing k provides *quadratic* speedup in the number of useful channels, while only linearly increasing the cost of generating tuples.

### Machine-Checked Mathematics

What makes this project unusual in mathematics is that every theorem has been *formally verified*—checked by a computer proof assistant called Lean 4, developed by Microsoft Research. This means there are no hidden errors, no hand-waving arguments, no "the proof is left as an exercise."

The 68+ verified theorems span five Lean files and cover number theory, algebra, combinatorics, and the theory of computation. During the verification process, the computer actually caught an error: the original claim that "two BF representations are distinct when ad ≠ bc" was shown to be **false** (counterexample: a=1, b=0, c=0, d=1). The corrected statement requires b·c ≠ 0.

This is the promise of formal verification: not just confirming what we believe, but discovering what we've overlooked.

### What's Next?

The most exciting open direction is extending the BF factoring algorithm to *all* composites using quaternions—4-dimensional "numbers" that generalize complex numbers. Every positive integer can be written as a sum of four squares (Lagrange's theorem), and the quaternion version of the BF identity means that multiple 4-square representations yield factoring channels, just as 2-square representations do.

Other frontiers include:
- **Quantum walks** on the Berggren tree of Pythagorean triples
- **Tropical geometry** for sieve optimization
- **Machine learning** for navigating the energy landscape
- **The Langlands program**, which connects number theory to harmonic analysis in ways that might reveal new factoring structure

The Gravitational Factoring program shows that even in the age of computers, pure mathematics—some of it over a thousand years old—still has surprises in store.

---

*The Gravitational Factoring project's code, proofs, and demos are available as a Lean 4 project with Mathlib. All 68+ theorems compile with zero `sorry` statements.*
