# The Detective Who Only Interviewed Witnesses One at a Time

### Why a hunt for hidden structure in a number-factoring sieve came up empty — and how the emptiness turned into a theorem

---

## A bump in the data

Start with a large integer $N$ that you would like to factor. One of the oldest
good ideas in computational number theory is to look at the sequence

$$y_v = (s+v)^2 - N, \qquad v = 0, 1, 2, 3, \ldots, \qquad s = \lfloor \sqrt{N} \rfloor .$$

These numbers are small compared with $N$ (they start out around $2\sqrt{N}\,v$),
and every one of them is a square minus $N$. If you can find enough values of $v$
for which $y_v$ factors completely into small primes — the technical word is
*smooth* — then a little linear algebra over $\mathbb{F}_2$ produces a congruence
$x^2 \equiv y^2 \pmod N$ and, with probability at least a half, a factor of $N$.
That is the engine inside the quadratic sieve and, in a more elaborate form,
inside the number field sieve.

Everything depends on how often a smooth $y_v$ turns up, and on *where*. So one
naturally scans: mark the positions $v$ at which a smooth value appears, call
these positions **hits**, and ask whether the hits like some places more than
others. In a large scan of exactly this kind, an excess appeared in a
particular part of the sweep — a mid-window region carried noticeably more hits
than the flanks. Not a huge excess, but a stubborn one. Something, apparently,
was steering the hits.

The obvious next question: *what*? Position indices are integers, and integers
have arithmetic personalities. Is a position more likely to be a hit when its
index is odd? When it is divisible by $7$? When it is close to a perfect square?
When it has few prime factors? When it is itself smooth? Eight such families of
"arithmetic features of the index" were written down in advance, together with
the exact thresholds that would count as a discovery, and then tested.

Every single one came back flat.

The largest honest enrichment across eight families was $R \le 1.11$; the best
per-family $p$-value was $0.36$. One raw number looked briefly exciting — the
cell $j \equiv 73 \pmod{105}$ showed $R = 1.5578$ — but it evaporated on contact
with a proper calibration, and we will see below exactly why. The verdict was
recorded as *no carrier found*.

This article is about what happened next: instead of shrugging and testing a
ninth feature, one can ask whether the null result was *forced*. It was. And the
proof of that turns out to hand you, for free, the exact law governing the place
where the structure is actually hiding.

## Marginal blindness

Here is the structural picture. Each observation lives in a grid: it has a
"row" coordinate — the position index $j$, whose arithmetic we were probing —
and a "column" coordinate collecting everything else about the observation. A
feature of the index carves the grid into vertical stripes: the stripe where
$j \equiv 3 \pmod 7$, the stripe where $j$ is smooth, and so on. The enrichment
ratio of a stripe $C$ is

$$R(C) = \frac{\text{hit rate inside } C}{\text{hit rate outside } C},$$

and the whole sweep consists of computing $R$ for a few hundred stripes.

Call the hit set **row balanced** if every row contains the same number of hits.
This is a very mild-sounding condition; it says only that the index coordinate,
taken alone, is uniform. Now the first theorem:

> **Theorem (Marginal Blindness).** If the hit set is row balanced with $m$ hits
> per row, then every stripe cut out by *any* function of the row coordinate has
> hit rate exactly $m/|B|$, where $|B|$ is the number of columns — and therefore
> enrichment ratio exactly $1$.

Not "approximately $1$", not "$1$ up to noise": exactly $1$, for every feature,
including the ones nobody has thought of yet. The proof is a two-line count: a
stripe consisting of $|S|$ rows contains $m|S|$ hits out of $|S|\,|B|$ cells,
and the $|S|$ cancels. The feature never enters the computation, which is
precisely the point.

And the converse holds too:

> **Theorem (Rigidity).** For a nonempty hit set on a grid with at least two
> rows, all single-row enrichment ratios equal $1$ **if and only if** the hit set
> is row balanced.

So a marginal sweep that reports $R = 1$ everywhere has not learned nothing —
but it has learned exactly one bit: *the rows are balanced*. Everything else
about the data is untouched. A sweep of eight families and a sweep of eight
hundred learn the same single bit.

## A carrier that hides in plain sight

Is this a real gap, or a technicality? Real, and unboundedly so. Take a grid
with $n$ rows and $n$ columns and let the hit set be the graph of a permutation
$\sigma$: the cells $(a, \sigma(a))$, one per row. This hit set is row balanced
with $m = 1$, so by the theorem above every conceivable feature of the row
coordinate returns enrichment exactly $1$. A million marginal tests would return
a million $1$s.

Yet the joint cell "the graph itself" has hit rate $1$ — every one of its cells
is a hit — against a global rate of $n/n^2 = 1/n$. Its enrichment over the
global rate is $n$, which is as large as you like.

> **Theorem (A Marginally Blind Carrier).** There exist hit sets on which every
> marginal feature of the index has enrichment exactly $1$ while a joint cell has
> hit rate $|B|$ times the global rate.

There is a second, independent way to see the same blindness. Suppose that
instead of contingency tables you fit a regression: try to predict the hit
indicator by any *additive* function $f(a) + g(b)$ of the two coordinates,
allowing $f$ and $g$ to be completely arbitrary. For the permutation-graph
carrier, every such predictor has coefficient of determination $R^2 \le 0$: it
does worse than the constant model. Two entirely different statistical
apparatuses — contingency ratios and least squares — are equally blind, because
they are blind for the same structural reason. The signal is in the *joint*
structure, and both apparatuses only ever look at one coordinate at a time.

The detective interviewed each witness separately, and each said the same
innocuous thing. The conspiracy was in what pairs of witnesses said *together*.

## Why the best of $105$ cells always looks good

Before turning to the pairs, one more piece of the empirical story deserves a
theorem, because it is the most common way that a scan fools its operator.

Suppose you split your positions into $K$ cells — say $105$ of them, one for
each residue class mod $105$ — and report the largest cell-to-global rate ratio.
Then:

> **Theorem (Selection Floor).** For any feature map and any hit set whatsoever,
> some cell has hit rate at least the global rate. Hence the best-of-$K$ ratio
> is always at least $1$.

This is pigeonhole: the cells partition the positions, so they cannot all be
below average. The immediate corollary is uncomfortable. Testing the hypothesis
"the best cell exceeds the global rate" rejects on *every* draw of the null
ensemble — its false-positive rate is exactly $1$. The test is not merely weak;
it is vacuous, and its output is a theorem about pigeonholes dressed up as
evidence about data.

The cure is to compare the observed maximum not with $1$ but with the
distribution of the *maximum* under the null. When that was done here, the null
distribution of "best of $105$ cells" had median $1.6334$ and $95$th percentile
$1.8516$. The observation was $1.5578$ — below the null's own median. And now
the second theorem in this circle of ideas closes the case with no assumptions
at all:

> **Theorem (The Median Argument).** If an observed value lies at or below a
> median of the null distribution of the statistic, its one-sided $p$-value is at
> least $1/2$.

Indeed $226$ of $300$ null draws beat the observed value, giving $p = 0.754$.
The exciting-looking $1.5578$ was not a weak signal. It was the ordinary
consequence of scanning $105$ cells and keeping the best one.

Two further facts complete the toolkit and are worth stating because they are so
often assumed rather than proved. First, the $p$-value of a maximum is at most
the sum of the per-cell $p$-values — which is exactly the Bonferroni correction,
and exactly why a per-family $p = 0.36$ says nothing on its own. Second,
permutation $p$-values are *exactly* valid in finite samples: for any statistic
and any level $\alpha \ge 0$, at most an $\alpha$-fraction of the null ensemble
has self-$p$-value $\le \alpha$. No asymptotics, no distributional assumptions,
no appeal to normality.

## Where the structure actually lives

So the marginal sweep was blind by construction and the raw maximum was noise.
Where should one look instead? At **pairs of consecutive positions** — precisely
the joint structure that the theorems above prove is invisible to any one-at-a-time
test. And here the sieve polynomial reveals something exact and rather pretty.

Fix an odd prime $q$ and ask which positions $v$ satisfy $q \mid y_v$, i.e.
$(s+v)^2 \equiv N \pmod q$. If $N$ is a nonzero square mod $q$, say $N = r^2$,
the answer is the two residues $v = r - s$ and $v = -r - s$: the familiar "two
roots per prime" that makes sieving efficient. The density of hits for this
prime is therefore exactly $2/q$, and — crucially — that density does not depend
on $N$ at all. A test that measures only the density learns nothing about $N$.

Now ask for two *consecutive* positions. Suppose $q$ divides both $y_v$ and
$y_{v+1}$. Subtracting gives $2(s+v) + 1 \equiv 0$, and substituting back gives
a startlingly rigid conclusion:

> **Theorem (Adjacency Obstruction).** If an odd prime $q$ divides two
> consecutive values $y_v$ and $y_{v+1}$, then $4N \equiv 1 \pmod q$.

Generic $N$ does not satisfy this. In fact the primes for which it *can* happen
are exactly the prime divisors of $4N - 1$ — a finite, explicitly computable
list. Away from that list, consecutive positions are **mutually exclusive**: a
prime that hits $v$ cannot hit $v+1$. And on the list, there is exactly one
adjacent double hit, at $v = -\tfrac12 - s$.

That dichotomy — zero or one, never the $\approx 4/q$ that independence would
predict — converts immediately into an exact covariance. Writing $\mathbb{1}_v$
for the indicator that $q \mid y_v$, averaged uniformly over $v \in \mathbb{Z}/q$:

$$\operatorname{Cov}(\mathbb{1}_v, \mathbb{1}_{v+1}) = \frac{\#\{\text{adjacent double hits}\}}{q} - \left(\frac{2}{q}\right)^2 = \begin{cases} -\dfrac{4}{q^2}, & 4N \not\equiv 1, \\[2mm] \dfrac{1}{q} - \dfrac{4}{q^2}, & 4N \equiv 1. \end{cases}$$

For every prime $q \ge 5$ this is *never zero*. Consecutive positions are never
independent: negatively dependent for generic targets, positively dependent on
the exceptional locus. Meanwhile the single-position density stays stubbornly at
$2/q$ in both cases. The marginal view cannot tell these two worlds apart; the
pair view separates them instantly.

The same argument runs at any lag. If $q$ divides both $y_v$ and $y_{v+k}$ with
$k \ne 0$, then $4N \equiv k^2$, so the exceptional lags are exactly $k = \pm 2r$
— **two** of the $q-1$ nonzero lags. At every other lag the covariance is
exactly $-4/q^2$, the same value, with no dependence on $k$ at all. The
dependency spectrum is flat, with two spikes. Practically, this means a
statistic that averages over lags loses no signal — a useful design fact, since
averaging buys variance reduction for free.

## The deficits add up

One prime is a curiosity. Sieving uses a whole factor base of primes, and the
statistic that matters is the *count* of factor-base primes dividing $y_v$. Do
the per-prime deficits reinforce, or cancel?

They reinforce, and the reason is the Chinese remainder theorem. Modulo a
product of distinct primes, the residue of $v$ mod $q_1$, mod $q_2$, and so on,
behave as genuinely independent coordinates: as $v$ runs over a full period,
every combination of local residues occurs exactly once. For statistics that are
sums of functions of separate coordinates, this makes every cross term in the
covariance vanish identically, leaving

$$\operatorname{Cov}\left(\sum_i f_i, \sum_i g_i\right) = \sum_i \operatorname{Cov}(f_i, g_i).$$

Applied to the sieve polynomial:

> **Theorem (Factor-Base Deficit Law).** For a factor base of odd primes
> $q_1, \dots, q_n$ with generic square targets, the number of factor-base primes
> dividing $y_v$ and the same count at $y_{v+1}$ have covariance exactly
> $$-\sum_{i=1}^{n} \frac{4}{q_i^{2}} \; < \; 0 .$$

Every prime contributes its own strictly negative $-4/q_i^2$, and nothing
cancels. Smoothness at $v$ makes smoothness at $v+1$ genuinely less likely — a
statement invisible to every marginal test of the index, but exactly quantified
here.

This is not merely formal. Sieving the actual polynomial for a prime
$N \approx 10^{12}$ across $400{,}000$ consecutive positions, with all odd primes
below $500$ as the factor base, the measured covariance between the divisor
counts at neighbouring positions comes out at $-0.0932$ against a predicted
$-0.0933$ — a $0.2\%$ discrepancy, with nothing fitted.

How big is the effect? Bounded, and dominated by the head of the base:

> **Theorem (Uniform Bound).** For any factor base of *distinct* odd primes,
> $\sum_i 4/q_i^2 \le 2$, however large the base.

The proof is a telescoping comparison with $\sum_{m \ge 3} 4/m^2$. Numerically,
summing over *all* odd primes gives $0.80899\ldots$, of which the primes $3$ and
$5$ alone contribute nearly three quarters. So the adjacent dependency is an
$O(1)$ effect: it does not diverge, it does not wash out as the factor base
grows, and it is essentially a small-prime phenomenon. That is exactly the
profile of an effect that could bias a hit-density scan in a fixed window while
remaining undetectable to any single-position statistic.

## What the null result actually taught us

It is worth being precise about the shape of the conclusion, because null
results have a reputation for being uninformative and this one is not.

The sweep did not fail to find a signal because the analysis was underpowered in
the usual sense — more data would not have helped. It failed because it was
testing a class of hypotheses that, conditional on a mild uniformity of the
index, is *provably* incapable of returning anything but $R = 1$. The flatness
of the eight families is not weak evidence for the absence of a carrier; it is
no evidence at all, because flatness was the only possible outcome. Meanwhile,
the theoretically-forced flatness coexists with joint carriers of unbounded
strength, and the sieve polynomial supplies one with an exactly computable law:
covariance $-4/q^2$ per prime at essentially every lag, accumulating to
$-\sum_i 4/q_i^2$ over a factor base, uniformly bounded by $2$.

There is a moral here that reaches well beyond factoring algorithms. A great
deal of contemporary data analysis consists of sweeping one-dimensional features
past a threshold and reporting the best one. The results above say: know the
*floor* of your scan statistic before you interpret its maximum (it is always at
least $1$, by pigeonhole); calibrate the maximum against the distribution of
maxima, not against the value $1$; and — most importantly — know which
hypotheses your test can, even in principle, distinguish. If your data have a
symmetry that forces your statistic to be constant, then your statistic is
measuring the symmetry, not the data.

The hunt goes on. The next stop is the consecutive-position study that these
theorems both motivate and equip: not "which residue class of the index is
enriched?" but "how does smoothness at one position talk to smoothness at the
next?" We already know the answer at the level of a single prime, and we know
how the answers combine. What remains is to measure how much of the observed
excess that shared arithmetic can actually explain.

Sometimes the most useful thing a null result can do is prove that it had to be
null — and point, on its way out, at exactly where to look next.
