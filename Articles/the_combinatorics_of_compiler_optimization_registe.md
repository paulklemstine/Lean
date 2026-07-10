# How Many Registers Does a Program Really Need? A Geometry of Overlap

Deep inside every compiler, a small drama plays out billions of times a day. A processor has
only a handful of *registers* — the fastest scratchpads it owns, the places where arithmetic
actually happens. A modern chip might have sixteen or thirty-two of them. Yet a program can
mention hundreds or thousands of variables. Somebody has to decide which variable lives in
which register, and when two variables must take turns. Get it right and code flies. Get it
wrong and the processor spends its life shuttling values to and from slow memory — the dreaded
*spill*.

This decision is called **register allocation**, and for decades it has been understood
through a beautiful and slightly intimidating lens: **graph coloring**. This article tells the
story of that lens, of a tempting conjecture about it that turns out to be *false*, and of the
sharper, simpler truth that survives — a truth that replaces an abstract graph invariant with
a quantity you can read off with a single sweep of your finger across a page.

## Variables that cannot share a room

Picture a variable's life inside a program. It is *born* the moment it is first assigned a
value, and it *dies* at the last instant its value is used. Between those two moments it is
**live**: the compiler must keep it somewhere. Two variables **interfere** if their lifetimes
overlap — if there is a moment when both are alive at once. Interfering variables cannot share
a register, for the same reason two guests cannot share a hotel room on the same night.

Turn this into a picture. Draw one dot for each variable, and connect two dots with a line
whenever the corresponding variables interfere. The result is the **interference graph** $G$.
A *legal* assignment of variables to registers is then exactly a way to color the dots so that
no two connected dots share a color. The number of colors is the number of registers. The
smallest number of colors that works is a famous graph invariant, the **chromatic number**
$\chi(G)$. So the question "how many registers does this program need?" becomes "what is
$\chi(G)$?"

That reformulation is elegant, but it comes with bad news attached: for *general* graphs,
computing the chromatic number is one of the hardest problems in computer science. If register
allocation really were graph coloring in full generality, compilers would be doomed to
heuristics forever.

## A tempting formula — and why it breaks

Two easy quantities bracket the chromatic number from above and below.

From above sits the classical greedy bound. Let $\Delta$ be the **maximum degree** of the
graph — the largest number of neighbors any single dot has. If you color the vertices one at a
time, each vertex has at most $\Delta$ already-colored neighbors, so among $\Delta+1$ colors
one is always free. Hence $\chi(G) \le \Delta + 1$. (Brooks' theorem refines this slightly,
but the spirit is the same.)

From below sits the **clique number** $\omega(G)$: the size of the largest set of dots that are
*all* mutually connected. A group of $\omega$ pairwise-interfering variables obviously needs
$\omega$ distinct registers, so $\chi(G) \ge \omega(G)$.

It is tempting to guess that these two bounds pinch the truth into a clean formula:
$$\chi(G) = \max(\Delta + 1,\ \omega(G)).$$
The guess says: you need $\Delta+1$ colors, *unless* the graph is actually less crowded than
its worst vertex suggests, in which case a big clique is the only thing forcing extra colors.

It is a lovely conjecture. It is also **false**. The cleanest witness is the *Petersen graph*,
a famously symmetric network of ten vertices in which every vertex has exactly three
neighbors, so $\Delta + 1 = 4$. It contains no triangle at all, so its clique number is merely
$\omega = 2$. The formula predicts $\max(4, 2) = 4$ colors. But the Petersen graph can in fact
be colored with just **three**. The formula overshoots. Whatever governs the chromatic number,
it is *not* this tidy maximum — not for arbitrary graphs.

So we have a choice. We can mourn the formula, or we can ask a sharper question: *the
interference graphs that real compilers actually produce are not arbitrary graphs.* Do they
have special structure that rescues an exact law?

They do.

## Enter the interval graph

Modern compilers, especially those using the fast and popular **linear-scan** allocator,
arrange a program so that each variable is live throughout one *contiguous* stretch of the
program's timeline. A variable's life is not a scattered set of moments; it is a single
unbroken segment — a **live range** $[\ell_i, h_i]$ running from its start point $\ell_i$ to
its end point $h_i$.

Once every variable is an interval on a line, the interference graph stops being arbitrary and
becomes something with a name and a personality: an **interval graph**. Two variables
interfere exactly when their segments overlap, and overlap of intervals on a line is an
extraordinarily well-behaved relation. Interval graphs are *chordal*, and chordal graphs are
*perfect* — a technical word with a spectacular consequence: for perfect graphs the chromatic
number and the clique number are always equal, $\chi(G) = \omega(G)$, with no slack. The
lower bound and the true answer coincide.

And for intervals the clique number has a wonderfully physical meaning. Define the **depth**
at a program point $t$ to be the number of live ranges covering $t$ — the number of variables
simultaneously alive at that instant. The **maximum overlap** $D$ is the largest depth over
all points: the single most crowded moment in the program's life. Our main result is that this
homely, hand-countable quantity *is* the answer.

> **The Maximum-Overlap Law.** For any program whose variables occupy contiguous live ranges,
> the interference graph satisfies
> $$\chi(G) = \omega(G) = D,$$
> where $D$ is the maximum number of variables simultaneously live at any single program point.
> Consequently the optimal number of registers is exactly $D$, and no allocation scheme,
> however clever, can do better.

The abstract, NP-hard-in-general chromatic number has collapsed into a number you compute by
scanning the timeline and asking, "what is the largest pile-up?"

## The one-dimensional miracle: Helly's property

Why does the clique number equal the maximum overlap? A clique is a set of variables that
*pairwise* interfere — every two of them overlap. Maximum overlap requires something stronger:
that they *all* overlap at *one common* point. In two dimensions these are genuinely
different. Three long, thin rectangles can pairwise cross while sharing no common point, like
three swords crossed in a fencing salute. Pairwise agreement need not imply universal
agreement.

On a *line*, this gap vanishes. This is the one-dimensional case of **Helly's theorem**, and
it is the geometric heart of the whole story:

> **One-Dimensional Helly Property.** If a collection of intervals overlaps pairwise, then all
> of them share a common point.

The proof is a single vivid observation. Take the interval whose *start* point $\ell_m$ is the
latest — the last one to open. Every other interval in the clique overlaps this last-opener,
which (since it opened even earlier) means every other interval must still be open at the
moment $\ell_m$. So the point $\ell_m$ lies inside all of them at once. Pairwise overlap, on a
line, forces a *common witness point*, and that point is simply the maximum of the left
endpoints.

This little lemma does all the heavy lifting. It says that any clique of $k$ mutually
interfering variables is really $k$ variables all alive at one instant — a depth-$k$ pile-up.
So the largest clique is exactly the deepest pile-up: $\omega(G) = D$. Combine that with
perfection's $\chi = \omega$ and the law falls out. The very same maximizing point $\ell_m$
also *exhibits* a clique of size exactly $D$, so the bound is genuinely achieved — this is not
a definitional accident but a real, attained equality.

## Coloring by scanning: why linear-scan is optimal

An exact count is satisfying, but a compiler needs an actual assignment. Here the same idea
delivers a concrete, blazingly fast algorithm. Sort the variables by their start points and
color them **earliest-start-first**. When it is variable $v$'s turn, look at its already-placed
interfering neighbors. Each of them overlaps $v$ and started *no later* than $v$ — so, by the
Helly observation, each of them is still alive at $v$'s own start point $\ell_v$. That means
all of $v$'s already-scheduled conflicts are part of the pile-up at $\ell_v$, of which there
are fewer than $D$ (counting $v$ itself brings the pile to at most $D$). Fewer than $D$ colors
are forbidden, so among $D$ registers one is always free.

This is precisely why the **linear-scan** allocator — a single left-to-right sweep — is not
just fast but *optimal* for contiguous live ranges. It never needs more than $D$ registers,
and $D$ registers are provably necessary. Reversing this sweep gives the "latest start first"
ordering that graph theorists call a *perfect elimination ordering*, the structural signature
of chordal graphs, here made completely concrete.

## The refinement of the greedy bound

Where does the old degree bound $\chi \le \Delta + 1$ fit? It is still true, but the overlap
law reveals it as a loose shadow of a sharper fact:
$$D \le \Delta + 1.$$
The reasoning is immediate. The deepest pile-up is a clique of $D$ mutually interfering
variables; pick any one of them, and its other $D-1$ clique-mates are all its neighbors, so it
has degree at least $D-1$, giving $\Delta \ge D - 1$. Thus $D \le \Delta + 1$, and since
$\chi = D$, the classical greedy guarantee is recovered — but now we know *exactly* how much
slack it carries. The greedy bound is tight only when the deepest pile-up already saturates
the busiest variable's neighborhood. In real programs the maximum overlap is typically far
below $\Delta + 1$, which is precisely why practical allocators comfortably fit realistic code
into modest register banks.

## Spilling, made geometric

What happens when a program's maximum overlap exceeds the number of registers you actually
have? Then no coloring exists, and some variable must be *spilled* — evicted to memory for
part of its life. The overlap law reframes this too. With only $k < D$ registers, every
program point of depth greater than $k$ is "over-full" and must shed variables. Because live
ranges are intervals, a single well-chosen eviction can relieve an entire contiguous congested
region at once. Spilling becomes a one-dimensional covering problem about the *depth profile*
— the graph of depth versus program point — rather than an opaque question about an abstract
network. This geometric view is what makes classic heuristics like "spill the
highest-degree variable" intelligible: on interval graphs, a variable's degree is controlled
by the depths at its two endpoints, so the busiest variable is always sitting near a deepest,
most congested point — exactly the place relief is needed.

## The moral

There is a satisfying arc here. Register allocation begins as graph coloring, an NP-hard
problem in its full generality. A tempting universal formula for the chromatic number,
$\max(\Delta+1, \omega)$, dazzles briefly and then shatters on the Petersen graph. But the
graphs that compilers *actually* build are not adversarial; they are interval graphs, born of
the simple fact that a variable lives across one contiguous stretch of time. On that restricted
but ubiquitous class, an exact and computable law emerges from a one-line geometric truth about
intervals on a line:

$$\text{registers needed} \;=\; \chi(G) \;=\; \omega(G) \;=\; D \;=\; \text{maximum simultaneous overlap.}$$

The lesson generalizes far beyond compilers. Hard problems often become easy the moment we
notice the structure the real world imposes on their instances. Here, the structure is the
humble line segment, and the payoff is that one of the busiest computations on Earth reduces to
counting the tallest stack of overlapping intervals — something you can do, quite literally, by
sweeping a finger across the timeline and watching for the crowd.
