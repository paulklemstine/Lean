# When Probability Forgets How to Add: The Strange World of Idempotent Large Deviations

## A coin that only remembers its best outcome

Imagine a casino where the house has rewritten the rules of arithmetic. At the
ordinary roulette table, the chance of *either* red *or* black is the sum of the
two chances. But in this strange new casino, "or" no longer means *add* — it
means *take the maximum*. If red pays you a score of $-2$ and black pays you a
score of $-5$, then the score of "red or black" is not $-7$ and not $-2.5$; it
is simply $-2$, the better of the two. The casino has forgotten how to add. It
only ever remembers the best thing that could happen.

This is not a thought experiment for its own sake. It is a precise and
surprisingly rich mathematical universe called **idempotent probability**, or
**max-plus probability**, and it sits at the crossroads of optimization,
statistical physics, tropical geometry, and the theory of rare events. The word
*idempotent* refers to the defining quirk: in this arithmetic, $a + a = a$,
because the maximum of a number with itself is just itself. Addition has become
idempotent.

In this article we follow one particular thread through that universe: the
theory of **large deviations** — the mathematics of how unlikely events behave
when you push a system to its extremes. We will see that a famous and famously
delicate result of classical probability, the **Donsker–Varadhan variational
principle**, has an idempotent twin that is not only true but *cleaner*, *exact*,
and stripped of the convexity machinery that the classical version cannot live
without. Along the way a single, humble inequality about maxima will do the work
that, in ordinary probability, requires the full weight of convex analysis.

## The dictionary: from times-and-plus to plus-and-max

To work in the new casino we need a dictionary. Ordinary arithmetic lives in
what mathematicians call a *semiring*: a world with an addition and a
multiplication. The **max-plus semiring** replaces them:

- **Addition becomes maximum**: $a \oplus b = \max(a, b)$.
- **Multiplication becomes ordinary addition**: $a \otimes b = a + b$.
- The "zero" (the neutral element for $\oplus$) becomes $-\infty$.
- The "one" (the neutral element for $\otimes$) becomes $0$.

There is a beautiful reason this dictionary is natural, not arbitrary. Consider
the quantity
$$\frac{1}{n}\log\!\big(e^{n a} + e^{n b}\big).$$
As the parameter $n$ grows without bound, the larger of $a$ and $b$ dominates the
exponential, and this expression converges to $\max(a,b)$. The ordinary sum,
filtered through a logarithm and a growing temperature, *becomes* the maximum.
Physicists call $n$ an inverse temperature and call this the *zero-temperature
limit*; mathematicians call it **Maslov dequantization**. It is the bridge that
turns classical analysis into idempotent analysis, and we will return to it.

A **max-plus measure** on a finite collection of outcomes $X$ is then nothing
more than an assignment of a real number — a *weight* — to each outcome:
$$w \colon X \to \mathbb{R}.$$
Think of $w(x)$ as the log-likelihood of outcome $x$, measured on the
zero-temperature scale. We call $w$ a **tropical probability measure** when it is
normalized the way a log-likelihood should be:
$$\max_{x \in X} w(x) = 0 \qquad\text{and}\qquad w(x) \le 0 \text{ for every } x.$$
The most likely outcome carries weight $0$ (probability $1$ on the log scale),
and everything else is penalized by how far below the peak it sits.

Finally, to integrate a function $\varphi \colon X \to \mathbb{R}$ — an
observable, a payoff, a test function — against such a measure, we do not sum and
we do not average. We maximize:
$$\int^{\!+}\!\varphi\,dP \;=\; \max_{x \in X}\big(\varphi(x) + w_P(x)\big).$$
This **max-plus integral** is the idempotent expectation. It asks a single
question: across all outcomes, what is the best achievable total of payoff plus
log-likelihood? In optimization this is exactly a value function; in physics it
is a free energy at zero temperature; in machine learning it is the logic behind
a hard "winner-take-all" or max-pooling layer.

## Rare events and the shape of cost

Classical large deviation theory studies the probability that a random average
strays far from its typical value. Such probabilities decay exponentially, and
the *speed* of that decay is governed by a so-called **rate function** $I(x)$,
which measures the "cost" of the system being found at the atypical state $x$.
Rare events are not impossible — they are merely expensive, and the rate function
is the price tag.

In the idempotent world the rate function is disarmingly simple. For a tropical
probability $P$ with weights $w_P$, define
$$I_P(x) \;=\; -\,w_P(x).$$
Because the peak weight is $0$ and all weights are non-positive, the rate
function is non-negative everywhere and vanishes exactly at the most likely
outcome. The penalty for being at $x$ is precisely how far $x$ falls below the
summit of the distribution. This is the zero-temperature shadow of the classical
rate function, and it is *exact* — no limits, no smoothing, no error terms.

Here the idempotent theory already shows its hand. The classical statement "the
probability of an event $A$ decays like $e^{-n \inf_{x \in A} I(x)}$" is an
*asymptotic* truth, valid only in the limit. Its idempotent counterpart is an
*identity*. If we define the cost of an event $A$ as $-\max_{x\in A} w_P(x)$,
then
$$\text{cost}(A) \;=\; \min_{x \in A} I_P(x),$$
on the nose, for every finite event. Idempotency has removed the logarithm and
the exponential that, in classical probability, blur this relationship into an
approximation. The maximum *is* the integral, and the cost of an event simply
*is* the cheapest way to make it happen.

## Random walks that scale perfectly

What makes a large deviation theory a *theory*, rather than a collection of
definitions, is what happens when you repeat an experiment many times. Consider a
**max-plus random walk**: take $n$ independent copies of our outcome space and
form paths $\omega = (\omega_1, \dots, \omega_n)$, assigning each path the
additive weight $\sum_i w_P(\omega_i)$ and observing the total displacement
$S_n(\omega) = \sum_i \mathrm{val}(\omega_i)$.

To track how the walk concentrates, we use the **idempotent cumulant generating
function**, the max-plus analogue of the moment generating function from
ordinary probability:
$$\Lambda(\lambda) \;=\; \max_{x \in X}\big(\lambda\,\mathrm{val}(x) + w_P(x)\big).$$
In classical probability the cumulant generating function of a sum of $n$
independent variables grows like $n$ times the single-step function — but only
after taking logarithms and exponentials, and only because $e^{a+b}=e^a e^b$. In
the idempotent world the same scaling holds *exactly and elementarily*:
$$\Lambda_{\text{walk}}(\lambda) \;=\; n\cdot\Lambda(\lambda).$$
The reason is a single clean fact about maxima: the maximum of a sum of
independent coordinates is the sum of the coordinate-wise maxima. There is no
need to invoke independence in the probabilistic sense, no need for moment
bounds, no need for anything beyond the observation that you can optimize each
coordinate separately. The law of large numbers, in this world, is a sentence
about rearranging a maximum.

From this exact scaling flows an **idempotent Chernoff bound**: for any
$\lambda \ge 0$ and any outcome $x$ in the upper-tail event
$\{\mathrm{val} \ge a\}$,
$$w_P(x) \;\le\; \Lambda(\lambda) - \lambda\,a.$$
Optimizing over $\lambda$ recovers the familiar exponential-tail estimate of
classical theory — except here it is a finite, exact inequality rather than an
asymptotic one.

## The crown jewel: idempotent Donsker–Varadhan

We now reach the result at the heart of this work. In classical probability the
**Donsker–Varadhan / Gibbs variational principle** is a jewel of convex duality.
It says that the free energy of a system can be recovered by a competition: you
search over *all* alternative probability laws $Q$, rewarding each by the average
energy it assigns and penalizing it by how far it has strayed from the reference
law $P$. The penalty is the celebrated **Kullback–Leibler divergence** (relative
entropy) $\mathrm{KL}(Q\,\|\,P)$, and the principle reads
$$\log \mathbb{E}_P\big[e^{\varphi}\big] \;=\; \sup_{Q}\Big(\mathbb{E}_Q[\varphi] - \mathrm{KL}(Q\,\|\,P)\Big).$$
This is the equation behind the Gibbs distribution in statistical mechanics, the
ELBO in variational inference, and a great deal of modern machine learning. Its
proof is genuinely hard: it rests on the convexity of the exponential and the
strict convexity of entropy.

What is the idempotent twin? First we need the right notion of "distance between
laws." In place of the Kullback–Leibler divergence, define the **idempotent
relative entropy**
$$D(Q\,\|\,P) \;=\; \max_{x \in X}\big(w_Q(x) - w_P(x)\big).$$
It measures the worst-case gap by which $Q$ exceeds $P$ in log-likelihood. With
the max-plus integral playing the role of free energy, the idempotent
Donsker–Varadhan principle is the strikingly parallel statement
$$\int^{\!+}\!\varphi\,dP \;=\; \max_{Q}\Big(\int^{\!+}\!\varphi\,dQ \;-\; D(Q\,\|\,P)\Big),$$
where the maximum ranges over *all* tropical probability measures $Q$.

This functional $D$ behaves exactly as a divergence should, and we can say
precisely why.

**It is zero for the reference law.** Comparing $P$ with itself gives
$D(P\,\|\,P) = \max_x(w_P(x) - w_P(x)) = \max_x 0 = 0$. Nothing strays from
itself.

**It is never negative — the idempotent Gibbs inequality.** For any two tropical
probabilities, $D(Q\,\|\,P) \ge 0$. The argument is so short it is worth seeing
in full. Both $Q$ and $P$ are normalized, so $Q$ attains weight $0$ at some peak
outcome $x_0$, and $P$'s weight there is non-positive. Hence
$w_Q(x_0) - w_P(x_0) \ge 0 - w_P(x_0) \ge 0$, and the overall maximum is at least
this large. The entire content of the Gibbs inequality — a deep fact in classical
probability requiring Jensen's inequality and the convexity of $x\log x$ — is
here just the statement that a normalized peak sits at zero.

**It vanishes precisely when one law dominates the other.** $D(Q\,\|\,P) = 0$ if
and only if $w_Q(x) \le w_P(x)$ for every outcome $x$. The divergence detects
exactly when $Q$ never out-weighs $P$ anywhere.

With these in hand, the variational principle itself splits into two halves.
The first is **weak duality**: for *every* candidate law $Q$ and every observable
$\varphi$,
$$\int^{\!+}\!\varphi\,dQ \;-\; D(Q\,\|\,P) \;\le\; \int^{\!+}\!\varphi\,dP.$$
This is, once again, a one-line consequence of the most basic property of the
maximum — its *subadditivity*, $\max(a+b) \le \max a + \max b$. No candidate law
can beat the reference free energy. The second half is **attainment**: the bound
is achieved, and it is achieved by the reference law $P$ itself, because plugging
$Q = P$ makes the penalty $D(P\,\|\,P)$ vanish and returns exactly
$\int^{\!+}\varphi\,dP$. Putting the two halves together, the reference free
energy is the *greatest* value of "average payoff minus divergence" over all
laws — the precise sense in which the idempotent Donsker–Varadhan principle holds.

There is a genuinely surprising punchline hidden in that last step. In classical
statistical mechanics, the optimal law in the Donsker–Varadhan competition is
*not* the reference law — it is the **tilted Gibbs measure**, reweighted by
$e^{\varphi}$. You must deform $P$ to extract its free energy. In the idempotent
world, no tilting is necessary: the supremum is attained at $P$ itself. The
observable $\varphi$ has, in effect, already been absorbed into the geometry of
the maximum, and the reference law is its own optimal tilt.

## Why the idempotent version is *easier*

Step back and notice what was — and was not — needed. The classical
Donsker–Varadhan principle is a theorem of convex analysis: it lives or dies by
the convexity of the exponential and the strict convexity of entropy. The
idempotent version used none of that. Every step rested on two elementary
properties of the maximum:

- **Subadditivity**: $\max(a+b) \le \max a + \max b$ (this gave weak duality);
- **Normalization**: the peak weight of a tropical probability is exactly zero
  (this gave the Gibbs inequality and the attainment at $P$).

The whole edifice is *order-theoretic*, not analytic. This is more than an
aesthetic observation; it draws a sharp line through the theory of large
deviations. Classical large deviation theory has two faces. One face — the
Laplace principle, the contraction principle, the Donsker–Varadhan duality — is
about how maxima and sums interact under scaling. The other face — the
Legendre–Fenchel duality that identifies the rate function as the convex
conjugate of the cumulant generating function, the content of **Cramér's
theorem** — is genuinely about *convexity*.

The idempotent collapse treats these two faces utterly differently. The
order-theoretic face survives *exactly*: in the max-plus world it becomes not an
approximation but an identity, and it sheds every convexity hypothesis. The
convex face does *not* collapse for free; the gap between the rate function and
its convex hull (its Legendre–Fenchel biconjugate) is real and persists,
closing only at the special "tilt-exposed" outcomes that a supporting line can
reach. Idempotent probability is thus a kind of mathematical centrifuge: it spins
the theory of rare events and separates the parts that were really about *order*
from the parts that were really about *curvature*.

## Closing the loop: the Laplace principle

There is one more strand that ties the whole construction to ordinary
probability rather than leaving it as a self-contained game. Recall the
zero-temperature limit we met at the start. For any profile
$g \colon X \to \mathbb{R}$ on a finite outcome space, the scaled
log-partition function obeys the **finite Laplace principle**
$$\frac{1}{n}\log\!\sum_{x \in X} e^{\,n\,g(x)} \;\xrightarrow[n\to\infty]{}\; \max_{x \in X} g(x),$$
and — what is more — the approach is controlled by an explicit, *uniform* error
of size $\log(\#X)/n$ that does not depend on the profile $g$ at all. Choosing
$g(x) = \lambda\,\mathrm{val}(x) + w_P(x)$ turns the classical log-moment
generating function into the idempotent cumulant generating function; choosing
$g(x) = \varphi(x) + w_P(x)$ turns the classical free energy into the max-plus
integral. The idempotent objects are not analogies; they are genuine limits of
their classical counterparts, reached at a rate we can write down.

This same Laplace bridge connects the theory to modern machine learning, where
the very same log-sum-exp expression is the *softmax* function. As temperature
drops, softmax sharpens into a hard maximum — argmax — and the idempotent
integral describes exactly the winner-take-all regime that classification layers,
attention mechanisms, and tropical neural networks operate in. The casino that
forgot how to add turns out to be the casino that machine learning quietly
visits every time it picks a single best answer.

## A new lens on an old subject

What have we gained by visiting this strange casino? A reformulation of large
deviation theory in which the law of large numbers is a rearrangement of a
maximum, the Gibbs inequality is the observation that a normalized peak sits at
zero, and the Donsker–Varadhan variational principle — that crown jewel of convex
duality — becomes a two-line consequence of the subadditivity of the maximum,
with the optimal law revealed to be the reference law itself. The price of
admission was a willingness to let addition become maximum; the reward was a
clean separation of the order-theoretic and the convex souls of the subject.

Rare events, it turns out, have a simpler arithmetic than we thought — if only we
are willing to remember the best thing that could happen, and nothing else.
