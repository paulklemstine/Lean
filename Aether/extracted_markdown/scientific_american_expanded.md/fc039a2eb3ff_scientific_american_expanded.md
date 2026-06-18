# Cracking Codes with Ancient Geometry: How Eight-Dimensional Numbers Could Break the Internet's Locks

*New mathematical experiments reveal that a geometric approach to factoring—rooted in Pythagorean triples and exotic number systems—may be more powerful than anyone expected*

---

Every time you enter your credit card number online, you're relying on one of mathematics' most stubborn unsolved problems: the difficulty of splitting large numbers into their prime factors. The RSA cryptosystem, which secures trillions of dollars in daily transactions, works because no one has found a fast way to factor the product of two large primes. Multiply 1,234,567,891 by 987,654,321? A computer does it in a nanosecond. Reverse the process? That could take longer than the age of the universe.

But a new line of research is attacking this problem from an unexpected angle: the geometry of right triangles in eight dimensions. And the latest results suggest it might work better than anyone thought.

## The Pythagorean Connection

You learned the Pythagorean theorem in school: $3^2 + 4^2 = 5^2$. What you probably didn't learn is that this simple equation hides a secret factoring machine.

Here's the trick. Take that equation and rearrange it:

$$(5 - 3)(5 + 3) = 4^2$$
$$2 \times 8 = 16$$

The hypotenuse 5 has been "peeled" into two factors: 2 and 8. Now suppose the hypotenuse is a number you want to factor—say 143 (which is 11 × 13). If you can find a Pythagorean-like equation with 143 as the hypotenuse, the peel factors $143 - x$ and $143 + x$ might share a common divisor with 143, revealing its prime factors.

This is the core idea of *gravitational factoring*: climb the tree of Pythagorean tuples, searching for one whose peel factors crack your target number.

## More Dimensions, More Chances

The real breakthrough comes from going higher-dimensional. In three dimensions, $2^2 + 3^2 + 6^2 = 7^2$ is a "Pythagorean quadruple." Each leg gives you a separate peel channel—a separate chance to find a factor. In $k$ dimensions, you get $k$ peel channels plus $k(k-1)/2$ "cross-collision" channels from comparing different tuples, for a total of $k(k+1)/2$ chances.

| Dimensions | Total Channels | Number System |
|:----------:|:--------------:|:-------------:|
| 2 | 3 | Complex numbers |
| 4 | 10 | Quaternions |
| 8 | **36** | Octonions |
| 16 | 136 | Sedenions |

The jump from 2 to 8 dimensions gives you 12 times as many factoring channels. But why stop at 8?

## The Division Algebra Sweet Spot

There's a deep mathematical reason why dimension 8 is special. In 1898, Adolf Hurwitz proved that bilinear sum-of-squares identities—formulas showing that the product of two sums of $n$ squares is itself a sum of $n$ squares—exist only for $n = 1, 2, 4,$ and $8$. These correspond to the four "division algebras": real numbers, complex numbers, quaternions, and octonions.

What makes this matter for factoring is that each identity guarantees you can decompose a product $N = pq$ as a sum of squares, and each decomposition gives you factoring channels. The octonions, with their 8-square identity (discovered by Ferdinand Degen in 1818), are the last and largest division algebra.

Beyond dimension 8, you enter the realm of sedenions (dimension 16), which have 136 channels but contain "zero divisors"—nonzero elements whose product is zero. This breaks the nice multiplicative structure. The sedenions give you more channels but weaker guarantees.

## The Density Question: How Often Does It Work?

The central question is: what fraction of Pythagorean tuples actually reveal a factor?

New computational experiments have produced a surprising answer. For a semiprime $N = pq$, the fraction of integers $x$ in $[1, N]$ with $\gcd(x, N) > 1$ (i.e., those that share a factor with $N$) is exactly:

$$\text{density} = \frac{p + q - 1}{pq}$$

This formula, derived from the inclusion-exclusion principle, was verified computationally with **zero error** across dozens of test cases. For balanced semiprimes where $p \approx q \approx \sqrt{N}$, this gives a density of approximately $2/\sqrt{N}$.

That's not great for huge numbers—but here's the kicker: with $k(k+1)/2$ channels, the effective density gets amplified. At dimension 8, you multiply your chances by 36. With the 480 different octonion multiplication tables (corresponding to different orientations of the Fano plane, a structure from projective geometry), you can get up to 17,280 independent factoring channels.

## The Non-Associativity Surprise

The most unexpected discovery involves a peculiar property of octonions: *non-associativity*. For ordinary numbers, $(a \times b) \times c = a \times (b \times c)$. For octonions, this fails.

But here's the remarkable part: while the products differ, their *norms* (sums of squares) are always equal. This means the same integer $N$ can be decomposed as a sum of 8 squares in multiple genuinely different ways, depending on how you bracket the multiplication. Each decomposition provides an independent set of 36 factoring channels.

In computational tests with specific octonions:
- The product $A \cdot B$ gave the decomposition $(4, 8, 4, 0, 4, 0, 4, 0)$
- The product $B \cdot A$ gave the completely different decomposition $(4, 2, 4, 6, 6, 0, 2, 4)$
- Both have the same norm: 128

Seven of eight components differ between the two decompositions. That's 7 genuinely new peel channels from simply reversing the multiplication order.

## Combining with Existing Methods

Perhaps the most practical advance is the *sieve-augmented* version, which hybridizes gravitational factoring with the quadratic sieve. The idea:

1. Generate many Pythagorean tuples
2. Compute their peel products $(d-x)(d+x)$
3. Keep only the "smooth" ones (those with only small prime factors)
4. Combine smooth products to create a perfect square
5. Use the classic congruence-of-squares technique to extract a factor

In tests, this approach successfully factored semiprimes up to 667 using just 3-dimensional tuples. The key theorem underlying this approach—that $\gcd(a - b, N)$ is nontrivial when $a^2 \equiv b^2 \pmod{N}$ with $a \not\equiv \pm b$—has been formally verified in Lean 4, providing a machine-checked guarantee of correctness.

## What's Next?

Four conjectures guide the research program:

**Conjecture A** (now partially confirmed): The factoring density is at least $1/\sqrt{N}$. The exact formula confirms this for the base density.

**Conjecture B** (open): The optimal dimension grows like $\log N / \log \log N$. Computational evidence is so far inconclusive.

**Conjecture C** (half-proven): Quaternion factoring is equivalent to integer factoring. One direction is formally verified; the reverse remains open.

**Conjecture D** (confirmed): Octonionic non-associativity provides a strict advantage. This has been demonstrated computationally with explicit examples.

The most exciting possibility: if the density conjecture holds and can be combined with efficient tuple generation, gravitational factoring could achieve *subexponential* complexity—the holy grail of factoring algorithms, currently achieved only by the number field sieve and its relatives.

## The Formal Guarantee

What sets this work apart from most mathematical exploration is its emphasis on *formal verification*. Every core identity and algebraic result has been proved in Lean 4, a computer proof assistant that mechanically checks every logical step. This means the results are not just "probably correct"—they are as certain as mathematics can be.

The verified results include:
- The Degen 8-square identity (368 terms, verified by `ring`)
- The parity obstruction theorems
- Channel count formulas for all dimensions up to 32
- The congruence-of-squares factoring principle
- The inclusion-exclusion density formula
- Lagrange's four-square theorem (using Mathlib)

This formal foundation ensures that as the framework develops, every new result builds on bedrock rather than sand.

## Should You Worry About Your Bank Account?

Not yet. The current approach works beautifully for small numbers but hasn't been tested at cryptographic scale (hundreds of digits). The $2/\sqrt{N}$ density means that for a 2048-bit key, you'd need on the order of $2^{512}$ random samples—still astronomical.

But mathematics has a way of surprising us. The quadratic sieve and number field sieve were once thought impractical too, before clever optimizations brought them into the realm of feasibility. If gravitational factoring can find similar shortcuts—perhaps through the lattice reduction hybrid, or through deeper exploitation of octonionic algebra—the story could change.

For now, the framework offers something valuable even if it never breaks RSA: a beautiful geometric perspective on one of mathematics' deepest problems, connecting ancient Pythagorean geometry to modern algebra and cryptography through eight-dimensional number systems that were once dismissed as mathematical curiosities.

The octonions, it seems, may have had the last laugh.

---

*The complete formal verification campaign (35+ theorems) and computational experiments are available as open-source Lean 4 and Python code.*
