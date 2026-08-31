# The Dial That Only Turns One Way

## A small bump in a sieve, and the theorem that says divisibility can never explain it

### A bump where there shouldn't be one

Factoring a large number is, at bottom, a hunt for coincidences. The oldest good idea in the business is to look for two numbers whose squares agree modulo $N$ — if $x^2 \equiv y^2 \pmod N$ and $x \not\equiv \pm y$, then $\gcd(x-y, N)$ splits $N$ open. Modern methods manufacture such coincidences in bulk. They walk along a sequence of candidate values, most famously

$$v = j^2 - N, \qquad j = \lceil \sqrt N\,\rceil, \lceil \sqrt N\,\rceil + 1, \lceil \sqrt N\,\rceil + 2, \dots$$

and ask which of these $v$ happen to factor completely into small primes. Such values are called *smooth*, and they are the raw material from which the final congruence of squares is assembled. Everything about the speed of the method comes down to one question: **how often, and where, do the smooth values appear?**

There is a beautiful classical answer to "how often". The density of integers near $x$ whose prime factors are all below $x^{1/u}$ is governed by the *Dickman function* $\rho(u)$ — a slowly-descending curve that starts at $\rho(u)=1$ for $u \le 1$, falls to $\rho(2) \approx 0.3069$, $\rho(3) \approx 0.0486$, and thereafter plunges roughly like $u^{-u}$. Feed the sizes of the $v$'s into $\rho$ and you get a prediction for the smooth-hit profile across a scan window: a smooth, gently sloping curve with no features.

The measurement did not match. Sweeping a scan window and plotting the ratio

$$R(t) \;=\; \frac{\text{measured hits at } t}{\text{Dickman-predicted hits at } t}$$

against the normalized window coordinate $t \in [0,1]$ produced not a flat line but a distinct hump in the middle: at $t = 0.65$ the residual sat about **17.7% above** where the flanks said it should be, with an uncertainty of $\pm 4.3\%$. That is a four-sigma feature. It survived shifting the window, it survived changing $N$, and it refused to go away.

Something in the arithmetic is putting extra smooth values near the middle of the window. The obvious suspect is divisibility.

### The obvious suspect

Here is the intuition. Not all $v$ are created equal. If $3 \mid v$, then $v$ has a head start toward being smooth — one small prime factor is already free. Likewise for $5$, for $7$, and for $2$. So the population of candidates is really a mixture of sub-populations, each with its own smoothness rate. Label each $v$ by which of the four smallest primes divide it:

$$c(v) \;=\; \bigl(2 \mid v,\; 3 \mid v,\; 5 \mid v,\; 7 \mid v\bigr) \;\in\; \{\text{false},\text{true}\}^4,$$

which sorts every candidate into one of $16$ **cells**. If the cell mix happened to be richer in high-rate cells near the middle of the window, the bump would be an artifact — a bookkeeping error, not a discovery.

So one builds the natural corrective model. For each cell $c$, compute the Dickman-weighted reference sum $S_c(t)$ — the predicted contribution of cell $c$ at position $t$ — and give each cell its own free rate multiplier $\kappa_c$. The improved baseline is the mixture

$$\mathrm{PRED}(t) \;=\; \sum_{c} \kappa_c \, S_c(t),$$

with the sixteen rates $\kappa_c$ fitted on the flanks of the window only, so that the bump region cannot influence its own explanation. Then look at the new residual $T(t)/\mathrm{PRED}(t)$ and see how much of the 17.7% the mixture has eaten.

It ate **zero percent**. Not a little, not most of it — exactly none. The residual peak stayed at $t=0.65$, and the amplitude stayed at $0.1774 \pm 0.0432$.

That kind of exact null result is suspicious. When a sixteen-parameter model fails to move a number *at all*, the honest reaction is not "the effect is robust" but "the model must have been powerless for a structural reason". And it was. Finding the reason turns a failed fit into a theorem.

### Why the mixture never stood a chance

The key is a fact so simple it is easy to walk past. The cell label of $v = j^2 - N$ depends only on $v$ modulo $2$, $3$, $5$ and $7$ — that is, only on $v$ modulo $210 = 2\cdot 3\cdot 5\cdot 7$. And

$$(j + 210)^2 - N \;=\; (j^2 - N) + 210\,(2j + 210),$$

so the cell label is a **$210$-periodic function of $j$**. Whatever $N$ is.

Now count. Take any window of $210$ consecutive values of $j$, and count how many land in cell $c$. Slide the window one step to the right: you drop the member at the left end and pick up a new one at the right end — but by periodicity the new member is in exactly the same cell as the one you dropped. The count does not change. Slide again, and again, all the way to infinity in both directions:

> **Flat Composition Theorem.** For every $N$, every cell $c$, and every starting point $a$, the number of $j \in \{a, a+1, \dots, a+209\}$ with $j^2 - N$ in cell $c$ is the same. The divisibility composition of a window is completely independent of where the window is.

Concretely, for $N = 8051 = 83 \times 97$, every window of $210$ consecutive $j$ contains exactly $45$ candidates in the cell "no small prime divides $v$", $18$ in "only $7$ divides", $30$ in "only $5$", $12$ in "$5$ and $7$" — and then the same four numbers again with the parity bit flipped, $105$ odd $j$ and $105$ even $j$. Every cell containing "$3 \mid v$" is *empty*, because $8051 \equiv 2 \pmod 3$ is a quadratic non-residue: $j^2 \equiv 8051$ has no solution mod $3$, so no $v$ in the whole infinite sequence is divisible by $3$. These numbers are the same at $a = 0$, at $a = 1234$, at $a = -77777$, everywhere.

Notice the two-sidedness here. The cell rates *are* real and *are* strongly modulated. Whether a given prime $p$ divides any $v$ at all depends on whether $N$ is a quadratic residue mod $p$: there are $0$, $1$ or $2$ roots of $j^2 \equiv N \pmod p$, so the rate at which $p$ divides $v$ is $0$, $1/p$ or $2/p$ — a genuine three-way switch. In the measurement the fitted rate ratios ranged over $0.645$ to $1.406$, a factor of about $2.2$ between the leanest and the richest cells, with the top cells being combinations involving $3 \mid v$ and $5 \mid v$. Divisibility matters enormously for *how many* smooth values you find.

It just says nothing whatsoever about *where*.

### One knob, and it isn't the one you need

Once you know composition is flat, the algebra is a single line, and it is devastating. Flat composition means each cell's reference curve is a fixed fraction of one common shape:

$$S_c(t) \;=\; w_c \cdot B(t),$$

where $w_c$ is the (position-independent) share of cell $c$ and $B$ is the common Dickman shape. Substitute into the mixture:

$$\mathrm{PRED}(t) \;=\; \sum_c \kappa_c \, S_c(t) \;=\; \Bigl(\sum_c \kappa_c w_c\Bigr) B(t) \;=\; K \cdot B(t).$$

Sixteen free parameters went in; one number $K$ came out. In fact the set of *all* achievable mixture predictions is exactly the ray $\{K \cdot B : K \in \mathbb{R}\}$ — the sixteen dials are wired together into a single volume knob. This is the whole content of the slogan:

> **Divisibility is a rate dial, not a position dial.**

Everything else follows immediately. The residual over the mixture is

$$\frac{T(t)}{\mathrm{PRED}(t)} \;=\; \frac{1}{K}\cdot\frac{T(t)}{B(t)},$$

a constant rescaling of the old residual. Constant rescalings cancel out of ratios, so the *relative* mid-window excess

$$\frac{R(t_0)}{R(t_1)} - 1$$

is literally unchanged: **removal is exactly $0\%$**, as a theorem, not as a measurement. The peak cannot move either — rescaling by a positive constant preserves every comparison $R(t) \le R(t_0)$, so the argmax stays where it was, at $t = 0.65$. And if the measured profile $T$ is not proportional to $B$ at even two positions, then no mixture whatsoever reproduces it.

The experiment's $0\%$ was not a coincidence. It was the only possible answer.

### Being honest about "exactly"

Real windows are not exactly $210$ long, and real compositions are flat only to measurement precision. The measured cell drift across the window was $0.269\%$ — small, but not zero. A negative result that depends on an idealization is worth little, so the estimate has to be made robust.

If each cell's reference sum is within a relative factor $\delta$ of the exactly-flat value, then the mixture is squeezed between $(1-\delta)KB(t)$ and $(1+\delta)KB(t)$, and one gets a clean quantitative bound: if the raw excess ratio is $\rho$, the mixture-residual excess ratio is at least

$$\rho \cdot \frac{1-\delta}{1+\delta}.$$

Put in the measured numbers, $\rho = 1.1774$ and $\delta = 0.00269$: the surviving excess is at least $0.1710$. The registered detection bar was $2\times$ the standard error, $2 \times 0.0432 = 0.0864$. The excess clears it by a factor of two, and it also clears twice the more conservative null-calibrated standard error, $2 \times 0.0411 = 0.0822$.

Turn the inequality around and it becomes a *budget*, which is the most portable form of the result:

> **Drift Budget.** To absorb a raw relative excess $\rho - 1$ completely, a mixture's composition drift must satisfy $\delta \ge \dfrac{\rho-1}{\rho+1}$.

For $\rho - 1 = 0.1774$ that demands $\delta \ge 8.1\%$. The measured drift is $0.269\%$ — more than thirty times too small. And notice what this statement does *not* mention: the size of $N$, the length of the window, the choice of prime bound. It is scale-free, so it transfers to any bit length unchanged.

### Killing an entire family of suspects

Divisibility by $2, 3, 5, 7$ was only the first candidate. The natural next guesses were: divisibility by larger primes; higher power residues of $v$; the low bits of $j$; Legendre symbols $\left(\frac{j^2-N}{p}\right)$ for $p > 7$. Each is a different classifier, and one could imagine grinding through them one at a time.

There is no need, because the argument above used nothing about the primes $2,3,5,7$ except one property: **periodicity**. Any classifier of $j$ that factors through the integers mod $m$ — a divisibility pattern, a power-residue symbol, a quadratic character, a bit pattern of $j^2-N$, any Boolean combination of these — is automatically $m$-periodic in $j$, since $(j+m)^2 - N \equiv j^2 - N \pmod m$. So its window composition is flat whenever the window length is a multiple of $m$, so its mixture family is a ray, so it removes exactly $0\%$. The whole residue world dies in one stroke.

Even for windows whose length $L$ is *not* a multiple of $m$, the damage is bounded exactly: two windows of length $L$ can differ in any class population by at most $L \bmod m < m$ members, a relative drift below $m/L$. Combine with the drift budget and you get a hard threshold: a residue carrier at modulus $m$ can absorb the excess only if $m/L \geq 8.1\%$, i.e. only if its period is a substantial fraction of the whole window. A modulus that small is not a hidden arithmetic mechanism; it is the window itself.

So the follow-up question sharpens into a genuine constraint:

> **The carrier must be aperiodic.** Whatever arithmetic mechanism concentrates smooth values near $t = 0.65$, it cannot factor through $\mathbb{Z}/m\mathbb{Z}$ for any modulus $m$ dividing the window length. It is not a divisibility pattern, not a Legendre symbol, not a residue class, not a bit pattern of $j^2 - N$.

### The result is about the world, not about the method

A negative theorem invites a nagging worry: maybe mixture models just never remove anything, and the whole framework is vacuous. It isn't, and this can be shown crisply.

Allow a reference family whose cells are permitted to drift with position — a *genuinely positional* family. The simplest example has two cells, one carrying the flat Dickman shape $B$ and one carrying the measured profile $T$ itself. Fit it, and the mixture reproduces the measurement exactly: the residual becomes constant and the excess is removed **completely**, $100\%$. And aperiodic carriers with position-dependent composition genuinely exist: the crude "is $j \ge 0$?" classifier puts an entire window in one class at $a=0$ and the entire window in the other class just to the left of the origin — maximal composition drift, and hence periodic at no modulus at all.

Side by side, this is the dichotomy that gives the work its shape: over a flat-composition grid the fitting procedure preserves the excess *exactly*, for every choice of rates; over a positional family the very same procedure annihilates it. The $0\%$ is a fact about the divisibility grid, not about the formalism.

### What has been learned

The bump at $t \approx 0.65$ is real, it is stable, and it now has a definite negative characterization: it is carried by something outside the entire arithmetic-residue universe. That is a much stronger statement than "the sixteen-cell fit failed". It removes an infinite family of candidate explanations at every modulus and every problem size simultaneously, and it does so with a criterion — aperiodicity of the carrier — that can be checked before running an experiment rather than after.

The surviving candidates are the ones that see the *size* of things rather than their residues: how large $v = j^2 - N$ actually is as $j$ moves across the window, how close $j$ is to a truncation boundary, valuation effects that grow rather than repeat. Those are genuinely positional quantities. They vary monotonically, not cyclically. They are, by the theorem above, exactly where the search must now go.

There is a general lesson here for anyone who fits mixture models to data. The reflex when a bump refuses to die is to add parameters. But parameters are only worth what their *span* is worth. Sixteen rate parameters over a periodic grid span a one-dimensional space — a single volume knob, useless against a feature that lives in position. Before adding a knob, ask what it can move. Sometimes the most informative thing a model can tell you is that it was never able to say anything at all.
