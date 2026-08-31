# The Floor Is Sharp: Why a Fair Scheduler Always Overshoots by Less Than Two

## A promise, and its price

Imagine a single optical fibre carrying many kinds of traffic at once. Some streams are robust: nearly every photon they send arrives. Others are fragile — a rare quantum channel where only one attempt in a thousand succeeds. A scheduler sits at the head of the fibre and decides, round after round, how much time each stream gets.

The scheduler makes a promise. It says: *no stream will ever be starved*. Every class $y$ of traffic will receive at least

$$\text{ideal}(y) \;=\; \frac{\gamma\, d(y)}{\beta \log\!\big(1/p(y)\big) + M + \gamma - r(y)}$$

units of channel time. Here $d(y)$ is how much the class is asking for, $p(y) \in (0,1]$ is its *occupancy* — the probability that a slot handed to it is actually usable — and $r(y)$ is a reservation credit the scheduler has already granted. The three global constants are an inverse temperature $\beta > 0$, a scheduling quantum $\gamma > 0$, and a background cost $M$. The denominator,

$$\text{gap}(y) \;=\; \beta \log\!\big(1/p(y)\big) + M + \gamma - r(y),$$

is the Boltzmann cost of pushing one successful transfer through: a rare channel has $p(y)$ small, so $\log(1/p(y))$ is large, so the gap is large and the fair share is small. A class holding a big credit has a small gap and a big share. The formula is a thermodynamic accounting of fairness.

Now for the catch. A real scheduler cannot hand out an arbitrary real number of microseconds. It hands out *backoff windows*, and backoff windows come in powers of two: $\ldots, \tfrac14, \tfrac12, 1, 2, 4, 8, \ldots$. Faced with a fair share of $1.3$ quanta, the arbiter cannot deliver $1.3$; it must round up to $2$. The service actually delivered is

$$\text{service}(y) \;=\; 2^{\lceil \log_2 \text{ideal}(y)\rceil}.$$

So the promise is kept — nobody is starved, because rounding *up* can only be generous. But how generous? How much channel time is wasted on the rounding? That question turns out to have an exact, and rather beautiful, answer.

## The answer: exactly $[1,2)$

Define the **slack** of a class to be the ratio of what it gets to what it deserves:

$$\text{slack}(y) \;=\; \frac{\text{service}(y)}{\text{ideal}(y)}.$$

Two facts are immediate from the definition of rounding up to a power of two. First, the floor: rounding up never gives less, so $\text{ideal}(y) \le \text{service}(y)$, i.e. $\text{slack}(y) \ge 1$. That is the no-starvation guarantee. Second, the ceiling: the next power of two above $x$ is always strictly less than $2x$, so $\text{service}(y) < 2\,\text{ideal}(y)$, i.e. $\text{slack}(y) < 2$. Every class, in every exchange, always: $1 \le \text{slack}(y) < 2$.

The interesting part is that nothing smaller is true. **The set of slack values realised across all exchanges is exactly the half-open interval $[1,2)$** — every single value in $[1,2)$ occurs, and nothing outside it does. The construction is disarmingly simple. Build a one-class exchange with a perfect channel ($p \equiv 1$, so $\log(1/p) = 0$), with $\beta = \gamma = M = 1$ and credit $r \equiv 1$. Then the gap is $0 + 1 + 1 - 1 = 1$ and the ideal share is just the demand $d$. To realise a target slack $t \in [1,2)$, set the demand to $d = 2/t$. Since $1 < 2/t \le 2$, the arbiter must jump all the way to the window $2$, and the slack is exactly $2/(2/t) = t$.

Two corollaries follow. The constant $1$ in the no-starvation floor is *optimal*: no constant $c > 1$ satisfies $c \cdot \text{ideal}(y) \le \text{service}(y)$ for all exchanges, because the slack $1$ is actually attained (take demand exactly $1$, already a power of two). And the constant $2$ in the ceiling is optimal too: no $c < 2$ satisfies $\text{service}(y) \le c\cdot \text{ideal}(y)$ everywhere, because slacks arbitrarily close to $2$ occur. The factor of two is not a weakness of the analysis. It is the exact width of the grid.

That last point deserves emphasis, and it becomes obvious once you replace $2$ by a general grid ratio $\rho > 1$, so windows are the powers $\rho^{\mathbb Z}$. Then a uniform bound $\text{service} \le c\cdot\text{ideal}$ holds for all exchanges **if and only if** $\rho \le c$, and a uniform bound $c\cdot\text{ideal} \le \text{service}$ holds **if and only if** $c \le 1$. The two optimal constants are $1$ and $\rho$. The headline "factor $2$" is the grid ratio and nothing else.

There is also a structural reason the supremum $\rho$ is approached but never attained: the slack is *log-periodic*. Scaling the demand by $\rho$ scales the delivered window by exactly $\rho$, so the slack is unchanged. The slack, as a function of the logarithm of the request size, is periodic with period $\log \rho$, and on one period it sweeps the half-open interval $[1,\rho)$ — closed at $1$, open at $\rho$, forever.

## The guarantee survives the whole channel

None of this is a single-class artefact. Summing the two-sided estimate over a finite family of classes shows that the total delivered service is at least the total ideal share, and — for a nonempty family — strictly less than twice it. Quantisation costs the *whole channel* the same factor of two, no more.

And the floor is not vacuous. A class whose transport gap is large gets almost nothing: if the gap exceeds $2\gamma d(y)/\varepsilon$ then $\text{service}(y) < \varepsilon$. As the occupancy $p(y)$ of a channel tends to zero, its Boltzmann cost $\beta \log(1/p(y))$ diverges and its service is squeezed out. The no-starvation floor is a genuine, saturating constraint on a real physical trade-off, not a bookkeeping tautology.

## Can randomness help?

A natural engineering instinct: if deterministic rounding costs a factor of two in the worst case, randomise. Shift the whole ladder of windows by a random phase $\theta$, so the arbiter delivers

$$\rho^{\lceil \log_\rho x - \theta\rceil + \theta}$$

instead of $\rho^{\lceil \log_\rho x\rceil}$. Surely a random ladder smooths the worst case?

It does not. For **every** phase $\theta$, the jittered window still covers the request and still overshoots by strictly less than $\rho$. Both the floor and the ceiling are phase-independent. No distribution over phases can lower the supremum, because the supremum is already attained in the limit at every single phase. This attractive idea is simply false, and it is worth saying so out loud.

But randomisation does change the *typical* behaviour, and here something lovely happens. Measured in backoff levels — that is, in units of $\log \rho$ — the log-slack of the jittered arbiter at request $x$ is exactly

$$\{\theta - \log_\rho x\},$$

the fractional part. As the phase sweeps $[0,1)$, the log-slack is a uniform rotation on the circle $\mathbb{R}/\mathbb{Z}$. Its average is therefore exactly $\tfrac12$, whatever the request. Exponentiating, the **geometric-mean slack is exactly $\sqrt{\rho}$**, independent of the instance entirely. For the binary arbiter, $\sqrt 2 \approx 1.414$.

The arithmetic mean is different, and equally clean. Averaging $\rho^{s}$ over $s$ uniform on $[0,1]$ gives

$$\int_0^1 \rho^{s}\,ds = \frac{\rho - 1}{\log \rho},$$

so the **arithmetic-mean slack is $(\rho-1)/\log\rho$**, which for $\rho = 2$ is $1/\log 2 \approx 1.4427$.

Three constants, then, describe a grid-$\rho$ arbiter: the typical (geometric-mean) slack $\sqrt\rho$, the mean slack $(\rho-1)/\log\rho$, and the worst case $\rho$. They are strictly ordered for every $\rho > 1$:

$$\sqrt\rho \;<\; \frac{\rho-1}{\log\rho} \;<\; \rho.$$

The left-hand inequality is a strict arithmetic–geometric mean gap, and its proof has a pleasing punchline. Substituting $u = \sqrt\rho$, it reduces to $2\log u < u - 1/u$ for $u > 1$; and the function $u - 1/u - 2\log u$ vanishes at $u=1$ and has derivative $1 + 1/u^2 - 2/u = (1 - 1/u)^2$, a perfect square, hence strictly positive for $u > 1$. For $\rho = 2$ the chain reads $1.414 < 1.443 < 2$.

## Why two? Because it is close enough to $e$

If the worst-case cost of a grid is its ratio $\rho$, and the benefit of a grid is the logarithmic dynamic range $\log \rho$ each backoff level covers, then the honest figure of merit is the **grid cost**

$$C(\rho) = \frac{\rho}{\log \rho}.$$

Minimise it. The answer is not $2$. For every $\rho > 1$ we have $e \le C(\rho)$, with equality *only* at $\rho = e$, where $C(e) = e$. The unique optimal backoff ratio is Euler's number.

Engineers use $2$ anyway, and the arithmetic vindicates them: $C(2) = 2/\log 2 \approx 2.885$, against the optimum $e \approx 2.718$. The binary arbiter is within $7\%$ of the theoretical best. There is a curious symmetry too: $C(4) = 4/\log 4 = 2/\log 2 = C(2)$, so binary and quaternary backoff cost *exactly* the same. Doubling the window size is a fixed point of the design trade-off — which is presumably why so many protocols land on it.

(One must resist over-claiming. "The dyadic grid is optimal" is false; $e$ is optimal, and $3$ is closer to $e$ than $2$ is. The correct, honest statement is the $7\%$ bound, and the exact tie between $\rho = 2$ and $\rho = 4$.)

## The twist: one exchange, watched long enough, sees everything

Everything so far quantifies over *all* exchanges. Sharpness meant: somewhere in the space of possible configurations, there is an instance whose slack is nearly $2$. That is a statement about a designer's freedom, not about a running system.

So here is the sharper question. Fix a single exchange and let it run. Suppose one class's demand grows geometrically — a stream ramping up by a factor $\alpha$ per round, so the ideal share climbs the ladder $\alpha^n$. Does *that one exchange*, over time, see the whole spectrum $[1,2)$?

Take logarithms. The log-slack along the ladder is

$$\log_2 \text{slack}(\alpha^n) \;=\; \{-n\log_2 \alpha\},$$

the fractional part again. This is precisely the orbit of the point $0$ under rotation of the circle $\mathbb{R}/\mathbb{Z}$ by the angle $-\log_2\alpha$. And the behaviour of circle rotations is one of the oldest and cleanest dichotomies in mathematics — Kronecker's theorem.

**If $\log_2 \alpha$ is irrational**, the orbit is dense: for every target slack level $s \in (0,1)$ and every tolerance $\varepsilon > 0$ there is a round $n$ with $|\{-n\log_2\alpha\} - s| < \varepsilon$. The closure of the log-slack orbit is the entire interval $[0,1]$. Concretely: some rounds overshoot by more than $2^{1-\varepsilon}$ — arbitrarily close to the ceiling of $2$ — while other rounds land within $2^\varepsilon$ of the floor. A single exchange saturates both ends of the spectrum, over time, all by itself.

**If $\log_2 \alpha = p/q$ is rational**, the orbit is periodic with period $q$: shifting $n$ by any multiple of $q$ returns the same log-slack. There are at most $q$ distinct slack values, ever. A finite set cannot be dense in $[0,1]$, so such an exchange never sees the whole spectrum; it cycles through a fixed, finite menu of overshoots.

These are exhaustive and exclusive, so we get a clean dichotomy: **the slack orbit of a geometrically growing exchange is dense in the full spectrum if and only if $\log_2 \alpha$ is irrational.** Sharpness, for a fixed running system, is not a scheduling property at all. It is a Diophantine property of the growth ratio.

And it is easy to be on the dense side. $\log_2 \alpha$ is irrational for every $\alpha$ that is not a rational power of $2$. Take $\alpha = 3$: if $\log_2 3 = p/q$ then $3^q = 2^p$, contradicting unique factorisation. So a stream whose demand triples each round will, over enough rounds, come arbitrarily close to wasting a full factor of two — and, on other rounds, be served with essentially perfect efficiency. Whereas a stream that *quadruples* each round, with $\log_2 4 = 2$, sits on the grid forever: slack exactly $1$, every single round, no waste at all.

## What to take away

The arc of the story is a small lesson in how sharp constants behave. The promise — no class is starved — is exactly right, and the price of keeping it with a physically realisable arbiter is exactly the grid ratio, no more and no less. Randomising the grid cannot improve the guarantee, but it makes the typical price $\sqrt 2$ rather than $2$. The best grid ratio is $e$, and $2$ is within $7\%$ of it, tied with $4$.

And then the punchline: whether a particular running system actually feels the worst case depends on whether the logarithm of its growth rate is a rational number. Triple your demand each round and you will eventually meet every inefficiency the design permits. Quadruple it and you will never waste a single slot. Between those two behaviours lies nothing but the difference between a rational number and an irrational one — a fact about number theory, quietly governing a fact about photons.
