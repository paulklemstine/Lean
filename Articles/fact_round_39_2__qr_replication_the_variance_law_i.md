# Same Dice, Different Throw: Why a Law About Square Roots Survives a Change of Luck

*A story about quadratic residues, random seeds, and how to tell a real pattern from a lucky one.*

---

## The embarrassment that started it

Every computational scientist has a version of this story. You run an experiment, a beautiful number comes out, you write it up — and then somebody re-runs the code with a different random seed and the beautiful number evaporates. It was never a property of the mathematics. It was a property of the particular stream of pseudo-random numbers that happened to come out of the generator that afternoon.

A research programme on integer factoring had just lived through exactly that: a claimed effect that turned out to be seed luck. So when the very next study produced a striking claim — summarised in the slogan **"the quadratic-residue bite is variance, not mean"** — the programme did the disciplined thing. It re-ran the whole experiment with a fresh seed (20260826 instead of the original 20260821) and compared every headline number.

Everything replicated. But the more interesting outcome is that we can now say *why* it had to replicate, and give an exact law for how much any such replication can wobble. That is the subject of this article.

## Square roots that sometimes exist and sometimes don't

Start with clock arithmetic. Fix an odd prime, say $p = 7$, and ask which numbers have square roots "mod 7". Squaring the non-zero residues gives

$$1^2=1,\quad 2^2=4,\quad 3^2=2,\quad 4^2=2,\quad 5^2=4,\quad 6^2=1 \pmod 7.$$

So $1, 2, 4$ have two square roots each, and $3, 5, 6$ have none. The lucky ones are called **quadratic residues**. Half the non-zero residues are lucky, half are not, and the lucky ones get exactly two roots apiece.

Define the **root count** $r_p(N)$ to be the number of $x$ modulo $p$ with $x^2 \equiv N$. For a non-zero $N$ it is either $2$ or $0$. Euler noticed a slick way to tell which: compute $N^{(p-1)/2} \bmod p$. The answer is $+1$ for residues and $-1$ for non-residues. Calling that sign $\left(\frac{N}{p}\right)$ (the Legendre symbol), we get the tidy formula

$$r_p(N) = 1 + \left(\tfrac{N}{p}\right).$$

Now do the same modulo a product of several distinct odd primes, $M = p_1 p_2 \cdots p_k$. By the Chinese Remainder Theorem, solving $x^2 \equiv N \pmod M$ is the same as solving it modulo each $p_i$ separately, and the answers multiply. So $r_M(N)$ is either $2^k$ (if $N$ is a square modulo every $p_i$) or $0$ (if it fails at even one prime). For $M = 105 = 3\cdot5\cdot7$, a randomly chosen unit $N$ has eight square roots with probability $1/8$ and none at all with probability $7/8$.

## Why factoring cares

Classical sieve factoring methods — the quadratic sieve and its descendants — hunt for numbers of the form $x^2 - N$ that factor completely into small primes. A small prime $p$ can only divide $x^2 - N$ if $N$ is a square mod $p$, and then it divides it for exactly $r_p(N)$ residue classes of $x$. So $r_p(N)$ is literally the **local divisibility rate**: the fraction of $x$ values that a given prime "bites" is $r_p(N)/p$.

Practitioners have long noticed that restricting attention to numbers built from quadratic residues changes how smooth things look. The question the earlier study asked was: *does the quadratic-residue condition change the average yield, or only how spread out it is?*

## The variance law

Here is the exact answer, which is the foundation for everything that follows.

> **The variance law.** Let $M$ be a product of $k$ distinct odd primes, and let $N$ range uniformly over the residues mod $M$ that are coprime to $M$. Then the root count $r_M(N)$ has mean exactly $1$ and variance exactly $2^k - 1$.

The proof is a short piece of group theory. The units mod $M$ form a finite abelian group $G$ with $\varphi(M)$ elements. Squaring is a homomorphism of $G$; the elements it sends to $1$ are the $t = 2^k$ "square roots of one" (one choice of $\pm 1$ at each prime). So each square in $G$ has exactly $t$ square roots and the number of squares is $\varphi(M)/t$. Adding up,

$$\sum_N r_M(N) = \frac{\varphi(M)}{t}\cdot t = \varphi(M), \qquad \sum_N r_M(N)^2 = \frac{\varphi(M)}{t}\cdot t^2 = t\,\varphi(M).$$

Divide by $\varphi(M)$: the mean is $1$ and the mean square is $t$, so the variance is $t - 1 = 2^k - 1$.

The slogan follows at once. On average, every $N$ gets exactly one root — the same as an unrestricted random number. The quadratic-residue condition never changes the mean. What it does is concentrate everything into rare jackpots: most $N$ get nothing, a few get $2^k$. The bite is variance.

## What a "seed" is, mathematically

Now to the replication question. In an experiment, you don't look at all of $G$; you draw a sample. Model a **seed** as a list $x = (x_1, \dots, x_n)$ of $n$ independent uniform draws from $G$. The thing you measure is a sample statistic, and the cleanest one is the **sample sum of deviations**

$$S(x) = \sum_{i=1}^n \bigl(r_M(x_i) - 1\bigr).$$

Dividing by $n$ gives how far your sample average of root counts sits from the true mean $1$.

Here is the beautiful simplification: since the space of all seeds is finite — there are exactly $\varphi(M)^n$ of them — "averaging over all possible seeds" is not a probabilistic hand-wave. It is a finite sum. Every statement below is an exact identity between whole numbers.

## The replication law

> **No seed bias.** Summed over all $\varphi(M)^n$ seeds, $\sum_x S(x) = 0$.

This is just linearity: each draw contributes a deviation that averages to zero.

> **Exact single-seed spread.** Summed over all seeds,
> $$\sum_x S(x)^2 = n\,\varphi(M)^n\,(2^k - 1).$$

When you expand $S(x)^2$ you get squared terms $(r(x_i)-1)^2$ and cross terms $(r(x_i)-1)(r(x_j)-1)$ for $i \ne j$. Because different draws are independent and each deviation averages to zero, every cross term cancels *exactly* — not approximately, exactly. What remains is $n$ copies of the per-draw variance. In everyday language: the variance of a sample mean of $n$ draws is $(2^k-1)/n$.

> **The two-seed drift law.** Take two independent seeds $x$ and $y$ of the same length. Summed over all $\varphi(M)^{2n}$ pairs,
> $$\sum_{x,y} \bigl(S(x) - S(y)\bigr)^2 = 2\,n\,\varphi(M)^{2n}\,(2^k - 1).$$

Expanding $(S(x) - S(y))^2$, the cross term $S(x)S(y)$ factors into $\left(\sum_x S(x)\right)\left(\sum_y S(y)\right) = 0\cdot 0$. So the drift between two replications is exactly twice the spread of one. Translated into sample means: **the average squared difference between the two seeds' estimates is exactly $2(2^k-1)/n$.**

> **A guaranteed tail bound.** The fraction of seed pairs whose sample sums differ by at least $c$ is at most $2n(2^k-1)/c^2$.

This is Chebyshev's inequality in counting form: if a sum of non-negative numbers is $T$, at most $T/c^2$ of them can be $\ge c^2$.

> **The measured variance is itself reproducible.** If you estimate the variance from your seed with the usual plug-in formula, its average over all seeds is exactly $\frac{n-1}{n}(2^k-1)$ — the classical Bessel factor and nothing else.

That last statement matters: the experiment did not just measure a mean, it measured a *variance*, and you might worry that a variance estimate is more fragile. It is not. Its expectation is pinned down exactly.

There is even a symmetry hiding here. Multiplying every draw by the same square $y^2$ leaves every root count unchanged, $r_M(y^2 g) = r_M(g)$, because $z \mapsto zy^{-1}$ matches square roots of $y^2 g$ with square roots of $g$. So the statistic only sees seeds "up to relabelling by squares".

## So why was it seed-robust?

Put the pieces side by side. The quantities the earlier study claimed — mean $1$, variance $2^k - 1$ — are exact population constants. A seed enters only through a sample average, and the size of the wobble of that sample average is controlled *by the very same variance*, divided by the sample size.

That is the punchline: **seed-robustness is not an extra hypothesis to be checked; it is a consequence of the variance law itself.** With samples of a hundred thousand draws at $k = 4$, the predicted root-mean-square drift between two seeds of the sample mean is $\sqrt{2\cdot 15/10^5} \approx 0.017$. A seed change can move your numbers by about that much and no more, except with Chebyshev-small probability.

## What the fresh seed actually showed

The real replication used actual smoothness yields of $x^2 - N$, which depend on more than local arithmetic, so the identities above describe the idealised statistic behind the experiment rather than every decimal place. Still, the experimental picture lines up with the theory:

- **Ensemble equality.** Squares of random $x$ and genuinely random numbers had the same smoothness rate in all four test cells: $0.12859$ vs $0.12786$, $0.02004$ vs $0.02023$, $0.12854$ vs $0.12585$, $0.02004$ vs $0.01869$. Mean unchanged — exactly as "mean 1" predicts. Meanwhile, random numbers restricted to quadratic residues were 32 to 200 times less smooth.
- **Per-$N$ correlations** between yield and the number of primes at which $N$ is a residue: $0.503, 0.415, 0.480, 0.403$ on the fresh seed against $0.504, 0.452, 0.483, 0.401$ originally. The largest drift is $0.037$.
- **Decile spreads** — the gap between the least and most favourable tenths of $N$ — replicated too: roughly $0.076$–$0.082$ versus $0.186$–$0.188$ at one smoothness level, and $0.006$–$0.008$ versus $0.039$–$0.043$ at a stricter one.

Verdict: the claim stands without qualification.

## The bonus theorem: a predictor at any depth

The replication also confirmed that the per-$N$ correlation — the training target of a *yield predictor* that scores each $N$ before sieving — is stable. That invites a natural question: what exactly is the distribution of such a predictor?

The simplest predictor counts, or weights, the primes at which $N$ is a quadratic residue:

$$\mathrm{Score}(N) = \sum_{i=1}^k w_i\, r_{p_i}(N) = \sum_{i=1}^k w_i\left(1 + \left(\tfrac{N}{p_i}\right)\right).$$

> **The $k$-prime score theorem.** For distinct odd primes $p_1,\dots,p_k$, any integer weights $w_1,\dots,w_k$, and $N$ uniform over the units mod $M = p_1\cdots p_k$, the score has mean exactly $w_1 + \cdots + w_k$ and variance exactly $w_1^2 + \cdots + w_k^2$.

With all weights equal to $1$, the plain count of "good" primes has mean $k$ and variance $k$.

The proof is the same cancellation trick, applied in a different direction. By the Chinese Remainder Theorem, a uniform unit mod $M$ is the same thing as an independent uniform unit mod each $p_i$. The centred pieces $w_i\left(\frac{N}{p_i}\right)$ each average to zero, and they live on different coordinates. When you square the sum, every cross term between two different primes cancels, and the variances simply add: each prime contributes $w_i^2$ times its own variance, which is $2^1 - 1 = 1$. The result holds for any number of primes. In fact it holds for any finite collection of finite abelian groups: the score $\sum_i w_i\,(r(x_i) - 1)$ sums to zero over the product group, and its square sums to the group's size times $\sum_i w_i^2(t_i - 1)$, where $t_i$ counts the square roots of one in the $i$-th group.

Two messages for anyone designing a sieve heuristic. First, the quadratic-residue information never shifts the predictor's mean, at any depth. Second, its dispersion grows prime by prime with no interference between primes — so adding a new prime to the score adds exactly its own weight squared to the variance.

## A small worked example

Take $M = 15$, so $G$ has $\varphi(15) = 8$ elements and $t = 4$. The root counts are $4$ for $N \in \{1, 4\}$ and $0$ for the other six units. So the deviations $r - 1$ are $3, 3, -1, -1, -1, -1, -1, -1$: they sum to $0$, and their squares sum to $9 + 9 + 6 = 24 = 8\cdot 3$. That's mean $1$, variance $3 = 2^2 - 1$.

Now draw seeds of length $n = 2$: there are $64$ of them. The replication law predicts $\sum_x S(x)^2 = 2\cdot 8^2\cdot 3 = 384$, and listing all $64$ seeds confirms it. Over the $4096$ seed pairs, the squared drifts total $2\cdot 8^2 \cdot 384 = 49152$. Not one cross term survives.

## Where this leaves us

There is a quiet lesson here about what replication means. Re-running with a new seed is good practice, but it is an empirical check of a mathematical fact: that the claimed quantity is a population constant and the noise around it is controlled. When the claim is an exact law — mean $1$, variance $2^k - 1$ — then the same law also predicts exactly how much replications should disagree. The fresh seed then becomes a check that this prediction holds, rather than a hope that luck is on your side twice.

The open questions are natural next steps. Fourth moments would sharpen Chebyshev into sub-Gaussian bounds; since $r - 1$ only takes two values, its moments are explicit polynomials in $t$, and small cases already match the predicted formula. Hoeffding-type exponential bounds would make "seed-robust" mean "fails with exponentially small probability". Moduli with repeated primes and the prime $2$ — which real sieves use — need only a count of the square roots of one. And choosing the best predictor weights becomes a clean exercise in Cauchy–Schwarz once you know that variances add with no cross terms.

Different seed, same dice. Read correctly, the law says the result had to come out this way.
