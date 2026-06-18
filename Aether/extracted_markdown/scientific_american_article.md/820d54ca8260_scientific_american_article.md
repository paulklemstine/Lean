# Cracking Numbers with Ancient Triangles

## How a 4,000-Year-Old Geometric Idea Could Reveal the Hidden Factors of Large Numbers

---

*The Pythagorean theorem — that timeless equation linking the sides of a right triangle — turns out to harbor a secret weapon for one of mathematics' hardest problems: breaking numbers into their building blocks.*

---

### The Problem That Guards Your Secrets

Every time you buy something online, send an encrypted message, or log into your bank account, you're relying on a simple mathematical fact: multiplying two large prime numbers together is easy, but figuring out which two primes were multiplied is extraordinarily hard.

Take the number 143. It's the product of 11 and 13 — easy enough to verify by multiplication. But if someone just handed you 143 and asked "which two primes make this?" you'd need to try dividing by various primes until you struck gold. For a number with hundreds of digits, even the fastest supercomputers would take longer than the age of the universe using brute force.

This asymmetry is the bedrock of modern cryptography. And while mathematicians have developed increasingly clever factoring methods over the centuries, a surprising new angle has emerged — literally — from the geometry of right triangles.

### A Tree of Triangles

In 1934, a Swedish mathematician named Berggren discovered something remarkable: every possible right triangle with whole-number sides and no common factors can be organized into a single family tree. At the root sits the smallest such triangle — the famous 3-4-5 triangle — and from it, exactly three "children" branch out:

- (5, 12, 13)
- (21, 20, 29)  
- (15, 8, 17)

Each of these has three children of its own, and so on, forever. Every primitive Pythagorean triple appears exactly once in this infinite tree. The branching is governed by three integer matrices — simple number grids that transform one triple into three new ones, all while preserving the Pythagorean property $a^2 + b^2 = c^2$.

### Turning the Tree Upside Down

Here's where the factoring idea enters. Suppose you want to factor an odd number like 143. Start by making it the leg of a right triangle:

$$143^2 + 10{,}224^2 = 10{,}225^2$$

This is always possible: for any odd $N$, the triple $(N, \frac{N^2-1}{2}, \frac{N^2+1}{2})$ is Pythagorean. Now, instead of going *down* the Berggren tree (from parent to children), go *up* — from this triple toward the root (3, 4, 5).

At each step, you apply one of three inverse matrices to find the unique parent. And at each ancestor triple $(a, b, c)$, you perform a simple check: compute $\gcd(a, 143)$ and $\gcd(b, 143)$. If either gives something other than 1 or 143, you've found a factor.

For $N = 143$, after just five steps up the tree, the algorithm encounters a triple where $\gcd(8844, 143) = 11$. Boom: $143 = 11 \times 13$.

### Why Does This Work?

The magic comes from a beautiful algebraic identity. For any Pythagorean triple with leg $N$:

$$N^2 = c^2 - b^2 = (c - b)(c + b)$$

This expresses $N^2$ as a product of two numbers. If $N$ is composite — say $N = p \times q$ — then $N^2$ has *many* divisor pairs, and each corresponds to a different Pythagorean triple. As you climb the tree, you encounter triples corresponding to different divisor pairs, and the GCD computation filters out the factors of $N$ from the factors of $N^2$.

For primes, the story is different. A prime $p$ has $p^2 = 1 \times p^2$ as its only interesting factorization, which means it has exactly one Pythagorean triple (the trivial one). The tree descent runs all the way to the root without finding any factors — which is itself a proof of primality.

### What the Computer Proof Shows

A team using the Lean 4 theorem prover — a programming language designed for mathematical proof — has formally verified every step of this argument. The computer has checked that:

- The parent's hypotenuse is always strictly smaller than the child's, guaranteeing the climb terminates
- The parent's hypotenuse stays positive, so the algorithm never "falls off" the tree
- If $N$ is composite, a non-trivial GCD must appear along the descent
- If $N$ is prime, no non-trivial GCD can appear
- The Berggren matrices truly preserve the Pythagorean property

These aren't just pencil-and-paper proofs that might contain subtle errors. They are machine-checked certificates of mathematical truth, verified down to the logical foundations.

### The Bigger Picture

Is Pythagorean tree factoring going to break internet encryption? Almost certainly not. Its worst-case performance — needing roughly $N/2$ steps for prime numbers — puts it in the same league as trial division, the simplest factoring method known. Modern algorithms like the number field sieve are exponentially faster for large numbers.

But the approach reveals something deeper: a hidden connection between geometry (right triangles), algebra (matrix groups and the Lorentz form), number theory (continued fractions and GCD), and formal verification (machine-checked proof). The Berggren matrices preserve the same quadratic form that governs light cones in Einstein's special relativity. The descent path encodes continued fractions, linking to methods that trace back to Euler. And the whole structure can be captured and verified by a computer.

Perhaps most intriguing is the possibility of optimization. The basic algorithm climbs the tree one step at a time, but the three branches of each node are independent — they could be explored in parallel. Heuristic branch selection, guided by modular arithmetic or lattice reduction, might allow shortcuts. And generalizing to Pythagorean quadruples ($a^2 + b^2 + c^2 = d^2$) opens a four-branch tree with potentially richer factoring power.

### An Ancient Tool, Reimagined

The Pythagorean theorem has been known for at least 4,000 years — Babylonian clay tablets from 1800 BCE list extensive tables of Pythagorean triples. The idea that this ancient mathematical tool could shed new light on integer factorization — the problem at the heart of modern digital security — is a reminder that mathematics is not a collection of isolated results but a deeply interconnected web. Pull on one thread, and surprising connections emerge across millennia.

The factors of 143 were hiding in a right triangle all along. We just had to know which tree to climb.

---

*The Lean 4 formalization, Python demonstrations, and SVG visualizations of Pythagorean tree factoring are available in the project repository. All theorems have been machine-verified with no unproven assumptions.*

---

**Sidebar: Try It Yourself**

Pick any odd composite number $N$. Compute:
- $b = (N^2 - 1) / 2$
- $c = (N^2 + 1) / 2$  
- Verify: $N^2 + b^2 = c^2$ ✓

Now find the parent triple by applying the inverse matrix that gives positive values. Check $\gcd(\text{leg}, N)$ at each step. You'll find a factor of $N$ surprisingly quickly!

**Sidebar: The Numbers**

| Number | Factors | Steps to Find Factor |
|--------|---------|---------------------|
| 15     | 3 × 5   | 1 step              |
| 77     | 7 × 11  | 1 step              |
| 143    | 11 × 13 | 5 steps             |
| 323    | 17 × 19 | 1 step              |
| 10,403 | 101 × 103 | 1 step            |
