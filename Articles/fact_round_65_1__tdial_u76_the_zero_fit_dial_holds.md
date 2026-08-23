# The Dial That Wouldn't Move

## How a correlation of 0.608 turned into a piece of arithmetic

### A number that kept showing up

Some experiments produce a number that refuses to go away.

The one at the centre of this story is a rank correlation. On one side sits a
very simple statistic: take a random integer with 76 binary digits and count how
many zeros it ends with. Call that number $T$. Most integers end in no zeros at
all; half of them, in fact. A quarter end in exactly one zero, an eighth in
exactly two, and so on down a geometric ladder that stretches, in principle, all
the way to 76. On the other side sits a downstream quantity the experiment calls
the *rate* — the output of the process being studied.

Line the observations up, rank them by $T$, rank them by the rate, and measure
how well the two orderings agree. That agreement is Spearman's $\rho$. Three
independent runs at 76-bit width returned

$$\rho = 0.593, \qquad \rho = 0.618, \qquad \rho = 0.612,$$

pooling to $\rho = 0.608$ with a confidence interval of $[0.588, 0.631]$. Every
value sat inside the pre-registered validation band $[0.55, 0.85]$, and $T$
outperformed a plain count statistic by $+0.073$, with interval $[0.045,
0.097]$ — a margin that never touches zero.

The striking part is not that the correlation exists. It is that the correlation
*will not move*. At 72 bits it was the same. At 76 bits it is the same. The dial
appears to be flat within noise across the entire measured range. And yet, a
dozen bit-widths earlier, at 64 bits, the same experiment recorded $0.648$. A
drop of $0.04$, and then nothing.

This article is about a very specific question: **can the geometry of ties
explain any of this?** The answer turns out to be a clean and slightly
surprising *no*, and the way that "no" is proved produces a new number — an
*effective base* of about $6.97$ — that reframes the whole measurement.

### Ties: the hidden ceiling on every rank correlation

Here is the first thing to understand about $T$. It is not a continuous
quantity. Among $2^{76}$ possible draws, exactly half give $T = 0$. A quarter
give $T = 1$. An eighth give $T = 2$. The statistic sorts the sample into a
small number of enormous *tie classes*.

Rank correlation hates ties. If half your observations carry identical values of
$T$, then no ranking of the response — none whatsoever — can distinguish them.
There is a hard ceiling on how large $\rho$ can possibly be, set purely by the
shape of the tie classes, before you know anything at all about the response.

That ceiling has an exact formula. Suppose the statistic partitions a sample of
size $n$ into tie classes of sizes $m_1, m_2, \ldots, m_k$. The Kendall tie
correction is

$$T(m_1,\ldots,m_k) \;=\; \frac{1}{12}\sum_{j} (m_j^3 - m_j),$$

and the best squared correlation any response can achieve against a statistic
with that profile is

$$\rho^2_{\max} \;=\; 1 - \frac{\sum_j (m_j^3 - m_j)}{n^3 - n}.$$

Cubes appear because they are what variance of ranks produces: a block of $m$
tied observations destroys $(m^3-m)/12$ of the total rank variance $ (n^3-n)/12$.
The formula says something intuitive — a profile of all singletons gives
$\rho^2_{\max} = 1$, and one giant class gives $0$ — but it says it exactly.

So the first thing to compute is the ceiling for the trailing-zero statistic
itself.

### The $p$-adic ceiling law

It pays to do this in general. Fix a base $p \ge 2$, draw uniformly from
$\{0, 1, \ldots, p^b - 1\}$, and let $T$ be the number of trailing zeros in base
$p$ — the $p$-adic valuation. The tie classes have sizes

$$(p-1)p^{b-1},\quad (p-1)p^{b-2},\quad \ldots,\quad (p-1)p,\quad (p-1),\quad 1,$$

the final singleton being the residue $0$ itself. Summing the cubes and
simplifying — the algebra is a geometric series that collapses beautifully —
gives what we will call the **$p$-adic ceiling law**:

$$\rho^2_{\max}(p,b) \;=\; \frac{3p}{p^2+p+1}\left(1 + \frac{1}{p^b\,(p^b+1)}\right).$$

Two features stand out. First, the whole dependence on the sample size $p^b$ is
packed into a single correction term of size roughly $p^{-2b}$. Second, the
leading factor

$$\pi(p) \;=\; \frac{3p}{p^2+p+1}$$

depends only on the base, and it is *strictly decreasing* in $p$: coarser
valuations (larger $p$) push the ceiling down. At $p = 2$ we get
$\pi(2) = 6/7 \approx 0.857$, so

$$\rho_{\max} \;\ge\; \sqrt{6/7} \;\approx\; 0.926$$

for the trailing-zero statistic at *any* bit-width.

### The flatness theorem, and why it kills a hypothesis

Now put numbers in. At bit-width $b$, the finite-size correction is
$1/(2^b(2^b+1))$. At $b = 72$ that is around $10^{-43.4}$; at $b = 76$, around
$10^{-45.8}$. The difference between the two ceilings is therefore

$$0 \;<\; \rho^2_{\max}(2,72) - \rho^2_{\max}(2,76) \;<\; 10^{-43}.$$

That is the **flatness theorem**, and it is worth pausing on. The observed
flatness of the dial between 72 and 76 bits is not merely *consistent* with tie
geometry — tie geometry *forces* flatness, by a margin some forty orders of
magnitude below any measurement anyone could make. Nothing whatsoever could be
learned from that agreement; the tie mechanism would have predicted it whatever
the data said.

The mirror image of the same computation is more damaging. The recorded drop
from $0.648$ at 64 bits to $0.608$ at 76 bits is $0.04$. The entire change in the
tie ceiling across that range satisfies

$$10^{30}\left(\rho^2_{\max}(2,64) - \rho^2_{\max}(2,76)\right) \;<\; 0.648 - 0.608 .$$

A thousand billion billion billion times too small. Whatever moves the dial with
bit-width, it is not the granularity of $T$.

### Closing the escape routes

A determined defender of the tie hypothesis has two moves left, and both can be
closed.

**Move one: blame the response.** Perhaps the *rate* is the coarse variable —
maybe it, too, takes only a few distinct values, and that is what caps the
correlation. This is a natural thought and it is provably backwards. In the
nested model, where each tie class of $T$ is subdivided by the response into
finer blocks, one can show that the attainable coefficient of the nested
configuration always *dominates* the one-sided coefficient of the coarse
profile. In words: **coarsening the response can only raise the ceiling, never
lower it.** The intuition is that the response's own ties shrink the denominator
of the correlation faster than they shrink the numerator. Consequently, if $T$
has the trailing-zero profile at 76 bits, then no response granularity of any
kind can bring the ceiling below $6/7$ — more than twice the recorded $\rho^2 =
0.608^2 \approx 0.370$.

**Move two: blame some other tie profile entirely.** Forget the specific
arithmetic of trailing zeros; is there *any* tie structure that would produce
$0.608$? Here a single scalar suffices. Let $M$ be the size of the largest tie
class in a sample of size $n$. Then, for every profile whatsoever,

$$\rho^2_{\max} \;\ge\; 1 - \frac{M^2-1}{n^2-1} \;\ge\; 1 - \left(\frac{M}{n}\right)^2 .$$

This is the **dominant-block law**, and it is remarkably economical: one number,
$M$, controls the whole ceiling from below. Two consequences follow immediately.
If no tie class holds more than half the sample, then $\rho^2_{\max} \ge 3/4$,
i.e. $\rho_{\max} \ge 0.866$: *balanced statistics simply cannot be attenuated
much*. And conversely, to push the ceiling down as far as $0.608^2$, a profile
must cram more than $79\%$ of the entire sample into a single tie class.

The trailing-zero statistic puts exactly $50\%$ into its largest class — at
every bit-width, forever. It misses the requirement by a mile. The tie-theoretic
explanation of the dial is not merely unlikely; it is arithmetically impossible.

### The effective base: reading the number backwards

Having established that the trailing-zero statistic's *own* ceiling is $6/7$,
one can ask a different and much more productive question. The ceiling law
assigns to each base $p$ a limiting value $\pi(p) = 3p/(p^2+p+1)$. Which base
would have produced the observed number?

Squaring the extremes of the seed range gives the window $[0.593^2, 0.618^2] =
[0.3517, 0.3819]$. Scanning the bases:

$$\pi(2) = \tfrac{6}{7} \approx 0.857, \quad
\pi(6) = \tfrac{18}{43} \approx 0.419, \quad
\pi(7) = \tfrac{7}{19} \approx 0.3684, \quad
\pi(8) = \tfrac{24}{73} \approx 0.329 .$$

Because $\pi$ is strictly decreasing, this is a complete search: $p = 7$ is the
**unique** integer base whose asymptotic ceiling lands inside the observed
window, and its finite-$b$ value at $b = 76$ lands there too (the correction is
of order $7^{-152}$). Put the other way round: $\sqrt{7/19} = 0.60698\ldots$,
against a measured pooled value of $0.608$. The measurement behaves exactly as a
*7-adic* valuation would — not a 2-adic one.

Is $7$ an artefact of only looking at integers? No. The equation $\pi(x) = r$ is
a quadratic in $x$, and inverting it gives a continuous **effective base**

$$\beta(r) \;=\; \frac{(3-r) + \sqrt{3(1-r)(3+r)}}{2r},$$

which satisfies $3\beta(r)/(\beta(r)^2+\beta(r)+1) = r$ exactly for every $r \in
(0,1)$, exceeds $1$ throughout, and takes the value $\beta(7/19) = 7$ on the nose.
Evaluated at the pooled dial $r = 0.608^2$, it gives

$$6.9 \;<\; \beta(0.608^2) \;<\; 7.05,$$

that is, $\beta \approx 6.97$. The two extreme seeds bracket it in $(6.6, 7.4)$.
The measurement pins the effective base to within about $\pm 0.4$ of $7$ —
without ever having been designed to measure a base at all.

There is a pretty structural fact lurking here. The function $x \mapsto
3x/(x^2+x+1)$ is invariant under $x \mapsto 1/x$: base $p$ and "base" $1/p$ give
identical ceilings. That self-duality is precisely why the inversion is a
quadratic with two roots, and why those two roots multiply to $1$ — the second
root of $\pi(x) = 0.608^2$ is $1/6.97 \approx 0.1435$. An effective base near
$7$ is the same statement as a block-ratio near $1/7$, which is a useful thing to
know if you are hunting for the mechanism.

### The corruption budget

If ties cannot move the dial, something must act on the *ranks themselves* —
some channel that reshuffles observations. How expensive is that?

Work directly with two rank vectors $R$ and $S$ on $n$ observations, each entry
lying in $[1,n]$, and use Spearman in its classical form

$$\rho(R,S) \;=\; 1 - \frac{6\sum_i (R_i - S_i)^2}{n^3-n}.$$

Suppose an adversary — or a physical mechanism — is allowed to alter the
response ranking only on a set $A$ of observations. Each altered coordinate can
change $\sum d^2$ by at most $(n-1)^2$, and the changes are localised to $A$, so

$$|\rho(R,S) - \rho(R,S')| \;\le\; \frac{6|A|(n-1)^2}{n^3-n} \;\le\; \frac{6|A|}{n}.$$

Turn it around and you get a **budget law**: to move the dial by $\delta$, you
must re-rank at least $\delta n / 6$ observations. Applied to the recorded drop
of $0.04$ from 64 to 76 bits, this says at least $n/150$ of the sample — about
$0.67\%$ — must be touched. Not a vanishing handful: a fixed positive fraction,
however large the experiment grows.

The bound is essentially sharp. A single transposition of two observations
changes $\sum d^2$ by exactly $-2(R_i-R_j)(S_i-S_j)$; swapping the two extreme
ranks realises the worst case $2(n-1)^2$, and moves the correlation by exactly

$$\Delta\rho \;=\; \frac{12(n-1)}{n(n+1)} \;=\; \Theta(1/n),$$

matching the Lipschitz rate. So the budget law is not a loose inequality dressed
up as a theorem; it is the right order of magnitude, with the right constant up
to a factor of two.

### What the argument leaves standing

Put the pieces together and a rather clean picture emerges. Three families of
"boring" explanations for the 76-bit measurement have been eliminated by
computation, not by taste:

1. **Granularity of the statistic** cannot do it: the ceiling for trailing zeros
   is $6/7$, and it is flat to $10^{-43}$ across the measured range.
2. **Granularity of the response** cannot do it either, and in fact pushes the
   ceiling the wrong way.
3. **Any tie structure at all** would need a single class holding $79\%$ of the
   sample, whereas the statistic's largest class is exactly $50\%$.

What survives is a rank-level channel, and it now comes with a price tag ($n/150$
re-ranked observations) and a signature (an effective base of $6.97$, equivalently
a block ratio of $1/6.97$). Those two constraints are strong enough to be tested.
The natural next conjecture, suggested by the self-duality above, is that a
Bernoulli($\theta$) rank-corruption channel applied to a genuinely 2-adic statistic
produces an effective base $p(\theta)$ that interpolates continuously from $2$ at
$\theta = 0$; to first order $p(\theta) \approx 2/(1-\theta)^2$, which would place
the observed $6.97$ at a corruption rate of roughly $\theta \approx 0.47$.

There is something appealing about how this went. A measurement produced a
number; the number was interrogated not by more measurement but by asking what
arithmetic could possibly have produced it; and the arithmetic answered with a
sharp, falsifiable constraint. The dial did not move — so we found out exactly
how much force it would take.
