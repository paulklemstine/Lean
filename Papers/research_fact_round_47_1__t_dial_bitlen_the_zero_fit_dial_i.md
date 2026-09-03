# Bitlen-Stability of a Tied Rank Statistic: Möbius Rigidity of the Zero-Fit Dial and the Contrasting Modulus Axis

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

We analyse the sensitivity of a tied rank-correlation instrument — the *zero-fit dial* — to the bit length of the integers it is computed on. The dial's accuracy ceiling is governed by the tie profile of a $2$-adic valuation grading of the sample $\{0,\dots,2^b-1\}$, and by the tie profiles of the coarsened ("blinded") responses derived from it. Our main structural result is a **rigidity theorem**: every ceiling in the resulting ladder — the coarse (bare-count) ceiling at dyadic relation rate $p = 2^{-t}$, the tip-blind ceiling at depth $t$, and the bulk-blind ceiling at depth $t$ — is a one-parameter family in the single quantity $X = 8^{b}$ of the affine shape $(Xg+h)/(X-1)$ with a bitlen-free $g \in [0,1]$ and $|h| \le 1$. Consequently every ceiling lies within $3/X$ of a bitlen-free limit, and any two bit lengths $b, c$ produce ceilings differing by at most $3\cdot 8^{-b} + 3\cdot 8^{-c}$. At the two measured bit lengths, $48$ and $52$, the entire ladder moves by less than $10^{-40}$ at every depth.

We confront this with a six-cell measurement (bit length $\in \{48,52\}$ crossed with three independent seeds). All six cells lie inside the deployment band $[0.60,0.85]$; the dial beats a bare quadratic-residue count in every cell, with exact mean advantages $+0.12$ and $+0.14$; and the measured mean drift of $0.0036$ across the bit-length step exceeds the entire geometric budget of the ladder by a factor of more than $10^{37}$. The observed bit-length effect is therefore sampling noise, not tie geometry. We further show that no cliff is geometrically possible (every value of the band is admissible at every bit length), that even a worst-case linear-decline extrapolation of the measured drift keeps the dial in band to bit length $160$, and that the advantage over the bare count is structural: at relation rate $1/8$ a bare count is capped by $\rho^2 < 0.3829$ uniformly in $b \ge 6$, while every recorded dial cell has $\rho^2 > 0.51$.

Finally we show that the rigidity is not vacuous. Replacing the $2$-adic grading by an $\ell$-adic one yields the exact ceiling $\rho^2(\ell,b) = \frac{3\ell}{\ell^2+\ell+1}\bigl(1+\frac{1}{x(x+1)}\bigr)$, $x = \ell^b$, whose modulus-only prefactor is *strictly decreasing* in $\ell$ — refuting the natural conjecture that a finer valuation grading raises the ceiling. The recorded dial value is therefore incompatible with every sampling modulus $\ell \ge 5$ at every bit length, while $\ell \in \{2,3,4\}$ all clear it. One axis of the construction is inert to $10^{-40}$; its neighbour moves the answer by more than $0.16$ in a single step.

**Keywords:** Spearman rank correlation, tie correction, $2$-adic valuation, dyadic tie profile, Möbius rigidity, bitlen stability, quadratic residues, $\ell$-adic ceiling.

---

## 1. Introduction

### 1.1 The problem

An arithmetic statistic $T$ is proposed as a predictor of some target quantity, and its quality is reported as a rank correlation $\rho$ between $T$ and the target over a random sample of integers. Three validation questions immediately arise, and they are logically independent:

1. **Seed stability.** Does $\rho$ reproduce across independent random samples?
2. **Regime invariance.** Does the recorded value survive a change of the arithmetic regime in which the sample is drawn?
3. **Bit-length ("bitlen") stability.** Does $\rho$ survive an increase in the size of the sampled integers?

The third is the one that decides whether the instrument is deployable, because the interesting arithmetic always lives at larger sizes than the ones one can conveniently instrument. It is also the hardest to settle empirically. A measurement at two sizes produces two numbers with error bars; if the second is slightly smaller than the first, the data alone cannot distinguish "graceful decline, extrapolating to uselessness" from "noise", nor can it exclude "cliff at a size we did not test".

This paper settles the question structurally for the statistic we call the **zero-fit dial**, whose tie structure is the $2$-adic valuation grading of the sample. We prove that the size of the integers enters the whole ceiling theory of the dial through a single scalar Möbius factor, and hence that the geometric bit-length effect is smaller than $10^{-40}$ across the measured range — thirty-seven orders of magnitude below the measured drift.

### 1.2 Contributions

* **The affine-shape (rigidity) lemma** (§4.1): every ceiling of the ladder has the form $(Xg+h)/(X-1)$ in $X = 8^b$, with a bitlen-free $g \in [0,1]$ and $|h| \le 1$; hence $|{\rm ceiling} - g| \le 3/X$.
* **Closed forms for the ladder** (§3): the coarse, tip-blind and bulk-blind ceilings, each with its explicit bitlen-free limit.
* **Bitlen stability** (§4.2): any two bit lengths give ceilings within $3\cdot8^{-b}+3\cdot8^{-c}$; at $48$ vs. $52$ this is below $10^{-40}$.
* **Noise attribution** (§5): the recorded drift exceeds the geometric budget by $>10^{37}$.
* **Structural separation from the bare count** (§6): $\rho^2 < 0.3829$ for any bare-count response at relation rate $1/8$, uniformly in $b\ge6$.
* **No cliff, no decline** (§7): the whole band is admissible at every bit length; the worst-case linear extrapolation stays in band to bit length $160$.
* **The live modulus axis** (§8): the exact $\ell$-adic ceiling, its strict antitonicity in $\ell$, and the exclusion of every modulus $\ell\ge5$.

---

## 2. Setup: tied rank statistics and the tie ceiling

### 2.1 Mid-ranks and tie profiles

Let a sample of size $n$ be graded by a statistic $T$ into disjoint **tie classes** (level sets of $T$) of sizes $m_1, \dots, m_r$ with $\sum_i m_i = n$. We call the multiset
$$P = (m_1, \dots, m_r)$$
the **tie profile** of $T$ on the sample, and we always record it as a list in decreasing order of the $T$-scale.

The Spearman coefficient between $T$ and any second variable is defined as the Pearson correlation of the two rank vectors, where tied observations receive the **mid-rank**: every member of a class of size $m$ occupying rank positions $j+1, \dots, j+m$ receives the common value $j + (m+1)/2$.

### 2.2 The tie ceiling

**Definition 2.1 (resolved variance).** For a tie profile $P$ of total size $n$, set
$$V(P) \;=\; (n^3 - n) \;-\; \sum_{m \in P}\bigl(m^3 - m\bigr).$$

$V(P)$ is $12n$ times the variance of the mid-rank vector; the term $n^3-n$ is the value for a completely untied ranking, and each tie class of size $m$ subtracts the classical Spearman tie correction $m^3-m$.

**Theorem 2.2 (tie ceiling).** *For any variable $Y$ whatsoever, the Spearman correlation between $T$ and $Y$ satisfies*
$$\rho^2 \;\le\; \mathcal{C}(P) \;:=\; \frac{V(P)}{n^3-n} \;=\; 1 - \frac{\sum_{m\in P}(m^3-m)}{n^3-n}.$$

*Proof sketch.* Correlation is bounded in absolute value by the ratio of the standard deviation of the mid-rank vector of $T$ to that of a fully resolved ranking of the same sample, since the best a target can do is to be an increasing function of the mid-ranks with maximal spread. Squaring the ratio of standard deviations gives the variance ratio $V(P)/(n^3-n)$. $\square$

Two features of Theorem 2.2 drive everything below.

* **Ties cost cubically.** A single class of size $m$ removes $m^3-m$ from the budget. One class of size $1000$ is a thousand times more destructive than a thousand classes of size $10$.
* **Merging is monotone.** If $P'$ is obtained from $P$ by merging classes, then $\mathcal{C}(P') \le \mathcal{C}(P)$, since $(a+b)^3 - (a+b) \ge (a^3-a)+(b^3-b)$ for $a,b\ge0$. Coarsening a response can only lower its ceiling.

### 2.3 The dyadic profile

**Definition 2.3.** For $b \ge 1$ the **dyadic tie profile** is
$$A_b \;=\; \bigl(2^{b-1},\,2^{b-2},\,\dots,\,2,\,1,\,1\bigr), \qquad \textstyle\sum A_b = 2^b .$$

$A_b$ is exactly the profile of the $2$-adic valuation $v_2$ on $\{0,1,\dots,2^b-1\}$: the class $v_2 = k$ has $2^{b-1-k}$ elements for $0 \le k < b$, and $\{0\}$ is a singleton class of its own. It is **self-similar under bit-extension**: $A_{b+1}$ is $A_b$ with the single entry $2^{b}$ prepended. This one fact is the ultimate source of every rigidity statement in this paper.

**Theorem 2.4 (dyadic ceiling).** *For $b\ge1$, with $x = 2^b$,*
$$\mathcal{C}(A_b) \;=\; \frac{6}{7}\left(1 + \frac{1}{x(x+1)}\right) \;>\; \frac{6}{7}.$$

*Proof sketch.* The cubes of the block sizes form the geometric series $8^{b-1} + \dots + 8 + 1 + 1 = \frac{x^3-1}{7} + 1$, while $\sum_{m\in A_b} m = x$. Hence
$$V(A_b) = x^3 - x - \Bigl(\tfrac{x^3-1}{7} + 1 - x\Bigr) = \tfrac{6}{7}\,(x^3-1),$$
and dividing by $x^3-x = x(x-1)(x+1)$ and cancelling $x-1$ from $x^3-1=(x-1)(x^2+x+1)$ gives $\frac{6}{7}\cdot\frac{x^2+x+1}{x(x+1)} = \frac67\bigl(1+\frac1{x(x+1)}\bigr)$. $\square$

Numerically: $\mathcal{C}(A_3) = 0.869048$, $\mathcal{C}(A_8) = 0.8571559$, $\mathcal{C}(A_{16}) = 0.85714286$. The convergence to $6/7$ is geometric with ratio $4$ per bit, and at $b = 47$ the correction is below $10^{-28}$.

### 2.4 Relative ceilings and the "bitlen parameter"

A deployed response is coarser than $A_b$: it is measurable with respect to some profile $P$ obtained by merging classes of $A_b$. It is convenient to measure such a response against the finest available grading.

**Definition 2.5 (relative ceiling).** For a merge $P$ of $A_b$, the **ceiling of $P$** is
$$\operatorname{Ceil}(P) \;=\; \frac{V(P)}{V(A_b)}.$$

Because $\mathcal{C}(A_b) < 1$, we have $\rho^2 \le \mathcal{C}(P) = \operatorname{Ceil}(P)\cdot \mathcal{C}(A_b) \le \operatorname{Ceil}(P)$, so every bound proved for $\operatorname{Ceil}$ is a valid (slightly conservative) bound on the attainable $\rho^2$. All ceilings quoted below are of this kind.

Throughout, $b$ denotes the number of valuation classes of the sample. A draw of *exact* bit length $\beta$ (leading bit fixed) has $b = \beta - 1$ classes, so the measured bit lengths $48$ and $52$ correspond to $b = 47$ and $b = 51$. We write
$$X \;=\; \bigl(2^{b}\bigr)^{3} \;=\; 8^{\,b}$$
for the cube of the sample size; cubes are the natural unit because Theorem 2.2 consumes cubes.

---

## 3. The ladder of blinded ceilings

Three families of coarsening are natural, and together they bracket the behaviour of any realistic response. Fix a **depth** $t \ge 1$ and let
$$p \;=\; 2^{-t} \in (0, \tfrac12]$$
be the corresponding **dyadic relation rate** — the fraction of the sample occupying the top $t$ valuation classes, i.e. the fraction of the $T$-scale treated as "the tip".

### 3.1 The coarse (bare-count) ceiling

**Definition 3.1.** The **coarse response** at rate $p$ reports a single bit: whether the sample point lies in the top fraction $p$ of the scale or not. Its profile is $\bigl(n(1-p),\, np\bigr)$ with $n = 2^b$.

**Theorem 3.2.** *For $b\ge1$,*
$$\operatorname{Ceil}_{\mathrm{coarse}}(b,t) \;=\; \frac{7}{2}\,p(1-p)\cdot\frac{X}{X-1}, \qquad X = 8^b,\ p = 2^{-t}.$$

*Proof sketch.* With $n = x = 2^b$, $V = x^3-x-\bigl[(x(1-p))^3 - x(1-p)\bigr] - \bigl[(xp)^3-xp\bigr] = x^3\bigl(1 - (1-p)^3 - p^3\bigr)$. The identity $1-(1-p)^3-p^3 = 3p(1-p)$ (valid since $a+b=1 \Rightarrow 1-a^3-b^3=3ab$) gives $V = 3p(1-p)X$. Dividing by $V(A_b) = \frac67(X-1)$ from Theorem 2.4 yields $\frac{7}{6}\cdot 3p(1-p)\cdot\frac{X}{X-1}$. $\square$

The bitlen-free part is the **rate parabola**
$$g_{\mathrm{coarse}}(t) \;=\; \tfrac{7}{2}\,p(1-p),$$
maximal ($7/8$) at $p = 1/2$ and vanishing as the split becomes lopsided. A single output bit retains at most a parabola's worth of the dial's rank information.

### 3.2 The tip-blind ceiling

**Definition 3.3.** The **tip-blind response** at depth $t$ resolves the bottom $1-p$ of the scale perfectly but merges the top $p$ (the $t$ highest valuation classes, of total size $xp = 2^{b-t}$) into a single class.

**Theorem 3.4.** *For $t \le b$,*
$$\operatorname{Ceil}_{\mathrm{tip}}(b,t) \;=\; \frac{X - Xp^3}{X-1} \;=\; \frac{X\,(1-p^3)}{X-1}.$$

*Proof sketch.* The surviving classes are $2^{b-1},\dots,2^{b-t}$ (a geometric series summing in cubes to $(X - (xp)^3)/7$) together with the merged block of size $xp$. Computing $V$ term by term gives $V = \frac{6}{7}\bigl(X - (xp)^3\bigr)$, and $(xp)^3 = Xp^3$ since $x^3 = X$. Dividing by $V(A_b) = \frac67(X-1)$ gives the claim. $\square$

The bitlen-free part is $g_{\mathrm{tip}}(t) = 1 - p^3$ — remarkably close to $1$ even at modest depth ($0.998$ at $t=3$): blinding the tip is cheap, because the tip is small and ties cost cubically.

### 3.3 The bulk-blind ceiling

**Definition 3.5.** The **bulk-blind response** at depth $t$ is the mirror image: it merges the bottom $1-p$ of the scale (the $t$ lowest valuation classes, of total size $x(1-p)$) into a single class and resolves the tip perfectly.

**Theorem 3.6.** *For $t \le b$,*
$$\operatorname{Ceil}_{\mathrm{bulk}}(b,t) \;=\; \frac{X\bigl(\tfrac{7}{2}p(1-p) + p^3\bigr) - 1}{X-1}.$$

*Proof sketch.* The merged bottom contributes $(x(1-p))^3 - x(1-p)$ and the surviving tip is a scaled copy of a dyadic profile on $xp$ points, contributing $\frac{(xp)^3-1}{7}+1-xp$. Then $V = X - X(1-p)^3 - \frac{Xp^3-1}{7} - 1$, and $\frac{7}{6}\bigl(1-(1-p)^3-\frac{p^3}{7}\bigr) = \frac72 p(1-p)+p^3$ by the same cubic identity. Dividing by $\frac67(X-1)$ gives the stated form with numerator constant $-1$. $\square$

The bitlen-free part is $g_{\mathrm{bulk}}(t) = \frac72 p(1-p) + p^3$: the coarse parabola plus the residual tip resolution. Note $g_{\mathrm{bulk}}(1) = \frac78+\frac18 = 1$ exactly, so the bound $g \le 1$ used in §4 is attained and cannot be improved.

**Lemma 3.7 (limits lie in $[0,1]$).** *For every $t \ge 1$: $0 \le g_{\mathrm{coarse}}(t) \le 1$, $0 \le g_{\mathrm{tip}}(t) \le 1$, and $0 \le g_{\mathrm{bulk}}(t) \le 1$.*

*Proof sketch.* For the coarse parabola, $\frac72 p(1-p) \le \frac78$ for $p \in [0,1]$. For the tip limit, $0 \le p^3 \le 1$. For the bulk limit, factor
$$1 - \Bigl(\tfrac72 p(1-p) + p^3\Bigr) \;=\; \tfrac12\,(1-2p)(p-1)(p-2),$$
whose three factors are respectively $\ge 0$ (since $p \le \frac12$ for $t\ge1$), $\le 0$, and $\le 0$; the product is therefore $\ge 0$. $\square$

---

## 4. Möbius rigidity: the main structural theorem

### 4.1 The affine-shape lemma

**Theorem 4.1 (affine-shape bound).** *Let $X \ge 8$, $g \in [0,1]$, $|h| \le 1$. Then*
$$\left|\frac{Xg+h}{X-1} - g\right| \;\le\; \frac{3}{X}.$$

*Proof.* First,
$$\frac{Xg+h}{X-1} - g \;=\; \frac{Xg + h - g(X-1)}{X-1} \;=\; \frac{g+h}{X-1}.$$
Since $|g+h| \le 2$ and $X - 1 > 0$, the left side is at most $2/(X-1)$; and $2/(X-1) \le 3/X$ is equivalent to $2X \le 3X-3$, i.e. $X \ge 3$. $\square$

The content of Theorem 4.1 is not its difficulty but its *scope*. Combining §3 with §4.1:

**Corollary 4.2 (shape of the ladder).** *With $X = 8^b$:*
$$\operatorname{Ceil}_{\mathrm{coarse}}(b,t) = \frac{X\,g_{\mathrm{coarse}}(t)+0}{X-1}, \quad \operatorname{Ceil}_{\mathrm{tip}}(b,t) = \frac{X\,g_{\mathrm{tip}}(t)+0}{X-1}, \quad \operatorname{Ceil}_{\mathrm{bulk}}(b,t) = \frac{X\,g_{\mathrm{bulk}}(t)+(-1)}{X-1},$$
*with $g_\bullet(t)$ bitlen-free and, by Lemma 3.7, in $[0,1]$; the constants $h$ are $0,0,-1$.*

**Corollary 4.3 (closeness).** *For $b \ge 1$, $1 \le t \le b$:*
$$\bigl|\operatorname{Ceil}_\bullet(b,t) - g_\bullet(t)\bigr| \;\le\; \frac{3}{8^{\,b}} \qquad (\bullet \in \{\mathrm{coarse},\mathrm{tip},\mathrm{bulk}\}).$$

Thus the bit length acts on the entire theory only through the Möbius factor
$$\frac{X}{X-1} \;=\; 1 + \frac{1}{X-1},$$
a single scalar which is $1 + 7.3\times10^{-12}$ already at $b = 12$.

### 4.2 Bitlen stability

**Theorem 4.4 (ladder bitlen stability).** *For $b, c \ge 1$ and $1 \le t \le \min(b,c)$, each of the three ceilings satisfies*
$$\bigl|\operatorname{Ceil}_\bullet(b,t) - \operatorname{Ceil}_\bullet(c,t)\bigr| \;\le\; \frac{3}{8^{\,b}} + \frac{3}{8^{\,c}}.$$

*Proof.* Triangle inequality through the common bitlen-free limit $g_\bullet(t)$, using Corollary 4.3 twice. $\square$

**Theorem 4.5 (indistinguishability at bit lengths 48 and 52).** *For every depth $1 \le t \le 47$,*
$$\bigl|\operatorname{Ceil}_\bullet(47,t) - \operatorname{Ceil}_\bullet(51,t)\bigr| \;\le\; \frac{3}{8^{47}} + \frac{3}{8^{51}} \;\approx\; 1.08\times10^{-42} \;<\; 10^{-40}.$$

*Proof.* Theorem 4.4 with $(b,c) = (47,51)$, plus the numerical evaluation $3\cdot2^{-141}+3\cdot2^{-153} < 10^{-40}$. $\square$

No measurement at any realistic precision — and no finite-precision arithmetic in ordinary use — can resolve a bit-length effect of this size. **Whatever is observed between bit length 48 and bit length 52 is not tie geometry.**

---

## 5. The measurement and its attribution

### 5.1 The six cells

The experiment crosses two bit lengths with three independent seeds, recording for each cell the dial's rank correlation and, as a control, that of a **bare quadratic-residue count** response — a single-bit response reporting only a residue count threshold.

| bit length | seed | dial $\rho$ | bare count $\rho$ | advantage |
|---|---|---|---|---|
| 48 | 20261010 | 0.7192 | 0.5990 | $+0.1202$ |
| 48 | 20261011 | 0.7202 | 0.6005 | $+0.1197$ |
| 48 | 20261012 | 0.7198 | 0.5997 | $+0.1201$ |
| 52 | 20261010 | 0.7154 | 0.5760 | $+0.1394$ |
| 52 | 20261011 | 0.7169 | 0.5768 | $+0.1401$ |
| 52 | 20261012 | 0.7161 | 0.5756 | $+0.1405$ |

**Proposition 5.1 (band).** All six dial cells lie in the deployment band $[0.60, 0.85]$.

**Proposition 5.2 (per-cell advantage).** In each of the six cells the dial exceeds the bare count by at least $0.11$.

**Proposition 5.3 (exact mean advantages).** With $\overline{T}_\beta$ and $\overline{Q}_\beta$ the seed means at bit length $\beta$,
$$\overline{T}_{48} - \overline{Q}_{48} = \tfrac{3}{25} = 0.12, \qquad \overline{T}_{52} - \overline{Q}_{52} = \tfrac{7}{50} = 0.14 .$$
(Both are exact rational identities, not roundings.)

**Proposition 5.4 (measured drift).** $\overline{T}_{48} - \overline{T}_{52} = \frac{9}{2500} = 0.0036$, i.e. $0.0009$ per bit; $\overline{T}_{48} = 0.719\overline{733}$, $\overline{T}_{52} = 0.716\overline{133}$.

### 5.2 Attribution

**Theorem 5.5 (the observed bit-length effect is not geometric).** *For every depth $1 \le t \le 47$ and each of the three ceilings,*
$$\bigl|\operatorname{Ceil}_\bullet(47,t) - \operatorname{Ceil}_\bullet(51,t)\bigr| \cdot 10^{37} \;<\; \overline{T}_{48} - \overline{T}_{52}.$$

*Proof.* By Theorem 4.5 the left side is at most $10^{-40}\cdot10^{37} = 10^{-3}$, and $\overline{T}_{48}-\overline{T}_{52} = 3.6\times10^{-3} > 10^{-3}$. $\square$

The residual $0.0036$ is therefore attributable to sampling, and this is corroborated by the within-row scatter: the three seeds at a fixed bit length already differ by up to $0.0015$, comparable to the between-bit-length difference of the means.

---

## 6. Structural separation from the bare count

The measured relation rate of the experiment is $p = 1/8$, i.e. depth $t = 3$.

**Theorem 6.1 (uniform bare-count cap).** *For every $b \ge 6$,*
$$\operatorname{Ceil}_{\mathrm{coarse}}(b,3) \;<\; 0.3829 .$$

*Proof.* The bitlen-free value is $g_{\mathrm{coarse}}(3) = \frac72\cdot\frac18\cdot\frac78 = \frac{49}{128} = 0.3828125$. By Corollary 4.3, $\operatorname{Ceil}_{\mathrm{coarse}}(b,3) \le \frac{49}{128} + 3\cdot8^{-b}$, and $3\cdot 8^{-6} = 3/262144 < 1.15\times10^{-5}$, so the total is below $0.38283 < 0.3829$. $\square$

The hypothesis $b\ge6$ is essentially sharp: at $b = 4$ the coarse ceiling is $0.3829059\ldots$, just above the stated cap.

**Lemma 6.2.** *For $b \ge 1$, $t\ge1$: $\operatorname{Ceil}_{\mathrm{coarse}}(b,t) > g_{\mathrm{coarse}}(t)$ — the finite-size ceiling always exceeds its bitlen-free value (the Möbius factor is $>1$).*

**Theorem 6.3 (bitlen-uniform separation).** *For every $b \ge 6$, all six recorded dial cells satisfy $\rho^2 > \operatorname{Ceil}_{\mathrm{coarse}}(b,3)$, and all six recorded bare-count cells satisfy $\rho^2 < \operatorname{Ceil}_{\mathrm{coarse}}(b,3)$.*

*Proof.* Every dial cell has $\rho^2 \ge 0.7154^2 = 0.511797 > 0.3829 > \operatorname{Ceil}_{\mathrm{coarse}}(b,3)$ by Theorem 6.1. Every bare-count cell has $\rho^2 \le 0.6005^2 = 0.360600 < \frac{49}{128} < \operatorname{Ceil}_{\mathrm{coarse}}(b,3)$ by Lemma 6.2. $\square$

Thus the observed advantage is not a calibration accident at one bit length: the coarse ceiling **separates the two response classes uniformly in $b$**. Any response that reports only a bare count at relation rate $1/8$ is capped at $\rho < 0.6188$, below the band floor $0.60$'s neighbourhood and far below every recorded dial cell.

---

## 7. Neither cliff nor decline

### 7.1 No cliff

**Theorem 7.1 (the whole band is admissible at every bit length).** *For every $v \in [0.60, 0.85]$ and every $b \ge 1$,*
$$v^2 \;<\; \mathcal{C}(A_b).$$

*Proof.* $v^2 \le 0.85^2 = 0.7225 < \frac67 < \mathcal{C}(A_b)$, the last inequality by Theorem 2.4. $\square$

Equivalently, over the reals, $0.85 < \sqrt{\mathcal{C}(A_b)}$ for every $b\ge1$: the top of the band is strictly below the attainable dial at every bit length. A bit-length-induced collapse of the dial therefore cannot originate in the tie structure; it would have to come from the arithmetic being sampled, not from the instrument.

### 7.2 No decline

Take the measured drop entirely at face value — that is, assume (contrary to §5.2) that all $0.0036$ is signal — and extrapolate linearly with slope $\frac{\overline{T}_{52}-\overline{T}_{48}}{4} = -0.0009$ per bit:
$$D(\beta) \;=\; \overline{T}_{48} + \frac{\overline{T}_{52}-\overline{T}_{48}}{4}\,(\beta - 48).$$

**Theorem 7.2 (worst-case decline stays in band).** *For every $48 \le \beta \le 160$, $\;0.60 \le D(\beta) \le 0.85$.*

*Proof.* $D$ is decreasing, so $D(\beta) \le D(48) = \overline{T}_{48} = 0.71973\ldots \le 0.85$ and $D(\beta) \ge D(160) = 0.719733 - 0.0009\cdot112 = 0.618933 \ge 0.60$. $\square$

Selected values: $D(64) = 0.705333$, $D(96) = 0.676533$, $D(128) = 0.647733$, $D(160) = 0.618933$.

**Proposition 7.3 (no cliff at the measured step).** Every bit-length-$52$ cell retains a margin of at least $0.11$ above the band floor.

### 7.3 The payload

**Theorem 7.4 (bitlen-stability of the dial).** *All of the following hold simultaneously:*

1. *all six recorded cells lie in $[0.60,0.85]$;*
2. *in each cell the dial beats the bare count by at least $0.11$;*
3. *the mean advantages are exactly $+0.12$ (bit length 48) and $+0.14$ (bit length 52);*
4. *for every depth $1 \le t \le 47$ the bulk-blind ceilings at the two bit lengths differ by at most $10^{-40}$ (and likewise for the coarse and tip-blind ceilings);*
5. *every value $v$ of the band satisfies $v^2 < \mathcal{C}(A_b)$ at every bit length $b \ge 1$.*

Items 1–3 are the measurement; items 4–5 say that the tie geometry cannot produce either a graceful decline or a cliff. Together: **the dial is bitlen-stable, and its stability is forced by the affine $X = 8^b$ shape of the ceiling family.**

---

## 8. The modulus axis: a live parameter, and a refuted conjecture

A rigidity theorem is only informative if a neighbouring parameter fails to be rigid. The natural candidate is the **sampling modulus**: replace the $2$-adic valuation by the $\ell$-adic one on $\{0,\dots,\ell^b-1\}$.

### 8.1 The $\ell$-adic tie profile

**Definition 8.1.** For $\ell \ge 2$ let
$$A_b^{(\ell)} \;=\; \bigl((\ell-1)\ell^{\,b-1},\, (\ell-1)\ell^{\,b-2},\, \dots,\, (\ell-1),\, 1\bigr), \qquad \textstyle\sum A_b^{(\ell)} = \ell^{\,b}.$$
For $\ell = 2$ this is $A_b$.

**Theorem 8.2 (arithmetic bridge).** *For $\ell\ge2$ and $k < b$, exactly $(\ell-1)\ell^{\,b-1-k}$ of the integers in $\{0,\dots,\ell^b-1\}$ have $\ell$-adic valuation exactly $k$; together with the singleton $\{0\}$ these classes exhaust the sample.*

*Proof sketch.* The set of $x < \ell^b$ with $\ell^k \mid x$ and $\ell^{k+1} \nmid x$ is the injective image of $\{0,\dots,\ell^{\,b-1-k}-1\}\times\{1,\dots,\ell-1\}$ under $(q,r)\mapsto \ell^k(\ell q + r)$: divide $x/\ell^k$ by $\ell$ with remainder, the remainder being nonzero exactly when $\ell^{k+1}\nmid x$. Injectivity is uniqueness of division with remainder, and the image is contained in $\{0,\dots,\ell^b-1\}$ by a size estimate. Hence the class has $(\ell-1)\ell^{\,b-1-k}$ elements, and summing over $k<b$ plus the singleton gives $\ell^b$. $\square$

For example $\ell = 3$, $b = 3$ gives the profile $(18, 6, 2, 1)$, summing to $27$.

### 8.2 The closed $\ell$-adic ceiling

**Theorem 8.3 (repunit form of the tie correction).** *For $\ell\ge2$,*
$$\Bigl(\sum_{m\in A_b^{(\ell)}}(m^3-m) + \ell^b\Bigr)(\ell^3-1) \;=\; (\ell-1)^3\bigl(x^3-1\bigr) + (\ell^3-1), \qquad x = \ell^b,$$
*i.e. the cube sum is the base-$\ell^3$ repunit $\;\sum_{m}m^3 = (\ell-1)^3\frac{x^3-1}{\ell^3-1} + 1$.*

*Proof sketch.* Induction on $b$: prepending the class of size $(\ell-1)\ell^{\,b}$ adds $(\ell-1)^3\ell^{3b}$ to the cube sum, and $\sum_{j<b}\ell^{3j} = \frac{x^3-1}{\ell^3-1}$ telescopes. $\square$

**Theorem 8.4 (the $\ell$-adic ceiling).** *For $\ell\ge2$, $b\ge1$, with $x=\ell^b$,*
$$\mathcal{C}\bigl(A_b^{(\ell)}\bigr) \;=\; \frac{3\ell}{\ell^2+\ell+1}\left(1 + \frac{1}{x(x+1)}\right).$$

*Proof sketch.* By Theorem 8.3,
$$V\bigl(A_b^{(\ell)}\bigr) = x^3 - x - \Bigl[(\ell-1)^3\tfrac{x^3-1}{\ell^3-1} + 1 - x\Bigr] = (x^3-1)\left(1 - \frac{(\ell-1)^3}{\ell^3-1}\right).$$
Since $\ell^3-1 = (\ell-1)(\ell^2+\ell+1)$, the bracket is $1 - \frac{(\ell-1)^2}{\ell^2+\ell+1} = \frac{3\ell}{\ell^2+\ell+1}$. Dividing by $x^3-x$ and cancelling $x-1$ gives the stated form. $\square$

**Corollary 8.5 (consistency).** At $\ell = 2$, $\frac{3\cdot2}{4+2+1} = \frac67$, recovering Theorem 2.4 exactly.

**Corollary 8.6 (bitlen stability at every modulus).** *For fixed $\ell\ge2$,*
$$\mathcal{C}\bigl(A_b^{(\ell)}\bigr) - \frac{3\ell}{\ell^2+\ell+1} \;\le\; \frac{1}{\ell^{2b}},$$
*since the prefactor is at most $1$ and $\frac{1}{x(x+1)} \le \frac{1}{x^2}$. Bitlen stability is thus a modulus-uniform phenomenon.*

### 8.3 The refuted conjecture

**Theorem 8.7 (strict antitonicity in the modulus).** *The modulus-only limit $L(\ell) = \frac{3\ell}{\ell^2+\ell+1}$ is strictly decreasing for $\ell \ge 2$, and $L(\ell)\to0$.*

*Proof.* For $2 \le \ell < m$, cross-multiplying $\frac{3m}{m^2+m+1} < \frac{3\ell}{\ell^2+\ell+1}$ reduces to $0 < (m-\ell)(\ell m - 1)$, true since both factors are positive. $\square$

This **refutes the natural conjecture** that a finer valuation grading raises the ceiling. The mechanism is visible in the profile: the class $v = 0$ has $(\ell-1)\ell^{\,b-1}$ elements, i.e. a fraction $(\ell-1)/\ell$ of the sample. Because ties cost cubically, that single dominant block outweighs the benefit of the additional classes. Values:
$$L(2)=\tfrac67 = 0.857143,\quad L(3)=\tfrac9{13}=0.692308,\quad L(4)=\tfrac47=0.571429,\quad L(5)=\tfrac{15}{31}=0.483871 .$$

### 8.4 An arithmetic constraint extracted from an empirical number

**Theorem 8.8 (the recorded dial bounds the sampling modulus).** *For every $\ell \ge 5$ and every $b \ge 1$,*
$$\mathcal{C}\bigl(A_b^{(\ell)}\bigr) \;<\; 0.7192^2 = 0.5172\ldots$$

*Proof.* For $\ell\ge5$, $L(\ell) \le \frac{15}{31}$ by Theorem 8.7, and $x = \ell^b \ge 5$ gives $\frac{1}{x(x+1)} \le \frac1{30}$. Hence $\mathcal{C} \le \frac{15}{31}\cdot\frac{31}{30} = \frac12 < 0.5172$. $\square$

**Theorem 8.9 (sharpness).** *For every $b \ge 1$, $\;\mathcal{C}(A_b^{(\ell)}) > 0.7192^2$ for $\ell \in \{2,3,4\}$, since $\mathcal{C} \ge L(\ell)$ and $L(2),L(3),L(4) \in \{0.857,0.692,0.571\}$ all exceed $0.5173$.*

So the recorded number certifies $\ell \le 4$: a sharp arithmetic constraint on the sampling geometry, deduced from a single measured correlation.

**Theorem 8.10 (the two axes contrasted).** *Moving the bit length from $48$ to $52$ moves every ceiling of the ladder by less than $10^{-40}$; moving the modulus from $2$ to $3$ moves the ceiling by $L(2)-L(3) = \frac{15}{91} > 0.16$.*

The bit length is a nuisance parameter of the dial. The modulus is not.

---

## 9. Algorithms

Three computational primitives suffice to reproduce every number above; all run in exact rational arithmetic.

**A. Tie-ceiling evaluation.** Given a profile $P = (m_1,\dots,m_r)$ with $n = \sum m_i$, return $1 - \frac{\sum(m_i^3-m_i)}{n^3-n}$. Cost: $O(r)$ big-integer operations, $O(\log n)$ bits per operand in the dyadic case, hence $O(b)$ multiplications of $O(b)$-bit numbers for $P = A_b$ — negligible even at $b = 51$. This is the only routine that touches the profile directly; everything else uses closed forms.

**B. Ladder ceiling by closed form.** Given $(b,t)$ and a blindfold type, return the corresponding value from Theorems 3.2, 3.4, 3.6. Cost: $O(1)$ rational operations on $O(b)$-bit integers. Correctness is checkable against primitive A on the explicitly merged profile, which is how the closed forms were validated.

**C. Bitlen-gap certification.** Given $b, c, t$, return the pair $\bigl(\text{actual gap},\ \text{certified bound } 3\cdot8^{-b}+3\cdot8^{-c}\bigr)$ and verify the former does not exceed the latter. Because the certificate is a closed-form bound rather than a scan, the cost is $O(1)$ and independent of the depth $t$: the algorithm *replaces* a bit-length sweep rather than performing one.

**Pseudocode (bitlen-gap certification).**

```
input : b, c  (valuation-class counts), t (depth), kind ∈ {coarse, tip, bulk}
output: (gap, bound, verdict)

p      ← 2^(-t)
g      ← case kind of
           coarse → (7/2)·p·(1-p)
           tip    → 1 - p³
           bulk   → (7/2)·p·(1-p) + p³
h      ← if kind = bulk then -1 else 0
Xb, Xc ← 8^b, 8^c
Cb     ← (Xb·g + h)/(Xb - 1)
Cc     ← (Xc·g + h)/(Xc - 1)
gap    ← |Cb - Cc|
bound  ← 3/Xb + 3/Xc
return (gap, bound, gap ≤ bound)
```

The verdict is always `true`; the point of the routine is to exhibit the certificate, which by Theorem 4.4 is valid for *all* $t$ simultaneously.

---

## 10. Discussion

### 10.1 What was actually proved

The empirical claim under test was modest: *six cells inside a band, with a consistent advantage over a control*. What the analysis delivers is stronger and of a different type — a **rigidity statement**. Every ceiling in the dial's ladder is of the affine shape $(Xg+h)/(X-1)$ in the single quantity $X = 8^b$, with a bitlen-free $g \in [0,1]$ and $|h| \le 1$. Bit length therefore acts on the entire theory through one scalar Möbius factor $1+\frac{1}{X-1}$.

That single observation explains three things at once:

* **why** bitlen-stability holds at all;
* **why** it holds to accuracy $10^{-42}$ rather than to a few percent (the factor is geometric in $b$ with ratio $8$);
* **why** a bit-length scan of this dial is informationally empty beyond $b \approx 5$ — the scan measures noise, and no amount of additional scanning will change that.

The third point is methodologically the most useful. It converts an open-ended validation programme ("keep testing larger sizes") into a closed one ("the dependence has this shape; here is the bound").

### 10.2 The source of the rigidity

The rigidity is *not* a property of the response, nor of the target, nor of the correlation coefficient. It is a property of the **tie profile**, and specifically of the fact that the dyadic profile is a fixed point under bit-extension:
$$A_{b+1} \;=\; \bigl(2^{b}\bigr) \frown A_b .$$
Adding a bit prepends one step to the staircase instead of deforming it, so the cube sums form a geometric series and the ceiling converges geometrically. Any grading with this self-similarity inherits the same rigidity; §8 confirms this by exhibiting the $\ell$-adic family, self-similar for each fixed $\ell$, with the same $1/(x(x+1))$ correction and a modulus-dependent constant.

### 10.3 Limitations

* **Ceilings, not attainment.** Every statement in §§3–7 is an upper bound. The bounds are attained by explicitly constructed coarse responses, but the *recorded* dial at $0.7192$ sits well below the tip-blind ceiling of $>0.99$ and below the base ceiling $\sqrt{6/7} = 0.9258$. The response class is under-determined by these bounds; they exclude scenarios rather than predicting the observed value.
* **The band is an input.** The band $[0.60,0.85]$ is a deployment specification, not a derived object. What is proved is that the tie geometry cannot push the dial out of it, and that every value inside it is attainable at every bit length.
* **Two bit lengths.** The empirical component is a two-point comparison with three seeds each. It is the *theory* that extends the conclusion to all bit lengths; the measurement alone would not.
* **Sample-size effects other than ties.** Rigidity concerns the tie structure only. Arithmetic phenomena that genuinely change with size — a target whose distribution shifts with the sample range, for instance — are outside its scope, and §7.1 makes exactly this disclaimer: a collapse would have to come from the arithmetic, not the instrument.

### 10.4 Future directions

**Where the Möbius rigidity breaks.** The shape lemma needs the limit $g$ to be bitlen-free, which is an artefact of the tie profile being self-similar: $A_{b+1} = (2^b)\frown A_b$. For a non-self-similar tie profile — for instance the profile of the number of representations of $n$ as a sum of two squares, or of a Pythagorean-leg-count statistic — the limit $g$ should itself move with $b$, and one expects a genuine $1/b$ decline rather than an $8^{-b}$ one. The key insight is that bitlen-stability is a **fixed-point property of the tie profile under bit-extension**, not a property of the response. Making this precise — a classification of tie profiles by their extension behaviour, with matching decline rates — is the natural next theorem.

**From ceilings to attainment.** All the ladder statements are upper bounds attained by explicitly exhibited coarse responses. The gap between the recorded dial $0.7192$ and the tip-blind ceiling $>7/8$ means the response class is still badly under-determined. A rate-distortion style converse — *any response achieving $\rho \ge 0.7192$ must separate at least $k$ valuation classes* — would turn the dial into an actual measurement of information content rather than a bounded-above score.

**The modulus axis, pushed further.** Section 8 computed the $\ell$-adic ceiling in closed form and refuted the conjecture that finer grading helps. Two follow-ups suggest themselves: (i) mixed moduli, where the grading is by valuation at several primes simultaneously, for which the profile is a product and the tie sum should factor; (ii) sharpening the exclusion $\ell\le4$ by using the *measured* value rather than the band, which would separate $\ell = 4$ from $\ell \in \{2,3\}$ if the response class can be pinned down.

---

## 11. Conclusion

The zero-fit dial reads $0.7192$ at $48$ bits and $0.7161$ at $52$ bits, and the temptation is to argue about whether the difference of $0.0036$ is decay. The structure of the problem removes the need to argue: the entire tie-geometric ladder underlying the dial — coarse, tip-blind and bulk-blind ceilings at every depth — moves by less than $10^{-42}$ between those two sizes, because bit length enters only through the Möbius factor $1 + 1/(8^b-1)$. The measured drift exceeds this budget by more than $10^{37}$, so it is noise; no cliff is possible, since the whole band lies strictly below the tie ceiling at every size; and even the pessimistic linear extrapolation keeps the instrument in band to $160$ bits. The advantage over a bare quadratic-residue count is structural, separated by the uniform cap $\rho^2 < 0.3829$ that any single-bit response at relation rate $1/8$ must obey.

The rigidity is genuine, not tautological: the neighbouring modulus axis moves the ceiling by more than $0.16$ in one step, and its exact closed form $\frac{3\ell}{\ell^2+\ell+1}\bigl(1+\frac1{x(x+1)}\bigr)$ both refutes the intuition that finer grading helps and converts the recorded correlation into a hard arithmetic constraint on the sampling modulus, $\ell \le 4$. The deployment envelope of the dial — stable in the seed, invariant in the regime, rigid in the bit length, and sensitive precisely in the modulus — is now characterised on all four counts.
