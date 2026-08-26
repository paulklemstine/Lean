# Composition, Not Position: Exact Accounting for a Left-Edge Excess in a Quadratic-Residue Search Window

**Author:** Aristotle
**Date:** 2026-08-26
**Domain:** Probability

---

## Abstract

A large stratified search records, for each modulus $N$, the residues $v = j^2 - N$ at positions $j$ ranging over the window $W(N) = [\lfloor\sqrt N\rfloor + 1,\ 3\lfloor\sqrt N\rfloor]$. Pooling $9594$ hits over $128$ moduli of size below $2^{96}$, the leading tenth of the window ("first decile", $D_1$) carries an excess of $604.76$ hits against a flat, size-blind null: a pooled rate ratio of $1.637$, with a two-component mixture fit reporting $\Delta\mathrm{AICc} = 49.78$ against a pre-registered decision bar of $6$. The natural interpretation is a *positional kernel*: a location-dependent elevation of the hit rate near the left edge of the window.

We prove that no positional component is required, and that none can be inferred from the reported statistics. Four independent results account for the profile in full.

1. **Inclusion geometry.** For every first-decile position, $25\,v \le 11\,(\lfloor\sqrt N\rfloor)^2 \le 11 N$ — exact integer arithmetic, sharp, and scale-carrying. For $N < 2^{96}$ this forces $v < 2^{95}$: the first decile is a *pure tiny-$v$ stratum*, and the observed count of $0$ first-decile hits with $\mathrm{bitlen}(v) \ge 96$ is a theorem, not an observation.

2. **Exact degeneracy and the quantile identity.** At fixed $N$ the residue is a strictly increasing, explicitly invertible function of the position, so every positional weight is realised by a magnitude weight and conversely. The empirical quantile function of the residue on the window is the closed form $\#\{j \in W(N): v \le x\} = \min(3\lfloor\sqrt N\rfloor, \lfloor\sqrt{N+x}\rfloor) - \lfloor\sqrt N\rfloor$; on the divisible moduli $N = (5m)^2$ the first-decile predicate is *equivalent* to $v \le 11m^2$. The rescaled residue obeys the limit law $F(y) = (\sqrt{1+y}-1)/2$ on $[0,8]$ with Kolmogorov error at most $1/(2M)$, and at the decile level $y = 11/25$ the limiting value $1/10$ is attained exactly.

3. **Composition accounting.** The flat-referenced excess splits exactly as $\text{flat excess} = \text{band excess} + \text{composition}$. Under size matching the whole excess is composition; under band homogeneity the composition term vanishes. The pooled rate ratio factorises as (matched ratio) $\times$ (composition factor), and $1.097 \times 1.4924 = 1.637$ to four decimals. Extremally, the composition factor lies in $[p_{\min}/p_0, p_{\max}/p_0]$ for any exposure allocation, giving a universal ceiling of $1.638$ on the pooled ratio at the reported inputs; conversely, at least $77\%$ of the observed excess is provably composition.

4. **Pooled versus stratified evidence, and truncation gradients.** Pooled $\Delta\mathrm{AICc}$ is bounded by the sum of stratum $\Delta\mathrm{AICc}$s plus a null misspecification gap $G \ge 0$ plus a penalty defect. With strata at $5.94$ and $-0.40$ and a defect at most $3$, the reported pooled $49.78$ forces $G \ge 41.2$. The residual $[96,98)$ signal is precisely what a monotone size density produces at a truncation boundary: a nonincreasing density always yields nonnegative apparent edge excess, a flat density yields exactly zero, and a geometric density of ratio $r$ yields relative edge excess $(1-r^m)/(1+r^m) \le m(1-r)$.

We also calibrate the control arm: a maximal $|z|$ of $2.53$ over $128$ strata gives a multiplicity-corrected bound exceeding $1$, so "controls clean" means the absence of an exceedance and not confirmation of the null. What survives the analysis is that the overdispersion itself is real ($+605$ hits with a named origin), that the mechanical degeneracy is load-bearing rather than incidental, and that both surviving mechanisms are scale-carrying.

**Keywords:** stratified sampling, Simpson's paradox, composition bias, quadratic residues, integer square root, quantile identity, model selection, AICc, truncation bias, multiplicity correction.

---

## 1. Introduction

### 1.1 The design

Fix a modulus $N \in \mathbb{N}$ and write $s = s(N) = \lfloor\sqrt N\rfloor$ for its integer square root. A sieve-type search enumerates positions

$$j \in W(N) := \bigl[\, s+1,\ 3s \,\bigr] \cap \mathbb{Z},$$

and at each position records the **residue**

$$v(N,j) := j^2 - N \in \mathbb{N}.$$

A subset of the positions register as *hits*, according to an arithmetic criterion whose details are irrelevant here. The design pools hits across $128$ moduli, all below $2^{96}$, yielding $9594$ pooled hits, against $512{,}000$ control runs.

The window has $2s$ positions. Its **first decile** $D_1$ is the leading tenth,

$$D_1(N) := \{\, j \in W(N)\ :\ 10\,(j - s) \le 2s \,\} = \{\, j \in W(N)\ :\ 5j \le 6s \,\}.$$

### 1.2 The observation, and the tempting reading

Against a flat null that assigns probability $1/10$ of a hit falling in $D_1$, the pooled data show an excess of

$$+604.76 \ \text{hits}, \qquad \text{pooled rate ratio } 1.637 .$$

Fitting a two-component mixture — a background plus a component supported near the left edge — to the *kept* sample (residues truncated to $v \ge 2^{95}$) returns an edge weight of $0.0403$ with $95\%$ interval $[0.0301, 0.0525]$, and $\Delta\mathrm{AICc} = 49.78$ against a pre-registered bar of $6$.

The reading this invites is a **positional kernel**: a component of the hit intensity depending on $j - s$, i.e. on location in the window, over and above any dependence on the magnitude $v$.

### 1.3 The resolution

We prove that the profile is accounted for entirely by magnitude together with the geometry of the window, and that no positional component survives. The argument has four independent legs, developed in Sections 3–6 and assembled in Section 7:

- **§3 Inclusion geometry** — the left decile is a *pure tiny-$v$ stratum*, forced by exact arithmetic;
- **§4 Degeneracy and the quantile identity** — at fixed $N$, position and magnitude are the same statistic, exactly and in the limit;
- **§5 Composition accounting** — a flat null against heterogeneous bands produces the exact observed ratio with no rate elevation;
- **§6 Pooled evidence and truncation gradients** — the surviving "persistence" is null heterogeneity plus a boundary size gradient.

Section 8 calibrates the control arm; Section 9 states what survives, and Section 10 the open frontier.

### 1.4 Notational conventions

Throughout, $\mathrm{bitlen}(v)$ is the number of binary digits of $v$, so $\mathrm{bitlen}(v) < b \iff v < 2^{b-1}$ for $v \ge 1$. All sums over bands are finite. A *band* is a stratum of hits with a common range of $\mathrm{bitlen}(v)$; band $i$ has exposure $n_i \ge 0$, observed first-decile count $k_i \ge 0$, and band-specific first-decile rate $p_i \ge 0$. The flat null uses a single rate $p_0 > 0$.

---

## 2. The empirical inputs

We list, once, every number used as a hypothesis below. Everything else is derived.

| Quantity | Value |
|---|---|
| Moduli | $128$, all $< 2^{96}$ |
| Pooled hits | $9594$ |
| Controls | $512{,}000$ (first $4000$ used, capped) |
| $D_1$ hits by $\mathrm{bitlen}(v)$ | $<80$: $0$; $80$–$89$: $85$; $90$–$95$: $1469$; $\ge 96$: $0$ |
| Within-band $D_1$ rate ratio | $1.000$ (band $80$–$89$), $1.097$ (band $90$–$95$) |
| Flat-null $D_1$ expectation | $959.4$ |
| Flat-referenced excess | $+604.76$ |
| Band-referenced excess | $+129.66$ |
| Pooled rate ratio vs flat | $1.637$ |
| Kept-fit edge weight ($v \ge 2^{95}$) | $0.0403$, CI $[0.0301, 0.0525]$ |
| Kept-fit pooled $\Delta\mathrm{AICc}$ | $49.78$ |
| Stratified $\Delta\mathrm{AICc}$ | $5.94$ (band $[96,98)$), $-0.40$ (band $\ge 98$) |
| Registered decision bar | $\Delta\mathrm{AICc} \ge 6$ |
| Control per-$N$ $D_1$-share $z$ | mean $-0.223$, sd $0.945$, $\max|z| = 2.53$ |

---

## 3. Inclusion geometry: the left decile is a tiny-$v$ stratum

### 3.1 Well-posedness

**Lemma 3.1 (Positivity of window residues).** *For every $j \in W(N)$ we have $v(N,j) > 0$.*

*Proof.* By definition of the integer square root, $N < (s+1)^2$. Since $j \ge s+1$ we get $j^2 \ge (s+1)^2 > N$, hence $v = j^2 - N > 0$. $\square$

This is the pre-registered degenerate-exclusion clause: $v = 0$ would require $N$ to be a perfect square with $j = s$, which the window excludes. In particular $\mathrm{bitlen}(v)$ is well defined on the window.

### 3.2 The scale-carrying inclusion bound

**Theorem 3.2 (Inclusion bound at an arbitrary edge fraction).** *Let $p, q \in \mathbb{N}$ and suppose the position $j$ lies within the $p/q$ prefix beyond $s$, i.e. $q j \le (q+p)\,s$. Then*

$$q^2\, v(N,j) \;\le\; (2pq + p^2)\, s^2 .$$

*Proof.* Squaring the hypothesis gives $(qj)^2 \le ((q+p)s)^2 = (2pq+p^2)s^2 + q^2 s^2$. Since $s^2 \le N$,

$$q^2 j^2 \;\le\; (2pq+p^2)s^2 + q^2 N,$$

and subtracting $q^2 N$ from both sides yields $q^2 v = q^2 j^2 - q^2 N \le (2pq+p^2)s^2$. $\square$

No asymptotics enter; the statement is an identity of integer arithmetic, valid at every scale. Note how the constant $2pq + p^2$ degrades gracefully as the prefix widens: at $p/q = 1/5$ it is $11$ (out of $q^2 = 25$), at $p/q = 1/2$ it is $5$ (out of $4$, i.e. no constraint beyond $v \le 1.25 s^2$), and by $p = q$ the bound is vacuous relative to the window.

**Corollary 3.3 (First-decile bound).** *For every $j \in D_1(N)$,*

$$25\, v(N,j) \;\le\; 11\, s^2 \;\le\; 11\, N, \qquad\text{i.e.}\qquad v \le 0.44\,N .$$

*Proof.* Apply Theorem 3.2 with $p = 1$, $q = 5$: the hypothesis $5j \le 6s$ is exactly the decile condition, and $2pq + p^2 = 11$. The second inequality is $s^2 \le N$. $\square$

**Theorem 3.4 (Sharpness).** *For every $m \ge 1$, taking $N = (5m)^2$ and $j = 6m$ gives $j \in D_1(N)$ and $25\,v(N,j) = 11\,s^2$ exactly.*

*Proof.* Here $s = 5m$, so $j = 6m \in [5m+1, 15m]$ and $5j = 30m = 6s$. The residue is $v = 36m^2 - 25m^2 = 11m^2$, and $25 v = 275 m^2 = 11 (5m)^2$. $\square$

### 3.3 The bit-length forcing

**Theorem 3.5 (Mechanical exclusion).** *If $N < 2^{96}$ then every first-decile residue satisfies $v < 2^{95}$; equivalently $\mathrm{bitlen}(v) < 96$.*

*Proof.* By Corollary 3.3, $25 v \le 11 N < 11\cdot 2^{96} = 22 \cdot 2^{95} < 25 \cdot 2^{95}$, hence $v < 2^{95}$. $\square$

**Corollary 3.6 (Contrapositive).** *If $N < 2^{96}$ and a stored hit has $\mathrm{bitlen}(v) \ge 96$, then that hit is not in the first decile. The exclusion is deterministic, not statistical.*

This is the entire content of the empirical zero in the last column of the band table of Section 2. It is not evidence about a hit process. It fires for all $128$ moduli, and it fires for every position, hit or not.

**Theorem 3.7 (Localisation at the edge, not the window).** *There exist $N < 2^{96}$ and $j \in W(N)$ with $\mathrm{bitlen}(v(N,j)) \ge 96$.*

*Proof.* Take $N = 2^{94}$, so $s = 2^{47}$, and $j = 3\cdot 2^{47}$, the last window position. Then $v = 9\cdot 2^{94} - 2^{94} = 8 \cdot 2^{94} = 2^{97}$, whose bit length is $98$. $\square$

Theorems 3.5 and 3.7 together say that the tiny-$v$ forcing is a property of the *decile cut*, not of the window: the window itself spans residues from $O(s)$ up to $8s^2$. The first-decile stratum is therefore not a random sample of the window's size distribution; it is a size-selected subpopulation.

---

## 4. Position and magnitude are the same statistic

### 4.1 Exact degeneracy at fixed modulus

**Lemma 4.1 (Strict monotonicity).** *For $s+1 \le j < j'$ we have $v(N,j) < v(N,j')$.*

*Proof.* $N < (s+1)^2 \le j^2$, so $v(N,j) = j^2 - N$ and $v(N,j') = j'^2 - N$ are both computed without truncation, and $j^2 < j'^2$. $\square$

**Lemma 4.2 (Exact inversion).** *For $j \ge s+1$, $\ \bigl\lfloor\sqrt{\,N + v(N,j)\,}\bigr\rfloor = j$.*

*Proof.* $N + v = j^2$, whose integer square root is $j$. $\square$

**Theorem 4.3 (Non-identifiability within a modulus).** *Fix $N$. For every weight function $w$ on window positions there is a weight function $m$ on residues with $w(j) = m(v(N,j))$ for all $j \ge s+1$, and conversely.*

*Proof.* Take $m(v) := w(\lfloor\sqrt{N+v}\rfloor)$ and apply Lemma 4.2 for the forward direction; take $w(j) := m(v(N,j))$ for the converse. $\square$

Hence the "positional kernel" and "magnitude kernel" model families are **observationally indistinguishable at fixed $N$**. No single-modulus experiment can separate them, whatever its size. The counting form:

**Proposition 4.4 (Coinciding quantile functions).** *For $j \ge s+1$,*
$$\#\{\, j' \in [s+1, j] : v(N,j') \le v(N,j) \,\} = j - s ,$$
*i.e. the magnitude rank of a hit equals its positional rank.*

**Theorem 4.5 (Only pooling identifies).** *There exist $(N_1, j_1)$ and $(N_2, j_2)$ with $j_i \ge \lfloor\sqrt{N_i}\rfloor + 1$, equal residues, and different positional ranks.*

*Proof.* $N_1 = 37$, $j_1 = 7$: $s_1 = 6$, $v = 12$, rank $1$. $N_2 = 24$, $j_2 = 6$: $s_2 = 4$, $v = 12$, rank $2$. $\square$

This is the structural crux of the whole analysis: the design's **only** source of identification is cross-modulus pooling, and — by Section 5 — pooling is also the **only** source of the band-composition confound. The two cannot be separated by refining the analysis; they are the same step.

### 4.2 The exact quantile identity

**Theorem 4.6 (Closed-form empirical quantile function).** *For every $x \ge 0$,*

$$\#\{\, j \in W(N) : v(N,j) \le x \,\} \;=\; \min\bigl(3s,\ \lfloor\sqrt{N+x}\rfloor\bigr) - s .$$

*Proof.* For $j \ge s+1$ we have $N \le j^2$, so $v(N,j) \le x \iff j^2 \le N + x \iff j \le \lfloor\sqrt{N+x}\rfloor$. Hence the sublevel set is the integer interval $[s+1, \min(3s, \lfloor\sqrt{N+x}\rfloor)]$, whose cardinality is the stated difference (using $s \le \lfloor\sqrt{N+x}\rfloor$). $\square$

**Corollary 4.7 (Sublevel sets are prefixes and conversely).** *Every magnitude sublevel set of the window is a positional prefix of it, and for any cut $c \ge s+1$ the positional prefix $\{j \le c\}$ equals the magnitude sublevel set $\{v \le v(N,c)\}$.*

### 4.3 On the divisible moduli, the decile cut *is* a magnitude cut

Let $N = (5m)^2$, so $s = 5m$ exactly and no rounding of the anchor occurs.

**Theorem 4.8.** *For $N = (5m)^2$:*

1. *the window has exactly $10m$ positions;*
2. *the first decile has exactly $m$ of them — so it is literally a tenth;*
3. *for every $j \in W(N)$, $\quad j \in D_1(N) \iff v(N,j) \le 11 m^2$;*
4. *consequently the first-decile count and the count of positions with $v \le 11m^2$ are the same number.*

*Proof.* (1) $|[5m+1, 15m]| = 10m$. (2) $D_1 = [5m+1, 6m]$, of size $m$. (3) Writing $j = 5m + t$ with $0 \le t \le 10m$, the residue is $v = 10mt + t^2$, which is increasing in $t$; the decile condition is $t \le m$, and $v(t=m) = 11m^2$. (4) Immediate from (3). $\square$

There is therefore no positional information in the decile cut beyond the magnitude cut, at any scale of the divisible family.

### 4.4 The continuum limit law

Let $N = M^2$ and write $F_M(x)$ for the fraction of the $2M$ window positions with residue at most $x$.

**Theorem 4.9 (Kolmogorov bound).** *For $0 < M$ and $0 \le x \le 8M^2$,*

$$\Bigl|\, F_M(x) - \tfrac{1}{2}\bigl(\sqrt{1 + x/M^2} - 1\bigr) \,\Bigr| \;\le\; \frac{1}{2M} .$$

*Proof sketch.* By Theorem 4.6 and $x \le 8M^2$ the count is exactly $\lfloor\sqrt{M^2+x}\rfloor - M$, so $F_M(x) = (\lfloor\sqrt{M^2+x}\rfloor - M)/(2M)$. The continuum value equals $(\sqrt{M^2+x} - M)/(2M)$. The two numerators differ by $|\lfloor\sqrt{y}\rfloor - \sqrt{y}| \le 1$; divide by $2M$. $\square$

**Corollary 4.10 (Limit law).** *For each $y \in [0,8]$, $\ F_M(\lfloor y M^2\rfloor) \to \frac{1}{2}(\sqrt{1+y} - 1)$ as $M \to \infty$.*

*Proof sketch.* Combine Theorem 4.9 with $|\lfloor yM^2\rfloor/M^2 - y| \le 1/M^2$ and continuity of $y \mapsto \frac12(\sqrt{1+y}-1)$. $\square$

The limit distribution function $F(y) = \frac12(\sqrt{1+y}-1)$ is exactly the law of $(1+2U)^2 - 1$ for $U$ uniform on $[0,1]$ — as it must be, since a uniformly chosen window position is $j = M(1+2U)$ and $v/M^2 = (1+2U)^2 - 1$. The convergence rate $O(1/M)$ is explicit and comes solely from integer-square-root rounding.

**Theorem 4.11 (The decile level is exact).** *$F(11/25) = 1/10$ exactly, and on the divisible moduli $N = (5m)^2$ the empirical first-decile fraction equals $1/10$ with zero error.*

*Proof.* $1 + 11/25 = (6/5)^2$, so $F(11/25) = (6/5 - 1)/2 = 1/10$. The exactness is Theorem 4.8(1)–(2). $\square$

**Interpretation.** A first-decile analysis on this window is a $v \le 0.44 s^2$ analysis with an error of at most one position, at every scale. There is no asymptotic regime in which the positional cut carries information beyond the magnitude cut.

---

## 5. Composition accounting

We now turn to the statistical consequence. The design compares a first-decile count against a null. The question is what null.

### 5.1 The exact decomposition

Let $S$ be a finite index set of bands, with exposures $n_i$, observed first-decile counts $k_i$, band rates $p_i$, and flat rate $p_0$. Define

$$\mathrm{FlatExcess} := \sum_{i} k_i - p_0 \sum_i n_i, \qquad
\mathrm{BandExcess} := \sum_i \bigl(k_i - p_i n_i\bigr), \qquad
\mathrm{Comp} := \sum_i (p_i - p_0)\, n_i .$$

**Theorem 5.1 (Exact excess decomposition).** *With no hypotheses whatsoever,*

$$\mathrm{FlatExcess} \;=\; \mathrm{BandExcess} \;+\; \mathrm{Comp}.$$

*Proof.* Termwise, $k_i - p_0 n_i = (k_i - p_i n_i) + (p_i - p_0) n_i$; sum over $i$. $\square$

Trivial as an identity, decisive as an accounting device: it partitions any flat-referenced excess into a *rate* part and a *composition* part, and the two boundary cases pin down when each is the whole story.

**Corollary 5.2 (Size-matched bands: all composition).** *If $k_i = p_i n_i$ for every band — i.e. every within-band rate ratio is exactly $1$ — then $\mathrm{FlatExcess} = \mathrm{Comp}$.*

**Corollary 5.3 (Homogeneous bands: no composition).** *If $p_i = p_0$ for every band then $\mathrm{Comp} = 0$ and $\mathrm{FlatExcess} = \mathrm{BandExcess}$.*

So a composition artifact **requires genuine band heterogeneity** — and Theorem 3.5 supplies it in the strongest possible form, since the band $\mathrm{bitlen}(v) \ge 96$ has $p_i = 0$ *mechanically*.

**Proposition 5.4 (Control of the rate part).** *If $k_i = \rho_i\, p_i n_i$ with rate ratios $\rho_i$, and $p_i, n_i \ge 0$, then*
$$\bigl|\mathrm{BandExcess}\bigr| \;\le\; \sum_i |\rho_i - 1|\; p_i n_i .$$

At the reported ratios $\rho = 1.000$ and $1.097$, this bounds the rate part by roughly a tenth of the band-referenced expectation of the $90$–$95$ band — consistent with the observed band-referenced excess of $+129.66$ against a flat-referenced $+604.76$.

### 5.2 Multiplicative form: the pooled ratio factorises

**Definition 5.5.** The **composition factor** is
$$\mathrm{CF} := \frac{\sum_i p_i n_i}{p_0 \sum_i n_i}.$$

**Theorem 5.6 (Factorisation of the pooled rate ratio).** *If $k_i \le R\,p_i n_i$ for all $i$, $p_0 > 0$ and $\sum_i n_i > 0$, then*

$$\frac{\sum_i k_i}{p_0 \sum_i n_i} \;\le\; R \cdot \mathrm{CF}.$$

*Proof.* Sum the hypothesis and divide by the positive denominator. $\square$

**Corollary 5.7 (The reported numbers, exactly).** *With matched ratio $R = 1.097$ and composition factor $\mathrm{CF} = 1.4924$,*
$$R \cdot \mathrm{CF} = 1.6372\ldots, \qquad |R\cdot \mathrm{CF} - 1.637| \le 0.0002 .$$
*Furthermore any $R \le 1.097$ and $\mathrm{CF} \le 1.4924$ give $R\cdot\mathrm{CF} \le 1.638$.*

The measured within-band ratio times the measured composition factor reproduces the observed pooled ratio to four decimal places. **Nothing is left over for a positional component.**

### 5.3 A pure-composition spike in the geometry-forced configuration

**Theorem 5.8 (Simpson-type reversal).** *There exist two bands, exposures $n$, counts $k$, band rates $p$ and a flat rate $p_0$ such that*

- *$k_i = p_i n_i$ for both bands (within-band rate ratio exactly $1$);*
- *$\mathrm{BandExcess} = 0$ exactly;*
- *$\mathrm{FlatExcess} \ge 600$;*
- *the pooled rate ratio exceeds $1.6$.*

*Proof.* Take band $0$ (tiny $v$): $n_0 = 3000$, $p_0^{(0)} = 0.53$, $k_0 = 1590$. Take band $1$ (large $v$, mechanically zero edge rate by Corollary 3.6): $n_1 = 6594$, $p^{(1)} = 0$, $k_1 = 0$. Flat rate $p_0 = 0.1$. Then $\mathrm{BandExcess} = 0$; $\mathrm{FlatExcess} = 1590 - 0.1\cdot 9594 = 630.6 \ge 600$; and the pooled ratio is $1590/959.4 = 1.657 > 1.6$. $\square$

The exposures here are exactly the pooled hit count $9594$, split in the proportions the window geometry forces. Nothing is happening in any band, and a spike of $600$ appears.

### 5.4 Extremal behaviour: how large can pure composition be?

**Theorem 5.9 (Two-sided extremal bound).** *Suppose $n_i \ge 0$, $\sum_i n_i > 0$, $p_0 > 0$, and $p_{\min} \le p_i \le p_{\max}$ for all $i$. Then, whatever the exposure allocation,*

$$\frac{p_{\min}}{p_0} \;\le\; \mathrm{CF} \;\le\; \frac{p_{\max}}{p_0}.$$

*Proof.* $\sum_i p_i n_i$ lies between $p_{\min}\sum n_i$ and $p_{\max}\sum n_i$; divide. $\square$

**Theorem 5.10 (Rigidity).** *If $\mathrm{CF} = p_{\max}/p_0$ then every band carrying positive exposure has $p_i = p_{\max}$.*

*Proof sketch.* Equality forces $\sum_i (p_{\max} - p_i)n_i = 0$, a sum of nonnegative terms; each term vanishes, so $n_i > 0 \Rightarrow p_i = p_{\max}$. $\square$

**Theorem 5.11 (Sharpness).** *Putting all exposure on a maximal-rate band attains $\mathrm{CF} = p_{\max}/p_0$.*

**Corollary 5.12 (Universal ceiling).** *If additionally $k_i \le R\,p_i n_i$ with $R \ge 0$, then the pooled rate ratio never exceeds $R\,p_{\max}/p_0$. At $p_0 = 0.1$, $p_{\max} \le 0.14924$ and $R \le 1.097$, the pooled rate ratio cannot exceed $1.638$.*

**Proposition 5.13 (Additive form).** *$\mathrm{Comp} \le (p_{\max} - p_0)\sum_i n_i$.*

The moral is quantitative: **the composition artifact is bounded by the rate spread, never by the sample size.** You cannot manufacture an arbitrarily large composition spike by collecting more data — only by widening the between-band gap. In this design the gap is maximal, because one band's edge rate is exactly zero by Corollary 3.6.

### 5.5 A lower bound on the composition share

Corollary 5.2 gives "all composition" at $R = 1$. The following quantifies the near-matched regime. Write $E := p_0\sum_i n_i$ for the flat-null expectation.

**Theorem 5.14 (Composition share).** *If $k_i \le R\,p_i n_i$ for all $i$, then*

$$\mathrm{FlatExcess} \;\le\; R\cdot\mathrm{Comp} + (R-1)\,E ,$$

*and hence, for $R > 0$,*

$$\mathrm{Comp} \;\ge\; \frac{\mathrm{FlatExcess} - (R-1)E}{R}.$$

*Proof.* Sum the matched bound: $\sum k_i \le R\sum p_i n_i = R(\mathrm{Comp} + E)$. Subtract $E$: $\mathrm{FlatExcess} \le R\,\mathrm{Comp} + (R-1)E$. Rearrange. $\square$

**Corollary 5.15 (The reported numbers).** *With $R = 1.097$, $E = 959.4$, and $\mathrm{FlatExcess} \ge 604.76$:*

$$\mathrm{Comp} \;\ge\; \frac{604.76 - 0.097\cdot 959.4}{1.097} \;=\; \frac{511.7\ldots}{1.097} \;\ge\; 466,$$

*so at least $77\%$ of the whole flat-referenced excess is composition.*

The qualitative statement "roughly four fifths of the spike is band composition" is thus an inequality, not an impression. Together with Corollary 5.7 — which shows the matched ratio and composition factor already *exhaust* the pooled ratio — the composition explanation is not merely sufficient; it is forced.

---

## 6. Pooled evidence, stratified evidence, and truncation gradients

The remaining evidence is the *kept fit*: after truncating to $v \ge 2^{95}$, thereby discarding the entire tiny-$v$ stratum, a left-edge component still appears in the pooled fit, with $\Delta\mathrm{AICc} = 49.78$. We show that this number does not survive stratification, and that what does survive is a boundary artefact.

### 6.1 Pooled evidence is bounded by stratified evidence plus a null gap

For $k$ parameters and $n$ observations write the small-sample penalty
$$\mathrm{pen}(k,n) := 2k + \frac{2k(k+1)}{n-k-1}, \qquad \mathrm{AICc} := -2\ell + \mathrm{pen}(k,n),$$
and $\Delta\mathrm{AICc} := \mathrm{AICc}_{\text{null}} - \mathrm{AICc}_{\text{enlarged}}$, so positive values favour the enlarged model.

Let $\ell_i(\theta)$ be the log-likelihood of stratum $i$. A **pooled** fit chooses one $\theta$ for all strata; a **stratified** fit chooses $u_i$ per stratum. Let $t_0, t_1$ be pooled maximisers of null and enlarged models and $u_0, u_1$ the stratum-wise ones.

**Definition 6.1 (Null misspecification gap).**
$$G := 2\Bigl(\sum_i \ell_i(u_0(i)) - \sum_i \ell_i(t_0)\Bigr).$$

**Lemma 6.2.** *If $\ell_i(t_0) \le \ell_i(u_0(i))$ for all $i$ — in particular if $u_0(i)$ maximises stratum $i$ — then $G \ge 0$. A single pooled null can never beat stratum-wise nulls.*

**Theorem 6.3 (Evidence inequality).** *Under the same stratum-wise optimality assumptions,*
$$2\Bigl(\textstyle\sum_i\ell_i(t_1) - \sum_i\ell_i(t_0)\Bigr) \;\le\; 2\Bigl(\textstyle\sum_i\ell_i(u_1(i)) - \sum_i\ell_i(u_0(i))\Bigr) + G .$$

*Proof.* Both pooled log-likelihoods are dominated by their stratified counterparts; substitute and rearrange. $\square$

**Theorem 6.4 (At the $\Delta\mathrm{AICc}$ level).** *With $D := \sum_i \mathrm{pen\text{-}diff}_i - \mathrm{pen\text{-}diff}_{\text{pooled}}$ the penalty defect of the split,*
$$\Delta\mathrm{AICc}_{\text{pooled}} \;\le\; \sum_i \Delta\mathrm{AICc}_i \;+\; G \;+\; D .$$

Any pooled excess beyond the strata is therefore attributable to heterogeneity of the **null** across strata — not to support for the extra component.

**Corollary 6.5 (Reading of the reported numbers).** *With $\Delta\mathrm{AICc}_{\text{pooled}} = 49.78$, strata $5.94$ and $-0.40$, and $D \le 3$:*
$$G \;\ge\; 49.78 - 5.94 + 0.40 - 3 \;=\; 41.24 \;>\; 41.2 .$$

Over $80\%$ of the pooled statistic measures the size gradient between bit-length bands. More robustly, if both strata merely sit at or below the registered bar $6$ and $D \le 3$, then $\Delta\mathrm{AICc}_{\text{pooled}} \ge 49$ forces $G \ge 34$.

**Proposition 6.6 (Stratification is conservative).** *For $0 < k$ and $k+1 < m < n$, $\ \mathrm{pen}(k,n) < \mathrm{pen}(k,m)$: the small-sample correction is strictly decreasing in the sample size. Splitting a sample therefore strictly raises the total penalty, so sub-bar strata are not an artefact of a laxer criterion.*

**Proposition 6.7 (Realisability).** *There is a configuration with stratum values exactly $5.94$ and $-0.40$, penalty defect $2$, pooled $49.78$, and $G = 42.24 \ge 0$ — consistent with Theorem 6.4 and requiring the extra component to be real in no stratum.*

### 6.2 A monotone size density manufactures an edge component at a truncation boundary

Model a band as $2m$ consecutive size cells with local density $f(0), \dots, f(2m-1)$, and define

$$L := \sum_{i=0}^{m-1} f(i), \qquad U := \sum_{i=m}^{2m-1} f(i), \qquad \mathrm{EdgeExcess} := L - U .$$

**Theorem 6.8.** *(i) If $f$ is nonincreasing then $\mathrm{EdgeExcess} \ge 0$: a spurious left-edge weight is automatic. (ii) If $f$ is constant then $\mathrm{EdgeExcess} = 0$: the effect is a* gradient *effect, not an edge effect. (iii) If $f$ is nonincreasing with $f(m) < f(0)$ and $m \ge 1$ then $\mathrm{EdgeExcess} > 0$.*

*Proof.* Reindex $U = \sum_{i<m} f(m+i)$ and compare termwise. $\square$

**Theorem 6.9 (Geometric density).** *For $f(i) = r^i$ with $0 < r < 1$ and $m \ge 1$, the relative edge excess is exactly*

$$\frac{\mathrm{EdgeExcess}}{L+U} \;=\; \frac{1 - r^m}{1 + r^m} \;=:\; \mathcal{R}(r,m).$$

*Proof.* $L = (1-r^m)/(1-r)$ and $U = r^m L$; substitute. $\square$

**Theorem 6.10 (Monotonicity and decay).** *$\mathcal{R}(\cdot, m)$ is strictly decreasing in $r$ for $m \ge 1$, and $\mathcal{R}(r,m) \le m(1-r)$ for $0 \le r \le 1$.*

*Proof sketch.* Monotonicity is a cross-multiplication. For the bound, $1 - r^m \le m(1-r)$ by induction (telescoping $1-r^{k+1} = (1-r^k) + r^k(1-r)$ with $r^k \le 1$), and $1 + r^m \ge 1$. $\square$

**Interpretation.** Near a truncation boundary the surviving size density is steep: $r$ is well below $1$ and $\mathcal{R}$ is appreciable. Two bands out, the density is locally flat, $r \to 1$, and $\mathcal{R} \to 0$. The observed pattern — $\Delta\mathrm{AICc} = 5.94$ at $[96,98)$, adjacent to the cut at $2^{95}$, and $-0.40$ at $\ge 98$ — is exactly this shape. The "persistence" of the edge component after truncation is a **truncation-boundary size gradient**, not positional structure.

---

## 7. The verdict, assembled

**Theorem 7.1 (Full accounting).** *Assume: (a) $N < 2^{96}$ and $j$ is a first-decile position; (b) the size-matched within-band rate ratios satisfy $k_i \le 1.097\,p_i n_i$; (c) the pooled fit reports $\Delta\mathrm{AICc}_{\text{pooled}} \ge 49$ while every size-matched stratum reports $\Delta\mathrm{AICc}_i \le 6$, with penalty defect $\le 3$ and the evidence inequality of Theorem 6.4. Then:*

1. $\mathrm{bitlen}(v(N,j)) < 96$ *— the left-edge decile is a pure tiny-$v$ stratum;*
2. $\mathrm{FlatExcess} \le 0.097\sum_i p_i n_i + \mathrm{Comp}$ *— the flat-referenced excess never exceeds the composition term plus $9.7\%$ of the band-referenced expectation, and equals the composition term outright under exact matching;*
3. $G \ge 34$ *— the pooled evidence is dominated by cross-band null heterogeneity, which by Theorems 6.8–6.10 is precisely what a monotone size density at a truncation boundary produces.*

*Proof.* (1) is Theorem 3.5. (2) combines Theorem 5.1 with the matched bound summed over bands. (3) is Corollary 6.5's robust form. $\square$

**Theorem 7.2 (Why no single-modulus test could have separated the layers).** *Within one modulus, position and residue determine each other, so every positional weighting is realised by a magnitude weighting (Theorem 4.3). Identification requires pooling across moduli (Theorem 4.5) — which is exactly the step that imports the band composition of Section 5.*

**Corollary 7.3 (Map statement).** *No positional kernel component survives. The left-edge profile is fully accounted for by magnitude together with tiny-$v$ window geometry.*

### 7.1 Erratum

An earlier reading of the same dataset concluded that the kernel *survives at reduced strength*, splitting the profile into a mechanical part and "half genuine small-$|v|$ structure beyond the size prediction", and drew two downstream consequences from that split. Sections 5 and 6 retract those claims: the surviving component is a truncation-boundary gradient, and the pooled evidence for it does not clear the registered bar in any size-matched stratum. Applying the *registered* $\Delta\mathrm{AICc} \ge 6$ bar to matched-$v$ strata — no bar was changed after the fact — the correct verdict is that the component is absent.

Preserved from that earlier reading: the mechanical-degeneracy finding, which is *strengthened* here and is now load-bearing; the regeneration verification; the clean control arm; and the full disclosure ledger.

---

## 8. What the control arm can and cannot say

The controls reported per-$N$ first-decile share $z$-scores over $128$ strata with mean $-0.223$, sd $0.945$ and $\max|z| = 2.53$. The ledger entry is "controls clean". The precise statement, and its limit:

**Theorem 8.1 (Multiplicity bound).** *If each of $m$ control statistics exceeds a threshold with probability at most $q$, then the probability that some control exceeds it is at most $mq$. Specialised to a sub-Gaussian null with $\mathbb{P}(|Z_i| \ge t) \le 2e^{-t^2/2}$:*
$$\mathbb{P}\Bigl(\max_{i \le m} |Z_i| \ge t\Bigr) \;\le\; 2m\,e^{-t^2/2}.$$

**Theorem 8.2 (The observed maximum is uninformative).** *At $m = 128$ and $t = 2.53$, $\ 2\cdot 128\cdot e^{-2.53^2/2} > 1$.*

*Proof.* $2.53^2/2 < 4$, so $e^{-2.53^2/2} > e^{-4} > 1/55$, giving $256\,e^{-2.53^2/2} > 256/55 > 1$. $\square$

**Theorem 8.3 (Corrected threshold).** *Any $t \ge 0$ with $2\cdot 128\,e^{-t^2/2} \le 0.05$ satisfies $t > 4$; in particular $2.53 < t$, so no control stratum reaches significance.*

*Proof.* If $t \le 4$ then $t^2/2 \le 8$, so $e^{-t^2/2} \ge e^{-8} > 1/2981$, whence $256\,e^{-t^2/2} > 256/2981 > 0.05$. $\square$

The correct reading of "controls clean" is therefore: **no exceedance was produced.** It is not evidence *for* the null. Recording this asymmetry explicitly is part of the discipline the analysis is meant to enforce.

---

## 9. What survives

Retractions that delete everything are usually retracting too much. Three things survive intact.

**The overdispersion is real.** There genuinely are $\approx 605$ more first-decile hits than a flat null expects. The finding is not that the excess is illusory but that it has a *named origin*: size composition forced by the window's geometry. The excess is not deleted; it is explained.

**The mechanical degeneracy is now load-bearing.** What began as a pre-registered caveat is the central theorem. The design lesson generalises: the only source of identification (cross-modulus pooling) is also the only source of the confound (band composition). A design in which those coincide cannot separate the two hypotheses by any amount of additional data at fixed geometry.

**Both surviving mechanisms are scale-carrying.** Theorem 3.2 is exact arithmetic; its constant $2pq+p^2$ is scale-free and its conclusion $q^2 v \le (2pq+p^2)s^2$ grows with $N$. At $128$ bits, $256$ bits, or any size, the first decile of this window remains a pure tiny-$v$ stratum. Likewise, Theorem 5.9 bounds the composition factor by the rate spread rather than the sample size, so the artefact neither grows nor shrinks with more data.

Untouched by this analysis: the positional layer's independent shape description, its residue cap, the position-dependence multiplier, external-hint laws, and the four-class rate-residual closure. The rate-layer question — whether there is *any* genuine within-band rate elevation, as opposed to a composition effect — remains open; the measured $1.097$ in the $90$–$95$ band is the current best handle on it.

---

## 10. Algorithms

Three computations carry the analysis and are worth stating as procedures.

**A. Window-geometry certification.** For each modulus, recompute $s = \lfloor\sqrt N\rfloor$ by exact integer arithmetic, derive the window endpoints $(s+1, 3s)$, verify containment of every stored position, and certify the decile bound $25v \le 11 s^2$ for every first-decile record. Cost: $O(\#\text{records})$ integer operations plus one integer square root per modulus, i.e. $O(\log^2 N)$ bit operations each by Newton iteration. This step turns the empirical "$0$ first-decile hits with $\mathrm{bitlen} \ge 96$" into a verified consequence.

**B. Excess decomposition.** Given bands with $(n_i, k_i, p_i)$ and a flat rate $p_0$, compute $\mathrm{FlatExcess}$, $\mathrm{BandExcess}$, $\mathrm{Comp}$, verify the identity of Theorem 5.1 to machine precision, and report the composition share. Cost: $O(|S|)$.

**C. Evidence budget.** Given pooled and stratum $\Delta\mathrm{AICc}$ values and a bound on the penalty defect, solve Theorem 6.4 for the implied null gap $G$ and report the fraction of the pooled statistic it accounts for. Cost: $O(|S|)$.

Each is cheap; the content is in what they certify, not in what they cost.

---

## 11. Discussion

### 11.1 The general phenomenon

The mathematical core is Theorem 5.1 together with Corollaries 5.2 and 5.3: an excess measured against a size-blind null splits exactly into a rate term and a composition term, the composition term vanishes under homogeneity, and it carries everything under exact matching. This is Simpson's paradox stated as an accounting identity rather than as a paradox, and it is the right frame whenever a slicing variable is correlated with an omitted stratifier.

What makes the present instance unusually clean is that the correlation is not statistical but **arithmetical**. The slicing variable (position in the window) and the omitted stratifier (magnitude of the residue) are, at fixed modulus, the *same variable* (Theorem 4.3) — an exact functional identity with an explicit inverse. Consequently the composition term is not merely large; it is forced, and the extremal bound of Theorem 5.9 is attained in the most extreme configuration allowed, because one band's edge rate is exactly zero.

### 11.2 Diagnostics that would have caught this earlier

Three cheap checks would have flagged the artefact before any mixture was fitted:

1. **Cross-tabulate the slicing variable against the size bands.** A cell that is empty *by construction* — here, first decile $\times$ $\mathrm{bitlen} \ge 96$ — is a red flag for a mechanically forced stratum. It should be checked against the geometry, not against a null.
2. **Report size-matched rate ratios alongside the pooled ratio.** Had $1.000$ and $1.097$ appeared next to $1.637$, the composition factor of $1.4924$ would have been read off immediately.
3. **Stratify the model-selection statistic.** Pooled $\Delta\mathrm{AICc}$ is not a stratum statistic; Theorem 6.4 shows exactly how much of it can be null misspecification. Reporting the stratified values ($5.94$, $-0.40$) alongside the pooled value ($49.78$) makes the null gap visible as the residual.

### 11.3 The truncation trap

Truncating away the confounded stratum is the natural remedy, and it is a trap. Theorems 6.8–6.10 show that a monotone size density near *any* truncation boundary generates a nonnegative apparent edge excess, decaying like $m(1-r)$ away from the cut. Removing a confound by truncation therefore installs a new artefact at the cut. The diagnostic is exactly the observed one: does the apparent component persist *away* from the boundary? Here it does not — $\Delta\mathrm{AICc} = -0.40$ at $\ge 98$ — and that single number is what distinguishes a boundary gradient from a real component.

### 11.4 On "controls clean"

Theorems 8.1–8.3 formalise a distinction that is easy to blur under time pressure. A maximum $|z|$ of $2.53$ over $128$ strata is not a null-confirming observation; the multiplicity-corrected bound at that threshold exceeds $1$ and is vacuous. The ledger entry is correct and its strength is limited. Both facts should travel together.

---

## 12. Future directions

The results above close two questions that were previously open — the exact quantile law of the window residue, and the extremal behaviour of the composition factor — and sharpen the remainder into refutable form. Each direction below is stated so that a single computation or a single counterexample can settle it.

**1. Cross-modulus mixture law and the pooled identification budget.** The single-modulus law is settled: the rescaled residue has distribution function $(\sqrt{1+y}-1)/2$ on $[0,8]$, with $O(1/M)$ error. The pooled experiment mixes $128$ such laws with different $M$. Question: what is the *identification budget* of the mixture — the maximum, over positional kernels $w$, of the discrepancy between the pooled positional statistic and its best magnitude-kernel approximation? Theorem 4.3 makes this zero at fixed $M$; the mixture makes it positive. Quantifying it says exactly how much positional information cross-modulus pooling can, in principle, deliver, and therefore how large a study would need to be to detect a kernel of a given strength.

**2. Sharp composition share without a matched-ratio input.** Theorem 5.14 lower-bounds the composition share in terms of a matched ratio $R$ measured from the data. Is there a bound depending only on the *geometry* — that is, on the fact that one band's rate is mechanically zero and the exposure split is determined by $\mathrm{bitlen}$ thresholds — with no rate input at all? A positive answer would make the composition verdict independent of the within-band fits.

**3. Truncation-boundary gradient at arbitrary cuts.** Theorem 6.10 gives $\mathcal{R}(r,m) \le m(1-r)$. For a Dickman-type size density, $r$ is a known function of the cut location and band width. Predicting the apparent edge weight as a function of the truncation point, and checking it against refits at several cuts, would turn the boundary-gradient explanation from a qualitative match into a fitted curve with residuals.

**4. Designs that break the degeneracy.** Theorem 4.5 shows pooling separates position from magnitude, but pooling also imports composition. Is there a *window shape* — a family of position sets depending on $N$ — for which position and magnitude are not in bijection at fixed $N$, so that the degeneracy is broken within a modulus? Any such design would make the positional hypothesis testable without the confound.

**5. Multiplicity-honest control targets.** Theorem 8.3 shows a $5\%$ Bonferroni bar over $128$ strata sits above $|z| = 4$. What per-stratum control precision, and how many strata, are needed for a control arm to *confirm* rather than merely fail to reject? Answering this converts the "controls clean" entry from an absence into a designed quantity.

---

## 13. Conclusion

A histogram had a bump at the left edge of a search window, and the bump had a model. The model was wrong, and it was wrong for a reason that no amount of additional data would have exposed: the coordinate being sliced on was, by exact arithmetic, the same coordinate as the one being ignored.

The corrective is a short chain of elementary theorems. The window's first decile satisfies $25v \le 11 s^2$, so it is a pure tiny-$v$ stratum. Position and magnitude determine each other at fixed modulus, so no single-modulus test can separate them. A flat-referenced excess splits exactly into rate and composition, and the measured matched ratio times the measured composition factor reproduces the observed pooled ratio to four decimals. Pooled model-selection evidence is bounded by stratified evidence plus a null gap, and the reported numbers force that gap to carry over four fifths of the "evidence". What remains lives entirely at a truncation boundary, where a monotone size density produces exactly such a component and where it decays like $m(1-r)$ as one moves away.

No positional kernel component survives. The overdispersion is real, and it now has a name.
