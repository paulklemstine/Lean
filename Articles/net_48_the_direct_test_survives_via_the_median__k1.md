# The Middle Seed: Why the Centre of a Noisy Measurement Is the Thing That Obeys a Law

## A prediction that failed four times, and a law that held

Imagine a laboratory notebook with four numbers written in it *before* an experiment begins:
$192$, $224$, $240$, $256$. These are pre-registered guesses at a single quantity — the smallest
attention budget at which a trained language model still retains $98\%$ of its full accuracy. The
experiment runs for four hours. The answer comes back: $160$.

All four guesses are wrong. Not narrowly wrong, not "within error bars" wrong — every one of the
four pre-stated values *comfortably clears the bar*, so none of them can be the threshold. On a
naive scoring rule, the round is a rout: $0$ for $4$.

And yet the same round confirmed, exactly and to the digit, a law that had been stated in advance.
The law did not predict the measurement. It predicted the **centre of the distribution of
measurements**. Three random seeds at this configuration produced the threshold set
$\{160,\ 224,\ 256\}$, whose median is $224$ — precisely $\tfrac{7}{8}$ of the reference value
$256$. At a shorter configuration, three seeds had produced $\{96,\ 112,\ 128\}$, median $112$,
precisely $\tfrac{7}{8}$ of the reference value $128$.

Two configurations. Six seeds. One ratio: $\tfrac{7}{8}$.

This article is about the mathematics that makes such a thing possible: why a quantity can be
unpredictable point-by-point while its *centre* is lawful, and why the median — not the average,
not the best case, not the worst case — is the unique reading of a small ensemble that neither
flatters nor slanders the truth.

## Knees, budgets, and the quota ladder

Start with the object being measured. A system has a tunable budget $k$ — how many memory slots it
may consult, how many terms of a series it may keep, how many samples it may draw. Increasing the
budget can only help: the *retained performance* $c(k)$, measured as a fraction of the
full-budget performance, is a non-decreasing function of $k$. Fix a bar, say $0.98$. The **knee**
$k^{*}$ is the smallest budget on the tested grid at which $c(k) \ge 0.98$ — the cheapest setting
you can honestly ship.

Now run the same experiment with several random seeds. Each seed $i$ reports its own knee $K_i$,
and the numbers disagree. What single budget should you quote?

There is not one answer but a **ladder** of answers, indexed by how many seeds you insist on
satisfying. Say a seed *passes* at budget $b$ if $K_i \le b$, and write $\mathrm{pass}(b)$ for the
set of passing seeds. For a quota $m$, define the **quota budget**
$$Q(m) \;=\; \min\{\, b \;:\; |\mathrm{pass}(b)| \ge m \,\},$$
the cheapest budget at which at least $m$ of the seeds are satisfied. The whole theory rests on one
small, completely general observation, whose proof is two lines but whose consequences run through
everything below:

> **Rung Characterisation.** For any ensemble of seeds and any feasible quota $m$,
> $$Q(m) \le b \quad\Longleftrightarrow\quad m \le |\mathrm{pass}(b)|.$$

In words: *the $m$-th rung of the ladder sits at or below $b$ exactly when the quota is met at
$b$.* This converts a statement about an order statistic into a statement about a counting event —
which is what will later let us attach probabilities to rungs.

For three seeds the ladder has three rungs, and they are the three order statistics you would have
guessed:
$$Q(1) = \min_i K_i, \qquad Q(2) = \operatorname{med}(K_1,K_2,K_3), \qquad Q(3) = \max_i K_i,$$
and necessarily $Q(1) \le Q(2) \le Q(3)$. The bottom rung is the *best case*, the lucky seed. The
top rung is the *guarantee*: the all-seeds-safe budget, the only rung you may quote as a promise.
The middle rung is the *centre*.

## The three rungs behave completely differently

Here is where the mathematics becomes sharp, and where the empirical round earns its name.

**The guarantee rung is infinitely fragile.** One bad seed drags the maximum arbitrarily far: for
any bound $B$ whatsoever there is a value of a single seed that pushes $\max$ past $B$. The
guarantee has *breakdown point zero*. It is the honest number to promise a user, and it is the
number you can least trust to reproduce.

**The centre cannot be moved out of the bracket.** Whatever a rogue seed $x$ does,
$$\min(b,c) \;\le\; \operatorname{med}(x,b,c) \;\le\; \max(b,c);$$
the median of three is pinned inside the interval spanned by the other two. More generally, in an
ensemble of $2m+1$ seeds, corrupting any $m$ of them leaves the middle rung inside the clean
ensemble's range, while $m+1$ corruptions can place it anywhere — the classical breakdown point of
$1/2$, and it is sharp. Even the general one-seed statement is exact: replacing a single seed moves
the $m$-quota budget into the interval $[\,Q(m-1),\, Q(m+1)\,]$ of the *original* ensemble. A rung
slips by at most one rung. The top rung has no $Q(m+1)$ above it to catch it, which is precisely
why it has no protection at all.

**Safety and robustness are genuinely in tension.** One cannot have both: a quota budget is safe
for *every* seed if and only if it is the full-quota budget. The moment you step down from the
maximum to gain robustness, you have given up the guarantee. The median is *not* a promise — at a
median budget, every seed whose knee lies above it demonstrably fails the bar. It is a *description
of the population*, and that is a different, equally useful thing.

**The law is not an artefact of the measuring grid.** One might worry that a ratio like $7/8$ is
manufactured by the coarse sweep grid on which knees are read off. It is not, for a structural
reason: order statistics commute with every monotone map. Quantising a real knee $\kappa$ to the
grid, $\kappa \mapsto s\lceil \kappa/s\rceil$, is monotone, so the median of the three *reported*
knees equals the quantisation of the median of the three *true* knees. Quantisation shifts the
median by a non-negative amount strictly less than one grid step $s$ — it can blur the law, but it
cannot invent it or destroy it.

## Why the median is the honest rung: a coin-flip calculation

Now make the seeds random. Fix a budget $b$ and let $p$ be the probability that a single seed's
knee lands at or below $b$. Three independent seeds give eight equally-structured outcomes, and by
the Rung Characterisation the probability that rung $m$ sits at or below $b$ is exactly the
probability that at least $m$ seeds pass. Those probabilities are three cubic polynomials:
$$F_3(p) = p^{3}, \qquad F_2(p) = 3p^{2} - 2p^{3}, \qquad F_1(p) = 3p - 3p^{2} + p^{3}.$$
On $[0,1]$ they are ordered, $F_3 \le F_2 \le F_1$ — the probabilistic ladder mirrors the
combinatorial one, the guarantee rung being the hardest to meet and the best case the easiest.

Now evaluate at the symmetric point $p = 1/2$, where a single seed is a fair coin:
$$F_3(\tfrac12) = \tfrac18, \qquad F_2(\tfrac12) = \tfrac12, \qquad F_1(\tfrac12) = \tfrac78 .$$
**The median rung is the unique calibrated rung.** Feed it a coin flip and it returns a coin flip.
The guarantee rung is pessimistic by a factor of four ($1/8$ instead of $1/2$); the best-case rung
is optimistic by the mirror-image factor ($7/8$). If you read a three-seed experiment through its
maximum, you will systematically understate how often the system is cheap; through its minimum, you
will systematically overstate it. Only through the centre do you report what you saw.

Better still, the median does not merely preserve a tendency — it **sharpens** it:

> **Amplification.** If $1/2 < p < 1$ then $F_2(p) > p$; if $0 < p < 1/2$ then $F_2(p) < p$. The
> map $p \mapsto 3p^{2}-2p^{3}$ has exactly three fixed points, $0$, $1/2$ and $1$, and its
> derivative at $1/2$ is $3/2 > 1$.

The calibrated point is a **repelling** fixed point. A per-seed majority becomes a stronger
three-seed majority; a per-seed minority is suppressed. That is the exact, quantitative sense in
which "take three seeds and read the middle one" converts noise into a law. Put in the numbers of
the round: four of the six recorded seeds have their knee at or below the $7/8$ budget, so
$p = 2/3$. The three-seed median lands there with probability $F_2(2/3) = 20/27 \approx 0.741$,
comfortably above $2/3$, while the guarantee rung is met only with probability
$F_3(2/3) = 8/27 \approx 0.296$. Reading the centre buys you the difference.

## Two contexts, six seeds, one ratio

With the theory in place, the data can be read properly. The reference scale is the **product
point** $P(d,\mathrm{ctx}) = d\cdot\mathrm{ctx}/32$: $128$ at the shorter configuration
($d=4$, $\mathrm{ctx}=1024$), $256$ at the longer one ($d=4$, $\mathrm{ctx}=2048$).

| configuration | three-seed knee set | as fractions of $P$ | spread | median |
|---|---|---|---|---|
| shorter, $P=128$ | $\{96,\ 112,\ 128\}$ | $\{0.750,\ 0.875,\ 1.000\}$ | $0.250$ | $112 = \tfrac78 \cdot 128$ |
| longer, $P=256$ | $\{160,\ 224,\ 256\}$ | $\{0.625,\ 0.875,\ 1.000\}$ | $0.375$ | $224 = \tfrac78 \cdot 256$ |

Three facts jump out, and each is a theorem about the two-point fit.

*The centre is a genuine ratio law.* $\alpha = 7/8$ is the **unique** constant with
$\alpha\cdot 128 = 112$ and $\alpha \cdot 256 = 224$; equivalently, the best affine fit
$\alpha\cdot\mathrm{ctx} + \beta$ through the two measured medians has intercept $\beta = 0$
exactly.

*The top rung is a ratio law too*, with the trivial ratio $\alpha = 1$, again intercept-free: the
product point is a pinned upper edge, and it passed the bar at every seed of both configurations.

*The bottom rung is not a ratio law at all.* No single $\alpha$ satisfies
$\alpha\cdot 128 = 96$ and $\alpha\cdot 256 = 160$: the two ratios are $3/4$ and $5/8$. The affine
fit exists and is unique — $96 = 1024/16 + 32$, $160 = 2048/16 + 32$ — but it carries a **non-zero
intercept** $\beta = 32$.

This is the **intercept-free dichotomy**: among the three order statistics, exactly the upper two
admit a context-free ratio law; the low tail demands an additive offset. An intercept is the
signature of a *floor* — a fixed cost that must be paid before any budget-dependent benefit
accrues — and only the optimistic rung, dominated by the luckiest seed, can see it. The centre and
the guarantee average it away.

The widening spread has the same explanation. The upper edge is pinned at $1$, the median is pinned
at $7/8$, so all the growth in spread ($0.250 \to 0.375$) lives in the low tail
($0.750 \to 0.625$). And there is an exact constraint: if the upper edge is pinned and the median
sits at $7/8$, the spread is at least $1/8$, with equality if and only if the low tail is itself at
$7/8$.

## The payoff: how fast, and how sure?

Translate budgets into speed. A budget $k$ against a context of length $\mathrm{ctx}$ buys a factor
$\mathrm{ctx}/k$. Then:

- the **guarantee** speedup, at the product point, is $\mathrm{ctx}/(d\cdot\mathrm{ctx}/32) = 32/d$
  — *independent of context*: $8\times$ at $d=4$, verified at every one of six seeds across two
  configurations;
- the **median** speedup, at $\tfrac78 P$, is $256/(7d)$ — also independent of context:
  $64/7 \approx 9.14\times$;
- the **best case** is *not* context-free: it grew from $32/3 \approx 10.67\times$ to
  $12.8\times$.

And this last growth is bounded. Under the affine low-tail law $k = \mathrm{ctx}/16 + 32$, the
best-case speedup is the hyperbola
$$\frac{\mathrm{ctx}}{\mathrm{ctx}/16 + 32} \;=\; \frac{16\,\mathrm{ctx}}{\mathrm{ctx} + 512},$$
strictly increasing in $\mathrm{ctx}$ and strictly below $16$ forever. The observed
$10.67 \to 12.8$ is exactly this curve, saturating below $16\times$ — a bounded promise, not an
unbounded one.

So the deployment reading at the longer configuration is a *distribution*, not a number:
$\{8.0\times,\ 9.1\times,\ 12.8\times\}$ — guaranteed, typical, lucky.

## Point-prediction and centre-prediction are logically independent

Which brings us back to the four failed guesses. Was the round a failure or a success? Both, and
the two verdicts are independent in a provable sense.

With two seeds already recorded at $224$ and $256$, the third seed $x$ leaves the median at $224$
**exactly when** $x \le 224$. That is a whole family — $\{160, 192, 224\}$ among the tested grid
points all keep the centre at $224$; only $x \ge 240$ would move it. Meanwhile the four
pre-registered point guesses form the set $\{192, 224, 240, 256\}$. All four combinations of "hit a
point guess" and "preserve the predicted centre" are realised by admissible values of $x$: $160$
misses every point and preserves the centre; $224$ hits a point and preserves it; $240$ hits a
point and breaks it; $288$ misses every point and breaks it. Hitting a pre-registered point and
confirming the predicted centre are **logically independent events**. A round can be $0/4$ on horns
and $1/1$ on the law without the slightest contradiction, and this one was.

There is an asymmetry worth naming: the centre is *harder to refute but not vacuous*. Any value at
or below $224$ preserves it — a large target — but $240$, $256$ or anything above would have
destroyed it outright, and those values were entirely available; indeed the other two seeds landed
there.

## What the next experiment decides

The theory hands the next run a single inequality. Add a fourth seed $x$ to the recorded
$\{256, 224, 160\}$. Then, in closed form:
$$Q(3) = \max\bigl(224, \min(256, x)\bigr), \qquad Q(2) = \min\bigl(224, \max(160, x)\bigr),
\qquad Q(4) = \max(256, x).$$
In particular the upper-median rung stays at $224$ **if and only if** $x \le 224$. One number, one
inequality, pre-registered — and it discriminates between two genuinely different readings of the
$7/8$ law. Under one reading $7/8$ is a constant; under the other it is the $n=3$ instance of
$1 - 2^{-n}$, the median of the maximum of $n$ exchangeable draws, in which case a fourth seed
should push the centre toward $15/16$, i.e. $240$. The polynomials $p^3$, $3p^2-2p^3$,
$3p-3p^2+p^3$ are exactly the $n=3$ case of that computation, so the two hypotheses are not idle
alternatives — they differ by one grid step, and one run separates them.

At double the context, the two low-tail families split too: the constant-ratio reading predicts
$320$, the affine reading $288$, a gap of exactly $\mathrm{ctx}/64 - 32$, which is $0$ where they
were fitted and one grid step at the next cell. The median law predicts $448 = \tfrac78 \cdot 512$.

## The moral

There is a habit of mind that treats a scientific prediction as a dart thrown at a number, and
scores it hit or miss. For noisy systems this habit is a trap: it rewards laws that are lucky and
punishes laws that are true. The alternative on display here is to predict a *functional of the
distribution* and to choose that functional for its statistical virtues rather than its rhetorical
convenience.

The median has those virtues, provably. It is the only rung of a three-seed ladder that is
calibrated. It has breakdown point $1/2$, the maximum possible, where the guarantee has breakdown
point $0$. It is equivariant under any monotone change of scale, so no reparametrisation of the
budget axis can fake or hide a law read through it. And it is *repelling* at the calibrated point —
its derivative $3/2$ means a majority tendency is amplified, not merely transmitted, so three seeds
buy strictly more than one.

The failure of four sharp guesses and the survival of one soft-looking law are, on this account,
not in tension. They are the expected signature of a system whose individual outcomes are noisy and
whose centre is lawful. That is most systems worth measuring.
