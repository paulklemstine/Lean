# When Neural Networks Speak in Tropical Tongues

## The hidden geometry of the simplest deep networks

Deep learning is often described in the language of biology — neurons, activations, layers that fire and pass signals along. But underneath the metaphor lies a piece of pure mathematics, and it turns out to be surprisingly clean. The most common building block of modern networks, the *rectified linear unit* or **ReLU**, is just the function

$$\mathrm{ReLU}(t) = \max(0, t).$$

It lets a positive signal through unchanged and clamps everything negative to zero. Stack thousands of these together, interleave them with weighted sums, and you get the engines behind image recognition, language models, and protein folding. The question this article is about is deceptively simple: *what kind of function does such a network actually compute?*

The answer is beautiful. Every ReLU network computes a function from a world of mathematics that, at first glance, has nothing to do with machine learning at all — the world of **tropical algebra**.

## A different arithmetic

Tropical mathematics begins with a mischievous idea: what if we redefined the basic operations of arithmetic? In the *min-plus* tropical semiring, we keep the real numbers but replace the two operations we learned in school:

- "Addition" $\oplus$ becomes **taking the minimum**: $a \oplus b = \min(a, b)$.
- "Multiplication" $\otimes$ becomes **ordinary addition**: $a \otimes b = a + b$.

This looks like a typo, but it is a consistent and powerful algebraic system. Just as ordinary multiplication distributes over ordinary addition, here ordinary addition distributes over $\min$: $a + \min(b, c) = \min(a + b, a + c)$. The whole apparatus of polynomials can be rebuilt on this foundation.

A **tropical polynomial** is what you get by taking a tropical "sum" (a minimum) of tropical "monomials" (which are just affine functions $x \mapsto \langle a, x\rangle + b$). Concretely, a tropical polynomial in $n$ variables is a function of the form

$$f(x) = \min_{i \in S}\big(\langle a_i, x\rangle + b_i\big),$$

a minimum over finitely many affine pieces. Geometrically, the graph of such a function is the lower envelope of a collection of flat planes — a downward-folding, **concave** piecewise-linear surface.

But concavity is a cage. A single minimum of planes can only ever bend one way. To escape, we allow ourselves one subtraction. A **tropical rational function** is a difference of two tropical polynomials,

$$f(x) = g(x) - h(x),$$

where $g$ and $h$ are each a minimum of affine pieces. This small concession unlocks an enormous class of shapes: every continuous piecewise-linear function — bending up, bending down, in any combination — can be written this way.

## The bridge

Here is the central result, stated plainly.

> **Theorem (ReLU networks are tropical rational functions).** Any function computed by a feed-forward network whose only nonlinearity is the ReLU is a tropical rational function in the min-plus semiring. That is, it can be written as a difference $g - h$ of two tropical polynomials.

Why is this true? The proof is a small tower of closure properties, each one intuitive on its own. Think of it as showing that the set of tropical rational functions is a fortress that the operations inside a neural network can never break out of.

**Start with the raw materials.** A constant function $x \mapsto c$ is a one-piece tropical polynomial. An affine function $x \mapsto \langle a, x\rangle + b$ — exactly what a single weighted sum in a network computes — is also a one-piece tropical polynomial. Both are therefore tropical rational.

**Closure under addition.** The pointwise sum of two tropical rational functions is again tropical rational. The key fact powering this is a *tropical distributive law*: adding two minimums, $\min_i u_i + \min_j v_j$, is the same as a single minimum over all pairs, $\min_{i,j}(u_i + v_j)$. So the sum of two tropical polynomials is a tropical polynomial, and differences combine in the obvious way.

**Closure under negation.** Negating $g - h$ just flips it to $h - g$. Trivial, but essential — it is what lets the class contain both convex and concave shapes.

**Closure under maximum.** This is the heart of the matter, because ReLU is built from a maximum. Suppose $f_1 = g_1 - h_1$ and $f_2 = g_2 - h_2$. Using the identity
$$\max(f_1, f_2) = \big(g_1 + h_2\big) + \big(g_2 + h_1\big) - \Big[\min\big(g_1 + h_2,\; g_2 + h_1\big) + h_1 + h_2\Big],$$
one writes the maximum of two tropical rational functions again as a difference of two tropical polynomials. The minimum in the denominator is exactly where the min-plus structure earns its keep.

**Closure under ReLU.** Now everything clicks. Since $\mathrm{ReLU}(t) = \max(0, t)$ and the constant $0$ is tropical rational, the rectifier applied to any tropical rational function stays tropical rational.

**Closure under the network's wiring.** Scaling by a weight, summing across a layer, and forming affine combinations all preserve the class. A neural network is nothing more than affine combinations alternating with ReLUs. By induction on the layers — each layer applying only operations the fortress is closed under — the entire network computes a tropical rational function. $\blacksquare$

This is not merely an analogy. It is an exact identity between two seemingly unrelated mathematical objects: the functions deep networks can express, and the rational functions of tropical geometry.

## Why the dictionary matters

Translating a problem into a new language is worthwhile only if the new language makes the problem easier. Tropical geometry does exactly that for neural networks, because it converts questions about *expressiveness* into questions about *counting*.

In tropical algebra, the complexity of a function is measured by the number of **monomials** — the number of affine pieces in its minimums. This count is a tropical analogue of the *degree* of an ordinary polynomial, and it turns out to be the right currency for measuring how much a network can do. Two themes emerge.

**Approximation costs monomials.** How well can a tropical rational function with $N$ monomials approximate a smooth target function on the interval $[0,1]$? There is an explicit, hand-built family of approximants with on the order of $N$ monomials that achieves uniform error $1/N$ for any Lipschitz target — one whose slope is bounded — and the sharper rate $1/N^2$ for targets whose *derivative* is also Lipschitz. The number of pieces plays the role of an effective resolution: more pieces, finer approximation, with the smoothness of the target dictating the exchange rate. The conjecture pushing this forward is a clean staircase: with $s$ bounded derivatives, $N$ monomials should buy error of order $N^{-s}$, and no family of $N$ monomials can do better.

**Convexity is the obstruction.** Why do we need the subtraction at all — why isn't a plain tropical polynomial enough? Because a minimum of planes is always concave, while a maximum of planes is always convex. The one thing a single tropical polynomial cannot reproduce is the amount by which a target function *bulges away from its own chords*. Consider the humble tent function, a triangular bump on $[0,1]$. It is unimodal — it rises then falls — and that single change of curvature cannot be captured by one minimum of lines. It genuinely needs the rational form, a difference. A striking conjecture sharpens this into an exact law: the best uniform error achievable by any finite maximum of affine functions equals *half the worst concavity defect* of the target — the largest gap by which the function climbs above a straight chord between two of its points. Convexity defect, on this view, is the precise price of the gap between polynomials and rational functions.

**Subtractions count curvature changes.** A final conjecture ties the two threads together. Each subtraction in a tropical rational representation injects exactly one sign change into the function's curvature profile. So a target needs a difference of polynomials with $k$ total linear pieces precisely when its graph alternates between convex and concave behavior at most $k-1$ times. One bump needs one subtraction; a more wiggly landscape needs proportionally more.

## The view from the summit

It is easy to think of deep learning as an inscrutable tangle of numbers tuned by brute force. The tropical dictionary tells a different story. Strip away the training, the data, the engineering, and what remains is a precise piece of geometry: a ReLU network is a tropical rational function, a difference of two folding, faceted concave surfaces. Its power to represent — and the cost of that power — is governed by counting affine pieces and by the single scalar that measures how far a target curves away from straightness.

That a sixty-year-old reimagining of arithmetic, conceived with no thought of machines that learn, should turn out to describe their innermost structure is a reminder of how mathematics works. The right language does not just restate a problem. It reveals the shape that was there all along.
