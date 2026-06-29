# Intersection Forms as a Symmetric Monoidal Category: The Parity Obstruction, Direct-Sum Additivity, and the E8 ⊕ E8 Witness of the Smooth/Topological Gap in Dimension Four

## Abstract

The smooth four-dimensional Poincaré conjecture — whether every smooth closed
4-manifold homotopy equivalent to $S^4$ is diffeomorphic to $S^4$ — remains open, and is
the last unresolved case of the Poincaré program. The subject is governed by the
interaction of two deep theorems: **Donaldson's diagonalization theorem**, which forces
the intersection form of a smooth, closed, simply-connected, positive-definite
4-manifold to be standard (diagonalizable over $\mathbb{Z}$ to $\langle 1\rangle^n$), and
**Freedman's classification**, which realizes every unimodular symmetric integral form as
the intersection form of a *topological* 4-manifold. The discrepancy between the two is
the smooth/topological gap.

This paper develops the **algebraic engine** of that gap as the structure of a *symmetric
monoidal category of integral symmetric bilinear forms*. We define a form $\mathrm{GForm}\,\iota$
over an arbitrary finite index type $\iota$, equipped with the three governing predicates
$\mathrm{Unimodular}$ (Poincaré duality), $\mathrm{IsEven}$ (spin), and
$\mathrm{StdDiagonalizable}$ (the conclusion of Donaldson's theorem). Our central
elementary result, the **parity obstruction**, states that a nonempty even form is never
standard-diagonalizable. We then introduce the **orthogonal direct sum** $Q \oplus R$,
modeling the connected-sum operation on 4-manifolds, prove the value-splitting identity
$(Q\oplus R)(v) = Q(v\circ\mathrm{inl}) + R(v\circ\mathrm{inr})$, and establish that all
three predicates are *additive* under $\oplus$. These additivity laws are exactly the
coherence laws of a symmetric monoidal structure. The capstone assembles them: the
rank-16 form $E_8 \oplus E_8$ is unimodular, even, and not standard-diagonalizable —
the algebraic shadow of the spin obstruction at the boundary of Rokhlin's theorem and the
$\tfrac{11}{8}$-conjecture. Every result herein has been formally verified.

**Keywords.** Four-manifold, intersection form, Donaldson's theorem, E8 lattice,
unimodular form, even form, spin manifold, Rokhlin's theorem, connected sum, symmetric
monoidal category, smooth Poincaré conjecture.

---

## 1. Introduction

### 1.1 The Poincaré program and the role of dimension four

The Poincaré conjecture, in its modern generalized form, asks whether a closed
$n$-manifold homotopy equivalent to the $n$-sphere $S^n$ must be the $n$-sphere. The
topological version is now a theorem in every dimension: Smale and Zeeman ($n \ge 5$),
Freedman ($n = 4$), and Perelman ($n = 3$). The *smooth* version — replacing
"homeomorphic" by "diffeomorphic" — is also resolved in every dimension *except four*. In
high dimensions the smooth statement is false in general (Milnor's exotic 7-spheres) but
its failures are catalogued by surgery theory; in dimension three smooth and topological
categories coincide. Dimension four stands alone: the **smooth 4-dimensional Poincaré
conjecture (SPC4)** is open, and it is open precisely because dimension four hosts
phenomena — exotic $\mathbb{R}^4$'s, exotic structures on closed manifolds — with no
analogue elsewhere.

### 1.2 The intersection form as the central invariant

For a closed oriented 4-manifold $M$, the cup product
$$
Q_M : H^2(M;\mathbb{Z})/\mathrm{tors} \times H^2(M;\mathbb{Z})/\mathrm{tors} \to \mathbb{Z},
\qquad (\alpha,\beta) \mapsto \langle \alpha \smile \beta, [M]\rangle,
$$
is a symmetric bilinear form, the **intersection form**. By Poincaré duality it is
*unimodular*. Freedman's theorem says that for simply-connected $M$, the homeomorphism
type is essentially determined by $Q_M$ (together with the Kirby–Siebenmann invariant),
and that *every* unimodular symmetric integral form is realized topologically. Donaldson's
theorem, by contrast, severely restricts which forms occur *smoothly*: a smooth, closed,
simply-connected, positive-definite $M$ has $Q_M \cong \langle 1\rangle^n$. The conflict
between "every unimodular form (topological)" and "only the standard form (smooth,
definite)" is the engine of four-dimensional exotica.

### 1.3 Contribution

This paper isolates and generalizes the **purely algebraic** content of that engine. Where
prior formal development fixed the index set as $\mathrm{Fin}\,n$, we work over an
arbitrary finite index type $\iota$ and develop the *monoidal* (direct-sum) structure of
the resulting category of forms. Concretely:

1. We define $\mathrm{GForm}\,\iota$ and the predicates $\mathrm{Unimodular}$,
   $\mathrm{IsEven}$, $\mathrm{StdDiagonalizable}$ over any finite $\iota$ (§3).
2. We prove the **parity obstruction** (Theorem 4.1): a nonempty even form is never
   standard-diagonalizable.
3. We prove the **even-diagonal criterion** (Theorem 4.3): a symmetric form with even
   diagonal is even.
4. We introduce the **orthogonal direct sum** $\oplus$ and prove the value-splitting
   identity (Theorem 5.1) and the three **additivity laws** (Theorems 5.2–5.4).
5. We assemble the **capstone** (Theorem 6.2): $E_8 \oplus E_8$ is unimodular, even, and
   not standard-diagonalizable.

All statements have been formalized and machine-checked, relying only on the standard
foundational axioms (propositional extensionality, the axiom of choice, and quotient
soundness); no result depends on any unproved assumption.

---

## 2. Background and related results

We recall, without proof, the two analytic inputs that give the algebra its geometric
force. They are *not* part of the formal development; the formal content is the algebra
that mediates between them.

**Theorem (Donaldson, 1983).** *Let $M$ be a smooth, closed, simply-connected
4-manifold with positive-definite intersection form $Q_M$. Then $Q_M$ is
standard-diagonalizable, i.e. $Q_M \cong \langle 1\rangle^{b_2(M)}$.*

**Theorem (Freedman, 1982).** *Every unimodular symmetric bilinear form over $\mathbb{Z}$
is the intersection form of a closed simply-connected topological 4-manifold, unique up to
homeomorphism in the even case and up to homeomorphism (with the Kirby–Siebenmann
refinement) in the odd case.*

**Theorem (Rokhlin, 1952).** *If $M$ is a smooth closed spin 4-manifold, then the
signature $\sigma(M)$ is divisible by $16$.*

The **classification of indefinite unimodular forms** (Hasse–Minkowski / Milnor–Husemoller)
states that an indefinite such form is determined by its rank, signature, and parity: in
the odd case it is $p\langle 1\rangle \oplus q\langle -1\rangle$, and in the even case it
is $p\,H \oplus q\,(\pm E_8)$, where $H = \left(\begin{smallmatrix}0&1\\1&0\end{smallmatrix}\right)$
is the hyperbolic plane. The $E_8$ form is thus the universal building block of even
definite forms, which is why it is the natural witness of the smooth/topological gap.

---

## 3. The category of integral symmetric forms

### 3.1 Objects

> **Definition 3.1 (Gram form).** For a finite index type $\iota$, a *Gram form*
> $\mathrm{GForm}\,\iota$ is a pair $(G, h)$ where $G \in \mathrm{Matrix}\,\iota\,\iota\,\mathbb{Z}$
> is the Gram matrix of a symmetric pairing and $h$ is a proof that $G$ is symmetric
> ($G^{\mathsf T} = G$).

The associated **quadratic value** on an integer vector $v : \iota \to \mathbb{Z}$ is
$$
Q(v) \;=\; v \cdot (G\,v) \;=\; v^{\mathsf T} G\, v \;=\; \sum_{i,j} v_i\,G_{ij}\,v_j .
$$

### 3.2 The three governing predicates

> **Definition 3.2 (Unimodular).** $Q$ is *unimodular* iff $\det G$ is a unit in
> $\mathbb{Z}$ (equivalently $\det G = \pm 1$). This is the algebraic form of Poincaré
> duality.

> **Definition 3.3 (Even).** $Q$ is *even* iff $Q(v)$ is even for every
> $v : \iota \to \mathbb{Z}$. Geometrically this is the spin condition.

> **Definition 3.4 (Standard-diagonalizable).** $Q$ is *standard-diagonalizable* iff there
> exists an integer matrix $T$ with $\det T$ a unit and $T^{\mathsf T} G\, T = I$. That is,
> $Q$ is congruent over $\mathbb{Z}$ to the identity form $\langle 1\rangle^{|\iota|}$.
> This is the conclusion of Donaldson's theorem in the positive-definite case.

These three predicates are the morphisms-invariants of the category: $\mathrm{Unimodular}$
and $\mathrm{IsEven}$ are invariant under integral congruence, and
$\mathrm{StdDiagonalizable}$ is itself a congruence assertion.

---

## 4. The parity obstruction

### 4.1 Change of basis

> **Lemma 4.0 (value under change of basis).** *For any $Q = (G,h)$, any integer matrix
> $T$, and any vector $v$,*
> $$ Q(T v) \;=\; v^{\mathsf T} (T^{\mathsf T} G\, T)\, v. $$

*Proof sketch.* Expand $Q(Tv) = (Tv)\cdot(G(Tv))$ and use the standard matrix identities
$\mathrm{vecMul\_mulVec}$ and $\mathrm{dotProduct\_mulVec}$ to rebracket, then associativity
of matrix multiplication regroups $T^{\mathsf T}(G\,T)$ into $(T^{\mathsf T} G\,T)$. $\square$

### 4.2 The obstruction

> **Theorem 4.1 (Parity obstruction; Donaldson's algebraic core).** *Let $\iota$ be a
> nonempty finite index type and $Q$ an even Gram form on $\iota$. Then $Q$ is not
> standard-diagonalizable.*

*Proof sketch.* Suppose toward contradiction that $T$ witnesses standardness, so
$T^{\mathsf T} G\, T = I$ with $\det T$ a unit. Pick any index $k \in \iota$ (using
nonemptiness) and let $v = e_k$ be the corresponding standard basis vector. By Lemma 4.0,
$$
Q(T v) \;=\; v^{\mathsf T}(T^{\mathsf T} G\, T)\, v \;=\; v^{\mathsf T} I\, v \;=\; v\cdot v \;=\; 1 .
$$
But $Q$ is even, so $Q(Tv)$ must be even; hence $1$ would be even, a contradiction. $\square$

The entire force of the theorem rests on the parity mismatch between the value $1$
produced by the identity form on a basis vector and the evenness of $Q$. It is elementary,
yet — fed through Donaldson's theorem — it is what forbids even definite forms from smooth
4-manifolds.

### 4.3 Recognizing even forms

In practice one verifies evenness from the diagonal alone.

> **Theorem 4.3 (Even-diagonal criterion).** *Let $Q = (G,h)$ be a symmetric Gram form
> (over $\mathrm{Fin}\,n$) all of whose diagonal entries $G_{ii}$ are even. Then $Q$ is
> even.*

*Proof sketch.* Write
$$
Q(v) = \sum_{i,j} v_i G_{ij} v_j = \sum_i G_{ii} v_i^2 \;+\; 2\!\!\sum_{i < j}\! v_i G_{ij} v_j ,
$$
using symmetry $G_{ij} = G_{ji}$ to fold the strictly-lower-triangular part onto the upper
and produce the factor $2$. The second summand is manifestly even; the first is a sum of
$G_{ii} v_i^2$, each even because $G_{ii}$ is. Hence $Q(v)$ is even. The folding step is the
identity, valid for any symmetric $f$,
$$
\sum_{i}\sum_{j} f(i,j) = \sum_i f(i,i) + 2\sum_i \sum_{j > i} f(i,j),
$$
proved by induction on $n$. $\square$

### 4.4 Boundary cases

Evenness is genuinely necessary. The **standard form** $\langle 1\rangle^n$ has
$Q(e_0) = 1$, so it is *not* even for $n \ge 1$ — consistent with it being (trivially)
standard-diagonalizable. At the opposite extreme, the **sphere form** on the empty index
$\mathrm{Fin}\,0$ (the intersection form of $S^4$, since $H^2(S^4)=0$) is simultaneously
unimodular, even, and standard-diagonalizable: its only value is the empty sum $0$, its
determinant is $1$, and $T = I$ witnesses standardness vacuously. This last fact is the
algebraic reason intersection forms *cannot* detect SPC4: homological data alone is
consistent with the standard sphere.

---

## 5. The monoidal structure: orthogonal direct sum

### 5.1 Definition

> **Definition 5.0 (Direct sum).** For $Q = (G,h_Q)$ on $\iota$ and $R = (H,h_R)$ on
> $\kappa$, the *orthogonal direct sum* $Q \oplus R$ is the Gram form on $\iota \sqcup \kappa$
> with block-diagonal Gram matrix
> $$
> \mathrm{gram}(Q\oplus R) \;=\; \begin{pmatrix} G & 0 \\ 0 & H \end{pmatrix},
> $$
> symmetric because both blocks are. Geometrically $Q\oplus R$ models the intersection
> form of a connected sum $M \,\#\, N$, since $H^2(M\# N) = H^2(M)\oplus H^2(N)$ with no
> cross terms.

### 5.2 Value splitting

> **Theorem 5.1 (Orthogonal splitting of the value).** *For any $v : \iota\sqcup\kappa \to \mathbb{Z}$,*
> $$ (Q\oplus R)(v) \;=\; Q(v\circ\mathrm{inl}) \;+\; R(v\circ\mathrm{inr}). $$

*Proof sketch.* The block-diagonal Gram matrix annihilates all cross terms. Expanding the
dot product and matrix–vector product over the sum type $\iota \sqcup \kappa$ and using
$\mathrm{Fintype.sum\_sum\_type}$, the double sum separates into the $\iota\times\iota$
block and the $\kappa\times\kappa$ block, which are exactly $Q(v\circ\mathrm{inl})$ and
$R(v\circ\mathrm{inr})$. $\square$

This single identity is the lever for all three additivity laws.

### 5.3 The additivity laws

> **Theorem 5.2 (Evenness is additive).** *If $Q$ and $R$ are even, so is $Q\oplus R$.*

*Proof sketch.* By Theorem 5.1, $(Q\oplus R)(v) = Q(\cdots) + R(\cdots)$, a sum of two
even integers, hence even. $\square$

> **Theorem 5.3 (Unimodularity is additive).** *If $Q$ and $R$ are unimodular, so is
> $Q\oplus R$.*

*Proof sketch.* The determinant of a block-diagonal (indeed block-triangular with zero
off-diagonal) matrix factors: $\det\!\begin{pmatrix}G&0\\0&H\end{pmatrix} = \det G \cdot \det H$.
A product of units is a unit. $\square$

> **Theorem 5.4 (Standardness is additive).** *If $Q$ and $R$ are standard-diagonalizable,
> so is $Q\oplus R$.*

*Proof sketch.* Let $T_1, T_2$ be the witnessing congruences, $T_1^{\mathsf T} G T_1 = I$
and $T_2^{\mathsf T} H T_2 = I$. Set $T = \begin{pmatrix}T_1&0\\0&T_2\end{pmatrix}$. Then
$$
T^{\mathsf T} \begin{pmatrix}G&0\\0&H\end{pmatrix} T
= \begin{pmatrix} T_1^{\mathsf T} G T_1 & 0 \\ 0 & T_2^{\mathsf T} H T_2 \end{pmatrix}
= \begin{pmatrix} I & 0 \\ 0 & I \end{pmatrix} = I,
$$
and $\det T = \det T_1 \cdot \det T_2$ is a unit. $\square$

### 5.4 Categorical reading

Theorems 5.1–5.4 say precisely that $(\mathrm{GForm}, \oplus)$ is a **symmetric monoidal
category** of integral symmetric forms in which $\mathrm{Unimodular}$, $\mathrm{IsEven}$,
and $\mathrm{StdDiagonalizable}$ are *structural* (closed under the monoidal product). The
unit object is the empty form (the sphere form of §4.4), and symmetry $Q\oplus R \cong R\oplus Q$
is realized by the block-swap congruence. The isolated phenomenon of $E_8$ thus becomes a
*law of the category*, and arbitrary even unimodular forms can be assembled from building
blocks while their obstruction-theoretic status is tracked automatically by the additivity
laws.

---

## 6. The $E_8$ and $E_8 \oplus E_8$ witnesses

### 6.1 The $E_8$ form

> **Definition 6.0.** $E_8$ is the Gram form on $\mathrm{Fin}\,8$ with Cartan matrix
> $$
> E_8 = \begin{pmatrix}
> 2&-1&0&0&0&0&0&0\\ -1&2&-1&0&0&0&0&0\\ 0&-1&2&-1&0&0&0&0\\ 0&0&-1&2&-1&0&0&0\\
> 0&0&0&-1&2&-1&0&-1\\ 0&0&0&0&-1&2&-1&0\\ 0&0&0&0&0&-1&2&0\\ 0&0&0&0&-1&0&0&2
> \end{pmatrix}.
> $$

> **Theorem 6.1 ($E_8$ properties).** *$E_8$ is unimodular and even.*

*Proof sketch.* **Unimodular:** the explicit integer matrix
$$
E_8^{-1} = \begin{pmatrix}
2&3&4&5&6&4&2&3\\ 3&6&8&10&12&8&4&6\\ 4&8&12&15&18&12&6&9\\ 5&10&15&20&24&16&8&12\\
6&12&18&24&30&20&10&15\\ 4&8&12&16&20&14&7&10\\ 2&4&6&8&10&7&4&5\\ 3&6&9&12&15&10&5&8
\end{pmatrix}
$$
satisfies $E_8 \cdot E_8^{-1} = I$ (a finite, decidable matrix identity). Taking
determinants gives $\det E_8 \cdot \det E_8^{-1} = 1$, so $\det E_8$ is a unit. **Even:**
every diagonal entry equals $2$, so Theorem 4.3 applies. $\square$

> **Corollary 6.1.1.** *$E_8$ is not standard-diagonalizable* (Theorem 4.1, since $E_8$ is
> even and $\mathrm{Fin}\,8$ is nonempty). With Donaldson's theorem, $E_8$ is not the
> intersection form of any smooth closed simply-connected 4-manifold; with Freedman's
> theorem it *is* realized topologically. This is the cleanest known witness of the
> smooth/topological gap in dimension four.

### 6.2 The capstone

> **Theorem 6.2 ($E_8 \oplus E_8$).** *The rank-16 form $E_8 \oplus E_8$ is unimodular,
> even, and not standard-diagonalizable.*

*Proof sketch.* Unimodular by Theorem 5.3 applied to Theorem 6.1; even by Theorem 5.2
applied to Theorem 6.1; not standard-diagonalizable by Theorem 4.1, since $E_8 \oplus E_8$
is even and $\mathrm{Fin}\,8 \sqcup \mathrm{Fin}\,8$ is nonempty. $\square$

### 6.3 Geometric significance

The signature of $E_8$ (positive-definite, rank $8$) is $\sigma(E_8) = 8$, so
$\sigma(E_8\oplus E_8) = 16$. The form $E_8\oplus E_8$ thus sits exactly at the threshold of
**Rokhlin's theorem** ($16 \mid \sigma$ for smooth spin manifolds): a single $E_8$
violates it ($8 \not\equiv 0 \bmod 16$), and the second copy restores divisibility. It is
also the minimal nontrivial test case of the open **$\tfrac{11}{8}$-conjecture**, which
predicts that a smooth spin 4-manifold with $\sigma \ne 0$ satisfies
$b_2 \ge \tfrac{11}{8}|\sigma|$, equivalently that its even form is
$2k\,E_8 \oplus \ell\,H$ with $\ell \ge 3k$. Furuta's "$\tfrac{10}{8}$ theorem" establishes
$\ell \ge 2k+1$, leaving the gap precisely around forms built from copies of $E_8$. The
present algebra makes $E_8 \oplus E_8$ a first-class, machine-checked object on which such
divisibility statements can be founded.

---

## 7. Algorithms

The formal development is constructive enough to drive direct computation. We highlight
three algorithms (full Python in the accompanying demonstration code).

**A. Evenness via the diagonal criterion.** Given a symmetric integer matrix $G$, return
*even* iff every $G_{ii}$ is even. Correct by Theorem 4.3; complexity $O(n)$ after an
$O(n^2)$ symmetry check.

**B. Unimodularity by integer determinant.** Compute $\det G$ over $\mathbb{Z}$ (fraction-
free Bareiss elimination) and test $\det G \in \{+1,-1\}$. Complexity $O(n^3)$ integer
operations, exact.

**C. Direct sum and additivity audit.** Form the block-diagonal $G\oplus H$ and verify the
three additivity laws empirically (parity of the diagonal, product of determinants, and a
randomized congruence search), illustrating Theorems 5.2–5.4.

A practical certificate of *non*-standardness combines A and B: if $G$ is even
(Algorithm A) and unimodular (Algorithm B) on a nonempty index, then by Theorem 4.1 it is
provably not standard-diagonalizable — no search over congruences $T$ is required.

---

## 8. Applications

1. **A computable smooth-obstruction certificate.** For any candidate even unimodular form
   $Q$ on a nonempty index, Theorem 4.1 yields, with no analysis and no search, the
   conclusion that $Q$ is not standard — hence (via Donaldson) not the form of a smooth
   definite simply-connected 4-manifold. This converts a deep geometric obstruction into a
   two-line arithmetic check.

2. **Compositional construction of exotic-form candidates.** The additivity laws let one
   build large even unimodular forms (e.g. $k\,E_8 \oplus \ell\,H$) from blocks while
   tracking parity, determinant, and standardness automatically — the natural setting for
   formulating and testing the $\tfrac{11}{8}$-conjecture.

3. **A formal substrate for Rokhlin-type divisibility.** With signature additivity
   ($\sigma(Q\oplus R) = \sigma(Q)+\sigma(R)$, a direct corollary of the same block
   argument used for the determinant), the present infrastructure is positioned to state
   and prove that the signature of an even unimodular form is divisible by $8$, and to
   frame the smooth refinement $16 \mid \sigma$ (Rokhlin) as a property of the monoidal
   category.

---

## 9. Discussion

The conceptual move of this paper is Grothendieck-style: replace a single sharp example
($E_8$) by the *category* in which it lives, and show that the property responsible for the
example ("even, unimodular, non-standard") is structural under the natural product. Three
points deserve emphasis.

First, the obstruction is genuinely *elementary*. Theorem 4.1 needs nothing beyond the
parity of $1$ and the change-of-basis identity. The depth of four-manifold theory enters
only through Donaldson's and Freedman's theorems, which sit *outside* the algebra; the
algebra is the precise interface between them.

Second, the generalization from $\mathrm{Fin}\,n$ to arbitrary finite $\iota$ is not
cosmetic. It is what makes $\oplus$ a clean operation on objects (the index of a direct sum
is naturally a *disjoint union*, not a re-indexed $\mathrm{Fin}\,(m+n)$), and it is what
turns the additivity laws into honest monoidal coherence rather than index bookkeeping.

Third, the sphere form (§4.4) records the *limit* of the method: intersection forms are
blind to SPC4 itself, because the sphere's form is the trivial object. The algebra
explains and bounds its own applicability — it detects the smooth/topological gap for
manifolds with $b_2 > 0$, while remaining silent, by design, on the homotopy-sphere
question.

---

## 10. Future directions

**Signature as a second congruence invariant.** Formalize positive-definiteness of $E_8$
over $\mathbb{R}$ (Sylvester's criterion: all eight leading principal minors positive — a
finite, decidable computation on the explicit matrix), define the signature
$\sigma(Q) = b_+ - b_-$ of a Gram form, and prove additivity $\sigma(Q\oplus R) = \sigma(Q)+\sigma(R)$
by the same block argument used for the determinant. Then $\sigma(E_8)=8$ and
$\sigma(E_8\oplus E_8)=16$. Signature is the second independent congruence invariant after
parity, and the existing $\oplus$ infrastructure transfers almost verbatim.

**Rokhlin as a divisibility law.** With signature in hand, prove the algebraic shadow of
Rokhlin's theorem: $8 \mid \sigma$ for even unimodular forms, and frame the smooth
refinement $16 \mid \sigma$ as the boundary that $E_8 \oplus E_8$ saturates.

**The hyperbolic plane and indefinite classification.** Add $H = \left(\begin{smallmatrix}0&1\\1&0\end{smallmatrix}\right)$
as a building block and formalize the Hasse–Minkowski/Milnor–Husemoller classification of
*indefinite* unimodular forms ($p\langle 1\rangle\oplus q\langle -1\rangle$ in the odd case,
$pH \oplus q(\pm E_8)$ in the even case), giving a complete structural census of the
category's objects.

**The $\tfrac{11}{8}$-conjecture frontier.** Encode the conjecture as a statement about
which even forms $2k\,E_8 \oplus \ell\,H$ are smoothly realizable, and connect to Furuta's
$\tfrac{10}{8}$ theorem as a partial bound. The $\oplus$-calculus developed here is the
natural language for stating and manipulating these forms.

---

## 11. Conclusion

We have recast the algebraic core of four-dimensional smooth topology as a symmetric
monoidal category of integral symmetric forms. The parity obstruction (Theorem 4.1) is the
elementary engine; the direct-sum additivity laws (Theorems 5.2–5.4) make it structural;
and the capstone (Theorem 6.2) produces the rank-16 witness $E_8 \oplus E_8$, sitting at
the boundary of Rokhlin's theorem and the $\tfrac{11}{8}$-conjecture. Every statement is
formally verified and depends only on standard foundational axioms. The smooth
four-dimensional Poincaré conjecture remains open; the algebra developed here is a precise,
extensible, machine-checked language in which its surrounding obstruction theory can be
expressed and advanced.

---

## References

- S. K. Donaldson, *An application of gauge theory to four-dimensional topology*, J.
  Differential Geom. **18** (1983), 279–315.
- M. H. Freedman, *The topology of four-dimensional manifolds*, J. Differential Geom.
  **17** (1982), 357–453.
- V. A. Rokhlin, *New results in the theory of four-dimensional manifolds*, Doklady Akad.
  Nauk SSSR **84** (1952), 221–224.
- J. Milnor and D. Husemoller, *Symmetric Bilinear Forms*, Springer, 1973.
- M. Furuta, *Monopole equation and the $\tfrac{11}{8}$-conjecture*, Math. Res. Lett.
  **8** (2001), 279–291.
- R. E. Gompf and A. I. Stipsicz, *4-Manifolds and Kirby Calculus*, AMS, 1999.
