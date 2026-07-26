# When One Group Remembers an Entire Shape

## The cartographer’s impossible question

Imagine being handed two labyrinths in total darkness. You may walk along corridors, return to your starting point, and record how journeys can be deformed into one another without tearing through walls. Could that information tell you whether the two labyrinths have the same underlying shape?

Topology asks this question in a precise way. Its objects may be loops of wire, curved surfaces, configuration spaces of robots, or enormous state spaces arising in physics and data analysis. Rather than measuring lengths and angles, topology studies what survives continuous deformation. A coffee cup and a ring-shaped doughnut are equivalent in this sense: each has one essential tunnel. A sphere is different because every loop on it can shrink to a point.

The **fundamental group** packages this loop information. Choose a basepoint $x$ in a space $X$. Consider all loops that start and end at $x$, identifying two loops when one can be continuously deformed into the other while its endpoints remain fixed. Concatenating loops gives a multiplication, the constant loop gives an identity, and traversing a loop backward gives an inverse. The resulting group is denoted $\pi_1(X,x)$.

This group is an invariant: if two spaces are homotopy equivalent, their fundamental groups are isomorphic. But is it a complete invariant? In other words, if two spaces have isomorphic fundamental groups, must they have the same homotopy type?

The answer is both beautifully positive and decisively negative. It is positive for spaces whose entire homotopy theory lives in dimension one, the spaces called $K(G,1)$ spaces. It is negative for arbitrary spaces—even for the simplest finite discrete spaces. The dividing line reveals exactly what a fundamental group remembers and exactly what it forgets.

## From loops to a network of journeys

A single basepoint can hide important information. The more comprehensive object is the **fundamental groupoid**. Its objects are all points of $X$. A morphism from $x$ to $y$ is a path from $x$ to $y$, considered up to deformation with endpoints fixed. Paths compose by concatenation, and every path has an inverse obtained by reversal. An algebraic system with many objects, composable arrows, and an inverse for every arrow is called a **groupoid**.

At any object $x$ of a groupoid, the arrows from $x$ back to itself form the **vertex group** $\Gamma_x$. For the fundamental groupoid, this vertex group is precisely $\pi_1(X,x)$.

A groupoid is **connected at $x$** if every object $y$ is isomorphic to $x$—that is, there is at least one reversible arrow from $x$ to $y$. In a fundamental groupoid, this says exactly that every point can be joined to $x$ by a path. Thus categorical connectedness is the algebraic shadow of path-connectedness.

Now comes the central compression principle.

**Connected Groupoid Classification Theorem.** *Let $\mathcal{G}$ be a connected groupoid and choose an object $x$. Then $\mathcal{G}$ is equivalent to the one-object groupoid whose arrows are the elements of the vertex group $\Gamma_x$.*

A one-object groupoid is simply a group viewed as a tiny category: it has one object, one arrow for every group element, and composition is group multiplication. The theorem says that a connected web of objects and reversible arrows contains no more essential information than the symmetries at one chosen vertex.

Why? Build a map from the one-object groupoid $\mathbf{B}\Gamma_x$ into $\mathcal{G}$. Send its unique object to $x$ and each group element to the corresponding loop at $x$. This map has three decisive properties.

First, it is **faithful**: distinct loops at $x$ remain distinct arrows. Second, it is **full**: every arrow from $x$ to itself already belongs to $\Gamma_x$. Third, it is **essentially surjective**: connectedness guarantees that every object of $\mathcal{G}$ is isomorphic to $x$. A full, faithful, and essentially surjective functor is an equivalence. The whole network therefore collapses, without loss of structure, onto one vertex and its loop group.

This is more than a clever simplification. It is a classification theorem.

## The exact realm where the group is complete

A **connected homotopy $1$-type** is a connected space or abstract homotopy type with no nontrivial homotopy information above dimension one. Equivalently, all homotopy groups $\pi_n$ vanish for $n \ge 2$. A connected space of this kind with fundamental group $G$ is called an **Eilenberg–MacLane space of type $K(G,1)$**.

The circle is a $K(\mathbb{Z},1)$. More generally, graphs are homotopy $1$-types; their fundamental groups are free groups. Many configuration spaces and classifying spaces also arise naturally as $K(G,1)$ spaces.

The groupoid theorem yields the promised positive result.

**Complete-Invariant Theorem for Connected Homotopy $1$-Types.** *Two connected homotopy $1$-types are equivalent if and only if their fundamental groups at chosen basepoints are isomorphic. In particular, $K(G,1)$ spaces are classified up to homotopy by the isomorphism class of $G$.*

For the forward direction, an equivalence carries loops to loops, respects concatenation and reversal, and induces a bijection between loop classes. Hence it produces an isomorphism of vertex groups.

For the reverse direction, replace each connected groupoid by the one-object groupoid of its chosen vertex group. If the two vertex groups are isomorphic, their one-object groupoids are equivalent. Composing the three equivalences gives an equivalence between the original groupoids:

$$
\mathcal{G} \simeq \mathbf{B}(\Gamma_x) \simeq \mathbf{B}(\Gamma_y) \simeq \mathcal{H}.
$$

Here $\mathbf{B}(G)$ denotes the one-object groupoid associated with a group $G$. In a homotopy $1$-type, the fundamental groupoid contains all available homotopy information, so the groupoid equivalence is the desired classification.

The result is striking because it turns geometry into algebra. Once higher-dimensional homotopy has disappeared and connectedness has merged all points into one path component, every remaining feature can be transported to a single basepoint. The multiplication table of its loops is enough.

## Why homotopy equivalence always preserves the group

Before seeing failure, it helps to isolate what never fails.

**Fundamental-Group Invariance Theorem.** *If $X$ and $Y$ are homotopy equivalent and $x \in X$, then $\pi_1(X,x)$ is isomorphic to $\pi_1(Y,f(x))$, where $f:X \to Y$ is either map in a chosen homotopy equivalence.*

A homotopy equivalence consists of continuous maps $f:X \to Y$ and $g:Y \to X$ such that $g \circ f$ is homotopic to the identity on $X$ and $f \circ g$ is homotopic to the identity on $Y$. Applying $f$ to every loop gives a homomorphism on fundamental groups; applying $g$ gives its inverse, after accounting for the given homotopies.

This theorem says the fundamental group is always a reliable obstruction. If the groups differ, the spaces cannot be homotopy equivalent. Completeness asks for the converse, and that is where missing information matters.

## The smallest counterexample

The failure already appears before higher-dimensional spheres enter the story. Compare a one-point space, denoted $\{*\}$, with the discrete two-point space $D=\{0,1\}$.

At any chosen point, both fundamental groups are trivial. A path is the continuous image of the connected interval $[0,1]$. In a discrete space, any connected subset contains only one point, so every path is constant. Consequently every based loop is constant and

$$
\pi_1(\{*\},*) \cong 1 \cong \pi_1(D,0).
$$

Nevertheless, $\{*\}$ and $D$ are not homotopy equivalent. To see this cleanly, use the notion of a **totally disconnected space**, one in which every connected component is a singleton. Discrete spaces are totally disconnected.

**Rigidity Lemma.** *If $Y$ is totally disconnected and two continuous maps $f,g:X \to Y$ are homotopic, then $f=g$.*

Indeed, fix $x \in X$. During a homotopy, the point $x$ traces a continuous path in $Y$ from $f(x)$ to $g(x)$. Its image is connected and therefore must be a singleton. Thus $f(x)=g(x)$ for every $x$.

A useful consequence follows immediately.

**Discrete Rigidity Theorem.** *A homotopy equivalence between totally disconnected spaces is a bijection of their underlying point sets.*

If $f$ and $g$ are homotopy inverses, the rigidity lemma upgrades the relations $g \circ f \simeq \operatorname{id}_X$ and $f \circ g \simeq \operatorname{id}_Y$ from homotopies to literal equalities. Therefore $f$ and $g$ are inverse functions. Since no bijection exists between a one-element set and a two-element set, the two spaces cannot be homotopy equivalent.

We have therefore proved the boundary result:

**Counterexample Theorem.** *There exist spaces with isomorphic based fundamental groups that are not homotopy equivalent. Specifically, a point and a discrete two-point space both have trivial fundamental group at every basepoint, but they are not homotopy equivalent.*

What did the based group forget? It forgot the other path component. Choosing one point in the two-point space sees only that isolated component. The full fundamental groupoid would retain both objects and therefore distinguish the spaces immediately.

## A hierarchy of memory

Topology offers a ladder of increasingly rich records.

A based fundamental group remembers loops around one point. The fundamental groupoid remembers paths among all points and therefore records path components as well as the fundamental group in each component. For arbitrary homotopy $1$-types, that groupoid is the right complete invariant.

But even the fundamental groupoid cannot see genuinely higher-dimensional phenomena. A point and a simply connected sphere have trivial fundamental groups and connected fundamental groupoids of the same basic form, yet a sphere has a nontrivial higher homotopy group. The second homotopy group of the $2$-sphere, for example, is $\mathbb{Z}$, while every positive-dimensional homotopy group of a point is trivial.

Thus the slogan “the fundamental group determines the space” needs two hypotheses: connectedness, so one basepoint does not miss other components, and $1$-truncation, so no higher-dimensional information lies beyond loops.

## Why this bridge matters

The classification is useful whenever a geometric problem naturally produces a $K(G,1)$. Instead of comparing spaces directly, one may compute groups and ask whether they are isomorphic. In robotics, collision-free configuration spaces often encode motions as paths and repeated maneuvers as loops. In geometric group theory, spaces provide geometry for groups, while groups compress the essential topology of suitable spaces. In dynamical systems and networked state spaces, groupoids keep track of movement between states, and connectedness lets one select a convenient reference state without losing information.

There is also an algorithmic lesson. For a finite connected groupoid, choose a base object, collect all of its self-arrows, and compute their composition table. The original many-object structure is then equivalent to the one-object groupoid encoded by that table. To compare two connected finite groupoids, it is enough to test their vertex groups for isomorphism. The compression can be dramatic: a large network of redundant viewpoints becomes one algebraic object.

Yet the counterexample counsels humility. Invariants are instruments, not oracles. A coarse invariant may prove that two spaces differ, but agreement may merely mean that the instrument is blind to the relevant feature. The art is to know the invariant’s range.

For connected homotopy $1$-types, the range is exact: the fundamental group is a complete fingerprint. Outside that range, the fingerprint can match while the spaces differ—first by disconnectedness, then by higher-dimensional holes. The deepest achievement is therefore not merely a classification, but a map of its frontier: one group remembers an entire shape precisely when there is nothing beyond paths and loops for it to forget.
