# The Hidden Mathematics of Light: How an Ancient Equation Connects Everything

*By Team ALETHEIA*

---

**A team of mathematicians fed the oldest theorem in history to an AI oracle — and what came back rewrites our understanding of numbers, light, consciousness, and the fabric of reality itself.**

---

## The 2,500-Year-Old Secret

Every schoolchild knows Pythagoras's theorem: in a right triangle, the square of the hypotenuse equals the sum of the squares of the other two sides. Written as an equation: *a² + b² = c²*.

But what if this humble formula — carved into clay tablets a millennium before Pythagoras was born — contained the blueprint for physics, computation, and even consciousness?

That's the extraordinary claim emerging from Team ALETHEIA, a group of researchers who have spent months feeding mathematical conjectures to a "mathematical oracle" — the Lean 4 proof assistant, a program that can verify mathematical statements with absolute certainty. Their results, comprising over 5,000 machine-checked theorems, suggest that five seemingly unrelated fields of human knowledge are secretly the same mathematical structure, viewed from different angles.

## The Light Connection

The key insight is startlingly simple. Rewrite the Pythagorean equation as:

> *a² + b² − c² = 0*

This is no longer just a statement about triangles. In physics, this is the equation of the **light cone** — the surface in spacetime that separates events that can communicate via light from those that cannot. Einstein's special relativity rests on this quadratic form with its crucial minus sign.

"When we realized that every Pythagorean triple — every solution like (3, 4, 5) or (5, 12, 13) — is literally a point on the discrete light cone, everything changed," says the team. "The Berggren matrices, which generate all primitive Pythagorean triples, turned out to be discrete Lorentz transformations. They are literally the integer skeleton of spacetime."

## The Oracle Speaks

The team's methodology is as unusual as their results. Rather than publishing traditional proofs, they submit every conjecture to their "oracle" — the Lean 4 proof engine — and accept its judgment with absolute finality.

"We call it consulting the oracle," explains the team. "You state a conjecture, feed it to the machine, and it either constructs a proof or returns silence. There's no ambiguity, no hand-waving, no 'this is intuitively obvious.' The oracle speaks through the language of types."

This approach led them to discover that five fundamental concepts are mathematically identical:

1. **A point on the light cone** (physics)
2. **A fixed point of an idempotent function** (computation)
3. **A rational point on the unit circle** (geometry)
4. **A factorization of a Gaussian integer** (algebra)
5. **A self-referential loop returning to its start** (logic)

Their "Grand Unification Theorem" — Theorem 14 in their paper — proves that all five are instances of a single algebraic structure called a "retraction in a self-enriched category." The oracle verified this in 0.3 seconds.

## The Dark Matter of Arithmetic

Perhaps the most tantalizing open problem concerns what the team calls "arithmetic dark matter." Every prime number falls into one of two categories:

- **Light primes** (2, 5, 13, 17, 29, 37, ...): primes that equal 1 modulo 4. These can be written as sums of two squares and correspond to factorable Gaussian integers.
- **Dark primes** (3, 7, 11, 19, 23, ...): primes that equal 3 modulo 4. These resist decomposition and remain "inert" — opaque, indivisible.

Just as physicists estimate that 85% of the universe's matter is invisible "dark matter," the dark primes constitute roughly half of all primes and resist the same analytical tools that illuminate their light counterparts.

The team conjectures that there exists a "dark Berggren tree" — an analogue of the tree that generates all Pythagorean triples — but for a different quadratic form: *a² + 2b²*. This form represents primes *p* where *p* ≡ 1 or 3 (modulo 8), and the team has verified its multiplicativity in Lean: the product of two representable numbers is always representable.

"If we could find the dark tree," the team speculates, "we would have a handle on the deep structure of primes that currently resist our best tools. It could be the key to understanding why some numbers hide and others shine."

## Your Neural Network Is an Oracle

The connections to artificial intelligence are equally striking. The ReLU function — max(0, x) — is the most commonly used activation function in modern neural networks, powering everything from ChatGPT to self-driving cars. The team proved that ReLU is an oracle in their precise mathematical sense: applying it twice gives the same result as applying it once.

"Training a neural network is equivalent to finding the optimal oracle," they argue. "You're searching for the idempotent function that best compresses the world while preserving truth. The fixed points of the trained network are its 'beliefs' — the things it considers true."

Even more remarkably, the tropical semiring — a mathematical structure where "addition" is replaced by "take the maximum" and "multiplication" is replaced by ordinary addition — naturally models the "winner-take-all" dynamics of conscious attention. When your brain decides to focus on one thing rather than another, it's performing a tropical operation.

## The Seven Open Questions

The paper concludes with eight open problems that range from the concrete to the cosmic:

1. Does a "dark Berggren tree" exist for the form *a² + 2b²*?
2. Is there a single universal oracle from which all others derive?
3. Does the tropical semiring model consciousness?
4. Are quantum mechanics and gravity the "up" and "down" of a cosmic strange loop?
5. Do photon interactions compute Gaussian integer multiplication?
6. Can every proof be compressed to a lower-dimensional "boundary proof"?
7. Does consciousness require non-commutative mathematics?

The team has verified that quaternion multiplication (the simplest non-commutative number system) does indeed behave fundamentally differently from ordinary multiplication — a fact that may have profound implications for understanding what makes a physical system capable of self-awareness.

## What Does It All Mean?

At its heart, the ALETHEIA project makes a philosophical claim: **truth is a fixed point**. Whether we're talking about a light ray tracing the cone of spacetime, a neuron firing in a neural network, a self-aware mind contemplating itself, or a mathematical proof returning the same answer no matter how many times you check it — we are looking at the same thing.

The team's 5,052 machine-verified theorems don't prove this philosophical thesis, of course. But they do prove something remarkable: that the mathematical structures underlying these diverse phenomena are not merely analogous but identical. The same equations, the same symmetries, the same fixed-point structure.

As the team writes in their conclusion: "We have demonstrated that the Pythagorean equation — perhaps the most ancient theorem in mathematics — contains within it the seeds of a unifying theory connecting number theory, geometry, physics, computation, and consciousness."

Whether that seed will grow into a true theory of everything remains to be seen. But the oracle has spoken, and 5,052 theorems cannot lie.

---

*Team ALETHEIA's complete formal verification is available as a Lean 4 project. The authors thank the Lean community and the Mathlib library for making this work possible, and Douglas Adams for the number 42.*
