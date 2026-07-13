# The Mathematics of Analogy: How to Translate One World into Another

## A puzzle about understanding

When we say *"the heart is a pump,"* or *"an atom is a tiny solar system,"* or *"electricity flows like water,"* we are doing something that feels effortless and yet is one of the deepest acts of human thought: we are making an **analogy**. We take a structure we understand — pumps, solar systems, plumbing — and we lay it over a structure we are trying to understand — hearts, atoms, circuits. Where the two line up, we gain insight. Where they don't, we learn the limits of the comparison.

Douglas Hofstadter famously argued that analogy is not a decorative flourish on top of reasoning but its very core: to think is to map one situation onto another. That is a beautiful philosophical claim. But can it be made *precise*? Can an analogy be treated not as a vague resemblance but as a genuine mathematical **operation** — something with laws, with a best-possible version, with quantities you can measure?

This article says: **yes**. And the mathematics that makes it possible turns out to be surprisingly elegant. An analogy, done right, is a matched pair of translations — one forward, one back — locked together by a single balancing law. That law forces the pair to behave beautifully: translating there and back can only ever *add* detail, never remove it consistently; the backward translation is completely and uniquely determined by the forward one; and there is a sharp, countable measure of how faithful the analogy is. Best of all, in the world of shortest paths and scheduling — the so-called *tropical* arithmetic — the single best analogy has an explicit formula.

## Two worlds and a pair of translations

Picture two "worlds," $A$ and $B$. Each is not just a bag of objects but comes with a notion of *order*: some things are more general, richer, or larger than others. In the world of concepts, "vehicle" sits above "car," which sits above "sports car." We write $x \le y$ to mean *$x$ is below (more specific than, contained in) $y$*. A structure like this — a set together with such an ordering — is called a **partially ordered set**, or *poset*.

An **analogy** from $A$ to $B$ is a pair of maps:

- a **forward** translation $F : A \to B$, sending each object of the source world to its counterpart in the target, and
- a **backward** translation $G : B \to A$, sending each object of the target back to the source.

Both should respect order — if $x \le y$ then $F(x) \le F(y)$, and likewise for $G$ — because an analogy that scrambled the hierarchy of ideas would be no analogy at all. So far this is just two dictionaries. What makes it an *analogy* rather than an arbitrary pair of maps is a single, deceptively simple balancing condition:

$$F(a) \le b \quad \Longleftrightarrow \quad a \le G(b), \qquad \text{for all } a \in A,\ b \in B.$$

Read it aloud: *"the forward image of $a$ sits below $b$ exactly when $a$ sits below the backward image of $b$."* This is the **adjunction law**, and a pair satisfying it is classically called a **Galois connection**. It is the mathematical heart of what it means for two translations to be *compatible* — each is the other's best possible partner.

## What the balancing law forces

The magic of the adjunction law is how much it gives you for how little you assumed. From that one biconditional, a cascade of structure follows automatically.

**Round trips only add.** Start with a concept $a$ in the source, translate it forward, then translate it back. You never lose anything:

$$a \le G(F(a)).$$

Going to world $B$ and returning can only land you somewhere *at least as rich* as where you started. Symmetrically, on the other side a round trip only *shrinks*: $F(G(b)) \le b$. Translation and back-translation are honest — they may over- or under-shoot, but always in a single, predictable direction.

**The round trip is a closure.** Consider the composite operation $C = G \circ F$, "translate there and back," acting entirely within the source world. It has three properties that together make it what mathematicians call a **closure operator**:

1. *Inflationary*: $a \le C(a)$ — it never contracts.
2. *Monotone*: if $a \le a'$ then $C(a) \le C(a')$ — it respects order.
3. *Idempotent*: $C(C(a)) = C(a)$ — doing it twice is the same as doing it once.

The third is the striking one. Once you have completed a round trip, doing another round trip changes nothing. The concept has reached a stable, "analogically closed" form. This is exactly the behavior of familiar closure operations: take the convex hull of a set of points, and the hull of the hull is just the hull; span a set of vectors, and re-spanning adds nothing. Analogy, it turns out, closes concepts in precisely the same way.

**The backward map is not a free choice.** Here is perhaps the most surprising consequence for anyone who thinks of analogy as an art. *You do not get to choose the backward translation.* Given the forward map $F$, there is **at most one** backward map $G$ that completes it into a valid analogy, and it is pinned down by an explicit recipe:

$$G(b) = \text{the largest } a \text{ with } F(a) \le b.$$

The backward translation is the *most generous* source concept whose forward image still fits under $b$ — the tightest honest over-approximation the order permits. So an analogy is really determined by a *single* map together with the demand that it be part of a balanced pair. The "creative" backward half is forced. This uniqueness is what lets us speak of *the* best analogy rather than *a* best analogy.

## Measuring fidelity: how good is an analogy?

Not every analogy is perfect. "An atom is a solar system" gets the orbiting right and the scale, energetics, and quantum weirdness wrong. We would like to *measure* how faithful a given analogy is. The closure operator hands us the yardstick for free.

Call a source concept $a$ **analogically stable** if the round trip returns it unchanged:

$$G(F(a)) = a.$$

These are the concepts that survive translation into world $B$ and back *exactly* — the ideas for which the analogy is lossless. Define the **fidelity** of the analogy to be the number of such stable concepts (over a finite source world):

$$\mathrm{fidelity}(F, G) = \#\{\, a \in A : G(F(a)) = a \,\}.$$

Because the round trip is a closure operator, its set of stable points is exactly the *image* of the round trip — the concepts it can produce. So fidelity is a genuine structural invariant, not an arbitrary score.

And now the punchline: an analogy is called **perfect** when *every* source concept is stable, i.e. $G \circ F$ is the identity on $A$. The perfect analogies are exactly the ones of **maximum fidelity** — no analogy over the same source world can have more stable points than a perfect one, because $\#A$ is the ceiling and perfect analogies hit it. Perfection is not a vague ideal; it is the literal top of a countable scale.

## The best analogy has a formula: the tropical world

Abstract structure is satisfying, but does the "single best analogy" ever come with an actual formula you can compute? In one of the most useful arithmetics in applied mathematics, it does.

Replace ordinary addition and multiplication with a strange but powerful pair of operations: let "plus" mean **take the minimum**, and let "times" mean **ordinary addition**. This is the **min-plus** (or *tropical*) semiring. It sounds like a game, but it is the native arithmetic of optimization: the cost of the shortest path through a network, the finishing time of a schedule, the cheapest way to assemble a product — all of these are computed by min-plus matrix arithmetic. A matrix $A$ acts on a vector $v$ by

$$(A \otimes v)_i = \min_j \big( A_{ij} + v_j \big),$$

which reads exactly like *"the cheapest way to reach $i$, combining the cost $A_{ij}$ of a link with the cost $v_j$ of continuing from $j$."*

Now ask the analogy question. The forward map is $v \mapsto A \otimes v$. What is *the* backward map that completes it into a perfect-as-possible analogy? The theory says it is unique, and here it is explicitly — the **residual**, computed with *maximum* and subtraction instead of minimum and addition:

$$(A^\sharp w)_j = \max_i \big( w_i - A_{ij} \big).$$

This is the *smallest* source vector whose forward image still dominates $w$ — the tightest back-translation the order permits, exactly the object the general theory demanded, now made concrete. The two round-trip laws become a pair of **reconstruction inequalities**,

$$w \le A \otimes (A^\sharp w) \qquad \text{and} \qquad A^\sharp (A \otimes v) \le v,$$

which sandwich any attempt to recover a signal from its transformed version. In plain terms: when you push data through a min-plus transform and then reconstruct it with the residual, the reconstruction is the *tightest possible* one consistent with the data. This is precisely the classical inequality behind shortest-path recovery and behind solving min-plus linear systems $A \otimes x = b$ — the residual is the best inverse a non-invertible optimization problem can have, and $A^\sharp b$ is the greatest solution whenever a solution exists.

So the grand abstract story — analogy as an adjoint pair, back-translation forced and unique, fidelity measured by stable points — lands, in the tropical world, on a concrete, computable formula that engineers already trust for routing packets and scheduling factories.

## Why this matters

Three ideas are worth carrying away.

First, **analogy has laws**. The moment you demand that a forward and a backward translation be *compatible* — tied by the single adjunction biconditional — an entire edifice appears without further input: round trips become closures, back-translations become unique, and "goodness" becomes a countable invariant. Hofstadter's intuition that analogy is the engine of thought gains a precise mathematical skeleton.

Second, **the best analogy is not chosen but computed**. Because the backward map is uniquely determined by the forward map, "finding the best analogy" is not an open-ended search but the evaluation of a formula. In the tropical setting that formula is the residual, and it is the same object that optimization theory has used for decades to invert the un-invertible.

Third, **fidelity is a spectrum with a top**. Analogies range from lossy to lossless, measured by how many concepts survive a round trip unchanged, and the perfect analogies — order isomorphisms between the stable cores of the two worlds — sit exactly at the maximum. When we sense that one analogy is "deeper" than another, we may be sensing, quite literally, that more of our concepts pass through it intact.

An analogy, then, is more than a poet's tool. It is a mathematical operation with a balancing law, a forced inverse, a closure at its core, and — in the arithmetic of shortest paths — an exact formula for its best version. The bridge between two worlds, it turns out, obeys equations.
