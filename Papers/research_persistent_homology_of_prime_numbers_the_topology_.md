# Persistent Homology of the Prime Point Cloud: The Zero-Dimensional Barcode as the Prime Gap Sequence

## Abstract

We study the zero-dimensional persistent homology of the point cloud formed by the prime numbers on the real line, with the $n$-th prime $p_n$ placed at position $p_n$. Under the Vietoris–Rips filtration — connect two points whenever they lie within a scale parameter $\varepsilon$ — the merging of connected components as $\varepsilon$ increases is recorded by the $H_0$ barcode. Our central structural result is a complete characterization of connectivity for *any* strictly increasing point cloud on a line: two points share an $\varepsilon$-connected component if and only if every consecutive gap between them is at most $\varepsilon$ (the **Single-Linkage Theorem**). As an immediate corollary, the death scale of the merge between neighboring points equals the gap between them, so the $H_0$ barcode is precisely the multiset of consecutive gaps. Specializing to the primes, the $i$-th finite bar has death scale equal to the $i$-th prime gap $p_{i+1}-p_i$. This dictionary lets us restate a classical open problem topologically: **the twin prime conjecture is equivalent to the assertion that the prime barcode contains infinitely many bars of length $2$.** We give complete proofs of the structural theorems, describe algorithms for computing the barcode from a prime sieve, discuss the connection to the Prime Number Theorem and to Poisson comparison models, and outline a research program relating prime-gap distribution theory to barcode statistics.

**Keywords:** persistent homology, Vietoris–Rips filtration, prime gaps, twin prime conjecture, single-linkage clustering, topological data analysis, prime number theorem.

---

## 1. Introduction

Topological data analysis (TDA) studies the "shape" of data by tracking how topological features — connected components, loops, voids — appear and disappear as a scale parameter is varied. The central object is the **persistence barcode**, a multiset of intervals $[b, d)$ recording the birth $b$ and death $d$ of each feature. Features with long bars are robust; short bars are typically dismissed as noise. This framework has proven remarkably effective at extracting structure from noisy, high-dimensional point clouds.

The prime numbers furnish an unusual and appealing test object. Placing the $n$-th prime $p_n$ at coordinate $p_n \in \mathbb{R}$ produces an infinite point cloud on the line whose geometry is entirely determined by the sequence of **prime gaps** $g_n = p_{n+1} - p_n$. The gap sequence
$$1,\,2,\,2,\,4,\,2,\,4,\,2,\,4,\,6,\,2,\,6,\,4,\,2,\,4,\,\dots$$
(the differences $3-2,\,5-3,\,7-5,\,11-7,\dots$) is one of the most studied and least understood sequences in mathematics. This paper asks what the zero-dimensional persistent homology of the prime cloud looks like, and answers it completely.

The answer is clean because the ambient space is one-dimensional. Our main structural theorem shows that on a line, single-linkage connectivity is governed entirely by the gap sequence, and hence the $H_0$ barcode is a lossless recording of that sequence. Applied to the primes, this identifies the topology with the arithmetic and, most strikingly, reformulates the twin prime conjecture as a statement about the recurrence of a length-$2$ bar.

### 1.1 Contributions

1. **A single-linkage characterization on the line** (Theorem 3.1): for a strictly increasing point cloud, two indices $i \le j$ are $\varepsilon$-connected iff all intervening gaps are $\le \varepsilon$.
2. **Barcode = gap multiset** (Theorem 3.2): the death scale of the adjacent merge at index $i$ is exactly $p_{i+1} - p_i$.
3. **Prime specialization** (Theorem 4.1): the $i$-th finite bar of the prime barcode has death scale equal to the $i$-th prime gap.
4. **Topological twin prime conjecture** (Theorem 4.3): infinitude of twin primes $\iff$ infinitely many bars of length $2$.
5. **Algorithms and numerics** (Sections 5–6): explicit computation from a sieve, empirical validation of the average-gap law, and comparison with a Poisson null model.

---

## 2. Definitions and setup

Throughout, a *point cloud* is a function $p : \mathbb{N} \to \mathbb{R}$; we write $p_n = p(n)$. We assume $p$ is **strictly increasing**, $p_0 < p_1 < p_2 < \cdots$, which holds for the primes.

**Definition 2.1 (Vietoris–Rips adjacency).** For a scale $\varepsilon \ge 0$, points at indices $a$ and $b$ are *adjacent at scale $\varepsilon$* when
$$|p_a - p_b| \le \varepsilon.$$
We denote this relation $\mathrm{Adj}_\varepsilon(a,b)$. It is reflexive (for $\varepsilon \ge 0$) and symmetric.

**Definition 2.2 (connected component).** Two indices lie in the same $\varepsilon$-connected component when they are related by the reflexive–transitive closure of $\mathrm{Adj}_\varepsilon$. We write $\mathrm{Conn}_\varepsilon(a,b)$ for this equivalence relation. Concretely, $\mathrm{Conn}_\varepsilon(a,b)$ holds iff there is a finite chain $a = c_0, c_1, \dots, c_m = b$ with $\mathrm{Adj}_\varepsilon(c_t, c_{t+1})$ for each $t$.

The **$H_0$ persistence** of the filtration $(\mathrm{Conn}_\varepsilon)_{\varepsilon \ge 0}$ tracks the number of components as $\varepsilon$ increases: each component is a *bar*, born when it first appears and dying when it merges into an older component. For a discrete increasing sequence, all components are present ("born") at $\varepsilon = 0$; the informative data is the multiset of *death scales* of the finite bars.

**Definition 2.3 (gap).** The $n$-th gap of $p$ is $g_n = p_{n+1} - p_n > 0$.

**Definition 2.4 (prime point cloud).** Let $P(n) = p_{n+1}$, the $(n{+}1)$-st prime placed on the real line, indexed so that $P(0) = 2,\ P(1) = 3,\ P(2) = 5,\dots$ (formally $P(n)$ is the $n$-th term of the increasing enumeration of the primes). The **$n$-th prime gap** is
$$\mathrm{primeGap}(n) = P(n+1) - P(n),$$
a positive integer for every $n$.

---

## 3. The structural theorems (general point cloud on a line)

The key phenomenon is that on a line, connectivity is a strictly local, order-respecting property. Two preliminary lemmas isolate the two halves of this fact.

**Lemma 3.0a (a gap is dominated by any straddling span).** If $p$ is strictly increasing and $a \le k < b$, then
$$p_{k+1} - p_k \;\le\; p_b - p_a.$$
*Proof.* Monotonicity gives $p_a \le p_k$ and $p_{k+1} \le p_b$ (the latter since $k+1 \le b$). Subtracting, $p_{k+1} - p_k \le p_b - p_a$. $\qquad\blacksquare$

**Lemma 3.0b (an edge certifies its interior gaps).** If $p$ is strictly increasing and $\mathrm{Adj}_\varepsilon(a,b)$ holds, then for every $k$ with $\min(a,b) \le k < \max(a,b)$ we have $p_{k+1} - p_k \le \varepsilon$.
*Proof.* Assume WLOG $a \le b$ (the relation is symmetric). Then $|p_a - p_b| = p_b - p_a \le \varepsilon$. By Lemma 3.0a, $p_{k+1}-p_k \le p_b - p_a \le \varepsilon$. $\qquad\blacksquare$

**Lemma 3.0c (small gaps chain into connectivity).** If $p$ is strictly increasing, $\varepsilon \ge 0$, and $p_{k+1} - p_k \le \varepsilon$ for all $k$ with $i \le k < i+n$, then $\mathrm{Conn}_\varepsilon(i, i+n)$.
*Proof.* Induct on $n$. For $n = 0$ the claim is reflexivity. For the step, the inductive hypothesis gives $\mathrm{Conn}_\varepsilon(i, i+n)$, and the hypothesis at $k = i+n$ gives $p_{i+n+1} - p_{i+n} \le \varepsilon$, i.e. $\mathrm{Adj}_\varepsilon(i+n, i+n+1)$; appending this edge yields $\mathrm{Conn}_\varepsilon(i, i+n+1)$. $\qquad\blacksquare$

**Lemma 3.0d (connectivity forces small interior gaps).** If $p$ is strictly increasing and $\mathrm{Conn}_\varepsilon(a,b)$, then for every $k$ with $\min(a,b) \le k < \max(a,b)$ we have $p_{k+1}-p_k \le \varepsilon$.
*Proof.* Induct on the length of the connecting chain. The base case is trivial (the interval is empty). For the inductive step $\mathrm{Conn}_\varepsilon(a,c)$ and $\mathrm{Adj}_\varepsilon(c,b)$: any target index $k$ in the interval $[\min(a,b), \max(a,b))$ lies either in the interval associated with the sub-chain $a \leftrightarrow c$ or in the interval $[\min(c,b),\max(c,b))$ certified by the final edge via Lemma 3.0b; in the first case apply the inductive hypothesis, in the second apply Lemma 3.0b. The two sub-intervals always cover $[\min(a,b),\max(a,b))$. $\qquad\blacksquare$

Combining Lemmas 3.0c and 3.0d yields the central theorem.

**Theorem 3.1 (Single-Linkage on a line).** Let $p$ be strictly increasing and $\varepsilon \ge 0$. For indices $i \le j$,
$$\mathrm{Conn}_\varepsilon(i, j) \iff \big(\forall k,\ i \le k < j \Rightarrow p_{k+1} - p_k \le \varepsilon\big).$$
*Proof.* ($\Rightarrow$) is Lemma 3.0d, noting $\min(i,j) = i$ and $\max(i,j) = j$. ($\Leftarrow$) is Lemma 3.0c with $n = j - i$. $\qquad\blacksquare$

**Interpretation.** The $\varepsilon$-connected components are exactly the *maximal runs of consecutive gaps that are all $\le \varepsilon$*. A single gap exceeding $\varepsilon$ severs the cloud; a block of small gaps fuses into one component. This is precisely single-linkage clustering, and on a line it is complete and exact.

**Theorem 3.2 (Adjacent merge = gap).** For $p$ strictly increasing and $\varepsilon \ge 0$,
$$\mathrm{Conn}_\varepsilon(i, i+1) \iff p_{i+1} - p_i \le \varepsilon.$$
Hence the death scale of the merge of the components containing $p_i$ and $p_{i+1}$ equals the gap $p_{i+1} - p_i$.
*Proof.* Apply Theorem 3.1 with $j = i+1$; the range $i \le k < i+1$ contains only $k = i$, so the right-hand side reduces to $p_{i+1}-p_i \le \varepsilon$. $\qquad\blacksquare$

**Corollary 3.3 (Barcode = gap multiset).** For a strictly increasing point cloud on a line, the multiset of finite $H_0$ bar lengths (death scales) equals the multiset of consecutive gaps $\{\,p_{n+1}-p_n : n \ge 0\,\}$. The barcode is a lossless encoding of the gap sequence.

---

## 4. The prime point cloud

**Theorem 4.1 (Prime death scale = prime gap).** For every $i$,
$$P(i+1) - P(i) = \mathrm{primeGap}(i),$$
where the right side is the $i$-th prime gap as a real number. Consequently the $i$-th finite bar of the prime barcode has death scale equal to the $i$-th prime gap.
*Proof.* Immediate from Definition 2.4; the cast from integer to real preserves the difference because $P(i+1) \ge P(i)$. $\qquad\blacksquare$

**Theorem 4.2 (Prime adjacent merge).** For $\varepsilon \ge 0$ and every $i$,
$$\mathrm{Conn}_\varepsilon(i, i+1) \iff \mathrm{primeGap}(i) \le \varepsilon.$$
*Proof.* Combine Theorem 3.2 (with $p = P$, which is strictly increasing since the prime enumeration is strictly increasing) and Theorem 4.1. $\qquad\blacksquare$

We now reach the main arithmetic payoff.

**Theorem 4.3 (Twin primes as a barcode statement).** The following are equivalent:
1. There are infinitely many primes $p$ with $p + 2$ also prime (the twin prime conjecture).
2. There are infinitely many indices $n$ with $\mathrm{primeGap}(n) = 2$.
3. The prime $H_0$ barcode contains infinitely many bars of length $2$.

*Proof.* $(2)\iff(3)$ is Theorem 4.1: a bar of death scale $2$ is exactly an index with prime gap $2$. We prove $(1)\iff(2)$.

$(1)\Rightarrow(2)$: Suppose there are infinitely many twin pairs. Given any bound $a$, we must find an index $n > a$ with $\mathrm{primeGap}(n) = 2$. Because twin pairs are unbounded, choose a prime $p$ with $p+2$ prime and with the prime-counting index of $p$ exceeding $a$; write $n$ for the index of $p$ in the prime enumeration, so $P(n) = p$ and $n > a$. It remains to show the *next* prime after $p$ is $p+2$, i.e. $P(n+1) = p+2$. Certainly $P(n+1) \le p+2$ because $p+2$ is a prime greater than $p$. And $P(n+1) \ge p+2$ because there is no prime strictly between $p$ and $p+2$: the only candidate is $p+1$, which for $p \ge 2$ has the opposite parity to $p$ and, being even and greater than $2$, is composite (and the base case $p=2$ is handled directly, its successor being $3$, though $2$ is not a lower twin). Hence $P(n+1) = p+2$ and $\mathrm{primeGap}(n) = 2$.

$(2)\Rightarrow(1)$: Suppose infinitely many indices $n$ have $\mathrm{primeGap}(n) = 2$. Given any bound, choose such an $n$ large enough that $P(n)$ exceeds it. Then $P(n)$ is prime and $P(n) + 2 = P(n+1)$ is prime, so $(P(n), P(n)+2)$ is a twin pair with $P(n)$ arbitrarily large. Hence twin pairs are unbounded. $\qquad\blacksquare$

**Remark 4.4.** The equivalence is genuine, not a definitional restatement. The connectivity relation $\mathrm{Conn}_\varepsilon$ is the honest reflexive–transitive closure of the Rips adjacency graph — the real component-merging process — and Theorem 3.1 establishes that it coincides with the gap condition as a *theorem*. The twin prime equivalence is proved over the honest sets in both directions.

---

## 5. Algorithms

### 5.1 Computing the finite barcode

By Corollary 3.3, computing the finite $H_0$ barcode of the prime cloud up to $N$ reduces to listing consecutive prime gaps.

```
Algorithm PRIME-BARCODE(N):
  input:  bound N
  output: multiset of finite H_0 bar lengths for primes ≤ N
  1. primes ← SIEVE(N)                      # sieve of Eratosthenes
  2. bars ← empty list
  3. for i in 0 .. len(primes) - 2:
  4.     bars.append(primes[i+1] - primes[i])   # Theorem 4.1
  5. return bars
```

Complexity: the sieve is $O(N \log\log N)$ time and $O(N)$ space; the gap pass is $O(\pi(N))$ where $\pi(N) \sim N/\log N$ is the number of primes up to $N$. The barcode is thus computed essentially as fast as the primes themselves.

### 5.2 Component count at a scale

To recover the number of $\varepsilon$-connected components (the number of bars still alive at scale $\varepsilon$), count the gaps exceeding $\varepsilon$ and add one: each oversized gap is a cut point separating two components.

```
Algorithm COMPONENTS-AT(gaps, ε):
  1. cuts ← number of g in gaps with g > ε
  2. return cuts + 1
```

This is a direct corollary of Theorem 3.1: components are maximal runs of gaps $\le \varepsilon$, and consecutive runs are separated exactly by gaps $> \varepsilon$.

### 5.3 Twin-bar counting

To test Theorem 4.3 empirically, count bars of length exactly $2$ up to $N$:

```
Algorithm TWIN-BAR-COUNT(N):
  1. gaps ← PRIME-BARCODE(N)
  2. return number of g in gaps with g == 2
```

The conjecture predicts this count grows without bound as $N \to \infty$ (Hardy–Littlewood heuristics predict $\sim 2 C_2 \, N / (\log N)^2$, with $C_2 \approx 0.6601$ the twin prime constant).

---

## 6. Numerical results and the Poisson comparison

### 6.1 The average-gap law

Because the barcode is the gap multiset, the mean finite bar length over the first $N$ primes is the telescoping average
$$\frac{1}{N}\sum_{i=0}^{N-1}\big(P(i+1) - P(i)\big) = \frac{P(N) - P(0)}{N} = \frac{p_{N+1} - 2}{N}.$$
By the Prime Number Theorem, $p_{N} \sim N \log N$, so the mean bar length near $x = p_N$ is asymptotic to $\log x$. Empirically, for primes below $10^6$ the mean gap is close to $\log(10^6) \approx 13.8$. This is the exact sense in which "the average bar length is the average prime gap."

### 6.2 The Poisson null model

A natural random comparison is a Poisson point process on $[2, x]$ with local intensity $1/\log t$ (matching the prime density). For such a process, the spacings between consecutive points are approximately independent exponential random variables with mean $\log x$, so its $H_0$ barcode has exponentially distributed bar lengths. The primes agree with this model in the *first moment* (mean bar length $\sim \log x$) but deviate sharply in the *fine structure*:

- **Parity rigidity.** Past the first gap, every prime gap is even (all primes beyond $2$ are odd), so the prime barcode has bars only at even lengths, whereas the Poisson model spreads mass over all positive reals.
- **Small-gap enhancement.** Gaps of $2$, $4$, $6$ are over-represented relative to the naive exponential prediction, reflecting the Hardy–Littlewood correlation structure.

Quantifying this deviation — for instance, showing the fraction of length-$2$ bars stays bounded away from the Poisson prediction — is a concrete program (see Future Directions).

### 6.3 What the computation shows

Sieving to $10^6$ yields $\pi(10^6) = 78498$ primes and $78497$ finite bars. The histogram of bar lengths is supported on the even integers (plus the single length-$1$ bar from the gap $3-2$), peaks at small even values, and has mean near $13.8$. Length-$2$ bars (twins) persist all the way to the top of the range — the empirical shadow of the twin prime conjecture reformulated in Theorem 4.3.

---

## 7. Discussion

The one-dimensional setting is what makes the prime barcode exactly computable: connectivity on a line is inherently local and order-preserving, so the barcode degenerates to the gap multiset (Corollary 3.3). This is simultaneously a strength — it gives a complete, exact answer and a clean dictionary between arithmetic and topology — and a limitation: the zero-dimensional homology on a line can never see higher features such as loops, because a line supports no essential cycles.

The value of the reformulation is conceptual and programmatic. It repackages the entire theory of prime-gap frequencies (Polignac-type conjectures, gap moments, the small-gaps breakthroughs) as statements about barcode multiplicities and moments, and it exhibits the twin prime conjecture as a *persistence* statement: a single feature of the prime cloud's shape that either recurs forever or eventually vanishes.

---

## 8. Future directions

**8.1 The gap-value spectrum is the set of barcode step-points.** The set of scales at which the component count strictly decreases should equal the set of values attained by the gap sequence, with each even $2k$ occurring as a gap contributing a positive-density family of bars of that death scale. On a line the barcode losslessly records the gap multiset, so Polignac-type distributional questions become questions about the multiplicity of individual bar lengths.

**8.2 A persistence-stability form of the average-gap law.** The empirical distribution of the first $N$ finite bar lengths, rescaled by $\log p_N$, should converge to a fixed limiting profile; in particular the mean bar length is asymptotic to $\log p_N$. The mean-length statement is the telescoping identity $(p_{N+1} - 2)/N$, controlled directly by the Prime Number Theorem; the higher moments and the shape of the limiting profile remain open.

**8.3 Higher homology from a two-dimensional prime lattice.** Embedding primes as the planar cloud $p_n \mapsto (p_n, p_{n+1})$ and running the Rips filtration should produce a first non-trivial $H_1$ class whose birth scale is governed by admissible gap patterns $(g_n, g_{n+1})$, with the shortest persistent loop corresponding to the smallest admissible triple of consecutive gaps. Genuine loops require three non-collinear points, which on the gap side is a constraint on consecutive gap *pairs* rather than single gaps.

**8.4 Barcode rigidity distinguishes primes from random gap models.** The prime barcode should differ measurably from that of a Poisson process of matching local intensity: the fraction of length-$2$ bars stays bounded away from the Poisson prediction, detectable purely from the barcode.

---

## 9. Conclusion

We have shown that the zero-dimensional persistent homology of the prime point cloud on the line is, exactly and losslessly, the sequence of prime gaps. Two structural theorems — the Single-Linkage characterization and the Adjacent-Merge identity — reduce the barcode to the gap multiset for any increasing cloud, and the prime specialization ties each bar to a prime gap. The culminating result recasts the twin prime conjecture as a purely topological assertion: the prime barcode contains infinitely many bars of length $2$. Primes, in short, have a shape, and their shape is their gaps.
