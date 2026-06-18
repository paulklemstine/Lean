# The Formula That Connects Everything: How One Simple Fraction Unifies Five Branches of Mathematics

*A formula first written down centuries ago for adding angles turns out to be the key to understanding everything from Einstein's relativity to quantum computing — and a computer has now proved it with mathematical certainty.*

---

## A Single Formula, Five Worlds

What if one formula could explain how angles combine, how the universe limits speed, how to draw circles on a flat map, and how to build the next generation of artificial intelligence? It sounds impossible. But mathematicians have discovered that this formula exists — and it's surprisingly simple:

$$\text{spb}(x, y) = \frac{x + y}{1 - xy}$$

Take two numbers, add them on top, multiply them and subtract from one on the bottom. That's it. This is the **Stereographic Projection Bridge** — or SPB for short — and it turns out to be one of the most connected formulas in all of mathematics.

## Hidden in Plain Sight

If you've taken trigonometry, you might recognize this formula. It's the tangent addition law: tan(α + β) = (tan α + tan β)/(1 − tan α · tan β). Students memorize it, use it on exams, and promptly forget it. But this formula has been hiding a secret.

The tangent function doesn't just add angles — it encodes an entire geometric universe. When you apply SPB to the number line, you're actually performing rotations on a circle, viewed through a special lens called **stereographic projection**. Imagine placing a circle on top of a line, then projecting every point on the circle down to the line using rays from the top of the circle. The circle's rotation — the simplest geometric motion — becomes this innocent-looking fraction on the number line.

## Einstein's Formula, With a Sign Flip

Here's where it gets extraordinary. Change one tiny detail — flip the minus sign in the denominator to a plus sign:

$$v_1 \oplus v_2 = \frac{v_1 + v_2}{1 + v_1 v_2}$$

This is Einstein's formula for adding velocities in special relativity. When two spaceships are flying in the same direction, you can't just add their speeds the way Galileo thought. Einstein showed that velocities compose according to this formula (with the speed of light set to 1).

The connection is profound. The sign flip is precisely what physicists call a **Wick rotation** — the mathematical trick that converts between ordinary space and the spacetime of relativity. One sign change takes you from the world of circles and rotations to the world of hyperbolic geometry and Lorentz boosts.

And it has a beautiful consequence: no matter how fast two sub-light-speed objects are moving, their combined speed is always less than the speed of light. The SPB formula guarantees it. If |v₁| < 1 and |v₂| < 1, then |v₁ ⊕ v₂| < 1 — always. The speed of light is an absolute barrier, baked into the algebra.

## The Cayley Transform: The Bridge Operator

The key to understanding why SPB works is the **Cayley transform**: C(x) = (1 + ix)/(1 − ix). This formula converts any real number into a point on the unit circle in the complex plane, and it has a magical property:

**C(spb(x, y)) = C(x) × C(y)**

In words: applying SPB on the number line is the same as multiplying on the circle. The Cayley transform is a perfect translator between two mathematical languages — the language of fractions on the real line and the language of rotations on the circle.

This makes SPB what mathematicians call a **group homomorphism**. It's not just a formula; it's a bridge between two algebraic worlds, preserving all their structure.

## Machine-Verified Truth

In an age where scientific results are sometimes questioned, a team has gone further than traditional mathematical proof. They've formalized over 40 theorems about SPB in **Lean 4**, a computer proof assistant that checks every logical step with the same rigor that a computer verifies software. The proofs are not just written down — they are *machine-verified*, meaning a silicon brain has confirmed every step is correct.

This includes:
- All four group axioms (identity, inverse, commutativity, associativity)
- The Cayley transform's unitarity (it always hits the circle)
- Einstein's sub-luminal closure (speeds can't exceed light)
- A beautiful invariance theorem involving the **Cauchy distribution** — the bell-curve's rebellious cousin with infinite tails

## The Cauchy Distribution: SPB's Natural Rhythm

Speaking of the Cauchy distribution, one of the most surprising discoveries is that this famous probability distribution — f(x) = 1/(π(1+x²)) — is the natural "heartbeat" of SPB.

When you repeatedly apply SPB with a fixed parameter a (that is, x₁ = spb(x₀, a), x₂ = spb(x₁, a), ...), the Cauchy distribution remains perfectly unchanged. No matter what value of a you choose, the Cauchy distribution is invariant. This was proved formally in Lean 4.

Why? Because the Cauchy distribution is what the uniform distribution on a circle looks like when you project it onto a line via stereographic projection. Since SPB IS stereographic projection, the Cauchy distribution is its natural measure — the "volume form" of the SPB universe.

## Chebyshev Polynomials: SPB's Children

Apply SPB to a number x with itself: spb(x, x) = 2x/(1−x²). This is the tangent double-angle formula. Apply again: you get the triple-angle formula. Keep going, and you generate the entire family of **Chebyshev polynomials** — mathematical objects used in everything from polynomial approximation to digital filter design.

The formula spbPow(tan θ, n) = tan(nθ) says that SPB iteration IS multiple-angle generation. This single formula replaces pages of trigonometric identities.

## What's Next?

The SPB framework opens over 30 research directions. Here are the most exciting:

**SPB Neural Networks**: Could SPB replace the weighted-sum-plus-activation pattern that drives modern AI? SPB neurons would naturally learn periodic and rotational patterns, with built-in self-normalization from the circle group's compactness. Early analysis suggests this could be particularly powerful for tasks involving phase, rotation, or cyclical data.

**Higher-Dimensional SPB**: In three dimensions, stereographic projection of S³ → ℝ³ should produce a non-commutative SPB that recovers Hamilton's quaternions. In seven dimensions, it should connect to the octonions and the exceptional Lie group G₂. This could provide new computational tools for 3D graphics, robotics, and quantum mechanics.

**Thomas Precession**: In 1D, SPB is commutative — the order doesn't matter. But in 3D, composing Lorentz boosts in different directions produces the Thomas-Wigner rotation, a purely relativistic effect with no classical analogue. Expressing this as an SPB "commutator defect" could yield new insights into the geometry of spacetime.

**Quantum Computing**: On the Bloch sphere, which represents the state of a qubit, stereographic projection converts quantum states to complex numbers. Some quantum gates become SPB operations in this coordinate system, suggesting new approaches to quantum circuit design.

## The Deeper Message

Perhaps the most profound lesson of SPB is that deep mathematical connections often hide inside elementary formulas. Every student learns the tangent addition law, but few realize it encodes the entire circle group, bridges to Einstein's relativity, generates Chebyshev polynomials, and carries the Cauchy distribution as its natural measure.

Mathematics is not a collection of isolated techniques — it is a web of hidden connections. The Stereographic Projection Bridge is a particularly brilliant thread in that web, connecting five branches of mathematics through a single, beautiful fraction.

And now, for the first time, a computer has verified that it all checks out.

---

*The formal proofs described in this article are available as open-source Lean 4 code.*
