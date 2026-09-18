# One Bit Is One Sample: The Hidden Exchange Rate Inside Shor's Algorithm

## A wall that wasn't there

Every account of Shor's factoring algorithm contains, somewhere, a piece of
folklore. It usually reads something like this: *to find a period $r$, your
quantum register must hold at least $2\log_2 r$ bits.* Below that line, the
story goes, the algorithm simply does not work. The register is too coarse, the
continued-fraction step cannot resolve the answer, and no amount of repetition
will save you. A wall.

The wall has a plausible pedigree. Shor's routine prepares a superposition over
a register of $q = 2^t$ computational basis states, applies a Fourier transform,
and measures. The resulting probability distribution is spiky: almost all the
mass sits on $r$ narrow *peaks*, located near the points $k \approx j\,q/r$ for
$j = 0, 1, \dots, r-1$. You get one integer $k$, and from it you must guess the
fraction $j/r$. The classical tool for that job is the theory of continued
fractions, and the classical theorem that licenses it says: if
$$\left|\frac{k}{q} - \frac{j}{r}\right| \le \frac{1}{2r^2},$$
then $j/r$ appears among the continued-fraction convergents of $k/q$ — and can
therefore be read off exactly. Since the measurement grid has spacing $1/q$, the
nearest grid point to $j/r$ is within $1/(2q)$, and $1/(2q) \le 1/(2r^2)$
precisely when $q \ge r^2$. Hence, the folklore: you need $t \ge 2\log_2 r$
bits, and below that you are lost.

That last step is the one that hides the error. It is a *worst-case* argument.
It guarantees that **every** peak is certifiable once $q \ge r^2$. It says
nothing whatsoever about how many peaks are certifiable when $q < r^2$ — and
the answer, it turns out, is: a perfectly definite, smoothly growing number of
them.

This article is about what replaces the wall. The short version is a slogan:

> **One register bit is worth one sample.**

The phase diagram of Shor period-finding, plotted with register width on one
axis and number of repetitions on the other, is not a cliff with a vertical
face. It is a **ramp** with unit slope. You can trade a qubit of register for a
doubling of your shot budget, and the trade is honest, one-for-one, all the way
down until both resources explode together.

## Counting the peaks

Start with a single measurement and a fixed register. The question is not "does
the algorithm work?" but "what fraction of the peaks are close enough to the
grid to be certifiable?" Call a peak index $j$ **certifiable** at register size
$q$ if some integer $k$ satisfies the convergent criterion above; clearing
denominators, this is
$$\exists k \in \mathbb{Z}: \quad 2r\,\bigl|jq - kr\bigr| \le q.$$

This looks like a question about grids and distances. It is really a question
about residues. Write $m = jq \bmod r$ for the *residue* of the $j$-th peak. The
peak sits at distance $m/r$ above a grid point, or $(r-m)/r$ below the next one,
and it certifies exactly when one of those distances is at most $q/(2r^2)$:
$$2rm \le q \quad\text{or}\quad 2r(r-m) \le q.$$
So certification is a condition on a single residue, and the certifiable
residues are the union of two blocks: an initial block $\{0, 1, \dots, B\}$ and a
mirror block $\{r-B, \dots, r-1\}$, where
$$B = \left\lfloor \frac{q}{2r} \right\rfloor.$$

Now the arithmetic does the rest. If the register size $q$ is coprime to the
period $r$ — which is automatic whenever $r$ is odd and $q$ a power of two — then
the map $j \mapsto jq \bmod r$ is a *bijection* of $\{0, \dots, r-1\}$ onto
itself. The peaks are perfectly equidistributed across the residues. So counting
certifiable peaks is the same as counting certifiable residues, and the two
blocks are simply counted:

> **The Peak-Counting Theorem.** Let $\gcd(q,r)=1$ and set $B=\lfloor q/(2r)\rfloor$.
> If $2B < r$, then exactly
> $$N(q,r) = 2\left\lfloor \frac{q}{2r} \right\rfloor + 1$$
> of the $r$ peaks are certifiable.

That is an *exact formula*, not an estimate. And it is immediately, devastatingly
incompatible with a wall, because dividing by $r$ gives the per-shot
certification probability
$$\frac{q}{r^2} - \frac{1}{r} \;<\; P_1 \;=\; \frac{N(q,r)}{r} \;\le\; \frac{q}{r^2} + \frac{1}{r}.$$

The certification rate is $q/r^2$, up to a single peak's worth of error. It is a
**ramp of unit slope in $q/r^2$**. It is positive everywhere that $q \ge 2r$. At
$q = r^2$ it reaches $1$ — which is exactly why $q = r^2$ looked like a
threshold. It is not the point where success becomes possible; it is the point
where success becomes *certain*. Two very different things.

Concrete numbers make the ramp vivid. Take the period $r = 21$:

| register $q$ | certifiable peaks | rate $P_1$ | $q/r^2$ |
|---|---|---|---|
| $64$  | $3$  | $0.143$ | $0.145$ |
| $128$ | $7$  | $0.333$ | $0.290$ |
| $256$ | $13$ | $0.619$ | $0.580$ |
| $512$ | $21$ | $1.000$ | $1.161$ |

The folklore wall for $r = 21$ sits at $q = 441$. At $q = 256$, comfortably
below it, nearly two-thirds of all measurements are certifiable. The "wall" is a
place where the ramp has already reached the ceiling.

## Where the real wall is

Refuting one wall does not mean there is no wall. There is — it is just
*linear*, not quadratic, and it lives a factor of $r$ lower than advertised.

The catch is that not every certificate is *useful*. If the continued-fraction
step returns the fraction $j/r$ in lowest terms and $\gcd(j,r) = d > 1$, then
what you actually recover is $r/d$, a proper divisor of the period. Call a
certificate **informative** when $\gcd(j,r)=1$, so that the denominator returned
is $r$ itself.

Tracking the same bijection through the coprimality condition gives an equally
exact count:

> **The Informative-Ramp Theorem.** Below saturation, with $\gcd(q,r)=1$ and
> $r \ge 2$, the number of informative certificates is exactly twice the number
> of integers in $[1, B]$ coprime to $r$, where $B = \lfloor q/(2r)\rfloor$.

So the usable ramp is the full ramp *thinned by the local density of totatives*
— the density of integers coprime to $r$ in a short initial segment. That is a
piece of analytic number theory sitting, unexpectedly, inside a quantum resource
bound. When $r$ is prime, no thinning happens at all: every nonzero residue is
coprime to $r$, and the informative count is exactly $2B$. When $r$ has many
small prime factors, the thinning is real, and a Legendre-type sieve bound
$\#\{\text{totatives in } [1,B]\} \ge B - \sum_{p \mid r} \lfloor B/p \rfloor$
gives what one can prove unconditionally.

And now the wall appears. The head block $[1, B]$ is *empty* precisely when
$B = 0$, i.e. when $q < 2r$. So:

> **The Linear Wall.** With $\gcd(q,r)=1$, informative certificates exist if and
> only if $q \ge 2r$. Below that — that is, with fewer than $\log_2 r + 1$ bits
> of register — every peak with coprime numerator fails to certify,
> deterministically, and no number of repetitions can help.

This is the honest home of the old "ten samples fail" observation. Deterministic
failure is real; it just happens at $q \approx 2r$, not at $q \approx r^2$. In
between lies the ramp, and in the ramp, samples buy you everything.

There is a third correction to the folklore worth recording. Even the saturation
point is misplaced. Saturation — *every* peak certifiable — happens exactly when
$r \le 2B+1$, and for odd $r$ that condition simplifies to
$$q \ge r(r-1),$$
strictly below the quoted $q = r^2$. The famous threshold is both the wrong kind
of thing (a saturation, not an onset) and in the wrong place (off by a factor
$r/(r-1)$).

## Buying bits with shots

So much for one measurement. Shor's algorithm is not run once; it is run $s$
times, and the classical post-processing succeeds if *any* sample yields a
usable certificate. Independent shots compound in the obvious way:
$$P_s = 1 - (1 - P_1)^s.$$

Two elementary inequalities pin this function between rails, and they are the
whole engine of the exchange law.

The **upper rail** is the union bound, $P_s \le s\,P_1$: if the expected number
of successes is below $1/2$, then so is the probability of any success. The
**lower rail** is subtler and is the reverse of Bernoulli's inequality:

> **Reverse Bernoulli.** For $0 \le x \le 1$ and any $n \ge 0$,
> $$(1-x)^n\,(1 + nx) \le 1.$$
>
> *Proof sketch.* Bernoulli gives $1 + nx \le (1+x)^n$. Multiply by
> $(1-x)^n \ge 0$ to get $(1-x)^n(1+nx) \le (1-x^2)^n$, and $(1-x^2)^n \le 1$
> because $0 \le 1-x^2 \le 1$. $\square$

Substituting $nx \ge 1$ gives $2(1-x)^n \le (1-x)^n(1+nx) \le 1$, hence
$P_n \ge 1/2$. In words: **once the expected number of successes reaches one,
you win with probability at least a half.** Together the rails say that the 50%
contour of $P_s$ lives exactly where the expected count $s\,P_1$ lives between
$1/2$ and $1$.

Now feed the ramp into the rails. Model the per-shot rate as
$$P_1(t) = \min\!\left(1,\; c\,2^{t}\right), \qquad c = \frac{1}{r^2},$$
which is the ramp with its natural ceiling at $1$. The expected-count coordinate
becomes $c\,s\,2^t$, and it is manifestly a function of $t + \log_2 s$ alone.
The two rails then give:

> **The Fungibility Ramp (Contour Band).** For $c > 0$, register width $t$ and
> sample budget $s$, write $P(t,s) = 1 - (1 - \min(1, c2^t))^s$. Then
> $$c\,s\,2^{t} \ge 1 \implies P(t,s) \ge \tfrac12, \qquad
> P(t,s) \ge \tfrac12 \implies c\,s\,2^{t} \ge \tfrac12.$$
> The half-success contour is therefore pinned between the two *parallel
> unit-slope lines* $c\,s\,2^t = \tfrac12$ and $c\,s\,2^t = 1$.

That is the result in one line. The contour is a straight line of slope $-1$ in
the $(\log_2 s, t)$ plane, with a band of width one bit. There is no vertical
face anywhere in the diagram. Along the contour, removing one register bit and
doubling the shot count leaves the coordinate $c\,s\,2^t$ *exactly* unchanged.
One bit is one sample.

The same law can be stated without ever mentioning a threshold, as a pure
statement about configurations. Say a configuration $(t,s)$ **reaches** the
target if $P(t,s) \ge 1/2$. Then:

> **Exchange, forward direction.** If $(t, 2s)$ reaches the target, so does
> $(t+1, s)$. A doubling of samples is worth *at most* one register bit.
>
> **Exchange, reverse direction.** If $(t+1, s)$ reaches the target, so does
> $(t, 4s)$. Two doublings of samples are worth *at least* one register bit.

The forward direction rests on the observation that dropping a bit at most
squares the failure probability: $1 - P_1(t+1) \le (1 - P_1(t))^2$, which is an
equality in the linear part of the ramp and an inequality in the saturated part.
The reverse direction runs the union bound backwards: reaching the target at
width $t+1$ forces $s\,P_1(t+1) \ge 1/2$, one bit costs at most a factor two, so
$4s\,P_1(t) \ge 1$, and the lower rail closes it.

Translating to the minimal register width $t^*(s)$ that suffices with $s$
samples, one gets the **exchange band**:
$$t^*(4^m s) \le t^*(s) - m, \qquad t^*(s) \le t^*(4^m s) + 2m.$$
Paying $2m$ sample doublings buys somewhere between $m$ and $2m$ register bits:
the exchange rate is one bit per doubling, up to a factor of two.

## What the experiments say

Proved bands are one thing; the actual slope is another. Direct simulation of
the correct measurement kernel — the arithmetic-progression distribution
$$P(k) = \frac{1}{Mq}\left|\frac{\sin(\pi M k r/q)}{\sin(\pi k r/q)}\right|^2,
\qquad M \approx q/r,$$
which is the exact Shor output distribution, not a contiguous-block
approximation — gives three measurements that fill in the picture.

**The single-sample ramp.** For families of the form $4\times\text{odd}$, the
per-shot certification rate rises smoothly with $q/r^2$: $0.003$ at
$q/r^2 = 0.028$, $0.36$ at $0.905$, plateauing near $0.46$. There is no jump
anywhere. Pure powers of two behave completely differently: they are
flat-saturated at rate $\approx 0.5$ at *every* ratio, because when $r \mid q$
every peak lands exactly on a grid point. That degenerate family is also the one
with no information content at all — at width $t = v_2(r)$ the outcome
distribution is uniform, entropy $\log_2 q$, independent of $r$.

**Sample ladders.** The compounding law $P_s = 1-(1-P_1)^s$ is not fitted; it is
predicted from the measured $P_1$ and then checked out-of-sample. An odd prime
period one bit below its wall has $P_1 = 0.725$; two samples measure $0.940$
against a prediction of $0.924$. A $2\times\text{odd}$ period three bits below
its wall has $P_1 = 0.055$; twenty samples measure $0.680$ against a prediction
of $0.677$.

**The exchange law itself.** For the odd composite period $1155$, whose folklore
wall sits at $t = 21$, the 50%-contour width shifts by
$$\{s = 2: \; 0,\quad s = 5: \; -2,\quad s = 20: \; -4,\quad s = 100: \; -6\}$$
against the ideal $-\log_2 s = \{-1, -2.3, -4.3, -6.6\}$. Every measured shift
lies inside the proved band of $[\tfrac12, 1]$ bits per doubling, and tracks the
ideal unit slope with an $O(1)$ offset.

## Why it matters

The refutation is worth dwelling on, because it is the source of the result. The
pre-registered hypothesis for this investigation was the wall: *odd period
implies deterministic certification failure below $t = 2\log_2 r$.* The
measurement refuted it. And the refutation was not a null result — it produced a
sharper law than the confirmation would have. The mechanism behind the
hypothesis was correct but applied at the wrong quantifier: deterministic
failure holds for the *worst-case* peak position, while actual peak positions
spread over the whole interval, so certification succeeds at rate $\approx q/r^2$
rather than never. The old "ten samples fail" observation was simply the
deep-ramp limit $q/r^2 \approx 0$ in disguise.

There is a practical moral. Qubits are the scarcest resource in near-term
quantum computing, and circuit *repetitions* are among the cheapest. A binary
threshold at $2\log_2 r$ says: build the register or go home. A ramp with unit
slope says: shorten the register by $m$ bits and pay $2^m$ times as many
repetitions. That is an exponential cost in $m$ — nobody is claiming otherwise —
but it is a *smooth, quantified, tunable* exponential rather than an
impossibility. For a register three or four bits short, it is the difference
between a hopeless experiment and one that runs eight to sixteen times longer.

And for the theory of quantum advantage, the shape of the trade-off is itself
the point. A threshold is a binary fact: you have the resources or you do not. A
unit-slope ramp is a *conversion rate*: quantum register width and classical
repetition count are the same currency, exchanged at par, up to one bit. The
quantum speedup is preserved — the exponential in $m$ makes sure of that — but
it is now quantitatively graded rather than all-or-nothing. The frontier between
"quantum wins" and "quantum loses" is not a line in the sand. It is a smooth
two-dimensional surface, and we now know its slope.

## Coda: what remains

Three honest soft spots remain in the argument, and each is a good problem.

First, the per-shot probability here is modelled as uniform weight on the
certifiable peaks. The true physical weight is the Dirichlet-kernel mass above,
which agrees with uniform weight only up to the familiar $4/\pi^2$ constant of
Fejér-type concentration. The conjecture is that the kernel puts at least
$4/\pi^2$ of its mass on the certifiable peaks whenever the ramp is above a
half, making the uniform model a genuine lower bound.

Second, the exchange rate is *proved* to lie in $[\tfrac12, 1]$ bits per
doubling, while every measurement points at exactly $1$ with an $O(1)$ offset.
Closing that gap means showing $t^*(2^m s) = t^*(s) - m + O(1)$ with the offset
independent of both $m$ and $s$.

Third, the sieve bound on the informative ramp goes vacuous exactly when $r$ has
many small prime factors — precisely the regime where the informative ramp is
thinnest and one would most like a bound. The natural conjecture is an
asymptotic: the informative fraction of certificates tends to $\varphi(r)/r$
uniformly in the interior of the ramp.

None of these change the headline, which is short enough to carry away: the
famous wall in Shor's algorithm is a ramp, the ramp has unit slope, and one
register bit is worth one sample.
