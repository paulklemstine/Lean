# The Hidden Stability of Exp-Log Circuits

## How a simple mathematical function guarantees convergence where neural networks cannot

Imagine you're trying to solve an equation by guessing and checking. You start with a rough guess, plug it into a formula, get a new value, plug *that* back in, and repeat. Sometimes this process spirals inward toward a single answer — a fixed point — like water finding the drain. Other times it oscillates wildly or flies off to infinity.

For most functions, there's no easy way to know in advance which will happen. But a special class of operations — built from nothing more than exponentials and logarithms — turns out to have a remarkable built-in guarantee: they always converge, and they do so at a predictable, geometric rate that can be computed directly from the parameters.

## The EML Operator

The function at the heart of this story is deceptively simple:

> *f(x) = eᵃ · log(bx + c)*

Here *a*, *b*, and *c* are parameters. The function takes a number *x*, applies a linear transformation (*bx + c*), takes the logarithm, and scales by an exponential factor. We call this an **EML operator** — for Exponential-Multiplicative-Logarithmic — and it arises naturally in signal processing, iterative optimization, and the design of neural network architectures.

What makes EML operators special is their derivative:

> *f'(x) = eᵃ · b / (bx + c)*

This derivative is a decreasing function of *x*. As *x* grows, the derivative shrinks. This is the mathematical fingerprint of **concavity** — the logarithm bends downward — and it has profound consequences.

## The Contraction Principle

The key insight is that if the derivative stays below 1 in absolute value throughout an interval, the function is a *contraction mapping*: it brings any two points closer together. Formally, if |*f'(x)*| < 1 for all *x* in some interval, then:

> |*f(y) - f(x)*| ≤ ρ · |*y - x*|

where ρ < 1 is the contraction rate. This is like a rubber band that shrinks with every pull — each iteration reduces the distance between any iterate and the fixed point by at least a factor of ρ.

For the EML operator, the contraction rate on an interval [L, U] is exactly:

> *ρ = eᵃ · b / (bL + c)*

This rate is less than 1 precisely when *eᵃ · b < bL + c* — a condition that can be checked instantly from the parameters. No simulation needed. No trial and error. The mathematics certifies convergence before the first iteration begins.

## Why This Matters

In the world of deep learning, stability is an evergreen concern. When you stack layers of a neural network, small perturbations can amplify catastrophically — a phenomenon related to exploding gradients and training instability. The EML framework offers something rare: a structural guarantee.

When you compose two EML operators, the overall contraction rate is simply the product of the individual rates. If layer 1 contracts by a factor ρ₁ = 0.45 and layer 2 by ρ₂ = 0.31, the two-layer composition contracts by ρ₁ · ρ₂ = 0.14. Stack ten such layers and you get a contraction rate of approximately 0.45¹⁰ ≈ 0.00034 — extraordinarily rapid convergence.

This multiplicative property doesn't hold for arbitrary neural network layers. With general activation functions like ReLU or sigmoid, composing layers can amplify, attenuate, or oscillate unpredictably. The exp-log structure imposes a discipline that propagates through depth.

## A Comparison Principle

Perhaps the most surprising result is a *comparison principle* for fixed points. Consider two EML operators with the same *b* and *c* but different exponential parameters *a₁ ≤ a₂*. Each has its own unique fixed point *x₁** and *x₂** in the contraction interval. The theorem guarantees:

> If *a₁ ≤ a₂*, then *x₁* ≤ x₂**.

The larger the exponential scaling, the larger the fixed point. This is the EML analog of comparison theorems in differential equations — a monotonicity principle that connects parameter changes to predictable shifts in equilibrium behavior.

The proof uses a clever contradiction argument. If the larger-parameter fixed point were smaller, the contraction property and monotonicity of the exponential would force the iteration to overshoot, violating the contraction bound. The geometry of exp and log conspire to prevent this.

## The Fixed-Point Landscape

What does the fixed point look like numerically? For the basic case *a = 0.5, b = 1, c = 1*:

- The fixed point is *x* ≈ 1.531076*
- The contraction rate on [1, ∞) is *ρ ≈ 0.824*
- The local rate at the fixed point is *|f'(x*)| ≈ 0.651*

Starting from *x₀ = 3.0*, the iteration converges within about 80 iterations to 15-digit accuracy. The error decreases geometrically, with the actual convergence faster than the a priori bound because the local rate at the fixed point is smaller than the global contraction constant.

As the parameter *a* increases from 0 to 1, the fixed point migrates smoothly from near 0 to around 5 (with *b = 1, c = 2*). The contraction rate remains bounded below 1 throughout, hovering around 0.35-0.37 — a remarkably stable range.

## Deeper Structure

The mathematical framework reveals several layers of structure:

**Derivative monotonicity.** The fact that *f'(x)* decreases with *x* means the worst-case contraction always occurs at the left endpoint of the interval. This makes the analysis tight: the Lipschitz constant we compute is not a loose upper bound but the actual supremum of the derivative.

**Self-mapping intervals.** For the Banach fixed-point theorem to produce a fixed point (not just prove uniqueness), we need the function to map an interval to itself. The EML operator maps [L, U] to itself when *L ≤ eᵃ · log(bL + c)* and *eᵃ · log(bU + c) ≤ U*. These conditions carve out a well-defined "stability region" in parameter space.

**Geometric convergence.** The iteration error satisfies |*xₙ - x** | ≤ ρⁿ · |*x₀ - x** |. Since ρ < 1, the powers ρⁿ tend to zero, and the error converges to zero. Moreover, the rate of convergence is known: the number of correct digits increases linearly with the number of iterations.

## Looking Forward

The EML fixed-point theorem opens several avenues. Can the contraction analysis extend to multivariate EML operators, where the parameters are matrices? Can the comparison principle be used to design adaptive algorithms that tune their parameters while maintaining convergence guarantees? And perhaps most intriguingly, can the multiplicative composition property of contraction rates be exploited in designing provably stable deep architectures?

These questions sit at the intersection of dynamical systems, approximation theory, and machine learning — a triangle of mathematical fields that the simple function *eᵃ · log(bx + c)* unexpectedly connects.

Mathematics has a long history of finding depth in simplicity. The quadratic formula, Euler's identity, and the central limit theorem all derive profound consequences from elementary ingredients. The EML fixed-point theorem belongs to this tradition: exponentials and logarithms, composed in the simplest possible way, yield a complete convergence theory with explicit rates, unique attractors, and structural stability across parameter variations.

The drain at the bottom of the mathematical bathtub turns out to have a precisely calculable pull — and that calculation takes nothing more than exp, log, and a comparison with 1.
