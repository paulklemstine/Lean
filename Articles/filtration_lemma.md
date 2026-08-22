# Clocks, Switches, and the Shape of Possibility

## A machine with two kinds of memory

Imagine a very simple machine. It has a **clock** that ticks forward — never backward — through $n$ positions, and a bank of $m$ **switches**, each of which starts off and, once flipped on, can never be flipped off again. A *state* of the machine is a reading of the clock together with a record of which switches are on. One state can *lead to* another exactly when the clock has not gone backwards and no switch has been un-flipped.

That is the whole device. Call a state of it a **clock-and-switch world**, and write $\mathrm{CW}(n,m)$ for the collection of all $n \cdot 2^m$ of them, ordered by "can lead to".

Geometrically, $\mathrm{CW}(n,m)$ is a product: a straight line of $n$ points crossed with an $m$-dimensional cube. It is the canonical picture of *monotone resource consumption* — time that only moves forward, and commitments that can only accumulate. Every irreversible process in the world has this shape somewhere inside it: an aging organism, a spent budget, a set of promises made, a stack of proofs derived.

Here is the question this article is about. The clock-and-switch worlds are extremely rigid — a line times a cube, nothing more. Yet a great many processes we care about have messy, branching, tangled state spaces. **Which of those messy state spaces are, in a precise sense, faithful shadows of a clock-and-switch machine?**

The answer turns out to be startlingly clean, and the last piece of it — the piece that makes the theory finally match the intuition — required inventing a new coordinate that the machine's own logic cannot see.

## What "faithful shadow" means

Suppose you have a state space $P$ — a finite set of situations with a relation "$p$ can lead to $q$", which we assume is reflexive and transitive (a *preorder*, written $p \le q$). You want to say that $P$ is a shadow of a clock-and-switch machine. What should that mean?

The naive answer, "there is an order-preserving surjection $f : \mathrm{CW}(n,m) \to P$", is far too weak. Order-preserving maps can crush all the interesting structure: send everything to a single point and you have "represented" the one-point space by any machine you like. What we want is a map that not only preserves the transitions we have, but *creates no illusions about the transitions we do not have*.

The right notion is a **bounded morphism** (also called a *p-morphism*). A map $f : X \to P$ between preorders is a bounded morphism when it satisfies two conditions:

- **Forth.** If $x \le y$ in $X$, then $f(x) \le f(y)$ in $P$. (Every transition upstairs is visible downstairs.)
- **Back.** If $f(x) \le q$ in $P$, then there is some $y \ge x$ in $X$ with $f(y) = q$. (Every transition downstairs can be *lifted*: whatever the shadow can do next, the machine can actually do.)

The back condition is the soul of the definition. It says the shadow is not merely order-preserving but *locally exact*: standing at any state $x$ of the machine, the possibilities you see in the shadow $P$ from $f(x)$ are precisely the possibilities the machine really has from $x$, no more and no less. This is exactly the notion under which modal (temporal, epistemic, provability) logic is invariant — a bounded morphic image satisfies the same modal formulas at corresponding points. So "faithful shadow" is not an aesthetic choice; it is forced by the logic.

Say that a finite preorder $P$ is **representable** if there is a *surjective* bounded morphism $\mathrm{CW}(n,m) \twoheadrightarrow P$ for some $n$ and $m$.

Two representations are obvious and were known from the start. **Forgetting the switches**, $w \mapsto \text{clock}(w)$, maps $\mathrm{CW}(n,m)$ onto the $n$-chain. And **counting the switches that are on**, $w \mapsto \#\{b : \text{switch}_b(w) = \text{on}\}$, maps the $m$-cube onto the chain of length $m+1$. Both are genuinely bounded morphisms — for the second one, the back condition says that to raise the count you just flip more switches on, which of course you can.

The question is what else.

## The greedy climb

Here is the main construction, and it is a small delight.

Let $P$ be a finite partial order that is **rooted** (there is a point $r$ below everything) and **directed** (any two points have a common upper bound; for finite $P$ this is the same as having a top element $\top$). Take a **linear extension** of $P$: a listing $t_0, t_1, \dots, t_{k-1}$ of all $k$ points of $P$ such that whenever $t_i \le t_j$ we have $i \le j$. Such a listing always exists — it is the statement that any partial order can be refined to a total order.

Now use one switch per point, and define a walk. Start at the root $r$. Read the switches from left to right. When switch $i$ is **on**, do this:

> if your current position is still below $t_i$, **jump to $t_i$**; otherwise, **jump to the top $\top$**.

When switch $i$ is off, stand still. After reading all $k$ switches, wherever you are standing is the image of that switch configuration.

That is the whole map: a greedy climb along a linear extension, with a "give up and jump to the top" clause. It sends a state of a machine with one clock tick and $|P|$ switches to a point of $P$.

**Theorem (Representation).** *Every finite rooted directed partial order is a surjective bounded morphic image of a clock-and-switch world. Explicitly, the greedy climb realises $P$ as an image of $\mathrm{CW}(1, |P|)$, and one can even do it with $|P| - 1$ switches.*

Both halves of the proof are instructive. **Surjectivity and the back condition** come from the linear extension: to reach any target $t_j$ from your current position, you turn on switch $j$ (and, if necessary, arrange the earlier switches so the climb is still below $t_j$ when it gets there — which is possible precisely because everything below $t_j$ appears *earlier* in a linear extension). **Monotonicity** is where the strange "jump to the top" clause earns its keep.

Why is it needed? Consider the diamond: a bottom $0$, two incomparable middle points $a$ and $b$, and a top $1$, with linear extension $0, a, b, 1$. Run the naive greedy climb — jump to $t_i$ when switch $i$ is on and you are below it, otherwise stand still. Turning on switch $b$ alone walks you to $b$. Turning on *both* $a$ and $b$ walks you to $a$ (you climb to $a$, and then you are not below $b$, so you stand still). But turning on more switches has moved you *down*: $b \not\le a$. Monotonicity fails. Repairing it by jumping to the top instead of standing still fixes exactly this: adding a switch either moves you further up the intended path, or catapults you to $\top$, which is above everything. The clause is not a technicality; it is the whole proof of the forth condition.

## The obstruction nobody ordered

The stated mission was more ambitious: every finite rooted directed **preorder** should be representable. A preorder differs from a partial order in allowing **clusters** — sets of distinct points that all lead to each other, $p \le q$ and $q \le p$ with $p \neq q$. Think of a system that can oscillate forever between two configurations without ever being able to tell them apart from the outside.

The ambitious statement is **false**, and the smallest counterexample is the two-point cluster itself.

**Theorem (Antisymmetry is inherited).** *If $X$ is a finite partial order and $f : X \to Y$ is a surjective bounded morphism, then $Y$ is antisymmetric: $p \le q$ and $q \le p$ force $p = q$.*

The proof is a lovely little maximality argument. Suppose $p \le q \le p$ in $Y$. Look at the set $S \subseteq X$ of all points mapping to $p$ or to $q$; it is nonempty and finite, so pick a **maximal** element $x$ of $S$. Say $f(x) = p$. Since $f(x) = p \le q$, the back condition hands us a $y \ge x$ with $f(y) = q$; then $y \in S$, and maximality of $x$ forces $y = x$, so $p = f(x) = f(y) = q$. The symmetric case is identical. Finiteness and antisymmetry of the *source* are all that is used.

Since every clock-and-switch world $\mathrm{CW}(n,m)$ is a finite partial order (a line times a cube — no clusters anywhere), no clock-and-switch machine can ever cast a shadow containing a cluster. Combining this with the greedy climb gives a complete answer:

**Theorem (Characterisation).** *A finite nonempty preorder is a surjective bounded morphic image of a clock-and-switch world if and only if it is rooted, directed, and antisymmetric.*

Three elementary order conditions, and the whole question is settled. Once you have this, structural facts fall out for free: representability is invariant under isomorphism, closed under finite products, inherited by every upward-closed principal filter $\{q : p \le q\}$, and satisfied by **every finite lattice with a least and greatest element** — hence by every finite Boolean algebra and every finite chain. Each of these is now a two-line verification of "rooted, directed, antisymmetric" rather than a construction of a morphism.

## How much machine do you need?

Knowing that a representation exists, one wants to know what it costs. Two independent lower bounds emerge, and they pull in different directions.

**The cardinality bound.** A surjection from $\mathrm{CW}(n,m)$ onto $P$ forces $|P| \le n \cdot 2^m$. So the number of switches must be at least about $\log_2 |P|$. This is the cheap bound.

**The height bound.** Define the **rank** of a state to be its clock reading plus the number of switches currently on. Moving strictly upward in $\mathrm{CW}(n,m)$ strictly increases the rank, and the rank lives in $\{0, 1, \dots, n+m-1\}$; so no strictly increasing chain in the machine has more than $n+m$ points. Now the *back* condition lets you lift any strictly increasing chain of $P$ to a strictly increasing chain of the machine, one step at a time. Therefore a chain of $\ell+1$ points in $P$ forces $\ell < n + m$: **the height of the shadow is a lower bound on clock ticks plus switches.** This bound is linear in the height, and for tall thin orders it dwarfs the logarithmic one.

For chains, the two ends meet exactly. The $(\ell+1)$-element chain is an image of the one-tick machine with $m$ switches **if and only if $\ell \le m$**. The morphism achieving $m = \ell$ is precisely the old "count the switches that are on" — so that classical example is not merely an example, it is *optimal*.

Two further facts pin down the roles of the two resources, and they are strikingly asymmetric:

- **With no switches you get exactly the chains.** A finite nonempty preorder is an image of some $\mathrm{CW}(n,0)$ if and only if it is a linear order. The clock alone can never manufacture branching; every bit of incomparability in the shadow is paid for by switches.
- **The clock is redundant.** Anything representable at all is representable with a *single* clock tick. Switches subsume clocks; clocks cannot subsume switches.

There is also a logical payoff. Because bounded morphisms preserve and reflect modal truth, one gets: **the modal theory of the clock-and-switch worlds is exactly the modal theory of the finite rooted directed partial orders.** A modal formula can be refuted on some finite bounded poset precisely when it can be refuted on a product of a chain with a Boolean cube. As a worked example, the axiom $\Diamond \Box p \to \Box \Diamond p$ — valid on any directed frame — can be checked on clock-and-switch worlds, where directedness is the wholly concrete operation "advance the clock to the later reading, take the union of the switches", and then exported for free to every finite rooted directed poset.

## Repairing the mission: a coordinate the order cannot see

So the original goal — every finite rooted directed *preorder* — is unreachable. Clusters are a genuine obstruction, and the obstruction is not an artifact of the proof; it is a theorem.

Unless one changes the machine.

Two natural repairs fail, and it is worth knowing why. **Putting a product order on an extra coordinate** does nothing: the augmented machine is still a partial order, so the inheritance theorem still applies and clusters remain unreachable. **Quotienting the machine** by an order-compatible equivalence also does nothing: such a quotient of a poset is again a poset, on the nose. Clusters cannot be produced by collapsing; they must be produced by *multiplying* — and by multiplying with something the order is blind to.

So: give the machine a **phase**, a value in $\{0, 1, \dots, c-1\}$, and declare that the accessibility relation **ignores it entirely**. A state of the augmented machine is a clock reading, a switch configuration, and a phase; and one state leads to another exactly when the underlying clock-and-switch parts say so, whatever the phases are. Formally, this is the product of $\mathrm{CW}(n,m)$ with the $c$-element **indiscrete** preorder, in which every point leads to every point. It has $n \cdot 2^m \cdot c$ states, and the moment $c \ge 2$ it is a genuine preorder rather than a partial order: any two states sharing a base form a cluster. Forgetting the phase is itself a surjective bounded morphism onto $\mathrm{CW}(n,m)$ — a third structural projection standing alongside "forget the switches" and "count the switches".

With this one extra coordinate, the mission statement becomes true.

**Theorem (Filtration lemma for preorders).** *Let $P$ be a finite nonempty rooted directed preorder in which every cluster has at most $c$ elements. Then $P$ is a surjective bounded morphic image of the phase-augmented machine with one clock tick, $c$ phases, and one switch per cluster of $P$.*

The proof is a clean two-layer factorisation, and it reuses the greedy climb untouched. First, collapse each cluster of $P$ to a point; the result is a finite rooted directed **partial order** $P/\!\!\approx$, so the greedy climb represents it using one switch per cluster. Second, use the phase as a *choice of element inside the reached cluster*: fix, for each cluster, an injection of it into the $c$ phases, and let the state $(\text{base}, \text{phase})$ map to the element of the cluster $f(\text{base})$ selected by that phase. Monotonicity is immediate, because the phase is invisible to the order and the underlying map is monotone. The back condition is where the two layers cooperate: to move to a target $p$, first lift the move to the cluster of $p$ using the back condition of the greedy climb, then set the phase to whichever value selects $p$ inside its cluster — possible exactly because the injection was chosen surjective onto the cluster.

**Corollary.** *Every finite rooted directed preorder — with no antisymmetry assumed — is a surjective bounded morphic image of a phase-augmented clock-and-switch world.* The mission statement, at last.

## And the phase count is exactly right

The pleasing part is that the new resource is not a blunt instrument. It is metered precisely.

**Theorem (Converse).** *In any surjective bounded morphic image of a phase-augmented machine with $c$ phases, every cluster has at most $c$ elements.*

The argument mirrors the antisymmetry proof, one level up. Given a cluster $C$ of the image, look at all machine states whose image lies in $C$ and choose one, $u$, whose **base** is maximal among these. The back condition then shows that *every* element of $C$ is already realised at that single base $u$, differing only in the phase — because moving to another element of the cluster would produce a state with base at least $u$, hence equal to $u$ by maximality. So $C$ injects into the set of phases, and $|C| \le c$.

Putting the two together:

**Theorem (Sharpness).** *For a finite nonempty rooted directed preorder $P$, the phase counts $c$ that work are exactly those with $c \ge$ (the largest cluster size of $P$). The minimum number of phases equals the maximal cluster size.*

And the characterisation loses a clause:

**Theorem.** *A finite nonempty preorder is a surjective bounded morphic image of a phase-augmented clock-and-switch world if and only if it is rooted and directed.* Antisymmetry has vanished — not because it was ignored, but because exactly one new, precisely-metered coordinate was purchased to pay for it.

## Why this shape of result matters

There is a pattern here that recurs across mathematics. You have a class of very simple, very concrete objects — here, lines times cubes — and a notion of faithful shadow. You ask what the shadows are. The first answer is "not quite what you hoped", and the gap between hope and truth is itself a theorem: an invariant (antisymmetry) that survives the shadowing process. Then you ask what minimal enrichment of the concrete objects closes the gap, you find it (one order-invisible coordinate), and — the real prize — you show that the enrichment is *metered exactly* by the invariant that was in the way (phases counted by cluster size).

The three structural projections — forget the switches, count the switches, forget the phase — are now understood not as scattered examples but as the visible faces of a single representation theorem, each one optimal in its own regime. And the moral for anyone modelling irreversible processes is concrete: **branching costs switches, height costs ticks-plus-switches, and indistinguishability costs phases** — at exactly one phase per indistinguishable alternative, no more and no less.
