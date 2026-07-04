# When Choices Cost More Than Colors

## A conjecture, a surprise, and a tiny graph that says "no"

Imagine you are handed a map and asked to color its regions so that no two
neighboring regions share a color. This is the oldest and most famous puzzle in
graph theory, and its answer—the Four Color Theorem—is a triumph of modern
mathematics: four colors always suffice for any map drawn in the plane.

But suppose the rules change slightly. Instead of a single global palette, each
region comes with its *own* short list of permitted colors. Your neighbor's
house may only be paintable in red or green; the town hall only in blue or
yellow. Every region still has, say, four colors to choose from, but the lists
differ from place to place. Can you *always* finish the job?

This is the world of **list coloring**, and it hides a beautiful and slightly
unsettling truth: having enough colors *on paper* is not the same as having
enough *choices*. This article tells the story of a natural conjecture about
planar maps, why it turns out to be false, and how a single graph with just six
vertices captures the whole phenomenon in miniature.

## The conjecture: four choices for three-colorable maps

Let us set the stage precisely. A **graph** is a collection of vertices, some
pairs joined by edges. A **proper coloring** assigns a color to each vertex so
that the two endpoints of every edge receive different colors. The smallest
number of colors that lets you do this is the **chromatic number**, written
$\chi(G)$.

Now the twist. A **list assignment** is a rule $L$ that gives each vertex $v$ a
finite set $L(v)$ of allowed colors. A **proper list coloring** is a proper
coloring $c$ that additionally respects every list: $c(v) \in L(v)$ for all
$v$. We say a graph is **$k$-choosable** if *no matter how* the lists are drawn,
so long as each list has at least $k$ colors, a proper list coloring exists. The
smallest such $k$ is the **list chromatic number** (or **choice number**),
written $\mathrm{ch}(G)$.

Because you can always hand every vertex the *same* list of $k$ colors,
$k$-choosability is at least as demanding as ordinary $k$-colorability:
$$\mathrm{ch}(G) \ge \chi(G).$$
Choices can only make life harder, never easier.

The Four Color Theorem says every planar graph has $\chi(G) \le 4$. A famous
later result of Thomassen says every planar graph is $5$-choosable, and Voigt
showed there are planar graphs that are *not* $4$-choosable—so for planar maps,
list coloring genuinely costs one extra color.

Against this backdrop, one might hope for a refinement. Planar graphs that are
already *easy* to color—say, three-colorable—should surely need fewer choices.
This is the **conjecture at the heart of this cycle**:

> *Every $3$-colorable planar graph is $4$-choosable.*

It is clean, plausible, and—as it happens—**false**. A $63$-vertex
$3$-colorable planar graph refutes it: it can be properly colored with three
colors, yet there is a way to hand each vertex four permitted colors that makes
a proper list coloring impossible. Low chromatic number, it turns out, provides
no control at all over the number of choices you need.

## The smallest place the surprise already lives

A $63$-vertex counterexample is convincing, but it is hard to hold in your head.
The real lesson—**colorability does not control choosability**—can be witnessed
by something far smaller, and we can pin it down completely. We only have to
step down to the simplest interesting number of colors, $k = 2$, and ask the
analogous question: is every $2$-colorable planar graph $2$-choosable?

The answer is again no, and the witness is a graph you could sketch on a napkin:
the **complete bipartite graph** $K_{2,4}$.

Picture two "small" vertices on the left, call them $a_0$ and $a_1$, and four
"big" vertices on the right, call them $b_0, b_1, b_2, b_3$. Every left vertex is
joined to every right vertex; the two left vertices are not joined to each other,
and neither are the four right vertices. This graph is:

- **Planar.** You can draw it in the plane without edge crossings.
- **Bipartite, hence $2$-colorable.** Paint all of the left side color $0$ and
  all of the right side color $1$; every edge runs between the sides, so no edge
  is monochromatic. Thus $\chi(K_{2,4}) = 2$.

And yet $K_{2,4}$ is **not** $2$-choosable. To see it, we exhibit a specific
assignment of two-element lists that cannot be satisfied.

## The diagonal trap

Here is the assignment. Give the two left vertices *disjoint* lists:
$$L(a_0) = \{0,1\}, \qquad L(a_1) = \{2,3\}.$$
Now give the four right vertices the four possible **cross pairs**, one color
drawn from each left list:
$$L(b_0)=\{0,2\}, \quad L(b_1)=\{0,3\}, \quad L(b_2)=\{1,2\}, \quad L(b_3)=\{1,3\}.$$
Every list has exactly two colors, so this is a legitimate test of
$2$-choosability.

Now try to color it. The left vertex $a_0$ must take a color $\alpha \in
\{0,1\}$, and $a_1$ must take a color $\beta \in \{2,3\}$. That is one of exactly
four combinations: $(\alpha,\beta)$ is $(0,2)$, $(0,3)$, $(1,2)$, or $(1,3)$.

Whichever pair you pick, look at the right vertex whose list is *precisely*
$\{\alpha,\beta\}$—it always exists, because the four right lists are exactly the
four cross pairs. That vertex is joined to both $a_0$ and $a_1$. But $a_0$ has
already eaten $\alpha$ and $a_1$ has already eaten $\beta$, so *both* of the only
colors available to that right vertex are forbidden. It cannot be colored. The
trap springs no matter what you do on the left.

This is the entire argument, and it is airtight: a finite check over just four
cases. The graph is planar, it is $2$-colorable, and it defeats every possible
assignment strategy against these particular two-element lists. Therefore
$$\mathrm{ch}(K_{2,4}) \ge 3 > 2 = \chi(K_{2,4}).$$

We record the headline result cleanly:

> **Theorem (Choices exceed colors).** There is a planar graph—namely
> $K_{2,4}$—that is $2$-colorable but not $2$-choosable.

This is the exact $k=2$ shadow of the $63$-vertex refutation at $k=4$: in both
cases a graph with a small chromatic number is forced to have a strictly larger
list chromatic number. The phenomenon is not a quirk of large intricate
constructions; it is present already in one of the most elementary graphs there
is.

## Why the gap opens

What is the mechanism? Ordinary coloring lets *all* vertices coordinate around
one shared palette. List coloring breaks that coordination: each vertex's
options are chosen by an adversary, and the adversary can arrange for the small
"controlling" side of the graph to *use up* exactly the colors that some other
vertex desperately needs. In $K_{2,4}$, the two left vertices act as a control
panel with four possible settings, and there is one right vertex booby-trapped
for each setting.

This immediately suggests how to make the gap as large as you like. The same
idea scales: give a small side disjoint $k$-element lists and give a large side
*all* the ways of picking one color from each, and some large-side vertex will
always be blocked. Concretely, the complete bipartite graph $K_{k,\,k^k}$ fails
to be $k$-choosable, even though—being bipartite—it never needs more than two
colors. **Bipartite graphs, the very tamest colorable graphs, have unbounded
list chromatic number.**

## What *does* control choosability

If chromatic number is the wrong dial, what is the right one? The honest answer
is **local sparsity**. A simple greedy argument shows:

> **Theorem (Degree bound).** If every vertex of $G$ has fewer than $k$
> neighbors—more generally, if the vertices can be ordered so each has fewer than
> $k$ earlier neighbors—then $G$ is $k$-choosable.

Process the vertices in that order; when you reach a vertex, fewer than $k$ of
its neighbors are already colored, so among its $\ge k$ list colors at least one
survives. Choose it and move on. Nothing about the *global* palette is
needed—only the number of *already-committed* neighbors at each step.

This is why the planar story ends where it does. Every planar graph has a vertex
of degree at most five in each of its subgraphs, and the greedy argument then
delivers Thomassen's theorem that **every planar graph is $5$-choosable**. Voigt's
planar non-$4$-choosable graph shows the five is best possible. The list
chromatic number of planar graphs is exactly $5$, one more than the chromatic
number of $4$—and the conjecture we started with, hoping that being
$3$-colorable would buy back that lost color, simply does not hold.

## The moral

The tale of $K_{2,4}$ is a small parable about a large theme in mathematics:
*global structure and local resources are different currencies.* The chromatic
number measures whether a coloring exists under ideal, coordinated conditions.
The list chromatic number measures robustness against an adversary who controls
your options one vertex at a time. They coincide often enough to lull us into
expecting them to coincide always—and then a six-vertex graph, drawn on a
napkin, quietly proves otherwise.

Coloring, it turns out, is easy. It is *choosing* that is hard.
