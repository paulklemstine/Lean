# Coin Flips on the Primes: How Randomness Tames the Multiplicative World

## A bell curve hiding inside the integers

Toss a fair coin once for every prime number. Heads is $+1$, tails is $-1$. Now build a function on the whole numbers by *multiplying together the coins of a number's prime factors*. This simple recipe produces one of the most studied objects in modern number theory: a **random multiplicative function**. It is a way of sprinkling controlled randomness across the integers while preserving their deepest structural feature — the way every number factors into primes.

Here is the surprising claim at the heart of this article. Take a huge number $x$, look at a window of consecutive integers $[x, x+y]$, and add up the values of the random function over that window. The result is a random quantity that fluctuates from one sequence of coin flips to another. And when the window is long enough, those fluctuations arrange themselves into the most famous shape in all of mathematics: the **Gaussian bell curve**.

That a bell curve should appear here is far from obvious. The classical Central Limit Theorem promises a bell curve when you add up *independent* random pieces. But the values of a multiplicative function are anything but independent: knowing the sign attached to the prime $3$ instantly tells you something about the numbers $3, 6, 15, 21, \dots$ all at once. The randomness leaks across the integers in a tangled, multiplicative web. And yet, order emerges.

## Two ways to flip the coins

There are two classical flavors of this construction, and the distinction turns out to matter enormously.

In the **Steinhaus** model, each prime is assigned not a $\pm 1$ sign but a random point on the unit circle — a complex number of absolute value $1$, chosen uniformly. The function is then defined on *every* integer by multiplying the primes' phases with multiplicity.

In the **Rademacher** model — the one we focus on here — each prime gets an honest coin flip, $\varepsilon_p = \pm 1$. The function is defined by
$$f(n) = \prod_{p \mid n} \varepsilon_p \quad \text{when } n \text{ is squarefree},$$
and crucially $f(n) = 0$ **when $n$ is divisible by a perfect square**. A number like $12 = 2^2 \cdot 3$ is simply switched off; only the *squarefree* numbers — those with no repeated prime factor, like $1, 2, 3, 5, 6, 7, 10, 11, \dots$ — carry a nonzero value.

This one design choice, "kill the non-squarefree numbers," is responsible for the entire story that follows. It means the Rademacher sum over a window is really a sum over the *squarefree* numbers in that window, and the size of the typical fluctuation is governed by *how many squarefree numbers the window contains*.

## The width of the bell

A bell curve is described by a single number: its width, or standard deviation. If you want to compare the random sum to a standard bell curve $N(0,1)$ — the one with mean zero and width one — you must first divide by the correct width. Get the width wrong and the whole comparison collapses.

So the essential question becomes: **what is the variance of the random sum?** The variance is the average of the square of the fluctuation, and its square root is the width we must divide by. Denote the sum over the window by
$$S = \sum_{x \le n \le x+y} f(n),$$
and its width by $\sigma(x,y) = \sqrt{\operatorname{Var}(S)}$.

The clean, exact answer — and the mathematical core of this work — is astonishingly simple.

> **Variance Identity (Rademacher case).** For a Rademacher random multiplicative function and *any* finite set $A$ of integers,
> $$\operatorname{Var}\!\left(\sum_{n \in A} f(n)\right) = \#\{\, n \in A : n \text{ is squarefree} \,\}.$$
> The variance is exactly the count of squarefree numbers in the set. In particular, for a short interval,
> $$\sigma(x,y)^2 = \#\{\, n \in [x, x+y] : n \text{ squarefree} \,\}.$$

No error terms, no asymptotics, no unproven hypotheses — an exact equality. The width of the bell curve is nothing more mysterious than a **head count of squarefree numbers**.

## Why the count is what it is

The reason is a beautiful two-line cancellation. Expand the square of the sum:
$$\operatorname{Var}(S) = \mathbb{E}\!\left[\Big(\sum_n f(n)\Big)^2\right] = \sum_{m,n} \mathbb{E}[f(m) f(n)].$$
(The mean of $S$ is zero, because each coin flip is as likely $+1$ as $-1$, so flipping the sign of a single prime negates $f(n)$ and cancels the average.)

Now consider a single cross term $\mathbb{E}[f(m) f(n)]$. Write $m$ and $n$ in terms of their prime factors. Every prime that divides $m$ but *not* $n$ contributes a lone factor $\varepsilon_p$, whose average over the coin flip is $\tfrac12(+1) + \tfrac12(-1) = 0$. That single unpaired coin annihilates the whole expectation. The only way to survive is for **every** prime to appear the same way in $m$ and in $n$ — that is, for $m$ and $n$ to be the *same squarefree number*. In that case $f(m) f(n) = f(n)^2 = 1$. Hence:

> **Orthogonality Relation.** $\mathbb{E}[f(m) f(n)] = 1$ if $m = n$ and $m$ is squarefree, and $0$ otherwise.

Summing over the diagonal $m = n$ leaves exactly one $1$ for each squarefree $n$ in the set — and there is the count. The randomness of the primes acts like a perfect filter: it erases every off-diagonal correlation and leaves behind a pure enumeration of squarefree integers.

## From counting to the bell curve's true width

How many squarefree numbers *are* there in a window $[x, x+y]$? A classical fact of number theory says that squarefree numbers have a natural density of $6/\pi^2 \approx 0.6079$ — the reciprocal of the famous sum $\sum 1/n^2 = \pi^2/6$ discovered by Euler. In a long window, the proportion of squarefree numbers hovers near this constant:
$$\#\{\, n \in [x, x+y] : n \text{ squarefree} \,\} = \frac{6}{\pi^2}\, y + o(y).$$
This holds unconditionally once the window is not too short (roughly $y \gg \sqrt{x}$), and for essentially all window lengths under the Riemann Hypothesis. Feeding this into the exact variance identity gives the true width of the bell:
$$\sigma(x,y)^2 \sim \frac{6}{\pi^2}\, y.$$

Compare this to the Steinhaus model, where *every* integer carries a nonzero value and the variance is simply $y$, giving width $\sqrt{y}$. The Rademacher width is smaller by exactly the factor $6/\pi^2$ — the squarefree density. This is the precise sense in which the two models differ: **the same bell curve appears, but its width is scaled by the density of squarefree numbers.** The design choice of switching off the non-squarefree integers is visible, quantitatively, in the shape of the final distribution.

## The idempotent heart: squares that don't grow

There is a small algebraic gem underlying all of this, worth isolating because it powers the exact variance formula. Consider the *indicator of squarefreeness*, the function $\chi(m)$ that equals $1$ when $m$ is squarefree and $0$ otherwise. Because it only ever takes the values $0$ and $1$, squaring it changes nothing:
$$\chi(m)^2 = \chi(m).$$
This "idempotency" is trivial to state but has real consequences. If you place the uniform distribution on $\{1, 2, \dots, N\}$ and treat $\chi$ as a random variable, its mean is the squarefree proportion $q_N = Q(N)/N$, where $Q(N)$ counts squarefree numbers up to $N$. Its variance, thanks to idempotency, collapses to the tidy formula for a two-valued (Bernoulli-like) random variable:

> **Squarefree Indicator Variance.** With the uniform distribution on $\{1, \dots, N\}$,
> $$\operatorname{Var}(\chi) = \frac{Q(N)}{N} - \left(\frac{Q(N)}{N}\right)^2 = q_N(1 - q_N),$$
> where $Q(N) = \#\{\, m \le N : m \text{ squarefree} \,\}$.

As $N \to \infty$, $q_N \to 6/\pi^2$, so the variance of the squarefree indicator tends to $\tfrac{6}{\pi^2}\big(1 - \tfrac{6}{\pi^2}\big) \approx 0.238$. This is the same constant $6/\pi^2$ reappearing in a different guise — a reminder that all these threads are woven from the same number-theoretic fabric.

## Why any of this matters

Random multiplicative functions were introduced decades ago as tractable stand-ins for genuine arithmetic objects — most famously the Möbius function and Dirichlet characters, whose sign patterns *look* random but are entirely deterministic and fiendishly hard to control. If we can prove that the random model behaves like a bell curve, we gain a template for what to expect, and sometimes a strategy to attack, the real thing. Questions about how much these sums can grow, how often they change sign, and how they distribute are central to analytic number theory and to the study of the Riemann zeta function.

The short-interval version — summing over a window $[x, x+y]$ rather than an initial segment $[1, x]$ — is especially delicate. Short intervals are where number theory keeps its hardest secrets: the distribution of primes in short intervals, gaps between primes, and the finest fluctuations of arithmetic functions all live here. Establishing a clean central limit theorem in this regime, with the *exact* normalization pinned down, is a meaningful step.

The picture we have assembled is this:

> **Central Limit Theorem (conjectured Rademacher form).** For a Rademacher random multiplicative function and any window length $y = y(x)$ with $y \to \infty$, $y = o(x)$, and such that the window $[x, x+y]$ contains $(6/\pi^2)y + o(y)$ squarefree numbers with probability $1 - o(1)$, the normalized sum
> $$\frac{1}{\sigma(x,y)} \sum_{x \le n \le x+y} f(n) \;\xrightarrow{\ d\ }\; N(0,1)$$
> converges in distribution to a standard Gaussian, with $\sigma(x,y)^2 = \#\{\, n \in [x,x+y] : n \text{ squarefree} \,\} \sim \tfrac{6}{\pi^2} y$.

The genuinely settled, unconditional part of this program is the exact variance identity and the orthogonality relation that produces it. They isolate the *number-theoretic* content of the problem — a count of squarefree integers — from the *probabilistic* content — the convergence to a Gaussian. Once the count is understood, the width of the bell is understood, and the shape follows.

## The moral

Start with nothing but a coin for each prime and a rule for multiplying. Out of that austere setup comes a bell curve, and the width of that bell curve is a plain count of squarefree numbers, governed by Euler's constant $6/\pi^2$. It is a small, sharp illustration of a recurring miracle in mathematics: that deterministic structure and pure randomness, when combined just so, conspire to produce the most orderly shape we know.
