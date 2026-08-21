# Pythagoras on the Light Cone: What a Tree of Right Triangles Can — and Cannot — Tell Us About Spacetime

## A very old equation, read in a new way

Every schoolchild meets the equation

$$a^2 + b^2 = c^2.$$

It is the rule of the right triangle: the two short sides, squared and added, give the square of the long one. The whole-number solutions — $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(20,21,29)$ — are the *Pythagorean triples*, and they have been catalogued since Babylonian clay tablets.

Now rearrange the equation:

$$a^2 + b^2 - c^2 = 0.$$

A physicist reading that line does not see a triangle. She sees the **Minkowski metric** of special relativity. In a universe with two space dimensions $x, y$ and one time dimension $t$, the "interval" separating an event from the origin is $x^2 + y^2 - t^2$. When it is positive the events are *spacelike* separated — no signal can pass between them. When it is negative they are *timelike* — one can cause the other. And when it is exactly zero, the separation is *lightlike*: the two events are joined by a ray of light.

So every Pythagorean triple is a point on the **light cone** of a $2{+}1$-dimensional spacetime, with the two legs as spatial coordinates and the hypotenuse as time. The triples are, quite literally, integer flashes of light.

That coincidence is the seed of a bold question, and this article is the story of what happens when you take it seriously.

## The tree that grows all triangles

Pythagorean triples are not scattered at random. In 1934 B. Berggren discovered — and F. Barning and A. Hall rediscovered — that all the *primitive* triples (those whose legs share no common factor) are generated from the single seed $(3,4,5)$ by three simple substitution rules, each applied over and over. Writing a triple as a column vector, the rules are three $3\times 3$ integer matrices:

$$A=\begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix},\qquad B=\begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix},\qquad C=\begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix}.$$

Feed $(3,4,5)$ into them and you get three new triples:

$$(3,4,5)\;\longrightarrow\;(5,12,13),\quad (21,20,29),\quad (15,8,17).$$

Feed each of those in again, and you get nine, then twenty-seven, then eighty-one. Every primitive triple appears exactly once, at exactly one address. The result is an infinite, perfectly regular ternary tree — the **Berggren tree** — with $(3,4,5)$ at the root and $3^k$ triples at depth $k$.

The three matrices are not arbitrary. Each one *preserves* the quantity $a^2+b^2-c^2$: if you start on the light cone, you stay on the light cone forever. In physicists' language, each matrix is an integral **Lorentz transformation** of $2{+}1$-dimensional spacetime — a discrete boost or reflection, an element of the group $O(2,1;\mathbb{Z})$. The Berggren tree is not merely a tree of triangles. It is an orbit of the Lorentz group acting on a single light ray.

## Causal sets: spacetime made of dust

Here the story picks up a second thread, from quantum gravity.

One of the most elegant approaches to reconciling gravity with quantum mechanics is **causal set theory**, proposed in 1987 by Bombelli, Lee, Meyer and Sorkin. Its slogan is: *order plus number equals geometry*. Throw away the continuum. Keep only a discrete set of "events" and a relation $x \prec y$ meaning "$x$ can influence $y$". Demand three axioms:

1. **Order.** The relation is transitive and has no cycles — you cannot be your own ancestor.
2. **Local finiteness.** Between any two events there are only finitely many others. This is what makes spacetime discrete: a finite volume holds a finite number of atoms.
3. **Faithful embedding.** The set should look, statistically, like a sprinkling of points into a Lorentzian spacetime.

The deep insight is that if you have the causal order and you know how to count, you get the metric for free — including the *dimension* of the spacetime. The trick, due to Myrheim and Meyer, is to count events in a **causal interval**: the set of all events lying causally between two given ones. In $d$-dimensional Minkowski space, the interval between two events separated by proper time $\tau$ is a double cone whose volume scales like $\tau^{d}$. So count the atoms in an interval, watch how the count grows with $\tau$, and read off the dimension from the exponent.

Now the moonshot becomes irresistible. Here is a discrete, infinite, exactly describable set of events, sitting exactly on the null cone of $2{+}1$ Minkowski space, carrying an exact action of the integral Lorentz group, with a natural tree order (ancestor-of) and a famous growth rate. **Is the Berggren tree a discrete model of spacetime?**

## What survives: the tree really is a causal set

The first half of the answer is a clean yes, and it is more than a formality.

Call an *event* a triple $(a,b,c)$ of strictly positive integers with $a^2+b^2=c^2$, and declare $t \prec u$ when $u$ can be reached from $t$ by some finite word in the three moves. Three facts must be checked.

**Nothing goes backwards.** Each of the three moves strictly increases the hypotenuse — in fact by at least one unit. So a word of length $n$ starting from an event lands at an event whose hypotenuse has grown by at least $n$. This single monotonicity fact kills closed causal curves outright: a nonempty word can never return you to where you started. There is no grandfather paradox in the tree of triangles.

**Every event has a unique parent.** This is the combinatorial heart. There is one universal "undo" map,

$$P(a,b,c) = (a+2b-2c,\; 2a+b-2c,\; -2a-2b+3c),$$

and the striking fact is what it does on the three branches:

$$P(A\cdot v) = (a,-b,c), \qquad P(B \cdot v) = (a,b,c), \qquad P(C \cdot v) = (-a,b,c).$$

$P$ inverts the middle move exactly; on the two outer branches it returns the parent with one sign flipped. Since genuine events have *positive* legs, the position of the minus sign identifies which move was used. One map, read three ways, recovers both the parent and the move. From this follows the tree property: the word of moves leading from an ancestor to a descendant is **unique**, there is exactly one path, and the level at depth $k$ has exactly $3^k$ events, each of them an antichain member — no two events at the same depth are ever related.

**Intervals are finite.** With unique paths in hand, the interval between $t$ and a descendant $u$ reached by a word of length $k$ is simply the set of the $k+1$ prefixes of that word. It is finite. Local finiteness holds.

So the axioms of order, acyclicity and local finiteness are all satisfied. The Berggren tree *is* a causal set. And the Lorentzian scaffolding around it is real: every word of moves is an integral Lorentz transformation preserving $a^2+b^2-c^2$; the tree is exactly the orbit of the root under that action; the determinant of a word is $(-1)^{\#B}$, so the middle move is the orientation-reversing generator while the outer two sit in the proper Lorentz group; and — a pretty corollary — distinct words give distinct matrices, so the three Berggren matrices generate a **free monoid of rank three** inside $O(2,1;\mathbb{Z})$. That freeness is precisely why the levels have $3^k$ elements: the growth of the tree is the growth of a free monoid.

## What breaks: the order is genealogy, not causality

And now the twist, which is the real result of this investigation.

A causal set is supposed to be a discrete spacetime. So one must ask: when the tree says $t \prec u$, does Minkowski space agree? Is the parent *inside the light cone* of the child?

The answer is a flat no, and it fails as badly as it possibly can. Compute the ambient interval between two events $t=(a,b,c)$ and $u=(a',b',c')$. Because both lie on the null cone, the algebra collapses beautifully:

$$Q(u-t) = 2\,(cc' - aa' - bb').$$

And one can show, using only the coprimality of the legs, that this quantity is **strictly positive for every pair of distinct events of the tree**. Two distinct points of a light cone are always spacelike separated unless they lie on the same null ray — and primitivity forbids two distinct primitive triples from being proportional. Hence:

> **Every two distinct events of the Berggren tree are spacelike separated.**

Every parent–child edge, every ancestor–descendant pair, every relation the tree calls "causal" is a relation Minkowski space calls *impossible*. No signal can travel from $(3,4,5)$ to $(5,12,13)$. The tree order is a **genealogical** order — an order of construction, of how the triples were built — and it has nothing to do with who can send light to whom.

Even the edge lengths come out exactly, and they are all positive:

$$Q(A\text{-edge}) = 4(c-b)^2, \qquad Q(B\text{-edge}) = 4(a-b)^2, \qquad Q(C\text{-edge}) = 4(c-a)^2,$$

and none of these can vanish, because no primitive triple has $a=b$ (that would force $c^2=2a^2$).

## And the dimension is one, not three

The second half of the moonshot claimed that the tree's famous growth rate — governed by the silver ratio $1+\sqrt2$ — would "reproduce" the dimension $2{+}1$. It does not, and the reason is sharp.

Recall the Myrheim–Meyer recipe: count events in an interval of proper time $\tau$ and look for growth like $\tau^{d}$. Here the count is exact. Because paths are unique, an interval of proper time $k$ consists of exactly the $k+1$ prefixes of the connecting word:

$$\bigl|\,[\,t,u\,]\,\bigr| = k+1 \quad\text{whenever } u \text{ is a depth-}k\text{ descendant of } t.$$

Worse (for the hypothesis), every interval is a **chain**: any two of its events are related. In a real sprinkling into $d$-dimensional Minkowski space with $d \ge 2$, a large interval is fat with *unrelated* pairs — that is what dimension means combinatorially. Here there are none. The growth is exactly linear, so no bound of the form $\rho \tau^2 \le |[t,u]|$ can hold for any positive density $\rho$. The effective dimension of the Berggren causal set is exactly **one**. It is a discrete line, not a discrete spacetime.

Where, then, did the exponential growth go? It is genuinely there — but in the wrong place. Follow the "spine" of the tree, applying the middle move over and over:

$$(3,4,5) \to (21,20,29) \to (119,120,169) \to (697,696,985) \to \cdots$$

The legs stay twins forever (their difference is always $\pm1$, because the middle move flips the sign of $a-b$), so each link of the spine has *exactly* the same spacelike length $4$ — a uniformly spaced discrete geodesic on the light cone. Meanwhile the hypotenuses obey the Pell recurrence

$$c_{k+2} = 6c_{k+1} - c_k, \qquad 5,\;29,\;169,\;985,\;5741,\;\dots$$

whose growth rate is $3+2\sqrt2 = (1+\sqrt2)^2$, the square of the silver ratio; in particular $c_k \ge 5^{k+1}$. So along one and the same chain, **proper time is exactly $k$ while the ambient time coordinate exceeds $5^{k+1}$**. The exponential growth is a property of the embedding coordinates — how fast the numbers get big — not of the causal order. Coordinates carry no dimension. Volume does, and the volume here is linear.

Similarly, the $3^k$ level growth beats every polynomial $k^d$; a spatial slice of a fixed-dimensional spacetime cannot grow that fast. The branching number of a tree and the dimension of a spacetime are different quantities, and this is a precise demonstration of the difference.

## A boundary that behaves beautifully

One piece of the moonshot did land, in an unexpectedly satisfying way: the **conformal boundary**.

Map each event to its direction on the "celestial circle", $(a/c, b/c)$ — a rational point of the unit circle $x^2+y^2=1$. This map is injective on the tree: distinct triples point in distinct directions, so the tree is faithfully painted onto the circle of null directions. Now follow the Pell spine. Its directions are

$$3/5 = 0.6,\quad 21/29 \approx 0.7241,\quad 119/169 \approx 0.7041,\quad 697/985 \approx 0.7076,\ \dots$$

converging to $\sqrt2/2$: the perfect $45^\circ$ direction, the diagonal of the square that Pythagoras' own school found irrational. So the spine has a well-defined endpoint at infinity — and that endpoint is **irrational**, hence not the direction of any event. The boundary strictly extends the causal set, exactly as null infinity strictly extends Minkowski space. The oldest irrational number in mathematics turns out to be the point at infinity of the tree of right triangles.

## What the failure teaches

It would be easy to file this under "nice idea, doesn't work". That reading misses the point. The negative results here are theorems, not disappointments, and they say something worth knowing about discrete geometry:

**A causal order cannot be inherited from a null cone.** Any set of distinct, pairwise non-proportional points on a light cone is a *total antichain* of the ambient causal order: nothing can influence anything. So any order you impose on such a set — however natural, however symmetric, however Lorentz-equivariant — is necessarily extra structure, unrelated to the ambient causality. To get a Lorentzian causal set from Pythagorean data you must move off the null cone, or change what "causal" means.

**Symmetry is not geometry.** The Berggren tree has an exact, unbroken, integral Lorentz symmetry. It sits exactly on the null cone. Every structural signal one could hope for is present — and the causal geometry still fails. Having the right symmetry group is not enough to be a spacetime; what matters is the *counting*, the volume law hidden in the order relation.

**Growth rates must be measured in the right currency.** The silver-ratio growth is real and beautiful, but it measures branching in a free monoid and magnitude of integer coordinates. Dimension is measured by interval volumes. Confusing the two is a natural mistake, and the Berggren tree makes the distinction unusually vivid: it grows like $3^k$ in one sense, like $(3+2\sqrt2)^k$ in another, and like $k$ in the only sense that determines dimension.

So the final ledger reads: the tree of Pythagorean triples *is* a causal set, is genuinely Lorentzian in its symmetry, has exactly computable link lengths, an exactly linear volume law, a free rank-three symmetry monoid, uniformly spaced geodesics, and an irrational point at infinity. It is a beautiful discrete object. It is just not spacetime — and now we know exactly why.

There is a certain justice in the ending. The tree of right triangles reaches out toward infinity and arrives at $\sqrt2$, the number whose discovery is said to have shattered the Pythagorean faith that all is number. Twenty-five centuries later, the same number stands at the boundary of the same triangles, marking the edge of a world that turned out not to be the one we live in — but which is, in its own right, exactly and completely understood.
