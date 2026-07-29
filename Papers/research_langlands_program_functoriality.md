# Unramified Symmetric-Square Functoriality: Parameters, Euler Factors, and Tensor Decomposition

## Abstract

We give a self-contained algebraic account of the unramified local symmetric-square transfer from rank two to rank three. Over an arbitrary commutative ring $R$, unramified data of rank $n$ are represented by a finite family of Satake parameters. To such a family we attach its central character value, the product of its parameters, and its standard Euler denominator, the polynomial obtained by multiplying the factors $1-\alpha X$. For a rank-two datum with parameters $(a,b)$, the symmetric-square transfer has parameters $(a^2,ab,b^2)$. We prove that this construction is natural under scalar extension, that its central character is the cube of the original central character, and that its standard Euler denominator is $(1-a^2X)(1-abX)(1-b^2X)$. We also prove the local Rankin–Selberg factorization: the Euler denominator of the tensor square, whose parameters are $(a^2,ab,ab,b^2)$, is the product of the symmetric-square denominator and the determinant denominator $1-abX$. Finally, we identify the lifted trace as $a^2+ab+b^2$ and establish its cubic telescoping identity. The arguments use only finite products and polynomial algebra, so all statements remain valid over commutative rings, without division or analytic hypotheses.

## 1. Introduction

Langlands functoriality predicts that a homomorphism between suitable dual groups should transport automorphic information while preserving local and global $L$-functions in a prescribed manner. One of its basic examples is the symmetric-square transfer from rank two to rank three. At an unramified place, the essential algebra is finite and explicit: if the rank-two Satake parameters are $a$ and $b$, then applying the symmetric-square representation produces the three parameters $a^2$, $ab$, and $b^2$.

This local transformation carries more structure than the parameter list alone suggests. Its product controls the central character. Its elementary symmetric functions determine the standard local Euler polynomial. Its relationship with the full tensor square expresses the decomposition of a two-dimensional tensor square into symmetric and alternating parts. Moreover, all of these constructions are natural under a change of coefficient ring.

Our purpose is to isolate and prove this complete algebraic package. We deliberately work over an arbitrary commutative ring $R$. This level of generality makes clear that the identities are polynomial identities rather than consequences of analytic convergence, semisimplicity, or division. It also permits specialization to fields, residue rings, and extensions of coefficient systems through one uniform statement.

The main results are as follows. For a rank-two datum $\pi=(a,b)$, define

$$
\operatorname{Sym}^2(\pi)=(a^2,ab,b^2),
\qquad
\det(\pi)=(ab),
$$

and

$$
\pi\otimes\pi=(a^2,ab,ab,b^2).
$$

Then the central characters satisfy

$$
\omega_{\operatorname{Sym}^2(\pi)}=\omega_\pi^3.
$$

The standard Euler denominators satisfy

$$
D_{\operatorname{Sym}^2(\pi)}(X)
=(1-a^2X)(1-abX)(1-b^2X)
$$

and

$$
D_{\pi\otimes\pi}(X)
=D_{\operatorname{Sym}^2(\pi)}(X)D_{\det(\pi)}(X).
$$

The lifted Hecke trace is

$$
\operatorname{tr}(\operatorname{Sym}^2(\pi))=a^2+ab+b^2,
$$

with

$$
(a-b)\operatorname{tr}(\operatorname{Sym}^2(\pi))=a^3-b^3.
$$

Finally, every construction commutes with a homomorphism of commutative rings.

The scope is local and unramified. These results specify the algebraic identities that a global symmetric-square transfer must satisfy at each unramified place; they do not assert the global existence of automorphic lifts or analytic properties of global $L$-functions.

## 2. Unramified parameter data

### 2.1. Parameter families

Let $R$ be a commutative ring with identity, and let $n$ be a nonnegative integer.

**Definition 2.1 (Unramified datum).** An unramified datum of rank $n$ over $R$ is an ordered family

$$
\pi=(\alpha_1,\ldots,\alpha_n),
\qquad \alpha_i\in R.
$$

The ordering is convenient for specifying constructions, although the principal invariants considered below are symmetric and therefore depend only on the associated multiset.

**Definition 2.2 (Scalar extension).** If $f:R\to S$ is a homomorphism of commutative rings and $\pi=(\alpha_1,\ldots,\alpha_n)$, define

$$
f_*(\pi)=(f(\alpha_1),\ldots,f(\alpha_n)).
$$

This operation includes embeddings into larger fields, reduction modulo an ideal when expressed by the quotient map, and any other coefficient change preserving sums, products, and the identity.

### 2.2. Central characters and Euler denominators

**Definition 2.3 (Central character value).** The central character value of $\pi=(\alpha_1,\ldots,\alpha_n)$ is

$$
\omega_\pi=\prod_{i=1}^{n}\alpha_i.
$$

For the empty family, the product is $1$. For a rank-two datum $(a,b)$, it is $ab$.

**Definition 2.4 (Standard Euler denominator).** The standard Euler denominator attached to $\pi$ is

$$
D_\pi(X)=\prod_{i=1}^{n}(1-\alpha_iX)\in R[X].
$$

When working over a field or in a ring of formal power series where the reciprocal is considered, the standard unramified local $L$-factor is

$$
L(X,\pi)=D_\pi(X)^{-1}.
$$

The denominator is the primary object here because it is polynomial and is defined over every commutative ring. No claim about analytic convergence is involved.

For rank two, direct evaluation gives the first explicit formula.

**Proposition 2.5 (Rank-two Euler denominator).** If $\pi=(a,b)$, then

$$
D_\pi(X)=(1-aX)(1-bX).
$$

**Proof sketch.** Apply Definition 2.4 to the two-element family. The finite product has exactly the displayed two factors. $\square$

Expanding gives

$$
D_\pi(X)=1-(a+b)X+abX^2.
$$

Thus the trace $a+b$ and central character $ab$ occur as its nonconstant coefficients, with the usual alternating signs.

### 2.3. Naturality of Euler denominators

A ring homomorphism $f:R\to S$ induces a coefficientwise homomorphism $R[X]\to S[X]$, also denoted by $f$ when no confusion can arise.

**Theorem 2.6 (Scalar-extension compatibility of Euler denominators).** For every unramified datum $\pi$ over $R$ and every ring homomorphism $f:R\to S$,

$$
f(D_\pi(X))=D_{f_*(\pi)}(X).
$$

**Proof sketch.** Since $f$ preserves $0$, $1$, subtraction, and multiplication, it sends each factor $1-\alpha_iX$ to $1-f(\alpha_i)X$. It also preserves finite products. Therefore

$$
f\!\left(\prod_i(1-\alpha_iX)\right)
=\prod_i(1-f(\alpha_i)X),
$$

which is the required denominator. $\square$

This theorem is the basic mechanism allowing identities proved universally over $R$ to be specialized through any coefficient map.

## 3. The symmetric-square construction

### 3.1. Representation-theoretic origin

Let a diagonal operator on a two-dimensional module have eigenparameters $a$ and $b$. On the symmetric square, the quadratic monomials $u^2$, $uv$, and $v^2$ are scaled by $a^2$, $ab$, and $b^2$, respectively. This motivates the following purely algebraic definition.

**Definition 3.1 (Symmetric-square transfer).** For a rank-two datum $\pi=(a,b)$ over $R$, define the rank-three datum

$$
\operatorname{Sym}^2(\pi)=(a^2,ab,b^2).
$$

**Definition 3.2 (Determinant character).** For the same datum, define the rank-one determinant datum

$$
\det(\pi)=(ab).
$$

**Definition 3.3 (Tensor square).** Define the rank-four tensor-square datum by

$$
\pi\otimes\pi=(a^2,ab,ab,b^2).
$$

The repeated mixed term records multiplicity. The ordered tensor basis $u\otimes u$, $u\otimes v$, $v\otimes u$, $v\otimes v$ receives the displayed eigenparameters.

### 3.2. Naturality of the transfer

**Theorem 3.4 (Scalar-extension compatibility of the symmetric square).** Let $f:R\to S$ be a homomorphism of commutative rings. For every rank-two datum $\pi$ over $R$,

$$
f_*(\operatorname{Sym}^2(\pi))
=\operatorname{Sym}^2(f_*(\pi)).
$$

**Proof sketch.** Write $\pi=(a,b)$. The left side is

$$
(f(a^2),f(ab),f(b^2)),
$$

while the right side is

$$
(f(a)^2,f(a)f(b),f(b)^2).
$$

These triples agree because a ring homomorphism preserves squares and products. $\square$

Combining Theorems 2.6 and 3.4 immediately shows that the Euler denominator of the symmetric-square datum also commutes with coefficient change. Naturality here is strict: no auxiliary choice or comparison is required.

## 4. Central character and standard Euler factor

### 4.1. Central-character law

**Theorem 4.1 (Central character of the symmetric square).** For every rank-two datum $\pi$ over a commutative ring,

$$
\omega_{\operatorname{Sym}^2(\pi)}=\omega_\pi^3.
$$

**Proof sketch.** If $\pi=(a,b)$, then $\omega_\pi=ab$. Multiplying the three transferred parameters gives

$$
\omega_{\operatorname{Sym}^2(\pi)}
=(a^2)(ab)(b^2)
=a^3b^3
=(ab)^3
=\omega_\pi^3.
$$

Only associativity and commutativity are used. $\square$

The theorem supplies a necessary compatibility condition for any proposed symmetric-square transfer. It is also consistent with scalar weights: if $a=b=t$, then the original central character is $t^2$, while each of the three lifted parameters equals $t^2$, so the lifted product is $t^6=(t^2)^3$.

### 4.2. Explicit rank-three Euler denominator

**Theorem 4.2 (Standard Euler denominator of the symmetric-square transfer).** For $\pi=(a,b)$,

$$
D_{\operatorname{Sym}^2(\pi)}(X)
=(1-a^2X)(1-abX)(1-b^2X).
$$

**Proof sketch.** Insert the parameter family $(a^2,ab,b^2)$ into Definition 2.4. $\square$

An expanded form can also be useful. Multiplication yields

$$
\begin{aligned}
D_{\operatorname{Sym}^2(\pi)}(X)
={}&1-(a^2+ab+b^2)X\\
&+ab(a^2+ab+b^2)X^2-a^3b^3X^3.
\end{aligned}
$$

The coefficient pattern reflects the three elementary symmetric functions of $a^2$, $ab$, and $b^2$. In particular, the coefficient of $X^3$ recovers Theorem 4.1, while the coefficient of $X$ gives the lifted trace considered in Section 6.

If local $L$-factors are denoted by reciprocals, Theorem 4.2 reads

$$
L(X,\operatorname{Sym}^2\pi)
=\frac{1}{(1-a^2X)(1-abX)(1-b^2X)}.
$$

This equality is formal; analytic interpretations require a context in which $X$ is specialized appropriately.

## 5. Tensor-square factorization

The tensor square of a two-dimensional representation decomposes as the direct sum of its symmetric square and exterior square. In dimension two, the exterior square is one-dimensional and is the determinant representation. The parameter calculation realizes this decomposition exactly.

**Theorem 5.1 (Local Rankin–Selberg Euler-factor decomposition).** For every rank-two datum $\pi$ over a commutative ring,

$$
D_{\pi\otimes\pi}(X)
=D_{\operatorname{Sym}^2(\pi)}(X)D_{\det(\pi)}(X).
$$

More explicitly, if $\pi=(a,b)$, then

$$
(1-a^2X)(1-abX)^2(1-b^2X)
=
\bigl((1-a^2X)(1-abX)(1-b^2X)\bigr)(1-abX).
$$

**Proof sketch.** The tensor-square parameter multiset is

$$
\{a^2,ab,ab,b^2\}.
$$

It is the multiset union of the symmetric-square family

$$
\{a^2,ab,b^2\}
$$

and the determinant family $\{ab\}$. Euler denominators multiply under multiset union because their defining linear factors concatenate. Equivalently, both sides of the displayed polynomial identity are the same four factors, merely grouped differently. $\square$

Whenever reciprocal factors are meaningful, taking inverses gives the familiar local identity

$$
L(X,\pi\otimes\pi)
=L(X,\operatorname{Sym}^2\pi)L(X,\det\pi).
$$

The theorem is valid even when polynomial factors are not cancellable. This is one reason to formulate the result directly as equality of denominators over a commutative ring.

### 5.1. Structural interpretation

Let $V$ be a free rank-two module with basis $u,v$. Under appropriate hypotheses permitting the usual splitting, one has

$$
V\otimes V\cong\operatorname{Sym}^2V\oplus\bigwedge^2V.
$$

The three symmetric directions correspond to $u\otimes u$, a symmetric mixed direction, and $v\otimes v$. The alternating direction corresponds to the antisymmetric mixed tensor. Both mixed directions carry the same eigenparameter $ab$, explaining its multiplicity two in the tensor square and its appearance once in each factor on the right side.

The parameter and polynomial identity itself requires no division by $2$, so it remains valid in characteristic $2$, where an internal direct-sum description of symmetric and alternating tensors may require additional care. The multiset calculation is therefore algebraically more robust than a proof depending on projection operators with coefficients $1/2$.

## 6. Trace identities

**Definition 6.1 (Hecke trace).** The trace of a finite parameter family $(\alpha_1,\ldots,\alpha_n)$ is

$$
\operatorname{tr}(\pi)=\sum_{i=1}^{n}\alpha_i.
$$

It is the negative of the coefficient of $X$ in $D_\pi(X)$.

**Theorem 6.2 (Trace of the symmetric-square transfer).** For $\pi=(a,b)$,

$$
\operatorname{tr}(\operatorname{Sym}^2(\pi))=a^2+ab+b^2.
$$

**Proof sketch.** Sum the three parameters $a^2$, $ab$, and $b^2$. $\square$

**Theorem 6.3 (Cubic telescoping identity).** For every $a,b$ in a commutative ring,

$$
(a-b)\operatorname{tr}(\operatorname{Sym}^2(a,b))=a^3-b^3.
$$

**Proof sketch.** Substitute Theorem 6.2 and distribute:

$$
\begin{aligned}
(a-b)(a^2+ab+b^2)
&=a^3+a^2b+ab^2-a^2b-ab^2-b^3\\
&=a^3-b^3.
\end{aligned}
$$

The mixed terms cancel. $\square$

Over a field with $a\ne b$, this gives the divided-difference expression

$$
\operatorname{tr}(\operatorname{Sym}^2(a,b))
=\frac{a^3-b^3}{a-b}.
$$

The polynomial form in Theorem 6.3 is stronger algebraically because it makes no invertibility assumption on $a-b$.

## 7. Algorithms and computational realization

### 7.1. Euler-denominator construction

Given parameters $\alpha_1,\ldots,\alpha_n$, the denominator may be computed iteratively. Represent a polynomial by a coefficient array in increasing degree. Initialize $c=[1]$. For each $\alpha_i$, replace $c$ by its convolution with $[1,-\alpha_i]$. After $n$ steps, $c$ contains the coefficients of $D_\pi(X)$.

At the $k$th step the current polynomial has degree $k-1$, and multiplying by a linear factor costs $O(k)$ ring operations. Hence the complete procedure uses $O(n^2)$ ring operations and $O(n)$ storage. For the ranks considered here, the computation is constant-size, but the generic algorithm is useful for higher symmetric powers.

### 7.2. Symmetric-square verification pipeline

For input $(a,b)$, compute:

1. the lifted parameters $(a^2,ab,b^2)$;
2. the determinant parameter $(ab)$;
3. the tensor parameters $(a^2,ab,ab,b^2)$;
4. the three Euler denominators using the iterative algorithm;
5. the product of the lifted and determinant denominators;
6. a coefficientwise comparison with the tensor denominator;
7. the products of the original and lifted parameters;
8. the two sides of the trace telescoping identity.

All quantities can be computed exactly over the integers or rational numbers. The factorization check compares polynomial coefficients rather than floating-point evaluations, avoiding numerical ambiguity.

### 7.3. Worked example

Let $a=2$ and $b=3$. Then

$$
\operatorname{Sym}^2(2,3)=(4,6,9),
\qquad
\det(2,3)=(6),
$$

and

$$
(2,3)\otimes(2,3)=(4,6,6,9).
$$

The central-character identity is

$$
4\cdot6\cdot9=216=(2\cdot3)^3.
$$

The trace and telescope are

$$
4+6+9=19,
$$

and

$$
(2-3)19=-19=2^3-3^3.
$$

The denominators are

$$
D_{\operatorname{Sym}^2}(X)
=(1-4X)(1-6X)(1-9X),
$$

$$
D_{\det}(X)=1-6X,
$$

and

$$
D_{\otimes^2}(X)
=(1-4X)(1-6X)^2(1-9X).
$$

The last polynomial is visibly the product of the preceding two.

## 8. Applications and consequences

### 8.1. Local consistency tests

The formulas provide quick necessary tests for a proposed rank-three symmetric-square lift. Given rank-two parameters $(a,b)$ and a candidate triple $(c_1,c_2,c_3)$, the expected multiset is $\{a^2,ab,b^2\}$. Even before full comparison, one may test

$$
c_1c_2c_3=(ab)^3
$$

and

$$
c_1+c_2+c_3=a^2+ab+b^2.
$$

One may then compare the complete Euler denominator with the cubic polynomial in Theorem 4.2. Equality of the denominator captures all elementary symmetric functions of the triple.

### 8.2. Reduction and specialization

Because the constructions commute with scalar extension, an identity over integers may be reduced modulo any integer $m$, and an identity over a base field may be transported into an extension field. For example, reducing $(a,b)$ modulo a prime and then lifting gives the same triple as lifting first and reducing each entry. The same statement holds coefficientwise for every Euler denominator and factorization.

This compatibility is useful in experimental arithmetic. Computations can be performed in finite coefficient rings while retaining a transparent relationship with universal polynomial formulas.

### 8.3. Finite collections of places

Suppose a finite set of places is equipped with pairs $(a_v,b_v)$. Applying Theorem 5.1 independently at each place and multiplying the resulting equalities suggests the finite product identity

$$
\prod_v D_{\pi_v\otimes\pi_v}(X)
=
\left(\prod_vD_{\operatorname{Sym}^2(\pi_v)}(X)\right)
\left(\prod_vD_{\det(\pi_v)}(X)\right).
$$

This follows directly from the local theorem and associativity and commutativity of polynomial multiplication. It is the finite algebraic precursor of an Euler-product decomposition.

## 9. Further algebraic consequences and boundary cases

### 9.1. Multiplicativity under concatenation

The factorization theorem is an instance of a general property of Euler denominators.

**Lemma 9.1 (Concatenation principle).** Let $A=(\alpha_1,\ldots,\alpha_r)$ and $B=(\beta_1,\ldots,\beta_s)$ be parameter families over the same commutative ring, and let $A\sqcup B$ denote their concatenation, with multiplicities retained. Then

$$
D_{A\sqcup B}(X)=D_A(X)D_B(X).
$$

**Proof sketch.** By definition, the denominator on the left is the product of the $r+s$ linear factors contributed first by $A$ and then by $B$. Associativity of polynomial multiplication allows the first $r$ and final $s$ factors to be grouped separately, giving the product on the right. $\square$

Theorem 5.1 follows immediately by observing that the tensor-square family is the concatenation of the symmetric-square family and the one-entry determinant family. The lemma also explains why the same reasoning extends to finite products over places and to any representation-theoretic direct-sum rule that can be expressed as a multiset identity among parameters.

### 9.2. Degenerate parameters

No nonvanishing hypothesis is needed. If $a=0$, the original datum is $(0,b)$ and the lift is

$$
(0,0,b^2).
$$

The lifted denominator becomes $1-b^2X$, because factors associated with zero parameters equal $1$. The original and lifted central characters are both $0$, in agreement with the cubic law. The tensor-square factorization remains valid, with all zero-parameter factors harmless.

If $a=b$, the lift is $(a^2,a^2,a^2)$, so

$$
D_{\operatorname{Sym}^2}(X)=(1-a^2X)^3.
$$

The telescoping identity reduces to $0=0$. Although the divided-difference quotient is then unavailable, the polynomial trace formula remains meaningful and gives $3a^2$. This illustrates why the division-free formulation is fundamental.

If $a=-b$, the lifted family is $(a^2,-a^2,a^2)$. Its trace is $a^2$, and its denominator is

$$
(1-a^2X)^2(1+a^2X).
$$

The cubic identity becomes $(2a)a^2=2a^3$ whenever this notation is interpreted in the ring. It remains correct in every characteristic, including characteristic $2$, where both sides vanish and $a=-a$.

### 9.3. Symmetry under interchange

**Lemma 9.2 (Exchange invariance).** Interchanging $a$ and $b$ leaves the central character, trace, and Euler denominator of the symmetric-square transfer unchanged.

**Proof sketch.** The interchange sends $(a^2,ab,b^2)$ to $(b^2,ba,a^2)$. Commutativity gives $ba=ab$, so the new family is a permutation of the old one. Products, sums, and Euler denominators are invariant under permutation. $\square$

This invariance confirms that the construction depends on the unordered Satake multiset rather than on a chosen labeling of its two members. The ordered-family notation is thus bookkeeping, not additional arithmetic structure.

### 9.4. Recovering invariants from coefficients

Write

$$
D_{\operatorname{Sym}^2}(X)=1-c_1X+c_2X^2-c_3X^3.
$$

The explicit expansion in Section 4 gives

$$
c_1=a^2+ab+b^2,
\qquad
c_2=ab(a^2+ab+b^2),
\qquad
c_3=(ab)^3.
$$

Consequently,

$$
c_2=(ab)c_1.
$$

This coefficient relation is another necessary condition for a cubic polynomial to arise from the symmetric square of a specified pair $(a,b)$. Together, the three coefficients display a rigid pattern: the trace gives $c_1$, multiplication by the original central character gives $c_2$, and cubing that character gives $c_3$.

**Corollary 9.3 (Coefficient consistency).** For the symmetric-square denominator of $(a,b)$, the quadratic coefficient equals the original central character times the lifted trace, and the cubic coefficient in alternating-sign notation equals the cube of the original central character.

**Proof sketch.** These are the second and third elementary symmetric functions of $(a^2,ab,b^2)$, computed by direct multiplication and collection of terms. $\square$

These formulas offer an efficient audit of numerical data. Computing three roots is unnecessary: one can compare coefficients directly, using exact ring arithmetic.

## 10. Scope and limitations

The term “functoriality” has both local algebraic and global automorphic content. The present theory establishes the complete unramified parameter-side compatibility for the symmetric-square representation. It does not construct a global automorphic representation on rank three from one on rank two. It also does not prove convergence, analytic continuation, functional equations, or equality at ramified and archimedean places.

These limitations clarify rather than diminish the result. A global lifting theorem must, at every unramified place, induce exactly the parameter transformation studied here. Consequently, the central-character law, Euler-factor formula, and tensor-square decomposition are unavoidable local constraints. The ring-general formulation further identifies which parts of the story are purely algebraic and independent of analytic theory.

## 11. Future work

Several extensions are natural. First, for the $n$th symmetric power, one expects the $n+1$ parameters

$$
a^i b^{n-i},\qquad 0\le i\le n.
$$

Their product should be

$$
(ab)^{n(n+1)/2}.
$$

Second, the Clebsch–Gordan rule predicts a parameter-multiset decomposition

$$
\pi\otimes\operatorname{Sym}^n\pi
\cong
\operatorname{Sym}^{n+1}\pi
\oplus
\bigl(\det\pi\otimes\operatorname{Sym}^{n-1}\pi\bigr),
$$

and hence an Euler-denominator factorization generalizing Theorem 5.1. Third, over a field with nonzero parameters, the symmetric-square construction should commute with taking contragredients, since inversion sends $(a^2,ab,b^2)$ to $(a^{-2},a^{-1}b^{-1},b^{-2})$. Fourth, local identities can be multiplied over arbitrary finite sets of places. Finally, a global extension would require the theory of automorphic representations and analytic $L$-functions beyond the finite polynomial framework developed here.

## 12. Conclusion

The unramified symmetric-square transfer is governed by the elementary transformation

$$
(a,b)\longmapsto(a^2,ab,b^2),
$$

but this transformation already realizes a coherent instance of functoriality. It commutes with coefficient change, cubes the original central character, determines the expected rank-three Euler denominator, and separates the tensor-square Euler denominator into symmetric-square and determinant factors. Its trace is $a^2+ab+b^2$, linked to the cubic difference $a^3-b^3$ by a division-free telescoping identity.

Every result holds over an arbitrary commutative ring. The local theory is therefore a finite, universal algebraic blueprint for the unramified behavior of the symmetric-square lifting from rank two to rank three.
