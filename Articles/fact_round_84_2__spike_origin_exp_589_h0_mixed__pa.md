# The Spike That Wasn't One Thing

## A statistical bump at the edge of a factoring search turns out to be pure geometry — and a little bit of real structure

### A very old idea

Pierre de Fermat left behind a beautifully simple way to split a large number into factors. If you want to factor $N$, look for a square just above it. Start at $s = \lfloor\sqrt{N}\rfloor$ and walk upward through $j = s+1, s+2, s+3, \dots$, computing at each step the *residue*

$$v(j) = j^2 - N.$$

If $v(j)$ ever happens to be a perfect square, say $v(j) = k^2$, you are done: $N = j^2 - k^2 = (j-k)(j+k)$, and you have factored $N$ with nothing more than a subtraction and a square-root test.

For numbers whose two prime factors are close together, this finds a factorization almost immediately. For the numbers used in cryptography, it does not — which is exactly why cryptographers like them. But the *sequence of residues* $v(s+1), v(s+2), v(s+3), \dots$ remains an object of genuine interest. Modern factoring algorithms do not wait for $v(j)$ to be a perfect square; they harvest values of $v(j)$ that are **smooth**, meaning built entirely out of small prime factors, and then combine many of them algebraically. Where the smooth values sit in the search window, and how often they appear, is a question with direct practical consequences: it tells you where to spend your sieving effort.

So people scan. Fix a window — say all $j$ with $s < j \le 3s$, a stretch of $2s$ candidate positions — record every $j$ whose residue is smooth, and plot the positions. To make windows for different $N$ comparable, rescale each position to a number between $0$ and $1$:

$$u = \frac{j - s}{2s}.$$

The left edge of the window is $u = 0$; the right edge is $u = 1$.

### The bump

In one such scan, across $128$ moduli of $96$ bits each and nearly ten thousand recorded hits, something jumped out. The hits were not uniformly spread across the window. There was a **spike at the left edge**: the first tenth of the window — the first decile, $u < 0.1$ — carried about $8.6\%$ of all the mass, far more than a smooth background model predicted. Fit a two-component model to the data, one component a broad bulk and the other a narrow edge bump, and the edge component came out with weight

$$w_{\text{edge}} = 0.0794,$$

decisively better than the no-bump model.

This is the kind of finding that makes a researcher sit up. If smooth residues really do cluster at the left edge of the Fermat window, that is exploitable: you sieve the left edge harder.

But there is a nagging alternative. Residues near the left edge are *small*. At the very first position, $j = s+1$, the residue is

$$v(s+1) = (s+1)^2 - N \le 2\sqrt{N} + 1,$$

because $s^2 \le N$. For a $96$-bit modulus that is a number of about $49$ bits — half the size of $N$. And small numbers are much more likely to be smooth than large ones, for reasons that have nothing to do with Fermat, factoring, or the structure of $N$: a random $49$-bit number is enormously more likely to factor into small primes than a random $95$-bit one. So maybe the spike is not structure at all. Maybe it is a *size effect* wearing a positional costume.

The obvious way to test this is to throw away the small residues. Keep only the hits with $v \ge 2^{95}$ — full-size residues, the same bit-length as the modulus — and see whether the spike survives.

That test was run. And it produced a surprise that is not statistical at all.

### The exclusion filter is degenerate — provably

Here is the punchline, and it requires no data whatsoever.

> **Theorem (Degeneracy of the exclusion filter).** Let $N$ be a $96$-bit modulus, so $2^{95} \le N < 2^{96}$, and let $j$ be a window position in the first decile. Then $v(j) < 2^{95}$.

Every single first-decile point has a sub-$2^{95}$ residue. So the filter "keep only $v \ge 2^{95}$" does not *thin* the first decile — it *annihilates* it. It removes $100\%$ of the mass it was supposed to be testing. Whatever the filter measures, it cannot possibly distinguish "the spike is a small-residue artifact" from "the spike is genuine structure", because after filtering there is no first decile left to look at.

The proof is a two-line calculation. Write $\delta = j - s$, so that the first-decile condition is roughly $\delta < 0.2\,s$ (the window has width $2s$, so a tenth of it is $0.2\,s$ positions). Then

$$v(j) = (s+\delta)^2 - N \le (s+\delta)^2 - s^2 = 2s\delta + \delta^2 < 0.4\,s^2 + 0.04\,s^2 = 0.44\,s^2 \le 0.44\,N,$$

using only $s^2 \le N$. Being careful with the integer rounding gives the clean statement

$$100\,v(j) < 45\,N \qquad \text{whenever } N \ge 2^{16},$$

and since $0.45 < 1/2$, a first-decile residue is always less than half the modulus. For $N < 2^{96}$ that means $v < 2^{95}$. Done.

Notice what the argument does *not* use: nothing about smoothness, nothing about the data, nothing about $96$ bits in particular. The constant $0.45$ is scale-free, which yields a statement of independent charm:

> **Theorem (Scale-free bit drop).** For every modulus $N \ge 2^{16}$ and every first-decile position $j$, the residue satisfies $2\,v(j) < N$. In particular $v(j)$ has strictly fewer binary digits than $N$ — at every scale.

The lower bound $N \ge 2^{16}$ is not decoration. Without it both statements are false: the modulus $N = 36482$ (with $s = 191$) has a first-decile point $j = 230$ whose residue exceeds $0.45\,N$, and $N = 962$ (with $s = 31$) has a first-decile point $j = 38$ whose residue exceeds $N/2$. These are the last such failures — beyond a few tens of thousands, the inequality holds forever — but they are honest counterexamples, and they mark exactly how much of a size hypothesis the theorem needs.

### Where the filter actually cuts

If the filter kills the first decile, where *does* it stop killing? The answer is again exact.

The residue $v(j) = j^2 - N$ is strictly increasing in $j$. That single observation is more powerful than it looks. It means that for a *fixed* modulus, "the residue is small" and "the position is far left" are literally the same condition. Precisely, for any threshold $T \ge 1$,

$$v(j) < T \iff j \le \left\lfloor \sqrt{N + T - 1} \right\rfloor.$$

So the excluded set is a single interval hugging the left edge, and its size can be written down exactly:

$$\#\{\,j \in (s, 3s] : v(j) < T \,\} = \min\!\big(3s,\ \lfloor \sqrt{N+T-1}\rfloor\big) - s.$$

There is no probability here. The bit-length histogram of a Fermat window is a deterministic function of $N$: the number of positions whose residue has exactly $b+1$ bits is a difference of two integer square roots, and the histogram telescopes perfectly.

Plugging in $T = 2^{95}$ and $2^{95} \le N < 2^{96}$ gives a two-sided bound:

> **Theorem (Window fraction of the tiny channel).** For every $96$-bit modulus, the excluded sub-$2^{95}$ region occupies between $11\%$ and $21\%$ of the window positions.

Since the first decile occupies $10\%$, the filter always removes the entire first decile *and at least a further* $2\%$ *of the window*. It is a geometric operation on the left edge, not a data-driven one.

Push the constant as far as it will go and you find the transition is sharp on both sides. Every position with $u \le 0.1123$ has a sub-$2^{95}$ residue, for every $96$-bit modulus. And there is an explicit $96$-bit modulus with a full-size residue already at $u \le 0.2072$. So the exact universal threshold — the largest $u$ below which degeneracy is guaranteed — lies somewhere between $0.1123$ and $0.2072$, and it cannot be pushed outside that bracket.

### The two irrational numbers hiding in the data

Why $0.1123$ and $0.2072$? Because in the continuum limit the whole picture collapses onto one curve.

At normalised position $u$ we have $j \approx s(1 + 2u) \approx \sqrt{N}(1+2u)$, so

$$v \approx \big((1+2u)^2 - 1\big)N.$$

Setting this equal to the threshold $2^{95}$ and solving gives the **crossing position**

$$u_0(N) = \frac{\sqrt{1 + 2^{95}/N} - 1}{2},$$

with the exact characterisation: $\big((1+2u)^2-1\big)N \ge 2^{95}$ if and only if $u \ge u_0(N)$. Below $u_0$ the residues are tiny; above it they are full size.

Now watch what happens as $N$ ranges over the $96$-bit moduli. The function $u_0$ is strictly decreasing in $N$ — bigger moduli expose their full-size residues sooner. At the top of the range, $N \to 2^{96}$, the ratio $2^{95}/N \to 1/2$ and

$$u_0 \to \frac{\sqrt{3/2}-1}{2} = \frac{\sqrt 6 - 2}{4} = 0.11237\ldots$$

At the bottom, $N \to 2^{95}$, the ratio tends to $1$ and

$$u_0 \to \frac{\sqrt 2 - 1}{2} = 0.20711\ldots$$

So for every $96$-bit modulus the crossing position lives in the interval

$$u_0(N) \in \left( \frac{\sqrt6 - 2}{4}, \ \frac{\sqrt2 - 1}{2} \right] \subset (0.1123,\ 0.2072].$$

Two quadratic irrationals bracket the entire phenomenon. And crucially, the decile boundary $1/10$ sits **strictly below** the smaller of them. That single inequality, $0.1 < 0.11237\ldots$, is the structural reason the exclusion filter is degenerate: no full-size residue can ever appear in the first decile of any $96$-bit modulus, because the earliest such residue can appear is at $u = 0.11237\ldots$.

It also explains a number that had been sitting in the data unexplained. After filtering, the surviving hits began at $u \approx 0.114$. That was read as an empirical fact about the sample. It is not: it is $(\sqrt6-2)/4$, a theorem.

This yields a clean phase transition for the design of such filters:

> **Theorem (Phase transition).** Let $c$ be a candidate positional cut-off. If $c \le (\sqrt6-2)/4$, then for *every* $96$-bit modulus no full-size residue occurs below position $c$ — the exclusion clause is degenerate. If $c > (\sqrt2-1)/2$, then for *every* $96$-bit modulus full-size residues *do* occur below $c$ — the clause is informative. The transition window is exactly $\big((\sqrt6-2)/4,\ (\sqrt2-1)/2\big]$, and the experiment's cut-off $c = 0.1$ lies strictly inside the degenerate regime.

Could the discreteness of the integer window be hiding something? No. The exact integer count of excluded positions differs from the continuum prediction by at most $2$, and the excluded *fraction* differs from $u_0(N)$ by at most $3/s$. For a $96$-bit modulus $s \ge 2^{47}$, so the two agree to roughly fourteen decimal places. Rounding can never explain a discrepancy in a fitted weight.

### And yet: the spike is not one object

Everything so far says the filter was the wrong instrument. So what happened when it was applied anyway, to the whole dataset rather than just the first decile?

The bump did not vanish. Refitting on the surviving full-size hits gave

$$w_{\text{edge}} = 0.0403,$$

with a confidence interval of $[0.0301, 0.0525]$ — comfortably excluding zero — and a model-comparison margin that still decisively favoured including the edge component. The edge weight halved, from $0.0794$ to $0.0403$, but it survived.

The honest reading is a split verdict. Roughly half the original spike was an **inclusion artifact**: tiny-residue hits, some as small as $2\sqrt{N} \approx 2^{50}$, which are smooth far more often than full-size numbers for elementary reasons. The other half is **genuine**: an excess of smoothness among full-size residues near the left edge of the window, beyond what the standard smoothness heuristic predicts, measured at the surviving population's own left edge $u \approx 0.11$. The original headline was not wrong so much as *conflated*: the reported $8.6\%$ was two different objects added together.

Which raises the question: are position and residue size the same stratification, or different ones? Within a single modulus, they are the same — that is exactly what monotonicity of $v(j)$ says. Across moduli, they come apart, and one can exhibit it explicitly.

Take $N_1 = (2^{48}-1)^2$, a $96$-bit modulus near the top of the range. At position $u = 0.15$, its residue is already **full size**, comfortably above $2^{95}$. Now take $N_2 = 199032864766431^2$, a $96$-bit modulus just barely above $2^{95}$. At position $u = 0.20$ — considerably further right — its residue is **still below** $2^{95}$.

> **Theorem (The spike is not one object).** For $96$-bit moduli the scan window splits into three regimes: a provably tiny prefix, where the entire first decile has residues of at most $95$ bits; a provably full-size tail, where beyond $u = 0.21$ every residue has at least $96$ bits; and a modulus-dependent middle, where both behaviours occur at the same normalised position. Consequently no positional cut-off can serve as a bit-length cut-off uniformly across moduli.

So the position statistic and the bit-length band are genuinely two different ways to slice the window, and any future model of where smooth residues live needs *both*. That is not a caveat in a discussion section; it is a theorem with explicit witnesses.

### What this episode is really about

There is a temptation, when a statistical control fails to change a result, to declare the result robust. And there is an opposite temptation, when a control demolishes a result, to declare the result an artifact. The interesting cases are the ones where neither applies — where the control turns out to be *incapable of measuring what it was designed to measure*, for reasons visible only when you stop looking at the data and start looking at the geometry.

Here the geometry was elementary: a parabola, $v = j^2 - N$, sampled on an interval. Everything followed from that. The residue grows quadratically from zero, so the left edge of any Fermat window is intrinsically a low-magnitude region; the first tenth of the window is *guaranteed* to lose a bit relative to the modulus; the bit-length bands are intervals, their populations are differences of integer square roots, and the crossing point between "tiny" and "full-size" is pinned between $(\sqrt6-2)/4$ and $(\sqrt2-1)/2$ by nothing more than the range of $96$-bit numbers.

None of this needed a single data point. All of it constrains what the data can possibly say.

The practical residue, so to speak, is a checklist for anyone studying positional structure in factoring windows. Do not filter on residue size and interpret the result positionally — for a fixed modulus those are the same variable. Do not read the left edge of the surviving support as an empirical feature — it is a quadratic irrational. And do not report a single edge weight — report one per bit-length band, because the spike, as it turns out, was never one object.

What remains after all the subtraction is small but real: full-size residues near the left edge of the Fermat window appear to be smoother than they have any right to be. That is a much narrower claim than the one we started with, and a much more interesting one, because it is the only part of the original signal that geometry cannot explain away.
