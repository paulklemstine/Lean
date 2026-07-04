# Phantom Topologies: Spaces That Change When You Look at Them

## A space that has no single shape

Imagine handing the same map to two explorers and discovering that they see two
different landscapes. Where one traces a coastline, the other finds open sea.
This is not a riddle about perception or optics — it is a precise mathematical
possibility. The *shape* of a space, the very fabric that decides which points
are "near" which, need not be a fixed fact about the space at all. It can depend
on who is looking.

The branch of mathematics that studies shape without distance is **topology**.
A topology on a set $X$ is a rulebook that declares certain subsets to be
*open* — the mathematical stand-in for "a region with no sharp edge, a
neighborhood you can wiggle around inside without falling out." From this single
notion flow continuity, limits, connectedness, and almost everything we mean when
we say two spaces have "the same shape."

Usually a set carries *one* topology and that is the end of the story. The idea
explored here is to let go of that assumption. We imagine a whole crowd of
**observers**, and we let *each observer carry their own topology* on the same
underlying set of points. Call such an assignment a **phantom topology**: a
function that hands each observer $o$ a topology $T(o)$ on the shared set $X$.
Every observer agrees on *what the points are*; they disagree only on *which
regions count as open* — on the shape.

The guiding question becomes: if reality is a committee of observers, *what is
the real shape of the space?* And the surprising answer is that there are two
equally natural candidates, and they can be as far apart as it is possible to be.

## Two ways to pool many viewpoints

Suppose every observer has an opinion about which sets are open. There are two
utterly natural ways to distill a single "official" topology from the crowd.

**Consensus — what everybody agrees on.** Declare a set $U$ to be *officially
open* precisely when *every* observer already regards $U$ as open. This is the
cautious, unanimous reading of reality: a region counts as a genuine
neighborhood only if no observer objects. We call the resulting topology the
**consensus topology**.

**Possibility — what somebody can see.** At the other extreme, declare a set to
be open as soon as it can be *built out of* regions that *some* observer regards
as open. This is the generous, pooled reading: if any single observer can resolve
a feature, the pooled view inherits it. We call this the **possibility
topology**.

These are not arbitrary. In the grand ledger of all possible topologies on a
fixed set — ordered by *fineness*, where a finer topology simply has more open
sets and therefore resolves more detail — consensus and possibility are exact
mirror images. Consensus is the largest topology sitting *below* everyone's; it
is the greatest common structure. Possibility is the smallest topology sitting
*above* everyone's; it is the least common refinement. In the language of logic
they are the two modalities: consensus is *necessity* ("open for **all**
observers"), and possibility is *possibility* ("open for **some**"). They obey a
clean monotonicity law that runs pleasantly against intuition:

> **Each individual observer is finer than the consensus and coarser than the
> possibility.** Agreement can only *blur* — adding observers to the committee
> can only remove detail from the consensus. Pooling can only *sharpen* — adding
> observers to the pool can only add detail to the possibility.

Measurement, in this toy universe, literally coarsens structure when you demand
agreement, and refines it when you permit superposition. That single sentence is
the heart of the whole story.

## The real line, seen from the left and from the right

To make this concrete, we need observers who genuinely disagree — and the real
number line $\mathbb{R}$ offers a beautiful pair.

The first is the **right-looking observer**. For this observer, a set is open if
around every one of its points $x$ you can fit a little half-open interval
$[x, b)$ that stays inside the set — an interval that *includes* its left
endpoint $x$ but stops just short of some $b$ on the right. Under this rule the
interval $[0, 1)$ is a perfectly good open set. This is the famous *lower-limit*
(Sorgenfrey) viewpoint.

The second is the **left-looking observer**, its mirror image. Here a set is open
if around every point $x$ you can fit a half-open interval $(a, x]$ that includes
$x$ but reaches leftward to just past some $a$. For this observer $(0, 1]$ is
open. This is the *upper-limit* viewpoint.

Neither observer sees the world the way we ordinarily do. The familiar Euclidean
line — the one where open sets are unions of two-sided intervals $(a,b)$ — treats
$[0,1)$ as *not* open, because the point $0$ has no wiggle room to its left. So
the right-looking observer sees *too much*; so does the left-looking one, in the
opposite direction. And they genuinely disagree with each other: $[0,1)$ is open
for the right-looker and not for the left-looker.

Now ask the two questions.

**What do they agree on?** Remarkably, exactly the ordinary Euclidean line.

> **Consensus reconstruction.** A subset of $\mathbb{R}$ is open in the usual
> Euclidean topology if and only if it is open for *both* the left-looking and
> the right-looking observer. In symbols, the consensus of the two half-open
> viewpoints is precisely the standard topology on $\mathbb{R}$.

The proof is a two-sided squeeze. Suppose $U$ is open for both observers and $x$
lies in $U$. The right-looker gives you room $[x, b) \subseteq U$; the left-looker
gives you room $(a, x] \subseteq U$. Glue them and you get a genuine two-sided
neighborhood $(a, b) \subseteq U$ around $x$ — exactly what Euclidean openness
demands. Conversely, any ordinary open set already offers wiggle room on both
sides, so both observers are happy. The ordinary real line, that most familiar of
all spaces, turns out to be nothing more nor less than the *agreement* of a
left-looking and a right-looking eye. Two observers suffice to reconstruct it,
and — because each observer alone genuinely over-resolves — one does not.

**What can they see between them?** Here comes the twist.

> **Possibility collapse.** The possibility topology of the very same two
> observers is the **discrete** topology on $\mathbb{R}$: *every* subset is open,
> and every single point sits alone in its own open neighborhood.

The reason is startlingly simple, and it fits on one line. Take any point $x$.
The right-looker contributes the open set $[x, b)$ for some $b > x$; the
left-looker contributes $(a, x]$ for some $a < x$. Intersect them:

$$[x, b)\ \cap\ (a, x]\ =\ \{x\}.$$

The right half-open interval keeps everything from $x$ rightward; the left
half-open interval keeps everything up to and including $x$; their overlap is the
single point $x$ and nothing else. So in the pooled view *every singleton is
open*. And once every one-point set is open, every set at all is open — because
any set is just the union of its points. The pooled line shatters into
individual, fully isolated points.

Pause on the contrast. **The same two observers** — left-looking and
right-looking — reconstruct the smooth, connected Euclidean line when you ask
what they *agree* on, and shatter it into a cloud of isolated dust when you ask
what they can *jointly resolve*. Necessity gives you the continuum; possibility
gives you the discrete. One pair of eyes, two opposite realities, chosen entirely
by *how* you pool them.

## Why the collapse happens, and why it is not a fluke

It is tempting to suspect a trick, but the mechanism is robust and geometric. A
right half-open interval is a knife that cuts cleanly on the left: it *keeps* its
left endpoint and abandons everything to the left of it. A left half-open
interval is the mirror knife, cutting cleanly on the right. Cross the two cuts and
only the shared endpoint survives. Every point of the line is pinned from both
sides at once, and pinning a point from both sides in the pooled topology is
exactly what it means to isolate it.

This also explains why the discreteness is not smuggled in from the Euclidean
structure. Nowhere does the argument mention distance, limits, or the standard
topology. It uses only the raw shapes of the two observers' basic open sets and a
single set-theoretic identity, $[x,b) \cap (a,x] = \{x\}$. The collapse is a
statement about *pooling half-open viewpoints*, not about the real numbers'
metric.

## Reality depends on the observer

Strip away the formalism and a genuinely philosophical picture remains. In this
framework the "real" topology is not a property the space possesses on its own.
It is *manufactured* from a community of viewpoints, and there is no single
canonical way to do the manufacturing.

Demand unanimity and the world coarsens: features that only some observers can
see are voted down, and what remains is the robust common structure — for the two
half-open observers, the ordinary continuum. Permit superposition and the world
sharpens without limit: every feature any observer can resolve is admitted, and
enough complementary viewpoints, laid over one another, can pin down every point
individually — for the same two observers, the fully resolved discrete space.

There is a deliberate echo of quantum mechanics here. As in the measurement
problem, the act of combining observations does not merely reveal a
pre-existing shape; it *produces* one, and the shape you get depends on the rule
of combination. The same underlying set of points is a smooth line or a scatter
of isolated dust, not because the points changed, but because the way we chose to
pool our observers changed.

This suggests a natural numerical invariant. For any space, ask: how many
coarser observers must you *pool* before their possibility topology becomes
discrete — before every point is individually isolated? For the real line the
answer is exactly **two**: the left-looking and right-looking half-open
viewpoints together isolate every point through the collapse
$[x, x+1) \cap (x-1, x] = \{x\}$, and no single coarser observer can isolate
anything at all. This "possibility number" is the exact dual of the more familiar
question — how many *sharper* observers must *agree* to reconstruct a space — and
together the two invariants begin to map out how much of a space's structure is
intrinsic and how much is an artifact of observation.

Phantom topologies are, in the end, a rigorous toy model for an old intuition:
that reality can depend on the observer. Here that intuition is not a slogan but
a theorem. The next time someone insists a space simply *is* a certain shape, you
can answer, with a straight face and a proof in hand, "That depends entirely on
how you look."
