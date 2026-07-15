# Exact Finite-Length Prefactors for Uniform Guesswork

**Aristotle**  
**July 15, 2026**

## Abstract

Guesswork quantifies the number of sequential trials needed to identify a hidden object. When the candidate list is uniform and has cardinality $N=b^k$, logarithmic growth rates describe only the dominant exponential scale. This paper determines the exact first and second moments, their complete finite-length corrections, and the resulting fluctuation laws. If $G$ is uniform on $\{1,\ldots,b^k\}$, then

$$
\mathbb E[G]=\frac{b^k+1}{2},
\qquad
\mathbb E[G^2]=\frac{(b^k+1)(2b^k+1)}{6}.
$$

Consequently, the normalized moments converge to $1/2$ and $1/3$ along every diverging dimension schedule. The exact normalized variance is $(1-b^{-2k})/12$, which converges to $1/12$, and the squared coefficient of variation converges to $1/3$. Thus fluctuations remain comparable to the mean even for exponentially large lists. We give elementary proofs, explicit algorithms for stable evaluation, finite-blocklength error bounds, numerical examples, and interpretations for constrained candidate search, decoding, and machine-learning reranking.

## 1. Introduction

A guessing procedure orders a finite collection of candidates and tests them sequentially until the hidden candidate is found. The random number of trials is the guesswork rank. This model appears in exhaustive search, list decoding, constrained inference, retrieval, and security analysis. In many structured problems the number of remaining candidates is naturally $b^k$: $b$ is an alphabet size and $k$ is a dimension, number of free coordinates, or logarithmic list size.

An exponent-level statement such as $\mathbb E[G]\asymp b^k$ identifies the correct scale but suppresses operationally important information. It does not say whether the leading factor is $1/2$, $1/10$, or a quantity depending on the schedule. Nor does it describe fluctuations. Exact moments supply this missing calibration.

This paper studies the maximally symmetric case: all candidates are equally likely. The simplicity is productive. First, it yields closed forms valid at every finite length. Second, it establishes benchmark constants against which nonuniform systems can be compared. Third, it exposes a continuous limit: after division by $N$, the guessing rank approaches the uniform shape on $[0,1]$.

The principal contributions are:

1. exact formulas for the first and second moments of uniform rank on a list of size $b^k$;
2. exact expansions of the normalized moments, including terms of order $b^{-k}$ and $b^{-2k}$;
3. an exact normalized-variance identity and the limit $1/12$;
4. the limiting squared coefficient of variation $1/3$;
5. schedule-independent asymptotics for every integer sequence $k_n\to\infty$;
6. direct algorithms and diagnostics for numerical use.

## 2. Definitions and setup

### 2.1 Uniform candidate lists

Fix integers $b\ge1$ and $k\ge0$, and let

$$
N=b^k.
$$

Consider an ordered list of $N$ candidates. The hidden candidate is chosen uniformly, and $G$ denotes its position in the order. Therefore

$$
\mathbb P(G=j)=\frac1N,
\qquad 1\le j\le N.
$$

The order itself is immaterial under a uniform prior: every permutation induces the same rank distribution.

### 2.2 Power sums and moments

For real $\rho$ for which the expression is considered, define the raw power sum

$$
S_\rho(N)=\sum_{j=1}^{N}j^\rho.
$$

The uniform guesswork moment of order $\rho$ is

$$
M_\rho(b,k)=\frac1{b^k}S_\rho(b^k)
=\mathbb E[G^\rho].
$$

The present results concern $\rho=1$ and $\rho=2$. Define the variance and squared coefficient of variation by

$$
\operatorname{Var}(G)=\mathbb E[G^2]-\mathbb E[G]^2,
$$

$$
\operatorname{CV}^2(G)=
\frac{\operatorname{Var}(G)}{\mathbb E[G]^2}.
$$

The normalized first moment, second moment, and variance are obtained by dividing by $N$, $N^2$, and $N^2$, respectively.

### 2.3 Diverging schedules

For asymptotics, fix $b\ge2$ and let $k_n$ be any sequence of nonnegative integers satisfying $k_n\to\infty$. Write

$$
N_n=b^{k_n}
$$

and let $G_n$ be uniform on $\{1,\ldots,N_n\}$. No monotonicity of $k_n$ is needed; divergence alone implies $N_n\to\infty$.

## 3. Exact finite-length moments

We begin with two elementary sum identities.

**Lemma 1 (sum of ranks).** For every positive integer $N$,

$$
\sum_{j=1}^{N}j=\frac{N(N+1)}2.
$$

**Proof sketch.** Pair $j$ with $N+1-j$. Every pair sums to $N+1$; handling the central term when $N$ is odd gives the same expression. Alternatively, induction adds $N+1$ to the formula at size $N$. $\square$

**Lemma 2 (sum of squared ranks).** For every positive integer $N$,

$$
\sum_{j=1}^{N}j^2=\frac{N(N+1)(2N+1)}6.
$$

**Proof sketch.** The formula is immediate at $N=1$. Assuming it at $N$, add $(N+1)^2$ and factor the result as $(N+1)(N+2)(2N+3)/6$, which is the claimed formula with $N$ replaced by $N+1$. $\square$

These identities yield the exact moments.

**Theorem 1 (exact first moment).** Let $b\ge1$ and $k\ge0$. For a uniformly located target in a list of size $N=b^k$,

$$
M_1(b,k)=\mathbb E[G]=\frac{b^k+1}{2}.
$$

**Proof sketch.** By uniformity,

$$
\mathbb E[G]=\frac1N\sum_{j=1}^{N}j.
$$

Apply Lemma 1 and cancel $N$. $\square$

The formula includes $b=1$, for which $N=1$ and the unique rank is $1$.

**Theorem 2 (exact second moment).** Under the same assumptions,

$$
M_2(b,k)=\mathbb E[G^2]
=\frac{(b^k+1)(2b^k+1)}6.
$$

**Proof sketch.** Uniformity gives $\mathbb E[G^2]=N^{-1}\sum_{j=1}^{N}j^2$. Apply Lemma 2 and cancel $N$. $\square$

These are exact identities, not asymptotic equivalents. Their expanded normalized forms are

$$
\frac{M_1(b,k)}{b^k}
=\frac12+\frac{1}{2b^k},
$$

and

$$
\frac{M_2(b,k)}{b^{2k}}
=\frac13+\frac{1}{2b^k}+\frac{1}{6b^{2k}}.
$$

The first neglected correction at exponent level is therefore explicit.

## 4. Asymptotic prefactors

**Theorem 3 (universal first- and second-moment prefactors).** Fix an integer $b\ge2$. Let $k_n\to\infty$, set $N_n=b^{k_n}$, and let $G_n$ be uniform on $\{1,\ldots,N_n\}$. Then

$$
\lim_{n\to\infty}\frac{\mathbb E[G_n]}{N_n}=\frac12,
$$

and

$$
\lim_{n\to\infty}\frac{\mathbb E[G_n^2]}{N_n^2}=\frac13.
$$

**Proof sketch.** Since $b\ge2$ and $k_n\to\infty$, one has $N_n\to\infty$ and $N_n^{-1}\to0$. The exact expansions from Theorems 1 and 2 become

$$
\frac{\mathbb E[G_n]}{N_n}
=\frac12+\frac{1}{2N_n},
$$

$$
\frac{\mathbb E[G_n^2]}{N_n^2}
=\frac13+\frac{1}{2N_n}+\frac{1}{6N_n^2}.
$$

All correction terms vanish. $\square$

The theorem is independent of how irregularly the dimension grows. It applies to $k_n=n$, $k_n=\lfloor Rn\rfloor$ for $R>0$, sparse subsequences, and schedules with bounded local decreases, provided only that $k_n$ eventually exceeds every fixed bound.

**Corollary 1 (finite-length error formulas).** Under the hypotheses of Theorem 3,

$$
\left|\frac{\mathbb E[G_n]}{N_n}-\frac12\right|
=\frac{1}{2N_n},
$$

and

$$
\left|\frac{\mathbb E[G_n^2]}{N_n^2}-\frac13\right|
=\frac{1}{2N_n}+\frac{1}{6N_n^2}.
$$

Both errors are positive, so the normalized moments approach their limits from above.

For $k_n=\lfloor Rn\rfloor$, these corrections decay exponentially in blocklength. More explicitly,

$$
\frac{1}{2N_n}=\frac12b^{-\lfloor Rn\rfloor},
$$

and the second-moment correction has the additional term $b^{-2\lfloor Rn\rfloor}/6$.

## 5. Exact fluctuations

Moment prefactors determine the scale but not yet the centered fluctuations. The exact formulas give those as well.

**Theorem 4 (exact normalized variance).** Let $b\ge1$ and $k\ge0$, and set $N=b^k$. Then

$$
\operatorname{Var}(G)=\frac{N^2-1}{12},
$$

or equivalently,

$$
\frac{\operatorname{Var}(G)}{N^2}
=\frac{1-N^{-2}}{12}.
$$

**Proof sketch.** Substitute Theorems 1 and 2 into

$$
\operatorname{Var}(G)=\mathbb E[G^2]-\mathbb E[G]^2.
$$

Using a common denominator of $12$ gives

$$
\frac{2(N+1)(2N+1)-3(N+1)^2}{12}
=\frac{N^2-1}{12}.
$$

Division by $N^2$ yields the normalized identity. $\square$

**Theorem 5 (variance and relative-fluctuation limits).** Under the assumptions of Theorem 3,

$$
\lim_{n\to\infty}
\frac{\operatorname{Var}(G_n)}{N_n^2}
=\frac1{12},
$$

and

$$
\lim_{n\to\infty}
\frac{\operatorname{Var}(G_n)}{\mathbb E[G_n]^2}
=\frac13.
$$

**Proof sketch.** The first limit follows immediately from Theorem 4 and $N_n^{-2}\to0$. For the second, either divide the first normalized limit by the square of the normalized-mean limit, obtaining

$$
\frac{1/12}{(1/2)^2}=\frac13,
$$

or simplify exactly:

$$
\operatorname{CV}^2(G)
=\frac{(N^2-1)/12}{(N+1)^2/4}
=\frac{N-1}{3(N+1)}.
$$

The latter expression converges to $1/3$. $\square$

The nonzero limit has a clear interpretation. Standard deviation and mean both grow linearly in $N$. Thus increasing the list size does not concentrate the search effort around its mean on a relative scale. Uniform guesswork remains intrinsically variable.

## 6. Geometric and distributional interpretation

Define the normalized rank

$$
U_N=\frac{G}{N}.
$$

It is uniform on the grid $\{1/N,2/N,\ldots,1\}$. The normalized moment is

$$
\mathbb E[U_N^\rho]
=\frac1N\sum_{j=1}^{N}\left(\frac{j}{N}\right)^\rho.
$$

This is a right-endpoint Riemann sum for $x^\rho$ on $[0,1]$. For $\rho=1$ and $\rho=2$, the limiting integrals are

$$
\int_0^1x\,dx=\frac12,
\qquad
\int_0^1x^2\,dx=\frac13.
$$

The variance constant is correspondingly

$$
\int_0^1x^2\,dx-
\left(\int_0^1x\,dx\right)^2
=\frac13-\frac14=\frac1{12}.
$$

This viewpoint explains why the constants are universal: the base $b$ and schedule $k_n$ determine only how quickly the grid becomes fine. They do not change its limiting shape.

It also motivates a general conjectural extension for every $\rho>0$:

$$
\frac{M_\rho(b,k)}{(b^k)^\rho}
\longrightarrow\frac1{\rho+1}.
$$

The exact first and second moments are the polynomial cases $\rho=1,2$, where finite-size corrections can be written in closed form.

## 7. Algorithms and numerical evaluation

### 7.1 Closed-form moment algorithm

Given $b$ and $k$, compute the integer $N=b^k$, then evaluate

$$
\mu=\frac{N+1}{2},
\qquad
m_2=\frac{(N+1)(2N+1)}6,
$$

$$
\sigma^2=\frac{N^2-1}{12},
\qquad
c^2=\frac{N-1}{3(N+1)}.
$$

Integer exponentiation by repeated squaring takes $O(\log k)$ multiplications. In a fixed-width arithmetic model the remaining operations are constant time; with arbitrary-precision integers their bit complexity depends on the $O(k\log b)$-bit size of $N$. The algorithm uses $O(1)$ stored large numbers and avoids enumerating the candidate list.

### 7.2 Direct-sum audit algorithm

For moderate $N$, one may independently compute

$$
\frac1N\sum_{j=1}^{N}j
\quad\text{and}\quad
\frac1N\sum_{j=1}^{N}j^2.
$$

This takes $O(N)$ arithmetic operations and $O(1)$ auxiliary space. It is inefficient for large $k$ but valuable as a transparent numerical audit of the closed forms.

### 7.3 Schedule convergence algorithm

For a sequence $k_0,\ldots,k_m$, compute $N_i=b^{k_i}$ and report the four normalized quantities

$$
\frac{\mu_i}{N_i},\qquad
\frac{m_{2,i}}{N_i^2},\qquad
\frac{\sigma_i^2}{N_i^2},\qquad
c_i^2.
$$

Comparing these with $1/2$, $1/3$, $1/12$, and $1/3$ displays convergence and verifies the exact correction scales. Closed forms make the complexity $O(m)$ large-number evaluations rather than $O(\sum_iN_i)$ enumeration.

## 8. Numerical examples

For binary lists, take $b=2$. At $k=4$, $N=16$ and

$$
\mathbb E[G]=8.5,
\qquad
\mathbb E[G^2]=93.5,
$$

$$
\operatorname{Var}(G)=21.25,
\qquad
\operatorname{CV}^2(G)=\frac5{17}\approx0.294118.
$$

The normalized first and second moments are $0.53125$ and $0.365234375$. At $k=10$, $N=1024$; the same quantities are already close to their limits:

$$
\frac{\mathbb E[G]}{N}=0.50048828125,
$$

$$
\frac{\mathbb E[G^2]}{N^2}
\approx0.3338216146,
$$

$$
\frac{\operatorname{Var}(G)}{N^2}
\approx0.0833332539.
$$

For a decimal alphabet with $b=10$ and $k=3$, $N=1000$. The expected rank is $500.5$, while the standard deviation is approximately $288.675$. The standard deviation remains a substantial fraction of the mean, as predicted by the limiting coefficient of variation $1/\sqrt3$.


## 9. Robustness, diagnostics, and finite-size bounds

### 9.1 Independence from the guessing order

For a nonuniform distribution, changing the order changes every guesswork moment. Uniformity is exceptional. Let $\pi$ be any permutation of the $N$ candidates, and let $G_\pi$ denote the rank under that order. For each $j\in\{1,\ldots,N\}$, exactly one candidate occupies position $j$, and that candidate has probability $1/N$. Consequently,

$$
\mathbb P(G_\pi=j)=\frac1N.
$$

Thus all statements in this paper are invariant under arbitrary deterministic reorderings. They also remain valid for an ordering randomized independently of the hidden candidate: conditioning on the random ordering gives a uniform rank, and averaging over the ordering changes nothing.

**Proposition 1 (order invariance).** For a uniform candidate distribution on $N$ elements, every deterministic guessing order induces the same rank law, namely the uniform law on $\{1,\ldots,N\}$. Any independently randomized order induces the same law after averaging.

**Proof sketch.** A deterministic order is a bijection between candidates and rank positions, so each position inherits probability $1/N$. For a random independent order, apply the deterministic statement conditionally and then average. $\square$

This proposition clarifies the boundary of the model. If an observed ordering achieves a mean rank substantially below $(N+1)/2$, then either the target distribution is not uniform or the ordering contains information statistically dependent on the target.

### 9.2 Exact one-sided approximation bounds

The normalized corrections are nonnegative. Therefore, for every $N\ge1$,

$$
\frac12\le\frac{\mathbb E[G]}N\le\frac12+\frac1{2N},
$$

and

$$
\frac13\le\frac{\mathbb E[G^2]}{N^2}
\le\frac13+\frac{2}{3N}.
$$

The second upper bound follows because $1/(6N^2)\le1/(6N)$, so the exact correction is at most $2/(3N)$. The variance approaches from below:

$$
0\le\frac1{12}-\frac{\operatorname{Var}(G)}{N^2}
=\frac1{12N^2}.
$$

The squared coefficient of variation also approaches from below, with exact gap

$$
\frac13-\operatorname{CV}^2(G)
=\frac{2}{3(N+1)}.
$$

These formulas distinguish two convergence speeds. The normalized variance has error of order $N^{-2}$, while the normalized moments and squared coefficient of variation generally have error of order $N^{-1}$.

### 9.3 Quantiles and tail probabilities

Moments summarize the distribution, but the uniform model also gives exact tails. For an integer threshold $t$ with $0\le t\le N$,

$$
\mathbb P(G\le t)=\frac{t}{N},
\qquad
\mathbb P(G>t)=1-\frac{t}{N}.
$$

Hence the $q$-quantile is the smallest integer $t$ satisfying $t/N\ge q$, namely $\lceil qN\rceil$. A service provisioned for only the mean number of guesses, approximately $N/2$, will be exceeded in approximately half of all instances. Provisioning for $90\%$ completion requires approximately $0.9N$ trials, not a small multiple of a concentrated standard error.

The tail formulas agree with the limiting continuous picture. For fixed $x\in[0,1]$,

$$
\mathbb P\left(\frac GN\le x\right)=\frac{\lfloor Nx\rfloor}{N}
$$

when $x<1$, up to the endpoint convention. The difference from $x$ is at most $1/N$. Thus the distribution functions converge uniformly to the distribution function of the continuous uniform law on $[0,1]$. This observation is stronger than convergence of the first two moments and explains why all bounded continuous statistics of normalized rank should have universal limits.

### 9.4 Numerical stability

For very large $k$, converting $N=b^k$ directly to floating point may overflow even though normalized statistics are close to modest constants. Stable evaluation should use $u=b^{-k}$ and the identities

$$
\frac{\mathbb E[G]}N=\frac12+\frac u2,
$$

$$
\frac{\mathbb E[G^2]}{N^2}=\frac13+\frac u2+\frac{u^2}{6},
$$

$$
\frac{\operatorname{Var}(G)}{N^2}=\frac{1-u^2}{12}.
$$

When even $u$ underflows to zero, returning the limiting constants is accurate to within the representable precision. Exact rational arithmetic is preferable when $N$ itself remains computationally manageable.

## 10. Applications

### 9.1 Constrained candidate search

Algebraic or combinatorial constraints often reduce a large ambient space to a list with $b^k$ feasible candidates. If symmetry makes these candidates equiprobable, the present formulas translate dimension directly into operational search cost. The exponent $k$ determines scale; the constants determine expected work and risk.

### 9.2 List decoding and reranking

A decoder or machine-learning model may output a candidate list followed by an expensive validation stage. If the scores inside a residual equivalence class contain no ranking information, the validation rank is uniform. The expected validation count is $(N+1)/2$, not merely “of order $N$,” and the variance warns that per-instance costs remain broadly dispersed.

### 9.3 Security benchmarks

A deliberately flat secret distribution induces uniform rank under any fixed attack order. Exact moments provide a baseline for evaluating departures from uniformity. A normalized mean far below $1/2$ indicates exploitable ordering information; a second moment below $1/3$ indicates a lighter tail than the uniform benchmark.

### 9.4 Finite-blocklength design

Asymptotic constants are often used at moderate dimensions. Here the approximation error is known exactly. A designer requiring first-moment relative error at most $\varepsilon$ needs

$$
\frac{1}{2b^k}\le\varepsilon.
$$

Thus it suffices that

$$
k\ge \frac{\log(1/(2\varepsilon))}{\log b},
$$

with the integer ceiling understood. Similar explicit inequalities follow from the second-moment correction.

## 11. Discussion

The results distinguish exponential order from calibrated asymptotics. Saying that $\mathbb E[G]$ has exponent one in $N$ is compatible with many constants; the exact theorem fixes the constant at $1/2$ and identifies the correction $1/(2N)$. The second moment similarly has exponent two but prefactor $1/3$.

The persistence of relative fluctuations is equally important. In some large systems, averaging creates concentration and makes the mean representative. Uniform rank does not behave that way. Its normalized distribution fills an interval rather than collapsing to a point. The limiting squared coefficient of variation $1/3$ quantifies this fact.

Uniformity is also the boundary between ordering-sensitive and ordering-insensitive search. With a nonuniform prior, an optimal guess order sorts candidates by probability, and moments depend on the entire probability profile. Under uniformity every order is equivalent, allowing list cardinality alone to determine all rank statistics.

## 12. Future work

Several extensions follow naturally. For arbitrary real $\rho>0$, a Riemann-sum argument should establish the prefactor $1/(\rho+1)$. Distributional convergence of $G/N$ to the uniform law on $[0,1]$ would unify all bounded continuous statistics. Exact third and fourth moments would yield finite-length skewness and kurtosis. Finally, nonuniform sources and random algebraic constraints require probabilistic models that derive, rather than assume, the effective candidate distribution.

## 13. Conclusion

For a uniform candidate list of size $N=b^k$, the first two guesswork moments are exactly

$$
\mathbb E[G]=\frac{N+1}{2},
\qquad
\mathbb E[G^2]=\frac{(N+1)(2N+1)}6.
$$

These identities produce normalized limits $1/2$ and $1/3$, exact normalized variance $(1-N^{-2})/12$, limiting normalized variance $1/12$, and limiting squared coefficient of variation $1/3$. The conclusions hold along every diverging dimension schedule. Beyond their elementary form, the results provide precise finite-length calibration for any application in which a constrained candidate list is effectively uniform.
## Appendix A. A compact derivation from generating identities

For completeness, the two moment formulas can also be recovered from finite-difference identities. The relation

$$
(j+1)^2-j^2=2j+1
$$

sums from $j=0$ through $N$ to give

$$
(N+1)^2=2\sum_{j=0}^{N}j+(N+1),
$$

which rearranges to the rank-sum formula. Likewise,

$$
(j+1)^3-j^3=3j^2+3j+1.
$$

Summing and substituting the first power sum yields the square-sum formula. This telescoping route emphasizes that exact guesswork moments are discrete antiderivatives of polynomial increments.

The normalized expansions then require no limiting theorem beyond $N^{-1}\to0$. Writing $u=N^{-1}$ gives

$$
\frac{\mathbb E[G]}N=\frac{1+u}{2},
\qquad
\frac{\mathbb E[G^2]}{N^2}=\frac{2+3u+u^2}{6}.
$$

Centering the second expression by the square of the first cancels the order-$u$ term:

$$
\left(\frac13+\frac u2+\frac{u^2}{6}\right)
-
\left(\frac12+\frac u2\right)^2
=\frac{1-u^2}{12}.
$$

This cancellation explains why normalized variance reaches its limiting value with error of order $N^{-2}$ even though each raw normalized moment has an order-$N^{-1}$ correction.

## Appendix B. Reproducible numerical protocol

A numerical study can be reproduced in four steps. First, choose a base $b\ge2$ and a finite dimension schedule. Second, compute $N=b^k$ with integer arithmetic. Third, evaluate the exact rational formulas before converting to decimal output. Fourth, compare direct sums only at dimensions small enough to enumerate comfortably. Exact equality between direct and closed-form values tests the implementation; it is not an approximation.

Monte Carlo sampling serves a different purpose. Drawing independent ranks uniformly from $\{1,\ldots,N\}$ illustrates sampling variation, but it is unnecessary for evaluating the theorem. If $T$ samples are used, the empirical normalized mean fluctuates with standard deviation approximately

$$
\sqrt{\frac{1}{12T}},
$$

for large $N$. Notably, normalization removes $N$ from this sampling-error scale. Increasing the candidate list does not by itself improve a Monte Carlo estimate; increasing the number of trials does.

For visualization, plotting against $k$ on a linear horizontal axis naturally displays exponential convergence because $N^{-1}=b^{-k}$. A logarithmic vertical axis applied to the absolute error makes the first-moment correction a straight line of slope $-\log b$. The normalized-variance error decays twice as fast, with slope $-2\log b$. These plots provide a direct graphical check of the exact finite-length orders.

## Appendix C. Scope of inference

The formulas determine rank statistics from uniformity and cardinality alone. They do not assert that a particular coding, retrieval, or inference system produces a uniform candidate list. That premise must be justified by symmetry, modeling assumptions, or data. Conditional on the premise, however, no independence among internal candidate features is required. The candidates may have complicated algebraic structure; only the target probabilities and the one-to-one assignment of candidates to ranks matter.

Similarly, the results concern sequential testing without early batch acceptance or variable per-candidate cost. If trial costs differ, the total work is a weighted partial sum rather than the rank itself. The uniform-rank law remains available as an ingredient, but additional cost information is needed. This separation is useful: the present theory isolates uncertainty about position, allowing application-specific cost models to be layered on top without changing the rank calculation.
