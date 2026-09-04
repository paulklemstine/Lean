# Rank-Grid Resolution in Threshold Statistics: Exact Splitting, Sharp Nested Bounds, and the Identifiability Limit of a Two-Cell Window Ladder

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

A threshold ("gate") statistic evaluated on a finite window of $N$ items can only be realised at the rank rates $k/N$. Consequently a measured *gate drop* — the change in a response when a threshold is hardened — mixes an intrinsic property of the population with an artifact of the rank grid. We build an order-theoretic model of this mixing, in which a nominal tail rate $\theta$ is realised as $\mathrm{gr}_N(\theta)=\lceil\theta N\rceil/N$, and derive an exact decomposition of the measured drop into an intrinsic drop and two resolution residuals.

Four groups of results follow. **(i) Structure and consistency:** the residual of an antitone response is nonnegative, decreases under grid refinement, is bounded by $L/N$ for an $L$-Lipschitz response, and the measured response converges to the ideal one. **(ii) Cross-window accounting:** in a *decoupled* design (gates held fixed across windows) the intrinsic drop cancels identically and the cross-window difference $D$ is a pure resolution quantity, with $|D|\le 2L(1/N_1+1/N_2)$ in general and the sharper, fine-window-free bound $|D|\le L/N_1$ for *nested* windows $N_2=N_1c$; an explicit linear witness attains $D=L/320$ at $(240,960)$, so the resulting slope certificate recovers exactly $3/4$ of the truth, and upper and lower bounds match to the factor $4/3$. A positive nested $D$ necessarily moves the hard gate between grids, and the refinement changes the realised gate with probability $1-1/c$ for a uniformly placed gate. In a *nested* design the gate drift $\varepsilon$ contributes an additional $2L(\varepsilon+1/N_2)$, so sample size and bound growth are not separable. **(iii) Derivation of the $1/N$ law:** averaging over the position of the gate inside its rank cell gives an offset-averaged residual of exactly $L/(2N)$ — the constant is half the local slope, not a fitted parameter — and the offset-averaged bias of a drop is $(L_2-L_1)/(2N)$, so that $D>0$ holds *if and only if* the response is steeper at the hard gate than at the soft gate. **(iv) An identifiability limit:** we exhibit two antitone $L$-Lipschitz responses that every cell of a two-cell nested ladder measures *identically*, yet whose intrinsic drops differ by exactly $L/(4N_{\mathrm{fine}})$; combined with (ii) this determines the design's resolving power up to a constant.

Applied to a reported four-cell experiment with $\Delta(240)=0.1073$, $\Delta(960)=0.0636$, $D=+0.0437$ (interval $[0.0346,0.0533]$), the theory yields: a certified Lipschitz floor $L\ge 8.30$; a proof that both pre-stated hypotheses ("most of the drop is resolution", "none of it is") fail across the entire reported confidence box; a Richardson-extrapolated intrinsic level $I=(4\Delta(960)-\Delta(240))/3=0.0490$, i.e. a resolution share of $54\%$ rather than the reported $41\%$ — the two differ by exactly $4/3$ — with the intrinsic share pinned only to $[0.36,0.60]$; a falsifiable third-cell prediction $\Delta(3840)=(5\Delta(960)-\Delta(240))/4\in[0.0459,0.0607]$; and a structural ambiguity of only $\approx 0.0022$, about $2\%$ of $\Delta(240)$. The last number decides the design question: the wide share interval is statistical width, not a resolution limit. More seeds, not finer windows.

**Keywords:** rank grid, threshold statistics, resolution bias, Richardson extrapolation, identifiability, Lipschitz certificate, nested window design.

---

## 1. Introduction

### 1.1 The empirical situation

Consider a response measured on the extreme tail of a scored population. A gate at nominal tail rate $\theta$ admits the top $\theta$-fraction of items; hardening the gate from a soft level $\theta_1$ to a hard level $\theta_2>\theta_1$ produces a *gate drop*. The empirical design that motivates this paper is a $2\times 2$ factorial: two window sizes $N\in\{240,960\}$ crossed with two threshold levels ($u=2.5$ and $u=3.5$, corresponding to $\theta_1$ and $\theta_2$), replicated over eight populations. It reports

| window $N$ | measured drop $\Delta(N)$ | interval |
|---:|:---|:---|
| $240$ | $+0.1073$ | $[0.0973,\,0.1148]$ |
| $960$ | $+0.0636$ | $[0.0597,\,0.0680]$ |
| $D=\Delta(240)-\Delta(960)$ | $+0.0437$ | $[0.0346,\,0.0533]$ |

Two hypotheses were stated before the data were seen.

- **H1** — *most* of the drop is a resolution artifact: quadrupling the window should recover most of it.
- **H2** — *none* of it is: the drop is intrinsic and window size is irrelevant.

The outcome is **neither**: quadrupling recovers $D/\Delta(240)\approx 41\%$, a real but minority fraction. The experimental reading was "mostly intrinsic threshold reweighting, with a real $\approx41\%$ minority from per-$N$ rank resolution."

### 1.2 What this paper does

Nothing below is statistics. Every empirical number enters only as a hypothesis on a real variable, and every conclusion is a theorem about those hypotheses. The contribution is a model in which "resolution component" is a *definite* mathematical object rather than a residual to be fitted, plus the sharp two-sided accounting that the model makes possible.

The organising question is not *what was measured* but *what can this design know*. We answer it with matching bounds:

- an **upper** bound on the ambiguity, $|D|\le L/N_1$ for nested windows (§4), so the design pins the intrinsic drop at least that well;
- a **lower** bound on the ambiguity, $L/(4N_{\mathrm{fine}})$, realised by two responses the design cannot separate (§7), so it pins it no better.

Between them lies the design's exact resolving power, and comparing that to the reported statistical width answers the operational question of what to do next.

### 1.3 Notation

Throughout, $S:\mathbb{R}\to\mathbb{R}$ is a *response*: the quantity of interest as a function of the nominal tail rate. $N,M,c,N_1,N_2$ are positive integers; $\theta,\theta_1,\theta_2$ are nominal rates with $\theta_1<\theta_2$; $L\ge 0$ is a slope budget. Windows $N_2=N_1 c$ are called *nested*.

---

## 2. The rank-grid model

### Definition 2.1 (Realised gate)

The **realised gate** of a nominal rate $\theta$ on a window of $N$ items is
$$\mathrm{gr}_N(\theta) \;=\; \frac{\lceil \theta N\rceil}{N}.$$

Only the rates $k/N$, $k\in\mathbb{Z}$, occur on a window of $N$ items; the definition rounds a request **up** to the next realisable rate, which is the conservative convention for a tail gate (never admit more items than requested).

### Definition 2.2 (Lipschitz budget)

$S$ has **Lipschitz budget** $L$ if $|S(x)-S(y)|\le L|x-y|$ for all $x,y$.

A trivial but useful remark: a Lipschitz budget is automatically nonnegative, since $0\le|S(0)-S(1)|\le L$.

### Definition 2.3 (Measured response, residual, drops)

- The **measured response** is $S_N(\theta) = S(\mathrm{gr}_N(\theta))$.
- The **resolution residual** is $r_N(\theta) = S(\theta) - S_N(\theta)$.
- The **measured gate drop** is $\Delta_S(N;\theta_1,\theta_2) = S_N(\theta_1) - S_N(\theta_2)$, abbreviated $\Delta(N)$.
- The **intrinsic gate drop** is $\Delta_S(\infty;\theta_1,\theta_2) = S(\theta_1)-S(\theta_2)$, abbreviated $\Delta(\infty)$.
- The **cross-window difference** is $D = \Delta(N_1)-\Delta(N_2)$.

### Proposition 2.4 (Basic geometry of the grid)

For every $N\ge 1$ and $\theta,\theta'\in\mathbb{R}$:

1. $\theta \le \mathrm{gr}_N(\theta) < \theta + 1/N$; hence $|\mathrm{gr}_N(\theta)-\theta|\le 1/N$.
2. $\mathrm{gr}_N$ is monotone: $\theta\le\theta' \Rightarrow \mathrm{gr}_N(\theta)\le\mathrm{gr}_N(\theta')$.
3. $|\mathrm{gr}_N(\theta)-\mathrm{gr}_N(\theta')| \le |\theta-\theta'| + 1/N$.
4. **(Refinement)** For every $c\ge 1$, $\mathrm{gr}_{Nc}(\theta) \le \mathrm{gr}_N(\theta)$.

*Proof sketch.* (1) is $\lceil x\rceil\ge x$ and $\lceil x\rceil< x+1$ applied to $x=\theta N$ and divided by $N$. (2) is monotonicity of $\lceil\cdot\rceil$. (3) follows from (1) applied at both points and the triangle inequality. (4) is the only non-formal step: since $\theta N \le \lceil \theta N\rceil$ we get $\theta\cdot Nc \le \lceil\theta N\rceil\, c$, and $\lceil\theta N\rceil c$ is an integer, whence $\lceil\theta N c\rceil\le \lceil\theta N\rceil c$; dividing by $Nc$ gives the claim. $\square$

Item (4) is the structural fact that the design's two windows are related by $960 = 240\cdot 4$, and it is worth a factor $2.5$ in §4.

### Proposition 2.5 (Residual structure)

Let $S$ be antitone (nonincreasing) and $N\ge 1$. Then:

1. **Nonnegativity:** $r_N(\theta)\ge 0$ for all $\theta$.
2. **Refinement shrinks it:** $r_{Nc}(\theta)\le r_N(\theta)$ for all $c\ge 1$.
3. **Magnitude:** if $S$ has Lipschitz budget $L$ (antitonicity not needed), $|r_N(\theta)|\le L/N$.
4. **Consistency:** if $S$ has Lipschitz budget $L$, then $S_N(\theta)\to S(\theta)$ as $N\to\infty$.

*Proof sketch.* (1) $\theta\le\mathrm{gr}_N(\theta)$ and $S$ antitone give $S(\mathrm{gr}_N(\theta))\le S(\theta)$. (2) Apply $S$ antitone to Proposition 2.4(4). (3) $|r_N(\theta)| = |S(\theta)-S(\mathrm{gr}_N\theta)| \le L|\mathrm{gr}_N\theta-\theta|\le L/N$. (4) Squeeze $|r_N|$ between $0$ and $L/N\to0$. $\square$

### Theorem 2.6 (Exact split of a measured drop)

For every response $S$, window $N$ and gates $\theta_1,\theta_2$,
$$\Delta(N) \;=\; \Delta(\infty) \;-\; r_N(\theta_1) \;+\; r_N(\theta_2).$$

*Proof.* Expand $\Delta(N)=S(\mathrm{gr}_N\theta_1)-S(\mathrm{gr}_N\theta_2)$ and substitute $S(\mathrm{gr}_N\theta_i) = S(\theta_i)-r_N(\theta_i)$. $\square$

This is an identity, not an approximation: it has no error term. It defines the intrinsic/resolution split that the remainder of the paper measures.

---

## 3. Decoupled designs measure pure resolution

The design's named follow-up is to *decouple the strip bound from the population median*, i.e. hold both gates fixed across the two windows. Formally that is the assumption that $\theta_1,\theta_2$ do not depend on $N$. Under it the split of Theorem 2.6 has a striking consequence.

### Theorem 3.1 (Decoupled cross-window difference is pure resolution)

If the gates are held fixed across windows, then
$$D \;=\; \Delta(N_1)-\Delta(N_2) \;=\; \bigl(r_{N_2}(\theta_1)-r_{N_1}(\theta_1)\bigr) \;-\; \bigl(r_{N_2}(\theta_2)-r_{N_1}(\theta_2)\bigr).$$
In particular $D$ contains no information whatsoever about $\Delta(\infty)$.

*Proof.* Apply Theorem 2.6 at $N_1$ and at $N_2$ and subtract; $\Delta(\infty)$ is the same real number in both and cancels identically. $\square$

### Corollary 3.2 (Generic size bound)

If $S$ has Lipschitz budget $L$ then $|D| \le 2L\left(\dfrac{1}{N_1}+\dfrac{1}{N_2}\right)$.

*Proof.* Four residual terms, each of absolute value $\le L/N_i$ by Proposition 2.5(3). $\square$

### Theorem 3.3 (Nested designs are confounded, quantitatively)

Suppose instead the gates move with the window: window $N_1$ uses gates $(a_1,a_2)$ and window $N_2$ uses gates $(b_1,b_2)$ with drift $|a_i-b_i|\le\varepsilon$. Then
$$\bigl|\Delta_S(N_1;a_1,a_2) - \Delta_S(N_2;b_1,b_2)\bigr| \;\le\; 2L\left(\frac{1}{N_1}+\frac{1}{N_2}\right) \;+\; 2L\left(\varepsilon+\frac{1}{N_2}\right).$$

*Proof sketch.* Insert and subtract $\Delta_S(N_2;a_1,a_2)$. The first difference is a decoupled cross-window difference, bounded by Corollary 3.2. The second is a gate perturbation at fixed window: by Proposition 2.4(3) the realised gates move by at most $\varepsilon+1/N_2$, and the Lipschitz budget converts this into $L(\varepsilon+1/N_2)$ per gate, hence $2L(\varepsilon+1/N_2)$ for the drop. $\square$

**Interpretation.** In a nested design, where the strip bound grows with the window, sample size and bound growth are not separable: a nonzero $D$ can be produced by gate drift alone. Theorem 3.3 is the experiment's own recorded caveat, made quantitative, and it is the formal reason the decoupled follow-up is the right next experiment rather than a mere refinement.

---

## 4. Sharp accounting for nested windows

Corollary 3.2 never used the nesting. Exploiting it doubles the strength and removes the fine window from the bound entirely.

### Theorem 4.1 (Nested cross-window bound)

Let $S$ be antitone with Lipschitz budget $L$, and let $N_2=N_1c$ with $c\ge1$. Then
$$|D| \;\le\; \frac{L}{N_1}.$$

*Proof.* By Theorem 3.1, $D = B_1 - B_2$ where $B_i = r_{N_2}(\theta_i)-r_{N_1}(\theta_i)$. By Proposition 2.5(1) and (2), $0\le r_{N_2}(\theta_i)\le r_{N_1}(\theta_i)\le L/N_1$, so each $B_i\in[-L/N_1,\,0]$. Hence $D = B_1-B_2 \in [-L/N_1,\,L/N_1]$. $\square$

Note the absence of $N_2$: making the fine window finer cannot widen what the comparison sees. The coarse window is the bottleneck.

### Corollary 4.2 (Certified slope floor)

At $(N_1,N_2)=(240,960)$ with $D\ge 0.0346$: $L \ge 240\times 0.0346 = 8.30$.

The generic Corollary 3.2 reads $|D|\le 2L(\tfrac1{240}+\tfrac1{960}) = L/96$ and gives only $L\ge 96\times0.0346 = 3.32$; nesting sharpens the certificate by a factor $2.5$. Either way, **a flat response cannot produce the reported $D$**: something in the strip is genuinely steep.

### Theorem 4.3 (An explicit witness, and the $4/3$ gap)

Let $S(x)=-Lx$ with $L\ge0$ — antitone, Lipschitz budget $L$, and with *no* intrinsic window dependence of any kind. With gates $\theta_1=0$ and $\theta_2=1/960$,
$$\Delta(240)=\frac{L}{240},\qquad \Delta(960)=\frac{L}{960},\qquad D = \frac{L}{320}>0.$$
Consequently the certificate of Corollary 4.2 returns $240\,D = \tfrac34 L$.

*Proof.* $\mathrm{gr}_N(0)=0$; $\mathrm{gr}_{240}(1/960) = \lceil 240/960\rceil/240 = 1/240$; $\mathrm{gr}_{960}(1/960)=1/960$. Substitute. $\square$

Two conclusions. First, **$D>0$ certifies nothing intrinsic by itself**: a purely linear response with no window dependence reproduces $D>0$ exactly. The implicit inference "$D>0$, therefore resolution is a minority" is invalid. Second, Theorems 4.1 and 4.3 bracket the design's power to recover the slope within the factor $4/3$ — precisely the price of not knowing where inside its rank cell the gate sits.

### Proposition 4.4 (Structural necessary condition)

Let $S$ be antitone and $N_2=N_1c$. If $D>0$ then $\mathrm{gr}_{N_2}(\theta_2) < \mathrm{gr}_{N_1}(\theta_2)$: the refinement must move the **hard** gate. Contrapositively, if the hard gate is realised identically on both windows, then $D\le 0$.

*Proof sketch.* From $D=B_1-B_2>0$ and $B_1\le0$ we get $B_2<0$, i.e. $r_{N_2}(\theta_2)<r_{N_1}(\theta_2)$, so the realised gates differ; Proposition 2.4(4) then forces the strict inequality in the stated direction. $\square$

This is a cheap diagnostic: instrument the follow-up experiment to log whether the hard gate moved, and any run in which it did not is *guaranteed* to contribute nonpositively.

### Proposition 4.5 (How often refinement matters)

For $\theta$ in the first coarse cell $(0,1/M]$, the grids agree, $\mathrm{gr}_{Mc}(\theta)=\mathrm{gr}_M(\theta)$, if and only if $\theta > \tfrac1M - \tfrac1{Mc}$. The agreement set is therefore an interval of length $\tfrac{1}{Mc}$, so a uniformly placed gate is *moved* by the refinement with probability $1-\tfrac1c$; for $240\to960$ this is exactly $3/4$.

*Proof sketch.* On $(0,1/M]$ one has $\lceil\theta M\rceil = 1$, so $\mathrm{gr}_M(\theta)=1/M$. Equality with $\mathrm{gr}_{Mc}(\theta)=\lceil\theta Mc\rceil/(Mc)$ holds iff $\lceil\theta Mc\rceil = c$, i.e. iff $\theta Mc > c-1$, i.e. iff $\theta > \tfrac{c-1}{Mc} = \tfrac1M-\tfrac1{Mc}$. The set is $\left(\tfrac1M-\tfrac1{Mc},\,\tfrac1M\right]$, of Lebesgue measure $\tfrac1{Mc}$. $\square$

---

## 5. Deriving the $1/N$ law by offset averaging

Sections 4 and 6 both rely on the reading that the resolution part of the drop scales as $c/N$ — "smooth mass per offset unchanged, only rate granularity changing". That is an ansatz. Here it is derived, and the constant is identified.

### Definition 5.1 (Cell average)

The **offset average** of $f$ across one rank cell of width $1/N$ is
$$\langle f\rangle_N \;=\; N\int_0^{1/N} f(t)\,dt.$$

The gate sits somewhere inside a rank cell; where exactly is an accident of the population, so this is the natural way to remove that accident.

### Lemma 5.2 (Granularity destroys offset information)

For $t\in(0,1/N]$ and any integer $k$, $\mathrm{gr}_N\!\left(\tfrac kN + t\right) = \tfrac{k+1}{N}$. Hence
$$\left\langle t\mapsto S_N\!\left(\tfrac kN+t\right)\right\rangle_N \;=\; S\!\left(\tfrac{k+1}{N}\right),$$
a constant in the offset.

*Proof sketch.* $\left(\tfrac kN+t\right)N = tN + k$ with $tN\in(0,1]$, so the ceiling is $k+1$. The measured response is therefore constant on the cell and its average is that constant. $\square$

### Lemma 5.3 (The smooth response averages to its cell midpoint)

If $S(x) = A - Lx$ for all $x$ in the closed cell $[\tfrac kN,\tfrac{k+1}{N}]$, then
$$\left\langle t\mapsto S\!\left(\tfrac kN+t\right)\right\rangle_N \;=\; A - L\left(\frac kN + \frac{1}{2N}\right).$$

*Proof sketch.* $N\int_0^{1/N}\bigl(C - Lt\bigr)dt = N\left(C/N - \tfrac{L}{2N^2}\right) = C - \tfrac{L}{2N}$ with $C=A-Lk/N$. $\square$

### Theorem 5.4 (The $1/N$ law, with its constant)

Under the hypothesis of Lemma 5.3,
$$\left\langle t\mapsto r_N\!\left(\tfrac kN+t\right)\right\rangle_N \;=\; \frac{L}{2N}.$$

*Proof.* Subtract Lemma 5.2 from Lemma 5.3: $\left(A - L\tfrac kN - \tfrac{L}{2N}\right) - \left(A - L\tfrac{k+1}{N}\right) = \tfrac{L}{N}-\tfrac{L}{2N} = \tfrac{L}{2N}$. $\square$

The ansatz "residual $= c/N$" is therefore correct, and $c = L/2$ is **half the local slope**, not a fitted parameter.

### Theorem 5.5 (Offset-averaged bias of a drop)

Let $S$ be locally affine with slope $-L_1$ across the soft gate's cell and $-L_2$ across the hard gate's cell. Then the offset-averaged measured drop exceeds the offset-averaged intrinsic drop by exactly
$$\frac{L_2-L_1}{2N}.$$

*Proof.* Apply Theorem 5.4 at each gate; the drop's bias is $\langle r_N(\theta_2)\rangle - \langle r_N(\theta_1)\rangle = \tfrac{L_2}{2N}-\tfrac{L_1}{2N}$, matching the sign pattern of Theorem 2.6. $\square$

### Corollary 5.6 (Sign rigidity)

On the offset-averaged model, the measured drop exceeds the intrinsic drop — equivalently the drop shrinks as $N$ grows, which is the reported $D>0$ — **if and only if** $L_1 < L_2$: the response is steeper at the hard gate than at the soft gate.

**This is the paper's most consequential negative result.** For a survival curve over a tail with a decaying density, the response *flattens* as one moves outward, i.e. $L_2 < L_1$, which forces $D<0$. The reported $D = +0.0437$ therefore has the **wrong sign** to be explained by rank granularity acting on a decaying tail. On the offset-averaged model, the sign of $D$ is a genuine constraint on the population's local geometry, not a free parameter absorbing a share. The remaining explanations are (a) gate drift in the nested design, bounded by Theorem 3.3, or (b) genuine threshold reweighting.

---

## 6. Auditing the reported four-cell reading

We now feed the reported numbers into the model. All statements below are theorems about real variables satisfying the stated inequalities.

### Theorem 6.1 (Both pre-stated hypotheses fail, on the whole box)

Write $\Delta(240)=I+r_1$, $\Delta(960)=I+r_2$ with $r_2\ge0$ and $\Delta(240)>0$. If $\Delta(240)\le 0.1148$, $\Delta(960)\ge 0.0597$ and $D=\Delta(240)-\Delta(960)\ge 0.0346$, then
$$r_1 > 0 \qquad\text{and}\qquad \frac{D}{\Delta(240)} < \frac12.$$

*Proof.* Since $D = r_1-r_2 \ge 0.0346 > 0$ and $r_2\ge0$, we get $r_1>0$: hardening still leaves a strictly positive resolution residual at the coarse window, so H2 ("none") fails. For H1, the inequality $2D<\Delta(240)$ is equivalent to $\Delta(240) < 2\Delta(960)$, which holds because $\Delta(240)\le 0.1148 < 0.1194 = 2(0.0597)\le 2\Delta(960)$. Dividing by $\Delta(240)>0$ gives $D/\Delta(240)<1/2$: quadrupling the window recovers strictly less than half the drop, so H1 ("most") fails. $\square$

So the **NEITHER** verdict is robust across the entire reported confidence box, not a point-estimate artifact. What follows shows that the *share* is not.

### Theorem 6.2 (Richardson extrapolation)

If the drop is affine in the rank step, $\Delta(N)=I+c/N$, then the two cells determine the intrinsic level and the coarse cell's resolution part exactly:
$$I = \frac{4\Delta(960)-\Delta(240)}{3}, \qquad \frac{c}{240} = \frac43\bigl(\Delta(240)-\Delta(960)\bigr) = \frac43 D.$$

*Proof.* $c/960 = (c/240)/4$; solve the two linear equations. $\square$

### Corollary 6.3 (The reported recovery understates the share by exactly $4/3$)

$$\frac{c/240}{\Delta(240)} \;=\; \frac43\cdot\frac{D}{\Delta(240)}.$$
Numerically, $\tfrac43\times 41\% \approx 54\%$: the resolution share of the coarse cell implied by the $1/N$ model is a **majority**, not the reported $41\%$ minority. The discrepancy is structural — the fine cell still carries a quarter of the coarse cell's residual, so the between-cell recovery necessarily misses a quarter of it.

### Theorem 6.4 (At the point estimates the headline is reversed)

With $\Delta(240)=0.1073$ and $\Delta(960)=0.0636$, Theorem 6.2 gives $I = \tfrac{4(0.0636)-0.1073}{3} = 0.04903\overline{3}$, and
$$0 < I \quad\text{and}\quad 2I < \Delta(240).$$
The extrapolated intrinsic level is positive but a strict minority of the coarse drop.

### Theorem 6.5 (Interval for the intrinsic share)

Under $\Delta(N)=I+c/N$, if $\Delta(240)\in[0.0973,0.1148]$ and $\Delta(960)\in[0.0597,0.0680]$ then
$$\frac{9}{25}\,\Delta(240) \;\le\; I \;\le\; \frac35\,\Delta(240), \qquad\text{i.e.}\qquad \frac{I}{\Delta(240)}\in[0.36,\,0.60].$$

*Proof.* By Theorem 6.2, $3I = 4\Delta(960)-\Delta(240)$, so both claims are linear inequalities in the two measurements.

*Upper.* $I\le\tfrac35\Delta(240)$ is $4\Delta(960)\le\tfrac{14}{5}\Delta(240)$. Since $4\Delta(960)\le 4(0.0680)=0.2720$ and $\tfrac{14}{5}\Delta(240)\ge 2.8(0.0973)=0.27244$, the inequality holds.

*Lower.* $I\ge\tfrac{9}{25}\Delta(240)$ is $4\Delta(960)\ge\tfrac{52}{25}\Delta(240)$. Since $4\Delta(960)\ge 4(0.0597)=0.23880$ and $\tfrac{52}{25}\Delta(240)\le 2.08(0.1148)=0.238784$, the inequality holds. $\square$

Both bounds are tight to four decimal places on the reported box, so they are the exact consequences of those intervals rather than a loose relaxation.

**"Mostly intrinsic" ($>1/2$) is consistent with the four cells but not certified by them.** The interval $[0.36,0.60]$ straddles $1/2$.

### Theorem 6.6 (Falsifiable third-cell prediction)

Under $\Delta(N)=I+c/N$, a third nested cell at $N=3840$ is determined by the two measured ones:
$$\Delta(3840) = \frac{5\Delta(960)-\Delta(240)}{4},$$
numerically $0.0527$, and confined by the reported intervals to $[0.0459,\,0.0607]$.

*Proof sketch.* $c/960 = (c/240)/4$ and $c/3840=(c/240)/16$; eliminate $I$ and $c$. Then propagate the interval endpoints through the affine map, which is increasing in $\Delta(960)$ and decreasing in $\Delta(240)$. $\square$

A measured $\Delta(3840)$ outside $[0.0459,0.0607]$ refutes the $1/N$ reading, and with it the $41\%$-versus-$54\%$ arithmetic of Corollary 6.3.

---

## 7. The identifiability limit of a two-cell ladder

All of §4–§6 bounds the resolution component *from above*. The complementary question is a **lower bound on ignorance**: can two responses agree on every measurement the design makes and still disagree about the intrinsic drop? They can, and by a computable amount.

### Definition 7.1 (Reference and adversary)

Fix $L\ge 0$.
$$\ell(x) = -\frac L2 x, \qquad
\kappa(x) = \begin{cases}
-Lx, & x\le \tfrac{1}{1920},\\[2pt]
-\tfrac{L}{1920}, & \tfrac{1}{1920}<x\le\tfrac{1}{960},\\[2pt]
-\tfrac L2 x, & x>\tfrac{1}{960}.
\end{cases}$$

The adversary $\kappa$ descends at the *maximal admissible* rate $-L$ on the first half of the first fine cell, is flat on the second half, and rejoins $\ell$ from $1/960$ onwards.

### Lemma 7.2 (Both responses are admissible)

For $L\ge0$, both $\ell$ and $\kappa$ are antitone with Lipschitz budget $L$.

*Proof sketch.* For $\ell$ this is immediate: $\ell(x)-\ell(y) = -\tfrac L2(x-y)$ and $L/2\le L$. For $\kappa$, a case analysis on which of the three pieces contain $x\le y$ shows in every case $0 \le \kappa(x)-\kappa(y)\le L(y-x)$, which gives both antitonicity and the Lipschitz bound (the latter after splitting on the order of $x,y$). The three slopes are $-L$, $0$, $-L/2$, all in $[-L,0]$, and the pieces match continuously at $1/1920$ and at $1/960$. $\square$

### Lemma 7.3 (The three rates the design ever evaluates)

With gates $\theta_1=0$ and $\theta_2=1/1920$:
$$\mathrm{gr}_{240}(0)=\mathrm{gr}_{960}(0)=0,\qquad \mathrm{gr}_{240}\!\left(\tfrac1{1920}\right)=\tfrac1{240},\qquad \mathrm{gr}_{960}\!\left(\tfrac1{1920}\right)=\tfrac{1}{960}.$$

*Proof.* $\lceil 0\rceil = 0$; $\lceil 240/1920\rceil = \lceil 1/8\rceil = 1$; $\lceil 960/1920\rceil = \lceil 1/2\rceil = 1$. $\square$

The hard gate sits *inside* the first fine cell, so both windows round it up to their own first grid point.

### Theorem 7.4 (Indistinguishability)

$\kappa$ and $\ell$ agree at $0$, at $1/240$ and at $1/960$. Consequently, for gates $(0, 1/1920)$,
$$\Delta_\kappa(240) = \Delta_\ell(240) \qquad\text{and}\qquad \Delta_\kappa(960) = \Delta_\ell(960).$$
Every cell of the design returns the same number for the two responses.

*Proof.* $\kappa(0)=0=\ell(0)$. At $1/240 > 1/960$ the third branch of $\kappa$ *is* $\ell$. At $1/960$, $\kappa$ takes the middle branch, $\kappa(1/960) = -L/1920 = -\tfrac L2\cdot\tfrac1{960} = \ell(1/960)$. Combine with Lemma 7.3. $\square$

### Theorem 7.5 (Yet the intrinsic drops differ)

$$\Delta_\kappa(\infty) - \Delta_\ell(\infty) \;=\; \frac{L}{3840} \;=\; \frac{L}{4\cdot 960}.$$

*Proof.* Both responses vanish at $0$. At the hard gate $\kappa(1/1920) = -L/1920$ while $\ell(1/1920) = -L/3840$. The intrinsic drops are $\Delta(\infty)= S(0)-S(1/1920)$, so the difference is $\tfrac{L}{1920}-\tfrac{L}{3840} = \tfrac{L}{3840}$. $\square$

### Theorem 7.6 (Identifiability limit)

For every $L\ge0$ there exist two antitone responses with Lipschitz budget $L$ that (i) are measured identically by both cells of the two-cell nested ladder, yet (ii) have intrinsic drops differing by exactly $L/(4N_{\mathrm{fine}})$ with $N_{\mathrm{fine}}=960$. Hence no re-analysis of the four cells can resolve the intrinsic drop below that width. Conversely, Theorem 4.1 shows the design *does* resolve it to within $L/N_{\mathrm{coarse}}$, a constant multiple.

*Proof.* Lemmas 7.2, 7.3 and Theorems 7.4, 7.5. $\square$

### Corollary 7.7 (The wide share interval is statistical, not structural)

With the certified floor $L\ge 8.30$ of Corollary 4.2 taken as the operative slope scale, the structural ambiguity of the design is
$$\frac{L}{3840} \approx \frac{8.30}{3840} \approx 0.0022,$$
about $2\%$ of $\Delta(240)=0.1073$. The intrinsic-share interval of Theorem 6.5 has width $0.60-0.36 = 0.24$, an order of magnitude larger. **The $[0.36,0.60]$ spread is therefore statistical width in the reported confidence intervals, not a resolution limit of the design.** More seeds, not finer windows, is the way to close it.

---

## 8. Algorithms

The theory is fully constructive; the following procedures implement it.

### 8.1 Grid realisation and residual evaluation

Given a response oracle $S$, a window $N$ and a nominal rate $\theta$: return $\lceil\theta N\rceil/N$, $S$ of it, and $S(\theta)$ minus that. Cost $O(1)$ per call. This is the primitive on which everything else is built.

### 8.2 Nested slope certificate

**Input:** nested windows $N_1 \mid N_2$, a measured $D$ (or its interval lower end $D^-$).
**Output:** the certified floor $L \ge N_1 D^-$, valid for every antitone response with the given measurements.
Complexity $O(1)$. Correctness is Theorem 4.1; Theorem 4.3 shows the certificate recovers $\tfrac{N_2-N_1}{N_2}L$ of the true slope on the linear witness, i.e. $\tfrac34 L$ at $(240,960)$.

### 8.3 Richardson intrinsic extrapolation with interval propagation

**Input:** $\Delta(N_1)$ and $\Delta(N_2)$ with $N_2 = cN_1$, optionally as intervals.
**Output:** $I = \dfrac{c\,\Delta(N_2)-\Delta(N_1)}{c-1}$, the coarse resolution part $\Delta(N_1)-I$, the share $I/\Delta(N_1)$, and — for a third nested cell $N_3 = c'N_1$ — the prediction $\Delta(N_3) = I + \bigl(\Delta(N_1)-I\bigr)\tfrac{N_1}{N_3}$.
Interval propagation is exact because the map is affine and monotone in each argument (increasing in $\Delta(N_2)$, decreasing in $\Delta(N_1)$), so it suffices to evaluate at the two opposite corners. Complexity $O(1)$.

### 8.4 Structural-versus-statistical triage

**Input:** the design $(N_1,N_2)$, the certified floor $L$, and the reported share interval.
**Output:** the structural ambiguity $L/(4N_2)$ as a fraction of $\Delta(N_1)$, compared to the statistical width of the share interval; a recommendation of "more seeds" when statistical width dominates, "finer windows" otherwise.
This is the operational content of Corollary 7.7 and is $O(1)$.

### 8.5 Offset-averaged simulator

Sample gate offsets uniformly inside a rank cell, evaluate the measured drop for each, and average. Theorem 5.4 predicts the mean residual to be $L/(2N)$ exactly; the simulator confirms it and, for a nonlinear response, quantifies the departure. Cost $O(\text{samples})$.

---

## 9. Applications

The rank-grid phenomenon is not peculiar to one experiment. Any statistic defined by "take the top $\theta$ fraction" is subject to it whenever the sample is finite.

- **Extreme-value and risk analytics.** Value-at-risk and expected shortfall at a nominal level are computed from order statistics, i.e. on a rank grid. Comparisons across sample sizes — backtesting windows, rolling horizons — are exactly the situation Theorem 3.1 describes, and any observed level dependence should be tested against $L/N_1$ before being attributed to a regime change.
- **Selective inference and false-discovery control.** Procedures that cut at a data-dependent rank inherit the same $O(1/N)$ bias; Theorem 5.4 gives the leading term as half the local slope of the discovery curve divided by $N$.
- **Model evaluation at fixed selectivity.** Comparing two systems "at the top $1\%$" on evaluation sets of different sizes compares two different realised thresholds. Proposition 4.5 says that for a uniformly placed gate a $c$-fold change in set size moves the realised threshold with probability $1-1/c$ — so the comparison is usually not at the same operating point.
- **Design of window ladders.** Theorem 7.6 gives, *before any data are collected*, the width of the design's blind spot, $L/(4N_{\mathrm{fine}})$. Comparing that number to the anticipated statistical width tells the experimenter whether to invest in replication or in resolution. This kind of a-priori triage is cheap and, in our reading of the four-cell design, decisive.

---

## 10. Discussion

Three findings deserve emphasis, because each contradicts an inference that is natural and wrong.

**A nonzero window effect certifies nothing intrinsic.** Theorem 4.3 constructs a perfectly linear response — the least "structured" object available, with no intrinsic window dependence at all — that reproduces $D>0$ exactly. Only the *size* of $D$ relative to $L/N_1$ is informative. The empirical reading's implicit step from "the effect survives quadrupling" to "resolution is a minority" does not follow.

**The reported recovery is not the resolution share.** Between-cell recovery $D/\Delta(N_1)$ and the coarse cell's resolution share differ by exactly $c/(c-1)$, which is $4/3$ at $(240,960)$: the fine cell retains a quarter of the coarse residual, so the difference of the two cells necessarily misses a quarter of it. At the point estimates this converts a $41\%$ minority into a $54\%$ majority and reverses the headline. Over the reported box the intrinsic share is only pinned to $[0.36,0.60]$.

**The sign is the strongest constraint available, and it points away from granularity.** Corollary 5.6 turns $D>0$ into the exact statement $L_2>L_1$ — the response must be steeper at the hard gate. For a decaying tail density the reverse holds. So the observed positive $D$ cannot be attributed to rank granularity acting on a well-behaved tail; the live candidates are gate drift in the nested design (Theorem 3.3) or genuine threshold reweighting. Distinguishing them is precisely what the decoupled follow-up does, since Theorem 3.1 makes $D$ a pure residual difference and Theorem 5.4 gives that difference a closed form.

What *is* robust is the **NEITHER** verdict itself: Theorem 6.1 establishes both $r_1>0$ and $2D<\Delta(240)$ across the entire reported confidence box, so neither pre-stated hypothesis survives, independent of any modelling choice about how the residual scales.

The methodological lesson is Corollary 7.7. A design has two kinds of uncertainty, and they call for opposite remedies. Structural ambiguity — the set of hypotheses the design cannot separate even with infinite replication — is here computable and small ($\approx 0.0022$, $2\%$ of the coarse drop). Statistical width is here large ($24$ percentage points on the share). Confusing them is how experimental programmes end up refining an instrument that was never the bottleneck.

**Limitations.** The model assumes the response is a deterministic function of the realised tail rate, and that the empirical numbers are the model's quantities. It does not model sampling noise; the intervals enter as hypotheses. Local affineness is assumed only where used (§5), and the identifiability construction (§7) uses a specific, though entirely admissible, adversary — a different gate placement would yield a different, generally smaller, gap.

---

## 11. Future directions

*(Derived from the results above.)*

### 11.1 Offset-randomised gating — the decoupled follow-up, sharpened

The key insight is that rank granularity is not noise to be averaged away but a *deterministic* map $\theta\mapsto\lceil\theta N\rceil/N$ whose only free parameter is where the gate sits inside its cell — so randomising that offset turns the resolution component into a quantity with a computable law, $L/(2N)$ per gate, instead of a residual to be fitted. The named follow-up already proposes decoupling the strip bound from the population median; Theorem 3.1 shows that decoupling alone makes $D$ a pure residual difference, and Theorem 5.4 says the offset average then has a closed form, so the experiment becomes a direct measurement of the local slope rather than a share estimate.

**Conjecture.** In a decoupled design with the gate offset drawn uniformly inside its rank cell,
$$\mathbb{E}[\Delta(N)] = \Delta(\infty) + \frac{L_2-L_1}{2N}$$
exactly, with no fitted constant.

### 11.2 Sign rigidity of the window effect

The key insight is that $D>0$ (drop shrinking with window size) is equivalent, on the offset-averaged model, to the response being *steeper at the hard gate*, which for a unimodal score distribution with decaying tail density is false. The reported $D=+0.0437$ therefore cannot be explained by rank granularity acting on a decaying tail; the remaining explanations are gate drift in the nested design (bounded by Theorem 3.3) or genuine threshold reweighting.

**Conjecture.** For every population whose score density is decreasing across the strip between the two gates, the offset-averaged decoupled cross-window difference is nonpositive; hence any decoupled design that still reports $D>0$ certifies threshold reweighting.

### 11.3 The third cell

Run $N=3840$. Theorem 6.6 predicts $\Delta(3840)\in[0.0459,0.0607]$ under the $1/N$ law. A measurement outside this interval falsifies the law and voids the share arithmetic; a measurement inside it, with tightened intervals, would collapse the $[0.36,0.60]$ share interval considerably.

### 11.4 Beyond two cells

Theorem 7.6 gives the blind spot of a *two*-cell ladder. The natural generalisation asks for the identifiability width of a $k$-cell nested ladder $N, Nc, Nc^2,\dots$ Each additional cell adds evaluation points and should shrink the adversary's room; a plausible target is a width of order $L/(4N c^{\,k-1})$ with a constant depending on $k$ — i.e. exponentially decreasing in the number of cells but only linearly in the total sample.

### 11.5 Non-uniform grids and weighted gates

Real designs sometimes use weighted or stratified selection, where the realisable rates form a non-uniform grid. Proposition 2.4(4) — the refinement inequality — is the only place uniformity is used essentially, and it survives whenever the fine grid *contains* the coarse one. Extending §4–§7 to arbitrary nested grids should be routine and would broaden the applicability considerably.

---

## 12. Conclusion

Making the rank grid explicit converts a soft methodological worry into an exact calculus. A measured gate drop splits, with no error term, into an intrinsic drop and two resolution residuals. In a design that holds its gates fixed, the cross-window difference is *purely* the second kind, bounded by $L/N_{\mathrm{coarse}}$ for nested windows and attained within $4/3$ by an explicit linear witness. Averaging over the gate's position in its cell derives the $1/N$ law with constant $L/2$, and turns the sign of the window effect into an exact statement about local steepness. And an explicit pair of indistinguishable responses shows that the design's blind spot has width exactly $L/(4N_{\mathrm{fine}})$.

Applied to the reported experiment: the **NEITHER** verdict is robust; the resolution *share* is not, and at the point estimates it is a majority rather than the reported minority; the sign of the effect argues against granularity as its cause; and the design's structural ambiguity, $\approx 2\%$ of the coarse drop, is an order of magnitude smaller than the statistical width of the share interval. The next experiment should decouple the gates and add seeds, not shrink the grid.
