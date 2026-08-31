# The Dial That Told the Truth and the Knob That Turned the Wrong Way

## A story about prediction, allocation, and the difference between them

Suppose you run a large factoring computation. Your machine has to grind through
hundreds of independent subproblems — call them *targets* — and each target,
per unit of computing time you spend on it, hands back a certain number of useful
outputs. Call that number the target's **rate**, $r_i$: relations produced per unit
of sieve length. Some targets are generous; some are stingy; a few, as we shall see,
are silently and permanently barren.

You have a fixed budget $B$ of computing time to divide among $n$ targets, and you
have just built a cheap predictor — a *dial* — that guesses each target's rate before
you spend anything on it. The dial is good. Ranked against the truth, its predictions
agree with reality about $74\%$ of the time by rank correlation; a perfect oracle dial,
which knows each rate exactly but is measured against the noisy realised yield, only
manages $78\%$. On a larger factor base the agreement rises to $84\%$. By the standards
of applied prediction this is an excellent instrument.

So you use it. The obvious move: **spend more time where the yield is thin**, to even
things out — sieve length in inverse proportion to the predicted rate,
$\ell_i \propto 1/r_i$. Every target gets its fair share of *relations*, roughly, rather
than its fair share of *seconds*.

The result was a catastrophe. Total output fell by $17.6\%$ against the boring baseline
of splitting the budget equally. Worse, that $-17.6\%$ was only survivable because of an
engineering safeguard nobody thought was doing real work: a *floor clip* guaranteeing
every target some minimum sieve length no matter what the dial said. Remove the clip and
run the policy in its pure form, and output falls by $146.7\%$ — i.e. the run collapses.
Meanwhile a policy running in exactly the opposite direction — a *concentrator* that
pushes budget toward the targets the dial likes best — gained $8.6\%$, and an oracle that
could see all the rates in advance would have gained $74.8\%$.

The natural diagnosis is that the dial must be worse than it looked; that a rank
correlation of $0.74$ is not enough to steer by. **That diagnosis is wrong, and one can
prove it is wrong.** The dial is fine. The policy is impossible. A dial with *perfect*
calibration, plugged into inverse-rate reallocation, would still have lost.

---

## The two-line theorem behind the disaster

Here is the whole allocation model. Targets $i = 1, \dots, n$ have positive rates
$r_i > 0$; an allocation is a vector $\ell$ of sieve lengths with $\sum_i \ell_i = B$;
the total yield is
$$Y(\ell) = \sum_{i=1}^n r_i \, \ell_i.$$

Two candidate policies. The **uniform baseline** gives everyone $\ell_i = B/n$, so
$$Y_{\text{unif}} = \frac{B}{n}\sum_i r_i = B \cdot \operatorname{AM}(r),$$
the budget times the *arithmetic mean* of the rates. The **inverse-rate policy** sets
$\ell_i = B \cdot r_i^{-1} / \sum_j r_j^{-1}$ — that is the unique normalisation making
the lengths inversely proportional to the rates and the budget exactly $B$. Its yield is
astonishing in its simplicity: each target contributes
$r_i \ell_i = B / \sum_j r_j^{-1}$, *the same amount regardless of $i$*, so
$$Y_{\text{inv}} = \frac{Bn}{\sum_i r_i^{-1}} = B \cdot \operatorname{HM}(r),$$
the budget times the *harmonic mean*.

And now the punchline is a two-thousand-year-old inequality. The harmonic mean never
exceeds the arithmetic mean, with equality if and only if all the rates coincide.
Therefore
$$Y_{\text{inv}} \;\le\; Y_{\text{unif}},$$
**always**, and *strictly* as soon as two targets have different rates. The inverse-rate
policy cannot beat doing nothing clever, and it can only tie in the one situation where
the dial has nothing to say. The better the dial, the more rate spread it reveals, the
worse the loss. The measured $-17.6\%$ is not a calibration failure; it is the arithmetic
mean–harmonic mean gap of the true rate distribution, showing up in a production log.

The proof used here is elementary and self-contained: it symmetrises over ordered pairs.
Expanding the product,
$$\Big(\sum_i r_i\Big)\Big(\sum_j r_j^{-1}\Big) = \sum_{i,j} \frac{r_i}{r_j},$$
and pairing each $(i,j)$ with $(j,i)$ turns the right-hand side into
$\tfrac12\sum_{i,j}\big(\tfrac{r_i}{r_j} + \tfrac{r_j}{r_i}\big)$. Since
$$\frac{x}{y} + \frac{y}{x} - 2 = \frac{(x-y)^2}{xy} \;\ge\; 0$$
for positive $x, y$, with strict inequality when $x \ne y$, every one of the $n^2$
pairs contributes at least $2$, and one of them contributes strictly more the moment two
rates differ. Hence $\big(\sum r_i\big)\big(\sum r_i^{-1}\big) \ge n^2$, which is exactly
$\operatorname{HM}(r) \le \operatorname{AM}(r)$.

---

## Why the safeguard was doing the real work

The floor clip now stops being a hack and becomes a *coordinate*. Define, for a floor
$f \ge 0$, the clipped policy
$$\ell_i(f) = f + \big(B - nf\big)\frac{r_i^{-1}}{\sum_j r_j^{-1}}:$$
give everybody $f$ up front, then split what remains by inverse rate. At $f = 0$ this is
the raw inverse-rate policy; at $f = B/n$ the residual budget is zero and this is
*exactly* the uniform baseline. So a single real parameter interpolates between the
disaster and the baseline.

A short computation gives the yield along this line, and it is **affine in $f$**:
$$Y(f) \;=\; \underbrace{\frac{Bn}{\sum_i r_i^{-1}}}_{\text{the } f=0 \text{ disaster}} \;+\; f\left(\sum_i r_i - \frac{n^2}{\sum_i r_i^{-1}}\right).$$
The slope is $\sum_i r_i - n^2 / \sum_i r_i^{-1}$, which is nonnegative precisely by the
same inequality $\big(\sum r_i\big)\big(\sum r_i^{-1}\big) \ge n^2$, and strictly positive
the moment two rates differ. **Every unit of floor buys yield, monotonically.** The clip
is not protecting against an edge case; it is dragging the operating point up a straight
line whose top end is the baseline you were trying to beat. Turn the clip off and you
slide to the bottom of that line — which is why the unclipped run lost $146.7\%$ and the
clipped one only $17.6\%$. Two numbers, one line.

---

## The correct sign, and the ceiling

If spreading is wrong, concentrating must be right, and it is. Put the entire budget on
a single target $i_0$ of maximal rate: the yield is $r_{i_0} B$, and since the maximum
dominates the mean, $r_{i_0} B \ge B \cdot \operatorname{AM}(r) = Y_{\text{unif}}$.
That is the measured $+8.6\%$ — the same inequality read the other way round.

How much is on the table in total? Exactly this much, and no more. For *any* allocation
with nonnegative lengths summing to $B$,
$$Y(\ell) = \sum_i r_i \ell_i \le \sum_i r_{\max} \ell_i = B \cdot r_{\max},$$
and the concentrator attains it. So $B \cdot r_{\max}$ is the exact supremum of achievable
yield — the *oracle bound* — and the headroom over the uniform baseline is precisely
$$B\big(r_{\max} - \operatorname{AM}(r)\big),$$
capped by a factor of $n$ above the baseline whatever the rates do. The measured $+74.8\%$
oracle gap is therefore not a loose estimate: it is exactly the spread between the best
target and the average one, and nothing else.

---

## The flip: stop reallocating, start refusing

The experiment then did the thing that worked. Instead of *reallocating* effort, use the
same dial to **skip**. Fix a threshold $\theta$, keep the targets whose dial value is at
least $\theta$, and defer the rest. In deployment, $\theta$ at the twentieth percentile
skipped $28.3\%$ of the work while retaining $89.5\%$ of the relations, for a $28.9\%$
throughput gain.

Here too the sign is a theorem, not luck. Say a dial $d$ is **concordant** with the true
rate if it never ranks two targets backwards: $d_i < d_j \Rightarrow r_i \le r_j$. A
threshold on a concordant dial produces a *separated* split — every kept target is at
least as good as every skipped one — and separation alone forces
$$\underbrace{\frac{\sum_{i \in K} r_i}{\sum_{i \in s} r_i}}_{\text{retention}} \;\ge\; \underbrace{\frac{|K|}{|s|}}_{\text{work fraction}} ,$$
which is exactly the shape of "$89.5\%$ of the relations for $71.7\%$ of the work". Equivalently,
throughput — yield per unit of work — never falls, and rises *strictly* the moment the
threshold defers a genuinely worse target.

But the deployed dial is *not* concordant; it is $0.74$-correlated, i.e. it makes a
bounded number of ranking mistakes. How much can that cost? Let $\mathrm{Disc}$ be the
set of ordered pairs the dial inverts. A first bound charges each inversion the largest
rate $M$:
$$|K| \sum_{i \in s} r_i \;\le\; |s| \sum_{i \in K} r_i \;+\; M\,|\mathrm{Disc}|,$$
so the retention deficit degrades **linearly**, not catastrophically, in the number of
inversions — and collapses to the exact concordant statement when $\mathrm{Disc} = \emptyset$.
A sharper bound charges each inversion only what it actually costs, its *rate gap*: the
**inversion mass**
$$\mathrm{IM} = \sum_{(j,i) \in \mathrm{Disc}} (r_j - r_i)$$
replaces $M|\mathrm{Disc}|$, is never larger, vanishes exactly for concordant dials, and can
be dramatically smaller — on an explicit three-target instance the refined penalty is $1$
where the crude one is $10$.

In fact the truth is an *identity*, not an inequality. The deficit is exactly the
inversion mass the threshold pays minus the **concordance mass** it earns on the pairs
it gets right:
$$|K|\sum_{i\in s} r_i - |s|\sum_{i \in K} r_i \;=\; \mathrm{IM}_\theta - \mathrm{CM}_\theta.$$
A dial wins whenever it is right more heavily than it is wrong. Kendall discordance is
not a proxy here; it is the ledger.

---

## Where the barren targets come from

The last piece is the prettiest, because it is not statistics at all. The sieve looks for
primes $p$ dividing values $x^2 - N$. Whether a given $p$ ever divides such a value is
decided by a classical congruence: $x^2 \equiv N \pmod p$. For an odd prime $p$ with
$N \not\equiv 0$, this congruence has **exactly two** solutions per period when $N$ is a
quadratic residue mod $p$, and **exactly zero** otherwise — because $x^2 = y^2$ forces
$x = \pm y$, and the two signs are distinct when $p$ is odd.

So the per-period hit rate of a factor-base prime is exactly
$$r(p) = \frac{2}{p} \quad\text{(admissible)} \qquad\text{or}\qquad r(p) = 0 \quad\text{(inadmissible)},$$
with nothing in between and nothing random. The residue dial is not a proxy for the rate;
up to the deterministic factor $2/p$ it **is** the rate. Three consequences follow at once.

*Small admissible primes carry the yield*, since $2/p$ decreases in $p$ — which is
precisely why concentrating wins and spreading loses.
*The hard tail is unreachable by construction*: a non-residue prime divides no sieve value
whatsoever, so its yield is identically zero at every sieve length. In the run, $40$ of
$400$ targets were of this kind. No amount of deeper sieving reaches them; moving any
positive budget off such a target onto a live one strictly increases yield. Deferral is the
instrument, not depth.
*The aggregate rate of a whole factor base is a deterministic arithmetic quantity*:
summing over admissible primes $A$,
$$R(A) = \sum_{p \in A} \frac{2}{p} = 2 H_A,$$
twice the harmonic sum of the admissible primes, with the inadmissible ones contributing
nothing. The oracle target is the *smallest* admissible prime, with rate $2/p_{\min}$, and
the exact ratio of oracle to mean is
$$\frac{r_{\max}}{R(A)/|A|} = \frac{|A|}{p_{\min} H_A},$$
strictly below the crude ceiling $|A|$ as soon as the base has two primes. The headroom
has a closed form.

---

## One number, not $2^n$ policies

A deployment does not have to accept threshold policies on faith. Suppose the run must
collect a quota $Q$ of relations and may choose *any* subset of targets to work on —
$2^n$ possibilities. Among subsets of a given size, a maximal-yield one exists, and an
exchange argument shows **every** maximiser is separated: you can never improve by keeping
a worse target while deferring a better one. Consequently the *minimum-work* quota-feasible
schedule can always be taken separated, and every separated schedule sits inside a single
threshold set — take $\theta$ to be its own smallest rate. Hence: **whenever the quota is
attainable at all, it is attained by a single threshold on the rate dial, with throughput
at least that of sieving everything.** The policy space collapses from $2^n$ subsets to
one real number.

The only residue of slop is ties. A threshold keeps *every* target whose rate equals
$\theta$, so it can overshoot a minimal schedule — by exactly the tie class, not more.
And on a genuine factor base there are no ties, because $p \mapsto 2/p$ is injective:
distinct admissible primes have distinct rates. On such a base the threshold policy is
*exactly* minimum-work.

Finally, honesty about the trade-off. Raising $\theta$ never lowers throughput — so on
throughput alone the optimum is degenerate, keep only the single best target — while
raising $\theta$ never raises total yield, and strictly lowers it as soon as a live target
is deferred. The two headline numbers, "$+28.9\%$ throughput" and "$89.5\%$ retention",
move in opposite directions by theorem. Choosing $\theta$ is choosing which constraint
binds: work, or relations.

---

## The moral

A predictor and a policy are different objects, and a good predictor wired into a bad
policy produces exactly the evidence that would convict the predictor. The rescue was
not a better dial. It was noticing that the loss had the shape of the arithmetic
mean–harmonic mean gap — a quantity that does not care how accurate your forecasts are —
and then using the same forecasts in the one deployment that separation makes
monotone: not *where do I spend more*, but *what do I refuse to spend on at all*.
