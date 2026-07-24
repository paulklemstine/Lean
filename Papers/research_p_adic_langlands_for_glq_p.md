# Foundations of the p-adic Langlands Correspondence for $GL_2(\mathbb{Q}_p)$: The Determinant Bridge and Twisting Compatibilities

## Abstract

We develop a self-contained algebraic foundation for the two sides of the
$p$-adic Langlands correspondence for $GL_2(\mathbb{Q}_p)$. On the automorphic
side we study the group $GL_2(K)$ over a field $K$ (specialized to
$K = \mathbb{Q}_p$), its scalar center, and the determinant homomorphism
$\det : GL_2(K) \to K^{\times}$. On the Galois side we study two-dimensional
representations $\rho : G \to GL_2(K)$ of an abstract group $G$ (a stand-in for
the absolute Galois group $\mathrm{Gal}(\overline{\mathbb{Q}}_p/\mathbb{Q}_p)$),
their determinant characters, and their behavior under character twists. We
prove: (i) the Cayley–Hamilton identity $M^2 = (\operatorname{tr}M)M -
(\det M)I$ for $2\times 2$ matrices, together with the adjugate identity it
implies; (ii) that the determinant $GL_2(K)\to K^{\times}$ is a surjective
homomorphism with kernel $SL_2(K)$; (iii) a bijection — the abelian, $GL_1$
shadow of local Langlands — between characters of $K^{\times}$ and characters of
$GL_2(K)$ trivial on $SL_2(K)$; (iv) the centrality of scalar matrices and the
fact that the determinant of $uI$ is $u^2$; and (v) the twisting compatibility
$\det(\chi\otimes\rho) = \chi^2\cdot\det\rho$. All results are specialized to
$K = \mathbb{Q}_p$. These statements form a rigid algebraic skeleton onto which
the analytic theory (Banach representations, the Montréal functor) can be
attached.

**Keywords.** $p$-adic Langlands, $GL_2(\mathbb{Q}_p)$, Galois representations,
determinant character, Cayley–Hamilton, central character, class field theory,
twisting.

---

## 1. Introduction

The Langlands program predicts deep and precise correspondences between two
seemingly disparate worlds: the arithmetic of Galois representations and the
harmonic analysis of automorphic representations. Its *local* incarnations attach,
to representations of the absolute Galois group of a local field, representations
of a reductive group over that field. The $p$-adic Langlands correspondence for
$GL_2(\mathbb{Q}_p)$ — developed by Breuil, Colmez, Emerton, Paškūnas, and others
— is the richest fully understood case: it establishes a bijection between certain
irreducible unitary $\mathbb{Q}_p$-Banach representations of $GL_2(\mathbb{Q}_p)$
and two-dimensional $p$-adic representations of
$\mathrm{Gal}(\overline{\mathbb{Q}}_p/\mathbb{Q}_p)$, realized concretely through
Colmez's *Montréal functor*.

The full correspondence is analytic and difficult. But beneath it lies a purely
algebraic layer that is completely explicit, and that already exhibits the shape
of the general theory: the interplay of trace and determinant on the Galois side,
the determinant homomorphism and central character on the automorphic side, and
the compatibility of the two under twisting. This paper isolates that algebraic
layer and proves it in full.

Our contributions, all proved rigorously and specialized to
$K = \mathbb{Q}_p = \mathbb{Q}_p$, are:

1. **Characteristic polynomial (Section 3).** The Cayley–Hamilton identity for
   $2 \times 2$ matrices and the adjugate identity it yields.
2. **The determinant bridge (Section 4).** Surjectivity of $\det$, identification
   of its kernel with $SL_2$, and the resulting bijection between characters of
   $K^{\times}$ and characters of $GL_2(K)$ trivial on $SL_2(K)$ — the abelian
   ($GL_1$) part of local Langlands.
3. **The center (Section 5).** The scalar embedding $K^{\times}\to GL_2(K)$, its
   centrality, and the determinant-squaring identity $\det(uI) = u^2$.
4. **Twisting on the Galois side (Section 6).** Definition of the twist
   $\chi\otimes\rho$ of a two-dimensional representation by a character, and the
   compatibility $\det(\chi\otimes\rho) = \chi^2\cdot\det\rho$.
5. **$p$-adic specialization (Section 7).** All of the above at
   $K = \mathbb{Q}_p$.

Throughout, $K$ denotes a field, $I$ the identity matrix, and $G$ an abstract
group standing in for the absolute Galois group.

---

## 2. Preliminaries and notation

Let $K$ be a field. We write $M_2(K)$ for the ring of $2\times 2$ matrices over
$K$ and $GL_2(K)$ for the group of invertible ones; $K^{\times}$ denotes the
multiplicative group of nonzero elements. For a matrix $M \in M_2(K)$,
$\operatorname{tr}M = M_{11}+M_{22}$ is its trace and $\det M = M_{11}M_{22} -
M_{12}M_{21}$ its determinant. The special linear group is
$SL_2(K) = \{M \in GL_2(K) : \det M = 1\}$.

A **character** of a group $H$ (valued in a group $A$) is a homomorphism
$H \to A$. When $A = K^{\times}$ these are the multiplicative characters in the
usual sense; we allow general abelian — indeed general — targets $A$ where it
costs nothing.

A **two-dimensional representation** of a group $G$ over $K$ is a homomorphism
$\rho : G \to GL_2(K)$.

The field $\mathbb{Q}_p$ of $p$-adic numbers is the completion of $\mathbb{Q}$
with respect to the $p$-adic absolute value $|x|_p = p^{-v_p(x)}$, where $v_p(x)$
is the exponent of $p$ in $x$. It is a field, and all results proved for a general
field $K$ apply to it verbatim.

---

## 3. The characteristic polynomial of a two-dimensional representation

The single algebraic fact underlying the trace-and-determinant data of a
two-dimensional representation is that a $2\times 2$ matrix satisfies its own
characteristic polynomial.

**Theorem 3.1 (Cayley–Hamilton for $2\times 2$ matrices).**
*For every $M \in M_2(K)$,*
$$M^2 = (\operatorname{tr}M)\,M - (\det M)\,I.$$

*Proof.* The characteristic polynomial of a $2\times 2$ matrix is
$p_M(X) = X^2 - (\operatorname{tr}M)X + \det M$. The general Cayley–Hamilton
theorem asserts $p_M(M) = 0$, i.e. $M^2 - (\operatorname{tr}M)M + (\det M)I = 0$,
which rearranges to the stated identity. (Directly: writing
$M = \begin{psmallmatrix} a & b \\ c & d\end{psmallmatrix}$, one computes
$M^2 = \begin{psmallmatrix} a^2+bc & b(a+d) \\ c(a+d) & d^2+bc\end{psmallmatrix}$,
$(\operatorname{tr}M)M = (a+d)\begin{psmallmatrix} a & b \\ c & d\end{psmallmatrix}$,
and $(\det M)I = (ad-bc)I$; subtracting confirms the identity entrywise.) $\qquad\blacksquare$

On the Galois side, Theorem 3.1 is the relation satisfied by the image of
Frobenius in a two-dimensional representation: the representation is controlled by
the trace and determinant of Frobenius, which are exactly the coefficients of the
characteristic polynomial.

The identity immediately produces the inverse of an invertible matrix as a
polynomial in the matrix itself.

**Corollary 3.2 (Adjugate identity).**
*For every $M \in M_2(K)$,*
$$M\big((\operatorname{tr}M)\,I - M\big) = (\det M)\,I.$$
*In particular, if $\det M \neq 0$ then $M$ is invertible with*
$$M^{-1} = \tfrac{1}{\det M}\big((\operatorname{tr}M)\,I - M\big).$$

*Proof.* Expand the left-hand side and apply Theorem 3.1:
$M((\operatorname{tr}M)I - M) = (\operatorname{tr}M)M - M^2 = (\operatorname{tr}M)M
- ((\operatorname{tr}M)M - (\det M)I) = (\det M)I$. Dividing by the nonzero scalar
$\det M$ gives the inverse formula. $\qquad\blacksquare$

Corollary 3.2 is the concrete mechanism behind invertibility in $GL_2$: it both
certifies that a matrix of nonzero determinant is invertible and exhibits the
inverse explicitly, and it locates the matrix $(\operatorname{tr}M)I - M$ as the
adjugate of $M$.

---

## 4. The determinant bridge and the abelian correspondence

We now study the determinant as a group homomorphism $GL_2(K) \to K^{\times}$ and
extract from it the abelian part of the correspondence.

### 4.1 Surjectivity and kernel

**Definition 4.1.** For $u \in K^{\times}$, let $\operatorname{diag}(u,1)$ denote
the diagonal element of $GL_2(K)$ with diagonal entries $u$ and $1$; its inverse
is $\operatorname{diag}(u^{-1},1)$.

**Lemma 4.2.** $\det\operatorname{diag}(u,1) = u$.

*Proof.* The determinant of a diagonal $2\times 2$ matrix is the product of its
diagonal entries: $u \cdot 1 = u$. $\qquad\blacksquare$

**Theorem 4.3 (The determinant is surjective).**
*The determinant homomorphism $\det : GL_2(K) \to K^{\times}$ is surjective.*

*Proof.* Given $u \in K^{\times}$, the element $\operatorname{diag}(u,1)$ of
$GL_2(K)$ has determinant $u$ by Lemma 4.2. $\qquad\blacksquare$

This is the $GL_2 \twoheadrightarrow GL_1$ reciprocity underlying the abelian part
of the correspondence.

**Proposition 4.4 (Kernel of the determinant).**
*An element $g \in GL_2(K)$ lies in $\ker\det$ if and only if $\det g = 1$; that
is, $\ker\det = SL_2(K)$.*

*Proof.* By definition $g \in \ker\det$ iff $\det g$ is the identity of
$K^{\times}$, i.e. $\det g = 1$, which is exactly the defining condition of
$SL_2(K)$. $\qquad\blacksquare$

### 4.2 The abelian ($GL_1$) correspondence

Surjectivity of $\det$ with kernel $SL_2$ yields, by the universal property of
quotient groups, a precise bijection between characters of $K^{\times}$ and those
characters of $GL_2(K)$ that ignore $SL_2$.

**Theorem 4.5 (Abelian local Langlands, $GL_1$ shadow).**
*Let $A$ be any group. Precomposition with $\det$ defines a bijection*
$$\big(K^{\times} \to A\big) \;\xrightarrow{\ \sim\ }\;
\big\{\, f : GL_2(K) \to A \ \text{a homomorphism with}\ SL_2(K) \subseteq \ker f \,\big\},
\qquad \chi \mapsto \chi\circ\det.$$
*Equivalently: every homomorphism $GL_2(K)\to A$ trivial on $SL_2(K)$ factors
uniquely through the determinant.*

*Proof.* By Theorem 4.3 the determinant $\det : GL_2(K)\to K^{\times}$ is a
surjective homomorphism, and by Proposition 4.4 its kernel is $SL_2(K)$. Hence
$\det$ realizes $K^{\times}$ as the quotient $GL_2(K)/SL_2(K)$. The universal
property of the quotient states that homomorphisms out of $GL_2(K)/SL_2(K)$ — i.e.
homomorphisms out of $GL_2(K)$ that are trivial on $SL_2(K)$ — correspond exactly
to homomorphisms out of $K^{\times}$, the correspondence being precomposition with
the quotient map $\det$. This is the claimed bijection.

Concretely, injectivity: if $\chi_1\circ\det = \chi_2\circ\det$, then since $\det$
is surjective (right-cancellable) we get $\chi_1 = \chi_2$. Surjectivity: given
$f$ trivial on $SL_2(K) = \ker\det$, the map $\chi(u) := f(g)$ for any $g$ with
$\det g = u$ is well defined (independence of the choice of $g$ follows from
triviality on the kernel), is a homomorphism, and satisfies $\chi\circ\det = f$.
$\qquad\blacksquare$

**Corollary 4.6 (Injectivity of twisting).** *The map $\chi \mapsto \chi\circ\det$
from characters of $K^{\times}$ to characters of $GL_2(K)$ is injective: distinct
characters of $K^{\times}$ give distinct twisting characters of $GL_2(K)$.*

*Proof.* Immediate from the right-cancellability of the surjection $\det$, as in
the injectivity step above. $\qquad\blacksquare$

Under local class field theory, characters of $\mathbb{Q}_p^{\times}$ are
identified with characters of the abelianized Weil group — that is, with
one-dimensional Galois representations. Theorem 4.5 therefore *is* the local
Langlands correspondence for $GL_1$: it matches one-dimensional Galois data with
the abelian characters of $GL_2(\mathbb{Q}_p)$. The full $p$-adic correspondence
for $GL_2$ is the two-dimensional refinement of this statement.

---

## 5. The center: scalar matrices and the central character

The center of $GL_2(K)$ consists of the scalar matrices, and it carries the
"central character" data that the correspondence must respect.

**Definition 5.1 (Scalar embedding).** Let $\iota : K^{\times} \to GL_2(K)$ send
$u \mapsto u I$, the scalar matrix with $u$ on the diagonal.

$\iota$ is a group homomorphism because $(uv)I = (uI)(vI)$ and $1\cdot I = I$.

**Proposition 5.2 (Determinant of a scalar).** *For $u \in K^{\times}$,*
$$\det(\iota(u)) = \det(uI) = u^2.$$

*Proof.* The scalar matrix $uI$ is diagonal with both diagonal entries equal to
$u$, so its determinant is $u\cdot u = u^2$. $\qquad\blacksquare$

The appearance of $u^2$ rather than $u$ — the scalar hits both diagonal entries —
is the source of the factor $\chi^2$ in the twisting law of Section 6.

**Proposition 5.3 (Centrality).** *For every $u\in K^{\times}$ and every
$g \in GL_2(K)$, $\iota(u)\,g = g\,\iota(u)$. That is, scalar matrices are
central.*

*Proof.* For any matrix $N$, $(uI)N = uN = N(uI)$ entrywise, since scalar
multiplication commutes with matrix multiplication. Restricting to invertible $g$
gives the claim. $\qquad\blacksquare$

Centrality is exactly what makes the twist of a representation well defined: it
lets the scalar factor slide freely past matrix products.

---

## 6. Twisting two-dimensional representations

We now turn to the Galois side and study how the determinant character of a
two-dimensional representation changes under twisting by a character.

**Definition 6.1 (Determinant character).** For a two-dimensional representation
$\rho : G \to GL_2(K)$, its **determinant character** is
$$\det\rho := \det\circ\,\rho : G \to K^{\times}.$$
Under local class field theory this corresponds to the central character of the
automorphic partner of $\rho$.

**Definition 6.2 (Twist).** Let $\rho : G \to GL_2(K)$ be a two-dimensional
representation and $\chi : G \to K^{\times}$ a character. The **twist** of $\rho$
by $\chi$ is the map
$$(\chi \otimes \rho)(g) := \chi(g)\,\rho(g) = \iota(\chi(g))\,\rho(g).$$

**Proposition 6.3.** *The twist $\chi\otimes\rho$ is again a homomorphism
$G \to GL_2(K)$.*

*Proof.* Clearly $(\chi\otimes\rho)(1) = \chi(1)\rho(1) = I$. For $g,h\in G$,
using that $\chi$ and $\rho$ are homomorphisms and that scalars are central
(Proposition 5.3),
$$
(\chi\otimes\rho)(gh) = \iota(\chi(g)\chi(h))\,\rho(g)\rho(h)
= \iota(\chi(g))\,\rho(g)\,\iota(\chi(h))\,\rho(h)
= (\chi\otimes\rho)(g)\,(\chi\otimes\rho)(h),
$$
where the middle equality moves the central scalar $\iota(\chi(h))$ past $\rho(g)$.
$\qquad\blacksquare$

**Theorem 6.4 (Twisting law for determinants).**
*For every character $\chi : G \to K^{\times}$, every two-dimensional
representation $\rho : G \to GL_2(K)$, and every $g \in G$,*
$$\det(\chi\otimes\rho)(g) = \chi(g)^2 \cdot \det\rho(g),
\qquad\text{i.e.}\qquad \det(\chi\otimes\rho) = \chi^2\cdot\det\rho.$$

*Proof.* By Definition 6.2 and multiplicativity of the determinant,
$$
\det(\chi\otimes\rho)(g) = \det\big(\iota(\chi(g))\,\rho(g)\big)
= \det(\iota(\chi(g)))\cdot\det(\rho(g)).
$$
By Proposition 5.2, $\det(\iota(\chi(g))) = \chi(g)^2$. Hence the right-hand side
is $\chi(g)^2\cdot\det\rho(g)$, as claimed. $\qquad\blacksquare$

Theorem 6.4 is one of the *defining compatibilities* of the Langlands
correspondence: the determinant of a two-dimensional Galois representation matches
the central character of its automorphic partner, and both must transform by the
square of $\chi$ under twisting by $\chi$. The exponent $2$ is the numerical
fingerprint of the two-dimensionality.

---

## 7. Specialization to $\mathbb{Q}_p$

All of the results above hold over an arbitrary field $K$ and specialize to the
field of $p$-adic numbers $\mathbb{Q}_p$ (for any fixed prime $p$) without change.
We record the specializations that constitute the algebraic skeleton of the
$p$-adic Langlands correspondence for $GL_2(\mathbb{Q}_p)$.

**Theorem 7.1.** *Let $p$ be a prime. Then:*

1. *(Cayley–Hamilton)* Every $M \in M_2(\mathbb{Q}_p)$ satisfies
   $M^2 = (\operatorname{tr}M)M - (\det M)I$.
2. *(Surjective determinant)* $\det : GL_2(\mathbb{Q}_p) \to
   \mathbb{Q}_p^{\times}$ is a surjective homomorphism with kernel
   $SL_2(\mathbb{Q}_p)$.
3. *(Abelian correspondence)* For any group $A$, the characters $GL_2(\mathbb{Q}_p)
   \to A$ trivial on $SL_2(\mathbb{Q}_p)$ are in bijection with characters
   $\mathbb{Q}_p^{\times}\to A$, via $\chi\mapsto\chi\circ\det$.
4. *(Twisting law)* For every $\chi : G \to \mathbb{Q}_p^{\times}$, every
   $\rho : G \to GL_2(\mathbb{Q}_p)$, and every $g\in G$,
   $\det(\chi\otimes\rho)(g) = \chi(g)^2\det\rho(g)$.

*Proof.* Each statement is the corresponding general result of Sections 3–6
(Theorem 3.1, Theorems 4.3/4.5 with Proposition 4.4, and Theorem 6.4) applied to
the field $K = \mathbb{Q}_p$. $\qquad\blacksquare$

---

## 8. Algorithms and computation

The algebraic facts above are constructive and lend themselves to direct
computation over $\mathbb{Q}$ or over the residue rings $\mathbb{Z}/p^k\mathbb{Z}$
(finite-precision models of $\mathbb{Z}_p$). Three computations are natural:

- **Verifying Cayley–Hamilton.** Given $M$, form $M^2$ and
  $(\operatorname{tr}M)M - (\det M)I$ and check equality entrywise. This is an
  $O(1)$ certificate for the characteristic-polynomial relation.
- **Inverting via the adjugate.** Given $M$ with $\det M \neq 0$, compute
  $\frac{1}{\det M}((\operatorname{tr}M)I - M)$ and verify it is a two-sided
  inverse. This turns Corollary 3.2 into a working inversion routine.
- **Checking the twisting law.** For a finite cyclic group $G$, pick a character
  $\chi$ and a representation $\rho$ (a matrix of the right multiplicative order),
  and verify $\det(\chi\otimes\rho)(g) = \chi(g)^2\det\rho(g)$ for every $g$.

The accompanying demonstration code carries out all three over exact arithmetic
and over $p$-adic residue rings.

---

## 9. Applications and significance

- **Local class field theory made explicit.** The abelian correspondence of
  Theorem 4.5 is the $GL_1$ case of local Langlands stated with no reference to
  cohomology or reciprocity maps: it is simply the universal property of the
  determinant. This is the cleanest possible on-ramp to the general program.
- **Central-character bookkeeping.** The twisting law (Theorem 6.4) is exactly
  the compatibility one must check when normalizing the $p$-adic correspondence,
  or when comparing a representation with its twists; the $\chi^2$ factor governs
  how determinants shift.
- **A rigid scaffold for the analytic theory.** The full correspondence is
  formulated for unitary Banach representations; the algebraic identities here are
  the invariants (characteristic polynomial, determinant/central character) that
  any such correspondence must preserve, and they hold before any topology is
  introduced.

---

## 10. Discussion and future directions

The results assembled here form a self-contained algebraic chain: the
characteristic polynomial of a two-dimensional representation, the determinant
homomorphism with its kernel $SL_2$ and the abelian correspondence it induces, the
central scalar embedding, and the twisting compatibility of determinants. Each
link is elementary; their organization is exactly the skeleton of the $p$-adic
Langlands correspondence for $GL_2(\mathbb{Q}_p)$.

The natural next steps move from algebra toward analysis:

1. **Topologize the objects.** Introduce the Banach / $p$-adic topology: unitary
   $\mathbb{Q}_p$-Banach representations of $GL_2(\mathbb{Q}_p)$ together with
   their unit balls, and continuous two-dimensional Galois representations.
2. **Construct the Montréal functor.** Realize Colmez's functor from
   $(\varphi,\Gamma)$-modules, matching two-dimensional Galois representations
   with $GL_2(\mathbb{Q}_p)$-representations, and verify that it carries the
   determinant character to the central character — the topological upgrade of
   Theorem 6.4.
3. **Irreducibility and unitarity.** Characterize the irreducible unitary Banach
   representations and prove the bijection with irreducible two-dimensional Galois
   representations.
4. **Compatibility with reduction mod $p$.** Relate the correspondence to its mod-$p$
   analogue and to the deformation theory of Galois representations.

Each of these builds directly on the algebraic bridge established here.

---

## Appendix: Summary of results

| Result | Statement |
|---|---|
| Cayley–Hamilton | $M^2 = (\operatorname{tr}M)M - (\det M)I$ |
| Adjugate / inverse | $M((\operatorname{tr}M)I - M) = (\det M)I$ |
| Determinant surjective | $\det : GL_2(K)\twoheadrightarrow K^{\times}$ |
| Kernel | $\ker\det = SL_2(K)$ |
| Abelian correspondence | $(K^{\times}\to A) \cong \{f:GL_2(K)\to A : SL_2\subseteq\ker f\}$ |
| Scalar determinant | $\det(uI) = u^2$ |
| Centrality | $uI$ commutes with all of $GL_2(K)$ |
| Twisting law | $\det(\chi\otimes\rho) = \chi^2\cdot\det\rho$ |
