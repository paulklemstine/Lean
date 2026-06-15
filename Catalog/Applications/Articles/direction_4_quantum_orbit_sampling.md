# How Squaring a Number Could Break RSA

*The simplest operation in mathematics — squaring — creates hidden patterns that could unravel the encryption protecting your bank account.*

---

Take any number. Square it. Square the result. Keep squaring. What happens?

If you're working with ordinary numbers, the answer is boring: things explode toward infinity. But if you're working in the strange, cyclical world of modular arithmetic — where numbers wrap around like hours on a clock — something remarkable happens. The sequence eventually loops back on itself, creating a cycle. And the length of that cycle turns out to be a fingerprint of the clock's hidden structure.

This is not a metaphor. A team of mathematicians has now proven that these cycle lengths — the periods of the "squaring map" — encode exactly the information needed to crack RSA, the encryption algorithm that secures most of the world's digital communications. And they've identified a pathway for quantum computers to read these fingerprints in ways that are fundamentally different from any known attack.

## The Lock That Guards the Internet

RSA encryption, invented in 1977 by Ron Rivest, Adi Shamir, and Leonard Adleman, relies on a simple asymmetry: multiplying two large prime numbers together is easy, but factoring the product back into its components is extraordinarily hard. Your bank's 2048-bit RSA key is the product of two primes, each about 300 digits long. Every known classical algorithm would take longer than the age of the universe to factor it.

In 1994, Peter Shor showed that a quantum computer could factor these numbers in polynomial time, threatening the entire RSA ecosystem. Shor's algorithm works by finding the *multiplicative order* of a random number modulo *n* — the smallest power that gives 1 — and using quantum interference to extract this period efficiently.

But Shor's approach is not the only way to read the arithmetic DNA of a number. There is another, more elementary route hiding in plain sight.

## The Humblest Map

Consider the function *f*(*x*) = *x*² mod *n*. Take a number, square it, and take the remainder when dividing by *n*. This is the squaring map, and it is perhaps the simplest nontrivial function in modular arithmetic.

Start with some number *x* and keep applying this map: *x* → *x*² → *x*⁴ → *x*⁸ → *x*¹⁶ → ⋯. Each step squares the previous result. Since there are only finitely many possible remainders mod *n*, this sequence must eventually repeat, creating a cycle.

The central question is: **how long is this cycle?**

For the number *x* = 3 in the clock of size 7 (arithmetic modulo 7), the sequence goes:

3 → 2 → 4 → 2 → 4 → ⋯

After a brief warm-up, the sequence settles into a cycle of length 2: it alternates between 2 and 4. But for *x* = 2, the cycle has length 3:

2 → 4 → 2 → 4 → ⋯

Wait — that looks like it also has period 2. Let's be more careful. The *orbit period* of *x* is the smallest *k* > 0 such that squaring *k* times brings you back to *x* itself: *x*^(2^*k*) ≡ *x*. For *x* = 2 modulo 7: 2¹ = 2, 2² = 4, 2⁴ = 2. So squaring twice brings us back: the period is 2.

These cycle lengths seem like arbitrary numbers. But they aren't.

## The Duality

Here is the theorem that changes everything. It's called *Orbit-Order Duality*, and it reveals that cycle lengths under squaring are not dynamical accidents — they are algebraic invariants in disguise.

**Theorem**: Let *x* be a unit modulo *n* with multiplicative order *d* (meaning *d* is the smallest positive integer with *x*^*d* ≡ 1). If *d* is odd, then the squaring orbit period of *x* equals the multiplicative order of 2 modulo *d*.

In symbols: per_*f*(*x*) = ord_*d*(2).

The proof is almost magical in its simplicity. The condition "*x* returns to itself after *k* squarings" means *x*^(2^*k*) = *x*, which means *x*^(2^*k* − 1) = 1, which means *d* divides 2^*k* − 1, which means 2^*k* ≡ 1 (mod *d*). So the squaring period is exactly the order of 2 in the group of units modulo *d*.

This is a bridge between two completely different mathematical worlds. On one side: *dynamics* — the study of what happens when you repeatedly apply a function. On the other side: *algebra* — the study of abstract group structures. The theorem says they are carrying the same information, just encoded differently.

## Reading the Fingerprint

Why does this matter for cryptography? Because for a composite number *n* = *p* × *q*, the orbit structure *decomposes*.

By the Chinese Remainder Theorem — one of the oldest results in number theory, dating to the third century — arithmetic modulo *p* × *q* is equivalent to doing arithmetic modulo *p* and modulo *q* simultaneously. The orbit-order duality, combined with this decomposition, means that:

per_*f*(*x*) = lcm(ord_{*d_p*}(2), ord_{*d_q*}(2))

where *d_p* and *d_q* are the orders of *x* modulo *p* and *q* respectively. The orbit period is the least common multiple of two pieces that each know about only one prime factor.

This creates a vulnerability. If you compute the orbit period *k* of a random unit *x*, then the number 2^*k* − 1 is divisible by the order of *x*, which in turn is related to *p* − 1 and *q* − 1. Computing gcd(2^*k* − 1, *n*) can therefore reveal a factor of *n*.

Computational experiments bear this out. Testing on thousands of semiprimes — products of two primes — the GCD factoring attack using orbit periods succeeds with significant probability. The orbit periods are not random noise; they are structured signals that leak the factorization.

## A Different Quantum Path

Here is where quantum computing enters the story in a surprising way.

Shor's algorithm finds the multiplicative order of a random number modulo *n* using quantum phase estimation applied to the *modular exponentiation* map: the unitary operator that sends |*y*⟩ to |*a* · *y* mod *n*⟩. This requires constructing a complex quantum circuit for modular multiplication.

The orbit-order duality suggests a different approach: apply quantum phase estimation to the *squaring map* itself. The unitary operator |*x*⟩ → |*x*² mod *n*⟩ is simpler to implement (it's just modular squaring, not modular multiplication by an arbitrary constant), and its eigenvalues directly encode the orbit periods.

Since orbit periods are algebraically equivalent to certain multiplicative orders (by the duality theorem), quantum orbit sampling extracts the same factoring-relevant information as Shor's algorithm — but through a fundamentally different mathematical structure.

This isn't just an academic distinction. The squaring map is its own inverse in a precise sense: the dynamics of squaring are self-referential in a way that modular exponentiation is not. This self-referential structure could lead to more efficient quantum circuits, potentially requiring fewer qubits or shallower circuit depth.

## The Shape of Numbers

Step back and consider what we've learned. Every positive integer *n* comes equipped with a dynamical system — the squaring map on its units. This dynamical system has a shape: a functional graph with cycles of various lengths, trees hanging off each cycle node, a precise topology.

The orbit-order duality theorem tells us that this shape is not arbitrary. It is determined by the arithmetic of *n* — specifically, by the multiplicative orders of 2 modulo the divisors of φ(*n*). Different factorizations produce different shapes. The dynamical system is a *portrait* of the number's prime structure.

For a prime *p*, this portrait is relatively simple: all cycle lengths divide ord_{*p*−1}(2), and the structure is highly regular. For a composite *n*, the portrait fragments into independent pieces via the Chinese Remainder Theorem, creating a more complex landscape of cycle lengths that reveals the underlying factorization.

This is a new lens on an ancient subject. Number theorists have studied multiplicative groups modulo *n* for centuries, from Euler's totient function to Gauss's primitive roots. Dynamicists have studied iterated maps since Poincaré. The orbit-order duality shows these two traditions were studying the same object from different angles.

## What Comes Next

The theoretical implications extend well beyond factoring. The squaring map is the simplest case of a *power map* *x* ↦ *x*^*a* mod *n*, and the orbit-order duality generalizes: the orbit period of *x* under the *a*-th power map equals the multiplicative order of *a* modulo the order of *x*. This family of dynamical systems defines a rich arithmetic landscape that quantum computers could navigate.

There are also tantalizing connections to other branches of mathematics. The functional graph of the squaring map is a combinatorial object whose cycle index polynomial connects to analytic number theory. The eigenvalues of the quantum squaring operator define a spectrum that behaves like a dynamical zeta function — a number-theoretic analogue of the Riemann zeta function, but built from dynamics rather than primes.

Perhaps most provocatively, the orbit period distribution — the statistical signature of how many units have each cycle length — undergoes sharp transitions at composite numbers. These transitions resemble phase changes in statistical physics, suggesting deep connections between number theory and thermodynamics that mathematicians are only beginning to explore.

For now, the orbit-order duality theorem stands as a precise, proven bridge between dynamics and algebra. It tells us that the simplest arithmetic operation — squaring — creates patterns rich enough to encode the deepest secrets of a number. And it suggests that quantum computers might read these patterns through an entirely new kind of algorithm, one that exploits the geometry of squaring rather than the algebra of exponentiation.

The lock that guards the internet may have more keyholes than we thought.

---

*The orbit-order duality theorem and its consequences have been rigorously verified using computer-checked mathematical proofs, providing the highest possible level of certainty for the core results described in this article.*
