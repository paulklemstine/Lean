# The Additive Uncertainty Principle on Cyclic Groups of Prime Order

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Let $p$ be a prime and let $f : \mathbb{Z}/p\mathbb{Z} \to \mathbb{C}$ be a nonzero function with discrete Fourier transform $\hat f(k) = \sum_x e^{-2\pi i kx/p} f(x)$. We give a complete and self-contained development of the *additive* uncertainty principle
$$|\operatorname{supp} f| + |\operatorname{supp} \hat f| \;\ge\; p + 1,$$
strictly stronger than the classical multiplicative bound $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \ge p$ that holds for every modulus. The engine is Chebotarev's theorem: for prime $p$, every square submatrix of the Fourier matrix $(\zeta^{xy})_{x,y \in \mathbb{Z}/p\mathbb{Z}}$, $\zeta$ a primitive $p$-th root of unity, is nonsingular. We present Frenkel's elementary proof of Chebotarev's theorem in full detail, based on the order of vanishing at $1$ of the integer polynomial $\det(X^{a_ib_j})$ and on the identity $\big(\prod_{j<k} j!\big)G_N = V(a)V(b)$ relating its critical coefficient to a product of Vandermonde determinants.

We then derive a family of consequences. (i) An **exact converse**: for *every* pair of subsets $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$ with $|A| + |B| = p+1$ there exists $f$ with $\operatorname{supp} f = A$ and $\operatorname{supp}\hat f = B$; the inequality is therefore sharp at every boundary point, not merely in isolated examples. (ii) A **primality criterion**: for $n \ge 2$ the additive bound holds for all nonzero $f : \mathbb{Z}/n\mathbb{Z}\to\mathbb{C}$ if and only if $n$ is prime, with subgroup indicators supplying explicit counterexamples $|\operatorname{supp} f| + |\operatorname{supp}\hat f| = d + e \le n$ whenever $n = de$, $d,e \ge 2$. (iii) **Deterministic sparse recovery**: any $k$-sparse signal is determined by its Fourier data on an arbitrary set of $2k$ frequencies, and $2k-1$ frequencies never suffice, for any sampling pattern. (iv) A **Fourier interpolation theorem**: for arbitrary $A, B$ with $|A| = |B|$ and arbitrary prescribed data, there is a unique signal vanishing off $A$ whose transform matches the data on $B$; equivalently every rectangular $A\times B$ block of the Fourier matrix has rank exactly $\min(|A|,|B|)$. (v) A **zero-counting theorem**: for nonzero $f$, the transform $\hat f$ vanishes at strictly fewer than $|\operatorname{supp} f|$ frequencies.

---

## 1. Introduction

### 1.1 Setting and notation

Fix an integer $n \ge 2$ and write $\zeta_n = e^{-2\pi i / n}$, a primitive $n$-th root of unity. For $f : \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$ define the **discrete Fourier transform**
$$\hat f(k) \;=\; \sum_{x \in \mathbb{Z}/n\mathbb{Z}} \zeta_n^{\,\overline{k}\,\overline{x}}\, f(x), \qquad k \in \mathbb{Z}/n\mathbb{Z},$$
where $\overline{y} \in \{0,1,\dots,n-1\}$ is the canonical representative of $y$. The **support** is
$$\operatorname{supp} f \;=\; \{x \in \mathbb{Z}/n\mathbb{Z} : f(x) \neq 0\},$$
a finite set whose cardinality we denote $|\operatorname{supp} f|$. A signal is **$k$-sparse** if $|\operatorname{supp} f| \le k$.

Concretely, $\hat f = M f$ where $M$ is the $n \times n$ **Fourier matrix** $M_{k,x} = \zeta_n^{\overline{k}\overline{x}}$. Since $M \overline{M}^{\,T} = nI$, the transform is invertible, so $f$ and $\hat f$ encode the same information.

### 1.2 The two uncertainty principles

The classical Donoho–Stark bound, valid for every modulus $n$ and every nonzero $f$, is multiplicative:
$$|\operatorname{supp} f| \cdot |\operatorname{supp} \hat f| \;\ge\; n. \tag{1.1}$$
It follows from the elementary estimate $\|\hat f\|_\infty \le \|f\|_1 \le |\operatorname{supp} f| \cdot \|f\|_\infty$ combined with the inverse transform. For prime moduli a strictly stronger, additive bound holds; it goes back to Tao's use of Chebotarev's theorem.

**Theorem A (additive uncertainty principle).** *Let $p$ be prime and $f : \mathbb{Z}/p\mathbb{Z}\to\mathbb{C}$ nonzero. Then*
$$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \;\ge\; p + 1.$$

That Theorem A implies (1.1) is pure arithmetic: if $\alpha,\beta \ge 1$ and $\alpha + \beta \ge P + 1$ then $\alpha\beta \ge \alpha + \beta - 1 \ge P$, since $(\alpha - 1)(\beta - 1) \ge 0$. The converse implication fails, and quantifiably so.

**Proposition B (strict strengthening).** *For $p = 13$ the pair $|\operatorname{supp} f| = |\operatorname{supp}\hat f| = 4$ satisfies the multiplicative bound $4\cdot 4 = 16 \ge 13$, yet no nonzero $f : \mathbb{Z}/13\mathbb{Z}\to\mathbb{C}$ realises it, because $4 + 4 = 8 < 14$.*

More generally, whenever $\sqrt{p} \le \alpha,\beta$ and $\alpha + \beta \le p$, the product bound permits a support pattern that the additive bound forbids; the balanced regime $\alpha = \beta \approx \sqrt p$ is exactly the region where the two statements differ most.

### 1.3 Overview

Section 2 states and proves Chebotarev's total nonsingularity theorem following Frenkel. Section 3 deduces Theorem A and its exact converse. Section 4 establishes the primality criterion. Section 5 develops the linear-algebraic consequences (interpolation, rank of minors, zero counting). Section 6 gives the sparse-recovery results and algorithms. Section 7 discusses scope, related phenomena, and open directions.

Everything below is elementary in the sense that it uses only determinants, binomial identities, the irreducibility of the cyclotomic polynomial $\Phi_p$, and finite-dimensional linear algebra.

---

## 2. Chebotarev's theorem on the minors of the prime Fourier matrix

### 2.1 Statement

**Theorem 2.1 (Chebotarev, 1926).** *Let $p$ be prime, let $\zeta \in \mathbb{C}$ be a primitive $p$-th root of unity, let $k \ge 0$, and let $a_1,\dots,a_k$ and $b_1,\dots,b_k$ be two sequences of pairwise distinct elements of $\{0,1,\dots,p-1\}$. Then*
$$\det\big(\zeta^{\,a_i b_j}\big)_{1\le i,j\le k} \;\neq\; 0 .$$

Equivalently: every square submatrix of the $p\times p$ Fourier matrix is invertible. We call this property **total nonsingularity**.

Primality is essential. For $n = 4$ and $\zeta = i$, rows $\{0,2\}$ and columns $\{0,2\}$ give $\begin{pmatrix} 1 & 1 \\ 1 & 1\end{pmatrix}$, singular. In general, if $n = de$ with $d,e\ge 2$, the block indexed by the annihilator pair $(e\mathbb{Z}/n, d\mathbb{Z}/n)$ is a rank-one all-ones matrix of size $\min(d,e) \ge 2$.

### 2.2 Frenkel's proof

Fix $a = (a_i)$ and $b = (b_j)$ as in the theorem and introduce the integer polynomial
$$F(X) \;=\; \det\big(X^{\,a_i b_j}\big)_{i,j} \;\in\; \mathbb{Z}[X], \qquad G(X) \;=\; F(X+1).$$
Set
$$N \;=\; 0 + 1 + \cdots + (k-1) \;=\; \binom{k}{2}, \qquad \mathrm{sf}(k) \;=\; \prod_{j=0}^{k-1} j! \quad (\text{the superfactorial}),$$
and let $V(a) = \prod_{i<j}(a_j - a_i)$ denote the Vandermonde determinant of $a$, i.e. $V(a) = \det(a_i^{\,j-1})_{i,j}$.

The proof rests on two lemmas about the coefficients of $G$, and one arithmetic lemma.

#### Step 1: coefficients of $G$ as signed sums of binomial coefficients

**Lemma 2.2.** *For every $d \ge 0$,*
$$G_d \;:=\; [X^d]\,G(X) \;=\; \sum_{\sigma \in S_k} \operatorname{sgn}(\sigma)\binom{\sum_{i} a_{\sigma(i)}b_i}{d}.$$

*Proof.* By the Leibniz formula, $G(X) = \det((X+1)^{a_ib_j}) = \sum_\sigma \operatorname{sgn}(\sigma)\prod_i (X+1)^{a_{\sigma(i)}b_i} = \sum_\sigma \operatorname{sgn}(\sigma)(X+1)^{s_\sigma}$ where $s_\sigma = \sum_i a_{\sigma(i)}b_i$. Now extract the coefficient of $X^d$ from each $(X+1)^{s_\sigma}$. $\square$

#### Step 2: from binomials to alternating power sums

Define the **alternating power sums**
$$T_r \;=\; \sum_{\sigma \in S_k} \operatorname{sgn}(\sigma)\, s_\sigma^{\,r}, \qquad s_\sigma = \sum_i a_{\sigma(i)} b_i .$$
Let $D_d(X) = X(X-1)\cdots(X-d+1) = \sum_{r=0}^{d} c_{d,r}X^r$ be the falling factorial, a monic polynomial of degree $d$ with integer coefficients, so that $d!\binom{y}{d} = D_d(y)$ for all integers $y$.

**Lemma 2.3.** *For every $d\ge 0$,* $\;d!\, G_d = \sum_{r=0}^{d} c_{d,r} T_r$.

*Proof.* Multiply Lemma 2.2 by $d!$ and substitute $d!\binom{s_\sigma}{d} = D_d(s_\sigma) = \sum_r c_{d,r}s_\sigma^r$; interchange the two finite sums. $\square$

#### Step 3: the alternating power sums vanish below the critical order

**Lemma 2.4 (multinomial expansion).** *For every $r \ge 0$,*
$$T_r \;=\; \sum_{\substack{m : \{1,\dots,k\}\to\mathbb{Z}_{\ge0} \\ \sum_i m_i = r}} \binom{r}{m}\Big(\prod_i b_i^{\,m_i}\Big)\det\big(a_i^{\,m_j}\big)_{i,j},$$
*where $\binom{r}{m} = r!/\prod_i m_i!$ is the multinomial coefficient.*

*Proof.* Expand $s_\sigma^r = \big(\sum_i a_{\sigma(i)}b_i\big)^r$ multinomially, obtaining $\sum_m \binom{r}{m}\prod_i (a_{\sigma(i)}b_i)^{m_i}$. Summing over $\sigma$ with signs and separating the $b$-factors gives $\sum_m \binom{r}{m}\prod_i b_i^{m_i}\sum_\sigma \operatorname{sgn}(\sigma)\prod_i a_{\sigma(i)}^{m_i}$, and the inner alternating sum is precisely the Leibniz expansion of $\det(a_i^{m_j})$. $\square$

**Lemma 2.5.** *If the exponent vector $m$ is not injective then $\det(a_i^{m_j}) = 0$.*

*Proof.* If $m_{j_1} = m_{j_2}$ with $j_1 \ne j_2$, the matrix has two identical columns. $\square$

**Lemma 2.6 (minimal sum of an injective vector).** *If $m : \{1,\dots,k\}\to\mathbb{Z}_{\ge 0}$ is injective then $\sum_i m_i \ge N = 0+1+\cdots+(k-1)$, with equality if and only if $\{m_1,\dots,m_k\} = \{0,1,\dots,k-1\}$.*

*Proof.* Induct on the largest element. For a finite set $S \subseteq \mathbb{Z}_{\ge0}$ with maximum $a$ and $S' = S\setminus\{a\}$, we have $S' \subseteq \{0,\dots,a-1\}$, so $|S'| \le a$; by induction $\sum_{x\in S'} x \ge \binom{|S'|}{2}$, whence $\sum_{x\in S} x \ge \binom{|S'|}{2} + a \ge \binom{|S'|}{2} + |S'| = \binom{|S|}{2}$. Equality forces $a = |S'| = |S|-1$ and equality for $S'$, i.e. $S = \{0,\dots,|S|-1\}$ by induction. $\square$

**Proposition 2.7.** $T_r = 0$ *for every* $r < N$, *and consequently* $G_d = 0$ *for every* $d < N$.

*Proof.* By Lemma 2.4 only injective $m$ contribute (Lemma 2.5); by Lemma 2.6 an injective $m$ has $\sum m_i \ge N > r$, so no injective $m$ occurs in the sum defining $T_r$. Hence $T_r = 0$. Lemma 2.3 then gives $d!\,G_d = 0$ for $d < N$, and $d! \ne 0$. $\square$

#### Step 4: the critical coefficient is a Vandermonde product

**Proposition 2.8.** $\mathrm{sf}(k)\, T_N = N!\, V(a)\, V(b)$, *and therefore*
$$\mathrm{sf}(k)\; G_N \;=\; V(a)\,V(b).$$

*Proof.* By Lemmas 2.4–2.6, the only exponent vectors contributing to $T_N$ are the bijections $m : \{1,\dots,k\}\to\{0,\dots,k-1\}$, i.e. $m_j = \tau(j)-1$ for a permutation $\tau \in S_k$ (write $m = \theta_\tau$). For such $m$:

* $\det(a_i^{\,\theta_\tau(j)})$ is the Vandermonde matrix $\det(a_i^{\,j-1})$ with its columns permuted by $\tau$, hence equals $\operatorname{sgn}(\tau)V(a)$;
* $\prod_i b_i^{\theta_\tau(i)}$ summed against $\operatorname{sgn}(\tau)$ over all $\tau$ reproduces $V(b)$, because $V(b) = \sum_\tau \operatorname{sgn}(\tau)\prod_i b_i^{\theta_\tau(i)}$ is exactly the Leibniz expansion of the transposed Vandermonde matrix;
* the multinomial coefficient is $\binom{N}{\theta_\tau} = N!/\prod_j \theta_\tau(j)! = N!/\mathrm{sf}(k)$, independent of $\tau$.

Assembling, $T_N = \frac{N!}{\mathrm{sf}(k)}\,V(a)\sum_\tau \operatorname{sgn}(\tau)\prod_i b_i^{\theta_\tau(i)} = \frac{N!}{\mathrm{sf}(k)}V(a)V(b)$. For the second identity apply Lemma 2.3 at $d = N$: all $T_r$ with $r<N$ vanish and $c_{N,N}=1$, so $N!\,G_N = T_N$; combine with the first identity and cancel $N! \neq 0$. $\square$

#### Step 5: the arithmetic contradiction

**Lemma 2.9.** *If $a_1,\dots,a_k$ are pairwise distinct elements of $\{0,\dots,p-1\}$ then $p \nmid V(a)$.*

*Proof.* $V(a) = \prod_{i<j}(a_j - a_i)$ and $p$ is prime, so $p \mid V(a)$ would force $p \mid (a_j - a_i)$ for some $i<j$. But $0 < |a_j - a_i| < p$, a contradiction. $\square$

*Proof of Theorem 2.1.* Suppose $\det(\zeta^{a_ib_j}) = 0$, i.e. $F(\zeta) = 0$. Since $\zeta$ is a primitive $p$-th root of unity, its minimal polynomial over $\mathbb{Q}$ is the cyclotomic polynomial $\Phi_p(X) = 1 + X + \cdots + X^{p-1}$, which is monic with integer coefficients; hence $\Phi_p \mid F$ in $\mathbb{Z}[X]$, say $F = \Phi_p H$. Shifting, $G(X) = F(X+1) = g(X)\,H(X+1)$ with $g(X) = \Phi_p(X+1)$.

The constant coefficient of $g$ is $\Phi_p(1) = p \ne 0$, so $g$ has trailing degree $0$ and trailing coefficient $p$. By Propositions 2.7 and 2.8, $G$ has all coefficients below degree $N$ equal to $0$, and $G_N \ne 0$ (indeed $\mathrm{sf}(k)G_N = V(a)V(b) \ne 0$ by Lemma 2.9); so $G$ has trailing degree exactly $N$ and trailing coefficient $G_N$. Trailing coefficients are multiplicative, so
$$G_N \;=\; p \cdot \big(\text{trailing coefficient of } H(X+1)\big),$$
an integer multiple of $p$. Then $p \mid \mathrm{sf}(k) G_N = V(a)V(b)$, so $p$ divides $V(a)$ or $V(b)$, contradicting Lemma 2.9. $\blacksquare$

**Remark 2.10.** The proof is constructive in spirit: it exhibits an explicit integer, $\mathrm{sf}(k)^{-1}V(a)V(b)$, which would have to be divisible by $p$ if the minor vanished. This gives a quantitative flavour: the "first nonzero jet" of $F$ at $X = 1$ is a Vandermonde product, and primality precisely blocks the divisibility that a vanishing minor would impose.

---

## 3. The additive uncertainty principle and its exact converse

### 3.1 Proof of Theorem A

*Proof of Theorem A.* Let $A = \operatorname{supp} f$ with $|A| = \alpha \ge 1$ and $B = \operatorname{supp}\hat f$ with $|B| = \beta$. Suppose for contradiction $\alpha + \beta \le p$. Then $|B^c| = p - \beta \ge \alpha$, so we may choose $R \subseteq B^c$ with $|R| = \alpha$. Because $\hat f$ vanishes on $B^c \supseteq R$ and $f$ vanishes off $A$,
$$0 \;=\; \hat f(k) \;=\; \sum_{x \in A} \zeta^{\,\overline{k}\,\overline{x}} f(x) \qquad \text{for all } k \in R .$$
This says the vector $(f(x))_{x\in A} \in \mathbb{C}^\alpha$ lies in the kernel of the $\alpha\times\alpha$ matrix $\big(\zeta^{\,\overline{k}\,\overline{x}}\big)_{k\in R,\, x\in A}$, which is a square submatrix of the Fourier matrix. By Theorem 2.1 that matrix is invertible, so $f|_A = 0$; since $f$ vanishes off $A$ too, $f = 0$, contradicting $f \ne 0$. $\blacksquare$

### 3.2 Sharpness

**Proposition 3.1 (extremal examples).** *Let $p$ be prime.*
1. *For the delta $\delta_c(x) = [x = c]$ one has $|\operatorname{supp}\delta_c| = 1$ and $|\operatorname{supp}\widehat{\delta_c}| = p$, total $p+1$.*
2. *For the constant $f \equiv 1$ one has $|\operatorname{supp} f| = p$ and $|\operatorname{supp}\hat f| = 1$, total $p+1$.*

*Proof.* $\widehat{\delta_c}(k) = \zeta^{\overline{k}\overline{c}}$ never vanishes, giving (1). For (2), $\hat f(k) = \sum_x \zeta^{\overline{k}\overline{x}}$ equals $p$ at $k=0$ and $0$ otherwise (geometric series). Alternatively, in each case the lower bound of Theorem A and the trivial upper bound $|\operatorname{supp}\hat f| \le p$ pin the total. $\square$

The much stronger fact is that the entire boundary is attained, in every position.

**Theorem C (exact converse).** *Let $p$ be prime and let $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$ satisfy $|A| + |B| = p+1$. Then there exists $f : \mathbb{Z}/p\mathbb{Z}\to\mathbb{C}$ with*
$$\operatorname{supp} f = A \qquad\text{and}\qquad \operatorname{supp}\hat f = B .$$

*Proof sketch.* Write $\alpha = |A| \ge 1$, $\beta = |B|$, so $|B^c| = p - \beta = \alpha - 1$. Consider the linear map
$$\Psi : \{f : \operatorname{supp} f \subseteq A\} \longrightarrow \mathbb{C}^{B^c}, \qquad \Psi(f) = \big(\hat f(k)\big)_{k \in B^c},$$
represented by the $(\alpha-1)\times\alpha$ matrix $\big(\zeta^{\overline{k}\overline{x}}\big)_{k\in B^c, x\in A}$. By Theorem 2.1 every $(\alpha-1)\times(\alpha-1)$ minor of this matrix is nonzero, so it has full row rank $\alpha-1$ and $\ker\Psi$ is one-dimensional. Let $f$ span the kernel.

*The support of $f$ is all of $A$.* If $f(x_0) = 0$ for some $x_0 \in A$, then $f$ restricted to $A\setminus\{x_0\}$ is a nonzero kernel vector of the square $(\alpha-1)\times(\alpha-1)$ submatrix with columns $A\setminus\{x_0\}$, contradicting Theorem 2.1.

*The support of $\hat f$ is all of $B$.* By construction $\hat f$ vanishes on $B^c$, so $\operatorname{supp}\hat f \subseteq B$. If the inclusion were strict, then $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \le \alpha + \beta - 1 = p$, contradicting Theorem A (note $f \ne 0$). $\square$

Two comments. First, Theorem C shows the additive principle is optimal *pointwise on its boundary*: no refinement of the form "$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \ge p+1$, with extra constraints on the positions of the supports" can hold. Second, the argument produces $f$ by solving a single linear system; Section 6 turns this into an algorithm.

**Corollary 3.2 (the boundary is attained everywhere).** *For $p$ prime and every $\alpha$ with $1 \le \alpha \le p$, the pair $(\alpha, p+1-\alpha)$ is realised as $(|\operatorname{supp} f|,|\operatorname{supp}\hat f|)$, and moreover the two supports may be prescribed to be any sets of those two sizes.*

*Proof.* Immediate from Theorem C. $\square$

In particular the inequality of Theorem A cannot be improved for any admissible split of $p+1$, nor for any placement of the supports.

---

## 4. Primality is necessary: a criterion

Let $n \ge 2$ be arbitrary and suppose $n = de$ with $d, e \ge 1$. Write $\zeta = \zeta_n = e^{-2\pi i/n}$.

**Definition 4.1.** The **subgroup indicator** $u_{n,d} : \mathbb{Z}/n\mathbb{Z}\to\mathbb{C}$ is the indicator of the subgroup $d\mathbb{Z}/n\mathbb{Z} = \{x : d \mid \overline{x}\}$:
$$u_{n,d}(x) = \begin{cases} 1, & d \mid \overline{x},\\ 0,&\text{otherwise.}\end{cases}$$

**Lemma 4.2 (support).** *If $n = de$ then $|\operatorname{supp} u_{n,d}| = e$.*

*Proof.* The elements of $\{0,\dots,n-1\}$ divisible by $d$ are $0, d, 2d, \dots, (e-1)d$, and these are pairwise distinct modulo $n$. $\square$

**Lemma 4.3 (finite Poisson summation).** *If $n = de$ then for all $k$,*
$$\widehat{u_{n,d}}(k) \;=\; \sum_{j=0}^{e-1}\big(\zeta^{\,\overline k\, d}\big)^{j} \;=\; \begin{cases} e, & e \mid \overline{k},\\ 0, & \text{otherwise.}\end{cases}$$

*Proof.* The first equality re-indexes the defining sum over the subgroup. Put $w = \zeta^{\overline{k}d}$. Since $\zeta$ is a primitive $n$-th root of unity, $w = 1$ iff $n \mid \overline{k}d$ iff $e \mid \overline{k}$. If $w = 1$ the geometric sum is $e$; otherwise $\sum_{j<e} w^j = (w^e-1)/(w-1) = 0$ because $w^e = \zeta^{\overline k d e} = \zeta^{\overline k n} = 1$. $\square$

**Corollary 4.4.** *If $n = de$ with $e \ge 1$ then $|\operatorname{supp}\widehat{u_{n,d}}| = d$: the transform of the indicator of a subgroup is a multiple of the indicator of its annihilator.*

**Theorem D (primality criterion).** *Let $n \ge 2$. The additive uncertainty bound*
$$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \;\ge\; n+1 \quad\text{for all nonzero } f:\mathbb{Z}/n\mathbb{Z}\to\mathbb{C}$$
*holds if and only if $n$ is prime.*

*Proof.* If $n$ is prime this is Theorem A. If $n$ is composite, write $n = de$ with $2 \le d$ and $2 \le e$ (possible for every composite $n \ge 4$: take $d$ any nontrivial divisor). Then $u_{n,d} \ne 0$ (it is $1$ at $0$) and by Lemmas 4.2, 4.4,
$$|\operatorname{supp} u_{n,d}| + |\operatorname{supp}\widehat{u_{n,d}}| \;=\; e + d \;\le\; de \;=\; n \;<\; n+1,$$
using $(d-1)(e-1)\ge 1$. $\blacksquare$

**Remark 4.5 (the failure is quantitatively worst at balanced factorisations).** The deficit is $n + 1 - (d+e) = de - d - e + 1 = (d-1)(e-1)$, maximised for balanced $d \approx e \approx \sqrt n$. In that case the additive bound fails by roughly $n - 2\sqrt n$, while the multiplicative bound is *exactly tight*: $d\cdot e = n$. Subgroup indicators are thus simultaneously the extremal examples for (1.1) and the fatal counterexamples for the additive bound.

**Example 4.6 ($n=4$).** $f = u_{4,2} = (1,0,1,0)$ has $\hat f = (2,0,2,0)$; both supports have size $2$, total $4 < 5$, while the product is $4 = n$.

---

## 5. Linear-algebraic consequences

Throughout this section $p$ is prime and $\zeta$ is a primitive $p$-th root of unity.

**Definition 5.1.** For $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$ let $M_{A,B}$ denote the $|B|\times|A|$ matrix (rows indexed by frequencies in $B$, columns by positions in $A$)
$$\big(M_{A,B}\big)_{k,x} \;=\; \zeta^{\,\overline{k}\,\overline{x}}, \qquad k \in B,\ x\in A .$$

**Theorem E (Fourier interpolation).** *Let $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$ with $|A| = |B|$, and let $g : B \to \mathbb{C}$ be arbitrary. Then there is exactly one $f : \mathbb{Z}/p\mathbb{Z}\to\mathbb{C}$ with $f = 0$ off $A$ and $\hat f(k) = g(k)$ for all $k \in B$.*

*Proof.* For $f$ vanishing off $A$ we have $\hat f(k) = \sum_{x\in A}\zeta^{\overline k \overline x}f(x)$, so the condition is the square linear system $M_{A,B}\,(f(x))_{x\in A} = (g(k))_{k\in B}$. By Theorem 2.1 the matrix $M_{A,B}$ is invertible; existence and uniqueness follow. $\square$

This is a deterministic interpolation statement with *no genericity hypothesis whatsoever* on the position of $A$ or $B$. Splitting into the two inequality regimes:

**Corollary 5.2 (restricted surjectivity).** *If $|B| \le |A|$, then for every $g$ there is an $f$ vanishing off $A$ with $\hat f|_B = g|_B$.* (Shrink $A$ to a subset $A'$ with $|A'| = |B|$ and apply Theorem E.)

**Corollary 5.3 (restricted injectivity).** *If $|A| \le |B|$ and $f_1, f_2$ both vanish off $A$ with $\hat f_1|_B = \hat f_2|_B$, then $f_1 = f_2$.* (Shrink $B$ to $B'$ with $|B'| = |A|$ and apply uniqueness in Theorem E.)

**Theorem F (rank of an arbitrary minor).** *For all $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$,* $\operatorname{rank} M_{A,B} = \min(|A|,|B|)$.

*Proof.* The rank is at most the number of rows and at most the number of columns, hence at most $r := \min(|A|,|B|)$. Conversely pick $A'\subseteq A$, $B'\subseteq B$ with $|A'| = |B'| = r$; the submatrix $M_{A',B'}$ is invertible by Theorem 2.1, so it contributes a nonzero $r\times r$ minor and $\operatorname{rank} M_{A,B}\ge r$. $\square$

Theorem F is total nonsingularity in rank form: *every* rectangular block of the prime Fourier matrix has maximal rank. In compressed-sensing language, every column submatrix of the $p\times p$ Fourier matrix with at most $|B|$ columns is injective on $\mathbb{C}^{A}$ as soon as $|A|\le|B|$ — the spark of the Fourier matrix restricted to any $|B|$ rows is exactly $|B|+1$, the largest conceivable value.

**Theorem G (zero counting; "fundamental theorem of algebra" for the DFT).** *For $p$ prime and $f \ne 0$,*
$$\#\{k \in \mathbb{Z}/p\mathbb{Z} : \hat f(k) = 0\} \;<\; |\operatorname{supp} f| .$$

*Proof.* The zero set of $\hat f$ is the complement of $\operatorname{supp}\hat f$, of size $p - |\operatorname{supp}\hat f| \le p - (p+1-|\operatorname{supp} f|) = |\operatorname{supp} f| - 1$ by Theorem A. $\square$

Thus a $k$-sparse signal has a spectrum vanishing at most $k-1$ times, precisely as a nonzero polynomial of degree $k-1$ has at most $k-1$ roots. The analogy is exact: for $f$ supported on $\{x_1,\dots,x_k\}$, $\hat f(k)$ is the value at $\zeta^{\overline{k}}$ of the exponential sum $\sum_j f(x_j) z^{\overline{x_j}}$, and Theorem G says such a sparse "polynomial" cannot vanish at $k$ or more $p$-th roots of unity.

---

## 6. Deterministic sparse recovery

### 6.1 The recovery theorem and its sharp threshold

**Theorem H (sparse recovery).** *Let $p$ be prime, $k \ge 0$, and let $f, g : \mathbb{Z}/p\mathbb{Z}\to\mathbb{C}$ satisfy $|\operatorname{supp} f| \le k$ and $|\operatorname{supp} g|\le k$. If $S \subseteq \mathbb{Z}/p\mathbb{Z}$ has $|S| \ge 2k$ and $\hat f(s) = \hat g(s)$ for all $s\in S$, then $f = g$.*

*Proof.* Let $h = f - g$ and suppose $h \ne 0$. Then $\operatorname{supp} h \subseteq \operatorname{supp} f \cup \operatorname{supp} g$, so $|\operatorname{supp} h| \le 2k$. By linearity $\hat h$ vanishes on $S$, so $|\operatorname{supp}\hat h| \le p - 2k$. Adding, $|\operatorname{supp} h| + |\operatorname{supp}\hat h| \le 2k + (p - 2k) = p < p+1$, contradicting Theorem A. $\square$

Two features deserve emphasis. The sampling set $S$ is **arbitrary** — no randomness, no incoherence condition, no restricted isometry property, and no exceptional patterns. And the guarantee is **exact and universal**, not probabilistic.

**Theorem I (the threshold $2k$ is optimal).** *Let $p$ be prime, $1 \le k$ with $2k \le p$, and let $S\subseteq\mathbb{Z}/p\mathbb{Z}$ be any set with $|S| = 2k-1$. Then there exist $f \ne g$, both $k$-sparse, with $\hat f(s) = \hat g(s)$ for all $s\in S$.*

*Proof.* Choose $A \subseteq \mathbb{Z}/p\mathbb{Z}$ with $|A| = 2k$. The matrix $M_{A,S}$ has $2k-1$ rows and $2k$ columns, so it has a nonzero kernel vector; let $h$ be the corresponding signal supported in $A$, so $h \ne 0$ and $\hat h|_S = 0$. By Theorem 2.1 every $(2k-1)\times(2k-1)$ submatrix of $M_{A,S}$ is invertible, so in fact $h(x)\ne 0$ for every $x\in A$ (as in the proof of Theorem C). Partition $A = A_1 \sqcup A_2$ with $|A_1| = |A_2| = k$, and set
$$f = h\cdot \mathbf{1}_{A_1}, \qquad g = -\,h\cdot\mathbf{1}_{A_2}.$$
Then $f$ and $g$ are $k$-sparse, $f - g = h \ne 0$ so $f \ne g$, and $\hat f - \hat g = \hat h$ vanishes on $S$. $\square$

So $2k$ frequencies always suffice, $2k-1$ frequencies never do, and the transition is pattern-independent. This is an unusually clean state of affairs: in most sampling theories the sharp threshold depends on the geometry of the sampling set.

### 6.2 Algorithms

Theorem E is not only an existence statement, it is a recipe.

**Algorithm 1 (support-constrained interpolation).** *Input:* prime $p$; sets $A, B$ with $|A| = |B| = m$; target data $g : B \to \mathbb{C}$. *Output:* the unique $f$ vanishing off $A$ with $\hat f|_B = g$.
1. Build $M \in \mathbb{C}^{m\times m}$, $M_{k,x} = \zeta^{\overline{k}\overline{x}}$ for $k\in B$, $x \in A$.
2. Solve $M c = g$ by Gaussian elimination with partial pivoting ($O(m^3)$ operations).
3. Return $f$ defined by $f(x) = c_x$ for $x\in A$ and $f = 0$ elsewhere.

Correctness is Theorem E; the system is guaranteed solvable and nonsingular for *every* pair $(A,B)$ by Theorem 2.1.

**Algorithm 2 (extremal-pair construction).** *Input:* prime $p$; sets $A, B$ with $|A|+|B| = p+1$. *Output:* $f$ with $\operatorname{supp} f = A$, $\operatorname{supp}\hat f = B$.
1. Let $R = \mathbb{Z}/p\mathbb{Z}\setminus B$, of size $|A|-1$.
2. Form $M \in \mathbb{C}^{(|A|-1)\times|A|}$ with $M_{k,x} = \zeta^{\overline k\overline x}$, $k \in R$, $x\in A$.
3. Compute a nonzero kernel vector $c$ of $M$ ($O(|A|^3)$); concretely, $c_x = (-1)^{\mathrm{pos}(x)}\det(M \text{ with column } x \text{ deleted})$, a Cramer-style formula guaranteed to give nonzero entries.
4. Return $f$ supported on $A$ with $f|_A = c$.

The determinantal formula in step 3 makes the conclusion "all coordinates nonzero" manifest: the coordinates are exactly the $(|A|-1)\times(|A|-1)$ minors of $M$, all nonzero by Theorem 2.1.

**Algorithm 3 (deterministic $k$-sparse recovery).** *Input:* prime $p$; sparsity $k$; frequency set $S$ with $|S| \ge 2k$; measured data $y = \hat f|_S$ of an unknown $k$-sparse $f$. *Output:* $f$.
1. For each candidate support $A$ with $|A| = k$ (there are $\binom{p}{k}$), solve the least-squares/consistency problem $M_{A,S}c = y$; by Theorem F, $M_{A,S}$ has full column rank $k$, so the system has at most one solution.
2. Return the unique consistent $(A, c)$.

Correctness — in particular the uniqueness of the consistent candidate — is Theorem H. Step 1 is exponential in $k$ as written; the practical route in the classical $k$-sparse setting is Prony's method / the Berlekamp–Massey algorithm applied to $2k$ *consecutive* frequencies, which recovers the support as the roots of an annihilating polynomial in $O(k^2)$ or $O(k\log^2 k)$ operations. Theorem H should be read as the statement that *uniqueness* holds for arbitrary frequency sets, while efficient *algorithms* are classical for structured (e.g. arithmetic-progression) sampling sets.

---

## 7. Discussion

### 7.1 What the additive bound buys over the multiplicative bound

Both bounds constrain the achievable region $\mathcal{R}_p \subseteq \{1,\dots,p\}^2$ of pairs $(|\operatorname{supp} f|, |\operatorname{supp}\hat f|)$. The multiplicative bound gives the hyperbolic region $\alpha\beta\ge p$; the additive bound gives the half-plane $\alpha+\beta\ge p+1$, strictly inside it. The gap is largest in the balanced regime $\alpha\approx\beta\approx\sqrt p$, where the hyperbola permits a total as small as $2\sqrt p$ and the truth is $p+1$. Theorem C says every point of the boundary line $\alpha+\beta = p+1$ is attained, with supports in arbitrary prescribed positions, so the half-plane cannot be shrunk; by Theorem D the hyperbola is the correct description for the extremal composite case in the sense that subgroup indicators attain $\alpha\beta = n$.

### 7.2 Why primes

Every obstruction to the additive bound found in Section 4 is a subgroup. This is not a coincidence: a coset structure is the only way to make both a function and its transform sparse, because the transform of a subgroup indicator is supported on the annihilator, whose size is the index. Cyclic groups of prime order have no proper nontrivial subgroups, so there is no such structure available. The same phenomenon appears in Chebotarev's theorem: the degenerate minors modulo a composite $n$ are exactly the all-ones blocks indexed by annihilator pairs.

### 7.3 The shape of Frenkel's argument

Three ideas combine. (a) *Deformation*: replace the transcendental datum $\zeta$ by a variable, turning a vanishing determinant into a polynomial divisibility. (b) *Order of vanishing*: the shift $X \mapsto X+1$ puts the point of interest at the origin, and the determinant structure forces vanishing to order at least $N = \binom{k}{2}$, because surviving multinomial terms need pairwise distinct exponents. (c) *Identification of the leading jet*: the coefficient at the critical order is, up to the superfactorial, a product of two Vandermonde determinants, whose non-divisibility by $p$ is elementary. The proof uses nothing about $\zeta$ beyond the fact that $\Phi_p(1) = p$.

The identity $\mathrm{sf}(k)\,G_N = V(a)V(b)$ deserves separate mention: it is a purely combinatorial statement about signed sums of binomial coefficients, independent of any root of unity, and can be checked numerically for small $k$.

### 7.4 Related and contrasting results

For the reals or the circle, uncertainty principles are inequalities about measures and variances (Heisenberg, Hardy, Beurling); on finite abelian groups they become counting statements. The multiplicative bound holds for all finite abelian groups. The additive bound is special to prime cyclic groups and, as Theorem D shows, characterises them among cyclic groups. Analogues over $\mathbb{Z}/p^m\mathbb{Z}$, over $(\mathbb{Z}/p\mathbb{Z})^d$, and over general finite abelian groups must therefore take a different, subgroup-sensitive form — for instance a bound in terms of the largest "sparse subgroup pair" available.

### 7.5 Future directions

* **Quantitative stability.** The recovery results here are exact-arithmetic statements. The natural next question is conditioning: what is the smallest singular value of $M_{A,B}$ for arbitrary $A, B$, and how does it degrade with $p$ and $|A|$? Chebotarev guarantees invertibility but no uniform lower bound, and known bounds decay rapidly; sharper estimates would convert exact recovery into noise-robust recovery.
* **Group-theoretic generalisation.** Formulate and prove the sharp support inequality on an arbitrary finite abelian group $G$, presumably of the form $|\operatorname{supp} f| + |\operatorname{supp}\hat f|\ge \min_{H}\big(|H| + [G:H]\big)$ over subgroups $H$ compatible with the support, and identify the extremal functions as coset-modulated subgroup indicators.
* **Effective algorithms for arbitrary sampling sets.** Theorem H gives uniqueness for arbitrary $S$ with $|S| = 2k$; Prony/Berlekamp–Massey gives efficiency for arithmetic progressions. Closing the gap — a polynomial-time recovery algorithm for arbitrary $S$ of size exactly $2k$ — is a concrete open problem.
* **Higher-dimensional and non-abelian settings.** Total nonsingularity fails for $(\mathbb{Z}/p\mathbb{Z})^2$; classifying which minors of a general character table are nonsingular is an attractive question with representation-theoretic content.
* **Structured refinements.** For supports with arithmetic structure (arithmetic progressions, Sidon sets, subgroups of $\mathbb{F}_p^\times$), one expects strengthenings of Theorem G with explicit descriptions of the zero sets of $\hat f$.

---

## 8. Summary of the main results

1. **Total nonsingularity (Chebotarev).** For $p$ prime and $\zeta$ a primitive $p$-th root of unity, every square submatrix of $(\zeta^{xy})$ is invertible.
2. **Additive uncertainty principle.** For $p$ prime and $f\ne0$: $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \ge p+1$; this implies, and is strictly stronger than, $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f|\ge p$.
3. **Exact converse.** Every pair $A,B$ with $|A|+|B| = p+1$ is realised as $(\operatorname{supp} f, \operatorname{supp}\hat f)$.
4. **Primality criterion.** For $n\ge2$ the additive bound holds for all nonzero $f$ on $\mathbb{Z}/n\mathbb{Z}$ iff $n$ is prime; for $n = de$ the subgroup indicator gives $|\operatorname{supp} f| + |\operatorname{supp}\hat f| = d+e\le n$.
5. **Interpolation and rank.** For $|A| = |B|$, prescribed spectral data on $B$ is matched by a unique signal supported in $A$; in general $\operatorname{rank} M_{A,B} = \min(|A|,|B|)$.
6. **Zero counting.** For $f \ne 0$, $\hat f$ vanishes at fewer than $|\operatorname{supp} f|$ frequencies.
7. **Deterministic sparse recovery.** $k$-sparse signals are determined by their spectrum on any $2k$ frequencies, and for every set of $2k-1$ frequencies there are distinct $k$-sparse signals with identical data there.
