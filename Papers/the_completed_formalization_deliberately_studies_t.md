# Two Laws of Delayed Generalization

### A guided tour of why learning systems wait, and exactly how long

---

## 1. The flat line

Train a small network on modular arithmetic. Within a few hundred steps it has memorized
the training set perfectly — nothing left to learn there. And on held-out data it stays at
chance. Not for a hundred more steps: for a hundred *thousand* more. Then, over a short
window, the test accuracy climbs almost vertically to near-perfect.

The phenomenon is called **grokking**, and it raises two separate questions.

- **Why is the transition sharp?** Why doesn't generalization creep in gradually?
- **How long is the wait?** What sets the length of the flat stretch, and what makes it
  explode?

This page answers both, in models small enough that every claim is a theorem. The punchline
is quantitative: the wait obeys exactly **two** laws, with two exact constants — $1/\lambda_c$
and $\pi$ — and near a critical point one of them always wins.

---

## 2. The smallest thing that can grok

Strip away the transformers. Take a two-layer rectifier network of hidden width $m$:

$$N(x) \;=\; c \;+\; \sum_{j=1}^{m} a_j \, \mathrm{ReLU}\!\big(\langle W_j, x\rangle + b_j\big),
\qquad \mathrm{ReLU}(u) = \max(u,0),$$

and instead of a fixed input, feed it a **ray**: pick a direction $p$ and watch
$t \mapsto N(tp)$ as $t$ grows. Writing $g_j = \langle W_j, p\rangle$ for the *signal* that
direction $p$ delivers to hidden unit $j$, this is

$$R(t) \;=\; c + \sum_{j=1}^m a_j\,\mathrm{ReLU}\big(t\,g_j + b_j\big).$$

Suppose $c < 0$ — the network's default answer is "no". Suppose the hidden biases satisfy
$b_j \le 0$, so units start silent, and the output weights satisfy $a_j \ge 0$, so no unit can
argue against another. Then $R$ is continuous, non-decreasing, starts negative, and eventually
goes positive.

> **Sharp Threshold Theorem.** A monotone continuous $f$ with $f(0) < 0$ that is positive
> somewhere has a **unique** $\tau \ge 0$ with $f \le 0$ on $(-\infty,\tau]$ and $f > 0$ on
> $(\tau,\infty)$.

<details>
<summary><b>Click to reveal the proof (three lines)</b></summary>

Let $F = \{t : f(t) \le 0\}$. Monotonicity makes $F$ a down-set containing $0$ and bounded
above by any $T$ with $f(T) > 0$, so $\tau = \sup F$ exists and is $\ge 0$. For $t < \tau$ pick
$u \in F$ with $t < u$; then $f(t) \le f(u) \le 0$, and continuity gives $f(\tau) \le 0$. For
$t > \tau$, $t \notin F$, so $f(t) > 0$. Uniqueness: two thresholds $\tau < \tau'$ would force
$f(\tau')$ to be both $> 0$ and $\le 0$. $\blacksquare$
</details>

That is one output. Real generalization is a *worst case* over a test set. Give $n$ labelled
points $p_k$ with labels $y_k \in \{\pm 1\}$, define the signed scores $s_k(t) = y_k R_{p_k}(t)$
and the margin $M(t) = \min_k s_k(t)$. A finite minimum of monotone continuous functions is
monotone and continuous, so the margin inherits a sharp threshold too.

> **Delayed Margin Positivity.** Under the sign conditions above, with negative-class points
> leaving every hidden unit silent and positive-class points exciting at least one, there is a
> single $\tau \ge 0$ such that the *whole* test set is misclassified-or-tied for $t \le \tau$
> and the *whole* test set is classified correctly with strictly positive margin for $t > \tau$.

Worst-case aggregation does not smear the transition. The entire test set flips at one instant.

---

## 3. Delay = prejudice ÷ evidence

We can compute $\tau$. Let $S = \sum_j a_j g_j$ be the **total signal**. Because ReLU is
dominated by its own linearization when biases are non-positive, $R(t) \le c + tS$, so nothing
can be positive before $t = |c|/S$. Conversely a single active unit $j_0$ forces positivity by
$(|c|/a_{j_0} - b_{j_0})/g_{j_0}$. Hence the **delay sandwich**

$$\frac{|c|}{\sum_j a_j g_j} \;\le\; \tau \;\le\; \frac{|c|/a_{j_0} - b_{j_0}}{g_{j_0}},$$

and when the hidden biases vanish it collapses to the exact identity

$$\boxed{\;\tau = \frac{|c|}{S}\;}$$

Read it: **delay equals prejudice divided by evidence.** The output bias $|c|$ is how much the
network insists on "no"; the total signal $S$ is how fast the data argues otherwise.

An immediate corollary is a **width law**. With $m$ identical units of output weight $A$ and
signal $g$, $\tau(m) = |c|/(mAg)$, so $m\,\tau(m)$ is a constant. And it survives randomness:
if the units are i.i.d. with integrable per-unit signal $Y$ of positive mean, then by the strong
law of large numbers

$$m\,\tau_m \;\longrightarrow\; \frac{|c|}{\mathbb{E}[Y]}\qquad\text{almost surely.}$$

Wider networks grok sooner, at exactly rate $1/m$, with a constant you can name.

{{algorithm:0}}

---

## 4. Can a network un-grok? Play with it

Once the transition happens, is it permanent? With non-negative output weights, yes — and the
reason is geometric rather than dynamical. Each $t \mapsto \mathrm{ReLU}(tg_j + b_j)$ is a
maximum of two affine functions, hence **convex**; a non-negative combination of convex
functions is convex; and a sublevel set of a convex function in one variable is an **interval**.
So the failure set $\{t : R(t) \le 0\}$ is an interval: you fail, then you succeed, and never
fail again. Call it **tropical rigidity** — it is exactly the piecewise-linear, max-plus
structure of a positively-weighted rectifier layer that forbids relapse.

Drop the sign condition and it shatters. In the widget below, start with the *positive preset*
and confirm that the shaded failure region is a single block no matter how you move the sliders.
Then hit *hat*: one output weight becomes $-2$, and the network groks at $t = 1/2$ and
**un-groks** at $t = 3/2$. Then hit *comb*: the tents repeat, and so do the relapses.

{{interactive_demo:2}}

<details>
<summary><b>The precise statements</b></summary>

The width-3 **hat network**
$$H(t) = -\tfrac12 + \mathrm{ReLU}(t) - 2\,\mathrm{ReLU}(t-1) + \mathrm{ReLU}(t-2)$$
is a triangular tent of height $1$ peaking at $t = 1$, and its failure set is *exactly*
$(-\infty,\tfrac12] \cup [\tfrac32,\infty)$ — provably not convex.

Gluing $k$ tents side by side, tent $i$ supported on $[2i, 2i+2]$ with peak $1$ at $2i+1$, and
keeping the output bias $-\tfrac12$, produces an honest two-layer ReLU network of width $3k$
that fails at every even integer $0, 2, \dots, 2k$ and succeeds at every odd integer below $2k$.
Its failure set therefore has **at least $k+1$ connected components**: the number of relapses
grows *linearly in the width*. Sign structure in the output layer buys the ability to
understand, forget, and re-understand, arbitrarily many times.
</details>

---

## 5. Where the wait actually comes from

So far the delay was baked into the geometry. In a real experiment it is produced by
optimization. Here is the smallest honest model.

Give a single weight $w$ the ridge loss $L_\lambda(w) = \frac{\lambda}{2}w^2 - s\,w$, where $s>0$
is the data drive and $\lambda>0$ is weight decay. Gradient flow $\dot w = s - \lambda w$ has the
exact solution

$$w(t) = \frac{s}{\lambda} + \Big(w_0 - \frac{s}{\lambda}\Big)e^{-\lambda t},$$

which climbs strictly toward the regularized optimum $s/\lambda$ and never reaches it. A
downstream rectifier fires only once $w$ exceeds an activation threshold $\theta$, so

$$\tau(\lambda) = \frac{1}{\lambda}\,\log\!\frac{s/\lambda - w_0}{\,s/\lambda - \theta\,}.$$

Now stare at the denominator. Set

$$\mu(\lambda) = \frac{s}{\lambda} - \theta, \qquad \lambda_c = \frac{s}{\theta}.$$

The threshold gets crossed **if and only if** $\mu(\lambda) > 0$, i.e. iff $\lambda < \lambda_c$.
Too much regularization and the network never groks — not late, *never*. This is a genuine phase
transition in a hyperparameter, and $\mu$ is its order parameter.

Turn the weight-decay dial yourself. Watch the plateau lengthen, then watch the transition
vanish entirely as you cross $\lambda_c$.

{{interactive_demo:0}}

{{algorithm:1}}

---

## 6. The other way to be slow: ghosts

There is a second, entirely different mechanism, and it is the classical picture of a
**saddle-node bifurcation**. Consider

$$\dot x = \mu - x^2.$$

For $\mu > 0$ there are two equilibria $\pm\sqrt\mu$: the upper is stable
($\partial_x = -2\sqrt\mu < 0$), the lower unstable ($+2\sqrt\mu > 0$). At $\mu = 0$ they collide
and annihilate. Below, there is nothing left to rest on — and yet the flow *crawls*, squeezing
through the ghost of the vanished pair.

The Riccati equation is solved exactly by $x(t) = -k\tan(kt)$ with $k = \sqrt{-\mu}$, and the
time to fall from $+A$ to $-A$ is

$$T(k,A) = \frac{2\arctan(A/k)}{k}.$$

Drag $\mu$ across zero in the widget and watch a delay appear from an absence. Then drag the
observation level $A$ across two orders of magnitude and watch the normalized product barely
move — that level-independence is the signature of a genuine bottleneck.

{{interactive_demo:1}}

<details>
<summary><b>The full local theory: nondegeneracy, stability, energy, robustness</b></summary>

**Nondegeneracy.** At $(\mu,x) = (0,0)$ the field $f_\mu(x) = \mu - x^2$ satisfies
$f_0(0) = 0$, $\partial_x f_0(0) = 0$, $\partial_\mu f = 1 \ne 0$, $\partial_{xx} f = -2 \ne 0$ —
precisely the classical saddle-node conditions.

**Nonlinear (not merely linear) stability.** Along any solution,
$\frac{d}{dt}(x-\sqrt\mu)^2 = -2(x-\sqrt\mu)^2(x+\sqrt\mu)$, strictly negative whenever
$x > -\sqrt\mu$ and $x \ne \sqrt\mu$; mirroring gives
$\frac{d}{dt}(x+\sqrt\mu)^2 = -2(x+\sqrt\mu)^2(x-\sqrt\mu) > 0$ below the stable branch.

**Energy.** Both branches are critical points of the cubic $V_\mu(x) = \frac{x^3}{3} - \mu x$,
whose negative gradient is the flow. The exact factorization
$V_\mu(x) - V_\mu(\sqrt\mu) = \frac13 (x-\sqrt\mu)^2(x+2\sqrt\mu)$ shows $+\sqrt\mu$ is a strict
local minimum; mirrored, $-\sqrt\mu$ is a strict local maximum. For $\mu < 0$, $V_\mu$ has no
critical point at all.

**Robustness.** For any continuous $g$ with $|g(x) - (\mu - x^2)| \le \varepsilon$ everywhere:
if $0 < \varepsilon < \mu$ then $g$ still has two zeros, one negative and one positive; every
zero satisfies $|x^2 - \mu| \le \varepsilon$, so it sits near a true branch; and if
$\mu < -\varepsilon$ then $g$ has no zero. The whole bifurcation diagram is stable under uniform
perturbations, so none of this is an artifact of the exact quadratic.
</details>

---

## 7. The main event: two exact constants

Both laws can be pinned down to their leading constants. This is the heart of the matter.

> **Law I (relaxation).** As $\lambda \uparrow \lambda_c$,
> $$\frac{\tau(\lambda)}{\log(1/\mu(\lambda))} \;\longrightarrow\; \frac{\theta}{s} = \frac{1}{\lambda_c},
> \qquad\text{i.e.}\qquad \tau \sim \frac{1}{\lambda_c}\log\frac{1}{\mu}.$$

> **Law II (bottleneck).** For every observation level $A > 0$,
> $$\sqrt{|\mu|}\;T\big(\sqrt{|\mu|}, A\big) \;\longrightarrow\; \pi,
> \qquad\text{i.e.}\qquad T \sim \pi\,|\mu|^{-1/2}.$$

<details>
<summary><b>Why 1/λ<sub>c</sub>?  A separation of scales.</b></summary>

Split the logarithm:
$$\tau(\lambda) = \frac{1}{\lambda}\Big[\log\big(s/\lambda - w_0\big) + \log\big(1/\mu\big)\Big].$$
As $\lambda \uparrow \lambda_c$ we have $s/\lambda \to \theta$, so the first term converges to the
*finite* number $\log(\theta - w_0)$ while the second diverges. Dividing by $\log(1/\mu)$ kills
the bounded part and leaves $1/\lambda \to 1/\lambda_c$. The delay is a bounded contribution
(how far the initial weight starts from the threshold) plus a divergent one (how close the
regularized optimum is to the threshold); only the second survives normalization.
</details>

<details>
<summary><b>Why exactly π, and why doesn't A appear?</b></summary>

Multiply through: $k\,T(k,A) = 2\arctan(A/k)$ — an *exact identity*, not an approximation. As
$k \downarrow 0$ with $A$ fixed, $A/k \to \infty$ and $\arctan \to \pi/2$, so the product tends to
$\pi$. The level $A$ has vanished from the limit because asymptotically **all** of the time is
spent in an arbitrarily small neighbourhood of the ghost equilibrium; widening the observation
window adds only $O(1)$. Level-independence is what distinguishes a bottleneck from an ordinary
transit.
</details>

Two exponents, two constants:

| Mechanism | Delay law | Sharp constant | Log–log signature |
|---|---|---|---|
| Threshold relaxation | $\tau \sim \lambda_c^{-1}\log(1/\mu)$ | $1/\lambda_c = \theta/s$ | slope $\approx 0$, curved |
| Saddle-node bottleneck | $T \sim \pi\,\mu^{-1/2}$ | $\pi$ | slope exactly $-1/2$ |

{{visualization:0}}

---

## 8. Who wins?

If a system has both mechanisms available, which delay do you actually observe? The answer is
decisive. Because $\sqrt\mu\,\log(1/\mu) \to 0$ as $\mu \downarrow 0$ — the logarithm is slower
than *every* inverse power —

$$\frac{K\log(D/\mu)}{\pi/(2\sqrt\mu)} \;\longrightarrow\; 0 \qquad(\mu \downarrow 0)$$

for every $K$ and every $D>0$; and quantitatively, for any $K, D, A > 0$ there is a whole
neighbourhood of criticality on which $K\log(D/\mu) < T(\sqrt\mu, A)$.

**The bottleneck always wins, eventually.** No matter how large you make the constant in front
of the logarithm — try it in the widget above by cranking $K$ — the crossing point merely moves;
the verdict does not change.

That is what makes the theory testable. Sweep the control parameter in a grokking experiment,
plot the delay against the distance to criticality on log–log axes, and read the slope: $-1/2$
means a saddle-node bottleneck; a curved line with no power-law slope means simple threshold
relaxation. Because both constants are known, the identification is *calibrated*, not merely
qualitative.

{{algorithm:2}}

{{demo:1}}

---

## 9. Grokking as a window

One last piece makes it concrete. Take the tiny network $N(t) = -1 + \mathrm{ReLU}(tp)$ with two
training points of signals $2$ and $-1$ and a test point of weak signal $1/2$. The training set
is perfectly classified once $t > 1/2$; the test point only once $t > 2$. The set of times where
training error is already zero but test error is still positive is *exactly* the interval
$(1/2, 2]$ — sharp on both sides.

And the window has no universal bound. A single unit with signal strength $\sigma$ has delay
exactly $1/\sigma$; fixing the training signal and shrinking the test signal makes the ratio
(test delay)/(train delay) exceed any prescribed $R$, while both transitions stay sharp. **The
gap between memorizing and understanding is set purely by how weakly the test distribution
excites the features the training data built.**

Nor is any of it fragile. If a perturbed trajectory stays uniformly within $\varepsilon$ of a
clean one that is non-positive before $\tau$ and grows at rate at least $\kappa$ after it, then
the perturbed trajectory is still $\le \varepsilon$ before $\tau$ and strictly positive after
$\tau + \varepsilon/\kappa$. That displacement bound is *attained exactly*, by the constant
perturbation $-\varepsilon$. Noise delays grokking by a computable amount; it never abolishes it.

{{visualization:1}}

---

## 10. Run everything

Every claim above is checked numerically in the following self-contained program: the sharp
thresholds, the sandwich, the exact $|c|/S$ delay, the $1/m$ width law and its almost-sure
version, tropical rigidity and the comb's relapses, the exact crossing law and criticality test,
both sharp constants, the dominance of the bottleneck, the $(1/2, 2]$ window, the unbounded
grokking ratio, and the exactness of the $\varepsilon/\kappa$ displacement.

{{demo:0}}

---

## 11. What the flat line was really telling you

Underneath the plateau, something is always moving — smoothly, monotonically. A weight climbing
an exponential toward its regularized optimum. A state crawling through the remnant of a pair of
equilibria that no longer exist. The output looks frozen because a rectifier is clipping the
news, or because a margin is still on the wrong side of zero. Understanding is not arriving
suddenly; it is arriving continuously, and only *becoming visible* suddenly.

The practical edge: if delay is prejudice over evidence, then to grok sooner you widen the
network, strengthen the features, or weaken the default answer — with returns of exactly $1/m$,
exactly $1/S$, exactly $|c|$. If the delay diverges as you raise regularization, there is a real
critical value beyond which the transition never happens. And if you want to know *which* kind of
slowness you are fighting, measure the exponent.

Further reading on the surrounding ideas:
[grokking](https://en.wikipedia.org/wiki/Grokking_(machine_learning)),
[saddle-node bifurcation](https://en.wikipedia.org/wiki/Saddle-node_bifurcation),
[Riccati equation](https://en.wikipedia.org/wiki/Riccati_equation),
[rectifier (neural networks)](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)),
[tropical geometry](https://en.wikipedia.org/wiki/Tropical_geometry),
[law of large numbers](https://en.wikipedia.org/wiki/Law_of_large_numbers).
