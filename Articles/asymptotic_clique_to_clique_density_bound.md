# The Democracy of Cliques: How Triangles Constrain Tetrahedra

## A question hidden in every network

Picture any network you like: a social graph where people are dots and
friendships are lines, a molecule where atoms bond to atoms, or the tangle of
routers that carries this very sentence to your screen. Mathematicians strip all
of these down to the same bare object, a **graph**: a set of $n$ *vertices*
together with a set of *edges* joining some pairs of them.

Inside every such graph live little islands of total connectivity called
**cliques**. A clique of size $r$ — an *$r$-clique* — is a group of $r$ vertices
in which *every* pair is joined by an edge. A $2$-clique is just an edge. A
$3$-clique is a triangle. A $4$-clique is a tetrahedron, four mutual friends who
all know one another. Cliques are the atoms of "togetherness" in a network, and
counting them is one of the oldest games in graph theory.

Write $k_r(G)$ for the number of $r$-cliques in a graph $G$. A natural, almost
childlike question is this: **if I know how many edges a network has, what can I
say about how many triangles it must contain? How many tetrahedra? And more
generally, how do the clique counts of different sizes constrain one another?**

This article is about a clean, complete answer to one half of that question — an
answer that turns out to be a statement of surprising democratic fairness among
cliques of every size.

## Two graphs, two extremes

To feel the tension in the question, compare two networks with the same number of
edges.

The first is a **single dense blob**: take $k$ vertices and connect *all* of
them to one another. This is the *complete graph* $K_k$. It is a solid diamond of
connectivity — it contains every possible clique. Out of $k$ vertices you can
choose any $r$ of them and they automatically form an $r$-clique. So $K_k$ is,
in a precise sense, *maximally cliquey*.

The second is a network of the same size that is spread thin — say a long cycle,
or a bipartite graph split into two camps with edges only between them. A
bipartite graph has plenty of edges but **not a single triangle**, because a
triangle would need three mutual neighbors and the two-camp rule forbids it.

So the same "edge budget" can buy you a fortress bursting with cliques of every
size, or a sprawling structure with none above size two. The interesting
mathematics lives in the *ratios*: not how many cliques there are in absolute
terms, but how the count of large cliques compares to the count of small ones.

## The right yardstick: realized fractions

Here is the key idea that makes everything click into place. Instead of asking
"how many $r$-cliques does $G$ have?", ask **"what fraction of the $r$-cliques
that could possibly exist actually do?"**

In a graph on $n$ vertices, the number of *potential* $r$-cliques — the number of
ways to pick $r$ vertices at all, connected or not — is the binomial coefficient
$$\binom{n}{r} = \frac{n!}{r!\,(n-r)!}.$$
Each of those vertex sets either is a clique or is not. So the honest measure of
"how cliquey is $G$ at scale $r$" is the **normalized clique density**
$$d_r(G) \;=\; \frac{k_r(G)}{\binom{n}{r}},$$
a number between $0$ and $1$: the fraction of possible $r$-cliques that $G$
actually realizes. For the complete graph $K_n$ every possible set *is* a clique,
so $d_r(K_n) = 1$ for all $r$. For a triangle-free graph, $d_3 = 0$.

With this yardstick in hand, the central discovery of this work can be stated in
a single sentence.

> **The realized fraction of cliques never increases as the cliques get bigger.**

That is, for any graph and any two sizes $s \le t$,
$$d_t(G) \;\le\; d_s(G), \qquad\text{i.e.}\qquad \frac{k_t(G)}{\binom{n}{t}} \;\le\; \frac{k_s(G)}{\binom{n}{s}}.$$
Big cliques are always *rarer, relative to their own possibilities*, than small
ones. A network might realize $40\%$ of its potential edges, but it can then
realize *at most* $40\%$ of its potential triangles, at most that fraction of its
tetrahedra, and so on down the line. Density can only leak away as you climb to
higher-order structure; it can never spontaneously concentrate.

This is what I mean by the *democracy of cliques*: no graph can be
disproportionately generous to its large cliques at the expense of its small
ones. The small cliques always vote first, and they cap what the big ones can do.

## The exact accounting behind it

The beautiful thing is that this monotonicity is not an approximation, not an
asymptotic slogan true only for enormous graphs. It follows from an **exact
counting identity** that holds for every finite graph, and the argument is short
enough to sketch here in full.

Fix two sizes $s < t$. We will count one thing in two different ways — the
oldest trick in combinatorics, and still one of the most powerful. The thing we
count is the number of **flags**: pairs $(S, T)$ where $S$ is an $s$-clique, $T$
is a $t$-clique, and $S$ sits inside $T$.

**Counting flags from the top down.** Start with a $t$-clique $T$. How many
$s$-cliques does it contain? Because $T$ is complete — every pair inside it is an
edge — *any* $s$ of its vertices automatically form an $s$-clique. So the number
of sub-$s$-cliques of $T$ is exactly the number of ways to choose $s$ of its $t$
vertices, namely $\binom{t}{s}$. Summing over all $t$-cliques, the total number
of flags is
$$\binom{t}{s}\, k_t(G).$$

**Counting flags from the bottom up.** Now start with an $s$-clique $S$. How many
$t$-cliques can contain it? To grow $S$ into a $t$-clique we must add $t - s$ new
vertices, and those new vertices can only come from the $n - s$ vertices outside
$S$. In the very best case — every such extension actually being a clique — the
number of valid extensions is at most the number of ways to choose the extra
vertices, $\binom{n-s}{t-s}$. Summing over all $s$-cliques, the total number of
flags is *at most*
$$\binom{n-s}{t-s}\, k_s(G).$$

Since both expressions count the same flags, the first must be no larger than the
second:
$$\boxed{\;\binom{t}{s}\, k_t(G) \;\le\; \binom{n-s}{t-s}\, k_s(G).\;}$$

That single inequality is the engine of everything. It says the number of large
cliques is controlled — with explicit, universal binomial constants — by the
number of small ones.

To reach the clean density statement, feed in one classical identity relating
binomial coefficients, the "subset of a subset" rule
$$\binom{n}{t}\binom{t}{s} \;=\; \binom{n}{s}\binom{n-s}{t-s},$$
which just says that choosing $t$ things and then $s$ of them is the same as
choosing $s$ things and then $t-s$ more. Substituting this into the boxed
inequality and cancelling the common positive factor $\binom{t}{s}$ turns it
into
$$k_t(G)\,\binom{n}{s} \;\le\; k_s(G)\,\binom{n}{t},$$
which is exactly $d_t(G) \le d_s(G)$. The democracy of cliques falls straight out
of double counting.

## Why the bound is perfect

A skeptic should ask: are those binomial constants the best possible, or just a
convenient over-estimate? Here the complete graph returns as the hero. On $K_n$
every set of vertices is a clique, so $k_r(K_n) = \binom{n}{r}$ exactly. Plug
that into the boxed inequality and both sides become equal — the "at most" in the
bottom-up count becomes an exact equality, because in a complete graph *every*
way of adding vertices really does yield a clique. So no smaller constant could
ever work: the fortress $K_n$ saturates the bound at every pair of sizes, and its
normalized densities are all equal to $1$, sitting flat at the very top of the
allowed range. The inequality is not merely true; it is *tight*.

## The other half of the story

There is a famous companion to this result, and it points in the opposite
direction. Our bound is an **upper** bound: it says large cliques cannot be *too
common* relative to small ones, and it is governed by the single dense
blob $K_n$. The complementary question — how *few* triangles can a graph with a
given edge density have, how *few* tetrahedra given a triangle count — is
answered by the celebrated **clique density theorem** of Lovász, Simonovits, and
Reiher. That sharp *lower* bound is governed not by a single clique but by
**complete multipartite graphs**: vertices split into equal camps with all edges
running between different camps. The general conjectured form,
$$\frac{k_t(G)}{n^t} \;\ge\; F_t\!\left(F_s^{-1}\!\left(\frac{k_s(G)}{n^s}\right)\right),$$
composes two piecewise-linear density profiles $F_s$ and $F_t$ that trace the
minimum possible clique densities along these balanced multipartite graphs; the
case $s = 2$ is Reiher's theorem.

The two results are mirror images. One is local, exact, and unconditional, and
its extremal graph is the complete graph; the other is deep, asymptotic, and its
extremal graphs are the multipartite blow-ups. Together they pin the possible
clique counts of a network between two sharp walls. This article has told the
first, cleaner story in full; the second remains one of the jewels of extremal
graph theory.

## Why anyone should care

Clique counting is not an idle pastime. Triangles in a social network measure how
tightly knit a community is — the "clustering" that makes friend groups feel like
groups. Larger cliques flag tightly coordinated subsystems: co-purchased
products, co-expressed genes, colluding accounts, functional modules in the
brain's wiring. Any algorithm that estimates or bounds these counts — for anomaly
detection, for compression, for understanding structure at scale — is implicitly
using relations exactly like the one proved here.

The monotonicity of realized density gives such algorithms a free, always-valid
sanity check: measure the edge density, and you have an instant, rigorous ceiling
on the triangle density, the tetrahedron density, and every higher clique density
at once — no matter how large or strange the network. And because the bound is
tight, that ceiling is the best guarantee anyone could ever offer.

There is something quietly satisfying in that. Behind the messy sprawl of real
networks sits a law as clean as arithmetic: the fraction of realized structure
can only thin out as structure grows more elaborate. Small worlds constrain large
ones. The triangles have already voted, and the tetrahedra must obey.
