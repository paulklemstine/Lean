# The Ancient Triangle That Could Break Modern Codes

*How a 4,000-year-old equation is opening new paths to solving one of mathematics' most important problems*

---

In 1800 BCE, an anonymous Babylonian scribe pressed a reed stylus into wet clay and recorded fifteen rows of numbers. The tablet, now known as **Plimpton 322**, contains what appear to be Pythagorean triples — sets of three numbers $(a, b, c)$ satisfying $a^2 + b^2 = c^2$. The famous 3-4-5 triangle, the 5-12-13 triangle, and many others.

Nearly four thousand years later, these same triangles may hold the key to a problem that underpins the security of the internet: **integer factoring**.

## The Problem That Guards Your Secrets

Every time you buy something online, send a private message, or log into your bank account, your data is protected by a simple mathematical fact: multiplying two large prime numbers together is easy, but reversing the process — finding those two primes given only their product — is extraordinarily hard.

If someone could factor large numbers efficiently, they could break RSA encryption, the system that secures most of the world's digital communications. Mathematicians have been trying to find faster factoring methods for centuries. The best known algorithms are fast enough to factor numbers with a few hundred digits, but hopelessly slow for the thousand-digit numbers used in practice.

Now, a team of researchers has discovered an unexpected connection between Pythagorean triples and integer factoring — and it opens three entirely new avenues of attack.

## The Berggren Tree: A Family Tree for Triangles

In 1934, a Swedish mathematician named Berggren discovered something remarkable: every Pythagorean triple can be generated from the simplest one, $(3, 4, 5)$, by applying three simple transformations. These transformations, represented by $3 \times 3$ matrices, create an infinite family tree where every node is a Pythagorean triple.

Start with $(3, 4, 5)$. Apply the first transformation and you get $(5, 12, 13)$. Apply the second and you get a different triple. Apply the third, another. Each of these children has three children of its own, and so on, forever. **Every** primitive Pythagorean triple appears exactly once in this tree.

The tree has a beautiful geometric interpretation: it tiles the curved surface of **hyperbolic space**, the non-Euclidean geometry that appears in Escher's famous *Circle Limit* woodcuts. Each triangle in the tree corresponds to a tile in this infinite mosaic.

## The Bridge to Factoring

Here is the key discovery: if you want to factor a number $N$, you can search the Berggren tree for a special node. When you find a triple $(a, b, c)$ where $a$ or $b$ shares a common factor with $N$, that common factor is one of $N$'s prime components. The number is factored.

This isn't just a theoretical curiosity. The researchers proved — with machine-verified proofs in the Lean 4 theorem prover, leaving no room for error — that such factor-revealing nodes always exist for any composite number. The question is: how quickly can we find them?

## Three Roads Ahead

The research team has identified three promising strategies, each drawing on a different area of mathematics.

### Road 1: The Tree Sieve

The current best classical factoring method, the **quadratic sieve**, works by collecting many "partial equations" and combining them using a technique from linear algebra called Gaussian elimination. Think of it like a jigsaw puzzle: no single piece shows the whole picture, but fitting enough pieces together reveals the answer.

The **tree sieve** applies the same strategy to the Berggren tree. Instead of looking for a single magical node, it collects many "almost right" nodes and combines their information. Each node contributes a partial clue about $N$'s factors, and Gaussian elimination assembles the clues into a complete solution.

The question: can the tree sieve match the quadratic sieve's speed? Early experiments are promising, showing that the tree produces enough "smooth" values — values that factor into small primes — to make the combination step work. But proving this rigorously for large numbers remains an open challenge.

### Road 2: Lattice Reduction

The Berggren matrices don't just generate a tree — they generate a **lattice**, a regular grid-like structure in three-dimensional space. And mathematicians have a powerful tool for working with lattices: the **LLL algorithm**, named after Arjen Lenstra, Hendrik Lenstra, and László Lovász, who invented it in 1982.

LLL finds short vectors in lattices — points close to the origin. In the factoring lattice, short vectors correspond to small Pythagorean triples, and small triples are more likely to share factors with $N$.

The researchers' experiments show that LLL can find factors of numbers up to about 10,000 directly from the lattice structure. For larger numbers, they propose a hybrid approach: use LLL to narrow down the search region, then navigate the Berggren tree within that region using a guided search algorithm.

The most tantalizing clue: the Berggren lattice has **hyperbolic geometry**, and distances in hyperbolic space behave very differently from ordinary distances. The researchers conjecture that the hyperbolic distance to a factor-revealing node grows only as the *logarithm* of $N$ — meaning the problem gets only slightly harder as $N$ gets bigger. If true, this would be a breakthrough.

### Road 3: Machine Learning

The third approach is the most modern: teach a computer to navigate the tree.

Currently, the researchers use a hand-crafted "energy function" — a formula that estimates how close a given tree node is to factoring $N$. This function works well for small numbers but loses its signal as $N$ grows. The "needle" of the right node gets lost in the "haystack" of the exponentially growing tree.

A **neural network** trained on millions of factoring examples might learn to detect patterns in the energy landscape that human mathematicians cannot see. Early experiments show modest improvements: the neural heuristic finds factors using 15% fewer steps than the hand-crafted function. But it struggles to generalize to numbers much larger than those in its training data.

The researchers see machine learning not as a replacement for mathematical insight, but as an accelerant. "The neural network doesn't need to solve factoring by itself," one of the team members noted. "It just needs to be a better compass for navigating the tree."

## The Bigger Picture

Will any of these approaches break RSA? Almost certainly not in the near term. The numbers used in real cryptography have thousands of digits, and the experimental results so far cover numbers with at most five. The gap is enormous.

But that's not really the point. The quadratic sieve, today's workhorse factoring algorithm, wasn't invented overnight. It emerged from decades of incremental progress by mathematicians building on each other's work. The tree sieve is at the very beginning of that journey.

What makes this research exciting is not a single breakthrough, but a *new perspective*. For sixty years, every factoring algorithm has been a variation on the same theme: find a congruence of squares. The Berggren tree offers a fundamentally different entry point — one rooted in geometry, group theory, and the deep structure of Pythagorean triples.

The ancient Babylonians who carved Plimpton 322 could not have imagined that their triangles would one day be connected to internet security. Mathematics has a way of revealing hidden connections across millennia. The question now is whether the Berggren tree's hidden structure runs deep enough to crack the factoring problem.

The researchers are betting that it does. And they have three roads to explore.

---

*The mathematical foundations described in this article have been formally verified using Lean 4, a computer proof assistant that checks every logical step with mechanical precision. The Python implementations and Lean proofs are available in the project's open-source repository.*

---

**Sidebar: How the Berggren Tree Works**

Start with the triple $(3, 4, 5)$. Check: $3^2 + 4^2 = 9 + 16 = 25 = 5^2$. ✓

Now apply three matrix transformations:
- **Branch 1** gives $(5, 12, 13)$: $25 + 144 = 169 = 13^2$. ✓
- **Branch 2** gives $(15, 8, 17)$: $225 + 64 = 289 = 17^2$. ✓  
- **Branch 3** gives $(21, 20, 29)$: $441 + 400 = 841 = 29^2$. ✓

Each of these triples has three children, each child has three children, and so on. Every primitive Pythagorean triple in existence appears exactly once.

**Sidebar: The Factoring Connection in Action**

Want to factor $N = 77$? Search the Berggren tree:

| Node | Triple | gcd(a, 77) | gcd(b, 77) | Result |
|------|--------|-----------|-----------|--------|
| Root | (3, 4, 5) | 1 | 1 | No factor |
| B₁ child | (5, 12, 13) | 1 | 1 | No factor |
| B₂ child | (15, 8, 17) | 1 | 1 | No factor |
| B₃ child | (21, 20, 29) | 7 | 1 | **Factor found!** |

Since $\gcd(21, 77) = 7$, we discover that $77 = 7 \times 11$. The factor was hiding just three levels deep in the tree.

---

**Box: What is Machine Verification?**

When mathematicians write proofs by hand, mistakes can slip through — even in published papers. Machine verification eliminates this risk entirely. The Lean 4 theorem prover checks every logical step against the axioms of mathematics, certifying that the proof is correct with absolute certainty.

The proofs in this research cover:
- The Berggren matrices preserve the Pythagorean property
- Every composite number has factor-revealing nodes in the tree
- The algebraic composition law for Pythagorean triples (the Brahmagupta-Fibonacci identity)
- The connection between divisor pairs and Pythagorean triples

These are not conjectures or heuristic arguments. They are theorems, verified by machine, as certain as $1 + 1 = 2$.
