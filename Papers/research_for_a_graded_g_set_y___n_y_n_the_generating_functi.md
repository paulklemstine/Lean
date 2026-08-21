# Rational Hilbert Series of Graded $G$-Sets: Transitivity, Finite Differences, and the Order of the Pole at $q=1$

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

Let $Y = \bigsqcup_{n \ge 0} Y_n$ be a graded $G$-set, that is, a family of sets $Y_n$ each carrying an action of a group $G_n$. For an integer $r \ge 0$ write $t_r(Y_n)$ for the number of orbits of $G_n$ on the set of injective $r$-tuples of $Y_n$, and form the **transitivity Hilbert series**
$$H_r(q) \;=\; \sum_{n\ge0} t_r(Y_n)\, q^n \;\in\; \mathbb{Q}[[q]].$$

We prove that if the grades are eventually $r$-transitive — that is, if there is a threshold $N$ with $G_n$ acting $r$-transitively on $Y_n$ for all $n \ge N$ — then $H_r$ is a rational function of $q$ whose denominator divides $(1-q)^{r+1}$. In fact the single factor $1-q$ already clears it: $(1-q)H_r(q)$ is a polynomial. We show further that the numerator $P$ of the reduced expression satisfies $P(1) = 1$, so the pole at $q = 1$ is simple with residue $-1$, and that in the clean case where the sub-threshold grades carry no injective $r$-tuple, $H_r(q) = q^N/(1-q)$ exactly.

The exponent $r+1$ in the general statement is proved optimal: for the graded set $Y_n = \{1,\dots,n\}$ with the trivial group acting, $t_r(Y_n) = r!\binom{n}{r}$ and $H_r(q) = r!\,q^r/(1-q)^{r+1}$, a pole of order exactly $r+1$. Since the same underlying graded set with the full symmetric group acting has $H_r(q) = q^r/(1-q)$, the pole order is a direct measurement of how much symmetry the grades carry.

The analytic engine is a complete classification, proved entirely within formal power series: for a sequence $a : \mathbb{N} \to \mathbb{Q}$ and $k \ge 0$, the product $(1-q)^k \sum_n a_n q^n$ is a polynomial if and only if the $k$-th forward difference $\Delta^k a$ vanishes eventually, if and only if $a$ is eventually a $\mathbb{Q}$-linear combination of the shifted binomials $\binom{n-N}{j}$, $j < k$ — equivalently, eventually a polynomial of degree $< k$. We also give a transitivity-free route to the same conclusion via Burnside's orbit-counting lemma, show that the series with poles only at $q=1$ form a subring (so sums and Cauchy products of such Hilbert series remain rational), and prove that eventual $r$-transitivity makes the entire profile $H_0,\dots,H_r$ rational.

---

## 1. Introduction

### 1.1 Setting

A **graded $G$-set** is a family $Y = (Y_n)_{n \ge 0}$ of sets together with, for each $n$, a group $G_n$ acting on $Y_n$. The archetype is $Y_n = \{1,\dots,n\}$ with $G_n = S_n$; but the definition is deliberately loose, allowing the group to vary with the grade, so that families such as $Y_n = \mathbb{F}_q^n$ with $G_n = \mathrm{GL}_n(\mathbb{F}_q)$, or $Y_n$ the vertex set of the $n$-cube with $G_n$ its automorphism group, are covered.

Fix $r \ge 0$. The **$r$-tuple object** of a $G$-set $Y$ is the set
$$\mathrm{Inj}(r, Y) \;=\; \{\,f : \{1,\dots,r\} \hookrightarrow Y \,\}$$
of injective maps from an $r$-element index set into $Y$, with $G$ acting pointwise, $(g\cdot f)(i) = g\cdot f(i)$. This action is well defined because the $G$-action on $Y$ is by bijections and therefore preserves injectivity. Write
$$t_r(Y) \;=\; \#\bigl(\mathrm{Inj}(r,Y)/G\bigr)$$
for the number of orbits, a cardinal which we regard as a natural number (interpreting an infinite orbit count as $0$ is never needed in the applications below, where all $t_r$ are finite).

**Definition 1.1 ($r$-transitivity).** A $G$-set $Y$ is **$r$-transitive** if $\mathrm{Inj}(r,Y)$ is nonempty and $G$ acts transitively on it.

For $r=1$ this is ordinary transitivity together with nonemptiness; for $r=2$, the classical notion of doubly transitive action; and so on.

**Definition 1.2 (Hilbert series).** The **transitivity Hilbert series** of a graded $G$-set $Y$ at level $r$ is the formal power series
$$H_r(q) \;=\; \sum_{n \ge 0} t_r(Y_n)\, q^n \;\in\; \mathbb{Q}[[q]].$$

We work throughout in the ring $\mathbb{Q}[[q]]$ of formal power series with rational coefficients. Convergence never arises. The statement "$H$ is a rational function with denominator dividing $(1-q)^{k}$" is formalised as

$$\exists\,P \in \mathbb{Q}[q] : \quad (1-q)^{k}\,H(q) \;=\; P(q). \tag{$\ast$}$$

This is not a weakening: $1-q$ is a unit of $\mathbb{Q}[[q]]$, with inverse $1+q+q^2+\cdots$, because its constant term is nonzero. Hence $(\ast)$ is equivalent to the honest equation $H(q) = P(q)\cdot\bigl((1-q)^{k}\bigr)^{-1}$ inside $\mathbb{Q}[[q]]$, exhibiting $H$ as a genuine quotient.

### 1.2 The results

The main theorem is the following.

**Theorem A (Rationality under eventual transitivity).** *Let $Y$ be a graded $G$-set and suppose there exists $N$ such that $Y_n$ is $r$-transitive for all $n \ge N$. Then there is a polynomial $P \in \mathbb{Q}[q]$ with*
$$(1-q)\,H_r(q) \;=\; P(q).$$
*In particular $H_r$ is a rational function whose denominator divides $(1-q)^{r+1}$.*

**Theorem B (Residue).** *Under the hypotheses of Theorem A, the numerator satisfies $P(1) = 1$. Equivalently, $H_r$ has a simple pole at $q=1$ with residue $-1$.*

**Theorem C (Exact form).** *If moreover $Y_n$ contains no injective $r$-tuple for every $n < N$, then*
$$H_r(q) \;=\; \frac{q^{N}}{1-q}.$$

**Theorem D (Sharpness of $r+1$).** *For the graded set $Y_n = \{1,\dots,n\}$ with the trivial group acting in every grade,*
$$t_r(Y_n) = n^{\underline{r}} = r!\binom{n}{r}, \qquad (1-q)^{r+1}H_r(q) = r!\,q^r,$$
*and there is **no** polynomial $P$ with $(1-q)^r H_r(q) = P(q)$. Hence the exponent $r+1$ in Theorem A cannot be lowered in the absence of a transitivity hypothesis.*

**Theorem E (Classification).** *For any $a : \mathbb{N}\to\mathbb{Q}$ and any $k\ge0$, the following are equivalent:*
1. *$(1-q)^k\sum_n a_n q^n$ is a polynomial;*
2. *$\Delta^k a$ vanishes for all sufficiently large $n$, where $(\Delta a)(n) = a(n+1)-a(n)$;*
3. *there exist $N$ and $d_0,\dots,d_{k-1}\in\mathbb{Q}$ with $a(n) = \sum_{j<k} d_j\binom{n-N}{j}$ for all $n\ge N$;*
4. *(for $k = r+1$) $a$ agrees, for all large $n$, with a polynomial in $n$ of degree at most $r$.*

**Theorem F (Burnside route).** *Let $G$ be a fixed finite group acting on every grade $Y_n$ of a graded set with all $Y_n$ finite. If for each $g \in G$ the number of injective $r$-tuples of $Y_n$ fixed by $g$ agrees, for all large $n$, with a polynomial in $n$ of degree at most $r$, then $(1-q)^{r+1}H_r(q)$ is a polynomial — with no transitivity assumption whatsoever.*

**Theorem G (Structure and profile).** *The set of $f \in \mathbb{Q}[[q]]$ such that $(1-q)^k f$ is a polynomial for some $k$ is a subring $R_1 \subseteq \mathbb{Q}[[q]]$ containing $\mathbb{Q}[q]$. Hilbert series of eventually $r$-transitive graded $G$-sets lie in $R_1$; consequently sums and Cauchy products of such series are again rational with poles only at $q=1$ (for a product of two, of order at most $2$). Moreover $r$-transitivity is downward closed, so eventual $r$-transitivity makes every $H_s$ with $s\le r$ rational with a simple pole at $q=1$ and numerator satisfying $P(1)=1$.*

### 1.3 Discussion of the picture

Theorem A and Theorem D together give the essential dichotomy, and they are best appreciated side by side because they concern *the same underlying graded set*, $Y_n = \{1,\dots,n\}$:

| Group acting | $t_r(Y_n)$ | $H_r(q)$ | order of pole at $q=1$ |
|---|---|---|---|
| $S_n$ (full symmetric) | $[\,n\ge r\,]$ | $q^r/(1-q)$ | $1$ |
| trivial group | $r!\binom{n}{r}$ | $r!\,q^r/(1-q)^{r+1}$ | $r+1$ |

The pole order is thus a numerical invariant that measures the amount of symmetry present in the grades, not their size. This is the conceptual content of the theorem: *transitivity collapses the denominator*.

---

## 2. The finite difference engine

Everything analytic in this paper follows from a single identity. Fix the ring $\mathbb{Q}[[q]]$ and write $X$ for the indeterminate when we wish to emphasise formality.

**Definition 2.1.** For $a : \mathbb{N}\to\mathbb{Q}$ the **forward difference** is $(\Delta a)(n) = a(n+1)-a(n)$. A sequence is **eventually zero** if there is $N$ with $a(n)=0$ for all $n\ge N$. The **generating series** is $\mathrm{gen}(a) = \sum_n a(n)X^n$.

**Lemma 2.2 (Eventually zero $=$ polynomial).** *$\mathrm{gen}(a)$ is (the image of) a polynomial if and only if $a$ is eventually zero.*

*Proof.* If $a(n)=0$ for $n\ge N$, then $\mathrm{gen}(a) = \sum_{i<N} a(i)X^i$, a polynomial. Conversely if $\mathrm{gen}(a) = P$ then $a(n)$ is the $n$-th coefficient of $P$, which vanishes for $n > \deg P$. $\square$

**Lemma 2.3 (The key identity).** *For every $a$,*
$$(1-X)\cdot\mathrm{gen}(a) \;=\; X\cdot\mathrm{gen}(\Delta a) \;+\; a(0).$$

*Proof.* Compare coefficients. In degree $0$ both sides give $a(0)$. In degree $m+1$: the left side gives $a(m+1)-a(m)$; the right side gives the degree-$m$ coefficient of $\mathrm{gen}(\Delta a)$, namely $(\Delta a)(m) = a(m+1)-a(m)$. $\square$

Lemma 2.3 is the whole engine: *multiplication by $1-X$ on series is differencing on coefficients, up to a shift and a constant*. Both operations that could spoil an induction — the shift by $X$ and the added constant $a(0)$ — are harmless, because $X\cdot(-)$ preserves polynomiality in both directions and constants are polynomials.

**Proposition 2.4 (Forward direction).** *If $\Delta^k a$ is eventually zero then $(1-X)^k\,\mathrm{gen}(a)$ is a polynomial.*

*Proof.* Induction on $k$. For $k=0$ this is Lemma 2.2. For the step, suppose $\Delta^k(\Delta a)$ is eventually zero; by induction there is $Q$ with $(1-X)^k\mathrm{gen}(\Delta a) = Q$. Then
$$(1-X)^{k+1}\mathrm{gen}(a) = (1-X)^k\bigl[(1-X)\mathrm{gen}(a)\bigr] = (1-X)^k\bigl[X\,\mathrm{gen}(\Delta a) + a(0)\bigr] = X\,Q + (1-X)^k a(0),$$
a polynomial. $\square$

**Lemma 2.5 (Dividing by $X$).** *If $X\varphi$ is a polynomial then so is $\varphi$.*

*Proof.* The $n$-th coefficient of $\varphi$ is the $(n+1)$-st coefficient of $X\varphi$, which vanishes for large $n$; apply Lemma 2.2. $\square$

**Proposition 2.6 (Converse).** *If $(1-X)^k\mathrm{gen}(a)$ is a polynomial $P$, then $\Delta^k a$ is eventually zero.*

*Proof.* Induction on $k$; the base case is Lemma 2.2. For the step, rewrite using Lemma 2.3:
$$P = (1-X)^{k}\bigl[(1-X)\mathrm{gen}(a)\bigr] = X\bigl[(1-X)^{k}\mathrm{gen}(\Delta a)\bigr] + (1-X)^{k}a(0),$$
so $X\cdot\bigl[(1-X)^{k}\mathrm{gen}(\Delta a)\bigr]$ equals the polynomial $P - (1-X)^k a(0)$. By Lemma 2.5, $(1-X)^k\mathrm{gen}(\Delta a)$ is a polynomial, and the inductive hypothesis applied to $\Delta a$ finishes. $\square$

Combining:

**Theorem 2.7 (Rationality criterion).** *For all $k$ and $a$,*
$$\bigl(\exists P\in\mathbb{Q}[q]:\ (1-q)^k\,\mathrm{gen}(a) = P\bigr)\quad\Longleftrightarrow\quad \Delta^k a \text{ is eventually zero.}$$

**Remark 2.8 (Honest quotients).** Since the constant coefficient of $(1-X)^k$ is $1 \ne 0$, this element is a unit of $\mathbb{Q}[[q]]$, so any identity $(1-X)^k f = P$ can be rewritten $f = P\cdot((1-X)^k)^{-1}$. Nothing is lost by phrasing rationality multiplicatively.

---

## 3. Polynomial growth and the binomial generating function

Theorem 2.7 reduces every question to the eventual vanishing of iterated differences. The bridge to *growth* statements is the classical fact that the difference operator lowers polynomial degree.

**Definition 3.1.** For $p \in \mathbb{Q}[x]$ let $(\delta p)(x) = p(x+1)-p(x)$ be the **discrete derivative**.

**Lemma 3.2.** *If $\deg p \le d+1$ then $\deg(\delta p) \le d$.*

*Proof.* If $p$ is constant, $\delta p = 0$. Otherwise $p(x+1)$ has the same degree and the same leading coefficient as $p(x)$ (composition with the monic linear $x+1$ preserves both), so the leading terms cancel in the difference and the degree drops strictly. $\square$

Applying $\delta$ to the *values* is the same as applying $\Delta$ to the *sequence*: if $a(n) = p(n)$ then $(\Delta a)(n) = (\delta p)(n)$. Iterating Lemma 3.2 gives:

**Proposition 3.3.** *If $\deg p \le d$ then $\Delta^{d+1}\bigl(n \mapsto p(n)\bigr) = 0$ identically.*

Since iterated differences depend only on the tail of a sequence (an immediate induction: if $a$ and $b$ agree from $N$ on, so do $\Delta a$ and $\Delta b$), we obtain the growth criterion in the form we need:

**Theorem 3.4 (Eventually polynomial $\Rightarrow$ denominator $(1-q)^{r+1}$).** *If there are $N$ and $p\in\mathbb{Q}[x]$ with $\deg p \le r$ and $a(n) = p(n)$ for all $n\ge N$, then $(1-q)^{r+1}\mathrm{gen}(a)$ is a polynomial.*

The universal example of degree-$r$ growth is the binomial coefficient, and its generating function can be computed exactly from Pascal's rule alone.

**Lemma 3.5 (Pascal as a difference equation).** *For $c_r(n) = \binom{n}{r}$ we have $\Delta c_{r+1} = c_r$, and consequently $\Delta^k c_{r+k} = c_r$.*

*Proof.* $\binom{n+1}{r+1} - \binom{n}{r+1} = \binom{n}{r}$ is Pascal's rule; iterate. $\square$

**Theorem 3.6 (Binomial generating function).** *For every $r \ge 0$,*
$$(1-q)^{r+1}\sum_{n\ge0}\binom{n}{r}q^{n} \;=\; q^{r}, \qquad\text{i.e.}\qquad \sum_{n\ge0}\binom{n}{r}q^{n} \;=\; \frac{q^{r}}{(1-q)^{r+1}}.$$

*Proof.* Induction on $r$. For $r=0$: $c_0 \equiv 1$, so $\Delta c_0 = 0$ and Lemma 2.3 gives $(1-q)\mathrm{gen}(c_0) = 0 + 1 = 1 = q^0$. For the step, write
$$(1-q)^{r+2}\mathrm{gen}(c_{r+1}) = (1-q)^{r+1}\bigl[(1-q)\mathrm{gen}(c_{r+1})\bigr] = (1-q)^{r+1}\bigl[q\,\mathrm{gen}(\Delta c_{r+1}) + c_{r+1}(0)\bigr].$$
Now $c_{r+1}(0) = \binom{0}{r+1} = 0$ and $\Delta c_{r+1} = c_r$, so this equals $q\cdot(1-q)^{r+1}\mathrm{gen}(c_r) = q\cdot q^r = q^{r+1}$ by the inductive hypothesis. $\square$

**Theorem 3.7 (Optimality).** *There is no polynomial $P$ with $(1-q)^{r}\sum_n\binom{n}{r}q^n = P(q)$.*

*Proof.* By Theorem 2.7 such a $P$ would force $\Delta^{r}c_r$ to be eventually zero. But $\Delta^r c_r = c_0 \equiv 1$ by Lemma 3.5 (with the roles $r = 0 + r$), which is nowhere zero. $\square$

Thus $q^r/(1-q)^{r+1}$ has a pole of order *exactly* $r+1$, and the exponent in Theorem 3.4 is best possible.

---

## 4. Newton's formula and the complete classification

Theorem 2.7 characterises rationality by eventual vanishing of $\Delta^k$. The converse direction of the growth statement — recovering a polynomial from vanishing differences — is Newton's forward difference formula, the discrete analogue of Taylor expansion.

**Definition 4.1.** The **shifted binomial functions** are $b_{N,j}(n) = \binom{n-N}{j}$ (with $n-N$ truncated at $0$; only $n\ge N$ is used).

**Lemma 4.2.** *For $n\ge N$, $(\Delta b_{N,j+1})(n) = b_{N,j}(n)$, and therefore $\Delta^{k}b_{N,j}(n) = 0$ for all $n\ge N$ whenever $j<k$.*

*Proof.* The first claim is Pascal's rule after the shift; the second follows by applying it $j+1$ times to reach $0$ and then noting that $\Delta$ preserves "vanishes from $N$ on". $\square$

**Lemma 4.3 (Hockey stick).** *$\sum_{i<m}\binom{i}{j} = \binom{m}{j+1}$.*

*Proof.* Induction on $m$ using $\binom{m}{j+1}+\binom{m}{j} = \binom{m+1}{j+1}$. $\square$

**Theorem 4.4 (Newton's forward difference formula).** *If $\Delta^k a$ vanishes for all $n \ge N$, then for all $n \ge N$,*
$$a(n) \;=\; \sum_{j=0}^{k-1} (\Delta^{j}a)(N)\,\binom{n-N}{j}.$$

*Proof.* After translating the index so that $N=0$, we prove: if $\Delta^k b \equiv 0$ then $b(m) = \sum_{j<k}(\Delta^j b)(0)\binom{m}{j}$. Induct on $k$. For $k=0$ the hypothesis says $b\equiv0$. For the step, apply the inductive hypothesis to $\Delta b$ (which satisfies $\Delta^{k}(\Delta b)\equiv 0$), obtaining $(\Delta b)(i) = \sum_{j<k}(\Delta^{j+1}b)(0)\binom{i}{j}$. Telescoping,
$$b(m) - b(0) = \sum_{i<m}(\Delta b)(i) = \sum_{j<k}(\Delta^{j+1}b)(0)\sum_{i<m}\binom{i}{j} = \sum_{j<k}(\Delta^{j+1}b)(0)\binom{m}{j+1},$$
by Lemma 4.3, and re-indexing the sum together with the term $b(0)\binom{m}{0}$ gives the claim. $\square$

**Theorem 4.5 (Three-way classification).** *For $a : \mathbb{N}\to\mathbb{Q}$ and $k\ge0$, the following are equivalent:*
1. *$(1-q)^k\mathrm{gen}(a)$ is a polynomial;*
2. *$\Delta^k a$ is eventually zero;*
3. *there are $N$ and coefficients $d_0,\dots,d_{k-1}$ with $a(n) = \sum_{j<k} d_j\binom{n-N}{j}$ for all $n\ge N$.*

*Proof.* (1)$\Leftrightarrow$(2) is Theorem 2.7. (2)$\Rightarrow$(3) is Theorem 4.4 with $d_j = (\Delta^j a)(N)$. (3)$\Rightarrow$(2): $\Delta^k$ is linear and annihilates each $b_{N,j}$ with $j<k$ past $N$ (Lemma 4.2), and iterated differences depend only on the tail. $\square$

The shifted binomials $b_{N,0},\dots,b_{N,r}$ form a basis of the space of polynomials of degree $\le r$; making this explicit turns condition (3) into an honest polynomial statement. Concretely, $b_{N,j}$ is realised by the polynomial
$$\beta_{N,j}(x) \;=\; \frac{1}{j!}\,(x-N)(x-N-1)\cdots(x-N-j+1),$$
of degree exactly $j$, which satisfies $\beta_{N,j}(n) = \binom{n-N}{j}$ for every integer $n \ge N$ (the falling factorial evaluated at the nonnegative integer $n-N$ is $j!\binom{n-N}{j}$).

**Theorem 4.6 (Polynomial classification).** *For $a : \mathbb{N}\to\mathbb{Q}$ and $r\ge0$:*
$$\bigl(\exists P : (1-q)^{r+1}\mathrm{gen}(a) = P\bigr) \quad\Longleftrightarrow\quad \exists N,\ \exists p\in\mathbb{Q}[x]\text{ with }\deg p \le r,\ \forall n\ge N:\ a(n)=p(n).$$

*Proof.* ($\Leftarrow$) is Theorem 3.4. ($\Rightarrow$): by Theorem 2.7, $\Delta^{r+1}a$ vanishes from some $N$ on; by Theorem 4.4, $a(n) = \sum_{j\le r}(\Delta^j a)(N)\binom{n-N}{j}$ for $n\ge N$; and $p = \sum_{j\le r}(\Delta^j a)(N)\,\beta_{N,j}$ is a polynomial of degree $\le r$ realising these values. $\square$

**Interpretation.** The exponent in the denominator is not slack: it is a measurement. The minimal $k$ with $(1-q)^k H$ polynomial equals one plus the eventual polynomial degree of the coefficient sequence.

---

## 5. Orbits of injective tuples, and Theorem A

We now return to group actions.

**Proposition 5.1 (Transitivity $=$ one orbit).** *For a $G$-set $Y$ and $r\ge0$: $t_r(Y)=1$ if and only if $Y$ is $r$-transitive.*

*Proof.* ($\Rightarrow$) If the orbit set is a singleton, it is in particular nonempty, so $\mathrm{Inj}(r,Y)\ne\emptyset$; and any two injective $r$-tuples have the same class, hence lie in a common orbit, so some $g$ carries one to the other. ($\Leftarrow$) Transitivity makes the orbit space a subsingleton — any two classes $[x],[y]$ coincide because $x \in Gy$ — and nonemptiness of $\mathrm{Inj}(r,Y)$ makes it nonempty. A nonempty subsingleton has exactly one element. $\square$

**Proposition 5.2 (Empty tuple object).** *If $\mathrm{Inj}(r,Y)=\emptyset$ then $t_r(Y)=0$.*

*Proof.* The orbit space of the empty set is empty. $\square$

**Proof of Theorem A.** Let $N$ be such that $Y_n$ is $r$-transitive for $n \ge N$. By Proposition 5.1, $t_r(Y_n) = 1$ for all $n \ge N$, hence the sequence $a(n)=t_r(Y_n)$ satisfies
$$(\Delta a)(n) = t_r(Y_{n+1}) - t_r(Y_n) = 1 - 1 = 0 \qquad (n \ge N),$$
so $\Delta^1 a$ is eventually zero. Proposition 2.4 with $k=1$ produces a polynomial $P$ with $(1-q)H_r(q)=P(q)$. Multiplying both sides by $(1-q)^{r}$ yields $(1-q)^{r+1}H_r(q) = (1-q)^r P(q)$, again a polynomial, so the denominator divides $(1-q)^{r+1}$. $\blacksquare$

The proof also makes visible exactly where each hypothesis is used: transitivity is used *only* to pin the eventual value of the sequence to the constant $1$; any eventually constant orbit count would do, and one would then obtain the residue statement with that constant.

**Proof of Theorem B (Residue).** We show the general fact: if $a(n) = c$ for all $n \ge N$ and $(1-q)\mathrm{gen}(a) = P$, then $P(1) = c$. Comparing coefficients in $(1-q)\mathrm{gen}(a)=P$ gives
$$P_0 = a(0), \qquad P_{n+1} = a(n+1)-a(n) \quad (n\ge0),$$
where $P_i$ denotes the $i$-th coefficient. Choose $m \ge \max(N, \deg P)$. Then
$$P(1) \;=\; \sum_{i=0}^{m} P_i \;=\; a(0) + \sum_{i=0}^{m-1}\bigl(a(i+1)-a(i)\bigr) \;=\; a(0) + \bigl(a(m)-a(0)\bigr) \;=\; a(m) \;=\; c.$$
Applying this with $c=1$, which holds by Proposition 5.1, gives Theorem B. $\blacksquare$

Since $(1-q)H_r(q) = P(q)$ with $P(1)=1$, the pole of $H_r$ at $q=1$ is simple with residue $\lim_{q\to1}(q-1)H_r(q) = -P(1) = -1$.

**Proof of Theorem C (Exact form).** Under the extra hypothesis, Proposition 5.2 gives $t_r(Y_n)=0$ for $n<N$ and Proposition 5.1 gives $t_r(Y_n)=1$ for $n\ge N$, so $a$ is the step sequence $[\,n\ge N\,]$, whose generating function is $q^N + q^{N+1} + \cdots = q^N/(1-q)$. Equivalently, $(1-q)\mathrm{gen}(a) = q^N$, which one checks coefficientwise. $\blacksquare$

**Example 5.3 (Symmetric groups).** Let $Y_n = \{1,\dots,n\}$ with $G_n = S_n$. For $n \ge r$ the action of $S_n$ on injective $r$-tuples is transitive (given two lists of $r$ distinct labels, a permutation sending one to the other exists because one may extend the induced bijection arbitrarily on the complements, which have equal size). For $n<r$ there is no injective map $\{1,\dots,r\}\hookrightarrow\{1,\dots,n\}$ by pigeonhole. Theorem C therefore gives
$$H_r(q) \;=\; \frac{q^{r}}{1-q}, \qquad P(q) = q^r, \qquad P(1)=1.$$

---

## 6. Sharpness: the trivial group

**Proposition 6.1 (Trivial actions count tuples).** *If $G$ acts trivially on $Y$ (that is, $g\cdot y = y$ for all $g,y$) then every element of $\mathrm{Inj}(r,Y)$ is fixed by every $g$, so each orbit is a singleton and $t_r(Y) = \#\mathrm{Inj}(r,Y)$.*

**Proposition 6.2.** *For $Y_n=\{1,\dots,n\}$ with the trivial group,*
$$t_r(Y_n) \;=\; \#\mathrm{Inj}(r,\{1,\dots,n\}) \;=\; n^{\underline{r}} \;=\; n(n-1)\cdots(n-r+1) \;=\; r!\binom{n}{r}.$$

*Proof.* The number of injections from an $r$-set into an $n$-set is the falling factorial; the last equality is the standard identity $n^{\underline r} = r!\binom{n}{r}$, valid for all $n$ (both sides vanish when $n<r$). $\square$

**Proof of Theorem D.** By Proposition 6.2 the coefficient sequence is $r!\,c_r$ with $c_r(n) = \binom{n}{r}$. Generating functions are $\mathbb{Q}$-linear, so by Theorem 3.6
$$(1-q)^{r+1}H_r(q) \;=\; r!\,(1-q)^{r+1}\mathrm{gen}(c_r) \;=\; r!\,q^{r}.$$
If $(1-q)^r H_r$ were a polynomial then, by Theorem 2.7 and linearity of $\Delta$, the sequence $r!\,\Delta^r c_r = r!\,c_0 \equiv r!$ would be eventually zero, contradicting $r! \neq 0$. $\blacksquare$

**Corollary 6.3 (Transitivity collapses the denominator).** *For every $r$, the graded set $Y_n = \{1,\dots,n\}$ satisfies*
$$(1-q)\,H_r^{S_\bullet}(q) = q^r \qquad\text{and}\qquad \nexists P:\ (1-q)^r H_r^{\mathrm{triv}}(q) = P(q),$$
*where the superscripts indicate the acting group. Thus the pole order at $q=1$ jumps from $1$ to $r+1$ purely by removing symmetry, with the grades unchanged.*

---

## 7. A transitivity-free route: Burnside's lemma

Transitivity is a strong hypothesis. Burnside's orbit-counting lemma provides an alternative sufficient condition of a completely different flavour.

**Theorem 7.1 (Burnside for injective tuples).** *Let $G$ be a finite group acting on a finite set $Y$. Then*
$$\sum_{g\in G}\bigl|\mathrm{Fix}_{\mathrm{Inj}(r,Y)}(g)\bigr| \;=\; t_r(Y)\cdot|G|,$$
*where $\mathrm{Fix}_S(g) = \{s\in S : g\cdot s = s\}$.*

*Proof.* The set $\mathrm{Inj}(r,Y)$ is finite (it injects into $Y^r$) and carries a $G$-action; apply the orbit-counting lemma to it. $\square$

**Theorem 7.2 (Fixed-point growth criterion).** *Let $G$ be a fixed finite group acting on each grade $Y_n$ of a graded set, all $Y_n$ finite. Suppose there are $N$ and polynomials $p_g \in \mathbb{Q}[x]$, $g \in G$, with $\deg p_g \le r$ and*
$$\bigl|\mathrm{Fix}_{\mathrm{Inj}(r,Y_n)}(g)\bigr| = p_g(n)\qquad\text{for all }g\in G,\ n\ge N.$$
*Then $(1-q)^{r+1}H_r(q)$ is a polynomial.*

*Proof.* Put $p = \frac{1}{|G|}\sum_{g\in G}p_g$. Its degree is at most $r$, being a scalar multiple of a finite sum of polynomials of degree $\le r$. For $n\ge N$, Theorem 7.1 gives
$$t_r(Y_n)\cdot|G| \;=\; \sum_{g\in G}\bigl|\mathrm{Fix}_{\mathrm{Inj}(r,Y_n)}(g)\bigr| \;=\; \sum_{g\in G}p_g(n),$$
so $t_r(Y_n) = p(n)$. Theorem 3.4 concludes. $\square$

The criterion is not vacuous: for a *constant* family, $Y_n = Y$ for all $n$ with a single finite $G$ acting, each fixed-point count is constant in $n$, hence given by a degree-$0$ polynomial, so the criterion applies and $(1-q)^{r+1}H_r$ is a polynomial (indeed $(1-q)H_r$ is already, since the coefficient sequence is constant).

The two hypotheses — eventual transitivity, and polynomial fixed-point growth — are logically independent. Transitivity says the group is large relative to the tuple object; polynomial fixed-point growth says each individual element's fixed locus is tame. Burnside's lemma is precisely the bridge that converts the second into a statement about the sequence $t_r(Y_\bullet)$ that the difference operator can act on.

---

## 8. Structural closure and the transitivity profile

### 8.1 The subring of series with poles only at $q=1$

**Definition 8.1.** Let
$$R_1 \;=\; \bigl\{\, f\in\mathbb{Q}[[q]] \ :\ \exists k\in\mathbb{N},\ \exists P\in\mathbb{Q}[q],\ (1-q)^k f = P \,\bigr\}.$$

**Theorem 8.2.** *$R_1$ is a subring of $\mathbb{Q}[[q]]$ containing $\mathbb{Q}[q]$.*

*Proof.* $0,1$ and every polynomial lie in $R_1$ (take $k=0$). If $(1-q)^k f = P$ and $(1-q)^\ell g = Q$ then
$$(1-q)^{k+\ell}(f+g) = (1-q)^{\ell}P + (1-q)^{k}Q, \qquad (1-q)^{k+\ell}(fg) = P\,Q,$$
both polynomials; and $(1-q)^k(-f) = -P$. $\square$

**Proposition 8.3 (Coefficient description).** *$\mathrm{gen}(a)\in R_1$ if and only if $\Delta^k a$ is eventually zero for some $k$; equivalently (Theorem 4.6) if and only if $a$ is eventually polynomial.*

*Proof.* Immediate from Theorem 2.7. $\square$

**Corollary 8.4 (Closure for Hilbert series).** *If $Y$ is eventually $r$-transitive and $Y'$ eventually $s$-transitive, then $H_r^{Y}$ and $H_s^{Y'}$ lie in $R_1$, and their Cauchy product satisfies*
$$(1-q)^{2}\,H_r^{Y}(q)\,H_s^{Y'}(q) \;=\; P(q)\,Q(q)$$
*for the respective numerators, so the product has a pole at $q=1$ of order at most $2$.*

This is the series-level shadow of a graded product construction: if $(Y\otimes Y')_n = \bigsqcup_{i+j=n} Y_i\times Y'_j$ with the product group acting, its coefficient sequence is the convolution of the two, and Corollary 8.4 bounds the resulting pole. Pole orders add — never more than that.

### 8.2 The whole profile is rational

**Lemma 8.5 (Downward closure).** *If $Y$ is $r$-transitive and $s\le r$, then $Y$ is $s$-transitive.*

*Proof.* Nonemptiness: restricting an injective $r$-tuple to its first $s$ coordinates gives an injective $s$-tuple. Transitivity: the existence of an injective $r$-tuple shows $|Y|\ge r$, and an $r$-transitive action on a set of at least $r$ elements is $s$-transitive for every $s\le r$ — given two injective $s$-tuples, extend each to an injective $r$-tuple (possible since $|Y|\ge r$), transport one to the other by $r$-transitivity, and restrict. $\square$

**Theorem 8.6 (Rational profile).** *If the grades of $Y$ are eventually $r$-transitive, then for every $s \le r$ there is a polynomial $P_s$ with*
$$(1-q)\,H_s(q) = P_s(q) \qquad\text{and}\qquad P_s(1) = 1;$$
*in particular each $H_s$ has denominator dividing $(1-q)^{s+1}$.*

*Proof.* By Lemma 8.5 the grades are eventually $s$-transitive for each $s\le r$; apply Theorems A and B at level $s$. $\square$

So eventual $r$-transitivity is not one theorem but $r+1$ of them, uniformly: the entire profile $\bigl(t_s(Y_n)\bigr)_{s\le r}$ has rational generating functions with a simple pole at $q=1$ and unit residue in the normalised sense $P_s(1)=1$.

---

## 9. Algorithms

The theory is fully effective. We record the three computations that matter, with their complexity.

### 9.1 Difference-table rationality test

**Input:** the first $M$ terms $a_0,\dots,a_{M-1}$ of a sequence, a bound $k$, a stability window $w$.
**Output:** whether $\Delta^k a$ appears to vanish on the last $w$ available indices, and hence whether $(1-q)^k$ clears the series.

Build the difference table row by row: row $0$ is $a$, and row $i+1$ is the forward difference of row $i$, one entry shorter. Row $k$ has $M-k$ entries; test whether its last $w$ entries are zero. Cost: $O(kM)$ additions. This test is *conclusive* in one direction — a nonzero tail entry certifies that $(1-q)^k$ does not clear the series *if* one knows the sequence is eventually polynomial — and is used in practice as a certificate generator: the minimal $k$ found is exactly one more than the eventual polynomial degree, by Theorem 4.6.

### 9.2 Numerator extraction

**Input:** the sequence $a$ (as a rule or a long prefix) and an exponent $k$ known to clear it.
**Output:** the numerator $P$ with $(1-q)^k\mathrm{gen}(a) = P$.

The coefficients of $P$ are obtained by convolving $a$ with the coefficients of $(1-q)^k$:
$$P_m \;=\; \sum_{i=0}^{\min(m,k)} (-1)^{i}\binom{k}{i}\,a_{m-i}.$$
Once $\Delta^k a$ has vanished from index $N$ on, $P_m=0$ for $m > N+k-1$, so one truncates there. Cost: $O(kN)$. The residue test $P(1)=\sum_m P_m \stackrel{?}{=}1$ is then a one-line validation of Theorem B.

### 9.3 Newton reconstruction

**Input:** a sequence known to satisfy $\Delta^k a \equiv 0$ beyond $N$.
**Output:** the closed form $a(n) = \sum_{j<k}(\Delta^j a)(N)\binom{n-N}{j}$ for $n\ge N$, and the equivalent polynomial in the falling-factorial basis.

Read off the $j$-th entry of the difference table's column at index $N$ for $j<k$; these are the Newton coefficients. Cost: $O(kN)$ to build the table, $O(k)$ to read the coefficients, $O(k)$ per evaluation. Converting to the monomial basis costs $O(k^2)$ via the falling factorials $\beta_{N,j}$.

---

## 10. Worked examples

**10.1 Symmetric groups, $r=3$.** $t_3(Y_n) = 0,0,0,1,1,1,\dots$; $\Delta$ of this is $0,0,0,1,0,0,\dots$, eventually zero, so $k=1$ works; numerator $P(q) = q^3$; $P(1)=1$; $H_3(q)=q^3/(1-q)$. Coefficient check: $q^3/(1-q) = q^3+q^4+q^5+\cdots$.

**10.2 Trivial group, $r=3$.** $t_3(Y_n) = n(n-1)(n-2) = 0,0,0,6,24,60,120,210,\dots$. Successive difference rows: $0,0,6,18,36,60,90,\dots$; then $0,6,12,18,24,30,\dots$; then $6,6,6,6,6,\dots$; then $0,0,0,0,\dots$. Exactly four differences are needed, matching $k = r+1 = 4$, and the third row is the nonzero constant $6=3!$, certifying that $k=3$ fails. Numerator: $(1-q)^4 H_3(q) = 6q^3$.

**10.3 A mixed family.** Suppose the grades are $r$-transitive from $N=5$ on, but the low grades give orbit counts $t_r = 0,3,2,7,4$ for $n=0,\dots,4$. Then
$$P(q) = 0 + 3q - q^2 + 5q^3 - 3q^4 - 3q^5,$$
computed from $P_0=a_0$, $P_{n+1}=a_{n+1}-a_n$, with $a_n = 1$ for $n \ge 5$. Its coefficients sum to $0+3-1+5-3-3 = 1$, confirming Theorem B without any further computation. The "defect region" $n<5$ is recorded verbatim in the numerator.

**10.4 An eventually-quadratic orbit count.** If a family has $t_2(Y_n) = n^2 - 3n + 4$ for $n \ge 2$, then $\Delta^3$ kills it, $k=3=r+1$ with $r=2$ suffices, and no smaller $k$ does, since $\Delta^2$ of a genuine quadratic is the nonzero constant $2$.

---

## 11. Discussion

### 11.1 What the pole order measures

The central message is that the order of the pole of $H_r$ at $q=1$ is a *symmetry invariant* of a graded $G$-set. It equals one plus the eventual polynomial degree of the orbit-counting sequence (Theorem 4.6). Full $r$-transitivity forces that degree to be $0$ and hence the pole order to be $1$; the absence of any symmetry pushes the degree to its maximum $r$ and the pole order to $r+1$. Everything in between corresponds to intermediate symmetry: a family whose orbit counts grow like a degree-$d$ polynomial has pole order exactly $d+1$, and $d$ can be read as a defect of transitivity.

### 11.2 The numerator as a complete record of the defect region

Theorem B says $P(1)=1$; the proof shows more, namely that the coefficients of $P$ are exactly $a_0$ and the successive differences $a_{n+1}-a_n$. Thus $P$ carries no information beyond the finitely many grades before transitivity sets in, and it carries *all* of that information: the map from the truncated sequence to the numerator is a bijection onto polynomials whose coefficients sum to $1$. Example 10.3 is a direct illustration. The clean case $P(q)=q^N$ of Theorem C is precisely the case where the defect region is "as empty as possible": no injective $r$-tuple exists below the threshold.

### 11.3 Relation to classical rationality theorems

Denominators that are powers of $1-q$ and eventually polynomial coefficient sequences are the signature of Hilbert–Serre type theorems in graded commutative algebra and of Ehrhart theory for lattice polytopes. The results here place orbit counts of graded group actions in the same family, with the difference operator playing the role usually played by a Koszul-type resolution. The proofs are elementary and constructive throughout; nothing beyond Pascal's rule, telescoping, and the invertibility of $1-q$ in the formal power series ring is used.

### 11.4 Independence of the two sufficient conditions

Theorem A (transitivity) and Theorem 7.2 (fixed-point growth) are logically independent sufficient conditions. Transitivity gives the strongest conclusion — a simple pole — while fixed-point growth is more flexible, applies to families with a fixed group and no transitivity at all, and yields the weaker but still meaningful bound $r+1$. Their common conclusion is not an accident: both hypotheses, by different means, control the growth of $t_r(Y_n)$ as a function of $n$, and it is only this growth that the analytic machine sees.

### 11.5 Limitations

Three limitations should be stated plainly. First, the theorems say nothing about the *rate* at which transitivity sets in; the threshold $N$ is an input and is invisible to the series apart from through the numerator's degree. Second, everything here is about the pole at $q=1$; if transitivity holds only along an arithmetic progression the argument breaks, and one should expect poles at roots of unity instead. Third, the graded product construction is treated only at the level of series (Corollary 8.4); identifying the orbit count of a graded product with the convolution of the factors' orbit counts requires a separate combinatorial argument.

---

## 12. Future directions

The following are five falsifiable conjectures suggested by the development, each stated so as to be attacked with the machinery above.

**C1. Orbit-counting rigidity: the numerator degree equals the transitivity threshold.**
Let $Y$ be a graded $G$-set that is $r$-transitive in every grade $n \ge N$ and has no injective $r$-tuple in any grade $n < N$. Then the numerator $P$ with $(1-q)H(q) = P(q)$ satisfies $P = q^N$ exactly; conversely, if $P$ is a monomial then the transitivity threshold is $\deg P$ and the grades below it carry no injective $r$-tuple. One direction is Theorem C; the converse — recovering the threshold from the numerator — is open here. *The key insight is* that the numerator of a Hilbert series is a **complete invariant of the defect region**: the polynomial $P$ records, coefficient by coefficient, the finitely many grades where transitivity has not yet set in, and $P(1)=1$ is the only global constraint on it. Why now? With the three-way classification the passage between sequences and numerators is completely explicit, so this is a finite computation on coefficients rather than an analytic argument.

**C2. Quasi-polynomial grading: periodic transitivity gives cyclotomic denominators.**
If the grades are $r$-transitive only along an arithmetic progression $n \equiv a \pmod m$, and $t_r(Y_n)$ is eventually periodic modulo $m$, then $\sum_n t_r(Y_n)q^n$ is rational with denominator dividing $(1-q^m)^{r+1}$, and lies in the subring generated by $R_1$ and the $m$-th roots of unity filters. *The key insight is* that $1-q^m = \prod_{\zeta^m=1}(1-\zeta q)$, so periodic transitivity should trade the single pole at $q=1$ for a full orbit of poles at the $m$-th roots of unity — the finite-difference operator $\Delta$ being replaced by the $m$-step difference $a(n+m)-a(n)$. Why now? The engine uses only the identity $(1-q)\mathrm{gen}(a) = q\,\mathrm{gen}(\Delta a) + a(0)$; the same one-line identity holds verbatim for $1-q^m$ and the $m$-step difference, so the whole tower should transfer.

**C3. Sub-additivity of pole order under products of graded $G$-sets.**
For graded $G$-sets $Y$, $Y'$ let $Y\otimes Y'$ be the graded $G\times G'$-set with $(Y\otimes Y')_n = \bigsqcup_{i+j=n} Y_i\times Y'_j$. If $Y$ is eventually $r$-transitive and $Y'$ eventually $s$-transitive, then $Y\otimes Y'$ is eventually $\min(r,s)$-transitive and the order of the pole of its Hilbert series at $q=1$ is at most $2$, with equality iff both factors have infinitely many nonempty grades. The series-level bound (denominator $(1-q)^2$) is Corollary 8.4; what is open is that the Hilbert series of the product $G$-set really is the Cauchy product, i.e. that $t_{\min(r,s)}$ of the product grade equals the convolution.

**C4. A converse to the Burnside criterion.**
If $(1-q)^{r+1}H_r$ is a polynomial for a family with a fixed finite group $G$, must each individual fixed-point count $n \mapsto |\mathrm{Fix}_{\mathrm{Inj}(r,Y_n)}(g)|$ be eventually polynomial of degree $\le r$? The averaged statement is Theorem 7.2; the question is whether cancellation among group elements can hide non-polynomial individual behaviour.

**C5. Effective thresholds.**
Given the numerator $P$ of an eventually $r$-transitive family, bound the transitivity threshold $N$ in terms of $\deg P$. Theorem C gives $N = \deg P$ in the extreme case; in general one expects $N \le \deg P$, with the gap measured by the number of sub-threshold grades that happen to be transitive already.

---

## 13. Conclusion

For a graded $G$-set whose grades are eventually $r$-transitive, the generating function of the orbit counts of injective $r$-tuples is a rational function of $q$ with denominator dividing $(1-q)^{r+1}$, and in fact with the single factor $1-q$ sufficing; the numerator evaluates to $1$ at $q=1$, and in the clean case is the monomial $q^N$ recording the transitivity threshold. The exponent $r+1$ is exactly right without transitivity, as the trivial-group family with orbit count $r!\binom{n}{r}$ and generating function $r!\,q^r/(1-q)^{r+1}$ demonstrates. Underlying all of it is a complete and elementary classification: $(1-q)^k$ clears a generating function precisely when the $k$-th forward difference of its coefficients vanishes eventually, precisely when the coefficients are eventually a polynomial of degree less than $k$. The pole order at $q=1$ is thus a sharp numerical measure of how much symmetry a graded family of group actions carries.
