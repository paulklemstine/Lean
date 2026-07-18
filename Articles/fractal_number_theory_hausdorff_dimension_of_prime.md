# The Prime Fractal That Vanished

## How a logarithmic lens reveals the difference between visual complexity and dimension

Prime numbers are the atoms of arithmetic. Every positive integer factors into them, yet their locations among the counting numbers seem irregular: $2,3,5,7,11,13,…$. As numbers grow, primes become rarer, but never disappear. Twin primes such as $11$ and $13$ appear in close pairs; long prime-free deserts appear elsewhere. This mixture of sparse order and apparent unpredictability makes the primes look like natural candidates for a fractal.

A particularly appealing proposal begins by changing how distance is measured. Instead of placing a prime $p$ at its ordinary position on the number line, assign it the logarithmic coordinate

$$
\phi(p)=\frac{1}{\log p}.
$$

The distance between primes $p$ and $q$ is then

$$
d(p,q)=\left|\frac{1}{\log p}-\frac{1}{\log q}\right|.
$$

This is not merely an analogy: it places every prime at a real point and measures ordinary Euclidean distance between the resulting coordinates. Because $\log p$ is strictly increasing for positive $p$, the function $1/\log p$ is strictly decreasing, so different primes receive different coordinates. Thus $d$ is a genuine metric. The transformed primes begin near $1/\log 2$ and march downward toward $0$.

At first sight, this logarithmic picture seems rich enough to support a dimension near $1$, perhaps even slightly larger. The prime number theorem says that the number of primes no greater than $x$ is approximately $x/\log x$. Twin-prime patterns create tiny local gaps, while uneven prime spacing produces complicated clusters. Numerical box-counting plots can display long stretches with nonzero slopes. It is tempting to interpret those slopes as evidence that the primes form a fractal curve.

That temptation conceals a decisive fact. The transformed prime set is countable.

## The countability barrier

Let

$$
P_{\log}=\left\{\frac{1}{\log p}:p\text{ is prime}\right\}\subset\mathbb R.
$$

There are only countably many natural numbers, and the primes are a subset of them. Applying a function to a countable set cannot make it uncountable. Therefore $P_{\log}$ is countable.

Countability alone does not prevent a set from being topologically striking. The rational numbers are countable and dense in the real line. A countable set can have infinitely many accumulation points, complicated local patterns, or a closure much larger than itself. But ordinary Hausdorff dimension is unforgiving: every countable set in a metric space has Hausdorff dimension zero.

To understand why, recall the idea behind Hausdorff measure. For an exponent $s>0$, cover a set $E$ by pieces $U_1,U_2,…$ of diameter at most $\delta$ and calculate the cost

$$
\sum_{n=1}^{\infty}(\operatorname{diam}U_n)^s.
$$

The $s$-dimensional Hausdorff measure is obtained by minimizing this cost over all such covers and then letting $\delta$ tend to zero. Dimension records the critical exponent where the measure changes from infinite to zero.

Now enumerate a countable set as $E=\{x_1,x_2,…\}$. Given any target cost $\eta>0$, cover $x_n$ by a ball whose diameter is at most

$$
\delta\left(\frac{\eta}{2^n}
ight)^{1/s},
$$

with an harmless rescaling if necessary to keep the total below $\eta$. The sum of the $s$th powers of these diameters is bounded by a geometric series with total at most $\eta$. Because $\eta$ can be arbitrarily small, the $s$-dimensional Hausdorff measure is zero.

This argument proves a general theorem.

**Countable-Set Theorem.** *In any metric space, every countable subset has zero $s$-dimensional Hausdorff measure for every $s>0$.*

Applying it immediately gives the central result.

**Logarithmic Prime Theorem.** *For every $s>0$, the $s$-dimensional Hausdorff measure of $P_{\log}$ is zero. Since $P_{\log}$ is nonempty, its Hausdorff dimension is exactly $0$.*

Nonemptiness matters only at the endpoint: the prime $2$ contributes $1/\log 2$. At dimension zero, Hausdorff measure behaves like counting measure, so a nonempty set does not have zero measure. The critical exponent is therefore exactly $0$, not $1$ and not $1+\varepsilon$.

## Why twin primes cannot rescue the conjecture

Suppose infinitely many twin-prime pairs exist. For a large twin pair $p$ and $p+2$, the mean value theorem suggests that the coordinate gap is on the scale

$$
\left|\frac{1}{\log p}-\frac{1}{\log(p+2)}\right|
\asymp \frac{2}{p(\log p)^2}.
$$

Such pairs create extremely close neighbors in the logarithmic picture. They may strongly influence finite-scale statistics. Yet they do not alter countability. Even infinitely many twin pairs still form a countable collection of points, and each point can receive its own rapidly shrinking covering ball. No abundance of special gaps can overcome that covering strategy.

This exposes a common mistake in fractal reasoning: divergence of a path-like sum is not the same as positive Hausdorff dimension. One may order points and add distances between selected neighbors, obtaining a quantity that grows or diverges. That sum concerns a chosen traversal. Hausdorff measure, by contrast, optimizes over all covers. It is free to cover each point separately at a cost that decays geometrically. A set can therefore look “long” under one bookkeeping rule while remaining zero-dimensional under another.

There is also a geometric limit that rules out the proposed dimension above $1$. The logarithmic prime set lies inside the real line, and every subset of $\mathbb R$ has Hausdorff dimension at most $1$. But the stronger countability argument drives the answer all the way down to $0$.

## The mirage of finite box counting

Why, then, might numerical experiments suggest a slope near $1$? Because finite data and asymptotic dimension answer different questions.

For a bounded set $E$, let $N(E,\varepsilon)$ be the smallest number of intervals of length $\varepsilon$ needed to cover it. A box-counting estimate examines

$$
\frac{\log N(E,\varepsilon)}{\log(1/\varepsilon)}.
$$

If the prime sample is fixed and finite, containing $m$ transformed primes, then once $\varepsilon$ is smaller than every separation between sample points, exactly $m$ boxes are needed. The numerator freezes at $\log m$, while the denominator tends to infinity. The ratio tends to $0$.

Before that final regime, however, boxes merge nearby points. As $\varepsilon$ decreases, clusters separate and $N$ rises. Over a restricted scale window, the log-log graph can resemble a straight line with a positive slope. That is a real finite-scale statistic, but it is not the Hausdorff dimension of the infinite countable set.

A second trap appears if the truncation grows while the scale shrinks. Let $P_X$ denote coordinates from primes at most $X$. Studying $N(P_X,\varepsilon)$ while choosing $X=X(\varepsilon)$ may produce a stable nonzero slope. Yet the result depends on the coupling rule between $X$ and $\varepsilon$. It describes a scaling family, not the ordinary Hausdorff dimension of one fixed set. Without stating that coupling, a numerical “dimension” has no unique asymptotic meaning.

## A small theorem with a wide reach

The conclusion does not depend on the prime number theorem, conjectures about gaps, or even the logarithm. Choose any countable collection $S$ in any metric space and replace its distance by any other genuine metric. As long as the underlying collection remains countable, its ordinary Hausdorff dimension remains zero. A nonlinear coordinate map may magnify some gaps and compress others; it may change completeness, boundedness, accumulation, and finite-scale covering behavior. It cannot defeat the point-by-point covering argument.

This distinction clarifies how dimension should be used in data analysis. Observed data sets are always finite and hence, literally interpreted, have Hausdorff dimension zero. When scientists report a dimension from a point cloud, they are modeling an underlying continuum, probability distribution, dynamical attractor, or scale-dependent family. That model may be excellent, but the inferred exponent belongs to the model or scaling regime, not to the finite list itself. The logarithmic prime example makes this usually hidden qualification impossible to ignore.

The same caution applies to other countable objects: algebraic numbers, rational points on a curve, event times in a discrete process, and sampled trajectories. Their spacing can carry rich information even though their Hausdorff dimension is zero. Dimension is one question among many, not a universal measure of complexity.

## What the logarithmic lens does reveal

The failed dimension conjecture does not make the construction useless. On the contrary, the coordinates encode prime gaps in a delicate way. If $q>p$ are nearby large primes, differentiation of $1/\log x$ gives

$$
\left|\phi(q)-\phi(p)\right|
\approx \frac{q-p}{p(\log p)^2}.
$$

Thus the geometry translates additive prime gaps into very small Euclidean separations. Covering numbers at prescribed finite scales can summarize clustering. Empirical distributions of rescaled gaps can compare ordinary and twin-prime behavior. The set’s closure also adds the accumulation point $0$, though this particular closure remains countable and still has dimension zero.

More promising invariants deliberately retain local scaling information that Hausdorff dimension discards for countable sets. Assouad-type dimensions ask how many small balls are needed inside a larger ball, uniformly across locations and scales. Quantitative covering profiles record the entire function $N(P_X,\varepsilon)$ instead of compressing it into one exponent. Rescaled limit sets may become uncountable, depending on the construction, and their dimensions could carry genuine information. Normalized empirical measures may converge even when the raw point set has trivial Hausdorff dimension.

The broader lesson reaches far beyond primes. A scatterplot can appear filamentary; a log-log graph can exhibit an impressive slope; a sequence can possess intricate gaps. None of these observations, by itself, determines Hausdorff dimension. The definition asks what happens under arbitrarily economical covers at arbitrarily small scales. For countable sets, that optimization is overwhelming.

The logarithmic primes still form a beautiful constellation. Their local geometry reflects one of mathematics’ most mysterious sequences. But in ordinary Hausdorff dimension, the constellation does not become a curve, wrinkled or otherwise. It remains what it has always been at the level that matters most for this invariant: countably many points, and therefore zero-dimensional.
