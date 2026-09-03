# Real-Parameter Scale Flow on Knee Chains

### A tropical one-parameter extension of the octave shift law, with an interpolation criterion, a generator theorem, and an exact discretisation defect

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

Measured deployment tables for transformer inference exhibit a striking regularity: the minimal per-query key budget required to avoid quality degradation — the *knee* — is generated, across a whole family of model sizes and context lengths, by a single one-dimensional chain translated by one context octave per octave of model scale. Formally, the knee table obeys $k(s,j) = K(j \dot{-} s)$, where $j$ indexes context octaves, $s$ indexes model scale, $K$ is the base chain and $\dot{-}$ is truncated subtraction. This is an action of the additive monoid $(\mathbb{N},+)$ on chains, and it leaves unmeasured model sizes formally inexpressible.

We show that the extension of this action to a real scale parameter is canonical rather than merely plausible, and we determine exactly how much of the resulting continuous table is forced by the data. The pivot is the observation that the clamp $\max(t-\sigma,0)$ appearing in any real-parameter reading of the law *is* truncated subtraction in the ordered-subtraction monoid $\mathbb{R}_{\ge 0}$; the discrete picture therefore lifts verbatim.

Our results are: (i) the shift extends to a genuine monoid action of $(\mathbb{R}_{\ge0},+)$ on real knee profiles, restricting cell-for-cell to the measured table; (ii) a **continuous rigidity theorem** — the real exchange law together with base-context inertia determines the entire two-variable table from its base profile, with the induction of the discrete argument replaced by a single translation; (iii) an **interpolation criterion** — a monotone real profile through the measured cells exists if and only if the chain is monotone, via an explicit ramp-basis construction; (iv) an explicit **failure of uniqueness**, with ramp and staircase interpolants disagreeing by four keys at the half-octave, and its exact repair — a **generator theorem** showing that monotonicity plus stationary increments forces affinity, proved by a Cauchy floor-squeeze requiring no continuity, measurability or rationality hypothesis; (v) identification of the **generator of the flow as the keys-per-octave rate**, with the table satisfying the transport equation $\partial_\sigma k + \partial_t k = 0$; (vi) a **budget adjunction** $k^*(\sigma,t)\le b \iff t \le \sigma + R$ with reach $R = (b-k_0)/\delta$, whose served boundary is a line of slope one; (vii) an **exact discretisation defect** — the number of served cells of the discrete table exceeds the area under the continuous served boundary by exactly $S/2$ over a scale window of length $S$; and (viii) a **tropical reading** — the table is a tropical binomial whose corner locus is exactly the diagonal $t=\sigma$, invariant under the flow direction $(1,1)$, which is the infinitesimal geometry behind the exchange law.

As a falsifiable consequence we predict the knee chain of an unmeasured 3B model: at 2048 tokens of context its knee lies rigorously in $(18, 18.4)$, giving a deployable budget of 19 keys — a value no integer scale index can produce.

**Keywords:** tropical geometry, max-plus algebra, monoid action, ordered subtraction, monotone interpolation, Cauchy functional equation, transport equation, inference key budgets.

---

## 1. Introduction

### 1.1 The measured object

Consider a family of transformer language models of increasing parameter count, evaluated at increasing context lengths, and for each (model, context) pair record the smallest per-query *key budget* at which task quality has not yet degraded. Plotted against budget, quality falls sharply and then plateaus; the corner of that curve is the **knee**, and the recorded number is the knee budget.

Index the context lengths by octaves: column $j \in \mathbb{N}$ corresponds to context length $512 \cdot 2^{j}$. Index the models by a **scale index** $s$. For the family we study — call it the reference family — the measured table is

| model | $j=0$ (512) | $j=1$ (1024) | $j=2$ (2048) | $j=3$ (4096) |
|---|---|---|---|---|
| 0.5B ($s=0$) | 16 | 20 | 24 | 28 |
| 1.5B ($s=1$) | 16 | 16 | 20 | 24 |
| 7B ($s=2$)   | 16 | 16 | 16 | 20 |

Each row is the row above it shifted one column to the right, with the vacated left cells filled by the base value 16.

### 1.2 The discrete octave shift law

**Definition 1.1 (Chain).** A *chain* is a function $K : \mathbb{N} \to \mathbb{N}$, interpreted as the knee budget at $j$ octaves of context above the base context of a reference model.

**Definition 1.2 (Discrete shift).** For $s \in \mathbb{N}$ the *shift* of a chain is $(\mathrm{shift}\,K\,s)(j) = K(j \dot{-} s)$, with $\dot{-}$ truncated subtraction on $\mathbb{N}$.

The discrete theory establishes that a measured scale family — a two-variable table satisfying the *exchange law* $k(s+a, j+a) = k(s,j)$ and *base-context inertia* $k(s,0)=k(0,0)$ — is exactly $k(s,j) = K(j \dot{-} s)$ for its base chain $K = k(0,\cdot)$, and that $\mathrm{shift}$ is an action of $(\mathbb{N},+)$. For the reference family the base chain is arithmetic, $K(j) = 16 + 4j$.

### 1.3 The problem

An action of $(\mathbb{N},+)$ has no element strictly between "shift by one" and "shift by two". A 3B model lies between the 1.5B and 7B rows, and the discrete law is structurally incapable of assigning it a budget. The competing hypothesis in the literature is blunt: *scale acts only discretely, and each model family needs its own chain*.

This paper tests that hypothesis by formalising the extension as a monotone-interpolation problem, proving existence, delimiting non-uniqueness exactly, and identifying the additional axiom that restores uniqueness. We then compute the resulting continuous table, sweep the 3B cell, and quantify the exact error incurred by discretising the scale axis.

---

## 2. The scale flow

### 2.1 Ordered subtraction is the hinge

The informal continuous law one would write down is $k^*(\sigma,j) = K_0\big(\max(j-\sigma,0)\big)$. The clamp $\max(\cdot,0)$ looks like an ad-hoc guard. It is not. In any commutative ordered monoid with ordered subtraction, $x \dot{-} y$ is characterised by the adjunction $x \dot{-} y \le z \iff x \le y + z$. On $\mathbb{N}$ this is truncated subtraction; on $\mathbb{R}_{\ge0}$ it is exactly $\max(x-y,0)$. The two formulas are one formula in two monoids.

**Definition 2.1 (Real knee profile).** A *real knee profile* is a function $K_0 : \mathbb{R}_{\ge0} \to \mathbb{R}$. The value $K_0(x)$ is the key budget at $x$ octaves of context above the model's own base context. The domain is $\mathbb{R}_{\ge0}$ because a model is never queried below its base context; the chain is clamped there, not extrapolated.

**Definition 2.2 (Scale flow).** For $\sigma \in \mathbb{R}_{\ge0}$ define $\rho_\sigma K_0 : \mathbb{R}_{\ge0} \to \mathbb{R}$ by
$$(\rho_\sigma K_0)(t) = K_0(t \dot{-} \sigma) = K_0\big(\max(t-\sigma,0)\big).$$

### 2.2 The flow is a monoid action

**Theorem 2.3 (Extension of the shift action).** For every real profile $K_0$ and all $a,b \in \mathbb{R}_{\ge0}$:
1. $\rho_0 K_0 = K_0$;
2. $\rho_b(\rho_a K_0) = \rho_{a+b} K_0$;
3. (*exchange*) $(\rho_{\sigma+a}K_0)(t+a) = (\rho_\sigma K_0)(t)$ for all $\sigma,t,a \ge 0$;
4. (*boundary*) if $t \le \sigma$ then $(\rho_\sigma K_0)(t) = K_0(0)$.

Consequently $\sigma \mapsto \rho_\sigma$ is an action of the additive monoid $(\mathbb{R}_{\ge0},+)$ on real knee profiles.

*Proof sketch.* (1) is $t \dot{-} 0 = t$. (2) is the ordered-subtraction identity $(t \dot{-} a)\dot{-} b = t \dot{-} (a+b)$, which holds in any such monoid and follows from the adjunction. (3) is cancellation of a common summand, $(t+a)\dot{-}(\sigma+a) = t \dot{-} \sigma$. (4) is $t \dot{-} \sigma = 0$ for $t \le \sigma$. $\square$

The statement "the shift action extends from $(\mathbb{N},+)$ to $(\mathbb{R}_{\ge0},+)$" is therefore a theorem about a structure, not a slogan: $\rho$ is a bona fide monoid action, and item (2) is the associativity law of that action.

**Monotonicity.** If $K_0$ is monotone then so is $\rho_\sigma K_0$ for every $\sigma$ (since $t \mapsto t \dot{-} \sigma$ is monotone), and for fixed $t$ the map $\sigma \mapsto (\rho_\sigma K_0)(t)$ is *antitone* (since $\sigma \mapsto t \dot{-} \sigma$ is antitone).

### 2.3 The flow restricts to the measurements

**Lemma 2.4 (Cast compatibility).** For $s,j \in \mathbb{N}$, the image of $j \dot{-} s$ under the inclusion $\mathbb{N}\hookrightarrow \mathbb{R}_{\ge0}$ equals $(j) \dot{-} (s)$ computed in $\mathbb{R}_{\ge0}$.

*Proof sketch.* Two cases. If $j \le s$ both sides are $0$. If $s \le j$, then $(j-s) + s = j$ in $\mathbb{N}$, hence also in $\mathbb{R}_{\ge0}$ after casting, and $x + s \mapsto x$ under $\dot{-} s$ recovers the claim. $\square$

**Theorem 2.5 (Restriction).** Let $K$ be a measured chain and $K_0$ a real profile with $K_0(n) = K(n)$ for all $n \in \mathbb{N}$. Then for all $s,j \in \mathbb{N}$,
$$(\rho_s K_0)(j) = K(j \dot{-} s) = k(s,j).$$
The continuous table reproduces every measured cell.

*Proof sketch.* Immediate from Lemma 2.4 and the interpolation hypothesis. $\square$

This is the legitimacy condition for the whole programme: the extension adds structure between the measured cells and disturbs none of them.

---

## 3. Continuous rigidity

**Definition 3.1 (Scale flow table).** A *scale flow* is a function $F : \mathbb{R}_{\ge0}\times\mathbb{R}_{\ge0} \to \mathbb{R}$ such that
* $F(0,\cdot)$ is monotone (*base monotonicity*),
* $F(\sigma+a, t+a) = F(\sigma,t)$ for all $\sigma,t,a \ge 0$ (*exchange*),
* $F(\sigma, 0) = F(0,0)$ for all $\sigma$ (*base-context inertia*).

**Theorem 3.2 (Continuous Rigidity).** Every scale flow satisfies
$$F(\sigma,t) \;=\; F\big(0,\, t \dot{-} \sigma\big) \;=\; \big(\rho_\sigma F(0,\cdot)\big)(t).$$

*Proof sketch.* Fix $\sigma, t$.
*Case $t \le \sigma$.* Apply exchange with base pair $(\sigma - t,\, 0)$ and increment $a = t$: since $(\sigma-t)+t = \sigma$ and $0 + t = t$, we get $F(\sigma,t) = F(\sigma-t, 0)$. Base-context inertia gives $F(\sigma-t,0) = F(0,0)$, and $t \dot{-} \sigma = 0$, so both sides equal $F(0,0)$.
*Case $\sigma \le t$.* Apply exchange with base pair $(0,\, t-\sigma)$ and increment $a=\sigma$: $F(\sigma,t) = F(0, t-\sigma) = F(0, t\dot{-}\sigma)$. $\square$

Note the shape of the argument. The discrete analogue proves the same statement by induction on the number of scale steps; the real-parameter version needs no induction, because a single translation reaches any cell. Continuity of the parameter *simplifies* the rigidity proof.

**Corollary 3.3 (Structural refutations).** Let $F$ be a scale flow.
1. *(No amplification of sensitivity.)* For each fixed $t$, $\sigma \mapsto F(\sigma,t)$ is antitone: a larger model never requires a larger budget at the same context.
2. *(No flattening.)* If $F(0,\cdot)$ is unbounded above, then so is $F(\sigma,\cdot)$ for every $\sigma$.
3. Every $F(\sigma,\cdot)$ is monotone.

*Proof sketch.* (1) By Theorem 3.2, $F(\sigma,t)=F(0,t\dot{-}\sigma)$ and $\sigma\mapsto t\dot{-}\sigma$ is antitone; compose with base monotonicity. (2) Given a bound $b$, pick $t$ with $F(0,t) > b$; then $F(\sigma, t+\sigma) = F(0,(t+\sigma)\dot{-}\sigma) = F(0,t) > b$. (3) Compose base monotonicity with monotonicity of $t \mapsto t \dot{-} \sigma$. $\square$

These refute, structurally rather than empirically, the folklore claims that scale amplifies context sensitivity and that scale flattens the context axis. Scaling *translates* the difficulty curve.

**Theorem 3.4 (Lipschitz transport).** Let $F$ be a scale flow whose base profile has slope at most $\delta \ge 0$, i.e. $F(0,y)-F(0,x) \le \delta(y-x)$ whenever $x \le y$. Then for all $\sigma,t,h \ge 0$,
$$\big|F(\sigma,t) - F(\sigma+h, t)\big| \;\le\; \delta h.$$

*Proof sketch.* By Corollary 3.3(1) the difference is nonnegative, so the absolute value may be dropped. By Theorem 3.2 it equals $F(0, t\dot{-}\sigma) - F(0, t \dot{-} (\sigma+h))$, and $t\dot{-}(\sigma+h) \le t \dot{-} \sigma$, so the slope bound applies with gap $(t\dot{-}\sigma)-(t\dot{-}(\sigma+h))$. The final step is the ordered-subtraction inequality $(t\dot{-}\sigma)-(t\dot{-}(\sigma+h)) \le h$, which follows from $t \le (t\dot{-}(\sigma+h)) + \sigma + h$. $\square$

Deployment tables built from the flow are therefore Lipschitz in scale: interpolating the model-size axis introduces no cliffs between measured rows.

**Theorem 3.5 (Real-rate identifiability).** If $K_0$ is strictly monotone and $\rho_a K_0 = \rho_b K_0$, then $a=b$.

*Proof sketch.* Suppose $a < b$. Evaluate both sides at $t=b$: the right side is $K_0(0)$, the left is $K_0(b-a)$ with $b - a > 0$, contradicting strict monotonicity. Symmetrically for $b<a$. $\square$

Passing from $(\mathbb{N},+)$ to $(\mathbb{R}_{\ge0},+)$ therefore introduces no gauge freedom in the scale parameter.

---

## 4. The interpolation problem

Theorems 2.3–3.2 assume a real profile $K_0$. The measured object is only a sequence. When does a suitable $K_0$ exist, and how unique is it?

### 4.1 Existence: the ramp basis

**Definition 4.1 (Unit ramp).** $r(x) = \min\big(1, \max(x,0)\big)$: zero below $0$, linear on $[0,1]$, one above $1$.

**Definition 4.2 (Ramp-basis interpolant).** For a chain $K$ with octave increments $d_i = K(i+1)-K(i)$, set
$$\mathrm{PL}_K(t) \;=\; K(0) \;+\; \sum_{i < \lceil t \rceil} d_i \, r(t-i).$$

**Theorem 4.3.** If $K$ is monotone then $\mathrm{PL}_K$ is monotone, and $\mathrm{PL}_K(n) = K(n)$ for all $n \in \mathbb{N}$.

*Proof sketch.* *Monotonicity.* Let $t \le u$. Then $\lceil t\rceil \le \lceil u \rceil$. Split the comparison in two steps. First, over the common index range $i < \lceil t \rceil$, each summand increases because $r$ is monotone and each coefficient $d_i \ge 0$ (monotonicity of $K$). Second, the extra indices $\lceil t\rceil \le i < \lceil u \rceil$ contribute terms $d_i\, r(u-i) \ge 0$. Monotonicity is thus structural — a consequence of nonnegative coefficients on monotone basis functions — rather than a case analysis on floors.
*Interpolation.* At $t=n$, every index $i < n$ satisfies $n - i \ge 1$, so $r(n-i)=1$ and the sum telescopes: $K(0) + \sum_{i<n}(K(i+1)-K(i)) = K(n)$. $\square$

**Theorem 4.4 (Interpolation criterion).** For a chain $K$, the following are equivalent:
1. There exists a monotone real profile $K_0$ with $K_0(n) = K(n)$ for all $n$.
2. $K$ is monotone.

*Proof sketch.* (2)$\Rightarrow$(1) is Theorem 4.3. (1)$\Rightarrow$(2): for $a \le b$ in $\mathbb{N}$, $K(a) = K_0(a) \le K_0(b) = K(b)$. $\square$

Combined with Theorem 2.3, this says: *the real-parameter extension of the octave shift is available exactly on the tables the discrete theory already admits.* No measured table is lost, and a non-monotone table can never be interpolated.

**Corollary 4.5 (Extension for every measured family).** For any scale family $F$ obeying the discrete exchange and boundary laws, there is a monotone real profile $K_0$ with $K_0\big((j)\dot{-}(s)\big) = F(s,j)$ for all $s,j \in \mathbb{N}$: the action extends from $(\mathbb{N},+)$ to $(\mathbb{R}_{\ge0},+)$ without losing a cell.

*Proof sketch.* Take $K_0 = \mathrm{PL}_{F(0,\cdot)}$ and combine Theorem 4.3, Lemma 2.4, and the discrete rigidity $F(s,j) = F(0, j\dot{-}s)$. $\square$

### 4.2 Uniqueness fails

**Definition 4.6 (Staircase interpolant).** $\mathrm{ST}_K(t) = K(\lceil t \rceil)$ — round the context up to the next measured octave.

$\mathrm{ST}_K$ is monotone whenever $K$ is (as $\lceil\cdot\rceil$ is monotone), and $\mathrm{ST}_K(n) = K(n)$.

**Theorem 4.7 (Non-uniqueness).** For the reference base chain $K(j)=16+4j$, both $\mathrm{PL}_K$ and $\mathrm{ST}_K$ are monotone and interpolate every measured cell, yet at the half-octave
$$\mathrm{PL}_K(1/2) = 18, \qquad \mathrm{ST}_K(1/2) = 20.$$
They disagree by four keys.

*Proof sketch.* $\lceil 1/2 \rceil = 1$, so $\mathrm{PL}_K(1/2) = K(0) + d_0\, r(1/2) = 16 + 4\cdot\tfrac12 = 18$, while $\mathrm{ST}_K(1/2) = K(1) = 20$. $\square$

**Monotone interpolation alone does not determine intermediate model sizes.** This refutes the natural conjecture and forces the search for an additional axiom.

### 4.3 The repair: stationary increments

The tempting repair — impose smoothness — is unmotivated: smoothness is an analytic convenience with no operational content, and it would be an assumption imported from outside the theory. The correct condition is a *flow* condition.

**Definition 4.8 (Stationary increments).** A profile $K_0$ has *stationary increments* if
$$K_0(t+u) - K_0(t) \;=\; K_0(u) - K_0(0) \qquad \text{for all } t,u \in \mathbb{R}_{\ge0},$$
i.e. the change over an interval depends only on its length. This is the defining homogeneity property of a one-parameter flow: half an octave of context costs the same wherever it is spent.

**Lemma 4.9 (Cauchy rigidity on $\mathbb{R}_{\ge0}$).** If $g : \mathbb{R}_{\ge0}\to\mathbb{R}$ is monotone and additive, $g(x+y)=g(x)+g(y)$, then $g(t) = g(1)\,t$ for all $t$.

*Proof sketch.* Additivity gives $g(0)=0$ and, by induction, $g(nx)=n\,g(x)$ for $n\in\mathbb{N}$; monotonicity gives $g(1)\ge 0$. Fix $t$ and $n \ge 1$, and put $m = \lfloor nt \rfloor$, so that $m \le nt \le m+1$. Applying the monotone $g$ and using $g(m)=m\,g(1)$, $g(m+1)=(m+1)g(1)$, $g(nt)=n\,g(t)$:
$$m\,g(1) \;\le\; n\,g(t) \;\le\; (m+1)\,g(1).$$
The same inequalities bound $n\,t\,g(1)$ (multiply $m \le nt \le m+1$ by $g(1)\ge0$). Subtracting, $|n\,g(t) - n\,t\,g(1)| \le g(1)$, hence $|g(t)-g(1)t| \le g(1)/n$ for every $n\ge1$. Letting $n\to\infty$ gives $g(t)=g(1)t$. $\square$

No continuity, measurability, or rationality hypothesis is used: monotonicity does the work that regularity assumptions usually do. This is why the resulting theorem is a structural statement about flows rather than a smoothness assumption in disguise.

**Theorem 4.10 (Generator Theorem).** A monotone real profile with stationary increments is affine:
$$K_0(t) = K_0(0) + \delta\, t, \qquad \delta := K_0(1)-K_0(0).$$

*Proof sketch.* Put $g(t) = K_0(t)-K_0(0)$. Monotonicity of $K_0$ gives monotonicity of $g$; stationarity is exactly additivity of $g$. Lemma 4.9 gives $g(t)=g(1)t$, i.e. the claim with $\delta = g(1)$. $\square$

Combined with Theorem 4.7, this pins the boundary exactly: **monotonicity alone leaves a family of interpolants; monotonicity plus stationary increments leaves precisely one.** The constant $\delta$ is the *keys-per-octave rate*.

### 4.4 Arithmetic chains and the canonical table

**Definition 4.11 (Affine profile).** $A_{k_0,\delta}(t) = k_0 + \delta t$.

**Theorem 4.12 (Existence and uniqueness for arithmetic chains).** Let $K$ be a chain with $K(j) = k_0 + \delta j$ for all $j$, with $\delta \ge 0$. Then:
1. $A_{k_0,\delta}$ is monotone, interpolates $K$, and has stationary increments.
2. It is the *only* monotone interpolant of $K$ with stationary increments.

*Proof sketch.* (1) is direct computation. (2) Let $K_0$ be another such. Interpolation at $0$ and $1$ gives $K_0(0)=k_0$ and $K_0(1) = k_0+\delta$; Theorem 4.10 then gives $K_0(t) = k_0 + \delta t$. $\square$

For the reference family $k_0 = 16$ and $\delta = 4$. Applying Theorem 3.2:

**Corollary 4.13 (The canonical real table).**
$$k^*(\sigma,t) \;=\; k_0 + \delta\,(t-\sigma)^{+} \;=\; 16 + 4\,\max(t-\sigma,\,0).$$

We record its two basic monotonicity properties, both immediate: $k^*$ is antitone in $\sigma$ and monotone in $t$ (for $\delta\ge0$). Hence the **sweep bracket**: if $\sigma_1 \le \sigma \le \sigma_2$ then $k^*(\sigma_2,t) \le k^*(\sigma,t)\le k^*(\sigma_1,t)$ for every $t$ — an unmeasured model between two measured ones has its whole knee chain bracketed by theirs.

**Theorem 4.14 (Restriction to the measured cells).** For all $s,j\in\mathbb{N}$, $k^*(s,j) = k(s,j)$. In particular $k^*(0,\cdot) = (16,20,24,28,\dots)$, $k^*(1,\cdot) = (16,16,20,24,\dots)$, $k^*(2,\cdot)=(16,16,16,20,\dots)$.

*Proof sketch.* $\max(j-s,0) = j\dot{-}s$ for naturals cast to $\mathbb{R}$, and $K(j\dot{-}s) = 16+4(j\dot{-}s)$. $\square$

---

## 5. The generator and the transport equation

Off the clamp locus the canonical table is affine in each variable, and its derivatives identify the generator of the flow.

**Theorem 5.1 (Generator).** For $\sigma < t$:
$$\frac{\partial k^*}{\partial \sigma}(\sigma,t) = -\delta, \qquad \frac{\partial k^*}{\partial t}(\sigma,t) = +\delta.$$

*Proof sketch.* On the open region $\sigma < t$ we have $k^*(\sigma,t) = k_0 + \delta(t-\sigma)$, and both derivatives are read off. Formally one shows the table agrees with this affine expression on a neighbourhood — the set $\{\sigma < t\}$ is open — and transports the derivative along that local agreement. $\square$

**Theorem 5.2 (Transport equation).** For $\sigma < t$,
$$\frac{\partial k^*}{\partial \sigma} + \frac{\partial k^*}{\partial t} = 0.$$

The table is constant along the direction $(1,1)$ in the (scale, context) plane. This is the infinitesimal form of the exchange law: one octave of scale is exchanged for exactly one octave of context, and the exchange rate — the generator — is the keys-per-octave rate $\delta$. Equivalently, scale and context enter the table only through the combination $t - \sigma$, i.e. through the ratio $\text{ctx}/2^{\sigma}$, now for real $\sigma$.

---

## 6. Calibrating the scale axis and the 3B sweep

### 6.1 Log-linear calibration

The scale index must be extended from $\{0,1,2\}$ to real model sizes. Parameter counts multiply, so the natural calibration is logarithmic, anchored on the two consecutive measured rows 1.5B $\mapsto 1$ and 7B $\mapsto 2$.

**Definition 6.1 (Scale index).** For $N > 0$ (model size in billions of parameters),
$$\mathrm{si}(N) \;=\; 1 + \frac{\log\!\big(N/1.5\big)}{\log(14/3)}.$$

**Proposition 6.2.** $\mathrm{si}(1.5) = 1$, $\mathrm{si}(7) = 2$, and $\mathrm{si}$ is strictly increasing on $(0,\infty)$.

*Proof sketch.* $\log 1 = 0$ gives the first; $7/1.5 = 14/3$ gives the second; strict monotonicity follows from strict monotonicity of $\log$ and positivity of $\log(14/3)$. $\square$

**Theorem 6.3 (The 3B scale index).** $\dfrac{7}{5} < \mathrm{si}(3) < \dfrac{3}{2}$.

*Proof sketch.* Since $3/1.5 = 2$ we have $\mathrm{si}(3) = 1 + \log 2/\log(14/3)$, so it suffices to bound the ratio $\rho = \log 2/\log(14/3)$ strictly between $2/5$ and $1/2$. As $\log(14/3) > 0$, the bound $\rho < 1/2$ is equivalent to $2\log 2 < \log(14/3)$, i.e. to $4 < 14/3$, which holds. The bound $2/5 < \rho$ is equivalent to $2\log(14/3) < 5\log 2$, i.e. to $(14/3)^2 < 2^5$, i.e. $196/9 < 32$, which holds. $\square$

Numerically $\mathrm{si}(3) = 1.44997\ldots$: the 3B model sits just short of half an octave past the 1.5B row.

**Corollary 6.4 (The offset is strictly fractional).** $1 < \mathrm{si}(3) < 2$ and $\mathrm{si}(3) \ne s$ for every $s \in \mathbb{N}$.

### 6.2 The predicted 3B chain

Write $k_{3\mathrm{B}}(t) = k^*(\mathrm{si}(3),\, t)$.

**Theorem 6.5 (3B, flat region).** $k_{3\mathrm{B}}(0) = k_{3\mathrm{B}}(1) = 16$.

*Proof sketch.* Both $0$ and $1$ are $\le \mathrm{si}(3) > 7/5 > 1$, so the clamp is active. $\square$

**Theorem 6.6 (3B at 2048 tokens).**
$$k^*(2,2) \;<\; k_{3\mathrm{B}}(2) \;<\; k^*(1,2), \qquad 18 < k_{3\mathrm{B}}(2) < \tfrac{92}{5} = 18.4, \qquad \lceil k_{3\mathrm{B}}(2)\rceil = 19.$$

*Proof sketch.* Since $\mathrm{si}(3) < 3/2 < 2$ the clamp is inactive: $k_{3\mathrm{B}}(2) = 16 + 4(2-\mathrm{si}(3))$. Theorem 6.3 gives $2 - \mathrm{si}(3) \in (1/2,\, 3/5)$, so the value lies in $(18, 18.4)$. The measured neighbours are $k^*(2,2)=16$ and $k^*(1,2)=20$. $\square$

**Theorem 6.7 (3B at 4096 tokens).**
$$k^*(2,3) < k_{3\mathrm{B}}(3) < k^*(1,3), \qquad 22 < k_{3\mathrm{B}}(3) < \tfrac{112}{5} = 22.4, \qquad \lceil k_{3\mathrm{B}}(3)\rceil = 23,$$
with measured neighbours $k^*(2,3)=20$ and $k^*(1,3)=24$.

**Theorem 6.8 (Monotone in model size).** For every $t$, $k^*(\mathrm{si}(7),t) \le k_{3\mathrm{B}}(t) \le k^*(\mathrm{si}(1.5),t)$: the interpolated deployment table never crosses a measured one.

The resulting deployment row:

| model | 512 | 1024 | 2048 | 4096 |
|---|---|---|---|---|
| 1.5B ($\sigma = 1$) | 16 | 16 | 20 | 24 |
| **3B** ($\sigma \approx 1.44997$) | **16** | **16** | **19** (from $18.20$) | **23** (from $22.20$) |
| 7B ($\sigma = 2$) | 16 | 16 | 16 | 20 |

### 6.3 Falsifiability

**Theorem 6.9 (The prediction is not a discrete cell).** For every $s \in \mathbb{N}$, $k^*(s,2) \ne k_{3\mathrm{B}}(2)$.

*Proof sketch.* If $s \ge 2$ the clamp gives $k^*(s,2)=16 < 18 < k_{3\mathrm{B}}(2)$. If $s \le 1$ then $k^*(s,2) = 16+4(2-s)\ge 20 > 18.4 > k_{3\mathrm{B}}(2)$. $\square$

This is the falsifiable content of the real-parameter extension. A purely discrete action can only predict integer translates: at 2048 tokens it must say 16 or 20. The flow says 19. A measured 3B knee of 16 or 20 at 2048 refutes the extension; a measured 19 confirms it.

---

## 7. What a family owns: identifiability and offset conjugacy

If the rate $\delta$ could be altered by re-parametrising the scale axis, it would be a fitting convention rather than data. It cannot.

**Theorem 7.1 (Rate identifiability).** Let $\delta' > 0$ and suppose two clamped-affine tables agree at every real context:
$$k_0 + \delta (t-a)^{+} \;=\; k_0' + \delta'(t-b)^{+} \qquad \text{for all } t \in \mathbb{R}.$$
Then $k_0 = k_0'$, $\delta = \delta'$ and $a = b$.

*Proof sketch.* Evaluate at $t = \min(a,b)$: both clamps are inactive, so $k_0 = k_0'$. Let $M = \max(a,b)$ and evaluate at $t=M$ and $t=M+1$: both clamps are now active, giving $k_0 + \delta(M-a) = k_0' + \delta'(M-b)$ and $k_0+\delta(M+1-a) = k_0'+\delta'(M+1-b)$. Subtracting yields $\delta = \delta'$; substituting back and cancelling the nonzero $\delta'$ yields $a=b$. $\square$

**Theorem 7.2 (Forced parameters).** Any clamped-affine family at scale offset $0$ reproducing the measured cells $k^*(0,0)=16$ and $k^*(0,1)=20$ has $k_0 = 16$ and $\delta = 4$.

*Proof sketch.* The first cell is on the clamp, so $k_0=16$; the second is off it, so $16 + \delta = 20$. $\square$

**Theorem 7.3 (Offset conjugacy).** Two clamped-affine tables with the same $(k_0,\delta)$ are translates of one another along the flow direction $(1,1)$:
$$k^*_{a+h}(t+h) = k^*_a(t) \quad \text{for all } t,h,$$
writing $k^*_a(t) = k_0 + \delta(t-a)^{+}$.

Together, Theorems 7.1–7.3 settle the competing hypothesis precisely. The chain and the rate are *shared* across the family; the only freedom a model owns, once the profile is fixed, is a single number — its offset on the scale axis. And by Corollary 6.4 that offset may be genuinely fractional. So "each family needs its own chain" is too coarse in one direction (the chain is shared) and the "one universal table" reading is too strong in the other (offsets differ, and are not integers).

---

## 8. The budget adjunction and the exact discretisation defect

### 8.1 Reading the table backwards

Deployment usually fixes a budget and asks what it buys.

**Definition 8.1 (Reach).** For a profile with base knee $k_0$ and rate $\delta > 0$, the *reach* of a budget $b \ge k_0$ is
$$R(b) \;=\; \frac{b-k_0}{\delta} \;\ge\; 0.$$

**Theorem 8.2 (Budget adjunction).** For $\delta>0$ and $b \ge k_0$, and for all real $\sigma, t$:
$$k^*(\sigma,t) \le b \quad \Longleftrightarrow \quad t \le \sigma + R(b).$$

*Proof sketch.* If $t \le \sigma$ the left side reads $k_0 \le b$, true; and the right side holds since $R \ge 0$. If $t \ge \sigma$ the left side reads $k_0 + \delta(t-\sigma)\le b$, which after dividing by $\delta>0$ is $t - \sigma \le (b-k_0)/\delta$. $\square$

**Corollary 8.3 (Served ray).** The served set at scale $\sigma$ is exactly the closed ray $\{t : t \le \sigma + R(b)\}$, and its supremum $\sigma+R(b)$ is attained.

**Theorem 8.4 (Continuous budget law).** For every real increment $h$,
$$\sup\{t : k^*(\sigma+h,\,t) \le b\} \;=\; \big(\sigma + R(b)\big) + h.$$
The served boundary is the line $t = \sigma + R(b)$ of slope exactly $1$: a fixed budget buys **one context octave per octave of scale**, for real scale. The discrete law is the restriction of this line to the integer lattice.

### 8.2 The measured instance

For the reference family with $b = 16 = k_0$, the reach is $R(16) = 0$, so the served boundary is the diagonal $t = \sigma$. A 16-key budget buys exactly a model's own base context. On the integer lattice this says the *first failing* context octave at scale $s$ is $s+1$ — precisely what was measured at $s=0$ and $s=1$ and predicted at $s=2$.

### 8.3 The staircase–triangle defect

We can now quantify exactly how much is lost by discretising the scale axis. Fix the budget $b=16$ and a scale window $S \in \mathbb{N}$ (inside a context window $J \ge S$ wide enough that no cell is cut off).

*Discrete count.* At integer scale $s$ the served context octaves are $j = 0,1,\dots,s$, so $s+1$ cells; over $s = 0,\dots,S-1$ the total is
$$\#\{\text{served cells}\} = \sum_{s=0}^{S-1}(s+1) = \frac{S(S+1)}{2}.$$
(Equivalently, in the doubled form in which the discrete theory records it, $2\cdot\#= 2Sf + S(S-1)$ with $f = 1$ the first failing octave at scale $0$.)

*Continuous area.* The area under the served boundary $t=\sigma$ over $[0,S]$ is $\int_0^S \sigma\,d\sigma = S^2/2$.

**Theorem 8.5 (Exact discretisation defect).** For every $S \in \mathbb{N}$ and every $J \ge S$,
$$\#\{\text{served cells over } [0,S)\} \;=\; \int_0^S \sigma\, d\sigma \;+\; \frac{S}{2}.$$

*Proof sketch.* Combine the two computations above: $S(S+1)/2 - S^2/2 = S/2$. The only care needed is the degenerate case $S=0$, where both sides vanish, and the natural-number subtraction in $S(S-1)$ must be cast correctly for $S \ge 1$. $\square$

This is the **Euler–Maclaurin half-cell correction**, in closed form and with no error term. The staircase exceeds the triangle by exactly half a cell per scale row. It is *linear* where the two quantities themselves are quadratic, so it vanishes to first order — which is the precise sense in which the continuous table is a faithful interpolation of the measured one rather than a story imposed upon it. The continuous extension is not merely asymptotically consistent with the measurements; its mismatch with them is a known, exactly computable linear term.

---

## 9. The tropical reading

The clamp is a max-plus operation, and this is not a coincidence but the organising principle.

**Theorem 9.1 (Tropical binomial form).** For $\delta \ge 0$,
$$k^*(\sigma,t) \;=\; \max\big(k_0,\; k_0 + \delta t - \delta\sigma\big).$$

*Proof sketch.* If $t\le\sigma$ the second argument is $\le k_0$; if $t\ge\sigma$ it is $\ge k_0$ and equals $k_0 + \delta(t-\sigma)$. $\square$

In the max-plus semiring — where tropical addition is $\max$ and tropical multiplication is ordinary $+$ — this exhibits the knee table as a **tropical binomial** in the two real coordinates: the tropical sum of the constant monomial $k_0$ and the monomial $k_0 + \delta t - \delta\sigma$. Every structural feature of the table is now a standard fact about tropical polynomials, obtained rather than assumed.

**Theorem 9.2 (Convexity / diminishing returns).** For $\delta \ge 0$, $t \mapsto k^*(\sigma,t)$ is convex on $\mathbb{R}$, and $\sigma \mapsto k^*(\sigma,t)$ is convex on $\mathbb{R}$.

*Proof sketch.* A pointwise maximum of a constant and an affine function is convex: for a convex combination, each of the two branches is bounded by the corresponding combination of maxima. Apply with slope $\delta$ in $t$ and slope $-\delta$ in $\sigma$. $\square$

Diminishing returns along both axes is thus *forced* by the tropical form, not fitted.

**Theorem 9.3 (Corner locus).** Let $\delta > 0$ and fix $\sigma$. Then $t \mapsto k^*(\sigma,t)$ is differentiable at every $t \ne \sigma$ and *not* differentiable at $t=\sigma$; that is,
$$\{t : k^*(\sigma,\cdot) \text{ is not differentiable at } t\} \;=\; \{\sigma\}.$$

*Proof sketch.* For $t < \sigma$ the function is locally constant; for $t>\sigma$ it is locally affine of slope $\delta$; both regions are open. At $t = \sigma$ the one-sided derivatives are $\delta$ from the right and $0$ from the left. If a two-sided derivative $d$ existed it would have to agree with each one-sided derivative on a set with the unique-differentiability property, forcing $d=\delta$ and $d=0$, contradicting $\delta>0$. $\square$

Deployment-wise this is a sharp statement: **each model has exactly one knee in its knee table, located at its own base context.** Not two, not a smeared region.

**Theorem 9.4 (Flow invariance of the corner locus).** For $\delta>0$ and all $\sigma,t,a$,
$$k^*(\sigma,\cdot) \text{ non-smooth at } t \quad \Longleftrightarrow \quad k^*(\sigma+a,\cdot)\text{ non-smooth at } t+a.$$

*Proof sketch.* Both sides are equivalent by Theorem 9.3 to $t=\sigma$ and $t+a = \sigma+a$ respectively, which are the same condition. $\square$

The corner locus is the diagonal of the (scale, context) plane, hence invariant under the flow direction $(1,1)$. **The exchange law is precisely the statement that the tropical hypersurface of the knee table is a line of slope one**, and the discrete octave shift law is that line sampled at lattice points.

**Theorem 9.5 (The flow preserves diminishing returns).** If a base profile $K_0 : \mathbb{R}\to\mathbb{R}$ is convex and monotone, then $t \mapsto K_0\big(\max(t-\sigma,0)\big)$ is convex for every $\sigma$.

*Proof sketch.* The clamp $t \mapsto \max(t-\sigma,0)$ is convex with image $[0,\infty)$; a monotone convex function composed with a convex function is convex, using monotonicity of $K_0$ on the image. $\square$

So diminishing returns is a property of the *family*, invariant under the flow, and not an attribute of an individual model.

---

## 10. Algorithms

Three procedures follow directly from the theory and are what a deployment pipeline actually runs.

**Algorithm A (Chain fitting).** Given a measured table, extract the base chain $K = k(0,\cdot)$, verify the exchange law $k(s,j) = K(j\dot{-}s)$ on every measured cell, test $K$ for monotonicity (Theorem 4.4), and test $K$ for constant increments. If increments are constant, output the canonical parameters $(k_0,\delta) = (K(0),\, K(1)-K(0))$ and the closed-form table $k^* = k_0 + \delta(t-\sigma)^{+}$; otherwise fall back to the ramp interpolant of Theorem 4.3. Cost: $O(SJ)$ for validation, $O(J)$ for fitting.

**Algorithm B (Interpolated budget).** Given a target model size $N$, a context length $L$, and fitted $(k_0,\delta)$ with anchors $(N_1,\sigma_1)$, $(N_2,\sigma_2)$: compute $\sigma = \mathrm{si}(N)$ by log-linear calibration, compute $t = \log_2(L/L_{\text{base}})$, evaluate $k^*(\sigma,t) = k_0 + \delta\max(t-\sigma,0)$, and return the deployable budget $\lceil k^*\rceil$. Cost: $O(1)$. Correctness of the bracketing is Theorem 6.8; Lipschitz stability of the output in $N$ is Theorem 3.4.

**Algorithm C (Reach and served region).** Given a budget $b$, compute $R = (b-k_0)/\delta$; report the served boundary $t = \sigma + R$ (Theorem 8.4), the discrete served-cell count $\sum_{s<S}\min(J, \lfloor s+R\rfloor +1)$, the continuous area, and their difference — which equals $S/2$ exactly in the aligned case $b=k_0$, $J \ge S$ (Theorem 8.5). Cost: $O(S)$.

---

## 11. Discussion

### 11.1 What the continuous extension buys

Three things, in increasing order of surprise.

*Operationally*, it fills in rows. A deployment table becomes a function of a real model size, Lipschitz in that size (Theorem 3.4), with a closed-form budget (Corollary 4.13) and a falsifiable prediction for any unmeasured model (Theorem 6.9).

*Structurally*, it clarifies what the octave shift law is. In discrete form it looks like a numerical coincidence about a grid. In continuous form it is a transport equation, $\partial_\sigma k + \partial_t k = 0$, whose generator is the keys-per-octave rate; the shift is the exponential of that generator. The rigidity theorem's proof gets *shorter* in the continuous setting, because a translation replaces an induction.

*Geometrically*, it identifies the table as a tropical binomial with a single corner on the diagonal. This subsumes convexity, the one-knee-per-model fact, and the exchange law itself into one statement about a tropical hypersurface being a line of slope one.

### 11.2 What was refuted

Three prior claims did not survive.

*"Monotonicity alone determines intermediate model sizes"* — false, with the explicit four-key gap of Theorem 4.7. The correction required identifying the right axiom, and the right axiom turned out to be a flow axiom (stationary increments) and not a smoothness axiom. Lemma 4.9's freedom from regularity hypotheses is what makes this a principled rather than a convenient choice.

*"The rate is a gauge artefact of the scale calibration"* — false, by Theorem 7.1: base knee, rate and offset are jointly identifiable.

*"Each model family needs its own chain"* — partly false. The chain and rate are shared; the offset is private, and may be fractional. A purely discrete reading cannot express a fractional offset and is therefore too coarse.

### 11.3 Limitations

The measured base chain is exactly arithmetic, which is what makes the canonical table a *binomial* with a single corner. A family with several plateaux would have a base chain that is piecewise arithmetic and a table that is a tropical polynomial with several monomials, whose corner locus is a tropical curve rather than a single diagonal. The generator theorem then applies only piecewise, and stationarity must be localised to each plateau.

The log-linear calibration of the scale index (Definition 6.1) is an assumption on the *parametrisation* of the scale axis, not a theorem: it is fixed by two anchors, and a family with three or more measured rows over-determines it. Our family does have a third row, and the over-determination is visible. The measured ladder is not geometric — $1.5/0.5 = 3$ while $7/1.5 = 14/3$ — so anchoring on the upper consecutive pair places the $0.5$B model at $\mathrm{si}(0.5) = 1 + \log(1/3)/\log(14/3) = 0.2868\ldots$ rather than at $0$, and the interpolated $0.5$B row $(16,19,23,27)$ undershoots the measured $(16,20,24,28)$ by one key.

It is worth being precise about what this does and does not affect. The knee table itself is exact at every *integer* scale index (Theorem 4.14): the discrepancy lives entirely in the map from parameter count to scale index, not in the flow. It says that the scale axis of this family is slightly compressed at the small end relative to a pure log-linear law — which is exactly the kind of deviation the identifiability theorem (Theorem 7.1) forbids from being absorbed into the rate, and hence exactly the kind that a third anchor makes testable. An alternative calibration anchored on $0.5$B $\mapsto 0$ and $7$B $\mapsto 2$ gives $\mathrm{si}(3) = 2\log 6/\log 14 = 1.3579\ldots$ and a $2048$-token knee of $18.57$, still strictly between the measured neighbours and still rounding to a deployable $19$ keys — so the headline prediction of Section 6 is robust to the choice of anchor pair, even though the exact value is not.

Finally, the discretisation defect $S/2$ (Theorem 8.5) is exact for the aligned budget $b = k_0$ and a wide-enough context window. For general budgets the same computation goes through with floors of $\sigma + R$, and the defect acquires a bounded fractional-part contribution; only the aligned case yields the clean half-cell.

---

## 12. Future directions

**Multi-knee profiles and tropical hypersurface rigidity.** A measured profile with several plateaux is a tropical polynomial with several monomials, whose corner locus is a tropical curve in the (scale, context) plane rather than a single diagonal. The key observation is that the flow-invariance argument of Theorem 9.4 used nothing about the *number* of monomials: the exchange law says only that the corner locus is invariant under $(1,1)$. This suggests a rigidity conjecture — any finite max-plus profile whose corner locus is invariant under $(1,1)$ must be a tropical polynomial in the single variable $t-\sigma$. The one-corner case (Theorem 9.3) is settled, so the induction on the number of corners has a base.

**Non-arithmetic chains.** For a chain that is monotone but not arithmetic, Theorem 4.4 gives existence and Theorem 4.7 gives non-uniqueness, but stationary increments fail globally. The right statement is presumably a piecewise generator theorem, with the profile affine on each plateau and the corner locus a polyhedral curve.

**Over-determined calibration.** With three or more measured rows the log-linear scale index becomes testable. Deviations would be informative: a systematically compressed axis at large $N$ would show up as curvature in $\mathrm{si}$, which the identifiability theorem forbids from being absorbed into the rate.

**Second-order discretisation.** The defect $S/2$ is the first Euler–Maclaurin term. For general budgets one expects a bounded oscillatory correction governed by $\{\sigma+R\}$, and it would be worth computing its exact form; a clean closed form would give error bars on interpolated tables at arbitrary budgets, not just aligned ones.

**Empirical falsification.** The sharpest immediate step is to measure a 3B model at 2048 tokens. The flow predicts a knee in $(18, 18.4)$ and a deployable budget of 19 keys. A measured 16 or 20 refutes the real-parameter extension outright.

---

## 13. Conclusion

The awkward clamp in the discrete octave shift law — the truncated subtraction that makes $j - s$ vanish when $s$ exceeds $j$ — was never a bookkeeping wart. It is ordered subtraction, an operation that exists just as naturally in $\mathbb{R}_{\ge0}$ as in $\mathbb{N}$, and reading it there lifts the entire discrete theory verbatim to a one-parameter flow.

The lift is legitimate (it restricts to every measured cell), rigid (two local laws determine the whole plane), conditionally unique (monotonicity is not enough; monotonicity plus stationary increments is exactly enough), generated by an identifiable rate (the keys-per-octave constant, satisfying a transport equation), geometrically transparent (a tropical binomial with a single corner on the diagonal), and quantitatively honest about its own discretisation error (exactly $S/2$, in closed form).

Its practical output is a row that nobody measured: a 3-billion-parameter model at 2048 tokens of context wants 19 keys — a number no integer scale index can produce, and one that a single afternoon of measurement can confirm or destroy.
