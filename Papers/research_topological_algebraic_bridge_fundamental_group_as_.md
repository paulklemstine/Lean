# Fundamental Groups as Complete Invariants of Connected Homotopy One-Types

**Aristotle**  
**July 26, 2026**

## Abstract

The fundamental group is among topology’s most effective invariants, but its exact classificatory scope requires care. This paper identifies that scope through the algebra of groupoids. We prove that every connected groupoid is equivalent to the one-object groupoid determined by the automorphism group of any chosen object. Consequently, two connected groupoids are equivalent if and only if their vertex groups are isomorphic. Interpreting groupoids as models of homotopy $1$-types yields the classification of connected homotopy $1$-types, and hence Eilenberg–MacLane spaces $K(G,1)$, by their fundamental groups. We also establish the invariant direction for arbitrary spaces: homotopy equivalence induces an isomorphism of fundamental groups. Completeness, however, fails without the connected $1$-type hypotheses. We prove that homotopic maps into a totally disconnected space are equal, deduce that a homotopy equivalence between totally disconnected spaces is a bijection, and use this rigidity to distinguish a point from a discrete two-point space despite their isomorphic trivial based fundamental groups. The results isolate two independent sources of information omitted by a based fundamental group: additional path components and higher homotopy.

## 1. Introduction

A topological invariant converts a geometric object into data that remain unchanged under an accepted notion of equivalence. The fundamental group converts a pointed space into a group of loop classes. It is strong enough to detect the hole in a circle and to distinguish many surfaces, knot complements, graphs, and configuration spaces. Yet an invariant and a complete invariant are different things. Invariance says

$$
X \simeq Y \quad\Longrightarrow\quad \pi_1(X,x)\cong\pi_1(Y,f(x)),
$$

whereas completeness would require an appropriate converse.

No unrestricted converse is possible. A based group examines loops in one path component and cannot count other components. Even within a connected space, it sees only one-dimensional homotopy and cannot generally recover higher homotopy groups. The natural question is therefore not whether the fundamental group always classifies spaces, but under exactly which hypotheses it does.

The answer is clean. A connected homotopy $1$-type has no homotopy information above paths, homotopies between paths, and their composition. Its algebraic model is a connected groupoid. Every connected groupoid can be compressed to one object, with the arrows at that object forming a group. Thus the vertex group is a complete invariant. For a connected topological $1$-type, that vertex group is the fundamental group.

This paper develops that argument from first principles. Section $2$ fixes the required categorical and topological definitions. Section $3$ constructs the one-vertex reduction and proves it is an equivalence. Section $4$ derives the complete classification and its converse. Section $5$ explains the $K(G,1)$ interpretation. Section $6$ proves preservation of fundamental groups under arbitrary homotopy equivalence. Section $7$ develops rigidity for totally disconnected targets, leading to an explicit counterexample in Section $8$. Sections $9$–$11$ discuss algorithms, applications, the boundary of the result, and future directions.

## 2. Definitions and preliminaries

### 2.1 Categories, groupoids, and equivalence

A **category** $\mathcal{C}$ consists of objects, sets of morphisms $\operatorname{Hom}_{\mathcal C}(a,b)$, identity morphisms, and associative composition. A **groupoid** is a category in which every morphism is invertible.

For an object $c$ of a groupoid $\mathcal C$, its **vertex group** or **automorphism group** is

$$
\operatorname{Aut}_{\mathcal C}(c)=\operatorname{Hom}_{\mathcal C}(c,c),
$$

with multiplication given by composition. Invertibility of every groupoid arrow makes this a group.

Given a group $G$, its **one-object groupoid** $\mathbf{B}G$ has one object $*$, morphism set

$$
\operatorname{Hom}_{\mathbf{B}G}(*,*)=G,
$$

and composition equal to multiplication in $G$.

A functor $F:\mathcal C\to\mathcal D$ is **faithful** if each induced map on morphism sets is injective, **full** if each induced map is surjective, and **essentially surjective** if every object of $\mathcal D$ is isomorphic to some $F(c)$. A standard characterization says that $F$ is an equivalence of categories precisely when it is full, faithful, and essentially surjective.

A groupoid $\mathcal C$ is **connected at $c$** if, for every object $d$, there exists an isomorphism $c\cong d$. Since all groupoid arrows are isomorphisms, this means that at least one arrow connects $c$ to each $d$. A groupoid is **connected** if it is connected at one, hence every, object.

### 2.2 Fundamental groupoids and fundamental groups

Let $X$ be a topological space. Its **fundamental groupoid** $\Pi_1(X)$ has the points of $X$ as objects. A morphism $x\to y$ is a continuous path $p:[0,1]\to X$ with $p(0)=x$ and $p(1)=y$, modulo homotopy relative to the endpoints. Concatenation of paths defines composition. Reversal defines inverses, so $\Pi_1(X)$ is a groupoid.

The vertex group at $x$ is the **fundamental group**:

$$
\operatorname{Aut}_{\Pi_1(X)}(x)=\pi_1(X,x).
$$

The fundamental groupoid is connected exactly when $X$ is path-connected.

A **homotopy equivalence** between spaces $X$ and $Y$ consists of continuous maps $f:X\to Y$ and $g:Y\to X$ and homotopies

$$
g\circ f\simeq \operatorname{id}_X,
\qquad
f\circ g\simeq \operatorname{id}_Y.
$$

A **homotopy $1$-type** is a homotopy type with no nontrivial homotopy groups above degree $1$. A connected space $X$ is an **Eilenberg–MacLane space of type $K(G,1)$** if

$$
\pi_1(X,x)\cong G
\quad\text{and}\quad
\pi_n(X,x)=0\ \text{for every }n\ge 2.
$$

The groupoid captures all information in a homotopy $1$-type: objects record points, arrows record paths up to endpoint-preserving homotopy, and there are no higher homotopy layers left to record.

## 3. Reduction of a connected groupoid to one vertex

Fix a groupoid $\mathcal C$ and an object $c$. Define the **vertex functor**

$$
V_c:\mathbf{B}\operatorname{Aut}_{\mathcal C}(c)\longrightarrow\mathcal C
$$

by sending the unique object of the source to $c$ and sending each element of $\operatorname{Aut}_{\mathcal C}(c)$ to the same arrow viewed in $\mathcal C$.

The classification rests on three elementary lemmas.

**Lemma 3.1 (Faithfulness of the vertex functor).** *The vertex functor $V_c$ is faithful.*

**Proof sketch.** The source has only one morphism set, namely $\operatorname{Aut}_{\mathcal C}(c)$. On that set, $V_c$ is the identity inclusion into $\operatorname{Hom}_{\mathcal C}(c,c)$, which is the same set. Therefore equality of images implies equality of the original automorphisms. $\square$

**Lemma 3.2 (Fullness of the vertex functor).** *The vertex functor $V_c$ is full.*

**Proof sketch.** Every morphism between the images of the source object is an endomorphism $h:c\to c$. Because $\mathcal C$ is a groupoid, $h$ is invertible and therefore belongs to $\operatorname{Aut}_{\mathcal C}(c)$. It is consequently the image of an arrow of $\mathbf{B}\operatorname{Aut}_{\mathcal C}(c)$. $\square$

**Lemma 3.3 (Essential surjectivity from connectedness).** *If $\mathcal C$ is connected at $c$, then $V_c$ is essentially surjective.*

**Proof sketch.** For every object $d$ of $\mathcal C$, connectedness supplies an isomorphism $c\cong d$. Since $c$ is the image of the unique source object, $d$ is isomorphic to an object in the image of $V_c$. $\square$

Combining these properties gives the central structural theorem.

**Theorem 3.4 (Connected Groupoid Classification).** *Let $\mathcal C$ be a groupoid connected at an object $c$. Then there is an equivalence*

$$
\mathcal C\simeq\mathbf{B}\operatorname{Aut}_{\mathcal C}(c).
$$

**Proof sketch.** Lemmas $3.1$, $3.2$, and $3.3$ show that $V_c$ is faithful, full, and essentially surjective. Hence $V_c$ is an equivalence. Reversing its direction if desired produces the displayed equivalence. $\square$

This theorem expresses a choice of gauge. To describe any arrow $a\to b$, choose transport arrows $u_a:c\to a$ and $u_b:c\to b$. Then every arrow $h:a\to b$ corresponds to the loop

$$
u_b^{-1}\circ h\circ u_a:c\to c.
$$

Conversely, a loop $k:c\to c$ determines

$$
u_b\circ k\circ u_a^{-1}:a\to b.
$$

Different transport choices change coordinates but not the equivalence class. All many-object information is reconstructed from one vertex group plus noncanonical choices that carry no invariant content in the connected case.

## 4. Classification by the vertex group

We now compare two connected groupoids.

**Theorem 4.1 (Completeness of the vertex group).** *Let $\mathcal C$ and $\mathcal D$ be groupoids connected at $c$ and $d$, respectively. If there is a group isomorphism*

$$
\varphi:\operatorname{Aut}_{\mathcal C}(c)\xrightarrow{\cong}
\operatorname{Aut}_{\mathcal D}(d),
$$

*then $\mathcal C$ and $\mathcal D$ are equivalent groupoids.*

**Proof sketch.** By Theorem $3.4$,

$$
\mathcal C\simeq\mathbf{B}\operatorname{Aut}_{\mathcal C}(c),
\qquad
\mathcal D\simeq\mathbf{B}\operatorname{Aut}_{\mathcal D}(d).
$$

The isomorphism $\varphi$ defines a functor between the one-object groupoids. It is faithful because $\varphi$ is injective, full because $\varphi$ is surjective, and essentially surjective because both groupoids have one object. Thus it is an equivalence. Composing equivalences yields

$$
\mathcal C
\simeq \mathbf{B}\operatorname{Aut}_{\mathcal C}(c)
\simeq \mathbf{B}\operatorname{Aut}_{\mathcal D}(d)
\simeq \mathcal D.
$$

$\square$

Completeness has a converse that does not require connectedness.

**Theorem 4.2 (Equivalence preserves vertex groups).** *Let $E:\mathcal C\simeq\mathcal D$ be an equivalence of groupoids. For every object $c$ of $\mathcal C$, there is a group isomorphism*

$$
\operatorname{Aut}_{\mathcal C}(c)
\cong
\operatorname{Aut}_{\mathcal D}(E(c)).
$$

**Proof sketch.** An equivalence is full and faithful, so its map

$$
\operatorname{Hom}_{\mathcal C}(c,c)
\longrightarrow
\operatorname{Hom}_{\mathcal D}(E(c),E(c))
$$

is bijective. Functoriality preserves identity arrows and composition. Because all endomorphisms in a groupoid are invertible, these endomorphism monoids are precisely the corresponding automorphism groups. The bijective homomorphism is therefore a group isomorphism. $\square$

Together, Theorems $4.1$ and $4.2$ give a biconditional.

**Corollary 4.3.** *Two connected pointed groupoids are equivalent, carrying one chosen vertex to the other up to isomorphism, if and only if their vertex groups are isomorphic.*

Connectedness is crucial. For a disconnected groupoid, one vertex group describes only one connected component. A complete invariant must retain the collection of components and the group attached to each, or equivalently retain the entire groupoid.

## 5. Connected homotopy one-types and $K(G,1)$ spaces

The categorical classification translates directly into homotopy theory.

**Theorem 5.1 (Complete-Invariant Theorem for Connected Homotopy $1$-Types).** *Let $X$ and $Y$ be connected homotopy $1$-types with basepoints $x$ and $y$. Then $X$ and $Y$ have equivalent homotopy types if and only if*

$$
\pi_1(X,x)\cong\pi_1(Y,y).
$$

**Proof sketch.** The fundamental groupoids $\Pi_1(X)$ and $\Pi_1(Y)$ are connected, and their vertex groups at $x$ and $y$ are the displayed fundamental groups. If those groups are isomorphic, Theorem $4.1$ gives an equivalence of fundamental groupoids. Since $X$ and $Y$ are $1$-types, the fundamental groupoid records all their homotopy information, so this groupoid equivalence determines an equivalence of homotopy types. Conversely, an equivalence of homotopy types induces an equivalence of fundamental groupoids, and Theorem $4.2$ identifies the vertex groups. $\square$

**Corollary 5.2 (Classification of Eilenberg–MacLane $1$-types).** *If $X$ is a $K(G,1)$ and $Y$ is a $K(H,1)$, then $X$ and $Y$ are homotopy equivalent if and only if $G\cong H$.*

**Proof sketch.** By definition, both spaces are connected homotopy $1$-types with fundamental groups $G$ and $H$. Apply Theorem $5.1$. $\square$

The statement concerns homotopy type, not homeomorphism. Distinct geometric models can realize the same $K(G,1)$ while differing in dimension, cell structure, smoothness, or metric. The theorem says that after all contractible geometric decoration is discarded, their remaining homotopy information is exactly $G$.

Examples include the circle $S^1$, which is a $K(\mathbb Z,1)$, and connected graphs, which are $K(F_r,1)$ spaces for free groups $F_r$ determined by graph rank. The classification predicts, for example, that two connected graphs are homotopy equivalent precisely when their free fundamental groups have equal rank.

## 6. The invariant direction for arbitrary spaces

The fundamental group remains an invariant even when it ceases to be complete.

**Theorem 6.1 (Homotopy invariance of the fundamental group).** *Let $f:X\to Y$ be part of a homotopy equivalence, with homotopy inverse $g:Y\to X$. For every $x\in X$, there is a group isomorphism*

$$
\pi_1(X,x)\cong\pi_1(Y,f(x)).
$$

**Proof sketch.** Applying $f$ to paths defines a functor $\Pi_1(f):\Pi_1(X)\to\Pi_1(Y)$. Applying $g$ defines a functor in the reverse direction. The homotopies $g\circ f\simeq\operatorname{id}_X$ and $f\circ g\simeq\operatorname{id}_Y$ provide natural isomorphisms showing that these functors are quasi-inverse equivalences. Theorem $4.2$ then gives an isomorphism between the automorphism groups at $x$ and $f(x)$, which are the stated fundamental groups. $\square$

Thus nonisomorphic fundamental groups obstruct homotopy equivalence for arbitrary spaces. The converse requires additional hypotheses, as the next sections demonstrate.

## 7. Rigidity of totally disconnected targets

A topological space $Y$ is **totally disconnected** if every connected component is a singleton. Equivalently for the argument below, every continuous image in $Y$ of the connected interval $[0,1]$ is a single point. Every discrete space is totally disconnected.

**Lemma 7.1 (Homotopy rigidity).** *Let $Y$ be totally disconnected. If continuous maps $f,g:X\to Y$ are homotopic, then $f=g$.*

**Proof.** Let $H:[0,1]\times X\to Y$ be a homotopy from $f$ to $g$. Fix $x\in X$. The map

$$
H_x:[0,1]\to Y,
\qquad
H_x(t)=H(t,x),
$$

is continuous. Since $[0,1]$ is connected, its image $H_x([0,1])$ is connected. Total disconnectedness forces this image to contain a single point. Hence

$$
f(x)=H(0,x)=H(1,x)=g(x).
$$

As this holds for every $x$, the maps are equal. $\square$

**Theorem 7.2 (Homotopy equivalences of totally disconnected spaces are bijections).** *If $X$ and $Y$ are totally disconnected and $f:X\to Y$ is a homotopy equivalence, then the underlying function $f$ is bijective.*

**Proof.** Let $g:Y\to X$ be a homotopy inverse. By definition,

$$
g\circ f\simeq\operatorname{id}_X,
\qquad
f\circ g\simeq\operatorname{id}_Y.
$$

Applying Lemma $7.1$ first with target $X$ and then with target $Y$ upgrades these homotopies to equalities:

$$
g\circ f=\operatorname{id}_X,
\qquad
f\circ g=\operatorname{id}_Y.
$$

Therefore $g$ is a two-sided inverse of $f$, and $f$ is bijective. $\square$

For discrete spaces, homotopy equivalence is therefore no weaker than ordinary bijection. This makes finite discrete spaces ideal for exposing the loss of component data caused by selecting one basepoint.

## 8. A minimal counterexample to unrestricted completeness

Let $P=\{*\}$ be the one-point space and let $D=\{0,1\}$ carry the discrete topology. Choose basepoints $*$ and $0$.

**Lemma 8.1.** *The fundamental group $\pi_1(P,*)$ is trivial.*

**Proof sketch.** There is only one map from any interval to $P$, so there is only one based loop and hence only one loop-homotopy class. $\square$

**Lemma 8.2.** *For either basepoint $b\in D$, the fundamental group $\pi_1(D,b)$ is trivial.*

**Proof sketch.** The image of a path $p:[0,1]\to D$ is connected. Since $D$ is discrete, and therefore totally disconnected, the image is a singleton. A loop based at $b$ must consequently be the constant loop at $b$. Thus there is one loop class. $\square$

It follows that

$$
\pi_1(P,*)\cong 1\cong\pi_1(D,0).
$$

Nevertheless, the spaces are not homotopy equivalent.

**Theorem 8.3 (Failure of classification by a based fundamental group).** *The one-point space and the discrete two-point space have isomorphic fundamental groups at their chosen basepoints, but they are not homotopy equivalent.*

**Proof.** The group isomorphism follows from Lemmas $8.1$ and $8.2$. Both spaces are totally disconnected. If a homotopy equivalence $P\simeq D$ existed, Theorem $7.2$ would make its underlying function a bijection. No bijection exists between a one-element set and a two-element set. Hence no homotopy equivalence exists. $\square$

The defect is transparent. The based group $\pi_1(D,0)$ records loops only in the component containing $0$ and ignores the component $\{1\}$. The fundamental groupoid does not lose this information: $\Pi_1(P)$ has one object, whereas $\Pi_1(D)$ has two nonisomorphic objects and no arrows between them.

## 9. Algorithms and finite models

Although the theorems are structural, they suggest concrete procedures for finite groupoids.

### 9.1 Vertex-group extraction

Suppose a finite groupoid is represented by a finite object set, finite arrow sets, source and target maps, and a composition table. Choose a base object $c$. Extract all arrows with source and target $c$ and restrict the composition table to them. This gives $\operatorname{Aut}(c)$.

If the groupoid contains $M$ arrows, scanning the arrow list costs $O(M)$. Constructing a full multiplication table for a vertex group of order $k$ costs $O(k^2)$ table accesses. Connectedness may be checked by breadth-first search on the underlying undirected object graph in $O(N+M)$ time for $N$ objects.

### 9.2 Reconstructing coordinates from transport arrows

For each object $a$, choose an arrow $u_a:c\to a$, found by graph traversal. Encode an arrow $h:a\to b$ as

$$
\kappa(h)=u_b^{-1}hu_a\in\operatorname{Aut}(c).
$$

This coordinate map exposes the equivalence with the one-object groupoid. Given precomputed inverses and constant-time composition-table lookup, encoding each arrow takes constant time; preprocessing transport arrows takes $O(N+M)$.

### 9.3 Comparing connected groupoids

After verifying connectedness, extract a vertex group from each groupoid and test the finite groups for isomorphism. The classification theorem guarantees that the original groupoids are equivalent exactly when these groups are isomorphic. A simple exhaustive isomorphism test for groups of common order $k$ considers up to $k!$ bijections and checks $k^2$ products for each, giving $O(k!k^2)$ worst-case time. Practical group-isomorphism algorithms use generators, invariants, and backtracking to reduce this cost substantially.

For finitely presented $K(G,1)$ models, the analogous pipeline replaces multiplication tables by group presentations. The mathematical reduction remains valid, though group isomorphism for arbitrary finite presentations is not algorithmically decidable in general. The theorem identifies the correct algebraic problem; it does not erase that problem’s computational difficulty.

## 10. Applications and boundary of validity

The classification creates a bridge between topology and algebra. In geometric group theory, a group acts as the compact algebraic signature of any connected $K(G,1)$ model. In motion planning, loops in a collision-free configuration space represent repeatable maneuvers; when the space is a $1$-type, their group completely determines its homotopy type. In network models with reversible transitions, a connected groupoid can be reduced to the symmetry group at one reference state.

The result also clarifies basepoint dependence. In a path-connected space, fundamental groups at different basepoints are isomorphic, but the isomorphism depends on a chosen connecting path and is generally not canonical. This is exactly the transport choice in the proof of Theorem $3.4$. The groupoid retains all basepoints simultaneously and makes this dependence geometrically visible.

There are two distinct ways completeness can fail.

First, **disconnectedness** creates information in components not containing the basepoint. The point-versus-two-points counterexample isolates this failure without any higher homotopy. Replacing the based group by the full fundamental groupoid repairs the problem for all homotopy $1$-types.

Second, **higher homotopy** survives even in connected, simply connected spaces. A point and the sphere $S^2$ both have trivial fundamental group. Their connected fundamental groupoids are equivalent, yet they are not homotopy equivalent because

$$
\pi_2(S^2)\cong\mathbb Z,
\qquad
\pi_2(P)=0.
$$

Thus even the fundamental groupoid is not complete beyond $1$-types. Higher groupoids or the full homotopy type are required to retain higher-dimensional cells and spheres.

The exact scope can be summarized as follows:

1. For arbitrary spaces, the based fundamental group is an invariant but not complete.
2. For disconnected $1$-types, the fundamental groupoid is complete, while one based group is not.
3. For connected $1$-types, one vertex group is complete.
4. Beyond $1$-types, neither the based group nor the fundamental groupoid is complete.

## 11. Future directions

A natural next step is a direct realization theorem for topological Eilenberg–MacLane spaces. One may define a pointed $K(G,1)$ by path-connectedness, an identification of its fundamental group with $G$, and vanishing higher homotopy groups. A classifying-space realization from groupoids to spaces, together with a $1$-truncation construction, should identify a connected $1$-type with the realization of its fundamental groupoid and make the topological classification entirely explicit.

The boundary of completeness can also be sharpened. For arbitrary $1$-types, equivalence of fundamental groupoids should be formulated as the exact complete invariant, including all path components. Beyond degree $1$, standard examples such as a point and a simply connected sphere show that higher homotopy groups are indispensable.

Further examples would illuminate the hierarchy: connected spaces with equal fundamental groups but unequal second homotopy groups; lens spaces with related fundamental groups but distinct homotopy types; products $K(G,1)\times S^n$, which preserve the fundamental group while introducing controlled higher homotopy; and classifying spaces $BG$ for concrete finite groups.

On the computational side, useful refinements include canonical or optimized choices of transport arrows, compressed representations by generators rather than complete multiplication tables, and componentwise normal forms for finite groupoids. These would turn the conceptual reduction into practical tools for topological data and reversible-state networks.

## 12. Conclusion

Every connected groupoid is equivalent to the one-object groupoid of the automorphism group at a chosen vertex. The proof is economical: the vertex functor is faithful by construction, full because every endomorphism is invertible, and essentially surjective by connectedness. This gives both directions of classification for connected groupoids and, through the groupoid model, for connected homotopy $1$-types. Accordingly, $K(G,1)$ spaces are classified up to homotopy by $G$.

The counterexample of one point versus two discrete points shows why the hypotheses cannot be discarded. Their based fundamental groups are both trivial, but total disconnectedness makes homotopy rigid and forces any homotopy equivalence to be a bijection. The missing datum is the extra component. Higher-dimensional examples reveal a second omission: loops do not encode higher homotopy.

The fundamental group is therefore neither merely weak nor universally omniscient. It is exact on a sharply defined domain. For connected homotopy $1$-types, one group is the whole homotopy story; outside that domain, the hierarchy of groupoids and higher invariants records what one group necessarily forgets.
