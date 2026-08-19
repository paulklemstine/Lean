# The Pointed Classification of Maps of Homotopy 1-Types and the Exact Fibres of Basepoint Forgetting

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

Homotopy $1$-types are modelled faithfully by groupoids: a connected $1$-type with fundamental group $G$ is modelled by the one-object groupoid $K(G,1)$ whose arrows are the elements of $G$. The classical unpointed classification asserts that homotopy classes of maps between connected $1$-types with fundamental groups $G$ and $H$ are in bijection with $\operatorname{Hom}(G,H)$ modulo conjugation by $H$. The quotient by conjugation is the source of two structural defects: the classification is functorial only up to conjugacy, and the group of homotopy self-equivalences of $K(G,1)$ comes out as $\operatorname{Out}(G)$ rather than $\operatorname{Aut}(G)$.

We show that both defects vanish, and that their magnitude is computable exactly, once basepoints are retained. The technical instrument is a *prescribed-value homotopy lemma*: for a connected source, any isomorphism $h : F(x) \to G(x)$ in the target that intertwines the two induced fundamental-group actions extends to a homotopy $F \Rightarrow G$ whose component at the basepoint is literally $h$. From it we obtain:

1. **The pointed classification.** For a connected pointed $1$-type $(X,x)$ with $\pi_1(X,x) = G$ and an *arbitrary* pointed $1$-type $(Y,y)$ with $\pi_1(Y,y) = H$, the induced-homomorphism map is a bijection $[(X,x),(Y,y)]_* \cong \operatorname{Hom}(G,H)$, with no quotient and no connectedness assumption on the target.
2. **Strict functoriality.** Identities induce identities and composites induce composites *on the nose*; pointed self-map classes form a monoid isomorphic to $\operatorname{End}(G)$, whose unit group is $\operatorname{Aut}(G)$, and a pointed class is invertible iff it is represented by a homotopy equivalence (pointed Whitehead theorem, monoid form).
3. **The fibre count.** The forgetful map $[(X,x),(Y,y)]_* \to [X,Y]$ is surjective with fibre over the class of a map inducing $\varphi$ of cardinality exactly $[H : C_H(\varphi(G))]$, uniformly in the basepoint. Over the identity class this is $[G : Z(G)] = |\operatorname{Inn}(G)|$, reconciling $\operatorname{Aut}(G)$ with $\operatorname{Out}(G)$. For abelian $H$ every fibre is a singleton.
4. **A decisive finite test.** For $G = H = S_3$ the three fibres have sizes $1$, $3$ and $6$ — in particular the identity map of $K(S_3,1)$ carries six pairwise non-pointed-homotopic pointed structures — matching the orbit sizes of the conjugation action of $S_3$ on the ten endomorphisms of $S_3$.

**Keywords:** homotopy $1$-type, Eilenberg–MacLane space, groupoid, fundamental group, pointed homotopy, centraliser index, outer automorphism group, Whitehead theorem.

---

## 1. Introduction

### 1.1 The problem

The fundamental group is attached not to a space but to a pointed space. For a path-connected $X$, a path $\gamma$ from $x$ to $x'$ induces an isomorphism $\pi_1(X,x) \to \pi_1(X,x')$, but this isomorphism depends on $\gamma$, and two choices differ by conjugation by the loop $\gamma \gamma'^{-1}$. Thus "the fundamental group of a connected space" is well defined only as a group up to a non-canonical isomorphism, and self-comparisons are ambiguous by an inner automorphism.

The ambiguity propagates to the classification of maps. If $X$ and $Y$ are aspherical — i.e. homotopy $1$-types, $X \simeq K(G,1)$ and $Y \simeq K(H,1)$ — then the classical theorem reads
$$[X, Y] \;\cong\; \operatorname{Hom}(G,H)/\text{conjugation by } H. \tag{1.1}$$
The conjugation quotient is forced: an unpointed map does not determine a homomorphism of fundamental groups until one chooses a path from $f(x)$ to the basepoint of $Y$.

Two consequences are structurally unpleasant.

- **Failure of strict functoriality.** For composable maps $f, g$, the homomorphism induced by $g \circ f$ is only *conjugate* to $g_\# \circ f_\#$; the classification (1.1) assembles into a family of bijections compatible with composition only after passing to conjugacy classes, and the comparison data (the conjugators) are choice-dependent.
- **$\operatorname{Out}$ instead of $\operatorname{Aut}$.** The monoid of unpointed self-map classes of $K(G,1)$ is the monoid of conjugacy classes of endomorphisms of $G$, and its unit group is $\operatorname{Out}(G) = \operatorname{Aut}(G)/\operatorname{Inn}(G)$. The inner automorphisms have been quotiented away, and the classification cannot see them.

### 1.2 The results

This paper resolves both issues and, more importantly, *quantifies* the difference. We work throughout in the groupoid model of $1$-types (Section 2), where everything is elementary and exact.

The technical heart is Theorem 3.1 (the *prescribed-homotopy lemma*), which strengthens the usual "conjugate homomorphisms give homotopic maps" statement by fixing the value of the homotopy at the basepoint. Everything else follows.

Section 4 introduces pointed maps and pointed homotopies and proves the pointed classification (Theorem 4.6):
$$[(X,x),(Y,y)]_* \;\cong\; \operatorname{Hom}\bigl(\pi_1(X,x), \pi_1(Y,y)\bigr),$$
valid for connected $(X,x)$ and *arbitrary* $(Y,y)$.

Section 5 establishes strict functoriality, the monoid structure ($\operatorname{End}(G)$), the pointed Whitehead theorem, and the pointed self-equivalence group ($\operatorname{Aut}(G)$).

Section 6 compares the two theories through the basepoint-forgetting map and proves the fibre-counting theorem (Theorem 6.4):
$$\bigl|\,\text{fibre over the class of } \varphi\,\bigr| \;=\; \bigl[\,H : C_H(\varphi(G))\,\bigr].$$

Section 7 carries out the finite test for $S_3$ (fibre sizes $1,3,6$) and the abelian antipode.

Section 8 gives algorithms and complexity; Section 9 discusses applications; Section 10 lists open directions.

### 1.3 Relation to classical topology

None of the ingredients is exotic; what is new is the level of precision. Classically one knows that "with basepoints, $[X,Y]_* \cong \operatorname{Hom}(\pi_1 X, \pi_1 Y)$ for aspherical $Y$", and that the difference between pointed and free classes is an action of $\pi_1(Y)$. The contributions here are: (i) a proof from a single clean lemma with prescribed basepoint value, in a model where all statements are equalities rather than natural transformations up to coherence; (ii) the removal of the connectedness hypothesis on the target; (iii) the exact and *uniform* fibre count by centraliser index, with the extremal cases (identity map, abelian target) worked out; and (iv) the decisive finite verification for $S_3$.

---

## 2. The groupoid model of homotopy 1-types

### 2.1 Groupoids as spaces

**Definition 2.1 (Groupoid).** A *groupoid* is a category $C$ in which every morphism is invertible. We write $\operatorname{Hom}_C(a,b)$ for the arrows $a \to b$ and $\operatorname{Aut}(c) = \operatorname{Hom}_C(c,c)$, a group under composition, called the *vertex group* at $c$.

The fundamental groupoid $\Pi_1(X)$ of a topological space has the points of $X$ as objects and homotopy classes rel endpoints of paths as arrows. It is the universal receptacle for $1$-dimensional homotopy information: two spaces have equivalent fundamental groupoids exactly when they have the same homotopy $1$-type. We therefore adopt the following dictionary and use it without further comment.

| Topology | Groupoid theory |
|---|---|
| homotopy $1$-type $X$ | groupoid $C$ |
| point of $X$ | object $c$ of $C$ |
| $\pi_0(X)$ | set of connected components of $C$ |
| $\pi_1(X,x)$ | vertex group $\operatorname{Aut}(c)$ |
| path-connected | connected groupoid |
| map $X \to Y$ | functor $F : C \to D$ |
| homotopy $f \simeq g$ | natural isomorphism $F \cong G$ |
| homotopy equivalence | equivalence of groupoids |
| $K(G,1)$ | one-object groupoid $\mathrm{B}G$ with $\operatorname{Aut}(\star) = G$ |

**Definition 2.2 (Connectedness at a basepoint).** A groupoid $C$ is *connected at* $c \in C$ if for every object $X$ there exists an isomorphism $c \to X$. We fix, once and for all, a choice of such an arrow and write $\gamma_X : c \to X$ for it, with $\gamma_c = \mathrm{id}_c$ where convenient. This choice is the model-theoretic incarnation of "choosing a path from the basepoint to each point".

**Definition 2.3 (Loop associated with an arrow).** For an arrow $f : X \to Y$ in a groupoid connected at $c$, set
$$\ell(f) \;=\; \gamma_X \, f \, \gamma_Y^{-1} \;\in\; \operatorname{Aut}(c),$$
the loop at the basepoint obtained by closing $f$ up through the chosen paths.

**Definition 2.4 (The model $K(G,1)$).** For a group $G$, let $\mathrm{B}G$ denote the groupoid with a single object $\star$ and $\operatorname{Hom}(\star,\star) = G$, composition being multiplication. It is connected, and $\operatorname{Aut}(\star) \cong G$ canonically. Every connected $1$-type is equivalent to $\mathrm{B}G$ for $G$ its fundamental group.

**Definition 2.5 (Induced map on vertex groups).** A functor $F : C \to D$ restricts to a group homomorphism
$$F_* : \operatorname{Aut}(c) \longrightarrow \operatorname{Aut}(F(c)), \qquad a \longmapsto F(a).$$
For unpointed purposes one must further transport $\operatorname{Aut}(F(c))$ to a fixed vertex group of $D$ along a chosen arrow, and it is exactly that choice which produces the conjugation ambiguity.

### 2.2 Realization of homomorphisms

**Proposition 2.6 (Realization).** Let $C$ be connected at $c$, let $D$ be a groupoid, $d \in D$, and $\varphi : \operatorname{Aut}(c) \to \operatorname{Aut}(d)$ a homomorphism. Then there is a functor $R_\varphi : C \to D$ with $R_\varphi(X) = d$ for all $X$ and
$$R_\varphi(f) \;=\; \varphi(\ell(f)) \quad\text{for every arrow } f.$$
In particular $R_\varphi(a) = \varphi(a)$ for $a \in \operatorname{Aut}(c)$.

*Proof sketch.* Functoriality on composites follows from $\ell(fg) = \ell(f)\ell(g)$ (the chosen paths cancel in the middle) and $\ell(\mathrm{id}) = \mathrm{id}$; apply $\varphi$. $\square$

Realization gives surjectivity of every classification statement below: every homomorphism is induced by an actual map. Note that $R_\varphi$ is *constant on objects*; this is what allows the target to be disconnected without harm.

---

## 3. Homotopies with a prescribed value at the basepoint

The following is the technical foundation of the paper. The classical statement produces *some* natural isomorphism between two functors whose induced homomorphisms are conjugate. We need to control its component at the basepoint.

**Theorem 3.1 (Prescribed-homotopy lemma).** Let $C$ be a groupoid connected at $c$, let $D$ be a groupoid, and let $F, G : C \to D$ be functors. Let
$$h : F(c) \xrightarrow{\ \cong\ } G(c)$$
be an isomorphism in $D$ satisfying the *intertwining condition*
$$F(a) \, h \;=\; h \, G(a) \qquad \text{for all } a \in \operatorname{Aut}(c). \tag{3.1}$$
Then there is a natural isomorphism $\eta : F \Rightarrow G$ with $\eta_c = h$.

*Proof.* Using the chosen arrows $\gamma_X : c \to X$ of Definition 2.2, define
$$\eta_X \;=\; F(\gamma_X)^{-1} \; h \; G(\gamma_X) \;:\; F(X) \to G(X).$$
Each $\eta_X$ is an isomorphism, being a composite of isomorphisms. For naturality, let $f : X \to Y$ be any arrow and put $a = \ell(f) = \gamma_X f \gamma_Y^{-1} \in \operatorname{Aut}(c)$. The intertwining condition (3.1) for $a$ reads
$$F(\gamma_X) F(f) F(\gamma_Y)^{-1} \, h \;=\; h \, G(\gamma_X) G(f) G(\gamma_Y)^{-1}.$$
Pre-composing with $F(\gamma_X)^{-1}$ and post-composing with $G(\gamma_Y)$ gives
$$F(f) \, F(\gamma_Y)^{-1} h \, G(\gamma_Y) \;=\; F(\gamma_X)^{-1} h \, G(\gamma_X) \, G(f),$$
that is, $F(f)\,\eta_Y = \eta_X\,G(f)$, which is exactly the naturality square. Finally, $\gamma_c$ may be taken to be $\mathrm{id}_c$, so $\eta_c = h$. $\square$

**Remark 3.2.** The intertwining condition (3.1) says precisely that conjugation by $h$ carries the homomorphism $a \mapsto F(a)$ to $a \mapsto G(a)$. Thus Theorem 3.1 is the statement: *conjugating data at the basepoint is realized by a homotopy that performs exactly that conjugation at the basepoint*. Existing formulations produce a homotopy realizing the conjugation up to an unspecified further loop; the surgical improvement here is what makes the pointed theory strict.

**Remark 3.3.** Connectedness of $C$ is used exactly once, to have the arrows $\gamma_X$; the target $D$ is unconstrained. This is why the pointed classification will hold for arbitrary targets.

---

## 4. Pointed maps and the pointed classification

### 4.1 Definitions

**Definition 4.1 (Pointed map).** Let $(C,c)$ and $(D,d)$ be pointed groupoids. A *pointed map* $P : (C,c) \to (D,d)$ consists of

- a functor $P^{\mathrm{f}} : C \to D$ (the underlying map), and
- an isomorphism $p : P^{\mathrm{f}}(c) \xrightarrow{\cong} d$ (the *chosen path*).

Topologically: a map together with a chosen path from the image of the basepoint to the basepoint.

**Definition 4.2 (Induced homomorphism).** The homomorphism of fundamental groups induced by a pointed map $P = (P^{\mathrm{f}}, p)$ is
$$P_\# : \operatorname{Aut}(c) \longrightarrow \operatorname{Aut}(d), \qquad P_\#(a) \;=\; p^{-1}\, P^{\mathrm{f}}(a)\, p .$$
It is a group homomorphism, being the composite of $F_*$ with conjugation by $p$. **No choice is involved**: the path is part of the data.

**Definition 4.3 (Pointed homotopy).** Two pointed maps $P, Q : (C,c) \to (D,d)$ are *pointed homotopic*, written $P \simeq_* Q$, if there is a natural isomorphism $\alpha : P^{\mathrm{f}} \Rightarrow Q^{\mathrm{f}}$ with
$$\alpha_c \, q \;=\; p, \tag{4.1}$$
i.e. the homotopy at the basepoint, followed by $Q$'s chosen path, is $P$'s chosen path.

**Proposition 4.4.** $\simeq_*$ is an equivalence relation. Reflexivity uses the identity natural isomorphism; symmetry inverts $\alpha$ and rearranges (4.1); transitivity composes and uses (4.1) twice. We write $[(C,c),(D,d)]_*$ for the quotient set of pointed homotopy classes.

### 4.2 The induced homomorphism is a complete invariant

**Proposition 4.5 (Invariance).** If $P \simeq_* Q$ then $P_\# = Q_\#$ — an equality of homomorphisms, not merely a conjugacy.

*Proof.* Let $\alpha$ realize the pointed homotopy, so $\alpha_c q = p$ and hence $p^{-1} = q^{-1}\alpha_c^{-1}$. For $a \in \operatorname{Aut}(c)$, naturality of $\alpha$ at $a$ gives $P^{\mathrm{f}}(a)\,\alpha_c = \alpha_c\, Q^{\mathrm{f}}(a)$. Therefore
$$P_\#(a) = p^{-1}P^{\mathrm{f}}(a) p = q^{-1}\alpha_c^{-1} P^{\mathrm{f}}(a)\, \alpha_c q = q^{-1} Q^{\mathrm{f}}(a) q = Q_\#(a). \qquad \square$$

**Theorem 4.6 (Pointed classification).** Let $(C,c)$ be a pointed groupoid *connected at $c$*, and let $(D,d)$ be an **arbitrary** pointed groupoid. Then
$$\Phi : [(C,c),(D,d)]_* \longrightarrow \operatorname{Hom}\bigl(\operatorname{Aut}(c), \operatorname{Aut}(d)\bigr), \qquad [P] \longmapsto P_\#$$
is a bijection. Its inverse sends $\varphi$ to the class of the *pointed realization* $\widehat{R}_\varphi = (R_\varphi, \mathrm{id}_d)$ of Proposition 2.6.

*Proof.* $\Phi$ is well defined by Proposition 4.5.

*Surjectivity.* For $\varphi : \operatorname{Aut}(c) \to \operatorname{Aut}(d)$ the pointed realization $\widehat{R}_\varphi$ has $(\widehat{R}_\varphi)_\#(a) = \mathrm{id}_d^{-1} R_\varphi(a)\, \mathrm{id}_d = \varphi(a)$, so $\Phi[\widehat{R}_\varphi] = \varphi$.

*Injectivity.* Suppose $P_\# = Q_\#$. Put $h = p\,q^{-1} : P^{\mathrm{f}}(c) \to Q^{\mathrm{f}}(c)$. For $a \in \operatorname{Aut}(c)$, the hypothesis $p^{-1}P^{\mathrm{f}}(a)p = q^{-1}Q^{\mathrm{f}}(a)q$ rearranges to
$$P^{\mathrm{f}}(a) \, p q^{-1} \;=\; p q^{-1} \, Q^{\mathrm{f}}(a),$$
which is exactly the intertwining condition (3.1) for $h$. By Theorem 3.1 there is a natural isomorphism $\eta : P^{\mathrm{f}} \Rightarrow Q^{\mathrm{f}}$ with $\eta_c = h = pq^{-1}$; then $\eta_c q = p q^{-1} q = p$, so $\eta$ witnesses $P \simeq_* Q$. $\square$

**Corollary 4.7.** For connected $1$-types $K(G,1)$ and any $1$-type $Y$ with $\pi_1(Y,y) = H$,
$$[(K(G,1),\star), (Y,y)]_* \;\cong\; \operatorname{Hom}(G,H).$$
In particular the set of pointed homotopy classes carries no residual symmetry: distinct homomorphisms give pointed-non-homotopic maps.

**Remark 4.8 (Sharpness).** Connectedness of the *source* cannot be dropped. A functor out of a disconnected groupoid is determined componentwise, and its behaviour on components other than the one containing $c$ is invisible to $\operatorname{Aut}(c)$; the classification then requires the data of a target component and a homomorphism for each source component.

---

## 5. Strict functoriality, the endomorphism monoid, and the pointed Whitehead theorem

### 5.1 Composition

**Definition 5.1.** The *identity* pointed map of $(C,c)$ is $\mathbf{1}_{(C,c)} = (\mathrm{id}_C, \mathrm{id}_c)$. The *composite* of $P : (C,c) \to (D,d)$ and $Q : (D,d) \to (E,e)$ is
$$P \ast Q \;=\; \bigl(P^{\mathrm{f}} \,;\, Q^{\mathrm{f}},\; Q^{\mathrm{f}}(p)\, q\bigr),$$
i.e. the composite functor, with chosen path "apply $Q$ to $P$'s path, then follow $Q$'s path".

**Theorem 5.2 (Strict functoriality).** For all pointed maps as above,
$$(\mathbf{1}_{(C,c)})_\# = \mathrm{id}_{\operatorname{Aut}(c)}, \qquad (P \ast Q)_\# \;=\; Q_\# \circ P_\# .$$
Both are equalities of homomorphisms.

*Proof.* The first is immediate. For the second, for $a \in \operatorname{Aut}(c)$,
$$(P\ast Q)_\#(a) = \bigl(Q^{\mathrm{f}}(p)q\bigr)^{-1} Q^{\mathrm{f}}\bigl(P^{\mathrm{f}}(a)\bigr) \bigl(Q^{\mathrm{f}}(p) q\bigr) = q^{-1} Q^{\mathrm{f}}\bigl(p^{-1} P^{\mathrm{f}}(a) p\bigr) q = Q_\#\bigl(P_\#(a)\bigr),$$
using functoriality of $Q^{\mathrm{f}}$ to absorb the conjugation. $\square$

This is precisely the statement that fails in the unpointed theory, where the corresponding identity holds only after conjugating by an element depending on the choices of transport paths.

**Proposition 5.3.** Composition respects pointed homotopy: if $P \simeq_* P'$ and $Q \simeq_* Q'$ then $P \ast Q \simeq_* P' \ast Q'$. (Whisker the two homotopies together, $\alpha \ast \beta = (\alpha Q^{\mathrm{f}}) ; (P'^{\mathrm{f}} \beta)$, and verify the basepoint condition using naturality of $\beta$ at $p'$.) Hence composition descends to a well-defined operation on pointed homotopy classes, and under the bijection of Theorem 4.6 it corresponds exactly to composition of homomorphisms.

### 5.2 The monoid of pointed self-maps

**Theorem 5.4 (Monoid structure).** For a groupoid $C$ connected at $c$, the set $[(C,c),(C,c)]_*$ of pointed homotopy classes of pointed self-maps is a monoid under composition (associativity and unitality hold up to pointed homotopy, hence strictly on classes), and
$$[(C,c),(C,c)]_* \;\cong\; \operatorname{End}\bigl(\operatorname{Aut}(c)\bigr)$$
as monoids, via $[P] \mapsto P_\#$.

*Proof.* Associativity and unitality of $\ast$ hold up to canonical pointed homotopy (the identity natural isomorphism, with the basepoint condition an identity of composites of chosen paths). The map $[P] \mapsto P_\#$ is a bijection by Theorem 4.6 and multiplicative by Theorem 5.2. $\square$

By contrast, the unpointed monoid of self-map classes of $K(G,1)$ is the monoid of *conjugacy classes* of endomorphisms of $G$ — a genuine quotient, as the $S_3$ computation in Section 7 makes explicit.

### 5.3 Whitehead's theorem, pointed

**Theorem 5.5 (Pointed Whitehead theorem).** Let $C$ be connected at $c$ and let $P$ be a pointed self-map of $(C,c)$. The following are equivalent:

1. the underlying functor $P^{\mathrm{f}}$ is an equivalence of groupoids;
2. the induced endomorphism $P_\# : \operatorname{Aut}(c) \to \operatorname{Aut}(c)$ is bijective;
3. the class $[P]$ is a unit of the monoid $[(C,c),(C,c)]_*$.

*Proof sketch.* $(1) \Leftrightarrow (2)$: $P_\#$ is the composite of $F_* : \operatorname{Aut}(c) \to \operatorname{Aut}(P^{\mathrm{f}}(c))$ with the isomorphism induced by conjugating along $p$; the latter is always bijective, so bijectivity of $P_\#$ is bijectivity of $F_*$. An equivalence induces bijections on all vertex groups; conversely, a functor between connected groupoids inducing a bijection on one vertex group is essentially surjective (connectedness of the target at $P^{\mathrm{f}}(c)$, which follows from connectedness of $C$ and the chosen path) and fully faithful (every hom-set is a torsor over the vertex group, and the transport arrows identify $\operatorname{Hom}(X,Y)$ with $\operatorname{Aut}(c)$). $(2) \Leftrightarrow (3)$: under the monoid isomorphism of Theorem 5.4, units of $\operatorname{End}(G)$ are exactly the bijective endomorphisms, i.e. $\operatorname{Aut}(G)$. $\square$

**Corollary 5.6 (Pointed self-equivalence group).** The group of pointed homotopy classes of pointed self-homotopy-equivalences of a connected $1$-type with fundamental group $G$ is
$$\bigl([(C,c),(C,c)]_*\bigr)^{\times} \;\cong\; \operatorname{Aut}(G).$$

This should be contrasted with the classical unpointed computation: the group of unpointed homotopy classes of self-homotopy-equivalences of $K(G,1)$ is $\operatorname{Out}(G) = \operatorname{Aut}(G)/\operatorname{Inn}(G)$. Section 6 explains the discrepancy exactly.

---

## 6. Forgetting the basepoint: the exact fibres

### 6.1 The comparison map

**Definition 6.1.** *Forgetting the basepoint* is the map
$$\pi : [(C,c),(D,d)]_* \longrightarrow [C,D], \qquad [P] \longmapsto [P^{\mathrm{f}}],$$
where $[C,D]$ denotes unpointed homotopy classes (natural isomorphism classes) of functors. It is well defined because a pointed homotopy is in particular a homotopy.

**Proposition 6.2 (Fibres are conjugation orbits).** Let $C$ be connected at $c$ and $P, Q$ pointed maps $(C,c) \to (D,d)$. Then
$$\pi[P] = \pi[Q] \iff \exists\, u \in \operatorname{Aut}(d) \ \ \forall a \in \operatorname{Aut}(c): \; Q_\#(a) = u\, P_\#(a)\, u^{-1}.$$

*Proof.* ($\Rightarrow$) A natural isomorphism $\alpha : P^{\mathrm{f}} \Rightarrow Q^{\mathrm{f}}$ gives, at the basepoint, an isomorphism $\alpha_c$; setting $u = q^{-1}\alpha_c^{-1} p$, naturality yields the displayed conjugation identity — this is the standard computation showing that path-transport changes the induced homomorphism by conjugation.

($\Leftarrow$) By Theorem 4.6, $P^{\mathrm{f}}$ is homotopic (even pointed-homotopic after replacing $P$ by its realization) to $R_{P_\#}$ and $Q^{\mathrm{f}}$ to $R_{Q_\#}$. It therefore suffices to know that $R_\varphi \cong R_\psi$ whenever $\varphi$ and $\psi$ are conjugate, which is Theorem 3.1 applied with $h = u$ (the intertwining condition is exactly $\psi(a) = u\varphi(a)u^{-1}$). $\square$

**Corollary 6.3.** Under the bijections of Theorem 4.6 and the unpointed classification (1.1), $\pi$ is identified with the canonical quotient map
$$\operatorname{Hom}(G,H) \twoheadrightarrow \operatorname{Hom}(G,H)/H\text{-conjugation}.$$
In particular $\pi$ is surjective: every unpointed class admits a pointed refinement.

### 6.2 The count

**Theorem 6.4 (Fibre-counting theorem).** Let $C$ be connected at $c$ with $G = \operatorname{Aut}(c)$, let $(D,d)$ be a pointed groupoid with $H = \operatorname{Aut}(d)$, and let $\varphi : G \to H$ be a homomorphism. Then the fibre of $\pi$ over the unpointed class of a map inducing $\varphi$ satisfies
$$\bigl|\pi^{-1}\bigl([\,R_\varphi\,]\bigr)\bigr| \;=\; \bigl[\,H : C_H(\varphi(G))\,\bigr],$$
the index in $H$ of the centraliser of the image of $\varphi$. The count depends only on $\varphi$, not on the models or the basepoints.

*Proof.* By Theorem 4.6 the fibre is in bijection with $\{\psi \in \operatorname{Hom}(G,H) : \psi \text{ is } H\text{-conjugate to } \varphi\}$, i.e. with the orbit of $\varphi$ under the conjugation action of $H$ on $\operatorname{Hom}(G,H)$, $(u \cdot \varphi)(g) = u\varphi(g)u^{-1}$. The stabiliser of $\varphi$ is
$$\operatorname{Stab}_H(\varphi) = \{u \in H : u\varphi(g)u^{-1} = \varphi(g)\ \forall g\} = \{u : u \text{ commutes with every element of } \varphi(G)\} = C_H(\varphi(G)).$$
By the orbit–stabiliser theorem the orbit is in bijection with the coset space $H/C_H(\varphi(G))$, whose cardinality is the index. $\square$

**Corollary 6.5 (Over the identity).** Taking $C = D$, $c = d$, $G = H$ and $\varphi = \mathrm{id}_G$, the image is all of $G$ and $C_G(G) = Z(G)$, so
$$\bigl|\pi^{-1}([\mathrm{id}])\bigr| \;=\; [\,G : Z(G)\,] \;=\; |\operatorname{Inn}(G)|.$$
This is exactly the kernel size of the surjection $\operatorname{Aut}(G) \twoheadrightarrow \operatorname{Out}(G)$, reconciling Corollary 5.6 with the unpointed answer: the pointed self-equivalence group $\operatorname{Aut}(G)$ maps onto the unpointed one $\operatorname{Out}(G)$ with fibres the cosets of $\operatorname{Inn}(G)$.

**Corollary 6.6 (Abelian target).** If $H = \operatorname{Aut}(d)$ is abelian then every centraliser is $H$, every index is $1$, and $\pi$ is injective. Equivalently: for a target $1$-type with abelian fundamental group — a circle, a torus, any $K(A,1)$ with $A$ abelian — the pointed and unpointed classifications of maps out of a connected $1$-type coincide, and basepoints carry no information.

*Direct proof.* If $Q_\#(a) = u P_\#(a) u^{-1}$ with $H$ commutative, then $Q_\# = P_\#$, so $[P] = [Q]$ by Theorem 4.6. $\square$

**Remark 6.7 (Interpretation).** Corollary 6.6 explains why the basepoint issue is invisible in the first examples every topologist meets. Maps into the circle are classified by $H^1(X;\mathbb{Z}) = \operatorname{Hom}(\pi_1 X, \mathbb{Z})$ with no conjugation quotient; degrees of self-maps of the torus are integer matrices with no ambiguity. Non-commutativity of the target fundamental group is precisely the source of basepoint dependence.

---

## 7. The decisive finite test: $G = H = S_3$

We now instantiate the theory at the smallest non-abelian group, $S_3 = \operatorname{Sym}(\{0,1,2\})$, of order $6$, with trivial centre and trivial outer automorphism group. Write $\tau = (0\,1)$ and $\operatorname{sgn} : S_3 \to \{\pm 1\}$ for the sign character. Work with the model $K(S_3,1) = \mathrm{B}S_3$ and its unique object $\star$, so $\operatorname{Aut}(\star) \cong S_3$.

### 7.1 The endomorphisms of $S_3$

**Lemma 7.1.** $|\operatorname{Hom}(S_3,S_3)| = 10$, distributed as follows:

- the trivial homomorphism ($1$ of them);
- homomorphisms with image of order $2$: these kill the alternating subgroup $A_3$ (the only normal subgroup of index $2$) and send the odd permutations to a fixed transposition; since there are $3$ transpositions there are $3$ such maps. A representative is
  $$\sigma : g \longmapsto \begin{cases} 1 & \operatorname{sgn}(g) = +1,\\ \tau & \operatorname{sgn}(g) = -1;\end{cases}$$
- automorphisms: $\operatorname{Aut}(S_3) \cong S_3$ (all automorphisms are inner because $Z(S_3)=1$ and $\operatorname{Out}(S_3)=1$), giving $6$ of them.

There are no homomorphisms with image of order $3$: such a map would have kernel of order $2$, but no subgroup of order $2$ in $S_3$ is normal. Total: $1 + 3 + 6 = 10$.

**Lemma 7.2 (Centre and centralisers).** $Z(S_3) = \{1\}$; $C_{S_3}(\{1\}) = S_3$ (order $6$); $C_{S_3}(\{1,\tau\}) = \{1,\tau\}$ (order $2$), since an element commuting with a transposition must preserve its support pointwise or setwise, leaving only $1$ and $\tau$ itself.

### 7.2 The three fibres

Applying Theorem 6.4 with $G = H = S_3$:

**Theorem 7.3 (Fibre over the constant map).** The fibre of $\pi$ over the unpointed class of the constant self-map of $K(S_3,1)$ has exactly
$$[\,S_3 : C_{S_3}(\{1\})\,] = 6/6 = \mathbf{1}$$
element. The constant map has an essentially unique pointed refinement.

**Theorem 7.4 (Fibre over the order-two map).** The fibre over the unpointed class of the map inducing $\sigma$ (image $\{1,\tau\}$, of order $2$) has exactly
$$[\,S_3 : C_{S_3}(\{1,\tau\})\,] = 6/2 = \mathbf{3}$$
elements — one for each of the three transposition subgroups into which the sign character can be composed.

**Theorem 7.5 (Fibre over the identity).** The fibre over the unpointed class of the identity map of $K(S_3,1)$ has exactly
$$[\,S_3 : Z(S_3)\,] = 6/1 = \mathbf{6}$$
elements: the identity map admits six pairwise non-pointed-homotopic pointed structures, corresponding to the six inner automorphisms of $S_3$, all of which become homotopic as soon as the basepoint is forgotten.

The three numbers $1$, $3$, $6$ sum to $10 = |\operatorname{Hom}(S_3,S_3)|$, as required by Corollary 6.3, and they are exactly the orbit sizes of the conjugation action of $S_3$ on $\operatorname{Hom}(S_3,S_3)$.

**Summary table.**

| unpointed class | representative $\varphi$ | $\varphi(S_3)$ | $\lvert C_{S_3}(\varphi(S_3))\rvert$ | pointed classes above it |
|---|---|---|---|---|
| constant | trivial | $\{1\}$ | $6$ | $1$ |
| sign-and-swap | $\sigma$ | $\{1,\tau\}$ | $2$ | $3$ |
| identity | $\mathrm{id}$ | $S_3$ | $1$ | $6$ |
| **total** | | | | $\mathbf{10}$ |

**Corollary 7.6.** The pointed classification is *strictly* finer than the unpointed classification: $K(S_3,1)$ has $10$ pointed self-map classes but only $3$ unpointed ones. Its pointed self-equivalence group is $\operatorname{Aut}(S_3) \cong S_3$ of order $6$, while its unpointed self-equivalence group is $\operatorname{Out}(S_3) = 1$.

### 7.3 The abelian antipode

**Theorem 7.7.** Let $A$ be an abelian group and $(C,c)$ any connected pointed $1$-type. Then forgetting the basepoint is injective on $[(C,c),(K(A,1),\star)]_*$; in particular, for $A = \mathbb{Z}/n$ the pointed and unpointed classifications of maps into $K(\mathbb{Z}/n,1)$ agree exactly.

This is Corollary 6.6 applied to the model $\mathrm{B}A$, whose vertex group is $A$. The contrast with Theorem 7.5 — six versus one — is the whole content of the theory in a single comparison.

---

## 8. Algorithms and complexity

All the quantities above are effectively computable for finite groups. We record the three primitive algorithms.

### 8.1 Enumerating $\operatorname{Hom}(G,H)$

Choose a generating set $g_1,\dots,g_k$ of $G$ (greedily, by adding elements outside the current span). For each tuple $(h_1,\dots,h_k) \in H^k$, attempt to extend $g_i \mapsto h_i$ to a function on $G$ by a breadth-first closure of the Cayley graph: maintain a partial map $\varphi$ with $\varphi(1)=1$, and whenever $x$ is assigned, assign $xg_i \mapsto \varphi(x)h_i$, aborting on any conflict. If the closure covers $G$ without conflict, the resulting map is a homomorphism (well-definedness of the closure is exactly the relation-checking). Cost: $O(|H|^k \cdot |G| k)$ in the worst case, with $k \le \log_2|G|$.

### 8.2 Centraliser and index

$C_H(S) = \{x \in H : xs = sx \ \forall s \in S\}$ is computed by a scan, in $O(|H|\,|S|)$ group multiplications; the index is $|H|/|C_H(S)|$ by Lagrange.

### 8.3 The fibre count

Given $\varphi$, compute $\operatorname{im}\varphi$ (a scan of $G$), then $C_H(\operatorname{im}\varphi)$, then the index. Cost $O(|G| + |H|\,|\operatorname{im}\varphi|)$. Note that this is *far* cheaper than computing the orbit of $\varphi$ directly, which costs $O(|H|\,|G|)$ map constructions plus hashing: Theorem 6.4 converts an orbit enumeration into a subgroup index.

### 8.4 Verification protocol

To check Theorem 6.4 experimentally for a pair $(G,H)$: enumerate $\operatorname{Hom}(G,H)$; partition it into conjugation orbits by explicit action; and for one representative of each orbit compare the orbit size with the centraliser index. The number of unpointed classes is the number of orbits and the number of pointed classes is $|\operatorname{Hom}(G,H)|$. This protocol confirms the theorem for all the small pairs one cares to test, and in particular reproduces $1,3,6$ for $(S_3,S_3)$.

---

## 9. Applications and interpretation

**9.1 Covering space theory.** Connected pointed coverings of a nice pointed space $(X,x)$ correspond to subgroups of $\pi_1(X,x)$; unpointed coverings correspond to *conjugacy classes* of subgroups. The dictionary is the same one studied here: the number of pointed coverings above a given unpointed covering with subgroup $K$ is $[\pi_1(X,x) : N(K)]$, the analogous orbit count for the conjugation action on subgroups. The theorems above are the "map" version of this familiar "subobject" phenomenon.

**9.2 $\operatorname{Aut}$ versus $\operatorname{Out}$ and group extensions.** Non-abelian group extensions $1 \to N \to E \to Q \to 1$ are governed by an *outer* action $Q \to \operatorname{Out}(N)$, and lifting it to a homomorphism $Q \to \operatorname{Aut}(N)$ is obstructed. Corollary 6.5 identifies the ambiguity in that lift with the fibre of the basepoint-forgetting map over the identity class, of size $[N : Z(N)]$; the classifying-space avatar of the extension problem is precisely the pointed-versus-unpointed distinction for maps of $K(\cdot,1)$'s.

**9.3 Gauge theory and flat connections.** A flat principal $H$-bundle on a space with fundamental group $G$ is given by a holonomy homomorphism $\varphi : G \to H$; two holonomies related by a global gauge transformation ($H$-conjugation) define isomorphic bundles. The moduli set is $\operatorname{Hom}(G,H)/H$ and the stabiliser $C_H(\varphi(G))$ is the *unbroken symmetry group* of the connection. Theorem 6.4 is then the statement that the number of framings of a flat bundle, modulo those that extend to gauge equivalences, is the index of the unbroken subgroup.

**9.4 Rigidity of aspherical spaces.** Corollary 5.6 and Theorem 5.5 combine into a strong rigidity statement: the pointed homotopy theory of aspherical spaces is *isomorphic*, not merely equivalent, to the algebra of their fundamental groups. Every construction on groups that is functorial — endomorphism monoids, automorphism groups, homomorphism sets — has a literal counterpart in pointed homotopy classes, with no coherence data to track.

**9.5 Computational topology.** Deciding homotopy equivalence, counting homotopy classes of maps, or enumerating self-equivalences of aspherical complexes becomes finite group computation. The reduction is exact rather than approximate, and Section 8 gives the complexity.

---

## 10. Discussion and future directions

**10.1 What is genuinely new.** Three points deserve emphasis. First, the prescribed-value homotopy lemma (Theorem 3.1) is the minimal strengthening that converts an "up to conjugacy" classification into a bijection; earlier arguments produce only the existence of *some* homotopy and thus cannot control basepoints. Second, the pointed classification requires *no* connectedness assumption on the target: the realization functor is constant on objects, so it does not care whether the target has other components. Third, the fibre count is *uniform* — the same index formula for every basepoint and every model — so it is genuinely an invariant of the homomorphism, not of the presentation.

**10.2 Coherence.** With basepoints fixed, all comparison $2$-cells in the classification can be chosen to be identities (Theorem 5.2), so no coherence obstruction can arise in the pointed setting. What remains is the unpointed, bicategorical bookkeeping: to exhibit the assignment "connected pointed groupoid $\mapsto$ its vertex group" as a genuine biequivalence between the homotopy $2$-category of connected groupoids and the $2$-category of groups, homomorphisms and conjugations, with coherent associativity and unit comparison cells.

**10.3 Beyond connected sources.** The object-level classification of arbitrary $1$-types is by the pair (set of components, fundamental groups of the components). For *maps* out of a disconnected source, the expected answer is that a homotopy class is exactly the data, for each source component, of a target component together with a (conjugacy class of a) homomorphism of the corresponding fundamental groups; the pointed theory above should give the componentwise strict version. Making this precise, and identifying the resulting monoid of self-map classes of a disconnected $1$-type, is the natural next step.

**10.4 Asphericity as a characterisation.** One expects that a path-connected space $X$ is aspherical if and only if for every path-connected $Y$ the map $[Y,X] \to \operatorname{Hom}(\pi_1 Y, \pi_1 X)/\text{conj}$ is a bijection — the "only if" being the classification above, the "if" following by testing against spheres. A pointed version should say: $X$ is aspherical iff $[Y,X]_* \to \operatorname{Hom}(\pi_1 Y, \pi_1 X)$ is a bijection for all connected $Y$.

**10.5 Genuinely higher phenomena.** Everything here is invisible above dimension $1$ by construction. A complete theory of maps of $2$-types would replace groups by crossed modules and conjugation by a richer $2$-dimensional symmetry; the fibre of "forget the basepoint" should then be a *groupoid* rather than a set, with $\pi_0$ the centraliser index computed here and $\pi_1$ the centre of the relevant automorphism group.

**10.6 Quantitative questions.** For a fixed finite $H$, the multiset of fibre sizes $\{[H : C_H(\varphi(G))] : \varphi \in \operatorname{Hom}(G,H)\}$ is an invariant of the pair $(G,H)$ refining the count of unpointed classes; its distribution as $G$ varies over, say, all groups of a fixed order, is an appealing combinatorial question. For $G = H = S_3$ it is $\{1,3,6\}$; for $G = (\mathbb{Z}/2)^2$, $H = S_4$ it is $\{1,3,3,3,6,6,6,6,6,6,6\}$, summing to the $52$ homomorphisms and $11$ conjugation orbits.

---

## Appendix A. Summary of results

- **Prescribed-homotopy lemma.** Connected source, intertwining isomorphism at the basepoint $\Rightarrow$ homotopy with that exact value at the basepoint.
- **Pointed classification.** $[(X,x),(Y,y)]_* \cong \operatorname{Hom}(\pi_1(X,x), \pi_1(Y,y))$ for connected $(X,x)$ and arbitrary $(Y,y)$.
- **Invariance and completeness.** Pointed-homotopic maps induce equal homomorphisms; equal induced homomorphisms imply pointed homotopy.
- **Strict functoriality.** $(\mathbf{1})_\# = \mathrm{id}$ and $(P \ast Q)_\# = Q_\# \circ P_\#$ exactly.
- **Monoid.** $[(X,x),(X,x)]_* \cong \operatorname{End}(\pi_1(X,x))$; units $\cong \operatorname{Aut}(\pi_1(X,x))$.
- **Pointed Whitehead theorem.** Homotopy equivalence $\Leftrightarrow$ bijective induced endomorphism $\Leftrightarrow$ invertible class.
- **Fibre count.** $|\pi^{-1}([\varphi])| = [H : C_H(\varphi(G))]$, uniformly.
- **Identity fibre.** $[G : Z(G)] = |\operatorname{Inn}(G)|$, reconciling $\operatorname{Aut}(G)$ with $\operatorname{Out}(G)$.
- **Abelian target.** Basepoint forgetting is injective.
- **$S_3$ test.** Fibre sizes $1$, $3$, $6$; ten pointed classes over three unpointed ones.
