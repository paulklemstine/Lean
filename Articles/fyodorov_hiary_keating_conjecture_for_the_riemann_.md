# The Tallest Peak on a Number-Theoretic Mountain Range

## A wager about the Riemann zeta function

Imagine walking along an infinitely long, jagged mountain ridge. The peaks rise and fall in a way that looks random, yet the terrain is completely determined by a single, rigid rule. You are given a stretch of the ridge and asked one deceptively simple question: *how tall is the highest peak you will encounter?*

This is, in essence, one of the deepest open questions in modern number theory. The "ridge" is the graph of the Riemann zeta function $\zeta(s)$ along the *critical line* — the vertical line in the complex plane where the real part of $s$ equals $\tfrac12$. Write $s = \tfrac12 + it$, let $t$ run over a window of time $[T, 2T]$, and record the height

$$M_T = \max_{t \in [T,\,2T]} \log\bigl|\zeta(\tfrac12 + it)\bigr|.$$

How large is $M_T$ when $T$ is enormous? In 2012, Yan Fyodorov, Ghaith Hiary, and Jonathan Keating made an astonishingly precise conjecture. They predicted not just the typical size of the tallest peak, but the entire statistical law governing its fluctuations. Their answer connects three worlds that have no business talking to one another: the prime numbers, the physics of disordered materials, and the mathematics of record-breaking.

## The typical height, and the surprise in the fluctuations

The first part of the conjecture concerns the *average* height of the tallest peak. As $T$ grows, the Fyodorov–Hiary–Keating (FHK) prediction says

$$M_T \approx \log\log T \;-\; \tfrac32 \log\log\log T.$$

The leading term $\log\log T$ grows with heartbreaking slowness — you would need $T$ larger than the number of atoms in the universe to make $\log\log T$ reach even a modest value — but it does grow, and the peaks do climb. The remarkable second term, with its $-\tfrac32$ coefficient and its *triple* logarithm, is a fingerprint. That exact constant $\tfrac32$ is the signature of a phenomenon physicists call **log-correlated fields**, and it links the zeta function to the way energy is distributed in glassy, disordered systems.

But the truly beautiful part is the *fluctuation*. Subtract off the typical value and look at what remains:

$$M_T - \log\log T + \tfrac32 \log\log\log T.$$

FHK predicted that as $T \to \infty$, this recentered quantity settles into a fixed, universal probability law: **the sum of two independent Gumbel random variables.** Two, not one — a doubling that reflects a subtle two-layer structure in the problem. To appreciate why this is so striking, we need to meet the Gumbel distribution and understand why it, of all the distributions in the world, shows up whenever we ask about maxima.

## The mathematics of records

Most of statistics is about *averages*. Add up many independent random quantities, and the bell-shaped normal distribution emerges — this is the celebrated Central Limit Theorem. But extremes obey a different and less familiar law. If instead of *summing* many random quantities you take their *maximum*, you enter the domain of **extreme value theory**, and the bell curve is replaced by a small family of universal shapes. The most important of these is the **Gumbel distribution**, described by the elegant double-exponential formula

$$G(x) = \exp\!\bigl(-e^{-x}\bigr).$$

This function is a genuine cumulative distribution function (CDF): it climbs monotonically from $0$ to $1$. One can verify every property directly. It is strictly positive everywhere, since it is an exponential. It stays strictly below $1$, because $e^{-x}$ is always positive so its negative exponential never reaches $1$. It is strictly increasing and continuous. And it has exactly the right behavior at the two ends of the number line:

$$\lim_{x \to -\infty} G(x) = 0, \qquad \lim_{x \to +\infty} G(x) = 1.$$

Differentiating $G$ gives the Gumbel probability density,

$$g(x) = e^{-x - e^{-x}},$$

a positive bump that integrates to exactly $1$ over the whole line — the hallmark of a legitimate probability law. Its median sits at the tidy value $x = -\log(\log 2)$, the point where a record is equally likely to fall above or below.

## Why Gumbel? The magic of self-similarity

Why should this particular curve be the universal law of maxima? The answer is a gorgeous algebraic identity called **max-stability**.

Suppose you have $n$ independent measurements, each following the Gumbel law, and you take their maximum. Because the events "all $n$ values are below a threshold" combine by multiplication, the CDF of the maximum is $G(x)^n$. Now shift the threshold by $\log n$ and compute:

$$G(x + \log n)^n = \Bigl(e^{-e^{-(x+\log n)}}\Bigr)^n = e^{-n \, e^{-x}/n} = e^{-e^{-x}} = G(x).$$

The $n$ in the exponent and the $n$ hiding inside $e^{-\log n} = 1/n$ cancel *perfectly*. Taking the maximum of $n$ Gumbel variables and re-centering by $\log n$ gives you back an *exact* Gumbel variable — not approximately, but on the nose. The Gumbel law is a fixed point of the "take-the-max" operation. This self-similarity is precisely why it acts as a universal attractor: repeat the max-and-recenter process on almost any starting distribution, and you are pulled inexorably toward Gumbel.

## Watching the attractor at work

The abstract principle becomes concrete in the simplest possible example. Take $n$ independent random variables, each drawn from the *exponential distribution* $\mathrm{Exp}(1)$ — the waiting-time law that governs radioactive decay and the arrival of buses. The chance that a single one exceeds a value $y$ is $e^{-y}$, so the chance all $n$ stay below $\log n + x$ is

$$\Bigl(1 - \tfrac{e^{-x}}{n}\Bigr)^{\!n}.$$

As $n$ grows, the classical limit $\left(1 - \tfrac{a}{n}\right)^n \to e^{-a}$ takes over, and this expression converges to

$$\Bigl(1 - \tfrac{e^{-x}}{n}\Bigr)^{\!n} \;\longrightarrow\; e^{-e^{-x}} = G(x).$$

There it is: the maximum of $n$ exponential waiting times, recentered by $\log n$, becomes Gumbel-distributed in the limit. This is the **Fisher–Tippett–Gnedenko theorem** — the extreme-value counterpart of the Central Limit Theorem — caught in its cleanest act. It is the seed from which the entire FHK edifice grows.

## Sliding and stretching: the location–scale family

Real-world records rarely arrive pre-centered at zero with unit spread. To model them we introduce two knobs: a *location* $\mu$ that slides the distribution left or right, and a *scale* $\beta > 0$ that stretches or compresses it. The result is the two-parameter **location–scale Gumbel family**

$$G_{\mu,\beta}(x) = \exp\!\Bigl(-e^{-(x-\mu)/\beta}\Bigr),$$

which is just the standard Gumbel law viewed through a change of ruler: $G_{\mu,\beta}(x) = G\!\bigl((x-\mu)/\beta\bigr)$. Every good property survives the transformation — positivity, the bound below $1$, strict monotonicity (for $\beta > 0$), and continuity — and so does max-stability, now in the form

$$G_{\mu,\beta}(x + \beta \log n)^n = G_{\mu,\beta}(x).$$

The only change is that the recentering shift is scaled by $\beta$. This flexible family is exactly what one needs to describe maxima that live on their own natural scale, as the zeta peaks do.

## The full circle: back to the zeta function

Now the FHK prediction snaps into focus. The values of $\log|\zeta(\tfrac12+it)|$ behave, statistically, like a **log-correlated random field** — a landscape in which nearby heights are strongly correlated and distant ones are nearly independent. Such fields have a two-layer, tree-like correlation structure, and the theory of extremes for them predicts precisely the $\log\log T - \tfrac32\log\log\log T$ centering, together with a limiting fluctuation given by the **sum of two independent Gumbel variables** — one Gumbel for each layer of the hierarchy.

The full conjecture for the zeta function remains open; proving it would require controlling the zeta function with a precision far beyond what is currently known. But the *machinery* it rests upon — the Gumbel law as a bona fide probability distribution, its exact max-stability, and the extreme-value convergence that makes it universal — is fully rigorous and completely understood. Each of the statements above has been established with the certainty of formal mathematical proof:

- $G(x) = e^{-e^{-x}}$ is a legitimate CDF (positive, bounded by $1$, strictly increasing, continuous, with limits $0$ and $1$).
- Its density $g(x) = e^{-x-e^{-x}}$ is positive and integrates to $1$.
- The max-stability identities $G(x+\log n)^n = G(x)$ and $G_{\mu,\beta}(x+\beta\log n)^n = G_{\mu,\beta}(x)$ hold exactly.
- The maxima of exponential variables converge to Gumbel: $\bigl(1 - e^{-x}/n\bigr)^n \to G(x)$.
- The Gumbel median is exactly $-\log(\log 2)$.

## Why it matters

There is something almost miraculous about the appearance of the Gumbel distribution here. It was born in the 1950s to answer engineering questions about floods and material failures — *how big is the worst flood in a century? when will the weakest link break?* It has no obvious connection to prime numbers. Yet the same double-exponential curve that predicts record floods also governs the tallest peaks of the Riemann zeta function, the object whose zeros encode the deepest secrets of the primes.

This is the recurring wonder of mathematics: a single structural idea — here, the self-similarity of maxima — refuses to stay in its home discipline. It surfaces in extreme-value statistics, in the physics of spin glasses and disordered energy landscapes, and in the analytic theory of the most famous function in number theory. The Fyodorov–Hiary–Keating conjecture is a bridge between these worlds, and the Gumbel distribution — modest, elegant, and universal — is the keystone that holds it up.
