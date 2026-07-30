# The Euler–Mascheroni Constant as Accumulated Information Divergence

## Abstract

We identify the Euler–Mascheroni constant with the cumulative Kullback–Leibler divergence along the sequence of exponential distributions whose rates are the positive integers. For positive rates $\lambda$ and $\mu$, write

$$
D(\lambda\|\mu)=\log\!\left(\frac{\lambda}{\mu}\right)+\frac{\mu}{\lambda}-1
$$

for the divergence from the exponential law of rate $\lambda$ to that of rate $\mu$. We prove that the divergence between consecutive integer rates is exactly the classical positive Euler–Mascheroni summand,

$$
D(k+1\|k+2)=\frac{1}{k+1}-\log\!\left(\frac{k+2}{k+1}\right),
$$

and consequently

$$
\gamma=\sum_{k=0}^{\infty}D(k+1\|k+2).
$$

The finite sum through $k=n-1$ is exactly $H_n-\log(n+1)$ and converges increasingly to $\gamma$. Every summand is strictly positive and satisfies the explicit bounds

$$
D(k+1\|k+2)\le \frac{1}{(k+1)(2k+3)}
\le \frac{1}{2(k+1)^2}.
$$

We also establish general structural identities for exponential divergence: nonnegativity with equality exactly at equal rates, invariance under common rescaling, and the symmetrization formula

$$
D(\lambda\|\mu)+D(\mu\|\lambda)
=\frac{(\lambda-\mu)^2}{\lambda\mu}
$$

for positive rates. These results give a self-contained information-theoretic interpretation of $\gamma$, expose the second-order geometry of nearby rates, and provide simple numerical algorithms and rigorous termwise controls.

## 1. Introduction

The Euler–Mascheroni constant is defined by the asymptotic difference between the harmonic numbers and the natural logarithm:

$$
\gamma=\lim_{n\to\infty}\left(H_n-\log n\right),
\qquad
H_n=\sum_{j=1}^{n}\frac1j.
$$

It marks the persistent discrepancy between discrete reciprocal accumulation and its continuous logarithmic approximation. Despite the elementary nature of this definition, the arithmetic status of $\gamma$ remains unknown: in particular, neither rationality nor irrationality has been established.

A productive approach to a classical constant is to seek representations that reveal additional structure. The representation studied here connects $\gamma$ to information theory. The relevant probability models are exponential distributions, which describe memoryless waiting times. The exponential law of rate $\lambda>0$ has density

$$
p_\lambda(x)=\lambda e^{-\lambda x},\qquad x\ge0.
$$

For two probability densities $p$ and $q$, their Kullback–Leibler divergence is

$$
D_{\mathrm{KL}}(p\|q)
=\int p(x)\log\!\left(\frac{p(x)}{q(x)}\right)dx,
$$

whenever the integral is defined. It quantifies the expected log-likelihood penalty incurred by using $q$ in place of the data-generating model $p$. It is nonnegative but generally asymmetric.

For exponential laws the integral has a closed form depending only on the ratio of rates. The elementary expression is sufficiently rich to encode the standard positive series for $\gamma$. The central observation is that the transition from rate $k+1$ to rate $k+2$ costs exactly

$$
\frac{1}{k+1}-\log\!\left(1+\frac{1}{k+1}\right),
$$

which is the difference between a relative increment and its logarithm. Summing these costs telescopes the logarithms and reconstructs the shifted harmonic approximation $H_n-\log(n+1)$.

This paper develops that observation from first principles. Section 2 defines the analytic and information-theoretic quantities. Section 3 proves the elementary inequalities used throughout. Section 4 establishes the finite and infinite accumulated-divergence identities. Section 5 derives rational inverse-square bounds. Section 6 studies scale invariance, equality cases, and symmetrization. Sections 7 and 8 present numerical algorithms and applications, followed by discussion and future directions.

## 2. Definitions and preliminary identities

### 2.1. Harmonic approximants

For each integer $n\ge0$, define the harmonic number by

$$
H_n=\sum_{j=1}^{n}\frac1j,
$$

with $H_0=0$. Define the shifted Euler–Mascheroni approximant

$$
G_n=H_n-\log(n+1).
$$

Because $\log(n+1)-\log n\to0$, the standard definition of $\gamma$ implies

$$
\lim_{n\to\infty}G_n=\gamma.
$$

The shift is useful because $G_0=0$ and its successive increments form a positive series.

**Definition 2.1 (Euler–Mascheroni increment).** For each integer $k\ge0$, let

$$
g_k=\frac{1}{k+1}-\log\!\left(\frac{k+2}{k+1}\right).
$$

Since $(k+2)/(k+1)=1+1/(k+1)$, the increment compares the linear quantity $1/(k+1)$ with the logarithm of the corresponding multiplicative change.

### 2.2. Exponential divergence

**Definition 2.2 (Exponential Kullback–Leibler divergence).** For positive rates $\lambda$ and $\mu$, define

$$
D(\lambda\|\mu)
=\log\!\left(\frac{\lambda}{\mu}\right)+\frac{\mu}{\lambda}-1.
$$

This is the KL divergence from the exponential law of rate $\lambda$ to the exponential law of rate $\mu$.

To derive the formula, observe that

$$
\log\!\left(\frac{p_\lambda(x)}{p_\mu(x)}\right)
=\log\!\left(\frac{\lambda}{\mu}\right)-(\lambda-\mu)x.
$$

Taking expectation under $p_\lambda$ and using $\mathbb E_\lambda[X]=1/\lambda$ gives

$$
D_{\mathrm{KL}}(p_\lambda\|p_\mu)
=\log\!\left(\frac{\lambda}{\mu}\right)
-\frac{\lambda-\mu}{\lambda}
=\log\!\left(\frac{\lambda}{\mu}\right)+\frac{\mu}{\lambda}-1.
$$

The formula depends only on the dimensionless ratio $\mu/\lambda$.

## 3. Logarithmic inequalities and positivity

The basic inequality behind KL nonnegativity is the tangent-line bound for the logarithm.

**Lemma 3.1 (Logarithmic tangent bound).** For every $x>0$,

$$
\log x\le x-1,
$$

with equality if and only if $x=1$.

**Proof sketch.** Let $h(x)=x-1-\log x$. Then

$$
h'(x)=1-\frac1x=\frac{x-1}{x}.
$$

Thus $h$ decreases on $(0,1)$ and increases on $(1,\infty)$, attaining its unique minimum $h(1)=0$ at $x=1$. This proves both the inequality and its equality condition. $\square$

**Theorem 3.2 (Gibbs inequality for exponential rates).** If $\lambda,\mu>0$, then

$$
D(\lambda\|\mu)\ge0.
$$

Equality holds if and only if $\lambda=\mu$. In particular, distinct positive rates have strictly positive divergence.

**Proof sketch.** Put $x=\mu/\lambda>0$. Then

$$
D(\lambda\|\mu)=x-1-\log x.
$$

Lemma 3.1 gives nonnegativity. Equality occurs exactly when $x=1$, equivalent to $\lambda=\mu$. $\square$

**Corollary 3.3 (Strict positivity of the Euler–Mascheroni increments).** For every integer $k\ge0$,

$$
g_k>0.
$$

**Proof sketch.** Apply the strict form of Lemma 3.1 to

$$
x=\frac{k+2}{k+1}>1.
$$

Because $x-1=1/(k+1)$, one obtains

$$
\log\!\left(\frac{k+2}{k+1}\right)<\frac{1}{k+1},
$$

which is precisely $g_k>0$. $\square$

## 4. The accumulated-information representation

We first establish the finite identity from which the infinite representation follows.

**Lemma 4.1 (Telescoping logarithms).** For every integer $n\ge0$,

$$
\sum_{k=0}^{n-1}
\log\!\left(\frac{k+2}{k+1}\right)
=\log(n+1).
$$

**Proof sketch.** The assertion is immediate for $n=0$. For $n\ge1$, use the addition law for logarithms and telescope the product:

$$
\begin{aligned}
\sum_{k=0}^{n-1}\log\!\left(\frac{k+2}{k+1}\right)
&=\log\!\left(\prod_{k=0}^{n-1}\frac{k+2}{k+1}\right)\\
&=\log\!\left(
\frac21\cdot\frac32\cdots\frac{n+1}{n}
\right)\\
&=\log(n+1).
\end{aligned}
$$

All factors are positive, so the logarithmic product rule applies. $\square$

**Theorem 4.2 (Finite positive-series identity).** For every integer $n\ge0$,

$$
\sum_{k=0}^{n-1}g_k=H_n-\log(n+1)=G_n.
$$

**Proof sketch.** Sum the definition of $g_k$. The reciprocal part is

$$
\sum_{k=0}^{n-1}\frac1{k+1}=H_n,
$$

while Lemma 4.1 identifies the logarithmic part with $\log(n+1)$. Subtraction yields the result. $\square$

**Theorem 4.3 (Consecutive-rate bridge).** For every integer $k\ge0$,

$$
D(k+1\|k+2)=g_k.
$$

**Proof sketch.** Substitute $\lambda=k+1$ and $\mu=k+2$ into Definition 2.2:

$$
\begin{aligned}
D(k+1\|k+2)
&=\log\!\left(\frac{k+1}{k+2}\right)
 +\frac{k+2}{k+1}-1\\
&=-\log\!\left(\frac{k+2}{k+1}\right)
 +\frac1{k+1}\\
&=g_k.
\end{aligned}
$$

$\square$

The finite information identity is now immediate.

**Theorem 4.4 (Cumulative divergence formula).** For every integer $n\ge0$,

$$
\sum_{k=0}^{n-1}D(k+1\|k+2)
=H_n-\log(n+1).
$$

**Proof sketch.** Replace each divergence by $g_k$ using Theorem 4.3, then apply Theorem 4.2. $\square$

**Theorem 4.5 (Accumulated-Information Theorem).** The Euler–Mascheroni constant is the infinite cumulative KL divergence along the integer-rate exponential family:

$$
\boxed{
\gamma=\sum_{k=0}^{\infty}D(k+1\|k+2)
}.
$$

Equivalently,

$$
\gamma=\sum_{k=0}^{\infty}
\left[
\frac1{k+1}-\log\!\left(\frac{k+2}{k+1}\right)
\right].
$$

The partial sums are strictly increasing and converge to $\gamma$.

**Proof sketch.** By Theorem 4.4, the $n$th partial sum is $G_n$. By the definition of the Euler–Mascheroni constant and the fact that $\log(n+1)-\log n\to0$, one has $G_n\to\gamma$. Strict increase follows from Theorem 3.2 or Corollary 3.3, since every adjacent pair of rates is distinct. $\square$

This theorem interprets $\gamma$ as accumulated model discrepancy. It is important that the orientation is from rate $k+1$ to rate $k+2$; reversing every arrow produces a different series because KL divergence is asymmetric.

## 5. Rational term bounds and quadratic decay

The positivity result gives a lower bound of zero. A useful upper bound follows from a rational approximation to $\log(1+x)$.

**Lemma 5.1 (Rational lower bound for the logarithm).** For every $x>0$,

$$
\log(1+x)\ge\frac{2x}{2+x}.
$$

The inequality is strict for $x>0$.

**Proof sketch.** Define

$$
f(x)=\log(1+x)-\frac{2x}{2+x}.
$$

Then $f(0)=0$. Direct differentiation yields

$$
\begin{aligned}
f'(x)
&=\frac1{1+x}-\frac4{(2+x)^2}\\
&=\frac{(2+x)^2-4(1+x)}{(1+x)(2+x)^2}\\
&=\frac{x^2}{(1+x)(2+x)^2}.
\end{aligned}
$$

For $x>0$, the numerator and denominator are positive, so $f'(x)>0$. Hence $f(x)>f(0)=0$. $\square$

**Theorem 5.2 (Rational majorant for each increment).** For every integer $k\ge0$,

$$
0<g_k\le\frac{1}{(k+1)(2k+3)}.
$$

**Proof sketch.** Set $x=1/(k+1)$ in Lemma 5.1. Since

$$
\frac{2x}{2+x}
=\frac{2}{2k+3},
$$

we obtain

$$
\log\!\left(1+\frac1{k+1}\right)
\ge\frac{2}{2k+3}.
$$

Therefore

$$
\begin{aligned}
g_k
&=\frac1{k+1}-\log\!\left(1+\frac1{k+1}\right)\\
&\le\frac1{k+1}-\frac2{2k+3}\\
&=\frac1{(k+1)(2k+3)}.
\end{aligned}
$$

Strict positivity was proved in Corollary 3.3. $\square$

**Corollary 5.3 (Inverse-square majorant).** For every integer $k\ge0$,

$$
0<g_k\le\frac1{2(k+1)^2}.
$$

**Proof sketch.** Since $2k+3\ge2k+2=2(k+1)$,

$$
(k+1)(2k+3)\ge2(k+1)^2.
$$

Taking positive reciprocals and applying Theorem 5.2 proves the claim. $\square$

The estimate makes the scale of the increments explicit. A Taylor expansion suggests

$$
x-\log(1+x)=\frac{x^2}{2}-\frac{x^3}{3}+O(x^4),
$$

so with $x=1/(k+1)$ the leading behavior is $1/[2(k+1)^2]$. Corollary 5.3 captures this natural leading scale as a rigorous upper bound without invoking an asymptotic expansion.

The inverse-square control also proves convergence independently by comparison with the convergent series $\sum_{j=1}^{\infty}1/j^2$. More refined summation of the rational majorant can provide explicit tail estimates; developing sharp remainder constants is a natural continuation of the present results.

## 6. Structural properties of exponential divergence

### 6.1. Scale invariance

**Theorem 6.1 (Common-scale invariance).** Let $\lambda$ and $\mu$ be positive rates and let $c>0$. Then

$$
D(c\lambda\|c\mu)=D(\lambda\|\mu).
$$

**Proof sketch.** Substitute into the closed form:

$$
\begin{aligned}
D(c\lambda\|c\mu)
&=\log\!\left(\frac{c\lambda}{c\mu}\right)
 +\frac{c\mu}{c\lambda}-1\\
&=\log\!\left(\frac{\lambda}{\mu}\right)
 +\frac{\mu}{\lambda}-1\\
&=D(\lambda\|\mu).
\end{aligned}
$$

$\square$

Thus divergence is independent of a common choice of time unit. It depends only on relative rate. More precisely, if $r=\mu/\lambda$, then

$$
D(\lambda\|\mu)=r-1-\log r.
$$

The entire two-parameter family therefore reduces to a one-variable convex function of a ratio.

### 6.2. Directionality and symmetrization

The divergence is asymmetric because generally

$$
D(\lambda\|\mu)\ne D(\mu\|\lambda).
$$

Nevertheless, the sum of the two directions simplifies exactly.

**Theorem 6.2 (Symmetrized exponential divergence).** For positive rates $\lambda$ and $\mu$,

$$
D(\lambda\|\mu)+D(\mu\|\lambda)
=\frac{\lambda}{\mu}+\frac{\mu}{\lambda}-2.
$$

Equivalently,

$$
\boxed{
D(\lambda\|\mu)+D(\mu\|\lambda)
=\frac{(\lambda-\mu)^2}{\lambda\mu}
}.
$$

**Proof sketch.** Add the two closed forms. The logarithms cancel because

$$
\log(\lambda/\mu)+\log(\mu/\lambda)=0.
$$

This leaves

$$
\frac{\lambda}{\mu}+\frac{\mu}{\lambda}-2.
$$

Putting the expression over the common denominator $\lambda\mu$ gives

$$
\frac{\lambda^2+\mu^2-2\lambda\mu}{\lambda\mu}
=\frac{(\lambda-\mu)^2}{\lambda\mu}.
$$

$\square$

The square form simultaneously proves nonnegativity and identifies the equality case. It is also a precise local geometry: when $\mu=\lambda+\delta$ with $|\delta|$ small relative to $\lambda$, the symmetrized divergence is of order $(\delta/\lambda)^2$.

**Corollary 6.3 (Consecutive-rate symmetrization).** For every integer $k\ge0$,

$$
D(k+1\|k+2)+D(k+2\|k+1)
=\frac1{(k+1)(k+2)}.
$$

**Proof sketch.** Apply Theorem 6.2 with $\lambda=k+1$ and $\mu=k+2$. Their difference has square $1$, yielding the stated rational expression. $\square$

This identity offers a contrast. The forward term contributing to $\gamma$ contains a logarithm, while the sum of forward and reverse terms is purely rational.

## 7. Numerical algorithms

The results lead to several straightforward numerical procedures. They are presented here as mathematical algorithms; implementation requires only harmonic summation and logarithms.

### 7.1. Direct accumulated-divergence summation

Given $n\ge0$, compute

$$
S_n=\sum_{k=0}^{n-1}D(k+1\|k+2).
$$

By Theorem 4.4, $S_n=H_n-\log(n+1)$. The algorithm requires $n$ iterations, $O(n)$ arithmetic operations, and $O(1)$ auxiliary storage if the sum is accumulated in place. For numerical stability, each term may be evaluated as

$$
g_k=\frac1{k+1}-\log1p\!\left(\frac1{k+1}\right),
$$

where $\log1p(x)$ is a standard routine designed to evaluate $\log(1+x)$ accurately for small $x$. This avoids forming a ratio close to $1$ and then taking its logarithm.

### 7.2. Telescoped harmonic-logarithm evaluation

The same quantity can be computed by

$$
S_n=H_n-\log(n+1).
$$

This also takes $O(n)$ time and $O(1)$ auxiliary storage. Comparing this evaluation with termwise divergence summation is a useful numerical consistency test. In exact mathematics the two are identical; finite-precision discrepancies diagnose accumulated rounding error.

### 7.3. Verification of term envelopes

For each $k$ in a finite range, compute

$$
g_k,
\qquad
R_k=\frac1{(k+1)(2k+3)},
\qquad
Q_k=\frac1{2(k+1)^2}.
$$

Theorems 5.2 and Corollary 5.3 predict

$$
0<g_k\le R_k\le Q_k.
$$

This procedure is $O(n)$ in time for $n$ tested indices and can record the ratios $g_k/R_k$ and $g_k/Q_k$. Since $g_k\sim1/[2(k+1)^2]$, the ratio $g_k/Q_k$ approaches $1$ as $k$ grows.

### 7.4. Symmetry diagnostics

For arbitrary positive rates $\lambda$ and $\mu$, calculate the two directed divergences and compare their sum with

$$
\frac{(\lambda-\mu)^2}{\lambda\mu}.
$$

This demonstrates asymmetry at the directed level and exact symmetry after addition. Repeating the computation with $c\lambda$ and $c\mu$ checks scale invariance numerically.

## 8. Applications and interpretations

### 8.1. Memoryless processes across scales

Exponential distributions model waiting times in idealized Poisson processes, radioactive decay, reliability systems, and queueing models. A rate change from $\lambda$ to $\mu$ represents a change in the pace of events. The quantity $D(\lambda\|\mu)$ measures the expected information penalty of modeling observations generated at rate $\lambda$ as though they came from rate $\mu$.

The integer ladder $1,2,3,\ldots$ is a canonical scale progression. Theorem 4.5 says that its total forward adjacent penalty is finite and equals $\gamma$. Although the absolute rate increments are always one, their relative size decreases. Consequently, the models become progressively harder to distinguish, and their divergences decay quadratically.

### 8.2. Discrete accumulation versus continuous growth

The identity illuminates a recurring role of $\gamma$. The logarithm records multiplicative growth:

$$
\log(n+1)=\sum_{k=0}^{n-1}\log\!\left(1+\frac1{k+1}\right),
$$

while the harmonic number records the corresponding first-order additive approximation:

$$
H_n=\sum_{k=0}^{n-1}\frac1{k+1}.
$$

Each information increment is the local error made by replacing $\log(1+x)$ with its tangent approximation $x$. The Euler–Mascheroni constant is the accumulated local linearization error along the specific sequence $x=1,1/2,1/3,\ldots$.

Thus the information interpretation and the classical sum-integral interpretation share a mechanism: both compare a nonlinear logarithmic change with a linear reciprocal increment.

### 8.3. A one-dimensional information geometry

Scale invariance allows rates to be represented by logarithmic coordinates. Set $u=\log\lambda$ and $v=\log\mu$. Then $\mu/\lambda=e^{v-u}$ and

$$
D(\lambda\|\mu)=e^{v-u}-1-(v-u).
$$

For small $h=v-u$,

$$
e^h-1-h=\frac{h^2}{2}+O(h^3).
$$

This explains the quadratic local behavior. The symmetrized formula gives an exact expression in the original rates and, in logarithmic coordinates, becomes

$$
e^h+e^{-h}-2=2(\cosh h-1).
$$

The adjacent integer rates satisfy

$$
h_k=\log(k+2)-\log(k+1)
=\log\!\left(1+\frac1{k+1}\right),
$$

which tends to zero. The series for $\gamma$ therefore accumulates a sequence of increasingly local information-geometric displacements.

### 8.4. Computation and diagnostics

The finite identity supplies two mathematically equivalent routes to the same approximation: direct summation of positive divergences and evaluation of a harmonic sum minus a logarithm. Positive summation avoids cancellation between large quantities, while the telescoped formula is conceptually compact. In high-precision work, compensated summation and stable evaluation of $\log(1+x)$ can be used to control roundoff.

The rational majorants provide per-step certificates that require no logarithmic comparison after evaluation. They also help identify implementation errors: a computed term outside the interval

$$
\left(0,\frac1{(k+1)(2k+3)}\right]
$$

is inconsistent with the theory.

## 9. General rate chains

The two-rate identities naturally extend the viewpoint from the integer ladder to an arbitrary sequence of positive rates $(\lambda_k)_{k\ge0}$. Define its directed information cost through step $n$ by

$$
C_n=\sum_{k=0}^{n-1}D(\lambda_k\|\lambda_{k+1}).
$$

Scale invariance shows that each term depends only on the adjacent ratio

$$
r_k=\frac{\lambda_{k+1}}{\lambda_k},
$$

through the function

$$
D(\lambda_k\|\lambda_{k+1})=r_k-1-\log r_k.
$$

Thus a common rescaling of the entire chain leaves every partial cost unchanged. The integer ladder corresponds to $r_k=1+1/(k+1)$.

The symmetric cost has an even simpler exact criterion term by term:

$$
D(\lambda_k\|\lambda_{k+1})+D(\lambda_{k+1}\|\lambda_k)
=\frac{(\lambda_{k+1}-\lambda_k)^2}{\lambda_k\lambda_{k+1}}.
$$

Consequently, the series of symmetrized adjacent divergences converges if and only if the series of normalized squared increments on the right converges. This is an identity-based reformulation rather than an additional convergence theorem, but it makes examples transparent.

For the polynomial chain $\lambda_k=(k+1)^p$ with $p>0$, adjacent relative changes are approximately $p/(k+1)$, so the symmetric terms are expected to behave like $p^2/(k+1)^2$ and hence to be summable. For a geometric chain $\lambda_k=a q^k$ with $a>0$ and $q>0$, $q\ne1$, every adjacent ratio is the same. Each divergence is then a fixed positive number, so both directed and symmetrized cumulative costs diverge linearly. These observations explain why the integer-rate construction has a finite total: its ratios approach one sufficiently rapidly.

The asymmetry can also be isolated algebraically. Writing $r=\mu/\lambda$, one has

$$
D(\lambda\|\mu)-D(\mu\|\lambda)
=r-\frac1r-2\log r.
$$

This expression changes sign under $r\mapsto1/r$ and vanishes at $r=1$. The symmetric square law captures the magnitude common to both orientations, while this antisymmetric expression records which model is treated as the reference.

## 10. Discussion

The accumulated-information theorem is exact, not metaphorical. Every summand in the classical positive series for $\gamma$ is literally a KL divergence between two explicitly specified probability laws. This gives a probabilistic meaning to the positivity of the series and explains its scale through the local behavior of statistical divergence.

Several features are worth emphasizing.

First, the orientation matters. The forward divergence $D(k+1\|k+2)$ contributes to $\gamma$, whereas the reverse divergence is different. The exact symmetrization formula quantifies the discrepancy between the two directions without obscuring either one.

Second, the rate ladder has constant additive spacing but shrinking multiplicative spacing. KL divergence is scale invariant, so multiplicative spacing is the relevant quantity. The relative step from $k+1$ to $k+2$ is $1+1/(k+1)$, and its divergence is second order in $1/(k+1)$. This is the structural source of inverse-square decay.

Third, the bridge does not by itself settle the rationality of $\gamma$. A positive series with explicit terms and useful bounds can support approximation theory, but irrationality arguments generally require highly structured rational or integral linear forms with exceptionally fast decay and controlled denominators. The present identities offer ingredients and motivation rather than a completed arithmetic criterion.

Finally, the construction suggests a broader program. Given a positive sequence of rates $(\lambda_k)$, one may study

$$
\sum_{k=0}^{\infty}D(\lambda_k\|\lambda_{k+1})
$$

and its symmetrized analogue. Scale invariance reduces each term to the adjacent ratio. The square identity shows that the symmetrized term equals

$$
\frac{(\lambda_{k+1}-\lambda_k)^2}
{\lambda_k\lambda_{k+1}}.
$$

This converts a question about information divergence into a question about normalized squared increments. Polynomial, geometric, and perturbed rate sequences should display sharply different convergence behavior.

## 11. Future work

Five directions arise naturally from the present results.

1. **Sharp two-sided summand asymptotics.** Establish the complementary rational lower bound

   $$
   \frac1{2(k+2)^2}\le g_k
   $$

   alongside the upper estimate $g_k\le1/[2(k+1)^2]$. This would squeeze every term between rational inverse-square expressions.

2. **Quantitative remainder bounds.** For positive $n$, prove explicit inequalities for

   $$
   \gamma-G_n,
   $$

   including strict positivity and an upper bound such as $1/(2n)$. The termwise inverse-square estimate is the natural starting point.

3. **Midpoint-corrected acceleration.** Study

   $$
   A_n=G_n+\frac1{2(n+1)}
   $$

   and prove a fully explicit error estimate of order $n^{-2}$, with an exact valid threshold.

4. **Symmetrized information tails.** Characterize positive rate chains for which

   $$
   \sum_k\left[D(\lambda_k\|\lambda_{k+1})
   +D(\lambda_{k+1}\|\lambda_k)\right]
   $$

   converges. The square formula reduces the problem to normalized adjacent increments and invites tests on polynomial and geometric sequences.

5. **Apéry-style linear forms.** Construct integer sequences from accelerated harmonic-logarithmic approximants and investigate whether nonzero integer linear forms in $1$ and $\gamma$ can decay exponentially. Either a successful bound or a concrete obstruction would clarify the arithmetic potential of the approach.

## 12. Conclusion

The Euler–Mascheroni constant admits the exact representation

$$
\gamma=\sum_{k=0}^{\infty}D(k+1\|k+2),
$$

where $D(\lambda\|\mu)$ is the KL divergence from an exponential law of rate $\lambda$ to one of rate $\mu$. Its $n$th partial sum is $H_n-\log(n+1)$; every term is strictly positive; and each is bounded above by both $1/[(k+1)(2k+3)]$ and $1/[2(k+1)^2]$. The divergence is invariant under common rescaling, vanishes exactly for equal positive rates, and has the exact symmetric form

$$
D(\lambda\|\mu)+D(\mu\|\lambda)
=\frac{(\lambda-\mu)^2}{\lambda\mu}.
$$

Together, these facts place $\gamma$ at a precise intersection of analytic number theory, probability, and information geometry: it is the finite information accumulated by moving through the memoryless waiting-time models of rates $1,2,3,\ldots$.