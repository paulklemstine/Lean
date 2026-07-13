# When Coins Agree: The Hidden Geometry of Correlation on the Cube

Imagine flipping $n$ fair coins and laying them out in a row. Each pattern of
heads and tails is a point of a vast combinatorial universe: the *discrete
cube* $\{0,1\}^n$, home to $2^n$ equally likely configurations. Now suppose two
observers each look at the same coins and each answer a yes/no question about
them. One asks, "Are at least half the coins heads?" Another asks, "Is the first
coin heads?" A third asks something more elaborate. A natural question quietly
underlies all of statistics, physics, and computer science: **when two such
questions both tend to say "yes," do they say "yes" together?**

This is the question of *correlation*, and on the discrete cube it has a
beautiful and surprisingly rigid answer. This article tells the story of that
answer — a sharp inequality, its two extreme faces, and the mathematics that
pins them down exactly.

## The players: observables, means, and covariance

Fix the number of coins $n$ and think of a coin pattern as a point
$x \in \{0,1\}^n$. An **observable** is any real-valued function $f$ on the
cube: it reads a pattern and returns a number. If $f$ only ever returns $0$ or
$1$, we call it an *event* — it is the yes/no question "does pattern $x$ have
property $f$?"

Because all $2^n$ patterns are equally likely, the **mean** (or expectation) of
an observable is simply its average value,
$$\mathbb{E}[f] = \frac{1}{2^n}\sum_{x \in \{0,1\}^n} f(x).$$
The mean is *linear*: the average of a sum is the sum of the averages, and
constants pass straight through, $\mathbb{E}[c] = c$.

The heart of the story is the **covariance** of two observables,
$$\operatorname{Cov}(f,g) = \mathbb{E}[f\cdot g] - \mathbb{E}[f]\,\mathbb{E}[g].$$
Covariance measures the tendency of $f$ and $g$ to move together. When it is
positive, high values of $f$ come paired with high values of $g$; when it is
negative, one rises as the other falls; when it is zero, the two are, on
average, indifferent to each other. The covariance of an observable with itself
is its **variance**, $\operatorname{Var}(f) = \operatorname{Cov}(f,f)$, a
measure of how much $f$ fluctuates.

## Monotone questions never disagree

A special and important class of questions are the **monotone** (or increasing)
ones: turning a coin from tails to heads can only make the answer more likely to
be "yes," never less. "Are at least half the coins heads?" is monotone. "Is the
first coin heads?" is monotone. "Is the number of heads exactly seven?" is not.

For monotone observables there is a foundational fact, a cornerstone of
probability and statistical physics known as the **Harris inequality** (a
special case of the Fortuin–Kasteleyn–Ginibre, or FKG, inequality):

> **Harris / FKG Correlation Inequality.** If $f$ and $g$ are both increasing
> observables on the cube, then $\operatorname{Cov}(f,g) \ge 0$.

In words: *monotone questions can never be negatively correlated.* If two
properties both become more likely as coins flip to heads, then knowing one
holds can only make the other more plausible. This is intuitively obvious and
notoriously subtle to prove — the classical proof passes through the algebra of
distributive lattices. A pleasant subtlety is that the inequality needs no
assumption that $f$ and $g$ are nonnegative: it holds for *arbitrary real*
increasing observables. The trick is a translation. Replace $f$ by
$f - f(\mathbf{0})$, where $\mathbf{0}$ is the all-tails pattern; this new
function is still increasing, is now nonnegative (its smallest value is at the
bottom of the cube), and — crucially — has *exactly the same covariance* with
$g$, because adding a constant to $f$ changes neither how it fluctuates nor how
it co-fluctuates with anything else.

The mirror image is just as clean. If $f$ increases but $g$ *decreases*, then

> **Reverse Correlation Inequality.** For $f$ increasing and $g$ decreasing,
> $\operatorname{Cov}(f,g) \le 0$.

Opposing tendencies are anti-correlated. This follows instantly from Harris
applied to $f$ and $-g$.

## How large can agreement get?

Harris tells us monotone correlation is nonnegative, but *how big* can it be?
For events — $\{0,1\}$-valued observables, and more generally any observable
whose values lie in the interval $[0,1]$ — there is a crisp ceiling.

The first ingredient is a bound on a single observable's fluctuation. For any
$[0,1]$-valued $f$, the variance satisfies
$$\operatorname{Var}(f) \le \tfrac14.$$
The reason is elegant: when $0 \le f(x) \le 1$, we always have
$f(x)^2 \le f(x)$, so $\mathbb{E}[f^2] \le \mathbb{E}[f]$; combined with the
identity $\operatorname{Var}(f) = \mathbb{E}[f^2] - \mathbb{E}[f]^2$ and the
fact that $t - t^2 \le 1/4$ for every real $t$, the bound falls out. Variance is
also never negative — it is an average of squared deviations from the mean.

The second ingredient is the venerable **Cauchy–Schwarz inequality**, which in
this language reads
$$\operatorname{Cov}(f,g)^2 \le \operatorname{Var}(f)\,\operatorname{Var}(g).$$
Correlation is limited by the individual fluctuations. Putting the two together
gives the centerpiece of this work:

> **Sharp Diagonal Correlation Bound.** For any two $[0,1]$-valued observables
> $f$ and $g$ on the cube,
> $$\operatorname{Cov}(f,g) \le \tfrac14.$$

Remarkably, this ceiling needs *no* monotonicity assumption — it holds for all
bounded observables. And the number $\tfrac14$ is not an artifact of a lossy
argument. It is *exactly* attainable, and the story of *how* it is attained
reveals the geometry hiding underneath.

## The two extremes: dictators and strangers

To understand when correlation is largest and when it vanishes, we meet the
simplest interesting events of all: the **dictatorships**. The $i$-th
dictatorship $\operatorname{dict}_i$ is the event "is coin $i$ heads?" — it
returns $1$ if $x_i = 1$ and $0$ otherwise. A single coordinate *dictates* the
answer, ignoring all other coins.

Dictatorships have a perfectly clean profile. Because a fair coin is heads half
the time,
$$\mathbb{E}[\operatorname{dict}_i] = \tfrac12, \qquad
\operatorname{Var}(\operatorname{dict}_i) = \tfrac14.$$
A dictatorship is maximally fluctuating: its variance sits exactly at the
$\tfrac14$ ceiling. Now compare two dictatorships.

- **Same coordinate.** If both observers ask about the *same* coin,
  $$\operatorname{Cov}(\operatorname{dict}_i, \operatorname{dict}_i)
  = \operatorname{Var}(\operatorname{dict}_i) = \tfrac14.$$
  This is the extreme case: two questions about the same coin are as correlated
  as $[0,1]$-valued questions can possibly be. The diagonal bound is *attained*,
  proving that $\tfrac14$ is sharp and not merely an upper estimate.

- **Different coordinates.** If the observers ask about *different* coins,
  $$\operatorname{Cov}(\operatorname{dict}_i, \operatorname{dict}_j) = 0
  \quad (i \ne j).$$
  Distinct coins are independent, so distinct dictatorships are perfectly
  uncorrelated.

So the two dictatorship regimes sit at opposite ends of the correlation
spectrum: perfect agreement ($\tfrac14$) when they share a coordinate, complete
indifference ($0$) when they do not.

## Strangers stay strangers: disjoint-support rigidity

The vanishing of correlation between different dictatorships is a shadow of a
much more general and robust phenomenon. Suppose observer $f$ only ever looks at
some fixed subset $S$ of the coins, and observer $g$ only ever looks at the
*complementary* coins outside $S$. Their questions are built from entirely
separate pieces of information. Intuition screams that they should be
uncorrelated, and they are:

> **Disjoint-Support Rigidity.** If $f$ depends only on the coordinates in $S$
> and $g$ depends only on the coordinates outside $S$, then
> $$\operatorname{Cov}(f,g) = 0.$$

The proof is a small combinatorial gem. Consider pairs of coin patterns
$(x,y)$, and the "block swap" that keeps the $S$-coordinates of $x$ but takes
the non-$S$ coordinates of $y$, and vice versa. This swap is an *involution* —
doing it twice returns you to where you started — and it perfectly reshuffles
the product of two independent cubes. Averaging $f$ times $g$ over this
reshuffling decouples the two, turning $\mathbb{E}[f g]$ into
$\mathbb{E}[f]\,\mathbb{E}[g]$ exactly. That is precisely the statement that the
covariance is zero.

This is the *equality boundary* of the Harris inequality: it identifies a whole
family of monotone pairs for which the correlation is not just small but exactly
zero, marking the floor of the positively-correlated regime.

## Why this is the base camp for a bigger climb

Put together, these results paint a complete map of the extremes:

- **The floor.** Correlation of monotone questions never goes below $0$
  (Harris), and it *equals* $0$ whenever the questions read disjoint blocks of
  coins (rigidity).
- **The ceiling.** Correlation of $[0,1]$-valued questions never exceeds
  $\tfrac14$ (the sharp diagonal bound), and it *equals* $\tfrac14$ exactly when
  both questions are the same dictatorship.

What makes this more than a catalogue of special cases is that the extremes are
pinned down *uniquely* enough to ask a far deeper question — one about
**stability**. If two monotone events are correlated *almost* as strongly as the
maximum allows, at correlation $\tfrac14 - \varepsilon$, must they *almost* be a
common dictatorship? If their correlation is *almost* zero, must their supports
be *almost* disjoint? These are quantitative "rigidity" or "stability"
conjectures: they promise that near-extremal behaviour forces near-extremal
structure. The exact extremal computations here — the unique maximiser, the
exact vanishing on disjoint supports — are precisely the anchors such stability
arguments need.

The same skeleton is measure-agnostic. Replace the fair coins by *biased* coins
that land heads with probability $p$, and the natural conjecture is that the
ceiling deforms continuously to $p(1-p)$ — the variance of a single biased coin
— while the extremiser stays a common dictatorship. The uniform case worked out
here, with its translation-plus-Cauchy–Schwarz backbone, is exactly the
template that should carry over.

Correlation on the cube is one of those places where a homely question about
coins opens onto a landscape of sharp inequalities, exact extremisers, and rigid
structure. The floor and the ceiling are now firmly in place. The climb toward
the stability theory built on top of them has a solid base camp.
