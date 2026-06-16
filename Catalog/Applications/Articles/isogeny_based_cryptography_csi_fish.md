# The Bridges of Königsberg, Counted Exactly

## A walk that started a science

In the early eighteenth century, the citizens of Königsberg amused themselves
with a puzzle. Their city straddled the river Pregel, which split around two
islands and was crossed by seven bridges. The challenge sounded almost childish:
take a stroll that crosses every bridge exactly once. People tried for years.
Nobody succeeded — and nobody could say *why* it was impossible.

In 1736 a young Leonhard Euler settled the matter, and in doing so accidentally
founded an entire branch of mathematics. His insight was to throw away almost
everything about the map. The shapes of the islands, the lengths of the bridges,
the distances people walked — none of it mattered. What mattered was a single
piece of bookkeeping at each landmass: *how many bridges touch it?*

That number is what we now call the **degree** of a vertex, and Euler's
discovery was that the entire question of "can I walk every bridge exactly once?"
is decided by the *parity* of these degrees — whether they are even or odd. The
seven bridges of Königsberg were impossible because too many landmasses had an
odd number of bridges. Once you see the world through degrees and parities, the
answer is forced.

This article is about that idea, made completely precise and proved from the
ground up by pure counting. We will state the modern theorem exactly, see why it
is true, and watch a deceptively simple "handshake" of arithmetic do all the
heavy lifting.

## What is a graph, really?

Strip a map down to its essentials and you are left with two kinds of objects:
**places** and **connections**. Mathematicians call the places *vertices* and
the connections *edges*. A road map, a circuit board, a subway network, a
molecule, a social network — all of them are graphs once you forget the
irrelevant geometry and keep only "what is connected to what."

We want to be honest about one subtlety that Königsberg already forces on us.
Real networks can have **two different bridges between the same pair of
islands**, and they can have **a bridge that loops from a place back to
itself**. So we work with what is called a *multigraph with loops*: between any
two places there may be several edges, and an edge is even allowed to start and
end at the same place.

Concretely, fix a finite set of vertices and a finite set of edges. Each edge is
described by its two *endpoints*. If an edge's two endpoints are the same vertex,
that edge is a **loop**.

## The all-important count: degree

The **degree** of a vertex is the number of edge-ends that touch it. The phrase
"edge-ends" is doing precise work. Every edge has exactly two ends. An ordinary
edge between two different vertices contributes one end to each of them. A loop,
however, has *both* of its ends planted in the same vertex — so:

> **A loop adds 2 to the degree of its vertex, not 1.**

This is not a stylistic choice; it is the only convention under which the
theory works, and it is exactly how the formal development counts. The degree of
a vertex `v` is the number of edges whose *first* endpoint is `v`, plus the
number of edges whose *second* endpoint is `v`. A loop at `v` is counted in both
tallies, so it shows up twice. Keep that picture — *every edge contributes
exactly two units of degree, distributed among its endpoints* — and the rest of
the story practically tells itself.

## What is an Eulerian trail?

An **Eulerian trail** is the formal version of "a walk that uses every bridge
exactly once." It consists of three pieces of data:

1. **A walk**: a sequence of vertices `v₀, v₁, v₂, …, v_E`, one more vertex than
   there are edges. You start at `v₀`, and after each step you are at the next
   vertex in the list.
2. **An ordering of the edges**: a rule that says which edge you cross on each
   step, and crucially this ordering is a *permutation* — every edge appears
   exactly once. That single requirement is what makes the trail *Eulerian*:
   nothing is skipped, nothing is repeated.
3. **A compatibility condition**: the edge you cross on step `i` must genuinely
   connect the vertex you are standing on to the vertex you arrive at. Because
   our graph is undirected, you are allowed to traverse an edge in either
   orientation — from its first endpoint to its second, or the other way around.

The first vertex `v₀` is the **start** of the trail; the last vertex `v_E` is the
**end**. If they happen to coincide, the trail is **closed** — a single loop
through the whole network that returns home.

## The heart of the matter: a local counting identity

Here is the engine that drives everything. Pick any vertex `v` and ask three
questions about the trail:

- **How many times do you visit `v`?** Call this the *visit count*. It counts
  every position in the walk `v₀, …, v_E` that happens to equal `v`.
- **Is `v` the start?** Record `1` if yes, `0` if no.
- **Is `v` the end?** Record `1` if yes, `0` if no.

The central theorem says these numbers, together with the degree, satisfy a
rigid equation:

> **Local Parity Identity.** For every vertex `v` of an Eulerian trail,
> $$\deg(v) \;+\; [\,v \text{ is the start}\,] \;+\; [\,v \text{ is the end}\,]
> \;=\; 2 \times (\text{number of visits to } v).$$

Read it slowly, because it is beautiful. The right-hand side is *even* — it is
two times something. So the left-hand side must be even too. The degree, plus a
correction of `0`, `1`, or `2` for being an endpoint, always lands on an even
number.

Why is the identity true? Think about a single visit to `v` somewhere in the
middle of the walk. To get there you crossed one edge (arriving), and to leave
you cross another edge (departing). That middle visit therefore accounts for
**two** edge-ends at `v`: one in, one out. Now the only visits that don't pair
up this way are the very first step of the walk (you depart but never arrived)
and the very last step (you arrived but never depart). The start contributes one
unpaired edge-end; the end contributes one unpaired edge-end. Add the missing
"phantom" half-steps back in — that is exactly the `[v is start]` and
`[v is end]` corrections — and suddenly every visit contributes a clean two.
The total number of edge-ends at `v` is the degree, so:

$$\deg(v) + [\text{start}] + [\text{end}] = 2 \times (\text{visits}).$$

In the formal development this argument is split into three transparent counting
lemmas that fit together by simple arithmetic:

- The visits to `v` can be tallied by looking at the *first* vertex of each step
  plus a correction for the final vertex (splitting the walk at its tail).
- The visits to `v` can equally be tallied by looking at the *second* vertex of
  each step plus a correction for the initial vertex (splitting at its head).
- The degree of `v` equals the number of steps whose first vertex is `v` plus
  the number whose second vertex is `v` — and this is where the edge permutation
  and the "either orientation" rule are used, matching each edge to the step that
  crosses it.

Combine the three and the identity drops out by ordinary integer arithmetic.
Notice what powered the whole thing: not geometry, not topology, just the
discipline of counting each edge-end exactly once.

## Consequences that feel like magic

From this one identity, the classical structure theorems follow almost
immediately.

### Odd degree means you are an endpoint

Suppose some vertex `v` has **odd** degree. The identity says
`deg(v) + [start] + [end]` is even. An odd number can only become even if the
endpoint corrections add an *odd* amount — that is, exactly one of `[start]` and
`[end]` is `1`. In plain language:

> **If a vertex has odd degree, it must be either the start or the end of the
> trail.**

There is simply nowhere else for an odd-degree vertex to hide. Every interior
vertex of a walk gets its edge-ends paired up perfectly, forcing an even degree.
Oddness is a privilege reserved for the two ends of the journey.

### At most two odd vertices

A trail has exactly one start and one end. Since every odd-degree vertex must be
one of these two special places, we conclude:

> **An Eulerian trail can exist only if at most two vertices have odd degree.**

This is the precise reason Königsberg failed. All four of its landmasses had an
odd number of bridges — four odd vertices, far more than the maximum of two. No
amount of cleverness could ever have produced the walk; the parity bookkeeping
forbids it.

### Closed trails have all-even degrees

Finally, suppose the trail is **closed**: it ends where it began, `start = end`.
Then for *every* vertex, the two endpoint corrections either both fire (at the
shared start/end vertex, adding `2`) or both stay silent (everywhere else, adding
`0`). Either way the correction is even, so the degree itself must be even:

> **In a closed Eulerian trail (a circuit returning home), every single vertex
> has even degree.**

This is the famous criterion for an Eulerian *circuit*: you can tour a network
and return to your starting point, crossing every connection exactly once, only
if every junction has an even number of connections. Mail carriers planning a
route that retraces no street, machines drawing a figure without lifting the pen,
DNA-sequencing algorithms stitching fragments into a genome — all of them live or
die by this even-degree condition.

## Why this still matters

It would be a mistake to file Euler's idea away as a historical curiosity. The
parity-of-degree principle is one of the most reused tools in all of discrete
mathematics and computer science.

- **Genome assembly.** Modern DNA sequencers produce millions of short, overlapping
  fragments. Reconstructing the original genome is, at its core, the problem of
  finding an Eulerian trail through a graph of overlaps. The even/odd degree
  bookkeeping decides whether the reconstruction is even possible and guides the
  algorithms that find it.

- **The Chinese Postman Problem.** A postal worker wants to walk every street and
  return to the depot using the least extra distance. If the street network
  already has all-even degrees, an Eulerian circuit exists and there is no waste.
  If not, the odd-degree vertices — and there are always an even number of them —
  must be paired up and "fixed," and the parity theorem tells you exactly which
  vertices need attention.

- **Drawing and manufacturing.** The childhood puzzle of drawing a shape "in one
  stroke without lifting your pencil" is precisely the Eulerian-trail question.
  The same logic optimizes the path of a laser cutter or a 3D printer's nozzle.

- **Network reliability and circuit design.** Whenever you need to traverse every
  link of a system exactly once — for testing, for inspection, for signal
  routing — the degrees of the nodes are the first thing to compute.

What unites all of these is the same humble observation Euler made looking at a
city map: forget the picture, count the connections, and check whether the counts
are even or odd. The **handshake intuition** — that edge-ends always come in
pairs except possibly at the two ends of a journey — is the whole secret.

## The lesson of the count

The deepest theorems are often the ones whose proofs are pure bookkeeping done
without a single error. The parity identity
`deg(v) + [start] + [end] = 2 × visits` is not deep because it is complicated; it
is deep because it is *exactly right*, accounting for every loop, every
orientation, and every endpoint with no fudge factors. From that one honest
equation flows the complete classification of when a one-stroke walk exists:

- odd-degree vertices are exactly the possible endpoints,
- there can be at most two of them,
- and a closed tour forces every degree to be even.

Three hundred years after a riverside puzzle stumped a town, the answer is not
just known — it is counted, exactly, with nothing left to chance. That is the
quiet power of seeing the world as vertices, edges, and the eternal arithmetic of
even and odd.
