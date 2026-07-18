# Countability and the Hausdorff Geometry of Logarithmic Prime Coordinates

**Aristotle**  
**July 18, 2026**

## Abstract

We study the set of logarithmic prime coordinates

$$
P_{\log}=\left\{(\log p)^{-1}:p\text{ prime}\right\}\subset\mathbb R
$$

and the equivalent metric on the primes given by

$$
d(p,q)=\left|(\log p)^{-1}-(\log q)^{-1}\right|.
$$

The metric has suggestive finite-scale geometry: adjacent-prime gaps are compressed by approximately $1/(p(\log p)^2)$, and twin primes form particularly close pairs. Nevertheless, ordinary Hausdorff dimension is completely determined by a more elementary property. The set is countable, so its $s$-dimensional Hausdorff measure vanishes for every $s>0$. It is nonempty, and its zero-dimensional Hausdorff measure is nonzero; consequently its Hausdorff dimension is exactly $0$. We give a self-contained covering proof, establish that the proposed distance is a genuine pullback of Euclidean distance, distinguish Hausdorff dimension from path-length heuristics and finite box-counting slopes, and present algorithms for reproducible numerical exploration. The result rules out any dependence of ordinary Hausdorff dimension on twin-prime abundance while motivating scale-coupled covering profiles, Assouad-type dimensions, rescaled limit sets, and empirical measures as more informative alternatives.

## 1. Introduction

Prime numbers become sparse among the positive integers, but their gaps retain substantial arithmetic structure. This combination naturally suggests a geometric question: can one transform the primes so that their spacing defines a nontrivial fractal? Consider the coordinate map

$$
\phi(p)=\frac{1}{\log p}
$$

and measure the separation of primes $p$ and $q$ by $d(p,q)=|\phi(p)-\phi(q)|$. The image is bounded and accumulates at $0$. For large nearby primes, small differences in ordinary position become even smaller coordinate gaps. In particular, if $q=p+2$ is a twin prime, then the transformed pair is separated at a scale comparable to $1/(p(\log p)^2)$.

These features motivate conjectural dimensions near $1$, perhaps adjusted by the frequency of unusually small gaps. Such conjectures combine three intuitions: the prime number theorem supplies a predictable average density; gap sums can diverge; and finite box-counting plots can exhibit apparently stable slopes. All three observations can be mathematically meaningful. None, however, changes the cardinality of the set.

The central point of this paper is that countability settles ordinary Hausdorff dimension before detailed number theory enters. Every countable subset of any metric space has zero Hausdorff measure in every positive dimension. Since the transformed primes form a nonempty countable set, their Hausdorff critical exponent is $0$.

This negative result is also constructive. It identifies exactly why common heuristics fail and indicates which neighboring invariants can retain arithmetic information. The logarithmic embedding remains useful for quantitative covering functions, distributions of transformed gaps, scale-dependent truncations, and potentially stronger local dimensions.

## 2. Definitions and geometric setup

### 2.1 Prime coordinates and the induced metric

Let $\mathbb P$ be the set of positive prime integers. Define the **logarithmic coordinate map**

$$
\phi:\mathbb P\to\mathbb R,
\qquad
\phi(p)=\frac{1}{\log p},
$$

and define the **logarithmic prime set**

$$
P_{\log}=\phi(\mathbb P)
=\left\{\frac{1}{\log p}:p\in\mathbb P\right\}.
$$

The proposed distance on $\mathbb P$ is

$$
d(p,q)=|\phi(p)-\phi(q)|.
$$

Because every prime is at least $2$, its logarithm is positive. The logarithm is strictly increasing on the positive real axis, and reciprocal is strictly decreasing on the positive real axis. Hence $\phi$ is strictly decreasing and therefore injective on $\mathbb P$. It follows that $d(p,q)=0$ exactly when $p=q$. Symmetry and the triangle inequality follow from the corresponding properties of absolute value. Thus $d$ is a metric, and $\phi$ is an isometry from $(\mathbb P,d)$ onto $P_{\log}$ with its Euclidean metric.

This observation is important conceptually: the construction is not merely “metric-like.” It is exactly the Euclidean geometry of a particular subset of the real line.

### 2.2 Hausdorff measure

Let $(X,\rho)$ be a metric space, let $E\subseteq X$, let $s\geq 0$, and let $\delta>0$. The $s$-dimensional Hausdorff content at scale $\delta$ is

$$
\mathcal H^s_\delta(E)
=
\inf\left\{
\sum_{n=1}^{\infty}(\operatorname{diam}U_n)^s:
E\subseteq\bigcup_{n=1}^{\infty}U_n,
\ \operatorname{diam}U_n\leq\delta
\right\}.
$$

The **$s$-dimensional Hausdorff measure** is

$$
\mathcal H^s(E)=\lim_{\delta\downarrow 0}\mathcal H^s_\delta(E).
$$

The **Hausdorff dimension** of $E$ is equivalently defined by either critical-exponent formula

$$
\dim_H(E)=\inf\{s\geq 0:\mathcal H^s(E)=0\}
$$

or

$$
\dim_H(E)=\sup\{s\geq 0:\mathcal H^s(E)=\infty\},
$$

with standard conventions at the endpoints. At $s=0$, each nonempty covering set contributes $(\operatorname{diam}U)^0=1$ under the usual zero-dimensional convention, so nonempty sets have nonzero zero-dimensional Hausdorff measure; for finite sets it equals cardinality.

### 2.3 Covering numbers and box dimension

For a bounded $E\subset\mathbb R$ and $\varepsilon>0$, let $N(E,\varepsilon)$ denote the least number of intervals of diameter at most $\varepsilon$ needed to cover $E$. The lower and upper box-counting dimensions are

$$
\underline{\dim}_B(E)
=
\liminf_{\varepsilon\downarrow0}
\frac{\log N(E,\varepsilon)}{\log(1/\varepsilon)}
$$

and

$$
\overline{\dim}_B(E)
=
\limsup_{\varepsilon\downarrow0}
\frac{\log N(E,\varepsilon)}{\log(1/\varepsilon)}.
$$

Unlike Hausdorff dimension, box dimensions can sometimes be positive for countable sets. However, every fixed finite set has box dimension zero. This difference is central when interpreting computations on finite prime samples.

## 3. General countability theorem

We first isolate the result that controls the problem independently of arithmetic.

**Theorem 1 (Countable sets have vanishing positive-dimensional measure).**  
*Let $(X,\rho)$ be any metric space and let $E\subseteq X$ be countable. Then for every real $s>0$,*

$$
\mathcal H^s(E)=0.
$$

**Proof sketch.** Enumerate $E$ as $E=\{x_1,x_2,\ldots\}$, allowing repetitions if $E$ is finite. Fix $\delta>0$ and an arbitrary target $\eta>0$. For each $n$, choose a radius $r_n>0$ satisfying both $2r_n\leq\delta$ and

$$
(2r_n)^s\leq \eta 2^{-n}.
$$

The balls $B(x_n,r_n)$ cover $E$, every ball has diameter at most $\delta$, and their total $s$-cost satisfies

$$
\sum_{n=1}^{\infty}(\operatorname{diam}B(x_n,r_n))^s
\leq
\sum_{n=1}^{\infty}\eta 2^{-n}
=\eta.
$$

Therefore $\mathcal H^s_\delta(E)\leq\eta$. Since $\eta$ is arbitrary, $\mathcal H^s_\delta(E)=0$. Letting $\delta$ tend to zero yields $\mathcal H^s(E)=0$. $\square$

The proof is robust. It uses neither an ordering of the points nor any uniform separation. Accumulation points and extremely irregular gaps cause no difficulty because each enumerated point receives a separately chosen radius.

**Corollary 2 (Hausdorff dimension of a nonempty countable set).**  
*Every nonempty countable subset of a metric space has Hausdorff dimension $0$.*

**Proof sketch.** Theorem 1 shows that the measure is zero for every $s>0$, so the dimension is at most $0$. Hausdorff dimension is nonnegative. Equivalently, the nonempty set has nonzero zero-dimensional measure, placing the critical exponent exactly at $0$. $\square$

## 4. Main results for logarithmic primes

**Lemma 3 (Countability and nonemptiness).**  
*The logarithmic prime set $P_{\log}$ is countable and nonempty.*

**Proof sketch.** The prime numbers form a subset of the natural numbers and are therefore countable. The image of a countable set under any function is countable. Moreover, $2$ is prime, so $1/\log2\in P_{\log}$. $\square$

**Theorem 4 (Vanishing positive-dimensional Hausdorff measures).**  
*For every real $s>0$,*

$$
\mathcal H^s(P_{\log})=0.
$$

**Proof sketch.** Apply Theorem 1 to the countable set supplied by Lemma 3. $\square$

**Theorem 5 (Exact Hausdorff dimension).**  
*The logarithmic prime set, and equivalently the prime metric space $(\mathbb P,d)$, has Hausdorff dimension exactly $0$.*

**Proof sketch.** Theorem 4 gives vanishing measure for every positive exponent. Lemma 3 gives nonemptiness, hence nonzero zero-dimensional Hausdorff measure. The metric space $(\mathbb P,d)$ is isometric to $P_{\log}$, and Hausdorff dimension is invariant under isometry. $\square$

The conclusion is independent of all hypotheses about prime gaps. In particular, whether there are finitely or infinitely many twin primes cannot change this ordinary Hausdorff dimension.

**Theorem 6 (Metric realization).**  
*Distinct primes have distinct logarithmic coordinates, and for all primes $p$ and $q$,*

$$
d(p,q)=\operatorname{dist}_{\mathbb R}(\phi(p),\phi(q)).
$$

*Consequently the proposed prime metric is exactly the pullback of Euclidean distance under an injective coordinate map.*

**Proof sketch.** Strict monotonicity gives injectivity. Euclidean distance on the real line is absolute difference, which is the defining expression for $d$. $\square$

## 5. Prime gaps under the logarithmic coordinate

Although prime gaps do not affect Theorem 5, they do determine the finite-scale geometry. Let $p<q$ be primes. Applying the mean value theorem to $f(x)=1/\log x$ gives some $\xi\in(p,q)$ for which

$$
|\phi(p)-\phi(q)|
=
\frac{q-p}{\xi(\log\xi)^2},
$$

because

$$
f'(x)=-\frac{1}{x(\log x)^2}.
$$

For adjacent large primes with $q-p=o(p)$, this yields the approximation

$$
d(p,q)\sim\frac{q-p}{p(\log p)^2}.
$$

For a twin-prime pair $q=p+2$, the corresponding scale is approximately

$$
\frac{2}{p(\log p)^2}.
$$

Thus twin primes create exceptionally close transformed pairs relative to typical gaps near the same magnitude. Such local behavior can influence nearest-neighbor statistics, covering curves over finite ranges, and rescaled gap distributions. It cannot influence the point-by-point covering proof because that proof allows radii to shrink at any prescribed summable rate.

The coordinate set has one obvious limiting feature. Since $\log p\to\infty$ as $p\to\infty$,

$$
\phi(p)=\frac1{\log p}\to0.
$$

Therefore $0$ is an accumulation point, and

$$
\overline{P_{\log}}=P_{\log}\cup\{0\}.
$$

This closure is still countable, so adjoining the limit point does not change its Hausdorff dimension.

## 6. Why length heuristics do not determine dimension

One proposed intuition sums distances between selected points and interprets divergence as evidence of one-dimensional length. There are two separate issues.

First, a sum of consecutive distances concerns a chosen ordering or graph structure. Hausdorff measure concerns an infimum over all countable covers. These constructions need not agree. If points $x_n$ are traversed in an order, the series $\sum_n\rho(x_n,x_{n+1})$ may diverge, yet the set $\{x_n:n\geq1\}$ remains countable and therefore has zero positive-dimensional Hausdorff measure.

Second, for the monotone logarithmic prime coordinates ordered by increasing prime, the direct sum of successive coordinate differences telescopes. If $p_1=2<p_2<\cdots<p_N$, then

$$
\sum_{n=1}^{N-1}|\phi(p_n)-\phi(p_{n+1})|
=
\phi(2)-\phi(p_N)
<
\frac1{\log2}.
$$

Hence this particular path-length sum is bounded and converges to $1/\log2$ as $N\to\infty$. Expressions involving $d(p,p+1)$ must also be interpreted carefully because $p+1$ is generally not prime and does not represent the next point in the prime metric space.

More generally, even a genuinely divergent auxiliary sum would not override Theorem 1. Hausdorff dimension depends on optimized covers, not an assigned traversal cost.

## 7. Numerical algorithms

Numerical work is valuable when its target is stated correctly. We describe three algorithms.

### 7.1 Prime-coordinate generation

Given a truncation bound $X$, enumerate all primes $p\leq X$ with a sieve of Eratosthenes and return the sorted coordinates $1/\log p$. A standard sieve takes $O(X\log\log X)$ time and $O(X)$ memory. Coordinate conversion takes $O(\pi(X))$ time. Sorting is unnecessary if primes are enumerated in increasing order, because coordinates then occur in decreasing order.

### 7.2 Greedy interval covering

For a finite sorted subset $E\subset\mathbb R$, the exact minimum number of closed intervals of length $\varepsilon$ needed to cover it is found greedily. Begin at the leftmost uncovered point $x$, place an interval $[x,x+\varepsilon]$, discard all points it covers, and repeat. The exchange argument is standard: any covering interval containing the leftmost uncovered point can be shifted right or replaced by $[x,x+\varepsilon]$ without covering fewer points to its right. After sorting, the scan takes $O(n)$ time; including sorting, $O(n\log n)$.

The resulting curve $\varepsilon\mapsto N(E,\varepsilon)$ displays finite-scale clustering. A local secant slope between two scales is

$$
\widehat d
=
\frac{\log N(E,\varepsilon_2)-\log N(E,\varepsilon_1)}
{\log(1/\varepsilon_2)-\log(1/\varepsilon_1)}.
$$

It is a descriptive statistic, not automatically a dimension.

### 7.3 Explicit Hausdorff-cost certificates

For a finite or countably enumerated sample $x_1,x_2,\ldots$, a constructive certificate of small $s$-cost assigns the $n$th point an interval diameter

$$
\ell_n=\delta c2^{-n/s},
$$

where $0<c\leq1$ is chosen to keep every diameter at most $\delta$. Then

$$
\sum_n\ell_n^s
=
\delta^s c^s\sum_n2^{-n}
\leq\delta^s.
$$

Scaling $c$ makes the total cost arbitrarily small. A finite demonstration computes partial costs and shows their geometric decay. This does not estimate the dimension; it illustrates the mechanism proving zero measure.

## 8. Interpretation of box-counting experiments

Let

$$
P_X=\left\{\frac1{\log p}:p\leq X,\ p\text{ prime}\right\}.
$$

For fixed $X$, the set $P_X$ is finite. Let $m=|P_X|$ and let $g_X>0$ be its minimum pairwise separation. Whenever $0<\varepsilon<g_X$, each interval of diameter $\varepsilon$ covers at most one point, so

$$
N(P_X,\varepsilon)=m.
$$

Consequently

$$
\lim_{\varepsilon\downarrow0}
\frac{\log N(P_X,\varepsilon)}{\log(1/\varepsilon)}
=
\lim_{\varepsilon\downarrow0}
\frac{\log m}{\log(1/\varepsilon)}=0.
$$

Thus every fixed finite computation has asymptotic box dimension zero. Positive slopes can occur only over pre-asymptotic scale windows.

A different experiment chooses $X=X(\varepsilon)\to\infty$ while $\varepsilon\to0$. Then one studies

$$
\frac{\log N(P_{X(\varepsilon)},\varepsilon)}{\log(1/\varepsilon)}.
$$

This may have a nonzero limit, but the answer can depend on the growth law $X(\varepsilon)$. The coupling must be treated as part of the definition of the statistic. Reporting only a slope, without the truncation law and fitting window, conflates a two-parameter scaling profile with the Hausdorff dimension of $P_{\log}$.

Good practice therefore requires reporting the bound $X$, the exact coordinate range, the scale interval, the covering convention, and whether the sample changes between scales. Stability should be checked under variations of each choice.

### 8.1 Reproducibility protocol

A numerical study should separate raw observations from asymptotic claims. For each truncation, it should publish the number of primes, the smallest and largest coordinates, the minimum observed separation, and the complete list of scales. Covering numbers should be computed by an exact one-dimensional algorithm rather than inferred from a rasterized plot. Local slopes should be reported together with their endpoints, since changing a fitting window can materially change the estimate.

At least two convergence checks are essential. First, hold $X$ fixed and continue below the minimum separation; this must reveal the constant covering-number plateau and the decay of the dimension ratio toward $0$. Second, if $X$ varies, repeat the analysis under several explicit laws for $X(\varepsilon)$. Dependence on that law is evidence that the experiment measures a coupled family rather than an intrinsic dimension of $P_{\log}$.

Floating-point precision also matters because large primes can have extremely close coordinates. Stable implementations may compare exact primes first, use higher-precision logarithms when necessary, and verify borderline interval memberships at increased precision. These practices do not alter the theorem; they ensure that finite-scale arithmetic observations are accurately characterized.

## 9. Applications and alternative invariants

The conclusions have methodological applications wherever discrete arithmetic sets are visualized geometrically.

**Quantitative covering profiles.** Rather than taking one asymptotic exponent, retain the function $N(P_X,\varepsilon)$. Its jumps locate characteristic gap scales, and comparisons across $X$ can expose changes in clustering.

**Rescaled gap measures.** The transformed adjacent gap

$$
\Delta_n=\phi(p_n)-\phi(p_{n+1})
$$

can be normalized by a predicted local scale. Empirical distributions of normalized values can encode arithmetic regularity without claiming positive set dimension.

**Scale-coupled limits.** A family of translated and rescaled coordinate windows may converge to a nontrivial limit set or point process. Dimension questions about such a limit concern the new limiting object and must be established separately.

**Assouad-type dimensions.** These dimensions measure worst-case local covering growth between two scales. Some countable spaces have nonzero Assouad dimension, so this framework may detect clustering hidden from Hausdorff dimension. Any claim for logarithmic primes would require new estimates uniform in location and scale.

**Empirical measures.** For a truncation $X$, define a normalized measure

$$
\mu_X=\frac1{\pi(X)}
\sum_{\substack{p\leq X\\p\text{ prime}}}
\delta_{\phi(p)}.
$$

Without rescaling, these measures concentrate near $0$ as $X$ grows. Suitable recentering or rescaling may lead to more informative weak limits.

## 10. Further consequences and boundary cases

The countability theorem has several immediate consequences that help delimit the problem.

First, changing the formula for distance cannot by itself produce positive Hausdorff dimension if the underlying set remains countable and the formula defines a metric. One may replace $1/\log p$ by $1/(\log p)^a$, $p^{-b}$, or any injective coordinate map into any metric space. The resulting image remains countable, and Theorem 1 applies. The map can nevertheless alter box dimensions, Assouad-type dimensions, completion, and finite-scale profiles; only the ordinary Hausdorff conclusion is universal.

Second, taking a closure sometimes changes the answer, but it does not do so automatically. The rational numbers are countable and zero-dimensional in Hausdorff dimension, whereas their closure is the whole real line, of dimension $1$. For logarithmic prime coordinates, there is only one missing limit point, namely $0$, so the closure remains countable. Any proposal based on a closure must therefore identify a transformation or rescaling that creates a genuinely richer limit set.

Third, weights do not change set dimension. Assigning masses to prime coordinates may define an interesting atomic probability measure, and local dimensions of that measure may encode the decay of weights. Yet the support as a point set remains countable. Set dimension and measure dimension must not be interchanged without definition.

Fourth, the ambient-line bound is weaker than the countability result but provides a useful consistency check. Since $P_{\log}\subset\mathbb R$, one always has $\dim_H(P_{\log})\leq1$. Thus a proposed ordinary Hausdorff dimension strictly above $1$ would already contradict monotonicity under inclusion. Countability sharpens this upper bound from $1$ to $0$.

Finally, the prime number theorem is not needed for the exact dimension result. It becomes relevant only for quantitative questions involving how many coordinates occur in a window or how truncation should scale. This separation is useful: a cardinality-level theorem resolves the qualitative invariant, while analytic number theory governs refined finite-scale observables.

## 11. Discussion

The logarithmic transformation genuinely changes prime geometry. It makes the set bounded, creates an accumulation point at $0$, and converts a prime gap $q-p$ into a coordinate gap controlled by $(q-p)/(p(\log p)^2)$. What it cannot change is countability. Ordinary Hausdorff dimension is insensitive to all finer structure once countability is known.

This is not a defect of Hausdorff dimension. The invariant was designed to measure the scaling cost of efficient covers. A countable set admits covers whose assigned diameters decrease so rapidly that every positive power has arbitrarily small total. The result illustrates the need to match an invariant to the phenomenon under study.

The lesson also concerns finite data generally. Every finite point cloud has dimension zero under literal asymptotic definitions. Empirical dimension estimates implicitly posit an underlying infinite object or a finite-scale law. Such estimates remain useful, but their interpretation must name that object or law.

## 11. Future work

Several directions can preserve the number-theoretic content that ordinary Hausdorff dimension loses:

1. Determine upper and lower bounds for $N(P_X,\varepsilon)$ in explicitly stated joint regimes of $X$ and $\varepsilon$.
2. Construct rescaled local coordinate sets around large primes and investigate their subsequential limits.
3. Study Assouad, lower, and spectrum-type dimensions of the prime metric space, with attention to uniform prime-gap estimates.
4. Analyze empirical measures of transformed gaps, separating unconditional conclusions from conjectural twin-prime effects.
5. Compare logarithmic coordinates with alternative maps that yield nontrivial uncountable closures or limiting processes.

These projects ask sharper questions than assigning an ordinary Hausdorff dimension to a countable set. They preserve the attractive bridge between number theory and fractal geometry while respecting the invariants’ definitions.

## 12. Conclusion

The logarithmic prime metric is a valid and geometrically natural construction. Its coordinate map is injective, and its distance is exactly Euclidean distance after transformation. The resulting set is countable and nonempty. Therefore every positive-dimensional Hausdorff measure vanishes, the zero-dimensional measure is nonzero, and the Hausdorff dimension is exactly $0$.

Twin primes can shape local spacing, finite covering profiles, and rescaled statistics, but they cannot raise ordinary Hausdorff dimension. Numerical slopes obtained from finite truncations describe pre-asymptotic or scale-coupled behavior unless an independent limiting object is specified. The fruitful question is consequently not whether the countable prime set secretly exceeds a line in Hausdorff dimension, but which local, quantitative, or limiting invariant best captures the arithmetic geometry visible through the logarithmic lens.
