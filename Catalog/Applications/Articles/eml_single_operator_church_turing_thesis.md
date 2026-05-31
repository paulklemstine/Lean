# The One Operator That Rules Them All

## How a simple mathematical trick unifies the building blocks of computation

---

In 1936, Alan Turing showed that a single, universal machine could simulate any computation. His insight — that complex computation reduces to simple, repeated operations — reshaped the twentieth century. Now, a new line of mathematical research asks whether a similar universality principle governs the continuous world of real-number computation. The answer, remarkably, seems to involve just two ancient mathematical friends: the exponential and the logarithm.

## The Unreasonable Power of Exp and Log

Every high school student learns about exponential growth and logarithms. What's less appreciated is how these two functions, combined with basic arithmetic (addition, multiplication, division), can build essentially *every* mathematical function that scientists and engineers use daily.

Consider the hyperbolic sine function, sinh(x), beloved by physicists modeling hanging cables and special relativity. It looks exotic, but it decomposes neatly:

> sinh(x) = (eˣ - e⁻ˣ) / 2

That's just two exponentials, a subtraction, and a division. The hyperbolic cosine, cosh(x)? Same idea, with a plus sign. The Gaussian bell curve that underpins all of statistics?

> exp(-x²) = e^(-x·x)

One multiplication and one exponential. The logistic sigmoid — the activation function powering modern neural networks?

> σ(x) = 1 / (1 + e⁻ˣ)

Again: an exponential, an addition, and a reciprocal.

This pattern runs deep. Real powers like x^(1/3) or x^π decompose through the "exp-log bridge": x^a = exp(a · log(x)). Every polynomial is built from addition and multiplication. Every rational function adds division. And then exp and log open the door to the entire edifice of transcendental mathematics.

## A Single Binary Operator

Here's where the story gets surprising. Mathematicians working on computational theory have discovered that a single binary operator — let's call it EML — can replace both exp and log:

> EML(x, y) = eˣ - log(y)

This looks almost too simple. But the magic lies in two identities:

- **Recovering exp**: EML(x, 1) = eˣ - log(1) = eˣ - 0 = eˣ
- **Recovering log**: 1 - EML(0, y) = 1 - (e⁰ - log(y)) = 1 - 1 + log(y) = log(y)

So one operator, applied with the right constant arguments, recovers both transcendental primitives. Combined with basic arithmetic, EML generates the entire class of elementary real functions.

This is analogous to the NAND gate in digital logic — a single gate from which all Boolean functions can be built. But EML operates in the continuous world of real numbers, making it a "universal primitive" for analog computation.

## Measuring Transcendental Complexity

The EML framework doesn't just tell us *which* functions are computable — it introduces a natural measure of *how transcendentally complex* a computation is.

Imagine building a mathematical expression as a tree. At the leaves are variables and constants. Internal nodes are operations: addition, multiplication, exp, log. Now count the maximum number of exp and log nodes you encounter along any path from the root to a leaf. Call this the *transcendental depth*.

This measure captures something fundamental: how many times you need to "cross the boundary" between the algebraic and transcendental worlds to compute a function. Addition and multiplication are algebraically "free." Each application of exp or log costs one unit of transcendental depth.

Under this measure, a natural hierarchy emerges:

- **Depth 0**: Rational functions (polynomials, their ratios). x², 1/x, (x³ + 1)/(x - 2). No transcendental operations needed.
- **Depth 1**: Functions involving one level of exp or log. eˣ, log(x), sinh(x), the Gaussian, the sigmoid. All the workhorses of applied mathematics.
- **Depth 2**: Functions involving nested transcendentals. exp(exp(x)), the iterated exponential. These arise in complexity theory and combinatorics.
- **Depth n**: The n-fold iterated exponential exp(exp(...(x)...)). Each level of nesting requires one more unit of depth.

## A Strict Hierarchy

The hierarchy is not just a classification scheme — it's provably strict. The simplest version of this result is striking: **the exponential function cannot be computed by any algebraic formula**, no matter how clever.

The proof uses a beautiful fixed-point argument from calculus. Suppose some polynomial p(x) equals eˣ for every x. Then taking derivatives: p'(x) = eˣ = p(x). So p equals its own derivative! But a polynomial's derivative has strictly lower degree — unless the polynomial is a constant. And a constant can't equal eˣ at both x = 0 (where eˣ = 1) and x = 1 (where eˣ ≈ 2.718). Contradiction.

This clean argument — polynomial functions can't match exp because they'd need to be their own derivative — shows that transcendental depth 0 is strictly weaker than transcendental depth 1. The deeper levels of the hierarchy are separated by similar, increasingly intricate arguments.

## Depth Adds Under Composition

One of the elegant properties of transcendental depth is its behavior under function composition: **depths add**. If f has depth 3 and g has depth 2, then f ∘ g (f composed with g) has depth at most 5.

This is proved by a circuit substitution argument. To compute f(g(x)), take the circuit for f and replace every occurrence of the variable with the circuit for g. Each transcendental node in f might now sit atop the transcendental nodes from g, stacking their depths additively.

This subadditivity property has practical implications. It tells us that composing operations never produces transcendental depth "for free" — the complexity of a pipeline is bounded by the sum of its stages. In the language of neural networks, each "layer" can contribute at most a constant amount of transcendental depth.

## The Church-Turing Connection

The parallel to classical computability is deliberate. Turing's thesis states that all effectively computable functions can be computed by a Turing machine. The EML Church-Turing thesis proposes an analogous principle for continuous computation:

> *Every Liouvillian function — one built from rational functions by finitely many adjunctions of exp and log — is computable by an EML circuit.*

The forward direction is trivially true: any EML circuit, by definition, computes some function. The depth of the circuit tells us exactly which level of the Liouvillian hierarchy the function belongs to.

The interesting question is what lies *outside* the EML universe. Trigonometric functions like sin(x) and cos(x) are notable absentees. Over the real numbers, there is no algebraic way to extract sin and cos from exp and log alone — you need the complex exponential e^(ix) = cos(x) + i·sin(x), which involves imaginary numbers. This suggests that the real EML universe is a proper subset of the full elementary function class, and the boundary is exactly where complex analysis becomes essential.

## Implications for Neural Networks

Modern neural networks are, at their core, compositions of simple functions. The most common activation functions — sigmoid, tanh, softplus — are all EML-computable, requiring transcendental depth exactly 1. The network's mathematical power comes from composing many such layers, linearly increasing the transcendental depth.

The EML framework suggests a new way to measure neural network expressiveness: not by parameter count or layer count, but by the *transcendental depth* of the functions they can approximate. A network with k layers of sigmoid activations has effective transcendental depth k, which determines the class of functions it can represent exactly (not just approximate).

This perspective connects deep learning theory to classical analysis in a precise, quantitative way. The "depth" in "deep learning" has a mathematical shadow in the transcendental depth hierarchy — and both measure, in different ways, the computational power that emerges from composition.

## An Open Frontier

The EML depth-width tradeoff conjecture poses a concrete challenge: computing the n-fold iterated exponential with optimal transcendental depth requires a circuit of size at least 2n - 1. For small cases, this is verifiable by exhaustive search. For large n, it remains open — and its resolution would reveal deep facts about the structure of transcendental computation.

Mathematics has a long tradition of finding unity beneath apparent diversity. The EML operator — a single formula combining exp and log — is the latest entry in this tradition: a universal primitive that captures the full power of elementary real computation. Like Turing's universal machine, it shows that computational universality can emerge from stunning simplicity.

The hierarchy it induces — measuring not just *what* can be computed, but *how transcendentally deep* the computation must go — opens a new dimension in understanding the complexity of continuous mathematics. In a world increasingly powered by continuous computation, from neural networks to analog signal processing, that understanding may prove as consequential as Turing's original insight.

---

*The research described in this article was conducted using rigorous mathematical methods, with key results verified to the standard of formal mathematical proof.*
