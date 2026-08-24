# The Geometry of Advantage: Chord Laws, Correlated-Family Capacity, and the Failure of Budget Averaging

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We develop a self-contained geometric theory of *advantage* — the excess correlation of one
statistic over a competing baseline against a shared outcome — and of the *capacity* of a
family of mutually correlated statistics to read a common response. Three layers are
established, together with one refutation.

At the pairwise layer we show that the classical three-variable Gram inequality
$a^2 + b^2 + c^2 \le 1 + 2abc$ is *equivalent*, via a polynomial identity, to the **chord law**
$(a-b)^2 \le (1-c)(1+c-2ab)$. Advantage is therefore not an additional datum but Gram
positivity read along the difference direction. Weakening the chord law yields the
**decorrelation budget** $\alpha^2 \le 2(1-c)(1-ab)$: an advantage of size $\alpha$ at
reading product $ab \le M < 1$ forces mutual correlation $c \le 1 - \alpha^2/(2(1-M))$. The
bound is sharp: when the response lies in the plane of the two statistics the chord law is
an identity. The associated chord distance $\sqrt{2-2\rho}$ is a metric, converting the
pairwise bound into a transitivity law for correlation.

At the family layer we prove the **capacity law** $k\rho^2 \le 1 + (k-1)\gamma$ for $k$ unit
statistics with pairwise correlations at most $\gamma$ all reading at least $\rho$ against a
unit response. It interpolates between the orthonormal ceiling $k\rho^2 \le 1$ ($\gamma = 0$)
and the pairwise parity ceiling $2\rho^2 \le 1 + c$ ($k=2$), and is attained on the whole
$(k,\gamma)$ sheet by the equidistant family. We give a complete **classification of
extremisers**: saturation forces every off-diagonal Gram entry to equal $\gamma$, every
reading to equal $\rho$, and the response to be the normalised sum $(k\rho)^{-1}\sum_i u_i$;
the configuration requires ambient dimension exactly $k$ and is unique there up to an
orthogonal change of frame. Capacity is a **staircase**: admissibility of size $k$ is the
threshold condition $\gamma \ge (k\rho^2-1)/(k-1)$, thresholds strictly increase, admissible
sizes form an initial segment, and the capacity equals $\lfloor (1-\gamma)/(\rho^2-\gamma)\rfloor$.
All of these are estimates of one **master law** $(k\rho)^2 \le \mathbf{1}^{\mathsf T} G\mathbf{1}$,
valid with no hypothesis on normalisation or correlation.

At the replication layer we prove rigidity results for records of per-replication
advantages constrained by published summary statistics, and then examine the natural
conjecture that per-replication budgets *average*: $\sum_i \alpha_i^2 \le 2(1-\bar c)(r - \sum_i a_ib_i)$.
We show this conjecture is **false** by explicit counterexample ($1.96 > 1.49$), identify the
missing hypothesis, and repair it in two ways — unconditionally by replacing the mean with
the minimum, and conditionally by a Chebyshev antivariation hypothesis under which the
conjecture holds verbatim. The failure occurs precisely in the *monovariant* regime typical
of bimodal replication records, giving a structural reason to distrust pooled advantage
estimates in exactly the setting where pooling is most tempting.

**Keywords:** correlation geometry, Gram matrix, Cauchy–Schwarz, equiangular families,
capacity, Chebyshev sum inequality, order statistics, meta-analysis.

---

## 1. Motivation and setting

### 1.1 The empirical record

The work is motivated by a concrete measurement problem. Over uniformly sampled 64-bit
integers, one compares two summary statistics as predictors of a downstream rate: the
trailing-zero count $T$ (the 2-adic valuation) and the popcount. The recorded quantities are:

* pooled reading $\rho(T,\text{rate}) = 0.641$ with confidence interval $[0.619, 0.660]$,
  entirely inside the pre-registered validation band $[0.55, 0.85]$;
* pooled advantage of $T$ over the popcount baseline $\alpha = +0.044$, interval
  $[0.022, 0.066]$, *below* the pre-registered bar $+0.05$, with $1$ of $3$ fresh
  replications above the bar;
* combining with three earlier replications: six-seed mean reading $0.644$, mean advantage
  $+0.059$, median advantage $+0.058$, $3$ of $6$ replications above the bar.

The first bullet is a clean replication of the presence hypothesis. The second and third
together constitute what we call **count parity**: a mean above a threshold carried by only
half of the sample. Formally, with $\rho_{\text{pooled}} = 0.641$, $\text{CI} = [0.619,0.660]$,
band $= [0.55,0.85]$, one has $0.55 \le 0.619 \le 0.641 \le 0.660 \le 0.85$; and with bar
$\tau = 0.05$, $\alpha_{\text{fresh}} = 0.044 < \tau < 0.058 = \text{median}_6 < 0.059 = \text{mean}_6$.
The advantage estimate and the bar straddle each other depending on how the sample is
aggregated.

The purpose of this paper is not statistical inference. It is to ask a prior question:
**what shapes may such a record have at all?** We treat correlations as what they are —
cosines of angles between vectors — and derive hard, hypothesis-free constraints. A record
that violates them is impossible, regardless of sampling noise.

### 1.2 Notation

Throughout, vectors live in $\mathbb{R}^n$ with the standard inner product
$\langle p, q\rangle = \sum_{x=1}^n p(x)q(x)$ and norm $\|p\| = \sqrt{\langle p,p\rangle}$.
For nonzero $u, v$ we write
$$\rho(u,v) \;=\; \frac{\langle u, v\rangle}{\|u\|\,\|v\|}$$
for their correlation (equivalently, after centering, the Pearson correlation of the
underlying samples). A *unit statistic* is a vector with $\langle u,u\rangle = 1$; a
*response* is a unit vector $w$; the *reading* of $u$ against $w$ is $\langle u, w\rangle$.

**Definition 1.1 ($\gamma$-family).** A family $u_1,\dots,u_k$ of vectors in $\mathbb{R}^n$
is a *$\gamma$-family* if $\langle u_i,u_i\rangle = 1$ for all $i$ and
$\langle u_i, u_j\rangle \le \gamma$ for all $i \ne j$.

A $0$-family with equality off the diagonal is an orthonormal system; an *equidistant* (or
equiangular) family is one with $\langle u_i,u_j\rangle = \gamma$ exactly, for all $i\neq j$.

---

## 2. Layer 1: the chord law and the decorrelation budget

### 2.1 Gram positivity rewritten

Let $u, v, w$ be unit vectors and set $a = \langle u,w\rangle$, $b = \langle v,w\rangle$,
$c = \langle u,v\rangle$. The Gram matrix
$$G \;=\; \begin{pmatrix} 1 & c & a \\ c & 1 & b \\ a & b & 1\end{pmatrix}$$
is positive semidefinite, and $\det G = 1 + 2abc - (a^2+b^2+c^2) \ge 0$.

**Theorem 2.1 (Chord identity).** For all real $a,b,c$,
$$(1-c)\bigl(1 + c - 2ab\bigr) - (a-b)^2 \;=\; 1 + 2abc - \bigl(a^2+b^2+c^2\bigr).$$

*Proof sketch.* Expand both sides. The left side is
$1 + c - 2ab - c - c^2 + 2abc - a^2 + 2ab - b^2 = 1 - c^2 + 2abc - a^2 - b^2$, which is the
right side. $\square$

**Corollary 2.2 (Chord law; equivalence form).** For all real $a,b,c$,
$$a^2 + b^2 + c^2 \le 1 + 2abc \iff (a-b)^2 \le (1-c)\bigl(1 + c - 2ab\bigr).$$

The two inequalities are literally the same inequality, rearranged. This is the conceptual
pivot of the paper: the *advantage* $a - b$ is not an extra degree of freedom layered on top
of a correlation structure. It is the Gram determinant, read along the difference direction.

**Corollary 2.3 (Chord law for statistics).** For any nonzero $u,v,w \in \mathbb{R}^n$,
$$\bigl(\rho(u,w) - \rho(v,w)\bigr)^2 \;\le\; \bigl(1 - \rho(u,v)\bigr)\bigl(1 + \rho(u,v) - 2\rho(u,w)\rho(v,w)\bigr).$$

*Proof sketch.* Normalise and apply Corollary 2.2 to the Gram determinant of the normalised
triple, which is non-negative by positive semidefiniteness. $\square$

### 2.2 The budget

**Theorem 2.4 (Decorrelation budget).** Suppose $a^2+b^2+c^2 \le 1 + 2abc$, and let
$\alpha \ge 0$ satisfy $\alpha \le a - b$. Then
$$\alpha^2 \;\le\; 2\,(1-c)\,(1 - ab).$$

*Proof sketch.* By Corollary 2.2, $(a-b)^2 \le (1-c)(1+c-2ab)$. Since $c \le 1$ (a
consequence of Gram positivity for unit vectors, or assumed) we have $1 + c - 2ab \le 2 - 2ab$,
and $1 - c \ge 0$, so $(1-c)(1+c-2ab) \le 2(1-c)(1-ab)$. Finally $0 \le \alpha \le a-b$ gives
$\alpha^2 \le (a-b)^2$. $\square$

**Corollary 2.5 (Mutual-correlation ceiling).** Under the hypotheses of Theorem 2.4, if in
addition $c \le 1$ and $ab \ge M$ with $M < 1$, then
$$c \;\le\; 1 - \frac{\alpha^2}{2(1-M)}.$$

*Proof sketch.* Rearrange Theorem 2.4 using $1 - ab \le 1 - M$ and $1 - M > 0$. $\square$

This is the operational form: **an advantage must be purchased with decorrelation, at a
price fixed by the strength of the two competitors.** Two numerical instances follow.

**Proposition 2.6 (Recorded correlation window).** If $a = 0.641$, $b = 0.597$, $c \le 1$ and
the Gram inequality holds, then
$$-0.24 \;\le\; c \;\le\; 1 - 0.0015 .$$

*Proof sketch.* The upper bound is Corollary 2.5 with $\alpha = 0.044$ and $M = 0.382 \le ab$.
The lower bound is the standard consequence of Gram positivity,
$c \ge ab - \sqrt{(1-a^2)(1-b^2)}$, with $ab = 0.382677$ and
$\sqrt{(1-a^2)(1-b^2)} \le 0.616$. $\square$

**Proposition 2.7 (Outlier decorrelation).** If the Gram inequality holds, $c \le 1$,
$a - b \ge 0.086$ and $ab \ge 1/3$, then $c \le 0.995$.

*Proof sketch.* Corollary 2.5 with $\alpha = 0.086$, $M = 1/3$ gives
$c \le 1 - 0.086^2/(2\cdot\frac23) = 1 - 0.005547 < 0.995$. $\square$

### 2.3 Sharpness and the chord metric

**Theorem 2.8 (Planar identity).** If $u,v,w$ are nonzero vectors in $\mathbb{R}^2$, then
$$\rho(u,v)^2 + \rho(u,w)^2 + \rho(v,w)^2 \;=\; 1 + 2\rho(u,v)\rho(u,w)\rho(v,w),$$
and consequently
$$\bigl(\rho(u,w)-\rho(v,w)\bigr)^2 \;=\; \bigl(1-\rho(u,v)\bigr)\bigl(1+\rho(u,v)-2\rho(u,w)\rho(v,w)\bigr).$$

*Proof sketch.* Three vectors in the plane are linearly dependent, so their Gram matrix is
singular; expanding $\det G = 0$ and dividing by $\|u\|^2\|v\|^2\|w\|^2$ gives the first
identity, and Theorem 2.1 converts it into the second. $\square$

Hence the chord law is an *identity* whenever the response lies in the plane spanned by the
two statistics, and Theorem 2.4 cannot be improved in general.

**Definition 2.9 (Chord distance).** For nonzero $u,v$ put $\hat u = u/\|u\|$ and
$$d(u,v) \;=\; \|\hat u - \hat v\| \;=\; \sqrt{2 - 2\rho(u,v)} .$$

**Theorem 2.10 (Triangle inequality; transfer).** For all $u,v,w$, $d(u,w) \le d(u,v) + d(v,w)$.
Equivalently, for nonzero vectors,
$$2 - 2\rho(v,w) \;\le\; \left(\sqrt{2 - 2\rho(u,v)} + \sqrt{2 - 2\rho(u,w)}\right)^2 .$$

*Proof sketch.* $d$ is the Euclidean distance between normalised vectors, so the triangle
inequality for $\|\cdot\|$ applies; the squared form follows by squaring and substituting
$d^2 = 2-2\rho$. $\square$

This upgrades the pairwise budget into a *transitivity* law: correlation is transitive in
the chord metric, with an explicit modulus.

---

## 3. Layer 2: capacity of a correlated family

### 3.1 The master law

**Theorem 3.1 (Master law).** Let $u_1,\dots,u_k \in \mathbb{R}^n$ be arbitrary, let $w$ be a
unit vector, and suppose $\langle u_i,w\rangle \ge \rho \ge 0$ for all $i$. Then
$$(k\rho)^2 \;\le\; \mathbf{1}^{\mathsf T} G\, \mathbf{1} \;=\; \sum_{i=1}^{k}\sum_{j=1}^{k} \langle u_i, u_j\rangle .$$

*Proof sketch.* Put $S = \sum_i u_i$. Then $\langle S, w\rangle = \sum_i \langle u_i,w\rangle \ge k\rho \ge 0$,
and Cauchy–Schwarz gives $\langle S,w\rangle^2 \le \langle S,S\rangle\langle w,w\rangle = \langle S,S\rangle$.
Finally $\langle S,S\rangle = \sum_{i,j}\langle u_i,u_j\rangle$. $\square$

No normalisation, no correlation ceiling, no restriction on $k$: everything below is a way of
bounding the right-hand side.

**Corollary 3.2 (Row-sum law).** If in addition $k \ge 1$ and $\sum_j \langle u_i,u_j\rangle \le R$
for every $i$, then $k\rho^2 \le R$.

*Proof sketch.* $\mathbf{1}^{\mathsf T}G\mathbf{1} \le kR$, so $(k\rho)^2 \le kR$; divide by $k$. $\square$

**Theorem 3.3 (Capacity law).** Let $u_1,\dots,u_k$ be a $\gamma$-family, $w$ a unit
response, $\rho \ge 0$, $k \ge 1$, and $\langle u_i,w\rangle \ge \rho$ for all $i$. Then
$$k\,\rho^2 \;\le\; 1 + (k-1)\,\gamma .$$

*Proof sketch.* Each row sum is $\langle u_i,u_i\rangle + \sum_{j\ne i}\langle u_i,u_j\rangle \le 1 + (k-1)\gamma$;
apply Corollary 3.2 with $R = 1 + (k-1)\gamma$. $\square$

**Corollary 3.4 (Recovering the two classical ceilings).**
(i) For an orthonormal family ($\gamma=0$), $k\rho^2 \le 1$.
(ii) For $k=2$ with $\langle u_1,u_2\rangle \le \gamma$, $2\rho^2 \le 1 + \gamma$.

Thus two previously separate ceilings — orthonormal capacity and pairwise parity — are the
two boundary faces of a single interpolating law.

**Corollary 3.5 (Forced pairwise correlation).** For $k \ge 2$, any $\gamma$-family as above
satisfies
$$\gamma \;\ge\; \frac{k\rho^2 - 1}{k-1}.$$

At $\rho = 0.641$, $k = 3$: $\gamma \ge (3\cdot 0.410881 - 1)/2 = 0.1163215$. In particular
no triple of statistics with pairwise correlations at most $0.1$ can all read $0.641$ against
a common response: **there is no decorrelated triple at the recorded level.**

**Theorem 3.6 (Off-diagonal floor and Frobenius form).** For unit statistics with all
readings at least $\rho \ge 0$ against a unit response,
$$\sum_{i}\sum_{j \ne i} \langle u_i,u_j\rangle \;\ge\; k^2\rho^2 - k,
\qquad
\bigl(k\rho^2\bigr)^2 \;\le\; \sum_{i}\sum_{j} \langle u_i,u_j\rangle^2 .$$

*Proof sketch.* The first is Theorem 3.1 with the $k$ diagonal ones subtracted. The second
applies Cauchy–Schwarz to $\mathbf{1}^{\mathsf T} G\mathbf{1} \le k\,\|G\|_F$ combined with
Theorem 3.1. $\square$

**Corollary 3.7 (Triple mean-correlation floor).** Three unit statistics each reading at
least $0.641$ against a unit response satisfy
$$\langle u_1,u_2\rangle + \langle u_1,u_3\rangle + \langle u_2,u_3\rangle \;\ge\; \tfrac{697929}{2000000} = 0.3489645 .$$

### 3.2 Attainability

**Theorem 3.8 (Equidistant realiser).** For every $k \ge 1$ and $\gamma \le 1$ with
$1 + (k-1)\gamma \ge 0$ there exist unit vectors $u_1,\dots,u_k \in \mathbb{R}^k$ with
$\langle u_i,u_j\rangle = \gamma$ for all $i\neq j$ and a unit $w \in \mathbb{R}^k$ with
$$\langle u_i, w\rangle \;=\; \sqrt{\frac{1 + (k-1)\gamma}{k}} \quad\text{for every } i,$$
so that $k\rho^2 = 1 + (k-1)\gamma$ exactly.

*Proof sketch.* Take $u_i = A e_i + B\mathbf{1}$ with $A = \sqrt{1-\gamma}$ and $B$ chosen so
that $A^2\delta_{ij} + 2AB + kB^2$ equals $1$ on the diagonal and $\gamma$ off it; explicitly
$B = \bigl(\sqrt{1 + (k-1)\gamma} - \sqrt{1-\gamma}\bigr)/k$. Take $w = k^{-1/2}\mathbf{1}$
and compute $\langle u_i, w\rangle = (A + kB)/\sqrt{k} = \sqrt{(1+(k-1)\gamma)/k}$. $\square$

Therefore the capacity law is tight *on the whole $(k,\gamma)$ sheet*, not merely at
isolated parameter values.

### 3.3 Classification of extremisers

The next three theorems together determine every configuration on the capacity boundary.

**Theorem 3.9 (Extremality forces equidistance).** Let $u_1,\dots,u_k$ be a $\gamma$-family,
$w$ a unit response, $\rho \ge 0$, $k \ge 1$, $\langle u_i,w\rangle \ge \rho$, and suppose
$k\rho^2 = 1 + (k-1)\gamma$. Then $\langle u_i,u_j\rangle = \gamma$ for all $i \ne j$.

*Proof sketch.* The capacity proof passes through $\mathbf{1}^{\mathsf T}G\mathbf{1} \le k\bigl(1+(k-1)\gamma\bigr)$,
which is a sum of $k(k-1)$ terms each bounded by $\gamma$. Saturation forces the sum of those
terms to equal $k(k-1)\gamma$; a sum of terms individually $\le \gamma$ that attains
$(\text{count})\cdot\gamma$ has all terms equal to $\gamma$. $\square$

**Theorem 3.10 (Extremality forces parallel response).** Under the same hypotheses,
$$\sum_{i=1}^{k} u_i(x) \;=\; k\rho\,w(x) \qquad \text{for every coordinate } x .$$

*Proof sketch.* Let $S = \sum_i u_i$. Three inequalities were used: $\langle S,w\rangle \ge k\rho$
(summing the readings), $\langle S,w\rangle^2 \le \langle S,S\rangle$ (Cauchy–Schwarz), and
$\langle S,S\rangle \le k + k(k-1)\gamma = (k\rho)^2$ (row sums and extremality). Chaining them
gives $\langle S,w\rangle \le k\rho$, hence $\langle S,w\rangle = k\rho$ and
$\langle S,S\rangle = (k\rho)^2$. Now expand
$$\bigl\| S - k\rho\, w \bigr\|^2 \;=\; \langle S,S\rangle - 2k\rho\,\langle S,w\rangle + (k\rho)^2\langle w,w\rangle \;=\; (k\rho)^2 - 2(k\rho)^2 + (k\rho)^2 \;=\; 0 .$$
A vector of zero norm vanishes coordinatewise. $\square$

Notice that the argument never invokes an abstract equality case of Cauchy–Schwarz; it
computes the residual norm directly, which is both shorter and constructive.

**Corollary 3.11 (Response is the normalised sum).** If moreover $\rho > 0$, then
$$w \;=\; \frac{1}{k\rho}\sum_{i=1}^{k} u_i .$$

**Theorem 3.12 (Extremality forces exact readings).** Under the hypotheses of Theorem 3.10,
$\langle u_i, w\rangle = \rho$ for every $i$.

*Proof sketch.* We know $\sum_i \langle u_i,w\rangle = \langle S,w\rangle = k\rho$ while each
term is $\ge \rho$; a sum of $k$ terms each at least $\rho$ that equals $k\rho$ has all terms
equal to $\rho$. $\square$

**Theorem 3.13 (Minimal ambient dimension).** Suppose $\gamma < 1$ and $1 + (k-1)\gamma > 0$.
Then an equidistant family of $k$ unit vectors with off-diagonal Gram entry $\gamma$ is
linearly independent; consequently it exists in $\mathbb{R}^n$ only if $n \ge k$, and it does
exist in $\mathbb{R}^k$.

*Proof sketch.* The Gram matrix is $(1-\gamma)I + \gamma J$, whose eigenvalues are
$1 + (k-1)\gamma$ (once, on $\mathbf{1}$) and $1-\gamma$ (with multiplicity $k-1$). Both are
positive under the stated hypotheses, so $G$ is nonsingular and the family is independent;
independence of $k$ vectors requires $n \ge k$. Theorem 3.8 supplies the realiser in
$\mathbb{R}^k$. $\square$

**Theorem 3.14 (Uniqueness up to a frame).** If $u_1,\dots,u_k$ and $v_1,\dots,v_k$ are two
families in $\mathbb{R}^k$ with the same Gram matrix and $u$ linearly independent, then there
is an orthogonal matrix $O$ with $v_i = O^{\mathsf T} u_i$ for all $i$. In particular any two
equidistant families with the same $\gamma < 1$ (and $1+(k-1)\gamma > 0$) in $\mathbb{R}^k$
differ by an orthogonal change of frame.

*Proof sketch.* Write the families as rows of matrices $U, V$ with $UU^{\mathsf T} = VV^{\mathsf T} = G$.
Since $U$ is invertible, $O = U^{-1}V$ satisfies $O^{\mathsf T}O = V^{\mathsf T}(UU^{\mathsf T})^{-1}V$;
a short computation shows $OO^{\mathsf T} = I$. $\square$

**Summary of the classification.** A capacity extremiser is determined by $(k,\gamma)$ alone,
up to an orthonormal frame: Gram matrix $(1-\gamma)I + \gamma J$, all readings exactly
$\rho = \sqrt{(1+(k-1)\gamma)/k}$, response equal to the normalised sum of the family,
ambient dimension exactly $k$.

### 3.4 The capacity staircase

**Definition 3.15.** For $\rho \in \mathbb{R}$ and $k \ge 2$ set
$$\theta(\rho,k) \;=\; \frac{k\rho^2 - 1}{k-1}.$$
Say the pair $(\rho,\gamma)$ *admits size $k$* if $k\rho^2 \le 1 + (k-1)\gamma$.

**Theorem 3.16 (Threshold form).** For $k \ge 2$, $(\rho,\gamma)$ admits size $k$ if and only
if $\gamma \ge \theta(\rho,k)$.

**Theorem 3.17 (Monotonicity and initial segments).** If $\rho^2 < 1$ and $2 \le j < k$ then
$\theta(\rho,j) < \theta(\rho,k)$. Consequently if $(\rho,\gamma)$ admits size $k$ it admits
every size $2 \le j \le k$: the admissible sizes form an initial segment.

*Proof sketch.* $\theta(\rho,k) = \rho^2 + (\rho^2-1)/(k-1)$, and $\rho^2 - 1 < 0$, so
$\theta$ is strictly increasing in $k$. $\square$

**Theorem 3.18 (Closed-form capacity).** If $\gamma < \rho^2$ and $\gamma \le 1$, then
$(\rho,\gamma)$ admits size $k$ if and only if
$$k \;\le\; \left\lfloor \frac{1-\gamma}{\rho^2-\gamma} \right\rfloor .$$

*Proof sketch.* $k\rho^2 \le 1 + (k-1)\gamma \iff k(\rho^2-\gamma) \le 1-\gamma$; divide by
the positive quantity $\rho^2-\gamma$ and take the integer part. $\square$

**Theorem 3.19 (Genuine phase transition).** Fix $\rho \ge 0$ and $k \ge 2$ with
$0 \le \theta(\rho,k) \le 1$. Then

* for every $\gamma < \theta(\rho,k)$ there is **no** $\gamma$-family of size $k$, in any
  ambient dimension, with a unit response read at least $\rho$ by every member; and
* at $\gamma = \theta(\rho,k)$ such a family exists (explicitly, in dimension $k+1$).

So each riser of the staircase is a real boundary, not an artefact of a lossy bound.

**Numerical instance.** At $\rho = 0.641$: $\theta(\rho,3) = \frac{232643}{2000000} = 0.1163215$
and $\theta(\rho,4) = \frac{53627}{250000} = 0.214508$, so
$$0.1 \;<\; \theta(\rho,3) \;<\; 0.2 \;<\; \theta(\rho,4).$$
Hence at ceiling $\gamma = 0.1$ the capacity is exactly $2$ (a pair exists in $\mathbb{R}^3$;
no triple exists anywhere), and at $\gamma = 0.2$ it is exactly $3$ (a triple exists in
$\mathbb{R}^4$; no quadruple exists anywhere). Equivalently
$\lfloor (1-0.1)/(0.641^2-0.1)\rfloor = 2$ and $\lfloor (1-0.2)/(0.641^2-0.2)\rfloor = 3$.
Moreover the extremal triple at $\gamma = \theta(\rho,3)$ is realisable in $\mathbb{R}^3$ and
in no smaller space, with all three readings exactly $0.641$.

---

## 4. Layer 3: records of replications

We now move from the geometry of one experiment to the arithmetic of many. Fix $r$
replications with per-replication advantages $\alpha_1,\dots,\alpha_r$.

### 4.1 Rigidity from summary statistics

**Theorem 4.1 (Block excess).** Let $S \subseteq B$ be finite index sets, $a : B \to \mathbb{Q}$,
and suppose $a_i \le \tau$ for all $i \in B\setminus S$. Then
$$\sum_{i\in S} a_i \;\ge\; \sum_{i\in B} a_i - \bigl(|B| - |S|\bigr)\tau ,$$
and hence, if $S \neq \emptyset$, some $i \in S$ has
$a_i \ge \bigl(\sum_{B} a - (|B|-|S|)\tau\bigr)/|S|$.

**Corollary 4.2 (Count-parity excess).** If $|B| = 2m$, $|S| = m$, $a_i \le \tau$ off $S$, and
$\sum_B a_i = |B|\mu$, then the mean of $a$ over $S$ is at least $2\mu - \tau$.

**Theorem 4.3 (Six-replication rigidity).** Let $a : \{1,\dots,6\} \to \mathbb{Q}$ with
$\sum_i a_i = 6\cdot 0.059$, $\sum_{i \in F} a_i = 3\cdot 0.044$ over the fresh triple $F$,
exactly $3$ indices with $a_i > 0.05$, and exactly $1$ of those in $F$. Then some legacy
index $i \notin F$ has $a_i \ge 0.086$.

*Proof sketch.* The legacy block sums to $6(0.059) - 3(0.044) = 0.222$; the above-bar count
splits as $3 = 2 + 1$, so exactly two legacy indices exceed $0.05$ and one does not. Applying
Theorem 4.1 with $B$ the legacy block, $S$ its above-bar subset ($|S| = 2$) and $\tau = 0.05$
gives a legacy index with $a_i \ge (0.222 - 0.05)/2 = 0.086$. $\square$

Since $0.086$ lies strictly outside the fresh confidence interval $[0.022,0.066]$, **the
excess sustaining the six-replication mean is necessarily carried by the older replication.**

**Theorem 4.4 (Sharpness).** The record $(0.050,\, 0.086,\, 0.086,\, 0.020,\, 0.030,\, 0.082)$
satisfies every hypothesis of Theorem 4.3 with legacy maximum exactly $0.086$; hence the
bound cannot be improved and the hypotheses are consistent.

**Theorem 4.5 (Above-group mean).** If $|S| = 3$ out of $6$, $a_i \le 0.05$ off $S$, and
$\sum_i a_i = 6\cdot 0.059$, then $\frac{1}{3}\sum_{i\in S} a_i \ge 2(0.059) - 0.05 = 0.068 > 0.066$.

**Corollary 4.6 (No flat record).** Under the hypotheses of Theorem 4.5 it is impossible that
$a_i \le 0.066$ for all $i$: no six-replication record with mean advantage $0.059$ and only
three replications above the bar can lie entirely inside the fresh confidence interval.

**Theorem 4.7 (Median rigidity and bimodality).** Let $a_{(1)} \le \cdots \le a_{(6)}$ be the
ordered advantages with median $(a_{(3)}+a_{(4)})/2 = 0.058$ and $a_{(3)} \le 0.05$. Then
$a_{(i)} \ge 2(0.058) - 0.05 = 0.066$ for all $i \ge 4$, and the *bimodality gap* satisfies
$$a_{(4)} - a_{(3)} \;\ge\; 0.016 .$$
If moreover $\sum_i a_i = 6(0.059)$ then $a_{(1)}+a_{(2)}+a_{(3)} \le 0.156$ and
$a_{(6)} \ge 0.068$.

The record is therefore *provably* split into a low cluster and a high cluster with a
guaranteed gap: count parity is a structural signature, not a sampling artefact.

### 4.2 Dispersion floors

**Theorem 4.8 (Variance floor).** Let $a_1,\dots,a_r$ have mean $\mu$, and let $L$ be a
nonempty proper subset with $a_i \le \tau < \mu$ for all $i \in L$. Then
$$\sum_{i=1}^r (a_i - \mu)^2 \;\ge\; \frac{r\,|L|}{r - |L|}\,(\mu-\tau)^2 ,
\qquad
\sum_{i=1}^r a_i^2 \;\ge\; r\mu^2 + \frac{r\,|L|}{r-|L|}(\mu-\tau)^2 .$$

*Proof sketch.* The deficiency of the low block, $\sum_{i \in L}(\mu - a_i) \ge |L|(\mu-\tau)$,
must be matched by an equal surplus on the complement. Minimising $\sum (a_i-\mu)^2$ subject
to a fixed block deficiency and surplus (equalising within each block, by Cauchy–Schwarz)
gives $|L|(\mu-\tau)^2 + \frac{(|L|(\mu-\tau))^2}{r-|L|}$, which equals the stated bound. $\square$

**Corollary 4.9 (Balanced form).** If $2|L| = r$ then $\sum_i (a_i-\mu)^2 \ge r(\mu-\tau)^2$.
For $r = 6$, $\mu = 0.059$, $\tau = 0.05$: $\sum_i(a_i - 0.059)^2 \ge 0.000486$.

**Theorem 4.10 (Count parity forces decorrelation).** Suppose $r$ replications satisfy Gram
positivity with readings $a_i, b_i$, mutual correlations $c_i \ge c_{\min}$, advantages
$0 \le \alpha_i \le a_i - b_i$, reading products $P \le a_ib_i \le 1$, mean advantage $\mu$,
and a nonempty proper low block $L$ with $\alpha_i \le \tau < \mu$ on $L$. Then
$$\mu^2 + \frac{|L|}{r-|L|}(\mu-\tau)^2 \;\le\; 2\,(1-c_{\min})\,(1-P).$$

*Proof sketch.* Sum the per-replication budgets $\alpha_i^2 \le 2(1-c_i)(1-a_ib_i) \le 2(1-c_{\min})(1-P)$
over $i$, and bound the left side below by the energy floor of Theorem 4.8 divided by $r$. $\square$

**Corollary 4.11.** With $r=6$, $\mu = 0.059$, $\tau = 0.05$, $|L| = 3$, $P = 1/3$:
$$c_{\min} \;\le\; 1 - \tfrac{5343}{2000000} \;=\; 1 - 0.00267 .$$

Dispersion *strengthens* the decorrelation conclusion: a bimodal record forces more
decorrelation than a flat record with the same mean.

---

## 5. The failure of budget averaging

### 5.1 The conjecture

Layer 1 is per-replication; Layer 3 is across replications. It is natural to conjecture that
the two commute with averaging. Precisely, with $\bar c = \frac1r\sum_i c_i$:

> **Conjecture (Budget Averaging).** Under Gram positivity per replication, $0 \le \alpha_i \le a_i - b_i$
> and $a_ib_i \le 1$,
> $$\sum_{i=1}^r \alpha_i^2 \;\le\; 2\,(1-\bar c)\Bigl(r - \sum_{i=1}^r a_ib_i\Bigr).$$

### 5.2 The refutation

**Theorem 5.1 (Budget averaging is false).** There exist $a,b,c,\alpha : \{1,2\} \to \mathbb{R}$ and
$\bar c$ satisfying every hypothesis of the Budget Averaging conjecture — Gram positivity, $\alpha_i \ge 0$,
$\alpha_i \le a_i-b_i$, $a_ib_i \le 1$, and $\sum_i c_i = 2\bar c$ — with
$$\sum_i \alpha_i^2 \;>\; 2(1-\bar c)\Bigl(2 - \sum_i a_ib_i\Bigr).$$

*Witness.* Take
$$(a_1,b_1,c_1,\alpha_1) = (0.7,\,-0.7,\,0,\,1.4), \qquad (a_2,b_2,c_2,\alpha_2) = (1,\,1,\,1,\,0),$$
so $\bar c = 1/2$. Gram positivity holds in both replications ($0.49+0.49+0 \le 1$ and
$1+1+1 \le 1 + 2$), the advantage constraints hold with equality, and $a_ib_i \in \{-0.49, 1\}$.
Then
$$\sum_i \alpha_i^2 = 1.96, \qquad 2\bigl(1-\tfrac12\bigr)\bigl(2 - (-0.49+1)\bigr) = 1.49 .$$
Since $1.96 > 1.49$, the conjecture fails. $\square$

### 5.3 Diagnosis and repair

The mechanism is transparent. Per replication the true budget is
$\alpha_i^2 \le 2(1-c_i)(1-a_ib_i)$, so
$$\sum_i \alpha_i^2 \;\le\; 2\sum_i (1-c_i)(1-a_ib_i).$$
The conjecture replaces $\sum_i (1-c_i)(1-a_ib_i)$ by $\frac1r\bigl(\sum_i(1-c_i)\bigr)\bigl(\sum_i(1-a_ib_i)\bigr)$.
That substitution is an instance of the **Chebyshev sum inequality**, which runs in the
*favourable* direction only when the two sequences are oppositely ordered. In the
counterexample, decorrelation $1-c_i = (1,0)$ and headroom $1-a_ib_i = (1.49, 0)$ *monovary*:
the replication with all the decorrelation also has all the headroom. The product sum is then
strictly larger than the product of averages.

**Theorem 5.2 (Unconditional repair: minimum in place of mean).** Under Gram positivity per
replication, $0 \le \alpha_i \le a_i - b_i$, $a_ib_i \le 1$, and $c_i \ge c_{\min}$ for all $i$,
$$\sum_{i=1}^r \alpha_i^2 \;\le\; 2\,(1-c_{\min})\Bigl(r - \sum_{i=1}^r a_ib_i\Bigr).$$

*Proof sketch.* Per replication, $\alpha_i^2 \le 2(1-c_i)(1-a_ib_i) \le 2(1-c_{\min})(1-a_ib_i)$
because $1-a_ib_i \ge 0$; sum over $i$. $\square$

**Theorem 5.3 (Conditional repair: Chebyshev).** Assume $r \ge 1$, Gram positivity per
replication, $0 \le \alpha_i \le a_i-b_i$, $\sum_i c_i = r\bar c$, and that the sequences
$(1-c_i)_i$ and $(1-a_ib_i)_i$ **antivary** (i.e. $(1-c_i - (1-c_j))\bigl((1-a_ib_i) - (1-a_jb_j)\bigr) \le 0$
for all $i,j$). Then the conjecture holds verbatim:
$$\sum_{i=1}^r \alpha_i^2 \;\le\; 2\,(1-\bar c)\Bigl(r - \sum_{i=1}^r a_ib_i\Bigr).$$

*Proof sketch.* Chebyshev's sum inequality for antivarying sequences gives
$r\sum_i (1-c_i)(1-a_ib_i) \le \bigl(\sum_i(1-c_i)\bigr)\bigl(\sum_i(1-a_ib_i)\bigr) = r(1-\bar c)\bigl(r - \sum_i a_ib_i\bigr)$.
Divide by $r$ and combine with the summed per-replication budgets. $\square$

Thus the conjecture is exactly one Chebyshev ordering hypothesis away from truth, and Theorem 5.1 shows
the hypothesis cannot be dropped.

### 5.4 Meta-analytic consequences for the record

**Definition 5.4.** The recorded six-replication advantage split is
$$\alpha \;=\; (0.016,\; 0.100,\; 0.106,\; 0.016,\; 0.050,\; 0.066),$$
which reproduces every published summary: total $0.354 = 6(0.059)$; fresh block
$(0.016,0.050,0.066)$ summing to $0.132 = 3(0.044)$; exactly $3$ entries above the bar $0.05$,
of which exactly $1$ is fresh; sorted median $(0.050+0.066)/2 = 0.058$; and a legacy entry
$\ge 0.086$ as Theorem 4.3 requires. Its advantage energy is
$$\sum_i \alpha_i^2 \;=\; \tfrac{28604}{1000000} \;=\; 0.028604 .$$

**Theorem 5.5 (Aggregate decorrelation floor).** Suppose each replication satisfies Gram
positivity, realises at least its recorded advantage $\alpha_i \le a_i - b_i$, has reading
product $1/3 \le a_ib_i \le 1$, and has $c_i \ge c_{\min}$ with $c_i \le 1$. Then
$$c_{\min} \;\le\; 1 - \tfrac{7151}{2000000} \;=\; 1 - 0.0035755 .$$

*Proof sketch.* Theorem 5.2 gives $0.028604 \le 2(1-c_{\min})(6 - \sum_i a_ib_i)$, and
$\sum_i a_ib_i \ge 6\cdot\frac13 = 2$ gives $6 - \sum_i a_ib_i \le 4$; hence
$1 - c_{\min} \ge 0.028604/8 = 0.0035755$. $\square$

**Theorem 5.6 (Chebyshev form for the record).** If in addition $(1-c_i)$ and $(1-a_ib_i)$
antivary and $\sum_i c_i = 6\bar c$ with $\bar c \le 1$, then the same numerical floor holds
for the *mean* correlation: $\bar c \le 1 - \frac{7151}{2000000}$.

The point is that the most-correlated replication in the record is constrained by the
*pooled* advantage energy; no single replication's budget delivers this bound (the largest
single advantage, $0.106$, at product $1/3$, gives only $1 - c \ge 0.106^2/(4/3) = 0.00843$
for *that* replication and nothing at all about the others; Theorem 5.5 constrains the
*worst* one).

---

## 6. Algorithms

The theory is effective, and three procedures summarise the computational content.

**Algorithm A (Capacity of a correlated family).** Given $\rho \in [0,1)$ and
$\gamma \in [0,1)$, return the largest admissible family size. If $\gamma \ge \rho^2$ the
capacity is unbounded; otherwise return $\lfloor (1-\gamma)/(\rho^2-\gamma)\rfloor$.
Complexity $O(1)$. Correctness is Theorem 3.18.

**Algorithm B (Extremal realiser).** Given $k$ and $\gamma \le 1$ with $1+(k-1)\gamma \ge 0$,
output the Gram-exact equidistant family $u_i = A e_i + B\mathbf{1}$ in $\mathbb{R}^k$ with
$A = \sqrt{1-\gamma}$, $B = \bigl(\sqrt{1+(k-1)\gamma} - \sqrt{1-\gamma}\bigr)/k$, together
with $w = k^{-1/2}\mathbf{1}$. Complexity $O(k^2)$ to materialise. Correctness is Theorem 3.8;
Theorems 3.9–3.12 say the output is, up to an orthogonal frame, the *only* extremiser.

**Algorithm C (Aggregated decorrelation certificate).** Given per-replication advantages
$\alpha_i$ and a reading-product floor $P$, return the certified bound
$1 - c_{\min} \ge \bigl(\sum_i \alpha_i^2\bigr)\big/\bigl(2r(1-P)\bigr)$ — valid
unconditionally — and, when the antivariation test on $(1-c_i)$, $(1-a_ib_i)$ passes, the
sharper mean-based bound. Complexity $O(r)$ for the bound and $O(r\log r)$ (or $O(r^2)$ naively)
for the ordering test. Correctness is Theorems 5.2, 5.3, and 5.5.

---

## 7. Discussion

### 7.1 What the three layers say together

Layer 1 states that advantage is *purchased*: an excess correlation of $\alpha$ over a
competitor at reading product $M$ costs at least $\alpha^2/(2(1-M))$ of mutual decorrelation.
This is unconditional and sharp.

Layer 2 states that strong predictors of the same thing must *crowd*: a family of $k$ unit
statistics each reading $\rho$ has forced pairwise correlation $\ge (k\rho^2-1)/(k-1)$, and
the admissible sizes form a staircase with closed-form top step
$\lfloor (1-\gamma)/(\rho^2-\gamma)\rfloor$. On each riser the extremal configuration is
completely rigid — equidistant Gram matrix, exact readings, response equal to the normalised
sum, ambient dimension exactly $k$, unique up to an orthogonal frame.

Layer 3 states that a replication record whose mean clears a bar while only half of its
entries do is *forced* to be bimodal, with an explicit gap, an explicit outlier bound, and an
explicit dispersion floor.

### 7.2 The negative result is the interesting one

The tempting bridge between Layers 1 and 3 — average the budgets — is false. Its failure is
not an edge case: it occurs exactly when the replications with the most decorrelation to
spend are also the ones with the most headroom, i.e. when decorrelation and headroom
*monovary*. Bimodal records are the canonical monovariant regime: a few replications carry
the whole effect, and those same replications are the ones whose statistics are least alike.
So in precisely the situation where pooling is most tempting — a marginal effect that
survives only in the aggregate — the naive mean-based budget over-credits the record.

The practical prescription is therefore explicit. When aggregating advantage evidence:

1. Use the *minimum* decorrelation form (Theorem 5.2) unless you can verify the ordering
   hypothesis; it is unconditional.
2. Test antivariation before using any mean-based aggregate (Theorem 5.3). The test is a
   simple pairwise ordering check.
3. Treat a count-parity split as a *warning* that the record is bimodal (Theorem 4.7) and that
   the mean is a poor summary of its geometry.

### 7.3 Relation to classical facts

The chord law is a repackaging of the non-negativity of a $3\times 3$ Gram determinant, but the
packaging is what makes it usable: it turns a symmetric statement about a correlation matrix
into an asymmetric statement about a competition. The capacity law generalises the elementary
Bessel-type bound $k\rho^2 \le 1$ to correlated families, and its extremisers are the familiar
equiangular configurations with Gram matrix $(1-\gamma)I + \gamma J$ — the same spectral
structure that appears in the analysis of regular simplices, where $\gamma = -1/(k-1)$ is the
smallest admissible value. The staircase formula
$\lfloor (1-\gamma)/(\rho^2-\gamma)\rfloor$ is a discrete packing statement in the same spirit
as bounds on the size of spherical codes, with the response direction playing the role of a
distinguished pole. The Chebyshev repair makes explicit a monotonicity hypothesis that
is invisible in the informal statement.

### 7.4 Limitations

The theory is deterministic geometry, not inference. It constrains which records can exist,
not which are likely; the decorrelation floors are certificates, not estimates, and they are
weakest exactly when readings are far apart (the factor $1-M$ in the denominator). The
replication-layer results assume the published summary statistics are exact rather than
estimated, so in practice they should be applied to the interval hulls of those summaries.
Finally, the capacity results assume a common lower bound $\rho$ on all readings; a version
with heterogeneous readings $\rho_i$ follows from the master law by replacing $k\rho$ with
$\sum_i \rho_i$, but the extremiser classification then needs restating.

---

## 8. Future directions

* **Heterogeneous capacity.** The master law $(\sum_i \rho_i)^2 \le \mathbf{1}^{\mathsf T}G\mathbf{1}$
  holds for heterogeneous readings. Determine the extremisers in that setting; we expect the
  response to remain a positively weighted sum of the family, with weights solving a linear
  system in $G$.
* **Beyond uniform ceilings.** Replace the single ceiling $\gamma$ by a graph or matrix of
  ceilings $\gamma_{ij}$ and characterise admissibility; the row-sum law already gives a
  bound, but the sharp condition should involve the spectral radius of the ceiling matrix.
* **Interval-valued records.** Re-derive the Layer-3 rigidity theorems with the summary
  statistics known only to lie in intervals, producing the *tightest* possible bimodality gap
  and outlier bound consistent with a set of reported confidence intervals.
* **Ordering diagnostics.** Develop a statistical test for the antivariation hypothesis of
  Theorem 5.3 from observable quantities, so that practitioners can decide legitimately
  between the mean-based and minimum-based aggregate budgets.
* **Sharpness of the aggregate floor.** Theorem 5.5 uses the crude bound
  $\sum_i a_ib_i \ge rP$. Determine the exact optimum of
  $\min_{c} \max_i c_i$ subject to the per-replication budgets and a fixed advantage record;
  we expect a water-filling solution.
* **Higher-order chord laws.** The chord identity is the $3\times 3$ Gram determinant. Find the
  analogous "advantage" rearrangement of the $4\times 4$ determinant, which should govern
  three-way competitions with a shared response.

---

## 9. Conclusion

Correlation is geometry, and once advantage is recognised as Gram positivity read along a
difference direction, a chain of hard constraints follows: an advantage costs decorrelation;
strong statistics for one target crowd together; the number of them is a staircase function
of the correlation ceiling with completely rigid extremisers; and a replication record whose
mean clears a bar carried by half the sample is provably bimodal.

The final result is a caution. Aggregating per-experiment geometric budgets by averaging is
invalid unless decorrelation and headroom are oppositely ordered — and in bimodal,
count-parity records they are not. Replacing the mean by the minimum restores validity
unconditionally; verifying a Chebyshev ordering restores the mean-based form exactly. That
distinction is small to state and consequential to ignore.
