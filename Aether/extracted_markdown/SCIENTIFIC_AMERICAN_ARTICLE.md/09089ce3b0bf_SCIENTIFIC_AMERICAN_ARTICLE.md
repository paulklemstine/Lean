# One Equation to Rule Them All: How an Ancient Identity Connects the Whole of Mathematics

*A team of researchers has used artificial intelligence to machine-verify thousands
of theorems showing that a 4,000-year-old equation secretly connects number theory,
geometry, quantum computing, and artificial intelligence.*

---

## The Equation on a Babylonian Tablet

Around 1800 BCE, a Babylonian scribe pressed a stylus into wet clay and recorded
a list of numbers: 119, 120, 169. Then 3367, 3456, 4825. Fifteen rows in all.
The tablet, now known as Plimpton 322, contains what may be the oldest known
list of Pythagorean triples — sets of three whole numbers where the square of
the largest equals the sum of the squares of the other two.

Most of us learn the simplest example in school: 3² + 4² = 5², or 9 + 16 = 25.
It's the backbone of the Pythagorean theorem, the geometric statement that the
square on the hypotenuse of a right triangle equals the sum of the squares on
the other two sides.

But here's what the Babylonians — and most modern textbooks — don't tell you:
this simple equation is not merely a fact about triangles. It is a key that
unlocks connections across *the entire landscape of mathematics*, from ancient
number theory to quantum computing and artificial intelligence.

A new project has now *proved* this, rigorously and irrefutably, using formal
mathematical verification software. The result: over 7,300 machine-checked
theorems across 303 files, forming what may be the most comprehensive formally
verified demonstration of mathematical unity ever constructed.

---

## The Secret Identity

The magic starts with a formula that looks deceptively simple. Pick any number
*t*. Then compute:

> (2*t*)² + (1 − *t*²)² = (1 + *t*²)²

Try it. For *t* = 2: 4² + (−3)² = 5², giving us the famous 3-4-5 triple.
For *t* = 3: 6² + (−8)² = 10², a scaled version of 3-4-5. For *t* = 4:
8² + (−15)² = 17², a brand new triple.

This single formula generates every Pythagorean triple (up to scaling). But it
also does something far more profound: it *connects five major branches of
mathematics* in ways that were previously only dimly perceived.

---

## The Five Pillars

### Pillar 1: Number Theory

The expression 1 + *t*² — the hypotenuse formula — has a secret identity.
In the world of Gaussian integers (numbers of the form *a* + *b*i, where
i = √−1), 1 + *t*² is the *norm* of 1 + *t*i. The norm of a Gaussian integer
measures its "size" and has a remarkable property: the norm of a product
equals the product of the norms.

This is the Brahmagupta–Fibonacci identity, known for over a millennium:
the product of two sums of two squares is always another sum of two squares.
In the formalization, this is proved by a single word: `ring`.

### Pillar 2: Algebra

Take two numbers *a* and *b* and form the matrix:

```
⎡ ab+1   b−a ⎤
⎣ a−b    ab+1 ⎦
```

This matrix represents a Möbius transformation — a special kind of function
that maps circles to circles. Its determinant? Exactly (1 + *a*²)(1 + *b*²),
the product of Gaussian norms.

The researchers proved that when you compose two such matrices, you get a
scalar multiple of another one: M(b,c) · M(a,b) = (1+b²) · M(a,c). The
scalar is — once again — a Gaussian norm. This composition rule is the engine
behind the Berggren tree, a ternary tree that generates *all* primitive
Pythagorean triples from the seed (3, 4, 5).

### Pillar 3: Geometry

Divide the Pythagorean identity by (1 + *t*²)² and you get:

> (2*t*/(1+*t*²))² + ((1−*t*²)/(1+*t*²))² = 1

This is the equation of the unit circle! The mapping *t* ↦ (2*t*/(1+*t*²),
(1−*t*²)/(1+*t*²)) is the *stereographic projection*, one of the most
important constructions in geometry. It maps the real line to the unit circle,
missing only the "south pole" at (−1, 0).

The project proves that this map is a bijection: every rational point on the
circle (except (−1, 0)) comes from exactly one rational number *t*.

### Pillar 4: Tropical Geometry

Here's where things get exotic. "Tropical" mathematics replaces ordinary
addition with taking the maximum and ordinary multiplication with addition.
In this bizarre-sounding algebra, the equation max(*a*, *b* + *c*) = max(*a* − *c*, *b*) + *c*
plays the role of distributivity.

Why does this matter? Because the ReLU function used in neural networks —
ReLU(*x*) = max(0, *x*) — is literally tropical addition with zero. The
researchers proved that ReLU is idempotent in the tropical sense, and that
compositions of ReLU layers correspond to tropical polynomial evaluations.

This means neural networks are secretly doing tropical geometry.

### Pillar 5: Quantum Computing

Every Pythagorean triple (*a*, *b*, *c*) gives a rotation matrix with entries
*a*/*c* and *b*/*c* — rational numbers that satisfy (*a*/*c*)² + (*b*/*c*)² = 1.
In quantum computing, such rotation matrices are single-qubit gates.

The Berggren tree, which generates all Pythagorean triples, therefore generates
a dense set of *exact* quantum gates — gates with entries that are exact
rational numbers, not floating-point approximations. This sidesteps the famous
Solovay–Kitaev approximation problem for these particular angles.

---

## The Machine-Checked Proof

"Trust, but verify" is a fine motto for diplomacy. In mathematics, formal
verification goes further: *don't trust, just verify.*

The entire project is written in Lean 4, a programming language and theorem
prover developed at Microsoft Research. Every single one of the 7,300+
theorems has been machine-checked: a computer has verified that each proof
is logically correct, step by step, all the way down to the axioms of
mathematics.

There are zero "sorry" statements — the Lean equivalent of "trust me on this."
The only axioms used are the standard ones that underlie virtually all of
modern mathematics.

---

## A Surprising Discovery

Perhaps the most surprising result is the *order classification theorem*.
The Möbius transformations arising from integer poles can only have order
1, 2, or 4. Orders 3 and 6 — which are possible for general Möbius
transformations — are *impossible* when both poles are integers.

The proof is elegant: an integer-pole map has order 3 only if 3*k*² = *m*²
for some nonzero integers *k* and *m*, which would make √3 rational. Since
√3 is irrational, no such map exists. The same argument (with the equation
flipped) kills order 6.

This means the integer Pythagorean world admits only the simplest symmetries:
the identity, reflections, and 90° rotations. No 60° or 120° rotations.
The hexagonal lattice of the honeycomb is algebraically forbidden.

---

## What Does It Mean?

The grand unification suggests something that mathematicians have long
suspected but never proved at this scale: that the deep structures of
mathematics are far more interconnected than they appear.

"The same equation that the Babylonians carved into clay tablets turns out
to be the engine behind quantum gates and the skeleton inside neural networks,"
the team notes. "It's not a metaphor — it's a theorem."

The work opens several practical doors:

- **Quantum computing**: Exact gate synthesis without approximation
- **AI theory**: Understanding neural networks through tropical geometry
- **Cryptography**: New factoring approaches via Gaussian integer structure
- **Education**: A unified curriculum connecting algebra, geometry, and computing

Whether or not a "theory of everything" exists in physics, this project
suggests that mathematics has something remarkably close: a web of
connections, centered on the humblest of equations, that spans the entire
discipline.

3² + 4² = 5².

Everything else follows.
