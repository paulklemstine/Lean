# The Arithmetic of Patience: Why Neural Networks Suddenly Understand

## A machine that fails, fails, fails — and then, one day, doesn't

In 2021, researchers training small neural networks on modular arithmetic noticed
something that looked like a bug. The network learned its training examples
almost immediately — perfect score, nothing left to memorize. And then, on data
it had never seen, it stayed *stubbornly, uniformly wrong*. Not for a few more
steps. For a hundred thousand more steps. The loss curve on held-out data sat
flat, like an EKG on a patient who had already been declared dead.

And then it moved. Sharply, almost vertically, the test accuracy climbed from
chance to essentially perfect. The network had, in the researchers' word,
*grokked* — a term borrowed from Heinlein meaning to understand something so
completely that you become it.

The phenomenon is now called **grokking**, and it has an unsettling quality. It
suggests that a learning system can hold, invisibly, a nearly-complete
understanding, and that the moment of visible comprehension is not the moment
understanding arrives but the moment it *crosses a line*. This article is about
that line: where it comes from, why the wait before it can be so long, and — the
central result we will build up to — the fact that the length of the wait obeys
exactly **two** laws, with two exact constants, and that when both are available
one of them always wins.

## The simplest thing that can grok

Strip away the transformers and the modular arithmetic. What is the minimum
apparatus needed to reproduce a sudden transition after a long flat wait?

Take a two-layer network with rectified-linear units. It has hidden width $m$,
takes inputs $x \in \mathbb{R}^d$, and computes
$$N(x) \;=\; c \;+\; \sum_{j=1}^{m} a_j \, \mathrm{ReLU}\!\big(\langle W_j, x\rangle + b_j\big),
\qquad \mathrm{ReLU}(u) = \max(u,0).$$
Here $W_j \in \mathbb{R}^d$ is the $j$-th hidden weight vector, $b_j$ its bias,
$a_j$ its output weight, and $c$ the output bias.

Now do the thing that makes the phenomenon visible: don't feed the network a
fixed input, feed it a *ramp*. Pick a direction $p \in \mathbb{R}^d$ and watch
$t \mapsto N(tp)$ as the ramp parameter $t$ increases from zero. Writing
$g_j = \langle W_j, p \rangle$ for the **signal** that direction $p$ delivers to
hidden unit $j$, the ramped output is
$$N(tp) \;=\; c \;+\; \sum_{j=1}^m a_j\,\mathrm{ReLU}\big(t\,g_j + b_j\big).$$

Suppose the output bias is negative, $c<0$ — the network's default answer is
"no". Suppose the hidden biases are non-positive, $b_j \le 0$, so units start
silent, and the output weights are non-negative, $a_j \ge 0$, so no unit can
argue against another. Then $t \mapsto N(tp)$ is a non-decreasing continuous
function that starts at $c < 0$. If even one unit eventually fires with positive
weight, the function eventually goes positive.

Here is the first structural fact, and it is more than a triviality:

> **Sharp Threshold Theorem.** *A monotone continuous function $f$ with $f(0)<0$
> that is positive somewhere has a unique number $\tau \ge 0$ with $f(t) \le 0$
> for all $t \le \tau$ and $f(t) > 0$ for all $t > \tau$.*

The transition happens **once**, at a single instant, with no dithering. Take
$\tau = \sup\{t : f(t) \le 0\}$; monotonicity confines the failure set to a
half-line and continuity puts $f(\tau) \le 0$ exactly at the endpoint.
Uniqueness is immediate: two such thresholds $\tau < \tau'$ would force $f$ to be
both $>0$ and $\le 0$ at any point strictly between them.

That is a statement about one output. Real generalization is about the *worst*
case over a whole test set. So consider $n$ labelled test points $p_1,\dots,p_n$
with labels $y_k \in \{\pm 1\}$, and define each **signed score**
$s_k(t) = y_k\,N(t p_k)$ — positive exactly when point $k$ is classified
correctly. The **margin** is the worst of them,
$$M(t) \;=\; \min_{1\le k \le n} s_k(t).$$
A minimum of finitely many monotone continuous functions is monotone and
continuous, so:

> **Delayed Margin Positivity.** *For a two-layer ReLU network with $c<0$,
> $b_j \le 0$, $a_j \ge 0$, presented with a two-class test set through a ramp,
> where negative-class points leave every hidden unit silent and positive-class
> points excite at least one unit, there is a single threshold $\tau \ge 0$ such
> that the whole test set is misclassified-or-tied for $t \le \tau$, and the
> entire test set is classified correctly, with strictly positive margin, for
> every $t > \tau$.*

This is grokking in miniature: a long flat stretch of failure, then a clean,
simultaneous, irreversible success across the board.

## How long is the wait?

We can compute $\tau$, and the answer is illuminating. Let $S = \sum_j a_j g_j$
be the **total signal** the direction $p$ delivers. Because ReLU is dominated by
its own linearization when biases are non-positive, $N(tp) \le c + tS$, so the
output cannot be positive before $t = |c|/S$. In the other direction, one active
unit $j_0$ with $a_{j_0}, g_{j_0} > 0$ already forces the output positive by time
$(|c|/a_{j_0} - b_{j_0})/g_{j_0}$. Hence the **delay sandwich**
$$\frac{|c|}{\sum_j a_j g_j} \;\le\; \tau \;\le\; \frac{|c|/a_{j_0} - b_{j_0}}{g_{j_0}}.$$
When the hidden biases vanish, $b_j = 0$, the two sides collapse and the delay is
*exactly*
$$\boxed{\;\tau = \frac{|c|}{\sum_j a_j g_j}\;}$$

Read that formula: **delay = prejudice divided by evidence**. The output bias
$|c|$ is how much the network insists on saying "no"; the total signal $S$ is how
fast the data argues otherwise. Make the bias twice as strong, wait twice as
long. Double the evidence, halve the wait.

An immediate consequence is a **width law**. Put $m$ identical hidden units, each
with output weight $A>0$ and signal $g>0$, into the network. Then
$S = mAg$ and
$$\tau(m) = \frac{|c|}{m\,A\,g}, \qquad\text{so}\qquad m\,\tau(m) = \frac{|c|}{Ag}
\ \text{ is independent of } m.$$
Delay is inversely proportional to width. The law survives randomness: if the
hidden units are drawn independently and identically with integrable signal
$Y$ of positive mean, then by the strong law of large numbers
$m^{-1}\sum_{j<m} Y_j \to \mathbb{E}[Y]$ almost surely, hence
$$m\,\tau_m \;\longrightarrow\; \frac{|c|}{\mathbb{E}[Y]}\qquad\text{almost surely.}$$
Wider networks grok sooner, and the improvement is exactly $1/m$, with a constant
you can name.

## Can a network un-grok?

Once the transition happens, is it permanent? With non-negative output weights,
yes — and for a beautiful reason. Each map $t \mapsto \mathrm{ReLU}(tg_j+b_j)$ is
convex (a maximum of two affine functions), a non-negative combination of convex
functions is convex, so $t \mapsto N(tp)$ is **convex**. A sublevel set of a
convex function is convex, so the *failure set* $\{t : N(tp) \le 0\}$ is an
interval. You fail, then you succeed, and you never fail again. Call this
**tropical rigidity**: it is exactly the piecewise-linear, max-plus structure of
ReLU networks that forbids relapse.

Remove the sign condition and rigidity dies spectacularly. Consider the width-3
"hat" network
$$H(t) = -\tfrac12 + \mathrm{ReLU}(t) - 2\,\mathrm{ReLU}(t-1) + \mathrm{ReLU}(t-2),$$
whose output is a triangular tent of height $1$ peaking at $t=1$. Its failure set
is *exactly* $(-\infty,\tfrac12] \cup [\tfrac32,\infty)$: the network groks at
$t=1/2$, holds understanding for one unit of ramp, and un-groks at $t=3/2$,
never to recover. That set is not convex, so the one negative output weight
$-2$ is doing real work.

Iterate the construction. Glue $k$ tents side by side along the ramp axis, each
supported on $[2i, 2i+2]$ with peak $1$ at $2i+1$, and keep the output bias
$-1/2$. The resulting **comb network** is an honest two-layer ReLU network of
width $3k$, it fails at every even integer $0,2,\dots,2k$ and succeeds at every
odd integer below $2k$. Its failure set therefore has at least $k+1$ connected
components. **The number of relapses can grow linearly in the width.** Sign
structure in the output layer buys you the ability to understand, forget,
re-understand — arbitrarily many times.

## Where the wait comes from: training, not fiat

So far the delay was built into the geometry. But in a real experiment the delay
is produced by *optimization*. Here is the smallest honest model of that.

Give a single weight $w$ the ridge-regularized loss
$$L_\lambda(w) = \frac{\lambda}{2}w^2 - s\,w,$$
where $s>0$ is the strength with which the data pushes the weight up and
$\lambda>0$ is weight decay pulling it back. Gradient flow
$\dot w = -L_\lambda'(w) = s - \lambda w$ has the exact solution
$$w(t) = \frac{s}{\lambda} + \Big(w_0 - \frac{s}{\lambda}\Big)e^{-\lambda t}.$$
The weight climbs, strictly and forever, toward the regularized optimum
$s/\lambda$, which it never reaches. The downstream unit fires only once
$w$ exceeds an activation threshold $\theta$. Solving gives the delay in closed
form:
$$\tau(\lambda) = \frac{1}{\lambda}\,
\log\!\frac{s/\lambda - w_0}{\,s/\lambda - \theta\,},$$
and the unit is *exactly* silent for $t \le \tau(\lambda)$ and strictly active
for every $t > \tau(\lambda)$.

Now stare at the denominator. Define
$$\mu(\lambda) = \frac{s}{\lambda} - \theta, \qquad
\lambda_c = \frac{s}{\theta}.$$
The threshold gets crossed at all **if and only if** $\mu(\lambda) > 0$, i.e. if
and only if $\lambda < \lambda_c$. Too much regularization and the network never
groks — not late, *never*. Just below $\lambda_c$, it groks, but the wait
blows up. This is a genuine phase transition in the regularization strength, and
$\mu$ is its order parameter.

## The two laws of waiting

We can now ask the quantitative question that organizes everything. As the
control parameter $\mu$ approaches its critical value $0$, how fast does the
delay diverge?

**Law I: logarithmic.** In the model above, as $\lambda \uparrow \lambda_c$,
$$\frac{\tau(\lambda)}{\log\big(1/\mu(\lambda)\big)} \;\longrightarrow\;
\frac{\theta}{s} = \frac{1}{\lambda_c},
\qquad\text{i.e.}\qquad
\tau(\lambda) \;\sim\; \frac{1}{\lambda_c}\,\log\frac{1}{\mu(\lambda)}.$$
The proof is a clean separation of scales: write
$\tau = \lambda^{-1}\big[\log(s/\lambda - w_0) + \log(1/\mu)\big]$; the first
logarithm converges to the finite number $\log(\theta - w_0)$ while the second
diverges, and $1/\lambda \to \theta/s$. So the divergence is entirely carried by
$\log(1/\mu)$, with leading constant exactly $1/\lambda_c$. Mercifully slow: to
double the wait you must square the closeness to criticality.

**Law II: inverse square root.** The second mechanism is qualitatively
different, and it is the classical picture of a *saddle-node bifurcation*.
Consider the normal form
$$\dot x = \mu - x^2.$$
For $\mu > 0$ there are two equilibria, $x = \pm\sqrt\mu$. The upper one is
stable: linearizing, $\partial_x(\mu - x^2) = -2\sqrt{\mu} < 0$, and nonlinearly,
the squared distance $(x-\sqrt\mu)^2$ strictly decreases along every solution
starting above $-\sqrt\mu$. The lower one is unstable, with
$+2\sqrt\mu > 0$ and $(x+\sqrt\mu)^2$ strictly increasing. At $\mu=0$ the two
collide and annihilate: the field satisfies
$f(0,0)=0$, $\partial_x f(0,0) = 0$, $\partial_\mu f = 1 \ne 0$,
$\partial_{xx} f = -2 \ne 0$ — precisely the classical saddle-node nondegeneracy
conditions. Both branches are critical points of a single cubic potential
$V_\mu(x) = x^3/3 - \mu x$: the stable branch is its local minimum, the unstable
branch its local maximum, and for $\mu<0$ the potential has no critical point at
all.

The whole picture is robust. Any continuous field $g$ with
$|g(x) - (\mu - x^2)| \le \varepsilon$ everywhere still has two zeros, one
negative and one positive, whenever $0 < \varepsilon < \mu$; every zero satisfies
$|x^2 - \mu| \le \varepsilon$, so it sits near a true branch; and for
$\mu < -\varepsilon$ it has no zero at all. The bifurcation diagram is not an
artifact of the exact algebra.

Now the delay. For $\mu = -k^2 < 0$ there is *no* equilibrium — but there is a
ghost. The Riccati equation is solved exactly by
$$x(t) = -k\tan(kt),$$
and the time it takes to fall from $+A$ down to $-A$ is
$$T(k,A) = \frac{2\arctan(A/k)}{k}.$$
The trajectory has nowhere to rest, yet it crawls: as $k \downarrow 0$,
$\arctan(A/k) \to \pi/2$ and so
$$k\,T(k,A) \;\longrightarrow\; \pi,
\qquad\text{i.e.}\qquad
T \;\sim\; \frac{\pi}{\sqrt{|\mu|}}.$$
Two things about this are remarkable. The exponent is $-1/2$, not logarithmic.
And the constant is exactly $\pi$ — **independent of the observation level $A$**.
Whether you watch the trajectory pass a wide window or a narrow one, essentially
all of the time is spent in the bottleneck itself, so the answer forgets where
you started.

## The dichotomy, and who wins

Two mechanisms, two exponents:
$$\tau_{\text{relax}} \sim \frac{1}{\lambda_c}\log\frac{1}{\mu}
\qquad\text{versus}\qquad
\tau_{\text{bottleneck}} \sim \frac{\pi}{\sqrt{\mu}}.$$
Their ratio settles the competition. Since $\sqrt{\mu}\,\log(1/\mu) \to 0$ as
$\mu \downarrow 0$,
$$\frac{K\log(D/\mu)}{\pi/(2\sqrt\mu)} \;\longrightarrow\; 0
\qquad (\mu \downarrow 0)$$
for every $K$ and every $D>0$. Quantitatively, for any constants $K, D, A > 0$
there is a neighbourhood of criticality on which $K\log(D/\mu) < T(\sqrt\mu, A)$.
**The bottleneck always wins, eventually.** A system that possesses both a
relaxation delay and a saddle-node bottleneck spends, close enough to
criticality, essentially all of its waiting inside the bottleneck; the
logarithmic term is asymptotically invisible.

This is the payoff, and it is testable. The two mechanisms leave *different
measurable fingerprints*. Sweep the weight decay in a grokking experiment, plot
the delay against the distance to the critical value on log–log axes, and the
slope tells you which mechanism you are looking at: a slope of $-1/2$ means a
saddle-node bottleneck, a logarithmic curve with no power-law slope means simple
threshold relaxation. The conjecture the mathematics suggests is that these are
the *only* two possibilities for a generic one-dimensional reduction: the two
codimension-one ways a smooth scalar system can be slow.

## Grokking as a window

One last piece makes the picture concrete. Take the tiny network
$N(t) = -1 + \mathrm{ReLU}(t\,p)$ and a dataset with two training points of
signals $2$ and $-1$ and one test point of weak signal $1/2$. The training set is
perfectly classified once $t > 1/2$; the test point only once $t > 2$. The set of
times where training error is already zero but test error is still positive is
*exactly* the interval $(1/2, 2]$ — a grokking window with sharp endpoints on
both sides.

And the window can be made arbitrarily wide. With signal strength $s$, a single
unit has delay exactly $1/s$; fixing the training signal and shrinking the test
signal makes the ratio (test delay)/(train delay) exceed any prescribed $R$,
while both delays remain finite and both transitions remain sharp. **The gap
between memorizing and understanding has no universal bound** — it is set purely
by how weakly the test distribution excites the features the training data
built.

Finally, none of this is fragile. If a perturbed trajectory stays uniformly
within $\varepsilon$ of a clean one that is non-positive before $\tau$ and grows
at rate at least $\kappa$ after it, the perturbed trajectory is still at most
$\varepsilon$ before $\tau$ and strictly positive after $\tau + \varepsilon/\kappa$.
The threshold moves by at most $\varepsilon/\kappa$ — and that bound is attained
exactly, by the constant perturbation $-\varepsilon$. Noise delays grokking; it
does not abolish it, and you can say by how much.

## What the flat line is really telling you

The picture that emerges is that the flat stretch on the test curve is not empty.
Underneath it, something is moving smoothly and monotonically — a weight climbing
an exponential toward its regularized optimum, or a state crawling through the
ghost of a pair of equilibria that no longer exist. The output looks frozen
because a rectifier is clipping the news, or because a margin is still on the
wrong side of zero. Understanding is not arriving suddenly; it is arriving
continuously, and only *becoming visible* suddenly.

That reframing has a practical edge. If delay equals prejudice over evidence,
then to grok sooner you widen the network, strengthen the features, or weaken the
default answer, and the returns are exactly $1/m$, exactly $1/S$, exactly
$|c|$. If your delay diverges as you turn up regularization, there is a genuine
critical value beyond which the transition never happens. And if you want to know
*which* kind of slowness you are fighting, measure the exponent: $-1/2$ or
$\log$. Two laws, two constants — $1/\lambda_c$ and $\pi$ — and, near
criticality, one clear winner.
