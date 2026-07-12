# How Many Descendants? The Hidden Gamma Law of Growing Networks

Imagine a network that grows one node at a time. The first few nodes are the
founders. Every newcomer arrives and immediately reaches back into the past,
picking a fixed number of older nodes to point to — its parents. Over time this
simple rule builds a sprawling web of ancestry: from any single node, a cascade
of descendants fans out through the generations that follow. How large does that
cascade become?

This is not an idle question. The same growth rule describes the spread of a
scientific idea through a citation network, the propagation of a software
dependency through a package ecosystem, the diffusion of a rumor through a social
graph, and the branching of lineages in a family tree. In each case a founding
event casts a shadow of consequences, and the size of that shadow — the number of
descendants — is what we would like to predict.

The remarkable answer is that the number of descendants is not just some
featureless growing quantity. When rescaled correctly, it settles into one of the
most beloved shapes in all of probability: the **Gamma distribution**. This
article tells the story of why.

## The model: a network that only looks backward

Fix an integer $d \ge 2$, the *out-degree*. We build a directed acyclic graph
$G_n$ on the vertices $1, 2, \dots, n$ as follows. The first $d$ vertices are seeds.
Every later vertex $v > d$ chooses $d$ distinct earlier vertices, uniformly at
random, and draws an edge to each of them. Because every edge points from a
larger label to a smaller one, the graph can never contain a cycle — hence
*directed acyclic graph*, or **DAG**. We call this the **random recursive
$d$-DAG**.

Now fix a founding vertex and ask for its **descendant set** $D_n$: all vertices
that can reach it by following edges backward, i.e., everyone whose ancestry
traces back to the founder. The quantity of interest is the *count* $|D_n|$, and
we want to understand how it behaves as the network grows, $n \to \infty$.

## The first surprise: growth is sublinear

Your intuition might say that in a network of $n$ nodes, a founder's descendants
should number some fixed *fraction* of $n$ — a quantity growing linearly. That
intuition is wrong for $d \ge 2$.

To see why, track the *expected* number of descendants. When vertex $k$ arrives,
it becomes a descendant of the founder exactly when at least one of its $d$
random parents is already a descendant. Working through the bookkeeping, the
expected descendant count is governed by a clean multiplicative object. Define the
**mean-growth product**
$$P_n(a) = \prod_{k=1}^{n}\left(1 + \frac{a}{k}\right),$$
where the growth rate is $a = 1/d$. Each factor $1 + a/k$ records the small extra
push that step $k$ gives to the expected descendant count. The product $P_n(1/d)$
turns out to be the exact normalization that controls $|D_n|$.

How fast does this product grow? Here is the key identity, proved exactly:
$$P_n(a) = \frac{\Gamma(n+1+a)}{\Gamma(1+a)\,n!},$$
where $\Gamma$ is the Gamma function, the continuous cousin of the factorial with
$\Gamma(m+1) = m!$ for integers. This closed form is a small miracle: an infinite
family of finite products collapses into a single ratio of Gamma values. From it,
a classical asymptotic estimate gives the punchline:
$$\frac{P_n(a)}{n^{a}} \longrightarrow \frac{1}{\Gamma(1+a)} \qquad (n \to \infty).$$
In words: the mean-growth product grows like $n^{a}$, up to the explicit constant
$1/\Gamma(1+a)$. Substituting $a = 1/d$, we learn that a founder in a random
$d$-DAG accumulates descendants at the rate
$$|D_n| \sim \frac{n^{1/d}}{\Gamma(1 + 1/d)}.$$

So for $d = 2$ the descendant count grows like $\sqrt{n}$; for $d = 3$ like the
cube root of $n$; and in general like $n^{1/d}$ — dramatically slower than linear.
The more parents each newcomer must find, the harder it is for any single lineage
to dominate, and the more the founder's influence is diluted. The scaling
exponent $1/d$ is the precise measure of that dilution.

## The second surprise: the shape is always Gamma

Knowing the *scale* of $|D_n|$ is only half the story. The deeper question is its
*shape*: once we divide out the $n^{1/d}$ growth, does the random quantity
$|D_n|/n^{1/d}$ wander without settling, or does it converge to a fixed
distribution?

It converges — and the limit is the **Gamma distribution with shape parameter
$d$ and rate $1$**, written $\mathrm{Gamma}(d,1)$. This is a continuous
probability law on the positive half-line $(0, \infty)$ with density
$$f_d(x) = \frac{e^{-x}\,x^{\,d-1}}{\Gamma(d)}.$$
The factor $x^{d-1}$ pulls the distribution away from zero (a founder almost
surely has *some* descendants), while $e^{-x}$ guarantees a light tail (runaway
lineages are exponentially unlikely). Dividing by $\Gamma(d)$ makes the total
probability exactly one — a fact one can verify directly, since
$$\int_0^\infty \frac{e^{-x}\,x^{\,d-1}}{\Gamma(d)}\,dx
= \frac{1}{\Gamma(d)}\int_0^\infty e^{-x}\,x^{\,d-1}\,dx
= \frac{\Gamma(d)}{\Gamma(d)} = 1,$$
using the integral definition of the Gamma function itself.

That $\mathrm{Gamma}(d,1)$ appears here is beautiful for a structural reason. The
shape parameter that emerges is exactly the out-degree $d$ — the very number of
parents each vertex must choose. The geometry of the growth rule is written
directly into the shape of the limiting law.

## How you prove a shape: the method of moments

How does one prove that a rescaled random quantity converges to a *specific*
continuous distribution? A distribution is an infinitely detailed object; you
cannot check it pointwise. The classical strategy is the **method of moments**.

The $p$-th moment of a distribution is the average value of $x^p$. For the
$\mathrm{Gamma}(d,1)$ law, a direct computation gives an elegant formula:
$$m_p = \int_0^\infty x^p\,\frac{e^{-x}x^{d-1}}{\Gamma(d)}\,dx
= \frac{\Gamma(d+p)}{\Gamma(d)}.$$
These moments obey a simple recurrence,
$$m_{p+1} = (d+p)\,m_p,$$
which starts from $m_0 = 1$ and, for whole-number exponents, unrolls into a
**rising factorial**:
$$m_k = \prod_{i=0}^{k-1}(d+i) = d\,(d+1)\,(d+2)\cdots(d+k-1).$$
In particular the mean is $m_1 = d$ and the variance is $m_2 - m_1^2 = d(d+1) -
d^2 = d$. For the Gamma$(d,1)$ law, mean and variance coincide, both equal to the
shape parameter — a clean fingerprint.

The strategy is then to show that the moments of the *network* quantity
$|D_n|/n^{1/d}$ converge, one by one, to these rising factorials $\prod_{i<k}(d+i)$.
Because the Gamma distribution is *determined* by its moments — its moments do not
grow too fast, so no other distribution can share them all — matching every
moment forces convergence to the Gamma law itself. The moment recurrence
$m_{p+1} = (d+p)m_p$ is the linchpin: it is exactly the identity a limit
distribution must satisfy, and it is exactly what the combinatorics of the
growing DAG produces.

## The boundary case: $d = 1$ and the random recursive tree

What happens at the edge of the model, when $d = 1$? Then every newcomer picks a
single parent, and the DAG becomes a **tree** — the classical *random recursive
tree*. Here the mean-growth product is taken with $a = 1$, and it collapses to
something almost comically simple:
$$P_n(1) = \prod_{k=1}^n\left(1 + \frac{1}{k}\right)
= \frac{2}{1}\cdot\frac{3}{2}\cdot\frac{4}{3}\cdots\frac{n+1}{n} = n+1.$$
The telescoping product leaves only $n+1$. So descendants grow **linearly**,
$P_n(1)/n \to 1$, and the scaling exponent is $1$ — exactly the value $1/d$ gives
at $d = 1$. The boundary case fits the general pattern seamlessly, even though its
qualitative behavior (linear, not sublinear) is entirely different. It is a
reassuring consistency check: the single formula $n^{1/d}$ knows about both the
trees and the DAGs.

## Why it matters

The story here is a microcosm of what makes probability theory powerful. A rule
of almost childish simplicity — "each newcomer points to $d$ random elders" —
generates, through the accumulation of countless small random choices, a limit
that is precise, universal, and independent of the messy details. Whether you are
modeling how a foundational paper accrues citations, how an early software library
becomes a load-bearing dependency, or how an ancestral gene propagates through
generations, the same two numbers govern the outcome: the growth exponent $1/d$
and the Gamma shape $d$.

Two quantities, both equal to the same structural constant $d$, emerge from pure
randomness. That is the quiet elegance at the heart of growing networks: chaos at
the level of individual choices, order at the level of the whole.
