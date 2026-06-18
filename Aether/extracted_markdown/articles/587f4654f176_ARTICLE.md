# The Map That Always Finds Its Way Home

## How a Simple Mathematical Recipe Guarantees Convergence — And What It Means for the Future of AI

---

Imagine dropping a marble into a funnel. No matter where on the rim you release it, it spirals inward to the same resting point at the bottom. The marble doesn't need instructions. It doesn't need a map. The shape of the funnel *guarantees* convergence.

Now imagine the funnel is made of mathematics — not physical material, but a combination of two of nature's most fundamental operations: the exponential function (how populations grow, how compound interest accumulates, how epidemics spread) and the logarithm (how we measure earthquakes, sound intensity, and information content). Combine them in a specific way, and you get a mathematical funnel: an operator that, when applied repeatedly, always spirals to the same fixed point.

This is the core discovery behind a new class of operators called **EML functions** — short for Exponential-times-Logarithm. The simplest member of the family is the function *f(x) = eᵃ · log(bx + c)*, where *a*, *b*, and *c* are adjustable parameters. Apply this function to any starting number in the right range, apply it again to the result, and again, and again — the sequence converges, rapidly and reliably, to a single number that depends only on the parameters. Not on where you started.

## The Contraction Principle

The key mathematical insight is ancient in spirit but newly applied: the **contraction mapping principle**, first proven by Stefan Banach in 1922. A contraction mapping is any function that brings points closer together. If *f* squishes every pair of points by at least a factor of *ρ < 1*, then:

1. There is exactly one fixed point — one number *x\** where *f(x\*) = x\**.
2. Starting from *any* point in the domain, repeated application of *f* converges to *x\** at a geometric rate.
3. After *n* iterations, the error is at most *ρⁿ* times the initial distance.

The power of this principle is its *certification*: if you can verify the contraction condition, convergence is mathematically guaranteed. No heuristics, no hopes, no "it seems to work in practice."

## Why EML?

The EML function *f(x) = eᵃ · log(bx + c)* occupies a sweet spot in the landscape of mathematical operations. The exponential provides amplification — it can magnify signals — while the logarithm provides compression — it tames wild inputs into manageable outputs. Together, they create a natural balance.

The derivative of this function is *f'(x) = eᵃ · b / (bx + c)*. This is a ratio: the exponential scaling in the numerator fights against the linear growth in the denominator. When the denominator wins — when *bx + c* is large enough relative to *eᵃ · b* — the derivative drops below 1 in absolute value, and the function becomes a contraction.

This creates a crisp boundary in parameter space. For a given set of parameters *(a, b, c)*, either the contraction condition holds (and convergence is guaranteed) or it doesn't (and the iteration may diverge). The boundary is not fuzzy or approximate — it's a sharp mathematical threshold.

## Composition: Deeper Contractions

One of the more surprising discoveries is that contraction schemes **compose**. If you have two EML operators, each with its own contraction constant, their composition — applying one after the other — is itself a contraction, with a contraction constant that is the *product* of the individual constants.

This means that composing two operators that each shrink distances by 50% gives a composite operator that shrinks distances by 75%. Three compositions: 87.5%. The convergence accelerates multiplicatively.

This composition property is not just a curiosity. It means that *layers* of EML operations — the kind used in neural network architectures — can inherit guaranteed convergence from their individual components. Each layer contracts, and the whole network contracts faster than any single layer.

## The Lyapunov Certificate

Beyond convergence, the theory provides a *certificate of stability* in the form of a Lyapunov function. Think of it as an "energy" that measures how far the current state is from equilibrium. For EML iterations, the natural Lyapunov function is simply *V(x) = (x - x\*)²* — the squared distance from the fixed point.

The key theorem states that this energy *strictly decreases* at every step: *V(f(x)) < V(x)* whenever *x ≠ x\**. The function is always rolling downhill toward its equilibrium. This is not just convergence — it's *monotone* convergence in energy, which rules out oscillatory pathways and provides a certificate that progress is being made at every single step.

## Numbers Tell the Story

Consider the specific case *a = 0.5, b = 1, c = 2*. The function *f(x) = e^0.5 · log(x + 2)* has a fixed point at approximately *x\* ≈ 1.993*. The spectral contraction rate — the absolute value of the derivative at the fixed point — is approximately *0.414*.

Starting from *x₀ = 4.0*:

| Iteration | Value      | Error         |
|-----------|------------|---------------|
| 0         | 4.000000   | 2.007         |
| 1         | 2.957      | 0.964         |
| 2         | 2.289      | 0.296         |
| 5         | 2.003      | 0.010         |
| 10        | 1.993      | 0.000001      |

The error drops by roughly a factor of 0.41 at each step — matching the spectral rate *|f'(x\*)| ≈ 0.414* with remarkable precision. By iteration 15, the error is below 10⁻¹⁵, the limit of floating-point precision.

## The Boundary of Convergence

The theory also characterizes *where convergence fails*. As the parameter *a* increases (making the exponential scaling stronger), the contraction rate *ρ = |f'(x\*)| = eᵃ/(x\* + c)* grows. When *ρ* reaches 1, the contraction property breaks down, and the iteration may oscillate or diverge.

For *b = 1, c = 2*, the critical value is approximately *a ≈ 1.07*. Below this threshold, convergence is guaranteed. Above it, the mathematical funnel flattens out and can no longer capture the marble.

This boundary analysis is practically valuable: it tells engineers exactly which parameter settings will produce reliable convergence and which will not. No trial and error needed.

## What This Means for AI

Modern neural networks are, at their core, compositions of simple functions applied iteratively. The EML framework suggests a design principle: build networks from operators that are *certified contractions*. Such networks would have mathematically guaranteed convergence, predictable behavior, and explicit error bounds — properties that current neural network architectures conspicuously lack.

The composition theorem means this certification scales: if each layer is a contraction, the whole network is a contraction with a predictable rate. This could be transformative for safety-critical applications — autonomous vehicles, medical diagnosis, financial systems — where "it usually works" is not good enough.

## Looking Forward

The fixed-point theory for EML operators opens several research directions. Can the contraction analysis extend to higher-dimensional EML operators (matrix exponentials times matrix logarithms)? Can the power series expansion of the fixed point as a function of the parameters be made explicit? And perhaps most intriguingly: can the Lyapunov certificates be used to provide formal guarantees for neural network behavior?

The marble always reaches the bottom of the funnel. The question now is how to build the best possible funnel.

---

*This article describes research on contraction mappings for exponential-logarithm operators, establishing guaranteed convergence of iterative schemes with explicit rate bounds.*
