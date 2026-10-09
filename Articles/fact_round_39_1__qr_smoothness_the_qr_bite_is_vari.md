# The Sieve That Doesn't Pay a Tax: Why Quadratic Residues Shape the Spread, Not the Average

*How a suspected handicap in one of the great factoring algorithms turned out to be a perfectly balanced trade — and where the real unevenness was hiding.*

---

## A factoring machine built from squares

Suppose someone hands you a large odd number $N$ and asks for its factors. One of the most successful general-purpose answers of the twentieth century is the **quadratic sieve**. Its idea is old — it goes back in spirit to Fermat — and beautifully simple: if you can find two numbers $a$ and $b$ with

$$a^2 \equiv b^2 \pmod N, \qquad a \not\equiv \pm b \pmod N,$$

then $\gcd(a-b, N)$ is a nontrivial factor of $N$.

To manufacture such a coincidence of squares, the sieve looks at the numbers

$$Q(x) = x^2 - N$$

for $x$ just above $\sqrt N$. These values are fairly small — roughly $2\sqrt N$ times the distance of $x$ from $\sqrt N$ — and the algorithm hunts for those that are **smooth**: values whose prime factors all lie below some bound $B$. Each smooth value is a "relation". Once you have collected a few more relations than there are primes below $B$, linear algebra over the two-element field combines some of them into a perfect square, and the factorization usually follows.

So the whole engine runs on one fuel: **how often is $x^2 - N$ smooth?** Everything — the running time, the memory, the choice of $B$ — depends on that rate.

## The worry: half the primes are locked out

Here is the subtlety that motivated the work described in this article. Fix a small odd prime $p$ not dividing $N$. When can $p$ divide $x^2 - N$? Exactly when $x^2 \equiv N \pmod p$, i.e. when $N$ is a **square modulo $p$** — a *quadratic residue*. Number theorists record this with the **Legendre symbol**:

$$\left(\frac{N}{p}\right) = \begin{cases} +1 & \text{if } N \text{ is a nonzero square mod } p,\\ -1 & \text{if it is not.}\end{cases}$$

Euler's criterion makes it easy to compute: $\left(\frac{N}{p}\right) \equiv N^{(p-1)/2} \pmod p$.

For exactly half of the odd primes, $N$ is a non-residue, and those primes can **never** divide any value $x^2 - N$. They are simply locked out of the factor base. A sieve value can only be built out of the other half.

That sounds like a serious handicap. A random integer of the same size can use *every* small prime as a building block; the sieve values can use only half of them. It seems natural to expect that sieve values should behave like random integers with a thinned-out factor base — or, equivalently, like random integers of a somewhat larger "effective size". An earlier study in this line of work had told exactly that story, after observing sieve yields running at only about 54–76% of a naive prediction.

The hypothesis was stated in advance and tested. It failed — spectacularly.

## The experiment

The test was direct. Across four regimes of the smoothness parameter $u = \log(\text{value})/\log B$ (the standard measure of how hard it is to be smooth), with 100,000 values in each cell, three populations were compared:

1. the actual sieve values $x^2 - N$, averaged over many different $N$;
2. **unrestricted** random integers of the same size;
3. random integers restricted to the "QR pool" — allowed to use only the primes $p$ with $\left(\frac{N}{p}\right) = +1$, as the lock-out story suggests.

The results:

* The sieve values were smooth **just as often** as unrestricted random integers, in every cell, within statistical noise. Both sat at 87–99% of the classical Dickman–de Bruijn prediction — a known finite-size correction that affects random integers just as much.
* The QR-pool-restricted random integers were smooth **21 to 56 times less often**.

So the sieve values do *not* behave like integers with half a factor base. They behave like completely ordinary integers. The lock-out costs nothing at all.

## The trade: double rate on half the pool

Why? Go back to a single prime $p$ and count *how many* residue classes of $x$ make $p$ divide $x^2 - N$.

* If $N$ is a non-residue mod $p$: **zero** classes.
* If $N$ is a nonzero residue mod $p$: the congruence $x^2 \equiv N$ has **two** solutions, $x \equiv \pm s$. So $p$ divides $x^2 - N$ for two classes out of $p$ — **twice** the rate $1/p$ at which $p$ divides a random integer.

Call $r_p(N)$ the number of solutions of $x^2 \equiv N \pmod p$. The two cases combine into a single formula:

$$r_p(N) = 1 + \left(\frac{N}{p}\right).$$

Now average over $N$. Exactly half the nonzero residues mod $p$ are squares, so the average of $r_p(N)$ is $\tfrac12 \cdot 2 + \tfrac12 \cdot 0 = 1$ — precisely the rate of a random integer. Halving the pool and doubling the rate cancel perfectly. In a clean statement:

> **Mean compensation at a prime.** For every odd prime $p$, summing over the $p-1$ nonzero residues $N$ modulo $p$,
> $$\sum_{N} \Big(1 + \left(\tfrac{N}{p}\right)\Big) = p - 1.$$
> The average local divisibility rate of $x^2-N$ is exactly the unrestricted one.

This is why the third population in the experiment did so badly: it modelled the halved pool but forgot the doubled rate.

## It works at every depth — for a deep reason

One prime is a warm-up. A real sieve uses hundreds or thousands of primes at once, and the interesting question is what happens jointly. Let $M = p_1 p_2 \cdots p_k$ be a product of $k$ distinct odd primes and let $r_M(N)$ be the number of classes $x$ modulo $M$ with $M \mid x^2 - N$.

The answer comes from looking at the problem through group theory. The units modulo $M$ form a finite abelian group $G$, and squaring $x \mapsto x^2$ is a map from $G$ to itself. The number $r_M(N)$ is just the size of the set of elements that square to $N$ — the *fibre* of the squaring map over $N$. Three facts then fall out almost for free:

* **Every element is a square root of exactly one thing.** So the fibres partition the group, and the root counts add up to the size of the group:
$$\sum_{N \in G} r(N) = |G|.$$
The average root count is exactly 1, *in every finite abelian group*.

* **All or nothing.** If $N$ has a square root $x$, then multiplying by $x$ matches the square roots of $N$ one-to-one with the square roots of $1$. So every root count is either $0$ or $t$, where $t$ is the number of square roots of $1$.

* **The second moment is exact.** Counting pairs carefully gives
$$\sum_{N \in G} r(N)^2 = |G|\cdot t, \qquad \text{so} \qquad \sum_{N\in G} \big(r(N) - 1\big)^2 = |G|\,(t-1).$$

For $M = p_1\cdots p_k$, the Chinese Remainder Theorem splits the units modulo $M$ into a product of the unit groups modulo each $p_i$, root counts multiply ($r_{mn} = r_m\, r_n$ for coprime $m,n$), and $1$ has exactly $2$ square roots modulo each odd prime. So $t = 2^k$. Put together, this gives the central theorem:

> **The QR bite is variance, not mean.** Let $M$ be a product of $k$ distinct odd primes and let $\varphi(M)$ be the number of units modulo $M$. Then, summing over all units $N$ modulo $M$,
> $$\sum_N r_M(N) = \varphi(M), \qquad \sum_N \big(r_M(N) - 1\big)^2 = \varphi(M)\,\big(2^k - 1\big).$$
> Moreover every $r_M(N)$ equals either $0$ or $2^k$, and exactly $\varphi(M)/2^k$ of the $N$ get the nonzero value.

Read that slowly. The **mean** is exactly 1 — the same as for random integers — *no matter how many primes you sieve with*. But the **variance** is $2^k - 1$: it grows *exponentially* with the number of sieving primes. A tiny fraction $1/2^k$ of the $N$ get a jackpot local rate $2^k$; everyone else gets nothing.

A concrete example: take $M = 3\cdot 5\cdot 7 = 105$. There are $\varphi(105) = 48$ residues $N$ coprime to 105. Exactly **6** of them have $8$ square roots modulo 105; the other **42** have none. The total is $6 \times 8 = 48$, an average of exactly 1. The squared deviations total $6\cdot 49 + 42 \cdot 1 = 336 = 48 \cdot 7$, a variance of exactly $2^3 - 1 = 7$.

## Where the unevenness really lives

So the quadratic-residue condition is not a tax on the average. But it is very far from irrelevant: it is a lottery. Each prime $p$ flips a coin for each $N$ — residue or not — and the coin tells you whether $p$ helps that particular $N$ twice as much as usual, or not at all.

This is exactly what the experiment saw once it stopped averaging over $N$ and looked at each $N$ separately:

* The per-$N$ smooth rate correlated with a very simple statistic — the number of odd primes up to 100 that are quadratic residues of $N$ — with correlation coefficients 0.50, 0.45, 0.48 and 0.40 across the four cells.
* The spread between the luckiest and unluckiest tenth of $N$ values was a factor of **2.4** at $u = 2.5$ and a factor of **9.3** at $u = 3.5$.

The growth of that spread with $u$ is the empirical echo of the $2^k$ law: at larger $u$ more primes matter, and the variance compounds.

One more exact fact sharpens the picture. Local rates at different primes are **exactly uncorrelated** across $N$: for coprime moduli the deviations $r_m(N) - 1$ and $r_n(N) - 1$ have covariance exactly zero. Consequently a weighted "Euler score" such as $a\,r_p(N) + b\,r_q(N)$ for two distinct odd primes has mean exactly $a+b$ and variance exactly $a^2 + b^2$ over $N$ modulo $pq$ — the per-prime contributions add with no cross terms. The unevenness builds up prime by prime, like the steps of a random walk.

## Solving an old puzzle

This also resolves the anomaly that started the whole investigation. The earlier study measured sieve yields at several scales but used **one** number $N$ per scale. With a per-$N$ spread as large as 2.4× to 9.3×, a single draw tells you mainly how lucky that particular $N$ was. The observed 54–76% yields were not a systematic deficit caused by the quadratic-residue condition — they were the luck of the draw. The "effective $u$" explanation offered at the time is retired: the mean identity rules it out.

## Why it matters

There is a practical payoff. Because the per-$N$ yield depends so strongly on which small primes are residues, it can be **predicted in advance**, cheaply. Twenty or so Euler-criterion tests — computing $N^{(p-1)/2} \bmod p$ for the first few odd primes — already carry much of the information. Practitioners of the quadratic sieve have long done something in this spirit: the classical *multiplier* trick replaces $N$ by $kN$ for a small $k$ chosen so that many small primes become residues. The analysis here explains why that works. Choosing a multiplier does not beat the average; it **harvests the variance**, moving you from an ordinary draw to a lucky one.

There is also a methodological lesson that reaches beyond factoring. When a population is built from many independent "coin flips", a restriction can leave the mean exactly unchanged while blowing up the spread. Experiments that sample only one member of such a population can mislead badly, and averages alone will never reveal the mechanism. In this case the restriction looked like a tax; it was really a lottery with a fair payout.

## What comes next

Several natural questions remain open. The exact results above concern *local* divisibility rates — how often a fixed modulus divides $x^2 - N$. Turning that into a statement about *smoothness* at a given $u$ needs a transfer principle of the Dickman type, which has not yet been worked out rigorously. Conjecturally, because each prime contributes an independent mean-zero coin flip, the logarithm of the per-$N$ yield should be approximately normally distributed, with mean given by the usual random-integer prediction and variance accumulating as a sum over primes of roughly $(\log p/(p-1))^2$. One concrete prediction is that the decile spread should keep growing with $u$ — beyond 30× at $u = 4.5$ — and that a weighted Euler-criterion score with weights proportional to $\log p/(p-1)$ should be close to the best linear predictor of yield, made possible because the zero-covariance identity makes the regression diagonal.

The quadratic sieve has been studied for four decades. It is a pleasant surprise that a question as basic as "do quadratic residues cost anything?" still has a crisp answer: *not on average — but they decide who wins.*
