# Phantom Topologies: Spaces That Change When You Look at Them

## A space that depends on who is watching

Ask a physicist what happens when you measure a quantum system and you'll hear
something unsettling: the act of looking changes what there is to see. What if
geometry worked the same way? What if the very shape of a space — which points
count as "close," which regions count as "open" — depended on the observer?

This article develops exactly that idea, and turns it into precise mathematics.
We call the resulting objects **phantom topologies**. The picture is simple and
strange at once: a space carries not one notion of nearness but many, one for
each observer. Reality is not any single observer's view. Reality is what *all*
of them agree on. And, as we'll see, agreement is a blurring operation — the more
observers you add, the coarser the shared world becomes. Individual observers see
"phantom" structure, extra detail that dissolves the moment you compare notes.

The surprise at the heart of this story is that a natural-sounding conjecture
about these observers — that "blurrier" spaces should need *more* observers to
reconstruct — turns out to be **false**, and is refuted by the smallest, humblest
space imaginable: two points glued so tightly they cannot be told apart.

## What is a topology, really?

Before we let observers loose, recall the one idea we need. A **topology** on a
set $X$ is a rulebook that declares which subsets are *open*. Openness is the
abstract stand-in for "wiggle room": a set $U$ is open if, standing at any of its
points, you can move a little in any direction and stay inside $U$. On the real
line $\mathbb{R}$, the familiar open sets are unions of open intervals $(a,b)$.

Two topologies on the same set can be compared. One is **finer** than another if
it has *more* open sets — it resolves more distinctions, like a sharper lens. The
coarsest possible topology on $X$ declares only the empty set and all of $X$ to be
open; it sees no internal structure at all. The finest declares *every* subset
open; it sees each point in perfect isolation.

Crucially, topologies on a fixed set form a **lattice**: any collection of them
has a well-defined "greatest common blur." Given several topologies, the sets that
are open in *every one of them* form a topology in their own right — the finest
topology that all of them refine. This shared-agreement topology is the technical
engine of everything that follows.

## Observers, consensus, and phantoms

Here is the definition. A **phantom topology** on a set $X$ is a family of
topologies indexed by a set of *observers*:
$$T : \mathcal{O} \longrightarrow \{\text{topologies on } X\}, \qquad o \mapsto T(o).$$
Each observer $o$ perceives $X$ through their own topology $T(o)$ — their own
private sense of which regions are open.

The **consensus** (or *real*) topology is the set of unanimous verdicts:
$$U \text{ is consensus-open} \iff U \text{ is open in } T(o) \text{ for every observer } o.$$
This is precisely the greatest-common-blur described above. It is what survives
comparison; it is the geometry no observer can dispute.

Two features make this more than a relabeling. First, **each observer is finer
than the consensus**: any single lens resolves at least as much as everyone can
agree on, and usually more. Second — the counterintuitive twist — **adding
observers can only coarsen reality**. Agreement is intersection, and intersecting
more collections of open sets can only shrink the pool. Measurement, in this
model, is a strictly *blurring* act.

We call a representation **genuinely phantom** when every observer is *strictly*
finer than the consensus — when each one sees real structure that reality does
not. The extra sets each observer perceives are the "phantoms": open regions that
feel real from a single vantage point but vanish under collective scrutiny. The
**phantom number** of a space is the smallest number of such strictly-sharper
observers whose consensus rebuilds it.

## The real line through two one-sided eyes

The first concrete result is a clean and pretty fact about the ordinary real
line. Introduce two observers with opposite biases.

The **left-leaning (lower-limit) observer** considers a set open when, from every
one of its points $x$, you can step a little to the *right* and stay inside: there
is some $b > x$ with the half-open interval $[x, b)$ contained in the set. This
observer treats each point as clinging to its right neighbors.

The **right-leaning (upper-limit) observer** is the mirror image: a set is open
when from every point $x$ you can step a little to the *left* and stay inside —
some $a < x$ with $(a, x]$ contained in the set.

Neither observer sees the ordinary line. The left-leaning observer regards the
half-open interval $[0, 1)$ as perfectly open (you can always step right from any
of its points), yet $[0,1)$ is *not* open in the usual sense — at the point $0$
you cannot step left without leaving. Symmetrically, $(0,1]$ is open only to the
right-leaning observer. These are genuine phantoms.

But now take the consensus.

> **Two-Observer Theorem for the Real Line.** A subset of $\mathbb{R}$ is open in
> the ordinary Euclidean sense if and only if it is open for *both* the
> left-leaning and the right-leaning observer. In other words, the standard
> topology on $\mathbb{R}$ is exactly the consensus of these two one-sided
> observers, each of which is strictly finer than reality.

The proof is a two-sided squeeze. If a set is open for both observers, then from
any point $x$ you can step right (some $[x, b)$ fits) *and* step left (some
$(a, x]$ fits); together these give a genuine two-sided interval $(a, b)$ around
$x$ inside the set — exactly ordinary openness. Conversely, an ordinary open set
already contains a two-sided interval around each point, so in particular it
contains a right piece and a left piece, satisfying both observers at once. The
phantoms $[0,1)$ and $(0,1]$ each survive under exactly one observer and are
annihilated by the other; only the two-sided sets endure.

Could one observer alone have done the job? No — and for a structural reason. The
consensus of a *single* observer is just that observer. So a one-observer
"representation" of the line would have to *be* the line already, with no phantom
structure at all. Genuine phantomness needs at least two observers, and two
suffice. **The phantom number of the Euclidean line is exactly two.**

## The conjecture: does blurriness demand a crowd?

The two-observer result invites a sweeping guess. The real line is about as
well-behaved as spaces come: it is *metrizable*, meaning its topology arises from
an honest distance function, and it can be described by a countable stock of basic
open sets. It reconstructs from just two observers. Perhaps, one might conjecture,
the *worse* a space behaves — the further it strays from being measured by a
distance — the *more* observers it takes to piece it back together:

> **Conjecture (the "crowd" hypothesis).** Every non-metrizable space requires at
> least three observers.

The intuition is seductive. A metrizable space has crisp separation: distinct
points sit at positive distance, so they can always be quarantined in disjoint
open sets. A non-metrizable space can be blurry, with points that no open set can
separate. Surely reconstructing such a fog demands extra viewpoints?

It does not. The conjecture is false — and the counterexample is the smallest
interesting space there is.

## The refutation: two points that cannot be told apart

Consider a space with just two points; call them $\mathsf{true}$ and
$\mathsf{false}$. Equip it with the coarsest possible topology, the **indiscrete
topology**, in which the only open sets are the empty set and the whole space. In
this world the two points are utterly inseparable: any open set that contains one
contains the other. There is no open "test" that distinguishes them.

This tiny space is **not metrizable**, and for a bedrock reason. Any space coming
from a distance function has a basic separation property: given two distinct
points, at least one of them sits in an open set excluding the other (formally, it
is a $T_0$ space). Metrizable spaces are always $T_0$. But in the indiscrete
two-point space the *only* nonempty open set is everything, so neither point can
be isolated from the other. It fails $T_0$, hence fails metrizability. It is as
non-metrizable as a space can be.

Now reconstruct it from two observers — the Sierpiński pair.

The **$\mathsf{true}$-resolving observer** declares a set open exactly when, if it
contains $\mathsf{false}$, it must also contain $\mathsf{true}$. Its open sets are
precisely the empty set, the singleton $\{\mathsf{true}\}$, and the whole space.
It resolves the phantom point $\{\mathsf{true}\}$.

The **$\mathsf{false}$-resolving observer** is the mirror: a set is open when
containing $\mathsf{true}$ forces containing $\mathsf{false}$. Its open sets are
the empty set, $\{\mathsf{false}\}$, and the whole space.

Each observer sees a phantom singleton — a lone point that looks open through one
lens. Each is strictly finer than the indiscrete reality. Yet look at what they
*agree* on: a set open to both must satisfy "contains $\mathsf{false}$ $\Rightarrow$
contains $\mathsf{true}$" *and* "contains $\mathsf{true}$ $\Rightarrow$ contains
$\mathsf{false}$." That double implication says the set contains both points or
neither: it is empty or everything. The consensus is exactly the indiscrete
topology.

> **Refutation Theorem.** The indiscrete two-point space is non-metrizable, yet it
> is the consensus of exactly two strictly-sharper observers. Hence its phantom
> number is two, and the "crowd" conjecture — that non-metrizable spaces need at
> least three observers — is false.

The smallest, blurriest, least-separated nontrivial space is rebuilt by just two
observers, exactly like the pristine real line.

## The moral: separation and phantom number are orthogonal

Why did the seductive conjecture fail? Because it silently fused two things that
have nothing to do with each other.

The first is **separation** — how finely a space can tell its points apart. This
is what metrizability governs, and it is a genuinely geometric, distance-flavored
property.

The second is the **phantom number** — how many strictly-sharper viewpoints it
takes to intersect back down to reality. This is a purely *order-theoretic*
property of where the space sits in the lattice of all topologies: it measures how
the space factors as a "greatest common blur" of finer topologies, with no
reference to distance or curvature at all.

The conjecture assumed the first controlled the second. The two-point
counterexample proves they are independent. A space can be maximally blurry
(indiscrete, non-$T_0$, non-metrizable) and still lattice-reducible into just two
sharper observers — because the two observers each add a single phantom point, and
those two phantoms cancel perfectly in consensus. Meanwhile the exquisitely
separated real line also needs exactly two. Separation and phantom number live on
different axes.

## Why this is more than a curiosity

The phantom-topology framework is a rigorous toy model of a slogan usually left
vague: *reality depends on the observer.* Here that slogan becomes a theorem-laden
definition. Each observer's world is a legitimate topology. Objective reality is
the consensus. Measurement — adding observers, comparing notes — provably coarsens
the shared structure rather than refining it, mirroring the way, in the quantum
world, information about a system comes at the cost of disturbing it.

It also delivers a clean methodological lesson that reaches beyond topology.
Faced with a plausible link between two properties — here "blurriness" and
"number of observers" — the instinct is to prove it. The phantom number teaches
the opposite reflex: ask whether the two properties even live on the same axis. A
single minimal example, two indistinguishable points, is enough to sever a
connection that looked inevitable, and to redirect attention to the real
invariant: reducibility in the lattice of topologies.

Spaces that change when you look at them, it turns out, are not paradoxes to be
explained away. They are ordinary mathematics, seen through more than one pair of
eyes — and the discipline of consensus tells us precisely which structure is real
and which is phantom.
