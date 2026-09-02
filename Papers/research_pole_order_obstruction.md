# The Pole-Order Obstruction: Root Extraction, Filtration, and Value-Group Interpolation for Products of Normalized $q$-Series

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

Let $\mathbb{C}((q))$ denote the field of formal Laurent series with complex coefficients. Call a series *normalized* if it has the shape $T = q^{-1} + \sum_{n\ge 0}c_nq^n$, that is, a simple pole with residue $1$ and an arbitrary holomorphic tail. Such series are the formal shape of the McKay–Thompson series of monstrous moonshine, of which there are $194$ — one for each conjugacy class of the Monster simple group.

We develop the theory of the **pole-order obstruction** attached to a product of $m$ normalized series. The starting point is elementary: such a product has order exactly $-m$, and multiplication by $q^m$ returns a power series with constant term $1$. We show that this single integer invariant governs a remarkable amount, and that it does so from three structurally distinct directions.

*Multiplicatively*, we prove that a nonzero Laurent series over $\mathbb{C}$ is an $n$-th power if and only if $n$ divides its order — no analytic hypothesis intervenes — and we upgrade this to a classification of power classes, $\mathbb{C}((q))^\times/(\mathbb{C}((q))^\times)^n \cong \mathbb{Z}/n\mathbb{Z}$ via order mod $n$. Consequently the product of the $194$ normalized series is an $n$-th power precisely for $n \in \{1,2,97,194\}$: it is a square, but has neither cube nor fourth root. We prove a converse rigidity statement: if $m$ series each have at most a simple pole and their product has a pole of order exactly $m$, then every factor has a pole of order exactly $1$.

*Linearly*, we construct the pole filtration $\mathrm{Pol}_m$ of $\mathbb{C}((q))$ by spaces of series with at most an $m$-fold pole, show that it is multiplicative, and prove that the associated space of principal parts is canonically isomorphic to $\mathbb{C}^m$, with all graded pieces one-dimensional. This is the formal-Laurent instance of the Riemann–Roch dimension count $\ell(D)-\ell(D-P)\le 1$ at a single point, here always an equality. The Monster-sized product is located exactly: it lies in $\mathrm{Pol}_{194}\setminus\mathrm{Pol}_{193}$ with deepest principal-part coordinate $1$.

*Combinatorially*, we prove a master coefficient identity — the Laurent coefficient in degree $k-m$ of a product of $m$ normalized series is the $k$-th power-series coefficient of the corrected product — and deduce a closed formula: for linear normalized factors $q^{-1}+a_i$, the coefficient in degree $k-m$ is the elementary symmetric function $e_k(a_1,\ldots,a_m)$.

Finally we show that the obstruction can be *moved and dissolved*, and that the two natural ways of doing so coincide. The replication operator $V_d:q\mapsto q^d$ multiplies order by $d$, changing the root spectrum from divisors of $194$ to divisors of $194d$, with minimal replication depth $n/\gcd(n,194)$ for an $n$-th root. Passing to the Puiseux-type Hahn field $\mathbb{C}[[q^{\mathbb{Q}}]]$ with divisible value group removes the obstruction entirely: the product is an $n$-th power for every $n$, and its $194$-th root has order exactly $-1$. Interpolating, an $n$-th root with exponents in the lattice $\tfrac1N\mathbb{Z}$ exists if and only if $n \mid 194N$ — literally the replication criterion at depth $N$. In sharpest form: for any additively closed set $S$ of rational exponents containing $\mathbb{Z}$, an $n$-th root supported in $S$ exists if and only if the single rational number $-194/n$ lies in $S$.

**Keywords:** formal Laurent series, pole order, valuation, root extraction, Riemann–Roch, Puiseux series, replication operator, elementary symmetric functions, monstrous moonshine.

---

## 1. Introduction

### 1.1 The setting

Fix the field $\mathbb{C}((q))$ of formal Laurent series: expressions $x = \sum_{n\in\mathbb{Z}}x_nq^n$ with $x_n\in\mathbb{C}$ and $\{n : x_n \ne 0\}$ bounded below. Equivalently, $\mathbb{C}((q))$ is the Hahn series field with value group $\mathbb{Z}$ and coefficient field $\mathbb{C}$; the general Hahn construction with an arbitrary ordered abelian value group $\Gamma$ will matter in §6–§7.

For $x \ne 0$, write $\operatorname{ord}(x) \in \mathbb{Z}$ for the least exponent with $x_{\operatorname{ord}(x)}\ne 0$, and $\operatorname{lc}(x) = x_{\operatorname{ord}(x)}$ for the leading coefficient. It is convenient to also use $\operatorname{ord}_{\top}$, taking values in $\mathbb{Z}\cup\{\infty\}$ with $\operatorname{ord}_\top(0) = \infty$, so that $\operatorname{ord}_\top$ is a genuine valuation, total on all of $\mathbb{C}((q))$. Its two defining properties are
$$\operatorname{ord}_\top(xy) = \operatorname{ord}_\top(x)+\operatorname{ord}_\top(y), \qquad \operatorname{ord}_\top(x+y) \ge \min\{\operatorname{ord}_\top(x),\operatorname{ord}_\top(y)\}.$$

### 1.2 Normalized series

**Definition 1.1 (Normalized series).** A Laurent series $f \in \mathbb{C}((q))$ is **normalized** if
1. $f_{-1} = 1$, and
2. $f_n = 0$ for all $n < -1$.

Equivalently, $f = q^{-1} + \sum_{n\ge 0}c_nq^n$ for some sequence $(c_n)_{n \ge 0}$ of complex numbers, which we call the *tail*. We write $\mathcal T(c) = q^{-1}+\sum_{n\ge0}c_nq^n$ for the normalized series with tail $c$.

**Definition 1.2 (Corrected part).** For $f$ normalized, its **corrected part** (or *unit part*) is the power series
$$\widehat f = qf \in \mathbb{C}[[q]], \qquad \widehat f = 1 + c_0q + c_1q^2 + \cdots.$$
Explicitly $\widehat f_k = f_{k-1}$; in particular $\widehat f$ has constant term $1$.

The motivating instance is monstrous moonshine. Each conjugacy class $g$ of the Monster group $\mathbb{M}$ carries a McKay–Thompson series $T_g(q) = q^{-1}+\sum_{n\ge1}\operatorname{tr}(g\mid V_n)q^{n}$, normalized in exactly the above sense. The Monster has $194$ conjugacy classes, and we write $M = 194$ throughout for that class count. **No property of the actual moonshine coefficients is used anywhere below**: all results are universally quantified over the tails, so they hold for the moonshine product as a special case, and their content is precisely that the phenomena are consequences of *shape*, not of arithmetic depth.

### 1.3 The basic theorem and the question it decides

**Theorem 1.3 (Pole-Order Theorem).** Let $s$ be a finite index set and let $(f_i)_{i\in s}$ be normalized. Then
$$\operatorname{ord}_\top\Big(\prod_{i\in s}f_i\Big) = -|s|.$$
In particular the product is nonzero, has a pole of order exactly $|s|$, and leading coefficient $1$.

*Proof sketch.* Each factor has $\operatorname{ord}_\top = -1$; the valuation is additive over finite products. Nonvanishing follows since the order is finite. The leading coefficient is the product of the leading coefficients, all equal to $1$. $\square$

**Corollary 1.4 (Factorization).** For normalized $(f_i)_{i\in s}$ with $m=|s|$,
$$\prod_{i\in s}f_i \;=\; q^{-m}\cdot U, \qquad U \;=\; \prod_{i\in s}\widehat{f_i} \in \mathbb{C}[[q]], \quad U(0) = 1 .$$
Multiplying by $q^m$ restores order $0$.

For the Monster-sized product this reads $\operatorname{ord}\big(\prod_g T_g\big) = -194$.

Everything in this paper flows from asking a *single* question of this configuration:

> For which $n \ge 1$ does there exist $y$ with $y^n = \prod_g T_g$?

The necessary condition is immediate from additivity: $n\operatorname{ord}(y) = -194$ forces $n \mid 194$. Sections 2–3 show sufficiency, Sections 4–5 explore what else the invariant controls, and Sections 6–8 change the ambient value group and watch the answer change in a completely controlled way.

---

## 2. The multiplicative structure of $\mathbb{C}((q))^\times$

### 2.1 Splitting the valuation sequence

Write $\mathbb{C}[[q]]^\times$ for the unit group of the power-series ring, i.e. the power series with nonzero constant term. There are two natural homomorphisms into $\mathbb{C}((q))^\times$: the inclusion $\iota$ of $\mathbb{C}[[q]]^\times$, and $k \mapsto q^k$ from $\mathbb{Z}$ (written multiplicatively).

**Theorem 2.1 (Splitting Theorem).** The map
$$\mathbb{Z} \times \mathbb{C}[[q]]^\times \longrightarrow \mathbb{C}((q))^\times, \qquad (k,u)\longmapsto q^k u$$
is a group isomorphism. Under it, $\operatorname{ord}$ is the projection onto the first factor.

*Proof sketch.* It is a homomorphism since $\operatorname{ord}(q^ku) = k$ and multiplication of monomials adds exponents. *Injectivity:* if $q^ku = 1$ then comparing orders gives $k=0$, hence $u=1$. *Surjectivity:* given $x \ne 0$, factor $x = q^{\operatorname{ord}(x)}\cdot \pi(x)$ where the *power-series part* $\pi(x) = q^{-\operatorname{ord}(x)}x$ has order $0$; its constant term is $\operatorname{lc}(x)\ne0$, so $\pi(x) \in \mathbb{C}[[q]]^\times$. $\square$

**Corollary 2.2 (Exactness).** $\ker(\operatorname{ord}) = \mathbb{C}[[q]]^\times$ inside $\mathbb{C}((q))^\times$: a Laurent series has order $0$ if and only if it is a unit power series.

Thus the valuation sequence $1\to\mathbb{C}[[q]]^\times\to\mathbb{C}((q))^\times\xrightarrow{\operatorname{ord}}\mathbb{Z}\to0$ is split exact. This is where all subsequent statements come from: any multiplicative question about $\mathbb{C}((q))^\times$ decomposes into a question about $\mathbb{Z}$ and a question about $\mathbb{C}[[q]]^\times$, and the second turns out to be vacuous.

### 2.2 Roots of unit power series

**Proposition 2.3 (Binomial roots).** Let $u \in \mathbb{C}[[q]]$ with $u(0)=1$, and let $n \ge 1$. Then there exists $w \in \mathbb{C}[[q]]$ with $w(0)=1$ and $w^n = u$.

*Proof sketch.* Let $B_r(X)=\sum_{k\ge0}\binom{r}{k}X^k$ denote the binomial series, defined for $r\in\mathbb{Q}$ because $\mathbb{C}$ has characteristic zero, so $\binom{r}{k}=r(r-1)\cdots(r-k+1)/k!$ makes sense. One has the formal identity $B_r(X)^k = B_{rk}(X)$; in particular $B_{1/n}(X)^n = B_1(X) = 1+X$. Now $a := u - 1$ has zero constant term, hence is substitutable, and $w := B_{1/n}(a)$ satisfies $w^n = B_{1/n}(a)^n = 1 + a = u$, with $w(0)=B_{1/n}(0)=1$. $\square$

**Corollary 2.4.** Let $P \in \mathbb{C}[[q]]$ with $P(0)\ne0$ and let $n\ge1$. Then $P$ has an $n$-th root in $\mathbb{C}[[q]]$.

*Proof sketch.* Write $P = P(0)\cdot u$ with $u(0)=1$. Choose $\lambda\in\mathbb{C}$ with $\lambda^n = P(0)$ (algebraic closedness) and apply Proposition 2.3 to $u$; then $(\lambda w)^n = P$. $\square$

Note where the hypotheses on the coefficient field enter: characteristic zero for the binomial coefficients, algebraic closedness for $\lambda$. Over $\mathbb{C}$ both are available, and the power-series factor offers no obstruction at all.

---

## 3. The root-extraction theorem

**Theorem 3.1 (Root-Extraction Theorem).** Let $x \in \mathbb{C}((q))$ be nonzero and let $n\ge1$. Then
$$\exists\, y \in \mathbb{C}((q)) : y^n = x \iff n \mid \operatorname{ord}(x).$$

*Proof sketch.* ($\Rightarrow$) If $y^n=x$ then $y\ne0$ and $\operatorname{ord}(x)=n\operatorname{ord}(y)$. ($\Leftarrow$) Write $\operatorname{ord}(x)=nk$. By Theorem 2.1, $x = q^{nk}\pi(x)$ with $\pi(x)$ a unit power series; by Corollary 2.4 pick $w$ with $w^n = \pi(x)$. Then $y = q^kw$ satisfies $y^n = q^{nk}w^n = x$. $\square$

The content is that the *only* obstruction is arithmetic: no condition on the coefficients of $x$ beyond nonvanishing at the leading position, which is automatic.

**Corollary 3.2 (Root spectrum of a normalized product).** For normalized $(f_i)_{i\in s}$ with $m=|s|$ and $n\ge1$,
$$\exists\, y : y^n=\prod_{i\in s}f_i \iff n \mid m .$$

**Corollary 3.3 (Monster root spectrum).** For any tails $c_1,\ldots,c_{194}$ and $n \ge 1$,
$$\exists\, y : y^n = \prod_{i=1}^{194}\mathcal T(c_i) \iff n \mid 194 \iff n \in \{1,2,97,194\}.$$
In particular the product **is** a square; it has **no** cube root ($3\nmid194$) and **no** fourth root ($194=2\cdot97$ is squarefree).

### 3.1 Power classes: the invariant is complete and sharp

Fix $n\ge1$ and let $\big(\mathbb{C}((q))^\times\big)^n$ be the subgroup of $n$-th powers. Since $\mathbb{C}((q))^\times$ is abelian this subgroup is normal, and $\operatorname{ord}$ descends modulo $n$ to a homomorphism $\overline{\operatorname{ord}}_n : \mathbb{C}((q))^\times \to \mathbb{Z}/n\mathbb{Z}$.

**Theorem 3.4 (Classification of power classes).** For every $n\ge1$,
$$\ker\big(\overline{\operatorname{ord}}_n\big) = \big(\mathbb{C}((q))^\times\big)^n \quad\text{and}\quad \mathbb{C}((q))^\times\big/\big(\mathbb{C}((q))^\times\big)^n \;\cong\; \mathbb{Z}/n\mathbb{Z},$$
the isomorphism being induced by pole order mod $n$.

*Proof sketch.* The kernel identification is exactly Theorem 3.1 read modulo $n$: $\operatorname{ord}(x)\equiv0 \pmod n$ iff $n\mid\operatorname{ord}(x)$ iff $x$ is an $n$-th power. Surjectivity of $\overline{\operatorname{ord}}_n$ is witnessed by the monomials $q^k$, whose order is $k$. The first isomorphism theorem finishes. $\square$

So the pole order mod $n$ is a **complete** invariant (it separates power classes exactly) and a **sharp** one (every residue is attained). For the Monster-sized product the class is $-194 \bmod n$, trivial precisely for the four divisors of $194$.

### 3.2 Additive contrast

**Proposition 3.5.** Let $(f_i)_{i\in s}$ be normalized with $s$ nonempty. Then $\operatorname{ord}_\top\big(\sum_{i\in s}f_i\big) = -1$.

*Proof sketch.* All coefficients in degrees $<-1$ vanish termwise. In degree $-1$ the coefficients sum to $|s|\cdot1 = |s| \ne 0$ in $\mathbb{C}$. Hence $-1$ lies in the support and nothing below does. $\square$

The sum of the $194$ normalized series has a *simple* pole, whereas the product has a pole of order $194$. Pole-order growth is purely multiplicative; this is precisely why the obstruction is a group homomorphism on $\mathbb{C}((q))^\times$ and admits no additive counterpart.

---

## 4. Rigidity: the pole certifies its factors

Theorem 1.3 computes the order of a product from the orders of the factors. The converse question is whether a maximal pole in the product forces maximal poles in each factor. It does.

**Theorem 4.1 (Rigidity).** Let $(f_i)_{i\in s}$ be nonzero Laurent series with $\operatorname{ord}(f_i)\ge-1$ for all $i$, and suppose $\operatorname{ord}\big(\prod_{i\in s}f_i\big) = -|s|$. Then $\operatorname{ord}(f_i) = -1$ for every $i\in s$.

*Proof sketch.* Additivity over a finite family of nonzero series gives $\sum_{i\in s}\operatorname{ord}(f_i) = -|s|$. Each summand satisfies $\operatorname{ord}(f_i)\ge-1$, so writing $\varepsilon_i = \operatorname{ord}(f_i)+1\ge0$ we get $\sum_i\varepsilon_i = 0$ with all $\varepsilon_i\ge0$, forcing $\varepsilon_i=0$ for all $i$. $\square$

**Corollary 4.2.** If $T_1,\ldots,T_{194}$ are nonzero with at most simple poles and $\prod_i T_i$ has a pole of order $194$, then each $T_i$ has a pole of order exactly $1$. A Monster-sized pole certifies that all $194$ factors are genuinely singular: no cancellation, and no regular factor.

---

## 5. The linear face: the pole filtration and a dimension count

The order is a valuation, hence a multiplicative gadget. It has an equally informative linear avatar.

**Definition 5.1 (Pole filtration).** For $m \ge 0$ set
$$\mathrm{Pol}_m = \{\, x\in\mathbb{C}((q)) : x_n = 0 \text{ for all } n < -m \,\}.$$

Each $\mathrm{Pol}_m$ is a $\mathbb{C}$-subspace (the conditions are linear), $\mathrm{Pol}_0 = \mathbb{C}[[q]]$, and $\mathrm{Pol}_m \subseteq \mathrm{Pol}_k$ for $m\le k$.

**Proposition 5.2 (Filtration = valuation).** $x \in \mathrm{Pol}_m \iff \operatorname{ord}_\top(x)\ge -m$.

*Proof sketch.* ($\Leftarrow$) Coefficients strictly below $\operatorname{ord}_\top$ vanish. ($\Rightarrow$) If $x=0$ this is clear; otherwise, if $\operatorname{ord}(x)<-m$ then the coefficient at $\operatorname{ord}(x)$ would have to vanish, contradicting the definition of order. $\square$

**Proposition 5.3 (Multiplicativity).** $\mathrm{Pol}_a\cdot\mathrm{Pol}_b\subseteq\mathrm{Pol}_{a+b}$.

*Proof sketch.* Immediate from Proposition 5.2 and additivity of the valuation. $\square$

So $(\mathrm{Pol}_m)_{m\ge0}$ is an increasing filtration of $\mathbb{C}((q))$ by subspaces, compatible with the algebra structure. Two immediate consequences of Proposition 5.2 and Theorem 1.3: a normalized series lies in $\mathrm{Pol}_1$, and a product of $m$ normalized series lies in $\mathrm{Pol}_m$ — the linear form of the pole-order obstruction.

### 5.1 Principal parts

**Definition 5.4.** For $m\ge0$, the **principal part map** is the linear map
$$\mathrm{pp}_m : \mathbb{C}((q)) \to \mathbb{C}^m, \qquad \mathrm{pp}_m(x) = \big(x_{-1}, x_{-2}, \ldots, x_{-m}\big),$$
and the **principal-part lift** is the linear map
$$L_m : \mathbb{C}^m \to \mathbb{C}((q)), \qquad L_m(c_0,\ldots,c_{m-1}) = c_0q^{-1}+c_1q^{-2}+\cdots+c_{m-1}q^{-m}.$$

**Lemma 5.5.** $L_m(\mathbb{C}^m)\subseteq\mathrm{Pol}_m$ and $\mathrm{pp}_m\circ L_m = \mathrm{id}_{\mathbb{C}^m}$. Moreover, if $x\in\mathrm{Pol}_m$ then $x - L_m(\mathrm{pp}_m(x)) \in \mathrm{Pol}_0$.

*Proof sketch.* The lift is a finite sum of monomials $q^{-(i+1)}$ with $1\le i+1\le m$, none of degree $<-m$. Reading off the coefficient of $q^{-(j+1)}$ in $L_m(c)$ picks out $c_j$ exactly, giving the section identity. For the last claim, in a degree $n<0$ either $n<-m$, where both terms vanish (the first by $x\in\mathrm{Pol}_m$), or $-m\le n\le-1$, where the two coefficients agree by the section identity. $\square$

**Definition 5.6.** The **space of principal parts of pole order at most $m$** is
$$\mathrm{PP}_m := \text{image of }\mathrm{Pol}_m \text{ in } \mathbb{C}((q))/\mathrm{Pol}_0 .$$

**Theorem 5.7 (Principal-part isomorphism).** For every $m\ge0$ the composite $\mathbb{C}^m \xrightarrow{L_m}\mathrm{Pol}_m \twoheadrightarrow \mathrm{PP}_m$ is a $\mathbb{C}$-linear isomorphism
$$\mathbb{C}^m \;\xrightarrow{\ \sim\ }\; \mathrm{PP}_m, \qquad (c_0,\ldots,c_{m-1}) \longmapsto \big[c_0q^{-1}+\cdots+c_{m-1}q^{-m}\big].$$
Consequently $\dim_{\mathbb{C}}\mathrm{PP}_m = m$.

*Proof sketch.* *Injectivity:* if $L_m(c)\in\mathrm{Pol}_0$, then all its negative coefficients vanish; the coefficient at $-(j+1)$ is $c_j$, so $c=0$. *Surjectivity:* given $x\in\mathrm{Pol}_m$, Lemma 5.5 gives $x \equiv L_m(\mathrm{pp}_m(x)) \pmod{\mathrm{Pol}_0}$, so the class of $x$ is hit. The dimension follows since $\dim\mathbb{C}^m=m$. $\square$

**Theorem 5.8 (Graded pieces).** For every $m\ge0$ the quotient $\mathrm{Pol}_{m+1}/\mathrm{Pol}_m$ is one-dimensional over $\mathbb{C}$, spanned by the class of $q^{-(m+1)}$.

*Proof sketch.* The linear map $\mathbb{C}\to\mathrm{Pol}_{m+1}/\mathrm{Pol}_m$, $c\mapsto[c\,q^{-(m+1)}]$, is well defined since $q^{-(m+1)}\in\mathrm{Pol}_{m+1}$. It is injective: if $c\,q^{-(m+1)}\in\mathrm{Pol}_m$ then reading degree $-(m+1)<-m$ gives $c=0$. It is surjective: for $x\in\mathrm{Pol}_{m+1}$, the difference $x - x_{-(m+1)}q^{-(m+1)}$ has all coefficients below $-m$ equal to zero, hence lies in $\mathrm{Pol}_m$. $\square$

**Remark 5.9 (Riemann–Roch shadow).** Theorems 5.7 and 5.8 are the formal-Laurent instance of the classical dimension count $\ell(D)-\ell(D-P)\le1$ for divisors supported at a single point $P$. In the local formal setting the inequality is *always* an equality: the pole filtration jumps by exactly one dimension per unit of pole order, because the residue field is $\mathbb{C}$ itself. The conceptual upgrade is this: the pole-order obstruction of a product of $m$ normalized series is not merely the integer $m$; it is a *vector* in an $m$-dimensional space, and the order records the position of that vector in the filtration.

### 5.2 Locating the Monster-sized product

**Theorem 5.10.** Let $P = \prod_{i=1}^{194}\mathcal T(c_i)$ for arbitrary tails. Then
1. $P \in \mathrm{Pol}_{194}$ and $P \notin \mathrm{Pol}_{193}$;
2. $P_{-194} = 1$, i.e. the deepest coordinate of $\mathrm{pp}_{194}(P)$ equals $1$;
3. $\dim_{\mathbb{C}}\mathrm{PP}_{194} = 194$, and the class of $P$ in $\mathbb{C}((q))/\mathrm{Pol}_0$ is nonzero.

*Proof sketch.* By Theorem 1.3, $\operatorname{ord}(P)=-194$ with leading coefficient $1$; Proposition 5.2 gives (1) upward and (2). If $P$ were in $\mathrm{Pol}_{193}$, the coefficient at $-194 < -193$ would vanish, contradicting (2). Part (3) is Theorem 5.7 plus the observation that $P\in\mathrm{Pol}_0$ would again force $P_{-194}=0$. $\square$

So the Monster-sized product occupies the *top* graded piece of the filtration exactly.

---

## 6. The combinatorial face: coefficients as symmetric functions

**Theorem 6.1 (Master coefficient identity).** Let $(f_i)_{i\in s}$ be normalized with $m=|s|$. Then for every $k\ge0$,
$$\Big(\prod_{i\in s}f_i\Big)_{\,k-m} \;=\; \Big(\prod_{i\in s}\widehat{f_i}\Big)_{\,k},$$
the right-hand side being a power-series coefficient of the corrected product.

*Proof sketch.* By Corollary 1.4, $\prod_i f_i = q^{-m}\cdot U$ with $U = \prod_i\widehat{f_i}$. Multiplication by the monomial $q^{-m}$ shifts every coefficient index down by $m$. $\square$

Thus every Laurent coefficient of a normalized product is a power-series coefficient of a normalized object: the pole is a pure shift, and the "interesting" content of the product is entirely holomorphic.

**Definition 6.2 (Linear normalized series).** For $a\in\mathbb{C}$ set $\ell(a) := q^{-1}+a$, the normalized series with tail $(a,0,0,\ldots)$. Its corrected part is $\widehat{\ell(a)} = 1 + aq$.

**Lemma 6.3.** $\displaystyle \Big(\prod_{i\in s}(1+a_iq)\Big)_{\,k} = \sum_{t\subseteq s,\;|t|=k}\ \prod_{i\in t}a_i \;=\; e_k(a)$, the $k$-th elementary symmetric function of $(a_i)_{i\in s}$.

*Proof sketch.* Expand the product by choosing, for each $i$, either $1$ or $a_iq$. A choice set $t$ contributes $\big(\prod_{i\in t}a_i\big)q^{|t|}$; collecting the terms with $|t|=k$ gives the claim. $\square$

**Theorem 6.4 (Closed formula).** For $a : s\to\mathbb{C}$ with $m = |s|$ and every $k \ge 0$,
$$\Big(\prod_{i\in s}\big(q^{-1}+a_i\big)\Big)_{\,k-m} \;=\; e_k\big((a_i)_{i\in s}\big).$$
Equivalently,
$$\prod_{i\in s}\big(q^{-1}+a_i\big) \;=\; \sum_{k=0}^{m}e_k(a)\,q^{\,k-m}.$$

*Proof sketch.* Combine Theorem 6.1 with Lemma 6.3. $\square$

**Corollary 6.5 (Support and endpoints).**
1. The coefficient in degree $k-m$ vanishes for $k>m$, since $e_k=0$ then; so the product is supported in degrees $-m,\ldots,0$.
2. The deepest coefficient (degree $-m$) is $e_0 = 1$.
3. The constant coefficient (degree $0$) is $e_m(a) = \prod_{i\in s}a_i$ — a Vieta relation.

**Example 6.6.** $(q^{-1}+2)(q^{-1}+3) = q^{-2}+5q^{-1}+6$, and indeed $e_1(2,3)=5$ sits in degree $1-2=-1$. Likewise $(q^{-1}+2)(q^{-1}+3)(q^{-1}+5) = q^{-3}+10q^{-2}+31q^{-1}+30$, with $e_2(2,3,5)=6+10+15=31$ in degree $2-3=-1$.

**Corollary 6.7 (Monster instance).** For $a_1,\ldots,a_{194}\in\mathbb{C}$, the product $\prod_{i=1}^{194}(q^{-1}+a_i)$ has coefficient $e_k(a)$ in degree $k-194$; its deepest coefficient is $1$ and its constant coefficient is $\prod_{i=1}^{194}a_i$. The Laurent expansion is the finite sum $\sum_{k=0}^{194}e_k(a)q^{k-194}$.

Thus for the simplest normalized shapes the pole-order profile is completely explicit, and the coefficients of a Monster-sized product are subset-sum (combinatorial) invariants of the tails.

---

## 7. Moving the obstruction: replication

Since the obstruction lives in the value group, deforming the variable should move it. The formal shadow of the Hecke-type operators of moonshine does exactly this.

**Definition 7.1 (Replication operator).** For $d\ge1$, let $V_d : \mathbb{C}((q))\to\mathbb{C}((q))$ be the substitution $q\mapsto q^d$; concretely it is induced by the order-embedding $k\mapsto dk$ of the exponent group $\mathbb{Z}$ into itself. It is an injective ring homomorphism.

**Proposition 7.2.** $\operatorname{ord}_\top(V_d x) = d\cdot\operatorname{ord}_\top(x)$ for all $x$.

*Proof sketch.* $V_d$ relabels exponents by $k\mapsto dk$, an increasing injection; the least exponent in the support maps to the least exponent of the image. $\square$

**Corollary 7.3.** For normalized $(f_i)_{i\in s}$ with $m=|s|$, $\operatorname{ord}\big(V_d\prod_i f_i\big) = -dm$, and the image is nonzero.

**Theorem 7.4 (Root spectrum after replication).** For normalized $(f_i)_{i\in s}$, $m=|s|$, $d,n\ge1$,
$$\exists\, y\in\mathbb{C}((q)) : y^n = V_d\Big(\prod_{i\in s}f_i\Big) \iff n \mid dm .$$

*Proof sketch.* Theorem 3.1 applied to the nonzero series $V_d\prod_i f_i$, whose order is $-dm$ by Corollary 7.3; divisibility is insensitive to sign. $\square$

**Corollary 7.5 (Monster after replication).** $V_d\big(\prod_{i=1}^{194}\mathcal T(c_i)\big)$ has an $n$-th root iff $n\mid 194d$. In particular:
- the *third* replication **is** a perfect cube ($3\mid 3\cdot194$), even though the original product is not;
- every replication is a perfect square ($2\mid194$);
- the fifth root remains obstructed at depth $3$, since $5\nmid582$.

**Theorem 7.6 (Minimal replication depth).** For $n,d\ge1$,
$$\exists\, y : y^n = V_d\Big(\prod_{i=1}^{194}\mathcal T(c_i)\Big) \iff \frac{n}{\gcd(n,194)} \;\Big|\; d .$$
Hence $n/\gcd(n,194)$ is the minimal depth at which an $n$-th root appears.

*Proof sketch.* By Theorem 7.4 the condition is $n\mid 194d$. Write $g=\gcd(n,194)$, $n=ga$, $194=gb$ with $\gcd(a,b)=1$. Then $n \mid 194d \iff ga \mid gbd \iff a\mid bd \iff a\mid d$ by coprimality. And $a = n/g$. $\square$

**Example 7.7.** $3/\gcd(3,194)=3$: a cube root first appears at depth $3$. $4/\gcd(4,194)=2$: a fourth root already appears at depth $2$, because $2\mid194$ does half the work. $5/\gcd(5,194)=5$: a fifth root needs depth $5$.

Replication therefore enlarges the root spectrum from the divisors of $194$ to the divisors of $194d$, in a completely predictable way, and never destroys an existing root.

---

## 8. Dissolving the obstruction: divisible value groups

The alternative to deforming the variable is to enlarge the exponents.

**Definition 8.1 (Puiseux-type Hahn field).** Let $\mathbb{C}[[q^{\mathbb{Q}}]]$ denote the Hahn series field with value group $\mathbb{Q}$ and coefficient field $\mathbb{C}$: formal sums $y = \sum_{r\in\mathbb{Q}}y_rq^r$ whose support $\{r : y_r\ne0\}$ is well ordered. Order, leading coefficient, and additivity of the valuation are defined exactly as before, now with values in $\mathbb{Q}$.

**Proposition 8.2 (Exponent extension).** The map $\iota:\mathbb{C}((q))\to\mathbb{C}[[q^{\mathbb{Q}}]]$ induced by the inclusion $\mathbb{Z}\hookrightarrow\mathbb{Q}$ of value groups is an injective ring homomorphism preserving order: if $\operatorname{ord}_\top(x)=k$ then $\operatorname{ord}_\top(\iota x)=k$.

**Theorem 8.3 (Dissolution).** Let $(f_i)_{i\in s}$ be normalized with $m=|s|$ and let $n\ge1$. Then there exists $y\in\mathbb{C}[[q^{\mathbb{Q}}]]$ with $y^n = \iota\big(\prod_{i\in s}f_i\big)$. Explicitly, $y = q^{-m/n}\cdot\iota(w)$, where $w\in\mathbb{C}[[q]]$ is the binomial $n$-th root of the corrected product $U = \prod_i\widehat{f_i}$ (which has constant term $1$, Corollary 1.4).

*Proof sketch.* Proposition 2.3 supplies $w$ with $w^n = U$ and $w(0)=1$. Then $y^n = q^{-m}\iota(w^n)=q^{-m}\iota(U) = \iota(q^{-m}U) = \iota\big(\prod_i f_i\big)$ by Corollary 1.4. The exponent $-m/n$ is a legitimate element of the value group $\mathbb{Q}$; this is the only step that fails over $\mathbb{Z}$. $\square$

**Theorem 8.4 (The Monster is a $194$-th power of a simple-pole series).** For arbitrary tails there exists $y\in\mathbb{C}[[q^{\mathbb{Q}}]]$ with
$$y^{194} = \iota\Big(\prod_{i=1}^{194}\mathcal T(c_i)\Big) \quad\text{and}\quad \operatorname{ord}_\top(y) = -1 .$$

*Proof sketch.* Take $y = q^{-1}\iota(w)$ in Theorem 8.3 with $n=m=194$; the order is $-1+0=-1$ since $\iota(w)$ has order $0$. $\square$

The $194$-fold pole is thus *literally* $194$ copies of one simple pole. Over $\mathbb{Q}$-exponents every $n\ge1$ works, in sharp contrast with the $\mathbb{Z}$-graded answer $n\mid194$. This confirms the diagnosis of §3: the obstruction is a property of the value group $\mathbb{Z}$, not of the series.

---

## 9. Interpolation: one hierarchy, two costumes

Sections 7 and 8 remove the obstruction in two apparently unrelated ways. They are the same way.

**Definition 9.1.** For $N\ge1$ let $\tfrac1N\mathbb{Z} = \{k/N : k\in\mathbb{Z}\}\subseteq\mathbb{Q}$, a subgroup containing $\mathbb{Z}$ and closed under addition.

**Theorem 9.2 (Support criterion — sharpest form).** Let $S\subseteq\mathbb{Q}$ be any set containing every integer and closed under addition. Let $P=\prod_{i=1}^{194}\mathcal T(c_i)$ and $n\ge1$. Then
$$\Big(\exists\, y\in\mathbb{C}[[q^{\mathbb{Q}}]]: y^n=\iota(P) \text{ and } \operatorname{supp}(y)\subseteq S\Big) \iff \frac{-194}{n}\in S .$$

*Proof sketch.* ($\Rightarrow$) Such a $y$ is nonzero and satisfies $n\operatorname{ord}(y)=\operatorname{ord}(\iota P)=-194$, so $\operatorname{ord}(y)=-194/n$; the order always lies in the support, so $-194/n\in S$. ($\Leftarrow$) Take $y=q^{-194/n}\cdot\iota(w)$ with $w$ the binomial $n$-th root of the corrected product as in Theorem 8.3. Its support is contained in $\{-194/n\}+\operatorname{supp}(\iota w)$, and $\operatorname{supp}(\iota w)\subseteq\mathbb{Z}\subseteq S$; closure under addition gives $\operatorname{supp}(y)\subseteq S$. $\square$

The existence of an $n$-th root is therefore decided by the membership of a *single rational number* in the exponent set. That is the strongest possible expression of "the pole order is the complete obstruction".

**Lemma 9.3.** For $N,n\ge1$: $\dfrac{-194}{n}\in\tfrac1N\mathbb{Z} \iff n \mid 194N$.

*Proof sketch.* $-194/n = k/N$ for some $k\in\mathbb{Z}$ iff $-194N = kn$ iff $n\mid 194N$. $\square$

**Theorem 9.4 (Graded interpolation).** For $N,n\ge1$,
$$\Big(\exists\, y\in\mathbb{C}[[q^{\mathbb{Q}}]]: y^n=\iota(P),\ \operatorname{supp}(y)\subseteq\tfrac1N\mathbb{Z}\Big) \iff n \mid 194N .$$

*Proof sketch.* Theorem 9.2 with $S = \tfrac1N\mathbb{Z}$, then Lemma 9.3. $\square$

**Theorem 9.5 (Value-group refinement $=$ replication depth).** For $N,n\ge1$,
$$\Big(\exists\, y : y^n=\iota(P),\ \operatorname{supp}(y)\subseteq\tfrac1N\mathbb{Z}\Big) \iff \Big(\exists\, z\in\mathbb{C}((q)) : z^n = V_N(P)\Big).$$

*Proof sketch.* The left side is $n\mid194N$ by Theorem 9.4; the right side is $n\mid 194N$ by Corollary 7.5. $\square$

The two hierarchies are one. Setting $N=1$ recovers the $\mathbb{Z}$-graded spectrum $n\mid194$ of Corollary 3.3; letting $N$ absorb any denominator recovers the unobstructed $\mathbb{Q}$-graded answer of Theorem 8.3.

**Corollary 9.6.** A cube root of $P$ exists with exponents in $\tfrac1N\mathbb{Z}$ if and only if $3\mid N$.

*Proof sketch.* By Theorem 9.4 the condition is $3\mid194N$; since $\gcd(3,194)=1$, this is $3\mid N$. $\square$

---

## 10. Algorithms

The theory is entirely effective. Three procedures summarize it.

**Algorithm A (Root spectrum).** *Input:* $m\ge1$ (number of normalized factors), bound $B$. *Output:* the set of $n\le B$ for which the product has an $n$-th root in $\mathbb{C}((q))$. *Method:* return the divisors of $m$ up to $B$. *Correctness:* Corollary 3.2. *Complexity:* $O(\sqrt m)$ by trial division, or $O(B)$ by sieving.

**Algorithm B (Minimal replication depth).** *Input:* $n\ge1$, $m\ge1$. *Output:* the least $d\ge1$ such that $V_d$ of the product has an $n$-th root. *Method:* return $n/\gcd(n,m)$. *Correctness:* Theorem 7.6. *Complexity:* $O(\log\min(n,m))$ by the Euclidean algorithm.

**Algorithm C (Explicit root construction).** *Input:* the tails of $m$ normalized series, an exponent $n$, a truncation order $K$. *Output:* the first $K$ terms of an $n$-th root, over $\mathbb{Q}$-exponents. *Method:* (i) form the corrected product $U = \prod_i\widehat{f_i}$ truncated at $q^K$; (ii) set $a = U-1$ and compute $w = \sum_{k\le K}\binom{1/n}{k}a^k$ truncated, which is legitimate because $a$ has zero constant term so $a^k = O(q^k)$; (iii) return the pair $\big(-m/n,\ w\big)$, representing $y = q^{-m/n}w$. *Correctness:* Theorem 8.3. *Complexity:* $O(K^2)$ coefficient operations for the truncated power composition, plus $O(mK)$ for the product; the root is exact to the requested order, and $w^n = U$ holds to order $K$.

Algorithm C also certifies the $\mathbb{Z}$-graded statements: when $n\mid m$ the exponent $-m/n$ is an integer and the same $w$ produces a genuine element of $\mathbb{C}((q))$.

---

## 11. Applications and interpretation

**A closed-form coefficient calculus.** Theorem 6.1 says that the entire Laurent expansion of a normalized product is a shifted power-series expansion. Combined with Theorem 6.4 this converts questions about the deep coefficients of a moonshine-shaped product into questions about symmetric functions of the tails. In particular, for linear factors the coefficient sequence is the elementary symmetric sequence read backwards from the pole; the constant term is the full product of the tails, a Vieta relation at Monster scale.

**A sharp certificate of singularity.** Theorem 4.1 turns the pole-order theorem into a diagnostic. Observing a pole of order $m$ in a product of $m$ at-most-simple-pole factors *proves* that every factor is singular. In a setting where one has access to the product but not the factors, the order of the pole is a complete certificate against cancellation.

**A model of obstruction theory.** The pattern — an existence question governed by the triviality of a class in a discrete group — recurs throughout mathematics. What is unusual here is that the pattern is realized *exactly*: the invariant is complete (Theorem 3.4), sharp (every class is attained), and one can deform the ambient value group and watch the obstruction respond according to a formula (Theorems 7.4, 8.3, 9.4). This makes the pole-order obstruction a clean pedagogical and computational laboratory for obstruction-theoretic reasoning.

**Filtrations and dimension counts.** Theorems 5.7 and 5.8 identify the linear structure underlying the invariant: the pole order is the position of a vector in a filtration whose graded pieces are each one-dimensional. This is the local formal analogue of the Riemann–Roch count at a point, and it upgrades the obstruction from a number to a $194$-dimensional vector for the Monster-sized product, with a distinguished nonzero deepest coordinate.

---

## 12. Discussion

Three remarks on the scope of what is proved.

*The results are universal in the tails.* No coefficient of any factor beyond the residue is ever used. The moonshine instance is a specialization, and the message is that the phenomena above are consequences of shape and of the value group, not of the (extremely deep) arithmetic that determines the McKay–Thompson coefficients. Conversely, this means the results cannot detect moonshine-specific structure; the pole order is a coarse but perfectly rigid invariant.

*The hypotheses on the coefficient field are exactly what is used.* Characteristic zero enters through the binomial coefficients $\binom{1/n}{k}$; algebraic closedness enters through the extraction of $n$-th roots of constants. Over a field failing either, the power-series factor of the splitting in Theorem 2.1 would contribute its own obstruction and Theorem 3.1 would acquire a second condition. That the answer over $\mathbb{C}$ is purely arithmetic is therefore a statement about $\mathbb{C}$ as much as about $q$.

*Multiplicativity is essential.* Proposition 3.5 makes the point sharply: the same $194$ series, added rather than multiplied, produce a simple pole. All of the structure above — the homomorphism, the power classes, the multiplicative filtration — depends on the valuation's additivity under multiplication, and none of it survives replacement of the product by a sum.

---

## 13. Future directions

Several directions extend naturally from the results above.

1. **Beyond squarefree $m$.** The Monster's class count $194 = 2\cdot 97$ is squarefree, which is why the root spectrum is small and why the fourth root fails. For a general count $m$ with repeated prime factors the spectrum $\{n : n\mid m\}$ is richer, and the interaction between the multiplicity structure of $m$ and the minimal replication depth $n/\gcd(n,m)$ deserves a systematic treatment, ideally as a statement about the divisor lattice.

2. **General value groups.** Theorem 9.2 is stated for additively closed subsets of $\mathbb{Q}$ containing $\mathbb{Z}$. The natural generality is a Hahn field over an arbitrary ordered abelian group $\Gamma$ containing $\mathbb{Z}$; the criterion should become "the element $-m/n$ exists in $\Gamma$", i.e. a divisibility question in $\Gamma$, with the fully divisible case recovering Theorem 8.3 and the case $\Gamma=\mathbb{Z}$ recovering Theorem 3.1. Quantifying the failure by the group $\Gamma/n\Gamma$ would give a graded refinement of Theorem 3.4.

3. **Positive characteristic and non-closed coefficient fields.** As noted in §12, the power-series factor is obstruction-free only because $\mathbb{C}$ is algebraically closed of characteristic zero. Over a field $k$ of characteristic $p$, $p$-th roots interact with the Frobenius and Proposition 2.3 fails; over a non-closed field the constant term contributes a class in $k^\times/(k^\times)^n$. The expected general statement is an exact sequence relating $k((q))^\times/(k((q))^\times)^n$ to $\mathbb{Z}/n$ and $k^\times/(k^\times)^n$, and it would be worth making this precise and sharp.

4. **Higher-order poles and mixed shapes.** Only simple-pole factors are considered. Allowing factors of order $-e_i$ replaces $m$ by $\sum_i e_i$ in every statement, but the rigidity theorem (Theorem 4.1) then has a more interesting content: which multisets of orders are consistent with a prescribed product order? This is a partition-theoretic question sitting on top of the valuation identity.

5. **Symmetric-function refinements.** Theorem 6.4 handles linear tails. For general tails the master identity (Theorem 6.1) reduces coefficient computation to the corrected product, whose coefficients are given by a multivariate convolution of the tails. Expressing these in a symmetric-function or quasi-symmetric-function basis, and identifying which such expressions are forced by the normalized shape alone, would complete the combinatorial face of the theory.

6. **Replication as a Hecke-type action.** The operator $V_d$ used here is the bare substitution $q\mapsto q^d$. The genuine Hecke operators of moonshine are averages over cosets and include additive corrections. Extending Theorem 7.4 to those operators — computing the order of a Hecke transform of a normalized product — would connect the pole-order calculus to the replication formulas of moonshine proper.

7. **Effective root computation and stability.** Algorithm C computes truncated roots by binomial substitution in $O(K^2)$ coefficient operations. Newton iteration on $w\mapsto w - (w^n-U)/(nw^{n-1})$ would give quadratic convergence in the truncation order; quantifying coefficient growth and the numerical conditioning of the resulting expansions, especially for tails of moonshine size, is an open practical question.
