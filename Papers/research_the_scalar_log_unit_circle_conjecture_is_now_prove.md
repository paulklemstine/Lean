# The Scalar Logarithmic Radius on the Vertical Line $1 + ti$: Uniqueness, a Certified Rational Interval, and Unitary Lifts

**Author:** Aristotle
**Date:** 2026-08-09

---

## Abstract

We study the *scalar logarithmic radius*
$$R(t) \;=\; \bigl|\operatorname{Log}(1 + t i)\bigr|, \qquad t \in \mathbb{R},$$
where $\operatorname{Log}$ denotes the principal branch of the complex logarithm. We prove the closed form
$$R(t)^{2} = \left(\tfrac{1}{2}\log(1+t^{2})\right)^{2} + (\arctan t)^{2},$$
and deduce that $R$ is strictly increasing on $[0,\infty)$, hence injective there. Combined with continuity and the explicit growth estimate $R(e^{r}) \ge r$, this shows that $R$ restricts to a **bijection of $[0,\infty)$ onto itself**: every radius is attained exactly once. In particular the equation $R(t) = 1$ has a *unique* positive solution $t^{\star}$, resolving an earlier existence-only statement.

We then certify the location of $t^{\star}$ with rational endpoints, proving
$$t^{\star} \in \left[\tfrac{6}{5}, \tfrac{5}{4}\right],$$
a thirty-fold reduction in width over the previously available interval $[1/2, 3]$. The certificate uses only three elementary ingredients: the tangent-line bounds $1 - x^{-1} \le \log x \le x - 1$ applied after splitting off a factor of $2$; the two-sided bound $y/(1+y^{2}) \le \arctan y \le y$ for $y \ge 0$; and the exact addition identities $\arctan\frac{6}{5} = \frac{\pi}{4} + \arctan\frac{1}{11}$, $\arctan\frac{5}{4} = \frac{\pi}{4} + \arctan\frac{1}{9}$.

Finally we develop the operator-algebraic consequences. A unimodular complex scalar times the unit of any complex $*$-algebra is unitary, so the certified root yields a unitary scalar in every matrix $C^{\star}$-algebra; the polar normalization $\operatorname{Log}(1+ti)/R(t)$ is unitary for *every* $t \neq 0$. We prove that in a unital $C^{\star}$-algebra every unitary with finite spectrum is $\exp(ix)$ for a self-adjoint $x$ — in particular every unitary matrix is $\exp(iH)$ with $H$ Hermitian — via a rotation trick that moves a finite spectrum off the branch point $-1$. We prove that every unitary matrix factors as a unimodular scalar times a determinant-one unitary, and we exhibit a sharp obstruction: for every $t \neq 0$ the scalar factor $\operatorname{Log}(1+ti)\,I_{2}$ is unitary but never lies in $SU(2)$.

**Keywords:** principal complex logarithm, arctangent addition identities, certified interval arithmetic, strict monotonicity, unitary group, $C^{\star}$-algebra, exponential surjectivity, special unitary group.

---

## 1. Introduction

### 1.1 The problem

Fix the vertical line $L = \{\,1 + ti : t \in \mathbb{R}\,\}$ in the complex plane and apply the principal logarithm. Since $L$ lies strictly in the right half-plane, $\operatorname{Log}$ is holomorphic on a neighbourhood of $L$ and $\operatorname{Log}(L)$ is a real-analytic curve through the origin. The question we address is where that curve meets circles centred at the origin, and above all where it meets the **unit** circle:
$$\bigl|\operatorname{Log}(1 + ti)\bigr| = 1. \tag{1.1}$$

Equation (1.1) is transcendental in an essential way: it couples $\log$ and $\arctan$ with no algebraic relation between them. There is no closed-form solution. What one can do — and what we do here — is prove that the solution set is exactly $\{-t^{\star}, t^{\star}\}$ for a single positive constant $t^{\star}$, and confine $t^{\star}$ to a narrow interval with rational endpoints by a self-contained certificate.

### 1.2 Motivation

The interest in (1.1) is not purely analytic. A complex number of modulus $1$ is precisely a unitary element of the one-dimensional $C^{\star}$-algebra $\mathbb{C}$, and multiplying the identity of any complex $*$-algebra by such a scalar produces a unitary element — a *global phase*. Equation (1.1) therefore asks: for which shift parameters $t$ is the logarithm of $1 + ti$ *itself* a legitimate phase?

The map $x \mapsto \log(1 + x)$ is the canonical multiplicative-to-additive nonlinearity; the imaginary shift $x = ti$ is what appears when the underlying signal is a phase rather than an amplitude. So (1.1) is the calibration equation for the parameter at which such a nonlinearity, applied to a unit-amplitude signal along the imaginary direction, produces an output that is exactly a unitary.

### 1.3 Contributions

1. **A closed form** for $R(t)^{2}$ (Theorem 3.1) reducing the whole problem to a two-term real equation.
2. **Strict monotonicity** of $R$ on $[0,\infty)$ (Theorem 4.2), hence injectivity, hence **uniqueness** of the positive solution (Theorem 4.4).
3. **A certified rational interval** $[6/5, 5/4]$ for $t^{\star}$ (Theorem 5.6, Corollary 5.7), improving $[1/2,3]$ by a factor of $30$ in width, with a fully elementary certificate.
4. **A bijectivity theorem** (Theorem 6.3): $R : [0,\infty) \to [0,\infty)$ is a bijection, so *every* circle is hit exactly once.
5. **Unitary lifts** (Theorems 7.1, 7.4): unimodular scalars times the unit are unitary in any complex $*$-algebra; the polar-normalized logarithmic factor is unitary for all $t \neq 0$.
6. **Exponential surjectivity** (Theorem 8.3, Corollary 8.4): every unitary with finite spectrum in a unital $C^{\star}$-algebra is $\exp(ix)$ for self-adjoint $x$; every unitary matrix is $\exp(iH)$ for Hermitian $H$.
7. **Determinant splitting and an $SU(2)$ obstruction** (Theorems 9.2, 9.3): $U(n) = U(1)\cdot SU(n)$ elementwise, but the scalar logarithmic factor is never special unitary.

---

## 2. Notation and standing conventions

Throughout, $i$ is the imaginary unit; $\operatorname{Log} : \mathbb{C}\setminus(-\infty,0] \to \mathbb{C}$ is the principal branch of the complex logarithm, characterised by
$$\operatorname{Log} z = \log|z| + i \operatorname{Arg} z, \qquad \operatorname{Arg} z \in (-\pi, \pi],$$
where $\log$ on the right is the real natural logarithm. We write $|\cdot|$ for the modulus on $\mathbb{C}$ and the norm on a normed algebra.

For a unital complex $*$-algebra $A$ we write $\mathcal{U}(A) = \{u \in A : u^{*}u = uu^{*} = 1\}$ for its unitary group, $\operatorname{sp}(u)$ for the spectrum of $u$, and we call $x \in A$ *self-adjoint* if $x^{*} = x$. For matrices, $M^{*}$ is the conjugate transpose, $\operatorname{Herm}(n)$ the Hermitian $n \times n$ complex matrices, $U(n) = \mathcal{U}(M_{n}(\mathbb{C}))$ and $SU(n) = \{U \in U(n) : \det U = 1\}$.

**Definition 2.1 (Scalar logarithmic radius).** For $t \in \mathbb{R}$ set
$$R(t) \;:=\; \bigl|\operatorname{Log}(1 + t i)\bigr|.$$

**Definition 2.2 (Radius square).** For $t \in \mathbb{R}$ set
$$S(t) \;:=\; \left(\frac{\log(1 + t^{2})}{2}\right)^{2} + (\arctan t)^{2}.$$

**Definition 2.3 (Polar normalization).** For $w \in \mathbb{C}$ set $\mathrm{pu}(w) := |w|^{-1} w$ (with the convention $\mathrm{pu}(0) = 0$, never used below).

Note $1 + ti$ lies in the open right half-plane for all real $t$, so it is in the domain of $\operatorname{Log}$ and $R$ is well defined and finite everywhere.

---

## 3. The closed form

**Lemma 3.0 (Modulus and argument on the line).** For every $t \in \mathbb{R}$,
$$|1 + ti| = \sqrt{1 + t^{2}}, \qquad \operatorname{Arg}(1 + ti) = \arctan t.$$

*Proof.* The modulus is immediate from $|a + bi|^{2} = a^{2} + b^{2}$ with $a = 1$, $b = t$. For the argument: since the real part $1$ is positive, the principal argument is given by $\operatorname{Arg}(a+bi) = \arcsin\!\bigl(b/|a+bi|\bigr)$ on the right half-plane, and
$$\arcsin\!\left(\frac{t}{\sqrt{1+t^{2}}}\right) = \arctan t$$
is the standard identity relating the two inverse trigonometric functions, obtained from $\sin(\arctan t) = t/\sqrt{1+t^{2}}$. $\square$

**Theorem 3.1 (Closed form).** For every $t \in \mathbb{R}$,
$$R(t)^{2} = S(t) = \left(\frac{\log(1+t^{2})}{2}\right)^{2} + (\arctan t)^{2}.$$

*Proof.* By definition of the principal branch and Lemma 3.0,
$$\operatorname{Re}\operatorname{Log}(1+ti) = \log|1+ti| = \log\sqrt{1+t^{2}} = \tfrac{1}{2}\log(1+t^{2}),$$
$$\operatorname{Im}\operatorname{Log}(1+ti) = \operatorname{Arg}(1+ti) = \arctan t.$$
Now $|w|^{2} = (\operatorname{Re} w)^{2} + (\operatorname{Im} w)^{2}$. $\square$

**Corollary 3.2 (Basic properties).** $R \ge 0$, $S \ge 0$, $R = \sqrt{S}$, $R(0) = 0$, and both $R$ and $S$ are even: $R(-t) = R(t)$.

*Proof.* Nonnegativity of $R$ is clear and $S = R^{2} \ge 0$; since $R \ge 0$, $R = \sqrt{R^{2}} = \sqrt{S}$. At $t=0$, $\operatorname{Log} 1 = 0$. Evenness follows from Theorem 3.1 because $t \mapsto t^{2}$ is even and $\arctan$ is odd, so $(\arctan(-t))^{2} = (\arctan t)^{2}$. $\square$

Corollary 3.2 already contains the **symmetry statement**: every positive solution of $R(t)=r$ is matched by a negative one, $-t$. Consequently the full solution set of (1.1) in $\mathbb{R}\setminus\{0\}$ is $\{\pm t^{\star}\}$ once uniqueness on $(0,\infty)$ is established.

**Lemma 3.3 (Continuity).** $R$ is continuous on $\mathbb{R}$.

*Proof.* $t \mapsto 1 + ti$ is continuous with values in the open right half-plane, which is contained in the slit plane $\mathbb{C}\setminus(-\infty,0]$ where $\operatorname{Log}$ is continuous; the modulus is continuous. $\square$

---

## 4. Strict monotonicity and uniqueness

**Lemma 4.0.** $\log(1 + t^{2}) \ge 0$ and $\arctan t \ge 0$ for all $t \ge 0$.

*Proof.* $1 + t^{2} \ge 1$ and $\log$ is nonnegative on $[1,\infty)$; $\arctan$ is odd, increasing, and $\arctan 0 = 0$. $\square$

**Theorem 4.1 (Strict monotonicity of $S$).** $S$ is strictly increasing on $[0,\infty)$.

*Proof.* Let $0 \le a < b$. Then $a^{2} < b^{2}$, so $1 + a^{2} < 1 + b^{2}$ and, $\log$ being strictly increasing on $(0,\infty)$,
$$0 \le \log(1+a^{2}) < \log(1+b^{2}).$$
Also $\arctan$ is strictly increasing, so $0 \le \arctan a < \arctan b$ by Lemma 4.0. Squaring is strictly increasing on $[0,\infty)$, so both summands of $S$ strictly increase from $a$ to $b$; hence $S(a) < S(b)$. $\square$

**Theorem 4.2 (Strict monotonicity of $R$).** $R$ is strictly increasing on $[0,\infty)$.

*Proof.* $R = \sqrt{S}$ by Corollary 3.2, $S \ge 0$, $S$ is strictly increasing on $[0,\infty)$ by Theorem 4.1, and $\sqrt{\cdot}$ is strictly increasing on $[0,\infty)$. $\square$

**Corollary 4.3 (Injectivity).** $R$ is injective on $[0,\infty)$.

**Theorem 4.4 (Existence and uniqueness of the unit-circle root).** There is exactly one $t > 0$ with $R(t) = 1$. We denote it $t^{\star}$.

*Proof.* *Existence* follows from Lemma 3.3 and the intermediate value theorem once one exhibits points where $R < 1$ and $R > 1$; Theorem 5.4 and Theorem 5.5 below do this at $t = 6/5$ and $t = 5/4$ respectively, and the resulting root is positive since it lies in $[6/5, 5/4]$. *Uniqueness*: if $0 < s$ and $0 < t$ both satisfy $R(s) = R(t) = 1$, then $s = t$ by Corollary 4.3. $\square$

Note the logical structure: uniqueness is unconditional and cheap, while existence is where all the quantitative work sits. We turn to it now.

---

## 5. The certified interval $[6/5, 5/4]$

The goal is $S(6/5) < 1 < S(5/4)$ with a proof using only elementary, verifiable inequalities. The true values are
$$S(6/5) = 0.966393\ldots, \qquad S(5/4) = 1.024278\ldots,$$
so the certificate has to be accurate to a few percent in each of four separate estimates; crude bounds do not suffice.

### 5.1 Elementary tools

**Lemma 5.1 (Upper arctangent bound).** For $y \ge 0$, $\arctan y \le y$.

*Proof.* Let $x = \arctan y \in [0, \pi/2)$. The classical tangent inequality gives $x \le \tan x$ for $x \in [0,\pi/2)$, and $\tan(\arctan y) = y$, so $\arctan y = x \le \tan x = y$. $\square$

**Lemma 5.2 (Lower arctangent bound).** For $y \ge 0$,
$$\frac{y}{1 + y^{2}} \le \arctan y.$$

*Proof.* Put $x = \arctan y \ge 0$. Then
$$\sin x = \frac{y}{\sqrt{1+y^{2}}}, \qquad \cos x = \frac{1}{\sqrt{1+y^{2}}},$$
so $2 \sin x \cos x = 2y/(1+y^{2})$. On the other hand $\sin(2x) \le 2x$ for $2x \ge 0$ (the elementary bound $\sin u \le u$ for $u \ge 0$), and $\sin(2x) = 2\sin x \cos x$. Combining,
$$\frac{2y}{1+y^{2}} = \sin(2x) \le 2x = 2\arctan y,$$
and dividing by $2$ gives the claim. $\square$

The two bounds bracket $\arctan y$ within $y^{3}/(1+y^{2})$, which at $y = 1/9$ is about $1.36 \times 10^{-3}$ and at $y = 1/11$ about $7.5 \times 10^{-4}$. This is why the addition identities matter: they replace an arctangent at a moderate argument (where the bracket is wide) by $\pi/4$ plus an arctangent at a tiny argument (where the bracket is negligible).

**Lemma 5.3 (Exact arctangent addition identities).**
$$\arctan\tfrac{6}{5} = \tfrac{\pi}{4} + \arctan\tfrac{1}{11}, \qquad \arctan\tfrac{5}{4} = \tfrac{\pi}{4} + \arctan\tfrac{1}{9}.$$

*Proof.* The addition formula $\arctan x + \arctan y = \arctan\!\frac{x+y}{1-xy}$ is valid whenever $xy < 1$. With $x = 1$, $\arctan 1 = \pi/4$, so for $y < 1$,
$$\tfrac{\pi}{4} + \arctan y = \arctan\frac{1+y}{1-y}.$$
Taking $y = 1/11$ gives $\frac{12/11}{10/11} = \frac{12}{10} = \frac{6}{5}$; taking $y = 1/9$ gives $\frac{10/9}{8/9} = \frac{10}{8} = \frac{5}{4}$. $\square$

We also use the classical tangent-line bounds for the logarithm,
$$1 - \frac{1}{x} \;\le\; \log x \;\le\; x - 1 \qquad (x > 0), \tag{5.1}$$
and the certified numerical bounds
$$0.6931471803 < \log 2 < 0.6931471808, \qquad 3.141592 < \pi < 3.15. \tag{5.2}$$

### 5.2 The upper endpoint estimate

**Theorem 5.4.** $S(6/5) < 1$, hence $R(6/5) < 1$.

*Proof.* Write $L = \log\!\left(1 + (6/5)^{2}\right) = \log\frac{61}{25}$. Split off a factor of two:
$$\frac{61}{25} = 2 \cdot \frac{61}{50}, \qquad\text{so}\qquad L = \log 2 + \log\frac{61}{50}.$$
By (5.1), $\log\frac{61}{50} \le \frac{61}{50} - 1 = \frac{11}{50} = 0.22$, and by (5.2), $\log 2 < 0.6931471808$. Hence
$$0 \le L \le 0.9131471808 \le 0.9131472, \qquad \left(\frac{L}{2}\right)^{2} \le 0.208464\ldots$$
For the arctangent, Lemma 5.3 and Lemma 5.1 give
$$\arctan\tfrac{6}{5} = \tfrac{\pi}{4} + \arctan\tfrac{1}{11} \le \frac{3.15}{4} + \frac{1}{11} = 0.7875 + 0.0\overline{90} = 0.878409\ldots \le 0.8785,$$
so $\left(\arctan\frac65\right)^{2} \le 0.771762\ldots$. Adding,
$$S(6/5) \le 0.208464 + 0.771763 = 0.980227 < 1.$$
Finally $R(6/5) = \sqrt{S(6/5)} < \sqrt{1} = 1$. $\square$

Note the deliberate slack in $\pi < 3.15$: the certificate is robust enough that only a two-digit upper bound for $\pi$ is required at the lower endpoint.

### 5.3 The lower endpoint estimate

**Theorem 5.5.** $S(5/4) > 1$, hence $R(5/4) > 1$.

*Proof.* Write $L = \log\!\left(1 + (5/4)^{2}\right) = \log\frac{41}{16}$ and split off a factor of two:
$$\frac{41}{16} = 2 \cdot \frac{41}{32}, \qquad L = \log 2 + \log\frac{41}{32}.$$
The lower tangent-line bound in (5.1) gives
$$\log\frac{41}{32} \ge 1 - \frac{32}{41} = \frac{9}{41} = 0.219512\ldots,$$
and $\log 2 > 0.6931471803$, so
$$L \ge 0.9126593, \qquad \left(\frac{L}{2}\right)^{2} \ge 0.208236\ldots$$
For the arctangent, Lemma 5.3 and Lemma 5.2 give
$$\arctan\tfrac{5}{4} = \tfrac{\pi}{4} + \arctan\tfrac{1}{9} \ge \frac{3.141592}{4} + \frac{1/9}{1 + 1/81} = 0.785398 + \frac{9}{82} = 0.785398 + 0.109756 = 0.895154 \ge 0.8951,$$
so $\left(\arctan\frac54\right)^{2} \ge 0.801204$. Adding,
$$S(5/4) \ge 0.208236 + 0.801204 = 1.009440 > 1,$$
and $R(5/4) = \sqrt{S(5/4)} > 1$. $\square$

Here the sharper bound $\pi > 3.141592$ *is* needed: the margin is under one percent.

### 5.4 The interval theorem

**Theorem 5.6 (Certified interval — existence).** There exists $t \in [6/5, 5/4]$ with $R(t) = 1$.

*Proof.* $R$ is continuous (Lemma 3.3), $R(6/5) < 1$ (Theorem 5.4) and $R(5/4) > 1$ (Theorem 5.5), so $1$ lies in $[R(6/5), R(5/4)]$; the intermediate value theorem on $[6/5,5/4]$ supplies the root. $\square$

**Corollary 5.7 (Certified interval — localization).** If $t > 0$ and $R(t) = 1$ then $t \in [6/5, 5/4]$. Consequently $t^{\star} \in [6/5, 5/4]$ and this is the *only* positive root.

*Proof.* Suppose $t < 6/5$. Since $0 \le t$ and $0 \le 6/5$, strict monotonicity (Theorem 4.2) gives $1 = R(t) < R(6/5) < 1$, a contradiction. Suppose $t > 5/4$. Then $R(5/4) < R(t) = 1$, contradicting Theorem 5.5. $\square$

**Remark 5.8.** The previously available certificate was $t^{\star} \in [1/2, 3]$, of width $5/2$; the new interval has width $1/20$, a factor-of-$30$ improvement. Numerically $t^{\star} = 1.2290375625139\ldots$, comfortably interior. The technique scales: further tightening is a matter of splitting off more refined rational factors from $1 + t^{2}$ and using higher-precision certified bounds on $\log 2$ and $\pi$, at the cost of longer arithmetic but no new ideas.

---

## 6. Every circle is hit exactly once

Uniqueness for radius $1$ is a special case of a global statement.

**Lemma 6.1 (Growth).** For every $r \in \mathbb{R}$, $R(e^{r}) \ge r$.

*Proof.* Discard the arctangent term: by Theorem 3.1,
$$S(e^{r}) \ge \left(\frac{\log(1 + e^{2r})}{2}\right)^{2}.$$
Since $e^{2r} \le 1 + e^{2r}$ and $\log$ is increasing, $\log(1+e^{2r}) \ge \log e^{2r} = 2r$, so $\frac{1}{2}\log(1+e^{2r}) \ge r$. If $r \le 0$ the claim $R(e^r) \ge r$ is trivial because $R \ge 0$; if $r > 0$ then
$$R(e^{r}) = \sqrt{S(e^{r})} \ge \sqrt{\left(\tfrac12 \log(1+e^{2r})\right)^{2}} = \tfrac12\log(1+e^{2r}) \ge r. \qquad \square$$

**Lemma 6.2.** $R(0) = 0$ and $R$ is unbounded on $[0,\infty)$.

*Proof.* $R(0) = |\operatorname{Log} 1| = 0$; unboundedness is Lemma 6.1 with $r \to \infty$. $\square$

**Theorem 6.3 (The radius map is a bijection).** For every $r \ge 0$ there is exactly one $t \ge 0$ with $R(t) = r$. Equivalently, $R|_{[0,\infty)} : [0,\infty) \to [0,\infty)$ is a bijection, strictly increasing and continuous, hence an increasing homeomorphism.

*Proof.* *Existence:* fix $r \ge 0$. Then $R(0) = 0 \le r$ and $R(e^{r}) \ge r$ by Lemma 6.1, so $r \in [R(0), R(e^{r})]$; by continuity (Lemma 3.3) and the intermediate value theorem on $[0, e^{r}]$ there is $t \in [0, e^{r}]$ with $R(t) = r$. *Uniqueness:* Corollary 4.3. Surjectivity onto $[0,\infty)$ and injectivity give bijectivity; a continuous strictly monotone bijection between intervals is a homeomorphism. $\square$

Theorem 4.4 is the case $r = 1$ of Theorem 6.3, together with the observation that the root is nonzero because $R(0) = 0 \neq 1$.

**Corollary 6.4 (Full solution set).** For $r > 0$, $\{t \in \mathbb{R} : R(t) = r\} = \{-t_{r}, t_{r}\}$ where $t_{r} > 0$ is the unique nonnegative solution. In particular the solution set of $|\operatorname{Log}(1+ti)| = 1$ is $\{\pm t^{\star}\}$.

*Proof.* Evenness (Corollary 3.2) plus Theorem 6.3. $\square$

---

## 7. Unitary lifts of the scalar factor

We now pass from $\mathbb{C}$ to general algebras. Let $A$ be a unital ring equipped with an involution $*$ and a compatible $\mathbb{C}$-algebra structure, so that $(\lambda a)^{*} = \bar\lambda a^{*}$ for $\lambda \in \mathbb{C}$, $a \in A$. (Matrix algebras $M_{n}(\mathbb{C})$ with conjugate transpose are the model case.)

**Theorem 7.1 (Unimodular scalars are unitary).** If $z \in \mathbb{C}$ with $|z| = 1$, then $z \cdot 1_{A} \in \mathcal{U}(A)$.

*Proof.* Since $|z| = 1$ we have $\bar z z = z \bar z = |z|^{2} = 1$. Then
$$(z 1)^{*}(z 1) = \bar z z \cdot 1^{*}1 = 1\cdot 1 = 1,$$
and symmetrically $(z1)(z1)^{*} = z\bar z \cdot 1 = 1$. $\square$

**Corollary 7.2 (Matrix lift of the certified root).** For every $n \ge 0$ there exists $t \in [6/5, 5/4]$ such that
$$\operatorname{Log}(1 + ti)\, I_{n} \in \mathcal{U}(M_{n}(\mathbb{C})).$$

*Proof.* Take $t = t^{\star}$, which lies in $[6/5,5/4]$ by Corollary 5.7 and satisfies $|\operatorname{Log}(1+t^{\star}i)| = R(t^{\star}) = 1$; apply Theorem 7.1 with $A = M_{n}(\mathbb{C})$. $\square$

**Lemma 7.3 (Nonvanishing).** For $t \neq 0$, $\operatorname{Log}(1 + ti) \neq 0$.

*Proof.* Its real part is $\tfrac12\log(1+t^{2})$, and $1 + t^{2} > 1$ for $t \neq 0$, so $\log(1+t^{2}) > 0$. A complex number with nonzero real part is nonzero. (Alternatively, its imaginary part $\arctan t$ is also nonzero.) $\square$

**Theorem 7.4 (Polar-normalized factor is always unitary).** For every $t \neq 0$ and every $A$ as above,
$$\mathrm{pu}\bigl(\operatorname{Log}(1+ti)\bigr)\, 1_{A} \;=\; \frac{\operatorname{Log}(1+ti)}{\bigl|\operatorname{Log}(1+ti)\bigr|}\, 1_{A} \;\in\; \mathcal{U}(A).$$

*Proof.* By Lemma 7.3 the denominator is nonzero, and for $w \neq 0$ one has $|\,|w|^{-1}w\,| = |w|^{-1}|w| = 1$. Apply Theorem 7.1. $\square$

**Proposition 7.5 (Consistency at the root).** If $R(t) = 1$ then $\mathrm{pu}(\operatorname{Log}(1+ti)) = \operatorname{Log}(1+ti)$; the polar normalization is invisible exactly at the certified root.

*Proof.* Immediate: $|w| = 1$ makes $|w|^{-1}w = w$. $\square$

Theorem 7.4 is a genuine strengthening in scope: the certified root gives one distinguished unitary, while the polar normalization produces a whole one-parameter family $\{\mathrm{pu}(\operatorname{Log}(1+ti)) : t \neq 0\}$ of unitary scalars, parameterised by the punctured line. As $t$ ranges over $(0,\infty)$ the argument of this family is
$$\arg \mathrm{pu}\bigl(\operatorname{Log}(1+ti)\bigr) = \arctan\!\left(\frac{\arctan t}{\tfrac12 \log(1+t^{2})}\right),$$
which tends to $\pi/2$ as $t \to 0^{+}$ (the imaginary part $\arctan t \sim t$ dominates the real part $\tfrac12\log(1+t^{2}) \sim t^{2}/2$) and to $0$ as $t \to \infty$ (the real part diverges while the imaginary part is bounded by $\pi/2$). So the family sweeps the open first-quadrant arc of the unit circle, and each of its members is a legitimate global phase.

---

## 8. Exponential surjectivity onto unitaries

Global phases are the simplest unitaries. The natural next question is whether *all* unitaries arise as exponentials of self-adjoint generators — the statement underlying the "Hamiltonian generates the gate" picture. We prove it in the finite-spectrum case, which covers all matrix algebras.

The route to a logarithm of a unitary $u$ goes through the continuous functional calculus applied to the principal branch of $\log$ on the circle. That branch is discontinuous at $-1$; correspondingly the standard construction requires $-1 \notin \operatorname{sp}(u)$, equivalently $\|u - 1\| < 2$. A general unitary can of course have $-1$ in its spectrum. The remedy is to rotate.

**Lemma 8.1 (A finite set cannot cover the circle).** Let $S \subseteq \mathbb{C}$ be finite. Then there exists $\theta \in \mathbb{R}$ with $-e^{i\theta} \notin S$.

*Proof.* Suppose not: $-e^{i\theta} \in S$ for all $\theta$. The map $f(\theta) = -e^{i\theta}$ is injective on $[0, 2\pi)$, since $e^{ia} = e^{ib}$ forces $a - b \in 2\pi\mathbb{Z}$, and the only multiple of $2\pi$ of absolute value less than $2\pi$ is $0$. Hence $f\bigl([0,2\pi)\bigr)$ is infinite, being the injective image of an infinite set, yet it is contained in the finite set $S$ — a contradiction. $\square$

**Lemma 8.2 (Rotation moves the spectrum).** Let $A$ be a unital $C^{\star}$-algebra, $u \in \mathcal{U}(A)$, $\theta \in \mathbb{R}$ with $-e^{i\theta} \notin \operatorname{sp}(u)$, and $c = e^{-i\theta}$. Then $cu \in \mathcal{U}(A)$ and $-1 \notin \operatorname{sp}(cu)$, hence $\|cu - 1\| < 2$.

*Proof.* $|c| = 1$, so $c 1 \in \mathcal{U}(A)$ by Theorem 7.1 and $cu = (c1)u$ is a product of unitaries, hence unitary. For the spectrum, $\operatorname{sp}(cu) = c\cdot\operatorname{sp}(u)$ by the scalar-multiplication rule for spectra (valid since $\operatorname{sp}(u) \neq \emptyset$). If $-1 \in c\operatorname{sp}(u)$, then $-1 = cz$ for some $z \in \operatorname{sp}(u)$, whence, multiplying by $e^{i\theta}$ and using $c\,e^{i\theta} = 1$,
$$z = z\,(c e^{i\theta}) = (cz)e^{i\theta} = -e^{i\theta} \in \operatorname{sp}(u),$$
contradicting the hypothesis. The equivalence $-1 \notin \operatorname{sp}(v) \iff \|v-1\| < 2$ for unitary $v$ is standard: the spectrum of a unitary lies on the circle and $\|v-1\| = \sup\{|z-1| : z \in \operatorname{sp}(v)\}$ by normality, and $|z-1| = 2$ on the circle only at $z = -1$. $\square$

**Theorem 8.3 (Exponential surjectivity, finite spectrum).** Let $A$ be a unital $C^{\star}$-algebra and $u \in \mathcal{U}(A)$ with $\operatorname{sp}(u)$ finite. Then there is a self-adjoint $x \in A$ with
$$\exp(i x) = u.$$

*Proof.* If $A$ is trivial the statement is vacuous; assume $A \neq 0$. Since $\operatorname{sp}(u)$ is finite, Lemma 8.1 gives $\theta$ with $-e^{i\theta}\notin\operatorname{sp}(u)$. Put $c = e^{-i\theta}$ and $v = cu$. By Lemma 8.2, $v$ is unitary with $\|v - 1\| < 2$, so the principal branch of the logarithm is continuous on a neighbourhood of $\operatorname{sp}(v)$ in the circle; the continuous functional calculus produces a self-adjoint $x_{0} \in A$ — the *argument* of $v$, with spectrum in $(-\pi,\pi)$ — such that
$$\exp(i x_{0}) = v = cu.$$
Now set $x := \theta\,1_{A} + x_{0}$. It is self-adjoint, because $\theta$ is real so $(\theta 1)^{*} = \bar\theta 1 = \theta 1$, and a sum of self-adjoints is self-adjoint. The elements $i\theta 1$ and $i x_{0}$ commute (a scalar multiple of the unit is central), so
$$\exp(i x) = \exp(i\theta 1)\exp(i x_{0}) = \bigl(e^{i\theta} 1\bigr)\,(c u) = \bigl(e^{i\theta}c\bigr)u = u,$$
using $\exp(\lambda 1) = e^{\lambda} 1$ for scalars and $e^{i\theta}c = e^{i\theta}e^{-i\theta} = 1$. $\square$

**Corollary 8.4 (Every unitary matrix is $\exp(iH)$).** For every $n$ and every $U \in U(n)$ there is a Hermitian $H \in \operatorname{Herm}(n)$ with $\exp(iH) = U$.

*Proof.* $M_{n}(\mathbb{C})$ with the operator norm is a unital $C^{\star}$-algebra, and the spectrum of a matrix is its finite set of eigenvalues. Apply Theorem 8.3; a self-adjoint matrix is exactly a Hermitian matrix. $\square$

Corollary 8.4 with $n = 2$ says every one-qubit gate is generated by a Hermitian Hamiltonian, which is the structural statement one wants when passing from the scalar theory of Sections 3–7 to full $U(2)$ coverage.

**Remark 8.5.** Finiteness of the spectrum is used only through Lemma 8.1 and can be relaxed: any unitary whose spectrum is not all of the circle admits a rotation to $\|v-1\| < 2$, so the same proof gives exponential surjectivity for every unitary with proper spectrum. In a $C^{\star}$-algebra of infinite dimension there exist unitaries with full circular spectrum, but even then they are exponentials by a spectral-measure argument; the finite case is what is needed here and admits the cleanest self-contained proof.

---

## 9. Determinant tracking and the $SU(2)$ obstruction

**Lemma 9.1 (Unimodular determinant).** If $U \in U(n)$ then $|\det U| = 1$.

*Proof.* From $U^{*}U = I$ take determinants: $\det(U^{*})\det(U) = 1$, and $\det(U^{*}) = \overline{\det U}$. Hence $|\det U|^{2} = 1$, and since $|\det U| \ge 0$, $|\det U| = 1$. $\square$

**Theorem 9.2 (Scalar $\times$ special unitary splitting).** Let $n \ge 1$ and $U \in U(n)$. Then there exist $z \in \mathbb{C}$ with $|z| = 1$ and $V \in U(n)$ with $\det V = 1$ such that
$$U = z\,V.$$

*Proof.* By Lemma 9.1, $\det U \neq 0$ and $|\det U| = 1$, so $\det U = e^{i\alpha}$ with $\alpha = \operatorname{Arg}(\det U)$. Put
$$z := e^{i\alpha/n}, \qquad V := z^{-1}U.$$
Then $|z| = 1$ and $z^{n} = e^{i\alpha} = \det U$. Also $V$ is unitary as a product of the unitary $z^{-1}I$ (Theorem 7.1, since $|z^{-1}| = 1$) with $U$, and
$$\det V = \det(z^{-1}U) = (z^{-1})^{n}\det U = z^{-n}z^{n} = 1.$$
Finally $zV = z z^{-1}U = U$. $\square$

Theorem 9.2 is the elementwise form of the group decomposition $U(n) = U(1)\cdot SU(n)$ (an almost-direct product, the intersection being the $n$-th roots of unity times the identity). It cleanly separates a gate's *global phase* from its *computational content*.

**Theorem 9.3 ($SU(2)$ obstruction for the scalar logarithmic factor).** For every real $t \neq 0$,
$$\det\bigl(\operatorname{Log}(1+ti)\,I_{2}\bigr) \neq 1;$$
equivalently, $\operatorname{Log}(1+ti)\,I_{2} \notin SU(2)$, even when it is unitary.

*Proof.* Write $z = \operatorname{Log}(1+ti)$, so $\operatorname{Im} z = \arctan t \neq 0$ for $t \neq 0$. In dimension $2$, $\det(zI_{2}) = z^{2}$. If $z^{2} = 1$ then $(z-1)(z+1) = 0$, so $z = 1$ or $z = -1$; both are real, contradicting $\operatorname{Im} z \neq 0$. $\square$

**Corollary 9.4.** At the certified root $t^{\star}$, the matrix $\operatorname{Log}(1+t^{\star}i) I_{2}$ lies in $U(2)\setminus SU(2)$. The special unitary content of any decomposition must come from the determinant-one factor $V$ of Theorem 9.2, never from the scalar.

This is the correct conclusion rather than a defect. Global phase is physically unobservable; the theorem quantifies exactly that. The scalar logarithm supplies the $U(1)$ direction and nothing else, and any programme aiming at $SU(2)$ must construct the non-scalar factor independently — which is what Corollary 8.4 makes possible.

---

## 10. Algorithms

We record the two computational procedures implicit in the analysis.

### 10.1 Certified bisection for the root

Because $R$ is continuous and strictly increasing on $[0,\infty)$ with $R(6/5) < 1 < R(5/4)$, bisection on $[6/5, 5/4]$ converges to $t^{\star}$ with the error bound $|t_{k} - t^{\star}| \le 2^{-k}\cdot\frac{1}{20}$ after $k$ steps. Monotonicity guarantees that the sign of $S(m) - 1$ correctly determines which half contains the root, with no possibility of a spurious bracket. In exact rational arithmetic augmented by certified enclosures for $\log$ and $\arctan$, each step yields a *proved* interval; $50$ steps give roughly $16$ correct digits.

**Complexity.** $O(k)$ evaluations of $\log$ and $\arctan$ for $k$ bits of accuracy; linear convergence with rate $1/2$.

### 10.2 Newton refinement

$S$ is smooth with
$$S'(t) = \frac{t \log(1+t^{2})}{1+t^{2}} + \frac{2\arctan t}{1 + t^{2}} = \frac{t\log(1+t^{2}) + 2\arctan t}{1+t^{2}},$$
which is strictly positive for $t>0$; Newton's method on $S(t) - 1$ from any starting point in $[6/5,5/4]$ converges quadratically. Six iterations from $t_{0} = 1.2$ give machine precision.

### 10.3 Hermitian generator of a unitary matrix

The proof of Corollary 8.4 is constructive when combined with the spectral theorem: diagonalise $U = W\operatorname{diag}(e^{i\phi_{1}},\dots,e^{i\phi_{n}})W^{*}$ with $W$ unitary and $\phi_{j} \in (-\pi,\pi]$, then $H = W\operatorname{diag}(\phi_{1},\dots,\phi_{n})W^{*}$ is Hermitian with $\exp(iH) = U$. The rotation trick of Theorem 8.3 corresponds to the freedom of shifting all $\phi_{j}$ by a common $\theta$ so that none sits at the branch cut. **Complexity:** $O(n^{3})$ via a unitary eigendecomposition (Schur form).

---

## 11. Applications and interpretation

**Calibrated phase generation.** The constant $t^{\star}$ is the unique positive parameter at which the "shift-and-log" nonlinearity applied to a purely imaginary input of magnitude $t$ produces an output of unit modulus — that is, a legitimate global phase without post-hoc renormalization. If a device implements $t \mapsto \operatorname{Log}(1+ti)$ and downstream stages require a unitary, then $t = t^{\star}$ is the unique admissible positive calibration, and Corollary 5.7 certifies it to within $5\%$ using nothing but rational arithmetic and two standard constants.

**Radius scheduling.** Theorem 6.3 says more: given any target radius $r$, there is a unique nonnegative $t$ realizing it. So the parameter $t$ is a faithful, invertible coordinate for the logarithmic radius, and a schedule $r(s)$ can be pulled back to a schedule $t(s) = R^{-1}(r(s))$ that is again continuous and monotone. This makes $R$ a well-behaved reparametrization, not merely a function with a distinguished level set.

**Robustness of the unitary output.** Theorem 7.4 removes the calibration requirement altogether at the cost of an explicit normalization: for *any* $t \neq 0$ the normalized output is unitary. The certified root is exactly the fixed point of that normalization (Proposition 7.5). In an implementation, one can therefore either calibrate to $t^{\star}$ or normalize; the theory says these agree at one point and only one.

**Where the computational content lives.** Theorems 9.2 and 9.3 together give a sharp statement about what a scalar construction can and cannot achieve. Every unitary is a phase times a special unitary; the scalar logarithmic factor supplies only the phase and, for $t \neq 0$, provably never the special-unitary part. Corollary 8.4 then identifies the correct source of that part: Hermitian generators. Any pipeline that hopes to realize a nontrivial one-qubit gate must, by these two results, invoke a non-scalar Hermitian generator.

---

## 12. Discussion

The technical heart of this work is the interplay between two very different kinds of argument. Uniqueness (Section 4) is *soft*: it needs only that each summand of $S$ is nonnegative and strictly increasing, and it yields an unconditional injectivity statement with no numerical input whatsoever. Localization (Section 5) is *hard* in the quantitative sense: every digit costs an inequality, and the true margins — $S(6/5)$ falls $3.4\%$ short of $1$, $S(5/4)$ exceeds it by $2.4\%$ — leave no room for lazy bounds.

The device that makes the hard part tractable is worth isolating as a general principle. Both $\log$ and $\arctan$ have excellent elementary two-sided rational bounds *near the identity element of the relevant structure*: the logarithm near $x = 1$ (via tangent lines), the arctangent near $y = 0$ (via $y/(1+y^{2}) \le \arctan y \le y$, whose gap is $O(y^{3})$). Away from those points the bounds degrade badly. The remedy in both cases is a **reduction identity** that transports the evaluation point back to the good region at the price of a known constant:
$$\log(2u) = \log 2 + \log u, \qquad \arctan\frac{1+y}{1-y} = \frac{\pi}{4} + \arctan y.$$
The first buys a factor of two in the argument; the second buys a rotation by $45^{\circ}$. Both are exactly the classical devices behind fast computation of $\log$ and $\pi$ — the arctangent identity is the same mechanism as Machin's formula — and here they turn a hopeless estimate into a comfortable one.

A second theme is the sharpness of the negative result in Section 9. It would be easy to read Theorem 9.3 as a limitation. It is better read as a *conservation law*: the scalar construction produces precisely the $U(1)$ component of a unitary and provably nothing more. Since the $U(1)$ component is physically unobservable — states differing by a global phase are indistinguishable — the theorem says the scalar theory is complete on its own terms and complementary to, rather than competing with, the Hermitian-generator theory of Section 8.

**Limitations.** The certified interval, while narrow, is not sharp: the true root sits at $1.22904$, so $[6/5,5/4]$ overshoots on both sides. Section 8's surjectivity theorem is stated for finite spectrum, which suffices for all matrix algebras but not for general $C^{\star}$-algebras. And the determinant–trace correspondence that would pin down exactly which Hermitian generators land in $SU(n)$ — namely $\det \exp(A) = \exp(\operatorname{tr} A)$, giving $\exp(iH) \in SU(n) \iff \operatorname{tr} H \in 2\pi\mathbb{Z}$ — is stated here but not proved; it is the most natural next target.

---

## 13. Future work

1. **Sharper certified enclosures.** Prove $t^{\star} \in [1.229, 1.2291]$. The method of Section 5 applies verbatim with higher-precision certified bounds on $\log 2$ and $\pi$ and with finer rational factorizations of $1 + t^{2}$; the obstruction is arithmetic bookkeeping, not mathematics.

2. **Transcendence of $t^{\star}$.** Conjecturally $t^{\star}$ is transcendental. It is the unique positive root of $\left(\tfrac12\log(1+t^{2})\right)^{2} + (\arctan t)^{2} = 1$, an equation mixing the logarithm and the arctangent — that is, the real and imaginary parts of one logarithm. A proof would presumably require a Schanuel-type input; unconditionally, even irrationality appears open.

3. **The determinant–trace bridge.** Prove $\det\exp(A) = \exp(\operatorname{tr} A)$ for complex matrices and deduce that a Hermitian $H$ satisfies $\exp(iH) \in SU(n)$ if and only if $\operatorname{tr} H \in 2\pi\mathbb{Z}$. This would supply the exact trace congruence class left open by Section 9.

4. **Beyond finite spectrum.** Extend Theorem 8.3 to all unitaries in a unital $C^{\star}$-algebra whose spectrum omits at least one point of the circle (immediate from the present proof, as noted in Remark 8.5), and then to arbitrary unitaries via spectral measures.

5. **Higher-dimensional analogues.** Replace the line $1 + ti$ by $1 + t N$ for a nilpotent or normal operator $N$ and study when $\|\operatorname{Log}(1 + tN)\| = 1$ in operator norm. The scalar case treated here is the one-dimensional shadow of a genuinely operator-valued question.

6. **The full arc.** Characterise the image $\{\mathrm{pu}(\operatorname{Log}(1+ti)) : t > 0\}$ as a subarc of the unit circle, with explicit endpoints; by Theorem 6.3 the radius is a coordinate on the curve, and the angle is the remaining degree of freedom.

---

## 14. Summary of results

| Result | Statement |
|---|---|
| Closed form | $R(t)^{2} = \left(\tfrac12\log(1+t^{2})\right)^{2} + (\arctan t)^{2}$, where $R(t)=\lvert \operatorname{Log}(1+ti)\rvert$ |
| Monotonicity | $R$ is strictly increasing on $[0,\infty)$ |
| Uniqueness | Exactly one $t>0$ solves $R(t) = 1$ |
| Certified interval | That root lies in $[6/5, 5/4]$; numerically $1.2290375625\ldots$ |
| Bijectivity | $R : [0,\infty)\to[0,\infty)$ is an increasing homeomorphism |
| Symmetry | $R$ is even; the full solution set is $\{\pm t^{\star}\}$ |
| Scalar unitarity | $\lvert z\rvert = 1 \implies z\cdot 1$ is unitary in any complex $*$-algebra |
| Polar normalization | $\operatorname{Log}(1+ti)/R(t)$ is unitary for all $t \neq 0$ |
| Exponential surjectivity | Every finite-spectrum unitary is $\exp(ix)$, $x$ self-adjoint; every $U \in U(n)$ is $\exp(iH)$, $H$ Hermitian |
| Determinant splitting | Every $U \in U(n)$ is a unimodular scalar times a determinant-one unitary |
| $SU(2)$ obstruction | For $t \neq 0$, $\operatorname{Log}(1+ti)I_{2}$ is never special unitary |
