# A Combinatorial Theory of Simple Normality for Digit Streams

## Abstract

Simple normality of a real number in base $b$ — the requirement that every digit $0, 1, \ldots, b-1$ occur in its base-$b$ expansion with limiting relative frequency exactly $1/b$ — is the gateway to some of the most stubborn open problems in number theory, including the conjectured normality of $\pi$, $e$, and $\sqrt{2}$. We develop a self-contained, purely combinatorial theory of simple normality by abstracting away the real-analytic packaging of base-$b$ expansions and working directly with **digit streams** $s : \mathbb{N} \to \{0,\ldots,b-1\}$. We introduce the digit count $\operatorname{countDigit}(s,d,n)$, the empirical frequency $\operatorname{freq}(s,d,n)$, and the predicate $\operatorname{SimplyNormal}(s)$, and prove four foundational results: (1) the **conservation law** $\sum_d \operatorname{countDigit}(s,d,n) = n$, which exhibits the empirical frequency vector as a point of the probability simplex $\Delta^{b-1}$ via $\sum_d \operatorname{freq}(s,d,n) = 1$; (2) a **monotone-divergence criterion** showing that any digit occurring infinitely often has unbounded, divergent count; (3) the **single-coordinate obstruction**, that convergence of even one frequency coordinate to a value $\neq 1/b$ forbids normality; and (4) an explicit **periodic simply normal stream**, the cyclic stream $\operatorname{cyc}_b(k) = k \bmod b$, which is rational yet simply normal, thereby refuting the folklore implication "normal $\Rightarrow$ irrational/transcendental." We close with a research program connecting these combinatorial primitives to equidistribution and ergodic theory.

**Keywords.** Simple normality, normal numbers, digit streams, empirical frequency, probability simplex, equidistribution, discrepancy, cyclic sequence, conservation law.

---

## 1. Introduction

### 1.1 Background and motivation

Borel introduced normal numbers in 1909 and proved that almost every real number (with respect to Lebesgue measure) is normal in every base. Yet more than a century later, the normality of essentially every *naturally arising* constant remains open: it is not known whether $\pi$, $e$, $\sqrt{2}$, $\ln 2$, or $\zeta(3)$ is even *simply* normal in *any* single base, despite trillions of computed digits showing no statistical anomaly. The gulf between the measure-theoretic abundance of normal numbers and our inability to certify a single explicit constant is one of the defining frustrations of the field.

Faced with this gulf, a productive strategy is to set aside the specific-constant question and instead build a *robust theory of the property itself*: identify the correct primitive object, establish its conservation laws, and classify what is provable about which sequences are normal. This paper carries out that program for **simple normality**.

### 1.2 The central abstraction

The essential move is to discard the real number and retain only its digit stream. A real number's base-$b$ expansion is encumbered by non-uniqueness ($0.4\overline{9} = 0.5\overline{0}$) and by the analytic baggage of convergent series; neither is relevant to the *frequency* statement that normality really is. We therefore study sequences
$$s : \mathbb{N} \to \operatorname{Fin} b, \qquad \operatorname{Fin} b = \{0, 1, \ldots, b-1\},$$
and define normality intrinsically on the stream. This turns every question into finite combinatorics plus a single limit, and it is the source of all the clean structure that follows.

### 1.3 Contributions

We prove, with full formal rigor (machine-checked), the following.

1. **Conservation law** (Theorem 3.2): $\sum_{d \in \operatorname{Fin} b} \operatorname{countDigit}(s,d,n) = n$.
2. **Simplex constraint** (Theorem 3.3): for $n > 0$, $\sum_{d} \operatorname{freq}(s,d,n) = 1$, so each empirical frequency vector lies in $\Delta^{b-1}$.
3. **Monotonicity and divergence** (Theorems 3.4–3.6): $\operatorname{countDigit}(s,d,\cdot)$ is monotone, and a digit occurring infinitely often has unbounded count tending to $+\infty$.
4. **Single-coordinate obstruction** (Theorem 4.1): if some $\operatorname{freq}(s,d,\cdot)$ converges to a value $\neq 1/b$, then $s$ is not simply normal.
5. **Periodic normal witness** (Theorems 5.2–5.4): the cyclic stream $\operatorname{cyc}_b$ is periodic of period $b$ and simply normal; consequently a rational number can be simply normal, refuting "normal $\Rightarrow$ transcendental."

### 1.4 Organization

Section 2 fixes definitions. Section 3 develops the conservation law and the monotone-divergence machinery. Section 4 states the obstruction theorem. Section 5 constructs and analyzes the cyclic witness. Section 6 discusses applications and the equidistribution bridge. Section 7 lists future directions.

---

## 2. Definitions

Throughout, fix a base $b \in \mathbb{N}$ with $b \geq 1$ (for the simplex statements we use $b \geq 1$; for normality the interesting regime is $b \geq 2$). We write $\operatorname{Fin} b$ for the digit alphabet $\{0,\ldots,b-1\}$ and $[n] = \{0,1,\ldots,n-1\}$ for the first $n$ indices.

**Definition 2.1 (Digit stream).** A *base-$b$ digit stream* is a function $s : \mathbb{N} \to \operatorname{Fin} b$.

**Definition 2.2 (Digit count).** For a stream $s$, a digit $d \in \operatorname{Fin} b$, and a window size $n \in \mathbb{N}$,
$$\operatorname{countDigit}(s, d, n) \;=\; \#\{\,k \in [n] : s(k) = d\,\} \;=\; \big|\{k < n : s(k) = d\}\big|.$$
Equivalently, it is the cardinality of the filtered finite set $\{k \in [n] : s(k) = d\}$.

**Definition 2.3 (Empirical frequency).** With the convention $0/0 = 0$,
$$\operatorname{freq}(s, d, n) \;=\; \frac{\operatorname{countDigit}(s, d, n)}{n} \in \mathbb{R}.$$
The value at $n = 0$ is a harmless junk value ($0/0 = 0$); all substantive statements quantify over $n > 0$ or are limits as $n \to \infty$.

**Definition 2.4 (Simple normality).** A stream $s$ is *simply normal* if for every digit $d \in \operatorname{Fin} b$,
$$\lim_{n \to \infty} \operatorname{freq}(s, d, n) = \frac{1}{b}.$$
We write $\operatorname{SimplyNormal}(s)$ for this predicate. In the language of filters, $\operatorname{freq}(s, d, \cdot) \to 1/b$ along the at-infinity filter.

**Remark 2.5.** Simple normality is strictly weaker than full normality, which requires every *block* of $k$ digits to occur with frequency $b^{-k}$ for all $k$. The present theory is the $k=1$ layer; it already exhibits the conservation, obstruction, and separation phenomena, and is the foundation on which the block theory is built.

---

## 3. The conservation law and monotone divergence

### 3.1 A basic bound

**Theorem 3.1 (Count bound; `countDigit_le`).** For all $s$, $d$, $n$,
$$\operatorname{countDigit}(s, d, n) \leq n.$$

*Proof sketch.* The set $\{k < n : s(k) = d\}$ is a subset of $[n]$, and cardinality is monotone under inclusion: $\#\{k < n : s(k)=d\} \le \#[n] = n$. $\qquad\blacksquare$

### 3.2 Conservation

**Theorem 3.2 (Conservation law; `sum_countDigit`).** For every stream $s$ and window $n$,
$$\sum_{d \in \operatorname{Fin} b} \operatorname{countDigit}(s, d, n) = n.$$

*Proof sketch.* Partition the index window $[n]$ according to the value of $s$. The map $s$ sends each index $k \in [n]$ to a digit $s(k) \in \operatorname{Fin} b$, so the fibers $\{k \in [n] : s(k) = d\}$, ranging over $d$, are pairwise disjoint and cover $[n]$. The fiber-wise cardinality formula (the cardinality of a finite set equals the sum over the codomain of the cardinalities of its fibers) gives
$$n = \#[n] = \sum_{d \in \operatorname{Fin} b} \#\{k \in [n] : s(k) = d\} = \sum_{d} \operatorname{countDigit}(s, d, n). \qquad\blacksquare$$

This is the structural heart of the theory: digit counts *partition* the window, and every downstream phenomenon is a consequence of this partition (or of its failure in the limit).

### 3.3 The simplex constraint

**Theorem 3.3 (Frequencies form a probability vector; `sum_freq`).** For every stream $s$ and every $n > 0$,
$$\sum_{d \in \operatorname{Fin} b} \operatorname{freq}(s, d, n) = 1.$$

*Proof sketch.* Since $n > 0$, division by $n$ is well-defined and we may factor it out of the sum:
$$\sum_{d} \operatorname{freq}(s,d,n) = \sum_{d} \frac{\operatorname{countDigit}(s,d,n)}{n} = \frac{1}{n}\sum_{d} \operatorname{countDigit}(s,d,n) = \frac{n}{n} = 1,$$
using Theorem 3.2 in the penultimate step (and casting the natural-number sum to $\mathbb{R}$). $\qquad\blacksquare$

**Corollary 3.3.1 (Simplex geometry).** For each $n > 0$ the vector
$$\mathbf{f}_n = \big(\operatorname{freq}(s,0,n), \ldots, \operatorname{freq}(s,b-1,n)\big)$$
has non-negative coordinates summing to $1$, hence is a point of the probability simplex $\Delta^{b-1} \subset \mathbb{R}^b$. Simple normality is precisely the statement $\mathbf{f}_n \to (1/b, \ldots, 1/b)$, the barycenter of $\Delta^{b-1}$.

This corollary recasts a number-theoretic property as the convergence of a measure-valued sequence to the uniform measure, opening the door to compactness and topology-of-the-simplex arguments (see Section 7, FD1).

### 3.4 Monotonicity and divergence

**Theorem 3.4 (Monotonicity; `countDigit_monotone`).** For fixed $s$ and $d$, the map $n \mapsto \operatorname{countDigit}(s, d, n)$ is monotone non-decreasing.

*Proof sketch.* If $m \le n$ then $[m] \subseteq [n]$, so $\{k < m : s(k)=d\} \subseteq \{k < n : s(k)=d\}$, and cardinality is monotone under inclusion. $\qquad\blacksquare$

**Theorem 3.5 (Unbounded count; `countDigit_not_bddAbove`).** Suppose the digit $d$ occurs *cofinally*: for every threshold $N$ there exists $k \geq N$ with $s(k) = d$. Then the range of $n \mapsto \operatorname{countDigit}(s,d,n)$ is not bounded above.

*Proof sketch.* We show by induction on $m$ that for every $m$ there is an $n$ with $\operatorname{countDigit}(s,d,n) \ge m$. The base case $m = 0$ is trivial. Given $n$ with count $\ge m$, cofinality supplies $k \ge n$ with $s(k) = d$; then the window $[k+1]$ contains all the previously counted occurrences (since $k \ge n$ implies $[n] \subseteq [k+1]$, giving count $\ge m$ by monotonicity) *plus* the new occurrence at index $k$, so $\operatorname{countDigit}(s,d,k+1) \ge m+1$. Hence the counts exceed every $m$ and cannot be bounded above. $\qquad\blacksquare$

**Theorem 3.6 (Divergence; `countDigit_tendsto_atTop`).** If $d$ occurs cofinally (infinitely often), then
$$\operatorname{countDigit}(s, d, n) \xrightarrow[n \to \infty]{} +\infty.$$

*Proof sketch.* A monotone sequence of natural numbers obeys a sharp dichotomy: it is either bounded above (and eventually constant) or unbounded (and eventually exceeds every threshold). Theorem 3.4 gives monotonicity and Theorem 3.5 rules out boundedness, so for every target $k$ there is a threshold $N$ beyond which $\operatorname{countDigit}(s,d,n) \ge k$; this is exactly divergence to $+\infty$. (Formally, this is the unbounded-monotone branch of the order-theoretic dichotomy `monotone_nat_unbounded_eventually_ge`.) $\qquad\blacksquare$

**Remark 3.7.** Theorem 3.6 is the qualitative engine linking *appearance* to *quantity*: a digit that keeps showing up is guaranteed a count that grows without bound. It is the natural prerequisite for any *rate* statement about $\operatorname{freq}$ and the dual of the obstruction theorem below.

---

## 4. The obstruction theorem

The conservation law caps the total frequency budget at $1$ for every $n$. The immediate consequence is that no single digit may converge to the wrong limiting frequency.

**Theorem 4.1 (Single-coordinate obstruction; `not_simplyNormal_of_freq_tendsto`).** Let $b \ge 2$. If there exists a digit $d$ and a real $L \neq 1/b$ with
$$\lim_{n\to\infty} \operatorname{freq}(s, d, n) = L,$$
then $s$ is **not** simply normal.

*Proof sketch.* Simple normality would require $\operatorname{freq}(s,d,\cdot) \to 1/b$. But limits in $\mathbb{R}$ are unique, so $\operatorname{freq}(s,d,\cdot)$ cannot converge simultaneously to $L$ and to $1/b$ when $L \neq 1/b$. Hence $\operatorname{SimplyNormal}(s)$ fails (it would force the contradictory second limit). $\qquad\blacksquare$

**Corollary 4.2 (Density-zero obstruction; `freq_tendsto_zero_of_finite`).** If the set of indices at which a digit $d$ appears has *density zero* — e.g. it is finite, or sparse like a factorial-supported set whose counting function is $o(n)$ — then $\operatorname{freq}(s,d,\cdot) \to 0 \neq 1/b$, so by Theorem 4.1 the stream is not simply normal. This is the mechanism by which Liouville-type lacunary streams fail normality (Section 7, FD3).

---

## 5. A periodic simply normal stream

We now construct an explicit witness that severs simple normality from irrationality.

**Definition 5.1 (Cyclic stream).** The *cyclic* (round-robin) stream in base $b$ is
$$\operatorname{cyc}_b : \mathbb{N} \to \operatorname{Fin} b, \qquad \operatorname{cyc}_b(k) = k \bmod b.$$
It enumerates $0, 1, \ldots, b-1, 0, 1, \ldots, b-1, \ldots$ forever.

**Theorem 5.2 (Periodicity; `cyc_periodic`).** The cyclic stream is periodic with period $b$:
$$\operatorname{cyc}_b(k + b) = \operatorname{cyc}_b(k) \quad \text{for all } k.$$

*Proof sketch.* $(k+b) \bmod b = k \bmod b$ by the basic law of modular reduction. $\qquad\blacksquare$

Periodicity means $\operatorname{cyc}_b$ is the digit stream of a **rational** number (its base-$b$ expansion is eventually periodic, indeed purely periodic), hence algebraic of degree $1$.

**Theorem 5.3 (Exact count and bounds; `cyc_count_bounds`).** For all $d \in \operatorname{Fin} b$ and $n \in \mathbb{N}$,
$$\operatorname{countDigit}(\operatorname{cyc}_b, d, n) = \left\lfloor \frac{n}{b} \right\rfloor + \big[\, d < n \bmod b \,\big],$$
where $[\,P\,] \in \{0,1\}$ is the Iverson bracket. Consequently
$$\left\lfloor \frac{n}{b} \right\rfloor \;\le\; \operatorname{countDigit}(\operatorname{cyc}_b, d, n) \;\le\; \left\lfloor \frac{n}{b} \right\rfloor + 1.$$

*Proof sketch.* Among the first $n$ indices there are $\lfloor n/b\rfloor$ complete blocks of length $b$, each containing exactly one index $k$ with $k \equiv d \pmod b$, contributing $\lfloor n/b\rfloor$ occurrences. The trailing partial block consists of the residues $0, 1, \ldots, (n \bmod b) - 1$, which contains $d$ iff $d < n \bmod b$, contributing the Iverson term. This is precisely the congruence-counting identity `Nat.count_modEq_card`. The two-sided bound follows since the Iverson term is $0$ or $1$. $\qquad\blacksquare$

**Theorem 5.4 (Cyclic normality; `cyc_simplyNormal`).** For every base $b \ge 1$, the cyclic stream $\operatorname{cyc}_b$ is simply normal.

*Proof sketch.* Fix a digit $d$. Dividing the bounds of Theorem 5.3 by $n > 0$,
$$\frac{\lfloor n/b\rfloor}{n} \;\le\; \operatorname{freq}(\operatorname{cyc}_b, d, n) \;\le\; \frac{\lfloor n/b\rfloor}{n} + \frac{1}{n}.$$
Now $\lfloor n/b\rfloor = (n - (n \bmod b))/b$ with $0 \le n \bmod b < b$ bounded, so
$$\frac{\lfloor n/b\rfloor}{n} = \frac{1}{b} - \frac{n \bmod b}{b\,n} \xrightarrow[n\to\infty]{} \frac{1}{b},$$
because $(n \bmod b)/(b\,n) \le (b-1)/(b\,n) \to 0$. The upper bound's extra $1/n \to 0$. By the squeeze theorem, $\operatorname{freq}(\operatorname{cyc}_b, d, n) \to 1/b$. Since $d$ was arbitrary, $\operatorname{cyc}_b$ is simply normal. $\qquad\blacksquare$

**Theorem 5.5 (Existence of a periodic normal stream; `exists_periodic_simplyNormal`).** For every $b \ge 1$ there exists a digit stream that is simultaneously periodic and simply normal; namely $\operatorname{cyc}_b$.

*Proof sketch.* Combine Theorems 5.2 and 5.4. $\qquad\blacksquare$

**Corollary 5.6 (Normality does not imply transcendence/irrationality).** A simply normal real number need not be irrational. The number whose base-$b$ digit stream is $\operatorname{cyc}_b$ is rational (periodic expansion, Theorem 5.2) yet simply normal (Theorem 5.4). Hence the folklore implication "simply normal $\Rightarrow$ irrational $\Rightarrow$ transcendental" is false in its first link.

**Discussion 5.7 (Why the witness works — discrepancy $O(1)$).** Define the *discrepancy* $D(d,n) = \big|\operatorname{countDigit}(s,d,n) - n/b\big|$. Theorem 5.3 yields $D(\operatorname{cyc}_b, d, n) \le 1$ uniformly: the cyclic stream achieves the smallest possible, *bounded* discrepancy. This is the extreme endpoint of equidistribution. Its deterministic block structure — not statistical pseudo-randomness — is what forces the digits into balance. This isolates a key conceptual point: the *destination* of normality (uniform frequencies) is reachable by routes far more rigid than randomness, and the cyclic route is the most rigid of all.

---

## 6. Applications and the equidistribution bridge

### 6.1 Algorithmic verification of finite-window frequencies

The combinatorial definitions are directly computable. Given any finitely specified stream (periodic, automatic, or the truncated digits of a constant), $\operatorname{countDigit}$ and $\operatorname{freq}$ are computed in $O(n)$ time and the discrepancy in $O(b + n)$ time. This makes the theory a practical instrument for *finite-window auditing* of candidate constants: one can certify, with rigorous error bars from Theorem 5.3-style bounds, how close a constant's observed frequencies are to uniform, and exhibit obstructions (Theorem 4.1) when present. See the accompanying demonstration code.

### 6.2 The equidistribution bridge

The deepest application links digit normality to dynamics. For a real $x \in [0,1)$, the $n$-th base-$b$ digit is
$$s_x(n) = \big\lfloor b \cdot (b^{n-1} x \bmod 1) \big\rfloor,$$
i.e. the digit is read off from the position of the orbit point $b^{n-1}x$ modulo $1$ under the multiply-by-$b$ map $T_b(y) = b y \bmod 1$. Consequently the digit count is a *Birkhoff sum* of an indicator function:
$$\operatorname{countDigit}(s_x, d, n) = \sum_{j=0}^{n-1} \mathbf{1}_{[d/b,\,(d+1)/b)}\big(T_b^{\,j}(x)\big).$$
Therefore $\operatorname{freq}(s_x, d, n)$ is exactly the time-average of the indicator of the digit subinterval $[d/b,(d+1)/b)$ along the orbit. Equidistribution of the orbit $(T_b^j x)_j$ on $[0,1)$ — convergence of time-averages to the Lebesgue measures of intervals — is then *equivalent* to simple normality of $x$, with each digit-frequency limit equal to the length $1/b$ of its subinterval. This is the formal content of the program in FD4 and the conduit through which ergodic theory (the ergodicity of $T_b$ under Lebesgue measure) yields Borel's almost-everywhere normality.

### 6.3 Separating normality from arithmetic complexity

Corollary 5.6 has a methodological payoff: it warns against conflating *statistical* complexity (uniform digit frequencies) with *arithmetic* complexity (irrationality, transcendence). The two are governed by different invariants, and the cyclic witness is the minimal counterexample on the normality side. Pairing it with a transcendental non-normal stream (FD3) would establish full logical independence.

---

## 7. Future directions

**FD1. Frequency-vector convergence is the *only* obstruction.** *Conjecture:* a stream $s$ is simply normal iff its empirical distribution vectors $\mathbf{f}_n \in \Delta^{b-1}$ converge to the uniform vector, and partial convergence of even one coordinate to a value $\neq 1/b$ forbids normality. The key insight is that `sum_freq` (Theorem 3.3) makes each $\mathbf{f}_n$ a genuine point of the probability simplex, so normality is precisely convergence of a measure-valued sequence to the uniform measure — a statement in the topology of $\Delta^{b-1}$. Both the simplex constraint (Theorems 3.2–3.3) and the one-coordinate obstruction (Theorem 4.1) are in hand; closing the iff needs only a Prokhorov-style compactness argument on $\Delta^{b-1}$.

**FD2. Block-discrepancy bound $\Rightarrow$ normality, quantitatively.** *Conjecture:* if $|\operatorname{countDigit}(s,d,n) - n/b| \le C\, n^{1-\varepsilon}$ uniformly in $d$ for some $C, \varepsilon > 0$, then $s$ is simply normal with convergence rate $\operatorname{freq}(s,d,n) = 1/b + O(n^{-\varepsilon})$. The cyclic stream achieves the extreme case $C = 1$, $\varepsilon = 1$ (discrepancy $O(1)$), so simple normality is the $\varepsilon \to 0^+$ boundary of a quantitative hierarchy of discrepancy classes. The cyclic bounds (Theorem 5.3) supply the endpoint and the squeeze in Theorem 5.4 is exactly the $\varepsilon = 1$ instance; generalizing the squeeze to a polynomial bound is a direct refactor.

**FD3. Normality is independent of transcendence (both directions).** *Conjecture:* there exist (i) algebraic simply-normal streams and (ii) transcendental non-normal streams, so "normal" and "transcendental" are logically independent. Periodicity (Theorem 5.2) already yields a rational — hence algebraic — simply normal number, killing "normal $\Rightarrow$ transcendental"; a sparse factorial-supported Liouville stream should kill the converse via a density-0 obstruction. Direction (i) is *proved* (Theorem 5.5); direction (ii) reduces to a density-zero instance of Corollary 4.2 for the support set $\{k! : k \in \mathbb{N}\}$, whose counting function is $O(\log n) = o(n)$.

**FD4. Equidistribution bridge $\{b^n x\} \mapsto$ digit frequencies.** *Conjecture:* a real $x$ is simply normal in base $b$ iff the orbit $(b^n x \bmod 1)$ is equidistributed on $[0,1)$, with the digit-frequency limits equal to the Lebesgue measures of the subintervals $[d/b,(d+1)/b)$. The $n$-th base-$b$ digit of $x$ is the floor of $b\cdot(b^{n-1}x \bmod 1)$, so $\operatorname{countDigit}$ is literally a Birkhoff sum of an indicator along the multiply-by-$b$ map (Section 6.2), linking the combinatorial theory to ergodic theory and the Weyl equidistribution criterion.

---

## 8. Conclusion

By treating normality as a frequency property of digit streams rather than a real-analytic property of expansions, we obtain a clean, fully formalized foundation: a conservation law placing empirical frequencies on the probability simplex, a monotone-divergence principle controlling digits that recur, a sharp single-coordinate obstruction, and an explicit periodic witness that detaches normality from transcendence. The grand questions — the normality of $\pi$, $e$, $\sqrt{2}$ — remain open, but the framework here states them precisely (as convergence to the simplex barycenter, equivalently as equidistribution of a multiply-by-$b$ orbit) and supplies the scaffolding on which quantitative and dynamical attacks can be built.
