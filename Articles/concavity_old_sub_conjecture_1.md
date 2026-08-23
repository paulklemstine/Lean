# The Curve That Rewards Compromise

## A single cubic, a single number $1/27$, and the exact moment averaging starts to pay

### A question about mixing

Suppose you run a process whose *output* depends on some *input mass* — the yield of a
chemical reaction as a function of reagent concentration, the branching rate of a population
as a function of resources, the growth exponent of a combinatorial structure as a function of
a weight parameter. Call the input $t$ and the output $\sigma(t)$.

Now ask the mixing question. You have two batches, one with mass $s$ and one with mass $t$.
You can either run them separately and average the two outputs, or pool them into one batch of
average mass $(s+t)/2$ and run *that*. Which is better?

The answer is decided by a single word: **concavity**. If
$$\frac{\sigma(s) + \sigma(t)}{2} \le \sigma\!\left(\frac{s+t}{2}\right)$$
holds for all admissible $s$ and $t$, then pooling is never worse — averaging your masses never
decreases your output. If the inequality runs the other way, mixing is a mistake and you should
keep your batches apart, pushing them to the extremes.

For the function this article is about, *both* things happen — and they happen on either side of
one specific number. That number is $1/27$. Below it, mixing hurts. Above it, mixing helps.
And $1/27$ is not a tuning constant someone chose: it is forced twice over, once by algebra and
once by a piece of the most classical inequality in mathematics.

### The critical cubic

Start with a cubic polynomial:
$$h(y) = y^3 - y^2 + \tfrac{1}{3}\,y .$$

Cubics are usually messy. This one is not, and the reason is visible in its derivative:
$$h'(y) = 3y^2 - 2y + \tfrac{1}{3} = 3\left(y - \tfrac{1}{3}\right)^{\!2}.$$

The derivative is a *perfect square*. It is never negative, and it vanishes at exactly one point,
$y = 1/3$. Generic cubics have two distinct critical points — a local max and a local min —
and consequently a range of heights where the curve is hit three times. Here those two critical
points have collided into one **degenerate** critical point. The curve never turns around; it
merely pauses, flattening to horizontal for an instant at $y = 1/3$ before resuming its climb.

Because $h$ is strictly increasing on the whole real line, every height is reached exactly once.
The equation $h(y) = t$ has a *unique* real solution for every real $t$. Write it $\sigma(t)$:
the **Lagrange exponent** attached to mass $t$.

A general cubic equation needs Cardano's formula, complex intermediates and a certain amount of
care. This one does not, because the degeneracy makes $h$ an affine copy of a pure cube:
$$h(y) = \frac{(3y-1)^3 + 1}{27}.$$
(Expand and check: the $y^2$ and $y$ terms fall exactly where they should.) Inverting this is
one line of algebra, and the answer is
$$\boxed{\;\sigma(t) = \frac{1 + \sqrt[3]{27t - 1}}{3}\;}$$
where $\sqrt[3]{\cdot}$ is the honest, sign-aware real cube root, defined on all of $\mathbb{R}$
by $\sqrt[3]{-x} = -\sqrt[3]{x}$. Classical resolvent theory, applied to this cubic, collapses
to a single real radical.

Two values are worth memorising. At $t = 0$, $\sigma(0) = 0$. And at
$$t = \frac{1}{27}, \qquad \sigma\!\left(\frac{1}{27}\right) = \frac{1}{3},$$
because $h(1/3) = 1/27$: the mass $1/27$ is precisely the height at which the growth rate passes
through the degenerate critical point. Everything in this story happens at that point.

### The main theorem: above $1/27$, averaging pays

**Concavity Theorem.** *The Lagrange exponent $\sigma$ is concave on $[1/27, \infty)$, and in
fact strictly so: for masses $s \neq t$ both at least $1/27$,*
$$\frac{\sigma(s) + \sigma(t)}{2} < \sigma\!\left(\frac{s+t}{2}\right).$$

Why is it true? Because of the collapse to a pure cube. The formula
$\sigma(t) = \bigl(1 + \sqrt[3]{27t-1}\bigr)/3$ says that $\sigma$ *is* the cube-root function
$x \mapsto x^{1/3}$, seen through an affine change of variables: substitute $x = 27t - 1$ (an
increasing, mass-preserving-up-to-scale relabelling), take the cube root, then shift and rescale
by positive constants. Concavity survives every one of these operations. And on $x \ge 0$ the
cube root is the archetypal concave function: its slope $\tfrac{1}{3}x^{-2/3}$ is steep near zero
and flattens forever after. When $t \ge 1/27$ we have $x = 27t - 1 \ge 0$, so we are exactly in
the regime where $x^{1/3}$ is concave. Transport that back and the theorem is proved.

The concavity is not a formal curiosity; it is a statement about a system. Read $\sigma$ as a
growth rate and $t$ as the mass fed into it, and the theorem says: **averaging two mass
distributions never decreases the growth rate**, with a *strict* gain whenever the two masses
actually differ. Homogenising is free money.

And it is not limited to two ingredients. Concavity upgrades automatically to arbitrary weighted
averages — Jensen's inequality. If $w_1, \dots, w_n \ge 0$ are weights summing to $1$ and each
mass $m_i$ satisfies $m_i \ge 1/27$, then
$$\sum_{i=1}^{n} w_i\,\sigma(m_i) \;\le\; \sigma\!\left(\sum_{i=1}^{n} w_i m_i\right).$$
Any blend beats the corresponding blend of outputs.

### The mirror world below $1/27$

Here is where the story acquires its edge. Below the critical mass the curvature is *reversed*.

**Convexity Theorem.** *$\sigma$ is strictly convex on $(-\infty, 1/27]$.*

The mechanism is a sign flip. For $t \le 1/27$ we have $27t - 1 \le 0$, so we write
$\sqrt[3]{27t-1} = -\bigl(1 - 27t\bigr)^{1/3}$, and now $\sigma$ is $x \mapsto x^{1/3}$ composed
with the *decreasing* affine map $t \mapsto 1 - 27t$ and then negated. A concave function
reflected through the horizontal axis is convex. Same cube root, same argument, opposite
conclusion.

Geometrically: $t = 1/27$ is an **inflection point**, and it is the image, under $h$, of the
degenerate critical point $y = 1/3$. The cubic flattens at $y = 1/3$; its inverse function has
vertical slope there and switches the direction it bends. Below the critical mass, mixing two
distributions *reduces* the growth rate — the system rewards polarisation, not compromise.

### Sharpness: $1/27$ is exactly the boundary

It is easy to state a theorem with a safe but wasteful hypothesis. "Concave on $[1/27, \infty)$"
would be a weaker claim than it looks if $\sigma$ happened to be concave everywhere, or on
$[1/1000, \infty)$. It is not.

**Sharpness Theorem.** *For every $a < 1/27$, the function $\sigma$ fails to be concave on
$[a, \infty)$. Equivalently: $\sigma$ is concave on $[c, \infty)$ **if and only if**
$c \ge 1/27$. Mirror-wise, $\sigma$ is convex on $(-\infty, c]$ if and only if $c \le 1/27$.*

The proof is a two-line collision. Take any $a < 1/27$. The two points $a$ and $1/27$ both lie in
the interval $[a,\infty)$, and they also both lie in $(-\infty, 1/27]$. If $\sigma$ were concave
on $[a,\infty)$, the midpoint inequality for the pair $(a, 1/27)$ would read
$\tfrac{1}{2}\sigma(a) + \tfrac{1}{2}\sigma(1/27) \le \sigma\bigl(\tfrac{a + 1/27}{2}\bigr)$.
But strict convexity below the critical mass applies to that *same* pair and gives the strict
reverse inequality. The two cannot both hold. So the hypothesis $t \ge 1/27$ in the main theorem
is not a convenience — it carves out the precise region where the phenomenon is real.

### Why $1/27$? Ask AM–GM

So far $1/27$ arrived from algebra: it is $h(1/3)$, the height of the degenerate critical point.
There is a second, entirely independent reason it is the right number.

Take a probability distribution on three states: nonnegative numbers $p, q, r$ with
$p + q + r = 1$. What is the largest their product can be?

**AM–GM bound.** *If $p, q, r \ge 0$ and $p + q + r = 1$, then $pqr \le 1/27$, with equality if
and only if $p = q = r = 1/3$.*

That is the arithmetic–geometric mean inequality in three variables, and $1/27 = (1/3)^3$ is its
extremal value. So if the mass fed to our mechanism is the *product mass* of a three-point
distribution, it can never exceed $1/27$ — and correspondingly, since $\sigma$ is increasing,
$$\sigma(pqr) \le \sigma\!\left(\tfrac{1}{27}\right) = \tfrac{1}{3},$$
with equality precisely for the uniform distribution $p = q = r = 1/3$, and *strict* inequality
for every other distribution.

The same number $1/27$ appears as the critical value of an algebraically degenerate cubic and as
the extremum of a three-variable optimisation problem, and the two coincide because both are
$(1/3)^3$. The critical mass is the mass of the *most balanced* three-point distribution. That is
the sense in which the concavity threshold is canonical rather than chosen: the physical regime
$t \ge 1/27$ is exactly the regime *at or above* what a balanced three-slot distribution can
supply.

### What concavity buys you

Concavity is not an end in itself; it is a licence to prove other things. Three consequences.

**1. The growth rate is a cube root, up to at most $1/3$.**

For every real $t$ (no hypothesis at all),
$$\sigma(t) \le \sqrt[3]{t} + \tfrac{1}{3},$$
and on the physical range $t \ge 1/27$ we also have the matching lower bound
$$\sqrt[3]{t} \le \sigma(t).$$
So $\sigma(t) - \sqrt[3]{t}$ is squeezed into $[0, 1/3]$: **the growth rate is a cube root plus a
bounded correction**. Both ends of the sandwich are attained in the limit — the gap is exactly
$0$ at the critical mass $t = 1/27$ (where $\sigma = \sqrt[3]{1/27} = 1/3$) and it climbs to $1/3$
as $t \to \infty$, since $\sqrt[3]{27t - 1} \to 3\sqrt[3]{t}$. The constant $1/3$ cannot be
improved.

**2. Merging is cheaper than running separately.**

Anchor the concavity inequality at the critical point $(1/27, 1/3)$, and out drops a
subadditivity law: for admissible masses $s, t \ge 1/27$,
$$\sigma\!\left(s + t - \tfrac{1}{27}\right) + \tfrac{1}{3} \;\le\; \sigma(s) + \sigma(t).$$
Read it as an accounting identity. Running two systems separately costs $\sigma(s) + \sigma(t)$.
Merging them into one system of combined mass, *paying the critical overhead $1/27$ exactly once
instead of twice*, costs no more. The proof writes each of $s$ and $t$ as a convex combination of
the merged mass $s + t - 1/27$ and the critical mass $1/27$ with complementary weights, applies
concavity twice, and adds; the merged terms cancel because the two weight pairs are mirror images.

Iterating over a family of $n$ admissible masses $m_1, \dots, m_n$ gives the $n$-fold merging law
$$\sigma\!\left(\sum_{i=1}^n m_i - \frac{n-1}{27}\right) + \frac{n-1}{3} \;\le\; \sum_{i=1}^n \sigma(m_i),$$
in which the critical overhead is paid once, no matter how many components are merged.

**3. $\sigma$ is a perfect order isomorphism of the line.**

Since $h$ is a strictly increasing bijection of $\mathbb{R}$ and $\sigma$ is its two-sided
inverse, $\sigma$ is an increasing bijection $\mathbb{R} \to \mathbb{R}$ — in particular
continuous and surjective. *Every* growth rate is realised by exactly one mass. There are no
gaps, no multivaluedness, no branch choices: the price of the degeneracy at $y = 1/3$ is a
single point of infinite slope, and the reward is a globally single-valued inverse.

For the analytically minded, the curvature statement has an exact differential shadow. Above the
critical mass $\sigma$ is differentiable with
$$\sigma'(t) = 3\,(27t - 1)^{-2/3},$$
which blows up as $t \downarrow 1/27$ and decreases monotonically to $0$ thereafter. A decreasing
derivative is concavity in its most familiar form. Note that the derivative fails to exist at
$t = 1/27$ itself — the tangent is vertical there — which is exactly why the clean, derivative-free
convexity argument, run through the cube root, is the right way to prove the theorem: it covers
the endpoint that calculus cannot reach.

### The shape of the whole picture

Put it all together and the graph of $\sigma$ tells a complete story in one stroke. Far to the
left it rises convexly, steepening; at $t = 1/27$ it passes through the point $(1/27, 1/3)$ with a
vertical tangent, the exact image of the flat spot in the cubic; and thereafter it turns over and
rises concavely forever, hugging the curve $\sqrt[3]{t} + 1/3$ from below. One inflection, one
critical mass, one number.

What makes it satisfying is the triple coincidence at $1/27$: it is the height of the degenerate
critical point of the cubic, it is the sharp boundary between the mixing-hurts and mixing-helps
regimes, and it is the AM–GM extremum $(1/3)^3$ of a three-point distribution. Three descriptions,
one number — and once you know the cubic's derivative is a perfect square, you can see why they
had to agree.

### Where this goes next

The proof used the number $3$ only twice: through the concavity of $x \mapsto x^{1/3}$, and
through the fact that odd powers are monotone on all of $\mathbb{R}$. Both have analogues for
every odd $n$. So one expects a family: for each $n$, the monic degree-$n$ polynomial $h_n$ with
$h_n'(y) = n\,(y - 1/n)^{n-1}$ and $h_n(0) = 0$ should have an inverse $\sigma_n$ that is concave
exactly on $[h_n(1/n), \infty)$, convex below it when $n$ is odd, and separated from the pure
radical $t^{1/n}$ by a gap growing from $0$ to $1/n$. Even $n$ must behave differently — $h_n$ is
then not injective on $\mathbb{R}$ and the convex mirror has nowhere to live.

Beyond that, one can drop the perfect-square hypothesis entirely. For a general real cubic
$p(y) = y^3 + ay^2 + by + c$ with an increasing inverse branch, the inflection sits at
$y^{*} = -a/3$, and one expects the inverse to be concave exactly on $[\,p(y^{*}), \infty)$ — so
that the curvature threshold is a *polynomial function of the coefficients*, namely the constant
term $c - ab/3 + 2a^3/27$ of the depressed cubic. That turns an analytic question about curvature
into an algebraic question about coefficient loci, with the discriminant lurking in the
background.

Finally, the AM–GM bridge begs to be pushed onto the simplex. For a distribution
$p = (p_1, \dots, p_k)$ with $\sum p_i = 1$, the composite $p \mapsto \sigma_k(\prod_i p_i)$ should
be bounded by $1/k$, with equality only at the uniform point, and should be strictly
Schur-concave — meaning it decreases whenever the distribution is made more unequal in the
majorisation order, with level sets exactly the majorisation classes. The critical constant would
then be revealed for what it is: not a constant at all, but the value of an optimisation problem
over a simplex.

For now, the three-dimensional case is settled, and settled sharply. Above the critical mass
$1/27$, compromise is always rewarded — and below it, never.
