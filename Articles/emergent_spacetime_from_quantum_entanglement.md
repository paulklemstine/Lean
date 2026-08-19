# The Shape of Entanglement

### How the geometry of space can be recovered from nothing but a table of quantum correlations

---

There is a sentence physicists have been repeating for a decade, half as a joke and half
as a research programme: **ER = EPR**.

The left-hand side, ER, stands for Einstein and Rosen — who in 1935 found that Einstein's
equations permit a "bridge" between two distant regions of space, what we now call a
wormhole. The right-hand side, EPR, stands for Einstein, Podolsky and Rosen — the same
Einstein, the same year, describing the phenomenon he called *spooky action at a distance*:
quantum entanglement.

The conjecture says that these two 1935 papers are about the same thing. Every entangled
pair of particles, on this view, is joined by a microscopic wormhole. Space is not the
stage on which quantum mechanics happens; space is what entanglement *looks like* when you
step back far enough.

It is a beautiful idea, and, as usually stated, alarmingly vague. What does it *mean* for
two entangled electrons to be "joined by a wormhole"? How wide is the wormhole? What
happens if you disentangle them — does space tear?

This article is about a small, complete world in which all of these questions have exact
answers. In this world, ER = EPR is not a slogan. It is a theorem, and so is nearly
everything you would want to deduce from it.

---

## A universe made of areas

Strip away the continuum. Imagine space is made of a finite number of tiny **cells**. Call
the set of them $V$. Between any two cells $x$ and $y$ there is a number $w(x,y) \ge 0$,
symmetric in $x$ and $y$, which we call the **area** of the little wall separating them. If
$w(x,y)=0$, the two cells are simply not adjacent — there is no wall, because there is no
contact.

That's the entire geometry: a finite list of nonnegative numbers. No coordinates, no
curvature tensor, no metric. Just areas.

Now take any collection of cells — a **region** $f$ — and ask how much wall you would have
to cut to isolate it. That's its **area**:

$$\operatorname{area}(f) \;=\; \sum_{x \in f} \; \sum_{y \notin f} w(x,y),$$

the total area of the walls separating inside from outside. This single quantity is the
workhorse of everything that follows.

Some cells are marked as **boundary** cells; the rest are hidden in the interior. The
boundary is where the quantum state lives; the interior is the emergent bulk we are trying
to build.

Finally, the rule connecting quantum information to geometry, borrowed from the
Ryu–Takayanagi prescription of holography:

> **The entropy of a boundary region $A$ is the area of the smallest surface you can draw
> in the bulk that ends on $A$.**

Formally: consider every region $f$ of the full cell set that *agrees with $A$ on the
boundary* — it can do whatever it likes in the hidden interior — and take the smallest
area among them. Call it $S(A)$.

That's it. From this we will get distance, curvature, wormholes, monogamy and a
renormalisation group.

---

## The width of a wormhole

Entropy $S(A)$ is a property of one region. To talk about a *bridge between two* regions we
need something else. Here it is, and it is the key new character in the story.

Given two regions $A$ and $B$, look at all the surfaces that **separate** them — every
region $\sigma$ that swallows all of $A$ and none of $B$ — and take the smallest area among
them. Call it the **throat capacity**:

$$E(A,B) \;=\; \min\{ \operatorname{area}(\sigma) \;:\; A \subseteq \sigma, \; B \cap \sigma = \emptyset \}.$$

Picture an hourglass. To cut the two bulbs apart you must slice the waist, and the cheapest
slice is the narrowest one. $E(A,B)$ is the area of that narrowest waist: the
*cross-section of the Einstein–Rosen bridge* joining $A$ to $B$.

The first surprise is how much this one number knows.

> **Bridge Detection Theorem.** For two distinct cells $u$ and $v$, the throat capacity
> $E(u,v)$ is strictly positive if and only if you can walk from $u$ to $v$ through the
> bulk along walls of positive area.

Why? If no path exists, take $R$ to be the set of all cells you *can* reach from $u$. By
construction, no positive-area wall leads out of $R$ — otherwise you could step further.
So $R$ separates $u$ from $v$ and has area exactly zero, which drives $E(u,v)$ to zero.
Conversely if $E(u,v)=0$, the cheapest separating surface has no positive wall crossing it,
so any journey starting at $u$ is trapped on $u$'s side forever, and $v$ is on the other
side.

A single real number decides whether two points of space are connected at all. This is
already ER = EPR in embryo. Now we make it quantitative.

---

## Entanglement is bounded by the throat

The natural measure of how entangled two boundary regions are is their **mutual
information**,

$$I(A:B) \;=\; S(A) + S(B) - S(A \cup B),$$

which is zero for independent regions and grows with correlation. The central theorem of
this story ties it to geometry:

> **Cross-Section Theorem.** For disjoint boundary regions,
> $$I(A:B) \;\le\; 2\,E(A,B).$$

*You cannot have more entanglement than twice the width of the bridge that carries it.*

The proof is a lovely piece of surgery. Take the cheapest surface $\sigma$ separating $A$
from $B$, and take the minimal surface $g$ for the combined region $A \cup B$. Now slice
$g$ along $\sigma$. The piece inside $\sigma$ ends on $A$; the piece outside ends on $B$.
So each piece is a legitimate competitor in the minimisation defining $S(A)$ and $S(B)$
respectively, and therefore

$$S(A) + S(B) \;\le\; \operatorname{area}(g \cap \sigma) + \operatorname{area}(g \setminus \sigma).$$

All that remains is to bound the right-hand side. Cutting $g$ in two costs you the original
surface plus, at worst, *two copies* of the knife:

$$\operatorname{area}(g \cap \sigma) + \operatorname{area}(g \setminus \sigma) \;\le\; \operatorname{area}(g) + 2\operatorname{area}(\sigma).$$

That inequality reduces, wall by wall, to a statement about four bits of information, and a
patient check of sixteen cases confirms it. The factor $2$ is not slack: there is a
configuration where both sides are exactly equal. Combining the two displays and cancelling
$S(A\cup B) = \operatorname{area}(g)$ gives the theorem.

Put it together with an easy observation in the other direction — a minimal surface for $A$
already separates $A$ from $B$, so $E(A,B) \le S(A)$, and likewise for $B$ — and you get the
whole picture:

> **The ER = EPR Sandwich.**
> $$\tfrac12 I(A:B) \;\le\; E(A,B) \;\le\; \min\bigl(S(A),\,S(B)\bigr).$$

The bridge is at least as wide as half the entanglement it carries, and no wider than the
entropy of either of its mouths. And in the simplest possible case — two cells joined by a
single wall of area $w$ — all three quantities collapse to $w$. The sandwich is tight.

An immediate corollary deserves its own name:

> **ER = EPR.** If two boundary cells have positive mutual information, then a bulk path
> joins them, and the bridge between them has cross-section at least half their mutual
> information.

Entangled means connected. Not by analogy — by proof.

---

## Distance, and why space is a tree

Now we build the metric. Wide bridges should mean nearby points; no bridge should mean
maximal separation. So define

$$d(u,v) \;=\; e^{-E(u,v)} \quad (u \ne v), \qquad d(u,u) = 0.$$

Distance is the exponential of minus the throat capacity. Cells joined by a fat wormhole
are close; cells with no wormhole sit at distance exactly $1$, the maximum.

Is this a metric? It is, and considerably more. The reason is a hidden inequality among
throat capacities:

> **Gomory–Hu Inequality.** For any three cells with $u \ne v$,
> $$\min\bigl(E(u,z),\, E(z,v)\bigr) \;\le\; E(u,v).$$

The one-line proof: take the cheapest surface separating $u$ from $v$. The third cell $z$
has to be on one side or the other. If it's on $u$'s side, that very surface also separates
$z$ from $v$; if it's on $v$'s side, it separates $u$ from $z$. Either way, one of the two
capacities on the left is bounded by the area of that surface.

Now apply $e^{-(\cdot)}$, which reverses order and swaps min for max:

> **Ultrametric Theorem.** For all cells,
> $$d(u,v) \;\le\; \max\bigl(d(u,z),\, d(z,v)\bigr).$$

This is *much* stronger than the triangle inequality. A space obeying it is called
**ultrametric**, and ultrametric spaces are strange, rigid places. Every triangle is
isosceles, with the two shortest sides equal. Any two balls are nested or disjoint — never
partially overlapping. And "being within distance $r$" is a *transitive* relation, so at
every scale the space shatters cleanly into clusters that refine as $r$ shrinks.
Ultrametric spaces are, in essence, trees.

There is a sharper way to say it. Gromov's four-point condition measures how far a space is
from being a tree; $\delta = 0$ is the extreme, tree case. Every ultrametric space is
$0$-hyperbolic. So:

> **The emergent spacetime is $0$-hyperbolic.**

Negative curvature is the signature of anti-de Sitter space, the setting where holography
is best understood. Here, from nothing but a min-cut on a finite graph, we get curvature as
negative as geometry permits. The bulk that entanglement builds is a tree.

Meanwhile, the Cross-Section Theorem converts into a slogan of Van Raamsdonk's, made
precise:

> **Distance decays exponentially in entanglement:** $\quad d(u,v) \le e^{-I(u:v)/2}$.

And its converse is just as vivid: two cells sit at maximal distance $1$ *exactly* when no
bridge joins them. Disentangle two halves of the world, and space really does tear apart.

---

## The whole geometry, from a table of numbers

Suppose there are no hidden interior cells — every cell is a boundary cell. Then a short
computation shows the surface enclosing a single cell has area equal to the total wall area
touching it, and from this the mutual information of two cells comes out as

$$I(u:v) \;=\; 2\,w(u,v).$$

The entanglement between two cells is literally twice the area of the wall between them.
Which means:

> **Reconstruction Theorem.** Two such worlds with identical tables of two-point mutual
> informations have *identical* emergent geometries: same distances, same ultrametric,
> same clusters, same curvature. The emergent metric space is an invariant of the
> entanglement data alone.

This is the punchline of the whole subject in miniature. Hand me the table $\{I(u:v)\}$ —
pure quantum information, no geometry in sight — and I hand you back a metric space,
complete with its tree structure and its negative curvature.

---

## Monogamy, or why a wormhole has exactly two mouths

Entanglement is famously **monogamous**: if two qubits are maximally entangled with each
other, neither has any entanglement left over for anyone else. If ER = EPR is right, this
must show up as a geometric fact. It does.

> **Monogamy of Bridges.** In a world with no hidden cells, suppose a cell $u$ saturates
> its entropy bound with a partner $v$, meaning $I(u:v) = 2S(\{u\})$. Then every other wall
> touching $u$ has area zero, and $u$ has zero mutual information with every other cell.

The proof is arithmetic with a physical punchline. Saturation says $2w(u,v)$ equals
$2\sum_{y \ne u} w(u,y)$, so $\sum_{y \ne u,v} w(u,y) = 0$. But every one of those terms is
an *area*, and areas are nonnegative. A sum of nonnegative numbers vanishes only if all of
them do.

Positivity of area — the most innocuous of assumptions — does all the work. Maximal
entanglement geometrically isolates its pair. **A wormhole has exactly two mouths.**

There is a companion statement at the level of capacities: among any three cells, the two
smallest throat capacities are always equal. That isosceles law is precisely the algebraic
signature of a weighted tree, and it says the wormhole network is never a tangle. It is
always a tree of bridges.

---

## Threads through the bridge

So far we have measured entanglement by *cutting* the bulk. There is a dual way: *flowing*
through it. Imagine bundles of infinitesimally thin threads running from one boundary region
to another, each wall limited by its area, the threads conserved in the interior. How many
can you route?

Concretely, a **thread configuration** is an antisymmetric assignment $\phi(x,y) = -\phi(y,x)$
of oriented flux to each pair of cells, obeying $\phi(x,y) \le w(x,y)$, and conserved
everywhere except at the sources and sinks. Its **value** is the flux emitted by the source.

> **Weak Duality.** No conserved, capacity-respecting thread configuration can carry more
> flux than the area of *any* surface separating its sources from its sinks. In particular
> its value is at most the throat capacity $E(A,B)$.

The proof has three beats. First: conservation lets you enlarge the source region all the
way out to the separating surface for free, since every extra cell contributes zero net
flux. Second: the flux *within* that enlarged region cancels perfectly — an antisymmetric
quantity summed over a square array is its own negative — so only the flux crossing the
boundary survives. Third: crossing flux is bounded wall-by-wall by capacity, and the total
capacity crossing the surface is precisely its area.

Is the bound achievable? For the simplest wormhole — two cells joined by one wall of area
$w$ — yes: push $w$ units of thread straight through. Its value is $w$, exactly the throat
capacity, exactly half the mutual information.

> **Max-flow = min-cut for a single Einstein–Rosen bridge.**

The general statement — that every throat is saturated by some flow — is a
max-flow–min-cut theorem waiting to be proved here, and the most inviting open problem in
the story. It would upgrade every statement about *how much* entanglement there is into a
statement about *where it lives*.

---

## Zooming out: a renormalisation group for space

One last move. In physics you always want to know what happens when you blur your vision.
So take a map $\pi$ that merges cells into clumps, and define the **coarse-grained
geometry**: the wall area between two clumps is the total wall area between their members.

The engine here is a single identity. Every surface you can draw in the coarse world pulls
back to a surface in the fine world *with exactly the same area*. But the converse fails,
and the failure is the whole point: fine surfaces that *cut through a clump* have no coarse
counterpart. They are destroyed by the blurring.

Since the fine world minimises over strictly more competitors, its min-cuts can only be
smaller. Hence:

> **Coarse-graining widens throats and contracts distances.** Merging cells can only
> increase every throat capacity and decrease every emergent distance; the merging map is
> $1$-Lipschitz.

And it is honestly strict. Take four cells in a row, $0-1-2-3$, with heavy walls of area $5$
at the ends and a thin waist of area $1$ in the middle. The cheapest way to separate the two
ends is to slice the waist, so the throat from $0$ to $3$ is at most $1$. Now merge the two
middle cells. The waist vanishes — it is *inside* a single cell, invisible — and what
remains is a three-cell chain with two heavy walls, every separating surface slicing one of
them. The throat jumps from $1$ to $5$; the distance drops from $e^{-1}$ to $e^{-5}$.

That's the renormalisation group of emergent spacetime, and it has a clean moral: *space
contracts under coarse-graining, and it contracts discontinuously exactly when you absorb
the surfaces that were doing the work.*

---

## A shattered world

Let's finish with the picture the whole theory was built to explain. Take $n$ Bell pairs:
$2n$ cells, paired off, with pair $i$ joined by a wall of area $w_i$ and no other walls
anywhere. What does the emergent space look like?

Everything can be computed exactly. The throat capacity between the two mouths of pair $i$
is exactly $w_i$ — and the sandwich is tight, with half the mutual information, the throat,
and both entropies all equal to $w_i$. The capacity between cells of *different* pairs is
zero, because no path leaves a pair. So the emergent distance is $e^{-w_i}$ within a pair
and exactly $1$ — maximal — between pairs. And at any resolution $r$ lying below $1$ but
above every $e^{-w_i}$, the clusters of the emergent ultrametric are *exactly the Bell
pairs*. Not approximately. Exactly.

So the emergent spacetime of $n$ independent Bell pairs is $n$ disconnected microscopic
wormholes, each of a width set by how entangled its pair is, and nothing else. Entangle a
pair more strongly and its mouths draw closer; disentangle it and they fly apart to maximal
distance as the bridge closes.

---

## What it means

None of this is a theory of quantum gravity: no time, no dynamics, no Einstein equation.
What there is, is the *kinematic skeleton* of ER = EPR, laid bare — a finite graph, a
minimisation principle, and a handful of theorems.

And the skeleton carries a startling amount of the flesh. From nothing but "the entropy of
a region is the area of its minimal surface" and "areas are nonnegative", we recover:

- **connectivity** — entangled means joined by a bridge, with no exceptions;
- **width** — the cross-section is squeezed tightly between half the mutual information and
  the entropy of the mouths;
- **distance** — an honest metric, exponentially decaying in entanglement;
- **curvature** — as negative as a geometry can be: the discrete image of anti-de Sitter
  space;
- **monogamy** — maximal entanglement isolates its pair, so a wormhole has two mouths;
- **flows** — entanglement is transportable through the throat, not merely counted by it;
- **scale** — a functorial coarse-graining that contracts the geometry, strictly.

Einstein wrote both 1935 papers, and spent the rest of his life convinced that the second
exposed a flaw in quantum mechanics. The suspicion now is that he had, twice, in the same
year, described the same thing from two sides. In the small, exact world of this article,
that suspicion is settled.

Space, here, *is* entanglement — seen from far enough away.
