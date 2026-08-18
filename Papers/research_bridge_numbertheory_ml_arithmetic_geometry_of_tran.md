# Arithmetic Geometry of Quantized Weight Lattices: Convexity Invariants of Loss Landscapes under Modular Grid Quantization

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

We study the effect of lattice quantization of neural-network weight tensors on the global convexity invariants of the loss landscape, and we show that the exact answer is arithmetic rather than metric.

Let $f$ be an $L$-Lipschitz loss on a weight space $E$ and let $Q : E \to E$ be a quantizer of covering radius $r$, i.e. $\|Q(x) - x\| \le r$ for all $x$; the motivating example is entrywise nearest-point projection onto the modular grid $\delta\mathbb{Z}$, for which $r = \delta/2$. We prove:

1. **Forward transfer.** If $f$ is convex, then $f \circ Q$ is $2Lr$-approximately convex; the strong-convexity modulus $\mu$ transfers unchanged with the same additive defect; the optimal value shifts by at most $Lr$; the rounded optimum is an $Lr$-approximate global optimum; under $\mu$-quadratic growth every lattice-optimal weight lies within $\sqrt{2Lr/\mu}$ of the true optimum; and sublevel sets of $f \circ Q$ are sandwiched between two convex sublevel sets of $f$ at level distance $Lr$.

2. **Sharpness.** The constant $2Lr$ is exactly optimal, both over the class of all radius-$r$ quantizers and — contrary to a natural conjecture — for nearest-point grid quantization itself. Exact convexity is genuinely destroyed: the quantized landscape of $|x|$ is non-convex for every mesh.

3. **The denominator law.** At a rational interpolation weight $a = k/q$ the sharp defect constant is $\big(1 - \gcd(k,q)/q\big)L\delta$, depending only on the reduced denominator. Balanced interpolation ($q = 2$) costs exactly half the general bound. For $\gcd(k,q) = 1$ the set of achievable defects of convex $1$-Lipschitz losses is *exactly* the arithmetic progression $\frac{\delta}{q}\{0,1,\dots,q-1\}$, and its maximum $\big(1 - 1/q\big)\delta$ is attained.

4. **Spectral converse.** The defect spectrum is an arithmetic fingerprint: it determines the mesh $\delta$ of the quantizer, and at fixed mesh it determines the reduced denominator of the interpolation weight.

5. **Modular structure.** The $m$-symbol codebook embeds in the weight torus $\mathbb{R}/\delta\mathbb{Z}$ with image exactly the $m$-torsion subgroup; codebooks form a divisibility tower of torsion subgroups with exact index $m'/m$, split by the Chinese Remainder Theorem at coprime precisions, and their union is dense in the torus. For a $b$-bit quantizer the defect is $L\delta/2^{b}$, so $\mathrm{defect}(b)\cdot 2^b = L\delta$ is a conserved scaling law.

6. **Reverse transfer.** If along a tower of quantizers with covering radii tending to zero the quantized landscapes are $\varepsilon_m$-approximately convex with $\varepsilon_m \to 0$, then $f$ is *exactly* convex. Convexity of a continuous landscape is therefore certifiable from finite, quantized measurements.

**Keywords:** quantization, weight lattices, convexity defect, covering radius, torsion subgroup, Chinese Remainder Theorem, approximate convexity, model interpolation.

---

## 1. Introduction

### 1.1 Motivation

Deploying a large neural network almost always involves *quantization*: each real-valued weight is replaced by the nearest element of a finite, uniformly spaced codebook, typically an integer code of $b$ bits multiplied by a scale. The operation is arithmetic (integers modulo a range) and it is applied to an object — the trained weight tensor — whose value is entirely analytic (a near-critical point of a smooth loss). The empirical fact that quantization is usually harmless is well established. What is missing is a statement of *what exactly is preserved* and *at what exact rate*.

This paper takes the global convexity structure of the loss landscape as the invariant of interest. Convexity, and its quantitative refinements — the strong-convexity modulus, quadratic growth at the optimum, convexity of sublevel sets — are the properties that make optimization tractable and that describe the geometry of a training basin. We ask whether they survive the projection of weight space onto a lattice, and we obtain sharp answers.

### 1.2 The three layers

The results organize into three layers.

The **analytic layer** (Sections 3–4) is a family of transfer theorems parametrized by the covering radius $r$ of the target lattice. Every result has the shape "invariant of $f$ $\Rightarrow$ invariant of $f \circ Q$, degraded by an explicit function of $Lr$", and every degradation vanishes as $r \to 0$.

The **arithmetic layer** (Section 7) identifies the codebook: an $m$-level codebook is exactly the $m$-torsion subgroup of the weight torus $\mathbb{R}/\delta\mathbb{Z}$. This gives the refinement tower its exact indices, gives mixed precision a Chinese-Remainder decomposition, and yields the density statement that underlies the reverse-transfer theorem.

The **spectral layer** (Sections 5–6) is where the two meet, and it is the least expected. The exact defect at a rational interpolation weight $a = k/q$ is governed by the *reduced denominator* of $a$ and nothing else. The set of achievable defects is a full arithmetic progression in $(\delta/q)\mathbb{Z}$, and from that set one can recover both $\delta$ and $q/\gcd(k,q)$.

### 1.3 Related notions

Approximate convexity — convexity up to an additive defect — is a classical relaxation; the specific point here is not the notion but the *exact* constants attached to it by lattice arithmetic. Interpolating two trained checkpoints ("model soups", linear mode connectivity) is standard practice; the denominator law says that the arithmetic form of the interpolation weight, not its magnitude, controls the worst-case landscape damage. Covering radii of lattices are the natural quantization-theoretic parameter; the contribution here is to show the covering radius is *exactly* the right parameter, and to compute what happens beyond first order.

---

## 2. Setup and definitions

### 2.1 Weight space

Throughout, $E$ is a real normed vector space. The concrete case is $E = \mathbb{R}^\iota$ for a finite index set $\iota$ (one coordinate per scalar weight; $\iota$ may be a product $\{1,\dots,d_{\mathrm{out}}\}\times\{1,\dots,d_{\mathrm{in}}\}$ for a single matrix, or a disjoint union over all layers of a transformer), equipped with the supremum norm
$$\|W\| \;=\; \max_{i \in \iota} |W_i| .$$
The sup norm is the natural choice because entrywise quantization controls exactly this quantity.

**Definition 2.1 (Loss).** A *loss* is a function $f : E \to \mathbb{R}$. It is *$L$-Lipschitz* if $|f(x) - f(y)| \le L\|x - y\|$ for all $x, y$, and *convex* if $f(ax + by) \le a f(x) + b f(y)$ whenever $a, b \ge 0$ and $a + b = 1$.

**Definition 2.2 (Strong convexity).** For $\mu \in \mathbb{R}$, $f$ is *$\mu$-strongly convex* if for all $x, y$ and $a, b \ge 0$ with $a + b = 1$,
$$f(ax + by) \;\le\; a f(x) + b f(y) - ab\,\tfrac{\mu}{2}\|x - y\|^2 .$$

### 2.2 Quantizers

**Definition 2.3 (Grid rounding).** For a mesh $\delta > 0$, the *grid rounding* map is
$$Q_\delta(x) \;=\; \delta \cdot \operatorname{round}(x/\delta), \qquad x \in \mathbb{R},$$
where $\operatorname{round}$ takes the nearest integer, halves rounding upwards. Its image is the lattice $\delta\mathbb{Z}$, the subgroup of $\mathbb{R}$ generated by $\delta$.

**Lemma 2.4 (Basic properties).** For $\delta > 0$: (i) $Q_\delta(x) \in \delta\mathbb{Z}$ for all $x$; (ii) $|Q_\delta(x) - x| \le \delta/2$; (iii) $Q_\delta(y) = y$ if and only if $y \in \delta\mathbb{Z}$; (iv) $Q_\delta \circ Q_\delta = Q_\delta$.

*Proof.* (i) is immediate. For (ii), write $Q_\delta(x) - x = \delta\big(\operatorname{round}(x/\delta) - x/\delta\big)$ and use $|\operatorname{round}(t) - t| \le 1/2$. (iii) One direction is (i); conversely if $y = \delta k$ with $k \in \mathbb{Z}$ then $y/\delta = k$ rounds to itself. (iv) follows from (i) and (iii). $\square$

Item (ii) says $\delta/2$ is the **covering radius** of $\delta\mathbb{Z}$: the largest distance from a real number to the lattice. Item (iv) says quantization is idempotent — re-quantizing a quantized checkpoint is a no-op, so the lattice is a genuine retract of weight space.

**Definition 2.5 (Tensor quantization).** For $W \in \mathbb{R}^\iota$, set $\big(Q_\delta W\big)_i = Q_\delta(W_i)$. Then $Q_\delta W \in (\delta\mathbb{Z})^\iota$ and, by Lemma 2.4(ii) applied coordinatewise,
$$\|Q_\delta W - W\| \;\le\; \delta/2 .$$

**Definition 2.6 (Abstract quantizer).** A *quantizer of covering radius $r \ge 0$* on $E$ is a map $Q : E \to E$ with $\|Q(x) - x\| \le r$ for all $x \in E$.

Every result of Sections 3–4 is proved at this level of generality; nearest-point projection to a full-rank lattice is the motivating instance, and Section 5 shows that some phenomena distinguish nearest-point quantizers from general ones while others do not.

### 2.3 Approximate convexity

**Definition 2.7 (Approximate convexity).** For $\varepsilon \in \mathbb{R}$ and $S \subseteq E$, a function $g$ is *$\varepsilon$-approximately convex on $S$* if for all $x, y \in S$ and all $a, b \ge 0$ with $a + b = 1$,
$$g(ax + by) \;\le\; a\,g(x) + b\,g(y) + \varepsilon .$$
The *convexity defect* of $g$ at the configuration $(x, y, a)$ is
$$\mathrm{def}_g(x,y,a) \;=\; g\big(ax + (1-a)y\big) - \big(a\,g(x) + (1-a)\,g(y)\big),$$
so $g$ is $\varepsilon$-approximately convex iff $\sup \mathrm{def}_g \le \varepsilon$.

Two trivial but load-bearing remarks: exact convexity is the case $\varepsilon = 0$, and $0$-approximate convexity on a convex set is exact convexity. Approximate convexity is monotone in $\varepsilon$.

**Definition 2.8 (Approximate strong convexity).** $g$ is *$\varepsilon$-approximately $\mu$-strongly convex on $S$* if for all $x,y \in S$, $a,b \ge 0$, $a+b=1$,
$$g(ax + by) \;\le\; a g(x) + b g(y) - ab\,\tfrac{\mu}{2}\|x-y\|^2 + \varepsilon .$$

---

## 3. Forward transfer: convexity survives up to the covering radius

The engine of this section is a two-line consequence of the Lipschitz property.

**Lemma 3.1 (Displacement bound).** If $f$ is $L$-Lipschitz and $Q$ has covering radius $r$, then for all $x$,
$$f(Q(x)) \le f(x) + Lr \qquad\text{and}\qquad f(x) \le f(Q(x)) + Lr .$$

*Proof.* $|f(Q(x)) - f(x)| \le L\|Q(x) - x\| \le Lr$. $\square$

### 3.1 The main transfer theorem

**Theorem 3.2 (Quantized convexity transfer).** Let $f$ be convex and $L$-Lipschitz on $E$ and let $Q$ be a quantizer of covering radius $r$. Then $f \circ Q$ is $2Lr$-approximately convex on $E$:
$$f\big(Q(ax + by)\big) \;\le\; a\, f(Q(x)) + b\, f(Q(y)) + 2Lr$$
for all $x, y \in E$ and $a, b \ge 0$ with $a + b = 1$. For the $\delta$-grid ($r = \delta/2$) the defect is $L\delta$.

*Proof sketch.* Chain three estimates. By Lemma 3.1 at the blended point, $f(Q(ax+by)) \le f(ax+by) + Lr$. By convexity of $f$, $f(ax+by) \le a f(x) + b f(y)$. By Lemma 3.1 at the endpoints, $f(x) \le f(Q(x)) + Lr$ and $f(y) \le f(Q(y)) + Lr$; multiply by $a$ and $b$ respectively and add, using $a + b = 1$ to collapse $a\,Lr + b\,Lr = Lr$. Summing gives the claim with total slack $2Lr$. $\square$

The same argument with the strong-convexity inequality in place of convexity, and with an $\varepsilon$-approximately convex $f$ in place of a convex one, gives:

**Theorem 3.3 (Curvature transfer).** If $f$ is $\mu$-strongly convex and $L$-Lipschitz and $Q$ has covering radius $r$, then $f \circ Q$ is $2Lr$-approximately $\mu$-strongly convex. The curvature modulus is transported *unchanged*; quantization contributes only a zeroth-order defect.

**Theorem 3.4 (Defect propagation).** If $f$ is $\varepsilon$-approximately convex and $L$-Lipschitz, then $f \circ Q$ is $(\varepsilon + 2Lr)$-approximately convex.

### 3.2 Optima

**Theorem 3.5 (No global optimum is lost).** Let $f$ be $L$-Lipschitz with a global minimizer $x_0$. Then the lattice point $Q(x_0)$ is an $Lr$-approximate global minimizer:
$$f(Q(x_0)) \;\le\; f(x) + Lr \qquad \text{for every } x \in E .$$

*Proof.* $f(Q(x_0)) \le f(x_0) + Lr \le f(x) + Lr$. $\square$

**Theorem 3.6 (Optimal-value stability).** Let $f$ be $L$-Lipschitz and bounded below, $Q$ a quantizer of radius $r$. Then
$$\inf_{x \in E} f(x) \;\le\; \inf_{w \in Q(E)} f(w) \;\le\; \inf_{x \in E} f(x) + Lr .$$

*Proof sketch.* The left inequality holds because $Q(E) \subseteq E$. For the right, every $x$ satisfies $\inf_{Q(E)} f \le f(Q(x)) \le f(x) + Lr$, so $\inf_{Q(E)} f - Lr$ is a lower bound for the range of $f$ and hence at most $\inf_E f$. $\square$

**Theorem 3.7 (Basin localization).** Let $f$ be $L$-Lipschitz with global minimizer $x_0$ and suppose $f$ has $\mu$-quadratic growth for some $\mu > 0$:
$$\tfrac{\mu}{2}\|x - x_0\|^2 \;\le\; f(x) - f(x_0) \qquad \text{for all } x .$$
Let $\hat w$ be any weight that is optimal *within the lattice*, i.e. $f(\hat w) \le f(Q(x))$ for all $x$. Then
$$\|\hat w - x_0\| \;\le\; \sqrt{\frac{2Lr}{\mu}} .$$

*Proof sketch.* Lattice optimality at $x_0$ gives $f(\hat w) \le f(Q(x_0)) \le f(x_0) + Lr$. Quadratic growth at $\hat w$ gives $\frac{\mu}{2}\|\hat w - x_0\|^2 \le f(\hat w) - f(x_0) \le Lr$. Solve and take square roots. $\square$

The hypothesis of Theorem 3.7 is supplied by strong convexity:

**Proposition 3.8 (Strong convexity implies quadratic growth at the optimum).** If $f$ is $\mu$-strongly convex on $E$ and attains its global minimum at $x_0$, then $\frac{\mu}{2}\|x - x_0\|^2 \le f(x) - f(x_0)$ for all $x$.

*Proof sketch.* Apply strong convexity along the segment $t x + (1-t)x_0$ with $t = 1/(n+1)$. Writing $C = \frac{\mu}{2}\|x-x_0\|^2$, minimality of $f(x_0)$ at the interpolated point yields, after dividing by $t > 0$, the inequality $(1-t)C \le f(x) - f(x_0)$. Let $n \to \infty$, so $t \to 0$. $\square$

**Corollary 3.9.** For a $\mu$-strongly convex $L$-Lipschitz loss, every lattice-optimal weight lies within $\sqrt{2Lr/\mu}$ of the true optimum. Quantization cannot relocate the basin of attraction; the dependence $r^{1/2}$ means that one extra bit of precision buys a factor $\sqrt{2}$ in localization.

### 3.3 The sublevel filtration

**Theorem 3.10 (Sublevel sandwich).** Let $f$ be convex and $L$-Lipschitz, $Q$ a quantizer of radius $r$. For every level $c \in \mathbb{R}$,
$$\{x : f(x) \le c - Lr\} \;\subseteq\; \{x : f(Q(x)) \le c\} \;\subseteq\; \{x : f(x) \le c + Lr\},$$
and both outer sets are convex.

*Proof sketch.* Convexity of the outer sets is convexity of sublevel sets of a convex function. The two inclusions are exactly the two halves of Lemma 3.1. $\square$

Consequently every invariant of the sublevel filtration that is monotone under inclusion and sandwiching — connectedness of level sets, star-shapedness, contractibility, absence of spurious components — is preserved up to a level shift of $Lr$. This is the precise sense in which "the shape of the landscape" survives quantization.

---

## 4. Reverse transfer: convexity certified from finite data

Forward transfer degrades information from the continuum to the lattice. The remarkable fact is that the degradation is symmetric, and therefore invertible in the limit.

**Theorem 4.1 (Finite-precision certification).** Let $f$ be $L$-Lipschitz and let $Q$ have covering radius $r$. If $f \circ Q$ is $\varepsilon$-approximately convex, then $f$ is $(\varepsilon + 2Lr)$-approximately convex.

*Proof sketch.* Reverse the chain in Theorem 3.2: $f(ax+by) \le f(Q(ax+by)) + Lr$, then apply $\varepsilon$-approximate convexity of $f \circ Q$, then $f(Q(x)) \le f(x) + Lr$ and likewise at $y$, weighting by $a$ and $b$. $\square$

**Theorem 4.2 (Two-sided audit).** For an $L$-Lipschitz loss and a quantizer of radius $r$, approximate-convexity certificates transfer in both directions with the same toll $2Lr$:
$$\varepsilon\text{-convex } f \;\Longrightarrow\; (\varepsilon + 2Lr)\text{-convex } f\circ Q, \qquad \varepsilon\text{-convex } f\circ Q \;\Longrightarrow\; (\varepsilon+2Lr)\text{-convex } f .$$
In particular an exactly convex quantized landscape certifies $2Lr$-approximate convexity of the continuous loss.

By Theorem 5.6 below the constant $2Lr$ in both directions is optimal.

**Theorem 4.3 (Reverse transfer along a refining tower).** Let $f$ be $L$-Lipschitz and let $(Q_m)_{m \in \mathbb{N}}$ be quantizers with covering radii $r_m \to 0$. Suppose $f \circ Q_m$ is $\varepsilon_m$-approximately convex with $\varepsilon_m \to 0$. Then $f$ is **exactly convex**.

*Proof sketch.* Fix $x, y$ and $a + b = 1$, $a,b \ge 0$, and put $A = a f(x) + b f(y)$. The argument of Theorem 4.1 at index $m$ gives
$$f(ax+by) \;\le\; A + \big(\varepsilon_m + 2 L r_m\big)$$
for every $m$. The right-hand side converges to $A$, so $f(ax+by) \le A$ by passing to the limit. As $x, y, a, b$ were arbitrary, $f$ is convex. $\square$

**Corollary 4.4 (Concrete grid tower).** Let $f : \mathbb{R}^\iota \to \mathbb{R}$ be $L$-Lipschitz and $\delta > 0$. If for every $m$ the entrywise $\delta/(m+1)$-grid quantized landscape is $\varepsilon_m$-approximately convex with $\varepsilon_m \to 0$, then $f$ is convex. Here the covering radii are $\delta/(2(m+1)) \to 0$, and the defect bound of Theorem 3.2 along the tower is $L\delta/(m+1) \to 0$.

**Interpretation.** Convexity of $f$ is an assertion quantified over a continuum of weight settings, and is thus not directly testable. Theorem 4.3 converts it into a statement about a sequence of *finite-precision* measurements. Each quantized landscape $f \circ Q_m$ is a function on a discrete set of codes; its convexity defect is a finite (in bounded regions) computation on integers. If those defects go to zero along a refining tower, exact convexity of the underlying continuous landscape follows.

---

## 5. Sharpness: the constant $2Lr$ is exactly right

### 5.1 Exact convexity really is destroyed

**Theorem 5.1 (Defect lower bound for the absolute-value loss).** Let $\delta > 0$ and let $f(x) = |x|$, which is convex and $1$-Lipschitz. If $f \circ Q_\delta$ is $\varepsilon$-approximately convex, then $\varepsilon \ge \delta/2$.

*Proof.* Take $x = 2\delta/5$, $y = 3\delta/5$, $a = b = 1/2$. Then $Q_\delta(x) = 0$ (since $2/5 < 1/2$), $Q_\delta(y) = \delta$ (since $3/5 > 1/2$), and the midpoint is $\delta/2$, whose rounding is $\delta$ (halves round up). Thus the quantized loss at the midpoint is $\delta$ while the average of quantized endpoint losses is $\frac12\cdot 0 + \frac12\cdot\delta = \delta/2$; the defect is $\delta/2$. $\square$

**Corollary 5.2.** For every $\delta > 0$ the quantized landscape $x \mapsto |Q_\delta(x)|$ is not convex. Hence "convexity is preserved" must be read in the quantitative, approximate sense of Theorem 3.2.

**Corollary 5.3 (Sharpness up to a factor $2$ for $|\cdot|$).** For $f = |\cdot|$ and mesh $\delta$ the true defect lies in $[\delta/2,\ \delta]$; the upper end is Theorem 3.2 with $L = 1$, $r = \delta/2$.

### 5.2 Optimality over general quantizers

**Theorem 5.4 (The abstract constant is exactly $2Lr$).** Fix $r > 0$ and define $S : \mathbb{R} \to \mathbb{R}$ by
$$S(x) = \begin{cases} 5r, & x = 4r,\\ x - r, & \text{otherwise.}\end{cases}$$
Then $|S(x) - x| = r$ for every $x$, so $S$ is a quantizer of covering radius $r$; and if $|\cdot| \circ S$ is $\varepsilon$-approximately convex then $\varepsilon \ge 2r$.

*Proof.* $S(3r) = 2r$, $S(5r) = 4r$, $S(4r) = 5r$; the midpoint of $3r$ and $5r$ is $4r$. Hence the defect at $(3r, 5r, \tfrac12)$ equals $5r - \frac12(2r + 4r) = 2r$. $\square$

So over the class of *all* radius-$r$ quantizers, no constant below $2Lr$ can work. The remaining question is whether nearest-point lattice projection — a far more structured operation — admits the better constant $Lr$.

### 5.3 The midpoint (model-soup) theorem

For balanced interpolation the improvement is real, and it comes from a parity constraint on rounding.

**Lemma 5.5 (Rounding parity).** For all real $X, Y$,
$$\Big|\operatorname{round}(X) + \operatorname{round}(Y) - 2\operatorname{round}\!\big(\tfrac{X+Y}{2}\big)\Big| \;\le\; 1 .$$

*Proof sketch.* Each rounding $n$ of a real $t$ satisfies $t - \tfrac12 < n \le t + \tfrac12$. Adding the two endpoint estimates and subtracting twice the midpoint estimate bounds the (integer) left-hand expression strictly between $-2$ and $2$, hence its absolute value is at most $1$. $\square$

**Theorem 5.6 (Balanced interpolation loses only $Lr$).** Let $f$ be convex and $L$-Lipschitz on $\mathbb{R}^\iota$ and let $\delta > 0$. For all $W, V \in \mathbb{R}^\iota$,
$$f\Big(Q_\delta\big(\tfrac12 W + \tfrac12 V\big)\Big) \;\le\; \tfrac12 f(Q_\delta W) + \tfrac12 f(Q_\delta V) + \tfrac{L\delta}{2},$$
i.e. defect at most $L\delta/2 = Lr$, half the general bound. The constant is attained (by $f = |\cdot|$ at $x = 2\delta/5$, $y = 3\delta/5$).

*Proof sketch.* Lemma 5.5, applied to $X = W_i/\delta$, $Y = V_i/\delta$ and rescaled by $\delta$, gives coordinatewise
$$\Big|Q_\delta\big(\tfrac{W_i+V_i}{2}\big) - \tfrac{Q_\delta(W_i) + Q_\delta(V_i)}{2}\Big| \le \tfrac{\delta}{2},$$
hence $\|A - B\| \le \delta/2$ where $A = Q_\delta(\frac{W+V}{2})$ and $B = \frac12 Q_\delta W + \frac12 Q_\delta V$. Then $f(A) \le f(B) + L\delta/2$ by Lipschitz continuity, and $f(B) \le \frac12 f(Q_\delta W) + \frac12 f(Q_\delta V)$ by convexity of $f$ at the two lattice points. $\square$

### 5.4 The conjecture $Lr$ fails in general

**Theorem 5.7 (Refutation).** Let $\delta > 0$, let $c = \delta$ and consider the convex $1$-Lipschitz *target loss* $T_c(w) = |w - c|$. For every integer $n \ge 3$, with $x = \delta/2$, $y = -\delta/2$ and $a = 1 - 1/n$,
$$T_\delta\Big(Q_\delta\big(a x + (1-a) y\big)\Big) - \Big(a\, T_\delta(Q_\delta x) + (1-a) T_\delta(Q_\delta y)\Big) \;=\; \delta\Big(1 - \frac1n\Big) .$$
Consequently the sharp constant for nearest-point grid quantization of convex $1$-Lipschitz losses is exactly $\delta = 2Lr$, and the conjectural improvement to $Lr$ is false.

*Proof sketch.* $Q_\delta(\delta/2) = \delta$ (halves round up) and $Q_\delta(-\delta/2) = 0$: the endpoints round *away from each other*. The interpolated point is $\delta/2 - \delta/n$, which lies strictly below the threshold $\delta/2$ and therefore rounds *down* to $0$. There $T_\delta = \delta$, maximal, while the endpoint values are $T_\delta(\delta) = 0$ and $T_\delta(0) = \delta$, so the weighted average is $(1-a)\delta = \delta/n$. The defect is $\delta - \delta/n$. $\square$

Two features of this witness explain why earlier intuition failed. The interpolation weight must be strongly unbalanced ($a \to 1$), and the loss must *decrease* across the offending grid cell; symmetric model losses such as $|x|$ or $x^2$ centred at a grid point cannot exhibit it.

**Corollary 5.8 (Exact constant).** For nearest-point $\delta$-grid quantization the supremum over convex $1$-Lipschitz losses of the convexity defect equals exactly $\delta$, matching Theorem 3.2 with $L = 1$, $r = \delta/2$.

The two extremes — $L\delta/2$ at $a = 1/2$ and $\to L\delta$ along $a = 1 - 1/n$ — are not two isolated facts. They are two instances of a single arithmetic law.

---

## 6. The denominator law and the defect spectrum

### 6.1 The law

Fix a mesh $\delta > 0$, a convex $L$-Lipschitz loss $f$ on $\mathbb{R}$, weights $x, y \in \mathbb{R}$, and an interpolation weight $a \in (0,1)$. Write
$$u = Q_\delta(x), \quad v = Q_\delta(y), \quad w = Q_\delta\big(ax + (1-a)y\big),$$
and define the **rounding discrepancy**
$$D(a; x, y) \;=\; a u + (1-a) v - w .$$

**Lemma 6.1 (Convex-analytic half).** If $w$ lies in the interval between $u$ and $v$, then the convexity defect of $f\circ Q_\delta$ at $(x,y,a)$ is at most $L\,|D(a;x,y)|$.

*Proof sketch.* Write $w = s u + (1-s)v$ for some $s \in [0,1]$; this is possible because $Q_\delta$ is monotone, so $w$ lies between $u$ and $v$. Convexity of $f$ at $w$ gives $f(w) \le s f(u) + (1-s) f(v)$, so
$$f(w) - \big(a f(u) + (1-a) f(v)\big) \le (a - s)\big(f(v) - f(u)\big) \le |a-s|\,L\,|u-v| = L\,|au + (1-a)v - w| . \square$$

**Lemma 6.2 (Covering-radius half).** For $0 < a < 1$ and any $x, y$, $\;|D(a;x,y)| < \delta$ strictly.

*Proof sketch.* Divide by $\delta$: the quantity is $\big|a\operatorname{round}(X) + (1-a)\operatorname{round}(Y) - \operatorname{round}(M)\big|$ with $X = x/\delta$, $Y = y/\delta$, $M = aX + (1-a)Y$. Both $a\operatorname{round}(X) + (1-a)\operatorname{round}(Y)$ and $\operatorname{round}(M)$ lie in the half-open window $(M - \tfrac12, M + \tfrac12]$, so their difference is strictly less than $1$ in absolute value. $\square$

**Lemma 6.3 (Arithmetic half).** Let $a = k/q$ with $0 < k < q$ integers. Then $D(a;x,y) \in (\delta/q)\mathbb{Z}$, and hence by Lemma 6.2
$$|D(a;x,y)| \;\le\; \delta\Big(1 - \frac1q\Big).$$

*Proof sketch.* $u, v, w$ are all in $\delta\mathbb{Z}$, say $u = \delta\alpha$, $v = \delta\beta$, $w = \delta\gamma$ with $\alpha,\beta,\gamma \in \mathbb{Z}$. Then
$$D = \delta\Big(\tfrac{k}{q}\alpha + \big(1 - \tfrac{k}{q}\big)\beta - \gamma\Big) = \frac{\delta}{q}\Big(k(\alpha - \beta) + q(\beta - \gamma)\Big) \in \frac{\delta}{q}\mathbb{Z}.$$
An element of $\frac{\delta}{q}\mathbb{Z}$ of absolute value strictly below $\delta$ has absolute value at most $\frac{\delta}{q}(q-1) = \delta(1 - 1/q)$. $\square$

Combining the three lemmas:

**Theorem 6.4 (The denominator law).** Let $f$ be convex and $L$-Lipschitz on $\mathbb{R}$, let $\delta > 0$ and let $a = k/q$ with $0 \le k \le q$, $q \ge 1$. Then for all $x, y$,
$$f\big(Q_\delta(a x + (1-a) y)\big) \;\le\; a\, f(Q_\delta x) + (1-a)\, f(Q_\delta y) + L\delta\Big(1 - \frac1q\Big) .$$

The balanced case $q = 2$ recovers Theorem 5.6 ($L\delta/2$); letting $q \to \infty$ recovers the general bound $L\delta = 2Lr$ of Theorem 3.2, whose attainment is Theorem 5.7 (there $q = n$, $k = n-1$).

**Theorem 6.5 (Tensor denominator law).** The same bound holds verbatim for a convex $L$-Lipschitz loss on $\mathbb{R}^\iota$ under entrywise quantization: for $0 < k < q$ and all $W, V \in \mathbb{R}^\iota$,
$$f\Big(Q_\delta\big(\tfrac{k}{q} W + \big(1-\tfrac{k}{q}\big)V\big)\Big) \le \tfrac{k}{q} f(Q_\delta W) + \big(1-\tfrac{k}{q}\big) f(Q_\delta V) + L\delta\Big(1 - \frac1q\Big).$$

*Proof sketch.* Lemma 6.3 holds coordinatewise, so the sup-norm distance between $A = Q_\delta(\frac kq W + (1-\frac kq)V)$ and $B = \frac kq Q_\delta W + (1-\frac kq)Q_\delta V$ is at most $\delta(1-1/q)$. Then $f(A) \le f(B) + L\delta(1-1/q)$ by Lipschitz continuity and $f(B) \le \frac kq f(Q_\delta W) + (1-\frac kq) f(Q_\delta V)$ by convexity. $\square$

This is the statement that applies to actual checkpoints: interpolating two quantized transformers with a low-denominator weight is provably gentler on the landscape than an arbitrary interpolation.

### 6.2 The spectrum is complete

Define, for a mesh $\delta$ and an interpolation weight $k/q$, the **defect set**
$$\mathcal{D}(\delta; k, q) \;=\; \Big\{\, f\big(Q_\delta(\tfrac kq x + (1-\tfrac kq) y)\big) - \big(\tfrac kq f(Q_\delta x) + (1-\tfrac kq) f(Q_\delta y)\big) \;:\; f \text{ convex } 1\text{-Lipschitz},\ x, y \in \mathbb{R} \Big\}.$$

Theorem 6.4 says $\mathcal{D}(\delta;k,q) \subseteq (-\infty, \delta(1-1/q)]$ and Lemma 6.3 says that its positive part is confined to the arithmetic progression $\frac{\delta}{q}\{0,1,\dots,q-1\}$. The next theorem says that confinement is exact — nothing in the progression is missing.

**Theorem 6.6 (Defect spectrum).** Let $\gcd(k,q) = 1$ and let $j$ be an integer with $0 \le j < q$. Then there exist $c, x, y \in \mathbb{R}$ such that the convex $1$-Lipschitz target loss $T_c(w) = |w - c|$ satisfies
$$T_c\big(Q_\delta(\tfrac kq x + (1-\tfrac kq)y)\big) - \Big(\tfrac kq T_c(Q_\delta x) + (1-\tfrac kq) T_c(Q_\delta y)\Big) \;=\; \frac{\delta j}{q}.$$
Hence $\frac{\delta}{q}\{0,1,\dots,q-1\} \subseteq \mathcal{D}(\delta;k,q)$.

*Proof sketch.* The construction is explicit. Take $x = \delta(d - \tfrac12)$ and $y = -\delta/2$ for a suitable integer $d$, and $c = \delta C$ with $C$ a large integer (larger than $d$, than the auxiliary $e$ below, and than $0$) so that the target loss is affine and decreasing on all relevant points. Rounding is exact on half-integers: $Q_\delta(\delta(d-\tfrac12)) = \delta d$ and $Q_\delta(-\delta/2) = 0$. The interpolated point is
$$\tfrac kq \delta(d - \tfrac12) + (1-\tfrac kq)(-\tfrac\delta2) = \delta\Big(\tfrac{kd}{q} - \tfrac12\Big),$$
whose rounding is determined by the residue of $kd$ modulo $q$: if $kd = qe + j$ with $0 \le j < q$, then the point is $\delta(e + \tfrac jq - \tfrac12)$ and rounds to $\delta e$. Evaluating the target loss (affine on the relevant range) gives defect exactly $\delta j/q$.

It remains to realize an arbitrary residue $j$. This is the covering step: we need $d \in \mathbb{Z}$ with $kd \equiv j \pmod q$. Since $\gcd(k,q) = 1$, $k$ is invertible modulo $q$, and Bézout's identity $uk + vq = 1$ supplies $d = uj$ explicitly, with $kd - j = -vqj$ divisible by $q$. $\square$

**Theorem 6.7 (Exact constant at a coprime weight).** For $0 < k \le q$ with $\gcd(k,q) = 1$,
$$\max \mathcal{D}(\delta;k,q) \;=\; \delta\Big(1 - \frac1q\Big),$$
and the maximum is attained.

*Proof.* The upper bound is Theorem 6.4 with $L = 1$; attainment is Theorem 6.6 with $j = q - 1$. $\square$

**Theorem 6.8 (Only the reduced denominator matters).** For arbitrary integers $0 < k < q$, with $g = \gcd(k,q)$,
$$\max \mathcal{D}(\delta;k,q) \;=\; \delta\Big(1 - \frac{g}{q}\Big) \;=\; \delta\Big(1 - \frac{1}{q/g}\Big),$$
i.e. the sharp constant depends only on the reduced denominator $q/g$.

*Proof sketch.* Write $k = g k'$, $q = g q'$ with $\gcd(k', q') = 1$. The interpolation weight $k/q$ equals $k'/q'$ as a real number, so the defect set depends only on the value: $\mathcal{D}(\delta;k,q) = \mathcal{D}(\delta;k',q')$. Apply Theorem 6.7 to $(k', q')$. $\square$

**Remark 6.9 (Arithmetic, not metric).** Theorem 6.8 has a striking consequence: the worst-case convexity cost of an interpolation weight is discontinuous in the weight. Interpolating with $a = 1/2$ costs $\delta/2$; interpolating with $a = 501/1000$, which differs from $1/2$ by one thousandth, costs $0.999\,\delta$ — twice as much. Nearness in $\mathbb{R}$ has no bearing; only the denominator in lowest terms does.

### 6.3 The spectral converse

The exact constants can be read backwards. The defect set is, in principle, an observable of a training or evaluation run: one measures violations of the convexity inequality on quantized checkpoints. Those measurements determine the arithmetic data of the quantizer.

**Theorem 6.10 (The mesh is determined by the defects).** Let $\delta, \delta' > 0$, let $q > 1$ and $\gcd(k,q) = 1$ with $k \le q$. If $\mathcal{D}(\delta;k,q) = \mathcal{D}(\delta';k,q)$ then $\delta = \delta'$.

*Proof.* By Theorem 6.7 both sets have a maximum, $\delta(1 - 1/q)$ and $\delta'(1-1/q)$ respectively; equal sets have equal maxima, and $1 - 1/q > 0$ since $q > 1$. $\square$

**Theorem 6.11 (The reduced denominator is determined by the defects).** Fix $\delta > 0$ and let $0 < k < q$, $0 < k' < q'$. If $\mathcal{D}(\delta;k,q) = \mathcal{D}(\delta;k',q')$ then
$$\frac{q}{\gcd(k,q)} \;=\; \frac{q'}{\gcd(k',q')} .$$

*Proof.* Equal sets have equal maxima; by Theorem 6.8 the maxima are $\delta(1 - g/q)$ and $\delta(1 - g'/q')$, so $g/q = g'/q'$ and hence $q/g = q'/g'$. $\square$

Thus the convexity defect spectrum is a complete arithmetic fingerprint: it identifies the lattice that produced it, and the reduced denominator of the interpolation weight used to probe it.

---

## 7. The modular layer: codebooks as torsion points

We now identify the arithmetic object indexing quantized weights.

### 7.1 The weight torus and the codebook homomorphism

Fix a dynamic range $\delta > 0$. Because a fixed-point weight format is periodic modulo its range, the natural home of a quantized weight is the **weight torus**
$$\mathbb{T}_\delta \;=\; \mathbb{R}/\delta\mathbb{Z} .$$
An $m$-level quantizer emits codes from $\mathbb{Z}/m\mathbb{Z}$; the code $k$ names the weight $k\delta/m$.

**Definition 7.1.** For $m \ge 1$ the *codebook homomorphism* is the group homomorphism
$$\chi_{\delta,m} : \mathbb{Z}/m\mathbb{Z} \longrightarrow \mathbb{T}_\delta, \qquad \chi_{\delta,m}(k) = k\,\frac{\delta}{m} \bmod \delta .$$
It is well defined precisely because $m\cdot(\delta/m) = \delta \equiv 0$; the code alphabet being modular is exactly what makes the map exist.

**Theorem 7.2 (Faithfulness).** For $\delta > 0$ and $m \ge 1$, $\chi_{\delta,m}$ is injective: distinct codes name distinct weights, so no precision is wasted.

*Proof sketch.* If $\chi_{\delta,m}(k) = 0$ then $k\delta/m = n\delta$ for some integer $n$, whence $k = nm$ and $k \equiv 0 \pmod m$. $\square$

**Theorem 7.3 (Codes are exactly torsion points).** The image of $\chi_{\delta,m}$ is precisely the $m$-torsion subgroup of the weight torus:
$$\operatorname{im}\chi_{\delta,m} \;=\; \{\,x \in \mathbb{T}_\delta \;:\; m x = 0 \,\}.$$

*Proof sketch.* Every $\chi_{\delta,m}(k)$ is killed by $m$. Conversely if $x = t \bmod \delta$ satisfies $mx = 0$ then $mt = n\delta$ for some integer $n$, so $t = n\delta/m$ and $x = \chi_{\delta,m}(n \bmod m)$. $\square$

Quantized weights are therefore not an arbitrary finite subset of the torus but its arithmetic points. Combining with injectivity:

**Corollary 7.4 (Codebook size).** $\#\{x \in \mathbb{T}_\delta : mx = 0\} = m$, and the generating step $\delta/m$ has order exactly $m$ in $\mathbb{T}_\delta$. For a weight tensor indexed by $\iota$, the $m$-level codebook has exactly $m^{|\iota|}$ elements.

### 7.2 Refinement towers and mixed precision

**Theorem 7.5 (Divisibility tower).** If $m \mid m'$ then $\{x : mx = 0\} \subseteq \{x : m'x = 0\}$, and the corresponding grids nest, $(\delta/m)\mathbb{Z} \subseteq (\delta/m')\mathbb{Z}$. Refining precision along a divisibility tower produces an increasing tower of torsion subgroups.

**Theorem 7.6 (Exact index).** For $0 < m \mid m'$,
$$\#\{x \in \mathbb{T}_\delta : m' x = 0\} \;=\; \frac{m'}{m}\cdot \#\{x \in \mathbb{T}_\delta : m x = 0\}.$$

**Theorem 7.7 (Chinese Remainder mixed precision).** If $\gcd(m,n) = 1$ there is a canonical isomorphism of codebooks
$$\big(\mathbb{Z}/mn\mathbb{Z}\big)^{\iota} \;\cong\; \big(\mathbb{Z}/m\mathbb{Z}\big)^{\iota} \times \big(\mathbb{Z}/n\mathbb{Z}\big)^{\iota},$$
so an $mn$-level quantizer factors as a pair of independent $m$- and $n$-level quantizers; in particular $(mn)^{|\iota|} = m^{|\iota|}\cdot n^{|\iota|}$.

This gives mixed-precision quantization a clean arithmetic meaning: coprime precisions carry independent information, and a composite precision is recoverable from its coprime factors.

**Theorem 7.8 (Density of the codebook tower).** The union of all finite codebooks,
$$\bigcup_{m \ge 1} \{x \in \mathbb{T}_\delta : mx = 0\} \;=\; \mathrm{Tors}(\mathbb{T}_\delta) \;\cong\; \mathbb{Q}/\mathbb{Z},$$
is dense in $\mathbb{T}_\delta$.

*Proof sketch.* A subgroup of the circle is either dense or cyclic, generated by a single element $a$ of finite order $n$; in the latter case the subgroup has exactly $n$ elements. But the torsion subgroup already contains the $(n+1)$-torsion, which has $n+1$ elements by Corollary 7.4 — a contradiction. Hence the torsion subgroup is dense. $\square$

Density is the arithmetic mechanism behind reverse transfer (Theorem 4.3): the tower of finite codebooks sees all of weight space in the limit, so defect measurements along the tower cannot miss any configuration.

### 7.3 Bit width

**Theorem 7.9 ($b$-bit quantization).** Let $f$ be convex and $L$-Lipschitz on $\mathbb{R}^\iota$ and let a $b$-bit uniform quantizer of dynamic range $\delta$ have mesh $\delta/2^b$. Then the quantized landscape is $\dfrac{L\delta}{2^b}$-approximately convex.

**Theorem 7.10 (Conserved scaling law).** With $\mathrm{defect}(b) = L\delta/2^b$,
$$\mathrm{defect}(b+1) = \tfrac12\,\mathrm{defect}(b), \qquad \mathrm{defect}(b)\cdot 2^{b} = L\delta \ \ \text{for every } b .$$
Each additional bit halves the convexity defect while doubling the codebook; the product is a bit-width-independent invariant of the loss and the dynamic range.

For instance, moving from INT8 to INT4 at fixed dynamic range multiplies the guaranteed convexity defect by $2^4 = 16$, and multiplies the basin-localization radius $\sqrt{2Lr/\mu}$ by $4$.

---

## 8. Algorithms

The theory yields three directly implementable procedures.

### 8.1 Convexity-defect audit

**Input:** a loss oracle $f$, a Lipschitz constant $L$, a mesh $\delta$, a finite sample of weight pairs and interpolation weights.
**Output:** a certified interval for the convexity defect of the continuous loss.

For each sampled triple $(W, V, a)$, evaluate the quantized defect
$$d = f\big(Q_\delta(aW + (1-a)V)\big) - a f(Q_\delta W) - (1-a) f(Q_\delta V),$$
and take $\hat\varepsilon = \max(0, \max_{\text{samples}} d)$. By Theorem 4.2 the continuous loss is $(\hat\varepsilon + L\delta)$-approximately convex on the sampled configurations, and by Theorem 3.2 any $\varepsilon$-approximate convexity of $f$ implies quantized defect at most $\varepsilon + L\delta$. Cost: three loss evaluations per sample.

### 8.2 Denominator-aware interpolation scheduling

**Input:** a target interpolation weight $a^\star \in (0,1)$, a denominator budget $q_{\max}$, mesh $\delta$, Lipschitz constant $L$.
**Output:** a rational weight $a = k/q$ with $q \le q_{\max}$ minimizing a trade-off between $|a - a^\star|$ and the certified worst-case defect $L\delta(1 - 1/q_{\mathrm{red}})$, where $q_{\mathrm{red}} = q/\gcd(k,q)$.

Enumerate Farey fractions of order $q_{\max}$ (or use continued-fraction convergents of $a^\star$), score each by $\lambda|a - a^\star| + L\delta(1 - 1/q_{\mathrm{red}})$, and return the minimizer. Farey enumeration is $O(q_{\max}^2)$; continued fractions give the best approximations at each denominator in $O(\log q_{\max})$ steps. The practical payoff is Remark 6.9: snapping an interpolation weight to a nearby small-denominator rational can halve the certified landscape damage at negligible cost in the value of the weight.

### 8.3 Defect-spectrum synthesis and mesh identification

**Input:** a mesh $\delta$, a coprime pair $(k,q)$, a target residue $j$.
**Output:** an explicit convex $1$-Lipschitz loss and weight pair realizing defect exactly $\delta j/q$.

Solve $k d \equiv j \pmod q$ by the extended Euclidean algorithm ($O(\log q)$), write $kd = qe + j$, and output the target loss $T_{\delta C}$ with $C = \max(d, e, 0)$ together with $x = \delta(d - \tfrac12)$, $y = -\delta/2$. Running this for $j = 0, \dots, q-1$ synthesizes the entire spectrum; by Theorems 6.10 and 6.11 the resulting maximum recovers $\delta$ and the reduced denominator, giving a *mesh-identification* procedure from landscape measurements.

---

## 9. Applications

**Post-training quantization with guarantees.** Theorems 3.5–3.7 give a deployment-time guarantee that is quantitative and checkable: the rounded optimum loses at most $L\delta/2$ in loss value, the lattice-restricted optimum is within $L\delta/2$ of the continuous optimum, and the optimizing weight cannot move further than $\sqrt{L\delta/\mu}$ from the true one. All three depend on the network only through $L$ (a gradient bound) and $\mu$ (a curvature bound).

**Bit-width selection.** Theorem 7.10 turns bit width into an explicit trade curve: defect $\times$ codebook size is conserved. A target defect $\varepsilon$ requires $b \ge \log_2(L\delta/\varepsilon)$ bits, and this is tight by Corollary 5.8.

**Model soups and checkpoint averaging.** Theorem 5.6 justifies the practice of *uniform* averaging with a sharp constant: balanced blending is exactly twice as gentle as the worst case. Theorem 6.4 extends this to arbitrary rational blends, and Remark 6.9 gives the counterintuitive design rule to prefer small denominators.

**Mixed-precision layouts.** Theorem 7.7 says a composite precision splits along coprime factors. Assigning coprime precisions to independent weight groups gives a codebook that is a direct product, so codes can be transported and recombined without loss.

**Landscape certification from quantized logs.** Theorem 4.3 makes convexity of a continuous landscape an experimentally accessible property: a sequence of finite-precision defect measurements with defects tending to zero certifies exact convexity. Since every measurement is on quantized (hence exactly representable) weights, the certificate is free of floating-point ambiguity.

---

## 10. Discussion

### 10.1 What is actually preserved

The results delineate two regimes sharply. *Approximately*, everything is preserved: convexity, the strong-convexity modulus, the optimal value, the optimizer location, the sublevel filtration, with an explicit degradation that is linear in the covering radius (or square-root in it, for the optimizer location). *Exactly*, nothing is preserved: quantized landscapes of convex functions are never convex, by Corollary 5.2. The correct statement is the quantitative one, and its constant is not improvable.

### 10.2 Why the arithmetic appears

The mechanism is visible in Lemma 6.3. Three lattice points enter the convexity inequality — the roundings of the two endpoints and of the blend — and the discrepancy between the blended lattice points and the lattice point of the blend is forced to lie in a *refined* lattice $(\delta/q)\mathbb{Z}$ whose refinement index is the denominator of the interpolation weight. Analysis supplies the strict bound $|D| < \delta$; arithmetic supplies the discreteness. A bounded discrete set has a maximum, and computing it is a number-theoretic question. That the maximum is attained for every coprime numerator is a covering statement in $\mathbb{Z}/q\mathbb{Z}$, resolved by Bézout.

### 10.3 Limitations

The theory is stated for globally Lipschitz, globally convex losses. Real transformer losses are neither, and the honest reading is local: the theorems apply on a region where $f$ is convex with a valid Lipschitz bound, with all constants relative to that region. The Lipschitz constant of a deep network can be large, and the bound $L\delta$ is only informative when $L\delta$ is small compared with the loss scale — this is precisely the regime in which quantization is empirically safe, so the theory and the practice agree about when to trust the guarantee.

The quantizer model is uniform (a scaled integer lattice) and deterministic. Non-uniform codebooks (logarithmic, learned, vector-quantized) fit the abstract framework of Definition 2.6 through their covering radius, so Theorems 3.2–4.3 apply verbatim; but the denominator law of Section 6 uses the lattice structure of $\delta\mathbb{Z}$ essentially and does not.

Finally, the defect is a worst-case quantity. Typical-case behaviour under a randomized rounding rule, or under a distribution of weight configurations, is a different and complementary question.

---

## 11. Future directions

Several concrete lines follow directly.

**Higher-rank lattices.** Replace $(\delta\mathbb{Z})^\iota$ by a general full-rank lattice $\Lambda \subset \mathbb{R}^\iota$ with covering radius $r(\Lambda)$. Theorems 3.2–4.3 apply unchanged. The denominator law should become a statement about the *index* of the sublattice generated by $\Lambda$ and the rational combination, i.e. about the group $\frac{1}{q}\Lambda / \Lambda \cong (\mathbb{Z}/q\mathbb{Z})^{|\iota|}$, and the defect spectrum should become a covering statement in that group rather than in $\mathbb{Z}/q\mathbb{Z}$. Anisotropic lattices (per-channel scales) are the practically relevant case.

**Stochastic rounding.** Randomized rounding is unbiased, and the expected discrepancy vanishes. The right object is then the *distribution* of the defect on the lattice slice $\frac{\delta}{q}\{0,\dots,q-1\}$; the denominator law bounds its support, and one expects an equidistribution statement for coprime $k$.

**Multi-point convexity.** Convexity over $n$-point combinations $\sum a_i x_i$ with $a_i = k_i/q$ should yield a defect governed by the lattice generated by the $k_i$ modulo $q$, i.e. by $\gcd(k_1,\dots,k_n,q)$, generalizing Theorem 6.8.

**Local versions.** Replace global convexity with convexity on a ball of radius $R$ around a checkpoint, and track how the covering radius interacts with the boundary. The expected form is a defect $2Lr$ plus a boundary term of order $r/R$.

**Empirical spectroscopy.** Theorems 6.10 and 6.11 suggest a measurement program: probe a deployed quantized model at interpolation weights of varying denominator, plot the observed defects, and read off the effective mesh and the effective reduced denominator. Deviations from the predicted arithmetic progression would quantify departures from uniform quantization.

---

## 12. Conclusion

Quantizing a neural network onto a modular lattice grid preserves the global convexity invariants of its loss landscape, quantitatively and in every reasonable sense: the convexity inequality holds up to $2Lr$, the curvature modulus is unchanged, the optimum value moves by at most $Lr$, the optimizer by at most $\sqrt{2Lr/\mu}$, and sublevel sets are sandwiched between convex sets at level distance $Lr$. The transfer is two-sided, and along a refining tower it inverts: exact convexity of a continuous landscape is certifiable from finite quantized measurements.

The constant $2Lr$ is exactly optimal — both for arbitrary radius-$r$ quantizers and for honest nearest-point rounding — and beneath it lies a finer, arithmetic law. At a rational interpolation weight $k/q$ the sharp defect is $\big(1 - \gcd(k,q)/q\big)L\delta$, the achievable defects form the complete arithmetic progression $\frac{\delta}{q}\{0,\dots,q-1\}$, and that spectrum determines both the mesh of the quantizer and the reduced denominator of the weight. Codebooks are torsion subgroups of the weight torus, they nest along divisibility with exact index, they split by the Chinese Remainder Theorem at coprime precisions, and they are dense in the limit.

The loss of convexity under quantization is thus not a metric quantity but an arithmetic one. How much convexity you pay depends on the denominator you pay it in.
