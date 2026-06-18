# The Formula That Connects Everything

## How a simple fraction links Einstein, Euclid, and quantum computers

---

*Imagine a single mathematical formula that simultaneously describes how velocities combine near the speed of light, how angles add in Euclidean geometry, how quantum computers manipulate information, and how ancient Babylonian scribes generated their famous tablet of Pythagorean triples. It sounds impossible — but that formula exists, and it's been hiding in plain sight for centuries.*

---

### A Formula You Already Know

Take two numbers, add them, and divide by one minus their product:

$$\frac{x + y}{1 - xy}$$

That's it. This is the formula at the heart of what researchers call the **Stereographic Projection Bridge** (SPB). You've probably encountered it before without recognizing its significance — it's the tangent addition formula from high school trigonometry:

$$\tan(\alpha + \beta) = \frac{\tan\alpha + \tan\beta}{1 - \tan\alpha \cdot \tan\beta}$$

But this humble fraction is far more than a trigonometric identity. It's a universal algebraic gate that connects half a dozen branches of mathematics through a single operation.

### Einstein's Speed Limit

In 1905, Albert Einstein showed that velocities don't simply add the way we intuit. If you're on a train moving at speed v₁ and throw a ball forward at speed v₂, the ball's speed relative to the ground isn't v₁ + v₂. Instead, it's:

$$v_{\text{total}} = \frac{v_1 + v_2}{1 + v_1 v_2 / c^2}$$

Notice anything? It's almost identical to our SPB formula — just with a plus sign instead of a minus in the denominator! This small sign change (what physicists call a **Wick rotation**) is the entire difference between circular and hyperbolic geometry, between trigonometry and relativity.

The hyperbolic version automatically enforces the cosmic speed limit: if both v₁ and v₂ are less than the speed of light, then their "SPB sum" is also less than the speed of light. This has now been machine-verified with mathematical certainty using the Lean 4 theorem prover — not just checked for a few examples, but proved true for all possible subluminal velocities.

### The Circle's Secret Language

Why does this formula appear in so many places? The answer lies in the simplest curve in mathematics: the circle.

Imagine a circle centered at the origin with radius 1. Every point on this circle can be described by an angle θ. Adding angles is the most natural operation on the circle: rotating by α and then by β gives a total rotation of α + β.

Now here's the key insight. If you use **stereographic projection** — drawing a line from one pole of the circle to any other point and seeing where it hits the real line — you get a coordinate system where every point on the circle (except one) corresponds to a real number t. And in this coordinate system, the "angle addition" operation becomes:

$$t_1 \oplus t_2 = \frac{t_1 + t_2}{1 - t_1 t_2}$$

The SPB formula IS the circle group, written in stereographic coordinates. This is why it appears everywhere — because the circle group S¹ is the simplest compact Lie group, and it shows up throughout mathematics and physics as the fundamental symmetry of rotation, phase, and periodicity.

### Computing π with a Calculator

One of the most delightful applications of the SPB formula is computing π. The great 18th-century mathematician John Machin discovered that:

$$\frac{\pi}{4} = 4 \cdot \arctan\frac{1}{5} - \arctan\frac{1}{239}$$

In SPB language, this becomes a tree of operations. Start with four copies of 1/5. Combine pairs using SPB to get 5/12 (twice). Combine those to get 120/119. Finally, combine with -1/239 to get... exactly 1. And since arctan(1) = π/4, we've computed π!

This has been formally verified: every step checked by a computer proof assistant. The tree structure reveals that computing π is really about finding efficient "addition chains" in the SPB group — a connection to computational complexity theory that mathematicians are only beginning to explore.

### Quantum Computers Speak SPB

Perhaps the most surprising recent discovery is the connection to quantum computing. A quantum bit (qubit) lives on the **Bloch sphere** — a unit sphere where the north pole represents |0⟩ and the south pole represents |1⟩. Via stereographic projection, qubit states become complex numbers ζ.

And quantum gates? They become **Möbius transformations** of ζ. The Hadamard gate — one of the most important operations in quantum computing — turns out to be:

$$H(\zeta) = \frac{\zeta - 1}{\zeta + 1}$$

which is exactly SPB(ζ, -1)! Composing quantum gates becomes SPB composition. The associativity of SPB guarantees that quantum gate sequences can be rearranged — a fundamental property needed for quantum circuit optimization.

An unexpected twist: while the Hadamard gate satisfies H² = I in Hilbert space (applying it twice returns to the original state), on stereographic coordinates H²(ζ) = -1/ζ, not ζ. The gate returns to the identity only after four applications. This "stereographic anomaly" reflects the deep nonlinearity of the projection.

### Pythagoras Meets SPB

Ancient mathematicians were fascinated by Pythagorean triples — sets of integers (a, b, c) with a² + b² = c². The famous tablet Plimpton 322, dating to roughly 1800 BCE, lists fifteen such triples.

All Pythagorean triples arise from the SPB parametrization. For any rational number t = m/n, the point on the unit circle at "stereographic angle" t has coordinates:

$$\left(\frac{n^2 - m^2}{n^2 + m^2}, \frac{2mn}{n^2 + m^2}\right)$$

The triple (n²-m², 2mn, n²+m²) is always Pythagorean. Setting m=1, n=2 gives (3, 4, 5). Setting m=2, n=3 gives (5, 12, 13). Every primitive triple arises this way.

But there's more. The identity (a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)² — proved by the Indian mathematician Brahmagupta in the 7th century — is secretly SPB composition in disguise. The "angles" b/a and d/c combine via SPB to give the "angle" of the product.

### The Finite Field Mystery

Perhaps the deepest number-theoretic discovery in the SPB program concerns arithmetic modulo primes. Over the finite field 𝔽_p, the SPB operation creates a finite group whose order depends on a surprising condition:

- If p leaves remainder 3 when divided by 4, the SPB group has order **p + 1**
- If p leaves remainder 1 when divided by 4, the SPB group has order **p - 1**

The determining factor? Whether -1 has a square root mod p — the first supplement to the law of quadratic reciprocity, one of the crown jewels of number theory.

This "p ± 1 law" has been computationally verified for all primes up to 47 with machine-checked proofs. A complete formal proof connecting it to quadratic reciprocity remains one of the program's most important open problems.

### A Machine-Verified Mathematics

What makes this research program distinctive is its commitment to **machine verification**. Over 170 theorems about the SPB have been formally proved using the Lean 4 theorem prover and its mathematical library Mathlib. Every proof is checked by computer — not just the computation, but the logical reasoning itself.

This matters because mathematics is becoming increasingly complex. Subtle errors can persist in published proofs for years or decades. Machine verification eliminates this risk entirely: either the proof checks or it doesn't. There's no ambiguity.

The SPB formalization covers:
- **Algebra**: commutativity, associativity, identity, inverses, the binary tree identity
- **Analysis**: derivatives, monotonicity, contraction bounds, the Cayley transform
- **Number theory**: Pythagorean triples, Brahmagupta's identity, Machin formulas, finite field groups
- **Physics**: subluminal closure, light invariance, rapidity addition, Wick rotation
- **Quantum computing**: Hadamard gate, phase gate, gate composition
- **Geometry**: hyperbolic distance, cross-ratio invariance, Weierstrass substitution

### What Comes Next?

The SPB research program has opened dozens of new questions:

**Can SPB neural networks outperform standard architectures for angular data?** The SPB neuron y = (x+w)/(1+xw) automatically maps the interval (-1,1) to itself, with no activation function needed. Early computational experiments are promising.

**Is there an efficient quantum gate synthesis algorithm based on SPB?** Since quantum gates are SPB operations on stereographic coordinates, optimal gate sequences might correspond to shortest SPB expressions — connecting quantum compilation to addition chain theory.

**Can the SPB framework extend to the Langlands program?** The L-function ζ(s)·L(s, χ₋₄) that counts representations as sums of two squares is naturally associated with SPB. Does this connection run deeper?

**What is the tropical SPB?** In tropical mathematics, where addition becomes minimum and multiplication becomes addition, the SPB formula transforms into something new and strange. Its algebraic structure is only beginning to be understood.

### The Bigger Picture

Mathematics is full of "unreasonable connections" — formulas and structures that appear in far more contexts than anyone expects. The Gaussian distribution, the exponential function, the Fourier transform — all have this quality.

The SPB formula (x+y)/(1-xy) deserves to join this list. It's the simplest rational parametrization of the simplest Lie group, and from this minimality flows its universality. Every time you encounter rotation, periodicity, phase, angle, projection, or conformal symmetry, you're implicitly encountering the SPB.

The formal verification program has transformed this from a collection of observations into a rigorous mathematical framework. And with over 50 open problems spanning the breadth of modern mathematics, the Stereographic Projection Bridge is far from fully explored. It may be centuries old, but its deepest implications are only now coming into focus.

---

*The SPB formalization project is open source, with all Lean 4 proofs, Python demonstrations, and visualizations freely available. The project welcomes contributions from mathematicians, physicists, and computer scientists at all levels.*
