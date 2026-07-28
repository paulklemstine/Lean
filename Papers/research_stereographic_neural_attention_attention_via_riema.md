# Stereographic Neural Attention on the Unit Sphere: A Deterministic Obstruction to Fixed-Threshold Sparsity

**Aristotle**  
**July 28, 2026**

## Abstract

We study a geometric attention mechanism in which normalized queries and keys are compared by the Cauchy kernel

$$
K(q,k)=\frac{1}{1+\lVert q-k\rVert^2}.
$$

This kernel arises naturally from stereographic geometry and appears at first to offer distance-driven sparsity. We show that spherical normalization creates a decisive obstruction to that expectation. In any seminormed vector space, two unit vectors have distance at most $2$; consequently every Cauchy weight between unit-sphere points is at least $1/5$. This deterministic lower bound is distribution-free and dimension-free. For any finite collection of unit keys and any threshold $\tau\leq 1/5$, the set of below-threshold keys is empty, while the number of active keys is exactly the total number $N$ of keys. If $N>1$, this active count is strictly greater than the integer square root of $N$, refuting a literal fixed-threshold $O(\sqrt N)$ claim with unit constant. We give proof sketches, thresholding algorithms, numerical diagnostics, and design implications. The obstruction points toward viable modifications based on bandwidth scaling, powered kernels, spherical-cap probabilities, and controlled top-$k$ approximation.

## 1. Introduction

Attention mechanisms compare a query with a family of keys and use the resulting scores to aggregate values. Dense pairwise comparison is expressive but expensive: for a sequence of length $N$, a full self-attention layer generally evaluates on the order of $N^2$ query-key interactions. This has motivated kernels whose values decay with geometric separation, with the hope that most interactions can be removed.

Spherical representations are attractive in this context. Normalizing vectors to unit norm suppresses radial scale, isolates directional information, and makes similarity invariant under positive rescaling of the original embeddings. Stereographic projection further links the sphere to rational kernels on Euclidean coordinates. One particularly simple score is the Cauchy kernel

$$
K(q,k)=\frac{1}{1+\lVert q-k\rVert^2}.
$$

It is strictly positive, smooth in ordinary Euclidean settings, maximal at coincidence, and decreasing with squared chordal distance. In an unbounded domain, $K(q,k)$ tends to zero as the distance tends to infinity. That decay suggests sparse attention: perhaps only a small neighborhood of each query has appreciable weight.

The central issue is that a unit sphere is bounded. Its chordal diameter is $2$, so the denominator of the unscaled Cauchy kernel never exceeds $5$. Hence the kernel never falls below $1/5$. This elementary observation has strong consequences for any sparsity notion based on an absolute threshold.

The contribution of this paper is a complete deterministic analysis of that obstruction. We establish four linked results:

1. the Cauchy weight is strictly positive for all queries and keys;
2. every pair of unit-sphere points has weight at least $1/5$;
3. at any threshold $\tau\leq 1/5$, no unit key is below threshold and every key remains active;
4. for more than one key, the active count exceeds the integer square root of the key count.

These statements require no randomness, no finite-dimensional assumption, and no asymptotic regime. They therefore apply to every sample from every distribution supported on the unit sphere. The result does not rule out geometric attention or the Cauchy family. Instead, it identifies a missing scale parameter and motivates several corrected research directions.

## 2. Mathematical setting

### 2.1 Ambient space and spherical data

Let $E$ be a real or complex seminormed vector space, with seminorm $\lVert\cdot\rVert$ and induced pseudometric

$$
d(x,y)=\lVert x-y\rVert.
$$

The argument also applies to normed vector spaces as the standard special case. Define the unit sphere by

$$
S(E)=\{x\in E:\lVert x\rVert=1\}.
$$

A query $q$ and key $k$ are **spherically normalized** when $q,k\in S(E)$.

The use of a seminormed space emphasizes that the result depends only on the triangle inequality and unit-norm constraints. It does not require coordinates, inner products, compactness, or finite dimension.

### 2.2 Stereographic Cauchy weight

**Definition 2.1 (Cauchy attention weight).** For $q,k\in E$, define

$$
K(q,k)=\frac{1}{1+d(q,k)^2}.
$$

This expression can also be obtained by taking one half of the standard stereographic conformal factor $2/(1+r^2)$ evaluated at $r^2=d(q,k)^2$. The direct formula above is all that is needed for the analysis.

Because $d(q,k)^2\geq 0$, the denominator is at least $1$. Thus $0<K(q,k)\leq 1$. Coincident points attain the upper endpoint.

### 2.3 Thresholded activity

Let $Q=\{k_1,\ldots,k_N\}$ be a finite collection of distinct keys and fix a query $q$. For a real threshold $\tau$, define the below-threshold set

$$
B_\tau(q,Q)=\{k\in Q:K(q,k)<\tau\},
$$

and the active set

$$
A_\tau(q,Q)=\{k\in Q:\tau\leq K(q,k)\}.
$$

Their cardinalities satisfy

$$
|B_\tau(q,Q)|+|A_\tau(q,Q)|=N,
$$

because each key either has weight below $\tau$ or at least $\tau$.

This is an absolute-threshold notion of sparsity. It differs from top-$k$ selection, which retains a prescribed rank, and from approximate sparsity, which controls the total normalized mass of discarded weights.

### 2.4 Integer square root

For a natural number $N$, let $\operatorname{isqrt}(N)=\lfloor\sqrt N\rfloor$ denote the largest natural number whose square is at most $N$. The proposed square-root benchmark is an active count no greater than a constant multiple of $\sqrt N$. Our exact result implies, in particular, that the unit-constant inequality $|A_\tau|\leq\operatorname{isqrt}(N)$ fails whenever $N>1$ and $\tau\leq 1/5$.

## 3. Geometric preliminaries

The analysis begins with two elementary lemmas.

**Lemma 3.1 (Strict positivity).** For every $q,k\in E$,

$$
K(q,k)>0.
$$

**Proof sketch.** The squared distance $d(q,k)^2$ is nonnegative, so $1+d(q,k)^2$ is strictly positive. Its reciprocal is therefore strictly positive. $\square$

Strict positivity alone does not prevent numerical sparsity: positive numbers may be arbitrarily close to zero. The decisive point is the uniform diameter bound.

**Lemma 3.2 (Unit-sphere chordal diameter).** If $q,k\in S(E)$, then

$$
d(q,k)\leq 2.
$$

**Proof sketch.** By the triangle inequality,

$$
d(q,k)=\lVert q-k\rVert\leq\lVert q\rVert+\lVert-k\rVert
=\lVert q\rVert+\lVert k\rVert=2.
$$

Only symmetry and the triangle inequality of the seminorm are used. $\square$

In an ordinary normed vector space, the constant $2$ is sharp: choosing $k=-q$ gives $d(q,k)=\lVert 2q\rVert=2$. Thus no smaller universal diameter bound is possible.

## 4. Main results

### 4.1 Uniform lower bound

**Theorem 4.1 (Uniform Weight-Floor Theorem).** Let $q,k\in E$ satisfy $\lVert q\rVert=\lVert k\rVert=1$. Then

$$
\frac15\leq K(q,k)=\frac{1}{1+d(q,k)^2}.
$$

**Proof sketch.** Lemma 3.2 gives $0\leq d(q,k)\leq 2$. Squaring preserves the inequality because distance is nonnegative, so $d(q,k)^2\leq 4$. Therefore

$$
1+d(q,k)^2\leq 5.
$$

Both sides are positive. Reciprocation reverses the denominator comparison, yielding

$$
\frac15\leq\frac{1}{1+d(q,k)^2}=K(q,k).
$$

$\square$

The bound is dimension-free and sharp in normed vector spaces containing an antipodal pair. At $k=-q$, the distance equals $2$ and the weight equals $1/5$. At $k=q$, the distance is $0$ and the weight is $1$. Hence the raw scores on the unit sphere occupy the compact interval $[1/5,1]$.

**Corollary 4.2 (Distribution-free almost-sure floor).** Let $(q,k)$ be random vectors whose joint distribution is supported on $S(E)\times S(E)$. Then

$$
\mathbb{P}\!\left(K(q,k)\geq\frac15\right)=1.
$$

**Proof sketch.** Every point in the support satisfies the deterministic hypotheses of Theorem 4.1. The event therefore contains the entire support and has probability one. No independence or uniformity assumption is needed. $\square$

The corollary explains why concentration of random points cannot overcome the obstruction. Randomness may describe where within $[1/5,1]$ a weight lies, but it cannot create a weight below $1/5$.

### 4.2 Empty pruned set

**Theorem 4.3 (No Pruning Below the Geometric Floor).** Let $q\in S(E)$ and let $Q$ be a finite set contained in $S(E)$. If $\tau\leq 1/5$, then

$$
B_\tau(q,Q)=\varnothing.
$$

**Proof sketch.** For each $k\in Q$, Theorem 4.1 gives $K(q,k)\geq 1/5$. Combining this with $\tau\leq 1/5$ yields $K(q,k)\geq\tau$. Thus the strict inequality $K(q,k)<\tau$ is false for every key, so the below-threshold set is empty. $\square$

The strict inequality in the definition of $B_\tau$ is important at the endpoint. Antipodal keys can have weight exactly $1/5$, but they remain active when $\tau=1/5$.

### 4.3 Exact active count

**Theorem 4.4 (Exact Active-Count Theorem).** Under the assumptions of Theorem 4.3, if $N=|Q|$, then

$$
|A_\tau(q,Q)|=N.
$$

**Proof sketch.** Every key satisfies $\tau\leq K(q,k)$ by Theorem 4.1 and the threshold assumption. Hence $A_\tau(q,Q)=Q$. Taking cardinalities gives the result. Equivalently, Theorem 4.3 and the partition of $Q$ into below-threshold and active keys imply the same equality. $\square$

This equality is stronger than an asymptotic lower bound. The number of retained interactions is not merely $\Omega(N)$; it is exactly $N$ for every finite key set.

### 4.4 Square-root obstruction

**Theorem 4.5 (Failure of the Unit-Constant Square-Root Bound).** Under the assumptions of Theorem 4.4, suppose $N>1$. Then

$$
\operatorname{isqrt}(N)<|A_\tau(q,Q)|.
$$

**Proof sketch.** Theorem 4.4 gives $|A_\tau(q,Q)|=N$. For every natural number $N>1$, its integer square root is strictly less than $N$. Substitution yields

$$
\operatorname{isqrt}(N)<N=|A_\tau(q,Q)|.
$$

$\square$

More broadly, because $|A_\tau|=N$, no bound $|A_\tau|\leq C\sqrt N$ with a fixed constant $C$ can hold for all $N$: choosing $N>C^2$ gives $N>C\sqrt N$. Thus the deterministic result contradicts any uniform $O(\sqrt N)$ active-count claim at a fixed threshold $\tau\leq 1/5$.

## 5. Algorithms and diagnostics

The theorems are analytic, but they suggest useful computational checks for proposed attention mechanisms.

### 5.1 Direct Cauchy-weight evaluation

Given vectors $q$ and $k$, compute their squared Euclidean distance and return its shifted reciprocal:

1. compute $s=\sum_j(q_j-k_j)^2$;
2. return $1/(1+s)$.

For vectors in $\mathbb{R}^d$, this costs $O(d)$ time and $O(1)$ additional working memory when evaluated in a streaming loop.

### 5.2 Active-count audit

Given one query, $N$ keys in $\mathbb{R}^d$, and a threshold $\tau$, evaluate all weights and count those satisfying $K(q,k_i)\geq\tau$. The direct procedure costs $O(Nd)$ time. Storing only the running count uses $O(1)$ auxiliary memory; retaining all weights uses $O(N)$.

For normalized inputs and $\tau\leq 0.2$, Theorem 4.4 predicts the output $N$ exactly. The calculation is therefore best understood as an implementation audit: any lower count indicates a normalization error, a different distance, a scaled kernel, or floating-point behavior inconsistent with the stated model.

### 5.3 Random spherical experiment

To illustrate the geometry in $\mathbb{R}^d$, sample a standard Gaussian vector $x$ and normalize it as $x/\lVert x\rVert_2$. Rotational invariance produces a uniform point on the sphere. Repeating this for one query and many keys gives an empirical weight distribution.

The expected histogram depends on dimension. In high dimension, independent random unit vectors are nearly orthogonal, so $\lVert q-k\rVert^2$ is often close to $2$ and $K(q,k)$ is often close to $1/3$. Nevertheless, every sample remains above $1/5$. The histogram may become concentrated, but it does not develop a near-zero tail.

### 5.4 Deterministic antipodal test

A minimal boundary test chooses any unit vector $q$ and sets $k=-q$. Then

$$
K(q,-q)=\frac{1}{1+\lVert2q\rVert^2}=\frac15.
$$

This confirms sharpness and tests the endpoint convention in thresholding. At $\tau=1/5$, the antipodal key must be active because activity uses the non-strict comparison $\tau\leq K$.

## 6. Consequences for normalized attention

Raw kernel floors also constrain normalized attention. Given positive raw weights $w_i=K(q,k_i)$, define

$$
a_i=\frac{w_i}{\sum_{j=1}^N w_j}.
$$

Since $1/5\leq w_i\leq 1$, the normalization denominator lies between $N/5$ and $N$. Consequently,

$$
\frac{1}{5N}\leq a_i\leq\frac{5}{N}.
$$

These bounds are coarse but informative. Every normalized key receives positive mass of order at least $1/N$, and no raw interaction is negligible relative to the largest by more than a factor of five. Therefore raw thresholding below $1/5$ cannot create sparse normalized attention.

A top-$m$ rule can enforce exactly $m$ retained keys, but the kernel floor warns that its discarded mass may be substantial. If $m=O(\sqrt N)$ while the weights remain comparable, then the omitted $N-m$ terms can carry most of the normalized mass. Any top-$k$ sparsification claim therefore requires a separate approximation-error theorem, not merely a count of retained entries.

## 7. Design modifications

### 7.1 Bandwidth-scaled Cauchy kernels

Introduce a bandwidth parameter $\beta>0$:

$$
K_\beta(q,k)=\frac{1}{1+\beta d(q,k)^2}.
$$

On the unit sphere, its deterministic floor is

$$
K_\beta(q,k)\geq\frac{1}{1+4\beta}.
$$

Unlike the unscaled case $\beta=1$, this floor can be made arbitrarily small. At a threshold $\tau\in(0,1)$, activity is equivalent to

$$
d(q,k)^2\leq\frac{\tau^{-1}-1}{\beta}.
$$

For Euclidean unit spheres, this condition defines a spherical cap centered at $q$. If keys are independent and uniform, the active count conditional on $q$ is binomial with success probability equal to the cap's normalized surface area. Choosing $\beta$ to make that probability of order $N^{-1/2}$ would produce an expected active count of order $\sqrt N$.

This reformulation exposes the correct mathematical object: not unconstrained Cauchy decay, but spherical-cap measure as a function of dimension and bandwidth.

### 7.2 Powered kernels

For $p>0$, define

$$
K_p(q,k)=\bigl(1+d(q,k)^2\bigr)^{-p}.
$$

The unit-sphere floor becomes $5^{-p}$. Increasing $p$ sharpens contrast while preserving radial monotonicity. The active condition is

$$
d(q,k)^2\leq\tau^{-1/p}-1.
$$

Again, the expected active count under uniform sampling reduces to a spherical-cap probability. A useful theory should identify explicit dependence of $p$ on dimension $d$, key count $N$, and threshold $\tau$.

### 7.3 Compactly supported kernels

A more direct route uses a kernel that vanishes beyond a chosen radius, such as

$$
K_R(q,k)=\max\left\{0,1-\frac{d(q,k)^2}{R^2}\right\}.
$$

This creates exact zeros but changes the analytic and approximation properties of the mechanism. Smooth compactly supported alternatives can soften the boundary. Their suitability depends on whether continuity, differentiability, positive definiteness, or universality is required.

### 7.4 Adaptive and rank-based thresholds

A data-dependent threshold can retain a desired quantile of weights, and top-$k$ selection fixes the active count by construction. Such methods evade the fixed-threshold theorem because their cutoff depends on the sample or on $N$. They should be evaluated by approximation error and stability: small changes in weights near the cutoff may alter the selected set.

## 8. Applications and interpretation

### 8.1 Long-sequence models

For long sequences, a dense active count means that simple thresholding does not reduce the number of query-key interactions. If the threshold is at most $0.2$, every key survives and the direct computational complexity remains quadratic across all queries. Any speedup must come from a modified kernel, approximate summation, low-rank structure, locality imposed before scoring, or rank-based pruning.

### 8.2 Spherical embedding systems

Unit normalization is common in metric learning and retrieval. The theorem applies whenever the score uses chordal distance and the unscaled Cauchy formula, independent of how embeddings were learned. It gives a quick calibration rule: an absolute threshold below $0.2$ is ineffective for pruning normalized embeddings.

### 8.3 Geometric model design

The analysis illustrates a general principle. Let a metric space have finite diameter $D$, and let $f:[0,\infty)\to(0,\infty)$ be decreasing. For the radial kernel $K(x,y)=f(d(x,y))$, every pair satisfies

$$
K(x,y)\geq f(D).
$$

Thus bounded geometry induces a kernel floor. Sparsity based on absolute magnitude requires either a sufficiently low floor, a threshold above it, or a kernel with compact support. This diameter-first calculation should precede probabilistic analysis.

## 9. Statistical geometry beyond the obstruction

The deterministic floor settles the low-threshold question, but the distribution of weights above $1/5$ remains informative. In Euclidean space, unit vectors satisfy

$$
\lVert q-k\rVert^2=2-2\langle q,k\rangle.
$$

Hence the unscaled kernel can be written as

$$
K(q,k)=\frac{1}{3-2\langle q,k\rangle}.
$$

For independent uniform points on $S^{d-1}$, the inner product is centered at zero and concentrates near zero as $d$ increases. Typical weights therefore concentrate near $1/3$, not near zero. This reinforces the deterministic conclusion with a statistical picture: high dimension makes most raw weights more alike around an interior value.

For a threshold $\tau>1/5$, activity can be expressed through an inner-product cutoff. The inequality $K(q,k)\geq\tau$ is equivalent to

$$
\langle q,k\rangle\geq\frac{3-\tau^{-1}}{2}.
$$

The active region is a spherical cap. Its measure gives the exact activation probability for a uniform random key. With independent keys, conditional on the query, the active count is binomial. Thus expectation, variance, and tail probabilities follow once the cap measure is known. The threshold $\tau=1/5$ corresponds to the cutoff $-1$, so the cap is the entire sphere, consistent with the exact active-count theorem.

Bandwidth scaling changes the cutoff to

$$
\langle q,k\rangle\geq 1-\frac{\tau^{-1}-1}{2\beta}.
$$

This formula provides a direct calibration method. One first chooses a target activation probability, such as $N^{-1/2}$, then selects the corresponding cap angle or inner-product quantile, and finally solves for $\beta$. In practice, the cap quantile may be evaluated from the beta distribution associated with a coordinate of a uniform spherical point or approximated by Gaussian concentration in high dimension.

The distinction between raw and normalized weights must remain explicit. A raw threshold defines activity before division by the row sum. A threshold on normalized weights varies implicitly with every other key because the denominator is data-dependent. The present theorems concern raw Cauchy scores, while approximation guarantees for the final attention output require control of normalized tail mass and of the value vectors being aggregated.

## 10. Limitations

The results address the unscaled Cauchy kernel on unit-sphere inputs and absolute thresholding at $\tau\leq 1/5$. They do not claim that every threshold is ineffective. For $\tau>1/5$, sufficiently distant keys can fall below threshold, and the number of active keys depends on their geometry.

The results also do not settle universal approximation. Strictly positive dense kernels may still support expressive neural architectures, and modified Cauchy mixtures may approximate broad classes of functions. Expressivity and computational sparsity are distinct properties.

Finally, the exact count concerns distinct finite key sets. In implementations, repeated keys are normally represented by indexed lists or multisets; the same pointwise argument applies to every occurrence, so the indexed active count is still the total number of entries.

## 11. Future research

Five directions emerge naturally.

First, for independent uniform points on $S^{d-1}$, analyze powered kernels with an exponent scaling like $d\log N$ and determine whether explicit constants produce expected active count at most a constant multiple of $\sqrt N$.

Second, derive an explicit bandwidth $\beta(d,N,\tau)$ for which the spherical-cap probability makes the expected active count comparable to $\sqrt N$ from above and below.

Third, once the cap probability is fixed, prove high-probability concentration of the active count. Conditional on the query, independent keys produce independent Bernoulli indicators, making binomial tail bounds the natural tool.

Fourth, study normalized top-$k$ approximation. The goal is to choose a bandwidth so that retaining the largest $\lceil C\sqrt N\rceil$ weights leaves discarded normalized mass at most $\varepsilon$ with high probability.

Fifth, determine whether finite positive mixtures of bandwidth-scaled Cauchy kernels retain the desired universal approximation properties for continuous permutation-equivariant functions on compact domains.

## 12. Conclusion

The unscaled Cauchy kernel does not become sparse merely because queries and keys are random points on a unit sphere. Spherical normalization bounds every chordal distance by $2$, which bounds every weight below by $1/5$. At thresholds no greater than this floor, the below-threshold set is empty, the active count is exactly $N$, and for $N>1$ that count exceeds $\lfloor\sqrt N\rfloor$.

The obstruction is deterministic, dimension-free, distribution-free, and sharp. Its practical lesson is equally direct: kernel decay must be calibrated against the diameter of the representation space. Bandwidth scaling and powered kernels restore a tunable floor and convert the sparsity question into one about spherical-cap probabilities. That revised formulation offers a viable path toward geometric attention with provable computational sparsity.
