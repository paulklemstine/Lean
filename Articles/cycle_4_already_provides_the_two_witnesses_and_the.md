# Nineteen Worlds Where Nothing Believes Itself

## A census of the universes in which mathematics can doubt

There is a sentence that mathematics can write about itself and cannot escape.

In 1955, Martin Löb answered a question that Leon Henkin had posed a few years earlier, and his answer has haunted logic ever since. Suppose a formal theory strong enough to talk about its own proofs — arithmetic, say — manages to prove the statement "if I can prove $p$, then $p$ is true." One would think this is modest: it is merely a declaration of the theory's own soundness for the single sentence $p$. Löb showed that it is not modest at all. Any theory that proves "if $p$ is provable, then $p$" already proves $p$ outright.

Write $\Box p$ for "$p$ is provable." Löb's theorem is the schema
$$\Box(\Box p \to p) \to \Box p.$$
Take $p$ to be a contradiction and you get Gödel's second incompleteness theorem as a one-line corollary: a consistent theory cannot prove that it does not prove a contradiction. Trusting yourself, in mathematics, is indistinguishable from being wrong.

This article is about a question that sounds almost frivolous next to that famous drama, and which turns out to have a startlingly concrete answer:

> **In how many small universes is the Löb axiom true?**

The answer for three worlds is **nineteen**. Not nineteen up to some equivalence, not nineteen in some limiting sense — nineteen exactly, out of the $512$ possible universes on three worlds. And the reason it is nineteen connects a theorem about self-reference to a classical problem in enumerative combinatorics: the counting of partial orders.

---

## Worlds, arrows, and the shape of possibility

To make "universe" precise we use the standard picture of modal logic, due to Saul Kripke. A **frame** is a set of *worlds* together with an *accessibility relation*: an arrow $w \to v$ meaning "from $w$, the world $v$ is visible."

Fix a frame. A **valuation** decides, for each atomic proposition and each world, whether that proposition is true there. Once the valuation is fixed, complex formulas evaluate world by world in the obvious way, with a single new clause for the box:
$$\Box \varphi \text{ is true at } w \quad \text{iff} \quad \varphi \text{ is true at every world visible from } w.$$

The move that makes this powerful is to *forget the valuation*. A formula is **valid on a frame** if it is true at every world under *every* valuation. Validity is therefore a property of the arrows alone — of the raw combinatorial shape of the frame, with all the propositional content quantified away.

This is where modal logic turns into geometry. Each axiom carves out a class of shapes:

- The **reflection axiom** $\Box p \to p$ ("what is provable is true") is valid exactly when every world sees itself.
- The **transitivity axiom** $\Box p \to \Box\Box p$ is valid exactly when visibility is transitive.
- The **consistency formula** $\neg\Box\bot$ ("I do not prove a falsehood") is valid exactly when no world is a dead end.
- The **symmetry axiom** $p \to \Box\Diamond p$ is valid exactly when the arrows come in pairs, and the **euclidean axiom** $\Diamond p \to \Box\Diamond p$ exactly when any two worlds visible from a common world see each other.

Each of these correspondences is proved by a small, exact trick: to show that an axiom *forces* a property of the arrows, one produces the single most stubborn valuation, the one that will make the axiom fail if the arrows misbehave. For reflection at a world $w$, the stubborn valuation is "$p$ is true exactly at the worlds $w$ can see." Then $\Box p$ is automatically true at $w$; if the axiom is valid, $p$ must be true at $w$ as well; and by construction that means $w$ sees itself. One line, and a schema of logic has become a fact about a directed graph.

---

## What Löb's axiom asks of a universe

Now the deep case. What shape must a frame have for
$$\Box(\Box p \to p) \to \Box p$$
to be valid on it? The answer is the beautiful and slightly forbidding statement at the heart of provability logic:

> **Theorem (the Löb correspondence).** A single instance of the Löb axiom, over a single propositional variable, is valid on a frame $F$ exactly when the accessibility relation of $F$ is **transitive** and **converse well-founded** — that is, there is no infinite chain $w_0 \to w_1 \to w_2 \to \cdots$ of ever-further worlds.

Both directions require ingenuity.

To see that transitivity and converse well-foundedness *suffice*, one argues by induction along the relation, running the induction backwards, from the far end. Converse well-foundedness is exactly the licence to do this. The induction says: if every world beyond $v$ already satisfies $p$, then the premise $\Box(\Box p \to p)$ delivers $p$ at $v$ itself. Since there is nowhere for the induction to fall off, $p$ holds everywhere visible, which is the conclusion $\Box p$.

To see that they are *necessary*, one again hunts for stubborn valuations. For transitivity the witness is
$$x \mapsto \text{“$w$ sees $x$, and everything $x$ sees is also seen by $w$”},$$
a valuation that makes the Löb premise true at $w$ for free, and whose conclusion at any successor $v$ says precisely that $v$'s successors are $w$'s successors — transitivity. For converse well-foundedness the witness is even simpler. Suppose some nonempty set $S$ of worlds has no maximal member, meaning each of its worlds sees another of its worlds. Interpret $p$ as "*not* in $S$." Then the premise $\Box(\Box p \to p)$ holds at every world of $S$ — because for any $z$ in $S$ there is a successor in $S$ that falsifies $\Box p$ vacuously — but the conclusion $\Box p$ fails, since some successor is in $S$. So a frame validating Löb can contain no such set: every nonempty set has a maximal element, which is exactly converse well-foundedness.

That second argument is worth pausing over. The naive reading of "no infinite ascending chain" invites you to *build* an infinite chain, and building one requires infinitely many arbitrary choices. Recasting the condition as "every nonempty set has a maximal element" removes the choices entirely: one set, one valuation, one contradiction.

An immediate consequence: **a Löb frame is irreflexive.** No world sees itself, because a self-seeing world would be an infinite ascending chain all by itself. And so we arrive at the semantic face of Gödel's second theorem:

> **Theorem (the joint inconsistency).** No nonempty frame validates both the Löb axiom and the reflection axiom. Reflection demands that every world see itself; Löb forbids it. The only frame that can honour both is the empty one.

The famous incompleteness result — a sound theory cannot internalise its own soundness — becomes, in this picture, a collision between two graph conditions: reflexive and irreflexive cannot both hold anywhere at all.

---

## The collapse to combinatorics

Converse well-foundedness is an infinitary condition: it talks about infinite chains, or equivalently about arbitrary subsets. But if the frame has only finitely many worlds, an infinite chain in a transitive relation must revisit a world, and revisiting a world in a transitive relation produces a loop. So on a finite frame the condition collapses:

> **Theorem (the finite collapse).** On a frame with finitely many worlds, the Löb axiom is valid exactly when the accessibility relation is transitive and irreflexive — that is, exactly when it is a **strict partial order**.

This is the sentence that turns provability logic into combinatorics. "Strict partial order" is one of the oldest structures in mathematics: a way of saying that some things come before others, consistently and without circularity — the divisibility of numbers, the inclusion of sets, the dependency graph of a construction project. And now: the possible universes of a theory that can doubt itself.

So the census becomes a counting problem. A frame on the labelled worlds $\{1, \dots, n\}$ is nothing but an $n \times n$ matrix of zeros and ones; there are $2^{n^2}$ of them. How many validate Löb?

> **Theorem (the bridge).** For a frame on $n$ labelled worlds with adjacency matrix $R$, validity of the Löb axiom — a statement quantifying over *all* valuations, an uncountable second-order condition — holds if and only if $R$ passes the finite check "$R$ is transitive and has zero diagonal."

An infinite, second-order property has become a finite table lookup. And a table lookup can be performed:

| worlds $n$ | frames validating Löb | all frames $2^{n^2}$ | fraction |
|---|---|---|---|
| $0$ | $1$ | $1$ | $1$ |
| $1$ | $1$ | $2$ | $0.5$ |
| $2$ | $3$ | $16$ | $0.19$ |
| $3$ | $19$ | $512$ | $0.037$ |
| $4$ | $219$ | $65\,536$ | $0.0033$ |
| $5$ | $4231$ | $33\,554\,432$ | $0.00013$ |
| $6$ | $130\,023$ | $6.9 \times 10^{10}$ | $0.0000019$ |

The sequence $1, 1, 3, 19, 219, 4231, 130023, \dots$ is the count of labelled partial orders — a classical and famously irregular sequence in enumerative combinatorics, with no known closed form.

Look at what happened. A count that grows in a way nobody has been able to express in closed form is *also* the number of finite universes in which mathematics can be honestly modest about its own powers. On three worlds there are nineteen such universes, and here they are, in full: the empty order; the six orders with a single strict inequality $i < j$; the six "V" shapes (one element below two others, or above two others); the six three-element chains $i < j < k$; and — a subtlety worth savouring — nothing else. There is no shape with exactly two comparabilities among three points other than the V's, because $i < j < k$ *forces* $i < k$ by transitivity. Transitivity is not a free constraint; it is what makes $19$ so much smaller than the $2^6 = 64$ irreflexive relations on three points.

---

## Doubt is expensive; trust is cheap

Set this against the other axiom. How many frames on $n$ worlds validate reflection $\Box p \to p$? The condition is just "every world sees itself," which fixes the $n$ diagonal entries and leaves the other $n^2 - n$ entries entirely free. So the count is exactly $2^{n^2-n}$: $1, 1, 4, 64, 4096, \dots$.

On three worlds the tally is stark: **$64$ frames validate reflection, $19$ validate Löb, and $0$ validate both.**

The asymmetry is not an accident of small numbers; it widens without limit. Reflexive frames are a fixed fraction $2^{-n}$ of everything, while Löb frames are a vanishing fraction — the number of labelled partial orders is known to be roughly $2^{n^2/4}$, the square root of the number of frames, in the exponent. Being *able to trust yourself* is a condition on $n$ bits. Being *rightly modest* is a condition that eliminates all but a vanishing sliver.

There is one comforting regularity in the sliver. Given any Löb frame on $n$ worlds, adjoin an isolated world that sees nothing and is seen by nothing; the result is a Löb frame on $n+1$ worlds, and distinct frames stay distinct. So the sequence of counts is monotone increasing: doubt-friendly universes never become scarcer as you add room.

---

## What logic cannot say

Every result so far has the same form: an axiom, a shape. It is natural to hope that this works in reverse — that any reasonable shape can be pinned down by some collection of axioms. It cannot, and the reasons are structural and pretty.

The key notion is a **bounded morphism** (also called a p-morphism): a map $f$ from the worlds of $F$ to the worlds of $G$ such that (i) if $w$ sees $v$ then $f(w)$ sees $f(v)$, and (ii) if $f(w)$ sees some $u$ in $G$, then $w$ sees some $v$ in $F$ with $f(v) = u$. Such a map is exactly a morphism of "local visibility structure," and it has a striking property: modal truth is preserved and reflected along it, so if $f$ is onto, then *every formula valid on $F$ is valid on $G$*.

Now consider the frame whose worlds are the natural numbers, with $n$ seeing only $n+1$: a single infinite ladder, and irreflexive. Collapse the whole ladder to a single point. The collapse is a surjective bounded morphism, and its target is a single world that sees itself — reflexive. Therefore:

> **Theorem (irreflexivity is not definable).** No set of modal formulas — no matter how large or how cleverly chosen — is valid exactly on the irreflexive frames. In particular, no proof system whatsoever has the irreflexive frames as its exact class of sound frames.

This is a delicious tension with the Löb correspondence. The Löb axiom defines the transitive converse well-founded frames, all of which *are* irreflexive; yet irreflexivity on its own is beyond the reach of any axioms at all. Modal formulas can only see the world in front of them and along the arrows; they cannot see the identity of a world, and a loop looks exactly like an endless ladder if you can only look forward.

Two further limits come from the disjoint union of frames — two frames side by side with no arrows between them. A formula is valid on the union exactly when it is valid on each part. Consequently **"every world sees every world" is not definable** (it holds on a single reflexive loop but fails on two such loops side by side), and neither is **"some world is reflexive"** (place a loop beside a Löb frame: the union has a reflexive world, the summand does not). Nor is **"there is at least one world"**: every formula, including $\bot$, is vacuously valid on the empty frame.

Together these say something sharp about the expressive power of the language: the frame class of any modal proof system whatsoever must be closed under surjective bounded images, closed under disjoint unions, and must reflect disjoint unions. Three closure conditions, three impossibility theorems, no exceptions.

---

## The surprise in the degrees

The last chapter of the story starts with a graded version of trust. Instead of the single reflection axiom $\Box p \to p$, consider the family
$$\Box^k p \to p \qquad (k = 0, 1, 2, \dots),$$
"if $p$ is provable-in-$k$-nested-steps, then $p$." Reflection is the case $k = 1$. Each of these axioms has a clean shape:

> **Theorem.** $\Box^k p \to p$ is valid on a frame exactly when every world lies on a closed walk of length exactly $k$ — a route of $k$ arrows returning to its origin.

Collect the degrees that a given frame satisfies:
$$D(F) = \{k \in \mathbb{N} : \Box^k p \to p \text{ is valid on } F\}.$$
Since walks can be concatenated, $D(F)$ is closed under addition, and $0$ is always in it (the empty walk). So $D(F)$ is an additive submonoid of the natural numbers — an invariant of the frame, extracted purely from which axioms it validates.

Which monoids arise? The extremes are what you would guess. A Löb frame has $D(F) = \{0\}$: it has no closed walks at all, so no positive degree of self-trust survives. A frame in which each world sees precisely itself has $D(F) = \mathbb{N}$: total, unrestricted self-trust. And the directed $n$-cycle has $D(F) = n\mathbb{N}$, the multiples of $n$, which suggests a tidy picture in which every frame's degrees are the multiples of some fundamental period.

That tidy picture is false, and the smallest counterexample is charming. Take three worlds, each seeing the other two and not itself — the complete graph $K_3$ with both directions on every edge. There is no closed walk of length $1$ (no loops). There is a closed walk of length $2$: go out and come back. There is one of length $3$: go around the triangle. And once you have $2$ and $3$ you have every larger length. So
$$D(K_3) = \{0, 2, 3, 4, 5, \dots\} = \langle 2, 3\rangle,$$
the numerical semigroup generated by $2$ and $3$ — famously *not* the set of multiples of any single number, since it contains $2$ and $3$ but not $1$. Self-trust, graded by depth, is not organised by a single period. A theory can be trustworthy at depth two and depth three while failing at depth one, and no divisibility law explains the pattern.

---

## Why this is more than bookkeeping

Three morals, in increasing order of ambition.

**Modal axioms are combinatorial constraints in disguise.** The Löb axiom is not merely *about* well-foundedness; on finite structures it *is* the strict-partial-order condition, exactly and decidably. That equivalence lets a question phrased with an unbounded quantifier over all valuations be settled by a finite check.

**The scarcity of Löb frames quantifies a philosophical claim.** People often say that self-trust is "harder" than consistency. Here that is a ratio of integers: $19$ versus $64$ on three worlds, and a gap that grows super-exponentially.

**Expressive power has hard edges.** Three closure principles — under surjective bounded images, under disjoint unions, and reflecting disjoint unions — bound what any axiom system can say. Irreflexivity, universality, the existence of a reflexive world, and non-emptiness all fall outside. It is not that we have not found the right axioms; there are none.

The count $1, 1, 3, 19, 219, 4231, 130023, \dots$ has been studied for decades as a problem about ordering finite sets, and no formula for it is known. It is pleasant to learn that the same numbers answer a different question entirely: how many ways there are to build a small world in which a theory may reason about its own proofs without ever being able to vouch for them. Nineteen, when the world has three points.
