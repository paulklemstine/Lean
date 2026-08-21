# Codiscrete Bicategories of Unital Magmas and the Combinatorics of the Associativity Defect

**Author:** Aristotle
**Date:** 2026-08-21

## Abstract

We attach to every pointed magma $M$ — a set with an entirely arbitrary binary operation $\ast$ and an arbitrary distinguished element $1$, subject to no axioms — a one-object bicategory $\mathcal{B}(M)$ whose hom-category is the *codiscrete* category on $M$, with horizontal composition given by $\ast$ and identity $1$-cell given by $1$. Because the hom-category is thin and total, the associator $(a\ast b)\ast c \cong a\ast (b\ast c)$ and the unitors $1\ast a \cong a$, $a \ast 1 \cong a$ exist and are invertible unconditionally, and Mac Lane's pentagon and triangle identities hold automatically. Thus arbitrary unit and associativity defects are converted into coherent invertible $2$-cells with no hypotheses whatsoever.

We then delimit exactly what this construction preserves and what it forgets. The bicategory $\mathcal{B}(M)$ is strict if and only if $M$ is a monoid; every ordered pair of $1$-cells forms an adjoint equivalence, so invertibility is free up to $2$-cells; but a $1$-cell is *strictly* invertible if and only if the corresponding element of $M$ has a two-sided inverse, so the $1$-cell layer retains the algebra. Every set map $M \to N$, with no compatibility hypothesis, induces a pseudofunctor $\mathcal{B}(M)\to \mathcal{B}(N)$, functorially; the induced pseudofunctor is strictly multiplicative precisely for magma homomorphisms.

The second half quantifies the weakness. For a finite magma we define the *associativity defect* $D(M) = \#\{(a,b,c) : (a\ast b)\ast c \neq a\ast(b\ast c)\}$ and prove: $D(M)$ equals the number of non-identity associator instances of $\mathcal{B}(M)$, so that for a unital magma $\mathcal{B}(M)$ is a $2$-category iff $D(M)=0$; the associative-triple count is multiplicative under products; $D$ is invariant under isomorphism, under passage to the opposite magma and under free unitalisation; $D$ is even for finite commutative magmas; and the sharp bounds $D(M)\le (n-1)^3$ for unital magmas of order $n$, and $D(M)\le (n-1)^3-(n-1)^2$ in the commutative unital case, both attained — by the *shift magma* of a fixed-point-free self-map and by the *negation magma* of a $2$-torsion-free abelian group respectively.

**Keywords:** magma, bicategory, codiscrete category, coherence, associator, associativity defect, extremal combinatorics, parity involution.

---

## 1. Introduction

Associativity is an axiom, not a fact. It is imposed on semigroups, monoids and groups because it makes the theory work, but a great many naturally occurring binary operations violate it: subtraction, exponentiation, the vector cross product, the arithmetic mean, the octonion product, floating-point addition, and — most relevant here — an arbitrary finite multiplication table produced by search or by a physical process.

Two complementary responses are available.

The *categorical response* is to weaken equality. Instead of demanding $(a\ast b)\ast c = a\ast(b\ast c)$, one supplies a specified isomorphism $\alpha_{a,b,c}$ between the two sides and asks it to be coherent, meaning that all diagrams built from these isomorphisms commute. The archetype is the theory of monoidal categories and bicategories, where Mac Lane's coherence theorem reduces the infinitely many required commutativities to the pentagon and triangle identities.

The *combinatorial response* is to measure. Define the number of triples at which the law fails and study it as a statistic of the multiplication table: its extremal values, its behaviour under natural operations, its parity.

This paper carries out both and connects them by an exact identity. Section 2 fixes notation. Section 3 constructs the codiscrete bicategory of an arbitrary pointed magma and establishes automatic coherence. Section 4 determines precisely what the construction preserves and forgets: strictness detects the monoid axioms; every pair of $1$-cells is an adjoint equivalence; strict invertibility detects genuine inverses; the construction is a pseudofunctor of *all* set maps; and the collapse onto the terminal bicategory is an isomorphism but not an equality. Section 5 develops the combinatorics of the associativity defect, with sharp bounds and extremal constructions. Section 6 exhibits the bridge between the two halves. Section 7 records exhaustive enumerations for small orders, including a refuted conjecture. Sections 8–10 discuss algorithms, applications and open problems.

The guiding slogan, which the two halves make precise from opposite directions, is:

> **Coherence is free; information is not.**

---

## 2. Preliminaries and notation

**Definition 2.1 (Magma, pointed magma).** A *magma* is a set $M$ equipped with a binary operation $\ast : M\times M\to M$; no axioms are imposed. A *pointed magma* is a magma together with a distinguished element $1\in M$, again with no axioms. A pointed magma is *unital* if $1\ast a = a = a\ast 1$ for all $a$, and is a *monoid* if in addition $\ast$ is associative.

**Definition 2.2 (Codiscrete category).** For a set $A$, the *codiscrete* category $\mathrm{Cod}(A)$ has object set $A$ and exactly one morphism $x \to y$ for every ordered pair $(x,y)$. Composition and identities are forced. $\mathrm{Cod}(A)$ is a *thin groupoid*: every morphism is invertible, and any two parallel morphisms are equal.

**Definition 2.3 (Bicategory).** A bicategory $\mathcal{C}$ consists of objects; for each ordered pair of objects a category $\mathcal{C}(X,Y)$ of $1$-cells and $2$-cells; horizontal composition functors $\mathcal{C}(X,Y)\times \mathcal{C}(Y,Z)\to\mathcal{C}(X,Z)$; identity $1$-cells; and invertible natural transformations — the associator $\alpha_{f,g,h}:(f\circ g)\circ h \Rightarrow f\circ(g\circ h)$ and the unitors $\lambda_f : \mathrm{id}\circ f \Rightarrow f$, $\rho_f : f\circ\mathrm{id}\Rightarrow f$ — subject to the pentagon identity for four composable $1$-cells and the triangle identity relating $\alpha$ to $\lambda,\rho$. A bicategory is *strict* (a $2$-category) when $\alpha$, $\lambda$ and $\rho$ are identities, equivalently when the underlying composition of $1$-cells is associative and unital on the nose.

We write $\mathbb{1}_X$ for the identity $1$-cell at $X$ and use $\circ$ (or juxtaposition) for horizontal composition.

**Definition 2.4 (Adjoint equivalence).** A $1$-cell $f : X\to Y$ in a bicategory is part of an *adjoint equivalence* if there are $g : Y\to X$ and invertible $2$-cells $\eta : \mathbb{1}_X \Rightarrow g\circ f$ (unit) and $\varepsilon : f\circ g \Rightarrow \mathbb{1}_Y$ (counit) satisfying the two triangle identities.

**Definition 2.5 (Pseudofunctor).** A pseudofunctor $F : \mathcal{C}\to\mathcal{D}$ assigns objects to objects, $1$-cells to $1$-cells, $2$-cells to $2$-cells functorially in each hom-category, together with invertible comparison $2$-cells $F(\mathbb{1}_X)\cong \mathbb{1}_{FX}$ and $F(f)\circ F(g)\cong F(f\circ g)$, compatible with the associators and unitors.

---

## 3. The codiscrete bicategory of a pointed magma

Throughout this section $(M,\ast,1)$ is an arbitrary pointed magma.

**Definition 3.1 (The codiscrete magma bicategory).** Let $\mathcal{B}(M)$ be the following data:

- a single object $\star$;
- hom-category $\mathcal{B}(M)(\star,\star) = \mathrm{Cod}(M)$: the $1$-cells are the elements of $M$ — we write $\lceil a\rceil$ for the $1$-cell named by $a\in M$ — and there is exactly one $2$-cell $\lceil a\rceil \Rightarrow \lceil b\rceil$ for every ordered pair;
- horizontal composition $\lceil a\rceil \circ \lceil b\rceil = \lceil a\ast b\rceil$, on $2$-cells the unique choice;
- identity $1$-cell $\mathbb{1}_\star = \lceil 1 \rceil$;
- associator $\alpha_{\lceil a\rceil,\lceil b\rceil,\lceil c\rceil}$ and unitors $\lambda_{\lceil a\rceil}$, $\rho_{\lceil a\rceil}$: the unique $2$-cells
$$\lceil (a\ast b)\ast c\rceil \Rightarrow \lceil a\ast(b\ast c)\rceil, \qquad \lceil 1\ast a\rceil \Rightarrow \lceil a\rceil, \qquad \lceil a\ast 1\rceil \Rightarrow \lceil a\rceil .$$

**Lemma 3.2 (Thinness).** Any two parallel $2$-cells of $\mathcal{B}(M)$ are equal, and every $2$-cell is invertible. Consequently $\mathcal{B}(M)(\star,\star)$ is a groupoid.

*Proof sketch.* Both statements are immediate from codiscreteness: the hom-set between any two $1$-cells is a singleton, so two parallel $2$-cells coincide; and the unique $2$-cell in the reverse direction is a two-sided inverse, since both composites are parallel to the relevant identity and therefore equal to it. $\square$

**Theorem 3.3 (Automatic coherence).** For every pointed magma $M$, the data of Definition 3.1 form a bicategory. In particular the associator and unitors are natural and invertible, and the pentagon and triangle identities hold. Every diagram of $2$-cells in $\mathcal{B}(M)$ commutes.

*Proof sketch.* Each axiom of a bicategory — functoriality of whiskering, the interchange law, naturality of $\alpha,\lambda,\rho$, the pentagon, the triangle — is an equation between two $2$-cells with the same source and target $1$-cell. By Lemma 3.2 there is at most one such $2$-cell, so all these equations hold vacuously. Invertibility is Lemma 3.2. The only genuine content is that horizontal composition of $1$-cells is well defined, which is exactly the operation $\ast$, and that $\mathbb{1}_\star$ is a $1$-cell, which is exactly the point $1$. $\square$

This is the precise sense in which *coherence is free*: the pentagon and triangle, which in general are substantive constraints, are automatic in a thin hom-category, and Mac Lane's conclusion (all diagrams commute) holds for the trivial reason.

**Definition 3.4 (Defect-repairing $2$-cells).** For $a,b,c\in M$ write
$$\mathrm{A}_{a,b,c} : \lceil (a\ast b)\ast c\rceil \xrightarrow{\ \sim\ } \lceil a\ast(b\ast c)\rceil, \qquad
\Lambda_a : \lceil 1\ast a\rceil \xrightarrow{\ \sim\ } \lceil a\rceil, \qquad
\mathrm{P}_a : \lceil a\ast 1\rceil \xrightarrow{\ \sim\ } \lceil a\rceil$$
for the unique isomorphisms. These are literally the associator and the unitors of $\mathcal{B}(M)$.

**Proposition 3.5 (Defects are visible at the $1$-cell level).** For all $a,b,c\in M$:

1. $(\lceil a\rceil\circ\lceil b\rceil)\circ \lceil c\rceil = \lceil a\rceil\circ(\lceil b\rceil\circ\lceil c\rceil)$ if and only if $(a\ast b)\ast c = a\ast (b\ast c)$;
2. $\mathbb{1}_\star \circ \lceil a\rceil = \lceil a\rceil$ if and only if $1\ast a = a$;
3. $\lceil a\rceil\circ \mathbb{1}_\star = \lceil a\rceil$ if and only if $a\ast 1 = a$.

*Proof sketch.* The naming map $a \mapsto \lceil a\rceil$ is a bijection from $M$ to the set of $1$-cells, and horizontal composition is $\ast$ transported along it; so equality of $1$-cells is equality in $M$. $\square$

Thus the associator at $(a,b,c)$ is an *endomorphism* $2$-cell precisely at the associative triples, and a $2$-cell between genuinely distinct $1$-cells precisely at the defective ones. This observation is the germ of the counting theorem of Section 6.

---

## 4. What the construction preserves and what it forgets

### 4.1 Strictness detects the monoid axioms

**Theorem 4.1 (Strictness criterion).** $\mathcal{B}(M)$ is a strict bicategory if and only if $M$ is a monoid, i.e.
$$(a\ast b)\ast c = a\ast(b\ast c) \ \ \forall a,b,c, \qquad 1\ast a = a \ \ \forall a, \qquad a\ast 1 = a \ \ \forall a.$$

*Proof sketch.* ($\Rightarrow$) Strictness asserts in particular the equalities of $1$-cells in Proposition 3.5, which transport back to the three monoid identities. ($\Leftarrow$) If $M$ is a monoid, the three families of equalities of $1$-cells hold, and the required identifications of the associator and unitors with identity $2$-cells are equalities of parallel $2$-cells, hence automatic by Lemma 3.2. $\square$

**Corollary 4.2.** If $M$ has any associativity or unit defect, $\mathcal{B}(M)$ is not strict. Hence the weakness of $\mathcal{B}(M)$ is not an artefact of the encoding: it is present exactly when the algebra is defective. When $M$ is a monoid, $\mathcal{B}(M)$ is the classical one-object $2$-category of $M$.

### 4.2 Equivalence is free; strict invertibility is not

**Theorem 4.3 (Every ordered pair of $1$-cells is an adjoint equivalence).** For *any* $a, b\in M$ — with no algebraic relation between them — the data
$$f = \lceil a\rceil, \quad g = \lceil b\rceil, \quad \eta : \mathbb{1}_\star \xrightarrow{\sim} g\circ f, \quad \varepsilon : f\circ g \xrightarrow{\sim} \mathbb{1}_\star$$
with $\eta,\varepsilon$ the unique $2$-cells, form an adjoint equivalence of $\star$ with itself. In particular every $1$-cell of $\mathcal{B}(M)$ is an equivalence.

*Proof sketch.* The unit and counit exist and are invertible by Lemma 3.2, and the two triangle identities are equalities of parallel $2$-cells, hence automatic. $\square$

**Theorem 4.4 (Strict invertibility remembers the algebra).** For $a\in M$, there exists a $1$-cell $g$ with $\lceil a\rceil \circ g = \mathbb{1}_\star$ and $g\circ \lceil a\rceil = \mathbb{1}_\star$ *as equalities of $1$-cells* if and only if there is $b\in M$ with $a\ast b = 1 = b\ast a$.

*Proof sketch.* Immediate from the bijection $a\mapsto \lceil a\rceil$ and Proposition 3.5: writing $g=\lceil b\rceil$, the two displayed equalities of $1$-cells are exactly $a\ast b = 1$ and $b\ast a = 1$. $\square$

Theorems 4.3 and 4.4 are the two sides of the slogan. Up to $2$-cells, $\mathcal{B}(M)$ knows nothing: all $1$-cells are equivalences and all $2$-cells are unique. On the nose, $\mathcal{B}(M)$ knows everything: the $1$-cell layer is the multiplication table of $M$ verbatim.

### 4.3 Functoriality on all set maps

**Theorem 4.5 (Pseudofunctoriality of arbitrary maps).** Let $M,N$ be pointed magmas and $f : M\to N$ *any* function, not assumed to preserve $\ast$ or $1$. Then
$$F_f : \mathcal{B}(M)\longrightarrow \mathcal{B}(N), \qquad \star \mapsto \star, \quad \lceil a\rceil \mapsto \lceil f(a)\rceil,$$
with the unique comparison $2$-cells $\lceil f(a)\rceil\circ\lceil f(b)\rceil \cong \lceil f(a\ast b)\rceil$ and $\mathbb{1}_\star \cong \lceil f(1)\rceil$, is a pseudofunctor. Moreover $F_{\mathrm{id}} = \mathrm{id}$ and $F_{g\circ f} = F_g\circ F_f$ on $1$-cells.

*Proof sketch.* The comparison $2$-cells exist and are invertible by codiscreteness; every compatibility axiom of a pseudofunctor is an equation of parallel $2$-cells, hence automatic. Functoriality on $1$-cells is functoriality of $a\mapsto f(a)$. $\square$

**Theorem 4.6 (Homomorphisms are exactly the strictly multiplicative ones).** For a function $f:M\to N$, the induced pseudofunctor satisfies
$$F_f(\lceil a\rceil \circ \lceil b\rceil) = F_f(\lceil a\rceil)\circ F_f(\lceil b\rceil) \quad \text{for all } a,b \in M$$
*as an equality of $1$-cells* if and only if $f(a\ast b) = f(a)\ast f(b)$ for all $a,b$, i.e. iff $f$ is a magma homomorphism.

*Proof sketch.* Both sides are the $1$-cells named by $f(a\ast b)$ and $f(a)\ast f(b)$; apply injectivity of the naming map. $\square$

So the codiscrete construction is defined on the category of *pointed sets and all maps*, while the classical notion of homomorphism is recovered exactly as the condition for strict compatibility with horizontal composition.

### 4.4 The collapse: exactly how much is forgotten

Let $\mathbf{1}$ denote the one-point pointed magma. Let $T : \mathcal{B}(M)\to\mathcal{B}(\mathbf{1})$ be induced by the unique map $M \to \mathbf{1}$, and $U : \mathcal{B}(\mathbf{1})\to \mathcal{B}(M)$ by the map sending the point to $1\in M$; both are pseudofunctors by Theorem 4.5.

**Theorem 4.7 (Collapse up to isomorphism).** For every $1$-cell $f$ of $\mathcal{B}(M)$ there is an invertible $2$-cell $U(T(f)) \cong f$. Hence at the level of $2$-isomorphism classes, $\mathcal{B}(M)$ retains no information about $M$ at all.

**Theorem 4.8 (…but not up to equality).** For $a\in M$, $U(T(\lceil a\rceil)) = \lceil a\rceil$ as $1$-cells if and only if $a = 1$.

*Proof sketch.* $U(T(\lceil a\rceil)) = \lceil 1\rceil$ always; equality with $\lceil a\rceil$ is $a = 1$. The isomorphism is the unique $2$-cell. $\square$

More generally, for arbitrary maps $g:M\to N$ and $h:N\to M$, the round trip $F_h\circ F_g$ sends each $1$-cell to one canonically isomorphic to it, while $F_h(F_g(\lceil a\rceil)) = \lceil a\rceil$ holds exactly when $h(g(a))=a$.

---

## 5. The associativity defect of a finite magma

We now quantify the weakness that Section 3 renders harmless. Throughout, $M$ is a finite magma with $|M| = n$.

**Definition 5.1 (Defect and associative count).**
$$\mathrm{DefSet}(M) = \{(a,b,c)\in M^3 : (a\ast b)\ast c \neq a\ast(b\ast c)\}, \qquad D(M) = |\mathrm{DefSet}(M)|,$$
$$A(M) = |\{(a,b,c) : (a\ast b)\ast c = a\ast(b\ast c)\}| = n^3 - D(M).$$
The *associativity density* is $d(M) = D(M)/n^3 \in [0,1]$.

**Proposition 5.2.** $D(M) = 0$ if and only if $M$ is a semigroup; and $D(M)\le n^3$ trivially. Moreover $A(M)+D(M) = n^3$.

### 5.1 Products: multiplicativity

**Theorem 5.3 (Multiplicativity of the associative count).** For finite magmas $M,N$,
$$A(M\times N) = A(M)\cdot A(N),$$
where $M\times N$ carries the componentwise product. Equivalently,
$$D(M\times N) = (|M|\,|N|)^3 - A(M)A(N), \qquad 1 - d(M\times N) = (1-d(M))(1-d(N)).$$

*Proof sketch.* A triple in $(M\times N)^3$ is the same thing as a pair consisting of a triple in $M^3$ and a triple in $N^3$; and since the product operation is componentwise, the triple is associative iff both components are. The bijection
$$((a,a'),(b,b'),(c,c')) \longleftrightarrow \big((a,b,c),(a',b',c')\big)$$
restricts to a bijection between the associative triples of $M\times N$ and the product of the associative sets of $M$ and $N$. $\square$

Thus the *associativity density* is multiplicative in the complementary sense: products of nearly-associative magmas degrade geometrically.

### 5.2 Invariance

**Theorem 5.4 (Isomorphism and reversal invariance).** If $M\cong N$ as magmas then $D(M) = D(N)$. Moreover $D(M^{\mathrm{op}}) = D(M)$, where $M^{\mathrm{op}}$ carries $a\ast^{\mathrm{op}}b = b\ast a$.

*Proof sketch.* An isomorphism induces a bijection of triples preserving both bracketings. For the opposite magma, the reversal $(a,b,c)\mapsto (c,b,a)$ is an involution of $M^3$ that interchanges the two bracketings computed in $M$ and in $M^{\mathrm{op}}$: indeed $(a\ast^{\mathrm{op}} b)\ast^{\mathrm{op}} c = c\ast(b\ast a)$ and $a \ast^{\mathrm{op}}(b\ast^{\mathrm{op}}c) = (c\ast b)\ast a$. So it maps the defect set of $M^{\mathrm{op}}$ bijectively onto that of $M$. $\square$

### 5.3 Parity in the commutative case

**Lemma 5.5 (Palindromes are associative).** If $\ast$ is commutative then $(a\ast b)\ast a = a\ast(b\ast a)$ for all $a,b$; i.e. no palindromic triple $(a,b,a)$ is defective.

*Proof sketch.* Commutativity gives $(a\ast b)\ast a = a \ast (a\ast b)$ and $b\ast a = a\ast b$, so both sides equal $a\ast(a\ast b)$. $\square$

**Theorem 5.6 (Parity).** The associativity defect of a finite commutative magma is even. Consequently $D(M)\neq 1$ for commutative $M$.

*Proof sketch.* The reversal $\tau(a,b,c) = (c,b,a)$ maps the defect set to itself: by Theorem 5.4's computation and commutativity, $(c\ast b)\ast a = a\ast(b\ast c)$ and $c\ast(b\ast a) = (a\ast b)\ast c$, so $\tau$ preserves defectiveness. It is an involution, and by Lemma 5.5 it has no fixed point *on the defect set* (its fixed points are the palindromic triples, which are never defective). A fixed-point-free involution partitions the set into $2$-element orbits, so the cardinality is even. $\square$

### 5.4 The unital bound and its sharpness

**Lemma 5.7 (Defect triples avoid the unit).** If $1\ast a = a = a\ast 1$ for all $a$, then no defect triple contains $1$ in any coordinate.

*Proof sketch.* If $a = 1$ both bracketings equal $b\ast c$; if $b=1$ both equal $a\ast c$; if $c=1$ both equal $a\ast b$. $\square$

**Theorem 5.8 (Unital bound).** A unital magma with $n$ elements satisfies $D(M)\le (n-1)^3$.

*Proof sketch.* By Lemma 5.7 the defect set is contained in $S^3$ where $S = M\setminus\{1\}$ has $n-1$ elements. $\square$

**Definition 5.9 (Shift magma).** Let $S$ be a set and $\sigma : S\to S$ a self-map. The *shift magma* $\mathrm{Sh}(\sigma)$ has underlying set $S\sqcup\{1\}$ with
$$1\ast x = x\ast 1 = x \quad (x \in \mathrm{Sh}(\sigma)), \qquad a\ast b = \sigma(b) \quad (a,b\in S).$$
It is unital by construction.

**Theorem 5.10 (The shift magma is maximally defective).** If $\sigma$ has no fixed point, then *every* triple of non-units of $\mathrm{Sh}(\sigma)$ is defective, hence
$$D(\mathrm{Sh}(\sigma)) = |S|^3 = (n-1)^3, \qquad n = |S|+1 .$$

*Proof sketch.* For $a,b,c\in S$ we compute $(a\ast b)\ast c = \sigma(b)\ast c = \sigma(c)$, while $a\ast(b\ast c) = a\ast \sigma(c) = \sigma(\sigma(c))$. These are equal iff $\sigma$ fixes $\sigma(c)$, which is excluded. Conversely, Lemma 5.7 says no other triple can be defective. $\square$

**Corollary 5.11 (Sharpness for every order).** For every $n\ge 3$ there is a unital magma of order $n$ with $D = (n-1)^3$: take $S$ of size $m=n-1\ge 2$ and $\sigma$ the cyclic shift $i\mapsto i+1 \bmod m$, which is fixed-point-free.

### 5.5 The commutative unital bound and its sharpness

**Lemma 5.12 (Counting non-palindromic triples).** For a finite set $S$ with $|S|=m$, the number of triples $(a,b,c)\in S^3$ with $a\neq c$ is $m^3-m^2$.

**Theorem 5.13 (Commutative unital bound).** A commutative unital magma with $n$ elements satisfies
$$D(M) \le (n-1)^3 - (n-1)^2 .$$

*Proof sketch.* By Lemma 5.7 the defect set lies in $S^3$, $S = M\setminus\{1\}$; by Lemma 5.5 it avoids the palindromic triples $(a,b,a)$; apply Lemma 5.12. $\square$

**Definition 5.14 (Negation magma).** For an abelian group $(G,+)$, the *negation magma* $\mathrm{Neg}(G)$ has underlying set $G\sqcup\{1\}$ with
$$1\ast x = x\ast 1 = x, \qquad a\ast b = -(a+b) \quad (a,b\in G).$$
It is commutative and unital.

**Theorem 5.15 (The negation magma attains the commutative bound).** Suppose $G$ is finite with no $2$-torsion (equivalently, $x+x = y+y \Rightarrow x=y$). Then a triple $(a,b,c)$ of non-units of $\mathrm{Neg}(G)$ is defective if and only if $a \neq c$, and hence
$$D(\mathrm{Neg}(G)) = |G|^3-|G|^2 = (n-1)^3-(n-1)^2, \qquad n = |G|+1 .$$

*Proof sketch.* $(a\ast b)\ast c = -(-(a+b)+c) = a+b-c$ and $a\ast(b\ast c) = -(a-(b+c)) = -a+b+c$. These agree iff $a + a = c + c$, iff $a = c$ by $2$-torsion-freeness. Now count with Lemma 5.12. $\square$

**Corollary 5.16.** For every odd $m\ge 3$ there is a commutative unital magma of order $n = m+1$ attaining $D = (n-1)^3 - (n-1)^2$: take $G = \mathbb{Z}/m$, which has no $2$-torsion because $2$ is invertible mod $m$.

Note the consistency with Theorem 5.6: $m^3-m^2 = m^2(m-1)$ is even for every $m$.

### 5.6 Unitalisation is defect-neutral

**Definition 5.17.** For an arbitrary magma $\alpha$, let $\alpha^1 = \alpha \sqcup \{1\}$ with $1$ declared a two-sided unit and the old product retained on $\alpha$.

**Theorem 5.18 (Free unitalisation preserves the defect).** $D(\alpha^1) = D(\alpha)$. Indeed the defect triples of $\alpha^1$ are exactly the images of the defect triples of $\alpha$.

*Proof sketch.* By Lemma 5.7 no defect triple of $\alpha^1$ involves $1$, and on triples of old elements both bracketings are computed by the old product — with the one caveat that products of old elements remain old elements, which holds by construction. $\square$

**Corollary 5.19.** Every associativity-defect value realised by a finite magma of order $m$ is realised by a unital magma of order $m+1$. In particular the restriction to unital magmas in Theorems 5.8 and 5.13 costs no generality in the study of defect *profiles*.

---

## 6. The bridge: defect counts non-identity associators

The two halves of the paper meet here. Let $M$ be a finite pointed magma.

**Theorem 6.1 (Defect = number of weak associator instances).**
$$\#\{(a,b,c)\in M^3 : (\lceil a\rceil\circ\lceil b\rceil)\circ\lceil c\rceil \neq \lceil a\rceil \circ (\lceil b\rceil\circ\lceil c\rceil)\} \;=\; D(M).$$
That is, the associator of $\mathcal{B}(M)$ is a $2$-cell between *distinct* $1$-cells at exactly $D(M)$ triples, and is an endomorphism $2$-cell at the remaining $A(M)$ triples.

*Proof sketch.* Immediate from Proposition 3.5(1): the naming map is a bijection intertwining composition with $\ast$, so the two filtered sets correspond. $\square$

**Theorem 6.2 (Strictness $\Leftrightarrow$ zero defect).** If $M$ is unital and finite, then $\mathcal{B}(M)$ is a $2$-category if and only if $D(M) = 0$.

*Proof sketch.* Combine Theorem 4.1 with Proposition 5.2: for a unital magma the unit clauses of the monoid axioms are given, so strictness reduces to associativity, which is $D(M)=0$. $\square$

**Corollary 6.3 (Maximal weakness).** For every $n\ge 3$ there is a unital magma $M$ of order $n$ such that $\mathcal{B}(M)$ is a perfectly coherent bicategory — all $2$-cells invertible, all parallel $2$-cells equal, pentagon and triangle satisfied — in which nevertheless *every one* of the $(n-1)^3$ non-unit associator instances is a genuinely non-identity $2$-cell. Take $M = \mathrm{Sh}(\sigma)$ for a fixed-point-free $\sigma$ on $n-1$ points.

Corollary 6.3 is the sharpest form of the slogan. Coherence and weakness are independent axes: a bicategory can be maximally weak and perfectly coherent at once.

---

## 7. Exhaustive enumeration at small orders

For small $n$ the space of unital multiplication tables on $\{1, s_1,\dots,s_{n-1}\}$ with $1$ a declared two-sided unit is parameterised by the $(n-1)^2$ entries of the restricted table, each with $n$ choices, giving $n^{(n-1)^2}$ labelled tables. Exhaustive enumeration is feasible for $n\le 4$ ($4^9 = 262\,144$ tables at $n=4$).

**Order $3$** ($3^4 = 81$ tables, bound $D\le 8$). The defect distribution is
$$D = 0:11,\quad 2:14,\quad 3:8,\quad 4:18,\quad 5:12,\quad 6:12,\quad 7:4,\quad 8:2 .$$
The maximum $8=(3-1)^3$ is attained by exactly $2$ tables — precisely the two shift magmas of the unique fixed-point-free involution of a $2$-set and its mirror. No table has $D=1$.

**Order $4$** ($4^9 = 262\,144$ tables, bound $D\le 27$). Exactly $156$ tables are associative, exactly $84$ attain the maximum $D=27$, and exactly $84$ have $D=1$; none of the latter is commutative, in agreement with the parity theorem (Theorem 5.6). Of the $84$ maximisers, only $8$ are shift magmas $a\ast b=\sigma(b)$ with $\sigma$ fixed-point-free, and $16$ if one includes the mirror family $a\ast b = \sigma(a)$; up to the $3! = 6$ relabellings of the non-units the $84$ maximisers fall into $18$ classes.

**A refuted conjecture.** The order-$3$ data suggests that a unital magma can never have exactly one defect triple. This is *false*: the $84$ order-$4$ examples with $D=1$ refute it. The correct general statement is the parity theorem, which forbids $D=1$ only under commutativity.

**A conjecture that survives.** The extremal family is strictly larger than the shift construction. Since maximality is a purely *local* condition — every one of the $(n-1)^3$ non-unit triples must fail — one expects the maximisers to be characterised by a finite forbidden-pattern condition on the restricted product $S\times S\to M$ rather than by a global identity.

---

## 8. Algorithms

The results above are supported by three elementary algorithms.

**Algorithm A: defect computation.** Given an $n\times n$ table $T$, compute
$$D = \#\{(a,b,c) : T[T[a][b]][c]\neq T[a][T[b][c]]\}$$
by direct triple iteration: $\Theta(n^3)$ time, $O(1)$ extra space. This also produces the defect set, hence the list of non-identity associator instances of the associated bicategory (Theorem 6.1).

**Algorithm B: exhaustive extremal search.** Enumerate the $n^{(n-1)^2}$ unital tables, evaluate Algorithm A on each, and tabulate the defect distribution: $\Theta\big(n^{(n-1)^2}\cdot n^3\big)$ time. Feasible through $n=4$; a symmetry reduction by the $(n-1)!$ relabellings of the non-units, and an early-abort test that stops as soon as the running defect exceeds a target, extend the range.

**Algorithm C: extremal constructors.** The shift magma of a fixed-point-free $\sigma$ and the negation magma of $\mathbb{Z}/m$ ($m$ odd) both build an $n\times n$ table in $\Theta(n^2)$ time, realising $D = (n-1)^3$ and $D = (n-1)^3-(n-1)^2$ respectively; verification is Algorithm A.

---

## 9. Discussion and applications

**Coherence as a cheap resource.** In practice the hardest part of exhibiting a bicategorical structure is verifying coherence. The codiscrete construction shows that if one is willing to make the hom-categories maximally uninformative, coherence costs nothing at all, whatever the algebra. It is the extreme point of a trade-off: hom-category information versus coherence burden. Discrete hom-categories (one $2$-cell only between equal $1$-cells) force the strict axioms; codiscrete hom-categories force nothing. Everything interesting lives strictly between.

**A functor of pointed sets.** Theorem 4.5 says the assignment $M \mapsto \mathcal{B}(M)$ is defined on pointed sets and *all* maps, and Theorem 4.6 identifies homomorphisms as exactly the maps whose induced pseudofunctor is strictly multiplicative. This gives a clean conceptual home for the notion of homomorphism: it is a strictness condition on an always-available pseudofunctor, not an extra structure.

**Measuring non-associativity.** The defect is a natural statistic for any concretely presented binary operation. Multiplicativity (Theorem 5.3) makes the *associativity density* behave like a probability: a triple drawn uniformly from a product is associative with the product of the component probabilities. Invariance under isomorphism and reversal (Theorem 5.4) make $D$ a genuine invariant of the multiplication table up to relabelling and mirror symmetry, and the parity theorem (Theorem 5.6) shows that symmetry hypotheses constrain not just the size but the *arithmetic* of the failure set.

**Where such magmas arise.** Floating-point addition, the arithmetic mean, subtraction and division, exponentiation, the cross product, the commutator, the fusion rules of an approximately-known physical system, and any randomly generated finite table are all magmas with nonzero defect. In each case the results here say: the operation admits a canonical coherent bicategorical model; the number of failures is a computable invariant; and if the operation is commutative that number is even and at most $(n-1)^3-(n-1)^2$ after unitalisation.

**Limits of the construction.** Theorem 4.7 is a genuine caveat: no information about $M$ survives passage to $2$-isomorphism classes. Any application of the construction must therefore work at the $1$-cell layer, where Theorems 4.4, 4.6 and 4.8 show that the algebra is fully retained. The honest summary of the mission is two-sided: coherence is free, information is not.

---

## 10. Future directions

1. **Classification of maximal-defect unital magmas.** Only $8$ of the $84$ order-$4$ maximisers come from the shift construction ($16$ counting mirrors), so the extremal family is strictly larger than the one proved sharp here. *Conjecture:* a unital magma of order $n\ge 3$ has $D = (n-1)^3$ if and only if the restricted product $S\times S\to M$ (with $S$ the non-units) satisfies a "no returning to a fixed point" condition, of which the two forms $a\ast b = \varphi(b)$ and $a\ast b = \varphi(a)$ for fixed-point-free $\varphi$ avoiding the unit are the principal cases; the number of such tables should be $2(n-1)^{n-1} - c_n$ for an explicitly computable correction $c_n$, matching the counts $2$ at $n=3$ and $84$ at $n=4$. The key structural point is that maximality is a *local* condition, so a forbidden-pattern characterisation should exist.

2. **Even-order sharpness of the commutative bound.** The commutative bound $(n-1)^3-(n-1)^2$ is attained by the negation magma over $\mathbb{Z}/m$ for *odd* $m = n-1$, where invertibility of $2$ is essential. For even $m$ the negation magma fails to be extremal, and a different construction — or a strictly smaller bound — is required. Determining the exact commutative maximum for even $n-1$ is open.

3. **Intermediate hom-structures.** Interpolate between the discrete and codiscrete extremes by prescribing which $1$-cells are allowed to be connected, and ask for which such "defect graphs" coherence is still automatic.

4. **Defect spectra.** Which values in $[0,(n-1)^3]$ are realised as defects of unital magmas of order $n$? Order $3$ realises $\{0,2,3,4,5,6,7,8\}$ but not $1$; order $4$ realises $1$. A characterisation of the spectrum, and of its commutative sub-spectrum (which must be even), is open.

5. **Higher defects.** Extend the count to the pentagon: for a magma, measure how badly the five bracketings of four elements fail to agree, and relate this "second-order defect" to $D$ and to the tricategorical analogue of the construction.

---

## 11. Summary of main results

- **Codiscrete repair.** Every pointed magma, with no axioms, yields a one-object bicategory with codiscrete hom-category; all coherence conditions hold automatically.
- **Automatic invertibility and uniqueness.** Every $2$-cell is invertible, and any two parallel $2$-cells are equal.
- **Strictness criterion.** The bicategory is strict exactly when the magma is a monoid.
- **Equivalence is free.** Any ordered pair of $1$-cells forms an adjoint equivalence.
- **Strict invertibility remembers.** A $1$-cell is strictly invertible iff the element has a two-sided inverse.
- **Universal functoriality.** Any set map induces a pseudofunctor, functorially; strict multiplicativity holds exactly for homomorphisms.
- **Collapse.** The construction retains nothing up to $2$-isomorphism, but everything on the nose.
- **Defect bridge.** $D(M)$ equals the number of non-identity associator instances; for unital $M$, strictness $\Leftrightarrow$ $D(M)=0$.
- **Multiplicativity.** $A(M\times N) = A(M)A(N)$.
- **Invariance.** $D$ is invariant under isomorphism, under reversal, and under free unitalisation.
- **Parity.** $D$ is even for finite commutative magmas; in particular $D\neq 1$.
- **Sharp bounds.** $D \le (n-1)^3$ for unital magmas, attained by shift magmas; $D\le (n-1)^3-(n-1)^2$ for commutative unital magmas, attained by negation magmas of $2$-torsion-free abelian groups.
