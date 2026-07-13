# When Every Neighborhood Has a Loud Voice, So Does the Whole Room

## A small local law with a big global consequence

Imagine a very large committee that must reach a single yes-or-no verdict on
every possible way of filling a slate of offices. There are $n$ offices to fill,
and for each office there are $m$ candidates. A *slate* is one choice of
candidate per office — a tuple $x = (x_1, x_2, \dots, x_n)$, where $x_i$ names the
person chosen for office $i$. The committee's collective opinion is a rule $f$
that assigns to every slate a single verdict, "approve" or "reject."

Now ask a natural question about power. **How much does any one office matter?**
If we hold every other office fixed and swap out only the candidate for office
$i$, does the committee's verdict ever flip? If it does, office $i$ has real
influence over the outcome. If swapping candidates for office $i$ never changes a
single verdict, then that office is, in effect, a rubber stamp.

This is the modern, combinatorial face of a classical idea. In 1988, Jeff Kahn,
Gil Kalai, and Nathan Linial proved a celebrated theorem about Boolean functions
— rules that take $n$ yes/no inputs and return a single yes/no answer. Their
KKL theorem says, roughly, that a "balanced" rule cannot spread its sensitivity
evenly and thinly across all its inputs: *some* input must be surprisingly
influential. Influence, it turns out, refuses to stay uniformly diluted.

The story told here is about lifting that principle from the humble two-candidate
world ($m = 2$, the Boolean cube) to a far richer stage: an arbitrary number of
candidates per office, arranged as a *partite complex*. And the punchline is a
clean **local-to-global law**: if influence is guaranteed to be loud in every
small neighborhood of the structure, then it is provably loud in the structure as
a whole.

## The geometry hiding in the committee

There is a beautiful piece of geometry underneath the committee metaphor. Group
the candidates by office: office $1$ has its own pool of $m$ people, office $2$
has another pool of $m$ people, and so on, with $n$ pools in total and no person
serving two offices. A valid slate picks exactly one person from each pool. In
the language of geometry, the pools are the *color classes* of a
**complete $n$-partite complex**, and the slates are its top-dimensional cells,
called **facets** or **transversals**: one vertex chosen from each color.

Two slates are **$i$-adjacent** when they are identical in every office except
office $i$, where they disagree. Picture all slates as points and draw an edge
between every $i$-adjacent pair; you get the $i$-th "direction" of a giant
generalized grid. The **influence of office $i$**, written $\mathrm{Inf}(f, i)$,
is simply the number of these $i$-direction edges across which the verdict flips:

$$\mathrm{Inf}(f, i) = \#\bigl\{(x, y) : x_k = y_k \text{ for all } k \neq i,\; x_i \neq y_i,\; f(x) \neq f(y)\bigr\}.$$

The more edges of direction $i$ are "sensitive," the more that office matters.

When $m = 2$ — two candidates per office — a slate is nothing but a string of
bits, the grid is the ordinary Boolean hypercube, and $\mathrm{Inf}(f, i)$ is the
classical edge-boundary influence of the $i$-th bit. So everything below contains
the familiar Boolean cube as its simplest special case.

## Links: zooming in on a neighborhood

The heart of local-to-global reasoning is the idea of a **link**. Fix one office
$j$ and pin it to a specific candidate $b$. Now look only at the slates that
choose $b$ for office $j$. This slice is the **link of the vertex $(j, b)$** —
a smaller copy of the same kind of structure, with one office removed and one
candidate locked in place.

Each vertex $(j, b)$ has its own link, and since office $j$ has $m$ candidates,
office $j$ generates exactly $m$ links. Inside a single link we can measure
influence just as before, but confined to the slice. We write
$\mathrm{InfSub}(f, j, b, i)$ for the number of sensitive $i$-edges that lie
entirely within the link of $(j, b)$:

$$\mathrm{InfSub}(f, j, b, i) = \#\bigl\{(x, y) : x_k = y_k \text{ for } k \neq i,\; x_i \neq y_i,\; f(x) \neq f(y),\; x_j = b\bigr\}.$$

This is the *local* view: influence as seen from inside one neighborhood of the
complex.

## The bridge: influence is exactly self-averaging

Here is the identity that makes everything work — simple to state, and
surprisingly powerful:

> **The Self-Averaging Bridge.** For any office $j$ and any office $i$, the global
> influence of $i$ is exactly the sum of its link influences across the $m$ links
> of $j$:
> $$\mathrm{Inf}(f, i) = \sum_{b=1}^{m} \mathrm{InfSub}(f, j, b, i).$$

Why is this true? Every sensitive $i$-edge connects two slates $x$ and $y$ that
agree everywhere except office $i$. In particular they agree at office $j$, so
they belong to *one and the same* link — the link of whatever candidate they
both chose for office $j$. Thus the $m$ links of office $j$ partition the
sensitive $i$-edges into disjoint groups, with no edge lost and none
double-counted. Add the groups back up and you recover the whole. This is not an
approximation, an inequality, or an averaging bound with error terms; it is an
exact bookkeeping equality. That exactness is precisely what lets us see effects
— like the dependence on the alphabet size $m$ — that fuzzier arguments miss.

Two immediate consequences fall out. First, every link influence is at most the
global influence, $\mathrm{InfSub}(f, j, b, i) \le \mathrm{Inf}(f, i)$, because a
single non-negative summand never exceeds the total. So **a coordinate that is
influential in even one neighborhood is at least that influential in the whole
complex**. Second, summing the bridge over all offices $i \neq j$ shows that the
total influence of the complex (excluding the pinned office) equals the sum, over
the $m$ links of $j$, of the influence living inside each link.

## From loud neighborhoods to a loud room

Now the payoff. Suppose we have a *local* guarantee: every one of the $m$ links
of office $j$ is influential, in the sense that the total influence living inside
each link is at least some threshold $T$. This is exactly the kind of hypothesis
a KKL-type theorem provides *on each link* — a promise that no neighborhood is
silent.

Summing the bridge, the total influence of the complex (over the offices other
than $j$) is at least $m \cdot T$: the $m$ neighborhoods each contribute at least
$T$, and their contributions add without overlap. There are only $n - 1$ offices
other than $j$ to share this total among, so by the pigeonhole principle *some*
office $i \neq j$ must carry at least the average:

> **Local-to-Global KKL Theorem (partite form).** Fix an office $j$ in the
> complete $n$-partite complex with $n \ge 2$ offices and $m$ candidates each. If
> every one of the $m$ links of $j$ carries total influence at least $T$, then
> some office $i \neq j$ has global influence at least the average
> $\dfrac{mT}{\,n-1\,}$.

A local promise repeated across $m$ neighborhoods becomes a global existence
statement: *there is a genuinely influential coordinate.* This is the
local-to-global phenomenon in its cleanest form, and it is exactly the shape of
argument that powers modern high-dimensional expander theory, where global
behavior is repeatedly deduced from the behavior of links.

Notice what the alphabet size $m$ does. Enlarging the candidate pool multiplies
the number of links of a single office, and because the bridge is an *exact* sum,
each new link pours strictly more sensitive edges into the global tally rather
than merely reshuffling a fixed budget. The guaranteed global influence
$mT/(n-1)$ grows linearly in $m$. In the two-candidate world this dependence is
invisible; only with an arbitrary alphabet, and only with an exact identity, does
it come into view.

## The sharp boundary of triviality

Every theorem about "something must be large" needs to know when the conclusion
could be vacuous. Here the boundary is astonishingly crisp:

> **The Degeneracy Dichotomy.** If every office has zero influence — that is, no
> single-office swap ever changes the verdict — then the committee's rule is
> constant: it returns the same verdict on every slate.

There is no murky middle ground. A rule is either *globally degenerate* (constant,
with the KKL conclusion vacuously empty) or it has a coordinate that swings some
verdict, and then the local-to-global machinery has something real to grip. The
KKL conclusion fails to say anything only in the single most boring case
imaginable — the committee that has already made up its mind.

## Why the argument is really about averages, not cubes

Strip away the combinatorial scenery and the engine is pure arithmetic of
non-negative weights. We have a collection of $m$ non-negative quantities (the
link contributions), each bounded below by $T$; their sum is at least $mT$; and
distributing that sum among $n - 1$ recipients forces one recipient to receive at
least the average. Nothing here needed the objects to be Boolean, or even to be a
cube. That abstraction is the reason the same skeleton transfers verbatim to
weighted, non-uniform, and higher-codimension settings — the natural next chapters
of the story.

## Where this points

The exact self-averaging identity is a small lemma with a long reach. Because it
is exact rather than approximate, it opens questions that were previously
invisible: How does guaranteed influence scale as the alphabet grows? What happens
when the $m$ links are weighted unequally — some neighborhoods more important than
others — and each weighted link satisfies its own influence bound? What if we pin
*two* offices at once, carving out higher-codimension links, and ask how the
influence of a third office decomposes across that finer partition? Each of these
is a variation on the same theme: local information, exactly aggregated, becomes
global insight.

The moral is one that echoes far beyond committees and complexes. In a structure
where sensitivity is guaranteed to be present in every neighborhood, sensitivity
cannot vanish from the whole. When every corner of the room has a loud voice, the
room itself is never silent.
