# The Architecture of Approximation: How Expression Trees Reveal the Hidden Structure of Functions

## A new mathematical framework shows that the complexity of representing functions mirrors the complexity of the functions themselves — with surprising implications for computation and artificial intelligence.

---

Every continuous function — the trajectory of a baseball, the curve of a bell, the decay of a radioactive atom — can be written as a formula. But how *complicated* must that formula be? This deceptively simple question opens a window onto one of the deepest connections in mathematics: the link between how hard a function is to *describe* and how hard it is to *compute*.

A new body of results now makes this connection precise, using a formal symbolic system called **EML** — for Exponential, Multiplicative, Logarithmic. Think of EML as a stripped-down programming language with exactly three capabilities: it can multiply numbers, raise *e* to a power, and take logarithms. From these three operations alone, it can build every continuous function to arbitrary precision. But the real surprise is not that it *can* — it's how the *cost* of doing so reveals the hidden architecture of the function itself.

## The Depth Hierarchy: Why Some Functions Are Inherently Deeper

Consider the exponential function, exp(*x*) = *e*^*x*. In EML, this is a single operation — one node in the expression tree. Now consider *exp(exp(x))*: the exponential of the exponential. That requires two exponential operations nested inside each other. And *exp(exp(exp(x)))* requires three.

The new results prove something remarkably clean: the *n*-fold iterated exponential requires exactly *n* layers of exponential nesting, and *no fewer*. Moreover, the total size of the expression — counting every node in the tree — is exactly 2*n* + 1. This is optimal: you cannot do better.

What makes this non-trivial is the contrast with polynomials. A polynomial of degree 1,000,000 — a million terms, each a power of *x* — has EML depth *zero*. It requires no exponentials at all. Yet a single application of the exponential function has depth one. The entire infinite-dimensional space of polynomials sits *below* the simplest transcendental function in the EML hierarchy.

This creates a strict *depth hierarchy*: at each level, there exist functions that can be expressed with that many layers of exponentiation but not with fewer. It's like discovering that musical instruments have a natural ordering — not by the sounds they produce, but by the physical principles they exploit. A violin (vibrating string) and a clarinet (vibrating air column) both make sound, but they sit at different levels of acoustic complexity.

## The Information Bottleneck: Why Depth Has a Price

But depth is not free. The new framework introduces a quantity called *retained symbolic information* — a measure of how much of a function's essential character survives as you pass it through layers of exponential operations.

The mathematics is elegant: if each layer retains a fraction α of the information (where 0 < α < 1), then after *l* layers, the retained information is α^*l* times the original. This is exponential decay — the same mathematical pattern that governs radioactive half-lives, the cooling of hot objects, and the fading of sound in a concert hall.

But here's the twist. The *product* of retained information times depth — a quantity the researchers call the *information-depth product* — has a maximum. Push too deep, and the exponential decay overwhelms the benefit of additional layers. Don't go deep enough, and you miss the efficiency gains of compositionality. There is a sweet spot, and it occurs at a depth proportional to 1/|ln(α)| — the reciprocal of the natural logarithm of the contraction factor.

This has a direct analog in neural network architecture design. The question "how deep should my network be?" has bedeviled machine learning practitioners for decades. The information-depth product provides a principled mathematical answer: there is an *optimal depth* for any given information retention rate, and going beyond it wastes capacity.

## Composition: The Arithmetic of Complexity

One of the most powerful results concerns how complexity combines under composition. If you have an EML expression that approximates function *f*, and another that approximates function *g*, how complex is the expression that approximates *f* ∘ *g* (f composed with g)?

The answer has two parts:
- **Depth adds.** If *f* needs depth *d₁* and *g* needs depth *d₂*, then *f* ∘ *g* needs at most depth *d₁* + *d₂*.
- **Size multiplies.** If *f* has size *s₁* and *g* has size *s₂*, then *f* ∘ *g* has size at most *s₁* × *s₂*.

The depth bound is sharp — you can achieve it with equality — while the size bound is worst-case. This creates a fundamental asymmetry: *depth is cheap but size is expensive* when composing functions.

This has profound implications. It means that deep, narrow EML expressions — like the iterated exponential towers — can represent functions that would require enormously wide shallow expressions. The gap can be exponential: a function needing depth *n* might require size 2^*n* if restricted to depth *n* − 1. Depth is the great compressor.

## Universal Approximation: Everything Is Reachable

The framework proves that EML expressions are *universal approximators*: every continuous function on a closed interval can be approximated to any desired accuracy by some EML expression. This follows from a classical result — the Weierstrass approximation theorem, which says polynomials can do this — combined with the fact that EML subsumes polynomials (they have depth zero in the EML hierarchy).

But the new contribution goes further. It introduces *EML description complexity* — the minimum size of an EML expression needed to achieve accuracy ε. This is a *computable surrogate for Kolmogorov complexity*, the legendary measure of a string's inherent information content that is itself uncomputable.

The new results prove that this description complexity is:
- **Anti-monotone in tolerance**: tighter accuracy needs bigger expressions.
- **Subadditive under addition**: the complexity of *f* + *g* is at most the sum of the complexities of *f* and *g* (plus one node for the addition).
- **Bounded above by description complexity**: the minimum depth needed is never more than the minimum size.

These are exactly the properties that define a well-behaved complexity measure — an *abstract Kolmogorov complexity* that captures the essential difficulty of approximating a function, measured not in bits but in exponential operations.

## The Bridge to Machine Learning

The EML framework reveals something that practitioners have known intuitively but have not been able to prove: the architecture of a computation matters as much as its raw size.

Modern neural networks are, at their core, compositions of simple functions — linear transformations interleaved with nonlinear activations like ReLU or sigmoid. The EML results show that this compositionality is not just a convenience; it is a mathematical necessity for efficiently representing certain classes of functions.

The depth hierarchy, in particular, suggests that there are functions for which no shallow network, however wide, can match the efficiency of a deep network. The gap is not merely quantitative but *qualitative*: some computational structures simply cannot be flattened without exponential blow-up.

## What Comes Next

The EML framework opens several doors. Can the description complexity be computed efficiently for specific function classes? Are there analogs of the depth hierarchy for other computational primitives — trigonometric functions, special functions, quantum gates? And what is the exact boundary between functions that admit efficient EML representations and those that don't?

These questions touch the deepest issues in mathematics and computer science: the relationship between structure and computation, the nature of mathematical complexity, and the fundamental limits of approximation. The EML hierarchy is not just a tool for studying functions — it is a new lens through which to see the architecture of mathematics itself.

---

*The EML universal approximation framework was developed and formally verified in Lean 4 with Mathlib, building on the Weierstrass approximation theorem and classical results in approximation theory. The complete formal proofs, including 30+ verified theorems with no gaps, are available in the accompanying repository.*
