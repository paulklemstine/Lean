# The Hidden Geometry of Prime Numbers: How Mathematicians Are Using Topology and Quaternions to Attack Factoring

*A Scientific American–Style Feature Article*

---

## The Problem That Guards Your Secrets

Every time you buy something online, send an encrypted message, or log into your bank, you're relying on a single mathematical assumption: that multiplying two large prime numbers together is easy, but finding those primes from their product is impossibly hard.

This is the integer factoring problem, and it's the foundation of RSA encryption — the system that protects trillions of dollars in commerce every day. If someone found a fast way to factor large numbers, the entire edifice of internet security would crumble overnight.

Now, a team of researchers has been approaching this ancient problem from a startlingly different angle: by treating numbers as landscapes, using the mathematics of shape and space to probe their hidden structure. Their work, formalized and verified by computer in the Lean 4 theorem prover, has produced over 145 machine-checked theorems connecting factoring to topics as diverse as the Fibonacci sequence, four-dimensional algebra, and the topology of energy landscapes.

Their latest breakthrough? A complete, computer-verified proof that every even perfect number has exactly the form that Euclid described over 2,300 years ago.

---

## Perfect Numbers: A 2,300-Year-Old Question Answered by Machine

A perfect number is one that equals the sum of its proper divisors. The number 6, for instance, is perfect because 1 + 2 + 3 = 6. So is 28 (1 + 2 + 4 + 7 + 14 = 28) and 496 and 8128.

Euclid proved that if 2^p - 1 is prime (a "Mersenne prime"), then 2^(p-1) × (2^p - 1) is perfect. Two thousand years later, Euler proved the converse: every *even* perfect number has exactly this form.

"The Euler direction is surprisingly tricky," explains the team. "You have to show that when you decompose an even perfect number, the pieces fit together in exactly one way."

Their formal proof, running to about 150 lines of Lean 4 code, goes through six precise steps:

1. Decompose the number as 2^k × m with m odd
2. Use the multiplicativity of the divisor sum to derive a key equation
3. Show that a specific Mersenne number divides m
4. Prove that the quotient must equal 1 (using a counting argument on divisors)
5. Conclude that m must be prime
6. Wrap everything up with the correct Mersenne prime structure

The computer checked every logical step. There is no room for error.

What about *odd* perfect numbers? Despite centuries of searching, none has ever been found. It's one of the oldest open problems in mathematics. The team verified computationally that no odd perfect number exists below 100, but the general question remains tantalizingly out of reach.

---

## The Energy Landscape: Seeing Factors as Valleys

Imagine plotting a mountain range where the height at position x equals the remainder when you divide N by x. Every divisor of N creates a valley — a point where the height drops to zero.

This "energy landscape," defined by E(x) = N mod x, turns factoring into a topological problem: find the valleys.

The team has formalized a complete mathematical framework for this landscape:

- **Divisors are exactly the zero-energy points** (formally proved)
- **The landscape has τ(N) valleys**, where τ(N) is the number of divisors
- **Sublevel sets grow monotonically**: as you raise the "water level," more and more of the landscape is submerged
- **The sum of all energies is bounded by N²**, giving control over the average "height"

"This is essentially persistent homology applied to number theory," the team explains. "We're tracking how the topology of the sublevel sets changes as the threshold increases. The birth time of each point tells you something about the factoring structure."

The key insight: divisors are born at time zero and persist forever. Non-divisors appear later. This creates a natural filtration that connects the arithmetic of N to the topology of its energy landscape.

---

## Fibonacci Numbers: Nature's Secret Factoring Tool

The Fibonacci sequence — 0, 1, 1, 2, 3, 5, 8, 13, 21, ... — is famous for appearing in sunflower spirals, pinecone patterns, and the breeding of rabbits. Less well known is its deep connection to prime numbers.

The team has formalized a remarkable fact: for any prime p (other than 2 and 5), the square of the p-th Fibonacci number F(p) leaves a remainder of 1 when divided by p. In symbols: F(p)² ≡ 1 (mod p).

The contrapositive gives a compositeness certificate: if you compute F(n)² mod n and get something other than 1, you've *proved* that n is composite — without finding any factors!

But there's a catch. Some composite numbers slip through the test. These "Fibonacci pseudoprimes" mimic primes by satisfying F(n)² ≡ 1 (mod n) despite being composite. How many are there?

"This is one of the most exciting open questions," says the team. "Our computational experiments suggest the density of Fibonacci pseudoprimes among composites tends to zero, but proving it requires deep results about primitive divisors of Fibonacci numbers."

### The Pisano Period Connection

When you reduce the Fibonacci sequence modulo a number m, it becomes periodic. The period π(m) — called the Pisano period — connects factoring to the structure of this periodicity.

The team proved formally that for coprime m₁ and m₂, the Pisano period of their product relates to the individual periods via the least common multiple. This means that computing π(N) for a semiprime N = pq reveals information about the factors p and q.

"It's like listening to two musical notes played together," the team explains. "The combined period tells you something about the individual frequencies."

---

## Quaternions: Factoring in Four Dimensions

In the 1840s, William Rowan Hamilton invented quaternions — a four-dimensional extension of complex numbers. What he couldn't have known is that quaternion arithmetic would one day connect to integer factoring.

The key is the Euler four-square identity: the product of two numbers, each expressed as a sum of four squares, is itself a sum of four squares. The team proved this formally as norm multiplicativity of the Hamilton product.

By Lagrange's theorem (also formalized), every positive integer is a sum of four squares. So every composite number N = pq has representations as four squares, and the quaternion structure of these representations can reveal the factors.

"It's like a holographic encoding," the team explains. "The factoring information is distributed across the four-dimensional quaternion structure."

The Brahmagupta-Fibonacci identity provides the two-dimensional version: (a² + b²)(c² + d²) = (ac - bd)² + (ad + bc)². This was known to ancient Indian mathematicians and shows that the product of two sums of two squares is always a sum of two squares.

---

## The Wall-Sun-Sun Conjecture: Primes That Don't Exist (Probably)

In 1992, Zhi-Hong Sun and Zhi-Wei Sun proved a remarkable result: if Fermat's Last Theorem fails for a prime p, then p must satisfy a specific condition involving Fibonacci numbers — namely, p² divides F(p-1). Such primes are called "Wall-Sun-Sun primes."

Since Andrew Wiles proved Fermat's Last Theorem in 1995, we know it never fails for any prime. But the Sun brothers' work raises a fascinating question: do Wall-Sun-Sun primes exist at all?

Despite searching up to 10^13, no one has ever found one. The team has formalized the conjecture and proved several supporting results:

- **Cassini's identity**: F(n)² - F(n-1)·F(n+1) = (-1)^(n+1)
- **Entry point bounds**: The smallest k with p | F(k) divides either p-1 or p+1
- **Wieferich primes**: The only known Wieferich primes are 1093 and 3511

"Wall-Sun-Sun primes, if they exist, would be extraordinarily rare," the team notes. "Their connection to both Fibonacci numbers and Fermat's Last Theorem makes them one of the most intriguing objects in number theory."

---

## Machine-Verified Mathematics: No Errors Allowed

What sets this research apart is its methodology. Every theorem is not just proved — it's *formally verified* by a computer.

The team uses Lean 4, a proof assistant that checks every logical step with mathematical rigor. Unlike a human proof, which might contain subtle errors or hidden assumptions, a Lean proof is guaranteed to be correct (modulo the small, well-understood axiom base of the system).

"We've verified over 145 theorems across 13 Lean files," the team reports. "When we say something is proved, we mean a computer has checked every single logical inference."

This isn't just academic perfectionism. As mathematics becomes more complex and proofs stretch to hundreds of pages, the risk of errors grows. Formal verification provides an absolute guarantee of correctness.

---

## What's Next?

The team has identified 95 research directions, ranging from the immediately tractable to the deeply speculative:

**Near-term goals** (3-6 months):
- Complete formalization of the Jacobi four-square formula r₄(n) = 8σ₁_no4(n) via theta functions
- Prove the Carmichael primitive divisor theorem for Fibonacci numbers
- Establish the Hurwitz quaternion ring as a Euclidean domain

**Medium-term goals** (6-18 months):
- Formalize persistent homology barcodes for the energy landscape
- Prove density bounds for Fibonacci pseudoprimes
- Connect σ₁ computation to lattice shortest vector problems

**Long-term dreams**:
- Quantum algorithms exploiting four-square representations
- Neural ODE verification for gradient descent on the energy landscape
- Tropical geometry approaches to factoring

"Every theorem we prove opens up five new questions," the team reflects. "The more we understand the mathematical structure of factoring, the more connections we discover."

Whether these connections will ultimately lead to a polynomial-time factoring algorithm remains one of the great open questions of mathematics and computer science. But the journey — verified step by verified step — is revealing a mathematical landscape of remarkable beauty and depth.

---

*The team's Lean 4 code, Python demonstrations, and SVG visualizations are available in the project repository.*
