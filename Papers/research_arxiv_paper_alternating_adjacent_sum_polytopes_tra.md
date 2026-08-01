# Two-State Transfer Matrices for Alternating Adjacent-Sum Systems

**Aristotle**  
**1 August 2026**

## Abstract

We study finite-state paths whose adjacent coordinates satisfy bounds alternating with period two. For states $0,1,\ldots,d-1$, the one-step compatibility matrix for a bound $b$ has entry $1$ at $(i,j)$ exactly when $i+j\le b$. Pairing bounds $s$ and $s+1$ produces the period matrix $M=A_sA_{s+1}$. We prove that each entry of this product counts two-edge paths with the prescribed alternating inequalities. We then give a complete recurrence theory for the two-state case over an arbitrary commutative ring. Cayley–Hamilton implies that all powers of $M$ satisfy a second-order recurrence with coefficients $\operatorname{tr}(M)$ and $\det(M)$. Arbitrary weighted open-boundary counts, even cyclic traces, and odd cyclic traces with one extra transfer step inherit exactly this recurrence. Their ordinary generating functions consequently have the common characteristic denominator $1-\operatorname{tr}(M)z+\det(M)z^2$, while their numerators encode boundary data. We also prove invariance of positive-length cyclic counts under rotation of the two alternating transfer factors. Algorithms based on dynamic programming, fast matrix exponentiation, and scalar recurrence evaluation are presented, together with examples and applications to constrained symbolic systems.

## 1. Introduction

Adjacent-sum restrictions are a basic source of lattice-point and finite-word counting problems. Given a sequence $(x_0,x_1,\ldots,x_m)$ drawn from a finite set of nonnegative integers, one imposes inequalities of the form $x_r+x_{r+1}\le b_r$. In a uniform model, every $b_r$ is the same. Here the bounds have period two: they alternate between $s$ and $s+1$. This is the smallest nonuniform deformation of the uniform model and already produces a meaningful parity distinction.

The principal observation is that periodicity should be absorbed into the time step. A one-edge transition alternates between two matrices, but a two-edge period is governed by a single matrix. Once this period matrix is identified, all path lengths containing complete periods are described by its powers. Open paths are obtained by applying left and right boundary weights. Closed paths are obtained by taking traces. Odd closed paths retain one unpaired transfer matrix.

For two states, the matrix algebra is especially rigid. Every $2\times2$ matrix satisfies a quadratic identity, so every scalar linear observation of its powers satisfies a second-order recurrence. This gives a precise explanation of a parity phenomenon: the open, even-cyclic, and odd-cyclic sequences may have different initial conditions and therefore different numerators, yet their generating functions inherit the same denominator.

The treatment below is algebraic and self-contained. Section 2 defines the alternating path model and proves the two-step interpretation. Section 3 introduces the three boundary observables. Section 4 establishes the characteristic recurrence. Section 5 derives generating functions and spectral formulas. Section 6 proves cyclic rotation invariance. Sections 7 and 8 discuss algorithms and an explicit example. Sections 9–11 describe applications, limitations, and further directions.

## 2. Alternating adjacent-sum paths

### 2.1. State space and one-step compatibility

Fix an integer $d\ge1$ and let

$$
S_d=\{0,1,\ldots,d-1\}.
$$

For every integer $b\ge0$, define the adjacency matrix $A_b\in\mathbb Z^{d\times d}$ by

$$
(A_b)_{ij}=\mathbf 1_{i+j\le b}
=\begin{cases}
1,&i+j\le b,\\
0,&i+j>b,
\end{cases}
\qquad i,j\in S_d.
$$

Thus $A_b$ is the compatibility matrix for one adjacent-sum inequality. It is symmetric, although products of matrices with different bounds need not be symmetric.

Fix $s\ge0$. We call $A_s$ the strict-step matrix and $A_{s+1}$ the relaxed-step matrix. A complete period consists first of a strict step and then of a relaxed step, and its transfer matrix is

$$
M=A_sA_{s+1}.
$$

Changing which step is called first replaces $M$ by $A_{s+1}A_s$. For open paths this may alter endpoint data. For cycles, Section 6 shows that positive-length traces are unchanged.

### 2.2. The path interpretation

**Theorem 2.1 (Two-Step Path-Counting Theorem).** For every $d\ge1$, $s\ge0$, and $i,k\in S_d$, the period-matrix entry is

$$
M_{ik}=\sum_{j\in S_d}
\mathbf 1_{i+j\le s}\mathbf 1_{j+k\le s+1}.
$$

Equivalently, $M_{ik}$ is the number of intermediate states $j$ such that the two-edge path $i\to j\to k$ obeys the strict bound on its first edge and the relaxed bound on its second edge.

**Proof sketch.** By the definition of matrix multiplication,

$$
(A_sA_{s+1})_{ik}=\sum_{j\in S_d}(A_s)_{ij}(A_{s+1})_{jk}.
$$

Substituting the indicator definitions gives the displayed formula. Each product is $1$ precisely when both inequalities hold, and is $0$ otherwise. Hence the sum counts admissible intermediate states. $\square$

Iterating the same argument shows that $(M^n)_{ik}$ counts alternating paths of $2n$ edges from $i$ to $k$, with the designated strict step first in each period. This follows by induction: multiplication by another $M$ concatenates one additional admissible two-edge segment and sums over the joining state.

## 3. Boundary observables

The algebraic recurrence is most naturally stated over a commutative ring $R$. Let $M$ be a $2\times2$ matrix over $R$, indexed by the two states $0$ and $1$.

### 3.1. Weighted open paths

Given boundary-weight functions $u,v:\{0,1\}\to R$, define the open count after $n$ periods by

$$
C_n(u,v;M)=\sum_{i=0}^1\sum_{j=0}^1u_i(M^n)_{ij}v_j.
$$

In vector notation this is $u^{\mathsf T}M^nv$. When $R=\mathbb Z$ and all weights equal $1$, it counts all paths without endpoint restrictions. Indicator weights select fixed endpoint sets. More general weights can encode endpoint multiplicities, costs, or signed statistics.

### 3.2. Even cyclic paths

Define the even cyclic count by

$$
E_n(M)=\operatorname{tr}(M^n).
$$

For an adjacency interpretation, a diagonal entry $(M^n)_{ii}$ counts paths that begin and end at $i$ after $n$ complete periods. Summing over $i$ counts closed paths with a marked starting position.

### 3.3. Odd cyclic paths

Let $A$ be an additional $2\times2$ transfer matrix over $R$. Define

$$
O_n(M,A)=\operatorname{tr}(M^nA).
$$

This represents $n$ complete two-step periods followed by one unpaired transition. In the alternating adjacent-sum model, $A$ can be either the strict or relaxed one-step matrix, depending on the parity convention and the location of the marked starting edge.

The three quantities $C_n$, $E_n$, and $O_n$ are linear functions of $M^n$. This common linearity is the reason a single matrix identity controls all of them.

## 4. Characteristic recurrences in the two-state case

Let

$$
t=\operatorname{tr}(M),\qquad \delta=\det(M).
$$

All results in this section hold for every $2\times2$ matrix over any commutative ring $R$; no positivity or diagonalizability is required.

**Theorem 4.1 (Two-State Cayley–Hamilton Identity).** Every $2\times2$ matrix $M$ over a commutative ring satisfies

$$
M^2-tM+\delta I=0.
$$

**Proof sketch.** Write $M=\begin{pmatrix}a&b\\c&d\end{pmatrix}$. Then $t=a+d$ and $\delta=ad-bc$. Direct multiplication gives

$$
M^2=\begin{pmatrix}a^2+bc&ab+bd\\ac+cd&bc+d^2\end{pmatrix}.
$$

Subtracting $(a+d)M$ and adding $(ad-bc)I$ makes each diagonal and off-diagonal entry vanish. Commutativity of $R$ permits the required rearrangements. $\square$

**Theorem 4.2 (Matrix-Power Recurrence).** For every $n\ge0$,

$$
M^{n+2}=tM^{n+1}-\delta M^n.
$$

**Proof sketch.** Multiply the identity in Theorem 4.1 on the left by $M^n$ and use associativity. Scalar multiplication commutes with matrix multiplication because $R$ is commutative. $\square$

The next three results are immediate consequences but are stated separately because they correspond to distinct combinatorial boundary conditions.

**Theorem 4.3 (Open-Chain Recurrence).** For all boundary weights $u,v$ and all $n\ge0$,

$$
C_{n+2}(u,v;M)=tC_{n+1}(u,v;M)-\delta C_n(u,v;M).
$$

**Proof sketch.** Apply the linear functional $X\mapsto u^{\mathsf T}Xv$ to both sides of Theorem 4.2. Linearity pulls the coefficients $t$ and $\delta$ outside. $\square$

**Theorem 4.4 (Even-Cycle Recurrence).** For all $n\ge0$,

$$
E_{n+2}(M)=tE_{n+1}(M)-\delta E_n(M).
$$

**Proof sketch.** Take the trace of both sides of Theorem 4.2 and use linearity of trace. $\square$

**Theorem 4.5 (Odd-Cycle Recurrence).** For every extra-step matrix $A$ and all $n\ge0$,

$$
O_{n+2}(M,A)=tO_{n+1}(M,A)-\delta O_n(M,A).
$$

**Proof sketch.** Right-multiply Theorem 4.2 by $A$, then take the trace. Matrix multiplication distributes over subtraction and commutes with scalar multiplication, while trace is linear. $\square$

These theorems make the parity split precise. Even and odd cyclic counts are generally different because

$$
E_0=2,\qquad E_1=t,
$$

whereas

$$
O_0=\operatorname{tr}(A),\qquad O_1=\operatorname{tr}(MA).
$$

Nevertheless, the recurrence coefficients are identical. The same statement holds for every choice of open boundary weights.

## 5. Rational generating functions and spectral behavior

### 5.1. The common denominator

**Proposition 5.1 (Generating Function of a Characteristic Sequence).** Suppose a sequence $(x_n)_{n\ge0}$ over a commutative ring satisfies

$$
x_{n+2}=tx_{n+1}-\delta x_n.
$$

Then its ordinary generating function $X(z)=\sum_{n\ge0}x_nz^n$ satisfies

$$
X(z)=\frac{x_0+(x_1-tx_0)z}{1-tz+\delta z^2}
$$

as a formal power series identity.

**Proof sketch.** Multiply the recurrence by $z^{n+2}$ and sum over $n\ge0$. The left side becomes $X(z)-x_0-x_1z$. The two terms on the right become $tz(X(z)-x_0)$ and $-\delta z^2X(z)$. Collecting the terms containing $X(z)$ and solving yields the formula. The denominator has constant coefficient $1$, so it is invertible as a formal power series. $\square$

**Corollary 5.2 (Shared Characteristic Denominator).** The generating functions of every weighted open count $C_n$, the even cyclic count $E_n$, and every odd cyclic count $O_n$ have denominator

$$
D(z)=1-\operatorname{tr}(M)z+\det(M)z^2.
$$

Their respective numerators are determined by their first two values.

**Proof sketch.** Apply Proposition 5.1 to Theorems 4.3–4.5. $\square$

The phrase “common denominator” refers to this canonical characteristic representation. In a special sequence, numerator and denominator may share a factor, causing cancellation. Thus the minimal denominator of an individual observable can be smaller, but every observable is governed by the stated common quadratic.

### 5.2. Eigenvalues and growth

Over a field extension in which the characteristic polynomial splits, let $\lambda_+$ and $\lambda_-$ solve

$$
r^2-tr+\delta=0.
$$

Then

$$
D(z)=(1-\lambda_+z)(1-\lambda_-z).
$$

If $\lambda_+\ne\lambda_-$, every scalar sequence satisfying the recurrence has the form

$$
x_n=\alpha\lambda_+^n+\beta\lambda_-^n
$$

for constants determined by $x_0$ and $x_1$. If the roots coincide at $\lambda$, the general form is

$$
x_n=(\alpha+\beta n)\lambda^n.
$$

These formulas follow either by solving the recurrence or by partial fractions. If $M$ is a nonnegative irreducible real matrix, Perron–Frobenius theory supplies a positive eigenvalue equal to the spectral radius. Provided the chosen observable does not annihilate its eigendirection, that eigenvalue determines exponential growth. This spectral conclusion requires positivity and noncancellation hypotheses; the algebraic recurrence itself does not.

## 6. Rotation of alternating cyclic products

A closed alternating path has no intrinsic first edge. The following identities express this symmetry.

**Lemma 6.1 (Alternating Product Rotation).** For square matrices $A$ and $B$ of the same size over a commutative ring and every $n\ge0$,

$$
B(AB)^n=(BA)^nB.
$$

**Proof sketch.** For $n=0$, both sides equal $B$. If the identity holds for $n$, then

$$
B(AB)^{n+1}=B(AB)^nAB=(BA)^nBAB=(BA)^{n+1}B,
$$

using associativity. This completes induction. $\square$

**Theorem 6.2 (Cyclic Rotation Invariance).** For every $n\ge0$,

$$
\operatorname{tr}((AB)^{n+1})=\operatorname{tr}((BA)^{n+1}).
$$

**Proof sketch.** Expand one final factor and reassociate:

$$
\operatorname{tr}((AB)^nAB)
=\operatorname{tr}(((AB)^nA)B).
$$

The cyclic trace identity $\operatorname{tr}(XY)=\operatorname{tr}(YX)$ moves $B$ to the front. Lemma 6.1 then changes $B(AB)^n$ into $(BA)^nB$, giving $\operatorname{tr}((BA)^nBA)$. $\square$

The exponent is required to be positive. At exponent zero both products are the identity anyway, but the combinatorial interpretation is an empty cycle rather than a rotated positive-length alternating cycle.

## 6.1. Boundary data versus dynamics

The preceding results admit a useful systems interpretation. The period matrix $M$ is the dynamical core, while $u$, $v$, the trace, and the extra matrix $A$ are observation mechanisms. Two models with the same $M$ but different endpoints therefore have identical characteristic dynamics. This is stronger than saying that their asymptotic rates often agree: it says that each complete finite sequence lies in the same two-dimensional module of recurrence solutions. Only two initial values are needed to select a particular observable.

This viewpoint also clarifies degeneracies. If $M$ is a scalar matrix, every observation is a pure geometric sequence after accounting for its initial coefficient. If $\det(M)=0$, the recurrence loses its oldest term and becomes first order from index one onward. If the characteristic polynomial has a repeated root, a generalized eigenvector can introduce the factor $n$. Finally, even when two distinct characteristic roots exist, an observable can annihilate one eigenspace; its generating function then cancels the corresponding factor. These are not failures of the common-denominator theorem. They describe situations in which the canonical denominator is not minimal for a particular boundary choice.

The ring-valued formulation is also significant. Counting uses $R=\mathbb Z$, but polynomial entries can record statistics. For example, replacing a legal transition by a monomial whose exponent records a cost yields a polynomial-valued matrix. The recurrence then holds coefficientwise, simultaneously controlling every cost class. Taking $R$ to be a field permits spectral analysis, while taking a quotient ring can encode congruence information. No new recurrence proof is needed for these variants.

## 6.2. Periods longer than two

The stationary-period principle is not restricted to alternating pairs. If local transfer matrices repeat with period $p$, define one period matrix $P=A_0A_1\cdots A_{p-1}$. Complete periods are governed by powers $P^n$, and incomplete lengths append a fixed prefix product. For a $d$-state model, Cayley–Hamilton gives a scalar recurrence of order at most $d$ for every linear observation of $P^n$. The present period-two, two-state theory is the first nontrivial instance: temporal nonuniformity is compressed into one product, and spatial state dimension determines recurrence order.

## 7. Algorithms

### 7.1. Constructing the period matrix

Given $d$ and $s$, construct $A_s$ and $A_{s+1}$ by testing each pair $(i,j)$. This costs $O(d^2)$ comparisons and memory. Their generic matrix product costs $O(d^3)$ arithmetic operations. Because the matrices have threshold structure, one can also compute

$$
M_{ik}=\#\{j\in S_d:j\le s-i\text{ and }j\le s+1-k\}
$$

as

$$
M_{ik}=\max\bigl(0,\min(d-1,s-i,s+1-k)+1\bigr),
$$

reducing construction to $O(d^2)$ arithmetic operations. The indicator-sum formula remains the conceptual foundation.

### 7.2. Computing a distant count

For a requested period $n$, binary exponentiation computes $M^n$ in $O(d^3\log n)$ generic arithmetic operations and $O(d^2)$ storage. In the two-state case, matrix dimensions are constant, so this becomes $O(\log n)$ ring operations up to constant factors. The desired open or cyclic observable is then read from the power.

### 7.3. Generating a sequence

When many consecutive two-state counts are needed, first compute $t$, $\delta$, $x_0$, and $x_1$. Then iterate

$$
x_{k+2}=tx_{k+1}-\delta x_k.
$$

This uses $O(N)$ ring operations and $O(1)$ working storage to produce values through $x_N$. It is preferable to repeated matrix powering for a dense initial segment. Fast linear-recurrence methods can recover a single distant term in $O(\log n)$ ring operations.

### 7.4. Independent recurrence check

For numerical exploration, one may compute $x_0,\ldots,x_N$ directly from matrix powers and verify

$$
x_{k+2}-tx_{k+1}+\delta x_k=0
$$

for each $k$. Performing this check for open, even-cyclic, and odd-cyclic observables demonstrates that the denominator is independent of the boundary functional.

## 8. Numerical example

Take $d=2$ and $s=1$. The state set is $\{0,1\}$, and

$$
A_1=\begin{pmatrix}1&1\\1&0\end{pmatrix},\qquad
A_2=\begin{pmatrix}1&1\\1&1\end{pmatrix}.
$$

Therefore

$$
M=A_1A_2=\begin{pmatrix}2&2\\1&1\end{pmatrix},
\qquad t=3,
\qquad \delta=0.
$$

The characteristic recurrence is

$$
x_{n+2}=3x_{n+1}.
$$

Choose $u=v=(1,1)^{\mathsf T}$. Then

$$
C_0=u^{\mathsf T}Iv=2,
$$

not $4$: the identity matrix permits only matching zero-period endpoints. Also,

$$
C_1=u^{\mathsf T}Mv=6.
$$

Thus the open sequence is

$$
2,6,18,54,162,\ldots,
$$

with generating function

$$
C(z)=\frac{2}{1-3z}.
$$

For even cycles,

$$
E_0=2,\qquad E_1=3,
$$

so

$$
E_n=2,3,9,27,81,\ldots
$$

and

$$
E(z)=\frac{2-3z}{1-3z}.
$$

For an extra strict step $A=A_1$,

$$
O_0=\operatorname{tr}(A_1)=1,
$$

and direct multiplication gives $O_1=\operatorname{tr}(MA_1)=5$. Hence

$$
O_n=1,5,15,45,135,\ldots
$$

and

$$
O(z)=\frac{1+2z}{1-3z}.
$$

All three canonical quadratic denominators are $1-3z+0z^2$, which here reduces to a linear polynomial because $M$ has determinant zero. The distinct numerators retain the boundary and parity information.

The example also illustrates a subtle point about zero periods. The open expression $u^{\mathsf T}I v$ sums only terms with equal endpoints, whereas a naive unconstrained pair count would sum all endpoint pairs. The transfer convention is internally consistent: a zero-edge path begins and ends at the same state.

## 9. Applications

### 9.1. Lattice-point enumeration

Integer vectors satisfying local inequalities can be viewed as paths through their coordinate values. Alternating bounds create a period-two transfer system. Once endpoint conventions and coordinate ranges are fixed, matrix products enumerate feasible vectors. Closed versions add an inequality connecting the last coordinate to the first and naturally lead to traces.

### 9.2. Constrained symbolic sequences

Finite alphabets with restrictions on adjacent symbols arise in constrained coding, protocol design, and key-generation policies. A zero-one matrix records legal transitions. Periodically varying policies are handled by multiplying the matrices over one complete policy cycle. The recurrence gives compact count formulas and can quantify the exponential supply of admissible strings.

### 9.3. Statistical and physical models

If the entries $0$ and $1$ are replaced by weights, the same algebra computes partition functions for one-dimensional systems with alternating interactions. Open boundary vectors represent external fields or endpoint conditions, while traces impose periodic boundary conditions. The commutative-ring formulation allows polynomial or symbolic weights as well as numerical ones.

### 9.4. Security interpretation

In cryptographic applications, counting admissible state sequences can estimate the size of a constrained design space. The present results do not by themselves establish cryptographic security: entropy, attack models, and distributional issues remain separate. They do provide an exact and efficient counting layer for systems whose local admissibility alternates with period two.

## 10. Scope and limitations

The recurrence theorems are universal for two-state transfer matrices, but they do not alone establish every analytic claim associated with higher-dimensional alternating adjacent-sum polytopes. In a full polytope model, the natural matrix may have $s+2$ states rather than two. Cayley–Hamilton then yields a recurrence of order at most $s+2$, and identifying a smaller minimal order requires additional structure.

Likewise, a matrix count becomes an Ehrhart count only after a precise bijection identifies lattice points in a dilated polytope with paths in the chosen state space. The present path-counting theorem proves the local two-edge mechanism; a full geometric development must specify dilation parameters, state truncation, open and cyclic boundary inequalities, and the resulting correspondence.

Finally, dominant-pole asymptotics require hypotheses. A common characteristic denominator supplies candidate poles, but cancellation can remove a pole from an individual generating function. Positivity and irreducibility are standard conditions ensuring a distinguished spectral radius, while nonvanishing projections ensure that the corresponding mode appears in the observable.

## 11. Discussion and future work

The core mechanism can be summarized in five transformations:

1. local adjacent-sum inequalities become zero-one compatibility matrices;
2. two alternating steps become one period matrix;
3. path boundary conditions become linear matrix observables;
4. Cayley–Hamilton becomes a scalar recurrence;
5. the recurrence becomes a rational generating function.

This separation of local dynamics from boundary observation is the conceptual contribution. It explains why parity classes can differ while sharing a denominator and why rotating the starting point of a cycle does not change its count.

Several directions extend the theory. The first is to treat the full $(s+2)$-state adjacent-sum matrices and determine when their characteristic recurrences reduce in order. The second is to define open and cyclic lattice-point sets and prove explicit bijections with matrix products and traces. The third is to develop formal-power-series identities and dominant-pole asymptotics with careful cancellation criteria. Further special structure may yield Möbius recurrences and arctangent forms for odd-dimensional series, as well as Jacobi-derivative formulas for even cyclic numerators and corresponding odd cyclic expressions.

## 12. Conclusion

A period-two local rule is rendered stationary by grouping two transitions. In the two-state setting, the resulting period matrix has a quadratic characteristic polynomial, and this one polynomial governs weighted open paths, even cycles, and odd cycles with an extra step. The sequences differ through initial data but share the recurrence

$$
x_{n+2}=\operatorname{tr}(M)x_{n+1}-\det(M)x_n
$$

and the characteristic denominator

$$
1-\operatorname{tr}(M)z+\det(M)z^2.
$$

Cyclic traces are invariant under rotation of the alternating factors, matching the absence of a preferred starting edge on a closed path. These facts provide a compact algebraic foundation for counting periodically constrained sequences and a clear starting point for the higher-state geometry of alternating adjacent-sum polytopes.
