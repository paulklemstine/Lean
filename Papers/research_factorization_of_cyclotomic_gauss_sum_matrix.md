# Factorization of the Cyclotomic Gauss-Sum Matrix

## Abstract

We study the $n \times n$ **cyclotomic Gauss-sum matrix**
$A_k(\chi) = \big[\,G_N(\chi^{k(i+j)})\,\big]_{0 \le i,j < n}$, whose entries are
Gauss sums over $\mathbb{Z}/N\mathbb{Z}$ with $N = p^m$ a prime power and
$n = \varphi(N)/k$. Because a Gauss sum is the finite Fourier transform of the
corresponding **Gauss periods** $\eta_a$, the matrix admits a clean spectral-type
factorization $A = W D W^{\mathsf T}$, where $W_{i,a} = \omega^{ai}$ is the
discrete Fourier transform (Vandermonde) matrix in a primitive $n$-th root of
unity $\omega$, and $D = \operatorname{diag}(\eta_0,\dots,\eta_{n-1})$ is the
diagonal matrix of periods. We isolate the *linear-algebraic core* of this
statement over an arbitrary commutative ring, taking the Fourier–period identity
as the definition of the matrix entries, and derive a family of consequences:
both $W$ and $A$ are symmetric; $W$ is Vandermonde with the classical product
determinant; $\det A = (\det W)^2 \prod_a \eta_a$; over a field $A$ is invertible
iff the nodes $\omega^i$ are distinct and every period is nonzero; the discrete
Fourier orthogonality relation $ (W^{\mathsf T}W)_{a,b} = n\,[\,n \mid a+b\,]$
holds; and the Gauss periods are recovered from a single column of $A$ by the
inverse transform. Finally, we refute the tempting conjecture
$W^{\mathsf T} W = n I$: the correct identity is $W^{\mathsf T} W = n P$, where $P$
is the reversal permutation $a \mapsto (n-a)\bmod n$, which differs from the
identity for all $n \ge 3$.

**Keywords.** Gauss sums, Gauss periods, cyclotomic cosets, discrete Fourier
transform, Vandermonde matrix, matrix factorization, roots of unity.

---

## 1. Introduction

Gauss sums are foundational objects in number theory, encoding delicate
arithmetic information about characters modulo $N$. Assembling a family of Gauss
sums into a matrix and studying its algebraic structure is a natural way to
expose relationships among them. The specific object of interest here is the
cyclotomic Gauss-sum matrix

$$A_k(\chi) = \big[\,G_N(\chi^{k(i+j)})\,\big]_{0 \le i,j < n},
\qquad N = p^m, \quad n = \varphi(N)/k,$$

where $\chi$ is a multiplicative character and $G_N$ is a Gauss sum. Because each
entry depends only on the sum $i+j$ of its indices, the matrix is symmetric and
"Hankel-like," and one expects the discrete Fourier transform to diagonalize it.

The purpose of this paper is to make that expectation precise and to extract its
consequences. The key structural fact is that a Gauss sum is the finite Fourier
transform of the **Gauss periods** of the $k$-th power residue cyclotomic cosets:

$$G_N(\chi^{ks}) = \sum_{a=0}^{n-1} \eta_a\, \omega^{as}, \tag{$\star$}$$

with $\omega$ a primitive $n$-th root of unity. Identity $(\star)$ is a classical
number-theoretic fact. Rather than rebuild the full cyclotomic apparatus, we
**take $(\star)$ as the definition** of the matrix entries and develop the
resulting linear algebra over an arbitrary commutative ring $R$. This yields a
self-contained, transparent account of the factorization and several corollaries
that are not visible in the purely number-theoretic formulation.

### Contributions

1. The factorization $A = W D W^{\mathsf T}$ (Theorem 3.1).
2. Symmetry of both $W$ and $A$ (Propositions 3.2–3.3).
3. Identification of $W$ as a Vandermonde matrix and the explicit product
   determinant (Propositions 4.1–4.2).
4. The determinant formula $\det A = (\det W)^2 \prod_a \eta_a$ and the
   invertibility criterion over a field (Theorems 4.3–4.4).
5. The discrete Fourier orthogonality relation and Fourier inversion recovering
   the Gauss periods (Theorems 5.1, 5.3–5.4).
6. A refutation of the conjecture $W^{\mathsf T}W = nI$, replaced by the correct
   reversal identity $W^{\mathsf T}W = nP$ (Theorem 5.5).

---

## 2. Definitions

Throughout, let $R$ be a commutative ring, $n \ge 1$ an integer, and
$\omega \in R$ a fixed element (a primitive $n$-th root of unity where noted). We
index rows and columns by $\{0, 1, \dots, n-1\}$.

**Definition 2.1 (Fourier / Vandermonde matrix).**
The *discrete Fourier transform matrix* $W = W_n(\omega)$ is the $n \times n$
matrix with entries

$$W_{i,a} = \omega^{a\,i}.$$

**Definition 2.2 (Diagonal period matrix).**
Given a vector of *Gauss periods* $\eta = (\eta_0, \dots, \eta_{n-1}) \in R^n$,
let $D = D_n(\eta) = \operatorname{diag}(\eta_0, \dots, \eta_{n-1})$.

**Definition 2.3 (Cyclotomic Gauss-sum matrix).**
The *Gauss-sum matrix* $A = A_n(\omega, \eta)$ is defined via the Fourier–period
identity $(\star)$ applied entrywise: its $(i,j)$ entry is

$$A_{i,j} = \sum_{a=0}^{n-1} \eta_a\, \omega^{a\,(i+j)}.$$

In the number-theoretic model, $\eta_a$ is the Gauss period of the $a$-th
cyclotomic coset, $\omega$ is a primitive $n$-th root of unity, and
$A_{i,j} = G_N(\chi^{k(i+j)})$.

**Remark.** Definition 2.3 is exactly the statement that each entry of $A$ is the
finite Fourier transform of the period vector, evaluated at frequency $i+j$.
Everything below is a consequence of this single generating identity.

---

## 3. The factorization

**Proposition 3.1 (Symmetry of $W$).** $W^{\mathsf T} = W$.

*Proof.* The $(i,a)$ entry of $W^{\mathsf T}$ is $W_{a,i} = \omega^{i a}
= \omega^{a i} = W_{i,a}$, using commutativity of the exponent. $\qquad\blacksquare$

**Proposition 3.2 (Symmetry of $A$).** $A^{\mathsf T} = A$.

*Proof.* Entry $(j,i)$ of $A$ is $\sum_a \eta_a\,\omega^{a(j+i)}$, which equals
$\sum_a \eta_a\,\omega^{a(i+j)}$ because $j + i = i + j$. $\qquad\blacksquare$

**Theorem 3.3 (Factorization).**
$$A = W\,D\,W^{\mathsf T}.$$

*Proof.* Compute the $(i,j)$ entry of the right-hand side. Since $D$ is diagonal,
$(WD)_{i,a} = W_{i,a}\,\eta_a = \eta_a\,\omega^{ai}$, and hence

$$\big(W D W^{\mathsf T}\big)_{i,j}
= \sum_{a=0}^{n-1} \eta_a\,\omega^{ai}\,\big(W^{\mathsf T}\big)_{a,j}
= \sum_{a=0}^{n-1} \eta_a\,\omega^{ai}\,\omega^{aj}
= \sum_{a=0}^{n-1} \eta_a\,\omega^{a(i+j)}
= A_{i,j}.$$

The two exponent laws used are $\omega^{ai}\omega^{aj} = \omega^{a(i+j)}$ and the
distribution $a(i+j) = ai + aj$. This matches Definition 2.3 exactly.
$\qquad\blacksquare$

Because $W$ is symmetric, the factorization may equivalently be written
$A = W D W$, exhibiting $A$ as the conjugate of the diagonal matrix $D$ by the
Fourier transform $W$. This is the spectral-type decomposition that drives the
rest of the paper.

---

## 4. Determinant and invertibility

**Proposition 4.1 ($W$ is Vandermonde).**
$W$ is the Vandermonde matrix in the nodes $x_i = \omega^{i}$; that is,
$W_{i,a} = x_i^{\,a} = (\omega^{i})^{a}$.

*Proof.* $W_{i,a} = \omega^{ai} = (\omega^{i})^{a}$. $\qquad\blacksquare$

**Proposition 4.2 (Vandermonde determinant).**
$$\det W = \prod_{0 \le i < j < n} \big(\omega^{j} - \omega^{i}\big).$$

*Proof.* Immediate from Proposition 4.1 and the classical Vandermonde
determinant formula applied to the nodes $\omega^0, \omega^1, \dots, \omega^{n-1}$.
$\qquad\blacksquare$

**Theorem 4.3 (Determinant of $A$).**
$$\det A = (\det W)^2 \cdot \prod_{a=0}^{n-1} \eta_a.$$

*Proof.* By Theorem 3.3 and multiplicativity of the determinant,
$\det A = \det W \cdot \det D \cdot \det W^{\mathsf T}$. Now
$\det W^{\mathsf T} = \det W$ and $\det D = \prod_a \eta_a$ since $D$ is diagonal.
Combining gives $\det A = (\det W)^2 \prod_a \eta_a$. $\qquad\blacksquare$

**Theorem 4.4 (Invertibility criterion).**
Over a field $K$,
$$\det A \ne 0 \iff \det W \ne 0 \ \text{ and } \ \eta_a \ne 0 \text{ for all } a.$$

*Proof.* In a field a product is nonzero iff each factor is nonzero. Apply this to
$\det A = (\det W)^2 \prod_a \eta_a$: the square $(\det W)^2$ is nonzero iff
$\det W \ne 0$, and $\prod_a \eta_a \ne 0$ iff every $\eta_a \ne 0$.
$\qquad\blacksquare$

The condition $\det W \ne 0$ is equivalent, via Proposition 4.2, to the nodes
$\omega^0, \dots, \omega^{n-1}$ being pairwise distinct — which holds precisely
when $\omega$ is a primitive $n$-th root of unity. Thus invertibility of $A$ is
governed entirely by (i) distinctness of the Fourier nodes and (ii) nonvanishing
of the Gauss periods.

---

## 5. Fourier orthogonality, inversion, and a refuted conjecture

We now assume $K$ is a field and $\omega \in K$ is a primitive $n$-th root of
unity.

**Lemma 5.0 (Geometric sum over roots of unity).**
If $r \in K$ satisfies $r^n = 1$, then
$$\sum_{i=0}^{n-1} r^{\,i} = \begin{cases} n & \text{if } r = 1, \\ 0 & \text{if } r \ne 1. \end{cases}$$

*Proof.* If $r = 1$ the sum is $n$. If $r \ne 1$, the finite geometric series
formula gives $\sum_{i=0}^{n-1} r^i = (r^n - 1)/(r - 1) = 0$ since $r^n = 1$.
$\qquad\blacksquare$

**Theorem 5.1 (Discrete Fourier orthogonality).**
For all indices $a, b$,
$$\big(W^{\mathsf T} W\big)_{a,b}
= \begin{cases} n & \text{if } n \mid a + b, \\ 0 & \text{otherwise.}\end{cases}$$

*Proof.* Using symmetry of $W$,
$(W^{\mathsf T}W)_{a,b} = \sum_{i} \omega^{ai}\,\omega^{bi}
= \sum_{i} (\omega^{a+b})^{i}$. Set $r = \omega^{a+b}$; then $r^n = (\omega^n)^{a+b}
= 1$, and $r = 1$ iff $\omega^{a+b} = 1$ iff $n \mid a+b$ (primitivity). Apply
Lemma 5.0. $\qquad\blacksquare$

**Corollary 5.2 (Reversal structure).**
Since $0 \le a, b < n$, the divisibility $n \mid a + b$ holds iff $b = 0$ and
$a = 0$, or $a + b = n$; that is, $b \equiv -a \pmod n$. Hence
$W^{\mathsf T} W = n\,P$, where $P$ is the permutation matrix of the *reversal*
map $a \mapsto (n - a) \bmod n$.

**Theorem 5.3 (Character orthogonality, inverse form).**
For all $a, c$,
$$\sum_{i=0}^{n-1} \big(\omega^{ci}\big)^{-1}\, \omega^{ai}
= \begin{cases} n & \text{if } a = c, \\ 0 & \text{if } a \ne c. \end{cases}$$

*Proof.* The summand equals $\big(\omega^{a}\,(\omega^{c})^{-1}\big)^{i}$. Let
$r = \omega^{a}(\omega^{c})^{-1}$; then $r^n = \omega^{an}(\omega^{cn})^{-1} = 1$,
and $r = 1$ iff $\omega^a = \omega^c$ iff $a = c$ (as $0 \le a,c < n$ and $\omega$
is primitive). Apply Lemma 5.0. $\qquad\blacksquare$

**Theorem 5.4 (Fourier inversion / period recovery).**
For every index $c$,
$$\sum_{i=0}^{n-1} \big(\omega^{ci}\big)^{-1}\Big(\sum_{a=0}^{n-1} \eta_a\,\omega^{ai}\Big)
= n\,\eta_c.$$
Consequently the Gauss periods are recovered from the zeroth column of $A$:
$$\sum_{i=0}^{n-1} \big(\omega^{ci}\big)^{-1}\, A_{i,0} = n\,\eta_c.$$

*Proof.* Expand and exchange the order of summation:
$$\sum_i (\omega^{ci})^{-1}\sum_a \eta_a \omega^{ai}
= \sum_a \eta_a \sum_i (\omega^{ci})^{-1}\omega^{ai}
= \sum_a \eta_a \cdot n\,[a = c] = n\,\eta_c,$$
by Theorem 5.3. For the second statement, note $A_{i,0} = \sum_a \eta_a\,\omega^{a(i+0)}
= \sum_a \eta_a\,\omega^{ai}$, so the zeroth column of $A$ is precisely the
Fourier transform of the periods; applying the inverse transform recovers
$n\,\eta_c$. $\qquad\blacksquare$

Theorem 5.4 shows that $A$ and the period vector $(\eta_a)$ carry the same
information: a single column of Gauss sums determines all $n$ periods by one
inverse DFT.

**Theorem 5.5 (Refutation of $W^{\mathsf T}W = nI$).**
Suppose $n \ge 3$ and $n \ne 0$ in $K$. Then
$$W^{\mathsf T} W \ne n\, I.$$

*Proof.* Consider the entry at $(a,b) = (1,\,n-1)$. Then $a + b = n$, so
$n \mid a+b$ and Theorem 5.1 gives $(W^{\mathsf T}W)_{1,n-1} = n \ne 0$. But the
corresponding entry of $n I$ is $0$, because $1 \ne n - 1$ when $n \ge 3$. Hence
the two matrices differ. $\qquad\blacksquare$

By Corollary 5.2 the correct identity is $W^{\mathsf T} W = n P$ with $P$ the
reversal permutation; it collapses to $n I$ only for $n \le 2$, where reversal is
trivial. This is the precise sense in which Fourier "orthogonality" pairs each
frequency with its mirror rather than with itself.

---

## 6. Algorithms

The results above are constructive and yield direct algorithms.

**Algorithm A (Assemble the Gauss-sum matrix).**
*Input:* period vector $\eta \in K^n$, primitive root $\omega$.
*Output:* $A$ with $A_{i,j} = \sum_a \eta_a\,\omega^{a(i+j)}$.
Precompute powers $\omega^0, \dots, \omega^{2n-2}$; then fill each entry as a
length-$n$ dot product. Cost $O(n^3)$ naïvely, or $O(n^2 \log n)$ using an FFT for
the underlying transform since the entries depend only on $i+j$.

**Algorithm B (Recover periods by inverse DFT).**
*Input:* the zeroth column $(A_{i,0})_{i}$, primitive root $\omega$.
*Output:* $(\eta_c)_c$ via $\eta_c = \frac{1}{n}\sum_i (\omega^{ci})^{-1} A_{i,0}$.
Cost $O(n^2)$ directly, or $O(n \log n)$ with an FFT. This realizes Theorem 5.4.

**Algorithm C (Determinant and invertibility test).**
*Input:* nodes $\omega^i$ and periods $\eta_a$.
*Output:* $\det A = \big(\prod_{i<j}(\omega^j - \omega^i)\big)^2 \prod_a \eta_a$,
and the boolean $\det A \ne 0$. Cost $O(n^2)$. This realizes Theorems 4.3–4.4.

---

## 7. Applications and discussion

**Diagonalize by Fourier.** The factorization is a member of the general family
of results stating that any matrix whose entries depend on $i+j$ (Hankel-type) or
$i - j$ (Toeplitz/circulant-type) is simplified by the Fourier basis. This is the
structural reason FFT-based methods dominate the numerical treatment of
convolution, circulant systems, and constant-coefficient difference equations.
Placing Gauss sums in this framework connects classical number theory to modern
computational linear algebra.

**Arithmetic of the determinant.** Theorem 4.3 reduces $\det A$ to two
transparent factors: the square of a Vandermonde determinant in the roots of
unity and the product of the Gauss periods. The Vandermonde square is closely
related to the discriminant of $x^n - 1$; making this relationship precise gives
an arithmetic interpretation of $\det A$ (see Future Directions).

**Degeneration is arithmetic.** The invertibility criterion (Theorem 4.4)
isolates the arithmetic obstruction to invertibility: with distinct nodes assured
by primitivity, $A$ fails to be invertible exactly when some Gauss period
vanishes. Vanishing periods are meaningful arithmetic events, and the criterion
translates a matrix-degeneracy question directly into that language.

**Efficient period computation.** Theorem 5.4 provides a practical route to all
$n$ Gauss periods from a single column of Gauss sums by one inverse transform,
avoiding $n$ separate coset summations.

**The value of a contrarian check.** The refuted conjecture $W^{\mathsf T}W = nI$
is exactly the sort of "obviously true" statement that invites uncritical
acceptance. Theorem 5.5 shows it fails for every $n \ge 3$, and Corollary 5.2
locates the failure precisely in the reversal permutation. The correct, subtler
orthogonality is what makes inversion (Theorem 5.4) consistent.

---

## 8. Future directions

1. **Bridge to genuine Gauss sums.** Replace the abstract entries by the
   number-theoretic Gauss sum $G_N(\chi^{ks})$ over $\mathbb{Z}/N\mathbb{Z}$ and
   prove the identity $G_N(\chi^{ks}) = \sum_a \eta_a\,\omega^{as}$ relating a
   Gauss sum to the Gauss periods of the $k$-th power residue cyclotomic cosets.
   This is the missing number-theoretic input that specializes the factorization
   to $A_k(\chi) = [G_N(\chi^{k(i+j)})]$.

2. **Reversal permutation, explicitly.** Package the orthogonality relation as an
   equation $W^{\mathsf T}W = n\,P$ for the permutation matrix $P$ of
   $a \mapsto (n - a)\bmod n$, and deduce a closed form for $A^{-1}$ (over a field
   with $n$ invertible and all $\eta_a \ne 0$) via
   $A^{-1} = \tfrac{1}{n^2}\,W^{\mathsf T} P D^{-1} P W$.

3. **Eigenstructure.** Since $W$ is symmetric, interpret $A = W D W$ as a
   spectral-type decomposition and extract eigenvalue/trace identities such as
   $\operatorname{tr} A = \sum_a \eta_a\big(\sum_i \omega^{2ai}\big)$.

4. **Specialization to prime-power moduli.** Instantiate with $N = p^m$,
   $n = \varphi(N)/k$, and a concrete primitive $n$-th root, tying $\eta$ to the
   actual period polynomials of the cyclotomic cosets.

5. **Determinant as a discriminant.** Relate $(\det W)^2$, the square of the
   Vandermonde determinant, to the discriminant of $x^n - 1$, giving an
   arithmetic interpretation of $\det A$.

---

## 9. Conclusion

Taking the Fourier–period identity as the definition of its entries, the
cyclotomic Gauss-sum matrix factors transparently as $A = W D W^{\mathsf T}$, a
conjugation of the diagonal period matrix by the discrete Fourier transform. From
this single decomposition flow the symmetry of $A$, its Vandermonde-based
determinant $\det A = (\det W)^2 \prod_a \eta_a$, a sharp invertibility criterion,
the recovery of the Gauss periods by inverse DFT, and a corrected orthogonality
relation $W^{\mathsf T} W = n P$ that supersedes the naïve $nI$. The account is
self-contained and holds over an arbitrary commutative ring for the structural
identities, specializing to fields where invertibility and inversion require it.
