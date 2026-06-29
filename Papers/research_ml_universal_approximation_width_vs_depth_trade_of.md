# A Two-Sided Depth–Width Separation for ReLU Networks via the Tent Map

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Machine Learning / Approximation Theory)

## Abstract

We give a complete, two-sided depth–width separation for rectified-linear-unit (ReLU) neural networks, built around the iterated tent map. On the one hand (the *shallow lower bound*), the $k$-fold tent $\mathrm{tent}^{[k]}$ oscillates $2^k$ times on $[0,1]$, and any single-hidden-layer ReLU network that approximates it to accuracy $\varepsilon < \tfrac12$ at the dyadic grid, under a per-neuron weight cap $A>0$, must have width at least $2^k(1-2\varepsilon)/A$ — exponential in the depth $k$. On the other hand (the *deep upper bound*), the tent map is realized *exactly* by a two-neuron ReLU block via the identity $|y| = \mathrm{relu}(y) + \mathrm{relu}(-y)$, so $\mathrm{tent}^{[k]}$ is realized exactly by $k$ stacked copies of that block, a depth-$k$, constant-width-$2$ network of total size $2k$. Hence the deep network's size equals $2\log_2(2^k)$ — logarithmic in the oscillation count it produces — while the matching shallow width is exponential. Combining the two bounds yields the separation: a single explicit target is realized by a deep network of size $2k$ yet forces shallow width $\ge 2^k(1-2\varepsilon)/A$. The gap between the two is unbounded: for every ratio $R$ there is a depth at which the forced shallow width exceeds $R$ times the deep size. The central invariant throughout is discrete total variation, a conserved additive measure of complexity that depth mints geometrically and shallow width can purchase only in proportion to its $L^1$ weight mass. All results are stated with explicit constants and have been formally verified.

## 1. Introduction

A persistent puzzle in the theory of deep learning is why depth helps. Classical universal approximation theorems show that a single hidden layer of sufficient width can approximate any continuous function on a compact set, so depth is not necessary for *expressivity in principle*. The interesting question is one of *efficiency*: are there functions that deep networks represent with far fewer parameters than any shallow network? A positive answer — a **depth–width separation** — was given in influential form by Telgarsky, who used the iterated triangle (tent) map to exhibit functions that deep networks compute compactly but that shallow networks require exponentially many units to approximate.

This paper presents a self-contained, two-sided, constant-explicit version of that separation, organized around a single conserved quantity: discrete total variation. The contribution is twofold.

1. **The shallow lower bound** (Section 4). Total variation can only drop by $2\varepsilon$ per node under an $\varepsilon$-approximation, and a shallow ReLU network's total variation over any grid is bounded by its $L^1$ weight mass $\sum_j |a_j|$. Chaining these gives weight mass $\ge 2^k(1-2\varepsilon)$ and, under a per-neuron cap $A$, width $\ge 2^k(1-2\varepsilon)/A$.

2. **The deep upper bound** (Section 5). The tent map equals a two-neuron ReLU block *exactly* — not merely in a limit — via $|y| = \mathrm{relu}(y) + \mathrm{relu}(-y)$. Stacking $k$ such blocks realizes $\mathrm{tent}^{[k]}$ exactly with total size $2k$, i.e. $2\log_2(2^k)$ neurons for $2^k$ oscillations.

Section 6 combines the two into a single separation statement and shows the gap is unbounded. Section 7 gives algorithms; Section 8 discusses applications and limitations; Section 9 lists future directions.

The decisive methodological choice is to replace analytic crossing-counting (intermediate value theorem) with an algebraic, additive *total-variation accounting*. This avoids continuity machinery entirely, makes the deep realization *exact*, and yields weight-magnitude-sensitive bounds with explicit constants.

## 2. Preliminaries and Definitions

Throughout, $\mathrm{relu}(y) = \max(y, 0)$.

### 2.1 The tent map and its iterates

**Definition 2.1 (Tent map).** The tent map on $[0,1]$ is
$$\mathrm{tent}(x) = 1 - |2x - 1|.$$
It satisfies $\mathrm{tent}(0)=0$, $\mathrm{tent}(\tfrac12)=1$, $\mathrm{tent}(1)=0$, and maps $[0,1]$ onto $[0,1]$.

We write $\mathrm{tent}^{[k]}$ for the $k$-fold composition $\mathrm{tent}\circ\cdots\circ\mathrm{tent}$ ($k$ times), with $\mathrm{tent}^{[0]} = \mathrm{id}$.

### 2.2 Discrete total variation

**Definition 2.2 (Discrete total variation).** For $g:\mathbb{R}\to\mathbb{R}$ and $k\in\mathbb{N}$, the discrete total variation over the $2^k$-cell dyadic grid of $[0,1]$ is
$$\mathrm{TV}_k(g) = \sum_{i=0}^{2^k-1}\left|\,g\!\left(\frac{i+1}{2^k}\right) - g\!\left(\frac{i}{2^k}\right)\right|.$$

### 2.3 Shallow networks

**Definition 2.3 (Shallow network).** A single-hidden-layer ("shallow") ReLU network of width $w$ with output weights $a:\{0,\dots,w-1\}\to\mathbb{R}$, thresholds $t:\{0,\dots,w-1\}\to\mathbb{R}$, and output bias $c\in\mathbb{R}$ computes
$$\mathrm{shallow}_{w,a,t,c}(x) = c + \sum_{j=0}^{w-1} a_j\,\mathrm{relu}(x - t_j).$$
Its width is $w$ and its $L^1$ weight mass is $\sum_{j} |a_j|$.

### 2.4 Deep networks as block compositions

**Definition 2.4 (Scalar ReLU block).** A scalar ReLU block $B$ consists of a neuron count $m\in\mathbb{N}$, an output bias $c\in\mathbb{R}$, output weights $a:\{0,\dots,m-1\}\to\mathbb{R}$, input weights $w:\{0,\dots,m-1\}\to\mathbb{R}$, and thresholds $t:\{0,\dots,m-1\}\to\mathbb{R}$. It computes
$$B(x) = c + \sum_{j=0}^{m-1} a_j\,\mathrm{relu}(w_j x - t_j),$$
and has size $\mathrm{size}(B) = m$.

**Definition 2.5 (Deep network evaluation and size).** A deep network is a finite list of blocks $L = [B_1, B_2, \dots, B_n]$, evaluated by composition:
$$\mathrm{evalNet}([\,], x) = x, \qquad \mathrm{evalNet}(B :: L, x) = B(\mathrm{evalNet}(L, x)).$$
Its total size is $\mathrm{netSize}(L) = \sum_{i} \mathrm{size}(B_i)$.

**Definition 2.6 (Tent block and deep tent).** The *tent block* is the two-neuron block
$$\mathrm{tentBlock} = \bigl(m=2,\; c=1,\; a=(-1,-1),\; w=(2,-2),\; t=(1,-1)\bigr),$$
so $\mathrm{tentBlock}(x) = 1 - \mathrm{relu}(2x-1) - \mathrm{relu}(-2x+1)$. The *deep tent of depth $k$* is the $k$-fold stack $\mathrm{deepTent}(k) = [\underbrace{\mathrm{tentBlock}, \dots, \mathrm{tentBlock}}_{k}]$.

## 3. The Conserved Currency: Total Variation of the Deep Tent

The engine of the entire separation is that $\mathrm{tent}^{[k]}$ is maximally oscillatory on the dyadic grid.

**Lemma 3.1 (Dyadic alternation).** For all $k, j\in\mathbb{N}$ with $j\le 2^k$,
$$\mathrm{tent}^{[k]}\!\left(\frac{j}{2^k}\right) = (j \bmod 2).$$

*Proof sketch.* Induct on $k$. The base case $k=0$ is immediate ($\mathrm{tent}^{[0]}=\mathrm{id}$ and $j\in\{0,1\}$). For the inductive step, split on whether $j\le 2^k$ or $j>2^k$. In the first region, one application of the tent halves the argument and the inductive hypothesis applies after the algebraic simplification $\mathrm{tent}(j/2^{k+1}) = j/2^k$ (valid for $j\le 2^k$, where $2j/2^{k+1}-1 \le 0$). In the second region, write $j = 2^k + m$ with $m\le 2^k$; then $\mathrm{tent}(j/2^{k+1}) = (2^k - m)/2^k$, and the inductive hypothesis at $2^k - m$ together with the parity identity $(2^k - m)\bmod 2 = j \bmod 2$ closes the case. $\square$

**Lemma 3.2 (Consecutive differences).** For $i + 1 \le 2^k$,
$$\left|\mathrm{tent}^{[k]}\!\left(\frac{i+1}{2^k}\right) - \mathrm{tent}^{[k]}\!\left(\frac{i}{2^k}\right)\right| = 1.$$

*Proof sketch.* By Lemma 3.1 both values are $(i+1)\bmod 2$ and $i\bmod 2$, which always differ by exactly $1$. $\square$

**Theorem 3.3 (Total variation of the deep tent).** For all $k$,
$$\mathrm{TV}_k\!\left(\mathrm{tent}^{[k]}\right) = 2^k.$$

*Proof sketch.* The sum in Definition 2.2 has $2^k$ terms, each equal to $1$ by Lemma 3.2. $\square$

Total variation is the *conserved, additive* quantity at the heart of the argument: depth produces $2^k$ units of it from $\mathrm{tent}^{[k]}$, and we will show shallow networks must pay for every unit.

## 4. The Shallow Lower Bound

We show that any shallow $\varepsilon$-approximant inherits most of the deep tent's total variation, and that a shallow network's total variation is capped by its weight mass.

**Lemma 4.1 (Ramp difference bound).** For thresholds $t$ and $a\le b$,
$$0 \le \mathrm{relu}(b - t) - \mathrm{relu}(a - t) \le b - a.$$

*Proof sketch.* The map $y\mapsto\mathrm{relu}(y-t)$ is non-decreasing and $1$-Lipschitz; a four-way case split on the signs of $a-t$ and $b-t$ verifies both inequalities. $\square$

**Theorem 4.2 (Shallow total variation $\le$ weight mass).** For every $k$, width $w$, and shallow network parameters $a,t,c$,
$$\mathrm{TV}_k\!\left(\mathrm{shallow}_{w,a,t,c}\right) \le \sum_{j=0}^{w-1} |a_j|.$$

*Proof sketch.* Across each cell, the bias $c$ cancels and the network's increment is $\sum_j a_j\bigl(\mathrm{relu}(\cdot)-\mathrm{relu}(\cdot)\bigr)$. By the triangle inequality and Lemma 4.1, the absolute increment over a cell of width $\Delta = 2^{-k}$ is at most $\sum_j |a_j|\,\Delta$. Summing over the $2^k$ cells gives $\sum_j |a_j|\cdot 2^k\cdot 2^{-k} = \sum_j |a_j|$. $\square$

**Theorem 4.3 (Approximants inherit total variation).** Let $g$ approximate $\mathrm{tent}^{[k]}$ to accuracy $\varepsilon$ at all dyadic nodes: $\bigl|\mathrm{tent}^{[k]}(i/2^k) - g(i/2^k)\bigr|\le\varepsilon$ for all $i\le 2^k$. Then
$$2^k(1 - 2\varepsilon) \le \mathrm{TV}_k(g).$$

*Proof sketch.* For each cell, the reverse triangle inequality gives
$$|g(\tfrac{i+1}{2^k}) - g(\tfrac{i}{2^k})| \ge |\mathrm{tent}^{[k]}(\tfrac{i+1}{2^k}) - \mathrm{tent}^{[k]}(\tfrac{i}{2^k})| - 2\varepsilon = 1 - 2\varepsilon,$$
using Lemma 3.2. Summing over the $2^k$ cells gives the bound. $\square$

**Theorem 4.4 (Depth–width separation, weight form).** Any shallow network approximating $\mathrm{tent}^{[k]}$ to accuracy $\varepsilon < \tfrac12$ at all dyadic nodes has $L^1$ weight mass
$$\sum_{j=0}^{w-1} |a_j| \ge 2^k(1 - 2\varepsilon).$$

*Proof.* Chain Theorem 4.3 (with $g = \mathrm{shallow}_{w,a,t,c}$) and Theorem 4.2. $\square$

**Theorem 4.5 (Depth–width separation, width form).** If additionally every neuron weight satisfies $|a_j| \le A$ for some $A > 0$, then approximating $\mathrm{tent}^{[k]}$ to accuracy $\varepsilon < \tfrac12$ forces width
$$w \ge \frac{2^k(1 - 2\varepsilon)}{A}.$$

*Proof.* From Theorem 4.4, $2^k(1-2\varepsilon)\le\sum_j|a_j|\le wA$; divide by $A$. $\square$

The bound degrades gracefully as $\varepsilon\to\tfrac12$ (the floor $2^k(1-2\varepsilon)\to0$), which is correct: a constant $\tfrac12$ trivially "approximates" within $\tfrac12$. The guard $\varepsilon<\tfrac12$ keeps the floor positive, and the per-neuron cap $A$ is necessary — without it, infinite-precision weights evade any width bound.

## 5. The Deep Upper Bound

We now show the deep side is genuinely cheap, by an *exact* algebraic realization.

**Theorem 5.1 (Tent equals a two-neuron block).** For all $x$,
$$\mathrm{tentBlock}(x) = \mathrm{tent}(x).$$

*Proof sketch.* Expand the block: $\mathrm{tentBlock}(x) = 1 - \mathrm{relu}(2x-1) - \mathrm{relu}(-2x+1)$. The key identity is $|y| = \mathrm{relu}(y) + \mathrm{relu}(-y)$: setting $y = 2x-1$ gives $\mathrm{relu}(2x-1) + \mathrm{relu}(1-2x) = |2x-1|$, so the block equals $1 - |2x-1| = \mathrm{tent}(x)$. The identity is purely algebraic, with no limiting process. $\square$

**Theorem 5.2 (Exact deep realization).** For all $k$,
$$\mathrm{evalNet}\bigl(\mathrm{deepTent}(k)\bigr) = \mathrm{tent}^{[k]} \quad\text{as functions.}$$

*Proof sketch.* Induct on $k$. The base case is the identity ($\mathrm{evalNet}([\,]) = \mathrm{id} = \mathrm{tent}^{[0]}$). For the step, $\mathrm{evalNet}(\mathrm{deepTent}(k+1), x) = \mathrm{tentBlock}(\mathrm{evalNet}(\mathrm{deepTent}(k), x))$; apply the inductive hypothesis and Theorem 5.1, and recognize $\mathrm{tent}\circ\mathrm{tent}^{[k]} = \mathrm{tent}^{[k+1]}$ via $\mathrm{iterate\_succ}'$. The realization is *exact*, not approximate. $\square$

**Theorem 5.3 (Linear deep size).** $\mathrm{netSize}(\mathrm{deepTent}(k)) = 2k$.

*Proof sketch.* The list is $k$ copies of a size-$2$ block; the sum of sizes is $2k$. $\square$

**Corollary 5.4 (Deep total variation).** $\mathrm{TV}_k\bigl(\mathrm{evalNet}(\mathrm{deepTent}(k))\bigr) = 2^k.$

*Proof.* Rewrite by Theorem 5.2 and apply Theorem 3.3. $\square$

**Theorem 5.5 (Logarithmic-size law).** The deep network realizing $2^k$ oscillations uses
$$\mathrm{netSize}(\mathrm{deepTent}(k)) = 2\log_2\!\left(2^k\right) = 2k$$
neurons: size grows logarithmically in the oscillation count.

*Proof.* $\log_2(2^k) = k$ (by $\mathrm{Nat.log\_pow}$), and the result follows from Theorem 5.3. $\square$

**Theorem 5.6 (Strict numerical gap).** For all $k\ge 3$,
$$2k < 2^k.$$

*Proof sketch.* Induction from the base case $k=3$ ($6 < 8$); for $k\ge 3$, $2^{k+1} = 2\cdot 2^k > 2\cdot 2k > 2(k+1)$. For $k=0,1,2$ one has equality up to $6 < 8$, so the strict gap is asymptotic and the dramatic separation is guarded by $k\ge 3$. $\square$

## 6. The Two-Sided Separation and Its Unbounded Gap

**Theorem 6.1 (Two-sided depth–width separation).** Fix $k$, a shallow width $w$ with parameters $a,t,c$, an accuracy $\varepsilon$, and a weight cap $A>0$ with $|a_j|\le A$ for all $j$. Suppose the shallow network approximates the deep tent at all dyadic nodes:
$$\left|\mathrm{evalNet}(\mathrm{deepTent}(k))\!\left(\tfrac{i}{2^k}\right) - \mathrm{shallow}_{w,a,t,c}\!\left(\tfrac{i}{2^k}\right)\right| \le \varepsilon \quad \text{for all } i\le 2^k.$$
Then both
$$\mathrm{netSize}(\mathrm{deepTent}(k)) = 2k \qquad\text{and}\qquad \frac{2^k(1-2\varepsilon)}{A} \le w.$$

*Proof.* The size equality is Theorem 5.3. For the width bound, rewrite the hypothesis via the exact realization (Theorem 5.2) so that it reads as an approximation of $\mathrm{tent}^{[k]}$, then apply Theorem 4.5. $\square$

Theorem 6.1 is the heart of the paper: a *single explicit target* is realized by a deep network of total size $2k$ (linear in depth) yet forces *any* shallow $\varepsilon$-approximant ($\varepsilon<\tfrac12$, weight cap $A$) to width $\ge 2^k(1-2\varepsilon)/A$ (exponential in depth).

**Theorem 6.2 (Unbounded gap).** For every ratio $R$ there exists a depth $k$ at which the forced shallow width exceeds $R$ times the deep size; equivalently,
$$\frac{2^k(1-2\varepsilon)/A}{2k} \xrightarrow[k\to\infty]{} \infty.$$

*Proof sketch.* The numerator grows like $2^k$ while the denominator grows like $k$; since $2^k$ eventually dominates any polynomial (in particular $k$, via the auxiliary bounds $k < 2^k$ and $k^2 \le 2^k$ for large $k$), the ratio diverges. Hence for any $R$ there is a $k$ with $2^k(1-2\varepsilon)/A > R\cdot 2k$. $\square$

The depth advantage is therefore not bounded by any constant: it is unbounded.

## 7. Algorithms

We summarize the constructive content as algorithms (Python implementations in the accompanying demo).

**Algorithm A (Deep tent evaluation).** Given depth $k$ and input $x$, apply the tent map $k$ times. Complexity $O(k)$ arithmetic operations; the realized function has $2^k$ pieces. This is the explicit deep network of Definition 2.6.

**Algorithm B (Discrete total-variation meter).** Given a function $g$ and resolution $k$, evaluate $g$ at the $2^k+1$ dyadic nodes and sum the absolute consecutive differences. Complexity $O(2^k)$ evaluations. Used to certify both $\mathrm{TV}_k(\mathrm{tent}^{[k]}) = 2^k$ and the shallow upper bound $\mathrm{TV}_k(\mathrm{shallow})\le\sum_j|a_j|$.

**Algorithm C (Shallow width lower bound).** Given depth $k$, accuracy $\varepsilon<\tfrac12$, and weight cap $A$, return $\lceil 2^k(1-2\varepsilon)/A\rceil$ as the minimum shallow width forced by Theorem 4.5. Constant time.

## 8. Applications and Discussion

**Why depth helps, mechanistically.** The separation isolates the mechanism behind the empirical success of depth: *composition multiplies complexity*. Each tent block contributes only two neurons but doubles the oscillation count; total variation, the conserved currency, grows geometrically with depth and only linearly with shallow weight mass. The same accounting principle applies whenever a problem possesses a complexity measure that compounds under composition.

**Exactness vs. approximation.** Because the deep realization is exact (Theorem 5.2), there is no approximation error on the deep side; the entire tolerance $\varepsilon$ is granted to the shallow competitor, which still cannot avoid the exponential wall. This asymmetry strengthens the separation.

**Scope and limitations.** The formalism is scalar (one input and one output per block), matching the one-dimensional tent. Extending the exact realization to $f:[-1,1]^n\to\mathbb{R}$ requires vector-valued blocks (input $\{0,\dots,d-1\}\to\mathbb{R}$) and a coordinatewise composition lemma; this is the route to the width-$(n+4)$, depth-$O(\log(1/\varepsilon))$ statements for continuous functions on $[-1,1]^n$. The size measure counts hidden neurons, the standard notion for the trade-off. The strict numerical gap $2k<2^k$ holds for $k\ge3$, so the dramatic separation is asymptotic.

## 9. Future Directions

- **Multi-input deep efficiency on $[-1,1]^n$.** A continuous $f:[-1,1]^n\to\mathbb{R}$ should be $\varepsilon$-approximable by a ReLU network of width $n+4$ and depth $O(\log(1/\varepsilon))$ per coordinate, applying the deep tent coordinatewise inside a Kolmogorov–Arnold-style outer sum. The exact scalar realization already gives a two-neuron oscillator; a width-$(n+4)$ carry-register architecture can refine each coordinate to dyadic resolution $2^{-k}$ using depth $k$, decoupling depth (resolution) from width (dimension). Only a vector-valued block and a coordinatewise composition lemma are missing.

- **Sharpness of the $2^k(1-2\varepsilon)/A$ shallow bound.** There should be a shallow network of width $\Theta(2^k)$ matching $\mathrm{tent}^{[k]}$ to any $\varepsilon>0$, so the lower bound is tight up to the constant $(1-2\varepsilon)/A$. A $2n$-ramp interpolant with $n=2^k$ nodes reproduces the piecewise-linear $\mathrm{tent}^{[k]}$ exactly; instantiating an exact-reproduction interpolant on the dyadic grid is the remaining step.

- **Depth–accuracy law for Lipschitz targets.** For $L$-Lipschitz $f$ on $[0,1]$, a depth-$O(\log(1/\varepsilon))$, constant-width network combining the deep tent (address bits) with a readout should achieve uniform error $\varepsilon$, beating the shallow width $O(L/\varepsilon)$. The deep tent computes the leading binary digits of the input via its dyadic alternation, turning function approximation into table lookup whose depth scales with bit-precision $\log(1/\varepsilon)$.

## 10. Conclusion

We have given a complete, two-sided, constant-explicit depth–width separation for ReLU networks. The iterated tent map oscillates $2^k$ times, forcing exponential shallow width $\ge 2^k(1-2\varepsilon)/A$, yet is realized exactly by a deep network of size $2k$ — logarithmic in the oscillation count. The gap is unbounded. The unifying invariant is discrete total variation: depth mints it geometrically, shallow width buys it linearly. This is the mathematical core of why depth is leverage, not merely convenience.
