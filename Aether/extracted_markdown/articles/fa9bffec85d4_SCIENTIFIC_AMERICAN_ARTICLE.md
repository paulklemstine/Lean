# The Computer That Proved 1,741 Theorems: How AI and Formal Math Are Rewriting the Rules of Certainty

*A Lean 4 project spanning 20 areas of mathematics shows that machine-verified proofs can scale — and may one day help crack the hardest open problems in mathematics.*

---

## The Promise of Perfect Proofs

What if you could be absolutely certain that a mathematical proof was correct — not "pretty sure," not "peer-reviewed by three experts," but *logically certain* down to the axioms?

That's the promise of **formal theorem proving**, a discipline where mathematicians write their proofs in a special programming language that a computer checks line by line, symbol by symbol. If the proof compiles, it's correct. Period.

In a new project pushing the boundaries of what's possible, researchers have formally verified **1,741 mathematical theorems** across **20 different areas of mathematics** — from number theory to quantum computing, from game theory to cryptography — all checked by a computer program called **Lean 4** against the massive **Mathlib** mathematical library.

The result is a sprawling, 16,000-line mathematical exploration that touches on some of the deepest questions in mathematics, including all seven of the famous **Millennium Prize Problems** — each worth $1 million for a correct solution.

---

## From Right Triangles to the Frontiers of Math

It all started with something ancient: **Pythagorean triples**.

You probably remember from school that 3² + 4² = 5². The triple (3, 4, 5) is the simplest example of a *primitive Pythagorean triple* — a right triangle with integer sides that share no common factor. What you might not know is that every such triple can be generated from (3, 4, 5) by multiplying by one of three special 3×3 matrices, forming an infinite **Berggren tree**.

This beautiful structure became the launchpad for an ambitious mathematical expedition. By pulling on the threads connecting Pythagorean triples to other areas of math, the project expanded into:

- **Algebraic geometry**: Pythagorean triples correspond to rational points on curves — the same objects at the heart of the Birch and Swinnerton-Dyer conjecture
- **Cryptography**: The number theory underlying PPTs is intimately connected to RSA encryption and Diffie-Hellman key exchange
- **Quantum computing**: The Berggren matrices, when taken modulo small primes, connect to quantum gate sets
- **Information theory**: The impossibility of lossless compression has a clean proof via the pigeonhole principle, itself a corollary of the project's combinatorial foundations

---

## What Does "Formally Verified" Actually Mean?

Traditional mathematical proofs are written in a mix of natural language and notation, relying on the reader to fill in gaps. Even published proofs in top journals sometimes contain errors that go undetected for years.

A **formal proof** is different. Every logical step is explicit and machine-checked. The computer verifies that each step follows from the axioms and previously proven results. There's no room for hand-waving, intuitive leaps, or subtle errors.

The Lean 4 proof assistant, developed by Microsoft Research and maintained by a global community, is one of the most powerful tools for this kind of work. Its mathematical library, **Mathlib**, contains over 100,000 formalized theorems — everything from basic arithmetic to advanced measure theory.

In this project, some highlights of what was formally verified include:

**A one-dimensional Brouwer fixed point theorem.** This classic result says that any continuous function mapping the interval [0,1] into itself must have at least one fixed point — a value x where f(x) = x. The formal proof uses the intermediate value theorem applied to g(x) = f(x) - x.

**Chebyshev's prime race bias.** Among primes up to 30, there are more primes congruent to 3 (mod 4) than to 1 (mod 4): 6 versus 4. This asymmetry, first noticed by Chebyshev in the 1850s, hints at deep structure in the distribution of prime numbers.

**The Cauchy-Davenport theorem in Z/7Z.** If you take two subsets A and B of integers modulo 7, the "sumset" A + B = {a + b : a ∈ A, b ∈ B} is always at least as large as |A| + |B| - 1 (or 7, whichever is smaller). This was verified computationally for specific sets.

**Cantor's theorem.** There is no surjection from any set to its power set — the foundation of our understanding of infinity.

---

## Touching the Millennium Problems

The project makes formal connections to all seven Clay Millennium Prize Problems:

1. **P vs NP**: Formalized the satisfiability problem for Boolean formulas and proved that the search space grows as 2^n. The compression impossibility theorem — proved via the pigeonhole principle — is a fundamental lower-bound technique in complexity theory.

2. **Riemann Hypothesis**: Verified the prime counting function π(n) for n up to 1000, computed Euler product factors, and demonstrated Chebyshev's bias phenomenon.

3. **Birch and Swinnerton-Dyer**: Formalized congruent number curves E_n: y² = x³ - n²x, verified their 2-torsion structure, and constructed rational points from Pythagorean triples.

4. **Yang-Mills**: Verified properties of the Pauli matrices (σ_x² = σ_z² = I) and the sl(2) Lie algebra structure.

5. **Navier-Stokes**: Computed the Sobolev critical exponent in 3D.

6. **Hodge Conjecture**: Verified the genus formula for plane curves and Euler characteristics.

7. **Poincaré Conjecture** (already solved by Perelman): Verified the Euler characteristic classification of surfaces.

Of course, none of these connections constitute proofs of the Millennium Problems themselves — those remain among the hardest open questions in mathematics. But they demonstrate that formal methods can handle the *surrounding infrastructure* needed for serious approaches.

---

## The Hard Parts: What Computers Still Can't Do

Not everything went smoothly. The **Sauer-Shelah lemma** — a fundamental result in combinatorics about "shattering" set systems — resisted all formalization attempts. Its proof requires a delicate induction with coordinate splitting that current automated tools can't handle.

Some theorems that look simple turn out to be unexpectedly difficult for computers. The variance decomposition formula Var(X) = E[X²] - E[X]² is trivial on paper but required careful handling of division and field operations in the formal setting.

And Brouwer's fixed point theorem in dimensions higher than 1 remains out of reach — it requires algebraic topology machinery (specifically, homology theory) that hasn't yet been formalized in Mathlib.

---

## From Pure Math to the Real World

The verified theorems have direct applications:

- **Cybersecurity**: The RSA and Diffie-Hellman verifications provide a foundation for formally verified cryptographic implementations — software that is provably correct, not just tested.

- **5G Communications**: The Hamming code perfection result and Singleton bound verification connect to the error-correcting codes that keep your phone calls clear.

- **Machine Learning**: The formalized Markov inequality and Cauchy-Schwarz inequality are the building blocks of learning theory bounds — the mathematics that tells us how much data an AI needs to learn reliably.

- **Control Systems**: Gronwall's inequality and stability criteria are the tools engineers use to prove that autopilots, self-driving cars, and industrial robots behave safely.

---

## What Comes Next

This project demonstrates that large-scale formal mathematics is no longer a pipe dream — it's a practical reality. With 1,741 verified theorems across 20 mathematical domains, we're beginning to see the outlines of a future where:

- **AI systems propose conjectures** and proof assistants verify them, creating a virtuous cycle of mathematical discovery
- **Critical software** in aviation, medicine, and finance is backed by machine-verified mathematical proofs
- **Textbook mathematics** comes with computer-checkable certificates of correctness
- **Research mathematics** uses formal methods as a standard tool, catching errors before publication and enabling collaboration at unprecedented scale

The ancient Pythagoreans would have been amazed: from 3² + 4² = 5², we've spun a web of verified mathematics that touches the deepest questions in the field. And the computer checked every step.

---

*The complete Lean 4 codebase, comprising 100+ source files and building against Mathlib v4.28.0, is available for inspection and further development.*
