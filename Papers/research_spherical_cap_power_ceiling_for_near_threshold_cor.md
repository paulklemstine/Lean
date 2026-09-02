# A Spherical-Cap Power Ceiling for Near-Threshold Correlation Tests

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

We study the resolving power of test statistics when two competing hypotheses are realised by predictor vectors that are nearly parallel. Writing $\hat u = u/\|u\|$ for the direction of a coordinate vector $u \in \mathbb{R}^n$ and $\operatorname{corr}(u,v) = \langle u,v\rangle/(\|u\|\|v\|)$, we begin from the exact chordal identity $\|\hat u - \hat v\|^2 = 2 - 2\operatorname{corr}(u,v)$, so that an alignment hypothesis $\operatorname{corr}(u,v) \ge 1 - \varepsilon$ confines the entire testing problem to a spherical cap of chordal radius $\sqrt{2\varepsilon}$ and angular radius at most $(\pi/2)\sqrt{2\varepsilon}$.

From this we derive a **sample-size-free power ceiling**: every statistic $F$ that is $L$-Lipschitz on the unit sphere satisfies $|F(\hat u) - F(\hat v)| \le L\sqrt{2\varepsilon}$, with no dependence on the ambient dimension $n$. The bound is invariant under $m$-fold replication of the experiment, because correlation — and hence the chord — is exactly replication-invariant. It is sharp: for every $L \ge 0$ the distance statistic $x \mapsto L\|x - \hat v\|$ attains it. The constrained class is non-vacuous: correlation against a fixed unit response is exactly $1$-Lipschitz on the sphere.

Applied to a recorded near-threshold configuration in which a pooled reading of $0.558$ is compared against a pre-registered floor of $0.550$, and in which the two competing predictors can be aligned to $\operatorname{corr}(u,v) \ge 0.9999$, the ceiling is $\sqrt2/100 = 0.014142\ldots$ (angular radius $0.81027^\circ < 0.9^\circ$). Conversely the recorded margin $\delta = 0.008$ forces $\operatorname{corr}(u,v) \le 1 - \delta^2/2 = 0.999968$, pinning the alignment in a window of width $6.8 \times 10^{-5}$.

We then identify the **optimal smooth test**: correlation against the contrast direction $e = (\hat u - \hat v)/\|\hat u - \hat v\|$ separates the hypotheses by *exactly* $\|\hat u - \hat v\|$, so the supremum of separation over the sphere-Lipschitz class is precisely the chordal distance and is attained by a correlation statistic. On the recorded configuration the optimal smooth test improves on the response correlation by at most a factor $\sqrt2/100 \div 0.008 = 1.7678$. A capacity theorem shows the cap admits at most one resolvable rung of any hypothesis ladder at the recorded margin, and that exactly one is attained. Extending Lipschitz to Hölder replaces the ceiling by $C(\sqrt{2\varepsilon})^\alpha$ without removing the obstruction. Finally, a discontinuous rank/threshold statistic attains maximal separation $1$ on the very same configuration while failing to be $L$-Lipschitz for any $L$ — locating the escape route precisely at the loss of continuity, and identifying a concrete better test to run.

**Keywords:** spherical cap, chordal distance, Lipschitz statistic, power ceiling, near-threshold correlation test, replication invariance, Hölder continuity, contrast direction.

---

## 1. Introduction

### 1.1 The phenomenon

Consider an experimental programme that summarises each run by a rank correlation between a predictor and a response, and that has pre-registered a threshold: the effect is declared present if the pooled correlation reaches $0.550$. Suppose the pooled reading comes back as $0.558$, with a resampling confidence interval that straddles the floor. The recorded verdict — *approaching, not crossed* — is a statement of genuine ambiguity, and the standard remedy is replication.

We show that in a precise and quantifiable sense the remedy cannot work, for a class of statistics that includes essentially all the ones an experimentalist would compute. The obstruction is not statistical but geometric, and it is invisible to sample-size calculations because the governing bound contains no sample size.

### 1.2 The mechanism in one paragraph

Correlation is scale-invariant, so a predictor is only ever seen through its direction, a point on the unit sphere $S^{n-1}$. Two hypotheses — "the dial reads $0.558$" and "the dial sits at $0.550$" — are realised by directions $\hat u, \hat v$. If those directions can be aligned to correlation $1 - \varepsilon$, the identity $\|\hat u - \hat v\|^2 = 2 - 2\operatorname{corr}(u,v)$ places both inside a spherical cap of radius $\sqrt{2\varepsilon}$. Any statistic that is stable — Lipschitz on the sphere — assigns values to the two hypotheses that differ by at most (Lipschitz constant) $\times$ (cap radius). Since correlation is invariant under replication, so is the cap radius, so replication does not shrink the bound. The only way out is to abandon stability.

### 1.3 Contributions

1. **Chordal geometry of a correlation cap** (§3): the identity $\|\hat u - \hat v\|^2 = 2 - 2c$, the cap bound $\sqrt{2\varepsilon}$, an angular form $\arccos c \le (\pi/2)\sqrt{2-2c}$ derived from Jordan's inequality, and the numerical fact that alignment $0.9999$ corresponds to angular radius below $0.9^\circ$.
2. **The sample-size-free ceiling** (§4): $|F(\hat u)-F(\hat v)| \le L\sqrt{2\varepsilon}$, its converse form (separation $\delta$ requires $L \ge \delta/\sqrt{2\varepsilon}$), and the specialisation to $L \ge 70$ for full separation at $\varepsilon = 10^{-4}$.
3. **Replication invariance** (§5): exact invariance of correlation and chord under $m$-fold repetition, hence an identical ceiling in dimension $mn$ for every $m$.
4. **Sharpness and non-vacuity** (§6): the distance statistic attains the ceiling for every $L$; the correlation statistic is $1$-Lipschitz on the sphere, so the class contains the test actually used.
5. **The alignment window** (§7): a recorded margin $\delta$ caps alignment at $1 - \delta^2/2$; combined with the attained configuration this pins the alignment between $0.9999$ and $0.999968$.
6. **The optimal smooth test** (§8): correlation against the contrast direction attains the ceiling exactly, so the optimum over the sphere-Lipschitz class *is* the chordal distance; the improvement over the recorded response correlation is capped at a factor $1.7678$.
7. **Cap capacity and Hölder robustness** (§9): at most one resolvable ladder rung fits in the cap at margin $0.008$, and exactly one is attained; the Hölder ceiling $C(\sqrt{2\varepsilon})^\alpha$ generalises the Lipschitz one.
8. **The escape** (§10): a rank/threshold statistic separates the same configuration by $1$ and is not $L$-Lipschitz for any $L$.

---

## 2. Setting and definitions

Throughout, $n \ge 1$ and vectors are elements of $\mathbb{R}^n$ regarded as coordinate tuples $u = (u_1,\dots,u_n)$.

**Definition 2.1 (inner product and norm).** $\langle u, v\rangle = \sum_{i=1}^n u_i v_i$ and $\|u\| = \sqrt{\langle u,u\rangle}$.

**Definition 2.2 (correlation).** For $u, v$ with $\|u\|,\|v\| \neq 0$,
$$\operatorname{corr}(u,v) \;=\; \frac{\langle u,v\rangle}{\|u\|\,\|v\|}.$$
By Cauchy–Schwarz, $-1 \le \operatorname{corr}(u,v) \le 1$. (In applications $u$ and $v$ are centred, or are rank vectors, so that this coincides with the Pearson or Spearman coefficient; nothing below uses centring.)

**Definition 2.3 (direction).** $\hat u = u/\|u\|$, with the convention $\hat 0 = 0$. For $u \neq 0$, $\|\hat u\| = 1$ and $\langle \hat u, \hat v\rangle = \operatorname{corr}(u,v)$. Correlation is unchanged by normalisation: $\operatorname{corr}(\hat u, w) = \operatorname{corr}(u,w)$.

**Definition 2.4 (chordal distance).** For nonzero $u, v$,
$$\operatorname{chord}(u,v) \;=\; \|\hat u - \hat v\|.$$

**Definition 2.5 (test statistic).** A *statistic* is a function $F : \mathbb{R}^n \to \mathbb{R}$. Its *separation* on the pair $(u,v)$ is $|F(\hat u) - F(\hat v)|$. A statistic *fully separates* the pair if its separation is $1$ (the natural normalisation for a decision rule taking values in $\{0,1\}$).

**Definition 2.6 (Lipschitz classes).** For $L \ge 0$:
- $F$ is **$L$-Lipschitz** if $|F(x)-F(y)| \le L\|x-y\|$ for all $x,y \in \mathbb{R}^n$;
- $F$ is **$L$-Lipschitz on the sphere** if $|F(x)-F(y)| \le L\|x-y\|$ for all $x,y$ with $\|x\|=\|y\|=1$.

The second class is strictly larger and is the one the geometry actually requires; every $L$-Lipschitz function is $L$-Lipschitz on the sphere. All ceilings below are stated for the weaker (sphere) hypothesis wherever possible, which strengthens the results.

**Definition 2.7 (Hölder on the sphere).** For $C, \alpha \ge 0$, $F$ is $(C,\alpha)$-Hölder on the sphere if $|F(x)-F(y)| \le C\|x-y\|^\alpha$ for all unit $x,y$. Taking $\alpha = 1$ recovers Definition 2.6 exactly.

**Definition 2.8 (replication).** For $m \ge 1$, $\operatorname{rep}_m(u) \in \mathbb{R}^{mn}$ is the concatenation of $m$ copies of $u$: the model of $m$ independent repetitions of the same experiment producing the same coordinate profile.

**Definition 2.9 (contrast direction).** For $\hat u \neq \hat v$,
$$e(u,v) \;=\; \frac{\hat u - \hat v}{\|\hat u - \hat v\|},$$
the unit vector pointing from the second hypothesis toward the first.

**Definition 2.10 (rank/threshold statistic).** For a response $w$ and cut $t \in \mathbb{R}$,
$$\operatorname{Thr}_{w,t}(x) \;=\; \begin{cases} 1, & \operatorname{corr}(x,w) \ge t, \\ 0, & \text{otherwise.}\end{cases}$$

### 2.1 The reference configuration

We fix once and for all the recorded near-threshold instance to which numerical statements refer.

**Configuration (R).** There exist $u, v, w \in \mathbb{R}^2$, all nonzero, with
$$\operatorname{corr}(u,w) = 0.558, \qquad \operatorname{corr}(v,w) = 0.550, \qquad \operatorname{corr}(u,v) \ge 0.9999.$$

Configuration (R) encodes the empirical situation: $u$ realises the "crossed" reading, $v$ realises the "exactly at the floor" reading, $w$ is the common response, the recorded margin is $\delta = 0.008$, and the two competing predictors can be made mutually indistinguishable to four nines. Every numerical claim below is a claim about (R) or about the general theory specialised to $\varepsilon = 10^{-4}$, $\delta = 0.008$.

---

## 3. Chordal geometry of a correlation cap

**Theorem 3.1 (Chordal identity).** For nonzero $u,v \in \mathbb{R}^n$,
$$\operatorname{chord}(u,v)^2 \;=\; 2 - 2\operatorname{corr}(u,v).$$

*Proof.* Expand the squared norm bilinearly:
$$\|\hat u - \hat v\|^2 = \langle \hat u,\hat u\rangle - 2\langle \hat u,\hat v\rangle + \langle \hat v,\hat v\rangle.$$
Since $u,v \neq 0$ we have $\langle \hat u,\hat u\rangle = \langle \hat v,\hat v\rangle = 1$, and $\langle \hat u,\hat v\rangle = \operatorname{corr}(u,v)$ by scale-invariance of the correlation. $\square$

**Corollary 3.2 (Chordal formula).** $\operatorname{chord}(u,v) = \sqrt{2 - 2\operatorname{corr}(u,v)}$.

**Theorem 3.3 (Cap bound).** If $\operatorname{corr}(u,v) \ge 1 - \varepsilon$ then $\operatorname{chord}(u,v) \le \sqrt{2\varepsilon}$.

*Proof.* Monotonicity of $\sqrt{\cdot}$ applied to $2 - 2\operatorname{corr}(u,v) \le 2\varepsilon$. $\square$

The bound is an equality when the alignment hypothesis is tight, so no information is lost at this step.

**Theorem 3.4 (Angular form).** For $c \in [-1,1]$,
$$\arccos c \;\le\; \frac{\pi}{2}\sqrt{2 - 2c}.$$

*Proof sketch.* Put $t = \arccos c \in [0,\pi]$, so $\cos t = c$. The half-angle identity $\cos t = 1 - 2\sin^2(t/2)$ gives $2 - 2c = 4\sin^2(t/2)$, and since $t/2 \in [0,\pi/2]$ we have $\sin(t/2) \ge 0$, whence $\sqrt{2-2c} = 2\sin(t/2)$. Jordan's inequality $\sin x \ge (2/\pi)x$ on $[0,\pi/2]$, applied at $x = t/2$, yields $t \le \pi\sin(t/2) = (\pi/2)\sqrt{2-2c}$. $\square$

Thus chordal and angular radii agree to first order, with a factor at most $\pi/2$ in the worst case; for near-unit correlations the two are numerically almost identical.

**Theorem 3.5 (Cap radius of Configuration (R)).** With $\varepsilon = 10^{-4}$,
$$\sqrt{2\varepsilon} \;=\; \frac{\sqrt2}{100} \;=\; 0.0141421\ldots, \qquad \arccos(0.9999) \;<\; \frac{\pi}{200} \;=\; 0.9^\circ.$$

*Proof sketch.* The first is the identity $(\sqrt2/100)^2 = 2\cdot 10^{-4}$. For the second, set $x = \pi/400$ and use the elementary bound $\sin x > x - x^3/4$ together with $3 < \pi \le 4$ to get $\sin x > 0.0074$; then $\cos(\pi/200) = 1 - 2\sin^2 x < 0.9999$, and strict antitonicity of $\arccos$ on $[-1,1]$ inverts the inequality. $\square$

Numerically $\arccos(0.9999) = 0.0141423\ldots$ radians $= 0.81027^\circ$, comfortably inside the $0.9^\circ$ bound. **The entire hypothesis test of Configuration (R) lives in a cap of angular radius below one degree.**

---

## 4. The Lipschitz power ceiling

**Theorem 4.1 (Ceiling, chordal form).** If $F$ is $L$-Lipschitz on the sphere and $u,v$ are nonzero, then
$$|F(\hat u) - F(\hat v)| \;\le\; L\,\operatorname{chord}(u,v).$$

*Proof.* $\hat u$ and $\hat v$ are unit vectors, so the sphere-Lipschitz hypothesis applies verbatim with $\|\hat u - \hat v\| = \operatorname{chord}(u,v)$. $\square$

**Theorem 4.2 (Spherical-Cap Power Ceiling).** Let $L \ge 0$, let $F$ be $L$-Lipschitz on the sphere, and suppose $\operatorname{corr}(u,v) \ge 1 - \varepsilon$ for nonzero $u,v \in \mathbb{R}^n$. Then
$$|F(\hat u) - F(\hat v)| \;\le\; L\sqrt{2\varepsilon}.$$
**The bound is independent of $n$.**

*Proof.* Chain Theorem 4.1 with Theorem 3.3, using $L \ge 0$ to preserve the inequality under multiplication. $\square$

The absence of $n$ is the whole point. It is not that the bound degrades slowly with sample size; the bound does not see the sample size at all. Two hypotheses aligned at $1-\varepsilon$ are, to a stable statistic, at most $L\sqrt{2\varepsilon}$ apart in a two-dimensional experiment and in a two-billion-dimensional one alike.

**Theorem 4.3 (Converse: separation costs sensitivity).** Under the hypotheses of Theorem 4.2 with $\varepsilon > 0$, if $|F(\hat u) - F(\hat v)| \ge \delta$ then
$$L \;\ge\; \frac{\delta}{\sqrt{2\varepsilon}}.$$

*Proof.* Divide the ceiling by $\sqrt{2\varepsilon} > 0$. $\square$

**Corollary 4.4 (Full separation at (R) needs $L \ge 70$).** If $\operatorname{corr}(u,v) \ge 0.9999$ and a statistic $F$ that is $L$-Lipschitz on the sphere satisfies $|F(\hat u)-F(\hat v)| \ge 1$, then $L \ge 70$.

*Proof.* Theorem 4.3 with $\delta = 1$, $\varepsilon = 10^{-4}$ gives $L \ge 100/\sqrt2 = 70.71\ldots$; a crude rational bound $\sqrt 2 < 1.415$ suffices to conclude $L \ge 70$. $\square$

Interpretation: a decisive verdict inside the cap requires a statistic whose value moves by more than seventy units per unit of movement on the sphere. Such a statistic is not a measurement of the effect; it is a measurement of the position of the boundary.

---

## 5. Replication leaves the cap invariant

**Lemma 5.1.** $\langle \operatorname{rep}_m u, \operatorname{rep}_m v\rangle = m\langle u,v\rangle$ and $\|\operatorname{rep}_m u\| = \sqrt m\,\|u\|$.

*Proof.* Re-index the sum over $\{1,\dots,mn\}$ as a sum over $\{1,\dots,m\}\times\{1,\dots,n\}$ whose summand is independent of the first factor; the inner sum contributes $\langle u,v\rangle$ and there are $m$ of them. The norm claim is the case $v=u$ followed by $\sqrt{m\,\langle u,u\rangle} = \sqrt m\sqrt{\langle u,u\rangle}$. $\square$

**Theorem 5.2 (Replication invariance of correlation).** For $m \ge 1$ and nonzero $u,v$,
$$\operatorname{corr}(\operatorname{rep}_m u, \operatorname{rep}_m v) \;=\; \operatorname{corr}(u,v).$$

*Proof.* By Lemma 5.1 the numerator gains a factor $m$ and the denominator gains $\sqrt m \cdot \sqrt m = m$; these cancel. $\square$

**Corollary 5.3.** $\operatorname{chord}(\operatorname{rep}_m u, \operatorname{rep}_m v) = \operatorname{chord}(u,v)$, by Corollary 3.2.

**Theorem 5.4 (Replication does not help).** For every $m \ge 1$ there are nonzero $u_m, v_m \in \mathbb{R}^{2m}$, namely the $m$-fold replications of the Configuration (R) predictors, with $\operatorname{corr}(u_m,v_m) \ge 0.9999$ and
$$|F(\hat u_m) - F(\hat v_m)| \;\le\; L\frac{\sqrt2}{100}$$
for every $L \ge 0$ and every $F$ that is $L$-Lipschitz on the sphere of $\mathbb{R}^{2m}$.

*Proof.* Replicate (R), apply Theorem 5.2 to transport the alignment hypothesis, then apply Theorem 4.2 in dimension $2m$ with $\varepsilon = 10^{-4}$ and Theorem 3.5. $\square$

The ceiling constant $\sqrt2/100$ is literally the same real number for every $m$. Whatever replication accomplishes — and it accomplishes a great deal against sampling noise — it does not enlarge the geometric room available to a stable statistic.

---

## 6. The ceiling is sharp, and the class is non-vacuous

Two objections must be met: that $\sqrt{2\varepsilon}$ is a lossy estimate, and that the Lipschitz class might exclude the statistics that matter.

**Theorem 6.1 (Sharpness).** For every $L \ge 0$ and all nonzero $u,v$ there exists an $L$-Lipschitz statistic $F$ (Lipschitz globally, hence also on the sphere) with
$$|F(\hat u) - F(\hat v)| \;=\; L\,\operatorname{chord}(u,v).$$

*Proof.* Take $F(x) = L\|x - \hat v\|$. The reverse triangle inequality $\bigl|\,\|a\| - \|b\|\,\bigr| \le \|a-b\|$ applied to $a = x - \hat v$, $b = y - \hat v$ gives $|F(x)-F(y)| \le L\|x-y\|$. And $F(\hat v) = 0$, $F(\hat u) = L\|\hat u - \hat v\|$. $\square$

So Theorem 4.2 is an exact description of the class, not an artefact.

**Theorem 6.2 (Correlation is $1$-Lipschitz on the sphere).** Let $w$ be a unit vector. Then $F(x) = \operatorname{corr}(x,w)$ satisfies $|F(x)-F(y)| \le \|x-y\|$ for all unit $x,y$.

*Proof.* For unit $x$ and unit $w$, $\operatorname{corr}(x,w) = \langle x,w\rangle$. Hence $|F(x)-F(y)| = |\langle x-y, w\rangle| \le \|x-y\|\,\|w\| = \|x-y\|$ by Cauchy–Schwarz. $\square$

Note that $x\mapsto \operatorname{corr}(x,w)$ is *not* globally Lipschitz on $\mathbb{R}^n$ (it blows up in slope near the origin), which is exactly why the sphere-restricted class in Definition 2.6 is the right hypothesis: it is what the geometry uses, and it is what the practitioner's statistic satisfies.

**Auxiliary metric facts.** The chordal distance is a pseudometric: $\operatorname{chord}(u,v) = \operatorname{chord}(v,u)$, $\operatorname{chord}(u,u) = 0$, and
$$\operatorname{chord}(u,w) \;\le\; \operatorname{chord}(u,v) + \operatorname{chord}(v,w),$$
the last by Minkowski's inequality applied to the splitting $\hat u - \hat w = (\hat u - \hat v) + (\hat v - \hat w)$. This is what makes cap estimates compose along chains (§9).

---

## 7. The alignment window

The alignment $0.9999$ is an *attained* value; the recorded margin constrains it from the other side.

**Theorem 7.1 (A reading gap forces a chordal separation).** For nonzero $u,v,w$,
$$|\operatorname{corr}(u,w) - \operatorname{corr}(v,w)| \;\le\; \operatorname{chord}(u,v).$$

*Proof.* Normalise $w$; by Theorem 6.2 the map $x\mapsto \operatorname{corr}(x,\hat w)$ is $1$-Lipschitz on the sphere, so evaluating at the unit vectors $\hat u,\hat v$ gives $|\operatorname{corr}(\hat u,\hat w) - \operatorname{corr}(\hat v,\hat w)| \le \|\hat u - \hat v\|$. Correlations are unchanged by normalising either argument. $\square$

**Theorem 7.2 (A margin caps the alignment).** If $\operatorname{corr}(u,w) - \operatorname{corr}(v,w) \ge \delta \ge 0$ then
$$\operatorname{corr}(u,v) \;\le\; 1 - \frac{\delta^2}{2}.$$

*Proof.* Theorem 7.1 gives $\delta \le \operatorname{chord}(u,v)$; square and use Theorem 3.1: $\delta^2 \le 2 - 2\operatorname{corr}(u,v)$. $\square$

**Theorem 7.3 (The (R) alignment window).** Both of the following hold.
1. *(Attainment)* There exist nonzero $u,v,w \in \mathbb{R}^2$ with $\operatorname{corr}(u,w) = 0.558$, $\operatorname{corr}(v,w) = 0.550$ and $\operatorname{corr}(u,v) \ge 0.9999$.
2. *(Ceiling)* For **every** $n$ and all nonzero $u,v,w \in \mathbb{R}^n$ realising those two readings,
$$\operatorname{corr}(u,v) \;\le\; 1 - 3.2\times 10^{-5} \;=\; 0.999968.$$

*Proof.* Part 1 is Configuration (R). Part 2 is Theorem 7.2 with $\delta = 0.008$, since $\delta^2/2 = 3.2\times10^{-5}$. $\square$

So the alignment of the two hypotheses is confined to
$$0.9999 \;\le\; \operatorname{corr}(u,v) \;\le\; 0.999968,$$
a window of width $6.8\times10^{-5}$. Two consequences. First, the recorded configuration is essentially the geometrically extremal one: no cleverer realisation of the two readings buys meaningful extra separation. Second, the ceiling $\sqrt2/100$ cannot be much improved by using the *upper* end of the window instead: at $\operatorname{corr} = 0.999968$ the chord is $\sqrt{6.4\times10^{-5}} = 0.008$ exactly, which is the recorded margin itself. The two ends of the window are $0.008$ and $0.0141$ — the true chord lies between them.

**Corollary 7.4 (The correlation test is already near-optimal).** On Configuration (R) the response-correlation statistic separates the hypotheses by exactly $0.008$, while every $1$-Lipschitz-on-the-sphere statistic is capped at $\sqrt2/100 = 0.014142\ldots$. The recorded test therefore achieves at least $0.008/0.014142 = 56.6\%$ of the theoretical maximum, and no smooth test can improve on it by more than the factor $1.7678$.

---

## 8. The optimal smooth test

Corollary 7.4 leaves a practical question: is there a *specific* statistic realising the optimum, and is it something one can actually compute? The answer is affirmative and pleasingly concrete.

**Lemma 8.1 (The contrast direction is a unit vector).** If $\hat u \neq \hat v$ then $e = e(u,v) = (\hat u - \hat v)/\|\hat u - \hat v\|$ satisfies $\|e\| = 1$.

**Theorem 8.2 (The contrast test attains the chord).** Let $u,v$ be nonzero with $\hat u \ne \hat v$, and let $e = e(u,v)$. Then
$$\operatorname{corr}(\hat u, e) - \operatorname{corr}(\hat v, e) \;=\; \operatorname{chord}(u,v).$$

*Proof.* Since $\hat u, \hat v, e$ are all unit vectors, correlations against $e$ are plain inner products. Hence
$$\operatorname{corr}(\hat u,e) - \operatorname{corr}(\hat v,e) = \langle \hat u - \hat v, e\rangle = \frac{\langle \hat u-\hat v, \hat u - \hat v\rangle}{\|\hat u - \hat v\|} = \frac{\|\hat u - \hat v\|^2}{\|\hat u-\hat v\|} = \|\hat u - \hat v\|. \qquad\square$$

**Theorem 8.3 (The smooth optimum is exactly the chordal distance).** Let $u,v$ be nonzero with $\hat u\neq\hat v$. Then:
1. there is a unit vector $e$ with $|\operatorname{corr}(\hat u,e) - \operatorname{corr}(\hat v,e)| = \operatorname{chord}(u,v)$; and
2. every statistic $F$ that is $1$-Lipschitz on the sphere satisfies $|F(\hat u) - F(\hat v)| \le \operatorname{chord}(u,v)$.

Consequently
$$\sup\bigl\{\,|F(\hat u)-F(\hat v)| \;:\; F \text{ is } 1\text{-Lipschitz on the sphere}\,\bigr\} \;=\; \operatorname{chord}(u,v),$$
and the supremum is a maximum attained by a correlation statistic.

*Proof.* Part 1 is Theorem 8.2 (the quantity is nonnegative, so the absolute value is harmless) together with Lemma 8.1 and Theorem 6.2 confirming that this statistic is indeed in the class. Part 2 is Theorem 4.1 with $L=1$. $\square$

This is the sharpest possible statement of the situation. The class of stable statistics is not merely bounded above by the chord; the chord is *achieved*, and achieved by the most classical object imaginable — a correlation against a fixed direction. The optimal experiment design, given the two hypotheses, is to project onto the difference between them.

**Theorem 8.4 (The optimal smooth test at (R)).** There exist nonzero $u,v,w \in \mathbb{R}^2$ with $\operatorname{corr}(u,w)=0.558$, $\operatorname{corr}(v,w)=0.550$, and a unit vector $e$ such that
$$\operatorname{corr}(\hat u, e) - \operatorname{corr}(\hat v, e) \;=\; \operatorname{chord}(u,v), \qquad 0.008 \;\le\; \operatorname{chord}(u,v) \;\le\; \frac{\sqrt2}{100},$$
and such that no statistic $1$-Lipschitz on the sphere separates $\hat u,\hat v$ by more than $\operatorname{chord}(u,v)$.

*Proof.* Take Configuration (R) and $e = e(u,v)$. The lower bound is Theorem 7.1 applied to the recorded margin; it also certifies $\hat u \ne \hat v$, so $e$ is well defined. The upper bound is Theorem 3.3 with $\varepsilon = 10^{-4}$ and Theorem 3.5. Optimality is Theorem 8.3(2). $\square$

**Theorem 8.5 (The contrast test dominates the recorded test, by at most $1.7678$).** On Configuration (R), with $e$ the contrast direction:
$$|\operatorname{corr}(\hat u,w) - \operatorname{corr}(\hat v,w)| = 0.008 \;\le\; |\operatorname{corr}(\hat u,e) - \operatorname{corr}(\hat v,e)| \;\le\; 1.7678 \cdot 0.008.$$

*Proof.* The equality is the recorded margin. The middle quantity equals $\operatorname{chord}(u,v)$ by Theorem 8.2, and the two inequalities are the two ends of the window of Theorem 8.4, since $1.7678 \times 0.008 = 0.01414\ldots \ge \sqrt2/100$. $\square$

**Reading of Theorem 8.5.** This is the practical payoff and the practical disappointment in one line. There *is* a strictly better smooth test than the one recorded, it is easy to describe, and it is optimal in its class. And it buys at most a factor of $1.77$ on a gap of $0.008$ — never enough to convert an ambiguous reading into a decisive one. Optimising within the smooth class is not where the leverage is.

---

## 9. Cap capacity and Hölder robustness

### 9.1 Chains of hypotheses

Real programmes do not test two hypotheses; they test ladders of them (successive rungs of a dial, successive dose levels, successive model refinements). The chordal triangle inequality makes the cap estimate compose.

**Theorem 9.1 (Chain bound).** Let $f_0, f_1, \dots, f_k$ be nonzero vectors with $\operatorname{corr}(f_i, f_{i+1}) \ge 1-\varepsilon$ for all $i < k$. Then $\operatorname{chord}(f_0, f_k) \le k\sqrt{2\varepsilon}$.

*Proof.* Induction on $k$: the base case is $\operatorname{chord}(f_0,f_0)=0$; the step combines the triangle inequality with Theorem 3.3 on the last link. $\square$

**Corollary 9.2.** If additionally $F$ is $L$-Lipschitz on the sphere with $L \ge 0$, then $|F(\hat f_0) - F(\hat f_k)| \le kL\sqrt{2\varepsilon}$. Eight rungs at (R)-level alignment still give a ceiling below $0.12L$.

### 9.2 Capacity: how many rungs fit in a cap

Turn the chain around: instead of assuming alignment at each link, assume the statistic *gains* at each link and ask how many links are possible.

**Theorem 9.3 (Ladder value growth).** If $F(\hat f_{i+1}) - F(\hat f_i) \ge \delta$ for all $i<k$, then $F(\hat f_k) - F(\hat f_0) \ge k\delta$.

*Proof.* Telescoping sum. $\square$

**Theorem 9.4 (Cap capacity bound).** Let $F$ be $L$-Lipschitz on the sphere with $L \ge 0$, let $f_0,\dots,f_k$ be nonzero with $F(\hat f_{i+1}) - F(\hat f_i) \ge \delta$ for all $i<k$, and suppose the *endpoints* are aligned: $\operatorname{corr}(f_0,f_k) \ge 1-\varepsilon$. Then
$$k\,\delta \;\le\; L\sqrt{2\varepsilon}.$$

*Proof.* Combine Theorem 9.3 with the ceiling Theorem 4.2 applied to the endpoints. $\square$

**Corollary 9.5 (The (R) cap holds at most one resolvable rung).** With $L=1$, $\delta = 0.008$, $\varepsilon = 10^{-4}$: $k \le \sqrt2/100 \div 0.008 = 1.7678$, hence $k \le 1$.

**Theorem 9.6 (One rung is resolvable — the capacity bound is tight).** There exist a statistic $F$ that is $1$-Lipschitz on the sphere and directions $f_0, f_1$, nonzero, with $F(\hat f_1) - F(\hat f_0) \ge 0.008$ and $\operatorname{corr}(f_0,f_1) \ge 0.9999$.

*Proof.* Take $F(x) = \operatorname{corr}(x,\hat w)$ from Configuration (R) — $1$-Lipschitz on the sphere by Theorem 6.2 — and the ladder $f_0 = v$, $f_1 = u$. Then $F(\hat f_1) - F(\hat f_0) = 0.558 - 0.550 = 0.008$ exactly, and the alignment is the recorded one. $\square$

Together, Corollary 9.5 and Theorem 9.6 pin the capacity of the (R) cap at exactly one rung: a stable statistic can distinguish "below the floor" from "above the floor" once, and cannot resolve any finer gradation inside the cap. A programme that reports a monotone ladder of two or more $0.008$-steps, all inside a $0.9999$-alignment cap, is reporting something a stable statistic cannot support.

### 9.3 Hölder statistics

Weakening Lipschitz continuity to Hölder continuity does not remove the obstruction.

**Theorem 9.7 (Hölder ceiling).** Let $C, \alpha \ge 0$ and let $F$ be $(C,\alpha)$-Hölder on the sphere. If $\operatorname{corr}(u,v) \ge 1-\varepsilon$ for nonzero $u,v$, then
$$|F(\hat u) - F(\hat v)| \;\le\; C\bigl(\sqrt{2\varepsilon}\bigr)^{\alpha}.$$

*Proof.* Apply the Hölder hypothesis at $\hat u,\hat v$ and then monotonicity of $r \mapsto r^\alpha$ on $r \ge 0$ together with Theorem 3.3. $\square$

**Theorem 9.8 (Hölder converse).** Under the same hypotheses with $\varepsilon>0$, a separation $\delta$ requires $C \ge \delta/(\sqrt{2\varepsilon})^{\alpha}$.

At $(R)$ with $\alpha = 1/2$, full separation requires $C \ge 1/\sqrt{0.014142} = 8.41$; at $\alpha = 1$ it requires $C \ge 70.71$. Lower exponents buy a milder constant, but only by making the statistic *more* singular at small scales — the modulus of continuity $r\mapsto Cr^\alpha$ with $\alpha<1$ has infinite slope at $0$. The trade-off is genuine, and it always points the same way: resolution inside the cap is purchased with local instability.

---

## 10. Escaping the ceiling: the discontinuous test

**Theorem 10.1 (A threshold statistic fully separates (R)).** On Configuration (R), with $t = 0.554$,
$$\operatorname{Thr}_{w,t}(\hat u) - \operatorname{Thr}_{w,t}(\hat v) \;=\; 1.$$

*Proof.* $\operatorname{corr}(\hat u, w) = \operatorname{corr}(u,w) = 0.558 \ge t$, so the first term is $1$; $\operatorname{corr}(\hat v, w) = 0.550 < t$, so the second is $0$. $\square$

**Theorem 10.2 (The threshold statistic is not $L$-Lipschitz for any $L$).** For every real $L$, the statistic $\operatorname{Thr}_{w,t}$ with $w = (1,0)$ and $t = 0.554$ fails to be $L$-Lipschitz.

*Proof sketch.* Write $s = \sqrt{1-t^2}$ and consider $x = (t, s)$, a unit vector with $\operatorname{corr}(x,w) = t$, so $\operatorname{Thr}_{w,t}(x) = 1$. For small $d>0$ let $y = (t-d, s)$. A short computation shows $\operatorname{corr}(y,w) = (t-d)/\|y\| < t$, because $t^2\|y\|^2 - (t-d)^2 = (1-t^2)\,d\,(2t-d) > 0$ for $0<d<2t$; hence $\operatorname{Thr}_{w,t}(y) = 0$. But $\|x-y\| = d$. Choosing $d < \min\{t/2,\ 1/(2(|L|+1))\}$ makes $L\|x-y\| < 1 = |\operatorname{Thr}_{w,t}(x) - \operatorname{Thr}_{w,t}(y)|$, contradicting the Lipschitz inequality. $\square$

Theorems 10.1 and 10.2 close the circle. The ceiling of §4 is not a statement that the hypotheses are unresolvable; it is a statement that they are unresolvable *by stable statistics*. A rank/threshold rule resolves them perfectly, and it does so by being infinitely sensitive precisely where the resolution happens.

**The methodological dichotomy.**

| | Stable statistics ($L$-Lipschitz on the sphere) | Threshold / rank statistics |
|---|---|---|
| Maximum separation at (R) | $L\sqrt2/100$; $= 0.0141$ at $L=1$ | $1$ |
| Optimal member | correlation against the contrast direction | threshold at $t=0.554$ |
| Sample-size dependence | none | none |
| Effect of $m$-fold replication | none | none |
| Local sensitivity | bounded by $L$ | unbounded |
| Verdict under a $10^{-2}$-degree perturbation | changes by $\le 2\times10^{-4}$ | may flip completely |

Neither column is uniformly better. The left column is what one wants if the predictor itself is measured with error; the right is what one wants if the predictor is exact and the question is genuinely a threshold question. What the analysis forbids is having both.

---

## 11. Algorithms

Three computational procedures follow directly from the theory. All are $O(n)$ in the data dimension apart from the noted exceptions.

**Algorithm A (Cap diagnostic).** *Input:* predictors $u,v$, response $w$. *Output:* alignment $\rho$, chordal radius, angular radius, ceiling at $L$, and the Lipschitz constant needed for full separation.
1. Compute $\rho = \operatorname{corr}(u,v)$ in $O(n)$.
2. Chordal radius $r = \sqrt{2-2\rho}$; angular radius $\theta = \arccos\rho$.
3. Ceiling at sensitivity $L$: $Lr$. Report also the angular form bound $(\pi/2)r$, which certifies $\theta \le (\pi/2)r$.
4. Reading gap $\delta = |\operatorname{corr}(u,w)-\operatorname{corr}(v,w)|$; required constant $L_{\min} = 1/r$ for full separation, and alignment ceiling $1 - \delta^2/2$.

This is a *design-stage* diagnostic: steps 1–3 need only the two hypothesised predictors, not any data collected under them.

**Algorithm B (Optimal smooth test).** *Input:* $u,v$. *Output:* the contrast direction and the optimal separation.
1. Normalise: $\hat u = u/\|u\|$, $\hat v = v/\|v\|$.
2. Difference $d = \hat u - \hat v$; if $\|d\| = 0$ report "hypotheses coincide; no smooth test separates them".
3. Contrast direction $e = d/\|d\|$; report separation $\langle \hat u,e\rangle - \langle \hat v,e\rangle$, which equals $\|d\|$ up to floating-point error.
4. Certify optimality: no $1$-Lipschitz-on-the-sphere statistic exceeds $\|d\|$ (Theorem 8.3).

**Algorithm C (Cap capacity).** *Input:* alignment $\varepsilon$, per-rung gain $\delta$, sensitivity $L$. *Output:* $k_{\max} = \lfloor L\sqrt{2\varepsilon}/\delta\rfloor$, the largest number of rungs of a monotone ladder that a stable statistic can resolve inside the cap, tight by Theorem 9.6 when the bound is an integer that is realisable.

---

## 12. Applications and scope

**Design-stage power screening.** The traditional power calculation asks for the $n$ needed to detect a given effect. Theorem 4.2 answers a logically prior question that no $n$ can override: *given the two hypotheses, is my statistic capable of seeing the difference at all?* Because the alignment $\rho$ between hypothesised predictors is computable before data collection, a programme can be screened for geometric futility in advance. A pre-registration that specifies both a smooth statistic and two hypotheses aligned above $1-\delta^2/2$ is internally inconsistent: it has committed to a test that cannot deliver a margin $\delta$.

**Diagnosing failed replications.** When a near-threshold result fails to sharpen across many replications, the standard explanations are publication bias, heterogeneity, or a genuinely null effect. The present analysis supplies a fourth, testable explanation: the competing hypotheses are geometrically indistinguishable at the resolution of the statistic, and replication is invariant on exactly the quantity that matters (Theorem 5.2). The signature of this explanation is distinctive — the observed separation should sit near a fixed ceiling that does *not* shrink with pooled sample size.

**Choosing among statistics.** Theorem 8.3 makes the trade explicit. Within the smooth class, the best possible test is a projection onto the contrast direction, and its advantage over an arbitrary reasonable smooth test is bounded by the ratio of the chord to that test's separation — at (R), at most $1.7678$. Any hope of a decisive verdict must therefore come from *outside* the smooth class, i.e. from a rank or threshold rule, and the analysis tells the experimenter to accept the accompanying brittleness knowingly rather than by accident.

**Ladder audits.** Corollary 9.5 supplies an internal-consistency check for programmes reporting graded ladders: the number of resolvable rungs inside a cap of alignment $1-\varepsilon$ at per-rung margin $\delta$ is at most $L\sqrt{2\varepsilon}/\delta$. Reports exceeding this count with a stable statistic are, as a matter of geometry, over-reporting.

**Scope and limitations.** The results are deterministic geometry, not distribution theory: they bound the *separation of values* of a statistic between two fixed hypothesis realisations, not the probability of a decision error. Sampling noise, if present, can only widen the overlap, so the ceilings are optimistic — they describe the best case for the experimenter. The framework applies verbatim to any scale-invariant summary (Pearson correlation on centred data, Spearman correlation on rank vectors, cosine similarity), and the Lipschitz hypothesis is required only on the sphere, which is the mildest form under which the conclusion is available. What the framework does *not* cover is statistics that depend on the predictor other than through its direction; for those, the relevant geometry is that of the larger space in which they vary.

---

## 13. Discussion

The result has the shape of an information-theoretic impossibility theorem but none of its machinery: no channel, no entropy, no asymptotics. It is a two-line inequality — Cauchy–Schwarz plus a Lipschitz hypothesis — that turns out to be exactly tight, and whose exact tightness is what makes it useful. The reason it is easy to miss is that it lives in the wrong coordinate system for standard practice. Statistical power is normally parameterised by effect size and sample size, and the quantity that controls it here, the mutual alignment of the hypotheses, is not a parameter of either.

Three features are worth isolating.

*Dimension-freeness is structural, not asymptotic.* The bound does not improve or degrade with $n$; the sample size never enters the derivation. This is a stronger statement than a slow rate. It says the resource that would have to be spent is not of the type that sampling produces.

*Sharpness converts a bound into a design principle.* Because the ceiling is attained (Theorem 6.1) and attained by an implementable statistic (Theorem 8.3), one knows both the maximum available and how to collect it. There is no gap left for a cleverer smooth analysis to exploit — a rare and clarifying situation.

*The escape route is exactly one hypothesis wide.* All of Lipschitz, Hölder, and their chain and ladder consequences fall to the same argument, so the failure of the ceiling for the threshold statistic is not a technicality: continuity is precisely the load-bearing hypothesis. That in turn suggests the correct currency for the escape is total variation rather than sensitivity, which is the subject of the first future direction below.

---

## 14. Future directions

### 14.1 A total-variation floor for discontinuous crossing tests

Escaping the Lipschitz ceiling costs *variation*. A statistic that separates two directions $\delta$ apart in value while they are $\sqrt{2\varepsilon}$ apart in distance must concentrate at least $\delta$ of total variation inside a cap of radius $\sqrt{2\varepsilon}$; the escape is therefore paid for in instability rather than in information. With an exact cap radius and an exact attained separation now in hand, this trade-off can be stated as a sharp inequality rather than a heuristic, and the one-dimensional (great-circle) case is immediately tractable: parameterise a geodesic through the cap and bound the essential variation of the statistic along it from below by the achieved separation.

### 14.2 Cap capacity as a packing invariant

Corollary 9.5 is a shadow of a general packing statement: the number of hypotheses in a correlation cap that an $L$-Lipschitz statistic can pairwise separate by $\delta$ should be bounded by $1 + L\sqrt{2\varepsilon}/\delta$, *independently of the dimension* — even though the cap itself contains exponentially many $\delta/L$-separated directions. The telescoping argument for chains is already available; upgrading from chains to arbitrary finite families requires replacing the linear order by a bound on the diameter of the image, and would exhibit a strict, quantitative separation between metric packing capacity and *statistical* resolving capacity.

### 14.3 Further programme

- **Randomised and noisy statistics.** Extend the ceiling to statistics with an independent noise term, converting the separation bound into a bound on total-variation distance between decision distributions and hence into a genuine power bound.
- **Multi-response caps.** When several responses $w_1,\dots,w_k$ are measured, the hypotheses live in the intersection of several caps; the effective radius should shrink like the radius of the intersection, giving a multi-endpoint design criterion.
- **Optimal discontinuous tests.** Among threshold rules, which cut $t$ maximises robustness — i.e. maximises the distance from the decision boundary to the two hypotheses? For (R) the midpoint $t = 0.554$ is the natural candidate, and a proof that it is optimal would complete the dichotomy of §10.
- **Estimating the alignment from data.** Turning the diagnostic of Algorithm A into an inferential tool requires a confidence interval for $\rho = \operatorname{corr}(u,v)$ when both predictors are estimated; the ceiling then becomes a random variable whose upper confidence limit is the operationally relevant quantity.

---

## 15. Conclusion

Two hypotheses realised by predictor directions correlated at $1-\varepsilon$ sit inside a spherical cap of chordal radius $\sqrt{2\varepsilon}$, and every statistic that is $L$-Lipschitz on the sphere is thereby prevented from separating them by more than $L\sqrt{2\varepsilon}$ — a bound that contains no sample size and is exactly invariant under replication. The bound is sharp, attained by a distance statistic and, within the natural normalisation $L=1$, attained by an ordinary correlation against the contrast direction $(\hat u-\hat v)/\|\hat u-\hat v\|$, which is therefore the optimal smooth test.

For the recorded near-threshold instance — a reading of $0.558$ against a floor of $0.550$, with hypotheses alignable to $0.9999$ — the cap has angular radius $0.81^\circ$, the ceiling for a unit-sensitivity statistic is $0.0141$, full separation would require sensitivity at least $70$, the alignment is pinned in the window $[0.9999,\,0.999968]$, the optimal smooth test improves on the recorded one by at most a factor $1.7678$, and the cap has capacity for exactly one resolvable rung. Meanwhile a discontinuous threshold statistic separates the identical configuration completely, at the price of being Lipschitz for no constant whatsoever.

The practical upshot is a change of question. Not "how many more runs do we need?" — for a stable statistic, the answer is that no number suffices — but "is the statistic we are using geometrically capable of the verdict we want, and if not, are we prepared to pay in brittleness for one that is?"
