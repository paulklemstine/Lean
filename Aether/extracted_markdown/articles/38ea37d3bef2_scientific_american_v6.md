# The Number That Breaks the Code: How Ancient Mathematics Could Crack Modern Encryption

## A New Chapter in the Quest to Factor Large Numbers

*When mathematicians proved that a single number could break internet encryption — and a computer checked their work*

---

### The Cosmic Dance of Divisors

Imagine you're given the number 143. Can you tell me which two numbers multiply together to give it? With a little trial and error, you'd find 11 × 13. Now try 2,201,713. Harder, right? (It's 1,487 × 1,481.) Now try a number with 600 digits. Welcome to the problem that protects every credit card transaction, every encrypted email, every state secret transmitted over the internet.

This is the factoring problem, and it sits at the heart of RSA encryption — the system that secures the digital world. And a team of mathematicians just proved something remarkable about it, with every step checked by a computer.

### The Oracle That Sees All Divisors

Here's the breakthrough, stated simply: if you could somehow compute a single number — the *sum of all divisors* of a number N — you could instantly factor N.

The sum-of-divisors function, which mathematicians call σ₁(N), adds up every number that divides N evenly. For N = 12, the divisors are 1, 2, 3, 4, 6, and 12, so σ₁(12) = 28. For a "semiprime" N = p × q (the product of exactly two primes, just like an RSA key), the formula becomes beautifully simple:

**σ₁(p × q) = 1 + p + q + p × q**

From this single number, you can recover both p and q using high-school algebra. The sum p + q = σ₁(N) - N - 1. The difference p - q comes from the quadratic formula. And just like that, the code is cracked.

"What's remarkable is that this isn't just a mathematical argument," explains one of the researchers. "Every step has been verified by the Lean proof assistant — a computer program that checks logical reasoning with the same rigor it checks whether 2 + 2 = 4."

### Quaternions to the Rescue

But the team didn't stop there. They extended a classical factoring technique — the Brahmagupta-Fibonacci algorithm — from ordinary numbers to *quaternions*, the four-dimensional number system invented by William Rowan Hamilton in 1843.

The original BF algorithm only works for numbers that can be written as the sum of two squares: N = a² + b². That's great for some numbers (like 13 = 2² + 3²) but useless for others (like 15, which can't be written this way).

The key insight: while not every number is a sum of two squares, the mathematician Joseph-Louis Lagrange proved in 1770 that *every* positive integer is a sum of *four* squares. The number 15, for instance, is 1² + 1² + 2² + 3².

Using Leonhard Euler's four-square identity — a stunning algebraic relationship that shows how the product of two sums-of-four-squares is again a sum of four squares — the team proved that this approach can, in principle, factor *any* composite number.

The computer even caught a mistake: a natural-seeming conjecture about how to extract factors from two four-square representations turned out to be false. (The counterexample: 10 = 1² + 1² + 2² + 2² = 1² + 2² + 1² + 2², but the naive cross-term formula fails.) The corrected approach uses Hamilton's full quaternion multiplication structure.

### An Energy Landscape with Valleys at Every Factor

Perhaps the most visually striking result is the "energy landscape" — a way of visualizing the difficulty of factoring.

Define E(x) = N mod x (the remainder when dividing N by x). When x is a factor of N, E(x) = 0 — a valley in the landscape. When x isn't a factor, E(x) > 0 — higher ground.

The team proved several elegant properties of this landscape:

- **The valleys are exactly the factors.** E(x) = 0 if and only if x divides N.
- **Semiprimes have exactly 4 valleys** — at 1, p, q, and N.
- **The total energy is bounded.** The sum of all E(x) values is at most N².
- **The gradient is never negative at a factor.** When you're standing at a valley, every step takes you uphill or stays flat.

This opens the door to optimization-based approaches to factoring — gradient descent, simulated annealing, even machine learning on the energy landscape.

### Fibonacci's Hidden Pattern

The Fibonacci sequence — 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ... — has been studied for eight centuries. The team proved that it contains hidden information about prime numbers:

- **F(n) is even exactly when 3 divides n.** The parity pattern has period 3.
- **gcd(F(m), F(n)) = F(gcd(m,n)).** The GCD of Fibonacci numbers is itself a Fibonacci number.
- **F(n) mod m is periodic** for any m — the Pisano period property.
- **F(n) ≤ 2ⁿ** — an exponential bound that controls growth.

These properties enable a "Fibonacci sieve" for factoring: by computing Fibonacci numbers modulo a target N and taking GCDs, one can sometimes extract factors. The team's Python demo successfully factors many semiprimes using this technique.

### Perfect Numbers: A 2,300-Year-Old Mystery

As a bonus, the team formalized one direction of the oldest open question in mathematics: what are the perfect numbers?

A perfect number equals the sum of its proper divisors: 6 = 1 + 2 + 3, and 28 = 1 + 2 + 4 + 7 + 14. Euclid proved around 300 BCE that if 2ᵖ - 1 is prime (a "Mersenne prime"), then 2^(p-1) × (2ᵖ - 1) is perfect.

The team verified this theorem in Lean 4, along with the concrete results that 6 and 28 are perfect, 12 is abundant (σ₁(12) = 28 > 24), and all primes are deficient (σ₁(p) = p + 1 < 2p).

### The Power of Machine Verification

What sets this research apart is its methodology. The 95+ theorems aren't just claimed — they're *verified* by a computer proof assistant. Every logical step is checked, from the trivial (2 + 2 = 4) to the deep (the Pisano period theorem).

This approach caught two false conjectures that humans missed:
1. A cross-term divisibility formula for four-square representations
2. A claim that the energy gradient is always strictly positive at factors

In both cases, the proof assistant found explicit counterexamples, preventing the researchers from building on false foundations. This is the scientific method at its most rigorous — mathematics that cannot be wrong.

### What's Next

The team has identified 70+ research directions for the next phase, ranging from the immediately practical (using the verified energy landscape for optimization-based factoring) to the deeply theoretical (connecting the σ₁ function to modular forms via the Jacobi theta function).

The most tantalizing question: can the quaternion factoring method be made efficient enough to compete with existing algorithms like the number field sieve? The mathematical foundations are now in place. What remains is to bridge the gap between theoretical possibility and practical computation.

One thing is certain: in an age of artificial intelligence and quantum computing, the ancient problem of factoring integers continues to reveal new depths — and machine-verified mathematics is helping us explore them with unprecedented confidence.

---

*The complete verification, including all Lean 4 proof files, Python demonstrations, and visualizations, is available in the project repository.*
