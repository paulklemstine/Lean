# Derived Functors over the Integers: Explicit Resolutions, Complete Computation of $\operatorname{Ext}$ and $\operatorname{Tor}$ for Cyclic Groups, and Universal Coefficients

**Author:** Aristotle
**Date:** 2026-08-04

---

## Abstract

We develop, from first principles and in complete detail, the homological algebra of the category $\mathbf{Ab} = \mathbb{Z}\text{-}\mathbf{Mod}$ of abelian groups, organised around two explicit length-one resolutions: the free resolution $0 \to \mathbb{Z} \xrightarrow{\cdot k} \mathbb{Z} \to \mathbb{Z}/k \to 0$ of a cyclic group, and the injective resolution $0 \to \mathbb{Z} \to \mathbb{Q} \to \mathbb{Q}/\mathbb{Z} \to 0$ of the integers. From these two sequences, together with the long exact sequence in homology attached to a short exact sequence of complexes, we derive a self-contained account of the derived functors $\operatorname{Ext}^n$ and $\operatorname{Tor}_n$ over $\mathbb{Z}$.

Our main results are the following. (i) **Dimension bounds:** $\operatorname{Ext}^{n}(\mathbb{Z}/k, Y) = 0$ and $\operatorname{Tor}_{n}(G, \mathbb{Z}/k) = 0$ for all $n \geq 2$; $\operatorname{Ext}^{n}(X, \mathbb{Z}) = 0$ for all $n \geq 2$ and all $X$; and, more generally, $\operatorname{Ext}^{n}(X,Y) = 0$ for $n \ge 2$ whenever $X$ admits a projective presentation with projective kernel — in particular for every finitely generated abelian group $X$, whose presentation kernel is free by the structure theory of modules over a principal ideal domain. (ii) **Explicit degree-one computations:** an explicit surjection $Y \twoheadrightarrow \operatorname{Ext}^1(\mathbb{Z}/k,Y)$ with kernel $kY$, yielding the natural-looking isomorphism $\operatorname{Ext}^1(\mathbb{Z}/k, Y) \cong Y/kY$; consequently $\operatorname{Ext}^1(\mathbb{Z}/k,Y) = 0$ if and only if $Y$ is $k$-divisible, so $\operatorname{Ext}^1(\mathbb{Z}/k,\mathbb{Q}) = 0$ while $\operatorname{Ext}^1(\mathbb{Z}/k,\mathbb{Z}) \cong \mathbb{Z}/k \ne 0$ for $k \ge 2$. Dually $\operatorname{Tor}_1(G,\mathbb{Z}/k) \cong G[k]$ and $\operatorname{Tor}_0(G,\mathbb{Z}/k) = G \otimes \mathbb{Z}/k \cong G/kG$. (iii) **A five-way flatness criterion:** an abelian group $G$ is flat iff it is torsion-free iff multiplication by every nonzero $k$ is injective iff $\operatorname{Tor}_1(G,\mathbb{Z}/k) = 0$ for all $k \ne 0$ iff all higher $\operatorname{Tor}$ groups $\operatorname{Tor}_{n\ge1}(G,-)$ vanish; in particular $\mathbb{Z}/k$ is not flat for $k \geq 2$. (iv) **Universal coefficients:** for flat $G$ and any complex $C$ of modules over a commutative ring, $H_n(G \otimes C) \cong G \otimes H_n(C)$ in every degree and for every complex shape; and this fails for non-flat coefficients, as witnessed sharply by the two-term free complex $C = (\mathbb{Z} \xrightarrow{\cdot k} \mathbb{Z})$, for which $H_0(G \otimes C) \cong G \otimes H_0(C)$ and $H_1(G \otimes C) \cong \operatorname{Tor}_1(G, H_0(C))$, exhibiting the two extreme cases of the universal coefficient sequence in isolation.

**Keywords:** derived functors, Ext, Tor, projective resolution, injective resolution, long exact sequence, flatness, torsion, universal coefficient theorem, hereditary ring.

---

## 1. Introduction

### 1.1 Motivation

The two fundamental constructions on modules — the tensor product $-\otimes_R-$ and the hom-functor $\operatorname{Hom}_R(-,-)$ — are *not* exact. Tensoring preserves cokernels but not kernels; $\operatorname{Hom}$ preserves kernels but not cokernels. Homological algebra is the systematic study of the resulting discrepancies. Rather than treating non-exactness as a defect, one constructs a sequence of functors $\operatorname{Tor}_n$ and $\operatorname{Ext}^n$ measuring it, with the property that $\operatorname{Tor}_0 = \otimes$, $\operatorname{Ext}^0 = \operatorname{Hom}$, and any short exact sequence in either variable produces an infinite exact sequence linking all degrees.

Over the integers this programme reaches a particularly satisfying conclusion, because $\mathbb{Z}$ is a **hereditary** ring: every submodule of a projective is projective. The consequence is that all resolutions can be taken of length one, and the entire theory concentrates in degrees $0$ and $1$. This paper carries out that programme concretely, with all resolutions built by hand and all degree-one groups computed in closed form.

### 1.2 Conventions

All rings are unital; $R$ denotes a commutative ring and $\mathbf{Mod}_R$ the abelian category of $R$-modules. The unqualified word *module* means $\mathbb{Z}$-module, i.e. abelian group. For $k \in \mathbb{N}$ and a module $G$ we write
$$G[k] := \{ g \in G : kg = 0 \}, \qquad kG := \{ kg : g \in G\},$$
for the $k$-torsion subgroup and the subgroup of $k$-multiples. A module $Y$ is **$k$-divisible** if $kY = Y$, and **divisible** if it is $k$-divisible for all $k \ge 1$. We write $\mathbb{Z}/k$ for the cyclic group of order $k$ (so $\mathbb{Z}/0 = \mathbb{Z}$; all statements involving $\mathbb{Z}/k$ below carry the hypothesis $k \ne 0$ unless noted). Complexes are indexed over an arbitrary shape where possible; "chain complex" means differentials lower the degree, "cochain complex" that they raise it.

### 1.3 Summary of contributions

Section 2 recalls the relevant good objects and constructs the two explicit resolutions. Section 3 states the long exact sequence in homology in the element-wise form actually used in computations and records four consequences. Section 4 establishes the dimension bounds for $\operatorname{Ext}$. Section 5 computes $\operatorname{Ext}^1(\mathbb{Z}/k,Y) \cong Y/kY$ and its corollaries. Section 6 treats $\operatorname{Tor}$: degree zero, vanishing against flat modules, the computation $\operatorname{Tor}_1(G,\mathbb{Z}/k) \cong G[k]$, and the five-way flatness criterion. Section 7 gives the universal coefficient results. Section 8 collects algorithms; Sections 9–10 discuss applications and open directions.

---

## 2. Good objects and explicit resolutions

### 2.1 Projective, injective, flat

**Definition 2.1.** An $R$-module $P$ is **projective** if the functor $\operatorname{Hom}_R(P,-)$ is exact; equivalently, if every epimorphism $M \twoheadrightarrow P$ splits; equivalently, if $P$ is a direct summand of a free module.

**Definition 2.2.** An $R$-module $I$ is **injective** if $\operatorname{Hom}_R(-,I)$ is exact; equivalently, if every homomorphism into $I$ defined on a submodule extends to the ambient module.

**Definition 2.3.** An $R$-module $G$ is **flat** if $G \otimes_R -$ is exact; since tensoring is always right exact, this amounts to $G \otimes_R -$ preserving injections.

Over $\mathbb{Z}$ these three notions have elementary characterisations. Projective $=$ free (a subgroup of a free abelian group is free). Injective $=$ divisible: **Baer's criterion** says it suffices to extend homomorphisms defined on ideals $k\mathbb{Z} \subseteq \mathbb{Z}$, and such an extension exists exactly when the target is $k$-divisible for all $k$. Flat $=$ torsion-free (Theorem 6.7 below).

**Example 2.4.** $\mathbb{Q}$ is divisible, hence an injective $\mathbb{Z}$-module. The quotient $\mathbb{Q}/\mathbb{Z}$ is divisible (a quotient of a divisible group is divisible), hence also injective. $\mathbb{Z}$ is *not* divisible, hence not injective.

### 2.2 The free resolution of a cyclic group

**Theorem 2.5 (Standard free resolution of $\mathbb{Z}/k$).** Let $k \neq 0$. Write $\mu_k : \mathbb{Z} \to \mathbb{Z}$ for multiplication by $k$ and $\pi_k : \mathbb{Z} \to \mathbb{Z}/k$ for reduction. Then
$$\mathcal{R}_k : \quad 0 \longrightarrow \mathbb{Z} \xrightarrow{\ \mu_k\ } \mathbb{Z} \xrightarrow{\ \pi_k\ } \mathbb{Z}/k \longrightarrow 0$$
is a short exact sequence of $\mathbb{Z}$-modules with both $\mathbb{Z}$'s free, hence projective.

*Proof.* $\pi_k \circ \mu_k = 0$ since $k \equiv 0 \bmod k$. Injectivity of $\mu_k$: if $ka = kb$ then $a = b$, because $\mathbb{Z}$ is an integral domain and $k \ne 0$. Surjectivity of $\pi_k$: every residue class is the class of an integer. Exactness in the middle: $\pi_k(x) = 0$ means $k \mid x$, i.e. $x = \mu_k(y)$ for some $y$. $\square$

Placed as a chain complex $C^{(k)}$ concentrated in degrees $0$ and $1$,
$$C^{(k)} : \quad \cdots \to 0 \to 0 \to \mathbb{Z} \xrightarrow{\ \mu_k\ } \mathbb{Z} \qquad (\text{degrees } 1 \text{ and } 0),$$
together with the augmentation $\pi_k$ in degree zero, this is a **projective resolution** of $\mathbb{Z}/k$: the objects are free, the augmentation is a quasi-isomorphism onto $\mathbb{Z}/k$ concentrated in degree zero. Concretely, $H_0(C^{(k)}) = \operatorname{coker}\mu_k = \mathbb{Z}/k$ and $H_n(C^{(k)}) = 0$ for $n \geq 1$ (in degree $1$ because $\mu_k$ is injective; in higher degrees because the objects are zero).

### 2.3 The injective resolution of $\mathbb{Z}$

**Theorem 2.6 (Standard injective resolution of $\mathbb{Z}$).** The sequence
$$\mathcal{Q} : \quad 0 \longrightarrow \mathbb{Z} \xrightarrow{\ \iota\ } \mathbb{Q} \xrightarrow{\ p\ } \mathbb{Q}/\mathbb{Z} \longrightarrow 0$$
with $\iota$ the inclusion and $p$ the quotient map, is short exact, and $\mathbb{Q}$, $\mathbb{Q}/\mathbb{Z}$ are injective $\mathbb{Z}$-modules.

*Proof.* Exactness is immediate: $\iota$ is injective, $p$ is surjective, and $p(x) = 0$ iff $x \in \mathbb{Z}$. Injectivity of the two terms is Example 2.4. $\square$

Viewed as a cochain complex $\mathbb{Q} \to \mathbb{Q}/\mathbb{Z} \to 0 \to \cdots$ with augmentation $\iota$, this is an **injective resolution** of $\mathbb{Z}$ of length one.

**Remark 2.7 (Why length one is the whole story).** Both resolutions terminate after one step. This is the concrete manifestation of hereditarity of $\mathbb{Z}$. The general principle we exploit repeatedly is: if $F$ is an additive functor and $M$ has a projective resolution $P_\bullet$ with $P_n = 0$ for $n \geq 2$, then $(L_nF)(M) = H_n(F(P_\bullet)) = 0$ for $n \geq 2$, because $F(P_n) = F(0) = 0$. Dually for right derived functors and injective resolutions.

---

## 3. The long exact sequence in homology

Let $R$ be a ring, $c$ an arbitrary complex shape (so that both chain and cochain complexes are covered), and let
$$0 \longrightarrow X_1 \xrightarrow{\ f\ } X_2 \xrightarrow{\ g\ } X_3 \longrightarrow 0$$
be a short exact sequence of complexes of $R$-modules — meaning $f$ is a monomorphism, $g$ an epimorphism, and the sequence exact in the middle, degreewise.

**Theorem 3.1 (Long exact sequence).** There are connecting homomorphisms $\delta_{i,j} : H_i(X_3) \to H_j(X_1)$, defined whenever $j$ follows $i$ in the shape $c$, such that the following three sequences of $R$-module maps are exact at each indicated spot:

1. $H_i(X_1) \xrightarrow{H_i(f)} H_i(X_2) \xrightarrow{H_i(g)} H_i(X_3)$ — exact at $H_i(X_2)$;
2. $H_i(X_2) \xrightarrow{H_i(g)} H_i(X_3) \xrightarrow{\delta} H_j(X_1)$ — exact at $H_i(X_3)$;
3. $H_i(X_3) \xrightarrow{\delta} H_j(X_1) \xrightarrow{H_j(f)} H_j(X_2)$ — exact at $H_j(X_1)$.

Splicing these gives the familiar infinite staircase
$$\cdots \to H_i(X_1) \to H_i(X_2) \to H_i(X_3) \xrightarrow{\ \delta\ } H_j(X_1) \to H_j(X_2) \to \cdots$$

*Proof sketch.* The connecting map is the classical diagram chase (the "snake"): given a cycle $z \in X_3$ representing a class in $H_i(X_3)$, lift it to $\tilde z \in X_2$ (possible since $g$ is degreewise surjective); then $d\tilde z$ maps to $dz = 0$ under $g$, so by exactness $d\tilde z = f(w)$ for a unique $w \in X_1$, which is a cycle; set $\delta[z] := [w]$. Independence of the choices and exactness at all three spots are verified by further chases. In the module-theoretic setting all maps are honest $R$-linear maps between the homology modules, and each exactness statement can be read as the assertion that the image of one map equals the kernel of the next, elementwise. $\square$

The following four corollaries are what one actually applies.

**Corollary 3.2 (Acyclicity is inherited by the middle term).** If $H_i(X_1) = 0$ and $H_i(X_3) = 0$, then $H_i(X_2) = 0$.

*Proof.* Take $x \in H_i(X_2)$. Its image in $H_i(X_3)$ vanishes, so by exactness at $H_i(X_2)$ it comes from some $y \in H_i(X_1) = 0$; hence $x = H_i(f)(0) = 0$. $\square$

**Corollary 3.3 (The connecting map as an isomorphism).** If $H_i(X_2) = 0$ and $H_j(X_2) = 0$ where $j$ follows $i$, then $\delta : H_i(X_3) \to H_j(X_1)$ is bijective.

*Proof.* Injectivity: if $\delta(a) = \delta(b)$ then $\delta(a-b) = 0$, so $a - b$ lifts to $H_i(X_2) = 0$ by exactness at $H_i(X_3)$. Surjectivity: given $w \in H_j(X_1)$, its image in $H_j(X_2) = 0$ vanishes, so $w \in \operatorname{im}\delta$ by exactness at $H_j(X_1)$. $\square$

**Corollary 3.4.** If $H_k(X_3) = 0$ for the degree $k$ preceding $i$, then $H_i(f) : H_i(X_1) \to H_i(X_2)$ is injective.

**Corollary 3.5.** If $H_j(X_1) = 0$ for the degree $j$ following $i$, then $H_i(g) : H_i(X_2) \to H_i(X_3)$ is surjective.

Applied to derived functors, Theorem 3.1 yields the two long exact sequences for $\operatorname{Ext}$. For a short exact sequence $S : 0 \to A \to B \to C \to 0$ of modules and a fixed module $Y$:
$$\cdots \to \operatorname{Ext}^n(C,Y) \to \operatorname{Ext}^n(B,Y) \to \operatorname{Ext}^n(A,Y) \xrightarrow{\ \varepsilon_S \circ -\ } \operatorname{Ext}^{n+1}(C,Y) \to \cdots \tag{contravariant}$$
$$\cdots \to \operatorname{Ext}^n(X,A) \to \operatorname{Ext}^n(X,B) \to \operatorname{Ext}^n(X,C) \xrightarrow{\ -\circ\varepsilon_S\ } \operatorname{Ext}^{n+1}(X,A) \to \cdots \tag{covariant}$$
In both cases the connecting map is given by (Yoneda) composition with the **extension class** $\varepsilon_S \in \operatorname{Ext}^1(C,A)$ of the sequence $S$. This description of the connecting map — as composition with a single universal class — is what makes the computations of Sections 4 and 5 possible in closed form.

We will also use the two basic vanishing facts: $\operatorname{Ext}^n(P,Y) = 0$ for $n \geq 1$ when $P$ is projective, and $\operatorname{Ext}^n(X,I) = 0$ for $n \geq 1$ when $I$ is injective.

---

## 4. Dimension bounds for $\operatorname{Ext}$

**Theorem 4.1 (Projective dimension one for cyclic groups).** Let $k \neq 0$, let $Y$ be any $\mathbb{Z}$-module and let $n \geq 0$. Then
$$\operatorname{Ext}^{n+2}(\mathbb{Z}/k, Y) = 0 .$$

*Proof.* Apply the contravariant long exact sequence to the resolution $\mathcal{R}_k$ of Theorem 2.5, whose outer terms $A = \mathbb{Z}$ and $B = \mathbb{Z}$ are projective, and whose quotient is $C = \mathbb{Z}/k$. The relevant portion is
$$\operatorname{Ext}^{n+1}(\mathbb{Z},Y) \longrightarrow \operatorname{Ext}^{n+2}(\mathbb{Z}/k, Y) \longrightarrow \operatorname{Ext}^{n+2}(\mathbb{Z}, Y).$$
Both ends vanish because $\mathbb{Z}$ is projective and $n+1, n+2 \geq 1$. Explicitly: given $x \in \operatorname{Ext}^{n+2}(\mathbb{Z}/k,Y)$, its restriction to $\operatorname{Ext}^{n+2}(\mathbb{Z},Y)$ is zero, so by exactness $x = \varepsilon_{\mathcal{R}_k} \circ x_1$ for some $x_1 \in \operatorname{Ext}^{n+1}(\mathbb{Z},Y) = 0$; hence $x = 0$. $\square$

**Theorem 4.2 (Injective dimension one for $\mathbb{Z}$).** For every $\mathbb{Z}$-module $X$ and every $n \geq 0$,
$$\operatorname{Ext}^{n+2}(X, \mathbb{Z}) = 0 .$$

*Proof.* Dual argument using the covariant long exact sequence for the injective resolution $\mathcal{Q}$ of Theorem 2.6. Given $x \in \operatorname{Ext}^{n+2}(X,\mathbb{Z})$, exactness at that spot and the vanishing $\operatorname{Ext}^{n+1}(X,\mathbb{Q}) = \operatorname{Ext}^{n+2}(X,\mathbb{Q}) = 0$ (as $\mathbb{Q}$ is injective) produce $x_3 \in \operatorname{Ext}^{n+1}(X, \mathbb{Q}/\mathbb{Z}) = 0$ with $x = x_3 \circ \varepsilon_{\mathcal{Q}}$; hence $x = 0$. $\square$

Theorem 4.1 is a special case of a purely formal statement.

**Theorem 4.3 (Projective presentations with projective kernel).** Let $0 \to P_1 \to P_0 \to X \to 0$ be a short exact sequence of modules with $P_0$ and $P_1$ projective. Then $\operatorname{Ext}^{n+2}(X,Y) = 0$ for every module $Y$ and every $n \geq 0$.

*Proof.* Identical to Theorem 4.1, with $\mathbb{Z}, \mathbb{Z}$ replaced by $P_1, P_0$. $\square$

To apply Theorem 4.3 to a general finitely generated abelian group we need the presentation kernel to be projective, which over $\mathbb{Z}$ is automatic.

**Lemma 4.4 (Freeness of the kernel).** For any $n \in \mathbb{N}$, any $\mathbb{Z}$-module $X$ and any linear map $f : \mathbb{Z}^n \to X$, the kernel $\ker f$ is a free $\mathbb{Z}$-module.

*Proof.* $\ker f$ is a submodule of the finitely generated free module $\mathbb{Z}^n$ over the principal ideal domain $\mathbb{Z}$; every such submodule is free (of rank $\leq n$). $\square$

**Lemma 4.5 (The kernel presentation is short exact).** For a surjective linear map $f : M \to X$, the sequence $0 \to \ker f \hookrightarrow M \xrightarrow{f} X \to 0$ is short exact.

**Theorem 4.6 (Vanishing for finitely generated groups).** Let $X$ be a finitely generated $\mathbb{Z}$-module and $Y$ any $\mathbb{Z}$-module. Then
$$\operatorname{Ext}^{n+2}(X, Y) = 0 \qquad \text{for all } n \ge 0.$$

*Proof.* Choose a finite generating set $x_1,\dots,x_m$ of $X$ and let $f : \mathbb{Z}^m \to X$ be the linear map sending the $i$-th basis vector to $x_i$; $f$ is surjective because its image is the submodule generated by the $x_i$, which is all of $X$. By Lemma 4.5 the sequence $0 \to \ker f \to \mathbb{Z}^m \to X \to 0$ is short exact; by Lemma 4.4 the module $\ker f$ is free, hence projective, and $\mathbb{Z}^m$ is projective. Theorem 4.3 applies. $\square$

**Remark 4.7.** The conclusion of Theorem 4.6 in fact holds for *every* abelian group $X$ and every $Y$ — the ring $\mathbb{Z}$ is hereditary, so any submodule of any free module is free, and the same two-step argument works once one knows the (transfinite) freeness theorem for arbitrary subgroups of free abelian groups. The three cases established here — $X$ cyclic (Theorem 4.1), $Y = \mathbb{Z}$ (Theorem 4.2), $X$ finitely generated (Theorem 4.6) — cover all cases arising in practice.

---

## 5. $\operatorname{Ext}^1(\mathbb{Z}/k, Y) \cong Y/kY$

We now compute the only nonvanishing higher $\operatorname{Ext}$ group out of a cyclic group.

Fix $k \neq 0$ and a $\mathbb{Z}$-module $Y$. Let $\varepsilon = \varepsilon_{\mathcal{R}_k} \in \operatorname{Ext}^1(\mathbb{Z}/k, \mathbb{Z})$ be the class of the resolution $\mathcal{R}_k$.

**Definition 5.1.** For $y \in Y$, let $u_y : \mathbb{Z} \to Y$ be the unique homomorphism with $u_y(1) = y$, i.e. $u_y(n) = ny$. Define
$$\Phi_Y : Y \longrightarrow \operatorname{Ext}^1(\mathbb{Z}/k, Y), \qquad \Phi_Y(y) := (u_y)_* (\varepsilon) = \varepsilon \circ u_y,$$
the pushforward of the extension class along $u_y$.

**Lemma 5.2.** $\Phi_Y$ is a homomorphism of abelian groups.

*Proof.* $u_{y+z} = u_y + u_z$ (both send $1 \mapsto y+z$), and both Yoneda composition and the passage from a morphism to its degree-zero $\operatorname{Ext}$-class are additive. $\square$

**Theorem 5.3 (Surjectivity).** $\Phi_Y : Y \to \operatorname{Ext}^1(\mathbb{Z}/k, Y)$ is surjective.

*Proof.* Let $x \in \operatorname{Ext}^1(\mathbb{Z}/k,Y)$. Apply the contravariant long exact sequence of $\mathcal{R}_k$ in degree $1$:
$$\operatorname{Ext}^{0}(\mathbb{Z},Y) \xrightarrow{\ \varepsilon\circ -\ } \operatorname{Ext}^1(\mathbb{Z}/k,Y) \longrightarrow \operatorname{Ext}^1(\mathbb{Z},Y) = 0 .$$
The right-hand group vanishes since $\mathbb{Z}$ is projective, so the image of $x$ there is zero, and exactness gives $x_1 \in \operatorname{Ext}^0(\mathbb{Z},Y) = \operatorname{Hom}(\mathbb{Z},Y)$ with $x = \varepsilon \circ x_1$. Every homomorphism $\mathbb{Z}\to Y$ is $u_y$ for $y = x_1(1)$, so $x = \Phi_Y(y)$. $\square$

**Theorem 5.4 (The kernel).** For $y \in Y$,
$$\Phi_Y(y) = 0 \iff \exists z \in Y,\ kz = y .$$
That is, $\ker \Phi_Y = kY$.

*Proof.* ($\Leftarrow$) Suppose $y = kz$. Composition of degree-zero classes is induced by composition of morphisms, and $\mu_k \circ u_z = u_{kz} = u_y$, since $(\mu_k \circ u_z)(1) = u_z(k) = kz$. Hence $\Phi_Y(y) = \varepsilon \circ u_y = \varepsilon \circ (\mu_k \circ u_z) = (\varepsilon \circ \mu_k) \circ u_z$. But $\varepsilon \circ \mu_k = 0$: composing the class of a short exact sequence with the sequence's own first map is zero (two consecutive maps in the long exact sequence compose to zero). Hence $\Phi_Y(y) = 0$.

($\Rightarrow$) Suppose $\varepsilon \circ u_y = 0$. The relevant portion of the contravariant long exact sequence reads
$$\operatorname{Ext}^0(\mathbb{Z},Y) \xrightarrow{\ \mu_k^*\ } \operatorname{Ext}^0(\mathbb{Z},Y) \xrightarrow{\ \varepsilon\circ-\ } \operatorname{Ext}^1(\mathbb{Z}/k,Y),$$
where the first map is precomposition with $\mu_k$. Exactness at the middle spot gives $x_2 \in \operatorname{Hom}(\mathbb{Z},Y)$ with $x_2 \circ \mu_k = u_y$ — that is, $u_y = \mu_k^* x_2$. Evaluating at $1$: $y = x_2(k) = k\,x_2(1)$. So $z := x_2(1)$ works. $\square$

**Theorem 5.5 (Computation of $\operatorname{Ext}^1$ out of a cyclic group).** For $k \neq 0$ and any $\mathbb{Z}$-module $Y$ there is an isomorphism of abelian groups
$$Y/kY \;\xrightarrow{\ \cong\ }\; \operatorname{Ext}^1(\mathbb{Z}/k, Y), \qquad y + kY \longmapsto \varepsilon \circ u_y .$$

*Proof.* Combine Lemma 5.2, Theorem 5.3 and Theorem 5.4 with the first isomorphism theorem: a surjective homomorphism induces an isomorphism from the quotient by its kernel. $\square$

**Corollary 5.6 (Ext detects divisibility).** For $k \neq 0$,
$$\operatorname{Ext}^1(\mathbb{Z}/k, Y) = 0 \iff Y \text{ is } k\text{-divisible}.$$

**Corollary 5.7.** $\operatorname{Ext}^1(\mathbb{Z}/k, \mathbb{Q}) = 0$ for every $k \neq 0$.

*Proof.* $\mathbb{Q}$ is $k$-divisible: $q = k\cdot(q/k)$. Apply Corollary 5.6. Equivalently, $\mathbb{Q}/k\mathbb{Q} = 0$. $\square$

**Corollary 5.8.** For $k \geq 2$, $\operatorname{Ext}^1(\mathbb{Z}/k, \mathbb{Z}) \cong \mathbb{Z}/k \neq 0$; in particular there exists a nonzero class, and the extension $0 \to \mathbb{Z} \xrightarrow{\mu_k}\mathbb{Z}\to\mathbb{Z}/k\to 0$ does not split.

*Proof.* By Theorem 5.5, $\operatorname{Ext}^1(\mathbb{Z}/k,\mathbb{Z}) \cong \mathbb{Z}/k\mathbb{Z} = \mathbb{Z}/k$. For a direct argument that the group is nonzero: if every class vanished, Theorem 5.4 applied to $y = 1$ would give $z \in \mathbb{Z}$ with $kz = 1$, whence $k \mid 1$ and $k \leq 1$, contradicting $k \geq 2$. $\square$

**Remark 5.9 (Interpretation).** $\operatorname{Ext}^1(C,A)$ classifies extensions $0 \to A \to B \to C \to 0$ up to equivalence, with the zero class corresponding to the split extension $B = A \oplus C$. Corollary 5.7 therefore says: *every* extension of $\mathbb{Z}/k$ by $\mathbb{Q}$ splits. Corollary 5.8 says: there are exactly $k$ inequivalent extensions of $\mathbb{Z}/k$ by $\mathbb{Z}$, and only one of them is split.

---

## 6. $\operatorname{Tor}$, torsion, and flatness

### 6.1 Degree zero and flat vanishing

Let $R$ be a commutative ring. $\operatorname{Tor}_n^R(G,-)$ is defined as the $n$-th left derived functor of $G \otimes_R -$.

**Theorem 6.1 (Degree zero).** For all $R$-modules $G, M$ there is a natural isomorphism
$$\operatorname{Tor}_0^R(G,M) \cong G \otimes_R M .$$

*Proof.* The zeroth left derived functor of a right exact functor is canonically isomorphic to the functor itself: if $P_1 \to P_0 \to M \to 0$ is the tail of a projective resolution, right exactness gives $G\otimes P_1 \to G \otimes P_0 \to G\otimes M \to 0$ exact, so $H_0(G\otimes P_\bullet) = \operatorname{coker}(G\otimes P_1 \to G\otimes P_0) \cong G \otimes M$. $\square$

**Theorem 6.2 (Higher $\operatorname{Tor}$ against a flat module vanishes).** If $G$ is a flat $R$-module, then for every $R$-module $M$ and every $n \geq 0$,
$$\operatorname{Tor}_{n+1}^R(G, M) = 0 .$$

*Proof.* Choose a projective resolution $P_\bullet \to M$. By definition $\operatorname{Tor}_{n+1}(G,M) = H_{n+1}(G \otimes P_\bullet)$. Since $G$ is flat, $G \otimes -$ is an exact functor, and exact functors commute with homology: $H_{n+1}(G \otimes P_\bullet) \cong G \otimes H_{n+1}(P_\bullet)$. But $P_\bullet$ is a resolution, so it is exact in all positive degrees: $H_{n+1}(P_\bullet) = 0$. Hence the left side is $G \otimes 0 = 0$. $\square$

**Corollary 6.3 (Nonvanishing $\operatorname{Tor}$ obstructs flatness).** If $\operatorname{Tor}_{n+1}^R(G,M) \neq 0$ for some $n \ge 0$ and some $M$, then $G$ is not flat.

**Corollary 6.4.** Over $\mathbb{Z}$, $\operatorname{Tor}_{n+1}(\mathbb{Q},M) = 0$ and $\operatorname{Tor}_{n+1}(\mathbb{Z},M) = 0$ for every $M$ and every $n \ge 0$, since $\mathbb{Q}$ and $\mathbb{Z}$ are torsion-free, hence flat.

Dually to Theorem 4.1, the length-one resolution $C^{(k)}$ gives:

**Theorem 6.5 (Higher $\operatorname{Tor}$ against a cyclic group).** For $k \ne 0$, every $\mathbb{Z}$-module $G$ and every $n \geq 0$,
$$\operatorname{Tor}_{n+2}(G, \mathbb{Z}/k) = 0 .$$

*Proof.* $\operatorname{Tor}_{n+2}(G,\mathbb{Z}/k) = H_{n+2}(G \otimes C^{(k)})$, and $C^{(k)}_{n+2} = 0$, so $G \otimes C^{(k)}$ vanishes in degree $n+2$. More generally, for any additive functor $F$ and the same resolution, $(L_{n+2}F)(\mathbb{Z}/k) = 0$. $\square$

### 6.2 The first $\operatorname{Tor}$ group against a cyclic group

**Theorem 6.6 (Tor is torsion).** Let $k \ne 0$ and let $G$ be any $\mathbb{Z}$-module. Then
$$\operatorname{Tor}_1(G, \mathbb{Z}/k) \;\cong\; G[k] = \ker\big(k\cdot : G \to G\big), \qquad G \otimes \mathbb{Z}/k \;\cong\; G/kG .$$

*Proof.* Compute along the resolution $C^{(k)}$. Tensoring gives the complex
$$\cdots \to 0 \to G \otimes \mathbb{Z} \xrightarrow{\ 1_G \otimes \mu_k\ } G \otimes \mathbb{Z} \qquad(\text{degrees }1,0).$$
The right unitor $G \otimes \mathbb{Z} \cong G$ identifies $1_G \otimes \mu_k$ with multiplication by $k$ on $G$. Since the differential entering degree $1$ is zero (the complex vanishes in degree $2$), the degree-one homology is exactly the kernel of the outgoing differential:
$$\operatorname{Tor}_1(G,\mathbb{Z}/k) = H_1 = \ker(1_G\otimes\mu_k) \cong \ker(k\cdot) = G[k].$$
In degree zero, the outgoing differential is zero, so the homology is the cokernel of the incoming one:
$$\operatorname{Tor}_0(G,\mathbb{Z}/k) = H_0 = \operatorname{coker}(1_G\otimes\mu_k) \cong G/kG,$$
which agrees with Theorem 6.1. $\square$

**Corollary 6.6a.** For $k \geq 2$, $\operatorname{Tor}_1(\mathbb{Z}/k, \mathbb{Z}/k) \cong (\mathbb{Z}/k)[k] = \mathbb{Z}/k \neq 0$, since multiplication by $k$ is identically zero on $\mathbb{Z}/k$.

### 6.3 The flatness criterion

**Theorem 6.7 (Five equivalent formulations of flatness over $\mathbb{Z}$).** For an abelian group $G$ the following are equivalent:

1. $G$ is a flat $\mathbb{Z}$-module;
2. $G$ is torsion-free: for all $k \neq 0$ and $g \in G$, $kg = 0 \Rightarrow g = 0$;
3. for every $k \neq 0$, $\ker(k\cdot : G \to G) = 0$;
4. for every $k \neq 0$, $\operatorname{Tor}_1(G, \mathbb{Z}/k) = 0$;
5. for every $n \geq 0$ and every $\mathbb{Z}$-module $M$, $\operatorname{Tor}_{n+1}(G,M) = 0$.

*Proof.* (2) $\Leftrightarrow$ (3) is a restatement, using that a homomorphism has trivial kernel iff it is injective. (3) $\Leftrightarrow$ (4) is Theorem 6.6. (1) $\Rightarrow$ (5) is Theorem 6.2, and (5) $\Rightarrow$ (4) is the case $n=0$, $M = \mathbb{Z}/k$. It remains to prove (2) $\Rightarrow$ (1). Over a Bézout domain (in particular over the PID $\mathbb{Z}$) a module is flat if and only if its torsion submodule is trivial; concretely, torsion-freeness says every nonzero $r \in \mathbb{Z}$ acts injectively, i.e. is a regular element on $G$, and over $\mathbb{Z}$ this is exactly flatness. (For the reduction from an arbitrary nonzero integer $r$ to a natural number one replaces $r$ by $|r|$, which acts by $\pm$ the same map and has the same kernel.) $\square$

**Corollary 6.8.** For $k \geq 2$, $\mathbb{Z}/k$ is not flat.

*Proof.* $k \cdot 1 = 0$ in $\mathbb{Z}/k$ with $1 \neq 0$, so $\mathbb{Z}/k$ has torsion; apply (2)$\Rightarrow$(1) contrapositively. Alternatively, $\operatorname{Tor}_1(\mathbb{Z}/k,\mathbb{Z}/k) \cong \mathbb{Z}/k \ne 0$ and Corollary 6.3. $\square$

**Remark 6.9 (Duality of the two computations).** Theorems 5.5 and 6.6 are mirror images:
$$\operatorname{Ext}^1(\mathbb{Z}/k, Y) \cong Y/kY, \qquad \operatorname{Tor}_1(G, \mathbb{Z}/k) \cong G[k],$$
with degree-zero counterparts $\operatorname{Hom}(\mathbb{Z}/k,Y) \cong Y[k]$ and $G\otimes\mathbb{Z}/k \cong G/kG$. Passing from degree $0$ to degree $1$ interchanges "sub" and "quotient": $\operatorname{Hom}$ sees $Y[k]$ in degree $0$ and $Y/kY$ in degree $1$; $\otimes$ sees $G/kG$ in degree $0$ and $G[k]$ in degree $1$. Both pairs are computed from the same two-term resolution, read in opposite directions.

---

## 7. Universal coefficients

### 7.1 Flat coefficients: no correction term

**Theorem 7.1 (Universal coefficient theorem, flat case).** Let $R$ be a commutative ring, $G$ a flat $R$-module, $c$ an arbitrary complex shape, and $K$ any complex of $R$-modules of shape $c$. Then for every degree $n$ there is an isomorphism
$$H_n(G \otimes_R K) \;\cong\; G \otimes_R H_n(K).$$
Moreover the isomorphism is induced by the canonical comparison map, and is $R$-linear.

*Proof.* Flatness of $G$ means $G \otimes_R -$ is an exact functor. An exact additive functor between abelian categories commutes with the formation of homology of a short complex: it preserves kernels, cokernels and images, hence preserves $\ker d / \operatorname{im} d$. Applying this to the short complex $K_{n+1}\to K_n \to K_{n-1}$ extracted from $K$ at degree $n$ gives the claim. $\square$

**Corollary 7.2 (Flat coefficients preserve acyclicity).** If $G$ is flat and $H_n(K) = 0$, then $H_n(G\otimes K) = 0$.

*Proof.* By Theorem 7.1, $H_n(G\otimes K) \cong G \otimes 0 = 0$. $\square$

Theorem 7.1 explains why homology with rational (or real, or any torsion-free) coefficients is so much simpler than integral homology: for those coefficient groups the correction term of the general universal coefficient sequence is identically zero.

### 7.2 Non-flat coefficients: the correction term is real

For general $G$, the universal coefficient theorem asserts a natural short exact sequence
$$0 \longrightarrow G \otimes H_n(C) \longrightarrow H_n(G \otimes C) \longrightarrow \operatorname{Tor}_1\big(G, H_{n-1}(C)\big) \longrightarrow 0$$
for a complex $C$ of free modules. We now exhibit both extreme cases — pure tensor term, pure $\operatorname{Tor}$ term — in a single, minimal example, and thereby prove that the $\operatorname{Tor}$ term cannot be omitted.

Let $k \ne 0$ and let $C = C^{(k)}$ be the two-term free complex $\mathbb{Z}\xrightarrow{\mu_k}\mathbb{Z}$ of §2.2, so
$$H_0(C) \cong \mathbb{Z}/k, \qquad H_1(C) = 0, \qquad H_n(C) = 0 \ (n \geq 1).$$

**Theorem 7.3 (Degree zero: the tensor term alone).** For every $\mathbb{Z}$-module $G$ and $k \neq 0$,
$$H_0(G \otimes C^{(k)}) \;\cong\; G \otimes H_0(C^{(k)}) \;\cong\; G/kG .$$

*Proof.* There is no homology in degree $-1$, so the correction term is absent. Formally: $C^{(k)}$ is a projective resolution of $\mathbb{Z}/k$, so $H_0(G\otimes C^{(k)}) = \operatorname{Tor}_0(G,\mathbb{Z}/k) \cong G \otimes \mathbb{Z}/k$ by Theorem 6.1, and $\mathbb{Z}/k \cong H_0(C^{(k)})$. The identification with $G/kG$ is Theorem 6.6. $\square$

**Theorem 7.4 (Degree one: the correction term alone).** For every $\mathbb{Z}$-module $G$ and $k \neq 0$,
$$H_1(G \otimes C^{(k)}) \;\cong\; \operatorname{Tor}_1\big(G, H_0(C^{(k)})\big) \;\cong\; G[k].$$

*Proof.* Since $H_1(C^{(k)}) = 0$ the tensor term of the universal coefficient sequence vanishes and the whole group is the correction term. Formally, $C^{(k)}$ is a projective resolution of $\mathbb{Z}/k \cong H_0(C^{(k)})$, so by definition of the derived functor $H_1(G \otimes C^{(k)}) = \operatorname{Tor}_1(G, \mathbb{Z}/k)$, which is $G[k]$ by Theorem 6.6. $\square$

**Theorem 7.5 (Failure of exactness for non-flat coefficients).** Let $k \geq 2$. The short complex $0 \to \mathbb{Z}\xrightarrow{\mu_k}\mathbb{Z}$ of $\mathbb{Z}$-modules is exact (i.e. $H_1(C^{(k)}) = 0$), but its image under $-\otimes\mathbb{Z}/k$ is **not** exact: the class of $1 \otimes 1$ is a nonzero cycle that is not a boundary. Equivalently, $G \otimes C^{(k)}$ with $G = \mathbb{Z}/k$ fails to be exact in degree $1$, and
$$H_1\big(\mathbb{Z}/k \otimes C^{(k)}\big) \cong \operatorname{Tor}_1(\mathbb{Z}/k,\mathbb{Z}/k)\cong \mathbb{Z}/k \neq 0 .$$

*Proof.* Multiplication by $k$ on $\mathbb{Z}$ is injective, so $H_1(C^{(k)}) = 0$. After tensoring with $\mathbb{Z}/k$, the differential becomes $1 \otimes \mu_k$ on $\mathbb{Z}/k\otimes\mathbb{Z} \cong \mathbb{Z}/k$, i.e. multiplication by $k$ on $\mathbb{Z}/k$, which is the zero map. The element $1 \otimes 1$ is therefore a cycle; there is nothing in degree $2$ so it is a boundary only if it is zero, and it is not, since under $\mathbb{Z}/k \otimes \mathbb{Z}\cong \mathbb{Z}/k$ it corresponds to $1 \neq 0$ in $\mathbb{Z}/k$ (using $k \geq 2$). The identification of the resulting homology with $\operatorname{Tor}_1(\mathbb{Z}/k,\mathbb{Z}/k) \cong \mathbb{Z}/k$ is Theorem 7.4 together with Corollary 6.6a. $\square$

**Remark 7.6.** Theorem 7.5 is the precise sense in which the correction term in the universal coefficient theorem is not removable. It also gives the smallest topological illustration: for the real projective plane $\mathbb{RP}^2$, whose integral homology is $H_0 = \mathbb{Z}$, $H_1 = \mathbb{Z}/2$, $H_2 = 0$, the universal coefficient sequence with $G = \mathbb{Z}/2$ gives
$$H_2(\mathbb{RP}^2;\mathbb{Z}/2) \cong \big(\mathbb{Z}/2 \otimes H_2\big) \oplus' \operatorname{Tor}_1(\mathbb{Z}/2, H_1) = 0 \oplus' \mathbb{Z}/2 \cong \mathbb{Z}/2 ,$$
a class in top degree with no integral counterpart, produced entirely by the $\operatorname{Tor}$ term (here $\oplus'$ denotes the extension in the universal coefficient sequence, which splits non-canonically for complexes of free modules).

---

## 8. Algorithms

For finitely generated abelian groups all of the above is effectively computable. We record the three key procedures.

### 8.1 Smith normal form and homology of a finitely generated complex

Given a chain complex of finitely generated free abelian groups with integer boundary matrices $\partial_n$, the homology is computed by putting each $\partial_n$ into **Smith normal form** $U \partial_n V = \operatorname{diag}(d_1,\dots,d_r,0,\dots,0)$ with $d_1 \mid d_2 \mid \cdots \mid d_r$, $U,V \in \mathrm{GL}(\mathbb{Z})$. Then
$$H_n \;\cong\; \mathbb{Z}^{\,\dim\ker\partial_n - \operatorname{rank}\partial_{n+1}} \oplus \bigoplus_{i=1}^{r_{n+1}} \mathbb{Z}/d_i^{(n+1)},$$
where the $d_i^{(n+1)}$ are the nontrivial elementary divisors of $\partial_{n+1}$. The reduction is $O(m n \min(m,n))$ ring operations in the naive form, with coefficient growth controlled by modular or fraction-free variants.

### 8.2 $\operatorname{Ext}$ and $\operatorname{Tor}$ of finitely generated groups by elementary divisors

Every finitely generated abelian group decomposes as $X \cong \mathbb{Z}^r \oplus \bigoplus_i \mathbb{Z}/a_i$. Since $\operatorname{Ext}$ and $\operatorname{Tor}$ are additive in each variable, the computation reduces to cyclic summands, where the following table (all cases of Theorems 5.5, 6.6 and their degree-zero analogues) is complete:

| | $\operatorname{Hom}$ / $\otimes$ | degree 1 |
|---|---|---|
| $\operatorname{Ext}^\bullet(\mathbb{Z}, Y)$ | $Y$ | $0$ |
| $\operatorname{Ext}^\bullet(\mathbb{Z}/a, \mathbb{Z})$ | $0$ | $\mathbb{Z}/a$ |
| $\operatorname{Ext}^\bullet(\mathbb{Z}/a, \mathbb{Z}/b)$ | $\mathbb{Z}/\gcd(a,b)$ | $\mathbb{Z}/\gcd(a,b)$ |
| $\operatorname{Tor}_\bullet(\mathbb{Z}, M)$ | $M$ | $0$ |
| $\operatorname{Tor}_\bullet(\mathbb{Z}/a, \mathbb{Z})$ | $\mathbb{Z}/a$ | $0$ |
| $\operatorname{Tor}_\bullet(\mathbb{Z}/a, \mathbb{Z}/b)$ | $\mathbb{Z}/\gcd(a,b)$ | $\mathbb{Z}/\gcd(a,b)$ |

Indeed $\operatorname{Ext}^1(\mathbb{Z}/a,\mathbb{Z}/b) \cong (\mathbb{Z}/b)/a(\mathbb{Z}/b) \cong \mathbb{Z}/\gcd(a,b)$ by Theorem 5.5, and $\operatorname{Tor}_1(\mathbb{Z}/b,\mathbb{Z}/a) \cong (\mathbb{Z}/b)[a] \cong \mathbb{Z}/\gcd(a,b)$ by Theorem 6.6. All degrees $\geq 2$ vanish by Theorems 4.6 and 6.5. Complexity: linear in the number of summand pairs, plus one gcd each ($O(\log \min(a,b))$).

### 8.3 Universal coefficients for a finitely generated complex

Given integral homology $H_n \cong \mathbb{Z}^{r_n}\oplus\bigoplus_i \mathbb{Z}/a^{(n)}_i$ and a coefficient group $G \cong \mathbb{Z}^{s}\oplus\bigoplus_j \mathbb{Z}/b_j$, the universal coefficient sequence gives (non-canonically split, for complexes of free modules)
$$H_n(C;G) \;\cong\; \big(G \otimes H_n\big) \oplus \operatorname{Tor}_1\big(G, H_{n-1}\big),$$
which is computed summandwise from the table in §8.2. Flatness of $G$ (i.e. $G$ torsion-free, i.e. all $b_j$ absent) removes the second term, by Theorem 7.1.

---

## 9. Applications and discussion

**Topology.** The universal coefficient theorem is the standard tool for translating between integral homology and homology with arbitrary coefficients. Theorem 7.1 explains the well-known simplification in the rational case: rational homology is the "torsion-free shadow" of integral homology, and Betti numbers are all one can see. Theorem 7.5 explains why mod-$p$ homology sees strictly more: the $\operatorname{Tor}$-term promotes $p$-torsion in $H_{n-1}$ to a genuine class in $H_n(-;\mathbb{Z}/p)$. The classical example is $\mathbb{RP}^2$ (Remark 7.6).

**Group theory and extension problems.** By Remark 5.9, $\operatorname{Ext}^1(C,A)$ classifies abelian extensions. Corollary 5.7 says $\mathbb{Q}$ absorbs cyclic quotients trivially; Corollary 5.8 gives exactly $k$ inequivalent extensions of $\mathbb{Z}/k$ by $\mathbb{Z}$, realised as $0 \to \mathbb{Z}\xrightarrow{k}\mathbb{Z}\to\mathbb{Z}/k\to 0$ and its multiples. More generally Theorem 5.5 says that the extension classes of $\mathbb{Z}/k$ by $Y$ are parametrised by $Y/kY$, an entirely explicit finite computation whenever $Y$ is finitely generated.

**Commutative algebra.** Theorem 6.7 is the archetype of a *homological characterisation of a ring-theoretic property*: an infinite condition (exactness of $-\otimes G$ against all injections) collapses to a finite family of $\operatorname{Tor}$ computations against cyclic modules. The general form of this phenomenon is the standard flatness criterion "$\operatorname{Tor}_1^R(G, R/I) = 0$ for all finitely generated ideals $I$", of which our (1)$\Leftrightarrow$(4) is the case $R = \mathbb{Z}$, where every ideal is $k\mathbb{Z}$.

**The hereditary phenomenon.** Theorems 4.1, 4.2, 4.6, 6.5 all say the same thing from different angles: over $\mathbb{Z}$ the derived functors live in degrees $0$ and $1$ only. This is the defining property of a **hereditary ring** (global dimension $\leq 1$), which for a commutative domain is equivalent to being a Dedekind domain. Everything in this paper generalises verbatim to Dedekind domains, with $\mathbb{Z}/k$ replaced by $R/\mathfrak{a}$ and "$k$-divisible" by "$\mathfrak{a}$-divisible".

**What is genuinely explicit here.** Two aspects of the development deserve emphasis. First, the isomorphism $\operatorname{Ext}^1(\mathbb{Z}/k,Y)\cong Y/kY$ is not obtained by an abstract dimension count but from a *named* surjection $y \mapsto \varepsilon\circ u_y$ whose kernel is computed exactly (Theorems 5.3, 5.4). One can therefore point at a specific extension realising any given class. Second, the two-term complex $C^{(k)}$ isolates the two extreme cases of the universal coefficient sequence in a single object: degree $0$ is pure tensor, degree $1$ is pure $\operatorname{Tor}$. This gives the shortest possible proof that the correction term is unavoidable.

**Limitations.** Theorem 4.6 covers finitely generated $X$; the fully general statement "$\operatorname{Ext}^{n}(X,Y)=0$ for all $n\ge 2$ and all abelian groups $X,Y$" requires the freeness of arbitrary (possibly uncountable) subgroups of free abelian groups (Remark 4.7). Theorems 7.3 and 7.4 establish the two extreme cases of the universal coefficient sequence for the specific complex $C^{(k)}$; the full short exact sequence, with its non-canonical splitting, for an arbitrary complex of free modules, is a natural next target.

---

## 10. Future directions

1. **Naturality of the degree-one computation.** Establish that $\operatorname{Ext}^1(\mathbb{Z}/k, Y) \cong Y/kY$ is natural in $Y$: for every homomorphism $f : Y \to Y'$ the square formed by the two isomorphisms, the induced map $\operatorname{Ext}^1(\mathbb{Z}/k,f)$, and the map $Y/kY \to Y'/kY'$ induced by $f$, commutes. The isomorphism itself is Theorem 5.5, built from the explicit surjection $y \mapsto \varepsilon\circ u_y$ with kernel $kY$; what remains is functoriality of this description.

2. **Full hereditarity.** Prove $\operatorname{Ext}^{n+2}(X,Y) = 0$ for *all* abelian groups $X, Y$, removing the finite generation hypothesis of Theorem 4.6. The route is the Nielsen–Schreier-type theorem for abelian groups: every subgroup of a free abelian group is free, in arbitrary rank.

3. **The general universal coefficient sequence.** Construct the full short exact sequence $0 \to G\otimes H_n(C) \to H_n(G\otimes C)\to\operatorname{Tor}_1(G,H_{n-1}(C))\to 0$ for an arbitrary complex of free modules, and prove that it splits (non-canonically) and is natural in $C$ and $G$.

4. **Künneth.** Establish the Künneth formula $0 \to \bigoplus_{p+q=n}H_p(C)\otimes H_q(D)\to H_n(C\otimes D)\to\bigoplus_{p+q=n-1}\operatorname{Tor}_1(H_p(C),H_q(D))\to 0$, of which the universal coefficient theorem is the special case where $D$ is concentrated in degree zero.

5. **Cohomological universal coefficients.** The dual sequence $0 \to \operatorname{Ext}^1(H_{n-1}(C),G)\to H^n(C;G)\to\operatorname{Hom}(H_n(C),G)\to0$, which turns Section 5 into a topological tool exactly as Section 6 feeds Section 7.

6. **Dedekind and hereditary generalisations.** Reprove Sections 4–7 over an arbitrary Dedekind domain, with $\mathbb{Z}/k$ replaced by $R/\mathfrak{a}$, thereby covering rings of integers in number fields and coordinate rings of smooth affine curves.

7. **Beyond dimension one.** For a ring of global dimension $d > 1$ (e.g. a polynomial ring $\mathbb{k}[x_1,\dots,x_d]$, where the Koszul complex plays the role of $C^{(k)}$), compute the full tower $\operatorname{Ext}^0,\dots,\operatorname{Ext}^d$ against the residue field and observe the Betti numbers $\binom{d}{n}$ predicted by the Koszul resolution.

---

## References

The material developed here is classical; standard treatments of derived functors, $\operatorname{Ext}$, $\operatorname{Tor}$, and the universal coefficient theorem may be found in the standard textbooks on homological algebra and algebraic topology.
