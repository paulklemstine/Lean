# When Two Colours Are Not Enough: The Hidden Geometry of Sparse Set Systems

Imagine you are handed a huge list of committees. Each committee is a small
group drawn from a large pool of people. Your job sounds almost childishly
simple: paint every person either **red** or **blue** so that no single
committee ends up entirely one colour. Every committee should contain at least
one red member *and* at least one blue member — no committee is allowed to be
monochromatic.

Sometimes this is easy. If there is only one committee, you just paint one of
its members red and another blue and you are done. But as the committees
multiply and overlap in intricate ways, the task can become impossible. The
famous *triangle* is the smallest example: three people, and the three
committees are all the pairs among them. Try it. Paint two people red — then the
committee consisting of those two people is all red. Paint two people blue — then
*that* pair is all blue. No matter how you colour three people with two colours,
some pair comes out solid. Two colours are simply not enough.

This tension — between systems that *can* be split into two colours and systems
that *cannot* — is the subject of one of the most elegant threads in
combinatorics, a story that begins with a deceptively simple question asked by
Paul Erdős in 1963 and leads directly to the birth of the modern
**probabilistic method**. This article tells that story and reports on a precise,
fully worked-out determination of the smallest impossible systems.

## Property B: the art of the two-colouring

Mathematicians package the "committees over people" picture as a **hypergraph**.
The people are *vertices*; each committee is an *edge*, which — unlike an edge in
an ordinary graph — may contain any number of vertices. A hypergraph is called
**$k$-uniform** when every edge has exactly $k$ vertices: every committee has
exactly $k$ members.

A red/blue colouring of the vertices is **proper** (the technical name is that
the hypergraph *has Property B*, after Felix Bernstein who studied it in 1908)
when no edge is monochromatic. In symbols, if we let $R$ be the set of red
vertices, then for every edge $e$ we require
$$e \not\subseteq R \qquad \text{and} \qquad e \cap R \neq \varnothing,$$
that is, $e$ is neither entirely red nor entirely blue.

The central question is disarmingly natural:

> **How many edges must a $k$-uniform hypergraph have before it can be forced to
> resist every two-colouring?**

Call this threshold $m(k)$: the *fewest* edges in any $k$-uniform hypergraph
that admits **no** proper two-colouring. A system with fewer than $m(k)$ edges
can always be split; some system with exactly $m(k)$ edges cannot. The number
$m(k)$ measures the exact price of impossibility.

## Erdős's coin-flip miracle

Here is where the story becomes beautiful. In 1963 Erdős proved a lower bound on
$m(k)$ without ever constructing a single hypergraph. His argument is a
one-paragraph miracle that launched a thousand papers.

Suppose your $k$-uniform hypergraph has fewer than $2^{k-1}$ edges. **Colour
every vertex independently by flipping a fair coin** — red for heads, blue for
tails. Now fix one edge $e$, which has exactly $k$ vertices. The probability that
this particular edge comes out *all red* is $(1/2)^k$, because all $k$ coins must
land heads. Likewise the probability it comes out *all blue* is $(1/2)^k$. So the
chance that $e$ is monochromatic — bad in one way or the other — is at most
$$2 \cdot \frac{1}{2^{k}} = \frac{1}{2^{k-1}}.$$

Now comes the **union bound**, the workhorse of probability: the chance that
*some* edge is monochromatic is no bigger than the sum of the individual chances.
If there are fewer than $2^{k-1}$ edges, that sum is
$$\#\{\text{edges}\} \cdot \frac{1}{2^{k-1}} < 2^{k-1} \cdot \frac{1}{2^{k-1}} = 1.$$

The probability of failure is strictly less than $1$. Therefore the probability
of **success** is strictly positive — which means at least one colouring must
work. A random experiment that succeeds with positive probability proves that a
successful outcome exists, even though we never point to it. We have proved:

> **The Erdős Lower Bound.** Every $k$-uniform hypergraph with fewer than
> $2^{k-1}$ edges can be properly two-coloured. Equivalently,
> $$m(k) \;\ge\; 2^{k-1}.$$

No committee list with fewer than $2^{k-1}$ committees of size $k$ can defeat
you. This is the whole probabilistic method in miniature: to prove something
exists, show a random object has it with positive probability.

## From probability to certainty: counting colourings

There is a down-to-earth way to see the same fact that avoids any talk of
"probability" at all — and it is the version we pin down exactly here. Over a
pool of $N$ people there are precisely $2^N$ possible red/blue colourings. Call a
colouring **bad for edge $e$** if $e$ comes out monochromatic. How many
colourings are bad for a fixed edge $e$ of size $k$?

The key counting fact is a piece of clean lattice geometry. The number of
subsets $R$ of an $N$-element ground set that *contain* a fixed set $S$ is
exactly $2^{N-|S|}$ — you may freely choose the membership of the $N-|S|$
elements outside $S$. By a symmetric "complement" argument (send each $R$ to its
opposite $R^{c}$), the number of subsets *disjoint* from $S$ is also $2^{N-|S|}$.
Applied to an edge $e$ of size $k$: exactly $2^{N-k}$ colourings make $e$ all
red, and exactly $2^{N-k}$ make it all blue, so at most $2^{N-k+1}$ colourings
are bad for $e$.

Summing over fewer than $2^{k-1}$ edges, the number of colourings that are bad
for *some* edge is at most
$$\#\{\text{edges}\} \cdot 2^{N-k+1} \;<\; 2^{k-1} \cdot 2^{N-k+1} = 2^{N}.$$

Strictly fewer than $2^{N}$ colourings are bad, so at least one colouring is
good. Same conclusion, now as pure finite counting: the coin flips become an
exact census of the $2^N$ colourings, and "positive probability" becomes "the
bad colourings do not fill the whole space."

## Finding the impossible systems: the exact values

The lower bound tells us the impossible systems cannot be *too* sparse. But how
sparse can they actually be? To nail down $m(k)$ we must also *exhibit* a
genuinely impossible system with as few edges as possible — a matching **upper
bound** — and prove nothing smaller works. This is where the exact small values
come from.

**The case $k=1$.** A $1$-uniform edge is a single vertex; a colouring makes it
"monochromatic" automatically (a lone vertex is whatever colour it is). A single
one-vertex edge already cannot be two-coloured in the required sense, so one
edge suffices and $m(1) = 1$. This agrees perfectly with the lower bound
$2^{1-1} = 2^0 = 1$.

**The case $k=2$.** Here $2$-uniform hypergraphs are just ordinary graphs, and
the lower bound gives $m(2) \ge 2^{1} = 2$. But two edges are never enough, and
seeing *why* is the genuinely new mathematical content of this work:

> **Every graph with at most two edges can be two-coloured.** Two edges are two
> pairs of vertices. They either share a vertex or they don't. If they are
> disjoint, colour one endpoint of each edge red and the other blue — done. If
> they share a vertex $v$, colour $v$ red and everything else blue; then each
> edge contains the red vertex $v$ and at least one blue vertex. Either way, no
> edge is monochromatic. In graph language: two edges can never close a cycle
> (a cycle needs at least three edges), so the graph is a forest, and forests are
> always two-colourable.

This bumps the lower bound up from $2$ to $3$: no graph with two or fewer edges
can be impossible. And the **triangle** — three vertices with all three pairs as
edges — realises exactly three edges and, as we saw at the very start, cannot be
two-coloured. Checking all $2^3 = 8$ colourings confirms it: every one leaves
some pair monochromatic. The triangle is the sparsest impossible graph, and so
$$m(2) = 3.$$

The triangle is not merely *an* example; it is *the* extremal object, the unique
minimum-edge witness to impossibility at $k=2$. The generic probabilistic bound
knows only that $m(2) \ge 2$; the sharp combinatorial argument, combined with the
concrete triangle, closes the gap and proves the exact value.

## Why this matters

At first glance, painting committees might feel like a parlour game. But
$m(k)$ and its relatives sit at a crossroads of ideas that reach far beyond
recreational mathematics.

- **The probabilistic method.** Erdős's coin-flip argument is the seed from
  which an entire field grew. The same "show it happens with positive
  probability" logic proves the existence of graphs with no small cliques and no
  large independent sets (Ramsey lower bounds), of error-correcting codes, of
  expander networks, and of countless other structures no one knows how to build
  by hand. Property B is the cleanest place to first meet the idea.

- **Satisfiability and constraint solving.** "Colour the vertices so no edge is
  monochromatic" is a special case of *not-all-equal satisfiability*, a cousin of
  the Boolean satisfiability problems at the heart of computer science. The
  threshold $m(k)$ is a purely combinatorial avatar of the phase transitions that
  make some logical formulas easy and others impossibly hard.

- **The gap between existence and construction.** The probabilistic lower bound
  $m(k) \ge 2^{k-1}$ is exponential and easy; the best explicit *constructions*
  of impossible hypergraphs lag far behind, and the exact value of $m(k)$ is
  unknown for every $k \ge 4$. Even $m(3) = 7$, realised by the celebrated Fano
  plane, requires real work. The story of $m(k)$ is a running dramatisation of one
  of mathematics' deepest themes: knowing that something exists is often far
  easier than finding it.

## The road ahead

The determination of $m(1) = 1$ and $m(2) = 3$, together with the exponential
lower bound $m(k) \ge 2^{k-1}$, is the beginning of a longer expedition. The next
landmark is $m(3) = 7$, embodied by the seven lines of the Fano plane — the
smallest projective plane, a configuration of seven points and seven lines in
which every pair of points lies on a unique line. Beyond that lies the
celebrated refinement of Radhakrishnan and Srinivasan, who used a subtle
*semi-random* colouring — flip coins, then locally repair the few monochromatic
edges — to push the lower bound up to roughly $2^{k}\sqrt{k/\log k}$. And beyond
*that* lie the many-colour generalisations, where two paints become $r$ and the
whole landscape shifts again.

What makes this corner of mathematics so appealing is that its central question
can be explained to a child — *paint the people so no committee is one colour* —
yet its answer draws on probability, geometry, logic, and the still-unfinished
art of turning existence into construction. The smallest impossible systems, it
turns out, have a great deal to teach us.
