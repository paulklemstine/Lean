# The Warehouse of All Possible Hierarchies

*How small can a single ordered structure be, if it has to contain every ordered structure of a given size hiding inside it?*

## A catalogue that contains everything

Imagine you run a warehouse whose customers order not objects but *hierarchies*. One wants a chain of command with five ranks; another, five independent contractors answering to nobody; a third, a diamond: one boss, three incomparable deputies, one common subordinate.

You could stock every hierarchy separately, but there are astronomically many — the number on $n$ labelled elements grows like $2^{n^2/4}$. Better: build **one** master hierarchy $H$, so richly interconnected that every request can be found *sitting inside it*. Pick out the right $n$ points of $H$, and the relationships they already have are exactly the ones asked for. Not approximately — exactly. If two chosen points are unrelated in the request, they must be unrelated in $H$ too.

The mathematical name for a hierarchy is a **partially ordered set**, or *poset*: a set with a relation $\le$ that is reflexive ($x \le x$), transitive ($x \le y$ and $y \le z$ force $x \le z$), and antisymmetric ($x \le y$ and $y \le x$ force $x = y$). Picking out a subset and keeping exactly the relations it already carries is called taking an **induced subposet**. A poset containing every $n$-element poset as an induced subposet is called a **universal poset** for size $n$.

The question of this article is deceptively simple:

> **How few points can a universal poset for size $n$ have?**

Write $U(n)$ for that minimum. The whole story is a fight to pin $U(n)$ down.

## The obvious answer, and why it is nearly right

Here is a construction that always works, and it is beautiful in its simplicity. Take any poset $P$ on the points $\{1,\dots,n\}$. To each point $x$, attach the set of everything below it:
$$\downarrow x \;=\; \{\,y : y \le x\,\}.$$
This is called the *principal down-set*, or *principal ideal*, of $x$. Now compare two such sets by inclusion. Transitivity says that if $x \le y$ then everything below $x$ is below $y$, so $\downarrow x \subseteq \downarrow y$. Conversely, reflexivity says $x \in \downarrow x$, so if $\downarrow x \subseteq \downarrow y$ then $x \in \downarrow y$, i.e. $x \le y$. Antisymmetry makes the assignment injective. In one line:

**Theorem (Boolean host).** *For every poset $P$ on $n$ points, the map $x \mapsto \downarrow x$ is an induced embedding of $P$ into the lattice of all subsets of $\{1,\dots,n\}$ ordered by inclusion.*

So the Boolean lattice — the poset of all $2^n$ subsets of an $n$-element set — is universal. Just like that, $U(n) \le 2^n$.

And in fact you can shave a point off, for free: since $x$ always lies in $\downarrow x$, the *empty* subset is never used as a label. Throwing it away leaves a universal host on $2^n - 1$ points, so

$$U(n) \;\le\; 2^n - 1 \;<\; 2^n .$$

The naive bound is never attained. That hints at something: the Boolean lattice is *wasteful*. Could it be wasteful by a huge factor — could $U(n)$ actually be something like $2^{n/2}$, the square root of the naive answer?

This is exactly the question that a recent line of work answers, and the answer is yes: for every $\eta>0$ and all large enough $n$, there is a universal poset of size $2^{(1+\eta)n/2}$. The exponent drops from $n$ to $n/2$. The construction is a labelling scheme, inspired by the Boolean lattice but far more economical, designed so that comparability can still be read off from labels and so that transitivity is automatically preserved; the hardest step relies on the Szemerédi Regularity Lemma, the great structural theorem of extremal combinatorics that says every large graph can be chopped into a bounded number of pieces that behave, pairwise, almost like random graphs.

What follows is a self-contained tour of the landscape around that theorem: the counting barrier that says the exponent can never drop below $n/4$, an explicit host that *achieves* the exponent $n/2$ on the hardest-looking sub-family, exact values of $U(n)$ for tiny $n$, and a new proof that $U(n)$ must grow faster than any constant multiple of $n$.

## The counting barrier: why you cannot do better than $2^{n/4}$

Why can a universal poset not be tiny — say, polynomial in $n$? The reason is pure information theory, and it is worth savouring because it is so short.

Fix two numbers $k$ and $l$ and look only at the simplest interesting posets: the **bipartite** ones, of height at most two. Take $k$ "low" elements $a_1,\dots,a_k$ and $l$ "high" elements $b_1,\dots,b_l$. No two lows are comparable, no two highs are comparable, and for each pair $(i,j)$ you get to *choose freely* whether $a_i < b_j$. Every such choice gives a genuine poset — transitivity is free because there are no chains of length three. So there are exactly $2^{kl}$ bipartite posets of shape $(k,l)$, all distinct.

Now suppose $H$ is a host with $N$ points containing all of them. For each of the $2^{kl}$ choices, fix one embedding: a map from the $k+l$ elements into the $N$ host points. Two *different* bipartite posets can never yield the *same* map, because from the map you can read the poset straight back off: $a_i < b_j$ holds if and only if the image of $a_i$ is below the image of $b_j$ in $H$. So we have an injection from $2^{kl}$ posets into the $N^{k+l}$ possible maps:

**Theorem (Counting bound).** *If a poset on $N$ points contains every $(k,l)$-bipartite poset as an induced subposet, then*
$$2^{kl} \;\le\; N^{\,k+l}, \qquad\text{equivalently}\qquad N \;\ge\; 2^{\,kl/(k+l)} .$$

Set $k=l=m$ and $n=2m$. Then $kl/(k+l) = m/2 = n/4$, so every universal poset for $n$ points needs at least $2^{n/4}$ of them. In logarithmic form, for every $n \ge 1$,
$$\frac{n-1}{4} \;\le\; \log_2 U(n) \;\le\; n .$$

There is the whole game in one line. The truth lies somewhere in the corridor between exponent $1/4$ and exponent $1$, and the theorem quoted above pushes the ceiling down to $1/2 + \eta$.

An amusing footnote: the counting bound is *lossy from the very first case*. For $n=2$ it gives only $U(2) \ge 2$, whereas the true value is $U(2)=3$ — you genuinely need three points (say $x < y$ and a third point $z$ incomparable to both) to host both the two-element chain and the two-element antichain. Counting arguments do not see that kind of obstruction at all.

## Achieving the exponent $n/2$, explicitly

Here is the surprise. On the bipartite family — the very family that produced the lower bound — one can write down an explicit optimal-looking host with no regularity lemma, no probabilistic argument, and no asymptotics.

**The tagged-neighbourhood host.** Fix $k$ and $l$. Build a poset $B_{k,l}$ whose points are of two kinds:

* $k$ *bottom* points, one for each $a_i$, pairwise incomparable;
* all pairs $(S,t)$ where $S$ is any subset of the bottom points and $t$ is a *tag* drawn from $\{1,\dots,l\}$, pairwise incomparable.

The order is the only sensible one: bottom point $a$ lies below $(S,t)$ exactly when $a \in S$; there are no other relations. The number of points is
$$|B_{k,l}| \;=\; k + 2^{k}\,l .$$

**Theorem (Bipartite universality).** *$B_{k,l}$ contains every $(k,l)$-bipartite poset as an induced subposet.*

The proof is one line: given a bipartite poset with relation $R$, send $a_i$ to the bottom point $a_i$, and send the high element $b_j$ to the pair $(\{a_i : a_i R\, b_j\},\, j)$ — its neighbourhood, tagged with its own index. A bottom point is below the image of $b_j$ exactly when it belongs to the neighbourhood, which is exactly the required relation; and two high images are equal only if their tags agree, so distinct high elements land on distinct points.

Why the tag? Because two high elements may have *identical* down-sets — imagine two managers overseeing precisely the same team. Their neighbourhoods are the same set, so the neighbourhood label alone cannot separate them; but a universal host must place them at *different* points, since a host is a poset and two distinct points of a poset are never "the same". Formally:

**Proposition (The tag is necessary).** *In any host containing all $(k,2)$-bipartite posets, the two high elements of the poset with no relations at all must receive distinct host points.*

So the tag coordinate is not decoration; it is forced.

Now balance the parts: $k=l=m$, so $n=2m$. The host has $m\,2^m + m$ points, an exponent of $m = n/2$. Setting this beside the counting bound gives a clean sandwich for the balanced bipartite family on $n=2m$ points:
$$2^{\,m/2} \;\le\; U_{\text{bip}}(m,m) \;\le\; m\,2^{m} + m .$$
Exponent $n/4$ below, exponent $n/2$ above — and the upper bound is a completely explicit list of points. The deep theorem about *all* posets says that the exponent $n/2$ survives when the bipartite restriction is dropped, up to a factor $2^{\eta n}$.

Is the remaining factor-of-two gap an artefact of a lazy argument? No. On the balanced bipartite family there are $2^{n^2/4}$ posets to host, while a host with $2^{cn}$ points offers $2^{cn^2}$ ways to place $n$ labelled points; counting is defeated only when $c < 1/4$. So it is *structurally impossible* for counting to certify an exponent above $1/4$: the method never notices that a single host point is *reused* by enormously many different embeddings. Closing the gap means understanding that reuse — precisely where machinery like the regularity lemma enters.

## Small numbers, exactly

Asymptotics are one thing; the first few values are another, and they are unexpectedly stubborn.

$$U(0)=0,\qquad U(1)=1,\qquad U(2)=3,\qquad U(3)=5,\qquad 7 \le U(4)\le 8 .$$

The upper bounds are explicit hosts. For $n=3$ there is a five-point poset into which all nineteen three-element orders embed as induced subposets; for $n=4$ there is an eight-point poset that hosts all $219$ four-element orders — a finite check, but a real one, over all $4096$ candidate relations on four points.

The lower bounds come from an idea entirely different from counting, and it is the engine of everything in the rest of this article.

**The overlap principle.** Suppose $P$ and $Q$ are two $n$-element posets that are *incompatible*: no poset on more than $s$ points embeds as an induced subposet into both. Any host must contain an induced copy of $P$ (occupying $n$ points) and an induced copy of $Q$ (occupying $n$ points), and the two copies can share at most $s$ points — because a shared set of points is an induced subposet of both. By inclusion–exclusion,
$$N \;\ge\; 2n - s .$$

Take $P$ = the $n$-chain $x_1 < x_2 < \dots < x_n$ and $Q$ = the $n$-antichain. Any poset embedding into both must be simultaneously totally ordered and totally unordered, so it has at most one point: $s=1$. Hence

**Theorem (Linear lower bound).** $U(n) \ge 2n-1$.

This is sharp for $n \le 3$ — it gives $U(3)\ge 5$, matching the five-point host exactly — and it gives $U(4)\ge 7$.

Three posets are better than two. Add $R$ = the disjoint union of two chains, each of about $n/2$ points. A chain sitting inside $R$ must live in one of the two chains, so the chain and $R$ share at most $\lceil n/2 \rceil$ points; the antichain and $R$ share at most $2$ points (one from each chain); the chain and the antichain share at most $1$. Bonferroni's inequality for three sets — $|A \cup B \cup C| \ge |A|+|B|+|C| - |A\cap B| - |A \cap C| - |B \cap C|$ — then yields

**Theorem (Three-poset bound).** $U(n) \;\ge\; 3n - \lceil n/2 \rceil - 3$,

which is asymptotically $\tfrac52 n$, beating $2n-1$ for every $n \ge 6$.

## Breaking the linear barrier

All of the above is linear in $n$, while the truth is exponential. Can the overlap method — which never counts posets at all — nevertheless see superlinear growth? The answer is yes, and the trick is to play a whole *geometric family* of posets against each other rather than two or three.

For a block size $d$, let $C_d$ be the poset on $\{0,1,\dots,n-1\}$ obtained by cutting the line into consecutive blocks of length $d$ and making each block a chain, with no relations between blocks. So $C_1$ is the antichain and $C_n$ is the full chain. The key combinatorial fact is a two-sided squeeze:

**Lemma (Chain-union overlap).** *If $e \ge d$, then any common induced subposet of $C_e$ and $C_d$ has at most $\lceil n/e\rceil \cdot d$ points.*

The reason is a pigeonhole with two prongs. Such a common subposet meets each of the $\approx n/e$ blocks of $C_e$ in a chain; and each of those chains, being totally ordered, must be carried into a *single* block of $C_d$, which holds at most $d$ points. Multiply.

Now take $n = 4^k$ and the geometric family $C_{4^0}, C_{4^1}, \dots, C_{4^{k-1}}$. Each contributes $n$ host points; the pairwise overlaps sum to at most
$$\sum_{i<k}\sum_{j<i} 4^{\,k-i}\,4^{\,j} \;\le\; \frac{k\,4^{k}}{3},$$
using the exact identity $3(1+4+\dots+4^{i-1}) + 1 = 4^{i}$. A Bonferroni bound for $k$ sets — $|\bigcup A_i| \ge \sum |A_i| - \sum_{j<i}|A_i \cap A_j|$ — gives $k\cdot 4^{k} \le N + \tfrac13 k\,4^k$, hence

**Theorem (Superlinear lower bound).** *For all $k$,* $\;2k\,4^{k} \le 3\,U(4^{k})$, *and for every $n$,*
$$n\log_4 n \;\le\; 6\,U(n).$$
*Consequently $U(n)/n \to \infty$: for every constant $C$ there are arbitrarily large $n$ with $U(n) \ge C n$.*

The base $4$ is not cosmetic. If you run the same argument with ratio $2$ instead of $4$, the geometric series of overlaps grows exactly as fast as the gain from adding a new poset, and the whole bound collapses to something linear. Ratio $2$ is precisely the threshold of the method; anything strictly larger works, and $4$ makes the arithmetic exact.

One more structural fact deserves a place. Delete a *maximal* point from an optimal host for the $(n+1)$-element posets and what remains still hosts all $n$-element posets, because every $n$-element poset extends to an $(n+1)$-element poset with an extra point on top, whose copy must use the deleted point last. Hence:

**Theorem (Strict monotonicity).** $U(n) < U(n+1)$ *for every $n$; in particular $U$ is injective.*

## Graphs, regularity, and where the difficulty really lives

There is a bridge from posets to graphs that makes the connection to the regularity lemma visible. The **comparability graph** of a poset joins two distinct points whenever they are comparable. Under this translation, a bipartite poset of shape $(k,l)$ becomes an ordinary bipartite graph on parts of sizes $k$ and $l$, and — this is the point — induced subposets become induced subgraphs. So a universal poset yields, via its comparability graph, a graph containing every $(k,l)$-bipartite graph as an induced subgraph; the counting bound $2^{kl} \le N^{k+l}$ can be re-derived on the graph side without ever mentioning order.

And on the graph side the heavy machinery is available. The Szemerédi Regularity Lemma states that for every $\varepsilon > 0$ there is a bound $M(\varepsilon)$ such that every large enough graph admits an equipartition of its vertices into between $m$ and $M(\varepsilon)$ parts, almost all pairs of which are $\varepsilon$-uniform: the edge density between any two large sub-parts is within $\varepsilon$ of the density between the parts themselves. Applied to comparability graphs of posets, it says every large poset can be split into a bounded number of blocks whose mutual comparability patterns look pseudorandom. That is the leverage which converts "a host point can serve many embeddings" from an obstruction into a resource, and it is what powers the passage from the explicit exponent $n/2$ on bipartite posets to the exponent $(1+\eta)n/2$ on all posets.

## Why anyone should care

Universal posets are a problem in *labelling*, and labelling is a practical business.

An **adjacency labelling scheme** assigns to each element a short binary string, so that the relation between any two elements can be decided from their two labels alone — no global lookup table. A universal host with $N$ points is exactly a labelling scheme with $\log_2 N$-bit labels: label a point by the host point it maps to, and decide comparability inside the host. Improving the exponent from $n$ to $n/2$ halves the label length. Such schemes let a distributed system answer "does $u$ dominate $v$?" from local data, compress version-control ancestry and taxonomies, and underlie succinct reachability structures.

The Boolean-lattice construction is precisely the naive scheme "label each element by the bit-vector of everything below it" — $n$ bits per element. The tagged-neighbourhood host is the observation that in a two-level hierarchy you only need the neighbourhood plus a disambiguating serial number. The deep theorem is the statement that a similar economy is achievable across all hierarchies at once, with about $n/2$ bits.

And the counting bound is the hard floor: no scheme can beat $n/4$ bits per element, because there are simply too many hierarchies and too few short labels. Somewhere between $n/4$ and $n/2$ lies the truth, and nobody yet knows where.

## The state of play

Collecting everything:

$$\max\!\left(2n-1,\; 3n-\lceil n/2\rceil-3,\; \tfrac{1}{6}n\log_4 n,\; 2^{(n-1)/4}\right) \;\le\; U(n) \;\le\; 2^{n}-1,$$

with $U(0)=0$, $U(1)=1$, $U(2)=3$, $U(3)=5$, $7 \le U(4) \le 8$, and $U$ strictly increasing throughout. The exponential lower bound eventually swamps all the linear and near-linear ones — the crossover happens around $n \approx 25$ — but for small $n$ the structural bounds are the sharp ones, and they are the only bounds that ever produce an *exact* value.

The exponent of $U(n)$ is now known to lie between $1/4$ and $1/2$. Which end is the truth? The counting bound is provably lossy in every small case where the answer is known, and the tagged-neighbourhood host achieves exponent $1/2$ on the bipartite family — faint evidence for the upper end. But the honest summary is the one every good open problem deserves: we know the corridor, and we do not know the room.
