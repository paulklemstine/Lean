# The Noise Floor: Why Every Learning Machine Hits the Same Wall

## A number you cannot argue with

Suppose you are handed a learning problem: a pile of noisy measurements, and a
signal hidden inside them that you would like to recover. You may choose any
method you like from a very large family — ridge regression, principal-component
truncation, early stopping of gradient descent, kernel smoothing, any of the
shrinkage estimators that statisticians have accumulated over a century. You
tune every knob perfectly. You have infinite computational patience.

How well can you do?

The surprising answer is that there is a single number, computable in closed
form from the data alone, that no method in that family can beat — and that
exactly one method attains. It is not an asymptotic statement, not a bound with
unspecified constants, and not a heuristic. It is an identity. The purpose of
this article is to explain what that number is, why the wall exists, and — the
new result at the heart of this work — to identify a beautiful information-theoretic
quantity that sits exactly one step above it: the *channel capacity* of the data.

## The setup, stripped to its bones

Almost every linear learning method, viewed in the right coordinate system, does
the same thing: it looks at the data one *mode* at a time and decides how much
of each mode to keep.

Concretely, let $A$ be the covariance matrix of the data. Diagonalize it. Its
eigenvectors are the natural directions of variation in the problem — the modes.
In those coordinates the problem decouples completely. In mode $i$ we have

- a **signal power** $a_i \ge 0$: how much genuine structure lives in that
  direction;
- a **noise power** $b > 0$: how much observation noise contaminates it. In the
  standard fixed-design regression normalization, $b = \sigma^2 / N$ where
  $\sigma^2$ is the noise variance and $N$ the sample size. More data means a
  smaller $b$; this is the only place the sample size enters.

A **spectral filter** is a vector $t = (t_i)$ with one number per mode: keep a
fraction $t_i$ of what you observe in mode $i$. Setting $t_i = 1$ trusts mode $i$
completely; $t_i = 0$ discards it. Ridge regression with regularization $\lambda$
is the filter $t_i = \mu_i/(\mu_i + \lambda)$ where $\mu_i$ are the covariance
eigenvalues. Principal-component regression is the filter with $t_i \in \{0,1\}$.
Gradient flow stopped at time $\tau$ is $t_i = 1 - e^{-\mu_i \tau}$. They differ
only in the *shape* of the profile $t$.

The excess risk of a filter splits into the classical two terms:

$$
R(t) \;=\; \sum_i \Big( \underbrace{a_i\,(1-t_i)^2}_{\text{bias}} \;+\; \underbrace{b\,t_i^2}_{\text{variance}} \Big).
$$

Keep too little and you throw away signal (bias); keep too much and you inherit
noise (variance). Every method is a different compromise.

## The wall

Here is the first main theorem.

> **The Noise-Floor Principle.** For any nonnegative spectrum $a$ and any noise
> level $b > 0$, every spectral filter $t$ satisfies
> $$ R(t) \;\ge\; \mathcal{N}(a,b) \;:=\; \sum_i \frac{a_i\, b}{a_i + b}, $$
> with equality if and only if $t$ is the Wiener filter $t_i = a_i/(a_i+b)$.

The proof is a one-line miracle of algebra. In each mode, complete the square:

$$
a_i(1-t_i)^2 + b\,t_i^2 \;=\; \frac{a_i b}{a_i + b} \;+\; \frac{\big((a_i+b)t_i - a_i\big)^2}{a_i+b}.
$$

The first term does not involve $t_i$ at all. The second is a perfect square
divided by a positive number, so it is $\ge 0$, and it vanishes exactly when
$t_i = a_i/(a_i+b)$. Sum over modes. That is the entire argument, and it delivers
a lower bound, an exact minimizer, and uniqueness in one stroke.

So the wall is real, and it has a name and a formula. Write

$$
d_{\mathrm{eff}}(a,b) \;=\; \sum_i \frac{a_i}{a_i+b}, \qquad \mathcal{N}(a,b) = b \cdot d_{\mathrm{eff}}(a,b).
$$

The quantity $d_{\mathrm{eff}}$ is the **effective dimension**. Each mode
contributes a number in $[0,1)$: essentially $1$ if $a_i \gg b$ (the mode sticks
out of the noise and is worth learning), essentially $0$ if $a_i \ll b$ (the mode
is drowned). The effective dimension counts, softly, how many directions in your
problem are actually visible. And the theorem says:

> **The irreducible risk is one unit of noise per visible dimension.**

That is a genuinely satisfying sentence. It also has a clean matrix form, because
$d_{\mathrm{eff}}$ is not just a spectral gadget: for a positive semidefinite
covariance $A$ with eigenvalues $\mu_i$,

$$
\operatorname{tr}\!\big( A (A + b\,\mathbb{1})^{-1} \big) \;=\; \sum_i \frac{\mu_i}{\mu_i + b} \;=\; d_{\mathrm{eff}}(\mu, b).
$$

The minimum achievable risk of *every* spectral method is therefore the analytic
functional $b \cdot \operatorname{tr}(A(A+b\mathbb{1})^{-1})$ of the covariance
alone — no reference to any estimator survives.

## What the wall is made of

A formula is one thing; understanding is another. What *is* $\sum_i a_i b/(a_i+b)$?

Note that $a b/(a+b)$ is the harmonic-style blend of $a$ and $b$: it is at most
both, and comparable to $\min(a,b)$. Precisely,

$$
\tfrac{1}{2}\min(a_i,b) \;\le\; \frac{a_i b}{a_i+b} \;\le\; \min(a_i,b).
$$

Summing gives the **head/tail sandwich**: split the modes at the noise level into
a *head* $\{i : a_i \ge b\}$ of resolvable modes and a *tail* $\{i : a_i < b\}$ of
drowned modes. Then

$$
\tfrac12\Big( b \cdot \#\text{head} + \sum_{\text{tail}} a_i \Big) \;\le\; \mathcal{N}(a,b) \;\le\; b \cdot \#\text{head} + \sum_{\text{tail}} a_i .
$$

Read it aloud: *the irreducible risk is, up to a factor of two, one unit of noise
for each mode you can see, plus the entire energy of every mode you cannot.* Both
constants in this sandwich are attained, so the factor of two is not an artifact
of a lazy proof; it is the exact price of replacing the smooth profile
$a b/(a+b)$ by the kinked $\min(a,b)$.

Two corollaries fall straight out, and both are the kind of statement one usually
sees hedged with "typically" or "in practice":

- **Nothing is learnable below the noise.** If every mode satisfies $a_i \le b$,
  then no spectral filter improves on the do-nothing estimator by more than a
  factor of two. When the signal is uniformly beneath the noise, sophistication
  buys you a constant, not an order.
- **Saturation above the noise.** If every mode satisfies $a_i \ge b$, the floor
  is at least $nb/2$: the irreducible risk grows *linearly in the ambient
  dimension* no matter how clever the method. Curse of dimensionality, as a
  theorem rather than a slogan.

## The new frontier: capacity between the two extremes

The head/tail sandwich compares the floor to a *counting* quantity. The crudest
useful bound compares it to a purely *linear* one: since $a/(a+b) \le a/b$,

$$
d_{\mathrm{eff}}(a,b) \;\le\; \frac{\operatorname{tr} A}{b} \;=\; \frac{\sum_i a_i}{b}.
$$

This trace bound is convenient — it needs only the total signal energy — but it
is badly lossy, precisely because it forgets that each individual mode
*saturates*: a huge mode still contributes only $1$, not $a_i/b$, to the effective
dimension. Doubling the energy of a mode that already dominates the noise buys
you nothing, and the trace bound cannot see that.

The central new result of this work identifies exactly what sits between the two.

> **The Capacity Frontier.** For a nonnegative spectrum $a$ and noise level
> $b>0$, define the **capacity**
> $$ C(a,b) \;=\; \sum_i \log\!\Big(1 + \frac{a_i}{b}\Big). $$
> Then
> $$ d_{\mathrm{eff}}(a,b) \;\le\; C(a,b) \;\le\; \frac{\sum_i a_i}{b}, $$
> and both inequalities can be strict.

The engine is a scalar sandwich that deserves to be better known:

$$
\frac{x}{x+b} \;\le\; \log\!\Big(1+\frac{x}{b}\Big) \;\le\; \frac{x}{b}, \qquad x \ge 0,\ b>0.
$$

Both halves come from the single elementary inequality $\log y \le y - 1$. Applied
to $y = 1 + x/b$ it gives the right-hand bound immediately. Applied to
$y = (1+x/b)^{-1}$, and using $\log y^{-1} = -\log y$, it gives
$-\log(1+x/b) \le \frac{b}{x+b} - 1 = -\frac{x}{x+b}$, which is the left-hand
bound. One inequality, used twice, in two directions.

Why is $C$ the right middle term, and not merely *a* middle term? Because it is
not an arbitrary interpolation: it is the **Gaussian channel capacity** of the
data. Up to the conventional factor of $\tfrac12$, $\sum_i \log(1 + a_i/b)$ is
the number of nats of information that a Gaussian channel with per-mode signal
powers $a_i$ and noise power $b$ can carry — Shannon's water-filling formula,
with no water-filling because the powers are given. It is simultaneously the
log-evidence of the Bayesian linear model with prior variance $a_i$, and — the
matrix identity that closes the circle —

$$
C(\mu, b) \;=\; \log \det\!\big(\mathbb{1} + b^{-1} A\big),
$$

the log-determinant of the regularized covariance. This is proved by
diagonalizing $A = U D U^{*}$, observing that
$\mathbb{1} + b^{-1}A = U\,(\mathbb{1} + b^{-1}D)\,U^{*}$ is a conjugate of a
diagonal matrix, so that the determinant is the product $\prod_i (1 + \mu_i/b)$
of the shifted eigenvalues (the unitary factors contribute reciprocal
determinants and cancel), and taking logarithms turns the product into the sum.

Multiplying through by $b$ gives the statement in its most quotable form:

> **Matrix Capacity Frontier.** For a positive semidefinite covariance $A$ and
> noise level $b > 0$,
> $$ \mathcal{N} \;\le\; b\,\log\det\!\big(\mathbb{1} + b^{-1}A\big) \;\le\; \operatorname{tr} A . $$

In words: *the irreducible risk of spectral learning is bounded by the channel
capacity of the data covariance, which is in turn bounded by the total signal
power.* On the left is an estimation-theoretic quantity — the best possible mean
squared error. On the right is a crude energy budget. In between sits a purely
information-theoretic object, and it is the tightest of the three natural
comparisons. Learning theory and information theory are joined here not by
analogy but by a chain of inequalities among three explicit functionals of the
same spectrum.

Is the refinement real, or is it a restatement? One mode, sitting exactly at the
noise level ($a = b = 1$), settles it: the three quantities are

$$
\tfrac12 \;<\; \log 2 \;\approx\; 0.693 \;<\; 1 .
$$

Both inequalities are strict at the most ordinary point imaginable. The frontier
is a genuine refinement.

## Which methods actually reach the wall?

The Noise-Floor Principle says the optimum is the Wiener filter $t_i =
a_i/(a_i+b)$, and that it is unique. That immediately raises an uncomfortable
question about the method everyone actually uses.

> **Ridge is optimal only under an exact isotropy relation.** Ridge regression
> with parameter $\lambda$ on a covariance with spectrum $\mu$ attains the noise
> floor if and only if $a_i \lambda = \mu_i b$ for every mode $i$.

Since $a_i = \theta_i^2 \mu_i$ for a signal with coefficients $\theta$, the
condition says $\theta_i^2 \equiv b/\lambda$: ridge is Bayes-optimal precisely
when the prior is flat. Any other signal geometry, and a single scalar knob is
provably the wrong shape.

How wrong? Sharply so, and the smallest possible example suffices. Take two
modes with signal powers $a = (1,0)$, a flat covariance, and $b=1$. A flat
covariance forces ridge to be a constant filter $t \equiv c$, with risk
$(1-c)^2 + 2c^2$. The noise floor is $1/2$. Minimizing over $c$ gives $2/3$ at
$c = 1/3$, so

$$
\text{best ridge risk} \;=\; \tfrac43 \times \text{noise floor},
$$

and the constant $4/3$ is attained, hence sharp. The true optimum here is the
non-constant filter $(1/2, 0)$, which no ridge parameter can produce. A 33%
excess, on a two-dimensional toy problem, from the single most standard
regularizer in statistics.

Early stopping fares better, and the comparison is strikingly asymmetric.

> **Early stopping dominates matched ridge, one-sidedly.** Gradient flow stopped
> at time $\tau$ never costs more than four times the matched ridge
> $\lambda = 1/\tau$ — for every spectrum, every signal, every noise level.
> The converse is false, and badly: on an explicit one-mode problem the matched
> ridge costs more than one hundred times early stopping.

The uniform factor-four bound comes from a per-mode comparison of the two filter
shapes, resting on the elementary estimates $e^{-u} \le 1/(1+u)$ and
$1 - e^{-u} \le 2u/(1+u)$ for $u = \mu_i \tau \ge 0$. The separation in the other
direction is a matter of tails: with a strong signal ($a = e^{20}$, $\mu = 1$,
$b = 1$, $\tau = 10$), early stopping has killed the bias down to
$e^{20}e^{-20} = 1$, while ridge has only suppressed it polynomially, to about
$e^{20}/121$. Exponential decay beats polynomial decay, and the folklore slogan
"early stopping is ridge with $\lambda = 1/\tau$" is therefore only half true:
one direction is a theorem with constant $4$, the other direction is false with
no constant at all.

## The hardest problem, and the shape of scaling laws

Two more consequences show how far a single formula travels.

**Which signal is hardest to learn?** Fix a total energy $\sum_i a_i = S$ across
$n$ modes and let an adversary distribute it. Since $x \mapsto xb/(x+b)$ is
concave and the floor is a symmetric sum, the maximum is at the flat spectrum
$a_i = S/n$, and the minimax value is exactly

$$
\max_{\sum a_i = S} \mathcal{N}(a,b) \;=\; \frac{S\,b\,n}{S + n b}.
$$

The formula is a harmonic blend of the two things that can limit you. With little
data ($nb \gg S$) it is $\approx S$: you learn nothing, and the risk is the whole
signal. With much data ($nb \ll S$) it is $\approx nb$: one unit of noise per
mode. The crossover is at $S = nb$, exactly the per-mode threshold $a = b$ that
governs the head/tail split. Concentrated spectra are easy; the adversary's best
move is to spread the signal so thin that every mode hovers at the detection
threshold.

**Where do neural scaling laws come from?** Empirically, model error decays like
a power of the amount of data, sometimes with a logarithmic correction. Once the
irreducible risk is reduced to the single functional $\mathcal{N}(a,b)$ with
$b = \sigma^2/N$, a scaling law stops being a modeling assumption and becomes a
computation. Take a geometric spectrum $a_i = r^i$ with $0 < r < 1$ — the generic
picture for smooth kernels and for empirical covariance spectra. Cut the modes at
the natural index $m$ where $r^{m+1} \le b \le r^m$. The head/tail sandwich gives

$$
\frac{b(m+1)}{2} \;\le\; \mathcal{N} \;\le\; b(m+1) + \frac{b}{1-r},
$$

and since $m \approx \log(1/b)/\log(1/r)$, this pins the risk at

$$
\mathcal{N} \;\asymp\; b\,\log(1/b) \;\asymp\; \frac{\sigma^2}{N}\log N .
$$

The log-corrected $1/N$ law, derived rather than assumed, with explicit constants
on both sides. Concretely, at $r = 1/2$, $b = 1/10$ and $10$ modes, the natural
cut is $m = 3$ and the floor is pinned between $0.2$ and $0.6$.

## What the wall teaches

Step back and the picture is unusually tidy for a subject as empirical as machine
learning. There is one functional,

$$
\mathcal{N}(a,b) = \sum_i \frac{a_i b}{a_i+b} = b \operatorname{tr}\!\big(A(A+b\mathbb{1})^{-1}\big),
$$

and it is simultaneously: the exact minimum of a variational problem over all
spectral filters; a trace functional of the covariance; a soft count of resolvable
directions; the value of a minimax game against an adversarial signal; and the
source of an honest scaling law. Around it, three tiers of comparison now stand in
a strict chain — the floor itself, the channel capacity $b \log\det(\mathbb{1} +
b^{-1}A)$, and the raw trace $\operatorname{tr} A$ — with the middle tier
borrowed, exactly and not merely by analogy, from Shannon.

Practically, the lesson is a warning and a permission. The warning: the excess
risk you cannot remove is set by the *shape* of your data spectrum relative to
$\sigma^2/N$, and no amount of estimator engineering moves it. If your spectrum
is flat at the threshold, you are in the worst case, and the only way out is more
data or better features. The permission: once your method is within a small
constant of the floor — and early stopping generally is — further tuning of the
regularizer is provably a rounding error, and your effort belongs elsewhere.

There is one number, it is computable, and it does not negotiate.
