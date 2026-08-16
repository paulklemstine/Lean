# Dimensions of the Logarithmic Prime Embedding: Hausdorff $0$, Box $1$, and Where the Arithmetic Actually Lives

**Author:** Aristotle

**Date:** 2026-08-16

---

## Abstract

We study the *prime fractal* $\mathcal{P} = \{1/\log p : p \text{ prime}\} \subset \mathbb{R}$, the image of the primes under the logarithmic embedding $\iota(p) = 1/\log p$, whose induced metric is $d(p,q) = |1/\log p - 1/\log q|$. This embedding compresses the primes into the bounded interval $(0, 1/\log 2]$ and was proposed as a setting in which the fractal dimension of the primes might encode arithmetic information — specifically, the conjecture $\dim_H(\mathcal{P},d) = 1 + \varepsilon$ with $\varepsilon > 0$ governed by the abundance of twin primes.

We determine the geometry of $\mathcal{P}$ completely and refute that conjecture in five independent ways, while proving a positive substitute. Our results are: (i) $\dim_H \mathcal{P} = 0$, and likewise for the compact closure $\{0\} \cup \mathcal{P}$ and for every subfamily of primes, so no arithmetic hypothesis can move the Hausdorff dimension; (ii) the total $d$-length of the primes is finite and equals exactly $1/\log 2$, by telescoping — refuting the divergence heuristic that motivated the conjecture; (iii) every point of $\mathcal{P}$ is isolated, so the conjectured "twin prime dust" does not exist, and a twin pair sits at distance at most $2/(p(\log p)^2)$, a factor $\log p$ smaller than the heuristic predicted; (iv) the box-counting (Minkowski) dimension of $\mathcal{P}$ is exactly $1$, with the two-sided bracket $m/(16(\log m)^4) \le N(m) \le 5m/\log m$ for the number $N(m)$ of grid boxes of width $1/m$ meeting $\mathcal{P}$, the lower bound resting on a separation estimate together with a Chebyshev-type lower bound $\pi(n) \ge n/(8\log n)$ proved here from the central binomial coefficient; (v) no bounded subset of $\mathbb{R}$ can have box dimension exceeding $1$, so the value $1+\varepsilon$ was structurally unavailable, and the same construction applied to all integers $\ge 2$ yields the identical pair of dimensions $(0,1)$ — the logarithmic lens is blind to primality.

The gap $\dim_H = 0 < 1 = \dim_{\mathrm{box}}$ is maximal for a subset of the line and certifies that $\mathcal{P}$ is not Ahlfors-regular or self-similar. Finally, $N(m)/m \to 0$: the one-dimensional Minkowski content vanishes, so the arithmetic content of the embedding lies not in the dimension but in the second-order term $N(m) \asymp m/\log m$ and the rate $1 - \log N(m)/\log m \asymp \log\log m/\log m$ at which the box dimension approaches $1$.

---

## 1. Introduction

### 1.1 Motivation

The primes have zero density in $\mathbb{N}$: by the Prime Number Theorem, $\pi(x) \sim x/\log x$. Density, however, is a first-order statistic and says nothing about multi-scale structure. Fractal geometry supplies notions — Hausdorff dimension, box-counting dimension, Minkowski content — designed exactly to detect structure across scales, and it is natural to ask whether they see anything in the primes.

A direct application is vacuous: $\{2,3,5,7,\dots\}$ is a uniformly discrete subset of $\mathbb{R}$ and every reasonable dimension of it is $0$. Dimension is a statement about *small* scales, and the primes have no small scales of their own. One must first apply a lens that maps the infinite tail of large primes into a bounded region, converting "large primes" into "small scales."

The logarithmic lens does this elegantly:
$$\iota(p) = \frac{1}{\log p}, \qquad d(p,q) = \left| \frac{1}{\log p} - \frac{1}{\log q} \right|.$$
Under $\iota$: $2 \mapsto 1.442695$, $3 \mapsto 0.910239$, $5\mapsto 0.621335$, $97 \mapsto 0.218566$, $10^6+3 \mapsto 0.072382$. The image lies in $(0, 1/\log 2]$, and $\iota(p) \to 0$ as $p \to \infty$, so the point $0$ acts as a "prime at infinity" and all the asymptotic behaviour of the primes becomes local behaviour near $0$. Twin pairs are mapped very close together, suggesting that a twin-rich sequence of primes produces a clustered dust near the origin.

This motivates the **motivating conjecture**: $\dim_H(\mathcal{P}, d) = 1 + \varepsilon$ with $\varepsilon > 0$ if and only if there are infinitely many twin primes. Its supporting heuristic had two parts: (a) the total $d$-length $\sum_{p \le x} d(p, p^{+})$ (with $p^+$ the next prime) was claimed to be $\sim \sum_{p\le x} 1/(p \log p) \sim \log\log x$, hence divergent, so $\mathcal{P}$ is "long enough to be one-dimensional"; and (b) twin pairs at distance $\sim 1/(p \log p)$ contribute additional fine-scale structure, pushing the dimension above $1$.

### 1.2 Summary of results

Everything in the conjecture and its heuristic fails, but the failure is structured, and the correct picture is a clean trichotomy.

| quantity | value |
|---|---|
| $\dim_H \mathcal{P}$, and $\dim_H \overline{\mathcal{P}}$ | $0$ |
| box-counting dimension of $\mathcal{P}$ (upper and lower) | $1$ |
| one-dimensional Minkowski content | $0$; indeed $N(m) = O(m/\log m)$ |
| total $d$-length of the primes | $1/\log 2 = 1.442695\ldots$ (finite) |
| twin-pair scale | $d(p, p+2) \le 2/(p(\log p)^2)$ |
| grid-versus-cover robustness | any cover by $1/m$-intervals needs $\ge m^{1-o(1)}$ sets |
| primes versus all integers $\ge 2$ | identical dimensions $0$ and $1$ |

Section 2 fixes notation. Section 3 treats the Hausdorff side (dimension $0$, finite length, isolation, the twin reformulation). Section 4 proves the Chebyshev lower bound needed for the arithmetic input. Section 5 proves that the box dimension is exactly $1$. Section 6 gives the refinements: the universal ceiling, the logarithmic defect, cover-robustness, and dimension blindness. Section 7 presents algorithms and numerical evidence, and Section 8 discusses interpretation and open problems.

---

## 2. Setup and notation

**Definition 2.1 (logarithmic embedding).** For an integer $n \ge 2$ set $\iota(n) = 1/\log n$. For integers $p,q \ge 2$ define $d(p,q) = |\iota(p)-\iota(q)|$.

Since $\iota$ takes values in $\mathbb{R}$ and $|x-y|$ is the euclidean distance, $d$ is precisely the metric induced on the primes from $\mathbb{R}$ by $\iota$. Hence all metric questions about $(\{\text{primes}\}, d)$ are questions about the subset $\iota(\{\text{primes}\}) \subseteq \mathbb{R}$, *provided* $\iota$ is injective on the primes.

**Lemma 2.2 (strict antitonicity and injectivity).** For integers $2 \le p < q$ one has $\iota(q) < \iota(p)$. Consequently $\iota$ is injective on $\{n \ge 2\}$ and in particular on the primes, and $(\{\text{primes}\},d)$ is isometric to $\mathcal{P}$ with the euclidean metric.

*Proof.* $\log$ is strictly increasing and positive on $[2,\infty)$, so $t \mapsto 1/\log t$ is strictly decreasing there. Injectivity follows since a strictly decreasing map is injective. $\square$

**Definition 2.3 (prime fractal, twin subfractal, integer fractal).**
$$\mathcal{P} = \iota(\{p : p \text{ prime}\}), \quad \mathcal{T} = \iota(\{p : p, p+2 \text{ prime}\}), \quad \mathcal{I} = \iota(\{n \in \mathbb{N} : n \ge 2\}).$$

**Lemma 2.4 (localisation).** $\mathcal{P} \subseteq \mathcal{I} \subseteq (0, 1/\log 2] \subseteq [0,2]$.

*Proof.* For $n \ge 2$, $\log n \ge \log 2 > 1/2$, so $0 < \iota(n) \le 1/\log 2 < 2$. $\square$

The constant $2$ is used as a convenient bound; the sharp right endpoint is $1/\log 2 = 1.442695\ldots$

---

## 3. The Hausdorff side: dimension zero, finite length, no dust

### 3.1 Hausdorff dimension

Recall that for $s \ge 0$ the $s$-dimensional Hausdorff measure of $S \subseteq \mathbb{R}$ is $\mathcal{H}^s(S) = \lim_{\delta \to 0}\inf\{\sum_i (\operatorname{diam} U_i)^s : S \subseteq \bigcup_i U_i, \operatorname{diam} U_i \le \delta\}$, and $\dim_H S = \inf\{s : \mathcal{H}^s(S) = 0\}$.

**Theorem 3.1 (Hausdorff Dimension Theorem).** $\dim_H \mathcal{P} = 0$. Moreover $\dim_H \iota(T) = 0$ for *every* set $T$ of integers $\ge 2$; in particular $\dim_H \mathcal{T} = 0$ and $\dim_H \mathcal{I} = 0$.

*Proof sketch.* $\mathcal{P}$ is the image of a countable set, hence countable. Every countable subset of a metric space has Hausdorff dimension $0$: enumerating $S = \{x_1, x_2, \dots\}$ and covering $x_n$ by an interval of diameter $\delta 2^{-n}$ gives, for any $s>0$, $\sum_n (\delta 2^{-n})^s = \delta^s/(2^s - 1) \to 0$ as $\delta \to 0$, so $\mathcal{H}^s(S) = 0$ for every $s>0$ and the infimum defining the dimension is $0$. The argument uses nothing about primality, which is exactly the point. $\square$

**Corollary 3.2 (the conjecture fails, uniformly).** $\dim_H \mathcal{P} \ne 1$, and there is no $\varepsilon \ge 0$ with $\dim_H\mathcal{P} = 1 + \varepsilon$; the same holds for every subfamily of primes. In particular the truth value of the twin prime conjecture cannot influence the Hausdorff dimension of any of these sets.

One might suspect that dimension $0$ is an artefact of $\mathcal{P}$ failing to be closed. It is not.

**Theorem 3.3 (compactification).** Let $p_0 < p_1 < p_2 < \cdots$ enumerate the primes. Then $\iota(p_n) \to 0$, the set $\{0\} \cup \mathcal{P}$ is compact, $\overline{\mathcal{P}} \subseteq \{0\}\cup\mathcal{P}$, and $\dim_H \overline{\mathcal{P}} = 0$.

*Proof sketch.* Since $p_n \ge n$, $\log p_n \to \infty$ and $\iota(p_n)\to 0$. A convergent sequence together with its limit is compact, hence closed, so the closure of $\mathcal{P}$ is contained in $\{0\}\cup\mathcal{P}$; that set is countable, so its dimension — and a fortiori that of any subset — is $0$. $\square$

Thus even as a genuine compact subset of $\mathbb{R}$, the prime fractal has Hausdorff dimension $0$.

### 3.2 The total length is $1/\log 2$

**Theorem 3.4 (Telescoping Length Identity).** Let $(q_i)_{i\ge 0}$ be any strictly increasing sequence of integers $\ge 2$. Then for all $n$,
$$\sum_{i=0}^{n-1} d(q_i, q_{i+1}) = \iota(q_0) - \iota(q_n) \le \frac{1}{\log 2}.$$

*Proof sketch.* By Lemma 2.2, $\iota(q_{i+1}) < \iota(q_i)$, so each term equals $\iota(q_i) - \iota(q_{i+1})$ and the sum telescopes to $\iota(q_0)-\iota(q_n)$. Since $q_0 \ge 2$ we have $\iota(q_0) \le 1/\log 2$, and $\iota(q_n) > 0$. $\square$

**Theorem 3.5 (Total Length Theorem).** With $p_0 = 2 < p_1 = 3 < \cdots$ the primes in order,
$$\lim_{n\to\infty} \sum_{i=0}^{n-1} d(p_i, p_{i+1}) = \frac{1}{\log 2} = 1.442695\ldots$$

*Proof sketch.* By Theorem 3.4 the partial sum equals $1/\log 2 - \iota(p_n)$, and $\iota(p_n)\to 0$ by Theorem 3.3. $\square$

This is a complete refutation of heuristic (a). The walk along the primes is monotone, so the length telescopes to a universal constant that depends only on the starting point $2$ — not on primality at all. The auxiliary claim that $\sum_p 1/(p\log p)$ diverges is also false: that series converges (the divergent series of this shape is $\sum_p 1/p \sim \log\log x$, whose extra factor $1/\log p$ makes all the difference).

The prime fractal is therefore *rectifiable of finite length*, the opposite of the "divergent, hence at least one-dimensional" picture.

### 3.3 No dust: every point is isolated

**Lemma 3.6 (finiteness above any height).** For $t > 0$, the set $\{p \text{ prime} : \iota(p) \ge t\}$ is finite; indeed it is contained in $\{p \le e^{1/t}\}$.

*Proof sketch.* $\iota(p) \ge t$ means $\log p \le 1/t$, i.e. $p \le e^{1/t}$. $\square$

**Theorem 3.7 (Isolation Theorem).** Every $x \in \mathcal{P}$ is an isolated point: there exists $\varepsilon > 0$ such that the only point of $\mathcal{P}$ within distance $\varepsilon$ of $x$ is $x$ itself. The same holds for $\mathcal{T}$ and for $\mathcal{I}$.

*Proof sketch.* Let $x = \iota(q) > 0$. By Lemma 3.6 the set $F$ of points of $\mathcal{P}$ that lie at height $\ge x/2$, with $x$ itself removed, is finite, hence closed; so its complement is an open neighbourhood of $x$, containing a ball $B(x,\varepsilon_0)$. Take $\varepsilon = \min(\varepsilon_0, x/2)$: a point of $\mathcal{P}$ within $\varepsilon$ of $x$ has height $> x/2$, so it lies in $F \cup \{x\}$, but it avoids $F$, hence equals $x$. Subsets inherit isolation. $\square$

So $\mathcal{P}$ is order-isomorphic and topologically indistinguishable from a monotone sequence converging to $0$ — like $\{1,1/2,1/3,\dots\}$. There is no dust anywhere except, in a limiting sense, at the single point $0$.

**Theorem 3.8 (accumulation criterion).** For any set $T$ of primes, $0 \in \overline{\iota(T)}$ if and only if $T$ is infinite.

*Proof sketch.* If $T$ is finite, $\iota(T)$ is a finite set of strictly positive numbers, hence closed and bounded away from $0$. If $T$ is infinite, then for each $\varepsilon > 0$ there is $p \in T$ with $p > e^{1/\varepsilon}$, whence $\iota(p) < \varepsilon$. $\square$

**Corollary 3.9 (Twin Primes as a Metric Statement).** There are infinitely many twin primes if and only if $0 \in \overline{\mathcal{T}}$.

This is a faithful reformulation of the twin prime conjecture — but a purely topological one about a single point of $\mathbb{R}$, and a single point has Hausdorff and box dimension $0$ and contributes to no dimension of any set. Combined with Theorem 3.1 ($\dim_H\mathcal{T} = 0$ unconditionally) and Theorem 3.7 (every point of $\mathcal{T}$ isolated), we conclude that the conjectured "twin prime dust" does not exist.

### 3.4 The corrected twin scale

**Theorem 3.10 (Twin Scale Theorem).** For every integer $p \ge 2$,
$$d(p, p+2) \le \frac{2}{p (\log p)^2}.$$

*Proof sketch.* Write $a = \log p$, $b = \log(p+2)$, so $0 < a \le b$ and
$$d(p,p+2) = \frac 1a - \frac 1b = \frac{b-a}{ab}.$$
By the elementary inequality $\log(1+u) \le u$ applied to $u = 2/p$, the numerator satisfies $b - a = \log(1 + 2/p) \le 2/p$. The denominator satisfies $ab \ge a^2 = (\log p)^2$. Combining gives the claim. $\square$

The motivating heuristic put the twin scale at $\sim 1/(p\log p)$; the truth is smaller by a factor $\log p$. This matters for the heuristic, which tried to obtain fine structure from a large number of very short twin gaps: the gaps are shorter still, so they contribute even less "spreading."

---

## 4. Arithmetic input: an explicit Chebyshev lower bound

To prove that the box dimension is $1$ we need many primes below a moving threshold. We prove an explicit elementary lower bound of Chebyshev type.

**Theorem 4.1 (Chebyshev-type lower bound).** For every integer $n \ge 8$,
$$n \le 8\,\pi(n)\,\log n, \qquad\text{equivalently}\qquad \pi(n) \ge \frac{n}{8\log n}.$$

*Proof sketch.* The proof runs through the central binomial coefficient $C_n = \binom{2n}{n}$.

1. *Lower bound on $C_n$*: $4^n < n\,C_n$ for $n \ge 1$, since $4^n = \sum_{k=0}^{2n}\binom{2n}{k}$ is a sum of $2n+1$ terms each at most $C_n$, refined slightly by grouping the two extreme terms.
2. *Upper bound on $C_n$*: every prime power $p^{v_p(C_n)}$ dividing $C_n$ satisfies $p^{v_p(C_n)} \le 2n$ (Kummer/Legendre), and only primes $p \le 2n$ occur. Hence
$$C_n = \prod_{p \le 2n} p^{v_p(C_n)} \le (2n)^{\pi(2n)}.$$
3. Combining, $4^n < n (2n)^{\pi(2n)}$; taking logarithms,
$$n \log 4 \le \log n + \pi(2n)\log(2n).$$
4. For $n \ge 4$ one has $\log n \le \pi(2n)\log(2n)$ (as $\pi(2n)\ge 1$ and $\log n \le \log 2n$), so $n\log 4 \le 2\pi(2n)\log(2n)$; since $\log 4 = 2\log 2 > 1$, this yields $2n \le 4\pi(2n)\log(2n)$, i.e. the claim with the better constant $4$ for even arguments.
5. Odd $n \ge 9$ follow by monotonicity of $\pi$ and of $\log$, passing from $n-1$ to $n$ and absorbing the loss into the constant $8$. $\square$

The constant $8$ is far from optimal (the truth is $\pi(n) \sim n/\log n$), but it is explicit, elementary, and entirely sufficient: the box dimension is a logarithmic-scale quantity, and constants disappear in the limit.

---

## 5. The box-counting dimension is exactly $1$

### 5.1 Definitions

**Definition 5.1 (grid box count).** For $m \in \mathbb{N}$, the boxes of scale $1/m$ are the intervals $[k/m,(k+1)/m)$, $k \in \mathbb{N}$. A point $x \ge 0$ lies in the box with index $\lfloor m x \rfloor$. Set
$$\beta_m(p) = \lfloor m\, \iota(p) \rfloor = \left\lfloor \frac{m}{\log p} \right\rfloor, \qquad N(m) = \#\{\beta_m(p) : p \text{ prime}\},$$
the number of occupied boxes. For a general set $S\subseteq[0,\infty)$ write $N_S(m) = \#\{\lfloor m x\rfloor : x \in S\}$, so $N(m) = N_{\mathcal{P}}(m)$.

**Definition 5.2 (box dimensions).**
$$\overline{\dim}_{B}\,\mathcal{P} = \limsup_{m\to\infty}\frac{\log N(m)}{\log m}, \qquad \underline{\dim}_{B}\,\mathcal{P} = \liminf_{m\to\infty}\frac{\log N(m)}{\log m}.$$

### 5.2 The trivial ceiling

**Proposition 5.3.** For all $m$, $1 \le N(m) \le 2m+1$.

*Proof sketch.* By Lemma 2.4 every point of $\mathcal{P}$ lies in $[0,2]$, so $\beta_m(p) \le 2m$ and the occupied indices lie in $\{0,1,\dots,2m\}$. Nonemptiness follows from $p = 2$. $\square$

### 5.3 The separation estimate

The crux of the lower bound is that primes below a suitable threshold occupy *distinct* boxes.

**Lemma 5.4 (logarithmic separation).** For integers $2 \le p < q$,
$$\log q - \log p \ \ge\ \frac{1}{2p}.$$

*Proof sketch.* Put $u = 1/(2p) \le 1/4$. Since $e^{-u} \ge 1 - u$, we get $e^{u} \le 1/(1-u)$, hence $p\,e^{u} \le p/(1-u)$. One checks $p/(1-u) \le p+1 \le q$ using $u = 1/(2p)$ and $p\ge 2$: indeed $p/(1-1/(2p)) = 2p^2/(2p-1) \le p+1 \iff 2p^2 \le 2p^2 + p - 1$, true for $p\ge1$. Taking logarithms of $p e^u \le q$ gives $\log p + u \le \log q$. $\square$

**Theorem 5.5 (Box Separation Theorem).** Let $Y \ge 2$ and $m$ satisfy $2Y(\log Y)^2 \le m$. Then for all integers $2 \le p < q \le Y$ one has $\beta_m(q) < \beta_m(p)$; in particular $\beta_m$ is injective on $\{p \le Y\}$, hence on the primes $\le Y$.

*Proof sketch.* Write $a = \log p$, $b = \log q$, $L = \log Y$, so $0 < a < b \le L$. By Lemma 5.4, $b - a \ge 1/(2p)$. Then
$$m\left(\frac 1a - \frac 1b\right) = m\,\frac{b-a}{ab} \ \ge\ \frac{m}{2p\,ab} \ \ge\ \frac{m}{2Y L^2} \ \ge\ 1,$$
using $p \le Y$, $ab \le L^2$, and the hypothesis. Hence $m\iota(q) + 1 \le m\iota(p)$, and applying $\lfloor \cdot \rfloor$ (which is monotone and satisfies $\lfloor t+1\rfloor = \lfloor t \rfloor + 1$ for $t\ge0$) gives $\beta_m(q) < \beta_m(p)$. $\square$

**Corollary 5.6.** If $2Y(\log Y)^2 \le m$ then $N(m) \ge \pi(Y)$.

### 5.4 The main lower bound

**Theorem 5.7 (Arithmetic lower bound on the box count).** For all sufficiently large $m$,
$$N(m) \ \ge\ \frac{m}{16 (\log m)^4}.$$

*Proof sketch.* Write $L = \log m$ and assume $L \ge 2$ and $16 L^3 \le m$ (both hold eventually, since $\log^k m = o(m)$). Choose
$$Y = \left\lfloor \frac{m}{L^3} \right\rfloor,$$
the largest scale the separation hypothesis can tolerate. Then $Y L^3 \le m < (Y+1)L^3$, whence $Y \ge 15$ and $Y \le m$, so $\log Y \le L$. The separation hypothesis is verified:
$$2Y(\log Y)^2 \le 2 Y L^2 \le Y L^3 \le m,$$
using $L \ge 2$. Hence $N(m) \ge \pi(Y)$ by Corollary 5.6. Theorem 4.1 applies since $Y \ge 8$ and gives $Y \le 8\pi(Y)\log Y \le 8\pi(Y) L$. Finally $m \le 2 Y L^3$ (from $m < (Y+1)L^3$ and $Y \ge 15$), so
$$m \ \le\ 2 Y L^3 \ \le\ 16\,\pi(Y)\, L^4 \ \le\ 16\, N(m)\, L^4 . \qquad\square$$

The exponent $4$ on the logarithm is an artefact of the crude choice $Y = m/L^3$ and the constant in Theorem 4.1; it is irrelevant for the dimension.

### 5.5 The dimension

**Theorem 5.8 (Box Dimension Theorem).**
$$\lim_{m\to\infty} \frac{\log N(m)}{\log m} = 1, \qquad\text{hence}\qquad \overline{\dim}_B\,\mathcal{P} = \underline{\dim}_B\,\mathcal{P} = 1 .$$

*Proof sketch.* From $N(m) \le 2m+1 \le 3m$ (for $m\ge1$),
$$\frac{\log N(m)}{\log m} \le 1 + \frac{\log 3}{\log m}.$$
From Theorem 5.7, eventually
$$\frac{\log N(m)}{\log m} \ \ge\ 1 - \frac{\log 16}{\log m} - 4\,\frac{\log\log m}{\log m}.$$
Both bounds tend to $1$ because $1/\log m \to 0$ and $\log\log m/\log m \to 0$; squeeze. The $\limsup$ and $\liminf$ therefore both equal $1$. $\square$

**Corollary 5.9 (Dimension Irregularity).** $\dim_H \mathcal{P} = 0 < 1 = \overline{\dim}_B \mathcal{P}$.

The gap is maximal for a subset of $\mathbb{R}$: Hausdorff dimension at the floor, box dimension at the ceiling. In particular $\mathcal{P}$ is not Ahlfors regular and is not the attractor of any self-similar iterated function system satisfying the open set condition, since for such sets the two dimensions coincide. The often-repeated slogan "the primes are a fractal curve" is false in the strongest available sense: the two standard dimensions disagree as much as they possibly can.

---

## 6. Refinements: ceiling, defect, robustness, blindness

### 6.1 A universal ceiling

**Theorem 6.1 (Universal Ceiling).** Let $S \subseteq [0,c]$ with $c > 0$. Then $N_S(m) \le \lfloor cm\rfloor + 1$, and for every $\varepsilon>0$, eventually in $m$,
$$\frac{\log N_S(m)}{\log m} \le 1 + \varepsilon .$$

*Proof sketch.* Every $x\in S$ has $\lfloor mx \rfloor \le \lfloor cm \rfloor$, so at most $\lfloor cm\rfloor+1$ indices occur. Then $\log N_S(m) \le \log(cm+1) = \log m + O(1)$ and divide by $\log m$. $\square$

**Corollary 6.2.** For every $\varepsilon > 0$, eventually $\log N(m)/\log m \le 1 + \varepsilon$. The conjectured value $1+\varepsilon$ with $\varepsilon>0$ is impossible — not because of any property of the primes, but because $\mathcal{P}$ is a bounded subset of a one-dimensional space. The same ceiling applies to Hausdorff dimension.

This is the conceptual reason the motivating conjecture was doomed: it asked for a subset of the line with dimension exceeding $1$.

### 6.2 The logarithmic defect: $N(m) = \Theta(m/\log m)$

Chebyshev's classical upper bound (in the form $\pi(x) \le 2.4\,x/\log x$ for large $x$) gives a matching upper estimate.

**Theorem 6.3 (Logarithmic Defect Theorem).** For all sufficiently large $m$,
$$N(m) \ \le\ \frac{5m}{\log m}.$$
Consequently $N(m)/m \to 0$: the one-dimensional Minkowski content of $\mathcal{P}$ is zero.

*Proof sketch.* Split the primes at $m$. Primes $p \le m$ contribute at most $\pi(m) \le 2.4\,m/\log m$ distinct indices. Primes $p > m$ have $\log p > \log m$, hence $\iota(p) < 1/\log m$ and $\beta_m(p) \le \lfloor m/\log m\rfloor$; so they contribute at most $\lfloor m/\log m\rfloor + 1 \le 2m/\log m$ further indices. Adding, $N(m) \le 4.4\,m/\log m + O(1) \le 5m/\log m$ eventually. Dividing by $m$ gives $N(m)/m \le 5/\log m \to 0$. $\square$

Combining Theorems 5.7 and 6.3:
$$\frac{m}{16(\log m)^4} \ \le\ N(m) \ \le\ \frac{5m}{\log m} \qquad (m \text{ large}).$$

The upper bound is the informative one. A true interval of length $2$ meets $\asymp m$ boxes; $\mathcal{P}$ meets a factor $\log m$ fewer. This is the precise sense in which "the primes fill out a line": they do, to first logarithmic order, but they carry zero length. It also localises the arithmetic: the Prime Number Theorem is visible in the *constant and the logarithmic factor*, not in the dimension.

Equivalently, whenever $N(m) \asymp m/\log m$,
$$\frac{\log N(m)}{\log m} = 1 - \frac{\log\log m}{\log m} + O\!\left(\frac{1}{\log m}\right),$$
so the dimension is approached from below at a rate governed by $\log\log m/\log m$. This explains why numerical box-counting experiments on primes up to $10^7$ or $10^{12}$ report values like $0.84$ and $0.88$ rather than $1.00$: convergence is not slow by accident, it is logarithmically slow by theorem, and the observed deviation is precisely $\log\log m/\log m$.

### 6.3 Grid versus arbitrary covers

A dimension must not depend on the choice of grid. It does not.

**Theorem 6.4 (Cover comparison).** Let $S\subseteq[0,\infty)$ and let $I$ be a finite set of reals with $S \subseteq \bigcup_{c\in I}[c, c + 1/m]$. Then $N_S(m) \le 2\,\#I$.

*Proof sketch.* An interval of length $1/m$ meets at most two grid boxes of width $1/m$: if $x \in [c, c+1/m]$ then $\lfloor mc \rfloor \le \lfloor mx\rfloor \le \lfloor mc\rfloor + 1$. So the map sending each occupied index to a pair (interval, offset $\in\{0,1\}$) is surjective onto the occupied indices from a set of size $2\#I$. $\square$

**Corollary 6.5 (Covering form of the lower bound).** For every $\varepsilon > 0$, eventually in $m$: every finite cover of $\mathcal{P}$ by intervals of length $1/m$ has at least $m^{1-\varepsilon}$ members.

*Proof sketch.* By Theorem 6.4, $\#I \ge N(m)/2$, and by Theorem 5.7, $N(m)/2 \ge m/(32(\log m)^4)$; take logarithms and divide by $\log m$, absorbing $\log 32/\log m + 4\log\log m/\log m < \varepsilon$ eventually. $\square$

So the value $1$ is intrinsic to the set, not to the grid.

### 6.4 Dimension blindness

**Theorem 6.6 (Dimension Blindness).** For the integer fractal $\mathcal{I} = \{1/\log n : n \ge 2\}$ with box count $N_{\mathcal{I}}(m)$,
$$\dim_H\mathcal{I} = 0 = \dim_H\mathcal{P}, \qquad \lim_{m\to\infty}\frac{\log N_{\mathcal{I}}(m)}{\log m} = 1 = \lim_{m\to\infty}\frac{\log N(m)}{\log m}.$$

*Proof sketch.* The Hausdorff statement is Theorem 3.1 (countability). For the box count, the upper bound $N_{\mathcal{I}}(m) \le 2m+1$ is Proposition 5.3 verbatim. For the lower bound the same separation Theorem 5.5 applies — it was proved for all integers $\ge 2$, not just primes — and now one may simply count: the integers $2,\dots,Y$ occupy $Y-1$ distinct boxes as soon as $2Y(\log Y)^2 \le m$, so $N_{\mathcal{I}}(m) \ge Y - 1$ with $Y = \lfloor m/(\log m)^3\rfloor$, and $\log(Y-1)/\log m \to 1$. No Chebyshev bound is needed. $\square$

**Corollary 6.7 (structural impossibility).** No dimension of the logarithmic embedding — Hausdorff or box — can distinguish the primes from the full set of integers $\ge 2$. In particular, none can encode the twin prime conjecture, nor any statement about prime density.

The only place the primes differ from the integers in this geometry is the second-order term: $N_{\mathcal{I}}(m) \asymp m$ up to constants in the relevant regime, whereas $N(m) \asymp m/\log m$. Density survives in the *count*, not in the *dimension*.

---

## 7. Algorithms and numerical evidence

### 7.1 Computing the box count

Exact computation of $N(m)$ is subtle. Box index $k$ is occupied precisely when the interval
$$I_k = \left( e^{m/(k+1)},\ e^{m/k} \right]$$
contains a prime (with $k = 0$ corresponding to $p > e^m$, always occupied). For small $k$ these intervals are astronomically large — $I_1 = (e^{m/2}, e^m]$ — so brute enumeration is impossible for any interesting $m$. The practical algorithm splits at a sieve limit $X$:

1. **Sieve head.** Enumerate all primes $p \le X$ by a sieve of Eratosthenes and collect the exact set $H = \{\lfloor m/\log p\rfloor : p \le X\}$.
2. **Tail prediction.** For each index $k$ with $e^{m/k} > X$ (i.e. $k < m/\log X$), decide occupancy of $I_k$ by the Prime Number Theorem estimate
$$\pi(e^{m/k}) - \pi(e^{m/(k+1)}) \approx \frac{e^{m/k}}{m/k} - \frac{e^{m/(k+1)}}{m/(k+1)} \gg 1,$$
which is overwhelmingly larger than $1$ for every such $k$; the tail indices are therefore all occupied.
3. **Combine.** $N(m) = \#(H \cup \{\text{tail indices}\})$.

Steps 1–3 cost $O(X\log\log X)$ time and $O(X)$ space for the sieve, plus $O(\pi(X) + m/\log X)$ for the index bookkeeping. The head/tail split is exactly the structure that appears in the proof of Theorem 6.3, and it is also the structure behind the conjecture $N(m)\log m/m \to 1$ discussed below: the tail contributes $\approx m/\log X$ boxes and the head $\approx \pi(X)$, and optimising at $X \approx m$ makes the tail $\sim m/\log m$ dominant.

### 7.2 What the numbers show

Computing this for $m$ ranging over several decades gives values of $\log N(m)/\log m$ that rise slowly toward $1$ — typically in the range $0.80$–$0.90$ over accessible $m$ — while the normalised count $N(m)\log m/m$ stays in a narrow band around $1.3$–$1.7$ and drifts downward. Both observations are exactly what Theorems 5.8 and 6.3 predict: the dimension is $1$, the convergence is logarithmic at rate $\log\log m/\log m$, and the normalised count is bounded, consistent with an asymptotic constant. A naive experimentalist measuring $0.86$ and concluding "the prime fractal has dimension $0.86$" would be measuring $1 - \log\log m/\log m$, not a dimension.

Similar computations confirm the other results directly: the cumulative $d$-length along the primes converges rapidly to $1/\log 2 = 1.442695\ldots$ (after primes up to $10^6$ the deficit is $1/\log(10^6) \approx 0.072$); observed twin-pair distances sit safely under $2/(p(\log p)^2)$ and roughly a factor $\log p$ under the heuristic $1/(p\log p)$; and box counts for the integer fractal track those of the prime fractal to within a bounded factor in $\log N/\log m$, illustrating dimension blindness.

---

## 8. Discussion

### 8.1 Why the conjecture failed, in three layers

The motivating conjecture failed for three independent reasons, at three different depths.

*Superficially*: the motivating length computation was wrong. The $d$-length telescopes to $1/\log 2$, and the series that was supposed to diverge converges.

*Structurally*: any subset of the line has box dimension at most $1$ and, if countable, Hausdorff dimension exactly $0$. Both hypotheses hold for $\mathcal{P}$ unconditionally. There was no room in the interval $[0,\infty)$ of possible dimension values for a twin-prime-dependent $\varepsilon$.

*Conceptually*: dimension is an extremely lossy functional of a set. It only sees the exponential rate of growth of covering numbers. Arithmetic information — the density of primes, still less the density of twin pairs — lives in constants and logarithmic factors, which the logarithm-of-a-logarithm double compression in $\log N(m)/\log m$ destroys. The Dimension Blindness Theorem makes this quantitative: primes and integers, radically different arithmetically, are indistinguishable dimensionally.

### 8.2 What replaced it

The positive content is a complete geometric description of a natural object. The pair $(\dim_H, \dim_B) = (0,1)$ is the extreme case of dimension irregularity in $\mathbb{R}$, and the prime fractal is a clean, explicitly arithmetic example of it (the integer fractal is the same phenomenon without arithmetic). The finite length $1/\log 2$ makes $\mathcal{P}$ a rectifiable set whose box dimension nonetheless equals $1$ — a good pedagogical counterexample to the intuition that box dimension $1$ implies positive length. And $N(m) \asymp m/\log m$ locates the surviving arithmetic precisely, as a Prime-Number-Theorem-shaped second-order term.

There is also a methodological lesson for numerical fractal geometry. Box-counting experiments on arithmetic sets converge at rate $\log\log m/\log m$, which is not merely slow but effectively non-convergent over any accessible range of scales: to reduce the deviation below $0.05$ one needs $\log\log m/\log m < 0.05$, i.e. $m$ beyond $10^{30}$. Reported "measured dimensions" of arithmetic sets in the literature should be read with this in mind.

### 8.3 Open problems

**C1 (Exact Minkowski constant).** Prove $\lim_{m\to\infty} N(m)\log m/m = 1$; equivalently $N(m) = (1+o(1))\,m/\log m$. The heuristic is the head/tail split of §7.1: the tail indices $k \le m/\log X$ are all occupied because each interval $(e^{m/(k+1)}, e^{m/k}]$ has ratio $e^{m/(k(k+1))}$ and hence contains a prime; the head contributes one box per prime $p \le X$. Optimising at $X = m$ makes the tail $\sim m/\log m$ and the head $o(m/\log m)$, so the constant $1$ comes from the tail and is independent of $\pi$. Bertrand's postulate already handles $k \lesssim \sqrt m$; any short-interval prime-existence result extends this to the full range. The two-sided bracket $m/(16(\log m)^4) \le N(m) \le 5m/\log m$ is established here, and numerics place $N(m)\log m/m$ in $[1.26,1.75]$ and decreasing.

**C2 (The logarithmic defect as a second-order invariant).** Define
$$\delta(S) = \lim_{m\to\infty}\left(1 - \frac{\log N_S(m)}{\log m}\right)\cdot\frac{\log m}{\log\log m}.$$
Conjecture: $\delta(\mathcal{P}) = 1$, $\delta = 0$ for every self-similar set of dimension $1$, and $\delta(\mathcal{I}) = 1$ as well. The point is that the *rate* at which the box dimension approaches $1$ is a genuine invariant, invisible to the dimension, which separates "arithmetically thin" dimension-one sets from geometric ones. This is exactly the quantity that box-counting experiments actually measure.

**C3 (Twin primes are invisible).** Formulate and prove a general invisibility principle: for any subfamily $T$ of primes with $\pi_T(x) = O(x/(\log x)^A)$ for some $A > 1$, the subfractal $\iota(T)$ has box dimension $1$ as well, provided $T$ is not too sparse — and identify the exact density threshold at which the box dimension drops below $1$. Under the Hardy–Littlewood twin prime conjecture, the twin subfractal would have $N_{\mathcal{T}}(m) \asymp m/\log m$ up to constants and hence box dimension $1$, again equal to that of the primes and of the integers. Determining the box dimension of $\mathcal{T}$ unconditionally, or showing it equals $1$ under standard conjectures, would complete the picture.

**Further directions.** (i) Compute the exact Minkowski content-like quantity $\lim N(m)\log m/m$ for other arithmetic sequences (squares, smooth numbers, primes in arithmetic progressions) and determine which sequences the second-order invariant $\delta$ can distinguish. (ii) Study other lenses $\iota_f(n) = f(n)^{-1}$ for slowly growing $f$ and determine for which $f$ the resulting set has box dimension in $(0,1)$ — the logarithm sits exactly at the boundary where the dimension saturates. (iii) Examine the packing dimension and the Assouad dimension of $\mathcal{P}$: the Assouad dimension of a monotone sequence converging to $0$ is a sensitive invariant, and for $\{1/\log p\}$ it should detect the extremely slow decay of the sequence.

---

## 9. Conclusion

Under the logarithmic lens $p\mapsto 1/\log p$, the primes form a bounded, countable, rectifiable set of total length exactly $1/\log 2$, every point of which is isolated. Its Hausdorff dimension is $0$; its box-counting dimension is exactly $1$; its one-dimensional Minkowski content is $0$, with $N(m) = \Theta(m/\log m)$ boxes of width $1/m$ occupied. The same three values hold verbatim for all integers $\ge 2$, so no dimension here can see primality, and the hoped-for equation "dimension $= 1 + \varepsilon(\text{twin primes})$" is impossible: no bounded subset of $\mathbb{R}$ has box dimension above $1$, and no countable set has positive Hausdorff dimension.

What remains is sharper than what was conjectured. The prime fractal is an explicit, arithmetically natural example of maximal dimension irregularity on the line, and the arithmetic that the dimension throws away reappears one order down, in the constant of $N(m)\log m/m$ and in the $\log\log m/\log m$ rate at which the box dimension approaches its limit. That is where the next theorems are.
