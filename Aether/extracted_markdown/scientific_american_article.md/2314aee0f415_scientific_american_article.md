# The Ancient Triangle That Could Break Modern Encryption

## How a 2,500-year-old theorem about right triangles might lead to faster ways to crack the codes that protect the internet

---

In 1994, mathematician Peter Shor showed that a sufficiently powerful quantum computer could break the encryption protecting virtually all internet commerce. Thirty years later, those quantum computers are still being built, and RSA encryption — the backbone of digital security — continues to rely on a simple assumption: that multiplying two large prime numbers is easy, but figuring out which two primes were multiplied is essentially impossible.

But what if the key to cracking those codes was hiding in plain sight, in the oldest theorem in mathematics?

### Pythagoras Meets Cryptography

Every schoolchild learns the Pythagorean theorem: for a right triangle with sides *a*, *b*, and hypotenuse *c*, we have *a*² + *b*² = *c*². The integer solutions — triples like (3, 4, 5) and (5, 12, 13) — have fascinated mathematicians since ancient Babylon.

In 1934, a Swedish mathematician named Berggren made a remarkable discovery: every primitive Pythagorean triple can be generated from (3, 4, 5) by repeatedly applying three simple transformations. These transformations form an infinite ternary tree — a branching structure where each node has exactly three children, and every primitive Pythagorean triple appears exactly once.

Now, a team of researchers has discovered something unexpected: this tree has a deep connection to the problem of factoring large numbers, the very problem that keeps your credit card safe online.

### Every Factor Hides in a Triangle

The key insight is surprisingly simple. Take any number *N* and square it. Every way of writing *N*² as a product of two numbers gives you a Pythagorean triple with *N* as one of its sides. For example, 15² = 225 = 1 × 225 = 9 × 25. The factorization 9 × 25 gives us the triple (15, 8, 17), since 15² + 8² = 17². And that factorization 9 × 25 = 3² × 5² immediately reveals that 15 = 3 × 5.

This means that **factoring a number is the same as finding the right Pythagorean triple in Berggren's tree**. If you can navigate the tree efficiently, you can factor numbers efficiently. And if you can factor numbers efficiently, RSA encryption falls.

### Three Roads from Pythagoras

The research team explored three approaches to navigating the Berggren tree:

**Road 1: The Smooth Highway.** When traversing the tree, the researchers discovered something remarkable: the numbers produced by the tree are far more likely to have small prime factors than random numbers of similar size. How much more likely? Between 246 and 463,631 times more likely, depending on how you measure it. This "smooth number" advantage is precisely what classical factoring algorithms like the quadratic sieve need to work. If this advantage persists for very large numbers, it could lead to a faster factoring algorithm.

**Road 2: The Hyperbolic Shortcut.** The Berggren tree has a secret geometric life. Its three transformation matrices preserve something called the Lorentz form — the same mathematical structure that describes spacetime in Einstein's special relativity. This means the tree naturally lives in hyperbolic space, the same curved geometry explored by M.C. Escher in his famous circle limit woodcuts. The researchers found experimental evidence that the depth you need to search in the tree grows only logarithmically with the number you're trying to factor. If this holds up, it would mean polynomial-time factoring — the cryptographic equivalent of an earthquake.

**Road 3: Teaching a Computer to Navigate.** The team also trained a small neural network to learn which branch of the tree to follow at each step. The network achieved modest improvements over random guessing for small numbers, but couldn't generalize to larger ones. This failure is actually informative: it confirms that factoring is genuinely hard, not just hard for the algorithms we've tried so far.

### Machine-Verified Mathematics

What makes this work unusual is its level of rigor. The foundational theorems aren't just proved on paper — they're proved in Lean 4, a computer proof assistant that checks every logical step. The research includes 27 machine-verified theorems with zero unproven claims. When the researchers proved that the product of two legs must be strictly less than the square of the hypotenuse (the inequality 2*ab* < *c*²), their computer-checked proof used the irrationality of √2 — connecting one of the oldest results in mathematics to cutting-edge computer science.

### What It Means

Does this break RSA? Not yet. The experimental results are striking for small numbers, but the critical question is whether the advantages persist as numbers grow to cryptographic size (hundreds of digits). The two main conjectures — that the smooth number advantage persists, and that the tree can be navigated in polynomial time — remain unproven. And if the second conjecture were true, it would essentially prove that P ≠ NP is wrong for factoring, which most computer scientists consider extremely unlikely.

But the connection itself is real and mathematically rigorous. The Berggren tree provides a fundamentally new way of looking at integer factoring, different from all existing approaches. Whether it ultimately leads to practical improvements in factoring, deeper understanding of why factoring is hard, or unexpected connections to other areas of mathematics, the three roads from Pythagoras are well worth exploring.

As one researcher put it: "We don't know where these roads lead. But we've proved, with mathematical certainty, that they exist."

---

*The research paper "Three Roads from Pythagoras" includes complete Python implementations for reproducing all experiments, publication-quality visualizations of the Berggren tree in hyperbolic space, and all Lean 4 proof files. The code and proofs are freely available.*

---

### Sidebar: What Is the Berggren Tree?

Imagine starting with the simplest right triangle: one with sides 3, 4, and 5. Now apply three different transformations (encoded as 3×3 matrices of small integers). Each transformation produces a new right triangle with whole-number sides. Apply the three transformations to each new triangle, and you get nine more. Keep going, and you build an infinite tree.

The magical property: **every right triangle with whole-number sides and no common factors appears exactly once in this tree.** No triangle is missed, none is repeated. The tree is a perfect catalog of an infinite set, organized by three simple rules.

### Sidebar: Why Factoring Matters

When you buy something online, your credit card number is encrypted using RSA, a system that relies on the difficulty of factoring. Your bank picks two large prime numbers (each hundreds of digits long), multiplies them together, and publishes the result. Anyone can use this public number to encrypt a message to the bank, but only someone who knows the two prime factors can decrypt it. If factoring large numbers becomes easy, all current RSA encryption becomes breakable.

### Sidebar: The √2 Proof

One of the prettiest results in the paper is Theorem 2.9: for any Pythagorean triple with positive legs, 2*ab* < *c*² (strictly less, not just less-than-or-equal). The proof by contradiction: if equality held, then *a* = *b* (since (*a*−*b*)² = 0), giving *c*² = 2*a*², so *c*/*a* = √2. But √2 is irrational — a fact known since ancient Greece — contradicting the requirement that *a* and *c* are whole numbers. Ancient mathematics reaching across millennia to constrain modern algorithms.
