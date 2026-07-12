# Three Faces of the Same Number: Trees, Binary Trees, and Mountain Ranges

## A number that keeps showing up

Start counting simple combinatorial objects and, sooner or later, you bump into the same sequence over and over again:

$$1,\ 1,\ 2,\ 5,\ 14,\ 42,\ 132,\ 429,\ \dots$$

In how many ways can you fully parenthesize a product of $n+1$ factors? How many ways can a convex polygon with $n+2$ sides be cut into triangles by non-crossing diagonals? How many little mountain ranges can you draw with $n$ up-strokes and $n$ down-strokes that never dip below the ground? Every one of these questions has the same answer, given by the **Catalan numbers**

$$C_n = \frac{1}{n+1}\binom{2n}{n}.$$

This article is about *why* three seemingly unrelated families of objects — **plane trees**, **binary trees**, and **lattice paths** — are secretly the same, and about a clean, fully rigorous way to prove it: not by comparing formulas, but by building an explicit dictionary that translates each object into another and back again, losing nothing along the way.

## The three families

**Plane trees.** Imagine a family tree drawn on paper. There is a single root at the top, and every node has some number of children arranged *in a definite left-to-right order*. A node can have no children, one child, or seventeen children — any number at all. Because the order of the children matters, swapping the left and right subtrees of a node generally gives a *different* plane tree. These are also called *ordered* or *planar* rooted trees, because you can think of them as drawn in the plane with the left-right order fixed.

Formally, a plane tree is nothing more than a root together with an *ordered list* of subtrees, each of which is again a plane tree. A **plane forest** is just a list of plane trees standing side by side. If we let $n$ denote the total number of nodes, we can ask: how many plane trees have exactly $n+1$ nodes? How many plane forests have exactly $n$ nodes?

**Binary trees.** Now restrict the shape. A binary tree is either empty, or it is an internal node with exactly *two* children, a left subtree and a right subtree, each of which is again a binary tree. This is the workhorse data structure of computer science, and its rigid two-children-per-node discipline makes it far easier to reason about recursively than the free-for-all of plane trees.

**Dyck paths.** Finally, leave trees behind entirely and draw a walk. Start at the origin and take $2n$ unit steps, each either an up-step $(+1)$ or a down-step $(-1)$, ending back on the axis, and — crucially — *never stepping below the axis*. The result looks like a mountain range that starts and ends at sea level and never goes underwater. Such a walk is called a **Dyck path**, and the number $n$ of up-steps (equivalently, the number of down-steps) is its **semilength**. Encode up as an opening bracket and down as a closing bracket, and a Dyck path becomes exactly a string of correctly balanced parentheses.

At first glance these three families could hardly look more different. One is about branching genealogies of unbounded width; one is about a strict two-way data structure; one is about a bracketed walk that stays above the water. And yet:

> **The main theorem.** For every $n$, the number of plane trees with $n+1$ nodes, the number of binary trees with $n$ internal nodes, and the number of Dyck paths of semilength $n$ are all *equal* — and all equal to the Catalan number $C_n$.

Counting formulas alone would already suggest this. What makes the story satisfying is that we can exhibit *explicit, reversible translations* between the families. Each translation is a **bijection**: a perfect one-to-one pairing that leaves no object unmatched on either side. Bijections are the gold standard of combinatorial proof, because they explain *why* two counts agree rather than merely confirming *that* they do.

## The key idea: turn a wide tree into a lean one

The heart of the matter is a single beautiful trick, often attributed to Knuth and known as the **left-child / right-sibling** encoding. It converts an arbitrary plane forest — with nodes of any width whatsoever — into a binary tree, where every node has a rigid two children. The trick is to *reinterpret* the two links of a binary node:

- the **left** child of a binary node no longer means "first subordinate"; instead it points to the *first child* of the current node in the plane tree;
- the **right** child no longer means "second subordinate"; instead it points to the *next sibling* of the current node.

In words: **"left = my first child, right = my next sibling."** Every node in a plane tree has a well-defined first child (or none) and a well-defined next sibling (or none), so this recipe assigns to each node exactly two binary links, exactly as a binary tree demands. Read a whole plane forest this way and you get a binary tree; the entire wide, ragged structure has been threaded onto a lean two-way skeleton.

Concretely, the encoding processes a forest recursively. Take the first tree in the forest. Its own children form a smaller forest, and *that* becomes the left subtree of the binary root. Everything after the first tree — the rest of the forest — becomes the right subtree. Apply the same rule inside each piece. An empty forest becomes the empty binary tree. That is the whole algorithm.

$$\text{forest} \;=\; (\text{first tree's children}) \;\text{as left}, \quad (\text{remaining forest}) \;\text{as right}.$$

The decoding runs in reverse. Given a binary tree, its left subtree decodes to the children of the first plane tree, and its right subtree decodes to the rest of the forest. Because the two procedures are exact inverses of one another — encode then decode returns the original forest, and decode then encode returns the original binary tree — the correspondence is a genuine bijection. Nothing is approximate and nothing is lost.

There is a bonus, and it is exactly what makes the counting come out right. **The transform preserves size.** A plane forest with $n$ nodes maps to a binary tree with $n$ internal nodes, and vice versa. Each node of the forest becomes exactly one internal node of the binary tree. So the bijection respects the natural notion of "how big" an object is, which lets us match up the families count-by-count, size class by size class.

## Climbing across the bridge

Once plane forests and binary trees are perfectly paired, a short chain of observations connects everything:

1. **Plane trees are just forests in disguise.** A single plane tree is nothing but its root plus its ordered list of children — and that list of children *is* a plane forest. Stripping the root off a plane tree with $n+1$ nodes leaves a forest with $n$ nodes; adding a root back reverses this. So plane trees with $n+1$ nodes correspond exactly to plane forests with $n$ nodes.

2. **Binary trees are already counted.** It is a classical fact that binary trees with $n$ internal nodes number exactly $C_n$, the $n$-th Catalan number.

3. **Binary trees match Dyck paths.** Reading a binary tree in the right traversal order produces a balanced bracket string — a Dyck path — and this too is a size-preserving bijection: binary trees with $n$ internal nodes correspond to Dyck paths of semilength $n$.

Assemble the chain and the destinations line up:

$$
\underbrace{\{\text{plane trees, } n+1 \text{ nodes}\}}_{\text{tree combinatorics}}
\;\longleftrightarrow\;
\underbrace{\{\text{plane forests, } n \text{ nodes}\}}_{}
\;\longleftrightarrow\;
\underbrace{\{\text{binary trees, } n \text{ internal nodes}\}}_{\text{data structures}}
\;\longleftrightarrow\;
\underbrace{\{\text{Dyck paths, semilength } n\}}_{\text{lattice paths}}.
$$

Composing the arrows gives the headline correspondence directly:

> **Plane trees with $n+1$ nodes are in explicit bijection with Dyck paths of semilength $n$.**

And because bijections preserve counts, every family in the chain has the same cardinality, the Catalan number $C_n$. We did not need to compute a single binomial coefficient to know the three counts agree; the dictionary itself is the proof.

## Why go to the trouble of a bijection?

You might reasonably ask: if we already have the formula $C_n = \frac{1}{n+1}\binom{2n}{n}$, why bother building explicit maps? Three reasons.

First, **understanding**. A formula tells you the total; a bijection tells you *the reason*. It reveals that a wide, branching plane tree and a bracketed mountain range are two encodings of one underlying combinatorial atom. The Knuth transform is the concrete mechanism that turns "unbounded arity" into "rigid binary" without losing information — a genuinely surprising structural fact.

Second, **computation and data structures**. The left-child / right-sibling encoding is not a mathematical curiosity; it is how real programs store trees of arbitrary width using only two pointers per node. Every node needs to remember just "my first child" and "my next sibling." The theorem above is the mathematical guarantee that this ubiquitous representation is *faithful*: no tree of arbitrary shape is ever confused with another, and every binary skeleton corresponds to a genuine tree.

Third, **a foundation to build on**. This three-way bridge is the ground floor of a much taller building. The original motivation comes from a deep question in modern combinatorics about the **Tamari lattice** — a subtle partial order on bracketings and trees — and its "greedy" intervals inside so-called planar constellations. A far-reaching conjecture predicts that certain intervals in these structures are counted by families of labeled planar trees, with the correspondence flowing, in every case, *through Dyck paths*. The plane-tree ↔ Dyck-path bijection established here is precisely the base layer ($m = 1$) of that program: the shared lattice-path substrate on which the richer, higher correspondences must be built.

## The road ahead

The natural next step is to widen every object by a parameter $m$. Instead of ordinary trees, one considers $(m+1)$-ary plane trees; instead of Dyck paths with up-steps $+1$ and down-steps $-1$, one considers **$m$-Dyck paths** whose down-steps drop by $m$ and which still never go underwater. These are counted not by Catalan numbers but by the **Fuss–Catalan numbers**

$$\frac{1}{mn+1}\binom{(m+1)n}{n},$$

and the Knuth transform generalizes to an $(m+1)$-fold "first-return" decomposition that should establish the corresponding bijection. Beyond that lies the order-theoretic heart of the story: formalizing the Tamari order itself through its rotation moves, isolating the *greedy* (synchronized) intervals, and finally matching their maximal elements with labeled planar trees. Each rung of that ladder rests on the same idea proved here — that trees of arbitrary width, rigid binary skeletons, and balanced mountain ranges are, at bottom, three faces of a single combinatorial coin.

The Catalan numbers have been called the most ubiquitous sequence in all of combinatorics, appearing in hundreds of guises. What this story shows is that their ubiquity is not a coincidence to be catalogued but a unity to be understood: build the right dictionary, and the many faces resolve into one.
