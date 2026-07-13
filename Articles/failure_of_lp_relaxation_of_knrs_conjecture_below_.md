# When "Dense" Is Not Enough: A Threshold That Isn't What It Seems

## A promise hidden inside randomness

Scatter a large random graph on $N$ vertices, joining each pair independently with
probability $\rho$. Now zoom in on any patch of it — any subset $S$ of the vertices.
On average, a $\rho$-fraction of the possible edges inside $S$ will be present. This
is the defining charm of randomness: it looks the same everywhere, at every scale.

But randomness is expensive and fragile. A more robust idea is to ask only for the
*symptom* of randomness rather than its full mechanism. Call a graph **$\rho$-locally
dense** if every patch $S$ carries at least its fair share of edges — at least a
$\rho$-fraction of the pairs inside $S$, no matter which $S$ you pick. Random graphs
satisfy this, but so do many highly structured, deliberately engineered graphs. Local
density is a promise about *every* window into the graph, and it turns out to be a
surprisingly powerful promise.

In 2010, Kohayakawa, Nagle, Rödl, and Schacht made that power precise with a bold
conjecture: **a $\rho$-locally dense host must contain at least as many copies of any
fixed pattern $F$ as a truly random graph would** — at least the "random count"
$\rho^{e(F)}$, where $e(F)$ is the number of edges in the pattern. In other words,
the mere symptom of randomness should already force the same abundance of triangles,
squares, matchings, and every other small structure that genuine randomness produces.

This article is about a single, sharp question that grew out of that conjecture — and
about a clean formula that looked exactly right, passed its first test perfectly, and
then turned out to be dramatically wrong.

## From counting to norms: the $L^p$ relaxation

To study "how many copies of $F$" a weighted host contains, it is convenient to pass
from finite graphs to their limit objects, **graphons**. A graphon is simply a
symmetric function
$$W : [0,1]^2 \to [0,1],$$
which you should picture as an infinitely fine weighted adjacency matrix: $W(x,y)$ is
the "density of connection" between points $x$ and $y$. Local density becomes the
clean integral statement
$$\int_{S\times S} W \;\ge\; \rho\,|S|^2 \qquad \text{for every measurable } S,$$
and the abundance of a pattern $F$ with edge set $E(F)$ is measured by the
homomorphism density
$$t(F,W) = \int \prod_{\{i,j\}\in E(F)} W(x_i,x_j)\, \prod_i dx_i .$$

The conjecture asserts $t(F,W)\ge \rho^{e(F)}$ for every $\rho$-locally dense $W$.

There is a natural way to *sharpen* the difficulty of this question. Instead of the
plain product, weight each edge by a power $p$ and take the $p$-th root. This produces
the **$L^p$ pattern norm**
$$\|W_F\|_{L^p} = \left(\int \prod_{\{i,j\}\in E(F)} W(x_i,x_j)^p \, \prod_i dx_i\right)^{1/p}.$$
At $p=1$ this is exactly the classical homomorphism density $t(F,W)$. As $p$ shrinks
toward $0$, the norm rewards spreading weight thinly and punishes concentration, so it
becomes *easier* to push the norm below the random target $\rho^{e(F)}$. The
$L^p$ relaxation of the conjecture asks the crisp question:

> For which exponents $p$ can a $\rho$-locally dense graphon $W$ achieve
> $\|W_F\|_{L^p} < \rho^{e(F)}$?

Below some threshold in $p$, local density is too weak to forbid it; above the
threshold, it wins. Where exactly is the line?

## A tempting formula

Here is the formula that motivated everything. For a pattern $F$ with $m$ edges and
$n$ non-isolated vertices, count the maximum possible number of edges among those $n$
vertices — that is $\binom{n}{2}$ — and compare it to the number $m$ that $F$ actually
uses. The proposed threshold was
$$p^\star(F) \stackrel{?}{=} \frac{\binom{n}{2}}{m},$$
with the claim that **for every $p$ below this value, a locally dense counterexample
exists**: some $\rho$-locally dense $W$ with $\|W_F\|_{L^p} < \rho^{e(F)}$.

It is a beautiful guess. It is dimensionally sensible, it is easy to compute, and — as
we will see — it is *exactly correct in the first case anyone would check*. That is
precisely what makes its later failure instructive.

## The single edge: the formula is perfect

Start with the simplest possible pattern, a single edge $F = K_2$. Here $n=2$, $m=1$,
$e(F)=1$, and the formula predicts the threshold
$$p^\star(K_2) = \frac{\binom{2}{2}}{1} = 1.$$

Both halves of this prediction are true, and provably sharp.

**Above the line, local density wins.** For every exponent $p \ge 1$, *no*
counterexample exists: every nonnegative $\rho$-locally dense graphon satisfies
$$\|W_{K_2}\|_{L^p} \ge \rho.$$
The reason is a single application of the power-mean inequality. Local density on the
*whole* vertex set says the average value of $W$ is at least $\rho$. For $p\ge 1$ the
$L^p$ average dominates the ordinary average, so
$$\|W_{K_2}\|_{L^p} = \big(\text{average of } W^p\big)^{1/p} \ge \text{average of } W \ge \rho.$$
Concentration cannot help you here; raising to a power $p\ge1$ only inflates the norm.

**Below the line, a concrete graphon breaks through.** For every $0<p<1$ there is an
explicit counterexample — and it is embarrassingly simple. Split $[0,1]$ into two equal
halves and place a graphon that is $2\rho$ inside each half and $0$ between them:
$$W = \begin{pmatrix} 2\rho & 0 \\ 0 & 2\rho \end{pmatrix}.$$
Every patch $S$ still sees average density at least $\rho$ (the concentrated mass on
the diagonal blocks exactly compensates the empty off-diagonal), so $W$ is genuinely
$\rho$-locally dense and its values lie in $[0,1]$ as long as $2\rho\le 1$. Yet a short
computation gives
$$\|W_{K_2}\|_{L^p} = \rho \cdot 2^{\,1 - 1/p}.$$
For $p<1$ the exponent $1-\tfrac1p$ is negative, so $2^{1-1/p}<1$ and the norm dips
strictly below $\rho$. The concentration that $L^p$ rewards is achieved by dumping all
the weight onto the diagonal blocks.

So for the single edge the threshold is exactly $p=1$, precisely as the formula
predicts. First test passed, flawlessly.

## The two-edge matching: the formula shatters

Now take the next-simplest pattern: two *disjoint* edges, the matching $M_2$. It has
$n=4$ non-isolated vertices, $m=2$ edges, and $e(F)=2$. The formula now predicts
$$p^\star(M_2) \stackrel{?}{=} \frac{\binom{4}{2}}{2} = \frac{6}{2} = 3.$$
So the claim is that for *every* $p<3$ — including the very ordinary $p=2$ — a locally
dense counterexample should exist.

It does not. The true threshold is **$1$, not $3$**.

The reason is a factorization so clean it feels like a magic trick. Because the two
edges of $M_2$ share no vertices, the four integration variables split into two
independent pairs, and the pattern norm simply factorizes:
$$\|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^{\,2}.$$
Two disjoint edges are, for this purpose, just one edge counted twice. Everything we
proved about the single edge now transfers verbatim by squaring. For $p\ge 1$ we
already know $\|W_{K_2}\|_{L^p}\ge \rho$, so
$$\|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^{2} \ge \rho^2 = \rho^{e(M_2)}.$$
No counterexample can exist anywhere on the interval $1 \le p < 3$. The formula's
promised counterexamples in that entire range are phantoms. And below $p=1$ the same
two-block graphon as before, now squared, gives a genuine counterexample, so the
threshold for $M_2$ is exactly $1$.

The predicted $3$ and the true $1$ differ by a factor of three. The formula didn't miss
by a rounding error — it missed by the whole structure of the problem.

## What the formula forgot: connectivity

Why was $\binom{n}{2}/m$ so wrong? Because it counts vertices as if they all had to be
squeezed into a single tangled cluster, when in fact a pattern can be *spread across
independent pieces*. The corrected threshold that block constructions actually reach is
$$\frac{n - c}{m},$$
where $c$ is the number of connected components of the pattern. The quantity $n-c$ is
the number of edges in a spanning forest of $F$: it counts the truly *binding*
constraints, the edges you cannot remove without disconnecting something, rather than
the vast number of edges the vertices could in principle support.

The construction behind this is the same two-block idea, generalized to $k$ blocks: put
weight $k\rho$ on each of the $k$ diagonal blocks and nothing between them. For the
pattern to survive, every connected component must collapse into a single block, which
happens with probability governed by exactly $n-c$ independent choices. Carrying out
the computation, the $k$-block graphon achieves
$$\|W_F\|_{L^p} = \rho^{m}\, k^{\,m - (n-c)/p},$$
which drops below $\rho^{e(F)}=\rho^m$ precisely when $p < (n-c)/m$. Sending $k\to\infty$
makes the violation as strong as one likes.

For the single edge and the matching alike, $(n-c)/m = 1$, which is why both have true
threshold $1$. But the two formulas can disagree without bound. For a matching with $k$
edges we have $n=2k$, $m=k$, $c=k$, so the honest threshold is
$$\frac{n-c}{m} = \frac{2k-k}{k} = 1,$$
while the tempting formula screams
$$\frac{\binom{2k}{2}}{k} = 2k-1 \longrightarrow \infty.$$
The gap between the guess and the truth grows without limit across the matching family.
The original formula was not merely off by a constant; it was measuring the wrong
quantity.

## The moral

This little story is a compact parable about mathematical intuition. A formula can be
elegant, dimensionally reasonable, and *exactly right on the first example you try*,
and still be fundamentally mistaken — because that first example was too symmetric to
reveal what the formula was quietly ignoring. Here the blind spot was connectivity: the
difference between a pattern that must be woven into one cluster and a pattern that
happily falls apart into independent pieces.

What survives is sharper than what was conjectured. For the single edge the threshold
is exactly $1$ and provably so on both sides. For every matching the threshold is
exactly $1$, collapsing a predicted value that raced off to infinity. And in general
the honest candidate threshold is $(n-c)/m$, a quantity that knows about the shape of
the pattern, not just its vertex count.

The next chapters of the story are wide open. Is $(n-c)/m$ the exact threshold for
*every* pattern, or is it merely what the simple block constructions can reach? The
triangle is the first genuine test: block kernels give counterexamples only for
$p<2/3$, but nobody yet knows whether cleverer, smoothly varying "rank-one" graphons —
of the form $W(x,y) = \rho + c\,\varphi(x)\varphi(y)$, which are automatically locally
dense — can push past that line. Somewhere between $2/3$ and $1$, for the humble
triangle, the truth is still hiding.
