# The One-Function Theorem: How a Single Function Can Approximate Everything

*A surprising mathematical discovery reveals that a single well-chosen function contains, in a precise algebraic sense, the blueprint for approximating every possible continuous function.*

---

In 1885, Karl Weierstrass proved one of the most beautiful results in mathematics: any continuous function on a closed interval can be approximated as closely as desired by polynomials. The result was elegant but seemed tied to the specific structure of polynomial algebra — the way you can add, multiply, and scale the simple function *x* to build up an arbitrarily rich library of approximating functions.

For over a century, mathematicians extended this idea in various directions. Could you approximate with trigonometric polynomials? (Yes — that's Fourier analysis.) Could you approximate with exponential polynomials? (Yes, under the right conditions.) Each new result required its own proof, its own machinery, its own special argument. The mathematical landscape was dotted with isolated approximation theorems, each a small island of knowledge.

Now, a new framework — the **Generator Algebra** — reveals that all these islands are connected by a single underwater ridge. The discovery is startling in its simplicity: *any injective continuous function generates a dense subalgebra*. In plain terms, if you start with just one continuous function that never takes the same value twice, you can build polynomial-like combinations of that function to approximate anything.

## The Generator Algebra

The idea is beguilingly simple. Take any continuous function φ on a compact space — say, a closed interval [a, b]. Form all possible "polynomials in φ": expressions like 3φ² − 2φ + 7, or more generally, any sum of products and scalar multiples of φ with itself. This collection of functions is what mathematicians call the **generator algebra** of φ, denoted Gen(φ).

The question that drives the entire theory is: *How much of the universe of continuous functions can Gen(φ) reach?*

If φ is the identity function — φ(x) = x — then Gen(φ) is just the ordinary polynomials, and Weierstrass's theorem tells us it can approximate everything. But what if φ is the exponential function? What about the sine function, or something more exotic?

## The Injectivity Principle

The answer turns out to depend on a single property of φ: **injectivity**. A function is injective if it never maps two different inputs to the same output — it preserves distinctness.

The **Generator Algebra Density Theorem** states:

> *If φ is continuous and injective on a compact space, then Gen(φ) is dense in the space of all continuous functions.*

This means polynomial expressions in φ can approximate any continuous function to arbitrary precision. The proof is a elegant application of the Stone-Weierstrass theorem, but the insight is deeper: injectivity is not just sufficient for density — it is *necessary*. The converse holds: Gen(φ) separates points (the technical condition for Stone-Weierstrass) if and only if φ is injective.

This creates a perfect dichotomy: either φ is injective and Gen(φ) can approximate everything, or φ is not injective and Gen(φ) is fundamentally limited — it can only approximate functions that are "compatible" with the fibers of φ (the sets of points where φ takes the same value).

## Unification

The power of the framework lies in its unification:

- **Classical Weierstrass**: The identity function id(x) = x is injective. Gen(id) = polynomials. Density follows.
- **Exponential approximation**: The exponential function exp(x) is injective. Gen(exp) = exponential polynomials (sums of products of exponentials). Density follows.
- **Logarithmic approximation**: log(x) is injective on (0, ∞). Gen(log) = polynomials in logarithms. Density follows.
- **Any monotone function**: Strictly monotone continuous functions are injective. Their generator algebras are all dense.

What was once a collection of separate theorems — each requiring its own proof — becomes a single insight: check injectivity, conclude density.

## The Approximation Kernel

When φ fails to be injective, the framework doesn't just say "approximation fails" — it quantifies exactly *how* it fails. The **Approximation Kernel** of φ is the equivalence relation that identifies points where φ takes the same value. If φ(a) = φ(b), then every polynomial in φ also agrees at a and b. The kernel precisely characterizes what Gen(φ) *cannot* distinguish.

This leads to a beautiful structure: the kernel of φ determines a quotient space, and Gen(φ) is dense in the continuous functions on that quotient. The kernel is the complete invariant of approximation power.

## The Depth Collapse Theorem

Perhaps the most surprising result concerns **depth**. In approximation theory and neural network design, there is a natural hierarchy: depth-1 approximations use simple combinations of a base function, depth-2 use compositions of those combinations, and so on. The EML (Exponential-Multiply-Logarithm) framework, which motivated this research, organizes functions by how many nested exponentials they require.

One might expect that deeper nesting gives fundamentally more approximation power — that there are functions requiring depth 3 that cannot be approximated at depth 2. The **Depth Collapse Theorem** shows this is false for qualitative approximation:

> *If any single depth level contains an injective function, then every depth level is already dense.*

Since the exponential function is injective and lives at depth 1, depth 1 can already approximate everything. Depth 2, 3, and beyond add no qualitative approximation power. This doesn't mean depth is irrelevant — the efficiency of approximation may still depend on depth — but the *possibility* of approximation is settled at depth 1.

This result has a provocative interpretation for neural network theory. Adding more layers to a network doesn't expand what can be *represented* (that was already known from universal approximation theorems), but the Generator Algebra framework shows this is not a coincidence — it's a structural consequence of having an injective activation function at any layer.

## The Approximation Spectrum

Looking forward, the most promising direction is the **Approximation Spectrum**: a new invariant that captures the "fingerprint" of a generating function. For each generator φ, the spectrum records the structure of its fibers — which points it identifies and how. Simple spectra (injective generators) give full density. Complex spectra (generators with large fibers) give limited approximation.

The spectrum opens the door to a systematic classification of approximation schemes: which generators are equivalent (generate the same closed algebra)? Which are strictly weaker? Can two weak generators complement each other to give full density?

The **Joint Density Theorem** provides one answer: if two generators φ and ψ "jointly separate points" — meaning that for any two distinct points, at least one of the generators distinguishes them — then their combined algebra is dense. This is the mathematical foundation for combining weak learners into strong ones, a principle that resonates with ensemble methods in machine learning.

## A Single Seed

The Generator Algebra framework reveals a profound economy in mathematics: one function, if chosen well, contains within itself the seeds of universal approximation. The function need not be special — it need not be a polynomial, an exponential, or anything with a nice closed form. It need only be continuous and injective. From that single seed, the algebra of its polynomial expressions grows dense in the space of all continuous functions.

It is a reminder that in mathematics, power often comes not from complexity but from a well-chosen simple structure, rigorously understood.

---

*This research connects approximation theory, functional analysis, and algebra through a novel framework that unifies classical results and opens new directions in quantitative approximation complexity.*
