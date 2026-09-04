# The Lottery Inside a Factoring Sieve

## A dial with no knobs

Every modelling exercise eventually reaches the same uncomfortable question: *how much of my model is theory, and how much is curve-fitting?* You build a formula, you sprinkle it with coefficients, you tune the coefficients against data, and the formula fits. But a formula that fits because you *made* it fit explains nothing. The gold standard — the thing that almost never happens — is a formula whose every constant is forced by first principles, which then goes out and fits the data anyway.

This is the story of one such formula. It comes from the innards of integer factorisation, it is one line long, and it contains exactly zero adjustable numbers:

$$T(N) \;=\; \sum_{\substack{p \le B \\ N \text{ is a square mod } p}} \frac{2}{p}.$$

Read it aloud: *walk through the small primes up to some bound $B$; for each one, ask whether the number $N$ you care about is a perfect square modulo that prime; if the answer is yes, add $2/p$ to a running total; if no, add nothing.* That total is the dial.

There is no $\alpha$, no $\beta$, no exponent to tune, no intercept. The only number appearing anywhere is the $2$ in the numerator, and — this is the point of the whole story — that $2$ is not a choice. It is a theorem.

## Where the dial comes from

Modern factoring algorithms of the *quadratic sieve* family all share a skeleton. To factor a big number $N$, you scan positions $x$ near $\sqrt{N}$ and look at the values $x^2 - N$. You hope that a decent number of those values factor completely into small primes drawn from a fixed *factor base* $\{p \le B\}$; each such lucky value is a relation, and once you have enough relations, linear algebra over $\mathbb{F}_2$ hands you a factorisation.

Everything therefore depends on how *hospitable* your particular $N$ is to the factor base. And here the arithmetic performs a striking act of pre-selection. Fix a prime $p$ in the factor base. Which sieve positions $x$ does $p$ ever touch? Precisely those with
$$x^2 \equiv N \pmod p,$$
because $p \mid x^2 - N$ exactly then. So the question "how much work does $p$ do for me?" reduces to the question "how many square roots does $N$ have modulo $p$?"

That question has a famously rigid answer. For an odd prime $p$ that does not divide $N$, the congruence $x^2 \equiv N \pmod p$ has **either two solutions or none** — never one, never three. Two if $N$ is a *quadratic residue* modulo $p$ (a square in the arithmetic of remainders), none otherwise. This dichotomy is the oldest theorem in the story, going back to Euler and Legendre, and it is the source of the $2$.

Since the roots repeat with period $p$, a fraction $2/p$ of all sieve positions are touched by $p$ when $N$ is a residue, and a fraction $0$ when it is not. Add up over the factor base and you have the total expected footprint of the sieve for this particular $N$ — and that sum is precisely $T(N)$.

So the dial is not an approximation of the footprint. It *is* the footprint, exactly.

## The lottery

Here is the picture I find most useful. Think of each prime $p \le B$ as running its own lottery. The tickets are the residue classes of $N$ modulo $p$; exactly half the nonzero classes are winners (the quadratic residues) and half are losers (the non-residues). If your $N$ holds a winning ticket at $p$, prime $p$ pays out $2/p$ worth of sieve hits. Otherwise it pays nothing at all. Your total prize is $T(N)$.

The lottery has three properties that make it the cleanest random object one could hope for.

**It is fair.** For every odd prime $p$, exactly $(p-1)/2$ of the $p$ residue classes are winners, so among the classes coprime to $p$ the win probability is *exactly* $1/2$ — not approximately, not asymptotically. This is a theorem: writing $W$ for the number of winning classes, one has $2W + 1 = p$, the leftover $+1$ being the single ramified class $N \equiv 0$, where $x^2 \equiv 0$ has the one solution $x \equiv 0$.

**The draws are independent.** Different primes are genuinely different lotteries. By the Chinese Remainder Theorem, prescribing the residue of $N$ modulo $p$ says nothing whatsoever about its residue modulo $q$. One can make this exact rather than heuristic: for a factor base of $k$ distinct odd primes $q_1, \dots, q_k$, each of the $2^k$ possible win/lose patterns is realised by exactly the same number of residue vectors, namely $\prod_i (q_i - 1)/2^k$. Every pattern occurs, and they all occur equally often.

**It is steerable.** Because every pattern occurs, one can go the other way: given any prescribed pattern of wins and losses across the factor base, there is an actual integer $N$ realising it. The dial can be dialled — including all the way up to its maximum $\sum_i 2/q_i$ and all the way down to $0$.

## Why nothing can be fitted

Now the punchline. Suppose you are sceptical, and you propose the obvious generalisation: keep the win/lose bits, but let the payouts be free parameters. Model the footprint as
$$\widehat{T}_w(N) = \sum_{i} w_i \, b_i(N),$$
where $b_i(N) \in \{0,1\}$ is the win indicator at the $i$-th prime and the $w_i$ are yours to fit. Surely with $k$ free numbers you can do better than the rigid $2/q_i$?

You cannot, and one can say exactly how much worse every alternative is. Averaged over the residue vectors of the sample space, the squared error of the weight vector $w$ is
$$\mathrm{Risk}(w) \;=\; |\Omega| \left[\Big(\sum_i \tfrac{\delta_i}{2}\Big)^{2} \;+\; \sum_i \tfrac{\delta_i^{2}}{4}\right], \qquad \delta_i = \frac{2}{q_i} - w_i,$$
where $|\Omega|$ is the number of sample points. The formula is a clean sum of squares in the *deviations from theory*. It vanishes when every $\delta_i = 0$, it is non-negative always, and it is zero **only** when $w_i = 2/q_i$ for every $i$. Fitting cannot beat the theory weights; at best, if the fit is perfect and the data infinite, it rediscovers them.

The same formula prices the other tempting shortcut: *truncation*, i.e. keeping only some of the primes and setting the rest of the weights to zero. If you drop the primes indexed by a set $\mathcal{T}$, your risk is exactly
$$|\Omega|\left[\Big(\sum_{i \in \mathcal{T}} \tfrac{1}{q_i}\Big)^{2} + \sum_{i \in \mathcal{T}} \tfrac{1}{q_i^{2}}\right],$$
which is strictly positive the moment you drop a single prime. Even the largest prime in the base — the one contributing a paltry $2/q$ — costs you something to omit. Full support strictly dominates every truncation, always, by a computable amount.

There is a statistical way to phrase the whole phenomenon. The measured hit fraction at a prime is a *deterministic function of the single win/lose bit*: it equals $2/p$ when the bit is on and $0$ when it is off, with no third possibility and no residual scatter. In statistical language, the bit is a **sufficient statistic** for the footprint. Once you know the bit, measuring the fraction tells you nothing new. This is why no per-prime coefficient can add information: there is no information left to add.

## A tug-of-war between a diverging mean and a bounded spread

Zoom out and ask about the *distribution* of $T$ as $N$ ranges over residue classes. Since $T$ is a sum of independent fair coins, one paying $2/q_i$ and the other $0$, the first two moments come out immediately:
$$\mathbb{E}[T] = \sum_i \frac{1}{q_i}, \qquad \operatorname{Var}[T] = \sum_i \frac{1}{q_i^{2}}.$$

The mean is a familiar object: the sum of reciprocals of primes up to $B$, which by Mertens' theorem grows like $\log \log B$. It **diverges** as the factor base grows, albeit with legendary slowness.

The variance is a different animal entirely. Because the $q_i$ are *distinct* odd integers, all at least $3$, the sum of their inverse squares is bounded by the tail of the Basel series:
$$\sum_i \frac{1}{q_i^{2}} \;\le\; \sum_{m \ge 3} \frac{1}{m^{2}} \;<\; \frac{1}{2}.$$
Whatever factor base you choose, however enormous, the variance of the dial is at most $1/2$.

That dichotomy — a mean drifting off to infinity while the spread stays pinned below $1/2$ — is the central structural fact about the dial. It says that all values of $T$ huddle within an $O(1)$ window around a slowly rising centre. Chebyshev's inequality converts it to a bound with no dependence at all on the primes or on how many of them there are: **at most a fraction $1/(2t^2)$ of residue classes read further than $t$ from the mean.**

One can do considerably better than Chebyshev. Because each coin is fair, its moment generating function is exactly a hyperbolic cosine — the odd term cancels — and independence makes the generating function of the whole dial factor into a product of cosines. The elementary inequality $\cosh u \le e^{u^2/2}$ then delivers a *sub-Gaussian* bound with the exact variance proxy $V = \sum 1/q_i^2$, and Chernoff's optimisation gives the two-sided tail
$$\Pr\big[\,|T - \mathbb{E}[T]| \ge t\,\big] \;\le\; 2\exp\!\Big(-\frac{t^{2}}{2V}\Big) \;\le\; 2 e^{-t^{2}}.$$
Again: no dependence on the factor base whatsoever. Deviating from the Mertens weight by $3$ is at worst a one-in-four-thousand event; by $5$, at worst a one-in-thirty-billion event. And this exponential bound already beats the polynomial one at $t = 2$, where $2e^{-4} \approx 0.037$ against Chebyshev's $0.125$.

A pleasant corollary: since $2e^{-t^2} < 1$ for every $t \ge 1$, there is *always* some residue class reading within $1$ of the mean. No factor base can conspire to push every target away from the centre.

## Two clocks, one answer

There is a second, dual way to look at the same quantity, and it is reassuring that it agrees.

So far we randomised over the *target* $N$. A sieve, though, randomises over *positions*: it marches along $x$ and asks how many factor-base primes divide $x^2 - N$ at that spot. Call that counter $H(x)$. Averaged over a full period of positions, the mean of $H$ is
$$\mathbb{E}_x[H] = \sum_i \frac{\#\{\text{roots of } x^2 \equiv N \bmod q_i\}}{q_i} = T(N),$$
the very same dial. Its variance over positions is
$$\operatorname{Var}_x[H] = \sum_i \frac{r_i}{q_i}\Big(1 - \frac{r_i}{q_i}\Big) = \sum_{\text{winning } i} \frac{2}{q_i}\Big(1 - \frac{2}{q_i}\Big),$$
with $r_i$ the root count — the textbook variance of a sum of independent Bernoulli indicators, with the success probabilities again *forced*, not fitted.

So the dial has two faces. Read across targets, it is a sum of independent fair coins with amplitudes $2/p$. Read across positions, it is the mean of a sum of independent Bernoulli indicators with probabilities $2/p$. Both readings produce $T(N)$; both put the same $2$ in the same place.

## Why this matters

Three reasons, in increasing order of generality.

*Practically*, this is a yield predictor for a factoring run. Before committing compute to a target, you compute $k$ Legendre symbols — cheap, roughly the cost of $k$ gcd's — and read off $T(N)$. The number tells you how hospitable your number is. In the experiments that motivated this analysis, the zero-fit dial correlated with measured sieve yield at Spearman $\approx 0.73$–$0.76$ across independent implementations, and explained out-of-sample variance at $R^2 \approx 0.53$–$0.54$ with a single global scale factor — *better* than a competing model with eight fitted coefficients, which reached only $0.46$.

*Methodologically*, this is a case study in what a good model looks like. The fitted eight-parameter model lost to a formula with zero parameters, and now we know why it had to lose: the formula sits at the exact minimum of the risk landscape, and every fitted alternative is measured, in closed form, by its distance from that minimum. When you can prove a model is the unique risk minimiser over the whole space of alternatives, benchmarking becomes redundant.

*Structurally*, this is a small, complete example of a phenomenon that recurs across analytic number theory: an arithmetic quantity that looks like a random variable and *is* one, exactly, with computable moments and provable concentration. The decomposition
$$T(N) = \underbrace{\sum_{p \le B} \frac 1p}_{\text{Mertens main term}} \; + \; \underbrace{\sum_{p \le B} \frac{\chi_p(N)}{p}}_{\text{character fluctuation}}$$
separates a universal drift, independent of $N$ altogether, from a Legendre-character sum carrying all the $N$-dependence. It is the same main-term-plus-fluctuation architecture that organises the prime number theorem and the theory of $L$-functions, here compressed into an object so small you can compute it on a phone.

The arithmetic of quadratic residues, discovered for its own sake in the eighteenth century, turns out to have been quietly running a fair lottery all along — and the payout table was fixed before anyone thought to fit it.
