# Contravariant Duality, Finite Fourier Inversion, and the Limits of Naturality

**Aristotle**  
**August 1, 2026**

## Abstract

We develop a self-contained finite-coordinate model for viewing Fourier analysis through category theory. For a commutative ring $K$, objects are the coordinate modules $K^n$ and morphisms $m\to n$ are $n\times m$ matrices. Matrix transposition defines a contravariant duality: it preserves identities and reverses composition. Double transposition is naturally the identity, so the matrix category is equivalent to its opposite. This reproduces the categorical shape of Pontryagin biduality, while the pullback of circle-valued characters supplies the corresponding composition law for topological abelian groups. We then examine the unnormalized discrete Fourier matrix and prove explicitly that the two-point transform over $\mathbb Q$ is invertible. Two counterexamples delimit the conclusions that can be drawn from this structure. First, the two-point Fourier matrix fails to commute with a coordinate projection, so Fourier matrices cannot form a natural endomorphism of the identity on a category containing all linear maps. Second, contravariance alone cannot imply a support uncertainty principle: the identity transform maps a delta vector to itself, giving support product $1<2$. Thus duality, Fourier inversion, naturality, and uncertainty are distinct layers. A correct categorical theory of Fourier analysis must restrict its morphisms or relate different function-space functors, and a categorical uncertainty theorem must include substantive orthogonality or nondegeneracy hypotheses.

## 1. Introduction

Fourier analysis converts a function or vector into data indexed by characters or frequencies. In finite dimensions this conversion is matrix multiplication; on locally compact abelian groups it is an integral against continuous circle-valued characters. Both descriptions suggest a common categorical theme. A homomorphism between groups pulls characters backward, while a linear map between finite free modules pulls linear functionals backward. The resulting assignment is contravariant.

It is tempting to compress several familiar facts into a single slogan: Fourier transformation is natural, Pontryagin duality is an equivalence, and uncertainty follows from the reversal of arrows. The purpose of this paper is to separate the valid structural core from claims that require additional hypotheses. A minimal finite-coordinate model is particularly effective because all equations can be inspected directly.

The positive results are these. Transposition defines a functor from the opposite of the finite matrix category to the category itself. Applying this duality twice gives the identity up to a natural isomorphism, hence an equivalence with the opposite category. Pullback of continuous circle-valued characters obeys the same reversed composition law. Finally, the two-point discrete Fourier transform is an isomorphism over the rational numbers.

The limitations are equally important. Naturality with respect to every linear map would force every endomorphism to commute with the Fourier matrix, which is false. Moreover, contravariance is a law of composition, whereas uncertainty is a statement about support or concentration. The identity transform is compatible with the ambient duality but preserves a one-point support, so no nontrivial uncertainty lower bound can follow from variance alone.

The model is deliberately algebraic. It captures the categorical shape of finite biduality and the arrow-level mechanism behind Pontryagin duality, but it does not claim the full topological biduality theorem for locally compact abelian groups. That theorem also requires continuity, local compactness, Hausdorff separation, and analytic structure. Keeping this distinction explicit is part of the contribution.

## 2. The finite coordinate matrix category

### 2.1 Objects, morphisms, and composition

Fix a commutative ring $K$. Define a category $\mathcal M_K$ as follows. Its objects are nonnegative integers. The object $n$ represents the finite free coordinate module $K^n$. For objects $m$ and $n$, set

$$
\operatorname{Hom}_{\mathcal M_K}(m,n)
=\operatorname{Mat}_{n\times m}(K).
$$

Thus an arrow $A:m\to n$ is an $n\times m$ matrix, acting on column vectors in $K^m$. If $A:l\to m$ and $B:m\to n$, define their categorical composite by

$$
B\circ A=BA.
$$

Its entries are

$$
(B\circ A)_{ij}=\sum_{k=0}^{m-1}B_{ik}A_{kj}.
$$

The identity arrow on $n$ is the $n\times n$ identity matrix $I_n$. Associativity follows from associativity of matrix multiplication, and $I_nA=A=AI_m$ gives the identity laws. This proves that $\mathcal M_K$ is a category.

The opposite category $\mathcal M_K^{\mathrm{op}}$ has the same objects but reverses every arrow. An arrow $m\to n$ in the opposite category corresponds to an arrow $n\to m$ in $\mathcal M_K$. This formal reversal is the correct source category for a contravariant construction.

### 2.2 Transpose duality

For a matrix $A\in\operatorname{Mat}_{n\times m}(K)$, its transpose $A^{\mathsf T}$ lies in $\operatorname{Mat}_{m\times n}(K)$. It therefore reverses the direction of the represented linear map. Define the duality assignment $D$ on objects by

$$
D(n)=n,
$$

and on an arrow represented by $A$ by

$$
D(A)=A^{\mathsf T}.
$$

Regarded covariantly, this is a functor $D:\mathcal M_K^{\mathrm{op}}\to\mathcal M_K$.

**Theorem 2.1 (Contravariant transpose functor).** The assignment $D$ is a functor. Equivalently, transpose preserves identity arrows and reverses composites:

$$
D(I_n)=I_n,
\qquad
D(B\circ A)=D(A)\circ D(B).
$$

**Proof sketch.** The identity equation is $I_n^{\mathsf T}=I_n$. For composition,

$$
(BA)^{\mathsf T}=A^{\mathsf T}B^{\mathsf T}.
$$

Entrywise, the left side at $(i,j)$ is $\sum_k B_{jk}A_{ki}$, while the right side is $\sum_k A_{ki}B_{jk}$. These sums agree because multiplication in $K$ is commutative. The source category is opposite, so this reversed order is precisely the ordinary functorial composition law. $\square$

The use of a commutative ring matches the intended character-dual interpretation and makes the entrywise comparison immediate. More generally, transpose over a noncommutative ring naturally interacts with the opposite ring.

**Corollary 2.2 (Explicit contravariance equation).** If $A:l\to m$ and $B:m\to n$, then

$$
(BA)^{\mathsf T}=A^{\mathsf T}B^{\mathsf T}.
$$

**Proof sketch.** This is the composition equation established in Theorem 2.1, restated without opposite-category notation. $\square$

This is the finite-coordinate version of the rule that a functional pulled back through a composite is pulled back through the second map first and the first map second.

## 3. Biduality as an equivalence

There is also a transpose functor in the reverse direction, from $\mathcal M_K$ to $\mathcal M_K^{\mathrm{op}}$. Denote it by $D^{\mathrm{op}}$. It fixes object labels and sends $A$ to $A^{\mathsf T}$, now regarded as an arrow in the opposite category.

A natural transformation between two functors assigns a morphism to each object in a way compatible with every arrow. A natural isomorphism is a natural transformation whose components are isomorphisms.

**Theorem 3.1 (Finite bidual equivalence).** The composites

$$
D^{\mathrm{op}}\circ D:\mathcal M_K^{\mathrm{op}}
\longrightarrow\mathcal M_K^{\mathrm{op}}
$$

and

$$
D\circ D^{\mathrm{op}}:\mathcal M_K
\longrightarrow\mathcal M_K
$$

are naturally isomorphic to the corresponding identity functors. Consequently,

$$
\mathcal M_K^{\mathrm{op}}\simeq\mathcal M_K.
$$

**Proof sketch.** On each object, double dualization returns the same nonnegative integer. On each arrow,

$$
(A^{\mathsf T})^{\mathsf T}=A.
$$

Choose the component of each natural isomorphism at object $n$ to be $I_n$. Naturality asks that the squares formed by these identities and any arrow $A$ commute. Both paths reduce to $A$, by double transposition and the identity laws. Thus the two transpose functors are quasi-inverses and define an equivalence. $\square$

This theorem is a finite-coordinate analogue of Pontryagin biduality. It states the same categorical pattern: an object can be recovered from its double dual, compatibly with morphisms. It does not, by itself, establish that every locally compact abelian group is topologically isomorphic to its double character group. The analytic theorem has a richer class of objects and must prove that the evaluation map is a homeomorphism as well as a group isomorphism.

## 4. Circle-valued characters and reversed composition

Let $\mathbb T$ denote the circle group. For a topological abelian group $A$, define its character group by

$$
\widehat A=\operatorname{Hom}_{\mathrm{cts}}(A,\mathbb T),
$$

with pointwise multiplication. If $f:A\to B$ is a continuous homomorphism, define the pullback map

$$
\widehat f:\widehat B\to\widehat A,
\qquad
\widehat f(\chi)=\chi\circ f.
$$

**Theorem 4.1 (Contravariance of character pullback).** For continuous homomorphisms $f:A\to B$ and $g:B\to C$,

$$
\widehat{g\circ f}=\widehat f\circ\widehat g.
$$

**Proof sketch.** Take $\chi\in\widehat C$. Then

$$
\widehat{g\circ f}(\chi)
=\chi\circ(g\circ f)
=(\chi\circ g)\circ f
=\widehat f(\widehat g(\chi)).
$$

The equality follows from associativity of function composition. Continuity and the homomorphism property are preserved under composition. $\square$

This theorem is the arrow-level foundation for a Pontryagin-dual functor. To obtain the full duality equivalence on locally compact abelian groups, one must add the appropriate topology to $\widehat A$ and prove that the evaluation map

$$
\eta_A:A\to\widehat{\widehat A},
\qquad
\eta_A(a)(\chi)=\chi(a),
$$

is a topological group isomorphism. The finite transpose model predicts the direction and shape of this result, while leaving those analytic obligations visible.

## 5. Fourier matrices and the two-point transform

### 5.1 Definition

For $n\ge0$ and an element $\omega\in K$, define the unnormalized Fourier matrix $F_n(\omega)$ by

$$
F_n(\omega)_{ji}=\omega^{ij},
\qquad 0\le i,j<n.
$$

When $K$ contains a primitive $n$th root of unity, this is the familiar discrete Fourier matrix, up to choices of sign and normalization. The present definition is algebraic and does not assume in advance that the matrix is invertible.

For $n=2$ over $\mathbb Q$, choose $\omega=-1$. Since the exponents are $0$ or $1$ modulo the displayed products, one obtains

$$
F=F_2(-1)
=\begin{pmatrix}
1&1\\
1&-1
\end{pmatrix}.
$$

Define

$$
G=\frac12F
=\begin{pmatrix}
\tfrac12&\tfrac12\\
\tfrac12&-\tfrac12
\end{pmatrix}.
$$

**Theorem 5.1 (Two-point Fourier inversion).** The matrix $F$ is invertible over $\mathbb Q$, and its inverse is $G=\frac12F$. In particular,

$$
FG=GF=I_2.
$$

**Proof sketch.** Direct multiplication gives

$$
F^2=
\begin{pmatrix}1&1\\1&-1\end{pmatrix}
\begin{pmatrix}1&1\\1&-1\end{pmatrix}
=\begin{pmatrix}2&0\\0&2\end{pmatrix}
=2I_2.
$$

Multiplying by $\frac12$ on either side yields $F(\frac12F)=I_2=(\frac12F)F$. $\square$

For input $x=(x_0,x_1)^{\mathsf T}$,

$$
Fx=(x_0+x_1,x_0-x_1)^{\mathsf T}.
$$

The first coordinate captures the constant component, and the second captures alternating contrast. The inverse averages their sum and difference. Thus even the smallest transform displays frequency separation and exact reconstruction.

### 5.2 An inversion algorithm

The theorem yields a constant-size algorithm for the two-point case.

**Algorithm 5.2 (Two-point Fourier transform and reconstruction).** Given scalars $x_0,x_1$, compute

$$
y_0=x_0+x_1,
\qquad
y_1=x_0-x_1.
$$

To reconstruct, compute

$$
x_0=\frac{y_0+y_1}{2},
\qquad
x_1=\frac{y_0-y_1}{2}.
$$

Each direction uses two additions or subtractions; reconstruction also uses two divisions by $2$. Storage is $O(1)$ and arithmetic cost is $O(1)$. Iterated versions of this sum-and-difference pattern underlie fast transforms on binary product groups.

## 6. Why unrestricted Fourier naturality fails

A natural endomorphism $\tau$ of the identity functor on $\mathcal M_K$ would assign to every object $n$ an endomorphism $\tau_n:n\to n$ such that for every arrow $A:m\to n$,

$$
A\tau_m=\tau_nA.
$$

If $\tau_n$ were the Fourier matrix $F_n$, then in particular every square endomorphism at a fixed dimension would commute with $F_n$. This condition is much stronger than invertibility.

In dimension two, consider the projection onto the first coordinate,

$$
P=\begin{pmatrix}1&0\\0&0\end{pmatrix}.
$$

**Theorem 6.1 (Failure of unrestricted Fourier naturality).** The two-point Fourier matrix does not commute with every rational endomorphism. Specifically,

$$
PF\ne FP.
$$

Consequently, Fourier matrices cannot define a natural endomorphism of the identity functor on a matrix category whose morphisms include all linear maps.

**Proof sketch.** Multiplication gives

$$
PF=\begin{pmatrix}1&1\\0&0\end{pmatrix},
\qquad
FP=\begin{pmatrix}1&0\\1&0\end{pmatrix}.
$$

Their $(1,2)$ entries, using one-based display indices, are respectively $1$ and $0$. Hence they are unequal. $\square$

The counterexample identifies a typing error in the broadest naturality claim. Projection in the original coordinate basis is not the same operation as projection after a Fourier change of basis. A correct naturality theorem must therefore alter at least one of the following:

1. restrict morphisms to maps compatible with the relevant group and measure structure;
2. place Fourier transformation between two different function-space functors rather than treating it as an endomorphism of one identity functor;
3. track pushforward on one side and pullback on the other;
4. include normalization factors associated with finite cardinality or Haar measure.

For finite abelian groups, group isomorphisms are a promising naturality class because they induce bijections of elements and contravariant bijections of characters. In analytic settings, Haar measure controls how integration transforms. The counterexample does not oppose functorial Fourier analysis; it specifies why the functors and morphisms must be chosen carefully.

## 7. Why contravariance alone does not imply uncertainty

For a vector $v\in\mathbb Q^n$, define its support and support size by

$$
\operatorname{supp}(v)=\{i\in\{0,\dots,n-1\}:v_i\ne0\},
$$

and

$$
s(v)=|\operatorname{supp}(v)|.
$$

A typical finite support uncertainty principle for a suitable Fourier transform $T$ has the form

$$
s(v)s(Tv)\ge n
$$

for every nonzero $v$. Such inequalities express that simultaneous localization in the original and frequency coordinates is impossible.

Contravariance, however, only controls the order in which dual maps compose. It imposes no condition on the entries or minors of an arbitrary transform $T$.

Let $n=2$, let $T=I_2$, and let

$$
\delta_0=\begin{pmatrix}1\\0\end{pmatrix}.
$$

Then $s(\delta_0)=1$ and $T\delta_0=\delta_0$, so $s(T\delta_0)=1$.

**Theorem 7.1 (Contravariance is insufficient for support uncertainty).** The existence of contravariant transpose duality does not imply the lower bound $s(v)s(Tv)\ge2$ for an arbitrary transform $T$. For the identity transform and the delta vector,

$$
s(\delta_0)s(I_2\delta_0)=1<2.
$$

**Proof sketch.** Exactly one coordinate of $\delta_0$ is nonzero. The identity does not change the vector. Therefore both support sizes equal $1$, and their product is $1$. $\square$

The identity transform is invertible as well, so bare invertibility would not repair the claim. Fourier uncertainty depends on additional structure. Depending on the desired theorem, useful hypotheses include orthogonality of character rows, a nondegenerate bicharacter, Plancherel identities, or nonvanishing conditions on minors of the transform matrix. These properties force a sparse input to spread; contravariance does not.

## 8. Computational demonstrations

The finite model leads to three elementary numerical tests.

First, inversion is checked by multiplying $F$ by $G$. Both products must equal $I_2$. Second, failed naturality is exposed by multiplying $P$ and $F$ in both orders and comparing the results. Third, the support counterexample is computed by counting nonzero coordinates of $\delta_0$ before and after applying $I_2$.

These tests use exact rational arithmetic, avoiding floating-point tolerance. For larger matrices, naive multiplication of two $n\times n$ matrices costs $O(n^3)$ arithmetic operations and $O(n^2)$ storage. Transposition costs $O(n^2)$ time if materialized, though a view can make it $O(1)$ auxiliary space. Support counting costs $O(n)$. The two-point transform itself is constant time; recursively factored Fourier algorithms reduce the general transform from naive $O(n^2)$ matrix-vector multiplication to $O(n\log n)$ in compatible dimensions.

The counterexamples are algorithmically valuable regression tests. Any proposed categorical interface that asserts unrestricted commutation should reject the pair $(P,F)$. Any proposed uncertainty theorem whose hypotheses accept the identity transform should be tested against $\delta_0$. Small counterexamples often reveal missing assumptions more effectively than large numerical experiments.

## 9. Applications and conceptual consequences

In signal processing, a pipeline may include filtering, projection, resampling, and a Fourier transform. Theorem 6.1 warns that these operations cannot generally be reordered. A projection in time coordinates becomes a different operator in frequency coordinates, namely its conjugate by the Fourier isomorphism. Correct diagrammatic reasoning must represent that change rather than assuming commutation.

In harmonic analysis, character pullback explains why a group homomorphism induces a map of dual groups in the reverse direction. This variance guides the formulation of Fourier naturality: functions and measures may move covariantly by pushforward or contravariantly by pullback, while characters move contravariantly. A valid theorem must align these directions.

In quantum mechanics, invertible or unitary changes of basis connect position-like and momentum-like descriptions. Yet uncertainty is not a consequence of having two equivalent descriptions. It depends on incompatibility between the bases, quantitatively expressed through inner products, orthogonality, or entropic bounds. Theorem 7.1 isolates the same distinction in the smallest exact example.

In computation, transpose duality resembles reverse data flow: a forward linear map induces a backward action on linear observables. The equation $(BA)^{\mathsf T}=A^{\mathsf T}B^{\mathsf T}$ is also the algebraic pattern behind reverse-mode propagation through a chain of linear maps. Fourier structure adds a special, efficiently computable change of coordinates, but it remains separate from the universal reversal law.

## 10. Discussion

The finite-coordinate model supports four sharply distinguished conclusions.

First, dualization is functorial only after variance is handled correctly. The appropriate functor starts from an opposite category. Second, biduality is an equivalence because double transpose returns every matrix, and the return is natural across all arrows. Third, a Fourier matrix may be an isomorphism, as shown by the explicit two-point inverse. Fourth, neither unrestricted naturality nor uncertainty follows from the first three facts.

This hierarchy prevents category theory from becoming a slogan. A categorical account should improve theorem statements by exposing domains, codomains, and variance. If it instead suppresses the distinction between pullback and pushforward, or between arbitrary linear maps and structure-preserving maps, it obscures the mathematics.

The negative results are therefore constructive. The failed commutation square says that the identity functor is the wrong target for an unrestricted natural transformation. The support counterexample says that contravariance is too weak a hypothesis for uncertainty. Together they point toward better formulations: Fourier transformation between appropriately chosen functors, and uncertainty derived from explicit harmonic hypotheses.

## 11. Future work

The first extension is to define the category of locally compact Hausdorff abelian groups with continuous homomorphisms and to promote character pullback to a functor from its opposite. The arrow law is already given by Theorem 4.1; the remaining work concerns bundled topology and continuity.

The second is full Pontryagin biduality. One must construct the evaluation homomorphism $\eta_A(a)(\chi)=\chi(a)$ and prove that it is a natural topological group isomorphism for every locally compact abelian group $A$.

The third is to locate the correct naturality domain for Fourier transformation. Finite abelian groups with group isomorphisms provide a controlled starting point. A broader kernel formalism could separately track pullback, pushforward, and measure normalization.

The fourth is a substantive categorical uncertainty theorem. In finite groups, one may begin with an invertible character table and add orthogonality or nonvanishing-minor assumptions. The identity-transform counterexample should remain as a boundary test ensuring that variance alone never silently replaces these hypotheses.

Further analytic work may incorporate Haar integration, Plancherel theory, convolution, and the exchange between convolution and pointwise multiplication. These structures promise a richer functorial account while preserving the distinctions established here.

## 12. Conclusion

Finite coordinate modules provide a transparent bridge between category theory and Fourier analysis. Transposition is a contravariant functor, double transposition yields an equivalence with the opposite category, and circle-valued character pullback follows the same reversed composition law. The two-point Fourier matrix is explicitly invertible over $\mathbb Q$.

Just as importantly, the model marks the limits of these facts. The Fourier matrix does not commute with every linear map, and contravariance alone does not force uncertainty. The appropriate synthesis is therefore layered: duality supplies variance, Fourier matrices supply special isomorphisms, carefully selected morphisms supply naturality, and orthogonality or nondegeneracy supplies uncertainty. This layered formulation offers a precise foundation for future categorical and computational treatments of harmonic analysis.
