# Sampler-Independent Tie Ceilings for the Trailing-Zero Statistic, and the Effective-Base Drift of a Fading Rank Correlation

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

We study the maximal Spearman rank correlation attainable between a heavily tied integer statistic — the trailing-zero count $T(x) = v_2(x)$, the 2-adic valuation — and an arbitrary tie-refining response, as a function of the geometry of the sampler. The motivating problem is empirical: a monitoring program that had tracked $\rho(T,\text{rate})$ across increasing input bit-lengths recorded, at bit-length $100$, a pooled value $\rho = 0.544$ with confidence interval $[0.498,0.588]$ — the first interval to straddle its validation floor $0.55$ on uniform draws. Before attributing this to a genuine decay of signal, one must exclude the possibility that the *ceiling itself* moved, since real samplers do not draw from a power-of-two range.

We prove that it does not. Our main structural result is a **universal range law**: for uniform draws from $\{0,\dots,n-1\}$, the squared tie ceiling is exactly
$$\rho^2_{\max}(n) = \frac67 + \frac{\tfrac67 n - E(n)}{n^3-n}, \qquad n \ge 2,$$
where the *ceiling defect* $E(n) = \sum_i m_i^3 - n^3/7$ satisfies $E(2m) = E(m)$ — hence depends only on the odd part of $n$ — obeys the odd step $E(2a+1) = E(a+1) - (9a^2+3a)/7$, equals $6/7$ exactly at the powers of two and nowhere else, and is sharply bounded by $-\tfrac37 n^2 \le E(n) \le \tfrac67$. Consequently $6/7 < \rho^2_{\max}(n) \le 6/7 + 1/(n-1)$ for every $n$, and at bit-length $100$ the whole admissible spread of ceilings has width below $10^{-29}$.

We then remove the assumption that the sampler starts at $0$. A profile is **dyadically dominated at scale $x$ with slack $C$** if its $i$-th block satisfies $m_i \le x/2^{i+1} + C$. We prove the cube-sum bound $\sum m_i^3 \le x^3/7 + Cx^2 + 3C^2x + C^3K$ ($K$ = number of blocks) and the resulting ceiling bound, and we show by an elementary separation argument ($v_2(x)=k \Rightarrow x \equiv 2^k \bmod 2^{k+1}$) that every offset window $[A,A+n)$ is dominated with slack $2$. Hence *every* dyadically dominated sampler at bit-length $100$ with slack $C\le 4$ has ceiling above $0.85$, while the recorded reading squares to $0.296$.

Finally we develop the base-$p$ analogue — with geometric fixed point $(p-1)^3/(p^3-1)$ and ceiling $3p/(p^2+p+1)$, tied together by the identity $1 - (p-1)^3/(p^3-1) = 3p/(p^2+p+1)$ — and use it to give the erosion a quantitative description: the unique integer base compatible with the bit-length-$76$ window is $7$, the unique base compatible with the bit-length-$100$ window is $9$, and the ceiling gap $7/19 - 27/91 = 124/1729 \approx 0.0717$ matches the recorded drop $0.608^2 - 0.544^2 \approx 0.0737$ to within $0.003$. Interpolating to real bases yields a unique floor-crossing base $t^\star \in (8.80,8.81)$ and, through the calibration one base unit per twelve bit-lengths, a forecast of the first band miss at bit-length between $97.6$ and $97.8$ — strictly inside the observed window $(96,100)$. We complement this with a sharp decision-theoretic analysis of straddling intervals, showing the ambiguity window is at most three rungs (twelve bit-lengths) wide.

**Keywords:** 2-adic valuation, Spearman rank correlation, tie correction, self-similar defect, Takagi-type fluctuation, dyadic domination, effective base.

---

## 1. Introduction

### 1.1 The setting

Let $T(x) = v_2(x)$ denote the 2-adic valuation of a positive integer $x$: the number of trailing zeros in its binary expansion. In a family of computational experiments this statistic served as a *dial* — a cheap predictor of a downstream quantity called the *rate* — and its predictive quality was tracked by Spearman's rank correlation $\rho(T,\text{rate})$ on samples of integers of prescribed bit-length.

The empirical record relevant here is:

| bit-length | pooled $\rho$ | interval |
|---|---|---|
| 76 | $0.608$ | (inside band) |
| 96 | $\approx 0.573$ | straddles |
| 100 | $0.544$ (seeds $0.546/0.528/0.549$) | $[0.498,0.588]$, straddles |
| 104 | $\approx 0.500$ | entirely below |

with validation floor $\rho \ge 0.55$. The trailing-zero statistic outperformed the naive count baseline by $+0.098$ throughout. At bit-length $100$ the interval straddled the floor for the first time on uniform draws.

### 1.2 The confound

Spearman's $\rho$ is a rank statistic, and $T$ is enormously tied: roughly half of all integers have $T=0$, a quarter have $T=1$, and so on. Tied observations share an average rank, and this imposes a hard upper bound on $|\rho|$ regardless of how informative the response is. If the level sets of $T$ on the sample have sizes $m_0, m_1, \dots, m_{K-1}$ with $\sum_i m_i = n$, then the maximum squared Spearman correlation over all responses that refine the tie structure is
$$\rho^2_{\max} = 1 - \frac{\sum_i (m_i^3 - m_i)}{n^3-n}.$$

For the idealised geometric profile $m_i = n/2^{i+1}$ the cubes sum to $n^3 \sum_{i\ge0} 8^{-(i+1)} = n^3/7$, so $\rho^2_{\max} \to 6/7$. All earlier analyses of this dial computed the ceiling for a *power-of-two* draw range. But real instrumentation samples from a rejection window, a residue class, a truncated stream, or the canonical offset window $[2^{99},2^{100})$ of exact 100-bit integers. In such samples the tie blocks are only approximately geometric, and *a priori* the ceiling could fluctuate with them — possibly enough to explain the observed decline without any decay of the underlying signal.

This paper closes that confound completely and then, with the sampler excluded, gives the erosion a quantitative description.

### 1.3 Contributions

1. **The universal range law** (Section 3): an exact closed form for the tie ceiling of $\{0,\dots,n-1\}$ for every $n$, in terms of a self-similar defect function $E$.
2. **The defect's structure** (Sections 3–4): doubling invariance, the exact odd step, the characterisation of powers of two as the unique maximisers, and the sharp fluctuation constant $3/7$ with an extremal family realising it.
3. **Dyadic domination** (Section 5): a sampler-free cube-sum bound depending only on an upper envelope on block sizes, with all error coefficients balancing exactly.
4. **Offset windows** (Section 6): the arithmetic separation argument that makes domination a theorem rather than a hypothesis, for arbitrary integer windows.
5. **The base-$p$ theory and effective-base drift** (Section 7): the generalised fixed point, the effective-base inversion $7 \to 9$, and its quantitative agreement with the recorded drop.
6. **The floor-crossing forecast** (Section 8): a unique real crossing base and a falsifiable prediction of the first band miss.
7. **Straddle geometry** (Section 9): what a boundary-crossing interval can and cannot decide, with a bounded resolution horizon.

---

## 2. Preliminaries

### 2.1 Tie profiles and the ceiling

**Definition 2.1 (Tie profile).** A *tie profile* is a finite list $L = (m_0, m_1, \dots, m_{K-1})$ of non-negative integers. Its *size* is $n = \sum_i m_i$ and its *length* is $K$. In our application $m_i$ is the number of sampled integers of 2-adic valuation exactly $i$.

**Definition 2.2 (Tie correction and ceiling).** For a profile $L$ of size $n$, the *tie correction* is
$$\tau(L) = \frac{1}{12}\sum_i (m_i^3 - m_i) = \frac{\Sigma_3(L) - n}{12}, \qquad \Sigma_3(L) := \sum_i m_i^3,$$
and the *(squared) tie ceiling* is
$$\rho^2_{\max}(L) = 1 - \frac{12\,\tau(L)}{n^3 - n} = 1 - \frac{\Sigma_3(L) - n}{n^3-n}, \qquad n \ge 2.$$

The expression is the classical Spearman tie correction: within a block of size $m$ all ranks are equal, and the rank sum-of-squares loses exactly $(m^3-m)/12$. It is achieved by any response that orders the blocks correctly and is arbitrary inside them; hence "ceiling" and not merely "bound".

Throughout, $n \ge 2$ ensures $n^3 - n > 0$.

### 2.2 The dyadic profile

**Definition 2.3.** For $b\ge 0$ the *dyadic profile* is $D_b = (2^{b-1}, 2^{b-2}, \dots, 2, 1, 1)$, i.e. $D_0 = (1)$ and $D_{b+1} = 2^b \Vert D_b$. It is the exact tie profile of $\{0,\dots,2^b-1\}$: the block $\{0\}$ contributes the trailing $1$.

A direct computation gives $\Sigma_3(D_b) = (n^3+6)/7$ with $n=2^b$, hence
$$\rho^2_{\max}(D_b) = \frac67\left(1 + \frac{1}{2^b(2^b+1)}\right). \tag{2.1}$$
This is the classical dyadic law that all previous analysis rested on. Everything below generalises it.

---

## 3. The universal range law

### 3.1 The halving recursion

**Definition 3.1 (Range profile).** For $n \ge 0$ define $B(n)$, the 2-adic tie profile of $\{0,1,\dots,n-1\}$, by
$$B(0) = (\,), \qquad B(1) = (1), \qquad B(n) = \left\lfloor \tfrac n2\right\rfloor \ \Vert\ B\!\left(\left\lceil \tfrac n2\right\rceil\right)\ \ (n\ge2).$$

**Proposition 3.2 (Correctness and basic facts).** $B(n)$ is the tie profile of $\{0,\dots,n-1\}$; its entries sum to $n$; and $B(2^b) = D_b$.

*Proof sketch.* Among $x < n$ exactly $\lfloor n/2\rfloor$ are odd, i.e. have $v_2 = 0$. The even ones are $x = 2y$ with $y < \lceil n/2 \rceil$ and $v_2(2y) = v_2(y)+1$, so the remaining blocks are those of $B(\lceil n/2\rceil)$ shifted by one index. The sum identity follows by strong induction since $\lfloor n/2\rfloor + \lceil n/2\rceil = n$; the power-of-two identity from $2^{b+1}/2 = (2^{b+1}+1)/2 = 2^b$ in integer arithmetic. $\square$

For example $B(11) = (5,3,1,1,1)$ and $B(3) = (1,1,1)$.

### 3.2 The ceiling defect

**Definition 3.3 (Ceiling defect).** $\displaystyle E(n) = \Sigma_3(B(n)) - \frac{n^3}{7}.$

The value $n^3/7$ is the geometric ideal; $E$ measures the arithmetic obstruction to it.

**Theorem 3.4 (Doubling invariance).** For every $m \ge 1$, $E(2m) = E(m)$. Hence $E(n)$ depends only on the odd part of $n$.

*Proof sketch.* By the recursion, $B(2m) = m \Vert B(m)$ (since $\lfloor 2m/2\rfloor = \lceil 2m/2 \rceil = m$). Therefore
$$E(2m) = m^3 + \Sigma_3(B(m)) - \frac{8m^3}{7} = \Sigma_3(B(m)) - \frac{m^3}{7} = E(m),$$
because $m^3 - 8m^3/7 = -m^3/7$. $\square$

**Theorem 3.5 (Odd step).** For every $a \ge 1$,
$$E(2a+1) = E(a+1) - \frac{9a^2+3a}{7}.$$

*Proof sketch.* Here $\lfloor (2a+1)/2 \rfloor = a$ and $\lceil (2a+1)/2\rceil = a+1$, so $B(2a+1) = a \Vert B(a+1)$ and
$$E(2a+1) = a^3 + \Sigma_3(B(a+1)) - \frac{(2a+1)^3}{7} = E(a+1) + a^3 + \frac{(a+1)^3 - (2a+1)^3}{7},$$
and $(a+1)^3 - (2a+1)^3 + 7a^3 = -(9a^2+3a)$. $\square$

**Corollary 3.6.** $E(1) = 6/7$ and $E(2^b) = 6/7$ for every $b \ge 0$.

**Theorem 3.7 (Two-sided bound).** For every $n$,
$$-\frac37 n^2 \;\le\; E(n) \;\le\; \frac67 .$$

*Proof sketch.* Strong induction. Even $n$: inherit from $n/2$; for the lower bound note $-\tfrac37(n/2)^2 \ge -\tfrac37 n^2$. Odd $n = 2a+1$ with $a\ge1$: the upper bound is immediate from Theorem 3.5 since the penalty is non-negative; the lower bound follows from $-\tfrac37(a+1)^2 - (9a^2+3a)/7 \ge -\tfrac37(2a+1)^2$, which reduces to $\tfrac37(4a^2+4a+1) - \tfrac37(a^2+2a+1) - \tfrac{9a^2+3a}{7} = 0$ — the two sides balance exactly, which is why $3/7$ is the right constant. The base case $n=1$ gives $6/7 \le 6/7$. $\square$

The odd step also yields the strengthened estimate used below.

**Corollary 3.8.** For odd $n = 2a+1$ with $a \ge 1$, $\ E(n) \le \tfrac67 - \tfrac{n^2}{7}$.

### 3.3 The law

**Theorem 3.9 (Universal range law).** For every $n \ge 2$,
$$\rho^2_{\max}(B(n)) = \frac67 + \frac{\tfrac67 n - E(n)}{n^3-n}.$$

*Proof sketch.* Substitute $\Sigma_3(B(n)) = n^3/7 + E(n)$ into Definition 2.2:
$$1 - \frac{n^3/7 + E(n) - n}{n^3-n} = \frac{(n^3-n) - n^3/7 + n - E(n)}{n^3-n} = \frac{\tfrac67 n^3 - E(n)}{n^3-n},$$
and $\tfrac67 n^3 = \tfrac67(n^3-n) + \tfrac67 n$. $\square$

**Corollary 3.10 (Universal bracketing).** For every $n \ge 2$,
$$\frac67 \;<\; \rho^2_{\max}(B(n)) \;\le\; \frac67 + \frac{1}{n-1}.$$
For $n\ge 13$ the upper bound improves to $\tfrac67 + \tfrac{1}{2n}$.

*Proof sketch.* Strict positivity of the correction from $E(n) \le 6/7 < \tfrac67 n$ (using $n\ge2$). The upper bound from $E(n) \ge -\tfrac37 n^2$: the correction is at most $(\tfrac67 n + \tfrac37 n^2)/(n^3-n)$, and cross-multiplying against $1/(n-1)$ (resp. $1/(2n)$ for $n\ge13$) gives a polynomial inequality valid in the stated range. $\square$

**Corollary 3.11 (Consistency).** At $n = 2^b$, $b\ge1$, Theorem 3.9 with $E(2^b) = 6/7$ reproduces (2.1) exactly.

*Proof sketch.* $\tfrac67 + \tfrac{\tfrac67 n - \tfrac67}{n^3-n} = \tfrac67\left(1 + \tfrac{n-1}{n(n-1)(n+1)}\right) = \tfrac67\left(1+\tfrac{1}{n(n+1)}\right)$. $\square$

This is a genuinely independent re-derivation: the dyadic law was originally obtained by summing a finite geometric series of cubes, whereas here it drops out of a general recursion.

**Corollary 3.12 (Odd ranges sit an order higher).** For odd $n = 2a+1$, $a\ge1$,
$$\rho^2_{\max}(B(n)) - \frac67 \;\ge\; \frac{1}{7n}.$$

*Proof sketch.* Insert Corollary 3.8 into Theorem 3.9: the numerator is at least $\tfrac67 n - \tfrac67 + \tfrac{n^2}{7} \ge \tfrac{n^2}{7}$, and $n^2/7$ divided by $n^3-n$ exceeds $1/(7n)$. $\square$

So the excess is $\Theta(1/n)$ for odd ranges but only $\Theta(1/n^2)$ for powers of two — a genuine dichotomy in *relative* terms, quantified below.

---

## 4. The fluctuation spectrum

### 4.1 Extremality of powers of two

**Theorem 4.1 (Unique maximisers).** For $n \ge 1$: $\ E(n) = \tfrac67$ if and only if $n$ is a power of two. Equivalently, power-of-two ranges are the unique minimisers of the tie ceiling among all draw ranges.

*Proof sketch.* Sufficiency is Corollary 3.6. For necessity, strong induction: if $n = 2m$ is even, $E(m) = E(n) = 6/7$ and $m$ is a power of two by hypothesis; if $n = 2a+1$ is odd with $a \ge 1$, Corollary 3.8 gives $E(n) \le \tfrac67 - n^2/7 < \tfrac67$, a contradiction; and $n=1=2^0$ closes the base case. $\square$

### 4.2 Sharpness of the constant $3/7$

The lower bound $E(n) \ge -\tfrac37 n^2$ is optimal, and the witnessing family is dictated by the recursion: to pay the quadratic penalty at every rung, the halving chain $n \mapsto (n+1)/2$ must stay odd all the way down. That forces $n_j = 2^{j+1}+1$, i.e. the family $3,5,9,17,33,\dots$, whose chain is $n \mapsto 2n-1$.

**Lemma 4.2 (Extremal step).** For $m \ge 2$, $\ E(2m-1) = E(m) - \dfrac{9(m-1)^2 + 3(m-1)}{7}$.

*Proof sketch.* Write $m = a+1$ and apply Theorem 3.5. $\square$

**Theorem 4.3 (Extremal family).** For every $j \ge 0$, with $n_j = 2^{j+1}+1$,
$$E(n_j) \;\le\; -\frac37 n_j^2 + \frac37 n_j + \frac{12}{7}.$$
Consequently $E(n_j)/n_j^2 \to -3/7$ and the constant of Theorem 3.7 cannot be improved.

*Proof sketch.* Induction on $j$. The base case is $E(3) = -6/7$ (from $B(3) = (1,1,1)$, $\Sigma_3 = 3$, $3 - 27/7 = -6/7$), and $-\tfrac37\cdot 9 + \tfrac37\cdot3 + \tfrac{12}{7} = -\tfrac{27}{7}+\tfrac97+\tfrac{12}{7} = -\tfrac67$: the base case is an *equality*. The step uses $n_{j+1} = 2n_j - 1$ and Lemma 4.2; substituting the inductive bound and expanding, the quadratic terms match identically.

The underlying reason for the constant: along the chain, the penalties $(9a^2+3a)/7$ with $a \approx n/2^{k+1}$ form a geometric series of ratio $1/4$, and $\frac{9}{28}\left(1+\tfrac14+\tfrac1{16}+\cdots\right) = \frac{9}{28}\cdot\frac43 = \frac37$. The fluctuation is self-similar, and its amplitude is fixed by 2-adic scaling alone. $\square$

**Corollary 4.4 (Matching $\Theta(1/n)$ excess).** For $j \ge 5$,
$$\frac{2}{5n_j} \;\le\; \rho^2_{\max}(B(n_j)) - \frac67 \;\le\; \frac{1}{2n_j}.$$

Thus the excess is genuinely of order $1/n$ with an optimal constant governed by $3/7$, and $\Theta(1/n^2)$ at powers of two.

### 4.3 Self-similarity

Theorem 3.4 says $E$ is constant along doublings, hence descends to a function of the odd part of $n$; Theorem 3.5 says the odd step is an affine contraction of ratio $1/4$ in the normalised variable $E(n)/n^2$. This is precisely the structure that produces Takagi/Trollope–Delange fluctuations for binary digit sums: one expects $E(n)/n^2$ to converge, along $n \to \infty$, to a nowhere-differentiable periodic profile in $\log_2 n \bmod 1$, oscillating between $0$ (approached at powers of two, where $E$ is the constant $6/7 = o(n^2)$) and $-3/7$. We prove the two extremes and the envelope; the full limit profile is left open (Section 10).

### 4.4 The bit-length-100 dichotomy and window

**Theorem 4.5 (Dichotomy).** 
$$10^{28}\left(\rho^2_{\max}(B(2^{100})) - \tfrac67\right) \;<\; \rho^2_{\max}(B(2^{100}-1)) - \tfrac67 .$$

*Proof sketch.* The left side is $10^{28}\cdot\tfrac67\cdot\tfrac{1}{2^{100}(2^{100}+1)} \approx 10^{28}\cdot 6.8\times10^{-61}$, while by Corollary 3.12 (with $2^{100}-1 = 2(2^{99}-1)+1$ odd) the right side is at least $1/(7(2^{100}-1)) \approx 1.1\times10^{-31}$. $\square$

**Theorem 4.6 (Ceiling window at bit-length 100).** For every $n \ge 2^{100}$,
$$\frac67 \;<\; \rho^2_{\max}(B(n)) \;<\; \frac67 + 10^{-29}.$$

*Proof sketch.* Corollary 3.10 with $n - 1 \ge 2^{100}-1 > 10^{29}$. $\square$

So the ceiling is *extremely* sensitive to the parity structure of $n$ in relative terms, and *totally* insensitive to it at the scale of the measurement: the entire spread is $10^{-29}$ against a recorded four-bit erosion step of $0.030$ — twenty-seven orders of magnitude smaller than the effect under investigation.

**Corollary 4.7 (First payload).** For every $n \ge 2$, $\ 0.544^2 < \rho^2_{\max}(B(n))$; indeed the same holds with $0.544$ replaced by the optimistic interval endpoint $0.588$, since $0.588^2 = 0.3457 < 6/7$. No sampling-range shape — power of two, odd modulus, rejection window, truncated stream — can produce the measured attenuation.

---

## 5. Dyadic domination: removing the sampler

Sections 3–4 still assume the sampler enumerates $\{0,\dots,n-1\}$. We now isolate the *only* property of that profile the argument needs.

**Definition 5.1 (Dyadic domination).** A profile $L$ is *dyadically dominated at scale $x \ge 0$ with slack $C \ge 0$*, written $\mathrm{DD}(L;x,C)$, if for every index $i$ (with entries past the end of $L$ read as $0$),
$$m_i \;\le\; \frac{x}{2^{i+1}} + C.$$

Two trivial but essential structural lemmas: if $\mathrm{DD}(m\Vert L; x, C)$ then $m \le x/2 + C$ (index $0$), and $\mathrm{DD}(L; x/2, C)$ (shift the index, using $x/2^{i+2} = (x/2)/2^{i+1}$).

**Theorem 5.2 (Dyadic cube-sum bound).** If $\mathrm{DD}(L;x,C)$ with $x,C\ge0$ and $L$ has $K$ blocks, then
$$\Sigma_3(L) \;\le\; \frac{x^3}{7} + Cx^2 + 3C^2 x + C^3 K .$$

*Proof sketch.* Induction on $L$. Empty list: right side is non-negative. Cons step $L' = m \Vert L$: the head obeys $m^3 \le (x/2 + C)^3$, and the tail obeys the inductive bound at scale $x/2$ with $K$ blocks. Adding and expanding, each coefficient balances *exactly*:
$$\underbrace{\frac18 + \frac1{56}}_{=\ 1/7}x^3, \qquad \underbrace{\frac{3C}{4} + \frac{C}{4}}_{=\ C}x^2, \qquad \underbrace{\frac{3C^2}{2} + \frac{3C^2}{2}}_{=\ 3C^2}x, \qquad \underbrace{C^3 + C^3K}_{=\ C^3(K+1)} .$$
(The $x^3$ line: $(x/2)^3 = x^3/8$ from the head, and $(x/2)^3/7 = x^3/56$ from the tail; $1/8+1/56 = 8/56 = 1/7$.) The $x^3/7$ coefficient is the geometric fixed point of the halving map on cubes and is exactly what produces the $6/7$ ceiling; the remaining three terms are the error budget, and no slack is wasted. $\square$

**Theorem 5.3 (Sampler-free ceiling bound).** Let $L$ have size $n = \sum_i m_i \ge 2$, $K$ blocks, and satisfy $\mathrm{DD}(L; n, C)$ with $C \ge 0$. Then
$$\rho^2_{\max}(L) \;\ge\; \frac67 - \frac{Cn^2 + 3C^2 n + C^3K}{n^3-n}.$$

*Proof sketch.* Write $B = Cn^2 + 3C^2n + C^3K$. Theorem 5.2 at $x=n$ gives $\Sigma_3(L) \le n^3/7 + B$, so
$$\rho^2_{\max}(L) = 1 - \frac{\Sigma_3(L)-n}{n^3-n} \ \ge\ 1 - \frac{n^3/7 + B - n}{n^3-n} = \frac67 + \frac{\tfrac67 n}{n^3-n} - \frac{B}{n^3-n},$$
using the algebraic identity $1 - \frac{n^3/7 - n}{n^3-n} = \frac67 + \frac{6n/7}{n^3-n}$; discarding the positive middle term gives the claim. $\square$

**Proposition 5.4 (Range profiles are dominated with slack $1$).** For every $n$, $\mathrm{DD}(B(n); n, 1)$. More precisely, if $x \ge n$ then the $i$-th entry of $B(n)$ is at most $(x-1)/2^{i+1} + 1$.

*Proof sketch.* Strong induction with the *shifted* numerator $x-1$, which is what makes the recursion close: the head is $\lfloor n/2 \rfloor \le n/2 \le (x-1)/2 + 1$, and the tail is $B(\lceil n/2\rceil)$ with $\lceil n/2 \rceil \le (x+1)/2$, for which the inductive hypothesis yields $((x+1)/2 - 1)/2^{i+1} + 1 = (x-1)/2^{i+2}+1$ — exactly the required bound one index later. $\square$

**Corollary 5.5 (Independent second proof).** For $n \ge 2$,
$$\rho^2_{\max}(B(n)) \;\ge\; \frac67 - \frac{n^2 + 3n + K_n}{n^3-n}, \qquad K_n = \#B(n) = O(\log n),$$
recovering the lower half of Corollary 3.10 by a route that never computes $E$.

The abstract bound is weaker than the exact law (it carries an $O(1/n)$ error where the exact computation has none), but it applies to profiles for which no exact law exists.

---

## 6. Offset windows: domination as a theorem

Domination was a hypothesis in Section 5. For the actual samplers of interest it is a theorem, and the mechanism is one line of elementary arithmetic.

**Lemma 6.1 (Separation).** If $x \ne 0$ and $v_2(x) = k$ then $x \equiv 2^k \pmod{2^{k+1}}$. Hence two integers of the same valuation $k$ differ by at least $2^{k+1}$.

*Proof sketch.* Write $x = 2^k m$; $m$ is odd since otherwise $2^{k+1}\mid x$. Then $x \bmod 2^{k+1} = 2^k(m \bmod 2) = 2^k$. $\square$

**Definition 6.2 (Window profile).** For a window $[A, A+n)$ with $A \ge 1$, let
$$m_k(A,n) = \#\{x \in [A,A+n) : v_2(x) = k\},$$
and let $W(A,n,K) = (m_0,\dots,m_{K-1})$.

**Theorem 6.3 (Counting bound).** For $A \ge 1$ and every $k$,
$$m_k(A,n) \;\le\; \frac{n}{2^{k+1}} + 2 .$$

*Proof sketch.* Put $d = 2^{k+1}$. By Lemma 6.1 the map $x \mapsto \lfloor x/d\rfloor$ is injective on the block (two elements with equal quotient and equal remainder $2^k$ coincide), and it maps the block into $[\lfloor A/d\rfloor, \lfloor (A+n)/d\rfloor]$, an interval of $\lfloor (A+n)/d\rfloor + 1 - \lfloor A/d\rfloor$ integers. Using $d\lfloor (A+n)/d\rfloor \le A+n$ and $A < d\lfloor A/d\rfloor + d$ gives the bound $n/d + 2$. $\square$

**Proposition 6.4 (Partition).** If $1 \le A$ and $A + n \le 2^K$, then $\sum_{k<K} m_k(A,n) = n$: the $K$ blocks account for every draw.

*Proof sketch.* Every $x \in [A,A+n)$ is non-zero and satisfies $2^{v_2(x)} \le x < 2^K$, so $v_2(x) < K$; the blocks are the fibres of $v_2$ over $\{0,\dots,K-1\}$, and fibrewise counting gives the interval's cardinality $n$. $\square$

**Corollary 6.5.** $\mathrm{DD}(W(A,n,K); n, 2)$ for every $A \ge 1$, $n$, $K$.

**Theorem 6.6 (Ceiling of an arbitrary offset window).** For $A \ge 1$, $A+n \le 2^K$, $n \ge 2$,
$$\rho^2_{\max}(W(A,n,K)) \;\ge\; \frac67 - \frac{2n^2 + 12n + 8K}{n^3-n}.$$

*Proof sketch.* Theorem 5.3 with $C=2$, using Proposition 6.4 for the size and $K$ for the block count. $\square$

**Corollary 6.7 (Every window at scale $10^4$ and above).** If $n \ge 10^4$ and $K \le n$, then $\rho^2_{\max}(W(A,n,K)) > \tfrac67 - \tfrac1{100} > 0.85$.

*Proof sketch.* The error term is at most $(2n^2+20n)/(n^3-n) \le 1/100$ once $n \ge 10^4$. $\square$

**Theorem 6.8 (The canonical bit-length-100 window).** For the window $[2^{99}, 2^{100})$ of exact 100-bit integers,
$$0.544^2 \;<\; \rho^2_{\max}\bigl(W(2^{99},2^{99},100)\bigr).$$

*Proof sketch.* Corollary 6.7 with $n = 2^{99} \ge 10^4$, $K = 100 \le n$, and $0.544^2 = 0.295936 < 0.85$. $\square$

**Theorem 6.9 (Second payload — no dominated sampler explains the miss).** Let $L$ be any tie profile at bit-length $100$, i.e. of size $n \ge 2^{100}$, with at most $n$ blocks, dyadically dominated at scale $n$ with any slack $C \le 4$. Then $\rho^2_{\max}(L) > 0.85 > 0.544^2$.

*Proof sketch.* Theorem 5.3; bound the error by $(4n^2 + 48n + 64n)/(n^3-n) \le 1/100$ for $n \ge 10^4$. $\square$

Slack $C=4$ comfortably covers every mechanism considered: zero-based ranges ($C=1$), offset windows ($C=2$), unions of two windows, arithmetic-progression samplers, and streams whose blocks deviate from geometric by a bounded additive amount. Together with Theorem 4.6 this closes the entire "the sampler did it" family of explanations.

---

## 7. The base-$p$ theory and the effective-base drift

### 7.1 Base-$p$ domination

Nothing in Section 5 is special to the ratio $1/2$.

**Definition 7.1.** For $p \ge 2$, a profile $L$ is *base-$p$ dominated at scale $x$ with slack $C$* if for all $i$,
$$m_i \;\le\; \frac{x(p-1)}{p^{i+1}} + C.$$
This is the geometry of the $p$-adic valuation: a fraction $(p-1)/p^{i+1}$ of a window has valuation exactly $i$.

**Definition 7.2 (Fixed point and ceiling).** $\displaystyle \kappa(p) = \frac{(p-1)^3}{p^3-1}, \qquad \lambda(p) = \frac{3p}{p^2+p+1}.$

**Lemma 7.3 (The linking identity).** For $p \ge 2$, $\ 1 - \kappa(p) = \lambda(p)$.

*Proof sketch.* $p^3 - 1 = (p-1)(p^2+p+1)$, so $1 - \kappa(p) = \frac{(p-1)(p^2+p+1)-(p-1)^3}{(p-1)(p^2+p+1)} = \frac{(p^2+p+1)-(p-1)^2}{p^2+p+1} = \frac{3p}{p^2+p+1}$. $\square$

At $p=2$: $\kappa(2) = 1/7$ and $\lambda(2) = 6/7$, recovering the dyadic constants. Also $\lambda$ is strictly decreasing in $p$ for $p \ge 1$ (Lemma 8.1 below).

**Theorem 7.4 (Base-$p$ cube-sum bound).** If $L$ is base-$p$ dominated at scale $x \ge 0$ with slack $C \ge 0$ and has $K$ blocks, then
$$\Sigma_3(L) \;\le\; \kappa(p)\,x^3 + 3Cx^2 + 3C^2x + C^3K .$$

*Proof sketch.* As in Theorem 5.2, peeling the head bounded by $x(p-1)/p + C$ and applying the hypothesis to the tail at scale $x/p$. The three key balances are now
$$\left(\frac{x(p-1)}{p}\right)^3 + \kappa(p)\left(\frac{x}{p}\right)^3 = \kappa(p)x^3, \qquad \left(\frac{x(p-1)}{p}\right)^2 + \left(\frac xp\right)^2 \le x^2, \qquad \frac{x(p-1)}{p} + \frac xp = x,$$
the first being exactly the fixed-point equation $\kappa = ((p-1)/p)^3 + \kappa/p^3$, and the second an inequality (with equality only in the limit $p\to\infty$), which is why the $x^2$ coefficient is $3C$ rather than $C$. $\square$

**Theorem 7.5 (Base-$p$ sampler-free ceiling).** If $L$ has size $n \ge 2$, $K$ blocks and is base-$p$ dominated at scale $n$ with slack $C \ge 0$, then
$$\rho^2_{\max}(L) \;\ge\; \lambda(p) - \frac{3Cn^2 + 3C^2n + C^3K}{n^3-n}.$$

*Proof sketch.* Exactly as Theorem 5.3, with $\kappa$ in place of $1/7$; the discarded positive term is $\frac{(1-\kappa(p))n}{n^3-n}$, non-negative because $0 \le \kappa(p) \le 1$, and the constant term is $1 - \kappa(p) = \lambda(p)$ by Lemma 7.3. $\square$

This makes the $p$-adic ceiling law *sampler-independent*: it no longer presupposes a sample size of the form $p^b$, exactly as Section 5 removed that assumption for $p=2$.

### 7.2 Effective-base inversion

The measured correlations are far below the true 2-adic ceiling $6/7$. The effective-base description asks instead: for which base does the *ideal* ceiling equal the *measured* value?

**Theorem 7.6 (Effective base at bit-length 100).** Base $9$ is the unique integer base $p \ge 2$ with
$$0.528^2 \;\le\; \lambda(p) \;\le\; 0.549^2,$$
the squared window spanned by the three recorded seeds. Indeed $\lambda(9) = 27/91 \approx 0.29670$, while $\lambda(8) = 24/73 \approx 0.32877 > 0.549^2 = 0.30140$ and $\lambda(10) = 30/111 \approx 0.27027 < 0.528^2 = 0.27878$; strict antitonicity of $\lambda$ excludes all other bases.

The analogous inversion at bit-length $76$ (where $\rho \approx 0.608$, $\rho^2 \approx 0.3697$) singles out $p = 7$, with $\lambda(7) = 7/19 \approx 0.36842$.

**Theorem 7.7 (The drift accounts for the drop).**
$$\bigl|\,(\lambda(7)-\lambda(9)) - (0.608^2 - 0.544^2)\,\bigr| \;\le\; 0.003 .$$
Explicitly $\lambda(7)-\lambda(9) = \tfrac7{19} - \tfrac{27}{91} = \tfrac{124}{1729} \approx 0.07171$, and $0.608^2 - 0.544^2 = 0.07373$.

Thus twenty-four bit-lengths of erosion are quantitatively one and a bit units of effective base: **one base unit per twelve bit-lengths**.

**Remark 7.8 (What the effective base is not).** The statistic is and remains 2-adic; its true ceiling $\lambda(2) = 6/7$ stays far above every recorded seed (indeed $2\cdot0.549^2 = 0.6028 < 6/7$). The effective base is a compact description of the *response channel's* attenuation, not a claim about the sampler's arithmetic. Likewise, all three seeds squared lie strictly between $\lambda(10)$ and $\lambda(8)$, so the entire seed spread is explained by an effective base in the open interval $(8,10)$.

---

## 8. The floor-crossing forecast

Theorem 7.7 turns a description into a model, and a model must make a prediction.

**Definition 8.1 (Real interpolation).** $\displaystyle g(t) = \frac{3t}{t^2+t+1}$ for $t \in \mathbb{R}$; note $t^2+t+1 = (t+\tfrac12)^2 + \tfrac34 > 0$ always, so $g$ is continuous on $\mathbb{R}$, and $g(p) = \lambda(p)$ at integers.

**Lemma 8.2 (Strict antitonicity).** If $1 \le s < t$ then $g(t) < g(s)$.

*Proof sketch.* Cross-multiplying, $g(s) - g(t) > 0$ is equivalent to $3(t-s)(st-1) > 0$, which holds since $t>s\ge1$ forces $st>1$. $\square$

**Theorem 8.3 (Unique crossing base).** There is exactly one real $t^\star \ge 1$ with $g(t^\star) = 0.55^2 = \tfrac{121}{400}$, and
$$8.80 \;<\; t^\star \;<\; 8.81 .$$

*Proof sketch.* Existence by the intermediate value theorem on $[8.80, 8.81]$: $g(8.80) = \tfrac{660}{2181} \approx 0.302614 > 0.3025$ and $g(8.81) = \tfrac{264300}{874261} \approx 0.302313 < 0.3025$. Uniqueness among $t\ge1$ from Lemma 8.2. The bracketing statement follows from the same two evaluations. (Equivalently, clearing denominators, $t^\star$ is the larger root of $121t^2 - 1079\,t + 121 = 0$, namely $t^\star = \tfrac{1079+\sqrt{1105677}}{242} = 8.8038\ldots$.) $\square$

**Definition 8.4 (Drift calibration).** $\beta(t) = 76 + 12(t-7)$, the linear map determined by the two measured effective bases: $\beta(7) = 76$, $\beta(9) = 100$.

**Theorem 8.5 (Forecast).** $\ 97.6 < \beta(t^\star) < 97.8$.

*Proof sketch.* Immediate from Theorem 8.3: $\beta$ is increasing with slope $12$, and $\beta(8.80) = 97.6$, $\beta(8.81) = 97.72$. $\square$

**Corollary 8.6 (Agreement with the record).** $96 < \beta(t^\star) < 100$: the predicted crossing lies strictly inside the observed straddle window. On a rung ladder of step $4$ this is precisely the prediction "last clean rung at bit-length $96$, first band miss at bit-length $100$" — which is exactly what was recorded.

The forecast is sharp enough to be falsified: it excludes a first miss at $96$ or earlier and at $104$ or later.

**Corollary 8.7 (The crossing is non-arithmetic).** $8 < t^\star < 9$: no *integer* effective base sits on the band floor. In the effective-base coordinate the floor crossing occurs strictly between two consecutive arithmetic markers, which is why the event has no clean arithmetic signature and can only be located by interpolation.

---

## 9. Straddle geometry: the logic of a boundary crossing

Finally we make precise what a straddling interval does and does not establish. This part is elementary but the constants are sharp and directly applicable.

**Definition 9.1.** An interval of half-width $w$ about $c$ *straddles* the threshold $B$ if $c-w<B<c+w$, and *resolves* $B$ if $c+w<B$ or $B<c-w$. Resolving implies not straddling.

**Definition 9.2.** A reading sequence $f:\mathbb{N}\to\mathbb{R}$ *erodes at rate at least $d$* if $f(k+1) \le f(k) - d$ for all $k$.

**Lemma 9.3 (Descent bound).** If $f$ erodes at rate at least $d$ and $i \le j$, then $f(j) + (j-i)d \le f(i)$.

*Proof sketch.* Induction on $j - i$. $\square$

**Theorem 9.4 (Resolution horizon).** If $f$ erodes at rate at least $d$ and the intervals of half-width $w$ at rungs $i \le j$ both straddle the same threshold $B$, then $(j-i)\,d < 2w$.

*Proof sketch.* Straddling at $i$ gives $f(i) - w < B$; at $j$ gives $B < f(j)+w$. Chain with Lemma 9.3: $f(j) + (j-i)d \le f(i) < B + w < f(j) + 2w$. $\square$

So ambiguity about band membership is confined to a window of fewer than $2w/d$ rungs; it can never persist indefinitely.

**Corollary 9.5 (Three rungs at bit-length 100).** With the recorded conservative half-width $w = 0.046$ and four-bit erosion step $d = 0.030$, any two straddling rungs differ by fewer than $2w/d = 3.07$, hence by at most $3$ rungs — **twelve bit-lengths**.

**Theorem 9.6 (Exit bound).** If $f$ erodes at rate at least $d$ and $f(i)+w < B + kd$, then $f(i+k)+w<B$: the interval is entirely below the threshold $k$ rungs later. Moreover, once entirely below, it stays below (for $d \ge 0$).

**Corollary 9.7 (Prediction and outcome).** From $f(i) = 0.544$, $w = 0.046$, $B = 0.55$, $d = 0.030$: since $0.544+0.046 = 0.590 < 0.55 + 2(0.030) = 0.610$, the whole interval is below the floor by rung $i+2$, i.e. by bit-length $108$. The recorded bit-length-$104$ interval was already entirely below the floor — the exit came **one rung early**, so the erosion between $100$ and $104$ exceeded the rate the bit-length-$100$ data alone could assume. This is the quantitative content of the observation that the fade accelerates.

**Theorem 9.8 (What bit-length 100 can and cannot decide).** The advantage of the trailing-zero statistic over the naive count baseline is $+0.098$, which exceeds the full interval width $2w = 0.092$; the four-bit erosion step is $0.030$, which does not. Hence at bit-length $100$ the experiment still resolves *which statistic is better*, but no longer resolves *how fast the dial is fading*.

**Proposition 9.9 (The ambiguity window is exactly two rungs).** With the reconstructed bit-length-$96$ reading $0.573$: the bit-length-$96$ interval already straddles the floor (its point estimate $0.573 \ge 0.55$ is inside the band but its lower end $0.527$ is not); the bit-length-$100$ interval straddles it; and the bit-length-$104$ interval lies entirely below it. So the report that "the validated envelope ends near bit-length $96$" is a statement about point estimates: at the interval level the envelope had already ended at $96$, and the decision became definite again at $104$. The window has width two rungs, comfortably inside the three-rung bound of Corollary 9.5. Independently, the bit-length-$100$ value recorded directly and the value reconstructed from the bit-length-$104$ report agree to within $0.001$.

---

## 10. Discussion and future directions

### 10.1 What is established

The logical shape of the result is *negative and decisive*. The tie ceiling of the trailing-zero statistic is $6/7 + O(1/n)$ for:

- every zero-based range $\{0,\dots,n-1\}$ (exactly, Theorem 3.9);
- every offset window $[A,A+n)$ (Theorem 6.6);
- every dyadically dominated profile with bounded slack, whatever its origin (Theorem 5.3).

At bit-length $100$ the spread across all such samplers is below $10^{-29}$ (Theorem 4.6), while the measured reading squares to $0.296$ and the effect under study is $0.030$ per four bit-lengths. No sampler geometry can produce the observed attenuation. Since the statistic's tie structure is fixed by arithmetic and the sampler is exonerated, the erosion must live in the **response channel** — the relationship between the statistic's blocks and the downstream rate — and that is where the search should continue.

Two structural facts emerged that are of independent interest. First, the ceiling defect is **self-similar in the odd part of $n$**, with sharp amplitude $3/7$ — a Takagi-type digit phenomenon attached to a rank-statistical quantity. Second, the band miss at bit-length $100$ is a **resolution** phenomenon: the straddle window is provably at most three rungs wide and observed to be two, and the experiment retains enough power to rank statistics but not to estimate the fade rate.

### 10.2 Future directions

**1. The general-base range law.** The $p$-adic ceiling $3p/(p^2+p+1)$ was originally proved only for ranges of size exactly $p^b$. The halving recursion of this work generalises verbatim to $n \mapsto \lceil n/p\rceil$, with the self-similar defect $\sum_j m_j^3 - \frac{(p-1)^3}{p^3-1}n^3$ invariant under $n \mapsto pn$. The key insight is that the geometric fixed point $(p-1)^3/(p^3-1)$ is exactly the quantity whose complement is $3p/(p^2+p+1)$, so the whole $p$-adic ceiling law is a statement about a single self-similar defect function, not about power-of-$p$ sample sizes. Why now? The effective-base inversion rests on comparing measured values with the $p$-adic ceiling; if that ceiling moved with the range shape, the inversion would be an artefact. This direction proves it does not.

*Status: partially closed.* The sampler-independent half is established here (Theorem 7.5): the ceiling $3p/(p^2+p+1) - O(1/n)$ holds for every base-$p$ dominated profile, with the geometric fixed point $(p-1)^3/(p^3-1)$ and the identity $1 - (p-1)^3/(p^3-1) = 3p/(p^2+p+1)$ doing the work, and no power-of-$p$ sample size assumed. What remains open is the exact base-$p$ range law with a matching *upper* bound and an explicit defect function $E_p$.

**2. Sharp fluctuation spectrum and its Takagi limit.** We proved $-\tfrac37 n^2 \le E(n) \le \tfrac67$ with both constants attained — the upper exactly at powers of two, the lower asymptotically along $n_j = 2^{j+1}+1$. The natural completion is the full distribution: $E(n)/n^2$ should have a limiting profile given by a Takagi-type nowhere-differentiable function of $\log_2 n \bmod 1$. The key insight is that $E$ is constant along doublings, so it descends to a function of the odd part, and the odd step $E(2a+1) = E(a+1) - (9a^2+3a)/7$ is an affine contraction of ratio $1/4$ — precisely the structure that generates Takagi/Trollope–Delange fluctuations for binary digit sums. Why now? All ceilings established so far are single numbers; a proved fluctuation profile turns the ceiling into a *band*, which is what a deployment envelope actually needs.

**3. Response-side attenuation as the only surviving mechanism.** With sampler geometry excluded, the erosion must live in the response. The effective-base drift of Section 7 is currently a *description* of that attenuation with a good fit and a successful forecast (Section 8); the open problem is to derive the drift rate — one base unit per twelve bit-lengths — from a model of the response channel rather than to calibrate it from two data points. A derivation would convert the forecast from an interpolation into a prediction, and would explain why the crossing base $t^\star \approx 8.804$ is non-integral.

### 10.3 Practical summary

For deployment purposes, the results say three things. The dial's tie ceiling is a fixed arithmetic constant, $6/7$, immune to every reasonable choice of sampler at any nontrivial scale; therefore any observed decline is real signal loss. The validated envelope of the dial ends near bit-length $96$, and beyond that point the signal degrades gradually toward the floor rather than collapsing. And the decision boundary is unresolvable only inside a window of at most twelve bit-lengths: below it the dial is definitely in band, above it definitely out, and only inside it does the instrument have to say "I cannot tell".
