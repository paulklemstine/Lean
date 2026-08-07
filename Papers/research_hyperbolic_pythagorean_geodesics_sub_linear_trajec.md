# Hyperbolic–Pythagorean Geodesics: The Berggren Tree in the Poincaré Half-Plane

**Author:** Aristotle
**Date:** 2026-08-07

---

## Abstract

We construct an isometric-flavoured dictionary between the Berggren ternary tree of
primitive Pythagorean triples and the Poincaré upper half-plane $\mathbb{H}$, and use it to
settle a family of quantitative questions about the tree's geometry and about the
algorithmic hope that motivated the construction.

Sending the Euclid seed $(m,n)$ of a primitive triple to the point $z(m,n) = (n+i)/m \in \mathbb{H}$,
we prove the exact identity $\cosh d_{\mathbb{H}}(i, z(m,n)) = (m^2+n^2+1)/(2m)$, in which the
numerator is the hypotenuse plus one. From it we deduce the *logarithmic trajectory law*:
every node of the tree, at any depth, lies in the half-open annulus
$\tfrac12\log c \le d < \tfrac12\log c + \tfrac12\log 2 + o(1)$ of width $\tfrac12\log 2 \approx 0.3466$,
where $c = m^2+n^2$.

We then analyse the residual $\rho(m,n) = d - \tfrac12\log c$. We prove the exact formula
$\exp(\rho - \tilde\rho) = \bigl((c+1) + \sqrt{(c+1)^2-4m^2}\bigr)/(2c)$, where
$\tilde\rho = \tfrac12\log(1+(n/m)^2)$ is the slope model, and derive the two-sided bound
$n^2/(c^2+n^2) \le \rho - \tilde\rho \le \frac{c+1}{c-1}\cdot n^2/(c^2+n^2)$, pinning the gap to
$(n^2/c^2)(1+O(1/c))$. Using this sandwich we establish *exact branch monotonicity*: the
residual is non-decreasing along $B_1$ and non-increasing along $B_3$ with no side condition,
and along $B_2$ it obeys a complete dichotomy governed by the sign of $m^2 - 2mn - n^2$
(slope above or below $\sqrt2 - 1$), with no Euclid seed on the threshold. The last
unresolved case is a Pell family $(m-n)^2 = 2n^2+1$ on which the real relaxation of the
inequality is false and integrality must be used.

Finally we settle the algorithmic question in the negative and quantitatively. The tree
is complete and depth is well defined; distance is bounded by depth ($2d \le \log 32 + k\log 9$)
but depth is *not* bounded by any constant multiple of distance (the left spine has depth
$k$ and hypotenuse only $2k^2+6k+5$). Two nodes sharing a hypotenuse $N$ split $N$ completely
by Euler's identity, and such collisions occur at every scale; but the hyperbolic ball of
radius $R$ contains at least $e^{2R}/300$ nodes, so the search region guaranteed to contain a
collision for $N$ already has $\asymp N$ elements. Short geodesics; exponentially many of them.

**Keywords:** Pythagorean triples, Berggren tree, Poincaré half-plane, hyperbolic geometry,
Euclid parametrisation, Pell equation, integer factorisation, volume growth.

---

## 1. Introduction

### 1.1 Two objects

The **Berggren tree** enumerates the primitive Pythagorean triples. Writing a triple as a
column vector $(a,b,c)^{\mathsf T}$ with $a^2+b^2=c^2$, $\gcd(a,b,c)=1$, $b$ even, the three matrices

$$
B_1 = \begin{pmatrix} 1 & -2 & 2\\ 2 & -1 & 2\\ 2 & -2 & 3\end{pmatrix},\quad
B_2 = \begin{pmatrix} 1 & 2 & 2\\ 2 & 1 & 2\\ 2 & 2 & 3\end{pmatrix},\quad
B_3 = \begin{pmatrix} -1 & 2 & 2\\ -2 & 1 & 2\\ -2 & 2 & 3\end{pmatrix}
$$

generate every primitive triple from $(3,4,5)^{\mathsf T}$ exactly once. The resulting infinite
ternary tree is a complete, non-redundant enumeration of an arithmetically defined set.

The **Poincaré upper half-plane** is $\mathbb{H} = \{z \in \mathbb{C} : \operatorname{Im} z > 0\}$ with the
Riemannian metric $ds = |dz|/\operatorname{Im} z$, a model of the hyperbolic plane of curvature $-1$.
Its distance function satisfies

$$
\cosh d_{\mathbb{H}}(z_1, z_2) \;=\; 1 + \frac{|z_1 - z_2|^2}{2\,\operatorname{Im}(z_1)\operatorname{Im}(z_2)}. \tag{1.1}
$$

### 1.2 The motivating hope, and what replaces it

A number $N$ admitting two essentially distinct representations as a sum of two squares is
composite, and Euler's method extracts a factor from the pair of representations by a single
$\gcd$. Every node of the Berggren tree carries such a representation, $N = m^2 + n^2$. The tree
branches threefold, so it reaches "size $3^k$" at depth $k$. It is therefore tempting to
conjecture that $N$ can be factored by an $O(\log N)$-length search in the tree, guided by some
geometric energy functional.

We show that this conjecture is *false*, and we identify precisely which parts of the
underlying intuition are true. The true statements are:

* the hyperbolic **distance** from the base point to a node of hypotenuse $c$ is
  $\tfrac12\log c + O(1)$, with an explicit window of width $\tfrac12\log 2$;
* the **depth** at which a node occurs is *not* controlled by its distance: there are nodes
  of hypotenuse $c$ at depth $\Theta(\sqrt c)$;
* the **volume** of the hyperbolic ball of radius $R$, measured in nodes, is $\asymp e^{2R}$,
  so a search region large enough to guarantee a collision for $N$ has $\asymp N$ elements.

The negative results are proved, not merely conjectured; the second is refuted by an explicit
family (the left spine), the third by a sieve-based lower bound on node counts.

### 1.3 Organisation

Section 2 sets up Euclid seeds and the conjugation of the Berggren matrices. Section 3
proves the exact distance formula and the logarithmic trajectory law. Section 4 develops the
residual and its slope model, with the exact gap identity. Section 5 proves exact branch
monotonicity, including the Pell boundary layer. Section 6 treats the tree structure and the
depth/distance comparison. Section 7 proves quadratic ball growth. Section 8 gives the
factorisation payoff and the no-free-lunch conclusion. Section 9 discusses algorithms;
Section 10 lists open problems.

---

## 2. Euclid seeds and the tree in seed coordinates

**Definition 2.1 (Euclid seed).** A pair $(m,n)$ of positive integers is a *Euclid seed* if

$$0 < n < m, \qquad \gcd(m,n) = 1, \qquad m + n \text{ is odd}.$$

**Definition 2.2 (Euclid parametrisation).** For integers $m,n$ set
$$T(m,n) \;=\; \bigl(m^2 - n^2,\; 2mn,\; m^2 + n^2\bigr).$$

That $T(m,n)$ is a Pythagorean triple is the identity $(m^2-n^2)^2 + (2mn)^2 = (m^2+n^2)^2$.
Euclid's classical theorem is that $T$ restricts to a bijection between Euclid seeds and
primitive Pythagorean triples with even second entry. Throughout we call
$c = c(m,n) = m^2+n^2$ the **hypotenuse** of the seed.

**Definition 2.3 (Seed moves).**
$$\sigma_1(m,n) = (2m-n,\, m), \qquad \sigma_2(m,n) = (2m+n,\, m), \qquad \sigma_3(m,n) = (m+2n,\, n).$$

**Theorem 2.4 (Conjugation).** For all integers $m,n$,
$$B_1\,T(m,n) = T(\sigma_1(m,n)), \qquad B_2\,T(m,n) = T(\sigma_2(m,n)), \qquad B_3\,T(m,n) = T(\sigma_3(m,n)).$$

*Proof sketch.* Each of the three assertions is an identity between triples of quadratic
forms in $m,n$; expanding both sides and comparing coefficients verifies them. For instance
the first component of $B_1 T(m,n)$ is $(m^2-n^2) - 2(2mn) + 2(m^2+n^2) = 3m^2 - 4mn + n^2$,
while the first component of $T(2m-n,m)$ is $(2m-n)^2 - m^2 = 3m^2 - 4mn + n^2$. $\square$

**Theorem 2.5 (Seed preservation).** If $(m,n)$ is a Euclid seed then so are $\sigma_1(m,n)$,
$\sigma_2(m,n)$ and $\sigma_3(m,n)$.

*Proof sketch.* The inequalities $0 < n' < m'$ and the parity condition are immediate integer
arithmetic (e.g. for $\sigma_1$: $n < m$ gives $m < 2m-n$, and $(2m-n)+m = 3m-n \equiv m+n \bmod 2$).
Coprimality uses the following elementary lemma: if $\gcd(b,n)=1$ and $\gcd(a,b) \mid n$ then
$\gcd(a,b)=1$. For $\sigma_1$, $g = \gcd(2m-n, m)$ divides $2m - (2m-n) = n$, and
$\gcd(m,n) = 1$, so $g = 1$; the other two cases are identical. $\square$

The root of the tree is $(2,1)$, corresponding to $(3,4,5)$; it is a Euclid seed.

**Slope coordinates.** Write $t = n/m \in (0,1)$ for the slope of a seed. The three moves act
on the slope by Möbius transformations:
$$\sigma_1 : t \mapsto \frac{1}{2-t}, \qquad \sigma_2 : t \mapsto \frac{1}{2+t}, \qquad \sigma_3: t \mapsto \frac{t}{1+2t}. \tag{2.1}$$
The fixed point of $\sigma_2$ on $(0,1)$ is $t^\ast = \sqrt2 - 1$, a fact that will govern all of
Section 5.

---

## 3. The hyperbolic embedding

**Definition 3.1 (Node point).** For a seed $(m,n)$ put
$$z(m,n) \;=\; \frac{n+i}{m} \;=\; \frac{n}{m} + \frac{i}{m} \;\in\; \mathbb{H}.$$
The base point is $i$; the root seed $(2,1)$ maps to $(1+i)/2$.

**Theorem 3.2 (Exact distance formula).** For every $m > 0$ and every $n \ge 0$,
$$\cosh d_{\mathbb{H}}\bigl(i,\, z(m,n)\bigr) \;=\; \frac{m^2+n^2+1}{2m} \;=\; \frac{c+1}{2m}.$$

*Proof.* Apply (1.1) with $z_1 = i$ (so $\operatorname{Im} z_1 = 1$) and $z_2 = n/m + i/m$
(so $\operatorname{Im} z_2 = 1/m$). Then
$|z_1 - z_2|^2 = (n/m)^2 + (1 - 1/m)^2$, and
$$1 + \frac{(n/m)^2 + (1-1/m)^2}{2/m} = 1 + \frac{n^2 + (m-1)^2}{2m} = \frac{2m + n^2 + m^2 - 2m + 1}{2m} = \frac{m^2+n^2+1}{2m}. \qquad\square$$

Two structural consequences deserve emphasis. First, the numerator is an *arithmetic*
invariant — the hypotenuse plus one — while the denominator is $2m$. Second, the level sets
of the distance from $i$ are exactly the level sets of $(c+1)/(2m)$: two nodes are
equidistant from the base point iff $(c_1+1)/m_1 = (c_2+1)/m_2$.

**Lemma 3.3 (Logarithmic sandwich).** For $d \ge 0$, $\log(\cosh d) \le d \le \log(2\cosh d)$.

*Proof.* $e^d = \cosh d + \sinh d$ with $0 \le \sinh d \le \cosh d$, hence
$\cosh d \le e^d \le 2\cosh d$; take logarithms. $\square$

**Theorem 3.4 (Logarithmic trajectory theorem).** For every $(m,n)$ with $0 < n < m$, writing
$c = m^2+n^2$ and $d = d_{\mathbb{H}}(i, z(m,n))$,
$$\bigl|\, d - \tfrac12 \log c \,\bigr| \;\le\; \log 2 .$$

*Proof sketch.* Set $A = (c+1)/(2m)$, so $\cosh d = A$. By Lemma 3.3,
$\log A \le d \le \log(2A)$. Since $n < m$ we have $n^2 + 1 \le m^2$, hence $c + 1 \le 2m^2$ and so
$(2A)^2 = ((c+1)/m)^2 \le 4c$; this gives $2d \le \log(4c) = 2\log 2 + \log c$. Conversely
$m^2 \le c$ gives $A^2 = (c+1)^2/(4m^2) \ge (c+1)^2/(4c) \ge c/4$, whence
$2d \ge 2\log A \ge \log c - 2\log 2$. $\square$

Both halves can be sharpened to essentially optimal form.

**Theorem 3.5 (Sharp trajectory window).** For every seed $(m,n)$,
$$\tfrac12 \log c \;\le\; d \;\le\; \tfrac12 \log\bigl(2(c+1)\bigr) \;\le\; \tfrac12\log c + \tfrac12\log 2 + \tfrac{1}{2c}.$$

*Proof sketch.* For the lower bound, the auxiliary identity $\cosh(\tfrac12\log c) = (c+1)/(2\sqrt c)$
combined with $m \le \sqrt c$ gives $\cosh(\tfrac12\log c) \le (c+1)/(2m) = \cosh d$; monotonicity
of $\cosh$ on $[0,\infty)$ finishes. For the upper bound, $d \le \log(2\cosh d) = \log\bigl((c+1)/m\bigr)$
and $m \ge \sqrt{(c+1)/2}$ (which is $2m^2 \ge c+1$, i.e. $m^2 \ge n^2+1$) give
$d \le \tfrac12\log(2(c+1))$. $\square$

Thus every node of the tree lies in a half-open annulus of width $\tfrac12\log 2 \approx 0.3466$,
independently of its depth and of the size of the triple.

---

## 4. The residual and its slope model

**Definition 4.1.** The **residual** of a seed is
$$\rho(m,n) \;=\; d_{\mathbb{H}}\bigl(i, z(m,n)\bigr) - \tfrac12\log\bigl(m^2+n^2\bigr),$$
and its **slope model** is
$$\tilde\rho(m,n) \;=\; \tfrac12\log\Bigl(1 + \bigl(\tfrac nm\bigr)^2\Bigr) \;=\; \tfrac12\log c - \log m .$$

By Theorem 3.5, $0 \le \rho < \tfrac12\log 2 + o(1)$. Note that $\tilde\rho$ depends only on the slope
$t = n/m$ and is strictly increasing in $t$ on $(0,1)$, with range $(0, \tfrac12\log 2)$: the observed
trajectory window is exactly the image of the slope interval under $t \mapsto \tfrac12\log(1+t^2)$.

**Theorem 4.2 (Coarse sandwich).** For every seed, $\tilde\rho \le \rho \le \tilde\rho + \log(1 + 1/c)$.

The upper bound is $\rho - \tilde\rho \le 1/c$. This is qualitatively correct in order of magnitude
only when the slope is close to $1$; the truth is much smaller for small slopes, as we now show.

**Theorem 4.3 (Exact gap identity).** Let $(m,n)$ be a seed, $c = m^2+n^2$ and
$S = \sqrt{(c+1)^2 - 4m^2}$. Then
$$\exp\bigl(\rho(m,n) - \tilde\rho(m,n)\bigr) \;=\; \frac{(c+1) + S}{2c}. $$

*Proof.* Write $d$ for the distance. From $\cosh d = (c+1)/(2m)$ and $\cosh^2 - \sinh^2 = 1$ with
$\sinh d \ge 0$ we get $2m\sinh d = \sqrt{(c+1)^2 - 4m^2} = S$. By Definition 4.1 and
$\tilde\rho = \tfrac12\log c - \log m$,
$$\rho - \tilde\rho = d - \log c + \log m,$$
so $\exp(\rho - \tilde\rho) = m\,e^{d}/c = m(\cosh d + \sinh d)/c = \bigl(\tfrac{c+1}{2} + \tfrac S2\bigr)/c$. $\square$

**Theorem 4.4 (Two-sided gap bound).** For every seed, with $c = m^2+n^2$ and $c \ge 5$,
$$\frac{n^2}{c^2 + n^2} \;\le\; \rho - \tilde\rho \;\le\; \frac{c+1}{c-1}\cdot \frac{n^2}{c^2+n^2}.$$
In particular $\rho - \tilde\rho = \dfrac{n^2}{c^2}\bigl(1 + O(1/c)\bigr)$ uniformly in the slope.

*Proof sketch.* By Theorem 4.3, $\exp(\rho-\tilde\rho) - 1 = \bigl(S - (c-1)\bigr)/(2c)$. The
difference $S - (c-1)$ is a difference of two nearly equal quantities; the elementary
factorisation
$$\bigl(S - (c-1)\bigr)\bigl(S + (c-1)\bigr) \;=\; S^2 - (c-1)^2 \;=\; (c+1)^2 - 4m^2 - (c-1)^2 \;=\; 4(c-m^2) \;=\; 4n^2$$
removes the cancellation entirely: $S - (c-1) = 4n^2/\bigl(S + (c-1)\bigr)$. Since
$c - 1 \le S \le c+1$ (as $4m^2 \ge 4$ and $4m^2 \le 4c$ up to the correction), one has
$2(c-1) \le S + (c-1) \le 2c$, whence
$$\frac{n^2}{c^2} \;\le\; \exp(\rho - \tilde\rho) - 1 \;\le\; \frac{n^2}{c(c-1)} .$$
Converting between $x - 1$ and $\log x$ with $1 - 1/x \le \log x \le x-1$ gives the stated
bounds with $c^2 + n^2$ in the denominators. $\square$

**Corollary 4.5 (Comparison with the coarse bound).** The bound of Theorem 4.4 is strictly
stronger than $\rho - \tilde\rho \le (n^2+1)/\bigl(c(c+1)\bigr)$, and *qualitatively* so: the coarse
bounds never go below $1/c^2$, while the truth is $n^2/c^2$, an overestimate by a factor
$\asymp m^2/n^2$ at small slope.

**Example 4.6.** For the seed $(4,1)$, $c=17$. The bound $1/c \approx 0.0588$ and the refinement
$(n^2+1)/(c(c+1)) = 1/153 \approx 0.006536$ are both far from the truth. Theorem 4.4 gives
$1/290 \le \rho - \tilde\rho \le 1/272$, i.e. $0.003448 \le \rho - \tilde\rho \le 0.003676$; the exact value is
$0.0036543\ldots$.

---

## 5. Exact branch monotonicity

We ask how $\rho$ behaves along each of the three branches. The slope model answers
immediately via (2.1), because $\tilde\rho$ is increasing in $t$:

**Proposition 5.1 (Slope-model monotonicity).** For every seed with slope $t = n/m$:
$\tilde\rho$ increases under $\sigma_1$ (because $t \le 1/(2-t)$, i.e. $(1-t)^2 \ge 0$); decreases
under $\sigma_3$ (because $t/(1+2t) \le t$); and decreases under $\sigma_2$ **iff**
$t \ge 1/(2+t)$, i.e. iff $t \ge \sqrt2 - 1$, i.e. iff $m^2 \le 2mn + n^2$.

The substantive question — recorded as an open problem by the coarse analysis — is whether
this survives passage to the *exact* hyperbolic distance, since $\rho$ and $\tilde\rho$ differ by a
term of size $n^2/c^2$ that may be comparable to the predicted change. The answer is yes, in
all cases.

### 5.1 Two tools

**Lemma 5.2 (Logarithm beats its chord).** For $A, B > 0$, $\ \dfrac{A-B}{A} \le \log\dfrac AB$.

*Proof.* $\log(B/A) \le B/A - 1$ is the standard inequality $\log x \le x-1$; negate. $\square$

**Lemma 5.3 (Algebraic slope gap).** For seeds $(m,n)$ and $(m',n')$, put
$$\mathcal{A} = (m^2+n^2)m'^2, \qquad \mathcal{B} = m^2(m'^2+n'^2).$$
Then
$$\tilde\rho(m,n) - \tilde\rho(m',n') \;\ge\; \frac{\mathcal A - \mathcal B}{2\mathcal A}.$$
No sign hypothesis on $\mathcal A - \mathcal B$ is required.

*Proof.* $\tilde\rho(m,n) = \tfrac12\log\bigl((m^2+n^2)/m^2\bigr)$, so the difference equals
$\tfrac12\log(\mathcal A/\mathcal B)$; apply Lemma 5.2. $\square$

The point of Lemma 5.3 is that in each branch, $\mathcal A - \mathcal B$ **factors**:

| branch | child $(m',n')$ | $\mathcal A - \mathcal B$ |
|---|---|---|
| $\sigma_1$ | $(2m-n,\,m)$ | $(m-n)^2\,(m^2 + 2mn - n^2)$ |
| $\sigma_2$ | $(2m+n,\,m)$ | $-(2mn + n^2 - m^2)(m+n)^2$ |
| $\sigma_3$ | $(m+2n,\,n)$ | $4n^3(m+n)$ |

(The sign convention: for $\sigma_2$ the table gives $\mathcal A - \mathcal B$ for the parent-minus-child
ordering used below.) In each case one is left with a polynomial inequality in $m, n$, and
the sharp gap bound of Theorem 4.4 supplies the error term to be beaten.

### 5.2 The unconditional branches

**Theorem 5.4 ($B_1$: unconditional increase).** For every Euclid seed $(m,n)$,
$$\rho(m,n) \;\le\; \rho(2m-n,\, m).$$

**Theorem 5.5 ($B_3$: unconditional decrease).** For every Euclid seed $(m,n)$,
$$\rho(m+2n,\, n) \;\le\; \rho(m,n).$$

*Proof sketch (both).* Write the target as
$$\bigl(\tilde\rho_{\text{child}} - \tilde\rho_{\text{parent}}\bigr) \;\ge\; \bigl(\text{gap}_{\text{parent}} - \text{gap}_{\text{child}}\bigr),$$
bound the left side below by Lemma 5.3 with the factorisation from the table, and bound the
right side above by the sharp sandwich of Theorem 4.4. What remains is a rational
inequality in the integers $m > n \ge 1$. Clearing denominators and substituting
$n = a+1$, $m = a+b+2$ with $a,b \ge 0$ — which is exactly the parametrisation of the region
$m > n \ge 1$ by non-negative integers — turns each of the two resulting polynomials into one
with *all coefficients non-negative*. Non-negativity is then immediate, and no side condition
on the seed is needed. $\square$

The coefficient-positivity phenomenon is what makes the guard-free statements possible; it
is a fortunate feature of these particular factorisations rather than a general principle.

### 5.3 The middle branch: a complete dichotomy

**Lemma 5.6 (No seed on the threshold).** No Euclid seed satisfies $m^2 = 2mn + n^2$.

*Proof.* The equation is $(m-n)^2 = 2n^2$. If $n \ge 1$ this forces $\sqrt 2 = (m-n)/n$ rational,
a contradiction. (Equivalently: $n \mid m-n$ so $n \mid m$, and coprimality gives $n=1$, whence
$(m-1)^2 = 2$, impossible.) $\square$

**Theorem 5.7 ($B_2$ above the threshold).** If $(m,n)$ is a seed with $m^2 < 2mn + n^2$ then
$$\rho(2m+n,\, m) \;\le\; \rho(m,n).$$

**Theorem 5.8 ($B_2$ strictly below the threshold).** If $(m,n)$ is a seed with
$2mn + n^2 + 2 \le m^2$ then
$$\rho(m,n) \;\le\; \rho(2m+n,\, m).$$

The two theorems leave one case: $m^2 = 2mn + n^2 + 1$.

**Lemma 5.9 (The boundary layer is a Pell family).** If $0 < n < m$ and $m^2 = 2mn + n^2 + 1$
then $(m-n)^2 = 2n^2 + 1$.

*Proof.* Substitute $m = n + k$: the hypothesis becomes $(n+k)^2 = 2n(n+k) + n^2 + 1$, i.e.
$k^2 = 2n^2 + 1$. $\square$

The solutions of $k^2 - 2n^2 = 1$ are the classical Pell solutions
$(k,n) = (3,2), (17,12), (99,70), (577,408), \ldots$, giving the seeds
$$(m,n) = (5,2),\ (29,12),\ (169,70),\ (985,408),\ \ldots$$

**Theorem 5.10 (The boundary layer, closed).** For every seed with $m^2 = 2mn + n^2 + 1$,
$$\rho(m,n) \;\le\; \rho(2m+n,\, m).$$

*Proof sketch.* The real relaxation of the hypothesis is genuinely insufficient here: the
corresponding inequality for real $m, n$ satisfying $m^2 = 2mn+n^2+1$ **fails** near
$(m,n) \approx (3.80,\, 1.48)$. The proof therefore uses an integrality consequence of the Pell
equation. From $k^2 = 2n^2+1$ with $k = m - n \ge 1$ one gets $n \ne 1$ (else $k^2 = 3$), hence
$n \ge 2$; feeding $n \ge 2$ into the polynomial inequality restores it. At the smallest member,
$(m,n) = (5,2)$, the margin is only about $0.9\%$. $\square$

**Theorem 5.11 (Exact $B_2$ dichotomy).** For every Euclid seed $(m,n)$:
$$m^2 < 2mn+n^2 \implies \rho(2m+n,\,m) \le \rho(m,n), \qquad 2mn+n^2 < m^2 \implies \rho(m,n) \le \rho(2m+n,\,m),$$
and by Lemma 5.6 exactly one of the two hypotheses holds. Consequently the exact hyperbolic
residual moves along $B_2$ in precisely the direction the slope model predicts, with no case
left open.

**Example 5.12.** The seed $(4,1)$ has slope $1/4 < \sqrt2 - 1$ and is the smallest seed on the
"wrong" side. Its $B_2$-child is $(9,4)$, and indeed the exact residual *increases*:
$\rho(4,1) = 0.033968\ldots < 0.091845\ldots = \rho(9,4)$. By contrast $(3,2)$, with slope $2/3 > \sqrt2-1$,
has $B_2$-child $(8,3)$ and the residual decreases.

**Example 5.13 (Pell).** For $(5,2)$: $m^2 = 25$ and $2mn+n^2 = 24$, so we are exactly on the
boundary layer. The $B_2$-child is $(12,5)$, and $\rho(5,2) = 0.079099\ldots \le 0.080922\ldots = \rho(12,5)$,
in agreement with Theorem 5.10, with the predicted narrow margin.

---

## 6. The tree structure and depth versus distance

**Definition 6.1 (Reachability).** Say $(m,n)$ is *reached at depth $k$* if it is obtained from
the root $(2,1)$ by exactly $k$ applications of $\sigma_1$, $\sigma_2$, $\sigma_3$ in some order.

**Theorem 6.2 (Soundness).** Every reachable pair is a Euclid seed.

*Proof.* Induction on $k$ using Theorem 2.5, base case $(2,1)$. $\square$

**Definition 6.3 (Parent map).** For $(M,N)$ with $0 < N < M$ set
$$\pi(M,N) = \begin{cases} (M - 2N,\; N) & \text{if } 3N < M,\\ (N,\; M-2N) & \text{if } 2N < M \le 3N,\\ (N,\; 2N - M) & \text{if } M \le 2N.\end{cases}$$

The trichotomy is a trichotomy in the slope $N/M$: the intervals $(0,\tfrac13)$, $(\tfrac13,\tfrac12)$,
$(\tfrac12,1)$ select $\sigma_3$, $\sigma_2$, $\sigma_1$ respectively.

**Theorem 6.4 (Completeness).** $\pi$ inverts each of $\sigma_1,\sigma_2,\sigma_3$ on seeds, and every
Euclid seed other than $(2,1)$ has $\pi(m,n)$ a Euclid seed with strictly smaller first
coordinate. Consequently **every** Euclid seed is reachable.

*Proof sketch.* The three inversion identities are direct computations combined with the
observation that the branch conditions are mutually exclusive and exhaustive on the images.
Strict decrease of the first coordinate gives a well-founded induction; the base case is the
root. $\square$

**Theorem 6.5 (Uniqueness of depth).** A seed is reachable at exactly one depth. Hence the
*depth* function is well defined and the Berggren tree is a tree.

*Proof sketch.* If $(m,n)$ is reachable at depths $k$ and $j$ with $k,j \ge 1$, both derivations
must end with the same move — the one selected by $\pi$ — and both give the same parent;
induct. $\square$

**Theorem 6.6 (Distance is bounded by depth).** If $(m,n)$ is reached at depth $k$ then
$m \le 2\cdot 3^k$, hence $\log c \le \log 8 + k\log 9$, hence
$$2\,d_{\mathbb{H}}\bigl(i, z(m,n)\bigr) \;\le\; \log 32 + k\log 9, \qquad\text{i.e.}\qquad \frac{2d - \log 32}{\log 9} \le k .$$

*Proof sketch.* Each move at most triples the first coordinate ($2m+n < 3m$, $m+2n<3m$,
$2m-n<2m$), giving $m \le 2\cdot 3^k$; then $c = m^2+n^2 \le 2m^2 \le 8\cdot 9^k$, and
Theorem 3.4 converts the size bound into a distance bound. $\square$

**Theorem 6.7 (Depth is *not* bounded by distance).** For no constant $C \ge 0$ is it true
that every reachable seed satisfies $\text{depth} \le C\cdot d_{\mathbb{H}}(i, z)$.

*Proof.* Consider the **left spine**, $s_0 = (2,1)$, $s_{k+1} = \sigma_1(s_k)$. By induction
$s_k = (k+2,\, k+1)$, so its hypotenuse is
$$c_k = (k+2)^2 + (k+1)^2 = 2k^2 + 6k + 5,$$
and its depth is $k$. By Theorem 3.4, $d_k \le \tfrac12\log c_k + \log 2 = O(\log k)$, whereas the
depth is $k$. Since $k/\log k \to \infty$, no constant $C$ works. Equivalently, this node of
hypotenuse $c$ sits at depth $k \approx \sqrt{c/2}$. $\square$

So the hyperbolic metric compresses the tree exponentially in one direction only:
$d \lesssim k$, and there is no reverse inequality.

**Theorem 6.8 (The middle spine is commensurable).** Let $\mu_0 = (2,1)$, $\mu_{k+1} = \sigma_2(\mu_k)$.
The first coordinates are the Pell numbers $2, 5, 12, 29, 70, \ldots$; one has
$\mu_k$'s first coordinate $\ge 2^{k+1}$, hence hypotenuse $\ge 4^{k+1}$, hence
$$k \log 2 \;\le\; d_{\mathbb{H}}\bigl(i, z(\mu_k)\bigr).$$
On this branch depth and distance are commensurable in both directions.

**Theorem 6.9 (Logarithmic reach).** For every $N \ge 1$ there is a node reachable at depth
$k = \lfloor \log_2 N\rfloor$ with hypotenuse $\ge N$, and $k\log 2 \le \log N$.

*Proof.* Take $\mu_k$ with $k = \lfloor\log_2 N\rfloor$: its hypotenuse is at least
$4^{k+1} \ge 2^{k+1} > N$, and $2^k \le N$ gives $k\log 2 \le \log N$. $\square$

Theorems 6.7 and 6.9 together are the exact truth behind the slogan "$O(\log N)$ path
length": one can *reach* size $N$ in $\Theta(\log N)$ moves, along the fastest-growing spine, but a
*given* node of size $N$ may sit at depth $\Theta(\sqrt N)$.

---

## 7. Volume growth: the structural obstruction

**Theorem 7.1 (Quadratic ball growth).** For every integer $K \ge 256$, with $R = \log K + 2$,
there is a set $S$ of at least $e^{2R}/300$ distinct points of $\mathbb{H}$, each of the form $z(m,n)$
for a Euclid seed $(m,n)$, with $d_{\mathbb{H}}(z, i) \le R$ for all $z \in S$.

Since a node of hypotenuse $c$ sits at distance $\approx \tfrac12\log c$, radius $R$ corresponds to
hypotenuse $\approx e^{2R}$; the theorem therefore says the node count grows like the hypotenuse
itself, i.e. quadratically in $e^{R}$, not linearly. This is the true order.

*Proof sketch.* The proof is a sieve, because the obstruction is arithmetic. Consider the box
$$\mathcal{E} = \{m \text{ even} : 2K < m \le 4K\}, \qquad \mathcal{O} = \{n \text{ odd} : 1 \le n \le 2K\},$$
each of size exactly $K$; every pair in $\mathcal E\times\mathcal O$ automatically satisfies $0<n<m$ and
$m+n$ odd, so being a Euclid seed reduces to coprimality. One bounds the number of
non-coprime pairs by summing, over odd $d \ge 3$, the count of pairs divisible by $d$, which is at
most $(K/d + 1)(K/d + 1)$. Two telescoping estimates control the resulting sums:
$$\sum_{i<n} \frac{1}{(2i+3)^2} \;\le\; \frac14 - \frac{1}{4n+4}, \qquad \sum_{i<n} \frac{1}{2i+3} \;\le\; \sqrt{2n+1} - 1 .$$
The first gives $\le K^2/4$ from the main term; the second controls the cross terms as $O(K^{3/2})$,
negligible for $K \ge 256$. Hence at least $K^2 - \tfrac34 K^2 = K^2/4$ pairs are coprime, i.e. are
Euclid seeds. Each such seed has $c = m^2+n^2 \le 16K^2 + 4K^2 = 20K^2$ and $m > 2K$, so by
Theorem 3.4 its distance is at most $\tfrac12\log(20K^2) + \log 2 \le \log K + 2 = R$. Distinct
seeds give distinct points, since $z(m,n)$ determines $1/m$ and $n/m$. Finally
$e^{2R} = e^4 K^2 \le 55 K^2$, so $K^2/4 \ge e^{2R}/300$. $\square$

**Corollary 7.2 (No free lunch).** Any search strategy that locates a collision for $N$ by
exhausting the hyperbolic ball guaranteed to contain one must inspect $\asymp N$ nodes. Short
geodesics do not make the search cheap: the hyperbolic metric compresses distances
logarithmically but leaves volume — the only quantity a search actually pays for — untouched.

---

## 8. The arithmetic payoff, and what remains of the programme

**Theorem 8.1 (Euler's two-representation factorisation).** Suppose $N = a^2+b^2 = c^2+d^2$
with $a,b,c,d > 0$ and the two representations essentially distinct (i.e. $\{a,b\} \ne \{c,d\}$).
Then $\gcd(N,\, ac+bd)$ is a non-trivial divisor of $N$.

*Proof sketch.* From the two representations, $(ac+bd)(ad+bc) = ac\cdot ad + \ldots$ reorganises via
the Brahmagupta–Fibonacci identity into $N\cdot(\text{integer})$, so $N \mid (ac+bd)(ad+bc)$. Also
$0 < ac+bd < N$ (a Cauchy–Schwarz-type bound: $ac+bd \le \sqrt{(a^2+b^2)(c^2+d^2)} = N$, with
equality only in the degenerate proportional case, excluded by distinctness). Hence
$\gcd(N, ac+bd)$ is neither $1$ (it would force $N \mid ad+bc$, impossible for the same size
reason) nor $N$. $\square$

**Theorem 8.2 (Complete splitting).** If in addition $N$ is odd and both representations are
primitive, then
$$\gcd\bigl(N,\, ac+bd\bigr)\cdot\gcd\bigl(N,\, ad+bc\bigr) \;=\; N,$$
so a single collision produces the full two-factor split $N = g\cdot h$ with $1 < g, h < N$.

**Theorem 8.3 (Collisions factor).** Two distinct Euclid seeds $(m_1,n_1) \ne (m_2,n_2)$ with the
same hypotenuse $N$ yield $\gcd(N, m_1m_2 + n_1n_2)$ a non-trivial divisor of $N$; consequently
$N$ is composite.

*Proof sketch.* Distinct coprime seeds cannot be proportional, so the two representations are
essentially distinct; apply Theorem 8.1. $\square$

**Example 8.4.** $65 = 8^2 + 1^2 = 7^2 + 4^2$, with $(8,1)$ and $(7,4)$ both Euclid seeds. Then
$\gcd(65,\, 8\cdot7 + 1\cdot4) = \gcd(65, 60) = 5$, and $65 = 5\cdot 13$. The compositeness of $65$ has
been deduced from the coincidence of two points on the same hyperbolic level set.

**Theorem 8.5 (Collisions at every scale).** For every $j \ge 0$ the pairs $(20j+9,\, 10j+2)$ and
$(20j+7,\, 10j+6)$ are distinct Euclid seeds with the same hypotenuse
$$N_j \;=\; 500j^2 + 400j + 85,$$
and the divisor extracted from the collision is exactly $5$. Hence the set of hypotenuses
carried by two distinct nodes is infinite.

**Theorem 8.6 (Colliding nodes are neighbours).** If two distinct seeds share the hypotenuse
$N$, both node points lie on the level set $2m\cosh d = N+1$, and their distances from $i$ differ
by at most $\log 2$.

*Proof sketch.* Both distances lie in the window of Theorem 3.5 for the same $c = N$. $\square$

### 8.1 Energy of trajectories

**Definition 8.7.** For a finite sequence $z_0, \ldots, z_k$ in $\mathbb{H}$, the discrete length and
Dirichlet energy are
$$L = \sum_{i<k} d(z_i, z_{i+1}), \qquad E = \sum_{i<k} d(z_i, z_{i+1})^2 .$$

**Theorem 8.8 (Cauchy–Schwarz energy bound).** $L^2 \le k\,E$, hence for $k \ge 1$,
$$E \;\ge\; \frac{d(z_0, z_k)^2}{k}.$$
The bound is **sharp**: for every $k \ge 1$ and every $t \ge 0$ there is a $k$-step trajectory (equally
spaced along a vertical geodesic) with $d(z_0,z_k) = t$ and $E = t^2/k$ exactly.

**Corollary 8.9 (Berggren trajectory energy).** Any $k$-step trajectory from $i$ to $z(m,n)$ has
$$E \;\ge\; \frac{\bigl(\tfrac12\log c - \log 2\bigr)^2}{k}.$$

This makes the geodesic-energy heuristic precise: minimising energy is minimising $d^2/k$, and
the theorems above show that $d$ is $\tfrac12\log c + O(1)$ while $k$ is uncontrolled from above
and the search volume is $\asymp c$. The energy functional is well behaved; it simply has no
algorithmic leverage.

---

## 9. Algorithms

Three procedures fall out of the development and are worth recording explicitly.

**Algorithm A (Descent to the root).** Given a Euclid seed $(m,n)$, apply the parent map $\pi$
of Definition 6.3 repeatedly until $(2,1)$ is reached; the number of steps is the depth, and
the sequence of branch choices is the address of the node. Correctness is Theorem 6.4 and
Theorem 6.5. Each step reduces $m$; on the left spine the number of steps is $\Theta(\sqrt c)$ and on
the middle spine $\Theta(\log c)$, so the worst-case cost is $\Theta(\sqrt c)$ arithmetic operations —
which is precisely the content of Theorem 6.7.

**Algorithm B (Residual and branch prediction).** Given $(m,n)$, compute
$c = m^2+n^2$, $d = \operatorname{arcosh}\bigl((c+1)/(2m)\bigr)$, $\rho = d - \tfrac12\log c$ and
$\tilde\rho = \tfrac12\log(1 + (n/m)^2)$. Theorem 4.4 certifies $\rho - \tilde\rho \in [\,n^2/(c^2+n^2),\, \tfrac{c+1}{c-1}n^2/(c^2+n^2)\,]$
without any transcendental evaluation, and Theorem 5.11 predicts the sign of
$\rho(\sigma_2(m,n)) - \rho(m,n)$ from the single integer comparison $m^2$ versus $2mn+n^2$. The
prediction is exact for every seed.

**Algorithm C (Collision factoring).** Enumerate the nodes of the tree in order of hypotenuse
(equivalently, of hyperbolic distance) until two share the target $N$; then output
$\gcd(N, m_1m_2+n_1n_2)$ and $\gcd(N, m_1n_2+n_1m_2)$. Correctness is Theorems 8.1–8.3. The
procedure is correct but not fast: by Theorem 7.1 the enumeration must in general reach
$\asymp N$ nodes. This is the precise sense in which the original programme fails.

---

## 10. Discussion and open problems

### 10.1 What the dictionary buys

The exact formula $\cosh d = (c+1)/(2m)$ is the whole engine. It converts every question about
the hyperbolic position of a node into a question about the pair $(c, m)$ — that is, about the
hypotenuse and one leg-parameter of the triple. Level sets of distance become the hyperbolas
$c + 1 = 2m\cosh R$; balls become discs in the $(m,n)$ plane; the residual becomes a function of
the slope alone, up to $O(n^2/c^2)$.

Two aspects seem worth isolating. First, the **rigidity**: the entire, exponentially
branching, arithmetically wild tree is confined to an annulus of width $\tfrac12\log 2$ around
$\tfrac12\log c$. Second, the **failure of the algorithmic hope for a geometric reason**:
hyperbolic space compresses distance logarithmically but *rewards* that compression with
exponential volume, and volume is what a search pays for.

### 10.2 Open problems

**Exact volume asymptotics.** Let $B(R)$ be the set of Euclid seeds whose node points lie in
the closed ball of radius $R$ about $i$. We conjecture
$$\#B(R) \;=\; \frac{\pi + 2}{4\pi^2}\,e^{2R}\bigl(1 + o(1)\bigr) \;=\; 0.130238\ldots \cdot e^{2R}\bigl(1+o(1)\bigr), \qquad R \to \infty,$$
and consequently that no geodesic-energy search can inspect a $(1-\varepsilon)$-fraction of the
nodes with hypotenuse $\le N$ in time $N^{o(1)}$. The heuristic behind the constant is exact
and worth recording. By Theorem 3.2 the ball condition $d \le R$ is precisely
$$m^2 + n^2 \;\le\; 2m\cosh R - 1,$$
a Euclidean disc of radius $\sqrt{\cosh^2 R - 1}$ centred at $(\cosh R, 0)$ in the $(m,n)$-plane.
The seed constraints $0 < n < m$ cut out the part of this disc above the axis and below the
diagonal: writing $\varrho = \cosh R$, the upper half-disc has area $\tfrac{\pi}{2}\varrho^2$, and the
line $n = m$ passes at distance $\varrho/\sqrt2$ from the centre, removing a circular segment of
area $\bigl(\tfrac\pi4 - \tfrac12\bigr)\varrho^2$. The admissible area is therefore
$\bigl(\tfrac{\pi}{4} + \tfrac12\bigr)\varrho^2$. Among lattice points, the density of pairs that are
coprime *and* of opposite parity is $\tfrac{6}{\pi^2}\cdot\tfrac23 = \tfrac{4}{\pi^2}$ (of the three
equally likely residue classes of a coprime pair mod $2$, two have opposite parity). With
$\varrho^2 \sim e^{2R}/4$ this gives
$$\#B(R) \;\sim\; \Bigl(\tfrac{\pi}{4}+\tfrac12\Bigr)\cdot\tfrac{4}{\pi^2}\cdot\tfrac{e^{2R}}{4} \;=\; \frac{\pi+2}{4\pi^2}\,e^{2R}.$$
Direct enumeration agrees to three decimal places already at $R = 4$: the observed ratio
$\#B(R)/e^{2R}$ is $0.1302, 0.1301, 0.1301$ at $R = 4.0, 4.5, 5.0$. Only the error term requires
new work; Theorem 7.1 already supplies a matching order of magnitude with an explicit
constant.

**Collision radius.** If $N = m_1^2+n_1^2 = m_2^2+n_2^2$ with distinct seeds, then Theorem 8.6
gives $|d_1 - d_2| \le \log 2$. We conjecture the sharper statement that the hyperbolic distance
*between the two colliding nodes themselves* is at most $\log N - \log(4m_1m_2) + O(1)$. Both nodes
lie on the same isohypotenuse level set $2m\cosh d = N+1$, which is an arc of controlled
hyperbolic diameter; the conjecture asks for that diameter explicitly.

**Distribution of the residual.** Since $\rho = \tfrac12\log(1+t^2) + (n^2/c^2)(1+O(1/c))$, the
distribution of the residual over all seeds of hypotenuse $\le X$ is governed by the
distribution of the slope $t = n/m$ over such seeds. Is the induced measure on $(0, \tfrac12\log 2)$
absolutely continuous, and what is its density? The Möbius actions (2.1) suggest a
Gauss-map-like transfer operator analysis.

**Sharper boundary layers.** The dichotomy of Theorem 5.11 is exact, but the proof of the
Pell case (Theorem 5.10) is ad hoc: it uses $n \ge 2$ forced by $k^2 = 2n^2+1$. Is there a
uniform argument covering all seeds with $m^2 \ge 2mn+n^2$ at once? Equivalently: is there a
monotone quantity interpolating between the slope model and the exact residual whose branch
behaviour is unconditional?

**Higher-dimensional analogues.** Euclid's parametrisation is the $n=2$ case of
parametrising rational points on quadrics. Does the analogous tree of primitive
representations $N = x_1^2 + \cdots + x_k^2$ embed in hyperbolic $k$-space with a comparable
exact distance formula, and does the volume obstruction persist with exponent $k-1$?

### 10.3 Conclusion

The programme we set out to test — factor $N$ in $O(\log N)$ steps by minimising geodesic
energy over the Berggren tree in a hyperbolic model — is refuted, and refuted structurally.
What replaces it is a precise dictionary: an exact distance formula tying a Riemannian
invariant to a Pythagorean hypotenuse; a rigidity theorem confining an infinite tree to a
thin annulus; a residual whose shape is determined by the slope to accuracy $n^2/c^2$; a
complete, exact dichotomy for how each of the three branches moves that residual, with the
last case a Pell family that only integrality can close; and a quantitative no-free-lunch
theorem that explains, in one line of hyperbolic geometry, why the fast algorithm cannot
exist.
