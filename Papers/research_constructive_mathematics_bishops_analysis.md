# Bishop's Constructive Analysis: Explicit Moduli, Sharp Constants, and the Cost of the Intermediate Value Theorem

**Author:** Aristotle
**Date:** 2026-08-06

---

## Abstract

We develop the elementary theory of Errett Bishop's constructive real numbers — regular sequences of rationals carrying their own modulus of Cauchyness — and use it to give a fully quantitative account of the constructive intermediate value theorem, the constructive least upper bound principle, and the constructive order relation. Four groups of results are established.

**(i) The number system.** A regular sequence $x : \mathbb{N} \to \mathbb{Q}$ with $|x_m - x_n| \le \frac{1}{m+1} + \frac{1}{n+1}$ denotes a real $\hat x$ with the exact error bound $|\hat x - x_n| \le \frac{1}{n+1}$; Bishop's definitional equality $|x_n - y_n| \le \frac{2}{n+1}$ coincides with equality of denoted reals, every real is denoted, and the quotient is in canonical bijection with $\mathbb{R}$. Constructive completeness holds with an explicit diagonal $L_n = (x_{2n+1})_{2n+1}$ and the rate $|L - x_k| \le \frac{1}{k+1}$; we show by an explicit two-parameter family that the index shift $n \mapsto 2n+1$ cannot be dropped. Arithmetic is given in computable form, with the index shift $n \mapsto 2n+1$ for sums and $n \mapsto (B_x+B_y)(n+1)$ for products, where $B_x = \lceil |x_0|\rceil + 2$; a concrete computable irrational denoting $\sqrt2$ is exhibited.

**(ii) The order.** Bishop positivity ($\exists n,\ x_n > \frac{1}{n+1}$) and strict order ($\exists n,\ x_n + \frac{2}{n+1} < y_n$) agree extensionally with the classical relations. Cotransitivity is proved in explicit form: from a witness $n$ for $x < y$ with certified rational gap $g$, any index $m$ with $\frac{1}{m+1} \le g/8$ reduces the disjunction $x<z \vee z<y$ to a single decidable rational comparison against the midpoint. A location lemma decides $a < x$ or $x < b$ for rationals $a<b$ by one comparison. We prove that the witness index admits no uniform bound.

**(iii) The intermediate value theorem.** For $f$ with an explicit modulus of uniform continuity $\omega$ on $[a,b]$ and $f(a)\le 0\le f(b)$, a finite grid search of mesh $\le \omega(\varepsilon)$ produces a grid point with $|f|\le\varepsilon$. Under a positive slope bound $c$, an $\varepsilon$-approximate root lies within $\varepsilon/c$ of the exact root; we prove this constant is attained and that no factor $\kappa<1$ improves it. The resulting root is presented as a Bishop real whose approximations are grid points, with root modulus $\delta \mapsto \omega(c\delta)$. Separately we prove a *bracketing* theorem: with **no** non-degeneracy hypothesis, the sign-change search returns a grid point within one mesh of a genuine root. Bishop's shelf family $S_t(x)=\min(x-1,\max(t,x-2))$ admits no continuous root selector, and — a quantitative strengthening — **no** selector whatsoever has oscillation below $1$ on any neighbourhood of the critical parameter. An explicit $1$-Lipschitz function shows that local non-constancy with an explicit modulus does not suffice to convert small values into small distances.

**(iv) Suprema and the cost of a query.** For located sets, an explicit one-query search computes the supremum. The general scheme with query fractions $\alpha<\beta$ preserves the enclosure invariant and contracts by exactly $\max(\beta,1-\alpha)$ per oracle call. Bishop's trisection ($\frac23$) is therefore **not optimal**: $\alpha=\frac25,\beta=\frac12$ contracts by $\frac35$. We prove $\frac12$ is a strict lower bound for every one-query scheme and an infimum that is approached but never attained.

**Keywords.** Constructive analysis, Bishop reals, regular sequence, explicit modulus, intermediate value theorem, cotransitivity, located set, Brouwerian counterexample.

---

## 1. Introduction

### 1.1 The problem

The classical intermediate value theorem asserts that a continuous $f : [a,b] \to \mathbb{R}$ with $f(a) \le 0 \le f(b)$ has a zero. Its standard proof forms $\sup\{x : f(x) \le 0\}$ and invokes the order-completeness of $\mathbb{R}$. That step is not effective: deciding, for a rational $q$, whether $q$ is an upper bound of a set of reals is not in general decidable, and the resulting supremum carries no rate of approximation.

Bishop's programme, initiated in *Foundations of Constructive Analysis* (1967) and refined in Bishop–Bridges, *Constructive Analysis* (1985), reconstructs analysis under two disciplines:

- **(D1)** every existence assertion is accompanied by a construction of the witness;
- **(D2)** every convergence assertion is accompanied by an explicit rate.

The programme is not a restriction to a smaller universe of numbers. As we prove below, the constructive reals are in bijection with the classical reals. What changes is the *content of a proof*: theorems become algorithms with proved error bounds, and the theorems that cannot be made into algorithms become visible, with counterexamples that measure exactly how badly they fail.

### 1.2 Contributions

This paper gives a self-contained development with, in each case, the sharpest constant we can prove:

1. The number system and constructive completeness, with a proof that Bishop's diagonal shift is *necessary* (§2, §3).
2. Computable arithmetic with the canonical bound and index shifts, and a concrete computable irrational (§4).
3. The constructive order with explicit cotransitivity, explicit location, and a proof that the witness index is not uniformly bounded (§5).
4. The approximate intermediate value theorem with explicit modulus, the exact theorem under a slope bound with a *sharp* root modulus $\varepsilon/c$, the presentation of the root as a Bishop real, and a hypothesis-free bracketing theorem (§6).
5. Brouwerian counterexamples: no continuous root selector, no selector of oscillation $<1$, and the insufficiency of local non-constancy (§7).
6. Constructive suprema for located sets, the general one-query search, the exact contraction law $\max(\beta,1-\alpha)$, the suboptimality of trisection, and the infimum $\frac12$ (§8).

Notation: throughout, $\mathbb{Q}$ and $\mathbb{R}$ are the rationals and the classical reals; $\lceil\,\cdot\,\rceil$ is the ceiling to a natural number. We reason classically *about* the constructive objects, so that the results have unambiguous meaning as statements of ordinary mathematics; the constructive content resides in the fact that every witness asserted to exist is exhibited by an explicit formula or a finite search.

---

## 2. The constructive real numbers

### 2.1 Regular sequences

> **Definition 2.1 (regular sequence).** A **regular sequence of rationals** is a function $x : \mathbb{N} \to \mathbb{Q}$, written $n \mapsto x_n$, such that
> $$|x_m - x_n| \;\le\; \frac{1}{m+1} + \frac{1}{n+1} \qquad \text{for all } m,n \in \mathbb{N}.$$
> We call such an $x$ a **Bishop real**, and $x_n$ its $n$-th approximation.

The condition is a Cauchy condition with the modulus already chosen: to obtain accuracy $\varepsilon$ one takes $n \ge 1/\varepsilon$, with no appeal to an existential quantifier and no choice principle. This is the whole point of the definition.

> **Lemma 2.2.** Every regular sequence is a Cauchy sequence in $\mathbb{R}$; indeed for $m,n \ge N$ one has $|x_m - x_n| \le \frac{2}{N+1} \to 0$.

*Proof.* Monotonicity of $t \mapsto 1/(t+1)$ applied to both terms of Definition 2.1. $\square$

> **Definition 2.3.** $\hat x := \lim_{n} x_n \in \mathbb{R}$ is the real number **denoted** by $x$.

### 2.2 The explicit modulus

> **Theorem 2.4 (explicit modulus).** For every Bishop real $x$ and every $n$,
> $$|\hat x - x_n| \;\le\; \frac{1}{n+1}.$$

*Proof sketch.* Fix $n$ and let $j \to \infty$ in $|x_j - x_n| \le \frac{1}{j+1} + \frac{1}{n+1}$. The left side converges to $|\hat x - x_n|$ by continuity of $t \mapsto |t - x_n|$, the right side to $\frac{1}{n+1}$. $\square$

Theorem 2.4 is the reason the theory is usable: the *index is the error bar*. It has an equally useful converse, which is the workhorse for identifying denoted reals.

> **Theorem 2.5 (recognition).** Let $x$ be a Bishop real, $r \in \mathbb{R}$, and $C \ge 0$. If $|x_n - r| \le \frac{C}{n+1}$ for all $n$, then $\hat x = r$.

*Proof sketch.* By Theorem 2.4 and the triangle inequality, $|\hat x - r| \le \frac{1+C}{n+1}$ for every $n$; letting $n \to \infty$ gives $|\hat x - r| = 0$. $\square$

Note the tolerance for an arbitrary constant $C$: one need not verify the canonical rate exactly, only up to a multiplicative constant. Every identification in §4 uses this.

We record the two-sided form, used constantly in §5:
$$x_n - \tfrac{1}{n+1} \;\le\; \hat x \;\le\; x_n + \tfrac{1}{n+1}. \tag{2.1}$$

### 2.3 Equality

Constructively, equality of reals is not decidable and cannot be defined as the negation of apartness. Bishop takes it as a primitive relation on regular sequences.

> **Definition 2.6 (Bishop equality).** $x \equiv y$ iff $|x_n - y_n| \le \frac{2}{n+1}$ for all $n$.

The tolerance $\frac{2}{n+1}$ is exactly the sum of the two error bars, so $x \equiv y$ says: *at every index, the approximations are as close as their own accuracy allows*.

> **Theorem 2.7 (equality is extensional).** $x \equiv y \iff \hat x = \hat y$.

*Proof sketch.* ($\Rightarrow$) By two applications of Theorem 2.4 and the triangle inequality through $x_n$ and $y_n$,
$$|\hat x - \hat y| \le |\hat x - x_n| + |x_n - y_n| + |y_n - \hat y| \le \tfrac{1}{n+1} + \tfrac{2}{n+1} + \tfrac{1}{n+1} = \tfrac{4}{n+1},$$
and $n \to \infty$ gives $\hat x = \hat y$. ($\Leftarrow$) Route through the common value: $|x_n - y_n| \le |x_n - \hat x| + |\hat x - y_n| \le \frac{2}{n+1}$. $\square$

> **Corollary 2.8.** $\equiv$ is an equivalence relation. In particular transitivity — the constructive "$3\varepsilon$" argument — holds.

> **Theorem 2.9 (surjectivity).** Every $r \in \mathbb{R}$ is denoted by a Bishop real.

*Proof sketch.* Choose $q_n \in \mathbb{Q}$ with $|r - q_n| < \frac{1}{2(n+1)}$ (density of $\mathbb{Q}$). Then
$$|q_m - q_n| \le |q_m - r| + |r - q_n| < \tfrac{1}{2(m+1)} + \tfrac{1}{2(n+1)} \le \tfrac{1}{m+1} + \tfrac{1}{n+1},$$
so $q$ is regular, and $|q_n - r| \le \frac{1}{n+1}$ gives $\hat q = r$ by Theorem 2.5. $\square$

> **Theorem 2.10 (comparison with classical analysis).** Let $\mathbf{R}_{\mathrm{B}}$ be the set of Bishop reals modulo $\equiv$. The map $[x] \mapsto \hat x$ is a well-defined bijection $\mathbf{R}_{\mathrm{B}} \to \mathbb{R}$.

*Proof.* Well-definedness and injectivity are Theorem 2.7 in its two directions; surjectivity is Theorem 2.9. $\square$

Theorem 2.10 is the precise sense in which nothing is lost. The constructive presentation is a presentation of the *same* structure, in which every element carries its own approximation data.

---

## 3. Constructive completeness, and the necessity of the shift

> **Definition 3.1.** A sequence $x : \mathbb{N} \to \{\text{Bishop reals}\}$ is a **regular sequence of reals** if
> $$|\widehat{x_k} - \widehat{x_l}| \;\le\; \frac{1}{k+1} + \frac{1}{l+1} \qquad \text{for all } k,l.$$

> **Theorem 3.2 (constructive completeness).** Let $x$ be a regular sequence of reals. Define
> $$L_n \;:=\; \big(x_{2n+1}\big)_{2n+1} \in \mathbb{Q}.$$
> Then $L$ is a regular sequence of rationals, and its denoted real $\widehat L$ satisfies the explicit rate
> $$|\widehat L - \widehat{x_k}| \;\le\; \frac{1}{k+1} \qquad \text{for all } k.$$

*Proof sketch.* **Regularity.** Write $j' = 2j+1$, so $\frac{1}{j'+1} = \frac{1}{2(j+1)} = \frac12 \cdot \frac{1}{j+1}$. By Theorem 2.4, $|(x_{m'})_{m'} - \widehat{x_{m'}}| \le \frac{1}{2}\cdot\frac{1}{m+1}$, and likewise at $n$. Chaining through $\widehat{x_{m'}}$ and $\widehat{x_{n'}}$ and using Definition 3.1,
$$|L_m - L_n| \le \tfrac12\tfrac{1}{m+1} + \left(\tfrac12\tfrac{1}{m+1} + \tfrac12\tfrac{1}{n+1}\right) + \tfrac12\tfrac{1}{n+1} = \tfrac{1}{m+1} + \tfrac{1}{n+1}.$$
**Rate.** For any $n$, chain $\widehat L \to L_n \to \widehat{x_{2n+1}} \to \widehat{x_k}$, picking up $\frac{1}{n+1}$, $\frac{1}{2(n+1)}$ and $\frac{1}{2(n+1)} + \frac{1}{k+1}$ respectively, giving $|\widehat L - \widehat{x_k}| \le \frac{2}{n+1} + \frac{1}{k+1}$; let $n \to \infty$. $\square$

The shift $n \mapsto 2n+1$ halves each error bar, and each of the two chains above consumes exactly one half. It is therefore not slack:

> **Theorem 3.3 (the shift is necessary).** There is a regular sequence of reals $x$ for which the **unshifted** diagonal $n \mapsto (x_n)_n$ is *not* a regular sequence.

*Proof.* Take
$$(x_k)_n \;=\; \frac{1}{k+1} + (-1)^k \cdot \frac{1}{n+1}.$$
Each $x_k$ is regular: the difference of two of its terms is $(-1)^k\big(\frac{1}{m+1} - \frac{1}{n+1}\big)$, whose absolute value is at most $\max\big(\frac{1}{m+1}, \frac{1}{n+1}\big) \le \frac{1}{m+1} + \frac{1}{n+1}$. By Theorem 2.5 (with $C=1$), $\widehat{x_k} = \frac{1}{k+1}$. Since $\big|\frac{1}{k+1} - \frac{1}{l+1}\big| \le \frac{1}{k+1} + \frac{1}{l+1}$ trivially (both terms are positive), $x$ is a regular sequence of reals. But
$$(x_0)_0 = 1 + 1 = 2, \qquad (x_1)_1 = \tfrac12 - \tfrac12 = 0,$$
so $|(x_0)_0 - (x_1)_1| = 2 > \tfrac{3}{2} = \tfrac{1}{0+1} + \tfrac{1}{1+1}$. $\square$

For the same family the shifted diagonal behaves correctly: since $\widehat{x_k} = \frac1{k+1} \to 0$, Theorem 3.2 forces $\widehat L = 0$ (any $\varepsilon>0$ is beaten by taking $k$ with $\frac{2}{k+1} < \varepsilon$). So the family separates the two constructions rather than merely breaking one.

---

## 4. Computable arithmetic

A Bishop real is a function $\mathbb{N}\to\mathbb{Q}$; if that function is computable, so is the real. The operations below are ordinary recursive definitions, and each is verified against the classical operation via Theorem 2.5.

### 4.1 Constants and negation

The constant sequence $(q)_n = q$ is regular (its differences vanish) and denotes $q$. Negation, $(-x)_n = -x_n$, requires no shift, and $\widehat{-x} = -\hat x$.

### 4.2 Addition

Termwise addition fails: $|(x_m+y_m)-(x_n+y_n)|$ is bounded only by $2(\frac{1}{m+1}+\frac{1}{n+1})$. The remedy is to compute each summand to twice the required accuracy.

> **Definition 4.1.** $(x + y)_n := x_{2n+1} + y_{2n+1}$.

> **Proposition 4.2.** $x+y$ is regular and $\widehat{x+y} = \hat x + \hat y$.

*Proof sketch.* With $\frac{1}{(2j+1)+1} = \frac12\cdot\frac{1}{j+1}$, the triangle inequality gives
$$|(x+y)_m - (x+y)_n| \le |x_{2m+1}-x_{2n+1}| + |y_{2m+1}-y_{2n+1}| \le 2\left(\tfrac12\tfrac{1}{m+1} + \tfrac12\tfrac{1}{n+1}\right),$$
which is exactly the required bound. For the value, $|(x+y)_n - (\hat x + \hat y)| \le \frac12\frac1{n+1} + \frac12\frac1{n+1} = \frac{1}{n+1}$, and Theorem 2.5 applies with $C=1$. $\square$

### 4.3 Multiplication and the canonical bound

Multiplication amplifies error by the size of the factors, so the shift must depend on a bound.

> **Definition 4.3 (canonical bound).** $B_x := \lceil |x_0| \rceil + 2 \in \mathbb{N}$.

> **Lemma 4.4.** $|x_n| \le B_x$ for every $n$, and $B_x \ge 1$.

*Proof.* $|x_n| \le |x_0| + |x_n - x_0| \le |x_0| + \frac{1}{n+1} + 1 \le \lceil|x_0|\rceil + 2$. $\square$

> **Definition 4.5.** With $M := B_x + B_y$ set $\mu(n) := M(n+1)$ and
> $$(x \cdot y)_n := x_{\mu(n)} \cdot y_{\mu(n)}.$$

> **Proposition 4.6.** $x\cdot y$ is regular and $\widehat{x\cdot y} = \hat x \cdot \hat y$.

*Proof sketch.* Write $a=\mu(m)$, $b=\mu(n)$ and split
$$x_ay_a - x_by_b = x_a(y_a-y_b) + y_b(x_a-x_b),$$
so that by Lemma 4.4,
$$|x_ay_a - x_by_b| \;\le\; (B_x + B_y)\left(\tfrac{1}{a+1}+\tfrac{1}{b+1}\right).$$
The key arithmetic fact is
$$M \cdot \frac{1}{\mu(n)+1} = \frac{M}{M(n+1)+1} \;\le\; \frac{1}{n+1},$$
valid since $M \ge 1$; applying it at $m$ and at $n$ yields the regularity bound. For the value one splits $(x\cdot y)_n - \hat x\hat y = x_a(y_a - \hat y) + \hat y(x_a - \hat x)$ and uses $\frac{1}{a+1}\le\frac{1}{n+1}$ (because $\mu(n)\ge n$), obtaining the hypothesis of Theorem 2.5 with $C = B_x + |\hat y|$. $\square$

### 4.4 A concrete computable irrational

> **Definition 4.7.** $\displaystyle (\sqrt2)_n := \frac{\big\lfloor \sqrt{2(n+1)^2}\big\rfloor}{n+1}$, where $\lfloor\sqrt{\cdot}\rfloor$ denotes the integer square root.

> **Proposition 4.8.** $\sqrt2$ as defined is a regular sequence of rationals, and its denoted real is the classical $\sqrt2$; in particular $(\widehat{\sqrt2})^2 = 2$.

*Proof sketch.* Put $s = \lfloor\sqrt{2m^2}\rfloor$, so $s^2 \le 2m^2 < (s+1)^2$, whence $s \le \sqrt2\,m < s+1$ and therefore
$$\left|\frac{s}{m} - \sqrt2\right| \le \frac{1}{m}. \tag{4.1}$$
With $m = n+1$ this reads $|(\sqrt2)_n - \sqrt2| \le \frac{1}{n+1}$; regularity follows by the triangle inequality through $\sqrt2$, and Theorem 2.5 with $C=1$ identifies the denoted real. $\square$

The definition uses integer arithmetic only. For instance $(\sqrt2)_4 = 7/5$ and $(\sqrt2)_{99} = 141/100$, both exactly as (4.1) predicts.

---

## 5. The constructive order

### 5.1 Definitions with positive content

> **Definition 5.1.** For Bishop reals $x,y$:
> - $x$ is **positive**, written $\mathrm{Pos}(x)$, iff $\exists n:\ x_n > \frac{1}{n+1}$;
> - $x < y$ iff $\exists n:\ x_n + \frac{2}{n+1} < y_n$.

Both are existential statements about *rational* data, so a proof is a natural number together with a decidable rational inequality. From a witness one reads off a rational lower bound on the gap:

> **Definition 5.2.** $g_n(x,y) := y_n - x_n - \frac{2}{n+1} \in \mathbb{Q}$.

> **Lemma 5.3.** If $n$ witnesses $x<y$ then $g_n(x,y) > 0$ and $g_n(x,y) \le \hat y - \hat x$.

*Proof.* By (2.1), $\hat x \le x_n + \frac1{n+1}$ and $\hat y \ge y_n - \frac1{n+1}$, so $\hat y - \hat x \ge y_n - x_n - \frac{2}{n+1}$. $\square$

> **Theorem 5.4 (extensionality of the order).** $\mathrm{Pos}(x) \iff \hat x > 0$, and $x<y \iff \hat x < \hat y$.

*Proof sketch.* ($\Rightarrow$) is Lemma 5.3 (resp. its one-sided analogue). ($\Leftarrow$) Given $\hat y - \hat x > 0$, choose $n$ with $\frac{4}{n+1} < \hat y - \hat x$; then by (2.1),
$$y_n - x_n \;\ge\; (\hat y - \tfrac1{n+1}) - (\hat x + \tfrac1{n+1}) \;>\; \tfrac{4}{n+1} - \tfrac{2}{n+1} = \tfrac{2}{n+1}. \qquad\square$$

Thus the constructive relations are not weaker as relations; they are *stronger as proofs*. Irreflexivity, transitivity and asymmetry follow at once from Theorem 5.4.

### 5.2 Cotransitivity: the constructive substitute for trichotomy

Classically $x<y$ implies, for any $z$, that $x<z$ or $z<y$ (indeed both alternatives can hold). Constructively this must be *decided*, and it can be:

> **Theorem 5.5 (cotransitivity, explicit form).** Let $n$ witness $x<y$, with gap $g := g_n(x,y) > 0$. Let $m$ be **any** index with $\frac{1}{m+1} \le \frac{g}{8}$. Then for every Bishop real $z$:
> $$\frac{x_m + y_m}{2} \le z_m \;\Longrightarrow\; x < z \ \text{(witnessed at } m), \qquad z_m < \frac{x_m + y_m}{2} \;\Longrightarrow\; z < y \ \text{(witnessed at } m).$$

*Proof sketch.* First, the gap survives to index $m$: by Lemma 5.3 and (2.1) at $m$,
$$y_m - x_m \;\ge\; (\hat y - \tfrac{1}{m+1}) - (\hat x + \tfrac{1}{m+1}) \;\ge\; g - \tfrac{2}{m+1} \;\ge\; g - \tfrac{g}{4} \;=\; \tfrac{3g}{4}. \tag{5.1}$$
Second, the tolerance at $m$ is small: $\frac{2}{m+1} \le \frac{g}{4}$. Now if $z_m \ge \frac{x_m+y_m}{2}$ then, using (5.1),
$$z_m - x_m \;\ge\; \frac{y_m - x_m}{2} \;\ge\; \frac{3g}{8} \;>\; \frac{g}{4} \;\ge\; \frac{2}{m+1},$$
which is exactly the witness condition for $x<z$ at $m$. The other case is symmetric. $\square$

The arithmetic above in fact only needs $\frac{1}{m+1} < g/6$; the constant $8$ is chosen for a clean non-strict hypothesis. Whether $6$ is optimal is stated as a conjecture in §10.

> **Corollary 5.6.** If $x<y$ then for every $z$, $x<z$ or $z<y$. (Choose any $m$ with $\frac1{m+1}\le g/8$; such $m$ exists and is computed from $g$.)

### 5.3 Location between rationals

> **Theorem 5.7 (constructive location).** Let $a<b$ be rationals and $x$ a Bishop real. Let $m$ satisfy $\frac{4}{m+1} \le b-a$. Then
> $$\frac{a+b}{2} \le x_m \;\Longrightarrow\; a < \hat x, \qquad x_m < \frac{a+b}{2} \;\Longrightarrow\; \hat x < b.$$
> In particular $a<\hat x$ or $\hat x < b$, decided by one rational comparison.

*Proof sketch.* If $x_m \ge \frac{a+b}{2}$ then by (2.1), $\hat x \ge \frac{a+b}{2} - \frac{1}{m+1} \ge \frac{a+b}{2} - \frac{b-a}{4} = a + \frac{b-a}{4} > a$. The other case is symmetric. $\square$

The classically trivial dichotomy $a<\hat x$ or $\hat x \le a$ is *not* available; Theorem 5.7 is its constructive replacement, and the price is the overlap on $(a,b)$.

### 5.4 The order is not decidable at bounded precision

> **Theorem 5.8 (no uniform witness bound).** For every $N \in \mathbb{N}$ there exist Bishop reals $x<y$ such that no index $n \le N$ witnesses $x<y$.

*Proof.* Take $x$ the constant $0$ and $y$ the constant $\frac{1}{N+1}$. Then $\hat x < \hat y$, so $x<y$ by Theorem 5.4. But for $n \le N$,
$$x_n + \frac{2}{n+1} = \frac{2}{n+1} \;\ge\; \frac{2}{N+1} \;>\; \frac{1}{N+1} = y_n,$$
so $n$ is not a witness. $\square$

This is the exact sense in which the order, though extensionally the classical order (Theorem 5.4), is not decidable from bounded data: any algorithm that inspects only $x_0,\dots,x_N$ and $y_0,\dots,y_N$ can be defeated.

---

## 6. The intermediate value theorem

### 6.1 Continuity with a modulus

> **Definition 6.1.** $\omega : \mathbb{R}\to\mathbb{R}$ is a **modulus of uniform continuity** for $f$ on $s \subseteq \mathbb{R}$ if for every $\varepsilon>0$: $\omega(\varepsilon)>0$, and for all $x,y \in s$ with $|x-y|\le\omega(\varepsilon)$ one has $|f(x)-f(y)|\le\varepsilon$.

Every function with a modulus is uniformly continuous on $s$ in the ordinary sense; the modulus is the constructive *datum* rather than a consequence. Every Lipschitz function with constant $1$ has the modulus $\omega = \mathrm{id}$; the map $x \mapsto cx$ with $c>0$ has $\omega(\varepsilon)=\varepsilon/c$.

Write $G_k := a + k\frac{b-a}{N}$ for the $k$-th point of the uniform grid of $N$ subintervals of $[a,b]$, so $G_0=a$, $G_N=b$, $G_{k+1}-G_k = \frac{b-a}{N}$, and $G_k \in [a,b]$ for $k \le N$.

### 6.2 The approximate theorem

> **Theorem 6.2 (approximate IVT with explicit modulus).** Let $a \le b$, let $\omega$ be a modulus for $f$ on $[a,b]$, let $\varepsilon>0$, let $N \ge 1$ with mesh $\frac{b-a}{N} \le \omega(\varepsilon)$, and suppose $f(a)\le 0 \le f(b)$. Then there is $k \le N$ with $|f(G_k)| \le \varepsilon$.

*Proof.* Let $S := \{k \le N : f(G_k) \le 0\}$. It is nonempty ($0 \in S$ since $f(G_0)=f(a)\le 0$) and finite; let $k^\ast := \max S$.

*Case $k^\ast = N$.* Then $f(b) \le 0 \le f(b)$, so $f(G_{k^\ast}) = 0$ and $|f(G_{k^\ast})| = 0 \le \varepsilon$.

*Case $k^\ast < N$.* Then $k^\ast+1 \le N$ and $k^\ast+1 \notin S$, i.e. $f(G_{k^\ast+1}) > 0$. Both grid points lie in $[a,b]$ and $|G_{k^\ast} - G_{k^\ast+1}| = \frac{b-a}{N} \le \omega(\varepsilon)$, so $|f(G_{k^\ast+1}) - f(G_{k^\ast})| \le \varepsilon$; combined with $f(G_{k^\ast+1}) > 0$ this gives $f(G_{k^\ast}) \ge -\varepsilon$. Since also $f(G_{k^\ast}) \le 0$, we conclude $|f(G_{k^\ast})| \le \varepsilon$. $\square$

The witness is explicit and the cost is $N+1$ evaluations. An admissible $N$ always exists: any $N > \frac{b-a}{\omega(\varepsilon)}$ will do.

> **Corollary 6.3.** Under the hypotheses of Theorem 6.2 minus the choice of $N$: for every $\varepsilon>0$ there is $x \in [a,b]$ with $|f(x)|\le\varepsilon$.

### 6.3 From small values to small distances

> **Definition 6.4 (slope bound).** $f$ has **slope bound $c$** on $s$ if for all $x \le y$ in $s$, $\;f(y)-f(x) \ge c\,(y-x)$.

> **Theorem 6.5 (root modulus).** Let $c>0$ be a slope bound for $f$ on $[a,b]$, let $r \in [a,b]$ with $f(r)=0$, and let $x \in [a,b]$ with $|f(x)|\le\varepsilon$. Then
> $$|x-r| \;\le\; \frac{\varepsilon}{c}.$$

*Proof.* If $r \le x$, the slope bound gives $c(x-r) \le f(x)-f(r) = f(x) \le \varepsilon$, hence $x - r \le \varepsilon/c$. If $x \le r$, it gives $c(r-x) \le f(r)-f(x) = -f(x) \le \varepsilon$, hence $r - x \le \varepsilon/c$. $\square$

> **Corollary 6.6 (uniqueness).** Under a positive slope bound, $f$ has at most one root in $[a,b]$. (Take $\varepsilon=0$ in Theorem 6.5.)

> **Theorem 6.7 (sharpness of the root modulus).** For every $c>0$ and every $\varepsilon>0$ with $\varepsilon/c \le 1$ there is a function $f$ on $[-1,1]$ with a modulus of uniform continuity, slope bound $c$, $f(-1)\le 0 \le f(1)$, a root $r \in [-1,1]$, and a point $x \in [-1,1]$ with $|f(x)|\le\varepsilon$ and
> $$|x-r| \;=\; \frac{\varepsilon}{c}.$$
> Consequently no constant $\kappa<1$ makes "$|f(x)|\le\varepsilon \Rightarrow |x-r| \le \kappa\varepsilon/c$" valid.

*Proof.* Take $f(x)=cx$, which has modulus $\omega(\eta)=\eta/c$ and slope bound exactly $c$; $r=0$ and $x=\varepsilon/c$. Then $|f(x)|=\varepsilon$ and $|x-r|=\varepsilon/c$. For the second claim, specialise to $c=\varepsilon=1$, $f(x)=x$ on $[-1,1]$, $r=0$, $x=1$: any valid $\kappa$ would give $1 \le \kappa$. $\square$

### 6.4 The exact theorem, with explicit modulus

> **Theorem 6.8 (constructive IVT with explicit modulus).** Let $a\le b$, $c>0$, let $\omega$ be a modulus for $f$ on $[a,b]$, let $c$ be a slope bound for $f$ on $[a,b]$, and let $f(a)\le 0\le f(b)$. Then there is $r \in [a,b]$ with $f(r)=0$, and for every $\delta>0$ and every $N\ge1$ with mesh $\frac{b-a}{N} \le \omega(c\delta)$, some grid point satisfies
> $$|G_k - r| \;\le\; \delta.$$
> The **modulus of the root** is therefore $\delta \mapsto \omega(c\delta)$.

*Proof.* Existence of $r$ follows from continuity and the sign change. Given $\delta$ and an admissible $N$, apply Theorem 6.2 with $\varepsilon := c\delta$ to obtain $k \le N$ with $|f(G_k)| \le c\delta$; then Theorem 6.5 gives $|G_k - r| \le c\delta/c = \delta$. $\square$

> **Theorem 6.9 (the root is a Bishop real).** Under the hypotheses of Theorem 6.8 with rational endpoints $a,b$, there is a Bishop real $x$ such that $\hat x \in [a,b]$, $f(\hat x)=0$, and each approximation $x_n$ is a **rational grid point** $a + k\frac{b-a}{N}$ for explicitly computed $N \ge 1$ and $k \le N$.

*Proof sketch.* For each $n$, apply Theorem 6.8 with $\delta = \frac{1}{2(n+1)}$ to obtain a rational grid point $q_n$ with $|q_n - r| \le \frac{1}{2(n+1)}$. Then
$$|q_m-q_n| \le |q_m-r| + |r-q_n| \le \tfrac{1}{2(m+1)}+\tfrac{1}{2(n+1)} \le \tfrac{1}{m+1}+\tfrac{1}{n+1},$$
so $q$ is regular; and $|q_n - r| \le \frac{1}{n+1}$ identifies $\hat q = r$ by Theorem 2.5. $\square$

So the root is not merely asserted to exist: it is produced as a regular sequence of rationals, each term of which the finite grid search of Theorem 6.2 computes.

### 6.5 Bracketing: what the search delivers with no hypotheses

Theorem 6.5 converts a small *value* into a small *distance*, and that is where the slope bound is spent. But the search of Theorem 6.2 produces more than a small value: it produces a *sign bracket*, and a bracket localises a root by itself.

> **Theorem 6.10 (bracketing form of the search).** Let $a\le b$, let $\omega$ be a modulus for $f$ on $[a,b]$, let $N\ge1$, and let $f(a)\le0\le f(b)$. With **no** further hypothesis, the largest grid index $k^\ast$ with $f(G_{k^\ast})\le0$ satisfies: there exists a root $r \in [a,b]$ of $f$ with
> $$|G_{k^\ast} - r| \;\le\; \frac{b-a}{N}.$$

*Proof.* As in Theorem 6.2. If $k^\ast=N$, then $r=b=G_{k^\ast}$ works. Otherwise $f(G_{k^\ast}) \le 0 < f(G_{k^\ast+1})$; $f$ is continuous on $[G_{k^\ast},G_{k^\ast+1}] \subseteq [a,b]$, so it has a root $r$ in that subinterval, whose length is one mesh. $\square$

The accuracy of the *location* is the mesh — no slope bound, no non-degeneracy. The constructive content is that the bracket is found by a finite search; extracting the root from the bracket is where classical completeness enters, and that is precisely the boundary §7 charts.

### 6.6 Local non-constancy is not enough

Bishop's exact IVT replaces the slope bound by *local non-constancy*: an explicit $\nu$ such that on every interval of length $\ge h$, $f$ attains absolute value $\ge \nu(h)$. This suffices to rule out flat shelves, but it does *not* license the inference from small values to small distances.

> **Theorem 6.11.** For every $\delta \in (0,2)$ there is a $1$-Lipschitz $f$ on $[0,4]$ with $f(0)\le0\le f(4)$, satisfying local non-constancy with the explicit modulus $\nu(h)=h/8$, together with a point $x \in [0,4]$ such that $|f(x)| \le \nu(\delta)/2$ while $|x-r| > \delta$ for **every** root $r$ of $f$.

*Proof sketch.* Take $\eta := \delta/32$ and
$$D_\eta(x) := \min\big(x-1,\ |x-3|+\eta\big), \qquad x \in [0,4].$$
It is $1$-Lipschitz as a min of $1$-Lipschitz functions; $D_\eta(0)\le -1<0$ and $D_\eta(4)\ge 0$. Its only root is $x=1$: if $D_\eta(r)=0$ then either $r-1=0$, or $|r-3|+\eta=0$, impossible for $\eta>0$. Local non-constancy with $\nu(h)=h/8$: in any interval of length $\ge h$ one finds a point $z$ at distance $\ge h/8$ from both critical points $1$ and $3$ (three probes at $x$, $x+h/3$, $x+2h/3$ cannot all be within $h/8$ of $\{1,3\}$, by the pigeonhole and the spacing), and at such $z$ one checks $|D_\eta(z)| \ge h/8$. Finally $D_\eta(3) = \min(2, \eta) = \eta = \delta/32 \le \nu(\delta)/2 = \delta/16$, while $|3-1|=2 > \delta$. $\square$

The function has a *near-root* of depth $\eta$ at $x=3$, arbitrarily shallow, at distance $2$ from the true root. This is the precise obstruction that the slope bound of Theorem 6.5 removes.

---

## 7. Brouwerian counterexamples: the exact IVT has no effective solution

### 7.1 The shelf family

> **Definition 7.1.** For $t \in [-1,1]$ define $S_t : [0,3]\to\mathbb{R}$ by
> $$S_t(x) := \min\big(x-1,\ \max(t,\ x-2)\big).$$

> **Lemma 7.2.** Each $S_t$ is $1$-Lipschitz, hence has the modulus $\omega=\mathrm{id}$ uniformly in $t$; and $S_t(0)\le0\le S_t(3)$.

*Proof.* $|\min(u_1,v_1)-\min(u_2,v_2)| \le \max(|u_1-u_2|,|v_1-v_2|)$ and likewise for $\max$; apply with $u_i = x_i-1$, $v_i = \max(t,x_i-2)$. For the endpoints: $S_t(0)\le 0-1 <0$, and $S_t(3) = \min(2,\max(t,1)) \ge 0$. $\square$

Consequently Theorem 6.2 applies to the whole family with a mesh depending on $\varepsilon$ alone: for every $t$ and $\varepsilon>0$, any $N$ with $3/N \le \varepsilon$ yields a grid point of $[0,3]$ with $|S_t| \le \varepsilon$. The approximate theorem is uniformly effective on the family.

### 7.2 Where the roots are

> **Lemma 7.3.** (i) If $1<x<2$ and $S_t(x)=0$ then $t=0$. (ii) If $t>0$ and $S_t(x)=0$ then $x=1$. (iii) If $t<0$ and $S_t(x)=0$ then $x=2$. (iv) Every root of every $S_t$ lies in $[1,2]$.

*Proof sketch.* All four are finite case analyses on which branch of the $\min$ and the $\max$ is active. For (i): if the active branch is $x-1$, then $x=1$, contradicting $x>1$; so $\max(t,x-2)=0$, and since $x-2<0$ the max must be $t$, giving $t=0$. For (ii): if the active branch were $\max(t,x-2)$, its value would be $\ge t > 0$, not $0$; so the active branch is $x-1$ and $x=1$. For (iii): if the active branch were $x-1$ then $x=1$, and $\max(t,-1)<0$ since $t<0$, so the minimum would be negative, not $0$; hence $\max(t,x-2)=0$, and $t<0$ forces $x-2=0$, i.e. $x=2$. For (iv): $x-1 \ge S_t(x) = 0$ gives $x \ge 1$; and either the active branch is $x-1$, whence $x=1\le2$, or $\max(t,x-2)=0 \ge x-2$, whence $x \le 2$. $\square$

So the root set jumps: $\{1\}$ for $t>0$, $[1,2]$ at $t=0$, $\{2\}$ for $t<0$.

### 7.3 No continuous selector

> **Theorem 7.4.** There is no continuous $r : [-1,1] \to \mathbb{R}$ with $S_t(r(t))=0$ for all $t \in [-1,1]$.

*Proof.* Suppose such an $r$ exists. By Lemma 7.3(ii)–(iii), $r(1)=1$ and $r(-1)=2$. By the *classical* intermediate value theorem applied to the continuous $r$ on $[-1,1]$, the image $r([-1,1])$ contains $[1,2]$; pick $t_0$ with $r(t_0)=\frac32$ and $t_1$ with $r(t_1)=\frac74$. Both values lie strictly between $1$ and $2$, so Lemma 7.3(i) gives $t_0=0$ and $t_1=0$. Then $\frac32 = r(0) = \frac74$, a contradiction. $\square$

Since every constructively defined function $\mathbb{R}\to\mathbb{R}$ is (pointwise, hence on compacta uniformly) continuous, Theorem 7.4 rules out any constructive proof of the exact IVT from the data "modulus of uniform continuity + sign change". It also identifies the missing hypothesis:

> **Proposition 7.5.** If $c$ is a slope bound for $S_0$ on $[0,3]$ then $c \le 0$.

*Proof.* $S_0(1)=S_0(2)=0$, so the slope bound at $x=1$, $y=2$ reads $c \cdot 1 \le 0$. $\square$

That is, the shelf family violates precisely the hypothesis of Theorem 6.8, at precisely the critical parameter.

### 7.4 Quantitative failure: no selector at all is nearly continuous

Theorem 7.4 excludes continuous selectors. In fact no selector, of any kind, is even approximately continuous at $t=0$.

> **Theorem 7.6 (oscillation bound).** Let $r$ be **any** function with $S_t(r(t))=0$ for all $t \in [-1,1]$. Then for every $\eta>0$, on the parameter window $T_\eta := [-1,1]\cap[-\eta,\eta]$,
> $$\sup r(T_\eta) \;-\; \inf r(T_\eta) \;\ge\; 1.$$

*Proof.* By Lemma 7.3(iv) the image $r(T_\eta)$ is contained in $[1,2]$, so both sup and inf exist. Put $s := \min(\eta,1) > 0$; then $s, -s \in T_\eta$. By Lemma 7.3(ii), $r(s)=1$; by Lemma 7.3(iii), $r(-s)=2$. Hence $\sup r(T_\eta) \ge 2$ and $\inf r(T_\eta) \le 1$. $\square$

The hypothesis is not vacuous: classically, selectors exist — e.g. $r(t)=2$ for $t<0$ and $r(t)=1$ otherwise — and Theorem 7.6 says every one of them jumps by at least a full unit at $0$. The failure of the exact IVT is not a delicate matter of definability; it is a discontinuity of fixed size $1$ that no choice can avoid.

---

## 8. The constructive least upper bound principle

### 8.1 Located sets

The classical construction of $\sup S$ decides, for a rational $q$, whether $q$ is an upper bound. Bishop demands that this decision be part of the data, in a deliberately *overlapping* form.

> **Definition 8.1 (located set).** A **located datum** for $S \subseteq \mathbb{R}$ is a function $L : \mathbb{Q}\times\mathbb{Q} \to \{\mathsf{true},\mathsf{false}\}$ such that for all rationals $p<q$:
> - if $L(p,q)=\mathsf{true}$ then $q$ is an upper bound of $S$;
> - if $L(p,q)=\mathsf{false}$ then some $s \in S$ satisfies $s > p$.

Both alternatives may hold simultaneously (when $p < \sup S \le q$); the oracle need only return a correct one. This is what makes located data available in practice: for the half-line $S = (-\infty,c]$ with $c \in \mathbb{Q}$, the decidable test $L(p,q) := (c \le q)$ is a located datum, since $c \le q$ makes $q$ an upper bound and $q<c$ makes $c \in S$ exceed $p<q<c$.

> **Definition 8.2 (enclosure).** A pair $(p,q) \in \mathbb{Q}^2$ **encloses** $S$ if $q$ is an upper bound of $S$ and some $s \in S$ has $s>p$.

### 8.2 Trisection

> **Definition 8.3.** One trisection step: given $(p,q)$, let $m_1 = p+\frac{q-p}{3}$, $m_2 = p+\frac{2(q-p)}{3}$, and set
> $$T(p,q) := \begin{cases} (p, m_2) & \text{if } L(m_1,m_2)=\mathsf{true},\\ (m_1, q) & \text{otherwise.}\end{cases}$$
> Let $(p_n,q_n) := T^n(p_0,q_0)$.

> **Theorem 8.4 (exact geometric rate).** $\;q_n - p_n = \left(\frac23\right)^n (q_0-p_0)$ for all $n$.

*Proof.* Each step replaces the width $w$ by $\frac23 w$ in both branches: $m_2 - p = \frac23 w$ and $q - m_1 = \frac23 w$. Induct. $\square$

> **Theorem 8.5 (enclosure invariant).** If $p_0<q_0$ and $(p_0,q_0)$ encloses $S$, then $(p_n,q_n)$ encloses $S$ for every $n$.

*Proof.* Induction. Widths stay positive by Theorem 8.4, so $m_1<m_2$ and the oracle guarantee applies. On $\mathsf{true}$, $m_2$ becomes an upper bound (oracle clause 1) and the left endpoint is unchanged, so the witness survives; on $\mathsf{false}$, some $s>m_1$ exists (oracle clause 2) and the right endpoint is unchanged, so the upper bound survives. $\square$

> **Theorem 8.6 (constructive least upper bound principle).** Let $S$ have a located datum, let $p_0<q_0$ with $(p_0,q_0)$ enclosing $S$. Then $S$ has a least upper bound $u$, and for every $n$
> $$p_n \le u \le q_n, \qquad q_n - p_n = \left(\tfrac23\right)^n(q_0-p_0).$$

*Proof sketch.* $S$ is nonempty (the witness at $p_0$) and bounded above (by $q_0$), so $u := \sup S$ exists classically. By Theorem 8.5, at each $n$ some $s \in S$ has $s>p_n$, whence $u \ge s > p_n$; and $q_n$ is an upper bound, whence $u \le q_n$. The width is Theorem 8.4. $\square$

> **Theorem 8.7 (the supremum is a Bishop real).** Under the hypotheses of Theorem 8.6 there is a Bishop real $x$ with $\hat x = \sup S$, whose $k$-th approximation $x_k$ is the left endpoint $p_{n(k)}$ of the first trisection stage with $\left(\frac23\right)^{n}(q_0-p_0) \le \frac{1}{k+1}$.

*Proof sketch.* Such an $n(k)$ exists since $(2/3)^n \to 0$. Then $|p_{n(k)} - u| \le q_{n(k)}-p_{n(k)} \le \frac{1}{k+1}$; regularity follows by the triangle inequality through $u$, and Theorem 2.5 with $C=1$ identifies $\hat x = u$. $\square$

Finally, the classical content of the located hypothesis:

> **Proposition 8.8 (comparison).** Classically, every $S$ has a located datum, namely $L(p,q) := $ "$q$ is an upper bound of $S$". Hence Theorem 8.6 is classically equivalent to ordinary order-completeness, and its entire constructive content lies in the extra datum.

### 8.3 The optimal contraction ratio of a one-query search

Trisection contracts by $\frac23$ per oracle call. Is that optimal? Consider the general scheme.

> **Definition 8.9 (one-query search).** Fix rationals $0<\alpha<\beta<1$. One step: given $(p,q)$ with $w := q-p$,
> $$T_{\alpha,\beta}(p,q) := \begin{cases} \big(p,\ p+\beta w\big) & \text{if } L(p+\alpha w,\ p+\beta w)=\mathsf{true},\\[2pt] \big(p+\alpha w,\ q\big) & \text{otherwise.}\end{cases}$$

Trisection is $(\alpha,\beta)=(\frac13,\frac23)$.

> **Theorem 8.10 (invariant and contraction).** For $0<\alpha<\beta<1$ and $p_0<q_0$ enclosing $S$: every stage of $T_{\alpha,\beta}$ encloses $S$, the widths remain strictly positive, and
> $$q_n - p_n \;\le\; \big(\max(\beta,\,1-\alpha)\big)^{n}\,(q_0-p_0).$$

*Proof sketch.* The invariant is Theorem 8.5 verbatim, using $\alpha<\beta$ (so the two query points are distinct and ordered, as the oracle requires) and positivity of the width. For the rate: on $\mathsf{true}$ the new width is $\beta w$, on $\mathsf{false}$ it is $(1-\alpha)w$; both are $\le \max(\beta,1-\alpha)\,w$. Positivity: $\beta>0$ and $1-\alpha>0$. Induct. $\square$

The bound is attained in the worst case: an adversarial oracle answering $\mathsf{true}$ when $\beta \ge 1-\alpha$ and $\mathsf{false}$ otherwise realises the factor exactly at every step.

> **Theorem 8.11 (trisection is not optimal).** With $(\alpha,\beta)=(\frac25,\frac12)$ the scheme preserves the enclosure invariant and contracts by
> $$\max\left(\tfrac12,\ 1-\tfrac25\right) = \tfrac35 \;<\; \tfrac23$$
> per oracle call.

> **Theorem 8.12 (the barrier $\frac12$).** For all $\alpha<\beta$, $\;\max(\beta,1-\alpha) > \frac12$. Conversely, for every $\eta>0$ there is an admissible pair with $\max(\beta,1-\alpha)<\frac12+\eta$.

*Proof.* If $\beta > \frac12$ we are done. Otherwise $\alpha < \beta \le \frac12$, so $1-\alpha > \frac12$. For the converse, put $t := \min(\eta,\frac14)>0$ and take $\alpha = \frac12-\frac t2$, $\beta=\frac12+\frac t2$; these satisfy $0<\alpha<\beta<1$ and
$$\max(\beta, 1-\alpha) = \max\left(\tfrac12+\tfrac t2,\ \tfrac12+\tfrac t2\right) = \tfrac12+\tfrac t2 < \tfrac12+\eta. \qquad\square$$

The interpretation is information-theoretic. One yes/no query splits the interval at two points; a $\mathsf{true}$ keeps the left $\beta$-fraction, a $\mathsf{false}$ the right $(1-\alpha)$-fraction, and these two fractions overlap in $[\alpha,\beta]$ — necessarily, since a legitimate query requires $\alpha<\beta$. The overlap is the cost of the oracle's freedom to answer either way in the ambiguous region. As $\beta-\alpha \to 0$ the overlap vanishes and each answer halves the interval, but the limiting query $\alpha=\beta$ is not admissible. Hence $\frac12$ is an infimum that is approached and never attained, and the "one bit per query" of an idealised bisection is unreachable for located suprema.

---

## 9. Algorithms

The development yields four algorithms, all elementary and all with proved error bounds.

**A1. Grid root search.** Input: $f$, $[a,b]$, modulus $\omega$, accuracy $\varepsilon$. Choose $N > (b-a)/\omega(\varepsilon)$. Evaluate $f$ at $G_0,\dots,G_N$, return the largest $k$ with $f(G_k)\le 0$. Cost $O(N)$ evaluations, $N = O\big(\tfrac{b-a}{\omega(\varepsilon)}\big)$. Guarantee: $|f(G_k)| \le \varepsilon$ (Theorem 6.2), and $G_k$ is within one mesh of a genuine root (Theorem 6.10). Under a slope bound $c$, running with $\varepsilon = c\delta$ gives $|G_k - r|\le\delta$ (Theorem 6.8).

**A2. Bishop arithmetic.** Represent a real by its approximation function. Add with index $2n+1$; multiply with index $(B_x+B_y)(n+1)$ after computing $B_x = \lceil|x_0|\rceil+2$. Requesting accuracy $\frac{1}{n+1}$ from a product costs one evaluation of each factor at index $\Theta(Mn)$; the precision blow-up is linear in the magnitude bound.

**A3. Located supremum search.** Input: oracle $L$, bracket $(p_0,q_0)$, target accuracy $\tau$. Iterate $T_{\alpha,\beta}$ until $q_n-p_n \le \tau$. Number of oracle calls $\lceil \log(\tau/(q_0-p_0)) / \log \max(\beta,1-\alpha)\rceil$; with $(\frac25,\frac12)$ this is $\log_{5/3}$ rather than $\log_{3/2}$, a constant-factor saving of $\log(3/2)/\log(5/3) \approx 0.794$ in the number of calls.

**A4. Cotransitive comparison.** Input: $x,y$ with witness index $n$ for $x<y$, and $z$. Compute $g = y_n - x_n - \frac{2}{n+1}$; choose $m$ with $\frac1{m+1}\le \frac g8$, i.e. $m = \lceil 8/g\rceil$; compare $z_m$ with $\frac{x_m+y_m}{2}$. Cost: three approximation queries at index $O(1/g)$ and one rational comparison. Output: a certified witness for $x<z$ or for $z<y$ (Theorem 5.5).

---

## 10. Discussion and open problems

### 10.1 What the sharp constants say

Every principal theorem above carries a constant, and in each case we have determined the constant or bracketed it.

| Quantity | Value proved | Status |
|---|---|---|
| Approximation error of $x_n$ | $\frac{1}{n+1}$ | exact (Theorem 2.4) |
| Completeness diagonal shift | $n \mapsto 2n+1$ | necessary (Theorem 3.3) |
| Product index shift | $(B_x+B_y)(n+1)$, $B_x = \lceil|x_0|\rceil+2$ | sufficient; see C3 below |
| Root modulus under slope $c$ | $\varepsilon/c$ | attained, no $\kappa<1$ (Theorem 6.7) |
| Location accuracy of sign search | one mesh $\frac{b-a}{N}$ | no hypotheses (Theorem 6.10) |
| Shelf-selector oscillation | $\ge 1$ near $t=0$ | for every selector (Theorem 7.6) |
| Trisection contraction | exactly $(2/3)^n$ | not optimal (Theorem 8.11) |
| One-query contraction | $\max(\beta,1-\alpha)$ | infimum $\frac12$, unattained (Theorem 8.12) |
| Cotransitivity threshold | $\frac1{m+1}\le g/8$ (proof needs $g/6$) | see C2 below |

The pattern is that the constructive versions are not weaker statements but *more informative* ones, and that the extra information is exactly what a numerical implementation would have to supply anyway.

### 10.2 Relation to the classical theory

Theorem 2.10 shows that the constructive number system is the classical one; Theorem 5.4 shows the same for the order; Proposition 8.8 shows that the least upper bound principle differs from classical completeness only by the located datum; and Theorem 6.8's hypotheses (modulus + slope bound) are strictly stronger than continuity + sign change, with Theorems 7.4 and 7.6 showing that the strengthening is unavoidable. So the picture is uniform: constructive analysis adds *data* to hypotheses and *rates* to conclusions, and it is precisely the theorems whose classical proof consumes an undecidable case split — the exact IVT, unrestricted completeness — that require the added data.

### 10.3 Future directions

Three concrete, falsifiable conjectures suggested by the development. Each is settled by a single proof or a single counterexample.

**C1 (batched queries).** Theorem 8.12 shows the optimal contraction of a *one-query* located search is the unattained infimum $\frac12$. The natural generalisation queries the oracle $k$ times per step, at pairs $\big(p+\alpha_i w,\ p+\beta_i w\big)$ with $\alpha_1<\beta_1\le\alpha_2<\beta_2\le\cdots<\beta_k$, keeping the smallest enclosure the $k$ answers certify.

> **Conjecture.** The worst-case contraction factor of any such $k$-query scheme is $>\frac{1}{k+1}$, and for every $\eta>0$ some $k$-query scheme achieves a factor $<\frac{1}{k+1}+\eta$. In particular the per-query efficiency $(\text{contraction})^{1/k} \to 0$ as $k\to\infty$: batching strictly pays.

Falsifiable by exhibiting a $k$-query scheme (say $k=2$) that preserves the enclosure invariant and contracts by $\le \frac{1}{k+1}$, or by proving that no $2$-query scheme beats $\frac25$.

**C2 (the cotransitivity threshold).** Theorem 5.5 decides $x<z$ or $z<y$ at any index $m$ with $\frac1{m+1}\le g/8$; the arithmetic of the proof needs only $\frac1{m+1}<g/6$.

> **Conjecture.** $6$ is optimal: for every $\kappa<6$ there are $x,y,z$ and indices $n,m$ with $\frac1{m+1}\le g_n(x,y)/\kappa$ for which the midpoint test at $m$ decides neither $x<z$ nor $z<y$ — while the conclusion of Theorem 5.5 does hold under $\frac{1}{m+1}<g/6$.

Falsifiable by a proof with a constant $\kappa<6$, or by an explicit triple defeating $6$.

**C3 (the canonical bound).** Definition 4.3 uses $B_x = \lceil|x_0|\rceil+2$, and Lemma 4.4's slack comes only from $n=0$, since $|x_n - x_0| \le \frac1{n+1}+1 \le 2$ with strict inequality for $n\ge1$.

> **Conjecture.** Replacing $B_x$ by $\lceil|x_0|\rceil+1$ still yields a regular sequence in Definition 4.5, with Proposition 4.6 intact; and the constant $1$ is then optimal, i.e. $\lceil|x_0|\rceil$ alone fails for some pair of Bishop reals.

Falsifiable by a pair $x,y$ for which the $+1$ definition violates regularity, or by a pair for which the $+0$ definition succeeds in all cases.

Beyond these, three broader lines suggest themselves: extending the arithmetic to a full ordered field structure with a constructive reciprocal (which requires a positivity witness for the denominator, and so a modulus depending on that witness); developing constructive differentiation with explicit moduli and a corresponding sharp mean value theorem — noting that the mean value theorem, like the exact IVT, must fail effectively and should admit a shelf-like counterexample; and quantifying the failure of the classical Bolzano–Weierstrass theorem in the same oscillation-lower-bound style as Theorem 7.6.

---

## 11. Conclusion

Bishop's discipline — constructions for existence, rates for convergence — turns analysis into a subject whose theorems carry numbers. We have shown that the resulting number system is the classical one (Theorem 2.10), that its order is the classical order presented with witnesses (Theorem 5.4), and that its completeness is classical completeness with an explicit diagonal whose index shift cannot be removed (Theorems 3.2, 3.3).

At the centre is the intermediate value theorem. Its approximate form is a finite grid search with a proved error bound (Theorem 6.2); its exact form requires a positive slope bound, and then delivers a unique root together with the modulus $\delta \mapsto \omega(c\delta)$ and the root itself as a regular sequence of rationals (Theorems 6.8, 6.9). The conversion constant $\varepsilon/c$ is attained and cannot be improved by any factor $\kappa<1$ (Theorem 6.7). Dropping the slope bound is fatal in a strong sense: Bishop's $1$-Lipschitz shelf family admits no continuous root selector (Theorem 7.4) and no selector whatsoever of oscillation below $1$ near the critical parameter (Theorem 7.6); and weakening it to local non-constancy is insufficient (Theorem 6.11). What survives with no hypotheses at all is the bracketing statement: the sign-change search lands within one mesh of a genuine root (Theorem 6.10).

Finally, the least upper bound principle for located sets is a search whose cost we have determined exactly: the general one-query scheme contracts by $\max(\beta,1-\alpha)$, so Bishop's trisection factor $\frac23$ is beaten by $\frac35$, and $\frac12$ is a barrier that is approached but never reached (Theorems 8.10–8.12). That a foundational question about constructive completeness resolves into a sharp two-parameter optimisation is, we think, the most striking thing the quantitative discipline buys.
