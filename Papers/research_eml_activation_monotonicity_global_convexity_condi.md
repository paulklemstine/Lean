# Global Convexity and Sharp Monotonicity Domains for Generalized Exponential–Logarithmic Activations, and their Dequantization to Tropical Addition

**Author:** Aristotle
**Date:** 2026-08-05

---

## Abstract

We study the two-parameter family of *generalized exponential–logarithmic* (EML) activation functions
$$E_{a,b}(x) = a x + \log\!\left(1 + e^{bx}\right), \qquad (a,b) \in \mathbb{R}^2,$$
which contains the softplus ($a=0$, $b=1$), the leaky/residual softplus ($a>0$), and — after rescaling — all smoothed rectifiers. We determine the exact parameter domain on which these functions are strictly monotone and strictly convex. Writing $\sigma(t) = e^{t}/(1+e^{t})$ for the logistic function, we prove the closed forms $E_{a,b}'(x) = a + b\,\sigma(bx)$ and $E_{a,b}''(x) = b^{2}\sigma(bx)(1-\sigma(bx))$, from which we obtain: (i) **global strict convexity** of $E_{a,b}$ on all of $\mathbb{R}$ for *every* $a\in\mathbb{R}$ and *every* $b\neq 0$; and (ii) the **sharp monotonicity criterion**: for $b>0$, $E_{a,b}$ is strictly increasing on $\mathbb{R}$ if and only if $a \geq 0$, the necessity being established by evaluating the derivative limit at $-\infty$.

We then exhibit a bridge to idempotent algebra. The same exponential–logarithmic pairing defines the log-sum-exp operation $x \oplus_b y = b^{-1}\log(e^{bx}+e^{by})$, which we show is *exactly* — not asymptotically — commutative, associative, and right-distributive over ordinary addition, being the transport of $(\mathbb{R}_{>0}, +, \times)$ along the isomorphism $x \mapsto e^{bx}$. The unique failing tropical axiom, idempotency, fails by an exactly computable constant: $x \oplus_b x = x + (\log 2)/b$. We prove the sharp two-sided sandwich $\max(x,y) < x \oplus_b y \leq \max(x,y) + (\log 2)/b$ and deduce Maslov dequantization, $x \oplus_b y \to \max(x,y)$ as $b\to\infty$, together with its min-plus mirror image. Combining both halves yields a **bridge theorem**: the rescaled activation $S_b(x) = E_{0,b}(x)/b$ is strictly convex and strictly increasing for every $b>0$, strictly dominates the tropical expression $\max(x,0)$, approximates it *uniformly in $x$* with error at most $(\log 2)/b$, and converges to it as $b\to\infty$ — at which point both strictness properties are lost. Convex analysis of neural activations and tropical algebra are thus two ends of a single exponential–logarithmic deformation.

**Keywords:** softplus, logistic function, strict convexity, sharp monotonicity domain, log-sum-exp, Maslov dequantization, tropical semiring, max-plus algebra.

---

## 1. Introduction

### 1.1 Motivation

Two research communities have, independently, made central use of the same pair of elementary transcendental functions.

In machine learning, the *rectified linear unit* $x \mapsto \max(x,0)$ is the dominant nonlinearity of deep neural networks. Its non-differentiability at the origin motivates a smooth surrogate, the **softplus** $x \mapsto \log(1+e^{x})$, whose derivative is the logistic sigmoid. Practitioners routinely introduce a sharpness parameter $b$ and a linear leak $a$, obtaining the family
$$E_{a,b}(x) = ax + \log(1+e^{bx}),$$
and rely — largely on the basis of numerical experience — on the family being monotone and convex.

In idempotent analysis and tropical geometry, the **max-plus semiring** $(\mathbb{R}\cup\{-\infty\}, \max, +)$ replaces ordinary addition by maximum. Maslov's *dequantization* programme realizes this semiring as a limit of ordinary arithmetic, conjugated by exponentials: the family of operations
$$x \oplus_b y = \frac{1}{b}\log\left(e^{bx}+e^{by}\right)$$
degenerates to $\max$ as $b\to\infty$, with $1/b$ playing the role of a temperature or of Planck's constant.

The observation animating this paper is that these are literally the same expression: with $y=0$,
$$x \oplus_b 0 = \frac{1}{b}\log\left(1+e^{bx}\right) = \frac{E_{0,b}(x)}{b}.$$
The rescaled softplus is the log-sum-exp of $x$ against the tropical unit. What follows makes both the convex-analytic and the algebraic sides of this identity precise, and quantifies the passage between them.

### 1.2 Contributions

1. **Exact derivative formulas.** Closed forms for $E_{a,b}'$ and $E_{a,b}''$ in terms of the logistic function (Section 3).
2. **Global strict convexity.** $E_{a,b}$ is strictly convex on all of $\mathbb{R}$ for every $a$ and every $b\neq 0$; the leak parameter $a$ is irrelevant to convexity (Theorem 3.4, Theorem 3.5).
3. **Sharp monotonicity domain.** For $b>0$, strict monotonicity of $E_{a,b}$ on $\mathbb{R}$ holds *iff* $a\geq 0$ (Theorem 4.3). The necessity direction is proved by a limit argument at $-\infty$ and shows that $a<0$ destroys even weak monotonicity.
4. **Exact algebraic laws for log-sum-exp.** Commutativity, associativity, right-distributivity, and the exact idempotency defect $(\log 2)/b$ (Section 5).
5. **Sharp sandwich and dequantization.** $\max(x,y) < x\oplus_b y \leq \max(x,y)+(\log 2)/b$, with convergence to max-plus and min-plus tropical addition (Section 6).
6. **Bridge theorem.** A single statement combining strict convexity, strict monotonicity, strict domination, a uniform $O(1/b)$ error bound, and convergence (Section 7).

### 1.3 Notation

$\log$ and $\exp$ denote the natural logarithm and exponential on $\mathbb{R}$. We write $\sigma$ for the logistic function, $\mathbb{R}_{>0}$ for the positive reals, and $\max, \min$ for the binary lattice operations on $\mathbb{R}$. A function $f$ is *strictly convex on a convex set $C$* if $f(\lambda u + (1-\lambda)v) < \lambda f(u) + (1-\lambda) f(v)$ for all distinct $u,v \in C$ and $\lambda \in (0,1)$. "Strictly increasing" means $u<v \Rightarrow f(u)<f(v)$; "monotone" (without qualifier) means non-decreasing.

---

## 2. The logistic function

**Definition 2.1.** The *logistic function* is
$$\sigma : \mathbb{R} \to \mathbb{R}, \qquad \sigma(t) = \frac{e^{t}}{1+e^{t}}.$$

Since $e^{t}>0$ for all $t$, the denominator satisfies $1+e^{t} > 1 > 0$, so $\sigma$ is well defined and smooth.

**Lemma 2.2 (Range).** For all $t\in\mathbb{R}$: $0 < \sigma(t) < 1$, and $1 - \sigma(t) = \dfrac{1}{1+e^{t}}$.

*Proof.* Positivity is a quotient of positive numbers. For $\sigma(t)<1$, since $1+e^{t}>0$ the inequality is equivalent to $e^{t} < 1 + e^{t}$, which is $0<1$. Finally, multiplying $1-\sigma(t)$ by the nonzero quantity $1+e^{t}$ gives $(1+e^{t}) - e^{t} = 1$, whence the stated identity. $\square$

**Lemma 2.3 (Crude exponential bound).** For all $t$, $\sigma(t) < e^{t}$.

*Proof.* Multiplying by $1+e^{t} > 0$ reduces the claim to $e^{t} < e^{t}(1+e^{t}) = e^{t} + e^{2t}$, i.e. to $0 < e^{2t}$. $\square$

**Lemma 2.4 (Left decay).** $\displaystyle\lim_{t\to-\infty}\sigma(t) = 0$.

*Proof.* $e^{t}\to 0$ as $t\to -\infty$, so $1+e^{t}\to 1 \neq 0$, and the quotient tends to $0/1 = 0$. (Alternatively, squeeze between $0$ and $e^{t}$ using Lemma 2.3.) $\square$

**Lemma 2.5 (Logistic differential equation).** $\sigma$ is differentiable with
$$\sigma'(t) = \sigma(t)\bigl(1-\sigma(t)\bigr).$$

*Proof.* Apply the quotient rule to $e^{t}/(1+e^{t})$, whose denominator is nonvanishing:
$$\sigma'(t) = \frac{e^{t}(1+e^{t}) - e^{t}\cdot e^{t}}{(1+e^{t})^{2}} = \frac{e^{t}}{(1+e^{t})^{2}} = \frac{e^{t}}{1+e^{t}}\cdot\frac{1}{1+e^{t}} = \sigma(t)\bigl(1-\sigma(t)\bigr),$$
using Lemma 2.2 for the last factor. $\square$

---

## 3. The generalized EML activation: derivatives and convexity

**Definition 3.1.** For $a,b \in \mathbb{R}$ the *generalized EML activation* is
$$E_{a,b} : \mathbb{R}\to\mathbb{R}, \qquad E_{a,b}(x) = a x + \log\!\left(1 + e^{bx}\right).$$

The argument of the logarithm is $\geq 1 > 0$, so $E_{a,b}$ is well defined and smooth. Note the normalization $E_{a,b}(0) = \log 2$ for all $a,b$: every member of the family passes through the same point above the origin.

**Special cases.** $E_{0,1}$ is the softplus; $E_{a,1}$ with $a>0$ is a residual (leaky) softplus; $E_{0,b}/b$ is the *rescaled* softplus with sharpness $b$, which satisfies $E_{0,b}(x)/b \to \max(x,0)$ (Section 7).

**Proposition 3.2 (First derivative).** $E_{a,b}$ is differentiable everywhere with
$$E_{a,b}'(x) = a + b\,\sigma(bx).$$

*Proof.* The inner map $x\mapsto bx$ has derivative $b$; composing with $\exp$ and adding the constant $1$ gives that $x\mapsto 1+e^{bx}$ has derivative $b\,e^{bx}$. Since $1+e^{bx}>0$, the chain rule for $\log$ applies and
$$\frac{d}{dx}\log(1+e^{bx}) = \frac{b\,e^{bx}}{1+e^{bx}} = b\,\sigma(bx).$$
Adding the derivative $a$ of the linear term completes the proof. $\square$

**Proposition 3.3 (Second derivative).** $E_{a,b}$ is twice differentiable with
$$E_{a,b}''(x) = b^{2}\,\sigma(bx)\bigl(1-\sigma(bx)\bigr).$$

*Proof.* By Proposition 3.2, $E_{a,b}' = a + b\,(\sigma\circ m_b)$ where $m_b(x)=bx$. Differentiating with the chain rule and Lemma 2.5,
$$E_{a,b}''(x) = b\cdot \sigma'(bx)\cdot b = b^{2}\sigma(bx)(1-\sigma(bx)). \qquad\square$$

Two structural facts are immediate and worth isolating. First, **the leak parameter $a$ does not appear in the second derivative**: adding an affine function changes no curvature. Second, the second derivative depends on $b$ only through the even factor $b^{2}$ and the argument $bx$; in particular $E_{a,b}''$ and $E_{a,-b}''$ agree up to the reflection $x\mapsto -x$.

**Theorem 3.4 (Strictly positive curvature).** For every $a\in\mathbb{R}$, every $b\neq 0$ and every $x\in\mathbb{R}$,
$$E_{a,b}''(x) > 0.$$

*Proof.* By Lemma 2.2, $0<\sigma(bx)<1$, hence $\sigma(bx)\bigl(1-\sigma(bx)\bigr)>0$ as a product of two positive reals. Since $b\neq 0$ we have $b^{2}>0$, and the product of positive reals is positive. $\square$

**Theorem 3.5 (Global strict convexity).** For every $a\in\mathbb{R}$ and every $b\neq 0$, $E_{a,b}$ is strictly convex on all of $\mathbb{R}$.

*Proof.* $\mathbb{R}$ is convex; $E_{a,b}$ is continuous (indeed differentiable, Proposition 3.2) and twice differentiable on the interior $\mathbb{R}$ with $E_{a,b}''>0$ everywhere by Theorem 3.4. The standard second-derivative criterion for strict convexity on a convex set applies. $\square$

**Remark 3.6 (Sharpness of the hypothesis $b\neq 0$).** For $b=0$ we get $E_{a,0}(x) = ax + \log 2$, an affine function: convex but nowhere strictly convex. Thus $b\neq 0$ is not merely convenient but necessary, and the parameter domain of strict convexity is exactly $\{(a,b) : b\neq 0\}$ — a *full* half of the parameter plane in the sense that it is the complement of a line.

**Remark 3.7 (Curvature magnitude).** Since $\sigma(1-\sigma)$ attains its maximum $1/4$ at $\sigma = 1/2$, i.e. at $x=0$, we obtain the global bounds
$$0 < E_{a,b}''(x) \leq \frac{b^{2}}{4},$$
with equality at $x=0$. The activation is therefore $\tfrac{b^{2}}{4}$-smooth (its derivative is Lipschitz with that constant), a quantity that governs step-size choice in gradient descent. Curvature is concentrated near the origin and decays exponentially: $E_{a,b}''(x) \leq b^{2}e^{-b|x|}$ for $b>0$, since $\sigma(t)(1-\sigma(t)) \le \min(e^{t}, e^{-t})$.

---

## 4. The exact monotonicity domain

Fix $b>0$ throughout this section. Proposition 3.2 pins the derivative into a band:
$$a < E_{a,b}'(x) < a+b \qquad \text{for all } x,$$
because $0<\sigma(bx)<1$. Both endpoints are approached but never attained: $E_{a,b}'(x)\to a$ as $x\to-\infty$ and $\to a+b$ as $x\to+\infty$. Monotonicity is therefore decided at the left end.

**Theorem 4.1 (Sufficiency).** If $a \geq 0$ and $b>0$, then $E_{a,b}$ is strictly increasing on $\mathbb{R}$.

*Proof.* By Proposition 3.2 and Lemma 2.2, for every $x$,
$$E_{a,b}'(x) = a + b\,\sigma(bx) > a \geq 0,$$
since $b>0$ and $\sigma(bx)>0$. A differentiable function with everywhere strictly positive derivative on an interval is strictly increasing there. $\square$

**Theorem 4.2 (Necessity).** If $a<0$ and $b>0$, then $E_{a,b}$ is not monotone (not even non-decreasing).

*Proof.* Suppose, for contradiction, that $E_{a,b}$ is non-decreasing. A differentiable non-decreasing function has non-negative derivative everywhere, so
$$a + b\,\sigma(bx) \geq 0 \qquad \text{for all } x \in \mathbb{R}. \tag{4.1}$$
Now let $x\to -\infty$. Since $b>0$, $bx \to -\infty$, and by Lemma 2.4, $\sigma(bx)\to 0$; hence the left-hand side of (4.1) tends to $a$. A limit of a family of non-negative reals is non-negative, so $a \geq 0$, contradicting $a<0$. $\square$

**Theorem 4.3 (Exact parameter domain for monotonicity).** Let $b>0$. Then
$$E_{a,b} \text{ is strictly increasing on } \mathbb{R} \iff a \geq 0.$$

*Proof.* ($\Leftarrow$) is Theorem 4.1. ($\Rightarrow$): if $a<0$, then $E_{a,b}$ is not non-decreasing by Theorem 4.2, hence a fortiori not strictly increasing. $\square$

**Remark 4.4 (Geometry of the failure).** For $a<0$ the equation $E_{a,b}'(x)=0$ reads $\sigma(bx) = -a/b$, which has a (unique) solution precisely when $0 < -a/b < 1$, i.e. when $-b < a < 0$; the solution is
$$x^{\ast} = \frac{1}{b}\log\!\frac{-a}{a+b},$$
the unique global minimum of $E_{a,b}$. For $a \leq -b$ the derivative is negative everywhere and $E_{a,b}$ is strictly *decreasing*. Thus the parameter plane splits, for $b>0$, into three regimes: strictly increasing ($a\geq 0$), unimodal with an interior minimum ($-b<a<0$), and strictly decreasing ($a\leq -b$).

**Remark 4.5 (Combined classification).** For $b>0$, the region of the $(a,b)$-plane on which $E_{a,b}$ is simultaneously strictly convex and strictly increasing on all of $\mathbb{R}$ is exactly the closed quadrant $\{a\geq 0, b>0\}$; convexity imposes no constraint beyond $b \neq 0$, and monotonicity imposes exactly $a\geq 0$. By the reflection $E_{a,b}(x) = E_{a+b,-b}(x)$ — which follows from $\log(1+e^{t}) = t + \log(1+e^{-t})$ — the case $b<0$ reduces to the case $b>0$, and there $E_{a,b}$ is strictly increasing iff $a + b \geq 0$.

---

## 5. Log-sum-exp: exact algebra

**Definition 5.1.** For $b\neq 0$, the *log-sum-exp* (or *soft maximum*) operation is
$$\oplus_b : \mathbb{R}\times\mathbb{R}\to\mathbb{R}, \qquad x \oplus_b y = \frac{1}{b}\log\!\left(e^{bx}+e^{by}\right).$$
The argument of the logarithm is a sum of two positive reals, hence positive, so $\oplus_b$ is well defined.

**Lemma 5.2 (Transport principle).** Let $\varphi_b(x) = e^{bx}$. For $b\neq 0$, $\varphi_b$ is a bijection $\mathbb{R}\to\mathbb{R}_{>0}$, and for all $x,y$:
$$\varphi_b(x\oplus_b y) = \varphi_b(x) + \varphi_b(y), \qquad \varphi_b(x+y) = \varphi_b(x)\,\varphi_b(y).$$

*Proof.* The second identity is $e^{b(x+y)} = e^{bx}e^{by}$. For the first, $b\cdot(x\oplus_b y) = \log(e^{bx}+e^{by})$ since $b\neq 0$ cancels, and exponentiating a logarithm of a positive number returns that number. Bijectivity of $\varphi_b$ onto $\mathbb{R}_{>0}$ is standard for $b\neq 0$; injectivity of $\exp$ combined with cancellation of $b$ is all we shall use. $\square$

Lemma 5.2 says that $\varphi_b$ is an isomorphism from the structure $(\mathbb{R}, \oplus_b, +)$ onto $(\mathbb{R}_{>0}, +, \times)$. Every identity of positive arithmetic that involves only $+$ and $\times$ therefore transports *exactly*.

**Theorem 5.3 (Commutativity).** For all $b$ and all $x,y$: $x\oplus_b y = y \oplus_b x$.

*Proof.* Immediate from commutativity of $+$ inside the logarithm. $\square$

**Theorem 5.4 (Exact associativity).** For $b\neq 0$ and all $x,y,z$:
$$(x\oplus_b y)\oplus_b z = x \oplus_b (y\oplus_b z).$$

*Proof.* Apply $\varphi_b$. By Lemma 5.2 used twice on each side,
$$\varphi_b\bigl((x\oplus_b y)\oplus_b z\bigr) = \varphi_b(x\oplus_b y) + \varphi_b(z) = e^{bx}+e^{by}+e^{bz},$$
and symmetrically for the right-hand side. Since $\exp$ is injective and $b\neq 0$ may be cancelled, the two arguments coincide. $\square$

**Theorem 5.5 (Distributivity of $+$ over $\oplus_b$).** For $b\neq 0$ and all $x,y,z$:
$$(x+z)\oplus_b (y+z) = (x\oplus_b y) + z.$$

*Proof.* Inside the logarithm, $e^{b(x+z)}+e^{b(y+z)} = e^{bz}\bigl(e^{bx}+e^{by}\bigr)$. Taking $\log$ of a product of positive factors splits it as $bz + \log(e^{bx}+e^{by})$, and dividing by $b$ gives $z + (x\oplus_b y)$. $\square$

Theorems 5.3–5.5 say that $(\mathbb{R}, \oplus_b, +)$ satisfies the semiring axioms relating a commutative associative "addition" $\oplus_b$ to a "multiplication" $+$ that distributes over it — precisely the axioms of the max-plus semiring except for one.

**Theorem 5.6 (Exact idempotency defect).** For $b\neq 0$ and all $x$:
$$x\oplus_b x = x + \frac{\log 2}{b}.$$

*Proof.* $e^{bx}+e^{bx} = 2e^{bx}$; taking the logarithm of this product of positive numbers gives $\log 2 + bx$; dividing by $b$ gives $x + (\log 2)/b$. $\square$

**Remark 5.7.** Idempotency ($x\oplus x = x$) is the defining axiom of *idempotent* (tropical) semirings, and it is the unique tropical axiom that $\oplus_b$ violates. Theorem 5.6 quantifies the violation as a constant translation independent of $x$, of magnitude $(\log 2)/b$. It is thus natural to regard $1/b$ as a deformation (or temperature, or Planck) parameter, and the limit $b\to\infty$ as a classical/zero-temperature limit — the *Maslov dequantization* of Section 6.

**Remark 5.8 (Absence of a neutral element).** The structure $(\mathbb{R},\oplus_b)$ has no neutral element, since $x\oplus_b y > \max(x,y) \geq x$ strictly (Theorem 6.1); the max-plus neutral element $-\infty$ is recovered only in the limit, or by extending the domain. This is why we speak of a *semiring-like* structure on $\mathbb{R}$ rather than a semiring: it is the isomorphic image of $(\mathbb{R}_{>0},+,\times)$, which likewise lacks an additive identity.

---

## 6. The sharp sandwich and dequantization

**Theorem 6.1 (Strict domination).** For $b>0$ and all $x,y$:
$$\max(x,y) < x\oplus_b y.$$

*Proof.* Since $b>0$, the claim is equivalent (multiplying by $b$ and exponentiating, both monotone operations) to
$$e^{b\max(x,y)} < e^{bx}+e^{by}.$$
By symmetry assume $x\leq y$, so $\max(x,y)=y$ and the right-hand side is $e^{by} + e^{bx} > e^{by}$ because $e^{bx}>0$. $\square$

**Theorem 6.2 (Sharp upper bound).** For $b>0$ and all $x,y$:
$$x\oplus_b y \leq \max(x,y) + \frac{\log 2}{b}.$$

*Proof.* Let $m = \max(x,y)$. Since $b>0$, $e^{bx}\leq e^{bm}$ and $e^{by}\leq e^{bm}$, hence
$$e^{bx}+e^{by} \leq 2e^{bm}.$$
Applying the increasing function $\log$ and using $\log(2e^{bm}) = \log 2 + bm$ gives
$$\log(e^{bx}+e^{by}) \leq \log 2 + bm = \left(m + \tfrac{\log 2}{b}\right)b,$$
and dividing by $b>0$ yields the claim. $\square$

**Corollary 6.3 (Sharpness).** The constant $\log 2$ in Theorem 6.2 cannot be decreased: equality holds throughout whenever $x=y$, by Theorem 5.6. Conversely, the strict inequality of Theorem 6.1 is never an equality but is asymptotically tight: for $x>y$ one has the exact second-order expansion
$$x\oplus_b y = \max(x,y) + \frac{1}{b}\log\!\left(1+e^{-b|x-y|}\right),$$
whose error term decays from $(\log 2)/b$ at $x=y$ to $0$ exponentially fast in $b|x-y|$.

*Proof of the expansion.* With $m=\max(x,y)$ and $d = |x-y|$, factor $e^{bx}+e^{by} = e^{bm}\left(1+e^{-bd}\right)$ and take $\log$. $\square$

**Theorem 6.4 (Maslov dequantization, max-plus form).** For all $x,y \in \mathbb{R}$,
$$\lim_{b\to+\infty} \; x\oplus_b y \;=\; \max(x,y).$$

*Proof.* Squeeze. For all $b>0$, Theorems 6.1 and 6.2 give
$$\max(x,y) \leq x\oplus_b y \leq \max(x,y) + \frac{\log 2}{b}.$$
Both bounding sequences tend to $\max(x,y)$ as $b\to\infty$, since $(\log 2)/b\to 0$. $\square$

**Theorem 6.5 (Min-plus / tropical form).** For all $x,y\in\mathbb{R}$,
$$\lim_{b\to+\infty}\; -\bigl((-x)\oplus_b(-y)\bigr) \;=\; \min(x,y),$$
which is the addition of the tropical semiring in its min-plus convention.

*Proof.* By Theorem 6.4 applied at $(-x,-y)$, $(-x)\oplus_b(-y) \to \max(-x,-y)$, and negation is continuous, so the left-hand side converges to $-\max(-x,-y) = \min(x,y)$. $\square$

**Remark 6.6 (Uniformity).** The bound of Theorem 6.2 is *uniform in $(x,y)$*: the error $x\oplus_b y - \max(x,y)$ lies in $(0, (\log 2)/b]$ for every pair of arguments. Consequently the convergence in Theorem 6.4 is uniform on $\mathbb{R}^{2}$, with rate exactly $\Theta(1/b)$ in the sup norm. This is what makes the deformation useful as a *quantitative* approximation scheme rather than a merely pointwise limit.

**Remark 6.7 ($n$-ary version).** The same argument with $n$ summands gives $\max_i x_i < \frac1b\log\sum_{i=1}^{n}e^{bx_i} \leq \max_i x_i + \frac{\log n}{b}$, so the uniform error grows only logarithmically in the number of terms.

---

## 7. The bridge theorem

We now specialize the second argument of the log-sum-exp to the tropical unit $0$.

**Lemma 7.1 (Activation = log-sum-exp against $0$).** For every $b \neq 0$ and every $x$,
$$\frac{E_{0,b}(x)}{b} = x\oplus_b 0.$$

*Proof.* $E_{0,b}(x) = \log(1+e^{bx})$ and $x\oplus_b 0 = \frac1b\log(e^{bx}+e^{0}) = \frac1b\log(e^{bx}+1)$. Commutativity of addition inside the logarithm identifies the two. $\square$

Write $S_b(x) := E_{0,b}(x)/b = \frac1b\log(1+e^{bx})$ for the *rescaled* EML activation with sharpness $b>0$.

**Theorem 7.2 (EML activation ↔ tropical bridge).** Let $b>0$. Then:

1. **(Strict convexity)** $E_{0,b}$ — and hence $S_b$, being a positive multiple of it — is strictly convex on all of $\mathbb{R}$.
2. **(Strict monotonicity)** $E_{0,b}$, and hence $S_b$, is strictly increasing on $\mathbb{R}$; this is the boundary case $a=0$ of the exact monotonicity domain $a\geq 0$.
3. **(Strict domination)** For every $x\in\mathbb{R}$, $\;\max(x,0) < S_b(x)$.
4. **(Uniform $O(1/b)$ approximation)** For every $x\in\mathbb{R}$, $\;S_b(x) \leq \max(x,0) + \dfrac{\log 2}{b}$.
5. **(Dequantization)** For every $x\in\mathbb{R}$, $\;\displaystyle\lim_{c\to\infty} \frac{E_{0,c}(x)}{c} = \max(x,0)$.

*Proof.* (1) is Theorem 3.5 with $a=0$, $b\neq 0$; scaling by $1/b>0$ preserves strict convexity. (2) is Theorem 4.1 with $a=0$. (3) and (4) follow from Lemma 7.1 together with Theorems 6.1 and 6.2 applied at $y=0$. (5) follows from Lemma 7.1 (valid for every $c\neq 0$, hence eventually along $c\to\infty$) together with Theorem 6.4 at $y=0$. $\square$

**Remark 7.3 (Loss of strictness in the limit).** The limit function $R(x) = \max(x,0)$ is convex and non-decreasing but *nowhere strictly convex* (it is affine on $(-\infty,0]$ and on $[0,\infty)$) and *not strictly increasing* (it is constant on $(-\infty,0]$). Thus items (1)–(2) hold for every finite $b$ and fail in the limit: the strictness properties are lost exactly at $b=\infty$. This is a genuine qualitative discontinuity, mirroring the fact that idempotency (Theorem 5.6) is achieved only in the limit. Equivalently, the curvature $S_b''(x) = b\,\sigma(bx)(1-\sigma(bx))$ has total mass $\int_{\mathbb{R}} S_b'' = 1$ independent of $b$, and converges weakly to the Dirac mass $\delta_0$: all curvature concentrates at the origin, becoming the corner.

**Remark 7.4 (Interpretation as a rectifier).** Statements (3)–(4) say precisely that the graph of $S_b$ lies in a horizontal band of height $(\log 2)/b$ above the graph of the rectifier, everywhere. Equivalently $\|S_b - R\|_{\infty} = (\log 2)/b$, attained at $x=0$ where $S_b(0) = (\log 2)/b$ and $R(0)=0$. The sup-norm distance between the smoothed and the sharp rectifier is therefore known *exactly*, not merely bounded.

---

## 8. Algorithms

Two computational tasks arise naturally from the theory: evaluating the deformation stably, and inverting the error bound to select a sharpness parameter.

### 8.1 Numerically stable evaluation

Direct evaluation of $\frac1b\log(e^{bx}+e^{by})$ overflows when $b\max(x,y)$ exceeds the exponent range of the floating-point format (about $709$ in IEEE double precision), and loses all precision when $b\min(x,y)$ underflows. The stable form is exactly the expansion of Corollary 6.3:
$$x\oplus_b y = m + \frac{1}{b}\log\!\left(1 + e^{-b|x-y|}\right), \qquad m=\max(x,y),$$
in which the exponential argument is always $\leq 0$, so $e^{-b|x-y|} \in (0,1]$ and no overflow is possible. The subexpression $\log(1+u)$ for small $u$ should be evaluated with the dedicated `log1p` primitive to avoid catastrophic cancellation. The cost is $O(1)$ arithmetic operations with one exponential and one logarithm.

Similarly, the activation itself is evaluated as
$$S_b(x) = \max(x,0) + \frac1b\,\mathrm{log1p}\!\left(e^{-b|x|}\right),$$
which is manifestly the rectifier plus a strictly positive correction bounded by $(\log 2)/b$ — the theory and the numerics agree term by term.

### 8.2 Sharpness selection from an error tolerance

Given a target uniform accuracy $\varepsilon>0$ for approximating the rectifier, Theorem 7.2(4) and Remark 7.4 give the exact requirement
$$\|S_b - R\|_{\infty} = \frac{\log 2}{b} \leq \varepsilon \iff b \geq \frac{\log 2}{\varepsilon}.$$
Thus the minimal admissible sharpness is $b^{\ast} = (\log 2)/\varepsilon$, and it is optimal: no smaller $b$ works, since the error at $x=0$ equals $(\log 2)/b$ exactly. The corresponding maximal curvature is $\sup_x S_b''(x) = b/4 = \log 2/(4\varepsilon)$, exposing the fundamental trade-off: accuracy $\varepsilon$ costs curvature (and hence gradient-step restriction) of order $1/\varepsilon$.

### 8.3 Monotonicity certification

Given $(a,b)$ with $b > 0$, deciding whether $E_{a,b}$ is strictly increasing is, by Theorem 4.3, the single comparison $a \geq 0$ — an $O(1)$ test with no numerical analysis required. When $-b<a<0$ the failure can be *localized*: the unique critical point is $x^{\ast} = \frac1b\log\frac{-a}{a+b}$ (Remark 4.4), and the depth of the resulting dip below the value at $+\infty$ can be computed in closed form. This turns a qualitative failure into an actionable diagnostic.

---

## 9. Applications and discussion

### 9.1 Neural network design

The results give three concrete guarantees for architectures built on EML activations.

- **Convexity is free.** Any activation of the form $ax + \log(1+e^{bx})$ with $b\neq 0$ is strictly convex, whatever the leak $a$. In *input-convex* neural architectures — where convexity of the network in its inputs is enforced by requiring convex, non-decreasing activations and non-negative weights — this half of the requirement is automatic.
- **Monotonicity has a sharp threshold.** The second half of the input-convex requirement, non-decrease, holds exactly when $a\geq 0$. The criterion is not an estimate; a leak of $a=-10^{-6}$ genuinely produces a non-monotone activation, with a minimum at $x^{\ast} = \frac1b\log\frac{-a}{a+b}$ far out on the left.
- **Smoothing is quantitatively controlled.** Replacing a rectifier by $S_b$ changes each neuron's pre-activation output by at most $(\log 2)/b$, uniformly. Propagating this through a network of depth $d$ with $1$-Lipschitz layers gives a total drift of $O(d\log 2/b)$, so the smoothed model can be made uniformly close to its piecewise-linear idealization at a price logarithmic in nothing and linear in $1/b$.

### 9.2 Tropical geometry of networks

A rectifier network computes a piecewise-linear function, which in the tropical dictionary is a *tropical rational function*: a difference of two tropical polynomials, i.e. of two maxima of affine forms. The linear regions of the network correspond to vertices of a Newton polytope, and counting them is a question of polyhedral combinatorics. Theorem 7.2 supplies the analytic half of the dictionary: the smoothed network is an *analytic deformation* of the tropical object, with an explicit modulus of convergence. This suggests treating $1/b$ as a resolution parameter interpolating between a differentiable model (accessible to calculus and gradient descent) and a combinatorial one (accessible to polytope algorithms).

### 9.3 Statistical mechanics and optimization

With $b = 1/T$ the inverse temperature, $x\oplus_b y$ is exactly the free energy $-T\log\left(e^{-(-x)/T}+e^{-(-y)/T}\right)$ of a two-state system with energies $-x,-y$; the sandwich of Section 6 is the statement that the free energy lies between the ground-state energy and the ground-state energy plus $T\log 2$, the entropy contribution of two degenerate states. The $n$-ary form of Remark 6.7 recovers the familiar $T\log n$ entropy of $n$ states. In optimization, the same formulas are the basis of *smoothed maximum* techniques and entropic regularization: $\oplus_b$ is the Legendre-dual of adding $\frac1b$ times a Shannon entropy penalty to the linear program $\max_i x_i$, and $(\log 2)/b$ is the maximal value of that penalty.

### 9.4 Relation to other EML activations

The method — differentiate twice, recognize the logistic factor, read off signs, take a limit at $-\infty$ to get necessity — applies verbatim to other exponential–logarithmic activations, each of which has its own exact parameter domain:
- $x\,\sigma(bx)$ (Swish/SiLU): *not* monotone for any $b>0$, with a single minimum; its second derivative changes sign, so it is convex only outside a bounded interval.
- $a x + \frac1b\log\cosh(bx)$: the derivative is $a + \tanh(bx)$, which ranges over the open interval $(a-1, a+1)$; hence this activation is strictly increasing on $\mathbb{R}$ if and only if $a\geq 1$, while it is strictly convex for every $b\neq 0$ since its second derivative is $b\,\mathrm{sech}^{2}(bx)>0$ for $b>0$. Its $b\to\infty$ limit is the piecewise-linear function $a x + |x|$.
- $x\tanh(\log(1+e^{bx}))$ (Mish): a composite of two EML transcendentals, with a correspondingly richer critical-point structure.

---

## 10. Future work

Six directions extend the present results.

1. **$n$-ary and measure-theoretic log-sum-exp.** Replace the binary $\oplus_b$ by $\frac1b\log\sum_{i<n}e^{bx_i}$ and by $\frac1b\log\int e^{bf}\,d\mu$. The sandwich becomes $\max \leq \cdot \leq \max + \frac{\log n}{b}$, respectively an essential-supremum statement, yielding $L^{p}\to L^{\infty}$ style dequantization theorems.
2. **Joint convexity in two variables.** Show that $(x,y)\mapsto x\oplus_b y$ is convex but *not* strictly convex, being affine along the diagonal $x=y$ — a restriction already computed exactly by the idempotency defect. The tropical limit $\max$ is convex and affine on each of two half-planes.
3. **The deformed semirings as objects.** Endow $\mathbb{R}$ with the $b$-deformed operations $(\oplus_b, +)$ as a genuine algebraic structure transported along $x\mapsto e^{bx}$ from $\mathbb{R}_{>0}$, and prove that this family of structures converges — in a Gromov–Hausdorff sense, or via pointwise convergence of the structure maps — to the tropical semiring.
4. **From one neuron to an architecture.** A rectifier network computes a tropical rational function; the $b$-smoothed network computes a log-sum-exp expression. Quantify the uniform distance between a smoothed network of depth $d$ and its tropical limit; an $O(d\log(\text{width})/b)$ bound would extend the bridge theorem from a single neuron to a whole architecture.
5. **Sharp domains for other EML activations.** Carry out the exact monotonicity/convexity analysis for Swish, Mish, and the $\log\cosh$ family, and identify their piecewise-linear tropical limits.
6. **Rate optimality and refined expansion.** Prove that $(\log 2)/b$ cannot be replaced by $c/b$ with $c<\log 2$ (Corollary 6.3 already gives the extremal configuration $x=y$), and develop the second-order expansion $x\oplus_b y = \max(x,y) + \frac1b\log(1+e^{-b|x-y|})$ into an asymptotic series useful for numerical analysis.

---

## 11. Conclusion

We have determined the exact parameter domain of monotonicity and convexity for the generalized exponential–logarithmic activation family $E_{a,b}(x) = ax+\log(1+e^{bx})$: strict convexity on the whole real line for every $a$ and every $b\neq 0$, and — for $b>0$ — strict monotonicity if and only if $a\geq 0$. Both statements are sharp, the second being established by a limit argument that shows a negative leak destroys even weak monotonicity.

The same exponential–logarithmic pairing generates the log-sum-exp operation, which we showed satisfies commutativity, associativity, and distributivity over ordinary addition *exactly*, being the transport of positive arithmetic along $x\mapsto e^{bx}$, and which violates idempotency by the exactly computable constant $(\log 2)/b$. The two-sided sandwich $\max(x,y) < x\oplus_b y \leq \max(x,y)+(\log 2)/b$ then yields Maslov dequantization to tropical addition with an explicit, uniform, and optimal rate.

Specializing to the tropical unit closes the loop: the rescaled activation $S_b(x) = \frac1b\log(1+e^{bx})$ is strictly convex and strictly increasing for every finite $b>0$, strictly dominates the rectifier $\max(x,0)$, lies within $(\log 2)/b$ of it uniformly, and converges to it — losing both strictness properties precisely in the limit. Smooth convex analysis and idempotent tropical algebra are two ends of a single exponential–logarithmic deformation, and the whole discrepancy between them is the number $\log 2$ divided by the sharpness.
