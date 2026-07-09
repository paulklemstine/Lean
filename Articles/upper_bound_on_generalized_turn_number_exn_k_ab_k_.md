# How Many Grids Can Hide in a Graph Without a Book?

## A counting problem at the heart of combinatorics

Imagine a vast social network: millions of people, each pair either friends or
strangers. Hidden inside this tangle of connections are countless little
patterns — triangles of mutual friends, stars of popular hubs, and more
elaborate shapes. A recurring question in the mathematics of networks is
deceptively simple to state and surprisingly deep to answer: *if we forbid one
particular pattern from appearing, how many copies of another pattern can still
survive?*

This is the modern face of one of combinatorics' oldest games, **extremal graph
theory**. The classical version asks how many *edges* a graph can have while
avoiding a forbidden shape. The contemporary version — the **generalized Turán
problem** — is richer: it asks how many *copies of a chosen shape* can coexist
with a forbidden one. Writing $\mathrm{ex}(n, H, F)$ for the largest number of
copies of a graph $H$ that can appear inside an $n$-vertex graph containing no
copy of the forbidden graph $F$, the goal is to understand this quantity as the
network grows.

This article tells the story of one clean, complete answer in this landscape.
The shapes involved are **complete bipartite graphs** — the "grids" and "books"
of the network world — and the punchline is a crisp growth law: no matter how
cleverly you wire up your network, if you ban a certain book, the number of
grids can grow no faster than the *cube* of the number of vertices.

## The cast of characters: grids and books

A **complete bipartite graph** $K_{a,b}$ is built from two teams of vertices,
one of size $a$ and one of size $b$, with every player on the first team joined
to every player on the second team — and no edges within a team. Picture an
$a \times b$ grid of connections: it is the purest form of "everyone here knows
everyone there."

Two such graphs star in our story:

- $K_{a,b}$, with $3 \le a \le b$, is the pattern we **count**. Think of it as a
  small, dense committee split into two fully-cooperating factions.
- $K_{3,b+1}$ is the pattern we **forbid**. It is a slightly lopsided grid: three
  vertices on one side, $b+1$ on the other, all cross-connections present. This
  is the "book" we ban from the network.

The question is then exact: **In an $n$-vertex network that contains no copy of
$K_{3,b+1}$, how many copies of $K_{a,b}$ can there be?**

## The answer

**Main Theorem.** *For all integers $a, b$ with $3 \le a \le b$, there is a
constant $C > 0$ such that every $n$-vertex graph containing no copy of
$K_{3,b+1}$ has at most $C \, n^3$ copies of $K_{a,b}$. Explicitly, one may take
$C = \binom{b}{\,a-3\,}$, so that the number of copies is at most
$\binom{b}{a-3}\, n^3$.*

In the compact language of the generalized Turán function,

$$\mathrm{ex}\bigl(n,\, K_{a,b},\, K_{3,b+1}\bigr) = O\!\left(n^3\right).$$

The remarkable feature is the *exponent*. A single copy of $K_{a,b}$ uses
$a + b \ge 6$ vertices. If copies could be placed freely, one might naively
expect on the order of $n^{a+b}$ of them — a wildly larger number. Forbidding the
book $K_{3,b+1}$ collapses this count all the way down to cubic growth. The
"three" in the exponent is no accident: it is precisely the "three" in the
forbidden $K_{3,b+1}$, and it enters through a beautiful counting maneuver.

## The idea of the proof: anchor on a triple

The engine behind the theorem is a double-counting argument in the spirit of the
classical **Kővári–Sós–Turán theorem**. It rests on a single, vivid observation
about what forbidding $K_{3,b+1}$ actually means.

Given a set $S$ of vertices, call a vertex $w$ a **common neighbor** of $S$ if
$w$ is joined to *every* vertex of $S$. The common neighbors of $S$ form its
**common neighborhood**, written $N(S)$.

Now here is the key translation:

**Common-neighborhood cap.** *A graph contains no copy of $K_{3,b+1}$ if and only
if every set of three vertices has at most $b$ common neighbors.*

Why? A copy of $K_{3,b+1}$ is exactly a triple of vertices together with $b+1$
other vertices all joined to each of the three. So the triple would need $b+1$
common neighbors. Ban the copy, and every triple is capped at $b$ common
neighbors. This is the entire content of the forbidden pattern, repackaged into a
local counting statement — and it is where the "three" lives.

With this cap in hand, the count proceeds in two moves.

**Move 1: Anchor every grid on a triple.** Any copy of $K_{a,b}$ has an $a$-side
with $a \ge 3$ vertices. Choose three of them; this triple $S$ *anchors* the copy.
So instead of counting copies directly, we count pairs (triple $S$, copy anchored
at $S$). Every copy is caught at least once, because it always contains at least
one anchoring triple.

**Move 2: Bound the copies at each anchor.** Fix a triple $S$. In any copy
anchored at $S$, the entire $b$-side must be joined to all of $S$ — so the
$b$-side lives inside the common neighborhood $N(S)$, which has at most $b$
vertices. Meanwhile the rest of the $a$-side, the $a - 3$ vertices beyond $S$,
must be joined to the whole $b$-side, so they too are confined to a common
neighborhood of size at most $b$. Counting the ways to choose these pieces gives
at most

$$\binom{b}{b}\binom{b}{a-3} = \binom{b}{a-3}$$

copies anchored at any single triple. (Here $\binom{b}{b} = 1$ counts the only
way to fill the $b$-side once its host neighborhood has exactly $b$ vertices.)

**Assembling the count.** There are $\binom{n}{3}$ triples in an $n$-vertex
graph, and each anchors at most $\binom{b}{a-3}$ copies, so the total number of
copies is at most

$$\binom{n}{3} \binom{b}{a-3} \;\le\; \binom{b}{a-3}\, n^3.$$

That is the theorem. The whole argument fits in a paragraph, yet it pins down the
exact growth rate.

## Two ways to read the same fact

Once a combinatorial bound is in hand, it can be dressed in the language of
analysis, where it reveals two complementary readings.

**A growth law.** For any growing family of $K_{3,b+1}$-free networks
$G_1, G_2, G_3, \dots$ (with $G_n$ on $n$ vertices), the copy count
$f(n) = \#\{\text{copies of } K_{a,b} \text{ in } G_n\}$ satisfies

$$f(n) = O\!\left(n^3\right),$$

with the leading constant equal to the very same combinatorial number
$\binom{b}{a-3}$ produced by the counting argument. The extremal constant is not
lost in translation; it *is* the analytic constant.

**A vanishing density.** Since a labelled copy of $K_{a,b}$ occupies $a+b \ge 6$
vertex slots, it is natural to compare the copy count to the number of ways to
place $a+b$ vertices, roughly $n^{a+b}$. The theorem says the ratio collapses:

$$\frac{\#\{\text{copies of } K_{a,b}\}}{n^{a+b}} \longrightarrow 0
\qquad \text{as } n \to \infty.$$

In probabilistic terms: if you drop $a+b$ vertices at random into a large
$K_{3,b+1}$-free network, the chance that they happen to form the grid $K_{a,b}$
tends to zero. The forbidden book makes grids vanishingly rare, not just
bounded in number.

## Why it matters

Complete bipartite patterns are everywhere once you look. In **incidence
geometry**, forbidding a $K_{s,t}$ is the language of the Zarankiewicz problem —
how many ones can a large 0–1 matrix hold without a solid $s \times t$ block? In
**database and coding theory**, the same grids describe forbidden configurations
of records or codewords. In the theory of **random graphs**, statements about
vanishing copy density are exactly the "first-moment" estimates used to locate the
thresholds at which structures suddenly appear. The clean cubic law here is a
sharp instance of a phenomenon that recurs across all these fields: *a single
forbidden dense pattern imposes a severe, quantifiable ceiling on every related
dense pattern.*

There is also aesthetic pleasure in how tightly the pieces fit. The exponent
$3$ is inherited directly from the $3$ in the forbidden $K_{3,b+1}$. The
constant $\binom{b}{a-3}$ records exactly how the two sides of the counted grid
interact with the cap of $b$ common neighbors. And the argument — anchor,
localize, multiply — is elementary enough to explain over coffee, yet it settles
the growth rate completely.

## The road ahead

The cubic upper bound is one half of a sharper truth. The number $O(n^3)$ is
believed — and in the full theory, known — to be *tight*: there exist
$K_{3,b+1}$-free networks with on the order of $n^3$ copies of $K_{a,b}$, so the
true answer is $\Theta(n^3)$, matched above and below. Building those extremal
networks explicitly, and thereby closing the gap to a two-sided asymptotic law,
is the natural next chapter.

Beyond that lie tantalizing generalizations: replace the forbidden $K_{3,b+1}$
by a general $K_{s,t}$ and the exponent should climb from $3$ to $s$; sharpen the
constant $\binom{b}{a-3}$ toward its true optimal value; and follow the bridges
into incidence geometry and random-graph thresholds, where the same counting
heartbeat sounds again.

For now, the moral is clean and quotable. Ban one modest book from your network,
and no matter how you build it, the grids you were hoping to count can grow no
faster than the cube of its size — and, measured against the space they could
occupy, they all but disappear.
