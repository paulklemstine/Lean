# The Hedging Hump: Why Half-Believing a Tip Is the Worst Thing You Can Do

*A tip about where to look can save you almost all of your work, or cost you more than having no tip at all. Which one you get depends on how much you trust it, and on where the tip points.*

---

## A game of hide and seek with numbers

Here is a simple game. A friend picks two whole numbers, $p$ and $q$, each uniformly at random from $1$ to $M$, and keeps them secret. Your job is to find the **smaller** of the two, $J = \min(p, q)$. You may ask about one number at a time: "Is $J = 17$?" Each question is a *probe*. You keep probing until you hit $J$. What you pay is the number of probes.

This is a toy, but a useful one. It is the simplest model of looking for the smaller of two hidden quantities. The best-known example is the smaller prime factor of a number $N = pq$. Trial division climbs up from the bottom. Fermat's classical method starts at $\sqrt N$ and works from the top. Both are ways of choosing *an order of search*, and the toy game strips that choice down to its bones.

The first observation is that $J$ prefers small values. For $J$ to equal $1$ it is enough that *either* number is $1$. For $J$ to equal $M$, *both* numbers must be $M$. Counting the pairs gives the exact law

$$
\Pr(J = i) = \frac{2(M - i) + 1}{M^2}, \qquad i = 1, \dots, M,
$$

which falls in a straight line from roughly $2/M$ down to $1/M^2$. We will call it the **min-law**.

When the probabilities are known, the best order is obvious, and it is a classical fact (the rearrangement inequality): **probe the most likely values first**. Here that means $1, 2, 3, \dots$ in order. The expected number of probes is then

$$
B(M) = \frac{(M+1)(2M+1)}{6M} \approx \frac{M}{3}.
$$

For $M = 512$ this is $171.17$ probes. Keep that number in mind. It is the price of searching **blind**.

## Enter the oracle

Now suppose someone whispers a tip: *"$J$ is somewhere in this window,"* naming a block of $W$ consecutive cells. Write $x = W/M$ for the fraction of the range the window covers. If the tip were certain, you would search only inside the window and pay at most $W$ probes. That would be a speedup of up to about $1/x$.

Real tips are not certain, though. You might believe this one with some **trust level** $\alpha$ between $0$ and $1$. The natural way to act on partial belief goes like this. Put total probability $\alpha$ on the window and $1 - \alpha$ on everything outside it. Inside each part, keep the relative odds the prior already gave you. Concretely, a cell $j$ with prior probability $p_j$ gets the new weight

$$
q_\alpha(j) = \begin{cases} \dfrac{\alpha}{P(S)}\, p_j & j \text{ in the window } S,\\[2mm] \dfrac{1-\alpha}{1-P(S)}\, p_j & \text{otherwise,}\end{cases}
$$

where $P(S)$ is the prior probability that $J$ lies in the window. Then you search in the best order for these new weights, which is again "most likely first." Call the expected cost $E(\alpha)$.

There is one special trust level. If $\alpha = P(S)$, you trust the tip exactly as much as the prior already did. The formula then returns the prior unchanged and $E$ equals the blind cost. We call this the **calibrated** trust. It is the "no news" point.

You would expect the following picture. As trust moves from "ignore the tip" ($\alpha = 0$) to "bet everything on it" ($\alpha = 1$), the cost should change smoothly, maybe in a straight line, and somewhere in between you should do at least as well as blind search.

That picture is wrong.

## The hump

Take $M = 512$ and a window covering the top quarter of the range, the cells $385$ to $512$. Plot $E(\alpha)$ against $\alpha$:

| trust $\alpha$ | expected probes $E(\alpha)$ |
|---|---|
| $0$ (ignore the window entirely) | $154.10$ |
| $0.0625$ (calibrated: no news) | $171.17$ |
| $\approx 0.22$ (**the peak**) | $\approx 196.5$ |
| $1$ (trust the window completely) | $43.17$ |

The curve rises from $154$ through the blind level $171$ to a peak near $196.5$, and then falls steeply to $43$. A searcher who trusts the tip about one-fifth of the way pays **about 15% more than a searcher with no tip at all**. They also pay more than someone who rejects the tip outright, and four and a half times more than someone who believes it fully.

We call this the **hedging hump**. Partial trust is not a safe middle ground. It is the most expensive way to act.

Why does it happen? With weak trust, the searcher still starts at the bottom, at cells $1, 2, 3, \dots$ But the extra weight on the window drags window cells forward in the order, one after another, ahead of low cells that are actually more likely. The searcher ends up with an order that is wrong whichever way the truth falls. If $J$ is small, which is likely, the searcher has wasted probes up at the top. If $J$ is in the window, the searcher has not committed hard enough to reach it quickly. Hedging spreads your effort over two hypotheses and serves neither well.

## Three theorems behind the picture

The striking part is that this is not a quirk of one example. The shape of the curve follows from a few clean facts.

**The curve is always concave and made of straight pieces.** For any fixed order of search, the expected cost is a *linear* function of $\alpha$. The weights $q_\alpha$ depend linearly on $\alpha$, and the cost of a fixed order is a weighted sum of them. The optimal searcher picks the cheapest order at each $\alpha$, so $E(\alpha)$ is the **lower envelope of $M!$ straight lines**. A minimum of lines is always concave and piecewise linear: it can bend downward, never upward. So any interior peak is a genuine summit.

**The hump appears for every decreasing prior.** Here is the general statement.

> **Hedging Hump Theorem.** Let the prior $p_1 > p_2 > \dots > p_n$ be strictly decreasing, and let the window $S$ have prior mass strictly between $0$ and $1$. Suppose the average position of $J$ inside the window differs from its average position outside. Then there is a trust level $\alpha$ strictly between $0$ and $1$ at which the optimal search costs strictly more than searching with no tip.

The idea of the proof fits in a paragraph. At the calibrated trust the weights are the prior itself, and they are *strictly* decreasing. Every gap between neighbouring weights is strictly positive, so a small change in $\alpha$ cannot reverse any of them. Near the calibrated point the optimal order therefore stays "ascending." Along a fixed order the cost is linear in $\alpha$, with slope equal to (average position inside the window) minus (average position outside). That slope is not zero, so moving $\alpha$ a little in the uphill direction strictly raises the cost above the blind value. Nothing in this argument uses the min-law. The hump is universal.

**For the min-law and a window at the top, the hump beats everything.** For the two-number game with the window at the right end, we get more:

> **Right-Window Hump Theorem.** For the min-law and a right-hand window of width $W$ with $3W \le M$, there is a trust level strictly between $0$ and $1$ whose cost is strictly larger than (i) the blind cost, (ii) the cost at full distrust, and (iii) the cost at full trust.

Full distrust searches the outside region in order. Its cost is the average position outside the window, which is below the blind average because the window sits at the top. Full trust scans the window from its right end and costs at most $W$. Since $3W \le M$, that is less than the blind cost of about $M/3$. The hump rises above both.

**And there is a ceiling.** How high can the hump go? For *any* probability vector on $n$ cells, scanning forwards and scanning backwards cost $(n+1)$ in total. The better of the two therefore costs at most $(n+1)/2$:

$$
E(\alpha) \;\le\; \frac{n+1}{2}\quad\text{for every }\alpha.
$$

The uniform distribution reaches this bound. For $M = 512$ the ceiling is $256.5$, so the measured peak of $196.5$ climbs about 30% of the way from the blind level toward the worst case possible. There is also a variant of the model in which the window gets weight $\alpha/W$ per cell, uniformly, rather than in proportion to the prior. In that variant the trust level $\alpha = x$ makes the posterior exactly uniform, and the hump reaches the ceiling exactly.

## Where you point matters as much as how wide

Now set trust to $1$ (a perfectly reliable tip) and ask how much a window of width $W$ helps. The answer depends on **where the window sits**.

Suppose the window starts $d$ cells from the right end, so it covers cells $M-d+1$ to $M-d+W$. Scanning it in ascending order is optimal, because the min-law still decreases inside it. A direct summation gives the **placement law**

$$
E \;=\; \frac{(W+1)\,(6d - 4W + 1)}{6\,(2d - W)}.
$$

This one formula answers every placement question:

* **Right is always best.** Sliding the window to the right strictly lowers the cost, for every width $W \ge 2$.
* **Right windows are miniature copies of the whole game.** Restrict the min-law to its top $W$ cells and rescale. You get exactly the min-law on $W$ cells. Restricting the minimum of two uniform numbers to its upper tail gives the minimum of two smaller uniform numbers. So the right window costs $(W+1)(2W+1)/(6W) \approx W/3$, a third of its width, just as blind search costs a third of $M$.
* **A universal ceiling.** For every placement, the speedup over blind search is at most $M/W = 1/x$. This holds exactly for every finite $M$, not just in a limit.
* **The asymptotic law.** Write $M = kW$ and $d = mW$ with $1 \le m \le k$. As the window grows, the speedup tends to
$$
\frac{k\,(2m-1)}{3m-2}.
$$
A right window ($m=1$) gives $k = 1/x$, the full ceiling. A left window ($m=k$) gives $(2-x)/\big(x(3-2x)\big) \approx 2/(3x)$, and a centered window also gives about $2/(3x)$.

So the same width buys about $1/x$ on the right and only about $2/(3x)$ on the left or in the middle. The right-to-left ratio $(3k-2)/(2k-1)$ approaches $3/2$. Placement is worth a 50% bonus: the same number of cells, used in a better place.

The best cell in our tables is $M = 256$ with a right window of width $16$ ($x = 1/16$). It gives a speedup of $43947/2992 \approx 14.69$, close to its ceiling of $16$.

| window fraction | left | centered | right | ceiling $1/x$ |
|---|---|---|---|---|
| $1/64$ | $34.40$ | $34.47$ | $45.78$ | $64$ |
| $1/16$ | $10.20$ | $10.30$ | $14.69$ | $16$ |
| $1/8$ | $5.32$ | $5.42$ | $7.68$ | $8$ |

*Speedups at $M = 256$ with a perfectly trusted window.*

## How sure must you be?

Back to partial trust, now for a left window. Suppose you want a speedup of $5.19$, which is roughly what a perfect $1/8$-window delivers on the left. How much must you trust the tip? Searching window-first, the cost is exactly linear in $\alpha$. At $M = 256$ the threshold is:

* for a window of fraction $1/8$: $\alpha^*$ between $0.995$ and $0.996$;
* for a window of fraction $1/64$: $\alpha^*$ between $0.836$ and $0.837$, drifting toward $0.833$ as $M$ grows.

To get serious gains, the tip must be **narrow and nearly certain**. A broad tip that is merely "likely" does not get there.

## The honesty gate

All of this assumed you could simply *choose* a trust level. In practice a tip comes from somewhere, and an honest source must be **calibrated**. Over many games, the tips it gives, together with how often it gives them, must average back to the prior. Formally, a source fires with probability $r$ and leaves you with beliefs $q$; otherwise it leaves you with $q'$; and

$$
p_j \;=\; r\,q_j + (1-r)\,q'_j \quad\text{for every cell } j.
$$

Two facts about such honest signals follow almost immediately.

> **Value is linear in the firing rate.** Whatever the signal, the expected saving of the optimal searcher who listens to it is at most $r\,(n-1)$ probes.

The reason is short. Fix the order that is best for the "no fire" beliefs $q'$. The searcher who ignores the signal can use that order too. The two searchers differ only on the fraction $r$ of games where the signal fired, and there they differ by at most $n - 1$ probes.

> **Uniform tips are capped by the lightest cell.** If, when it fires, the signal says "$J$ is uniformly spread over the window $S$ with total weight $\alpha$", then $r\alpha/W \le p_j$ for every cell $j$ in the window.

The reason: the "no fire" beliefs cannot be negative, so the prior must already hold at least $r\alpha/W$ at every window cell.

Now put the window on the right, where the min-law is thinnest. The lightest cell is the very last one, with prior probability $1/M^2$. The gate closes:

$$
r\,\alpha \;\le\; \frac{W}{M^2},\qquad \alpha\cdot(\text{expected saving}) \;<\; \frac{W}{M} \;=\; x .
$$

For $M = 512$ and $x = 1/16$, a calibrated uniform tip on the right window can fire at most about $1.2\times 10^{-4}$ of the time at full strength, and it saves less than $1/16$ of a probe on average. Blind search costs $171$ probes. **Honest uniform tips about the top of the range are worthless.** On the left, by contrast, the lightest window cell is about $1000$ times heavier, and the cap is a respectable $r\alpha \le 0.117$.

There is a broader point here. The right window is where a *trusted* tip helps most: it has the $1/x$ ceiling and the self-similar structure. It is also where an *honest* tip can say least, because the calibrated trust of the right window is just its prior mass,

$$
P(\text{right window}) = x^2,
$$

which vanishes quadratically as the window narrows. "Start at $\sqrt N$" is exactly a rightmost-interval commitment. It is a strategy that pays off when you have strong prior reason to believe the answer lies there, and whose honestly calibrated capacity goes to zero.

## Hints that say nothing about "which"

One more remark. In the two-number game there are two different questions you could get help with. *Which* of $p, q$ is the smaller? And *where* is the smaller one? An interval tip of the kind studied here gives no information at all about the first question. By symmetry, the window is equally consistent with "$p$ is smaller" and with "$q$ is smaller." Yet it changes the optimal search order completely. Information about location and information about identity are priced separately. A ceiling on what identity-type hints can buy says nothing about location-type hints.

## Checking the numbers

Several independent checks support these results. For every $M$ from $5$ to $8$, the claim that "most likely first" is optimal was confirmed by brute force over all $M!$ search orders. Simulated searchers drawing from the stated laws reproduce the exact expected costs, within the scatter expected from chance. One such simulation was useful in a less comfortable way. An early version of the calculation had the outside-window mass normalized incorrectly, and a simulated mean landing $72$ standard errors from the "exact" value exposed the slip. It is a reminder that a formula and a simulation catch different kinds of mistakes.

## The moral

Three lessons come out of one small game:

1. **Don't half-believe.** The cost of acting on a tip is concave in your trust, and for any decreasing prior there is a band of partial trust where you do worse than with no tip at all. Either commit or ignore.
2. **Aim where it's thin.** A window placed where the prior is smallest buys the full $1/x$. The same window anywhere else buys only about $2/(3x)$.
3. **But honest tips can't aim there.** Calibration ties a uniform tip's strength to the lightest cell it covers. On the right, that is $1/M^2$, and the tip's value collapses below $x$ probes.

The two-number game is tiny. The tension it shows is general: the places where a hint would help most are often the places where an honest hint has the least to say.
