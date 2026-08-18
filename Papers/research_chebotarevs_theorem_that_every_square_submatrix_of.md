# Chebotarev's Theorem on Roots of Unity and Its Consequences: Uncertainty, Exact Sparse Recovery, and Cauchy–Davenport

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

Let $p$ be a prime and let $\zeta$ be a primitive $p$-th root of unity in a field of characteristic zero. Chebotarev's theorem asserts that every square submatrix of the discrete Fourier transform matrix $\big(\zeta^{jk}\big)_{j,k \in \mathbb{Z}/p}$ is nonsingular. We give a complete, self-contained development of this theorem along the lines of Frenkel's polynomial argument, together with a systematic derivation of its analytic and combinatorial consequences.

Our contributions are organised as a single deductive chain, each link of which is proved here in full detail:

1. **Chebotarev's theorem** and its *quantitative core*: for distinct residues $a_1,\dots,a_n$ and $b_1,\dots,b_n$ modulo $p$, the integer polynomial $P(X) = \det\big((1+X)^{a_ib_j}\big)$ vanishes at $X = 0$ to order exactly $N = \binom{n}{2}$, and its $N$-th coefficient equals $\det\big(a_i^{k}\big)\cdot\det\big(\binom{b_i}{k}\big)$, an integer prime to $p$.
2. A **converse**: for every composite modulus $M > 1$ and every primitive $M$-th root of unity, an explicit singular $2\times 2$ submatrix exists. Consequently "all square submatrices of the $M \times M$ DFT matrix are nonsingular" is *equivalent* to the primality of $M$.
3. A **rectangular form**: every $n \times m$ submatrix with $n \le m$ has full row rank.
4. The **prime-order uncertainty principle** $\#\operatorname{supp} f + \#\operatorname{supp}\widehat f \ge p+1$ for nonzero $f : \mathbb{Z}/p \to \mathbb{C}$, together with two refinements: the bound is attained on *every* prescribed support, and the extremal kernels are *rigid* (one-dimensional).
5. **Exact sparse recovery**: a $k$-sparse signal on $\mathbb{Z}/p$ is determined by its Fourier coefficients on an *arbitrary* set of $2k$ frequencies, with a matching negative result showing $2k-1$ frequencies never suffice.
6. A **Fourier-analytic proof of the Cauchy–Davenport theorem** $\#(A+B) \ge \min(p, \#A+\#B-1)$, obtained by convolving two extremal functions.

We also present algorithms extracted from the proofs — computation of the staircase coefficient, construction of extremal functions, and combinatorial sparse decoding — together with their complexity, and discuss the sense in which primality is the exact hypothesis under which the entire chain functions.

**Keywords:** Chebotarev's theorem, discrete Fourier transform, cyclotomic polynomial, uncertainty principle, compressed sensing, sparse recovery, Cauchy–Davenport theorem, Vandermonde determinant.

---

## 1. Introduction

### 1.1 The problem

Fix an integer $M \ge 2$ and a primitive $M$-th root of unity $\zeta$ in $\mathbb{C}$ (or in any field of characteristic zero containing one). The *discrete Fourier transform matrix* of order $M$ is
$$F_M \;=\; \big(\zeta^{jk}\big)_{j,k = 0}^{M-1}.$$
It is invertible — indeed $F_M \overline{F_M} = M I$ — but invertibility of the whole matrix says nothing about its submatrices. Given $A = \{a_1 < \cdots < a_n\}$ and $B = \{b_1 < \cdots < b_n\}$, two $n$-element subsets of $\mathbb{Z}/M$, we may extract the *minor*
$$F_M[A,B] \;=\; \big(\zeta^{a_i b_j}\big)_{i,j=1}^{n}.$$

**Question.** For which $M$ is $F_M[A,B]$ nonsingular for *all* choices of $A$ and $B$?

Chebotarev proved in 1926 that primality suffices. The converse — that primality is also necessary — is elementary but worth stating precisely, and we do so below. The theorem has since acquired several proofs (Chebotarev's original argument, Reshetnyak's, Tao's exposition via a valuation argument, Frenkel's polynomial proof); we follow Frenkel's, which is the shortest and most self-contained, and which additionally yields quantitative information that the other proofs do not make explicit.

### 1.2 Why one should care

The nonsingularity of *all* minors is exactly the algebraic hypothesis needed for a family of "no exceptions" statements in analysis and combinatorics.

- In *sampling theory*, nonsingularity of $F_p[A,B]$ for $\#A = \#B = k$ says that a signal known to be supported in $A$ can be reconstructed from its Fourier coefficients on $B$ — for *every* $B$ of the right size. Contrast this with the usual compressed-sensing paradigm, in which measurement sets are chosen at random and guarantees hold with high probability.
- In *additive combinatorics*, the same hypothesis powers a Fourier-analytic route to the Cauchy–Davenport inequality.
- In *harmonic analysis on finite groups*, it produces an uncertainty principle strictly stronger than the general-group bound $\#\operatorname{supp} f \cdot \#\operatorname{supp} \widehat f \ge |G|$, and one which is sharp in the strongest imaginable sense.

### 1.3 Notation and conventions

Throughout, $p$ denotes a prime and $M$ an arbitrary modulus. $\mathbb{Z}/p$ is the ring of residues; $\binom{m}{k}$ is the usual binomial coefficient with $\binom{m}{k} = 0$ for $k > m$. For a function $f : \mathbb{Z}/p \to \mathbb{C}$ we write
$$\operatorname{supp} f = \{x \in \mathbb{Z}/p : f(x) \ne 0\},$$
and its discrete Fourier transform is
$$\widehat f(t) \;=\; \sum_{x \in \mathbb{Z}/p} e^{-2\pi i\, xt/p}\, f(x), \qquad t \in \mathbb{Z}/p .$$
Convolution is $(f*g)(x) = \sum_{y} f(y)\, g(x - y)$. We use the *staircase number*
$$N(n) \;=\; 0 + 1 + \cdots + (n-1) \;=\; \binom{n}{2}.$$
The *Vandermonde determinant* of $c_1,\dots,c_n$ is $V(c) = \det\big(c_i^{\,k}\big)_{i=1,\dots,n;\ k=0,\dots,n-1} = \prod_{i<j}(c_j - c_i)$.

---

## 2. Chebotarev's theorem

### 2.1 Statement

> **Theorem 2.1 (Chebotarev).** Let $p$ be prime, let $K$ be a field of characteristic zero and let $\zeta \in K$ be a primitive $p$-th root of unity. Let $a_1,\dots,a_n$ and $b_1,\dots,b_n$ be two lists of *pairwise distinct* elements of $\{0,1,\dots,p-1\}$. Then
> $$\det\Big(\zeta^{\,a_i b_j}\Big)_{i,j=1}^{n} \;\ne\; 0 .$$

Observe that $n \le p$ automatically, since the $a_i$ are distinct residues.

### 2.2 The auxiliary polynomial and its multilinear expansion

Define
$$P(X) \;=\; \det\Big((1+X)^{\,a_i b_j}\Big)_{i,j=1}^n \;\in\; \mathbb{Z}[X],$$
and put $s_i = (1+X)^{a_i} - 1 \in \mathbb{Z}[X]$.

> **Lemma 2.2 (shift lemma).** For every $m \ge 0$ there is $w_m \in \mathbb{Z}[X]$ with $(1+X)^m - 1 = X\,w_m$ and $w_m(0) = m$.

*Proof sketch.* Induction on $m$: for the step use $(1+X)^{m+1} - 1 = (1+X)\big((1+X)^m - 1\big) + X$, so $w_{m+1} = (1+X)w_m + 1$ and $w_{m+1}(0) = w_m(0) + 1$. $\square$

> **Lemma 2.3 (uniform binomial expansion).** If $m < p$ then in any commutative ring, $(1+s)^m = \sum_{k=0}^{p-1} \binom{m}{k} s^k$.

*Proof sketch.* The binomial theorem gives the sum up to $k = m$; the extra terms $k = m+1,\dots,p-1$ vanish because $\binom{m}{k} = 0$ there. Extending to a *uniform* index range $\{0,\dots,p-1\}$ independent of $m$ is what allows the determinant to be expanded row by row against one fixed basis. $\square$

> **Lemma 2.4 (multilinear determinant expansion).** Let $R$ be a commutative ring, $c : \{1..n\}\times\{1..m\} \to R$ and $E : \{1..m\}\times\{1..n\} \to R$. Then
> $$\det\Big(\textstyle\sum_{k=1}^m c_{ik} E_{kj}\Big)_{i,j} \;=\; \sum_{f : \{1..n\}\to\{1..m\}} \Big(\prod_{i=1}^n c_{i, f(i)}\Big)\, \det\big(E_{f(i),\,j}\big)_{i,j}.$$

*Proof sketch.* The determinant is an alternating multilinear function of the rows. The $i$-th row of the left-hand matrix is the sum over $k$ of the vectors $c_{ik}\,E_{k,\bullet}$; expanding multilinearity in all $n$ rows produces one term per choice function $f$, and pulling the scalars $c_{i,f(i)}$ out of row $i$ yields the stated formula. $\square$

Combining Lemmas 2.3 and 2.4 with $(1+X)^{a_i b_j} = (1 + s_i)^{b_j}$ gives:

> **Proposition 2.5 (expansion of $P$).** With $b_j < p$ for all $j$,
> $$P(X) \;=\; \sum_{f : \{1..n\} \to \{0,\dots,p-1\}} \Big(\prod_{i=1}^n s_i^{\,f(i)}\Big)\cdot \det\Big(\binom{b_j}{f(i)}\Big)_{i,j}.$$

> **Lemma 2.6 (non-injective terms die).** If $f$ is not injective, then $\det\big(\binom{b_j}{f(i)}\big)_{i,j} = 0$.

*Proof.* If $f(i_1) = f(i_2)$ with $i_1 \ne i_2$, rows $i_1$ and $i_2$ of the matrix coincide. $\square$

### 2.3 Order of vanishing at the origin

> **Lemma 2.7 (staircase bound).** If $f : \{1..n\} \to \mathbb{Z}_{\ge 0}$ is injective then $\sum_i f(i) \ge N(n)$. Moreover, if equality holds then $f$ is a bijection onto $\{0,1,\dots,n-1\}$.

*Proof sketch.* The image is a set of $n$ distinct nonnegative integers; sorting it increasingly, the $j$-th smallest is at least $j-1$, so the sum is at least $0 + 1 + \cdots + (n-1)$. If some value were $\ge n$, deleting it and applying the bound to the remaining $n-1$ values gives $\sum_i f(i) \ge N(n-1) + n > N(n)$, contradiction. $\square$

> **Theorem 2.8.** $X^{N(n)} \mid P(X)$ in $\mathbb{Z}[X]$.

*Proof.* By Proposition 2.5 and Lemma 2.6 only injective $f$ contribute. For such $f$, using Lemma 2.2 we write $s_i^{f(i)} = X^{f(i)} w_{a_i}^{f(i)}$, so the product over $i$ is divisible by $X^{\sum_i f(i)}$, which by Lemma 2.7 is divisible by $X^{N(n)}$. $\square$

### 2.4 The staircase coefficient

> **Theorem 2.9 (staircase coefficient).** Let $\chi(b) = \det\big(\binom{b_i}{k}\big)_{i=1..n,\ k=0..n-1}$. Then
> $$[X^{N(n)}]\,P \;=\; V(a)\cdot \chi(b), \qquad V(a) = \prod_{i<j}(a_j - a_i).$$

*Proof sketch.* Each term of Proposition 2.5 with injective $f$ factors as $X^{\sum_i f(i)}\,U_f(X)$ with $U_f(0) = \big(\prod_i a_i^{f(i)}\big)\det\big(\binom{b_j}{f(i)}\big)$, by Lemma 2.2. Terms with $\sum_i f(i) > N(n)$ contribute nothing to the coefficient of $X^{N(n)}$; terms with $\sum_i f(i) = N(n)$ contribute exactly $U_f(0)$, and by Lemma 2.7 these are precisely the $f$ that biject onto $\{0,\dots,n-1\}$. Hence
$$[X^{N(n)}]\,P \;=\; \sum_{g \in \mathfrak{S}_n} \Big(\prod_i a_i^{\,g(i)}\Big)\det\Big(\binom{b_j}{g(i)}\Big)_{i,j},$$
where in fact the sum may be taken over *all* functions $g : \{1..n\}\to\{0,\dots,n-1\}$ since non-injective ones contribute zero. Applying Lemma 2.4 backwards, this sum is the determinant of the product matrix
$$\Big(\sum_{k=0}^{n-1} a_i^{\,k}\,\binom{b_j}{k}\Big)_{i,j} \;=\; \big(a_i^{\,k}\big)_{i,k}\cdot\Big(\binom{b_j}{k}\Big)_{k,j},$$
whose determinant is $V(a)\cdot\chi(b)$ (the second factor being the determinant of the transpose of the binomial matrix). $\square$

> **Lemma 2.10 (superfactorial identity).** $\Big(\prod_{k=0}^{n-1} k!\Big)\cdot \chi(b) \;=\; V(b) = \prod_{i<j}(b_j - b_i).$

*Proof sketch.* The falling factorials $\mathrm{fall}_k(Y) = Y(Y-1)\cdots(Y-k+1)$ form a sequence of monic polynomials with $\deg \mathrm{fall}_k = k$; for such a basis the determinant $\det\big(\mathrm{fall}_k(b_i)\big)$ equals the Vandermonde determinant $V(b)$ (change of basis by a unipotent triangular matrix has determinant $1$). Since $\mathrm{fall}_k(b_i) = k!\binom{b_i}{k}$, factoring $k!$ out of column $k$ gives the claim. $\square$

> **Corollary 2.11 (the coefficient is prime to $p$).** If the $a_i$ are distinct residues in $\{0,\dots,p-1\}$ and likewise the $b_j$, then $p \nmid V(a)$, $p \nmid \chi(b)$, and hence
> $$p \;\nmid\; [X^{N(n)}]\,P .$$
> In particular $P$ vanishes at $X=0$ to order *exactly* $N(n)$.

*Proof.* $V(a) = \prod_{i<j}(a_j - a_i)$ is a product of nonzero integers of absolute value $< p$, so $p$ divides none of them and, $p$ being prime, not the product. Same for $V(b)$; by Lemma 2.10, $\chi(b)$ divides $V(b)$ up to the factor $\prod k!$, so $p \mid \chi(b)$ would force $p \mid V(b)$. $\square$

### 2.5 The cyclotomic obstruction

> **Lemma 2.12 (shifted cyclotomic polynomial).** For $p$ prime let $\Psi_p(X) = \Phi_p(X+1)$, where $\Phi_p(X) = 1 + X + \cdots + X^{p-1}$. Then
> $$X\,\Psi_p(X) = (1+X)^p - 1, \qquad\text{hence}\qquad [X^k]\,\Psi_p = \binom{p}{k+1} \quad (0 \le k \le p-1).$$
> In particular $\Psi_p(0) = p$, every coefficient of degree $< p-1$ is divisible by $p$, and the leading coefficient is $1$.

*Proof.* Substitute $X + 1$ into the geometric-sum identity $(Y-1)\Phi_p(Y) = Y^p - 1$ and read off coefficients via the binomial theorem. $\square$

> **Proposition 2.13 (divisibility step).** Let $P \in \mathbb{Z}[X]$ with $[X^m]P = 0$ for all $m < N$. If $\Psi_p \mid P$, then $p \mid [X^N] P$.

*Proof sketch.* Write $P = \Psi_p Q$. First we show $[X^m]Q = 0$ whenever $m + (p-1) \le N$, by strong induction on $m$: in the convolution formula for $[X^m](\Psi_p Q)$ all terms with second index $< m$ vanish by the inductive hypothesis, leaving $\Psi_p(0)\,[X^m]Q = p\,[X^m]Q$, which equals $[X^m]P = 0$ since $m < N$; as $p \ne 0$ in $\mathbb{Z}$, $[X^m]Q = 0$.
Now expand $[X^N]P = \sum_{k+\ell = N} [X^k]\Psi_p \cdot [X^\ell]Q$. If $k + 1 < p$ then $p \mid \binom{p}{k+1} = [X^k]\Psi_p$. Otherwise $k \ge p-1$, whence $\ell + (p-1) \le \ell + k = N$ and $[X^\ell]Q = 0$. Every term is divisible by $p$. $\square$

### 2.6 Proof of Theorem 2.1

Suppose $\det(\zeta^{a_ib_j}) = 0$.

*Step 1.* Substituting $X = \zeta - 1$ into $P$ gives $\det\big((1+(\zeta-1))^{a_ib_j}\big) = \det(\zeta^{a_ib_j}) = 0$, so $\zeta - 1$ is a root of $P$.

*Step 2.* Equivalently $\zeta$ is a root of $P(X-1)$. Since $\zeta$ is an algebraic integer with $\zeta^p = 1$ and $\zeta \ne 1$, its minimal polynomial over $\mathbb{Q}$ is the cyclotomic polynomial $\Phi_p$, which is irreducible and monic with integer coefficients; hence $\Phi_p \mid P(X-1)$ in $\mathbb{Z}[X]$. Substituting $X \mapsto X+1$ yields $\Psi_p \mid P$.

*Step 3.* By Theorem 2.8, all coefficients of $P$ below degree $N(n)$ vanish.

*Step 4.* Proposition 2.13 now gives $p \mid [X^{N(n)}]P$, contradicting Corollary 2.11. $\blacksquare$

Two remarks. First, characteristic zero is used only through the identification of $\Phi_p$ with the minimal polynomial of $\zeta$ over $\mathbb{Z}$; the theorem is genuinely false in characteristic $p$ (where $\zeta = 1$) and the argument does not apply. Second, Corollary 2.11 is of independent interest as a *quantitative* statement: it determines the exact order of vanishing at $X=0$ of the deformation $\det\big((1+X)^{a_ib_j}\big)$ and identifies the leading coefficient in closed form.

### 2.7 Rectangular form

> **Theorem 2.14 (full row rank).** Let $p$ be prime, $\zeta$ a primitive $p$-th root of unity in a characteristic-zero field $K$, and let $n \le m$. Let $a_1,\dots,a_n$ and $b_1,\dots,b_m$ be distinct residues modulo $p$. If $v \in K^n$ satisfies $\sum_{i=1}^n v_i\,\zeta^{a_i b_j} = 0$ for all $j = 1,\dots,m$, then $v = 0$.

*Proof.* Restrict to the first $n$ columns: the resulting square minor is nonsingular by Theorem 2.1, and a nonzero vector cannot lie in the left kernel of an invertible matrix. $\square$

### 2.8 Necessity of primality

> **Theorem 2.15 (converse).** Let $M > 1$ be composite and let $\zeta$ be a primitive $M$-th root of unity in a field. Then there are distinct residues $a_1 \ne a_2$, $b_1 \ne b_2$ modulo $M$ with $\det\big(\zeta^{a_ib_j}\big)_{i,j=1}^2 = 0$. Consequently, for a modulus $M > 1$,
> $$\text{all square submatrices of } F_M \text{ are nonsingular} \iff M \text{ is prime}.$$

*Proof.* Write $M = de$ with $1 < d < M$; then $2 \le e < M$. Take $a = (0, e)$ and $b = (0, d)$. The matrix is
$$\begin{pmatrix} \zeta^{0} & \zeta^{0} \\ \zeta^{0} & \zeta^{ed}\end{pmatrix} = \begin{pmatrix} 1 & 1 \\ 1 & 1\end{pmatrix},$$
since $\zeta^{ed} = \zeta^{M} = 1$; its determinant is $0$. Combined with Theorem 2.1, this proves the equivalence. $\square$

The special case $M = 4$, $\zeta = i$, $a = b = (0,2)$ is the smallest instance.

Structurally, the reason is transparent: composite $M$ has a proper subgroup of $M$-th roots of unity, giving nontrivial vanishing sums; every such relation produces a linear dependence among rows of $F_M$ restricted to suitable index sets.

---

## 3. The prime-order uncertainty principle

### 3.1 Statement and derivation

> **Theorem 3.1 (uncertainty principle).** Let $p$ be prime and $f : \mathbb{Z}/p \to \mathbb{C}$ nonzero. Then
> $$\#\operatorname{supp} f \;+\; \#\operatorname{supp}\widehat f \;\ge\; p+1 .$$

*Proof.* Let $A = \operatorname{supp} f$, $k = \#A \ge 1$. Suppose for contradiction $\#\operatorname{supp}\widehat f \le p - k$. Then the complement of $\operatorname{supp}\widehat f$ has at least $k$ elements; choose $B \subseteq \mathbb{Z}/p$ with $\#B = k$ and $\widehat f|_B = 0$. Enumerate $A = \{\alpha_1,\dots,\alpha_k\}$ and $B = \{\beta_1,\dots,\beta_k\}$ and let $\omega$ be the primitive $p$-th root of unity $e^{-2\pi i /p}$, so that the Fourier kernel is $\omega^{xt}$. Set $v_i = f(\alpha_i)$. For each $j$,
$$0 \;=\; \widehat f(\beta_j) \;=\; \sum_{x \in \mathbb{Z}/p} f(x)\,\omega^{x\beta_j} \;=\; \sum_{i=1}^k v_i\, \omega^{\alpha_i \beta_j},$$
the middle equality because $f$ vanishes off $A$. Thus $v$ lies in the left kernel of the $k \times k$ minor $\big(\omega^{\alpha_i\beta_j}\big)$, which is nonsingular by Theorem 2.1. Hence $v = 0$, contradicting $f(\alpha_1) \ne 0$. $\square$

The multiplicative bound $\#\operatorname{supp} f \cdot \#\operatorname{supp}\widehat f \ge p$ holds for every finite abelian group; Theorem 3.1 is a genuinely prime-order phenomenon and is stronger precisely in the regime of small supports (e.g. $k = 2$, $p = 101$: the multiplicative bound gives $51$, the additive bound gives $100$).

### 3.2 Sharpness

> **Proposition 3.2 (Dirac case).** Let $\delta_0(x) = \mathbf{1}[x = 0]$. Then $\widehat{\delta_0} \equiv 1$, so $\#\operatorname{supp}\delta_0 + \#\operatorname{supp}\widehat{\delta_0} = 1 + p = p+1$.

Sharpness holds far more generally. The key construction is elementary linear algebra and requires no primality.

> **Lemma 3.3 (extremal construction).** Let $A, S \subseteq \mathbb{Z}/p$ with $\#A = \#S + 1$. Then there is a nonzero $f : \mathbb{Z}/p \to \mathbb{C}$ vanishing off $A$ with $\widehat f|_S = 0$.

*Proof.* Consider the linear map sending a function supported in $A$ (an $\#A$-dimensional space) to the vector of its Fourier coefficients on $S$ (an $\#S = \#A - 1$-dimensional space). A linear map from a space of dimension $m+1$ to one of dimension $m$ has nontrivial kernel. Concretely, one pads the $(\#A) \times (\#S)$ evaluation matrix with a zero column to make it square; the resulting matrix has determinant zero, so a nonzero vector annihilates it. $\square$

> **Theorem 3.4 (sharpness on every support).** Let $p$ be prime and $\emptyset \ne A \subseteq \mathbb{Z}/p$. Then there exists $f$ with $\operatorname{supp} f = A$ (exactly) and
> $$\#\operatorname{supp} f + \#\operatorname{supp}\widehat f \;=\; p+1 .$$

*Proof.* Choose any $S$ with $\#S = \#A - 1$ (possible since $\#A \le p$) and let $f$ be as in Lemma 3.3. Then $\operatorname{supp} f \subseteq A$, so $\#\operatorname{supp} f \le \#A$; and $\widehat f$ vanishes on $S$, so $\#\operatorname{supp}\widehat f \le p - (\#A - 1)$. Adding, $\#\operatorname{supp} f + \#\operatorname{supp}\widehat f \le p + 1$. Theorem 3.1 gives the reverse inequality, so equality holds throughout — forcing $\#\operatorname{supp} f = \#A$, i.e. $\operatorname{supp} f = A$. $\square$

Thus for every prescribed support set $A$, no matter how it is arranged inside $\mathbb{Z}/p$, an extremal function exists. This is a strong contrast with, say, the group $\mathbb{Z}/M$ for composite $M$, where extremisers of the multiplicative uncertainty principle are supported on cosets of subgroups.

### 3.3 Rigidity

> **Theorem 3.5 (uniqueness of extremal kernels).** Let $p$ be prime and $A, S \subseteq \mathbb{Z}/p$ with $\#A = \#S+1$. Then the space
> $$\mathcal{K}(A,S) = \{f : \operatorname{supp} f \subseteq A,\ \widehat f|_S = 0\}$$
> is exactly one-dimensional: it contains a nonzero $f$, and every $g \in \mathcal{K}(A,S)$ is a scalar multiple of $f$.

*Proof.* Existence is Lemma 3.3. For uniqueness, let $f \ne 0$ in $\mathcal{K}(A,S)$, pick $a_0$ with $f(a_0)\ne 0$ (necessarily $a_0 \in A$), let $g \in \mathcal{K}(A,S)$ and set $c = g(a_0)/f(a_0)$, $h = g - cf$. Then $h \in \mathcal{K}(A,S)$ and $h(a_0) = 0$, so $\operatorname{supp} h \subseteq A \setminus \{a_0\}$ has at most $\#S$ elements, while $\widehat h$ vanishes on $S$, so $\#\operatorname{supp}\widehat h \le p - \#S$. If $h \ne 0$ this contradicts Theorem 3.1, since $\#S + (p - \#S) = p < p+1$. Hence $h = 0$ and $g = cf$. $\square$

The interpretation is a *rigidity* statement: the extremisers of the uncertainty principle, far from forming a large family, are pinned down (up to scale) by their support and by the zero set of their transform.

---

## 4. Exact sparse recovery

Call $f : \mathbb{Z}/p \to \mathbb{C}$ *$k$-sparse* if $\#\operatorname{supp} f \le k$.

> **Theorem 4.1 (exact recovery from any $2k$ frequencies).** Let $p$ be prime, $k \ge 0$, and let $S \subseteq \mathbb{Z}/p$ with $\#S \ge 2k$. If $f, g$ are $k$-sparse and $\widehat f|_S = \widehat g|_S$, then $f = g$.

*Proof.* Let $h = f - g$. Then $\operatorname{supp} h \subseteq \operatorname{supp} f \cup \operatorname{supp} g$, so $\#\operatorname{supp} h \le 2k$; and $\widehat h$ vanishes on $S$, so $\#\operatorname{supp}\widehat h \le p - 2k$. If $h \ne 0$, Theorem 3.1 gives $p+1 \le 2k + (p - 2k) = p$, absurd. $\square$

The measurement set $S$ is *arbitrary*: an adversary may select which $2k$ Fourier coefficients are revealed, and the $k$-sparse pre-image is still unique. No random matrix, no restricted isometry property, no failure probability. (Stability under noise is a separate matter; see §7.)

> **Theorem 4.2 (optimality).** Let $1 \le k$ and $2k \le p$, and let $S \subseteq \mathbb{Z}/p$ with $\#S = 2k-1$. Then there exist *distinct* $k$-sparse $f, g$ with $\widehat f|_S = \widehat g|_S$.

*Proof.* Choose $A \subseteq \mathbb{Z}/p$ with $\#A = 2k = \#S+1$ and apply Lemma 3.3 to obtain a nonzero $h$ supported in $A$ with $\widehat h|_S = 0$. Partition $A = A_1 \sqcup A_2$ with $\#A_1 = \#A_2 = k$, and set $f = h\cdot\mathbf{1}_{A_1}$, $g = -h\cdot\mathbf{1}_{A_2}$. Both are $k$-sparse, $f - g = h \ne 0$ so $f \ne g$, and $\widehat f - \widehat g = \widehat h$ vanishes on $S$. $\square$

Together, Theorems 4.1 and 4.2 place the exact information-theoretic threshold for identifiability of $k$-sparse signals on $\mathbb{Z}/p$ at $2k$ frequencies, for every admissible measurement pattern.

---

## 5. Cauchy–Davenport via convolution

### 5.1 Convolution preliminaries

> **Lemma 5.1 (convolution theorem).** For $f, g : \mathbb{Z}/p \to \mathbb{C}$ and every $t$, $\widehat{f*g}(t) = \widehat f(t)\,\widehat g(t)$.

*Proof sketch.* Expand $\widehat{f*g}(t) = \sum_x \omega^{xt}\sum_y f(y)g(x-y)$, substitute $x = y + z$ and use the character identity $\omega^{(y+z)t} = \omega^{yt}\omega^{zt}$ to factor the double sum. $\square$

> **Lemma 5.2 (support of a convolution).** $\operatorname{supp}(f*g) \subseteq \operatorname{supp} f + \operatorname{supp} g$.

*Proof.* If $(f*g)(x) \ne 0$ some summand $f(y)g(x-y)$ is nonzero, whence $y \in \operatorname{supp} f$, $x - y \in \operatorname{supp} g$ and $x = y + (x-y)$. $\square$

> **Lemma 5.3 (pigeonhole).** If $X, Y \subseteq \mathbb{Z}/p$ with $\#X + \#Y > p$ then $X \cap Y \ne \emptyset$.

*Proof.* $\#X + \#Y = \#(X\cap Y) + \#(X \cup Y) \le \#(X\cap Y) + p$. $\square$

### 5.2 The theorem

> **Theorem 5.4 (Cauchy–Davenport).** Let $p$ be prime and $A, B \subseteq \mathbb{Z}/p$ nonempty. Then
> $$\#(A+B) \;\ge\; \min\big(p,\ \#A + \#B - 1\big).$$

*Proof.* Write $\alpha = \#A$, $\beta = \#B$, both $\ge 1$ and $\le p$.

*Case 1: $\alpha + \beta > p+1$.* We claim $A + B = \mathbb{Z}/p$. Given $x$, the set $x - B = \{x - b : b \in B\}$ has $\beta$ elements, and $\alpha + \beta > p$, so by Lemma 5.3 there is $a \in A \cap (x - B)$, i.e. $a = x - b$ for some $b \in B$, i.e. $x = a + b \in A+B$. Then $\#(A+B) = p \ge \min(p, \alpha+\beta-1)$.

*Case 2: $\alpha + \beta \le p+1$.* Then $\alpha + \beta - 2 \le p - 1$, so we may choose $T \subseteq \mathbb{Z}/p$ with $\#T = \alpha + \beta - 2$ and split $T = S_A \sqcup S_B$ with $\#S_A = \alpha - 1$ and $\#S_B = \beta - 1$. By Lemma 3.3 there are nonzero $f$ supported in $A$ with $\widehat f|_{S_A} = 0$, and nonzero $g$ supported in $B$ with $\widehat g|_{S_B} = 0$.

By Theorem 3.1, $\#\operatorname{supp}\widehat f \ge p+1-\alpha$ and $\#\operatorname{supp}\widehat g \ge p+1-\beta$. Their sum is $2p + 2 - \alpha - \beta \ge 2p+2 - (p+1) = p+1 > p$, so by Lemma 5.3 there is $t$ with $\widehat f(t)\widehat g(t) \ne 0$; by Lemma 5.1, $\widehat{f*g}(t)\ne 0$, hence $h := f*g \ne 0$.

By construction $\widehat h = \widehat f\,\widehat g$ vanishes on all of $T$ (on $S_A$ because $\widehat f$ does, on $S_B$ because $\widehat g$ does), so
$$\#\operatorname{supp}\widehat h \;\le\; p - (\alpha + \beta - 2).$$
By Lemma 5.2 and $\operatorname{supp} f \subseteq A$, $\operatorname{supp} g \subseteq B$ we get $\operatorname{supp} h \subseteq A + B$, hence $\#\operatorname{supp} h \le \#(A+B)$. Applying Theorem 3.1 to $h$:
$$p + 1 \;\le\; \#\operatorname{supp} h + \#\operatorname{supp}\widehat h \;\le\; \#(A+B) + p - \alpha - \beta + 2,$$
i.e. $\#(A+B) \ge \alpha + \beta - 1 \ge \min(p, \alpha+\beta-1)$. $\square$

This is a genuine *bridge*: an algebraic statement about cyclotomic fields (irreducibility of $\Phi_p$) controls a purely additive-combinatorial inequality, through the intermediary of the uncertainty principle. The usual proofs of Cauchy–Davenport (the $e$-transform, or the Combinatorial Nullstellensatz) go by entirely different routes.

---

## 6. Algorithms

The proofs above are constructive enough to yield algorithms. We record three, with complexities in arithmetic operations.

### 6.1 The staircase coefficient

**Input:** distinct residues $a_1,\dots,a_n$, $b_1,\dots,b_n$ mod $p$.
**Output:** the integer $[X^{N(n)}]\det\big((1+X)^{a_ib_j}\big) = V(a)\,\chi(b)$, together with its residue mod $p$.

By Theorem 2.9 and Lemma 2.10 this is computable without any polynomial arithmetic:
$$V(a) = \prod_{i<j}(a_j - a_i), \qquad \chi(b) = \frac{\prod_{i<j}(b_j-b_i)}{\prod_{k=0}^{n-1} k!}.$$
The cost is $O(n^2)$ multiplications of integers (plus one exact division). Verifying that the residue mod $p$ is nonzero constitutes a *certificate of nonsingularity* for the corresponding DFT minor that never touches a complex number — a numerically exact substitute for computing $\det(\zeta^{a_ib_j})$ in floating point, which is ill-conditioned for large $n$.

### 6.2 Extremal function construction

**Input:** $A, S \subseteq \mathbb{Z}/p$ with $\#A = \#S+1 = m+1$.
**Output:** the (essentially unique, by Theorem 3.5) $f$ supported on $A$ with $\widehat f|_S = 0$.

Form the $(m+1)\times m$ matrix $E_{ij} = \omega^{\alpha_i \sigma_j}$ ($\alpha_i \in A$, $\sigma_j \in S$) and compute a null vector of $E^{\mathsf T}$. Cofactor expansion gives a closed form: taking $f(\alpha_i) = (-1)^i \det E^{(i)}$, where $E^{(i)}$ deletes row $i$, yields a valid solution, and by Chebotarev every one of these $m\times m$ minors is nonzero — so the extremal function has *full* support $A$, as Theorem 3.4 predicts. Cost: $O(m^3)$ by Gaussian elimination, or $O(m^4)$ via the cofactor formula.

### 6.3 Combinatorial sparse decoder

**Input:** measurements $y_s = \widehat f(s)$ for $s \in S$ with $\#S = 2k$; promise that $f$ is $k$-sparse.
**Output:** $f$ (unique by Theorem 4.1).

*Support-enumeration decoder.* For each candidate support $A$ with $\#A = k$, solve the $\#S \times k$ overdetermined system $\sum_{a\in A} f(a)\,\omega^{as} = y_s$ ($s \in S$) in least squares; accept $A$ if the residual is zero. By Theorem 2.14 (full row rank) the system has at most one solution for each $A$, and by Theorem 4.1 exactly one candidate support yields a consistent system whenever the promise holds. Complexity $O\!\big(\binom{p}{k}\,k^2\,\#S\big)$ — exponential in $k$, but with a *deterministic* guarantee for every measurement set.

*Prony-style decoder.* When $S$ is an arithmetic progression of length $2k$, the classical Prony/Berlekamp–Massey approach applies: build the $k \times k$ Hankel matrix of measurements, solve for the annihilating filter, and find its roots among the $p$-th roots of unity to recover the support in $O(k^3 + kp)$ operations. The Chebotarev machinery explains *why* the Hankel matrix is invertible for genuinely $k$-sparse signals, and Theorem 4.1 extends the identifiability guarantee to arbitrary (non-progression) measurement sets, at the price of losing the fast algorithm.

---

## 7. Discussion

### 7.1 Primality as the exact hypothesis

Theorem 2.15 shows that the entire chain of results is a *prime-order phenomenon*, and instructively so. For composite $M = de$, the function $f = \mathbf{1}_{e\mathbb{Z}/M}$ — the indicator of the subgroup of order $d$ — has $\#\operatorname{supp} f = d$ and $\widehat f$ supported on the annihilator subgroup of order $e$; then
$$\#\operatorname{supp} f + \#\operatorname{supp}\widehat f = d + e,$$
which for $M$ large and $d \approx e \approx \sqrt{M}$ is around $2\sqrt{M}$, dramatically smaller than $M+1$. The multiplicative bound $de = M$ is attained exactly; the additive bound fails spectacularly. Subgroups are the enemy, and primes have none. Exhaustive enumeration over all indicator signals for $M \le 12$ confirms that the minimum of $\#\operatorname{supp} f + \#\operatorname{supp}\widehat f$ equals $M+1$ exactly for the primes and $\min_{d \mid M,\ 1<d<M}(d + M/d)$ for the composites, the minimiser always being a subgroup indicator.

The same subgroup indicator is the reason compressed sensing over composite moduli fails deterministically: two distinct sparse signals differing by a subgroup indicator are invisible to any measurement set avoiding the annihilator.

### 7.2 Relation to other proofs and to the polynomial method

Frenkel's proof is a *deformation* argument: the vanishing of a complex determinant is transported to a divisibility statement about a single integer, $[X^{N}]P$. It has the flavour of the polynomial method — introduce a polynomial whose low-order behaviour is forced, then evaluate the obstruction at a distinguished point — and it is worth noting that the Combinatorial Nullstellensatz proof of Cauchy–Davenport is also a polynomial-method argument. Our route reaches Cauchy–Davenport through analysis rather than directly, and so exposes a different mechanism: the sumset bound is a *support* statement, and support statements are exactly what an uncertainty principle controls.

Tao's original derivation of Theorem 3.1 from Chebotarev is the same as ours; the additional contributions here are the sharpness on arbitrary supports (Theorem 3.4), the rigidity of extremal kernels (Theorem 3.5), the matching lower bound for sparse recovery (Theorem 4.2), and the explicit necessity of primality in full generality (Theorem 2.15).

### 7.3 Noise and stability

Theorem 4.1 is an exact-arithmetic statement. In floating point, the relevant quantity is not whether $\det F_p[A,B] \ne 0$ but *how small* it is relative to the natural scale: since all entries have modulus $1$, the Hadamard bound gives $|\det F_p[A,B]| \le n^{n/2}$, and the reconstruction error is governed by the normalised quantity $|\det F_p[A,B]|\,/\,n^{n/2}$. Chebotarev's theorem guarantees the qualitative statement for every $A,B$ but says nothing quantitative. Explicit lower bounds on $|\det F_p[A,B]|$ (effective versions of Chebotarev) are the natural stability question, and §8 formulates one.

### 7.4 Numerical illustration

Direct computation confirms the picture. For $p = 7$ all $3431$ square minors of $F_7$ (over all sizes $n = 1,\dots,7$) are nonsingular; the smallest determinant modulus encountered is $\approx 0.868$, attained at size $n=2$, while the largest, $7^{7/2} \approx 907$, is attained by the full matrix. For $M = 8$, by contrast, $1396$ of the $12869$ square minors are singular, among them rows $\{0,4\}$, columns $\{0,2\}$, whose $2\times 2$ determinant is $\zeta^{8}-1 = 0$; and the count of singular minors grows quickly with the number of divisors of $M$ ($4$ of $69$ for $M=4$, $120$ of $923$ for $M=6$). On the analytic side, random signals on $\mathbb{Z}/11$ never violate $\#\operatorname{supp} f + \#\operatorname{supp}\widehat f \ge 12$, and the explicitly constructed extremal functions realise equality on every prescribed support size, whereas over $\mathbb{Z}/12$ the subgroup indicator $\mathbf 1_{4\mathbb{Z}/12}$ achieves $3 + 4 = 7$, far below $M+1 = 13$.

---

## 8. Future directions

**Exact singularity locus for composite moduli.** For every $M$ and all $A, B \subseteq \mathbb{Z}/M$ with $\#A = \#B = n$, we conjecture that the submatrix $\big(\zeta_M^{ab}\big)$ is singular *if and only if* there is a divisor $d \mid M$ with $1 < d < M$ and a coset decomposition of $A$ and $B$ witnessing a vanishing sum of $d$-th roots of unity. For $M$ prime the locus is empty (Theorem 2.1); for every composite $M$ a singular $2\times 2$ minor already exists (Theorem 2.15), namely $A = \{0, M/d\}$, $B = \{0,d\}$. The key insight is that the only obstruction to nonsingularity is the reducibility of the *set* of $M$-th roots of unity into subgroup orbits: vanishing sums of $M$-th roots of unity are generated by the full sums over prime-order subgroups, and each such relation should produce exactly one singular minor pattern.

**Effective Chebotarev.** Find explicit lower bounds for $|\det F_p[A,B]|$ in terms of $p$ and $n$ — for example, is $|\det F_p[A,B]| \ge c(n)\, p^{-C n^2}$ for absolute constants? The integrality certificate of §6.1 controls the algebraic norm of the determinant and should yield a first bound; sharper bounds would immediately give stability guarantees for the sparse recovery of §4 in the presence of noise.

**Higher-rank and non-cyclic analogues.** Which of these statements survive over $(\mathbb{Z}/p)^d$, where the "minors" become submatrices indexed by subsets of $\mathbb{F}_p^d$? Here the uncertainty principle $\#\operatorname{supp} f \cdot \#\operatorname{supp}\widehat f \ge p^d$ is sharp on subspaces, so the additive strengthening must fail; but a restricted version for sets in general position may hold.

**Sharp constants in additive combinatorics.** Vosper's theorem describes the extremal configurations for Cauchy–Davenport (arithmetic progressions with the same common difference). Can the rigidity result of Theorem 3.5 be leveraged to obtain a Fourier-analytic proof of Vosper's theorem, and beyond it a Freiman-type structure theorem?

**Fast deterministic decoding.** Is there an algorithm recovering a $k$-sparse signal from an arbitrary set of $2k$ Fourier coefficients in time polynomial in $k$ and $\log p$? The support-enumeration decoder is exponential in $k$; the Prony decoder is fast but requires structured measurement sets. Closing this gap would make the deterministic guarantee of Theorem 4.1 algorithmically usable.

---

## 9. Conclusion

Chebotarev's theorem is a statement about arithmetic rigidity: at prime order, the roots of unity admit no unexpected linear relations, and consequently no square block of the Fourier matrix collapses. We have given a complete proof by deformation to an integer polynomial, together with the exact quantitative statement — the deformed determinant vanishes to order precisely $\binom{n}{2}$ with a leading coefficient prime to $p$ — and shown that primality is not merely sufficient but necessary.

The consequences form a chain of increasing concreteness: an uncertainty principle with an additive, and sharp, bound; an exact identifiability threshold of $2k$ measurements for $k$-sparse signals, valid for every measurement pattern; and a classical additive-combinatorial inequality obtained by convolving two extremal functions. The moral is that arithmetic rigidity, analytic uncertainty, and combinatorial expansion are three descriptions of the same underlying fact — and that the fact holds precisely at the primes.
