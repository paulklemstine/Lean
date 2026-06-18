# The Hidden Arithmetic of Neural Networks: How Exponentials and Logarithms Learn Everything

## A Mathematical Discovery Reveals Why Simple Operations Can Approximate Any Continuous Function

Imagine you had only three tools: the exponential function, the logarithm, and basic arithmetic — addition and multiplication. Could you build any shape? Approximate any curve? The surprising answer, established through a chain of mathematical results that bridge 19th-century approximation theory with modern neural network design, is yes. And not just qualitatively — we now know *how well* these simple building blocks can approximate, with explicit guarantees.

## The Universal Building Blocks

At the heart of modern artificial intelligence lies an old question: given a set of simple operations, what can you build by combining them? The polynomials — sums of powers like 3x² + 2x - 1 — were the first family shown to approximate any continuous function, a celebrated result due to Weierstrass in 1885. But polynomials are wasteful: to approximate a function with sharp corners or rapid oscillations, you need enormously high degrees.

Neural networks use a different set of building blocks. The most fundamental are the *exponential function* e^x (which grows explosively) and its inverse, the *logarithm* log(x) (which grows agonizingly slowly). Combined with addition and multiplication, these form what researchers call "EML networks" — for Exponential, Multiplication, and Logarithm.

The key mathematical insight is this: the function x ↦ e^x is *strictly monotone* — it always increases. If two inputs differ, their exponentials must differ too. This seemingly simple property has profound consequences.

## The Separation Principle

The mathematical framework that makes everything work dates back to Marshall Stone, who in 1937 dramatically generalized Weierstrass's theorem. Stone showed that *any* collection of continuous functions that can "separate points" — meaning for any two distinct inputs, at least one function in the collection gives different outputs — can approximate all continuous functions.

For EML networks, the separation property follows from a clean chain of reasoning. Given any two distinct points x and y on a compact set, consider the function t ↦ exp(t). Since the exponential is strictly monotone, exp(x) ≠ exp(y). This single observation — that exponentiation preserves distinctness — is the engine that drives the entire theory.

But there's a subtlety. You don't just need individual functions that separate points. You need an *algebra* — a collection closed under addition, multiplication, and scalar multiplication. The EML generators {exp(w·x + b) : w, b ∈ ℝ} form exactly such a generating set. Their sums, products, and linear combinations build an algebra that separates every pair of distinct points.

## From Existence to Rates

Knowing that EML networks *can* approximate any continuous function is important but incomplete. A builder wants to know: how many bricks do I need for a wall of given precision?

This is where quantitative approximation theory enters. The density result says: for any continuous function f on a compact set and any tolerance ε > 0, there exists an EML network g with ||f - g|| < ε — the maximum error over the entire domain is less than ε. The proof is non-constructive (it comes from the abstract density of the subalgebra), but it provides a rigorous guarantee.

For functions with bounded rate of change — the *Lipschitz* functions that satisfy |f(x) - f(y)| ≤ L·|x - y| — the story becomes more concrete. The modulus of continuity controls the approximation quality: smoother functions need simpler networks.

## The Tropical Connection

Perhaps the most surprising discovery is what happens when you push EML networks to extremes. Consider the expression:

(1/t) · log(exp(t·a) + exp(t·b))

As the parameter t grows toward infinity, this expression doesn't explode. Instead, it converges to max(a, b) — the simple operation of taking the larger of two numbers.

This is the *Maslov dequantization*, and it reveals that EML arithmetic is a smooth deformation of *tropical arithmetic*, where addition becomes maximum and multiplication becomes addition. Tropical mathematics, born from optimization theory and algebraic geometry, turns out to be the skeleton that EML networks approximate in the high-parameter limit.

This bridge between smooth neural network operations and combinatorial tropical geometry is not merely aesthetic. It suggests that the optimization landscapes of neural networks have hidden piecewise-linear structure — and that techniques from tropical geometry could illuminate why gradient descent works as well as it does.

## Depth Matters

One might think that wider networks (more generators at the same depth) can substitute for deeper ones (more layers of composition). The mathematical results say otherwise.

A depth-2 EML composition — exp(w₂ · exp(w₁ · x + b₁) + b₂) — cannot be reduced to a depth-1 generator exp(w · x + b) for any choice of parameters. The doubly-exponential growth of exp(exp(x)) is fundamentally different from the singly-exponential growth of exp(w·x + b). This is a *strict depth hierarchy*: each additional layer of composition genuinely expands what the network can represent.

This mirrors empirical observations in deep learning, where deeper networks consistently outperform wider-but-shallower ones. The mathematical proof provides a rigorous foundation: depth is not just practically useful — it is theoretically necessary.

## What This Means

These results establish EML networks as mathematically complete approximation tools with several attractive properties:

1. **Universality**: They can approximate any continuous function on any compact set.
2. **Efficiency through depth**: Deeper compositions access strictly richer function classes.
3. **Tropical structure**: In the large-parameter limit, they reveal hidden combinatorial geometry.
4. **Explicit guarantees**: The approximation quality is controlled by the modulus of continuity.

The implications extend beyond neural networks. The tropical limit connects to optimization (linear programming in disguise), algebraic geometry (tropical varieties as limits of classical ones), and even physics (where similar "dequantization" limits appear in the semiclassical approximation of quantum mechanics).

Mathematics often progresses by revealing that seemingly different objects are secretly the same. The EML story shows that the smooth exponential world of neural networks, the piecewise-linear world of tropical geometry, and the classical world of polynomial approximation are all facets of a single mathematical crystal — one that we are only beginning to understand.

---

*This article describes mathematical research on the approximation theory of exp-log networks, extending the Stone-Weierstrass theorem to quantitative settings and establishing connections to tropical geometry.*
