# Critical Geometry of Counted Proof Spaces

### Recoding invariance, uniform transition windows, dimension spectra, and the origin of power laws

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We study a deductive system through its *counting data*: the cumulative number $N(n)$ of derivable statements of encoded length at most $n$, measured against the ambient volume $S_k(n) = \sum_{i \le n} k^i$ of the $k$-letter language. Two encodings of the same system that translate into one another with additive length overhead at most $b$ distort metric balls by a radial shift of at most $b$. We determine precisely which observables survive such a *bounded recoding*, and which do not.

Two survive. The **count radius** $r(m) = \min\{n : N(n) \ge m\}$ is $b$-quasi-invariant, $|r_1(m) - r_2(m)| \le b$; and the **entropy dimension** $h = \lim_n \log N(n)/n$ is *exactly* invariant. The density level is not. We prove the exact splitting identity $S_k(n+b) = \sum_{i<b}k^i + k^b S_k(n)$, hence $S_k(n+b) \le 2k^b S_k(n)$ and the density distortion law $d_1(n) \le 2k^b\, d_2(n+b)$: a recoding acts additively on radii but *multiplicatively on levels*. This yields a critical-index sandwich across rescaled levels, and we show the rescaling is unavoidable: for every $D$ there are two antitone null profiles obeying exactly the distortion inequalities of an overhead-$1$ binary recoding whose same-level critical indices differ by at least $D$.

Sharpness is restored by exponential order. If $c a^n \le N(n) \le C a^n$ with $a < k$, then any radius at which the density is still at level $\varepsilon$ and any radius at which it has dropped below $\varepsilon$ are separated by at most $\log(2C/c)/\log(k/a)$ — a bound independent of $\varepsilon$. In cross-system form this gives the corrected quasi-invariance statement: two encodings whose counts share an exponential order have level-$\varepsilon$ critical indices within $\log(2C/c)/\log(k/a) + 1$ of one another, uniformly in $\varepsilon$; and an overhead-$b$ recoding perturbs the constants only by $a^{\pm b}$. For counts that are submultiplicative up to a factor $P$, Fekete's lemma supplies the matching lower bound $e^{Ln} \le P N(n)$, giving the unconditional window bound $\log(2CP)/\log(k/e^{L})$.

Beyond a single density we develop the **dimension spectrum**. Every $h \in [0, \log k]$ is the entropy dimension of a genuine subfamily, which has ambient density zero whenever $e^h < k$; unions take the maximum dimension; and strata meeting independently in the counting sense $|A\cap B|\cdot S_k(n) = |A|\cdot|B|$ intersect in dimension $h_1 + h_2 - \log k$, strictly below both when both strata are proper.

Finally we identify the origin of power laws in proof-length data. A single regime of entropy $s$ has geometric tail $e^{-sx}$ with the *constant* successive ratio $e^{-s}$, so no power law can arise homogeneously. The uniform scale mixture over $s \in [0,1]$ has the exact tail $(1 - e^{-x})/x$: an exact power law of index $-1$, with $xT(x) \to 1$, successive ratios tending to $1$, and no geometric dominating bound. Heterogeneity across regimes, and not any single entropy, is the mechanism.

**Keywords:** proof space, derivability density, prefix-free encoding, quasi-isometry, entropy dimension, phase transition, Fekete's lemma, regular variation, scale mixture.

---

## 1. Introduction

### 1.1 Counting a deductive system

Fix a finite alphabet with $k \ge 2$ letters and a prefix-free encoding of the statements of a deductive system as finite strings. Write $|\varphi|$ for the encoded length of a statement $\varphi$. The set of statements of length at most $n$ is a ball in the string metric, and its cardinality is the *ambient volume*

$$S_k(n) \;=\; \sum_{i=0}^{n} k^{i} \;=\; \frac{k^{n+1}-1}{k-1}.$$

Two elementary facts about $S_k$ will be used constantly: $k^n \le S_k(n)$, and $S_k(n) \le 2k^n$ when $k \ge 2$ (the geometric sum below the top layer is dominated by the top layer). So $S_k(n) \asymp k^n$ within a factor $2$.

Let $N(n)$ denote the number of *derivable* statements of length at most $n$. Two derived observables organise the paper.

**Definition 1.1 (derivability density).** $\;d_N(n) = N(n)/S_k(n)$.

**Definition 1.2 (entropy dimension).** A count $N$ *has entropy dimension* $h$ if $\log N(n)/n \to h$ as $n \to \infty$.

The ambient count has entropy dimension $\log k$; a system is *exponentially sparse* when its dimension is strictly smaller, and then $d_N(n) \to 0$.

### 1.2 The recoding problem

The trouble is that neither $N$ nor $d_N$ is intrinsic. Both depend on the encoding. The correct equivalence between encodings is the following.

**Definition 1.3 (bounded recoding, overhead $b$).** Two encodings of the same system are related by a *recoding of overhead $b$* if there are injections translating each into the other with $|\tau(\varphi)|_2 \le |\varphi|_1 + b$ and $|\sigma(\psi)|_1 \le |\psi|_2 + b$.

Injectivity plus the length bound gives the *ball comparison* immediately.

**Proposition 1.4 (balls shift radially).** Let $B_i(n)$ be the ball of radius $n$ in encoding $i$ and $f$ an injection with $|f(x)|_2 \le |x|_1 + b$. Then $|B_1(n)| \le |B_2(n+b)|$ for every $n$.

*Proof.* $f$ maps $B_1(n)$ injectively into $B_2(n+b)$, since $|x|_1 \le n$ implies $|f(x)|_2 \le n + b$. $\square$

For counting functions this reads

$$N_1(n) \le N_2(n+b), \qquad N_2(n) \le N_1(n+b) \qquad (n \in \mathbb{N}). \tag{$\ast$}$$

Condition $(\ast)$ — a radial shift by $b$ in both directions — is our standing abstraction of "same system, different writing". It is a quasi-isometry with multiplicative constant $1$ and additive constant $b$.

The naive expectation is that a *threshold* defined from the density should move by at most $b$ under $(\ast)$. Section 3 refutes this and Sections 4–5 identify the correct hypothesis under which a corrected statement holds.

### 1.3 Contributions

1. **Invariant observables** (§2): count radii are $b$-quasi-invariant; the entropy dimension is exactly invariant.
2. **Density distortion** (§3): an exact splitting identity for $S_k$, the multiplicative distortion law $d_1(n) \le 2k^bd_2(n+b)$, a critical-index sandwich across rescaled levels, and a counterexample showing the rescaling cannot be removed.
3. **Uniform transition windows** (§4): exact exponential order forces a level-independent window width $\log(2C/c)/\log(k/a)$; cross-system, this bounds the gap between critical indices of two encodings uniformly in $\varepsilon$.
4. **Submultiplicativity** (§5): Fekete's lemma with an explicit matching lower bound $e^{Ln} \le PN(n)$, yielding an unconditional window bound.
5. **Dimension spectrum** (§6): realization of every rate in $[0,\log k]$ at zero density, the union law, and the strict drop $h_1 + h_2 - \log k$ at independent intersections.
6. **Power laws from mixtures** (§7): the exact mixed tail $(1-e^{-x})/x$, regular variation of index $-1$, and the falsification of the single-regime geometric model.

---

## 2. Invariant observables

### 2.1 Count radii

**Definition 2.1 (count radius).** For a nondecreasing $N : \mathbb{N} \to \mathbb{N}$ and $m \in \mathbb{N}$,
$$r_N(m) \;=\; \min\{\,n \in \mathbb{N} : m \le N(n)\,\}$$
(with the convention that the minimum of the empty set is $0$). This is the observable dual to a density level: instead of fixing a radius and reading off a count, fix a count and read off a radius.

**Theorem 2.2 (radial quasi-invariance).** Assume $(\ast)$ and that for each $i$ there is some $n$ with $m \le N_i(n)$. Then
$$r_{N_2}(m) \le r_{N_1}(m) + b \qquad\text{and}\qquad r_{N_1}(m) \le r_{N_2}(m) + b,$$
i.e. $|r_{N_1}(m) - r_{N_2}(m)| \le b$.

*Proof.* By definition $m \le N_1(r_{N_1}(m))$, and $(\ast)$ gives $N_1(r_{N_1}(m)) \le N_2(r_{N_1}(m) + b)$. Hence $m \le N_2(r_{N_1}(m)+b)$, so the minimal radius at which $N_2$ reaches $m$ is at most $r_{N_1}(m)+b$. Swap the roles of the two systems for the other inequality. $\square$

This is the correct form of the heuristic "a threshold should move rather than disappear": *a radial threshold moves by at most the overhead*.

### 2.2 The entropy dimension is exactly invariant

**Lemma 2.3 (shift invariance of growth rates).** If $\log N(n)/n \to h$ then $\log N(n+b)/n \to h$ for each fixed $b$.

*Proof.* Write $\frac{\log N(n+b)}{n} = \frac{\log N(n+b)}{n+b}\cdot\frac{n+b}{n}$. The first factor tends to $h$ along the shifted subsequence, the second to $1$. $\square$

**Theorem 2.4 (exact invariance of the entropy dimension).** Suppose $N_1, N_2 \ge 1$ pointwise, satisfy $(\ast)$, and have entropy dimensions $h_1, h_2$. Then $h_1 = h_2$.

*Proof.* For $n \ge 1$, monotonicity of $\log$ and $N_1(n) \le N_2(n+b)$ give $\log N_1(n)/n \le \log N_2(n+b)/n$. Passing to the limit using Lemma 2.3 yields $h_1 \le h_2$; symmetry gives the reverse. $\square$

The contrast with the density is already visible: the growth rate is a *rate*, and a bounded shift of the argument is invisible to a rate. The density is a *level*, and levels are exactly what a shift destroys.

---

## 3. Density distortion, and the failure of same-level stability

### 3.1 The ambient volume moves multiplicatively

**Lemma 3.1 (exact splitting).** For all $k, n, b$,
$$S_k(n+b) \;=\; \Big(\sum_{i<b}k^{i}\Big) \;+\; k^{b}\,S_k(n).$$

*Proof.* Split the range $\{0,\dots,n+b\}$ as $\{0,\dots,b-1\}\sqcup\{b,\dots,b+n\}$ and factor $k^b$ out of the second block. $\square$

**Lemma 3.2.** For $k \ge 2$: $\sum_{i<b}k^i \le k^b$; $S_k(n) \le 2k^n$; and consequently
$$S_k(n+b) \;\le\; 2k^{b}\,S_k(n).$$

*Proof.* The first two are immediate inductions. For the third, apply Lemma 3.1 and note $\sum_{i<b}k^i \le k^b \le k^b S_k(n)$ since $S_k(n) \ge 1$. $\square$

**Theorem 3.3 (density distortion law).** If $k \ge 2$ and $N_1(n) \le N_2(n+b)$, then
$$d_{N_1}(n) \;\le\; 2k^{b}\; d_{N_2}(n+b).$$

*Proof.* $d_{N_1}(n) = N_1(n)/S_k(n) \le N_2(n+b)/S_k(n)$, and by Lemma 3.2, $1/S_k(n) \le 2k^b/S_k(n+b)$. $\square$

The exponential factor $2k^b$ is not an artefact of the estimate: the ambient volume genuinely grows by $k^b$ over a shift of $b$, so the *denominator* of the density is distorted exponentially while the numerator is only shifted.

### 3.2 The critical-index sandwich

**Definition 3.4 (level-$\varepsilon$ critical index).** Given a profile $d : \mathbb{N} \to \mathbb{R}$ and $\varepsilon > 0$, an index $c$ is the *level-$\varepsilon$ critical index* of $d$ if
$$\forall n:\quad d(n) < \varepsilon \iff c < n,$$
i.e. $c$ is the last radius at which $d$ is still at level $\varepsilon$. (Antitone profiles crossing $\varepsilon$ have such an index.)

**Theorem 3.5 (sandwich under multiplicative distortion).** Let $d_1, d_2$ satisfy $d_1(n) \le K d_2(n+b)$ and $d_2(n) \le K d_1(n+b)$ for a constant $K > 0$. Let $c_1$ be the level-$\varepsilon$ critical index of $d_1$, $c_{\mathrm{lo}}$ the level-$(\varepsilon/K)$ index of $d_2$, and $c_{\mathrm{hi}}$ the level-$(K\varepsilon)$ index of $d_2$. If $b \le c_1$ then
$$c_{\mathrm{hi}} + b \;\le\; c_1 \;\le\; c_{\mathrm{lo}} - b .$$

*Proof sketch.* Upper index: at $c_1 + 1$ we have $d_1(c_1+1) < \varepsilon$, and $d_2(c_1+1-b) \le K d_1(c_1+1) < K\varepsilon$, so $c_{\mathrm{hi}} < c_1 + 1 - b$. Lower index: at $c_1$ we have $\varepsilon \le d_1(c_1) \le K d_2(c_1+b)$, so $d_2(c_1+b) \ge \varepsilon/K$ and hence $c_1 + b \le c_{\mathrm{lo}}$. $\square$

**Corollary 3.6 (density form).** With $K = 2k^b$ furnished by Theorem 3.3, the level-$\varepsilon$ critical index of $d_{N_1}$ is sandwiched between the level-$2k^b\varepsilon$ and level-$\varepsilon/(2k^b)$ critical indices of $d_{N_2}$, each displaced by $b$.

### 3.3 The rescaling cannot be dropped

**Theorem 3.7 (unbounded critical-index gap).** For every $D \in \mathbb{N}$ there exist antitone profiles $p, q : \mathbb{N} \to \mathbb{R}$ with $p, q \to 0$, a level $\varepsilon > 0$ with $\varepsilon \le p(0)$ and $\varepsilon \le q(0)$, such that
$$p(n) \le 4\,q(n+1), \qquad q(n) \le 4\,p(n+1) \qquad (n \in \mathbb{N}),$$
— exactly the distortion inequalities produced by an overhead-$b=1$ recoding of a binary language, $K = 2\cdot 2^1 = 4$ — and whose level-$\varepsilon$ critical indices $c_p, c_q$ satisfy $c_q + D \le c_p$.

*Proof.* Take $p(n) = 1/(n+1)$ and $q(n) = 1/(2n+2) = p(n)/2$, and $\varepsilon = 1/(2D+2)$. Both are antitone and null. For the distortion inequalities, $4q(n+1) = 4/(2n+4) = 2/(n+2) \ge 1/(n+1) = p(n)$ for all $n \ge 0$, and $4p(n+1) = 4/(n+2) \ge 1/(2n+2) = q(n)$. For the indices: $p(n) < \varepsilon \iff 2D+2 < n+1 \iff 2D+1 < n$, so $c_p = 2D+1$; and $q(n) < \varepsilon \iff 2D + 2 < 2n+2 \iff D < n$, so $c_q = D$. Hence $c_p - c_q = D+1$. $\square$

**Interpretation.** The failure is structural, not technical. A recoding acts additively on radii but multiplicatively on levels. When the density decays *slowly* — here harmonically — a fixed multiplicative factor corresponds to an unbounded radial displacement, because the profile takes an unbounded number of steps to lose a factor of $2$. The level-$\varepsilon$ critical index is therefore **not** a recoding invariant, at any fixed level. The invariants are the count radius (Theorem 2.2) and the entropy dimension (Theorem 2.4).

Equivalently: sharpness of a threshold requires the profile to fall by a definite factor per unit radius. That is the hypothesis of the next section.

---

## 4. Uniform transition windows under exact exponential order

**Definition 4.1 (exact exponential order).** $N$ has *exact exponential order $a$ with constants $0 < c \le C$* if $c a^n \le N(n) \le C a^n$ for all $n$. We always assume $0 < a < k$ (exponential sparsity inside the ambient language).

**Lemma 4.2 (two-sided density bounds).** If $k \ge 2$, $a \ge 0$, and $c a^n \le N(n)$ for all $n$, then
$$\frac{c}{2}\Big(\frac{a}{k}\Big)^{n} \;\le\; d_N(n);$$
if $N(n) \le C a^n$ for all $n$, then $d_N(n) \le C (a/k)^n$.

*Proof.* Use $k^n \le S_k(n) \le 2k^n$: for the lower bound, $d_N(n) \ge c a^n / (2k^n)$; for the upper, $d_N(n) \le C a^n / k^n$. $\square$

So the density itself decays geometrically with ratio $a/k < 1$, and $\log(k/a)$ is the *decay rate per unit radius*. Converting a level distortion into a radial displacement now costs only $\log(\text{factor})/\log(k/a)$ steps. This is the entire content of the following.

**Theorem 4.3 (cross-system window bound).** Let $k \ge 2$, $0 < a < k$, $0 < c \le C$. Suppose $N^{\mathrm{up}}(m) \le C a^m$ and $c a^m \le N^{\mathrm{low}}(m)$ for all $m$. Let $\varepsilon \in \mathbb{R}$, and let $n_+, n_-$ satisfy
$$\varepsilon \le d_{N^{\mathrm{up}}}(n_+), \qquad d_{N^{\mathrm{low}}}(n_-) < \varepsilon .$$
Then
$$n_+ - n_- \;\le\; \frac{\log(2C/c)}{\log(k/a)} .$$

*Proof sketch.* If $n_+ \le n_-$ the right side is nonnegative (as $c \le 2C$) and there is nothing to prove. Otherwise chain the two hypotheses through Lemma 4.2:
$$\frac{c}{2}\Big(\frac{a}{k}\Big)^{n_-} \;\le\; d_{N^{\mathrm{low}}}(n_-) \;<\; \varepsilon \;\le\; d_{N^{\mathrm{up}}}(n_+) \;\le\; C\Big(\frac{a}{k}\Big)^{n_+}.$$
Rearranged, $(k/a)^{n_+-n_-} \le 2C/c$; taking logarithms and dividing by $\log(k/a) > 0$ finishes. $\square$

**Theorem 4.4 (uniform transition window).** Let $N$ have exact exponential order $a < k$ with constants $c \le C$. Then for *every* level $\varepsilon > 0$ and all radii $n_+, n_-$ with $\varepsilon \le d_N(n_+)$ and $d_N(n_-) < \varepsilon$,
$$n_+ - n_- \;\le\; \frac{\log(2C/c)}{\log(k/a)} .$$
The bound is independent of $\varepsilon$, hence independent of the cutoff.

*Proof.* Theorem 4.3 with $N^{\mathrm{up}} = N^{\mathrm{low}} = N$. $\square$

This is the sense in which a counted proof space of exponential order undergoes a genuine *phase transition*: the transition window separating the $\varepsilon$-thick from the $\varepsilon$-thin regime has a width fixed by the shape constants $(a, c, C, k)$ alone. Lowering $\varepsilon$ translates the window outward without smearing it.

**Theorem 4.5 (corrected quasi-invariance of critical indices).** Let $N_1, N_2$ both have exact exponential order $a < k$ with the same constants $c \le C$, and let $c_i$ be radii with
$$\varepsilon \le d_{N_i}(c_i), \qquad d_{N_i}(c_i + 1) < \varepsilon .$$
Then
$$|c_1 - c_2| \;\le\; \frac{\log(2C/c)}{\log(k/a)} + 1,$$
uniformly in $\varepsilon$.

*Proof.* Apply Theorem 4.3 twice, crossing the systems: with $N^{\mathrm{up}} = N_1$ at $n_+ = c_1$ and $N^{\mathrm{low}} = N_2$ at $n_- = c_2 + 1$ we get $c_1 - c_2 - 1 \le W$; swapping gives $c_2 - c_1 - 1 \le W$, where $W = \log(2C/c)/\log(k/a)$. $\square$

This is what survives Theorem 3.7: the gap is controlled not by the recoding overhead but by the exponential order of the counts, and it is finite precisely because the exponential decay converts a level distortion into a bounded radial shift.

**Theorem 4.6 (transfer of exponential order across a recoding).** Assume $(\ast)$ and let $N_1$ have exact exponential order $a > 0$ with constants $c \le C$. Then
$$\frac{c}{a^{b}}\,a^{m} \;\le\; N_2(m) \quad (m \ge b), \qquad N_2(m) \;\le\; (C a^{b})\, a^{m} \quad (m \ge 0).$$

*Proof.* For $m \ge b$: $N_2(m) \ge N_1(m-b) \ge c a^{m-b} = (c/a^b)a^m$. For the upper bound: $N_2(m) \le N_1(m+b) \le C a^{m+b} = (Ca^b)a^m$. $\square$

So exponential order is a property of the system rather than of the writing; a bounded recoding perturbs the constants by $a^{\pm b}$ only. Feeding these into Theorem 4.5 gives the index-gap bound $\big(\log(2C/c) + 2b\log a\big)/\log(k/a) + 1$ — again uniform in $\varepsilon$.

---

## 5. Submultiplicativity supplies the missing lower bound

Theorem 4.4 requires a *two-sided* exponential law. A convergent growth rate $\log N(n)/n \to L$ gives only $N(n) = e^{(L+o(1))n}$, which permits subexponential oscillation — exactly the oscillation that prevents a sharp finite crossing. The natural structural hypothesis for a deductive calculus removes it.

**Definition 5.1 (submultiplicativity up to a factor).** $N$ is *$P$-submultiplicative* ($P \ge 1$) if $N(m+n) \le P\,N(m)\,N(n)$ for all $m,n$. For a finitely generated calculus this expresses that a derivation of total length $m+n$ splits, up to bounded bookkeeping, into two derivations of lengths $m$ and $n$.

**Theorem 5.2 (Fekete bound for derivability counts).** Let $N(n) \ge 1$ for all $n$ and let $N$ be $P$-submultiplicative. Then the limit $L = \lim_n \log N(n)/n$ exists, and moreover
$$e^{L n} \;\le\; P\,N(n) \qquad \text{for every } n .$$

*Proof sketch.* Put $u(n) = \log(P\,N(n)) \ge 0$. Submultiplicativity gives $P N(m+n) \le (P N(m))(P N(n))$, so $u$ is subadditive. By Fekete's subadditive lemma $u(n)/n$ converges to $L' = \inf_n u(n)/n$, which is finite since $u \ge 0$; and $\log N(n)/n = u(n)/n - \log P / n \to L'$, so $L = L'$. Being an infimum, $L \le u(n)/n$ for all $n \ge 1$, i.e. $Ln \le \log(P N(n))$, i.e. $e^{Ln} \le P N(n)$. The case $n = 0$ is trivial since $P N(0) \ge 1$. $\square$

The point is that Fekete's lemma yields more than convergence: because the limit is an infimum, it provides the *matching lower bound for every single $n$*, with the explicit constant $1/P$. Submultiplicativity is precisely the hypothesis that suppresses oscillations invisible to a growth rate.

**Theorem 5.3 (uniform window for submultiplicative counts).** Let $k \ge 2$, $P \ge 1$, $N(n) \ge 1$, let $e^{Ln} \le P N(n)$ for all $n$ (e.g. by Theorem 5.2), let $N(n) \le C\,(e^{L})^{n}$ for all $n$, and let $e^{L} < k$. Then for every $\varepsilon$ and all radii with $\varepsilon \le d_N(n_+)$ and $d_N(n_-) < \varepsilon$,
$$n_+ - n_- \;\le\; \frac{\log(2CP)}{\log(k/e^{L})} .$$

*Proof.* Apply Theorem 4.4 with $a = e^{L}$, $c = P^{-1}$ (which is $\le C$, since $N(0) \ge 1$ forces $C \ge 1 \ge P^{-1}$), and simplify $2C/c = 2CP$. $\square$

---

## 6. The dimension spectrum of theorem families

Sparsity is one bit of information. Since every proper family has density zero, the density cannot distinguish families. The growth rate can, and it organises into a spectrum.

**Definition 6.1.** A *stratum* is a cumulative count $N$; it *has entropy dimension $h$* if $\log N(n)/n \to h$.

### 6.1 Every dimension is realized, and at zero density

**Definition 6.2 (canonical stratum).** $N_h(n) = \lceil e^{h n}\rceil$ for $h \ge 0$.

**Lemma 6.3.** $e^{hn} \le N_h(n) \le 2 e^{hn}$, and $N_h(n) \ge 1$.

*Proof.* The ceiling satisfies $x \le \lceil x \rceil < x + 1$, and $e^{hn} \ge 1$ gives $\lceil e^{hn}\rceil < e^{hn} + 1 \le 2e^{hn}$. $\square$

**Theorem 6.4 (realization of the spectrum).** For every $h \ge 0$, the canonical stratum has entropy dimension exactly $h$.

*Proof.* Taking logarithms in Lemma 6.3 and dividing by $n$ gives $h \le \log N_h(n)/n \le h + \log 2 / n$; squeeze. $\square$

**Theorem 6.5 (a proper stratum lives in the ambient language and has density zero).** If $e^{h} \le k$ then $N_h(n) \le S_k(n)$ for all $n$; and if $e^{h} < k$ (and $k \ge 2$, $h \ge 0$) then $d_{N_h}(n) \to 0$.

*Proof.* For the inclusion, $e^{hn} = (e^h)^n \le k^n \le S_k(n)$, and $N_h(n)$ is the least integer above $e^{hn}$. For the density, Lemma 6.3 gives $N_h(n) \le 2(e^h)^n$, so by Lemma 4.2 $d_{N_h}(n) \le 2(e^h/k)^n \to 0$. $\square$

Thus the interval $[0, \log k)$ of dimensions sits entirely inside the zero-density phase: a continuum of distinct strata that the provable/unprovable ratio cannot tell apart.

### 6.2 Unions: a supremum law

**Theorem 6.6 (union law).** If $N_1, N_2 \ge 1$ have entropy dimensions $h_1, h_2$, then $N_1 + N_2$ has entropy dimension $\max(h_1, h_2)$.

*Proof sketch.* Pointwise, $\max(N_1(n), N_2(n)) \le N_1(n)+N_2(n) \le 2\max(N_1(n),N_2(n))$. Taking logarithms and dividing by $n$ sandwiches $\log(N_1+N_2)(n)/n$ between $A(n) := \max(\log N_1(n)/n, \log N_2(n)/n)$ and $A(n) + \log 2/n$. Since $A(n) \to \max(h_1,h_2)$ and $\log 2 / n \to 0$, the squeeze applies. $\square$

The union law is a supremum law because a sum of two exponentials is dominated by the larger up to a factor $2$, and constant factors are invisible after dividing logarithms by $n$. (The two-stratum case iterates to any finite union; countable unions require a separate argument since the supremum need not be attained.)

### 6.3 Intersections: strict dimension drop

**Definition 6.7 (counting independence).** Two strata $A, B$ inside the ambient language *meet independently* if for all $n$
$$|A \cap B|_{\le n} \cdot S_k(n) \;=\; |A|_{\le n}\cdot|B|_{\le n},$$
the exact discrete analogue of $\mathbb{P}(A\cap B) = \mathbb{P}(A)\,\mathbb{P}(B)$ for the uniform measure on the ball.

**Theorem 6.8 (dimension of an independent intersection).** Let $k \ge 2$; let $N_1, N_2, N_\cap \ge 1$ satisfy $N_\cap(n)\,S_k(n) = N_1(n)\,N_2(n)$ for all $n$, and let $N_i$ have entropy dimension $h_i$. Then $N_\cap$ has entropy dimension
$$h_\cap \;=\; h_1 + h_2 - \log k .$$

*Proof.* Take logarithms in the independence identity:
$$\log N_\cap(n) = \log N_1(n) + \log N_2(n) - \log S_k(n).$$
Divide by $n$ and pass to the limit, using $\log S_k(n)/n \to \log k$. $\square$

**Lemma 6.9 (arithmetic strict drop).** If $h_1 < L$ and $h_2 < L$ then $h_1 + h_2 - L < \min(h_1,h_2)$.

*Proof.* $h_1+h_2-L < h_1 \iff h_2 < L$, and symmetrically. $\square$

**Theorem 6.10 (strict dimension drop).** Under the hypotheses of Theorem 6.8, if both strata are proper ($h_1, h_2 < \log k$), then $h_\cap < \min(h_1,h_2)$.

Equivalently, in terms of *codimensions* $\kappa_i = \log k - h_i > 0$: $\kappa_\cap = \kappa_1 + \kappa_2$. Codimensions add at independent intersections, exactly as for transversal subvarieties or independent fractal sets.

**Theorem 6.11 (a nontrivial spectrum exists).** Let $k \ge 2$ and $0 \le h_1 < h_2$ with $e^{h_2} < k$. Then the canonical strata of rates $h_1, h_2$ have entropy dimensions $h_1$ and $h_2$ respectively, their union has dimension $h_2$, and both have ambient density $0$.

*Proof.* Theorems 6.4, 6.5 and 6.6. $\square$

The dimension spectrum, not the density, is therefore the informative invariant of a family of theorems — and by Theorem 2.4 it is invariant under bounded recoding. It forms a lattice-like structure: supremum on unions, strict additive drop of codimension on independent intersections.

---

## 7. Power laws from mixtures of geometric proof regimes

Empirical proof-length data are frequently reported as heavy-tailed. Can one homogeneous proof space produce a power law? No.

**Definition 7.1 (single regime).** A proof regime of *entropy parameter $s > 0$* has length tail $T_s(x) = e^{-xs}$ — the probability that a random derivable statement is longer than $x$.

**Proposition 7.2 (constant successive ratio).** For every $s$ and every $x$,
$$\frac{T_s(x+1)}{T_s(x)} \;=\; e^{-s},$$
a constant strictly below $1$.

*Proof.* $e^{-(x+1)s}/e^{-xs} = e^{-s}$. $\square$

A constant successive ratio is the defining signature of geometric decay, and geometric decay is never regularly varying. So a genuine power law must arise from *heterogeneity across regimes*. Model that heterogeneity as a scale mixture over the entropy parameter.

**Definition 7.3 (uniform scale mixture).** $\displaystyle T(x) \;=\; \int_0^1 e^{-xs}\,ds$.

**Theorem 7.4 (closed form).** For $x > 0$,
$$T(x) \;=\; \frac{1 - e^{-x}}{x}.$$

*Proof.* Substituting $t = xs$, $T(x) = \frac1x\int_0^x e^{-t}\,dt = \frac{1-e^{-x}}{x}$. $\square$

**Theorem 7.5 (exact power-law bounds).** For $x \ge 1$,
$$\frac{1 - e^{-1}}{x} \;\le\; T(x) \;\le\; \frac{1}{x} .$$

*Proof.* From Theorem 7.4, using $e^{-x} \le e^{-1}$ for $x \ge 1$ and $e^{-x} > 0$. $\square$

Numerically $1 - e^{-1} \approx 0.632$: the mixed tail is pinned between $0.632/x$ and $1/x$ for all $x \ge 1$. This is an exact power law of exponent one, with explicit constants.

**Theorem 7.6 (regular variation of index $-1$).** $\;x\,T(x) \to 1$ as $x \to \infty$.

*Proof.* $x T(x) = 1 - e^{-x} \to 1$. $\square$

Hence $T(\lambda x)/T(x) \to \lambda^{-1}$ for every $\lambda > 0$: the tail is regularly varying with index $-1$ in the standard sense.

**Theorem 7.7 (successive ratios tend to one).** $\;T(n+1)/T(n) \to 1$ as $n \to \infty$.

*Proof.* $\dfrac{T(n+1)}{T(n)} = \dfrac{1-e^{-(n+1)}}{1-e^{-n}}\cdot\dfrac{n}{n+1} \to 1\cdot 1$. $\square$

**Theorem 7.8 (the mixture is not geometric).** There is no pair $(C, a)$ with $0 \le a < 1$ such that $T(n) \le C a^{n}$ for all $n \ge 1$.

*Proof.* Suppose there were. By Theorem 7.5, $(1-e^{-1})/n \le C a^n$ for all $n \ge 1$, i.e. $1 - e^{-1} \le C\,n\,a^{n}$. But $n a^n \to 0$ for $a < 1$, so the right-hand side eventually falls below the positive constant $1 - e^{-1}$ — a contradiction. $\square$

**Interpretation.** The power law comes entirely from the behaviour of the mixing law near zero entropy: regimes with $s \approx 0$ have almost flat tails and dominate at large lengths. The exponent $1$ is the index of the uniform mixing density; the same computation with a mixing density behaving like $s^{\alpha-1}$ near zero produces index $\alpha$, by an incomplete-Gamma asymptotic. Proposition 7.2 and Theorem 7.7 give an operational test that is checkable on data: plot successive tail ratios. If they hover at a constant below $1$, the data are consistent with a single regime; if they climb towards $1$, the population is heterogeneous and a power law is the right model.

---

## 8. Algorithms

The theory yields three directly implementable procedures.

**Algorithm A (empirical transition window).** Given a table of counts $N(0), \dots, N(M)$, an alphabet size $k$ and a level $\varepsilon$: compute $d(n) = N(n)/S_k(n)$ for each $n$; return $n_+ = \max\{n \le M : d(n) \ge \varepsilon\}$ and $n_- = \min\{n \le M : d(n) < \varepsilon\}$; the pair $(n_-, n_+)$ delimits the transition window and $n_+ - n_-$ is its measured width. Cost $O(M)$. Theorem 4.4 gives the certified bound $\log(2C/c)/\log(k/a)$ against which to compare, once $(a, c, C)$ have been fitted.

**Algorithm B (fitted exponential order and certified window).** Given counts, estimate $a = \exp\big(\widehat{\log N(n)/n}\big)$ from the tail of the sequence, then set $c = \min_n N(n)a^{-n}$, $C = \max_n N(n)a^{-n}$ over the fitted range; return $W = \log(2C/c)/\log(k/a)$ if $a < k$. Cost $O(M)$. $W$ upper bounds the transition width at *every* level, so it is a falsifiable prediction: an observed width exceeding $W$ certifies that the two-sided exponential law fails on the range examined.

**Algorithm C (regime-heterogeneity test).** Given an empirical tail $T$ sampled at integers, compute $\rho(n) = T(n+1)/T(n)$ and $\pi(n) = n\,T(n)$. If $\rho(n)$ is approximately constant $< 1$, report "single geometric regime with entropy $-\log \rho$"; if $\rho(n) \nearrow 1$ while $\pi(n)$ stabilises, report "scale mixture, regularly varying of index $-1$" and estimate the index from the slope of $\log T$ against $\log x$. Cost $O(M)$.

**Algorithm D (count-radius comparison across encodings).** Given two count tables, compute $r_i(m) = \min\{n: N_i(n) \ge m\}$ by a linear scan and return $\max_m |r_1(m)-r_2(m)|$. Theorem 2.2 asserts this quantity is at most the recoding overhead $b$, giving a direct empirical lower bound on the overhead of the translation between two encodings. Cost $O(M + m_{\max})$.

---

## 9. Discussion

### 9.1 Which observables are physical

The results split the natural observables of a counted proof space into two classes.

*Invariant.* Count radii ($b$-quasi-invariant, Theorem 2.2) and the entropy dimension (exactly invariant, Theorem 2.4). Any statement about a deductive system phrased in these terms is a statement about the system.

*Encoding-dependent.* The density at a fixed radius, and the critical index at a fixed level (Theorem 3.7). These may be perfectly meaningful for a *given* encoding, but they carry no invariant content unless a hypothesis such as exponential order (Theorem 4.5) is added.

The mechanism behind the split is worth restating: a recoding of overhead $b$ shifts radii by $b$ and multiplies levels by up to $2k^b$. Radial statements see an additive constant; level statements see a multiplicative one. The two become commensurable exactly when the density decays at a definite exponential rate, and the exchange rate between them is $\log(k/a)$ nats of level per unit of radius.

### 9.2 Sharpness

Theorem 3.7 shows the level rescaling in Corollary 3.6 cannot be removed, and it does so with profiles that obey the distortion inequalities of an actual overhead-$1$ binary recoding, so the counterexample is not an artefact of a weakened hypothesis. On the other hand the counterexample lives at the level of the *observables* (antitone null profiles), not of explicit integer counting functions of a specific calculus; realizing it by concrete derivability counts is a natural refinement.

Theorem 4.4 requires a two-sided exponential bound *at the same base*. If the upper bound has base $a$ and the lower bound has base $\rho < a$, the argument gives a window width growing like $\log(1/\varepsilon)/\log(a/\rho)$, and the uniformity in $\varepsilon$ is genuinely lost. Fekete's lemma (Theorem 5.2) removes half of this hypothesis unconditionally for submultiplicative counts; the matching upper bound $N(n) \le C(e^L)^n$ remains an assumption.

### 9.3 Relation to metric geometry and fractal dimension

The setting is a discrete analogue of the growth theory of finitely generated groups. A bounded recoding is a quasi-isometry with multiplicative constant $1$; the entropy dimension plays the role of the exponential growth rate, which is likewise a quasi-isometry invariant, and count radii play the role of the inverse growth function. The dimension spectrum of §6 is the counting analogue of a box-counting dimension: $\log N(n)/n$ is exactly $\log(\text{number of cells at scale } k^{-n})/\log(k^{n})$ up to normalisation by $\log k$, so $h/\log k$ is a box dimension in $[0,1]$ for the corresponding subset of the Cantor-like space of infinite strings. Under that normalisation, Theorem 6.6 is the standard "dimension of a finite union is the maximum", and Theorem 6.8 is the classical codimension-additivity for independent (transversal) sets.

### 9.4 Consequences for the empirical study of proof corpora

Three practical prescriptions follow.

1. **Report radii and rates, not densities at fixed cutoffs.** A density measured at length $n$ in one serialization format cannot be compared with a density measured at length $n$ in another; a count radius or a fitted growth rate can.
2. **Certify a window before claiming a phase transition.** Algorithm B produces a level-independent width prediction from the fitted exponential order. Only if the observed window respects it is a "sharp transition" claim consistent with the counting law.
3. **Test for heterogeneity before fitting a power law.** By Proposition 7.2, a single regime cannot produce a power law. A power-law fit therefore implicitly asserts a mixture, and Algorithm C tests that assertion directly, via the successive-ratio diagnostic.

---

## 10. Future work

**An intrinsic recoding-invariant critical index.** Theorem 4.5 bounds the gap between the level-$\varepsilon$ critical indices of two counts of the same exact exponential order by $\log(2C/c)/\log(k/a) + 1$, uniformly in $\varepsilon$, and Theorem 4.6 shows that an overhead-$b$ recoding changes the constants only by $a^{\pm b}$ for radii at least $b$. We conjecture that the residual $b$-dependence is an artefact: for counts that are monotone and bounded below by $1$, the transferred lower bound should extend to all radii, and the resulting gap bound $\big(\log(2C/c) + 2b\log a\big)/\log(k/a) + 1$ should be replaceable by $b + \log(2C/c)/\log(k/a) + 1$ — the overhead entering additively in radius and not through the entropy factor at all. The reason to expect this is now clear: it is the *level*, not the radius, that a recoding distorts, and a level distortion by $2k^b$ becomes a bounded radius shift only when the count has a genuine exponential order $a$; normalising radii by $\log(k/a)$ is exactly the correction making the two effects commensurable.

**Threshold windows for submultiplicative calculi.** For a finitely generated calculus with counts submultiplicative up to a polynomial factor and exponential growth rate strictly below the ambient language, we conjecture that a logarithmically smoothed density is eventually antitone and that every fixed positive level has a transition window of width bounded independently of the cutoff. Submultiplicativity should suppress the oscillations that are invisible to exponential growth rates but currently obstruct an intrinsic threshold; the present work reduces this to controlling the matching upper bound.

**A multifractal spectrum for theorem families.** Partitioning derivable statements by proof-theoretic complexity and assigning each stratum its entropy dimension, we conjecture that natural calculi exhibit a nontrivial multifractal spectrum, with the union dimension equal to the supremum of stratum dimensions (Theorem 6.6 gives the finite case) and intersections obeying the strict drop of Theorem 6.10 under an approximate — rather than exact — independence condition allowing subexponential error factors. A single provable/unprovable ratio discards the internal geometry that such a spectrum records.

**General mixing laws and a Tauberian converse.** For a scale mixture of geometric regimes whose entropy parameter has density proportional to $s^{\alpha-1}$ near zero, we conjecture a regularly varying tail of index $-\alpha$, together with a converse under a Tauberian regularity condition: a regularly varying tail forces the mixing law to have the corresponding power behaviour near zero. Theorem 7.4 settles the case $\alpha = 1$ exactly.

**Quantitative diagonalization.** For a concrete arithmetized theory with a fixed prefix-free syntax, we conjecture explicit upper and lower bounds on the length of the shortest fixed-point sentence in terms of the description length of the provability predicate, and that bounded recodings preserve these bounds up to additive constants. Semantic incompleteness yields existence but no numerical threshold; a quantitative diagonal lemma must account for the cost of quotation, substitution, and the provability predicate. Counting laws and fixed-point laws are at present separate theories, and coding-cost estimates are the necessary bridge.

---

## 11. Conclusion

Reduced to its counting data, a deductive system carries a genuine geometry. Its stable invariants under any bounded change of encoding are radial — count radii, quasi-invariant with the overhead as the additive constant — and asymptotic — the entropy dimension, exactly invariant. Density levels are not stable, and the reason is a clean mismatch: recodings distort radii additively but levels multiplicatively by $2k^b$. Where the counting law has a genuine two-sided exponential order below the ambient rate, the mismatch is repaired: transition windows acquire a width bounded uniformly in the level, and critical indices become quasi-invariant with a bound determined by the shape of the counting law rather than by the encoding. Submultiplicativity, the counting shadow of concatenating proofs, supplies half of that two-sided law unconditionally via Fekete's lemma, with the explicit constant $1/P$.

Above the level of a single density there is a spectrum. Every rate in $[0,\log k]$ is realized by a genuine subfamily, all of them invisible to the provable/unprovable ratio; unions take the maximum dimension; independent intersections add codimensions. And when proof-length data are heavy-tailed, the source cannot be a single homogeneous regime — those have constant successive ratios — but a mixture across regimes, whose uniform case has the exact tail $(1-e^{-x})/x$, a power law of index $-1$ with successive ratios climbing to $1$.

The theorems a system can prove occupy a shape in the space of strings. The shape has a dimension, a boundary layer of bounded thickness, and an intersection calculus — and unlike the alphabet in which it happens to be written, the shape is intrinsic.
