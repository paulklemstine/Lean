# The Arithmetic of Ties: Why Counting Classes Caps a Correlation

## A dial that reads the low bits

Suppose you are handed a machine that produces 56-bit integers, and you suspect that some
hidden process — a solver, a hash, a physical device — leaves a fingerprint in the *low*
bits of its output. A natural probe is the **zero-fit dial**: for each output $x$, record

$$T(x) = \nu_2(x) = \text{the number of trailing zero bits of } x,$$

so $T = 0$ for odd numbers, $T = 1$ for numbers divisible by $2$ but not $4$, and so on.
Then measure how strongly $T$ tracks whatever response variable you care about — a success
rate, a runtime, a difficulty score — using a rank correlation coefficient $\rho$.

This is a cheap, elegant statistic. It is also, by construction, brutally coarse. Among all
$2^{56}$ possible $56$-bit values, exactly half are odd, so half of your sample collapses
into the single value $T=0$. A quarter collapses into $T=1$. In total there are only
$57$ distinct readings the dial can ever produce, and their sizes are wildly lopsided:

$$2^{55},\ 2^{54},\ \dots,\ 2,\ 1,\ 1 .$$

When a statistic takes the *same* value on many observations, those observations are
**tied**: no ranking procedure can tell them apart. Ties are not a nuisance to be corrected
away. They are a hard, geometric limit on how much correlation the statistic can express,
no matter how beautifully the underlying science cooperates. That limit is the subject of
this article, and the punchline is startlingly clean:

> **The ceiling on a tied statistic is governed, to within a vanishing correction, by the
> *number* of tie classes alone — not by their sizes, and not by any clever reweighting of
> the data.**

## The tie-attenuation law

Fix a sample of $n$ observations on which a statistic takes $K$ distinct values, with
$m_1, m_2, \dots, m_K$ observations in each class, so $m_1 + \dots + m_K = n$. Call the
list $L = (m_1,\dots,m_K)$ the **tie profile**. Rank correlation replaces each observation
by its rank, with tied observations receiving the average of the ranks they jointly occupy.
The consequence is a hard cap: even if the response variable is a perfectly monotone
function of the statistic — the best case imaginable — the squared rank correlation cannot
exceed

$$\rho^2_{\max}(L) \;=\; 1 - \frac{\sum_{j=1}^{K} \left(m_j^3 - m_j\right)}{n^3 - n}.$$

This is the classical tie-attenuation law, and it is a purely combinatorial statement: it
depends on the *shape* of the ties and nothing else. We call $\rho^2_{\max}(L)$ the
**ceiling** of the profile.

Everything in what follows flows from noticing that the ceiling is really a statement about
one number, the **cubic moment**

$$C(L) = \sum_{j=1}^{K} m_j^3,$$

since the law can be rewritten as $\rho^2_{\max} = 1 - (C(L) - n)/(n^3 - n)$. A profile is
"good" — permissive, high-ceilinged — exactly when its cubic moment is small relative to
$n^3$.

For the dial at bit-length $b$, the cubic moment can be summed in closed form:

$$C = \left(2^{b-1}\right)^3 + \left(2^{b-2}\right)^3 + \dots + 1^3 + 1^3 = \frac{8^b + 6}{7},$$

a geometric series with ratio $1/8$. With $n = 2^b$ this gives a ceiling of essentially
$1 - 1/7 = 6/7$, so $\rho \le \sqrt{6/7} = 0.92582\ldots$ — a bound that does not improve as
$b$ grows. Half the mass sitting in one class costs the dial a permanent eighth of its
resolving power.

## Buying resolution by reweighting

If a single dominant class is what hurts, can we dilute it? Reweighting is the natural
move: give each observation a multiplicity $w$, so that a class of size $m$ becomes a class
of size $w\,m$. Crucially, this is not a cosmetic relabelling. The mass scales *linearly*
in the weight while the cubic moment scales *cubically*, and the ceiling is a ratio of the
two. Reweighting genuinely moves the ceiling.

The simplest scheme is **stratified**: weight the dominant odd class by $p$ and every deeper
class by $q$. Sending the bit-length to infinity, the resulting ceiling converges to a
remarkably compact expression,

$$\kappa(p,q) \;=\; 1 - \frac{p^3 + q^3/7}{(p+q)^3}.$$

Maximising this over all positive $p, q$ is a one-variable calculus problem in the ratio
$s = q/p$, and its answer is a small surprise:

$$\kappa^\star = \max_{p,q>0} \kappa(p,q) = 1 - \frac{1}{\left(1+\sqrt{7}\right)^2} = 0.9247639\ldots,$$

attained exactly when $q = \sqrt{7}\,p$. The optimal weight ratio is a quadratic
irrational, so **no rational weighting is ever exactly optimal**, though the continued-fraction
convergent $q/p = 37/14$ gets within $10^{-7}$. The whole computation rests on one algebraic
identity, a factorisation of a cubic difference into a perfect square times a positive
linear form:

$$(1+s)^2\left(s^2u^3 + v^3\right) - s^2\left(u+v\right)^3 = \left(v - su\right)^2\left[(1+2s)v + s(2+s)u\right].$$

Because the right-hand side is manifestly nonnegative and vanishes precisely at $v = su$,
the inequality and its equality case both fall out at once. The $\sqrt{7}$ is the geometric
series' ratio in disguise: for a general radix $g$ the same argument yields
$\kappa_g = (g^3-1)/(g-1)^3$ — so $\kappa_2 = 7$, $\kappa_{10} = 111/81$ — with an
optimal ceiling $1 - 1/(1+\sqrt{\kappa_g})^2$. The gain that weighting buys,
$1/\kappa - 1/(1+\sqrt{\kappa})^2$, is always strictly positive and strictly decreasing in
$\kappa$: coarser radices leave more on the table.

On the correlation scale, the whole reweighting budget for the binary dial is

$$\sqrt{\kappa^\star} - \sqrt{6/7} \;=\; 0.9616465\ldots - 0.9258201\ldots \;\in\; (0.0358,\ 0.0359).$$

That is a hard, two-sided cap: careful weighting can add about three and a half correlation
points to a binary trailing-zero dial, and never more.

## Closing the adversarial hole

There are two objections a sceptic will raise, and both are serious.

**Objection one: a limit is not a bound.** The value $\kappa^\star$ is the ceiling in the
bit-length limit. Every *finite* profile enjoys a small discrete bonus — the $-m_j$ terms in
$\sum (m_j^3 - m_j)$ push the finite ceiling slightly *above* the continuum idealisation. In
principle some finite bit-length could break the cap.

The answer is a **continuum sandwich**. For every tie profile with $n \ge 2$ observations,

$$1 - \frac{C(L)}{n^3} \;\le\; \rho^2_{\max}(L) \;\le\; 1 - \frac{C(L)}{n^3} + \frac{1}{n^2}.$$

The exact discrete ceiling and its clean continuum surrogate never differ by more than
$1/n^2$, uniformly over *all* profiles — no assumption on the block sizes at all. Both halves
follow from the two elementary moment inequalities $n \le C(L) \le n^3$ combined with the
comparison of the fractions $\frac{C-n}{n^3-n}$ and $\frac{C}{n^3}$. With $n = 2^b$ the
correction is $4^{-b}$, so at bit-length $56$ the sandwich is tight to about $2\times10^{-34}$:
the $\sqrt{7}$ cap holds at the actual bit-length of the experiment, not merely in the limit.

**Objection two: why only two levels?** A determined designer would not restrict themselves
to a head/tail weighting. Why not choose an arbitrary positive weight for *each* of the $57$
classes independently?

This is where the story becomes clean, and it is the main result of this work. Consider any
profile of $K$ blocks with total mass $n$. A power-mean (Chebyshev–Hölder) inequality says
the cubic moment cannot be small:

$$n^3 \;\le\; K^2 \sum_{j=1}^{K} m_j^3, \qquad\text{with equality exactly for the flat profile } m_1 = \dots = m_K.$$

Feeding this into the sandwich gives a bound that no longer mentions the block sizes at all:

$$\boxed{\ \rho^2_{\max}(L) \;\le\; 1 - \frac{1}{K^2} + \frac{1}{n^2}\ }$$

for every profile of $K$ classes and mass $n \ge 2$. And it is sharp: the flat profile of
$K$ blocks of size $m$ has ceiling at least $1 - 1/K^2$ and at most $1 - 1/K^2 + 1/n^2$, so
the constant cannot be improved.

The consequence for the dial is immediate and total. **Weighting redistributes mass among
the tie classes but never creates a new one.** A weighted bit-length-$b$ dial still has
exactly $b+1$ classes. So for *any* weight vector whatsoever — arbitrary, adversarial,
tuned with full knowledge of the response —

$$\rho^2_{\max} \;\le\; 1 - \frac{1}{(b+1)^2} + \frac{1}{n^2},$$

and at $b = 56$,

$$\rho^2_{\max} \;\le\; 1 - \frac{1}{3249} + 2^{-112}, \qquad \rho \le 0.9998461\ldots$$

The bound also identifies the optimiser: the *equalising* weighting, which gives the class
of numbers with exactly $k$ trailing zeros the weight $2^k$, flattens all $b+1$ classes to
equal size and therefore attains the cap to within $1/n^2$. No weight vector can beat it by
more than that vanishing amount.

Notice the elegant reversal. The power-mean bound and the $\sqrt{7}$ bound are proved by
the *same* cubic factorisation — the inductive step for $n^3 \le K^2 C(L)$ is exactly the
identity displayed above with $s = K$, $u = m$, $v = \sum_{j>1} m_j$. One algebraic fact,
two very different theorems: a *sharp* cap of $0.9616$ for stratified weightings, and a
*universal* cap of $0.9998$ for arbitrary ones. The gap between them is precisely the price
of the extra design freedom.

## What this says about a real experiment

The mathematics above was developed to adjudicate a concrete empirical question. A
fresh-seed replication measured the zero-fit dial at bit-length $56$ across three
independent seeds. The primary hypothesis — that the dial correlates with the response
inside a pre-registered validation band $[0.55, 0.85]$ — held comfortably: the pooled
reading was

$$\rho(T, \text{rate}) = 0.669, \qquad \text{95\% CI } [0.650,\ 0.690],$$

with all three seeds passing. The secondary hypothesis was that the trailing-zero statistic
beats a plain popcount baseline by more than $+0.05$. It failed: the pooled advantage was
$+0.045$, only one of three seeds cleared the bar, and the verdict on the record reads
*"the weighted edge is not established at bit-length 56."*

The natural worry is that the failure is an artefact — that the dial is simply saturated,
its ties so coarse that no protocol could have produced a bigger advantage. The results here
refute that worry quantitatively, and in two independent registers.

- Under the *sharp* cap for stratified weightings, the whole reweighting budget is
  $0.0358$ to $0.0359$ on the $\rho$ scale. That is more than **seven times** the recorded
  $0.005$ shortfall. Weighting was never the binding constraint; there was ample room.
- Under the *universal* cap for arbitrary weightings, the dial can in principle read as high
  as $0.99984$. The recorded $0.669$ leaves roughly $0.29$ of correlation headroom even
  against the far more conservative $\sqrt{\kappa^\star} = 0.96165$ — nearly sixty times the
  missing margin.

So the shortfall is a fact about the **response variable**, not about the geometry of the
dial. Count parity in this batch is not evidence that the statistic is saturated; the
statistic's own ceiling is nowhere near being touched. That is the kind of statement one
wants after a negative result: not merely "we failed to detect an effect," but "here is a
theorem that says the measuring instrument had seven times the dynamic range it needed."

## The moral

Ties are usually treated as bookkeeping — a correction term in a formula. Taken seriously,
they are a resource-accounting problem: a statistic has a fixed budget of distinguishability
set by how many distinct values it can emit, and no amount of post-hoc reweighting creates
distinctions that were never there. The block-count cap makes that intuition exact,

$$\rho^2_{\max} \le 1 - \frac{1}{K^2} + \frac{1}{n^2},$$

and the sharpness result says the accounting is honest in both directions. If you want a
higher ceiling, you must add classes — refine the statistic — not reshuffle the mass among
the classes you already have. That is a design principle for anyone building a coarse probe
into a fine-grained phenomenon, and it comes with a number attached.
