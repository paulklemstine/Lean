# The Simple Formula That Connects Einstein, Ancient Mathematics, and the Shape of Uncertainty

*A formula discovered by ancient mathematicians turns out to encode special relativity, the geometry of circles, and the mathematics of randomness — and now computers have verified it with absolute certainty.*

---

## A Formula Hidden in Plain Sight

Take two numbers, add them, and divide by one minus their product:

$$\frac{x + y}{1 - xy}$$

This unassuming expression — called the **Stereographic Projection Bridge** (SPB) — may be one of the most quietly powerful formulas in all of mathematics. It appears, often in disguise, across an astonishing range of fields: trigonometry, special relativity, number theory, probability, and even the design of computer chips.

Now, a team of researchers has used computer proof assistants — software that can verify mathematical arguments with absolute certainty — to confirm dozens of deep properties of this formula, answering open questions and revealing new connections that had gone unnoticed for centuries.

## Three Formulas in One

The SPB formula encodes three distinct mathematical ideas simultaneously:

### 1. The Tangent Addition Formula (Ancient Trigonometry)
If you've taken trigonometry, you may remember: tan(α + β) = (tan α + tan β)/(1 − tan α · tan β). That's exactly SPB applied to the tangents of two angles. Ancient astronomers used this to combine angle measurements; today it drives everything from GPS navigation to computer graphics.

### 2. Einstein's Velocity Addition (1905)
When Einstein formulated special relativity, he discovered that velocities don't simply add up. If you're on a train moving at speed *v* and throw a ball at speed *w*, the combined speed isn't *v + w* — it's *(v + w)/(1 + vw/c²)*. Normalize the speed of light to 1, flip a sign, and you get the SPB formula. The fact that |spbH(x,y)| < 1 whenever |x| < 1 and |y| < 1 — now computer-verified — is precisely the statement that you can never exceed the speed of light by combining subluminal velocities.

### 3. The Circle Group (Geometry)
If you draw the unit circle and project it onto a line through stereographic projection, the circle's rotation becomes the SPB operation on the line. The formula literally bridges the geometry of circles with the algebra of the real numbers.

## What the Computers Proved

Using the Lean theorem prover — software that checks every logical step — the researchers verified over 50 properties of SPB, including:

**No fixed points.** When you apply SPB translation (shifting everything by a fixed amount *a*), nothing stays in place — unless *a* = 0. Mathematically, the equation spb(x, a) = x has no solution when a ≠ 0. This is because SPB encodes a *rotation*, and rotations (other than the identity) don't have fixed points on the circle.

**Cross-ratio invariance.** The cross-ratio is a number assigned to four points that remains unchanged under perspective transformations — it's the mathematical reason why railroad tracks appear to converge at the horizon. The computer verified that SPB preserves the cross-ratio, confirming it is a genuine Möbius transformation, the most fundamental type of symmetry in projective geometry.

**The Cauchy connection.** The Cauchy distribution — a probability distribution famous for having no mean or variance (its tails are so heavy that averages don't converge) — turns out to be the *natural* probability distribution for SPB. The computer verified the exact algebraic identity that makes the Cauchy density transform correctly under SPB. In a sense, the Cauchy distribution is to SPB what the Gaussian (bell curve) is to ordinary addition.

**Velocity contraction.** The computer formally verified that Einstein's velocity addition always maps subluminal speeds to subluminal speeds — a mathematical theorem that encodes one of the most celebrated facts in physics.

## Hidden Connections

Perhaps the most surprising results are the connections between seemingly unrelated mathematical domains:

### SPB and Complex Numbers
The SPB formula is secretly *complex number multiplication in disguise*. If you represent a real number *x* as the complex number 1 + xi, then:

(1 + xi)(1 + yi) = (1 − xy) + (x + y)i

The real part is the SPB denominator; the imaginary part is the SPB numerator. This means SPB is, at its core, multiplication of complex numbers on the line Re(z) = 1.

### SPB and Pythagorean Triples
If *x = p/q* is a rational number, then the SPB double formula spb(x,x) = 2x/(1−x²) generates the parametrization of all Pythagorean triples: (q²−p², 2pq, p²+q²). Every right triangle with integer sides comes from the SPB formula applied to a fraction.

### SPB and the Brahmagupta–Fibonacci Identity
The ancient identity (a²+b²)(c²+d²) = (ac−bd)² + (ad+bc)² — proved by Brahmagupta in 628 AD and rediscovered by Fibonacci in 1225 — is exactly the statement that the SPB norm N(x) = 1 + x² is multiplicative. The computer verified this as a consequence of complex number norm multiplicativity.

## Why Computer Verification Matters

"Mathematics is the queen of the sciences," Carl Friedrich Gauss famously said. But even queens make mistakes. Published mathematical proofs sometimes contain errors — subtle gaps in logic that human reviewers miss. The four-color theorem, the classification of finite simple groups, and Kepler's conjecture all had proofs that were initially questioned.

Computer proof assistants change this calculus. When the Lean system verifies a proof, it checks every logical step against a small set of foundational axioms. There is no ambiguity, no "the reader can verify that..." — either the proof compiles or it doesn't. The SPB results represent a new standard of mathematical certainty.

## What's Next?

The SPB framework opens several exciting research directions:

**Quantum computing.** The SPB matrix M(a) = [[1, a], [-a, 1]] defines a one-parameter family of transformations that could serve as quantum gates. Its elliptic nature (no real eigenvalues for a ≠ 0) means it naturally implements rotations on the Bloch sphere.

**Signal processing.** The SPB linearization theorem — spb(x,y) ≈ x + y + xy(x+y)/(1−xy) — suggests new approaches to nonlinear filtering, where the "correction term" xy(x+y)/(1−xy) captures interference effects.

**Cryptography.** SPB's analogue of discrete exponentiation — iterating spb *n* times gives tan(n·arctan(x)) — could potentially form the basis of a Diffie-Hellman-like key exchange protocol, where the "hard problem" is computing the SPB discrete logarithm.

**Machine learning.** SPB neurons — activation functions based on spb(wx, b) instead of σ(wx + b) — naturally capture angular relationships in data, potentially outperforming standard architectures on problems with circular symmetry (compass directions, phase angles, time-of-day effects).

The SPB formula (x+y)/(1−xy) has been known for centuries, yet its full mathematical depth is only now being revealed through the combination of human insight and machine verification. Like many great mathematical ideas, its beauty lies not in complexity but in the extraordinary richness hidden within its simplicity.

---

*The research was verified using the Lean 4 theorem prover with the Mathlib mathematical library. All proofs are publicly available and can be independently verified by anyone with a computer.*
