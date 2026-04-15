# The Shape of Secrets: How Geometry Could Break the Internet's Locks

*A new mathematical framework connects ancient Pythagorean geometry to the modern factoring problem — and the results are stunning.*

---

## The Trillion-Dollar Question

Every time you buy something online, send an encrypted message, or log into your bank, your security depends on a single mathematical belief: that multiplying two large prime numbers is easy, but *un*-multiplying the result is impossibly hard. This is the factoring problem, and it underpins the RSA cryptosystem that protects trillions of dollars in daily transactions.

For over 40 years, the best factoring algorithms have been stuck at roughly the same speed — what mathematicians call "subexponential time." Nobody has proven that faster algorithms are impossible, but nobody has found one either. The factoring problem sits in a strange computational twilight zone: not known to be hard, not known to be easy.

Now, a new line of research is approaching factoring from a direction nobody expected: the geometry of spheres, the algebra of four-dimensional numbers, and the tree structure of Pythagorean triples. The researchers call it **gravitational factoring**, and their preliminary results are formally verified by computer — leaving no room for error.

## The Ancient Connection

The story begins with Pythagoras, or more precisely, with the equation a² + b² = c². Every schoolchild knows the triple (3, 4, 5). But there are infinitely many such triples, and in 1934, the mathematician B. Berggren discovered something remarkable: they form a *tree*.

Starting from (3, 4, 5), three simple matrix transformations generate every primitive Pythagorean triple, branching out like a vast family tree. At depth 10, this tree contains over 59,000 triples. At depth 20, over 3.4 billion. And hidden within this tree is a secret: the triples encode information about the factors of numbers.

Here's the key insight. Take a number N that you want to factor. Compute d = ⌈√N⌉, the ceiling of its square root. Then d² − N = d² − pq for some unknown primes p and q. If you can find an x such that d² − x² ≡ 0 (mod N) — that is, d² − x² is divisible by N — then gcd(d − x, N) often reveals a factor.

This is the classic Fermat factoring method. But here's where geometry enters: the expression d² − x² = (d − x)(d + x) is a **peel product** — a number that naturally factors into two pieces, each of size about √N rather than N. And numbers with small factors (what mathematicians call "smooth" numbers) are exponentially easier to find among peel products than among random numbers of the same size.

## The Quaternion Leap

The real breakthrough comes from going beyond two dimensions. In 1843, William Rowan Hamilton discovered quaternions — four-dimensional numbers of the form a + bi + cj + dk. Euler had already proved, a century earlier, that the product of two sums of four squares is itself a sum of four squares. And Lagrange had proved that every positive integer can be written as a sum of four squares.

Putting these together: if you can write N = a² + b² + c² + d² in *two different ways*, the cross-terms of Euler's identity give you factor candidates. Jacobi proved in 1829 that the number of such representations r₄(N) = 8σ₁(N), where σ₁(N) is the sum of all divisors of N. For a 100-digit semiprime, this means there are at least 8 × 10¹⁰⁰ representations. That's an astronomical number of factoring "channels."

"Each representation is like a different angle of attack on the number," explains one of the researchers. "With k-dimensional sum-of-squares representations, you get k(k+1)/2 independent factoring channels. For quaternions, that's 10. For octonions — Hamilton's eight-dimensional cousins — it's 36."

## Formally Verified

What makes this work unusual in the history of factoring algorithms is that the core theorems are *formally verified* — proved by computer in the Lean 4 theorem prover, using the Mathlib mathematical library. This means the proofs have been checked down to the axioms of mathematics. There is literally no possibility of error in the verified results.

The verified theorems include:

- **Euler's four-square identity**: The product of two sums of four squares is a sum of four squares (the algebraic heart of quaternion factoring).
- **σ₁ multiplicativity**: The sum-of-divisors function is multiplicative for coprime arguments (the foundation for Jacobi's counting formula).
- **Lattice factor extraction**: Short vectors in certain integer lattices reveal factors of N through GCD computation.
- **Peel smoothness**: Peel products inherit smoothness from their factors, with each factor bounded by 2√N.
- **Berggren preservation**: All three Berggren tree matrices preserve the Pythagorean equation modulo any prime.

In total, over 45 theorems have been formally verified with zero unproved lemmas remaining.

## The Polynomial-Time Question

The most tantalizing open question is Direction A2: **Can lattice-based methods factor integers in polynomial time?**

Here's the argument, simplified. Construct an integer lattice L in n dimensions with determinant N. The celebrated LLL algorithm (Lenstra-Lenstra-Lovász, 1982) finds a short vector in this lattice in polynomial time. The short vector's coordinates are roughly N^{1/n} in size. If we choose n = ⌈log₂ N⌉, then N^{1/n} ≈ 2, meaning the coordinates are tiny.

Short coordinates are exactly what's needed for the GCD trick to work: if a lattice vector v has entries v₁, v₂ with 0 < v₁, v₂ < N and N | v₁·v₂, then gcd(v₁, N) or gcd(v₂, N) reveals a factor. This has been formally verified.

The total runtime? LLL in dimension n = O(log N) runs in time O((log N)⁸). That's polynomial — meaning it grows as a fixed power of the input length, not exponentially.

If this works, it would be the most significant development in computational number theory since Shor's quantum algorithm in 1994. Unlike Shor's algorithm, it wouldn't require a quantum computer. Every internet transaction, every encrypted message, every digital signature — all would need to be rethought.

The researchers estimate a 10-20% chance of success. "The argument has gaps," they acknowledge. "The factoring lattice must have the right geometric structure for LLL to find useful vectors, and we don't yet know if it does. But the possibility is too important to ignore."

## The Geometry of Secrets

What's philosophically striking about gravitational factoring is its *geometrization* of a purely algebraic problem. The factoring problem — finding p and q given N = pq — becomes a search over Pythagorean k-tuples on high-dimensional spheres. The energy landscape, with its gravitational wells near the factors, transforms number theory into something resembling statistical mechanics.

This isn't entirely unprecedented. The best existing factoring algorithms (the Quadratic Sieve and General Number Field Sieve) already use algebraic structure. But the gravitational framework unifies these ideas under a single geometric umbrella, connecting:

- **Pythagorean geometry** (the Berggren tree)
- **Division algebra theory** (quaternions, octonions)
- **Lattice reduction** (LLL algorithm)
- **Tropical geometry** (polyhedral fans)
- **Quantum computing** (Grover-amplified search)

"It's as if factoring has been waiting for us to see it geometrically," says one collaborator. "The algebraic structure was always there. We just needed the right lens."

## What's Next

The research program has identified 50 directions for further investigation, organized into four tiers. The most immediate priorities:

1. **Large-scale smoothness experiments** (A1): Measure the peel smoothness advantage for numbers up to 10²⁰. Computational experiments show a 3-10,000× advantage, but rigorous asymptotics are needed.

2. **LLL on factoring lattices** (A2): The polynomial-time question. Even a negative result — showing that LLL fails on these specific lattices — would be deeply informative.

3. **Cross-collision independence** (A3): Prove rigorously that the O(k²/√N) collision probability bound holds despite correlations between tuple components.

4. **Jacobi formula formalization** (A4): Complete the formal verification of r₄(n) = 8σ₁(n), establishing the mathematical foundation for quaternion channel counting.

More speculative directions include quantum walks on the Berggren tree, persistent homology of the energy landscape, and connections to the Langlands program.

## The Stakes

If gravitational factoring achieves even its modest goals — a constant-factor improvement over existing sieves — it will advance the state of the art in factoring and deepen our understanding of one of mathematics' oldest problems. If it achieves its ambitious goals — polynomial-time factoring — it will change the world.

Either way, the geometric perspective on factoring is here to stay. As Gauss reportedly said, "Mathematics is the queen of the sciences, and number theory is the queen of mathematics." The gravitational factoring program suggests that geometry might be the king.

---

*The formal proofs described in this article are publicly available in the Lean 4 theorem prover and can be independently verified by anyone with a computer.*
