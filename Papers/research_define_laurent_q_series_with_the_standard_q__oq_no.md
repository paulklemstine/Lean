# The Corrected Product: Normalized $q$-Series Form a Torsion-Free Divisible Group

**Author:** Aristotle
**Date:** 2026-08-24

## Abstract

A formal Laurent series $f \in \mathbb{C}((q))$ is called *normalized* if it has the shape
$$f(q) = q^{-1} + a_0 + a_1 q + a_2 q^2 + \cdots,$$
that is, a simple pole at $q = 0$ with residue $1$ and no lower-order terms. This is the normalization carried by the modular invariant $J = j - 744$ and by all $194$ McKay–Thompson series of Monstrous Moonshine. Normalized series are not closed under multiplication: a product of $m$ of them has a pole of order exactly $m$. We make this obstruction precise and then dissolve it. We prove that $q^{k} f_1 \cdots f_m$ is normalized if and only if $k = m-1$, so the correction is unique; we introduce the *corrected product* $f \star g := q f g$ and show that the normalized series form a commutative group under $\star$ with identity $q^{-1}$, canonically isomorphic to the group of $1$-units of $\mathbb{C}[[q]]$; we prove the structure theorem $\mathbb{C}((q))^{\times} \cong \mathbb{Z} \times \mathbb{C}[[q]]^{\times}$ exhibiting the pole order as a direct summand; and we prove that the corrected group is **torsion free** (a geometric-sum argument) and **divisible** (via substitution into the binomial series $(1+X)^{1/n}$), hence uniquely divisible, hence a $\mathbb{Q}$-vector space in multiplicative notation. Consequences include: closed-form Newton identities for the coefficients of corrected inverses and roots; the existence and uniqueness of rational corrected powers $f^{\star r}$ for $r \in \mathbb{Q}$; the fact that each power map is a group automorphism; and the existence of a unique normalized $G$ with $q^{193} G^{194} = q^{193} \prod_g T_g$, the canonical *geometric mean* of the Monster's trace functions. We also record a finite-determinacy theorem for coefficients of products, and exact numerical evidence that the corrected square root of $J$ has integer coefficients through $q^{10}$ while its cube and fifth roots have denominators that are unbounded powers of $3$ and $5$ respectively.

**Keywords:** normalized $q$-series, Laurent series, pole order, $1$-units, divisible abelian groups, binomial series, McKay–Thompson series, Monstrous Moonshine.

---

## 1. Introduction

### 1.1 Normalization as a convention with consequences

The theory of modular functions is full of normalizations, and Monstrous Moonshine is built on one of them. Every McKay–Thompson series $T_g$ attached to a conjugacy class $g$ of the Monster group $\mathbb{M}$ is expanded as a $q$-series of the specific shape
$$T_g(q) = q^{-1} + a_0(g) + a_1(g)\, q + a_2(g)\, q^2 + \cdots,$$
and the principal one, $T_1 = J = j - 744$, has
$$J(q) = q^{-1} + 196884\,q + 21493760\,q^2 + 864299970\,q^3 + \cdots. \tag{1.1}$$
The normalization does two things at once: it fixes the additive ambiguity (by prescribing the constant term, in the moonshine convention $a_0 = 0$) and it fixes the multiplicative ambiguity (by prescribing that the polar part is exactly $q^{-1}$). Without the latter, the statement "$196884 = 196883 + 1$" would be meaningless, because the coefficients would only be defined up to a common scalar.

Because the normalization is a multiplicative condition, it is natural to ask whether the normalized series form an algebraic structure under multiplication. They do not, and the failure is exact rather than approximate. This paper isolates the failure, shows that it is a single integer parameter, corrects it canonically, and then determines the resulting group completely: it is torsion free and divisible, hence uniquely divisible, hence — as an abstract group — a $\mathbb{Q}$-vector space.

### 1.2 Summary of results

Throughout, $\mathbb{C}[[q]]$ denotes formal power series, $\mathbb{C}((q))$ formal Laurent series (finitely many negative-exponent terms), and $\operatorname{ord}(f) \in \mathbb{Z} \cup \{\infty\}$ the order of $f$, i.e. the least exponent with nonzero coefficient.

1. **(Normalization characterization, Theorem 2.3)** $f$ is normalized if and only if $f = q^{-1} u$ for a unique $u \in \mathbb{C}[[q]]$ with $u(0) = 1$.
2. **(Pole order and uniqueness of the correction, Theorem 3.1, Theorem 3.3)** A product of $m$ normalized series has order $-m$ with leading coefficient $1$; and $q^{k} f_1 \cdots f_m$ is normalized iff $k = m-1$.
3. **(Corrected product and group law, Theorem 4.2, Theorem 4.4)** With $f \star g := q f g$, the normalized series form a commutative group $\mathcal{N}$ with identity $q^{-1}$, and $f \mapsto q f$ is a group isomorphism $\mathcal{N} \xrightarrow{\ \sim\ } U_1 := 1 + q\mathbb{C}[[q]]$.
4. **(Structure of the unit group, Theorem 5.1)** $\mathbb{C}((q))^{\times} \cong \mathbb{Z} \times \mathbb{C}[[q]]^{\times}$ via $(k, v) \mapsto q^{k} v$, with the $\mathbb{Z}$-coordinate given by $\operatorname{ord}$.
5. **(Torsion freeness, Theorem 6.1)** If $u \in U_1$ and $u^n = 1$ for some $n \ge 1$, then $u = 1$.
6. **(Divisibility, Theorem 6.3)** Every $u \in U_1$ has an $n$-th root in $U_1$, for every $n \ge 1$.
7. **(Unique divisibility, Theorem 6.5, Corollary 6.6)** For every normalized $f$ and $n \ge 1$ there is exactly one normalized $g$ with $q^{n-1} g^n = f$. Each power map $g \mapsto g^{\star n}$ is an automorphism of $\mathcal{N}$.
8. **($\mathbb{Q}$-vector space structure, Theorem 7.2, Theorem 7.4)** Any uniquely divisible abelian group carries a unique $\mathbb{Q}$-module structure; hence $\mathcal{N}$ admits rational corrected powers $f^{\star r}$, $r \in \mathbb{Q}$, with $f^{\star r}$ the unique normalized $g$ satisfying $g^{\star d} = f^{\star p}$ for $r = p/d$ in lowest terms.
9. **(Newton identities, Theorem 8.1, Theorem 8.2)** Explicit universal formulas for the low-order coefficients of $\star$-inverses and $\star$-square roots.
10. **(Finite determinacy, Theorem 9.1)** The Laurent coefficients of $f_1 \cdots f_m$ in degrees $\le N - m$ depend only on the coefficients of each $f_i$ in degrees $\le N$.
11. **(Moonshine mean, Theorem 10.3)** There is exactly one normalized $G$ with $q^{193} G^{194} = q^{193}\prod_{g} T_g$.

Section 11 reports exact rational computations: the corrected square root of $J$ has integer Laurent coefficients through $q^{10}$; the corrected cube root has denominators $3, 9, 81$ appearing at $q^2, q^5, q^8$; the fifth root has denominators up to $5^6$ within the same range.

---

## 2. Setting and the normalization characterization

### 2.1 Laurent and power series

Let $\mathbb{C}[[q]]$ be the ring of formal power series and $\mathbb{C}((q))$ its field of fractions, the field of formal Laurent series: elements are functions $\mathbb{Z} \to \mathbb{C}$, $k \mapsto f_k$, whose support is bounded below. Write $f = \sum_{k} f_k q^k$ and $[q^k] f := f_k$. Multiplication is the Cauchy product, well defined because supports are bounded below.

The **order** $\operatorname{ord}(f)$ of a nonzero $f$ is $\min \{k : f_k \ne 0\}$, and $\operatorname{ord}(0) = \infty$. It is a discrete valuation:
$$\operatorname{ord}(fg) = \operatorname{ord}(f) + \operatorname{ord}(g), \qquad \operatorname{ord}(f + g) \ge \min(\operatorname{ord} f, \operatorname{ord} g), \tag{2.1}$$
and $\mathbb{C}((q))$ is a field, with $f$ invertible iff $f \neq 0$. The **pole order** of $f$ is $-\operatorname{ord}(f)$ when this is positive.

A power series $u$ is a **$1$-unit** if $u(0) = 1$, i.e. $[q^0]u = 1$. Write
$$U_1 := \{ u \in \mathbb{C}[[q]] : [q^0] u = 1 \} = 1 + q\,\mathbb{C}[[q]].$$

**Lemma 2.1.** $U_1$ is a subgroup of $\mathbb{C}[[q]]^{\times}$. Indeed $[q^0](uv) = [q^0]u \cdot [q^0]v = 1$, and if $u \in U_1$ then the recursion $v_0 = 1$, $v_k = -\sum_{j=1}^{k} u_j v_{k-j}$ defines $v \in U_1$ with $uv = 1$. Moreover $\mathbb{C}[[q]]^{\times} = \{u : u(0) \neq 0\} = \mathbb{C}^{\times} \cdot U_1$. $\square$

### 2.2 Normalized series

**Definition 2.2 (Normalized $q$-series).** $f \in \mathbb{C}((q))$ is **normalized** if
$$[q^{-1}] f = 1 \quad\text{and}\quad [q^{k}] f = 0 \ \text{ for all } k < -1 .$$
Equivalently, $f = q^{-1} + a_0 + a_1 q + \cdots$ for some $a_0, a_1, \ldots \in \mathbb{C}$. Let $\mathcal{N} \subset \mathbb{C}((q))$ denote the set of normalized series. Every normalized $f$ has $\operatorname{ord}(f) = -1$ with leading coefficient $1$.

**Theorem 2.3 (Normalization characterization).** $f \in \mathbb{C}((q))$ is normalized if and only if there exists $u \in U_1$ with $f = q^{-1} u$; and then $u = q f$ is unique.

*Proof sketch.* If $u \in U_1$, then multiplying by $q^{-1}$ shifts every coefficient down by one: $[q^k](q^{-1}u) = [q^{k+1}]u$, which vanishes for $k < -1$ and equals $1$ at $k = -1$. Conversely, if $f$ is normalized, then $u := qf$ has $[q^{k}]u = [q^{k-1}]f = 0$ for $k < 0$, so $u$ is a power series, and $[q^0]u = [q^{-1}]f = 1$. Uniqueness is immediate since $q$ is invertible in $\mathbb{C}((q))$. $\square$

We call $u = q f$ the **normalized part** of $f$, and record the coefficient dictionary
$$[q^{k}] f = [q^{k+1}] (qf) \qquad (k \ge -1). \tag{2.2}$$
Thus $a_j = [q^{j+1}]u$ for $j \geq 0$.

**Definition 2.4 (Moonshine-shaped series).** For a coefficient sequence $c : \mathbb{N} \to \mathbb{C}$ with $c(0) = 0$, the associated *trace series* is
$$T_c(q) := q^{-1} + \sum_{n \ge 1} c(n)\, q^{n},$$
which is normalized by Theorem 2.3. The modular invariant $J$ of (1.1) is the case $c(n) = \dim V^{\natural}_n$, the graded dimensions of the Moonshine module. The Monster has $\nu = 194$ conjugacy classes, so Moonshine produces a family $(T_g)_{g}$ of $194$ normalized series.

---

## 3. The pole-order obstruction

**Theorem 3.1 (Pole order of a finite product).** Let $f_1, \dots, f_m$ be normalized, $m \ge 1$. Then
$$\operatorname{ord}\Big(\prod_{i=1}^{m} f_i\Big) = -m, \qquad [q^{-m}]\prod_{i=1}^{m} f_i = 1 .$$
In particular the product is normalized if and only if $m = 1$.

*Proof sketch.* By (2.1) the order is additive, so $\operatorname{ord}(\prod f_i) = \sum \operatorname{ord}(f_i) = -m$. The leading coefficient of a product is the product of leading coefficients, all equal to $1$. Normalization requires order $-1$, so $m = 1$. $\square$

This is the *pole-order obstruction*: the assignment $f \mapsto \operatorname{ord}(f)$ is a homomorphism onto $\mathbb{Z}$ and detects, exactly, the failure of $\mathcal{N}$ to be closed under multiplication.

**Lemma 3.2 (Shifting).** For $k \in \mathbb{Z}$ and $f \ne 0$, $\operatorname{ord}(q^{k} f) = k + \operatorname{ord}(f)$ and the leading coefficient is unchanged.

**Theorem 3.3 (Uniqueness of the correcting exponent).** Let $f_1, \dots, f_m$ be normalized and $k \in \mathbb{Z}$. Then
$$q^{k} f_1 \cdots f_m \ \text{ is normalized} \iff k = m - 1 .$$

*Proof sketch.* By Theorem 3.1 and Lemma 3.2, $q^k \prod f_i$ has order $k - m$ with leading coefficient $1$. A series is normalized precisely when its order is $-1$ and its leading coefficient is $1$; the leading coefficient is automatic, so the condition is $k - m = -1$. $\square$

The obstruction is therefore *correctable and uniquely so*. The $194$-fold moonshine instance reads: $q^{193}\prod_{g} T_g$ is normalized, and $193$ is the only exponent with this property.

---

## 4. The corrected product and the group of normalized series

**Definition 4.1 (Corrected product).** For $f, g \in \mathbb{C}((q))$ set
$$f \star g := q\, f\, g .$$

**Theorem 4.2 (Closure, commutativity, associativity, identity).**
$\star$ is commutative and associative on $\mathbb{C}((q))$; the series $q^{-1}$ satisfies $q^{-1} \star f = f$ for all $f$; and if $f, g$ are normalized then so is $f \star g$.

*Proof sketch.* Commutativity is clear. For associativity, $(f\star g)\star h = q(q f g)h = q^2 fgh = f \star (g \star h)$ by the same computation on the other side. The identity: $q^{-1}\star f = q\, q^{-1} f = f$. Closure is Theorem 3.3 with $m = 2$, $k = 1$. $\square$

**Definition 4.3.** $\mathcal{N}$ denotes the set of normalized series equipped with $\star$ and with distinguished element $\varepsilon := q^{-1}$.

**Theorem 4.4 (Group identification).** The map
$$\Phi : \mathcal{N} \longrightarrow U_1, \qquad \Phi(f) := q f$$
is a bijection with $\Phi(f \star g) = \Phi(f)\Phi(g)$ and $\Phi(\varepsilon) = 1$. Consequently $(\mathcal{N}, \star, \varepsilon)$ is a commutative group, isomorphic to the multiplicative group $U_1$ of $1$-units of $\mathbb{C}[[q]]$.

*Proof sketch.* Bijectivity and $\Phi(\varepsilon)=1$ are Theorem 2.3. Multiplicativity: $\Phi(f\star g) = q(qfg) = (qf)(qg)$. Transport of structure along a bijection turns the group $U_1$ (Lemma 2.1) into a group on $\mathcal{N}$. $\square$

**Remark 4.5 (What the obstruction *is*).** The correct statement is not that $\mathcal{N}$ fails to be a monoid, but that $\mathcal{N}$ is a **torsor**: it is the coset $q^{-1} U_1$ of the subgroup $U_1 \le \mathbb{C}((q))^{\times}$, and the corrected product is the group law transported from $U_1$ to that coset. All the algebra of $\mathcal{N}$ is the algebra of $U_1$; the factor $q^{-1}$ is a change of base point.

**Proposition 4.6 (Powers and finite products in the group).** For $f_1, \dots, f_m \in \mathcal{N}$,
$$f_1 \star \cdots \star f_m = q^{\,m-1} f_1 \cdots f_m, \qquad\text{in particular}\qquad f^{\star n} = q^{\,n-1} f^{n}. \tag{4.1}$$

*Proof sketch.* Induction on $m$: each application of $\star$ contributes one factor of $q$, and $m$ factors need $m - 1$ applications. Formally, $q^{k-1}f_1\cdots f_k \star f_{k+1} = q\cdot q^{k-1} f_1\cdots f_k \cdot f_{k+1} = q^{k} f_1 \cdots f_{k+1}$. $\square$

Formula (4.1) is the reason all subsequent statements about roots carry the exponent $n-1$.

---

## 5. Structure of the unit group of $\mathbb{C}((q))$

The pole-order obstruction is a shadow of a global splitting.

**Theorem 5.1 (Structure theorem).** The map
$$\Psi : \mathbb{Z} \times \mathbb{C}[[q]]^{\times} \longrightarrow \mathbb{C}((q))^{\times}, \qquad \Psi(k, v) = q^{k} v$$
is a group isomorphism (with $\mathbb{Z}$ written multiplicatively). Moreover $\operatorname{ord}(\Psi(k,v)) = k$, i.e. the projection to the $\mathbb{Z}$-coordinate is the order valuation.

*Proof sketch.* $\Psi$ is a homomorphism because $q^{k}v \cdot q^{l}w = q^{k+l}vw$. *Injectivity*: if $q^k v = 1$ then taking orders gives $k + \operatorname{ord}(v) = 0$; but $v$ is a unit of $\mathbb{C}[[q]]$, so $v(0) \neq 0$ and $\operatorname{ord}(v) = 0$, whence $k = 0$ and then $v = 1$. *Surjectivity*: given $f \ne 0$, put $k := \operatorname{ord}(f)$; then $q^{-k} f$ is a power series with nonzero constant term, hence a unit of $\mathbb{C}[[q]]$, and $f = \Psi(k, q^{-k}f)$. The last claim follows from $\operatorname{ord}(v) = 0$. $\square$

**Corollary 5.2.** The order map $\operatorname{ord} : \mathbb{C}((q))^{\times} \to \mathbb{Z}$ is a split surjective homomorphism with kernel $\mathbb{C}[[q]]^{\times}$, and $\mathbb{C}[[q]]^{\times} \cong \mathbb{C}^{\times} \times U_1$ via $v \mapsto (v(0),\ v/v(0))$.

Hence
$$\mathbb{C}((q))^{\times} \;\cong\; \mathbb{Z} \times \mathbb{C}^{\times} \times U_1,$$
a decomposition into a valuation part, a scaling part, and the "unipotent" part $U_1$ where all the interesting arithmetic of $q$-series lives. Normalization pins the first two coordinates to $(-1, 1)$; the corrected product is exactly the operation that respects that pinning.

---

## 6. Torsion freeness, divisibility, and unique roots

### 6.1 No torsion

**Theorem 6.1 (Torsion freeness of $U_1$).** Let $u \in U_1$ and $n \ge 1$ with $u^{n} = 1$. Then $u = 1$.

*Proof.* In $\mathbb{C}[[q]]$ we have the geometric-sum identity
$$\Big(\sum_{i=0}^{n-1} u^{i}\Big)(u - 1) = u^{n} - 1 = 0 .$$
$\mathbb{C}[[q]]$ is an integral domain, so one factor vanishes. The constant term of $\sum_{i=0}^{n-1} u^{i}$ is $\sum_{i=0}^{n-1} ([q^0]u)^{i} = n \neq 0$ in $\mathbb{C}$, so that factor is nonzero. Hence $u - 1 = 0$. $\square$

Note the two hypotheses actually used: the coefficient ring is a domain, and $n$ is invertible (indeed nonzero) in it. Both hold in characteristic $0$; the statement genuinely fails in characteristic $p$, where $(1 + q)^{p} = 1 + q^{p}$ produces torsion after a suitable substitution.

**Corollary 6.2.** $\mathcal{N}$ is torsion free: $f^{\star n} = \varepsilon$ with $n \ge 1$ implies $f = \varepsilon$. Equivalently, $q^{n-1} f^{n} = q^{-1}$ forces $f = q^{-1}$.

### 6.2 Divisibility via the binomial series

For $r \in \mathbb{Q}$ let
$$B_r(X) := (1+X)^{r} := \sum_{k \ge 0} \binom{r}{k} X^{k} \in \mathbb{Q}[[X]] \subseteq \mathbb{C}[[X]], \qquad \binom{r}{k} = \frac{r(r-1)\cdots(r-k+1)}{k!}.$$

**Lemma 6.2a (Exponent law).** $B_r B_s = B_{r+s}$ for all $r, s \in \mathbb{Q}$; in particular $B_r^{\,m} = B_{mr}$ for $m \in \mathbb{N}$, and $B_1 = 1 + X$, $B_0 = 1$.

*Proof sketch.* The Vandermonde–Chu convolution $\sum_{i+j=k}\binom{r}{i}\binom{s}{j} = \binom{r+s}{k}$ is a polynomial identity in $r, s$, valid for all rationals since it holds for all nonnegative integers and both sides are polynomials of bounded degree. The power statement follows by induction. $\square$

**Lemma 6.2b (Substitution).** If $h \in \mathbb{C}[[q]]$ has $h(0) = 0$, then for any $F \in \mathbb{C}[[X]]$ the substitution $F(h) := \sum_k F_k h^{k}$ is a well-defined power series (each coefficient is a finite sum because $\operatorname{ord}(h^k) \ge k$), $F \mapsto F(h)$ is a ring homomorphism, and $[q^0]F(h) = F_0$. In particular substitution maps $1$-units to $1$-units.

*Proof sketch.* Coefficientwise finiteness is immediate from $\operatorname{ord}(h^{k}) \ge k$; the homomorphism property is the standard universal property of formal substitution at a topologically nilpotent element. For the constant term, only $k=0$ contributes. $\square$

**Theorem 6.3 (Divisibility of $U_1$).** For every $u \in U_1$ and every $n \ge 1$ there exists $v \in U_1$ with $v^{n} = u$. Explicitly,
$$v = B_{1/n}(u - 1) = \sum_{k \ge 0} \binom{1/n}{k} (u-1)^{k}.$$

*Proof.* Put $h := u - 1$, which has $h(0) = 0$, so substitution at $h$ is a well-defined ring homomorphism by Lemma 6.2b, and $v := B_{1/n}(h)$ is a $1$-unit since $B_{1/n}$ has constant term $1$. Applying the homomorphism to the identity $B_{1/n}^{\,n} = B_{n \cdot (1/n)} = B_1 = 1 + X$ of Lemma 6.2a gives
$$v^{n} = B_{1/n}(h)^{n} = (1 + X)\big|_{X = h} = 1 + h = u. \qquad \square$$

The hypothesis $\operatorname{char} = 0$ enters through $1/n \in \mathbb{Q}$; the binomial coefficients $\binom{1/n}{k}$ have denominators divisible by arbitrarily large powers of the primes dividing $n$, which is the source of the integrality questions in §11.

### 6.3 Unique roots

**Theorem 6.4 (Unique divisibility of $U_1$).** For every $u \in U_1$ and $n \ge 1$ there is a **unique** $v \in U_1$ with $v^{n} = u$.

*Proof.* Existence is Theorem 6.3. If $v_1^{n} = v_2^{n} = u$ with $v_1, v_2 \in U_1$, then $t := v_1 v_2^{-1} \in U_1$ satisfies $t^{n} = v_1^n (v_2^n)^{-1} = 1$, so $t = 1$ by Theorem 6.1. $\square$

**Theorem 6.5 (Unique corrected roots).** Let $f$ be normalized and $n \ge 1$. Then there is exactly one normalized $g$ with $g^{\star n} = f$; equivalently, exactly one normalized $g$ with
$$q^{\,n-1}\, g(q)^{n} = f(q).$$

*Proof.* Transport Theorem 6.4 along the isomorphism $\Phi$ of Theorem 4.4, and rewrite $g^{\star n}$ using Proposition 4.6. $\square$

**Corollary 6.6 (Power automorphisms).** For every $n \ge 1$ the map $\pi_n : \mathcal{N} \to \mathcal{N}$, $\pi_n(g) = g^{\star n}$, is a group automorphism: it is a homomorphism because $\mathcal{N}$ is abelian, injective by torsion freeness (Corollary 6.2 applied to $g_1 \star g_2^{\star(-1)}$) and surjective by Theorem 6.5. Moreover $\pi_n$ is rootable: $\mathcal{N}$ is a divisible abelian group in the sense that $\pi_n$ is onto for all $n \geq 1$.

---

## 7. The $\mathbb{Q}$-vector space structure

Unique divisibility is exactly the condition that makes rational exponents meaningful. We record the general principle and its specialization.

**Definition 7.1.** An abelian group $(M, +)$ is *uniquely divisible* if for every $n \ge 1$ the multiplication map $x \mapsto n x$ is a bijection $M \to M$. Write $x/n$ for the unique preimage.

**Theorem 7.2 (Uniquely divisible $\Rightarrow$ $\mathbb{Q}$-vector space).** Let $M$ be a uniquely divisible abelian group. Then
$$r \cdot x := p\,(x / d), \qquad r = \tfrac{p}{d} \in \mathbb{Q},\ d \ge 1,$$
is well defined and makes $M$ a $\mathbb{Q}$-vector space; this is the unique $\mathbb{Q}$-module structure compatible with the given addition.

*Proof sketch.* Well-definedness: if $p/d = p'/d'$ then $d d'$-divisibility and the injectivity of multiplication by $dd'$ identify $p(x/d)$ and $p'(x/d')$, because $dd'\,\big(p(x/d)\big) = pd'\,x = p'd\,x = dd'\,\big(p'(x/d')\big)$. Additivity in $x$ follows from the fact that $x \mapsto x/d$ is a homomorphism (being the inverse of the homomorphism $x \mapsto dx$). Additivity in $r$: to compare $(r+s)\cdot x$ with $r\cdot x + s\cdot x$, clear denominators by applying the injective map $y \mapsto (d_r d_s) y$ and use ordinary integer arithmetic. Associativity $(rs)\cdot x = r \cdot (s \cdot x)$ and $1 \cdot x = x$ are proved the same way. Uniqueness: any $\mathbb{Q}$-structure must satisfy $d\,(r\cdot x) = (dr)\cdot x$, which pins $r \cdot x$ by injectivity. $\square$

**Corollary 7.3.** $\mathcal{N}$, written additively (i.e. its additive avatar under $\star$), is a $\mathbb{Q}$-vector space. Equivalently, $U_1$ is a $\mathbb{Q}$-vector space in multiplicative notation.

**Definition/Theorem 7.4 (Rational corrected powers).** For $f \in \mathcal{N}$ and $r \in \mathbb{Q}$ define $f^{\star r}$ by the $\mathbb{Q}$-action of Theorem 7.2. Then
$$f^{\star (r+s)} = f^{\star r} \star f^{\star s}, \qquad f^{\star (rs)} = \big(f^{\star s}\big)^{\star r}, \qquad f^{\star 1} = f, \qquad f^{\star 0} = \varepsilon,$$
and $f^{\star n}$ agrees with the $n$-fold corrected power for $n \in \mathbb{N}$. Moreover, if $r = p/d$ in lowest terms with $d \ge 1$, then $f^{\star r}$ is the **unique** normalized $g$ with
$$g^{\star d} = f^{\star p} .$$

*Proof sketch.* The exponent laws are the module axioms transported through the isomorphism $\mathcal{N} \cong U_1$. The characterization: $d \cdot (r \cdot x) = p \cdot x$ in additive notation is the defining property of the rational action, and uniqueness follows because $g \mapsto g^{\star d}$ is injective (Corollary 6.6). Agreement with integer powers is induction using $f^{\star(k+1)} = f^{\star k}\star f^{\star 1}$. $\square$

Concretely, $f^{\star r}$ has the closed form $q^{-1}\,B_r(qf - 1)$: substitute $qf - 1$ into the binomial series with exponent $r$.

---

## 8. Newton identities: explicit coefficients of inverses and roots

Uniqueness makes the coefficients of $\star$-roots universal polynomials in the coefficients of the argument. We record the first few, which are the ones used in computation.

Throughout, $f = q^{-1} + a_0 + a_1 q + a_2 q^{2} + \cdots$ is normalized with normalized part $u = qf = 1 + a_0 q + a_1 q^{2} + a_2 q^{3} + \cdots$.

**Theorem 8.1 (Corrected inverse).** Let $g$ be normalized with $g \star f = q^{-1}$, and write $g = q^{-1} + b_0 + b_1 q + \cdots$. Then
$$b_0 = -a_0, \qquad b_1 = a_0^{2} - a_1 .$$

*Proof sketch.* $g \star f = q^{-1}$ translates, via $\Phi$, into $(qg)(qf) = 1$. Comparing the coefficients of $q^{1}$ and $q^{2}$ in the Cauchy product of $1 + b_0 q + b_1 q^{2}+\cdots$ and $1 + a_0 q + a_1 q^{2} + \cdots$ gives
$$b_0 + a_0 = 0, \qquad b_1 + b_0 a_0 + a_1 = 0,$$
and solving in order yields the claim. $\square$

**Theorem 8.2 (Corrected square root).** Let $g = q^{-1} + b_0 + b_1 q + b_2 q^{2} + \cdots$ be normalized with $g \star g = f$, i.e. $q g^{2} = f$. Then
$$b_0 = \frac{a_0}{2}, \qquad b_1 = \frac{a_1}{2} - \frac{a_0^{2}}{8}, \qquad b_2 = \frac{a_2}{2} - \frac{a_0 a_1}{4} + \frac{a_0^{3}}{16}.$$

*Proof sketch.* Again pass to $1$-units: $(qg)^2 = qf$. Comparing coefficients of $q^1, q^2, q^3$ in $(1 + b_0 q + b_1 q^2 + b_2 q^3 + \cdots)^2 = 1 + a_0 q + a_1 q^2 + a_2 q^3 + \cdots$ gives
$$2b_0 = a_0, \qquad 2b_1 + b_0^{2} = a_1, \qquad 2b_2 + 2 b_0 b_1 = a_2,$$
and back-substitution produces the stated formulas. $\square$

**Corollary 8.3 (Moonshine normalization).** If $a_0 = 0$ — the convention for all McKay–Thompson series — then the corrected square root also has vanishing constant term, and
$$b_0 = 0, \qquad b_1 = \frac{a_1}{2}, \qquad b_2 = \frac{a_2}{2}.$$

**Example 8.4 ($J$).** For $J = q^{-1} + 196884\,q + 21493760\,q^{2} + \cdots$ the corrected square root begins
$$\sqrt{J}^{\,\star} = q^{-1} + 0 + 98442\,q + 10746880\,q^{2} + \cdots,$$
and the corrected inverse begins
$$J^{\star(-1)} = q^{-1} + 0 - 196884\,q + \cdots .$$
Both are the unique normalized series with the stated defining property (Theorem 6.5).

---

## 9. Finite determinacy

For computation one needs to know that truncated inputs determine truncated outputs. Because pole orders add, the truncation window shifts.

**Theorem 9.1 (Finite determinacy for products).** Let $f_1, \dots, f_m$ and $g_1, \dots, g_m$ be normalized, $N \in \mathbb{N}$, and suppose
$$[q^{k}] f_i = [q^{k}] g_i \qquad \text{for all } i \text{ and all } -1 \le k \le N .$$
Then
$$[q^{k}] \prod_i f_i = [q^{k}] \prod_i g_i \qquad \text{for all } k \le N - m + 1 .$$

*Proof sketch.* Pass to normalized parts $u_i = qf_i$, $v_i = qg_i$, which agree in degrees $\le N+1$. For power series, the coefficient of $q^{d}$ in a product depends only on the coefficients of the factors in degrees $\le d$; formally, if $a, a'$ and $b, b'$ agree through degree $d$ then so do $ab$ and $a'b'$, by inspecting the Cauchy sum $\sum_{i+j=d}a_i b_j$. Induction over the $m$ factors gives agreement of $\prod u_i$ and $\prod v_i$ through degree $N+1$. Finally $\prod f_i = q^{-m}\prod u_i$, which shifts degrees down by $m$. $\square$

The theorem says exactly how much input precision a target output precision costs: to know a $194$-fold moonshine product through $q^{N}$, one needs each factor through $q^{N + 193}$.

---

## 10. Monstrous Moonshine applications

Let $T_1, \dots, T_{194}$ be normalized series of moonshine shape (Definition 2.4), one per conjugacy class of the Monster.

**Theorem 10.1 (Corrected moonshine product).** The series $q^{193}\prod_{i=1}^{194} T_i$ is normalized, and for $k \in \mathbb{Z}$, $q^{k}\prod_i T_i$ is normalized if and only if $k = 193$.

*Proof.* Theorem 3.1 and Theorem 3.3 with $m = 194$. $\square$

**Theorem 10.2 (Unique corrected square root of $J$).** There is exactly one normalized $g$ with $q\,g(q)^{2} = J(q)$, and its expansion begins $q^{-1} + 98442\,q + 10746880\,q^{2} + \cdots$.

*Proof.* Theorem 6.5 with $n = 2$ and $f = J$; the coefficients are Theorem 8.2 with $a_0 = 0$. $\square$

**Theorem 10.3 (The geometric mean of the Monster's trace functions).** There is exactly one normalized $G$ with
$$q^{193}\, G(q)^{194} \;=\; q^{193}\prod_{i=1}^{194} T_i(q),$$
namely $G = \Big(\bigstar_{i} T_i\Big)^{\star (1/194)}$.

*Proof.* The right-hand side is normalized by Theorem 10.1; apply Theorem 6.5 with $n = 194$. $\square$

In the uncorrected setting, "the $194$-th root of a product of moonshine series" is ill-posed twice over: the product is not normalized, and roots would be ambiguous up to $194$-th roots of unity. Correcting the product removes the first problem, and torsion freeness removes the second. $G$ is a canonical object attached to the Monster's character table via Moonshine, with no choices made.

**Remark 10.4 (Rational moonshine means).** More generally, for any rational weights $r_i \in \mathbb{Q}$ the weighted mean $\bigstar_i\, T_i^{\star r_i}$ exists and is unique (Theorem 7.4). Replication-type identities, which relate $T_g(q)$ to $T_{g^{n}}$ and to Hecke-type operators, become statements about $\mathbb{Q}$-linear relations in the vector space $\mathcal{N}$.

---

## 11. Computational evidence: integrality of corrected roots of $J$

All computations below are exact over $\mathbb{Q}$, using the coefficients $c(1), \dots, c(10)$ of $J$:
$$196884,\ 21493760,\ 864299970,\ 20245856256,\ 333202640600,$$
$$4252023300096,\ 44656994071935,\ 401490886656000,\ 3176440229784420,\ 22567393309593600.$$

**Corrected square root.** The unique normalized $g$ with $qg^{2} = J$ has Laurent coefficients
$$\begin{aligned} &[q^{0}] = 0, \quad [q^{1}] = 98442, \quad [q^{2}] = 10746880, \quad [q^{3}] = -4413263697,\\ &[q^{4}] = -1047821432832, \quad [q^{5}] = 376869391313174, \quad [q^{6}] = 150580578862513152,\\ &[q^{7}] = -35577391320709928685, \quad [q^{8}] = -23497935558209789278208, \ \ldots\end{aligned}$$
Every one of these is an **integer**, and the pattern persists through $q^{10}$, the limit of the input data. This is unexpected from the formulas: the coefficient $[q^{k}]$ of a square root is a polynomial in $c(1), \ldots, c(k+1)$ with denominators that are powers of $2$ growing like $2^{2k}$ (cf. the $1/8$ and $1/16$ in Theorem 8.2). Integrality therefore encodes a family of $2$-adic congruences among the $c(n)$.

**Corrected cube and fifth roots.** By contrast, the unique normalized $g_3$ with $q^{2}g_3^{3} = J$ has denominators
$$1,\ 1,\ 3,\ 1,\ 1,\ 9,\ 1,\ 1,\ 81,\ 1,\ 9 \qquad \text{at } q^{0},\dots,q^{10},$$
and the fifth root has denominators $1, 5, 1, 25, 5, 125, 5, 625, 125, 5^{6}, 625$. The integrality of the corrected square root is thus a *prime-specific* phenomenon, not a general feature of corrected roots.

**Interpretation.** In the language of §6, taking the corrected square root is the operator
$$u \longmapsto B_{1/2}(u - 1)$$
on $1$-units. Over $\mathbb{Z}_2$, the binomial series $B_{1/2}$ has $2$-adically unbounded denominators; that its value at $u - 1 = qJ - 1$ nevertheless lies in $\mathbb{Z}_2[[q]]$ is equivalent to congruences among the graded dimensions of the Moonshine module. Known $2$-adic congruences for $c(n)$ and replication formulas are natural candidates for the mechanism.

**Conjecture 11.1 (Dyadic integrality).** The unique normalized $g$ with $qg^{2} = J$ has integer Laurent coefficients, i.e. $qg \in \mathbb{Z}[[q]]$.

---

## 12. Algorithms

We summarize the algorithms behind §11; all operate on truncated series over $\mathbb{Q}$ to precision $P$ (i.e. modulo $q^{P}$ after passing to $1$-units), with coefficient arithmetic exact.

**A. Corrected product.** Given normalized $f, g$ by their $1$-units $u, v$, return the $1$-unit $uv$: a Cauchy product, $O(P^{2})$ coefficient operations.

**B. Corrected inverse.** Given $u \in U_1$, solve $uv = 1$ by the recursion $v_0 = 1$, $v_k = -\sum_{j=1}^{k} u_j v_{k-j}$: $O(P^{2})$, no divisions (the divisions by $u_0 = 1$ are trivial), so integrality is preserved when $u \in \mathbb{Z}[[q]]$.

**C. Corrected $n$-th root (binomial substitution).** Given $u \in U_1$ and $n \ge 1$, compute $h := u - 1$, then evaluate $B_{1/n}(h)$ by Horner's rule with $P$ truncated multiplications: $O(P^{3})$ naively, $O(P^{2}\log P)$ with repeated squaring on the outer polynomial, and $O(P^2)$ if one instead uses the Newton recursion below. Correctness is Theorem 6.3.

**D. Corrected $n$-th root (Newton recursion).** Alternatively, solve $v^{n} = u$ coefficientwise: $v_0 = 1$ and, for $k \ge 1$,
$$v_k = \frac{1}{n}\Big( u_k - \sum_{\substack{k_1 + \cdots + k_n = k \\ k_i < k}} v_{k_1}\cdots v_{k_n} \Big),$$
implemented efficiently by maintaining $v^{n-1}$; cost $O(P^{2})$ per multiplication round. The explicit division by $n$ at every step is exactly what makes the integrality of §11 surprising.

**E. Rational corrected power.** For $r = p/d$, either substitute into $B_r$ directly (Theorem 7.4's closed form) or compute the $d$-th root and then the $p$-th power; the two agree by uniqueness (Theorem 7.4), which doubles as a correctness check.

**F. Pole-order bookkeeping.** For a family of $m$ normalized series, the plain product has pole order $m$ and the unique correcting exponent is $m-1$ (Theorem 3.3). Precision must be inflated accordingly: computing the corrected product of $m$ factors through $q^{N}$ requires each factor through $q^{N+m-1}$ (Theorem 9.1).

---

## 13. Discussion

### 13.1 What was actually obstructed

The phrase "normalization obstruction" suggests something is prevented. The results above show that nothing is: the obstruction is a valuation, the valuation splits (Theorem 5.1), and the splitting supplies the canonical correction. What the failure of closure really encodes is that $\mathcal{N}$ is a *torsor* rather than a subgroup — the difference between an affine space and a vector space. Choosing the base point $q^{-1}$ turns the torsor into the group $U_1$; the corrected product $\star$ is the induced law.

This is a recurring pattern. Objects normalized by a leading coefficient (monic polynomials, principal parts of Laurent expansions, probability densities, unit-determinant matrices) frequently form torsors rather than subgroups; the "wrong" multiplication has to be twisted by exactly the amount the normalization prescribes, and the twist is unique whenever the normalization condition is cut out by a homomorphism to $\mathbb{Z}$.

### 13.2 What could not be weakened

Two apparently reasonable strengthenings are false. First, "normalized series are closed under multiplication" cannot be repaired by weakening the conclusion — the pole order of a product of $m$ factors is exactly $m$, on the nose, so no inequality-type statement survives. The fix must change the operation. Second, torsion freeness genuinely uses characteristic $0$: in characteristic $p$ the $1$-units contain elements of order $p$, so roots would exist but not be unique, and the group would not be a $\mathbb{Q}$-vector space.

### 13.3 Relation to known moonshine structure

The corrected group of normalized series is a natural home for identities that multiply McKay–Thompson series. Replication formulas, the Koike–Norton–Zagier product identity for $j(p) - j(q)$, and Hecke-type operators all produce expressions built from products of moonshine series; each such expression must be corrected by a power of $q$, and the correcting exponent is dictated by Theorem 3.3. In the corrected group the exponent bookkeeping vanishes into the group law, and the operations become $\mathbb{Q}$-linear maps on a $\mathbb{Q}$-vector space.

### 13.4 Limits of the present work

We work with formal series only. Convergence, modularity, and the Hauptmodul property play no role in the proofs; correspondingly, none of the results asserts that a corrected root of a modular function is modular. Indeed the corrected square root of $J$ is presumably not the $q$-expansion of a Hauptmodul for any group — the interest of Conjecture 11.1 is precisely that arithmetic (integrality) survives where modularity does not obviously do so.

---

## 14. Future directions

**Direction 1 — Dyadic integrality of corrected roots of Hauptmoduln.** Prove Conjecture 11.1. The framework identifies the corrected square root as $B_{1/2}(qJ - 1)$, so the question becomes whether $B_{1/2}$ maps $qJ - 1$ into $\mathbb{Z}_2[[q]]$. Since $B_{1/2}(X) \in \mathbb{Z}_2[[X]]$ fails (its coefficients have unbounded $2$-denominators), integrality must come from congruences satisfied by $c(n)$ — replication formulas in $2$-adic disguise. The prime-specificity documented in §11 (cube root denominators $3, 9, 81$; fifth root denominators up to $5^{6}$) shows the phenomenon is arithmetic, not formal. A natural first target: prove $[q^{k}]g \in \mathbb{Z}_2$ for all $k$ by exhibiting the recursion for $g$ as an integral $2$-adic Frobenius-type recursion.

**Direction 2 — Valuation-split rigidity of moonshine products.** The splitting $\mathbb{C}((q))^{\times} \cong \mathbb{Z} \times \mathbb{C}[[q]]^{\times}$ is canonical. Conjecture: it is *rigid* on the moonshine locus, in the sense that any multiplicative map from the $194$ McKay–Thompson series into $\mathbb{C}((q))^{\times}$ commuting with Hecke-type operators $T_n$ factors as an integer-valued valuation coordinate together with a $1$-unit having integral coefficients. This would explain why the correcting exponents appearing in moonshine identities are always the "expected" ones.

**Direction 3 — The geometric mean $G$ of the Monster.** Determine whether the unique $G$ with $q^{193}G^{194} = q^{193}\prod_g T_g$ has arithmetic content: are its coefficients rational? algebraic integers? Is $G$ invariant under the Galois action permuting the McKay–Thompson series of conjugate classes? Since Galois conjugation permutes the family, $G$ should be Galois-stable, and hence have rational coefficients — proving this cleanly would be a first structural theorem about corrected means.

**Direction 4 — Weighted means and $\mathbb{Q}$-linear moonshine.** Exploit the $\mathbb{Q}$-vector space structure directly: view the map $g \mapsto T_g$ as a vector in $\mathcal{N}^{194}$ and study the $\mathbb{Q}$-subspace it spans. Class-function-valued corrected products, $\bigstar_g T_g^{\star \chi(g)}$ for a rational character $\chi$, are then well defined, and their coefficients are natural candidates for new moonshine-type numerology.

**Direction 5 — Beyond characteristic zero and beyond $\mathbb{C}$.** Over a field of characteristic $p$ the corrected group is divisible but not torsion free ($1$-units contain $p$-torsion); over $\mathbb{Z}$ it is neither. Classifying the corrected group of normalized $q$-series over an arbitrary base ring — in particular over $\mathbb{Z}$ and $\mathbb{Z}_p$, where the integrality questions of §11 live — is a well-posed and apparently tractable problem, and would situate Conjecture 11.1 inside a structural statement rather than a numerical one.

---

## 15. Conclusion

The normalization $f = q^{-1} + O(1)$ that underlies all of Monstrous Moonshine obstructs multiplication in a completely explicit way: pole orders add, so a product of $m$ normalized series has a pole of order exactly $m$, and the unique repair is the factor $q^{m-1}$. Elevating that repair to a definition — the corrected product $f \star g = q f g$ — turns the normalized series into a commutative group, canonically the group of $1$-units of $\mathbb{C}[[q]]$. That group is torsion free, by a geometric-sum argument, and divisible, by substitution into the binomial series; hence uniquely divisible, hence a $\mathbb{Q}$-vector space. Roots of every order exist and are unique, rational corrected powers are well defined and obey the usual exponent laws, and the $194$ McKay–Thompson series acquire a canonical geometric mean. The obstruction, examined closely, was a coordinate all along; and it leaves behind one sharp, numerically supported question: why the corrected square root of the modular invariant should have integer coefficients.
