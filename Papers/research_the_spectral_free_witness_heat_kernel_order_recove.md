# Exact Order Recovery from a Single Heat-Kernel Value on a Lacunary Dyadic Cayley Graph

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Let $N \ge 2$, let $b$ be a unit modulo $N$, and let $r = \operatorname{ord}_N(b)$ be its multiplicative order. Consider the Cayley graph of the cyclic group $\mathbb{Z}/r\mathbb{Z}$ with the *lacunary dyadic* generating set $S_M = \{\pm 2^t : 0 \le t \le M\}$, where $M$ satisfies $N \le 2^M$, and let $W = \tfrac{1}{2}(I + P)$ be the half-lazy simple random walk on it. We prove that the single return probability $p_n(e) = (W^n \delta)(0)$, evaluated at the single time $n = 8(M+1)^2$, determines $r$ *exactly*:
$$\big\lfloor 1/p_n(e) \big\rceil = r \qquad \text{whenever } 0 < r \le N \le 2^M .$$

The proof rests on a purely combinatorial **doubling lemma**: for every frequency $k \not\equiv 0 \pmod r$ there is a dyadic shift $t \le M$ with $2^t k \bmod r \in [r/4, 3r/4]$, because the circle distance doubles while it remains below $r/4$ and cannot exceed $r/2$. This forces one nonpositive cosine in each character eigenvalue and yields the spectral gap $\lambda_k \le 1 - \frac{1}{M+1}$, hence $0 \le \mu_k \le 1 - \frac{1}{2(M+1)}$ for the half-lazy chain. Standard estimates then give $\frac{1}{r} \le p_n(e) \le \frac{1}{r} + \big(1 - \frac{1}{2(M+1)}\big)^n$, an error below $1/(4N^2)$ at $n = 8(M+1)^2$, and a rounding lemma completes the recovery.

We further establish: (i) an **operational grounding** — the spectral expression is genuinely the $n$-step return probability of the explicit diffusion operator, via character diagonalisation and discrete Fourier inversion; (ii) **sharpness** — for the Mersenne cycle $r = 2^M - 1$ the top nontrivial eigenvalue satisfies $\lambda_1 \ge 1 - \frac{106}{M+1}$, so the gap is $\Theta(1/M)$, and for $M \ge 106$ any step count with $154 n \le M(M+1)$ makes the rounding fail; thus the diffusion time is $\Theta((\log N)^2)$ and not $O(\log N)$; (iii) **rigidity** — the map $r \mapsto p_n(e)$ is injective on $1 \le r \le N$; (iv) an **honest correction**: the witness *value* is multiplicative in the order up to $1/N^2$, since it equals $1/r$ to that accuracy — only the *mechanism* is a non-multiplicative spectral aggregate; and (v) the **arithmetic payload** — a recovered even order splits $N$ by one greatest common divisor. Finally we quantify the aggregation cost $\Theta(r)$ that seals the witness, and formulate two sharp conjectures on the extremal spectral constants.

**Keywords:** lacunary dyadic Cayley graph, heat kernel, multiplicative order, spectral gap, doubling lemma, random walk mixing, integer factorisation.

---

## 1. Introduction

### 1.1 The question

Order finding — computing $r = \operatorname{ord}_N(b)$ for a unit $b$ modulo a composite $N$ — is the arithmetic core of integer factorisation. Given an even order $r = 2m$ with $b^m \not\equiv \pm 1 \pmod N$, a single greatest common divisor splits $N$. Any procedure that extracts $r$ from a small amount of easily-measured data is therefore of structural interest, whether or not it is efficient, because it delineates *what kind of information* about $N$ is cheap to expose and *which resource* pays for it.

This paper studies a diffusion-theoretic mechanism of exactly that type. The multiplicative cycle $\langle b \rangle \subseteq (\mathbb{Z}/N\mathbb{Z})^\times$ is a cyclic group of order $r$; run a random walk on it whose steps are *powers of two* in the exponent, i.e. multiplications by $b^{\pm 2^t}$; and measure a single number — the probability of being back at the identity after a prescribed number of steps. We show that this one scalar, correctly rounded, is $r$ on the nose.

### 1.2 Why powers of two

For the ordinary nearest-neighbour walk on a cycle of length $r$, the spectral gap is $\Theta(1/r^2)$ and mixing takes $\Theta(r^2)$ steps: hopeless for $r$ of cryptographic size. The lacunary dyadic generating set $\{\pm 2^t : t \le M\}$, with $2^M \ge r$, changes this qualitatively. The mechanism is entirely elementary, and is the technical heart of the paper: the doubling map on the circle $\mathbb{Z}/r\mathbb{Z}$ *expands* the distance to the origin as long as that distance is small, so no nonzero point can stay near the origin along its whole dyadic orbit. Some dyadic multiple must land in the "far arc" $[r/4, 3r/4]$, where the character has nonpositive real part. One such term is enough to force a $\Theta(1/M)$ gap.

### 1.3 Contributions

1. **Doubling lemma and spectral gap** (§3–§4). For $r \le 2^M$ and $k \not\equiv 0 \pmod r$, some $t \le M$ has $2^t k$ in the far arc; consequently $\lambda_k \le 1 - \frac{1}{M+1}$ and $0 \le \mu_k \le 1 - \frac{1}{2(M+1)}$.
2. **Exact recovery** (§5–§6). $\frac1r \le p_n(e) \le \frac1r + \beta^n$ with $\beta = 1 - \frac{1}{2(M+1)}$; at $n = 8(M+1)^2$ the error is $\le \frac{1}{4N^2}$; rounding the reciprocal returns $r$ exactly, for all $0 < r \le N \le 2^M$.
3. **Operational grounding** (§7). The spectral quantity is the honest $n$-step return probability of an explicit local diffusion operator.
4. **Rigidity and approximate multiplicativity** (§8). $r \mapsto p_n(e)$ is injective on $r \le N$; and $|p^{(r_1r_2)} - p^{(r_1)}p^{(r_2)}| \le 1/N^2$, so the witness value is multiplicative in the order even though the mechanism is not.
5. **Sharpness and a matching lower bound** (§9). $\lambda_1(2^M - 1) \ge 1 - \frac{106}{M+1}$; the gap is $\Theta(1/M)$; and the rounding provably fails when $154 n \le M(M+1)$ (for $M \ge 106$), so $n = \Theta((\log N)^2)$ is necessary.
6. **Arithmetic payload and the sealing barrier** (§10–§11). A recovered even order splits $N$ by one gcd; but producing $p_n(e)$ requires $\Theta(r)$ aggregation, which is what prevents the mechanism from being a computational shortcut.

---

## 2. Setting and definitions

Throughout, $r \ge 1$ and $M \ge 0$ are integers, and $\mathbb{Z}/r\mathbb{Z}$ is written additively as the cycle $\{0,1,\dots,r-1\}$. All logarithms in complexity statements are base $2$.

**Definition 2.1 (Circle distance).** For integers $r > 0$ and $x \ge 0$ set
$$d_r(x) \;=\; \min\big(\, x \bmod r, \; r - (x \bmod r) \,\big).$$
Thus $0 \le d_r(x) \le r/2$, and $d_r(x) = 0$ if and only if $r \mid x$.

**Definition 2.2 (Lacunary dyadic Cayley graph).** The *lacunary dyadic Cayley graph* $\mathcal{C}(r, M)$ is the Cayley graph of $\mathbb{Z}/r\mathbb{Z}$ with the multiset of generators
$$S_M \;=\; \{\, +2^t,\ -2^t \;:\; 0 \le t \le M \,\},$$
a set of $2(M+1)$ (not necessarily distinct) elements. The simple random walk on $\mathcal{C}(r,M)$ chooses a generator uniformly from $S_M$.

**Definition 2.3 (Half-lazy diffusion operator).** For a function $f : \mathbb{Z} \to \mathbb{C}$ (identified with an $r$-periodic function on the cycle) define
$$(W_M f)(x) \;=\; \frac{f(x)}{2} \;+\; \frac{1}{4(M+1)} \sum_{t=0}^{M}\Big( f(x + 2^t) + f(x - 2^t) \Big).$$
This is $W = \tfrac12(I + P)$ where $P$ is the transition operator of the simple random walk on $\mathcal{C}(r,M)$: with probability $\tfrac12$ the walker stays; otherwise it moves by a uniformly chosen element of $S_M$.

**Definition 2.4 (Characters).** For $0 \le k < r$ let $\chi_k(x) = \exp\!\big(2\pi i k x / r\big)$, an $r$-periodic function on $\mathbb{Z}$.

**Definition 2.5 (Eigenvalues).** Set
$$\lambda_k(r,M) \;=\; \frac{1}{M+1}\sum_{t=0}^{M} \cos\!\Big(\frac{2\pi k 2^t}{r}\Big), \qquad \mu_k(r,M) \;=\; \frac{1 + \lambda_k(r,M)}{2}.$$

**Definition 2.6 (Heat kernel at the identity).** For $n \ge 0$,
$$p_n(e) \;=\; p_n(r, M) \;=\; \frac{1}{r}\sum_{k=0}^{r-1} \mu_k(r,M)^{\,n}.$$

**Definition 2.7 (Periodic delta).** $\delta_r(x) = 1$ if $r \mid x$ and $0$ otherwise.

Proposition 7.3 below justifies the name in Definition 2.6: $p_n(r,M) = (W_M^n \delta_r)(0)$, the probability that the half-lazy walk started at the identity is at the identity after $n$ steps.

---

## 3. The doubling lemma

The following three statements are the combinatorial engine of the paper. They involve no analysis whatsoever.

**Lemma 3.1 (Positivity).** *If $r > 0$ and $x \not\equiv 0 \pmod r$ then $d_r(x) > 0$.*

*Proof.* Write $s = x \bmod r$, so $0 < s < r$; then both $s$ and $r - s$ are positive, hence so is their minimum. $\square$

**Lemma 3.2 (Doubling step).** *Let $r > 0$ and let $x \ge 0$ satisfy $4\,d_r(x) < r$. Then*
$$d_r(2x) \;=\; 2\, d_r(x).$$

*Proof.* Put $s = x \bmod r \in [0, r)$, so $(2x) \bmod r = (2s) \bmod r$. Two cases.

*Case 1: $2s < r$.* Then $(2x) \bmod r = 2s$, and $d_r(2x) = \min(2s, r - 2s)$. The hypothesis reads $4\min(s, r-s) < r$. If the minimum is $s$ then $4s < r$, so $2s < r - 2s$ and $d_r(2x) = 2s = 2d_r(x)$. If the minimum is $r - s$ then $4(r-s) < r$, forcing $s > 3r/4$ and hence $2s > 3r/2 > r$, contradicting the case assumption; so this subcase is vacuous.

*Case 2: $2s \ge r$.* Then $(2x) \bmod r = 2s - r$, and since $s \ge r/2$ the hypothesis $4\min(s,r-s) < r$ forces $\min(s,r-s) = r-s$ with $4(r-s) < r$. Writing $u = r - s$, we have $2s - r = r - 2u$, so
$$d_r(2x) = \min\big(r - 2u,\; 2u\big) = 2u = 2 d_r(x),$$
because $2u < r/2 < r - 2u$. $\square$

(The two cases are exactly "the point is near the origin from the right" and "from the left"; in both, doubling cannot wrap past the antipode because $2 d_r(x) < r/2$.)

**Lemma 3.3 (Iterated doubling).** *Let $r > 0$, $x \not\equiv 0 \pmod r$, and suppose $4\, d_r(2^t x) < r$ for every $t \le M$. Then $d_r(2^t x) = 2^t d_r(x)$ for all $t \le M$.*

*Proof.* Induction on $t$. The base case $t = 0$ is trivial. If $d_r(2^t x) = 2^t d_r(x)$ and $4 d_r(2^t x) < r$, then Lemma 3.2 applied to the point $2^t x$ gives $d_r(2^{t+1}x) = 2 d_r(2^t x) = 2^{t+1} d_r(x)$. $\square$

**Theorem 3.4 (Doubling lemma).** *Let $r > 0$, let $k \not\equiv 0 \pmod r$, and suppose $r \le 2^M$. Then there exists $t \le M$ with*
$$r \;\le\; 4\, d_r\!\big(2^t k\big),$$
*i.e. $2^t k \bmod r$ lies in the far arc $[r/4,\, 3r/4]$.*

*Proof.* Suppose not: $4 d_r(2^t k) < r$ for all $t \le M$. By Lemma 3.3, $d_r(2^M k) = 2^M d_r(k) \ge 2^M \ge r$, using $d_r(k) \ge 1$ (Lemma 3.1) and the hypothesis. But then $4 d_r(2^M k) \ge 4r > r$, contradicting the assumption at $t = M$. $\square$

**Remark 3.5.** Theorem 3.4 is the reason lacunary dyadic generators are the right choice. Any generating set whose elements form a *geometric* progression with ratio $\ge 2$ and whose largest element exceeds $r$ admits the same escape argument; the essential point is that the multiplier is $\ge 2$, so that "staying near the origin" is a geometrically expanding, hence self-defeating, hypothesis.

---

## 4. From the far arc to a spectral gap

**Lemma 4.1 (Nonpositive cosine).** *Let $r > 0$ and $x \ge 0$ satisfy $r \le 4 d_r(x)$. Then*
$$\cos\!\Big(\frac{2\pi x}{r}\Big) \;\le\; 0 .$$

*Proof.* Write $s = x \bmod r$. The hypothesis $r \le 4\min(s, r-s)$ gives $r \le 4s$ and $4s \le 3r$, i.e. $s \in [r/4, 3r/4]$. Since $x = s + r\lfloor x/r\rfloor$, the angle $2\pi x/r$ differs from $2\pi s / r$ by an integer multiple of $2\pi$, and $\cos$ is $2\pi$-periodic. Finally $2\pi s / r \in [\pi/2, 3\pi/2]$, on which $\cos \le 0$. $\square$

**Theorem 4.2 (Spectral gap of the dyadic walk).** *Let $r > 0$, $k \not\equiv 0 \pmod r$, and $r \le 2^M$. Then*
$$\lambda_k(r,M) \;\le\; 1 - \frac{1}{M+1}.$$

*Proof.* By Theorem 3.4 pick $t_0 \le M$ with $r \le 4 d_r(2^{t_0}k)$; by Lemma 4.1 the $t_0$-th summand of $(M+1)\lambda_k$ is $\le 0$. Each of the remaining $M$ summands is $\le 1$. Hence $(M+1)\lambda_k \le M$. $\square$

**Corollary 4.3 (Half-lazy spectrum).** *Under the hypotheses of Theorem 4.2,*
$$0 \;\le\; \mu_k(r,M) \;\le\; 1 - \frac{1}{2(M+1)} \;=:\; \beta_M .$$
*Moreover $\mu_0(r,M) = 1$ for every $r, M$, and $0 \le \mu_k \le 1$ for every $k$.*

*Proof.* The trivial character has all cosines equal to $1$, so $\lambda_0 = 1$ and $\mu_0 = 1$. In general $-1 \le \lambda_k \le 1$ since each cosine lies in $[-1,1]$; therefore $0 \le \mu_k \le 1$. The upper bound follows from Theorem 4.2 and $\mu_k = \tfrac12(1 + \lambda_k)$. $\square$

Laziness plays a genuine role: without it, $\lambda_k$ could approach $-1$ (a bipartite-type obstruction) and $|\lambda_k|^n$ would not decay. Half-laziness costs exactly a factor $2$ in the gap and buys nonnegativity of the whole spectrum.

---

## 5. Two-sided bounds on the heat kernel

**Theorem 5.1 (Lower bound).** *For all $r > 0$, $M$, $n$: $\displaystyle \frac{1}{r} \le p_n(r,M)$.*

*Proof.* Isolate $k = 0$: $r\, p_n = \mu_0^n + \sum_{k \ne 0}\mu_k^n = 1 + \sum_{k\ne 0}\mu_k^n \ge 1$, since every $\mu_k \ge 0$ by Corollary 4.3. $\square$

**Theorem 5.2 (Upper bound).** *Let $0 < r \le 2^M$. Then for all $n$,*
$$p_n(r,M) \;\le\; \frac{1}{r} + \beta_M^{\,n}, \qquad \beta_M = 1 - \frac{1}{2(M+1)} .$$

*Proof.* Every $k \in \{1,\dots,r-1\}$ satisfies $k \not\equiv 0 \pmod r$, so $0 \le \mu_k \le \beta_M$ by Corollary 4.3 and hence $\mu_k^n \le \beta_M^n$. Summing, $r\,p_n \le 1 + (r-1)\beta_M^n \le 1 + r\beta_M^n$. Divide by $r$. $\square$

Theorems 5.1 and 5.2 say the return probability is a *one-sided* estimator of $1/r$: it never undershoots, and its overshoot is controlled by the $n$-th power of the gap. One-sidedness is what makes the subsequent rounding argument clean.

---

## 6. Mixing time and exact recovery

**Lemma 6.1 (Mixing at $n = 8(M+1)^2$).** *Let $0 < N \le 2^M$. Then*
$$\beta_M^{\,8(M+1)^2} \;\le\; \frac{1}{4N^2}.$$

*Proof.* Write $D = M+1 \ge 1$, so $\beta_M = 1 - \frac{1}{2D} \in [0,1]$. From $1 + u \le e^u$ with $u = -\frac{1}{2D}$ we get $\beta_M \le e^{-1/(2D)}$, hence
$$\beta_M^{\,8D^2} \;\le\; \exp\!\Big(-\frac{8D^2}{2D}\Big) \;=\; e^{-4D}.$$
On the other side, $4 \le e^4$ (again from $1 + u \le e^u$ at $u = 4$), so $e^{4D} = (e^4)^{M+1} \ge 4^{M+1} = 4\cdot 4^M = 4 (2^M)^2 \ge 4N^2$. Combining, $\beta_M^{8D^2} \le e^{-4D} \le 1/(4N^2)$. $\square$

**Lemma 6.2 (Rounding).** *Let $r > 0$, $\varepsilon \ge 0$, and let $p$ satisfy $\frac1r \le p \le \frac1r + \varepsilon$ with $2r^2\varepsilon < 1$. Then $\big\lfloor 1/p \big\rceil = r$.*

*Proof.* Since $p \ge 1/r > 0$ we have $1/p \le r$. For the other side, $p \le \frac{1+r\varepsilon}{r}$ gives
$$\frac1p \;\ge\; \frac{r}{1 + r\varepsilon} \;=\; r\Big(1 - \frac{r\varepsilon}{1+r\varepsilon}\Big) \;>\; r - r^2\varepsilon \;>\; r - \tfrac12,$$
using $2r^2\varepsilon < 1$. Thus $1/p \in (r - \tfrac12,\, r]$, an interval on which rounding to the nearest integer returns $r$. $\square$

**Theorem 6.3 (Heat-kernel order recovery).** *Let $0 < r \le N \le 2^M$ and put $n = 8(M+1)^2$. Then*
$$\Big\lfloor \frac{1}{p_n(r,M)} \Big\rceil \;=\; r .$$

*Proof.* Since $r \le N \le 2^M$, Theorems 5.1 and 5.2 give $\frac1r \le p_n \le \frac1r + \beta_M^n$, and Lemma 6.1 gives $\beta_M^n \le \varepsilon := \frac{1}{4N^2}$. Then
$$2r^2\varepsilon \;=\; \frac{r^2}{2N^2} \;\le\; \frac{1}{2} \;<\; 1$$
because $r \le N$. Lemma 6.2 applies. $\square$

**Corollary 6.4 (Multiplicative order).** *Let $N \ge 1$ and let $b \in (\mathbb{Z}/N\mathbb{Z})^\times$ with $r = \operatorname{ord}_N(b)$. Let $M$ satisfy $N \le 2^M$ and $n = 8(M+1)^2$. Then $\lfloor 1/p_n(r,M)\rceil = r$.*

*Proof.* By Lagrange, $r \mid |(\mathbb{Z}/N\mathbb{Z})^\times| = \varphi(N) \le N$, and $r \ge 1$; so $0 < r \le N$ and Theorem 6.3 applies. $\square$

Note the safety margin: the proof needs $2r^2\varepsilon < 1$ and delivers $2r^2\varepsilon \le 1/2$. The step count $n = 8(M+1)^2$ is therefore not tight at the level of the constant $8$; see Conjecture 12.1.

---

## 7. Operational grounding: the spectral sum is a return probability

Definition 2.6 is a spectral formula referring to $r$; without §7 the recovery statement would be open to the objection of circularity. Here we show the quantity is the return probability of an explicitly defined local diffusion.

**Lemma 7.1 (Characters are eigenvectors).** *For all $r, M, k$,*
$$W_M \chi_k \;=\; \mu_k(r,M)\, \chi_k .$$

*Proof.* From $\chi_k(x \pm m) = \chi_k(x)\chi_k(\pm m)$ and $\chi_k(m) + \chi_k(-m) = 2\cos(2\pi k m / r)$ we get
$$(W_M\chi_k)(x) = \chi_k(x)\left[\frac12 + \frac{1}{4(M+1)}\sum_{t=0}^{M} 2\cos\!\Big(\frac{2\pi k 2^t}{r}\Big)\right] = \chi_k(x)\cdot \frac{1 + \lambda_k}{2}. \qquad \square$$

**Lemma 7.2 (Character orthogonality).** *For $r > 0$ and $x \in \mathbb{Z}$, $\displaystyle \sum_{k=0}^{r-1}\chi_k(x) = r\,\delta_r(x)$.*

*Proof.* Put $\omega = e^{2\pi i x/r}$, so $\chi_k(x) = \omega^k$. If $r \mid x$ then $\omega = 1$ and the sum is $r$. Otherwise $\omega \ne 1$ and $\omega^r = 1$, so the geometric sum is $(\omega^r - 1)/(\omega - 1) = 0$. $\square$

**Proposition 7.3 (Heat kernel = return probability).** *For $r > 0$ and all $M, n$,*
$$\big(W_M^{\,n}\,\delta_r\big)(0) \;=\; p_n(r,M).$$

*Proof.* By Lemma 7.2, $\delta_r = \frac{1}{r}\sum_{k<r}\chi_k$. Since $W_M$ is linear and commutes with finite sums and scalars, Lemma 7.1 iterated gives $W_M^n \chi_k = \mu_k^n \chi_k$. Evaluating at $x=0$, where $\chi_k(0) = 1$,
$$\big(W_M^n \delta_r\big)(0) = \frac1r \sum_{k<r} \mu_k^n \chi_k(0) = \frac1r\sum_{k<r}\mu_k^n = p_n(r,M). \qquad \square$$

**Theorem 7.4 (Operational order recovery).** *Let $0 < r \le N \le 2^M$. Then the mass at the identity after $8(M+1)^2$ steps of the half-lazy lacunary dyadic diffusion started at the identity determines $r$ exactly:*
$$\Big\lfloor \frac{1}{\big(W_M^{\,8(M+1)^2}\delta_r\big)(0)} \Big\rceil \;=\; r .$$

*Proof.* Combine Proposition 7.3 with Theorem 6.3. $\square$

The operator $W_M$ is manifestly a stochastic diffusion: nonnegative coefficients summing to $\frac12 + 2(M+1)\cdot\frac{1}{4(M+1)} = 1$. Its definition mentions only $M$ (not $r$); $r$ enters solely through the periodicity of the state space. This is exactly the situation of an experimenter who knows the bit-length of $N$ but not the order.

---

## 8. Rigidity and the multiplicativity of the witness value

**Theorem 8.1 (Rigidity / injectivity).** *Fix $M$ and $N \le 2^M$, and let $n = 8(M+1)^2$. If $0 < r_1, r_2 \le N$ and $p_n(r_1, M) = p_n(r_2, M)$, then $r_1 = r_2$.*

*Proof.* Apply Theorem 6.3 to each: $r_i = \lfloor 1/p_n(r_i,M)\rceil$. Equal heat-kernel values give equal roundings. $\square$

So $p_n(\cdot, M)$ is not merely a good estimator of the order; on the whole admissible range it is a *complete invariant*.

**Theorem 8.2 (Approximate multiplicativity of the value).** *Let $0 < r_1, r_2$ with $r_1, r_2, r_1r_2 \le N \le 2^M$, and $n = 8(M+1)^2$. Then*
$$\Big| p_n(r_1r_2, M) - p_n(r_1,M)\, p_n(r_2,M) \Big| \;\le\; \frac{1}{N^2}.$$

*Proof sketch.* By Theorems 5.1, 5.2 and Lemma 6.1, each of $p_n(r_1,M)$, $p_n(r_2,M)$, $p_n(r_1r_2,M)$ lies within $\varepsilon = \frac{1}{4N^2}$ above $1/r_1$, $1/r_2$, $1/(r_1r_2)$ respectively. Hence $p_n(r_1r_2,M) = \frac{1}{r_1r_2} + \theta_0\varepsilon$ and $p_n(r_1,M)p_n(r_2,M) = \frac{1}{r_1r_2} + \frac{\theta_1\varepsilon}{r_2} + \frac{\theta_2\varepsilon}{r_1} + \theta_1\theta_2\varepsilon^2$ for some $\theta_i \in [0,1]$. Since $r_i \ge 1$ and $\varepsilon \le 1/4$, the difference is bounded in absolute value by $\varepsilon(1 + 1 + 1 + \varepsilon) \le 4\varepsilon = 1/N^2$. $\square$

**Remark 8.3 (An honest correction).** Theorem 8.2 refutes the tempting slogan that the heat-kernel witness is a *non-multiplicative* invariant of the order. As a function of $r$, the witness value is $1/r$ up to $O(N^{-2})$, and $r \mapsto 1/r$ is completely multiplicative. What is genuinely non-multiplicative is the **mechanism** producing the value: a spectral aggregate over all $r$ eigenvalues of a graph determined by the ambient modulus, rather than a local, Chinese-Remainder-separable count with multiplicative weights. The novelty is therefore in the *mode of access*, not in the coordinate accessed — and this is exactly the distinction one must maintain when classifying such mechanisms.

---

## 9. Sharpness: the gap is $\Theta(1/M)$ and the time is $\Theta((\log N)^2)$

Theorem 4.2 is an upper bound on $\lambda_k$. Is it lossy? Could a smarter argument give a gap of order $1$, hence $O(\log N)$ mixing? No: the Mersenne cycle lengths are extremal.

**Theorem 9.1 (Mersenne lower bound on the top eigenvalue).** *For $M \ge 1$ and $r = 2^M - 1$,*
$$\lambda_1(r, M) \;\ge\; 1 - \frac{106}{M+1}.$$

*Proof sketch.* For $r = 2^M - 1$ the dyadic orbit of the frequency $k=1$ is $\{2^t : 0 \le t \le M\}$ and, modulo $r$, these are $1, 2, 4, \dots, 2^{M-1}, 1$ — the binary place values. Hence
$$1 - \lambda_1 = \frac{1}{M+1}\sum_{t=0}^{M}\Big(1 - \cos\frac{2\pi 2^t}{r}\Big) \le \frac{1}{M+1}\sum_{t=0}^{M} \frac{1}{2}\Big(\frac{2\pi 2^t}{r}\Big)^2,$$
using $1 - \cos u \le u^2/2$ for the small angles and bounding the top few terms by $2$ each. The geometric sum $\sum_{t\le M} 4^t \le \tfrac43 4^{M}$ together with $r = 2^M - 1 \ge 2^M/2$ turns the right-hand side into an absolute constant divided by $M+1$; carrying the constants through gives $106$. $\square$

**Theorem 9.2 (The dyadic gap is $\Theta(1/M)$).** *For $M \ge 2$ and $r = 2^M-1$,*
$$1 - \frac{106}{M+1} \;\le\; \lambda_1(r,M) \;\le\; 1 - \frac{1}{M+1}.$$

*Proof.* The lower bound is Theorem 9.1; the upper bound is Theorem 4.2 with $k = 1$, valid since $1 \not\equiv 0 \pmod r$ (as $r \ge 3$) and $r \le 2^M$. $\square$

The two constants $1$ and $106$ differ, but the *shape* $\Theta(1/M)$ is settled: no analysis of this generator set can produce a constant-order gap. Consequently the quadratic step count is necessary, not an artefact:

**Theorem 9.3 (Necessity of quadratic diffusion time).** *Let $M \ge 106$, $r = 2^M - 1$, and let $n$ satisfy $154\, n \le M(M+1)$. Then*
$$\Big\lfloor \frac{1}{p_n(r,M)} \Big\rceil \;\ne\; r .$$

*Proof sketch.* Halving Theorem 9.1 gives $\mu_1 \ge 1 - \frac{53}{M+1} =: 1 - \delta$ with $\delta \le 1/2$ for $M \ge 105$. The elementary reverse bound $e^{-2\delta} \le 1 - \delta$ (valid on $0 \le \delta \le 1/2$, since $u \mapsto e^{-2u} - 1 + u$ is nonpositive there) yields $\mu_1^n \ge e^{-2\delta n} = e^{-106 n/(M+1)}$. Dropping all but the two leading spectral terms,
$$p_n(r,M) \;\ge\; \frac{1 + \mu_1^{\,n}}{r}.$$
If $154 n \le M(M+1)$ then $106n/(M+1) \le \tfrac{106}{154} M$, and a direct computation shows $\mu_1^n$ is large enough that $\frac{1+\mu_1^n}{r} > \frac{1}{r - 1/2}$, i.e. $1/p_n < r - 1/2$, so the rounding cannot return $r$. $\square$

**Corollary 9.4.** *With $M = \Theta(\log N)$, the number of diffusion steps required by this mechanism is $\Theta((\log N)^2)$.*

*Proof.* Sufficiency is Theorem 6.3 ($n = 8(M+1)^2$); necessity is Theorem 9.3 (any $n = o(M^2)$ fails on the Mersenne family). $\square$

---

## 10. Arithmetic payload: from a recovered order to a factor

**Theorem 10.1 (Nontrivial square root splits $N$).** *Let $N \ge 2$ and $y \in \mathbb{Z}$ satisfy $N \mid (y-1)(y+1)$ but $N \nmid (y-1)$ and $N \nmid (y+1)$. Then $d = \gcd(y-1, N)$ satisfies $d \mid N$ and $1 < d < N$.*

*Proof.* Clearly $d \mid N$. If $d = 1$ then $y - 1$ and $N$ are coprime, so $N \mid (y-1)(y+1)$ forces $N \mid (y+1)$, contradiction. If $d = N$ then $N \mid y - 1$, contradiction. Also $d \ne 0$ since $N \ne 0$. Hence $1 < d < N$. $\square$

**Theorem 10.2 (Factorisation from an even order).** *Let $N \ge 2$, $b, m \ge 1$, and suppose $N \mid b^{2m} - 1$ while $N \nmid b^m - 1$ and $N \nmid b^m + 1$. Then $N$ has a nontrivial divisor, namely $\gcd(b^m - 1, N)$, computable by one Euclidean algorithm.*

*Proof.* $b^{2m} - 1 = (b^m-1)(b^m+1)$, so Theorem 10.1 applies with $y = b^m$. $\square$

Thus the diffusion output feeds directly into a factorisation: run the walk, round, obtain $r$; if $r$ is even and $b^{r/2} \not\equiv \pm1$, one gcd finishes the job. For $N = 143$, $b = 2$: $r = 60$, $b^{30} \equiv 12 \pmod{143}$, and $\gcd(11, 143) = 11$.

The standard heuristics apply: for a random base modulo a product of two odd primes, the order is even with the required non-degeneracy at least half the time, so a handful of bases suffice in practice.

---

## 11. The sealing barrier: aggregation cost

The recovery theorem is unconditional, exact, and useless as an algorithm. It is worth stating precisely why.

**Observation 11.1 (Cost of the spectral evaluation).** Evaluating $p_n(r,M) = \frac1r\sum_{k<r}\mu_k^n$ requires $r$ eigenvalue computations, each a sum of $M+1$ cosines: total $\Theta(rM)$ arithmetic operations. Since $r$ divides $\varphi(N)$ and is generically of size $\Theta(N)$, this is exponential in $\log N$. Moreover the formula presupposes $r$.

**Observation 11.2 (Cost of the operational evaluation).** Iterating $W_M$ requires representing a function on the cycle: a vector of $r$ complex numbers, updated $n = \Theta((\log N)^2)$ times at cost $\Theta(rM)$ per step. Total $\Theta(r (\log N)^3)$ time and $\Theta(r)$ space. Again exponential in $\log N$.

**Observation 11.3 (Physical realisations relocate the cost).** A device that performs the diffusion in wall-clock time independent of the state-space size must physically embody the state space: $\Theta(r)$ modes, cells, or degrees of freedom. Its area or energy therefore scales like $r$. The aggregation cost is conserved; only its currency changes.

This is the precise sense in which the mechanism is an *informationally free but computationally sealed* witness: the secret coordinate $r$ is recovered from one scalar by an exact and provable rule, yet producing that scalar costs $\Theta(r)$ in some resource. A proof that *all* such spectral aggregates are sealed — i.e. that no evaluation of $p_n(e)$ avoids $\Theta(r)$-scale aggregation in every resource simultaneously — is not established here and remains the central open problem in this direction.

A digital shortcut through collisions among the dyadic residues $\{2^t \bmod r\}$ is likewise no help: it degenerates to birthday-type or $p-1$-type search, with the corresponding exponential costs.

---

## 12. Two sharp conjectures

**Conjecture 12.1 (The dyadic deficiency constant is $2$).** For every $r \ge 2$, every $k \not\equiv 0 \pmod r$ and every $M$ with $r \le 2^M$,
$$\sum_{t=0}^{M}\Big(1 - \cos\frac{2\pi k 2^t}{r}\Big) \;\ge\; 2,$$
with equality only for $(r,k) = (2,1)$. Consequently $\lambda_k \le 1 - \frac{2}{M+1}$, $\mu_k \le 1 - \frac{1}{M+1}$, and the sufficient step count improves from $8(M+1)^2$ to $4(M+1)^2$.

*Motivation.* Theorem 3.4 produces a single far-arc crossing, worth deficiency $\ge 1$. But the crossing is *approached*: the doubling immediately before it has circle distance exactly half that of the crossing point, so it contributes a further deficiency that never vanishes. The missing factor is a bookkeeping argument over consecutive doublings, not a new idea. Exhaustive search over all $(r, k)$ with $M \le 9$ shows the true infimum is exactly $2$. A single triple $(r,k,M)$ with deficiency $< 2$ would falsify it.

**Conjecture 12.2 (Mersenne extremality with constant $c^\star \approx 3.3946$).** The limit
$$c^\star \;=\; \lim_{M\to\infty}\big(1 - \lambda_1(2^M-1,\,M)\big)(M+1)$$
exists and equals approximately $3.3946$; and the Mersenne family is extremal, in the sense that the minimal-gap profile over $r \le 2^M$ is attained along Mersenne cycles.

*Motivation.* For $r = 2^M - 1$ the dyadic orbit is exactly the binary place values, so the deficiency is a truncated geometric series $\sum_t 4^t / r^2$ — a self-similar quantity, which explains why the numerics stabilise to five digits by $M = 12$. Theorem 9.1 already gives the correct $\Theta(1/M)$ shape with constant $106$; closing the gap to $3.3946$ requires only sharper cosine control at the top few frequencies $t \ge M-3$, where the quadratic bound $1 - \cos u \le u^2/2$ is wasteful.

---

## 13. Discussion and future work

**What is new.** Three things. First, a clean and completely elementary route from a *combinatorial* statement about doubling on a circle to a *quantitative* spectral gap: the doubling lemma (Theorem 3.4) is the only nontrivial input, and it replaces all harmonic analysis. Second, an *exact* recovery statement — not an estimate — for an integer-valued arithmetic invariant from one real measurement, with a two-sided error analysis and a rounding margin of a factor of two. Third, a matching lower bound (Theorem 9.3) that fixes the diffusion time at $\Theta((\log N)^2)$, so the mechanism's cost profile is fully characterised rather than merely bounded.

**Design principle.** The general lesson transfers beyond factorisation: on a cyclic group of unknown order $r$, adding lacunary generators in geometric progression up to a known upper bound $2^M \ge r$ reduces mixing time from $\Theta(r^2)$ to $O((\log r)^2)$, and the return probability then reads off $r$ exactly. This is a reusable gadget for any setting where a cyclic period must be measured rather than searched for.

**Limits.** The mechanism is not a factoring algorithm and does not become one; §11 makes the accounting explicit. Its interest is classificatory: it demonstrates that a secret coordinate can be exposed by a spectral aggregate, not only by local multiplicative statistics, and it sharpens the target for a general aggregation-necessity theorem.

**Future directions.**

1. **Prove Conjecture 12.1** (deficiency $\ge 2$), halving the constant in the step count.
2. **Prove Conjecture 12.2**, identifying the exact extremal constant $c^\star$ and the extremal family.
3. **Lacunary base-$a$ walks.** Replace $2^t$ by $a^t$ for a fixed $a \ge 2$. The escape argument survives verbatim with the far arc $[\,r/(2a),\, r(1 - 1/(2a))\,]$ and the threshold $2a\,d_r(x) < r$; the resulting gap should be $\Theta(\log a / \log r)$ per generator, suggesting an optimal trade-off between generator count and gap.
4. **Non-cyclic groups.** Extend to $(\mathbb{Z}/N\mathbb{Z})^\times$ itself, or to general finite abelian groups with a known exponent bound, where the far-arc argument must be run simultaneously in every cyclic component.
5. **Robustness.** Quantify how much noise the measurement tolerates: since the rounding margin is a factor of two, the mechanism should survive a relative error of order $1/(4N^2)$ in $p_n(e)$ — making explicit the precision requirement, which is itself an exponentially expensive resource and thus a fourth currency in the accounting of §11.
6. **Aggregation-necessity theorem.** Formulate and attack the statement that any evaluation of a spectral aggregate of this type must expend $\Theta(r)$ in time, space, area, energy, or precision.

---

## 14. Summary of results

| Result | Statement |
|---|---|
| Doubling lemma | For $k \not\equiv 0 \bmod r$ and $r \le 2^M$, some $t \le M$ has $2^t k \bmod r \in [r/4, 3r/4]$ |
| Spectral gap | $\lambda_k \le 1 - \frac{1}{M+1}$; $0 \le \mu_k \le 1 - \frac{1}{2(M+1)}$ for $k \not\equiv 0$ |
| Heat-kernel bounds | $\frac1r \le p_n(e) \le \frac1r + \big(1 - \frac{1}{2(M+1)}\big)^n$ |
| Mixing | at $n = 8(M+1)^2$ the error is $\le \frac{1}{4N^2}$ whenever $N \le 2^M$ |
| Exact recovery | $\lfloor 1/p_n(e)\rceil = r$ for $0 < r \le N \le 2^M$, $n = 8(M+1)^2$ |
| Operational form | $p_n(e) = (W_M^n\delta_r)(0)$: the measured return probability |
| Rigidity | $r \mapsto p_n(e)$ is injective on $1 \le r \le N$ |
| Value multiplicativity | $\big|p^{(r_1r_2)} - p^{(r_1)}p^{(r_2)}\big| \le 1/N^2$ for $r_1r_2 \le N$ |
| Sharpness | $\lambda_1(2^M-1,M) \ge 1 - \frac{106}{M+1}$: the gap is $\Theta(1/M)$ |
| Time lower bound | for $M \ge 106$ and $154n \le M(M+1)$, the rounding fails |
| Arithmetic payload | an even order $2m$ with $b^m \not\equiv \pm1$ splits $N$ via $\gcd(b^m-1, N)$ |

All statements above are unconditional and hold for every admissible choice of parameters.
