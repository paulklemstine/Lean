# The Geometry of a Fading Dial: Decorrelation Certificates, Plateau Identifiability, and Rapidity Pooling

**Author:** Aristotle
**Date:** 2026-08-31

---

## Abstract

We study the mathematics forced by a single well-documented measurement: the fourth rung of a *dial ladder*, in which the rank correlation $\rho$ between an arithmetic statistic $T$ of a uniformly drawn integer and a downstream observable (*the rate*) is tracked as a function of the integer's bit length. At bit length $108$ the pooled reading is $\rho = 0.4880$ with confidence interval $[0.445, 0.534]$ — the first rung whose entire interval falls below the pre-registered validity floor $0.55$ — with a paired advantage of $+0.092$ (interval $[0.043, 0.139]$) of the dial over a count baseline, and the first rung exhibiting inter-seed heterogeneity.

We develop, in three parts, the exact mathematics that this reading licenses.

1. **Certificate geometry.** Positive semidefiniteness of the $3\times 3$ correlation matrix of dial, baseline and rate yields the bound $c \le ab + \sqrt{(1-a^2)(1-b^2)}$ on the dial–baseline correlation. We prove the exact gap identity
$$\Bigl(1-\tfrac{(a-b)^2}{2}\Bigr) - \Bigl(ab+\sqrt{(1-a^2)(1-b^2)}\Bigr) = \tfrac12\bigl(\sqrt{1-a^2}-\sqrt{1-b^2}\bigr)^2,$$
identifying the widely used advantage certificate $c \le 1-\delta^2/2$ as precisely the AM–GM relaxation of the Gram certificate, with strict domination exactly when $a^2 \ne b^2$. We give the limit form of the certificate along a converging ladder.
2. **Plateau identifiability.** For a non-increasing sequence whose decrements contract by a factor $r<1$, we prove the tail bound $s_n - s_{n+m} \le d_n/(1-r)$, convergence, and the one-rung localisation $L \le s_n \le L + d_n/(1-r)$. We then determine the attainable plateau set *exactly*: it is the closed interval $[s_0 - d_0/(1-r),\, s_0-d_0]$. At the $108$ rung this narrows the forecast to $[0.4362, 0.4621]$; the two rungs measured subsequently are scored against the coarser window, and the raw ladder is shown to be non-monotone, delimiting the hypothesis honestly.
3. **Rapidity pooling.** Fisher's $z$-transform is $\operatorname{artanh}$, i.e. rapidity: $\tanh(\operatorname{artanh}x + \operatorname{artanh}y) = (x+y)/(1+xy)$ is Einstein velocity composition, and correlations form an abelian group under it. Midpoint concavity of $\tanh$ on $[0,\infty)$, proved from the identity $\cosh(m+d)\cosh(m-d) = \cosh^2 m + \sinh^2 d$, gives $\text{mean} \le \text{pool} \le \max$, whence: heterogeneity inflates the pooled reading but cannot lift it above a floor that all seeds respect. Composition, unlike averaging, can cross the floor.

Finally we prove a **capacity bound** for families of weak dials: $k$ unit dials each correlating at least $\rho \ge 0$ with the rate and pairwise at most $c < \rho^2$ satisfy $k \le (1-c)/(\rho^2-c)$, capping an ensemble at four dials at the band floor with $c \le 0.1$.

**Keywords:** correlation geometry, Gram matrix, positive semidefiniteness, Fisher $z$-transform, rapidity, Einstein velocity addition, plateau identifiability, spherical packing.

---

## 1. The measurement and the questions it forces

### 1.1 The ladder

A statistic $T$ — an arithmetic fingerprint of a uniformly drawn integer, built from trailing-zero counts and small-prime quadratic-residue indicators — is used to predict a downstream observable, the *rate*. The quality of the dial is the pooled Spearman rank correlation between $T$ and the rate. The programme's single free knob is the bit length of the integers drawn. The recorded readings are:

| bit length | 96 | 100 | 104 | **108** | 112 | 116 | 120 |
|---|---|---|---|---|---|---|---|
| $\rho$ | 0.5739 | 0.5436 | 0.5005 | **0.4880** | 0.4621 | 0.4847 | 0.43636 |
| step | — | $-0.0303$ | $-0.0431$ | $-0.0125$ | $-0.0259$ | $+0.0226$ | $-0.0483$ |

Write $\rho_i$ for the reading at index $i$, so bit length $= 96 + 4i$.

**Definition 1.1 (Band floor).** The pre-registered validity floor is $\beta = 0.55$. A rung is *in the band* if $\rho \ge \beta$ and has *lost the band* if its entire confidence interval lies below $\beta$.

**Proposition 1.2 (Band history).** $\rho_0 \ge \beta$, and $\rho_i < \beta$ for every $1 \le i \le 6$.

*Proof.* Direct arithmetic comparison of the seven recorded rationals with $55/100$. $\square$

**Proposition 1.3 (Certified band loss at bit length 108).** The interval $[0.445, 0.534]$ satisfies: $0.534 < \beta$; the separation margin $\beta - 0.534 \ge 0.016$; and the reading $0.488$ lies inside its own interval, $0.445 \le 0.488 \le 0.534$.

*Proof.* Arithmetic. $\square$

The content of Proposition 1.3 is not that the point estimate is small — it was already small at bit lengths $104$ and, arguably, $100$ — but that this is the first rung at which *no* value in the interval reaches the floor. Earlier rungs were compatible with "the dial is in the band and we got unlucky." This one is not.

**Proposition 1.4 (Deceleration).** The three steps into rungs $1$, $2$, $3$ are all negative, and the step into rung $3$ is strictly smaller in magnitude than each of the two preceding steps:
$$\rho_2 - \rho_3 = 0.0125 \;<\; \rho_1-\rho_2 = 0.0431, \qquad \rho_2 - \rho_3 \;<\; \rho_0-\rho_1 = 0.0303.$$

*Proof.* Arithmetic. $\square$

### 1.2 The three questions

The $108$ rung is distinguished in three ways, and each raises a precise mathematical question.

- **A paired advantage.** The dial's correlation with the rate, $a = 0.488$, exceeds the count baseline's, $b = 0.396$, by $\delta = 0.092$ with interval $[0.043, 0.139]$. A large advantage forces the dial and the baseline to be non-redundant. *What is the sharpest certificate available, and how does the standard one compare?* (Section 3.)
- **A decelerating fade.** Proposition 1.4. *What, quantitatively, does deceleration alone determine about the endpoint of the fade?* (Section 4.)
- **Seed heterogeneity.** This is the first rung whose independent runs disagree. *Can heterogeneity manufacture a sub-floor pooled value that individual seeds do not support — or conversely, can honest aggregation rescue the band?* (Section 5.)

Section 6 asks whether an *ensemble* of sub-floor dials can re-enter the band, and answers with a packing bound.

---

## 2. Correlations as spherical data

All of what follows rests on one identification.

**Definition 2.1 (Correlation geometry).** Standardise each variable to mean zero and unit variance. In the resulting inner-product space, correlation *is* the inner product of unit vectors. Given three standardised variables — dial $T$, baseline $N$, rate $R$ — write
$$a = \operatorname{corr}(T,R), \qquad b = \operatorname{corr}(N,R), \qquad c = \operatorname{corr}(T,N),$$
and define the **correlation angle** $\theta(\rho) = \arccos\rho \in [0,\pi]$.

**Definition 2.2 (Gram positivity).** The triple $(a,b,c)$ is *admissible* if its $3\times 3$ correlation matrix
$$G = \begin{pmatrix} 1 & c & a \\ c & 1 & b \\ a & b & 1\end{pmatrix}$$
is positive semidefinite. Since the leading minors are automatically nonnegative when $|a|,|b|,|c| \le 1$, admissibility reduces to the scalar determinant condition
$$\det G = 1 + 2abc - a^2 - b^2 - c^2 \;\ge\; 0. \tag{$\star$}$$

**Lemma 2.3 (Scalar form of admissibility).** If $(\star)$ holds then $(c-ab)^2 \le (1-a^2)(1-b^2)$.

*Proof.* Expand: $(1-a^2)(1-b^2) - (c-ab)^2 = 1 - a^2 - b^2 + a^2b^2 - c^2 + 2abc - a^2b^2 = \det G$. The claim is $(\star)$ rewritten. $\square$

**Theorem 2.4 (Two-sided Gram bound).** Under $(\star)$,
$$ab - \sqrt{(1-a^2)(1-b^2)} \;\le\; c \;\le\; ab + \sqrt{(1-a^2)(1-b^2)}.$$

*Proof.* Lemma 2.3 gives $|c-ab| \le \sqrt{(1-a^2)(1-b^2)}$ by monotonicity of the square root; unfold the absolute value. $\square$

Writing $a = \cos\alpha$, $b = \cos\beta$, the bound reads $c \le \cos\alpha\cos\beta - \sin\alpha\sin\beta \cdot(-1) = \cos(\alpha-\beta)$ on the upper side and $c \ge \cos(\alpha+\beta)$ on the lower — the cosine addition formulae. Hence:

**Theorem 2.5 (Triangle inequality for the correlation angle).** If $|a| \le 1$, $|b| \le 1$ and $(\star)$ holds, then
$$\theta(c) \;\le\; \theta(a) + \theta(b).$$

*Proof sketch.* If $\theta(a)+\theta(b) \ge \pi$ the claim is trivial since $\theta(c) \le \pi$. Otherwise, $\cos(\theta(a)+\theta(b)) = ab - \sqrt{(1-a^2)(1-b^2)} \le c = \cos\theta(c)$, using $\sin\arccos t = \sqrt{1-t^2}$ and the lower Gram bound. Both $\theta(a)+\theta(b)$ and $\theta(c)$ lie in $[0,\pi]$, where cosine is strictly decreasing; applying strict antitonicity contrapositively converts the cosine inequality into $\theta(c) \le \theta(a)+\theta(b)$. $\square$

So $\arccos\circ\operatorname{corr}$ is a genuine metric radius: correlation data are spherical data. Two immediate consequences frame the whole paper.

**Corollary 2.6 (The band floor is a spherical cap).** The set of dials in the band is the cap of angular radius $\theta(0.55)$ around the rate. Since $\arccos$ is strictly decreasing, $\theta(0.55) < \theta(0.488)$: the $108$ dial lies strictly outside the cap.

The fade is therefore literally a trajectory: as bit length increases, the dial migrates away from the rate on the correlation sphere, and "losing the band" is the moment it exits the cap.

---

## 3. Decorrelation certificates and the exact AM–GM gap

### 3.1 Two certificates

The dial is only interesting if it is not a repackaging of the baseline, i.e. if $c$ is bounded away from $1$. Two bounds are available.

**Definition 3.1.** For admissible $(a,b,c)$ set
$$\mathrm{Gram}(a,b) = ab + \sqrt{(1-a^2)(1-b^2)}, \qquad \mathrm{Adv}(a,b) = 1 - \frac{(a-b)^2}{2}.$$
Theorem 2.4 gives $c \le \mathrm{Gram}(a,b)$; the *advantage certificate* in standard use is $c \le \mathrm{Adv}(a,b)$.

### 3.2 The gap is a perfect square

**Theorem 3.2 (Exact gap identity).** For all $a, b$ with $|a| \le 1$ and $|b| \le 1$,
$$\mathrm{Adv}(a,b) - \mathrm{Gram}(a,b) \;=\; \frac{\bigl(\sqrt{1-a^2} - \sqrt{1-b^2}\bigr)^2}{2}.$$

*Proof.* Put $p = \sqrt{1-a^2}$, $q = \sqrt{1-b^2}$, so $p^2 = 1-a^2$, $q^2 = 1-b^2$ and, since both radicands are nonnegative, $\sqrt{(1-a^2)(1-b^2)} = pq$. Then
$$\mathrm{Adv} - \mathrm{Gram} = 1 - \tfrac12(a-b)^2 - ab - pq = 1 - \tfrac12 a^2 - \tfrac12 b^2 - pq = \tfrac12\bigl(p^2 + q^2\bigr) - pq = \tfrac12 (p-q)^2. \qquad \square$$

The quantities $p = \sin\theta(a)$ and $q = \sin\theta(b)$ are the *residual lengths*: the components of dial and baseline orthogonal to the rate. The identity says the advantage certificate is obtained from the Gram certificate by replacing the geometric mean $pq$ of the residual variances by their arithmetic mean $(p^2+q^2)/2$. It is exactly an AM–GM relaxation, and the loss is the AM–GM defect.

**Corollary 3.3 (Domination).** $\mathrm{Gram}(a,b) \le \mathrm{Adv}(a,b)$ always; hence $c \le \mathrm{Adv}(a,b)$ follows from $(\star)$ — the advantage certificate is a consequence of the Gram certificate, not an independent fact.

**Theorem 3.4 (Strict domination).** If additionally $a^2 \ne b^2$, then $\mathrm{Gram}(a,b) < \mathrm{Adv}(a,b)$ strictly.

*Proof.* $a^2 \ne b^2$ forces $p \ne q$ (else squaring gives $1-a^2 = 1-b^2$), so $(p-q)^2 > 0$; apply Theorem 3.2. $\square$

This is exactly the operative regime: a certified nonzero advantage means $a \ne b$, and with both positive that means $a^2 \ne b^2$. **Whenever the advantage measurement is informative, the certificate derived from it is strictly suboptimal.**

### 3.3 The 108 instance

**Theorem 3.5 (Decorrelation certificate at bit length 108).** With $a = 0.488$, $b = 0.396$, any admissible $c$ satisfies
$$c \le 0.9949, \qquad\text{while}\qquad \mathrm{Adv}(0.488, 0.396) = 0.995768 > 0.9949 .$$

*Proof.* $1-a^2 = 0.761856$ and $1-b^2 = 0.843184$, whose product is $0.6423847\ldots \le 0.8016^2$; hence $\sqrt{(1-a^2)(1-b^2)} \le 0.8016$ and $\mathrm{Gram} \le ab + 0.8016 = 0.193248 + 0.8016 < 0.9949$. The second claim is $1 - 0.092^2/2 = 0.995768$. $\square$

The improvement is modest in absolute terms and structurally decisive: the residual-length gap here is $\tfrac12(\sqrt{0.761856}-\sqrt{0.843184})^2 = 0.0010309$, and the exact Gram bound is $0.9947371$, entirely accounted for by Theorem 3.2.

### 3.4 The limit form

A single rung certifies a single $c$. A converging ladder certifies a limit.

**Theorem 3.6 (Limit decorrelation).** Let $a_n \to A$, $b_n \to B$, $c_n \to C$ with $|a_n| \le 1$, $|b_n| \le 1$ and $(\star)$ holding at every $n$. Then
$$C \;\le\; 1 - \frac{(A-B)^2}{2}.$$

*Proof.* By Corollary 3.3, $c_n \le 1 - (a_n-b_n)^2/2$ for every $n$. The right-hand side converges to $1-(A-B)^2/2$ by continuity of the arithmetic operations, and the left to $C$; pass to the limit in the inequality. $\square$

**Corollary 3.7.** If the advantage persists along the plateau at the conservative edge of the measured interval, $A - B \ge 0.043$, then $C \le 0.9990755$.

Thus a *persistent* advantage — even the weakest advantage compatible with the $108$ interval — yields a *permanent* decorrelation guarantee: the dial can never become a relabelling of the count baseline.

---

## 4. Deceleration, plateaus, and exact identifiability

### 4.1 The model class

**Definition 4.1 (Decelerating fade).** A sequence $s : \mathbb{N} \to \mathbb{R}$ is a *fade with ratio $r$* ($r<1$) if it is non-increasing, $s_{n+1} \le s_n$ for all $n$, and its decrements contract:
$$s_{n+1} - s_{n+2} \;\le\; r\,(s_n - s_{n+1}) \quad \text{for all } n.$$
Write $d_n = s_n - s_{n+1} \ge 0$ for the current step.

### 4.2 Tail control and localisation

**Theorem 4.2 (Tail bound).** For a fade with ratio $r < 1$ and all $n, m$,
$$s_n - s_{n+m} \;\le\; \frac{d_n}{1-r}.$$

*Proof.* Induction on $m$, generalising over $n$. For $m=0$ the left side is $0$ and the right side is nonnegative. For the step, the inductive hypothesis at $n+1$ gives $s_{n+1} - s_{n+1+m} \le d_{n+1}/(1-r)$, and $d_{n+1} \le r\,d_n$ by deceleration; adding $d_n$ and using $d_n + r d_n/(1-r) = d_n/(1-r)$ closes the induction. $\square$

**Theorem 4.3 (Plateau localisation from one rung).** A fade with ratio $r<1$ converges to some $L$, and for every $n$
$$L \le s_n \quad\text{and}\quad s_n - L \le \frac{d_n}{1-r}.$$

*Proof.* $s$ is antitone; Theorem 4.2 with $n=0$ shows $s_m \ge s_0 - d_0/(1-r)$ for all $m$, so $s$ is bounded below and converges to $L = \inf_i s_i$. The bound $L \le s_n$ is the infimum property. For the other side, $s_n - d_n/(1-r) \le s_m$ for every $m$: for $m \ge n$ this is Theorem 4.2, and for $m < n$ it follows from $s_n \le s_m$ and nonnegativity of $d_n/(1-r)$. Taking the infimum over $m$ gives $s_n - d_n/(1-r) \le L$. $\square$

This is the theorem behind "the fade decelerates toward a plateau": *one* rung and its immediate successor, plus a contraction bound, localise the endpoint of an infinite process to an interval of length $d_n/(1-r)$.

### 4.3 The 108 window and its retrodictive score

**Theorem 4.4 (The 108 plateau window).** Index $0$ at bit length $108$ and $1$ at $112$. Any fade with ratio $r \le 1/2$ satisfying $s_0 = 0.488$ and $s_1 = 0.4621$ converges to a limit $L$ with
$$0.4362 \;\le\; L \;\le\; 0.488, \qquad \text{in particular } L \le 0.55 - 0.062.$$

*Proof.* $d_0 = 0.0259$ and $d_0/(1-r) \le 0.0259/(1/2) = 0.0518$; substitute into Theorem 4.3 at $n = 0$. $\square$

The whole window lies at least $0.062$ below the floor: **for the entire model class, the band loss certified at $108$ is permanent.**

**Proposition 4.5 (Scoring the forecast).** Both rungs measured *after* the window was licensed — $0.4847$ at bit length $116$ and $0.43636$ at $120$ — lie in $[0.4362, 0.488]$, and $0.43636$ clears the lower edge by $1.6 \times 10^{-4}$.

*Proof.* Arithmetic. $\square$

A window that is respected only because it is wide would be worthless; the $120$ rung sits $0.00016$ inside it, so the forecast is tight rather than vacuous.

**Proposition 4.6 (The honest boundary: the ladder is not antitone).** It is *false* that $\rho_{i+1} \le \rho_i$ for all $i \le 5$: the rung at $116$ rebounds above the rung at $112$ ($0.4847 > 0.4621$).

*Proof.* The single index $i = 4$ refutes the universal statement. $\square$

Proposition 4.6 is essential to reading the rest honestly. The hypothesis of Definition 4.1 is *not* satisfied by the raw ladder. Theorems 4.3–4.4 apply to the fade component of the ladder, with the $116$ rebound as residual. Claiming more would be a misstatement of what the data support.

### 4.4 Exact identifiability of the plateau

Theorem 4.3 is an inclusion. Is it sharp? Both edges can be settled exactly.

**Definition 4.7 (Geometric fade).** For $s_0, d_0 \in \mathbb{R}$ and $0 \le r < 1$ put
$$g_n \;=\; \Bigl(s_0 - \frac{d_0}{1-r}\Bigr) + \frac{d_0}{1-r}\, r^n .$$

**Theorem 4.8 (The lower edge is attained).** For $0 \le r < 1$ and $d_0 \ge 0$: $g_0 = s_0$, $g_1 = s_0 - d_0$, the sequence is non-increasing, its decrements satisfy $g_{n+1}-g_{n+2} = r\,(g_n - g_{n+1})$ *with equality*, and $g_n \to s_0 - d_0/(1-r)$.

*Proof.* Direct computation: $g_n - g_{n+1} = \frac{d_0}{1-r}r^n(1-r) = d_0 r^n \ge 0$, from which monotonicity, the exact contraction and the two initial values follow. Convergence is $r^n \to 0$ for $|r|<1$. $\square$

**Corollary 4.9.** At $s_0 = 0.488$, $d_0 = 0.0259$, $r = 1/2$, the geometric fade converges to exactly $0.4362$: the lower edge of Theorem 4.4 is realised, not merely a bound.

The upper edge, by contrast, is *never* attained: the first step is already spent.

**Theorem 4.10 (Plateau membership).** If $s$ is a fade with ratio $r<1$ converging to $L$, then
$$s_0 - \frac{s_0-s_1}{1-r} \;\le\; L \;\le\; s_1 .$$

*Proof.* The left inequality is Theorem 4.3 at $n = 0$ together with uniqueness of limits. For the right, $s_n \le s_1$ eventually (indeed for all $n \ge 1$ by antitonicity), and limits preserve non-strict inequalities. $\square$

**Theorem 4.11 (Exact plateau set).** Fix $s_0 \in \mathbb{R}$, $d_0 > 0$ and $r < 1$. A real number $L$ is the limit of some fade with ratio $r$, initial value $s_0$ and first step exactly $d_0$ **if and only if**
$$s_0 - \frac{d_0}{1-r} \;\le\; L \;\le\; s_0 - d_0 .$$

*Proof.* ($\Rightarrow$) Theorem 4.10 with $s_1 = s_0 - d_0$. ($\Leftarrow$) Given such an $L$, put $D = s_0 - L$, so $d_0 \le D \le d_0/(1-r)$ and $D > 0$. Set $q = 1 - d_0/D$. Then $0 \le q$ (as $d_0 \le D$), $q < 1$ (as $d_0/D > 0$), and $q \le r$: indeed $D \le d_0/(1-r)$ gives $(1-r)D \le d_0$, i.e. $1 - d_0/D \le r$. The geometric fade $g$ of Definition 4.7 with ratio $q$ has $g_0 = s_0$, $g_1 = s_0 - d_0$, exact contraction ratio $q \le r$ (hence *at most* $r$, as required, since decrements are nonnegative), and limit $s_0 - d_0/(1-q) = s_0 - D = L$. $\square$

The attainable set is a closed interval of length
$$\frac{d_0}{1-r} - d_0 \;=\; d_0\,\frac{r}{1-r}.$$

**Corollary 4.12 (Corrected 108 window).** With $s_0 = 0.488$, $d_0 = 0.0259$, $r \le 1/2$, the attainable plateaus are exactly $[0.4362, 0.4621]$, an interval of length $0.0259$. The measured $120$ rung ($0.43636$) lies inside it; the measured $116$ rung ($0.4847$) does not — which is precisely the non-monotone rebound of Proposition 4.6.

**Methodological consequence.** One rung plus a ratio bound *cannot* identify the plateau; the residual uncertainty $d_0\,r/(1-r)$ is irreducible. Sharpening the forecast requires a second, independent estimate of the contraction ratio, not more precision on a single rung.

---

## 5. Rapidity pooling and seed heterogeneity

### 5.1 Fisher's $z$ is rapidity

**Definition 5.1.** For $x, y \in (-1,1)$ define *composition* and *pooling*:
$$x \oplus y = \frac{x+y}{1+xy}, \qquad P_2(x,y) = \tanh\!\Bigl(\frac{\operatorname{artanh}x + \operatorname{artanh}y}{2}\Bigr), \qquad P_3(x,y,z) = \tanh\!\Bigl(\frac{\operatorname{artanh}x + \operatorname{artanh}y + \operatorname{artanh}z}{3}\Bigr).$$
$P_2, P_3$ are the standard Fisher-$z$ pooled estimators of a common correlation from independent seeds.

**Theorem 5.2 (Composition is Einstein velocity addition).** For $x, y \in (-1,1)$,
$$\tanh\bigl(\operatorname{artanh}x + \operatorname{artanh}y\bigr) \;=\; \frac{x+y}{1+xy} \;=\; x \oplus y .$$

*Proof.* $\tanh(u+v) = \dfrac{\tanh u + \tanh v}{1 + \tanh u \tanh v}$; substitute $u = \operatorname{artanh}x$, $v = \operatorname{artanh}y$ and use $\tanh\operatorname{artanh}t = t$ on $(-1,1)$. $\square$

This is the relativistic composition law for collinear velocities with $c = 1$, and $\operatorname{artanh}$ is the rapidity map. Correlations are velocities; Fisher's $z$ is rapidity; and the arithmetic of pooling is the arithmetic of boosts.

**Theorem 5.3 (No superluminal pooling).** $x, y \in (-1,1) \implies x\oplus y \in (-1,1)$.

*Proof.* Immediate from Theorem 5.2, since $\tanh$ maps $\mathbb{R}$ into $(-1,1)$. $\square$

**Theorem 5.4 (Abelian group law).** On $(-1,1)$, $\oplus$ is commutative and associative, has identity $0$, and inverse $x \mapsto -x$; $\operatorname{artanh}$ is a group isomorphism onto $(\mathbb{R},+)$.

*Proof sketch.* Commutativity and the identity/inverse laws are direct computations on $(x+y)/(1+xy)$. Associativity is proved by transport: $\operatorname{artanh}(x\oplus y) = \operatorname{artanh}x + \operatorname{artanh}y$ by Theorem 5.2 and $\operatorname{artanh}\tanh = \mathrm{id}$, so both bracketings map to $\operatorname{artanh}x + \operatorname{artanh}y + \operatorname{artanh}z$ under an injective map. $\square$

### 5.2 Concavity: heterogeneity inflates

**Theorem 5.5 (Midpoint concavity of $\tanh$ on $[0,\infty)$).** For $m \ge 0$ and any $d$,
$$\tanh(m+d) + \tanh(m-d) \;\le\; 2\tanh m,$$
with strict inequality when $m > 0$ and $d \ne 0$.

*Proof.* Two exact hyperbolic identities:
$$\cosh(m+d)\cosh(m-d) = \cosh^2 m + \sinh^2 d, \qquad \sinh(m+d)\cosh(m-d) + \sinh(m-d)\cosh(m+d) = 2\sinh m\cosh m .$$
Hence
$$\tanh(m+d)+\tanh(m-d) = \frac{2\sinh m \cosh m}{\cosh^2 m + \sinh^2 d}, \qquad 2\tanh m = \frac{2\sinh m\cosh m}{\cosh^2 m}.$$
The two expressions share a nonnegative numerator; the left denominator exceeds the right by $\sinh^2 d \ge 0$, strictly when $d \ne 0$. For $m>0$ the numerator is strictly positive, giving strictness. $\square$

The surplus term $\sinh^2 d$ *is* the effect of spread: displacement in rapidity always costs correlation, quadratically at small $d$.

**Corollary 5.6 (Two-point and three-point forms).** For $u, v, w \ge 0$,
$$\tanh u + \tanh v \le 2\tanh\tfrac{u+v}{2}, \qquad \tanh u + \tanh v + \tanh w \le 3\tanh\tfrac{u+v+w}{3},$$
with strictness in the two-point form whenever $u \ne v$.

*Proof.* The two-point form is Theorem 5.5 with $m = (u+v)/2$, $d = (u-v)/2$. The three-point form is the classical "adjoin the mean as a fourth point" argument: with $m = (u+v+w)/3$, apply the two-point form to $(u,v)$, to $(w,m)$, and to the two resulting midpoints, whose average is again $m$; adding the three inequalities cancels the intermediate terms. $\square$

**Theorem 5.7 (Heterogeneity inflates the pooled estimate).** For $x, y, z \in [0,1)$,
$$\frac{x+y}{2} \le P_2(x,y), \qquad \frac{x+y+z}{3} \le P_3(x,y,z),$$
and the first inequality is *strict* whenever $x \ne y$.

*Proof.* Apply Corollary 5.6 with $u = \operatorname{artanh}x$ etc., which are nonnegative for nonnegative arguments, and use $\tanh\operatorname{artanh}t = t$. $\square$

So the Fisher-pooled reading is *optimistic*: it is biased upward relative to the arithmetic mean of the seeds, strictly so exactly when the seeds disagree. The $108$ rung, being the first heterogeneous rung, is the first whose pooled value is strictly above its seed average. This makes the band loss *harder* to explain away, not easier: the pooling convention was already working in the band's favour.

### 5.3 The floor cannot be crossed by averaging

**Theorem 5.8 (Pooling never exceeds the largest seed).** For $x,y,z \in (-1,1)$,
$$P_3(x,y,z) \;\le\; \max\{x,y,z\}.$$

*Proof.* Let $M = \max\{x,y,z\} \in (-1,1)$. As $\operatorname{artanh}$ is increasing on $(-1,1)$, each $\operatorname{artanh}$ of a seed is at most $\operatorname{artanh}M$, hence so is their mean; $\tanh$ is increasing, so $P_3 \le \tanh\operatorname{artanh}M = M$. $\square$

**Theorem 5.9 (Heterogeneity cannot rescue the band).** If $x,y,z \in [0,1)$ and $x,y,z < 0.55$, then
$$\frac{x+y+z}{3} \;\le\; P_3(x,y,z) \;<\; 0.55 .$$

*Proof.* Theorem 5.7 for the left, Theorem 5.8 plus $\max\{x,y,z\} < 0.55$ for the right. $\square$

The "pooling artefact" explanation of the $108$ band loss is therefore closed: no configuration of sub-floor seeds pools to a band-compliant value, however heterogeneous.

### 5.4 The boundary: composition is not averaging

**Theorem 5.10 (Composition can cross the floor).** $0.4 < 0.55$, yet
$$0.4 \oplus 0.4 = \frac{0.8}{1.16} = 0.6896\ldots > 0.55, \qquad\text{while}\qquad P_2(0.4, 0.4) = 0.4 < 0.55 .$$

*Proof.* The composition value is arithmetic; $P_2(x,x) = \tanh\operatorname{artanh}x = x$. $\square$

This delimits Theorem 5.9 exactly. *Aggregating* independent estimates of one quantity (averaging in rapidity) is floor-preserving; *composing* independent effects (adding rapidities) is a boost and is not. The distinction is the same as that between averaging velocity measurements and chaining Lorentz boosts, and confusing them would be the natural way to produce a spurious band re-entry.

---

## 6. Can an ensemble of weak dials re-enter the band?

The final escape route: if one dial is below the floor, combine several. The correlation sphere bounds the strategy before it is attempted.

**Theorem 6.1 (Dial family capacity).** Let $u$ be a unit vector (the standardised rate) in a real inner-product space and $v_1,\dots,v_k$ unit vectors (the standardised dials), $k \ge 1$. Suppose
$$\langle v_i, u\rangle \ge \rho \ \ \text{for all } i, \qquad \langle v_i, v_j\rangle \le c \ \ \text{for all } i \ne j,$$
with $\rho \ge 0$ and $c < \rho^2$. Then
$$k \;\le\; \frac{1-c}{\rho^2 - c}.$$

*Proof.* Let $S = \sum_i v_i$. Expanding, $\|S\|^2 = \sum_{i,j}\langle v_i,v_j\rangle$. Each term is at most $c$ off the diagonal and exactly $1$ on it, so each row sums to at most $kc + (1-c)$ and $\|S\|^2 \le k\bigl(kc + (1-c)\bigr)$. On the other hand $\langle S,u\rangle = \sum_i \langle v_i,u\rangle \ge k\rho$, and Cauchy–Schwarz with $\|u\|=1$ gives $\langle S,u\rangle \le \|S\|$. Hence $k\rho \le \|S\|$, and squaring (both sides nonnegative) $k^2\rho^2 \le \|S\|^2 \le k^2 c + k(1-c)$. Dividing by $k > 0$ yields $k(\rho^2 - c) \le 1-c$, and $\rho^2 - c > 0$ permits division. $\square$

**Corollary 6.2 (Capacity at the band floor).** If $k$ unit dials each correlate at least $0.55$ with the rate and pairwise at most $0.1$, then $k \le 4$.

*Proof.* $\dfrac{1-0.1}{0.55^2-0.1} = \dfrac{0.9}{0.2025} = 4.444\ldots$, so $k < 5$ and $k \le 4$. $\square$

This is the packing companion of Theorem 2.5: dials at a fixed angle from the rate live in a spherical cap, and a cap admits only boundedly many near-orthogonal directions. Note the honest limitation: at the *measured* $108$ configuration ($\rho = 0.488$ with a certified pairwise bound only as strong as $c \le 0.9949$) the hypothesis $c < \rho^2$ fails and the bound is vacuous. Capacity bites only when the dials are genuinely weakly aligned — precisely the regime an ensemble strategy needs in order to work at all.

---

## 7. Algorithms

The results support four directly implementable computations.

**Algorithm A — Certificate comparison.** *Input:* $a, b \in [-1,1]$. *Output:* $\mathrm{Gram}$, $\mathrm{Adv}$, and their gap. Compute $p = \sqrt{1-a^2}$, $q = \sqrt{1-b^2}$; return $ab + pq$, $1-(a-b)^2/2$, and $(p-q)^2/2$, verifying the identity of Theorem 3.2 to machine precision. Cost $O(1)$.

**Algorithm B — Plateau window.** *Input:* consecutive rungs $s_0 > s_1$ and a ratio bound $r < 1$. *Output:* the exact attainable plateau interval $[s_0 - d_0/(1-r),\, s_0 - d_0]$ with $d_0 = s_0 - s_1$ (Theorem 4.11), together with the coarser one-rung localisation $[s_0 - d_0/(1-r),\, s_0]$ (Theorem 4.3) for scoring historical forecasts. Cost $O(1)$; membership tests for later rungs cost $O(1)$ each.

**Algorithm C — Rapidity pooling.** *Input:* seeds $x_1,\dots,x_m \in (-1,1)$. *Output:* $\tanh\bigl(\frac1m\sum_i \operatorname{artanh}x_i\bigr)$, plus the certified sandwich $\mathrm{mean} \le \mathrm{pool} \le \max$. Cost $O(m)$. The same routine, with a *sum* instead of a mean, computes iterated Einstein composition and demonstrates the floor-crossing dichotomy of Theorem 5.10.

**Algorithm D — Ensemble capacity.** *Input:* target $\rho$, pairwise ceiling $c$. *Output:* $\lfloor (1-c)/(\rho^2-c)\rfloor$ if $c < \rho^2$, else "unbounded/vacuous". Cost $O(1)$. A randomised companion samples unit vectors in a cap and greedily maximises a family with the given pairwise ceiling, confirming the bound empirically.

---

## 8. Discussion

**What the geometry buys.** Every result above is a consequence of one identification — correlations are inner products of unit vectors — and its two corollaries: positive semidefiniteness of the Gram matrix, and the metric structure of $\arccos$. The advantage certificate was, before this analysis, an ad hoc inequality; Theorem 3.2 exhibits it as a relaxation of the correct spherical bound with an exactly computable defect, and Theorem 3.4 says the defect is always positive in the operative regime. The band floor was a threshold on a scalar; Corollary 2.6 makes it a spherical cap, and Theorem 6.1 turns the cap into a packing constraint on ensembles.

**What the deceleration analysis buys.** Reading a decelerating step as "we are approaching a plateau" is standard practice and usually informal. Theorem 4.3 makes it a theorem with an explicit error term, and Theorem 4.11 makes it *sharp*: the attainable plateau set is an interval of length $d_0 r/(1-r)$, no shorter, and every point of it is realised by an explicit geometric fade. This is a genuinely negative methodological finding — the residual uncertainty is structural, not statistical, so it cannot be reduced by measuring the same rung more precisely. It also produced a falsifiable forecast that the two subsequently measured rungs did in fact satisfy, one of them by $1.6\times 10^{-4}$.

**What the relativistic analogy buys.** The identification of Fisher's $z$ with rapidity is more than an aesthetic remark. It supplies the group law (Theorem 5.4), the automatic admissibility of composed values (Theorem 5.3), and — via concavity — the pooling sandwich. It also immediately explains the dichotomy of Theorem 5.10: averaging in rapidity is a barycentre and stays between the extreme seeds, while adding rapidities is a boost and escapes them. Any claim that heterogeneity "explains away" a sub-floor pooled reading must therefore be a claim about composition, and composition is not what pooling does.

**Limitations, stated plainly.** The seven-rung ladder is not monotone (Proposition 4.6), so the deceleration hypothesis applies to a fade *component* of the data and not to the raw sequence; the $116$ rebound is outside the sharpened window of Corollary 4.12 and is a genuine residual, not a nuisance to be assumed away. The capacity bound is vacuous at the measured configuration and applies only to a hypothetical family of weakly aligned dials. The Gram results assume the reported values are correlations of a genuine joint distribution, i.e. that $(\star)$ holds; rank correlations on tied data can violate this, and the corresponding tie geometry is not treated here. Finally, the numerical instances use the reported point estimates; propagating interval uncertainty through the certificates is straightforward but would widen every conclusion.

---

## 9. Future directions

Five questions remain open, ordered roughly by how close they are to a proof.

**1. Curvature obstruction to band re-entry.** Let $\theta_n = \arccos\rho_n$ be the correlation angle of the ladder. Conjecture: angular deceleration $\theta_{n+2} - 2\theta_{n+1} + \theta_n \le 0$ from bit length $108$ onwards forces $\theta_n$ to converge with $\lim\theta_n \ge \arccos 0.488$; in particular no later rung re-enters the $0.55$ cap, and the $116$ rebound is bounded by $\theta_{112}-\theta_{116} \le \theta_{108}-\theta_{112}$. The key insight is that the triangle inequality (Theorem 2.5) makes $\arccos\rho$ a genuine metric radius, so deceleration should be imposed on the *angle*, where it is a convexity statement, and not on the raw correlation, where non-monotonicity of the measured ladder (Proposition 4.6) already falsifies it. The correlation-space model is provably falsified by the data; the angle-space version is not, and the seven measured rungs already decide it numerically.

**2. Sharp AM–GM defect along a ladder.** Theorem 3.2 computes the certificate gap pointwise. Along a ladder with converging $a_n, b_n$ the accumulated defect $\sum_n \tfrac12(\sqrt{1-a_n^2}-\sqrt{1-b_n^2})^2$ should be finite and computable in closed form for a geometric fade, quantifying the total cost of using the relaxed certificate over the whole programme.

**3. Two-ratio identifiability.** Theorem 4.11 shows one rung plus a ratio bound leaves an interval of length $d_0 r/(1-r)$. The natural sequel: determine the exact attainable plateau set given *two* consecutive step ratios, and the minimal number of rungs needed to identify the plateau to a prescribed tolerance.

**4. Tie geometry and Gram violation.** Spearman correlations on tied data need not come from a joint Gaussian, and the Gram condition $(\star)$ can fail. Characterise the tie configurations for which the measured triples remain admissible, and give a corrected certificate for those that do not.

**5. Optimal weak-dial ensembles.** Theorem 6.1 bounds the size of a weakly aligned family. The companion question is constructive: given a target correlation with the rate and a pairwise ceiling, what is the maximal correlation achievable by the *best weighted* combination, and is the capacity bound attained by an equiangular configuration in the cap?

---

## 10. Conclusion

A single measurement — a rank correlation of $0.4880$ with interval $[0.445, 0.534]$, entirely below a floor of $0.55$ — has an exact mathematical shadow. The certificate the programme used to argue that the dial is not a repackaged baseline is an arithmetic-mean–geometric-mean relaxation of a spherical bound, and the relaxation costs exactly $\tfrac12(\sqrt{1-a^2}-\sqrt{1-b^2})^2$, always positive when the two predictors differ in strength. The deceleration in the fade localises its endpoint to an interval that is now known exactly, $[0.4362, 0.4621]$, whose length $d_0 r/(1-r)$ is irreducible from a single rung. And the heterogeneity between runs, which pushes the pooled reading upward, still cannot lift it above a floor that no individual run reaches — because pooling is a barycentre in rapidity, bounded below by the mean and above by the maximum.

The dial left the band, and every route back — a favourable pooling convention, a temporary dip, an ensemble of weak dials — is closed by geometry.
