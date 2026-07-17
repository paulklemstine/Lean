# Trace Multiplication and Pell-Conic Dynamics for Integral Möbius Transformations

**Aristotle**  
**17 July 2026**

## Abstract

We develop an arithmetic model for iterated integral Möbius transformations of determinant one. If $A\in\mathrm{SL}_2(\mathbb Z)$ has trace $t$, the traces $u_n=\operatorname{tr}(A^n)$ satisfy the universal recurrence $u_0=2$, $u_1=t$, and $u_{n+2}=tu_{n+1}-u_n$. Conversely, every integer $t$ occurs as the trace of such a transformation, so this recurrence captures all integral trace parameters. We prove that multiplication of orbit indices descends to explicit polynomial maps on traces. In particular,

$$
u_{2n}=u_n^2-2,
\qquad
u_{3n}=u_n^3-3u_n.
$$

The doubled discriminant factors as

$$
u_{2n}^2-4=(u_n^2-4)u_n^2,
$$

and equivalently the Pell parameter satisfies $4-u_{2n}^2=(4-u_n^2)u_n^2$. These identities are uniform across elliptic, parabolic, and hyperbolic trace regimes. We relate them to the invariant conic $x^2-txy+y^2=4-t^2$, describe direct and accelerated algorithms for computing traces, establish pure periodicity of the pair recurrence modulo every positive modulus, and explain how trace coordinates provide a canonical foundation for studying primitive geodesics. The results isolate a robust arithmetic structure without imposing noncanonical ring operations on a hyperbolic tessellation.

## 1. Introduction

Arithmetic on a curved quotient requires a canonical choice of quantities. Points or vertices in a hyperbolic tessellation can be labeled in many ways, but labels alone do not define addition, multiplication, divisibility, or primality. By contrast, the trace of a determinant-one Möbius transformation is invariant under conjugation, determines its dynamical type, and is explicitly related to hyperbolic translation length. Trace is therefore a natural arithmetic coordinate for modular hyperbolic dynamics.

Let

$$
A=\begin{pmatrix}a&b\\c&d\end{pmatrix}
$$

have integral entries and determinant $ad-bc=1$. It acts by $z\mapsto(az+b)/(cz+d)$ on the upper half-plane; the Poincaré disk model is obtained by conjugating this action. Repetition of the transformation corresponds to the powers $A^n$. The sequence of traces $\operatorname{tr}(A^n)$ turns this group-power orbit into an integer recurrence.

The central observation is functorial: taking a power in stages multiplies indices,

$$
(A^n)^m=A^{mn},
$$

while the Cayley–Hamilton theorem expresses the trace of a power as a polynomial in the original trace. Consequently, index multiplication is represented by polynomial evaluation. The cases $m=2$ and $m=3$ yield quadratic and cubic laws. The quadratic law further forces a square-factor identity for the trace discriminant.

This paper gives a self-contained account of these statements and their consequences. Section 2 introduces integral Möbius transformations and the universal trace recurrence. Section 3 proves the power interpretation and index-multiplication principle. Section 4 establishes the doubling and tripling laws. Section 5 develops the invariant Pell conic and discriminant factorization. Section 6 treats boundary regimes and spectral coordinates. Sections 7 and 8 present computational algorithms and applications, including modular periodicity and primitive-orbit diagnostics. Section 9 clarifies the scope of the results, and Section 10 lists concrete directions for further study.

## 2. Definitions and basic structure

### 2.1. Integral determinant-one Möbius transformations

An **integral determinant-one Möbius transformation** is represented by a matrix

$$
A=\begin{pmatrix}a&b\\c&d\end{pmatrix},
\qquad a,b,c,d\in\mathbb Z,
\qquad ad-bc=1.
$$

Its trace is $\operatorname{tr}(A)=a+d$. Matrices $A$ and $-A$ induce the same fractional linear map, but retaining a representative in $\mathrm{SL}_2(\mathbb Z)$ is convenient for signed trace identities. Conjugation preserves trace, so every formula below is independent of the coordinates used to represent a conjugacy class.

The identity has trace $2$. Matrix multiplication defines powers by $A^0=I$ and $A^{n+1}=AA^n$.

### 2.2. The determinant-one trace recurrence

For $t\in\mathbb Z$, define the sequence $u_n(t)$ by

$$
u_0(t)=2,\qquad u_1(t)=t,
$$

and

$$
u_{n+2}(t)=t\,u_{n+1}(t)-u_n(t)
\qquad(n\ge0).
$$

We call this the **determinant-one trace recurrence**. Its first terms are

$$
2,\quad t,\quad t^2-2,\quad t^3-3t,\quad t^4-4t^2+2.
$$

Each $u_n(t)$ is a monic polynomial in $t$ of degree $n$ for $n\ge1$. These are normalized Chebyshev polynomials: $u_n(2x)=2T_n(x)$, where $T_n$ is the Chebyshev polynomial of the first kind.

The recurrence covers every integral parameter through a concrete matrix.

**Proposition 2.1 (Universal trace realization).** For every integer $t$, there exists an integral determinant-one matrix with trace $t$. One choice is

$$
A_t=\begin{pmatrix}t-1&1\\t-2&1\end{pmatrix}.
$$

**Proof sketch.** Direct calculation gives $\det A_t=(t-1)-(t-2)=1$ and $\operatorname{tr}(A_t)=(t-1)+1=t$. Thus no restriction on $t$ is hidden in the recurrence. $\square$

### 2.3. Dynamical regimes

For a real determinant-one matrix, trace separates the standard regimes:

- $|t|<2$: elliptic;
- $|t|=2$: parabolic, including degenerate central representatives;
- $|t|>2$: hyperbolic.

If $|t|>2$, the eigenvalues are real and reciprocal. Writing the eigenvalues as $\lambda$ and $\lambda^{-1}$ gives

$$
u_n(t)=\lambda^n+\lambda^{-n}.
$$

For $t>2$, write $t=2\cosh\theta$ with $\theta>0$; then

$$
u_n(t)=2\cosh(n\theta).
$$

This analytic expression is useful for interpretation, but all principal results below are integral polynomial identities and require no division into cases.

## 3. Traces of powers and multiplication of indices

The bridge between group dynamics and recurrence arithmetic is Cayley–Hamilton.

**Theorem 3.1 (Trace recurrence for powers).** Let $A$ be an integral $2\times2$ matrix with determinant $1$ and trace $t$. Then, for every $n\ge0$,

$$
\operatorname{tr}(A^n)=u_n(t).
$$

**Proof sketch.** Cayley–Hamilton gives

$$
A^2-tA+I=0.
$$

Multiplying by $A^n$ yields $A^{n+2}=tA^{n+1}-A^n$. Taking traces gives the defining recurrence. The initial values are $\operatorname{tr}(I)=2$ and $\operatorname{tr}(A)=t$, so uniqueness of recursively defined sequences proves the claim. $\square$

The group law supplies the index arithmetic.

**Lemma 3.2 (Power-index multiplication).** For every square matrix $A$ and nonnegative integers $m,n$,

$$
(A^n)^m=A^{mn}.
$$

**Proof sketch.** Induct on $m$. The case $m=0$ is the identity matrix. If the formula holds for $m$, then $(A^n)^{m+1}=A^n(A^n)^m=A^nA^{mn}=A^{(m+1)n}$. $\square$

Combining Theorem 3.1 and Lemma 3.2 gives a general principle even before the relevant polynomials are named.

**Corollary 3.3 (Index multiplication descends to traces).** For all integers $t$ and all nonnegative integers $m,n$,

$$
u_{mn}(t)=u_m(u_n(t)).
$$

**Proof sketch.** Choose a determinant-one integral matrix $A$ with trace $t$ using Proposition 2.1. Then

$$
u_{mn}(t)=\operatorname{tr}(A^{mn})
=\operatorname{tr}((A^n)^m)
=u_m(\operatorname{tr}(A^n))
=u_m(u_n(t)).
$$

The last two equalities apply Theorem 3.1 first to $A^n$ and then to $A$. $\square$

This composition law explains why the recurrence polynomials are structurally natural. It also gives $u_m\circ u_n=u_{mn}=u_n\circ u_m$.

## 4. Explicit doubling and tripling laws

The first nontrivial recurrence polynomials are

$$
u_2(x)=x^2-2,
\qquad
u_3(x)=x^3-3x.
$$

Substituting these into Corollary 3.3 produces the main trace-multiplication formulas.

**Theorem 4.1 (Trace Doubling Theorem).** For every integer $t$ and every nonnegative integer $n$,

$$
u_{2n}(t)=u_n(t)^2-2.
$$

**Proof sketch.** Let $B=A^n$. Cayley–Hamilton for $B$ gives $B^2-(\operatorname{tr}B)B+I=0$. Taking traces and using $\operatorname{tr}(I)=2$ yields $\operatorname{tr}(B^2)=(\operatorname{tr}B)^2-2$. Since $B^2=A^{2n}$ and $\operatorname{tr}(A^k)=u_k(t)$, the formula follows. Equivalently, use Corollary 3.3 with $m=2$. $\square$

**Theorem 4.2 (Trace Tripling Theorem).** For every integer $t$ and every nonnegative integer $n$,

$$
u_{3n}(t)=u_n(t)^3-3u_n(t).
$$

**Proof sketch.** Multiply $B^2-(\operatorname{tr}B)B+I=0$ by $B$ and take traces. Substitution of $\operatorname{tr}(B^2)=(\operatorname{tr}B)^2-2$ gives $\operatorname{tr}(B^3)=(\operatorname{tr}B)^3-3\operatorname{tr}B$. Set $B=A^n$. Equivalently, apply Corollary 3.3 with $m=3$. $\square$

### 4.1. Numerical example

For $t=3$, the recurrence gives

$$
(u_0,u_1,u_2,u_3,u_4,u_5)=(2,3,7,18,47,123).
$$

Doubling at $n=5$ predicts

$$
u_{10}=123^2-2=15127.
$$

Tripling at $n=4$ predicts

$$
u_{12}=47^3-3\cdot47=103682.
$$

Direct recurrence computation gives the same values. These examples illustrate that a distant term can be reconstructed from a single intermediate trace.

## 5. Pell-conic geometry and discriminant factorization

### 5.1. The invariant conic

The trace recurrence preserves a binary quadratic expression.

**Theorem 5.1 (Pell-Conic Invariant).** For every integer $t$ and every $n\ge0$,

$$
u_n(t)^2-t\,u_n(t)u_{n+1}(t)+u_{n+1}(t)^2=4-t^2.
$$

Hence every consecutive pair $(u_n(t),u_{n+1}(t))$ is an integral point on

$$
x^2-txy+y^2=4-t^2.
$$

**Proof sketch.** Define $F(x,y)=x^2-txy+y^2$. One recurrence step sends $(x,y)$ to $(y,ty-x)$. Expanding shows

$$
F(y,ty-x)=F(x,y).
$$

At $(u_0,u_1)=(2,t)$, the value is $4-2t^2+t^2=4-t^2$. Invariance under every step proves the formula. $\square$

For hyperbolic $|t|>2$, set $D=t^2-4>0$. The conic becomes

$$
x^2-txy+y^2=-D.
$$

The discriminant of the binary quadratic form is $D$. Thus a group-power orbit gives a distinguished sequence of integral points on a Pell-type conic. The recurrence transition

$$
\begin{pmatrix}x\\y\end{pmatrix}
\longmapsto
\begin{pmatrix}0&1\\-1&t\end{pmatrix}
\begin{pmatrix}x\\y\end{pmatrix}
$$

has determinant $1$ and preserves the quadratic form.

### 5.2. Doubling and the trace discriminant

Define the trace discriminant at index $n$ by

$$
\Delta_n=u_n(t)^2-4.
$$

The doubling law gives an exact factorization.

**Theorem 5.2 (Doubled Discriminant Factorization).** For every integer $t$ and every $n\ge0$,

$$
u_{2n}(t)^2-4
=igl(u_n(t)^2-4\bigr)u_n(t)^2.
$$

**Proof sketch.** Substitute $u_{2n}=u_n^2-2$ and expand:

$$
(u_n^2-2)^2-4=u_n^4-4u_n^2=(u_n^2-4)u_n^2.
$$

No sign or nondegeneracy assumption is required. $\square$

Changing signs gives the corresponding Pell-parameter statement.

**Corollary 5.3 (Doubling morphism for the Pell parameter).** For every integer $t$ and every $n\ge0$,

$$
4-u_{2n}(t)^2
=igl(4-u_n(t)^2\bigr)u_n(t)^2.
$$

Thus doubling multiplies $u_n^2-4$ by a square. In any setting where square classes are meaningful, $\Delta_{2n}$ and $\Delta_n$ represent the same square class, except that a zero value remains zero. This is a concrete algebraic signature of an even power.

### 5.3. Compatibility with the conic

The conic invariant concerns consecutive traces, whereas Theorem 5.2 concerns one trace and its doubled index. Their compatibility follows from the common matrix origin. The point $(u_n,u_{n+1})$ is advanced by an invertible isometry of the binary quadratic form, while index doubling replaces $A^n$ by $(A^n)^2$. The scalar trace coordinate changes by $x\mapsto x^2-2$, and its discriminant changes by multiplication with $x^2$. Thus recurrence dynamics, conic geometry, and polynomial iteration are different projections of one power operation.

## 6. Uniformity across dynamical regimes

The formulas have no exceptional trace parameters.

### 6.1. Parabolic boundaries

For $t=2$, the recurrence gives $u_n=2$ for all $n$. The doubling formula is $2=2^2-2$, and Theorem 5.2 reads $0=0\cdot4$. The discriminant vanishes identically.

For $t=-2$, one obtains $u_n=2(-1)^n$. Again $u_n^2-4=0$ for every $n$, and both multiplication formulas hold. Retaining these cases matters: they show that the factorization correctly records parabolic degeneration rather than requiring division by a vanishing discriminant.

### 6.2. Elliptic traces

When $t=2\cos\theta$, the recurrence has the expression

$$
u_n(t)=2\cos(n\theta).
$$

The quadratic and cubic trace laws reduce to the familiar multiple-angle identities for cosine. For integral $t$ with $|t|<2$, only $t=-1,0,1$ occur, and the resulting sequences are periodic.

### 6.3. Hyperbolic traces and lengths

For a hyperbolic transformation, let $\ell$ be its translation length. Up to the sign of the chosen matrix representative,

$$
|t|=2\cosh(\ell/2).
$$

Since $A^n$ has translation length $n\ell$, the identity

$$
|u_n(t)|=2\cosh(n\ell/2)
$$

is geometrically expected. The trace multiplication formulas are precisely the polynomial versions of multiplying lengths inside the hyperbolic cosine. Unlike the length itself, trace remains integral for integral matrices and is therefore suited to arithmetic analysis.

## 7. Algorithms

### 7.1. Linear recurrence evaluation

The most direct method stores two consecutive values.

**Algorithm 7.1 (Sequential trace recurrence).** Given integers $t$ and $n\ge0$, initialize $(x,y)=(2,t)$. Repeat $(x,y)\leftarrow(y,ty-x)$ exactly $n$ times, then return $x$.

**Correctness.** After $k$ iterations, the pair is $(u_k,u_{k+1})$ by induction on $k$. Therefore the returned value is $u_n$.

**Complexity.** The method performs $O(n)$ integer additions and multiplications. It uses $O(1)$ stored integers, although their bit length grows with $n$ in the hyperbolic regime.

### 7.2. Matrix binary exponentiation

Binary exponentiation computes $A_t^n$ in $O(\log n)$ matrix multiplications and then takes the trace.

**Algorithm 7.2 (Binary matrix trace evaluation).** Set $R=I$, $B=A_t$, and $k=n$. While $k>0$, multiply $R$ by $B$ if $k$ is odd, replace $B$ by $B^2$, and replace $k$ by $\lfloor k/2\rfloor$. Return $\operatorname{tr}(R)$.

**Correctness.** The loop invariant is $RB^k=A_t^n$. When $k=0$, this gives $R=A_t^n$. Theorem 3.1 then identifies its trace with $u_n(t)$.

**Complexity.** There are $O(\log n)$ multiplications of $2\times2$ integer matrices. Bit complexity depends on the growth of the entries; for fixed hyperbolic $t$, their bit length is $O(n)$.

### 7.3. Polynomial index jumps

When an index is repeatedly doubled or tripled, Theorems 4.1 and 4.2 give scalar updates

$$
D(x)=x^2-2,
\qquad
T(x)=x^3-3x.
$$

Starting from $u_n$, one may compute $u_{2^a3^b n}$ by composing $D$ and $T$ in any order, because both represent multiplication of the index and hence commute on trace values. This requires $a+b$ scalar polynomial evaluations. For arbitrary indices, matrix exponentiation or a full addition-chain implementation is preferable, since knowing one trace alone does not support an addition formula without additional state.

### 7.4. Modular orbit detection

For modulus $q>1$, reduce the pair transition modulo $q$:

$$
F_t(x,y)=(y,ty-x)\pmod q.
$$

Its inverse is

$$
F_t^{-1}(x,y)=(tx-y,x)\pmod q.
$$

**Proposition 7.3 (Pure modular periodicity).** For every integer $t$ and modulus $q>1$, the sequence $(u_n(t),u_{n+1}(t))\bmod q$ is purely periodic.

**Proof sketch.** The state space has $q^2$ elements, so repetition is inevitable. Because $F_t$ is a bijection, every state lies on a cycle; an orbit cannot have a nonrepeating prefix feeding into a cycle. In particular, the initial pair $(2,t)$ returns after finitely many steps. $\square$

A dictionary-based implementation finds the exact period in at most $q^2$ transitions and uses $O(q^2)$ states in the worst case. Since the transition matrix belongs to $\mathrm{SL}_2(\mathbb Z/q\mathbb Z)$, the period also divides its group-theoretic order.

## 8. Applications and interpretation

### 8.1. Primitive versus imprimitive powers

A hyperbolic conjugacy class is **primitive** if it is not a proper positive power of another class. Closed geodesics inherit the same distinction. If $A=B^2$, then

$$
\operatorname{tr}(A)=\operatorname{tr}(B)^2-2,
$$

and its discriminant has the special form

$$
\operatorname{tr}(A)^2-4
=igl(\operatorname{tr}(B)^2-4\bigr)\operatorname{tr}(B)^2.
$$

Similarly, a cube has trace $x^3-3x$. These conditions provide computable necessary signatures of imprimitive classes. They are not by themselves complete primitivity tests: different conjugacy classes may share a trace, and solving a polynomial trace equation does not automatically produce an integral group root. Nevertheless, the formulas isolate arithmetic exclusion maps that can be combined with conjugacy and Pell-conic data.

### 8.2. Counting in trace coordinates

For hyperbolic $A$, trace and geodesic length satisfy $|\operatorname{tr}A|=2\cosh(\ell/2)$. Hence a trace bound $|\operatorname{tr}A|\le X$ is equivalent to

$$
\ell\le2\operatorname{arcosh}(X/2).
$$

This allows questions about primitive closed geodesics to be translated into integral trace coordinates. Such a counting problem is canonical because trace is conjugacy-invariant. It avoids assigning arithmetic meaning to arbitrary tessellation labels.

### 8.3. Polynomial dynamics

The doubling map $D(x)=x^2-2$ is a classical polynomial dynamical system. Here it has a precise group-theoretic interpretation: iterating $D$ on $u_n$ yields

$$
D^{\circ k}(u_n)=u_{2^kn}.
$$

Likewise, the cubic map $T(x)=x^3-3x$ gives $T^{\circ k}(u_n)=u_{3^kn}$. More generally, the polynomials $u_m(x)$ form a commuting semigroup under composition indexed multiplicatively by positive integers. Integral Möbius dynamics therefore supplies a geometric realization of Chebyshev polynomial iteration.

### 8.4. Finite-ring experiments

Reducing the recurrence modulo $q$ creates an invertible finite dynamical system. The identities survive reduction:

$$
u_{2n}\equiv u_n^2-2\pmod q,
\qquad
u_{3n}\equiv u_n^3-3u_n\pmod q.
$$

These constraints can accelerate consistency checks, stratify periods, and expose exceptional behavior at primes dividing $t^2-4$. The discriminant factorization also indicates that doubling preserves an appropriate modular square-class relation whenever that notion is defined.

### 8.5. Stability under conjugacy and choice of model

If $S$ is an invertible real matrix, then $A$ and $SAS^{-1}$ describe the same transformation in changed coordinates. For every $n$,

$$
(SAS^{-1})^n=SA^nS^{-1},
$$

so cyclicity of trace gives $\operatorname{tr}((SAS^{-1})^n)=\operatorname{tr}(A^n)$. The recurrence parameter, every term $u_n$, the doubling and tripling laws, and the discriminant factorization are consequently conjugacy-invariant. Passing between the upper half-plane and disk models therefore changes none of the arithmetic developed here.

### 8.6. Growth and numerical representation

For fixed hyperbolic $t$ with dominant eigenvalue $|\lambda|>1$, one has $|u_n|\asymp|\lambda|^n$. Thus the bit length of $u_n$ is $\Theta(n\log|\lambda|)$. An algorithm using $O(\log n)$ algebraic stages does not have polylogarithmic bit cost, because it must output an integer with linearly many bits in $n$. This distinction is important when comparing sequential recurrence, scalar polynomial jumps, and binary matrix exponentiation. The latter two reduce the number of stages, while fast big-integer arithmetic governs the cost inside each stage.

The discriminant identity itself offers a useful exact check for implementations. Given independently computed $u_n$ and $u_{2n}$, the residual

$$
r=u_{2n}^2-4-(u_n^2-4)u_n^2
$$

must vanish. Together with the Pell-conic residual, this detects many indexing and arithmetic errors without relying on floating-point approximations.

## 9. Scope and limitations

The results establish exact arithmetic for traces of powers. They do not define a ring of tessellation vertices, prove unique factorization for geometric points, establish a prime-geodesic asymptotic, construct a spectral zeta function, or locate its zeros. Those are distinct tasks requiring precise definitions and substantial analytic input.

In particular, a finite numerical check of zeros cannot establish a critical-line theorem, and a series over an unspecified “hyperbolic norm” is not automatically a canonical zeta function. A mathematically stable route is to begin with primitive conjugacy classes, their lengths, and established spectral constructions, then translate into trace coordinates where possible.

The present framework contributes three ingredients to that route. First, it identifies trace as a canonical integral coordinate. Second, it shows exactly how composite power indices appear through trace polynomials. Third, it connects traces to an invariant Pell conic and a square-factor discriminant law. These are algebraic foundations rather than analytic conclusions.

## 10. Future directions

### 10.1. Universal trace multiplication polynomials

For every positive integer $m$, define the monic integral polynomial $C_m(x)=u_m(x)$. Corollary 3.3 suggests systematic study of

$$
u_{mn}(t)=C_m(u_n(t)),
\qquad
C_m\circ C_n=C_{mn}.
$$

A central target is the general factorization

$$
C_m(x)^2-4=(x^2-4)Q_m(x)^2
$$

for an integral polynomial $Q_m$. The doubled discriminant theorem gives $Q_2(x)=x$. Establishing the family uniformly would clarify how every composite index transforms square classes.

### 10.2. Effective finite-ring periods

The pair recurrence is purely periodic modulo every $q>1$. The next problem is to determine effective bounds and characterize maximal periods. Since the transition matrix

$$
M_t=\begin{pmatrix}0&1\\-1&t\end{pmatrix}
$$

lies in $\mathrm{SL}_2(\mathbb Z/q\mathbb Z)$, the period of the initial pair divides the order of $M_t$. Sharp formulas should depend on the factorization of $q$ and on the discriminant $t^2-4$.

### 10.3. Primitive Pell points and primitive geodesics

For nonsquare positive $D=t^2-4$, one should characterize which points on

$$
x^2-txy+y^2=-D
$$

arise from primitive powers of primitive modular conjugacy classes. Group-theoretic primitivity is subtler than $\gcd(x,y)=1$. Doubling and tripling provide explicit maps whose images mark some imprimitive indices.

### 10.4. Prime-geodesic counting by trace

Let $P(X)$ count primitive hyperbolic conjugacy classes whose absolute trace is at most $X$. An effective asymptotic for $P(X)$ should be obtained by translating geodesic-length estimates through

$$
|\operatorname{tr}A|=2\cosh(\ell(A)/2).
$$

The trace/Pell model supplies a precise counting coordinate and may help organize arithmetic refinements of such estimates.

## 11. Conclusion

For integral determinant-one Möbius transformations, the trace sequence of powers is governed by a universal second-order recurrence. Repeating a power multiplies its index, and Cayley–Hamilton turns that multiplication into polynomial evaluation. The first two laws are

$$
u_{2n}=u_n^2-2,
\qquad
u_{3n}=u_n^3-3u_n.
$$

Doubling also produces the exact factorization

$$
u_{2n}^2-4=(u_n^2-4)u_n^2,
$$

while consecutive traces remain on the invariant Pell conic

$$
x^2-txy+y^2=4-t^2.
$$

Together these statements form a coherent arithmetic system linking group powers, polynomial dynamics, integral recurrences, quadratic Diophantine geometry, modular periodicity, and hyperbolic length. They show that the arithmetic of curved motion is most naturally sought not in arbitrary vertex labels but in conjugacy-invariant coordinates already encoded by the geometry.