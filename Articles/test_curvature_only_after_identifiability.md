# The Shape of a Coin Toss

## Why "very sensitive" and "negatively curved" are two different things — and how a three-sided die settles the argument

### A rumour that will not die

There is a story that circulates in statistics, machine learning and theoretical
physics, and it goes something like this. *Complex models are chaotic. Tiny changes
in their parameters produce wildly different behaviour. Chaos means exponential
divergence. Exponential divergence means hyperbolic geometry. Therefore the space of
models is negatively curved.*

Each step in that chain sounds plausible. Each one has a respectable-sounding
precedent: hyperbolic space really does separate its points exponentially fast, and
exponentially separating dynamics really are the signature of negative curvature in
Anosov theory. So the conclusion gets repeated, and then cited, and eventually it
stops being a conjecture and becomes a slogan: *statistical model space is
hyperbolic*.

This article is about what happens when you stop repeating the slogan and just
compute. We will take the simplest statistical model that is genuinely
two-dimensional — a three-sided die — measure its geometry from first principles,
and find that it is not hyperbolic at all. It is a *sphere*. Its curvature is a
constant $+1/4$: the curvature of a perfectly round ball of radius $2$. And it has
exponential sensitivity in the strongest form anyone could ask for.

The two properties simply do not talk to each other. That is the punchline, and the
rest of this article is about how you get there and what else you find along the
way.

---

### Giving a family of models a shape

Start with the object. A **statistical model** here means a smooth family of
probability distributions, one for each choice of parameters. Our first model is the
open trinomial simplex: a die with three faces, whose face probabilities are

$$p(x,y) = (x,\; y,\; 1 - x - y), \qquad x > 0,\; y > 0,\; 1 - x - y > 0.$$

The pair $(x, y)$ ranges over an open triangle, and each point of that triangle is a
loaded three-sided die.

Now, how far apart are two dice? Euclidean distance in the triangle is a bad answer.
The dice $(0.50, 0.25, 0.25)$ and $(0.51, 0.24, 0.25)$ are hard to tell apart, but
$(0.001, 0.499, 0.5)$ and $(0.011, 0.489, 0.5)$ differ by the same Euclidean amount
and are *easy* to tell apart: one of them shows face 1 about ten times as often as
the other. The right notion of distance must be *statistical*, measuring how quickly
data lets you distinguish the two.

That notion is the **Fisher information metric**. Define the *score functions*, the
sensitivity of the log-likelihood to each parameter,

$$s_i(a) = \frac{\partial}{\partial \theta_i} \log p_a(\theta),$$

and set

$$g_{ij}(\theta) = \mathbb{E}\big[s_i s_j\big] = \sum_a p_a(\theta)\, s_i(a)\, s_j(a).$$

This is the covariance of the score — the amount of information one observation
carries about the parameters. It is the unique Riemannian metric on a statistical
model that is invariant under sufficient statistics, which is Chentsov's theorem and
the reason it is *the* metric rather than *a* metric.

Two checks come first, and the order matters. Before you may speak of curvature, you
must know that (i) the scores are honest derivatives of the model — they are, and one
computes for the trinomial model

$$s_1 = \Big(\tfrac1x,\; 0,\; \tfrac{-1}{1-x-y}\Big), \qquad
s_2 = \Big(0,\; \tfrac1y,\; \tfrac{-1}{1-x-y}\Big),$$

and (ii) they are *centred*, $\mathbb{E}[s_i] = 0$, which is the regularity condition
guaranteeing the model is locally identifiable and that the Fisher metric is a
genuine covariance. Both hold. Carrying out the expectation gives a metric with no
approximations anywhere in sight:

$$g = \begin{pmatrix} \dfrac1x + \dfrac1z & \dfrac1z \\[2ex] \dfrac1z & \dfrac1y + \dfrac1z \end{pmatrix},
\qquad z = 1 - x - y.$$

Look at what it says. As $x \to 0$ — as the first face becomes nearly impossible —
the coefficient $1/x$ blows up. Distances near the boundary of the triangle are
enormous. In fact, for any bound $M$ you like, there is a point of the open simplex
where the Fisher information exceeds $M$. The model is *arbitrarily sensitive*. This
is the observation that starts the hyperbolic rumour: unbounded sensitivity, blow-up
at the boundary, an infinitely deep well — surely this is a hyperbolic plane in
disguise?

---

### The measurement

To answer that you have to actually compute the curvature, and there is no shortcut.
The recipe is fixed and unforgiving. From the metric $g$ you form the **Levi-Civita
connection**, the unique way of differentiating vector fields that is both
torsion-free (mixed second derivatives commute) and metric-compatible (lengths and
angles are preserved by parallel transport). Uniqueness is not a convenience here; it
is what makes the answer canonical. Given any candidate rule $\Gamma_{ij,l}$ with
those two properties, the algebra forces

$$\Gamma_{ij,l} = \tfrac12\big(\partial_i g_{jl} + \partial_j g_{il} - \partial_l g_{ij}\big),$$

with no freedom left over. There is exactly one geometry attached to the metric, so
"the curvature of the model" is a well-posed question.

Then you raise an index with the inverse metric — which for the trinomial model is
the delightfully simple multinomial covariance matrix

$$g^{-1} = \begin{pmatrix} x(1-x) & -xy \\ -xy & y(1-y)\end{pmatrix}$$

— assemble the Riemann tensor out of derivatives and products of the connection, and
contract it down to a single number, the Gauss curvature $K$. Curvature is the
failure of parallel transport around a small loop to be the identity; positive $K$
means triangles are fat and geodesics converge, negative $K$ means triangles are thin
and geodesics run away from each other.

Grind the derivatives through. Everything is rational in $x$ and $y$, and the
expressions along the way are not pretty: the Christoffel symbols involve terms like
$\frac{1}{2}\big(\frac{x}{1-x-y} - \frac{1}{x} + 1\big)$, and the raw curvature
numerator carries a factor $\frac{1}{xy(1-x-y)}$. But when the dust settles, all of
that cancels, and what is left is

$$\boxed{\;K(x, y) = \tfrac14 \quad \text{at every point of the open simplex.}\;}$$

Not negative. Not variable. The constant $+1/4$.

A sceptic is entitled to worry that a sign convention has been flipped somewhere. So
the same machinery — same connection formula, same Riemann tensor, same
contraction — was run on the Poincaré upper half-plane $g = y^{-2}(dx^2 + dy^2)$, the
standard model of the hyperbolic plane, and it returns $K = -1$, exactly as it must.
The conventions are calibrated. The $+1/4$ is real.

---

### Why a quarter?

A constant curvature of $1/4$ is $1/r^2$ with $r = 2$. Where does a sphere of radius
$2$ come from?

Take the square roots of the probabilities. The map

$$p \;\longmapsto\; 2\big(\sqrt{p_1},\, \sqrt{p_2},\, \sqrt{p_3}\big)$$

sends every probability vector to a point at Euclidean distance exactly $2$ from the
origin, because $\sum_a \left(2\sqrt{p_a}\right)^2 = 4 \sum_a p_a = 4$. The open
simplex lands inside the positive octant of the round sphere of radius $2$ in
$\mathbb{R}^3$. And the miracle — it is not a miracle, it is a two-line
computation — is that the ordinary Euclidean metric of that sphere pulls back to
*exactly* the Fisher metric. The statistical model and the piece of sphere are the
same Riemannian surface. A sphere of radius $2$ has curvature $1/4$. Done.

This is the Bhattacharyya–Hellinger picture, and once you see it, the blow-up at the
boundary loses its menace entirely. The sphere is perfectly smooth there. What blows
up is only the *coordinate system* $(x, y)$, which is like latitude–longitude near a
pole: the chart degenerates, the surface does not.

---

### Where the exponential rate actually lives

Now put the two halves together, because this is where the rumour dies.

Take two distinct dice $p$ and $q$. How fast can you tell them apart from $n$
independent throws? The classical measure is the **Hellinger affinity**

$$\rho(p, q) = \sum_a \sqrt{p_a q_a},$$

which is $1$ when $p = q$ and less than $1$ otherwise, since
$\rho = 1 - \tfrac12\sum_a(\sqrt{p_a}-\sqrt{q_a})^2$. Its crucial property is
*tensorisation*: for the $n$-fold product model, the affinity between the two product
distributions is exactly

$$\rho_n = \rho(p,q)^n.$$

Since $0 < \rho < 1$ strictly, $\rho^n \to 0$ *geometrically*. Two distinct dice
become distinguishable at an exponential rate in the sample size. This is exponential
statistical sensitivity in its strongest, cleanest form: no asymptotics, no
approximation, an exact power law.

And here is the thing. Look again at the sphere embedding. The Euclidean inner
product of the two embedded points is

$$\big\langle 2\sqrt{p},\, 2\sqrt{q} \big\rangle = 4\sum_a \sqrt{p_a q_a} = 4\rho(p,q).$$

So $\rho$ *is* the cosine of the angle between the two points on the sphere. The
exponential rate of statistical distinguishability is a cosine — the most positively
curved quantity in geometry. The Fisher–Rao geodesic distance between the two dice is
literally $2\arccos\rho$, an arc length on a round sphere.

The exponential decay $\rho^n$ has nothing to do with the shape of the parameter
space. It comes from *independence* — from multiplying likelihoods across $n$
observations, which turns any number below $1$ into a geometric sequence. It would
happen just as fast if the model were flat, or spherical, or hyperbolic. Reading
"exponential separation of hypotheses" as "hyperbolic parameter space" confuses a
property of the product construction with a property of the geometry.

The counterexample can be stated in one sentence: **there is a statistical model
whose $n$-sample hypotheses separate at an exact geometric rate $r^n$ with
$0 < r < 1$, and whose Fisher–Rao geometry has constant curvature $+1/4$ at every
point.** Since $+1/4$ is not negative, and this holds at every point of the model,
the implication "exponential sensitivity $\Rightarrow$ negative curvature" is false.
Not unproven — false, with a witness you can hold in your hand.

---

### Three models, three signs

If the trinomial simplex were the only finite-support model, one might argue that
finite support *forces* positive curvature and the whole discussion is moot. It does
not, and the sharpest way to see it is to compute two more models with the same
machinery.

**A flat one.** Take two independent coin flips, with biases $u$ and $v$:

$$p = \big(uv,\; u(1-v),\; (1-u)v,\; (1-u)(1-v)\big).$$

Four outcomes, two parameters. Its Fisher metric is the *product*

$$g = \mathrm{diag}\!\left(\frac{1}{u - u^2},\; \frac{1}{v - v^2}\right),$$

each factor depending on its own variable alone. All mixed Christoffel symbols
vanish, so the entire Riemann tensor does, and the curvature is identically $0$. The
independence model is Fisher-*flat*. (It is, in fact, a Euclidean rectangle in
disguise: the substitution $u = \sin^2(\phi/2)$ straightens each factor out.)

**A genuinely wobbly one.** Now break the product structure with a *tie*. Suppose a
population splits into two groups: group $A$ occurs with probability $1 - s$ and
succeeds with probability $t$; group $B$ occurs with probability $s$ and succeeds
with probability $t^2$ — the same underlying parameter, squared, as if group $B$ must
clear the hurdle twice. Then

$$p = \big((1-s)t,\; (1-s)(1-t),\; s t^2,\; s(1 - t^2)\big), \qquad (s,t) \in (0,1)^2.$$

The Fisher metric is still diagonal — the group share and the success parameter turn
out to be orthogonal — but its second entry is now
$\big((1-s) + (1+3s)t\big)/(t - t^3)$, which couples the two coordinates and destroys
the product structure. The curvature is a genuine function of position, and it
changes sign:

$$K\!\left(\tfrac1{10}, \tfrac12\right) = -\frac{239}{3844} \approx -0.0622 < 0,
\qquad
K\!\left(\tfrac1{10}, \tfrac1{10}\right) = \frac{6209}{42436} \approx +0.1463 > 0.$$

Both are exact rational numbers. Between the two points runs a curve on which the
curvature vanishes exactly, and the model's geometry passes smoothly from spherical
to hyperbolic as you cross it.

So among four-outcome, two-parameter models with finitely many outcomes, the
Fisher–Rao curvature attains strictly positive values, exactly zero, and strictly
negative values — and one single model already attains two of the three. There is no
such thing as "the curvature of a finite-support model." The number of outcomes and
the number of parameters tell you nothing about the sign. Curvature is a property of
the specific family, and it has to be computed for that family.

---

### What the family of connections says

One more wrinkle, and it is the most beautiful part of the computation.

Information geometry does not stop at one connection. Amari's **$\alpha$-family**
interpolates between two natural ways of differentiating on a statistical model,
using the *skewness tensor* $C_{ijk} = \mathbb{E}[s_i s_j s_k]$:

$$\Gamma^{(\alpha)}_{ij,l} = \Gamma_{ij,l} - \frac{\alpha}{2} C_{ijl}.$$

At $\alpha = -1$ you get the mixture connection (straight lines are convex mixtures of
distributions); at $\alpha = +1$ the exponential connection (straight lines are
exponential tilts); at $\alpha = 0$ the Levi-Civita connection of the Fisher metric.

On the trinomial simplex something clean happens. In these mixture coordinates the
metric derivative *is* minus the skewness tensor, $\partial_k g_{ij} = -C_{ijk}$, from
which $\Gamma_{ij,l} = -\tfrac12 C_{ijl}$ and hence the whole $\alpha$-family collapses
into a single scalar multiple of the Levi-Civita connection:
$\Gamma^{(\alpha)} = (1 + \alpha)\Gamma$. Because curvature is quadratic in the
connection, this forces the curvature scalar to be a quadratic polynomial in
$\alpha$, and it is:

$$K_\alpha = \frac{1 - \alpha^2}{4}.$$

Read it off. At $\alpha = 0$ it is $1/4$, our Gauss curvature. At $\alpha = \pm 1$ it
is exactly $0$: the two dual connections are *flat*, which is Amari's dual flatness
theorem for the simplex, here as a corollary of a single quadratic. Across the whole
statistically meaningful range $|\alpha| \le 1$ the curvature is non-negative, and it
is negative *only* for $|\alpha| > 1$, outside the range anyone uses. Not one member
of the standard family gives you a hyperbolic geometry.

---

### The moral

None of this says negative curvature is unimportant, or that no statistical model is
hyperbolic. Some are; the tied model above is negatively curved on an open region.
What the computation says is narrower and more useful: **negative curvature is an
independent claim, and it must be tested independently.**

Test identifiability first — are the scores honest derivatives, are they centred, is
the metric non-degenerate? Only then compute the connection, and only then the
curvature, and compute it, don't infer it. Exponential sensitivity will not tell you
the answer; the boundary blow-up of the coordinates will not tell you the answer;
the number of outcomes will not tell you the answer. In the case at hand every one of
those heuristics points towards hyperbolic, and every one of them is wrong: the
answer is a round sphere of radius $2$.

There is a wider lesson here about the vocabulary we borrow. "Exponential",
"sensitive", "chaotic", "hyperbolic", "negatively curved" are five different words
that describe five different things, and they have drifted into being treated as
synonyms because in a few celebrated examples they happen to coincide. The three-sided
die is a reminder that they don't have to. It is about as simple as a statistical
model gets — you could explain it to a child with a spinner — and it separates the
concepts cleanly and permanently.

Compute the curvature. It is only a page of algebra, and the answer may surprise you.
