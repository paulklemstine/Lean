# The Square-Root Law of Batching — and What Happens When Multiplication Gets Cheaper

## A puzzle from the machine room

Suppose you are sieving. Not for gold, but for numbers: you have a stream of
candidates and, for each one, you want to know whether it is *smooth* — whether it
factors entirely into small primes. This is the inner loop of essentially every
modern integer-factoring and discrete-logarithm algorithm, and it is where the
machine spends almost all of its life.

Testing one candidate at a time is wasteful. There is a beautiful trick, due in
spirit to Bernstein: multiply a whole **batch** of candidates into one gigantic
integer, and test them all at once against the product of the small primes. One
expensive setup — computing a product tree, reducing a large modulus — is then
shared across the entire batch. The bigger the batch, the more thinly the setup is
spread.

So: make the batch as big as possible? The machine says no. Somewhere around a
batch of a few thousand candidates, the curve turns around and larger batches start
getting *worse*. In one careful measurement of a batch smoothness test, the
turning point sat near $1715$ candidates. Below it, batching wins; above it, testing
candidates one at a time is cheaper again.

Why should there be a turning point at all? And why *there*?

## The tension in one line

Write $k$ for the batch size and count the cost **per candidate**. Three things
contribute.

* A **setup** cost $A$, paid once per batch, hence $A/k$ per candidate. It falls as
  the batch grows.
* A **flat** per-candidate cost $c$, indifferent to $k$.
* A **penalty** for working with a big integer. A batch of $k$ candidates makes a
  number roughly $k$ times as long, and multiplying long numbers is
  super-linear. If multiplying two $n$-word integers costs about $n^{\mu}$ word
  operations, then per candidate the batch product costs about $k^{\mu-1}$ times
  what a single candidate would. Normalising so that a batch of one is free, the
  penalty is $q\,(k^{\mu-1}-1)$.

Adding them up:

$$C(k) \;=\; \frac{A}{k} \;+\; c \;+\; q\,\bigl(k^{\mu-1}-1\bigr), \qquad k>0 .$$

The exponent $\mu$ is the **multiplication exponent** of your arithmetic library.
Schoolbook long multiplication has $\mu = 2$. Karatsuba's algorithm has
$\mu = \log_2 3 \approx 1.585$. Toom–Cook sits lower still, and FFT-based
multiplication is essentially $\mu = 1$ up to logarithms. In the idealised model
where you count *operations* rather than *machine words* — pretending that
multiplying two numbers costs one tick regardless of their size — you also get
$\mu = 1$.

The whole story is a fight between the falling term $A/k$ and the rising term
$q\,k^{\mu-1}$. And now the exponent $\mu$ decides the outcome.

## The root law

Here is the central result.

> **The Root Law.** Let $A>0$, $q>0$ and $\mu>1$. Then over all positive batch
> sizes, $C$ attains its minimum at exactly one point,
> $$k^{*} \;=\; \left(\frac{A}{(\mu-1)\,q}\right)^{1/\mu},$$
> and the minimum value is
> $$C(k^{*}) \;=\; c - q + \mu\,(\mu-1)^{\frac{1-\mu}{\mu}}\,A^{\frac{\mu-1}{\mu}}\,q^{\frac{1}{\mu}} .$$
> Every other batch size is strictly worse.

For the schoolbook case $\mu = 2$ this collapses to the familiar
$k^{*} = \sqrt{A/q}$ with optimal cost $c - q + 2\sqrt{Aq}$ — the *square-root law*
of the title, the same shape as the economic order quantity of inventory theory and
the optimal block size in a hundred other amortisation problems. The root law says
that the square root was never fundamental: it was the fingerprint of schoolbook
arithmetic. In general the optimum is a $\mu$-th root.

You could prove this with calculus. Differentiate, set to zero, check the second
derivative. But the cleaner proof — and the one that generalises — uses no
derivatives at all. It rests on a single inequality.

**Bernoulli's inequality, in the right clothes.** For $u \ge 0$ and $\mu \ge 1$,
$$\mu\,u \;\le\; u^{\mu} + (\mu - 1),$$
with equality only at $u = 1$ when $\mu > 1$. Divide through by $u$ and rearrange:
$$\mu \;\le\; \frac{\mu-1}{u} + u^{\mu-1}.$$
That right-hand side is exactly the cost curve in disguise. So the inequality
*is* the theorem, once you choose the right units.

**The balance principle.** Suppose some batch size $t>0$ makes the amortised setup
exactly $(\mu-1)$ times the marginal penalty — in symbols, $A = q(\mu-1)t^{\mu}$.
Substituting $k = \theta t$ and factoring, the variable part of the cost becomes
$$q\,t^{\mu-1}\left(\frac{\mu-1}{\theta} + \theta^{\mu-1}\right),$$
and the inequality above says the bracket is at least $\mu$, with equality only at
$\theta=1$. Hence $t$ is the unique global minimiser. Solving
$A = q(\mu-1)t^{\mu}$ for $t$ gives the root law. That is the entire proof: one
inequality, one change of variables.

The balance condition deserves a moment. At the optimum, *the setup share of the
cost is exactly $(\mu-1)$ times the multiplication share*. For $\mu=2$, setup and
penalty are equal — the classical "balance the two terms" heuristic, now a theorem.
As $\mu$ falls towards $1$, the factor $\mu-1$ collapses: the optimum wants the
setup share to be vanishingly small compared to the penalty, which it can only
achieve by taking the batch enormous. That is the first hint at what happens in the
flat model.

## Bigger is always better — in the flat model

Put $\mu=1$ and the penalty term disappears identically: $C(k) = A/k + c$. This is
strictly decreasing. Every batch size is beaten by a larger one; there is no
optimum, no crossover, no reversal. Batching just keeps winning.

That is the resolution of the original puzzle. The measured reversal is not a
property of batching. It is a property of the *arithmetic* underneath the batching.
Change the multiplication algorithm and the reversal moves; idealise the
multiplication to a flat cost and the reversal disappears altogether. Concretely,
if you fix the setup and penalty and let the exponent slide down toward $1$, the
optimal batch runs off to infinity: whenever $\mu - 1 \le A/(qM^{2})$ (and
$\mu \le 2$, $M \ge 1$), the optimum already exceeds $M$. So the flat model's
"no optimum" is the continuous limit of the root law, not a separate phenomenon.

And in between, the optimum is **antitone in $\mu$**: lowering the multiplication
exponent never decreases the optimal batch. Faster multiplication does not merely
make batching cheaper — it makes *bigger* batching optimal. With $A = 1000$ and
$q = 1/1000$, the schoolbook optimum is exactly $1000$ candidates; at $\mu = 3/2$ it
jumps to $2\,000\,000^{2/3} \approx 15\,874$.

## The crossover is a root too

The practitioner's question is usually not "what is the optimal batch?" but
"should I batch at all?". Compare batching a pool of $k$ candidates against testing
them individually at a solo cost $s_1$ each. Per candidate, the batch costs
$q(k^{\mu-1}-1) + c_1$. Batching wins precisely when this is at most $s_1$, i.e.
$$k \;\le\; M^{*}(\mu) \;=\; \left(1 + \frac{s_1-c_1}{q}\right)^{\!1/(\mu-1)} .$$

At $\mu = 2$ this is the linear formula $M^{*} = 1 + (s_1-c_1)/q$ — exactly the
crossover measured in the schoolbook word model, and the reason the calibrated
value $1715$ looked like a plain ratio. But the linearity was an accident of
$\mu=2$. In general the crossover is a $1/(\mu-1)$-th **root** of the same
setup-to-penalty ratio, and lowering $\mu$ below $2$ can only push it out:
$M^{*}(\mu) \ge M^{*}(2)$ for all $1 < \mu \le 2$. Calibrated to the measured
$1715$: at $\mu = 3/2$ the crossover is $1715^{2} = 2\,941\,225$ candidates — three
orders of magnitude further out. As $\mu \downarrow 1$ it diverges: in the flat
model there is no crossover at any pool size, which is exactly what measurements up
to $k=512$ reported.

## One curve, in disguise

Here is the most satisfying structural fact. Measure the batch not in candidates
but in *multiples of the optimum*: write $k = \theta k^{*}$. Then

$$C(\theta k^{*}) \;=\; (c-q) \;+\; q\,(k^{*})^{\mu-1}\cdot S_{\mu}(\theta),
\qquad S_{\mu}(\theta) = \frac{\mu-1}{\theta} + \theta^{\mu-1}.$$

Everything about the problem — the setup $A$, the penalty $q$ — has been absorbed
into a vertical scale. The *shape* of the curve depends on the single number $\mu$.
All batching cost curves with the same multiplication exponent are the same curve,
stretched. And $S_{\mu}(1) = \mu$: the minimum of the shape is its own exponent.

This collapse turns a family of engineering measurements into a single object, and
it makes the next result meaningful.

## The optimum is a plateau, not a spike

How much does it cost to get the batch size wrong? In shape units, exactly:

$$S_{\mu}(\theta) - \mu \;\le\; \frac{(\mu-1)(\theta-1)^{2}}{\theta}
\qquad (1 < \mu \le 2,\ \theta>0).$$

The excess is **second order** in the sizing error. Missing the optimum by $20\%$
($\theta = 1.2$) costs at most $(\mu-1)\cdot 0.0333$ in shape units — against a
minimum of $\mu$, a relative overhead well under one percent for schoolbook
arithmetic. Even a factor of two ($\theta = 2$) costs at most $(\mu-1)/2$.

Two consequences for anyone tuning a real system. First, you do not need to find
$k^{*}$ precisely; anything within a factor of two is essentially free. Second, the
penalty is proportional to $\mu - 1$, so on faster arithmetic the plateau is even
flatter. This is why measured crossovers are broad, mushy regions rather than sharp
spikes — and why different machines report wildly different "optimal" batch sizes
while all running within a hair of optimal.

## Convex — but in the wrong variable

There is a subtlety here that only shows up below the quadratic model. Is the cost
function convex? For $\mu = 2$, yes. For $\mu < 2$, **no** — and there is a concrete
counterexample: take $\mu = 3/2$, $A = q = 1$, $c=0$, and batch sizes $4$ and $100$.
The average of the two costs is strictly *less* than the cost at their midpoint
$52$. A convex function cannot do that.

What *is* true, for every $\mu$, is that the cost is **multiplicatively convex**:
convex along geometric interpolations of the batch size. If
$k = k_1^{w} k_2^{1-w}$ with $0 \le w \le 1$, then
$$C(k) \;\le\; w\,C(k_1) + (1-w)\,C(k_2).$$
In other words, the cost is a convex function of $\log k$, not of $k$.

This is not a technicality; it is the *reason* the answer is a root. Multiplicative
convexity says the natural coordinate on batch sizes is logarithmic — and in
logarithmic coordinates, minimising a sum of two exponentials in $\log k$ gives a
weighted geometric mean of the parameters. A root of $A/q$, not a ratio. The same
structure explains the scaling laws: multiply the setup by $\lambda$ and the optimum
scales by $\lambda^{1/\mu}$; multiply the penalty by $\lambda$ and it scales by
$\lambda^{-1/\mu}$; multiply *both* and the optimum does not move at all, while the
optimal cost simply scales by $\lambda$. Library-level constant factors — the
difference between a tuned GMP and a naive implementation — **relocate** the
optimum but can never abolish it.

## What integer should I actually use?

A real batch size is a positive integer. Does the real-valued $k^{*}$ tell you
anything about the discrete optimum? It might, a priori, not: minimising a function
over the integers can land far from its real minimiser if the function wobbles.

It does not wobble. The cost is **strictly unimodal**: strictly decreasing on
$(0, k^{*}]$ and strictly increasing on $[k^{*}, \infty)$. Hence:

> **Discrete optimum.** For every integer $n \ge 1$, the cost at $n$ is at least the
> smaller of the costs at $\lfloor k^{*}\rfloor$ and $\lceil k^{*}\rceil$. The best
> integer batch is one of the two neighbours of the real optimum.

(The floor is clamped at $1$ for the degenerate case $k^{*}<1$, where the smallest
admissible batch wins.) The proof again avoids calculus, via a *balance-shift*
trick: to show the cost drops as you move up toward $k^{*}$, compare with an
auxiliary problem whose setup $A' = q(\mu-1)k_2^{\mu}$ is chosen so that its optimum
sits exactly at the larger point $k_2$. The balance principle handles the auxiliary
problem, and the difference between the two cost functions is $(A-A')/k$, which is
itself decreasing — so the strict inequality transfers. Unimodality also means that
a binary or ternary search over batch sizes is guaranteed to converge to the
optimum: no local minima to trap it.

## What the story adds up to

Start with an engineering mystery — why does batching stop paying off? — and the
answer turns out to be a clean piece of mathematics with a moral. The reversal is
real, but it belongs to the *multiplication algorithm*, not to batching. The
square-root rule that practitioners have used for decades is the $\mu = 2$ shadow of
a general root law. The optimum always exists and is always unique when $\mu>1$; it
is always a root of the setup-to-penalty ratio; it always sits on a flat plateau; it
always has an integer neighbour that is best; and it always dissolves, gracefully
and continuously, as the arithmetic approaches linear cost.

Two things this does *not* settle. First, real memory hierarchies make $\mu$ an
effective *step function* of the batch size: once the working set spills out of L2
cache, the exponent jumps. The universal collapse gives a sharp diagnostic here —
a single-tier model has exactly one optimum, so any *second* local minimum in a
measured curve is direct evidence of a cache-tier boundary. Second, FFT-based
multiplication costs $k \log k \log\log k$, which is not a pure power: its "local
exponent" is slowly varying, so it falls just outside the pure root law. The balance
principle behind the proof, though, never used the exact form $k^{\mu-1}$ — only
that the penalty is multiplicatively convex and the amortised setup is
multiplicatively convex with the opposite slope. Extending the law to arbitrary
regularly varying penalty profiles $P(k)$, with the optimum wherever the elasticity
$kP'(k)/P(k)$ crosses $1$, is the natural next theorem.

Until then: batch, but batch to a root.
