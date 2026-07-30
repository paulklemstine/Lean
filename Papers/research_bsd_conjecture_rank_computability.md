# Certified Mordell–Weil Rank Computation from Finite Descent Presentations

## Abstract

Let $E/\mathbb{Q}$ be an elliptic curve. The unconditional computability of the Mordell–Weil rank $r(E)$ for every such curve is not currently known. This paper isolates the finite linear-algebra endpoint of descent and states exactly what can be computed once a complete certificate is available. For a rational relation matrix $A$ with $n$ rows, define the presentation rank by $r_A=n-\operatorname{rank}_{\mathbb{Q}}(A)$. We prove that $r_A$ is the dimension of the quotient of $\mathbb{Q}^n$ by the span of the columns of $A$. Consequently, whenever a certified descent identifies that quotient with the rationalized free part of $E(\mathbb{Q})$, the algebraic rank is exactly $r_A$. Rank parity is transported through the same equality, and any established parity relation $W(E)=(-1)^{r(E)}$ for the root number becomes the explicit formula $W(E)=(-1)^{r_A}$. We give exact Gaussian-elimination algorithms, worked examples, complexity estimates, and a careful account of the certificate-production gap. The result separates a decidable finite checker from the deeper arithmetic problem of constructing a complete descent presentation.

## 1. Introduction

For a nonsingular elliptic curve $E$ over $\mathbb{Q}$, the Mordell–Weil theorem gives a decomposition

$$
E(\mathbb{Q})\cong \mathbb{Z}^{r(E)}\oplus E(\mathbb{Q})_{\mathrm{tors}},
$$

where the torsion subgroup is finite and $r(E)\ge 0$ is the algebraic rank. The rank measures the number of independent points of infinite order and controls whether the rational-point group is finite or infinite. It is also the algebraic quantity occurring in the Birch and Swinnerton-Dyer conjecture, which predicts equality between $r(E)$ and the order of vanishing of the Hasse–Weil $L$-function at its central point.

Descent methods convert portions of this arithmetic problem into finite computations. They typically provide upper bounds through Selmer groups, while independent rational points provide lower bounds. In favorable cases the bounds coincide. It is essential, however, to distinguish successful computations for broad classes or individual curves from an unconditional, universally terminating exact-rank algorithm. The latter is not presently known for all elliptic curves over $\mathbb{Q}$.

The contribution here is deliberately conditional and exact. Suppose an arithmetic computation supplies a finite rational presentation of the rationalized free quotient, together with a certificate that the presentation is correct and complete. Once that hypothesis is made explicit, rank computation becomes a theorem of finite-dimensional linear algebra. If there are $n$ generators and the independent relations have rank $\rho$, then precisely $n-\rho$ free rational directions remain.

This paper develops that endpoint in a self-contained fashion. Section 2 fixes the algebraic objects. Section 3 proves the matrix and quotient-dimension theorems. Section 4 transfers the result to a certified Mordell–Weil presentation. Section 5 treats parity and root numbers. Section 6 gives exact algorithms, and Section 7 supplies examples. Sections 8–10 discuss applications, limitations, and future work.

## 2. Definitions and setup

### 2.1 Elliptic curves and algebraic rank

An **elliptic curve over $\mathbb{Q}$** is a smooth projective curve of genus one equipped with a rational base point. In a short Weierstrass model it can be written

$$
E:y^2=x^3+ax+b,
$$

with $a,b\in\mathbb{Q}$ and discriminant

$$
\Delta=-16(4a^3+27b^2)\ne 0.
$$

The chord-and-tangent law makes $E(\mathbb{Q})$ an abelian group. The Mordell–Weil theorem states that this group is finitely generated. Its rank is the unique integer $r(E)$ such that

$$
E(\mathbb{Q})/E(\mathbb{Q})_{\mathrm{tors}}\cong\mathbb{Z}^{r(E)}.
$$

Tensoring with $\mathbb{Q}$ kills torsion and yields an $r(E)$-dimensional vector space:

$$
\left(E(\mathbb{Q})/E(\mathbb{Q})_{\mathrm{tors}}\right)\otimes_{\mathbb{Z}}\mathbb{Q}
\cong \mathbb{Q}^{r(E)}.
$$

Thus rank may be recovered as a rational vector-space dimension.

### 2.2 Finite rational presentations

Fix nonnegative integers $m$ and $n$, and let

$$
A\in\operatorname{Mat}_{n\times m}(\mathbb{Q}).
$$

We regard $A$ as having $m$ columns in the generator space $\mathbb{Q}^n$. The columns encode relations among $n$ generators. Let

$$
R_A=\operatorname{span}_{\mathbb{Q}}\{\text{columns of }A\}\subseteq\mathbb{Q}^n
$$

be the relation space, and define the **presented quotient**

$$
V_A=\mathbb{Q}^n/R_A.
$$

The **matrix-derived descent rank** is

$$
r_A=n-\operatorname{rank}_{\mathbb{Q}}(A).
$$

Here matrix rank means the dimension of the column span. Because $R_A$ is a subspace of $\mathbb{Q}^n$, this rank is at most $n$, so $r_A$ is a nonnegative integer.

### 2.3 Complete descent certificates

A **complete descent presentation certificate** for an elliptic curve $E$ consists, at the level needed here, of a rational matrix $A$ and a justified identification of dimensions

$$
r(E)=\dim_{\mathbb{Q}}V_A.
$$

A stronger certificate may give an explicit vector-space isomorphism between $V_A$ and the rationalized Mordell–Weil group. Such an isomorphism implies the displayed equality and is therefore sufficient.

The word “complete” is indispensable. A finite descent computation may instead provide only an upper bound or a quotient related to a Selmer group. Unless completeness is established, the matrix-derived number need not equal the exact Mordell–Weil rank.

## 3. Linear-algebraic foundation

We begin with the bound that makes the subtraction defining $r_A$ legitimate.

**Lemma 3.1 (Relation-rank bound).** Let $A$ be an $n\times m$ matrix over $\mathbb{Q}$. Then

$$
\operatorname{rank}_{\mathbb{Q}}(A)\le n.
$$

**Proof sketch.** Every column of $A$ belongs to $\mathbb{Q}^n$, and the span of the columns is therefore a subspace of an $n$-dimensional vector space. The dimension of a subspace cannot exceed the dimension of its ambient space. $\square$

**Corollary 3.2 (Generator–relation identity).** For every rational $n\times m$ matrix $A$,

$$
r_A+\operatorname{rank}_{\mathbb{Q}}(A)=n.
$$

**Proof sketch.** By definition, $r_A=n-\operatorname{rank}(A)$. Lemma 3.1 ensures that ordinary subtraction in the nonnegative integers is valid, after which the identity follows immediately. $\square$

The central quotient statement is a standard rank–nullity principle, stated here in the form required by finite presentations.

**Theorem 3.3 (Quotient rank–nullity).** For every rational $n\times m$ matrix $A$,

$$
\dim_{\mathbb{Q}}V_A+\operatorname{rank}_{\mathbb{Q}}(A)=n.
$$

**Proof sketch.** The ambient vector space $\mathbb{Q}^n$ is finite-dimensional with dimension $n$. The relation subspace $R_A$ has dimension equal to the column rank of $A$. For any subspace $R$ of a finite-dimensional vector space $V$, one has

$$
\dim(V/R)+\dim(R)=\dim(V).
$$

Apply this formula to $V=\mathbb{Q}^n$ and $R=R_A$. $\square$

**Theorem 3.4 (Correctness of the matrix-derived rank).** For every rational $n\times m$ matrix $A$,

$$
r_A=\dim_{\mathbb{Q}}V_A.
$$

**Proof sketch.** Theorem 3.3 gives $\dim V_A+\operatorname{rank}(A)=n$. Corollary 3.2 gives $r_A+\operatorname{rank}(A)=n$. Cancelling the common relation-rank term yields the result. Equivalently, solve the quotient rank–nullity identity directly for $\dim V_A$. $\square$

This theorem is invariant under elementary row operations, invertible changes of the proposed generator basis, elementary column operations, and invertible changes of the relation basis. Each such operation preserves the dimension of the column span or carries it through an ambient isomorphism. Thus the computed number depends only on the presented quotient, not on arbitrary choices of coordinates.

## 4. Certified computation of Mordell–Weil rank

We now connect the finite presentation to the arithmetic invariant.

**Theorem 4.1 (Certified Descent Rank Theorem).** Let $E/\mathbb{Q}$ be an elliptic curve. Let $A$ be a rational $n\times m$ matrix, and suppose a complete descent certificate establishes

$$
r(E)=\dim_{\mathbb{Q}}V_A.
$$

Then

$$
r(E)=r_A=n-\operatorname{rank}_{\mathbb{Q}}(A).
$$

**Proof sketch.** The certificate identifies $r(E)$ with $\dim V_A$. Theorem 3.4 identifies $\dim V_A$ with $r_A$. Transitivity of equality gives the claim. $\square$

The theorem expresses a certificate-checking paradigm. Constructing a certificate may involve global and local arithmetic, point searches, Selmer groups, heights, and descent. Once the certificate has reduced the problem to the displayed dimension equality, the final computation uses only exact linear algebra.

**Corollary 4.2 (Uniqueness across certified presentations).** Suppose $A$ and $B$ are two complete descent presentations for the same elliptic curve $E$. Then

$$
n_A-\operatorname{rank}(A)=n_B-\operatorname{rank}(B),
$$

where $n_A$ and $n_B$ are the respective numbers of generators.

**Proof sketch.** By Theorem 4.1, both sides equal $r(E)$. $\square$

This corollary is useful operationally: independently produced certificates may have different sizes and relations, but their matrix-derived ranks must agree.

## 5. Parity and root-number transport

The parity of the rank is obtained with no additional arithmetic computation.

**Theorem 5.1 (Parity Transport Theorem).** Under the hypotheses of Theorem 4.1,

$$
r(E)\text{ is even}\quad\Longleftrightarrow\quad r_A\text{ is even}.
$$

Equivalently,

$$
r(E)\equiv n-\operatorname{rank}(A)\pmod 2.
$$

**Proof sketch.** Theorem 4.1 gives equality of the two nonnegative integers. Equal integers have equal residues modulo $2$. $\square$

Let $W(E)\in\{+1,-1\}$ denote the root number in the functional equation of the completed $L$-function of $E$. The parity conjecture predicts

$$
W(E)=(-1)^{r(E)}.
$$

The next result is a transport statement, not a proof of that conjecture.

**Theorem 5.2 (Root-number formula from a certified presentation).** Assume the hypotheses of Theorem 4.1 and, additionally, assume that the parity relation

$$
W(E)=(-1)^{r(E)}
$$

holds for $E$. Then

$$
W(E)=(-1)^{r_A}=(-1)^{n-\operatorname{rank}(A)}.
$$

**Proof sketch.** Substitute the equality $r(E)=r_A$ from Theorem 4.1 into the assumed parity relation. $\square$

The assumptions have distinct roles. The presentation certificate is algebraic and identifies the rank. The parity relation links rank to an analytic sign. Neither is silently inferred from the other.

## 6. Exact algorithms

### 6.1 Rational Gaussian elimination

Given $A\in\operatorname{Mat}_{n\times m}(\mathbb{Q})$, exact Gaussian elimination computes its rank. Starting at the upper-left corner, locate a nonzero pivot in the remaining submatrix, interchange rows if necessary, normalize or retain the pivot, and eliminate its column from all other rows. Move to the next row and column until no pivot remains. The number of pivots is $\operatorname{rank}(A)$.

For dense matrices, a standard implementation uses

$$
O\bigl(nm\min(n,m)\bigr)
$$

rational arithmetic operations and $O(nm)$ storage. Rational numerators and denominators may grow during elimination. Fraction-free Bareiss elimination, modular rank computation followed by certification, or carefully normalized fractions mitigate bit growth. For the conceptual certificate checker, exact fractions are sufficient and avoid tolerance errors.

### 6.2 Certified-rank endpoint algorithm

The endpoint algorithm accepts a matrix and the external fact that its quotient dimension equals the curve’s rank. It proceeds as follows:

1. Read the $n\times m$ rational relation matrix $A$.
2. Check that all rows have the same length and parse every entry exactly.
3. Row-reduce $A$ over $\mathbb{Q}$.
4. Count pivots to obtain $\rho=\operatorname{rank}(A)$.
5. Return $r_A=n-\rho$.
6. Return “even” if $r_A$ is divisible by $2$, and “odd” otherwise.
7. If a parity relation is supplied, return the corresponding sign $(-1)^{r_A}$.

The matrix phase always terminates because each pivot strictly advances through a finite set of rows and columns. Its correctness follows from Theorems 3.4, 4.1, 5.1, and 5.2. The algorithm does not construct or validate the deeper arithmetic content of a complete descent certificate unless a separate checker for that content is supplied.

### 6.3 Independent verification through minors

For small matrices, rank can also be certified by minors. To prove $\operatorname{rank}(A)\ge k$, exhibit a nonzero $k\times k$ minor. To prove $\operatorname{rank}(A)\le k$, show that every $(k+1)\times(k+1)$ minor vanishes. This approach is combinatorially expensive but produces compact, independently checkable witnesses in modest dimensions.

## 7. Worked examples

### 7.1 A rank-two quotient

Consider

$$
A_1=
\begin{pmatrix}
1&0&1\\
0&1&1\\
1&1&2\\
0&0&0
\end{pmatrix}.
$$

The third column is the sum of the first two, and the first two columns are independent. Therefore

$$
\operatorname{rank}(A_1)=2.
$$

There are $n=4$ generators, so

$$
r_{A_1}=4-2=2.
$$

The quotient $V_{A_1}$ is two-dimensional. If $A_1$ is a complete descent presentation for $E$, then $r(E)=2$, the rank is even, and an assumed parity relation gives $W(E)=+1$.

### 7.2 A rank-one quotient with redundant relations

Let

$$
A_2=
\begin{pmatrix}
1&0&1&2\\
0&1&1&2\\
0&0&0&0
\end{pmatrix}.
$$

The first two columns are independent. The third is their sum, and the fourth is twice their sum. Hence $\operatorname{rank}(A_2)=2$. Since $n=3$,

$$
r_{A_2}=3-2=1.
$$

This example emphasizes that the number of written relations is not the number of independent relations. Four columns impose only two independent rational constraints. A complete presentation would therefore certify odd Mordell–Weil rank and, under the parity relation, root number $-1$.

### 7.3 Full relation rank

Take the $3\times 3$ identity matrix $A_3=I_3$. Its columns span all of $\mathbb{Q}^3$, so

$$
\operatorname{rank}(A_3)=3,
\qquad
r_{A_3}=0.
$$

The quotient is the zero vector space. If this presentation is complete for a curve, the curve has rank zero. Its rational-point group then consists entirely of torsion and is finite.

### 7.4 No relations

At the opposite extreme, let $A_4$ have $n$ rows and no nonzero columns. Then $R_{A_4}=\{0\}$, so

$$
\operatorname{rank}(A_4)=0,
\qquad
r_{A_4}=n.
$$

The presented quotient is simply $\mathbb{Q}^n$. This boundary case checks that the formula behaves correctly when every proposed generator survives independently.

## 8. Arithmetic interpretation and applications

The theorem is useful whenever difficult mathematics can produce a finite presentation whose completeness is checkable. In elliptic-curve descent, local conditions define finite Selmer data. Such data commonly bounds the quotient of rational points by multiplication, and therefore bounds rank. To pass from a bound to an exact presentation, one must also account for rational points and any obstruction represented by the Tate–Shafarevich group or related descent data. The matrix theorem does not erase these issues; it locates them precisely in the certificate hypothesis.

Height pairings offer another route to finite evidence. For independent points $P_1,\ldots,P_k$, the canonical-height pairing forms a Gram matrix. Nonsingularity demonstrates independence and yields a lower bound $r(E)\ge k$. Descent can supply an upper bound. When upper and lower bounds coincide, the result can be packaged as a complete rank certificate, after which the finite presentation theorem records the endpoint cleanly.

The certificate viewpoint also supports reproducibility. Search procedures can be optimized aggressively, while final evidence remains exact. Rational matrices can be exchanged without floating-point ambiguity. Different presentations may be compared by their quotient dimensions. Parity becomes a cheap consistency check: if a separately computed root number and an established parity theorem disagree with the matrix parity, at least one input certificate is invalid.

Beyond elliptic curves, the same quotient computation appears in homology, where cycles are divided by boundaries; in finitely presented modules, where generators are divided by relations; in network models, where conservation laws reduce degrees of freedom; and in linear codes, where parity constraints cut down message spaces. The arithmetic challenge is specialized, but the finite endpoint is universal.

## 8.1 Certificate anatomy and audit trail

A practical certificate should expose enough data to distinguish three layers. The first layer specifies $n$ proposed free generators and interprets vectors in $\mathbb{Q}^n$ as rational combinations of them. The second supplies relation columns and proves that each column maps to zero. The third proves completeness: every rational relation is generated by those columns, or equivalently the induced map from $V_A$ to the rationalized Mordell–Weil group is an isomorphism. Sound relations alone establish only a map out of the quotient; completeness is what makes dimensions equal.

Elementary operations provide an economical audit trail. Swapping rows corresponds to reordering generators, multiplying a row by a nonzero rational rescales a generator coordinate, and adding a multiple of one row to another changes the generator basis. Column operations reorganize the relation basis. Recording these operations allows a checker to reconstruct the reduced matrix and verify every pivot without trusting an opaque rank routine.

Exactness is especially important for rational data. Consider columns that differ by a rational number with a very large denominator. Numerically they may look identical at fixed precision while remaining linearly independent. Conversely, rounding may destroy an exact dependence. Fraction arithmetic decides whether a pivot is exactly zero and therefore returns the mathematically correct quotient dimension.

## 8.2 Stability under enlarging a presentation

Presentations are not unique, and useful algorithms often add auxiliary generators or redundant relations. If one appends a new generator together with a relation identifying it uniquely with an existing rational combination, both the number of generators and the relation rank increase by one. Their difference remains unchanged. Likewise, appending a relation already in the column span changes neither matrix rank nor quotient dimension.

**Proposition 8.1 (Stability under redundant relations).** If $B$ is obtained from $A$ by adjoining columns belonging to $R_A$, then $V_B$ and $V_A$ have the same dimension, and $r_B=r_A$.

**Proof sketch.** The old and new column spans coincide, so their dimensions coincide. The ambient generator space is unchanged, and Theorem 3.4 gives equal matrix-derived ranks. $\square$

This stability permits certificate producers to favor transparent data over minimal data. Redundancy may enlarge a file, but it cannot alter the result when handled exactly.

## 9. Scope and limitations

The principal limitation must be stated unequivocally: these results do not establish an unconditional algorithm that computes $r(E)$ for every elliptic curve over $\mathbb{Q}$. They establish exact computation **from a complete finite descent presentation**. The difference is the production and certification of that presentation.

The Mordell–Weil theorem guarantees finite generation, but a bare existence theorem does not automatically provide a terminating procedure that finds a full basis. Height theory gives finiteness below fixed bounds, but determining a sufficient bound can require information not effectively available in complete generality. Selmer computations produce finite upper bounds, yet an upper bound need not equal the true rank. Rational-point searches give lower bounds, yet failure to find another point is not proof that none exists.

Likewise, Theorem 5.2 does not establish the parity conjecture. It says that whenever the relation $W(E)=(-1)^{r(E)}$ is known or assumed, an exact certified rank presentation permits substitution of the computable matrix-derived rank. This logical modularity is a strength: it prevents conditional arithmetic claims from being hidden inside unconditional linear algebra.

## 10. Future directions

Several developments would extend the certificate pipeline. First, an executable fraction-free row-reduction routine should return both a pivot count and a compact trace that can be checked independently. Second, a presentation certificate can be enriched with proposed rational points, relations, and explicit maps between the matrix quotient and the rationalized Mordell–Weil group.

Third, one can develop the height machinery needed for finite generation and generator searches: naive and canonical heights, quadraticity, bounded differences, the height pairing, and Northcott finiteness. Fourth, concrete $2$-descent for curves with full rational $2$-torsion offers a tractable setting in which square classes and local conditions can be represented explicitly. Fifth, the exact termination hypothesis under which Selmer upper bounds and point-generated lower bounds must meet should be isolated rather than presumed.

Finally, the root-number statement should be specialized from an abstract sign transport to the local and global root numbers of elliptic curves. This would provide a transparent interface among descent certificates, exact matrix rank, rank parity, and analytic functional equations.

## 11. Conclusion

A complete finite presentation turns Mordell–Weil rank into quotient dimension. For a rational relation matrix $A$ with $n$ rows, the quotient by its column span has dimension

$$
n-\operatorname{rank}_{\mathbb{Q}}(A).
$$

If a descent certificate identifies this quotient with the rationalized free part of $E(\mathbb{Q})$, the same expression is the exact algebraic rank. Its parity is immediate, and any available root-number parity relation becomes an explicit sign formula.

The mathematical message is a separation of concerns. Exact Gaussian elimination completely solves the finite endpoint. The unresolved general challenge lies in constructing, for every elliptic curve, a terminating and complete arithmetic certificate. Stating that boundary precisely yields a useful theorem, a reliable computational pipeline, and a clear agenda for further work.
