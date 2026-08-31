# Sharp Constants for Quantised Fair Scheduling: The Slack Spectrum of a Photon-Transport Exchange

**Author:** Aristotle

**Date:** 2026-08-31

---

## Abstract

We analyse the exact cost of quantisation in a thermodynamically-motivated fair-scheduling model. A *photon-transport exchange* multiplexes several transport classes over a shared quantum channel; the ideal share of a class $y$ is $\gamma d(y)/\mathrm{gap}(y)$, where the *transport gap* $\mathrm{gap}(y) = \beta\log(1/p(y)) + M + \gamma - r(y)$ is the Boltzmann cost of a successful transfer, corrected by the class's reservation credit. A physically realisable arbiter cannot deliver arbitrary real shares: it delivers binary exponential backoff windows, i.e. it rounds the ideal share up to the nearest power of two.

We prove that this arbiter never starves a class, $\mathrm{ideal}(y) \le \mathrm{service}(y)$, and always overshoots by strictly less than a factor of two, $\mathrm{service}(y) < 2\,\mathrm{ideal}(y)$. We then determine the *slack spectrum* exactly: the set of achievable ratios $\mathrm{service}/\mathrm{ideal}$ over all exchanges is precisely the half-open interval $[1,2)$. For a general grid ratio $\rho > 1$ we obtain the exact characterisations: a uniform ceiling $\mathrm{service} \le c\cdot\mathrm{ideal}$ holds iff $\rho \le c$, and a uniform floor $c\cdot\mathrm{ideal} \le \mathrm{service}$ holds iff $c \le 1$. The headline factor $2$ is therefore the grid ratio itself, not an artefact of the argument. Both bounds survive summation over a finite family of classes.

We next study randomised (phase-jittered) grids. The floor and the ceiling are phase-independent — randomisation *cannot* improve the worst case — but the phase-averaged behaviour is exactly computable: the log-slack is the fractional part $\{\theta - \log_\rho x\}$, whose phase average is $1/2$, so the geometric-mean slack is exactly $\sqrt{\rho}$ and the arithmetic-mean slack is exactly $(\rho-1)/\log\rho$. We prove the strict hierarchy $\sqrt\rho < (\rho-1)/\log\rho < \rho$ for every $\rho > 1$. Defining the *grid cost* $C(\rho) = \rho/\log\rho$, we show $C$ is uniquely minimised at $\rho = e$, that $C(4) = C(2)$ exactly, and that $C(2) < 1.07\,e$.

Finally, we show that sharpness is realised not merely across the space of exchanges but *within a single exchange over time*. If a class's demand grows geometrically with ratio $\alpha$, the log-slack along the ladder $\alpha^n$ equals $\{-n\log_2\alpha\}$, the orbit of a circle rotation. We prove a Diophantine dichotomy: the slack orbit is dense in the full spectrum **iff** $\log_2\alpha$ is irrational. In particular an exchange whose demand triples per round saturates both the floor and the factor-two ceiling, whereas one that quadruples per round has slack identically $1$.

**Keywords:** fair scheduling, exponential backoff, quantisation error, sharp constants, circle rotation, equidistribution, Kronecker's theorem, Boltzmann cost.

---

## 1. Introduction

### 1.1 The physical setting

Consider a shared quantum channel — an optical fibre, a satellite downlink, a bus of entanglement-distribution nodes — that must be multiplexed across several *transport classes*. Each class $y$ is described by three numbers:

- an **occupancy** $p(y) \in (0,1]$: the probability that a slot offered to class $y$ is actually usable (photon not lost, entanglement not decohered);
- a **demand** $d(y) > 0$: the amount of channel time the class is requesting;
- a **reservation credit** $r(y) \in \mathbb{R}$: channel time already committed to $y$ by the arbiter.

Three global constants govern the exchange: an inverse temperature $\beta > 0$, a scheduling quantum $\gamma > 0$, and a background cost $M \in \mathbb{R}$.

**Definition 1.1 (Photon-transport exchange).** A *photon-transport exchange* over an index set $\iota$ consists of constants $\beta > 0$, $\gamma > 0$, $M \in \mathbb{R}$ and functions $p, d, r : \iota \to \mathbb{R}$ with $0 < p(y) \le 1$, $d(y) > 0$, and the positivity condition
$$\beta\log\!\big(1/p(y)\big) + M + \gamma - r(y) > 0 \qquad \text{for all } y.$$

**Definition 1.2 (Transport gap and ideal share).** The *transport gap* of class $y$ is
$$\mathrm{gap}(y) \;=\; \beta \log\!\big(1/p(y)\big) + M + \gamma - r(y) \;>\;0,$$
the Boltzmann cost of one successful transfer corrected by the class's own credit. The *ideal share* — the allocation a perfectly divisible arbiter would grant — is
$$\mathrm{ideal}(y) \;=\; \frac{\gamma\, d(y)}{\mathrm{gap}(y)} \;>\; 0.$$

The interpretation is thermodynamic. A rare class ($p(y)$ small, so $\log(1/p(y))$ large) has a large Boltzmann cost, a large gap and hence a small ideal share: the channel does not spend its capacity on transfers that will mostly fail. A class holding a large credit $r(y)$ has a small gap and a correspondingly large share. Monotonicity is immediate: comparing two classes of the same exchange with $M - r(y) = M - r(z)$, we have $p(y) \le p(z) \implies \mathrm{gap}(z) \le \mathrm{gap}(y)$, since $\log(1/\cdot)$ is antitone and $\beta > 0$.

### 1.2 The quantisation constraint

A real arbiter allocates *backoff windows*, which form a geometric ladder. The arbiter picks the smallest window in the ladder that covers the ideal share.

**Definition 1.3 (Grid quantiser).** For a grid ratio $\rho > 1$ and $x > 0$,
$$\mathrm{gridCeil}_\rho(x) \;=\; \rho^{\lceil \log_\rho x\rceil},$$
the least integer power of $\rho$ (positive or negative exponent) that is at least $x$.

**Definition 1.4 (Delivered service).** The *service* delivered by the grid-$\rho$ arbiter is $\mathrm{service}_\rho(y) = \mathrm{gridCeil}_\rho(\mathrm{ideal}(y))$. The *dyadic* (binary exponential backoff) arbiter is the case $\rho = 2$, and we write $\mathrm{service}(y) = \mathrm{service}_2(y) = 2^{\lceil \log_2 \mathrm{ideal}(y)\rceil}$.

**Definition 1.5 (Slack).** The *slack* of a class is $\mathrm{slack}(y) = \mathrm{service}(y)/\mathrm{ideal}(y)$; more generally, for a request size $x>0$ we write $\mathrm{slack}(x) = \mathrm{gridCeil}_2(x)/x$ and $\mathrm{logSlack}(x) = \log_2 \mathrm{slack}(x)$.

The organising question of this paper: **exactly what does quantisation cost?**

### 1.3 Summary of results

1. **Two-sided bound** (Theorem 3.1, 3.2). $\mathrm{ideal}(y) \le \mathrm{service}(y) < 2\,\mathrm{ideal}(y)$, for every exchange and every class.
2. **The slack spectrum** (Theorem 3.6). $\{\,\mathrm{service}(y)/\mathrm{ideal}(y)\,\} = [1,2)$ exactly.
3. **The constants are the grid ratio** (Theorem 4.2, 4.3). For a general grid ratio $\rho$: $\mathrm{service}_\rho \le c\cdot\mathrm{ideal}$ for all exchanges iff $\rho \le c$; and $c\cdot\mathrm{ideal} \le \mathrm{service}_\rho$ for all exchanges iff $c \le 1$.
4. **Aggregation and non-vacuity** (Theorems 5.1, 5.2, 5.3).
5. **Jitter cannot beat the worst case, but changes the typical case** (Theorems 6.2, 6.4, 6.6, 6.7): geometric-mean slack exactly $\sqrt\rho$, arithmetic-mean slack exactly $(\rho-1)/\log\rho$, and the strict hierarchy $\sqrt\rho < (\rho-1)/\log\rho < \rho$.
6. **The optimal grid ratio is $e$** (Theorem 7.2), with $C(4) = C(2) < 1.07 e$ (Theorems 7.3, 7.4).
7. **Diophantine dichotomy** (Theorem 8.7). A geometrically growing exchange has a dense slack orbit iff $\log_2$ of its growth ratio is irrational; ternary growth saturates the spectrum (Theorem 8.9).

---

## 2. The grid quantiser

All the structure lives in $\mathrm{gridCeil}_\rho$; the exchange contributes only positivity of the ideal share. Fix $\rho > 1$ throughout this section and let $x > 0$.

**Lemma 2.1 (Covering).** $x \le \mathrm{gridCeil}_\rho(x)$.

*Proof.* Write $x = \rho^{\log_\rho x}$. Since $\log_\rho x \le \lceil\log_\rho x\rceil$ and $t \mapsto \rho^t$ is increasing for $\rho > 1$, we get $x \le \rho^{\lceil\log_\rho x\rceil} = \mathrm{gridCeil}_\rho(x)$. $\square$

**Lemma 2.2 (Efficiency).** $\mathrm{gridCeil}_\rho(x) < \rho\, x$.

*Proof.* $\lceil t\rceil < t + 1$, so $\rho^{\lceil \log_\rho x\rceil} < \rho^{\log_\rho x + 1} = \rho^{\log_\rho x}\cdot\rho = \rho x$. $\square$

**Lemma 2.3 (Forced jump).** If $1 < x \le \rho$ then $\mathrm{gridCeil}_\rho(x) = \rho$.

*Proof.* $\log_\rho x > 0$ because $x>1$ and $\rho>1$; and $\log_\rho x \le 1$ because $x \le \rho$. Hence $\lceil \log_\rho x\rceil = 1$ and $\mathrm{gridCeil}_\rho(x) = \rho^1$. $\square$

This lemma is the workhorse for every sharpness construction: on the whole interval $(1,\rho]$ the quantiser delivers the *same* window $\rho$, so the slack $\rho/x$ sweeps the entire range $[1,\rho)$ as $x$ sweeps $(1,\rho]$ backwards.

**Lemma 2.4 (Exactness on the grid).** $\mathrm{gridCeil}_\rho(x) = x$ iff $x = \rho^k$ for some $k \in \mathbb{Z}$.

*Proof.* ($\Rightarrow$) Take $k = \lceil\log_\rho x\rceil$. ($\Leftarrow$) If $x = \rho^k$ then $\log_\rho x = k$ is an integer, so $\lceil \log_\rho x\rceil = k$. $\square$

**Lemma 2.5 (Equivariance).** $\mathrm{gridCeil}_\rho(\rho x) = \rho\,\mathrm{gridCeil}_\rho(x)$, and consequently the slack is log-periodic:
$$\frac{\mathrm{gridCeil}_\rho(\rho x)}{\rho x} = \frac{\mathrm{gridCeil}_\rho(x)}{x}.$$

*Proof.* $\log_\rho(\rho x) = \log_\rho x + 1$ and $\lceil t + 1\rceil = \lceil t\rceil + 1$, so the exponent increases by exactly one. $\square$

**Lemma 2.6 (Monotonicity).** $0 < x \le y \implies \mathrm{gridCeil}_\rho(x) \le \mathrm{gridCeil}_\rho(y)$.

*Proof.* $\log_\rho$ is monotone, $\lceil\cdot\rceil$ is monotone, $t \mapsto \rho^t$ is monotone. $\square$

Lemma 2.5 already explains the shape of the answer: the slack function, viewed on the logarithmic scale, is periodic with period $\log\rho$, and on one period it is the decreasing function $x \mapsto \rho/x$ on $(1,\rho]$, whose range is $[1,\rho)$ — closed at the bottom, open at the top.

---

## 3. The floor, the ceiling, and the dyadic spectrum

**Theorem 3.1 (No starvation).** For every exchange and every class $y$,
$$\frac{\gamma\, d(y)}{\beta\log(1/p(y)) + M + \gamma - r(y)} \;\le\; \mathrm{service}(y).$$

*Proof.* The left side is $\mathrm{ideal}(y) > 0$; apply Lemma 2.1 with $\rho = 2$. $\square$

**Theorem 3.2 (Factor-two ceiling).** $\mathrm{service}(y) < 2\,\mathrm{ideal}(y)$ for every exchange and every class.

*Proof.* Lemma 2.2 with $\rho = 2$. $\square$

**Corollary 3.3.** $\mathrm{service}(y)/\mathrm{ideal}(y) \in [1,2)$ always.

**Theorem 3.4 (Exactness criterion).** $\mathrm{service}(y) = \mathrm{ideal}(y)$ iff $\mathrm{ideal}(y) = 2^k$ for some $k \in \mathbb{Z}$.

*Proof.* Lemma 2.4. $\square$

To show these constants are attained we need explicit exchanges. The following one-parameter family suffices.

**Definition 3.5 (Witness exchange).** For $x > 0$ let $W_x$ be the single-class exchange with $\beta = \gamma = M = 1$, $p \equiv 1$, $r \equiv 1$, $d \equiv x$.

Since $\log(1/1) = 0$, the gap of $W_x$ is $0 + 1 + 1 - 1 = 1$, hence $\mathrm{ideal}_{W_x} = \gamma x / 1 = x$. The witness family therefore realises *any* prescribed ideal share, and all questions about the slack spectrum reduce to questions about $\mathrm{gridCeil}$.

Combining with Lemma 2.3: if $1 < x \le 2$ then $\mathrm{service}_{W_x} = 2$, so the slack of $W_x$ is $2/x$.

**Theorem 3.6 (The slack spectrum is exactly $[1,2)$).**
$$\{\, c \in \mathbb{R} \;:\; \exists \text{ an exchange and a class with } \mathrm{service}(y) = c\cdot \mathrm{ideal}(y)\,\} \;=\; [1,2).$$

*Proof.* ($\subseteq$) Corollary 3.3. ($\supseteq$) Given $t \in [1,2)$, set $x = 2/t$. Then $x > 1$ because $t < 2$, and $x \le 2$ because $t \ge 1$. By Lemma 2.3, $\mathrm{service}_{W_x} = 2 = t \cdot (2/t) = t\cdot \mathrm{ideal}_{W_x}$. $\square$

**Corollary 3.7 (The floor is attained and optimal).** $W_1$ has $\mathrm{ideal} = 1 = 2^0$, so by Theorem 3.4 its service equals its ideal share exactly. Consequently no constant $c > 1$ satisfies $c\cdot\mathrm{ideal}(y) \le \mathrm{service}(y)$ for all exchanges.

**Corollary 3.8 (The ceiling is optimal).** For every $\varepsilon > 0$ there is an exchange with $(2-\varepsilon)\,\mathrm{ideal}(y) < \mathrm{service}(y)$; hence no constant $c < 2$ satisfies $\mathrm{service}(y) \le c\cdot\mathrm{ideal}(y)$ for all exchanges.

*Proof.* Take $x = 1 + \min(\varepsilon/4, 1/2)$, so $1 < x \le 2$ and $\mathrm{service}_{W_x} = 2$. One checks $(2-\varepsilon)x < 2$: if $\varepsilon \ge 2$ this is trivial, and if $\varepsilon < 2$ it is equivalent to $x - 1 < \varepsilon/(2-\varepsilon)$, which holds since $x - 1 \le \varepsilon/4 < \varepsilon/(2-\varepsilon)$ whenever $2 - \varepsilon < 4$. $\square$

Thus the mission statement — *the no-starvation constant cannot be improved beyond a factor of $2$* — holds in the strongest possible form: the bound $\mathrm{service} < 2\,\mathrm{ideal}$ is universal, the value $1$ is attained, and the value $2$ is the exact supremum.

---

## 4. Where the factor two comes from

The dyadic constants are not special. Replace the ladder $2^{\mathbb{Z}}$ by $\rho^{\mathbb{Z}}$.

**Theorem 4.1 (General grid, general witness).** For every $\rho > 1$ and every $t \in [1,\rho)$ there is an exchange with $\mathrm{service}_\rho(y) = t\cdot\mathrm{ideal}(y)$; namely $W_{\rho/t}$.

*Proof.* With $x = \rho/t$ we have $1 < x \le \rho$, so Lemma 2.3 gives $\mathrm{service}_\rho = \rho = t\cdot(\rho/t)$. $\square$

**Theorem 4.2 (Optimal ceiling constant).** For $\rho > 1$ and $c \in \mathbb{R}$,
$$\big(\forall\ \text{exchanges}:\ \mathrm{service}_\rho(y) \le c\cdot\mathrm{ideal}(y)\big) \iff \rho \le c.$$

*Proof.* ($\Leftarrow$) Lemma 2.2 gives $\mathrm{service}_\rho < \rho\,\mathrm{ideal} \le c\,\mathrm{ideal}$. ($\Rightarrow$) Suppose $c < \rho$. Put $t = \max(1, (c+\rho)/2)$; then $1 \le t < \rho$ and $c < t$. Theorem 4.1 supplies an exchange with slack exactly $t > c$, contradicting the bound. $\square$

**Theorem 4.3 (Optimal floor constant).** For $\rho > 1$ and $c \in \mathbb{R}$,
$$\big(\forall\ \text{exchanges}:\ c\cdot\mathrm{ideal}(y) \le \mathrm{service}_\rho(y)\big) \iff c \le 1.$$

*Proof.* ($\Leftarrow$) Lemma 2.1. ($\Rightarrow$) Theorem 4.1 with $t=1$ gives an exchange with $\mathrm{service}_\rho = \mathrm{ideal}$, forcing $c\cdot\mathrm{ideal} \le \mathrm{ideal}$ and hence $c \le 1$. $\square$

Specialising $\rho = 2$: $\mathrm{service} \le c\cdot\mathrm{ideal}$ holds universally iff $2 \le c$, and $c\cdot\mathrm{ideal} \le \mathrm{service}$ holds universally iff $c \le 1$. **The factor $2$ in the headline statement is precisely the grid ratio of the arbiter — nothing else.**

---

## 5. Aggregation and non-vacuity

**Theorem 5.1 (The floor aggregates).** For a finite family of classes, $\sum_y \mathrm{ideal}(y) \le \sum_y \mathrm{service}(y)$.

*Proof.* Sum Theorem 3.1 termwise. $\square$

**Theorem 5.2 (The ceiling aggregates).** For a finite *nonempty* family, $\sum_y \mathrm{service}(y) < 2\sum_y \mathrm{ideal}(y)$.

*Proof.* Sum the strict inequality of Theorem 3.2 over a nonempty index set. $\square$

Quantisation costs the whole channel the same factor of two, no more. The bound is therefore an aggregate capacity statement, not just a per-class one.

**Theorem 5.3 (Rare channels are squeezed out).** For any $\varepsilon > 0$, if $\mathrm{gap}(y) > 2\gamma d(y)/\varepsilon$ then $\mathrm{service}(y) < \varepsilon$.

*Proof.* The hypothesis rearranges to $2\gamma d(y)/\mathrm{gap}(y) < \varepsilon$, i.e. $2\,\mathrm{ideal}(y) < \varepsilon$; combine with $\mathrm{service}(y) < 2\,\mathrm{ideal}(y)$. $\square$

Physically: as $p(y) \to 0$ the Boltzmann cost $\beta\log(1/p(y))$ diverges, the gap diverges, and the service tends to $0$. The floor of Theorem 3.1 is therefore a genuine, saturating constraint — a class *can* be driven to arbitrarily small service, and the floor is exactly the boundary of that decay.

---

## 6. Phase-jittered arbiters

A natural attempt to improve the worst case: randomise the ladder.

**Definition 6.1 (Jittered quantiser).** For $\rho > 1$, phase $\theta \in \mathbb{R}$ and $x > 0$,
$$J_{\rho,\theta}(x) \;=\; \rho^{\lceil \log_\rho x - \theta\rceil + \theta}.$$
For $\theta = 0$ this is $\mathrm{gridCeil}_\rho$; in general it is the ladder $\rho^{\mathbb{Z}}$ shifted multiplicatively by $\rho^{\theta}$.

**Theorem 6.2 (The guarantee is phase-independent).** For every $\rho>1$, every phase $\theta$ and every $x > 0$,
$$x \;\le\; J_{\rho,\theta}(x) \;<\; \rho\,x.$$

*Proof.* $\lceil t\rceil \ge t$ with $t = \log_\rho x - \theta$ gives $\lceil t\rceil + \theta \ge \log_\rho x$, hence the left inequality by monotonicity of $\rho^{(\cdot)}$. And $\lceil t\rceil < t+1$ gives $\lceil t\rceil + \theta < \log_\rho x + 1$, hence the right. $\square$

**Corollary 6.3 (Randomisation cannot help the worst case).** Since the two-sided bound of Theorem 6.2 is attained in the limit *at every fixed phase* — by Theorem 4.1 applied to the shifted ladder — no probability distribution over phases can lower the supremum of the slack below $\rho$, nor raise the infimum above $1$. The often-conjectured statement "randomisation improves the worst case" is **false** for this family.

What randomisation *does* change is the distribution of the slack, and that distribution is exactly computable.

**Theorem 6.4 (The log-slack is a circle rotation).** For $\rho > 1$, $x > 0$ and every phase $\theta$,
$$\log_\rho\!\Big(\frac{J_{\rho,\theta}(x)}{x}\Big) \;=\; \{\theta - \log_\rho x\},$$
where $\{t\} = t - \lfloor t\rfloor$ is the fractional part.

*Proof.* $\log_\rho(J_{\rho,\theta}(x)/x) = \lceil \log_\rho x - \theta\rceil + \theta - \log_\rho x = \lceil u\rceil - u$ with $u = \log_\rho x - \theta$. The elementary identity $\lceil u\rceil - u = \{-u\}$ (verified separately for $u\in\mathbb{Z}$ and $u\notin\mathbb{Z}$) finishes the proof. $\square$

So as the phase $\theta$ sweeps a unit interval, the log-slack sweeps the circle $\mathbb{R}/\mathbb{Z}$ uniformly. The mean of the fractional part over any interval of unit length is $\tfrac12$, since $\{\cdot\}$ is $1$-periodic and $\int_0^1 t\,dt = \tfrac12$.

**Theorem 6.5 (Mean log-slack).** For every $\rho > 1$ and $x > 0$,
$$\int_0^1 \log_\rho\!\Big(\frac{J_{\rho,\theta}(x)}{x}\Big)\,d\theta = \frac12, \qquad \int_0^1 \log\!\Big(\frac{J_{\rho,\theta}(x)}{x}\Big)\,d\theta = \frac{\log\rho}{2}.$$

*Proof.* Substitute Theorem 6.4 and translate the integration variable: the integrand becomes $\{\theta - \log_\rho x\}$, an integral of a $1$-periodic function over a unit interval, hence equal to $\int_0^1\{t\}\,dt = \tfrac12$. Multiply by $\log\rho$ for the second identity. $\square$

**Theorem 6.6 (Geometric-mean slack).** For every $\rho > 1$ and every $x > 0$,
$$\exp\!\left(\int_0^1 \log\frac{J_{\rho,\theta}(x)}{x}\,d\theta\right) \;=\; \sqrt{\rho}.$$

*Proof.* Immediate from Theorem 6.5: $\exp(\tfrac12\log\rho) = \rho^{1/2}$. $\square$

Note the striking uniformity: the typical slack does not depend on $x$ at all, hence not on the exchange. For the dyadic arbiter it is $\sqrt2 \approx 1.4142$, strictly below the worst case $2$.

**Theorem 6.7 (Arithmetic-mean slack).** For every $\rho > 1$ and every $x > 0$,
$$\int_0^1 \frac{J_{\rho,\theta}(x)}{x}\,d\theta \;=\; \frac{\rho-1}{\log\rho}.$$

*Proof.* By Theorem 6.4 the integrand is $\rho^{\{\theta - \log_\rho x\}}$. Since $s \mapsto \rho^{\{s\}}$ is $1$-periodic, translating the variable reduces the integral to $\int_0^1 \rho^{s}\,ds$. Writing $\rho^s = e^{s\log\rho}$ and integrating gives $(\rho - 1)/\log\rho$. $\square$

For $\rho = 2$ this is $1/\log 2 \approx 1.4427$.

**Theorem 6.8 (Strict hierarchy of the three constants).** For every $\rho > 1$,
$$\sqrt\rho \;<\; \frac{\rho-1}{\log\rho} \;<\; \rho.$$

*Proof.* *Left inequality.* Set $u = \sqrt\rho > 1$, so $\log\rho = 2\log u$ and $\rho - 1 = u^2 - 1$. The claim becomes $u < (u^2-1)/(2\log u)$, i.e. $2\log u < u - 1/u$. Consider $f(u) = u - 1/u - 2\log u$ on $[1,\infty)$. Then $f(1) = 0$ and
$$f'(u) = 1 + \frac{1}{u^2} - \frac{2}{u} = \Big(1 - \frac1u\Big)^2 > 0 \quad (u>1),$$
a perfect square. Hence $f$ is strictly increasing on $[1,\infty)$ and $f(u) > 0$ for $u > 1$.

*Right inequality.* From $\log t < t - 1$ for $t > 0$, $t \ne 1$, applied with $t = 1/\rho$: $-\log\rho < 1/\rho - 1$, i.e. $\log \rho > 1 - 1/\rho = (\rho-1)/\rho$. Multiplying by $\rho/\log\rho > 0$ gives $\rho > (\rho-1)/\log\rho$. $\square$

For the dyadic arbiter: $1.4142\ldots < 1.4427\ldots < 2$.

**Interpretation.** Jitter does not change the *guarantee* — the floor and the ceiling are both exactly as before — but it converts the worst-case factor into a typical factor $\sqrt\rho$ and an average factor $(\rho-1)/\log\rho$. For capacity planning this is the practically relevant number; for admission control the worst case remains binding.

---

## 7. The optimal grid ratio

The grid ratio is a design parameter. A larger $\rho$ costs more in the worst case ($\mathrm{slack} < \rho$) but covers more logarithmic dynamic range per backoff level ($\log \rho$ per level). The natural figure of merit is therefore:

**Definition 7.1 (Grid cost).** $C(\rho) = \dfrac{\rho}{\log \rho}$ for $\rho > 1$: worst-case slack per unit of logarithmic range covered by one level.

**Theorem 7.2 (Euler's number is the unique optimum).** For every $\rho > 1$, $e \le C(\rho)$, with equality iff $\rho = e$; and $C(e) = e$.

*Proof.* Apply $\log t \le t - 1$ with $t = \rho/e > 0$: $\log\rho - 1 \le \rho/e - 1$, so $\log\rho \le \rho/e$, i.e. $e\log\rho \le \rho$, i.e. $e \le \rho/\log\rho = C(\rho)$ (using $\log\rho > 0$). Strictness: $\log t < t-1$ whenever $t \ne 1$, and $t = \rho/e = 1$ iff $\rho = e$. Finally $C(e) = e/\log e = e$. $\square$

**Theorem 7.3 (Binary and quaternary arbiters tie exactly).** $C(4) = C(2)$.

*Proof.* $\log 4 = 2\log 2$, so $C(4) = 4/(2\log2) = 2/\log 2 = C(2)$. $\square$

**Theorem 7.4 (The dyadic arbiter is within $7\%$ of optimal).** $C(2) < 1.07\, e$.

*Proof.* $C(2) = 2/\log 2$. Using $\log 2 > 0.6931471803$ and $e > 2.7182818283$ one has $2/\log 2 < 2.8854 < 1.07 \times 2.7182 < 1.07\,e$. $\square$

**Verdict (Theorem 7.5).** The dyadic arbiter satisfies, simultaneously: $e < C(2) < 1.07\,e$ (near-optimal grid design), worst-case slack exactly $2$ (unimprovable, Theorem 4.2), typical slack $\sqrt2 < 2$ (Theorem 6.6), and mean slack $1/\log 2$ strictly between them (Theorems 6.7, 6.8).

**A caution against over-claiming.** It is tempting to conclude that "the dyadic grid is optimal". This is *false*: $e$ is optimal, and $3$ is closer to $e$ than $2$ is ($C(3) = 3/\log 3 \approx 2.7307$ versus $C(2) \approx 2.8854$). The defensible statements are the quantitative $7\%$ bound and the exact tie $C(2) = C(4)$, which does explain why doubling the window is a natural fixed point of the design trade-off: over the integer ratios, the cost function is flat between $2$ and $4$ with a minimum at $3$ in between.

---

## 8. Diophantine dynamics: sharpness inside a single exchange

Everything so far quantifies over the space of exchanges. Sharpness meant: *some* configuration realises slack close to $2$. A sharper question, invisible at that level, is whether a **single running exchange** sees the whole spectrum over time.

Model the natural scenario: a class whose demand grows geometrically by a factor $\alpha > 0$ per round, so the ideal share runs along the ladder $\alpha^n$, $n \in \mathbb{Z}$. (By the witness family of Definition 3.5, every such ladder is realised by a genuine exchange, and $\mathrm{service}/\mathrm{ideal}$ for that exchange is exactly $\mathrm{slack}(\alpha^n)$.)

**Lemma 8.1 (Log-slack is a ceiling defect).** For $x > 0$, $\mathrm{logSlack}(x) = \{-\log_2 x\}$.

*Proof.* $\mathrm{slack}(x) = 2^{\lceil \log_2 x\rceil - \log_2 x}$, so $\mathrm{logSlack}(x) = \lceil u\rceil - u$ with $u = \log_2 x$, which equals $\{-u\}$. $\square$

**Theorem 8.2 (The demand ladder is a circle rotation).** For $\alpha > 0$ and $n \in \mathbb{Z}$,
$$\mathrm{logSlack}(\alpha^n) \;=\; \{\, n\cdot(-\log_2\alpha)\,\}.$$

*Proof.* $\log_2(\alpha^n) = n\log_2\alpha$; substitute into Lemma 8.1. $\square$

So the log-slack of the exchange, sampled round by round, is the orbit of $0$ under the rotation of the circle $\mathbb{R}/\mathbb{Z}$ by the angle $-\log_2\alpha$. The classical dichotomy for circle rotations now decides everything.

**Theorem 8.3 (Kronecker's theorem, in the form needed).** Let $\vartheta$ be irrational. For every $y \in (0,1)$ and every $\varepsilon > 0$ there is $n \in \mathbb{Z}$ with $|\{n\vartheta\} - y| < \varepsilon$.

*Proof sketch.* The additive subgroup of $\mathbb{R}$ generated by $\vartheta$ and $1$ is dense precisely when $\vartheta \notin \mathbb{Q}$ (a closed subgroup of $\mathbb{R}$ is either cyclic or all of $\mathbb{R}$, and $\langle \vartheta,1\rangle$ cyclic would force $\vartheta$ rational). Choose $\delta = \min(\varepsilon, y, 1-y) > 0$ and pick a group element $z = m\vartheta + k$ with $|z - y| < \delta$. Then $0 < z < 1$, so $\{m\vartheta\} = \{z - k\} = \{z\} = z$, and $|\{m\vartheta\} - y| < \delta \le \varepsilon$. $\square$

**Theorem 8.4 (Dense slack orbit in the irrational case).** If $\alpha > 0$ and $\log_2 \alpha$ is irrational, then for every $s \in (0,1)$ and every $\varepsilon > 0$ there is $n \in \mathbb{Z}$ with $|\mathrm{logSlack}(\alpha^n) - s| < \varepsilon$. Consequently
$$[0,1] \;\subseteq\; \overline{\{\mathrm{logSlack}(\alpha^n) : n \in \mathbb{Z}\}}.$$

*Proof.* Apply Theorem 8.3 with $\vartheta = -\log_2\alpha$ (irrational since $\log_2\alpha$ is) and use Theorem 8.2. This shows the orbit closure contains $(0,1)$; taking closures again and using $\overline{(0,1)} = [0,1]$ together with idempotence of closure gives the display. $\square$

**Theorem 8.5 (A single exchange saturates both ends).** If $\log_2\alpha$ is irrational and $0 < \varepsilon < 1$, then
$$\exists\,n\in\mathbb{Z}:\ \mathrm{slack}(\alpha^n) > 2^{\,1-\varepsilon}, \qquad \exists\,m\in\mathbb{Z}:\ \mathrm{slack}(\alpha^m) < 2^{\,\varepsilon}.$$

*Proof.* Apply Theorem 8.4 with target $s = 1 - \varepsilon/2$ and tolerance $\varepsilon/4$ to obtain $n$ with $\mathrm{logSlack}(\alpha^n) > 1 - \tfrac34\varepsilon > 1-\varepsilon$; since $\mathrm{slack} = 2^{\mathrm{logSlack}}$ and $t\mapsto 2^t$ is increasing, the first claim follows. Symmetrically with target $s = \varepsilon/2$ and tolerance $\varepsilon/4$ for the second. $\square$

So one exchange, watched long enough, gets arbitrarily close to wasting a full factor of $2$, and on other rounds is served with essentially no waste at all.

**Theorem 8.6 (Periodicity and finiteness in the rational case).** Suppose $\log_2\alpha = p/q$ with $q \ne 0$ integers. Then for all $n,k\in\mathbb{Z}$,
$$\mathrm{logSlack}(\alpha^{\,n+kq}) = \mathrm{logSlack}(\alpha^{\,n}).$$
If moreover $q > 0$, the orbit $\{\mathrm{logSlack}(\alpha^n) : n \in \mathbb{Z}\}$ is finite (of cardinality at most $q$), hence closed, hence *not* dense in $[0,1]$.

*Proof.* By Theorem 8.2, $\mathrm{logSlack}(\alpha^{n+kq}) = \{(n+kq)(-p/q)\} = \{n(-p/q) - kp\}$, and $\{t - j\} = \{t\}$ for integer $j$. For finiteness, every $n$ is congruent mod $q$ to some element of $\{0,\dots,q-1\}$, so the orbit is the image of a finite set. A finite subset of $\mathbb{R}$ is closed and cannot contain the infinite set $[0,1]$. $\square$

**Theorem 8.7 (Diophantine dichotomy).** For $\alpha > 0$,
$$[0,1] \subseteq \overline{\{\mathrm{logSlack}(\alpha^n) : n\in\mathbb{Z}\}} \iff \log_2\alpha \ \text{is irrational}.$$

*Proof.* ($\Leftarrow$) Theorem 8.4. ($\Rightarrow$) If $\log_2\alpha = p/q$ is rational, write it with $q > 0$; Theorem 8.6 shows the orbit is finite and hence not dense. $\square$

**Sharpness for a fixed exchange is therefore a Diophantine property of the growth ratio, not a scheduling property.**

**Theorem 8.8 ($\log_2 3$ is irrational).** If $\log_2 3 = p/q$ with $p,q$ positive integers then $q\log 3 = p\log 2$, so $3^q = 2^p$ — impossible by unique factorisation (the left side is odd and exceeds $1$, the right side is even). Positivity of $p,q$ follows from $\log_2 3 > 0$. $\square$

**Theorem 8.9 (Ternary growth saturates the spectrum).** If demand grows by a factor $3$ per round, then $[0,1] \subseteq \overline{\{\mathrm{logSlack}(3^n)\}}$; quantitatively, for every $0 < \varepsilon < 1$ some round has slack exceeding $2^{1-\varepsilon}$ and some round has slack below $2^{\varepsilon}$.

*Proof.* Theorems 8.4, 8.5 and 8.8. $\square$

By contrast, growth ratio $\alpha = 4$ has $\log_2 4 = 2 \in \mathbb{Z}$, so every $\alpha^n$ lies on the dyadic grid and the slack is identically $1$: perfect efficiency forever. And $\alpha = \sqrt2$ has $\log_2\alpha = 1/2$, giving a period-$2$ orbit with slack values $\{1, \sqrt2\}$. The behaviour of a running exchange is decided entirely by the arithmetic of $\log_2\alpha$.

---

## 9. Algorithms

Three computational primitives summarise the theory.

**Algorithm 9.1 (Dyadic allocation).** Given $\beta,\gamma,M$ and per-class $(p,d,r)$, compute $\mathrm{gap} = \beta\log(1/p)+M+\gamma-r$; abort if $\mathrm{gap} \le 0$; compute $\mathrm{ideal} = \gamma d/\mathrm{gap}$; return $2^{\lceil\log_2\mathrm{ideal}\rceil}$. Cost: $O(1)$ per class, or $O(|\iota|)$ for the whole channel. Numerically, the ceiling must be computed carefully: when $\log_2\mathrm{ideal}$ is within floating-point epsilon of an integer, one should snap to that integer, otherwise a share that is exactly a power of two can be rounded to the *next* window and the reported slack jumps spuriously from $1$ to $2$.

**Algorithm 9.2 (Slack-orbit sampler).** Given a growth ratio $\alpha$ and a horizon $N$, return $\big(\{-n\log_2\alpha\}\big)_{n=0}^{N-1}$ together with the discrepancy of the sample against the uniform distribution. Cost $O(N)$ (or $O(N\log N)$ if the sample is sorted to compute the star discrepancy exactly). For irrational $\log_2\alpha$ the discrepancy tends to $0$; for rational $\log_2\alpha = p/q$ in lowest terms it stalls at a value bounded below by roughly $1/(2q)$, giving a practical numerical test of the dichotomy of Theorem 8.7.

**Algorithm 9.3 (Grid-cost optimiser).** Minimise $C(\rho) = \rho/\log\rho$ over $\rho > 1$. Since $C'(\rho) = (\log\rho - 1)/(\log\rho)^2$, the unique stationary point is $\rho = e$ and $C$ is strictly decreasing on $(1,e)$ and strictly increasing on $(e,\infty)$; a bisection on $C'$ or a direct golden-section search converges in $O(\log(1/\text{tol}))$ evaluations. Practically the routine is used to report the *relative excess* $C(\rho)/e - 1$ for a candidate ratio.

---

## 10. Applications and discussion

**Admission control.** Theorem 3.1 is the safety property a scheduler advertises. Theorem 4.2 says that the corresponding capacity reservation must be $\rho$ times the sum of ideal shares, and that this factor cannot be shaved: any admission controller that provisions less than $\rho\sum_y \mathrm{ideal}(y)$ can be defeated by an adversarial demand vector. Theorem 5.2 confirms the factor does not compound across classes.

**Capacity planning.** For *expected* throughput, the binding constant is not $\rho$ but $(\rho-1)/\log\rho$ (arithmetic mean, Theorem 6.7), or $\sqrt\rho$ if one is combining slacks multiplicatively across independent stages (geometric mean, Theorem 6.6). For $\rho = 2$ that is a planning factor of $1.44$ rather than $2$ — a $28\%$ difference in provisioned capacity, entirely accounted for by which mean is appropriate.

**Grid design.** Theorem 7.2 says a designer free to choose the ratio should choose $e$; Theorem 7.4 says $2$ costs at most $7\%$ more; Theorem 7.3 says $4$ costs exactly the same as $2$. Any protocol restricted to integer ratios and wanting the theoretical optimum should use $3$, at $C(3)\approx 2.7307$ versus the ideal $e \approx 2.7183$ — an excess of under half a percent.

**Diagnostics.** Section 8 has an operational reading. If a running class exhibits a slack that is constant, or cycles through a short finite list, its demand growth ratio is a rational power of the grid ratio, and the deployment is either perfectly efficient (slack $1$) or persistently wasteful by a fixed factor. If the observed slack wanders densely over $[1,2)$, the growth ratio is Diophantine-generic. A monitoring system can therefore infer a structural property of the workload from the empirical distribution of its overshoot.

**What did not survive.** Two attractive conjectures are false and worth recording. (i) *Randomisation improves the worst case.* False: Theorem 6.2 holds at every phase, so no phase distribution lowers the supremum. (ii) *The dyadic grid is optimal.* False as stated: $e$ is the unique optimum and $3$ is closer to it than $2$; the honest version is Theorem 7.4. A third statement, the strict AM–GM gap $\sqrt\rho < (\rho-1)/\log\rho$, was first conjectured from numerics and then proved (Theorem 6.8) via the perfect-square derivative identity.

**Limitations.** The model treats each class's allocation independently, with no global capacity constraint coupling them; a constrained version (allocate $\sum_y \mathrm{service}(y) \le 1$) would make the arbiter's rounding decisions interdependent, and the sharp constants there are open. The jitter analysis averages over a *uniform* phase; one may ask whether a non-uniform phase distribution optimises some other functional of the slack (it cannot change the sup or inf, by Corollary 6.3, but it can change every moment in between). Finally, the geometric demand ladder of Section 8 is the simplest non-trivial dynamics; general demand processes require an ergodic-theoretic rather than a Diophantine treatment.

---

## 11. Future work

**Sub-$\rho$ slack for state-dependent arbiters.** The factor $\rho$ is forced only because the arbiter is *memoryless*: each request is rounded independently, so the log-slack is a fixed point of the shift on $\mathbb{R}/\log\rho\,\mathbb{Z}$. An arbiter carrying a deficit counter between rounds can *borrow* from a round whose slack is small. The natural conjecture is that the long-run *average* slack of the optimal state-dependent arbiter equals the geometric mean $\sqrt\rho$, not $\rho$, while the *per-round* worst case remains $\rho$. Cycle-averaged results of Section 6 give the target constant; what is needed is a matching lower bound over all causal deficit policies.

**Quantitative equidistribution.** Theorem 8.7 is qualitative. For a badly-approximable growth ratio (bounded continued-fraction partial quotients, e.g. $\log_2\alpha$ with quadratic-irrational-like behaviour), the discrepancy of the slack orbit after $N$ rounds should be $O(\log N/N)$, giving an explicit bound on how many rounds an operator must wait before observing a slack within $\varepsilon$ of the ceiling. Conversely, Liouville-type ratios would give arbitrarily long stretches of nearly constant slack.

**Multi-class coupling.** With a hard channel constraint the arbiter must round some classes down; the resulting object is a simultaneous Diophantine approximation problem, and the sharp constant should depend on the number of classes.

**Non-uniform phase distributions.** Characterise which functionals of the slack distribution are optimised by which phase laws, given that the sup and inf are immovable.

---

## 12. Conclusion

Quantisation in a thermodynamically fair scheduler costs exactly the grid ratio, and nothing can be shaved from either end: the achievable slack set is exactly $[1,\rho)$, closed at $1$ and open at $\rho$, with the openness explained structurally by log-periodicity. Randomising the grid leaves the guarantee untouched but sets the typical cost at $\sqrt\rho$ and the mean cost at $(\rho-1)/\log\rho$, strictly ordered below $\rho$. The best grid ratio is Euler's number; the ubiquitous choice $\rho = 2$ costs under $7\%$ more and ties exactly with $\rho = 4$. And whether a given running exchange ever feels the worst case is settled by a single arithmetic question about its growth ratio: dense slack if and only if $\log_2\alpha$ is irrational. Tripling demand each round eventually meets every inefficiency the design permits; quadrupling it never wastes a slot.
