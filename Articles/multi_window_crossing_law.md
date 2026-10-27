# How Many Hints Does It Take? The Geometry Hidden in a Search Oracle

*A lost key, a nervous detective, and a single number that decides whether advice is worth anything at all.*

---

## The detective and the row of lockers

Picture a row of $M$ lockers. One of them holds a stolen diamond. You can open them one at a time, and every locker you open costs you a minute. If you know nothing, the best you can do is open them in any order; on average you will spend about $M/2$ minutes.

Now an informant leans in. "It's in the first ten," she whispers. "I'm right about that half the time. And if it isn't in the first ten, it's in the first thirty — I'm right about *that* five times out of six."

That is an oracle with **nested windows**: a sequence of ever-wider stretches $[0, w_1) \subset [0, w_2) \subset \dots \subset [0, w_k)$ at the start of the row, each labelled with a **cumulative reliability** $\alpha_1 \le \alpha_2 \le \dots \le \alpha_k$, the probability that the diamond lies inside that window. Forecasters, search engines, triage nurses and debugging tools all speak this way: "probably here; almost certainly somewhere around here."

Two questions follow at once.

1. **How should you search?** Should you trust the informant and sweep left to right, or hedge?
2. **How much does the advice buy you?** If you want to be $s$ times faster than some reference price, which combinations of widths and reliabilities make that possible?

The answers turn out to be remarkably clean. The second one is governed by a single number, the *gate functional* $\Phi$, which is just one minus an area under a curve. Whether a speedup is reachable is decided by whether $\Phi$ falls below $1/(3s)$. This is the **multi-window crossing law**.

---

## Turning words into a probability picture

The informant's statements carve the row into blocks. Block 1 is the first window $[0, w_1)$. Block 2 is the part of the second window not already covered, $[w_1, w_2)$. And so on, up to block $k$. And there is one more block that people tend to forget: the **complement** $[w_k, M)$, everything outside the widest window.

The mass of each block is the *jump* in reliability. Block $i$ holds probability $\alpha_i - \alpha_{i-1}$ (with $\alpha_0 = 0$), and the complement holds whatever is left over, $1 - \alpha_k$.

With no further information, the honest thing to do is spread each block's mass evenly over its lockers. The result is a staircase-shaped probability distribution called the **step posterior**. In our example with $M = 6$ lockers, windows of widths $1$ and $3$, and reliabilities $1/2$ and $5/6$, the six lockers receive probabilities

$$\tfrac12,\ \tfrac16,\ \tfrac16,\ \tfrac1{18},\ \tfrac1{18},\ \tfrac1{18}.$$

---

## The cost of a search order

A **search order** is a ranking of the lockers: which one you open first, second, and so on. If the diamond is in a locker you rank in position $t$, you pay $t$ minutes. The expected cost is

$$\text{cost} = \sum_{\text{lockers } j} (\text{position of } j)\times(\text{probability of } j).$$

The most natural strategy is **committed search**: believe the informant and open the lockers left to right. With a step posterior its cost has a tidy form. Inside block $i$ the positions run consecutively, so their average is the block's **mean slot**, the midpoint of its first and last positions. That gives

$$\text{committed cost} = \sum_{\text{blocks}} (\text{block mass}) \times (\text{mean slot of the block}).$$

In the example the blocks occupy positions $\{1\}$, $\{2,3\}$, $\{4,5,6\}$, with mean slots $1$, $5/2$, $5$ and masses $1/2$, $1/3$, $1/6$. The committed cost is

$$\tfrac12\cdot 1 + \tfrac13\cdot\tfrac52 + \tfrac16\cdot 5 = \tfrac{13}{6} \approx 2.17$$

minutes. Blind search would cost $7/2$.

---

## Is trusting the informant actually optimal?

There are $6! = 720$ ways to order six lockers. Is committed search the cheapest of them? In the example, yes: an exhaustive check shows that no order beats $13/6$. Exactly $12$ orders tie it, namely the ones that shuffle lockers *within* a block but never put a later block ahead of an earlier one.

The general reason is a slicing argument known as the **layer-cake principle**. Think of the staircase posterior as a stack of horizontal slabs. Each slab covers an initial stretch of lockers, called an *upper set*, and its thickness is the drop in density from one step to the next. The cost of any order splits slab by slab:

$$\text{cost} = \sum_{\text{slabs}} (\text{slab thickness}) \times (\text{sum of the positions given to that slab's lockers}).$$

A set of $m$ lockers can never be given positions that sum to less than $1 + 2 + \dots + m = m(m+1)/2$, and it reaches that minimum exactly when those lockers are opened first. Committed search does this for every slab at once. So:

> **Bayes-optimality.** If the oracle is *calibrated*, meaning its blocks get less dense as you move outward, then committed search has the smallest expected cost among all $M!$ orders.

The calibration condition matters. Suppose the informant says "the first half, with reliability $1/10$" for six lockers. The first half is then *less* likely than the second, the densities increase, and sweeping left to right costs $47/10$. Sweeping right to left costs only $23/10$. An anti-calibrated hint should be read backwards, and the clean theory needs the calibration assumption.

---

## The price of a speedup and the crossing law

To talk about speedups we need a yardstick. The pricing convention used here charges a reference amount

$$\beta_M = \frac{(M+1)(2M+1)}{6M} = \frac{1}{M^2}\sum_{k=1}^{M} k^2 \;\approx\; \frac{M}{3},$$

and an order achieves speedup $s$ when $s \times \text{cost} \le \beta_M$.

Now rescale the row to the unit interval, so that window boundaries become fractions $x_i = w_i/M$. Define the **gate functional**

$$\Phi \;=\; \sum_{\text{blocks}} (\alpha_{i} - \alpha_{i-1})\cdot\frac{x_{i-1} + x_{i}}{2},$$

where the sum includes the complement block, which runs from $x_k$ to $x_{k+1} = 1$ and has mass $1 - \alpha_k$. In words, $\Phi$ is the block mass times the block midpoint, summed over all blocks. The first main result says that $\Phi$ is exactly the committed cost in disguise:

$$\text{committed cost} = M\,\Phi + \tfrac12 .$$

Combined with Bayes-optimality, this gives an exact criterion.

> **The multi-window crossing law (exact form).** For a calibrated oracle on $M$ lockers, some search order achieves speedup $s$ if and only if
> $$s\,\bigl(M\Phi + \tfrac12\bigr) \le \beta_M .$$

As $M$ grows, $\beta_M/(M\Phi + c)$ tends to $1/(3\Phi)$ for every fixed offset $c$. The finite criterion therefore settles into a strikingly simple continuum law:

> **The multi-window crossing law (continuum form).** Speedup $s$ is reachable if and only if
> $$\Phi \;\le\; \frac{1}{3s}.$$

In the worked example, $\Phi = 5/18$. The best finite speedup at $M = 6$ is $(91/36)/(13/6) = 7/6$. Scaling the same picture up to $M = 60, 600, 6000$ lockers pushes the best speedup to about $1.1943$, $1.1994$ and $1.19994$, closing in on $1/(3\Phi) = 6/5$.

The condition is *linear* in the reliabilities. For fixed window widths, the profiles $(\alpha_1, \dots, \alpha_k)$ that reach speedup $s$ are cut out by a single linear inequality on top of the ordering constraints. The gate is a polyhedron, and in particular a convex set: if two informants each deliver speedup $s$, any blend of their reliability claims does too.

---

## The picture: it's all an area

The most satisfying view of $\Phi$ is geometric. Plot the informant's claims as points $(x_i, \alpha_i)$ in the unit square: start at $(0,0)$, pass through each window $(x_1,\alpha_1), \dots, (x_k,\alpha_k)$, and end at $(1,1)$. Join the dots with straight segments. This is the **reliability curve**: how much probability you have covered after searching a given fraction of the row.

A short telescoping calculation (an "integration by parts" for polygons) shows that

$$\Phi + \text{AUC} = 1,$$

where AUC is the area under the reliability curve. So the law can be restated in a form that anyone who has seen a ROC curve will recognise:

> **Area form.** Speedup $s$ is reachable if and only if the area under the reliability curve is at least $1 - \dfrac{1}{3s}$.

A useless oracle gives the diagonal, with area $1/2$ and speedup $2/3$ under this pricing. A perfect oracle hugs the top-left corner. Every hint is worth exactly the area it adds.

---

## One window: the classical law comes back

With a single window of width $w$ and reliability $\alpha$, the curve has one kink. The area form reduces to

$$w \;\le\; \alpha - \alpha_{\min}(s), \qquad \alpha_{\min}(s) = 1 - \frac{2}{3s}.$$

This is the classical **single-window crossing law**. A window is worth having only if its reliability beats a threshold by at least its own width. A narrow, confident window crosses the bar; a wide, vague one does not. For $s = 1$ the threshold is $\alpha_{\min} = 1/3$. For $s = 2$ it climbs to $2/3$.

The multi-window law reduces to this classical statement when there is just one window, and extends it to any number of nested windows.

---

## What extra windows can and cannot do

**More windows help exactly when they bend the curve upward.** Insert a new point $(x', \alpha')$ between two neighbouring corners $(x_\ell, \alpha_\ell)$ and $(x_r, \alpha_r)$. The gate functional changes by exactly

$$\Delta\Phi = -\frac{(x_r - x_\ell)\,\bigl(\alpha' - \text{chord}(x')\bigr)}{2},$$

where $\text{chord}(x')$ is the height of the straight line joining the two neighbours at $x'$. This is just the area of the triangle that the new point adds or removes. A new window helps if it sits above the chord, does nothing if it lies on it, and hurts if it lies below.

**More reliability always helps; more width always hurts.** Raising any $\alpha_i$ while holding the widths fixed lowers $\Phi$. Widening any window while holding the reliabilities fixed raises $\Phi$.

**Inner windows cannot rescue a weak outer window.** No matter how many sharp, reliable inner windows the informant offers, reaching speedup $s$ forces the widest window's reliability $\alpha_k$ to satisfy

$$\alpha_k \;\ge\; \alpha_{\min}(s) + w_k\,(1 - \alpha_k),$$

which is strictly above $\alpha_{\min}(s)$ whenever the window has positive width and is not certain. The reason is the complement block. Whatever the informant leaves outside the widest window must be searched after everything inside it, and that tail alone can sink the speedup.

---

## The block everyone forgets

It is tempting to state the law using only the windows the informant actually named, adding up $(\alpha_i - \alpha_{i-1}) \times$ midpoint over blocks $1$ through $k$ and leaving out the complement. That version is **false**. Take one window covering half the row with reliability $1/10$, and ask for $s = 1$. The truncated sum is $1/40$, comfortably below $1/3$, so it says "yes". The true gate functional is $7/10$, and the honest answer is "no". The $90\%$ of probability the informant left outside the window carries most of the cost.

The lesson extends beyond mathematics. When you judge a forecast, the part it is silent about counts as much as the part it states.

---

## Why this matters

Nested confidence windows are everywhere: weather cones of uncertainty, ranked search results, nested differential diagnoses, "the bug is probably in this module, certainly in this subsystem." The multi-window crossing law gives a single, checkable criterion for when such advice is worth a target speedup. It is linear in the claims and convex in the space of oracles, it can be read off as an area, and it is sharp at every finite size. It also tells an oracle designer what to aim for: push the reliability curve up and to the left, add windows only where they bend the curve above its chords, and never neglect the tail.

From a whisper in a detective's ear to an inequality about areas, the advice is worth exactly what it adds to the picture.
