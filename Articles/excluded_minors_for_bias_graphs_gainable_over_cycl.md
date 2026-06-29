# Forbidden Shapes: How Three Tiny Graphs Decide Whether a Network Can Carry Clockwise Arithmetic

## A puzzle about "going around in circles"

Imagine you are wiring up a network — power lines, road junctions, a circuit board, a social web of friends and rivals. Across each connection you want to record a small piece of arithmetic: a *gain*, a number that tells you how much something changes as you travel along that link. Voltage shifts across a resistor. A currency conversion across a trade route. A phase rotation across an optical fiber. A "+1 friend / −1 enemy" tally across a relationship.

Now ask the natural question. As you walk around a loop in your network and return to where you started, the gains should add up to *something*. Sometimes they cancel perfectly and you come back unchanged — the loop is **balanced**. Sometimes they don't, and you return with a net shift — the loop is **unbalanced**.

Here is the twist that turns this into deep mathematics. Suppose someone hands you a network and, for every loop, tells you in advance which loops are *supposed* to be balanced and which are *supposed* to be unbalanced — but does **not** tell you the gains. Can you always reverse-engineer a consistent set of gains that produces exactly that pattern of balance?

The surprising answer is: **not always.** And the reasons it can fail are astonishingly rigid. When your gains live in a clock arithmetic with $p$ hours — the integers modulo a prime $p$, written $\mathbb{Z}/p$ — whether or not a valid set of gains exists is governed entirely by a short list of *forbidden patterns*. If your network avoids all of them, gains exist. If it contains even one, gains are impossible. This article tells the story of the cleanest member of that list, and how a pigeonhole and a piece of pull-back magic pin it down completely.

## Biased graphs: keeping the balance, forgetting the rest

To make the puzzle precise, mathematicians use an object called a **biased graph**. The word "biased" is technical, not political: it refers to the *bias*, the chosen pattern of balanced versus unbalanced cycles.

A biased graph is an ordinary graph together with a rule that designates some of its cycles as balanced. Not every designation is allowed — the balanced cycles must hang together consistently — but for our story the key insight is what we choose to *remember* and what we *forget*.

We forget the vertices. We forget the geometric drawing. We remember only two things:

- which sequences of edges form a **cycle** (a closed walk that comes back to its start), and
- which of those cycles are **balanced**.

In the formal development, a cycle is recorded as a list of edges, each tagged with a direction of travel — a Boolean flag saying "I traversed this edge forwards" or "backwards." A biased graph $G$ is then just a pair of predicates: `isCycle`, telling you which oriented walks count as cycles, and `balanced`, telling you which of those are balanced. Everything else about the network is stripped away, because everything else is irrelevant to the gain question.

## Gains, and what it means to "realise" a bias

A **$\mathbb{Z}/p$-gain labelling** is a function $g$ that assigns to every edge $e$ a value $g(e)$ in the clock arithmetic $\mathbb{Z}/p$. To compute the gain of an oriented cycle, you walk around it and add up the labels, but with a sign: if you cross an edge forwards you add $g(e)$, and if you cross it backwards you subtract it. This is the **signed sum**:

$$\mathrm{signedSum}(g, c) \;=\; \sum_{(e,\,\text{dir}) \in c} \big(\text{dir} = \text{forward}\big)\, ?\, g(e)\, :\, -g(e).$$

We say the labelling **realises** the biased graph when the bias and the arithmetic agree on every cycle: a cycle is balanced *exactly when* its signed sum is zero. In symbols, for every cycle $c$,

$$G.\mathrm{balanced}(c) \iff \mathrm{signedSum}(g, c) = 0.$$

A biased graph is **$\mathbb{Z}/p$-gainable** when at least one such labelling exists. Gainability is the property we want to characterise: which biased graphs can have their entire pattern of balance explained by a single consistent assignment of clock-arithmetic gains?

## Minors: zooming in on substructures

The miracle of this subject — and of much of modern graph theory — is that gainability is controlled by **minors**. Loosely, a minor of a graph is any smaller graph you can find inside it by deleting edges and merging others. The celebrated Robertson–Seymour theory tells us that vast families of graphs are characterised by a *finite* list of forbidden minors. Planar graphs, for instance, are exactly the graphs with no $K_5$ and no $K_{3,3}$ minor.

For biased graphs carrying gains, we use a refined notion: the **labelled minor** (also called a weak map). A biased graph $H$ is a minor of $G$ when there is a way to inject $H$'s edges into $G$'s edges, with each edge optionally *flipped* in orientation, such that every cycle of $H$ maps to a cycle of $G$ and balanced stays matched with balanced. Formally there is an injection $\varphi$ on edges and a switch $\sigma$ (a Boolean per edge) that together carry $H$'s structure faithfully into $G$.

Why is this the *right* notion of minor? Because gains flow through it. If $G$ has a gain labelling and $H$ sits inside $G$ as a labelled minor, you can simply **pull the labelling back**: define $H$'s gain on an edge $e$ to be $g(\varphi(e))$, negated if that edge was flipped. The central computation — call it the *pull-back identity* — says that the signed sum of the pulled-back labelling around any cycle of $H$ equals the signed sum of the original labelling around the image cycle in $G$:

$$\mathrm{signedSum}\big(\text{pullback}(g),\, c\big) \;=\; \mathrm{signedSum}\big(g,\, \varphi(c)\big).$$

This identity is the engine of the whole theory. It is proved by a clean case analysis: each edge is either flipped or not, and traversed forwards or backwards, giving four cases, and in every one the two sides agree because flipping an edge and negating its label are the same operation under a signed sum.

From the pull-back identity, a foundational theorem follows almost immediately.

> **Minor-closedness (Lemma B).** If $G$ is $\mathbb{Z}/p$-gainable and $H$ is a labelled minor of $G$, then $H$ is $\mathbb{Z}/p$-gainable.

The proof is a single line of reasoning: take $G$'s labelling, pull it back to $H$, and the pull-back identity guarantees that balance and zero-signed-sum still coincide on every cycle of $H$. Gainability is inherited downward. This is exactly the property a class needs in order to be describable by forbidden minors — and it sets the stage for the obstruction.

## The first forbidden shape: $(p+1)$ parallel edges

The cleanest obstruction is almost embarrassingly simple to draw: take two vertices and connect them with $p+1$ parallel edges. In the language of graph theory this is $(p+1)K_2$ — the matching $K_2$ inflated $p+1$ times.

What are its cycles? With parallel edges between two vertices, the only loops are **digons**: pick two of the parallel edges, go out along one and come back along the other. In the formal model, a digon is the oriented walk $[(i, \text{forward}), (j, \text{backward})]$ for two distinct edges $i \neq j$. And crucially, we declare **every** digon **unbalanced**. This is the "contrabalanced" bundle: no loop is allowed to cancel.

Now ask whether $(p+1)K_2$ is $\mathbb{Z}/p$-gainable. The signed sum around the digon $[(i,+),(j,-)]$ is $g(i) - g(j)$. For the digon to be unbalanced, this must be **nonzero**:

$$g(i) - g(j) \neq 0 \quad\text{for all } i \neq j, \qquad\text{i.e.}\qquad g(i) \neq g(j).$$

In other words, a valid gain labelling must assign **distinct** values to all $p+1$ edges. But the labels live in $\mathbb{Z}/p$, which has only $p$ elements. You cannot place $p+1$ pigeons into $p$ holes without a collision. The labelling is impossible.

> **The obstruction (Lemma A).** For every prime $p$, the contrabalanced bundle $(p+1)K_2$ is **not** $\mathbb{Z}/p$-gainable.

This is the pigeonhole principle wearing a graph-theoretic disguise, and it is the heart of the matter. The formal proof shows that any realising labelling would be an injective function from a $(p+1)$-element edge set into $\mathbb{Z}/p$, then derives the contradiction from the fact that an injection cannot increase cardinality while $|\mathbb{Z}/p| = p < p+1$.

Combine this with minor-closedness and you get a clean necessary condition that holds for *every* biased graph, no matter how complicated:

> **Necessity, in general.** Any $\mathbb{Z}/p$-gainable biased graph contains **no** $(p+1)K_2$ minor.

The argument is pure transitivity: if a gainable graph $G$ contained a $(p+1)K_2$ minor, then by minor-closedness that bundle would itself be gainable — contradicting the pigeonhole obstruction. So the forbidden shape really is forbidden, universally.

## Closing the loop: a complete characterisation for parallel classes

Necessity is half the prize. The other half — **sufficiency** — asks: if a biased graph avoids the forbidden shape, can we always build a gain labelling? In full generality the answer requires two more forbidden shapes (described below), but for one important family the story closes completely.

A **parallel class** is a biased graph in which all edges run between the same two vertices. Its cycles are exactly the digons, and a digon $[(i,+),(j,-)]$ is balanced precisely when edges $i$ and $j$ belong to the same *balanced class* — that is, when a natural equivalence relation groups them together. The entire bias is then encoded by a single number: how many distinct balanced classes there are. Call it the **parallel-class count**.

For this family, everything lines up perfectly through that one number:

- **Gainability by counting.** A parallel-class biased graph is $\mathbb{Z}/p$-gainable if and only if its number of balanced classes is at most $p$. (Assign one of the $p$ available clock values to each class; distinct classes get distinct values, equal classes get equal values, and the digon balance condition $g(i) = g(j)$ falls out exactly.)
- **The minor, by counting.** It contains a $(p+1)K_2$ minor if and only if its number of balanced classes is at least $p+1$. (Pick one edge from each of $p+1$ distinct classes; their pairwise digons are all unbalanced, reproducing the contrabalanced bundle.)

Putting the two counting statements side by side yields the theorem in its sharpest form:

> **Excluded-minor theorem (parallel-class family).** A parallel-class biased graph is $\mathbb{Z}/p$-gainable **if and only if** it contains no $(p+1)K_2$ minor.

The two conditions are simply the two sides of the same coin — "at most $p$ classes" versus "no $(p+1)$ classes" — and the bridge between them is the humble act of counting. This is a complete, self-contained, vertex-free proof: no heavy machinery, just a pigeonhole, a pull-back, and a careful count.

## The wider picture: three shapes, one theorem

The parallel-class result is one panel of a larger mural. The full conjecture — the concept that motivated this work — says that for every odd prime $p$, the class of all biased graphs that admit a $\mathbb{Z}/p$-gain labelling is closed under minors and has **exactly three** excluded minors:

1. the contrabalanced bundle $(p+1)K_2$ — the pigeonhole obstruction we proved here;
2. the **balanced triangle** $\pm K_3$ — a three-edge loop whose bias cannot be realised; and
3. the **unbalanced four-cycle** $-K_4$ — a more intricate four-vertex obstruction.

The first of these has a transparent, elementary proof, and that is the one made fully rigorous in this work. The other two live in the deeper country of signed graphs, Dowling geometries, and matroid representability over finite fields — the same circle of ideas in which a graph's "frame matroid" is representable over $GF(p)$ precisely when the gains can be found. There, the threshold subtly shifts: gain-realisability of a bundle of $k$ parallel edges has the threshold $k \le p$ (the affine line over $\mathbb{Z}/p$), while representability of the associated rank-2 matroid $U_{2,k}$ over $GF(p)$ has threshold $k \le p+1$ (the projective line). That gap of exactly one is a clue to how balance and linear algebra are secretly the same subject.

## Why this matters beyond the page

The temptation is to see this as a curiosity about little graphs. But "gains around cycles" is one of the most pervasive patterns in applied mathematics, and the question "is my prescribed pattern of consistencies and inconsistencies *realisable*?" appears everywhere.

In **electrical networks**, gains are voltage or impedance shifts, and a balanced loop is Kirchhoff's law satisfied. In **social network theory**, the famous *structural balance* of Heider and Cartwright–Harary asks exactly when a web of friendships ($+$) and antagonisms ($-$) can be consistently split into camps; that is the $p = 2$ case of this very framework, with $\mathbb{Z}/2$ gains. In **physics**, gauge theories assign group-valued phases to paths and ask when the holonomy around loops is trivial — gainability over a group is the discrete shadow of a flat connection. In **scheduling and constraint satisfaction**, the gains are offsets and the balanced cycles are the consistency requirements; unrealisability is an impossible specification.

In all of these, the message of the excluded-minor theorem is the same and it is liberating: you do not have to search through astronomically many possible labellings to know whether a consistent one exists. You only have to look for a handful of small forbidden patterns. Find one, and you have a *certificate of impossibility* — a concrete, human-checkable reason why no labelling can work. Avoid them all, and a labelling is guaranteed.

That is the quiet power of forbidden-minor theorems: they convert an infinite search into a finite checklist. Here, for clock arithmetic with $p$ hours, the checklist begins with the simplest impossible thing imaginable — $p+1$ roads between two towns, every round trip forced to come back changed, in a world where there are only $p$ ways to change. The pigeonhole does the rest.
