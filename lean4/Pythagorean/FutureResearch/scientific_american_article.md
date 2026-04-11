# The Geometry of Breaking Codes: How Ancient Number Theory Could Crack Modern Encryption

*A new framework connects Pythagorean geometry to the problem that secures your bank account*

---

Every time you buy something online, your credit card number travels across the internet protected by a mathematical lock. That lock—the RSA cryptosystem—relies on a simple fact: multiplying two large prime numbers together is easy, but splitting the result back into its prime factors is extraordinarily hard. A computer can multiply two 300-digit primes in a fraction of a second, but no known algorithm can reverse the process in less than billions of years.

Or can it?

A new mathematical framework called *gravitational factoring* approaches this ancient problem from a surprising direction: the geometry of right triangles and their higher-dimensional cousins.

## From Pythagoras to Cryptography

You probably remember the Pythagorean theorem from school: $a^2 + b^2 = c^2$. The triple $(3, 4, 5)$ is the most famous example. But Pythagorean triples are just the beginning. In four dimensions, we have *Pythagorean quadruples*: $(1, 2, 2, 3)$ works because $1^2 + 2^2 + 2^2 = 3^2$. In eight dimensions, we get *Pythagorean octuples*.

Here's the key insight: if you have a Pythagorean quadruple $(a, b, c, d)$ with $a^2 + b^2 + c^2 = d^2$, you can rearrange it as:

$$(d - a)(d + a) = b^2 + c^2$$

This "peel identity" splits the hypotenuse $d$ into two factors: $d - a$ and $d + a$. If $d$ happens to be the number you want to factor, and if one of these factors shares a common divisor with $d$, you've cracked the code.

## More Dimensions, More Chances

The beauty of the framework is that each dimension gives you more opportunities to find a factor. In $k$ dimensions, each Pythagorean k-tuple gives you $k$ "peel channels"—$k$ different ways to split the hypotenuse—plus $\binom{k}{2}$ "cross-collision channels" from comparing pairs of tuples.

The total follows a simple formula: $k(k+1)/2$ channels. For ordinary Pythagorean triples ($k = 2$), you get 3 chances. For quadruples ($k = 3$), you get 6. But at dimension 8—the dimension of the *octonions*, a mysterious number system discovered in 1843—you get **36 channels**. That's a 12-fold improvement over the basic approach.

## The Division Algebra Connection

Why is dimension 8 special? The answer lies in one of the most beautiful results in abstract algebra. In 1898, the German mathematician Adolf Hurwitz proved that there are exactly four dimensions where a "sum of squares" identity works perfectly: 1, 2, 4, and 8. These correspond to the four *normed division algebras*:

- **Real numbers** (dimension 1): $a \cdot b = ab$ — trivial
- **Complex numbers** (dimension 2): $(a^2 + b^2)(c^2 + d^2) = (ac-bd)^2 + (ad+bc)^2$
- **Quaternions** (dimension 4): Euler's four-square identity
- **Octonions** (dimension 8): Degen's eight-square identity

Each level up the hierarchy loses a property: complex numbers aren't ordered, quaternions aren't commutative ($ij \neq ji$), and octonions aren't even associative ($(ij)k \neq i(jk)$). But the norm—the sum of squares—stays multiplicative.

And here's the punchline: that non-associativity isn't a bug. It's a *feature*. Because octonion multiplication depends on the order of operations, the *same* product $N = pq$ can be decomposed into a sum of 8 squares in *multiple independent ways*. Each decomposition gives a fresh set of 36 factoring channels. The non-associativity provides bonus information that associative algebras can't match.

## The Energy Landscape

The researchers behind gravitational factoring describe their approach using the language of physics. Imagine the set of all k-tuples as a landscape, with "energy" measuring how far a tuple is from revealing a factor. The target number $N$ sits at the bottom of a gravitational well, and the factoring algorithm is like a ball rolling downhill.

The landscape has fascinating properties. The "factoring-revealing" tuples form hyperplanes cutting through a high-dimensional sphere. For a semiprime $N = pq$, these hyperplanes have a density of approximately $1/p + 1/q$ on the sphere—sparse, but non-vanishing.

## Computer-Verified Mathematics

What makes this work especially rigorous is that the core results have been formally verified using the Lean 4 proof assistant—a computer program that checks every logical step of a mathematical proof. The Degen eight-square identity, the channel-counting formulas, and the parity obstruction theorems have all been machine-checked, leaving no room for error.

This is part of a broader trend in mathematics: using computers not just to *compute* answers, but to *verify* that proofs are correct. The gravitational factoring project represents one of the most extensive formalizations of the connection between division algebras and number theory.

## Can It Break RSA?

The honest answer: probably not, at least not yet. Modern RSA uses 2048-bit keys, meaning the primes have about 300 digits each. The factoring density—the fraction of k-tuples that actually reveal a factor—appears to decrease as the numbers get larger. Whether it decreases slowly enough for the approach to be practical remains an open question.

But even if gravitational factoring never breaks RSA, it reveals deep connections between geometry, algebra, and number theory that mathematicians find irresistible. The idea that the ancient geometry of Pythagoras, filtered through the exotic octonions, has anything at all to say about modern cryptography is itself remarkable.

## What's Next?

The research program spans multiple frontiers:

- **Empirical studies** to measure how factoring density scales with number size
- **Hybrid algorithms** combining geometric insight with classical sieving methods
- **Quantum acceleration** using Grover's algorithm on the tree structure
- **Higher Cayley-Dickson algebras** (the 16-dimensional sedenions have zero divisors—could these help?)
- **Machine learning** to train neural networks that navigate the k-tuple tree efficiently

Perhaps most tantalizingly, the statistical mechanics analogy suggests there might be a *phase transition* in the factoring landscape—a critical threshold where the algorithm's behavior changes qualitatively from "hopeless" to "effective." Finding this threshold, if it exists, would be a major breakthrough.

For now, your bank account is safe. But the mathematicians are still climbing Pythagoras's ladder, and each rung reveals a wider view.

---

*The core mathematical results described in this article have been formally verified in Lean 4 using the Mathlib library. The Lean proofs, Python demonstrations, and visualizations are available in the project repository.*
