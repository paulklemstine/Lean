# The Left-Edge Spike of a Fermat Window is Not One Object: Exact Band Geometry of Quadratic Residues $j^2 - N$

**Author:** Aristotle

**Date:** 2026-08-26

---

## Abstract

We study the residue sequence $v(j) = j^2 - N$ along the Fermat scan window $j \in (s, 3s]$, $s = \lfloor\sqrt N\rfloor$, with positions normalised as $u = (j-s)/(2s) \in (0,1]$. Empirical scans of such windows report a pronounced excess of smooth residues at the left edge — a "spike" carrying roughly $8.6\%$ of the recorded mass in the first decile — and it is natural to test whether that excess is merely a magnitude artifact by discarding residues smaller than the modulus scale.

We prove that this test is *provably degenerate*. For every $96$-bit modulus $N$ (that is, $2^{95} \le N < 2^{96}$) and every first-decile position $j$, one has $v(j) < 2^{95}$. Hence a "$v \ge 2^{95}$" filter deletes $100\%$ of the first-decile population, by arithmetic alone and independently of any data. The mechanism is scale-free: for every $N \ge 2^{16}$ a first-decile residue satisfies $100\,v(j) < 45\,N$, hence $2\,v(j) < N$, so the residue always loses at least one binary digit relative to the modulus. Both size hypotheses are load-bearing, with explicit counterexamples at $N = 36482$ and $N = 962$.

We then determine the geometry exactly. Since $v$ is strictly increasing on the window, every bit-length band is a positional interval; the sub-$T$ population is exactly $\min(3s, \lfloor\sqrt{N+T-1}\rfloor) - s$, and the band histogram telescopes into differences of integer square roots — a deterministic function of $N$ with no stochastic content. For $96$-bit moduli the excluded band occupies between $11\%$ and $21\%$ of the window. In the continuum the transition is governed by the crossing curve $u_0(N) = (\sqrt{1 + 2^{95}/N} - 1)/2$, strictly decreasing in $N$ and confined to $\big((\sqrt6-2)/4, (\sqrt2-1)/2\big] \subset (0.1123, 0.2072]$; the decile boundary $0.1$ lies strictly below the lower endpoint, which is the structural cause of the degeneracy and which reproduces the observed post-filter support edge $u \approx 0.114$. The exact discrete threshold is bracketed by the same two quadratic irrationalities, and a discrete–continuum bridge shows the integer count differs from the continuum prediction by at most $2$ positions, or $3/s$ in normalised fraction — invisible at $96$ bits, where $s \ge 2^{47}$.

Finally we show that position and bit-length are *not* interchangeable stratifications across moduli: explicit $96$-bit witnesses exhibit a full-size residue at $u = 0.15$ for one modulus and a sub-$2^{95}$ residue at $u = 0.20$ for another. Combined with the refit of the empirical data — the edge weight drops from $0.0794$ to $0.0403$ with a confidence interval excluding zero — the conclusion is that the observed spike conflates two distinct objects: a magnitude-driven inclusion channel and a residual, genuine excess among full-size residues. Any positional-shape model for Fermat windows must therefore be stratified by bit-length band as well as by position.

**Keywords:** Fermat factorisation, quadratic residue window, smoothness, bit-length bands, integer square root, crossing curve, degenerate exclusion criterion.

---

## 1. Introduction

### 1.1 The Fermat window

Let $N$ be a positive integer to be factored and put $s = \lfloor\sqrt N\rfloor$. Fermat's method examines the integers $j > s$ and the associated residues

$$v(j) := j^2 - N \ \ (>0 \text{ for } j > s),$$

seeking $j$ with $v(j)$ a perfect square, which yields $N = (j - \sqrt{v(j)})(j + \sqrt{v(j)})$. In modern congruence-of-squares algorithms the perfect-square condition is relaxed: one collects positions $j$ whose residue $v(j)$ is **$B$-smooth** (all prime factors at most $B$) and combines them by linear algebra over $\mathbb F_2$. The distribution of such "hits" inside a scan window is therefore of direct algorithmic interest.

We fix throughout the **window**

$$W(N) := \{\, j \in \mathbb Z : s < j \le 3s \,\}, \qquad |W(N)| = 2s,$$

and the **normalised position**

$$u(j) := \frac{j-s}{2s} \in (0,1].$$

### 1.2 The empirical spike and the control that failed

A scan across $128$ moduli of $96$ bits, with $9594$ recorded smooth hits, showed a marked left-edge excess: the first decile $u < 0.1$ carried $\approx 8.6\%$ of the mass. A two-component fit (broad bulk plus a half-Gaussian edge component, $50$ equal-width position bins, Poisson bin likelihood, cluster bootstrap over moduli) assigned the edge component weight

$$w_{\text{edge}} = 0.0794 \quad [0.0702,\, 0.0908],$$

with a decisive model-selection margin over the bulk-only model.

Because residues at the left edge are numerically small, and small integers are far likelier to be smooth than large ones, the natural control is to restrict attention to *full-size* residues, $v \ge 2^{95}$, and refit. On the full dataset that filter retained $7221$ of the $9594$ hits; the refitted edge weight was

$$w_{\text{edge}} = 0.0403 \quad [0.0301,\, 0.0525],$$

still with a decisive margin and a confidence interval excluding zero.

The subject of this paper is a structural fact about the filter itself, discovered while auditing the control: within the region the control was meant to probe — the first decile — it removes everything. The empirical band table records the same fact: among the $7221$ full-size hits, *zero* lie in the first decile. This is not a property of the sample. It is a theorem about parabolas.

### 1.3 Results

Throughout, $\operatorname{bitlen}(v)$ denotes the number of binary digits of $v$, i.e. the least $b$ with $v < 2^b$.

1. **Degeneracy (Theorem 3.3).** For $2^{95} \le N < 2^{96}$ and $j$ in the first decile, $v(j) < 2^{95}$, i.e. $\operatorname{bitlen} v(j) \le 95$. Set-theoretically (Theorem 3.6), the filtered first decile is empty.
2. **Scale-freeness (Theorem 3.2, Corollary 3.4).** For every $N \ge 2^{16}$ and every first-decile $j$: $100\,v(j) < 45N$, hence $2v(j) < N$, hence $\operatorname{bitlen} v(j) < \operatorname{bitlen} N$.
3. **Necessity of the size hypothesis (Proposition 3.5).** $N = 36482$ and $N = 962$ are explicit counterexamples to (2) without a lower bound on $N$.
4. **Non-triviality (Theorem 3.7).** For $2^{95}\le N<2^{96}$ and $100 j \ge 142 s$ (i.e. $u \gtrsim 0.21$), $v(j) \ge 2^{95}$. The filter annihilates the left edge only.
5. **Exact band geometry (Section 4).** $v$ is strictly increasing; $v(j) < T \iff j \le \lfloor\sqrt{N+T-1}\rfloor$; the sub-$T$ population is $\min(3s,\lfloor\sqrt{N+T-1}\rfloor)-s$; the bit-length histogram telescopes into differences of integer square roots. For $96$-bit moduli the excluded band occupies $11\%$–$21\%$ of the window.
6. **Continuum crossing curve (Section 5).** $u_0(N) = (\sqrt{1+2^{95}/N}-1)/2$ characterises the transition exactly, is strictly decreasing, and lies in $\big((\sqrt6-2)/4,(\sqrt2-1)/2\big]$. Consequently $0.1 < u_0(N)$ always, and the phase transition of the exclusion criterion in the cut-off parameter is sharp.
7. **Sharp discrete constants (Section 6).** Degeneracy holds up to $u \le 0.1123$; it fails at some $96$-bit modulus by $u \le 0.2072$. The exact discrete threshold is bracketed by the two continuum endpoints.
8. **Discrete–continuum bridge (Section 7).** The integer excluded count differs from the continuum length by at most $2$; the normalised fractions differ by at most $3/s$.
9. **Two stratifications (Section 8).** Within a modulus, position and band coincide; across moduli they decouple, with explicit $96$-bit witnesses at $u = 0.15$ and $u = 0.20$.

---

## 2. Notation and basic facts

Let $N \ge 1$ and $s = \lfloor \sqrt N\rfloor$, so $s^2 \le N < (s+1)^2$.

**Definition 2.1 (Residue).** For $j \in \mathbb N$, $v(j) = v_N(j) := j^2 - N$ (understood as $0$ when $j^2 < N$; all statements below assume $j > s$, where $v(j) > 0$).

**Definition 2.2 (Window).** $j$ lies *in the window* if $s < j \le 3s$.

**Definition 2.3 (First decile).** We use the slack integer form employed in the experiment: $j$ lies in the **first decile** $D_1(N)$ if
$$s < j \quad\text{and}\quad 5(j - s) < s + 5,$$
i.e. $\delta := j-s$ satisfies $\delta < 0.2\,s + 1$. Since the window has width $2s$, this is $u(j) \lesssim 1/10$.

**Lemma 2.4 (Positivity).** If $s < j$ then $N < j^2$, hence $v(j) > 0$.

*Proof.* $N < (s+1)^2 \le j^2$. $\square$

The following elementary expansion is used repeatedly. Writing $j = s+\delta$,

$$v(j) = (s+\delta)^2 - N = s^2 + 2s\delta + \delta^2 - N \le 2s\delta + \delta^2, \tag{2.1}$$

because $s^2 \le N$. Inequality (2.1) is the entire engine of Section 3: on the left edge, $\delta$ is a small multiple of $s$, so $v$ is a small multiple of $s^2 \le N$.

---

## 3. Degeneracy of the exclusion criterion

### 3.1 The core arithmetic bound

**Lemma 3.1 (Core bound).** For every $N$ and every $j \in D_1(N)$,
$$25\, v(j) \ \le\ 11\,N + 48\,s + 16 .$$

*Proof.* With $\delta = j-s$ the decile condition gives $5\delta \le s+4$. By (2.1), $25 v(j) \le 25(2s\delta + \delta^2) = 2 s (5\delta)\cdot 5 + (5\delta)^2 \le 10s(s+4) + (s+4)^2 = 11 s^2 + 48 s + 16$. Since $s^2 \le N$, the claim follows. $\square$

The leading constant $11/25 = 0.44$ is exactly $(1+0.2)^2 - 1$, the continuum value at $u = 0.1$.

**Theorem 3.2 (Scale-free degeneracy).** For every modulus $N \ge 2^{16}$ and every $j \in D_1(N)$,
$$100\, v(j) \ <\ 45\, N .$$

*Proof.* From $N \ge 2^{16}$ we get $s \ge 2^8 = 256$, hence $256\, s \le s^2 \le N$, and therefore $192 s + 64 < N$ (using $N \ge 65536$). Multiplying Lemma 3.1 by $4$ gives $100 v \le 44N + 192 s + 64 < 44N + N = 45N$. $\square$

**Theorem 3.3 (Degeneracy at $96$ bits).** Let $2^{95} \le N < 2^{96}$ and $j \in D_1(N)$. Then $v(j) < 2^{95}$.

*Proof.* $N \ge 2^{95} \ge 2^{16}$, so $100 v < 45 N < 45 \cdot 2^{96} = 90 \cdot 2^{95} < 100\cdot 2^{95}$. $\square$

**Corollary 3.4 (Bit drop).** (i) If $N \ge 2^{16}$ and $j \in D_1(N)$ then $2v(j) < N$ and hence $\operatorname{bitlen} v(j) < \operatorname{bitlen} N$. (ii) If moreover $2^{95}\le N<2^{96}$ then $\operatorname{bitlen} v(j) \le 95$.

*Proof.* (i) $100v < 45N < 50N$. For the bit-length claim, let $\beta = \operatorname{bitlen} N \ge 1$; then $N < 2^{\beta} = 2\cdot 2^{\beta-1}$, so $2v < 2\cdot 2^{\beta-1}$, i.e. $v < 2^{\beta-1}$, i.e. $\operatorname{bitlen} v \le \beta - 1$. (ii) is Theorem 3.3. $\square$

### 3.2 The size hypotheses are necessary

**Proposition 3.5 (Counterexamples).**
1. $N = 36482$, $s = 191$, $j = 230$: $j \in D_1(N)$ (indeed $5\cdot 39 = 195 < 196 = s+5$) and $v(j) = 52900 - 36482 = 16418$, while $0.45N = 16416.9$; thus $45N \le 100 v$. So Theorem 3.2 fails without $N \ge 2^{16}$.
2. $N = 962$, $s = 31$, $j = 38$: $j \in D_1(N)$ ($5\cdot 7 = 35 < 36 = s+5$) and $v(j) = 1444 - 962 = 482$, while $N/2 = 481$; thus $N \le 2 v(j)$. So even the weaker "loses one bit" statement of Corollary 3.4(i) fails without a size hypothesis.

An exhaustive scan indicates $N = 36482$ is the largest modulus violating $100v < 45N$ and $N = 962$ the largest violating $2v < N$; the hypothesis $N \ge 2^{16}$ is thus nearly sharp for the first and generous for the second.

### 3.3 Set-level form: "fraction removed $=1$"

**Theorem 3.6 (The filtered first decile is empty).** For $2^{95}\le N<2^{96}$,
$$\big\{\, j \in [s+1,\,3s] \ :\ 5(j-s) < s+5 \ \text{ and } \ v(j)\ge 2^{95} \,\big\} \ =\ \varnothing .$$

*Proof.* Immediate from Theorem 3.3. $\square$

Thus the removed fraction of first-decile mass is exactly $1$, for every $96$-bit modulus and every dataset; the criterion carries no discriminatory information there.

### 3.4 The criterion is not globally trivial

**Theorem 3.7 (Full-size tail).** Let $2^{95}\le N<2^{96}$ and suppose $142\,s \le 100\,j$ (i.e. $j \ge 1.42 s$, equivalently $u \ge 0.21$). Then $v(j) \ge 2^{95}$.

*Proof sketch.* From $100j \ge 142 s$, $10^4 j^2 \ge 20164\, s^2$. Also $N \le s^2 + 2s$ and $s \le 2^{48}$ (since $N < 2^{96}$). Hence
$$10^4\big(j^2 - N\big) \ \ge\ 20164\,s^2 - 10^4 N \ \ge\ 10164\,N - 40328\,s ,$$
using $s^2 \ge N - 2s$. Finally $40328\cdot 2^{48} \le 164 \cdot 2^{95}$ and $N \ge 2^{95}$ give $10164 N - 40328 s \ge 10^4\cdot 2^{95}$. $\square$

So the window splits (for $96$-bit moduli) into a provably tiny prefix $u \lesssim 0.1123$ and a provably full-size tail $u \ge 0.21$; the criterion is degenerate exactly on the left edge.

---

## 4. Exact band geometry

### 4.1 Monotonicity and positional intervals

**Theorem 4.1 (Strict monotonicity).** If $s < j_1 < j_2$ then $v(j_1) < v(j_2)$.

*Proof.* $j_1^2 < j_2^2$ and $N < j_1^2$, so $j_1^2 - N < j_2^2 - N$. $\square$

**Theorem 4.2 (Band = positional cut).** For $T \ge 1$ and $j > s$,
$$v(j) < T \iff j \le \big\lfloor \sqrt{N + T - 1} \,\big\rfloor .$$

*Proof.* $v(j) < T \iff j^2 \le N + T - 1 \iff j \le \lfloor\sqrt{N+T-1}\rfloor$, the last step being the defining property of the integer square root. $\square$

**Corollary 4.3 (The excluded set is a left-edge interval).** For $T \ge 1$,
$$\{\, j \in (s,3s] : v(j) < T \,\} \ =\ \big(s,\ \min(3s,\ \lfloor\sqrt{N+T-1}\rfloor)\,\big] ,$$
whose cardinality is
$$\#\{\, j \in (s,3s] : v(j)<T \,\} \ =\ \min\!\big(3s,\ \lfloor\sqrt{N+T-1}\rfloor\big) - s . \tag{4.1}$$

Formula (4.1) is exact and involves no probabilistic input whatsoever.

**Proposition 4.4 (How small the channel gets).** $v(s+1) \le 2s + 1 \le 2\sqrt N + 1$.

*Proof.* $(s+1)^2 = s^2 + 2s + 1 \le N + 2s + 1$. $\square$

So the extreme left of the window realises residues of about half the bit-length of $N$ — roughly $2^{49}$ for a $96$-bit modulus. This is the arithmetic mechanism behind the inclusion channel: such numbers are smooth vastly more often than full-size draws.

### 4.2 The deterministic band histogram

Let $C_{\le b}(N) := \#\{ j \in (s,3s] : \operatorname{bitlen} v(j) \le b \}$.

**Theorem 4.5 (Cumulative counts).** $C_{\le b}(N) = \min\big(3s, \lfloor\sqrt{N+2^b-1}\rfloor\big) - s$.

*Proof.* $\operatorname{bitlen} v \le b \iff v < 2^b$; apply (4.1) with $T = 2^b$. $\square$

**Theorem 4.6 (Telescoping / exact band populations).** For every $b$,
$$\#\{ j \in (s,3s] : \operatorname{bitlen} v(j) = b+1\} \;=\; C_{\le b+1}(N) - C_{\le b}(N),$$
so that the band population equals
$$\min\!\big(3s,\lfloor\sqrt{N+2^{b+1}-1}\rfloor\big) \; - \; \min\!\big(3s,\lfloor\sqrt{N+2^{b}-1}\rfloor\big).$$

*Proof.* The sets $\{\operatorname{bitlen} v \le b\}$ and $\{\operatorname{bitlen} v = b+1\}$ are disjoint with union $\{\operatorname{bitlen} v \le b+1\}$; combine with Theorem 4.5. $\square$

**Remark 4.7.** The bit-length histogram of a Fermat window is therefore a *deterministic function of $N$ alone*: a telescoping sequence of differences of integer square roots. Any apparent "band distribution" in a hit sample is the composition of this fixed geometric profile with the smoothness process — never an independent random object.

### 4.3 Quantitative degeneracy at $96$ bits

Write $m := \lfloor\sqrt{N + 2^{95}-1}\rfloor$ for the cut point at threshold $T = 2^{95}$.

**Lemma 4.8 (The cut lies inside the window).** For $2^{95}\le N<2^{96}$, $m \le 3s$.

*Proof.* $N + 2^{95} - 1 \le 2N \le 2(s^2+2s) < (3s+1)^2$ for $s \ge 1$. $\square$

**Theorem 4.9 (Lower bound: the excluded interval strictly contains the first decile).** For $2^{95}\le N < 2^{96}$,
$$m - s \ \ge\ 0.22\, s, \qquad\text{i.e.}\qquad 11 s \le 50\,\#\{j \in (s,3s] : v(j)<2^{95}\}.$$

*Proof sketch.* Put $k = \lceil 1.22\, s\rceil$. Then $2500\,k^2 \le (61 s + 49)^2 = 3721 s^2 + 5978 s + 2401$. Since $2^{95} \ge N/2$ and $s^2 \le N$, one checks $3721 s^2 + 5978 s + 2401 \le 2500 (N + 2^{95}-1)$, using $s \ge 2^{47}$ to absorb the linear terms. Hence $k \le \lfloor\sqrt{N+2^{95}-1}\rfloor = m$. Combine with (4.1) and Lemma 4.8. $\square$

Since the first decile has width at most $0.2 s + 1$, the excluded interval contains it with a margin of at least $0.02\,s$ positions — about $2^{45}$ positions at $96$ bits.

**Theorem 4.10 (Upper bound on the cut).** For $2^{95}\le N<2^{96}$, $100\,m \le 142\,s$.

*Proof sketch.* With $k = \lfloor 1.42 s\rfloor$ one has $142 s < 100(k+1)$, whence $(k+1)^2 > 2(s^2+2s+1) \ge 2N \ge N + 2^{95}$, so $m < k+1$. $\square$

**Theorem 4.11 (Window fraction of the tiny channel).** For every $96$-bit modulus,
$$0.11 \ \le\ \frac{\#\{ j \in (s,3s] : v(j)<2^{95}\}}{2s} \ \le\ 0.21 .$$

*Proof.* Combine (4.1), Lemma 4.8, Theorem 4.9 and Theorem 4.10. $\square$

This is the discrete counterpart of the continuum interval derived next.

---

## 5. The continuum crossing curve

In the continuum approximation $j \approx s(1+2u)$, $s \approx \sqrt N$, so $v \approx \big((1+2u)^2-1\big)N$.

**Definition 5.1 (Crossing position).** For $N > 0$,
$$u_0(N) := \frac{\sqrt{1 + 2^{95}/N} - 1}{2}.$$

**Theorem 5.2 (Exact characterisation).** For $N > 0$ and $u \ge 0$,
$$\big((1+2u)^2 - 1\big)N \ \ge\ 2^{95} \iff u \ \ge\ u_0(N).$$

*Proof.* $\big((1+2u)^2-1\big)N \ge 2^{95} \iff (1+2u)^2 \ge 1 + 2^{95}/N \iff 1+2u \ge \sqrt{1+2^{95}/N}$ (both sides nonnegative) $\iff u \ge u_0(N)$. $\square$

**Theorem 5.3 (Monotonicity).** If $0 < N_1 < N_2$ then $u_0(N_2) < u_0(N_1)$: larger moduli expose full-size residues earlier in the window.

*Proof.* $N \mapsto 2^{95}/N$ is strictly decreasing on $(0,\infty)$ and $\sqrt{\cdot}$ is strictly increasing. $\square$

**Theorem 5.4 (Sharp interval).** For $2^{95} \le N < 2^{96}$,
$$\frac{\sqrt6-2}{4} \;<\; u_0(N) \;\le\; \frac{\sqrt2-1}{2},$$
numerically $0.11237\ldots < u_0(N) \le 0.20711\ldots$.

*Proof.* Upper: $N \ge 2^{95}$ gives $2^{95}/N \le 1$, so $u_0(N) \le (\sqrt2-1)/2$. Lower: $N < 2^{96}$ gives $2^{95}/N > 1/2$, so $u_0(N) > (\sqrt{3/2}-1)/2 = (\sqrt6/2 - 1)/2 = (\sqrt6-2)/4$. $\square$

**Corollary 5.5 (Structural cause of the degeneracy).** For every $N$ with $0 < N < 2^{96}$,
$$\tfrac1{10} \;<\; u_0(N).$$
Indeed $2.4 < \sqrt6$ gives $(\sqrt6-2)/4 > 0.1$.

Thus no full-size residue can occur in the first decile of a $96$-bit modulus — the continuum explanation of Theorem 3.3 — and the *observed* left edge of the post-filter support, $u \approx 0.114$, is not an empirical accident but the value $(\sqrt6-2)/4 = 0.11237\ldots$ attained (in the limit) at the top of the $96$-bit range.

**Theorem 5.6 (Phase transition in the cut-off).** Let $c \in \mathbb R$ be a candidate positional cut-off.
1. If $c \le (\sqrt6-2)/4$, then for every $N \in (0, 2^{96})$ and every $u \in [0,c)$ one has $\big((1+2u)^2-1\big)N < 2^{95}$: the exclusion criterion is degenerate for all $96$-bit moduli.
2. If $c > (\sqrt2-1)/2$, then for every $N \ge 2^{95}$ there exists $u \in [0,c)$ with $\big((1+2u)^2-1\big)N \ge 2^{95}$: the criterion is informative for all $96$-bit moduli.

Consequently the transition window is exactly $\big((\sqrt6-2)/4,\ (\sqrt2-1)/2\big]$, and the experimental cut-off $c = 0.1$ lies strictly inside the degenerate regime.

*Proof.* (1) If some $u < c \le (\sqrt6-2)/4$ satisfied the inequality, Theorem 5.2 would give $u \ge u_0(N) > (\sqrt6-2)/4$ by Theorem 5.4 — contradiction. (2) Take $u = (\sqrt2-1)/2 \ge u_0(N)$ (Theorem 5.4) and apply Theorem 5.2; $u < c$ by hypothesis. $\square$

---

## 6. Sharp discrete constants

Theorem 3.3 establishes degeneracy for $u \lesssim 0.1$. The continuum analysis says the true universal constant is at most $(\sqrt2-1)/2$ and at least $(\sqrt6-2)/4$. Both bounds are attained in the discrete setting up to four decimal places.

**Theorem 6.1 (Sharp degeneracy, $u \le 0.1123$).** Let $2^{95}\le N<2^{96}$, $j > s$, and suppose
$$10^4 (j - s) \ \le\ 2246\, s \qquad (\text{i.e. } u \le 0.1123).$$
Then $v(j) < 2^{95}$.

*Proof sketch.* With $\delta = j-s$ and $10^4 \delta \le 2246 s$, expansion (2.1) gives
$$10^8\big(2 s\delta + \delta^2\big) \le \big(2\cdot 2246 \cdot 10^4 + 2246^2\big) s^2 = 49\,964\,516\, s^2 \le 49\,964\,516\,N,$$
so $10^8 v(j) \le 0.49964516 \cdot 10^8 N < \tfrac12\cdot 10^8 N$, and $N < 2^{96} = 2\cdot 2^{95}$ finishes. $\square$

**Theorem 6.2 (Failure beyond $u = 0.2072$).** There exist $N$ with $2^{95}\le N<2^{96}$ and $j$ in the window with $u(j) \le 0.2072$ and $v(j) \ge 2^{95}$. An explicit witness is
$$N = 199032864766431^2 = 39614081257132410564184477761, \qquad j = 281512083925640,$$
for which $s = 199032864766431$, $u(j) = 0.20720\ldots$ and $v(j) = 79249053396156578873049409600 - N \ge 2^{95}$.

**Corollary 6.3 (Bracketing).** Let $c^\star$ denote the supremum of cut-offs $c$ such that "$u(j)\le c \Rightarrow v(j) < 2^{95}$" holds for all $96$-bit moduli. Then
$$0.1123 \ \le\ c^\star \ \le\ 0.2072,$$
matching the continuum endpoints $(\sqrt6-2)/4 = 0.11237\ldots$ and $(\sqrt2-1)/2 = 0.20711\ldots$ to four decimals.

Note that $c^\star$ *equals* the continuum lower endpoint up to discretisation: the infimum of $u_0(N)$ over $96$-bit $N$ is $(\sqrt6-2)/4$, approached as $N \uparrow 2^{96}$, while $\sup_N u_0(N) = (\sqrt2-1)/2$ is attained at $N = 2^{95}$ and is the reason the criterion becomes informative only past $0.2072$ for *some* moduli.

---

## 7. Discrete–continuum bridge

The exact excluded count is $m - s$ with $m = \lfloor\sqrt{N+2^{95}-1}\rfloor$ (Corollary 4.3, Lemma 4.8); the continuum model predicts a length $\sqrt{N+2^{95}} - \sqrt N$ and a fraction $u_0(N)$. These agree to within an absolute constant.

**Theorem 7.1 (Count bridge).** For every $N \ge 1$,
$$\Big| \big(m - s\big) - \big(\sqrt{N+2^{95}} - \sqrt N\big) \Big| \ \le\ 2 .$$

*Proof sketch.* $m \le \sqrt{N+2^{95}-1} < m+1$ and $s \le \sqrt N < s+1$, together with $\sqrt{x} \le \sqrt{x-1}+1$ for $x \ge 1$. Each of the four comparisons costs at most $1$; the stated bound follows after cancellation. $\square$

**Theorem 7.2 (Fraction bridge).** For $N \ge 2^{95}$,
$$\left| \frac{m-s}{2s} - u_0(N) \right| \ \le\ \frac{3}{s}.$$

*Proof sketch.* Write $A = \sqrt N$, $B = \sqrt{N+2^{95}}$ and use $u_0(N) = (B-A)/(2A)$ (an identity obtained from Definition 5.1 by $\sqrt{1+2^{95}/N} = B/A$). Then
$$\frac{m-s}{2s} - \frac{B-A}{2A} \;=\; \frac{(m-s)-(B-A)}{2s} \;+\; \frac{(B-A)(A-s)}{2sA}.$$
The first term is at most $1/s$ in absolute value by Theorem 7.1; for the second, $0 \le A - s < 1$ and $B - A \le A$ (since $2^{95}\le N$ implies $B \le 2A$), giving a bound of $1/s$. Hence the total is at most $2/s \le 3/s$. $\square$

**Remark 7.3.** For a $96$-bit modulus $s \ge 2^{47} \approx 1.4\times 10^{14}$, so $3/s \approx 2\times 10^{-14}$: the discrete and continuum excluded fractions coincide to about fourteen decimal digits. Discretisation can never account for a discrepancy in a fitted edge weight.

---

## 8. Position and bit-length are two stratifications

Within a *single* modulus, Theorem 4.1 says the bit-length band of a residue is a strictly increasing function of the position; the two stratifications coincide. Across moduli they do not, and the failure is not marginal: it happens well inside the window.

**Theorem 8.1 (Full-size witness at $u = 0.15$).** Let
$$N_1 = (2^{48}-1)^2 = 79228162514263774643590529025, \qquad j_1 = 365917469723851.$$
Then $2^{95} \le N_1 < 2^{96}$, $s_1 = 2^{48}-1$, $j_1$ is in the window, $u(j_1) = 0.15000\ldots \le 0.15$, and
$$v(j_1) = 54667432134841638586607741176 \ \ge\ 2^{95} = 39614081257132168796771975168 .$$

**Theorem 8.2 (Tiny witness at $u = 0.20$).** Let
$$N_2 = 199032864766431^2 = 39614081257132410564184477761, \qquad j_2 = 278646010673003 .$$
Then $2^{95} \le N_2 < 2^{96}$, $s_2 = 199032864766431$, $j_2$ is in the window, $u(j_2) = 0.2 \ge 0.15$, and
$$v(j_2) = 38029518006846891224808560248 \ <\ 2^{95}.$$

Both are verified by direct integer arithmetic: $j_1^2 = 133895594649105413230198270201$ and $j_2^2 = 77643599263979301788993038009$.

**Corollary 8.3 (No universal positional surrogate).** There is no cut-off $c \in [0.15, 0.20]$ such that, uniformly over $96$-bit moduli, "$u \le c$" is equivalent to "$v < 2^{95}$": modulus $N_1$ already violates the forward implication at $u = 0.15$, and modulus $N_2$ violates the converse at $u = 0.20$.

The witnesses are the extremal moduli predicted by Theorem 5.4: $N_1$ sits just below $2^{96}$, where $u_0 \approx 0.11237$, so full-size residues begin early; $N_2$ sits just above $2^{95}$, where $u_0 \approx 0.20711$, so tiny residues persist late.

**Theorem 8.4 (Synthesis: the spike is not one object).** For $96$-bit moduli the window decomposes into
1. a **provably tiny prefix**: every first-decile position has $\operatorname{bitlen} v \le 95$ (Theorem 3.3);
2. a **provably full-size tail**: every position with $u \ge 0.21$ has $\operatorname{bitlen} v \ge 96$ (Theorem 3.7);
3. a **modulus-dependent middle**: both behaviours occur at the same normalised position, for different moduli (Theorems 8.1–8.2).

Consequently the position statistic and the bit-length band are independent stratifications of the window across the modulus ensemble, and a "$v \ge 2^{95}$" cut is a *geometric* operation on the left edge, not a data-driven one.

---

## 9. Algorithms

The results above are effective, and each one corresponds to a short, exact computation. We record the three that matter in practice; all arithmetic is exact integer arithmetic, and no floating point is required except where noted.

### 9.1 Exact band histogram of a Fermat window

**Input:** modulus $N$, maximal bit-length $B$.
**Output:** the exact vector $\big(\#\{j\in(s,3s]:\operatorname{bitlen} v(j)=b\}\big)_{b\le B}$.

By Theorems 4.5–4.6 it suffices to evaluate $C_{\le b} = \min(3s, \lfloor\sqrt{N+2^b-1}\rfloor) - s$ for each $b$ and difference the result. Each step is one integer square root of an $O(\log N)$-bit number, so the total cost is $O(B\, M(\log N))$ where $M$ is the multiplication cost — a few microseconds at $96$ bits, and the answer is *exact*, with no sampling error. Note that this replaces what would otherwise be an $O(s)$ scan over $2s \approx 2^{48}$ positions by $B$ square roots.

### 9.2 Degeneracy audit of an exclusion criterion

**Input:** modulus $N$, residue threshold $T$, positional cut-off $c \in (0,1]$.
**Output:** the exact fraction of the region $\{u \le c\}$ removed by the filter $v \ge T$.

Compute $m = \min(3s, \lfloor\sqrt{N+T-1}\rfloor)$, the last position with $v < T$, and $p = s + \lfloor 2sc \rfloor$, the last position with $u \le c$. The removed fraction is $\big(\min(m,p)-s\big)/(p-s)$. It equals $1$ — the criterion is degenerate on that region — precisely when $p \le m$. This is the exact test that Theorem 3.6 shows returns $1$ for $T = 2^{95}$, $c = 0.1$ and every $96$-bit $N$. Cost: one integer square root.

### 9.3 Crossing-curve bracket for an ensemble

**Input:** a bit-length $\beta$ (so $N$ ranges over $[2^{\beta-1}, 2^{\beta})$) and a threshold $T$.
**Output:** the interval of crossing positions over the ensemble.

By Theorems 5.3–5.4 the crossing curve $u_0(N) = (\sqrt{1+T/N}-1)/2$ is strictly decreasing, so its range over $[2^{\beta-1}, 2^\beta)$ is
$$\Big( \tfrac{\sqrt{1+T/2^{\beta}}-1}{2}, \ \tfrac{\sqrt{1+T/2^{\beta-1}}-1}{2} \Big].$$
For $T = 2^{\beta-1}$ this is exactly $\big((\sqrt6-2)/4, (\sqrt2-1)/2\big]$, independent of $\beta$ — the interval is a universal constant of the construction, not a feature of $96$ bits. Any positional cut-off below the left endpoint is degenerate for the whole ensemble; any cut-off above the right endpoint is informative for the whole ensemble.

---

## 10. Consequences for empirical studies of Fermat windows

**(a) The reported control was uninformative in the region it targeted.** The "keep $v \ge 2^{95}$" clause removes $100\%$ of first-decile mass by Theorem 3.6, so it cannot discriminate "the spike is a magnitude artifact" from "the spike is genuine structure" inside the first decile. The empirical band table is consistent to the digit: zero of the $7221$ full-size hits and zero of the $426525$ full-size controls lie in the first decile.

**(b) The surviving signal is real but relocated.** Refitting on the full-size subpopulation yields an edge weight $0.0403$ with confidence interval $[0.0301, 0.0525]$, measured at the surviving population's own support edge $u \approx 0.11$ — which Corollary 5.5 identifies as $(\sqrt6-2)/4$ rather than a data-dependent quantity. The interval excludes zero, so an edge component persists among full-size residues. The honest reading of the drop $0.0794 \to 0.0403$ is a split: roughly half the original spike weight is a tiny-residue inclusion channel (residues as small as $2\sqrt N \approx 2^{50}$ by Proposition 4.4, which are smooth far more often than full-size draws), and roughly half is an excess among full-size residues not explained by magnitude.

**(c) Band mass is geometry, not statistics.** The observed hit mass by band ($0$ below $80$ bits, $0.0089$ in $80$–$89$, $0.2385$ in $90$–$95$, $0.7527$ at $\ge 96$) should be read against the *deterministic* band profile of Theorem 4.6, which for each modulus is a fixed vector of differences of integer square roots. Only the ratio of observed to geometric mass carries information about smoothness.

**(d) Any future positional-shape model needs two indices.** By Theorem 8.4 the position and the band are the same stratification within a modulus but not across the ensemble. A model indexed by $u$ alone will therefore absorb an uncontrolled mixture of magnitude effects at the left edge; the fix is to stratify by $\operatorname{bitlen} v$ as well, which is cheap because the strata are computable exactly by §9.1.

**(e) Discretisation is not an available excuse.** Theorem 7.2 pins the discrete excluded fraction to the continuum crossing position within $3/s \approx 2\times10^{-14}$ at $96$ bits.

---

## 11. Discussion

The episode analysed here has a general moral for the statistics of arithmetic objects. The quantity being controlled for — residue magnitude — and the quantity being measured — position in the window — were not independent variables but, within each modulus, the *same* variable in two coordinates, related by the strictly increasing map $j \mapsto j^2 - N$. A control that conditions on one while measuring the other is then not a weak control; it is an empty one on the region of interest.

What makes the situation recoverable is that the coupling is exactly computable. The window's band structure is a telescoping sequence of integer square roots; the crossing point between tiny and full-size residues is a single explicit algebraic function of $N$; and across a bit-level ensemble that function sweeps a fixed interval bounded by two quadratic irrationalities. Everything an analyst needs to disentangle magnitude from position is available in closed form, before any data is collected.

Three limitations should be stated plainly. First, the theorems concern the *geometry* of the window — the sizes of the residues and the populations of the bands — not the smoothness process itself; the persistence of an edge component among full-size residues is an empirical statement supported by the refit, not a theorem. Second, the empirical numbers quoted here (edge weights, band masses, confidence intervals) come from one experimental design — a fifty-bin Poisson fit with a half-Gaussian edge component and a bootstrap clustered over moduli — and amplitudes from a differently parametrised fit are not numerically comparable; the internal comparison $0.0794 \to 0.0403$ is the meaningful one. Third, the control population used for the reference shape was a capped set of non-hit positions per modulus, which is a position-uniform reference and not a smoothness-matched one.

Within those limits, the mathematical conclusion is unambiguous and unconditional: the left-edge spike of a Fermat window is not a single object, and no positional statistic can be interpreted without simultaneously fixing the bit-length band.

---

## 12. Future directions

### 12.1 Sharpening what is already here

- **Determine $c^\star$ exactly.** Corollary 6.3 brackets the universal discrete degeneracy constant in $[0.1123, 0.2072]$. The continuum analysis suggests the correct statement is a *family* of constants: for each $\beta$-bit ensemble with threshold $T$, degeneracy holds below $\inf_N u_0(N)$ and fails above $\sup_N u_0(N)$, and one should be able to prove the discrete constant equals the continuum infimum up to $O(1/s)$ by feeding Theorem 7.2 back into the argument.
- **General thresholds and general windows.** All results are stated for $T = 2^{\beta-1}$ and the window $(s, 3s]$. The proofs use only $s^2 \le N$ and the width of the window; the natural generalisation is a two-parameter family indexed by the ratio $T/N$ and the window multiplier, in which $\big((\sqrt6-2)/4, (\sqrt2-1)/2\big]$ becomes one fibre.
- **Second-order band profile.** Theorem 4.6 gives band populations exactly. Expanding the integer square roots asymptotically should yield the band profile as a smooth density in $u$ plus an explicitly bounded lattice error, giving the exact "geometric null" against which observed band masses ought to be normalised.

### 12.2 Testable conjectures about the surviving signal

- **The residual edge excess is a genuine smoothness effect, and it should scale.** If the full-size edge component with weight $\approx 0.04$ is real, its magnitude should vary predictably with the modulus bit-length and the smoothness bound, since the standard heuristic density of smooth numbers depends on both. A scan at $80$ and $112$ bits with the same design would either exhibit the predicted drift or refute the effect.
- **Band-stratified refit.** Fitting an edge weight separately in each bit-length band ($90$–$95$, $\ge 96$) should reveal a monotone decay of the edge component with band index if the effect is magnitude-driven, and a flat profile if it is genuinely positional. This is the single most informative follow-up, and it is cheap given §9.1.
- **Crossing-curve stratification as a design principle.** Because $u_0(N)$ is strictly decreasing, moduli can be sorted by $u_0$ and the analysis run in the *rescaled* coordinate $u/u_0(N)$, in which the tiny/full-size boundary is at $1$ for every modulus. Any residual edge structure surviving that reparametrisation is, by construction, free of the magnitude channel.

### 12.3 From the original programme

The three cycles of work behind this paper replaced the informal claim "the left-edge spike is partly a tiny-$v$ inclusion artifact" by exact theorems about the window $j \in (s,3s]$, $v = j^2-N$, $u = (j-s)/(2s)$.

*Cycle 1 — degeneracy is arithmetic, not statistical.* For every $96$-bit $N$, every first-decile point has $v < 2^{95}$, via the scale-free inequality $100v < 45N$, which forces $\operatorname{bitlen} v < \operatorname{bitlen} N$ at every scale. The $v \ge 2^{95}$ filter therefore removes $100\%$ of the first-decile mass, while past $u = 0.21$ every residue is full size. In the continuum the crossing curve is $u_0(N) = (\sqrt{1+2^{95}/N}-1)/2$, strictly decreasing in $N$ and confined to $\big((\sqrt6-2)/4, (\sqrt2-1)/2\big]$; the decile boundary $0.1$ sits strictly below $(\sqrt6-2)/4 = 0.11237\ldots$, which reproduces the reported kept-support left edge $u \approx 0.114$. Both size hypotheses are load-bearing: $N = 36482$ and $N = 962$ are explicit counterexamples without them.

*Cycle 2 — sharp constants and a deterministic histogram.* The degeneracy constant was pushed from $0.1$ to $0.1123$, and shown impossible beyond $0.2072$, so the exact discrete threshold is bracketed by the same two quadratic irrationalities that bound the crossing curve. Since the residue is strictly increasing, bands are positional intervals with exactly $\min(3s, \lfloor\sqrt{N+T-1}\rfloor) - s$ points, the sub-$2^{95}$ band occupies $11$–$21\%$ of the window, and the whole band histogram telescopes into differences of integer square roots — a function of $N$ alone.

*Cycle 3 — discrete meets continuum.* The exact integer count differs from the continuum length by at most $2$, and the normalised fractions by at most $3/s$; at $96$ bits $s \ge 2^{47}$, so discretisation is invisible at any plausible fit precision.

*The synthesis* is that within a single modulus the bit-length band and the position are the *same* stratification, while across moduli they decouple: explicit $96$-bit witnesses give a full-size and a sub-$2^{95}$ residue at essentially the same normalised position. That is the precise sense in which the observed spike conflates two objects.

*Failure analysis.* The tempting universal statement "the exclusion clause is degenerate for all moduli" is false without a size hypothesis, and the naive hope that a positional cut-off could replace a band cut-off uniformly in $N$ is also false — both are now recorded as theorems rather than caveats.

---

## Appendix A. Numerical reference values

| Quantity | Value |
|---|---|
| $2^{95}$ | $39614081257132168796771975168$ |
| $(\sqrt6-2)/4$ | $0.112372435695794\ldots$ |
| $(\sqrt2-1)/2$ | $0.207106781186547\ldots$ |
| $N_1 = (2^{48}-1)^2$ | $79228162514263774643590529025$ |
| $u_0(N_1)$ | $0.11237243569\ldots$ |
| $N_2 = 199032864766431^2$ | $39614081257132410564184477761$ |
| $u_0(N_2)$ | $0.20710678118\ldots$ |
| $s$ for a $96$-bit modulus | $\ge 2^{47} = 140737488355328$ |
| $3/s$ at $96$ bits | $\le 2.14\times10^{-14}$ |

## Appendix B. Summary of the empirical figures referenced

| Statistic | All hits | Full-size hits ($v \ge 2^{95}$) |
|---|---|---|
| Sample size | $9594$ | $7221$ |
| Edge weight $w_{\text{edge}}$ | $0.0794$ | $0.0403$ |
| Confidence interval | $[0.0702, 0.0908]$ | $[0.0301, 0.0525]$ |
| Support left edge | $u = 0$ | $u \approx 0.114$ |

Hit mass by bit-length band: $<80$ bits: $0$; $80$–$89$: $0.0089$; $90$–$95$: $0.2385$; $\ge 96$: $0.7527$. Within-band first-decile fractions: $1.000$ (below $80$), $0.642$ ($80$–$89$), $0.000$ ($\ge 96$).
