# The Three Operations That Can Draw Anything

## A surprising claim about exp, log, and arithmetic

Imagine you are handed an astonishingly restrictive toolbox. Inside it you find only three kinds of operations: you may **add and multiply** numbers (and scale them by constants), you may take the **exponential** $e^x$ of anything you have built, and you may take the **logarithm** $\log x$ of anything you have built that happens to be positive. That's it. No sines, no cosines, no absolute values, no special "max" gadget, no neural-network layers bought off the shelf.

Now someone draws an arbitrary smooth landscape over the unit square — a continuous height map $f$ defined for every point $(x, y)$ with $0 \le x \le 1$ and $0 \le y \le 1$. It might be a mountain range, a rippling pond, the silhouette of a face. The challenge: using *only* your three operations, build a formula that reproduces that landscape to within any tolerance you like. A millimeter. A micron. A billionth of a micron.

The remarkable answer is that **you can always do it.** The class of functions you can write down with exponentials, logarithms, and arithmetic — call them **EML functions**, for Exponential–Multiplicative–Logarithmic — is *dense* in the space of all continuous functions on the cube. Every continuous function, no matter how wild, has an EML function arbitrarily close to it everywhere at once. This article is the story of why that is true, what it costs, and why it matters far beyond a piece of pure mathematics.

## Why "everywhere at once" is the hard part

It is easy to match a function at a few points. Run a curve through ten dots and you are done. The difficulty in approximation theory is *uniformity*: we want the error to be small **simultaneously at every single point** of the square, not just on average and not just at sample locations. The right way to measure this is the **uniform norm** (also called the sup norm):

$$\|g - f\| = \max_{x \in [0,1]^n} |g(x) - f(x)|.$$

This single number records the worst mismatch anywhere on the entire domain. Saying that EML functions are dense means: for every continuous target $f$ and every tolerance $\varepsilon > 0$, there is an EML function $g$ with

$$\|g - f\| < \varepsilon.$$

The worst error, anywhere, is below $\varepsilon$. That is a strong promise, and it is exactly the promise that makes approximation theory useful in engineering: a controller, a circuit, or a learned model that is "usually" right but occasionally wildly wrong is often worse than useless.

## The master key: Stone and Weierstrass

How could one possibly prove that three humble operations can imitate *every* continuous function? The trick is not to fight each target function individually. Instead we lean on one of the most elegant theorems in twentieth-century analysis: the **Stone–Weierstrass theorem**.

Karl Weierstrass proved in 1885 that ordinary polynomials can uniformly approximate any continuous function on an interval. Marshall Stone, in the 1930s and 40s, distilled the essence of *why* into a structural principle that applies far beyond polynomials. Stone's insight was that approximation power is not about the specific formulas you use; it is about two abstract properties of the whole *collection* of functions you can build:

1. **It is an algebra.** The collection is closed under addition, multiplication, and scaling by constants. If $g$ and $h$ are in your toolbox's reach, so are $g + h$, $g \cdot h$, and $5g$. Such a closed-under-arithmetic collection is called a **subalgebra** of the continuous functions.

2. **It separates points.** For any two distinct points $a \ne b$ in the domain, some function in your collection assigns them different values. The toolbox can "tell any two points apart."

Stone–Weierstrass says: *on a compact space, any subalgebra that separates points is dense.* That is the master key. To prove that EML functions can draw anything, we do not need to construct clever approximations by hand. We only need to verify these two clean structural conditions, and the theorem does the rest.

Formally, the version we use reads:

> **Stone–Weierstrass (point-separating form).** Let $X$ be a compact Hausdorff space and let $A$ be a subalgebra of the continuous real functions $C(X, \mathbb{R})$. If $A$ separates points, then the closure of $A$ is everything: $\overline{A} = C(X, \mathbb{R})$.

Equivalently, in the language of approximation: every $f \in C(X, \mathbb{R})$ and every $\varepsilon > 0$ admit a $g \in A$ with $\|g - f\| < \varepsilon$.

## Setting the stage: the cube as a stage of points

To make all of this precise we need a clean arena. We take the **unit cube** $[0,1]^n$ — the set of all points whose $n$ coordinates each lie between $0$ and $1$. For $n = 2$ it is the unit square; for $n = 3$ a solid cube; for general $n$ a hypercube. Crucially, the cube is **compact** (closed and bounded) and **Hausdorff** (distinct points can be surrounded by disjoint neighborhoods). These are exactly the hypotheses Stone–Weierstrass demands, because the cube is a finite product of the compact, Hausdorff interval $[0,1]$.

The simplest functions on the cube are the **coordinate projections**: the function $\pi_i$ that reads off the $i$-th coordinate of a point and ignores the rest, $\pi_i(x) = x_i$. There are $n$ of them. From these seeds we grow our first algebra.

## Step one: the coordinate algebra already separates points

Let $\mathcal{A}_{\text{coord}}$ be the smallest subalgebra containing all the coordinate projections — concretely, the set of all **polynomials in the coordinates**, things like $3x_1^2 x_2 - x_3 + 7$. This is the starting toolbox.

Does it separate points? Take two distinct points $a \ne b$ of the cube. Being different means they disagree in at least one coordinate: $a_i \ne b_i$ for some $i$. But then the coordinate projection $\pi_i$ already pulls them apart, since $\pi_i(a) = a_i \ne b_i = \pi_i(b)$. So a *single* coordinate function distinguishes them. Point separation is immediate.

By Stone–Weierstrass, that one fact is enough:

> **Density of the coordinate algebra.** The polynomials in the coordinates are dense in $C([0,1]^n, \mathbb{R})$. For every continuous $f$ and every $\varepsilon > 0$ there is a polynomial $g$ in the coordinates with $\|g - f\| < \varepsilon$.

This is the multivariate Weierstrass theorem, recovered as a special case. It already proves that *arithmetic alone* (no exp, no log) can draw anything on the cube.

## Step two: adding exp and log — the full EML algebra

So why bring in exponentials and logarithms at all, if polynomials already suffice? Two reasons, one structural and one practical.

The structural reason is honesty about the function class. "EML functions" by definition allow $\exp$ and $\log$, so the natural object of study is the *full* EML algebra $\mathcal{A}_{\text{EML}}$: the smallest collection that contains the coordinate algebra **and** is additionally closed under

- the **exponential operation**, sending a function $f$ to the function $x \mapsto e^{f(x)}$; and
- the **logarithm operation**, sending a *positive* function $f$ (one with $f(x) > 0$ everywhere, so the logarithm stays continuous) to $x \mapsto \log f(x)$.

This is built up inductively: start with coordinate polynomials and constants, then repeatedly apply addition, multiplication, exponentiation, and (positive) logarithm. The full EML algebra strictly contains the coordinate algebra — it has genuinely new members like $e^{x_1}$ that are not polynomials — yet it still lives inside $C([0,1]^n, \mathbb{R})$, and it certainly still separates points (it contains the coordinate functions that already did the job). So Stone–Weierstrass applies verbatim:

> **EML Universal Approximation Theorem.** The full EML algebra is dense in $C([0,1]^n, \mathbb{R})$. Every continuous function on the cube can be uniformly approximated, to any tolerance, by a finite formula in the coordinates using addition, multiplication, scalar constants, exponentials, and logarithms.

That is the headline. Three operations, and the entire universe of continuous shapes is within reach.

## The practical payoff: depth, width, and the softmax trick

The practical reason to care about exp and log is **efficiency**, and this is where the story connects to modern machine learning. Density says an approximant *exists*; it says nothing about how big or deep the formula must be. The deeper question is the **rate**: how good an approximation can you buy for a given amount of structure?

Here a single, beautiful identity does enormous work. Consider the **log-sum-exp** function — the smooth stand-in for the maximum that powers the "softmax" layers of essentially every modern neural network:

$$\operatorname{LSE}(x_1, x_2) = \log\!\left(e^{x_1} + e^{x_2}\right).$$

This is an EML function of *depth two*: one layer of exponentials, a sum, and one outer logarithm. What does it compute? Almost exactly the maximum. The exact accounting is

$$\log\!\left(e^{x_1} + e^{x_2}\right) = \max(x_1, x_2) + \log\!\left(1 + e^{-|x_1 - x_2|}\right),$$

and since the correction term is squeezed between $\log 1 = 0$ and $\log 2$, we get the clean two-sided sandwich

$$\max(x_1, x_2) \;\le\; \log\!\left(e^{x_1} + e^{x_2}\right) \;\le\; \max(x_1, x_2) + \log 2.$$

So a depth-two EML network reproduces the maximum with an error that never exceeds the universal constant $\log 2 \approx 0.693$ — *regardless of the inputs*. This is the rigorous heart of why "smooth max" works.

The truly useful part is that the error is not fixed; it is a **dial you can turn.** Insert a temperature parameter $c > 0$, run the inputs through $\operatorname{LSE}$ scaled by $c$, and divide back out. The resulting *scaled* log-sum-exp obeys

$$\left|\;\frac{1}{c}\log\!\left(e^{c x_1} + e^{c x_2}\right) - \max(x_1, x_2)\;\right| \;\le\; \frac{\log 2}{c}.$$

Crank $c$ up and the error melts away like $1/c$. This is **dequantization**: a continuous, differentiable EML formula converging to the sharp, non-differentiable $\max$ as the temperature rises, with an *explicit, provable* error bound at every finite temperature. Want the approximation accurate to $\varepsilon$? Choose $c = \log 2 / \varepsilon$ and you are guaranteed to be within $\varepsilon$, everywhere, forever.

## Why depth is the currency

This is where "depth of the composition" enters the title's promise. The maximum of two numbers is exactly the kind of sharp, corner-laden function that polynomials approximate only clumsily — to pin down a sharp ridge with smooth polynomials you need very high degree, i.e. enormous *width*. The EML class buys the same accuracy with a tiny, fixed *depth*: two layers (exp, then log) and a single tunable constant.

That trade-off — a little depth replacing a lot of width — is precisely the phenomenon that makes deep networks powerful in practice. The log-sum-exp identity is the cleanest possible instance of it, and because the constant is exactly $\log 2$ and the rate is exactly $1/c$, it can be taught, audited, and trusted rather than merely observed empirically.

The same construction scales: the maximum of $m$ numbers is captured by one log-of-sum-of-$m$-exponentials, with a worst-case gap of $\log m$ before temperature scaling, i.e. an error of $\log m / c$ after. A depth-two EML network of width $m$ therefore smooths the $m$-way maximum to any desired accuracy — a width-$m$, depth-$2$ realization of a function that any exp/log-free polynomial would need explosively high degree to match.

## The tropical connection

There is a deeper current running underneath all of this, and it gives the subject its name: **tropical mathematics**. In the "tropical" or "max-plus" semiring, the role of ordinary addition is played by $\max$ and the role of ordinary multiplication is played by $+$. Tropical polynomials are exactly piecewise-linear functions — the hinges, ridges, and folds you get from taking maxima of linear pieces. They are also, strikingly, the exact functions computed by neural networks built from linear layers and ReLU activations.

Log-sum-exp is the bridge between the smooth world and the tropical world. As the temperature $c \to \infty$, the smooth EML operation $\frac{1}{c}\operatorname{LSE}(c\,\cdot)$ degenerates into the tropical operation $\max$. The exponential map carries ordinary addition to multiplication and ordinary maximum to addition; the logarithm carries it back. EML functions are, in this precise sense, the **analytic shadow of tropical geometry** — and the error bounds above quantify exactly how faithful that shadow is at each finite temperature.

So the universal approximation theorem for EML functions is really two theorems wearing one coat. On the smooth side, it is Stone–Weierstrass: arithmetic-with-exp-and-log can draw any continuous shape. On the tropical side, it is dequantization: those same operations smoothly and controllably converge to the sharp, piecewise-linear primitives of max-plus algebra, with the conversion error pinned to the explicit constants $\log 2$ and $\log m$.

## What it all means

Strip away the formalism and the message is simple and a little astonishing. A toolbox containing only addition, multiplication, the exponential, and the logarithm is **universal**: it can reproduce every continuous function on a bounded domain to any precision. The proof costs almost nothing once you have Stone's master key — you need only check that coordinate projections tell points apart, which they obviously do.

But the *reason to prefer* exp and log over plain polynomials is efficiency, and that reason is made quantitative by the log-sum-exp identity. The same two operations that guarantee universality also give you a depth-two, temperature-tunable smoother for the maximum, with error exactly controlled by $\log 2 / c$ for two inputs and $\log m / c$ for $m$. That is not a metaphor for how deep learning works; it is a clean, fully accounted-for special case of it.

Three operations. Every shape. A dial labeled "accuracy." And underneath, a quiet bridge between the smooth calculus of exponentials and the angular geometry of the tropical world. That is the EML universal approximation theorem — small in its ingredients, vast in its reach.
