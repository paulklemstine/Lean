# The Shape of a Search: Exact Constants in Uniform Guesswork

Suppose a locked device accepts one code from a list of $N$ possibilities. You know that every code is equally likely, and you test the possibilities in some fixed order. Sometimes you are lucky and succeed immediately; sometimes the correct code sits at the very end. How much work should you expect?

The familiar answer is “about half the list.” That answer is right, but it hides a richer story. The average is only one feature of the search. The second moment measures the weight of long searches; the variance describes how widely the required work fluctuates; and the coefficient of variation tells us whether uncertainty becomes negligible as the list grows. For uniform guessing, all of these quantities admit exact formulas, including their finite-size corrections.

These formulas matter whenever uncertainty is represented by a uniformly populated list: exhaustive decoding, random indexing, anonymized candidate sets, password search under a deliberately flat prior, or a coset of candidates produced by algebraic constraints. They turn a rough exponential estimate into a calibrated prediction.

## Rank is the random variable

Number the candidate positions from $1$ through $N$. If the hidden item is uniform, its rank $G$ is uniform on

$$
\{1,2,\ldots,N\}.
$$

The general moment of order $\rho$ is

$$
M_\rho(N)=\mathbb E[G^\rho]
=\frac{1}{N}\sum_{j=1}^{N}j^\rho.
$$

In many coding and machine-learning settings the list size is a power, $N=b^k$, where $b$ is an alphabet size and $k$ is an effective dimension. Then

$$
M_\rho(b,k)=b^{-k}\sum_{j=1}^{b^k}j^\rho.
$$

This definition already separates two issues. The factor $b^k$ controls the exponential scale, while the normalized power sum determines the constant in front. An exponent alone says whether the work resembles $b^k$ or $b^{2k}$; an exact prefactor says how much of that scale is actually realized.

## The midpoint law

The first exact result is the mean-rank theorem.

**Mean-Rank Theorem.** For every integer base $b\ge 1$ and every nonnegative integer $k$, a uniform search through $N=b^k$ candidates satisfies

$$
\mathbb E[G]=\frac{b^k+1}{2}.
$$

The proof is the classic pairing argument. The first and last ranks add to $N+1$, as do the second and next-to-last, and so on. Equivalently, the identity

$$
1+2+\cdots+N=\frac{N(N+1)}{2}
$$

gives the result after division by $N$.

The small $+1$ is not cosmetic. It is the exact finite-list correction. After normalizing by $N$, the theorem becomes

$$
\frac{\mathbb E[G]}{N}=\frac12+\frac{1}{2N}.
$$

Thus the celebrated constant $1/2$ is approached from above, with an error exactly equal to $1/(2N)$.

## The long tail leaves a second signature

A mean does not distinguish a tightly clustered search time from one with frequent extremes. The second moment does.

**Second-Moment Theorem.** Under the same assumptions,

$$
\mathbb E[G^2]=\frac{(b^k+1)(2b^k+1)}{6}.
$$

This follows from the square-sum identity

$$
1^2+2^2+\cdots+N^2=\frac{N(N+1)(2N+1)}{6}.
$$

Dividing by $N^2$ reveals every correction:

$$
\frac{\mathbb E[G^2]}{N^2}
=\frac13+\frac{1}{2N}+\frac{1}{6N^2}.
$$

The leading constant is $1/3$, not $(1/2)^2=1/4$. That gap is the mathematical trace of persistent fluctuations. Even an enormous uniform list contains searches spread across the entire range from nearly immediate success to nearly complete exhaustion.

## Variability does not wash away

Subtracting the square of the mean from the second moment yields the exact variance:

$$
\operatorname{Var}(G)=\frac{N^2-1}{12}.
$$

Equivalently,

$$
\frac{\operatorname{Var}(G)}{N^2}
=\frac{1-N^{-2}}{12}.
$$

This is the **Normalized-Variance Theorem**. As $N$ grows, the normalized variance tends to $1/12$. The standard deviation therefore behaves like $N/\sqrt{12}$, while the mean behaves like $N/2$. Both remain proportional to the full list size.

A scale-free measure makes this especially clear. The squared coefficient of variation is variance divided by the squared mean:

$$
\operatorname{CV}^2(G)
=\frac{\operatorname{Var}(G)}{\mathbb E[G]^2}
=\frac{N-1}{3(N+1)}.
$$

Hence

$$
\operatorname{CV}^2(G)\longrightarrow\frac13.
$$

So relative uncertainty does not disappear. Doubling the dimension may make the candidate set exponentially larger, but it does not make uniform guesswork relatively more predictable.

## Any diverging dimension follows the same laws

The asymptotic conclusions do not require dimension to grow one step at a time. Let $k_n$ be any sequence of nonnegative integers with $k_n\to\infty$, and fix $b\ge2$. Set $N_n=b^{k_n}$. Since $N_n\to\infty$, the exact formulas immediately give the **Uniform-Prefactor Limit Theorem**:

$$
\frac{\mathbb E[G_n]}{N_n}\longrightarrow\frac12,
\qquad
\frac{\mathbb E[G_n^2]}{N_n^2}\longrightarrow\frac13,
$$

$$
\frac{\operatorname{Var}(G_n)}{N_n^2}\longrightarrow\frac1{12},
\qquad
\frac{\operatorname{Var}(G_n)}{\mathbb E[G_n]^2}
\longrightarrow\frac13.
$$

This flexibility is useful for blocklength schedules such as $k_n=\lfloor Rn\rfloor$. In that case the first normalized error is exactly $1/(2b^{\lfloor Rn\rfloor})$, while the second normalized error is

$$
\frac{1}{2b^{\lfloor Rn\rfloor}}+
\frac{1}{6b^{2\lfloor Rn\rfloor}}.
$$

The convergence is exponentially fast in $n$ whenever $R>0$.


## A clock with an unusually broad hand

It is tempting to hear “the average is half the list” and imagine most searches ending near the midpoint. Uniform rank does not support that picture. Consider a list divided into four equal quarters. Exactly one quarter of searches finish in the first quarter, exactly one quarter finish in the last quarter, and the same is true of each middle quarter, apart from harmless rounding when $N$ is not divisible by $4$. Large lists make this pattern smoother, not narrower.

That observation explains the variance constant without algebra. After scaling the rank by $N$, the search endpoint is spread nearly uniformly from $0$ to $1$. Its mean is the midpoint $1/2$, but its standard deviation approaches

$$
\frac{1}{\sqrt{12}}\approx 0.288675.
$$

Relative to the mean, the limiting standard deviation is

$$
\frac{1/\sqrt{12}}{1/2}=\frac{1}{\sqrt3}\approx0.577350.
$$

A standard deviation equal to roughly $58\%$ of the mean is operationally large. Capacity planning based only on the average can therefore be misleading. If each guess invokes a costly simulation, database query, physical test, or human review, then different instances naturally consume very different resources even though all share the same list size.

## Exact arithmetic as a design tool

The closed forms make planning immediate. Suppose a binary system leaves $2^{20}=1{,}048{,}576$ candidates. The expected number of tests is

$$
\frac{2^{20}+1}{2}=524{,}288.5.
$$

The normalized mean exceeds $1/2$ by only $1/2^{21}$, yet the standard deviation is still about $2^{20}/\sqrt{12}$, or roughly $302{,}697$. The asymptotic prefactor is already extraordinarily accurate, while the realized workload remains highly variable. Approximation error and statistical variability are different phenomena: one can be tiny while the other is large.

The formulas also answer inverse questions. If a designer wants the normalized mean to lie within $\varepsilon$ of $1/2$, the exact correction requires

$$
\frac{1}{2b^k}\le \varepsilon.
$$

Solving for dimension gives

$$
k\ge \frac{\log(1/(2\varepsilon))}{\log b},
$$

rounded upward to an integer. No simulation is necessary. A desired accuracy can be translated directly into a minimum list dimension.

## Why a flat list is the essential model

Uniformity may sound idealized, but it is often a design objective. A cryptographic secret is intended to look flat to an adversary. A randomized code may leave a candidate coset whose members are symmetric. A balanced retrieval system may deliberately remove ranking information. In each case the search rank is approximately uniform, and these constants become benchmarks.

They are also diagnostic. If observed normalized means differ greatly from $1/2$, then the candidates are not behaving as a flat list under the chosen order. If the normalized second moment differs from $1/3$, the tail structure is different even if the mean happens to agree. The pair of constants separates central effort from tail risk.

For machine-learning systems, candidate generation and reranking frequently produce a list rather than one answer. When scores are uninformative within a constrained class, testing or validating candidates reduces to uniform guesswork. Knowing only that the list has size $b^k$ gives the exponential scale. The exact formulas add operational quantities: expected validations, variability across instances, and finite-size error bars.

## From sums to a continuous picture

The constants have a geometric explanation. Divide the rank by the list size and write $U_N=G/N$. Its possible values form the evenly spaced grid

$$
\left\{\frac1N,\frac2N,\ldots,1\right\}.
$$

As $N$ increases, this grid fills the interval $[0,1]$. The averages of $U_N$ and $U_N^2$ approach the corresponding areas under the curves $x$ and $x^2$:

$$
\int_0^1x\,dx=\frac12,
\qquad
\int_0^1x^2\,dx=\frac13.
$$

This suggests the broader law

$$
\frac{\mathbb E[G^\rho]}{N^\rho}
\longrightarrow
\int_0^1x^\rho\,dx
=\frac{1}{\rho+1}
$$

for every positive real $\rho$. The first two cases are not isolated coincidences; they are the first visible moments of a uniform limiting shape.

## What the constants teach us

The exponent says that the mean search cost grows like $b^k$ and the second moment like $b^{2k}$. The constants say more:

* a uniform search consumes asymptotically half its candidate list on average;
* its squared rank consumes one third of the squared scale;
* its variance occupies one twelfth of the squared scale;
* its relative fluctuations remain substantial, with limiting squared coefficient of variation $1/3$;
* and all corrections are explicit at finite length.

This is a small mathematical model with a broad lesson. In exponential problems, growth rates are only the silhouette. Exact constants reveal the shape: the typical burden, the tail, the variability, and the speed at which asymptotic intuition becomes trustworthy.
## A benchmark, not a promise

The uniform model should be read as a clean reference point. Real candidate lists may contain unequal probabilities, side information, adaptive tests, or correlations between the ordering and the hidden item. Those features can improve a well-designed search or expose a vulnerable one. The value of the flat model is that it identifies exactly what list size alone can predict. Once $N$ is known, there are no hidden distributional parameters: every order has the same law, every quantile is determined, and the first two moments follow immediately.

That makes the constants useful in experiments. A measured normalized mean below $1/2$ signals informative ranking. A mean near $1/2$ paired with a second moment far from $1/3$ signals that the center may look uniform while the tail does not. Exact benchmarks turn qualitative claims such as “the list seems flat” into quantitative comparisons. They tell us not only how an idealized search grows, but precisely where a real search departs from that ideal.
