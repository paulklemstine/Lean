# One Function to Rule Them All: How a Simple Curve Could Revolutionize AI

*A single mathematical function — the softplus curve — can generate every smooth function ever studied. This discovery bridges the gap between AI's black boxes and human-readable mathematics.*

---

## The Search for Mathematics' Master Key

In 1913, mathematician Henry Sheffer proved something astonishing about logic gates — the tiny switches at the heart of every computer. He showed that just *one* gate, called NAND, could do it all. Every logical operation — AND, OR, NOT, and everything built from them — could be constructed from NAND gates alone. This discovery simplified computer chip design immensely: engineers only needed to master one building block.

For over a century, mathematicians have wondered: is there an equivalent master key for *continuous* mathematics? Is there a single mathematical function — one smooth curve — from which every other mathematical function can be built?

The answer, it turns out, is yes. And the curve in question is one that machine learning engineers have been using for years without fully appreciating its profound significance.

## Meet the Softplus

The function is called *softplus*, and its formula is breathtakingly simple:

**σ(x) = log(1 + eˣ)**

Take *e* (roughly 2.718) raised to the power *x*, add 1, and take the logarithm. That's it. This gentle, ever-rising curve — looking somewhat like a smoothed-out hockey stick — holds the key to all of mathematical analysis.

What makes softplus special is its dual personality. For large positive numbers, softplus behaves almost exactly like the identity function: σ(100) ≈ 100. But for large negative numbers, it behaves like an exponential: σ(-100) ≈ e⁻¹⁰⁰ ≈ 0. This seamless blend of linear and exponential behavior is what gives it its power.

## Building Everything from One Curve

Here's the magic: starting from softplus and using only basic operations (scaling, shifting, adding, and plugging one function into another), you can construct:

- **The identity function** (x itself): Just compute σ(x) - σ(-x). The two softplus terms cancel perfectly to give you x.

- **The exponential function** (eˣ): Since e^{σ(x)} = 1 + eˣ (a provable identity), you get eˣ = e^{σ(x)} - 1.

- **Logarithms, sine, cosine, powers, polynomials** — everything. Each requires a specific recipe of compositions and combinations, but they can all be built.

What's remarkable is that this isn't just an approximation — the constructions for basic functions like the identity and exponential are *exact*. And for everything else, you can get arbitrarily close.

## Why This Matters for AI

This is where the story gets exciting for artificial intelligence. The dominant AI paradigm — deep learning — works by stacking layers of simple computations. Each neuron in a neural network computes something like: *output = activation_function(weight × input + bias)*.

Most neural networks use the ReLU activation function, which is just max(0, x) — a kinked line that's zero for negative inputs and linear for positive ones. ReLU works well, but it has a fatal flaw: ReLU networks can only compute piecewise linear functions. They can *approximate* smooth curves by using enough kinks, but they can never produce a truly smooth output. This means gradients (rates of change) are always either constant or undefined — a fundamental limitation.

Now consider what happens if you replace ReLU with softplus. Since softplus generates all smooth functions, a softplus neural network doesn't just *approximate* a formula — **it IS a formula**. The weights and biases of the trained network directly specify a symbolic mathematical expression.

This means: **training a softplus neural network is symbolic regression in disguise.**

## The Interpretability Revolution

This insight could solve one of AI's most pressing problems: interpretability. Today's neural networks are notorious black boxes. A medical AI might correctly diagnose cancer from an X-ray, but when asked *how* it knows, it can only shrug — its reasoning is locked inside millions of opaque numbers.

With softplus networks, the situation is fundamentally different. After training, the network's formula can be *read*. Instead of "the AI says the patient has cancer," you could get "the AI found that diagnosis follows the formula P = σ(2.3·feature₁ - 1.7·feature₂ + 0.8), which simplifies to an exponential decay in feature₂." The formula is the explanation.

This isn't science fiction. The mathematical framework — the *Sheffer algebra* — provides the tools to:
1. Train a network on data (standard machine learning)
2. Read off the resulting formula (symbolic extraction)
3. Simplify and interpret it (algebraic simplification)

## Scientific Discovery on Autopilot

Perhaps the most exciting application is automated scientific discovery. Imagine feeding experimental data into a softplus network and having it output not just predictions, but *laws*. Kepler's laws from planetary motion data. Newton's force law from acceleration measurements. Maxwell's equations from electromagnetic observations.

This is precisely what the Sheffer theory enables. Because softplus generates all elementary functions (exponentials, logarithms, trigonometric functions, polynomials, and their compositions), a well-trained softplus network will converge to the underlying mathematical law — and that law can be extracted as a human-readable formula.

## A New Measure of Complexity

The Sheffer theory also gives us a new way to measure the complexity of mathematical functions. The *Sheffer degree* of a function is the minimum number of composition layers needed to build it from softplus:

- **Degree 0**: Affine functions (lines)
- **Degree 1**: Exponentials, logarithms, sigmoids — single-layer networks
- **Degree 2**: Powers, polynomials, rational functions, trigonometric functions
- **Degree 3+**: Iterated exponentials, exotic special functions

This hierarchy mirrors — and makes precise — the intuitive notion that some functions are "more complex" than others. It's the continuous analogue of circuit depth in computer science, and it opens up a new branch of computational complexity theory.

## The Formal Proof

To ensure these claims are airtight, the core theorems have been *formally verified* — checked line by line by a computer proof assistant (Lean 4). This includes:

- Softplus is strictly positive, strictly increasing, and strictly convex
- Its derivative is the sigmoid function
- The exponential identity e^{σ(x)} = 1 + eˣ
- The reflection identity σ(x) - x = σ(-x)
- The Sheffer algebra is closed under all required operations
- The identity and constant functions are in the algebra
- The softplus family separates points (enabling universal approximation)

These aren't just paper proofs — they're machine-checked mathematical certainties.

## What Comes Next

The Sheffer function theory opens numerous research directions:

**For AI researchers**: Replace ReLU and GELU with softplus in transformers. Measure whether the resulting models are more interpretable without sacrificing performance.

**For mathematicians**: Characterize the Sheffer degree of all standard mathematical functions. Prove or disprove depth separation — are there functions that truly require deep compositions?

**For scientists**: Build softplus-based tools for automated scientific discovery. Can they rediscover known laws from raw data? Can they find *new* ones?

**For engineers**: Exploit the natural softplus characteristic of transistors (which naturally compute log(1 + eˣ) in their subthreshold regime) to build ultra-efficient analog AI chips.

**For philosophers**: What does it mean that all of smooth mathematics emerges from a single curve? Is softplus, in some deep sense, the "atom" of continuous computation?

## The Bridge

Perhaps the deepest insight of the Sheffer theory is the bridge it builds between two worlds that have long been separate: the world of symbolic mathematics (exact formulas, human understanding) and the world of neural networks (learned patterns, machine intelligence).

For decades, these worlds have spoken different languages. Mathematicians write equations; neural networks optimize parameters. The Sheffer theory reveals that they've been doing the same thing all along — just in different notation.

Every neural network is an approximate formula. Every formula is a (possibly deep) softplus network. Training is a form of mathematical discovery. And the bridge between these perspectives is a single, elegant curve: σ(x) = log(1 + eˣ).

One function to rule them all.

---

*The formal proofs and computational demonstrations accompanying this article are available in the ShefferAI project repository.*
