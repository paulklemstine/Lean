# The Fundamental Group as a Complete Invariant of Connected Homotopy 1-Types

**Aristotle**  
**31 July 2026**

## Abstract

The fundamental group is preserved by homotopy equivalence but does not classify arbitrary topological spaces. This paper isolates the precise algebraic setting in which it becomes complete. A connected groupoid is shown to be equivalent to the one-object groupoid formed from the automorphism group of any chosen object. Consequently, two connected groupoids are equivalent if and only if their vertex automorphism groups are isomorphic. Interpreting groupoids as homotopy $1$-types yields the classification of connected Eilenberg–Mac Lane $1$-types $K(G,1)$ by the group $G$. We also establish the complementary preservation result: an equivalence of groupoids identifies corresponding vertex groups, and a homotopy equivalence of spaces induces an isomorphism of based fundamental groups. The scope of the classification is demonstrated by an explicit counterexample. A one-point discrete space and a two-point discrete space have isomorphic trivial fundamental groups but are not homotopy equivalent. The obstruction follows from a general rigidity theorem: homotopic maps into a totally disconnected space are equal, so a homotopy equivalence between totally disconnected spaces must be a genuine bijection. Together, these results identify connectedness and truncation at homotopical dimension one as the conditions under which the fundamental group retains all relevant information.

## 1. Introduction

A topological invariant associates algebraic data to a space in a manner preserved by an appropriate notion of equivalence. The fundamental group $\pi_1(X,x)$ is formed from loops based at $x$, with loops identified when they are homotopic relative to their endpoints and multiplied by concatenation. If $X$ and $Y$ are homotopy equivalent, their corresponding fundamental groups are isomorphic. The converse is false in general: one algebraic shadow cannot normally record every component and every higher-dimensional feature of a space.

There is nevertheless a natural range in which the converse holds exactly. A homotopy $1$-type has no nontrivial homotopy above dimension one. Its points, paths, and homotopies between paths are represented algebraically by a groupoid. If the $1$-type is connected, every point is reachable from any chosen basepoint. In that case, all path data can be transported to loops at the basepoint, and all composition is governed by one group.

The central theorem can be expressed as

$$
\mathcal C\simeq\mathcal D
\quad\Longleftrightarrow\quad
\operatorname{Aut}_{\mathcal C}(c)\cong
\operatorname{Aut}_{\mathcal D}(d)
$$

for connected groupoids $\mathcal C$ and $\mathcal D$ and chosen objects $c$ and $d$. The proof has three ingredients. First, the one-object groupoid associated with $\operatorname{Aut}(c)$ maps fully and faithfully into $\mathcal C$. Second, connectedness makes that map essentially surjective. Third, a group isomorphism induces an equivalence between the corresponding one-object groupoids.

This groupoid statement is the exact algebraic classification result. Its topological interpretation applies to connected homotopy $1$-types, and in particular to spaces of type $K(G,1)$. It should not be confused with the unrestricted claim that any two spaces with the same fundamental group are homotopy equivalent. To mark the boundary, we prove that the one-point and two-point discrete spaces have the same based fundamental group but different homotopy types.

The argument also supplies a useful general theorem about totally disconnected spaces. Since the image of a connected interval under a continuous map is connected, every path in a totally disconnected space is constant. Thus a homotopy into such a space cannot move any point. Homotopy inverse identities consequently become literal inverse identities.

## 2. Definitions and conventions

### 2.1 Groupoids and equivalence

A **groupoid** $\mathcal C$ consists of objects, sets of arrows $\operatorname{Hom}_{\mathcal C}(x,y)$, identity arrows, and associative composition, with the requirement that every arrow be invertible. The automorphisms of an object $c$ form a group

$$
\operatorname{Aut}_{\mathcal C}(c)
=\operatorname{Hom}_{\mathcal C}(c,c),
$$

where multiplication is composition.

A functor $F:\mathcal C\to\mathcal D$ maps objects to objects and arrows to arrows while preserving identities and composition. It is **faithful** if each map on arrow sets is injective, **full** if each such map is surjective, and **essentially surjective** if every object of $\mathcal D$ is isomorphic to an object $F(c)$. A functor is an equivalence precisely when it is full, faithful, and essentially surjective.

A pointed groupoid $(\mathcal C,c)$ is **connected at $c$** if for every object $x$ there exists an isomorphism $c\to x$. In a groupoid, this is equivalent to connectedness of the underlying undirected network of objects and arrows. If it holds at one object, it holds at every object.

### 2.2 One-object groupoids

For a group $G$, define $BG$ to be the groupoid with one object $\ast$ and

$$
\operatorname{Hom}_{BG}(\ast,\ast)=G.
$$

The identity arrow is the identity element of $G$, composition is group multiplication, and arrow inversion is group inversion. A group homomorphism $\varphi:G\to H$ induces a functor $B\varphi:BG\to BH$. If $\varphi$ is an isomorphism, $B\varphi$ is an equivalence.

### 2.3 Fundamental groupoids and $1$-types

For a topological space $X$, the **fundamental groupoid** $\Pi_1(X)$ has the points of $X$ as objects. An arrow $x\to y$ is an endpoint-preserving homotopy class of paths from $x$ to $y$. Path concatenation gives composition and path reversal gives inversion. The vertex group at $x$ is

$$
\operatorname{Aut}_{\Pi_1(X)}(x)=\pi_1(X,x).
$$

If $X$ is path-connected, then $\Pi_1(X)$ is connected at every point.

A **homotopy $1$-type** is a homotopy type whose homotopy groups in degrees $n\ge2$ vanish. A connected Eilenberg–Mac Lane space $K(G,1)$ is characterized by

$$
\pi_1(K(G,1))\cong G,\qquad
\pi_n(K(G,1))=0\quad(n\ge2).
$$

The groupoid is the algebraic model of a homotopy $1$-type: objects model points, arrows model paths up to homotopy, and no independent higher cells remain.

### 2.4 Totally disconnected spaces

A topological space $Y$ is **totally disconnected** if every connected subset of $Y$ has at most one point. Discrete spaces are totally disconnected. Because the interval $[0,1]$ is connected, every continuous map $[0,1]\to Y$ is constant when $Y$ is totally disconnected.

## 3. Compression of a connected groupoid

Fix a connected groupoid $\mathcal C$ and an object $c$. Let

$$
G=\operatorname{Aut}_{\mathcal C}(c).
$$

There is a canonical vertex functor

$$
V_c:BG\longrightarrow\mathcal C
$$

that sends the sole object of $BG$ to $c$ and sends each element $g\in G$ to the corresponding automorphism of $c$.

**Lemma 3.1 (Faithfulness of the vertex functor).** *The functor $V_c$ is faithful.*

**Proof sketch.** The only arrow set in $BG$ is $G$. On this set, $V_c$ is the identity interpretation of a group element as an automorphism of $c$. If two such arrows have the same image, they are the same automorphism and hence the same element of $G$. Thus the arrow map is injective. $\square$

**Lemma 3.2 (Fullness of the vertex functor).** *The functor $V_c$ is full.*

**Proof sketch.** Every arrow from $c$ to itself in $\mathcal C$ is invertible because $\mathcal C$ is a groupoid. It is therefore an element of $\operatorname{Aut}_{\mathcal C}(c)=G$, and by construction it lies in the image of $V_c$. $\square$

**Lemma 3.3 (Essential surjectivity from connectedness).** *If $\mathcal C$ is connected at $c$, then $V_c$ is essentially surjective.*

**Proof sketch.** Given any object $x$ of $\mathcal C$, connectedness supplies an isomorphism $c\cong x$. Since $c$ is the image of the unique object of $BG$, the object $x$ is isomorphic to an object in the image. $\square$

Combining these observations gives the structural core of the classification.

**Theorem 3.4 (Connected Groupoid Compression Theorem).** *Every connected groupoid $\mathcal C$ is equivalent to the one-object groupoid $B\operatorname{Aut}_{\mathcal C}(c)$ associated with the automorphism group of any chosen object $c$.*

**Proof sketch.** By Lemmas 3.1–3.3, the vertex functor is full, faithful, and essentially surjective. The standard equivalence criterion therefore makes it an equivalence. Reversing its direction if desired gives

$$
\mathcal C\simeq B\operatorname{Aut}_{\mathcal C}(c).
$$

Concretely, choose an isomorphism $p_x:c\to x$ for every object $x$. An arrow $f:x\to y$ is encoded by

$$
p_y^{-1}fp_x\in\operatorname{Aut}_{\mathcal C}(c),
$$

and recovered as $f=p_y(p_y^{-1}fp_x)p_x^{-1}$. This makes explicit why no arrow data are lost. $\square$

The choices $p_x$ are not canonical, but the resulting equivalence class is. Replacing $p_x$ by another family changes coordinates through automorphisms at the basepoint.

## 4. Exact classification by the vertex group

**Lemma 4.1 (One-object transport).** *If $G\cong H$ as groups, then $BG\simeq BH$ as groupoids.*

**Proof sketch.** A group isomorphism $\varphi:G\to H$ defines a functor that maps the sole object to the sole object and maps arrows by $\varphi$. Injectivity gives faithfulness, surjectivity gives fullness, and essential surjectivity is automatic because the target has one object. $\square$

**Theorem 4.2 (Sufficiency of isomorphic vertex groups).** *Let $\mathcal C$ and $\mathcal D$ be connected groupoids, with chosen objects $c$ and $d$. If*

$$
\operatorname{Aut}_{\mathcal C}(c)\cong
\operatorname{Aut}_{\mathcal D}(d),
$$

*then $\mathcal C\simeq\mathcal D$.*

**Proof sketch.** Compress both groupoids using Theorem 3.4 and apply Lemma 4.1 in the middle:

$$
\mathcal C
\simeq B\operatorname{Aut}_{\mathcal C}(c)
\simeq B\operatorname{Aut}_{\mathcal D}(d)
\simeq\mathcal D.
$$

The composite of equivalences is an equivalence. $\square$

The converse does not require connectedness when the target basepoint is the image of the source basepoint.

**Theorem 4.3 (Preservation of vertex groups).** *If $E:\mathcal C\simeq\mathcal D$ is an equivalence of groupoids and $c$ is an object of $\mathcal C$, then*

$$
\operatorname{Aut}_{\mathcal C}(c)\cong
\operatorname{Aut}_{\mathcal D}(E(c)).
$$

**Proof sketch.** An equivalence is fully faithful, so it induces a bijection

$$
\operatorname{Hom}_{\mathcal C}(c,c)\longrightarrow
\operatorname{Hom}_{\mathcal D}(E(c),E(c)).
$$

Functoriality preserves identities and composition. Since all endomorphisms in a groupoid are automorphisms, this bijective monoid homomorphism is a group isomorphism. $\square$

To compare $E(c)$ with an independently chosen $d$, connectedness of $\mathcal D$ supplies an isomorphism $i:d\cong E(c)$. Conjugation by $i$ identifies their automorphism groups.

**Theorem 4.4 (Exact Classification Theorem).** *For connected groupoids $\mathcal C$ and $\mathcal D$ with chosen objects $c$ and $d$, the following are equivalent:*

1. *$\mathcal C$ and $\mathcal D$ are equivalent groupoids;*
2. *$\operatorname{Aut}_{\mathcal C}(c)$ and $\operatorname{Aut}_{\mathcal D}(d)$ are isomorphic groups.*

**Proof sketch.** The implication from (2) to (1) is Theorem 4.2. For the reverse implication, Theorem 4.3 identifies $\operatorname{Aut}_{\mathcal C}(c)$ with $\operatorname{Aut}_{\mathcal D}(E(c))$. Connectedness gives $d\cong E(c)$, and conjugation along this isomorphism identifies $\operatorname{Aut}_{\mathcal D}(E(c))$ with $\operatorname{Aut}_{\mathcal D}(d)$. Composing the two group isomorphisms proves (2). $\square$

**Corollary 4.5 (Classification of connected homotopy $1$-types).** *Two connected homotopy $1$-types are equivalent if and only if their fundamental groups at chosen basepoints are isomorphic. In particular, the group $G$ is a complete invariant of the homotopy $1$-type $K(G,1)$.*

This corollary concerns equivalence at the level of homotopy $1$-types. For spaces already known to have no higher homotopy information, it captures their entire homotopy type. For arbitrary spaces, the fundamental groupoid is only the $1$-truncation and cannot detect higher homotopy groups.

## 5. Homotopy invariance for spaces

**Theorem 5.1 (Homotopy invariance of the fundamental group).** *Let $e:X\simeq Y$ be a homotopy equivalence of topological spaces. For every $x\in X$, there is a group isomorphism*

$$
\pi_1(X,x)\cong\pi_1(Y,e(x)).
$$

**Proof sketch.** The map $e$ sends a based loop at $x$ to a based loop at $e(x)$ and respects endpoint-preserving homotopies and concatenation. A homotopy inverse induces the inverse map on loop classes because maps that are homotopic induce the same map on the fundamental group after the standard basepoint adjustment. Equivalently, $e$ induces an equivalence of fundamental groupoids, and Theorem 4.3 identifies the vertex groups. $\square$

The theorem says that $\pi_1$ is always an invariant. Completeness is a stronger property: an invariant is complete on a class of objects if equality, or isomorphism, of invariant values implies equivalence of the objects. Corollary 4.5 establishes completeness on connected $1$-types, not on all spaces.

## 6. Rigidity in totally disconnected targets

The failure outside the classified range can be seen without invoking higher-dimensional invariants.

**Lemma 6.1 (Constancy of paths).** *Every continuous path in a totally disconnected space is constant.*

**Proof sketch.** The interval $[0,1]$ is connected, and the continuous image of a connected space is connected. In a totally disconnected space, the image must therefore consist of one point. $\square$

**Theorem 6.2 (Rigidity of homotopies).** *Let $Y$ be totally disconnected. If continuous maps $f,g:X\to Y$ are homotopic, then $f=g$.*

**Proof sketch.** Let $H:[0,1]\times X\to Y$ be a homotopy from $f$ to $g$. For a fixed $x\in X$, the map $t\mapsto H(t,x)$ is a path in $Y$. Lemma 6.1 makes it constant, so

$$
f(x)=H(0,x)=H(1,x)=g(x).
$$

This holds for every $x$, hence $f=g$. $\square$

**Theorem 6.3 (Homotopy equivalences are bijections in the totally disconnected setting).** *If $X$ and $Y$ are totally disconnected and $e:X\simeq Y$ is a homotopy equivalence, then the underlying function of $e$ is bijective.*

**Proof sketch.** Let $r:Y\to X$ be a homotopy inverse. The composites $r\circ e$ and $e\circ r$ are homotopic to the respective identity maps. By Theorem 6.2, these homotopies imply literal equalities

$$
r\circ e=\operatorname{id}_X,\qquad
e\circ r=\operatorname{id}_Y.
$$

Thus $r$ is a two-sided set-theoretic inverse of $e$, making $e$ bijective. $\square$

## 7. Counterexample to unrestricted classification

Let $P=\{*\}$ be the one-point discrete space and $D=\{0,1\}$ the two-point discrete space. Select $*\in P$ and $0\in D$ as basepoints.

**Lemma 7.1 (Triviality of the two fundamental groups).** *Both $\pi_1(P,*)$ and $\pi_1(D,0)$ are trivial groups.*

**Proof sketch.** Every path in either discrete space is constant by Lemma 6.1. Hence the only loop at either selected basepoint is the constant loop, up to endpoint-preserving homotopy. Each fundamental group has one element. $\square$

It follows that

$$
\pi_1(P,*)\cong\{1\}\cong\pi_1(D,0).
$$

**Theorem 7.2 (Same fundamental group, different homotopy type).** *The spaces $P$ and $D$ have isomorphic based fundamental groups but are not homotopy equivalent.*

**Proof sketch.** Their fundamental groups are isomorphic by Lemma 7.1. Both spaces are totally disconnected. If a homotopy equivalence $P\simeq D$ existed, Theorem 6.3 would make its underlying map a bijection. No bijection exists from a one-element set to a two-element set. Therefore no homotopy equivalence exists. $\square$

The counterexample isolates the role of connectedness. A based fundamental group only probes the component containing its basepoint. The extra isolated point of $D$ is invisible to $\pi_1(D,0)$. Retaining the entire fundamental groupoid would reveal the discrepancy: $\Pi_1(P)$ has one connected component, whereas $\Pi_1(D)$ has two.

There is also a separate higher-dimensional limitation. Even among connected spaces, $\pi_1$ does not classify arbitrary homotopy types. For example, a point and the sphere $S^2$ both have trivial fundamental group, while second homotopy or second homology distinguishes them. This observation explains why the $1$-type assumption is essential in Corollary 4.5.

## 8. Algorithms and finite examples

For a finite groupoid presented by objects, invertible arrows, source and target maps, identities, inverses, and a composition table, Theorem 3.4 gives a direct compression procedure.

**Algorithm 8.1 (Vertex-group compression).** Choose a base object $c$. Search the arrow table for an isomorphism $p_x:c\to x$ for every object $x$. If one does not exist, the groupoid is not connected at $c$. Otherwise collect all loops $c\to c$; these form $G=\operatorname{Aut}(c)$. Encode each arrow $f:x\to y$ by

$$
\operatorname{code}(f)=p_y^{-1}fp_x\in G.
$$

Decode $g\in G$ as $p_ygp_x^{-1}:x\to y$. The two formulas are mutually inverse for fixed endpoints.

With an explicit arrow table of size $m$ and constant-time table lookup, collecting loops and checking sources and targets costs $O(m)$. A straightforward search for one connector per object also costs $O(m)$. Encoding all arrows is $O(m)$ once inverses and composition are table-indexed. The output may be exponentially more concise than a redundant many-object presentation because it retains one object and the vertex group.

For connected finite groupoids $\mathcal C$ and $\mathcal D$, classification reduces to computing their vertex groups and testing group isomorphism. The complexity of the second task depends on the group representation; the structural reduction itself is linear in the explicit groupoid tables.

The discrete counterexample has an equally simple computational signature. For a finite discrete space with $n$ points, every based fundamental group is trivial, independent of $n$, while its homotopy type remembers $n$ because homotopy equivalence is bijection. Thus the list

$$
(n,|\pi_1|)=(1,1),(2,1),(3,1),\ldots
$$

shows an infinite family on which the based fundamental group is constant while the homotopy types are pairwise distinct.

## 9. Applications and conceptual consequences

The classification provides a bridge between geometric and algebraic descriptions.

First, any connected groupoid can be replaced, up to equivalence, by a skeletal one-object model. This is useful whenever a problem is invariant under equivalence: calculations involving many isomorphic objects can be transferred to a single group.

Second, connected homotopy $1$-types can be organized by groups. The construction $G\mapsto BG$ realizes a group as a one-object groupoid, while taking a vertex automorphism group reverses the construction up to equivalence. In topology, a geometric realization of $BG$ supplies the corresponding $K(G,1)$ model.

Third, the theorem clarifies the effect of changing basepoints. A path between basepoints induces an isomorphism of fundamental groups by conjugation. The isomorphism is generally noncanonical because it depends on the chosen path, but the group isomorphism class is canonical on a connected component.

Fourth, the counterexample emphasizes that a complete invariant must be judged relative to a domain. The fundamental group is complete for connected $1$-types, incomplete for disconnected spaces because it misses components, and incomplete for general connected spaces because it misses higher homotopy.

## 10. Discussion and future work

The classification separates two issues that are often blended together. The groupoid theorem is purely structural: invertibility, fullness, faithfulness, and connectedness force all information into one vertex group. The topological conclusion additionally depends on restricting attention to $1$-types. A general space carries a fundamental groupoid, but that groupoid captures only its dimension-one homotopical data.

Several extensions are natural. For connected CW complexes with contractible universal covers, one expects an isomorphism of fundamental groups to be realized by a homotopy equivalence after appropriate basepoint transport. Establishing that realization directly would connect the abstract $1$-type classification to concrete spaces.

A stronger connected counterexample beyond $1$-types can be detected by second homology: $S^2$ and a point have trivial fundamental groups, but $H_2(S^2;\mathbb Z)\cong\mathbb Z$ while $H_2(\mathrm{pt};\mathbb Z)=0$. This would isolate the higher-dimensional, rather than disconnected, source of failure.

The symmetry theory of a $K(G,1)$ also invites refinement. Pointed self-equivalences correspond to automorphisms of $G$, while forgetting the basepoint should identify automorphisms differing by conjugation, leading to the outer automorphism group $\operatorname{Out}(G)$. Finally, homotopy $2$-types require new data: a fundamental group, a second homotopy group carrying a group action, and coherence information such as a Postnikov invariant. Explicit examples with the same $\pi_1$ but different $\pi_2$ would display the next layer of the classification problem.

## 11. Conclusion

A connected groupoid contains no more equivalence-invariant information than the automorphism group of one object. The vertex functor is full and faithful because it exactly captures the basepoint loops, and connectedness makes it essentially surjective. Hence connected groupoids, and therefore connected homotopy $1$-types, are classified by a single group up to isomorphism.

The accompanying counterexample is equally informative. One and two discrete points have the same trivial based fundamental group, yet total disconnectedness makes homotopy equivalence rigid enough to require an impossible bijection. The fundamental group is therefore always preserved, complete on connected $1$-types, and incomplete outside that controlled domain. Its success and its failure are governed by the same principle: it remembers precisely dimension-one information in the connected component of its basepoint.
