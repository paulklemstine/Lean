# The Dial That Wouldn't Move: Why Small Primes Carry the Signal

## A knob with a mysterious sweet spot

Suppose you are handed a large odd number $N$ and asked to say something about it
without factoring it. One of the oldest tricks in number theory is to *interrogate
it modulo small primes*. For each small prime $\ell$, you ask a single yes/no
question:

> Is $N$ a perfect square modulo $\ell$?

That is, does the congruence $x^2 \equiv N \pmod{\ell}$ have a solution? The
answer is a single bit. Collect the bits for all primes $\ell$ up to some cutoff
$B$ and you have a *fingerprint* of $N$: a long string of yes/no answers,
computable in a flash, that encodes a surprising amount of arithmetic
information. Number theorists call the "yes" primes the **quadratic residue
primes** of $N$, and the collected bits a **dial**.

The obvious way to turn that string of bits into a single number — a *dial
reading* you can correlate against anything else you care about — is to count the
yeses:

$$C(B) \;=\; \#\{\ell \le B \;:\; N \text{ is a square mod } \ell\}.$$

And here a genuine puzzle appears. In an extended empirical study of this
covariate against an arithmetic target, the count dial explained about $32\%$ of
the variance when the cutoff was $B = 400$ — a strong, unmistakable signal. Then
the cutoff was pushed out. At $B = 4000$ the explained variance collapsed to
$2.4\%$. At $B = 4\cdot 10^4$: $1.5\%$. At $B = 10^5$: *zero*, to four decimal
places. At $B = 10^6$: a wobbling $2.8\%$.

More data made the signal *worse*. A thousand times more information, and the
correlation evaporated.

The natural first hypothesis — call it the **scale-shift hypothesis** — is that
the informative window simply *moves*: that at cutoff $10^6$ the useful primes
are no longer the small ones but some band further out, and one merely has to
look in the right place. This is the hypothesis a careful experimentalist
registers in advance, precisely so as not to be able to explain away a negative
result afterwards. It was registered. And it was refuted: none of the candidate
shifted windows recovered the signal. The window at $400$ was not in the wrong
place. It was in the *right* place, and everything beyond it was noise being
poured into the average.

This article is about the theorem that explains why — and about the repair,
which turns out to be a single reweighting so simple you could write it on a
napkin.

## Weighing the primes

The count dial gives every prime an equal vote. The prime $3$ counts exactly as
much as the prime $999{,}983$. But those two primes are not equally informative,
and the reason is a fact about density.

Whether $N$ is a square modulo $\ell$ is, from the point of view of a random $N$,
a coin flip. But when we ask how much a prime's residue status shifts a
*multiplicative* quantity attached to $N$ — how much of the target's structure
lives at that prime — the contribution scales like $1/\ell$. Small primes are
common divisors, common congruence obstructions, common everything. Their
influence is heavy. Large primes each nudge the answer by an amount of order
$1/\ell$, which for $\ell \approx 10^6$ is a millionth of a nudge.

So the natural dial is not a count but a **harmonic sum**:

$$W(B) \;=\; \sum_{\substack{\ell \le B \\ N \text{ a square mod } \ell}} \frac{1}{\ell}.$$

Each prime votes with weight $1/\ell$: the informative small primes shout, the
uninformative large ones whisper.

The empirical effect is dramatic, and it is dramatic in the *opposite direction*
from the count dial. At $B = 400$ the weighted dial explains $47.3\%$ of the
variance. At $B = 10^6$ — a cutoff two and a half thousand times larger — it
explains $47.9\%$. It barely moved. And the two covariates, computed at cutoffs
$400$ and $10^6$, correlate with each other at $0.999$.

In other words: once you weight harmonically, **all the signal is already there
by $400$**, and pushing the cutoff to a million adds essentially nothing —
neither signal nor noise. The count dial *dilutes*; the weighted dial
*saturates*.

## The theorem behind the table

That two-sided behaviour is not a quirk of this population of numbers. It is a
theorem about linear covariates, and here it is.

Model the target as a superposition of independent per-prime contributions:
$$s \;=\; \sum_{i \in S} a_i \, e_i,$$
where the $e_i$ are orthonormal unit vectors (independent directions, one per
prime in the population $S$) and $a_i$ is the *amplitude* of the $i$-th prime —
how much of the target that prime carries. A **window** is a subset $T \subseteq S$
of primes we are allowed to look at, and a *dial* is any linear combination
$u = \sum_{i \in T} c_i e_i$ of the visible directions. The quality of the dial is
its squared correlation with the target,
$$R^2(u,s) \;=\; \frac{\langle u, s\rangle^2}{\|u\|^2\,\|s\|^2}
\;=\; \frac{\bigl(\sum_{i \in T} c_i a_i\bigr)^2}{\bigl(\sum_{i\in T} c_i^2\bigr)\bigl(\sum_{i\in S} a_i^2\bigr)}.$$
The two dials of the experiment are the two obvious choices of coefficients:
$c_i = 1$ for the count dial, $c_i = a_i$ for the weighted dial. They give

$$R^2_{\mathrm{count}} = \frac{\bigl(\sum_{i \in T} a_i\bigr)^2}{|T|\,\sum_{i \in S} a_i^2},
\qquad
R^2_{\mathrm{weighted}} = \frac{\sum_{i \in T} a_i^2}{\sum_{i \in S} a_i^2}.$$

**First theorem: the weighted dial always wins.** For every window,
$R^2_{\mathrm{count}} \le R^2_{\mathrm{weighted}}$. This is nothing but the
Cauchy–Schwarz inequality $\bigl(\sum_T a_i\bigr)^2 \le |T| \sum_T a_i^2$. The
measured pair $0.3207 \le 0.4731$ at $B = 400$ is an instance.

**Second theorem: the loss is exactly a flatness factor.** Define the *flatness*
of the amplitude profile on the window,
$$\mathrm{flat}(T) \;=\; \frac{\bigl(\sum_{i \in T} a_i\bigr)^2}{|T|\, \sum_{i\in T} a_i^2} \;\in\; (0,1],$$
which equals $1$ precisely when all the amplitudes on the window are equal. Then
$$R^2_{\mathrm{count}} \;=\; \mathrm{flat}(T)\cdot R^2_{\mathrm{weighted}},$$
exactly, with no error term. And the defect has a closed form: Lagrange's
identity gives
$$|T|\sum_{i \in T} a_i^2 - \Bigl(\sum_{i \in T} a_i\Bigr)^2 \;=\; \tfrac12 \sum_{i \in T}\sum_{j\in T} (a_i - a_j)^2,$$
so the flatness is strictly less than $1$ as soon as two amplitudes on the
window differ. A $1/\ell$ profile across primes from $3$ to $10^6$ is about as
un-flat as a profile can be, which is exactly why equal weighting is so costly.

**Third theorem: saturation.** Now put in the arithmetic. With amplitudes
$a_i \asymp 1/i$ — the harmonic profile the arithmetic dictates — the window
consisting of the first $n$ primes satisfies
$$1 - \frac{1}{n} \;\le\; R^2_{\mathrm{weighted}} \;\le\; 1 - \frac{1}{8n},$$
the upper bound holding as soon as the ambient population is at least twice the
window. Read that carefully: the lower bound is *uniform in the ambient
population*. A window of $400$ captures at least $99.75\%$ of everything the
entire infinite population could ever explain, whether the ambient cutoff is
$400$ or $10^6$ or $10^{100}$. The two-sided estimate pins the saturation rate at
exactly order $1/n$. The window size is a *tolerance* parameter, not a *scale*
parameter — a statement about how much precision you want, never about how big
your numbers are.

**Fourth theorem: dilution.** The same amplitudes make the equal-weight count
dial satisfy
$$R^2_{\mathrm{count}} \;\le\; \frac{(1 + \log n)^2}{n},$$
because the numerator only grows like the harmonic number $H_n \le 1 + \log n$
while the denominator's normaliser grows like $n$. This tends to zero. The count
dial doesn't merely stop improving — it *degrades to nothing*, and it does so at
the rate the sweep shows.

Putting the last two together gives the whole phenomenon in one sentence: **for
every tolerance $\varepsilon > 0$ there is a window size beyond which the
harmonically weighted dial explains at least $1 - \varepsilon$ of the explainable
variance while the equal-weight count dial explains at most $\varepsilon$ of
it.** Same primes, same bits, same information — opposite conclusions, decided
entirely by the weights.

## Why the sweet spot is real

There is a last piece of the refutation. Could the count dial's optimum still be
"out there", at some enormous window nobody has looked at? No. Strip away the
ambient normaliser and the count dial's score at window size $n$ is
$H_n^2 / n$, where $H_n = 1 + \tfrac12 + \cdots + \tfrac1n$. Since
$H_n \le 1 + \log n$, this score tends to $0$; and a function on the positive
integers that tends to $0$ and is positive somewhere attains a *global maximum at
a finite argument*. So there is a genuine best window $B^\ast$, and no larger
window can ever beat it. The scale shift is impossible, not merely unobserved.
The verdict is that the window is **stronger, not shifted** — and the empirically
located $B^\ast = 400$ stands, scale-independently.

The contrast with the weighted dial is total: there, a larger window is *never*
worse (the explained variance is monotone in the window and capped at $1$), so
the question "where is the optimal window?" has the boring answer "everything",
and the interesting content is entirely the *rate* at which small windows
approach it.

## An erratum written by the law of quadratic reciprocity

The same investigation delivered a second, more sobering result — a correction to
an earlier round of conclusions, and it is a lovely illustration of how a
two-hundred-year-old theorem can invalidate a modern regression.

There are two natural ways to implement the dial bit. You can ask "is $N$ a
square mod $\ell$?", writing the symbol with the **prime on the bottom**; or you
can compute the reciprocal symbol, with the **composite $N$ on the bottom**. For
most purposes these look interchangeable, and one earlier study used the second
form. Its dials came out weak, and the weakness was reported as a genuine finding
about the arithmetic.

It was not. Quadratic reciprocity says that the two symbols agree *except* when
both $\ell$ and $N$ are congruent to $3 \bmod 4$, in which case they are exact
negatives. Precisely: the two forms differ by the twist
$$\tau(\ell, N) = \begin{cases} -1 & \text{if } \ell \equiv 3 \text{ and } N \equiv 3 \pmod 4,\\ +1 & \text{otherwise,}\end{cases}$$
which is the classical reciprocity sign $(-1)^{\lfloor \ell/2\rfloor\lfloor N/2\rfloor}$
on odd arguments. This is a sharp dichotomy: *on* the condition the flip is
total — every single row flips, with no exceptions — and *off* the condition the
two forms agree identically. The empirical audit found exactly this: a
conditional flip rate of $100\%$ across all $2680$ qualifying rows, zero
violations, and an unconditional rate of $27.19\%$ matching the predicted density
to two decimal places on a population where the condition held for $52.3\%$ of
the numbers.

Now, $\tau = \pm 1$ is an involution: multiplying by it destroys no information
whatsoever. You can always undo it. But it can destroy *linear* signal utterly,
and that is the whole point. Here is the smallest possible illustration. Take
four data rows with targets $(+1, +1, -1, -1)$ and a clean dial that matches the
target perfectly, so its covariance with the target is $4$ — a perfect
correlation. Apply a twist pattern $(+1, -1, +1, -1)$, which is exactly what the
$3 \bmod 4$ condition does on a balanced population. The flipped dial now has
covariance **zero** with the target. The information is all still there, sitting
in the sign pattern; a linear model simply cannot see it.

That is the diagnosis, and it converts the earlier "weak dial" finding into an
erratum: the weakness was a property of the *form* of the dial, not of the
arithmetic. The clean prime-bottom dial on the same population is strong
($34.5\%$ explained variance), while both the flipped forms are weak
($4.1\%$ and $5.5\%$) — as the twist predicts. The mechanism even localises
itself: on a window made only of primes $\ell \equiv 1 \pmod 4$ the two forms are
*literally the same covariate*, so the entire artifact is carried by the
$3 \bmod 4$ half of the window, and only for $N \equiv 3 \pmod 4$. Where the
condition does bite, the two dials are not merely different but *complementary*:
one records a residue exactly when the other does not.

Not everything was retracted. The earlier study's *primary* conclusion was a null
result about a different, individual-factor dial, and that null replicated
cleanly here ($0.19\%$ explained variance, well within noise). The twist
mechanism does not even apply to it. A null that survives an attempt to explain
it away is a stronger null than it was before.

## What the dial is actually looking at

One more piece of arithmetic explains what these covariates can and cannot see.
When $N = pq$ is a product of two primes, the residue bit of $N$ at $\ell$ is the
**exclusive-or** of the bits of $p$ and $q$: $pq$ is a square mod $\ell$ exactly
when $p$ and $q$ have the *same* residue status. The product dial therefore reads
a parity, never the factors themselves. Two semiprimes — one where both factors
are residues at every prime of the window, one where both are non-residues — have
*identical* dials, at every window, with every weighting. And a perfect square
$m^2$ maximises the dial: it is a residue at every prime coprime to it, so its
weighted reading is the full harmonic weight of the window. These are hard
limits: no amount of reweighting can make a covariate distinguish configurations
it provably identifies.

## The moral

Three lessons, each with a life beyond this particular arithmetic.

**More data is not more signal if you average it wrong.** The count dial had
strictly more information at $B=10^6$ than at $B=400$ — it contained the smaller
dial's bits verbatim. It performed worse anyway, because equal weighting buries a
handful of loud voices under a million quiet ones. The relevant quantity is not
how many observations you have but how flat your weight profile is against the
true amplitude profile, and the flatness factorisation
$R^2_{\mathrm{count}} = \mathrm{flat}(T)\cdot R^2_{\mathrm{weighted}}$ measures
exactly that loss.

**A negative result can be an artifact of coordinates.** Multiplying a covariate
by a $\pm1$ pattern loses nothing and can zero out a perfect correlation. When a
regression reports "no signal", the honest next question is whether some known
symmetry of the data has scrambled the signal into a direction the model cannot
represent. Here the symmetry was quadratic reciprocity, sitting in plain sight.

**And a sweet spot can be a theorem.** "The signal lives at $B = 400$" sounds
like a fact about one dataset, the kind of thing that evaporates when someone
changes the population. It is not. It is the statement that a certain positive
score tending to zero attains its maximum at a finite argument, and that a certain
harmonic tail is $O(1/n)$ — facts that hold at every scale, for every population.
The dial did not need to move. It needed to be weighed.
