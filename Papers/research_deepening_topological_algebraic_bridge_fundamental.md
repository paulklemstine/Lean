# The Fundamental Group as a Complete Invariant of Homotopy 1-Types: Realization, Whitehead, Sharpness, and the Role of $\pi_0$

**Author:** Aristotle
**Date:** 2026-08-04

## Abstract

We give a complete, self-contained classification of homotopy 1-types and of the maps between them, using groupoids as the algebraic model. For connected 1-types with basepoints — the algebraic models of Eilenberg–MacLane spaces $K(G,1)$ — we prove a *realization theorem*: every homomorphism $\varphi : \pi_1(X) \to \pi_1(Y)$ of fundamental groups is induced by an actual map of 1-types. We prove that two maps out of a connected 1-type are homotopic if and only if a single isomorphism at the basepoint intertwines the two induced actions of the fundamental group, and we deduce the classification bijection
$$[\,K(G,1),\,K(H,1)\,] \;\;\cong\;\; \mathrm{Hom}(G,H)\big/\mathrm{conjugation},$$
together with its functoriality: composition of maps corresponds to composition of induced homomorphisms, exactly at the level of conjugacy classes. We compute the fibres of the realization map: the homomorphisms inducing a fixed homotopy class form a coset space of the centralizer of the image, so their number is the index $[H : C_H(\varphi(G))]$. We prove the Whitehead theorem for 1-types — a map of connected 1-types inducing an isomorphism on fundamental groups is a homotopy equivalence — and its converse. We then prove that the hypotheses are sharp in the strongest possible sense: the one-point space and the discrete two-point space have isomorphic homotopy groups in *every* degree, yet are not homotopy equivalent, so no family of homotopy groups classifies without a connectivity hypothesis. Finally we identify precisely the missing datum. Defining $\pi_0$ of a 1-type as its set of isomorphism classes of objects, we prove that every 1-type decomposes as the disjoint union of its components, that disjoint unions of connected 1-types are classified by an index bijection matching fundamental groups, and hence that the pair ($\pi_0$, the family of fundamental groups of the components) is a complete invariant of arbitrary homotopy 1-types.

**Keywords.** Fundamental group, groupoid, Eilenberg–MacLane space, homotopy 1-type, Whitehead theorem, conjugacy class of homomorphisms, centralizer, $\pi_0$, complete invariant.

---

## 1. Introduction

### 1.1 The problem

The fundamental group $\pi_1(X,x)$ of a based topological space is the archetypal algebraic invariant of a space: functorial, computable, and lossy. It is lossy by design — it sees only dimension one — and the entire apparatus of higher homotopy theory exists because of what it discards. The classification problem that this paper addresses is the complementary one: **on which class of spaces, and for which class of maps, is the fundamental group a *complete* invariant, and what exactly happens at the boundary of that class?**

The expected answer is "aspherical spaces", i.e. Eilenberg–MacLane spaces $K(G,1)$: spaces whose higher homotopy groups vanish. Making this precise, however, involves several separate statements which are usually treated as folklore:

1. **Objects.** Connected 1-types with isomorphic fundamental groups are homotopy equivalent.
2. **Maps, existence.** Every homomorphism of fundamental groups is realized by a map.
3. **Maps, uniqueness.** Two maps induce the same homotopy class exactly when the induced homomorphisms are conjugate.
4. **Whitehead.** A $\pi_1$-isomorphism between connected 1-types is a homotopy equivalence.
5. **Sharpness.** None of this survives dropping connectedness, and the failure is severe.
6. **Repair.** Adding $\pi_0$ restores completeness for all 1-types.

This paper proves all six, in a uniform algebraic setting, and quantifies (3) by computing the fibres of the realization map.

### 1.2 The algebraic model

We work with **groupoids**: categories in which every morphism is invertible. The fundamental groupoid $\Pi_1(X)$ of a space — objects the points of $X$, morphisms the homotopy classes rel endpoints of paths — is the canonical example, and for a homotopy 1-type it is a faithful algebraic replacement for the space. Under this dictionary:

| Topology | Algebra |
|---|---|
| homotopy 1-type $X$ | groupoid $\mathcal{C}$ |
| point $x \in X$ | object $c \in \mathcal{C}$ |
| $\pi_1(X,x)$ | vertex group $\mathrm{Aut}(c)$ |
| path-connected | connected groupoid |
| $\pi_0(X)$ | set of isomorphism classes of objects |
| continuous map | functor |
| homotopy of maps | natural isomorphism of functors |
| homotopy equivalence | equivalence of categories |
| disjoint union | coproduct of groupoids |

Every theorem below is stated and proved in this algebraic setting, where it is exact; §7 transports the main statements back to topology for path-connected spaces via the fundamental groupoid.

### 1.3 Conventions and basic definitions

Throughout, $\mathcal{C}, \mathcal{D}, \mathcal{E}$ denote groupoids; composition is written left-to-right, so $f \cdot g$ means "first $f$, then $g$", and $\mathbf{1}_X$ is the identity of $X$.

**Definition 1.1 (Vertex group).** For an object $c$ of a groupoid $\mathcal{C}$, the **vertex group** $\mathrm{Aut}(c)$ is the group of isomorphisms $c \to c$ under composition. In a groupoid every endomorphism is invertible, so $\mathrm{Aut}(c)$ coincides (as a monoid, hence as a group) with the endomorphism monoid $\mathrm{End}(c)$; we use the two interchangeably, via the isomorphism sending an isomorphism to its underlying morphism, with inverse supplied by groupoid inversion.

**Definition 1.2 (Connectedness).** A groupoid $\mathcal{C}$ is **connected at $c$** if for every object $d$ there exists an isomorphism $c \to d$. This is the algebraic form of path-connectedness with basepoint $c$. A connected groupoid with vertex group $G$ is precisely the algebraic model of a $K(G,1)$.

**Definition 1.3 (Equivalence).** An **equivalence** of groupoids is a functor $F$ which is full, faithful, and essentially surjective; equivalently, one admitting a quasi-inverse. This is the algebraic form of homotopy equivalence.

**Definition 1.4 ($\pi_0$).** For a category $\mathcal{C}$, isomorphism of objects is an equivalence relation; the quotient set
$$\pi_0(\mathcal{C}) \;=\; \mathrm{Ob}(\mathcal{C})/\!\cong$$
is the set of **connected components** of $\mathcal{C}$. A functor $F$ induces a well-defined map $\pi_0(F) : \pi_0(\mathcal{C}) \to \pi_0(\mathcal{D})$, since functors preserve isomorphisms.

**Definition 1.5 (Conjugacy of homomorphisms).** Homomorphisms $\varphi, \psi : G \to H$ are **conjugate** if there is $u \in H$ with $\psi(a) = u\varphi(a)u^{-1}$ for all $a \in G$. This is an equivalence relation (reflexive via $u = 1$, symmetric via $u^{-1}$, transitive via a product), and the quotient set is denoted $\mathrm{Hom}(G,H)/\mathrm{conj}$.

---

## 2. Chosen paths and the loop construction

All the constructions below rest on one device, which is the algebraic form of "choose a path from the basepoint to every point".

**Definition 2.1 (Chosen paths).** Let $\mathcal{C}$ be connected at $c$. A **base path system** assigns to every object $X$ an isomorphism $p_X : c \to X$, normalized so that $p_c = \mathbf{1}_c$. Such a system exists: choose $p_X$ arbitrarily among the (nonempty) isomorphisms $c \to X$ for $X \neq c$, and take the identity at $X = c$.

**Definition 2.2 (Loop of a morphism).** For $g : X \to Y$ in $\mathcal{C}$, put
$$\ell(g) \;=\; p_X \cdot g \cdot p_Y^{-1} \;\in\; \mathrm{Aut}(c).$$

**Lemma 2.3 (Properties of $\ell$).** For all composable $f : X \to Y$, $g : Y \to Z$, all objects $X$, and all $a \in \mathrm{Aut}(c)$:

1. $\ell(\mathbf{1}_X) = 1$;
2. $\ell(f \cdot g) = \ell(g) \cdot \ell(f)$ in the group $\mathrm{Aut}(c)$;
3. $\ell(a) = a$.

*Proof sketch.* (1) $p_X \cdot \mathbf{1}_X \cdot p_X^{-1} = 1$. (2) $p_X \cdot f \cdot g \cdot p_Z^{-1} = (p_X \cdot f \cdot p_Y^{-1})(p_Y \cdot g \cdot p_Z^{-1})$, and the product in $\mathrm{Aut}(c)$ is composition written in the opposite order, which accounts for the swap. (3) $p_c = \mathbf{1}_c$ by normalization. $\square$

Property (3) is the reason for the normalization $p_c = \mathbf{1}_c$: the loop construction restricts to the identity on the fundamental group itself, so the functors built from it induce exactly the homomorphism one started with, with no correction term.

---

## 3. Realization: every homomorphism is induced by a map

**Definition 3.1 (Realization functor).** Let $\mathcal{C}$ be connected at $c$ with a base path system, let $\mathcal{D}$ be a groupoid with a chosen object $d_0$, and let $\varphi : \mathrm{Aut}(c) \to \mathrm{Aut}(d_0)$ be a homomorphism. Define $R_\varphi : \mathcal{C} \to \mathcal{D}$ by
$$R_\varphi(X) = d_0 \quad \text{for all } X, \qquad R_\varphi(g) = \varphi(\ell(g)) \quad \text{for all } g.$$

**Lemma 3.2.** $R_\varphi$ is a functor.

*Proof sketch.* Identities: $R_\varphi(\mathbf{1}_X) = \varphi(\ell(\mathbf{1}_X)) = \varphi(1) = 1 = \mathbf{1}_{d_0}$ by Lemma 2.3(1). Composition: $R_\varphi(f \cdot g) = \varphi(\ell(f \cdot g)) = \varphi(\ell(g)\ell(f)) = \varphi(\ell(g))\varphi(\ell(f))$, which, unwinding the group multiplication of $\mathrm{Aut}(d_0)$ back into composition order, is exactly $R_\varphi(f) \cdot R_\varphi(g)$. $\square$

**Lemma 3.3.** $R_\varphi(a) = \varphi(a)$ for every $a \in \mathrm{Aut}(c)$.

*Proof.* Immediate from Lemma 2.3(3). $\square$

**Theorem 3.4 (Realization).** *Let $\mathcal{C}$ be a groupoid connected at $c$, let $\mathcal{D}$ be a groupoid, let $d_0 \in \mathcal{D}$, and let $\varphi : \mathrm{Aut}(c) \to \mathrm{Aut}(d_0)$ be any group homomorphism. Then there exist a functor $F : \mathcal{C} \to \mathcal{D}$ and an isomorphism $e : F(c) \to d_0$ such that the induced homomorphism of vertex groups, transported along $e$, equals $\varphi$:*
$$e^{-1} \cdot F(a) \cdot e \;=\; \varphi(a) \qquad \text{for all } a \in \mathrm{Aut}(c).$$

*Proof.* Take $F = R_\varphi$ and $e = \mathbf{1}_{d_0}$, and apply Lemma 3.3. $\square$

Topologically: **the map $[\,K(G,1), K(H,1)\,] \to \mathrm{Hom}(G,H)$ is surjective.** Every algebraic morphism between fundamental groups of aspherical spaces comes from a genuine map of spaces. Note how little is required: $\mathcal{D}$ need not be connected, and $\varphi$ need not be injective, surjective, or anything else.

---

## 4. Homotopies are conjugations

Realization is surjective but far from injective. This section identifies its fibres exactly.

**Definition 4.1 (Induced homomorphism).** If $\mathcal{D}$ is connected at $d_0$ with a base path system $q$, a functor $F : \mathcal{C} \to \mathcal{D}$ induces
$$F_* : \mathrm{Aut}(c) \to \mathrm{Aut}(d_0), \qquad F_*(a) \;=\; q_{F(c)} \cdot F(a) \cdot q_{F(c)}^{-1},$$
namely the action of $F$ on the vertex group, transported to $d_0$ along the chosen path. By Lemma 3.3, $(R_\varphi)_* = \varphi$ whenever the base path system of $\mathcal{D}$ is normalized at $d_0$.

**Theorem 4.2 (Homotopy criterion).** *Let $\mathcal{C}$ be connected at $c$, let $\mathcal{D}$ be any category, and let $F, G : \mathcal{C} \to \mathcal{D}$ be functors. Then $F$ and $G$ are homotopic (naturally isomorphic) if and only if there exists an isomorphism $h : F(c) \to G(c)$ such that*
$$F(a) \cdot h \;=\; h \cdot G(a) \qquad \text{for all } a \in \mathrm{Aut}(c).$$

*Proof sketch.*

($\Rightarrow$) Let $\alpha : F \Rightarrow G$ be a natural isomorphism and set $h = \alpha_c$. Naturality applied to the morphism $a : c \to c$ is precisely $F(a) \cdot \alpha_c = \alpha_c \cdot G(a)$.

($\Leftarrow$) Choose a path system $p$ on $\mathcal{C}$ and define, for each object $X$,
$$\alpha_X \;=\; F(p_X)^{-1} \cdot h \cdot G(p_X) \; : \; F(X) \to G(X).$$
The crucial point is **path-independence**: if $p'$ is any other isomorphism $c \to X$, then $a := p' \cdot p_X^{-1}$ is an automorphism of $c$ with $p' = a \cdot p_X$, and
$$F(p')^{-1} h\, G(p') = F(p_X)^{-1} \big(F(a)^{-1} h\, G(a)\big) G(p_X) = F(p_X)^{-1} h\, G(p_X),$$
using the intertwining hypothesis applied to $a^{-1}$. Thus $\alpha_X$ does not depend on the chosen path. Naturality now follows: given $f : X \to Y$, the composite $p_X \cdot f$ is an isomorphism $c \to Y$, hence a legitimate choice of path to $Y$, and computing $\alpha_Y$ with it gives
$$F(f) \cdot \alpha_Y = F(f) \cdot F(p_X \cdot f)^{-1} h\, G(p_X \cdot f) = F(p_X)^{-1} h\, G(p_X) \cdot G(f) = \alpha_X \cdot G(f).$$
Each $\alpha_X$ is invertible, being a composite of isomorphisms, so $\alpha$ is a natural isomorphism. $\square$

Connectedness is used exactly once, but decisively: it is what allows a single isomorphism at the basepoint to be propagated coherently over the whole 1-type.

**Lemma 4.3 (Intertwining is conjugation).** For $p, q, u \in \mathrm{Aut}(d_0)$ in a group, $p \cdot u = u \cdot q$ holds if and only if $q = u^{-1} p u$.

**Theorem 4.4 (Classification of maps).** *Let $\mathcal{C}$ be connected at $c$, let $d_0 \in \mathcal{D}$, and let $\varphi, \psi : \mathrm{Aut}(c) \to \mathrm{Aut}(d_0)$. Then*
$$R_\varphi \simeq R_\psi \iff \varphi \text{ and } \psi \text{ are conjugate in } \mathrm{Aut}(d_0).$$

*Proof sketch.* Both realizations send every object to $d_0$, so the isomorphism $h$ of Theorem 4.2 is an element $u \in \mathrm{Aut}(d_0)$, and the intertwining condition $\varphi(a) u = u \psi(a)$ for all $a$ is, by Lemma 4.3, exactly $\psi = u^{-1}\varphi u$. $\square$

**Corollary 4.5 (The classification bijection).** *Let $\mathcal{C}$ be connected at $c$ and $\mathcal{D}$ connected at $d_0$, with $G = \mathrm{Aut}(c)$ and $H = \mathrm{Aut}(d_0)$. Then the assignments $F \mapsto [F_*]$ and $[\varphi] \mapsto [R_\varphi]$ are mutually inverse bijections*
$$[\,\mathcal{C}, \mathcal{D}\,] \;=\; \{\text{functors } \mathcal{C} \to \mathcal{D}\}/\simeq \;\;\xrightarrow{\ \cong\ }\;\; \mathrm{Hom}(G,H)/\mathrm{conj}.$$

*Proof sketch.* Both maps are well defined: homotopic functors induce conjugate homomorphisms (evaluate the natural isomorphism at $c$ and transport along the chosen path), and conjugate homomorphisms have homotopic realizations (Theorem 4.4). One composite is the identity by $(R_\varphi)_* = \varphi$ (Lemma 3.3). The other is the identity because every functor $F$ out of a connected groupoid is homotopic to the realization of the homomorphism it induces: the isomorphisms $q_{F(c)}^{-1} \cdot F(p_X)^{-1}$ assemble, by Theorem 4.2 applied at the basepoint, into a natural isomorphism $F \cong R_{F_*}$. $\square$

Topologically, this is the classical statement
$$[\,X,\,K(H,1)\,] \;\cong\; \mathrm{Hom}(\pi_1 X, H)/\mathrm{conj}$$
for $X$ a connected 1-type, in its sharpest form: the bijection is exhibited by explicit mutually inverse constructions, not merely asserted.

**Theorem 4.6 (Functoriality).** *The classification is compatible with composition.*

1. *The identity map induces the identity homomorphism: $(\mathrm{id}_{\mathcal{C}})_* = \mathrm{id}_{\mathrm{Aut}(c)}$.*
2. *For $F : \mathcal{C} \to \mathcal{D}$ and $G : \mathcal{D} \to \mathcal{E}$ with $\mathcal{D}, \mathcal{E}$ connected at $d_0, e_0$, the homomorphism $(F \circ G)_*$ is conjugate to $G_* \circ F_*$; explicitly, the conjugating element is*
$$u \;=\; r_{G(d_0)} \cdot G(q_{F(c)}) \cdot r_{G(F(c))}^{-1},$$
*where $q, r$ are the chosen path systems of $\mathcal{D}, \mathcal{E}$.*
3. *Consequently, at the level of conjugacy classes the identity is exact: $[(F\circ G)_*] = [G_* \circ F_*]$.*

*Proof sketch.* (1) is immediate from the normalization $p_c = \mathbf{1}_c$. (2) Both sides are conjugations of $G(F(a))$ by paths from $e_0$; the two paths differ by exactly $u$, and expanding the definitions and cancelling $q_{F(c)}q_{F(c)}^{-1}$ yields the identity. (3) is (2) read in the quotient. $\square$

The residual conjugation in (2) is not an artifact: it is the usual basepoint-change indeterminacy, and it disappears precisely when one passes to conjugacy classes — which is exactly the object the classification bijection is about.

---

## 5. Fibres of the classification: a counting theorem

Corollary 4.5 says that homotopy classes of maps are conjugation orbits of homomorphisms. It is natural to ask how large those orbits are.

Let $G, H$ be groups. Conjugation defines an action of $H$ on $\mathrm{Hom}(G,H)$ by $(u \cdot \varphi)(a) = u \varphi(a) u^{-1}$; one checks directly that $u \cdot \varphi$ is again a homomorphism and that this is a group action. By definition, $\psi$ lies in the orbit of $\varphi$ if and only if $\psi$ and $\varphi$ are conjugate.

**Theorem 5.1 (Stabilizer = centralizer).** *The stabilizer of $\varphi \in \mathrm{Hom}(G,H)$ under conjugation is the centralizer of the image:*
$$\mathrm{Stab}_H(\varphi) \;=\; C_H\big(\varphi(G)\big) \;=\; \{u \in H : u\varphi(a) = \varphi(a)u \text{ for all } a \in G\}.$$

*Proof.* $u \cdot \varphi = \varphi$ means $u\varphi(a)u^{-1} = \varphi(a)$ for all $a$, i.e. $u$ commutes with every element of the image. $\square$

**Corollary 5.2 (Orbit structure).** *There is a bijection $\mathrm{Orb}_H(\varphi) \cong H / C_H(\varphi(G))$ between the set of homomorphisms conjugate to $\varphi$ and the coset space of the centralizer of the image. In particular*
$$\#\{\psi : \psi \sim \varphi\} \;=\; \big[\,H : C_H(\varphi(G))\,\big].$$

*Proof.* Orbit–stabilizer, combined with Theorem 5.1. $\square$

**Theorem 5.3 (Fibres of realization).** *Let $\mathcal{C}$ be connected at $c$, $d_0 \in \mathcal{D}$, $G = \mathrm{Aut}(c)$, $H = \mathrm{Aut}(d_0)$, and $\varphi \in \mathrm{Hom}(G,H)$. The set of homomorphisms $\psi$ whose realization is homotopic to that of $\varphi$ is*
$$\{\psi : R_\psi \simeq R_\varphi\} \;=\; \mathrm{Orb}_H(\varphi), \qquad \text{of cardinality} \quad \big[\,H : C_H(\varphi(G))\,\big].$$

*Proof.* Theorem 4.4 identifies the left-hand set with the orbit; Corollary 5.2 counts it. $\square$

**Examples.**

- $\varphi$ trivial: $C_H(\{1\}) = H$, index $1$. The constant map has a unique homomorphism above it.
- $\varphi$ surjective and $Z(H) = 1$: $C_H(H) = Z(H) = 1$, index $|H|$. A full copy of $H$ collapses to one homotopy class.
- $H$ abelian: every centralizer is $H$, index $1$, so conjugation is trivial and $[\,K(G,1),K(H,1)\,] \cong \mathrm{Hom}(G,H)$ on the nose. This recovers the familiar fact that for abelian targets no conjugacy quotient is needed.

**Corollary 5.4 (Counting identity).** *For finite $G, H$,*
$$|\mathrm{Hom}(G,H)| \;=\; \sum_{[\varphi]} \big[\,H : C_H(\varphi(G))\,\big],$$
*the sum being over homotopy classes of maps $K(G,1) \to K(H,1)$.* This is a finite, checkable identity relating a purely algebraic count to a purely homotopical one, and it can be verified directly for any range of small groups by the procedures of §10.

---

## 6. The Whitehead theorem for 1-types

**Theorem 6.1 (Whitehead, 1-dimensional).** *Let $\mathcal{C}$ be connected at $c$, let $F : \mathcal{C} \to \mathcal{D}$ be a functor, and suppose $\mathcal{D}$ is connected at $F(c)$. If the induced map on vertex groups*
$$F_c : \mathrm{Aut}(c) \to \mathrm{Aut}(F(c))$$
*is bijective, then $F$ is an equivalence.*

*Proof sketch.* Three separate implications.

**Injective $\Rightarrow$ faithful.** Let $f, g : X \to Y$ with $F(f) = F(g)$. Then $F$ sends the loops $\ell(f), \ell(g) \in \mathrm{Aut}(c)$ to the same automorphism, since each is a composite of $F(p_X), F(f)$ resp. $F(g)$, and $F(p_Y)^{-1}$. Injectivity gives $\ell(f) = \ell(g)$, and conjugating back by $p_X^{-1}(-)p_Y$ recovers $f = g$.

**Surjective $\Rightarrow$ full.** Let $f : F(X) \to F(Y)$. The composite $g = F(p_X) \cdot f \cdot F(p_Y)^{-1}$ is an automorphism of $F(c)$; by surjectivity choose $b \in \mathrm{Aut}(c)$ with $F(b) = g$. Then $p_X^{-1} \cdot b \cdot p_Y : X \to Y$ is a preimage of $f$, as one checks by applying $F$ and cancelling.

**Connected target $\Rightarrow$ essentially surjective.** Every object $d$ of $\mathcal{D}$ is isomorphic to $F(c)$ by hypothesis, and $F(c)$ is in the image, so $d$ is isomorphic to an object in the image.

Full + faithful + essentially surjective is an equivalence. $\square$

**Theorem 6.2 (Converse).** *If $F : \mathcal{C} \to \mathcal{D}$ is an equivalence, then $F_c : \mathrm{Aut}(c) \to \mathrm{Aut}(F(c))$ is bijective for every object $c$.*

*Proof sketch.* Injectivity is faithfulness. For surjectivity, fullness and faithfulness give a preimage morphism for any automorphism of $F(c)$, and the preimage of an isomorphism under a fully faithful functor is an isomorphism. $\square$

**Corollary 6.3.** *Two connected 1-types are homotopy equivalent if and only if their fundamental groups are isomorphic; and a map between connected 1-types is a homotopy equivalence if and only if it induces an isomorphism on fundamental groups.*

*Proof.* The "only if" statements are Theorem 6.2. For the "if": given an isomorphism $\varphi : \mathrm{Aut}(c) \to \mathrm{Aut}(d_0)$, realize it by $R_\varphi$ (Theorem 3.4); its induced map on vertex groups is $\varphi$, hence bijective, so Theorem 6.1 applies. $\square$

Corollary 6.3 is the sense in which **the fundamental group is a complete invariant of connected homotopy 1-types** — complete not just as a set-level invariant of objects, but as a classification of maps up to homotopy (Corollary 4.5), functorially (Theorem 4.6), with computable fibres (Theorem 5.3).

---

## 7. Topological consequences

We now transport the algebra back across the bridge.

**Proposition 7.1.** *If $X$ is a path-connected space and $x \in X$, then the fundamental groupoid $\Pi_1(X)$ is connected at $x$.*

*Proof sketch.* For $y \in X$ choose a path $\gamma$ from $x$ to $y$. Its homotopy class is a morphism $x \to y$, and the class of the reverse path is a two-sided inverse: $\gamma \cdot \bar\gamma \simeq \mathrm{const}_x$ and $\bar\gamma \cdot \gamma \simeq \mathrm{const}_y$. $\square$

**Theorem 7.2 (Topological realization).** *Let $X, Y$ be path-connected spaces with basepoints $x, y$, and let $\varphi : \pi_1(X,x) \to \pi_1(Y,y)$ be any homomorphism. Then there exist a map of fundamental groupoids $F : \Pi_1(X) \to \Pi_1(Y)$ and an isomorphism $e : F(x) \to y$ such that the induced homomorphism on $\pi_1$, transported along $e$, is exactly $\varphi$.*

*Proof.* Proposition 7.1 supplies connectedness; the identification of $\pi_1$ with the vertex group of the fundamental groupoid (Definition 1.1) converts $\varphi$ into a homomorphism of vertex groups; apply Theorem 3.4. $\square$

**Theorem 7.3.** *Path-connected spaces with isomorphic fundamental groups have equivalent fundamental groupoids.*

*Proof sketch.* Realize the isomorphism by a functor as in Theorem 7.2. The induced map on vertex groups is a composite of bijections — the isomorphism itself and the transport isomorphisms — hence bijective, and the target is connected at the image of the basepoint since it is connected at $y$ and $F(x) \cong y$. Theorem 6.1 applies. $\square$

For genuine 1-types, where the fundamental groupoid is a complete model, Theorem 7.3 is the statement that aspherical spaces with isomorphic fundamental groups are homotopy equivalent. For general spaces it is the exact residue of that statement that survives: the 1-truncations agree.

---

## 8. Sharpness: the hypotheses cannot be weakened

### 8.1 Connectedness is necessary

**Definition 8.1 (Discrete 1-type).** For a set $\alpha$, the **discrete groupoid** $\mathbf{D}(\alpha)$ has object set $\alpha$ and only identity morphisms. All its vertex groups are trivial. It is the algebraic model of a totally disconnected space.

**Theorem 8.2 (Connectedness is necessary).** *The groupoids $\mathbf{D}(\{*\})$ and $\mathbf{D}(\{0,1\})$ satisfy:*

1. *their vertex groups at any basepoints are isomorphic (both trivial);*
2. *$\mathbf{D}(\{*\})$ is connected;*
3. *$\mathbf{D}(\{0,1\})$ is not connected;*
4. *they are not equivalent.*

*Proof sketch.* (1) Both vertex groups are trivial, so the unique map between them is an isomorphism. (2) There is only one object. (3) A morphism between distinct objects of a discrete groupoid would force those objects to be equal, contradicting $0 \neq 1$. (4) An equivalence would induce a bijection on isomorphism classes of objects (see Proposition 8.6 below), but one side has one class and the other two. $\square$

Thus Corollary 6.3 genuinely requires connectedness on both sides.

### 8.2 No family of homotopy groups suffices

Theorem 8.2 might suggest that the deficiency is confined to $\pi_1$ and could be repaired by higher homotopy groups. It cannot. The following is the sharpest form of the counterexample.

**Theorem 8.3 (Vanishing of all homotopy groups of a totally disconnected space).** *Let $Z$ be a totally disconnected topological space, $z \in Z$, and let $N$ be any nonempty index type. Then the homotopy "group" $\pi_N(Z,z)$ of based maps of the cube $[0,1]^N$ sending the boundary to $z$, modulo boundary-fixing homotopy, has exactly one element.*

*Proof sketch.* Let $f$ be such a based cube map. The cube $[0,1]^N$ is connected, and $f$ is continuous, so its image is a connected subset of $Z$; in a totally disconnected space every connected subset is a single point. Hence $f$ is constant. Since $f$ sends the boundary — which is nonempty, containing for instance the corner with all coordinates $0$ — to $z$, that constant value is $z$. So any two based cube maps $f, g$ are equal as functions; the constant homotopy $H(t,y) = f(y)$ is then a boundary-fixing homotopy from $f$ to $g$. Therefore all such maps are identified in the quotient. $\square$

**Theorem 8.4 (All homotopy groups agree, yet not homotopy equivalent).** *Let $P$ be the one-point space and $B$ the two-point discrete space. Then:*

1. *for every degree, $\pi_N(P) \cong \pi_N(B)$ (both are trivial);*
2. *$P$ and $B$ are not homotopy equivalent.*

*Proof sketch.* (1) Both spaces are totally disconnected, so Theorem 8.3 makes every homotopy group trivial in every degree, and any two one-element sets are in bijection. (2) A homotopy equivalence between totally disconnected spaces induces a bijection of underlying point sets — homotopies between maps into a totally disconnected space are constant, so the homotopy inverse is an actual two-sided inverse — and there is no bijection between a one-element and a two-element set. $\square$

This is a strictly stronger negative result than "the fundamental group is not a complete invariant". It says the whole infinite tower $\pi_1, \pi_2, \pi_3, \dots$ is not a complete invariant, and it isolates the reason: the tower is blind to $\pi_0$.

### 8.3 $\pi_0$ is exactly what is missing, in the extreme case

**Proposition 8.5 (Components of a discrete 1-type).** *$\pi_0(\mathbf{D}(\alpha)) \cong \alpha$.*

**Proposition 8.6 ($\pi_0$ is a homotopy invariant).** *An equivalence $\mathcal{C} \simeq \mathcal{D}$ induces a bijection $\pi_0(\mathcal{C}) \cong \pi_0(\mathcal{D})$.*

*Proof sketch.* The functor and its quasi-inverse induce maps on $\pi_0$; the unit and counit isomorphisms show that the two composites act as the identity on isomorphism classes. $\square$

**Proposition 8.7.** *If $\mathcal{C}$ is connected then $\pi_0(\mathcal{C})$ has at most one element.*

**Theorem 8.8 (Discrete 1-types are classified by $\pi_0$).** *$\mathbf{D}(\alpha) \simeq \mathbf{D}(\beta)$ if and only if there is a bijection $\alpha \cong \beta$.*

*Proof sketch.* ($\Rightarrow$) Compose the bijections of Propositions 8.5 and 8.6. ($\Leftarrow$) A bijection of sets induces an isomorphism, hence an equivalence, of the associated discrete groupoids. $\square$

So in the totally disconnected world — where the fundamental groups carry no information whatsoever — $\pi_0$ is a complete invariant. Together with Theorem 8.2 this pins down $\pi_0$ as *precisely* the datum that the fundamental group was missing.

---

## 9. The complete invariant of an arbitrary 1-type

We now prove that $\pi_0$ and the fundamental groups, taken together, classify *all* 1-types. The proof has two halves: a gluing theorem for disjoint unions, and a decomposition theorem reducing the general case to that one.

### 9.1 Coproducts of 1-types

**Definition 9.1 (Coproduct).** Given a family $(\mathcal{C}_i)_{i \in I}$ of groupoids, their **coproduct** $\coprod_i \mathcal{C}_i$ has objects the pairs $(i, X)$ with $X \in \mathcal{C}_i$, and morphisms $(i,X) \to (j,Y)$ given by the morphisms $X \to Y$ of $\mathcal{C}_i$ when $i = j$, and none otherwise. It is again a groupoid.

**Lemma 9.2 (Summands are separated).** *If $(i,X) \cong (j,Y)$ in $\coprod_k \mathcal{C}_k$ then $i = j$; moreover $\mathrm{Aut}\big((i,X)\big) \cong \mathrm{Aut}(X)$.*

*Proof sketch.* By construction there are no morphisms between different summands; and within a summand the hom-sets and composition are those of $\mathcal{C}_i$. $\square$

**Proposition 9.3 ($\pi_0$ of a coproduct).** *If each $\mathcal{C}_i$ is connected (at a chosen $c_i$) then $\pi_0\big(\coprod_i \mathcal{C}_i\big) \cong I$.*

*Proof sketch.* Every object $(i, X)$ is isomorphic to $(i, c_i)$, since $\mathcal{C}_i$ is connected; and distinct basepoints are non-isomorphic by Lemma 9.2. The map sending a class to its index is therefore a well-defined bijection. $\square$

**Proposition 9.4 (Assembling maps).** *Let $e : I \to J$ and let $F_i : \mathcal{C}_i \to \mathcal{D}_{e(i)}$ be functors. These assemble into $\coprod_i F_i : \coprod_i \mathcal{C}_i \to \coprod_j \mathcal{D}_j$, which is:*

- *faithful if every $F_i$ is faithful;*
- *full if every $F_i$ is full and $e$ is injective;*
- *essentially surjective if every $F_i$ is essentially surjective and $e$ is surjective.*

*Proof sketch.* Faithfulness and fullness are checked summand by summand; injectivity of $e$ guarantees no morphisms are missed between summands mapping to the same target index, and surjectivity of $e$ guarantees every target summand is reached. $\square$

**Theorem 9.5 (Gluing).** *A bijection $e : I \cong J$ together with equivalences $\mathcal{C}_i \simeq \mathcal{D}_{e(i)}$ for all $i$ yields an equivalence $\coprod_i \mathcal{C}_i \simeq \coprod_j \mathcal{D}_j$.*

*Proof.* Apply Proposition 9.4 to the family of equivalence functors. $\square$

**Theorem 9.6 (Classification of coproducts of connected 1-types).** *Let $(\mathcal{C}_i)_{i\in I}$ and $(\mathcal{D}_j)_{j \in J}$ be families of groupoids, connected at $c_i$ resp. $d_j$. Then*
$$\coprod_i \mathcal{C}_i \;\simeq\; \coprod_j \mathcal{D}_j \iff \exists\, e : I \cong J \text{ with } \mathrm{Aut}(c_i) \cong \mathrm{Aut}(d_{e(i)}) \text{ for all } i.$$

*Proof sketch.* ($\Leftarrow$) By Corollary 6.3 each isomorphism of vertex groups gives an equivalence $\mathcal{C}_i \simeq \mathcal{D}_{e(i)}$; glue with Theorem 9.5. ($\Rightarrow$) Given an equivalence $E$, define $e(i)$ to be the index of the summand containing $E(i, c_i)$. This is well defined, and it is a bijection since $E$ induces a bijection on $\pi_0$ (Proposition 8.6) which is $I \to J$ under the identification of Proposition 9.3. For the vertex groups: $\mathrm{Aut}(c_i) \cong \mathrm{Aut}(i,c_i) \cong \mathrm{Aut}\big(E(i,c_i)\big) \cong \mathrm{Aut}\big(e(i), d_{e(i)}\big) \cong \mathrm{Aut}(d_{e(i)})$, using Lemma 9.2 twice, Theorem 6.2 for the middle isomorphism, and connectedness of $\mathcal{D}_{e(i)}$ to move the basepoint. $\square$

### 9.2 Decomposition

**Definition 9.7 (Component subgroupoid).** For $p \in \pi_0(\mathcal{C})$, let $\mathcal{C}_p$ be the full subgroupoid on the objects whose isomorphism class is $p$.

**Proposition 9.8.** *Each $\mathcal{C}_p$ is connected, and its vertex group at any object is the automorphism group of that object computed in $\mathcal{C}$.*

*Proof sketch.* Two objects with the same class are isomorphic in $\mathcal{C}$; the isomorphism lies in $\mathcal{C}_p$ because $\mathcal{C}_p$ is a full subgroupoid. Fullness also identifies the hom-sets, hence the vertex groups. $\square$

**Theorem 9.9 (Decomposition into components).** *For every groupoid $\mathcal{C}$, the assembly functor*
$$\coprod_{p \in \pi_0(\mathcal{C})} \mathcal{C}_p \longrightarrow \mathcal{C}, \qquad (p, X) \mapsto X,$$
*is an equivalence.*

*Proof sketch.* Faithful: morphisms in the coproduct are morphisms of $\mathcal{C}$, and no data is forgotten. Full: any $f : X \to Y$ in $\mathcal{C}$ forces $X$ and $Y$ into the same component, so it already lives in the corresponding summand. Essentially surjective: $X$ is the image of $([X], X)$, on the nose. $\square$

**Theorem 9.10 (Complete invariant for arbitrary homotopy 1-types).** *Two groupoids $\mathcal{C}, \mathcal{D}$ are equivalent if and only if there is a bijection $e : \pi_0(\mathcal{C}) \cong \pi_0(\mathcal{D})$ such that, for every component $p$, the fundamental groups of the corresponding components are isomorphic:*
$$\mathrm{Aut}\big(X_p\big) \;\cong\; \mathrm{Aut}\big(Y_{e(p)}\big),$$
*where $X_p$, $Y_q$ are any chosen representatives of the components $p$, $q$.*

*Proof.* By Theorem 9.9, $\mathcal{C} \simeq \coprod_p \mathcal{C}_p$ and $\mathcal{D} \simeq \coprod_q \mathcal{D}_q$, and each summand is connected (Proposition 9.8). Hence $\mathcal{C} \simeq \mathcal{D}$ if and only if the two coproducts are equivalent, which by Theorem 9.6 holds if and only if the stated bijection with matching vertex groups exists. Representatives may be changed freely because a connected groupoid has isomorphic vertex groups at all objects. $\square$

**Summary.** The complete invariant of a homotopy 1-type is the pair
$$\Big(\ \pi_0(X),\ \big(\pi_1(X, x_p)\big)_{p \in \pi_0(X)}\ \Big)$$
up to bijection of the index set and isomorphism of the groups — that is, the *multiset of fundamental groups of the components*. For a connected 1-type this reduces to the single group $\pi_1$ (Corollary 6.3); for a totally disconnected one it reduces to the cardinality of $\pi_0$ (Theorem 8.8); and the counterexample of Theorem 8.4 is exactly the case of two 1-types with matching (trivial) groups and non-matching component sets.

---

## 10. Algorithms

For finite groups every statement above becomes a finite computation.

### 10.1 Enumerating homomorphisms

A homomorphism is determined by the images of a generating set $S \subseteq G$, but not every tuple of images extends. The **generator-lifting** algorithm iterates over all $|H|^{|S|}$ candidate assignments; for each, it performs a breadth-first traversal of the Cayley graph of $G$ with respect to $S$, propagating the candidate map $\hat\varphi(g \cdot s) = \hat\varphi(g)\hat\varphi(s)$ and rejecting the candidate as soon as a vertex is reached twice with conflicting values. Surviving candidates are verified on the full multiplication table. The cost is $O(|H|^{|S|} \cdot |G| \cdot |S|)$ time, which for the groups of order at most $24$ used in the demonstrations is entirely routine.

### 10.2 Homotopy classes of maps

Given $\mathrm{Hom}(G,H)$, the set $[\,K(G,1),K(H,1)\,]$ is computed by forming the conjugation orbits: repeatedly take an unclassified $\varphi$, compute $\{u\varphi(-)u^{-1} : u \in H\}$, and mark the orbit. The cost is $O(|\mathrm{Hom}(G,H)| \cdot |H| \cdot |G|)$.

### 10.3 Verifying the counting theorem

For each orbit representative $\varphi$, compute $C_H(\varphi(G))$ by scanning $H$ for elements commuting with all images, and compare $|H| / |C_H(\varphi(G))|$ with the orbit size (Theorem 5.3), and the sum of orbit sizes with $|\mathrm{Hom}(G,H)|$ (Corollary 5.4).

### 10.4 Deciding homotopy equivalence of 1-types

By Theorem 9.10, a finite 1-type is encoded by the multiset of isomorphism types of the fundamental groups of its components. Two are homotopy equivalent iff these multisets agree, which is decided by sorting canonical invariants of the groups and comparing. For the small groups used here, a canonical invariant can be taken to be the isomorphism type determined by order together with the multiset of element orders and commutativity — enough to separate the groups considered — or, in general, a full isomorphism test.

---

## 11. Discussion

Several features of this classification deserve emphasis.

**The correspondence is a genuine equivalence of theories, not a mere invariant.** The classification is complete at three levels: objects (Corollary 6.3), morphisms (Corollary 4.5), and $2$-morphisms — homotopies are conjugations (Theorem 4.2). Moreover it is compatible with composition (Theorem 4.6). This is the precise sense in which "connected homotopy 1-types = groups": one has a correspondence of entire structures, with the residual conjugation ambiguity of unbased homotopy theory appearing exactly where basepoint-change indeterminacy should appear.

**Basepoints and conjugacy are the same phenomenon.** The conjugation in Theorem 4.6(2) is not an inconvenience to be avoided but the fingerprint of unbasedness. In the based setting the classification would be a bijection with $\mathrm{Hom}(G,H)$ itself; the quotient by conjugation is precisely the price of forgetting basepoints, and Theorem 5.3 measures that price exactly, as the index of a centralizer.

**The counterexample is optimal.** Theorem 8.4 is stronger than the usual cautionary example, because it defeats not just $\pi_1$ but the whole homotopy tower. It shows that the connectivity hypothesis in Whitehead-type theorems is not a technical convenience: without it, no amount of higher homotopy data can determine homotopy type. It also identifies the exact repair, since Theorem 8.8 shows $\pi_0$ alone is complete in that degenerate regime, and Theorem 9.10 shows it is complete in general when combined with the fundamental groups.

**Everything is computable.** Because the invariant is a multiset of groups and the classification of maps is a set of conjugacy classes of homomorphisms, all the statements become finite computations for finite groups. This is not the usual situation in homotopy theory, and it is a direct consequence of the classification being *complete* rather than merely *faithful*.

**Scope.** The results concern 1-types. For a general space $X$ the fundamental groupoid computes only the $1$-truncation, and Theorem 7.3 accordingly says that path-connected spaces with isomorphic fundamental groups have equivalent fundamental groupoids — their $1$-truncations agree — which is the exact residue of Corollary 6.3 outside the aspherical world. Sphere versus point remains the standard reminder that this residue is strictly weaker than homotopy equivalence in general.

---

## 12. Future directions

Several natural continuations remain.

**Bicategorical refinement.** Functoriality has been established at the level of homomorphisms and conjugacy classes (Theorem 4.6). The full statement — that the classification is an equivalence of bicategories between connected pointed 1-types with maps and homotopies, and groups with homomorphisms and conjugations — requires coherence data (associativity and unit constraints matching up), and formulating and proving that coherence is the natural next step.

**Beyond 1-types.** The analogue for $2$-types replaces groupoids by $2$-groupoids and the invariant by a crossed module: $\pi_1$ together with $\pi_2$ and the action of the former on the latter, plus a $k$-invariant in $H^3(\pi_1; \pi_2)$. The pattern of results here — realization, homotopies-are-conjugations, Whitehead, sharpness, decomposition — suggests a template for that setting.

**Non-connected targets and homotopy classes.** Corollary 4.5 assumes both sides connected. For a non-connected target the set of homotopy classes should be a disjoint union over target components; making this precise, and combining it with Theorem 9.10, would give a complete computation of $[\mathcal{C}, \mathcal{D}]$ for arbitrary 1-types.

**Enumerative consequences.** Corollary 5.4 expresses $|\mathrm{Hom}(G,H)|$ as a sum of centralizer indices. Systematic study of this decomposition — for instance for $G$ cyclic, where $\mathrm{Hom}(G,H)$ is the set of elements of order dividing $|G|$ and the classification counts conjugacy classes of such elements — links the homotopy-theoretic count to classical counting theorems in finite group theory, of the Frobenius type.

**Infinite and topological groups.** The arguments use only the group structure and choice of paths, so they apply verbatim to arbitrary (possibly infinite) groups. Extending them to topological groups and topological groupoids, where "conjugacy class" acquires a topology and the classification becomes a statement about mapping spaces rather than sets, is a further direction.
