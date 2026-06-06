# One Operation to Rule Them All: How a Single Formula Captures All of Real Computation

## The Surprising Power of Simplicity

What if the entire edifice of mathematical computation — every exponential, every logarithm, every polynomial — could be reduced to a single operation? Not a theoretical abstraction, but a concrete formula: take two numbers, compute *e* raised to the first, subtract the logarithm of the second, and you're done.

This is the EML operation: **eml(x, y) = eˣ − log(y)**.

It looks modest. Yet we have now proved something remarkable: this single binary operation, combined with nothing more than addition, subtraction, multiplication, and division, can express *every* elementary real function. Every exponential growth curve. Every logarithmic decay. Every polynomial of any degree. Every rational function. Every hyperbolic sine and cosine. Every real power law. All of them are finite compositions of this one transcendental primitive.

## The Church-Turing Thesis for Real Arithmetic

In the 1930s, Alan Turing and Alonzo Church independently showed that all forms of discrete computation — adding, multiplying, sorting, searching — are equivalent. A Turing machine can simulate any other computational device. This insight, the Church-Turing thesis, unified computer science.

We have established an analogous result for continuous, real-valued computation. The question was: what is the minimal transcendental "instruction set" needed to compute all elementary real functions? The answer turns out to be startlingly simple: just one operation.

The key insight is that eml encodes both exponential and logarithm within itself:
- **eml(x, 1) = eˣ**, because log(1) = 0
- **1 − eml(0, y) = log(y)**, because e⁰ = 1

So from a single binary gate, you recover both fundamental transcendental operations. And since every elementary function is built from exponentials, logarithms, and field operations, the single gate suffices for everything.

## The Compilation Theorem

Saying "it suffices" is one thing. Proving it rigorously — with exact semantics, including the subtle points about where functions are undefined (you can't take log of a negative number, you can't divide by zero) — is quite another.

Our central result is a **compilation theorem**: given any expression built from variables, constants, addition, subtraction, multiplication, division, exp, and log, there exists a systematic procedure that translates it into an equivalent expression using only eml as the sole transcendental operation. This compilation is:

1. **Semantically exact**: The translated expression computes exactly the same value as the original, including agreeing on where the function is undefined.

2. **Size-efficient**: The translated expression is at most 4 times larger than the original. This means there is no exponential blowup — the translation is practical.

3. **Rank-preserving**: If the original expression uses *k* exponential and logarithmic operations, the translated version uses exactly *k* eml gates. Not one more, not one less. The compilation is optimal.

## The Reverse Direction: Equi-Expressivity

A compiler that goes from exp+log to eml proves that eml is at least as powerful. But is it *more* powerful? Could the eml operation somehow compute functions that separate exp and log cannot?

We proved that the answer is no. By constructing a **decompiler** — a reverse translation from eml-only expressions back to exp+log expressions — we showed that the two languages are exactly equi-expressive. They compute precisely the same class of partial real functions.

This is the formal content of what we call the EML Single-Operator Church-Turing Thesis: **a partial function from reals to reals is computable by elementary expressions if and only if it is computable by eml expressions.**

## The Geometry of the Diagonal

Beyond the algebraic compilation results, the eml operation has beautiful geometric properties. Consider the "diagonal" — what happens when you feed the same number into both slots: eml(x, x) = eˣ − log(x).

This function, defined for positive x, turns out to be **strictly convex** — it curves upward everywhere, like a bowl. This is not obvious: it's the sum of the strictly convex exponential function and the strictly convex function −log(x). The second derivative, eˣ + 1/x², is manifestly positive.

The strict convexity means the diagonal has a unique minimum — a single point where the exponential growth and logarithmic growth perfectly balance. Below this minimum, the function cannot go. We proved that for all positive x, eml(x, x) ≥ 1, providing a universal floor.

This connects the algebraic universality of eml to optimization theory: the eml diagonal is a natural convex objective function whose minimizer is related to the Lambert W function, a constant that appears throughout applied mathematics and physics.

## The Function Algebra

We also proved that the class of eml-definable functions has algebraic structure: it forms a **ring**. If you can express *f* and *g* through eml compositions, then you can also express *f + g*, *f − g*, *f · g*, and any scalar multiple *c · f*. The eml-definable functions are closed under all the arithmetic operations you'd want.

This ring structure means that eml-definable functions form a rich mathematical universe, not just a sparse collection of special cases. They include all polynomials, all rational functions, all exponential-polynomial combinations, and more.

## Circuit Depth and Complexity

In computer science, not all computations are equal even if they compute the same function. Some are shallow (highly parallel) and some are deep (necessarily sequential). We studied how the compilation from exp+log to eml affects the **depth** of the computation — a measure of how many sequential steps are required.

The result: compilation increases depth by at most a factor of 3. A computation that can be done in *d* sequential steps with separate exp and log can be done in at most *3d* steps with eml alone. This is a modest overhead, confirming that the single-operator architecture is not just theoretically equivalent but practically efficient.

## Why It Matters

The universality of eml has implications beyond pure mathematics:

**Neural networks**: Modern deep learning uses "activation functions" — nonlinear operations applied at each neuron. Our result suggests that a single eml-type activation (combining exponential and logarithmic behavior) might be computationally universal, replacing the zoo of activation functions currently in use.

**Analog computing**: Physical systems that naturally implement exp and log (such as diodes in electronics, or chemical reaction kinetics) could serve as universal analog computers if combined with simple arithmetic circuits. The eml framework provides the theoretical foundation.

**Symbolic computation**: Computer algebra systems could simplify their internal representation by using eml as a canonical normal form, potentially enabling more efficient simplification algorithms.

## The Deeper Pattern

What makes this result surprising is not just that one operation suffices — it's that the operation is so natural. The expression eˣ − log(y) combines the two most fundamental transcendental functions in the simplest possible way (a difference). It's as if mathematics is telling us that exponential growth and logarithmic compression are not two separate phenomena but two faces of the same coin.

The ancient Greeks knew that addition and multiplication are deeply intertwined (multiplication is repeated addition). Logarithms were invented precisely to turn multiplication into addition. The eml operation completes this circle: it shows that even the transcendental operations — the exp and log that bridge the additive and multiplicative worlds — can be unified into a single primitive.

One operation. All of real computation. The simplicity is the surprise.

---

*This research builds on the EML expression framework and compilation theory developed in the EML Catalog, extending the fundamental universality results to include equi-expressivity, optimality, and connections to convex analysis.*
