# The Functional-Equation Sign of a Duality Eigensystem

### A complete determination of the root sign, its central-parity form, its structural properties, and its analytic avatar

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

Let $Q \neq 0$ be a scalar in a field $K$ and let $\alpha_1,\dots,\alpha_d \in K$ be a finite family equipped with an involution $\sigma$ of the index set satisfying $\alpha_i\alpha_{\sigma(i)} = Q^2$. We call such data a *duality eigensystem*; it axiomatises exactly the structure that Poincaré duality imposes on the middle-degree Frobenius eigenvalues of a smooth projective variety over a finite field, with $Q = q^{n/2}$.

We prove an exact sign law for the product of the eigenvalues,
$$\prod_{i=1}^d \alpha_i = (-1)^{\,\nu}\,Q^d, \qquad \nu := \#\{i : \sigma(i)=i,\ \alpha_i = -Q\},$$
and deduce that the characteristic polynomial $P(T) = \prod_i (1-\alpha_i T)$ satisfies the functional equation $(Q^2T)^d P\bigl((Q^2T)^{-1}\bigr) = \varepsilon\, Q^d P(T)$ with root sign $\varepsilon = (-1)^{d+\nu}$. We show the converse is sharp: over a field with $-1 \neq 1$, the identity $\prod\alpha_i = Q^d$ holds if and only if $\nu$ is even.

We then eliminate $\sigma$ from the answer, proving the *central parity law*
$$\varepsilon = (-1)^{m_+}, \qquad m_+ := \#\{i : \alpha_i = Q\},$$
and, via the factorisation $P(T) = (1-QT)^{m_+}G(T)$ with $G(Q^{-1}) \neq 0$, identifying $m_+$ as the exact order of vanishing of $P$ at the central point $T = Q^{-1}$. Consequently $\varepsilon = -1$ forces $P(Q^{-1}) = 0$.

We establish that $\varepsilon$ is a genuine invariant: it is valued in $\mu_2$, multiplicative under direct sums, and invariant under the rescaling $(Q,\alpha) \mapsto (cQ, c\alpha)$. In odd degree a self-dual eigenvalue necessarily exists, whence under the hypothesis $\nu = 0$ one has $\varepsilon = -1$ and central vanishing.

Finally we bridge to analysis. Writing $Q = e^L$ and substituting $T = e^{-sL}$, the completed function $\Lambda(s) = e^{(s-1)dL/2}P(e^{-sL})$ is entire and satisfies $\Lambda(2-s) = \varepsilon\,\Lambda(s)$; combined with an elementary Taylor-symmetry principle this yields
$$(-1)^{\operatorname{ord}_{s=1}\Lambda} = \varepsilon = (-1)^{m_+}.$$
An analytic order of vanishing is thereby computed by a finite eigenvalue count. Explicit witnesses in degrees $1$, $2$ and $4$, together with a fixed-point-free $3$-cycle exhibiting $\prod\alpha_i = -Q^3$, show that every hypothesis — in particular the involutivity of $\sigma$ — is load-bearing.

**Keywords:** functional equation, root number, Poincaré duality, Frobenius eigenvalues, parity conjecture, central vanishing, involution.

---

## 1. Introduction

### 1.1 The problem

For a smooth projective variety $X$ of dimension $n$ over $\mathbb{F}_q$, the zeta function factors as an alternating product of polynomials $P_i(T) = \det(1 - \mathrm{Frob}\,T \mid H^i)$, and the middle-degree factor
$$P(T) = \prod_{i=1}^{d}(1-\alpha_i T), \qquad |\alpha_i| = q^{n/2},$$
carries the essential arithmetic. Poincaré duality acts on the multiset $\{\alpha_i\}$ by $\alpha \mapsto q^n/\alpha$: concretely, there exists a permutation $\sigma$ of the index set with
$$\alpha_i\,\alpha_{\sigma(i)} = q^n = Q^2, \qquad Q := q^{n/2}.$$
Substituting $T \mapsto (Q^2T)^{-1}$ in $P$ produces a functional equation
$$(Q^2T)^d\,P\bigl((Q^2T)^{-1}\bigr) = \varepsilon\,Q^d\,P(T),$$
whose sign $\varepsilon = \pm1$ is the root number of the associated $L$-factor. By the parity philosophy, this sign governs the parity of the order of vanishing at the central point — and it is therefore the object of interest.

The organising question addressed here is:

> **When is $\prod_i \alpha_i$ exactly $Q^d$, with no sign correction — and what exactly is $\varepsilon$?**

### 1.2 Results

We answer this completely, in four layers.

1. **The sign law and its sharp converse** (§3). $\prod\alpha_i = (-1)^{\nu}Q^d$ with $\nu$ the number of $(-Q)$-carrying fixed points of $\sigma$; hence $\varepsilon = (-1)^{d+\nu}$. The conclusion $\prod \alpha_i = Q^d$ holds *iff* $\nu$ is even. In particular, forbidding $-Q$ at fixed points forces $\prod\alpha_i = Q^d$ and $\varepsilon = (-1)^d$.

2. **Central parity** (§4). The permutation is inessential: $\varepsilon = (-1)^{m_+}$ where $m_+$ is the multiplicity of $+Q$ in the eigenvalue list, which is the exact order of vanishing of $P$ at $T = Q^{-1}$. So *the sign of the functional equation is the parity of the central order of vanishing*, and $\varepsilon = -1$ implies $P(Q^{-1}) = 0$.

3. **Structure** (§5). $\varepsilon^2 = 1$; $\varepsilon$ is multiplicative under direct sums and invariant under rescaling; odd degree forces a self-dual eigenvalue, hence (under the hypothesis) $\varepsilon = -1$ and central vanishing.

4. **The analytic bridge** (§6). An exponential substitution converts the polynomial functional equation into $\Lambda(2-s) = \varepsilon\Lambda(s)$ for an entire completed function, and the parity of the analytic order of vanishing at $s=1$ equals $\varepsilon$.

Section 7 gives the sharpness witnesses; §8 discusses scope and applications; §9 lists open directions.

### 1.3 Honest scope

The object studied is an *axiomatised model*. It records exactly the duality structure the Weil conjectures supply — $\sigma$ an involution with $\alpha_i\alpha_{\sigma(i)} = Q^2$ — over an arbitrary field. Nothing about the *existence* of such systems for actual varieties, nor the Riemann-hypothesis bound $|\alpha_i| = q^{n/2}$, is used or claimed. The results are purely structural consequences of duality and hence apply verbatim to any cohomological setting with a perfect pairing into the Tate twist: étale cohomology of varieties over finite fields, rigid or crystalline cohomology, and self-dual Galois or motivic representations of arbitrary weight.

---

## 2. Definitions

Throughout, $K$ is a field and $\iota$ is a finite index set with $d := |\iota|$.

**Definition 2.1 (Duality eigensystem).** A *duality eigensystem* over $K$ on the index set $\iota$ consists of:
- a scalar $Q \in K$ with $Q \neq 0$ (the *half-weight*, modelling $q^{n/2}$);
- a family $\alpha : \iota \to K$ (the *eigenvalues*);
- a permutation $\sigma$ of $\iota$ (the *duality permutation*),

subject to two axioms:
- **(Involutivity)** $\sigma(\sigma(i)) = i$ for all $i$;
- **(Duality)** $\alpha_i \cdot \alpha_{\sigma(i)} = Q^2$ for all $i$.

We write $E = (Q,\alpha,\sigma)$ and call $d = |\iota|$ the *degree* of $E$ (the Betti number).

**Definition 2.2 (Anti-diagonal fixed points).** The *negative fixed set* is
$$\mathrm{NF}(E) := \{ i \in \iota : \sigma(i) = i \text{ and } \alpha_i = -Q\}, \qquad \nu := |\mathrm{NF}(E)|.$$

**Definition 2.3 (Central multiplicity).** The *central multiplicity* is
$$m_+ := \#\{ i \in \iota : \alpha_i = Q\}.$$

**Definition 2.4 (Characteristic polynomial).** $P_E(T) := \prod_{i \in \iota}(1 - \alpha_i T)$.

**Definition 2.5 (Root sign).** $\displaystyle \varepsilon(E) := \frac{(-1)^d \prod_{i}\alpha_i}{Q^d}$.

Definition 2.5 is not an arbitrary choice; Theorem 3.6 shows it is precisely the constant appearing in the duality functional equation.

**Remark 2.6.** The two axioms are independent in the strongest sense: Theorem 7.6 exhibits a bijective, fixed-point-free $\sigma$ satisfying Duality but not Involutivity, for which the main theorem's conclusion fails.

---

## 3. The sign law

### 3.1 Elementary consequences of duality

**Lemma 3.1 (No zero eigenvalue).** For every $i$, $\alpha_i \neq 0$.

*Proof.* If $\alpha_i = 0$ then Duality gives $0 = Q^2$, contradicting $Q \neq 0$. $\square$

**Lemma 3.2 (Fixed points are $\pm Q$).** If $\sigma(i) = i$, then $\alpha_i = Q$ or $\alpha_i = -Q$.

*Proof.* Duality at $i$ reads $\alpha_i^2 = Q^2$, so $(\alpha_i - Q)(\alpha_i + Q) = 0$, and $K$ is a field. $\square$

Geometrically, when $|\alpha_i| = Q$ these are exactly the two *real* points of the circle of radius $Q$: the two eigenvalues which are their own duality partners.

**Lemma 3.3 (The failed naive route).** Multiplying Duality over all $i$ and using that $\sigma$ is a bijection gives $\bigl(\prod_i \alpha_i\bigr)^2 = Q^{2d}$, hence $\prod_i \alpha_i = \pm Q^d$.

This one-line argument determines the product up to sign only — precisely the information at stake. Breaking the ambiguity requires the pairing argument below, and, crucially, involutivity.

### 3.2 Cancellation over two-cycles

**Definition 3.4.** Set
$$\beta_i := \begin{cases} 1 & \text{if } \sigma(i) = i,\\[2pt] \alpha_i / Q & \text{otherwise.}\end{cases}$$

**Lemma 3.5 (Pairing cancellation).** $\displaystyle \prod_{i \in \iota} \beta_i = 1$.

*Proof.* Apply the involution-pairing principle for products: $\sigma$ maps $\iota$ to itself, is involutive, and for each $i$ with $\sigma(i) \neq i$ we have $\beta_i\,\beta_{\sigma(i)} = (\alpha_i/Q)(\alpha_{\sigma(i)}/Q) = Q^2/Q^2 = 1$ by Duality, while for each fixed $i$ we have $\beta_i = 1$. Thus $\beta$ is a function whose value at $i$ times its value at $\sigma(i)$ is $1$ on every orbit, and which is $1$ at every fixed point; the total product is therefore $1$. $\square$

This lemma is the heart of the matter: **duality two-cycles are sign-neutral**, whatever their eigenvalues.

### 3.3 The exact sign law

**Theorem 3.6 (Duality sign law).** For every duality eigensystem $E$,
$$\prod_{i \in \iota} \alpha_i \;=\; (-1)^{\nu}\,Q^{d}, \qquad \nu = |\mathrm{NF}(E)|.$$

*Proof.* We claim that for every $i$,
$$\alpha_i = \bigl(Q\,\beta_i\bigr)\cdot\begin{cases}-1 & i \in \mathrm{NF}(E)\\ \phantom{-}1 & \text{otherwise.}\end{cases}$$
Indeed, if $\sigma(i) \neq i$ then $\beta_i = \alpha_i/Q$ and $i \notin \mathrm{NF}(E)$, giving $Q\beta_i = \alpha_i$. If $\sigma(i) = i$ then $\beta_i = 1$ and, by Lemma 3.2, either $\alpha_i = Q$ (and $i \notin \mathrm{NF}$, so the claim reads $\alpha_i = Q$) or $\alpha_i = -Q$ (and $i \in \mathrm{NF}$, so the claim reads $\alpha_i = -Q$). Taking the product over $i$ and splitting the two factors,
$$\prod_i \alpha_i = \Bigl(Q^d \prod_i \beta_i\Bigr)\cdot(-1)^{\nu} = (-1)^{\nu} Q^d$$
by Lemma 3.5. $\square$

**Corollary 3.7 (The conjecture, proved).** If $\sigma(i) = i \implies \alpha_i \neq -Q$ for all $i$, then $\prod_i \alpha_i = Q^d$.

*Proof.* The hypothesis says $\mathrm{NF}(E) = \varnothing$, so $\nu = 0$. $\square$

**Theorem 3.8 (Sharp converse).** Suppose $-1 \neq 1$ in $K$. Then
$$\prod_i \alpha_i = Q^d \iff \nu \text{ is even}.$$

*Proof.* By Theorem 3.6, $\prod\alpha_i = (-1)^\nu Q^d$, and $Q^d \neq 0$. If $\nu$ is even then $(-1)^\nu = 1$. Conversely if $\nu$ is odd, $(-1)^\nu = -1$, and $-Q^d = Q^d$ would give $-1 = 1$ after cancelling the unit $Q^d$. $\square$

Thus the hypothesis of Corollary 3.7 is *sufficient but not necessary*; the genuine invariant is a $\mathbb{Z}/2$ count of anti-diagonal fixed points, a Lefschetz-style statement. The hypothesis $-1 \neq 1$ is necessary: in characteristic $2$ the sign question is empty.

### 3.4 The functional equation

**Theorem 3.9 (Duality functional equation).** For every $T \neq 0$,
$$(Q^2T)^d\,P_E\bigl((Q^2T)^{-1}\bigr) \;=\; (-1)^d\Bigl(\prod_i \alpha_i\Bigr) P_E(T).$$

*Proof.* For each $i$,
$$(Q^2T)\bigl(1 - \alpha_i (Q^2T)^{-1}\bigr) = Q^2T - \alpha_i = -\alpha_i\Bigl(1 - \tfrac{Q^2}{\alpha_i}T\Bigr) = -\alpha_i\bigl(1 - \alpha_{\sigma(i)}T\bigr),$$
using Lemma 3.1 and Duality. Taking the product over $i$, distributing the $d$ copies of $Q^2T$, and using that $\sigma$ is a bijection (so $\prod_i (1-\alpha_{\sigma(i)}T) = \prod_i(1-\alpha_i T) = P_E(T)$), the claim follows, since $\prod_i(-\alpha_i) = (-1)^d\prod_i \alpha_i$. $\square$

Note that this theorem uses only that $\sigma$ is a *bijection* with $\alpha_i\alpha_{\sigma(i)} = Q^2$; involutivity is not needed here. It is needed in Theorem 3.6, which evaluates the resulting constant.

**Corollary 3.10 (Normalised form).** For $T \neq 0$,
$$(Q^2T)^d\,P_E\bigl((Q^2T)^{-1}\bigr) = \varepsilon(E)\cdot Q^d \cdot P_E(T).$$

**Theorem 3.11 (Closed formula for the sign).** $\varepsilon(E) = (-1)^{\,d + \nu}$.

*Proof.* Immediate from Definition 2.5 and Theorem 3.6. $\square$

**Corollary 3.12.** If $\sigma$ has no $-Q$ fixed point, $\varepsilon(E) = (-1)^d$, and the functional equation reads $(Q^2T)^dP\bigl((Q^2T)^{-1}\bigr) = (-1)^dQ^dP(T)$.

---

## 4. Central parity: eliminating the permutation

The formula $\varepsilon = (-1)^{d+\nu}$ refers to $\sigma$, which is auxiliary data; the multiset $\{\alpha_i\}$ is intrinsic. We now show $\varepsilon$ depends on the multiset alone.

### 4.1 The combinatorial engine

**Lemma 4.1 (Free involutions have even orbit count).** Let $g$ be an involution of a set, and $S$ a finite subset with $g(S) \subseteq S$ and $g(a) \neq a$ for all $a \in S$. Then $|S|$ is even.

*Proof.* Evaluate $\prod_{a\in S}(-1)$ by pairing $a$ with $g(a)$: each two-element orbit contributes $(-1)(-1) = 1$, and there are no fixed points, so the product is $1$. But the product is also $(-1)^{|S|}$. Hence $(-1)^{|S|} = 1$ and $|S|$ is even. $\square$

**Lemma 4.2 (Duality-stability of the central set).** If $\alpha_i = Q$ then $\alpha_{\sigma(i)} = Q$.

*Proof.* Duality gives $Q\,\alpha_{\sigma(i)} = Q^2$; divide by $Q \neq 0$. $\square$

**Lemma 4.3.** Both $\{i : \sigma(i)\neq i\}$ and $\{i : \sigma(i) \neq i \text{ and } \alpha_i = Q\}$ have even cardinality.

*Proof.* Apply Lemma 4.1 with $g = \sigma$. For the first set, $\sigma$ maps non-fixed indices to non-fixed indices (if $\sigma(\sigma(i)) = \sigma(i)$ then applying $\sigma$ and involutivity gives $\sigma(i) = i$) and has no fixed points there. For the second, additionally use Lemma 4.2 to see that the set is $\sigma$-stable. $\square$

### 4.2 The parity bridge

**Proposition 4.4 (Counting bridge).** If $-1 \neq 1$ in $K$, then
$$d + \nu + m_+ \text{ is even, i.e.}\quad d + \nu \equiv m_+ \pmod 2 .$$

*Proof.* First, $Q \neq -Q$: otherwise $2Q = 0$, and since $Q \neq 0$ this forces $2 = 0$, i.e. $-1 = 1$. Consequently, by Lemma 3.2, a fixed index has $\alpha_i = -Q$ if and only if $\alpha_i \neq Q$; hence
$$\mathrm{NF}(E) = \{i : \sigma(i) = i \text{ and } \alpha_i \neq Q\}.$$
Write $F := \{i:\sigma(i)=i\}$, $R := \{i : \sigma(i)\neq i\}$, $F_+ := \{i \in F : \alpha_i = Q\}$, $R_+ := \{i\in R:\alpha_i = Q\}$. Then
$$d = |F| + |R|, \qquad |F| = |F_+| + \nu, \qquad m_+ = |F_+| + |R_+|.$$
Therefore
$$d + \nu + m_+ = |F_+| + \nu + |R| + \nu + |F_+| + |R_+| = 2|F_+| + 2\nu + |R| + |R_+|,$$
which is even because $|R|$ and $|R_+|$ are even by Lemma 4.3. $\square$

**Theorem 4.5 (Central parity law).** If $-1 \neq 1$ in $K$, then
$$\varepsilon(E) = (-1)^{m_+}.$$

*Proof.* By Theorem 3.11, $\varepsilon = (-1)^{d+\nu}$, and by Proposition 4.4, $d+\nu \equiv m_+ \pmod 2$; powers of $-1$ with exponents of equal parity agree. $\square$

The duality permutation has disappeared: only the multiset of eigenvalues matters.

### 4.3 Order of vanishing at the central point

**Definition 4.6.** $G_E(T) := \prod_{\alpha_i \neq Q}(1 - \alpha_i T)$, the *non-central factor*.

**Proposition 4.7 (Central factorisation).** $P_E(T) = (1 - QT)^{m_+}\,G_E(T)$ for all $T$.

*Proof.* Split the product $\prod_i(1-\alpha_iT)$ over $\{\alpha_i = Q\}$ and its complement. On the first set every factor equals $1-QT$, and there are $m_+$ of them. $\square$

**Proposition 4.8 (Exactness).** $G_E(Q^{-1}) \neq 0$.

*Proof.* A factor $1 - \alpha_i Q^{-1}$ vanishes iff $\alpha_i = Q$, which is excluded on the index set of $G_E$. A product of nonzero elements of a field is nonzero. $\square$

Thus **$m_+$ is exactly the order of vanishing of $P_E$ at the central point $T = Q^{-1}$**, and Theorem 4.5 reads:

> The sign of the functional equation is $(-1)^{\text{order of vanishing at the centre}}$.

**Theorem 4.9 (Parity criterion).** If $-1 \neq 1$ in $K$, then $\varepsilon(E) = -1 \iff m_+$ is odd.

*Proof.* Immediate from Theorem 4.5, using $-1 \neq 1$ to distinguish the two values. $\square$

**Corollary 4.10 (Sign $-1$ forces central vanishing).** If $-1 \neq 1$ and $\varepsilon(E) = -1$, then $P_E(Q^{-1}) = 0$.

*Proof.* By Theorem 4.9, $m_+$ is odd, hence positive; by Proposition 4.7, $P_E(Q^{-1}) = (1-QQ^{-1})^{m_+}G_E(Q^{-1}) = 0^{m_+}\,G_E(Q^{-1}) = 0$. $\square$

**Corollary 4.11.** If $-1 \neq 1$ and $\sigma$ has no $-Q$ fixed point, then $(-1)^{m_+} = (-1)^d$: the central order of vanishing has the parity of the degree.

---

## 5. Structural properties: $\varepsilon$ as an invariant

We now verify that $\varepsilon$ behaves as a root number should, which is what distinguishes an invariant from a formula.

**Theorem 5.1 ($\mu_2$-valued).** $\varepsilon(E)^2 = 1$ for every duality eigensystem.

*Proof.* $\varepsilon = (-1)^{d+\nu}$ by Theorem 3.11, and $\bigl((-1)^{k}\bigr)^2 = \bigl((-1)^2\bigr)^k = 1$. $\square$

**Definition 5.2 (Direct sum).** Given eigensystems $E$ on $\iota$ and $F$ on $\iota'$ with the same half-weight $Q$, define $E \oplus F$ on the disjoint union $\iota \sqcup \iota'$ by concatenating the eigenvalue families and letting the duality permutation act blockwise. The axioms are inherited componentwise.

The requirement of equal $Q$ is essential: eigensystems of different weights cannot be summed — that would be a *graded*, not a direct, sum (see §9.1).

**Proposition 5.3.** $\deg(E\oplus F) = \deg E + \deg F$; $P_{E\oplus F}(T) = P_E(T)P_F(T)$; $\prod_{E\oplus F}\alpha = \bigl(\prod_E\alpha\bigr)\bigl(\prod_F\alpha\bigr)$; and $m_+(E\oplus F) = m_+(E) + m_+(F)$.

*Proof.* Each statement is the corresponding product or sum over a disjoint union, split into its two blocks. $\square$

**Theorem 5.4 (Multiplicativity).** $\varepsilon(E \oplus F) = \varepsilon(E)\,\varepsilon(F)$.

*Proof.* By Definition 2.5 and Proposition 5.3,
$$\varepsilon(E\oplus F) = \frac{(-1)^{d_E+d_F}\bigl(\prod_E\alpha\bigr)\bigl(\prod_F\alpha\bigr)}{Q^{d_E+d_F}} = \frac{(-1)^{d_E}\prod_E\alpha}{Q^{d_E}}\cdot\frac{(-1)^{d_F}\prod_F\alpha}{Q^{d_F}}. \qquad\square$$

So $E \mapsto \varepsilon(E)$ is a monoid homomorphism from the additive monoid of duality eigensystems of fixed weight into $\mu_2$ — the model's shadow of the multiplicativity of root numbers in the Grothendieck group of Galois representations. The hypothesis "no $-Q$ fixed point" is likewise stable under direct sums.

**Definition 5.5 (Twist).** For $c \neq 0$, the *twist* $E^{(c)}$ has half-weight $cQ$, eigenvalues $c\alpha_i$, and the same $\sigma$. Duality holds since $(c\alpha_i)(c\alpha_{\sigma(i)}) = c^2Q^2 = (cQ)^2$.

**Theorem 5.6 (Twist invariance).** $\varepsilon(E^{(c)}) = \varepsilon(E)$ for every $c \neq 0$.

*Proof.* $\prod_i(c\alpha_i) = c^d\prod_i\alpha_i$ and $(cQ)^d = c^dQ^d$; the factors $c^d$ cancel in Definition 2.5. $\square$

Hence $\varepsilon$ depends only on the *normalised* eigenvalues $\alpha_i/Q$ — precisely the invariance one demands of an arithmetic quantity under a change of normalisation or a Tate twist.

**Theorem 5.7 (Odd degree forces a self-dual eigenvalue).** If $d$ is odd, then $\sigma$ has a fixed point.

*Proof.* If not, $\iota$ itself is the set of non-fixed indices, which is even by Lemma 4.3 — contradicting $d$ odd. $\square$

**Theorem 5.8 (Odd degree, no $-Q$: sign $-1$).** If $\sigma$ has no $-Q$ fixed point and $d$ is odd, then $\varepsilon(E) = -1$.

*Proof.* By Corollary 3.12, $\varepsilon = (-1)^d = -1$. $\square$

**Corollary 5.9 (Odd degree forces central vanishing).** If in addition $-1 \neq 1$ in $K$, then $P_E(Q^{-1}) = 0$.

*Proof.* Combine Theorem 5.8 with Corollary 4.10. $\square$

This is the model's counterpart of "root number $-1$ implies the central value vanishes", now a theorem rather than a conjecture. Note the mechanism: odd degree forces a fixed point (Theorem 5.7); the hypothesis forces that fixed point to carry $+Q$; hence $m_+ \geq 1$ and, by Corollary 4.11, $m_+$ is odd.

---

## 6. The analytic bridge

Everything so far is polynomial algebra over an arbitrary field. We now take $K = \mathbb{C}$ and convert the polynomial functional equation into an analytic one, so that the parity statement becomes a statement about orders of vanishing of an entire function.

### 6.1 The analytic parity principle

**Theorem 6.1 (Taylor symmetry).** Let $\Lambda$ be analytic at $s = 1$, not identically zero in any neighbourhood of $1$, and suppose $\Lambda(2-s) = w\,\Lambda(s)$ for all $s$ near $1$, with $w$ a constant. Let $r := \operatorname{ord}_{s=1}\Lambda$ be the order of vanishing. Then
$$(-1)^{r} = w.$$

*Proof sketch.* Write $\Lambda(1+u) = \sum_{k\ge0}c_k u^k$ near $u = 0$; the hypothesis of non-local-vanishing says some $c_k \neq 0$, and $r$ is the least such index. Substituting $s = 1+u$ turns the functional equation into $\Lambda(1-u) = w\,\Lambda(1+u)$, i.e. $\sum_k c_k(-1)^ku^k = w\sum_k c_ku^k$. Comparing coefficients, $(-1)^kc_k = wc_k$ for all $k$; taking $k = r$ and dividing by $c_r \neq 0$ gives $(-1)^r = w$. $\square$

(Incidentally $w^2 = 1$ follows, by applying the functional equation twice.)

### 6.2 The completed function

Fix a complex logarithm $L$ of the half-weight, i.e. $e^L = Q$; such an $L$ exists since $Q \neq 0$.

**Definition 6.2 (Completed function).**
$$\Lambda_E(s) := \exp\!\Bigl(\tfrac{(s-1)d}{2}L\Bigr)\cdot P_E\bigl(e^{-sL}\bigr).$$

The substitution $T = e^{-sL}$ carries the duality substitution $T \mapsto (Q^2T)^{-1}$ to the reflection $s \mapsto 2-s$: indeed $Q^2 e^{-sL} = e^{(2-s)L}$, so $(Q^2 T)^{-1} = e^{-(2-s)L}$. The central point $T = Q^{-1}$ corresponds to $s = 1$. The exponential prefactor is the model's analogue of the conductor factor $N^{s/2}$ in the completed Hasse–Weil $L$-function.

**Proposition 6.3 (Entirety).** $\Lambda_E$ is entire.

*Proof.* $s \mapsto e^{-sL}$ is entire, $P_E$ is a polynomial, and the prefactor is entire; products and compositions of entire functions are entire. $\square$

**Theorem 6.4 (Analytic functional equation).** For every $s \in \mathbb{C}$,
$$\Lambda_E(2-s) = \varepsilon(E)\cdot\Lambda_E(s).$$

*Proof.* Put $T := e^{-sL}$, which is nonzero since $\exp$ never vanishes. As noted, $Q^2T = e^{(2-s)L}$, hence $(Q^2T)^{-1} = e^{-(2-s)L}$, $(Q^2T)^d = e^{(2-s)Ld}$, and $Q^d = e^{Ld}$. Corollary 3.10 applied at $T$ therefore reads
$$e^{(2-s)Ld}\,P_E\bigl(e^{-(2-s)L}\bigr) = \varepsilon\, e^{Ld}\,P_E(T).$$
Dividing by the nonvanishing factor $e^{(2-s)Ld}$,
$$P_E\bigl(e^{-(2-s)L}\bigr) = \varepsilon\, e^{Ld}\,e^{-(2-s)Ld}\,P_E(T).$$
Now
$$\Lambda_E(2-s) = e^{\frac{(1-s)d}{2}L}\,P_E\bigl(e^{-(2-s)L}\bigr) = \varepsilon\;e^{\left(\frac{(1-s)d}{2} + d - (2-s)d\right)L}\,P_E(T),$$
and the exponent bookkeeping is
$$\frac{(1-s)d}{2} + d - (2-s)d = \frac{(s-1)d}{2},$$
so the right-hand side is exactly $\varepsilon\,\Lambda_E(s)$. $\square$

**Remark 6.5 (Independence of the branch).** The logarithm $L$ is a choice; any $L' = L + 2\pi i k$ also satisfies $e^{L'} = Q$. Theorem 6.4 holds verbatim for the corresponding $\Lambda_E'$, with the *same* constant $\varepsilon(E)$, since $\varepsilon(E)$ is defined without reference to $L$. Consequently Theorem 6.6 gives the same parity for every branch: the conclusion is independent of the choice. Nothing requires $Q$ to be real or positive, so the bridge applies to any weight.

### 6.3 The parity theorem

**Theorem 6.6 (Analytic parity for a duality eigensystem).** Suppose $\Lambda_E$ is not identically zero near $s=1$, and set $r := \operatorname{ord}_{s=1}\Lambda_E$. Then
$$(-1)^{r} = \varepsilon(E).$$

*Proof.* Combine Theorem 6.4 with Theorem 6.1, applied with $w = \varepsilon(E)$; the analyticity hypothesis holds by Proposition 6.3. $\square$

**Theorem 6.7 (Analytic rank $\equiv$ central multiplicity).** Under the hypotheses of Theorem 6.6,
$$(-1)^{r} = (-1)^{m_+}.$$

*Proof.* Theorem 6.6 followed by Theorem 4.5 (over $\mathbb{C}$, $-1 \neq 1$). $\square$

**Theorem 6.8 (Under the no-$(-Q)$ hypothesis).** If moreover no fixed point of $\sigma$ carries $\alpha = -Q$, then
$$(-1)^{r} = (-1)^{d}.$$
In particular, odd-dimensional middle cohomology forces the completed function to vanish at the central point.

*Proof.* Theorem 6.6 followed by Corollary 3.12. $\square$

**Proposition 6.9 (Discharging the non-degeneracy hypothesis).** If $P_E\bigl(e^{-s_0L}\bigr) \neq 0$ for some $s_0$, then $\Lambda_E(s_0) \neq 0$, so $\Lambda_E$ is not the zero function and its order of vanishing at $s=1$ is finite.

*Proof.* $\Lambda_E(s_0)$ is a product of a nonzero exponential and $P_E(e^{-s_0L})$. $\square$

In practice this is automatic: a nonzero polynomial has finitely many roots, and $s \mapsto e^{-sL}$ has dense image in $\mathbb{C}^\times$ (indeed it is surjective onto $\mathbb{C}^\times$ when $L \neq 0$), so $P_E(e^{-sL})$ is nonzero for some $s$ unless $P_E$ is the zero polynomial — which it is not, since $P_E(0) = 1$.

Theorem 6.7 is the culmination: an *analytic* invariant, the order of vanishing of a transcendental function at a point, is computed modulo $2$ by a *finite count* of Frobenius eigenvalues. The finite-field combinatorics and the archimedean Taylor symmetry are two computations of the same element of $\mathbb{Z}/2$.

---

## 7. Sharpness: explicit witnesses

All witnesses below are over $\mathbb{C}$, with $Q \neq 0$ arbitrary.

**Theorem 7.1 (Degree 1, positive fixed point).** Let $d=1$, $\sigma = \mathrm{id}$, $\alpha_1 = Q$. Then the no-$(-Q)$ hypothesis holds, $\prod\alpha = Q$, and $\varepsilon = (-1)^1 = -1$ — the value predicted by Corollary 3.12.

**Theorem 7.2 (Degree 1, negative fixed point — the sign flip).** Let $d=1$, $\sigma = \mathrm{id}$, $\alpha_1 = -Q$. Then
$$\prod\alpha = -Q \neq Q^1, \qquad \varepsilon = +1 \neq (-1)^1 .$$
Hence the hypothesis of Corollary 3.7 cannot be deleted: *a single* anti-diagonal fixed point flips the sign.

**Theorem 7.3 (Degree 2, a free duality pair — sign-neutrality).** Let $d = 2$, $\sigma$ the transposition, $\alpha = (a, Q^2/a)$ for any $a \neq 0$. Then $\prod\alpha = Q^2$ and $\varepsilon = +1 = (-1)^2$, for every $a$. There are no fixed points, so the hypothesis holds vacuously. Two-cycles never contribute to the sign, whatever their eigenvalues.

**Theorem 7.4 (Degree 2, two negative fixed points — sufficient but not necessary).** Let $d=2$, $\sigma = \mathrm{id}$, $\alpha_1 = \alpha_2 = -Q$. Then $\nu = 2$, the hypothesis of Corollary 3.7 fails at *every* index, yet
$$\prod\alpha = Q^2, \qquad \varepsilon = +1 = (-1)^2 .$$
Two anti-diagonal fixed points cancel, in accordance with Theorem 3.8. The hypothesis is sufficient but not necessary.

**Theorem 7.5 (Degree 4).** (i) With $\sigma$ a product of two transpositions and $\alpha = (a, Q^2/a, b, Q^2/b)$, $a,b\neq0$: $\prod\alpha = Q^4$ and $\varepsilon = +1 = (-1)^4$. (ii) With $\sigma$ the transposition of the last two indices and $\alpha = (Q, -Q, a, Q^2/a)$: $\prod\alpha = -Q^4$ and $\varepsilon = -1 \neq (-1)^4$. So the sign is genuinely a function of the fixed-point data, not of the degree alone.

**Theorem 7.6 (Involutivity is essential).** Let $\iota = \{0,1,2\}$, let $\sigma$ be the $3$-cycle $i \mapsto i+1 \pmod 3$, and let $\alpha_i = -Q$ for all $i$. Then:
- $\sigma$ is a bijection and Duality holds: $\alpha_i\alpha_{\sigma(i)} = (-Q)(-Q) = Q^2$;
- $\sigma$ has **no fixed point whatsoever**, so the hypothesis "no $-Q$ fixed point" holds vacuously;
- $\sigma$ is **not** an involution;
- $\prod_i \alpha_i = -Q^3 \neq Q^3$, and correspondingly the functional-equation constant is $(-1)^{d+1}$, not $(-1)^d$.

Hence the axiom $\sigma\circ\sigma = \mathrm{id}$ cannot be weakened to "$\sigma$ is a bijection". It is exactly what the pairing argument of Lemma 3.5 consumes.

*Remark on the shape of this witness.* It is not an accident. Chasing $\alpha_i\alpha_{\sigma(i)} = Q^2$ around a $3$-cycle gives $\alpha_0\alpha_1 = \alpha_1\alpha_2 = \alpha_2\alpha_0 = Q^2$; the first two force $\alpha_0 = \alpha_2$, and then the third forces $\alpha_0^2 = Q^2$, so the cycle is constant $\pm Q$. The choice $-Q$ gives the counterexample and the choice $+Q$ the trivial case; there is no third possibility.

**Remark 7.7 (Completeness of the degree $\leq 4$ analysis).** Since $\varepsilon$ depends only on $d$ and the fixed-point data (Theorem 3.11), degree $4$ already exhibits every combinatorial pattern of an involution: four fixed points, two fixed points plus one two-cycle, and two two-cycles. All conform to $\varepsilon = (-1)^{d+\nu}$.

---

## 8. Discussion and applications

### 8.1 What is actually being asserted

The essential content can be phrased in one sentence: *for a multiset of scalars stable under the reflection $\alpha \mapsto Q^2/\alpha$, the functional-equation sign is determined entirely by the fixed points of that reflection, and there only by their parity.* All the complexity of a generic eigenvalue — its argument, its position on the Weil circle — is invisible to the sign, because reflection pairs it with an exact reciprocal.

This is why parity statements are so much more tractable than the exact-order statements they shadow. The full Birch–Swinnerton-Dyer conjecture asks for a number; parity asks only for a bit, and that bit is protected by a symmetry rigid enough to be computed exactly.

### 8.2 Computational content

The sign law yields an algorithm of striking simplicity. Given the eigenvalue list and the half-weight, the root sign is computed by:

1. counting the multiplicity $m_+$ of $Q$ in the list, and
2. returning $(-1)^{m_+}$.

This runs in $O(d)$ operations and requires *no knowledge of $\sigma$*. It is the computational face of Theorem 4.5. An equally cheap consistency check is available: form $\prod_i \alpha_i$ and verify that it equals $\pm Q^d$ (Lemma 3.3) and that the sign agrees with $(-1)^{m_+ + d}$ (Theorems 3.11 and 4.5).

If instead one is given $\sigma$, one can compute the sign as $(-1)^{d + \nu}$; the agreement of the two computations is a nontrivial verification of the duality structure and detects, for example, non-involutive $\sigma$ (Theorem 7.6).

### 8.3 Relations to classical statements

The results transcribe as follows.

- **Root numbers.** $\varepsilon$ is the model's root number: $\mu_2$-valued (Theorem 5.1), multiplicative (Theorem 5.4), twist-invariant (Theorem 5.6). These are precisely the axioms one expects of $\varepsilon$-factors in the Langlands-theoretic setting.
- **Parity conjecture.** Theorem 4.9 and Corollary 4.10 are the exact statement "$\varepsilon = -1 \Rightarrow$ central vanishing, and $\varepsilon = (-1)^{\text{ord}}$", proved here rather than conjectured.
- **Odd rank.** Corollary 5.9 says odd-dimensional middle cohomology (under the no-$(-Q)$ hypothesis) forces the zeta factor to vanish centrally — the analogue of the guarantee of a point of infinite order when the root number is $-1$.
- **Archimedean/finite-field duality.** Theorem 6.7 shows that the archimedean Taylor-symmetry computation of parity and the finite-field fixed-point count of parity are literally the same $\mathbb{Z}/2$ element.

### 8.4 Limits of the model

Three limits deserve emphasis. First, nothing here proves the *existence* of duality eigensystems for a given variety — that is the content of the Weil conjectures, taken as input. Second, the Riemann-hypothesis bound $|\alpha_i| = q^{n/2}$ is never used; imposing it constrains which sign patterns can occur (see §9.2) but is not needed for the sign law. Third, the model treats a single self-paired block; a real variety has a graded family of blocks paired across the middle (see §9.1).

---

## 9. Future directions

### 9.1 Graded duality and the global zeta functional equation

**Conjecture.** Let $H^0,\dots,H^{2n}$ be duality eigensystems in which Poincaré duality pairs $H^i$ with $H^{2n-i}$ (rather than a single self-paired block), with weights $|\alpha| = q^{i/2}$. Then the global zeta function $Z(T) = \prod_i P_i(T)^{(-1)^{i+1}}$ satisfies
$$Z\bigl(1/(q^nT)\bigr) = \pm\,q^{n\chi/2}T^{\chi}Z(T), \qquad \chi = \sum_i(-1)^ib_i,$$
and the sign is $(-1)^{m_+(n)}$: it is carried **entirely by the middle cohomology**.

The key insight is that off-middle degrees are paired with a *different* block, so their contribution to the sign telescopes, and only the self-paired middle block can produce a fixed point. The proof of Theorem 3.6 already isolates the sign in the fixed-point set of the pairing, and Theorem 5.4 shows how blocks compose; a graded structure is the natural next object.

### 9.2 Weight-constrained rigidity: which sign patterns are realisable?

**Conjecture.** Impose the Riemann-hypothesis bound $|\alpha_i| = Q$ with $Q > 0$ real. Then duality is *forced*: $\sigma$ can be taken to be complex conjugation, every fixed point is real, $m_+ + m_- \equiv d \pmod 2$, and $\varepsilon = (-1)^{m_+}$ with $m_+ + m_-$ equal to the number of *real* eigenvalues. Consequently the number of admissible sign patterns in degree $d$ is exactly $\lfloor d/2\rfloor + 1$.

The key insight is that the Riemann-hypothesis bound turns the abstract duality permutation into the canonical involution $\alpha \mapsto Q^2/\alpha = \overline{\alpha}$, converting a combinatorial hypothesis into a topological one. The model deliberately omits the archimedean bound, so this is exactly the missing constraint.

### 9.3 Further directions

- **Higher $\mu_n$ analogues.** Replace the involution by an order-$k$ symmetry $\alpha \mapsto \zeta Q^2/\alpha$ and ask for the resulting $\mu_k$-valued invariant; the $3$-cycle witness of Theorem 7.6 suggests that non-involutive symmetries produce genuinely new phenomena rather than degenerate ones.
- **Families and rigidity.** In a family of eigensystems varying algebraically, $\varepsilon$ is locally constant by Theorem 5.6 and the discreteness of $\mu_2$; identifying the loci where it jumps is a question about the collision of an eigenvalue with $\pm Q$.
- **Effective bounds on $m_+$.** Theorem 4.9 makes the parity of $m_+$ computable; bounding $m_+$ itself, given only point counts over finitely many extensions $\mathbb{F}_{q^r}$, would upgrade a parity statement to a rank bound.
- **Non-field coefficients.** The sign law's proof uses only that $Q$ is a unit and that $K$ has no zero divisors in the relevant places; extending the theory to eigensystems over integral domains or over $\mathbb{Z}_\ell$ would connect it to integral structures on cohomology.

---

## 10. Summary of principal results

| Result | Statement |
|---|---|
| Duality sign law | $\prod_i\alpha_i = (-1)^{\nu}Q^d$, $\nu = \#\{-Q\text{-fixed points}\}$ |
| Sharp converse | $\prod_i\alpha_i = Q^d \iff \nu$ even (when $-1 \neq 1$) |
| Functional equation | $(Q^2T)^dP\bigl((Q^2T)^{-1}\bigr) = \varepsilon Q^dP(T)$, $\varepsilon = (-1)^{d+\nu}$ |
| Central parity law | $\varepsilon = (-1)^{m_+}$, $m_+ = \#\{i:\alpha_i = Q\}$ |
| Central factorisation | $P(T) = (1-QT)^{m_+}G(T)$, $G(Q^{-1})\neq0$ |
| Central vanishing | $\varepsilon = -1 \Rightarrow P(Q^{-1}) = 0$ |
| Structure | $\varepsilon^2=1$; $\varepsilon(E\oplus F) = \varepsilon(E)\varepsilon(F)$; twist-invariance |
| Odd degree | $d$ odd $\Rightarrow$ a self-dual eigenvalue exists; with $\nu=0$, $\varepsilon=-1$ and $P(Q^{-1})=0$ |
| Analytic bridge | $\Lambda(s) = e^{(s-1)dL/2}P(e^{-sL})$ entire, $\Lambda(2-s) = \varepsilon\Lambda(s)$ |
| Analytic parity | $(-1)^{\operatorname{ord}_{s=1}\Lambda} = \varepsilon = (-1)^{m_+}$ |
| Sharpness | Single $-Q$ fixed point flips the sign; two cancel; a non-involutive $3$-cycle with no fixed points has $\prod\alpha = -Q^3$ |
