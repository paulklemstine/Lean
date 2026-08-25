# Normalized Gap and Pair-Correlation Statistics for Finite Spectra: Unfolding, Rigidity, and Unfolding-Free Separation of Universality Classes

**Author:** Aristotle

**Date:** 2026-08-25

---

## Abstract

We develop, from first principles and in full rigour, the elementary layer of random-matrix-style spectral statistics for finite deterministic level sequences: raw gaps, mean gaps, normalized (unfolded) gaps, empirical spacing distribution functions, two-level correlation counts, and number counts in windows. Our starting point is the observation — obvious in principle, yet routinely violated in practice — that a spacing law computed from a spectrum with a varying density of states measures the density of states rather than the correlations. We make this precise with a sharp example: for the deterministic quadratic spectrum $\lambda_k = k^2$, the empirical distribution of the *raw* normalized gaps over a window of $n$ levels is within $1/(2n)$ of the uniform law on $[0,2]$ at every threshold, uniformly in $n$. This clean law is entirely an artefact.

We then prove a general unfolding principle: if $g$ inverts the level sequence, i.e. $g(\lambda_k) = k$, then every normalized gap of $g \circ \lambda$ equals $1$. The quadratic spectrum is the instance $g = \sqrt{\cdot}$, whose unfolded form is the picket fence $\lambda_k \mapsto k$. For this picket fence we compute the entire suite of statistics exactly: the spacing distribution is a Dirac mass at $1$ with zero spacing variance; the two-level correlation count is $R_2(n,t) = 2\lfloor t\rfloor n - \lfloor t\rfloor(\lfloor t\rfloor+1)$ for $\lfloor t \rfloor \le n$, with normalized limit the staircase $2\lfloor t \rfloor$; and the number count in any window $[a, a+L)$ deviates from $L$ by strictly less than $1$, uniformly in $a$, so the number variance is bounded — a statement that extends verbatim to any arithmetic spectrum $\lambda_k = dk$.

Against these we set the two reference universality classes. We prove that $p_{\mathrm{Poisson}}(s) = e^{-s}$ and the Wigner surmise $p_{\mathrm{GUE}}(s) = \frac{32}{\pi^2}s^2 e^{-\frac{4}{\pi}s^2}$ are probability densities of mean one, with second moments $2$ and $3\pi/8$ respectively, so that the spacing variance strictly orders the three regimes as $0 < \frac{3\pi}{8}-1 < 1$. We prove quadratic level repulsion ($p_{\mathrm{GUE}} < p_{\mathrm{Poisson}}$ on $(0,1/4]$), the non-equivalence of the two classes under arbitrary rescaling, and the existence of a strict interior mode of the Wigner surmise at $s^\star = \sqrt{\pi}/2$ with maximal value $8/(\pi e)$ — a scale-free, normalization-free discriminant, since the Poisson density is strictly decreasing and has no interior mode. Quantitatively, the empirical spacing law of the picket fence is at Kolmogorov–Smirnov distance at least $1/3$ from the Poisson law and at least $1/12$ from the Wigner surmise, for every window size.

Finally we introduce the consecutive gap ratio $r_i = \min(g_i,g_{i+1})/\max(g_i,g_{i+1})$ and prove that it is invariant under every orientation-preserving affine change of scale with no unfolding, no window and no mean-spacing normalization; that it lies in $[0,1]$ and equals $1$ exactly when consecutive gaps agree; and that for the *raw* quadratic spectrum $r_i = (2i+1)/(2i+3) \to 1$ with exact deviation $1 - r_i = 2/(2i+3)$, while $r_i < 1$ for every $i$. Thus the ratio statistic detects the rigidity of $\lambda_k = k^2$ directly in the raw data, where the normalized-gap distribution reports a spurious uniform law.

---

## 1. Introduction

### 1.1 The problem

Let $\lambda_0 < \lambda_1 < \lambda_2 < \cdots$ be a sequence of real numbers, thought of as the energy levels of a quantum system, the eigenvalues of a large matrix, or the ordinates of the zeros of an $L$-function. The central empirical discovery of random matrix theory is that the *local* statistics of such sequences — the statistics of gaps between neighbouring levels, once measured in units of the local mean gap — fall into a small number of universality classes determined by the global symmetry and integrability properties of the underlying system, not by its microscopic details.

Two classes anchor the subject:

* **Poisson statistics**, expected for classically integrable systems (the Berry–Tabor picture), in which levels behave as if dropped independently and the spacing law is exponential;
* **Random-matrix statistics**, expected for classically chaotic systems (the Bohigas–Giannoni–Schmit picture), in which levels repel; for systems without time-reversal symmetry the relevant ensemble is the Gaussian Unitary Ensemble, whose spacing law is closely approximated by the Wigner surmise.

Between and beyond these lie **rigid** spectra — perfectly regular sequences such as arithmetic progressions — whose fluctuations are bounded rather than merely suppressed.

### 1.2 The unfolding problem

Any comparison between an observed spectrum and a universality class must first eliminate the *density of states*. If the mean gap varies substantially across the window under study, the observed spread of gap sizes reflects the trend, not the fluctuations. The standard remedy — dividing gaps by a local mean gap, equivalently applying a smoothed counting function to the levels — is called **unfolding**.

Unfolding is not canonical. It requires a choice of window and a choice of smoothing, and different choices produce different answers. This paper does three things about that.

1. It quantifies exactly how badly the un-unfolded comparison can fail, on a maximally clean example.
2. It proves the unfolding principle in general, isolating precisely what unfolding removes.
3. It develops an **unfolding-free** statistic — the consecutive gap ratio — that is invariant under every affine change of scale, and shows that on the same example this statistic reports the correct answer directly from the raw data.

### 1.3 Summary of contributions

All statements below are theorems proved in the body of the paper.

* **Invariance and normalization of unfolding.** The normalized gaps of a window of $n$ levels sum to $n$; they are invariant under $\lambda \mapsto a\lambda + b$ for $a \neq 0$.
* **A sharp spurious law.** For $\lambda_k = k^2$, the empirical distribution function of the raw normalized gaps is within $1/(2n)$ of the uniform law on $[0,2]$ at every threshold.
* **The unfolding principle.** If $g(\lambda_k) = k$ for all $k$ then all normalized gaps of $g \circ \lambda$ equal $1$.
* **Exact statistics of the picket fence.** Dirac spacing law, zero spacing variance, exact two-level count, staircase density limit $2\lfloor t\rfloor$, bounded number variance ($< 1$ in every window), no empty window of length $\geq 1$.
* **The two universality classes.** Normalization, unit mean and second moments of both densities; the variance ordering $0 < 3\pi/8 - 1 < 1$; quadratic level repulsion on $(0,1/4]$; non-equivalence under rescaling; the strict interior mode $\sqrt{\pi}/2$ of the Wigner surmise versus the strict monotonicity of the Poisson density.
* **Quantitative separation.** KS distance $\geq 1/3$ to Poisson and $\geq 1/12$ to the Wigner surmise, for every window size.
* **The unfolding-free ratio statistic.** Affine invariance with no window; characterization of $r=1$; the exact value $r_i = (2i+1)/(2i+3)$ for the raw quadratic spectrum, with $1 - r_i = 2/(2i+3)$ and $r_i < 1$ for all $i$.

---

## 2. Gaps, mean gaps and unfolding

Throughout, a **level sequence** is a function $\lambda : \mathbb{N} \to \mathbb{R}$; we do not require monotonicity in the definitions, but all our examples are strictly increasing.

**Definition 2.1 (Raw gap).** The $i$-th raw gap of $\lambda$ is $g_i(\lambda) := \lambda_{i+1} - \lambda_i$.

**Definition 2.2 (Mean gap).** The mean gap over the window of the first $n$ gaps is
$$\bar{g}_n(\lambda) := \frac{\lambda_n - \lambda_0}{n}.$$

Since the raw gaps telescope, $\sum_{i=0}^{n-1} g_i(\lambda) = \lambda_n - \lambda_0$, and therefore $\bar{g}_n(\lambda)$ is precisely the arithmetic mean of the first $n$ raw gaps.

**Definition 2.3 (Normalized / unfolded gap).** For $\bar{g}_n(\lambda) \neq 0$,
$$s_i^{(n)}(\lambda) := \frac{g_i(\lambda)}{\bar{g}_n(\lambda)}.$$

**Theorem 2.4 (Unfolding normalizes the mean spacing to one).** For every $n \geq 1$ with $\bar{g}_n(\lambda) \neq 0$,
$$\sum_{i=0}^{n-1} s_i^{(n)}(\lambda) = n.$$

*Proof.* Pull the constant denominator out of the sum and apply the telescoping identity: $\sum_{i<n} s_i^{(n)} = (\lambda_n - \lambda_0)/\bar g_n(\lambda) = (\lambda_n - \lambda_0) \cdot n /(\lambda_n - \lambda_0) = n$, the middle step being legitimate because $\bar g_n \ne 0$ forces $\lambda_n \ne \lambda_0$. $\square$

**Theorem 2.5 (Affine invariance).** For every $a \neq 0$, every $b \in \mathbb{R}$, and all $n \ge 1$, $i \ge 0$,
$$s_i^{(n)}(a\lambda + b) = s_i^{(n)}(\lambda).$$

*Proof.* Both the raw gap and the window increment are homogeneous of degree $1$ in $a$ and insensitive to $b$: $g_i(a\lambda + b) = a\, g_i(\lambda)$ and $\bar g_n(a\lambda+b) = a\,\bar g_n(\lambda)$. The factor $a$ cancels in the quotient. $\square$

Theorem 2.5 is the formal reason that **raw spectra may never be compared, only unfolded ones**: any statistic worth reporting must be invariant under the recalibrations $\lambda \mapsto a\lambda + b$ that carry no physical content.

**Definition 2.6 (Empirical spacing distribution).** For $n \geq 1$,
$$F_n^\lambda(t) := \frac{1}{n}\,\#\left\{ i < n : s_i^{(n)}(\lambda) \leq t \right\}.$$

**Definition 2.7 (Spacing variance).** $\displaystyle V_n(\lambda) := \frac{1}{n}\sum_{i=0}^{n-1}\left(s_i^{(n)}(\lambda) - 1\right)^2.$

By Theorem 2.4 the normalized gaps have mean exactly $1$, so $V_n$ is a genuine empirical variance.

**Theorem 2.8 (Zero variance characterizes rigidity).** Let $n \geq 1$ and $\bar g_n(\lambda) \neq 0$. Then $V_n(\lambda) = 0$ if and only if $g_i(\lambda) = \bar g_n(\lambda)$ for every $i < n$.

*Proof.* A sum of squares of reals vanishes iff each term vanishes; $s_i^{(n)} = 1$ iff $g_i = \bar g_n$ since $\bar g_n \ne 0$. The converse direction substitutes $g_i = \bar g_n$ termwise. $\square$

---

## 3. The quadratic spectrum before unfolding: a sharp spurious law

**Definition 3.1.** The *quadratic spectrum* is $\lambda_k = k^2$.

Its raw gaps are the odd numbers, $g_i = (i+1)^2 - i^2 = 2i+1$, and its window mean gap is $\bar g_n = n^2/n = n$, so
$$s_i^{(n)} = \frac{2i+1}{n}, \qquad i = 0,\dots,n-1.$$

Two immediate consequences show how badly the raw normalized gaps fail to concentrate: the first normalized gap of the window of size $n+1$ is $1/(n+1) \to 0$, while the last is $2 - 1/(n+1) \to 2$. The raw normalized gaps spread over the whole interval $[0,2]$. In fact they equidistribute there, and the following theorem makes this uniform and quantitative.

**Lemma 3.2 (Counting lemma).** For $n \in \mathbb{N}$ and $x \geq 0$,
$$\#\{ i < n : 2i + 1 \le x \} = \min\!\left(n,\ \left\lfloor \tfrac{x+1}{2}\right\rfloor\right).$$

*Proof.* For a natural number $i$, the inequality $2i+1 \le x$ is equivalent to $i + 1 \le (x+1)/2$, hence to $i + 1 \le \lfloor (x+1)/2 \rfloor$ (as $i+1$ is an integer and $(x+1)/2 \ge 0$), hence to $i < \lfloor (x+1)/2 \rfloor$. So the filtered set is $\{0,\dots,n-1\} \cap \{0,\dots,\lfloor (x+1)/2\rfloor - 1\}$, an initial segment of length $\min(n, \lfloor (x+1)/2\rfloor)$. $\square$

**Theorem 3.3 (The raw quadratic spectrum looks uniform on $[0,2]$).** For every $n \geq 1$ and every $t \in [0,2]$,
$$\left| F_n^{\lambda}(t) - \frac{t}{2}\right| \leq \frac{1}{2n}, \qquad \lambda_k = k^2.$$

*Proof.* Write $x := tn \ge 0$. Since $s_i^{(n)} = (2i+1)/n$, the condition $s_i^{(n)} \le t$ is exactly $2i + 1 \le x$, so Lemma 3.2 gives the count as $\min(n, \lfloor (x+1)/2\rfloor)$. Because $t \le 2$ we have $x \le 2n$, hence $(x+1)/2 \le n + 1/2$ and $\lfloor (x+1)/2 \rfloor \le \lfloor n + 1/2\rfloor = n$; the minimum is attained by the floor. Writing $c := \lfloor (x+1)/2 \rfloor$, the elementary floor bounds $(x+1)/2 - 1 < c \le (x+1)/2$ give $|c - x/2| \le 1/2$. Finally
$$F_n^\lambda(t) - \frac{t}{2} = \frac{c}{n} - \frac{x/2}{n} = \frac{c - x/2}{n},$$
whose absolute value is at most $1/(2n)$. $\square$

**Remark 3.4 (Why the law is meaningless).** Theorem 3.3 exhibits an exceptionally clean limiting spacing law — the uniform law on $[0,2]$, approached at rate $O(1/n)$ — that carries no information whatsoever about correlations between levels. It arises because the density of states of $\lambda_k = k^2$ diverges: the variation of $s_i^{(n)}$ across the window is a systematic trend, not a fluctuation. Any comparison of this law with $e^{-s}$ or with the Wigner surmise is meaningless. Sections 4–6 show what the correct comparison yields.

---

## 4. The unfolding principle and the picket fence

**Theorem 4.1 (Unfolding principle).** Let $\lambda : \mathbb{N} \to \mathbb{R}$ and let $g : \mathbb{R}\to\mathbb{R}$ satisfy $g(\lambda_k) = k$ for every $k \in \mathbb{N}$ — that is, $g$ is a counting function of the spectrum. Then for every $n \geq 1$ and every $i$,
$$s_i^{(n)}(g\circ\lambda) = 1.$$

*Proof.* All raw gaps of $g\circ\lambda$ equal $(i+1) - i = 1$, and the window mean is $(n - 0)/n = 1$; the quotient is $1$. $\square$

**Definition 4.2 (Unfolded quadratic spectrum).** The smoothed counting function of $\lambda_k = k^2$ is $N(x) = \sqrt{x}$, and $N(\lambda_k) = k$. We call $\mu_k := \sqrt{\lambda_k} = k$ the *unfolded quadratic spectrum*, or the **picket fence**.

Theorem 4.1 with $g = \sqrt{\cdot}$ yields at once:

**Corollary 4.3.** $s_i^{(n)}(\mu) = 1$ for every $n \geq 1$ and every $i$; consequently
$$F_n^{\mu}(t) = \begin{cases} 0, & t < 1,\\ 1, & t \geq 1,\end{cases}$$
the empirical spacing law of the picket fence is the Dirac mass at $1$, and $V_n(\mu) = 0$ for every $n \geq 1$.

**Remark 4.4.** Theorem 4.1 also explains the *limits* of unfolding: unfolding by the *exact* counting function always produces the picket fence, destroying all fluctuation information. Genuine spectral statistics is unfolding by a *smoothed* counting function, so that the fine-grained deviations from perfect regularity survive. The theorem is the boundary case that delineates what unfolding removes.

---

## 5. Two-level correlations of the picket fence: an exact staircase

**Definition 5.1 (Two-level correlation count).** For a level sequence $\lambda$, a window size $n$ and a distance $t \ge 0$,
$$R_2(\lambda; n, t) := \#\left\{ (i,j) \in \{0,\dots,n-1\}^2 \;:\; i \neq j,\ |\lambda_i - \lambda_j| \le t \right\}.$$

This is the unnormalized two-level (pair) correlation function: the number of ordered pairs of distinct levels within distance $t$.

**Theorem 5.2 (Exact pair correlation of the picket fence).** For every $n$ and every $t \geq 0$,
$$R_2(\mu; n, t) = 2 \sum_{d=1}^{\lfloor t\rfloor} (n - d)^+,$$
where $(x)^+$ denotes truncated subtraction in $\mathbb{N}$.

*Proof.* Two distinct integers $i \ne j$ in $\{0,\dots,n-1\}$ satisfy $|i-j| \le t$ iff their distance $d := |i - j| \ge 1$ satisfies $d \le \lfloor t \rfloor$. Partition the admissible pairs by $d$. For a fixed $d \ge 1$ the pairs with $j = i + d$ are indexed injectively by $i \in \{0,\dots,n-d-1\}$, giving $(n-d)^+$ of them, and symmetrically for $i = j + d$; the two families are disjoint since $d \ge 1$. The families for distinct $d$ are pairwise disjoint since $d$ is determined by the pair. Summing cardinalities gives the formula. $\square$

**Lemma 5.3 (Summation identity).** For all $m \le n$,
$$2\sum_{d=1}^{m}(n - d) + m(m+1) = 2mn.$$

*Proof.* Induction on $m$. For $m = 0$ both sides vanish. The inductive step adds $2(n - (m+1))$ to the left sum and replaces $m(m+1)$ by $(m+1)(m+2)$, whose difference is $2(m+1)$; the total increment is $2n - 2(m+1) + 2(m+1) = 2n$, matching the right-hand side. $\square$

**Theorem 5.4 (Closed form).** If $\lfloor t \rfloor \le n$ then
$$R_2(\mu; n, t) = 2\lfloor t\rfloor\, n - \lfloor t \rfloor\left(\lfloor t\rfloor + 1\right).$$

*Proof.* Combine Theorems 5.2 and Lemma 5.3 with $m = \lfloor t \rfloor$. $\square$

**Theorem 5.5 (Staircase invariance).** For every $n$ and every $t \ge 0$, $R_2(\mu; n, t) = R_2(\mu; n, \lfloor t \rfloor)$: the two-level correlation of the picket fence depends on $t$ only through $\lfloor t \rfloor$, hence is constant between consecutive integers.

*Proof.* Immediate from Theorem 5.2, since $\lfloor \lfloor t \rfloor \rfloor = \lfloor t\rfloor$. $\square$

**Theorem 5.6 (Pair-correlation density is the staircase $2\lfloor t\rfloor$).** For every $t \geq 0$,
$$\lim_{n\to\infty}\frac{R_2(\mu; n, t)}{n} = 2\lfloor t \rfloor.$$

*Proof.* For $n \ge \lfloor t \rfloor$, Theorem 5.4 gives $R_2(\mu;n,t)/n = 2\lfloor t\rfloor - \lfloor t\rfloor(\lfloor t\rfloor+1)/n$, and the second term tends to $0$. $\square$

**Remark 5.7 (Contrast with the universality classes).** The two-level *densities* of both universality classes are continuous in $t$: for Poisson the normalized count grows like $2t$, and for the unitary class like $2t$ minus a sine-kernel correction, again continuous. A staircase cannot be approximated uniformly by a continuous function, so the deterministic spectrum is not described by either class at any scale. The gap between the staircase value $2\lfloor t\rfloor$ and the Poisson value $2t$ is $2\{t\}$, which oscillates between $0$ and $2$ and never settles.

---

## 6. Spectral rigidity: bounded number variance

**Definition 6.1 (Window count).** For a picket fence at unit spacing, the levels in the window $[a, a+L)$ are exactly the integers $m$ with $a \le m < a+L$, i.e. the elements of $\{\lceil a \rceil, \lceil a\rceil + 1, \dots, \lceil a + L\rceil - 1\}$, of which there are $\lceil a+L \rceil - \lceil a \rceil$.

**Theorem 6.2 (Number rigidity).** For every $a \in \mathbb{R}$ and every $L \geq 0$,
$$\Big|\,\#\{\text{levels of } \mu \text{ in } [a, a+L)\} - L \,\Big| < 1.$$

*Proof.* Write $C = \lceil a+L\rceil - \lceil a \rceil$ for the count. The ceiling bounds $x \le \lceil x \rceil < x + 1$, applied at $x = a$ and $x = a+L$, give
$$a + L - (a+1) < C < (a+L+1) - a,$$
i.e. $L - 1 < C < L + 1$. $\square$

**Corollary 6.3 (No empty windows).** If $L \geq 1$ then $[a, a+L)$ contains at least one level of $\mu$.

*Proof.* If the count were $0$, Theorem 6.2 would give $L = |0 - L| < 1$. $\square$

**Theorem 6.4 (Rigidity of an arbitrary arithmetic spectrum).** Let $d > 0$ and let the spectrum be $\lambda_m = dm$, $m \in \mathbb{Z}$. Then for every $a \in \mathbb{R}$ and $L \geq 0$,
$$\Big|\,\#\{\text{levels in } [a, a+L)\} - \tfrac{L}{d} \,\Big| < 1.$$

*Proof.* The condition $a \le dm < a+L$ is equivalent, after dividing by $d > 0$, to $a/d \le m < a/d + L/d$, so the levels in the window correspond bijectively to the integers of $[a/d, a/d + L/d)$. Apply Theorem 6.2 with $a/d$ in place of $a$ and $L/d \ge 0$ in place of $L$. $\square$

**Remark 6.5 (The three rigidity regimes).** Theorem 6.2 says the number variance of the picket fence is bounded by $1$ for all window lengths. For a Poisson process the number variance in a window of length $L$ equals $L$ and diverges linearly; for unitary random-matrix statistics it grows like $\frac{1}{\pi^2}(\log L + c)$. Bounded / logarithmic / linear is therefore a scale-free trichotomy that survives all normalization conventions.

---

## 7. The two universality classes

**Definition 7.1.** The **Poisson spacing density** is $p_{\mathrm{P}}(s) := e^{-s}$ and the **Wigner surmise for the unitary class** is
$$p_{\mathrm{U}}(s) := \frac{32}{\pi^2}\, s^2\, e^{-\frac{4}{\pi}s^2},$$
both taken on $(0,\infty)$.

### 7.1 Gaussian moment integrals

The unitary computations rest on three integrals, each proved by exhibiting an explicit antiderivative on $[0,\infty)$, verifying integrability, and passing to the limit at $+\infty$ using $x^k e^{-bx^2} \to 0$.

**Lemma 7.2.** For $b > 0$,
$$\int_0^\infty x^2 e^{-bx^2}\,dx = \frac{\sqrt{\pi/b}}{4b}, \qquad \int_0^\infty x^3 e^{-bx^2}\,dx = \frac{1}{2b^2}, \qquad \int_0^\infty x^4 e^{-bx^2}\,dx = \frac{3\sqrt{\pi/b}}{8b^2}.$$

*Proof sketch.* For the odd moment, the function $F(x) = -\left(\frac{x^2}{2b} + \frac{1}{2b^2}\right)e^{-bx^2}$ satisfies $F'(x) = x^3 e^{-bx^2}$ and $F(x)\to 0$ as $x\to\infty$, whence the integral equals $-F(0) = 1/(2b^2)$. For the even moments one uses $G(x) = -\frac{x}{2b}e^{-bx^2}$ with $G'(x) = x^2 e^{-bx^2} - \frac{1}{2b}e^{-bx^2}$ and $H(x) = -\left(\frac{x^3}{2b} + \frac{3x}{4b^2}\right)e^{-bx^2}$ with $H'(x) = x^4 e^{-bx^2} - \frac{3}{4b^2}e^{-bx^2}$; since $G(0) = H(0) = 0$ and both tend to $0$ at infinity, each reduces to a multiple of the half-Gaussian $\int_0^\infty e^{-bx^2}dx = \frac{1}{2}\sqrt{\pi/b}$. Integrability of $x^k e^{-bx^2}$ on $(0,\infty)$ and the decay $x^k e^{-bx^2}\to 0$ follow from the standard comparison of $x^k e^{-bx^2}$ with $e^{-x/2}$ at infinity. $\square$

### 7.2 Both classes are unfolded probability densities

**Theorem 7.3.** $\displaystyle \int_0^\infty p_{\mathrm{P}} = 1$ and $\displaystyle \int_0^\infty s\, p_{\mathrm{P}}(s)\,ds = 1$; also $\displaystyle \int_0^\infty s^2 p_{\mathrm{P}}(s)\,ds = 2$.

*Proof.* Directly, $\int_0^\infty e^{-s}ds = 1$. The moments are the Gamma values $\Gamma(2) = 1$ and $\Gamma(3) = 2$. $\square$

**Theorem 7.4.** $\displaystyle \int_0^\infty p_{\mathrm{U}} = 1$, $\displaystyle \int_0^\infty s\, p_{\mathrm{U}}(s)\,ds = 1$, and $\displaystyle \int_0^\infty s^2 p_{\mathrm{U}}(s)\,ds = \frac{3\pi}{8}$.

*Proof.* Take $b = 4/\pi$ and note $\sqrt{\pi/b} = \sqrt{\pi^2/4} = \pi/2$. Lemma 7.2 then gives
$$\int_0^\infty p_{\mathrm{U}} = \frac{32}{\pi^2}\cdot\frac{\pi/2}{4\cdot(4/\pi)} = \frac{32}{\pi^2}\cdot\frac{\pi^2}{32} = 1,$$
$$\int_0^\infty s\,p_{\mathrm{U}}(s)\,ds = \frac{32}{\pi^2}\cdot\frac{1}{2(4/\pi)^2} = \frac{32}{\pi^2}\cdot\frac{\pi^2}{32} = 1,$$
$$\int_0^\infty s^2 p_{\mathrm{U}}(s)\,ds = \frac{32}{\pi^2}\cdot\frac{3(\pi/2)}{8(4/\pi)^2} = \frac{3\pi}{8}. \qquad\square$$

**Corollary 7.5 (The spacing variance orders the three regimes).** Since both densities have mean $1$, their variances are $\int s^2 p - 1$. Hence
$$0 \;<\; \frac{3\pi}{8} - 1 \;<\; 1,$$
with $\frac{3\pi}{8} - 1 \approx 0.1781$: a rigid spectrum has spacing variance $0$ (Corollary 4.3), the unitary class $3\pi/8 - 1$, and Poisson $1$. Level repulsion strictly reduces spacing fluctuations without eliminating them.

*Proof.* $3\pi/8 > 3\cdot 3.14/8 > 1$ and $3\pi/8 < 3\cdot 3.15/8 < 2$. $\square$

### 7.3 Level repulsion

**Theorem 7.6 (Quadratic level repulsion).** For every $s$ with $0 < s \le 1/4$,
$$p_{\mathrm{U}}(s) < p_{\mathrm{P}}(s).$$

*Proof.* The Gaussian factor satisfies $e^{-(4/\pi)s^2}\le 1$, so $p_{\mathrm{U}}(s) \le \frac{32}{\pi^2}s^2$. Using $\pi > 3.14$ gives $\frac{32}{\pi^2} < \frac{32}{3.14^2} < 3.25$, and $s \le 1/4$ gives $s^2 \le s/4$; hence $p_{\mathrm{U}}(s) < 3.25\, s/4 < 1 - s$ for $0 < s \le 1/4$. Finally $1 - s \le e^{-s}$ by the elementary inequality $1 + x \le e^x$ at $x = -s$. $\square$

**Theorem 7.7 (The classes are not related by a change of scale).** For every $c > 0$ there exists $s > 0$ with
$$c\, p_{\mathrm{U}}(cs) \ne p_{\mathrm{P}}(s).$$

*Proof.* Take $s := \min\!\left(\tfrac12, \tfrac{1}{8(1+c)^3}\right) > 0$. Bounding the Gaussian factor by $1$ and $\frac{32}{\pi^2}$ by $4$ (valid since $\pi^2 > 9$) gives $c\,p_{\mathrm{U}}(cs) \le 4c^3 s^2$. The choice of $s$ makes $8(1+c)^3 s \le 1$, and $c^3 \le (1+c)^3$, so $4c^3 s^2 \le s/2$. On the other side, $s \le 1/2$ and $1 - s \le e^{-s}$ give $p_{\mathrm{P}}(s) \ge 1/2$. Since $s/2 \le 1/4 < 1/2$, the two sides cannot be equal. $\square$

Thus repulsion is not an artefact of units: no rescaling of the unitary spacing law reproduces the exponential law.

### 7.4 The interior mode: a normalization-free discriminant

**Theorem 7.8 (Poisson has no interior mode).** $p_{\mathrm{P}}$ is strictly decreasing on $\mathbb{R}$.

*Proof.* $s \mapsto e^{-s}$ is strictly decreasing. $\square$

**Lemma 7.9.** For every real $u \ne 1$, $u e^{-u} < e^{-1}$.

*Proof.* The strict form of $1 + x < e^x$ for $x \ne 0$ at $x = u - 1$ gives $u < e^{u-1}$. Multiplying by $e^{-u} > 0$ yields $u e^{-u} < e^{u-1}e^{-u} = e^{-1}$. $\square$

**Theorem 7.10 (Strict interior mode of the Wigner surmise).** Put $s^\star := \frac{\sqrt{\pi}}{2}$. Then
$$p_{\mathrm{U}}(s^\star) = \frac{8}{\pi e}, \qquad\text{and}\qquad p_{\mathrm{U}}(s) < p_{\mathrm{U}}(s^\star) \text{ for every } s > 0 \text{ with } s \ne s^\star.$$

*Proof.* Substituting $u = \frac{4}{\pi}s^2$ turns the density into $p_{\mathrm{U}}(s) = \frac{8}{\pi}\, u e^{-u}$. At $s = s^\star$ we have $s^{\star 2} = \pi/4$, hence $u = 1$ and $p_{\mathrm{U}}(s^\star) = \frac{8}{\pi}e^{-1} = \frac{8}{\pi e}$. For $s > 0$ with $s \ne s^\star$ we have $u \ne 1$ (as $u = 1$ forces $s^2 = \pi/4$ and, for positive $s$, $s = \sqrt{\pi}/2$), so Lemma 7.9 gives $\frac{8}{\pi}ue^{-u} < \frac{8}{\pi}e^{-1}$. $\square$

Numerically $s^\star \approx 0.8862$ and $p_{\mathrm{U}}(s^\star) = 8/(\pi e) \approx 0.9366$.

**Remark 7.11.** Theorems 7.8 and 7.10 furnish a *scale-free* discriminant. The presence of an interior maximum in the spacing density is preserved by every reparametrization $s \mapsto cs$ (which moves the mode to $s^\star/c$ but does not create or destroy it), so it can be tested on data whose normalization is in doubt. A monotone spacing histogram indicates the Poisson class; a histogram peaking at a positive spacing indicates repulsion.

---

## 8. Quantitative separation: Kolmogorov–Smirnov bounds

We now make "the unfolded quadratic spectrum is neither Poisson nor unitary" into an explicit, $n$-independent inequality. Write $F_{\mathrm{P}}(t) = 1 - e^{-t}$ for the Poisson spacing CDF and $F_{\mathrm{U}}(t) = \int_0^t p_{\mathrm{U}}(s)\,ds$ for the unitary one.

**Lemma 8.1.** $F_{\mathrm{P}}(1/2) \ge 1/3$.

*Proof.* $e^{1/2} \ge 1 + 1/2 = 3/2$, hence $e^{-1/2}\le 2/3$ and $F_{\mathrm{P}}(1/2) = 1 - e^{-1/2} \ge 1/3$. $\square$

**Lemma 8.2.** $\displaystyle F_{\mathrm{U}}(1/2) \ \ge\ \frac{4}{3\pi^2}\,e^{-1/\pi} \ \ge\ \frac{1}{12}.$

*Proof.* On $[0,1/2]$ we have $s^2 \le 1/4$, hence $\frac{4}{\pi}s^2 \le \frac{1}{\pi}$, hence $e^{-(4/\pi)s^2} \ge e^{-1/\pi}$, and therefore the pointwise bound $p_{\mathrm{U}}(s) \ge \frac{32}{\pi^2}e^{-1/\pi}s^2$. Integrating,
$$F_{\mathrm{U}}(1/2) \ge \frac{32}{\pi^2}e^{-1/\pi}\int_0^{1/2}s^2\,ds = \frac{32}{\pi^2}e^{-1/\pi}\cdot\frac{1}{24} = \frac{4}{3\pi^2}e^{-1/\pi}.$$
For the numerical form use $\pi < 3.15$, so $\frac{4}{3\pi^2} > \frac{4}{3\cdot 3.15^2} > 0.134$, and $\pi > 3.14$ with $1 + x \le e^x$ gives $e^{-1/\pi} \ge 1 - 1/\pi \ge 1 - 1/3 = 2/3$. The product exceeds $0.089 > 1/12$. $\square$

**Theorem 8.3 (Quantitative non-Poisson-ness).** For every $n \geq 1$,
$$\sup_{t\ge 0}\left| F_n^{\mu}(t) - F_{\mathrm{P}}(t)\right| \;\ge\; \left| F_n^{\mu}(1/2) - F_{\mathrm{P}}(1/2)\right| \;\ge\; \frac13.$$

*Proof.* By Corollary 4.3, $F_n^\mu(1/2) = 0$; apply Lemma 8.1. $\square$

**Theorem 8.4 (Quantitative non-unitarity).** For every $n \geq 1$,
$$\sup_{t\ge0}\left| F_n^{\mu}(t) - F_{\mathrm{U}}(t)\right| \;\ge\; \left| F_n^{\mu}(1/2) - F_{\mathrm{U}}(1/2)\right| \;\ge\; \frac{1}{12}.$$

*Proof.* As above, using Lemma 8.2. $\square$

Both separations are witnessed at the single threshold $t = 1/2$, where the rigid spectrum has no gaps at all while both universality classes place definite positive mass. Crucially the bounds do not degrade with $n$: no amount of data will make the picket fence look Poisson or unitary.

---

## 9. The unfolding-free gap ratio

Sections 3–8 rest on a choice of window (the first $n$ levels) and, implicitly, on a choice of smoothing for the counting function. We now remove both.

**Definition 9.1 (Consecutive gap ratio).** For a level sequence $\lambda$ and index $i$,
$$r_i(\lambda) := \frac{\min\big(g_i(\lambda),\, g_{i+1}(\lambda)\big)}{\max\big(g_i(\lambda),\, g_{i+1}(\lambda)\big)}.$$

**Theorem 9.2 (The gap ratio needs no unfolding).** For every $a > 0$, every $b\in\mathbb{R}$ and every $i$,
$$r_i(a\lambda + b) = r_i(\lambda).$$

*Proof.* All gaps scale as $g_j(a\lambda+b) = a\,g_j(\lambda)$. Since $a > 0$, both $\min$ and $\max$ commute with multiplication by $a$, and the common factor cancels. $\square$

There is no window, no mean spacing and no counting function in Definition 9.1: the ratio is built from three consecutive levels alone.

**Theorem 9.3 (Range).** If $g_i(\lambda) > 0$ then $r_i(\lambda) \le 1$; if in addition $g_{i+1}(\lambda) > 0$ then $0 \le r_i(\lambda) \le 1$.

*Proof.* Positivity of $g_i$ makes the maximum positive, and $\min \le \max$ gives the upper bound; positivity of both gaps makes the minimum nonnegative. $\square$

**Theorem 9.4 (Characterization of rigidity).** If $g_i(\lambda) > 0$ then
$$r_i(\lambda) = 1 \iff g_i(\lambda) = g_{i+1}(\lambda).$$

*Proof.* With the maximum positive, $r_i = 1$ iff $\min = \max$, which for two reals holds iff they are equal. $\square$

### 9.1 The quadratic spectrum through the ratio lens

**Theorem 9.5.** For the *raw* quadratic spectrum $\lambda_k = k^2$ and every $i \ge 0$,
$$r_i = \frac{2i+1}{2i+3}, \qquad 1 - r_i = \frac{2}{2i+3}, \qquad r_i < 1, \qquad r_i \xrightarrow[i\to\infty]{} 1.$$
For the unfolded spectrum $\mu_k = k$, $r_i = 1$ exactly, for every $i$.

*Proof.* The gaps are $g_i = 2i+1 \le 2i+3 = g_{i+1}$, so the minimum is $2i+1$ and the maximum is $2i+3$. The identity $1 - \frac{2i+1}{2i+3} = \frac{2}{2i+3}$ is arithmetic; positivity of $2/(2i+3)$ gives $r_i < 1$, and $2/(2i+3)\to 0$ gives the limit. For the picket fence all gaps equal $1$, so $\min = \max = 1$. $\square$

**Remark 9.6 (The point of the ratio statistic).** Compare Theorem 9.5 with Theorem 3.3. Applied to the *same raw data*, the normalized-gap distribution reports a uniform law on $[0,2]$ — a spurious, correlation-free artefact of the diverging density of states — while the ratio statistic reports $r_i \to 1$ with the explicit rate $1 - r_i = 2/(2i+3)$, i.e. correctly identifies the spectrum as asymptotically rigid, with no unfolding whatsoever. The ratio statistic sees through the density of states because it compares each gap only with its immediate neighbour, over which the density has essentially no time to change.

**Remark 9.7 (Universality constants).** Because of Theorem 9.2, the mean value of $r$ under a universality class is an honest, unfolding-free universality constant. For Poisson levels the expected ratio is $2\ln 2 - 1 \approx 0.3863$; for unitary statistics it is approximately $0.5996$; and for a rigid spectrum it is $1$. These are the numbers routinely used in numerical studies of quantum chaos and many-body localization, precisely because they can be extracted from a raw spectrum without any preprocessing.

---

## 10. Algorithms

The results above translate directly into finite algorithms, all elementary and all with linear or near-linear cost.

**Algorithm A (Empirical normalized-gap CDF).** Given levels $\lambda_0,\dots,\lambda_n$: form the $n$ raw gaps, compute $\bar g_n = (\lambda_n - \lambda_0)/n$, divide, sort, and evaluate the empirical CDF at the requested thresholds. Cost $O(n\log n)$ dominated by the sort, or $O(n)$ per threshold without sorting. Applying this to $\lambda_k = k^2$ reproduces the $1/(2n)$ bound of Theorem 3.3 to machine precision.

**Algorithm B (Unfolding by a monotone counting map).** Given levels and a smoothed counting function $N$, replace $\lambda_k$ by $N(\lambda_k)$ and re-run Algorithm A. When $N$ is the exact counting function, Theorem 4.1 guarantees that every normalized gap is $1$; the interest lies in *smoothed* $N$, for which the output is the fluctuation spectrum.

**Algorithm C (Two-level correlation count).** The naive count over ordered pairs costs $O(n^2)$. For a sorted spectrum, a two-pointer sweep computes $R_2(n,t)$ in $O(n)$ after sorting: for each $i$, advance a pointer to the largest $j$ with $\lambda_j \le \lambda_i + t$, and add $2(j - i)$. For the picket fence this returns exactly $2\lfloor t\rfloor n - \lfloor t\rfloor(\lfloor t\rfloor+1)$ of Theorem 5.4.

**Algorithm D (Number variance by window sampling).** Fix a window length $L$; sample window positions $a$ uniformly over the spectral range; count levels in $[a, a+L)$ by binary search in $O(\log n)$ each; report the empirical variance of the counts. For the picket fence the output is $O(1)$ in $L$ (Theorem 6.2 caps the deviation at $1$ pointwise, so the variance never exceeds $1$); for simulated Poisson levels it grows like $L$.

**Algorithm E (Gap-ratio statistic).** Form the raw gaps and output $r_i = \min(g_i,g_{i+1})/\max(g_i,g_{i+1})$ for each $i$, then report the mean. Cost $O(n)$, no preprocessing, no parameters. By Theorem 9.2 the output is unchanged if the input is affinely rescaled — a property that can be, and in the accompanying numerics is, verified directly.

---

## 11. Applications

**Quantum chaos diagnostics.** The mean gap ratio is now the standard order parameter in numerical studies of the many-body localization transition, precisely because it requires no unfolding of a spectrum whose density of states is exponential in system size and therefore extremely awkward to unfold reliably. Theorem 9.2 is the formal justification; Theorem 9.5 is a worked example showing that it correctly identifies rigidity where the naive statistic fails.

**Number theory.** The ordinates of the nontrivial zeros of the Riemann zeta function have density $\frac{1}{2\pi}\log\frac{T}{2\pi}$ at height $T$, so unfolding is mandatory before comparing to random-matrix predictions. The general unfolding principle (Theorem 4.1) formalizes what the standard change of variable accomplishes, and Theorem 3.3 quantifies what is being removed.

**Detecting spurious universality.** Theorem 3.3 is a cautionary template: a spectrum whose density of states scales like a power of the level index will produce a clean but meaningless limit law for raw normalized gaps. Any reported spacing law should therefore be accompanied by an invariance check — recompute after an affine rescaling of the raw levels (which must change nothing, by Theorem 2.5) and after changing the window size (which will change a spurious law substantially).

**Model discrimination with finite data.** Theorems 8.3 and 8.4 give window-size-independent lower bounds, so a single spacing histogram with a resolvable bin below $s = 1/2$ suffices to reject rigidity if any small spacings are observed, and to reject both universality classes if none are.

---

## 12. Discussion

The technical content of this paper is elementary; its value lies in the sharpness and completeness of the statements. Three points deserve emphasis.

First, the failure mode illustrated by Theorem 3.3 is *not* a small effect that careful practice mitigates. The spurious law for $\lambda_k = k^2$ is a uniform distribution — as far from both an exponential and a Wigner surmise as one could ask — approached at rate $O(1/n)$. Comparing a raw normalized-gap histogram with $e^{-s}$ is measuring the wrong thing, and the wrong thing can be arbitrarily convincing.

Second, the three regimes are separated in *every* observable we examined, with explicit constants, and the separations are mutually consistent:

| Observable | Rigid (picket fence) | Unitary | Poisson |
|---|---|---|---|
| Spacing density | Dirac mass at $1$ | $\frac{32}{\pi^2}s^2e^{-4s^2/\pi}$ | $e^{-s}$ |
| Spacing variance | $0$ | $\frac{3\pi}{8}-1 \approx 0.178$ | $1$ |
| Interior mode | (degenerate) at $1$ | $\sqrt{\pi}/2 \approx 0.886$ | none (monotone) |
| Small spacings $s < 1/2$ | probability $0$ | $\ge 1/12$ | $\ge 1/3$ |
| Two-level density | staircase $2\lfloor t\rfloor$ | continuous, $2t$ minus sine-kernel term | $2t$ |
| Number variance in $[a, a+L)$ | bounded, $< 1$ | $\sim \frac{1}{\pi^2}\log L$ | $L$ |
| Mean gap ratio | $1$ | $\approx 0.5996$ | $2\ln 2 - 1 \approx 0.386$ |

Third, and most useful in practice, the *invariance-first* design principle. Rather than trying to normalize away an unwanted transformation, build the statistic so that the transformation cancels. The gap ratio does this for the affine group $\lambda \mapsto a\lambda + b$, $a > 0$: it is a quotient of two quantities that transform identically. The mode of a spacing density does it in a different way — the presence of an interior maximum is preserved by every rescaling, so it can be tested even when the normalization is unknown.

**Limitations.** Two boundaries of the present work should be stated plainly. The unitary spacing law used here is the Wigner surmise, the $2\times 2$ approximation, not the exact sine-kernel gap distribution of the infinite unitary ensemble; the two agree to within a fraction of a percent but are not identical, and statements such as Theorem 7.10 concern the surmise. Likewise the "Poisson" and "unitary" comparisons are comparisons with *densities*, not with random processes: the number-variance and two-level statements for those classes are quoted as context in Remarks 5.7 and 6.5 rather than derived here. All statements attributed above to the picket fence, to the raw and unfolded quadratic spectrum, to the two explicit densities, and to the gap ratio are proved in full.

---

## 13. Future Directions

### 13.1 What survived and what needed a different definition

The unfolding invariants (sum of normalized gaps, affine invariance); the uniform-on-$[0,2]$ law of the raw quadratic spectrum with rate $1/(2n)$; the Dirac law after unfolding; the exact pair-correlation staircase $2\lfloor t\rfloor n - \lfloor t\rfloor(\lfloor t\rfloor+1)$ and its density limit $2\lfloor t\rfloor$; bounded number variance ($<1$ in every window); normalization, unit mean and second moments of both densities; the variance ordering $0 < 3\pi/8 - 1 < 1$; quadratic level repulsion on $(0,1/4]$; non-equivalence of the two classes under any rescaling; and the interior mode $\sqrt{\pi}/2$ of the Wigner surmise — all of these are established here in full.

One planned comparison had to be abandoned and replaced. The first attempt to compare the quadratic spectrum with the two universality classes used the *raw* normalized gaps. That comparison is meaningless: the raw law is uniform on $[0,2]$ purely because the density of states diverges. The correct objects are (i) the unfolded gaps and (ii) unfolding-free statistics such as the gap ratio, which already sees rigidity in the raw spectrum.

Two targets remained out of reach in this cycle. The genuine two-level form factor of the unitary class, $R_2(t) = 1 - \left(\frac{\sin \pi t}{\pi t}\right)^2$ — as opposed to the Wigner surmise — requires the sine-kernel determinantal process. Likewise the exact Poisson mean gap ratio $2\ln 2 - 1$ requires a two-dimensional density computation.

### 13.2 Conjecture 1: Sine-Kernel Rigidity Threshold

The key insight is that the bounded number variance proved for the picket fence (deviation $< 1$) and the logarithmic variance $\frac{1}{\pi^2}(\log L + c)$ expected for unitary statistics are separated by a *scale-free* dichotomy: a spectrum is "rigid" iff its window-count deviation is $O(1)$, "unitary-like" iff it is $\Theta(\log L)$, and "Poisson-like" iff it is $\Theta(\sqrt{L})$.

**Conjecture.** For every deterministic spectrum $\lambda_k = f(k)$ with $f$ smooth, convex, and $f'$ polynomially growing, the unfolded number variance is bounded by an absolute constant.

Why now: the unfolding principle and the ceiling-based window count are already in place, so only the arithmetic of $\lceil\cdot\rceil$ along $f$ remains.

### 13.3 Conjecture 2: Gap-Ratio Universality Constants

The key insight is that the ratio statistic is invariant under affine rescaling with no unfolding at all, so the numbers $\langle r\rangle_{\mathrm{Poisson}} = 2\ln 2 - 1$ and $\langle r\rangle_{\mathrm{unitary}} \approx 0.5996$ are honest, unfolding-free universality constants.

**Conjecture.**
$$\int_0^\infty\!\!\int_0^\infty \frac{\min(s,t)}{\max(s,t)}\,e^{-s-t}\,ds\,dt = 2\ln 2 - 1,$$
and the corresponding Wigner-surmise integral is strictly larger, with the ordering $2\ln 2 - 1 < \langle r\rangle_{\mathrm{unitary}} < 1$ reproducing the rigid/unitary/Poisson trichotomy in a single scalar that requires no unfolding.

### 13.4 Further directions

* **Smoothed unfolding with controlled error.** Quantify how the empirical spacing law changes when the exact counting function is replaced by a smoothing at scale $\epsilon$, so that the fluctuation content survives with an explicit error term.
* **Beyond arithmetic rigidity.** Extend the bounded-number-variance theorem from $\lambda_k = dk$ to Beatty sequences $\lambda_k = \lfloor \alpha k + \beta\rfloor$, where three-distance phenomena replace the exact ceiling arithmetic.
* **Higher-order ratio statistics.** Study $r_i^{(m)}$ built from gaps at separation $m$ and determine whether the family separates classes more finely than $m = 1$ alone.
* **Quantitative mode detection.** Turn the interior-mode discriminant into a hypothesis test with explicit sample-size requirements, using the strict inequality of Theorem 7.10 to control the gap between the true mode value and nearby values.

---

## 14. Conclusion

Normalized gap statistics are meaningless before unfolding, and we have made this precise: the raw quadratic spectrum obeys a uniform law on $[0,2]$ to within $1/(2n)$, an artefact carrying no correlation information at all. After unfolding, the same spectrum is a perfect picket fence with a Dirac spacing law, an exact staircase two-level correlation $2\lfloor t\rfloor n - \lfloor t\rfloor(\lfloor t\rfloor+1)$, and number variance bounded by $1$ in every window. It is at Kolmogorov–Smirnov distance at least $1/3$ from Poisson statistics and at least $1/12$ from unitary statistics, uniformly in the window size. The two universality classes themselves are separated by the spacing variance ordering $0 < 3\pi/8 - 1 < 1$, by quadratic level repulsion on $(0,1/4]$, by non-equivalence under any rescaling, and by the presence of a strict interior mode $\sqrt{\pi}/2$ with maximal value $8/(\pi e)$ in the unitary case against strict monotonicity in the Poisson case. Finally, the consecutive gap ratio — invariant under every orientation-preserving affine change of scale, with no window and no unfolding — detects the rigidity of the raw quadratic spectrum directly, with the exact deviation $1 - r_i = 2/(2i+3)$. Where a statistic can be built to be blind to the arbitrary choices, it should be.
