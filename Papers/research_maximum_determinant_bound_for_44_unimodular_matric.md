# Maximal Determinants of Four-by-Four Integer Matrices with Bounded Entries

## Abstract

We study the order-four instance of Hadamard's maximal determinant problem: for a fixed bound $c \ge 0$, determine
$$
D(c) := \max\bigl\{ \det M : M \in \mathbb{Z}^{4\times 4},\ |M_{ij}| \le c \text{ for all } i,j \bigr\}.
$$
We prove three complementary facts and correct a circulating error. First, the value $16\,c^4$ is *achievable*: the scaled Hadamard matrix $cH$ is admissible and satisfies $\det(cH) = 16\,c^4$, whence $D(c) \ge 16\,c^4$. Second, a crude permanent (Leibniz) bound gives $D(c) \le 24\,c^4$, so $16\,c^4 \le D(c) \le 24\,c^4$ for every $c \ge 0$. Third, the reachable determinants are quantized: any $4\times4$ sign matrix ($\pm 1$ entries) has determinant divisible by $8$. Finally, we refute a formula that had been proposed for the maximum: writing $c = 2k-1$, the guess $(2k-1)^4 - 2(2k-1)^2 + 1 = (c^2-1)^2$ is strictly below the achievable value $16\,c^4$ for all $k \ge 1$, and hence is not even an upper bound. Throughout, the key structural phenomenon is *separability*: every bound factors as (constant) $\times\, c^4$, reducing the problem to the sign-matrix case $c = 1$.

**Keywords:** maximal determinant, Hadamard matrix, bounded-entry matrices, Hadamard's determinant problem, permanent bound, divisibility law, experimental design.

## 1. Introduction

The determinant of a real square matrix is the signed volume of the parallelepiped spanned by its rows. A natural extremal question, raised by Jacques Hadamard in 1893, asks how large this volume can be when the entries are constrained in magnitude. Concretely, fix an order $n$ and a bound $c > 0$, and consider all $n \times n$ matrices whose entries lie in $[-c, c]$. Among these, which has the largest determinant, and what is that maximum?

This is *Hadamard's maximal determinant problem*. Despite its elementary statement it is genuinely hard: the exact maximum is known only for special orders and remains open in infinitely many cases. Hadamard's own inequality gives the universal upper bound $|\det M| \le \prod_i \|r_i\| \le (\sqrt{n}\,c)^n = n^{n/2} c^n$, with equality if and only if the rows are mutually orthogonal and each has maximal length. When $n$ is a multiple of $4$ (and, conjecturally, only then for $n > 2$) this bound is met by *Hadamard matrices*: $\pm 1$ matrices with pairwise orthogonal rows.

This paper isolates the order-four case, which is small enough to admit fully explicit computation yet large enough to display the essential features of the general problem. We denote the extremal quantity by $D(c)$ as above. Our contributions are:

1. A self-contained derivation of the explicit Laplace expansion of a $4\times4$ determinant (Section 3), used as the computational engine throughout.
2. **Achievability** (Section 4): the scaled Hadamard matrix $cH$ is admissible and has $\det(cH) = 16\,c^4$, so $D(c) \ge 16\,c^4$.
3. A **general upper bound** (Section 5): $|\det M| \le 24\,c^4$ for every admissible $M$, giving $16c^4 \le D(c) \le 24c^4$.
4. A **divisibility law** (Section 6): every $4\times4$ sign matrix has determinant divisible by $8$.
5. A **refutation** (Section 7): the circulating formula $(c^2-1)^2$ (with $c = 2k-1$) is strictly less than $16c^4$ for all $c \ge 1$, hence fails to be an upper bound.

We close (Section 8–9) with applications and the sharp constant as a future direction.

## 2. Definitions and setup

Throughout, matrices are indexed by $\{0,1,2,3\}$ (so a $4\times4$ matrix $M$ has entries $M_{ij}$ for $0 \le i,j \le 3$), and the determinant is the usual alternating multilinear form of the rows.

**Definition 2.1 (Admissible matrix).** For $c \ge 0$, a matrix $M \in \mathbb{Z}^{4\times4}$ is *$c$-admissible* if $|M_{ij}| \le c$ for all $i,j$.

**Definition 2.2 (Maximal determinant).** $D(c) := \max\{ \det M : M \text{ is } c\text{-admissible} \}$. The maximum exists because the admissible set is finite.

**Definition 2.3 (Sign matrix).** $M$ is a *sign matrix* if every entry satisfies $M_{ij} \in \{-1, +1\}$. Sign matrices are exactly the $1$-admissible matrices with no zero entries.

**Definition 2.4 (Hadamard matrix of order four).** The matrix
$$
H = \begin{pmatrix} 1 & 1 & 1 & 1 \\ 1 & -1 & 1 & -1 \\ 1 & 1 & -1 & -1 \\ 1 & -1 & -1 & 1 \end{pmatrix}
$$
is a sign matrix whose rows are pairwise orthogonal, each of Euclidean norm $2$.

**Definition 2.5 (Scaled Hadamard matrix).** For $c \in \mathbb{Z}$, set $\,cH$, the matrix obtained by multiplying every entry of $H$ by $c$. Its entries are all $\pm c$.

## 3. The computational engine: Laplace expansion of order four

Our explicit computations rest on a single identity, the cofactor (Laplace) expansion of a $4\times4$ determinant along its first row.

**Proposition 3.1 (Order-four Laplace expansion).** For any commutative ring $R$ and any $A \in R^{4\times4}$,
$$
\begin{aligned}
\det A =\ & A_{00}\bigl(A_{11}(A_{22}A_{33}-A_{23}A_{32}) - A_{12}(A_{21}A_{33}-A_{23}A_{31}) + A_{13}(A_{21}A_{32}-A_{22}A_{31})\bigr) \\
- & A_{01}\bigl(A_{10}(A_{22}A_{33}-A_{23}A_{32}) - A_{12}(A_{20}A_{33}-A_{23}A_{30}) + A_{13}(A_{20}A_{32}-A_{22}A_{30})\bigr) \\
+ & A_{02}\bigl(A_{10}(A_{21}A_{33}-A_{23}A_{31}) - A_{11}(A_{20}A_{33}-A_{23}A_{30}) + A_{13}(A_{20}A_{31}-A_{21}A_{30})\bigr) \\
- & A_{03}\bigl(A_{10}(A_{21}A_{32}-A_{22}A_{31}) - A_{11}(A_{20}A_{32}-A_{22}A_{30}) + A_{12}(A_{20}A_{31}-A_{21}A_{30})\bigr).
\end{aligned}
$$

*Proof sketch.* Expand $\det A$ along the first row: $\det A = \sum_{j=0}^{3} (-1)^j A_{0j}\,\det A^{(0,j)}$, where $A^{(0,j)}$ is the $3\times3$ minor obtained by deleting row $0$ and column $j$. Each of the four minors is then expanded by the standard $3\times3$ rule, and the terms are collected. The result is a polynomial identity that holds over any commutative ring. $\square$

This identity is exact and needs no hypotheses on $R$; it serves purely as a mechanical device for turning determinants of specific $4\times4$ matrices into explicit polynomials in their entries.

## 4. Achievability: the scaled Hadamard construction

**Theorem 4.1 (Determinant of the base Hadamard matrix).** $\det H = 16$.

*Proof sketch.* Substitute the sixteen entries of $H$ into the expansion of Proposition 3.1 and simplify. Geometrically, the four rows are mutually orthogonal vectors each of norm $2$, so they span a hypercube of side $2$ and $4$-volume $2^4 = 16$; the sign works out positive. $\square$

**Theorem 4.2 (Achievable value).** For every $c \in \mathbb{Z}$,
$$
\det(cH) = 16\,c^4.
$$

*Proof sketch.* The matrix $cH$ has each of its four rows equal to $c$ times the corresponding row of $H$. The determinant is multilinear and alternating in the rows, so scaling each of the four rows by $c$ multiplies the determinant by $c^4$: $\det(cH) = c^4 \det H = 16\,c^4$. Equivalently, substitute the entries $\pm c$ into Proposition 3.1 and collect; the result is the degree-four monomial $16\,c^4$. $\square$

**Theorem 4.3 (Admissibility).** For $c \ge 0$, the matrix $cH$ is $c$-admissible: $|(cH)_{ij}| \le c$ for all $i,j$.

*Proof sketch.* Every entry of $cH$ is $c$ or $-c$; since $c \ge 0$, its absolute value is exactly $c$. $\square$

**Corollary 4.4 (Lower bound on the maximum).** For every $c \ge 0$, $\,D(c) \ge 16\,c^4$.

*Proof.* Immediate from Theorems 4.2 and 4.3: $cH$ is admissible and attains determinant $16\,c^4$. $\square$

## 5. A general upper bound

**Theorem 5.1 (Permanent / Leibniz bound).** For every $c$-admissible $M \in \mathbb{Z}^{4\times4}$,
$$
|\det M| \le 24\,c^4.
$$

*Proof sketch.* The Leibniz formula writes the determinant as a signed sum over the $4! = 24$ permutations of $\{0,1,2,3\}$:
$$
\det M = \sum_{\sigma \in S_4} \operatorname{sgn}(\sigma) \prod_{i=0}^{3} M_{i,\sigma(i)}.
$$
By the triangle inequality and the multiplicativity of absolute value,
$$
|\det M| \le \sum_{\sigma \in S_4} \prod_{i=0}^{3} |M_{i,\sigma(i)}| \le \sum_{\sigma \in S_4} c^4 = 24\,c^4,
$$
since each of the four factors is at most $c$ and there are $24$ terms. $\square$

**Corollary 5.2 (Two-sided bound).** For every $c \ge 0$,
$$
16\,c^4 \;\le\; D(c) \;\le\; 24\,c^4,
$$
with the lower endpoint attained by the scaled Hadamard matrix.

The gap between $16$ and $24$ is an artifact of the crude counting in Theorem 5.1; the true constant is $16$, as discussed in Section 9. Even so, Corollary 5.2 already determines the exact *order of growth* $D(c) = \Theta(c^4)$ and pins the leading constant to a factor-$1.5$ window.

## 6. Quantization: a divisibility law

The reachable determinants are not distributed continuously; congruence constraints force them onto a coarse lattice.

**Theorem 6.1 (Divisibility law for sign matrices).** If $M \in \mathbb{Z}^{4\times4}$ is a sign matrix (every $M_{ij} \in \{+1, -1\}$), then $8 \mid \det M$.

*Proof sketch.* Perform the row operations $r_i \mapsto r_i - r_0$ for $i = 1,2,3$; these leave the determinant unchanged. Because every original entry is $\pm 1$, each new entry in rows $1,2,3$ is a difference of two $\pm1$ values, hence lies in $\{-2, 0, 2\}$ — in particular it is even. Write each such row as $2$ times an integer row. Multilinearity of the determinant in the rows extracts one factor of $2$ from each of the three reduced rows, giving $\det M = 8 \cdot \det M'$ where $M'$ is an integer matrix. Therefore $8 \mid \det M$. $\square$

**Remark 6.2.** Theorem 6.1 is the order-four case of the general law that an $n\times n$ sign matrix has determinant divisible by $2^{n-1}$; the row-subtraction argument is uniform in $n$. Its consequence is *quantization*: for $c=1$ the achievable determinants are multiples of $8$, and within $[-16,16]$ exactly the values $\{-16,-8,0,8,16\}$ occur. The extremal problem is thus a search over an arithmetic progression, not a continuum, which is exactly the mechanism behind the Ehlich–Wojtas congruence restrictions on maximal determinants at other orders.

## 7. Refutation of a circulating formula

A formula had been proposed for $D(c)$ in the case of odd bounds. Writing $c = 2k-1$ with $k \ge 1$, the claim was
$$
D(2k-1) \overset{?}{=} (2k-1)^4 - 2(2k-1)^2 + 1 = \bigl((2k-1)^2 - 1\bigr)^2 = (c^2-1)^2.
$$
We show this is false — indeed not even an upper bound — for every $k \ge 1$.

**Lemma 7.1 (Arithmetic gap).** For every $c \ge 1$, $\ (c^2 - 1)^2 < 16\,c^4$.

*Proof sketch.* Expand: $16c^4 - (c^2-1)^2 = 16c^4 - c^4 + 2c^2 - 1 = 15c^4 + 2c^2 - 1$. For $c \ge 1$ we have $15c^4 \ge 15$ and $2c^2 \ge 2$, so the expression is at least $16 > 0$. Hence $(c^2-1)^2 < 16c^4$. $\square$

**Theorem 7.2 (Refutation).** For every integer $k \ge 1$, setting $c = 2k-1$, there exists a $c$-admissible matrix $M$ with
$$
\det M > (2k-1)^4 - 2(2k-1)^2 + 1.
$$
Consequently the proposed formula is not an upper bound for $D(c)$, and in particular is not the maximum.

*Proof sketch.* Since $k \ge 1$, we have $c = 2k - 1 \ge 1$. Take $M = cH$, the scaled Hadamard matrix. By Theorems 4.2 and 4.3 it is $c$-admissible with $\det M = 16c^4$. By Lemma 7.1, $16c^4 > (c^2-1)^2 = (2k-1)^4 - 2(2k-1)^2 + 1$. $\square$

**Discussion.** The already-decisive case is $k = 1$ ($c = 1$): the formula returns $(1-1)^2 = 0$, predicting that the largest determinant of a $\pm1$ matrix is zero, whereas $\det H = 16$. The error most plausibly arises from conflating two normalizations of the extremal problem: one in which columns generate a unit-covolume lattice (so determinants are compared against $1$), and the bounded-entry normalization studied here (so determinants scale as $c^4$). A formula calibrated to the former has no reason to hold in the latter, and a single evaluation at $c=1$ suffices to detect the discrepancy.

## 8. Applications

Maximal-determinant and Hadamard matrices are foundational in several applied areas, all exploiting the same principle — long, mutually orthogonal rows encode the maximum independent information under a fixed magnitude budget.

- **Optimal experimental design.** In two-level factorial experiments, a Hadamard design lets an experimenter estimate the effects of many binary factors with minimal variance from the fewest runs; maximizing the determinant of the design matrix (D-optimality) minimizes the volume of the confidence ellipsoid of the estimated parameters.
- **Error-correcting codes.** The rows of a Hadamard matrix (and their negations) form the Hadamard code, whose large minimum distance made it suitable for deep-space communication (e.g., the Mariner missions).
- **Signal processing and quantum computing.** The Walsh–Hadamard transform, built from Hadamard matrices, is a fast, multiplication-free orthogonal transform used in compression, spread-spectrum communication, and as the fundamental single-qubit and $n$-qubit gate in quantum algorithms.
- **Weighing designs.** Determinant maximization under entry bounds directly models the problem of weighing several objects together on a spring or chemical balance to minimize measurement error.

## 9. Discussion and future directions

**The sharp constant.** The results above trap $D(c)$ in $[16c^4, 24c^4]$ and show the lower end is attained. The sharp statement is $D(c) = 16\,c^4$. Closing the gap requires replacing the crude Leibniz bound with Hadamard's inequality specialized to order four. The clean route uses the Gram matrix: $(\det M)^2 = \det(M M^{\mathsf T})$, and $MM^{\mathsf T}$ is positive semidefinite with diagonal entries equal to the squared row norms, each at most $4c^2$. The inequality $\det G \le \prod_i G_{ii}$ for positive semidefinite $G$ (Hadamard's determinant inequality) then gives $(\det M)^2 \le (4c^2)^4 = 256\,c^8$, i.e. $|\det M| \le 16\,c^4$. Establishing $\det G \le \prod_i G_{ii}$ for PSD $G$ is the one remaining ingredient for a fully sharp, two-sided determination.

**Separability.** Every bound we proved factors as (constant) $\times\, c^4$. This reflects a genuine structural fact: for each fixed order $n$, the maximal determinant with entries bounded by $c$ equals $A_n \cdot c^n$ for a constant $A_n$ independent of $c$, because scaling all entries by $c$ scales the determinant by $c^n$. The whole difficulty is concentrated in the constant $A_n$ — equivalently the sign-matrix ($c=1$) problem.

**The spectrum of reachable determinants.** Theorem 6.1 shows sign-matrix determinants live in $8\mathbb{Z}$; enumerating precisely which multiples of $8$ occur (conjecturally, within $[-16,16]$, only $\{-16,-8,0,8,16\}$) is a finite, checkable refinement that would fully describe the order-four determinant spectrum.

**General order.** The $2^{n-1}$ divisibility law and the separability constant $A_n$ both invite induction on $n$: the row-subtraction argument of Theorem 6.1 is order-independent, and $A_n$ is the central unknown of Hadamard's problem, equal to $n^{n/2}$ exactly when a Hadamard matrix of order $n$ exists.

## 10. Conclusion

For $4\times4$ integer matrices with entries bounded by $c$, the maximal determinant satisfies $16\,c^4 \le D(c) \le 24\,c^4$, with the lower bound achieved by the scaled Hadamard matrix $cH$ and the sharp value being $16\,c^4$. The determinants of sign matrices are quantized into multiples of $8$. A previously circulating formula $(c^2-1)^2$ for the maximum is refuted at every $c \ge 1$, failing even to be an upper bound. The order-four case thus offers a complete, transparent microcosm of Hadamard's maximal determinant problem: an explicit optimal construction, a clean scaling law, an arithmetic quantization, and a cautionary correction.
