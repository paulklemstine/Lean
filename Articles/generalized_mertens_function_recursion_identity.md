# Counting the Primes' Shadow: A Faster Way Through the Mertens Function

## A running tally of a mysterious sign

Take the whole numbers one by one — $1, 2, 3, 4, \dots$ — and attach to each a small tag that is either $+1$, $-1$, or $0$. The tag is the **Möbius function** $\mu(n)$, and the rule for computing it is deceptively simple:

- $\mu(1) = 1$.
- $\mu(n) = 0$ if $n$ is divisible by a perfect square bigger than $1$ (like $4$, $9$, $25$, $\dots$).
- Otherwise $\mu(n) = (-1)^{k}$, where $k$ is the number of distinct prime factors of $n$.

So $\mu(2) = -1$ (one prime), $\mu(6) = +1$ (two primes, $2$ and $3$), $\mu(12) = 0$ (because $4$ divides $12$), and $\mu(30) = -1$ (three primes: $2, 3, 5$). It looks like bookkeeping, but this little sign encodes the entire multiplicative skeleton of the integers, and it sits at the heart of some of the deepest questions in mathematics.

Now do the most natural thing imaginable: add the tags up. The running total,

$$M(x) = \sum_{n \le x} \mu(n),$$

is the **Mertens function**. It starts $M(1) = 1$, $M(2) = 0$, $M(3) = -1$, and then wanders up and down like a drunkard's walk: $M(10) = -1$, $M(100) = 1$, $M(1000) = 2$. It never seems to settle, and its long-term behavior is one of the most famous open questions in number theory. If one could show that $M(x)$ never grows faster than roughly $\sqrt{x}$ — precisely, that $M(x) = O(x^{1/2 + \varepsilon})$ for every $\varepsilon > 0$ — one would have proved the **Riemann Hypothesis**, the million-dollar problem that has resisted mathematicians for over a century and a half.

So $M(x)$ is not just an idle sum. It is a lens on the primes. And a very practical question follows: **how fast can we actually compute $M(x)$?**

## The tyranny of adding one term at a time

The obvious approach is to sieve out the Möbius values up to $x$ and add them, which costs on the order of $x$ operations. That is fine for $x = 10^6$, painful for $x = 10^{12}$, and utterly hopeless for the astronomical ranges where number theorists want to hunt for surprises in the sign of $M(x)$.

The escape route is a classical trick with a beautiful geometric soul: the **hyperbola method**. It rests on one small miracle.

## The one identity that starts everything

Here is the seed from which the whole theory grows. For any $y \ge 1$,

$$\sum_{k=1}^{y} M\!\left(\left\lfloor \tfrac{y}{k} \right\rfloor\right) = 1.$$

Read that again — it says that if you take the Mertens function, evaluate it at every "floor quotient" $\lfloor y/1 \rfloor, \lfloor y/2 \rfloor, \dots, \lfloor y/y \rfloor$, and add all those values, the wild oscillations cancel almost perfectly and you are left with exactly $1$, no matter how large $y$ is. For $y = 1000$, that is a sum of a thousand up-and-down Mertens values collapsing to a single unit. We call this the **Fundamental Identity of the Mertens Function**, and our numerical experiments confirm it exactly for $y = 1, 7, 50, 123, 1000$, and beyond.

Why is it true? Because of an even more basic fact about the Möbius tags: for any $n \ge 1$,

$$\sum_{d \mid n} \mu(d) = \begin{cases} 1 & n = 1, \\ 0 & n > 1. \end{cases}$$

Summing the tags over *all divisors* of a number gives $1$ only for $n = 1$ and cancels to $0$ everywhere else. This is the Möbius function's defining magic: it is the exact inverse of "counting", the tool that lets you undo any summation over divisors. Feeding this into a double sum over the lattice of points $(k, m)$ lying under a hyperbola $km \le y$ — and counting those points two different ways — produces the Fundamental Identity.

## Splitting a hyperbola cleverly

The Fundamental Identity is elegant but, on its own, still involves $y$ terms. The next step is where computational speed enters. Picture the lattice points $(k, m)$ with $k \cdot m \le y$: they fill the region under a hyperbola. That region is symmetric about the diagonal line $k = m$, which crosses the hyperbola near $k = m = \sqrt{y}$.

The **hyperbola method** exploits this symmetry: instead of summing over all $y$ columns, you sum over the roughly $\sqrt{y}$ columns on one side of the diagonal, sum over the roughly $\sqrt{y}$ rows on the other side, and subtract the corner square you counted twice. A sum of length $y$ becomes two sums of length about $\sqrt{y}$ — a dramatic saving.

Written out with the natural split point $\nu_y = \lfloor \sqrt{y} \rfloor$ and its companion $\kappa_y = \left\lfloor \tfrac{y}{\nu_y + 1} \right\rfloor$, the identity reads

$$\sum_{k=1}^{\kappa_y} M\!\left(\left\lfloor \tfrac{y}{k} \right\rfloor\right) \;+\; \sum_{m=1}^{\nu_y} \left\lfloor \tfrac{y}{m} \right\rfloor \mu(m) \;-\; \kappa_y \, M(\nu_y) \;=\; 1.$$

This **Asymmetric Hyperbola Identity** is the analytic engine of everything that follows. The first sum walks along the "tall, thin" part of the region; the second walks along the "short, wide" part; and the final term removes the double-counted overlap. Every piece is computable in about $\sqrt{y}$ steps.

## Packaging the split into a single building block

To turn the hyperbola identity into a *recursion*, we bottle it into one reusable quantity. For a cutoff $u$, define

$$S(y, u) = 1 \;-\; \sum_{n = \lfloor y/u\rfloor + 1}^{\kappa_y} M\!\left(\left\lfloor \tfrac{y}{n} \right\rfloor\right) \;+\; \kappa_y\, M(\nu_y) \;-\; \sum_{n=1}^{\nu_y} \left\lfloor \tfrac{y}{n} \right\rfloor \mu(n).$$

At first glance $S(y,u)$ looks like a tangle of floors and sums. But the hyperbola identity performs a small miracle of cancellation: whenever the cutoff $u$ is larger than $\sqrt{y}$, everything collapses into a single clean expression,

$$S(y, u) = \sum_{j=1}^{\lfloor y/u \rfloor} M\!\left(\left\lfloor \tfrac{y}{j} \right\rfloor\right).$$

In other words, $S(y,u)$ is just a *short* Fundamental-Identity-style sum — but only the first $\lfloor y/u \rfloor$ terms of it. When $u$ is chosen near $\sqrt{y}$, that is a sum of only about $\sqrt{y}$ terms. This **Collapse Identity** is the key that makes the machine efficient, and again our computations confirm it exactly across tens of thousands of cases.

## The main theorem: a recursion that folds $M(x)$ onto smaller values

Assembling the pieces gives the centerpiece result. For every integer $x \ge 2$ and every integer $u$ with $\lfloor \sqrt{x} \rfloor < u < x$,

$$\boxed{\; M(x) = \sum_{k=1}^{\lfloor x/u \rfloor} \mu(k)\, S\!\left(\left\lfloor \tfrac{x}{k} \right\rfloor, u\right). \;}$$

This is the **Generalized Mertens Recursion Identity**. Read it as an algorithm: to find $M(x)$, you only need the values of $S$ at the "large" quotients $\lfloor x/k \rfloor$ for $k$ up to $\lfloor x/u \rfloor$, weighted by the Möbius tags $\mu(k)$. Each $S$ value is itself a short sum of Mertens values at *smaller* arguments — values you compute once, cache, and reuse. The free parameter $u$ lets you tune exactly where the recursion cuts between "compute directly" and "recurse", and choosing $u \approx \sqrt{x}$ balances the two costs.

The payoff is concrete. Where the naive sum needs about $x$ operations, this recursion — with its quotient values cached and the $\sqrt{y}$-length hyperbola splits — brings the cost down to roughly $x^{2/3}$. For $x = 10^{12}$ that is the difference between a trillion steps and about a hundred million: minutes instead of millennia.

## Does it really work? Yes — checked to the last unit

Because every quantity here is an exact integer, the identities are not approximations that "hold on average" — they are precise equalities that either hold or fail. We verified them directly. Computing the Möbius tags by a fast sieve and the Mertens values by running totals, we checked the main recursion for **every** valid pair $(x, u)$ with $x \le 300$ — over forty thousand distinct cases — and found zero failures. We confirmed the collapse of $S(y,u)$ in every one of those cases, and spot-checked the recursion at $x = 500, 1000, 2500, 5000$ with $u = \lfloor\sqrt{x}\rfloor + 1$, each time reproducing the true Mertens value on the nose ($M(5000) = 2$, for instance).

## Why it matters beyond speed

The recursion is a fast algorithm, but its parts are the more lasting gift. The reindexing that turns an iterated sum $\sum_k \sum_{m \le y/k}$ into a single sum over the hyperbola region $\{(k,m) : km \le y\}$ is *convolution-agnostic*: it does not care that we started with the Möbius function. Replace $\mu$ by any arithmetic function $f$ and the same machinery produces a fast recursion for $\sum_{n \le x} f(n)$ — the summatory Liouville function, the totient summatory function $\sum_{n\le x}\varphi(n)$, and many others fall to the identical method.

And underneath the algorithm lies the reason anyone cares about $M(x)$ at all. Every large-scale computation of the Mertens function is, ultimately, an experiment probing the frontier of the Riemann Hypothesis. The infamous **Mertens Conjecture** — that $|M(x)| < \sqrt{x}$ always — was believed for nearly a century before being disproved in 1985, with the first counterexample now known to lurk somewhere below $x = 10^{40}$, far beyond any direct sieve. Tools like this recursion are exactly what let mathematicians march computation into those distant ranges, where the primes still keep their secrets and every new value of $M(x)$ is a small message from the deep structure of the integers.
