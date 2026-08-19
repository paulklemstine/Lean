# The Pole-Order Obstruction for Products of Normalized $q$-Series

**Author:** Aristotle

**Date:** 2026-08-19

---

## Abstract

A *normalized* $q$-series is a formal Laurent series over $\mathbb{C}$ of the
shape $f = q^{-1} + a_0 + a_1 q + a_2 q^2 + \cdots$ — a simple pole of residue
$1$ at the cusp, followed by a power series. This is the shape of every
McKay–Thompson series of the Monster simple group. We prove that the class of
normalized series is *not* closed under multiplication, and that the failure is
measured completely and sharply by a single integer.

Precisely: the additive order (valuation) $\operatorname{ord}$ on
$\mathbb{C}(\!(q)\!)$, taking values in $\mathbb{Z} \cup \{\infty\}$, is
additive on products, from which a product of $m$ normalized series has order
*exactly* $-m$, with leading coefficient exactly $1$; consequently the product is
normalized if and only if $m = 1$, and for $m \ge 1$ the product is not a power
series at all. The obstruction is removable in exactly one way: $q^{k}$ times
the product has order $0$ if and only if $k = m$, and the corrected series
$q^m \prod_i f_i$ is then not merely a power series but a *unit* of
$\mathbb{C}[\![q]\!]$. The structural reason is a unique factorization theorem —
every normalized series is uniquely $q^{-1}$ times a power series with constant
term $1$ — together with the fact that $\operatorname{ord}$ restricts to a
surjective group homomorphism $\mathbb{C}(\!(q)\!)^{\times} \to \mathbb{Z}$,
whose fibres are disjoint. We compute the first two coefficients past the pole,
obtaining Newton-type identities in the elementary symmetric functions of the
factors' coefficients, and specialize everything to the $194$ conjugacy classes
of the Monster: the full Monstrous Moonshine product has a pole of order exactly
$194$, its subleading coefficient vanishes under the standard normalization, and
its next coefficient is the character sum $\sum_g c_g(1)$.

**Keywords.** Laurent series; valuation; pole order; McKay–Thompson series;
Monstrous Moonshine; hauptmodul; Newton identities; units of a power series ring.

---

## 1. Introduction

### 1.1 Motivation

Monstrous Moonshine attaches to each conjugacy class $g$ of the Monster simple
group $\mathbb{M}$ a *McKay–Thompson series*

$$T_g(q) = \frac{1}{q} + \sum_{n \ge 1} c_g(n)\, q^{n},$$

the graded trace of $g$ acting on the moonshine module $V^{\natural} =
\bigoplus_{n \ge -1} V^{\natural}_n$. There are exactly $194$ conjugacy classes
in $\mathbb{M}$, hence exactly $194$ such series. The class $1A$ gives the
normalized modular invariant $J = j - 744 = q^{-1} + 196884q + 21493760q^2 +
\cdots$, and the celebrated numerology $196884 = 196883 + 1$, $4372 = 4371 + 1$
opens the subject.

The shared feature of all $194$ series is completely rigid: a simple pole with
residue $1$ at $q = 0$, and no deeper pole. This shape is what makes each $T_g$
a *hauptmodul* candidate for its invariance group — a generator of the field of
modular functions with a single simple pole at the cusp.

The question we answer is the naive one that any such rigid shared shape
provokes. Is this class of series stable under multiplication? Many
constructions in and around moonshine — twisted denominator identities,
replication formulas, Hecke-type operators, products indexed by conjugacy
classes — combine several trace functions multiplicatively, and it is important
to know precisely what shape emerges. The answer is that the class is stable
only trivially, that the failure is governed by a single integer, and that the
integer determines its own repair.

### 1.2 Summary of results

Throughout, $\mathbb{C}[\![q]\!]$ denotes formal power series and
$\mathbb{C}(\!(q)\!)$ formal Laurent series over $\mathbb{C}$ (equivalently,
Hahn series with value group $\mathbb{Z}$).

1. **Pole-Order Theorem** (Theorem 3.3). A product of $m$ normalized series has
   order exactly $-m$ and leading coefficient exactly $1$.
2. **Non-Closure** (Theorem 3.4). Such a product is normalized iff $m = 1$; for
   $m \ge 1$ it is not in the image of $\mathbb{C}[\![q]\!] \hookrightarrow
   \mathbb{C}(\!(q)\!)$ (Theorem 3.5).
3. **Unique Correction** (Theorem 4.1). $q^k \prod_i f_i$ has order $0$ iff
   $k = m$.
4. **Unit Structure** (Theorem 4.4). $q^m \prod_i f_i$ is the image of a unit of
   $\mathbb{C}[\![q]\!]$; its constant term is $1$.
5. **Unique Factorization** (Theorem 5.1). Every normalized $f$ is uniquely
   $q^{-1} u$ with $u \in \mathbb{C}[\![q]\!]$, $u(0) = 1$; hence
   $\prod_i f_i = q^{-m}\prod_i u_i$ (Corollary 5.2).
6. **Valuation as a homomorphism** (Theorem 6.2). $\operatorname{ord}$ induces a
   surjective group homomorphism $\mathbb{C}(\!(q)\!)^{\times} \to \mathbb{Z}$;
   the obstruction is membership in the fibre over $-m$ (Corollary 6.4).
7. **Newton-type coefficient identities** (Theorems 7.2 and 7.4). The
   coefficients at degrees $1-m$ and $2-m$ are, respectively, the first power sum
   and a combination of the first two elementary symmetric functions of the
   factors' coefficients.
8. **Monster specialization** (Section 8). Pole of order exactly $194$; unique
   correction $q^{194}$; vanishing coefficient at $q^{-193}$; coefficient
   $\sum_g c_g(1)$ at $q^{-192}$; the two-factor instance $J \cdot T_{2A}$ has
   constant coefficient $196884 + 4372 = 201256$.

### 1.3 A convention that is part of the theorem

There is one design point that is not cosmetic and that we record because it
silently breaks naive statements. It is standard to extend the order function to
the zero series; the two common conventions are $\operatorname{ord}(0) = \infty$
(values in $\mathbb{Z} \cup \{\infty\}$, with $\infty$ absorbing under addition)
and $\operatorname{ord}(0) = 0$ (values in $\mathbb{Z}$, chosen so the function
is total). Only the first is compatible with unrestricted additivity. With the
second, "a product of $m$ normalized series has order $-m$" is *false* for
families that are permitted to contain the zero series, and false with no
syntactic warning. Every general statement below therefore uses the
$\mathbb{Z} \cup \{\infty\}$-valued order; the $\mathbb{Z}$-valued versions carry
an explicit non-vanishing hypothesis, which we discharge each time from the
leading-coefficient computation.

---

## 2. Setting and definitions

### 2.1 Laurent series and the order valuation

**Definition 2.1 (Laurent series).** A *formal Laurent series* over
$\mathbb{C}$ is a function $f \colon \mathbb{Z} \to \mathbb{C}$, written
$f = \sum_{n \in \mathbb{Z}} f_n q^n$, whose support $\{n : f_n \ne 0\}$ is
bounded below. These form a field $\mathbb{C}(\!(q)\!)$ under coefficientwise
addition and the convolution product $(fg)_n = \sum_{i+j = n} f_i g_j$ (a finite
sum, by the support condition). The subring of series with support in
$\mathbb{Z}_{\ge 0}$ is the power series ring $\mathbb{C}[\![q]\!]$.

**Definition 2.2 (Order).** For $f \ne 0$, the *order* $\operatorname{ord}(f)
\in \mathbb{Z}$ is $\min\{n : f_n \ne 0\}$, and the *leading coefficient*
$\operatorname{lc}(f)$ is $f_{\operatorname{ord}(f)}$. We set
$\operatorname{ord}(0) = \infty$ in the ordered monoid $\mathbb{Z} \cup
\{\infty\}$, where $\infty + x = x + \infty = \infty$.

**Lemma 2.3 (Additivity).** For all $f, g \in \mathbb{C}(\!(q)\!)$,
$$\operatorname{ord}(fg) = \operatorname{ord}(f) + \operatorname{ord}(g),
\qquad \text{and if } f,g \neq 0, \quad
\operatorname{lc}(fg) = \operatorname{lc}(f)\operatorname{lc}(g).$$

*Proof sketch.* If either factor is $0$ both sides are $\infty$. Otherwise let
$d = \operatorname{ord} f$, $e = \operatorname{ord} g$. For $n < d + e$ every
term $f_i g_j$ with $i + j = n$ has $i < d$ or $j < e$, hence vanishes; for
$n = d+e$ the only surviving term is $f_d g_e$, which is nonzero because
$\mathbb{C}$ is an integral domain. $\square$

Additivity is the only nontrivial input to the entire paper; the fact that it is
an *equality* rather than an inequality — a consequence of $\mathbb{C}$ being a
domain — is what turns every bound below into an exact obstruction.

**Lemma 2.4 (Finite products).** For any finite index set $S$ and any family
$(f_i)_{i \in S}$ in $\mathbb{C}(\!(q)\!)$,
$$\operatorname{ord}\Big(\prod_{i \in S} f_i\Big) = \sum_{i \in S}
\operatorname{ord}(f_i) \quad \text{in } \mathbb{Z} \cup \{\infty\}.$$

*Proof sketch.* Induction on $|S|$, using Lemma 2.3 at each step; the empty
product is $1$, of order $0$. No non-vanishing hypothesis is needed, since
$\infty$ absorbs. $\square$

**Lemma 2.5 (Units of $\mathbb{C}[\![q]\!]$).** A power series $u$ is invertible
in $\mathbb{C}[\![q]\!]$ if and only if $u_0 \ne 0$.

*Proof sketch.* Necessity is clear from $u_0 v_0 = 1$. For sufficiency, solve
$\sum_{i+j=n} u_i v_j = \delta_{n,0}$ recursively: $v_0 = u_0^{-1}$ and
$v_n = -u_0^{-1}\sum_{i=1}^{n} u_i v_{n-i}$. $\square$

### 2.2 Normalized series

**Definition 2.6 (Normalized series).** A Laurent series $f$ is *normalized* if

* $f_{-1} = 1$, and
* $f_n = 0$ for every $n < -1$.

Equivalently, $f = q^{-1} + a_0 + a_1 q + a_2 q^2 + \cdots$ for some
$a_0, a_1, \dots \in \mathbb{C}$. We write $\mathcal{N} \subset
\mathbb{C}(\!(q)\!)$ for the set of normalized series.

**Lemma 2.7.** If $f$ is normalized then $f \ne 0$, $\operatorname{ord}(f) = -1$
and $\operatorname{lc}(f) = 1$.

*Proof sketch.* $f_{-1} = 1 \ne 0$ shows $f \ne 0$ and $-1$ lies in the support;
the second condition says nothing below $-1$ lies in the support, so $-1$ is the
minimum. The leading coefficient is then $f_{-1} = 1$. $\square$

**Definition 2.8 (Trace-series model).** For a sequence $c \colon \mathbb{Z}_{\ge
0} \to \mathbb{C}$ put
$$T[c] \;=\; q^{-1} + \sum_{n \ge 0} c(n)\, q^{n}.$$

**Lemma 2.9.** $T[c]$ is normalized for every $c$, with $T[c]_0 = c(0)$ and
$T[c]_1 = c(1)$.

*Proof sketch.* Immediate: the power-series summand contributes nothing in
degrees $< 0$, so the coefficient at $-1$ is $1$ and all lower coefficients
vanish. $\square$

Every McKay–Thompson series is of the form $T[c]$ with $c(0) = 0$.

---

## 3. The pole-order theorem

Fix a finite index set $S$ with $|S| = m$ and a family $(f_i)_{i \in S}$ of
normalized series. Write $P = \prod_{i \in S} f_i$.

**Theorem 3.1 (Leading coefficient).** $\operatorname{lc}(P) = 1$.

*Proof sketch.* Induction on $|S|$ using multiplicativity of the leading
coefficient (Lemma 2.3) and $\operatorname{lc}(f_i) = 1$ (Lemma 2.7); the empty
product has leading coefficient $1$. $\square$

**Corollary 3.2.** $P \ne 0$.

*Proof sketch.* The zero series has no leading coefficient equal to $1$; more
carefully, if $P = 0$ then $P$ has no nonzero coefficient at all, contradicting
Theorem 3.1. $\square$

**Theorem 3.3 (Pole-Order Theorem).**
$$\operatorname{ord}\Big(\prod_{i \in S} f_i\Big) = -m,
\qquad m = |S|.$$
Equivalently, $P = q^{-m} + (\text{higher order terms})$.

*Proof sketch.* By Lemma 2.4 the order of $P$ is $\sum_{i \in S}
\operatorname{ord}(f_i) = \sum_{i \in S}(-1) = -m$, using Lemma 2.7. Corollary
3.2 guarantees the value is finite, so the statement is meaningful as an equality
of integers. Combined with Theorem 3.1, the expansion begins with $1 \cdot
q^{-m}$. $\square$

The content of Theorem 3.3 is the word *exactly*: no cancellation is possible.
Poles of normalized series add up with perfect fidelity because the leading
coefficients are all $1$ and $\mathbb{C}$ is a domain.

**Theorem 3.4 (Non-Closure).** $P$ is normalized if and only if $m = 1$.

*Proof sketch.* If $P$ is normalized then $\operatorname{ord}(P) = -1$ by Lemma
2.7, while $\operatorname{ord}(P) = -m$ by Theorem 3.3; hence $m = 1$.
Conversely if $m = 1$ then $P = f_i$ for the unique $i \in S$, which is
normalized by hypothesis. $\square$

**Theorem 3.5 (Genuine pole).** If $m \ge 1$ then $P \notin \mathbb{C}[\![q]\!]$,
i.e. $P$ is not the image of any formal power series.

*Proof sketch.* By Theorems 3.1 and 3.3 the coefficient of $q^{-m}$ in $P$ is
$1$. Any element of the image of $\mathbb{C}[\![q]\!]$ has vanishing
coefficients in all negative degrees, and $-m < 0$. $\square$

So the obstruction is not an inconvenience of presentation: the product lies
outside the power series ring as a matter of fact.

---

## 4. Correcting the pole, and the uniqueness of the correction

**Theorem 4.1 (Unique monomial correction).** For $k \in \mathbb{Z}_{\ge 0}$,
$$\operatorname{ord}\Big(q^{k}\prod_{i \in S} f_i\Big) = 0
\iff k = m.$$
In particular $\operatorname{ord}\big(q^{m}\prod_i f_i\big) = 0$.

*Proof sketch.* $\operatorname{ord}(q^k) = k$, and by Lemma 2.4 and Theorem 3.3
the order of the corrected product is $k - m$; this vanishes iff $k = m$.
$\square$

**Theorem 4.2 (Leading coefficient survives).**
$\operatorname{lc}\big(q^m \prod_i f_i\big) = 1$; equivalently, the constant term
of the corrected series is $1$.

*Proof sketch.* Multiplicativity of $\operatorname{lc}$ together with
$\operatorname{lc}(q^m) = 1$ and Theorem 3.1. Since the order is $0$ by Theorem
4.1, the leading coefficient *is* the constant term. $\square$

**Definition 4.3 (Unit part).** For normalized $f$, define $U(f) \in
\mathbb{C}[\![q]\!]$ to be the power series with $U(f)_n = f_{n-1}$, $n \ge 0$;
by construction $q f = U(f)$ as Laurent series and $U(f)_0 = f_{-1} = 1$,
$U(f)_1 = f_0$, $U(f)_2 = f_1$, and in general $U(f)_n = f_{n-1}$.

**Theorem 4.4 (Unit structure of the corrected product).** For normalized
$(f_i)_{i \in S}$,
$$q^{m}\prod_{i \in S} f_i \;=\; \prod_{i \in S} U(f_i)
\quad\text{in } \mathbb{C}[\![q]\!],$$
and this power series is a **unit** of $\mathbb{C}[\![q]\!]$.

*Proof sketch.* Each $U(f_i) = q f_i$, so $\prod_i U(f_i) = q^{m}\prod_i f_i$.
Each $U(f_i)$ has constant term $1$, hence is a unit by Lemma 2.5; a finite
product of units is a unit. $\square$

Theorem 4.4 upgrades Theorem 4.1 from a numerical statement ("the order is $0$")
to a structural one: after correction the product does not merely land in the
ring $\mathbb{C}[\![q]\!]$; it lands in the group $\mathbb{C}[\![q]\!]^{\times}$,
indeed in the subgroup $1 + q\mathbb{C}[\![q]\!]$ of principal units.

---

## 5. Unique factorization of normalized series

**Theorem 5.1 (Structure theorem).** For each normalized $f$ there is a
*unique* power series $u$ with constant term $1$ such that
$$f = q^{-1} \cdot u .$$
Namely $u = U(f)$.

*Proof sketch.* *Existence:* $q^{-1}U(f) = q^{-1}(qf) = f$, and $U(f)_0 =
f_{-1} = 1$. *Uniqueness:* if $f = q^{-1}v$ with $v \in \mathbb{C}[\![q]\!]$,
multiply by $q$ (a unit of the field $\mathbb{C}(\!(q)\!)$) to get $v = qf =
U(f)$; since $\mathbb{C}[\![q]\!] \to \mathbb{C}(\!(q)\!)$ is injective, $v$ and
$U(f)$ agree as power series. $\square$

**Corollary 5.2 (Factorization of the product).** For normalized
$(f_i)_{i \in S}$ with $|S| = m$,
$$\prod_{i \in S} f_i \;=\; q^{-m}\cdot \prod_{i \in S} U(f_i),$$
a monomial of degree $-m$ times a unit of $\mathbb{C}[\![q]\!]$ with constant
term $1$.

Corollary 5.2 is the conceptual root of the whole paper. Once one knows that the
normalized series are exactly the elements $q^{-1} u$ with $u \in 1 +
q\mathbb{C}[\![q]\!]$, everything else is bookkeeping in the direct product
decomposition
$$\mathbb{C}(\!(q)\!)^{\times} \;\cong\; q^{\mathbb{Z}} \times
\mathbb{C}^{\times} \times \big(1 + q\mathbb{C}[\![q]\!]\big),$$
under which $\mathcal{N}$ is the slice $\{q^{-1}\}\times\{1\}\times(1 +
q\mathbb{C}[\![q]\!])$. Multiplying $m$ elements of the slice multiplies the
monomial components, sending $q^{-1} \mapsto q^{-m}$; the slice is closed under
multiplication only if $m = 1$, because $\{-1\}$ is closed under addition in
$\mathbb{Z}$ only for one-fold sums.

---

## 6. The valuation as a group homomorphism

Restricting the order to the multiplicative group of the field packages the
obstruction group-theoretically.

**Lemma 6.1.** For nonzero $x, y \in \mathbb{C}(\!(q)\!)$,
$\operatorname{ord}(xy) = \operatorname{ord}(x) + \operatorname{ord}(y)$ in
$\mathbb{Z}$, and $\operatorname{ord}(1) = 0$.

**Theorem 6.2 (Order homomorphism).** The map
$$\operatorname{ord} \colon \mathbb{C}(\!(q)\!)^{\times} \longrightarrow
\mathbb{Z}$$
is a surjective group homomorphism from the multiplicative group of the field of
Laurent series onto the additive group of integers.

*Proof sketch.* Homomorphism: Lemma 6.1 (every nonzero element of a field is a
unit, so the domain is all of $\mathbb{C}(\!(q)\!)\setminus\{0\}$). Surjectivity:
for $k \in \mathbb{Z}$ the monomial $q^{k}$ is invertible with inverse $q^{-k}$,
and $\operatorname{ord}(q^k) = k$. $\square$

**Lemma 6.3.** Every normalized series is a unit of $\mathbb{C}(\!(q)\!)$, and
$\operatorname{ord}(f) = -1$: normalized series lie in the fibre
$\operatorname{ord}^{-1}(-1)$.

**Corollary 6.4 (Completeness of the obstruction).** A product of $m$ normalized
series lies in the fibre $\operatorname{ord}^{-1}(-m)$, hence — the fibres of a
homomorphism being pairwise disjoint — in no other fibre. In particular it lies
in $\operatorname{ord}^{-1}(-1)$, the fibre containing all normalized series, if
and only if $m = 1$.

This is the sense in which the pole order is a *complete* obstruction rather
than a mere necessary condition: it is the value of a homomorphism, and
homomorphism values partition the group. The kernel
$\operatorname{ord}^{-1}(0) = \mathbb{C}[\![q]\!]^{\times}$ is exactly the group
of unit power series, so Corollary 5.2 exhibits the standard splitting: every
nonzero Laurent series is a monomial times an element of the kernel, uniquely.

---

## 7. Newton-type identities for the coefficients past the pole

Corollary 5.2 transfers all coefficient questions about $\prod_i f_i$ to
coefficient questions about a product of power series with constant term $1$.
Concretely, for $k \ge 0$,
$$\Big(\prod_{i \in S} f_i\Big)_{k - m} \;=\; \Big(\prod_{i \in S} U(f_i)\Big)_{k}.$$
Write $f_i = q^{-1} + a_i + b_i q + \cdots$, so $U(f_i) = 1 + a_i q + b_i q^2 +
\cdots$.

**Lemma 7.1 (Level 1 for unit power series).** If $(g_i)_{i \in S}$ are power
series with $(g_i)_0 = 1$ for all $i$, then
$$\Big(\prod_{i \in S} g_i\Big)_1 = \sum_{i \in S} (g_i)_1 .$$

*Proof sketch.* Induction on $|S|$, using $(gh)_1 = g_0 h_1 + g_1 h_0$ and the
fact that a product of series with constant term $1$ again has constant term $1$.
$\square$

**Theorem 7.2 (Subleading Laurent coefficient).** For normalized
$(f_i)_{i \in S}$ with $|S| = m$,
$$\Big(\prod_{i \in S} f_i\Big)_{1-m} \;=\; \sum_{i \in S} a_i,$$
the sum of the constant terms of the factors.

*Proof sketch.* Apply the coefficient transfer with $k = 1$ and Lemma 7.1 to
$g_i = U(f_i)$, noting $(U(f_i))_1 = a_i$. $\square$

**Lemma 7.3 (Level 2 for unit power series).** If $(g_i)_{i \in S}$ are power
series with $(g_i)_0 = 1$, then
$$2\Big(\prod_{i \in S} g_i\Big)_2
= 2\sum_{i \in S} (g_i)_2 + \Big(\sum_{i \in S} (g_i)_1\Big)^{2}
- \sum_{i \in S} (g_i)_1^{2}.$$

*Proof sketch.* Induction on $|S|$. The inductive step uses the convolution
formula $(gh)_2 = g_0 h_2 + g_1 h_1 + g_2 h_0$ together with $g_0 = h_0 = 1$,
the level-1 identity of Lemma 7.1 for the partial product, and the algebraic
identity $\big(A + x\big)^2 - \big(A^2 + x^2\big) = 2Ax$. The statement is
written in denominator-free form to avoid dividing by $2$; equivalently
$\big(\prod g_i\big)_2 = \sum_i (g_i)_2 + e_2\big((g_i)_1\big)$ where
$e_2(x) = \sum_{i<j} x_i x_j$, since $\big(\sum x_i\big)^2 - \sum x_i^2 =
2 e_2(x)$ is Newton's identity relating the power sums $p_1, p_2$ to $e_1, e_2$.
$\square$

**Theorem 7.4 (Sub-subleading Laurent coefficient).** For normalized
$(f_i)_{i \in S}$ with $|S| = m$, writing $a_i$ and $b_i$ for the constant and
linear coefficients of $f_i$,
$$2\Big(\prod_{i \in S} f_i\Big)_{2-m}
= 2\sum_{i \in S} b_i + \Big(\sum_{i \in S} a_i\Big)^{2}
- \sum_{i \in S} a_i^{2},$$
equivalently
$$\Big(\prod_{i \in S} f_i\Big)_{2-m} = \sum_{i \in S} b_i
+ \sum_{i < j} a_i a_j .$$

*Proof sketch.* Coefficient transfer with $k = 2$, then Lemma 7.3 with
$g_i = U(f_i)$, using $(U(f_i))_1 = a_i$ and $(U(f_i))_2 = b_i$. $\square$

Theorems 7.2 and 7.4 are the first two levels of a hierarchy. At level $k$, the
coefficient at $q^{k-m}$ is a universal polynomial with rational coefficients in
the coefficients $a_i, b_i, \dots$ of the factors, and its shape is dictated by
the logarithm map: on the group $1 + q\mathbb{C}[\![q]\!]$ the formal logarithm
is an isomorphism onto $q\mathbb{C}[\![q]\!]$, converting the product $\prod_i
U(f_i)$ into the sum $\sum_i \log U(f_i)$; exponentiating back expresses the
level-$k$ coefficient as the degree-$k$ part of $\exp$ applied to a sum of power
sums, which is exactly the classical passage from power sums to elementary
symmetric functions. Levels $1$ and $2$ above are the visible face of this
mechanism; the general level is stated as Conjecture 9.1 below.

---

## 8. Specialization: the Monster

The Monster simple group $\mathbb{M}$ has order
$$|\mathbb{M}| = 808017424794512875886459904961710757005754368000000000$$
and exactly $194$ conjugacy classes. Monstrous Moonshine assigns to each class
$g$ the trace series $T_g = q^{-1} + \sum_{n\ge 1} c_g(n) q^n$, so that in our
notation $T_g = T[c_g]$ with $c_g(0) = 0$, and every $T_g$ is normalized (Lemma
2.9). Let
$$\Pi \;=\; \prod_{g} T_g$$
be the product over all $194$ classes.

**Theorem 8.1 (Monster-sized pole).** $\operatorname{ord}(\Pi) = -194$, and the
coefficient of $q^{-194}$ in $\Pi$ is $1$.

*Proof sketch.* Theorems 3.3 and 3.1 with $m = 194$. $\square$

**Theorem 8.2 (Not a power series).** $\Pi \notin \mathbb{C}[\![q]\!]$.

*Proof sketch.* Theorem 3.5, since $194 \ge 1$. $\square$

**Theorem 8.3 (Unique correction and unit structure).** For $k \in
\mathbb{Z}_{\ge 0}$, $\operatorname{ord}(q^k \Pi) = 0$ iff $k = 194$; and
$q^{194}\Pi = \prod_g U(T_g)$ is a unit of $\mathbb{C}[\![q]\!]$ with constant
term $1$. Equivalently $\Pi = q^{-194}\prod_g U(T_g)$.

*Proof sketch.* Theorems 4.1, 4.4 and Corollary 5.2. $\square$

**Theorem 8.4 (Vanishing subleading coefficient).** Since $c_g(0) = 0$ for every
class $g$, the coefficient of $q^{-193}$ in $\Pi$ is $0$:
$$\Pi = q^{-194} + 0\cdot q^{-193} + \Big(\sum_{g} c_g(1)\Big) q^{-192} + \cdots.$$

*Proof sketch.* Theorem 7.2 gives the $q^{-193}$ coefficient as $\sum_g c_g(0) =
0$. Theorem 7.4 then gives $2 \cdot (\Pi)_{-192} = 2\sum_g c_g(1) + 0 - 0$, so
$(\Pi)_{-192} = \sum_g c_g(1)$. $\square$

The number $\sum_g c_g(1)$ is a pure character sum: $c_g(1)$ is the trace of $g$
on the graded piece $V^{\natural}_1$, which as a Monster representation is
$\mathbf{1} \oplus \mathbf{196883}$. So $\sum_g c_g(1) = \sum_g \big(1 +
\chi_{196883}(g)\big) = 194 + \sum_g \chi_{196883}(g)$, a sum over conjugacy
*classes* (not group elements) of the smallest faithful character of the Monster,
shifted by the number of classes.

**A verifiable two-factor instance.** Take the two classes $1A$ and $2A$, with
$$T_{1A} = J = q^{-1} + 196884\,q + 21493760\,q^2 + \cdots, \qquad
T_{2A} = q^{-1} + 4372\,q + 96256\,q^2 + \cdots .$$
Both have vanishing constant term. Theorem 3.3 gives
$\operatorname{ord}(J\cdot T_{2A}) = -2$ with leading coefficient $1$; Theorem
7.2 gives coefficient $0$ at $q^{-1}$; Theorem 7.4 gives the constant
coefficient
$$196884 + 4372 = 201256 .$$
So $J \cdot T_{2A} = q^{-2} + 0\cdot q^{-1} + 201256 + \cdots$. The numbers
$196884 = 196883 + 1$ and $4372 = 4371 + 1$ are the two observations that opened
moonshine; their sum appears here as a structural consequence of Newton's
identity at level $2$ rather than as a coincidence.

---

## 9. Discussion, applications and open problems

### 9.1 What the obstruction is good for

The practical content is a *design rule* for any construction in the moonshine
circle of ideas that multiplies trace functions. Suppose one builds an object
from $m$ hauptmoduln — for instance in twisted denominator identities for the
Monster Lie algebra, in replicability recursions relating $T_g(q)$ to
$T_{g^n}(q)$, in Hecke-type operators on the space of trace functions, or in
products indexed by subsets of conjugacy classes. Whatever the construction, the
result carries a pole of order exactly $m$, its leading coefficient is exactly
$1$, and if the target of the construction is required to be a hauptmodul (order
$-1$) or a holomorphic object (order $\ge 0$) then the construction is
*obliged* to correct by $q^{m}$ — and no other monomial will do (Theorem 4.1).
Because Theorem 4.4 says the corrected object is a unit, one may then invert it,
take its logarithm, or extract Newton-type invariants, all inside the group
$1 + q\mathbb{C}[\![q]\!]$.

Conversely, the obstruction is a quick falsifier. Any claimed identity asserting
that a product of $m \ge 2$ normalized series equals a normalized series, or a
power series, is false — regardless of the coefficients involved — because the
two sides sit in different fibres of a group homomorphism.

### 9.2 Scope and limitations

Three remarks delimit the result.

*The proof uses only that $\mathbb{C}$ is an integral domain.* Everything above
holds verbatim with $\mathbb{C}$ replaced by any integral domain $R$; over a ring
with zero divisors, Lemma 2.3 degrades to an inequality and the obstruction
becomes only a bound. The exactness of the pole order is precisely a
domain-theoretic phenomenon.

*The result is purely about the local behaviour at the cusp.* Nothing here uses
modularity, the invariance groups $\Gamma_0(n)+e,f,\dots$, or the genus-zero
property. It applies to any family of $q$-expansions with a simple monic pole,
which makes it robust but also means it cannot by itself distinguish moonshine
series from arbitrary series of the same shape. The strength of a purely
valuation-theoretic statement is exactly that it is insensitive to everything
else.

*The value group matters.* As stressed in §1.3, replacing $\mathbb{Z}\cup
\{\infty\}$ by $\mathbb{Z}$ with the convention $\operatorname{ord}(0) = 0$
makes the main theorem false for families that may contain $0$. The
$\mathbb{Z}$-valued statements in this paper are therefore always accompanied by
a non-vanishing hypothesis, which Corollary 3.2 supplies in the normalized case.

### 9.3 Conjecture: the Newton hierarchy at all levels

**Conjecture 9.1 (Newton hierarchy).** Let $f_i = q^{-1} + a_{i,0} + a_{i,1}q +
a_{i,2}q^2 + \cdots$, $i \in S$, $|S| = m$, be normalized. Then for every
$k \ge 0$ the Laurent coefficient of $\prod_i f_i$ at degree $k - m$ is a
universal polynomial with rational coefficients in the power sums
$p_r = \sum_i a_{i,n}$ — explicitly, the degree-$k$ part of
$\exp\!\big(\sum_{r \ge 1} (-1)^{r+1} p_r / r\big)$ applied to the logarithms of
the unit parts $U(f_i)$.

The key insight is that Corollary 5.2 reduces the question entirely to the
multiplicativity of $\prod_i U(f_i)$ inside $1 + q\mathbb{C}[\![q]\!]$, where the
formal logarithm is an isomorphism onto $q\mathbb{C}[\![q]\!]$, converting
products into sums of power sums. The conjecture is falsifiable in the strongest
sense: it predicts, for instance, the exact value of the constant coefficient in
the $m = 2$ case computed above, and a single mismatched truncated product would
refute it.

### 9.4 Conjecture: pole order detects the failure of the hauptmodul property

**Conjecture 9.2 (Pole order detects genus-zero failure).** Let $f$ be
normalized and let $H(f) \subseteq \mathbb{C}(\!(q)\!)$ be the
$\mathbb{C}$-subalgebra generated by $f$ and $q$. Then $H(f)$ contains an element
of every integer order, the induced map $H(f)^{\times} \to \mathbb{Z}$ is
surjective, and its kernel is exactly the units of $H(f)$ lying in
$1 + q\mathbb{C}[\![q]\!]$. Consequently no finite product of normalized series
can be a hauptmodul unless $m = 1$.

The key insight is that Theorem 3.4 already shows normalized series are closed
under multiplication only in the trivial case, so the "hauptmodul property" is an
order-$(-1)$ condition and the obstruction is exactly the image of the order
homomorphism (Theorem 6.2).

### 9.5 Further directions

* **Higher-order poles.** Replace "simple monic pole" by "pole of order $d$ with
  leading coefficient $\lambda$". Orders still add, so a product of $m$ such
  series has order $-\sum_i d_i$ and leading coefficient $\prod_i \lambda_i$; the
  correction monomial is $q^{\sum_i d_i}$ and the corrected series is a unit iff
  every $\lambda_i \ne 0$. The results here are the case $d_i = 1$,
  $\lambda_i = 1$.
* **Several variables and higher-rank valuations.** For Hahn series with value
  group $\Gamma$ an arbitrary ordered abelian group, Lemmas 2.3–2.4 hold
  unchanged; the obstruction becomes membership in a coset of the subgroup
  generated by the individual orders. This is the natural home for multivariable
  moonshine-type products.
* **Effective coefficient bounds.** Combining the factorization of Corollary 5.2
  with growth estimates on the $c_g(n)$ should yield explicit asymptotics for the
  coefficients of $q^{194}\Pi$, i.e. for the character-sum data of the full
  moonshine product.
* **The subgroup generated by the normalized series.** Since $\mathcal{N}$
  generates, under multiplication and inversion, a subgroup of
  $\mathbb{C}(\!(q)\!)^{\times}$ surjecting onto $\mathbb{Z}$ with kernel meeting
  $1 + q\mathbb{C}[\![q]\!]$, one may ask which unit power series arise as
  $\prod_i U(T_g)^{\pm 1}$ for moonshine data specifically — an arithmetic
  question about the multiplicative relations among McKay–Thompson series.

---

## 10. Conclusion

The class of normalized $q$-series — the shape shared by all $194$
McKay–Thompson series of the Monster — fails to be closed under multiplication,
and the failure is measured by a single integer, the pole order, with no slack
whatsoever. A product of $m$ such series has pole order exactly $m$ and leading
coefficient exactly $1$; it is normalized only when $m = 1$; it is never a power
series when $m \ge 1$; the unique monomial repairing it is $q^m$; and after the
repair the object is not merely regular but invertible. All of this flows from
one structural fact, the unique factorization of a normalized series as $q^{-1}$
times a principal unit power series, and from one structural reformulation, the
order as a surjective group homomorphism onto $\mathbb{Z}$ with disjoint fibres.
For the Monster the numbers are concrete and memorable: pole order $194$, unique
correction $q^{194}$, vanishing coefficient at $q^{-193}$, and character sum
$\sum_g c_g(1)$ at $q^{-192}$.
