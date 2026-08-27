# The Factoring Algorithm That Isn't Gambling

## How a small experiment about elliptic curves turned a probabilistic folk model into exact arithmetic

### A machine that hunts for factors

Suppose someone hands you a large number $N$ and asks for a nontrivial factor. If $N$ is a product of two enormous primes of roughly equal size, nobody knows how to do this quickly. But if $N$ happens to have one *medium-sized* prime factor $p$ hidden inside a much larger composite, there is a beautiful algorithm that finds it: Hendrik Lenstra's **elliptic curve method**, ECM.

The idea is a piece of mathematical sleight of hand. You pick a random elliptic curve and a random point $P$ on it, and you pretend to do arithmetic "modulo $N$". You then compute a huge multiple $k\cdot P$ of the point. If, hidden inside $N$, the prime $p$ is such that the point's order in the group of points modulo $p$ divides $k$, then the computation *breaks*: a division by something that is $0$ modulo $p$ but not modulo $N$. The breakage is the prize. A single greatest-common-divisor computation coughs up $p$.

The scalar $k$ is not random. In stage 1 of ECM, it is built prime by prime:

$$k(B) \;=\; \prod_{\substack{q \le B \\ q \text{ prime}}} q^{\lfloor \log_q B\rfloor},$$

where $B$ is a *smoothness bound* the user chooses. This scalar is the product of every prime power below $B$: $k(10) = 2^3\cdot 3^2\cdot 5\cdot 7 = 2520$. The algorithm walks up the list of primes $2, 3, 5, 7, 11, \dots$ — the **schedule** — multiplying the point by one prime power at a time, and checking for breakage as it goes.

### The folk model, and the doubt about it

Practitioners have long carried around a mental model of when ECM succeeds. It says: on each curve you try, there is roughly a chance

$$1 - e^{-1.44\,B/p}$$

of a lucky hit — a *collision*, a chance coincidence in which the accumulated quantity happens to be divisible by $p$. On this account, success at a small bound $B$ is essentially gambling, and success rates ought to respond smoothly to the dose of $B$ you administer, the way a drug response curve does.

An empirical campaign put that model under strain. Running stage 1 alone against numbers with a planted medium prime $p$, at three different budgets — a bound equal to $12.5\%$, $50\%$, and $90\%$ of a natural target — the observed success rates simply refused to move. At $26$-bit primes the three rates were $0.65$, $0.75$, $0.60$; at $32$-bit primes they were $0.75$, $0.775$, $0.75$. Statistically indistinguishable from each other and, more strikingly, indistinguishable *across scales*: the confidence intervals at the two bit lengths overlapped at every dose. If the collision model were driving things, the rate should have tracked $1-e^{-1.44B/p}$ and collapsed as $p$ grew. It did not.

Even more suggestive was *when* success arrived. Recording the point in the prime schedule at which each successful run actually broke — normalized so that "$0$" means the very first prime and "$1$" means the last — the distribution was violently non-uniform. Median firing positions clustered between $0.073$ and $0.293$: the great majority of the useful work happened in the first ten to thirty percent of the schedule. Fewer than $13\%$ of successes came in the final fifth. A statistical test of uniformity was rejected decisively in all six experimental cells.

So the experiment said: this is not gambling; it is something structural, and the structure survives scaling. The question is *what* structure. Below is the answer — and it turns out not to need statistics at all.

### The event is a divisibility, not a coin flip

Here is the first and most important fact, and once you see it the probabilistic language starts to look like a costume.

> **The Firing Criterion.** A point whose order is $n$ is annihilated by the full stage-1 scalar $k(B)$ if and only if $n$ is **$B$-powersmooth**: every prime power $q^{v}$ that exactly divides $n$ satisfies $q^{v} \le B$.

There is no probability in that statement. The success event of stage 1 is a divisibility, full stop. And it comes with a truncated version that will matter in a moment: the scalar accumulated after all primes up to a cutoff $C$ kills $n$ exactly when every prime power exactly dividing $n$ is both at most $B$ *and* has a prime that has already appeared in the schedule.

The proof is the sort of thing that fits on a napkin once you look at the right object. Divisibility of one positive integer by another is equivalent to a coordinatewise inequality between their prime exponent vectors. The exponent of a prime $r$ in $k(B,C)$ is $\lfloor \log_r B\rfloor$ if $r \le C$ and $0$ otherwise. So $n \mid k(B,C)$ says exactly $v_r(n) \le \lfloor \log_r B\rfloor$ for every prime $r \le C$ dividing $n$, and $v_r(n)=0$ for larger $r$ — which is the criterion, since $v \le \lfloor\log_q B\rfloor$ means precisely $q^v \le B$.

### Counting, exactly

Model the group of points as a cyclic group of order $m$, so that a random starting point is a uniformly random residue modulo $m$. Then:

> **The Exact Rate.** A scalar $k$ annihilates exactly $\gcd(m,k)$ of the $m$ points. The success rate is exactly $\gcd(m,k)/m$.

Not "approximately", not "in expectation": exactly. The residues killed by $k$ are precisely the multiples of the cofactor $m/\gcd(m,k)$, and there are $\gcd(m,k)$ of those below $m$.

Combining with the firing criterion gives the structural identification:

> **The Firing Count Is the Powersmooth Part.** $\gcd(m,k(B))$ is the largest $B$-powersmooth divisor of $m$ — it divides $m$, it is $B$-powersmooth, and every $B$-powersmooth divisor of $m$ divides it.

So the question "how often does stage 1 fire?" is literally the question "how big is the powersmooth part of the order?" That reformulation is where the collision model dies. Consider the concrete cell $m = 720$, $B = 10$. Here $k(10) = 2520$, and $\gcd(720, 2520) = 360$. Exactly half of the group fires. The collision model, meanwhile, predicts a rate of at most $1.44 \cdot 10/720 = 0.02$ — because $1 - e^{-x} \le x$ always. The truth beats the folk prediction by more than a factor of $25$.

That comparison generalizes: whenever the powersmooth part exceeds $1.44\,B$, order completion provably outruns the collision baseline, because the baseline is bounded above by the linear function $1.44\,B/m$ while the true rate is $\gcd(m,k(B))/m$.

### Why the rate refuses to respond to dose

Now the flatness. The empirical rates were stubbornly constant across $B$; the arithmetic says they *must* be, except at rare thresholds.

> **No Dose Response.** Raising the bound from $B$ to $B'$ changes the firing count not at all, unless some prime power $q^{j}$ that actually divides the order lies in the interval $(B, B']$.

Increasing $B$ can only help — the scalar $k(B)$ divides $k(B')$ whenever $B \le B'$, so the firing count is monotone. But that monotone function is a **staircase** with very few steps. A typical order $m$ has only a handful of distinct prime factors, and only those primes' powers can ever be thresholds. Between consecutive thresholds, nothing happens. Turning the dose knob within an inert stretch buys literally zero.

And the staircase tops out:

> **Saturation.** The firing count reaches its maximum possible value, $m$ — every point fires — exactly when the order $m$ is itself $B$-powersmooth. Beyond that point, more bound buys nothing at all.

The jumps themselves have an exact size. When the schedule passes a prime $q$, the count is multiplied by $q^{\min(v_q(m),\ \lfloor\log_q B\rfloor)}$ — which is $1$, i.e. no change, whenever $q$ does not divide $m$.

The $720$ example again, watched step by step as the cutoff advances through $1, 2, 3, 5, 7, 10$:

$$1,\quad 8,\quad 72,\quad 360,\quad 360,\quad 360.$$

Four primes in the schedule; only three of the transitions do anything, and after the prime $5$ the remaining schedule is dead weight. If you had measured the "dose response" of this cell by comparing $B=7$ to $B=10$, you would have measured exactly zero — and correctly so.

### Why success arrives early

The other empirical signature was the early firing: medians in the first tenth to third of the schedule. Again, exact arithmetic explains it, and again the explanation removes the randomness from the event itself.

> **The Firing Position Is the Largest Prime Factor.** For an order that fires at all, the least cutoff $C$ at which the accumulating scalar already kills it is exactly the largest prime factor of the order.

That is a startlingly rigid statement. There is no distribution over positions for a fixed order; the position is *determined*. A run fires within the first $\pi(L)$ of its $\pi(B)$ prime steps precisely when the order has no prime factor exceeding $L$. Conversely, a late fire is a *certificate* that the order has a large prime factor.

Because typical smooth numbers have their largest prime factor far below the bound, the firing position piles up near the bottom of the schedule — exactly the observed medians. And there is a purely structural obstruction to uniformity that requires no distributional input whatsoever:

> **Sparsity of Firing Positions.** The set of schedule steps at which the cumulative count ever increases is exactly $\{q \text{ prime} : q \mid m,\ q \le B\}$. There are at most $\omega(m) \le \log_2 m$ such steps among the $\pi(B)$ steps of the schedule. Once the schedule is longer than $\log_2 m$, some step is never a firing position at all — so the distribution of firing positions cannot be uniform.

Push that further with a pigeonhole argument and you get a long dead zone:

> **The Long Inert Block.** Among the $\pi(B)$ primes of the schedule there is always a set of at least $\pi(B)/(\omega(m)+1)$ of them carrying one and the same firing count. If the order has at most one prime divisor, at least half the schedule is inert.

A uniform distribution increases at every step. A staircase with a block of that size flat cannot be uniform, and cannot be close to uniform. That is precisely the obstruction a goodness-of-fit test detects — the experiment's decisive rejections were reading off an arithmetic fact.

### The control experiment, and why it is the right one

A good experiment separates the two candidate mechanisms rather than arguing about them. This one did, using the composite's *other* factor. If $N = p\,q$ with $p$ medium and $q$ enormous, then a stage-1 run at a bound $B$ far below $q$ can conceivably hit $q$ only by accident: order completion at $q$ is impossible, because the order there certainly has a prime factor above $B$. So the count of hits at $q$ measures the collision floor and nothing else, while hits at $p$ measure collision *plus* order completion.

The arithmetic makes that control exact:

> **The Control Identity.** If every prime factor of the order exceeds the bound $B$, the firing count collapses to $1$ — only the identity element fires. The order-completion rate is exactly $1/m$.

Empirically, the two channels were cleanly separated: $9$ to $16$ collision-only hits per cell against $24$ to $31$ order-completion hits. Independently, the success rate of the *first* curve alone, at the smallest dose and largest scale, was $0.425$ — about $2.58$ times the per-curve collision baseline of $0.1647$. The excess is not a rounding error; it is the signal.

Multiple curves, incidentally, also stop being a probabilistic story:

> **Multi-Curve Amplification.** With $c$ independently chosen points, the number of tuples on which stage 1 fires at least once is exactly $m^{c} - (m - \gcd(m,k))^{c}$; the rate is exactly $1 - (1-\rho)^{c}$ with $\rho = \gcd(m,k)/m$. No independence assumption is needed — it is a count.

For $m = 720$, $B=10$, $\rho = 1/2$: three curves give exactly $7/8$. That is the shape the experiment saw at every cell.

### Why the picture doesn't degrade with scale

Finally, the scale-stability. Rates at $32$-bit primes matched rates at $26$-bit primes, dose for dose. That, too, has an arithmetic shadow:

> **Scale Invariance.** Multiplying the order by any factor coprime to the scalar leaves the number of firing points unchanged.

The part of the group order that lives above the smoothness bound is invisible to the mechanism. It changes the denominator — the rate $\gcd(m,k)/m$ shrinks if you grow $m$ while holding the smooth part fixed — but it cannot change the mechanism, and it certainly cannot convert order completion into collision luck. What the experiment measured across bit lengths was the smooth part of a randomly drawn order, and there is no reason for that to collapse over a six-bit jump. It didn't.

One more refinement matters for elliptic curves specifically. The group of points modulo a prime is not always cyclic; it is a product of at most two cyclic groups, $\mathbb{Z}/m_1 \times \mathbb{Z}/m_2$. There the firing count is the product $\gcd(m_1,k)\cdot\gcd(m_2,k)$ of the two smooth parts — which is *at least* $\gcd(m_1 m_2, k)$. Splitting the order into two factors can only help. Real curves fire at least as often as the cyclic model predicts.

### What it all means

The experimental chain that produced these questions asked whether an apparent "destruction wall" in stage-1 performance was real, whether low-bound success was luck, and whether the answer held up as numbers got bigger. The exact arithmetic settles the mechanism side completely: stage-1 success is a divisibility, its rate is a greatest common divisor, its dose response is a saturating staircase, its firing position is a largest prime factor, and its position distribution is supported on at most $\log_2 m$ of the $\pi(B)$ schedule steps. The collision heuristic is not wrong so much as *irrelevant* in this regime: it is a floor, and the observed rates sit far above it.

The practical reading is worth stating plainly. If most of the useful firing happens in the first $10$–$30\%$ of the schedule, then a great deal of stage-1 computation is spent walking through primes that provably cannot help for the order at hand. The staircase says which steps those are: everything strictly between consecutive prime divisors of the order. You cannot know those in advance, of course — that is the whole game — but you can know that the *distribution* of useful work is front-loaded, and budget accordingly.

There is an honest limit to how far this goes. That the *median* normalized firing position is small is not provable at this level of generality, because for a fixed order the position is deterministic, and for a family it depends on the distribution of largest prime factors of smooth numbers — Dickman-function territory, which is analytic input rather than pure arithmetic. What survives unconditionally is the deterministic skeleton: everything but the large-prime part has already fired by any cutoff you name. Likewise, turning a long inert block into a quantitative bound on distance-to-uniform requires knowing where the block sits, not just how long it is. Those are the next honest questions.

But the mechanism question is closed. Stage 1 of the elliptic curve method, at low bounds, is not getting lucky. It is completing orders, early, and it will keep doing so as the numbers grow.
