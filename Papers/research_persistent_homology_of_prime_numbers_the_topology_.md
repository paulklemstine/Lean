# Persistent Homology of the Prime Point Cloud: Quantisation, Correlation, and the Vanishing of $H_1$

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We study the Vietoris–Rips persistent homology of the prime point cloud $\{p_1, p_2, p_3, \dots\} = \{2,3,5,7,\dots\} \subseteq \mathbb{R}$ and test the *Poisson heuristic* for its barcode: the conjecture that the zero-dimensional bar lengths are exponentially distributed with mean $\log x$, and that the first homology carries bars at scale $(\log x)^2$, the longest of which encodes the Twin Prime Conjecture. We prove that both halves of the conjecture fail, and we replace them with exact statements.

In dimension zero we show that the barcode is *arithmetically quantised*: the initial bar has length $1$ and every later bar has even length, so the bar-length measure is atomic on $\{1\} \cup 2\mathbb{N}$ and every open window $(2k, 2k+2)$ is empty, while any exponential law of any mean assigns strictly positive mass to it. The quantisation is quantitatively robust — every bar length is at distance at least $1$ from every odd integer $\ge 3$ — and the barcode has bars of arbitrarily large length, precluding an exponential tail at any fixed scale. The Betti staircase is constant on each interval $[2k, 2k+2)$, and its drops invert exactly to the prime-gap histogram; the area under the reduced Betti curve satisfies the exact identity $\int_0^\infty (b_0(\varepsilon,n) - 1)\,d\varepsilon = p_n - 2$.

In dimension one we prove a vanishing theorem: for *any* strictly increasing point cloud on the real line and *any* scale, every mod-$2$ one-cycle of the Rips (flag) complex is a symmetric-difference sum of Rips triangles. Hence $H_1 = 0$ at all scales, and no $H_1$ bar of the prime cloud exists — in particular no "twin prime $H_1$ bar". The correct topological form of the Twin Prime Conjecture is zero-dimensional: it holds if and only if the single Betti step $b_0(1,n) - b_0(2,n)$ is unbounded in $n$.

Finally we show that the barcode is a *correlated* point pattern, refuting independence as well as the exponential marginal. Past the initial triple $3,5,7$, two adjacent bars of equal length $d$ force $3 \mid d$; in particular adjacent twin bars never occur, though an independent model predicts $(n-1)q^2$ of them. This is the case $q = 3$ of a general block law: for every prime $q$, some block of fewer than $q$ consecutive bars has total length divisible by $q$. The barcode is a complete invariant, $p_n = 2 + \sum_{m<n} g_m$, so these congruence exclusions are genuine constraints on the topology.

**Keywords:** persistent homology; Vietoris–Rips filtration; prime gaps; barcode; Betti curve; Poisson process; twin primes; chordal graphs.

---

## 1. Introduction

### 1.1 The prime point cloud

Let $p_1 = 2 < p_2 = 3 < p_3 = 5 < \cdots$ be the primes in increasing order, and let
$$P(n) = p_{n+1} \in \mathbb{R}, \qquad n = 0, 1, 2, \dots$$
be the *prime point cloud*: the $n$-th prime regarded as a point on the real line. (Indices are zero-based throughout; $P(0) = 2$.) Because the enumeration of primes is strictly increasing, $P$ is a strictly monotone map $\mathbb{N} \to \mathbb{R}$.

Persistent homology asks how the topology of a point cloud varies with the resolution at which it is inspected. Concretely, fix a scale $\varepsilon \ge 0$ and form the *Vietoris–Rips complex* $R_\varepsilon$: the simplicial complex whose vertices are the indices $n$, and in which a finite set of indices spans a simplex iff all pairwise distances are at most $\varepsilon$. Increasing $\varepsilon$ gives a nested family (a *filtration*) of complexes, and each homological feature — a connected component in $H_0$, a loop in $H_1$ — is born at some scale and dies at some scale. The multiset of birth–death intervals is the *barcode*.

The heuristic this paper tests is the following, in wide informal circulation.

> **Poisson heuristic for the prime barcode (conjectural).** Near $x$, primes have density $1/\log x$; hence the $H_0$ barcode of the prime cloud should resemble that of a Poisson process of that intensity. In particular (i) $H_0$ bar lengths should be exponentially distributed with mean $\approx \log x$, and (ii) $H_1$ bars should appear at scale $\approx (\log x)^2$, the longest one persisting from $\varepsilon = 2$ (the twin-prime scale) to $\infty$ and encoding the Twin Prime Conjecture.

We prove (i) and (ii) both false, in strong forms, and identify the true statements that replace them.

### 1.2 Summary of results

* **Quantisation** (Theorem 3.1, Corollary 3.3). $g_0 = 1$ and $g_i$ is even for $i \ge 1$; hence the barcode measure is atomic on $\{1\} \cup 2\mathbb{N}$.
* **Refutation of the exponential law** (Theorem 3.5). For every $k \ge 1$ and every $n$, no bar among the first $n$ has length in $(2k, 2k+2)$; an exponential law of mean $m > 0$ assigns mass $e^{-2k/m} - e^{-(2k+2)/m} > 0$ to that window. Likewise the window $(0,1)$ is empty.
* **Robustness** (Theorem 3.7). Every bar length is at distance $\ge 1$ from every odd integer $2k+1 \ge 3$; the refutation survives bottleneck perturbations of size $< 1/2$.
* **Unbounded bars** (Theorem 3.8). For every $N$ some bar has length $\ge N$; no fixed-mean exponential tail is possible.
* **Even Betti staircase and inversion** (Theorems 4.2, 4.5). $\varepsilon \mapsto b_0(\varepsilon, n)$ is constant on $[2k, 2k+2)$, and $\#\{i < n : g_i = 2k\} = b_0(2k-1,n) - b_0(2k+1,n)$.
* **Betti area identity** (Theorem 4.6). $\int_0^\infty (b_0(\varepsilon,n)-1)\,d\varepsilon = p_n - 2$; the mean bar length of the first $n$ bars is $(p_n - 2)/n$.
* **Twin primes in $H_0$** (Theorem 5.2). The Twin Prime Conjecture holds iff $b_0(1,n) - b_0(2,n)$ is unbounded.
* **Chordality** (Theorem 6.1). Every cycle of length $\ge 4$ in the Rips graph of a strictly increasing line cloud has a two-step chord.
* **Vanishing of $H_1$** (Theorem 6.4). Every mod-$2$ one-cycle of a line Rips complex is a sum of Rips triangles; so $H_1 = 0$ at every scale, for the primes in particular.
* **Pair-correlation exclusion** (Theorems 7.1, 7.3). Adjacent equal bars force $3 \mid d$; adjacent twin bars never occur past $3,5,7$; hence the independence hypothesis fails.
* **Block divisibility** (Theorem 7.6). For every prime $q$ and every start past $q$, some block of $< q$ consecutive bars has length sum divisible by $q$.
* **Completeness** (Theorem 8.1). $p_n = 2 + \sum_{m<n} g_m$.

---

## 2. Definitions and the zero-dimensional dictionary

Throughout, $p : \mathbb{N} \to \mathbb{R}$ denotes an arbitrary *strictly increasing* point cloud on the line, and $P$ the specific prime cloud $P(n) = p_{n+1}$.

**Definition 2.1 (Rips adjacency and connectivity).** For $\varepsilon \in \mathbb{R}$, indices $a, b$ are *$\varepsilon$-adjacent* if $|p(a) - p(b)| \le \varepsilon$. They are *$\varepsilon$-connected* if they are related by the reflexive–transitive closure of $\varepsilon$-adjacency; write $a \sim_\varepsilon b$.

**Definition 2.2 (Bars, gaps).** For the prime cloud put $g_i = p_{i+2} - p_{i+1} = P(i+1) - P(i)$, the $i$-th *prime gap* — equivalently, as Proposition 2.4 records, the length of the $i$-th finite $H_0$ bar.

**Definition 2.3 (Betti curve).** $b_0(\varepsilon, n)$ denotes the number of $\varepsilon$-connected components of the first $n+1$ points $p(0), \dots, p(n)$, i.e. the zeroth Betti number of the truncated Rips complex at scale $\varepsilon$.

The elementary structure of a filtration on a line is contained in the following observation.

**Proposition 2.4 (Line dictionary).** *Let $p$ be strictly increasing, $\varepsilon \ge 0$, and $i \le j$. Then $i \sim_\varepsilon j$ if and only if $p(k+1) - p(k) \le \varepsilon$ for every $k$ with $i \le k < j$. Consequently, for every $n$,*
$$b_0(\varepsilon, n) = 1 + \#\{\, i < n : p(i+1) - p(i) > \varepsilon \,\},$$
*and the finite $H_0$ barcode of the first $n+1$ points is the multiset of bars $[0, p(i+1) - p(i))$ for $i < n$, together with one infinite bar.*

*Proof sketch.* ($\Rightarrow$) Any $\varepsilon$-path from $i$ to $j$ must, at each step $|p(a) - p(b)| \le \varepsilon$, straddle every intermediate consecutive pair, whence each such pair has gap $\le \varepsilon$ by monotonicity. ($\Leftarrow$) If all intermediate gaps are $\le \varepsilon$ then the chain $i \to i+1 \to \cdots \to j$ realises the connection. The component count follows because the components are exactly the maximal runs of consecutive indices whose internal gaps are $\le \varepsilon$, and the components are separated by the gaps exceeding $\varepsilon$. Each such run merges with its right-hand neighbour precisely when $\varepsilon$ reaches the separating gap, giving the stated bars. $\square$

Thus in dimension zero *the topology of a line point cloud is exactly its gap data*, and for the primes the barcode is exactly the prime gap sequence
$$1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, 2, 4, 6, 6, \dots$$

We record two conventions. First, "the barcode measure" means the empirical measure of the first $n$ bar lengths, $\mu_n = \frac1n \sum_{i<n} \delta_{g_i}$; a claim that bar lengths are exponentially distributed with mean $m$ is a claim about limits of $\mu_n$. Second, $b_0(\varepsilon,n) - 1$ is the *reduced* Betti number, discarding the single bar that never dies.

---

## 3. Quantisation of the barcode and the failure of the exponential law

**Theorem 3.1 (Quantisation).** *$g_0 = 1$, and $g_i$ is even with $g_i \ge 2$ for every $i \ge 1$.*

*Proof.* $g_0 = 3 - 2 = 1$. For $i \ge 1$ both $p_{i+1}$ and $p_{i+2}$ are primes $\ge 3$, hence odd; the difference of two odd numbers is even, and it is positive because the enumeration is strictly increasing, so $g_i \ge 2$. $\square$

**Corollary 3.2 (Uniqueness of the odd bar).** *$g_i = 1$ if and only if $i = 0$.*

**Corollary 3.3 (Real form).** *For $i \ge 1$ there is $k \ge 1$ with $P(i+1) - P(i) = 2k$. The barcode measure $\mu_n$ is supported in $\{1\} \cup \{2,4,6,\dots\}$ for every $n$.*

Write
$$B_n(a,b) = \#\{\, i < n : a < P(i+1) - P(i) < b \,\}$$
for the number of the first $n$ bars whose length lies in the open window $(a,b)$.

**Theorem 3.4 (Empty windows).** *For every $n$ and every $k \ge 1$, $B_n(2k, 2k+2) = 0$. Also $B_n(0,1) = 0$.*

*Proof.* Suppose $2k < g_i < 2k+2$ with $k \ge 1$. If $i = 0$ then $g_i = 1 \le 2k$, a contradiction. If $i \ge 1$ then $g_i = 2a$ for some integer $a$, and $2k < 2a < 2k+2$ forces $k < a < k+1$, impossible in the integers. For the second claim, $g_i \ge 1$ always. $\square$

**Theorem 3.5 (Refutation of the exponential/Poisson law).** *Let $m > 0$ and $k \ge 1$. Then for every $n$,*
$$B_n(2k, 2k+2) = 0 \qquad\text{while}\qquad e^{-2k/m} - e^{-(2k+2)/m} > 0 .$$
*The same holds for the window $(0,1)$ with predicted mass $1 - e^{-1/m} > 0$. Hence for no mean $m$ — in particular not $m = \log x$ — are the prime $H_0$ bar lengths exponentially distributed.*

*Proof.* The vanishing is Theorem 3.4. The exponential law with mean $m$ has survival function $t \mapsto e^{-t/m}$, so the mass of $(a,b)$ is $e^{-a/m} - e^{-b/m}$, which is positive whenever $a < b$ because $t \mapsto e^{-t/m}$ is strictly decreasing. $\square$

**Remark 3.6.** The refutation is a comparison of two explicitly nonvacuous quantities: a strictly positive predicted proportion against an identically zero observed count, at every truncation. It is therefore not an asymptotic or statistical objection but a structural one: $\mu_n$ is purely atomic while every exponential law is absolutely continuous. No rescaling, no choice of intensity, and no passage to the limit can repair this.

**Theorem 3.7 (Robust quantisation).** *For every $i$ and every $k \ge 1$,*
$$\big| \,(P(i+1) - P(i)) - (2k+1) \,\big| \;\ge\; 1 .$$
*That is, every bar length is at distance at least $1$ from every odd integer $\ge 3$.*

*Proof.* If $i = 0$ the length is $1$ and $|1 - (2k+1)| = 2k \ge 2$. If $i \ge 1$ the length is an even integer $2a$; then either $2a \le 2k$, giving $|2a - (2k+1)| \ge 1$, or $2a \ge 2k+2$, giving $|2a - (2k+1)| \ge 1$. $\square$

Since the bottleneck distance between barcodes moves each bar endpoint by at most the distance itself, Theorem 3.7 implies that any barcode within bottleneck distance $< 1/2$ of the prime barcode still has empty windows of positive width around every odd integer, and hence is still not exponential. The refutation is stable.

**Theorem 3.8 (Arbitrarily long bars).** *For every $N \in \mathbb{N}$ there exists $i$ with $g_i \ge N$.*

*Proof.* Let $m = N + 2$. For $2 \le j \le m$ the number $m! + j$ is divisible by $j$ and strictly exceeds $j$, hence is composite. So the interval $[m! + 2, \; m! + m]$ contains no primes. Let $n$ be the index of the least prime $\ge m! + 2$. Then $p$ of index $n$ exceeds $m! + m$, while the previous prime is $< m! + 2$, so the gap between them exceeds $m - 2 = N$. $\square$

**Corollary 3.9.** *The barcode is unbounded: for every $C \in \mathbb{R}$ some bar has length $> C$. Hence the bar-length distribution has no exponential tail with a fixed mean, and no single scale $\log x$ governs the barcode.*

---

## 4. The Betti staircase and the area identity

**Definition 4.1.** For the prime cloud, Proposition 2.4 gives $b_0(\varepsilon, n) = 1 + \#\{i < n : g_i > \varepsilon\}$.

**Theorem 4.2 (Even quantisation of the staircase).** *Let $k \ge 1$ and $2k \le \varepsilon_1 \le \varepsilon_2 < 2k+2$. Then $b_0(\varepsilon_1, n) = b_0(\varepsilon_2, n)$ for every $n$: the Betti curve is constant on $[2k, 2k+2)$.*

*Proof.* It suffices that $\{i < n : g_i > \varepsilon_1\} = \{i < n : g_i > \varepsilon_2\}$. One inclusion is monotonicity. Conversely, if $g_i > \varepsilon_1 \ge 2k$ then either $i = 0$, impossible since $g_0 = 1 \le 2k$, or $g_i = 2a$ with $2a > 2k$, i.e. $a \ge k+1$, i.e. $g_i \ge 2k + 2 > \varepsilon_2$. $\square$

**Remark 4.3.** Almost surely, a Poisson cloud's Betti curve is non-constant on every subinterval of the range of its bar lengths, since the bar lengths are almost surely distinct and dense in $(0,\infty)$. The prime staircase, by contrast, has all its jumps at even integers — one more structural separation from the Poisson model.

**Theorem 4.4 (Window splitting).** *For $k \ge 1$ and every $n$,*
$$\#\{i<n : g_i > 2k-1\} = \#\{i<n : g_i > 2k+1\} + \#\{i<n : g_i = 2k\}.$$

*Proof.* By Theorem 3.1 every $g_i$ with $i \ge 1$ is even and $g_0 = 1$, so $g_i > 2k-1$ holds iff $g_i > 2k+1$ or $g_i = 2k$, and the two alternatives are disjoint. $\square$

**Theorem 4.5 (Inversion formula).** *For $k \ge 1$,*
$$\#\{\, i < n : g_i = 2k \,\} \;=\; b_0(2k-1,\, n) \;-\; b_0(2k+1,\, n).$$
*Hence the Betti staircase and the prime-gap histogram determine one another.*

*Proof.* Immediate from Definition 4.1 and Theorem 4.4. $\square$

**Theorem 4.6 (Betti area identity).** *For every $n$,*
$$\int_0^{\infty} \big( b_0(\varepsilon, n) - 1 \big)\, d\varepsilon \;=\; p_{n+1} - 2 ,$$
*the $n$-th prime (zero-based) minus $2$.*

*Proof sketch.* Layer-cake: for $\varepsilon > 0$,
$$b_0(\varepsilon, n) - 1 = \#\{i<n : g_i > \varepsilon\} = \sum_{i<n} \mathbf{1}_{(0,\, g_i)}(\varepsilon),$$
since the $i$-th bar contributes exactly while the scale is strictly below its length. Each indicator is integrable (its support is a bounded interval), so the integral passes through the finite sum, and $\int_0^\infty \mathbf{1}_{(0,g_i)} = g_i$. Finally the gaps telescope: $\sum_{i<n} g_i = p_{n+1} - p_1 = p_{n+1} - 2$. $\square$

**Corollary 4.7 (Mean bar length).** *For $n \ge 1$, the average length of the first $n$ bars is*
$$\frac1n \int_0^\infty \big(b_0(\varepsilon,n) - 1\big)\, d\varepsilon \;=\; \frac{p_{n+1} - 2}{n},$$
*the exact form of the "average prime gap" whose asymptotics the Prime Number Theorem describes as $\sim \log p_n$.*

**Corollary 4.8 (Divergence).** *The Betti area is unbounded: for every $C$ there is $n$ with $\int_0^\infty (b_0(\varepsilon,n)-1)\, d\varepsilon > C$.*

For primes below $10^6$ ($78\,497$ finite bars) the identity gives area $999\,981 = 999\,983 - 2$, and the mean bar length is $12.739$ against $\log p_n = 13.815$.

---

## 5. The Twin Prime Conjecture is a Betti step

**Definition 5.1.** The *twin step* of the barcode is
$$\tau(n) \;=\; b_0(1, n) - b_0(2, n),$$
the number of components that merge as the scale crosses $2$.

**Theorem 5.2 (Twin primes in $H_0$).** *For every $n$, $\tau(n) = \#\{ i < n : g_i = 2 \}$. Consequently:*
$$\#\{\, p : p \text{ and } p+2 \text{ both prime} \,\} = \infty \iff \tau \text{ is unbounded, i.e. } \forall N\, \exists n:\ \tau(n) \ge N .$$

*Proof.* By Definition 4.1, $b_0(1,n) - b_0(2,n) = \#\{i<n : g_i > 1\} - \#\{i<n : g_i > 2\}$, and since gaps are integers, $\{g_i > 1\}$ splits disjointly into $\{g_i > 2\}$ and $\{g_i = 2\}$, giving the count. A predicate holds for infinitely many indices iff its counting function over $\{0,\dots,n-1\}$ is unbounded in $n$: for the forward direction, any finite set of $N$ witnesses lies inside some initial segment; for the converse, a finite witness set would cap the counts. Finally, $p$ and $p+2$ are both prime for infinitely many $p$ iff $g_i = 2$ for infinitely many $i$. $\square$

Theorem 5.2 is the corrected form of the conjectural "twin prime $H_1$ bar": the twin prime problem is a statement about a *single step of the zero-dimensional Betti staircase*, and Section 6 shows there is no $H_1$ in which it could have lived.

---

## 6. Vanishing of $H_1$ for point clouds on a line

### 6.1 The combinatorial statement

**Theorem 6.1 (Chordality).** *Let $p$ be strictly increasing, $\varepsilon \in \mathbb{R}$, and let $c : \mathbb{N} \to \mathbb{N}$ be a closed cycle of length $k \ge 4$ in the Rips graph at scale $\varepsilon$: that is, $c$ is $k$-periodic, injective on one period, and $|p(c(i)) - p(c(i+1))| \le \varepsilon$ for all $i$. Then there is an index $t$ with $c(t) \ne c(t+2)$ and $|p(c(t)) - p(c(t+2))| \le \varepsilon$: the cycle has a chord between vertices at cyclic distance exactly $2$.*

*Proof.* Let $v = c(i_0)$ minimise $p \circ c$ over one period; by periodicity $p(v) \le p(c(i))$ for all $i$. Let $t$ be the index with $t + 1 \equiv i_0$, so that $c(t)$ and $c(t+2)$ are the two cycle neighbours of $v$. Both satisfy $p(v) \le p(c(t))$, $p(v) \le p(c(t+2))$ and $p(c(t)) - p(v) \le \varepsilon$, $p(c(t+2)) - p(v) \le \varepsilon$, so both lie in the window $[p(v), p(v) + \varepsilon]$; hence $|p(c(t)) - p(c(t+2))| \le \varepsilon$. That $c(t) \ne c(t+2)$ follows from injectivity on a period together with $k \ge 4$: equality would force $k \mid 2$. $\square$

**Corollary 6.2 (No chordless cycles in the prime Rips graph).** *At every scale $\varepsilon$, the Rips graph of the prime point cloud contains no induced (chordless) cycle of length $\ge 4$; the graph is chordal.*

The statement is not vacuous: at scale $\varepsilon = 4$ the primes $3, 5, 7$ span a triangle, so chords do occur.

### 6.2 The homological statement over $\mathbb{F}_2$

Chordality is a statement about *induced* cycles; the homological content requires more. We work with $\mathbb{F}_2$ coefficients, where the chain complex of the flag (Rips) complex takes a purely combinatorial form.

**Definition 6.3 ($\mathbb{F}_2$ one-chains).** An *edge* is an ordered pair $e = (a,b)$ with $a < b$; it is a *Rips edge at scale $\varepsilon$* if $|p(a) - p(b)| \le \varepsilon$. A *one-chain* is a finite set $E$ of edges; addition of chains is symmetric difference $E_1 \,\triangle\, E_2$. The *degree* $\deg_E(v)$ is the number of edges of $E$ incident to $v$; the boundary $\partial_1 E$ is the set of vertices of odd degree, so $E$ is a *cycle* iff every degree is even. For $a < b < c$ the *triangle chain* is $T(a,b,c) = \{(a,b), (b,c), (a,c)\}$, and it is a *Rips triangle* if all three of its edges are Rips edges. The *triangle span* is the set of chains obtained from $\emptyset$ by repeatedly adding (i.e. symmetric-differencing) Rips triangles; it is exactly the image of $\partial_2$ on the flag complex.

Since $H_1 = \ker \partial_1 / \operatorname{im} \partial_2$, vanishing of $H_1$ is the assertion that every cycle lies in the triangle span.

**Theorem 6.4 (Vanishing of $H_1$ on a line).** *Let $p : \mathbb{N} \to \mathbb{R}$ be strictly increasing and $\varepsilon \in \mathbb{R}$. Then every $\mathbb{F}_2$ one-cycle $E$ all of whose edges are Rips edges at scale $\varepsilon$ lies in the span of the Rips triangles at scale $\varepsilon$. Consequently $H_1(R_\varepsilon; \mathbb{F}_2) = 0$ for every $\varepsilon$.*

*Proof.* Define the *weight* $\mu(E) = \sum_{(a,b) \in E} b$, the sum of the right endpoints, and induct strongly on $\mu(E)$.

If $E = \emptyset$ it lies in the span. Otherwise let $v$ be the largest right endpoint occurring in $E$. Every edge incident to $v$ has $v$ as its right endpoint (an edge $(v, b)$ would have $b > v$, contradicting maximality). The degree of $v$ is nonzero, and even because $E$ is a cycle, hence at least $2$: there are two distinct edges $(u,v), (w,v) \in E$, and we may name them so that $u < w < v$.

*The chord is present.* Since $p$ is increasing, $p(u) < p(w) < p(v)$, and $|p(u) - p(v)| \le \varepsilon$ gives $p(v) - p(u) \le \varepsilon$; hence $0 < p(w) - p(u) < p(v) - p(u) \le \varepsilon$, so $(u,w)$ is a Rips edge. Therefore $T = T(u, w, v)$ is a Rips triangle (its third and second edges $(w,v), (u,v)$ lie in $E$ and are Rips edges by hypothesis).

*The move preserves cycles.* Every vertex has degree $0$ or $2$ in $T$, so $T$ is itself a cycle; and degrees add modulo $2$ under symmetric difference, because $\deg_{A \triangle B}(x) \equiv \deg_A(x) + \deg_B(x) \pmod 2$. Hence $E' = T \,\triangle\, E$ is again a cycle, and all its edges are Rips edges.

*The move terminates.* Weights satisfy $\mu(A \triangle B) + 2\sum_{e \in A \cap B} e_2 = \mu(A) + \mu(B)$. Here $\mu(T) = w + 2v$ and $\{(u,v), (w,v)\} \subseteq T \cap E$, so $\sum_{e \in T \cap E} e_2 \ge 2v$; substituting,
$$\mu(E') = \mu(T) + \mu(E) - 2\!\!\sum_{e \in T \cap E}\!\! e_2 \;\le\; (w + 2v) + \mu(E) - 4v \;=\; \mu(E) + (w - 2v) \;<\; \mu(E),$$
since $0 \le w < v$. (Concretely: the two edges of weight $v$ are deleted and at most one new edge, of weight $w < v$, appears.)

By the inductive hypothesis $E'$ lies in the triangle span; and $E = T \,\triangle\, E'$ because symmetric difference is an involution, so $E$ lies in the span as well. $\square$

**Corollary 6.5 (No $H_1$ bars for the primes).** *The prime point cloud has vanishing first homology at every scale $\varepsilon$. In particular the conjectured $H_1$ bars at scale $(\log x)^2$ do not exist, and there is no "twin prime $H_1$ bar" persisting from $\varepsilon = 2$ to $\infty$.*

**Example 6.6 (Non-vacuity).** The prime complex genuinely contains nonzero one-cycles; they simply bound. At scale $\varepsilon = 8$, the quadrilateral on the primes $3, 5, 7, 11$,
$$E = \{(3,5), (5,7), (7,11), (3,11)\},$$
has all degrees equal to $2$ and is a nonzero chain, hence an honest one-cycle; and
$$E \;=\; T(3,5,7) \;\triangle\; T(3,7,11),$$
both summands being Rips triangles at scale $8$ (their longest edges are $7-3 = 4$ and $11-3 = 8$). Thus $E$ is a cycle that bounds, exactly as Theorem 6.4 asserts.

**Remark 6.7.** The mechanism is dimensional, not arithmetic: a point cloud in $\mathbb{R}^1$ has an *indifference graph*, and the leftmost (or rightmost) vertex of any cycle sees both of its neighbours inside one window of width $\varepsilon$, so they see each other. Any interesting $H_1$ would require the primes to be embedded into a space of dimension $\ge 2$ — e.g. via $n \mapsto (p_n \bmod a, p_n \bmod b)$ or a spiral embedding — which is a genuinely different (and open) construction.

---

## 7. Correlations: the barcode is not an independent process

Theorem 3.5 kills the exponential *marginal*. A weaker Poisson hypothesis survives it: that bar lengths, whatever their marginal law, are *independent*. This section refutes independence too.

**Theorem 7.1 (Mod-3 law).** *For every $i \ge 2$, at least one of $g_i$, $g_{i+1}$, $g_i + g_{i+1}$ is divisible by $3$.*

*Proof.* The three primes $p_{i+1} < p_{i+2} < p_{i+3}$ all exceed $3$ (since $i \ge 2$ gives $p_{i+1} \ge 5$), so none is divisible by $3$ and each residue mod $3$ lies in $\{1,2\}$. By pigeonhole two of the three residues coincide, and the corresponding difference — which is $g_i$, $g_{i+1}$ or $g_i + g_{i+1}$ — is divisible by $3$. $\square$

**Theorem 7.2 (Repeated bars are multiples of 3).** *If $i \ge 2$ and $g_i = g_{i+1} = d$, then $3 \mid d$.*

*Proof.* By Theorem 7.1 either $3 \mid g_i = d$, or $3 \mid g_{i+1} = d$, or $3 \mid g_i + g_{i+1} = 2d$, and in the last case $3 \mid d$ since $\gcd(2,3) = 1$. $\square$

**Theorem 7.3 (Exclusion of adjacent twin bars).** *For $i \ge 2$ it is never the case that $g_i = g_{i+1} = 2$; likewise never $g_i = g_{i+1} = 4$. Consequently the number of adjacent twin-bar pairs past the start is exactly $0$ at every truncation:*
$$\#\{\, i < n : i \ge 2,\ g_i = 2,\ g_{i+1} = 2 \,\} = 0 .$$

*Proof.* Theorem 7.2 would force $3 \mid 2$, respectively $3 \mid 4$. $\square$

**Remark 7.4 (Sharpness).** The hypothesis $i \ge 2$ is necessary: $g_1 = g_2 = 2$, from the triple $3, 5, 7$. This is the unique adjacent twin pair in the entire barcode.

**Theorem 7.5 (Refutation of independence).** *Let a model posit that bar lengths are independent with $\mathbb{P}(\text{length} = 2) = q > 0$. For $n \ge 2$ it predicts $(n-1)q^2 > 0$ adjacent twin-bar pairs among the first $n$ bars, while the prime barcode contains exactly $0$ past the start. Hence the prime barcode is not an independent-increment (Poisson) process.*

Beyond the diagonal, an analogous obstruction exists at every prime modulus. Write $g$'s block sums as $\sum_{m \in [j,k)} g_{i+m}$.

**Theorem 7.6 (Block divisibility).** *Let $q$ be prime and let $i$ be an index with $p_{i+1} > q$. Then there exist $j < k < q$ with*
$$q \ \Big|\ \sum_{m = j}^{k-1} g_{i+m}.$$

*Proof.* The $q$ primes $p_{i+1}, \dots, p_{i+q}$ all exceed $q$, hence none is divisible by $q$, so their residues mod $q$ lie in the $q-1$ classes $\{1, \dots, q-1\}$. By pigeonhole two coincide, say those of index $i+j$ and $i+k$ with $j < k < q$. Their difference is divisible by $q$, and telescoping the barcode gives
$$p_{i+k+1} - p_{i+j+1} = \sum_{m=j}^{k-1} g_{i+m}. \qquad\square$$

**Theorem 7.7 (No long constant runs).** *Let $q$ be prime, $p_{i+1} > q$, and suppose $g_{i+m} = d$ for all $m < q-1$. Then $q \mid d$.*

*Proof.* Take the block $[j,k)$ from Theorem 7.6; the block sum is $(k-j)d$ and $q \mid (k-j)d$. Since $q$ is prime and $0 < k - j < q$, $q \nmid (k-j)$, so $q \mid d$. $\square$

**Corollary 7.8 (No four consecutive twin bars).** *Past $p = 5$ there is no run of four consecutive bars all of length $2$ — equivalently, no five primes in arithmetic progression with common difference $2$.* Indeed $q = 5$ would give $5 \mid 2$.

**Theorem 7.9 (Cap on the twin step).** *For every $n$, $\tau(n) \le \lfloor n/2 \rfloor + 3$.*

*Proof.* By Theorem 5.2, $\tau(n)$ is the cardinality of $S = \{ i < n : g_i = 2\}$. By Theorem 7.3, $S$ contains no two consecutive integers $\ge 2$. Split off the at most two elements $\{0,1\}$; on the remainder the map $i \mapsto \lfloor i/2 \rfloor$ is injective (two indices with the same halved value differ by $1$, which is forbidden) and lands in $\{0, \dots, \lfloor n/2\rfloor\}$. Hence $|S| \le \lfloor n/2 \rfloor + 1 + 2$. $\square$

No i.i.d. model satisfies a deterministic cap of this kind.

**Empirical corroboration.** Among the $78\,497$ bars below $10^6$: the adjacent pattern $(2,2)$ occurs exactly once (at $3,5,7$); $(4,4)$ and $(8,8)$ occur never; the repeats that *do* occur are $(6,6)$ with $1\,929$ occurrences, and $(12,12), (18,18), (24,24), (30,30), (36,36), (42,42)$ — all of them multiples of $3$, precisely as Theorem 7.2 requires; mixed patterns are common, e.g. $(2,4)$ with $1\,393$ and $(4,2)$ with $1\,444$ occurrences.

---

## 8. The barcode is a complete invariant

**Theorem 8.1 (Reconstruction).** *For every $n$, $p_{n+1} = 2 + \sum_{m < n} g_m$.*

*Proof.* The gaps telescope: $\sum_{m<n} (p_{m+2} - p_{m+1}) = p_{n+1} - p_1 = p_{n+1} - 2$. $\square$

Thus the persistence diagram of the prime point cloud determines the primes. Every arithmetic statement about primes is, formally, a statement about the barcode — which explains both why the barcode inherits so much structure (quantisation, exclusions, block laws) and why one should not expect the barcode to be "generic" in any probabilistic sense.

---

## 9. Algorithms

Three algorithms underlie the computations reported here; all are elementary and near-linear.

**A. Barcode extraction.** Sieve to $x$ in $O(x \log \log x)$; the barcode of $\{p \le x\}$ is the list of consecutive differences, computed in $O(\pi(x))$. Correctness is Proposition 2.4. This yields the empirical measure $\mu_n$, the gap histogram, and (by prefix sums) the Betti area.

**B. Betti curve and inversion.** From the histogram $h(2k) = \#\{i<n : g_i = 2k\}$, the Betti curve is $b_0(\varepsilon,n) = 1 + \sum_{2k > \varepsilon} h(2k)$, computable for all even thresholds simultaneously by a suffix sum in $O(g_{\max})$. Theorem 4.5 makes the map $h \leftrightarrow b_0$ a bijection, computed in either direction by prefix/suffix differencing.

**C. Cycle reduction (constructive $H_1$ vanishing).** Given a scale $\varepsilon$, a strictly increasing cloud, and a set $E$ of Rips edges with all degrees even, repeatedly: take the maximal vertex $v$ carried by $E$; take the two smallest left-endpoints $u < w$ among the edges $(\cdot, v) \in E$; emit the triangle $T(u,w,v)$; replace $E$ by $T \triangle E$. The proof of Theorem 6.4 shows each step is legal (the chord $(u,w)$ is a Rips edge), preserves the cycle condition, and strictly decreases the weight $\mu(E) = \sum_{(a,b) \in E} b$. The loop therefore terminates after at most $\mu(E)$ iterations, in $O(\mu(E) \cdot |E|)$ time with naive data structures, and outputs an explicit triangle decomposition — a certificate that the cycle bounds.

---

## 10. Discussion

### 10.1 What survives of the Poisson heuristic

Nothing above contradicts the Cramér-style heuristic *as an asymptotic guide*: the mean bar length $(p_n - 2)/n$ does track $\log p_n$, and large-scale statistics of prime gaps are well modelled by it. What fails is the heuristic's description of the barcode at *fine* scales, and the failure is exactly where arithmetic lives:

* divisibility by $2$ quantises the bar lengths, destroying absolute continuity;
* divisibility by $3$ creates a repulsion between $\varepsilon = 2$ merges, destroying independence;
* divisibility by each prime $q$ imposes a block law, destroying independence at range $q$.

A corrected model should therefore be a *quantised, congruence-constrained* point process — morally the Hardy–Littlewood singular-series model rather than a plain Poisson process. Our results are precisely the deterministic constraints such a model must respect.

### 10.2 Why $H_1$ was never available

The conjecture that $H_1$ should encode twin primes was a category error of dimension. The prime cloud lives in $\mathbb{R}^1$, whose Rips complexes are flag complexes of indifference graphs, and Theorem 6.4 shows those have no first homology at any scale. The interesting arithmetic is thus forced into $H_0$, where Theorem 5.2 places it precisely: at the first step of the staircase.

That said, Theorem 6.4 also indicates where a genuine $H_1$ theory of the primes could live: in dimension $\ge 2$. Embeddings such as $n \mapsto (p_n \bmod a, \; p_n \bmod b)$, the Ulam-spiral embedding, or the "prime lattice" $\{(p, q) : p, q \text{ prime}\} \subseteq \mathbb{R}^2$ all produce clouds for which loops are possible, and for which the barcode is not merely the gap sequence.

### 10.3 Interpretation of the area identity

Theorem 4.6 says that two invariants studied separately — total persistence and the Betti curve — are the same datum viewed in two ways, and that the datum is arithmetic: $p_n - 2$. This is a Fubini/layer-cake statement, but its consequence is a translation device: statements about prime gaps become statements about an integral over the scale parameter. For instance, the Prime Number Theorem becomes the assertion that the normalised Betti area $\frac1n\int_0^\infty (b_0 - 1)$ is asymptotic to $\log p_n$; large-gap results become lower bounds on the sup of the Betti staircase's support.

---

## 11. Future directions

Each of the following is falsifiable and sharply stated.

**C1. Admissibility is the only obstruction (barcode form of the $k$-tuple conjecture).** Call a tuple $(d_1, \dots, d_k)$ of positive even integers *barcode-admissible* if for every prime $q \le k+1$ the partial sums $0, d_1, d_1 + d_2, \dots, d_1 + \cdots + d_k$ do not cover all residues mod $q$. Conjecture: a pattern occurs as $k$ consecutive bars of the prime barcode, infinitely often, **iff** it is barcode-admissible. The "only if" half is proved here — Theorem 7.6 shows a non-admissible pattern can occur at most finitely often, and Theorem 7.7 is the constant-pattern case. The existence half is a barcode restatement of the Hardy–Littlewood/Dickson prime $k$-tuple conjecture. The key insight is that the $q = 3$ exclusion behind Theorem 7.3 is not a curiosity but the shadow of a complete residue-theoretic classification: pigeonhole on prime residues mod $q$ yields exactly the covering condition, so the set of realisable local barcode patterns is cut out by finitely many congruence conditions.

**C2. Betti-area asymptotics as an equivalent of the Prime Number Theorem and beyond.** The identity of Theorem 4.6 turns density statements into statements about the normalised Betti area. Making the equivalence quantitative — relating error terms in the Prime Number Theorem to convergence rates of $\frac1n\int_0^\infty (b_0(\varepsilon,n)-1)\,d\varepsilon$, and to the shape of the staircase near $\varepsilon \approx \log p_n$ — would give a topological reformulation of the classical analytic estimates, and potentially a Riemann-hypothesis-equivalent statement about the Betti curve's fluctuation.

**C3. Higher-dimensional embeddings.** Since $H_1$ vanishes identically on a line, the natural next question is which planar or higher-dimensional embeddings of the primes produce nontrivial persistent $H_1$, and whether the resulting bars have arithmetic meaning (e.g. modular embeddings $n \mapsto (p_n \bmod a, p_n \bmod b)$, where admissible residue patterns should control loop formation).

**C4. Stability and inverse problems.** Theorem 3.7 shows the prime barcode is separated from all odd lengths by $1$. One can ask for the precise bottleneck-distance radius within which no absolutely continuous model fits, and — inversely — which quantised, congruence-constrained processes have barcodes within a prescribed bottleneck distance of the prime barcode.

**C5. Sharpening the twin-step cap.** Theorem 7.9 gives $\tau(n) \le n/2 + 3$; the true growth is conjecturally $\sim 2\Pi_2 \, n / \log p_n$ with $\Pi_2$ the twin prime constant. Any unconditional improvement of the deterministic cap using higher moduli ($q = 5, 7, \dots$ block laws) would be a purely combinatorial constraint on the Betti staircase.

---

## 12. Conclusion

The primes, laid on the real line, do have a topology — and it is entirely zero-dimensional. Their barcode is the sequence of prime gaps: atomic on $\{1\} \cup 2\mathbb{N}$, with hard empty windows that no exponential law can respect; heavy-tailed, with bars of arbitrarily large length; correlated, with $3$-divisibility forbidding adjacent equal bars and every prime $q$ imposing a block law; complete, reconstructing the primes exactly; and calibrated, with area $p_n - 2$ under its reduced Betti curve. In dimension one there is nothing: every cycle in the Rips complex of a line point cloud is a sum of triangles, so the conjectured twin-prime hole does not exist. The Twin Prime Conjecture is nonetheless present in the barcode, in an unexpectedly plain form — as the assertion that the single Betti step at scale $\varepsilon = 2$ grows without bound.
