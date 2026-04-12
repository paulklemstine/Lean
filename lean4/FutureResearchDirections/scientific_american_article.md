# The Gravity of Numbers: A Geometric Approach to Cracking Codes

*How ancient Pythagorean mathematics and higher-dimensional algebras may transform the way we factor large numbers*

---

## The Problem That Guards Your Secrets

Every time you type a credit card number online, a mathematical puzzle stands between your data and anyone who wants to steal it. That puzzle is *integer factorization* — taking a large number and finding the two prime numbers that multiply together to produce it.

It sounds simple. If I tell you that 15 = 3 × 5, you'd barely blink. But if I give you a number with 600 digits — the kind used in modern RSA encryption — the best computers in the world would need longer than the age of the universe to find its factors by brute force.

This asymmetry — easy to multiply, hard to factor — is the bedrock of internet security. And a new mathematical framework, drawing on ideas from Pythagoras, quaternions, and even gravitational physics, is providing fresh insight into why factoring is hard and how it might be made easier.

## Pythagoras Meets Cryptography

You probably remember the Pythagorean theorem from school: a² + b² = c². A Pythagorean triple like (3, 4, 5) satisfies this equation with whole numbers. What you might not know is that these triples hide a secret about factoring.

Consider the number N = 15. If we can find a Pythagorean triple (a, b, c) where the hypotenuse c is a multiple of 15 — say c = 15 itself — then the legs a and b might share a factor with 15. Check: gcd(15 - 12, 15) = gcd(3, 15) = 3. We just found a factor of 15 using nothing but a Pythagorean triple and the greatest common divisor!

This is the core insight of *gravitational factoring*: **factoring is equivalent to finding Pythagorean tuples whose hypotenuse is divisible by the number you want to factor**.

## The Energy Landscape

The name "gravitational" comes from a beautiful physical analogy. Imagine a landscape with hills and valleys, where the height at each point represents how far a Pythagorean tuple is from revealing a factor. The factor-revealing configurations sit at the bottom of deep "gravitational wells" — just like massive objects create wells in spacetime.

Finding a factor means rolling a ball across this landscape until it falls into a well. The deeper and wider the well, the easier it is to find. The research team has shown that for a semiprime N = p × q, the wells have depth proportional to p + q - 1, and the fraction of the landscape occupied by wells is exactly (p + q - 1)/(pq). For a balanced semiprime where p ≈ q ≈ √N, this works out to about 2/√N — a small but nonzero fraction.

## Going Higher: The Power of Extra Dimensions

Here's where it gets exciting. A Pythagorean triple lives in 3 dimensions. But what about a *quadruple* — four numbers where a² + b² + c² = d²? Or a *quintuplet*? Or an *octuplet*?

Each extra dimension adds new "channels" for extracting factors. A triple gives 3 chances to find a factor. A quadruple gives 10. An octuplet gives 36. The formula is elegantly simple: k legs give k + k(k-1)/2 = k(k+1)/2 total channels.

But there's a deeper reason why certain dimensions are special. They correspond to the great *division algebras* of mathematics:

- **Dimension 2**: Complex numbers ℂ (3 channels)
- **Dimension 4**: Quaternions ℍ (10 channels)
- **Dimension 8**: Octonions 𝕆 (36 channels)
- **Dimension 16**: Sedenions 𝕊 (136 channels)

These algebras, discovered over two centuries, each have a multiplication rule that preserves a "norm" — the sum of squares of all components. This norm multiplicativity is exactly what makes them useful for factoring: if N(A) = p and N(B) = q, then N(A·B) = p·q = N, and the multiplication structure reveals how p and q combine.

## Euler's Magic Identity

The key mathematical engine is a family of identities discovered by Leonhard Euler in the 18th century. Euler showed that the product of two sums of four squares is itself a sum of four squares:

(a₁² + b₁² + c₁² + d₁²)(a₂² + b₂² + c₂² + d₂²) = A² + B² + C² + D²

where A, B, C, D are specific combinations of the original eight numbers. Combined with Lagrange's theorem (every positive integer is a sum of four squares), this means every semiprime N = pq can be written as a quaternion product, and the product structure encodes the factorization.

The research team has *formally verified* this identity using Lean 4, a computer proof assistant that checks mathematical arguments with absolute rigor. This isn't just a paper proof — it's a proof that has been verified by a computer, symbol by symbol, with zero room for error.

## The Berggren Tree: A Map of All Triples

To actually find useful Pythagorean triples, the researchers use a remarkable structure called the *Berggren tree*. Discovered by the Swedish mathematician B. Berggren in 1934, this infinite ternary tree generates every primitive Pythagorean triple exactly once.

The root is (3, 4, 5). Each node has three children, produced by multiplying by three specific 3×3 matrices (called A, B, and C). The tree has the beautiful property that every primitive triple appears at exactly one node. Searching for a factor of N becomes navigating this tree — a geometric journey through the space of all Pythagorean triples.

The tree grows exponentially: at depth d, there are 3^d nodes with hypotenuses up to about 3^(d+1). This exponential coverage means that linear-depth search covers exponentially many triples, giving the algorithm its exploratory power.

## Quantum Acceleration

What happens when we add quantum computing? The researchers analyzed the effect of Grover's quantum search algorithm on the framework. Classically, finding a factor-revealing tuple among √N candidates takes O(√N) time. Grover's algorithm can search this space in O(N^(1/4)) time — a *fourth-root* improvement.

For a 2048-bit RSA key, this means:
- Classical gravitational factoring: ~2^(1024) operations
- Quantum gravitational factoring: ~2^(512) operations
- Shor's algorithm: ~2^(33) operations (polynomial)

Shor's algorithm remains far superior for pure factoring, but the gravitational framework provides geometric intuition that Shor's algebraic approach lacks — and may reveal structural features of factoring that lead to new algorithms.

## The Sedenion Frontier

Perhaps the most intriguing direction is the *sedenion* algebra — 16-dimensional numbers that are the next step beyond octonions in the Cayley-Dickson hierarchy. Sedenions have a property that their predecessors lack: *zero divisors*. That is, there exist nonzero sedenions A and B with A·B = 0.

At first glance, this seems like a bug. But the research team conjectures it's a feature: the zero-divisor structure constrains how factors can combine, potentially revealing them. A sedenion provides 136 factoring channels — nearly four times as many as an octonion's 36.

This is one of 30 open research directions identified by the team, ranging from lattice theory to tropical geometry to machine learning.

## Why It Matters

Even if gravitational factoring never breaks RSA, the framework is advancing mathematics in several ways:

1. **Formal verification**: The team has machine-verified dozens of theorems in Lean 4, setting a new standard for rigor in factoring research.

2. **Cross-pollination**: The framework connects number theory, algebra, geometry, physics, and computer science in unexpected ways. The energy landscape idea, borrowed from physics, provides intuition that pure algebra misses.

3. **New questions**: The research has generated fundamental questions about the topology of factoring energy landscapes, the role of non-associativity in computation, and connections to the Riemann hypothesis.

4. **Education**: The geometric perspective makes factoring accessible. You can literally *see* the factors as gravitational wells in a landscape — a far cry from the abstract algebraic manipulations of traditional approaches.

## The Road Ahead

The central open question is one of *complexity*: can gravitational factoring be made subexponential? The answer likely depends on whether the sieve-augmented variant — which combines k-tuple generation with factor base methods — can match the efficiency of the quadratic sieve.

The team has identified the lattice reduction hybrid as the most promising path. By combining the LLL algorithm (which finds short vectors in lattices) with the geometric structure of k-tuples, they hope to achieve a polynomial-time factor extraction step that, combined with subexponential k-tuple generation, would yield a competitive algorithm.

Whether or not this succeeds, the gravitational factoring framework has already achieved something rare in mathematics: it has made an ancient problem feel new again. By viewing factoring through the lens of geometry, physics, and higher-dimensional algebra, it has opened doors that pure number theory alone could not.

And in mathematics, opening a door is often more important than what you find on the other side.

---

*The gravitational factoring framework is an ongoing research program. All formally verified results are available in Lean 4 source code with Mathlib dependencies. Python demonstrations and visualizations are included for readers who wish to explore the concepts computationally.*
