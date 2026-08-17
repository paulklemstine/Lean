# The Fundamental Group as a Complete Invariant — and the Exact Failure of Completeness for Coverings

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We determine precisely how much of a topological situation the fundamental group remembers. On the positive side, for aspherical one-dimensional spaces — the Eilenberg–MacLane spaces $K(G,1)$ — the fundamental group is a *complete* invariant: two such spaces are equivalent if and only if their fundamental groups are isomorphic, and every group is realised. On the negative side, we show that the fundamental group is emphatically *not* a complete invariant of coverings of a fixed $K(G,1)$, and we identify the invariant that is.

Working throughout in the groupoid model, in which a $K(G,1)$ is the one-object groupoid of the group $G$ and a covering of it is the action groupoid of a $G$-set, we establish: (i) a covering is connected iff its monodromy action is transitive, its fundamental group at a chosen point of the fibre is the stabiliser of that point, and its number of sheets is the index of that stabiliser; (ii) the **Galois correspondence** — two connected coverings are isomorphic iff their subgroups are conjugate, morphisms correspond to sub-conjugacy, and pointed isomorphism corresponds to equality of subgroups; (iii) the deck group of the covering classified by $H \le G$ is $N_G(H)/H$, so a covering is regular iff $H$ is normal, the universal cover is simply connected with deck group $G$, and the resulting short exact sequence identifies group extensions with regular coverings; (iv) fibre products of coverings decompose into connected components indexed by double cosets $H \backslash G / K$, the component through a point being classified by $H \cap gKg^{-1}$.

We then quantify the failure of completeness. Over the Klein four group $V=\mathbb{Z}/2\times\mathbb{Z}/2$ we exhibit two double coverings with equivalent total spaces (both $K(\mathbb{Z}/2,1)$) and equal degrees that are not isomorphic as coverings; and we universalise this: for **every** group $G$ surjecting onto $\mathbb{Z}/2$, the space $K(G\times\mathbb{Z}/2,1)$ carries two non-isomorphic double coverings whose total spaces are both $K(G,1)$. Contrasting this with $S_3$, where two *distinct* point stabilisers give *isomorphic* coverings, we show that conjugacy is exactly the right equivalence: isomorphism of fundamental groups is too coarse and equality of subgroups is too fine.

Finally we compute. For the circle, subgroups of $\mathbb{Z}$ are determined by their index, so the number of sheets is a complete invariant of connected coverings — the sharpest possible outcome. For the torus, degree is far from complete: we prove via Hermite normal form that the number of connected $n$-sheeted coverings is exactly $\sigma(n)=\sum_{d\mid n} d$ (so $3, 4, 7$ in degrees $2, 3, 4$ and $p+1$ in prime degree $p$), that every finite-index subgroup of $\mathbb{Z}^2$ is isomorphic to $\mathbb{Z}^2$, and hence that *all* of these infinitely many pairwise non-isomorphic coverings have a torus as total space. Finally we identify connected double coverings of any $K(G,1)$ with the nonzero classes of $H^1(G;\mathbb{F}_2)=\operatorname{Hom}(G,\mathbb{Z}/2)$, and give the exact odd-prime correction: $p-1$ surjective characters share each normal kernel of index $p$, and a non-normal subgroup of prime index $p$ forces a prime factor of $|G|$ strictly below $p$.

**Keywords:** fundamental group, Eilenberg–MacLane space, covering space, Galois correspondence, deck transformation group, conjugacy class of subgroups, Hermite normal form, mod-two cohomology.

---

## 1. Introduction

The fundamental group $\pi_1(X,x_0)$ of a pointed connected space is the set of loops at $x_0$ modulo homotopy, with concatenation as multiplication. It is the first and most transparent algebraic invariant in topology, and the first question one asks of any invariant is how much it forgets.

The answer has two faces, and this paper develops both in a single framework.

**Face one: total recall.** Restricted to spaces whose only homotopy is in dimension one — the aspherical spaces $K(G,1)$, characterised by $\pi_1 = G$ and $\pi_n = 0$ for $n \ge 2$ — the fundamental group is a *complete* invariant. Two such spaces are homotopy equivalent iff their fundamental groups are isomorphic, and every group occurs. Homotopy theory in this range is group theory, exactly.

**Face two: exact amnesia.** Change the objects from spaces to *coverings* of a fixed $K(G,1)$. Now the fundamental group fails, and fails maximally: there are pairs of coverings of the same base with the same number of sheets and homotopy-equivalent total spaces that are not isomorphic as coverings. What the fundamental group cannot see is not the isomorphism type of the subgroup $H \le G$ that classifies the covering, but its *position* in $G$; and the exact invariant is the conjugacy class of $H$.

Our strategy is to work entirely in the **groupoid model** of homotopy $1$-types, where both faces become theorems of group theory and both can be proved with complete precision.

### 1.1 The groupoid model

A *groupoid* is a category in which every morphism is invertible. The fundamental groupoid $\Pi_1(X)$ of a space has the points of $X$ as objects and homotopy classes of paths as morphisms. For a connected space, choosing a path from a fixed basepoint to every other point produces an equivalence of categories between $\Pi_1(X)$ and the one-object groupoid $\mathbf{B}G$ whose single object has automorphism group $G=\pi_1(X,x_0)$. Homotopy $1$-types and groupoids agree; connected homotopy $1$-types and one-object groupoids agree; so a model of $K(G,1)$ is precisely $\mathbf{B}G$.

**Definition 1.1 (Model of $K(G,1)$).** For a group $G$, write $\mathbf{B}G$ for the groupoid with one object $\star$ and $\operatorname{Hom}(\star,\star)=G$, composition being multiplication.

**Definition 1.2 (Connected groupoid).** A groupoid $\mathcal{C}$ is *connected at* an object $c$ if for every object $d$ there is an isomorphism $c \cong d$.

**Theorem 1.3 (Complete invariance for homotopy $1$-types).** Let $\mathcal{C}$ and $\mathcal{D}$ be groupoids connected at objects $c$ and $d$ respectively. If $\operatorname{Aut}(c) \cong \operatorname{Aut}(d)$ as groups, then $\mathcal{C}$ and $\mathcal{D}$ are equivalent. In particular $\mathbf{B}G \simeq \mathbf{B}H$ iff $G \cong H$, and every group is realised.

*Proof sketch.* Choose for each object $x$ of $\mathcal{C}$ an isomorphism $u_x : c \to x$ with $u_c = \mathrm{id}$, and similarly $v_y$ in $\mathcal{D}$; these exist by connectedness. Transport an arrow $f: x \to x'$ to the automorphism $u_{x'}^{-1} f u_x$ of $c$, apply the given isomorphism $\operatorname{Aut}(c) \cong \operatorname{Aut}(d)$, and transport back along a chosen surjection of object sets. Functoriality is a direct check with the chosen paths cancelling in pairs; essential surjectivity and full faithfulness are immediate. The converse direction is functoriality of $\operatorname{Aut}$ under equivalence. $\square$

So in the $1$-type range the invariant is perfect. Everything interesting happens one level up, when we look at maps *to* a $K(G,1)$.

### 1.2 Coverings as $G$-sets

**Definition 1.4 (Action groupoid).** Let $G$ act on a set $X$. The *action groupoid* $G \ltimes X$ has $X$ as its set of objects and $\operatorname{Hom}(x,y) = \{g \in G : g\cdot x = y\}$, composition being multiplication in $G$. The forgetful functor $G \ltimes X \to \mathbf{B}G$, which sends every object to $\star$ and the arrow $g$ to $g$, is the *covering projection*, and $X$ is the *fibre*.

This is the algebraic shadow of the usual construction: the monodromy of a covering of $X$ is an action of $\pi_1(X)$ on the fibre, and the covering is recovered from the action. All statements below are statements about $G$-sets; each has the covering-theoretic reading indicated.

**Definition 1.5 (Morphisms and isomorphisms of coverings).** For $G$-sets $X$ and $Y$, a *morphism of coverings* is a $G$-equivariant map $f : X \to Y$, i.e. $f(g\cdot x) = g \cdot f(x)$; an *isomorphism of coverings* is an equivariant bijection.

---

## 2. Structure of a connected covering

Throughout this section $G$ is a group and $X$ a $G$-set.

**Theorem 2.1 (Connectivity $=$ transitivity).** The action groupoid $G\ltimes X$ is connected at a point $x$ of the fibre if and only if $G$ acts transitively on $X$.

*Proof sketch.* If the action is transitive, any $y \in X$ receives an arrow $g : x \to y$ where $g\cdot x = y$, and every arrow is invertible. Conversely, if $G \ltimes X$ is connected at $x$, then given $a,b \in X$ pick arrows $e : x \to a$ and $f : x\to b$; the element $f\,e^{-1} \in G$ carries $a$ to $b$. $\square$

**Theorem 2.2 (The fundamental group of a covering is a stabiliser).** For $x \in X$, the automorphism group of $x$ in $G\ltimes X$ is canonically isomorphic to the stabiliser
$$\operatorname{Stab}_G(x) = \{g \in G : g\cdot x = x\} \le G .$$

*Proof sketch.* By definition an automorphism of $x$ is an element $g$ with $g\cdot x = x$, and composition is multiplication; the identification is the identity map on underlying elements. $\square$

**Corollary 2.3 (A connected covering of a $K(G,1)$ is a $K(H,1)$).** If $G$ acts transitively on $X$ then $G\ltimes X \simeq \mathbf{B}\operatorname{Stab}_G(x)$ for any $x \in X$. Indeed both groupoids are connected and their vertex groups agree, so Theorem 1.3 applies.

**Theorem 2.4 (Degree $=$ index).** If $G$ acts transitively on $X$, then $|X| = [G : \operatorname{Stab}_G(x)]$ for any $x \in X$; i.e. the number of sheets of a connected covering is the index of its subgroup.

*Proof sketch.* The orbit map $g \mapsto g\cdot x$ induces a bijection $G/\operatorname{Stab}_G(x) \to X$, surjective by transitivity and injective by the definition of the stabiliser. $\square$

**Proposition 2.5 (The projection on fundamental groups).** The map $\operatorname{Aut}_{G\ltimes X}(x) \to G$ induced by the covering projection is injective with image exactly $\operatorname{Stab}_G(x)$.

Thus every connected covering realises a subgroup of $\pi_1$ of the base, and conversely each subgroup $H \le G$ is realised by the coset space $X = G/H$ with left translation, whose stabiliser at the trivial coset is $H$.

---

## 3. The Galois correspondence

The classification of connected coverings has exactly the form of the fundamental theorem of Galois theory, with conjugacy playing the role of the ambiguity of embeddings.

For a transitive $G$-set $X$ with $x \in X$ and any $g \in G$, the elementary identity
$$\operatorname{Stab}_G(g\cdot x) = g\,\operatorname{Stab}_G(x)\,g^{-1}$$
is what makes conjugacy unavoidable: moving the chosen point of the fibre conjugates the subgroup.

**Lemma 3.1 (Transport).** Let $X$ be a transitive $G$-set with $x_0 \in X$ and let $Y$ be any $G$-set with $y_0 \in Y$ satisfying $\operatorname{Stab}_G(x_0) \le \operatorname{Stab}_G(y_0)$. Then there is a unique morphism of coverings $f : X \to Y$ with $f(x_0)=y_0$, given by $f(a\cdot x_0) = a \cdot y_0$.

*Proof sketch.* Well-definedness is the key point: if $a\cdot x_0 = b\cdot x_0$ then $b^{-1}a \in \operatorname{Stab}_G(x_0) \le \operatorname{Stab}_G(y_0)$, so $a\cdot y_0 = b\cdot y_0$. Equivariance and uniqueness follow because every point of $X$ is $a \cdot x_0$ for some $a$. $\square$

**Theorem 3.2 (Morphisms $=$ sub-conjugacy).** Let $X$ and $Y$ be transitive $G$-sets with points $x$ and $y$. A morphism of coverings $X \to Y$ exists if and only if
$$\exists\, g\in G:\quad \operatorname{Stab}_G(x) \le g\,\operatorname{Stab}_G(y)\,g^{-1}.$$

*Proof sketch.* Given $f$, choose $g$ with $g\cdot y = f(x)$, which is possible by transitivity of $Y$; then $\operatorname{Stab}_G(x) \le \operatorname{Stab}_G(f(x)) = g\operatorname{Stab}_G(y)g^{-1}$, the containment because $f$ is equivariant. Conversely, the containment is exactly the hypothesis of Lemma 3.1 applied to the point $g\cdot y$. $\square$

**Theorem 3.3 (Galois correspondence).** Let $X$ and $Y$ be transitive $G$-sets with points $x$ and $y$. Then $X \cong Y$ as coverings if and only if
$$\exists\, g\in G:\quad \operatorname{Stab}_G(y) = g\,\operatorname{Stab}_G(x)\,g^{-1}.$$
Consequently, isomorphism classes of connected coverings of a $K(G,1)$ correspond bijectively to conjugacy classes of subgroups of $G$, the covering attached to $H$ being $G/H$, with total space a $K(H,1)$ and degree $[G:H]$.

*Proof sketch.* An isomorphism preserves stabilisers ($\operatorname{Stab}_G(e(x)) = \operatorname{Stab}_G(x)$, applying the containment of Theorem 3.2 to $e$ and to $e^{-1}$), and transitivity supplies $g$ with $g\cdot e(x) = y$. Conversely, given the conjugacy, apply Lemma 3.1 in both directions between $g \cdot x$ and $y$ — the two subgroups now being equal — and check that the composites fix all points of the form $a \cdot x$, hence are the identity. $\square$

**Theorem 3.4 (Pointed classification).** With notation as above, there is an isomorphism of coverings $e : X \to Y$ with $e(x)=y$ if and only if $\operatorname{Stab}_G(x) = \operatorname{Stab}_G(y)$.

Theorems 3.3 and 3.4 together isolate the role of conjugacy: it is exactly the freedom to move the basepoint in the fibre, i.e. to drag the basepoint of the covering around a loop of the base.

**Corollary 3.5 (Abelian base).** If $G$ is abelian, conjugacy is equality, so isomorphism classes of connected coverings correspond bijectively to *subgroups* of $G$, and every covering is regular.

---

## 4. Deck transformations, regularity, and extensions

**Definition 4.1.** The *deck group* of a covering $X$ is the group of automorphisms of $X$ as a covering, i.e. equivariant bijections $X \to X$.

**Theorem 4.2 (Deck group).** For $H \le G$ the deck group of the connected covering $G/H$ is
$$\operatorname{Deck}(G/H)\;\cong\; N_G(H)/H,$$
where $N_G(H)$ is the normaliser. Moreover the deck group acts *freely*: a deck transformation with a fixed point is the identity.

*Proof sketch.* An equivariant map $G/H \to G/H$ is determined by the image $nH$ of the trivial coset, and equivariance forces $H \le nHn^{-1}$, i.e. $n \in N_G(H)$ in the finite-index case and after passing to inverses in general; the assignment $n \mapsto (aH \mapsto anH)$ is a surjective homomorphism $N_G(H) \to \operatorname{Deck}(G/H)$ with kernel $H$. Freeness: a deck transformation fixing $aH$ agrees with the identity at one point of a transitive $G$-set, and two equivariant maps out of a transitive $G$-set that agree at a point are equal. $\square$

**Theorem 4.3 (Regularity).** The deck group acts transitively on the fibre — the covering is *regular* — if and only if $H \trianglelefteq G$. In that case $\operatorname{Deck}(G/H)\cong G/H$.

**Theorem 4.4 (Universal cover).** Take $H = 1$, i.e. $X=G$ with left translation. Then the covering is simply connected (its fundamental group at any point is the trivial stabiliser), and its deck group is isomorphic to $G$, a deck transformation being right translation.

**Theorem 4.5 (Exact sequence of a regular covering).** Let $H \trianglelefteq G$. Then
$$1 \longrightarrow H \longrightarrow G \longrightarrow \operatorname{Deck}(G/H) \longrightarrow 1$$
is exact: the fundamental group of the total space injects into that of the base with image exactly $H$, the deck homomorphism is surjective, and its kernel is exactly $H$.

**Corollary 4.6 (Extensions are regular coverings).** A surjection $\varphi : G \twoheadrightarrow Q$ with kernel $N$ is precisely the data of a regular covering of $K(G,1)$ whose total space is a $K(N,1)$ and whose deck group is $Q$. Conversely every regular covering arises this way.

**Theorem 4.7 (Nielsen–Schreier via coverings).** If $G$ is a free group, then the fundamental group of every connected covering of $K(G,1)$ is free. Equivalently: every subgroup of a free group is free.

*Proof sketch.* By Theorem 2.2 the fundamental group of the covering is a subgroup of $G$; the statement is then exactly the Nielsen–Schreier theorem, whose topological proof is that a covering of a graph is a graph and the fundamental group of a graph is free. $\square$

**Theorem 4.8 (Fibre products and double cosets).** Let $H, K \le G$. The fibre product of the coverings $G/H$ and $G/K$ over the base is the $G$-set $(G/H)\times(G/K)$ with the diagonal action. Its orbits — the connected components of the fibre product — are in bijection with the double cosets $H\backslash G/K$; the component containing $(H, gK)$ is the connected covering classified by
$$\operatorname{Stab}_G(H, gK) \;=\; H \cap gKg^{-1}.$$
In particular the fibre product is connected iff $G = HK$.

*Proof sketch.* The stabiliser computation is immediate from $\operatorname{Stab}_G(aH)=aHa^{-1}$. The orbit of $(H,gK)$ determines and is determined by the double coset $HgK$, since $(aH, agK)$ and $(H, g'K)$ lie in the same orbit iff $g' \in HgK$. Connectivity is the statement that $H\backslash G/K$ is a single class. $\square$

Taking $K=H$ recovers regularity from the fibre-product side: the self-fibre-product of $G/H$ splits into $|H\backslash G/H|$ components, and it splits into $[G:H]$ copies of $G/H$ exactly when $H$ is normal.

---

## 5. The failure of $\pi_1$ as an invariant of coverings

Theorem 1.3 says the fundamental group classifies $K(G,1)$ spaces. We now show it does not classify coverings, and we measure the failure exactly.

### 5.1 The Klein four group

Let $V = \mathbb{Z}/2 \times \mathbb{Z}/2$, written multiplicatively as $C_2 \times C_2$, and let $H_1 = C_2 \times 1$, $H_2 = 1 \times C_2$, and $H_\Delta = \ker(\mu)$ where $\mu(x,y)=xy$ — the diagonal.

**Theorem 5.1 (Exactly three double coverings).** $H_1, H_2, H_\Delta$ have index two and are the *only* index-two subgroups of $V$. Hence $K(V,1)$ has exactly three connected double coverings, and they are pairwise non-isomorphic.

*Proof sketch.* A subgroup of index two in a group of order four has order two, hence is generated by one of the three involutions $(1,0)$, $(0,1)$, $(1,1)$, giving the three listed subgroups; distinctness is a membership check. Since $V$ is abelian, Corollary 3.5 turns non-equality of subgroups into non-isomorphism of coverings. $\square$

**Theorem 5.2 ($\pi_1$ is not a complete invariant of coverings).** The two coverings $V/H_1$ and $V/H_2$ of $K(V,1)$ satisfy:
1. their total spaces are equivalent (both are $K(\mathbb{Z}/2,1)$), so they have isomorphic fundamental groups;
2. they have the same number of sheets, namely $2$;
3. they are **not** isomorphic as coverings.

*Proof sketch.* (1) $H_1 \cong H_2 \cong \mathbb{Z}/2$; the swap automorphism of $V$ carries $H_1$ onto $H_2$, giving the isomorphism explicitly, and Theorem 1.3 upgrades it to an equivalence of total spaces. (2) Both have index two. (3) $H_1 \ne H_2$ and $V$ is abelian, so Corollary 3.5 forbids an isomorphism. $\square$

So the total-space homotopy type together with the degree — everything intrinsic to $\tilde X$ — does not determine a covering. The missing datum is the *position* of the subgroup in $\pi_1$.

### 5.2 A universal source of such pairs

The phenomenon is not special to $V$.

**Theorem 5.3 (Twisted pair).** Let $G$ be any group admitting a surjection $\varphi : G \twoheadrightarrow C_2$, and work over the base $K(G\times C_2, 1)$. Define
$$N_{\text{base}} = \ker(\mathrm{pr}_2) = G\times 1, \qquad N_{\text{tw}} = \ker\big((\varphi\circ \mathrm{pr}_1)\cdot \mathrm{pr}_2\big) = \{(g,\varphi(g)) : g\in G\}.$$
Then both have index two, both are isomorphic to $G$, the two associated double coverings have equivalent total spaces (each a $K(G,1)$), and they are **not** isomorphic as coverings.

*Proof sketch.* Each subgroup is the kernel of a surjective character to $C_2$, hence of index two (the second because $\varphi$ is surjective). The projection $\mathrm{pr}_1$ restricts to an isomorphism on each: on $N_{\text{base}}$ trivially, on $N_{\text{tw}}$ because $g \mapsto (g,\varphi(g))$ is an inverse. Non-isomorphism: index-two subgroups are normal, so conjugation fixes each of them setwise, and Theorem 3.3 reduces isomorphism to equality; but $N_{\text{base}} \neq N_{\text{tw}}$ since $\varphi$ is nontrivial. $\square$

**Corollary 5.4 (Non-abelian instance).** Taking $G = S_3$ with $\varphi$ the sign character gives two non-isomorphic connected double coverings of $K(S_3\times C_2,1)$, both with total space a $K(S_3,1)$.

The proof identifies the general mechanism: whenever isomorphism of coverings reduces to *equality* of subgroups — which happens for every index-two subgroup, over any base — two distinct but abstractly isomorphic subgroups give indistinguishable total spaces and distinguishable coverings.

**Lemma 5.5 (Index two kills conjugacy).** Over any base, two connected double coverings classified by $H$ and $L$ are isomorphic iff $H = L$. Indeed a subgroup of index two is normal, so $gHg^{-1}=H$ for all $g$.

### 5.3 Conjugacy is exactly the right equivalence

The Klein example shows isomorphism of fundamental groups is too coarse. The next shows equality of subgroups is too fine.

**Theorem 5.6 ($S_3$: distinct subgroups, isomorphic coverings).** Let $S_3$ act on $\{0,1,2\}$ and let $P_0, P_1$ be the stabilisers of $0$ and $1$. Then $P_0 \ne P_1$, but $P_1 = \tau P_0 \tau^{-1}$ for the transposition $\tau=(0\,1)$, and hence the two three-sheeted coverings $S_3/P_0$ and $S_3/P_1$ **are** isomorphic.

*Proof sketch.* $P_0 = \{\mathrm{id},(1\,2)\}$ and $P_1=\{\mathrm{id},(0\,2)\}$ are distinct; the conjugation identity $\operatorname{Stab}(g\cdot x) = g\operatorname{Stab}(x)g^{-1}$ with $g=\tau$ gives the conjugacy; Theorem 3.3 concludes. $\square$

**Theorem 5.7 (Synthesis).** Combining 5.2 and 5.6: among the three candidate equivalences on classifying subgroups,
- *abstract isomorphism of subgroups* is strictly coarser than isomorphism of coverings (Klein four group);
- *equality of subgroups* is strictly finer than isomorphism of coverings ($S_3$);
- *conjugacy* is exactly isomorphism of coverings (Theorem 3.3).

---

## 6. Coverings of the circle: degree is complete

**Theorem 6.1.** Every subgroup of $\mathbb{Z}$ is of the form $n\mathbb{Z}$, and two subgroups of $\mathbb{Z}$ with the same index are equal.

*Proof sketch.* Subgroups of $\mathbb{Z}$ are cyclic, say generated by $a$ and $b$; the index of $\langle a\rangle$ is $|a|$ (interpreting $|0|=0$ as infinite index), so equality of indices gives $|a| = |b|$, hence $a=\pm b$ and $\langle a\rangle = \langle b\rangle$. $\square$

**Theorem 6.2 (Classification of coverings of the circle).** Let $S^1$ be a $K(\mathbb{Z},1)$. Two connected coverings of $S^1$ are isomorphic if and only if they have the same number of sheets. Every $n \ge 1$ occurs, realised by $n\mathbb{Z} \le \mathbb{Z}$ (the $n$-fold wrap $z\mapsto z^n$); and infinite degree occurs only for the trivial subgroup, the universal cover $\mathbb{R}\to S^1$.

*Proof sketch.* $\mathbb{Z}$ is abelian, so Corollary 3.5 makes isomorphism equality of subgroups; Theorem 2.4 makes degree the index; Theorem 6.1 makes index determine the subgroup. For the last claim, a subgroup of index $0$ (infinite index) has the same index as the trivial subgroup, hence equals it. $\square$

This is the sharpest possible classification: a single number classifies. Theorem 5.1 already shows it does not generalise — over the Klein four group there are three pairwise non-isomorphic coverings of the *same* degree $2$.

---

## 7. Coverings of the torus: $\sigma(n)$ of them, all tori

Let $T$ be a $K(\mathbb{Z}^2,1)$, i.e. the $2$-torus. Connected $n$-sheeted coverings correspond to index-$n$ subgroups (sublattices) of $\mathbb{Z}^2$, and — the base being abelian — non-isomorphic ones correspond to distinct subgroups.

### 7.1 Every finite covering of the torus is a torus

**Theorem 7.1.** Every finite-index subgroup $H \le \mathbb{Z}^2$ is isomorphic to $\mathbb{Z}^2$.

*Proof sketch.* If $[\mathbb{Z}^2:H]=k<\infty$ then $k\mathbb{Z}^2 \le H$, so $H$ contains a copy of $\mathbb{Z}^2$ and has rank at least two; being a submodule of a free module of rank two over the principal ideal domain $\mathbb{Z}$, it is free of rank at most two. Hence it is free of rank exactly two. $\square$

**Corollary 7.2.** The total space of every connected finite-sheeted covering of the torus is again a torus.

### 7.2 Degree two and three by hand

**Theorem 7.3 (Three double coverings).** $\mathbb{Z}^2$ has exactly three subgroups of index two, namely
$$\langle (1,0),(0,2)\rangle,\qquad \langle (2,0),(0,1)\rangle,\qquad \langle (1,1),(1,-1)\rangle,$$
the last being $\{(x,y) : x+y \text{ even}\}$. The three coverings are pairwise non-isomorphic, and each total space is a torus.

*Proof sketch.* An index-two subgroup contains $2\mathbb{Z}^2$ (squares lie in any index-two subgroup), hence is the preimage of an index-two subgroup of $\mathbb{Z}^2/2\mathbb{Z}^2 \cong V$; by Theorem 5.1 there are exactly three of those. Each of the three is the image of an injective endomorphism of $\mathbb{Z}^2$ with matrix columns $(1,0),(0,2)$; $(2,0),(0,1)$; $(1,1),(1,-1)$ respectively, hence isomorphic to $\mathbb{Z}^2$. $\square$

**Theorem 7.4 (Four triple coverings).** $\mathbb{Z}^2$ has exactly four subgroups of index three; the four coverings are pairwise non-isomorphic and all four total spaces are tori.

*Proof sketch.* A subgroup of index three is normal (abelian base), hence the kernel of a surjection $\chi : \mathbb{Z}^2 \to C_3$. Such a $\chi$ is determined by its values $(a,b) \in (\mathbb{Z}/3)^2$ on the standard generators, and is surjective iff $(a,b)\ne(0,0)$. Rescaling $(a,b)\mapsto(2a,2b)$ does not change the kernel, so the eight nonzero pairs fall into four kernel classes, giving four subgroups. $\square$

### 7.3 Prime degree: exactly $p+1$

**Theorem 7.5.** For a prime $p$, the torus has exactly $p+1$ connected coverings of degree $p$, pairwise non-isomorphic, all with torus total space.

*Proof sketch.* A character $\mathbb{Z}^2 \to C_p$ is determined by its values $(a,b)\in(\mathbb{Z}/p)^2$, and is surjective iff $(a,b)\neq (0,0)$: there are $p^2-1$ surjective characters. Taking kernels maps these onto the index-$p$ subgroups, and by Theorem 8.4 below every fibre of this map has exactly $p-1$ elements. Hence the number of index-$p$ subgroups is $(p^2-1)/(p-1) = p+1$. $\square$

### 7.4 The general count: Hermite normal form

**Definition 7.6.** For integers $a,d>0$ and $c$, let $L(a,c,d) \le \mathbb{Z}^2$ be the sublattice spanned by $(a,0)$ and $(c,d)$, i.e. the image of the endomorphism of $\mathbb{Z}^2$ sending $(1,0)\mapsto(a,0)$ and $(0,1)\mapsto(c,d)$.

**Lemma 7.7 (Index).** $[\mathbb{Z}^2 : L(a,c,d)] = a\,d$.

*Proof sketch.* A two-step tower. The lattice $L(a,c,d)$ is contained in $\mathbb{Z}\times d\mathbb{Z}$, which is the kernel of reduction of the second coordinate mod $d$ and hence has index $d$. Inside $\mathbb{Z}\times d\mathbb{Z}$, the sublattice $L(a,c,d)$ is the kernel of the homomorphism $(x,y)\mapsto x - (y/d)c \bmod a$, which is surjective onto $\mathbb{Z}/a$; so the relative index is $a$. Multiply. $\square$

**Theorem 7.8 (Existence and uniqueness of normal form).** Every finite-index subgroup $H \le \mathbb{Z}^2$ equals $L(a,c,d)$ for unique integers $a,d>0$ and $0 \le c < a$.

*Proof sketch.* Existence: let $a$ generate the cyclic group $\{x \in \mathbb{Z} : (x,0)\in H\}$ and $d$ generate $\{y : \exists x,\ (x,y) \in H\}$; choose $c$ with $(c,d)\in H$, reduce $c$ modulo $a$ by subtracting multiples of $(a,0)$, and verify that $(a,0)$ and $(c,d)$ generate $H$ by clearing the second coordinate of an arbitrary element. Uniqueness: $a$, $d$ and $c \bmod a$ are recovered from $H$ by the same two subgroups of $\mathbb{Z}$, which are intrinsic. $\square$

**Theorem 7.9 (The $\sigma$ classification).** For $n \ge 1$, the number of subgroups of index $n$ in $\mathbb{Z}^2$, equivalently the number of isomorphism classes of connected $n$-sheeted coverings of the torus, is
$$\#\{H \le \mathbb{Z}^2 : [\mathbb{Z}^2:H]=n\} \;=\; \sum_{a \mid n} a \;=\; \sigma(n).$$
These coverings are pairwise non-isomorphic and each total space is again a torus.

*Proof sketch.* By Theorems 7.8 and 7.7, index-$n$ subgroups biject with pairs $(a,c)$ where $a \mid n$ (and then $d=n/a$) and $0\le c<a$; for each divisor $a$ there are $a$ choices of $c$, giving $\sum_{a\mid n} a$. Pairwise non-isomorphism is Corollary 3.5 (abelian base), and the total spaces are tori by Corollary 7.2. $\square$

Specialising: $\sigma(2)=3$, $\sigma(3)=4$, $\sigma(4)=7$, $\sigma(p)=p+1$, recovering Theorems 7.3, 7.4, 7.5 uniformly.

**Corollary 7.10 (Maximal failure of $\pi_1$).** The torus admits infinitely many pairwise non-isomorphic connected coverings — $\sigma(n)$ in each degree $n$ — and the total space of every one of them is a torus. Hence neither the homotopy type of the total space, nor even that together with the degree, comes close to determining a covering.

---

## 8. Double coverings are mod-two characters; the odd-prime correction

Let $C_p$ denote the cyclic group of order $p$.

**Theorem 8.1 (Characters versus kernels, $p=2$).** For any group $G$:
1. a homomorphism $\varphi : G \to C_2$ is nontrivial iff it is surjective, and then $[G:\ker\varphi]=2$;
2. every subgroup $H \le G$ of index two is the kernel of a homomorphism $G \to C_2$ (namely the composite $G \to G/H \xrightarrow{\ \sim\ } C_2$, the quotient being a group of order two and hence a copy of $C_2$);
3. a homomorphism into $C_2$ is determined by its kernel.

*Proof sketch.* (1) $C_2$ has only two elements, so a nontrivial character hits the generator, and the index of the kernel equals the order of the image. (2) Index two implies normal, so the quotient is a group of order two, and any two groups of prime order $p$ are isomorphic. (3) Given $\ker\varphi = \ker\psi$: for each $g$, either both $\varphi(g)$ and $\psi(g)$ are trivial, or both are the unique nontrivial element. $\square$

**Theorem 8.2 (Double coverings $=$ nonzero mod-two classes).** For any group $G$, the assignment $\varphi \mapsto \ker\varphi$ is a bijection
$$\{\varphi \in \operatorname{Hom}(G, C_2) : \varphi \neq 1\} \;\xrightarrow{\ \sim\ }\; \{H \le G : [G:H]=2\},$$
with inverse $H \mapsto (G \to G/H \cong C_2)$. Combined with Lemma 5.5 (isomorphism of double coverings is equality of subgroups), this identifies the set of isomorphism classes of connected double coverings of a $K(G,1)$ with the nonzero classes of
$$H^1(G;\mathbb{F}_2) \;=\; \operatorname{Hom}(G, \mathbb{Z}/2),$$
the covering attached to $\varphi$ having total space a $K(\ker\varphi, 1)$.

*Proof sketch.* The two maps of Theorem 8.1 (2) and (3) are mutually inverse: $\ker$ of the constructed character is $H$ by the quotient description, and a character is recovered from its kernel by (3). $\square$

This is the algebraic content of the classical statement that double covers are classified by first mod-two cohomology — the orientation double cover of a manifold being the class $w_1$.

For odd primes exactly two corrections appear, and they are independent.

**Theorem 8.3 (Prime index and cyclic characters).** Let $p$ be prime and $H \trianglelefteq G$ of index $p$. Then $H = \ker\chi$ for some surjection $\chi : G \twoheadrightarrow C_p$; conversely the kernel of any surjection onto $C_p$ has index $p$.

*Proof sketch.* $G/H$ has order $p$, hence is cyclic of order $p$; compose the quotient map with an isomorphism $G/H \cong C_p$. Conversely the index of a kernel is the order of the image. $\square$

**Theorem 8.4 (Multiplicity $p-1$).** Two surjections $G \twoheadrightarrow C_p$ have the same kernel iff they differ by an automorphism of $C_p$; since $|\operatorname{Aut}(C_p)| = p-1$, exactly $p-1$ surjective characters share each kernel.

*Proof sketch.* If $\ker\chi = \ker\chi'$, both factor through the same isomorphism $G/\ker\chi \cong C_p$ up to an automorphism $s$ of $C_p$, so $\chi' = s\circ\chi$; conversely post-composition with an automorphism does not change the kernel. The action of $\operatorname{Aut}(C_p)$ on the set of surjections with a given kernel is simply transitive, and $\operatorname{Aut}(C_p) \cong (\mathbb{Z}/p)^\times$ has order $p-1$. $\square$

At $p=2$ this degenerates to $2-1=1$, recovering Theorem 8.1 (3): the mod-two character is unique. This is precisely the multiplicity that turns the $p^2-1$ surjective characters of $\mathbb{Z}^2$ into $p+1$ subgroups in Theorem 7.5.

**Theorem 8.5 (Where irregularity can live).** Let $H \le G$ have prime index $p$ and suppose $H$ is *not* normal, with $G$ finite. Then $p$ is strictly larger than the smallest prime factor of $|G|$.

*Proof sketch.* The index divides $|G|$, so the smallest prime factor of $|G|$ is at most $p$. If it equalled $p$, then $H$ would be normal, by the classical fact that a subgroup whose index is the smallest prime divisor of the order of the group is normal (the action on cosets gives a homomorphism to $S_p$ whose image has order dividing $p!$ and dividing $|G|$, forcing the kernel to be $H$). Hence the inequality is strict. $\square$

**Theorem 8.6 (Sharpness: a maximally irregular covering).** Let $S_3$ act on $\{0,1,2\}$ and let $P_0$ be the stabiliser of $0$. Then $[S_3:P_0]=3$, $P_0$ is not normal, and $P_0$ is self-normalising. Hence the associated connected three-sheeted covering of $K(S_3,1)$ is not regular, and in fact its deck group $N_{S_3}(P_0)/P_0$ is **trivial** — a three-sheeted covering with no nontrivial symmetries. Correspondingly the smallest prime factor of $|S_3|=6$ is $2 < 3$, as Theorem 8.5 requires.

Together, Theorems 8.5 and 8.6 delimit the prime-degree character theory exactly: at the smallest prime divisor of $|G|$ every degree-$p$ covering is regular and character-theoretic; above it, regularity can fail, and does.

---

## 9. Algorithms

The classification is effective. We record the three algorithms that make it so.

**Algorithm A (Classify coverings of a $K(G,1)$ for finite $G$).**
Enumerate the subgroups of $G$; group them into conjugacy classes under $g H g^{-1}$; each class is one isomorphism class of connected covering, of degree $[G:H]$, with total space a $K(H,1)$, deck group $N_G(H)/H$, and regular exactly when $N_G(H)=G$. Complexity is dominated by subgroup enumeration, $O(2^{|G|})$ naively but $O(|\mathcal{S}|\cdot|G|)$ once the subgroup list $\mathcal{S}$ is available.

**Algorithm B (Count $n$-sheeted coverings of the torus).**
Enumerate the normal forms: for each divisor $a$ of $n$ set $d=n/a$ and let $c$ run over $0,\dots,a-1$; output the lattice spanned by $(a,0)$ and $(c,d)$. The output has $\sigma(n)$ elements, each a distinct subgroup of index $n$; complexity $O(\sigma(n))$ after divisor enumeration in $O(\sqrt n)$.

**Algorithm C (Reduce a sublattice to normal form).**
Given generators of $H \le \mathbb{Z}^2$ of finite index, compute $d = \gcd$ of the second coordinates, use the Bézout combination to build a generator $(c,d)$, clear second coordinates from the other generators to obtain a subset of $\mathbb{Z}\times 0$ and let $a = \gcd$ of their first coordinates, then reduce $c$ modulo $a$. Output $(a,c,d)$; the index is $ad$. Complexity $O(k \log \max|{\cdot}|)$ for $k$ generators.

---

## 10. Applications and interpretation

**Group theory from topology.** The dictionary is used in both directions. Nielsen–Schreier (Theorem 4.7) is the flagship: a purely combinatorial statement about words proved by unrolling a bouquet of circles. Theorem 4.8 is Mackey's double coset formula for the restriction–induction composite, read as a statement about intersecting coverings.

**Extensions as geometry.** Corollary 4.6 makes group cohomology geometric: a central extension $1 \to N \to G \to Q \to 1$ is a regular covering with deck group $Q$, and the classifying data of extensions and of regular coverings coincide. In particular Theorem 8.2, identifying double coverings with $H^1(G;\mathbb{F}_2)$, is the degree-one instance visible in every orientation double cover and every spin structure discussion.

**Where the invariant must be refined.** Theorem 5.2 and Corollary 7.10 are cautionary tales for anyone who hopes to classify a bundle by its total space. Over the torus, *every* finite covering has the same total space up to homeomorphism, so the total space carries zero information; the covering is remembered entirely by the sublattice. In lattice-theoretic language, Theorem 7.9 is the statement that the subgroup zeta function of $\mathbb{Z}^2$ is $\zeta(s)\zeta(s-1)$, whose coefficients are $\sigma(n)$ — a coincidence of enumerative number theory and covering-space theory.

**Number theory.** The counts $\sigma(n)$ tie the enumeration of coverings to divisor sums; the prime case $p+1$ is the number of lines in the projective line over $\mathbb{F}_p$, exactly as the character-theoretic proof suggests: index-$p$ sublattices of $\mathbb{Z}^2$ correspond to the $\mathbb{F}_p$-points of $\mathbb{P}^1$, i.e. to nonzero characters up to scaling.

---

## 11. Discussion

The two headline results look contradictory and are not. The fundamental group is a *complete* invariant of $K(G,1)$ spaces (Theorem 1.3) and a *hopeless* invariant of coverings of a fixed $K(G,1)$ (Theorem 5.2, Corollary 7.10). The resolution is that a covering is not a space; it is a space together with a projection, and the projection remembers the *embedding* $H \hookrightarrow G$, not merely the abstract group $H$.

The exact invariant is therefore a subgroup up to conjugacy (Theorem 3.3), and every classical refinement of covering theory is a refinement of that statement:

| Covering-theoretic notion | Algebraic counterpart |
|---|---|
| connected covering | transitive $G$-set $G/H$ |
| number of sheets | index $[G:H]$ |
| $\pi_1$ of total space | $H$ |
| isomorphism of coverings | conjugacy of subgroups |
| pointed isomorphism | equality of subgroups |
| deck group | $N_G(H)/H$ |
| regular covering | $H$ normal |
| universal cover | $H = 1$ |
| covering morphism | sub-conjugacy $H \le gKg^{-1}$ |
| fibre product components | double cosets $H\backslash G/K$ |
| double covering | nonzero class in $H^1(G;\mathbb{F}_2)$ |

Two structural observations deserve emphasis. First, index two is special in *two* independent ways — index-two subgroups are automatically normal (killing the conjugacy ambiguity) and $\operatorname{Aut}(C_2)$ is trivial (killing the character ambiguity) — and only the conjunction of the two makes the cohomological count $|H^1(G;\mathbb{F}_2)|-1$ exact. Second, Theorems 8.5 and 8.6 show that both failures switch on at once for odd primes, with $S_3$ the minimal witness: the index-three point stabiliser is non-normal, self-normalising, and its covering has trivial deck group.

---

## 12. Future directions

**Odd-prime counting.** For an odd prime $p$ we conjecture the exact split
$$\#\{\text{connected degree-}p\text{ coverings of } K(G,1)\} \;=\; \frac{p^d-1}{p-1} \;+\; \#\{\text{conjugacy classes of non-normal index-}p\text{ subgroups}\},$$
where $d = \dim_{\mathbb{F}_p}\operatorname{Hom}(G, C_p)$. The first term counts the regular ones: nonzero characters modulo the scaling action of $(\mathbb{Z}/p)^\times$, two characters having the same kernel exactly when they are scalar multiples (Theorem 8.4). The key insight is that for $p=2$ both corrections degenerate — conjugacy is trivial because index-two subgroups are normal, and scaling is trivial because $(\mathbb{Z}/2)^\times$ is trivial — so the cohomological count is exact; for odd $p$ both switch on, and they are independent of each other. Theorems 8.3, 8.4, 8.5 and 8.6 supply all but the bookkeeping.

**Higher-rank lattices.** Theorem 7.9 counts index-$n$ sublattices of $\mathbb{Z}^2$ as $\sigma(n)$. The analogous count for $\mathbb{Z}^r$ is the coefficient of the subgroup zeta function $\zeta(s)\zeta(s-1)\cdots\zeta(s-r+1)$, and the Hermite normal form argument generalises verbatim. We expect the corresponding statement that every finite-index subgroup of $\mathbb{Z}^r$ is isomorphic to $\mathbb{Z}^r$, hence that all finite coverings of the $r$-torus are $r$-tori, giving unboundedly large families of coverings with a single total space.

**Surface groups.** For $\pi_1$ of a closed surface of genus $g \ge 2$, a degree-$n$ covering has total space of genus $n(g-1)+1$, so the total space *does* vary with the degree. Counting index-$n$ subgroups of surface groups is governed by the Hall-type formula for the number of subgroups of a given index in a finitely generated group; making the conjugacy correction explicit and comparing with the torus computation would isolate exactly how much the abelianness of $\mathbb{Z}^2$ contributed.

**Non-regular phenomena.** Theorem 8.5 bounds where non-regular prime-degree coverings can occur. A natural refinement: for each prime $p$, characterise the finite groups admitting a non-normal subgroup of index $p$, and count the resulting non-regular coverings, whose deck groups $N_G(H)/H$ interpolate between the trivial group ($H$ self-normalising, as for $S_3$) and $C_p$ (regular).

**Beyond dimension one.** The complete invariance of $\pi_1$ for $K(G,1)$ spaces has no analogue for higher $\pi_n$; the natural next question is which classes of spaces are classified by the pair $(\pi_1, \pi_2)$ together with the $k$-invariant, and whether the failure of $\pi_1$ to classify coverings has a two-dimensional shadow in the classification of gerbes and $2$-coverings by $H^2$.

---

## 13. Conclusion

For aspherical one-dimensional spaces, the fundamental group is a complete invariant: the topology is the algebra. For coverings of such a space, the fundamental group of the total space is not a complete invariant, and the failure can be made as bad as one likes — over the torus, infinitely many pairwise non-isomorphic coverings all have a torus as total space. The precise invariant is the conjugacy class of the classifying subgroup, and every classical construction of covering theory — degree, deck group, regularity, universal cover, fibre product, double cover — is the shadow of an equally classical construction of group theory: index, normaliser quotient, normality, the trivial subgroup, double cosets, and first mod-two cohomology.

The lesson generalises past this dictionary. An invariant does not simply "work" or "fail"; it works exactly on the category where the data it discards is not there. Move to a richer category — spaces with a map rather than spaces — and the discarded data reappears, together with the precise refinement needed to capture it.
