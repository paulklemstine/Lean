# The Hidden Tree of Primes: How an Obscure 1934 Paper Reveals a Secret Structure in the Prime Numbers

*A forgotten Swedish mathematician discovered a magical tree that grows every right triangle with integer sides. Ninety years later, that tree is revealing unexpected patterns in the prime numbers — and computers are proving the results with mathematical certainty.*

---

## The Oldest Equation in Mathematics

Everyone who has survived a high school geometry class knows the Pythagorean theorem: for a right triangle with legs *a* and *b* and hypotenuse *c*, we have a² + b² = c². The equation is ancient — Babylonian scribes were carving solutions like (3, 4, 5) and (5, 12, 13) into clay tablets nearly 4,000 years ago.

But here's a question that might seem simple and turns out to be surprisingly deep: Can you list *all* right triangles with whole-number sides?

The answer has been known since Euclid (around 300 BCE): pick any two positive integers *m* and *n* with *m* > *n*, and the formula a = m² − n², b = 2mn, c = m² + n² always gives you a right triangle. Choose m = 2, n = 1 and you get (3, 4, 5). Choose m = 3, n = 2 and you get (5, 12, 13). Every right triangle with whole-number sides arises this way (after possibly scaling and swapping the legs).

But there's a much more beautiful way to organize them — one that wasn't discovered until 1934, when a Swedish mathematician named Berggren published a short paper in an obscure Scandinavian journal. His idea: arrange all the triangles into a *tree*.

## Berggren's Magic Tree

Imagine starting with the simplest right triangle: (3, 4, 5). Now apply three specific recipes to transform it into three new triangles:

- **Recipe A**: Transform (a, b, c) into (a − 2b + 2c, 2a − b + 2c, 2a − 2b + 3c)
- **Recipe B**: Transform (a, b, c) into (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)
- **Recipe C**: Transform (a, b, c) into (−a + 2b + 2c, −2a + b + 2c, −2a + 2b + 3c)

Apply these to (3, 4, 5):
- Recipe A gives **(5, 12, 13)**
- Recipe B gives **(21, 20, 29)**
- Recipe C gives **(15, 8, 17)**

Each of these is genuinely a right triangle — you can check: 5² + 12² = 25 + 144 = 169 = 13². And each of these three children can have the same three recipes applied, giving nine grandchildren, then 27 great-grandchildren, and so on, forever.

Here's the magical part: **every** "primitive" right triangle (one where the three sides share no common factor) appears in this tree exactly once. The tree is an infinite family album of all right triangles.

```
                              (3, 4, 5)
                           /      |      \
                     (5,12,13) (21,20,29) (15,8,17)
                    /   |   \    / | \    / | \
              (7,24,25) ... ...  ...  ... ... ...
```

## Where Are the Primes?

Now here's where things get interesting — and where modern mathematics meets an ancient mystery.

Look at the hypotenuse (the longest side) of each triangle in the first few levels:

- Level 0: **5** ← prime!
- Level 1: **13**, **29**, **17** ← all prime!
- Level 2: 25, **73**, **53**, **89**, 169, 85, 65, **97**, **37**

Something remarkable is happening. Primes show up as hypotenuses far more often than you'd expect by chance. At level 2, five of the nine hypotenuses are prime — that's 56%. By comparison, among all numbers of similar size, only about 30% are prime.

This isn't a coincidence. It's a reflection of one of the most beautiful theorems in number theory, proved by Pierre de Fermat in 1640:

> **A prime number can be the hypotenuse of a right triangle if and only if it leaves a remainder of 1 when divided by 4.**

The primes 5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97... all equal 1 mod 4. And each of them appears as the hypotenuse of *exactly one* primitive right triangle — meaning each gets exactly one spot in Berggren's tree.

## The Computer Detectives

To understand how primes distribute themselves throughout the tree, we needed to go deeper — much deeper than pencil and paper allows.

We programmed a computer to generate the Berggren tree down to level 9, producing 29,524 triangles in total. At each level, we counted how many hypotenuses were prime:

| Level | Triangles | Prime Hypotenuses | Percentage |
|-------|-----------|-------------------|------------|
| 0 | 1 | 1 | 100% |
| 1 | 3 | 3 | 100% |
| 2 | 9 | 5 | 56% |
| 3 | 27 | 14 | 52% |
| 4 | 81 | 40 | 49% |
| 5 | 243 | 95 | 39% |
| 6 | 729 | 236 | 32% |
| 7 | 2,187 | 670 | 31% |
| 8 | 6,561 | 1,803 | 27% |
| 9 | 19,683 | 4,707 | 24% |

The percentage of primes decreases as we go deeper — but slowly. Much more slowly than you might expect.

Here's why that's surprising. As we descend the tree, the hypotenuses grow exponentially. By level 9, some hypotenuses are in the millions. The Prime Number Theorem tells us that primes thin out logarithmically: among numbers near *N*, about 1 in log(*N*) is prime. So naïvely, you'd expect the prime fraction to plummet. Instead, it gently declines as roughly 1/d^0.6, where d is the depth.

The explanation lies in the geometry of the tree itself. Two of the three Berggren recipes (A and C) produce only gentle growth — like walking along a gentle slope. These branches concentrate many triangles in the "small number" zone where primes are abundant. The third recipe (B) rockets the hypotenuse upward exponentially, but it's only one branch out of three. The net effect: the tree naturally gravitates toward regions rich in primes.

## Chains of Primes

One of the most tantalizing patterns we found involves *prime chains* — paths through the tree where every hypotenuse along the way is prime.

Starting from (3, 4, 5) with its prime hypotenuse 5, we can follow Recipe A to get (5, 12, 13) with prime hypotenuse 13, then apply Recipe C to get (45, 28, 53) with prime hypotenuse 53. Continuing down the tree, we found a chain of **nine consecutive prime hypotenuses**:

**5 → 13 → 53 → 193 → 433 → 773 → 1213 → 1753 → 2393**

Each number in that sequence is prime, and each corresponds to a right triangle that's the child of the previous one. Is this just a lucky streak? We don't think so. The structure of the tree makes long prime chains more likely than pure randomness would predict, and we conjecture that chains of *any* length exist somewhere in the tree.

## The Gaussian Connection

The deepest explanation for why primes dance through the Berggren tree so beautifully comes from an idea of Carl Friedrich Gauss.

In 1832, Gauss introduced the *Gaussian integers* — numbers of the form a + bi, where i = √(−1). In this extended number system, the "size" of a number a + bi is |a + bi|² = a² + b². Sound familiar?

Every primitive Pythagorean triple corresponds to a Gaussian integer: the triple (3, 4, 5) corresponds to 2 + i (since 2² + 1² = 5 = the hypotenuse). When the hypotenuse is prime, the corresponding Gaussian integer is a *Gaussian prime* — an atom in this extended number system that can't be broken down further.

The Berggren tree, viewed through this lens, is really a map of how Gaussian primes organize themselves. The three recipes A, B, C correspond to fundamental symmetries of the Gaussian integers, and the tree structure reflects the unique way these atomic building blocks fit together.

This connection reaches all the way to the frontiers of modern mathematics. The Berggren matrices generate a group closely related to the "theta group," a symmetry group that appears in the theory of modular forms — the same mathematical objects that played a crucial role in Andrew Wiles's proof of Fermat's Last Theorem.

## Proof by Computer — A New Kind of Certainty

Our investigation didn't stop at computation. We wanted *proof* — not just evidence, but the absolute certainty that only formal mathematics can provide.

We used Lean 4, a computer proof assistant developed at Microsoft Research, to formally verify the core properties of the Berggren tree:

- ✅ Each of the three recipes genuinely preserves the Pythagorean property
- ✅ The three matrices preserve the Lorentz quadratic form x² + y² − z²  
- ✅ Every triangle in the tree, at any depth, satisfies a² + b² = c²
- ✅ At least one leg of any Pythagorean triple is even
- ✅ No integer ≡ 3 (mod 4) is a sum of two squares

These aren't just "we checked a million cases and they all worked" results. They are *formally verified theorems* — the computer has checked every logical step, from axioms to conclusion. There is zero possibility of error (short of a bug in the proof checker itself, which has been extensively validated).

This approach — combining computational exploration with formal verification — represents a new paradigm in mathematical research. We explore with algorithms, discover patterns with statistics, and then nail down the truth with machine-checked proofs.

## The Questions That Remain

Like all good mathematics, our investigation raises more questions than it answers:

1. **The Prime Chain Conjecture:** Can you find prime chains of *any* length in the Berggren tree? We found one of length 9, but does a chain of length 100 exist? Length 1,000?

2. **The Density Mystery:** Why does the prime fraction decay as d^{−0.6} rather than d^{−1}? Is there an exact formula?

3. **Twin Primes in Triangles:** Are there infinitely many right triangles where both legs are prime and differ by exactly 2 (like 5 and 7, or 11 and 13)?

4. **The Langlands Connection:** The theta group that underlies the Berggren tree is connected to the vast Langlands program — often called the "Grand Unified Theory of mathematics." Does this connection reveal new truths about primes?

## A Tree That Keeps Growing

Berggren's 1934 paper was written in Swedish, published in an obscure journal, and largely forgotten for decades. It was independently rediscovered by Barning in the Netherlands (1963) and Hall in England (1970). Today, armed with computers that can generate millions of triangles per second and proof assistants that can verify theorems with absolute rigor, we're beginning to see just how deep this tree's roots go.

The Berggren tree is more than a clever enumeration trick. It's a window into the deep structure of number theory — a structure where the ancient Pythagorean theorem, the distribution of prime numbers, the algebra of imaginary numbers, and the geometry of hyperbolic space all converge in a single, elegant, infinitely branching tree.

And somewhere in that tree, at a depth we haven't reached yet, there may be secrets about prime numbers that mathematicians haven't even dreamed of.

---

*The Python code, Lean 4 proofs, and visualizations described in this article are available in the project repository.*
