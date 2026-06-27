# One Neuron Is Enough: The Hidden Simplicity Behind Universal Approximation

## A puzzle about machines that learn anything

Modern artificial intelligence rests on a quietly astonishing promise. Give a neural
network enough capacity, the theory says, and it can imitate *any* continuous
relationship between inputs and outputs — the price of a house from its features, the
next word in a sentence, the trajectory of a falling leaf. This promise has a name:
**universal approximation**. It is the reason engineers trust that, with enough data and
patience, a network *could* in principle learn the pattern hiding in their problem.

But universality, as usually told, is a story about *size*. Pile up enough neurons,
the classical theorems whisper, and you can get arbitrarily close to your target. The
mental image is one of brute force: a vast hidden layer, thousands of units firing in
concert, collectively sculpting a function out of raw numerical clay.

This article is about a much sharper, almost mischievous truth. It turns out that the
engine of universality is not *quantity* at all. The real magic comes from a single,
humble property that almost every activation function in machine learning happens to
possess — and once you see it, the whole forest of "universal approximation theorems"
collapses into one tidy idea you can hold in your hand.

The property is **injectivity**: never sending two different inputs to the same output.
And the punchline is this:

> A *single* neuron with a strictly increasing activation — sigmoid, tanh, softplus,
> arctan, take your pick — followed by an ordinary polynomial, can approximate any
> continuous function on a bounded domain as closely as you like.

No wide hidden layer. No army of units. One neuron, one polynomial. Let us see why.

## The cast of characters: the activation zoo

Every artificial neuron does two things. First it forms a weighted combination of its
inputs — a simple linear gadget. Then it passes that number through a nonlinear
*activation function*, the spark of nonlinearity that lets networks bend and curve.

Over the decades, practitioners have accumulated a small menagerie of favorite
activations. Four of them are the heroes of our story:

- The **logistic sigmoid**, $\sigma(x) = \dfrac{1}{1 + e^{-x}}$, the classic S-curve
  that squashes any real number into the interval $(0,1)$. It was the workhorse of early
  neural networks and still rules the world of probabilities.
- The **softplus**, $s(x) = \log(1 + e^{x})$, a smooth, gentle ramp that rises like a
  hill from nearly flat on the left to nearly straight on the right.
- The **hyperbolic tangent**, $\tanh(x) = \dfrac{e^{x} - e^{-x}}{e^{x} + e^{-x}}$, the
  sigmoid's symmetric cousin, squashing inputs into $(-1, 1)$.
- The **arctangent**, $\arctan(x)$, the inverse of the tangent function, another smooth
  S-curve flattening out toward $\pm \pi/2$.

They look different. They come from different corners of mathematics — probability,
analysis, trigonometry. Practitioners argue about which one trains fastest or
generalizes best. But beneath the surface they share one secret feature that, as we will
see, is the *only* thing that matters for universality.

## The one property that rules them all

Look again at those four curves. Trace each from left to right. Every one of them is
*always climbing*. They never dip, never plateau into a flat stretch, never double back.
In mathematics we call such a function **strictly monotone** (here, strictly
increasing): whenever $x < y$, we are guaranteed $\sigma(x) < \sigma(y)$.

This is more than an aesthetic observation. A strictly increasing function can never
return the same value twice. If $\sigma(a) = \sigma(b)$ then $a$ and $b$ cannot be
different — for if, say, $a < b$, we would need $\sigma(a) < \sigma(b)$, a
contradiction. So strict monotonicity forces **injectivity**: distinct inputs always go
to distinct outputs. The function loses no information; it merely re-encodes the line.

Each of our four activations earns its injectivity through a one-line argument:

- **Sigmoid**: as $x$ grows, $-x$ shrinks, so $e^{-x}$ shrinks, so the denominator
  $1 + e^{-x}$ shrinks, so the fraction $\frac{1}{1+e^{-x}}$ grows. Strictly increasing.
- **Softplus**: as $x$ grows, $e^x$ grows, so $1 + e^x$ grows, and the logarithm — itself
  strictly increasing — carries that growth forward. Strictly increasing.
- **Tanh**: its slope is $1/\cosh^2(x)$, and since $\cosh$ is never zero, this slope is
  *always strictly positive*. A function with everywhere-positive slope only ever climbs.
- **Arctan**: it is the inverse of a strictly increasing function on its principal
  branch, and inverses of increasing functions increase. Strictly increasing.

Four different reasons, one shared conclusion. Hold that thought, because injectivity is
about to do all the heavy lifting.

## Separating the world, point by point

Why should injectivity have anything to do with approximating arbitrary functions? The
bridge is a celebrated nineteenth- and twentieth-century result called the
**Stone–Weierstrass theorem**, one of the crown jewels of analysis.

Here is its spirit. Suppose you have a collection of "building-block" functions on some
domain. You are allowed to add them, multiply them, and scale them by constants — the
operations of ordinary algebra. The resulting family of all such combinations is called
the **subalgebra generated** by your blocks. Stone and Weierstrass proved a remarkable
sufficient condition for this generated family to be *dense* — that is, able to
approximate every continuous function on a closed, bounded domain to any precision:

> If your building blocks can **separate points** — meaning that for any two distinct
> locations in the domain, at least one block assigns them different values — then the
> functions you can build from them are dense. You can hit any continuous target.

It is a profound trade. All you must verify is the modest, almost trivial-sounding
ability to *tell points apart*. In return you receive the sweeping power to reproduce
every continuous function on the domain.

And here is where our humble property pays off spectacularly. A single injective function
*already* separates points all by itself. If $g$ is injective and $x \ne y$, then by
definition $g(x) \ne g(y)$ — the two points are separated, with $g$ as the witness. One
injective function does the entire job that Stone–Weierstrass asks of an entire family.

Chaining these observations together gives the centerpiece of this work, which we may
state precisely. Let $X$ be any compact (closed and bounded, in the familiar setting)
domain, and let $C(X,\mathbb{R})$ denote the continuous real-valued functions on it.

> **Single-feature universality.** If $g : X \to \mathbb{R}$ is a continuous *injective*
> function, then the subalgebra it generates — all polynomials in $g$, that is all finite
> combinations $c_0 + c_1 g + c_2 g^2 + \cdots + c_d g^d$ — is uniformly dense in
> $C(X,\mathbb{R})$.

In the formal development this is the theorem `adjoin_singleton_dense`, and its companion
`adjoin_singleton_approx` packages the same fact in the working engineer's language:
for any target function $f$ and any tolerance $\varepsilon > 0$, there is a polynomial
$p$ in $g$ with $\|p - f\| < \varepsilon$, the error measured in the worst-case
(uniform) sense across the whole domain.

## From abstract features to real neurons

Now we assemble the pieces. A single neuron computes $g(x) = \sigma(w \cdot x + b)$: it
forms a linear combination of the inputs, then applies an activation $\sigma$. Two facts
make this neuron an injective feature in its own right.

First, **composition preserves injectivity**: if $\sigma$ is injective and the inner map
is injective, their composition is injective too. Distinct inputs survive the first map
distinct, and the second map keeps them distinct. (In the formalization this is the
small but pivotal lemma `injective_comp`.)

Second, our four activations are *all* injective, as we proved above. So a neuron built
from any of them, sitting atop an injective feature, is itself an injective feature.

Feeding that into single-feature universality yields the headline result, captured by the
theorem `activation_feature_dense` and its quantitative twin `activation_feature_approx`:

> **One activated neuron plus a polynomial is universal.** For any compact domain, any
> injective continuous activation $\sigma$, and any injective input feature $g$, the
> functions $c_0 + c_1\,(\sigma\circ g) + c_2\,(\sigma\circ g)^2 + \cdots$ are dense in
> the continuous functions on that domain.

Specialized to the most concrete possible setting — a single input ranging over an
interval $[a,b]$, with $g$ the identity coordinate — we obtain four clean corollaries,
one per activation, named `sigmoid_dense_Icc`, `softplus_dense_Icc`, `tanh_dense_Icc`,
and `arctan_dense_Icc`. Each says: *polynomials in this one activation are dense on the
interval.* And a single umbrella theorem, `activation_dense_Icc`, states it once and for
all for any strictly monotone continuous activation, swallowing all four special cases
into one.

There is a pleasing economy here. The mathematician's instinct is to prove one general
theorem and watch the special cases tumble out. That is exactly what happens: the
strict-monotonicity interface `strictMono_feature_dense` takes *monotone plus continuous*
as input and returns universality. Each activation then reduces to a one-line
monotonicity check — sigmoid, softplus, tanh, arctan each "plug in" and inherit
universality automatically.

## The exponential ancestor

Where did the single-feature principle come from? Its first incarnation concerned the
**exponential function** $e^x$, the most famous injective function of all. Because $e^x$
is strictly increasing, polynomials in $e^x$ — the so-called **exponential polynomials**,
finite combinations $\sum_k c_k\, e^{k x}$ — are dense in the continuous functions on any
interval. This is the theorem `exponentialPolynomials_dense_Icc`, and a refinement,
`exp_monomials_span_dense`, shows you do not even need genuine products of distinct
features: the plain linear span of the powers $e^{0}, e^{x}, e^{2x}, e^{3x}, \ldots$
already suffices.

This exponential result is the seed. The leap of the present work is the realization,
recorded as a "hypothesis confirmed" in the research notes, that *nothing about the
exponential's analytic personality was ever used* — only its injectivity. The exponential
was a red herring dressed as a hero. Strip away its special status and you find that
*any* injective continuous function works just as well, and the whole activation zoo
walks through the door.

## What is genuinely surprising — and what is not

It is worth being honest about where the surprise lives.

The surprising part is the **collapse of variety into a single principle**. The
literature treats "sigmoid networks are universal," "tanh networks are universal," and so
on as separate theorems, each with its own proof tailored to the activation's quirks.
Here they all descend from one fact — injectivity via strict monotonicity — applied
through one theorem. Diversity of activation is revealed to be irrelevant to *whether*
you can approximate; it is a cosmetic choice from the standpoint of pure expressive power.

The *unsurprising* — but important — flip side is that this tells you nothing about
**how efficiently** you approximate. Density is a yes/no question: *can* you get
arbitrarily close? It says nothing about the *degree* of polynomial or the number of
terms you need to hit a given accuracy. That quantitative question — the **approximation
rate**, how the cost scales with the desired precision and the smoothness of the target —
is where activations genuinely differ, and where the harder, more practical mathematics
begins. The research notes flag this explicitly: the universal-approximation *content*
lives entirely in injectivity; everything else is about *rates*.

There is even a sharp boundary lurking here. Consider a *non*-injective activation, such
as a Gaussian bump $\rho(x) = e^{-x^2}$, which is symmetric and so sends $x$ and $-x$ to
the same value. A single Gaussian feature can fail to separate points — it literally
cannot tell a value from its negative — and so a lone Gaussian neuron is *not* universal
in this single-feature sense. To recover universality with such activations you genuinely
need a *family* of them, several units working together. Injectivity is not merely
sufficient for the single-neuron miracle; it is essentially the dividing line.

## Why this matters

At first glance this might look like a piece of mathematical housekeeping — tidying a
folklore drawer. But the reframing carries real weight.

For the **theorist**, it isolates the true mechanism of universality. When you understand
that injectivity (point separation) is the load-bearing wall, you know exactly which
modifications to an architecture preserve universality and which threaten it. Swap one
strictly monotone activation for another: safe. Introduce a symmetry that collapses
distinct inputs: dangerous. The principle becomes a design compass.

For the **educator**, it offers a strikingly clean narrative. Instead of four proofs for
four activations, there is one idea — *injective features separate points, and separation
plus algebra gives density* — that a student can grasp in an afternoon and then watch
unfold across the entire activation zoo.

And for the **engineer**, it is a reminder of where to spend effort. If universality is
"free" the moment your activation is monotone, then the interesting engineering questions
are never *whether* a network can fit the data, but *how cheaply* — how few units, how low
a degree, how little data. The existence theorems are settled; the economics are not.

## The shape of the idea

Step back and the whole argument fits on a single breath:

1. The standard activations are strictly increasing.
2. Strictly increasing means injective: no two inputs collide.
3. An injective function separates points: it tells every pair of locations apart.
4. Stone–Weierstrass: point-separating building blocks generate everything continuous.
5. Therefore one injective activation, plus polynomial read-out, is universal.

Five steps, and the menagerie of universal approximation theorems becomes a single, well-lit
room. The sigmoid, the tanh, the softplus, the arctan — different masks worn by the same
underlying actor. What makes a neuron universal was never its particular curve. It was the
simplest promise a function can make: *I will never confuse two different things.*

That, in the end, is the quiet lesson. The power to approximate everything grows not from
complexity but from a refusal to lose information — one injective step at a time.
