# The Dial That Could Not Fall

## What a stubborn number told us about ties, coarseness, and the limits of correlation

There is a particular kind of scientific pleasure in a number that refuses to
behave. Ours was $0.648$.

The number is a rank correlation — a Spearman coefficient, the workhorse
statistic that asks not "how big" but "in what order". We had been tracking it
across a grid of experiments, watching it slowly slide: about $0.78$ when our
inputs were 44-bit integers, then down, and down, until at 64 bits it settled at
$0.648$, with three independent random seeds agreeing closely ($0.658$, $0.642$,
$0.643$) and a pooled confidence interval of $[0.629, 0.665]$.

That gentle decline was the puzzle. The quantity being correlated was a
*zero-count*: for each integer drawn uniformly at random, count how many binary
zeros sit at its right-hand end before the first $1$. (The number $40 = 101000_2$
has three; the number $7 = 111_2$ has none.) Against this count we correlated a
downstream "rate". As the bit-length grew, the correlation drifted downward.
Why?

The obvious suspect was **ties**. A zero-count is a very lumpy statistic: half of
all integers have zero trailing zeros, a quarter have exactly one, an eighth have
exactly two. Enormous numbers of observations share the same value. And ties are
known to depress rank correlations — when a hundred observations are all
assigned the same rank, the statistic simply has less ordering information to
offer. As the bit-length grows, the number of distinct zero-count values grows
too, so maybe the tie structure is quietly changing and dragging the dial with
it.

This article is the story of how we made that suspicion precise enough to test —
and then killed it, cleanly, with an exact formula.

---

## Midranks, and a piece of luck

To correlate a tied variable, statisticians use **midranks**: sort your $n$
observations, and give every member of a tied block the average of the rank
positions that block occupies. Twelve observations tied for positions $3$ through
$6$? All four of them receive the midrank $4.5$.

Now suppose you correlate such a midranked statistic against a response that is
*finer* — a response that never ties two observations the statistic separates,
and which orders the observations inside each tied block in some way. This is
exactly the situation of the zero-count against a continuous rate: the rate
distinguishes items that the coarse zero-count lumps together.

Something lucky happens here. The midrank vector is, by construction, the average
of the response's ranks within each block. In probabilistic language, the coarse
vector $R$ is the conditional expectation of the fine vector $S$ given the block.
And conditional expectations satisfy the *tower property*, so
$$\operatorname{Cov}(R, S) = \operatorname{Var}(R).$$
The cross-term collapses. The whole correlation problem reduces to comparing two
variances — and that is a purely combinatorial question about block sizes.

**Theorem (Tie-Attenuation Law).** *Let a discrete statistic take tied values in
blocks of sizes $m_1, \dots, m_g$ with $\sum_j m_j = n \ge 2$, scored by
midranks, and let it be measured against any response whose ordering refines
those blocks. Then the squared Spearman correlation is exactly*
$$\rho^2 \;=\; 1 \;-\; \frac{12 \sum_{j} (m_j^3 - m_j)}{n^3 - n}.$$

The sum $T = \frac{1}{12}\sum_j (m_j^3 - m_j)$ is a classical object — the
*Kendall tie correction*, the amount of rank variance destroyed inside the tied
blocks — and $V = (n^3-n)/12$ is the total rank variance. So the law says simply
$\rho^2 = (V - T)/V$: the fraction of the ordering information that survives the
lumping.

Two corollaries are immediate and reassuring. The right-hand side never exceeds
$1$, and it equals $1$ exactly when every block has size $1$, i.e. exactly when
there are no ties at all. A tie-free statistic against a refining response is a
perfect rank match; every tie costs you, and the cost of a block of size $m$ is
$(m^3 - m)/12$, cubic in the block size. Big blocks are catastrophic; a few
doubletons barely register.

The law is remarkable for what it *doesn't* mention. It doesn't mention the
response, at all — only that it refines the blocks. Whatever the downstream rate
happens to be, however it is generated, the correlation is pinned by the
statistic's tie profile alone. That makes it a **ceiling**, and ceilings are
falsifiable.

---

## Counting zeros, exactly

So compute the ceiling for our statistic. Among the $2^b$ integers below $2^b$,
exactly $2^{b-1}$ are odd (zero trailing zeros), $2^{b-2}$ have exactly one,
$2^{b-3}$ have exactly two, and so on down to a single integer with $b-1$
trailing zeros; plus the number $0$ itself, sitting alone. So the tie profile is
the geometric list
$$2^{b-1},\; 2^{b-2},\; \dots,\; 2,\; 1,\; 1.$$

Plugging a geometric profile into a cubic sum is a geometric series in disguise:
$\sum_k (2^{b-1-k})^3 = \sum_k 8^{b-1-k}$, which telescopes against the $8$'s.
The arithmetic delivers something beautiful.

**Theorem (Dyadic Ceiling).** *For uniform $b$-bit draws with $b \ge 1$, the
trailing-zero statistic scored by midranks against any refining response
satisfies exactly*
$$\rho^2 \;=\; \frac{6}{7}\left(1 + \frac{1}{2^b(2^b+1)}\right).$$

The ceiling is strictly decreasing in $b$ and converges to $6/7$ from above; in
correlation units,
$$\rho \;\longrightarrow\; \sqrt{6/7} \;=\; 0.9258200\ldots$$

The derivation is three lines. With $x = 2^b$ observations, the cubic mass is
$\sum_j m_j^3 = \sum_{k=0}^{b-1} 8^{\,b-1-k} + 1 = \frac{x^3-1}{7} + 1$, so the
law gives
$$\rho^2 = 1 - \frac{\frac{x^3-1}{7} + 1 - x}{x^3 - x}
 = \frac{6}{7}\cdot\frac{x^3-1}{x^3-x}
 = \frac{6}{7}\cdot\frac{x^2+x+1}{x^2+x}
 = \frac{6}{7}\left(1 + \frac{1}{x(x+1)}\right).$$

The $6/7$ is worth savouring. It is the signature of a geometric tie profile with
ratio $1/2$: in the large-$n$ limit the law reads $\rho^2 \approx 1 - \sum_j p_j^3$
where $p_j$ are the class proportions, and halving proportions contribute cubic
mass $\sum_{k \ge 1} 8^{-k} = 1/7$. Hence $\rho^2 \to 1 - 1/7 = 6/7$. A statistic
whose values are geometrically distributed with ratio $1/2$ can never correlate
better than $0.9258$ with anything, no matter how informative the response.

And now the punchline. How much does that ceiling move between bit-length $44$
and bit-length $64$? The correction term is $\frac{1}{2^b(2^b+1)}$, which at
$b=44$ is already smaller than $3 \times 10^{-27}$. The ceiling drops by less
than $10^{-26}$ over the whole range of our experiment.

The recorded dial dropped from $0.78$ to $0.648$. In squared units, from
$0.6084$ to $0.419904$ — a drop of $0.188$.

**A gap of twenty-four orders of magnitude.** Whatever is pushing the dial down,
it is not the tie granularity of the zero-count. The suspect has an alibi.

---

## Blaming the instrument, and failing again

A good detective checks the alibi. Real instruments truncate: perhaps the
zero-count is not recorded in full, but capped at some value $c$, with every draw
having $c$ or more trailing zeros dumped into a single merged bucket. A merged
bucket is a *huge* tied block, and huge blocks are cubically expensive. Surely a
small enough cap explains a low reading?

The same machinery answers this exactly. Capping at $c$ replaces the tail of the
geometric profile with one block of size $2^{b-c}$, and the cubic sum is again a
finite geometric series.

**Theorem (Truncation Ceiling).** *Capping the trailing-zero count at $c$, with
$1 \le c \le b$, gives exactly*
$$\rho^2(b,c) \;=\; \frac{6}{7} \cdot \frac{8^{b} - 8^{\,b-c}}{8^{b} - 2^{b}}.$$

This is increasing in $c$ — more resolution, higher ceiling, as it must be — and
its minimum over all admissible caps is attained at $c = 1$, where it exceeds
$3/4$. **No cap, at any bit-length, produces a ceiling below $0.75$.** The
recorded $\rho^2 = 0.419904$ sits far beneath. Truncation is refuted.

The formula also stitches the story together: at $c = b$ it reproduces the full
dyadic ceiling, and at $c = 1$ — where capping degenerates to the even/odd split
— it reproduces the balanced two-class value we are about to meet. Three separate
computations, one consistent picture.

---

## If not the statistic, the response

By elimination, the coarseness must live on the *other* side of the correlation.
So we generalised the law to the two-sided case. Suppose both variables are
tied, and suppose the response's blocks *refine* the statistic's — nested, like
counties inside states.

The midrank collapse survives nesting, and for a lovely reason: averaging fine
midranks inside a coarse block, weighted by the fine block sizes, returns exactly
the coarse midrank. The tower property doesn't care how fine the fine partition
is, only that it refines the coarse one.

**Theorem (Two-Sided Attenuation Law).** *Let the response's tie blocks refine
the statistic's, with $n \ge 2$ observations, $V = (n^3-n)/12$, and let
$T_{\mathrm{coarse}}$ and $T_{\mathrm{fine}}$ be the Kendall tie corrections of
the two profiles. Then*
$$\rho^2 \;=\; \frac{V - T_{\mathrm{coarse}}}{V - T_{\mathrm{fine}}}.$$

Setting $T_{\mathrm{fine}} = 0$ recovers the one-sided law, as it should. And the
coefficient always lands in $[0,1]$, thanks to a small but essential fact: the
map $m \mapsto m^3 - m$ is *superadditive*, so $(a^3-a) + (b^3-b) \le (a+b)^3 -
(a+b)$ for non-negative $a, b$. Splitting a block never increases the tie
correction, so $T_{\mathrm{fine}} \le T_{\mathrm{coarse}}$ always. The
coefficient equals $1$ precisely when the two profiles coincide; any *mismatch*
in granularity attenuates. Holding the statistic fixed, refining the response
drives the coefficient down towards its floor $(V - T_{\mathrm{coarse}})/V$,
the one-sided value; conversely, a coarse variable paired with a much finer one
is penalised for all the ordering detail it cannot track.

Now specialise ruthlessly. The coarsest possible non-trivial response is
*binary*: two classes, $j$ positives and $k$ negatives. Measured against a
tie-free statistic, this is a two-block coarse profile against a singleton fine
profile, and the law evaluates in closed form.

**Theorem (Binary-Response Ceiling).** *A two-class response with $j$ positives
and $k$ negatives, measured against a tie-free statistic, attains exactly*
$$\rho^2 \;=\; \frac{3jk}{(j+k)^2 - 1}.$$

For large samples with base rate $q = j/(j+k)$ this is $\rho^2 \to 3q(1-q)$, i.e.
$$\rho \;\longrightarrow\; \sqrt{3q(1-q)}.$$
The maximum sits at $q = 1/2$, where the exact value is $3j^2/(4j^2 - 1)$ —
always strictly above $3/4$, converging down to it, so that
$$\rho \;\longrightarrow\; \frac{\sqrt{3}}{2} \;=\; 0.8660254\ldots$$

**A binary response can never yield a rank correlation above $\sqrt{3}/2$.** Not
with a perfect statistic, not with infinite data, not ever. That is a hard
ceiling of the geometry of ranks, and it is one of those facts that ought to be
better known: if your outcome variable is a yes/no, your rank correlation is
capped at $0.866$ before you have collected a single data point, and capped much
lower if the classes are unbalanced.

---

## The calibration, and a falsifiable prediction

Now turn the formula around and use it as a measuring device. Our reading was
$\rho = 0.648$, i.e. $\rho^2 = 0.419904$. Solve $3q(1-q) = 0.419904$ for the
minority mass $q$.

The answer is $q \approx 16.83\%$: a two-class response with $1683$ positives per
$10\,000$ observations reproduces the recorded pooled value to within $10^{-4}$
in $\rho^2$. Precise agreement, from a formula that knows nothing about our
experiment.

And the same formula excludes: any two-class response whose minority class holds
at least a quarter of the sample gives $\rho^2 \ge 9/16 = 0.5625$, far above the
recorded $0.419904$. So under the response-granularity reading, the data *forces*
a skewed response.

This is what turns a curiosity into science. We began with a soft observation —
"the dial declines with bit-length" — and ended with a sharp, falsifiable
prediction:

> If the decline is caused by response coarseness, then the 64-bit rate variable
> is effectively a two-class variable with minority mass near $17\%$, and the
> dial can never exceed $\sqrt{3}/2 \approx 0.866$ at any bit-length whatsoever.

Go and inspect the response distribution. If its minority mass is $40\%$, the
explanation dies. If it is near $17\%$, we have found the mechanism.

---

## The verdict on $0.648$, and why it was worth the trouble

A last word on the measurement itself, because it is a small parable about
statistical decision rules.

Our three seeds gave $0.658$, $0.642$, $0.643$; all three cleared the
pre-registered bar of $0.630$ (a baseline of $0.580$ plus a required improvement
of $0.05$). So did the pooled point estimate, $0.648$. But the pre-registration
also demanded that the *lower end* of the confidence interval clear the bar, and
the lower end was $0.629$ — an improvement of $0.049$ over baseline, short of the
required $0.050$ by one part in a thousand.

The verdict recorded was **count parity**: the majority passes, the strict
criterion does not. It is tempting to treat such a near-miss as a failure. It is
better to notice that near-misses of this shape are *structurally bounded*. If
two of three readings clear a bar $\tau$ and the third is at least the band floor
$\ell$, then the pooled mean is at least
$$\tau - \frac{\tau - \ell}{3}.$$
With $\tau = 0.63$ and $\ell = 0.55$, the pooled value could not have fallen
below $0.6033$ — and in fact read $0.648$. A "majority passes, pooled fails"
verdict lives inside a window of width $(\tau-\ell)/3$; it can never be a gross
discordance, only a fine one. Knowing the width of the window is what lets you
call a near-miss a near-miss rather than a scandal.

And the mathematics that this small anomaly provoked is now standing on its own,
independent of the experiment that motivated it: an exact tie-attenuation law, an
exact two-sided version for nested profiles, exact ceilings for dyadic, capped,
and binary structures. Each is a statement about the geometry of rank vectors, and
each is useful anywhere ranks are correlated — in genomics, where expression ranks
meet coarse phenotype classes; in information retrieval, where graded relevance
judgements are correlated against continuous scores; in psychometrics, where
Likert items are ranked against latent traits. In every one of those settings
there is a ceiling, it is computable from the block sizes alone, and it is often
much lower than practitioners assume.

The moral is the oldest one in measurement: before you ask why a number is small,
find out how large it was allowed to be. Sometimes the answer is $0.866$, and
your model was never in trouble at all.
