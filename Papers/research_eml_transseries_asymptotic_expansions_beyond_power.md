# The Ordered Field of Exponential–Logarithmic Transseries: Structure, Faithfulness, and the Reduction of Real Closedness

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

We develop the theory of an explicit ordered field $\mathbb{T}$ of *exponential–logarithmic (EML) transseries*: Hahn series whose value group is the four-dimensional lexicographically ordered group $\mathbb{R}^4$, whose coordinates record the four scales of the growth hierarchy $e^{e^x} \gg e^x \gg x \gg \log x$. We prove that the transmonomials form a multiplicative group isomorphic to $(\mathbb{R}^4,+)$ whose asymptotic ordering is exactly the lexicographic ordering of exponent data; that $\mathbb{T}$ is a non-Archimedean ordered field in which every positive element has $n$-th roots of all orders, so that the nonnegative elements are precisely the squares and $\mathbb{T}$ is Euclidean and formally real; and that consequently the ordering is definable in the ring language, is the unique compatible ordering, and is preserved by every ring homomorphism out of $\mathbb{T}$.

We then connect $\mathbb{T}$ to analysis. The algebra $\mathcal{E}$ of finite real linear combinations of transmonomials maps into $\mathbb{T}$ by formal expansion and into the ring of germs at $+\infty$ by evaluation; we prove that both maps are injective ring homomorphisms with identical fibres and that the correspondence is an order isomorphism onto its image. The key result is the **Asymptotic Comparison Theorem** in two forms: a transseries dominated by every transmonomial is zero, and an EML function that is $o(\mathfrak{m})$ for every transmonomial $\mathfrak{m}$ is zero. Thus the EML scale admits no flat germs and the transseries expansion is a complete invariant. We equip $\mathcal{E}$ with a derivation computing the analytic derivative, identify its kernel as exactly $\mathbb{R}$, prove that EML germs form a Hardy field (eventual monotonicity, existence of limits in $\mathbb{R}\cup\{\pm\infty\}$, eventual injectivity), and establish a Liouville-type obstruction: $1/(x\log x)$ has no antiderivative in $\mathcal{E}$, because $\log\log x$ is flat against the entire EML scale.

Finally we attack real closedness of $\mathbb{T}$. We reduce it to the odd-degree root property for monic polynomials, exhibit roots that are not obtainable by radicals via a Henselian lifting argument (the *casus irreducibilis* cubic $z^3 - 3z + t$ for infinitesimal $t$), and prove a Newton scaling theorem normalising an arbitrary monic polynomial together with a Cauchy root bound, sharpening the reduction to *normalised* monic odd-degree polynomials. Full real closedness of $\mathbb{T}$ remains open; we delimit the gap precisely.

**Keywords:** transseries, Hahn series, Hardy field, asymptotic expansion, real closed field, Newton polygon, Hensel's lemma, exp-log functions.

---

## 1. Introduction

### 1.1 The problem with power series at infinity

Asymptotic analysis at $+\infty$ has always suffered from an expressivity gap. A power series in $1/x$ can describe the behaviour of $x/(x+1)$ or of $e^{1/x}$, but it cannot describe $e^x$, $\log x$, or $x^{\pi}$. Worse, it cannot *distinguish*: the classical obstruction is the existence of **flat** functions, nonzero functions all of whose asymptotic coefficients vanish. The standard example, $e^{-1/t^2}$ at $t=0$, translates at infinity into $e^{-x}$, which is $o(x^{-n})$ for every $n$ and therefore invisible to any expansion in powers of $1/x$. Asymptotic expansion in a fixed scale is thus not injective, and no amount of care recovers a function from its expansion.

Transseries fix the gap by enlarging the scale until it is *closed* under the operations one cares about, and then proving that in the enlarged scale nothing is flat. The construction goes back, in various forms, to Hardy's logarithmico-exponential functions, to Hahn's fields of formal series with well-ordered support, and, in its mature form, to the work of Écalle on resurgence and of Aschenbrenner, van den Dries and van der Hoeven on the model theory of transseries. This paper develops in full a concrete four-scale slice of that theory: enough to be entirely explicit and computable, and enough to carry all the structural theorems.

### 1.2 What is proved here

The results fall into five groups.

1. **The ordered field.** The construction of $\mathbb{T}$, the multiplicative group structure of transmonomials, the Scale Comparison Theorem identifying asymptotic comparison with lexicographic comparison of exponent data, the strict growth hierarchy, and non-Archimedeanity.
2. **Roots and order rigidity.** Existence of $n$-th roots of positive elements; the squares are the nonnegatives; formal reality; definability, uniqueness and rigidity of the ordering; the quadratic solvability criterion.
3. **Faithfulness.** The two ring homomorphisms out of the EML algebra $\mathcal{E}$, their injectivity, the order embedding, and the Asymptotic Comparison Theorem in formal and analytic form.
4. **Differential structure and Hardy-field behaviour.** The derivation and its compatibility with real differentiation; the constants theorem; eventual monotonicity, limits, and injectivity; the Liouville-type obstruction for $1/(x\log x)$.
5. **Towards real closedness.** Reduction to odd-degree monic polynomials, Henselian root construction beyond radicals, and Newton scaling normalisation with the resulting sharpened reduction.

Throughout, "eventually" means "for all sufficiently large $x$", and $f \prec g$ means $f = o(g)$ as $x\to+\infty$.

---

## 2. The rank group and the field of transseries

### 2.1 Growth ranks

**Definition 2.1 (Rank group).** The *EML rank group* is
$$\Gamma \;=\; \mathbb{R} \times_{\mathrm{lex}} \bigl(\mathbb{R}\times_{\mathrm{lex}}(\mathbb{R}\times_{\mathrm{lex}}\mathbb{R})\bigr),$$
that is, the additive group $\mathbb{R}^4$ with the lexicographic order: $(d,a,b,c) < (d',a',b',c')$ iff $d<d'$, or $d=d'\wedge a<a'$, or $d=d'\wedge a=a'\wedge b<b'$, or $d=d'\wedge a=a'\wedge b=b'\wedge c<c'$. Write $\rho(d,a,b,c)$ for the corresponding element.

$\Gamma$ is a linearly ordered abelian group. Two of its properties matter later.

**Lemma 2.2 (Divisibility).** For every $n \ge 1$ and every $g\in\Gamma$ there is $h\in\Gamma$ with $nh = g$; explicitly $h = \rho(d/n, a/n, b/n, c/n)$.

*Proof.* Scalar division in $\mathbb{R}$, coordinatewise, using $n\cdot\rho(d,a,b,c) = \rho(nd,na,nb,nc)$, which follows by induction from additivity of $\rho$. $\square$

**Lemma 2.3 (Surjectivity of the parametrisation).** Every element of $\Gamma$ is $\rho(d,a,b,c)$ for a unique quadruple $(d,a,b,c)$.

The intended meaning of a rank is fixed by the dictionary
$$\rho(d,a,b,c) \;\longleftrightarrow\; \mathfrak{m}_{d,a,b,c}(x) \;=\; \exp\bigl(d\,e^{x}\bigr)\,\exp(a x)\, x^{b}\,(\log x)^{c}.$$

### 2.2 Hahn series

**Definition 2.4 (Transseries).** The field of *EML transseries* is
$$\mathbb{T} \;=\; \mathbb{R}\bigl(\!\bigl(t^{\Gamma}\bigr)\!\bigr),$$
the field of Hahn series: functions $f : \Gamma \to \mathbb{R}$ whose support $\{g : f(g)\neq 0\}$ is well-ordered, with pointwise addition and convolution product. It is a field because $\Gamma$ is a linearly ordered group and $\mathbb{R}$ is a field; the well-ordering condition guarantees that each coefficient of a product is a finite sum and that inverses exist.

$\mathbb{T}$ carries a linear order: for $f\neq0$ let $\operatorname{ord}(f)=\min \operatorname{supp}(f)$ and $\operatorname{lc}(f) = f(\operatorname{ord}(f))$; declare $f>0$ iff $\operatorname{lc}(f)>0$. This makes $\mathbb{T}$ a strictly ordered field.

**Convention 2.5 (Sign of the exponent).** In a Hahn series a *large* exponent means a *small* series. Since we want a *large* transmonomial to be a *large* transseries, we place the transmonomial $\mathfrak{m}_{d,a,b,c}$ at the rank $\rho(-d,-a,-b,-c)$ and write
$$T(d,a,b,c) \;=\; t^{\rho(-d,-a,-b,-c)} \in \mathbb{T}, \qquad C(r) = r\,t^{0}\in\mathbb{T}.$$
Thus $x = T(0,0,1,0)$, $\log x = T(0,0,0,1)$, $e^x = T(0,1,0,0)$, $e^{e^x} = T(1,0,0,0)$.

### 2.3 Transmonomials as a group, and the comparison theorem

**Theorem 2.6 (Multiplicative structure).** The map $(d,a,b,c)\mapsto T(d,a,b,c)$ is an injective group homomorphism from $(\mathbb{R}^4,+)$ into $(\mathbb{T}^{\times},\cdot)$:
$$T(d,a,b,c)\,T(d',a',b',c') = T(d+d',a+a',b+b',c+c'),\qquad T(0,0,0,0)=1,$$
$$T(d,a,b,c)^{-1} = T(-d,-a,-b,-c),\qquad T(d,a,b,c)^n = T(nd,na,nb,nc).$$
Each $T(d,a,b,c)$ is positive with leading coefficient $1$.

*Proof sketch.* Monomials multiply by adding exponents, $t^{g}t^{h}=t^{g+h}$, and $\rho$ is additive; positivity is immediate from $\operatorname{lc}=1>0$. Inverse and power formulas follow. $\square$

**Theorem 2.7 (Scale Comparison Theorem).** For all real $d,a,b,c,d',a',b',c'$,
$$T(d,a,b,c) < T(d',a',b',c') \iff (d,a,b,c) <_{\mathrm{lex}} (d',a',b',c').$$

*Proof sketch.* Two positive monomials with equal coefficients compare inversely to their ranks: if $g'<g$ then $t^{g} < t^{g'}$, since at the least index where the two series differ — namely $g'$ — the second has a positive coefficient and the first has zero. Combining with the sign convention $T(d,a,b,c) = t^{\rho(-d,-a,-b,-c)}$ and the fact that negation reverses the lexicographic order on $\Gamma$ gives the claim. $\square$

Theorem 2.7 is the formal counterpart of the entire folklore of growth-rate comparison, and it yields the *strict* hierarchy: no finite power of one scale reaches the next.

**Corollary 2.8 (Growth hierarchy).** For every $n\in\mathbb{N}$ and every $r\in\mathbb{R}$,
$$C(r) < \log x, \qquad (\log x)^{n} < x, \qquad x^{n} < e^{x}, \qquad (e^{x})^{n} < e^{e^{x}},$$
and $x^{-1} < C(r)$ for every real $r>0$.

**Corollary 2.9 (Non-Archimedeanity).** $\mathbb{T}$ is not Archimedean: no integer multiple of $1$ exceeds $x$, since $n\cdot 1 = C(n) < \log x < x$.

---

## 3. Roots, squares and the rigidity of the ordering

### 3.1 Root extraction

The central technical device is the factorisation of a nonzero transseries into a monomial, a real scalar and a **$1$-unit**.

**Lemma 3.1 (Leading decomposition).** Every nonzero $f\in\mathbb{T}$ can be written $f = t^{g}\,r\,u$ where $g=\operatorname{ord}(f)$, $r=\operatorname{lc}(f)\neq0$, and $u = 1+\varepsilon$ with $\operatorname{ord}(\varepsilon)>0$, i.e. $\varepsilon$ infinitesimal.

*Proof sketch.* Set $u = r^{-1}t^{-g}f$. Its order is $0$ and its leading coefficient is $1$, so $u-1$ has strictly positive order. $\square$

**Lemma 3.2 (Binomial roots of $1$-units).** For every $1$-unit $u=1+\varepsilon$ and every $n\ge1$ there is a $1$-unit $v$ with $v^n=u$; namely $v=u^{1/n}$ defined by the binomial series
$$u^{s} \;=\; \sum_{k\ge0}\binom{s}{k}\varepsilon^{k}, \qquad \binom{s}{k}=\frac{s(s-1)\cdots(s-k+1)}{k!},$$
which is a well-defined element of $\mathbb{T}$ because $\operatorname{ord}(\varepsilon^{k}) = k\operatorname{ord}(\varepsilon)\to\infty$, so the family $(\binom{s}{k}\varepsilon^{k})_k$ is summable in the Hahn sense.

*Proof sketch.* The binomial power satisfies $u^{s}u^{s'}=u^{s+s'}$, $u^{0}=1$ and $u^{1}=u$; hence $u^{n\cdot s}=(u^{s})^{n}$ by induction on $n$, and taking $s=1/n$ gives $(u^{1/n})^{n}=u^{1}=u$. $\square$

Note that this step is where infinite sums are essential: $(1+x^{-1})^{1/2} = 1 + \tfrac12 x^{-1} - \tfrac18 x^{-2} + \tfrac1{16}x^{-3} - \cdots$ is genuinely infinite.

**Theorem 3.3 (Root extraction for positive transseries).** If $f>0$ and $n\ge1$, there is $h>0$ with $h^{n}=f$.

*Proof sketch.* Decompose $f = t^{g}r u$ as in Lemma 3.1, with $r>0$ because $f>0$. Choose $g_0\in\Gamma$ with $n g_0 = g$ (Lemma 2.2, divisibility), $s = r^{1/n}>0$ (real closedness of $\mathbb{R}$), and $v = u^{1/n}$ (Lemma 3.2). Then $h = t^{g_0} s v$ satisfies $h^{n} = t^{g}r u = f$, and $h>0$ since its leading coefficient is $s>0$. $\square$

**Corollary 3.4 (Euclidean field).** Every $f\ge0$ is a square, and conversely; that is, $\operatorname{IsSquare}(f) \iff f\ge0$.

**Corollary 3.5 (Odd roots).** For odd $n$, every $f\in\mathbb{T}$ (of any sign) has an $n$-th root: apply Theorem 3.3 to $|f|$ and use $(-h)^n=-h^n$.

**Corollary 3.6 (Formal reality).** $-1$ is not a sum of squares in $\mathbb{T}$: a sum of squares is a sum of nonnegative elements, hence nonnegative, while $-1<0$.

### 3.2 Order rigidity

**Theorem 3.7 (Definability of the ordering).** For all $f,g\in\mathbb{T}$:
$$f \le g \iff g-f \text{ is a square.}$$
Consequently $0<f \iff f\neq0 \wedge \operatorname{IsSquare}(f)$, and for every $f$, either $f$ or $-f$ is a square.

*Proof.* Immediate from Corollary 3.4 applied to $g-f$. $\square$

**Theorem 3.8 (Uniqueness of the ordering).** Let $R$ be any binary relation on $\mathbb{T}$ such that (i) $R(0,s^2)$ for all $s$, (ii) $R$ is translation-invariant ($R(a,b)\Rightarrow R(a+c,b+c)$), and (iii) $R$ is antisymmetric. Then $R(f,g)\iff f\le g$.

*Proof sketch.* If $f\le g$ then $g-f=s^{2}$ for some $s$, so $R(0,g-f)$ by (i) and $R(f,g)$ by (ii). Conversely if $R(f,g)$ but $g<f$, then $f-g=s^{2}$, giving $R(g,f)$ by the same argument, and (iii) forces $f=g$, contradicting $g<f$. $\square$

**Theorem 3.9 (Automatic monotonicity).** Every ring homomorphism $\varphi:\mathbb{T}\to K$ into an ordered field $K$ is monotone. In particular every field automorphism of $\mathbb{T}$ preserves the asymptotic ordering.

*Proof.* If $f\le g$, write $g-f=s^{2}$; then $\varphi(g)-\varphi(f)=\varphi(s)^{2}\ge0$. $\square$

Theorem 3.9 says the asymptotic hierarchy is not extra data layered on the algebra: it is a consequence of it. No algebraic symmetry can permute growth rates.

### 3.3 Quadratics

**Theorem 3.10 (Quadratic formula and solvability).** If $a\neq0$ and $b^{2}-4ac\ge0$, then $az^{2}+bz+c=0$ has a solution in $\mathbb{T}$; indeed two solutions with sum $-b/a$. Conversely, a monic quadratic has a root iff its discriminant is nonnegative:
$$\exists z\in\mathbb{T}:\; z^{2}+bz+c=0 \iff b^{2}-4c\ \ge\ 0.$$

*Proof sketch.* Forwards: let $s$ satisfy $s^{2}=b^{2}-4ac$ (Corollary 3.4) and take $z=(-b\pm s)/(2a)$; expanding verifies the equation. Backwards: if $z^{2}+bz+c=0$ then $(2z+b)^{2}=b^{2}-4c$, so the discriminant is a square, hence $\ge0$. $\square$

Thus $\sqrt{x}\in\mathbb{T}$ while $\sqrt{-1}\notin\mathbb{T}$.

---

## 4. The EML algebra and the faithfulness of expansion

### 4.1 Two representations

**Definition 4.1 (EML algebra).** Let $\mathcal{E} = \mathbb{R}[\Gamma]$ be the group algebra: finitely supported functions $p:\Gamma\to\mathbb{R}$, with convolution product. An element $p$ is a formal finite linear combination $\sum_{g} p(g)\,[g]$ of transmonomial symbols.

**Definition 4.2 (Two maps).** For $p \in \mathcal{E}$ put
$$\Phi(p) = \sum_{g} p(g)\,t^{g} \in \mathbb{T} \qquad\text{(formal expansion)},$$
$$E_p(x) = \sum_{g} p(g)\,\mathfrak{r}_g(x), \quad \mathfrak{r}_{\rho(d,a,b,c)}(x)=\exp(-d\,e^{x})\exp(-a x)\,x^{-b}(\log x)^{-c}$$
(the *EML function* of $p$, defined for $x>1$; the signs implement Convention 2.5).

Both $\Phi$ and $p\mapsto [E_p]$ (the germ at $+\infty$) are ring homomorphisms. That $\Phi$ is multiplicative is the definition of convolution; that $p\mapsto E_p$ is multiplicative rests on $\mathfrak{r}_{g+h}=\mathfrak{r}_g\mathfrak{r}_h$, itself a consequence of $\exp$ turning sums into products.

### 4.2 The analytic meaning of the lexicographic order

**Theorem 4.3 (Vanishing of positive-rank monomials).** If $g>0$ in $\Gamma$ then $\mathfrak{r}_g(x)\to0$ as $x\to+\infty$; if $g<0$ then $\mathfrak{r}_g(x)\to+\infty$.

*Proof sketch.* Write $g=\rho(d,a,b,c)$ and $\log \mathfrak{r}_g(x) = -d e^{x} - a x - b\log x - c\log\log x$. Lexicographic positivity of $(d,a,b,c)$ means the first nonzero coordinate is positive, and each term dominates all later ones: $e^{x}\gg x\gg\log x\gg\log\log x$. Hence $\log\mathfrak{r}_g(x)\to-\infty$ and $\mathfrak{r}_g(x)\to0$. $\square$

This is the exact analytic content of Theorem 2.7: the formal ordering *is* the asymptotic ordering.

**Theorem 4.4 (Dominant-term theorem).** If $p\neq0$ with minimal rank $g_0$ in its support and $\kappa=p(g_0)$, then $E_p(x)/\mathfrak{r}_{g_0}(x)\to\kappa$; in particular $E_p$ is eventually of the constant sign of $\kappa$ and eventually nonvanishing.

*Proof sketch.* Divide $E_p$ by $\mathfrak{r}_{g_0}$: the $g_0$-term contributes $\kappa$, and every other term contributes $p(g)\mathfrak{r}_{g-g_0}$ with $g-g_0>0$, which tends to $0$ by Theorem 4.3. $\square$

### 4.3 Faithfulness

**Theorem 4.5 (Asymptotic sign theorem).** $\Phi(p)>0$ implies $E_p(x)>0$ eventually.

**Theorem 4.6 (Faithfulness of the expansion).** For $p,q\in\mathcal{E}$:
$$E_p =_{\text{eventually}} E_q \iff \Phi(p)=\Phi(q), \qquad E_p <_{\text{eventually}} E_q \iff \Phi(p)<\Phi(q).$$
Both $\Phi$ and $p\mapsto[E_p]$ are injective, with identical fibres.

*Proof sketch.* Both statements reduce, by linearity, to the case $q=0$: $E_r$ is eventually zero iff $r=0$, and eventually positive iff $\Phi(r)>0$. The forward direction of the second is Theorem 4.5. The converse is Theorem 4.4: if $r\neq0$, $E_r$ has the eventual sign of its dominant coefficient $\kappa=\operatorname{lc}(\Phi(r))$, which is exactly the sign of $\Phi(r)$; and $E_r$ is eventually nonzero. $\square$

**Corollary 4.7 (Hardy-field embedding).** The germs at $+\infty$ of EML functions form an ordered integral domain order-isomorphic to $\Phi(\mathcal{E})\subseteq \mathbb{T}$.

### 4.4 The Asymptotic Comparison Theorem

**Theorem 4.8 (Formal comparison).** Let $u\in\mathbb{T}$ satisfy $|u| < T(d,a,b,c)$ for *all* real $d,a,b,c$. Then $u=0$. Equivalently, for $f,h\in\mathbb{T}$:
$$f = h \iff |f-h| < T(d,a,b,c) \text{ for all } d,a,b,c\in\mathbb{R}.$$

*Proof sketch.* Suppose $u\neq0$; then $|u|>0$ has an order $g_1=\operatorname{ord}(|u|)$, and any transmonomial of rank strictly larger than $g_1$ is strictly smaller than $|u|$ (this is the monomial-below-a-positive-series lemma: if $g>\operatorname{ord}(v)$ and $v>0$ then $t^{g}<v$). Taking $g=g_1+\rho(0,0,0,1)$, say, contradicts the hypothesis. $\square$

This says that the value group leaves no "gap" through which a nonzero element of $\mathbb{T}$ could fall below the entire scale: the scale is *cofinal downwards* in the positive elements. It is the formal expression of "agreeing to all orders implies equality".

**Theorem 4.9 (No flat EML germs).** If $p\neq0$ then there exists a rank $g$ with $E_p \neq o(\mathfrak{r}_g)$.

*Proof sketch.* Take $g=g_0=\operatorname{ord}(\Phi(p))$; by Theorem 4.4, $E_p/\mathfrak{r}_{g_0}\to\kappa\neq0$, so $E_p$ is *asymptotic to* $\kappa\mathfrak{r}_{g_0}$ and in particular not $o(\mathfrak{r}_{g_0})$. $\square$

**Theorem 4.10 (Analytic comparison).** If $E_p - E_q = o(\mathfrak{r}_g)$ for every rank $g$, then $p=q$ (hence $E_p$ and $E_q$ have the same germ).

*Proof.* Apply Theorem 4.9 to $p-q$ and use linearity. $\square$

Theorem 4.10 is exactly the failure of the pathology described in §1.1: the EML scale contains no analogue of $e^{-1/x^{2}}$. Every nonzero EML function is *seen* by the scale. Thus the transseries expansion is a complete asymptotic invariant, and one may legitimately identify an EML function with its expansion.

---

## 5. Differential structure

### 5.1 The derivation

Differentiating $\mathfrak{r}_{\rho(d,a,b,c)}(x)=\exp(-de^{x}-ax-b\log x -c\log\log x)$ gives the logarithmic derivative
$$\frac{\mathfrak{r}'_{g}}{\mathfrak{r}_{g}} \;=\; -d\,e^{x} \;-\; a \;-\; \frac{b}{x} \;-\; \frac{c}{x\log x},$$
and each of $e^x$, $1$, $1/x$, $1/(x\log x)$ is again a transmonomial: they have ranks $\rho(0,-1,0,0)$, $0$, $\rho(0,0,1,0)$, $\rho(0,0,1,1)$ respectively. Hence:

**Definition 5.1.** Let $\operatorname{dlog}(g)\in\mathcal{E}$ be the element $-d[\rho(0,-1,0,0)] - a[0] - b[\rho(0,0,1,0)] - c[\rho(0,0,1,1)]$, and define
$$D(p) \;=\; \sum_{g} \bigl(p(g)[g]\bigr)\cdot \operatorname{dlog}(g).$$

**Theorem 5.2 (Leibniz rule).** $D$ is additive and satisfies $D(pq) = D(p)q + pD(q)$; thus $(\mathcal{E},D)$ is a differential ring.

*Proof sketch.* Both sides are additive in $p$ and in $q$, so it suffices to check on monomials $[g],[h]$, where the identity reduces to $\operatorname{dlog}(g+h) = \operatorname{dlog}(g)+\operatorname{dlog}(h)$ — the additivity of the coordinate functionals $d,a,b,c$ on $\Gamma$. $\square$

**Theorem 5.3 (The formal derivation is the analytic one).** For every $p\in\mathcal{E}$ and every $x>1$, the function $E_p$ is differentiable at $x$ with $E_p'(x) = E_{D(p)}(x)$.

*Proof sketch.* By linearity, reduce to a single transmonomial and apply the chain rule to $\exp$ of the log; the condition $x>1$ ensures $\log x>0$ so that $\log\log x$ and $x^{-b}$ are defined and differentiable. $\square$

**Theorem 5.4 (Nondegeneracy).** A transmonomial with nonzero exponent data has nonzero derivative.

### 5.2 The constants

**Theorem 5.5 (Kernel of the derivation).** $D(p)=0$ if and only if $p = c\cdot[0]$ for some $c\in\mathbb{R}$; equivalently, iff $E_p$ is eventually constant.

*Proof sketch.* The interesting direction is a cross-domain argument. If $D(p)=0$ then by Theorem 5.3, $E_p'(x)=0$ for all $x>1$, so $E_p$ is constant on $(1,\infty)$ by the mean value theorem, say $E_p \equiv c$. Then $q := p - c[0]$ has $E_q\equiv 0$, and injectivity of the germ representation (Theorem 4.6) gives $q=0$, i.e. $p=c[0]$. No combinatorial cancellation analysis inside $\mathcal{E}$ is needed. $\square$

This is a satisfying instance of a general principle in this development: analytic facts (MVT, IVT) and algebraic facts (injectivity, divisibility) are used interchangeably because the dictionary between them is exact.

### 5.3 Hardy-field behaviour

**Theorem 5.6 (Existence of limits).** For every $p\in\mathcal{E}$, exactly one of the following holds: $E_p \to L\in\mathbb{R}$, $E_p\to+\infty$, or $E_p \to -\infty$.

*Proof sketch.* If $p=0$ the limit is $0$. Otherwise let $g_0=\operatorname{ord}(\Phi(p))$ and $\kappa=p(g_0)$. If $g_0>0$ then $\mathfrak{r}_{g_0}\to0$ and $E_p\to0$; if $g_0=0$ then $E_p\to\kappa$; if $g_0<0$ then $\mathfrak{r}_{g_0}\to+\infty$ (Theorem 4.3) and by Theorem 4.4, $E_p\sim\kappa\mathfrak{r}_{g_0}\to\pm\infty$ according to the sign of $\kappa$. $\square$

**Theorem 5.7 (No oscillation).** For every $p\in\mathcal{E}$ there is $N$ such that $E_p$ is strictly increasing on $[N,\infty)$, or strictly decreasing on $[N,\infty)$, or constant on $[N,\infty)$.

*Proof sketch.* $D(p)\in\mathcal{E}$ again, so by Theorem 4.4 applied to $D(p)$, the derivative $E_p' = E_{D(p)}$ is eventually of constant sign — positive, negative, or identically zero (the last case exactly when $D(p)=0$, i.e. $p$ constant by Theorem 5.5). Continuity plus a constant-sign derivative on a half-line gives strict monotonicity there. $\square$

**Corollary 5.8 (Eventual injectivity).** A non-constant EML function is injective on some half-line $[N,\infty)$.

Theorems 5.6–5.8 are precisely the defining tameness properties of a Hardy field. They fail badly outside it: $\sin x$ has no limit, oscillates forever, and is nowhere eventually injective.

### 5.4 A Liouville-type obstruction

**Theorem 5.9.** $1/x$ has an antiderivative in $\mathcal{E}$, namely $\log x$: $D([\rho(0,0,0,-1)]) = [\rho(0,0,1,0)]$.

**Theorem 5.10 (Flatness of $\log\log x$).** For every rank $g$ with $\mathfrak{r}_g\to+\infty$, $\dfrac{\log\log x}{\mathfrak{r}_g(x)}\to 0$.

*Proof sketch.* $\mathfrak{r}_g\to+\infty$ forces $g<0$ lexicographically; the slowest such growth is achieved with $d=a=b=0$ and $c>0$, giving $(\log x)^{c}$, and $\log\log x = o((\log x)^{c})$ for every $c>0$ since $\log u = o(u^{c})$ with $u=\log x$. All other growing transmonomials dominate $(\log x)^{c}$. $\square$

**Theorem 5.11.** For no $p\in\mathcal{E}$ and $K\in\mathbb{R}$ is $E_p(x)=\log\log x+K$ eventually.

*Proof sketch.* Such an $E_p$ tends to $+\infty$, so by Theorem 5.6 and the dominant-term theorem it satisfies $E_p \sim \kappa\,\mathfrak{r}_{g_0}$ with $\kappa\neq0$ and $\mathfrak{r}_{g_0}\to+\infty$. But then $\log\log x/\mathfrak{r}_{g_0}(x)\to\kappa\neq0$, contradicting Theorem 5.10. $\square$

**Theorem 5.12 (No EML antiderivative for $1/(x\log x)$).** There is no $p\in\mathcal{E}$ with $D(p) = [\rho(0,0,1,1)]$.

*Proof.* If there were, then $f(x)=E_p(x)-\log\log x$ has $f'(x)=\frac{1}{x\log x}-\frac{1}{x\log x}=0$ on $(1,\infty)$, so $f$ is a constant $K$ and $E_p = \log\log x + K$, contradicting Theorem 5.11. $\square$

This is the exact one-level-up analogue of "$1/x$ has no rational antiderivative": closing the algebra under integration forces a new logarithm each time, and the tower never terminates. It is the local reason why transseries fields must in general admit infinitely many nested logarithms — our four-scale slice, being deliberately finite-dimensional, is not closed under integration, and this theorem says so precisely rather than vaguely.

---

## 6. Towards real closedness

### 6.1 The reduction

A field $R$ is *real closed* if it is semireal, every element or its negative is a square, and every odd-degree polynomial over $R$ has a root. For $\mathbb{T}$ the first two conditions are Corollaries 3.6 and 3.4.

**Theorem 6.1 (Reduction).** $\mathbb{T}$ is real closed if and only if every monic odd-degree polynomial in $\mathbb{T}[z]$ has a root in $\mathbb{T}$.

*Proof.* The semireality and square conditions are theorems; for the odd-degree clause, division by the leading coefficient reduces the general case to the monic case. $\square$

**Theorem 6.2 (The residue field is real closed).** $\mathbb{R}$ is a real closed field.

*Proof sketch.* Nonnegative reals are squares, and an odd-degree real polynomial changes sign at $\pm\infty$, hence has a root by the intermediate value theorem. $\square$

Together with Lemma 2.2 (divisibility of the value group), this supplies both classical inputs of the Newton-polygon proof strategy for real closedness of a Hahn field.

**Theorem 6.3 (Degree one).** Every degree-one polynomial over $\mathbb{T}$ has a root — trivially, since $\mathbb{T}$ is a field.

### 6.2 Roots beyond radicals: Hensel lifting

Theorem 3.3 produces roots of $z^{n}=f$. Many polynomial equations over an ordered field are provably *not* solvable by radicals; the classical example is the *casus irreducibilis* cubic. To reach those, we import Hensel's lemma along a one-parameter deformation.

**Definition 6.4 (Infinitesimals).** $t\in\mathbb{T}$ is *small* if $|t|<C(r)$ for every real $r>0$. Every transmonomial $T(d,a,b,c)$ with $(d,a,b,c)<_{\mathrm{lex}}0$ is small; e.g. $1/x$, $1/\log x$, $e^{-x}$. Small elements have strictly positive order.

**Theorem 6.5 (Henselianity of $\mathbb{R}[[X]]$).** The ring $\mathbb{R}[[X]]$ of formal power series is $X$-adically complete, hence Henselian at $(X)$. Consequently, if $F\in\mathbb{R}[[X]][z]$ is monic and its residue $F_0 = F \bmod X \in\mathbb{R}[z]$ has a *simple* real root $a$ (i.e. $F_0(a)=0$, $F_0'(a)\neq0$), then $F$ has a root $y\in\mathbb{R}[[X]]$ with constant term $a$.

*Proof sketch.* Completeness is the statement that the natural map to the inverse limit of $\mathbb{R}[[X]]/(X^{n})$ is an isomorphism, immediate from the definition of a formal power series. A complete local ring is Henselian, and the Henselian lifting property is exactly the assertion about simple residue roots (Newton's method converges $X$-adically: $y_{k+1} = y_k - F(y_k)/F'(y_k)$, with $F'(y_k)$ a unit because its constant term $F_0'(a)$ is a nonzero real). $\square$

**Theorem 6.6 (Substituting an infinitesimal).** For $t\in\mathbb{T}$ small there is a ring homomorphism $\mathrm{ev}_t:\mathbb{R}[[X]]\to\mathbb{T}$ with $\mathrm{ev}_t(X)=t$, $\mathrm{ev}_t(\text{const } r) = C(r)$, and $\mathrm{ev}_t$ preserving the constant term in the sense that the rank-$0$ coefficient of $\mathrm{ev}_t(f)$ is $f(0)$. It sends roots to roots: if $F(y)=0$ in $\mathbb{R}[[X]][z]$ then $(\mathrm{ev}_t F)(\mathrm{ev}_t y)=0$ in $\mathbb{T}[z]$.

*Proof sketch.* Because $t$ has positive order, the family $(f_k t^{k})_k$ is summable in the Hahn sense, so $f\mapsto \sum_k f_k t^{k}$ is well defined; it is a ring homomorphism because summable families multiply term by term. $\square$

**Theorem 6.7 (Deformation theorem).** Let $F\in\mathbb{R}[[X]][z]$ be monic whose specialisation at $X=0$ has a simple real root. Then for every small $t\in\mathbb{T}$, the polynomial obtained by substituting $t$ for $X$ has a root in $\mathbb{T}$.

*Proof.* Combine Theorems 6.5 and 6.6. $\square$

**Theorem 6.8 (Casus irreducibilis).** For every small $t\in\mathbb{T}$, the cubic
$$z^{3}-3z+t=0$$
has a root in $\mathbb{T}$, although its Cardano discriminant is strictly negative:
$$\left(\frac{t}{2}\right)^{2}+\left(\frac{-3}{3}\right)^{3} \;=\; \frac{t^{2}}{4}-1 \;<\;0 .$$

*Proof sketch.* The residue cubic $z^{3}-3z$ has the simple root $z=0$ (derivative $-3\neq0$ there), so Theorem 6.7 applies. For the discriminant: $|t|<C(2)$ gives $t^{2}<4$, hence $t^{2}/4-1<0$. $\square$

Theorem 6.8 is significant because a cubic with three real roots and negative Cardano discriminant provably cannot be solved by real radicals; the root is thus outside the reach of Theorem 3.3 and its corollaries. In contrast:

**Theorem 6.9 (Cardano in $\mathbb{T}$).** Every depressed cubic $z^{3}+pz+q$ with $(q/2)^{2}+(p/3)^{3}\ge0$ has a root in $\mathbb{T}$, given by Cardano's formula, using only the square and cube roots supplied by Theorem 3.3; hence so does every cubic with nonnegative discriminant.

Together, Theorems 6.8 and 6.9 cover all cubics whose discriminant is not infinitesimally close to $0$, and they show that the two available techniques — radicals and Hensel lifting — are genuinely complementary.

### 6.3 Newton scaling

The classical proof that a Hahn field over a real closed residue field with divisible value group is real closed proceeds by the Newton polygon: rescale so that the coefficients become comparable, reduce modulo infinitesimals, find a root of the residue polynomial, and lift. We prove the rescaling step in full.

**Definition 6.10 (Newton scaling).** For $\lambda\in\mathbb{T}^{\times}$ and $P\in\mathbb{T}[z]$ of degree $n$, set
$$\mathcal{N}_{\lambda}(P)(z) \;=\; \lambda^{-n}\,P(\lambda z).$$
Then $\mathcal{N}_\lambda(P)$ is monic of degree $n$ whenever $P$ is, its $i$-th coefficient is $\lambda^{i-n}a_i$ where $a_i=P_i$, and $z$ is a root of $\mathcal{N}_\lambda(P)$ iff $\lambda z$ is a root of $P$.

**Definition 6.11 (Normalised).** A monic $P$ of degree $n$ is *normalised* if $|a_i|\le1$ for all $i$ (all coefficients lie in the valuation ring) and, unless $P=z^{n}$, $|a_i|=1$ for some $i<n$.

**Theorem 6.12 (Newton Normalisation Theorem).** For every monic $P\in\mathbb{T}[z]$ there exists $\lambda>0$ in $\mathbb{T}$ such that $\mathcal{N}_{\lambda}(P)$ is normalised. Explicitly one may take
$$\lambda \;=\; \max_{\substack{i<n \\ a_i\neq0}} |a_i|^{1/(n-i)},$$
with $\lambda=1$ if $P=z^{n}$.

*Proof sketch.* The maximum exists because the order on $\mathbb{T}$ is total and the index set is finite; the fractional powers $|a_i|^{1/(n-i)}$ exist and are positive by Theorem 3.3. With this $\lambda$, the $i$-th coefficient of the scaled polynomial is $a_i\lambda^{i-n} = a_i/\lambda^{n-i}$, and by the choice of $\lambda$ we have $\lambda^{n-i}\ge|a_i|$, whence $|a_i\lambda^{i-n}|\le1$ for every $i<n$; the leading coefficient is $1$. If some $a_i\neq0$ with $i<n$, the index $i^{*}$ realising the maximum satisfies $\lambda^{n-i^{*}}=|a_{i^{*}}|$ exactly, so the corresponding scaled coefficient has absolute value exactly $1$. $\square$

**Theorem 6.13 (Cauchy root bound).** If $P$ is monic with all $|a_i|\le1$ and $P(z)=0$, then $|z|<2$.

*Proof sketch.* If $|z|\ge2$ then $|z|^{n} = |{-\textstyle\sum_{i<n}a_iz^{i}}| \le \sum_{i<n}|z|^{i} = \frac{|z|^{n}-1}{|z|-1}\le |z|^{n}-1 < |z|^n$, a contradiction. The geometric-sum manipulation is valid in any ordered field. $\square$

**Theorem 6.14 (Sharpened reduction).** $\mathbb{T}$ is real closed if and only if every *normalised* monic odd-degree polynomial over $\mathbb{T}$ has a root.

*Proof.* One direction is trivial. Conversely, given a monic odd-degree $P$, apply Theorem 6.12 to get a normalised $\mathcal{N}_{\lambda}(P)$ of the same degree; a root $z$ of it yields the root $\lambda z$ of $P$. Now invoke Theorem 6.1. $\square$

### 6.4 The remaining gap

Full real closedness of $\mathbb{T}$ is **not** established. What Theorem 6.14 achieves is a reduction to exactly the situation in which a Newton-polygon/Hensel argument operates:

- the polynomial is monic of odd degree $n$;
- all coefficients lie in the valuation ring $\mathcal{O}=\{|f|\le1\}$;
- the reduction modulo the maximal ideal (the infinitesimals) is a *genuine* monic real polynomial $\bar{P}\in\mathbb{R}[z]$ of degree $n$ with $\bar{P}\neq z^{n}$;
- $\mathbb{R}$ is real closed (Theorem 6.2), so $\bar{P}$, being of odd degree, has a real root;
- the value group is divisible (Lemma 2.2);
- all roots are bounded, $|z|<2$ (Theorem 6.13).

The remaining difficulty is precisely the case of a *multiple* residue root: Theorem 6.5 lifts simple residue roots only, and a multiple root requires a further scaling step (a genuine Newton-polygon induction on the multiplicity, with an accompanying well-foundedness argument). We regard the sharpened statement of Theorem 6.14 as the correct formulation of the open problem in this setting.

---

## 7. Algorithms

The theory is effective, and several proofs are algorithms in disguise.

**A. Dominant-term extraction and limit computation.** Given $p\in\mathcal{E}$ as a finite list of (rank, coefficient) pairs, sort ranks lexicographically, take the minimum $g_0=\rho(d,a,b,c)$ and its coefficient $\kappa$. Then $E_p \sim \kappa\,\mathfrak{r}_{g_0}$, and the limit is: $0$ if $g_0>0$; $\kappa$ if $g_0=0$; $\operatorname{sign}(\kappa)\cdot\infty$ if $g_0<0$. Cost: $O(m\log m)$ for $m$ terms, or $O(m)$ with a linear scan. This is the core of automated limit computation for exp-log expressions.

**B. Root extraction by leading decomposition + binomial series.** To compute $f^{1/n}$ to a prescribed depth $N$: extract $(g,r,\varepsilon)$ with $f = t^{g}r(1+\varepsilon)$; output $t^{g/n}\,r^{1/n}\sum_{k=0}^{N}\binom{1/n}{k}\varepsilon^{k}$, truncating products at rank depth $N$. Cost dominated by $N$ series multiplications.

**C. Newton scaling.** Compute $\lambda = \max_{i<n,\,a_i\neq0}|a_i|^{1/(n-i)}$ using B for the fractional powers and the lexicographic comparison for the maximum; return the coefficient list $(a_i\lambda^{i-n})_i$. Cost: $O(n)$ root extractions and $O(n)$ comparisons.

**D. Hensel/Newton lifting along a parameter.** Given monic $F\in\mathbb{R}[[X]][z]$ and a simple root $a$ of $F_0$, iterate $y_{k+1}=y_k - F(y_k)/F'(y_k)$ in $\mathbb{R}[[X]]$ truncated at order $2^{k}$; the $X$-adic valuation of $F(y_k)$ doubles each step (quadratic convergence), so $\lceil\log_2 N\rceil$ iterations give the root modulo $X^{N}$. Substituting a small transseries $t$ then yields the transseries root.

**E. Formal differentiation.** Replace each term $\kappa[g]$, $g=\rho(d,a,b,c)$, by $\kappa[g]\cdot(-d[\rho(0,-1,0,0)]-a[0]-b[\rho(0,0,1,0)]-c[\rho(0,0,1,1)])$ and collect. Cost: $O(m)$ monomial multiplications.

---

## 8. Applications and discussion

**Automated asymptotics.** Algorithm A is the theoretical basis of the "series/limit at infinity" facilities of computer algebra systems for exp-log expressions. Theorem 4.6 is what makes such an algorithm *correct*: comparing expansions decides comparison of germs, with no residual case analysis.

**Resurgence and non-perturbative physics.** Divergent perturbation series in quantum mechanics and field theory are completed by exponentially small terms $e^{-S/g}$; the natural home for such completed expansions is a transseries field where $e^{-1/g}$ is an honest, comparable object rather than a term that "does not appear in the expansion". Theorem 4.8 is the statement that such a field has no invisible content.

**Hardy fields and model theory.** Theorems 5.6–5.8 exhibit EML germs as a Hardy field. The o-minimality of the real exponential field implies that all functions definable there are eventually monotone with limits; our development obtains those conclusions concretely and constructively for the exp-log scale, from the dominant-term theorem alone.

**Differential algebra.** Theorem 5.5 (constants $=\mathbb{R}$) and Theorem 5.12 (no antiderivative for $1/(x\log x)$) place $\mathcal{E}$ within the Liouville theory of elementary integration: $\mathcal{E}$ is a differential ring whose constants are exactly the ground field and which is not closed under integration, the first obstruction appearing one logarithm above the classical one.

**Real algebra at infinity.** The Order Rigidity Theorem 3.9 is a statement of independent interest: the growth ordering of transseries cannot be broken by any algebraic symmetry. It means that "asymptotic size" is a ring-theoretic invariant of the field, which is why so many statements about growth can be reduced to polynomial identities.

**Limitations.** The scale used here is four-dimensional: $e^{e^{x}}$, $e^{x}$, $x$, $\log x$. It is therefore not closed under exponentiation (there is no $e^{e^{e^{x}}}$) nor under integration (Theorem 5.12). These are deliberate: the finite-dimensional scale keeps everything explicit and computable while still exhibiting all the structural phenomena. Extension to the full exp-log hierarchy is a matter of replacing $\mathbb{R}^{4}$ by a suitable direct limit of such groups, at the cost of losing the elementary lexicographic description of ranks.

---

## 9. Future work

Three directions are immediate.

1. **Closing the real-closedness gap.** By Theorem 6.14 it suffices to handle normalised monic odd-degree polynomials. The remaining case is a multiple root of the residue polynomial; the standard remedy is a Newton-polygon induction: substitute $z \mapsto \bar{a} + z_1$ where $\bar{a}$ is the multiple residue root, rescale again by Theorem 6.12, and observe that the multiplicity of the residue root strictly decreases or the degree drops. Making the induction well-founded in this setting — with the value group $\mathbb{R}^4$ and hence possibly non-discrete Newton slopes — is the crux.

2. **Deeper scales.** Replace $\Gamma=\mathbb{R}^{4}$ by the direct limit over $\Gamma_k = \mathbb{R}^{k}$ of iterated exponentials and logarithms, obtaining a scale closed under $\exp$, $\log$ and integration. The Asymptotic Comparison Theorem should persist; the flatness argument of Theorem 5.10 becomes a diagonal argument.

3. **Effective transseries arithmetic.** Algorithms A–E above can be assembled into a certified library for exp-log limits, asymptotic expansions and root finding, with the correctness statements being exactly the theorems of §§4–6.

---

## 10. Conclusion

Recording a growth rate as a point of $\mathbb{R}^4$ and comparing points lexicographically turns the informal hierarchy $e^{e^{x}}\gg e^{x}\gg x\gg\log x$ into arithmetic. Once that is done, the Hahn series construction supplies an ordered field $\mathbb{T}$ in which infinitely large and infinitely small quantities are first-class citizens; root extraction makes $\mathbb{T}$ Euclidean, hence its ordering definable, unique and rigid; and the dominant-term analysis makes the expansion map from exp-log functions faithful, so that a function and its expansion are interchangeable. The Asymptotic Comparison Theorem — no nonzero object hides below the whole scale — is the technical heart, and it is what rescues asymptotic expansion from the flat-function pathology that afflicts power series. The remaining question, real closedness, has been reduced to a single sharply stated clause about normalised monic odd-degree polynomials, with all the classical Newton-polygon inputs verified.
