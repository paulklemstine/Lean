# When Three Colors Are Not Enough: The Hidden Rigidity of Square-Free Networks

## A puzzle about maps, friends, and colors

Imagine a vast social network with two seemingly innocent rules. First, the world
is *small*: any two people are either friends, or they share at least one mutual
friend. Nobody is more than two handshakes away from anybody else. Second, the
network has *no squares*: you will never find four people $a, b, c, d$ arranged in
a closed loop of friendships $a\!-\!b\!-\!c\!-\!d\!-\!a$ with no shortcuts across
the middle. Put differently, any two people share **at most one** mutual friend.

These two rules look modest. Yet together they force the network into a
surprisingly rigid shape — a shape so constrained that, once it grows even
moderately large, it becomes impossible to sort everyone into just three groups
so that no two friends land in the same group.

That last sentence is a statement about *coloring*. In graph theory, a "proper
$k$-coloring" is a way of painting each vertex (person) with one of $k$ colors so
that adjacent vertices (friends) never share a color. The smallest number of
colors that works is the graph's **chromatic number**. Three colors are famously
enough for any map of countries drawn without holes... no, wait — that's four
colors, and it's a different problem. For general networks, three colors are often
*not* enough, and deciding when they suffice is one of the deepest questions in
combinatorics.

This article is about a precise conjecture that lives at the crossroads of these
ideas:

> **The Non-3-Colorability Conjecture.** Any square-free network of diameter two,
> in which no single person is friends with *everybody*, and in which the most
> popular person has at least $17$ friends, cannot be properly colored with only
> three colors.

We will not settle this conjecture here — nobody has yet. But we *will* build the
rigid scaffolding on which any solution must rest: three exact inequalities that
pin down the geometry of these networks. And we will see why the number three,
the number seventeen, and two of the most beautiful graphs ever discovered are all
secretly part of the same story.

## Three words, three tensions

Let us name the three rules carefully, because their interplay is the whole point.

**Square-free (no $C_4$).** A four-cycle, written $C_4$, is a loop of four
vertices. Forbidding it is equivalent to a crisp local law: *any two distinct
vertices have at most one common neighbour.* If two people had two mutual friends,
those four would close a square. So square-freeness is a statement about
*uniqueness of connection* — between any two strangers there is at most one bridge.

**Diameter two.** The whole network fits inside two handshakes: *every pair of
distinct vertices is either adjacent or has a common neighbour.* This is a
statement about *density* — the graph cannot be stringy or spread out; it must be
tightly woven.

**No universal vertex.** Nobody is connected to everyone else. This rules out the
cheap trick of a "hub" — a single vertex joined to all others. A star graph (one
hub, many leaves) has diameter two and is square-free, but it is trivially
$2$-colorable, so it must be excluded to make the question interesting.

Here is the tension that makes the conjecture believable. Diameter two says *there
must be enough edges to keep everyone close*. Square-freeness says *there cannot be
too many edges clustered locally* — around any one person, their friends form a
network with no edges repeated in a square, essentially a sparse matching. These
two forces pull in opposite directions, and "no universal vertex" removes the one
loophole (the hub) that would let a graph escape the squeeze. When the maximum
degree $\Delta$ — the number of friends of the most popular person — grows past a
threshold, the conjecture says the strain becomes so great that three colors can
no longer absorb it.

## The first pillar: how big can such a world be?

The first exact result caps the population of any diameter-two network in terms of
its most popular member. It is a classical idea known as the **Moore bound**.

> **Moore Bound (diameter two).** In any finite network of diameter at most two,
> the number of vertices satisfies
> $$|V| \le \Delta^2 + 1,$$
> where $\Delta$ is the maximum degree.

The proof is a beautiful counting argument that anyone can follow. Fix any person
$v$. Every other person is one of two kinds: a *friend* of $v$, or a *stranger* to
$v$. There are at most $\Delta$ friends. Now take a stranger $w$. Because the
diameter is two and $w$ is not adjacent to $v$, they must share a common friend
$u$ — and $u$ is one of $v$'s (at most $\Delta$) friends. So $w$ hangs off one of
$v$'s friends. Each such friend $u$ has at most $\Delta$ neighbours, one of which
is $v$ itself, leaving at most $\Delta - 1$ slots for strangers. Adding up: one
vertex $v$, at most $\Delta$ friends, and at most $\Delta(\Delta-1)$ strangers,
gives
$$|V| \le 1 + \Delta + \Delta(\Delta - 1) = \Delta^2 + 1.$$

Notice that this argument never used square-freeness. Diameter two alone caps the
size. Square-freeness enters later — and, remarkably, it is exactly what makes this
bound *tight*.

## The second pillar: the cherry-counting inequality

The second result is where square-freeness earns its keep. Call a "cherry" any
choice of a central vertex together with an unordered pair of its neighbours — a
little three-vertex path $a\!-\!v\!-\!b$ with $v$ in the middle. A vertex of degree
$d$ is the centre of exactly $\binom{d}{2}$ cherries. So the total number of
cherries in the whole graph is $\sum_v \binom{\deg v}{2}$.

> **Cherry Inequality (Kővári–Sós–Turán).** In any square-free network,
> $$\sum_{v} \binom{\deg v}{2} \le \binom{|V|}{2}.$$

The proof is a single, elegant double count. Each cherry $a\!-\!v\!-\!b$ points to
an unordered pair of endpoints $\{a, b\}$. There are $\binom{|V|}{2}$ such pairs in
total. The magic of square-freeness is that **no two cherries can point to the
same pair**: if two different centres $v$ and $v'$ both connected the same pair
$\{a, b\}$, then $v$ and $v'$ would be *two* common neighbours of $a$ and $b$ — a
forbidden square! So the map from cherries to endpoint-pairs is injective, and the
number of cherries cannot exceed the number of pairs. That is the inequality.

This is the precise sense in which square-free graphs are "locally sparse": their
degree sequence cannot be too top-heavy, because every high-degree vertex spends a
quadratic number of cherries, and cherries are a scarce, non-repeatable resource.

## The third pillar: the no-hub floor

The final piece is a humble but essential bookkeeping fact.

> **No-Hub Bound.** If a network has no universal vertex, then
> $$\Delta + 2 \le |V|.$$

The most popular person has $\Delta$ friends, which already accounts for $\Delta+1$
people (themselves plus their friends). Because they are *not* universal, there
must be at least one more person they are not friends with. That extra person
brings the count to at least $\Delta + 2$. Simple — but it guarantees the graph is
strictly larger than a single closed neighbourhood, which is what keeps the problem
from collapsing into a triviality.

## Where the two forces collide

Now watch the three pillars work together. Suppose you wanted to properly color
such a graph with three colors. Coloring with three colors means partitioning the
vertices into three groups, each an *independent set* (no two friends inside a
group). If the largest possible independent set has size $\alpha$, then three of
them can cover at most $3\alpha$ vertices. So three colors suffice **only if**
$$3\alpha \ge |V|.$$

The conjecture, restated, is that for square-free diameter-two graphs without hubs
and with $\Delta \ge 17$, this inequality *fails* — the independent sets are simply
too small to tile the whole graph three times over.

And here is where the pillars deliver their verdict. In such a graph, any two
*non-adjacent* vertices have a *unique* common neighbour (diameter two gives at
least one; square-freeness allows at most one). So an independent set of $s$
mutually non-adjacent people demands $\binom{s}{2}$ distinct "connector" vertices,
one bridging each pair. But the Moore bound caps the whole population at
$\Delta^2 + 1$. Cramming $\binom{s}{2}$ distinct connectors into a world of that
size forces $s$ to be of order $\Delta$, not of order $|V| \approx \Delta^2$. In
other words, the independence number grows only *linearly* in $\Delta$, while the
graph itself grows *quadratically*. The ratio $3\alpha / |V|$ shrinks toward zero,
and for $\Delta$ large enough, three colors cannot possibly cover the graph.

That heuristic is the beating heart of the conjecture, and the three exact
inequalities above are precisely the tools needed to make it rigorous.

## Two legendary witnesses

The abstract story becomes vivid through two of the most famous graphs in
mathematics, both of which are square-free diameter-two graphs that meet the Moore
bound with perfect equality, $|V| = \Delta^2 + 1$.

**The Petersen graph** has $10$ vertices, each of degree $3$, so $\Delta = 3$ and
$\Delta^2 + 1 = 10$ — equality. It is square-free, has diameter two, and has no
hub. Its largest independent set has size $4$, and since $3 \times 4 = 12 \ge 10$,
it *can* be $3$-colored. And indeed its chromatic number is exactly three. This is
consistent with the conjecture, because Petersen's degree, $3$, is far below the
threshold of $17$.

**The Hoffman–Singleton graph** is the crown jewel: $50$ vertices, each of degree
$7$, with $\Delta^2 + 1 = 50$ — again equality. It too is square-free, of diameter
two, and hub-free. But now its largest independent set has size only $15$, so
$3 \times 15 = 45 < 50$: three independent sets cannot cover all fifty vertices,
and indeed its chromatic number is **four**. Here, already at degree $7$, three
colors have failed.

The Hoffman–Singleton graph is doing more than illustrating the conjecture — it is
whispering that the true threshold is far below $17$. Phase-A analysis conjectures
the sharp cutoff is around $\Delta = 8$: the last three-colorable examples vanish
just above the Hoffman–Singleton degree of $7$. The number $17$ in the headline
conjecture is a safe, provable frontier, not the sharp edge; the sharp edge is one
of the tantalizing open questions.

## Why these graphs are so rare — and so beautiful

There is a deeper reason the Petersen and Hoffman–Singleton graphs keep appearing.
The graphs that meet the Moore bound with equality, $|V| = \Delta^2 + 1$, are
called **Moore graphs of diameter two**. A celebrated theorem says these can exist
only for a handful of degrees: $\Delta = 2$ (the pentagon), $\Delta = 3$ (Petersen),
$\Delta = 7$ (Hoffman–Singleton), and *possibly* $\Delta = 57$ — a graph on $3250$
vertices whose existence remains unknown after decades of searching. The very same
equality case surfaces in our cherry inequality: a square-free diameter-two graph
that turns $\sum_v \binom{\deg v}{2} \le \binom{|V|}{2}$ into an equation is exactly
one of these Moore graphs. So the sharp cases of *both* pillars single out the same
rare, hyper-symmetric objects. It is no coincidence — it is the fingerprint of the
rigidity that makes the whole conjecture plausible.

## What remains, and why it matters

The three inequalities are settled facts. What is still open is the leap from
counting to coloring: proving rigorously that the independence number really is
$O(\Delta)$, and converting that into a lower bound on the chromatic number. The
most promising routes sharpen the heuristic above into a theorem (conjecturally
$\alpha \le 2\Delta$), or relax the problem to *fractional* coloring — where colors
may be split into probabilistic mixtures — and show that even this generous
relaxation forbids a value of three once $\Delta \ge 17$.

Why care about a statement concerning square-free two-handshake networks? Because
these constraints are the mathematical DNA of efficient, robust systems:
communication networks that keep everyone close without redundant bottlenecks,
error-correcting codes whose codewords avoid short cycles, and combinatorial
designs where every pair of points meets in a unique line. In all of these,
"square-free and diameter two" is not an abstraction but a design goal — and
knowing that such systems are chromatically rigid tells engineers and
mathematicians alike exactly how much structure they are buying, and what it
costs. The conjecture, and the three pillars beneath it, are a map of that
trade-off, drawn in the pure language of vertices, edges, and colors.
