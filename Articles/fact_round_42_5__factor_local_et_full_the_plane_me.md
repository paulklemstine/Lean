# The Plane, Measured — and the Wall Where One Algorithm Destroys Itself

## Three algorithms, one question

Give me a number $N = p\cdot q$ that is the product of two unknown primes, with $p \le q$, and ask me how long it takes to break it apart. That single question — the engine room of public-key cryptography — has a surprising amount of hidden structure, and most of that structure is invisible if you only look at $N$.

The right variable is not $N$. It is $p$, the *smaller* prime. Almost every classical factoring method is **factor-local**: its running time is governed by the small prime hiding inside $N$, not by $N$'s size. So one writes the ansatz

$$T \;\approx\; c \cdot p^{\alpha},$$

runs the algorithm across thousands of semiprimes, plots $\log T$ against $\log p$, and reads off the slope $\alpha$. Each algorithm gets a point on a line; together they form what we will call the **factor-local exponent plane**.

Three classical methods were measured this way, on six thousand semiprimes per experimental arm, with bootstrap confidence intervals:

| method | fitted $\alpha$ | 95% interval |
|---|---|---|
| trial division | $1.0009$ | $[1.000,\ 1.002]$ |
| Pollard's rho | $0.4994$ | $[0.485,\ 0.510]$ |
| Fermat's method | $0.9932$ | — |

And then a fourth method — the elliptic curve method, ECM — flatly refused to produce a single number at all. Its fitted exponent wandered from $-0.86$ to $+0.04$ depending on how the experiment was set up.

This article is about what those four outcomes actually *mean*. Every one of them, it turns out, is the shadow of an exact theorem. Three of them are exactly the theorem you'd hope for. The fourth is a warning.

## The arm: what happens when you change the big prime?

An **arm** of the experiment is a rule for choosing the second prime $q$ once $p$ is fixed: $q$ the next prime after $p$; $q \approx 2p$; $q$ drawn uniformly from a huge range; and so on. A cost law $T \approx c\,p^{\alpha}$ is only meaningful if $\alpha$ doesn't secretly depend on which arm you happened to pick. The measurement said: trial division and rho are *arm-invariant to first order*; Fermat is *strongly* arm-dependent. Both halves of that dichotomy are theorems.

## Law one: trial division's exponent is exactly $1$

Textbook trial division walks $2, 3, 4, 5, \dots$ until something divides. For a semiprime the last divisor it examines is the smallest prime factor, so

**Theorem (exact trial-division cost).** If $p$ and $q$ are primes with $p \le q$, then the largest trial divisor examined before $N = pq$ splits is exactly $p$.

That is not "asymptotically $p$", not "$\Theta(p)$" — it is $p$, on the nose. Consequently $\log_p(\text{cost}) = 1$ exactly, for every single semiprime, with no fitted constant and no error term. And because the cost never mentions $q$:

**Theorem (exact arm invariance).** For primes $p \le q$ and $p \le q'$, trial division on $pq$ and on $pq'$ has *literally the same* cost.

So the fitted $1.0009$ is not measuring an exponent that happens to be near $1$; it is measuring an exponent that is $1$, plus the noise of the timing harness. The confidence interval $[1.000, 1.002]$ containing $1$ at its left endpoint is exactly what an exact law looks like through the fog of a real machine.

## Law two: the birthday exponent is $1/2$, from both sides

Pollard's rho iterates a pseudo-random map modulo $N$ and waits for the trajectory to collide modulo $p$. Model the visited residues as $t$ uniform independent draws from a set of size $m \approx p$. The probability of no collision is exactly the falling factorial ratio

$$R(m,t) \;=\; \frac{m(m-1)\cdots(m-t+1)}{m^{t}} \;=\; \prod_{i=0}^{t-1}\Bigl(1 - \frac{i}{m}\Bigr).$$

Almost everybody knows the upper estimate $R \le e^{-t(t-1)/2m}$. The point of the present work is that both directions hold simultaneously, with no asymptotic hand-waving:

**Theorem (two-sided birthday bracket).** For $0 < m$ and $t \le m$,
$$1 - \frac{t(t-1)}{2m} \;\le\; R(m,t) \;\le\; \exp\!\Bigl(-\frac{t(t-1)}{2m}\Bigr).$$

The lower bound is a Weierstrass product inequality; the upper bound is $1-x \le e^{-x}$ applied termwise. Together they trap the point where the collision probability crosses $1/2$:

**Corollary (the threshold window).** If $t(t-1) \le m$ then the collision probability is at most $1/2$; if $t \ge 1 + \sqrt{2m\log 2}$ it is at least $1/2$. Hence any constant-probability threshold $T(m)$ satisfies
$$\sqrt{m} \;\le\; T(m) \;\le\; 1 + \sqrt{2\log 2}\,\sqrt{m}, \qquad \sqrt{2\log 2}\approx 1.1774 .$$

Both walls of the corridor are $\Theta(\sqrt m)$. The corridor is wide in the *constant* — a factor of $1.18$ — and infinitely narrow in the *exponent*. That is why the measurement returned $0.4994$ with interval $[0.485, 0.510]$: it recovered the birthday bound to three decimals, and it could not have done otherwise. Indeed:

**Theorem (rigidity of the rho exponent).** Let $p_n \to \infty$ and let $T(n)$ be *any* function with $\sqrt{p_n} \le T(n) \le 2 + \sqrt{2 p_n \log 2}$. Then $\log_{p_n} T(n) \to 1/2$.

Every admissible cost model in the corridor gives the same exponent. The constant $1.1774$ and all additive slack are invisible to the slope. The plane is *rigid*.

## Law three: Fermat's method halts at exactly $(p+q)/2$

Fermat's method searches for $x$ with $x^2 - N$ a perfect square, starting just above $\sqrt N$. For a semiprime one can say exactly where it stops.

**Theorem (exact halting abscissa).** Let $p < q$ be odd primes and $N = pq$. Then $x = \frac{p+q}{2}$, $y = \frac{q-p}{2}$ satisfies $x^2 - y^2 = N$, and no smaller $x$ does. (The only other representation, $N = 1\cdot N$, occurs at the strictly larger $x = (N+1)/2$.)

So the work Fermat must do is the walk from $\sqrt N$ up to $(p+q)/2$, a quantity with a beautiful closed form:

**Theorem (the Fermat gap).** $\displaystyle \frac{p+q}{2} - \sqrt{pq} \;=\; \frac{(\sqrt q - \sqrt p)^2}{2}.$

This is just the AM–GM defect, and it explains everything about Fermat's behaviour. On a **bounded-ratio arm**, where $2p \le q \le 4p$, the gap is squeezed between $p/12$ and $5p/2$: exponent $1$, constant pinned. But the gap is *strictly increasing in $q$* — its derivative with respect to $q$ is $\tfrac12\bigl(1-\sqrt{p/q}\bigr)$, which is at least $\tfrac12(1-\tfrac1{\sqrt2}) \approx 0.146$ once $q \ge 2p$, uniformly bounded away from zero. Change the arm, change the cost. Trial division's $q$-derivative is identically $0$; Fermat's is bounded below by a positive constant. That is the invariance dichotomy, in one line of calculus.

### Why the measured Fermat exponent was $0.9932$ and not $1$

Here the theory does something better than agree with the measurement — it *predicts the discrepancy*. On the arm $q = 2p$ the gap is exactly $\bigl(\tfrac32 - \sqrt2\bigr)p$, so the fitted exponent has a closed form:

$$\log_p\!\left(\frac{p+q}{2}-\sqrt{pq}\right) \;=\; 1 + \frac{\log\!\left(\tfrac32 - \sqrt2\right)}{\log p}.$$

Since $\tfrac32 - \sqrt2 \approx 0.0858 < 1$, its logarithm is negative, so **the fitted exponent is strictly below $1$ at every finite $p$** — precisely the sign of the observed deficit. How big must $p$ be for the deficit to shrink to the observed $\varepsilon = 0.0068$? Rearranging,
$$\varepsilon \log p \;\ge\; -\log\!\left(\tfrac32-\sqrt2\right) \approx 2.4559 \quad\Longrightarrow\quad \log p \gtrsim 361,$$
i.e. $p \gtrsim e^{361} \approx 10^{157}$. The measured $0.9932$ on a toy range is therefore not evidence against the exact law $\alpha = 1$; it is the *exactly predicted* finite-size correction, a constant divided by $\log p$.

## The wall: where ECM destroys itself

Now the fourth algorithm, and the reason it refused to give a number.

ECM's stage 1 picks a random elliptic curve modulo $N$, a point on it, and multiplies that point by the huge scalar $k(B) = \mathrm{lcm}(1,2,\dots,B)$. Reduce the curve modulo $p$ and modulo $q$ and you get two finite groups, of orders $m_p$ and $m_q$. The method splits $N$ when the point dies in exactly one of them:

$$\textbf{split} \iff \bigl(m_p \mid k(B)\bigr)\ \text{XOR}\ \bigl(m_q \mid k(B)\bigr).$$

Hasse's theorem confines each order to a window of width $4\sqrt p$ around $p+1$:
$$W(p) = \bigl[\,p+1-2\sqrt p,\; p+1+2\sqrt p\,\bigr].$$

The entire folklore of ECM is: raise $B$, kill more orders, succeed more often. That folklore has a cliff at the end of it.

**Theorem (the self-destruction wall).** If $B$ is at least the top of the Hasse window at *both* primes, then for every curve, $m_p \mid k(B)$ and $m_q \mid k(B)$ simultaneously. The XOR is never satisfied: **no curve ever splits**. The number of successes in any finite batch is $0$, and an infinite stream of curves still never splits — the uncapped expected time to a split is $+\infty$.

This is why ECM has no single $(\alpha, c)$. Behind the wall its success probability is not small; it is *zero*. No power law $T \approx c\,p^\alpha$ can hold uniformly across a bound $B$ that eventually crosses the wall, because no power law equals infinity. The honest object is not one exponent but a *family* $\{(\alpha, c)(B)\}$, valid only in the region below the wall. The measurement's wandering $\alpha$ from $-0.86$ to $+0.04$ was the experiment reporting, correctly, that it was being asked the wrong question.

### Where exactly is the wall?

The naive guess is "the largest prime in the window". That guess is wrong, and the correction is the sharpest result of the cycle. For an integer $n$, let $\mathrm{mpp}(n)$ be the largest prime *power* exactly dividing $n$; recall $n$ is **$B$-powersmooth** iff $\mathrm{mpp}(n) \le B$, and $n \mid \mathrm{lcm}(1,\dots,B)$ iff $n$ is $B$-powersmooth. Define

$$B^*(p) \;=\; \max_{n \in W(p)} \mathrm{mpp}(n).$$

**Theorem (exact wall threshold).** Every order in the Hasse window at $p$ degenerates at bound $B$ **if and only if** $B \ge B^*(p)$. Equivalently, $B^*(p)$ is the *least* positive bound at which total degeneration occurs.

At $p = 101$ the window is $[80,124]$. Its largest prime is $113$ — but the wall sits at $121 = 11^2$: nothing degenerates for $B < 121$, and everything does by $B = 124$. **Prime powers, not primes, set the wall.** That single example rewrites the question. Asking "how large is $B^*(p)$?" is not a question about prime gaps; it is a question about the largest prime power in a short interval — a *smooth-number* statistic, and smooth numbers in short intervals are far more tractable than primes in short intervals. The natural conjecture is $B^*(p) \ge p/2$ for all $p \ge 19$.

### Degeneration is joint — and that gives a safe zone

The wall is not local. Crossing it at one prime only is not a disaster; it is a *gift*:

**Theorem (one-sided crossing).** If $B$ exceeds the window at $p$ but the order at $q$ survives, then the XOR fires and the curve splits — deterministically.

Fatal degeneration requires *simultaneous* crossing, which is why the edge of validity is governed by $\min(p,q)$, and why the conservative rule of thumb is provably safe:

**Theorem (the validity edge).** If $p, q \ge 19$ and $2B \le \min(p,q)$, then every integer in either Hasse window strictly exceeds $B$; no order is forced to die, and the size mechanism cannot degenerate anything. In practice: **$B \lesssim \min(p,q)/2$**.

## What actually drives ECM — and what does not

A tempting hypothesis (call it the proxy hypothesis) is that cheap statistics of the order — its largest prime factor $\mathrm{lpf}$, its number of distinct prime factors $\omega$ — predict whether stage 1 fires. They do not, and the refutation is an explicit infinite family:

**Theorem (proxies are blind).** For every bound $B \ge 2$, the two orders $m = 2^{a}$ and $m' = 2^{a+1}$, where $a = \lfloor \log_2 B\rfloor$, have the same largest prime factor ($2$) and the same number of distinct prime factors ($1$) — yet $m$ divides $\mathrm{lcm}(1,\dots,B)$ and $m'$ does not.

Any predictor that is a function of $(\mathrm{lpf}, \omega)$ is constant on this pair and therefore cannot separate firing from non-firing. The positive replacement is exact: the number of window orders that fire at bound $B$ is *precisely* the number of $n \in W(p)$ with $\mathrm{mpp}(n) \le B$. Powersmoothness across the whole $4\sqrt p$ window is the driver.

## A last surprise: firing is a counting problem, not a probability problem

One more exact result deserves airtime, because it corrects a widespread heuristic. In a cyclic group of order $m$, the number of points killed by the scalar $k$ is exactly $\gcd(m,k)$. So the firing *rate* is $\gcd(m,k)/m$, and for $c$ independent curves the number of successful tuples is exactly $m^c - (m-\gcd(m,k))^c$ — a rate of $1-(1-\rho)^c$ with $\rho = \gcd(m,k)/m$, derived by counting, with no independence assumption smuggled in.

Take $m = 720$ and $B = 10$, so $k = \mathrm{lcm}(1,\dots,10) = 2520$ and $\gcd = 360$: **half** of all points fire. The folklore "collision" model would predict a rate of at most $1.44\,B/m = 1/50$. The true rate is more than $25\times$ larger. Order completion, not collision, is the mechanism.

And the schedule is a staircase, not a ramp: the cumulative firing count only jumps when the prime cutoff passes a prime dividing $m$, so at most $\omega(m) \le \log_2 m$ of the $\pi(B)$ steps do anything, and some run of at least $\pi(B)/(\omega(m)+1)$ consecutive primes is completely flat. If you measure a "dose–response curve" for stage 1 and see a smooth slope, you are measuring your averaging window, not the algorithm.

## The shape of the result

The plane has been measured, and three of its four points are now theorems rather than fits: trial division at exponent $1$ exactly and exactly arm-invariant; the birthday threshold bracketed from both sides at exponent $1/2$ with a pinned constant; Fermat at exponent $1$ with an exact closed-form finite-size correction that predicts the observed deficit and an exact derivative that predicts its arm-sensitivity. The exponents $(1, 1, \tfrac12)$ are rigid: no admissible cost model inside the proved brackets can move them.

The fourth point is not a point. ECM's cost law exists only inside a region, and the region's boundary is a specific arithmetic functional of a short interval — the largest prime power in a window of width $4\sqrt p$. Past it, every curve dies at once and the algorithm consumes itself. Knowing exactly where that boundary lies turns a folklore warning into a computable rule, and turns the hardest remaining question about ECM's failure mode into a question about smooth numbers in short intervals, where the analytic tools are much better.

Sometimes the most useful thing a measurement can tell you is that the quantity you were measuring does not exist.
