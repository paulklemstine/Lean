# Asymptotic Comparison Beyond Coefficient Extensionality

### The germ interpretation of the integer rank scale: injectivity, order, the flat kernel, and multiplicative closure

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

A formal series on a scale of comparison functions is an exact algebraic object: two such series are equal precisely when all of their coefficients agree. Passing to analysis, one is tempted to read this *coefficient extensionality* as the assertion that two functions with the same asymptotic expansion coincide. That reading is false, and the failure is classical — flat functions such as $e^{-x}$ have identically vanishing expansions on the power scale. This paper makes both halves precise and, more importantly, determines the exact size of the discrepancy.

We work with the integer rank scale $m_r(x) = x^r$ at $+\infty$ and establish the following. (i) **Rank comparison:** $r < s$ implies $m_r = o(m_s)$, so the scale is strictly and unambiguously ordered. (ii) **Uniqueness:** a function has at most one asymptotic expansion on the scale. (iii) **A convergent fragment:** formal series $\sum_{n\ge0} a_n x^{-n}$ with uniformly bounded coefficients converge for $x > 1$ and thereby define germs at $+\infty$; a single geometric tail estimate shows the resulting germ realizes the series as its classical asymptotic expansion. (iv) **Injectivity:** on this fragment the interpretation is injective, and conversely formal agreement at all ranks implies equality of eventual germs — coefficient extensionality is exactly valid here. (v) **Sign and order:** the leading nonzero monomial controls the eventual sign, with an explicit and sharp threshold $x > (M + |a_{n_0}|)/|a_{n_0}|$; the germ is asymptotically equivalent to its leading monomial; any two fragment germs are eventually comparable (a Hardy-field trichotomy, so no oscillation); and the interpretation is an order embedding of the lexicographic order on coefficient sequences into the eventual-domination order on germs. (vi) **The flat kernel:** calling $f$ *flat* when it is negligible against every rank, the fibres of the expansion map are exactly the cosets of the flat germs, the flat germs form an ideal under multiplication by $O(1)$ germs, the ideal is nontrivial, and it meets the image of the fragment only in $0$. Coefficient extensionality is therefore valid modulo flatness and not one bit further. (vii) **Multiplicativity and closure:** the germ of a formal Cauchy product is the product of the germs; the bounded fragment is *not* closed under the Cauchy product (squaring the all-ones series produces the unbounded coefficients $n+1$); the geometrically bounded fragment $|a_n| \le M\rho^n$ *is* closed, at rate $2\max(\rho_1,\rho_2)$; the inflation of the rate can be made arbitrarily small but cannot be removed. The correct multiplicatively closed object is thus a directed system of fragments rather than a single one.

**Keywords:** asymptotic expansion; germ at infinity; rank scale; flat function; Hardy field; lexicographic order; Cauchy product; Borel's theorem; beyond all orders.

---

## 1. Introduction

### 1.1 Two notions of equality

Formal series are combinatorial objects. Given a scale of comparison functions indexed by a totally ordered set of *ranks*, a formal series is a function from ranks to coefficients, and equality of formal series is equality of coefficient functions. We call this **coefficient extensionality**. It is a definition, and as such it is unassailable.

Analytic asymptotics is a different game. There, a function $f$ *has* the expansion $\sum_n a_n x^{-n}$ when each truncation approximates $f$ to the order of its last retained term. The expansion is a description of $f$'s behaviour near a limit point, not a decomposition of $f$. The natural question is whether the description is complete: does the expansion determine the function?

The answer, well known but rarely stated with precision, is *no*, and the reason is the existence of **flat** functions — nonzero functions negligible against every element of the scale. The exponential $e^{-x}$ is flat on the power scale at $+\infty$. Borel's theorem sharpens the phenomenon in the smooth category: *every* coefficient sequence is realized by some smooth function, so the expansion map from smooth germs to formal series is surjective with an enormous kernel.

The practical significance of the kernel is out of all proportion to its innocuous definition. Exponentially small effects — Stokes phenomena, instanton corrections, above-barrier reflection, the splitting between two states of a symmetric double well — are precisely the phenomena invisible to a perturbative expansion at every finite order. In the applied literature they are studied under the heading "asymptotics beyond all orders". Whatever a formal expansion is telling you, it is telling you nothing about the kernel.

### 1.2 What this paper does

We do not merely observe the failure; we measure it, and we identify the largest natural class on which the formal principle is exactly correct.

The structure of the argument is:

1. Fix the scale and prove the elementary ordering fact that makes it a scale at all (§2).
2. Define asymptotic expansion and prove uniqueness of coefficients (§3). Uniqueness already shows that the expansion map is well defined; only injectivity can fail.
3. Isolate a **convergent fragment** of formal series that literally sum to functions, and prove that the resulting interpretation map is injective and realizes expansions (§4). This is where coefficient extensionality is rescued.
4. Prove that the interpretation respects order, in the strong sense of a Hardy-field trichotomy plus a lexicographic order embedding (§5).
5. Define flatness and prove the **fibre theorem**: the fibres of the expansion map are exactly cosets of the flat germs; the flat germs form a nontrivial ideal that intersects the fragment trivially (§6).
6. Study multiplication: multiplicativity of the interpretation, failure of closure for the bounded fragment, restoration of closure for the geometric fragment, and sharpness of the necessary rate inflation (§7).
7. Discuss algorithmic content, applications, and limitations (§8–§10).

Everything is stated for the integer rank scale at $+\infty$; §10 comments on what generalizes.

---

## 2. The rank scale

Throughout, "germ" means germ at $+\infty$ of a function $\mathbb{R}\to\mathbb{R}$; two functions define the same germ when they agree on some interval $(A,\infty)$. We write $f = o(g)$, $f = O(g)$, and $f \sim g$ for the usual relations along the filter $x \to +\infty$.

**Definition 2.1 (Rank monomials).** For $r \in \mathbb{Z}$, the *monomial of rank $r$* is $m_r(x) = x^r$. For $n \in \mathbb{N}$ we write $u_n(x) = x^{-n} = (x^{-1})^n$, so that $u_n = m_{-n}$. The family $\{u_n\}_{n\ge0}$ is the *decaying part* of the scale; it will carry the convergent fragment.

**Theorem 2.2 (Rank comparison).** If $r < s$ are integers then $m_r = o(m_s)$ as $x \to +\infty$.

*Proof sketch.* For $x > 0$ the denominator never vanishes, so the little-o statement is equivalent to $m_r(x)/m_s(x) \to 0$. On $x>0$ this quotient equals $x^{r-s}$ with $r - s < 0$, and $x^{k} \to 0$ for negative integer $k$. $\square$

**Corollary 2.3.** For natural numbers $n < m$, $u_m = o(u_n)$: within the decaying part, a higher index (equivalently, a lower rank) is negligible against a lower index.

Theorem 2.2 is what makes the collection $\{m_r\}$ a *scale*: no two ranks are comparable in both directions, and the ordering is strict. Every rigidity result below is ultimately a consequence of it.

---

## 3. Asymptotic expansions and uniqueness

**Definition 3.1 (Asymptotic expansion).** A function $f$ *has expansion* $a = (a_n)_{n\ge0}$ if for every $N \in \mathbb{N}$,
$$f(x) - \sum_{n=0}^{N} a_n x^{-n} \;=\; o\!\left(x^{-N}\right), \qquad x\to+\infty .$$

Two remarks. First, the condition is *nested*: the estimate at $N$ is stronger than the estimate at $N-1$, and having it for all $N$ is the whole content. Second, expansion is a property of the germ: if $f$ and $g$ agree eventually and $f$ has expansion $a$, then so does $g$. We record this because it is used constantly.

**Lemma 3.2 (Congruence).** If $f$ has expansion $a$ and $f = g$ eventually, then $g$ has expansion $a$.

The following technical lemma is the engine of uniqueness.

**Lemma 3.3.** Let $g$ be eventually nonvanishing and let $C$ be a constant with $C\cdot g = o(g)$. Then $C = 0$.

*Proof sketch.* If $C \ne 0$, apply the definition of $o$ with $\varepsilon = |C|/2$: eventually $|C||g(x)| \le \tfrac{|C|}{2}|g(x)|$. Choosing an $x$ at which additionally $g(x)\ne0$ gives $|C| \le |C|/2$ with $|C| > 0$, a contradiction. $\square$

**Theorem 3.4 (Uniqueness of expansion coefficients).** If $f$ has expansions $a$ and $b$, then $a = b$.

*Proof sketch.* By strong induction on $N$, assume $a_n = b_n$ for all $n < N$. Subtract the two defining estimates at level $N$:
$$\Big(f(x) - \sum_{n\le N} a_n x^{-n}\Big) - \Big(f(x) - \sum_{n\le N} b_n x^{-n}\Big) = \sum_{n \le N}(b_n - a_n)x^{-n},$$
and the left-hand side is $o(x^{-N})$ as a difference of two such. By the inductive hypothesis all terms with $n<N$ vanish, so the right-hand side collapses to $(b_N - a_N)x^{-N}$. Since $x^{-N}$ is eventually nonzero, Lemma 3.3 gives $b_N = a_N$. $\square$

Theorem 3.4 says the expansion map $f \mapsto a$ is a well-defined partial function on germs. The remaining question is its injectivity, which is the subject of §6. First we build the class on which injectivity holds.

---

## 4. The convergent fragment and its interpretation

### 4.1 Bounded series

**Definition 4.1 (Bounded series).** A *bounded series* is a triple consisting of a coefficient sequence $a : \mathbb{N} \to \mathbb{R}$, a real number $M$, and the data of the inequalities $|a_n| \le M$ for all $n$. We write $\mathcal{B}$ for the collection of bounded series and $M(c)$, $a^c$ for the bound and coefficients of $c \in \mathcal{B}$.

Immediately $M(c)\ge0$, since $0 \le |a^c_0| \le M(c)$. The set $\mathcal{B}$ is closed under negation ($M$ unchanged) and difference (with bound $M + M'$), so its image in coefficient space is a linear subspace, and the accompanying bounds behave subadditively.

**Definition 4.2 (Interpretation).** For $c \in \mathcal{B}$ set
$$E_c(t) = \sum_{n\ge0} a^c_n t^n \quad (|t|<1), \qquad \mathcal{E}_c(x) = E_c(x^{-1}).$$
We call $\mathcal{E}_c$ the *germ interpretation* of $c$; it is defined for $x>1$ and hence is a germ at $+\infty$.

**Lemma 4.3 (Summability).** For $0 \le t < 1$ the series $\sum_n a^c_n t^n$ converges absolutely, being dominated termwise by the geometric series $\sum_n M(c)\,t^n$.

### 4.2 The quantitative core

Everything analytic in the bounded theory follows from one estimate.

**Theorem 4.4 (Tail bound).** For $c \in \mathcal{B}$, $0 \le t < 1$, and $k \in \mathbb{N}$,
$$\left| E_c(t) - \sum_{n=0}^{k-1} a^c_n t^n \right| \;\le\; \frac{M(c)\, t^{k}}{1-t}.$$

*Proof sketch.* Two ingredients. (a) A general comparison: if $|f_i| \le g_i$ termwise and both are summable, then the tail of $\sum f$ after $k$ terms is bounded in absolute value by the tail of $\sum g$ after $k$ terms. This follows from writing each tail as $\sum_i f(i+k)$, applying the triangle inequality for infinite sums, and comparing termwise. (b) The geometric tail in closed form: $\sum_{n\ge0} M t^n - \sum_{n<k} M t^n = M t^k/(1-t)$, obtained from the closed forms $M/(1-t)$ and $M(1-t^k)/(1-t)$. Apply (a) with $f_n = a^c_n t^n$, $g_n = M(c)t^n$, then substitute (b). $\square$

### 4.3 Sign control

**Proposition 4.5 (Positivity from the leading coefficient, in $t$).** Let $c \in \mathcal{B}$, let $n_0$ be such that $a^c_n = 0$ for $n<n_0$ and $a^c_{n_0} > 0$. If $0 < t$ and
$$t\,\bigl(M(c) + a^c_{n_0}\bigr) < a^c_{n_0},$$
then $E_c(t) > 0$.

*Proof sketch.* The hypothesis forces $t<1$. Truncating at $k = n_0+1$, the retained sum collapses to the single term $a^c_{n_0}t^{n_0}$, because all earlier coefficients vanish. Theorem 4.4 bounds the discarded tail by $M(c)t^{n_0+1}/(1-t)$. The hypothesis on $t$ is exactly what is needed to make this bound strictly smaller than $a^c_{n_0}t^{n_0}$: clearing the denominator, the required inequality is $M(c)\,t^{n_0}\,t < a^c_{n_0}t^{n_0}(1-t)$, i.e. $t(M(c)+a^c_{n_0}) < a^c_{n_0}$. Hence $E_c(t)$ exceeds a positive quantity minus a strictly smaller one. $\square$

**Theorem 4.6 (The leading nonzero monomial controls the eventual sign).** Let $c\in\mathcal{B}$ with $a^c_n = 0$ for $n < n_0$ and $a^c_{n_0}\ne0$. Then for all
$$x > \frac{M(c) + |a^c_{n_0}|}{|a^c_{n_0}|}$$
the sign of $\mathcal{E}_c(x)$ equals the sign of $a^c_{n_0}$; equivalently, $a^c_{n_0}\cdot \mathcal{E}_c(x) > 0$ eventually. In particular $\mathcal{E}_c$ is eventually nonvanishing whenever $c$ has a nonzero coefficient.

*Proof sketch.* For $a^c_{n_0}>0$, substitute $t = x^{-1}$ into Proposition 4.5; the condition $t(M+a_{n_0})<a_{n_0}$ becomes exactly $x > (M+a_{n_0})/a_{n_0}$. The negative case follows by applying the positive case to $-c$, using $\mathcal{E}_{-c} = -\mathcal{E}_c$. $\square$

**Remark 4.7 (Sharpness).** The eventual quantifier cannot be dropped, and the threshold is attained. There are bounded series whose interpretation vanishes exactly at the value of $x$ produced by the estimate; the leading monomial controls the *germ*, never the pointwise values on any smaller domain.

### 4.4 Realization and injectivity

**Theorem 4.8 (The interpretation realizes the expansion).** For every $c \in \mathcal{B}$, the germ $\mathcal{E}_c$ has $a^c$ as its classical asymptotic expansion.

*Proof sketch.* Fix $N$ and $\varepsilon>0$. Restrict to $x \ge 2$, so $t = x^{-1} \le 1/2$ and $1-t \ge 1/2$. Theorem 4.4 at $k = N+1$ gives
$$\Bigl|\mathcal{E}_c(x) - \sum_{n\le N} a^c_n x^{-n}\Bigr| \le \frac{M\,t^{N+1}}{1-t} \le 2M\,t^{N+1} = \bigl(2M\,x^{-1}\bigr)\cdot x^{-N}.$$
Choosing additionally $x \ge 2(M+1)/\varepsilon$ makes the bracket at most $\varepsilon$, which is precisely the little-o statement against $x^{-N}$. $\square$

**Theorem 4.9 (Extensionality on the fragment).** For $c,d \in \mathcal{B}$,
$$\mathcal{E}_c = \mathcal{E}_d \text{ eventually} \iff a^c = a^d .$$

*Proof sketch.* ($\Rightarrow$) By Theorem 4.8 and Lemma 3.2, the single germ $\mathcal{E}_c$ has both $a^c$ and $a^d$ as expansions; apply Theorem 3.4. ($\Leftarrow$) Equal coefficients give literally equal sums. $\square$

Theorem 4.9 is the positive half of the programme: on the normalized summable fragment, formal agreement at all ranks is *equivalent* to equality of eventual germs. The formal principle is exactly correct here.

---

## 5. Order: a lexicographic Hardy field

Injectivity says the interpretation separates points. In fact it does much more: it preserves and reflects a natural total order.

**Definition 5.1 (Lexicographic order).** For sequences $a,b:\mathbb{N}\to\mathbb{R}$ write $a \prec b$ if there is $n$ with $a_m = b_m$ for all $m<n$ and $a_n < b_n$. Clearly $a\prec b$ implies $a\ne b$.

**Lemma 5.2 (Linearity of the interpretation).** For $c,d \in \mathcal{B}$, eventually $\mathcal{E}_{c-d} = \mathcal{E}_c - \mathcal{E}_d$ (indeed for all $x>1$, by linearity of absolutely convergent sums).

**Theorem 5.3 (Equivalence with the leading monomial).** With $c, n_0$ as in Theorem 4.6,
$$\mathcal{E}_c(x) \;\sim\; a^c_{n_0}\,x^{-n_0}, \qquad x\to+\infty .$$

*Proof sketch.* The expansion property at level $n_0$ (Theorem 4.8) says $\mathcal{E}_c(x) - \sum_{n \le n_0} a^c_n x^{-n} = o(x^{-n_0})$, and by vanishing of the earlier coefficients the sum is the single term $a^c_{n_0}x^{-n_0}$. Dividing by the nonzero constant $a^c_{n_0}$ converts $f - g = o(x^{-n_0})$ into $f - g = o(g)$, which is asymptotic equivalence. $\square$

**Theorem 5.4 (Lexicographic order implies germ order).** If $a^c \prec a^d$ then eventually $\mathcal{E}_c(x) < \mathcal{E}_d(x)$.

*Proof sketch.* Let $n_0$ witness $a^c\prec a^d$. The difference series $d-c$ lies in $\mathcal{B}$, has vanishing coefficients below $n_0$, and has positive coefficient $a^d_{n_0}-a^c_{n_0}$ at $n_0$. Theorem 4.6 makes $\mathcal{E}_{d-c}$ eventually positive; Lemma 5.2 identifies it eventually with $\mathcal{E}_d - \mathcal{E}_c$. $\square$

**Theorem 5.5 (Trichotomy: no oscillation).** For all $c,d\in\mathcal{B}$ exactly one of the following holds:
(i) $a^c = a^d$ and $\mathcal{E}_c = \mathcal{E}_d$ eventually;
(ii) eventually $\mathcal{E}_c < \mathcal{E}_d$;
(iii) eventually $\mathcal{E}_d < \mathcal{E}_c$.

*Proof sketch.* If the coefficient sequences agree we are in case (i) by Theorem 4.9. Otherwise the set of indices where they differ is nonempty; let $n_0$ be its least element. Below $n_0$ the coefficients agree, and at $n_0$ they are distinct reals, hence comparable; whichever way they compare, Theorem 5.4 delivers (ii) or (iii). Mutual exclusivity follows because the intersection of two eventual conditions is eventual and nonempty, so no two cases can hold simultaneously. $\square$

Theorem 5.5 is the Hardy-field property: the germs of the fragment are pairwise eventually comparable. This is a genuine restriction — general germs oscillate ($\sin x$ against $0$ crosses infinitely often) — and it is what licenses reasoning "for large $x$" without qualification.

**Theorem 5.6 (Order embedding).** For $c,d\in\mathcal{B}$,
$$\bigl(\text{eventually } \mathcal{E}_c < \mathcal{E}_d\bigr) \iff a^c \prec a^d .$$

*Proof sketch.* ($\Leftarrow$) is Theorem 5.4. ($\Rightarrow$): run Theorem 5.5. Case (i) contradicts the hypothesis, since two eventual statements are jointly satisfiable at some point. Case (iii) likewise contradicts it by asymmetry. So case (ii) holds, and unwinding the first-difference index used in its proof yields exactly the witness for $a^c \prec a^d$. $\square$

Together with the evident transitivity and irreflexivity of the eventual-domination relation, Theorem 5.6 says the interpretation is an isomorphism of ordered sets from $(\mathcal{B}/{\sim}, \prec)$ onto its image in the germ order, where $\sim$ is equality of coefficient sequences.

---

## 6. The flat kernel: the exact defect

### 6.1 Flatness

**Definition 6.1 (Flat germ).** A function $f$ is *flat* if $f = o(x^{-n})$ for every $n \in \mathbb{N}$; equivalently, $x^n f(x) \to 0$ for all $n$.

**Proposition 6.2 (Linear structure).** The flat functions contain $0$ and are closed under negation, addition, subtraction, and multiplication by real constants.

**Proposition 6.3 (Ideal property).** If $f$ is flat and $g = O(1)$ at $+\infty$, then $gf$ is flat.

*Proof sketch.* Composing "big-O times little-o is little-o" at each rank: $g\cdot f = O(1)\cdot o(x^{-n}) = o(x^{-n})$. $\square$

**Proposition 6.4 (Nontriviality).** The function $e^{-x}$ is flat and nowhere zero. Hence flatness does not imply vanishing.

*Proof sketch.* Flatness is the statement $x^n e^{-x} \to 0$ for each $n$, the classical dominance of exponential decay over polynomial growth; here it is packaged as $e^{-x}/x^{-n} = x^n e^{-x} \to 0$, valid because $x^{-n}$ is eventually nonzero. $\square$

### 6.2 The fibre theorem

**Theorem 6.5 (Fibres of the expansion map).** Suppose $f$ has expansion $a$. Then for any $g$:
$$g \text{ has expansion } a \iff f - g \text{ is flat}.$$

*Proof sketch.* Both directions are the same cancellation. ($\Rightarrow$) At each level $N$, subtract the two defining estimates; the truncated sums cancel identically and the difference of the remainders is $(f-g)(x)$ up to that cancellation, so $(f-g) = o(x^{-N})$. ($\Leftarrow$) Given the estimate for $f$ at level $N$ and flatness of $f-g$ at level $N$, subtract: $\bigl(f(x)-\sum_{n\le N}a_nx^{-n}\bigr) - (f-g)(x) = g(x) - \sum_{n\le N}a_n x^{-n}$, a difference of two $o(x^{-N})$ terms. $\square$

**Corollary 6.6 (Failure of analytic extensionality, exactly quantified).** The expansion map is not injective on germs — $0$ and $e^{-x}$ both have the zero expansion yet differ at every point — and the exact obstruction to injectivity is the flat ideal: two germs have the same expansion if and only if they are congruent modulo flat germs.

### 6.3 The fragment as a set of canonical representatives

**Theorem 6.7 (No flat germs in the fragment).** For $c \in \mathcal{B}$: $\mathcal{E}_c$ is flat $\iff$ $a^c = 0$.

*Proof sketch.* If $\mathcal{E}_c$ is flat then it has the zero expansion (the truncations of the zero series are zero, so the defining estimates are exactly flatness), and it has expansion $a^c$ by Theorem 4.8; uniqueness gives $a^c=0$. Conversely, zero coefficients give the zero germ, which is flat. $\square$

**Corollary 6.8.** No bounded series interprets to $e^{-x}$: if $\mathcal{E}_c = e^{-x}$ eventually then $a^c = 0$ by Theorems 4.8 and 3.4, forcing $\mathcal{E}_c \equiv 0$, contradicting $e^{-x}\ne0$.

**Theorem 6.9 (Flat difference collapses on the fragment).** For $c,d\in\mathcal{B}$: $\mathcal{E}_c - \mathcal{E}_d$ is flat $\iff a^c = a^d$.

**Theorem 6.10 (Realization / canonical representative).** For $c \in \mathcal{B}$ and any germ $g$:
$$g \text{ has expansion } a^c \iff \mathcal{E}_c - g \text{ is flat}.$$
Thus $\mathcal{E}_c$ is the unique *summable* representative of its own asymptotic expansion, and every other representative is obtained from it by adding an arbitrary flat correction.

The picture is now complete on the additive side. Write $\mathcal{G}$ for the space of germs admitting an expansion, $\mathcal{F}\subset\mathcal{G}$ for the flat germs. The expansion map induces an injection $\mathcal{G}/\mathcal{F} \hookrightarrow \{\text{formal series}\}$, and the interpretation $\mathcal{E}:\mathcal{B}\to\mathcal{G}$ is a section over its image, with $\mathcal{E}(\mathcal{B})\cap\mathcal{F} = \{0\}$. In words: **coefficient extensionality is valid modulo flatness, and not one bit further.**

---

## 7. Multiplication: the Cauchy product

### 7.1 Multiplicativity

**Definition 7.1 (Cauchy product).** For coefficient sequences $a,b$ define
$$(a*b)_n = \sum_{i+j=n} a_i\, b_j = \sum_{i=0}^{n} a_i b_{n-i}.$$

**Theorem 7.2 (Multiplicativity of the interpretation).** For $c,d\in\mathcal{B}$ and $0 \le t < 1$,
$$E_c(t)\,E_d(t) = \sum_{n\ge0} (a^c * a^d)_n\, t^n .$$
Consequently, eventually in $x$,
$$\mathcal{E}_c(x)\,\mathcal{E}_d(x) = \sum_{n\ge0}(a^c*a^d)_n\,x^{-n}.$$

*Proof sketch.* Both $\sum_n \|a^c_n t^n\|$ and $\sum_n \|a^d_n t^n\|$ converge (Lemma 4.3), so the product of the sums may be reorganized as a sum over antidiagonals — the absolutely convergent form of Mertens' theorem. On the antidiagonal $i+j=n$ one has $t^i t^j = t^n$, which converts $\sum_{i+j=n} a_i t^i b_j t^j$ into $\bigl(\sum_{i+j=n}a_ib_j\bigr)t^n$. For the germ form, take $t = x^{-1}$ and note $x>1 \Rightarrow 0\le x^{-1}<1$. $\square$

So the interpretation is compatible with multiplication *wherever both sides make sense*. The question is whether the source is closed.

### 7.2 The bounded fragment is not closed

**Proposition 7.3 (Linear bound).** For $c,d\in\mathcal{B}$,
$$\bigl|(a^c * a^d)_n\bigr| \le (n+1)\,M(c)M(d).$$

*Proof sketch.* The antidiagonal $\{(i,j) : i+j=n\}$ has exactly $n+1$ elements and each summand is bounded by $M(c)M(d)$; apply the triangle inequality. $\square$

**Definition 7.4 (All-ones series).** Let $\mathbf{1} \in \mathcal{B}$ have $a_n = 1$ for all $n$ and $M = 1$; its interpretation is $\sum_n x^{-n} = x/(x-1)$ for $x>1$.

**Lemma 7.5.** $(\mathbf{1}*\mathbf{1})_n = n+1$.

**Theorem 7.6 (The bounded fragment is not a ring).** The sequence $(\mathbf{1}*\mathbf{1})_n = n+1$ is unbounded; hence there is no bounded series with the Cauchy-product coefficients of $\mathbf{1}$ with itself, and the bounded fragment is not closed under the Cauchy product.

*Proof sketch.* Given any candidate bound $M$, choose a natural number $n > M$; then $|(\mathbf{1}*\mathbf{1})_n| = n+1 > M$. $\square$

Proposition 7.3 is therefore *best possible*: the linear factor $n+1$ cannot be improved to a constant. Note carefully where the failure lies. The interpretation is multiplicative (Theorem 7.2), and the product germ $\bigl(x/(x-1)\bigr)^2$ is a perfectly respectable function with the asymptotic expansion $\sum_n (n+1)x^{-n}$. What fails is that the *coefficient norm defining the fragment* — the supremum norm — is not submultiplicative for convolution. The defect is in the choice of fragment, not in the interpretation.

### 7.3 The geometric fragment

**Definition 7.7 (Geometric series fragment).** A *geometric series* at rate $\rho>0$ with constant $M$ is a coefficient sequence with $|a_n| \le M\rho^n$ for all $n$. Write $\mathcal{G}_\rho$ for the corresponding fragment; $\mathcal{B} = \mathcal{G}_1$ up to the constant. Such a series converges for $\rho t < 1$, i.e. for $x > \rho$.

The entire bounded theory generalizes verbatim, with $t$ replaced by $\rho t$ in the geometric estimates.

**Theorem 7.8 (Tail bound, geometric case).** If $|a_n|\le M\rho^n$, $t \ge 0$, and $\rho t<1$, then
$$\left| \sum_{n\ge0} a_n t^n - \sum_{n<k} a_n t^n\right| \le \frac{M(\rho t)^k}{1-\rho t}.$$

**Theorem 7.9 (Realization and injectivity, geometric case).** The germ of a geometric series has that series as its asymptotic expansion; and two geometric series have eventually equal germs if and only if their coefficient sequences coincide.

*Proof sketch.* Identical in shape to Theorems 4.8 and 4.9. For realization, restrict to $x \ge 2\rho$, so $\rho x^{-1} \le 1/2$; the tail bound at $k=N+1$ then reads $\le 2M(\rho x^{-1})^{N+1} = \bigl(2M\rho^{N+1}x^{-1}\bigr)x^{-N}$, and the bracket is eventually below any $\varepsilon$. Injectivity follows from realization plus uniqueness of coefficients. $\square$

**Theorem 7.10 (Product closure).** If $|a_n| \le M\rho^n$ and $|b_n| \le M'\sigma^n$, then with $\rho^* = \max(\rho,\sigma)$,
$$\bigl|(a*b)_n\bigr| \;\le\; (n+1)\,MM'\,(\rho^*)^n \;\le\; MM'\,(2\rho^*)^n .$$
Hence the geometric fragment is closed under the Cauchy product, at the cost of doubling the rate.

*Proof sketch.* On the antidiagonal $i+j=n$, bound $|a_i| \le M(\rho^*)^i$ and $|b_j|\le M'(\rho^*)^j$ (monotonicity of $\rho\mapsto\rho^k$ for the enlarged base), multiply to get $MM'(\rho^*)^n$ per term, and sum $n+1$ terms. The second inequality is $n+1 \le 2^n$ for all $n\ge0$, which follows from $n < 2^n$. $\square$

**Theorem 7.11 (Expansion of a product).** If $f$ and $g$ are germs of geometric series with coefficients $a$ and $b$, then $fg$ has asymptotic expansion $a*b$.

*Proof sketch.* By Theorem 7.10 the sequence $a*b$ defines an element of the geometric fragment at rate $2\rho^*$; by Theorem 7.9 its germ realizes $a*b$ as an expansion; by the germ form of Theorem 7.2 that germ agrees eventually with $fg$; conclude by Lemma 3.2. $\square$

### 7.4 Sharpness of the rate inflation

The factor $2$ in Theorem 7.10 is an artefact of the convenient bound $n+1\le2^n$. How much of the inflation is intrinsic?

**Lemma 7.12 (Absorbing a linear factor).** For $q>1$ and all $n \in \mathbb{N}$,
$$n+1 \;\le\; \Bigl(1 + \tfrac{1}{q-1}\Bigr)\,q^n .$$

*Proof sketch.* Bernoulli's inequality gives $q^n = (1+(q-1))^n \ge 1 + n(q-1)$. Multiplying by $K = 1+\tfrac1{q-1}$ and expanding, $K\bigl(1+n(q-1)\bigr) = K + nq \ge n+1$ since $K \ge 1$ and $q>1$. $\square$

**Theorem 7.13 (Arbitrarily small inflation).** Let $a,b$ be geometric with rates $\rho,\sigma$ and constants $M,M'$, and let $r > \rho^* = \max(\rho,\sigma)$. Then $a*b$ is geometric at rate $r$; explicitly
$$|(a*b)_n| \;\le\; \Bigl(1 + \tfrac{1}{r/\rho^* - 1}\Bigr) MM' \cdot r^n .$$

*Proof sketch.* Apply Theorem 7.10's linear bound and then Lemma 7.12 with $q = r/\rho^* > 1$, using $(r/\rho^*)^n(\rho^*)^n = r^n$. $\square$

Note the constant blows up as $r \downarrow \rho^*$, and the next theorem explains why it must.

**Theorem 7.14 (The inflation cannot be removed).** At the rate of the factors themselves, closure fails: $\mathbf{1}$ is geometric at rate $1$ with constant $1$, and $(\mathbf{1}*\mathbf{1})_n = n+1$ admits no bound of the form $M\cdot 1^n$.

*Proof sketch.* $M \cdot 1^n = M$, and $n+1$ exceeds any fixed $M$ for large $n$. $\square$

**Corollary 7.15 (Structural conclusion).** No single geometric rate defines a subring. The family $\{\mathcal{G}_\rho\}_{\rho>0}$, ordered by inclusion $\mathcal{G}_\rho\subseteq\mathcal{G}_{\rho'}$ for $\rho\le\rho'$, is a *directed system* of modules, closed under products in the sense that multiplication maps $\mathcal{G}_\rho\times\mathcal{G}_\sigma \to \mathcal{G}_{r}$ for every $r>\max(\rho,\sigma)$. The colimit — the set of coefficient sequences of at most exponential growth, i.e. those with $\limsup |a_n|^{1/n} <\infty$ — is a ring, and the germ interpretation is a ring homomorphism on it. This colimit is precisely the ring of germs of functions holomorphic in a neighbourhood of $\infty$, expanded at $\infty$.

---

## 8. Algorithms and computation

The theory is unusually algorithmic: every existence statement above comes with an explicit constant, and the constants are computable from the data $(a, M, \rho)$.

**Algorithm A (Certified evaluation).** *Input:* coefficients $a$ with bound $|a_n|\le M\rho^n$; a point $x>\rho$; a target accuracy $\varepsilon$. *Output:* a value $S$ and a certificate $|S - \mathcal{E}(x)| \le \varepsilon$.
Set $t = 1/x$ and $q = \rho t < 1$; choose the least $k$ with $Mq^k/(1-q) \le \varepsilon$, namely
$$k = \left\lceil \frac{\log\bigl(\varepsilon(1-q)/M\bigr)}{\log q} \right\rceil,$$
and return $S = \sum_{n<k} a_n t^n$ by Horner's rule. Correctness is exactly Theorem 7.8. Cost: $O(k)$ arithmetic operations, with $k = O(\log(1/\varepsilon)/\log(1/q))$ — linear in the number of accurate digits, with a constant that degrades as $x \downarrow \rho$.

**Algorithm B (Sign certification).** *Input:* $(a, M)$ bounded, with first nonzero index $n_0$. *Output:* the eventual sign and an explicit threshold. Return $\operatorname{sgn}(a_{n_0})$ together with $X^* = (M + |a_{n_0}|)/|a_{n_0}|$; by Theorem 4.6 the sign is certified for all $x > X^*$. Cost: $O(n_0)$. This converts an analytic question ("is this function eventually positive?") into a finite inspection of the coefficient list.

**Algorithm C (Lexicographic germ comparison).** *Input:* two coefficient lists, an index budget $N$. *Output:* the eventual order relation between the germs, or "undecided within budget". Scan $n=0,1,\dots,N$; at the first $n$ with $a_n \ne b_n$, return `<` or `>` according to the comparison of $a_n$ and $b_n$; if no difference is found, return "agree to order $N$". By Theorem 5.6 the answer, when returned, is exactly the eventual order of the germs — no analysis is required. Cost: $O(N)$, and the scan is a decision procedure for germ comparison on any class where the first difference is known to occur within a computable bound.

**Algorithm D (Cauchy product with certified rate).** *Input:* $(a,M,\rho)$, $(b,M',\sigma)$, target rate $r > \max(\rho,\sigma)$, truncation order $N$. *Output:* the coefficients $(a*b)_n$ for $n\le N$ and a certificate $|(a*b)_n| \le C r^n$ with $C = \bigl(1+\frac{1}{r/\rho^*-1}\bigr)MM'$. The coefficients are computed by direct convolution in $O(N^2)$, or in $O(N\log N)$ by FFT; the certificate is Theorem 7.13. Theorem 7.14 shows the constraint $r > \max(\rho,\sigma)$ cannot be relaxed to $r = \max(\rho,\sigma)$.

**Algorithm E (Flatness screening).** *Input:* a function $f$ given as a black box, an order $N$, a sample threshold $X$. *Output:* numerical evidence for or against flatness. Evaluate $x^n f(x)$ for $n \le N$ at increasing $x \ge X$ and test for decay. This is *not* a decision procedure, and cannot be: by Theorem 6.5 the flat germs are precisely the ambiguity of the expansion map, so no finite amount of expansion data distinguishes $f$ from $f + \text{flat}$. The algorithm is therefore best understood as a *demonstration of the obstruction*: it converges to the same output for $0$ and for $e^{-x}$.

---

## 9. Applications and interpretation

**9.1 Licence for formal manipulation.** The results give a precise licence. Any question about a germ that is invariant under adding a flat correction is answerable from the expansion alone, and — inside the fragment — answerable by a finite computation on coefficients: sign at infinity (Theorem 4.6), rate of decay (Theorem 5.3), which of two germs eventually dominates (Theorem 5.6), the expansion of a product (Theorem 7.11). Any question *not* invariant under flat corrections is not answerable from the expansion at all, no matter how many terms are computed.

**9.2 Why perturbation theory misses exponentially small effects.** Corollary 6.6 is the abstract form of the "beyond all orders" phenomenon. If two solutions of a differential equation differ by a flat germ — as happens routinely across Stokes lines, in barrier-penetration problems, and in the splitting of nearly degenerate eigenvalues — then their perturbative expansions are identical to all orders. Computing more terms is provably useless; the information lives in the kernel and must be recovered by non-perturbative means (resurgence, Borel–Laplace summation, exponential asymptotics), all of which work by adding structure *beyond* the expansion.

**9.3 Hardy-field behaviour and termination arguments.** Theorem 5.5 says fragment germs never oscillate. This is exactly the property one needs for statements like "the algorithm eventually terminates because this quantity is eventually decreasing", or "one of these two growth rates eventually wins". Whenever the quantities involved are expansions with geometrically bounded coefficients, the trichotomy is available and the comparison reduces to lexicographic inspection.

**9.4 Analytic-combinatorial dictionary.** Corollary 7.15 identifies the multiplicatively closed object as the sequences of at most exponential growth — precisely the coefficient sequences of functions holomorphic near $\infty$. So the "correct" fragment for a ring-theoretic treatment is not a normed space of coefficient sequences but a colimit; this is the same phenomenon that makes germs of holomorphic functions a direct limit over shrinking neighbourhoods rather than a Banach algebra.

**9.5 Sharpness as design guidance.** Theorem 7.14 warns against a natural but wrong definition. A reader designing a formal framework would naturally impose a uniform coefficient bound; the theory then has good additive and order properties (§4–§6) but is not closed under products. The correct fix — a directed family of geometric bounds — is forced, not chosen.

---

## 10. Limitations and scope

*The scale is the integer power scale.* Everything here concerns comparison against $x^r$, $r\in\mathbb{Z}$. Real or transfinite exponents, logarithmic terms $x^r(\log x)^k$, and exponential scales $e^{\lambda x}x^r$ all support analogous theories, but the ordered index set changes and with it the shape of the lexicographic statement. The uniqueness argument (Theorem 3.4) uses only that the scale is strictly ordered and eventually nonvanishing, so it generalizes immediately; the tail bounds are specific to the geometric structure of the power scale.

*The fragment is a fragment.* The bounded and geometric fragments consist of germs that are *convergent* sums. Genuinely divergent asymptotic series — the Stirling series, the Euler series $\sum (-1)^n n!\,x^{-n-1}$ — lie outside, and for them injectivity of the interpretation is not even a meaningful question until a summation method is fixed. Extending the order-embedding theorem to a Borel-summable class is the most natural open direction.

*Flatness is not decidable from data.* As noted in Algorithm E, the flat kernel is by construction invisible to expansion data. Any effective treatment of the kernel requires information about the function beyond its expansion — analytic continuation, growth in complex sectors, or a differential equation it satisfies.

*One-sided limit point.* All statements are at $+\infty$. The germ at $-\infty$, or at a finite point, requires the corresponding scale; for a finite point the "flat" functions are the classic $e^{-1/x^2}$-type examples, and the fibre theorem holds verbatim with the same proof.

---

## 11. Future directions

The natural continuations, in rough order of accessibility:

1. **Divergent but summable fragments.** Replace convergence by Borel summability. Does the order embedding of Theorem 5.6 survive on a Borel-summable class? The obstruction is that summation is only defined after a choice of direction, and different directions differ by exactly a flat correction — the Stokes phenomenon. Making Theorem 6.5 the organizing principle of that discussion would be an attractive reformulation.

2. **The colimit as a ring.** Corollary 7.15 asserts that the sequences with $\limsup|a_n|^{1/n}<\infty$ form a ring on which the interpretation is a ring homomorphism. Developing this directly — units, the local structure at $\infty$, the relation to germs of holomorphic functions — would replace the current family of module-level statements with a single algebraic one.

3. **Differentiation and the Hardy-field axioms.** A Hardy field is closed under differentiation as well as arithmetic. Termwise differentiation of a geometric series stays geometric at any inflated rate (the extra factor $n$ is absorbed exactly as in Lemma 7.12), so the fragment should be a genuine Hardy field. Confirming closure under division by nonvanishing elements — where the leading-coefficient sign control of Theorem 4.6 supplies the eventual nonvanishing — would complete the picture.

4. **Finer scales.** Adjoin logarithms: the scale $x^r(\log x)^k$ ordered lexicographically by $(r,k)$. Theorem 3.4 transfers; what changes is that the index set is no longer of order type $\omega$, so the "first difference" in Theorem 5.6 must be taken in a well-ordered index set.

5. **Quantitative flatness.** Stratify the flat ideal by decay rate ($e^{-x}$ versus $e^{-x^2}$ versus $e^{-e^x}$) and ask which quotients of the flat ideal are detected by refined scales. This is the abstract skeleton of resurgence theory.

6. **Effective thresholds elsewhere.** Theorem 4.6 gives a sharp, explicit threshold for sign determination. Analogous explicit thresholds for the trichotomy of Theorem 5.5 — how large must $x$ be before the lexicographic order is realized? — are computable from the tail bound and would make Algorithm C fully quantitative.

---

## 12. Conclusion

Coefficient extensionality — "equal coefficients, equal object" — is a definition in the formal world and a theorem, a falsehood, or a theorem-with-a-correction in the analytic one, depending on where one stands.

On the convergent fragment it is a theorem: the interpretation of a bounded (or geometrically bounded) series into germs at $+\infty$ is injective, linear, an order embedding for the lexicographic order, and multiplicative. Its image contains a unique representative of each expansion it realizes, and the leading nonzero monomial controls the sign, the asymptotic size, and the comparisons, with explicit and sharp thresholds.

On arbitrary germs it is false, and the failure is exactly the flat ideal: two germs share an expansion if and only if they differ by a germ negligible against every rank. The ideal is nontrivial, absorbs bounded multipliers, and meets the fragment only at zero.

And on the multiplicative side, the naive fragment breaks — the supremum norm on coefficients is not submultiplicative under convolution — while the geometric fragments repair it as a directed system, with a rate inflation that can be made arbitrarily small but never eliminated.

The final statement is short. *Formal asymptotic reasoning is valid exactly modulo flatness; inside the convergent fragment there is nothing to be modulo, and the formal and analytic worlds coincide completely.*
