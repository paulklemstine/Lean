# The Pole-Order Obstruction: Completeness, Rigidity and Symmetric-Function Hierarchies for Products of Normalized $q$-Series

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

Let $\mathbb{C}(\!(q)\!)$ be the field of formal Laurent series over $\mathbb{C}$ and call a series *normalized* if it has the shape $f = q^{-1} + a(0) + a(1)q + \cdots$, i.e. order $-1$ with leading coefficient $1$ — the shape of a McKay–Thompson series of Monstrous Moonshine. We study the elementary but surprisingly rigid obstruction that prevents the class of normalized series from being closed under multiplication, and we determine the fine structure of the corrected product.

Our results fall into four groups. **(1) The obstruction.** A product of $m$ normalized series has order exactly $-m$; hence $q^m\prod_i f_i$ has order $0$ and $q^{m-1}\prod_i f_i$ is again normalized. Applied to the $194$ conjugacy classes of the Monster, the full moonshine product has a pole of order exactly $194$. **(2) Structure.** The unit group splits canonically, $\mathbb{C}(\!(q)\!)^\times \cong \mathbb{C}[\![q]\!]^\times \times \mathbb{Z}$, so the order is a *complete* invariant of the coset space $\mathbb{C}(\!(q)\!)^\times/\mathbb{C}[\![q]\!]^\times$; it is *unique* in that every homomorphism to $\mathbb{Z}$ trivial on $\mathbb{C}[\![q]\!]^\times$ is an integer multiple of it; it is *torsion-free*, so no power of a series with a pole is a unit power series; and it is *additively robust*, unchanged by adding any strictly less singular series. We also show that the set of normalized series is a torsor under the group $1 + q\mathbb{C}[\![q]\!]$. **(3) Coefficient hierarchy.** We prove an exact convolution formula for the Laurent coefficient at every degree $n-m$, and show that under the moonshine normalization $a_i(0)=0$ it collapses to pure power sums at degrees $2-m$ and $3-m$, with the first interaction appearing at degree $4-m$ in the form of the second elementary symmetric function of the linear coefficients. **(4) Positivity.** For factors with non-negative real coefficients the product has non-negative real coefficients in every degree, and each coefficient of the product dominates the corresponding coefficient of every individual factor.

We also record the cryptographic reading of the structure theory: the pole order behaves as a leak invariant that is perfectly resistant to multiplicative blinding by units and perfectly randomizable by monomial shifts, a one-time-pad structure over $\mathbb{Z}$.

**Keywords:** formal Laurent series, valuation, pole order, Monstrous Moonshine, McKay–Thompson series, symmetric functions, Newton identities, blinding invariance.

---

## 1. Introduction

### 1.1 Motivation

Monstrous Moonshine attaches to each element $g$ of the Monster group $\mathbb{M}$ a *McKay–Thompson series* $T_g$, a $q$-series depending only on the conjugacy class of $g$. The Monster has exactly $194$ conjugacy classes, so there are $194$ such series, each normalized so that
$$T_g = q^{-1} + 0 + a_g(1)\,q + a_g(2)\,q^2 + \cdots$$
The identity class gives the normalized modular invariant
$$T_{1A} = J = q^{-1} + 196884\,q + 21493760\,q^2 + 864299970\,q^3 + \cdots$$

The normalization "leading term exactly $q^{-1}$, vanishing constant term" is a convention, but a load-bearing one: it fixes the class of series as a rigid geometric object rather than a loose family. A natural structural question is then whether that class is closed under the operations one wants to perform on it. It is not: multiplication overshoots. This paper quantifies the failure, shows it is an *unremovable* obstruction in several precise senses, and computes what lies beneath the leading term.

The rigidity statements are elementary in their proofs but strong in their content, and they have a natural reading in the language of information leakage: the order of a Laurent series is an integer that no multiplicative blinding, no additive masking, and no exponentiation can perturb, while an explicit and unique monomial shift resets it to any desired value. This is the structure of a perfect one-time pad over $\mathbb{Z}$, and the corresponding subgroup lattice is completely determined.

### 1.2 Summary of contributions

1. **Exact pole order** of a product of $m$ normalized series, and the sharp corrections $q^m$ (to order $0$) and $q^{m-1}$ (back to normalized form).
2. **The splitting theorem** $\mathbb{C}[\![q]\!]^\times \times \mathbb{Z} \xrightarrow{\ \sim\ } \mathbb{C}(\!(q)\!)^\times$, with explicit inverse, and the resulting **completeness** of the order as an invariant of blinding classes.
3. **Rigidity**: uniqueness up to scaling of the order among $\mathbb{Z}$-valued multiplicative invariants trivial on units of $\mathbb{C}[\![q]\!]$; **torsion-freeness**; **additive robustness**; a valuation-theoretic characterization of the image of $\mathbb{C}[\![q]\!]$ and a sharp threshold for when $q^k\prod_i f_i$ is a power series.
4. **A torsor theorem**: normalized series form a principal homogeneous space under the multiplicative group $1+q\mathbb{C}[\![q]\!]$.
5. **The coefficient hierarchy**: an exact all-degree convolution identity, and its collapse into power sums (degrees $2-m$, $3-m$) and a second elementary symmetric function (degree $4-m$) under the moonshine normalization.
6. **Positivity and domination** results for factors with non-negative real coefficients.
7. **Numerical instances** with genuine McKay–Thompson data, agreeing exactly with the identities.

---

## 2. Setting and definitions

### 2.1 Formal Laurent series and order

**Definition 2.1 (Laurent series).** A *formal Laurent series* over $\mathbb{C}$ is a function $f : \mathbb{Z} \to \mathbb{C}$, written $f = \sum_{n\in\mathbb{Z}} f_n q^n$, whose support $\{n : f_n \ne 0\}$ is bounded below. These form a field $\mathbb{C}(\!(q)\!)$ under coefficientwise addition and the convolution product
$$(fg)_n \;=\; \sum_{j+k=n} f_j\,g_k,$$
which is well defined because the supports are bounded below. Series supported in $n \ge 0$ form the subring $\mathbb{C}[\![q]\!]$ of formal power series.

**Definition 2.2 (Order).** For $f \ne 0$ set $\operatorname{ord}(f) = \min\{n : f_n \ne 0\} \in \mathbb{Z}$, and $\operatorname{ord}(0) = +\infty$. The coefficient $f_{\operatorname{ord}(f)}$ is the *leading coefficient*, written $\mathrm{lc}(f)$.

**Lemma 2.3 (Valuation axioms).** For nonzero $f,g$:
$$\operatorname{ord}(fg) = \operatorname{ord}(f)+\operatorname{ord}(g), \qquad \mathrm{lc}(fg) = \mathrm{lc}(f)\,\mathrm{lc}(g),$$
$$\operatorname{ord}(f+g) \ \ge\ \min\{\operatorname{ord}(f),\operatorname{ord}(g)\},$$
with equality in the last when $\operatorname{ord}(f)\ne\operatorname{ord}(g)$.

*Proof sketch.* Write $N = \operatorname{ord} f$, $M = \operatorname{ord} g$. The convolution coefficient at $N+M$ has the single nonzero contribution $f_N g_M \ne 0$ (all other index pairs put one factor below its order), and every coefficient below $N+M$ vanishes term by term. Additivity of order and multiplicativity of leading coefficients follow at once; in particular $\mathbb{C}(\!(q)\!)$ has no zero divisors. The ultrametric inequality for sums is immediate from the definition, and if the orders differ the lower one is unopposed. $\square$

Lemma 2.3 says that $\operatorname{ord}$ is a discrete valuation with value group $\mathbb{Z}$, and every statement in Sections 3–5 is ultimately a consequence of it.

**Lemma 2.4 (Units).** A power series $u \in \mathbb{C}[\![q]\!]$ is invertible in $\mathbb{C}[\![q]\!]$ iff $u_0 \ne 0$, iff $\operatorname{ord}(u) = 0$. A Laurent series is invertible in $\mathbb{C}(\!(q)\!)$ iff it is nonzero.

**Lemma 2.5 (Valuation subring).** For $x \in \mathbb{C}(\!(q)\!)$ we have $x \in \mathbb{C}[\![q]\!]$ if and only if $\operatorname{ord}(x) \ge 0$. Equivalently, $\mathbb{C}[\![q]\!] = \{x : x_n = 0 \text{ for all } n<0\}$ is exactly the non-negative part of the valuation.

### 2.2 Normalized series

**Definition 2.6 (Normalized series).** A Laurent series $f$ is *normalized* if
$$f_{-1} = 1 \quad\text{and}\quad f_n = 0 \text{ for all } n < -1,$$
that is, $f = q^{-1} + f_0 + f_1 q + f_2 q^2 + \cdots$. We write $a(k) := f_k$ for $k \ge 0$ and call $a(0)$ the *constant term*. A normalized series satisfies the *moonshine normalization* if in addition $a(0) = 0$.

**Proposition 2.7 (Valuation characterization).** $f$ is normalized if and only if $f \ne 0$, $\operatorname{ord}(f) = -1$ and $\mathrm{lc}(f) = 1$.

*Proof sketch.* If $f$ is normalized the support is contained in $\{-1,0,1,\dots\}$ and contains $-1$, so the order is $-1$ and the leading coefficient is $f_{-1}=1$. Conversely $\operatorname{ord}(f)=-1$ forces $f_n=0$ for $n<-1$, and $\mathrm{lc}(f)=1$ reads $f_{-1}=1$. $\square$

**Definition 2.8 (Normalized part).** For a normalized $f$, the *normalized part* is the power series
$$P_f := q\,f \;=\; 1 + a(0)\,q + a(1)\,q^2 + a(2)\,q^3 + \cdots \in \mathbb{C}[\![q]\!],$$
so that $(P_f)_0 = 1$ and $(P_f)_{k} = a(k-1)$ for $k \ge 1$. Under the moonshine normalization $P_f = 1 + a(1)q^2 + a(2)q^3+\cdots$, with vanishing *linear* term.

**Definition 2.9 (Trace series).** Given a coefficient sequence $c : \mathbb{N}\to\mathbb{C}$, the associated *trace series* is
$$T_c := q^{-1} + \sum_{n \ge 0} c(n)\,q^n,$$
which is normalized, and satisfies the moonshine normalization iff $c(0)=0$. Every McKay–Thompson series is of this form.

**Definition 2.10 (Monster data).** Write $M = 194$ for the number of conjugacy classes of the Monster group, and let $T_{c_1},\dots,T_{c_M}$ be the associated trace series. Their product $\prod_{i=1}^{M} T_{c_i}$ is the *moonshine product*.

---

## 3. The obstruction and its repair

### 3.1 Exact pole order

**Theorem 3.1 (Pole-Order Theorem).** Let $f_1,\dots,f_m$ be normalized series. Then $\prod_{i=1}^m f_i \ne 0$ and
$$\operatorname{ord}\Big(\prod_{i=1}^m f_i\Big) = -m, \qquad \mathrm{lc}\Big(\prod_{i=1}^m f_i\Big) = 1 .$$

*Proof sketch.* Induct on $m$ using Lemma 2.3: each factor contributes $\operatorname{ord} = -1$ and $\mathrm{lc} = 1$; orders add and leading coefficients multiply. The empty product has order $0$, consistent with $m=0$. $\square$

**Corollary 3.2 (Correction to order $0$).** $q^{m}\prod_{i=1}^m f_i$ has order $0$; equivalently it is an invertible power series with constant term $1$. Indeed $q^m \prod_i f_i = \prod_i P_{f_i}$.

**Corollary 3.3 (Monster case).** The moonshine product $\prod_{i=1}^{194} T_{c_i}$ has order exactly $-194$, and $q^{194}$ times it is an invertible power series with constant term $1$. It is not itself a power series, and no power $q^k$ with $k<194$ makes it one.

**Theorem 3.4 (Sharp threshold).** For normalized $f_1,\dots,f_m$ and $k \in \mathbb{N}$,
$$q^{k}\prod_{i=1}^m f_i \in \mathbb{C}[\![q]\!] \iff k \ge m .$$

*Proof sketch.* By Theorem 3.1 the order of the left side is $k-m$, and by Lemma 2.5 membership in $\mathbb{C}[\![q]\!]$ is equivalent to that order being non-negative. $\square$

### 3.2 Repair to normalized form and the torsor structure

**Theorem 3.5 (Renormalization).** If $f_1,\dots,f_m$ are normalized with $m \ge 1$, then $q^{m-1}\prod_{i=1}^m f_i$ is again normalized. In particular the binary operation $(f,g)\mapsto q\,fg$ preserves the class of normalized series, and $q^{193}\prod_{i=1}^{194} T_{c_i}$ is again of McKay–Thompson shape.

*Proof sketch.* By Theorem 3.1 the product has order $-m$ and leading coefficient $1$; multiplying by $q^{m-1}$ shifts the order to $-1$ and does not change the leading coefficient. Apply Proposition 2.7. $\square$

**Theorem 3.6 (Torsor structure).** Let $\mathcal{N}$ be the set of normalized series and let
$$G := 1 + q\,\mathbb{C}[\![q]\!] = \{u \in \mathbb{C}[\![q]\!] : u_0 = 1\},$$
a group under multiplication. Then $G$ acts simply transitively on $\mathcal{N}$: for all $f,g \in \mathcal{N}$ there is a *unique* $u \in G$ with $f = u\,g$. Thus $\mathcal{N}$ is a principal homogeneous space (torsor) under $G$.

*Proof sketch.* Given $f, g \in \mathcal{N}$, both $P_f = qf$ and $P_g = qg$ are power series with constant term $1$, hence lie in $G$, which is a group because the constant term of a product is the product of constant terms and inversion preserves constant term $1$. Set $u := P_f P_g^{-1} \in G$; then $ug = (qf)(qg)^{-1}g = f$. Uniqueness: $ug = u'g$ with $g\ne0$ gives $u=u'$ since $\mathbb{C}(\!(q)\!)$ is a field. That the action is well defined ($u \in G$, $g\in\mathcal N \Rightarrow ug\in\mathcal N$) follows from Lemma 2.3, as $\operatorname{ord}(ug) = -1$ and $\mathrm{lc}(ug)=1$. $\square$

The group $G$ appearing here is exactly the *blinding group* of Section 4: the subgroup of $\mathbb{C}[\![q]\!]^\times$ fixing both the order and the leading coefficient.

---

## 4. Structure theory: completeness, rigidity, robustness

### 4.1 The splitting theorem

**Theorem 4.1 (Splitting).** The map
$$\Phi:\ \mathbb{C}[\![q]\!]^\times \times \mathbb{Z} \longrightarrow \mathbb{C}(\!(q)\!)^\times, \qquad \Phi(u,k) = u\,q^{k},$$
is a group isomorphism (writing $\mathbb{Z}$ multiplicatively). Consequently the short exact sequence
$$1 \longrightarrow \mathbb{C}[\![q]\!]^\times \longrightarrow \mathbb{C}(\!(q)\!)^\times \xrightarrow{\ \operatorname{ord}\ } \mathbb{Z} \longrightarrow 0$$
is split, with splitting $k \mapsto q^k$, and $\operatorname{ord}\circ\Phi(u,k) = k$.

*Proof sketch.* $\Phi$ is a homomorphism because $q^kq^l=q^{k+l}$ and multiplication is commutative. *Injectivity:* if $uq^k=1$ then taking orders gives $k=0$ (as $\operatorname{ord} u = 0$), whence $u=1$. *Surjectivity:* given $x \ne 0$ with $N=\operatorname{ord}(x)$, the shifted series $u := q^{-N}x$ has order $0$, hence is a unit power series, and $x = u\,q^{N}$. The retraction statement is Lemma 2.3. $\square$

**Corollary 4.2 (Kernel description).** $\operatorname{ord}(x) = 0$ if and only if $x$ is an invertible power series. Hence $\ker(\operatorname{ord}) = \mathbb{C}[\![q]\!]^\times$.

**Theorem 4.3 (Completeness of the invariant).** For nonzero $x,y$:
$$\big(\exists\, u\in\mathbb{C}[\![q]\!]^\times:\ x = u\,y\big) \iff \operatorname{ord}(x)=\operatorname{ord}(y).$$
Equivalently $\mathbb{C}(\!(q)\!)^\times/\mathbb{C}[\![q]\!]^\times \cong \mathbb{Z}$ via the order, so the order is a *complete* invariant of the coset space: it distinguishes exactly the classes and nothing finer.

*Proof sketch.* ($\Rightarrow$) additivity plus $\operatorname{ord}(u)=0$. ($\Leftarrow$) $xy^{-1}$ has order $0$, so it is a unit power series by Corollary 4.2. $\square$

### 4.2 The cryptographic reading

Define the *pole leak* of a nonzero Laurent series to be $\lambda(x) := \operatorname{ord}(x)$.

**Proposition 4.4 (Blinding invariance).** $\lambda(x u) = \lambda(x)$ for every unit power series $u$; and conversely, if $\lambda(xw)=\lambda(x)$ for some nonzero $w$, then $w$ is a unit power series. Thus the stabilizer of the leak is *exactly* $\mathbb{C}[\![q]\!]^\times$.

**Proposition 4.5 (One-time shift).** $\lambda(x\,q^{k}) = \lambda(x)+k$, and for every target $t\in\mathbb{Z}$ there is a *unique* $k$ with $\lambda(x q^k)=t$, namely $k=t-\lambda(x)$.

Together: the pole order is unmaskable by the $\mathbb{C}[\![q]\!]^\times$-action and perfectly randomizable by the $q^{\mathbb{Z}}$-action — a one-time pad over $\mathbb{Z}$ whose key space is exactly the value group of the valuation.

**Corollary 4.6 (Monster leak).** The class of the moonshine product in $\mathbb{C}(\!(q)\!)^\times/\mathbb{C}[\![q]\!]^\times \cong \mathbb{Z}$ is $-194$; it is unchanged by blinding by any unit power series; and $q^{194}$ is the *unique* monomial shift landing the product in $\mathbb{C}[\![q]\!]^\times$.

### 4.3 Rigidity: the order is the only invariant

**Theorem 4.7 (Rigidity).** Let $\varphi : \mathbb{C}(\!(q)\!)^\times \to \mathbb{Z}$ be *any* group homomorphism (target written additively) with $\varphi(u)=0$ for all $u\in\mathbb{C}[\![q]\!]^\times$. Then
$$\varphi(x) = \varphi(q)\cdot \operatorname{ord}(x) \quad\text{for all } x \ne 0 .$$
In particular $\varphi$ is an integer multiple of the order, and two such homomorphisms agreeing on $q$ are equal.

*Proof sketch.* By Theorem 4.1 write $x = u\,q^{k}$ with $k = \operatorname{ord}(x)$. Then $\varphi(x) = \varphi(u) + k\varphi(q) = k\varphi(q)$. $\square$

Theorem 4.7 is the precise sense in which the pole-order leak is not one invariant among many: up to a global scalar it is the unique $\mathbb{Z}$-valued multiplicative invariant insensitive to blinding.

**Theorem 4.8 (Why it splits at all).** Every surjective group homomorphism $\varphi : G \twoheadrightarrow \mathbb{Z}$ from any group admits a homomorphic section. Consequently the splitting in Theorem 4.1 is not an accident of Laurent series but a consequence of the freeness of $\mathbb{Z}$.

*Proof sketch.* Pick $g$ with $\varphi(g)=1$ and let $\sigma(k) := g^{k}$; this is a homomorphism $\mathbb{Z}\to G$ with $\varphi\circ\sigma = \mathrm{id}$. $\square$

**Theorem 4.9 (Uniqueness of the correction, up to blinding).** If $\sigma : \mathbb{Z}\to\mathbb{C}(\!(q)\!)^\times$ is any homomorphic section of $\operatorname{ord}$, then $\sigma(1) = u\,q$ for a *unique* unit power series $u$. Hence $q^{194}$ is the canonical Monster correction up to blinding, and no further ambiguity exists.

*Proof sketch.* $\operatorname{ord}(\sigma(1))=1$, so $\sigma(1)q^{-1}$ has order $0$ and is a unit power series by Corollary 4.2; uniqueness holds because $\mathbb{C}(\!(q)\!)$ is a field. $\square$

### 4.4 Torsion-freeness and additive robustness

**Theorem 4.10 (No-Root Theorem).** Let $x \ne 0$ and $n \ge 1$. Then $x^{n}$ is a unit power series if and only if $x$ is. Consequently no positive power of the moonshine product is a power series; indeed
$$\operatorname{ord}\Big(\big(\textstyle\prod_{i=1}^{194} T_{c_i}\big)^{n}\Big) = -194\,n .$$

*Proof sketch.* $\operatorname{ord}(x^n)=n\operatorname{ord}(x)$ by additivity, and $n\cdot k=0$ with $n\ge1$ forces $k=0$ in the torsion-free group $\mathbb{Z}$; then apply Corollary 4.2. $\square$

**Theorem 4.11 (Additive robustness).** Let $f_1,\dots,f_m$ be normalized and let $y$ be any Laurent series (possibly zero) with $\operatorname{ord}(y) > -m$. Then
$$\operatorname{ord}\Big(\prod_{i=1}^m f_i + y\Big) = -m .$$
In particular, adding to the moonshine product any power series, any polynomial in $q$, or any finite sum of series of order $>-194$ leaves the order at exactly $-194$.

*Proof sketch.* By Lemma 2.3 the order of a sum equals the smaller of the two orders when they differ; here $\operatorname{ord}(\prod_i f_i) = -m < \operatorname{ord}(y)$. $\square$

Theorems 4.3, 4.7, 4.10 and 4.11 combine into the slogan: the pole-order obstruction is **complete**, **unique**, **indestructible under powers**, and **stable under additive masking**.

---

## 5. The coefficient hierarchy

Theorem 3.1 records only the leading behaviour. We now compute what lies underneath. Throughout, $f_1,\dots,f_m$ are normalized with coefficient sequences $a_i(0),a_i(1),a_i(2),\dots$, and we set $a_i(-1) := 1$ to encode the leading $q^{-1}$.

### 5.1 The exact convolution identity

**Theorem 5.1 (All-degree formula).** For every $n \in \mathbb{N}$,
$$\Big[\,q^{\,n-m}\,\Big]\ \prod_{i=1}^{m} f_i \;=\; \sum_{\substack{(\nu_1,\dots,\nu_m)\in\mathbb{N}^m \\ \nu_1+\cdots+\nu_m = n}} \ \prod_{i=1}^{m} a_i(\nu_i-1).$$

*Proof sketch.* Multiply by $q^m$: by Corollary 3.2, $q^m\prod_i f_i = \prod_i P_{f_i}$ is a power series, and the coefficient of $q^{\,n-m}$ in $\prod_i f_i$ equals the coefficient of $q^{n}$ in $\prod_i P_{f_i}$. Expanding the $m$-fold product of power series gives the sum over compositions $\nu$ of $n$ into $m$ non-negative parts of $\prod_i (P_{f_i})_{\nu_i}$, and $(P_{f_i})_{\nu} = a_i(\nu-1)$ with the convention $a_i(-1)=1$. $\square$

Theorem 5.1 is exact but grows combinatorially: the number of terms is $\binom{n+m-1}{m-1}$, already astronomically large for $m=194$ and modest $n$. Its value lies in the collapses it admits.

### 5.2 Low-order collapses without extra hypotheses

**Proposition 5.2 (Leading and subleading).** $\big[q^{-m}\big]\prod_i f_i = 1$ and
$$\big[q^{1-m}\big]\prod_i f_i = \sum_{i=1}^m a_i(0).$$

*Proof sketch.* $n=0$ has the single composition $\nu=0$, contributing $\prod_i a_i(-1)=1$. For $n=1$ each composition places the single unit at one index $i$, contributing $a_i(0)$. $\square$

**Proposition 5.3 (Sub-subleading).** With no hypothesis on the constant terms,
$$2\,\big[q^{2-m}\big]\prod_i f_i \;=\; 2\sum_{i} a_i(1) \;+\; \Big(\sum_i a_i(0)\Big)^{2} \;-\; \sum_i a_i(0)^2 ,$$
i.e. $\big[q^{2-m}\big]\prod_i f_i = \sum_i a_i(1) + e_2\big(a_1(0),\dots,a_m(0)\big)$, where
$$e_2(x_1,\dots,x_m) := \sum_{i<j} x_i x_j = \tfrac12\Big[\big(\textstyle\sum_i x_i\big)^2 - \textstyle\sum_i x_i^2\Big].$$

*Proof sketch.* $n=2$ splits into compositions with a single part equal to $2$ (contributing $a_i(1)$) and those with two parts equal to $1$ at distinct indices $i<j$ (contributing $a_i(0)a_j(0)$). The division-free form avoids dividing by $2$ and is valid over any commutative ring. $\square$

### 5.3 The moonshine collapse

Assume from now on the moonshine normalization $a_i(0)=0$ for all $i$. Then $P_{f_i} = 1 + a_i(1)q^{2} + a_i(2)q^{3} + \cdots$: the *linear* term of each corrected factor vanishes. This single fact pushes the first interaction between two factors from degree $2$ to degree $4$.

**Lemma 5.4 (Quadratic level).** If $g_1,\dots,g_m$ are power series with $(g_i)_0=1$ and $(g_i)_1=0$, then
$$\Big[q^{2}\Big]\prod_i g_i = \sum_i (g_i)_2 .$$

**Theorem 5.5 (Third-order identity).** Under the same hypotheses,
$$\Big[q^{3}\Big]\prod_i g_i = \sum_i (g_i)_3 .$$
Consequently, for $m$ normalized series with vanishing constant terms,
$$\Big[q^{\,3-m}\Big]\prod_{i=1}^m f_i = \sum_{i=1}^m a_i(2).$$

*Proof sketch.* Induct on the number of factors, using the two-factor expansion
$$[q^3](ab) = a_0b_3 + a_1b_2 + a_2b_1 + a_3b_0 .$$
By induction the partial product $\prod_{i<k} g_i$ again has constant term $1$ and vanishing linear term (Proposition 5.2 with $a_i(0)=0$), so the two middle cross terms vanish, leaving $[q^3]\prod_{i<k}g_i + [q^3]g_k$. Transport to the Laurent level via $[q^{3-m}]\prod_i f_i = [q^{3}]\prod_i P_{f_i}$ and $(P_{f_i})_3 = a_i(2)$. $\square$

**Theorem 5.6 (Fourth-order identity).** Let $g_1,\dots,g_m$ be power series with $(g_i)_0=1$ and $(g_i)_1=0$. Then
$$2\,\Big[q^{4}\Big]\prod_i g_i \;=\; 2\sum_i (g_i)_4 \;+\; \Big(\sum_i (g_i)_2\Big)^{2} - \sum_i (g_i)_2^{2},$$
that is, $[q^4]\prod_i g_i = \sum_i (g_i)_4 + e_2\big((g_1)_2,\dots,(g_m)_2\big)$. Consequently, for $m$ normalized series with vanishing constant terms,
$$\Big[q^{\,4-m}\Big]\prod_{i=1}^m f_i \;=\; \sum_{i=1}^m a_i(3) \;+\; e_2\big(a_1(1),\dots,a_m(1)\big).$$

*Proof sketch.* Induct on the number of factors using the two-factor expansion
$$[q^4](ab) = a_0b_4 + a_1b_3 + a_2b_2 + a_3b_1 + a_4b_0 .$$
For the partial product $A = \prod_{i<k}g_i$ we know: $A_0=1$, $A_1=0$, $A_2 = \sum_{i<k}(g_i)_2$ (Lemma 5.4), $A_3 = \sum_{i<k}(g_i)_3$ (Theorem 5.5). With $B = g_k$ satisfying $B_0=1$, $B_1=0$, the expansion reduces to
$$[q^4](AB) = A_4 + B_4 + A_2B_2 ,$$
and $A_2 B_2 = \big(\sum_{i<k}(g_i)_2\big)(g_k)_2$ is exactly the new batch of pairwise products needed to upgrade $e_2$ over $\{i<k\}$ to $e_2$ over all indices, since
$$e_2(x_1,\dots,x_k) = e_2(x_1,\dots,x_{k-1}) + x_k\sum_{i<k}x_i .$$
The division-free formulation follows from the identity $2e_2 = (\sum x)^2 - \sum x^2$; stating the theorem in that form keeps it valid without dividing by $2$. The Laurent statement follows via $(P_{f_i})_2 = a_i(1)$ and $(P_{f_i})_4 = a_i(3)$. $\square$

**Summary table.** For $m$ normalized series with vanishing constant terms:

| degree | coefficient of $\prod_i f_i$ |
|---|---|
| $-m$ | $1$ |
| $1-m$ | $0$ |
| $2-m$ | $\sum_i a_i(1)$ |
| $3-m$ | $\sum_i a_i(2)$ |
| $4-m$ | $\sum_i a_i(3) + e_2\big(a(1)\big)$ |

**Monster specializations.** With $m = 194$ the four rows read: the coefficient at degree $-193$ vanishes; at $-192$ it is $\sum_i c_i(1)$; at $-191$ it is $\sum_i c_i(2)$; and at $-190$ it satisfies
$$2\,\Big[q^{-190}\Big]\prod_{i=1}^{194} T_{c_i} = 2\sum_{i} c_i(3) + \Big(\sum_i c_i(1)\Big)^{2} - \sum_i c_i(1)^2 .$$

### 5.4 Interpretation

The hierarchy has a clean generating-function explanation. Writing $P_i = \exp\!\big(\log P_i\big)$ with $\log P_i = \sum_{k\ge2} \ell_i(k)q^{k}$ (no linear term, because $(P_i)_1=0$), we get
$$\prod_i P_i = \exp\Big(\sum_{k\ge2} L_k q^{k}\Big), \qquad L_k := \sum_i \ell_i(k) .$$
Every coefficient of the corrected product is therefore a universal polynomial in the *power sums* $L_2, L_3, \dots$, with coefficients independent of $m$. Degrees $2$ and $3$ can only use $L_2$ and $L_3$ linearly — there is no way to write $2$ or $3$ as a sum of two or more parts each $\ge 2$ — while degree $4$ admits the partition $4 = 2+2$, which is precisely the source of the quadratic term $\tfrac12 L_2^2$ and, after unwinding, of $e_2$. The first interaction of two distinct factors is thus forced to appear at degree $4$ and nowhere earlier. This is the structural reason for the "three degrees of additivity" phenomenon.

---

## 6. Positivity and domination

McKay–Thompson coefficients for the identity class are dimensions of graded pieces of an infinite-dimensional representation, hence non-negative integers; for other classes they are traces, but non-negativity holds in many cases of interest. The convolution identity converts this into structural statements about the product.

**Definition 6.1.** A complex number $z$ is *non-negative real* if $z = r$ for some real $r \ge 0$. This property is preserved by addition, by multiplication, and by finite sums and products.

**Theorem 6.2 (Positivity propagation).** Let $f_1,\dots,f_m$ be normalized with $a_i(k)$ non-negative real for all $i$ and all $k \ge 0$. Then for every $n \in \mathbb{N}$, the coefficient $\big[q^{\,n-m}\big]\prod_i f_i$ is non-negative real. Moreover $\big[q^{\,d}\big]\prod_i f_i = 0$ for every $d < -m$, so the statement covers all degrees.

*Proof sketch.* By Theorem 5.1 the coefficient is a finite sum of finite products of the $a_i(\nu_i-1)$ (with $a_i(-1)=1$), and non-negative reals are closed under sums and products. Vanishing below $-m$ is Theorem 3.1. $\square$

**Theorem 6.3 (Coefficient domination).** Under the hypotheses of Theorem 6.2, for every index $j$ and every $n \ge 1$,
$$a_j(n-1) \ \le\ \big[q^{\,n-m}\big]\prod_{i=1}^m f_i ,$$
both sides being non-negative reals. In particular the corrected moonshine product grows at least as fast, coefficientwise, as the largest of its McKay–Thompson factors.

*Proof sketch.* In the sum of Theorem 5.1, consider the single composition $\nu$ with $\nu_j = n$ and $\nu_i = 0$ for $i \ne j$; its contribution is $a_j(n-1)\prod_{i\ne j}a_i(-1) = a_j(n-1)$. All other contributions are non-negative reals, so the total is at least this one term. $\square$

Notably the proof is purely combinatorial: an analytic-looking growth estimate falls out of the bookkeeping identity, with no analysis involved.

---

## 7. Numerical instances

We record explicit checks against genuine McKay–Thompson data. Take the three trace series
$$T_{1A} = q^{-1} + 196884\,q + 21493760\,q^{2} + 864299970\,q^{3} + \cdots,$$
$$T_{2A} = q^{-1} + 4372\,q + 96256\,q^{2} + 1240002\,q^{3} + \cdots,$$
$$T_{3A} = q^{-1} + 783\,q + 8672\,q^{2} + 65367\,q^{3} + \cdots,$$
all with vanishing constant terms, and form $\Pi := T_{1A}T_{2A}T_{3A}$, which by Theorem 3.1 has order $-3$.

| degree | predicted by | value |
|---|---|---|
| $-3$ | Theorem 3.1 | $1$ |
| $-2$ | Proposition 5.2 | $0$ |
| $-1$ | Proposition 5.3 | $196884+4372+783 = 202039$ |
| $0$ | Theorem 5.5 | $21493760+96256+8672 = 21598688$ |
| $1$ | Theorem 5.6 | $865605339 + 1018360296 = 1883965635$ |

The degree-$1$ entry decomposes as
$$\sum_i a_i(3) = 864299970 + 1240002 + 65367 = 865605339,$$
$$e_2(196884,4372,783) = 196884\cdot4372 + 196884\cdot783 + 4372\cdot783 = 1018360296 .$$
Direct convolution of the truncated series reproduces all five numbers exactly.

Two features are worth noting. First, the jump from $2.2\times10^{7}$ at degree $0$ to $1.9\times10^{9}$ at degree $1$ is dominated by the cross term $e_2$, which exceeds the sum of the individual cubic coefficients: the interaction, once it switches on, immediately dominates. Second, degrees $-2$, $-1$ and $0$ are *exactly additive* in the input data — the three degrees of additivity guaranteed by the vanishing constant terms.

---

## 8. Algorithms

Three computational procedures follow from the theory.

**(A) Truncated Laurent arithmetic and pole extraction.** Represent a Laurent series by an integer offset $d$ and a coefficient vector $(c_0,\dots,c_{N})$ meaning $\sum_{j} c_j q^{d+j}$. Multiplication is discrete convolution: the product of series with offsets $d_1,d_2$ and lengths $N_1,N_2$ has offset $d_1+d_2$ and coefficients given by the Cauchy product, computable in $O(N_1N_2)$ time (or $O(N\log N)$ by FFT). The order is the index of the first nonzero coefficient, shifted by the offset. Multiplying $m$ series each truncated to $N$ terms costs $O(mN^2)$ by iterated convolution, and the pole order of the result is read off in $O(N)$.

**(B) Symmetric-function coefficient prediction.** Given only the low-order data $a_i(0),a_i(1),a_i(2),a_i(3)$ of $m$ normalized series with $a_i(0)=0$, the coefficients of the product at degrees $-m$ through $4-m$ are computed by the closed forms of Section 5 in $O(m)$ time and $O(1)$ space, using the division-free identity $2e_2 = (\sum x)^2 - \sum x^2$. This is exponentially cheaper than convolution, which would need $\binom{n+m-1}{m-1}$ terms; for $m=194$ and $n=4$ that is over $6\times10^{7}$ compositions versus $194$ additions.

**(C) Blinding, masking and unmasking.** Given a series $x$, a unit power series $u$, an additive mask $y$ with $\operatorname{ord}(y)>\operatorname{ord}(x)$, and a shift $k$, the pipeline $x \mapsto q^{k}(ux) + y$ has order $\operatorname{ord}(x)+k$; recovery of $\operatorname{ord}(x)$ from the transcript is exact and the unique unmasking shift is $k^{\ast} = -\operatorname{ord}(x)$. Each step is $O(N\log N)$ or better, and the leak computation is $O(N)$.

---

## 9. Discussion

### 9.1 What is really being used

Every structural theorem in Sections 3 and 4 is a consequence of two facts: order is additive on products, and its value group $\mathbb{Z}$ is free of rank one and torsion-free. Nothing about $\mathbb{C}$, about modularity, or about the Monster enters. Accordingly, all of Sections 3 and 4 hold verbatim over any field of formal Laurent series over an integral domain, and more generally for any discrete valuation with value group $\mathbb{Z}$ — for instance the $p$-adic valuation on $\mathbb{Q}_p$, where "pole order" becomes "$p$-adic valuation" and "blinding by a unit power series" becomes "multiplication by a $p$-adic unit". The Monster enters only through the numeral $194$ and through the positivity of Section 6.

### 9.2 The cryptographic analogy, and its limits

The analogy with blinding is genuine at the level of group structure: the ambient group is a direct product $K \times \mathbb{Z}$, where $K$ acts as the blinding group and $\mathbb{Z}$ as the leaked value; the leak is a complete invariant of the $K$-orbits, is unique up to scaling among $\mathbb{Z}$-valued invariants trivial on $K$, and is perfectly shifted by the $\mathbb{Z}$-factor. This is exactly the structure one wants of a one-time pad, and exactly the structure one *does not* want of a side channel: any protocol that transmits a formal Laurent series and hopes to conceal its valuation by multiplicative randomization is doomed, no matter how the randomizing unit is chosen.

The limits should be stated as clearly. This is a statement about a specific algebraic invariant of an idealized object, not about a concrete cryptosystem, and the "adversary" here is granted exact algebraic access to the series. What the theory contributes is a complete classification of what such an adversary can and cannot learn from valuation-type queries.

### 9.3 The role of normalization

The coefficient hierarchy shows the normalization $a(0)=0$ doing real work. Without it, interaction begins immediately: the degree-$(2-m)$ coefficient already carries $e_2$ of the constant terms (Proposition 5.3). With it, three degrees are purely additive, and interaction begins at degree $4-m$ with $e_2$ of the *linear* coefficients. Deferring nonlinearity is exactly what makes low-order moonshine identities look like sums of dimensions.

---

## 10. Future directions

**C1. The all-order identity as a complete homogeneous symmetric function.** For a product of $m$ normalized series with vanishing constant terms, we conjecture that the Laurent coefficient at degree $n-m$ is the complete homogeneous symmetric expression in which every partition of $n$ into parts $\ge 2$ contributes exactly once, with multiplicities given by multinomial coefficients over the factors. Equivalently, the generating function of the corrected product is $\exp\big(\sum_i \log(1 + \sum_{k\ge2} a_i(k-1)q^{k})\big)$, so the coefficients are polynomial in the power sums $p_j = \sum_i a_i(j)$ with universal, $m$-independent coefficients. The key insight is that vanishing constant terms make each corrected factor $1 + O(q^2)$, pushing the first interaction from degree $2$ to degree $4$; the degree-$n$ coefficient is therefore a universal polynomial in the power sums with *no* dependence on $m$ until $n=4$, which is exactly what the results at $n=1,2,3$ (pure power sums) and $n=4$ (first cross term, $e_2$ of the linear coefficients) establish. The exact convolution identity over compositions already provides the raw expansion; the remaining work is to organize the collapse by partitions.

**C2. Uniqueness of the leak for non-multiplicative adversaries.** Let $\Phi : \mathbb{C}(\!(q)\!)^\times \to \mathbb{Z}$ be any function, *not assumed a homomorphism*, that is (i) invariant under multiplication by unit power series and (ii) additive on the subgroup $q^{\mathbb{Z}}$. We conjecture $\Phi = c\cdot\operatorname{ord}$ for some integer $c$. The key insight is that condition (i) forces $\Phi$ to factor through the coset space $\mathbb{C}(\!(q)\!)^\times/\mathbb{C}[\![q]\!]^\times$, identified with $\mathbb{Z}$ *as a set*, so (ii) upgrades a set-theoretic factorization to an additive one without ever assuming multiplicativity on the whole group. This strictly strengthens the rigidity theorem by removing the homomorphism hypothesis.

**Further avenues.** (i) *Higher orders explicitly*: compute degrees $5-m$ and $6-m$, where the partitions $5=2+3$ and $6=2+2+2=3+3=2+4$ predict mixed symmetric functions, and confirm the multinomial pattern of C1. (ii) *Positivity of cross terms*: since $e_2$ of non-negative reals is non-negative, the domination bound of Theorem 6.3 can presumably be sharpened at degree $4-m$ to $\sum_i a_i(3) + e_2(a(1))$ exactly, giving a two-sided estimate. (iii) *Other valuations*: transport the whole structure theory to a general discrete valuation ring and identify which statements need the residue field to be a field of characteristic zero (none, we expect). (iv) *Replicability*: the McKay–Thompson series satisfy replication formulas; determining how the coefficient hierarchy interacts with replication would connect the elementary bookkeeping here to the deeper moonshine identities.

---

## 11. Conclusion

The order of a formal Laurent series is the simplest nontrivial invariant one can attach to it, and precisely because of its simplicity it is maximally rigid. We have shown that for products of normalized $q$-series of moonshine type the invariant is exactly computable ($-m$ for $m$ factors, so $-194$ for the full Monster product), complete (it classifies series up to multiplication by unit power series), unique (up to scaling, among all $\mathbb{Z}$-valued multiplicative invariants trivial on unit power series), and indestructible (immune to powers and to additive masking of higher order), with a unique repair by the monomial $q^{194}$ — or $q^{193}$ if one wants a normalized series back, the set of normalized series being a torsor under the group of power series with constant term $1$.

Below the leading term, the moonshine normalization produces a striking pattern: three consecutive degrees whose coefficients are pure sums over the factors, followed at degree $4-m$ by the first cross term, the second elementary symmetric function of the linear coefficients. The mechanism — vanishing linear terms in the corrected factors, hence no partition of $2$ or $3$ into parts of size at least $2$ — explains both why the additivity holds and exactly where it must break.
