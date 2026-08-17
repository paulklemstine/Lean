# Why the Middle Number Wins

## The strange authority of the median

Suppose you run the same experiment three times, changing only the random number that
initializes it, and you get three answers: $160$, $224$, $256$. What do you report?

Almost everyone reaches for the middle one. It is such a reflex that we rarely ask what
entitles us to it. The average would be $213.3$, which is not any of the answers. The largest,
$256$, is the safe one if you need a guarantee. The smallest is the one you would quote if you
were selling something. The middle value, $224$, feels *honest* — but "feels honest" is not a
theorem.

This article is about the moment where it becomes one. It turns out that the middle reading of
an odd-sized ensemble of runs is singled out **twice over**, by two arguments that have nothing
obvious to do with each other:

* a **probabilistic** argument, about what a reading means when your runs are coin flips; and
* a **combinatorial** argument, about how many of your runs an adversary would have to sabotage
  before your reading becomes worthless.

Each argument, on its own, picks out exactly one reading from the list. And the two arguments
pick out the *same* one. The main theorem below says this is not a coincidence but an
equivalence: **a reading is unbiased on coin-flip runs if and only if it is maximally robust to
sabotage.** Calibration and robustness are the same constraint wearing different clothes.

The setting where this was discovered is concrete and slightly surprising: measuring how much
of a language model's attention you can throw away before it degrades.

## The measurement that started it

Modern sequence models compute, for every position in a text, a weighted blend of every earlier
position. If the text has $L$ tokens, that is on the order of $L^2$ interactions — the reason
long context is expensive. A natural question: at each position, if you keep only the $k$
largest attention weights and discard the rest, how small can $k$ be before the model's
predictions actually get worse?

Call the smallest such $k$ the **knee**. Below the knee the model degrades; above it, nothing
much happens. The knee is the number an engineer wants, because it is the compression factor
you can safely deploy.

Here is the awkward part. Train the same model twice, changing only the random seed, and you get
two different knees. At a context length of $2048$ and width parameter $d = 4$, three seeds gave
knees of $256$, $224$, and $160$: a spread of $60\%$ between the smallest and largest. A knee is
not a property of the architecture; it is a random variable, and a noisy one.

And yet something in that noise is stable. Write $P = d \cdot L / 32$ for the natural scale of
the problem — with $d = 4$ and $L = 2048$ this is $P = 256$. Then the three knees are
$P$, $\tfrac{7}{8}P$, and $\tfrac{5}{8}P$, and their **median is exactly $\tfrac{7}{8}P = 224$**.
At half the context, $L = 1024$ and $P = 128$, three other seeds had given knees
$\{96, 112, 128\} = \{\tfrac{3}{4}P, \tfrac{7}{8}P, P\}$ — median again exactly $\tfrac{7}{8}P = 112$.

Four sharp predictions had been written down in advance for the third seed at the long context —
$224$, $240$, $256$, $192$ — and the measurement, $160$, refuted all four. But the prediction
about the *center of the distribution* survived intact. This is the pattern worth taking
seriously: individual runs are unpredictable, the center of the ensemble is not. Notice too that
the spread widened with context — from $\{0.75, 0.875, 1.0\}$ times $P$ to
$\{0.625, 0.875, 1.0\}$ — with the growth all in the low tail, while the upper edge stayed pinned
at $P$ and the middle stayed pinned at $\tfrac{7}{8}P$.

Which raises the question the rest of this article answers. If the center is the quantity you
report, *which* center, and why that one?

## Ladders, not lists

Start by describing a set of seed results in a way a machine — or a careful accountant — would.

Give each seed $i$ its knee $K(i)$: the least budget at which that seed's model clears the
accuracy bar. Now for each quota $m$ between $1$ and $n$, define
$$Q(m) \;=\; \text{the least budget } b \text{ such that at least } m \text{ of the } n \text{ seeds clear the bar at } b .$$
This is the **quota ladder**. Its rungs are exactly the sorted knees: $Q(1)$ is the smallest knee
(the lucky seed), $Q(n)$ is the largest (the budget that works for everybody), and for odd
$n = 2r+1$ the rung $Q(r+1)$ is the median.

Reading the ladder at $m = n$ gives you a **guarantee**: "this budget suffices for all seeds."
Reading it at $m = 1$ gives you a **best case**. Reading at the middle gives you the *typical*
case. Every reporting convention in the empirical literature — worst case, best case, median,
"$k$ out of $n$" — is a choice of rung. The question "which center?" is now precise: which $m$?

## The first argument: calibration

Fix a budget and ask, for a single seed, whether it clears the bar there. Model that as a coin
with bias $p$: the seed clears with probability $p$, independently of the other seeds. Then the
$m$-th rung sits at or below the budget exactly when at least $m$ seeds clear, so the
probability that rung $m$ reads "yes" is the binomial upper tail
$$R_n(m,p) \;=\; \sum_{j \ge m} \binom{n}{j} p^{\,j}(1-p)^{\,n-j}.$$
This function is the rung's *distribution function*, and it obeys the expected structure: it
decreases as you raise the quota $m$, increases in $p$, and satisfies the Pascal recursion
$R_{n+1}(m+1,p) = p\,R_n(m,p) + (1-p)\,R_n(m+1,p)$ obtained by conditioning on the last seed.
Raising the quota by one costs exactly one binomial term:
$R_n(m,p) - R_n(m+1,p) = \binom{n}{m}p^m(1-p)^{n-m}$.

Now call a rung **calibrated** if, when the seeds are fair coins ($p = 1/2$), the rung reads
"yes" with probability exactly $1/2$. A calibrated rung is one that does not lean: on a
maximally uninformative ensemble it reports "pass" and "fail" with equal frequency, so any
asymmetry you see in its output came from the data and not from the reporting convention.

At $p = 1/2$ the tail collapses to counting: $R_n(m,1/2) = T(n,m)/2^n$ where
$T(n,m) = \sum_{j\ge m}\binom{n}{j}$. The binomial coefficients are symmetric, which gives the
reflection identity
$$T(n,m) + T(n,\,n+1-m) \;=\; 2^{\,n},$$
and $T(n,\cdot)$ is strictly decreasing on the meaningful range. Put those together and you get
the **parity law of calibration**:
$$R_n(m,\tfrac12) = \tfrac12 \quad\Longleftrightarrow\quad 2m = n+1 .$$
So an ensemble has a calibrated rung **if and only if its size is odd**, and then that rung is
unique: the median. An even ensemble has none at all. This is not a near miss that shrinks away;
it is an exact impossibility at every even size.

You can measure the failure. For $n = 2r$ the two central rungs read
$$R_{2r}(r,\tfrac12) = \tfrac12 + \delta_r, \qquad R_{2r}(r+1,\tfrac12) = \tfrac12 - \delta_r,
\qquad \delta_r = \frac{1}{2^{2r+1}}\binom{2r}{r} .$$
The defect $\delta_r$ is strictly positive, strictly decreasing, and tends to $0$ — but only at
the leisurely rate $r^{-1/2}$. Precisely,
$$\frac{1}{2\sqrt{4r+1}} \;\le\; \delta_r \;\le\; \frac{1}{2\sqrt{3r+1}},
\qquad \delta_r\sqrt{r} \longrightarrow \frac{1}{2\sqrt{\pi}} = 0.28209\ldots$$
The upper and lower brackets are exactly the statement $3 \le \pi \le 5$, read off an ensemble
ladder instead of a circle. The defects are so far from small that $\sum_r \delta_r$ diverges.

There is a consolation prize, and it explains a convention everybody already uses: the two
central rungs of an even ensemble *average* to exactly $1/2$. That is precisely the textbook rule
"the median of an even sample is the mean of the two middle values." The rule is not an
arbitrary tie-break; it is the unique repair of a parity defect.

## The second argument: sabotage

Now forget probability. Someone hands you $n$ seed results, and you are told that up to $c$ of
them are corrupted — a run that silently diverged, a logging bug, a machine that thermally
throttled. You do not know which. You still want to read a rung.

The key estimate is a two-sided bracket. If two knee assignments $K$ and $K'$ agree outside a set
$S$ of at most $c$ seeds, then the corrupted reading of rung $m$ is trapped between two *clean*
rungs:
$$Q_K(m-c) \;\le\; Q_{K'}(m) \;\le\; Q_K(m+c).$$
Corrupting $c$ seeds can move a rung by at most $c$ rungs, in either direction. So as long as
$m - c \ge 1$ and $m + c \le n$, the sabotaged reading is still somewhere inside the honest
ensemble's own range — it may be wrong, but it is not *alien*.

Both halves of that condition are sharp, and here is where the theory gets its teeth.

* **Upward breakdown.** With $n - m + 1$ corrupted seeds you can push rung $m$ above *any*
  prescribed value $B$. Set every corrupted knee to $B$; then fewer than $m$ clean seeds remain,
  so the quota cannot be filled below $B$. The reading is unbounded — infinitely biased.
* **Downward breakdown.** With $m$ corrupted seeds you can collapse rung $m$ to $0$: set those
  $m$ knees to zero and the quota is met at budget zero.

Therefore the number of corrupted seeds a rung tolerates — its **breakdown number** — is exactly
$$\beta(n,m) \;=\; \min(m-1,\; n-m).$$
This is a clean, complete answer: not an estimate, a formula. And it immediately grades the
usual reporting conventions. The guarantee rung $m=n$ has $\beta = 0$: a single bad seed destroys
it, without bound. The best-case rung $m=1$ has $\beta = 0$ too. In a three-seed ensemble, the
median is the *only* rung that survives a single corrupted run at all.

Between "tolerable" and "destroyed" there is no gray zone, either: at any contamination level
below breakdown, the set of readings an adversary can force is *exactly* the clean interval
$[Q(m-c),\, Q(m+c)]$, with both endpoints attained. So the maximal bias equals the clean spread,
and the breakdown number is precisely the level at which that spread stops being finite.

## The two arguments meet

Look at the two answers side by side. For an odd ensemble $n = 2r+1$:

* the unique **calibrated** rung is $m = r+1$;
* the unique rung with **maximal breakdown number** is $m = r+1$, since
  $\beta(2r+1, m) = \min(m-1, 2r+1-m) \le r$ with equality only at the center.

That is the theorem, stated as an equivalence:

> **The Calibration–Robustness Dichotomy.** In an ensemble of $n = 2r+1$ seeds, a rung
> $1 \le m \le n$ satisfies $R_n(m,1/2) = 1/2$ if and only if $\beta(n,m) = r$.

A parity identity on binomial tails, and a counting bound on how many seeds an adversary must
buy, single out the same index. "Report the median" is therefore not a convention chosen for
convenience: it is the unique reading that is simultaneously unbiased on uninformative data and
maximally hard to sabotage.

The dichotomy has a mirror image, and the mirror is just as informative. For an even ensemble
$n = 2r$, both properties fail *together*: no rung is calibrated, and the maximal breakdown
number $r-1$ is attained by **two** rungs, the two central ones. Parity is a single obstruction
to a canonical center, and it shows up on the probabilistic side and the robustness side at
once. An even ensemble has no center in either sense.

## What this says about the fourth seed

Return to the measurement. Three seeds gave $\{160, 224, 256\}$; the median is $224$, exactly
$\tfrac78 P$; the natural next move is to run a fourth seed.

The theory has an unwelcome verdict about that plan. A fourth seed:

* does **not** improve robustness. Both central rungs of a four-seed ensemble have breakdown
  number $1$ — the same as the three-seed median. You pay four hours of training for zero extra
  tolerance to a bad run.
* does **not** restore calibration. No rung of a four-seed ensemble is calibrated; the central
  defect is $\delta_2 = \binom{4}{2}/2^5 = 3/16$, so the two central rungs read $0.6875$ and
  $0.3125$ instead of $0.5$.
* **can** confirm the law, and only in one way. Averaging the two middle values of
  $\{160, 224, 256, x\}$, the four-seed reading is $192$ for $x \le 160$, $(x+224)/2$ for
  $160 \le x \le 224$, $(224+x)/2$ for $224 \le x \le 256$, and $240$ for $x \ge 256$. It equals
  the three-seed median $224$ **exactly when $x = 224$** and is strictly worse otherwise, with a
  bias that never exceeds $32$ and is at most $16$ as soon as $x \ge 192$.

A fifth seed, by contrast, does both: breakdown number $2$, strictly better than the third
seed's $1$, and the median rung is calibrated again. If you can afford one more run, you cannot
afford one more run — you need two.

## How many runs would actually settle it?

There is a third question the same framework answers: not "which rung?" but "how many seeds
until the rung is *certain*?"

If each seed clears the bar with probability $p > 1/2$, the median rung is an instance of
Condorcet's jury theorem: it converges to certainty as the ensemble grows, and the ladder is
monotone — every extra pair of seeds helps, strictly. The miss probability obeys
$$1 - R_{2r+1}(r+1,p) \;\le\; 2(1-p)\bigl(4p(1-p)\bigr)^{r},$$
a geometric rate, since $4p(1-p) < 1$ whenever $p \ne 1/2$. Sharpening the same argument by
keeping the exact binomial term rather than bounding it gives
$$1 - R_{2r+1}(r+1,p) \;\le\; \frac{\binom{2r+1}{r}\,\bigl(p(1-p)\bigr)^{r+1}}{2p-1},$$
and feeding in the central binomial sandwich turns this into an explicit Stirling-type bound
with an extra $1/\sqrt{3r+4}$.

At the measured per-seed frequency $p = 2/3$, the crude rate needs $73$ seeds to certify the
median to within $1\%$; the sharpened rate needs $49$; the truth crosses $1\%$ at exactly $47$.
And there is a small, honest negative result attached: no bound that dominates the sharpened
rate can certify at $47$, because the sharpened rate itself still exceeds $1/100$ there. The
gap between $47$ and $49$ is not an artifact of sloppiness — it is the price of that particular
route.

Meanwhile the actual three-seed ensemble, evaluated in its own frequency model, has median-rung
miss probability $1 - R_3(2, 2/3) = 7/27 \approx 26\%$. The center measured in the experiment is
a point estimate with a one-in-four chance of being on the wrong side — not a certified center.
That is the sharpest honest limit on the empirical claim, and it comes from the same theory that
justifies reading the median in the first place.

## Is the median also the *narrowest* reading?

One more natural conjecture, because it is instructive that it is false. Since the achievable
readings under $c$ corruptions form the interval $[Q(m-c), Q(m+c)]$, the *width* of that
interval is the deployment-relevant uncertainty. Is the median always the narrowest?

No. The five-seed sample $\{0,0,0,10,20\}$ — three seeds agreeing and two stragglers — has a
median window strictly wider than an off-center one. The minimizer of the width follows the
sample's *gaps*, not its center.

But it is true under exactly the hypothesis that a well-behaved experiment is supposed to
supply. Call a ladder **center-minimal** if gaps closer to the middle are smaller, which is what
the order statistics of a unimodal law do. Under center-minimality, the median window is
narrowest among all rungs, at every radius. The proof is a two-sided induction along the ladder
driven by an exact criterion: moving a window outward widens it exactly when the gap it takes in
exceeds the gap it lets out.

And the measured sample? Its gaps are $64$ and $32$ — equidistant from the center of a
three-rung ladder and unequal — so center-minimality holds only vacuously, and the mechanism has
no content at three seeds. At the measured cell, the median's robustness is not explained by
narrowness. It is explained by the breakdown number: with three seeds, the median is the only
rung that has a contamination window at all.

## The moral

The result that survives here is not any of the four sharp predictions about a single run. Every
one of them was refuted. What survived is a statement about the *shape of the distribution* of
runs — its center sits at $\tfrac78$ of the natural scale — and that survival is exactly what the
theory says to expect: per-run readings are noisy, the center is the robust functional, and the
center is robust for two reasons that turn out to be one reason.

There is a broader lesson for anyone who reports numbers from stochastic experiments. The choice
between "worst case," "best case," and "typical" is not a matter of taste. It is a choice of rung
on a ladder, each rung comes with a breakdown number $\min(m-1, n-m)$ and a calibration status,
and those two attributes are locked together by parity. Guarantees are maximally fragile.
Best cases are maximally fragile. The median of an odd ensemble is the unique fixed point of
both notions of "does not lean." Even ensembles have no center; averaging the two middle values
is not a convention but the exact repair of a measurable parity defect.

The next time someone reports the middle of three runs, they are on firmer ground than they know
— and if they report the middle of four, they are on ground the theory says does not exist.
