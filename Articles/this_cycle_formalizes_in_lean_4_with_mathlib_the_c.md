# Many Worlds of Mathematics: The Secret Topology of the Set-Theoretic Multiverse

## A universe that keeps splitting

Imagine that mathematics is not a single, fixed universe of objects but a vast, ever-branching landscape of possible worlds. In each world the familiar rules of arithmetic and logic hold, yet the worlds disagree about the deep questions — questions such as *how many real numbers there are*, or whether every set can be well-ordered in some particular pathological way. From any given world we can build a richer one, a *forcing extension*, in which some previously undecided question is finally settled. And from that richer world we can build a richer one still. The result is a branching tree of mathematical universes: the **set-theoretic multiverse**.

This picture is not science fiction. It is the working intuition of set theorists who study *forcing*, the technique invented by Paul Cohen in 1963 to prove that the Continuum Hypothesis is neither provable nor refutable from the standard axioms. Cohen's method builds new universes on top of old ones. Once you accept that such construction is always available, you are led naturally to ask: *what are the laws governing the act of passage from one universe to another?*

The astonishing answer, discovered by Joel David Hamkins and Benedikt Löwe, is that these laws form a precise, nameable system — a **modal logic**. This article tells the story of that logic, and of a new bridge connecting it to an unexpected corner of mathematics: **topology**, the study of shape, nearness, and continuity. Along the way we will meet *buttons* that can be pushed but never unpushed, *switches* that flip freely, and a quantitative law stating that in a suitable sense *almost every* mathematical statement is undecidable.

## Necessity and possibility, made mathematical

To reason about "every extension" and "some extension" we borrow two operators from **modal logic**, the logic of necessity and possibility. Let $W$ be the collection of worlds, and let $R$ be the *accessibility relation*: we write $R\,w\,v$ to mean "$v$ is a forcing extension of $w$." An *assertion* is simply a property $P$ that may be true in some worlds and false in others. We then define two new assertions:

$$\Box P \text{ holds at } w \iff \text{for every } v \text{ with } R\,w\,v,\ P \text{ holds at } v,$$

$$\Diamond P \text{ holds at } w \iff \text{for some } v \text{ with } R\,w\,v,\ P \text{ holds at } v.$$

In words: $\Box P$ ("necessarily $P$", or *"$P$ is forceable-permanent"*) says $P$ is true in **every** extension; $\Diamond P$ ("possibly $P$", or *"$P$ is forceable"*) says $P$ is true in **some** extension. These are the two verbs of the multiverse: *must* and *can*.

Which logical laws do these operators obey? The answer depends entirely on the *shape* of the accessibility relation $R$, and this is where the theory becomes beautiful. Each classical modal axiom turns out to correspond to a simple geometric condition on $R$. This dictionary — the *Sahlqvist correspondence* — is the first pillar of our story.

## A dictionary between axioms and shapes

Here is the correspondence, stated as a set of exact equivalences. For each axiom schema, the modal law holds for **all** assertions if and only if the relation $R$ has the stated shape:

- **Axiom T**, $\Box p \to p$ ("what is necessary is true"), holds exactly when $R$ is **reflexive** — every world is an extension of itself.
- **Axiom 4**, $\Box p \to \Box\Box p$ ("the necessary is necessarily necessary"), holds exactly when $R$ is **transitive** — an extension of an extension is an extension.
- **Axiom B**, $p \to \Box\Diamond p$, holds exactly when $R$ is **symmetric** — if $v$ extends $w$ then $w$ extends $v$.
- **Axiom 5**, $\Diamond p \to \Box\Diamond p$, holds exactly when $R$ is **Euclidean**.
- **Axiom .2**, $\Diamond\Box p \to \Box\Diamond p$, holds exactly when $R$ is **directed** (also called *confluent*): any two extensions of a world have a common further extension.

Each of these is a two-way street: the shape forces the law, and the law forces the shape.

Now comes the punchline of the classification. The forcing order is genuinely **reflexive** (a universe is trivially a forcing extension of itself), genuinely **transitive** (iterating forcing gives forcing), and genuinely **directed** — this last is the *amalgamation* property of forcing, the fact that any two extensions can be jointly absorbed into a common larger one. So axioms **T**, **4**, and **.2** all hold. But forcing is emphatically **not symmetric**: once you have added a new real number you cannot, by forcing, take it back. So axioms **B** and **5** *fail*.

The logic with T, 4, and .2 but not B or 5 has a name: it is **S4.2**, the Hamkins–Löwe logic of forcing. The whole drama lives in the loss of symmetry. Symmetry is precisely the property whose absence separates the full, collapse-everything logic **S5** from the honest, arrow-of-time logic **S4.2**.

To make this concrete and airtight, one can exhibit a single explicit model where all of this is visible at once: take the worlds to be the natural numbers $0, 1, 2, \dots$ with $R\,w\,v$ meaning $w \le v$. This relation is reflexive, transitive, and directed (given $a$ and $b$, their maximum is above both), so T, 4, and .2 hold. But it is not symmetric — $0 \le 1$ while $1 \not\le 0$ — and indeed both B and 5 fail. The order $(\mathbb{N}, \le)$ is thus a faithful miniature of the forcing multiverse: it validates exactly S4.2 and refutes S5.

## Buttons and switches

Within this multiverse some assertions behave in strikingly different ways, and Hamkins gave them memorable names.

A **button** is an assertion that, once made true by forcing, can never be made false again — you can push it, but you cannot un-push it. Formally, a button is an assertion that is *stable*: its truth is preserved along accessibility. The key structural result is that, over a reflexive frame, the buttons are *exactly the fixed points of necessity* — an assertion $S$ is a button precisely when $S$ and $\Box S$ coincide at every world. Buttons, moreover, are well-behaved algebraically: the conjunction of two buttons is a button, so is their disjunction, and the distributive law holds. In short, **the buttons form a distributive lattice**.

A **switch**, by contrast, is an assertion that can always be flipped either way: from any world you can force it true and you can force it false. In the *fully connected* multiverse — the idealized situation in which every world is an extension of every other — the switches are exactly the **non-constant** assertions: those that are true somewhere and false somewhere. And a genuine switch can never be a non-trivial button: the two notions are cleanly disjoint. Buttons are the assertions with an arrow of time; switches are the assertions with none.

## Independence is the rule, not the exception

So far the story has been qualitative. The third pillar makes it quantitative, and the result is bracing.

Fix a finite number $n$ of independent "atoms" — think of them as $n$ independent yes/no questions the multiverse might answer. A **branch** (a world, at this level of resolution) is an assignment of a truth value to each atom, so there are exactly $2^n$ branches. A **sentence** is any property of branches — that is, any Boolean function from branches to $\{\text{true}, \text{false}\}$ — and there are therefore $2^{2^n}$ sentences in all.

A sentence is **settled** if it has the same truth value in every branch: it is either always true or always false. There are exactly **two** such sentences, the constant "true" and the constant "false." Every other sentence is **independent** — true in some branch, false in another — and so cannot be decided one way or the other across the multiverse. The count is exact:

$$\#\{\text{independent sentences}\} = 2^{2^n} - 2.$$

Divide by the total $2^{2^n}$ and let $n$ grow. The proportion of settled sentences is $2 / 2^{2^n}$, which races to zero, so the proportion of independent sentences tends to **one**:

$$\frac{2^{2^n} - 2}{2^{2^n}} \longrightarrow 1 \quad \text{as } n \to \infty.$$

**Undecidability is generic.** In the space of all possible sentences, the decidable ones — the two constants — are a vanishing minority. The famous independence results of set theory are not exotic curiosities; they are the overwhelming norm, and it is the *decidable* statements that are rare and precious.

## The hidden topology

The newest chapter of this story, and the reason for revisiting it now, is a bridge to topology. It turns out that the modal operators $\Box$ and $\Diamond$ are not merely formal manipulations — they are **geometric**.

Recall that a **topology** on a set is a choice of which subsets count as "open," subject to the rules that the whole space and the empty set are open, and that unions and finite intersections of open sets are open. Every topology comes with two fundamental operations: the **interior** of a set (its largest open core) and the **closure** of a set (its smallest closed hull).

Given the forcing relation $R$, call a set of worlds **upward-closed** if, whenever a world belongs to it, so does every extension of that world. These are exactly the *stable* assertions — the buttons. Declare these upward-closed sets to be the open sets. This choice satisfies all the axioms of a topology (for *any* relation $R$ whatsoever), and the result is the **Alexandrov topology** of the multiverse.

The reward is a perfect dictionary. Whenever $R$ is a preorder — reflexive and transitive, exactly the T-and-4 situation of genuine forcing — the following identities hold:

- **Necessity is interior.** The assertion $\Box S$ is exactly the topological interior of $S$: the largest stable assertion that implies $S$.
- **Possibility is closure.** The assertion $\Diamond S$ is exactly the topological closure of $S$: the smallest costable assertion implied by $S$.

From these two identities everything else follows by pure topology. The idempotence law $\Box\Box p = \Box p$, for instance, is just the familiar fact that taking the interior twice is the same as taking it once. And the two named classes of assertions acquire crystalline topological identities:

- **Buttons are the open sets.** An assertion is a button (fixed by necessity) exactly when it is open in the Alexandrov topology.
- **Settled assertions are the clopen sets.** An assertion is settled — its truth value never changes along forcing, in either direction — exactly when it is **clopen**, that is, both open and closed.

These topologies have a special signature that ordinary spaces lack: they are **Alexandrov-discrete**, meaning that *arbitrary* intersections of open sets remain open, not merely finite ones. This is the structural fingerprint of a topology born from an order relation, and it is precisely what allows $\Box$ and $\Diamond$ to be computed pointwise, world by world.

Finally, the topological lens gives a luminous restatement of the counting law. In the fully connected multiverse — the symmetric S5 situation where every world extends every other — the only clopen sets are the empty set and the whole space. In other words, the only settled assertions are the two truth-constants, and everything else is genuinely independent. The abstract count "there are exactly two settled sentences" becomes the crisp topological statement "the space has exactly two clopen sets." Two faces of one truth.

## Why it matters

The set-theoretic multiverse began as a philosophical stance: the idea that there is no single "true" universe of sets, only a plurality of equally legitimate ones. What this line of work shows is that the stance has *hard mathematical content*. The passage between universes obeys a definite logic, S4.2, pinned down by the exact geometry of the forcing order. The special assertions — buttons and switches — form clean algebraic and topological structures. Undecidability is not a defect at the margins but the statistical norm. And beneath all of it lies a single organizing image: an Alexandrov space whose open sets are the stable assertions, whose interior operator is necessity, whose closure operator is possibility, and whose two clopen sets are the only things everyone can agree on.

It is a rare and satisfying thing when logic, combinatorics, and topology turn out to be describing the same object from three different angles. The multiverse of mathematics, it seems, has a shape — and we are beginning to learn how to see it.
