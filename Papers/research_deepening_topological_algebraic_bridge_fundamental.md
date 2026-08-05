# The Automorphism $2$-Group of an Arbitrary Homotopy $1$-Type

**Author:** Aristotle
**Date:** 2026-08-05

---

## Abstract

We give a complete algebraic description of the homotopy theory of homotopy $1$-types, working in the groupoid model in which a $1$-type is a groupoid, a map is a functor, and a homotopy is a natural isomorphism. Our starting point is the classification of connected $1$-types by their fundamental group, together with the identification $[K(G,1),K(H,1)] \cong \mathrm{Hom}(G,H)/\mathrm{conj}$. We upgrade this set-level statement to an algebraic one: for a connected $1$-type $X$ with $\pi_1 X = G$, the monoid $[X,X]$ of homotopy classes of self-maps is isomorphic to the monoid $\mathrm{ConjEnd}(G)$ of conjugacy classes of endomorphisms of $G$; a class is invertible precisely when it is represented by an equivalence; and therefore the group of homotopy self-equivalences satisfies $\mathrm{hAut}(X)\cong\mathrm{Out}(G)$, while the self-homotopies of the identity form the centre $Z(G)$. This determines the automorphism $2$-group of every connected $1$-type.

We then remove connectedness entirely. For an arbitrary family $(C_i)_{i\in\iota}$ of connected $1$-types we prove a **matrix normal form**: $\bigl[\bigsqcup_i C_i,\bigsqcup_i C_i\bigr]$ is isomorphic to the monoid of pairs $\langle\sigma,P\rangle$ with $\sigma:\iota\to\iota$ and $P_i\in[C_i,C_{\sigma(i)}]$. Passing to units yields the exact sequence
$$1 \to \prod_i \mathrm{Out}(\pi_1 C_i) \to \mathrm{hAut}\Bigl(\bigsqcup_i C_i\Bigr) \to \mathrm{Sym}'(\pi_0) \to 1,$$
where $\mathrm{Sym}'(\pi_0)$ consists of those permutations of the components preserving homotopy type; the self-homotopies of the identity form $\prod_i Z(\pi_1 C_i)$. Since every $1$-type decomposes as the disjoint union of its components, this determines the automorphism $2$-group of an arbitrary $1$-type. We recover both extremes — the wreath product $\mathrm{Out}(G)\wr\mathrm{Sym}(\iota)$ for a constant family, the symmetric group $\mathrm{Sym}(\pi_0)$ for a discrete family — and give explicit computations: $\mathrm{hAut}(S^1)\cong\mathbb{Z}/2$ with the degree monoid $(\mathbb{Z},\cdot)$; $\mathrm{hAut}(T^n)\cong\mathrm{GL}_n(\mathbb{Z})$; $\mathrm{hAut}(K(\mathbb{Z}/n,1))\cong(\mathbb{Z}/n)^\times$ of order $\varphi(n)$; rigidity of $K(S_3,1)$; and the four-element symmetry group of $K(\mathbb{Z},1)\sqcup K(\mathbb{Z}/3,1)$.

**Keywords.** Eilenberg–MacLane space, aspherical space, fundamental group, groupoid, outer automorphism group, homotopy self-equivalence, wreath product, Euler totient function.

---

## 1. Introduction

### 1.1 The problem

The fundamental group is the oldest algebraic invariant of a topological space, and it is famously incomplete: $S^2$ and a point have the same fundamental group and different homotopy types. It is therefore natural to isolate the class of spaces on which $\pi_1$ *is* complete, and to ask how much of the homotopy theory of that class is visible in group theory alone.

The class is well known: the **homotopy $1$-types**, i.e. spaces all of whose higher homotopy groups vanish. A connected one with fundamental group $G$ is an Eilenberg–MacLane space $K(G,1)$, also called aspherical. Such spaces exist for every group and are unique up to homotopy equivalence. What is less often spelled out in full is the *complete* dictionary: not only the objects, but the mapping spaces, the self-equivalence groups, and the higher automorphism structure — and not only in the connected case.

The purpose of this paper is to write that dictionary down in complete generality, with no connectedness assumptions anywhere, and to demonstrate it on a range of explicit examples.

### 1.2 The groupoid model

Throughout, we adopt the algebraic model of homotopy $1$-types. Given a space $X$, its **fundamental groupoid** $\Pi_1 X$ has the points of $X$ as objects and homotopy classes of paths as morphisms. This construction induces an equivalence between the homotopy category of $1$-types and the homotopy category of groupoids, under which:

| topology | groupoid model |
|---|---|
| space | groupoid $C$ |
| path component set $\pi_0 X$ | set of isomorphism classes of objects |
| $\pi_1(X,x)$ | vertex group $\mathrm{Aut}(x)$ |
| continuous map | functor |
| homotopy of maps | natural isomorphism of functors |
| homotopy equivalence | equivalence of categories |
| $K(G,1)$ | connected groupoid with vertex group $G$ |
| disjoint union | coproduct of groupoids |

We therefore use "$1$-type" and "groupoid" interchangeably, "map" for "functor", and "homotopic" for "naturally isomorphic". The simplest model of $K(G,1)$ is the **one-object groupoid** $BG$ with a single object $\star$ and $\mathrm{Aut}(\star) = G$; it is connected with vertex group $G$, hence equivalent to any other model.

### 1.3 Notation

For groupoids $A,B$ we write $[A,B]$ for the set of natural-isomorphism classes of functors $A\to B$, and $\llbracket F\rrbracket$ for the class of a functor $F$. Composition makes $[A,A]$ a monoid, which we denote $\mathrm{hEnd}(A)$; we write $\mathrm{hAut}(A) := \mathrm{hEnd}(A)^\times$ for its group of units. For a group $G$, $\mathrm{Aut}(G)$, $\mathrm{Inn}(G)$, $\mathrm{Out}(G) = \mathrm{Aut}(G)/\mathrm{Inn}(G)$, and $Z(G)$ have their usual meanings, and $\mathrm{ConjEnd}(G) := \mathrm{End}(G)/\!\sim$ denotes the set of endomorphisms modulo the conjugation action $\phi \sim c_a\circ\phi$, $c_a(g)=aga^{-1}$. We say a groupoid $C$ is **connected at $c$** if every object is isomorphic to $c$.

---

## 2. The connected case

### 2.1 Classification of objects and maps

We take as our foundation the following two statements, which express that $\pi_1$ is a complete invariant on connected $1$-types.

> **Theorem 2.1 (Complete invariance).** Two connected $1$-types are homotopy equivalent if and only if their fundamental groups are isomorphic. More precisely, if $C$ is connected at $c$ and $D$ is connected at $d$, then an isomorphism $\mathrm{Aut}(c)\cong\mathrm{Aut}(d)$ of groups gives rise to an equivalence $C \simeq D$, and conversely every equivalence $C\simeq D$ induces such an isomorphism.

*Proof sketch.* Connectedness lets one choose, for each object $x$, an isomorphism $u_x : c \to x$ (with $u_c = \mathrm{id}$). Given a group isomorphism $\theta : \mathrm{Aut}(c)\to\mathrm{Aut}(d)$, define a functor on objects by a chosen bijection-free construction through the one-object model: both $C$ and $D$ are equivalent to the one-object groupoids on their vertex groups, via the functors classifying the chosen paths, and $\theta$ induces an isomorphism of those one-object groupoids. Composing the three equivalences yields $C\simeq D$. Conversely, an equivalence $E : C\simeq D$ gives a group isomorphism $\mathrm{Aut}(c)\to\mathrm{Aut}(E c)$ by functoriality, and conjugating by a chosen isomorphism $d \to Ec$ (available by connectedness) lands in $\mathrm{Aut}(d)$. $\square$

> **Theorem 2.2 (Classification of maps).** For connected $1$-types $C$ (at $c$) and $D$ (at $d$) with $G=\mathrm{Aut}(c)$ and $H=\mathrm{Aut}(d)$, there is a natural bijection
> $$[C,D]\;\cong\;\mathrm{Hom}(G,H)/\text{conjugation by }H.$$

*Proof sketch.* A functor $F : C\to D$ induces $\mathrm{Aut}(c)\to\mathrm{Aut}(Fc)$; choosing an isomorphism $p : d\to Fc$ transports this to a homomorphism $\iota_p(F) : G\to H$. Changing $p$ replaces $\iota_p(F)$ by a conjugate, so the conjugacy class is well defined; a natural isomorphism $F\cong F'$ supplies a compatible comparison, so the class only depends on $\llbracket F\rrbracket$. Conversely a homomorphism $\phi : G\to H$ determines a functor $BG\to BH$, and composing with the equivalences $C\simeq BG$, $BH\simeq D$ gives a functor $C\to D$. The two constructions are mutually inverse. $\square$

The conjugation quotient is not a defect but the exact shadow of basepoint-freeness: conjugating a homomorphism corresponds to dragging the image of the basepoint around a loop, which is a homotopy.

### 2.2 The self-map monoid

Theorem 2.2 with $D=C$ is a bijection of *sets*. Both sides carry a monoid structure — composition of homotopy classes on the left, and composition of endomorphisms modulo conjugacy on the right (well defined because $c_a\phi \circ c_b\psi = c_{a\,\phi(b)}(\phi\psi)$).

> **Theorem 2.3 (Monoid classification).** For a connected $1$-type $C$ at $c$ with $G = \mathrm{Aut}(c)$, the bijection of Theorem 2.2 is an isomorphism of monoids
> $$\mathrm{hEnd}(C)\;\cong\;\mathrm{ConjEnd}(G).$$

*Proof sketch.* One checks that the induced-homomorphism construction sends the identity functor to the class of $\mathrm{id}_G$ and a composite $F\circ F'$ to the composite of the classes; the only subtlety is that the auxiliary chosen path in the definition of the induced homomorphism changes by conjugation under composition, which is invisible after passing to conjugacy classes. Bijectivity is Theorem 2.2. $\square$

Working at the level of monoids immediately yields a Whitehead-type criterion.

> **Theorem 2.4 (Invertibility criterion).** A class $\llbracket F\rrbracket\in\mathrm{hEnd}(C)$ is invertible if and only if $F$ is an equivalence.

*Proof sketch.* If $F$ is an equivalence with quasi-inverse $F^{-1}$, the unit and counit isomorphisms show $\llbracket F\rrbracket\llbracket F^{-1}\rrbracket=\llbracket F^{-1}\rrbracket\llbracket F\rrbracket=1$. Conversely, if $\llbracket F\rrbracket\llbracket G\rrbracket = \llbracket G\rrbracket\llbracket F\rrbracket = 1$ then there are natural isomorphisms $G\circ F\cong\mathrm{id}$ and $F\circ G\cong\mathrm{id}$; these are exactly the data of an adjoint equivalence after the standard triangle-identity correction. $\square$

Note that this criterion is stated for arbitrary $1$-types, not merely connected ones; it is the monoid-theoretic form of the statement that a self-map of a $1$-type is a homotopy equivalence iff it admits a homotopy inverse.

### 2.3 The main theorem in the connected case

> **Theorem 2.5 (Symmetry theorem).** Let $C$ be a $1$-type connected at $c$, with $G=\mathrm{Aut}(c)$. Then
> $$\mathrm{hAut}(C)\;\cong\;\mathrm{Out}(G)=\mathrm{Aut}(G)/\mathrm{Inn}(G).$$
> In particular $\#\mathrm{hAut}(C)=\#\mathrm{Out}(G)$.

*Proof sketch.* By Theorem 2.3, $\mathrm{hAut}(C)=\mathrm{hEnd}(C)^\times\cong\mathrm{ConjEnd}(G)^\times$. An endomorphism whose conjugacy class is invertible must be an automorphism (compose with a representative of the inverse class and use that conjugation preserves surjectivity and injectivity), so $\mathrm{ConjEnd}(G)^\times$ consists of the conjugacy classes of automorphisms; two automorphisms are conjugate exactly when they differ by an inner automorphism. Hence $\mathrm{ConjEnd}(G)^\times\cong\mathrm{Aut}(G)/\mathrm{Inn}(G)=\mathrm{Out}(G)$. $\square$

> **Theorem 2.6 (Self-homotopies of the identity).** For a $1$-type $C$ connected at $c$, the group $\mathrm{Aut}(\mathrm{id}_C)$ of self-homotopies of the identity is isomorphic to the centre $Z(\mathrm{Aut}(c))$.

*Proof sketch.* A natural automorphism $\alpha$ of $\mathrm{id}_C$ assigns to each object $x$ an element $\alpha_x\in\mathrm{Aut}(x)$, and naturality with respect to $\mathrm{Aut}(x)$ forces $\alpha_x$ to be central. Evaluation at $c$ gives a homomorphism $\mathrm{Aut}(\mathrm{id}_C)\to Z(\mathrm{Aut}(c))$; connectedness makes it injective (naturality along a chosen isomorphism $c\to x$ determines $\alpha_x$ from $\alpha_c$) and surjective (a central $z$ defines $\alpha_x := u_x z u_x^{-1}$, independent of the chosen $u_x$ by centrality, and this is natural). $\square$

Theorems 2.5 and 2.6 together compute the **automorphism $2$-group** $\mathrm{AUT}(C)$ of a connected $1$-type: its $\pi_0$ is $\mathrm{Out}(G)$ and its $\pi_1$ is $Z(G)$.

Two corollaries are worth recording.

> **Corollary 2.7 (Abelian case).** If $\pi_1$ is abelian then $\mathrm{Inn}=1$, so $\mathrm{hAut}(K(G,1))\cong\mathrm{Aut}(G)$.

> **Corollary 2.8 (Rigidity criterion).** If $G$ is complete (centreless with only inner automorphisms) then $K(G,1)$ is homotopy rigid: $\mathrm{hAut}=1$ and $\mathrm{Aut}(\mathrm{id})=1$.

---

## 3. Computations for connected $1$-types

### 3.1 The circle and the degree

Let $C = B\mathbb{Z}$ be the one-object model of $K(\mathbb{Z},1)$, i.e. the circle.

> **Theorem 3.1 (Degree).** $\mathrm{hEnd}(S^1)\cong(\mathbb{Z},\cdot)$ as monoids. Explicitly, every self-map has a **degree** $d\in\mathbb{Z}$; two self-maps are homotopic iff they have equal degree; degrees multiply under composition and the identity has degree $1$. A self-map is an equivalence iff its degree is $\pm 1$, whence $\#\mathrm{hAut}(S^1)=2$ and $\mathrm{hAut}(S^1)\cong\mathbb{Z}/2$.

*Proof sketch.* $\mathrm{End}(\mathbb{Z}) = \{n\mapsto dn\}\cong(\mathbb{Z},\cdot)$, and $\mathbb{Z}$ is abelian so conjugacy is trivial; apply Theorem 2.3. The unit group of $(\mathbb{Z},\cdot)$ is $\{\pm1\}$, and Theorem 2.4 identifies units with equivalences. $\square$

### 3.2 The $n$-torus and $\mathrm{GL}_n(\mathbb{Z})$

> **Theorem 3.2 (Torus).** $\mathrm{hAut}(T^n)\cong\mathrm{GL}_n(\mathbb{Z})$, the group of invertible $n\times n$ integer matrices.

*Proof sketch.* $T^n$ is a $K(\mathbb{Z}^n,1)$; by Corollary 2.7, $\mathrm{hAut}\cong\mathrm{Aut}(\mathbb{Z}^n)$. Additive automorphisms of an abelian group are exactly its $\mathbb{Z}$-linear automorphisms, and $\mathbb{Z}$-linear automorphisms of the free module $\mathbb{Z}^n$ are invertible integer matrices. $\square$

For $n=1$ this recovers $\{\pm 1\}$; for $n=2$ it is the classical statement that homotopy self-equivalences of the $2$-torus are classified by $\mathrm{GL}_2(\mathbb{Z})$.

### 3.3 Lens spaces and Euler's totient

> **Theorem 3.3 (Totient theorem).** For every $n\ge 1$,
> $$\mathrm{hAut}\bigl(K(\mathbb{Z}/n,1)\bigr)\;\cong\;(\mathbb{Z}/n)^{\times},\qquad \#\,\mathrm{hAut}\bigl(K(\mathbb{Z}/n,1)\bigr)=\varphi(n),$$
> where $\varphi$ is Euler's totient function.

*Proof sketch.* Model $K(\mathbb{Z}/n,1)$ as the one-object groupoid on the cyclic group of order $n$. Since it is abelian, Corollary 2.7 gives $\mathrm{hAut}\cong\mathrm{Aut}(\mathbb{Z}/n)$; an automorphism of $\mathbb{Z}/n$ is multiplication by a unit, giving $\mathrm{Aut}(\mathbb{Z}/n)\cong(\mathbb{Z}/n)^\times$, whose order is $\varphi(n)$ by definition of the totient. $\square$

Special cases: $\#\mathrm{hAut}(K(\mathbb{Z}/1,1))=\#\mathrm{hAut}(K(\mathbb{Z}/2,1))=1$ (homotopy rigidity), $\#\mathrm{hAut}(K(\mathbb{Z}/5,1))=4$, and for a prime $p$,
$$\#\mathrm{hAut}\bigl(K(\mathbb{Z}/p,1)\bigr)=p-1 .$$

The totient theorem is a genuine bridge between homotopy theory and elementary number theory: the number of homotopy classes of self-homotopy-equivalences of the infinite lens space $K(\mathbb{Z}/n,1)$ is a multiplicative arithmetic function of $n$, oscillating in a way that no continuity or dimension argument could predict.

### 3.4 Nonabelian examples: rigidity and nonabelian symmetry

> **Theorem 3.4 (Rigidity of $K(S_3,1)$).** Every automorphism of the symmetric group $S_3$ is inner; hence $\mathrm{Out}(S_3)=1$ and $K(S_3,1)$ is homotopy rigid. Since $Z(S_3)=1$, the identity map also admits no nontrivial self-homotopy.

*Proof sketch.* $S_3$ has trivial centre, so $\mathrm{Inn}(S_3)\cong S_3$ has order $6$; and $\mathrm{Aut}(S_3)$ embeds into the permutations of the three transpositions, hence has order at most $6$. Therefore $\mathrm{Aut}(S_3)=\mathrm{Inn}(S_3)$ and $\mathrm{Out}(S_3)=1$. Apply Theorems 2.5 and 2.6. $\square$

So a space with nonabelian, nontrivial fundamental group can be perfectly stiff.

> **Theorem 3.5 (Nonabelian symmetry group).** For the Klein four group $V=(\mathbb{Z}/2)^2$, $\mathrm{hAut}(K(V,1))\cong\mathrm{Aut}(V)\cong S_3$, of order $6$ and nonabelian.

*Proof sketch.* $V$ is abelian, so Corollary 2.7 applies; an automorphism of $V$ is determined by an arbitrary permutation of the three involutions, giving $\mathrm{Aut}(V)\cong S_3$. $\square$

Thus abelian $\pi_1$ does not imply abelian symmetry group.

---

## 4. Disconnected $1$-types

Every $1$-type is (equivalent to) the disjoint union of its connected components, so the connected results become a complete theory only after the disconnected case is handled. We fix a family $(C_i)_{i\in\iota}$ of groupoids, with $C_i$ connected at $c_i$, and write $\Sigma := \bigsqcup_{i\in\iota}C_i$.

### 4.1 The extreme cases

> **Theorem 4.1 (Totally disconnected $1$-types).** For a discrete groupoid on a set $\alpha$ (all vertex groups trivial),
> $$\mathrm{hEnd}\cong\mathrm{End}(\alpha)\quad\text{(the full transformation monoid)},\qquad \mathrm{hAut}\cong\mathrm{Sym}(\alpha),$$
> and there are no nontrivial self-homotopies of the identity.

*Proof sketch.* A functor between discrete categories is a function on objects, and naturally isomorphic functors agree on objects since the only morphisms are identities. This gives a monoid isomorphism with $\mathrm{End}(\alpha)$; passing to units gives $\mathrm{Sym}(\alpha)$. The last claim holds because all vertex groups, hence all centres, are trivial. $\square$

Theorems 2.5 and 4.1 are the two poles: purely algebraic and purely combinatorial. The general theorem must interpolate.

### 4.2 Homotopy classes of maps out of a disjoint union

Two structural facts organise the general case.

> **Lemma 4.2 (Maps out of a coproduct).** For any target $D$, restriction along the inclusions is a bijection
> $$\Bigl[\bigsqcup_i C_i,\;D\Bigr]\;\cong\;\prod_i\,[C_i,D].$$

*Proof sketch.* Functors out of a coproduct are exactly families of functors out of the summands, and a natural isomorphism of such functors is exactly a family of natural isomorphisms. The only care needed is that the choice of comparison isomorphisms can be made independently on each summand, which is legitimate by the axiom of choice. $\square$

> **Lemma 4.3 (Factorization through one component).** Let $A$ be connected at $a$ and $F : A\to\bigsqcup_i C_i$ a functor. Then there is a unique index $j$ (namely the first coordinate of $F(a)$) and a functor $P : A\to C_j$ with $F\cong \mathrm{incl}_j\circ P$. Moreover, if $\mathrm{incl}_j\circ P\cong\mathrm{incl}_k\circ Q$ then $j=k$ and $P\cong Q$.

*Proof sketch.* The image of a connected groupoid is connected, and the components of a coproduct are the components of the summands, so all objects $F(x)$ lie over the same index $j$; define $P(x)$ to be the second coordinate, and the same for morphisms, using that morphisms in the coproduct between objects over $j$ are exactly morphisms in $C_j$. The uniqueness statement follows because a natural isomorphism between functors into the coproduct has components that are morphisms of the coproduct, hence forces the indices to agree, and its components then form a natural isomorphism $P\cong Q$. $\square$

Lemma 4.3 is the technical heart of the paper: it is what turns an arbitrary self-map of a disconnected $1$-type into a matrix.

### 4.3 The matrix normal form

**Definition 4.4 (The matrix monoid).** Let $\mathrm{Wr}(C)$ be the set of pairs $\langle\sigma,P\rangle$ where $\sigma:\iota\to\iota$ is a function and $P$ assigns to each $i$ a homotopy class $P_i\in[C_i,C_{\sigma(i)}]$. Define
$$\langle\sigma,P\rangle\cdot\langle\tau,Q\rangle \;=\; \bigl\langle\, \sigma\circ\tau,\; i\mapsto Q_i \text{ then } P_{\tau(i)} \,\bigr\rangle,$$
with unit $\langle\mathrm{id},(\llbracket\mathrm{id}_{C_i}\rrbracket)_i\rangle$. This is a monoid; one should think of $\langle\sigma,P\rangle$ as an $\iota\times\iota$ matrix with entry $P_i$ in position $(\sigma(i),i)$ and no other nonzero entries, multiplied by the usual rule.

> **Theorem 4.5 (Matrix normal form for self-maps).** For any family $(C_i)$ of connected $1$-types there is an isomorphism of monoids
> $$\mathrm{hEnd}\Bigl(\bigsqcup_i C_i\Bigr)\;\cong\;\mathrm{Wr}(C).$$
> Explicitly, the class of a functor $F$ corresponds to the index map $i\mapsto \mathrm{pr}_1 F(c_i)$ together with the classes of the components of $F$ supplied by Lemma 4.3.

*Proof sketch.* The map $\mathrm{Wr}(C)\to\mathrm{hEnd}(\Sigma)$ sends $\langle\sigma,P\rangle$ to the class of the functor assembled from representatives via the universal property of the coproduct; Lemma 4.2 (well-definedness) and Lemma 4.3 (independence of representatives) show this is well defined. Multiplicativity is a direct computation with the coproduct description of composition. Injectivity follows from the uniqueness half of Lemma 4.3 applied at each basepoint $c_i$; surjectivity follows from its existence half applied to the restriction of $F$ to each summand, using Lemma 4.2. $\square$

Theorem 4.5 classifies *all* self-maps, not only the equivalences, and specialises to Theorem 4.1 (all $C_i$ terminal) and Theorem 2.3 ($\iota$ a singleton).

### 4.4 The symmetry group of a disconnected $1$-type

Restricting Theorem 4.5 to units gives, for each self-equivalence, a *bijective* index map, hence a group homomorphism
$$\pi : \mathrm{hAut}(\Sigma)\longrightarrow\mathrm{Sym}(\iota),$$
computed on representatives by $\pi(u)(i)=\mathrm{pr}_1 F(c_i)$ for any representing functor $F$. We identify its image and its kernel.

> **Theorem 4.6 (Image: only look-alikes may be permuted).** A permutation $\sigma\in\mathrm{Sym}(\iota)$ lies in the image of $\pi$ if and only if $C_i\simeq C_{\sigma(i)}$ for every $i$.

*Proof sketch.* ($\Rightarrow$) If $u$ has representative $F$, an equivalence by Theorem 2.4, then $F$ restricts to an equivalence of the component of $c_i$ with the component of $F(c_i)$; by Theorem 2.1 (in the form "an isomorphism of vertex groups yields an equivalence") this gives $C_i\simeq C_{\sigma(i)}$. ($\Leftarrow$) Choose equivalences $E_i : C_i\simeq C_{\sigma(i)}$ and assemble them along $\sigma$ into a functor $\Sigma\to\Sigma$. Because $\sigma$ is a bijection, the assembled functor is full, faithful and essentially surjective, hence an equivalence, and its class is a unit by Theorem 2.4 with index map $\sigma$. $\square$

We write $\mathrm{Sym}'(\pi_0) := \mathrm{im}\,\pi = \{\sigma : \forall i,\ C_i\simeq C_{\sigma(i)}\}$, the group of **homotopy-type-preserving permutations of the components**.

> **Theorem 4.7 (Kernel).** $\ker\pi\;\cong\;\prod_i\mathrm{Out}(\pi_1 C_i)$.

*Proof sketch.* Under the matrix normal form, a unit lies in $\ker\pi$ iff its index map is the identity, i.e. it is a "diagonal matrix" whose $i$-th entry is a unit of $\mathrm{hEnd}(C_i)$. The diagonal embedding $\prod_i\mathrm{hAut}(C_i)\to\mathrm{hAut}(\Sigma)$ is therefore injective with image $\ker\pi$: injectivity is immediate from Theorem 4.5, and surjectivity onto the kernel follows because an entrywise inverse of a diagonal unit is again diagonal, so each entry is separately invertible. Now apply Theorem 2.5 to each factor. $\square$

Combining:

> **Theorem 4.8 (Structure theorem).** For an arbitrary family of connected $1$-types the sequence
> $$1\longrightarrow\prod_i\mathrm{Out}\bigl(\pi_1C_i\bigr)\longrightarrow\mathrm{hAut}\Bigl(\bigsqcup_iC_i\Bigr)\stackrel{\pi}{\longrightarrow}\mathrm{Sym}'(\pi_0)\longrightarrow1$$
> is exact. Furthermore, the self-homotopies of the identity satisfy
> $$\mathrm{Aut}\bigl(\mathrm{id}_{\Sigma}\bigr)\;\cong\;\prod_i Z\bigl(\pi_1C_i\bigr).$$

*Proof sketch.* Exactness is Theorems 4.6 and 4.7. For the last claim, restriction along the inclusion $C_i\hookrightarrow\Sigma$ (which is fully faithful) sends a self-homotopy of $\mathrm{id}_\Sigma$ to one of $\mathrm{id}_{C_i}$, and assembling a family of self-homotopies of the identities of the summands gives an inverse construction; the two are mutually inverse group isomorphisms. Applying Theorem 2.6 to each summand gives $\prod_i Z(\pi_1 C_i)$. $\square$

Since every $1$-type is the disjoint union of its components, Theorem 4.8 determines the automorphism $2$-group of an **arbitrary** homotopy $1$-type: $\pi_0$ is an extension of the type-preserving permutations of $\pi_0$ by the product of the outer automorphism groups, and $\pi_1$ is the product of the centres.

### 4.5 The two extremes recovered

> **Corollary 4.9 (Constant family: the wreath product).** If $C_i = D$ for all $i$, with $D$ connected with fundamental group $G$, then every permutation of the components is realised, the extension splits, and
> $$\mathrm{hAut}\Bigl(\bigsqcup_{i\in\iota}K(G,1)\Bigr)\;\cong\;\mathrm{Out}(G)\wr\mathrm{Sym}(\iota)\;=\;\bigl(\iota\to\mathrm{Out}(G)\bigr)\rtimes\mathrm{Sym}(\iota).$$
> In particular for $\iota$ of size $n$ the order is $|\mathrm{Out}(G)|^{\,n}\cdot n!$.

*Proof sketch.* Surjectivity of $\pi$ is Theorem 4.6 with $C_i\simeq C_{\sigma(i)}$ witnessed by the identity. A splitting is given by permuting the copies with identity entries; that this is a group homomorphism is a direct matrix computation. The semidirect product structure is then the standard consequence of a split exact sequence, and the action of $\mathrm{Sym}(\iota)$ on $\prod_i\mathrm{Out}(G)$ is by permuting factors, which is the wreath product. $\square$

> **Corollary 4.10 (Pairwise inequivalent components).** If $C_i\simeq C_j$ implies $i=j$, then $\pi$ is trivial and
> $$\mathrm{hAut}\Bigl(\bigsqcup_iC_i\Bigr)\;\cong\;\prod_i\mathrm{Out}(\pi_1C_i),\qquad \#\mathrm{hAut}=\prod_i\#\mathrm{Out}(\pi_1C_i)\ \ (\iota\text{ finite}).$$

*Proof sketch.* By Theorem 4.6 every $\sigma$ in the image satisfies $C_i\simeq C_{\sigma(i)}$, hence $\sigma(i)=i$ by hypothesis. Thus $\ker\pi$ is everything, and Theorem 4.7 applies. $\square$

Finally, the general counting formula for a finite family, obtained by grouping the components into homotopy types: if the components fall into homotopy types with multiplicities $m_1,\dots,m_r$, then
$$\#\,\mathrm{hAut}\Bigl(\bigsqcup_{i=1}^{n}C_i\Bigr)\;=\;\Bigl(\prod_{i=1}^{n}\#\mathrm{Out}(\pi_1C_i)\Bigr)\cdot\prod_{k=1}^{r}m_k! ,$$
valid whenever all the factors are finite, since $\mathrm{Sym}'(\pi_0)\cong\prod_k\mathrm{Sym}(m_k)$.

---

## 5. Worked examples for disconnected $1$-types

### 5.1 A rigid two-piece example

Consider $X = K(\mathbb{Z},1)\sqcup K(\mathbb{Z}/3,1)$: a circle next to an infinite lens space.

> **Theorem 5.1.** The two components of $X$ are not homotopy equivalent; consequently no self-homotopy-equivalence of $X$ interchanges them, and
> $$\#\,\mathrm{hAut}(X)\;=\;\#\mathrm{Out}(\mathbb{Z})\cdot\#\mathrm{Out}(\mathbb{Z}/3)\;=\;2\cdot 2\;=\;4 .$$

*Proof sketch.* If the components were equivalent, Theorem 2.1 would give a group isomorphism $\mathbb{Z}\cong\mathbb{Z}/3$; but $\mathbb{Z}$ is infinite and $\mathbb{Z}/3$ is finite, a contradiction. So the family is pairwise inequivalent and Corollary 4.10 applies. Now $\mathrm{Out}(\mathbb{Z})=\mathrm{Aut}(\mathbb{Z})=\{\pm1\}$ has order $2$, and $\mathrm{Out}(\mathbb{Z}/3)=(\mathbb{Z}/3)^\times$ has order $\varphi(3)=2$ by Theorem 3.3. $\square$

The four symmetries are the pairs $(\pm1,\pm1)$: reflect the circle or not, and invert the lens space or not.

### 5.2 A purely combinatorial example

> **Theorem 5.2.** The disjoint union of three copies of $K(S_3,1)$ has exactly $3!=6$ homotopy classes of self-homotopy-equivalences, all of which are relabellings of the copies.

*Proof sketch.* By Theorem 3.4, $\mathrm{Out}(S_3)=1$, so Corollary 4.9 gives $\mathrm{hAut}\cong 1\wr\mathrm{Sym}(3)\cong\mathrm{Sym}(3)$ of order $6$. $\square$

### 5.3 A mixed example

> **Theorem 5.3.** The disjoint union of two copies of $K(V,1)$, $V$ the Klein four group, has $6^2\cdot 2 = 72$ homotopy classes of self-homotopy-equivalences.

*Proof sketch.* $\#\mathrm{Out}(V)=\#\mathrm{Aut}(V)=6$ by Theorem 3.5; Corollary 4.9 with $n=2$ gives $6^2\cdot 2!=72$. $\square$

### 5.4 A universal realisation statement

> **Theorem 5.4 (Every permutation is realised in a constant family).** If $D$ is a connected $1$-type and $\iota$ any index set, then for every $\sigma\in\mathrm{Sym}(\iota)$ there is a homotopy self-equivalence of $\bigsqcup_{i\in\iota}D$ inducing $\sigma$ on components.

*Proof sketch.* Immediate from Theorem 4.6, since $D\simeq D$ for all $i$. $\square$

Theorems 5.1 and 5.4 exhibit the two extremes of the exact sequence of Theorem 4.8: in the first, the image of $\pi$ is trivial and $\mathrm{hAut}$ is the plain product of outer automorphism groups; in the second, the image of $\pi$ is everything.

---

## 6. Algorithms

The theory is effective for finite data. We record the three computations that turn the theorems into a calculator.

**Algorithm A (Outer automorphism order of a finite group).** Given a finite group $G$ by its multiplication table, enumerate the bijections $G\to G$ preserving the operation (pruning by generator images and by order preservation), obtaining $|\mathrm{Aut}(G)|$. Then $|\mathrm{Inn}(G)|=|G|/|Z(G)|$ by the first isomorphism theorem applied to $g\mapsto c_g$, and $|\mathrm{Out}(G)|=|\mathrm{Aut}(G)|/|\mathrm{Inn}(G)|$. With generator-image pruning the cost is $O(|G|^{d+1})$ where $d$ is the size of a generating set, which is small in practice.

**Algorithm B (Order of the symmetry group of a $1$-type).** Given a finite list of connected components, each specified by its fundamental group, first partition the components into homotopy types by testing isomorphism of fundamental groups (Theorem 2.1); if the multiplicities are $m_1,\dots,m_r$ then $|\mathrm{Sym}'(\pi_0)|=\prod_k m_k!$, and by Theorem 4.8 the total order is $\bigl(\prod_i|\mathrm{Out}(\pi_1C_i)|\bigr)\cdot\prod_k m_k!$; the order of the group of self-homotopies of the identity is $\prod_i|Z(\pi_1C_i)|$.

**Algorithm C (Matrix normal form of a self-map).** Given a self-map $F$ of a disjoint union, compute for each $i$ the index $\sigma(i)=\mathrm{pr}_1F(c_i)$ and the induced homomorphism $\pi_1C_i\to\pi_1C_{\sigma(i)}$ obtained by transporting $F$ along a chosen path from the basepoint of $C_{\sigma(i)}$ to $F(c_i)$; the pair $\langle\sigma,(\text{class of }\phi_i)\rangle$ is the normal form of Theorem 4.5, and $F$ is an equivalence iff $\sigma$ is a bijection and every $\phi_i$ is an isomorphism.

Algorithm C is the computational content of the whole theory: it reduces the comparison of two self-maps of a $1$-type — a homotopy-theoretic question — to comparing a permutation and finitely many conjugacy classes of homomorphisms.

---

## 7. Discussion

### 7.1 What has been achieved

The results above form a closed dictionary. Every homotopy-theoretic question about $1$-types has an exact algebraic answer:

| homotopy question | algebraic answer |
|---|---|
| when are two connected $1$-types equivalent? | when their $\pi_1$ are isomorphic |
| what are the maps $K(G,1)\to K(H,1)$? | $\mathrm{Hom}(G,H)/\mathrm{conj}$ |
| what is the monoid of self-maps? | $\mathrm{ConjEnd}(G)$ |
| which self-maps are equivalences? | those with invertible class, i.e. automorphisms |
| what is $\mathrm{hAut}$ of a connected $1$-type? | $\mathrm{Out}(G)$ |
| what are the self-homotopies of the identity? | $Z(G)$ |
| what are the self-maps of $\bigsqcup_i C_i$? | matrices $\langle\sigma,P\rangle$ |
| what is $\mathrm{hAut}$ of $\bigsqcup_i C_i$? | extension of $\mathrm{Sym}'(\pi_0)$ by $\prod_i\mathrm{Out}(\pi_1C_i)$ |
| what are its self-homotopies of the identity? | $\prod_i Z(\pi_1C_i)$ |

The last three rows are what removes the last hypothesis: earlier one had the connected case and the constant-family case, in which all components are copies of a single $K(G,1)$ and the answer is the wreath product $\mathrm{Out}(G)\wr\mathrm{Sym}(\iota)$. The matrix normal form covers a completely arbitrary family, and the wreath product reappears as the special case where all pieces look alike.

### 7.2 Interpretation

Two aspects deserve emphasis.

First, the appearance of $\mathrm{Out}$ rather than $\mathrm{Aut}$ is not a technicality; it is the precise homotopy-theoretic meaning of "inner". An inner automorphism is realised by transporting the basepoint around a loop, which is a homotopy and not new symmetry. Correspondingly, the automorphisms that are lost from $\pi_0$ reappear one level up: the group of self-homotopies of the identity is the centre $Z(G)$, which is exactly the kernel of $G\to\mathrm{Inn}(G)$. The automorphism $2$-group $(\mathrm{Out}\,G, Z(G))$ is thus the crossed module $G\to\mathrm{Aut}(G)$ in disguise, with its two invariants being exactly the cokernel and the kernel of that map.

Second, the structure theorem for disconnected $1$-types says that all "external" symmetry is relabelling of look-alike components and all "internal" symmetry is outer automorphisms, with no interaction beyond the evident permutation action. That the extension need not split in general is a real phenomenon of nonconstant families; it does split for a constant family, where a canonical splitting by pure relabelling exists.

### 7.3 Sharpness

The examples show that no clause of the theory can be dropped:

- $K(S_3,1)$ shows a nontrivial, nonabelian fundamental group can give a completely rigid space, so $\mathrm{hAut}$ is not detected by the size of $\pi_1$;
- $K(V,1)$ shows an abelian fundamental group can give a nonabelian symmetry group;
- $K(\mathbb{Z}/n,1)$ shows the order of $\mathrm{hAut}$ can oscillate arbitrarily with $n$, since $\varphi$ does;
- $K(\mathbb{Z},1)\sqcup K(\mathbb{Z}/3,1)$ shows the permutation part can be trivial even for a disconnected space with two components of equal symmetry order — the components have the same *number* of symmetries but different homotopy types, so no swap exists.

---

## 8. Future directions

This line of work studies **when the fundamental group is a complete invariant**, in the algebraic model where a homotopy $1$-type is a groupoid and a $K(G,1)$ is a connected groupoid with vertex group $G$. Previous work classified the objects (a connected $1$-type is determined by $\pi_1$), the maps ($[K(G,1),K(H,1)]\cong\mathrm{Hom}(G,H)/\mathrm{conj}$), and the automorphism $2$-group of a connected $1$-type ($\pi_0=\mathrm{Out}\,G$, $\pi_1=Z(G)$); then the description of $\mathrm{hAut}$ for a **disconnected** $1$-type in the constant-family case, together with the first nonabelian examples.

The present work removes the last hypothesis from that description: the components of the disjoint union no longer have to be copies of a single $K(G,1)$. For a completely arbitrary $1$-type the monoid of homotopy classes of self-maps is a matrix monoid, and
$$1\to\prod_i\mathrm{Out}(\pi_1C_i)\to\mathrm{hAut}\Bigl(\bigsqcup_iC_i\Bigr)\to\mathrm{Sym}'(\pi_0)\to1$$
is exact, with $\mathrm{Sym}'(\pi_0)$ the permutations of the components preserving their homotopy type; the self-homotopies of the identity are $\prod_iZ(\pi_1C_i)$.

Natural continuations:

1. **Non-splitting.** Determine exactly when the extension of Theorem 4.8 splits. It splits for a constant family; construct families where it does not, and describe the classifying cohomology class in $H^2(\mathrm{Sym}'(\pi_0);\ \cdot)$ for the induced action.
2. **Infinite index sets and topologised symmetry groups.** For infinite $\iota$ the group $\mathrm{Sym}'(\pi_0)$ carries a natural topology; investigate the resulting topological group structure on $\mathrm{hAut}$.
3. **More outer automorphism groups.** The theorems are only as useful as the $\mathrm{Out}$ computations available. Extend the library of computed examples to free groups ($\mathrm{Out}(F_n)$), surface groups (mapping class groups, by the Dehn–Nielsen–Baer theorem), and finitely generated abelian groups in general.
4. **Beyond $1$-types.** Move to $2$-types, where the invariants are $\pi_1$, $\pi_2$ as a $\pi_1$-module, and a $k$-invariant in $H^3(\pi_1;\pi_2)$, and ask for the corresponding description of $\mathrm{hAut}$ as an extension involving the automorphisms of the $k$-invariant.
5. **Equivariant and fibrewise versions.** Replace groupoids by groupoids over a fixed base, or by $G$-groupoids, and identify the corresponding symmetry groups.
6. **Effective computation.** Turn the matrix normal form into a decision procedure for homotopy of self-maps of finite $1$-types presented by finite groupoids, and analyse its complexity relative to the group isomorphism problem.

---

## 9. Conclusion

For homotopy $1$-types, topology and group theory coincide without remainder. The fundamental group classifies connected $1$-types; homotopy classes of maps are conjugacy classes of homomorphisms; the self-map monoid is the conjugacy-class monoid of endomorphisms; the symmetry group of a connected $1$-type is $\mathrm{Out}(\pi_1)$ and its higher symmetry group is $Z(\pi_1)$. Disconnected $1$-types are governed by a matrix monoid, and their symmetry groups are extensions of the type-preserving permutations of the components by the product of the outer automorphism groups. Every one of these statements is sharp, and the examples — degree on the circle, $\mathrm{GL}_n(\mathbb{Z})$ on the torus, Euler's totient on lens spaces, rigidity of $K(S_3,1)$ — show how the dictionary converts topological questions into arithmetic and combinatorial answers.
