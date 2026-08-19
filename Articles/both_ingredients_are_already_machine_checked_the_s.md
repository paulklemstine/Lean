# The Glue Problem: What Happens to a Graph When You Pin Two Copies Together

Take two maps of two countries. Each is coloured so that neighbouring regions
get different colours, and each uses at most four colours. Now suppose the two
countries touch at exactly one point — a single shared corner, like the Four
Corners monument in the American Southwest, but with only two states meeting.
Can you still colour the combined map with four colours?

Yes, and the reason is almost embarrassingly simple: permute the colours of the
second map until the shared corner gets the same colour in both. Nothing else
can clash, because no region of the first country borders a region of the
second. The property "four colours suffice" survives the gluing.

Now ask the same question about a numerical relative of colourability. In any
map coloured with four colours, one of the four colour classes must contain at
least a quarter of the regions, and regions of the same colour never touch. So
every four-colourable map contains a *large mutually non-adjacent family*: at
least a quarter of all its regions, no two of which share a border. In graph
language: if $G$ is a graph on $n$ vertices, write $\alpha(G)$ for the size of
the largest set of pairwise non-adjacent vertices (an *independent set*), and
define the **independence ratio**

$$i(G) \;=\; \frac{\alpha(G)}{n}.$$

Then four-colourability forces $i(G) \ge 1/4$.

So here is the question that this article is about. Colourability survives
gluing at a point. Does the *inequality* $i(G) \ge 1/4$ survive it too?

The answer is no — and the way it fails turns out to be beautifully precise. It
fails by an amount that can be computed exactly, and the failure has a hard
floor at the number $1/7$, which is neither guessed nor approximate: it is
exactly the worst that gluing can ever do to a quarter.

---

## Pinning graphs together

Let us fix the operation. Given two graphs $G_1$ and $G_2$ drawn on the same
vertex set, say that $G$ is the **1-sum** of $G_1$ and $G_2$ along the *cut
vertex* $v$ if:

* $G$ is the union of the edges of $G_1$ and $G_2$;
* every edge of $G_1$ has both endpoints in a set $A$, and every edge of $G_2$
  has both endpoints in a set $B$;
* $A \cup B$ is the whole vertex set, and $A \cap B = \{v\}$.

Picture two blobs sharing exactly one pin. The $m$-fold version — $m$ blobs, all
sharing the same single pin, pairwise meeting nowhere else — is the **star
amalgam**. Everything below is about how graph invariants behave under these
operations.

For the colouring-flavoured invariants, the answer is as clean as it can be.

> **Theorem (amalgamation is a maximum).** If $G$ is the 1-sum of $G_1$ and
> $G_2$, then its chromatic number and its clique number are
> $$\chi(G) = \max\bigl(\chi(G_1),\chi(G_2)\bigr), \qquad
>   \omega(G) = \max\bigl(\omega(G_1),\omega(G_2)\bigr),$$
> and the same holds for a star amalgam of any number of parts, with the maximum
> taken over all of them.

The $\chi$ half is the colour-permutation trick made precise. If $C_1$ colours
the first side and $C_2$ the second, both with $k$ colours, then colour a vertex
$x$ by $C_1(x)$ if $x \in A$, and otherwise by $\tau(C_2(x))$, where $\tau$ is
the transposition that swaps the two colours $C_1(v)$ and $C_2(v)$. Edges inside
$A$ are fine because $C_1$ is proper. Edges inside $B$ are fine because $\tau$ is
a bijection — unless one endpoint is the cut vertex $v$ itself, and that is
exactly the case the transposition was designed for: it sends $C_2(v)$ to
$C_1(v)$, and it sends nothing else there.

The $\omega$ half rests on an observation with a nice geometric flavour: *a
clique can never straddle the cut*. If $x$ lies in $A$ but not $B$, and $y$ lies
in $B$ but not $A$, then $x$ and $y$ are non-adjacent, because every edge lives
inside one of the two sides. So a set of pairwise adjacent vertices is trapped on
one side, and the largest clique of the amalgam is the largest clique of a part.

An immediate consequence: the identity $\chi = \omega$ — a graph whose chromatic
number is forced down to the obvious lower bound given by its largest clique —
is preserved by gluing at a point. Two maxima of the same list agree.

---

## The pigeonhole, and exactly when it is tight

Before we can see how the ratio $i(G)$ breaks, we need to know precisely when it
is tight. The bound $i(G) \ge 1/k$ for $k$-colourable graphs is a pigeonhole: the
$k$ colour classes are independent sets and they partition the $n$ vertices, so
$n = \sum_c |C^{-1}(c)| \le k\,\alpha(G)$, and hence $\alpha(G)/n \ge 1/k$.

Pigeonhole arguments are lossy. When are they not?

> **Theorem (equality analysis of the pigeonhole bound).** Let $C$ be a proper
> colouring of $G$ with $k$ colours. Then $n = k\,\alpha(G)$ — equivalently, for
> a nonempty graph, $i(G) = 1/k$ — **if and only if every colour class of $C$ is
> a maximum independent set of $G$.**

The proof is a strict-inequality bookkeeping argument. Each class has at most
$\alpha(G)$ vertices. If even one class had strictly fewer, summing $k$ terms
would give $n < k\,\alpha(G)$ strictly. Conversely, if all $k$ classes have
exactly $\alpha(G)$ vertices, the sum is $k\,\alpha(G)$ on the nose.

The content of this statement is conceptual rather than technical. It says that
sitting exactly on the threshold $i(G) = 1/k$ is not a numerical coincidence but
a *balancedness* property: the colouring must be perfectly even, and each of its
levels must be as large as any independent set in the whole graph. Graphs on the
threshold are rigid objects.

Two examples make the point. The complete graph $K_4$ has $n=4$, $\alpha=1$, and
its (only) proper $4$-colouring has four classes of size $1 = \alpha$: perfectly
balanced, and indeed $i = 1/4$. The three-vertex path, $2$-coloured with classes
of sizes $2$ and $1$, is unbalanced: $n = 3 < 2\cdot 2 = k\alpha$, and $i = 2/3$
sits strictly above $1/2$.

---

## Why the ratio breaks: the cut vertex is counted twice

Now we can see the mechanism. Colouring is a *local* certificate: a colouring of
the amalgam is assembled from colourings of the pieces, one vertex at a time.
Independence is not quite local, and the failure of locality is a single vertex.

Suppose $s_1$ is an independent set on the first side and $s_2$ an independent
set on the second. Since no edge crosses the cut, $s_1 \cup s_2$ is independent
in the amalgam — provided the two sets agree about the cut vertex $v$. If both
contain $v$, the union has $|s_1| + |s_2| - 1$ elements. If only one contains
$v$, you may have to delete it, again losing one. Either way:

> **Theorem (superadditivity with defect one).** For independent sets $s_1$ and
> $s_2$ of the two parts of a 1-sum, $|s_1| + |s_2| \le \alpha(G) + 1$; and in
> the $m$-fold star amalgam, $\sum_{i} |s_i| \le \alpha(G) + (m-1)$.

The defect $m-1$ is exactly the number of surplus copies of the cut vertex. The
same double-counting appears on the other side of the fraction, in an identity
worth stating on its own: for *any* set $S$ of vertices of a 1-sum,

$$|S| + [\,v \in S\,] \;=\; |S \cap A| + |S \cap B|,$$

where $[\,v \in S\,]$ is $1$ if $S$ contains the cut vertex and $0$ otherwise. In
particular the total vertex count satisfies $n + (m-1) = \sum_i N_i$, where $N_i$
is the size of the $i$-th side.

Both numerator and denominator of the ratio therefore suffer a $+1$ per extra
copy of the pin — but the numerator is small and the denominator is large, so the
damage is asymmetric. Turning the two displayed facts into an inequality gives
the exact loss:

> **Theorem (the defect bound).** If every side of an $m$-fold star amalgam
> carries an independent set of relative density at least $r$, then
> $$i(G) \;\ge\; r - \frac{(m-1)(1-r)}{n}.$$

For a single 1-sum ($m=2$) this reads $i(G) \ge r - (1-r)/n$: the ratio can slip
below the threshold, but by at most one part in $n$.

---

## The graph that falls off the threshold

Is that slip real? It is, and the extremal example is small enough to hold in
your head.

Take $K_8$, the complete graph on eight vertices, and delete a single edge; call
the result $K_8 - e$. Its largest independent set is exactly the pair of
endpoints of the missing edge, so $\alpha = 2$, $n = 8$, and

$$i(K_8 - e) = \frac{2}{8} = \frac14,$$

sitting precisely on the threshold. Now take two copies and pin them together at
one endpoint of the missing edge. The result has $15$ vertices. Its largest
independent set consists of the pin together with the *other* endpoint of each
missing edge — three vertices in all, and no more, because each side is nearly
complete. Hence

$$i(G) = \frac{3}{15} = \frac15 \;<\; \frac14.$$

Two graphs on the threshold, glued at a point, produce a graph below it. The
threshold property $i \ge 1/4$ is **not** closed under vertex amalgamation.

And the drop is not arbitrary. With $r = 1/4$ and $n = 15$ the defect bound
predicts $1/4 - (3/4)/15 = 1/5$ exactly. The counterexample does not merely
violate the threshold; it *saturates* the general inequality, so the defect term
cannot be improved.

There is a consistency check hiding here, and it is reassuring. Colourability is
closed under gluing, and four-colourability implies $i \ge 1/4$. So no
counterexample can have four-colourable sides — and indeed $K_8 - e$ contains a
$K_7$ and needs seven colours. The two halves of the story fit together exactly:
whenever an amalgam drops below $1/4$, at least one of its sides must fail to be
four-colourable.

---

## How far can it fall? The $1/7$ barrier

Once gluing two copies costs you something, gluing $m$ copies should cost more.
Take $m$ copies of $K_8 - e$ and pin them all at a common vertex. The resulting
graph has $n = 7m+1$ vertices; a largest independent set takes the pin plus one
vertex from each of the $m$ blocks, so $\alpha = m+1$ and

$$i(G) = \frac{m+1}{7m+1}, \qquad
  i(G) - \frac17 = \frac{6}{7(7m+1)}.$$

The sequence starts $1/4$, $1/5$, $2/11$, $5/29$, $1/6$, … and decreases to
$1/7 \approx 0.142857$, never reaching it. The exact identity for the gap says
something sharper than mere convergence: the entire deficiency is of order $1/n$,
carried by the single shared vertex.

So the ratio of an amalgam of quarter-density graphs can be pushed arbitrarily
close to $1/7$. Can it be pushed *below*? No — and this is the main theorem.

> **The $1/7$ Barrier Theorem.** Let $G$ be a star amalgam whose every side has
> at least two vertices and carries an independent set occupying at least a
> quarter of that side. Then $n \le 7\,\alpha(G)$, that is,
> $$i(G) \;\ge\; \frac17 .$$
> Moreover $1/7$ is optimal: for every $\varepsilon > 0$ there is such an amalgam
> with $i(G) < 1/7 + \varepsilon$.

Here is why the barrier exists. The obvious route — plug $r = 1/4$ into the
defect bound — fails badly: it gives $1/4 - (m-1)(3/4)/n$, which goes *negative*
once there are many parts, and proves nothing absolute. The defect bound charges
$m-1$ copies of the cut vertex, and for tiny sides that charge can exceed the
entire side.

The fix is to run two different arguments and let each cover the other's blind
spot.

*Regime one: all sides are large*, meaning every side has at least eight
vertices. Then the parts are few relative to the whole: from $n + (m-1) = \sum
N_i \ge 8m$ we get $n \ge 7m+1$, so $m$ is at most about $n/7$. Feeding that into
the defect bound leaves exactly enough room to conclude $n \le 7\alpha$.

*Regime two: some side is small*, with at most seven vertices. Now abandon the
defect bound entirely and use a *cut-free* union instead. Delete the pin from
every side's independent set (and if that empties a set, replace it by any single
non-pin vertex of that side, which exists because each side has at least two
vertices). The resulting sets avoid the pin, live on distinct sides, and are
therefore pairwise disjoint and jointly independent, with **no defect at all**:
$\sum_i |t_i| \le \alpha(G)$. The price is a per-side estimate: from $N_i \le
4|s_i| \le 4|t_i| + 4$ and $|t_i| \ge 1$ one gets $N_i \le 7|t_i| + 1$. Summing
over all $m$ sides costs $m$ surplus units, one too many — and the small side is
precisely where you win it back, since $N_j \le 7 \le 7|t_j|$ with no surplus at
all. The books balance, and $n \le 7\alpha$ again.

Two regimes, one constant, and the extremal family sitting exactly at the seam:
the minimum of the per-side efficiency is attained at side size $8$, which is why
$K_8 - e$ and no other graph is the extremal building block.

---

## What the number $1/7$ is telling us

There is a clean formula lurking behind the $7$. A threshold $i \ge r$, subjected
to gluing, should degrade to a floor of

$$\frac{r}{2-r},$$

and for $r = 1/4$ this is $(1/4)/(7/4) = 1/7$. The heuristic behind it is the
per-side accounting above: after deleting the pin, a side of size $N$ contributes
about $rN - 1$ independent vertices out of $N-1$, and the function $N \mapsto
(rN-1)/(N-1)$ is smallest at the smallest admissible side, $N = 2/r$, where it
equals exactly $r/(2-r)$. Specialising $r = 1/k$ predicts a floor of $1/(2k-1)$:
gluing turns "one in $k$" into "one in $2k-1$", and no worse.

The moral is a distinction between two kinds of mathematical hypothesis.
*Colourability* is a local certificate — a rule assigning something to each
vertex, checkable edge by edge — and local certificates glue. *A ratio bound* is a
global average, and averages do not glue: combining two fractions produces
something like a mediant, and a mediant of two copies of $1/4$ with an extra
vertex double-counted is strictly less than $1/4$.

That is not a defect of the ratio; it is information about it. It says that if
you want a hereditary class of graphs, closed under pinning, all of whose members
have independence ratio at least $1/4$, you cannot simply *ask* for the ratio.
You must ask for a certificate that survives assembly — and the natural candidate
is a (possibly fractional) four-colouring. Closure under gluing is, in this sense,
a test that separates the averages from the structures.

The same distinction shows up wherever large objects are built from small pieces
along thin interfaces: in tree decompositions and clique-sums, where a graph is
assembled by pinning pieces along small separators; in constraint satisfaction,
where a solution assembled from partial solutions must agree on the overlap; in
distributed computing, where local certificates are the only kind a network can
check. In every one of those settings, the lesson of the $1/7$ barrier applies.
Gluing costs you exactly one vertex per seam — and if the quantity you care about
is a fraction, one vertex per seam is enough to take you from a quarter down to a
seventh, but never any further.
