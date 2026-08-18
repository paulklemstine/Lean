# Renormalized Factorization of Normalized Series: Realizability, Rigidity, and Positivity

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

Let $K$ be a field and let $K(\!(q)\!)$ denote the field of formal Laurent series in a uniformizer $q$, equipped with its order (valuation) map $\operatorname{ord}$. Call a series *normalized* when it has a simple pole, $\operatorname{ord} f = -1$, and define the *renormalized product* of a family $f_0,\dots,f_{m-1}$ to be $q^m \prod_{i<m} f_i$. We prove that for every $m \ge 1$ the image of the renormalized product map, restricted to normalized families, is **exactly** the order-zero locus: the total pole order is the only obstruction to such a factorization. We then determine the fibres of this map completely. For $m = 1$ the factorization is unique; for every $m \ge 2$ and every realizable target the fibre is infinite, over every field, including $\mathbb{F}_2$, where no scalar rescaling is available. The fibre is a torsor under the group of order-zero twists, and this group is free of rank $m - 1$; we call $m-1$ the *rigidity index*.

Four extensions sharpen the picture. (i) *Gauge invariance*: allowing an arbitrary integer pole profile $d$ and an arbitrary renormalization $q^k$, the realizable set is exactly $\{\,g : \operatorname{ord} g = k + \sum_{i<m} d_i\,\}$; two profiles with equal total have identical realizable sets and explicitly equinumerous fibres, via the monomial gauge transformation $f_i \mapsto f_i \, q^{\,d_i' - d_i}$. (ii) *Structure*: realizability and non-uniqueness are the two halves of a split short exact sequence $1 \to \ker \Pi \to (\mathcal{O}^\times)^m \to \mathcal{O}^\times \to 1$, with $\ker \Pi \cong (\mathcal{O}^\times)^{m-1}$ as a group. (iii) *Universality and finite levels*: the entire theory holds over any commutative group carrying a $\mathbb{Z}$-valued valuation with a uniformizer — in particular over $\mathbb{Q}_p$ — and truncating to $\mathbb{Z}/p^D$ yields the exact fibre count $\bigl((p-1)p^{D-1}\bigr)^{m-1}$, whose generating function is rational with Euler factor $\bigl(1 - p^{\,m-1}T\bigr)^{-1}$. (iv) *Positivity*: over $\mathbb{R}$ with nonnegative coefficients, the twist group collapses to the trivial group, so the abundance of factorizations is a purely algebraic phenomenon; equivalently, the only law on $\mathbb{N}$ normalized by $p_0 = 1$ whose generating function has a nonnegative reciprocal is the Dirac mass at $0$. A probabilistic dictionary translates realizability into the statement that a finitely supported law admits a renormalized factorization if and only if it charges the atom at $0$.

**Keywords:** Laurent series, discrete valuation, renormalized product, rigidity index, gauge invariance, probability generating function, $p$-adic numbers, Euler factor, positivity.

---

## 1. Introduction

### 1.1 The problem

Fix a field $K$ and work in the field $K(\!(q)\!)$ of formal Laurent series with coefficients in $K$: elements are formal sums $\sum_{n \in \mathbb{Z}} a_n q^n$ whose support is bounded below. The **order** (or valuation) of a nonzero such series is
$$\operatorname{ord} f = \min \{\, n : a_n \neq 0 \,\},$$
with the convention $\operatorname{ord} 0 = +\infty$. Order is the fundamental invariant: it is a homomorphism from the multiplicative group $K(\!(q)\!)^\times$ onto $\mathbb{Z}$,
$$\operatorname{ord}(fg) = \operatorname{ord} f + \operatorname{ord} g .$$

**Definition 1.1 (Normalized series).** A Laurent series $f$ is *normalized* if $\operatorname{ord} f = -1$, i.e. $f$ has a simple pole at $q = 0$.

**Definition 1.2 (Renormalized product).** For $k, m \in \mathbb{N}$ and a family $f : \mathbb{N} \to K(\!(q)\!)$, the *renormalized product* is
$$R_{k,m}(f) \;=\; q^{k} \prod_{i < m} f_i .$$
The *critical* renormalization is $k = m$; we write $R_m := R_{m,m}$.

The question addressed here — which we refer to as the *factorization problem* — is twofold:

> **(Realizability)** For which $g \in K(\!(q)\!)$ do there exist normalized $f_0, \dots, f_{m-1}$ with $R_m(f) = g$?
>
> **(Rigidity)** When such a family exists, how large is the set of all of them?

### 1.2 Summary of results

The answers are complete and, in a precise sense, universal.

1. **Realizability is governed by a single conservation law.** Since orders add, $\operatorname{ord} R_m(f) = m + \sum_{i<m}(-1) = 0$ for every normalized family. Conversely every order-zero series is realized, for every $m \ge 1$ (Theorem 3.3). The realizable set is thus exactly the order-zero locus $\mathcal{O}^\times$.

2. **Rigidity obeys a sharp dichotomy.** For $m = 1$ the factorization is unique (Proposition 4.1). For $m \ge 2$ the set of factorizations is infinite (Theorem 4.4), over every field. The fibre is a torsor under the group of order-zero twists with unit total product (Theorem 4.5), which is free of rank $m-1$ (Theorem 6.4). We call $m-1$ the *rigidity index*.

3. **The pole profile is pure gauge.** Prescribing an arbitrary profile of pole orders $d_i$ and an arbitrary renormalization exponent $k$ changes nothing except through the total $k + \sum d_i$ (Theorems 5.2 and 7.1); profiles with equal totals have canonically bijective fibres.

4. **One exact sequence explains everything.** Realizability is surjectivity, and non-uniqueness is nontriviality of the kernel, of the product homomorphism $\Pi : (\mathcal{O}^\times)^m \to \mathcal{O}^\times$; the resulting short exact sequence splits, and $\ker \Pi \cong (\mathcal{O}^\times)^{m-1}$ as a group (Section 8).

5. **Finite levels count exactly.** Over $\mathbb{Q}_p$ truncated modulo $p^D$, the fibre has exactly $\bigl((p-1)p^{D-1}\bigr)^{m-1}$ elements; the level-to-level growth ratio is $p^{m-1}$, and the associated generating function is rational with denominator $1 - p^{m-1}T$ (Section 9).

6. **Positivity destroys the gauge group.** A nonnegative real power series whose inverse is nonnegative is constant; hence the positivity-preserving twist group is trivial and the probabilistic factorization is rigid where the algebraic one is not (Section 10).

### 1.3 Why this is the natural formulation

Three features of the problem make it more than a computation with valuations.

*The renormalization is forced.* Without the factor $q^m$, the product of $m$ normalized series would have order $-m$ and the realizable set would be the order-$(-m)$ locus — a set that changes with $m$. The critical renormalization $k = m$ is the unique choice making the realizable set independent of $m$. That stability is what allows the *same* target to be compared across different numbers of slots, and hence what makes the rigidity dichotomy a statement about $m$ alone.

*The obstruction is a conservation law.* "Only the total order matters" is the exact analogue of a conservation law in physics, and the accompanying redundancy (which slot carries which pole order) is the exact analogue of a gauge freedom. Making this analogy precise — a gauge transformation, a gauge-invariant observable, a gauge orbit — is the content of Sections 5 and 8.

*Positivity is a genuine constraint, not a normalization.* Probability generating functions live in the same algebra but in a proper sub-semiring. The passage from field to semiring collapses an infinite gauge group to the trivial group. This is the mechanism by which a probabilistic problem can be rigid while its algebraic shadow is not.

---

## 2. Preliminaries

Throughout, $K$ is a field, $q$ denotes the uniformizer of $K(\!(q)\!)$ (the monomial of degree $1$), and we freely use:

**Lemma 2.1 (Order arithmetic).** For nonzero $a, b \in K(\!(q)\!)$:
$$\operatorname{ord}(ab) = \operatorname{ord} a + \operatorname{ord} b, \qquad \operatorname{ord}(a^{-1}) = -\operatorname{ord} a, \qquad \operatorname{ord}(q^{k}) = k \ (k \in \mathbb{Z}).$$
Moreover $\operatorname{ord}(a + b) \ge \min(\operatorname{ord} a, \operatorname{ord} b)$ with equality when $\operatorname{ord} a \neq \operatorname{ord} b$.

**Definition 2.2 (Order-zero locus).** $\mathcal{O}^\times := \{\, u \in K(\!(q)\!) : \operatorname{ord} u = 0 \,\}$, the group of units of the valuation ring. By Lemma 2.1 it is closed under multiplication and inversion and contains $1$.

**Lemma 2.3 (Stability of normalization).** If $u \in \mathcal{O}^\times$ and $f$ is normalized, then $uf$ is normalized.

*Proof.* $\operatorname{ord}(uf) = 0 + (-1) = -1$. $\square$

Lemma 2.3 is the engine of every non-uniqueness statement below: the normalization condition is invariant under the action of $\mathcal{O}^\times$, so units can be moved between slots freely.

---

## 3. Realizability: the pole order is the only obstruction

**Lemma 3.1 (Additivity of pole orders).** If $f_i$ is normalized for all $i < m$, then $\operatorname{ord} \prod_{i<m} f_i = -m$.

*Proof.* Induction on $m$ using Lemma 2.1; each factor is nonzero because it has finite order. $\square$

**Proposition 3.2 (Order of the renormalized product).** For a normalized family, $\operatorname{ord} R_{k,m}(f) = k - m$. In particular $\operatorname{ord} R_m(f) = 0$.

The converse is the main realizability theorem, and its proof is constructive.

**Definition 3.3 (Canonical family).** For $g$ of order $0$ and $m \ge 1$, set
$$\operatorname{can}_m(g)_i \;=\;
\begin{cases}
q^{-1} g, & i = 0,\\
q^{-1}, & 1 \le i < m,\\
1, & i \ge m.
\end{cases}$$

**Theorem 3.4 (Realizability; "Conjecture C", main statement).** *Let $m \ge 1$ and $g \in K(\!(q)\!)$. Then*
$$\exists\, f : \mathbb{N} \to K(\!(q)\!) \ \text{with } f_i \text{ normalized for } i<m \text{ and } R_m(f) = g
\iff \operatorname{ord} g = 0 .$$
*Equivalently, $\{\, R_m(f) : f_i \text{ normalized}\,\} = \mathcal{O}^\times$.*

*Proof sketch.* ($\Rightarrow$) Proposition 3.2. ($\Leftarrow$) Take $f = \operatorname{can}_m(g)$. Slot $0$ has order $-1 + 0 = -1$ and slots $1,\dots,m-1$ have order $-1$, so the family is normalized. Its product is $q^{-m} g$, whence $R_m(f) = q^m \cdot q^{-m} g = g$. $\square$

**Theorem 3.5 (Arbitrary renormalization exponent).** For $m \ge 1$ and $k \in \mathbb{N}$,
$$\{\, R_{k,m}(f) : f_i \text{ normalized for } i < m \,\} \;=\; \{\, g : \operatorname{ord} g = k - m \,\}.$$

*Proof sketch.* Multiply the statement of Theorem 3.4 by $q^{k-m}$: the map $g \mapsto q^{k-m} g$ is a bijection of the order-zero locus onto the order-$(k-m)$ locus, and it intertwines the two renormalizations. $\square$

**Remark 3.6.** Theorem 3.4 holds over *every* field, with no hypothesis on characteristic or cardinality, and with no convergence considerations. The canonical family shows the realizable set is nonempty in the strongest possible sense: one explicit witness, uniformly in $m$ and $g$.

---

## 4. Rigidity: a sharp dichotomy at $m = 2$

**Definition 4.1 (Factorization set).** For $m \ge 1$ and $g$ of order $0$,
$$\mathcal{F}_m(g) \;=\; \{\, f : \mathbb{N} \to K(\!(q)\!) \ \mid\ f_i \text{ normalized for } i<m,\ f_i = 1 \text{ for } i \ge m,\ R_m(f) = g \,\}.$$
The condition off the window is a normalization ensuring that $\mathcal{F}_m(g)$ measures genuine freedom inside the window rather than the arbitrariness of unused slots.

**Proposition 4.2 (Uniqueness at $m=1$).** If $R_1(f) = R_1(f') = g$ then $f_0 = f_0'$. Indeed $q f_0 = q f_0'$ and $q \neq 0$ in a field.

Thus $\mathcal{F}_1(g)$ is a singleton, namely $\{q^{-1}g\}$ in slot $0$.

**Definition 4.3 (Two-slot twist).** For $u \in \mathcal{O}^\times$ let
$$(\tau_u f)_i = \begin{cases} u f_0, & i = 0, \\ u^{-1} f_1, & i = 1, \\ f_i, & i \ge 2. \end{cases}$$

**Lemma 4.4.** For $m \ge 2$ and $u \in \mathcal{O}^\times$, the family $\tau_u f$ is normalized on the window whenever $f$ is (Lemma 2.3, applied to $u$ and $u^{-1}$, both of order $0$), and $\prod_{i<m} (\tau_u f)_i = \prod_{i<m} f_i$. Hence $R_m(\tau_u f) = R_m(f)$.

To turn Lemma 4.4 into an infinitude statement one needs infinitely many distinct order-zero units, available over every field:

**Lemma 4.5 (Distinguished units).** For $n \in \mathbb{N}$ put $u^{(n)} := 1 + q^{\,n+1}$. Then $\operatorname{ord} u^{(n)} = 0$ (the two summands have distinct orders $0$ and $n+1$), $u^{(n)} \neq 0$, $\operatorname{ord}\bigl( (u^{(n)})^{-1} \bigr) = 0$, and $n \mapsto u^{(n)}$ is injective.

**Theorem 4.6 (Non-uniqueness).** *For every $m \ge 2$ and every $g$ with $\operatorname{ord} g = 0$, the factorization is not unique; in fact $\mathcal{F}_m(g)$ is infinite.*

*Proof sketch.* The families $\tau_{u^{(n)}}\bigl(\operatorname{can}_m(g)\bigr)$, $n \in \mathbb{N}$, all lie in $\mathcal{F}_m(g)$ by Lemma 4.4 and Theorem 3.4. They are pairwise distinct because their slot-$0$ entries $u^{(n)} q^{-1} g$ determine $u^{(n)}$ (divide by the nonzero $q^{-1}g$), and $n \mapsto u^{(n)}$ is injective. $\square$

**Remark 4.7.** Over $\mathbb{F}_2$ there are no nontrivial scalars, so rescaling $f_0 \mapsto \lambda f_0$, $f_1 \mapsto \lambda^{-1} f_1$ produces nothing. The units $1 + q^{n+1}$ still do. The dichotomy is therefore not an artifact of large coefficient fields.

The structure of $\mathcal{F}_m(g)$ is exactly a torsor:

**Theorem 4.8 (Fibre = torsor).** Let $m \ge 1$ and let $f, f' \in \mathcal{F}_m(g)$. Then
$$f'_i / f_i \in \mathcal{O}^\times \quad (i < m), \qquad \prod_{i<m} f'_i/f_i = 1 .$$
Conversely, if $f \in \mathcal{F}_m(g)$ and $u_0,\dots,u_{m-1} \in \mathcal{O}^\times$ satisfy $\prod_{i<m} u_i = 1$, then the family $i \mapsto u_i f_i$ (extended by $1$) again lies in $\mathcal{F}_m(g)$.

*Proof sketch.* Forward: $\operatorname{ord}(f_i'/f_i) = (-1) - (-1) = 0$; and cancelling the nonzero factor $q^m$ in $R_m(f) = R_m(f')$ gives $\prod f_i = \prod f_i'$, so the product of the ratios is $1$. Backward: each $u_i f_i$ is normalized by Lemma 2.3, and $\prod_i u_i f_i = (\prod u_i)(\prod f_i) = \prod f_i$. $\square$

Theorem 4.8 identifies $\mathcal{F}_m(g)$, once one point is chosen, with the group
$$T_m := \Bigl\{\, (u_i)_{i<m} \in (\mathcal{O}^\times)^m : \textstyle\prod_{i<m} u_i = 1 \,\Bigr\},$$
which is trivial exactly when $m = 1$ or $\mathcal{O}^\times = \{1\}$. Since $\mathcal{O}^\times$ is always infinite in the Laurent setting, the dichotomy is exactly "$m = 1$ versus $m \ge 2$".

---

## 5. Arbitrary pole profiles: only the total obstructs

**Definition 5.1 (Pole profile).** A family $f$ *has pole profile* $d : \mathbb{N} \to \mathbb{Z}$ on the window $[0,m)$ if $\operatorname{ord} f_i = d_i$ for all $i<m$ and $f_i = 1$ for $i \ge m$. Write $R^{\mathbb{Z}}_{k,m}(f) = q^{k}\prod_{i<m} f_i$ for $k \in \mathbb{Z}$.

**Theorem 5.2 (Profile realizability).** *For $m \ge 1$, any $k \in \mathbb{Z}$ and any profile $d$,*
$$\bigl\{\, R^{\mathbb{Z}}_{k,m}(f) : f \text{ has profile } d \,\bigr\} \;=\; \Bigl\{\, g : \operatorname{ord} g = k + \textstyle\sum_{i<m} d_i \,\Bigr\}.$$

*Proof sketch.* ($\subseteq$) Orders add. ($\supseteq$) Generalize the canonical family: put $f_0 = q^{\,d_0 - k - \sum_{1 \le i < m} d_i}\, g$ — more transparently, take $f_i = q^{d_i}$ for $1 \le i < m$ and let slot $0$ absorb the remainder, namely $f_0 = g\, q^{-k - \sum_{1\le i<m} d_i}$, whose order is $\operatorname{ord} g - k - \sum_{1 \le i<m} d_i = d_0$. $\square$

**Corollary 5.3.** The classical statement is the constant profile $d \equiv -1$ with $k = m$: the realizable set is the order-zero locus, recovering Theorem 3.4.

Theorem 5.2 says the individual $d_i$ are invisible in the *image*. Section 8 shows they are invisible in the *fibres* as well.

---

## 6. The abstract valuation setting

Nothing above uses coefficients. The proofs use only: a commutative group, a homomorphism to $\mathbb{Z}$, and an element of value $1$.

**Definition 6.1 (Discrete valuation datum).** Let $G$ be a commutative group. A *discrete valuation datum* on $G$ is a pair $(\operatorname{val}, \pi)$ with $\operatorname{val} : G \to \mathbb{Z}$ satisfying $\operatorname{val}(ab) = \operatorname{val} a + \operatorname{val} b$, and $\pi \in G$ with $\operatorname{val} \pi = 1$. Consequently $\operatorname{val} 1 = 0$, $\operatorname{val}(a/b) = \operatorname{val} a - \operatorname{val} b$, $\operatorname{val}(a^n) = n \operatorname{val} a$ for $n \in \mathbb{Z}$, and $\operatorname{val}$ is surjective.

Write $\mathcal{O}^\times_V := \{u \in G : \operatorname{val} u = 0\}$, a subgroup, and define
$$R_{k,m}(f) = \pi^{k} \prod_{i<m} f_i, \qquad \mathcal{F}_{k,m,d}(g) = \{ f : \text{profile } d,\ R_{k,m}(f) = g \}.$$

**Theorem 6.2 (Abstract realizability).** *For $m \ge 1$, $k \in \mathbb{Z}$, profile $d$ and $g \in G$:*
$$\mathcal{F}_{k,m,d}(g) \neq \emptyset \iff \operatorname{val} g = k + \sum_{i<m} d_i .$$

*Proof sketch.* Same canonical family: $f_i = \pi^{d_i}$ for $1 \le i < m$, and $f_0 = g\,\pi^{-k-\sum_{1\le i<m} d_i}$. $\square$

**Theorem 6.3 (Abstract torsor structure).** Fix $f^{0} \in \mathcal{F}_{k,m,d}(g)$. Then $f \mapsto (f_i / f^{0}_i)_{i<m}$ is a bijection from $\mathcal{F}_{k,m,d}(g)$ onto the twist group $T_m = \{ u \in (\mathcal{O}^\times_V)^m : \prod u_i = 1 \}$.

**Theorem 6.4 (Rigidity index).** *With $m = n+1$ slots, $T_m$ is in bijection with $(\mathcal{O}^\times_V)^{n}$: the entries in slots $1,\dots,n$ are free and slot $0$ is forced to be the inverse of their product. Hence for a realizable target,*
$$\bigl|\mathcal{F}_{k,\,n+1,\,d}(g)\bigr| \;=\; \bigl|\mathcal{O}^\times_V\bigr|^{\,n} .$$
*In particular the fibre is a singleton if and only if $n = 0$ or $\mathcal{O}^\times_V$ is trivial.*

**Corollary 6.5 (Rigidity dichotomy).** If $\mathcal{O}^\times_V \neq \{1\}$ and $g$ is realizable, then the factorization is unique iff $m = 1$.

**Instantiation 6.6 (Laurent series).** $G = K(\!(q)\!)^\times$, $\operatorname{val} = \operatorname{ord}$, $\pi = q$. Recovers Sections 3–5.

**Instantiation 6.7 ($p$-adic numbers).** $G = \mathbb{Q}_p^\times$, $\operatorname{val} = v_p$, $\pi = p$. Then: a $p$-adic number is $p^k$ times a product of $m$ numbers of prescribed valuations $d_i$ iff $v_p(g) = k + \sum d_i$; and for $m \ge 2$ this factorization is never unique, since $\mathbb{Z}_p^\times$ is infinite.

---

## 7. Gauge invariance of the profile

**Definition 7.1 (Monomial gauge transformation).** For $e : \mathbb{N} \to \mathbb{Z}$ define
$$(\gamma_e f)_i = \begin{cases} f_i \,\pi^{\,e_i}, & i < m, \\ f_i, & i \ge m. \end{cases}$$

**Lemma 7.2.** $\gamma_e$ maps profile-$d$ families to profile-$(d+e)$ families, and $\gamma_{-e} \circ \gamma_e = \mathrm{id}$. If $\sum_{i<m} e_i = 0$ then $R_{k,m}(\gamma_e f) = R_{k,m}(f)$, because $\prod_{i<m} \pi^{e_i} = \pi^{\sum e_i} = 1$.

**Theorem 7.3 (Profiles with equal total are gauge-equivalent).** *Let $d, d'$ be profiles with $\sum_{i<m} d_i = \sum_{i<m} d'_i$. Then for every $k$ and $g$:*
1. *the realizable sets coincide: $\{R_{k,m}(f) : \text{profile } d\} = \{R_{k,m}(f) : \text{profile } d'\}$;*
2. *the fibres are in explicit bijection, $\mathcal{F}_{k,m,d}(g) \cong \mathcal{F}_{k,m,d'}(g)$, via $\gamma_{d'-d}$;*
3. *rigidity is profile-independent: $\mathcal{F}_{k,m,d}(g)$ is a singleton (or empty) iff $\mathcal{F}_{k,m,d'}(g)$ is.*

*Proof sketch.* Put $e = d' - d$; then $\sum_{i<m} e_i = 0$, so $\gamma_e$ preserves the renormalized product (Lemma 7.2) while shifting the profile from $d$ to $d'$, and $\gamma_{-e}$ is a two-sided inverse. Statement (1) also follows from Theorem 6.2, since both sides equal the level set of $k + \sum d_i$. $\square$

The physical reading: the pole orders $d_i$ are *gauge coordinates*, the total $\sum d_i$ is the *gauge-invariant observable*, and $\gamma_e$ with $\sum e_i = 0$ is the group of gauge transformations. No property of the factorization problem — image, fibre size, uniqueness — can distinguish profiles with the same total.

---

## 8. The split exact sequence behind the dichotomy

Let $\mathcal{O}^\times := \mathcal{O}^\times_V$ and let
$$\Pi : (\mathcal{O}^\times)^m \to \mathcal{O}^\times, \qquad \Pi(u) = \prod_{i<m} u_i$$
be the product homomorphism (well defined and a homomorphism because $G$ is commutative and $\operatorname{val}$ additive).

**Theorem 8.1 (Splitting).** For $m = n+1 \ge 1$, let $\sigma : \mathcal{O}^\times \to (\mathcal{O}^\times)^{m}$ place $u$ in slot $0$ and $1$ elsewhere. Then $\sigma$ is a homomorphism and $\Pi \circ \sigma = \mathrm{id}$. In particular $\Pi$ is surjective.

**Theorem 8.2 (Kernel is free of rank $m-1$).** For $m = n+1$ there is a group isomorphism
$$\ker \Pi \;\cong\; (\mathcal{O}^\times)^{\,n},$$
sending $u \in \ker \Pi$ to $(u_1,\dots,u_n)$; the inverse sends $(w_1,\dots,w_n)$ to $\bigl((w_1\cdots w_n)^{-1}, w_1,\dots,w_n\bigr)$. Consequently
$$(\mathcal{O}^\times)^m \;\cong\; \ker\Pi \times \mathcal{O}^\times \;\cong\; (\mathcal{O}^\times)^{n} \times \mathcal{O}^\times .$$

**Theorem 8.3 (Fibre = kernel).** For any realizable $g$ and any profile $d$, $\mathcal{F}_{k,m,d}(g)$ is in bijection with $\ker \Pi$. Hence the fibre is a singleton iff $\ker \Pi$ is trivial, iff $m = 1$ or $\mathcal{O}^\times = \{1\}$.

Thus the short exact sequence
$$1 \longrightarrow \ker \Pi \longrightarrow (\mathcal{O}^\times)^m \xrightarrow{\ \Pi\ } \mathcal{O}^\times \longrightarrow 1$$
is exact and split, and:

* **surjectivity of $\Pi$** = "the total valuation is the only obstruction" (realizability);
* **nontriviality of $\ker \Pi$** = "the factorization is never unique for $m \ge 2$";
* **rank of $\ker\Pi$** = the rigidity index $m-1$, the corank of the product map.

This is the structural statement the earlier, more computational results were shadows of: the isomorphism of Theorem 8.2 is one of *groups*, strictly stronger than the bare bijection of Theorem 6.4.

---

## 9. Finite levels, exact counts, and an Euler factor

In the Laurent and $p$-adic settings $\mathcal{O}^\times$ is infinite, so Theorem 6.4 reads $|\mathcal{F}| = \infty^{\,n}$. Truncation makes the count finite and exact. Let $U$ be any commutative group; the relevant fibre is
$$\Phi_n(U, g) := \Bigl\{\, f : \{0,\dots,n\} \to U \ \Bigm|\ \prod_{i=0}^{n} f_i = g \,\Bigr\}.$$

**Theorem 9.1 (Free slots).** For every commutative group $U$, every $n \ge 0$ and every $g \in U$, there is a bijection
$$\Phi_n(U,g) \;\cong\; U^{\,n}, \qquad f \mapsto (f_1,\dots,f_n),$$
with inverse $(w_1,\dots,w_n) \mapsto \bigl(g\,(w_1\cdots w_n)^{-1},\, w_1, \dots, w_n\bigr)$. Hence $|\Phi_n(U,g)| = |U|^n$ when $U$ is finite.

**Theorem 9.2 (Finite-level dichotomy).** For finite $U$: $|\Phi_n(U,g)| = 1$ iff $n = 0$ or $|U| = 1$.

Specializing to $U = (\mathbb{Z}/p^D)^\times$, the unit group of the $D$-th truncation of $\mathbb{Z}_p$:

**Theorem 9.3 (Finite-level fibre count).** *Let $p$ be prime, $D \ge 1$, $m = n+1$. For every target $g \in (\mathbb{Z}/p^D)^\times$,*
$$\bigl|\Phi_n\bigl((\mathbb{Z}/p^{D})^\times, g\bigr)\bigr| \;=\; \bigl((p-1)\,p^{\,D-1}\bigr)^{\,n} ,$$
*since $\bigl|(\mathbb{Z}/p^D)^\times\bigr| = \varphi(p^D) = (p-1)p^{D-1}$.*

**Theorem 9.4 (Level recursion).** $\bigl|\Phi_n\bigl((\mathbb{Z}/p^{D+1})^\times,\cdot\bigr)\bigr| = p^{\,n} \cdot \bigl|\Phi_n\bigl((\mathbb{Z}/p^{D})^\times,\cdot\bigr)\bigr|$ for $D \ge 1$: each extra digit of precision multiplies the number of factorizations by $p^{\,n}$, so the rigidity index is the exponent of the growth rate.

Because the counts are geometric, their generating function is rational, and the identity holds at the level of formal finite sums over any commutative ring $R$ — no convergence needed.

**Theorem 9.5 (Euler factor of the rigidity index).** *For every $N \in \mathbb{N}$ and $T \in R$,*
$$\bigl(1 - p^{\,n} T\bigr) \sum_{D=0}^{N-1} \bigl((p-1)p^{D}\bigr)^{n}\, T^{\,D+1} \;=\; (p-1)^{n}\, T\,\bigl(1 - (p^{\,n}T)^{N}\bigr).$$
*Letting $N \to \infty$ formally, $\sum_{D \ge 1} \bigl|\Phi_n\bigr|_{D}\, T^{D} = \dfrac{(p-1)^n T}{1 - p^{\,n} T}$: the denominator is exactly $1 - p^{\,m-1}T$.*

*Proof sketch.* Factor $\bigl((p-1)p^D\bigr)^n = (p-1)^n (p^n)^D$ out of the sum and apply the telescoping identity $(1-x)\sum_{D<N} x^D = 1 - x^N$ with $x = p^n T$. $\square$

**Theorem 9.6 (Finite-level rigidity dichotomy).** If $(p-1)p^{D-1} \ge 2$ — i.e. $p$ odd, or $p = 2$ and $D \ge 2$ — then $|\Phi_n| = 1$ iff $n=0$, matching the valuation-level dichotomy.

**Theorem 9.7 (The exceptional level).** For $p = 2$, $D = 1$ the group $(\mathbb{Z}/2)^\times$ is trivial, so $|\Phi_n| = 1$ for *every* $n$: modulo $2$ the factorization is unique regardless of the number of slots. This is the unique corner case in which finite-level rigidity is strictly stronger than valuation-level rigidity.

Finally, the levels are compatible:

**Theorem 9.8 (Lifting).** If $\varphi : U \to V$ is a surjective homomorphism of commutative groups, the induced map $\Phi_n(U,g) \to \Phi_n(V, \varphi(g))$, $f \mapsto \varphi \circ f$, is surjective. Applied to the reductions $(\mathbb{Z}/p^{D+1})^\times \twoheadrightarrow (\mathbb{Z}/p^{D})^\times$: every factorization modulo $p^{D}$ lifts to one modulo $p^{D+1}$, so the tower of fibres has surjective transition maps and its inverse limit is nonempty.

---

## 10. Probability: the bridge and the collapse of the gauge group

### 10.1 The bridge

**Definition 10.1 (Generating function).** For a weight sequence $c : \mathbb{N} \to K$ and a cutoff $N$, set $G_c^N := \sum_{n<N} c_n q^{n} \in K(\!(q)\!)$.

**Lemma 10.2 (Order of a generating function).** If $N \ge 1$ and $c_0 \neq 0$ then $\operatorname{ord} G_c^N = 0$. If $c_0 = 0$ then $\operatorname{ord} G_c^N > 0$ (possibly $+\infty$, if all displayed coefficients vanish).

*Proof sketch.* Write $G_c^N = c_0 + q\bigl(\sum_{n<N-1} c_{n+1} q^{n}\bigr)$. The bracket has order $\ge 0$, so the shifted part has order $\ge 1$; the ultrametric equality then gives $\operatorname{ord} G_c^N = \operatorname{ord} c_0 = 0$ when $c_0 \ne 0$, and the second claim is the same decomposition with the constant term deleted. $\square$

Combining with Theorem 3.4 and Theorem 4.6:

**Theorem 10.3 (Probability bridge).** *Let $c$ be a finitely supported weight sequence with cutoff $N \ge 1$ and let $m \ge 1$.*
1. *(Existence) If $c_0 \neq 0$ then $G_c^N = q^m \prod_{i<m} f_i$ for some normalized $f_0,\dots,f_{m-1}$.*
2. *(Obstruction) If $c_0 = 0$ then no such factorization exists, for any $m \ge 1$.*
3. *(Abundance) For $K = \mathbb{R}$, $c = p$ a nonnegative law with $p_0 > 0$, and $m \ge 2$, the set of such factorizations is infinite.*

In words: *a finitely supported law admits a renormalized factorization into simple-pole factors precisely when it charges the atom at $0$*; and when it does, the factorization is unique only for $m = 1$.

### 10.2 Positivity destroys the twists

All abundance came from twisting by $(u, u^{-1})$ with $u \in \mathcal{O}^\times$. Probabilistic objects carry a constraint absent from the field: their coefficients are nonnegative. Say a formal power series $u = \sum_n u_n x^n$ over $\mathbb{R}$ is **nonnegative** if $u_n \ge 0$ for all $n$.

**Theorem 10.4 (Convolution obstruction).** *Let $u, v$ be nonnegative power series over $\mathbb{R}$ with $uv = 1$. Then $u_n = 0$ for all $n \ge 1$; that is, $u$ is a constant, and $u_0 > 0$.*

*Proof.* For $n \ge 1$, the $n$-th coefficient of $uv = 1$ is $\sum_{j=0}^{n} u_j v_{n-j} = 0$. Every summand is nonnegative, hence every summand vanishes; in particular $u_n v_0 = 0$. From $u_0 v_0 = 1$ we get $v_0 \ne 0$, so $u_n = 0$. Positivity of $u_0$ follows from $u_0 v_0 = 1$ with both factors nonnegative. $\square$

**Corollary 10.5 (Trivial positive twist group).** If moreover $u_0 = 1$ then $u = 1$. Hence the set of normalized positivity-preserving twists $\{(u,u^{-1}) : u, u^{-1} \text{ nonnegative}, u_0 = 1\}$ is a singleton: the two-slot twist that generates non-uniqueness is never positivity-preserving unless trivial.

**Corollary 10.6 (Dirac rigidity).** *Let $p$ be a nonnegative sequence with $p_0 = 1$ whose generating function has a nonnegative reciprocal. Then $p$ is the point mass at $0$: $p_n = \mathbb{1}[n=0]$.*

The contrast is the punchline of the paper. Over a field, the fibre of the renormalized-product map is an infinite torsor and the rigidity index is $m-1$. Impose nonnegativity of coefficients — i.e. work in the semiring where probability lives — and the group acting on the fibre collapses to $\{1\}$. The abundance of algebraic factorizations is invisible to probability: it is a phenomenon of the ambient field, not of the measure.

---

## 11. Algorithms

The proofs are constructive and translate directly into algorithms.

**Algorithm A (Canonical factorization).** *Input:* a target $g$ of order $0$ given by its coefficients, a slot count $m \ge 1$, a profile $d$ and an exponent $k$ with $\operatorname{ord} g = k + \sum d_i$. *Output:* a valid family. Set $f_i = q^{d_i}$ for $1 \le i < m$ and $f_0 = g\, q^{-k - \sum_{1 \le i<m} d_i}$. Cost: $O(m)$ monomial assignments plus one shift of $g$. Correctness: Theorem 6.2.

**Algorithm B (Twist enumeration).** *Input:* a factorization $f$, a slot count $m \ge 2$, a list of units $u_1, \dots, u_{n}$ ($n = m-1$) of order $0$. *Output:* the family $f'$ with $f_0' = f_0 (u_1 \cdots u_n)^{-1}$ and $f_i' = u_i f_i$. Every element of the fibre arises exactly once this way (Theorems 8.2, 9.1). Cost: $O(m)$ series multiplications.

**Algorithm C (Gauge transport between profiles).** *Input:* a factorization with profile $d$, a target profile $d'$ with $\sum d = \sum d'$. *Output:* the factorization $f_i \mapsto f_i\, q^{\,d'_i - d_i}$, which has profile $d'$ and the same renormalized product (Theorem 7.3). Cost: $O(m)$ shifts.

**Algorithm D (Finite-level enumeration and counting).** *Input:* $p$, $D$, $n$, target $g \in (\mathbb{Z}/p^D)^\times$. *Output:* all $\bigl((p-1)p^{D-1}\bigr)^n$ tuples with product $g$: iterate over $(w_1,\dots,w_n) \in \bigl((\mathbb{Z}/p^D)^\times\bigr)^n$ and prepend $g (w_1 \cdots w_n)^{-1}$. Cost: $\Theta\bigl(n \cdot \varphi(p^D)^n\bigr)$ for enumeration; $O(1)$ arithmetic for the count via Theorem 9.3.

---

## 12. Discussion

**What is actually being classified.** The renormalized product map is a homomorphism-like map whose source is a product of level sets of a valuation and whose target is a level set of the same valuation. Once the profile is absorbed by gauge, the map is literally the product homomorphism $\Pi$ on $(\mathcal{O}^\times)^m$. Every result then becomes a statement about $\Pi$: it is surjective (realizability), split (canonical factorization), with kernel free of rank $m-1$ (rigidity). The apparent richness of the original question is the richness of the group $\mathcal{O}^\times$, transported.

**Why the total valuation is the only obstruction.** Structurally, because $\operatorname{val}$ is *surjective* — the existence of a uniformizer is what allows an arbitrary deficit to be dumped into a single slot. Over a group with a non-surjective valuation (say, values in $2\mathbb{Z}$) the realizable set would be a proper subset of the expected level set, and the theory would acquire a second, arithmetic obstruction. The uniformizer is doing real work.

**The role of positivity.** The collapse in Section 10 is not a technicality. The group $\mathcal{O}^\times$ owes its size to the availability of additive inverses: $1 + q$ has inverse $1 - q + q^2 - \cdots$, which is nonnegative only if the signs conspire — and they never do, unless the series is constant. The convolution argument makes this exact. Structurally: the units of the semiring of nonnegative power series are just the positive constants, whereas the units of the ring of all power series are all series with nonzero constant term. The rigidity index of a factorization problem is a property of the *ambient unit group*, and semirings have far fewer units than rings.

**Finite levels as a bridge.** Theorems 9.3–9.5 show that the invariant $m-1$ survives truncation in the most legible possible way: it is the exponent in the Euler factor $\bigl(1 - p^{m-1}T\bigr)^{-1}$ of the counting series. Since the transition maps between levels are surjective (Theorem 9.8), the finite-level data determines the valuation-level picture in the limit — except at the single exceptional level $p = 2$, $D = 1$, where the truncated unit group is trivial and rigidity is spuriously perfect.

**Independence of the coefficient field.** Perhaps the most striking robustness statement is that non-uniqueness holds over $\mathbb{F}_2$. Many "abundance of solutions" arguments in algebra secretly use scalars; here scalars are irrelevant, because the twists $1 + q^{n+1}$ are built from the uniformizer alone.

---

## 13. Future work

Several directions suggest themselves.

1. **Full probabilistic rigidity.** Section 10 proves that positivity kills the twist group. What remains is to characterize completely, for a fixed law with $p_0 > 0$ and a fixed $m$, the set of factorizations whose factors are themselves (rescaled) probability generating functions — the positivity analogue of Theorem 6.4. The natural conjecture is that the fibre is a singleton for every $m$, i.e. the rigidity index of the positive problem is $0$.

2. **Non-surjective valuations and higher rank.** Replacing $\mathbb{Z}$ by an arbitrary totally ordered abelian value group, or dropping the uniformizer, should produce a genuine arithmetic obstruction beyond the total valuation. Quantifying the failure of realizability in terms of the index of the value subgroup generated by the profile is a concrete next step.

3. **Rigidity indices for other decomposition problems.** The pattern "conservation law + gauge orbit + corank" is not specific to valuations. Identifying the analogue of $m-1$ for factorization problems with additional constraints (prescribed residues, symmetry conditions, integrality) would test how far the mechanism travels.

4. **Euler products.** Theorem 9.5 produces one local factor $\bigl(1-p^{m-1}T\bigr)^{-1}$ per prime. Assembling these over all $p$ with $T = p^{-s}$ suggests a zeta-like object whose analytic behaviour encodes the rigidity index globally; making this precise, including convergence, is open.

5. **Effective enumeration modulo truncation.** Algorithm D is optimal for full enumeration but exponential in $n$. Sampling uniformly from the fibre, or enumerating fibre elements with prescribed extra constraints (e.g. all slots congruent to $1$ modulo $p$), are natural algorithmic questions with a clean group-theoretic formulation.

---

## 14. Conclusion

The factorization problem for renormalized products of normalized series has a complete solution, and the solution is structural rather than computational. For every $m \ge 1$, the realizable targets are exactly the series of order $0$; equivalently, in the general valued setting, exactly those of valuation $k + \sum_{i<m} d_i$. The pole profile is pure gauge. The fibre over a realizable target is a torsor under a group free of rank $m-1$, so factorization is unique precisely for one slot and infinitely ambiguous for two or more, over every field. All of it is the split short exact sequence $1 \to \ker\Pi \to (\mathcal{O}^\times)^m \to \mathcal{O}^\times \to 1$ in disguise. Truncating to finite precision converts the rigidity index into the exponent of an Euler factor. And demanding positivity — the step from algebra to probability — annihilates the gauge group entirely, so that a phenomenon of unbounded ambiguity over a field becomes, for probability distributions, a matter of a single canonical decomposition.
