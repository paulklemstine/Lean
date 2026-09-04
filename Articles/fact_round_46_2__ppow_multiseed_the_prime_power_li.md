# The Ghost in the Regression: How Repeated Prime Factors Hide in Plain Sight

## A small bump that refused to go away

Suppose you are handed a big list of whole numbers and asked to predict something about each one — its logarithm, say — using only *multiplicative* information. The natural first move is to record which primes divide the number. For $n = 360 = 2^3 \cdot 3^2 \cdot 5$, that means writing down $\{2, 3, 5\}$ and forming the score

$$B(n) \;=\; \sum_{p \mid n} \log p \;=\; \log 2 + \log 3 + \log 5 \;=\; \log 30 .$$

This is the logarithm of the **radical** of $n$, the product of its distinct prime divisors, written $\operatorname{rad} n$. It is the standard "which primes are present?" feature, and it is very informative: it tells you the entire squarefree skeleton of $n$.

But it is not everything. It has thrown away the *exponents*. It cannot tell $360 = 2^3 3^2 5$ apart from $30 = 2 \cdot 3 \cdot 5$, and it certainly cannot tell $4$ apart from $2$. So a second feature suggests itself: the full prime-power score

$$P(n) \;=\; \sum_p v_p(n) \log p \;=\; \log n,$$

where $v_p(n)$ is the exponent of $p$ in $n$. Add this to the model, and the fit improves.

That is exactly what a numerical experiment reported. Fitting on windows of consecutive integers drawn from smooth-number pools, adding the prime-power feature on top of the radical feature raised the coefficient of determination $R^2$ by about $0.05$. Five independent random seeds produced lifts of

$$+0.055,\quad +0.049,\quad +0.051,\quad +0.050,\quad +0.048,$$

a cross-seed standard deviation of only $0.0025$ — a twentieth of the effect itself. And when the window was lengthened from $240$ integers to $960$, the lift did not wash out; it *grew*, from $0.051$ to $0.058$ in one regime and from $0.058$ to $0.082$ in a smoother one.

Anyone who has fitted a regression knows the sinking feeling that accompanies a small, stable improvement: is this real structure, or is it the model quietly memorising noise? The purpose of this article is to report that in this case the question has a complete and satisfying answer. The bump is not statistics at all. It is arithmetic, and it can be computed exactly.

## Naming the ghost

Whatever information the second feature adds beyond the first is captured by their difference. Call it the **prime-power excess**:

$$E(n) \;=\; \log n - \log(\operatorname{rad} n) \;=\; \sum_{p \mid n} \bigl(v_p(n) - 1\bigr)\log p .$$

Three facts about $E$ are immediate and they already frame everything that follows.

**It is never negative.** Every exponent $v_p(n)$ is at least $1$ when $p$ divides $n$, so every term in the sum is $\ge 0$.

**It vanishes exactly on the squarefree numbers.** If no prime divides $n$ twice, then $\operatorname{rad} n = n$ and $E(n) = 0$. Conversely, if $E(n) = 0$ then every term must vanish, forcing every exponent down to $1$. So $E$ is *pure repeated-prime information*: it is completely blind to the squarefree part of the world and lights up only where a prime occurs more than once.

**It is not a function of the radical.** Here is the whole story in two integers: $\operatorname{rad} 4 = \operatorname{rad} 2 = 2$, yet $E(4) = \log 2$ while $E(2) = 0$. The radical feature literally cannot distinguish $2$ from $4$, and the target does distinguish them.

That last point converts directly into an error bound that no amount of clever modelling can evade. Suppose two integers $m$ and $n$ share a radical, and suppose your predictor is *any* function $f$ of the radical alone — linear, polynomial, a lookup table, a neural network, anything, so long as its only input is $\operatorname{rad}$. It must output the same value at $m$ and at $n$. A short computation (minimise $(a-t)^2 + (b-t)^2$ over the common output $t$; the minimum is at the midpoint) gives

$$\bigl(E(m) - f(\operatorname{rad} m)\bigr)^2 + \bigl(E(n) - f(\operatorname{rad} n)\bigr)^2 \;\ge\; \tfrac{1}{2}\bigl(E(m) - E(n)\bigr)^2 .$$

Applied to the pair $(p, p^2)$, whose common radical is $p$, this says: every radical-only model carries squared error at least $(\log p)^2/2$ on that pair alone. Meanwhile the prime-power model is *exact* there. The lift is forced, before any data is seen.

## The exact law: a lift made of prime powers

Positivity is one thing; a formula is better. And there is one.

A classical identity of Chebyshev says that for every $n \ge 1$,

$$\sum_{d \mid n} \Lambda(d) = \log n,$$

where the von Mangoldt function $\Lambda$ takes the value $\log p$ at every prime power $p^k$ ($k \ge 1$) and $0$ everywhere else. Split that sum into the divisors that are *primes* and those that are *higher* prime powers. The prime part is precisely $\sum_{p \mid n} \log p = \log(\operatorname{rad} n)$ — the base feature. Everything left over is the excess. Define

$$\Lambda^{\sharp}(d) = \begin{cases} \Lambda(d) & \text{if } d = p^k \text{ with } k \ge 2,\\ 0 & \text{otherwise,}\end{cases}$$

and we have the clean statement

$$E(n) \;=\; \sum_{d \mid n} \Lambda^{\sharp}(d).$$

**The base feature is the prime part of Chebyshev's identity; the lift is the higher-prime-power part.** That single sentence is the arithmetic identity of the ghost.

Now sum over a window. Interchanging the order of summation — the ancient Dirichlet trick, counting each $d$ once for each of its $\lfloor N/d\rfloor$ multiples below $N$ — gives an exact window law:

$$\sum_{n \le N} E(n) \;=\; \sum_{d \le N} \Lambda^{\sharp}(d)\,\Bigl\lfloor \frac{N}{d} \Bigr\rfloor .$$

No error term, no asymptotics. The total prime-power signal in a window is a weighted count of higher prime powers.

From this the growth is transparent. Since $\lfloor N/d \rfloor > N/d - 1$, restricting the sum to any finite family $D$ of higher prime powers gives

$$\sum_{n \le N} E(n) \;\ge\; \Bigl(\sum_{d \in D} \frac{\Lambda^{\sharp}(d)}{d}\Bigr) N \;-\; \sum_{d \in D} \Lambda^{\sharp}(d).$$

Take $D = \{4, 8\}$, whose weights are $\log 2$ apiece, and you already get the concrete bound $\sum_{n \le N} E(n) \ge N/4 - 2$ for $N \ge 8$. Take larger and larger families and the density constant climbs toward its true value

$$\sum_p \frac{\log p}{p(p-1)} \;=\; \sum_{k \ge 2}\sum_p \frac{\log p}{p^k} \;\approx\; 0.7554 .$$

So the signal is **linear in the window length**, with slope about three quarters of a natural log per integer. Doubling the window doubles the mass. The experimental observation that the lift grows with window length is not a hint; it is a slope.

## Why five seeds agreed

The most striking feature of the experiment was its stability: five different random seeds, five nearly identical lifts. Model a seed by where its window sits — an offset $a$, then the window $[a, a+w)$. Write $\mathcal{M}(a,w) = \sum_{a \le n < a+w} E(n)$ for the mass it collects.

Two bounds explain the agreement, and they say slightly different things.

The first is a *crude but completely offset-free* floor. Every fourth integer is divisible by $4$, and any $n$ divisible by $4$ has $E(n) \ge \log 2$. So a window of length $w$ contains at least $\lfloor w/4 \rfloor$ integers each carrying at least $\log 2$:

$$\mathcal{M}(a,w) \;\ge\; \Bigl\lfloor \frac{w}{4} \Bigr\rfloor \log 2 \qquad \text{for every offset } a \ge 1.$$

This is where the window length enters most vividly: four extra integers add at least $\log 2$ more, always. At $w = 240$ the floor is $60 \log 2 \approx 41.6$; at $w = 960$ it is $240 \log 2 \approx 166.4$; and the step from the short window to the long one adds at least $180 \log 2 \approx 124.8$ *on top of* whatever the short window already had. Growth with window length, made unconditional.

The second bound is sharper and is the real explanation of the seeds. Write $\rho(M) = \sum_{d \le M} \Lambda^{\sharp}(d)/d$ for the truncated prime-power density and $\Psi(M) = \sum_{d\le M} \Lambda^{\sharp}(d)$ for the total prime-power weight below $M$. Then for every offset $a \ge 1$ whose window fits below $M$,

$$\bigl| \mathcal{M}(a,w) - w\,\rho(M) \bigr| \;\le\; \Psi(M).$$

The main term $w\rho(M)$ knows nothing about $a$; the error $\Psi(M)$ also knows nothing about $a$, and — crucially — nothing about $w$. Consequently any two seeds $a, b$ satisfy

$$\bigl| \mathcal{M}(a,w) - \mathcal{M}(b,w) \bigr| \;\le\; 2\,\Psi(M),$$

while their common value grows like $\rho(M) w$. Signal linear in $w$, dispersion constant in $w$: the cross-seed standard deviation must be small compared to the effect, exactly as observed ($0.0025$ against $0.05$).

And $\Psi(M)$ really is small. Its support consists only of the true higher prime powers $p^k$ with $k \ge 2$ below $M$. For such a $p^k$ we need $p \le \sqrt M$ and $k \le \log_2 M$, so there are at most $\sqrt M\,(\log_2 M + 1)$ of them — a vanishing fraction of the $M$ integers available. The error term is essentially $\sqrt M \log^2 M$ against a main term of size $\rho(M) w$. The prime-power signal is carried by a sparse, structured, *reproducible* set of integers, which is precisely why it does not care which seed found it.

## How much lift, exactly?

All of the above shows the lift is positive and grows. The last piece of the story pins it down *with equality*, and it is the most conceptually satisfying part.

Fix any finite design $S$ of integers and any target $y$ defined on it. A "base model" is any predictor of the form $n \mapsto f(\operatorname{rad} n)$. Such a model is constant on each **fibre** of the radical — each cluster of design points sharing a radical. It sees the clusters and nothing inside them. The best it can possibly do is predict, in each cluster, the average of the target over that cluster; and its residual is then the **within-fibre sum of squares**

$$W \;=\; \sum_{c} \; \sum_{n \in S,\; \operatorname{rad} n = c} \bigl(y(n) - \bar y_c\bigr)^2 ,$$

with $\bar y_c$ the mean of $y$ over the fibre of $c$. Two statements make this precise: no base model has residual smaller than $W$, and the fibrewise-mean model achieves $W$ exactly. Hence the best possible base-only coefficient of determination is

$$R^2_{\text{base}} \;=\; 1 - \frac{W}{T}, \qquad T = \text{total sum of squares of } y \text{ on } S .$$

Since the exact prime-power model achieves $R^2 = 1$ (it *is* the target), the lift is

$$\boxed{\;\Delta R^2 \;=\; \frac{W}{T}\;}$$

— exactly, not approximately. **The measured lift is the fraction of the target's variance that lives inside the fibres of the radical.**

This single formula settles a lot at once.

*It gives a sharp dichotomy.* If the design contains even one pair $m \neq n$ with $\operatorname{rad} m = \operatorname{rad} n$ but $E(m) \neq E(n)$ — a **radical collision with different prime-power content** — then that fibre has positive variance, so $W > 0$ and $\Delta R^2 > 0$. If the design contains no such pair, then the target is constant on every fibre, $W = 0$, and $\Delta R^2 = 0$ on the nose.

For this particular pair of features the criterion is even simpler than it looks. If two *distinct* integers share a radical, then $E(m) - E(n) = \log m - \log n \neq 0$ automatically. So a collision in the required sense is nothing more than **a radical value occurring twice in the design**, and the dichotomy reads: the lift is positive exactly when some radical repeats, and zero exactly when all radicals are distinct. There is no middle ground and no room for a fitting artefact.

This is also where the shape of the experiment enters. Among consecutive integers, repeated radicals are relatively scarce — you need $n$ and, say, $2n$ or $4n$ to land in the same short window. Among *smooth* numbers, they are unavoidable. Every $y$-smooth integer has its radical among the squarefree divisors of the primorial $y\# = \prod_{p \le y} p$, of which there are only $2^{\pi(y)}$. So a pool of more than $2^{\pi(y)}$ distinct $y$-smooth numbers *must* repeat a radical; the pigeonhole leaves no choice. Concretely, among all $7$-smooth numbers up to $10^5$ there are $693$ integers but only $15$ possible radicals, and the exact lift is $W/T = 0.935$; loosening the smoothness to $y = 13, 31, 97$ gives $0.745$, $0.493$, $0.375$. Smoother pool, fewer radicals, bigger lift — the observed direction, derived rather than fitted.

*It produces honest intermediate values.* On the three-point design $\{2, 3, 4\}$ the radical takes the value $2$ on $\{2, 4\}$ and $3$ on $\{3\}$. The targets are $E(2) = 0$, $E(3) = 0$, $E(4) = \log 2$. A short computation gives $W = (\log 2)^2/2$, coming entirely from the collision fibre, and $T = \tfrac{2}{3}(\log 2)^2$. Hence

$$\Delta R^2 = \frac{(\log 2)^2/2}{\tfrac23 (\log 2)^2} = \frac{3}{4} .$$

Not $0$, not $1$: a genuinely intermediate lift, of the same qualitative kind as the measured $0.05$, on a design you can check by hand.

*It explains the smoothness dependence.* The experiment found a *larger* lift on smoother pools. Here is why, and it is pigeonhole in disguise. If every prime factor of $n$ is below $y$ — that is, $n$ is $y$-smooth — then $\operatorname{rad} n$ divides the primorial $y\# = \prod_{p \le y} p$. So the base feature is capped:

$$\log(\operatorname{rad} n) \le \log(y\#) \le y \log 4,$$

using Chebyshev's bound $y\# \le 4^y$. But the target $\log n$ is not capped. Everything above the ceiling *must* be carried by the prime-power term:

$$E(n) \;\ge\; \log n - y\log 4 .$$

In particular every $y$-smooth number exceeding $4^y$ has strictly positive prime-power signal — a cute corollary: **no $y$-smooth number above $4^y$ is squarefree**. And if $n \ge y^u$, then $E(n) \ge u\log y - y\log 4$, a floor that rises as the pool gets smoother at fixed size. The extreme case is the tower $\{2, 4, 8, \dots, 2^m\}$, where the base feature is *constant* ($\operatorname{rad} 2^k = 2$ always) while the target $E(2^k) = (k-1)\log 2$ marches upward. Its total variance is exactly $\frac{m(m^2-1)}{12}(\log 2)^2$, no base model achieves positive $R^2$ at all, and the lift is the maximal $\Delta R^2 = 1$. As designs get smoother, the base feature degenerates and *all* explanatory power migrates to the prime-power term.

## A hierarchy, and where it stops

If squares help, do cubes help more? The question has a clean answer. Interpolate between the two features by capping exponents at a level $j$:

$$F_j(n) = \sum_p \min\bigl(v_p(n), j\bigr) \log p .$$

Then $F_1 = \log(\operatorname{rad} n)$ is the base feature, $F_j = \log n$ once $j$ exceeds all exponents, and the increments are the **layers**

$$F_{j+1}(n) - F_j(n) = \sum_{p^{\,j+1} \mid n} \log p =: L_{j+1}(n),$$

so that $E = L_2 + L_3 + L_4 + \cdots$, a finite filtration of Chebyshev's identity. Each layer obeys its own exact window law,

$$\sum_{n \le N} L_k(n) = \sum_{p \le N} \log p \Bigl\lfloor \frac{N}{p^k} \Bigr\rfloor,$$

and from this the decay is immediate: replacing $p^k$ by $p^{k+1}$ at least halves every floor term, because $p \ge 2$. Hence

$$\sum_{n\le N} L_{k+1}(n) \;\le\; \tfrac12 \sum_{n \le N} L_k(n), \qquad\text{and iterating,}\qquad \sum_{n \le N} L_{k+j}(n) \le 2^{-j}\sum_{n\le N} L_k(n).$$

Summing the geometric series gives the punchline: the square layer alone already sandwiches the whole effect,

$$\sum_{n \le N} L_2(n) \;\le\; \sum_{n\le N} E(n) \;\le\; 2 \sum_{n \le N} L_2(n).$$

Adding a cube feature on top of a square feature can never gain more than the square feature already did, and the entire tail of higher-order features is worth at most twice the level you stopped at. The hierarchy is also *finite* for any window: the level-$k$ layer is identically zero once $N < 2^k$. That is a falsifiable prediction about feature engineering, derived rather than tuned.

## What the bump really was

Put the pieces together and the little $+0.05$ dissolves into something you can compute with a pencil.

The prime-power feature adds exactly the information the radical throws away: the repeated primes. That information is a von Mangoldt mass carried by the higher prime powers $4, 8, 9, 16, 25, 27, \dots$. Those numbers are sparse — about $\sqrt M \log_2 M$ of them below $M$ — but they carry positive weight $\log p$ each and they recur with density $1/p^k$, so their total mass in a window of length $w$ is $\approx 0.7554\,w$ regardless of where the window sits. The regression sees this as: a lift that is positive (there are collisions), stable across seeds (the offset-dependence is a bounded error term), growing with the window (the mass is linear in $w$), larger on smoother pools (the base feature is capped by the primorial), and dominated by squares (geometric decay in the level).

Every one of those five adjectives, teased out of noisy fits, turns out to be a theorem. And the number itself is not a fitted parameter but a ratio of two sums of squares: the variance of repeated-prime content *inside* the radical classes, divided by its total variance.

Statistics, here, was a measuring instrument pointed at a piece of number theory. What it detected was Chebyshev's identity, split in two.
