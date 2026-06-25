# One Graph to Forbid Them All: The Hunt for Single Obstructions Below Density 3/2

## A children's game with a deep secret

Imagine you are handed a box of toy networks — dots connected by lines, what
mathematicians call *graphs*. You are asked to sort them into two piles by a
single rule: "throw away any network that contains a triangle." Easy enough. But
now notice something subtle. If a network has no triangle, then *shrinking* it —
deleting a dot, erasing a line, or fusing two connected dots into one — can never
*create* a triangle. The property "triangle-free" is preserved as you simplify.

Families of networks that survive simplification like this are called
**minor-closed classes**, and they are one of the crown jewels of modern
combinatorics. The word "minor" is the technical name for "a smaller network you
can obtain by deleting and shrinking." A class is *minor-closed* when, whenever a
network belongs to it, every smaller network you can carve out of it belongs too.

Planar networks — those you can draw on paper without lines crossing — form a
minor-closed class. So do forests (networks with no cycles), networks that fit on
a doughnut, networks of bounded "tree-width," and countless others. These classes
are everywhere in computer science, where they delineate exactly the problems that
go from impossibly hard to efficiently solvable.

This article is about a beautiful organizing principle for such classes, and about
a sharp numerical frontier — the number **3/2** — beyond which the wild diversity
of minor-closed classes suddenly tames into something almost rigidly simple. Every
claim below corresponds to a fully machine-checked theorem.

## Forbidden patterns: the Robertson–Seymour philosophy

Here is the first miracle. Take *any* minor-closed class. It turns out you can
always describe it by a list of "forbidden patterns" — a set of networks none of
which is allowed to appear as a minor. Planar networks, for instance, are exactly
the networks that forbid two specific patterns (the complete network on five dots,
$K_5$, and the "three houses, three utilities" network $K_{3,3}$). Forests are
exactly the networks that forbid every cycle.

We can make this precise. Given a set $S$ of networks, define the class

$$\mathrm{excl}(S) = \{\, x \mid \text{no member of } S \text{ is a minor of } x \,\}.$$

In words: $\mathrm{excl}(S)$ is everything that avoids all the patterns in $S$.
The first basic fact is that this is *always* a legitimate minor-closed class —
if you avoid a pattern, anything smaller still avoids it:

> **Excluding a pattern keeps you closed.** For every set $S$, the class
> $\mathrm{excl}(S)$ is minor-closed.

The deeper fact runs in reverse. Suppose we agree that the minor relation is
*well-founded* — meaning you cannot shrink a network forever; every downward
chain eventually bottoms out. (For finite networks this is automatic.) Then every
minor-closed class is itself an exclusion class, and we can even say *which*
patterns to forbid. The right list is the set of **minimal obstructions**: the
networks that are *not* in the class, but all of whose proper minors *are*. These
are the smallest possible "first offenders."

$$\mathrm{obstructions}(C) = \{\, m \mid m \notin C \text{ and every } x < m \text{ lies in } C \,\}.$$

> **Every minor-closed class is an exclusion class.** If $C$ is minor-closed (over
> a well-founded minor order), then $C = \mathrm{excl}(\mathrm{obstructions}(C))$.

This is the easy, order-theoretic heart of the celebrated Robertson–Seymour
program. The hard part of their work proves that this obstruction list is always
*finite*; what we capture here, with complete rigor, is the cleaner structural
skeleton: a minor-closed class and its set of minimal obstructions are two faces
of the same coin.

## The simplest possible classes: one forbidden pattern

Now we can ask a sharp question. Some classes need long lists of forbidden
patterns. Others need very few. What is the *simplest* kind of minor-closed class?

The answer: a class characterized by **a single forbidden minor** — one pattern
$H$ such that the class is exactly $\mathrm{excl}(\{H\})$. The triangle-free
example we started with is precisely $\mathrm{excl}(\{\triangle\})$. These
single-pattern classes are the atoms of the theory, and they have a crisp
signature. Forbidding one pattern $H$ produces a class whose *only* minimal
obstruction is $H$ itself:

> **One pattern, one obstruction.** The minimal obstructions of $\mathrm{excl}(\{H\})$
> are exactly $\{H\}$.

And the converse holds too, giving a perfect dictionary between the two notions:

> **The single-forbidden-minor dictionary.** A minor-closed class is described by
> a single forbidden pattern *if and only if* its set of minimal obstructions is a
> single network.

This is the conceptual centerpiece. "Being defined by one rule" and "having one
smallest offender" are literally the same condition. To check whether a complicated
class has a clean one-line description, you no longer have to guess the rule — you
just count its minimal obstructions and ask whether there is exactly one.

## Enter density: a numerical thermometer

So far everything is combinatorial. Now we introduce a number that measures how
"heavy" a network is: its **edge density**, the ratio of lines to dots,

$$\rho(G) = \frac{|\text{edges of } G|}{|\text{dots of } G|}.$$

A sparse network like a path has density just under $1$. A dense network like a
complete graph has density growing without bound. For a whole class of networks we
track its *limiting density* — how heavy its members are allowed to get as they
grow large.

The number $3/2$ marks a remarkable phase boundary. By a classical bookkeeping
identity — every edge has two endpoints, so the degrees of all dots add up to
twice the number of edges — a density of $3/2$ corresponds to an *average degree
of $3$*. Below that line, networks are forced to be genuinely thin: most dots have
only one or two neighbors. The mission behind this work is a striking conjecture:

> **The 3/2 conjecture.** Every minimal minor-closed class whose limiting density
> stays above some fixed $\delta < 3/2$ can be defined by a *single* forbidden
> minor.

In other words, just below the magic threshold $3/2$, the messy world of
minor-closed classes collapses into the simplest possible kind — the
single-pattern atoms. This article reports two concrete, fully verified pillars of
that program, populating the region below $3/2$ with explicit, structurally
different families.

## Pillar one: forests live below the line

The first inhabitant is the most classical sparse family of all — **forests**, the
networks with no cycles. A forest can be enormous, but it can never close a loop.

A foundational counting fact about forests is that a non-empty forest on $|V|$ dots
has at most $|V| - 1$ edges; equivalently,

$$|E| + 1 \le |V|.$$

A tree (a connected forest) achieves equality, $|E| + 1 = |V|$, which immediately
pins its density strictly below $1$. The same bound carries to every forest:

> **Forests are sparse.** Every finite forest has edge density strictly below
> $3/2$ (indeed, strictly below $1$).

And crucially, the forest family is minor-closed in the relevant sense: any
subgraph of an acyclic network is acyclic, so deleting parts of a forest can never
manufacture a cycle. Forests thus form a bona fide minor-closed class sitting
comfortably below the $3/2$ line, with limiting density exactly $1$. They are the
prototypical citizen of the region the conjecture is about.

## Pillar two: a second, richer witness — bounded degree

Forests are the *acyclic* extreme. The natural worry is that everything below
$3/2$ might just be "forests in disguise." The second pillar dispels that worry by
exhibiting a structurally *different* family that still lives below the line: the
networks of **maximum degree at most $2$**.

A network in which every dot touches at most two lines is, by an elementary
classification, a disjoint union of **paths and cycles** — nothing more
complicated can occur. Unlike forests, these networks are allowed to contain
cycles, and arbitrarily many of them. Yet they remain thin. The same handshaking
identity does the work: if every dot has degree at most $2$, then the degrees sum
to at most $2|V|$, and since they also sum to $2|E|$, we get

$$2|E| = \sum_v \deg(v) \le 2|V| \quad\Longrightarrow\quad |E| \le |V|.$$

Therefore the density never exceeds $1$:

> **Bounded-degree networks are sparse.** Every finite network of maximum degree
> at most $2$ has edge density strictly below $3/2$ (indeed at most $1$).

This family is also minor-closed in the subgraph sense, for a simple monotonicity
reason: deleting lines can only *lower* the degree of every dot, so the maximum
degree can only go down.

> **Degree is monotone.** If $G$ is a subgraph of $G'$, then the maximum degree of
> $G$ is at most the maximum degree of $G'$. Consequently the class of networks of
> maximum degree at most any fixed bound $d$ is minor-closed.

Here is the punchline that makes this a genuinely new witness rather than a
restatement of the forest result. A cycle on $n$ dots, $C_n$, has exactly $n$ dots
and $n$ edges, so $|E| = |V|$ — the bound $|E| \le |V|$ is *tight*. Cycles have
maximum degree $2$ but they are *not* forests. So the bounded-degree family is
strictly larger than the forest family while remaining below $3/2$. The region
below the threshold is not a one-family desert; it is populated by structurally
distinct, single-parameter constrained families — exactly the landscape in which
the single-forbidden-minor phenomenon is conjectured to reign.

## Why two different witnesses matter

Picture the line at density $3/2$ as a coastline. The conjecture says that all the
"minimal" land just inland from this coast is made of the same simple bedrock —
single-pattern classes. To trust such a sweeping claim you want to see that the
inland territory is *real* and *varied*, not a single artificial outcropping. The
two pillars do exactly this:

- **Forests** show the *acyclic* corner of the territory, density floor $1$.
- **Bounded-degree-$2$ graphs** show a *cyclic* corner — same density floor $1$,
  yet containing every cycle, which no forest can.

Two qualitatively different families, both provably below $3/2$, both genuinely
minor-closed. Together with the order-theoretic dictionary — "single forbidden
minor" equals "single minimal obstruction" — they reduce the grand conjecture to a
pair of crisp, falsifiable sub-questions:

1. *Largeness from density.* Does staying above $\delta$ near $3/2$ force a class
   to swallow the entire bounded-degree-$2$ family (all paths and cycles) as a
   floor?
2. *Maximality forces a singleton.* Among the proper classes avoiding a fixed
   pattern, the largest one is $\mathrm{excl}(\{H\})$ — does *being* such a maximal
   avoider force the minimal-obstruction antichain to collapse to a single graph?

If both hold, a minimal class above the density floor must be a maximal avoider,
and maximal avoiders have a single obstruction — which is exactly a single
forbidden minor. The whole edifice is assembled from finite combinatorics and the
well-foundedness of the minor order, with no appeal to deep structure theory.

## A worked miniature

Let us make the dictionary tangible. Take the class of triangle-free networks,
$\mathrm{excl}(\{K_3\})$, where $K_3$ is the triangle. Its only minimal
obstruction is $K_3$ itself: a triangle is not triangle-free, but every proper
minor of a triangle (an edge, two edges, a path) *is* triangle-free. So the
obstruction set is the single network $\{K_3\}$ — and by the dictionary, the class
is genuinely a single-forbidden-minor class. Conversely, if someone hands you a
mysterious minor-closed class and you discover it has two incomparable smallest
offenders, you know *for certain* it cannot be captured by any one forbidden
pattern.

Now overlay the density picture. The triangle-free networks are *not* below
$3/2$ — they can be very dense (think of complete bipartite graphs). But the
forest class $\mathrm{excl}(\{\text{all cycles}\})$ and the bounded-degree-$2$
class both *are*. The conjecture predicts that as we slide minimal classes toward
the $3/2$ coast, each one must ultimately wear a single forbidden-minor badge — and
the two pillars guarantee there is a rich, non-trivial coastline for that
prediction to govern.

## The view from here

What makes this story satisfying is the interplay of two completely different kinds
of mathematics. On one side, pure order theory: the lattice of minor-closed
classes, the perfect duality between forbidden patterns and minimal obstructions,
the well-foundedness that lets us always find a smallest offender. On the other,
hands-on combinatorics: handshaking identities, degree counts, the humble
observation that a cycle has as many edges as dots.

The number $3/2$ is where these two worlds meet. It is the precise altitude at
which sparseness becomes so severe that the only minimal minor-closed classes left
standing are the simplest imaginable — each one definable by forbidding a single
graph. We have planted two flags firmly in that territory and reduced the summit to
two clean, attackable conjectures. The single forbidden minor, it seems, really may
be one graph to forbid them all.
