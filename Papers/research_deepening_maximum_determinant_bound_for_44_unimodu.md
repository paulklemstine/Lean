# Extremal Determinants of $4 \times 4$ Integer Matrices with Bounded Entries

## Abstract

We study the maximal determinant problem for $4 \times 4$ integer matrices whose
entries lie in a symmetric range $\{-B, \dots, B\}$. We give an explicit
construction — a scaled order-$4$ Hadamard matrix — whose entries are all $\pm B$,
whose rows are mutually orthogonal, and whose determinant equals $16\,B^4$. Using
the Leibniz expansion of the determinant we establish the universal permutation
bound $|\det A| \le 24\,B^4$ for every admissible matrix. Together these results
bracket the maximum determinant $M(B)$ as $16\,B^4 \le M(B) \le 24\,B^4$, with the
lower bound attained. We further prove that the orthogonality relation
$A A^{\mathsf T} = 4B^2 I$ serves as an algebraic certificate forcing
$(\det A)^2 = (4B^2)^4$, and we identify the exact value $M(B) = 16\,B^4$,
observing that closing the bracket from $24$ to $16$ is exactly the content of the
Hadamard determinant inequality. Finally, we rigorously refute a previously
circulated candidate formula: the expression $(2k-1)^4 - 2(2k-1)^2 + 1$, once
proposed as the maximum over the odd-radius range $\{-(2k-1), \dots, 2k-1\}$, is
not even an upper bound — for every $k \ge 1$ the explicit construction already
exceeds it, and at $k = 1$ the formula evaluates to $0$ while the true maximum is
$16$.

**Keywords:** maximal determinant problem, Hadamard matrix, bounded-entry
matrices, Leibniz permutation bound, orthogonal rows, determinant inequalities.

---

## 1. Introduction

Given a bound $B \ge 0$, consider the family of integer matrices whose entries
all lie in the symmetric range $\{-B, -B+1, \dots, B-1, B\}$. A basic extremal
question asks: over this family, how large can the determinant be? This is a
finite-order instance of the classical **maximal determinant problem**, whose
history stretches back to Hadamard's work of the 1890s and which remains open in
general because of its intimate link to the existence of Hadamard matrices.

We focus on order $4$. This is the smallest order at which a Hadamard matrix
exists beyond the trivial cases, and hence the first order at which the maximal
determinant problem displays its characteristic structure. Our contributions are:

1. **An explicit extremal construction** (Section 3): a scaled order-$4$ Hadamard
   matrix $H(B)$ with all entries $\pm B$, mutually orthogonal rows, and
   determinant exactly $16\,B^4$.
2. **A universal upper bound** (Section 4): every admissible matrix satisfies
   $|\det A| \le 24\,B^4$, via the Leibniz permutation expansion, itself a
   specialisation of the general order-$n$ estimate $|\det A| \le n!\,B^n$.
3. **A rigorous bracket** (Section 5): $16\,B^4 \le M(B) \le 24\,B^4$, with the
   lower end attained; we identify the exact value $M(B) = 16\,B^4$ and locate
   the remaining analytic input (Hadamard's inequality) precisely.
4. **A refutation** (Section 6): the circulated candidate
   $(2k-1)^4 - 2(2k-1)^2 + 1$ for the odd-radius range is false — it is not even
   an upper bound — with a concrete counterexample for every $k \ge 1$.

Throughout, $A^{\mathsf T}$ denotes the transpose of $A$, $I$ the $4 \times 4$
identity matrix, and $\det A$ the determinant. We index rows and columns by
$\{0,1,2,3\}$.

---

## 2. Preliminaries and definitions

**Definition 2.1 (Admissible family).** For $B \ge 0$, a matrix
$A \in \mathbb{Z}^{4 \times 4}$ is *$B$-admissible* if $|A_{ij}| \le B$ for all
$i, j$. Write $\mathcal{A}(B)$ for the set of $B$-admissible matrices and define
the maximum determinant
$$
M(B) := \max_{A \in \mathcal{A}(B)} \det A.
$$
The maximum is well defined: $\mathcal{A}(B)$ is finite and nonempty.

**Definition 2.2 (Cofactor expansion).** For a $4 \times 4$ matrix $M$ over a
commutative ring, the determinant expands along the first row as
$$
\begin{aligned}
\det M
&= M_{00}\big(M_{11}(M_{22}M_{33} - M_{23}M_{32}) - M_{12}(M_{21}M_{33} - M_{23}M_{31}) + M_{13}(M_{21}M_{32} - M_{22}M_{31})\big) \\
&\quad - M_{01}\big(M_{10}(M_{22}M_{33} - M_{23}M_{32}) - M_{12}(M_{20}M_{33} - M_{23}M_{30}) + M_{13}(M_{20}M_{32} - M_{22}M_{30})\big) \\
&\quad + M_{02}\big(M_{10}(M_{21}M_{33} - M_{23}M_{31}) - M_{11}(M_{20}M_{33} - M_{23}M_{30}) + M_{13}(M_{20}M_{31} - M_{21}M_{30})\big) \\
&\quad - M_{03}\big(M_{10}(M_{21}M_{32} - M_{22}M_{31}) - M_{11}(M_{20}M_{32} - M_{22}M_{30}) + M_{12}(M_{20}M_{31} - M_{21}M_{30})\big).
\end{aligned}
$$
This is the concrete form of the Leibniz sum we use for the explicit
computations below.

**Geometric interpretation.** Writing the rows of $A$ as vectors
$r_0, r_1, r_2, r_3 \in \mathbb{R}^4$, the quantity $|\det A|$ is the
$4$-dimensional volume of the parallelepiped they span. Two structural facts
follow. First, each edge length $\|r_i\|$ is maximized, at $\|r_i\| = 2B$, when
every entry of $r_i$ is $\pm B$, since
$\|r_i\|^2 = \sum_j A_{ij}^2 \le 4B^2$. Second, for edges of fixed length the
volume is maximized when they are mutually orthogonal. These two observations
predict a maximum volume of $(2B)^4 = 16\,B^4$; the rest of the paper makes this
prediction rigorous and exhibits an integer matrix that attains it.

---

## 3. The extremal construction

**Definition 3.1 (Scaled Hadamard matrix).** For $B \in \mathbb{Z}$ define
$$
H(B) :=
\begin{pmatrix}
 B & B & B & B \\
 B & -B & B & -B \\
 B & B & -B & -B \\
 B & -B & -B & B
\end{pmatrix}.
$$

**Proposition 3.2 (Entries).** Every entry of $H(B)$ satisfies
$|H(B)_{ij}| = |B|$. In particular, if $B \ge 0$ then $H(B) \in \mathcal{A}(B)$.

*Proof.* Each of the sixteen entries is $+B$ or $-B$, so its absolute value is
$|B|$. For $B \ge 0$ this equals $B$, so $|H(B)_{ij}| \le B$ and $H(B)$ is
$B$-admissible. $\qquad\blacksquare$

**Theorem 3.3 (Orthogonality certificate).** The rows of $H(B)$ are mutually
orthogonal and of equal squared length $4B^2$; equivalently,
$$
H(B)\, H(B)^{\mathsf T} = 4B^2 \, I.
$$

*Proof.* The $(i,j)$ entry of $H(B)H(B)^{\mathsf T}$ is the dot product of rows
$i$ and $j$ of $H(B)$. For $i = j$ this is $B^2 + B^2 + B^2 + B^2 = 4B^2$. For
$i \ne j$ a direct check gives $0$; for instance rows $0$ and $1$ give
$B^2 - B^2 + B^2 - B^2 = 0$, and the remaining five off-diagonal pairs cancel
identically. Hence $H(B)H(B)^{\mathsf T} = 4B^2 I$. $\qquad\blacksquare$

**Theorem 3.4 (Extremal determinant).** $\det H(B) = 16\,B^4$.

*Proof.* Expanding via the cofactor formula of Definition 2.2 and simplifying
yields $16\,B^4$ directly. Alternatively, the orthogonality certificate gives an
illuminating derivation: since $\det(XY) = \det X \det Y$ and
$\det X^{\mathsf T} = \det X$,
$$
(\det H(B))^2 = \det H(B) \cdot \det H(B)^{\mathsf T}
= \det\!\big(H(B) H(B)^{\mathsf T}\big) = \det(4B^2 I) = (4B^2)^4 = 256\,B^8,
$$
so $|\det H(B)| = 16\,B^4$; the direct expansion fixes the sign as $+$.
$\qquad\blacksquare$

**Remark 3.5 (Scaling).** Determinants of order $4$ scale as the fourth power of a
scalar multiple: $\det(c \cdot M) = c^4 \det M$. Since
$H(B) = B \cdot H(1)$ and $\det H(1) = 16$, this recovers
$\det H(B) = 16\,B^4$ and makes explicit that the entire family is generated by
scaling the primitive $\pm 1$ Hadamard matrix.

---

## 4. Upper bounds via the permutation expansion

**Theorem 4.1 (Leibniz bound, general order).** Let $A$ be an $n \times n$ integer
matrix with $|A_{ij}| \le B$ for all $i, j$. Then
$$
|\det A| \le n! \, B^n.
$$

*Proof.* By the Leibniz formula,
$\det A = \sum_{\sigma \in S_n} \operatorname{sgn}(\sigma) \prod_{i} A_{i\,\sigma(i)}$.
The sum has $n!$ terms; each product of $n$ entries has absolute value at most
$B^n$. The triangle inequality gives
$|\det A| \le \sum_{\sigma} \prod_i |A_{i\,\sigma(i)}| \le n! \, B^n$.
$\qquad\blacksquare$

**Corollary 4.2 (Order-$4$ permutation bound).** Every $B$-admissible
$4 \times 4$ matrix $A$ satisfies
$$
|\det A| \le 24 \, B^4, \qquad \text{hence} \qquad \det A \le 24\,B^4.
$$

*Proof.* Apply Theorem 4.1 with $n = 4$, using $4! = 24$; the one-sided bound
follows from $\det A \le |\det A|$. $\qquad\blacksquare$

The permutation bound is genuinely valid but not tight: it treats all $24$
signed products as if they could simultaneously attain magnitude $B^4$ with a
common sign, which the alternating structure of the determinant never permits.
Section 5 records the sharp value and isolates the additional input needed to
reach it.

---

## 5. The maximum, bracketed and identified

**Theorem 5.1 (Lower bound on the maximum).** For $B \ge 0$ there exists a
$B$-admissible matrix of determinant $16\,B^4$; hence $M(B) \ge 16\,B^4$.

*Proof.* Take $A = H(B)$. By Proposition 3.2 it is $B$-admissible, and by
Theorem 3.4 its determinant is $16\,B^4$. $\qquad\blacksquare$

**Theorem 5.2 (Upper bound on the maximum).** For every $B \ge 0$,
$M(B) \le 24\,B^4$.

*Proof.* Immediate from Corollary 4.2 applied to the maximizer. $\qquad\blacksquare$

**Theorem 5.3 (Bracket).** For $B \ge 0$,
$$
16\,B^4 \;\le\; M(B) \;\le\; 24\,B^4,
$$
and the lower end is attained by the explicit matrix $H(B)$.

*Proof.* Combine Theorems 5.1 and 5.2. $\qquad\blacksquare$

**Theorem 5.4 (Exact value).** In fact $M(B) = 16\,B^4$.

*Sketch.* The lower bound is Theorem 5.1. For the matching upper bound, set
$G = A A^{\mathsf T}$. Then $G$ is positive semidefinite with diagonal entries
$G_{ii} = \|r_i\|^2 = \sum_j A_{ij}^2 \le 4B^2$. The Hadamard determinant
inequality for positive-semidefinite matrices states
$\det G \le \prod_i G_{ii}$, whence
$$
(\det A)^2 = \det G \le \prod_{i=0}^{3} G_{ii} \le (4B^2)^4 = 256\,B^8,
$$
so $|\det A| \le 16\,B^4$. Equality forces each $G_{ii} = 4B^2$ (all entries
$\pm B$) and $G$ diagonal (orthogonal rows) — exactly the scaled Hadamard
condition. $\qquad\blacksquare$

**Remark 5.5 (Where the gap lives).** The elementary permutation argument yields
only $24\,B^4$; sharpening it to $16\,B^4$ is precisely the Hadamard determinant
inequality (equivalently the Hadamard–Fischer inequality), a genuine analytic
input rather than mere term-counting. The construction of Section 3 already tells
us the answer is $16\,B^4$; the bracket of Theorem 5.3 traps it rigorously with
elementary means, and Theorem 5.4 pins it down.

---

## 6. Refuting the circulated formula

A candidate closed form had been circulated for a variant of the problem in which
entries are restricted to the *odd-radius* range $\{-(2k-1), \dots, 2k-1\}$ for a
positive integer $k$. The claim was that the maximum determinant equals
$$
C(k) := (2k-1)^4 - 2(2k-1)^2 + 1 = \big((2k-1)^2 - 1\big)^2.
$$
We show this is false in the strongest sense: $C(k)$ is not even an upper bound.

**Theorem 6.1 (Strict refutation for all $k$).** For every integer $k \ge 1$,
$$
C(k) = (2k-1)^4 - 2(2k-1)^2 + 1 \;<\; 16\,(2k-1)^4.
$$

*Proof.* Write $t = 2k-1 \ge 1$. The inequality reads
$t^4 - 2t^2 + 1 < 16\,t^4$, i.e. $0 < 15\,t^4 + 2t^2 - 1$. Since $t \ge 1$ we have
$15t^4 \ge 15$ and $2t^2 \ge 2$, so $15t^4 + 2t^2 - 1 \ge 16 > 0$.
$\qquad\blacksquare$

Because $H(2k-1)$ is $(2k-1)$-admissible with determinant $16\,(2k-1)^4$
(Theorems 3.4 and 5.1), Theorem 6.1 exhibits an admissible matrix whose
determinant strictly exceeds $C(k)$ for every $k$. Thus $C(k)$ fails to bound the
family — it is not merely an inaccurate value of the maximum but not an upper
bound at all.

**Theorem 6.2 (Order-of-magnitude failure at $k=1$).** For the range
$\{-1, 0, 1\}$ (i.e. $k = 1$), the circulated formula gives $C(1) = 0$, yet there
exists an admissible matrix of determinant $16$.

*Proof.* $C(1) = 1 - 2 + 1 = 0$. The matrix $H(1)$, all of whose entries are
$\pm 1$, is $1$-admissible and has determinant $16 > 0$. $\qquad\blacksquare$

A predicted maximum of $0$ would assert that every $\{-1,0,1\}$-valued
$4 \times 4$ matrix is singular; the single matrix $H(1)$ refutes this outright.

**Theorem 6.3 (Odd-radius bracket).** For every $k \ge 1$, over the range
$\{-(2k-1), \dots, 2k-1\}$ there is an admissible matrix of determinant
$16\,(2k-1)^4$, and every admissible matrix has determinant at most
$24\,(2k-1)^4$. Hence the true maximum lies in
$[16\,(2k-1)^4, \, 24\,(2k-1)^4]$ — well above the circulated $C(k)$.

*Proof.* Apply Theorem 5.3 with $B = 2k-1 \ge 1$. $\qquad\blacksquare$

---

## 7. Applications

Scaled Hadamard matrices are not merely extremal curiosities; the same
orthogonality that maximizes the determinant makes them central to several
applied disciplines.

- **Error-correcting codes.** Rows of a Hadamard matrix, read as $\pm 1$
  codewords, are maximally dissimilar, giving codes with large minimum distance.
  Hadamard codes were used in deep-space telemetry for early planetary missions.
- **Signal processing.** The Walsh–Hadamard transform is a fast, multiplication-
  free orthogonal transform used in image and video compression and in
  spread-spectrum communication.
- **Statistical design of experiments.** Hadamard matrices generate optimal
  two-level factorial and Plackett–Burman designs, balancing factors so that
  parameter estimates have minimum variance — a $D$-optimality property that is
  exactly the maximal-determinant condition.

The order-$4$ analysis here is the base case that anchors all of these: it is the
smallest nontrivial size at which the extremal object exists.

---

## 8. Discussion and future work

Our results give a complete elementary account of the order-$4$ maximal
determinant problem on a symmetric integer range: an explicit extremiser, an
elementary two-sided bracket, the exact value, and a refutation of a circulated
formula. Several natural directions extend this work.

**1. Close the bracket to the exact value $16\,B^4$.** *Conjecture:* Every
$4 \times 4$ real matrix with $|A_{ij}| \le B$ satisfies $|\det A| \le 16\,B^4$,
with equality exactly for the scaled Hadamard matrices. The route is via
$(\det A)^2 = \det(A A^{\mathsf T})$, where $G = A A^{\mathsf T}$ is
positive-semidefinite with $G_{ii} \le 4B^2$; the Hadamard–Fischer inequality
$\det G \le \prod_i G_{ii}$ yields $|\det A| \le 16\,B^4$, and equality forces
orthogonal rows of equal length — a Hadamard matrix. The lower bound and its
orthogonality certificate are already in hand; only the positive-semidefinite
determinant inequality remains.

**2. General even order and the Hadamard connection.** *Conjecture:* For every
order $n$ divisible by $4$, the maximum determinant with $|A_{ij}| \le B$ equals
$n^{n/2} B^n$, attained iff a Hadamard matrix of order $n$ exists. The bound is
achieved precisely when the rows can be made mutually orthogonal with all entries
$\pm B$ — the definition of a scaled Hadamard matrix. Extending the achievability
argument turns the maximal determinant problem into a direct probe of the
**Hadamard conjecture** (existence of Hadamard matrices of every order $4m$), a
long-standing open problem.

**3. The gap when no Hadamard matrix exists.** *Conjecture:* For orders
$n \equiv 1, 2, 3 \pmod 4$ the maximum determinant is strictly below the Hadamard
bound $n^{n/2} B^n$, with the deficit governed by the Barba ($n$ odd) and
Ehlich–Wojtas ($n \equiv 2 \bmod 4$) bounds, scaled by $B^n$. Orthogonality of
$\pm B$ rows is impossible unless $n$ permits a Hadamard structure, forcing the
extremal Gram matrix away from a scalar multiple of the identity.

**4. Rigidity of the extremiser.** *Conjecture:* Among $4 \times 4$ matrices with
entries in $\{-B, \dots, B\}$, the only determinant-maximisers are the
$2^4 \cdot 4! = 384$ signed permutations of the scaled Hadamard matrix
(equivalently, all $\pm B$ matrices with orthogonal rows).

---

## 9. Conclusion

For $4 \times 4$ integer matrices with entries bounded by $B$, the maximum
determinant is $16\,B^4$, achieved by a scaled order-$4$ Hadamard matrix whose
mutually orthogonal rows serve as the structural certificate of extremality. An
elementary permutation bound gives the honest bracket
$16\,B^4 \le M(B) \le 24\,B^4$, and the Hadamard determinant inequality closes it
to the exact value. Along the way we refuted a circulated candidate formula
$(2k-1)^4 - 2(2k-1)^2 + 1$, which fails to bound the family and collapses to $0$
at $k=1$ despite a true maximum of $16$. The story exemplifies a durable
principle: extremal values are proved achievable by explicit construction, and
false formulas are best answered by explicit counterexample.
