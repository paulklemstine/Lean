# The Walk That Started a Science: Why You Can't Cross Every Bridge Just Once

## A puzzle from a city of bridges

In the eighteenth century, the Prussian city of Königsberg sat astride the
Pregel River. The river split the city into four landmasses — two banks and two
islands — and seven bridges stitched them together. On lazy Sunday afternoons the
citizens entertained themselves with a deceptively simple challenge: could you
take a stroll through the city that crossed every one of the seven bridges exactly
once, and return to where you started?

People tried. They failed. They tried again, sketching routes on scraps of paper,
convinced that the right clever path was out there if only they looked hard
enough. Nobody could find it — but nobody could explain *why* it was impossible
either. "I couldn't do it" is not the same as "it cannot be done."

In 1736 the mathematician Leonhard Euler settled the matter, and in doing so he
quietly invented an entire branch of mathematics. His insight was that the answer
had nothing to do with cleverness, distances, or the shapes of the islands. It
depended only on *how many bridges touched each landmass*. That single shift in
perspective — from geometry to connection, from shape to structure — was the birth
of **graph theory**, and with it the modern science of networks.

This article tells the story of the clean mathematical heart of Euler's argument:
a counting law so robust that it can be proved with nothing more than careful
bookkeeping. We will state it precisely, prove its core, and see why it forces the
walkers of Königsberg to fail every single time.

## From bridges to dots and lines

The first and most important move is to throw away everything irrelevant. The
exact positions of the islands, the lengths of the bridges, the bends in the
river — none of it matters. What matters is the pattern of connections.

So we replace each landmass with a **dot** (a *vertex*) and each bridge with a
**line** joining two dots (an *edge*). The resulting picture is a **multigraph**:
"multi" because two landmasses can be joined by several bridges at once, so we
allow several edges between the same pair of dots. We even allow a bridge that
loops from a landmass back to itself.

To make this fully precise, imagine numbering the landmasses $0, 1, \dots, n_V-1$
and the bridges $0, 1, \dots, n_E-1$. A multigraph is then just a list that
records, for each bridge, the two landmasses it connects:

> **Definition (Multigraph).** A multigraph on $n_V$ vertices and $n_E$ edges is a
> function that assigns to every edge an *ordered pair* of vertices — its two
> endpoints.

We store the endpoints as an ordered pair $(\text{ends}(e).1, \text{ends}(e).2)$
purely for convenience; a walker doesn't care which end of a bridge they cross
first. A loop is simply a bridge whose two endpoints are the same vertex.

The single most important quantity in the whole story is the **degree** of a
vertex: the number of bridge-ends sticking out of it.

> **Definition (Degree).** The degree of a vertex $v$ is the total number of edge
> *endpoints* equal to $v$. Concretely, each edge contributes $1$ for each of its
> two endpoints that lands on $v$:
> $$ \deg(v) = \sum_{e} \big( [\,\text{ends}(e).1 = v\,] + [\,\text{ends}(e).2 = v\,]\big), $$
> where $[\,\cdot\,]$ is $1$ when the statement inside is true and $0$ otherwise.

Notice the elegant consequence of counting *endpoints* rather than edges: an
ordinary bridge between two different landmasses adds $1$ to each of their degrees,
but a **loop** at $v$ contributes $1 + 1 = 2$ to $\deg(v)$. A loop, after all, has
both of its ends planted in the same spot. This convention is exactly what makes
the parity argument below work flawlessly.

## What is a "walk that uses every bridge once"?

The Königsberg challenge asks for a route that traverses every bridge exactly
once. Such a route is called an **Eulerian trail**. Let us pin down what that
means as data.

A trail across $n_E$ bridges visits a sequence of $n_E + 1$ landmasses: you start
somewhere, and each bridge-crossing moves you to the next landmass, so $n_E$
crossings produce $n_E + 1$ stopping points (counting the start). Call this
sequence $\text{walk}(0), \text{walk}(1), \dots, \text{walk}(n_E)$.

For the route to use *every* bridge *exactly once*, we need a way to match the
$i$-th step of the walk with a distinct bridge. That matching is a **permutation**
$\text{edgeAt}$ of the bridge labels: a perfect, no-repeats, no-omissions
reshuffling that tells us which bridge is crossed at each step. Finally, the
matching has to be honest — the bridge assigned to step $i$ must really connect the
$i$-th landmass to the next one:

> **Definition (Eulerian trail).** An Eulerian trail consists of a vertex sequence
> $\text{walk}(0), \dots, \text{walk}(n_E)$ together with a permutation
> $\text{edgeAt}$ of the edges, such that for every step $i$ the edge
> $\text{edgeAt}(i)$ has endpoints $\{\text{walk}(i), \text{walk}(i{+}1)\}$ in one
> orientation or the other.

The permutation is the crucial ingredient. Because it is a genuine reshuffling of
all the edges, every bridge appears as $\text{edgeAt}(i)$ for exactly one step $i$.
That is the formal way of saying "each bridge is used exactly once."

## The accounting identity at the heart of it all

Here is the idea that makes everything click. There are two completely different
ways to count the bridge-ends at a vertex $v$, and they must agree.

**The static count.** Walk around the whole graph and tally every bridge-end that
touches $v$. That is the definition of $\deg(v)$ above.

**The dynamic count.** Now replay the Eulerian trail step by step. At each step
$i$, look at the two landmasses involved, $\text{walk}(i)$ and $\text{walk}(i{+}1)$,
and count how many of them equal $v$ (that's $0$, $1$, or $2$). Sum this over all
steps.

These two counts are the same number — because the permutation $\text{edgeAt}$
pairs up the steps of the walk with the edges of the graph, and crossing an edge
"uses up" exactly its two endpoints. This is our first theorem.

> **Theorem A (Degree equals walk-step count).** For every vertex $v$,
> $$ \deg(v) = \sum_{i} \big([\,\text{walk}(i) = v\,] + [\,\text{walk}(i{+}1) = v\,]\big). $$

Now comes a beautiful piece of bookkeeping. The right-hand sum counts each landmass
*visit* almost twice — once as the "arrival" of one step and once as the
"departure" of the next — but the two ends of the whole trail are special. The very
first landmass $\text{walk}(0)$ is only ever a departure, and the very last
landmass $\text{walk}(n_E)$ is only ever an arrival. Every other appearance of $v$
in the middle of the trail gets counted exactly twice. Making this precise gives a
clean **endpoint-correction identity**:

> **Theorem B (Endpoint correction).** For every vertex $v$,
> $$ \deg(v) + \big([\,\text{walk}(0) = v\,] + [\,\text{walk}(n_E) = v\,]\big) = 2 \cdot \big(\text{number of trail positions equal to } v\big). $$

Stare at this equation, because it contains the entire secret of Königsberg. The
right-hand side is an **even number** — it is literally two times something. The
quantity in parentheses on the left is a tiny correction: it is $0$, $1$, or $2$,
depending on whether $v$ happens to be the start of the trail, the end, both, or
neither.

## Odd degrees can only live at the ends

From Theorem B the conclusion tumbles out almost by itself. The total
$\deg(v) + (\text{correction})$ is even. So $\deg(v)$ and the correction term must
have the *same parity* — both even or both odd.

**If $v$ is an interior vertex** (neither the start nor the end of the trail), the
correction term is $0$, which is even. Therefore $\deg(v)$ is even too.

> **Theorem C (Interior vertices have even degree).** If $v$ is neither the start
> $\text{walk}(0)$ nor the end $\text{walk}(n_E)$ of the trail, then $\deg(v)$ is
> even.

Flip this around and you get the punchline:

> **Theorem D (Odd vertices are endpoints).** If $\deg(v)$ is odd, then $v$ must be
> the start of the trail or its end.

And since there is only *one* start and *one* end, at most two vertices can have
odd degree:

> **Theorem E (At most two odd vertices).** In any multigraph that admits an
> Eulerian trail, the number of odd-degree vertices is at most $2$.

This is the law the people of Königsberg ran into without knowing it.

## Back to the seven bridges

Recall the actual city. The two riverbanks, the big island, and the smaller island
were connected by seven bridges. Counting the bridge-ends at each landmass, the
classic configuration gives degrees of $5, 3, 3, 3$ — **all four landmasses have
odd degree.**

Theorem E says an Eulerian trail can tolerate *at most two* odd-degree vertices.
Königsberg had *four*. Four is more than two. Therefore no route crossing every
bridge exactly once can possibly exist — not because the citizens weren't clever
enough, but because the very structure of the city forbids it. No amount of
ingenuity can change the parity of a count.

The argument is wonderfully sturdy. It never mentions distance, geometry, or
strategy. It is pure accounting: each time you walk *into* a landmass mid-trail you
must walk back *out*, consuming bridges two at a time. Only the place where you
begin and the place where you finish are allowed to break that in-out pairing — and
those two privileged spots are the only ones that may carry an odd count.

## Why this matters far beyond a Prussian river

It would be a mistake to file this away as a charming historical curiosity. The
parity-of-degree argument is the prototype of a style of reasoning that now
underpins enormous swaths of science and engineering.

**Routing and logistics.** The modern descendant of the bridge problem is the
"route inspection" or *Chinese postman* problem: a mail carrier, a snowplow, or a
street-sweeper must traverse every road in a network and wants to minimize
backtracking. Whether a no-repeat route exists, and how much repetition is forced
if it doesn't, is governed precisely by which intersections have an odd number of
roads. Euler's parity count is the first thing any such algorithm checks.

**DNA sequencing.** When a genome is reconstructed from millions of short
fragments, modern assemblers build a graph whose edges are overlapping snippets and
then look for a trail that uses every edge — an Eulerian trail. The existence and
shape of that trail, again, hinge on degree parities. A counting trick from 1736
helps decode the book of life.

**Network design and circuit testing.** Engineers laying out the wiring on a chip,
or testing that every connection in a circuit has been exercised, rely on the same
even/odd accounting to decide when a single sweep can cover everything.

**The deeper lesson.** Euler's true gift was not the answer but the *method*:
abstract away the inessential, encode the essential as a graph, and let a
conserved quantity — here, parity — do the heavy lifting. This is the same
intellectual reflex that later produced conservation laws in physics, invariants in
topology, and checksums in computer science. The question "what stays the same no
matter what you do?" is one of the most powerful in all of mathematics, and the
bridges of Königsberg are where it first crossed the water.

## The shape of certainty

What makes this result so satisfying is its finality. Most of us, faced with a
puzzle, can only report our failures: "I tried for an hour and couldn't do it."
Euler gave us something categorically stronger — a *proof of impossibility*, a
guarantee that no future attempt, however inspired, can ever succeed. The four odd
landmasses of Königsberg are an immovable obstacle written into the arithmetic of
the city itself.

That is the quiet power of a counting argument. You do not have to examine every
possible route — there are astronomically many — to know that all of them fail. You
only have to notice that each one would force an even number of odd vertices, and
that four is not at most two. From that single observation, certainty follows.

A Sunday stroll that seemed merely stubbornly difficult turned out to be flatly
impossible, and the explanation launched a science. Not bad for a walk that could
never be taken.
