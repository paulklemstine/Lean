# One Poset to Hold Them All

## The hotel problem

Imagine you run a very peculiar hotel. Your guests arrive in groups of $n$, and every group comes with a rigid internal hierarchy: some guests outrank others, some pairs are simply incomparable, and the whole arrangement is *transitive* — if Alice outranks Bob and Bob outranks Carol, then Alice outranks Carol. Mathematicians call such a hierarchy a **partially ordered set**, or **poset**.

Your hotel is itself organised as a hierarchy: each room sits somewhere in a fixed, permanent pecking order that you built once and can never change. When a group checks in, you must assign each guest a room so that the hotel's own pecking order, restricted to the occupied rooms, reproduces the group's hierarchy *exactly*. Not approximately: exactly. If two guests are incomparable, their rooms must be incomparable. If one outranks the other, so must their rooms.

The question is brutally simple to state:

> **How many rooms do you need so that *every* possible group of $n$ guests can be accommodated?**

Call that number $U(n)$. It is the size of the smallest **universal poset** for the $n$-element posets — smallest host containing every $n$-point hierarchy as an *induced* sub-hierarchy.

This is not an idle puzzle. The same question, dressed differently, is the **adjacency labelling** problem of distributed computing: how few bits must you attach to each vertex of a network so that any two vertices can decide, from their labels alone, how they are related — with no lookup table, no central server, no communication? A host poset with $N$ points is exactly a labelling scheme using $\log_2 N$ bits per element, and universality is exactly the guarantee that the scheme works for *every* input. Compact labelling schemes of this kind underpin routing, distributed data structures, and the succinct encoding of relational data.

## The lazy answer, and why it is nearly right

There is an embarrassingly simple universal host: the **Boolean lattice**. Take all $2^n$ subsets of an $n$-element set, ordered by inclusion. Given any poset $P$ on the points $x_1,\dots,x_n$, send each $x$ to its **principal ideal**
$$\downarrow x = \{\,y : y \le x\,\}.$$
Then $x \le y$ if and only if $\downarrow x \subseteq \downarrow y$. The forward direction is transitivity; the backward direction is the observation that $x$ always belongs to $\downarrow x$, so if $\downarrow x \subseteq \downarrow y$ then $x \in \downarrow y$, i.e. $x \le y$. That single line proves:

> **Theorem (Boolean upper bound).** Every partial order on $n$ points embeds as an induced subposet of the Boolean lattice of all subsets of an $n$-element set. Hence $U(n) \le 2^n$.

And notice: the empty set is *never used as a label*, because $x \in \downarrow x$ always. So we may delete it from the host and still accommodate everybody:

> **Theorem (the naive bound is never attained).** $U(n) \le 2^n - 1$; in particular $U(n) < 2^n$ for every $n \ge 0$.

That "minus one" looks like a joke, but it makes a real point: the natural barrier $2^n$ is *strictly* not the truth. And one cannot do better with this particular scheme. For every nonempty subset $S$ of the ground set and every $x \in S$, there is a genuine partial order — put $S \setminus \{x\}$ as an antichain strictly below $x$ and leave everything else isolated — whose ideal label for $x$ is exactly $S$. So the ideal labelling uses *all* $2^n - 1$ nonempty subsets, and beating $2^n$ by a factor requires an entirely different idea.

## How small can it possibly be?

Here is the counting argument, the oldest and still the strongest lower bound known. Restrict attention to the simplest interesting posets: the **height-two** or **bipartite** ones. Take $k$ "bottom" points and $l$ "top" points; let no two bottom points be comparable, no two top points be comparable, and let each bottom point $a$ be below each top point $b$ or not, freely. There are exactly $2^{kl}$ such posets, one for each bipartite relation, and distinct relations give distinct posets.

Now suppose a host with $N$ points accommodates all of them. Each such poset comes with an embedding, a function from $k+l$ guests into $N$ rooms — and crucially, from the embedding you can *read the poset back off*, because the embedding is induced. So the map "poset $\mapsto$ its chosen embedding" is injective, and there are only $N^{k+l}$ functions to land in. Therefore:

> **Theorem (counting lower bound).** If a poset with $N$ points contains every $(k,l)$-bipartite poset as an induced subposet, then
> $$2^{kl} \le N^{\,k+l}, \qquad\text{equivalently}\qquad N \ge 2^{\,kl/(k+l)}.$$

Split $n$ guests as evenly as possible, $k = \lfloor n/2 \rfloor$ and $l = \lceil n/2 \rceil$; then $kl/(k+l) \ge (n-1)/4$ and we obtain the shape of the problem:

> **Theorem (the sandwich).** For every $n \ge 1$,
> $$\frac{n-1}{4} \;\le\; \log_2 U(n) \;\le\; n.$$

So $U(n)$ is exponential, with exponent somewhere between $n/4$ and $n$. And that gap — a factor of four in the exponent, a *quartic* gap in the actual number of rooms — is the entire subject.

## The half-way house

Recent work has narrowed the gap dramatically from the top. For every $\eta > 0$ and all sufficiently large $n$ there is a universal host of size $2^{(1+\eta)n/2}$: the exponent can be pushed down to $n/2$, arbitrarily closely. The proof designs a labelling scheme that preserves transitivity, inspired by the Boolean lattice, and deploys the Szemerédi Regularity Lemma — the great structural hammer of extremal combinatorics, which says that the edges of any huge graph can be partitioned into a bounded number of blocks that behave, statistically, like random graphs.

Where does the exponent $n/2$ come from? There is a beautifully clean place to see it: on the bipartite subclass, the exponent $n/2$ is *achieved by an explicit, elementary construction*. Here it is.

> **Theorem (the tagged-neighbourhood host).** Fix $k$ and $l$. Let the host consist of
> * $k$ **bottom points** $1,\dots,k$, pairwise incomparable, and
> * all pairs $(S, j)$ with $S \subseteq \{1,\dots,k\}$ and $j \in \{1,\dots,l\}$, pairwise incomparable,
>
> with the rule that bottom point $a$ lies below $(S,j)$ exactly when $a \in S$. This poset has $k + 2^k l$ points and contains **every** $(k,l)$-bipartite poset as an induced subposet.

The embedding is what you would guess: send bottom point $a$ to itself, and send top point $b$ to the pair $(\,\{a : a < b\},\; b\,)$ — its down-set, *tagged* with its own name. The down-set does all the ordering work; the tag does something subtler, and it is not optional:

> **Theorem (the tag is necessary).** In any host for the $(k,2)$-bipartite posets, the two top points of the poset in which nothing is comparable receive *distinct* host points.

Two guests with identical relationships to everyone else still need separate rooms — an induced embedding must be injective, since a poset has no two distinct points that are mutually comparable. The down-set alone cannot distinguish them; the tag can. This is the small, sharp reason why "labelling by neighbourhood" needs one extra coordinate.

Balancing at $k = l = m$ and $n = 2m$, the tagged host has $m \cdot 2^m + m$ points, exponent $n/2$ — exactly the exponent of the general theorem, on the very subclass where the counting lower bound is at its strongest. Meanwhile the counting bound on the same subclass gives only $2^{n/4}$. So we have, on the bipartite class,
$$2^{n/4} \;\le\; (\text{smallest bipartite host}) \;\le\; \tfrac{n}{2}\bigl(2^{n/2}+1\bigr),$$
and the mystery — factor two in the exponent — is fully visible in a construction you can draw on a napkin.

## Where the counting argument leaks

Why does counting lose a factor of two? Because it allows a host point to be *reused*: the argument treats all $N^{k+l}$ functions as available, when in reality a host point that is high up in the host order cannot suddenly play the role of a low point in some other embedding. Comparabilities in the host cannot be switched off.

You can watch this leak already at $n = 2$. There are exactly three posets on two points: the antichain, and the two chains (which are isomorphic, so really two shapes). A host must contain a comparable pair *and* an incomparable pair. Two points can be one or the other but never both, so a two-point host is impossible; and a three-point host — a two-element chain plus an isolated point — works.

> **Theorem.** $U(2) = 3$.

The counting bound at $n=2$ predicts only $U(2) \ge 2$. Already lossy, in the very first nontrivial case, and lossy for exactly the reason that costs a factor of two asymptotically.

## Small numbers, hard-won

Exact values of $U(n)$ are startlingly difficult. Here is what is known with certainty:
$$U(0)=0,\quad U(1)=1,\quad U(2)=3,\quad U(3)=5,\quad 7 \le U(4) \le 8.$$

$U(3)=5$ has a satisfying witness: the five-point host consisting of a **diamond** (one bottom point below two incomparable middle points, both below a top point) together with one isolated point contains all nineteen partial orders on three points. The matching lower bound $U(3) \ge 5$ needs no search at all — it follows from a general structural principle, to which we now turn.

## The overlap method: geometry, not counting

Counting is not the only way to force a host to be large. Here is a completely different mechanism, and it is the source of the most interesting new results in this circle of ideas.

Say two $n$-element posets $P$ and $Q$ have **common induced bound $s$** if no set of more than $s$ points can sit inside $P$ and inside $Q$ in a way that matches all relations. Then:

> **Theorem (overlap bound).** If $P$ and $Q$ are $n$-element posets with common induced bound $s$, then every host containing both as induced subposets has at least $2n - s$ points.

The proof is a picture. The copy of $P$ occupies $n$ host points, the copy of $Q$ occupies $n$ host points, and their intersection is a set of host points that is *simultaneously* an induced subposet of $P$ and of $Q$ — so it has at most $s$ points. Inclusion–exclusion finishes it.

Feed in the two most incompatible posets there are: the **$n$-chain** (everybody comparable) and the **$n$-antichain** (nobody comparable). Two points cannot be comparable and incomparable at once, so their common induced bound is $1$, and:

> **Theorem.** $U(n) \ge 2n - 1$ for every $n$.

Sharp at $n = 1, 2, 3$. And it explains, with no computation whatsoever, why no four-point host can serve all three-point posets: a four-point host containing a $3$-chain has only one point left over, so it cannot also contain a $3$-antichain.

Add a third poset — the disjoint union of two chains of lengths $\lceil n/2 \rceil$ and $\lfloor n/2 \rfloor$ — and run inclusion–exclusion for three sets. Its overlap with the chain is at most $\lceil n/2 \rceil$ (a chain inside a union of two chains lives in one of them), and with the antichain at most $2$ (an antichain inside a union of two chains has at most one point per chain). So:

> **Theorem.** $U(n) \ge 3n - \lceil n/2 \rceil - 3$, asymptotically $\tfrac{5}{2}n - 3$.

This beats $2n-1$ from $n = 6$ on. But it is still linear, and one naturally asks: is the overlap method *intrinsically* linear? It is not.

## Going superlinear: a geometric family of rulers

The trick is to use not three posets but a whole geometric ladder of them, and to make the overlaps decay fast enough that they cost only a constant fraction of the gain.

Fix $n = 4^k$. For each $i$ with $0 \le i < k$, cut the ground set $\{0,1,\dots,n-1\}$ into consecutive blocks of length $4^i$, and let $P_i$ be the poset in which two points are comparable exactly when they lie in the same block, ordered by their index. So $P_i$ is a disjoint union of $4^{k-i}$ chains of length $4^i$: a ruler with tick spacing $4^i$. $P_0$ is the antichain, and the ladder gets coarser as $i$ grows.

The key estimate is a two-line argument. Suppose $j < i$ and consider a set of points sitting inside both $P_i$ (coarse) and $P_j$ (fine). It splits into at most $4^{k-i}$ pieces, one per coarse block, and each piece is a chain of $P_i$, hence a chain of $P_j$, hence lies inside a single fine block, hence has at most $4^j$ points. Total: at most $4^{k-i} \cdot 4^j$ points.

Now sum. The $k$ copies together demand $k \cdot 4^k$ host points; the pairwise overlaps subtract at most
$$\sum_{i<k}\sum_{j<i} 4^{k-i} 4^{j} \;\le\; \frac{k \cdot 4^k}{3},$$
using the exact identity $3\sum_{j<i} 4^j + 1 = 4^i$. Two thirds of the demand survives:

> **Theorem (superlinear lower bound).** $2k\cdot 4^k \le 3\,U(4^k)$; consequently, for every $n$,
> $$n \log_4 n \;\le\; 6\, U(n),$$
> and therefore $U(n)/n \to \infty$.

The base $4$ is not decoration. With ratio $2$ instead of $4$ the geometric series of overlaps contributes almost exactly one full copy per index, and what survives is only $2n-2$ — a bound independent of $k$, no better than the trivial linear one. Ratio $2$ is the **exact threshold** of the method. This also explains why the three-poset argument stalled at $\tfrac52 n$ — it was one step of a ladder that only pays off when you climb it with the right stride.

The result is still astronomically below the truth ($n\log n$ versus $2^{n/4}$). Its interest is that it measures precisely how much *structure*, as opposed to *counting*, can force. And by a Dilworth/Erdős–Szekeres argument, any two $n$-element posets share a chain or an antichain on $\Omega(\log n)$ points, so the overlap method cannot itself go beyond order $n \log n$: the exponential must come from counting.

## The staircase never rests

One more structural fact, small but pleasing. Is $U$ strictly increasing? Nothing in the counting bounds says so — they are far too crude. But a direct argument works.

> **Theorem (strict monotonicity).** $U(n) < U(n+1)$ for every $n$; in particular $U$ is injective.

Take an optimal host $H$ for the $(n+1)$-element posets and let $m$ be any maximal point of $H$. Given an $n$-element poset $P$, adjoin a new element $\top$ above everything, obtaining an $(n+1)$-element poset $P^{+}$. Inside $H$, the copy of $P^{+}$ places the image of $\top$ strictly above the images of all other $n$ points — so *none* of those $n$ points can be $m$, since nothing lies strictly above a maximal point. Therefore $H$ with $m$ deleted, one point smaller, is already universal for the $n$-element posets. Hence $U(n) \le U(n+1) - 1$. No plateaux, ever.

## The bridge to graphs

Finally, the reason the Regularity Lemma can enter at all. To a poset $P$ associate its **comparability graph**: same points, with $x$ and $y$ joined by an edge exactly when they are distinct and comparable. This is a functor on induced embeddings — an induced subposet becomes an induced subgraph — provided the embedding both preserves and *reflects* the order, and is injective, which induced embeddings automatically are.

On height-two posets, nothing is lost. The comparability graph of a $(k,l)$-bipartite poset is *exactly* the corresponding bipartite graph, and the correspondence is a bijection on relations. So the poset counting bound and the graph counting bound are the same theorem seen from two sides: a host graph on $N$ vertices containing all $(k,l)$-bipartite graphs as induced subgraphs also satisfies $2^{kl} \le N^{k+l}$, and pushing a universal poset host through the comparability functor re-derives the poset bound by a genuinely different route.

For general posets the functor *does* lose information — the comparability graph forgets which way each edge points — and that is precisely why the regularity-based construction must re-orient afterwards. And regularity applies verbatim: every sufficiently large finite poset admits, for each $\varepsilon > 0$, an $\varepsilon$-uniform equipartition of its comparability graph into a bounded number of parts, the bound depending on $\varepsilon$ alone and not on the poset. That is the door through which the modern machinery walks in.

## What we know, and what we want

Assembling everything:
$$\max\Bigl(3n - \bigl\lceil \tfrac n2 \bigr\rceil - 3,\ \tfrac16 n\log_4 n,\ 2^{(n-1)/4}\Bigr) \;\le\; U(n) \;\le\; 2^n - 1,$$
with $2^{(1+\eta)n/2}$ available from above for large $n$, and exact values $1, 3, 5$ at $n = 1,2,3$ and $U(4)\in\{7,8\}$.

The linear and superlinear bounds are sharp for tiny $n$ and hopeless afterwards; the counting bound is vacuous for $n \le 4$ and dominant from around $n = 20$ on. The two regimes cross, and neither knows anything about the other.

And the real question is untouched by both. Write $U(n) = 2^{c(n) n}$. We know $c(n) \in [1/4, 1/2 + o(1)]$. Is the truth $1/4$? Is it $1/2$? Is there a genuine constant at all? Every improvement so far has come from finding a cleverer labelling scheme (pushing the top down) or a cleverer family of mutually hostile posets (pushing the bottom up). The bipartite class shows exactly where the difficulty lives: there, counting says $n/4$, an explicit napkin construction says $n/2$, and nobody knows which of the two is telling the truth.

A hotel, a hierarchy, and a factor of two in an exponent. Some of the best problems really are that easy to state.
