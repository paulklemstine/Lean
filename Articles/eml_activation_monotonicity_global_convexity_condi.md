# The Hidden Bridge Between Smooth Neurons and Tropical Arithmetic

## A function that cannot make up its mind

Take a piece of paper and draw the graph of the function
$$\mathrm{softplus}(x) = \log\left(1 + e^{x}\right).$$

Far to the left it hugs the horizontal axis. Far to the right it becomes indistinguishable from the diagonal line $y = x$. In between — right around the origin — it bends, smoothly and gently, from one behaviour into the other. It looks, in short, like a *rounded corner*.

That rounded corner is one of the most economically consequential curves of the last decade. In its sharp-cornered form, $x \mapsto \max(x, 0)$, it is the rectified linear unit, the workhorse nonlinearity of modern deep learning. In its smoothed form it is the softplus, used whenever a training procedure needs derivatives that do not jump.

This article is about a precise statement of something that practitioners feel intuitively: **the smooth curve and the sharp corner are the two endpoints of a single continuous deformation, and that deformation is exactly the passage from ordinary arithmetic to *tropical* arithmetic.** Along the way we will pin down, to the last epsilon, exactly which members of a natural two-parameter family of these activations are increasing, and which are convex.

---

## Part I: A two-parameter family and its exact behaviour

Call a function an **exponential–logarithmic transcendental** — an EML transcendental for short — if it is built out of $\exp$ and $\log$. The natural two-parameter family of EML activations is
$$E_{a,b}(x) = a\,x + \log\!\left(1 + e^{b x}\right), \qquad a, b \in \mathbb{R}.$$

Here $b$ is a *sharpness* dial and $a$ is a *leak* or *residual* dial. At $a=0$, $b=1$ we recover the softplus. Positive $a$ adds a linear leak, so that the function keeps rising even where the softplus has gone flat — the smooth analogue of the "leaky ReLU". Negative $a$ tilts the whole graph downward.

Two questions have crisp, complete answers.

### Question 1: When is $E_{a,b}$ convex?

**Answer: always, provided $b \neq 0$ — regardless of $a$.**

The reason is a small computation that is worth doing in your head. Write $\sigma$ for the logistic function
$$\sigma(t) = \frac{e^{t}}{1 + e^{t}},$$
the familiar S-shaped curve running from $0$ at $-\infty$ to $1$ at $+\infty$. Differentiating $E_{a,b}$ once gives
$$E_{a,b}'(x) = a + b\,\sigma(bx),$$
and differentiating again, using the celebrated self-referential identity $\sigma' = \sigma(1-\sigma)$, gives
$$E_{a,b}''(x) = b^{2}\,\sigma(bx)\bigl(1 - \sigma(bx)\bigr).$$

Now $0 < \sigma(t) < 1$ for every real $t$ — the logistic curve never actually reaches its asymptotes — so the product $\sigma(1-\sigma)$ is *strictly* positive everywhere. Multiply by $b^2 > 0$ and you get:

> **Theorem (Global strict convexity).** For every $a \in \mathbb{R}$ and every $b \neq 0$, the function $E_{a,b}$ has strictly positive second derivative at every real point, and is therefore strictly convex on the whole real line.

Notice what the linear term $a x$ did: *nothing*. Adding a straight line to a convex function cannot destroy convexity, and here the algebra confirms it — $a$ has vanished from the second derivative entirely. The convexity of these activations is completely robust to the leak parameter.

### Question 2: When is $E_{a,b}$ increasing?

Here the answer is not "always", and finding the exact boundary is the point.

Fix $b > 0$. Since $0 < \sigma(bx) < 1$, the derivative $a + b\,\sigma(bx)$ lives strictly between $a$ and $a + b$. So if $a \geq 0$, the derivative is strictly positive everywhere and the function is strictly increasing. And if $a < 0$? Then as $x \to -\infty$ we have $\sigma(bx) \to 0$, so the derivative tends to $a$, which is negative: the function is *decreasing* far out on the left. The threshold is exactly at $a = 0$, and it is attained.

> **Theorem (Exact monotonicity domain).** Let $b > 0$. Then $E_{a,b}$ is strictly increasing on all of $\mathbb{R}$ **if and only if** $a \geq 0$.

This is a sharp parameter bound, not an estimate. The "only if" half deserves a moment of appreciation, because it is where the reasoning is subtlest. Suppose $E_{a,b}$ were merely *non-decreasing*. Then its derivative must be $\geq 0$ everywhere:
$$a + b\,\sigma(bx) \geq 0 \quad \text{for all } x.$$
Take the limit as $x \to -\infty$. The logistic term collapses to $0$, and since a limit of non-negative quantities is non-negative, we conclude $a \geq 0$. Contrapositive: $a < 0$ kills even plain monotonicity, let alone strict monotonicity. So the boundary case $a = 0$ — the softplus itself — sits exactly on the edge: increasing, but with derivative decaying to $0$.

There is a design lesson buried here for anyone building networks. A leaky activation is safe for gradient-based optimization (monotone, convex, everywhere-positive curvature) precisely when the leak coefficient is non-negative. A "negative leak", however small, produces a function that turns around somewhere on the far left, creating a spurious region of decreasing response.

---

## Part II: The same exponentials, a different disguise

Now watch the same two operations — exponentiate, add, take the log — appear in a completely different area of mathematics.

Define, for $b \neq 0$, the **log-sum-exp** operation
$$x \oplus_b y = \frac{1}{b}\log\!\left(e^{bx} + e^{by}\right).$$

This is a binary operation on the real numbers. It is the "soft maximum" that appears everywhere in statistics, in the partition functions of statistical mechanics (with $b$ the inverse temperature), and in the numerically-stable implementations of softmax layers.

Here is the key structural observation. The map $\varphi(x) = e^{bx}$ is a bijection from $\mathbb{R}$ onto the positive reals $\mathbb{R}_{>0}$, and by construction
$$\varphi(x \oplus_b y) = \varphi(x) + \varphi(y), \qquad \varphi(x + y) = \varphi(x)\cdot\varphi(y).$$
In other words, $\varphi$ carries the pair of operations $(\oplus_b, +)$ on $\mathbb{R}$ to the pair $(+, \times)$ on $\mathbb{R}_{>0}$. Every algebraic law of ordinary positive arithmetic is therefore inherited *exactly* — not approximately — by the deformed operations:

> **Theorem (Exact algebraic laws).** For every $b \neq 0$ and all real $x, y, z$:
> - $x \oplus_b y = y \oplus_b x$ (commutativity);
> - $(x \oplus_b y) \oplus_b z = x \oplus_b (y \oplus_b z)$ (associativity);
> - $(x + z) \oplus_b (y + z) = (x \oplus_b y) + z$ (distributivity of $+$ over $\oplus_b$).

The proof of associativity is a one-liner once you have the transport principle: apply $\varphi$ to both sides, and both become $e^{bx} + e^{by} + e^{bz}$; since $\varphi$ is injective, the two sides agree.

So $(\mathbb{R}, \oplus_b, +)$ is a perfectly good semiring-like structure — a copy of positive arithmetic wearing a logarithmic mask.

### The one law that fails, and by exactly how much

There is one property that ordinary addition on $\mathbb{R}_{>0}$ *does not* have: idempotency. And so $\oplus_b$ does not have it either. But the failure is measurable with total precision:

> **Theorem (Exact idempotency defect).** For every $b \neq 0$ and every $x$,
> $$x \oplus_b x = x + \frac{\log 2}{b}.$$

This is the single most informative formula in the story. It says the deviation from idempotency is a *constant shift* of size $\log 2 / b$, independent of $x$. And that constant tends to zero as $b \to \infty$.

Idempotency — $a \oplus a = a$ — is the defining eccentricity of **tropical** (or *idempotent*, or *max-plus*) algebra, in which one replaces addition by $\max$ and multiplication by $+$. In the max-plus semiring, $\max(x,x) = x$ trivially. The formula above is telling us that $\oplus_b$ is a *quantum* deformation of $\max$, with $1/b$ playing the role of Planck's constant, and that letting $b \to \infty$ is a *classical limit* — a process known as **Maslov dequantization**.

### The sandwich

Making the limit precise takes a two-sided estimate, and both sides are sharp.

> **Theorem (Sharp sandwich).** For every $b > 0$ and all real $x, y$,
> $$\max(x,y) \;<\; x \oplus_b y \;\leq\; \max(x,y) + \frac{\log 2}{b}.$$

The lower bound holds because $e^{bx} + e^{by}$ is strictly larger than $e^{b\max(x,y)}$ (the other term is positive). The upper bound holds because $e^{bx} + e^{by} \leq 2e^{b\max(x,y)}$, and $\log 2$ appears when you take logs. The upper bound is *attained* — at $x = y$ it is exactly the idempotency defect. The lower bound is strict but not attained: the soft maximum always overshoots the true maximum, by an amount that shrinks to zero as the two arguments separate.

Squeezing between the two ends of the sandwich gives the dequantization statement:

> **Corollary (Maslov dequantization).** For all real $x, y$,
> $$\lim_{b \to \infty} \; \frac{1}{b}\log\!\left(e^{bx} + e^{by}\right) \;=\; \max(x,y).$$

And the mirror image, obtained by conjugating with $x \mapsto -x$, converges to the min-plus operation:
$$\lim_{b\to\infty}\; -\bigl((-x) \oplus_b (-y)\bigr) \;=\; \min(x,y),$$
which is the addition of the standard tropical semiring in its min convention.

---

## Part III: Closing the loop — the bridge

Now the two halves collide. Set $y = 0$ in the log-sum-exp:
$$x \oplus_b 0 = \frac{1}{b}\log\!\left(e^{bx} + 1\right) = \frac{E_{0,b}(x)}{b}.$$

**The rescaled softplus *is* tropical addition of $x$ and the tropical unit $0$, deformed.** The activation function of a neuron and the addition of a tropical semiring are literally the same expression.

Putting everything together:

> **Bridge Theorem.** Fix $b > 0$ and let $S_b(x) = \frac{1}{b}\log(1 + e^{bx})$ be the rescaled EML activation. Then:
> 1. $S_b$ is strictly convex on all of $\mathbb{R}$ and strictly increasing;
> 2. $S_b(x) > \max(x, 0)$ for every $x$ — the smooth activation strictly dominates its tropical shadow;
> 3. $S_b(x) \leq \max(x,0) + \frac{\log 2}{b}$ for every $x$ — the approximation is *uniform* in $x$, with error at most $\log 2/b$;
> 4. $S_b(x) \to \max(x, 0)$ as $b \to \infty$, for every $x$.

The most striking feature of this statement is item 3: the error bound $\log 2 / b$ does not depend on $x$ at all. The rounded corner approximates the sharp corner *equally well everywhere*, and the entire discrepancy is concentrated in a single number, $\log 2 \approx 0.693$, divided by the sharpness.

There is also a beautiful discontinuity in *quality* at the limit. Every $S_b$ with $b$ finite is **strictly** convex: pick any two distinct points on its graph and the chord lies strictly above the curve in between. The limit $\max(x,0)$ is convex, but *nowhere* strictly convex — it is affine on the whole ray $x \leq 0$ and affine on the whole ray $x \geq 0$. Likewise every $S_b$ is strictly increasing, but the limit is only non-decreasing, being flat to the left of the origin. Strictness is destroyed exactly in the limit. The dequantization is a phase transition: an infinite family of strictly curved, strictly increasing smooth functions collapsing onto a piecewise-linear object with none of those properties, and doing so at the tidy rate $\log 2/b$.

---

## Why this matters

**For machine learning.** A rectified linear network computes a piecewise-linear function of its inputs. In the tropical language, it computes a *tropical rational function* — a difference of two tropical polynomials — and the geometry of its decision boundaries becomes the geometry of Newton polytopes. What the bridge theorem gives is a *quantitative* version of the correspondence at the level of a single neuron: replacing every sharp corner by a smooth one with sharpness $b$ perturbs the output by at most $\log 2/b$. Chained through a network, this yields explicit control over how far a smoothed model can drift from its piecewise-linear idealization. Smoothing is not just a numerical convenience; it is a controlled deformation with a known modulus.

**For optimization.** Strict convexity plus strict monotonicity are exactly the properties that make gradient-based methods behave. The exact monotonicity criterion $a \geq 0$ tells a designer precisely which leaky activations retain those guarantees, and the fact that convexity survives *every* choice of $a$ tells them which property they can never lose.

**For physics and algebra.** The parameter $1/b$ is a temperature. At high temperature ($b$ small), the log-sum-exp is a genuine thermodynamic free energy averaging over configurations. At zero temperature ($b \to \infty$), only the ground state survives, and the free energy degenerates into a maximum — which is precisely tropical addition. Idempotent algebra is the zero-temperature limit of ordinary algebra, and the exponential–logarithmic transcendentals are the interpolation between them.

---

## A last picture

Imagine a dial labelled $b$. At $b = 1$ you see a gentle, rounded, everywhere-curving hill of a function. As you turn the dial up, the curve tightens, the corner sharpens; the whole visible discrepancy from the sharp corner is squeezed into a shrinking band of height $\log 2 / b$. At every finite setting the function is strictly convex, strictly increasing, and infinitely differentiable — a perfectly well-behaved analytic object. Only at the unreachable end of the dial does it snap into the piecewise-linear corner, and in that instant it loses strictness in both properties at once.

That dial connects the calculus of neural networks to the combinatorics of tropical geometry, and everything in between is exponentials and logarithms.
