# The Arithmetic of Mixed-Domain Key Budgets

**A model-free theory of attention knees under pooling, interleaving and unequal mixing**

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

We develop a model-free theory of the *key budget* — the number of top-ranked attention
weights required to retain a prescribed fraction $\tau$ of the total attention mass of a
context — and of how that budget behaves when two or more content domains are combined.
Two combination operators are analysed: **pooling**, in which the domains share one
context with mixing weights $a$ and $b$, and **interleaving**, in which the domains
alternate along a context of doubled length. The central structural fact is that
interleaving *is* pooling read in doubled key units: an even prefix of an interleaved
context contains matched prefixes of both domains. From this reduction we obtain a
complete account of the empirical verdict "a mixed domain starts at the easier component's
level and rises at double the expected rate".

The results are: (i) a **mediant sandwich**, showing that the pooled retained-mass curve
always lies between its component curves, and hence that the pooled budget is caged between
the component budgets for every mixing ratio; (ii) a **no-formula theorem**, exhibiting
three profile pairs with identical component budgets whose balanced mixtures realise the
minimum, midpoint and maximum of the cage, so that no function of the component budgets
computes the mixed budget; (iii) an exact **convex-combination identity** with weight the
*mass share*, and the resulting **mass-share rigidity theorem**: once one domain carries
enough mass, the mixture's budget equals that domain's budget exactly; (iv) the **doubling
law** $|\Delta_{\mathrm{mix}} - 2\Delta_{\mathrm{pool}}| \le 1$ for context-doubling
increments, generalised to a **multiplier law** with multiplier $m$ for $m$-fold round
robins and multiplier $s+1$ — the reciprocal of the rarest mixing rate — for $s{:}1$
interleaving; (v) a **gate staircase** with sharp stability radii, from which interleaving
is shown to *divide* gate resolution by exactly the factor by which it multiplies the
increment, giving a **signal-to-resolution conservation inequality** with equality precisely
for balanced mixtures; (vi) an exact treatment of block interleaving, in which the residual
$\pm b$ quantisation window collapses to a single integer; (vii) a **closed formula** for
the critical mixing weight at which a ratio sweep collapses onto the dominant component,
expressed in four head masses of the two *pure* domains; and (viii) **two-sided spectral
estimators** turning a single observed budget into a bracket on the per-key decay ratio of
the attention profile. Together these results reinterpret a mixed-domain budget measurement
as a measurement of the model's attention spectrum rather than of the corpus.

**Keywords:** attention key budget, retained mass, mediant inequality, mass share, convex
combination, interleaving, round robin, gate staircase, spectral decay ratio.

---

## 1. Introduction

### 1.1 The measurement

Modern attention mechanisms distribute, at each query position, a positive weight over the
keys of the context. Sorting those weights in decreasing order and asking how many of them
are needed to account for a fraction $\tau$ of their total gives a single integer — the
**key budget**, or **knee**, of the measurement. It is the natural operational notion of a
model's working memory: keys past the knee can be pruned with a controlled loss of mass.

A natural experiment sweeps the *content type* of the context. Measuring the knee on pure
program source, on pure natural-language prose, and on a stream that interleaves blocks of
each, at two context lengths, produces the following table (gate exact; blocks of roughly
five hundred characters, fifty–fifty by volume):

| context $n$ | interleaved | code | prose | interleaved increment |
|---|---|---|---|---|
| $512$ | $12$ | $12$ | $16$ | — |
| $1024$ | $20$ | $16$ | $20$ | $+8$ (each pure domain: $+4$) |

Three readings were proposed for this table:

* **(P1)** the mixed knee is the midpoint of the component knees;
* **(P2)** the mixed knee reaches the harder domain's level as the context grows;
* **(P3)** mixed-domain attention has structure of its own.

The table refutes P1 at $n=512$ (the mixture sits at the minimum, not the midpoint),
supports P2 at $n=1024$, and leaves P3 as a slogan. This paper replaces the slogan with
theorems.

### 1.2 What is and is not explained

Two facts must be explained separately, because they have different causes.

*Starts low.* At the shorter context the mixture is indistinguishable from the easier
component. We show this is not a coincidence of the data but a **rigidity** phenomenon: as
soon as one domain's mass share is large enough that a certain gate window fits inside a
single step of that domain's knee staircase, the mixture's knee is *exactly* that domain's
knee.

*Rises fast.* The doubled increment is, we show, a **change of units**. Interleaving two
domains produces a context of doubled length whose even prefixes are matched prefixes of
the components; every budget is therefore automatically expressed in half-keys. The
doubling would occur even if a domain were interleaved with a rescaled copy of itself, so
it carries no information about cross-domain interaction whatsoever.

What *is* domain-specific is the position of the mixture inside its cage, and that is
governed by a single scalar: the mass share.

### 1.3 Outline

Section 2 fixes definitions. Section 3 proves the mediant sandwich and refutes P1. Section
4 gives the convex-combination identity and mass-share rigidity. Section 5 proves the
halving reduction, the bracket and the doubling law, and audits the reported grid. Section
6 treats multi-domain and unequal-rate interleaving. Section 7 develops the gate staircase,
stability radii, and the signal-to-resolution accounting. Section 8 treats block
interleaving exactly. Section 9 gives the mixing-ratio phase boundary and its closed
formula. Section 10 gives the two-sided spectral estimators. Section 11 lists algorithms,
Section 12 discusses limitations and Section 13 future directions.

---

## 2. Definitions

Throughout, an **attention profile** is a function $w : \mathbb{N} \to \mathbb{R}$ with
$w_i > 0$ for all $i$; the intended reading is that $w_i$ is the $i$-th largest attention
weight at some query position. No normalisation and no monotonicity is assumed except where
explicitly stated.

**Definition 2.1 (head mass).** $\displaystyle H_w(k) = \sum_{i<k} w_i$.

Head mass is nonnegative, nondecreasing in $k$, and strictly positive for $k \ge 1$.

**Definition 2.2 (retained mass).** For a context length $n \ge 1$ and a budget
$k \ge 0$,
$$R_w(n,k) \;=\; \frac{H_w(\min(k,n))}{H_w(n)} \;\in\; [0,1].$$
Thus $R_w(n,0)=0$, $R_w(n,k)=1$ for $k \ge n$, and $R_w(n,\cdot)$ is nondecreasing.

**Definition 2.3 (knee / key budget).** For a gate $\tau \le 1$,
$$k^*_w(n,\tau) \;=\; \min\{\,k \in \mathbb{N} : \tau \le R_w(n,k)\,\}.$$
The minimum exists because $R_w(n,n)=1 \ge \tau$. Two elementary facts are used constantly:
*(pass)* $\tau \le R_w(n,k^*)$; and *(fail)* $R_w(n,k) < \tau$ for every $k < k^*$.
Consequently, if $R_w(n,m) < \tau \le R_w(n,m+1)$ then $k^*_w(n,\tau) = m+1$ — the knee is
pinned by one failing and one passing inequality. Knees are nondecreasing in the context
length.

**Definition 2.4 (context-doubling increment).**
$\Delta_w(\tau,n) = k^*_w(2n,\tau) - k^*_w(n,\tau)$, a natural-number (truncated)
subtraction, which by monotonicity of the knee in $n$ is the honest difference.

**Definition 2.5 (pooling).** For weights $a,b>0$ and profiles $u,v$,
$$(\mathrm{pool}_{a,b}(u,v))_i \;=\; a\,u_i + b\,v_i .$$
Head masses add: $H_{\mathrm{pool}_{a,b}(u,v)}(k) = a H_u(k) + b H_v(k)$.

**Definition 2.6 (interleaving).**
$$(\mathrm{mix}(u,v))_i \;=\; \begin{cases} u_{i/2} & i \text{ even},\\ v_{(i-1)/2} & i \text{ odd}.\end{cases}$$

**Definition 2.7 (block interleaving).** For a block size $b \ge 1$, writing
$i = b\,\beta + \rho$ with $\rho < b$,
$$(\mathrm{block}_b(u,v))_i \;=\; \begin{cases} u_{\,b\lfloor \beta/2\rfloor + \rho} & \beta \text{ even},\\ v_{\,b\lfloor \beta/2\rfloor + \rho} & \beta \text{ odd}.\end{cases}$$
$\mathrm{block}_1 = \mathrm{mix}$.

**Definition 2.8 ($m$-fold round robin and family pool).** For a family
$U = (U^{(0)},\dots,U^{(m-1)})$ of profiles,
$$(\mathrm{rr}_m U)_i = U^{(i \bmod m)}_{\lfloor i/m\rfloor}, \qquad (\mathrm{poolFam}_m U)_i = \sum_{j<m} U^{(j)}_i .$$

**Definition 2.9 (unequal-rate interleaving).** For $s \ge 1$, the $s{:}1$ pattern places
$s$ keys of $u$ then one key of $v$, periodically, with period $s+1$; its pooled partner
bundles $s$ keys of $u$ with one key of $v$ per pooled key. The mixing rates are
$p_u = s/(s+1)$ and $p_v = 1/(s+1)$, so $1/\min_j p_j = s+1$.

**Definition 2.10 (mass share).**
$$\lambda \;=\; \lambda_{a,b}(u,v;n) \;=\; \frac{a H_u(n)}{a H_u(n) + b H_v(n)} \in (0,1).$$

**Definition 2.11 (step width).** $\displaystyle \mathrm{sw}_w(n,k) = \frac{w_k}{H_w(n)}$,
the normalised mass of the single key of rank $k$.

---

## 3. The mediant sandwich, and the refutation of P1

### 3.1 The sandwich

**Lemma 3.1 (mediant inequality).** For positive $B_1,B_2$,
$$\min\!\left(\frac{A_1}{B_1},\frac{A_2}{B_2}\right) \le \frac{A_1+A_2}{B_1+B_2} \le \max\!\left(\frac{A_1}{B_1},\frac{A_2}{B_2}\right).$$

*Proof sketch.* If $m$ denotes the minimum then $mB_1 \le A_1$ and $mB_2 \le A_2$; add and
divide by $B_1+B_2$. The upper bound is symmetric. $\square$

**Theorem 3.2 (Mediant Sandwich).** For positive profiles $u,v$, weights $a,b>0$, context
$n \ge 1$ and every budget $k$,
$$\min\bigl(R_u(n,k),R_v(n,k)\bigr) \;\le\; R_{\mathrm{pool}_{a,b}(u,v)}(n,k) \;\le\; \max\bigl(R_u(n,k),R_v(n,k)\bigr).$$

*Proof sketch.* Head masses add, so the pooled retained mass is literally the mediant
$\frac{aH_u(\min(k,n)) + bH_v(\min(k,n))}{aH_u(n)+bH_v(n)}$ of the two component retained
masses (with denominators $aH_u(n)$ and $bH_v(n)$); apply Lemma 3.1. $\square$

**Corollary 3.3 (the cage).** For $\tau \le 1$,
$$\min\bigl(k^*_u(n,\tau),k^*_v(n,\tau)\bigr) \;\le\; k^*_{\mathrm{pool}_{a,b}(u,v)}(n,\tau) \;\le\; \max\bigl(k^*_u(n,\tau),k^*_v(n,\tau)\bigr).$$

*Proof sketch.* For the upper bound, at $K = \max(k^*_u,k^*_v)$ both components pass the
gate (knees are monotone in the budget), so by the lower half of the sandwich the mixture
passes, and the mixture's knee is at most $K$. For the lower bound, at the mixture's own
knee the mixture passes; by the upper half of the sandwich one of the components passes
there too, so that component's knee is at most the mixture's, whence the minimum is.
$\square$

### 3.2 P1 is false, and so is every replacement

Fix $n = 4$ and $\tau = 7/10$. Let $v = (1,1,1,1)$ (flat, "prose-like"); its head masses
are $1,2,3,4$, so $R_v(4,2) = 1/2 < 0.7 \le 3/4 = R_v(4,3)$ and $k^*_v = 3$. Let

$$u_A = (10,1,1,1), \qquad u_B = (100,1,1,1), \qquad u_C = (1/10,\,1/1000,\,1/1000,\,1/1000).$$

Each has $k^*_u = 1$: for $u_A$, $R_{u_A}(4,1) = 10/13 \approx 0.769 \ge 0.7$; similarly for
$u_B$ ($100/103$) and $u_C$ ($\tfrac{0.1}{0.103} \approx 0.971$).

**Theorem 3.4 (the whole cage is attained).** With $a=b=1$ and the data above,
$$k^*_{\mathrm{pool}}(u_A,v) = 2, \qquad k^*_{\mathrm{pool}}(u_B,v) = 1, \qquad k^*_{\mathrm{pool}}(u_C,v) = 3,$$
while in all three cases the component knees are $1$ and $3$.

*Proof sketch.* Direct computation of four head masses per case. For $u_A + v = (11,2,2,2)$:
retained masses $11/17 \approx 0.647 < 0.7 \le 13/17 \approx 0.765$, so the knee is $2$. For
$u_B + v = (101,2,2,2)$: $101/107 \approx 0.944 \ge 0.7$, so the knee is $1$. For
$u_C + v = (1.1, 1.001, 1.001, 1.001)$: the profile is nearly flat, retained masses
$\approx 0.268, 0.512, 0.756$, so the knee is $3$. $\square$

**Corollary 3.5 (No-Formula Theorem).** There is no function
$f : \mathbb{N}\times\mathbb{N} \to \mathbb{N}$ with
$k^*_{\mathrm{pool}_{1,1}(u,v)}(n,\tau) = f\bigl(k^*_u(n,\tau), k^*_v(n,\tau)\bigr)$ for all
positive profiles $u,v$, all $n\ge 1$ and all $\tau \le 1$.

*Proof sketch.* Such an $f$ would have to satisfy $f(1,3)=2$ and $f(1,3)=1$ by Theorem 3.4.
$\square$

In particular P1 — "the mixed knee is the midpoint" — fails, and the mediant sandwich is
*exactly* the truth: it is valid, and nothing sharper in terms of the component knees is.

---

## 4. The convex identity and mass-share rigidity

The three witnesses of Theorem 3.4 differ not in their knees but in their masses. That
intuition is exactly right, and it can be made into an identity.

**Theorem 4.1 (Convex-Combination Identity).** With $\lambda$ the mass share of
Definition 2.10,
$$R_{\mathrm{pool}_{a,b}(u,v)}(n,k) \;=\; \lambda\,R_u(n,k) \;+\; (1-\lambda)\,R_v(n,k)$$
for every budget $k$.

*Proof sketch.* Expand both sides over the common denominator $aH_u(n)+bH_v(n)$: the left
side is $\frac{aH_u(\min(k,n)) + bH_v(\min(k,n))}{aH_u(n)+bH_v(n)}$, and the right side is
$\frac{aH_u(n)}{D}\cdot\frac{H_u(\min(k,n))}{H_u(n)} + \frac{bH_v(n)}{D}\cdot\frac{H_v(\min(k,n))}{H_v(n)}$
with $D$ the same denominator; the component denominators cancel. $\square$

Theorem 3.2 is the corollary that a convex combination lies between its endpoints. The
identity says more: it lets one read the mixture off the dominant component alone, at a
*shifted gate*.

**Theorem 4.2 (shifted-gate bracket).** Suppose $\tau/\lambda \le 1$. Then
$$k^*_u\!\left(n, \frac{\tau - (1-\lambda)}{\lambda}\right) \;\le\; k^*_{\mathrm{pool}_{a,b}(u,v)}(n,\tau) \;\le\; k^*_u\!\left(n, \frac{\tau}{\lambda}\right).$$

*Proof sketch.* By Theorem 4.1 and $0 \le R_v \le 1$ we have
$\lambda R_u(n,k) \le R_{\mathrm{pool}}(n,k) \le \lambda R_u(n,k) + (1-\lambda)$. If $u$
clears the raised gate $\tau/\lambda$ at budget $k$ then the mixture clears $\tau$ there,
giving the upper bound; if the mixture clears $\tau$ at $k$ then $u$ clears the lowered
gate $(\tau-(1-\lambda))/\lambda$, giving the lower bound. $\square$

The two shifted gates differ by $(1-\lambda)/\lambda$, the reciprocal mass ratio, which
tends to $0$ as $\lambda \to 1$. Combining with the staircase structure of Section 7 gives:

**Theorem 4.3 (Mass-Share Rigidity).** If the interval
$\bigl[(\tau-(1-\lambda))/\lambda,\ \tau/\lambda\bigr]$ is contained in a single step of the
staircase $\gamma \mapsto k^*_u(n,\gamma)$ — equivalently, if
$(1-\lambda)/\lambda$ is smaller than the distance from $\tau/\lambda$ to the nearest lower
step edge of $u$ — then
$$k^*_{\mathrm{pool}_{a,b}(u,v)}(n,\tau) \;=\; k^*_u(n,\tau).$$
Moreover the required mass share is strictly less than $1$ whenever the gate is strictly
interior to its step, so the hypothesis is always achievable and never vacuous.

*Proof sketch.* Both bounds of Theorem 4.2 are values of the same locally constant
staircase at two gates lying in one step; hence they coincide, and squeeze the mixture's
knee. Local constancy is Theorem 7.1. $\square$

**Corollary 4.4 ("starts at the easier domain's level").** Under mass dominance the
interleaved knee at context $2n$ equals $2k^*_u(n,\tau)$ up to the one-key parity slack of
Theorem 5.3, which by Theorem 5.6 cannot be removed.

This is the exact content of the empirical statement that the mixture at the shorter
context sits at code's level: at that context the code domain still owns enough of the
attention mass that the shifted-gate window fits inside one of its staircase steps.

---

## 5. Interleaving is pooling in doubled key units

### 5.1 The halving reduction

**Lemma 5.1 (matched prefixes).** For all $k$,
$$H_{\mathrm{mix}(u,v)}(2k) = H_u(k) + H_v(k), \qquad H_{\mathrm{mix}(u,v)}(2k+1) = H_u(k+1) + H_v(k).$$

*Proof sketch.* Induction on $k$: passing from $2k$ to $2k+2$ adds $u_k$ and $v_k$, one from
each domain, because the parity of the index selects the domain. $\square$

**Theorem 5.2 (Halving Reduction).** For all $n,k$,
$$R_{\mathrm{mix}(u,v)}(2n,2k) \;=\; R_{\mathrm{pool}_{1,1}(u,v)}(n,k).$$

*Proof sketch.* Numerators agree by Lemma 5.1 and $\min(2k,2n) = 2\min(k,n)$; denominators
agree by the same lemma at $k=n$. $\square$

This is the structural content of "mixed-domain attention has its own geometry": a mixed
context of length $2n$ is a pooled context of length $n$, in doubled key units.

### 5.2 The bracket, the parity law, and its sharpness

**Theorem 5.3 (mixed-knee bracket).** Write $Q = k^*_{\mathrm{pool}_{1,1}(u,v)}(n,\tau)$.
Then
$$2Q - 1 \;\le\; k^*_{\mathrm{mix}(u,v)}(2n,\tau) \;\le\; 2Q .$$

*Proof sketch.* Upper: by Theorem 5.2 the mixture passes the gate at budget $2Q$. Lower: if
the mixture's knee were at most $2Q-2 = 2(Q-1)$ then, again by Theorem 5.2, the pool would
pass at $Q-1$, contradicting minimality of $Q$. $\square$

**Theorem 5.4 (Parity Law).** If $Q \ge 1$ then
$$k^*_{\mathrm{mix}(u,v)}(2n,\tau) \;=\; \begin{cases} 2Q-1 & \text{if } \tau \le R_{\mathrm{mix}(u,v)}(2n,2Q-1),\\ 2Q & \text{otherwise.}\end{cases}$$
A single comparison at the odd budget $2Q-1$ decides the parity.

*Proof sketch.* Immediate from Theorem 5.3 together with the pass/fail characterisation of
the knee. $\square$

**Theorem 5.5 (both ends are generic).** For *every* pair of positive profiles and every
$n \ge 1$: (i) $R_{\mathrm{mix}(u,v)}(2n,1) > 0$; (ii) for every gate
$0 < \tau \le R_{\mathrm{mix}(u,v)}(2n,1)$ the mixed knee equals $2Q-1$, the odd end; and
(iii) at the top gate $\tau=1$ it equals $2Q$, the even end.

*Proof sketch.* (i) is positivity of $u_0$. (ii): such a $\tau$ is cleared at budget $1$, so
both the mixed and the pooled knee equal $1 = 2\cdot 1 - 1$. (iii): at $\tau=1$ both knees
are the full lengths, $2n$ and $n$. $\square$

**Corollary 5.6 (the one-key slack is irremovable).** No parity-free identity refines
Theorem 5.3: for every profile pair both ends of the bracket occur, the odd end on a gate
interval of positive length.

### 5.3 The doubling law

**Theorem 5.7 (Doubling Law).** For positive profiles and $\tau \le 1$,
$$2\,\Delta_{\mathrm{pool}_{1,1}(u,v)}(\tau,n) \;\le\; \Delta_{\mathrm{mix}(u,v)}(\tau,2n) + 1, \qquad \Delta_{\mathrm{mix}(u,v)}(\tau,2n) \;\le\; 2\,\Delta_{\mathrm{pool}_{1,1}(u,v)}(\tau,n) + 1 .$$
That is, $|\Delta_{\mathrm{mix}} - 2\Delta_{\mathrm{pool}}| \le 1$.

*Proof sketch.* Apply Theorem 5.3 at contexts $n$ and $2n$ and subtract; monotonicity of the
knee in the context length ensures the truncated subtractions behave as ordinary ones.
$\square$

**Corollary 5.8 (the doubling is not a cross-domain effect).** Interleaving a profile $u$
with a rescaled copy $c\,u$ ($c>0$) satisfies the same bounds with
$\Delta_{\mathrm{pool}} = \Delta_u$. In particular, if a pure domain has increment $4$, the
self-interleaved stream must have increment between $7$ and $9$.

*Proof sketch.* $\mathrm{pool}_{1,1}(u,cu) = (1+c)u$ and the retained mass is invariant under
positive rescaling, so the pooled curve is the pure curve. $\square$

### 5.4 What the reported grid actually pins down

A knee is observed on a grid of budgets, not continuously. The reported table records
failures at $8$ and $16$ and passes at $12$ and $20$.

**Theorem 5.9 (increment audit).** Let $w$ be a positive profile with
$R_w(512,8) < \tau \le R_w(512,12)$ and $R_w(1024,16) < \tau \le R_w(1024,20)$. Then
$$5 \;\le\; \Delta_w(\tau,512) \;\le\; 11 .$$

*Proof sketch.* The hypotheses give $9 \le k^*_w(512,\tau) \le 12$ and
$17 \le k^*_w(1024,\tau) \le 20$; subtract the extremes. $\square$

So the reported "+8" is a point inside a window of width $7$ that the grid cannot resolve
further; the doubling law predicts a value near $8$, and the audit says the data are
consistent with, but do not isolate, it. Reporting the bracket rather than the point is the
honest form of the measurement.

**Theorem 5.10 (mixed below prose at the short context).** If a mixed stream clears the gate
at budget $12$ at context $512$ while a prose stream does not, then
$k^*_{\mathrm{mix}}(512,\tau) \le 12 < k^*_{\mathrm{prose}}(512,\tau)$, so the mixed knee is
strictly below the prose knee. This is the falsifiable form of "starts low".

---

## 6. Many domains, and unequal rates

### 6.1 The multiplier is the number of domains

**Theorem 6.1 (round-robin reduction and bracket).** For a family $U$ of $m \ge 1$ positive
profiles,
$$R_{\mathrm{rr}_m U}(mn, mk) = R_{\mathrm{poolFam}_m U}(n,k),$$
and with $Q = k^*_{\mathrm{poolFam}_m U}(n,\tau)$,
$$mQ - (m-1) \;\le\; k^*_{\mathrm{rr}_m U}(mn,\tau) \;\le\; mQ .$$

*Proof sketch.* A prefix of length $mk$ of the round robin contains exactly the first $k$
keys of each of the $m$ domains, so head masses agree with the family pool; the bracket then
follows as in Theorem 5.3, the slack being one full cycle minus one. $\square$

**Theorem 6.2 (Multiplier Law).**
$$\bigl|\Delta_{\mathrm{rr}_m U}(\tau,mn) - m\,\Delta_{\mathrm{poolFam}_m U}(\tau,n)\bigr| \;\le\; m-1 .$$
The context-doubling increment of an $m$-domain round robin is exactly $m$ times the pooled
increment, up to $m-1$ keys. The case $m=2$ is Theorem 5.7.

A three-domain interleaving must therefore show a *tripled* increment: a direct experimental
consequence.

### 6.2 The rarest domain sets the multiplier

Balanced round robins suggest the multiplier is the number of domains. It is not.

**Theorem 6.3 (Rarest-Domain Multiplier).** For the $s{:}1$ interleaving of $u$ and $v$
(Definition 2.9), with $Q$ the knee of the corresponding uneven pool at context $n$,
$$(s+1)Q - s \;\le\; k^*_{s:1}\bigl((s+1)n,\tau\bigr) \;\le\; (s+1)Q,$$
and consequently the increment multiplier is $s+1 = 1/\min_j p_j$, the reciprocal of the
rarest mixing rate — not the number of domains, which is $2$ for every $s$.

*Proof sketch.* At budgets aligned to the period $s+1$, a prefix contains exactly $sk$ keys
of $u$ and $k$ keys of $v$, i.e. exactly the first $k$ keys of the uneven pool whose $k$-th
key bundles $s$ keys of $u$ with one key of $v$. Apply the argument of Theorem 6.1 with
cycle length $s+1$. $\square$

**Prediction 6.4.** A $90{:}10$ code/prose mixture should show a *tenfold*, not twofold,
context-doubling increment. This is the sharpest falsifiable consequence of the present
theory.

### 6.3 The fair-comparison dichotomy

**Theorem 6.5 (Dichotomy).** Fix $0 < \tau < 1$.

1. *(Gap ⇒ boundedness.)* If $u$ and $v$ decay geometrically, $u_{i+1} \le r\,u_i$ and
   $v_{i+1} \le r\,v_i$ with $r<1$, then there is a constant $C$, independent of the
   context, with $k^*_{\mathrm{mix}(u,v)}(2n,\tau) \le C$ and $k^*_u(n,\tau) \le C$ for all
   $n \ge 1$.
2. *(Gapless ⇒ unbounded excess.)* For the flat profile $w \equiv 1$ used as both domains,
   for every $K$ there is a context $n$ with
   $k^*_{\mathrm{mix}}(2n,\tau) - k^*_w(n,\tau) > K$.

*Proof sketch.* (1) For a geometrically decaying profile the tail beyond budget $K$ is at
most $r^K/(1-r)$ times the head key, so $r^K \le (1-\tau)(1-r)$ forces the gate to be
cleared at $K$ for every $n$; the mixture of two such profiles decays at the same rate in
doubled units. (2) For the flat profile $R_w(n,k) = k/n$, so $k^* = \lceil \tau n\rceil$ and
the mixed knee is $\lceil 2\tau n\rceil$; the excess is $\approx \tau n \to \infty$.
$\square$

Hence a growing mixed-versus-pure excess is evidence about the *spectrum* of the model's
attention, not about the corpus mixture — a point made quantitative in Section 10.

---

## 7. The gate staircase: resolution is conserved, not created

### 7.1 Steps and stability radii

**Theorem 7.1 (Staircase).** If $R_w(n,m) < \tau \le R_w(n,m+1)$ then $k^*_w(n,\tau) = m+1$.
Hence $\gamma \mapsto k^*_w(n,\gamma)$ is a nondecreasing step function whose step at value
$k$ is the interval $\bigl(R_w(n,k-1), R_w(n,k)\bigr]$, of width exactly
$\mathrm{sw}_w(n,k) = w_k/H_w(n)$ for $k<n$.

**Theorem 7.2 (Stability radius).** Let $K = k^*_w(n,\tau) \ge 1$. Every gate $\tau'$ with
$$|\tau' - \tau| \;<\; \min\bigl(\tau - R_w(n,K-1),\ R_w(n,K) - \tau\bigr)$$
satisfies $k^*_w(n,\tau') = K$. The radius is computable from two retained-mass values the
experiment already records.

**Theorem 7.3 (Sharpness).** If the gate sits exactly on a step edge, $\tau = R_w(n,k)$ with
$0<k<n$, then $k^*_w(n,\tau) = k$ while $k^*_w(n,\tau+\varepsilon) = k+1$ for every
$0 < \varepsilon \le \mathrm{sw}_w(n,k)$. Hence the radius of Theorem 7.2 cannot be enlarged:
a knee reported at a gate near a step edge measures the gate, not the model.

### 7.2 Interleaving subdivides steps

**Theorem 7.4 (step splitting).** For every $k$,
$$\mathrm{sw}_{\mathrm{mix}(u,v)}(2n,2k) + \mathrm{sw}_{\mathrm{mix}(u,v)}(2n,2k+1) \;=\; \mathrm{sw}_{\mathrm{pool}_{1,1}(u,v)}(n,k),$$
and in the balanced case $v = u$ each mixed sub-step is exactly half of the pooled step.
More generally, for a round robin of $m$ domains the sub-step at index $mk+j$ is the
normalised mass of key $k$ of domain $j$, and the $m$ sub-steps sum to the pooled step.

*Proof sketch.* Both mixed sub-steps have the common denominator $H_u(n)+H_v(n)$ (Lemma 5.1
at $k=n$) and numerators $u_k$ and $v_k$, whose sum is the pooled key mass. $\square$

**Corollary 7.5 (resolution divides by $m$).** Some sub-step is at most $1/m$ of the pooled
step it refines, and the bound is realised: there is an explicit gate at which a
perturbation of that size already moves the round-robin knee by one key. For $m=2$: the
finest gate distinction a mixed protocol can make is at most half of what the corresponding
pure protocol can make.

### 7.3 Signal-to-resolution accounting

Define the **density** of a protocol at a budget as (context-doubling increment) $\times$
(resolution), where resolution is the narrowest sub-step refining the relevant pooled step.

**Theorem 7.6 (Conservation inequality).** For every family of domains, the interleaved
density exceeds the pooled density by at most one pooled step. Interleaving is never a
measurement amplifier.

**Theorem 7.7 (Exact case).** When the $m$ interleaved domains are copies of one profile,
the resolution is exactly $1/m$ of the pooled step and the two densities agree up to
$(1-1/m)$ of a pooled step; the increment slack $m-1$ of Theorem 6.2 is exactly one
resolution unit.

**Theorem 7.8 (Unbounded loss without balance).** For every constant $C$ there is a
two-domain mixture — take the second domain faint, weights $1$ and $\varepsilon$ — whose
resolution is smaller than the pooled step divided by $C$. Hence density is *not* conserved
in general; equality is confined to balanced mixtures, and unbalanced mixing strictly
destroys information.

*Proof sketch.* The faint sub-step is $\varepsilon/(1+\varepsilon)$ of the pooled step; let
$\varepsilon \to 0$. $\square$

The practical reading: the doubled increment of a balanced mixed protocol buys nothing —
it is exactly offset by halved gate resolution — and a *ratio* sweep is not a sequence of
equally informative measurements, so each point of such a sweep needs its own resolution
correction.

---

## 8. Block interleaving, exactly

The physical protocol interleaves blocks of roughly five hundred characters, not single
keys. Does the block size matter?

**Theorem 8.1 (aligned invariance).** For $b \ge 1$,
$$H_{\mathrm{block}_b(u,v)}(2bk) = H_u(bk) + H_v(bk), \qquad R_{\mathrm{block}_b(u,v)}(2bn,2bk) = R_{\mathrm{pool}_{1,1}(u,v)}(bn,bk).$$
At block-aligned budgets the block size is invisible: every block size gives the same curve
as single-key alternation, read at the corresponding budget.

**Corollary 8.2 (quantisation only).** With $Q = k^*_{\mathrm{pool}_{1,1}(u,v)}(bn,\tau)$,
$$2Q - 2b \;<\; k^*_{\mathrm{block}_b(u,v)}(2bn,\tau) \;\le\; 2Q + 2b,$$
so a block-size sweep should show *no* systematic trend, only $\pm b$ jitter. A reported
block-size effect larger than one block is evidence of something outside this model
(tokenisation boundaries, positional effects).

The $\pm b$ window is, however, an artefact of only ever evaluating at aligned budgets.
Inside a block pair the mixture accumulates one domain at a time.

**Theorem 8.3 (intra-block master identities).** For $b \ge 1$, $0 \le r \le b$ and any $q$,
$$H_{\mathrm{block}_b(u,v)}(2bq + r) = H_u(bq+r) + H_v(bq),$$
$$H_{\mathrm{block}_b(u,v)}(2bq + b + r) = H_u(bq+b) + H_v(bq+r).$$

*Proof sketch.* Induction on $r$, using the index computation that the key at position
$2bq+i$ (for $i<b$) is key $bq+i$ of the first domain, and the key at $2bq+b+i$ is key
$bq+i$ of the second. In the first half only the first domain accumulates on top of matched
prefixes of both; in the second half only the second accumulates, on top of a complete extra
block of the first. $\square$

Dividing by the aligned denominator $H_u(bn)+H_v(bn)$ gives the corresponding retained-mass
identities, and hence:

**Theorem 8.4 (Exact blocked knee).** Fix $q < n$ and $1 \le r \le b$. If
$$\frac{H_u(bq+r-1)+H_v(bq)}{H_u(bn)+H_v(bn)} < \tau \le \frac{H_u(bq+r)+H_v(bq)}{H_u(bn)+H_v(bn)}$$
then $k^*_{\mathrm{block}_b(u,v)}(2bn,\tau) = 2bq + r$; and symmetrically, with the
second-half identity, for budgets in the second half of a block pair. Two component-level
inequalities — one failing, one passing — determine the blocked knee to a single integer.
No bracket remains.

Note that these inequalities involve only head masses of the *pure* domains: the blocked
knee can be evaluated from a domain-wise attention table without ever building the mixed
context.

**Theorem 8.5 (sharper aligned upper bound).** With $Q = k^*_{\mathrm{pool}_{1,1}(u,v)}(bn,\tau) < bn$,
$$k^*_{\mathrm{block}_b(u,v)}(2bn,\tau) \;\le\; 2Q + b - (Q \bmod b),$$
halving the quantisation error the protocol must tolerate compared with Corollary 8.2.

*Proof sketch.* Write $Q = bq + s$ with $s = Q \bmod b < b$. By the second-half identity at
$(q,s)$ the blocked mixture already passes the gate at budget $2bq + b + s$, because
$H_u(bq+b) \ge H_u(Q)$ and $H_v(bq+s) = H_v(Q)$, so its numerator dominates the pooled
numerator at $Q$, which passes. Then
$2bq + b + s = 2Q + b - s$. $\square$

---

## 9. The mixing-ratio sweep: monotone, with one computable kink

Fix the second domain's weight at $1$ and sweep the first domain's weight $a > 0$.

**Definition 9.1 (domination).** $u$ *uniformly dominates* $v$ at context $n$ if
$R_v(n,k) \le R_u(n,k)$ for every budget $k$.

**Theorem 9.2 (ratio monotonicity).** Under domination, if $a_2 b_1 \le a_1 b_2$ then
$R_{\mathrm{pool}_{a_2,b_2}}(n,k) \le R_{\mathrm{pool}_{a_1,b_1}}(n,k)$ for every $k$, and
hence $k^*_{\mathrm{pool}_{a_1,b_1}}(n,\tau) \le k^*_{\mathrm{pool}_{a_2,b_2}}(n,\tau)$.
Shifting weight to the easier domain can only lower the knee.

*Proof sketch.* Clearing denominators, the inequality between two mediants reduces to
$(a_1b_2 - a_2b_1)\bigl(H_u(\min(k,n))H_v(n) - H_v(\min(k,n))H_u(n)\bigr) \ge 0$; the first
factor is the ratio hypothesis and the second is domination. $\square$

**Corollary 9.3 (predicted shape of a sweep).** Under domination the sweep is a monotone
staircase running from the easier domain's knee to the harder domain's knee, with no
overshoot at either end and no reversal in between. A measured sweep that is non-monotone
refutes domination, checkable curve by curve.

**Definition 9.4 (collapse region and critical weight).**
$\mathcal{C} = \{a>0 : k^*_{\mathrm{pool}_{a,1}(u,v)}(n,\tau) = k^*_u(n,\tau)\}$ and
$a^{*} = \inf \mathcal{C}$.

**Theorem 9.5 (single phase boundary).** Under domination, $\mathcal{C}$ is upward closed;
under strict gate interiority it is non-empty, with an explicit witness weight computable
from the two component head masses. Hence the sweep is a step function of $a$ with one
identified threshold: strictly above $a^{*}$ the knee has collapsed onto the dominant
knee, strictly below it has not. A single balanced measurement whose pooled knee misses the
dominant knee already forces $a^{*} > 1$, so the boundary is interior.

**Theorem 9.6 (linearity of the pass condition).** For $k \le n$ and $a>0$,
$$\tau \le R_{\mathrm{pool}_{a,1}(u,v)}(n,k) \iff \tau\bigl(aH_u(n) + H_v(n)\bigr) \le aH_u(k) + H_v(k),$$
a *linear* inequality in $a$. Consequently, if the dominant excess
$D = H_u(k) - \tau H_u(n)$ is positive, the pass set is the half-line $\{a \ge \pi(k)\}$
with endpoint
$$\pi(k) \;=\; \frac{\tau H_v(n) - H_v(k)}{H_u(k) - \tau H_u(n)}.$$

**Theorem 9.7 (Closed formula for the critical weight).** Under domination, with
$K = k^*_u(n,\tau)$ and $D = H_u(K) - \tau H_u(n) > 0$,
$$a^{*} \;=\; \max\bigl(0,\ \pi(K)\bigr) \;=\; \max\left(0,\ \frac{\tau H_v(n) - H_v(K)}{H_u(K) - \tau H_u(n)}\right),$$
and $a^{*} > 0$ **iff** $H_v(K) < \tau H_v(n)$, i.e. exactly when the weak domain fails the
gate at the dominant knee.

*Proof sketch.* Under domination the pooled knee is never below $K$ (Corollary 3.3 plus
domination), so collapse at weight $a$ is equivalent to the pooled profile passing the gate
at the single budget $K$; by Theorem 9.6 that is the half-line $\pi(K) \le a$, whose
infimum, intersected with $a>0$, is $\max(0,\pi(K))$. $\square$

**Example 9.8.** For $u = u_A = (10,1,1,1)$, $v=(1,1,1,1)$, $n=4$, $\tau=0.7$: $K=1$,
$H_u(1)=10$, $H_u(4)=13$, $H_v(1)=1$, $H_v(4)=4$, so
$$a^{*} = \frac{0.7\cdot 4 - 1}{10 - 0.7\cdot 13} = \frac{1.8}{0.9} = 2 .$$
The full sweep is: knee $3$ for $a < 8/19$, knee $2$ on $[8/19, 2)$, knee $1$ for
$a \ge 2$ — two kinks, both predicted by the same formula ($\pi(2) = 8/19$, $\pi(1)=2$).
The balanced protocol $a=1$ sits strictly below the critical weight, which is exactly why
its knee ($2$) exceeds the dominant knee ($1$).

The practical payoff: **a mixing-ratio sweep needs no mixed measurement**. Its kinks are
predicted by four head masses of the two pure domains.

---

## 10. A budget measurement is a spectral measurement

**Theorem 10.1 (explicit universal budget).** If $w_{i+1} \le r\,w_i$ for all $i$, with
$0<r<1$, and $r^K \le (1-\tau)(1-r)$, then $k^*_w(n,\tau) \le K$ for *every* context length
$n$. The criterion is monotone in $r$: a profile decaying at rate $r$ decays at every larger
rate.

*Proof sketch.* $w_i \le r^i w_0$, so the tail beyond $K$ is at most $w_0 r^K/(1-r)$ while
the head is at least $w_0$; the retained fraction at $K$ is therefore at least
$1/(1 + r^K/(1-r)) \ge \tau$ under the stated inequality. $\square$

**Theorem 10.2 (lower estimator).** Contrapositively, a single observation $k^*_w(n,\tau) > K$
*refutes* every candidate decay ratio $r_0$ with $r_0^K \le (1-\tau)(1-r_0)$; the true ratio
must exceed $r_0$. For the interleaved protocol the same conclusion holds with the threshold
doubled: a mixed knee exceeding $2K$ at context $2n$ certifies $r_0 < r$.

**Theorem 10.3 (upper estimator).** Let $w$ be nonincreasing with a *floor rate* $q>0$,
meaning $q\,w_i \le w_{i+1}$ for all $i$, and let $n \ge 2K$. Then
$$R_w(n,K) \;\le\; \frac{1}{1 + q^{2K}},$$
independently of the context length. Consequently a measurement $k^*_w(n,\tau) \le K$
certifies
$$q^{2K} \;\le\; \frac{1-\tau}{\tau}.$$

*Proof sketch.* Monotonicity gives $H_w(K) \le K w_0$. The floor rate gives
$w_i \ge q^i w_0$, so the *second* block of $K$ keys carries at least $K q^{2K} w_0$ of mass.
Hence $R_w(n,K) \le \frac{Kw_0}{Kw_0 + Kq^{2K}w_0}$. Rearranging the pass inequality
$\tau \le R_w(n,K)$ yields the bound on $q^{2K}$. $\square$

**Theorem 10.4 (two-sided spectral bracket).** A single exact knee value $k^*_w(n,\tau)=K_0$
brackets the profile's spectrum from both sides: every candidate $r_0$ passing the criterion
of Theorem 10.1 at $K_0 - 1$ is excluded from below, and the floor rate satisfies
$q^{2K_0} \le (1-\tau)/\tau$ from above.

**Example 10.5.** Take the reported mixed knee $k^*_{\mathrm{mix}}(2n, 0.99) = 20$. On the
one hand $K = 9$ passes the criterion of Theorem 10.1 at $r_0 = 1/2$, since
$(1/2)^9 = 1/512 \le (1-0.99)(1-1/2) = 1/200$, and the observed knee exceeds $2K = 18$; by
Theorem 10.2 the model's decay ratio satisfies $r > 1/2$. On the other hand the halving
reduction (Theorem 5.2) forces the *pooled* knee to be at most $10$, and Theorem 10.3 at
$K=10$ then gives $q^{20} \le (1-0.99)/0.99 = 1/99$, i.e. $q < 4/5$. The two reported
integers therefore pin the model's per-key ratio into the window $(1/2, 4/5)$ — a genuine
two-sided spectral measurement of the model, not of the corpus.

---

## 11. Algorithms

Three procedures suffice to compute everything above from a domain-wise attention table.

**A. Knee by prefix scan.** Given a profile prefix $w_0,\dots,w_{n-1}$ and a gate $\tau$,
accumulate head mass until $H \ge \tau H_w(n)$ and return the count. Time $O(n)$, space
$O(1)$ after one pass to compute $H_w(n)$. Correctness is Theorem 7.1.

**B. Blocked-mixture knee without building the mixture.** Given pure head-mass arrays
$H_u, H_v$, a block size $b$, a context $n$ and a gate $\tau$: for each block pair index
$q < n$ and offset $r \le b$, evaluate the two intra-block identities of Theorem 8.3 and
return the first budget whose retained value reaches $\tau$. Time $O(bn)$ with $O(1)$ work
per candidate budget, and no mixed context is ever materialised.

**C. Ratio-sweep kink prediction.** Given $H_u, H_v$, $n$, $\tau$: compute $K = k^*_u(n,\tau)$
by A, then $a^{*} = \max\bigl(0, (\tau H_v(n) - H_v(K))/(H_u(K) - \tau H_u(n))\bigr)$ by
Theorem 9.7. Time $O(n)$. The full staircase of the sweep is obtained by evaluating $\pi(k)$
at every budget $k \le n$ and sorting the resulting kinks.

A fourth routine, the **stability audit**, should accompany every reported knee: compute
$\min(\tau - R_w(n,K-1),\ R_w(n,K)-\tau)$ (Theorem 7.2) and report it alongside $K$. If the
radius is small relative to gate uncertainty, the reported knee is a property of the gate.

---

## 12. Discussion and limitations

**On P1, P2, P3.** P1 (midpoint) is false in the strongest sense: no function of the
component knees exists (Corollary 3.5). P2 (reaches the harder level) is a possible but not
a necessary behaviour; the cage of Corollary 3.3 permits it, and mass-share rigidity
explains why the mixture may sit at either end. P3 (own structure) is true, but the
structure is arithmetic — mediant, convex combination with weight the mass share, and a
staircase whose steps are individual key masses — rather than a novel cross-domain
interaction. Corollary 5.8 is decisive here: the doubled increment appears when a domain is
interleaved with a rescaled copy of *itself*.

**Hypotheses.** Ratio monotonicity (Theorem 9.2), the phase boundary (Theorem 9.5) and the
closed formula (Theorem 9.7) all require *domination*; the witnesses of Theorem 3.4 show
what fails without it. The rarest-domain multiplier (Theorem 6.3) covers rational rates
whose minority share is $1/(s+1)$; general Beatty-type patterns are not covered, and the
statement fixes the pattern explicitly rather than quantifying over rate vectors. The
spectral estimators require, respectively, a geometric upper envelope and a floor rate on a
sorted profile.

**What the theory forbids.** A block-size sweep showing a systematic trend beyond one block
(Corollary 8.2); a mixing-ratio sweep that drifts rather than kinks under domination
(Corollary 9.3); an interleaved protocol that is more informative than its pooled
counterpart (Theorem 7.6); a mixed increment differing from $m$ (or $s+1$) times the pooled
increment by more than $m-1$ (or $s$) keys. Any of these observations would falsify the
model, and each is cheap to test.

**Measurement hygiene.** Theorems 7.2, 7.3 and 5.9 together say that a bare knee value is
not a measurement. A knee must be reported with its stability radius and with the grid
bracket the sampling actually pins down; on the reported grid the "+8" increment is only
pinned to $[5,11]$.

---

## 13. Future directions

* **Mixing-ratio sweep with resolution correction.** Theorem 7.8 shows that unbalanced
  points of a sweep are less informative than balanced ones; a sweep should therefore be
  reported with per-point resolution weights, and the closed formula of Theorem 9.7 should
  be checked directly against measured kinks.
* **Unequal rates beyond $s{:}1$.** Extend Theorem 6.3 to general rational rate vectors and
  to irrational (Beatty) interleaving patterns; conjecturally the multiplier is
  $1/\min_j p_j$ in full generality.
* **Block-size sensitivity, empirically.** Theorem 8.4 makes the blocked knee exactly
  computable from pure-domain tables; comparing that prediction with a measured block-size
  sweep is a direct test of the whole framework.
* **Multi-domain protocols.** Three- and four-way interleavings should show tripled and
  quadrupled increments (Theorem 6.2) with correspondingly divided resolution
  (Corollary 7.5); the invariance of the density product is the sharpest available test.
* **Spectral estimation at scale.** Theorem 10.4 turns budget tables into two-sided
  brackets on the per-key decay ratio; running the estimator across model scales converts a
  budget-measurement programme into a spectral-measurement programme.
* **Other domain pairs and larger models.** The theory is model-free, so the predictions
  transfer verbatim; discrepancies would localise precisely which hypothesis
  (domination, floor rate, geometric envelope) fails for a given model.

---

## 14. Conclusion

The verdict "the mixed domain starts low and rises fast" is correct, and both halves are now
explained — by different mechanisms. *Starts low* is mass-share rigidity: when one domain
owns enough of the attention mass, the mixture's key budget equals that domain's budget
exactly, with no error term. *Rises fast* is a change of units: interleaving is pooling with
each key split in two, so increments are automatically multiplied by the interleaving
period, and this happens even when a domain is interleaved with a copy of itself. The
apparent novelty of mixed-domain attention resolves into a mediant, a convex combination, and
a staircase — and, having resolved, becomes predictive: a tenfold increment for a $90{:}10$
mixture, no trend in a block-size sweep, one computable kink in a ratio sweep, and a
two-sided bracket on the model's attention spectrum from two integers in a table.
