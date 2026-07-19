# Two Cutoffs, One Error Budget: Prime Numbers as a Finite Statistical System

## A product built from tiny ladders

Prime numbers usually enter mathematics as indivisible integers: $2,3,5,7,\ldots$. Yet the same primes can also be treated as labels for independent microscopic modes, each carrying a ladder of possible occupations. This statistical-mechanical viewpoint turns a classical product from number theory into a finite partition function and, more importantly, reveals exactly how two different approximations contribute to its error.

Choose a finite collection of modes indexed by a set $I$. Give mode $i$ a weight $q_i$ satisfying

$$
0\le q_i<1.
$$

If the mode can be occupied $n$ times, its contribution is $q_i^n$. Allowing occupations only from $0$ through $N$ gives the local geometric sum

$$
1+q_i+q_i^2+\cdots+q_i^N.
$$

Because the modes are independent, the partition function of the entire finite system is the product

$$
T_N(q)=\prod_{i\in I}\left(\sum_{n=0}^{N}q_i^n\right).
$$

If there is no occupation ceiling, the local sum becomes $(1-q_i)^{-1}$, so the completed finite product is

$$
C(q)=\prod_{i\in I}\frac{1}{1-q_i}.
$$

The central question is simple: how much does the ceiling $N$ change the answer? The exact response is more informative than a bare convergence statement.

## The defect has an exact shape

The ordinary finite geometric-series identity says

$$
\sum_{n=0}^{N}q_i^n=\frac{1-q_i^{N+1}}{1-q_i}.
$$

Multiplying this identity over all modes gives the **Exact Occupation-Defect Theorem**:

For every finite family of real weights with $q_i<1$,
$$
T_N(q)=C(q)\prod_{i\in I}\left(1-q_i^{N+1}\right).
$$

The formula separates the ideal finite partition function $C(q)$ from a dimensionless correction. Each local correction $q_i^{N+1}$ is precisely the first omitted power. Nothing is hidden: the full many-mode defect is assembled from the first missing occupation at each mode.

This exact factorization also proves that truncation approaches the completed product from below whenever the weights are nonnegative. Indeed, every factor $1-q_i^{N+1}$ lies between $0$ and $1$. Thus

$$
0\le C(q)-T_N(q).
$$

The missing mass is not merely nonnegative; it has a clean additive upper bound.

## Turning a product error into a sum

Products can look like interactions even when the underlying modes are independent. The useful elementary principle is the **Multiplicative Union Bound**. If $0\le a_i\le1$ for every $i$ in a finite set, then

$$
1-\prod_{i\in I}(1-a_i)\le\sum_{i\in I}a_i.
$$

For two terms this reads $a+b-ab\le a+b$. For many terms, the subtracted overlaps only reduce the total. It is the same logic that bounds the probability of a union by the sum of individual probabilities, but no probability theory is required.

Set $a_i=q_i^{N+1}$. Combining the exact defect formula with the multiplicative union bound yields the **Occupation-Tail Bound**:

If $0\le q_i<1$ for all $i$, then
$$
0\le C(q)-T_N(q)
\le C(q)\sum_{i\in I}q_i^{N+1}.
$$

The right-hand side is explicit and local. Instead of estimating a potentially complicated product directly, one adds the first omitted powers and multiplies by the completed finite product. Since every $q_i<1$, the bound decays geometrically with $N$.

A small example makes the mechanism visible. Take weights $1/2$, $1/3$, and $1/5$, with occupations $0,1,2$. Then

$$
C(q)=\frac{1}{1-1/2}\frac{1}{1-1/3}\frac{1}{1-1/5}=\frac{15}{4},
$$

while

$$
T_2(q)=\left(1+\frac12+\frac14\right)
\left(1+\frac13+\frac19\right)
\left(1+\frac15+\frac1{25}\right).
$$

The normalized defect is exactly

$$
1-\frac{T_2(q)}{C(q)}
=1-\left(1-\frac1{2^3}\right)
\left(1-\frac1{3^3}\right)
\left(1-\frac1{5^3}\right),
$$

and it is at most

$$
\frac1{2^3}+\frac1{3^3}+\frac1{5^3}.
$$

The estimate is especially effective when the omitted powers are small, because products of two or more tails are then of still smaller order.

## The two-cutoff principle

Occupation is only one possible approximation. Often the finite set of modes is itself a truncation of a larger or infinite system. Suppose $Z$ is a target quantity. Insert the intermediate completed finite product $C(q)$ between $Z$ and $T_N(q)$. The triangle inequality gives

$$
|Z-T_N(q)|\le |Z-C(q)|+|C(q)-T_N(q)|.
$$

Applying the occupation-tail bound produces the **Two-Cutoff Error-Splitting Theorem**:

For every real target $Z$, every finite family with $0\le q_i<1$, and every occupation ceiling $N$,
$$
|Z-T_N(q)|
\le |Z-C(q)|+C(q)\sum_{i\in I}q_i^{N+1}.
$$

This inequality is the conceptual heart of the result. It assigns the total error to two independent budgets. The first term measures modes not represented by the finite system. The second measures occupations omitted from the modes that were retained. One can improve either approximation without entangling it with the other.

That independence matters computationally. Imagine choosing how much memory to spend on adding modes and how much to spend on raising $N$. A monolithic error estimate gives little guidance. The split estimate says exactly which source dominates, so resources can be directed where they buy the greatest reduction.

## When the modes are primes

Now let the retained modes be primes below a cutoff $x$, and choose an inverse temperature $\beta>0$. Associate to each prime $p<x$ the Boltzmann weight

$$
q_p=\exp(-\beta\log p)=p^{-\beta}.
$$

Because every prime satisfies $p>1$, these weights obey $0<q_p<1$. The truncated prime-occupation partition is therefore

$$
T_{x,N}(\beta)
=\prod_{\substack{p<x\\p\ \mathrm{prime}}}
\left(1+p^{-\beta}+p^{-2\beta}+\cdots+p^{-N\beta}\right),
$$

and its completed finite counterpart is

$$
C_x(\beta)
=\prod_{\substack{p<x\\p\ \mathrm{prime}}}
\frac{1}{1-p^{-\beta}}.
$$

The exact factorization becomes

$$
T_{x,N}(\beta)
=C_x(\beta)
\prod_{\substack{p<x\\p\ \mathrm{prime}}}
\left(1-p^{-(N+1)\beta}\right).
$$

For any real target $Z$, the **Prime Partition Two-Cutoff Bound** states

$$
|Z-T_{x,N}(\beta)|
\le |Z-C_x(\beta)|
+C_x(\beta)
\sum_{\substack{p<x\\p\ \mathrm{prime}}}p^{-(N+1)\beta}.
$$

If $\beta>1$, the natural infinite target is the Euler product for the Riemann zeta function,

$$
\zeta(\beta)=\prod_{p\ \mathrm{prime}}\frac{1}{1-p^{-\beta}}.
$$

Then $|\zeta(\beta)-C_x(\beta)|$ is the prime-cutoff error, while the explicit sum is the occupation-cutoff error. The finite theorem does not by itself estimate the omitted primes, extend $\zeta$ beyond its Euler-product region, or say anything about its zeros. Its strength is sharper and more foundational: it isolates the occupation error unconditionally and leaves the prime tail as a separate analytic problem.

## A unique integer encoding

Why does a prime occupation model connect so naturally to number theory? A configuration assigns a nonnegative occupation $n_p$ to each retained prime. Unique factorization maps that configuration to the integer

$$
m=\prod_{p<x}p^{n_p}.
$$

The Boltzmann weight of the configuration is

$$
\prod_{p<x}p^{-\beta n_p}=m^{-\beta}.
$$

Thus the partition function sums reciprocal powers of integers whose prime factors are retained and whose exponents do not exceed $N$. Raising the prime cutoff admits new prime factors; raising the occupation ceiling admits higher exponents. The two cutoffs constrain genuinely different aspects of integer structure, which explains why their errors separate so cleanly.

## What the estimate teaches

The bound offers three practical lessons.

First, geometric convergence is local. For fixed primes and fixed $\beta>0$, the occupation error shrinks at least as fast as a sum of $p^{-(N+1)\beta}$. The smallest retained prime usually controls the slowest decay. This suggests that the additive bound becomes asymptotically sharp when one local tail dominates.

Second, exact algebra should precede asymptotics. The factorization identifies every correction term before any limiting argument begins. Quantitative analysis can then focus on known geometric tails rather than on a product whose structure has been obscured.

Third, approximation design becomes modular. To approximate $\zeta(\beta)$ in the region $\beta>1$, one may choose $x$ to control omitted primes and independently choose $N$ to control omitted occupations. The finite identity remains stable under either choice.

## A practical way to balance the budgets

Suppose a calculation is allowed total error $\varepsilon$. The split suggests reserving part of that allowance for omitted modes and part for occupations. After choosing $x$ so that the prime-tail estimate meets its allocation, one computes $C_x(\beta)$ and increases $N$ until

$$
C_x(\beta)\sum_{p<x}p^{-(N+1)\beta}
$$

falls below the remaining allowance. This is not merely a theoretical prescription. The sum decreases monotonically, so a program can find a suitable $N$ by doubling an initial guess and then using binary search. The answer comes with a guarantee rather than an empirical impression.

A rougher but immediate rule is also available. If there are $m$ modes and every weight is at most $\rho<1$, then

$$
C(q)-T_N(q)\le C(q)m\rho^{N+1}.
$$

Thus a relative occupation error no greater than $\varepsilon$ is guaranteed whenever $m\rho^{N+1}\le\varepsilon$. In the prime system, $\rho=2^{-\beta}$ whenever the prime $2$ is retained. This conservative rule reveals the exponential benefit of each additional occupation level.

## Why this pattern appears elsewhere

The argument is not confined to number theory. A bounded-multiplicity generating function in combinatorics has local factor $1+q+\cdots+q^N$; an unbounded multiset has factor $(1-q)^{-1}$. Truncated bosonic models use the same ladder. In each setting, the theorem says that the relative loss is controlled by the sum of first forbidden weights. The prime interpretation is distinguished not by different algebra, but by the remarkable fact that occupation vectors encode ordinary integers uniquely.

The conditions also mark the boundary of the story. If a weight reaches $1$, the completed geometric ladder diverges. If negative weights are allowed, cancellation destroys the monotone “missing mass” interpretation. The exact geometric identity may survive, but the positive error budget need not. The assumptions $0\le q_i<1$ are therefore structural, not decorative.

## The road ahead

Several natural questions follow. One is to let $x$ and $N$ grow together and prove locally uniform convergence on compact subsets of the half-plane $\operatorname{Re}(s)>1$. Another is to determine the sharp leading term of the occupation defect; inclusion–exclusion predicts dominance by the largest local tails. A third is to extend the real estimate to complex temperature by replacing weights with their absolute values.

More speculative directions ask whether an additional archimedean sector can represent the gamma factor in the completed zeta function, or whether response forms built from occupation fluctuations can illuminate zero-free regions. Those ambitions require substantial new ideas. The present result supplies a disciplined starting point: a finite product with an exact defect, a transparent positivity statement, and an error budget that never confuses missing primes with missing occupations.

The broader message reaches beyond prime numbers. Whenever a finite partition function is built from independent geometric ladders, truncating each ladder produces the same architecture: an exact multiplicative defect and an additive tail bound. What begins as a familiar geometric series becomes a general principle for controlling layered approximations—one cutoff at a time.
