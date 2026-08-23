# Separating Temporal Lag from Pitch Interval: A Tropical Theory of Digit Melodies

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

A recurring claim in the popular and semi-technical literature on "digit music" holds that a peak in the autocorrelation of a decimal digit sequence at lag $12$ evidences *octave* structure in the corresponding melody. The claim conflates two independent variables: the **temporal lag**, an element of the additive monoid $\mathbb{N}$ indexing which pairs of positions are compared, and the **pitch interval**, an element of $\{0,\dots,b-1\}$ recording what is heard when a pair is compared. We develop the theory of these two variables for base-$b$ digit melodies and prove that they are separated as completely as two variables can be.

On the pitch side, we introduce the lag-$\ell$ **pitch-interval distribution** $N_x(n,\ell,\cdot)$ and prove: (i) it is a probability-like distribution of total mass $n$ supported on $\{0,\dots,b-1\}$, so that for $b=10$ the octave value $v=12$ has mass zero at every lag, in every window, for every melody; (ii) an **inverse theorem** — every multiplicity function on $\{0,\dots,9\}$ of total mass $n$ is realized as the lag-$1$ interval distribution of an explicit decimal melody, and every lag $\ell \ge 1$ realizes $\ell\cdot N$ on a window of length $\ell n$ — so the temporal parameter constrains nothing about the pitch histogram beyond its support.

On the temporal side, we introduce the **lag spectrum** $M_x(\ell) = \sup_i |x_i - x_{i+\ell}|$ and prove it is a tropical (min-plus) seminorm on the lag monoid: $M_x(k+\ell)\le M_x(k)+M_x(\ell)$. Its kernel is the monoid of unison lags, which we show is closed under greatest common divisors and therefore equals the set of multiples of the minimal period, or $\{0\}$ in the aperiodic case; two coprime periods force constancy.

The two sides are joined by a single scalar. We prove the **moment bridge**: for a cyclic digit melody, $2A(k) = 2E - \sum_v v^2 N_k(v)$, where $A$ is autocorrelation and $E$ is energy. Autocorrelation is therefore exactly the second moment of the lag-$k$ pitch statistic, up to the energy normalization; it is a functional of the interval distribution, and the functional is not injective — we exhibit two four-note decimal melodies with identical energy and identical lag-$1$ autocorrelation but different unison counts. We compute the exact combinatorial null model (the triangular distribution $P_b$ with second moment $(b^4-b^2)/6$) and derive an exact **null deficit law** $12(E - A(k)) = m(b^4 - b^2)$, specializing to $E - A = 825m$ in base ten. Finally we prove that the pairwise interval matrix is idempotent in the min-plus matrix semiring, and that pitch-class reduction modulo $12$ is faithful on any alphabet of size at most $12$ and first fails in base $13$.

**Keywords:** tropical semiring, min-plus algebra, autocorrelation, pitch-interval distribution, digit sequences, periodicity, lag spectrum, layer-cake rearrangement.

---

## 1. Introduction

### 1.1 The conflation

Let $x = (x_0, x_1, x_2, \dots)$ be a sequence of decimal digits — the digits of $\pi$, of $e$, of a physical measurement, of a pseudorandom stream. The standard sonification maps $x_i$ to the $x_i$-th note of a scale, producing a *digit melody*. Two numerical quantities then compete for the name "twelve".

The **temporal lag** $\ell$ is the offset used when comparing positions: the pair $(i, i+\ell)$. It is the parameter of the autocorrelation function
$$A(\ell) \;=\; \sum_i x_i x_{i+\ell},$$
and it lives in the additive monoid $(\mathbb{N},+)$ of offsets.

The **pitch interval** is the perceptual distance between two notes, in semitones: $|x_i - x_j|$. An *octave* is the specific interval value $12$.

The two coincide only in name. A lag-$12$ autocorrelation compares digit positions twelve time steps apart; it does not measure a twelve-semitone interval. Yet the inference "peak at lag $12$ $\Rightarrow$ octave structure" is common enough to deserve a definitive mathematical treatment. This paper provides it, and finds — as often happens when one corrects a conflation — that both variables turn out to be interesting on their own.

### 1.2 Contributions

1. **Support and the vanishing octave.** The lag-$\ell$ interval distribution of a base-$b$ melody is supported on $\{0,\dots,b-1\}$; in base ten the octave value has mass zero at every lag and in every window (§3).
2. **Moment calculus.** Every additive lag statistic is a moment of the interval distribution (§3.3). In particular, autocorrelation is its second moment, via the moment bridge $2A(k) = 2E - \sum_v v^2 N_k(v)$ (§5).
3. **Non-invertibility.** The bridge loses information: explicit melodies with equal energy and equal lag-$1$ autocorrelation but different lag-$1$ interval distributions (§5.3).
4. **Exact null model.** The triangular pair-count distribution, its closed-form second moment $(b^4-b^2)/6$, and the exact null autocorrelation deficit law (§6).
5. **Tropical lag spectrum.** Subadditivity of $M_x$, its interpretation as a min-plus seminorm on the lag monoid, gcd-rigidity of the unison-lag monoid, and the resulting complete dichotomy for lag twelve (§7).
6. **Decoupling / inverse theorem.** Explicit realization of arbitrary interval histograms at arbitrary lags, via layer-cake rearrangement, an alternating walk, and interleaving (§8).
7. **Tropical idempotency of the interval matrix** and the shortest-voice-leading interpretation (§9).
8. **Pitch classes.** Faithfulness of mod-$12$ reduction on alphabets of size $\le 12$, and its sharp failure in base $13$ (§10).

---

## 2. Setting and basic definitions

Throughout, $b \ge 1$ is an alphabet size (the *base*), and a **melody** is a function $x : \mathbb{N} \to \mathbb{N}$.

**Definition 2.1 (digit melody).** $x$ is a *base-$b$ digit melody* if $x_i < b$ for all $i$. We write $\mathcal{D}_b$ for the set of such melodies. The *decimal* case is $b = 10$.

**Definition 2.2 (pitch interval).** The pitch interval between the notes at positions $i$ and $j$ is
$$\iota_x(i,j) \;=\; |x_i - x_j| \;\in\; \mathbb{N}.$$
This is a *pitch* statistic; it does not refer to $j-i$.

**Definition 2.3 (lag interval).** For a temporal lag $\ell$, the *lag-$\ell$ interval at position $i$* is
$$\lambda_x(\ell, i) \;=\; \iota_x(i, i+\ell) \;=\; |x_i - x_{i+\ell}|.$$

**Definition 2.4 (interval distribution).** For a window length $n$, a lag $\ell$, and an interval value $v$,
$$N_x(n,\ell,v) \;=\; \#\{\, i < n : \lambda_x(\ell,i) = v \,\}.$$

Elementary properties, all immediate: $\iota_x$ is symmetric, $\iota_x(i,i)=0$, $\iota_x(i,j)=0 \iff x_i = x_j$, $\lambda_x(0,i)=0$, and the triangle inequality
$$\iota_x(i,k) \;\le\; \iota_x(i,j) + \iota_x(j,k) \tag{2.1}$$
holds for all $i,j,k$, since $|\cdot|$ on $\mathbb{Z}$ is a metric. Inequality (2.1) is the single analytic input behind everything tropical in this paper.

For cyclic statistics we also use finite windows with wraparound. If $d : \mathbb{Z}/n \to \{0,\dots,b-1\}$, we set
$$E(d) = \sum_{i} d_i^2, \qquad A_d(k) = \sum_i d_i\, d_{i+k}, \qquad \mathcal{I}_d(k) = \sum_i (d_{i+k} - d_i)^2,$$
the **energy**, **autocorrelation at lag $k$**, and **interval energy at lag $k$**, all sums taken over $\mathbb{Z}/n$. The cyclic interval distribution is
$$N^{\mathrm{cyc}}_d(k,v) \;=\; \#\{\, i \in \mathbb{Z}/n : |d_i - d_{i+k}| = v \,\}.$$

The polarization identity
$$2A_d(k) \;=\; 2E(d) - \mathcal{I}_d(k) \tag{2.2}$$
holds for any real cyclic signal: expand $(d_{i+k}-d_i)^2 = d_{i+k}^2 - 2 d_i d_{i+k} + d_i^2$ and use that $\sum_i d_{i+k}^2 = \sum_i d_i^2$ by reindexing the cycle. A companion fact we use: $A_d(k) = E(d)$ if and only if the shift $i \mapsto d_{i+k}$ equals $d$, i.e. the window is $k$-periodic.

---

## 3. The interval distribution: support, mass, moments

### 3.1 Support

**Lemma 3.1.** *If $x \in \mathcal{D}_b$ then $\lambda_x(\ell,i) < b$ for all $\ell, i$.*

*Proof.* Both $x_i$ and $x_{i+\ell}$ lie in $[0,b)$, so their absolute difference is $< b$. $\square$

**Theorem 3.2 (support).** *If $x \in \mathcal{D}_b$ and $v \ge b$, then $N_x(n,\ell,v) = 0$ for all $n,\ell$.*

*Proof.* Immediate from Lemma 3.1: the defining filter is empty. $\square$

**Corollary 3.3 (the octave never appears).** *For every decimal melody $x$, every window length $n$, and every lag $\ell$ — in particular $\ell = 12$ —*
$$N_x(n,\ell,12) = 0 .$$

This is the formal content of the phrase "there is no octave in a ten-note scale". It holds for the constant melody as much as for the digits of $\pi$; it is a property of the alphabet, not of the number being expanded. The genuinely falsifiable content of the theory lies in the results that follow.

**Corollary 3.4 (octave versus unison at lag twelve).** *For a decimal melody $x$ and any $n$,*
$$N_x(n,12,12) = 0, \qquad N_x(n,12,0) = \#\{\, i<n : x_i = x_{i+12} \,\}.$$

The two numbers on display are different statistics of the same $n$ position pairs. The first is identically zero; the second is what a lag-$12$ correlation study actually detects.

### 3.2 Total mass

**Theorem 3.5 (total mass).** *For $x \in \mathcal{D}_b$,* $\displaystyle\sum_{v=0}^{b-1} N_x(n,\ell,v) = n.$

*Proof.* Partition the index set $\{0,\dots,n-1\}$ into the fibres of the map $i \mapsto \lambda_x(\ell,i)$, which by Lemma 3.1 lands in $\{0,\dots,b-1\}$. The cardinality of the whole set is the sum of the fibre cardinalities, and the fibre over $v$ has cardinality $N_x(n,\ell,v)$. $\square$

### 3.3 Moments

**Theorem 3.6 (moment principle).** *For $x \in \mathcal{D}_b$ and any weight $g : \mathbb{N} \to \mathbb{N}$,*
$$\sum_{v=0}^{b-1} g(v)\, N_x(n,\ell,v) \;=\; \sum_{i<n} g\bigl(\lambda_x(\ell,i)\bigr).$$

*Proof.* Fibrewise summation over the value of $\lambda_x(\ell,\cdot)$, exactly as in Theorem 3.5, with $g$ constant on each fibre. $\square$

This is the precise sense in which *every additive lag statistic is a functional of the pitch-interval distribution at that lag*. Two special cases matter below.

**Corollary 3.7 (second moment).** $\displaystyle \sum_{v=0}^{b-1} v^2\, N_x(n,\ell,v) \;=\; \sum_{i<n} \lambda_x(\ell,i)^2 .$

**Corollary 3.8 (sharp decimal bound).** *For $x \in \mathcal{D}_{10}$,* $\displaystyle \sum_{v=0}^{9} v^2 N_x(n,\ell,v) \le 81\,n,$ *with equality iff every lag-$\ell$ interval in the window is nine semitones.*

---

## 4. Witness melodies

Two explicit families supply all the counterexamples and realizations we need.

**Definition 4.1 (square wave).** For $v, \ell \ge 0$, let $s_{v,\ell}(i) = v \cdot \bigl(\lfloor i/\ell\rfloor \bmod 2\bigr)$.

**Lemma 4.2.** *If $v < b$ then $s_{v,\ell} \in \mathcal{D}_b$. If $\ell \ge 1$ then $\lambda_{s_{v,\ell}}(\ell,i) = v$ for every $i$.*

*Proof.* The values of $s_{v,\ell}$ are $0$ and $v$, so the first claim is clear. For the second, $\lfloor (i+\ell)/\ell \rfloor = \lfloor i/\ell \rfloor + 1$, so the parity of the block index flips, so exactly one of $s_{v,\ell}(i)$, $s_{v,\ell}(i+\ell)$ equals $v$ and the other $0$. $\square$

**Theorem 4.3 (lag/interval spectrum).** *For $\ell, v \in \mathbb{N}$, there exists a decimal melody $x$ with $\lambda_x(\ell,i) = v$ for all $i$ if and only if*
$$v \le 9 \quad\text{and}\quad (\ell \ge 1 \ \text{ or }\ v = 0).$$

*Proof.* Necessity: $v \le 9$ by Lemma 3.1, and $\lambda_x(0,i)=0$ forces $v = 0$ when $\ell = 0$. Sufficiency: for $\ell \ge 1$ take $s_{v,\ell}$ by Lemma 4.2; for $v = 0$ take the constant melody. $\square$

**Corollary 4.4 (at lag twelve).** *A constant lag-$12$ interval value $v$ is realizable by a decimal melody iff $v \le 9$. Thus every value from a unison up to a major sixth occurs, and the octave occurs at no lag.*

**Corollary 4.5 (separation witness).** *The square wave $s_{7,12}$ satisfies, for every window length $n$,*
$$N(n,12,7) = n, \qquad N(n,12,0) = 0, \qquad N(n,12,12) = 0 .$$

So a melody can be perfectly regular at lag $12$ in the temporal sense (it is $24$-periodic and its lag-$12$ interval is constant) while containing **not a single unison** at that lag — and, of course, not a single octave.

---

## 5. The moment bridge

We now work on the cyclic window $\mathbb{Z}/n$ with a digit melody $d$, viewed as a real signal.

**Lemma 5.1.** *For $a, c \in \mathbb{N}$ one has $(a - c)^2 = |a-c|^2$ as real numbers.* (Trivial, but it is the step that converts a signed real difference into the natural-number pitch interval on which the histogram is indexed.)

**Theorem 5.2 (interval energy = second moment).** *Let $d : \mathbb{Z}/n \to \{0,\dots,b-1\}$. Then*
$$\mathcal{I}_d(k) \;=\; \sum_{v=0}^{b-1} v^2\, N^{\mathrm{cyc}}_d(k,v).$$

*Proof.* By Lemma 5.1, $\mathcal{I}_d(k) = \sum_i |d_{i+k}-d_i|^2$. Fibre the index set over the value of $i \mapsto |d_i - d_{i+k}|$, which lands in $\{0,\dots,b-1\}$; on the fibre over $v$ the summand is constantly $v^2$ and the fibre has $N^{\mathrm{cyc}}_d(k,v)$ elements. $\square$

**Theorem 5.3 (moment bridge).** *For a base-$b$ cyclic digit melody $d$ and any lag $k$,*
$$\boxed{\;2\,A_d(k) \;=\; 2\,E(d) \;-\; \sum_{v=0}^{b-1} v^2\, N^{\mathrm{cyc}}_d(k,v).\;}$$

*Proof.* Combine the polarization identity (2.2) with Theorem 5.2. $\square$

### 5.1 Autocorrelation is a functional of the pitch statistic

**Corollary 5.4 (congruence).** *Let $d, e$ be base-$b$ cyclic digit melodies of the same length with $E(d) = E(e)$ and $N^{\mathrm{cyc}}_d(k,v) = N^{\mathrm{cyc}}_e(k,v)$ for all $v$. Then $A_d(k) = A_e(k)$.*

*Proof.* Apply the bridge to each and compare; the right-hand sides agree term by term. $\square$

So the temporal statistic is *determined* by the pitch statistic together with the energy. This legitimizes autocorrelation as a pitch-theoretic quantity — and simultaneously bounds what it can express.

### 5.2 The peak is a unison statement

**Theorem 5.5 (maximality).** *For a cyclic digit melody $d$ and any lag $k$,*
$$A_d(k) = E(d) \iff |d_i - d_{i+k}| = 0 \ \text{ for all } i \iff \text{$d$ is $k$-periodic}.$$

*Proof.* $A_d(k) = E(d)$ holds iff the shifted signal equals the original (the equality case of Cauchy–Schwarz for the cyclic shift, or directly from (2.2) with $\mathcal{I}_d(k)=0$); and the shifted signal equals the original iff all lag-$k$ intervals vanish. $\square$

Hence: *a lag-$12$ autocorrelation peak is a statement about the mass $N_{12}(0)$ of unisons.* The octave value $v = 12$ contributes mass $0$ to every term of the bridge for every decimal melody (Corollary 3.3), so it cannot be responsible for any part of the peak.

### 5.3 The bridge is not invertible

The bridge maps a ten-bin histogram to one number, so injectivity is a priori hopeless; the following makes the failure concrete and minimal.

**Theorem 5.6 (information loss).** *There exist decimal cyclic melodies $d, e$ of length $4$ with*
$$E(d) = E(e), \qquad A_d(1) = A_e(1), \qquad N^{\mathrm{cyc}}_d(1,0) \ne N^{\mathrm{cyc}}_e(1,0).$$

*Proof.* Take $d = (0,0,0,5)$ and $e = (0,3,0,4)$. Then $E(d) = 25 = 9+16 = E(e)$. Every cyclically adjacent product vanishes in both cases, so $A_d(1) = 0 = A_e(1)$. The lag-$1$ interval multiset of $d$ is $\{0,0,5,5\}$, giving $N^{\mathrm{cyc}}_d(1,0) = 2$; that of $e$ is $\{3,3,4,4\}$, giving $N^{\mathrm{cyc}}_e(1,0) = 0$. $\square$

Consequently **a correlation statistic cannot certify any statement about which musical intervals occur**: two melodies indistinguishable by energy and lag-$1$ correlation differ in their unison count by the maximum possible amount for that window.

---

## 6. The exact null model

An empirical claim of the form "lag $k$ is anomalous" requires a baseline. Because the pitch alphabet is finite and the statistic is combinatorial, the baseline can be computed in closed form; no simulation is required.

**Definition 6.1 (triangular pair count).** For a base $b$ and interval value $v$,
$$P_b(v) \;=\; \#\{\, (a,c) \in \{0,\dots,b-1\}^2 : |a-c| = v \,\}.$$

**Theorem 6.2 (closed form).** $P_b(0) = b$; $P_b(v) = 2(b-v)$ for $0 < v < b$; $P_b(v) = 0$ for $v \ge b$. In particular $P_{10}(12) = 0$.

*Proof.* For $v=0$ the pairs are the $b$ diagonal ones. For $0<v<b$, the pairs are $(a, a+v)$ and $(a+v, a)$ with $0 \le a < b-v$, giving $2(b-v)$. For $v \ge b$ no pair qualifies. $\square$

**Theorem 6.3 (total mass).** $\displaystyle\sum_{v=0}^{b-1} P_b(v) = b^2$, the number of ordered digit pairs.

*Proof.* The pairs are partitioned by their interval value, which lies in $\{0,\dots,b-1\}$. $\square$

**Theorem 6.4 (null second moment).** $\displaystyle 6\sum_{v=0}^{b-1} v^2 P_b(v) + b^2 = b^4$, i.e. $\displaystyle\sum_{v} v^2 P_b(v) = \frac{b^4-b^2}{6}$.

*Proof sketch.* By Theorem 6.2 the sum equals $\sum_{v=1}^{b-1} 2v^2(b-v)$. Using $\sum_{v<b} v^2 = \tfrac{(b-1)b(2b-1)}{6}$ and $\sum_{v<b} v^3 = \tfrac{b^2(b-1)^2}{4}$, one gets $2b\cdot\tfrac{(b-1)b(2b-1)}{6} - 2\cdot\tfrac{b^2(b-1)^2}{4} = \tfrac{b^4-b^2}{6}$ after simplification. (Formally the identity is proved by induction on $b$ over the integers, avoiding truncated subtraction.) $\square$

**Corollary 6.5 (decimal baseline).** $\displaystyle\sum_{v=0}^{9} v^2 P_{10}(v) = 1650$: over the $100$ ordered digit pairs, the mean squared interval is exactly $16.5$ semitones$^2$ (RMS interval $\approx 4.06$ semitones).

**Theorem 6.6 (null autocorrelation deficit).** *Let $d$ be a base-$b$ cyclic digit melody whose lag-$k$ interval distribution is exactly $m$ copies of the null distribution, $N^{\mathrm{cyc}}_d(k,v) = m\,P_b(v)$ for all $v$. Then*
$$12\bigl(E(d) - A_d(k)\bigr) \;=\; m\,(b^4 - b^2).$$
*In base ten: $E(d) - A_d(k) = 825\,m$, where the window length is $n = 100m$.*

*Proof.* By the moment bridge, $2(E - A_d(k)) = \sum_v v^2 N_d^{\mathrm{cyc}}(k,v) = m \sum_v v^2 P_b(v) = m\,(b^4-b^2)/6$. Multiply by $6$. For $b = 10$: $E - A = m \cdot 1650/2 = 825m$; the window length is the total mass $m\,b^2 = 100m$. $\square$

No structural hypothesis on the melody enters. **A measured deficit differing from $825m$ is the only legitimate form of a "lag-$k$ anomaly" claim** in base ten; a deficit equal to $825m$ is exactly the absence of news.

---

## 7. The temporal variable: a tropical seminorm on the lag monoid

We now study the lag variable in isolation. Throughout this section $x$ is a melody on $\mathbb{N}$.

### 7.1 Unison lags

**Definition 7.1.** $p \in \mathbb{N}$ is a *unison lag* (a *period*) of $x$ if $x_i = x_{i+p}$ for all $i$. Write $U(x)$ for the set of unison lags.

**Lemma 7.2.** $0 \in U(x)$; $U(x)$ is closed under addition; if $p,q \in U(x)$ with $q \le p$ then $p - q \in U(x)$; and $p, q \in U(x)$ implies $q \bmod p \in U(x)$.

*Proof.* Additivity and $0$ are immediate. For subtraction, apply the $q$-periodicity at index $i + (p-q)$ to move between $x_{i+p-q}$ and $x_{i+p} = x_i$. The modulus statement follows by subtracting $\lfloor q/p\rfloor$ copies of $p$ from $q$, each step legitimate by the previous two properties. $\square$

**Theorem 7.3 (gcd-closure).** *If $p, q \in U(x)$ then $\gcd(p,q) \in U(x)$.*

*Proof.* Strong induction on $p$. If $p = 0$ then $\gcd(0,q)=q \in U(x)$. Otherwise $\gcd(p,q) = \gcd(q \bmod p,\, p)$, and $q \bmod p \in U(x)$ by Lemma 7.2 with $q \bmod p < p$; apply the inductive hypothesis. This is precisely the Euclidean algorithm run inside $U(x)$. $\square$

**Definition 7.4.** The *minimal period* $p_{\min}(x)$ is the least positive element of $U(x)$, or $0$ if none exists.

**Theorem 7.5 (rigidity).** *If $x$ has a positive period then*
$$U(x) \;=\; \{\, p \in \mathbb{N} : p_{\min}(x) \mid p \,\},$$
*i.e. $U(x)$ is the monoid of multiples of a single number. If $x$ has no positive period then $U(x) = \{0\}$.*

*Proof.* Multiples of a period are periods. Conversely, if $p \in U(x)$ is positive then $g = \gcd(p_{\min}, p) \in U(x)$ is positive and $\le p_{\min}$, hence $g = p_{\min}$ by minimality, hence $p_{\min} \mid p$. The aperiodic case is immediate. $\square$

**Theorem 7.6 (coprime periods force constancy).** *If $p, q \in U(x)$ with $\gcd(p,q)=1$, then $x$ is constant.*

*Proof.* By Theorem 7.3, $1 \in U(x)$, so $x_i = x_{i+1}$ for all $i$; induct. $\square$

Thus the temporal variable is **arithmetically rigid**: its structure is governed by divisibility, and the entire unison locus is determined by one integer.

### 7.2 The lag spectrum

**Definition 7.7 (lag spectrum).** $M_x(\ell) \;=\; \sup_i\, \lambda_x(\ell,i) \;=\; \sup_i |x_i - x_{i+\ell}|.$

For $x \in \mathcal{D}_b$ the supremum is over a bounded set of naturals, hence attained; $M_x(\ell) < b$, so $M_x(\ell) \le 9$ in the decimal case.

**Theorem 7.8 (subadditivity).** *For $x \in \mathcal{D}_b$ and all $k,\ell$,*
$$M_x(k+\ell) \;\le\; M_x(k) + M_x(\ell).$$

*Proof.* Fix $i$. By the triangle inequality (2.1) routed through position $i+k$,
$$|x_i - x_{i+k+\ell}| \le |x_i - x_{i+k}| + |x_{i+k} - x_{i+k+\ell}| \le M_x(k) + M_x(\ell),$$
and take the supremum over $i$. $\square$

**Theorem 7.9 (kernel).** *For $x \in \mathcal{D}_b$, $M_x(\ell) = 0 \iff \ell \in U(x)$.*

Recall the **tropical semiring** $(\mathbb{N}\cup\{\infty\}, \oplus, \odot)$ with $a\oplus c = \min(a,c)$ and $a \odot c = a + c$; its multiplicative unit is $0$. Writing $T_x(\ell)$ for $M_x(\ell)$ viewed in this semiring, Theorem 7.8 reads
$$T_x(k+\ell) \;\le\; T_x(k)\odot T_x(\ell),$$
i.e.:

> **The lag spectrum is a tropical seminorm on the additive monoid of lags.** Its "unit fibre" $\{\ell : T_x(\ell) = \mathbf{1}\}$ — where $\mathbf{1}$ is the tropical unit — is exactly $U(x)$, an additive submonoid of $\mathbb{N}$, and by Theorem 7.5 a monoid of multiples.

This is the structural reason the temporal variable is rigid while the pitch variable (next section) is free: the lag variable carries a subadditive scalar with an arithmetically closed kernel; the pitch variable carries no such constraint.

### 7.3 Lag twelve, completely resolved

**Theorem 7.10 (dichotomy at lag twelve).** *Let $x$ be a decimal melody.*
1. *If $M_x(12) = 0$ then $p_{\min}(x) \mid 12$, every lag-$12$ pair sounds a unison, and no lag-$12$ pair sounds an octave.*
2. *If $M_x(12) \ne 0$ then some lag-$12$ pair sounds an interval of size between $1$ and $9$ semitones — again never an octave.*

*Proof.* (1) $M_x(12)=0$ means $12 \in U(x)$ (Theorem 7.9); then $p_{\min} \mid 12$ by Theorem 7.5, all lag-$12$ intervals are $\le M_x(12) = 0$, and no interval can equal $12$ since all are $\le 9$. (2) If every lag-$12$ interval were outside $[1,9]$, then — all being $\le 9$ — all would be $0$, forcing $M_x(12)=0$. $\square$

The octave value never enters the dichotomy: perfect lag-$12$ correlation is a statement about periods dividing $12$; imperfect lag-$12$ correlation is a statement about some interval in $[1,9]$.

**Theorem 7.11 (subadditivity is strictly one-way).** $M_{s_{7,12}}(12) = 7$ *and* $M_{s_{7,12}}(24) = 0$.

*Proof.* The first is Lemma 4.2 with $v=7,\ell=12$. For the second, $\lfloor (i+24)/12\rfloor = \lfloor i/12\rfloor + 2$ has the same parity as $\lfloor i/12 \rfloor$, so the melody is $24$-periodic. $\square$

Hence a vanishing spectrum at lag $2\ell$ says nothing about lag $\ell$: temporal regularity at one scale is compatible with complete absence of unisons at half that scale.

---

## 8. The pitch variable: complete decoupling

We now prove that the interval histogram is unconstrained beyond its support — the exact opposite of the rigidity found for lags.

### 8.1 The alternating walk

**Definition 8.1.** Given a demand sequence $v : \mathbb{N}\to\mathbb{N}$, the *alternating walk* $W_v$ is defined by $W_v(0) = 0$ and
$$W_v(t+1) = \begin{cases} W_v(t) + v(t), & t \text{ even},\\ W_v(t) - v(t), & t \text{ odd}.\end{cases}$$

**Lemma 8.2 (walk invariant).** *If $v$ is non-increasing then, for every $t$, $0 \le W_v(t) \le v(0)$; moreover at even $t$ the walk has room to move up by $v(t)$ and at odd $t$ it has room to move down by $v(t)$. Consequently*
$$|W_v(t+1) - W_v(t)| = v(t) \quad\text{for all } t .$$

*Proof sketch.* Maintain the parity invariant "at even $t$: $W_v(t) + v(t) \le v(0)$; at odd $t$: $v(t) \le W_v(t)$" by induction, using monotonicity of $v$ at each step. The invariant guarantees the up-steps do not overshoot the ceiling $v(0)$ and the down-steps do not underflow $0$, so each step realizes its demand exactly. $\square$

The walk therefore plays a prescribed *non-increasing* sequence of intervals, one per time step, without ever leaving the range $[0, v(0)]$.

### 8.2 Layer-cake rearrangement

An arbitrary histogram is not a non-increasing sequence, so we rearrange it.

**Definition 8.3.** For a multiplicity function $N$ on $\{0,\dots,9\}$, let the *tail mass* be $T_N(w) = \sum_{u=w}^{9} N(u)$ and define the *layer sequence*
$$L_N(t) \;=\; \#\{\, w \in \{1,\dots,9\} : t < T_N(w) \,\}.$$

$L_N$ is the non-increasing rearrangement of the demanded intervals, written as a layer cake: level $w$ contributes $1$ to $L_N(t)$ for exactly the first $T_N(w)$ time steps.

**Lemma 8.4.** $L_N$ *is non-increasing, takes values in $\{0,\dots,9\}$, and for each $w \le 9$,*
$$\#\{\, t < n : L_N(t) = w \,\} = N(w) \qquad \text{whenever } \textstyle\sum_{v\le 9} N(v) = n .$$

*Proof sketch.* Monotonicity and the range bound are immediate from the definition, since $T_N$ is antitone in $w$ and there are nine levels. For the counting claim, first show $\#\{t<n : L_N(t)\ge w\} = T_N(w)$ for $1\le w\le 9$ — this is the defining property of the layer-cake construction — then subtract consecutive upper level sets, using $T_N(w) = N(w) + T_N(w+1)$ and $T_N(10)=0$, and handle $w=0$ as the complement of the first upper level set. $\square$

### 8.3 The inverse theorem at lag one

**Theorem 8.5 (inverse theorem).** *Let $N$ be any multiplicity function on $\{0,\dots,9\}$ with $\sum_{v=0}^{9} N(v) = n$. Then the decimal melody $x = W_{L_N}$ satisfies*
$$N_x(n,1,w) = N(w) \qquad\text{for all } w \le 9 .$$

*Proof.* By Lemma 8.4, $L_N$ is non-increasing with values $\le 9$, so by Lemma 8.2 the walk stays in $[0, L_N(0)] \subseteq [0,9]$ (a decimal melody) and its lag-$1$ interval at time $t$ is exactly $L_N(t)$. Hence the lag-$1$ interval histogram over $\{0,\dots,n-1\}$ is the value histogram of $L_N$, which is $N$ by Lemma 8.4. $\square$

**Corollary 8.6 (extreme histogram).** *There is a decimal melody realizing, in a window of ten position pairs, one unison and nine intervals of nine semitones each — and still no octave.*

*Proof.* Apply Theorem 8.5 with $N(0)=1$, $N(9)=9$, all other values zero; the total mass is $10$. The absence of octaves is Corollary 3.3. $\square$

### 8.4 Transporting a histogram to any lag

**Definition 8.7 (interleaving).** For a melody $z$ and $\ell \ge 1$, the *$\ell$-fold interleaving* is $z^{[\ell]}(i) = z(\lfloor i/\ell\rfloor)$: $\ell$ independent voices, each advancing one step per $\ell$ time units.

**Lemma 8.8.** *For $\ell \ge 1$, $\lambda_{z^{[\ell]}}(\ell, i) = \lambda_z(1, \lfloor i/\ell\rfloor)$.*

*Proof.* $\lfloor (i+\ell)/\ell\rfloor = \lfloor i/\ell\rfloor + 1$. $\square$

**Theorem 8.9 (decoupling at every lag).** *Let $\ell \ge 1$ and let $N$ be a multiplicity function on $\{0,\dots,9\}$ with total mass $m$. Then there is a decimal melody $x$ with*
$$N_x(\ell m,\, \ell,\, w) \;=\; \ell \cdot N(w) \qquad \text{for all } w \le 9 .$$

*Proof.* Take $x = (W_{L_N})^{[\ell]}$. The window $\{0,\dots,\ell m -1\}$ splits into $m$ blocks $[\ell t, \ell t + \ell)$; on the block indexed by $t$, Lemma 8.8 says every one of the $\ell$ positions realizes the same interval $\lambda_{W_{L_N}}(1,t)$. Summing the block contributions and applying Theorem 8.5 gives $\ell\,N(w)$. $\square$

**Corollary 8.10 (the temporal parameter constrains nothing).** *For every lag $\ell\ge1$ and every histogram shape on $\{0,\dots,9\}$, some decimal melody exhibits that shape (scaled by $\ell$) as its lag-$\ell$ interval distribution. In particular at $\ell=12$: no histogram supported on $\{0,\dots,9\}$ is excluded, and no histogram charging $v\ge10$ is attainable.*

The contrast with §7 is the central structural finding of this work: **lags are rigid (divisibility-organized), pitches are free (only support-constrained), and the only coupling is the second moment.**

---

## 9. The min-plus interval matrix

The triangle inequality (2.1) has a matrix-algebraic shadow that explains the tropical flavour of the whole subject.

**Definition 9.1.** For a melody $x$ and $n \ge 1$, the *interval matrix* $A \in \mathrm{Mat}_n(\mathbb{N}\cup\{\infty\})$ has entries $A_{ij} = |x_i - x_j|$, read in the min-plus semiring, where matrix product is
$$(A \odot B)_{ij} = \min_k \bigl( A_{ik} + B_{kj}\bigr).$$

**Lemma 9.2 (chain bound).** *For any sequence of positions $p_0, p_1, \dots, p_m$,*
$$|x_{p_0} - x_{p_m}| \;\le\; \sum_{t<m} |x_{p_t} - x_{p_{t+1}}| .$$

*Proof.* Induction on $m$ using (2.1). $\square$

**Theorem 9.3 (tropical idempotency).** $A \odot A = A$, and hence $A^{\odot m} = A$ for every $m \ge 1$.

*Proof.* "$\le$": choose the intermediate index $k = i$, whose cost is $A_{ii} + A_{ij} = 0 + A_{ij}$. "$\ge$": for every $k$, $A_{ik} + A_{kj} \ge A_{ij}$ by (2.1); take the minimum. Powers follow by induction. $\square$

**Interpretation.** $(A\odot A)_{ij}$ is the cheapest two-step *voice-leading* from note $i$ to note $j$ through an intermediate note, measured in total semitone motion. Idempotency says: *the cheapest voice-leading, with any number of intermediate stops, is the direct interval.* The interval matrix is its own tropical Kleene closure — it is already shortest-path complete.

**Further properties.** $A$ is symmetric ($A^{\mathsf T} = A$; intervals are unordered), its diagonal is the tropical unit (each note sounds a unison with itself), and for decimal melodies every entry is $\le 9$ and no entry equals $12$. Specializing to the pair $(i, i+12)$: the matrix entry equals the lag-$12$ interval at position $i$ and is never the octave. Temporal distance $12$ and pitch distance $12$ occupy different axes of the same matrix.

---

## 10. Pitch classes modulo twelve

The other half of a corrected methodology is the use of *pitch classes*: reducing pitches modulo the octave, $\mathrm{pc}(a) = a \bmod 12 \in \mathbb{Z}/12$, and interval classes $\mathrm{ic}(a,c) = \mathrm{pc}(|a-c|)$.

**Theorem 10.1 (faithfulness below the octave).** *If $a, c < 12$ then $\mathrm{pc}(a) = \mathrm{pc}(c) \iff a = c$.*

*Proof.* Congruence mod $12$ of two residues in $[0,12)$ is equality. $\square$

**Corollary 10.2.** *For decimal melodies, two notes have the same pitch class exactly when they are the same note, and two pairs have the same interval class exactly when they have the same interval. Octave equivalence is a no-op; interval classes carry exactly the same information as intervals.*

*Proof.* Digits are $< 10 < 12$, and intervals of digits are $\le 9 < 12$; apply Theorem 10.1. $\square$

**Theorem 10.3 (sharpness).** *In base $13$ the reduction is no longer injective: $\mathrm{pc}(0) = \mathrm{pc}(12)$ while $0 \ne 12$.*

Thus mod-$12$ analysis and interval analysis are the same theory for any alphabet of at most twelve symbols, and genuinely diverge from thirteen symbols on. The lesson for methodology: on a decimal digit scale, "using pitch classes" is not a correction — it changes nothing. The real correction is to measure $|x_i - x_j|$ for a clearly specified pair of positions.

---

## 11. Algorithms

All quantities above are computable in near-linear time. We record the three procedures that matter.

**Algorithm A (interval histogram at a lag).** Given a window $x_0,\dots,x_{n+\ell-1}$ and a lag $\ell$, initialize a length-$b$ array $H$ to zero and, for $i = 0,\dots,n-1$, increment $H[\,|x_i - x_{i+\ell}|\,]$. Cost: $O(n)$ time, $O(b)$ space. Correctness is Definition 2.4; the output has total mass $n$ (Theorem 3.5) and is supported on $\{0,\dots,b-1\}$ (Theorem 3.2).

**Algorithm B (moment bridge audit).** Given a cyclic window $d$ of length $n$ and a lag $k$, compute $E = \sum d_i^2$ and $A = \sum d_i d_{i+k}$ directly, compute $H$ by Algorithm A on the cyclic window, and verify $2A = 2E - \sum_v v^2 H[v]$. The residual is identically zero (Theorem 5.3); a nonzero residual indicates an indexing error, which is why the identity is useful as an audit. Comparing $E - A$ against $825m$ (where $n = 100m$) implements the null deficit test of Theorem 6.6. Cost: $O(n + b)$.

**Algorithm C (histogram realization).** Given a target histogram $N$ on $\{0,\dots,9\}$ of mass $n$ and a lag $\ell \ge 1$: compute the tail masses $T_N(w)$ for $w=1,\dots,9$; form the layer sequence $L_N(t) = \#\{w : t < T_N(w)\}$ for $t < n$; run the alternating walk $W_{L_N}$ to obtain a melody of $n+1$ notes; if $\ell > 1$, interleave, $x(i) = W_{L_N}(\lfloor i/\ell\rfloor)$, producing a window of length $\ell n$ whose lag-$\ell$ histogram is $\ell N$. Cost: $O(n\cdot 9 + \ell n)$ time; the melody is a valid decimal melody by Lemma 8.2. Correctness: Theorems 8.5 and 8.9.

---

## 12. Applications and methodological consequences

**12.1 Reporting standards for digit-sonification studies.** A claim about musical content in a digit sequence should report the interval histogram $N_x(n,\ell,\cdot)$ for an explicitly stated lag $\ell$ and window $n$, not a correlation coefficient. If a correlation is reported, the moment bridge fixes its meaning: it is the second moment of the histogram, offset by the energy, and nothing more. In particular the phrase "octave structure at lag 12" is unfalsifiable-by-vacuity in base ten: the octave mass is identically zero.

**12.2 Exact baselines instead of simulation.** Theorem 6.6 replaces Monte Carlo baselines by an identity. For a decimal window of length $n = 100m$ whose lag-$k$ interval histogram matches the triangular null, the autocorrelation deficit is exactly $825m$. Deviations are then measured against an exact reference rather than a sampling distribution — useful when $n$ is small and simulation noise dominates.

**12.3 Choosing an alphabet that can hear octaves.** If a study genuinely wishes to test for octave phenomena, it must use an alphabet whose interval range reaches $12$: at least $13$ symbols (base $13$, or a scale with $13$ steps). Theorem 10.3 identifies base $13$ as exactly the point at which octave equivalence becomes nontrivial. Below it, all "octave" language is empty.

**12.4 Periodicity detection.** Theorem 7.5 says that the set of lags with perfect correlation is a divisibility-closed set — so a detector that finds a unison lag $\ell$ has automatically found all multiples of $p_{\min} \mid \ell$, and can prune its search accordingly. Theorem 7.6 gives a cheap consistency test: two coprime detected periods imply the data is constant, so any nonconstant sequence with two coprime "periods" has a bug.

**12.5 Voice-leading and shortest paths.** Theorem 9.3 says the pairwise interval matrix of a one-dimensional pitch space is a fixed point of tropical matrix multiplication — the shortest-path closure is trivial. Any voice-leading optimization on such a space is therefore vacuous; nontrivial voice-leading geometry requires a pitch space that is not a line.

---

## 13. Discussion

The mathematical shape of these results is a striking asymmetry between the two variables that the folklore conflated.

The **temporal** variable lives in $(\mathbb{N},+)$, is measured by the lag spectrum $M_x$, and is organized by *divisibility*. Its zero set is a monoid of multiples; its scalar is subadditive; its natural home is the tropical semiring, where subadditivity becomes submultiplicativity and the zero set becomes the fibre over the tropical unit. Everything about the temporal variable is arithmetic.

The **pitch** variable lives in $\{0,\dots,b-1\}$, is measured by the histogram $N_x(n,\ell,\cdot)$, and is *unconstrained* beyond its support: every admissible histogram occurs, at every lag, with an explicit construction. Nothing about the pitch variable is arithmetic.

The only bridge is one scalar, the second moment. This is a strong information-theoretic statement about what a correlation study can conclude: the map from ten-dimensional histograms to autocorrelation is a fixed linear functional with weights $v^2$, and Theorem 5.6 shows the loss is realized already on windows of length four.

Two caveats delimit the scope. First, the "no octave" statements are properties of the *alphabet*, not of any particular sequence; they hold for the constant melody as much as for the digits of a transcendental constant. The falsifiable content of the theory therefore lies in the moment bridge, the null deficit law, the rigidity theorems, and the realization theorems — not in Corollary 3.3. Second, faithfulness of pitch-class reduction is likewise an artefact of alphabet size, and Theorem 10.3 records exactly where it stops.

A degenerate case worth flagging: at $\ell = 0$ every interval is zero, so the histogram is a point mass at the unison for trivial reasons. This is why Theorem 4.3 is stated as a guarded biconditional.

---

## 14. Future directions

This cycle established a complete separation of the two variables that the original "lag 12 $\approx$ octave" reading conflated: the temporal variable $\ell$ lives in the additive monoid $\mathbb{N}$, is measured by the tropical lag spectrum $M_x(\ell)$, and is organized by divisibility (the unison-lag monoid is the set of multiples of the minimal period); the pitch variable lives in $\{0,\dots,9\}$, is measured by the interval distribution $N_x(n,\ell,v)$, and is unconstrained beyond its support (every histogram is realized, at every lag). The bridge between them is the moment identity $2A = 2E - \sum_v v^2 N(v)$: an autocorrelation statistic sees only the second moment of the pitch statistic. Three bold, testable directions follow.

**1. Tropical spectral rigidity of the lag spectrum.** *Conjecture.* The function $\ell \mapsto M_x(\ell)$ of a decimal melody is not an arbitrary subadditive function: for aperiodic melodies of positive entropy it is eventually equal to its maximum $9$, and the set of lags where it is $< 9$ is finite and closed under divisors. The key insight is that $M_x$ is a tropical seminorm on $(\mathbb{N},+)$ whose unit fibre is already known to be an arithmetically rigid monoid, so the next fibres — the level sets $\{\ell : M_x(\ell) \le c\}$ — should inherit divisor-closedness from the same truncated-subtraction argument that produced gcd-closure. Why now? Subadditivity, gcd-closure, and the description of the unison lags as multiples supply the $c = 0$ case in full; the general case needs only a quantitative version of the period-subtraction lemma, i.e. a "$c$-approximate period" calculus.

**2. Fine–Wilf theorem for finite digit windows.** *Conjecture.* If a window of $n$ consecutive digits has unison lags $p$ and $q$ and $n \ge p + q - \gcd(p,q)$, then it has unison lag $\gcd(p,q)$; the bound is sharp. The key insight is that the infinite-word gcd-closure proved here degenerates on finite windows exactly at the Fine–Wilf threshold, so the finite theorem is the quantitative refinement of the rigidity we already have. Why now? A finite-window version is what empirical digit studies actually measure — they never see an infinite melody — and the proof can reuse the period-subtraction lemma verbatim with an index-range side condition.

**3. Joint interval distributions at two lags.** *Conjecture.* For coprime lags $k,\ell \ge 1$ the pair of interval distributions $(N_k, N_\ell)$ is jointly realizable for every pair of admissible histograms of equal mass, whereas for $\ell = 2k$ the pair is constrained by the tropical triangle inequality: $N_{2k}$ must be supported in $[0, 2\max \operatorname{supp} N_k]$. The key insight is that interleaving, used here for a single lag, becomes a Chinese-remainder construction for coprime lags, while non-coprime lags are coupled by subadditivity of the lag spectrum — so coprimality is exactly the boundary between free and constrained joint realizability.

---

## 15. Conclusion

Autocorrelation at sequence lag $12$ compares digit positions twelve time steps apart; it does not measure a twelve-semitone interval. Once the two variables are separated, each acquires a clean theory: the temporal variable becomes a tropical seminorm on the lag monoid with a divisibility-rigid kernel, and the pitch variable becomes a completely free histogram constrained only by the alphabet's span. The unique bridge between them, the second moment, is explicit, non-invertible, and comes with an exact combinatorial null baseline. To study musical intervals in a digit sequence, use the distribution of $|x_i - x_j|$ for a clearly specified pair of positions — and, if octaves are the object of interest, use an alphabet with at least thirteen symbols.
