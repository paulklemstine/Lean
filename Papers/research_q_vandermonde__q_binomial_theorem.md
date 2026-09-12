# A Division-Free Theory of Gaussian Binomial Coefficients: Rothe's $q$-Binomial Theorem, the $q$-Vandermonde Convolution, and Their Consequences over Arbitrary Commutative Rings

**Author:** Aristotle

**Date:** 2026-09-12

---

## Abstract

We develop the theory of Gaussian binomial coefficients $\binom{n}{k}_q$ from a division-free starting point: instead of the classical quotient of $q$-factorials, we take as definition the $q$-Pascal recursion $\binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{k+1}\binom{n}{k+1}_q$, which makes sense over an arbitrary commutative semiring. From this we derive the second ($q$-reflected) Pascal recursion, Rothe's $q$-binomial theorem
$$\prod_{i=0}^{n-1}(1+q^ix) = \sum_{k=0}^{n} q^{\binom k2}\binom{n}{k}_q x^k,$$
and the $q$-Vandermonde convolution
$$\binom{m+n}{k}_q = \sum_{j=0}^{k} q^{(m-j)(k-j)}\binom{m}{j}_q\binom{n}{k-j}_q,$$
both valid for arbitrary $q$ and $x$ in a commutative ring. The only step in the second proof that is not formally valid over a general ring — cancellation of the factor $q^{\binom k2}$ produced by coefficient extraction — is isolated by a **universality principle**: since $\binom{n}{k}_q$ is a polynomial expression in $q$ with integer coefficients, it commutes with every ring homomorphism, so the identity may be proved once in the integral domain $\mathbb{Z}[X]$ with $q=X$, where cancellation is legitimate, and then transported to every commutative ring by evaluation.

We then deduce, in the same division-free style: the Gauss product formula in cleared form $\binom{n}{k}_q (q;q)_k (q;q)_{n-k} = (q;q)_n$; the symmetry $\binom{n}{k}_q = \binom{n}{n-k}_q$; Gauss' alternating sum; the $q$-analogue $\binom{2n}{n}_q = \sum_j q^{(n-j)^2}\binom{n}{j}_q^2$ of the central binomial identity; the Goldman–Rota recurrence $G_{n+2} = 2G_{n+1} + (q^{n+1}-1)G_n$ for Galois numbers; the Rogers–Szegő three-term ladder $H_{n+2}(x) = (1+x)H_{n+1}(x) + (q^{n+1}-1)xH_n(x)$, with Gauss' evaluations $H_{2m+1}(-1)=0$ and $H_{2m}(-1)=\prod_{i<m}(1-q^{2i+1})$; Cauchy's reciprocal $q$-binomial theorem in unit form, together with the negative $q$-Vandermonde convolution; the polynomiality, monicity, degree $k(n-k)$ and coefficient non-negativity of the universal Gaussian binomial in $\mathbb{Z}[X]$; the $q$-Lucas theorem $\binom{n}{k}_z = \binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\binom{n\bmod d}{k\bmod d}_z$ at a primitive $d$-th root of unity, with the $q=-1$ phenomenon as a special case; and a bridge to finite projective geometry recovering the line counts of $PG(3,q)$.

**Keywords:** Gaussian binomial coefficient, $q$-Pascal recurrence, $q$-binomial theorem, $q$-Vandermonde convolution, $q$-Pochhammer symbol, Galois numbers, Rogers–Szegő polynomials, $q$-Lucas theorem, Grassmannian.

---

## 1. Introduction

The Gaussian binomial coefficient is usually introduced as a quotient. With the $q$-integer $[n]_q = 1 + q + \cdots + q^{n-1}$ and the $q$-factorial $[n]_q! = [1]_q[2]_q\cdots[n]_q$, one sets

$$\binom{n}{k}_q = \frac{[n]_q!}{[k]_q!\,[n-k]_q!}. \tag{1.1}$$

This is convenient but structurally misleading. Formula (1.1) presupposes that the $q$-integers are invertible, which is false in most rings of interest and dramatically false at a root of unity — precisely where the theory is most interesting. Moreover, the fact that (1.1) *is* a polynomial, let alone one with non-negative coefficients, is not visible in the definition.

We therefore adopt a different foundation. Throughout, $R$ is a commutative semiring (a commutative ring when subtraction is needed) and $q \in R$ is arbitrary.

**Definition 1.1 ($q$-Pascal definition).** For $n,k\in\mathbb{N}$ define $\binom{n}{k}_q \in R$ by
$$\binom{n}{0}_q = 1,\qquad \binom{0}{k+1}_q = 0,\qquad \binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{k+1}\binom{n}{k+1}_q. \tag{1.2}$$

Definition 1.1 uses only addition and multiplication. Three things follow immediately and cost nothing:

1. *Universality.* $\binom{n}{k}_q$ is the image of the universal element $\binom{n}{k}_X \in \mathbb{Z}[X]$ (resp. $\mathbb{N}[X]$) under the evaluation $X\mapsto q$; consequently, for every semiring homomorphism $f : R \to S$ one has $f\bigl(\binom{n}{k}_q\bigr) = \binom{n}{k}_{f(q)}$.
2. *Universality is a proof technique.* Any identity between $+,\times$-expressions in $q$ that holds in $\mathbb{Z}[X]$ with $q=X$ holds in every commutative ring. Since $\mathbb{Z}[X]$ is an integral domain, cancellation by a nonzero element is available there and only there.
3. *Positivity.* The recursion never subtracts, so $\binom{n}{k}_X \in \mathbb{N}[X]$; non-negativity of coefficients is automatic rather than a theorem.

The whole development below is organised around (1) and (2). The plan is: §2 basic theory and the second Pascal recursion; §3 Rothe's theorem; §4 the $q$-Vandermonde convolution and the universality argument; §5 the Gauss product formula, symmetry and alternating sums; §6 Galois numbers and the Rogers–Szegő ladder; §7 the reciprocal (Cauchy) side; §8 polynomiality; §9 the $q$-Lucas theorem; §10 the Grassmannian dictionary; §11 algorithms; §12 discussion and future directions.

Notation: $\binom k2 = k(k-1)/2$ denotes an ordinary binomial coefficient (no subscript $q$); $(q;q)_m = \prod_{i=1}^{m}(1-q^i)$ is the $q$-Pochhammer symbol; all subtractions $n-k$ inside index positions are truncated ($n-k=0$ when $k\ge n$), which is harmless because the relevant coefficients vanish in that range.

---

## 2. Basic theory

**Lemma 2.1 (vanishing and normalisation).** For all $q \in R$:
(i) $\binom{n}{0}_q = 1$; (ii) $\binom{n}{k}_q = 0$ whenever $n<k$; (iii) $\binom{n}{n}_q = 1$; (iv) $\binom{n}{1}_q = \sum_{i=0}^{n-1} q^i = [n]_q$.

*Proof.* (i) and (ii) are immediate inductions on $n$ using (1.2); for (ii), both terms on the right of (1.2) vanish by the inductive hypothesis. (iii) follows from (1.2) and (ii): $\binom{n+1}{n+1}_q = \binom{n}{n}_q + q^{n+1}\binom{n}{n+1}_q = 1 + 0$. (iv) is the induction $\binom{n+1}{1}_q = \binom n0_q + q\binom n1_q = 1 + q\sum_{i<n}q^i$. $\square$

**Proposition 2.2 (second $q$-Pascal recursion).** For all $n,k$,
$$\binom{n+1}{k+1}_q = q^{\,n-k}\binom{n}{k}_q + \binom{n}{k+1}_q. \tag{2.1}$$

*Proof.* Double induction on $n$ (generalising over $k$). For $n=0$ both sides reduce to Lemma 2.1. For the step with $k=0$, (2.1) asserts $[n+2]_q = q^{n+1}\cdot 1 + [n+1]_q$, which is the two ways of peeling a geometric sum. For $k+1$, expand both $\binom{n+2}{k+2}_q$ by (1.2) and apply the inductive hypothesis to each term; the exponents match because $q^{k+1}q^{\,n-k} = q^{\,n+1}$. For $k>n$ both sides vanish by Lemma 2.1(ii), which is what makes the truncated subtraction $n-k$ harmless. $\square$

The two recursions are the only structural inputs used in the rest of the paper. Informally, (1.2) peels a factor off one end of a product and (2.1) peels it off the other; almost every theorem below is an instance of playing them against each other.

**Lemma 2.3 (transfer).** If $f : R \to S$ is a homomorphism of commutative semirings, then $f\bigl(\binom{n}{k}_q\bigr) = \binom{n}{k}_{f(q)}$ for all $n,k$. In particular, evaluation $\mathbb{Z}[X]\to R$, $X\mapsto q$, sends $\binom{n}{k}_X$ to $\binom{n}{k}_q$.

*Proof.* Induction on $n$ and $k$ using (1.2) and the fact that $f$ preserves $+$, $\times$, $0$, $1$ and hence powers. $\square$

---

## 3. Rothe's $q$-binomial theorem

**Lemma 3.1 (coefficient step).** For all $q,x\in R$ and all $n,j$,
$$q^{\binom{j+1}{2}}\binom{n+1}{j+1}_q x^{j+1} = q^{\binom{j+1}{2}}\binom{n}{j+1}_q x^{j+1} + q^{\binom{j}{2}}\binom{n}{j}_q x^{j}\cdot (q^n x).$$

*Proof.* Apply (2.1) to $\binom{n+1}{j+1}_q$ and use $\binom{j+1}{2} = \binom j2 + j$ together with $\binom j2 + j + (n-j) = \binom j2 + n$, valid when $j \le n$; when $j>n$ the term $\binom nj_q$ vanishes and the identity is trivial. $\square$

**Theorem 3.2 (Rothe's $q$-binomial theorem).** For all $q,x$ in a commutative semiring and all $n\ge 0$,
$$\prod_{i=0}^{n-1}\bigl(1+q^i x\bigr) = \sum_{k=0}^{n} q^{\binom k2}\binom{n}{k}_q x^k. \tag{3.1}$$

*Proof.* Induction on $n$. For $n=0$ both sides are $1$. Assume (3.1) for $n$ and multiply by $(1+q^n x)$. The left-hand side becomes $\prod_{i<n+1}(1+q^ix)$; the right-hand side becomes
$$\sum_{k\le n} q^{\binom k2}\binom nk_q x^k \;+\; \sum_{k\le n} q^{\binom k2}\binom nk_q x^k\cdot q^n x .$$
Re-index the second sum by $k = j$ and the target sum $\sum_{k\le n+1} q^{\binom k2}\binom{n+1}{k}_q x^k$ by $k = j+1$ (its $k=0$ term being $1$). Lemma 3.1 matches the two sums term by term. $\square$

At $q=1$, (3.1) is the binomial theorem $(1+x)^n = \sum_k \binom nk x^k$.

**Corollary 3.3 (coefficient form).** In the polynomial ring $R[x]$,
$$\Bigl[x^k\Bigr]\prod_{i=0}^{n-1}(1+q^i x) = q^{\binom k2}\binom{n}{k}_q ,\qquad \Bigl[x^k\Bigr]\prod_{i=0}^{n-1}(1+q^{m+i} x) = q^{\binom k2 + mk}\binom{n}{k}_q . \tag{3.2}$$

*Proof.* The first is Theorem 3.2 read coefficientwise (all terms of degree $>n$ vanish by Lemma 2.1(ii)). The second is the first applied to the element $q$ with $x$ replaced by $q^m x$, since $\prod_{i<n}(1+q^{m+i}x) = \prod_{i<n}(1+q^{i}(q^mx))$. $\square$

---

## 4. The $q$-Vandermonde convolution

This is the central theorem, and the place where the universality principle earns its keep.

**Lemma 4.1 (exponent additivity).** For all $a,b\in\mathbb{N}$: $\binom{a+b}{2} = \binom a2 + \binom b2 + ab$.

*Proof.* Induction on $b$ using $\binom{b+1}{2} = \binom b2 + b$, or directly from $(a+b)(a+b-1)/2$. $\square$

**Proposition 4.2 (scaled convolution; valid over any commutative semiring).** For all $m,n,k$,
$$q^{\binom k2}\binom{m+n}{k}_q = \sum_{j=0}^{k} q^{\binom j2 + \binom{k-j}{2} + m(k-j)}\binom{m}{j}_q\binom{n}{k-j}_q. \tag{4.1}$$

*Proof.* Work in $R[x]$ and split the product at position $m$:
$$\prod_{i=0}^{m+n-1}(1+q^ix) = \Bigl(\prod_{i=0}^{m-1}(1+q^ix)\Bigr)\Bigl(\prod_{i=0}^{n-1}(1+q^{m+i}x)\Bigr).$$
Extract the coefficient of $x^k$. On the left, Corollary 3.3 gives $q^{\binom k2}\binom{m+n}{k}_q$. On the right, the coefficient of a product is the convolution $\sum_{j+j'=k}$ of coefficients, and each factor's coefficients are given by the two formulas of (3.2), producing $q^{\binom j2}\binom mj_q \cdot q^{\binom{k-j}{2} + m(k-j)}\binom{n}{k-j}_q$. $\square$

**Theorem 4.3 (universal $q$-Vandermonde).** In $\mathbb{Z}[X]$, for all $m,n,k$,
$$\binom{m+n}{k}_X = \sum_{j=0}^{k} X^{(m-j)(k-j)}\binom{m}{j}_X\binom{n}{k-j}_X . \tag{4.2}$$

*Proof.* Multiply the right-hand side by $X^{\binom k2}$ and compare with (4.1) term by term. For $j \le m$, Lemma 4.1 applied to $a=j$, $b=k-j$ gives $\binom k2 = \binom j2 + \binom{k-j}{2} + j(k-j)$, and $m(k-j) = j(k-j) + (m-j)(k-j)$, so
$$\binom j2 + \binom{k-j}{2} + m(k-j) = \binom k2 + (m-j)(k-j)$$
and the terms agree. For $j>m$ the factor $\binom mj_X$ vanishes, so both terms are zero (this is where truncated subtraction $m-j$ is harmless). Hence
$$X^{\binom k2}\binom{m+n}{k}_X = X^{\binom k2}\sum_{j\le k} X^{(m-j)(k-j)}\binom mj_X\binom{n}{k-j}_X .$$
Now $X^{\binom k2}\neq 0$ and $\mathbb{Z}[X]$ is an integral domain, so it may be cancelled. $\square$

**Theorem 4.4 ($q$-Vandermonde convolution).** For every commutative ring $R$, every $q\in R$ and all $m,n,k\ge 0$,
$$\boxed{\;\binom{m+n}{k}_q = \sum_{j=0}^{k} q^{(m-j)(k-j)}\binom{m}{j}_q\binom{n}{k-j}_q\;} \tag{4.3}$$

*Proof.* Apply the evaluation homomorphism $\mathbb{Z}[X]\to R$, $X\mapsto q$, to (4.2). Both sides of (4.2) are built from $+,\times$ and powers, so the homomorphism passes through sums, products and powers; Lemma 2.3 identifies the images of the Gaussian binomials. $\square$

**Remark 4.5 (why the detour is necessary).** Cancelling $q^{\binom k2}$ directly in (4.1) requires $q$ to be a non-zero-divisor, which fails for many rings of interest (e.g. $q$ nilpotent, or $q=0$, or $R$ a product ring). Theorem 4.4 holds *unconditionally*: at $q=0$, for instance, (4.3) reduces to $\binom{m+n}{k}_0 = \binom{m}{k}_0\cdot\binom{n}{0}_0 + \cdots$, and indeed $\binom nk_0 = 1$ for $k \le n$. The universality detour is thus not a convenience but the only correct route to the general statement.

**Corollary 4.6 (reflected form).** $\displaystyle \binom{m+n}{k}_q = \sum_{j=0}^{k} q^{\,j\,(n-(k-j))}\binom{m}{j}_q\binom{n}{k-j}_q$.

*Proof.* Apply (4.3) with $m$ and $n$ interchanged and reverse the summation index $j \mapsto k-j$. $\square$

**Corollary 4.7 (classical Vandermonde).** $\binom{m+n}{k} = \sum_{j\le k}\binom mj\binom{n}{k-j}$.

*Proof.* Evaluate (4.3) at $q=1$, using $\binom nk_1 = \binom nk$ (an immediate induction from (1.2) against Pascal's rule). $\square$

---

## 5. Gauss product formula, symmetry, alternating sums

**Definition 5.1.** The $q$-Pochhammer symbol is $(q;q)_m = \prod_{i=1}^{m}\bigl(1-q^i\bigr)$, so $(q;q)_0=1$ and $(q;q)_{m+1} = (q;q)_m\,(1-q^{m+1})$.

**Theorem 5.2 (division-free Gauss product formula).** For $k\le n$ and any $q$ in a commutative ring,
$$\binom{n}{k}_q\,(q;q)_k\,(q;q)_{n-k} = (q;q)_n. \tag{5.1}$$

*Proof.* Induction on $n$. The base $n=0$ forces $k=0$. For the step, write $k+1 \le n+1$; if $k=n$ both sides equal $(q;q)_{n+1}$ by Lemma 2.1(iii). Otherwise use (1.2) to split $\binom{n+1}{k+1}_q$, apply the inductive hypothesis to $\binom nk_q$ and $\binom{n}{k+1}_q$, and combine using the Pochhammer recursion together with the elementary identity $(1-q^{n-k}) + q^{n-k}(1-q^{k+1}) = 1-q^{n+1}$. $\square$

Formula (5.1) is (1.1) with all denominators cleared; unlike (1.1) it is meaningful and true when the factors $1-q^i$ are not invertible, e.g. at roots of unity or in characteristic dividing relevant quantities.

**Theorem 5.3 (symmetry).** For $k\le n$, $\binom{n}{k}_q = \binom{n}{n-k}_q$.

*Proof.* In $\mathbb{Z}[X]$, Theorem 5.2 gives $\binom nk_X (X;X)_k (X;X)_{n-k} = (X;X)_n = \binom{n}{n-k}_X (X;X)_{n-k}(X;X)_{k}$. The product $(X;X)_k(X;X)_{n-k}$ is nonzero in the integral domain $\mathbb{Z}[X]$ (each factor $1-X^i$ is nonzero), so it may be cancelled, giving the identity universally; transport by $X\mapsto q$. $\square$

**Theorem 5.4 (Gauss' alternating sum).** For $n \ge 1$ and any $q$ in a commutative ring,
$$\sum_{k=0}^{n} (-1)^k q^{\binom k2}\binom{n}{k}_q = 0 .$$

*Proof.* Put $x=-1$ in Theorem 3.2. The left-hand product contains the factor $1 + q^0(-1) = 0$, so it vanishes; the right-hand side is the stated sum. $\square$

**Theorem 5.5 ($q$-analogue of the central binomial identity).** For all $n$,
$$\binom{2n}{n}_q = \sum_{j=0}^{n} q^{(n-j)^2}\binom{n}{j}_q^{\,2}.$$

*Proof.* Take $m=n$, $k=n$ in Theorem 4.4, obtaining $\sum_j q^{(n-j)^2}\binom nj_q \binom{n}{n-j}_q$, then apply Theorem 5.3 to the second factor. $\square$

---

## 6. Galois numbers and the Rogers–Szegő ladder

**Definition 6.1.** The *Galois number* is $G_n = \sum_{k=0}^{n}\binom{n}{k}_q$, and its weighted companion is $W_n = \sum_{k=0}^{n} q^k\binom{n}{k}_q$. More generally the *Rogers–Szegő polynomial* is
$$H_n(x) = \sum_{k=0}^{n}\binom nk_q x^k, \qquad\text{with } W_n(x) = \sum_{k=0}^{n} q^k \binom nk_q x^k = H_n(qx),$$
so that $H_n(1) = G_n$ and $W_n(1) = W_n$.

**Lemma 6.2 (coupled system).** For all $n$,
$$H_{n+1}(x) = x\,H_n(x) + W_n(x), \qquad W_{n+1}(x) = q^{\,n+1}x\,H_n(x) + W_n(x). \tag{6.1}$$

*Proof.* For the first, expand $H_{n+1}$ by the first Pascal recursion (1.2): $\binom{n+1}{k+1}_q = \binom nk_q + q^{k+1}\binom{n}{k+1}_q$, so the $x^{k+1}$ terms contribute $x\cdot\binom nk_q x^k$ and $q^{k+1}\binom{n}{k+1}_qx^{k+1}$; summing, and using $\binom{n}{n+1}_q=0$ to close the range, gives $xH_n + W_n$. For the second, expand $W_{n+1}(x) = \sum_k q^k\binom{n+1}{k}_q x^k$ with the *second* recursion (2.1): $q^{k+1}\binom{n+1}{k+1}_q = q^{k+1}q^{\,n-k}\binom nk_q + q^{k+1}\binom{n}{k+1}_q = q^{\,n+1}\binom nk_q + q^{k+1}\binom n{k+1}_q$, and sum. $\square$

The two components of (6.1) come from the two Pascal recursions respectively: this is the cleanest illustration of the principle that the theory is generated by peeling from both ends.

**Theorem 6.3 (Rogers–Szegő three-term ladder).** For all $q,x$ in a commutative ring and all $n\ge 0$,
$$H_{n+2}(x) = (1+x)\,H_{n+1}(x) + \bigl(q^{\,n+1}-1\bigr)\,x\,H_n(x). \tag{6.2}$$

*Proof.* Eliminate $W$ from (6.1): $H_{n+2} = xH_{n+1} + W_{n+1} = xH_{n+1} + q^{n+1}xH_n + W_n$, and $W_n = H_{n+1} - xH_n$. Substituting gives $H_{n+2} = xH_{n+1} + q^{n+1}xH_n + H_{n+1} - xH_n$, which is (6.2). $\square$

**Corollary 6.4 (Goldman–Rota recurrence).** $G_{n+2} = 2G_{n+1} + (q^{\,n+1}-1)G_n$.

*Proof.* Set $x=1$ in (6.2). $\square$

For a prime power $q$, $G_n$ counts all subspaces of $\mathbb{F}_q^n$ (see §10); Corollary 6.4 is then the classical Goldman–Rota recurrence. At $q=1$ it degenerates to $2^{n+2} = 2\cdot 2^{n+1} + 0$, consistent with $G_n = 2^n$.

**Theorem 6.5 (Gauss' evaluations at $x=-1$).** For all $m\ge 0$,
$$H_{2m+1}(-1) = 0, \qquad H_{2m}(-1) = \prod_{i=0}^{m-1}\bigl(1-q^{2i+1}\bigr).$$

*Proof.* At $x=-1$ the coefficient $(1+x)$ in (6.2) vanishes, so the ladder degenerates to the two-step recursion $H_{n+2}(-1) = (1-q^{\,n+1})H_n(-1)$. Since $H_1(-1) = 1 - 1 = 0$, all odd-index values vanish. Since $H_0(-1)=1$, induction gives $H_{2m}(-1) = \prod_{i<m}(1-q^{2i+1})$, the step from $2m$ to $2m+2$ contributing the factor $1-q^{2m+1}$. $\square$

Explicitly, $\sum_{k=0}^{2m}(-1)^k\binom{2m}{k}_q = (1-q)(1-q^3)\cdots(1-q^{2m-1})$ and $\sum_{k=0}^{2m+1}(-1)^k\binom{2m+1}{k}_q = 0$ — Gauss' classical evaluations, here obtained from a single degenerating recurrence.

---

## 7. The reciprocal side: Cauchy's $q$-binomial theorem

Rothe's theorem expands a finite product $\prod(1+q^ix)$. Its reciprocal counterpart expands $1/\prod(1-q^ix)$, which is not a polynomial identity; we state it in a division-free way, as an assertion that a certain product of power series equals $1$.

**Definition 7.1.** In the ring $R[[X]]$ of formal power series, put $\Phi_n = \sum_{k\ge 0}\binom{n+k-1}{k}_q X^k$ and, for a shift parameter $m$, $\Phi_{m,n} = \sum_{k\ge 0} q^{mk}\binom{n+k-1}{k}_q X^k$.

**Lemma 7.2 (peeling one factor).** $\bigl(1 - q^{n}X\bigr)\,\Phi_{n+1} = \Phi_{n}$, and more generally $\bigl(1-q^{m+n}X\bigr)\Phi_{m,n+1} = \Phi_{m,n}$.

*Proof.* Compare coefficients of $X^{k+1}$: the claim is $\binom{n+1+k}{k+1}_q - q^{n}\binom{n+k}{k}_q = \binom{n+k}{k+1}_q$, which is exactly the second Pascal recursion (2.1) with top index $n+k$ and bottom index $k$, since $(n+k)-k = n$. The coefficient of $X^0$ is $1$ on both sides. The shifted version is identical with $q$ replaced by the scaling $q^m$ in the coefficient bookkeeping. $\square$

**Theorem 7.3 (Cauchy's $q$-binomial theorem, unit form).** For all $q\in R$ and $n\ge 0$, in $R[[X]]$
$$\Bigl(\prod_{i=0}^{n-1}\bigl(1-q^iX\bigr)\Bigr)\cdot \sum_{k\ge0}\binom{n+k-1}{k}_q X^k \;=\; 1 . \tag{7.1}$$
In particular $\prod_{i<n}(1-q^iX)$ is a unit of $R[[X]]$ with the displayed inverse.

*Proof.* Induction on $n$. For $n=0$ the product is empty and $\Phi_0 = 1$ because $\binom{k-1}{k}_q = 0$ for $k\ge1$. The step is Lemma 7.2: $\prod_{i<n+1}(1-q^iX)\,\Phi_{n+1} = \bigl(\prod_{i<n}(1-q^iX)\bigr)\bigl((1-q^nX)\Phi_{n+1}\bigr) = \bigl(\prod_{i<n}(1-q^iX)\bigr)\Phi_n = 1$. $\square$

At $q=1$, (7.1) is the classical $(1-X)^n\sum_k\binom{n+k-1}{k}X^k = 1$.

**Theorem 7.4 (negative $q$-Vandermonde convolution).** For all $m,n,k$,
$$\binom{m+n+k-1}{k}_q = \sum_{j=0}^{k} q^{\,m(k-j)}\binom{m+j-1}{j}_q\binom{n+k-j-1}{k-j}_q. \tag{7.2}$$

*Proof.* Split $\prod_{i<m+n}(1-q^iX) = \prod_{i<m}(1-q^iX)\cdot\prod_{i<n}(1-q^{m+i}X)$. By Theorem 7.3 and its shifted version, the inverse of the left-hand side is $\Phi_{m+n}$ and the inverse of the right-hand side is $\Phi_m\Phi_{m,n}$. Inverses in $R[[X]]$ are unique, so $\Phi_{m+n} = \Phi_m\,\Phi_{m,n}$; comparing coefficients of $X^k$ gives (7.2). $\square$

At $q=1$, (7.2) is the negative-index Vandermonde convolution $\binom{m+n+k-1}{k} = \sum_j \binom{m+j-1}{j}\binom{n+k-j-1}{k-j}$.

---

## 8. Polynomiality

**Theorem 8.1.** For $k\le n$ the universal Gaussian binomial $\binom nk_X\in\mathbb{Z}[X]$ is monic of degree $k(n-k)$, has non-negative coefficients, and satisfies $\binom nk_X\big|_{X=1} = \binom nk$.

*Proof.* Non-negativity is immediate from (1.2), which involves no subtraction, so $\binom nk_X\in\mathbb{N}[X]\subseteq\mathbb{Z}[X]$. Monicity and the degree are a simultaneous induction on $n$: in $\binom{n+1}{k+1}_X = \binom nk_X + X^{k+1}\binom{n}{k+1}_X$, the first summand has degree $k(n-k)$ and the second has degree $(k+1) + (k+1)(n-k-1) = (k+1)(n-k)$, which is strictly larger when $k+1 \le n$; so the leading term is that of the second summand, monic of degree $(k+1)\bigl((n+1)-(k+1)\bigr)$. The boundary cases $k+1 = n+1$ are covered by Lemma 2.1(iii). Evaluation at $X=1$ turns (1.2) into Pascal's rule. $\square$

The degree $k(n-k)$ is the dimension of the Grassmannian of $k$-planes in $n$-space, and the coefficients count partitions inside a $k\times(n-k)$ box — the Schubert cell decomposition made visible (see §10).

---

## 9. Roots of unity: the $q$-Lucas theorem

Let $R$ be an integral domain and $z\in R$ a primitive $d$-th root of unity, meaning $z^d=1$ and $z^j\neq1$ for $0<j<d$.

**Lemma 9.1.** $(z;z)_d = 0$, while $(z;z)_m \ne 0$ for $m<d$.

*Proof.* $(z;z)_d$ contains the factor $1-z^d = 0$. For $m<d$ every factor $1-z^{i}$ with $1\le i\le m<d$ is nonzero by primitivity, and $R$ is a domain. $\square$

**Lemma 9.2 (block collapse).** For $0 < k < d$ and any $n$ with $d \mid n$, $\binom{n}{k}_z = 0$; and for all $m,k$,
$$\binom{d+m}{k}_z = \binom{m}{k}_z + \bigl[\,d \le k\,\bigr]\binom{m}{k-d}_z ,$$
where $[\cdot]$ is $1$ if the condition holds and $0$ otherwise.

*Proof sketch.* The first statement follows from Theorem 5.2 with $n$ a multiple of $d$: $(z;z)_n = 0$ while $(z;z)_k \ne 0$ and — in the relevant range — $(z;z)_{n-k}\neq 0$ after removing full blocks, forcing $\binom nk_z=0$. The second is the $d$-fold iterate of the Pascal recursions: adding a block of $d$ to the top index multiplies the relevant transition weights by $z^d=1$, collapsing the $d$-step transfer to the two extreme terms. $\square$

**Theorem 9.3 ($q$-Lucas).** For a primitive $d$-th root of unity $z$ in an integral domain and all $n,k$,
$$\binom{n}{k}_z = \binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\cdot\binom{n \bmod d}{k \bmod d}_z . \tag{9.1}$$

*Proof.* Strong induction on $n$. If $n<d$ then $\lfloor n/d\rfloor = 0$ and the claim reads $\binom nk_z = \binom{0}{\lfloor k/d\rfloor}\binom{n}{k \bmod d}_z$; for $k<d$ this is trivial, and for $k\ge d$ both sides vanish (the left because $n<d\le k$). If $n = d+m$, apply Lemma 9.2 and the inductive hypothesis to $\binom mk_z$ and $\binom{m}{k-d}_z$; the two resulting ordinary binomials combine by Pascal's rule $\binom{a+1}{b+1} = \binom{a}{b} + \binom{a}{b+1}$, using $\lfloor (d+m)/d\rfloor = \lfloor m/d\rfloor + 1$ and $(d+m)\bmod d = m \bmod d$. $\square$

**Corollary 9.4 (vanishing criterion).** If $d\mid n$ and $d\nmid k$ then $\binom nk_z = 0$.

**Corollary 9.5 (the $q=-1$ phenomenon).** In $\mathbb{Z}$, with $z=-1$ (a primitive square root of unity), $\binom nk_{-1} = \binom{\lfloor n/2\rfloor}{\lfloor k/2\rfloor}\binom{n\bmod 2}{k \bmod 2}_{-1}$. In particular $\binom{2a}{2b}_{-1} = \binom ab$ and $\binom{2a}{2b+1}_{-1} = 0$.

For example, row $6$ of the Gaussian triangle evaluated at $q=-1$ is $1,0,3,0,3,0,1$: Pascal's row $1,3,3,1$ interleaved with zeros. In the representation-theoretic reading, $\binom{2a}{2b}_{-1}$ counts the $2b$-subsets of a $2a$-set fixed by a fixed-point-free involution.

---

## 10. The Grassmannian dictionary

Let $q$ be a prime power and $\mathbb{F}_q$ the field with $q$ elements. The number of $k$-dimensional subspaces of $\mathbb{F}_q^n$ is
$$\frac{(q^n-1)(q^n-q)\cdots(q^n-q^{k-1})}{(q^k-1)(q^k-q)\cdots(q^k-q^{k-1})} = \binom{n}{k}_q ,$$
the standard count of ordered independent $k$-tuples divided by the order of $GL_k(\mathbb{F}_q)$; the resulting rational expression equals the Gaussian binomial by the cleared Theorem 5.2. Under this dictionary the results above read as geometry:

* **Symmetry** $\binom nk_q = \binom{n}{n-k}_q$ is duality: $W \mapsto W^\perp$ (or the annihilator in the dual space) is a bijection between $k$-subspaces and $(n-k)$-subspaces.
* **Degree** $k(n-k)$ (Theorem 8.1) is the dimension of the Grassmannian $\mathrm{Gr}(k,n)$; the coefficients of $\binom nk_X$ count Schubert cells indexed by partitions in a $k\times(n-k)$ box.
* **The $q$-Vandermonde convolution** (4.3) is the decomposition of $\mathrm{Gr}(k,\mathbb{F}_q^m\oplus\mathbb{F}_q^n)$ according to $\dim (W\cap \mathbb{F}_q^m)=j$: the factor $\binom mj_q$ chooses the intersection, $\binom{n}{k-j}_q$ chooses the projection to the second summand, and $q^{(m-j)(k-j)}$ counts the homomorphisms gluing the two, i.e. the affine fibre of the cell.
* **Galois numbers** $G_n = \sum_k \binom nk_q$ count all subspaces of $\mathbb{F}_q^n$, and Corollary 6.4 is their Goldman–Rota recurrence.

**Worked example ($PG(3,q)$).** In the projective $3$-space over $\mathbb{F}_q$ — whose points are the lines of $\mathbb{F}_q^4$ and whose lines are the planes of $\mathbb{F}_q^4$ — the number of projective lines through a fixed point is
$$\binom 31_q = 1+q+q^2,$$
and the total number of projective lines is
$$\binom 42_q = 1+q+2q^2+q^3+q^4 = (q^2+1)(q^2+q+1).$$
Splitting $4 = 2+2$ in Theorem 4.4 gives
$$\binom 42_q = q^4\binom20_q\binom22_q + q^{1}\binom21_q\binom21_q + \binom22_q\binom20_q = q^4 + q(1+q)^2 + 1,$$
the three terms classifying a plane $W\subset\mathbb{F}_q^4$ by $\dim(W\cap U) \in\{0,1,2\}$ for a fixed reference plane $U$. For $q=2$ this reads $35 = 16 + 18 + 1$; for $q=3$, $130 = 81+48+1$.

---

## 11. Algorithms

**Algorithm A (Gaussian triangle by dynamic programming).** Build a table of $\binom nk_q\in\mathbb{Z}[X]$ for $0\le k\le n\le N$ by (1.2). Each entry costs one polynomial addition and one shift-multiply of length $O(k(n-k)) = O(N^2)$, so the total cost is $O(N^4)$ coefficient operations and $O(N^4)$ memory for the whole triangle (or $O(N^3)$ with a rolling row). Because (1.2) is subtraction-free, all intermediate coefficients are non-negative and no cancellation occurs; the algorithm is therefore numerically exact over $\mathbb{Z}$ and also correct verbatim over any commutative semiring.

**Algorithm B (Rothe expansion).** Expand $\prod_{i<n}(1+q^ix)$ iteratively in $x$, each factor updating the coefficient list by $c_k \leftarrow c_k + q^{i}c_{k-1}$. This computes the $q^{\binom k2}\binom nk_q$ directly, at cost $O(n^2)$ polynomial operations, and gives an independent check of Algorithm A.

**Algorithm C ($q$-Vandermonde convolution / verification).** Given $m,n,k$, form $\sum_{j\le k} q^{(m-j)(k-j)}\binom mj_q\binom{n}{k-j}_q$ from a table produced by Algorithm A: $O(k)$ polynomial multiplications. Used with $m+n$ fixed, this is a *splitting oracle*: it evaluates a large Gaussian binomial from two smaller triangles, a useful divide-and-conquer when only a few entries of a very wide row are needed.

**Algorithm D (Rogers–Szegő ladder).** Compute $H_0=1$, $H_1 = 1+x$ and iterate (6.2). Each step costs $O(1)$ polynomial operations in $x$ (degree $\le n$) with coefficients in $\mathbb{Z}[q]$, so the whole family $H_0,\dots,H_N$ costs $O(N)$ ladder steps rather than the $O(N^2)$ entries of the triangle — a genuine speed-up when only the row sums or their generating functions are needed. Specialising $x=1$ produces the Galois numbers by Corollary 6.4; specialising $x=-1$ produces Gauss' products by Theorem 6.5.

---

## 12. Discussion

### 12.1 Division-freeness as a design principle

Every classical formula in this area has a quotient form and a cleared form. The cleared forms — (5.1) instead of (1.1); the unit statement (7.1) instead of "the reciprocal of the product is the Gaussian series" — are strictly stronger: they are theorems over every commutative ring, and they specialise correctly in exactly the degenerate situations (roots of unity, nilpotents, characteristic $p$, the trivial ring) where the quotient forms are undefined. The $q$-Lucas theorem of §9 is the payoff: it is a statement *about* a degenerate specialisation, and its proof leans on Theorem 5.2 in cleared form.

### 12.2 Universality as a proof technique

The Gaussian binomials, being generated by a subtraction-free recursion in $+$ and $\times$, are a universal object: $\binom nk_X\in\mathbb{Z}[X]$ carries all the information, and every other instance is its image under a ring homomorphism (Lemma 2.3). The consequence is a two-step recipe for any polynomial identity in $q$:

1. prove it in $\mathbb{Z}[X]$, where the integral-domain structure permits cancellation of nonzero elements;
2. transport by $X\mapsto q$.

In this development the recipe converts the single genuinely obstructed step — cancelling the coefficient-extraction artefact $q^{\binom k2}$ in Proposition 4.2 — into one application of cancellation in a domain plus one application of a homomorphism, and it does the same work again in the proof of symmetry (Theorem 5.3), where $(X;X)_k(X;X)_{n-k}$ must be cancelled. The pattern is general: *an identity involving only ring operations belongs in the free ring on its parameters.*

### 12.3 Relations between the results

The dependency structure is a narrow tree. The two Pascal recursions (1.2) and (2.1) generate everything. Rothe (Theorem 3.2) needs (2.1); $q$-Vandermonde (Theorem 4.4) needs Rothe plus universality; Gauss' alternating sum is a one-point evaluation of Rothe; the Gauss product formula needs only (1.2); symmetry needs the product formula plus universality; the central-binomial $q$-identity needs Vandermonde plus symmetry; the Rogers–Szegő ladder needs both recursions and nothing else, and it contains the Goldman–Rota recurrence and Gauss' evaluations as its $x=1$ and $x=-1$ slices. The reciprocal side (§7) is an independent branch whose only structural input is again (2.1). This is a small number of primitive moves for a large amount of classical theory, and it suggests that further identities in the family — Carlitz linearization being the natural next target (see below) — should be reachable by the same two moves.

### 12.4 Future directions

**Carlitz linearization of Rogers–Szegő products.** There should be explicit exponents $e(m,n,k)$ with
$$H_m(x)H_n(x) = \sum_{k\le \min(m,n)} q^{e(m,n,k)}\binom mk_q\binom nk_q (q;q)_k\,H_{m+n-2k}(x),$$
the Rogers–Szegő analogue of the linearization of a product of Hermite polynomials. The coupled system (6.1) makes $\{H_n\}$ a birth-and-death ladder, and the conjecture asserts that the ladder's structure constants are Gaussian binomials weighted by the $q$-Pochhammer symbol. All ingredients are in place; the missing datum is the exponent $e$, readable from small cases and then provable by double induction against the ladder.

**Grassmannian enumeration, internalised.** The dictionary of §10 is used here as interpretation. It should be a theorem: for a finite field with $q$ elements, the set of $k$-dimensional subspaces of $\mathbb{F}_q^n$ has exactly $\binom nk_q$ elements as a natural number, and consequently the Galois numbers count all subspaces. The natural route is the orbit–stabiliser argument for the transitive action of $GL_n(\mathbb{F}_q)$ on $k$-subspaces, combined with the cleared product formula (5.1) to avoid division.

**Cyclic sieving.** Corollary 9.5 is the smallest instance of the cyclic sieving phenomenon: the polynomial $\binom nk_X$, evaluated at $d$-th roots of unity, counts $k$-subsets fixed by a $d$-fold rotation. Theorem 9.3 supplies exactly the evaluation needed; the remaining content is a bijective fixed-point count, which the block structure of (9.1) already mirrors.

**Further specialisations.** The universality principle makes any specialisation $X\mapsto q$ immediately legal, which invites systematic study of the resulting families: $q$ a nilpotent (truncated Grassmannians), $q$ a $p$-adic integer, $q$ a matrix, and $q$ in a tropical or Boolean semiring where the subtraction-free definition (1.2) still applies but no cleared quotient formula does.

---

## 13. Summary of the main results

| Result | Statement |
|---|---|
| $q$-Pascal, first form | $\binom{n+1}{k+1}_q = \binom nk_q + q^{k+1}\binom{n}{k+1}_q$ |
| $q$-Pascal, second form | $\binom{n+1}{k+1}_q = q^{\,n-k}\binom nk_q + \binom{n}{k+1}_q$ |
| Rothe's $q$-binomial theorem | $\prod_{i<n}(1+q^ix) = \sum_k q^{\binom k2}\binom nk_q x^k$ |
| $q$-Vandermonde convolution | $\binom{m+n}{k}_q = \sum_j q^{(m-j)(k-j)}\binom mj_q\binom{n}{k-j}_q$ |
| Gauss product formula | $\binom nk_q (q;q)_k (q;q)_{n-k} = (q;q)_n$ for $k\le n$ |
| Symmetry | $\binom nk_q = \binom{n}{n-k}_q$ for $k \le n$ |
| Gauss' alternating sum | $\sum_k (-1)^kq^{\binom k2}\binom nk_q = 0$ for $n\ge1$ |
| Central binomial $q$-identity | $\binom{2n}{n}_q = \sum_j q^{(n-j)^2}\binom nj_q^2$ |
| Goldman–Rota recurrence | $G_{n+2} = 2G_{n+1} + (q^{n+1}-1)G_n$ |
| Rogers–Szegő ladder | $H_{n+2}(x) = (1+x)H_{n+1}(x) + (q^{n+1}-1)xH_n(x)$ |
| Gauss' evaluations | $H_{2m+1}(-1)=0$, $H_{2m}(-1)=\prod_{i<m}(1-q^{2i+1})$ |
| Cauchy's theorem (unit form) | $\bigl(\prod_{i<n}(1-q^iX)\bigr)\sum_k\binom{n+k-1}{k}_qX^k = 1$ |
| Negative $q$-Vandermonde | $\binom{m+n+k-1}{k}_q = \sum_j q^{m(k-j)}\binom{m+j-1}{j}_q\binom{n+k-j-1}{k-j}_q$ |
| Polynomiality | $\binom nk_X$ monic of degree $k(n-k)$, coefficients in $\mathbb{N}$ |
| $q$-Lucas | $\binom nk_z = \binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\binom{n\bmod d}{k\bmod d}_z$ at a primitive $d$-th root of unity |
| $q=-1$ phenomenon | $\binom{2a}{2b}_{-1} = \binom ab$, $\binom{2a}{2b+1}_{-1}=0$ |
| Projective line counts | $\binom31_q = 1+q+q^2$, $\binom42_q = (q^2+1)(q^2+q+1) = q^4+q(1+q)^2+1$ |
