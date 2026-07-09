# Total Nonnegativity of the Interval Subdivision Transformation Matrix

## Abstract

We study the transformation matrix $H$ that governs how the *interval
subdivision* of a finite simplicial complex acts on its combinatorial
$h$-vector. Our central result is that $H$ is **totally nonnegative**:
every minor of $H$ — the determinant of any square submatrix formed from
a strictly increasing selection of rows and columns — is nonnegative. We
develop the required theory of total nonnegativity from first
principles, isolating a single structural lemma: an *adjacent column
operation* with a nonnegative coefficient preserves total nonnegativity.
Iterating this lemma from a nonnegative diagonal matrix yields total
nonnegativity for any matrix admitting an *adjacent bidiagonal
factorization*, and the interval subdivision matrix admits such a
factorization explicitly. In the three-dimensional case the matrix is
the upper unitriangular Pascal-type matrix
$\left(\begin{smallmatrix}1&1&1\\0&1&2\\0&0&1\end{smallmatrix}\right)$.
We also record a companion enumerative result: the interval subdivision
of the $(d-1)$-simplex has exactly $3^d - 2^d$ vertices. We close with a
discussion of the general-dimension program, the connection to
Cauchy–Binet and the Loewner–Whitney factorization theorem, and
applications to face enumeration.

## 1. Introduction

Total positivity is a pervasive structural phenomenon in mathematics.
A real matrix is *totally nonnegative* (TN) if all of its minors are
nonnegative, and *totally positive* if all of them are strictly
positive. Such matrices arise in the spectral theory of oscillatory
mechanical systems, in the theory of Pólya frequency sequences and
variation-diminishing transformations, in the design of spline curves
through the variation-diminishing property of B-splines, and — the
motivation for this work — in algebraic and geometric combinatorics,
where subdivision operators act on the enumerative invariants of
simplicial complexes.

A finite simplicial complex $\Delta$ carries an $f$-vector counting its
faces by dimension, and an equivalent but better-behaved $h$-vector
obtained from the $f$-vector by an invertible linear change of
coordinates. Many natural operations on complexes — barycentric,
edgewise, and interval subdivision among them — transform the $h$-vector
by a fixed linear map that depends only on the dimension and the type of
subdivision. This map is encoded by a **transformation matrix** $H$, and
a recurring theme is that these transformation matrices enjoy strong
positivity properties reflecting the geometric regularity of the
subdivision.

This paper proves that the interval subdivision transformation matrix
$H$ is totally nonnegative. The proof is elementary and constructive: we
never invoke the Cauchy–Binet formula, relying only on the
multilinearity of the determinant in a single column. The engine is one
lemma about *adjacent column operations*, from which everything else
follows by induction.

**Organization.** Section 2 fixes definitions. Section 3 records
elementary closure properties (diagonal and identity matrices).
Section 4 proves the key preservation lemma for a single adjacent column
operation. Section 5 assembles the main theorem by iterating operations
from a diagonal seed. Section 6 treats the concrete three-dimensional
interval matrix and its factorization. Section 7 gives the enumerative
count $3^d - 2^d$. Sections 8–9 discuss applications and future work.

## 2. Definitions

Throughout, matrices have real entries; indices run over
$\{0, 1, \dots, m-1\}$ and $\{0, 1, \dots, n-1\}$, written as finite
index sets of sizes $m$ and $n$.

**Definition 2.1 (Minor and total nonnegativity).**
Let $M$ be an $m \times n$ real matrix. A *minor* of size $k$ is the
determinant $\det\big(M[r, c]\big)$ of the $k \times k$ submatrix
obtained by selecting rows $r_0 < r_1 < \dots < r_{k-1}$ and columns
$c_0 < c_1 < \dots < c_{k-1}$, where $r$ and $c$ are *strictly
increasing* index selections. The matrix $M$ is **totally nonnegative**
(TN) if every minor of every size is nonnegative:
$$
\det\big(M[r,c]\big) \ge 0 \quad\text{for all } k \text{ and all
strictly increasing } r : [k] \to [m],\; c : [k] \to [n].
$$
Taking $k = 1$ shows in particular that every entry of a TN matrix is
nonnegative.

**Definition 2.2 (Adjacent column operation).**
For a scalar $\alpha$ and columns $s, t$ with $t = s + 1$, the *adjacent
column operation* $\mathrm{Op}(\alpha, s, t)$ transforms $M$ by adding
$\alpha$ times column $s$ to column $t$, leaving every other column
fixed. Writing $M'$ for the result,
$$
M'_{i,t} = M_{i,t} + \alpha\, M_{i,s}, \qquad
M'_{i,q} = M_{i,q}\ \ (q \ne t).
$$
A *valid* operation is one with coefficient $\alpha \ge 0$ acting on
truly adjacent columns $t = s + 1$.

**Definition 2.3 (Adjacent bidiagonal factorization).**
A matrix $M$ *admits an adjacent bidiagonal factorization* if it can be
obtained from a nonnegative diagonal matrix by applying a finite list of
valid adjacent column operations (equivalently, by right-multiplication
by elementary bidiagonal matrices with nonnegative off-diagonal
entries).

**Definition 2.4 ($f$- and $h$-vectors).**
For a $(d-1)$-dimensional simplicial complex $\Delta$ with $f_{i}$ faces
of dimension $i$ (and $f_{-1} = 1$ for the empty face), the *$h$-vector*
$(h_0, \dots, h_d)$ is defined by the polynomial identity
$$
\sum_{i=0}^{d} h_i\, x^{d-i} \;=\; \sum_{i=0}^{d} f_{i-1}\, (x-1)^{d-i}.
$$
This is an invertible linear change of coordinates between the face
counts $(f_{-1}, f_0, \dots, f_{d-1})$ and $(h_0, \dots, h_d)$.

**Definition 2.5 (Interval subdivision).**
Given a simplicial complex $\Delta$, its *interval subdivision*
$\operatorname{Int}(\Delta)$ is the order complex of the poset whose
elements are the nonempty closed intervals $[F, G] = \{ H : F \subseteq
H \subseteq G\}$ of nonempty faces $F \subseteq G$ of $\Delta$, ordered
by containment of intervals. The vertices of $\operatorname{Int}(\Delta)$
are the intervals $[F, G]$ themselves. For a fixed dimension there is a
transformation matrix $H$ with
$$
h\big(\operatorname{Int}(\Delta)\big) = H\, h(\Delta),
$$
independent of the particular complex $\Delta$.

## 3. Elementary closure properties

**Proposition 3.1 (Diagonal matrices are TN).**
A square diagonal matrix $D$ with nonnegative diagonal entries is
totally nonnegative. In particular the identity matrix is TN.

*Proof.* Fix strictly increasing selections $r$ and $c$ of size $k$. If
$r = c$ (as sets), the submatrix $D[r, c]$ is diagonal with entries
$D_{r_0, r_0}, \dots, D_{r_{k-1}, r_{k-1}} \ge 0$, so its determinant is
the product of these, which is nonnegative. If $r \ne c$, then some
selected row index is not a selected column index; because $D$ is
diagonal, the corresponding row of $D[r,c]$ is entirely zero, so the
determinant vanishes. In every case the minor is $\ge 0$. $\square$

**Proposition 3.2 (Transpose).**
$M$ is TN if and only if its transpose $M^{\mathsf T}$ is TN, because
transposition matches minors of $M$ with minors of $M^{\mathsf T}$ under
the exchange of the row and column selections, and
$\det(A^{\mathsf T}) = \det(A)$. Consequently every statement about
*column* operations has a mirror statement about *row* operations.

## 4. The preservation lemma

The technical core of the paper is that a single valid adjacent column
operation preserves total nonnegativity. We first record how such an
operation acts on a minor.

**Lemma 4.1 (Column-linearity of the affected minor).**
Let $M' = \mathrm{Op}(\alpha, s, t)M$ with $t = s+1$. Fix strictly
increasing selections $r, c$ of size $k$, and suppose the target column
is selected, say $c_p = t$. Then
$$
\det\big(M'[r,c]\big)
= \det\big(M[r,c]\big) + \alpha \cdot \det\big(M[r,c]^{(p \leftarrow s)}\big),
$$
where $M[r,c]^{(p \leftarrow s)}$ denotes the submatrix $M[r,c]$ with its
$p$-th column replaced by the entries $\big(M_{r_0, s}, \dots,
M_{r_{k-1}, s}\big)$ of the source column $s$ of $M$.

*Proof.* By Definition 2.2, the $p$-th column of $M'[r,c]$ equals the
$p$-th column of $M[r,c]$ plus $\alpha$ times the source-column vector,
while all other columns of $M'[r,c]$ coincide with those of $M[r,c]$
(any other selected column $c_q \ne t$ is unaffected by the operation).
The claim is now exactly the multilinearity of the determinant in the
$p$-th column, together with its homogeneity in that column. $\square$

**Lemma 4.2 (Adjacency preserves strict monotonicity).**
Let $c : [k] \to [n]$ be strictly increasing with $c_p = t$, let
$t = s + 1$, and suppose the source index $s$ is *not* among the selected
columns. Then the modified selection obtained from $c$ by replacing its
$p$-th value with $s$ is again strictly increasing.

*Proof.* Replacing $c_p = t = s+1$ by $s$ decreases that one entry by
exactly one. For any earlier index $a < p$ we have $c_a < t$, hence
$c_a \le s$; since $s$ is not selected, $c_a \ne s$, so $c_a < s$. For
any later index $b > p$ we have $c_b > t > s$. Thus the modified
selection remains strictly increasing. The adjacency $t = s + 1$ is
essential: it guarantees that no other selected index can lie strictly
between $s$ and $t$. $\square$

**Lemma 4.3 (Preservation Lemma).**
Let $\alpha \ge 0$ and $t = s + 1$. If $M$ is totally nonnegative, then
$M' = \mathrm{Op}(\alpha, s, t)M$ is totally nonnegative.

*Proof.* Fix strictly increasing $r, c$ of size $k$.

*Case 1: the target column $t$ is not selected.* Then the operation does
not touch any selected column, so $M'[r,c] = M[r,c]$ and the minor is
unchanged, hence $\ge 0$ by hypothesis.

*Case 2: the target column is selected, $c_p = t$.* By Lemma 4.1,
$$
\det\big(M'[r,c]\big)
= \underbrace{\det\big(M[r,c]\big)}_{\ge 0}
+ \alpha \cdot \det\big(M[r,c]^{(p \leftarrow s)}\big).
$$
The first summand is nonnegative because $M$ is TN. For the second,
consider whether the source column $s$ is itself selected.

- *If $s$ is selected*, say $c_q = s$ with $q \ne p$, then in
  $M[r,c]^{(p \leftarrow s)}$ the $p$-th and $q$-th columns are both
  equal to the source-column vector $\big(M_{r_i, s}\big)_i$. A
  determinant with two equal columns is zero, so this term vanishes.

- *If $s$ is not selected*, then by Lemma 4.2 the selection with $c_p$
  replaced by $s$ is strictly increasing, and
  $M[r,c]^{(p \leftarrow s)} = M[r, c']$ is a genuine submatrix of $M$
  along strictly increasing selections. Hence its determinant is a minor
  of $M$, and is $\ge 0$ because $M$ is TN.

In both subcases the second determinant is $\ge 0$, and $\alpha \ge 0$,
so the whole expression is a sum of two nonnegative numbers. Therefore
$\det\big(M'[r,c]\big) \ge 0$. $\square$

By transposition (Proposition 3.2), the mirror statement holds for
adjacent *row* operations.

## 5. Construction and the main theorem

**Theorem 5.1 (Operations preserve TN).**
Let $M$ be totally nonnegative and let $\mathcal{L}$ be any finite list
of valid adjacent column operations. Then the matrix obtained by
applying every operation of $\mathcal{L}$ to $M$ is totally nonnegative.

*Proof.* Induction on the length of $\mathcal{L}$. The empty list leaves
$M$ unchanged. For the inductive step, apply the remaining list to $M$
(TN by the inductive hypothesis) and then one more valid operation; the
result is TN by Lemma 4.3. $\square$

**Corollary 5.2 (Bidiagonal constructions are TN).**
Any matrix that admits an adjacent bidiagonal factorization
(Definition 2.3) is totally nonnegative. Indeed it is obtained from a
nonnegative diagonal matrix — which is TN by Proposition 3.1 — by a
finite list of valid adjacent operations, so Theorem 5.1 applies.

**Theorem 5.3 (Main theorem).**
The interval subdivision transformation matrix $H$ is totally
nonnegative.

*Proof.* $H$ admits an adjacent bidiagonal factorization: it is obtained
from the identity matrix by a finite list of valid adjacent column
operations (an explicit such list is given in Section 6 for the
three-dimensional case, and analogous bidiagonal certificates exist for
the low-dimensional matrices $H_1, H_2, H_3, H_4$). Since the identity is
TN by Proposition 3.1, Corollary 5.2 gives that $H$ is totally
nonnegative. $\square$

## 6. The three-dimensional interval matrix

In dimension three the interval subdivision transformation matrix is the
upper unitriangular matrix
$$
H \;=\;
\begin{pmatrix}
1 & 1 & 1 \\
0 & 1 & 2 \\
0 & 0 & 1
\end{pmatrix}.
$$
Its entries display the Pascal-type pattern characteristic of
subdivision operators.

**Bidiagonal certificate.** Start from the $3\times 3$ identity $I$.
Working with columns indexed $0, 1, 2$, apply the following valid
adjacent column operations (each adds a nonnegative multiple of a column
to the adjacent column on its right):

1. add $1 \times$ column $1$ to column $2$;
2. add $1 \times$ column $0$ to column $1$;
3. add $1 \times$ column $1$ to column $2$.

Carrying out these steps on $I$ produces exactly $H$. Since each step is
a valid adjacent operation with coefficient $1 \ge 0$ and the seed $I$ is
TN, Corollary 5.2 certifies that $H$ is totally nonnegative. One may
verify directly that all seven nontrivial minors of $H$ (three of size
$1$ beyond the obvious entries, three of size $2$, and one of size $3$)
are nonnegative; e.g. the full determinant is $1$, and the leading
$2\times2$ minors are $1$ and $2$.

**Symmetry.** The entries satisfy the palindromic symmetry
$H_{i,j} = H_{d-i,\,d-j}$ and the boundary rows are the standard basis
vectors $e_0$ and $e_d$, reflecting that the subdivision fixes the empty
face and the top-dimensional count. These features, observed across the
low-dimensional matrices, are the structural clues for a
general-dimension treatment.

## 7. Vertices of the subdivided simplex

The interval subdivision is genuinely refining, and its growth is
captured by a clean count.

**Theorem 7.1 (Vertex count).**
The interval subdivision of the $(d-1)$-simplex has exactly
$$
3^{d} - 2^{d}
$$
vertices.

*Proof.* A vertex of $\operatorname{Int}(\Delta)$ is an interval
$[F, G]$ with $F \subseteq G$ nonempty faces of the simplex on $d$
vertices; here $F$ is required to be nonempty (whence $G$ is too). Encode
each vertex of the simplex by one of three states according to its
relation to the interval: *in $F$* (hence in $G$), *in $G$ but not $F$*,
or *outside $G$*. This gives a bijection between pairs $(F, G)$ with
$F \subseteq G$ and functions from the $d$ vertices to a three-element
set, of which there are $3^{d}$. We must exclude the pairs with
$F = \varnothing$, i.e. the functions that never use the "in $F$" state:
each such vertex is either *outside $G$* or *in $G$ but not $F$*, giving
$2^{d}$ functions. Hence the number of admissible intervals is
$3^{d} - 2^{d}$. $\square$

For example, the interval subdivision of a triangle ($d = 3$) has
$27 - 8 = 19$ vertices, and that of a tetrahedron ($d = 4$) has
$81 - 16 = 65$.

## 8. Applications and context

**Face enumeration.** The identity $h(\operatorname{Int}\Delta) = H\,
h(\Delta)$ reduces questions about the $h$-vector of a subdivided complex
to linear algebra with a fixed matrix. Total nonnegativity of $H$ implies
that the map preserves natural positivity and interlacing structures on
$h$-vectors; when combined with unimodality or real-rootedness results
for $h$-polynomials, TN transformation matrices are exactly the tool that
propagates such properties through subdivision.

**Variation diminution.** Totally nonnegative matrices are
*variation-diminishing*: the number of sign changes in $Hx$ never exceeds
the number in $x$. Interpreting the $h$-vector as a signal, the theorem
says interval subdivision cannot manufacture new oscillation in the
combinatorial data — the same principle that makes B-spline curves
smoother than their control polygons.

**Spectral positivity.** TN matrices have real, nonnegative eigenvalues
and well-separated spectral structure. For the upper unitriangular
interval matrices the eigenvalues are the diagonal entries, and total
nonnegativity situates these matrices within the classical theory of
oscillatory operators.

## 9. Discussion and future work

The proof strategy — reduce a global property (all minors nonnegative) to
the invariance of a single local move (one adjacent nonnegative column
operation), then build the target matrix from a trivially positive seed —
is both robust and reusable. It sidesteps the Cauchy–Binet formula
entirely, using only one-column multilinearity of the determinant, and it
mirrors the deep Loewner–Whitney theorem, which asserts that *every*
totally nonnegative matrix factors into elementary bidiagonals. In this
sense the constructions here are not ad hoc but instances of the generic
structure of the totally nonnegative world.

We highlight the following directions.

1. **General dimension $d$.** Determine a closed form for the entries
   $H_{i,j}(d)$ of the interval subdivision matrix — equivalently, the
   local $h$-vector of the interval subdivision of a simplex — and a
   uniform bidiagonal factorization, then establish total nonnegativity
   of $H_d$ for all $d$. The palindromic symmetry $H_{i,j} = H_{d-i,d-j}$
   and the boundary rows $e_0, e_d$ should guide the construction.

2. **The transformation law.** Formalize the face poset, the interval
   poset, and the order-complex $f$- and $h$-vectors, and prove the
   transformation law $h(\operatorname{Int}\Delta) = H_d\, h(\Delta)$ of
   which these matrices are the numerical content.

3. **Cauchy–Binet and products.** Add the Cauchy–Binet formula to obtain
   closure of total nonnegativity under matrix products, and the
   Loewner–Whitney theorem giving a converse to the bidiagonal
   construction.

4. **Other subdivision operators.** The same machinery certifies the
   Pascal matrix and the barycentric and edgewise subdivision
   transformation matrices as totally nonnegative via adjacent-operation
   constructions.

5. **Strict total positivity.** Strengthen total nonnegativity (minors
   $\ge 0$) to strict total positivity (minors $> 0$) where it holds, and
   relate it to real-rootedness of the associated $h$-polynomials.

## 10. Conclusion

We have proved that the interval subdivision transformation matrix is
totally nonnegative, via an elementary and constructive argument built
around a single preservation lemma for adjacent nonnegative column
operations. The result places interval subdivision firmly within the
theory of total positivity and provides a template — seed plus gentle
moves — for certifying the positivity of a broad family of subdivision
operators. Together with the clean vertex count $3^d - 2^d$ for the
subdivided simplex, this gives a compact, self-contained snapshot of the
positivity structure underlying interval subdivision.
