# The Hidden Simplicity of Family Trees in Random Networks

Imagine a growing web of dependencies. It could be a citation network, where
each new paper cites a handful of older ones; a software project, where each new
module builds on a few existing components; or the intricate wiring of a
biological pathway. In every case we have a *directed acyclic graph* (a DAG): a
collection of points, called vertices, joined by one-way arrows that never form a
loop. Each arrow says "this depends on that," and the no-loops rule guarantees
that nothing, however indirectly, depends on itself.

A natural way to model such networks as they grow is the **random $d$-DAG**. We
add vertices one at a time, numbering them $1, 2, 3, \dots$. When vertex $n$
arrives, it reaches back and attaches to exactly $d$ of the earlier vertices,
chosen at random. The parameter $d$ is fixed once and for all — every newcomer
makes the same number $d$ of choices. This single rule generates a rich, evolving
family tree whose statistical properties have surprising structure.

This article is about one such property: the **joint descendants of the last few
vertices**. It turns out that a question which looks hopelessly tangled — how
many future vertices will end up depending, simultaneously, on several of the
most recent arrivals? — is governed by an identity of almost startling
cleanness. A long product of interacting probabilities collapses, term by term,
into a single ratio involving only its endpoints.

## Descendants, ancestors, and the question we ask

Fix a vertex $v$. Its **descendants** are all the later vertices that can reach
back to $v$ by following arrows — the "intellectual heirs" of $v$, the modules
that ultimately rest on it, the reactions downstream of it. Symmetrically, the
**ancestors** of $v$ are the vertices $v$ itself depends on, directly or through
a chain.

Now here is the twist. Instead of tracking the descendants of a single vertex,
we watch the *last $k$ vertices* to enter the graph — vertices
$n, n+1, \dots, n+k-1$ — and we ask for their **common descendants**: the future
vertices that will depend on *all* of them at once. As the graph keeps growing to
enormous size, how large does this shared family become?

The answer has two parts. First, the shared family does grow without bound, but
slowly: its size scales like $n^{d/(d+1)}$, a fractional power of $n$ dictated
entirely by the branching number $d$. Divide the count by $n^{d/(d+1)}$ and the
fluctuations settle down: the rescaled size **converges in distribution** to a
genuine, non-degenerate random variable — one that never collapses to a single
predictable value, but also never runs off to infinity.

Second, and more beautifully, that limiting random variable has an explicit
description. It can be written as a **product of independent Beta random
variables**, or equivalently through ratios of independent **Gamma random
variables**. The purpose of this article is to explain *why* products of Betas
appear, and to reveal the elegant algebraic identity that makes the whole picture
computable.

## From growing graphs to Pólya urns

Why should Beta distributions have anything to do with counting descendants in a
random graph? The bridge is a classical device from probability: the **Pólya
urn**.

Picture an urn with balls of several colors. At each step you draw a ball, look
at its color, and return it together with extra balls of the same color. Colors
that get ahead early tend to stay ahead — success breeds success. The remarkable
classical fact is that the *long-run proportions* of the colors do not converge
to fixed numbers; they converge to **random** proportions, and those random
proportions follow a **Beta** (or, with several colors, a **Dirichlet**)
distribution.

The ancestry structure of a random $d$-DAG hides exactly such an urn. As the
graph grows, whether a new vertex lands "below" the group of watched vertices
behaves like drawing from an urn whose composition is reinforced at every step.
Tracking $k$ watched vertices at once requires a *multi-draw* urn — each newcomer
makes $d$ simultaneous choices — and chaining these urns through time produces
not one Beta variable but a **product** of them. This is the origin of the limit
law. The case $k = 2$ was understood through precisely this ancestry-process and
multi-draw-urn analysis; the story here is what makes the generalization to every
$k$ work.

## The moment miracle

To identify a limiting random variable, probabilists reach for its **moments**:
the averages $\mathbb{E}[X^p]$ of its powers. Get all the moments and, under mild
conditions, you have pinned down the distribution completely.

So consider a product of independent Beta variables. Recall that a **Beta$(\alpha,
\beta)$** random variable $B$ lives on the interval $[0,1]$, and its moments are
given by a neat ratio of **Gamma functions**:
$$
\mathbb{E}[B^p] \;=\; \frac{\Gamma(\alpha + p)\,\Gamma(\alpha + \beta)}
{\Gamma(\alpha)\,\Gamma(\alpha + \beta + p)} .
$$
Here $\Gamma$ is the Gamma function, the smooth interpolation of the factorial:
$\Gamma(n) = (n-1)!$ for whole numbers, and $\Gamma(x+1) = x\,\Gamma(x)$ for all
$x$.

Now take a whole chain of independent Beta variables $B_0, B_1, \dots, B_{n-1}$,
where $B_j \sim \text{Beta}(\alpha_j, \beta_j)$, and form their product
$P = B_0 B_1 \cdots B_{n-1}$. Because the factors are independent, the $p$-th
moment of the product is the product of the moments:
$$
\mathbb{E}[P^p] \;=\; \prod_{j=0}^{n-1}
\frac{\Gamma(\alpha_j + p)\,\Gamma(\alpha_j + \beta_j)}
{\Gamma(\alpha_j)\,\Gamma(\alpha_j + \beta_j + p)} .
$$
At first sight this is a fearsome object: a long product of Gamma ratios, growing
more complicated with every extra factor.

But the parameters coming out of the ancestry urns are not arbitrary. They
satisfy a single **chaining condition**:
$$
\alpha_{j+1} \;=\; \alpha_j + \beta_j \qquad \text{for every } j.
$$
In words: the *total* concentration of one stage becomes the *leading*
concentration of the next. And with this one condition, the entire product
collapses.

> **The Beta-Moment Telescoping Theorem.** *If the parameters chain additively,
> $\alpha_{j+1} = \alpha_j + \beta_j$ for all $j$, then*
> $$
> \prod_{j=0}^{n-1}
> \frac{\Gamma(\alpha_j + p)\,\Gamma(\alpha_j + \beta_j)}
> {\Gamma(\alpha_j)\,\Gamma(\alpha_j + \beta_j + p)}
> \;=\;
> \frac{\Gamma(\alpha_0 + p)\,\Gamma(\alpha_n)}
> {\Gamma(\alpha_0)\,\Gamma(\alpha_n + p)} .
> $$

Every intermediate parameter — $\alpha_1, \alpha_2, \dots, \alpha_{n-1}$, along
with all the $\beta_j$ — vanishes from the answer. Only the *first* parameter
$\alpha_0$ and the *last* parameter $\alpha_n$ survive. An apparently
high-dimensional tangle of dependent stages is governed by nothing more than its
two endpoints.

Read the right-hand side again: it is exactly the $p$-th moment formula of a
single Beta variable, one with parameters $\alpha_0$ and $\beta = \alpha_n -
\alpha_0$. So the theorem says something wonderfully concrete: **a chained
product of independent Beta variables is, in its moments, indistinguishable from
one single Beta variable.** The chain telescopes into a point.

## Why it telescopes

The proof is a small marvel of rearrangement, and it rests on two ideas.

**First idea: turn each factor into a ratio of endpoints.** Introduce the
shorthand $f(x) = \Gamma(x + p)/\Gamma(x)$. Using the chaining condition
$\alpha_j + \beta_j = \alpha_{j+1}$, a single factor of the product can be
rewritten as
$$
\frac{\Gamma(\alpha_j + p)\,\Gamma(\alpha_j + \beta_j)}
{\Gamma(\alpha_j)\,\Gamma(\alpha_j + \beta_j + p)}
\;=\;
\frac{f(\alpha_j)}{f(\alpha_{j+1})} .
$$
This is pure algebra: expand $f(\alpha_j) = \Gamma(\alpha_j+p)/\Gamma(\alpha_j)$
and $f(\alpha_{j+1}) = \Gamma(\alpha_{j+1}+p)/\Gamma(\alpha_{j+1})$, substitute
$\alpha_{j+1} = \alpha_j + \beta_j$, and the Gamma factors line up.

**Second idea: telescope.** A product of consecutive ratios collapses like a
folding spyglass:
$$
\prod_{j=0}^{n-1} \frac{f(\alpha_j)}{f(\alpha_{j+1})}
\;=\; \frac{f(\alpha_0)}{f(\alpha_1)} \cdot \frac{f(\alpha_1)}{f(\alpha_2)}
\cdots \frac{f(\alpha_{n-1})}{f(\alpha_n)}
\;=\; \frac{f(\alpha_0)}{f(\alpha_n)} .
$$
Every $f(\alpha_j)$ for $0 < j < n$ appears once in a numerator and once in a
denominator, and cancels. Substituting back $f(\alpha_0)/f(\alpha_n) =
\big(\Gamma(\alpha_0+p)/\Gamma(\alpha_0)\big) / \big(\Gamma(\alpha_n+p)/
\Gamma(\alpha_n)\big)$ gives exactly the claimed endpoint formula.

There is one subtlety worth flagging, because it is the kind of thing that is
easy to miss and fatal to ignore. The telescoping requires that none of the
intermediate quantities $\Gamma(\alpha_j + p)$ vanish. The Gamma function is
never zero for positive arguments, so for genuine Beta parameters this is
automatic — but if one were to plug in arguments where an interior
$\Gamma(\alpha_j + p)$ hit zero, the left-hand product would collapse to $0$ while
the right-hand side stayed positive, and the identity would fail. The clean
statement therefore carries the mild non-vanishing proviso, and with it the
identity holds exactly.

There is also a companion identity that makes everything computable by hand for
whole-number shifts. For any positive integer $m$,
$$
\frac{\Gamma(x + m)}{\Gamma(x)} \;=\; \prod_{i=0}^{m-1} (x + i)
\;=\; x\,(x+1)\cdots(x+m-1),
$$
the *rising factorial*. This turns Gamma ratios into ordinary polynomial
products and is what lets us verify the telescoping numerically to the last
digit.

## The scaling exponent, demystified

The same rising-factorial identity explains where the mysterious exponent
$d/(d+1)$ comes from. The *average* size of the descendant set of a single late
vertex obeys a simple multiplicative recursion as the graph grows, and the
solution to that recursion is precisely a ratio of rising factorials. Estimating
how such a ratio grows — a standard exercise in comparing a sum of logarithms to
an integral — shows that the mean size grows like a constant times $n^{d/(d+1)}$,
with matching bounds above and below. The exponent is not the fingerprint of some
delicate random fluctuation; it is simply the leading term in the asymptotics of
a Pochhammer (rising-factorial) ratio. The randomness lives in the *fluctuations*
around this mean — and those fluctuations are what the product-of-Betas limit
law describes.

## When the family collapses to one

One more phenomenon rounds out the picture, and it is purely about order. The
descendants of a vertex are exactly the "lower set" of that vertex in the
reachability ordering of the graph. Intersecting the descendant sets of several
vertices therefore behaves like intersecting lower sets — and such an
intersection collapses to a single one of them precisely when the generating
vertices are **totally ordered by reachability**, i.e. they form a chain. If even
one link is missing — if two of the watched vertices are incomparable, neither
reachable from the other — then the common-descendant set is *strictly smaller*
than each individual descendant set. The chaining condition on the urn parameters
is the algebraic shadow of this order-theoretic chain condition, and it is sharp:
break the chain at one index and the collapse fails.

## Why it matters

At the level of ideas, this is a story about **emergent simplicity**. A random
process — vertices arriving, each grabbing $d$ ancestors at random — produces a
family structure that looks intractably complex. Yet its statistics are ruled by
one clean law: independence plus additive chaining forces a long product to
telescope, and a whole cascade of dependent stages behaves like a single stage.
The high-dimensional problem has an essentially one-dimensional soul.

At the level of applications, random $d$-DAGs are a workhorse model for citation
graphs, dependency graphs, and preferential-attachment networks. Knowing how the
*shared* downstream influence of several recent nodes grows — and knowing its
exact limiting distribution — sharpens our understanding of how influence
concentrates in growing networks. The telescoping identity is also a reusable
tool in its own right: any time independent Beta (or Dirichlet) stages chain
additively, their combined moments simplify to their endpoints, whether the
setting is Bayesian statistics, population genetics, or the analysis of
randomized algorithms.

The moral is one that recurs throughout mathematics. Complexity is often a matter
of perspective. Find the right variable, impose the one natural condition the
system already satisfies, and a forbidding product folds up in your hands —
leaving behind only where you started and where you ended.
