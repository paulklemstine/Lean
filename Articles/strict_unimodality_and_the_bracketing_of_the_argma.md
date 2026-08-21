# Where Is the Biggest Term? A Complete Answer, Down to the Last Tie

## A question every student asks once

Expand $(p+q)^n$. You get $n+1$ terms,

$$w_k \;=\; \binom{n}{k}\, p^k q^{\,n-k}, \qquad k = 0, 1, \dots, n,$$

and they do something visually satisfying: they climb, they reach a summit, they fall. Draw them as a bar chart and you get the familiar bell-shaped silhouette that appears everywhere from quality control to quantum statistics.

Now ask the obvious question: **which bar is the tallest?**

Everybody "knows" the answer. Somewhere around $k \approx np/(p+q)$. Most textbooks say this much and move on, occasionally adding a parenthetical caveat: *"and sometimes two adjacent terms tie."* That parenthetical is where the interesting mathematics lives. When exactly do two terms tie? Can three tie? Can the tie happen at a place you didn't expect? And is $np/(p+q)$ actually the right centre, or is it off by a little?

The answer, it turns out, is completely clean — and the correct centre is *not* $np/(p+q)$. It is

$$\theta \;=\; \frac{(n+1)\,p}{p+q},$$

a number we will call the **mode parameter**. Everything about the summit — its location, whether it is a single peak or a two-bar plateau, how it moves when you change $n$ or $p$ — is determined by this one real number and by two elementary operations on it: rounding down and rounding up.

The purpose of this article is to tell that story, and to explain why the same story is really about a much more general phenomenon: any sequence that is *strictly log-concave* has a summit trapped between two explicitly computable indices, and the two indices can differ by at most one.

## Two indices that trap the summit

Let $a_0, a_1, \dots, a_n$ be positive numbers. Define two indices by scanning left to right.

- The **lower bracketing degree** $d^-$ is the first index $k \le n$ at which the sequence stops rising *strictly*: the smallest $k$ with $a_{k+1} \le a_k$, capped at $n$ if no such $k$ exists.
- The **upper bracketing degree** $d^+$ is the first index $k \le n$ at which the sequence starts *strictly falling*: the smallest $k$ with $a_{k+1} < a_k$, again capped at $n$.

The definitions differ only in the strictness of one inequality, so $d^- \le d^+$ always. Between them sits the summit — but for a completely arbitrary positive sequence, "between them" could be an enormous, wild region. The sequence might oscillate; the summit might not even be in the interval.

The magic ingredient that tames everything is *strict log-concavity*:

$$a_k \, a_{k+2} \;<\; a_{k+1}^2 \qquad \text{whenever } k + 2 \le n.$$

Equivalently, the points $(k, \log a_k)$ lie in **strictly concave position** — each one lies strictly above the chord joining its two neighbours, so all of them are vertices of their upper convex hull. Equivalently again: the ratios

$$r_k \;=\; \frac{a_{k+1}}{a_k}$$

are **strictly decreasing**. That last formulation is the engine of the entire theory, and it makes the mechanism transparent. A sequence rises exactly while $r_k > 1$ and falls exactly once $r_k < 1$. Because the ratios only ever decrease, the sequence can cross the line $r = 1$ once and only once. It goes up, then it goes down, and it can never change its mind.

From this simple observation everything follows.

**The Bracketing Theorem.** *For a strictly log-concave positive sequence on $\{0, 1, \dots, n\}$:*

1. *$d^- \le d^+ \le d^- + 1$: the two bracketing degrees differ by at most one.*
2. *$d^+ = d^- + 1$ exactly when $d^- < n$ and $a_{d^-} = a_{d^-+1}$ — that is, exactly when the summit is a genuine two-term plateau.*
3. *The set of indices at which the sequence attains its maximum is precisely the interval $\{d^-, d^-+1, \dots, d^+\}$. Strictly below $d^-$ the sequence is strictly increasing; strictly above $d^+$ it is strictly decreasing.*

Part 1 is where strict log-concavity earns its keep. Suppose the top were a flat run of three: $a_d = a_{d+1} = a_{d+2}$. Then $a_d a_{d+2} = a_{d+1}^2$, in flat contradiction with the strict Newton inequality. So plateaus of length three or more are impossible, and the maximiser set — an interval, by the up-then-down structure — has at most two elements. A strictly log-concave sequence has a summit that is either a lone peak or a pair of twins, never a mesa.

## The threshold mechanism: turning the brackets into formulas

Knowing that the summit is trapped in a window of width at most one is nice. Knowing *where that window is* is better. Here is the observation that converts the abstract theorem into explicit arithmetic.

In every naturally occurring example, the question "does the sequence rise at step $k$?" has an answer of a remarkably rigid form: it rises exactly when $k$ is smaller than some fixed real number. Call the sequence a **threshold window with threshold $\theta$** when, for all $k < n$,

$$a_k < a_{k+1} \iff k + 1 < \theta, \qquad\qquad a_k \le a_{k+1} \iff k + 1 \le \theta,$$

with $0 < \theta < n+1$. The two conditions differ only in strictness, and that tiny difference is exactly what encodes the possibility of a tie.

**The Threshold Theorem.** *For a threshold window with threshold $\theta$,*

$$d^- = \lceil \theta \rceil - 1, \qquad d^+ = \lfloor \theta \rfloor,$$

*and consequently*

$$d^+ = d^- + 1 \iff \theta \in \mathbb{Z}.$$

The proof is a two-line rounding argument. The sequence rises at $k$ precisely while $k+1 < \theta$, i.e. while $k+1 \le \lceil \theta \rceil - 1$; the first index where the strict rise stops is therefore $\lceil \theta \rceil - 1$. It fails to fall at $k$ precisely while $k+1 \le \theta$, i.e. while $k + 1 \le \lfloor \theta \rfloor$; the first strict fall is at $\lfloor \theta \rfloor$. And for a real number $\theta$, $\lceil \theta \rceil$ and $\lfloor \theta \rfloor$ agree if and only if $\theta$ is an integer.

That last equivalence is the punchline of the whole subject. **The comparison of the two bracketing degrees is exactly the question "is $\theta$ a whole number?"** Ties at the top are not mysterious coincidences; they are integrality statements about a single explicit real parameter.

There is a pleasant intuition here. Think of $\theta$ as a marker sliding along the real line. The peak of the sequence is the integer nearest below $\theta$. When $\theta$ sits strictly between two integers, one integer wins and the maximiser is unique. When $\theta$ lands exactly on an integer, the marker is equidistant from "before" and "after", and the two neighbouring terms tie.

## The binomial case, fully explicit

Now run the machine on $w_k = \binom{n}{k}p^kq^{n-k}$ with $p, q > 0$.

**Step 1: Pascal's rows are strictly log-concave.** For $k + 2 \le n$,

$$\binom{n}{k}\binom{n}{k+2} \;<\; \binom{n}{k+1}^2 .$$

This follows from the single elementary identity $\binom{n}{k+1}(k+1) = \binom{n}{k}(n-k)$. Writing $n = k+2+m$ and applying the identity twice gives

$$\binom{n}{k+1}^2 (k+1)(m+1) = \binom{n}{k}\binom{n}{k+2}(m+2)(k+2).$$

Since $(m+2)(k+2) > (m+1)(k+1)$, the claimed strict inequality drops out. Multiplying by the positive factors $p^k q^{n-k}$ preserves it, so the binomial weights form a strictly log-concave window, and all three parts of the Bracketing Theorem apply to them.

**Step 2: the rise criterion.** The consecutive ratio is

$$\frac{w_{k+1}}{w_k} = \frac{n-k}{k+1}\cdot\frac{p}{q},$$

and $w_k < w_{k+1}$ holds exactly when $(n-k)p > (k+1)q$, which rearranges to

$$k + 1 \;<\; \frac{(n+1)p}{p+q} \;=\; \theta .$$

So the binomial weights are a threshold window with threshold $\theta = (n+1)p/(p+q)$ — a genuine threshold, since $0 < \theta < n+1$ whenever $p, q > 0$. The weak criterion $w_k \le w_{k+1} \iff k+1 \le \theta$ is the same computation with $<$ replaced by $\le$.

**Step 3: read off everything.**

$$\boxed{\;d^- = \left\lceil \frac{(n+1)p}{p+q}\right\rceil - 1, \qquad d^+ = \left\lfloor \frac{(n+1)p}{p+q}\right\rfloor\;}$$

and the largest term of $(p+q)^n$ is attained exactly at the indices $k$ with $d^- \le k \le d^+$. The peak is a two-term plateau if and only if $(n+1)p/(p+q)$ is an integer.

Note that the natural centre is $(n+1)p/(p+q)$, not $np/(p+q)$: the "$+1$" is not a rounding artefact but the exact content of the criterion. For a fair coin with $n = 5$, $\theta = 3$ is an integer, and indeed $\binom{5}{2} = \binom{5}{3} = 10$ tie for the maximum. For $n = 4$, $\theta = 5/2$ is not an integer, and $\binom{4}{2} = 6$ is the unique champion.

**Step 4: arithmetic corollaries.** If $p = P$ and $q = Q$ are positive integers, then $\theta = (n+1)P/(P+Q)$ is an integer exactly when

$$(P+Q) \mid (n+1)P,$$

a purely arithmetical divisibility test for the existence of a tie. For the classical case $P = Q = 1$ this specialises beautifully:

$$d^- = \left\lfloor \frac n2 \right\rfloor, \qquad d^+ = \left\lceil \frac n2 \right\rceil = \left\lfloor \frac{n+1}{2}\right\rfloor,$$

and the binomial coefficients $\binom{n}{0}, \dots, \binom{n}{n}$ have a two-term plateau at the top **exactly when $n$ is odd** — the familiar fact that odd rows of Pascal's triangle have twin central entries, now derived as a special case of an integrality criterion rather than as a symmetry accident.

## How big is the biggest term?

Once you know *where* the peak is, a one-line pigeonhole tells you roughly *how big* it is. The $n+1$ weights sum to $(p+q)^n$, and every one of them is at most the peak value $w_{d^-}$. Hence

$$\frac{(p+q)^n}{n+1} \;\le\; w_{d^-} \;\le\; (p+q)^n .$$

The largest term of a binomial expansion therefore carries at least a $1/(n+1)$ share of the total. This crude-looking sandwich is exactly the estimate behind many entropy and large-deviation arguments: on a logarithmic scale, $\log w_{d^-} = n\log(p+q) + O(\log n)$, so the maximal term already determines the exponential growth rate of the whole sum.

## The peak as a moving target

Because the brackets are just roundings of $\theta$, understanding how the summit moves is the same as understanding how $\theta$ moves. Two clean statements govern this.

**Monotonicity.** If two threshold windows have thresholds $\theta \le \theta'$, then both of their bracketing degrees satisfy $d^-\le d^{-\prime}$ and $d^+ \le d^{+\prime}$. Rounding is monotone, so the peak can only move right when the threshold moves right. Concretely: increasing the success weight $p$ (with $q$ fixed) never moves the mode of the binomial weights to the left, because $\theta = (n+1)p/(p+q)$ is increasing in $p$.

**The staircase bound.** If $\theta' < \theta + 1$, then $d^{-\prime} \le d^- + 1$ and $d^{+\prime} \le d^+ + 1$. A sub-unit change in the threshold can move each bracketing degree by at most one step. Applied to $n \mapsto n+1$, where $\theta$ increases by exactly $p/(p+q) < 1$, this says: **adding one trial moves the mode by zero or one, never more.** The mode of the binomial weights, viewed as a function of $n$, is a monotone unit staircase.

## Every degree can be the champion

Here is a consequence of strict log-concavity that deserves to be better known. Fix $n$ and any degree $d \le n$. Then there is a weight $p > 0$ making $d$ the *unique* maximiser of $k \mapsto \binom{n}{k}p^k$.

Take $\theta = d + \tfrac12$ and solve $(n+1)p/(p+1) = \theta$, i.e. $p = \theta/(n+1-\theta)$, which is positive because $0 < \theta < n+1$. Then $\lceil \theta \rceil - 1 = d = \lfloor \theta \rfloor$, so both brackets land on $d$, and since $\theta$ is a half-integer there is no tie: $d$ is the strict, unique champion.

Geometrically this says that all $n+1$ points $(k, \log \binom{n}{k})$ are vertices of their upper convex hull — none is hidden underneath the others. Tilting the picture by the linear function $k \log p$ picks out each vertex in turn. As $\theta$ sweeps continuously across $(0, n+1)$, the argmax sweeps through every degree $0, 1, \dots, n$, pausing to tie precisely at the integers. That is the same picture combinatorialists draw when they speak of Newton polygons, and the same picture statisticians draw when they speak of exponential families and their tilting.

## The same story in a different key: Poisson

The threshold mechanism is not special to binomials. Consider the Poisson weights

$$u_k = \frac{\lambda^k}{k!}, \qquad \lambda > 0,$$

the terms of the series for $e^{\lambda}$. Their ratio is $u_{k+1}/u_k = \lambda/(k+1)$, so

$$u_k < u_{k+1} \iff k + 1 < \lambda .$$

The threshold *is* the parameter. They are strictly log-concave, since $(k+1)!^2 < k!\,(k+2)!$. Therefore

$$d^- = \lceil \lambda \rceil - 1, \qquad d^+ = \lfloor \lambda \rfloor,$$

and the Poisson weights tie at the top exactly when $\lambda$ is a positive integer — the textbook statement "the Poisson mode is $\lfloor\lambda\rfloor$, with a tie at $\lambda - 1$ when $\lambda$ is an integer", now a corollary of a single general theorem rather than a separate calculation.

And because binomial and Poisson brackets are both roundings of thresholds, they can be compared *directly*. Take the classical Poisson scaling $p = \lambda/n$, $q = 1 - \lambda/n$ with $0 < \lambda < n$, so that the expected number of successes is $\lambda$. The binomial threshold is then

$$\theta = \frac{(n+1)(\lambda/n)}{1} = \lambda + \frac{\lambda}{n},$$

which exceeds the Poisson threshold $\lambda$ by less than $1$. Monotonicity and the staircase bound instantly give

$$d^+_{\text{Poisson}} \;\le\; d^+_{\text{binomial}} \;\le\; d^+_{\text{Poisson}} + 1 .$$

The binomial mode is never below the Poisson mode and never more than one above it — a sharp, non-asymptotic version of the Poisson limit theorem, at the level of modes, proved without a single limit.

## Why this is the right way to think about it

There is a moral in this development, and it is about where the content of a theorem really lies.

"The binomial weights are unimodal" is an easy theorem. "The maximum is attained on an interval of indices" is an easy theorem. What is *not* free — what all the classical treatments blur into a parenthetical remark — is the **explicit comparison of the two bracketing degrees**: the statement that they differ by at most one, together with a computable criterion telling you exactly which of the two cases you are in. Once that comparison is made precise, ties stop being folklore and become arithmetic: $\theta \in \mathbb{Z}$, or in integer parameters, $(P+Q) \mid (n+1)P$, or in the fair-coin case, $n$ odd.

The theory also isolates precisely what was needed. The upper bracket $d^+ = \lfloor \theta \rfloor$ came from the *weak* criterion, the lower bracket $d^- = \lceil \theta \rceil - 1$ from the *strict* one; the gap between the two is the gap between $\le$ and $<$, made numerical. Nothing about binomials or factorials was used except to identify $\theta$. Any family of weights whose rise criterion crosses a threshold once — hypergeometric, negative binomial, and beyond — inherits the whole package for free, with only the computation of its own $\theta$ left to do.

That is the pleasant surprise hiding behind a question every student asks once: the tallest bar in the bell curve is not merely "around $np$". It is exactly $\lfloor (n+1)p/(p+q) \rfloor$, it is unique unless that number is a whole number, and when it is not unique it is a tie of exactly two — never three.
