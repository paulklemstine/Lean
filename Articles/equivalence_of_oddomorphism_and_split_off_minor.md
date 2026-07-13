# When Odd Counting Reveals Hidden Structure in Networks

## A parity rule that acts like a map between graphs

Imagine you are handed two networks — call them $F$ and $G$ — drawn as
collections of dots (vertices) joined by lines (edges). A classic question in
mathematics asks: *how are these two networks related?* The gold standard is an
**isomorphism**: a perfect relabelling of the dots of $F$ so that it becomes an
exact copy of $G$. But exact copies are rare and rigid. Most of the interesting
relationships between networks are looser, messier, and far more common.

This article is about one such relationship, a surprisingly powerful one built
out of a single humble idea: **counting things and asking whether the answer is
odd or even.** The relationship is called an **oddomorphism**, and it turns out
to behave almost like an isomorphism while being flexible enough to fold, merge,
and simplify a network — exactly the operations that reveal when one network is
hiding inside another.

## The rule in one sentence

An oddomorphism is a function $\varphi$ that assigns to every vertex $u$ of the
first graph $F$ a vertex $\varphi(u)$ of the second graph $G$, subject to a
single local rule:

> For each vertex $u$ of $F$ and each vertex $a$ of $G$: the number of neighbours
> of $u$ (in $F$) that $\varphi$ sends to $a$ is **odd** exactly when $\varphi(u)$
> is joined to $a$ in $G$.

Read that again slowly, because everything flows from it. We are not asking that
neighbours go to neighbours in some tidy way. We are asking a *parity* question:
line up all the neighbours of $u$, see where $\varphi$ scatters them across $G$,
and for each possible destination $a$, count how many landed there. If that count
is odd, the rule demands an edge from $\varphi(u)$ to $a$; if it is even, the rule
forbids one. Odd means "connected," even means "not connected." That is the whole
definition.

This is a "mod 2" or "modulo two" version of the more familiar idea of a graph
homomorphism, where one insists that edges map to edges. Working modulo two — the
arithmetic of a light switch, where $1 + 1 = 0$ — softens the requirement into a
counting statement, and that softening is precisely what gives oddomorphisms their
power.

## From counting to matrices

To reason cleanly about all these parity conditions at once, it helps to encode
everything in matrices over the two-element number system $\mathrm{GF}(2)$, where
the only numbers are $0$ and $1$ and where $1 + 1 = 0$.

Every graph carries an **adjacency matrix** $A$: a grid of $0$s and $1$s with a
$1$ in row $u$, column $v$ exactly when $u$ and $v$ are joined by an edge. And
every function $\varphi$ from the vertices of $F$ to the vertices of $G$ carries a
**function matrix** $M_\varphi$: a grid whose entry in row $u$, column $a$ is $1$
exactly when $\varphi(u) = a$. Each row of $M_\varphi$ has a single $1$ — it just
records where that vertex goes.

Now watch what matrix multiplication does. The product $A_F \, M_\varphi$ counts,
for each vertex $u$ and destination $a$, how many neighbours of $u$ land on $a$ —
and because we are working modulo two, it records only the *parity* of that count.
The product $M_\varphi \, A_G$ records whether $\varphi(u)$ is adjacent to $a$ in
$G$. The oddomorphism rule is exactly the demand that these two matrices agree:

$$A_F \, M_\varphi = M_\varphi \, A_G \qquad (\text{arithmetic modulo } 2).$$

This compact equation — a single "intertwining" identity — *is* the local parity
rule, repackaged so that the tools of linear algebra can go to work. One clean
line of algebra now stands in for a whole forest of odd-versus-even bookkeeping.

## Why the matrix form matters: composing maps for free

The matrix picture immediately pays a dividend. Suppose you have an oddomorphism
$\varphi$ from $F$ to $G$ and another, $\psi$, from $G$ to $H$. Is the composite
"first $\varphi$, then $\psi$" an oddomorphism from $F$ to $H$?

There is a lovely fact hiding in the function matrices: multiplying two of them
corresponds to composing the functions,
$$M_\varphi \, M_\psi = M_{\psi \circ \varphi}.$$
With this in hand, checking that oddomorphisms compose is a two-line slide of
parentheses. Start from $A_F M_\varphi = M_\varphi A_G$, multiply, and push the
adjacency matrix through step by step:
$$A_F (M_\varphi M_\psi) = (M_\varphi A_G) M_\psi = M_\varphi (A_G M_\psi)
= M_\varphi (M_\psi A_H) = (M_\varphi M_\psi) A_H.$$
The intertwining survives, so $\psi \circ \varphi$ is again an oddomorphism.

Combined with the observation that the identity map is trivially an oddomorphism
(its function matrix is the identity matrix, which commutes with everything), we
learn that oddomorphisms behave like a well-organized system of one-way roads:
you can always stay put, and you can always chain trips together. In mathematical
language, the relation "there is an oddomorphism from $F$ to $G$" is a
**preorder** — it is reflexive and transitive. This is the same structural
backbone that underlies almost every notion of "one object simplifies to another"
across mathematics.

## Oddomorphisms are more generous than isomorphisms

Every genuine isomorphism between graphs is automatically an oddomorphism. If
$\varphi$ perfectly matches up $F$ with $G$, then each vertex $u$ has exactly one
neighbour going to each neighbour-destination, so the parity rule is satisfied for
the most boring possible reason: the counts are all one, which is odd. So
oddomorphisms include everything the classical theory already recognized.

But they include much more. Here is the small example that makes the whole idea
vivid. Let $F$ be two separate edges — four vertices $\{0,1,2,3\}$ with $0$ joined
to $1$ and $2$ joined to $3$, and nothing else. This is the graph sometimes
written $2K_2$. Let $G$ be a single edge $K_2$: two vertices $\{0,1\}$ joined by
one line. Now fold the two parallel edges onto the single one:
$$\varphi: \quad 0 \mapsto 0, \quad 1 \mapsto 1, \quad 2 \mapsto 0, \quad 3 \mapsto 1.$$

Is this an oddomorphism? Take vertex $0$ of $F$. Its only neighbour is $1$, and
$\varphi(1) = 1$, so one neighbour lands on destination $1$ (odd → edge required)
and zero neighbours land on destination $0$ (even → no edge). And indeed
$\varphi(0) = 0$ is joined to $1$ but not to itself in $G$. The rule checks out,
and by symmetry it checks out at every vertex. So $\varphi$ is a bona fide
oddomorphism — even though it is **not** injective (it sends both $0$ and $2$ to
$0$) and is certainly not an isomorphism (the graphs have different sizes). It is,
however, **surjective**: every vertex of the target is hit.

Contrast this with the *constant* map that crushes all four vertices to a single
point. That map is **not** an oddomorphism: collapsing everything destroys the
parity balance, and the intertwining equation fails. So oddomorphisms are not a
free-for-all. They permit genuine folding and merging, but only the folds that
respect the odd-counting rule.

That single example carries the moral of the story. The folding map turns two
disjoint edges into one by *identifying* corresponding endpoints — deleting the
redundancy and gluing what remains. This is exactly the kind of operation that, in
graph theory, exhibits one graph as a **minor** of another: something you obtain
by deleting and contracting pieces of a larger network.

## The big picture: oddomorphisms and "split-off minors"

Why care about a parity rule at all? Because it appears to detect a fundamental
structural relationship. There is a classical way of simplifying a graph called
**splitting off**, going back to foundational work on graph operations: you take a
vertex, break its connections apart in a controlled way, and reconnect the loose
ends, gradually distilling a smaller graph out of a larger one. A graph $G$
obtained from $F$ by a sequence of such moves (together with deletions) is called
a **split-off minor** of $F$.

The guiding conjecture that frames this entire subject is strikingly clean:

> **There is an oddomorphism from $F$ to $G$ if and only if $G$ is a split-off
> minor of $F$.**

One direction of this equivalence is established: whenever $G$ can be split off
from $F$, an oddomorphism exists — and the composition machinery described above
is exactly the tool that builds it, chaining the oddomorphism of each individual
split-off step into a single oddomorphism for the whole reduction. The reverse
direction — that *every* oddomorphism secretly encodes such a geometric
simplification — remains open, an inviting target that turns a question about
odd-versus-even counting into a question about the shape and reducibility of
networks.

The stakes are more than aesthetic. Oddomorphisms sit at the crossroads of two
very active themes in modern combinatorics: **homomorphism counting** — where two
graphs are compared by counting, for every small pattern, how many ways it embeds
into each — and **quantum isomorphism**, a notion born from quantum information
theory in which graphs can be "the same" through correlations that no classical
relabelling could produce. Counting oddomorphisms modulo two is precisely the kind
of parity invariant that distinguishes graphs which classical counting cannot, and
that lets the algebra of $\mathrm{GF}(2)$ speak to genuinely quantum phenomena.

## What we can now say for certain

Stripped to its essentials, here is the secure ground beneath the conjecture:

- **A clean local rule.** A map is an oddomorphism precisely when, at every
  vertex, odd-versus-even neighbour counts match the adjacency pattern of the
  target — equivalently, when its function matrix intertwines the two adjacency
  matrices modulo two.
- **A composable structure.** The identity is always an oddomorphism, and
  oddomorphisms chain together, so "reducible via an oddomorphism" is a genuine
  preorder — a consistent notion of one network simplifying to another.
- **A strict generalization of sameness.** Every isomorphism is an oddomorphism,
  but there are oddomorphisms — like the fold of two edges onto one — that no
  isomorphism could ever be, and these witness genuine minors.
- **A guardrail.** Not everything is permitted: crushing a graph to a point breaks
  the rule, so oddomorphisms carve out a meaningful, structured middle ground
  between rigid isomorphism and unconstrained collapse.

Mathematics is full of moments where a simple question — *is this number odd or
even?* — turns out to encode something deep about structure. The theory of
oddomorphisms is one of those moments. A light-switch arithmetic, applied to the
neighbours of a vertex, gives rise to a robust algebra of maps between graphs, and
that algebra seems to know, all on its own, when one network is quietly folded up
inside another.
