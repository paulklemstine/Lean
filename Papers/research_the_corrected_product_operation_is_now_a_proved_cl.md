# The Corrected-Product Torsor of Normalized $q$-Series

**Author:** Aristotle
**Date:** 2026-08-21

## Abstract

A Laurent series $f \in \mathbb{C}((q))$ is *normalized* if it has the shape $f = q^{-1} + a_0 + a_1 q + a_2 q^2 + \cdots$, i.e. its polar part is exactly the monomial $q^{-1}$ with coefficient $1$. Normalized series are the standard shape of Hauptmoduln and of McKay–Thompson series, but they are not closed under multiplication: a product of $m$ normalized series has a pole of order $m$. We take this *pole-order obstruction* seriously and study its unique monomial repair, the **corrected product** $f \star g = q f g$.

We prove that $\star$ is closed on normalized series, that the correction exponent is unique ($q^{m} f g$ is normalized if and only if $m = 1$), and that $\star$ makes the normalized series a commutative group with identity $q^{-1}$ and inversion $f \mapsto q^{-2} f^{-1}$, isomorphic to the group $1 + q\mathbb{C}[[q]]$ of one-units of the formal power series ring via $f \mapsto qf$. The set of normalized series is thus a torsor-like object which becomes a group upon nominating the base point $q^{-1}$.

We then determine the invariant theory of the $\star$-orbits. There is a strictly descending, separated filtration by *depth* subgroups $\mathrm{Deep}_k$, whose graded pieces are all isomorphic to $(\mathbb{C},+)$, and whose associated level invariants $c_k$ form a bijection (not a homomorphism) from normalized series to $\mathbb{C}^{\mathbb{N}}$. The group is torsion-free and uniquely divisible — a $\mathbb{Q}$-vector space — with explicit complex one-parameter subgroups $r \mapsto f^{\star r}$ obtained by substituting $qf-1$ into the binomial series $(1+X)^r$, faithful for every $f \ne q^{-1}$.

The central computational result is an **exact finite binomial expansion**: for a $k$-deep series, $c_m(f^{\star n}) = \sum_{d \le \lfloor m/k\rfloor} \binom{n}{d} \, \omega_d$ with weights $\omega_d$ independent of $n$. Consequently every orbit invariant is a polynomial in the iteration count of degree at most $\lfloor m/k \rfloor$; at level $jk$ the leading term is exactly $\binom{n}{j} c_k(f)^j$; the depth is constant along non-trivial orbits and is the first orbit invariant; and the whole level-$m$ invariant is determined by the $\lfloor m/k \rfloor + 1$ iterates $n = 0,1,\dots,\lfloor m/k\rfloor$. We illustrate with the modular function $J = q^{-1} + 196884 q + 21493760 q^2 + 864299970 q^3 + \cdots$: the $q$-coefficient of $J^{\star n}$ is $196884\,n$ and the $q^3$-coefficient is $864299970\,n + \binom{n}{2}\,196884^2$.

**Keywords:** normalized $q$-series, pole-order obstruction, corrected product, one-units, formal power series, coefficient filtration, divisible abelian group, binomial series, orbit invariants, moonshine coefficients.

---

## 1. Introduction

### 1.1 Normalized $q$-series and their obstruction

Throughout, $\mathbb{C}((q))$ denotes the field of formal Laurent series in $q$ over $\mathbb{C}$: sums $\sum_{n \in \mathbb{Z}} f_n q^n$ whose support is bounded below. We write $[q^n]f = f_n$.

> **Definition 1.1 (Normalized series).** A Laurent series $f \in \mathbb{C}((q))$ is **normalized** if
> $$[q^{-1}]f = 1 \quad\text{and}\quad [q^{n}]f = 0 \text{ for all } n < -1 .$$
> Equivalently, $f = q^{-1} + a_0 + a_1 q + a_2 q^2 + \cdots$ for some $a_0, a_1, \dots \in \mathbb{C}$. We write $\mathrm{Norm}$ for the set of normalized series.

This is the standard shape of a Hauptmodul: the $q$-expansion of a generator of the function field of a genus-zero modular curve, normalized so that the polar part is exactly $q^{-1}$ and (in the classical convention) so that the constant term is prescribed. The McKay–Thompson series of Monstrous Moonshine are normalized in this sense, with vanishing constant term.

Normalized series are visibly closed under addition of a constant, but not under multiplication. Every normalized series has order $-1$ (order = the least $n$ with $[q^n]f \ne 0$), and orders add under multiplication in an integral domain, so the product of $m$ normalized series has order $-m$.

> **Proposition 1.2 (Pole-order obstruction, binary form).** If $f$ and $g$ are normalized then $fg$ is **never** normalized.
>
> *Proof.* $fg$ has order $(-1)+(-1) = -2 \ne -1$, whereas every normalized series has order $-1$. $\square$

The obstruction is exactly one unit of pole order per extra factor, which suggests correcting by a power of $q$. The following says the correction is unique, so the operation studied in this paper is forced rather than chosen.

> **Theorem 1.3 (Uniqueness of the correction).** Let $f, g$ be normalized and $m \in \mathbb{N}$. Then $q^{m} f g$ is normalized if and only if $m = 1$.
>
> *Proof.* Orders add: $q^m fg$ has order $m - 2$, and normalization forces order $-1$, i.e. $m = 1$. Conversely $m=1$ works, by Theorem 2.4 below. $\square$

> **Definition 1.4 (Corrected product).** For $f,g \in \mathbb{C}((q))$ set
> $$f \star g \;=\; q\,f\,g .$$

### 1.2 Results

The paper is organized around three questions.

1. *Is $\star$ an algebraic structure?* Yes: $(\mathrm{Norm}, \star)$ is a commutative group with identity $q^{-1}$, canonically isomorphic to the one-unit group of $\mathbb{C}[[q]]$ (Section 2).
2. *What separates the $\star$-orbits?* An infinite tower of invariants with all graded pieces $(\mathbb{C},+)$, whose first non-vanishing level — the *depth* — is an orbit invariant, and whose level-$k$ value grows linearly along the orbit (Sections 3 and 4).
3. *How do the higher invariants grow?* By an exact finite binomial law, hence polynomially with degree governed by depth, and determined by finitely many iterates (Section 5).

Section 6 applies the theory to moonshine coefficients, Section 7 records the algorithms, and Sections 8–9 discuss and extend.

---

## 2. The corrected product is a commutative group law

### 2.1 One-unit coordinates

The entire structure theory rests on a change of coordinates.

> **Definition 2.1 (One-units).** A power series $u \in \mathbb{C}[[q]]$ is a **one-unit** if $u(0) = 1$, i.e. $u = 1 + u_1 q + u_2 q^2 + \cdots$. Write $\mathcal{U} = 1 + q\,\mathbb{C}[[q]]$ for the set of one-units.

$\mathcal{U}$ is a commutative group under ordinary multiplication of power series: it is closed under products (the constant term of a product is the product of the constant terms), contains $1$, and every one-unit is invertible in $\mathbb{C}[[q]]$ with inverse again a one-unit.

> **Theorem 2.2 (Coordinates for normalized series).** A Laurent series $f$ is normalized if and only if $f = q^{-1}u$ for a (necessarily unique) one-unit $u$; explicitly $u = qf$.
>
> *Proof sketch.* If $u$ is a one-unit then $[q^n](q^{-1}u) = [q^{n+1}]u$, which vanishes for $n < -1$ and equals $u(0) = 1$ at $n = -1$; hence $q^{-1}u$ is normalized. Conversely, if $f$ is normalized then $qf$ has support in $\mathbb{N}$ — because the support of $f$ is bounded below by $-1$ — so $qf$ is a power series, and its constant term is $[q^{-1}]f = 1$. Uniqueness is immediate since $u \mapsto q^{-1}u$ is injective. $\square$

We call $u = qf$ the **normalized part** of $f$, and we will freely pass between $f$ and $u$. The dictionary between coefficients is
$$[q^{k}] u \;=\; [q^{k-1}] f \qquad (k \ge 0),$$
so the constant term of $u$ is the leading $1$ of $f$, the linear coefficient of $u$ is the constant term $a_0$ of $f$, and so on.

### 2.3 Closure and the group law

> **Lemma 2.3.** $q \cdot q^{-1} = 1$, and consequently $q^{-1}$ is normalized (take $u = 1$ in Theorem 2.2).

> **Theorem 2.4 (Closure of the corrected product).** If $f$ and $g$ are normalized then so is $f \star g = q f g$.
>
> *Proof.* Write $f = q^{-1}u$, $g = q^{-1}v$ with $u,v$ one-units (Theorem 2.2). Then
> $$q\,(q^{-1}u)(q^{-1}v) \;=\; (q\,q^{-1})\,q^{-1}(uv) \;=\; q^{-1}(uv),$$
> and $uv$ is a one-unit, so the result is normalized by Theorem 2.2 again. $\square$

The same computation identifies $\star$ completely: **in one-unit coordinates the corrected product is ordinary multiplication.** The remaining group axioms are then formal.

> **Theorem 2.5 (Closure under corrected inversion).** If $f$ is normalized then so is $q^{-2} f^{-1}$, where $f^{-1}$ is the inverse of $f$ in the field $\mathbb{C}((q))$.
>
> *Proof.* With $f = q^{-1}u$ one checks $f^{-1} = q\,u^{-1}$, since $(q^{-1}u)(q u^{-1}) = (q q^{-1}) (u u^{-1}) = 1$ and $u$ is invertible. Hence $q^{-2}f^{-1} = q^{-1}u^{-1}$, which is normalized because $u^{-1}$ is a one-unit. $\square$

> **Theorem 2.6 (Group structure).** The set $\mathrm{Norm}$ of normalized series, equipped with
> $$f \star g = q f g, \qquad e = q^{-1}, \qquad f^{\star(-1)} = q^{-2}f^{-1},$$
> is a commutative group.
>
> *Proof sketch.* Associativity and commutativity are inherited from $\mathbb{C}((q))$ after clearing the correction factors: $(f\star g)\star h = q^2 fgh = f \star (g \star h)$. For the unit, $q^{-1} \star f = q\,q^{-1} f = f$. For the inverse, $(q^{-2}f^{-1}) \star f = q\,q^{-2}\,f^{-1}f = q^{-1}$. Closure of each operation is Theorems 2.4, 2.5 and Lemma 2.3. $\square$

> **Theorem 2.7 (Structure theorem).** The map $\Phi : \mathrm{Norm} \to \mathcal{U}$, $\Phi(f) = qf$, is an isomorphism of commutative groups $(\mathrm{Norm}, \star) \xrightarrow{\ \sim\ } (\mathcal{U}, \cdot)$, with inverse $u \mapsto q^{-1}u$.
>
> *Proof.* Bijectivity is Theorem 2.2. Multiplicativity is $q(f\star g) = q\,(q f g) = (qf)(qg)$. $\square$

Two remarks. First, the identity element of $(\mathrm{Norm},\star)$ is the base point $q^{-1}$, which is not distinguished by anything intrinsic to the set $\mathrm{Norm}$; the honest statement is that $\mathrm{Norm}$ is a torsor under $\mathcal{U}$, and becomes a group once $q^{-1}$ is nominated as origin. Second, all statements below can be read either downstairs in $\mathrm{Norm}$ or upstairs in $\mathcal{U}$; we will use whichever is more transparent.

### 2.4 Iterates and finite products

> **Proposition 2.8 (Shape of an iterate).** For $f$ normalized and $n \ge 1$,
> $$f^{\star n} \;=\; q^{\,n-1} f^{\,n}.$$
> More generally, for a finite family $f_1, \dots, f_N$ of normalized series, $f_1 \star \cdots \star f_N = q^{\,N-1} f_1 \cdots f_N$.
>
> *Proof.* Induction, using $q(q^{j-1}f^{j})f = q^{j}f^{j+1}$; equivalently, apply $\Phi$ and use $\Phi(f^{\star n}) = (qf)^n$. $\square$

Thus iterating the corrected product applies the pole correction $n-1$ times, in exact agreement with the obstruction. For example, the corrected product of $194$ normalized series — one per conjugacy class of the Monster — is $q^{193}$ times their ordinary product.

---

## 3. The first invariant

> **Definition 3.1.** For $f = q^{-1} + a_0 + a_1 q + \cdots$ normalized, write $a_0(f) = [q^0]f$.

> **Theorem 3.2 (Additivity and linear growth of the first invariant).** For all normalized $f,g$,
> $$a_0(f \star g) = a_0(f) + a_0(g), \qquad a_0(f^{\star n}) = n\,a_0(f) \quad (n \ge 0), \qquad a_0(q^{-1}) = 0.$$
> Hence $a_0 : (\mathrm{Norm},\star) \to (\mathbb{C},+)$ is a group homomorphism, and it is surjective.
>
> *Proof sketch.* In one-unit coordinates $a_0(f) = [q^1](qf)$, and for one-units $u,v$ one has $[q^1](uv) = u(0)[q^1]v + [q^1]u\,v(0) = [q^1]u + [q^1]v$. Surjectivity: $q^{-1}(1 + zq) = q^{-1} + z$ realizes any $z \in \mathbb{C}$. Linear growth is induction on $n$. $\square$

> **Proposition 3.3 (The first invariant is not complete).** The normalized series $f = q^{-1} + q$ satisfies $f \ne q^{-1}$ and $a_0(f) = 0$. Hence $a_0$ is not injective, and its whole orbit $\{f^{\star n}\}$ is invisible to $a_0$.
>
> *Proof.* Its one-unit coordinate is $1 + q^2 \ne 1$, while the linear coefficient of $1 + q^2$ vanishes. $\square$

The repair is to look further along the expansion — systematically.

---

## 4. The depth filtration and the graded invariants

> **Definition 4.1 (Level invariants and depth).** For $f$ normalized with one-unit coordinate $u = qf$, and $k \ge 0$, define
> $$c_k(f) \;=\; [q^{k}]u \;=\; [q^{k-1}]f .$$
> So $c_0(f) = 1$ always, $c_1(f) = a_0(f)$, $c_2(f) = a_1(f)$, and so on. For $k \ge 1$ let
> $$\mathrm{Deep}_k \;=\; \{\, f \in \mathrm{Norm} \;:\; c_i(f) = 0 \text{ for all } 1 \le i < k \,\},$$
> the set of **$k$-deep** series, i.e. those agreeing with the base point $q^{-1}$ through level $k$. The **depth** of $f \ne q^{-1}$ is the largest $k$ with $f \in \mathrm{Deep}_k$; equivalently the least $k \ge 1$ with $c_k(f) \ne 0$.

We say a power series $w$ (or one-unit $u$) has *low vanishing at $k$* if $[q^i]w = 0$ for $0 < i < k$; the one-unit coordinate of a $k$-deep normalized series is exactly a one-unit with low vanishing at $k$.

### 4.1 Coefficient calculus

The following three elementary lemmas drive everything.

> **Lemma 4.2 (Below the threshold).** If $u$ has low vanishing at $k$ then for $m < k$ and any $b \in \mathbb{C}[[q]]$, $[q^m](ub) = u(0)\,[q^m]b$.
>
> *Proof.* In $[q^m](ub) = \sum_{i+j = m} [q^i]u\,[q^j]b$, every term with $0 < i \le m < k$ vanishes. $\square$

> **Lemma 4.3 (Additivity at the threshold).** If $u, v$ both have low vanishing at $k \ge 1$ then
> $$[q^{k}](uv) \;=\; u(0)\,[q^{k}]v \;+\; [q^{k}]u\;v(0).$$
> In particular, if $u,v$ are one-units, $[q^k](uv) = [q^k]u + [q^k]v$; and $uv$ again has low vanishing at $k$.
>
> *Proof.* In $[q^k](uv) = \sum_{i+j=k} [q^i]u\,[q^j]b$, every term with $0 < i < k$ (hence $0 < j < k$) vanishes, leaving the two extreme terms. Low vanishing of $uv$ is the same computation for $m<k$. $\square$

> **Lemma 4.4 (Inversion at the threshold).** If $u$ is a one-unit with low vanishing at $k \ge 1$, then $u^{-1}$ is a one-unit with low vanishing at $k$ and $[q^k](u^{-1}) = -[q^k]u$.
>
> *Proof.* Apply Lemma 4.2 to $u u^{-1} = 1$ to get $[q^m]u^{-1} = 0$ for $0<m<k$, then Lemma 4.3 to the same identity at level $k$. $\square$

### 4.2 The filtration and its graded pieces

> **Theorem 4.5 (The tower).** For each $k \ge 1$, $\mathrm{Deep}_k$ is a subgroup of $(\mathrm{Norm},\star)$, and
> $$\mathrm{Norm} = \mathrm{Deep}_1 \supseteq \mathrm{Deep}_2 \supseteq \mathrm{Deep}_3 \supseteq \cdots$$
> Moreover, on $\mathrm{Deep}_k$ the level-$k$ invariant is a surjective group homomorphism
> $$c_k : (\mathrm{Deep}_k, \star) \twoheadrightarrow (\mathbb{C},+),$$
> whose kernel is exactly $\mathrm{Deep}_{k+1}$.
>
> *Proof sketch.* Subgroup: Lemmas 4.3 and 4.4 in one-unit coordinates. Homomorphism: Lemma 4.3. Surjectivity: $u = 1 + zq^{k}$ is $k$-deep with $c_k = z$. Kernel: by definition, a $k$-deep series is $(k+1)$-deep iff $c_k$ vanishes on it. $\square$

> **Corollary 4.6 (All graded pieces are $(\mathbb{C},+)$).** For every $k \ge 1$,
> $$\mathrm{Deep}_k / \mathrm{Deep}_{k+1} \;\cong\; (\mathbb{C},+),$$
> and hence any two graded pieces are isomorphic. No invariant intrinsic to a single graded piece can distinguish levels; the distinguishing datum is the *position* in the tower.

> **Theorem 4.7 (Strictness and separatedness).** For every $k \ge 1$ the inclusion $\mathrm{Deep}_{k+1} \subsetneq \mathrm{Deep}_k$ is strict, and $\bigcap_{k \ge 1} \mathrm{Deep}_k = \{q^{-1}\}$.
>
> *Proof.* Strictness: the series with one-unit coordinate $1 + q^{k}$ is $k$-deep with $c_k = 1 \ne 0$. Separatedness: if all $c_k(f)$ vanish for $k\ge 1$ then $qf = 1$, i.e. $f = q^{-1}$. $\square$

> **Theorem 4.8 (Completeness and freeness of the invariant system).** The map
> $$C : \mathrm{Norm} \longrightarrow \mathbb{C}^{\mathbb{N}}, \qquad C(f) = \bigl(c_1(f), c_2(f), c_3(f), \dots\bigr)$$
> is a bijection: two normalized series with the same invariants coincide, and every prescribed sequence of complex numbers occurs.
>
> *Proof.* Injectivity: the invariants determine every coefficient of the one-unit $qf$ (its constant term being $1$), so they determine $f$. Surjectivity: given $(z_1,z_2,\dots)$, the series $q^{-1}\bigl(1 + \sum_{k\ge 1} z_k q^{k}\bigr)$ has exactly these invariants. $\square$

> **Remark 4.9 (Why the filtration is necessary).** $C$ is *not* a group isomorphism onto $\mathbb{C}^\mathbb{N}$ with pointwise addition. For instance, if $f$ has one-unit coordinate $1 + q$, then $f\star f$ has coordinate $(1+q)^2 = 1 + 2q + q^2$, so $c_2(f \star f) = 1$ while $c_2(f) + c_2(f) = 0$. Level $k$ becomes additive only after restricting to $\mathrm{Deep}_k$, which is precisely the content of Theorem 4.5.

### 4.3 Rigidity: torsion-freeness, divisibility, one-parameter subgroups

> **Theorem 4.10 (Linear growth at the depth).** If $f \in \mathrm{Deep}_k$ with $k \ge 1$, then for all $n \ge 0$
> $$c_k\bigl(f^{\star n}\bigr) \;=\; n\,c_k(f).$$
> *Proof.* Induction on $n$ using Lemma 4.3 and the fact that $\mathrm{Deep}_k$ is closed under $\star$. $\square$

> **Theorem 4.11 (First invariant of a non-trivial series).** For every $f \ne q^{-1}$ there is a unique $k \ge 1$ with $c_i(f) = 0$ for $1 \le i < k$ and $c := c_k(f) \ne 0$ — the depth — and along the orbit $c_k(f^{\star n}) = n c$ for all $n$.

> **Theorem 4.12 (Torsion-freeness).** If $f^{\star n} = q^{-1}$ for some $n \ge 1$ then $f = q^{-1}$. Consequently every non-trivial orbit $\{f^{\star n} : n \in \mathbb{Z}\}$ is infinite cyclic, and $n \mapsto f^{\star n}$ is injective.
>
> *Proof.* If $f \ne q^{-1}$, take $k$ and $c \ne 0$ as in Theorem 4.11. Then $0 = c_k(q^{-1}) = c_k(f^{\star n}) = nc \ne 0$ in the characteristic-zero field $\mathbb{C}$, a contradiction. $\square$

> **Theorem 4.13 (Unique divisibility).** For every normalized $f$ and every $n \ge 1$ there is a *unique* normalized $g$ with $g^{\star n} = f$. Hence $(\mathrm{Norm},\star)$ is a torsion-free divisible abelian group, i.e. a $\mathbb{Q}$-vector space, and every power map $f \mapsto f^{\star n}$ ($n\ge1$) is a bijection.
>
> *Proof sketch.* Uniqueness follows from torsion-freeness: if $g^{\star n} = h^{\star n}$ then $(g \star h^{\star(-1)})^{\star n} = q^{-1}$, so $g = h$. Existence is explicit. Let $u = qf$ and $w = u - 1$, which has zero constant term, so substitution of $w$ into any formal power series is well defined coefficientwise. Substituting $w$ into the binomial series
> $$(1+X)^{1/n} \;=\; \sum_{d\ge0} \binom{1/n}{d} X^{d}$$
> yields a power series $v_0$ with $v_0^{\,n} = 1 + w = u$; rescaling $v_0$ by the inverse of its constant term (an $n$-th root of unity) produces a one-unit $v$ with $v^n = u$, and $g = q^{-1}v$. $\square$

The same construction runs with an arbitrary complex exponent, which explains *why* linear growth is possible: the discrete orbit is the restriction of a complex flow.

> **Definition 4.14 (Complex corrected powers).** For $f$ normalized with $u = qf$, $w = u - 1$, and $r \in \mathbb{C}$, define
> $$f^{\star r} \;=\; q^{-1}\cdot \bigl( (1+X)^r \big|_{X = w} \bigr), \qquad (1+X)^r = \sum_{d \ge 0}\binom{r}{d} X^d .$$

> **Theorem 4.15 (One-parameter subgroups).** For every normalized $f$: (i) $f^{\star(r+s)} = f^{\star r} \star f^{\star s}$ for all $r,s \in \mathbb{C}$; (ii) $f^{\star n}$ for $n \in \mathbb{N}$ agrees with the $n$-fold corrected product; (iii) $f^{\star 0} = q^{-1}$ and $f^{\star 1} = f$; (iv) if $f$ is $k$-deep then $c_k(f^{\star r}) = r\,c_k(f)$; (v) if $f \ne q^{-1}$ then $r \mapsto f^{\star r}$ is injective. Hence every non-trivial orbit lies on a faithful complex one-parameter subgroup $(\mathbb{C},+) \hookrightarrow (\mathrm{Norm},\star)$.
>
> *Proof sketch.* (i) is the identity $(1+X)^{r+s} = (1+X)^r (1+X)^s$ of binomial series, transported through substitution, which is a ring homomorphism on series with zero constant term. (ii) is $(1+X)^n = $ the polynomial $(1+X)^n$. (iv): expanding $(1+X)^r|_{X=w} = \sum_d \binom{r}{d} w^d$, the term $d = 0$ contributes nothing at level $k \ge 1$, the term $d=1$ contributes $r\,[q^k]w = r\,c_k(f)$, and each $d \ge 2$ contributes $0$ because $w^d$ has order at least $dk > k$. (v) follows from (iv) with $c_k(f) \ne 0$. $\square$

Statement (iv) is the exact continuous analogue of Theorem 4.10: at the depth, the invariant is *linear in the exponent*, for all complex exponents.

---

## 5. The exact binomial law above the depth

Theorem 4.10 describes level $k$ for a $k$-deep series. The next theorem describes *all* levels at once, and is the computational heart of the paper.

> **Theorem 5.1 (Exact finite binomial expansion).** Let $u$ be a one-unit with low vanishing at $k \ge 1$, and put $w = u - 1$ (so $w$ has order at least $k$). Then for all $m, n \ge 0$
> $$[q^{m}]\bigl(u^{n}\bigr) \;=\; \sum_{d=0}^{\lfloor m/k \rfloor} \binom{n}{d}\,[q^{m}]\bigl(w^{d}\bigr),$$
> a finite sum whose range and whose weights $[q^m](w^d)$ are independent of $n$.
>
> *Proof.* By the binomial theorem in $\mathbb{C}[[q]]$, $u^n = (1+w)^n = \sum_{d=0}^{n} \binom{n}{d} w^{d}$, hence $[q^m]u^n = \sum_{d=0}^{n}\binom{n}{d}[q^m]w^d$. Extend both this sum and the asserted sum to the common range $0 \le d < N$ for any large $N$. The added terms vanish for two different reasons: for $d > n$ because $\binom{n}{d} = 0$; for $d > \lfloor m/k\rfloor$ because $w^d$ has order at least $dk \ge (\lfloor m/k\rfloor +1)k > m$, so $[q^m]w^d = 0$. (That orders add is the elementary fact that if $[q^i]w = 0$ for all $i<k$, then $[q^i](w^d) = 0$ for all $i < dk$, proved by induction on $d$ via the convolution formula.) The two extensions coincide, so the two sums are equal. $\square$

Transporting to normalized series through $\Phi$ gives the following. Write $\omega_d(f, m) = [q^m]\bigl((qf-1)^d\bigr)$ for the **binomial weights**.

> **Theorem 5.2 (Polynomial growth of every orbit invariant).** Let $f$ be $k$-deep, $k \ge 1$. Then for every level $m \ge 0$,
> $$c_m\bigl(f^{\star n}\bigr) \;=\; \sum_{d=0}^{\lfloor m/k\rfloor} \binom{n}{d}\,\omega_d(f,m) \qquad (n \ge 0),$$
> with the weights independent of $n$. Since $\binom{n}{d}$ is a polynomial in $n$ of degree $d$, the level-$m$ invariant of the orbit is a polynomial in the iteration count of degree at most $\lfloor m/k \rfloor$.

Two special cases recover earlier results independently. If $0 < m < k$ then $\lfloor m/k \rfloor = 0$ and the sum is $\binom{n}{0}\omega_0(f,m) = [q^m]1 = 0$: below the depth all orbit invariants vanish identically. If $m = k$, then $\lfloor m/k\rfloor = 1$ and the sum is $\binom{n}{0}\cdot 0 + \binom{n}{1}[q^k](qf-1) = n\,c_k(f)$: the linear law of Theorem 4.10.

The leading weight can be computed in closed form.

> **Lemma 5.3 (Top weight).** If $w$ has order at least $k$ then $[q^{jk}](w^{j}) = \bigl([q^{k}]w\bigr)^{j}$ for all $j \ge 0$.
>
> *Proof.* Induction on $j$. In $[q^{(j+1)k}](w^j \cdot w) = \sum_{p+s = (j+1)k}[q^p](w^j)[q^s]w$, every term with $s < k$ dies since $w$ has order $\ge k$, and every term with $p < jk$ dies since $w^j$ has order $\ge jk$; only $(p,s) = (jk,k)$ survives. $\square$

> **Theorem 5.4 (The binomial growth law, in full).** Let $f$ be $k$-deep with depth invariant $c = c_k(f)$. Then for all $j, n \ge 0$,
> $$c_{jk}\bigl(f^{\star n}\bigr) \;=\; \binom{n}{j}\,c^{\,j} \;+\; \sum_{d < j} \binom{n}{d}\,\omega_d(f, jk).$$
> In particular the degree of $n \mapsto c_{jk}(f^{\star n})$ is **exactly** $j$ whenever $c \ne 0$.
>
> *Proof.* Theorem 5.2 at level $m = jk$, where $\lfloor jk/k\rfloor = j$, together with Lemma 5.3 evaluating the top weight $\omega_j(f, jk) = c^j$. $\square$

> **Corollary 5.5 (Quadratic law at twice the depth).** For $f$ $k$-deep,
> $$c_{2k}\bigl(f^{\star n}\bigr) \;=\; n\,c_{2k}(f) \;+\; \binom{n}{2}\,c_k(f)^{2} .$$
> *Proof.* The case $j = 2$ of Theorem 5.4, with $\omega_1(f,2k) = [q^{2k}](qf-1) = c_{2k}(f)$ and $\omega_0(f,2k) = 0$. Equivalently, one can prove it directly by a "Newton splitting" at level $2k$: for two one-units $a,b$ with low vanishing at $k$,
> $$[q^{2k}](ab) = [q^{2k}]a + [q^{2k}]b + [q^{k}]a\,[q^{k}]b,$$
> since the only surviving antidiagonal terms are $(0,2k)$, $(k,k)$ and $(2k,0)$; induction on $n$ then produces the binomial coefficient $\binom{n}{2}$ via $\binom{n+1}{2} = \binom{n}{2} + n$. $\square$

> **Theorem 5.6 (Finite determination of orbit invariants).** Let $f, g$ both be $k$-deep, $k \ge 1$, and fix a level $m$. If
> $$c_m\bigl(f^{\star n}\bigr) = c_m\bigl(g^{\star n}\bigr) \quad\text{for all } n \le \lfloor m/k \rfloor,$$
> then the same holds for every $n \ge 0$.
>
> *Proof sketch.* Both sides are given by Theorem 5.2 with weight vectors $(\omega_d(f,m))_d$ and $(\omega_d(g,m))_d$ supported on $d \le \lfloor m/k\rfloor$. Strong induction on $j \le \lfloor m/k\rfloor$: evaluating the two expansions at $n = j$ and using $\binom{j}{d} = 0$ for $d > j$ and $\binom{j}{j} = 1$ gives
> $$\sum_{d<j}\binom{j}{d}\omega_d(f,m) + \omega_j(f,m) \;=\; \sum_{d<j}\binom{j}{d}\omega_d(g,m) + \omega_j(g,m),$$
> and the sums agree by the inductive hypothesis, hence $\omega_j(f,m) = \omega_j(g,m)$. Equal weight vectors give equal invariants for all $n$. $\square$

This is the statement that the infinite family of "experiments" $n = 0,1,2,\dots$ collapses to $\lfloor m/k\rfloor + 1$ of them, with the number controlled only by the depth.

Finally, the depth itself is an orbit invariant, which answers the question that motivated the whole development.

> **Theorem 5.7 (Depth is constant along orbits).** Let $f$ be $k$-deep, $k \ge 1$, and let $n \ne 0$. Then $f^{\star n} \in \mathrm{Deep}_{k+1}$ if and only if $f \in \mathrm{Deep}_{k+1}$. Consequently $f$ and $f^{\star n}$ have the same depth for every $n \ne 0$, and the depth is the first invariant that distinguishes $\star$-orbits.
>
> *Proof.* Both $f$ and $f^{\star n}$ lie in $\mathrm{Deep}_k$, and by Theorem 4.10, $c_k(f^{\star n}) = n\,c_k(f)$ with $n \ne 0$ in $\mathbb{C}$. So $c_k(f^{\star n}) = 0 \iff c_k(f) = 0$, which by Theorem 4.5 is the criterion for membership in $\mathrm{Deep}_{k+1}$. $\square$

Combining: the depth separates orbits of different depths; within a fixed depth $k$, the invariant $c_k$ separates the individual iterates (it takes the distinct values $n c_k(f)$); and above the depth, the invariants are polynomials whose exact degrees are prescribed by Theorem 5.4.

---

## 6. An application: iterating moonshine

The McKay–Thompson series of Monstrous Moonshine are normalized $q$-series with vanishing constant term; the class $1\mathrm{A}$ series is
$$J \;=\; q^{-1} + 196884\,q + 21493760\,q^{2} + 864299970\,q^{3} + \cdots$$
(the modular $j$-function with its constant term removed). Vanishing constant term means $c_1(J) = 0$, so $J$ is $2$-deep, with depth invariant $c_2(J) = 196884$.

The general theory then yields closed formulas for every coefficient of every corrected-product iterate $J^{\star n} = q^{\,n-1}J^{\,n}$, with no series manipulation required.

> **Theorem 6.1 (Level 2: the linear regime).** For any normalized trace-shaped series $T$ with $c_1(T) = 0$ and every $n \ge 0$,
> $$c_2\bigl(T^{\star n}\bigr) = n\,c_2(T).$$
> For $J$ this reads: the coefficient of $q$ in $q^{\,n-1}J^{\,n}$ is exactly $196884\,n$; for $n = 2$, $393768$.

> **Theorem 6.2 (Level 4: the quadratic regime).** With $T$ as above and $c_2(T), c_4(T)$ its level-$2$ and level-$4$ invariants (the coefficients of $q$ and $q^3$ in $T$),
> $$c_4\bigl(T^{\star n}\bigr) \;=\; n\,c_4(T) + \binom{n}{2}\,c_2(T)^{2}.$$
> For $J$: the coefficient of $q^{3}$ in $q^{\,n-1}J^{\,n}$ is
> $$864299970\,n \;+\; \binom{n}{2}\cdot 196884^{2}.$$
> At $n = 2$ this evaluates to $1728599940 + 38763309456 = 40491909396$.

*Proof.* Both are Theorem 4.10 and Corollary 5.5 with $k = 2$ (so $2k = 4$), using the dictionary $c_{k}(T) = [q^{k-1}]T$. $\square$

Two features deserve comment. First, the numbers are structural, not coincidental: $196884^2$ appears as the top binomial weight of Lemma 5.3, i.e. as $\bigl(c_2(J)\bigr)^2$ — the square of the depth invariant. Second, the theory predicts the *shape* of the answer at every level: at level $2j$ the coefficient of $q^{2j-1}$ in $J^{\star n}$ is a polynomial in $n$ of degree exactly $j$ with leading binomial term $\binom{n}{j}\,196884^{j}$, and by Theorem 5.6 it is determined by the $j+1$ iterates $n = 0, \dots, j$.

Also worth recording is the "Monster-sized" instance of Proposition 2.8: the corrected product of the $194$ McKay–Thompson-shaped series, one per conjugacy class of the Monster, equals $q^{193}$ times their ordinary product, and lies in $\mathrm{Deep}_2$ because its first invariant is the sum $\sum_i c_1(T_i) = 0$.

---

## 7. Algorithms

The theory is effective. We record the three algorithms it produces; all operate on truncated one-unit coordinates $u = qf = 1 + u_1 q + \cdots + u_{M}q^{M}$ modulo $q^{M+1}$.

**A. Corrected product and corrected inverse.** Given truncations of $f$ and $g$, the corrected product is the truncated Cauchy product of one-units, cost $O(M^2)$; the corrected inverse is the standard triangular recursion $v_0 = 1$, $v_m = -\sum_{i=1}^{m} u_i v_{m-i}$, also $O(M^2)$. Correctness is Theorem 2.7: $\star$ *is* multiplication of one-units.

**B. Orbit invariants by the binomial expansion.** Given a $k$-deep $f$ and a level $m$, compute $w = qf - 1$ truncated at $q^m$, form the powers $w^d$ for $0 \le d \le \lfloor m/k\rfloor$, and read off the weights $\omega_d = [q^m]w^d$. Then $c_m(f^{\star n}) = \sum_d \binom{n}{d}\omega_d$ evaluates the invariant for *any* $n$ in $O(\lfloor m/k\rfloor)$ arithmetic operations after an $O\!\left(\frac{m}{k}M^2\right)$ precomputation — with no dependence on $n$. This is the algorithmic content of Theorem 5.2: the iteration count leaves the inner loop entirely.

**C. Corrected roots and complex powers.** Given $f$ and $r \in \mathbb{C}$, compute $w = qf - 1$ and evaluate $\sum_{d \le M} \binom{r}{d} w^{d}$ truncated at $q^{M}$; the result is the one-unit coordinate of $f^{\star r}$. With $r = 1/n$ this is the unique $\star$-root of Theorem 4.13, computed without any root-finding. Cost $O(M^3)$ naively, or $O(M^2)$ with Horner-style accumulation of the powers of $w$.

An immediate application of B is *orbit fingerprinting*: to test whether $g$ could be $f^{\star n}$ for some unknown $n$, compute the depth $k$ of $f$, check that $g$ has the same depth (Theorem 5.7), read off the candidate $n = c_k(g)/c_k(f)$ from the linear law, and then verify at higher levels using the polynomial expansion. Each higher level is a single polynomial identity check rather than a series computation.

---

## 8. Discussion

**Obstruction as structure.** The narrative arc here is that a closure failure, quantified exactly, turns into an algebraic structure. The failure is one unit of pole order per additional factor; the repair $q^{m-1}$ is unique (Theorem 1.3); and the repaired binary operation is not just closed but a commutative group law with a canonical identification (Theorem 2.7). The set of normalized series has no preferred element intrinsically, so the correct statement is torsorial: $\mathrm{Norm}$ is a torsor under the one-unit group, and becomes that group once $q^{-1}$ is chosen as origin.

**Why the invariants behave so well.** All the rigidity — torsion-freeness, unique divisibility, linear then polynomial growth — traces back to the single fact that the one-unit group is *pro-unipotent*: it is the inverse limit of the unipotent groups $(1 + q\mathbb{C}[[q]])/(1 + q^{k}\mathbb{C}[[q]])$, and its "logarithm" is available because we are in characteristic zero. Theorem 4.15 makes this concrete without invoking any Lie theory: the substitution of $qf - 1$ into $(1+X)^r$ is an honest one-parameter flow, and Theorem 5.1 is the statement that the flow's coefficient functions are polynomial because the substituted variable is nilpotent to any finite order.

**What the tower does and does not see.** Corollary 4.6 shows that all the graded pieces are isomorphic, so nothing intrinsic to a piece detects its level; and Theorem 4.8 shows that the full invariant system is a free and complete coordinate system, but not a homomorphism. The resolution is Theorem 5.7: depth — a *positional* datum in the tower — is the first genuine orbit invariant, and everything else is expansion data around it.

**Comparison with the naive product.** It is worth stressing what the corrected product is *not*. It is not the pointwise or ordinary product of functions: $f \star g = qfg$ has a different analytic meaning, and the group structure is that of one-units, not of the multiplicative group of a function field. What survives is precisely the combinatorics of coefficients, which is where moonshine-type arithmetic lives. That is why Theorems 6.1 and 6.2 have crisp arithmetic content while saying nothing directly about modularity.

**Limits of the results.** The results are statements about formal Laurent series over $\mathbb{C}$. Nothing here asserts that $J^{\star n}$ is modular for $n \ge 2$ — it is not, in general — nor that the corrected product preserves integrality of coefficients beyond the obvious (it does: if $f,g$ have integer coefficients then so does $qfg$, and the iterate formulas of Section 6 return integers, as the moonshine numbers illustrate). The invariant theory is complete for orbits, but the classification of orbits themselves inside a fixed depth stratum reduces, by Theorem 4.13, to a $\mathbb{Q}$-linear question in an infinite-dimensional vector space.

---

## 9. Future directions

This work turned $f \star g = q f g$ from a well-posed operation into a fully described algebraic object: a torsion-free, uniquely divisible abelian group isomorphic to the one-units $1 + q\mathbb{C}[[q]]$, equipped with a separating filtration whose graded pieces are copies of $(\mathbb{C},+)$, with faithful complex one-parameter subgroups through every point, a second-order binomial growth law at level $2k$, an identification of the associated graded object, strictness and separatedness of the tower, and completeness and freeness of the whole invariant system. The exact finite binomial expansion then showed that *every* orbit invariant at level $m$ of a $k$-deep series is a polynomial in the iteration count of degree at most $\lfloor m/k\rfloor$, determined by $\lfloor m/k\rfloor + 1$ iterates; the leading weight at level $jk$ is $\binom{n}{j}c^{j}$, so the degree in $n$ is exactly $j$ when the depth invariant $c$ is non-zero; and depth is constant along every non-trivial orbit — the answer to the question that opened the investigation. What remains open is recorded below, in falsifiable form.

### 9.1 Decidability of corrected-product orbit membership

The finite-determination theorem says the level-$m$ invariant of an orbit is a polynomial of degree at most $\lfloor m/k \rfloor$ in the iteration count. *Conjecture*: for normalized series whose coefficients lie in a fixed number field, the question "is $g$ an iterate $f^{\star n}$ of $f$?" is decidable, and a witness $n$ — if one exists — is bounded by an explicit function of the depth $k$ and the first level $m$ at which $f$ and $g$ differ.

The key insight is that the exact binomial expansion converts the a priori infinite search over $n$ into a *single* polynomial equation $\sum_{d \le m/k} c_d \binom{n}{d} = c_m(g)$ with $n$-independent coefficients $c_d$; a non-constant polynomial has at most $\lfloor m/k\rfloor$ roots, so either the level-$m$ equation already pins $n$ down to a finite list, or the level-$m$ invariant carries no information at all and one passes to the next level, which by strictness of the filtration is a strictly smaller stage. Both ingredients — the $n$-independence of the weights and the strict descent of the tower — are now available, which is what makes the conjecture attackable.

### 9.2 Further lines

* **Integral and $p$-adic structure.** The corrected product preserves $\mathbb{Z}$-coefficients. What is the structure of the sub-monoid of integral normalized series, which is *not* divisible? Which integral series have integral $\star$-roots, and is the answer governed by congruences on the depth invariant?
* **Arithmetic of the weights.** For $J$ the binomial weights at level $2j$ begin $196884^{j}$; are the lower weights expressible in terms of the moonshine coefficients in a uniform way, and do they inherit divisibility phenomena?
* **Other obstruction repairs.** The same analysis applies whenever a normalization pins a leading exponent: series with polar part $q^{-N}$, or with prescribed leading coefficient $\lambda \ne 1$, produce corrected products $q^{N} fg$ and rescalings thereof. Which of the structural theorems survive, and does the uniqueness of the monomial repair persist in the multivariate setting?
* **Finite-level truncations.** The quotients $\mathrm{Norm}/\mathrm{Deep}_{k}$ are finite-dimensional unipotent groups. Making the polynomial growth laws uniform in $k$ would give effective bounds for the decidability question of §9.1.

---

## 10. Summary of results

1. **Obstruction and uniqueness.** A product of normalized series is never normalized; $q^{m}fg$ is normalized exactly for $m = 1$.
2. **Coordinates.** $f$ is normalized iff $f = q^{-1}u$ with $u$ a one-unit.
3. **Closure and group law.** $f \star g = qfg$ is closed, and $(\mathrm{Norm}, \star, q^{-1}, f \mapsto q^{-2}f^{-1})$ is a commutative group.
4. **Structure theorem.** $f \mapsto qf$ is an isomorphism onto $1 + q\mathbb{C}[[q]]$; iterates satisfy $f^{\star n} = q^{n-1}f^n$.
5. **First invariant.** $a_0$ is a surjective homomorphism onto $(\mathbb{C},+)$ with $a_0(f^{\star n}) = n a_0(f)$, but is not injective.
6. **Filtration.** The depth subgroups form a strictly descending, separated tower; each level invariant is a surjective homomorphism on its stage with kernel the next stage; all graded pieces are $(\mathbb{C},+)$; the full invariant system is a bijection onto $\mathbb{C}^{\mathbb{N}}$ but not a homomorphism.
7. **Rigidity.** The group is torsion-free and uniquely divisible — a $\mathbb{Q}$-vector space — with explicit complex one-parameter subgroups $r \mapsto f^{\star r}$, faithful away from the base point, satisfying $c_k(f^{\star r}) = r\,c_k(f)$ at the depth.
8. **Binomial law.** $c_m(f^{\star n}) = \sum_{d \le \lfloor m/k\rfloor}\binom{n}{d}\omega_d$ with $n$-independent weights; degree exactly $j$ at level $jk$ with leading term $\binom{n}{j}c_k(f)^j$; quadratic law $c_{2k}(f^{\star n}) = n c_{2k}(f) + \binom{n}{2}c_k(f)^2$; finite determination by $\lfloor m/k\rfloor + 1$ iterates; depth constant along orbits.
9. **Moonshine.** For $J = q^{-1} + 196884q + 21493760q^2 + 864299970q^3 + \cdots$: the $q$-coefficient of $J^{\star n}$ is $196884\,n$, and the $q^3$-coefficient is $864299970\,n + \binom{n}{2}196884^{2}$, equal to $40491909396$ at $n = 2$.
