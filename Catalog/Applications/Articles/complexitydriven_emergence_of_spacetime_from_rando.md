# How Spacetime Could Crystallize Out of Pure Information

## A tale of cuts, distances, and the geometry hiding inside complexity

Imagine you could take the universe apart the way you take apart a sentence:
not into atoms, but into *information*. Strip away the matter, the energy, even
the stage of space and time on which everything seems to play out, and ask a
stubborn question — what is left? A growing community of physicists believes the
answer is something surprisingly humble: a web of correlations, a network of
quantum threads tying one region to another. And the truly radical claim is that
**space itself is not fundamental at all**. Geometry — distance, area, curvature,
the very fabric of "here" versus "there" — emerges from how those threads are
woven, the way a smooth fabric emerges from the discrete crossing of warp and
weft.

This article is about a small, sharp, and *completely rigorous* corner of that
grand idea. We will not need quantum field theory or string theory. We will need
only two ingredients that a curious high-schooler can hold in their head: the
operation "take the minimum," and the operation "add." Out of just those two
moves — min and plus — a faithful skeleton of holographic geometry appears, with
phase transitions, reconstructable regions, and a notion of curvature, all of it
provable.

Mathematicians have a name for the world where you replace ordinary addition
with "take the minimum" and ordinary multiplication with "add." They call it
**tropical mathematics** (the name is a tribute to the Brazilian mathematician
Imre Simon, not to any property of the palm trees). In the tropical world,
$2 \oplus 5 = \min(2,5) = 2$ and $2 \otimes 5 = 2 + 5 = 7$. It sounds like a
party trick, but it is exactly the arithmetic that governs shortest paths,
optimal cuts, and — as we will see — the cheapest way to entangle two halves of
a quantum system. That last fact is the bridge between *complexity* and
*geometry*, and it is the heart of our story.

## The currency of entanglement: bond dimension

Start with a tensor network. Picture a graph: dots (vertices) for the pieces of
a quantum system, lines (edges) for the correlations between them. Each line
carries a number called its **bond dimension** $D$ — think of it as the
*bandwidth* of that connection, the number of independent quantum channels
running through it. A thin wire ($D=1$) carries no entanglement at all; a fat
wire carries a lot. Bond dimension is, quite literally, the price you pay in
complexity to entangle one region with another.

Now slice the network in two. Any way of partitioning the dots into a group $A$
and everything else defines a **cut**. The entanglement across that cut is
measured by a single integer, the **Schmidt rank** $\mathrm{rank}(A)$: the
number of independent quantum "modes" that must be threaded through the cut to
reproduce the state. The famous Ryu–Takayanagi proposal of holography says that
in the right limit this entanglement *is* the area of a surface in an emergent
space. Cut the network, count the threads, and you have measured a geometric
area. Information becomes geometry.

But which cut? A quantum system can be sliced a thousand ways. Giulio Tononi's
theory of consciousness — Integrated Information Theory — supplied a beautiful
organizing principle that turns out to be exactly right here: don't look at the
average cut, and don't look at the worst-case cut. Look at the cut that the
system can *least afford to lose*, the one across which it is **least**
entangled. That weakest seam is the system's Achilles' heel, and the
entanglement that survives even there is its **integrated information**.

We make this precise. For an $n$-party network, the integrated information of a
single cut $A$ is one less than its Schmidt rank, $\mathrm{rank}(A) - 1$ (the
"$-1$" simply discounts the trivial single thread that any nonzero state
carries). The integrated information of the whole network is the minimum over
every nontrivial cut:

$$\Phi \;=\; \min_{A \text{ a nontrivial cut}} \big(\mathrm{rank}(A) - 1\big).$$

There it is again — the tropical "min." The system's irreducible complexity is
a tropical sum over all the ways it could be torn apart.

## Four facts you can take to the bank

This definition is not just suggestive; it has a clean and provable internal
logic. Here are the load-bearing facts, each one established with full rigor.

**1. The weakest seam exists, and it sets the value.** There is always a
specific cut — call it the *Minimum Information Partition* — that achieves the
minimum. The system has a genuine fault line, not just an abstract lower bound.
And $\Phi$ is the *greatest* number that sits below every cut's information: it
is the tightest possible summary of the whole landscape of cuts.

**2. Zero integrated information means the system falls apart.** A network has
$\Phi = 0$ **if and only if** it is a product state across some cut — that is,
some slice has Schmidt rank exactly $1$, a thin wire carrying no real
entanglement. In holographic language, a region of "space" pinches off and
disconnects. Complexity and connectivity vanish together. This is an exact
equivalence, not a slogan:

$$\Phi = 0 \iff \exists \text{ a cut } A \text{ with } \mathrm{rank}(A) = 1.$$

**3. Bandwidth is a hard ceiling.** If every wire in your network has bond
dimension at most $D$, then no cut can carry more than $D$ threads, and so

$$\Phi \;\le\; D - 1.$$

You cannot manufacture more irreducible complexity than your bandwidth allows.
The concept's headline test case is the simplest nontrivial one: a
bond-dimension-$2$ network (a "qubit chain," in physics terms) is forced to obey
$\Phi \le 1$.

**4. The ceiling is sharp — and it is touched exactly when everything is
maximally entangled.** Here is the result we are proudest of. Consider the
*maximally entangled* network, the one whose Schmidt rank equals the full bond
dimension $D$ across **every single cut** — every wire saturated, no slack
anywhere. Then the inequality above becomes an equality:

$$\Phi \;=\; D - 1.$$

The bound is not loose; it is *attained*, and attained precisely by the most
entangled configuration. Moreover this maximal value coincides exactly with the
single-cut integrated information of the canonical maximally entangled state (the
"identity" coefficient matrix on $D \times D$). The complexity ceiling and the
geometry of maximal entanglement are the same number, viewed two ways.

This quartet — existence of the weak seam, the zero-iff-disconnected criterion,
the bandwidth ceiling, and its sharp saturation — is the algebraic backbone of
"complexity becomes geometry." It tells us *how much* geometry a given amount of
complexity can support, and exactly when the budget is spent.

## A threshold where geometry switches on

The most evocative prediction of the emergent-spacetime program is a **phase
transition**: dial up the bond dimension and, at some critical value, the
fractal tangle of a low-complexity network snaps into a smooth, classical
geometry. Tropical mathematics makes this transition not just plausible but
inevitable, and even gives a formula for where it happens.

Here is the mechanism, stripped to its essence. In holography the entanglement
entropy of a boundary region is the area of the *smallest* surface that
separates it from the rest — a minimal cut. Suppose two candidate cuts compete.
Write the bond dimension on a logarithmic scale, $t = \log D$, the natural
currency of entanglement entropy. Each cut contributes an "area-law" line that
grows with $t$:

$$S_0(t) = a_0 + c_0\, t, \qquad S_1(t) = a_1 + c_1\, t.$$

Here $c_i$ is the *size* of cut $i$ (how many wires it severs) and $a_i$ is a
fixed offset. The actual entanglement entropy is whichever is smaller — the
tropical minimum of the two lines:

$$S(t) = \min\big(a_0 + c_0 t,\; a_1 + c_1 t\big).$$

A minimum of straight lines is a **tropical polynomial**: a piecewise-linear,
concave, downward-bending curve. And concave piecewise-linear curves do exactly
one interesting thing — they have *kinks*. Set the two lines equal and solve:

$$t_c = \frac{a_0 - a_1}{c_1 - c_0}, \qquad D_c = e^{t_c}.$$

Below the critical bond dimension $D_c$, one cut wins and the geometry has one
character; above $D_c$, the *other* cut takes over and the geometry has a
different character. The slope of $S$ — the **scaling exponent** of the
entanglement — jumps discontinuously from $c_0$ to $c_1$ at the kink. That jump
is a genuine first-order phase transition, and the location $D_c$ is computable
in closed form from nothing but the cut sizes and offsets.

This is the tropical heartbeat of the whole conjecture: emergence of classical
spacetime is the moment the dominant minimal surface changes, and tropical
geometry guarantees that the change is sharp, that the curve bends only
downward, and that all of the "curvature" lives concentrated at the kinks. Away
from a kink the entropy is perfectly linear — flat, smooth, classical. *At* the
kink the discrete curvature

$$S(t-1) - 2 S(t) + S(t+1)$$

is strictly negative — a spike of curvature marking the transition. Everywhere
else it is zero. Geometry, in this picture, is smooth except where complexity
forces it to bend, and it can only ever bend one way.

There is a striking corollary lurking here, one the formal development makes
explicit: if you rescale *every* bond dimension uniformly — multiply all the
wires' bandwidth by the same factor — the winning cut never changes, because you
have shifted both lines by the same amount. **Uniform complexity produces no new
geometry.** For spacetime to emerge with structure, the entanglement must be
*heterogeneous* across the network. Curvature is a child of contrast.

## Reading the bulk from its edge

The second pillar of holography is even more astonishing than the first. The
**holographic principle** says that everything happening inside a region of
space is encoded on its boundary, like a three-dimensional scene captured in a
flat hologram. The interior — the "bulk" — is redundant; the edge knows it all.
But the edge does not know it *uniformly*. A patch $B$ of the boundary can only
reconstruct a certain interior region, its **entanglement wedge**. What is in
the wedge, the boundary patch can recover. What is outside it, the patch is blind
to.

The same min-and-plus arithmetic builds this picture exactly. Put the network's
vertices on a graph with a distance function $d$. The tropical distance from a
bulk vertex $v$ to a boundary region $S$ is the nearest member:

$$\mathrm{dist}(v, S) = \min_{b \in S} d(v, b).$$

The entanglement wedge of a boundary region $B$ is then the set of bulk vertices
that are *strictly closer* to $B$ than to the rest of the boundary:

$$\mathrm{Wedge}(B) = \{\, v : \mathrm{dist}(v, B) < \mathrm{dist}(v, \text{boundary} \setminus B)\,\}.$$

The strict inequality is doing quiet but crucial work: it carves out a clean,
robust region with no ambiguous tie-vertices sitting on a knife's edge. Every
vertex in the wedge has a positive *gap* — a margin by which it prefers $B$.

That margin is what makes the wedge *stable*. Real physical distances are never
known perfectly; they jitter. The rigorous statement is that if a vertex sits in
the wedge with gap $\delta$, then **any** perturbation of the distances smaller
than $\delta/2$ leaves it firmly inside. The wedge does not flicker under noise;
it is a robust phase, separated from its complement by a finite barrier — exactly
the behavior you would demand of a physically meaningful region.

And now the punchline: **reconstruction**. Encode a bulk state as a function
$\varphi$ assigning a value to each vertex. The boundary sees it only through a
min-plus convolution — the cheapest way to reach each boundary point:

$$\mathrm{Obs}(\varphi)(b) = \min_{v \in \text{bulk}} \big(\varphi(v) + d(v, b)\big).$$

The theorem says: under a mild non-degeneracy condition (each wedge vertex is the
*unique* cheapest route to some boundary point of $B$), if two bulk states
produce **identical boundary observations on $B$**, then they must be
**identical throughout the entire wedge of $B$**. The boundary patch determines
the bulk — but only inside its wedge, exactly as holography demands. A surgery
performed deep in the wedge is always detectable from the boundary; a surgery
performed outside it can hide. The edge knows its wedge and nothing more.

## Why a tiny rigorous model matters

It would be easy to dismiss all this as a toy. There are no gravitons here, no
Einstein equations solved, no continuum manifold — just finite graphs and the
arithmetic of min and plus. But that minimalism is the point. The grand
conjecture — that smooth Lorentzian spacetime crystallizes out of a random
tensor network once its complexity crosses a threshold — is, today, mostly
heuristic, supported by numerical experiments on supercomputers and by
suggestive analogies. What the tropical core provides is a *proven nucleus*: a
setting where every one of the conjecture's qualitative features can be stated
exactly and verified without loopholes.

In that nucleus we find, with certainty: a complexity measure with a sharp
ceiling that maximal entanglement saturates; a phase transition at a computable
critical bond dimension where the scaling exponent jumps; a guarantee that the
transition is sharp and one-sided because tropical entropy is concave; a proof
that uniform complexity is geometrically inert, so heterogeneity is the true
order parameter; and a faithful, noise-stable holographic reconstruction in
which the boundary determines the bulk precisely within its entanglement wedge.

None of these is the final theory of quantum gravity. All of them are the *kind*
of statement the final theory must contain, rendered in a form simple enough to
prove and rich enough to recognize. That is what good toy models do: they take a
dream and find, inside it, the smallest piece that is unmistakably true. The
dream is that spacetime is made of information. The smallest true piece, it
turns out, speaks the language of min and plus.
