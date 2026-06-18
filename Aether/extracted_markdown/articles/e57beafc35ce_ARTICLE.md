# The Hidden Trees Inside a Language Model — and Why They All Forget the Same Way

## A puzzle of sameness

Two research groups, on opposite sides of the world, train a large language
model. They use different random seeds, different text corpora, different
hardware. One trains on a snapshot of the open web; the other on a curated
library of books. By every right these two models should be different
creatures. Yet when you measure how quickly each one learns from the examples
inside a single prompt — the now-famous trick called *in-context learning*,
where a model picks up a new task just from a few demonstrations typed into its
input — something strange happens. Plot the error against the number of
examples, rescale the axes, and the two curves snap onto **the same curve**.

This is not a coincidence to be shrugged off. It is the signature of
**universality**, the same phenomenon that makes water boil at a sharply
defined temperature regardless of which pot you use, and that makes wildly
different magnets share identical critical behavior near their Curie point.
Physicists have a name for the machinery behind universality: the
*renormalization group*. The bold claim explored here is that in-context
learning has a renormalization group too — and that the right language for it
is not the familiar geometry of distances and angles, but a stranger geometry
borrowed from number theory: the **p-adic**, or **ultrametric**, world.

This article tells the story of two mathematical pillars that turn that claim
from a slogan into theorems. The first explains *where the structure comes
from*: attention, the core operation of a transformer, secretly organizes
itself into a **tree**. The second explains *why everything forgets the same
way*: the learning error flows, under rescaling, to a single **fixed point**
that no longer remembers how the model was born.

## A different kind of distance

Start with a question that sounds like a riddle. How far apart are two numbers?

The ordinary answer uses the absolute value: 7 and 10 are 3 apart. But there
is another, equally legitimate way to measure size, invented by the
mathematician Kurt Hensel over a century ago and now central to modern number
theory. Pick a prime number, say $p = 2$. Declare a whole number to be
**small** when it is divisible by a high power of $2$. So $8 = 2^3$ is *tiny*,
$16 = 2^4$ is *tinier still*, and an odd number like $7$ is *large*. Formally,
the **2-adic size** of a number is $2^{-k}$, where $k$ is how many times $2$
divides it. This is the *p-adic absolute value*, written $|\cdot|_p$.

This upside-down notion of size obeys an astonishing strengthening of the
triangle inequality. In ordinary geometry, the shortest path between two points
is a straight line, and detours only make things longer:
$d(x,z) \le d(x,y) + d(y,z)$. In the p-adic world the inequality becomes far
stricter — the **strong triangle inequality**, also called the *ultrametric
inequality*:

$$ d(x,z) \;\le\; \max\big(d(x,y),\, d(y,z)\big). $$

Read that again. The distance from $x$ to $z$ is no bigger than the *larger* of
the two legs — not their sum. A space where this holds is called an
**ultrametric space**. It is a place where, vividly, *every triangle is
isosceles*: the two longest sides of any triangle are always equal. There are
no "slightly longer" detours; geometry comes in sharp, discrete tiers.

This single inequality has a spectacular consequence, and it is the seed of
everything that follows.

## Why ultrametric spaces are secretly trees

Imagine drawing a "ball" of radius $r$ around a point — all the points within
distance $r$. In the everyday plane, two overlapping disks can intersect in a
little lens-shaped sliver: they partially overlap. In an ultrametric space,
**this is impossible**. Any two balls are either completely nested (one sits
entirely inside the other) or completely disjoint (they share nothing at all).
There is no in-between.

That "nested-or-disjoint" rule is exactly the rule that defines a **tree**.
Think of biological taxonomy: two species are either in the same genus or not;
genera nest inside families, families inside orders, and nothing straddles two
branches. The same goes for a file system's folders, or a corporate org chart.
Whenever objects organize into balls that are always nested or disjoint, they
are organizing into a branching hierarchy — a *dendrogram*.

The first pillar of this work makes that precise and proves it. Define two
items to be **in the same cluster at resolution $\varepsilon$** when their
ultrametric distance is at most $\varepsilon$:

$$ \mathrm{SameCluster}(\varepsilon,\,x,\,y) \iff d(x,y) \le \varepsilon. $$

Three facts, each a proven theorem, follow.

- **It is a genuine grouping.** At every resolution $\varepsilon \ge 0$, the
  same-cluster relation is an *equivalence relation*: every item clusters with
  itself; if $x$ clusters with $y$ then $y$ clusters with $x$; and — the crucial
  one — if $x$ clusters with $y$ and $y$ with $z$, then $x$ clusters with $z$.
  That last property, *transitivity*, is precisely the strong triangle
  inequality in disguise: $d(x,z) \le \max(d(x,y), d(y,z)) \le
  \max(\varepsilon,\varepsilon) = \varepsilon$. It would **fail** for ordinary
  distances — two friends each close to a common acquaintance need not be close
  to each other. In the ultrametric world they always are.

- **The clusters are exactly the balls.** The set of everything in the same
  cluster as $x$ at resolution $\varepsilon$ is precisely the closed ball of
  radius $\varepsilon$ around $x$. Clustering *is* drawing balls.

- **The tree is real.** Take any two cluster-balls, at any two resolutions.
  They are either nested or disjoint — never partially overlapping. So as you
  sweep the resolution $\varepsilon$ from large to small, coarse clusters split
  cleanly into finer sub-clusters, and the whole family of partitions stacks
  into a single rooted tree. Shrinking $\varepsilon$ *refines* the partition;
  growing it *merges* clusters. These are the levels of the hierarchy.

The punchline is striking: **no learning, no probability, and no training is
needed for the tree to exist.** It is forced into being by one inequality. The
moment you summarize attention scores p-adically — replacing "how big is this
score" with "how divisible by $p$ is it" — a hierarchical tree of clusters
materializes automatically. The geometry does the organizing for free.

## From attention scores to hierarchical trees

Why care about attention specifically? A transformer's attention mechanism
produces, for every token, a row of scores saying how much that token should
"listen to" every other token. These rows are the model's working memory of
relationships. Ordinarily we treat them as vectors in ordinary Euclidean space
and reason with dot products and softmaxes.

The proposal here is to **compress** each attention row through a p-adic
valuation: instead of recording the precise real-valued scores, record their
ultrametric summary — essentially, at what *scale* each relationship lives. By
the theorems above, those summaries don't just sit in a featureless cloud; they
fall into a dendrogram. Tokens that "attend at the same scale" land in the same
branch. Coarsening the resolution merges branches; refining it splits them.
Attention, viewed non-Archimedeanly, *is* a hierarchical clustering of context.

This is a faithful, lossless statement about geometry, not a heuristic. It
gives a rigorous substrate on which to ask the deeper dynamical question: as the
prompt grows longer and we zoom out, how does the model's error behave?

## The second pillar: everyone forgets the same way

Here is where renormalization enters. In physics, the renormalization group is
a recipe for *zooming out*: average over fine details, rescale, and watch how
the description of the system transforms. Repeat the zoom-out many times and the
system often drifts toward a **fixed point** — a description that no longer
changes under further zooming, and that has forgotten the microscopic details
it started with. Fixed points are why universality exists: many different
starting systems flow to the same destination.

Model the in-context-learning error the same way. Each time we double the prompt
length (one "zoom-out" step), the error transforms by a simple **affine**
rule — a multiply-and-add:

$$ \mathrm{rgStep}(g, b, x) \;=\; g\,x + b. $$

Here $x$ is the current error, $g$ is a *gain* (how much error survives one
rescaling), and $b$ is a *source term* — the irreducible contribution of the
handful of "relevant operators," the features that genuinely matter at large
scale. This little map carries a surprising amount of structure, and each claim
below is a proven theorem.

- **There is exactly one resting point.** The map has a unique fixed point,

  $$ x^\* \;=\; \mathrm{rgFixed}(g,b) \;=\; \frac{b}{1 - g}, $$

  the value that maps to itself: $g x^\* + b = x^\*$. This is the infrared
  (large-scale) destination of the flow — the error the model settles into once
  the prompt is long enough that microscopic accidents have washed out.

- **The flow has a clean closed form.** Apply the rescaling $n$ times and the
  distance to the fixed point shrinks geometrically, *exactly*:

  $$ \mathrm{rgStep}^{[n]}(x) - x^\* \;=\; g^{\,n}\,\big(x - x^\*\big). $$

  No approximation: the deviation from the fixed point is multiplied by $g$ at
  every step. This is the renormalization flow written out in full.

- **Every initialization converges.** Whenever the gain satisfies $|g| < 1$,
  the iterates $\mathrm{rgStep}^{[n]}(x)$ converge to $x^\*$ *for every starting
  error $x$ whatsoever*. The model's idiosyncratic starting point is forgotten.

- **Universality, made exact.** Take two models with different initializations
  and different training corpora — two different starting errors $x_1$ and
  $x_2$. Their *difference* under the flow is exactly $g^n (x_1 - x_2)$, which
  goes to zero. The two trajectories merge. After enough rescaling, you cannot
  tell which model you are looking at. This is the renormalization-group account
  of why rescaled learning curves collapse onto one another.

## The p-adic flow: contraction for free

The affine model above is the *Archimedean* (ordinary-real) picture, and it
requires the assumption $|g| < 1$ to converge. The p-adic picture is even
cleaner, because in the ultrametric world *contraction is built in*.

Take the renormalization step to be multiplication by the prime $p$ itself —
the "uniformizer" that generates the scale ladder. In ordinary arithmetic,
multiplying by $p$ makes a number bigger. In the p-adic metric it makes it
**smaller**, and by an exact, predictable amount:

$$ \big\| p^{\,n}\, x \big\|_p \;=\; p^{-n}\, \| x \|_p. $$

Each renormalization step shrinks the p-adic size by precisely a factor of
$1/p$. There is no free parameter to tune and no condition to check —
multiplication by $p$ is *intrinsically* contracting. Two consequences follow,
both proven.

- **Universal convergence to a universal fixed point.** The p-adic flow
  $x \mapsto p\,x$ drives every starting error to $0$, the unique fixed point,
  regardless of where it began.

- **Exact data collapse.** Normalize each model's error curve by its starting
  value. Then every model — every seed, every corpus, every width — produces the
  identical curve

  $$ n \;\longmapsto\; p^{-n}. $$

  Not approximately, not asymptotically: exactly. This is the sharpest possible
  form of the "curves collapse onto one master curve" phenomenon that motivated
  the whole investigation, and the critical exponent (the slope $\log_p$ of the
  collapse) is fixed by the prime alone.

## Why this matters

Put the two pillars together and a coherent picture emerges. **Geometry:**
attention, summarized p-adically, organizes the context into a rigid
hierarchical tree, with no learning required — the strong triangle inequality
alone forces the dendrogram into existence. **Dynamics:** the in-context error,
renormalized under prompt-length rescaling, flows to a universal fixed point
that forgets initialization and training corpus, and in the p-adic model
collapses exactly onto the master curve $p^{-n}$.

If this is the right skeleton for real transformers — and that is an empirical
question the theory is designed to make testable — the payoff is concrete.
Universality classes mean **scale transfer**: measure the critical exponents on
small, cheap models and predict the behavior of large, expensive ones, the same
way a physicist reads off bulk material properties from a universality class
without simulating every atom. The ultrametric tree gives a principled,
interpretable summary of what attention is actually doing — a hierarchy of
relationships rather than an inscrutable matrix. And the fixed-point structure
turns vague intuitions about "emergent scaling laws" into precise, falsifiable
predictions, with a clear refutation criterion: if no architecture-stable
universality class appears, or if the p-adic compression destroys the predictive
scaling structure, the conjecture fails.

What makes the story satisfying is how little it assumes. The tree is not
engineered; it is the shadow of a 100-year-old inequality from number theory.
The universality is not fitted; it is the inevitable fate of an affine flow with
a contracting gain. Three of the deepest currents in modern science —
renormalization from physics, ultrametric geometry from number theory, and
neural computation from machine learning — turn out to meet at a single point,
and at that point the mathematics is not just suggestive but **proven**. The
hidden trees inside a language model, and the universal way they all learn to
forget, are no longer a metaphor. They are theorems.
