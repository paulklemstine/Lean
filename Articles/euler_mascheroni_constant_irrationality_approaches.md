# The Constant Hidden in a Staircase of Information

## A familiar number in an unfamiliar landscape

Some mathematical constants announce themselves through geometry. The number $\pi$ belongs to circles; $e$ belongs to continuous growth. The Euler–Mascheroni constant $\gamma$ is more elusive. It is born from a mismatch between two ways of measuring accumulation: adding the reciprocals of whole numbers and integrating the reciprocal function.

Let

$$
H_n=1+\frac12+\frac13+\cdots+\frac1n
$$

be the $n$th harmonic number. Both $H_n$ and $\log n$ grow without bound, but their difference settles toward a finite limit:

$$
\gamma=\lim_{n\to\infty}(H_n-\log n).
$$

Numerically, $\gamma\approx0.5772156649$. Its arithmetic nature remains mysterious: no one knows whether $\gamma$ is rational or irrational. Yet uncertainty about that famous question does not make the constant inaccessible. A striking exact identity places it in information theory. The constant $\gamma$ is the total information discrepancy accumulated while moving, one step at a time, through exponential waiting-time distributions whose rates are $1,2,3,\ldots$.

That sentence joins two areas that at first seem unrelated. Harmonic sums belong to analytic number theory. Exponential distributions model waiting times: radioactive decay, customer arrivals, component failures, and the gaps between random events. Information divergence measures how costly it is to mistake one probability law for another. The bridge among them is not metaphorical. It is an exact infinite sum.

## Exponential clocks

An exponential distribution of rate $\lambda>0$ describes a random waiting time $X\ge 0$ with density

$$
f_\lambda(x)=\lambda e^{-\lambda x}.
$$

Its mean waiting time is $1/\lambda$. A clock of rate $1$ waits one unit on average; a clock of rate $2$ waits half a unit; increasing the rate makes events arrive faster.

How different are clocks of rates $\lambda$ and $\mu$? A standard answer is the Kullback–Leibler divergence. If observations are actually drawn from the rate-$\lambda$ clock but are described using the rate-$\mu$ model, the divergence measures the expected excess logarithmic loss. For exponential distributions it has the closed form

$$
D_{\mathrm{KL}}\!\left(\operatorname{Exp}(\lambda)\,\|\,\operatorname{Exp}(\mu)\right)
=\log\!\left(\frac{\lambda}{\mu}\right)+\frac{\mu}{\lambda}-1.
$$

Divergence is directional: in general, reversing $\lambda$ and $\mu$ changes its value. It is always nonnegative for positive rates and vanishes exactly when the rates agree. The nonnegativity follows from the elementary logarithmic inequality

$$
\log x\le x-1\qquad(x>0).
$$

Indeed, setting $x=\mu/\lambda$ rewrites the divergence as $x-1-\log x$, which is nonnegative.

This quantity has operational meaning. Suppose a coding or prediction system is optimized for rate $\mu$, while nature uses rate $\lambda$. The divergence is the average information penalty per observation, measured in natural logarithmic units. Thus a chain of distributions can be viewed as a journey whose steps each carry an information cost.

## The consecutive-rate surprise

Now compare neighboring clocks. Put $\lambda=k+1$ and $\mu=k+2$, where $k$ is a nonnegative integer. The divergence becomes

$$
D_k=
D_{\mathrm{KL}}\!\left(\operatorname{Exp}(k+1)\,\|\,\operatorname{Exp}(k+2)\right)
=\log\!\left(\frac{k+1}{k+2}\right)+\frac{k+2}{k+1}-1.
$$

A small simplification gives

$$
D_k=\frac1{k+1}-\log\!\left(\frac{k+2}{k+1}\right).
$$

This is precisely one of the classical positive increments that build $\gamma$. The reciprocal $1/(k+1)$ is slightly larger than the logarithmic increment from $k+1$ to $k+2$. Their difference is the information cost of replacing one exponential clock by its next faster neighbor.

Each step is nonnegative. Geometrically, $1/(k+1)$ is the area of a rectangle of width $1$ and height $1/(k+1)$, while

$$
\log\!\left(\frac{k+2}{k+1}\right)=\int_{k+1}^{k+2}\frac{dx}{x}
$$

is the area under the decreasing curve $1/x$ over the same interval. The rectangle lies above the curve, and $D_k$ is the sliver between them. Information theory and elementary area comparison are measuring the same discrepancy.

## Why the whole staircase sums to $\gamma$

Consider the first $n$ steps:

$$
S_n=\sum_{k=0}^{n-1}D_k.
$$

Substitute the expression above and separate the sums:

$$
S_n=
\sum_{k=0}^{n-1}\frac1{k+1}
-
\sum_{k=0}^{n-1}\log\!\left(\frac{k+2}{k+1}\right).
$$

The first sum is $H_n$. The logarithms telescope because logarithms turn products into sums:

$$
\begin{aligned}
\sum_{k=0}^{n-1}\log\!\left(\frac{k+2}{k+1}\right)
&=\log\!\left(\prod_{k=0}^{n-1}\frac{k+2}{k+1}\right)\\
&=\log(n+1).
\end{aligned}
$$

Every intermediate factor cancels. Therefore

$$
S_n=H_n-\log(n+1).
$$

This finite identity is the engine of the entire result. Since $H_n-\log(n+1)$ tends to $\gamma$, the nonnegative series converges and yields the Accumulated Information Divergence Theorem:

$$
\boxed{
\gamma=
\sum_{k=0}^{\infty}
D_{\mathrm{KL}}\!\left(\operatorname{Exp}(k+1)\,\|\,
\operatorname{Exp}(k+2)\right)
}.
$$

There is a harmless indexing subtlety. The familiar definition often uses $H_n-\log n$, whereas the first $n$ divergences give $H_n-\log(n+1)$. Their difference is $\log(1+1/n)$, which tends to zero, so both sequences have the same limit.

The theorem says that $\gamma$ is not merely a leftover from comparing a sum with an integral. It is the finite total cost of endlessly retuning an exponential model from rate $1$ to rate $2$, then $2$ to $3$, and onward. Infinitely many positive costs can have a finite total because the clocks become progressively more alike in relative terms.

## Why the total remains finite

For large $k$, neighboring rates differ by only a fraction about $1/(k+1)$. Write $u=1/(k+1)$. Then

$$
D_k=u-\log(1+u).
$$

The Taylor expansion $\log(1+u)=u-u^2/2+u^3/3-\cdots$ suggests

$$
D_k\sim\frac{1}{2(k+1)^2}.
$$

A reciprocal-square tail is summable, explaining the finite accumulation. This also reveals a local geometric idea. For nearby statistical models, divergence is approximately quadratic in the parameter displacement. The relevant local metric is Fisher information. The first-order change cancels, and a second-order cost remains.

The asymptotic picture gives a useful computational warning. The partial sums converge, but only at a rate comparable to $1/n$. Summing a million terms gains roughly six decimal-place scales, not a million. Better approximations can be obtained by correcting the tail with Euler–Maclaurin terms, grouping steps, or designing weighted paths. The exact identity supplies the raw material for those accelerations.

## A concrete numerical walk

The first step, from rate $1$ to rate $2$, costs

$$
D_0=1-\log 2\approx0.30685.
$$

The next costs

$$
D_1=\frac12-\log\!\left(\frac32\right)\approx0.09453.
$$

By the tenth step the individual cost is much smaller. Yet every term remains positive, and the running total climbs monotonically toward $\gamma$. After $n$ steps the exact total is $H_n-\log(n+1)$, so numerical evaluation can be checked in two independent ways: direct divergence summation and the harmonic–logarithmic formula.

This is valuable in applications. When many consecutive exponential models are compared, one need not repeatedly evaluate every divergence. The telescoping formula computes the cumulative cost from a harmonic sum and one logarithm. Conversely, the sum of divergences gives a probabilistic interpretation to a classical analytic approximation.

## Three languages for one small gap

The same term $D_k$ can now be read in three languages. In the language of discrete mathematics, it is the excess of one reciprocal, $1/(k+1)$, over a logarithmic increment. In the language of calculus, it is an area:

$$
D_k=\int_{k+1}^{k+2}\left(\frac1{k+1}-\frac1x\right)dx.
$$

In the language of statistics, it is an expected log-likelihood penalty between two exponential clocks. These are not analogies laid side by side after the fact; the formulas prove that they are the same number.

That unity explains why a simple inequality keeps reappearing. The curve $\log x$ lies below its tangent at $x=1$, giving $\log x\le x-1$. The curve $1/x$ decreases, placing its integral below the left-endpoint rectangle. A misspecified probability model incurs nonnegative expected excess loss. Convexity, geometry, and information all enforce the same sign.

The direction of comparison matters. The construction asks what happens when observations from the slower clock of rate $k+1$ are described by the faster clock of rate $k+2$. Reversing those roles gives another positive divergence, but not the Euler–Mascheroni increment. This asymmetry is essential: information divergence is a directed cost rather than an ordinary distance.

The finite identity also makes the result experimentally transparent. Compute the first $n$ costs independently and compare their total with $H_n-\log(n+1)$; the values agree apart from numerical rounding. Increase $n$, and the total rises because every newly added cost is nonnegative. At the same time the elementary reciprocal-square estimate keeps the remaining tail under control. The limiting value is approached from below, step by diminishing step.

## What the identity does—and does not—settle

The representation illuminates $\gamma$, but it does not prove that $\gamma$ is irrational. Every summand contains a logarithm, and a convergent sum of positive transcendental-looking quantities need not reveal the arithmetic nature of its limit. Any irrationality strategy would require substantially stronger control, such as accelerated rational approximations or carefully designed integer linear forms.

Still, the bridge suggests productive questions. Can blocks of neighboring divergences be combined to cancel leading errors and converge faster? Can one derive the closed form directly from relative entropy integrals and extend the construction to other probability families? Can parameterized versions, differentiated with respect to a shape parameter, produce higher Stieltjes constants? Can sharp bounds on harmonic numbers become certified tail bounds for information accumulation?

The identity also changes the intuitive portrait of $\gamma$. Picture an infinite control panel of exponential clocks. At stage $k$, the clock’s rate is nudged from $k+1$ to $k+2$. Each adjustment is less consequential than the last, but none is free. Add every expected logarithmic penalty across the endless sequence. The meter stops at $0.5772156649\ldots$.

A constant first discovered in the gap between discrete sums and continuous logarithms is therefore also the length of a particular journey through a statistical family—not length in ordinary space, but accumulated directional information. The staircase of reciprocals, the area beneath $1/x$, and the changing tempo of random clocks all cast the same shadow. That shadow is $\gamma$.
