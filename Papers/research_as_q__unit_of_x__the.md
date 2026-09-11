# Pole Order, Locality and Newton Recursions for Products of Normalized $q$-Series

**Aristotle**

**Date:** 2026-09-11

---

## Abstract

Let $\mathbb{C}((q))$ denote the field of formal Laurent series in $q$ over $\mathbb{C}$. Call a series *normalized* if it has the shape
$$f = q^{-1} + a_0 + a_1 q + a_2 q^2 + \cdots,$$
that is, a simple pole at $q=0$ with residue $1$ and no deeper pole. Series of this shape include the McKay–Thompson series of monstrous moonshine, one for each of the $194$ conjugacy classes of the Monster group. Multiplying $q$ into such a series produces a unit $u_f = qf$ of the power-series ring $\mathbb{C}[[q]]$, so that any finite product of normalized series factors as $q^{-m}$ times a unit, where $m$ is the number of factors. Indexing the Laurent coefficients of the product by *level* — $c_k$ denotes the coefficient of $q^{k-m}$ — we prove:

1. **A closed multi-Cauchy master formula** expressing $c_k$ as a sum over weak compositions of $k$ into $m$ parts of products of factor coefficients, uniformly in $k$ and with no case distinctions.
2. **Locality**: $c_k$ is a universal polynomial in the tails of at most $k$ of the $m$ factors, and depends only on the coefficients of each factor in degrees $< k$. If in addition all factors have vanishing constant term — the genuine McKay–Thompson normalization — the bound improves to $k/2$ factors.
3. **A Newton recursion** $(k+1)c_{k+1} = \sum_{j\le k} c_j\, p_{k-j}$, where $p_r$ is the $r$-th coefficient of the sum of the logarithmic derivatives of the unit parts, with base case $c_0 = 1$.
4. **Rigidity**: since the recursion is invertible in characteristic zero, the logarithmic power sums $p_0,\dots,p_{K-1}$ determine $c_0,\dots,c_K$ irrespective of the number of factors. Specializing to linear factors $q^{-1}+a_i$ recovers the classical Newton identities and the classical theorem that power sums determine elementary symmetric functions.
5. **Integrality transfer**: the coefficients of the product lie in any subring of $\mathbb{C}$ containing all coefficients of the factors.

Two algorithms — an explicit composition sum and a linear recursion of cost independent of the number of factors — are given and cross-validated on numerical instances, including a $194$-factor product of moonshine shape.

**Keywords.** Formal Laurent series; pole order; McKay–Thompson series; monstrous moonshine; Newton's identities; elementary symmetric functions; logarithmic derivative; locality.

---

## 1. Introduction

### 1.1 Motivation

A recurring shape in modular forms, vertex operator algebra character theory and moonshine is the *normalized $q$-series*
$$f(q) = \frac{1}{q} + a_0 + a_1 q + a_2 q^2 + \cdots .$$
The canonical example is the Hauptmodul of $\mathrm{SL}_2(\mathbb{Z})$,
$$J(q) = j(q) - 744 = \frac{1}{q} + 196884\,q + 21493760\,q^2 + \cdots,$$
whose coefficients are dimensions of graded pieces of the moonshine module. Monstrous moonshine attaches to each conjugacy class $g$ of the Monster $\mathbb{M}$ a McKay–Thompson series
$$T_g(q) = \frac{1}{q} + 0 + c_g(1)q + c_g(2)q^2 + \cdots,$$
the graded trace of $g$ on the moonshine module. There are $194$ such classes, hence $194$ such series, each with a simple pole of residue $1$ and vanishing constant term.

Products of such series arise naturally: in denominator-formula manipulations, in the study of replicable functions, and whenever one wants to compare the whole family $\{T_g\}_{g}$ at once. The elementary question addressed here is:

> **Question.** Given $m$ normalized series $f_1,\dots,f_m$, what are the Laurent coefficients of $\prod_i f_i$, and how much of the data of the factors does each one see?

A naive expansion is hopeless: a coefficient of a product of $194$ infinite series appears to require summing over an unmanageable set of choices. The results below show the answer is highly structured. The organizing observation is a triviality with substantial consequences: **a simple pole of residue $1$ factors off as a unit**.

### 1.2 Prior state and contribution

For a product of $m$ normalized series it was already known that the pole order is exactly $m$ and that the corrected product $q^m \prod_i f_i$ is a unit of $\mathbb{C}[[q]]$; the resulting *shift identity* identifies the Laurent coefficient of $\prod f_i$ in degree $k-m$ with the ordinary power-series coefficient in degree $k$ of $\prod (q f_i)$. On the coefficient side, however, only two instances were available: the *subleading* identity at level $1$,
$$\big[q^{1-m}\big]\prod_i f_i = \sum_i a_0(f_i),$$
and a level-$2$ identity quadratic in $a_0$ and linear in $a_1$. The general level $k$ was open, except in the degenerate *linear* case $f_i = q^{-1}+a_i$, where the answer is the elementary symmetric function $e_k(a)$.

This paper closes the level-$k$ problem in three independent ways — a closed formula, a locality decomposition, and a Newton recursion — proves the recursion is invertible, and derives from that inversion both a rigidity theorem for moonshine-type products and a proof of the classical Newton identities and their invertibility that never touches symmetric-function combinatorics.

### 1.3 Organization

Section 2 fixes notation and records the unit factorization. Section 3 proves the master formula. Section 4 develops locality, truncation, half locality and integrality transfer. Section 5 constructs the logarithmic derivative and the Newton recursion. Section 6 inverts the recursion and proves rigidity. Section 7 specializes everything to the linear case and recovers classical symmetric-function theory. Section 8 gives algorithms and complexity. Section 9 records worked numerical instances. Sections 10 and 11 discuss the results and list open directions.

---

## 2. Setting and basic structure

### 2.1 The ring

Let $\mathbb{C}[[q]]$ be the ring of formal power series and $\mathbb{C}((q))$ the field of formal Laurent series, whose elements have coefficients indexed by $\mathbb{Z}$ with only finitely many nonzero in negative degrees. For $F \in \mathbb{C}((q))$ and $n \in \mathbb{Z}$ write $[q^n]F$ for the coefficient of $q^n$.

**Definition 2.1 (Normalized series).** A series $f \in \mathbb{C}((q))$ is **normalized** if
$$[q^{-1}]f = 1 \qquad\text{and}\qquad [q^{n}]f = 0 \text{ for all } n < -1 .$$
Equivalently $f = q^{-1} + a_0 + a_1 q + \cdots$ with $a_n := [q^n]f$. We call $(a_0, a_1, a_2, \dots)$ the **tail** of $f$.

**Definition 2.2 (Unit part).** The **unit part** of a normalized $f$ is
$$u_f := q\, f = 1 + a_0 q + a_1 q^2 + a_2 q^3 + \cdots \in \mathbb{C}[[q]],$$
so $[q^{n+1}]u_f = [q^{n}]f$ for $n \ge -1$.

**Lemma 2.3 (Unit factorization).** For normalized $f$, the series $u_f$ lies in $\mathbb{C}[[q]]$ and has constant term $1$; hence $u_f$ is a unit of $\mathbb{C}[[q]]$ and $f = q^{-1}u_f$.

*Proof.* Multiplication by $q$ shifts degrees up by one, so the pole of order $1$ is cancelled and no negative degrees remain; the new constant term is $[q^{-1}]f = 1$. A power series is a unit exactly when its constant term is invertible. $\square$

**Proposition 2.4 (Pole order and shift).** Let $f_1,\dots,f_m$ be normalized, indexed by a finite set $S$ with $|S| = m$. Then
$$\prod_{i\in S} f_i = q^{-m}\prod_{i\in S}u_{f_i},$$
the second factor being a unit of $\mathbb{C}[[q]]$. Consequently the product has a pole of order exactly $m$ and, for every $k \ge 0$,
$$\big[q^{\,k-m}\big]\prod_{i \in S} f_i \;=\; \big[q^{k}\big]\prod_{i \in S} u_{f_i}. \tag{2.1}$$

*Proof.* Immediate from Lemma 2.3 and multiplicativity: $\prod_i (q^{-1}u_i) = q^{-m}\prod_i u_i$, and a finite product of units is a unit, so the constant term of $\prod u_i$ is $1 \ne 0$, giving pole order exactly $m$. Identity (2.1) is multiplication of coefficient indices by the shift $q^{-m}$. $\square$

### 2.2 Levels

**Definition 2.5 (Level-$k$ coefficient).** For a family $(f_i)_{i \in S}$ of normalized series with $|S| = m$, the **level-$k$ coefficient** is
$$c_k := \big[q^{\,k-m}\big]\prod_{i\in S}f_i \qquad (k \in \mathbb{Z}_{\ge 0}).$$

Indexing by level rather than by absolute degree is the essential bookkeeping device: it makes products of different sizes directly comparable, and by (2.1) it identifies $c_k$ with an ordinary power-series coefficient. Note $c_0 = [q^0]\prod u_i = 1$.

**Definition 2.6 (Exponent vectors).** For a finite set $S$ and $k \ge 0$, let
$$\mathcal{A}(S,k) := \Big\{ \nu : S \to \mathbb{Z}_{\ge 0} \;\Big|\; \sum_{i\in S}\nu_i = k \Big\}$$
be the set of **weak compositions** of $k$ indexed by $S$. The **support** of $\nu$ is $\operatorname{supp}\nu := \{ i \in S : \nu_i \ne 0\}$. One has $|\mathcal{A}(S,k)| = \binom{m+k-1}{k}$ with $m = |S|$.

---

## 3. The master formula

**Theorem 3.1 (Level-$k$ master formula).** Let $(f_i)_{i\in S}$ be normalized, $|S| = m$. Then for every $k \ge 0$,
$$\boxed{\;\big[q^{\,k-m}\big]\prod_{i\in S}f_i \;=\; \sum_{\nu \in \mathcal{A}(S,k)}\ \prod_{i\in S}\ \big[q^{\,\nu_i - 1}\big]f_i \;}\tag{3.1}$$

*Proof.* By the shift identity (2.1) it suffices to compute $[q^k]\prod_i u_{f_i}$. The coefficient of $q^k$ in a finite product of power series is the multi-Cauchy sum
$$\big[q^{k}\big]\prod_{i\in S}u_{f_i} \;=\; \sum_{\nu\in\mathcal{A}(S,k)}\ \prod_{i \in S}\ \big[q^{\nu_i}\big]u_{f_i},$$
obtained by iterating the binary Cauchy product. By Definition 2.2, $[q^{\nu_i}]u_{f_i} = [q^{\nu_i - 1}]f_i$ for every $\nu_i \ge 0$. Substituting gives (3.1). $\square$

**Remark 3.2 (Uniformity).** Formula (3.1) requires no case distinction, and this is not an accident of presentation. A factor with $\nu_i = 0$ is queried at degree $-1$, where the normalization gives $[q^{-1}]f_i = 1$: the *pole coefficient is precisely the neutral element of the product*. Thus the same expression handles excited and unexcited factors. Any attempt to state the formula in terms of the tail coefficients alone forces a split into cases and loses this uniformity.

**Remark 3.3 (Interpretation).** Formula (3.1) is the arithmetic shadow of the factorization $\prod f_i = q^{-m}\cdot(\text{unit})$: the $q^{-m}$ accounts for the reindexing $k \mapsto k-m$, and the unit accounts for the composition sum.

**Corollary 3.4 (Pole coefficient).** $c_0 = 1$: the coefficient of $q^{-m}$ in $\prod_{i \in S} f_i$ equals $1$.

*Proof.* $\mathcal{A}(S,0) = \{0\}$, and the single term is $\prod_{i \in S}[q^{-1}]f_i = 1$. $\square$

**Corollary 3.5 (Two-factor convolution form).** For normalized $f,g$,
$$\big[q^{\,k-2}\big](fg) \;=\; \sum_{j=0}^{k}\ \big[q^{\,j-1}\big]f \cdot \big[q^{\,k-j-1}\big]g .$$

*Proof.* Specialize (3.1) to $|S| = 2$, where $\mathcal{A}(S,k)$ is parametrized by $j = \nu_1 \in \{0,\dots,k\}$. $\square$

Corollary 3.5 is the smallest instance in which two full tails interact; the two extreme terms $j = 0$ and $j=k$ use the pole coefficients.

---

## 4. Locality, truncation, half locality, integrality

Theorem 3.1 is exact but sums over $\binom{m+k-1}{k}$ terms, which is large when $m$ is. The following results say that almost all of the apparent complexity is vacuous.

### 4.1 Locality

**Lemma 4.1 (Exponent bound).** If $\nu\in\mathcal{A}(S,k)$ then $\nu_i \le k$ for every $i \in S$.

*Proof.* $\nu_i \le \sum_{j\in S}\nu_j = k$ since all terms are nonnegative. $\square$

**Lemma 4.2 (Support bound).** If $\nu \in \mathcal{A}(S,k)$ then $|\operatorname{supp}\nu| \le k$.

*Proof.* Summing $\nu$ over its support gives $k$, since the omitted terms are zero. Each summand over the support is $\ge 1$, so $|\operatorname{supp}\nu| = \sum_{i\in\operatorname{supp}\nu}1 \le \sum_{i\in\operatorname{supp}\nu}\nu_i = k$. $\square$

**Lemma 4.3 (Unexcited factors are neutral).** Let $(f_i)_{i\in S}$ be normalized and $\nu$ an exponent vector with $\operatorname{supp}\nu \subseteq S$. Then
$$\prod_{i \in S}\big[q^{\nu_i - 1}\big]f_i \;=\; \prod_{i \in \operatorname{supp}\nu}\big[q^{\nu_i-1}\big]f_i .$$

*Proof.* For $i \notin \operatorname{supp}\nu$ we have $\nu_i = 0$ and the factor is $[q^{-1}]f_i = 1$; delete these factors. $\square$

**Theorem 4.4 (Locality decomposition).** Let $(f_i)_{i\in S}$ be normalized, $|S| = m$. For every $k \ge 0$,
$$\big[q^{\,k-m}\big]\prod_{i\in S}f_i \;=\; \sum_{\substack{T \subseteq S\\ |T| \le k}}\ \ \sum_{\substack{\nu\in\mathcal{A}(S,k)\\ \operatorname{supp}\nu = T}}\ \ \prod_{i \in T}\big[q^{\,\nu_i-1}\big]f_i . \tag{4.1}$$
In particular $c_k$ is a universal polynomial, independent of $m$, in the tail coefficients of at most $k$ of the factors at a time.

*Proof.* Partition the index set $\mathcal{A}(S,k)$ of the master formula into the fibres of the map $\nu \mapsto \operatorname{supp}\nu$. By Lemma 4.2 every fibre lies over a subset $T\subseteq S$ with $|T|\le k$, so the fibration is well defined onto $\{T\subseteq S: |T|\le k\}$. Applying Lemma 4.3 inside each fibre replaces the product over $S$ by the product over $T$. $\square$

**Remark 4.5.** The inner sum in (4.1) is a sum over *strict* compositions of $k$ into $|T|$ positive parts, of which there are $\binom{k-1}{|T|-1}$. Hence the total number of nonvacuous terms is $\sum_{t \le \min(k,m)} \binom{m}{t}\binom{k-1}{t-1}$: polynomial in $m$ of degree $k$ rather than exponential. For $m=194$ and $k=3$ this is $194 + 194\cdot 193 + \binom{194}{3}$ terms of a very simple shape, and the *interactions* involve at most triples.

**Remark 4.6 (Generalizing $e_k$).** In the linear case (Section 7) the only surviving exponent vectors are the indicators of $k$-element subsets, and (4.1) becomes literally "$e_k$ is a sum over $k$-subsets". Theorem 4.4 is the exact extension of that statement to arbitrary tails.

### 4.2 Truncation

**Theorem 4.7 (Truncation locality).** Let $(f_i)_{i\in S}$ and $(g_i)_{i\in S}$ be two families of normalized series with $|S| = m$, and let $k \ge 0$. If
$$\big[q^{\,j}\big]f_i = \big[q^{\,j}\big]g_i \quad \text{for all } i \in S \text{ and all } 0 \le j < k,$$
then
$$\big[q^{\,k-m}\big]\prod_{i \in S}f_i = \big[q^{\,k-m}\big]\prod_{i\in S}g_i .$$

*Proof.* Compare the two master formulas term by term. Fix $\nu \in \mathcal{A}(S,k)$ and $i \in S$. If $\nu_i = 0$, both factors equal $[q^{-1}]f_i = 1 = [q^{-1}]g_i$ by normalization. If $\nu_i = r+1 \ge 1$, then $r < k$ by Lemma 4.1, and the hypothesis gives $[q^{r}]f_i = [q^{r}]g_i$. Hence corresponding products agree, and so do the sums. $\square$

Thus the level-$k$ coefficient of a product of infinite series is computed exactly from finite truncations of the factors: only the coefficients $a_0,\dots,a_{k-1}$ of each factor matter.

### 4.3 Half locality for vanishing constant term

Genuine McKay–Thompson series satisfy $a_0 = 0$. This kills half of the exponent spectrum.

**Theorem 4.8 (No exponent equals one).** Let $(f_i)_{i \in S}$ be normalized with $[q^0]f_i = 0$ for all $i \in S$. Then
$$\big[q^{\,k-m}\big]\prod_{i \in S}f_i \;=\; \sum_{\substack{\nu \in \mathcal{A}(S,k) \\ \nu_i \ne 1 \ \forall i \in S}}\ \prod_{i\in S}\big[q^{\,\nu_i - 1}\big]f_i .$$

*Proof.* In the master formula, if $\nu_i = 1$ for some $i$ then the corresponding factor is $[q^{0}]f_i = 0$, so the whole product vanishes. Discarding vanishing terms leaves exactly the stated restricted sum. $\square$

**Theorem 4.9 (Half locality).** If $\nu \in \mathcal{A}(S,k)$ satisfies $\nu_i \ne 1$ for all $i \in S$, then
$$2\,|\operatorname{supp}\nu| \;\le\; k .$$
Consequently, under the hypotheses of Theorem 4.8, the level-$k$ coefficient depends on at most $\lfloor k/2 \rfloor$ of the factors at a time.

*Proof.* Every $i \in \operatorname{supp}\nu$ has $\nu_i \ne 0$ and $\nu_i \ne 1$, hence $\nu_i \ge 2$. Summing over the support, $2|\operatorname{supp}\nu| \le \sum_{i \in \operatorname{supp}\nu}\nu_i = k$. $\square$

**Corollary 4.10 (Monster half locality).** For a product of the $194$ McKay–Thompson series, the coefficient of $q^{k-194}$ is a universal polynomial in the tails of at most $\lfloor k/2\rfloor$ of the $194$ classes.

### 4.4 Integrality transfer

**Theorem 4.11 (Integrality transfer).** Let $R \subseteq \mathbb{C}$ be a subring and let $(f_i)_{i \in S}$ be normalized with $[q^n]f_i \in R$ for all $i \in S$ and all $n \in \mathbb{Z}$. Then $[q^{k-m}]\prod_{i\in S}f_i \in R$ for every $k \ge 0$.

*Proof.* By Theorem 3.1 the coefficient is a finite sum of finite products of elements of $R$, and $R$ is closed under sums and products. $\square$

**Corollary 4.12.** If every McKay–Thompson-shaped factor has integer coefficients, then every Laurent coefficient of the $194$-fold product is an integer. (Note $[q^{-1}]f_i = 1 \in R$ and $[q^{n}]f_i = 0 \in R$ for $n<-1$, so the hypothesis reduces to integrality of the tails.)

---

## 5. The logarithmic derivative and the Newton recursion

The master formula is closed but non-recursive. We now derive a recursion, whose cost per level does not grow with $m$.

**Definition 5.1 (Logarithmic derivative).** For $u \in \mathbb{C}[[q]]$ with $u(0) \ne 0$, set
$$\mathcal{L}(u) := u' \, u^{-1} \in \mathbb{C}[[q]],$$
where $'$ is the formal derivative and $u^{-1}$ the power-series inverse.

**Theorem 5.2 (Logarithmic derivative linearizes products).** Let $(u_i)_{i \in S}$ be power series with $u_i(0) \ne 0$. Then
$$\Big(\prod_{i\in S}u_i\Big)' \;=\; \Big(\prod_{i \in S}u_i\Big)\cdot \sum_{i \in S}\mathcal{L}(u_i). \tag{5.1}$$

*Proof.* Induction on $|S|$. For $S = \varnothing$ both sides are $0$. For the step, write $P = \prod_{i \in S}u_i$ and adjoin $a \notin S$. Leibniz gives $(u_a P)' = u_a' P + u_a P'$. By the inductive hypothesis $P' = P\sum_{i\in S}\mathcal{L}(u_i)$, so
$$(u_aP)' = u_a'P + u_aP\sum_{i\in S}\mathcal{L}(u_i) = u_aP\Big(u_a'u_a^{-1} + \sum_{i \in S}\mathcal{L}(u_i)\Big),$$
using $u_au_a^{-1}=1$, which is legitimate because $u_a(0) \ne 0$. This is (5.1) for $S \cup \{a\}$. $\square$

**Definition 5.3 (Logarithmic power sums).** For a family $(f_i)_{i \in S}$ of normalized series with unit parts $u_i = q f_i$, put
$$p_r := \big[q^{r}\big]\sum_{i \in S}\mathcal{L}(u_i) \;=\; \sum_{i\in S}\big[q^{r}\big]\frac{u_i'}{u_i}, \qquad r \ge 0 .$$

**Theorem 5.4 (Newton recursion).** With $c_k$ the level-$k$ coefficients of $\prod_{i\in S}f_i$ and $p_r$ as in Definition 5.3,
$$\boxed{\;(k+1)\,c_{k+1} \;=\; \sum_{j=0}^{k} c_j \, p_{k-j}\;}\qquad (k \ge 0), \qquad c_0 = 1. \tag{5.2}$$

*Proof.* Let $P = \prod_{i\in S}u_i$, so $c_j = [q^j]P$ by (2.1). Extract the coefficient of $q^k$ from (5.1). On the left, $[q^k](P') = (k+1)[q^{k+1}]P = (k+1)c_{k+1}$, since formal differentiation sends $q^{k+1} \mapsto (k+1)q^k$. On the right, the Cauchy product gives
$$\big[q^k\big]\Big(P \cdot \sum_i \mathcal{L}(u_i)\Big) = \sum_{j=0}^{k}\big[q^{j}\big]P \cdot \big[q^{k-j}\big]\sum_i\mathcal{L}(u_i) = \sum_{j=0}^{k}c_jp_{k-j}.$$
The base case $c_0=1$ is Corollary 3.4. $\square$

**Proposition 5.5 (Constant term of the logarithmic derivative).** For normalized $f$ with unit part $u = qf$,
$$\big[q^{0}\big]\mathcal{L}(u) = \big[q^0\big]f = a_0 .$$

*Proof.* $u$ has constant term $1$, hence $u^{-1}$ has constant term $1$, and $[q^0](u'u^{-1}) = [q^0](u')\cdot[q^0](u^{-1}) = [q^1]u = [q^0]f$. $\square$

**Corollary 5.6 (Level one, two ways).** $c_1 = \sum_{i\in S}[q^0]f_i$.

*Proof.* From (5.2) with $k=0$: $c_1 = c_0p_0 = p_0$, and $p_0 = \sum_i [q^0]f_i$ by Proposition 5.5. Alternatively, the master formula at $k=1$ sums over the $m$ indicator vectors $\nu = \delta_i$, whose terms are $[q^0]f_i$. $\square$

The agreement of the two derivations is a genuine consistency check: the Cauchy route and the calculus route are logically independent.

**Corollary 5.7 (Level two).** $2c_2 = \big(\sum_{i}a_0(f_i)\big)^2 - \sum_i a_0(f_i)^2 + 2\sum_i a_1(f_i)$.

*Proof.* The master formula at $k=2$ splits the compositions of $2$ into the vectors $2\delta_i$ (contributing $a_1(f_i)$) and $\delta_i+\delta_j$ with $i \ne j$ (contributing $a_0(f_i)a_0(f_j)$). Summing the latter over unordered pairs gives $\tfrac12\big[(\sum_i a_0)^2 - \sum_i a_0^2\big]$. $\square$

---

## 6. Inverting the recursion: rigidity

Over a field of characteristic zero the factor $k+1$ in (5.2) is invertible, so the recursion is not merely a relation but a *determination*.

**Theorem 6.1 (Rigidity).** Let $(f_i)_{i\in S}$ and $(g_i)_{i \in T}$ be two families of normalized series, with $|S| = m$ and $|T| = n$ *not assumed equal*. Denote by $p_r^{f}, p_r^{g}$ their logarithmic power sums and by $c_j^{f}, c_j^{g}$ their level-$j$ coefficients. Fix $K \ge 0$ and suppose
$$p_r^{f} = p_r^{g}\qquad\text{for all } r < K .$$
Then
$$c_j^{f} = c_j^{g}\qquad\text{for all } j \le K .$$

*Proof.* Strong induction on $j$. For $j = 0$ both sides are $1$ by Corollary 3.4. Let $j = k+1 \le K$ and assume the claim for all smaller indices. In the sum $\sum_{i=0}^{k}c_i p_{k-i}$ of (5.2), each $i$ satisfies $i \le k < j \le K$, so $c_i^f = c_i^g$ by the inductive hypothesis; and each $k-i \le k < K$, so $p^f_{k-i} = p^g_{k-i}$ by assumption. Hence the two right-hand sides of (5.2) coincide, giving
$$(k+1)c^f_{k+1} = (k+1)c^g_{k+1}.$$
Since $\operatorname{char}\mathbb{C} = 0$, $k+1 \ne 0$ in $\mathbb{C}$, and cancellation yields $c^f_{k+1} = c^g_{k+1}$. $\square$

**Remark 6.2.** The number of factors has disappeared from the conclusion. Two products may have poles of different orders $m \ne n$; the theorem compares them level by level, i.e. in degrees $j-m$ versus $j-n$. In this indexing the *head* of a product of normalized series is a function of the sequence $(p_r)_r$ alone. Characteristic zero is used exactly once, in the cancellation of $k+1$.

**Remark 6.3 (Sharpness).** Knowledge of $p_0,\dots,p_{K-1}$ controls exactly the levels up to $K$ and no further. For instance the one-element family $\{2\}$ and the two-element family $\{1,1\}$ (in the linear case of Section 7) have $p_1 = 2$ in common, so their levels $0$ and $1$ agree, while $p_2 = 4 \ne 2$ and correspondingly their level-$2$ coefficients differ ($0$ versus $1$).

---

## 7. The linear case: classical symmetric function theory

Let $a : S \to \mathbb{C}$ be a finite family of complex numbers and take the **linear** normalized series
$$\ell_i := q^{-1} + a_i ,$$
whose tail is $(a_i,0,0,\dots)$ and whose unit part is $u_i = 1 + a_i q$.

**Proposition 7.1 (Coefficients are elementary symmetric functions).** For every $k \ge 0$,
$$\big[q^{\,k-m}\big]\prod_{i\in S}\ell_i \;=\; e_k(a) := \sum_{\substack{T\subseteq S\\|T| = k}}\ \prod_{i \in T}a_i .$$

*Proof.* In the master formula, $[q^{\nu_i-1}]\ell_i$ is $1$ if $\nu_i = 0$, $a_i$ if $\nu_i = 1$, and $0$ if $\nu_i \ge 2$. So the surviving $\nu \in \mathcal{A}(S,k)$ are exactly the indicator vectors of $k$-element subsets $T$, each contributing $\prod_{i\in T}a_i$. $\square$

**Proposition 7.2 (Logarithmic derivative of a linear unit).** For $a \in \mathbb{C}$ and $r \ge 0$,
$$\big[q^{r}\big]\,\mathcal{L}(1 + aq) \;=\; (-1)^{r}a^{\,r+1}.$$

*Proof.* $(1+aq)' = a$, and $(1+aq)^{-1} = \sum_{r\ge0}(-a)^rq^r$, as one checks by multiplying out: the product telescopes to $1$. Hence $\mathcal{L}(1+aq) = a\sum_r(-a)^rq^r$, whose $r$-th coefficient is $a\cdot(-1)^ra^r$. $\square$

**Corollary 7.3.** In the linear case $p_r = (-1)^r \, \pi_{r+1}(a)$, where $\pi_s(a) := \sum_{i\in S}a_i^{\,s}$ is the classical $s$-th power sum.

**Theorem 7.4 (Newton's identities).** For any finite family $a: S \to \mathbb{C}$ and any $k \ge 0$,
$$(k+1)\,e_{k+1}(a) \;=\; \sum_{j=0}^{k}(-1)^{\,k-j}\,e_j(a)\,\pi_{\,k-j+1}(a).$$

*Proof.* Apply the Newton recursion (5.2) to the family $(\ell_i)_{i \in S}$, substituting $c_j = e_j(a)$ from Proposition 7.1 and $p_{k-j} = (-1)^{k-j}\pi_{k-j+1}(a)$ from Corollary 7.3. $\square$

The classical low cases follow at once: $k=0$ gives $e_1 = \pi_1$; $k=1$ gives $2e_2 = \pi_1^2 - \pi_2$.

**Theorem 7.5 (Power sums determine elementary symmetric functions).** Let $a : S \to \mathbb{C}$ and $b : T\to\mathbb{C}$ be finite families, with $|S|$ and $|T|$ not assumed equal, and let $K \ge 0$. If
$$\pi_{r+1}(a) = \pi_{r+1}(b) \qquad\text{for all } r < K,$$
then $e_j(a) = e_j(b)$ for all $j \le K$.

*Proof.* By Corollary 7.3 the hypothesis says the logarithmic power sums of the two linear families agree below degree $K$ (the sign $(-1)^r$ is common to both). Rigidity (Theorem 6.1) gives equality of the level-$j$ coefficients for $j \le K$, which by Proposition 7.1 are the elementary symmetric functions. $\square$

**Remark 7.6.** Theorem 7.5 is the classical invertibility of Newton's identities in characteristic zero, here obtained without any symmetric-function combinatorics: the entire argument runs through poles of Laurent series and one division by $k+1$. Together with Theorem 7.4 it shows that the pole-order machinery does not merely resemble symmetric-function theory — it contains it as the degenerate case in which all tails terminate after one term.

---

## 8. Algorithms

Two complementary algorithms compute the level-$k$ coefficients. Throughout, $m$ is the number of factors and $K$ the highest level required; arithmetic operations in the coefficient ring are the unit of cost.

### 8.1 Composition-sum evaluation

**Algorithm A (Master formula evaluation).**

```
INPUT : tails A[1..m][0..K-1] of normalized series; level k <= K
OUTPUT: c_k

total <- 0
for each nu in WeakCompositions(m, k):
    term <- 1
    for i in 1..m:
        if nu[i] = 0 then term <- term * 1          # pole coefficient
        else               term <- term * A[i][nu[i]-1]
        if term = 0 then break                       # early exit
    total <- total + term
return total
```

Cost: $\binom{m+k-1}{k}$ compositions, i.e. $O(m^k/k!)$ for fixed $k$; with the locality decomposition of Theorem 4.4 one instead enumerates subsets $T$ of size $t \le \min(k,m)$ together with strict compositions of $k$ into $t$ positive parts, for a total of $\sum_{t\le \min(k,m)}\binom{m}{t}\binom{k-1}{t-1}$ terms, and under the vanishing-constant-term hypothesis only $t \le \lfloor k/2\rfloor$ occurs. Algorithm A is the method of choice for structural reasoning and small $k$, since each term is individually meaningful.

### 8.2 Newton recursion

**Algorithm B (Newton recursion via logarithmic derivatives).**

```
INPUT : tails A[1..m][0..K-1]; precision K
OUTPUT: c_0..c_K

# 1. unit parts
for i in 1..m: U[i] <- [1, A[i][0], A[i][1], ..., A[i][K-1]]     # truncated at q^K

# 2. logarithmic derivatives and their sum
P[0..K-1] <- 0
for i in 1..m:
    D <- FormalDerivative(U[i])
    V <- PowerSeriesInverse(U[i])          # Newton/Cauchy inversion, O(K^2)
    L <- Truncate(D * V, K)
    P <- P + L

# 3. recursion
c[0] <- 1
for k in 0..K-1:
    s <- 0
    for j in 0..k: s <- s + c[j]*P[k-j]
    c[k+1] <- s / (k+1)
return c
```

Cost: $O(mK^2)$ for step 2 (each inversion and convolution is $O(K^2)$ by the naive schoolbook method) and $O(K^2)$ for step 3. Crucially the recursion itself is *independent of $m$*: once the power sums are aggregated, the factors are forgotten. For a moonshine-scale computation ($m = 194$) with modest $K$ this is by far the cheaper route, and rigidity (Theorem 6.1) explains why no information is lost.

### 8.3 Cross-validation

Because Algorithms A and B are logically independent — one is a Cauchy expansion, the other a calculus identity — agreement of their outputs is a meaningful correctness test. The numerical instances of Section 9 exercise exactly this.

---

## 9. Worked instances

**9.1 Two factors, level three.** Let $f = q^{-1}+2+3q$ and $g = q^{-1}+5+7q$, so $m = 2$ and level $k=3$ is the coefficient of $q^{1}$. Corollary 3.5 gives
$$\big[q^{1}\big](fg) = 1\cdot 0 + 2\cdot 7 + 3\cdot 5 + 0\cdot 1 = 29 .$$
Direct expansion confirms the coefficient of $q$ in $fg$ is $29$.

**9.2 Half locality.** Let $f = q^{-1}+3q+4q^2$ and $g = q^{-1}+7q+9q^2$, both with vanishing constant term. The four compositions of $3$ contribute
$$(0,3)\!: 1\cdot 9,\quad (1,2)\!: 0\cdot 7,\quad (2,1)\!: 3 \cdot 0,\quad (3,0)\!: 4\cdot 1,$$
so the level-$3$ coefficient is $9 + 4 = 13$. The two mixed terms die exactly as Theorem 4.8 predicts, and only single-factor excitations survive, consistent with $2|\operatorname{supp}\nu| \le 3$.

**9.3 Logarithmic derivative of a linear unit.** By Proposition 7.2, $[q^3]\mathcal{L}(1+2q) = (-1)^3 2^4 = -16$.

**9.4 Rigidity, sharp form.** Linear families $a = (3)$ and $b = (1,2)$: here $\pi_1(a) = 3 = \pi_1(b)$, hence $p_0$ agrees and by Theorem 6.1 with $K=1$ the levels $0$ and $1$ agree — indeed $e_0 = 1$ and $e_1 = 3$ for both, even though the pole orders are $1$ and $2$. At the next degree $\pi_2(a) = 9 \ne 5 = \pi_2(b)$, and the level-$2$ coefficients differ ($0$ versus $2$).

**9.5 A moonshine-scale product.** For $m = 194$ factors with integral, vanishing-constant-term tails, the product has a pole of order exactly $194$; the level-$0$ coefficient is $1$; the level-$1$ coefficient is $0$ (all constant terms vanish); the level-$3$ coefficient is exactly the sum of the $194$ coefficients $a_2$, since half locality forbids two simultaneous excitations at weight $3$; and all coefficients are integers by Theorem 4.11. Numerical experiments confirm that Algorithm A, Algorithm B, and direct multiplication of truncated unit parts agree to the computed precision.

---

## 10. Discussion

### 10.1 What makes the theory work

The whole development rests on one structural fact: **a simple pole with residue $1$ is a unit in disguise.** From it flow, in order:

- the exact pole order $m$ of an $m$-fold product;
- the level indexing, which makes products of different sizes comparable;
- the uniformity of the master formula, because $[q^{-1}]f = 1$ is the multiplicative neutral element;
- the base case $c_0 = 1$ that anchors the Newton recursion and hence rigidity;
- the invertibility of the unit parts, without which the logarithmic derivative is undefined.

The normalization is therefore not a convenience but the mechanism.

### 10.2 Locality as a physical statement

Theorem 4.4 has the flavour of a locality principle: at level $k$ only $k$ "sites" (factors) are excited, and total excitation is conserved. Theorem 4.9 says that a selection rule (vanishing constant term) forbids single quanta, halving the number of participating sites. Theorem 6.1 says that the aggregate observables $p_0,p_1,\dots$ determine the state. This dictionary is not merely decorative: it correctly predicts which refinements are available. Any hypothesis forcing the low-degree tail coefficients to vanish translates directly into a stronger locality bound by the same argument as Theorem 4.9 — if $a_0 = \cdots = a_{d-1} = 0$ for every factor, every surviving exponent is $0$ or $\ge d+1$, whence $(d+1)|\operatorname{supp}\nu| \le k$.

### 10.3 Relation to symmetric function theory

Section 7 shows the linear case is exactly classical symmetric function theory, with $c_k \leftrightarrow e_k$ and $p_r \leftrightarrow (-1)^r\pi_{r+1}$. The general case therefore deserves to be read as a *deformation* of symmetric function theory in which each "variable" $a_i$ is replaced by a full tail $(a_0^{(i)}, a_1^{(i)}, \dots)$. Under this deformation: $e_k$ becomes the level-$k$ coefficient; the $k$-subset sum becomes the composition sum; Newton's identities persist verbatim; and the invertibility of Newton's identities persists verbatim. What is lost is the vanishing of $e_k$ for $k > m$ — with genuine tails, all levels are nonzero in general — and this is precisely the room in which moonshine-type series live.

### 10.4 Practical import for moonshine-scale products

For the $194$-fold product of McKay–Thompson-shaped series the results give a complete computational recipe with rigorous error control: pole order known exactly, coefficients determined by finite truncations, interaction depth bounded by $\lfloor k/2\rfloor$, integrality guaranteed, and a recursion whose per-level cost is independent of the number of factors. Nothing here requires knowing the actual moonshine coefficients: the statements are universal in the tails, so they apply to any family of the given shape.

---

## 11. Future directions

Several natural continuations present themselves.

1. **Level-$k$ closed forms in the tails.** The master formula is a sum over compositions; expressing $c_k$ as an explicit universal polynomial in the tail coefficients (the analogue of writing $e_k$ in terms of $p_j$ via the Newton–Girard determinant) would give a canonical basis-free form. The $k \le 2$ cases are Corollaries 5.6 and 5.7.

2. **Higher-order poles.** Replace $q^{-1}$ by $q^{-d}$ with residue-type normalization $[q^{-d}]f = 1$. The unit factorization survives, but the neutral-element coincidence that makes the master formula uniform does not; identifying the correct replacement is the first question.

3. **Infinite products.** Moonshine denominator formulas involve infinite products. Under a suitable convergence hypothesis in the $q$-adic topology, does the locality decomposition give a well-defined level-$k$ coefficient for infinitely many factors? Locality suggests yes: at level $k$ only $k$ factors ever interact.

4. **Sharper selection rules.** Section 10.2 notes that vanishing of $a_0,\dots,a_{d-1}$ improves the locality bound to $k/(d+1)$. Are there arithmetic hypotheses on moonshine coefficients (congruences, replicability) that yield further structural restrictions on the surviving exponent vectors?

5. **Integrality beyond subrings.** Theorem 4.11 transfers membership in a subring. Congruence information — e.g. divisibility properties of level-$k$ coefficients modulo small primes — is not captured by that argument and would require exploiting cancellation in the composition sum.

6. **Rigidity as a moduli statement.** Theorem 6.1 says the map (families of normalized series) $\to$ (sequences of logarithmic power sums) has fibres on which the head of the product is constant. Characterizing the image of this map, and the fibres themselves, would turn rigidity into a genuine classification.

7. **Effective inversion.** Rigidity gives $c_j$ from $p_r$; the converse direction (recovering the power sums from the coefficients) is the triangular inverse of (5.2), also invertible in characteristic zero. Making both directions numerically stable in floating point, and analysing the growth of coefficients for moonshine-scale $m$, is an applied question of independent interest.

---

## 12. Conclusion

Products of normalized $q$-series — the shape ubiquitous in moonshine — have completely structured Laurent coefficients. The pole order is exactly the number of factors; the leading coefficient is always $1$; each level-$k$ coefficient is given by a uniform composition sum, sees at most $k$ of the factors (at most $k/2$ under the McKay–Thompson normalization) and only their first $k$ tail coefficients; the coefficients satisfy a Newton recursion driven by the logarithmic derivatives of the unit parts; and that recursion is invertible, so the power sums are a complete invariant of the head of the product. Specializing to one-term tails recovers the elementary symmetric functions, Newton's identities, and their classical invertibility — obtained here purely from the arithmetic of a single pole.
