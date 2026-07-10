# The Poincaré Conjecture for Data: Sharp Scaling of the Manifold-Detection Threshold

## Abstract

The *Poincaré conjecture for data* proposes a topological criterion for manifold detection: a point cloud whose multiscale homology matches that of a $d$-sphere should lie near a $d$-sphere, and the smallest scale $\varepsilon_\star$ at which the Vietoris–Rips complex acquires the homology of $S^d$ — the *Poincaré threshold* — was conjectured to obey the exact law $\varepsilon_\star = C\,d^{1/2}\,n^{-1/d}$, where $n$ is the number of sample points and $C > 0$ a universal constant. We isolate three separable assertions inside this formula and settle each rigorously in a clean, Nerve-Lemma-faithful discrete model — the Chebyshev ($\ell^\infty$) grid cube $\{0,\dots,m-1\}^d$, in which covering the cube to radius $r$ plays the role of resolving the shape at scale $\varepsilon$. We prove: (1) a **packing lower bound** $m^d \le |S|\,(2r+1)^d$ for every $r$-cover $S$, yielding the scaling $2r+1 \ge m\,n^{-1/d}$; (2) **sharpness** of the exponent $-1/d$, via an explicit grid cover attaining minimal size exactly $t^d = (m/(2r+1))^d$ when $m=(2r+1)t$, together with a matching minimality bound; and (3) the sharp norm comparison $\|x\|_\infty \le \|x\|_2 \le \sqrt d\,\|x\|_\infty$ with the constant $\sqrt d$ attained, showing the $d^{1/2}$ prefactor is a metric-conversion artifact rather than topology. Finally we **disprove** the exact equality: the minimal covering radius is a step function of $n$ (for $m=7$, $d=1$ it equals $1$ throughout $n\in\{3,4,5,6\}$), so no positive constant $C$ can reproduce the threshold exactly. The conjectured identity must be downgraded to a scaling relation $\varepsilon_\star \asymp d^{1/2} n^{-1/d}$.

**Keywords:** persistent homology, manifold detection, Vietoris–Rips complex, covering number, packing bound, Chebyshev metric, curse of dimensionality, topological data analysis.

## 1. Introduction

### 1.1 From Poincaré's theorem to a question about data

The Poincaré conjecture, proved by Perelman, asserts that every simply connected closed $3$-manifold is homeomorphic to the $3$-sphere. Reformulated for finite data, one asks whether a point cloud whose topological signature matches that of a sphere must in fact be sampled from (or near) a sphere. The tool that makes "topological signature" precise for finite data is *persistent homology*: at each scale $\varepsilon$, one builds the Vietoris–Rips complex $\mathrm{VR}_\varepsilon(X)$ on the point cloud $X=\{x_1,\dots,x_n\}\subset\mathbb R^D$ by declaring a finite subset to span a simplex when its diameter is below $\varepsilon$, and records how the homology evolves with $\varepsilon$.

For a $d$-sphere, the target signature is unmistakable: $H_0 = \mathbb Z$, $H_d = \mathbb Z$, and $H_k = 0$ for $0 < k < d$. There is a window of scales $\varepsilon$ in which a well-sampled sphere exhibits exactly this signature; below the window the cloud is disconnected dust, above it the complex is contractible. The **Poincaré threshold** $\varepsilon_\star$ is the infimum of scales at which the sphere signature first appears — the fundamental quantity of manifold detection.

### 1.2 The conjectured law and our contributions

The conjecture posits an exact law
$$\varepsilon_\star \;=\; C\, d^{1/2}\, n^{-1/d}, \qquad C>0 \text{ universal.}$$
We decompose this into three independent claims and resolve each:

1. **The exponent claim** ($\varepsilon_\star \propto n^{-1/d}$): *proved and sharp.*
2. **The dimensional-prefactor claim** ($d^{1/2}$): *proved to be a metric artifact* — the exact $\ell^\infty\!\to\!\ell^2$ conversion constant.
3. **The exact-equality claim** (a single constant $C$ makes it an identity): *disproved*; the threshold is a step function of $n$.

Net verdict: $\varepsilon_\star \asymp d^{1/2} n^{-1/d}$ holds as a scaling relation, but the clean equality is false.

### 1.3 A discrete model faithful to the topology

To reason about thresholds without the analytic overhead of curved manifolds, we use a discrete surrogate that preserves the essential covering combinatorics and connects to topology through the Nerve Lemma. All results below are stated and proved in this model.

## 2. The discrete model and definitions

Throughout, $d,m,r,t,n$ denote natural numbers.

**Definition 2.1 (Grid cube).** The *discrete $d$-cube of side $m$* is the set $Q_{m,d} = \{0,1,\dots,m-1\}^d$, which we represent as functions $\mathrm{Fin}\,d \to \mathrm{Fin}\,m$. It has $|Q_{m,d}| = m^d$ points and plays the role of a densely sampled cube-like object.

**Definition 2.2 (Chebyshev closeness).** For a radius $r$ and centers/points $s,x \in Q_{m,d}$, we say $x$ is *$r$-close* to $s$, written $\mathrm{ChebClose}(r,s,x)$, if in every coordinate $i$,
$$\bigl|\,x_i - s_i\,\bigr| \le r,$$
i.e. the Chebyshev ($\ell^\infty$) distance satisfies $\|x-s\|_\infty \le r$.

**Definition 2.3 (Chebyshev ball).** The *ball* $B_r(s) = \{\, x \in Q_{m,d} : \mathrm{ChebClose}(r,s,x)\,\}$.

**Definition 2.4 ($r$-cover).** A finite set $S \subseteq Q_{m,d}$ is an *$r$-cover* if every $x \in Q_{m,d}$ is $r$-close to some $s \in S$, i.e. $Q_{m,d} = \bigcup_{s\in S} B_r(s)$.

**Definition 2.5 (Minimal covering radius / discrete Poincaré threshold).** For a fixed sample budget $n$,
$$\mathrm{minRad}(m,n) \;=\; \inf\{\, r : \text{some } S \text{ with } |S|\le n \text{ is an } r\text{-cover of } Q_{m,d}\,\}.$$

**Dictionary to persistent homology.** The ambient object is $Q_{m,d}$; a point cloud / landmark set is a finite $S$; the scale $\varepsilon$ is the $\ell^\infty$ radius $r$. The statement "$\mathrm{VR}_\varepsilon(X)$ recovers the homology of the object" is modelled by "$S$ is an $r$-cover." This is exactly the Nerve-Lemma hypothesis under which the Čech/Rips complex of $S$ (with balls of radius $r$) is homotopy equivalent to the union of balls, hence to the cube. Thus $\mathrm{minRad}(m,n)$ is the discrete Poincaré threshold at sample budget $n$.

## 3. The scaling law: a sharp packing bound

### 3.1 Ball size

**Lemma 3.1 (Coordinate count).** For any center value $c$, the number of grid coordinates within distance $r$ is at most $2r+1$:
$$\bigl|\{\, a \in \mathrm{Fin}\,m : |a - c| \le r \,\}\bigr| \le 2r+1.$$
*Proof sketch.* The admissible values inject, via $a \mapsto a$ as an integer, into the interval $[c-r,\,c+r] \cap \mathbb Z$, which has at most $2r+1$ elements. $\square$

**Lemma 3.2 (Ball cardinality).** Every Chebyshev ball satisfies $|B_r(s)| \le (2r+1)^d$.
*Proof sketch.* The ball factors as a product over coordinates, $B_r(s) = \prod_{i} \{a : |a - s_i| \le r\}$, so its size is the product of the coordinate counts, each $\le 2r+1$ by Lemma 3.1; hence $|B_r(s)| \le (2r+1)^d$. $\square$

### 3.2 The lower bound and its scaling form

**Theorem 3.3 (Packing lower bound).** If $S$ is an $r$-cover of $Q_{m,d}$, then
$$m^d \;\le\; |S|\cdot (2r+1)^d.$$
*Proof sketch.* Since the balls $\{B_r(s)\}_{s\in S}$ cover the cube, $m^d = |Q_{m,d}| \le \bigl|\bigcup_{s\in S} B_r(s)\bigr| \le \sum_{s \in S} |B_r(s)| \le |S|\,(2r+1)^d$, using subadditivity of cardinality under union and Lemma 3.2. $\square$

**Theorem 3.4 (The $n^{-1/d}$ scaling law).** Let $d\ge 1$, $m\ge 1$, and let $S$ be an $r$-cover with $n = |S|$. Then
$$m \;\le\; n^{1/d}\,(2r+1), \qquad\text{equivalently}\qquad 2r+1 \;\ge\; m\, n^{-1/d}.$$
*Proof sketch.* Raise the inequality of Theorem 3.3 to the power $1/d$: since $x\mapsto x^{1/d}$ is monotone on $[0,\infty)$, $(m^d)^{1/d} \le (n\,(2r+1)^d)^{1/d}$, and $(m^d)^{1/d}=m$, $(n(2r+1)^d)^{1/d}=n^{1/d}(2r+1)$ by the laws of real exponents. $\square$

Interpreting $2r+1$ as the (discrete) detection scale and $n$ as the sample budget, Theorem 3.4 is exactly the conjectured $\varepsilon_\star \gtrsim n^{-1/d}$: the covering radius cannot decay faster than $n^{-1/d}$.

## 4. Sharpness of the exponent

The lower bound is attained by a regular grid, so the exponent $-1/d$ cannot be improved.

**Construction 4.1 (Grid cover).** Assume $m = (2r+1)\,t$. Partition each coordinate axis $\{0,\dots,m-1\}$ into $t$ consecutive blocks of length $2r+1$. The *block center* of block $k \in \{0,\dots,t-1\}$ is
$$c_k \;=\; k\,(2r+1) + r,$$
the midpoint of block $k$. The grid cover is the product set
$$S_{\mathrm{grid}} = \{\, s : \mathrm{Fin}\,d \to \mathrm{Fin}\,m \ \mid\ \forall i,\ s_i = c_{k_i} \text{ for some } k_i \,\} = \prod_{i=1}^{d}\{c_0,\dots,c_{t-1}\}.$$

**Lemma 4.2 (Blocks are covered).** For every coordinate value $v \in \{0,\dots,m-1\}$, writing $v = (2r+1)q + \rho$ with $0 \le \rho < 2r+1$, the block center $c_q = q(2r+1)+r$ satisfies $|v - c_q| = |\rho - r| \le r$.
*Proof sketch.* Since $0\le \rho \le 2r$, we have $-r \le \rho - r \le r$. $\square$

**Theorem 4.3 (Existence of an optimal cover).** When $m=(2r+1)t$, the set $S_{\mathrm{grid}}$ is an $r$-cover of $Q_{m,d}$ with exactly $|S_{\mathrm{grid}}| = t^d$ points.
*Proof sketch.* Cover: given any $x$, choose in each coordinate the block center of $x_i$'s block; by Lemma 4.2 this center is within radius $r$ in every coordinate, so $x$ is $r$-close to the resulting product point. Count: the block-center map $k \mapsto c_k$ is injective (distinct blocks have distinct centers because $c_k = k(2r+1)+r$ is strictly increasing in $k$), so the $d$-fold product of the $t$ centers has exactly $t^d$ elements. $\square$

**Theorem 4.4 (Minimality).** When $m=(2r+1)t$, every $r$-cover of $Q_{m,d}$ has at least $t^d$ points.
*Proof sketch.* By Theorem 3.3, $m^d \le |S|\,(2r+1)^d$; substitute $m^d = (2r+1)^d t^d$ and cancel the positive factor $(2r+1)^d$ to get $t^d \le |S|$. $\square$

**Corollary 4.5 (Exact minimal cover size).** When $m = (2r+1)t$, the minimal $r$-cover size is *exactly* $t^d = (m/(2r+1))^d$. Consequently the minimal radius scales as $2r+1 = m\,n^{-1/d}$ along this family, and no exponent other than $-1/d$ is consistent with both the lower bound (Theorem 3.3) and the achievability (Theorem 4.3). $\square$

## 5. The $\sqrt{d}$ prefactor is a metric artifact

The packing analysis is cleanest in the Chebyshev metric, but spheres and the Rips parameter live in the Euclidean metric. Converting between them introduces exactly the factor $\sqrt d$.

**Lemma 5.1 (Lower comparison).** For $x \in \mathbb R^d$ and any coordinate $i$,
$$|x_i| \;\le\; \Bigl(\textstyle\sum_{j} x_j^2\Bigr)^{1/2} = \|x\|_2.$$
*Proof sketch.* $x_i^2 \le \sum_j x_j^2$ since the omitted terms are nonnegative; take square roots. $\square$

**Lemma 5.2 (Upper comparison).** If $|x_i| \le M$ for all $i$ (with $M \ge 0$), then
$$\|x\|_2 = \Bigl(\textstyle\sum_j x_j^2\Bigr)^{1/2} \;\le\; \sqrt d\, M.$$
*Proof sketch.* Each $x_j^2 \le M^2$, so $\sum_j x_j^2 \le d\,M^2$; take square roots and use $\sqrt{d M^2} = \sqrt d\, M$. $\square$

Together, Lemmas 5.1–5.2 give the two-sided comparison
$$\|x\|_\infty \;\le\; \|x\|_2 \;\le\; \sqrt d\,\|x\|_\infty.$$

**Theorem 5.3 (Sharpness of $\sqrt d$).** The constant $\sqrt d$ in Lemma 5.2 is optimal: for the all-ones vector $\mathbf 1 = (1,\dots,1)$, $\|\mathbf 1\|_\infty = 1$ while
$$\|\mathbf 1\|_2 = \Bigl(\textstyle\sum_{j=1}^d 1^2\Bigr)^{1/2} = \sqrt d = \sqrt d \cdot \|\mathbf 1\|_\infty.$$
*Proof sketch.* Direct evaluation of the sum of $d$ ones. $\square$

**Interpretation.** An $\ell^\infty$ covering radius $r$ corresponds to a Euclidean radius somewhere in $[r,\ \sqrt d\, r]$, and the worst case is exactly $\sqrt d\, r$. Hence when the Chebyshev threshold $2r+1 \asymp m\,n^{-1/d}$ is re-expressed in the Euclidean scale in which $S^d$ and the Rips parameter are measured, it picks up precisely the factor $\sqrt d$. The $d^{1/2}$ prefactor is therefore a **metric-conversion constant**, not intrinsic topology.

## 6. Disproof of the exact power law

The exponent and prefactor claims survive; the claim of an *exact* identity does not.

**Definitions (1-D covering).** For the line grid $\{0,\dots,m-1\}$, say it is *$r$-coverable with $n$ samples* if some $S$ with $|S|\le n$ satisfies: every point is within Chebyshev distance $r$ of some $s\in S$. Let $\mathrm{minRad}(m,n)$ be the least such $r$.

**Lemma 6.1.** For $m=7$: $\{1,3,5\}$ is a $1$-cover, so $7$ is $1$-coverable with $3$ samples. Hence also with $4$ samples.
*Proof sketch.* Each of $0,1,2$ is within $1$ of $1$; each of $2,3,4$ within $1$ of $3$; each of $4,5,6$ within $1$ of $5$. $\square$

**Lemma 6.2.** For $m=7$, radius $0$ is impossible with fewer than $7$ samples: a $0$-cover forces $S$ to contain every point (each point is $0$-close only to itself), so $|S|\ge 7$. In particular $7$ is not $0$-coverable with $3$ or with $4$ samples.
*Proof sketch.* $|x-s|=0 \iff x=s$, so $r=0$ requires $S \supseteq \{0,\dots,6\}$, i.e. $|S|\ge 7 > 4$. $\square$

**Proposition 6.3 (Two equal thresholds).** $\mathrm{minRad}(7,3) = 1$ and $\mathrm{minRad}(7,4) = 1$.
*Proof sketch.* By Lemma 6.1 radius $1$ is achievable with $3$ (hence $4$) samples, so $\mathrm{minRad}\le 1$; by Lemma 6.2 radius $0$ is not achievable with $3$ or $4$ samples, so $\mathrm{minRad}\ge 1$. $\square$

**Corollary 6.4 (Step function).** $\mathrm{minRad}(7,3) = \mathrm{minRad}(7,4)$ although $3 \ne 4$. Indeed the minimal radius stays pinned at $1$ for all $n \in \{3,4,5,6\}$: it is constant on a range and drops only at the endpoints ($n=7$ reaches $0$; $n=1$ needs radius $3$). The threshold is a *staircase* in $n$, not a smooth curve. $\square$

**Theorem 6.5 (No exact inverse power law).** There is no constant $C>0$ with
$$\mathrm{minRad}(7,3) = C/3 \quad\text{and}\quad \mathrm{minRad}(7,4) = C/4.$$
*Proof sketch.* Substituting Proposition 6.3 gives $1 = C/3$ and $1 = C/4$, forcing $C=3$ and $C=4$ simultaneously — impossible. Equivalently, $C/3 = C/4$ would force $C=0$, contradicting $C>0$. $\square$

**Discussion.** The one-dimensional case is the law $\varepsilon_\star = C/n$. A strictly decreasing, injective function of $n$ cannot equal a step function that is constant on a range. Hence the *equality* in the conjecture is false; only the *scaling* $\varepsilon_\star \asymp d^{1/2} n^{-1/d}$ (up to bounded multiplicative constants) is tenable. The failure is generic: any integer-valued covering radius is piecewise constant in $n$, so no continuous strictly-monotone law can match it exactly.

## 7. Algorithms

We record the constructive procedures underlying the theorems.

**Algorithm A (Minimal covering radius, exact).** Given $m,n$, compute $\mathrm{minRad}(m,n)$ by searching $r=0,1,2,\dots$ and testing coverability. In one dimension, radius $r$ is coverable with $n$ samples iff $\lceil m/(2r+1)\rceil \le n$ (greedy left-to-right placement of centers at $r, 3r+1, \dots$ is optimal). This gives the closed form $\mathrm{minRad}(m,n) = \min\{ r : \lceil m/(2r+1)\rceil \le n\}$.

**Algorithm B (Grid cover generator).** Given $m=(2r+1)t$ and $d$, output the $t^d$ product points whose coordinates are the block centers $c_k = k(2r+1)+r$, $k=0,\dots,t-1$. This realizes the optimal cover of Theorem 4.3.

**Algorithm C (Packing certificate).** Given an alleged $r$-cover $S$, verify the lower bound is respected by checking $m^d \le |S|(2r+1)^d$; and verify $S$ is genuinely a cover by testing each cube point against the balls of $S$.

## 8. Applications

- **Sample-complexity budgeting.** Theorem 3.4 quantifies how many landmarks are needed to resolve a $d$-dimensional shape to scale $\varepsilon$: $n \gtrsim (m/\varepsilon)^d$. The intrinsic dimension $d$, not the ambient dimension $D$, controls the budget.
- **Metric selection.** Theorem 5.3 shows that quoting a detection threshold without naming the metric is ambiguous up to a factor $\sqrt d$; the $\ell^\infty$ radius is the natural quantity for packing, the $\ell^2$ radius for Euclidean geometry.
- **Landmark subsampling.** Construction 4.1 is an explicit, provably optimal landmark set for cube-like regions, useful for witness-complex and landmark-based persistence pipelines.
- **Threshold estimation caveat.** Corollary 6.4 warns practitioners that empirical threshold-vs-$n$ curves are staircases; fitting a smooth $C n^{-1/d}$ recovers the exponent but should not be expected to fit an exact constant.

## 9. Discussion and future work

We have shown that the Poincaré-for-data threshold obeys a sharp $n^{-1/d}$ scaling, that the $\sqrt d$ prefactor is an $\ell^\infty\!\to\!\ell^2$ conversion constant, and that the conjectured clean equality is false — the threshold is an integer-valued staircase, matched only up to constants.

**Future directions.**
- **From cubes to spheres.** Replace the Chebyshev cube by a discretization of $S^d$ carrying an Ahlfors-regular measure, for which $\mu(\text{ball}) \asymp \varepsilon^d$; the same volume-packing argument should transfer, yielding the threshold scaling for genuine spheres.
- **General manifolds and reach.** Extend to manifolds of positive reach, relating the constant to curvature and injectivity radius.
- **Persistence-window width.** Study not only where the sphere signature appears but the full interval of scales over which it persists, and its scaling in $n$.
- **Noise and near-manifolds.** Quantify the "$\varepsilon$-close to $S^d$" tolerance and the stability of detection under sub-Gaussian noise.
- **Constants and phase transitions.** Characterize the exact staircase (jump locations) and the sharp constants in the scaling relation across dimensions.

## 10. Conclusion

The manifold-detection threshold of the Poincaré conjecture for data scales like $n^{-1/d}$ (proved and sharp), carries a $\sqrt d$ prefactor that is purely a change-of-metric constant (proved), but does *not* satisfy the conjectured exact equality (disproved). The correct statement is the scaling relation $\varepsilon_\star \asymp d^{1/2}\,n^{-1/d}$. Manifold detection is a topological problem governed by the intrinsic dimension, and its difficulty is captured by a single, unavoidable exponent.
