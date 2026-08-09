# The Median Machine: How Tropical Arithmetic Turns Training into Counting

## A different kind of arithmetic

Suppose you throw away multiplication and addition and replace them with something stranger. In **tropical arithmetic**, "addition" means *take the maximum* and "multiplication" means *ordinary addition*:

$$a \oplus b = \max(a,b), \qquad a \otimes b = a + b.$$

This is not a game. Tropical arithmetic is the natural algebra of scheduling, of shortest paths, of optimal control — anywhere the cost of a compound operation is the *worst* of its parts rather than the sum. It is also, more recently, the natural algebra of a very ordinary object: the neural network built from rectified linear units. A network whose only nonlinearity is $\mathrm{relu}(x) = \max(x,0)$ computes, coordinate by coordinate, a *difference of tropical polynomials*. Every ReLU network is a tropical rational function, and every tropical rational function is a ReLU network. The two vocabularies describe the same class of continuous, piecewise-linear maps.

That correspondence raises a question that is easy to state and, it turns out, has a completely exact answer. What happens when you *train* a tropical model — when you run gradient descent on the simplest tropical object there is, and measure error in the most natural way?

The answer, in one sentence: **training becomes a counting problem, and the algorithm doesn't merely converge, it finishes.** Not "converges asymptotically." Not "converges linearly." It reaches an exact optimum in a number of steps you can compute in advance from the initial condition, and afterwards it sits there forever. And there is a further surprise: the geometry of the optimum — whether it is a single point or a whole segment — can be read off from the *width* of the smallest ReLU network that implements one step of the training algorithm. Two units means a point; four units means a segment. Nothing in between, ever.

This article tells that story.

## The simplest tropical model

Take the simplest nonconstant tropical function of one variable: the tropical monomial
$$z \mapsto z \otimes \theta = z + \theta,$$
with a single trainable parameter $\theta$. Given data pairs $(z_j, y_j)$, the residual of the $j$-th observation is $|(z_j + \theta) - y_j| = |\theta - x_j|$, where $x_j := y_j - z_j$ is the *reduced sample*. So every one-parameter tropical regression problem, no matter what its raw data looked like, collapses to the same clean question:

> Given $n$ real numbers $x_0, \dots, x_{n-1}$, minimize
> $$L(\theta) \;=\; \sum_{i=0}^{n-1} |\theta - x_i|.$$

This is the $L^1$ — absolute-error — empirical loss, and the answer is the folklore fact that the $L^1$ minimizer is the *median*. Folklore is not proof, and the folklore version quietly hides the interesting structure. Here is the structure.

### One mechanism, all the theorems

Everything below flows from a single observation about what happens when you slide $\theta$ to the right, from a pivot $p$ to a point $\theta > p$. Every sample sitting at or below $p$ contributes a term $|\theta - x_i|$ that grows by *exactly* $\theta - p$. Every other sample contributes a term that can shrink, but by at most $\theta - p$. So if $j$ of the $n$ samples lie at or below the pivot,

$$L(\theta) \;\ge\; L(p) + \bigl(j - (n-j)\bigr)\,(\theta - p).$$

The rate of increase is the **imbalance** between the block below the pivot and the block above it. Mirror the argument to slide left. That is the whole engine. Moreover the inequality is *sharp*: if all the samples above the pivot also lie above $\theta$, so that no data point is crossed, then the bound holds with equality — the loss is exactly affine with slope $j - (n-j)$ on that slab.

Now feed the engine different pivots.

**Odd samples.** With $n = 2k+1$ sorted samples $x_0 \le \dots \le x_{2k}$, take the pivot at the middle order statistic $m := x_k$. Sliding right, $k+1$ samples lie at or below $m$ and $k$ above, so the imbalance is $1$; sliding left, the imbalance is again $1$. Combining:

$$L(m) + |\theta - m| \;\le\; L(\theta) \qquad \text{for every } \theta.$$

The loss doesn't just have its minimum at the median — it grows *at least as fast as the distance travelled*. Consequently $\theta$ minimizes $L$ **if and only if** $\theta = m$: the minimizer is unique, and the growth is a genuine "sharp-bottomed valley," not a flat basin. And the constant $1$ cannot be improved: between $x_k$ and $x_{k+1}$ the loss is exactly $L(m) + (\theta - m)$.

**Even samples.** With $n = 2k+2$ samples the picture changes qualitatively. Between the two central order statistics $x_k$ and $x_{k+1}$ the two blocks are perfectly balanced, and the loss is *constant*: an explicit computation gives

$$L(\theta) \;=\; \sum_{i=k+1}^{2k+1} x_i \;-\; \sum_{i=0}^{k} x_i \qquad \text{for all } \theta \in [x_k, x_{k+1}],$$

a value independent of $\theta$. Outside that interval the imbalance jumps to $2$, so the loss grows with slope at least $2$ in each direction. Therefore:

> **The set of minimizers of an even sample is exactly the closed interval $[x_k, x_{k+1}]$** — no more, no less.

The parity of the sample size is not a technicality. It decides whether the optimum is a *point* or a *segment*, and that dichotomy will echo all the way into the architecture of the training step.

## The training step, and why it stops

What does subgradient descent actually do here? The subgradient of $L$ counts samples: it is (number above $\theta$) minus (number below $\theta$), up to sign, and a step of size $\eta$ moves $\theta$ toward the median. The one crucial refinement is *clipping*: the update must not overshoot the target. The resulting one-step map, the **clipped tropical update** with target $m$ and step $t$, is

$$\Phi_{m,t}(x) \;=\; \begin{cases} \min(m,\; x + t) & x < m,\\[2pt] \max(m,\; x - t) & x \ge m.\end{cases}$$

In words: walk $t$ units toward $m$, and stop if you get there.

Two facts make this map exceptionally well behaved. First, it satisfies a **semigroup law**: for $s \ge 0$,
$$\Phi_{m,s}\bigl(\Phi_{m,t}(x)\bigr) = \Phi_{m,t+s}(x).$$
Composing two clipped steps is a single clipped step with the times added. That means $n$ steps of size $\eta$ are *literally the same thing* as one step of size $n\eta$: the discrete algorithm and the continuous flow coincide exactly, with no discretization error whatsoever. Second, the distance to the target obeys an exact law, not an inequality:
$$\bigl|\Phi_{m,t}(x) - m\bigr| \;=\; \max\bigl(0,\ |x - m| - t\bigr).$$

Put these together and the convergence theory is complete and exact. After $n$ steps of size $\eta > 0$ from initialization $x_0$,

$$\Phi_{m,\eta}^{\,n}(x_0) = m \quad \Longleftrightarrow \quad |x_0 - m| \le n\eta.$$

So training terminates at the exact optimum after
$$N \;=\; \left\lceil \frac{|x_0 - m|}{\eta} \right\rceil \ \text{ steps},$$
and **not one step earlier** — every iterate before $N$ is strictly off the optimum. This is finite termination with a matching lower bound: the ceiling is not an artifact of a lossy estimate, it is the truth.

The loss follows along. Because $L$ is $n$-Lipschitz (each of the $n$ absolute-value terms is $1$-Lipschitz), the excess empirical risk after $n$ steps is squeezed between $0$ and
$$(2k+1)\cdot \max\bigl(0,\ |x_0 - m| - n\eta\bigr),$$
which hits zero, exactly, at step $N$.

**Even samples: descend onto a segment.** When the optimum is an interval $[\ell, h]$ rather than a point, the natural update aims at the *nearest* optimal point — the metric projection $\pi(\theta) = \max(\ell, \min(h, \theta))$ — and clips:
$$S_{\ell,h,\eta}(\theta) = \Phi_{\pi(\theta),\,\eta}(\theta).$$
The projection turns out to be a **conserved quantity** of this dynamics: one step never changes which optimal point you are aiming at. That single invariance collapses the whole iteration to the scalar case: $n$ steps of the interval update equal one clipped flow of duration $n\eta$ toward the fixed target $\pi(\theta)$. Training therefore halts at $\pi(\theta)$ — the point of the optimal segment nearest to where you started — after $\lceil |\theta - \pi(\theta)|/\eta \rceil$ steps, and the point it halts at is an exact empirical-risk minimizer. Where you start decides which optimum you get; how long it takes is exactly the distance divided by the step, rounded up.

## Many parameters: boxes

Real models have more than one parameter. For a *separable* tropical affine model — $d$ coordinates, each with its own sample — the loss is $\sum_i L_i(\theta_i)$, and here a clean general principle applies:

> **Separability principle.** A sum $\sum_i F_i(\theta_i)$ of one-variable functions is minimized at $\theta$ if and only if each $F_i$ is minimized at $\theta_i$.

The proof is a two-line argument with the update-one-coordinate trick, but the consequences are structural. With odd samples in every coordinate, the joint minimizer is the unique vector of coordinatewise medians, and simultaneous descent hits it after exactly $\max_i \lceil |\theta_i - m_i|/\eta \rceil$ steps — the slowest coordinate sets the clock, and again no earlier step will do.

With *even* samples in every coordinate, the joint minimizer set is exactly the **box**
$$\prod_{i=1}^{d} \bigl[x_i(k_i),\, x_i(k_i+1)\bigr],$$
a product of central segments. Simultaneous clipped descent freezes at the coordinatewise projection of the initialization onto that box, in at most the maximum of the $d$ coordinatewise times, at an exact optimum. The high-dimensional dynamics factor *perfectly* through $d$ independent scalar problems — nothing is lost.

A concrete instance: two coordinates with four-point samples $(-3,-1,2,5)$ and $(0,1,1,4)$. The optimal set is $[-1,2] \times [1,1]$ — a segment in the first coordinate and a single point in the second, because the second sample happens to have a repeated central value. A box that is degenerate in some directions and not others; and descent from any starting point lands on its nearest face in finitely many steps.

## What if the steps are noisy?

Exact finite termination sounds fragile. It is not, and there is a precise statement of how it degrades. Suppose every update is corrupted by an error of size at most $\varepsilon$, so the trajectory only satisfies $|u_{n+1} - \Phi_{m,\eta}(u_n)| \le \varepsilon$. Then for $\varepsilon \le \eta$,

$$|u_n - m| \;\le\; \max\Bigl(\varepsilon,\ |u_0 - m| - n(\eta - \varepsilon)\Bigr).$$

The noise eats into the step size: the effective speed is $\eta - \varepsilon$ rather than $\eta$, and the guarantee saturates at radius $\varepsilon$. Outside the $\varepsilon$-ball the clean linear bound $|u_0 - m| - n(\eta-\varepsilon)$ still holds verbatim, and for $\varepsilon < \eta$ the trajectory enters the closed $\varepsilon$-ball in finitely many steps and never leaves it.

The $\max$ with $\varepsilon$ is not slack in the argument — it is *necessary*. The constant trajectory $u_n \equiv m + \varepsilon$ is a legitimate perturbed run: the clipped update sends $m+\varepsilon$ to $m$ (as long as $\varepsilon \le \eta$), and the perturbation of size exactly $\varepsilon$ puts it back. It sits at distance exactly $\varepsilon$ forever. So the naive hope that the bound decays to $0$ is simply false, and the radius $\varepsilon$ is attained.

## Reading the geometry off the architecture

Now the part that connects back to neural networks.

The clipped update is a continuous piecewise-linear map, so it *is* a small ReLU network. Which one, and how small? A "width-$k$ network with a skip connection" here means
$$N(x) = \sum_{j=1}^{k} a_j\,\mathrm{relu}(b_j x + c_j) + px + q,$$
$k$ units plus an affine bypass. The bypass matters: allowing it makes lower bounds much harder, because a linear term can absorb a great deal of structure for free.

The right tool is a **discrete curvature test**. For a window of radius $h$ around a point $x$, form the second difference
$$D_h N(x) = N(x+h) + N(x-h) - 2N(x).$$
A single ReLU unit is affine on any window that misses its kink, so its second difference there is zero; the linear skip contributes zero always. Hence: *if $D_h N(x) \ne 0$, some unit must have its kink strictly inside the window $(x-h, x+h)$.* That is the kink-witness principle, and it needs no convexity, no differentiability, and no sign conditions.

Add one more elementary lemma — two windows of radius $h$ whose centers are at least $2h$ apart cannot share a unit — and width lower bounds become *counting separated kinks*.

Apply it. The scalar clipped update $\Phi_{m,t}$ with $t>0$ has kinks at $m-t$ and $m+t$, which are $2t$ apart: pick $h = t/2$ and both windows have nonvanishing second difference, so at least two distinct units are needed. And two suffice:
$$\Phi_{m,t}(x) \;=\; m + \mathrm{relu}(x - m - t) - \mathrm{relu}(m - x - t).$$
Exact width two. (A softer argument also shows a *single* unit can never work, because one ReLU unit is either convex or concave while the clipped update is flat between two kinks of opposite curvature — but the curvature test is strictly stronger, since it survives the addition of the affine skip.)

Now the interval update $S_{\ell,h,\eta}$ with $\ell < h$. It has **four** kinks — at $\ell - \eta$, $\ell$, $h$, and $h + \eta$ — and the same counting argument, with window radius $\min(\eta, h-\ell)/2$, forces four distinct units. Four suffice, via a telescoping identity with alternating signs:
$$S_{\ell,h,\eta}(\theta) = \theta + \eta - \mathrm{relu}\bigl(\theta - (\ell-\eta)\bigr) + \mathrm{relu}(\theta - \ell) - \mathrm{relu}(\theta - h) + \mathrm{relu}\bigl(\theta - (h+\eta)\bigr).$$

Put the two cases side by side, using the fact that the degenerate interval $\ell = h$ reproduces the scalar update exactly:

> **Width dichotomy.** One clipped descent step toward the tropical $L^1$ optimum requires exactly **two** ReLU units when the optimum is a point, and exactly **four** when it is a nondegenerate segment.

The width of the optimizer is a faithful invariant of the minimizer geometry — which, as we saw, is decided by the parity of the sample. An architectural quantity you can measure by counting neurons tells you a statistical fact about the data. That is the kind of bridge tropical geometry is good at building.

## Why this matters

Three things stand out.

**Exactness.** Almost every convergence theorem in optimization is asymptotic or rate-based. Here everything is an identity: the distance after $n$ steps is *equal* to $\max(0, |x_0-m| - n\eta)$; the stopping time is *exactly* $\lceil |x_0-m|/\eta\rceil$; the minimizer set is *exactly* an interval, or *exactly* a box. Tropical models are rigid enough to admit closed-form training.

**Robustness with a sharp radius.** The finite-termination guarantee degrades gracefully and predictably under noise: effective speed $\eta - \varepsilon$, terminal radius exactly $\varepsilon$. Both halves — the bound and its attainment — are part of the theorem.

**A dictionary between geometry and architecture.** The kink-counting method that gives the $2$-versus-$4$ dichotomy is not special to these maps. It says: to implement a piecewise-linear map with well-separated kinks, you need at least one unit per kink, skip connections notwithstanding. The tropical minimizer geometry is thereby *encoded* in the smallest architecture that can run one step of its own training.

Tropical arithmetic began as a way of turning optimization problems into algebra. Here the circle closes: an algebraic model, trained by an ordinary optimizer, produces an optimization dynamics so rigid that its convergence, its optimum, and even the neural architecture needed to express its own update rule are all determined by a single act of counting.
