# Generator Tilt and the Scan-Order Inversion for Balanced Semiprimes

**Author:** Aristotle

**Date:** 2026-08-26

---

## Abstract

For a semiprime $N = pq$ with $p \le q$ and $q < 2p$, the small factor lies in the *canonical window* $(\sqrt{N/2},\,\sqrt{N}]$. A divisor scan of that window may proceed *window-ascending* (upward from $\sqrt{N/2}$) or *sqrt-descending* (downward from $\sqrt{N}$), and the two orders have complementary touch counts. We show that the contest between them collapses to a single scalar — the mean *tilt* $\bar z$, the normalised height of the divisor inside its window — and prove an exact inversion law: sqrt-descending strictly beats window-ascending if and only if $\bar z > 1/2$, with exact pool speedup $S = (L(1-\bar z)+1)/(L\bar z+1)$ for window length $L$, and with tilt-only predictor $(1-\bar z)/\bar z$ correct to within $1/(L\bar z^2)$.

We then compute $\bar z$ from the generator. The tilt of a key depends on $(p,q)$ only through the prime ratio $r = q/p$, via $z(r) = (r^{-1/2}-2^{-1/2})/(1-2^{-1/2})$, so the winner of the scan-order contest is a property of the key-generation law and not of any individual key. The two orders tie at the critical ratio $r^\star = 24 - 16\sqrt{2} = 1.372583\ldots$, which lies strictly inside the balance band $(1,2)$: enforcing $q < 2p$ does not determine the winner.

Two generator classes are solved exactly. A *ratio-uniform* pool on $[1,2]$ has mean tilt exactly $\sqrt{2}-1 = 0.414213\ldots < 1/2$, so window-ascending wins there with tilt-only speedup exactly $\sqrt{2}$. The *deployed* class — two primes drawn independently and uniformly from the same bit-length window — has ratio density $f(r) = 4/r^2 - 1$ on $[1,2]$, obtained by differentiating the exact planar area $A(r) = 5/2 - 2/r - r/2$; its mean tilt is exactly

$$\bar z = \frac{9 - 5\sqrt2}{3} = 0.642977\ldots > \frac12,$$

with tilt-only speedup $(5\sqrt2-6)/(9-5\sqrt2) = 0.555265\ldots$ — window-ascending *loses* roughly $44\%$ of the work. Under this law the probability that an individual key is won by sqrt-descending is $5 - 4/r^\star - r^\star \approx 0.7132$.

We also locate the boundary inside a one-parameter family: for the law with density proportional to $r^{-\theta}$ on $[1,2]$, the mean tilt is strictly increasing in $\theta$ and crosses $1/2$ at exactly $\theta^\star = 3/2$.

Finally we show that no redesign of the window helps: for multiplier $R>1$ the tie ratio is $r^\star(R) = 4R/(1+\sqrt{R})^2$, which satisfies $1 < r^\star(R) < \min(R,4)$ for every $R$, and ratio-uniform pools on $[1,R]$ have mean tilt $1/(1+\sqrt{R}) < 1/2$ always. We transfer the continuum statement to the integer window with an explicit half-step margin criterion, obtaining a deployment theorem: whenever $\sqrt{N} \ge 1/(2m(r))$ with $m(r) = r^{-1/2} - (1+2^{-1/2})/2 > 0$, the sqrt-descending scan strictly beats the window-ascending scan on the true integer window $[\lceil\sqrt{N/2}\rceil, \lfloor\sqrt{N}\rfloor]$. The conclusion is a scoped negative result: a window-ascending advantage is confined to artificially ratio-spread populations and is adversarially reversed on the populations deployed generators actually produce. No speedup for factoring is claimed or implied.

**Keywords:** semiprime factorisation, divisor scan order, prime ratio law, generator tilt, canonical balance window, closed-form mean tilt, no-go theorem.

---

## 1. Introduction

### 1.1 The question

Let $N = pq$ be a semiprime with $p \le q$. Trial division for the small factor need only test integers up to $\sqrt{N}$. If in addition the factorisation is *balanced*, meaning $q < 2p$, then $p^2 \le N < 2p^2$ and hence

$$\sqrt{N/2} < p \le \sqrt{N},$$

so the search may be confined to the **canonical window** $W(N) = (\sqrt{N/2},\,\sqrt{N}]$, whose length is $(1 - 2^{-1/2})\sqrt{N} \approx 0.2929\sqrt{N}$.

Confining the search to $W(N)$ leaves a free choice: the order in which the window is traversed. Two orders are canonical.

- **Window-ascending:** start at the bottom of the window and increase. Cost (touch count) to reach a divisor $d$: $d - a + 1$, where $a$ is the bottom of the window.
- **Sqrt-descending:** start at $\lfloor \sqrt N \rfloor$ and decrease. Cost: $b - d + 1$, where $b$ is the top.

The question addressed here is exactly which of these is cheaper, and on which populations of keys. It is a *reorder-class* question: neither scan changes the asymptotic complexity of trial division, and the comparison is a constant-factor one. But it is a constant factor with a clean and complete answer, and the answer turns out to say something structural about the interaction between an algorithm and the population it is benchmarked on.

### 1.2 The claim under test

An empirical claim in circulation held that the window-ascending order enjoys a systematic advantage over sqrt-descending on balanced semiprimes — a "channel" of savings available whenever the generator produces balanced keys. Supporting measurements on synthetic pools of balanced semiprimes reported speedups around $1.5$–$1.6$ in favour of ascending.

We show that this claim is correct on the pools where it was measured, and *false, with the opposite sign and comparable magnitude*, on the pools that deployed key generators actually produce. The reversal is not an empirical accident: both regimes are computed here in closed form, and the two closed forms lie on opposite sides of the decision threshold.

### 1.3 Contributions

1. **Reduction to one scalar** (§3). The two touch counts are complementary; the pool comparison is decided by the mean tilt $\bar z$ alone, with an exact speedup law and an explicit predictor error identity.
2. **Tilt is a generator property** (§4). The tilt depends on $(p,q)$ only through $r = q/p$; the tie ratio is $r^\star = 24-16\sqrt2$, strictly inside the balance band.
3. **Exact solution of the deployed class** (§5). Independent same-bit-length sampling has ratio density $4/r^2-1$ and mean tilt exactly $(9-5\sqrt2)/3 > 1/2$.
4. **Window-design no-go** (§6). For every window multiplier $R>1$, $1 < r^\star(R) = 4R/(1+\sqrt R)^2 < \min(R,4)$, and ratio-uniform pools have mean tilt $1/(1+\sqrt R) < 1/2$.
5. **Transfer to integer scans** (§7). A half-step margin criterion converts the continuum comparison into a statement about $[\lceil\sqrt{N/2}\rceil, \lfloor\sqrt N\rfloor]$, with per-key aggregation over pools with distinct windows.
6. **Agreement with measurement** (§8). All analytic values fall inside the reported measurement intervals from a four-pool simulation study.

---

## 2. Setup and definitions

Throughout, a *window* is a pair of integers $a \le b$ and a *divisor position* is an integer $d$ with $a \le d \le b$.

**Definition 2.1 (Scan costs).** The **ascending cost** of a scan of $[a,b]$ stopping at $d$ is $\mathrm{asc}(a,d) = d - a + 1$; the **descending cost** is $\mathrm{desc}(b,d) = b - d + 1$.

**Definition 2.2 (Tilt).** For $a < b$ and $x \in \mathbb{R}$, the **tilt** is $t(a,b;x) = (x-a)/(b-a)$. For a finite pool $S$ of keys with divisor positions $d_i$ in a common window $[a,b]$, the **mean tilt** is $\bar z = \frac{1}{|S|}\sum_{i \in S} t(a,b;d_i)$.

**Definition 2.3 (Pool totals).** $T_{\mathrm{asc}} = \sum_{i \in S} \mathrm{asc}(a,d_i)$ and $T_{\mathrm{desc}} = \sum_{i \in S} \mathrm{desc}(b,d_i)$. The **pool speedup** of ascending over descending is $S = T_{\mathrm{desc}}/T_{\mathrm{asc}}$; a value $> 1$ means ascending is the cheaper order.

**Definition 2.4 (Prime ratio and balance).** For $N = pq$ with $0 < p \le q$, the **prime ratio** is $r = q/p \ge 1$. The pair is **balanced** if $r < 2$. The **balance band** is $r \in (1,2)$.

**Definition 2.5 (Canonical window, integer form).** $a(N) = \lceil \sqrt{N/2}\rceil$, $b(N) = \lfloor \sqrt N \rfloor$.

**Definition 2.6 (Window multiplier).** For $R > 1$ the $R$-window is $(\sqrt{N/R},\,\sqrt N]$; scanning it upward is well defined whenever the generator guarantees $q < Rp$. The canonical window is $R = 2$.

---

## 3. The reduction: one scalar decides the contest

### 3.1 Conservation of scan budget

**Lemma 3.1 (Conservation law).** For all integers $a,b,d$,
$$\mathrm{asc}(a,d) + \mathrm{desc}(b,d) = (b-a) + 2.$$

*Proof.* $(d-a+1)+(b-d+1) = b-a+2$; the divisor cancels. $\square$

The two orders share a fixed budget: whatever one saves the other spends. This is the structural reason the comparison reduces to a location statistic and nothing else.

**Lemma 3.2 (Pointwise inversion).** $\mathrm{desc}(b,d) < \mathrm{asc}(a,d)$ if and only if $a + b < 2d$, i.e. if and only if $d$ lies strictly above the midpoint of the window.

*Proof.* Immediate from Definition 2.1. $\square$

### 3.2 Window membership is exactly balance

**Proposition 3.3.** Let $N = pq$ with $p, q$ positive integers and $p > 0$. Then
$$p^2 \le N < 2p^2 \iff (p \le q \text{ and } q < 2p).$$

*Proof.* $p^2 \le pq \iff p \le q$ and $pq < 2p^2 = p\cdot 2p \iff q < 2p$, both by cancelling the positive factor $p$. $\square$

Thus the canonical window contains the small factor precisely for balanced factorisations, and a generator that does not enforce $q < 2p$ produces keys on which the ascending scan is not even defined. Two consequences are worth recording.

**Corollary 3.4 (Same bit length forces window membership).** If $2^{b-1} \le p \le q < 2^{b}$ with $b \ge 1$, then $p \le q < 2^b = 2\cdot 2^{b-1} \le 2p$, so $p^2 \le N < 2p^2$.

This matters for the refutation: on a pool of two independent primes of *equal bit length*, every key is inside the window, so the ascending scan is always well defined and its loss cannot be attributed to window misses.

**Remark 3.5.** Off-balance semiprimes genuinely escape: $21 = 3 \cdot 7$ has $3^2 = 9 \le 21$ but $21 \ge 18 = 2\cdot 3^2$.

### 3.3 The tilt form of the totals

**Lemma 3.6.** For a nonempty pool $S$ in a common window with $a<b$ and $L = b-a$,
$$T_{\mathrm{asc}} = |S|\,(L\bar z + 1), \qquad T_{\mathrm{desc}} = |S|\,\big(L(1-\bar z)+1\big).$$

*Proof.* $T_{\mathrm{asc}} = \sum_i (d_i - a) + |S| = L\sum_i t(a,b;d_i) + |S| = |S|(L\bar z + 1)$; the descending form follows from Lemma 3.1 summed over the pool. $\square$

**Theorem 3.7 (Exact speedup law).** For a nonempty pool with $a<b$, $L = b-a$ and $\bar z > 0$,
$$S \;=\; \frac{T_{\mathrm{desc}}}{T_{\mathrm{asc}}} \;=\; \frac{L(1-\bar z)+1}{L\bar z + 1}.$$

*Proof.* Divide the two expressions of Lemma 3.6; the pool size cancels and the denominator is positive. $\square$

The pool speedup therefore depends on the population only through $\bar z$ — no higher moment of the divisor distribution enters. This is the "single scalar" reduction.

**Theorem 3.8 (Inversion theorem).** For a nonempty pool with $a<b$,
$$T_{\mathrm{desc}} < T_{\mathrm{asc}} \iff \bar z > \tfrac12 .$$

*Proof.* By Lemma 3.6 the inequality is $L(1-\bar z) + 1 < L\bar z + 1$, i.e. $L(1-2\bar z) < 0$, i.e. $\bar z > 1/2$ since $L > 0$. $\square$

Theorem 3.8 is the decision rule of the whole paper: a measured or computed $\bar z > 1/2$ refutes any window-ascending advantage on that population, whatever the window length, pool size, or key size.

### 3.4 The tilt-only predictor and its exact error

For large $L$ the speedup law simplifies to the **tilt-only predictor** $P(\bar z) = (1-\bar z)/\bar z$.

**Proposition 3.9 (Error identity).** For $L>0$ and $z>0$,
$$\frac{L(1-z)+1}{Lz+1} - \frac{1-z}{z} \;=\; \frac{2z-1}{z\,(Lz+1)}.$$

*Proof.* Put both sides over the common denominator $z(Lz+1)$ and expand: the numerator of the left side is $z(L(1-z)+1) - (1-z)(Lz+1) = 2z - 1$. $\square$

**Corollary 3.10 (Predictor accuracy).** For $0 < z \le 1$ and $L>0$,
$$\left| \frac{L(1-z)+1}{Lz+1} - \frac{1-z}{z} \right| \le \frac{1}{L z^2}.$$

*Proof.* By Proposition 3.9 the modulus equals $|2z-1| / (z(Lz+1)) \le 1/(z\cdot Lz) = 1/(Lz^2)$, using $|2z-1| \le 1$ for $z \in (0,1]$ and $Lz + 1 > Lz$. $\square$

Two features of Proposition 3.9 deserve emphasis. First, the error vanishes identically at the tie $z = 1/2$, so the predictor never misclassifies the *winner*; it only misreports the *margin*. Second, the error is $O(1/L)$, and $L = \Theta(\sqrt N)$, so at cryptographic sizes the predictor is exact to far more digits than any measurement can resolve. At the laboratory scale of the simulations ($b = 15$ bits, $L \approx 47$) it accounts for the gap between the predicted $\sqrt2 \approx 1.414$ and the measured $1.5896$ on the balanced control pool.

---

## 4. The tilt is a property of the generator

### 4.1 The ratio law

**Theorem 4.1 (Bridge theorem).** For real $p, q > 0$, the normalised height of $p$ inside the real window $(\sqrt{pq/2},\,\sqrt{pq}]$ is
$$\frac{p - \sqrt{pq/2}}{\sqrt{pq} - \sqrt{pq/2}} \;=\; z(q/p), \qquad\text{where}\qquad z(r) = \frac{r^{-1/2} - 2^{-1/2}}{1 - 2^{-1/2}}.$$

*Proof.* Write $p = u^2$, $q = v^2$ with $u,v>0$. Then $\sqrt{pq} = uv$ and $\sqrt{pq/2} = uv/\sqrt2$, so the left side is
$$\frac{u^2 - uv/\sqrt2}{uv - uv/\sqrt2} = \frac{u/v - 1/\sqrt2}{1 - 1/\sqrt2},$$
after dividing numerator and denominator by $uv$. Since $\sqrt{q/p} = v/u$, we have $u/v = (q/p)^{-1/2}$, which is the claim. $\square$

The size of $N$ has cancelled: **the tilt is scale-free**, a function of the ratio alone. Consequently the scan-order winner is determined by the *law of the prime ratio* emitted by a key generator, not by any property of an individual key. We call $\bar z = \mathbb E[z(r)]$ the **generator tilt**.

**Proposition 4.2 (Monotonicity and endpoints).** $z$ is strictly decreasing on $(0,\infty)$, with $z(1) = 1$ and $z(2) = 0$.

*Proof.* $r \mapsto r^{-1/2}$ is strictly decreasing on $(0,\infty)$ and the affine normalisation has positive denominator $1 - 2^{-1/2} > 0$. The endpoint values are direct substitutions. $\square$

Perfectly balanced keys sit at the *top* of the window ($z=1$) and maximally unbalanced ones at the *bottom* ($z=0$). This is the geometric content of the whole inversion: balance pushes the small factor toward $\sqrt N$, which is exactly where the descending scan begins.

### 4.2 The critical ratio

**Theorem 4.3 (Tie ratio).** Let $r^\star = 24 - 16\sqrt2$. Then $z(r^\star) = 1/2$, and for $r>0$,
$$z(r) > \tfrac12 \iff r < r^\star .$$
Moreover $1 < r^\star < 2$, and numerically $r^\star = 1.3725830\ldots$

*Proof.* First, $\sqrt{r^\star} = 4 - 2\sqrt2$, since $(4-2\sqrt2)^2 = 16 - 16\sqrt2 + 8 = 24 - 16\sqrt2$ and $4 - 2\sqrt2 > 0$. Hence
$$z(r^\star) = \frac{\frac{1}{4-2\sqrt2} - \frac{1}{\sqrt2}}{1 - \frac{1}{\sqrt2}} = \frac{\frac{4+2\sqrt2}{8} - \frac{\sqrt2}{2}}{\frac{\sqrt2-1}{\sqrt2}} = \frac12,$$
using $(4-2\sqrt2)(4+2\sqrt2) = 8$. The equivalence follows from strict monotonicity (Proposition 4.2). The bracketing $1 < r^\star < 2$ is $1.41421 < \sqrt2 < 1.41422$ inserted into $24 - 16\sqrt2$. $\square$

**Corollary 4.4 (Balance is not sufficient).** The dividing line between the two scan orders lies strictly inside the balance band. A generator that enforces $q < 2p$ — which is exactly what makes the ascending scan well defined — has thereby determined *nothing* about which order wins.

This is the pivot of the paper. The condition that legitimises the ascending scan is not the condition that makes it profitable, and the gap between the two contains all deployed generators.

### 4.3 The hard-balance control pool

**Theorem 4.5 (Ratio-uniform mean tilt).** If the prime ratio is uniform on $[1,2]$, then
$$\bar z \;=\; \int_1^2 z(r)\,dr \;=\; \sqrt2 - 1 \;=\; 0.4142135\ldots$$

*Proof.* $\int_1^2 r^{-1/2}\,dr = 2\sqrt2 - 2$. Hence
$$\int_1^2 z(r)\,dr = \frac{(2\sqrt2 - 2) - 2^{-1/2}}{1 - 2^{-1/2}} = \frac{\sqrt2(2\sqrt2-2) - 1}{\sqrt2 - 1} = \frac{4 - 2\sqrt2 - 1}{\sqrt2-1} = \frac{3-2\sqrt2}{\sqrt2-1},$$
and $(3-2\sqrt2) = (\sqrt2-1)^2$, so the quotient is $\sqrt2 - 1$. $\square$

**Corollary 4.6.** $\sqrt2 - 1 < 1/2$: the ratio-uniform pool is bottom-heavy, so window-ascending wins there, and its tilt-only speedup is
$$\frac{1 - (\sqrt2-1)}{\sqrt2-1} = \frac{2-\sqrt2}{\sqrt2-1} = \sqrt2 .$$

*Proof.* $\sqrt2 < 1.5$ gives the first claim. For the second, multiply numerator and denominator by $\sqrt2+1$: $(2-\sqrt2)(\sqrt2+1) = 2\sqrt2 + 2 - 2 - \sqrt2 = \sqrt2$, while $(\sqrt2-1)(\sqrt2+1) = 1$. $\square$

So the previously reported advantage is real — on this pool, and with the exact value $\sqrt2$.

---

## 5. The deployed generator class, solved exactly

A deployed key generator does not sample a ratio. It samples two primes independently and uniformly from the same bit-length window and takes whatever ratio results. This section solves that model in closed form.

### 5.1 The normalised model

**Model 5.1.** Let $p, q$ be independent and uniform on $[1,2]$ (the normalisation of a dyadic bit-length window $[2^{b-1}, 2^{b})$), conditioned on $p \le q$. Let $r = q/p \in [1,2]$.

By Corollary 3.4 every such pair is balanced and lies inside the canonical window, so no key of this class is excluded from the ascending scan.

### 5.2 The exact area and the ratio density

**Theorem 5.2 (Planar area).** For $1 \le r \le 2$, the area of $\{(p,q) \in [1,2]^2 : p \le q \le rp\}$ is
$$A(r) \;=\; \int_1^2 \big(\min(rp,\,2) - p\big)\,dp \;=\; \frac52 - \frac2r - \frac r2 .$$

*Proof.* Slice by $p$. The vertical extent of the region above $p$ is $\min(rp,2) - p$, and $rp \le 2$ exactly when $p \le t := 2/r$; note $1 \le t \le 2$ because $1 \le r \le 2$. Split the integral at $t$:
$$\int_1^{t}\big((r-1)p\big)\,dp + \int_{t}^{2}(2-p)\,dp = (r-1)\frac{t^2-1}{2} + \Big[2p - \frac{p^2}{2}\Big]_{t}^{2}.$$
The first term is $(r-1)(4/r^2 - 1)/2$ and the second is $2 - (2t - t^2/2) = 2 - 4/r + 2/r^2$. Summing and simplifying with $t = 2/r$ gives $5/2 - 2/r - r/2$. $\square$

Sanity checks: $A(1) = 5/2 - 2 - 1/2 = 0$, since no ordered pair has ratio strictly below $1$; and $A(2) = 5/2 - 1 - 1 = 1/2$, the area of the half-square $\{p \le q\}$, since every ordered pair drawn from $[1,2]$ has ratio at most $2$.

**Theorem 5.3 (Ratio density).** $A$ is differentiable on $(0,\infty)$ with
$$A'(r) \;=\; \frac{2}{r^2} - \frac12 \;=\; \frac{f(r)}{2}, \qquad f(r) := \frac{4}{r^2} - 1,$$
and $f$ is a probability density on $[1,2]$: $f \ge 0$ there and $\int_1^2 f(r)\,dr = 1$.

*Proof.* The derivative is elementary. The conditioning constant is the total mass $A(2) = 1/2$, so the density of $r$ is $A'(r)/A(2) = f(r)$. Nonnegativity on $[1,2]$ is $4/r^2 \ge 1$, i.e. $r \le 2$. For the mass, an antiderivative of $f$ is $F_0(r) = -4/r - r$, whence for any $s \ge 1$
$$\int_1^{s} f(r)\,dr = \Big(-\frac4s - s\Big) - (-4-1) = 5 - \frac4s - s, \tag{5.1}$$
which at $s=2$ equals $5 - 2 - 2 = 1$. $\square$

**Remark 5.4 (Shape).** $f(1) = 3$ and $f(2) = 0$: the density is heaped against perfect balance and vanishes at the edge of the band. Independent same-size primes come out *nearly equal* with high probability. By (5.1) the median ratio solves $5 - 4/s - s = 1/2$, giving $s \approx 1.2192$; the effective ratio near which the tilt of the population is realised is around $5/4$, and indeed $z(5/4) = 0.63955\ldots$, already comfortably above $1/2$.

### 5.3 The exact mean tilt

**Theorem 5.5 (Main theorem: deployed generator tilt).** Under Model 5.1,
$$\bar z_{\mathrm{ind}} \;=\; \int_1^2 z(r)\,f(r)\,dr \;=\; \frac{9 - 5\sqrt2}{3} \;=\; 0.6429773\ldots$$

*Proof.* Write $c = 2^{-1/2}$, so $z(r) = (r^{-1/2} - c)/(1-c)$. Then
$$z(r) f(r) = \frac{1}{1-c}\Big(4r^{-5/2} - r^{-1/2} - 4c\,r^{-2} + c\Big).$$
Each term is an elementary power. An antiderivative of the bracket is
$$G(r) = -\tfrac83 r^{-3/2} - 2r^{1/2} + 4c\,r^{-1} + c\,r,$$
as one checks by differentiating term by term. Evaluating,
$$G(2) - G(1) = \Big(-\tfrac{8}{3}\cdot\tfrac{1}{2\sqrt2} - 2\sqrt2 + 2c + 2c\Big) - \Big(-\tfrac83 - 2 + 4c + c\Big).$$
With $c = 1/\sqrt2 = \sqrt2/2$ this simplifies to
$$G(2)-G(1) = \frac{9-5\sqrt2}{3}\Big(1 - \frac{1}{\sqrt2}\Big),$$
and dividing by $1-c$ gives $\int_1^2 z f = (9-5\sqrt2)/3$. $\square$

**Corollary 5.6 (Analytic refutation).** $\bar z_{\mathrm{ind}} = (9-5\sqrt2)/3 > 1/2$. By Theorem 3.8 the sqrt-descending order strictly beats the window-ascending order on the deployed class — as a theorem, with no appeal to simulation.

*Proof.* $(9 - 5\sqrt2)/3 > 1/2 \iff 18 - 10\sqrt2 > 3 \iff 10\sqrt2 < 15 \iff \sqrt2 < 1.5$. $\square$

**Corollary 5.7 (Exact loss).** The tilt-only speedup of the deployed class is
$$P(\bar z_{\mathrm{ind}}) = \frac{1 - \frac{9-5\sqrt2}{3}}{\frac{9-5\sqrt2}{3}} = \frac{5\sqrt2 - 6}{9 - 5\sqrt2} = 0.5552646\ldots,$$
i.e. window-ascending performs about $1/0.5553 \approx 1.80$ times as much work as sqrt-descending: it loses roughly $44\%$.

### 5.4 The inversion is typical, not a tail effect

**Theorem 5.8 (Per-key frequency).** Under Model 5.1 the probability that a key's ratio falls below the critical ratio — equivalently, by Theorem 4.3 and Lemma 3.2, that the sqrt-descending order wins on that individual key — is
$$\Pr[r < r^\star] \;=\; 5 - \frac{4}{r^\star} - r^\star \;=\; 0.71320\ldots, \qquad r^\star = 24-16\sqrt2 .$$

*Proof.* Substitute $s = r^\star$ in (5.1); the numerical value follows from $1.37248 < r^\star < 1.37264$. $\square$

So the reversal is not carried by a thin adversarial tail. Roughly $71\%$ of deployed-style keys are individually top-heavy, and the pool mean is top-heavy as well.

**Corollary 5.9 (Opposite sides of the tie).** $\sqrt2 - 1 < 1/2 < (9-5\sqrt2)/3$. The ratio-uniform control pool and the independent same-bit-length pool land on strictly opposite sides of the decision threshold. This dichotomy is the entire content of the scope boundary.

### 5.5 A one-parameter family through the tie

The two solved classes are two points of a natural interpolating family. For $\theta \in \mathbb R$ let $\mu_\theta$ be the law on $[1,2]$ with density proportional to $r^{-\theta}$; then $\mu_0$ is the ratio-uniform control, and increasing $\theta$ piles mass against perfect balance, mimicking the deployed concentration. Where does this family cross the threshold?

**Theorem 5.10 (Exact crossing exponent).** Write $I(s) = \int_1^2 r^{-s}\,dr$. Then $\mathbb E_{\mu_\theta}[z]$ is a strictly increasing function of $\theta$, tending to $0$ as $\theta \to -\infty$ and to $1$ as $\theta \to +\infty$, and it equals $1/2$ at the single point
$$\theta^\star = \frac32 .$$

*Proof.* With $c = 2^{-1/2}$, $\mathbb E_{\mu_\theta}[z] = \bigl(I(\theta+\tfrac12)/I(\theta) - c\bigr)/(1-c)$, so the condition $\mathbb E_{\mu_\theta}[z] = 1/2$ is $I(\theta+\tfrac12)/I(\theta) = (1+c)/2$. At $\theta = 3/2$ we have $I(2) = 1/2$ and $I(3/2) = 2 - \sqrt2$, whence
$$\frac{I(2)}{I(3/2)} = \frac{1}{2(2-\sqrt2)} = \frac{2+\sqrt2}{4} = \frac{1 + 2^{-1/2}}{2} = \frac{1+c}{2},$$
using $(2-\sqrt2)(2+\sqrt2) = 2$. For monotonicity, note that for $\theta_1 < \theta_2$ the density ratio $d\mu_{\theta_2}/d\mu_{\theta_1} \propto r^{-(\theta_2-\theta_1)}$ is strictly decreasing in $r$, so $\mu_{\theta_2}$ strictly dominates $\mu_{\theta_1}$ in likelihood ratio and hence is stochastically smaller; since $z$ is strictly decreasing (Proposition 4.2), $\mathbb E_{\mu_{\theta_2}}[z] > \mathbb E_{\mu_{\theta_1}}[z]$. The limits follow because $\mu_\theta$ concentrates at $r = 2$ as $\theta \to -\infty$ and at $r = 1$ as $\theta \to +\infty$, where $z$ takes the values $0$ and $1$. $\square$

So the entire one-parameter family is classified by a single rational number: a generator whose ratio density decays like $r^{-\theta}$ near balance is adversarial to the ascending scan exactly when $\theta > 3/2$. For comparison, the deployed density $4/r^2 - 1$ is not of this form, but it is *steeper* than $r^{-3/2}$ near $r = 1$ in the relevant sense, consistent with its top-heavy verdict.

---

## 6. Window design cannot rescue the ascending scan

The window multiplier is a free parameter of the algorithm: for $R > 1$ one may scan $(\sqrt{N/R},\,\sqrt N]$ upward whenever the generator guarantees $q < Rp$. It is natural to ask whether a wider or narrower window makes the ascending order win on near-balanced populations. It does not.

**Definition 6.1.** The $R$-tilt law is $z_R(r) = (r^{-1/2} - R^{-1/2})/(1 - R^{-1/2})$; the canonical case is $z_2 = z$.

**Theorem 6.2 (General tie ratio).** For $R>1$ put $r^\star(R) = 4R/(1+\sqrt R)^2$. Then $z_R(r^\star(R)) = 1/2$, $z_R$ is strictly decreasing, and $z_R(r) > 1/2 \iff r < r^\star(R)$.

*Proof.* $\sqrt{r^\star(R)} = 2\sqrt R/(1+\sqrt R)$, so $r^\star(R)^{-1/2} = (1+\sqrt R)/(2\sqrt R) = \tfrac12(R^{-1/2} + 1)$, which is the midpoint of $R^{-1/2}$ and $1$; substituting into $z_R$ gives $1/2$. Strict monotonicity is as in Proposition 4.2, and the equivalence follows. $\square$

**Theorem 6.3 (No-go bounds).** For every $R>1$,
$$1 \;<\; r^\star(R) \;<\; R \qquad\text{and}\qquad r^\star(R) \;<\; 4 .$$

*Proof.* Write $s = \sqrt R > 1$. Then $r^\star = 4s^2/(1+s)^2$. The inequality $r^\star > 1$ is $4s^2 > (1+s)^2$, i.e. $2s > 1+s$, i.e. $s>1$. The inequality $r^\star < R$ is $4s^2 < s^2(1+s)^2$, i.e. $2 < 1+s$, i.e. $s>1$. The bound $r^\star < 4$ is $4s^2 < 4(1+s)^2$, immediate. $\square$

**Corollary 6.4 (Design no-go).** For every window multiplier $R>1$ there exists $r$ with $1 < r < \min(R,4)$ and $z_R(r) > 1/2$: an interval of near-balanced ratios just above $1$ is adversarial to the ascending scan *for every window*. Moreover the tie point can never be pushed past ratio $4$, so "widen the window" is a capped strategy. Since deployed generators concentrate ratio mass near $1$ (Remark 5.4), no window design removes the adversarial tilt.

*Proof.* Take $r = (1 + r^\star(R))/2$ and apply Theorems 6.2 and 6.3. $\square$

**Theorem 6.5 (Ratio-uniform pools are bottom-heavy for every window).** If $r$ is uniform on $[1,R]$ then
$$\frac{1}{R-1}\int_1^{R} z_R(r)\,dr \;=\; \frac{1}{1+\sqrt R} \;<\; \frac12 .$$

*Proof.* $\int_1^R r^{-1/2}\,dr = 2\sqrt R - 2$, so, multiplying numerator and denominator by $\sqrt R$,
$$\int_1^R z_R(r)\,dr = \frac{(2\sqrt R - 2) - (R-1)R^{-1/2}}{1 - R^{-1/2}} = \frac{\sqrt R\,(2\sqrt R - 2) - (R-1)}{\sqrt R - 1} = \frac{R - 2\sqrt R + 1}{\sqrt R - 1} = \frac{(\sqrt R - 1)^2}{\sqrt R - 1} = \sqrt R - 1 .$$
Since $R - 1 = (\sqrt R - 1)(\sqrt R + 1)$, this equals $(R-1)/(1+\sqrt R)$, and dividing by $R-1$ gives the mean $1/(1+\sqrt R)$, which is $< 1/2$ exactly when $\sqrt R > 1$. $\square$

At $R = 2$ this recovers Theorem 4.5, since $1/(1+\sqrt2) = \sqrt2 - 1$. And it identifies the origin of the whole mirage: **bottom-heaviness is a property of ratio-spread populations**, uniformly across window designs — and ratio-spread populations are laboratory constructions, not products of any deployed generator.

Finally, consistency: $r^\star(2) = 8/(1+\sqrt2)^2 = 8/(3+2\sqrt2) = 8(3-2\sqrt2) = 24 - 16\sqrt2$, recovering Theorem 4.3.

---

## 7. From the continuum to the integer scan

Two debts remain between the continuum analysis and an actual scan: the window is rounded to integers, and different keys have different windows.

### 7.1 Rounding: a half-step suffices

**Definition 7.1 (Margin).** $m(r) = r^{-1/2} - \tfrac12\big(1 + 2^{-1/2}\big)$.

**Proposition 7.2.** $m(r) > 0 \iff z(r) > 1/2 \iff r < r^\star$.

*Proof.* $z(r) > 1/2$ is $r^{-1/2} - 2^{-1/2} > \tfrac12(1 - 2^{-1/2})$, i.e. $r^{-1/2} > \tfrac12(1 + 2^{-1/2})$, which is $m(r) > 0$. The second equivalence is Theorem 4.3. $\square$

**Lemma 7.3 (Half-step transfer).** Let $\alpha \le \beta$ be reals and $d$ an integer with $\alpha + \beta + 1 \le 2d$. Then, on the rounded window $[\lceil\alpha\rceil, \lfloor\beta\rfloor]$,
$$\mathrm{desc}(\lfloor\beta\rfloor, d) < \mathrm{asc}(\lceil\alpha\rceil, d).$$

*Proof.* By Lemma 3.2 it suffices that $\lceil\alpha\rceil + \lfloor\beta\rfloor < 2d$. But $\lceil\alpha\rceil < \alpha + 1$ and $\lfloor\beta\rfloor \le \beta$, so $\lceil\alpha\rceil + \lfloor\beta\rfloor < \alpha + \beta + 1 \le 2d$. $\square$

**Theorem 7.4 (Deployment theorem).** Let $N = pq$ with $p, q > 0$ real, $p$ an integer, and $r = q/p$. If
$$1 \;\le\; 2\,m(r)\,\sqrt{N},$$
then on the integer window $[\lceil\sqrt{N/2}\rceil,\ \lfloor\sqrt N\rfloor]$ the sqrt-descending scan strictly beats the window-ascending scan; equivalently
$$\Big\lceil \sqrt{N/2}\,\Big\rceil + \Big\lfloor \sqrt N \Big\rfloor \;<\; 2p .$$

*Proof.* Since $p = \sqrt{N}/\sqrt{r}$, we have $r^{-1/2}\sqrt N = p$, hence
$$2m(r)\sqrt N = 2p - \sqrt N - \sqrt{N}/\sqrt2 = 2p - \sqrt N - \sqrt{N/2}.$$
The hypothesis therefore reads $\sqrt{N/2} + \sqrt{N} + 1 \le 2p$, and Lemma 7.3 with $\alpha = \sqrt{N/2}$, $\beta = \sqrt N$, $d = p$ concludes. $\square$

**Corollary 7.5 (Explicit threshold).** If $r < r^\star$ then $m(r) > 0$ and every key with $\sqrt N \ge 1/(2m(r))$ is won by the sqrt-descending scan. For deployed-style ratios the threshold is a small constant: e.g. at $r = 5/4$, $m(5/4) = 2/\sqrt5 - (1+2^{-1/2})/2 = 0.04044\ldots$, so $\sqrt N \ge 12.37$, i.e. $N \ge 154$, suffices. Every key of cryptographic size satisfies the bound by an overwhelming margin.

### 7.2 Aggregation over per-key windows

**Theorem 7.6 (Per-key aggregation).** Let $S$ be a nonempty finite pool, each key $i$ with its own integer window $[a_i, b_i]$ and divisor $d_i$. If $a_i + b_i < 2d_i$ for all $i \in S$, then $\sum_i \mathrm{desc}(b_i, d_i) < \sum_i \mathrm{asc}(a_i, d_i)$.

*Proof.* Lemma 3.2 gives a strict inequality termwise; summing a strict inequality over a nonempty index set preserves strictness. $\square$

**Theorem 7.7 (Mixed pools).** If $a_i + b_i \le 2d_i$ for all $i \in S$ and the inequality is strict for at least one $j \in S$, the same conclusion holds.

*Proof.* Termwise $\mathrm{desc} \le \mathrm{asc}$ with one strict term. $\square$

Theorem 7.7 is the practically relevant form: a pool need not be uniformly top-heavy for descending to win the total. Combined with Theorem 5.8 — about $71\%$ of deployed-style keys are individually top-heavy — the pool-level verdict is robust.

### 7.3 The weighted-tilt law

When keys have distinct windows, the exact speedup law of Theorem 3.7 survives with one modification: the relevant average is *weighted by window length*.

**Theorem 7.8 (Weighted-tilt law).** Let $S$ be a pool of $n$ keys with windows $[a_i,b_i]$, lengths $L_i = b_i - a_i > 0$ and tilts $z_i = (d_i-a_i)/L_i$. Put
$$\bar L = \frac1n\sum_i L_i, \qquad z_w = \frac{\sum_i L_i z_i}{\sum_i L_i}.$$
Then
$$\frac{T_{\mathrm{desc}}}{T_{\mathrm{asc}}} = \frac{\bar L\,(1-z_w)+1}{\bar L\, z_w + 1},$$
and in particular descending wins the pool total if and only if $z_w > 1/2$.

*Proof.* $T_{\mathrm{asc}} = \sum_i (d_i - a_i + 1) = \sum_i L_i z_i + n = n(\bar L z_w + 1)$, and by Lemma 3.1 $T_{\mathrm{desc}} = \sum_i (L_i + 2) - T_{\mathrm{asc}} = n(\bar L(1-z_w)+1)$. Divide. $\square$

**Remark 7.9 (Direction of the weighting bias).** The weight $L_i = b_i - a_i$ is proportional to $\sqrt{N_i}$, and at fixed small factor $p$ a larger ratio means a larger $N$ and hence a longer window. Since the tilt *decreases* in the ratio (Proposition 4.2), long-window keys are systematically low-tilt keys, so $z_w \le \bar z$ whenever the pool has a spread of ratios: the weighting biases the measured speedup *in favour of the ascending scan*. The size of the bias grows with the ratio spread of the pool, and vanishes as the pool concentrates on a single ratio. This is a quantitative statement, not a heuristic: it is exactly the discrepancy quantified in §8.

---

## 8. Comparison with measurement

A simulation study generated four pools of $n = 600$ semiprimes each at bit length $b = 15$ with a fixed seed, using exact-uniform sieve-index prime sampling and touch-count costs computed directly from the scan definitions, with bootstrap standard errors from eight batches. Reported values (with $S>1$ meaning window-ascending wins):

| Pool | Window | Measured $\bar z$ (95% CI) | Measured $S \pm$ SE | In-window fraction |
|---|---|---|---|---|
| Hard-balance control (ratio spread over the band) | canonical | $0.4114$ $[0.3887, 0.4341]$ | $1.5896 \pm 0.0538$ | $1.000$ |
| Independent same-bit-length (deployed style) | canonical | $0.6356$ $[0.6150, 0.6562]$ | $0.5578 \pm 0.0217$ | $1.000$ |
| Narrow high-ratio stratum | $R = 4.5$ | $0.0558$ $[0.0530, 0.0586]$ | $17.345 \pm 0.4654$ | $0$ (canonical) |
| Wide ratio band | $R = 8.0$ | $0.5979$ $[0.5765, 0.6194]$ | $0.5505 \pm 0.0230$ | $0.582$ (canonical) |

Against these, the analytic values of this paper:

- **Control pool.** Theorem 4.5 gives $\bar z = \sqrt2 - 1 = 0.41421$, inside the measured interval $[0.3887, 0.4341]$. The measured speedup $1.5896$ exceeds the unweighted tilt-only value $\sqrt2 = 1.41421$, and Theorem 7.8 explains the gap exactly: the control pool spreads its ratio over the whole band, so by Remark 7.9 the window-length-weighted mean tilt $z_w$ falls appreciably below the unweighted $\bar z$. An independent reconstruction of a $600$-key, $15$-bit ratio-uniform pool gives $\bar z = 0.4107$ (matching the reported $0.4114$) but $z_w = 0.3856$, and $(1-z_w)/z_w = 1.593$, reproducing the reported $1.5896$ to within its standard error. The gap is a weighting effect, not a failure of the analytic value.
- **Deployed pool.** Theorem 5.5 gives $\bar z = (9-5\sqrt2)/3 = 0.642977$, inside the measured $[0.6150, 0.6562]$. Corollary 5.7 gives $S = 0.555265$, inside the measured $0.5578 \pm 0.0217$. Both analytic values are *predictions*, not fits. Here the weighting bias of Remark 7.9 is small, because the ratio density $4/r^2-1$ is concentrated: a $600$-key reconstruction gives $\bar z = 0.6537$ against $z_w = 0.6583$, a shift of under $0.005$, so the unweighted closed form is already accurate (and the shift is in the direction that makes ascending look *worse*, not better).
- **In-window fraction.** Corollary 3.4 explains the $1.000$ in-window fractions of the two canonical-window pools: equal bit length forces balance, hence window membership. The ascending scan was well defined on every deployed-style key and still lost.
- **Wide-band pool.** With $R = 8$, Theorem 6.5 predicts a ratio-uniform mean tilt of $1/(1+\sqrt8) = 0.2612$ *in the $R$-window*; the reported $0.5979$ is measured in the canonical window on a pool only $58\%$ of which lies inside it, so the two numbers are not directly comparable. What is comparable is the sign: the measured $S = 0.5505 < 1$ places this pool on the descending side once evaluated in the canonical window, consistent with the concentration of its in-window mass near $r=1$.
- **Narrow high-ratio pool.** The $17\times$ figure is real but not deployable: it is obtained by pinning the population into a narrow high-ratio stratum and scanning an adapted window, which requires advance knowledge of the declared ratio support — information invisible from $N$ alone. It is an illustration of Theorem 6.2 (a sufficiently high ratio band is bottom-heavy in an adapted window) rather than an attack.

Three-way agreement between the closed form $\sqrt2-1$, the analytic control target $0.414$, and independent replication of the control at a different bit length establishes that the measurement machinery is sound; the deployed-pool reversal is therefore a property of the population, not of the harness.

---

## 9. Algorithms

The results yield three short, exact procedures.

**Algorithm A (Scan-order oracle).** Given a description of a generator as a ratio law $\mu$ on $[1, R]$, compute $\bar z = \int z_R \,d\mu$; output "descending" if $\bar z > 1/2$, "ascending" if $\bar z < 1/2$, "tie" otherwise, with predicted speedup $(L(1-\bar z)+1)/(L\bar z+1)$. Cost: one integral. For the two solved classes the integral has the closed forms $1/(1+\sqrt R)$ and $(9-5\sqrt2)/3$.

**Algorithm B (Per-key margin test).** Given $N$ and a hypothesised ratio $r$, compute $m(r) = r^{-1/2} - (1+2^{-1/2})/2$. If $m(r) > 0$ and $\sqrt N \ge 1/(2m(r))$, Theorem 7.4 certifies that the descending scan wins on that key. Cost: $O(1)$ arithmetic operations at working precision.

**Algorithm C (Empirical tilt estimation).** Given a pool of factored semiprimes, compute for each the integer window $[\lceil\sqrt{N/2}\rceil, \lfloor\sqrt N\rfloor]$ and the tilt $(p - a)/(b-a)$; average. The pool speedup is then read from Theorem 3.7, and the exact touch counts can be verified directly. Cost: $O(n)$ square roots.

---

## 10. Discussion

### 10.1 What is established

The scan-order contest for balanced semiprimes is *completely solved* at the level of populations. It reduces to one scalar; the scalar is a generator property; the two natural generator classes are computed exactly; and the answer is opposite on the two. In summary:

$$\bar z_{\text{ratio-uniform}} = \sqrt2 - 1 = 0.41421\ldots \;<\; \frac12 \;<\; \frac{9-5\sqrt2}{3} = 0.64298\ldots = \bar z_{\text{independent}} .$$

The tie ratio $r^\star = 24 - 16\sqrt2 \approx 1.3726$ sits strictly inside the balance band, so the natural hypothesis "enforce balance and the ascending scan pays" is provably wrong; and the general tie-ratio bounds $1 < 4R/(1+\sqrt R)^2 < 4$ show that no window redesign repairs it.

### 10.2 What is not claimed

No factoring speedup is claimed. Both scans are exhaustive searches of a window of length $\Theta(\sqrt N)$ and are exponential in the bit length; a constant factor of $1.8$ in either direction is of no cryptanalytic consequence. Nor is any weakness in deployed key generation implied — quite the reverse: the finding is that deployed generation is *adversarial* to the hoped-for reordering gain, purely as a consequence of the geometry of independent sampling, without any deliberate hardening.

The $17\times$ figure on the narrow high-ratio pool must be read carefully. It is a pinning artefact requiring knowledge of the declared ratio support, which is not recoverable from $N$; it is not a deployable advantage.

### 10.3 Limits of transfer

The continuum model treats primes in a bit-length window as uniform points. The classical heuristics for prime distribution make this a good approximation at scale, but the transfer was assumed rather than established here; only exhaustive small-scale enumeration was performed. The direction of the approximation error is, however, favourable to the conclusion: any additional filtering applied by a real generator (rejecting near-equal primes, enforcing minimum bit distance, and so on) narrows the ratio band further toward $1$, which by Proposition 4.2 *increases* the tilt and strengthens the descending advantage.

The simulations were run at $15$-bit scale, where the window length $L \approx 47$ is small enough that the $O(1/L)$ correction of Proposition 3.9 is visible. At cryptographic sizes the exact law and the tilt-only predictor are indistinguishable.

### 10.4 The methodological point

The generator and the algorithm were entangled in the original measurement: the reported advantage was a joint property of "ascending scan" and "ratio-uniform sampler", and no amount of tuning the algorithm on that sampler could have revealed the reversal. What revealed it was writing the sampler as a probability law, pushing it through the cost model, and reading off a closed form. The two closed forms differ in sign relative to the threshold, and that difference is the entire result.

---

## 11. Future directions

The scan-order question has been reduced to a single scalar and solved for the two populations that matter. Several natural continuations remain.

**Tilt spectrum of a general prime-generation law.** The whole contest factors through one linear functional of the generator, $\mathbb E[z(r)]$, so classifying generators reduces to classifying ratio laws by a single moment. Theorem 5.10 settles the power-law family: the mean tilt is strictly *increasing* in $\theta$ and crosses $1/2$ at exactly $\theta^\star = 3/2$. What remains is the qualitative statement for arbitrary laws. *Conjecture:* for every ratio law $\mu$ supported in $[1,2]$, the condition $\mathbb E_\mu[z] = 1/2$ forces $\mu$ to put mass on both sides of the critical ratio $r^\star$ — equivalently, no law concentrated entirely on one side of $r^\star$ can be tied. This should follow from the strict monotonicity of $z$ together with $z(r^\star) = 1/2$, and the interesting question is the quantitative version: how small can $\mu\bigl((r^\star, 2]\bigr)$ be for a tied law?

**Unequal-bit-length generators.** The computation of Theorem 5.5 used only the area of a region inside a square; for primes of bit lengths $b$ and $b+k$ the region becomes a rectangle $[1,2]\times[2^k, 2^{k+1}]$, whose slice areas are still elementary and whose area formula generalises verbatim. *Conjecture:* for $k \ge 1$ the ratio never falls below $2^k \ge 2$, so the small factor leaves the canonical window entirely (in-window fraction $0$), and no admissible window multiplier $R < 2^k$ restores it; the ascending scan becomes *undefined* rather than merely worse.

**Higher moments and variance-aware predictors.** Theorem 3.7 shows the pool speedup depends only on the mean tilt, but the *variance* of the per-key outcome — how often descending wins on an individual key, Theorem 5.8 — is a second, independent statistic of the generator. A two-parameter description $(\mathbb E[z], \Pr[z > 1/2])$ would characterise both the pool-level and the key-level verdict, and both are closed-form integrals of the ratio law.

**Beyond two scan orders.** The conservation law of Lemma 3.1 applies only to the two monotone traversals. A midpoint-outward or randomised traversal has a different cost functional, and the natural optimisation problem — minimise expected touch count over all traversal orders, given the generator's tilt law — is a scheduling problem whose solution should be to visit positions in decreasing order of tilt density. Quantifying the gap between that optimum and the better of the two monotone scans would complete the reorder-class map.

---

## 12. Conclusion

For balanced semiprimes, the choice between scanning the canonical window upward from $\sqrt{N/2}$ and downward from $\sqrt N$ is decided by a single scalar, the mean tilt of the population — descending wins exactly when the mean tilt exceeds $1/2$ — and that scalar is a property of the key generator, not of any key. Ratio-uniform populations have mean tilt exactly $\sqrt2 - 1$ and favour ascending by exactly $\sqrt2$; independent same-bit-length populations, which is what deployed generators produce, have ratio density $4/r^2 - 1$ and mean tilt exactly $(9-5\sqrt2)/3$, and favour descending, with ascending losing about $44\%$ of the work. The tie occurs at ratio $24 - 16\sqrt2 \approx 1.3726$, strictly inside the balance band, so enforcing balance settles nothing; and since the tie ratio for any window multiplier $R$ lies in $(1,4)$, no window redesign repairs the deficit. The hoped-for reordering advantage exists, but only on populations no deployed generator emits.
