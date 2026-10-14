# Does the Dial Still Point North? Calibrating a Prediction Across Scale

*How four slopes, two $R^2$ values and a t-statistic can be read exactly, and what that reading tells us about a sieve that is growing up.*

---

## A compass taken to new territory

Suppose you build a compass in your backyard and tune it until it points true north. Then you carry it a hundred miles away. Does it still work? Maybe it points a few degrees off. Maybe it shakes so much that a single reading means little. Maybe the land itself is different and pulls the needle in ways the backyard never did. Each of these failures looks different. Each needs a different fix.

Number theorists who study sieves face this same question all the time. A sieve is a procedure for finding *smooth* numbers among many candidates. A number is smooth when all its prime factors are small. Smooth numbers are the raw material of the fastest known methods for factoring large integers. Every candidate a sieve examines is a *value*, and every smooth value it finds is a *relation*. How many relations come out per unit of work is the *yield*. The yield depends on the number being factored, call it $N$, in ways that are only partly understood.

The experiment behind this article built a predictor for that yield: a **footprint-weighted yield dial**. It looks at the set of small primes that are "active" for a given modulus $N$, meaning the primes that can divide the sieved values. It combines them into one number,

$$S_\alpha(N) \;=\; \sum_{\ell \in \operatorname{supp}(N)} \ell^{-\alpha},$$

where $\alpha > 0$ is a tuning exponent. This is the dial. Small primes contribute a lot and large primes contribute little. The exponent $\alpha$ sets how sharply the dial favours the very smallest primes.

The dial was fitted on moduli of 44 bits. Then it was carried, unchanged, to 48 and 52 bits. The question was the compass question: **does the dial still point north?**

## The headline numbers

Here is what the experiment reported. For each target size, and for two sieve depths (80 values per modulus and 240 values per modulus), it regressed the observed yield on the dial's transferred prediction and recorded the slope of the fitted line. This number is the **calibration slope**. A perfectly calibrated predictor has slope exactly $1$: if it predicts one extra unit of yield, one extra unit shows up on average.

| target size | 80 values / $N$ | 240 values / $N$ |
|---|---|---|
| 48 bits | 0.896 | 0.912 |
| 52 bits | 0.834 | 0.834 |

All four slopes fell inside the pre-agreed acceptance band. The experiment also tracked a second feature, the *direct divisibility* indicator $d(N)$. It stayed statistically significant after the dial's effect was removed, in all twelve cells of the study, with the smallest absolute t-statistic equal to $3.92$. And the fraction of yield variance explained, the familiar $R^2$, rose a lot with sieve depth. In one representative cell (smoothness parameter $u = 2.5$, 48 bits) it went from $0.41$ at 80 values to $0.60$ at 240.

"In band" is a pass mark, not an explanation. The real interest is in what these numbers *force*. Taking each claim seriously and following the algebra to the end gives some surprisingly sharp conclusions.

## Lesson one: slopes below one are what honesty looks like

Start with the slopes being below one. You might read that as a flaw. It is actually what an honest transfer should look like, and the reason is one of the oldest results in statistics: **errors-in-variables attenuation**.

Think of the dial's prediction $x$ as the true signal $s$ plus some prediction noise $e$. Think of the observed yield $y$ as a multiple $c\cdot s$ of the same signal plus yield noise $\eta$. The number $c$ is the *scale factor*. If the dial's units carry over perfectly to the new size, $c = 1$. If the territory has shifted, $c \neq 1$. Now assume only that the signal and the two noises are pairwise uncorrelated in the sample. Then an exact identity holds for every finite data set:

> **Attenuation Law.** The calibration slope equals
> $$\text{slope} \;=\; \frac{c\,V}{V+E},$$
> where $V$ is the variance of the signal and $E$ is the variance of the prediction noise.

This is not an approximation and not a large-sample limit. It follows from bilinearity of the covariance and nothing else. Two consequences follow at once. If the scale is right ($c = 1$), the slope lies between $0$ and $1$. It equals $1$ **exactly when the prediction is noiseless**. Every real predictor has some noise, so every honest calibration slope sits a little below one. A slope of $0.9$ is the expected signature of a noisy but correctly scaled predictor.

## Lesson two: the coincidence at 52 bits

Now look at the 52-bit row: $0.834$ and $0.834$. The slope did not move when the sieve depth tripled.

That matters, because prediction noise comes in two kinds. Part of it is *fixed*: structure the dial simply misses, whatever the sieve depth. Call its variance $E_0$. The other part is *sampling noise*: the yield of a modulus is estimated from finitely many values, and the error shrinks as more values are used. With $m$ values per modulus its variance is $\sigma/m$. So the attenuated slope depends on the depth as

$$\text{slope}(m) \;=\; \frac{c\,V}{V + E_0 + \sigma/m}.$$

This curve can only rise as $m$ grows: more relations never hurt calibration. And it is *strictly* rising unless $\sigma = 0$. That gives an exact conclusion:

> **Stable-Slope Theorem.** If the calibration slope is the same at two different relation counts, the relation-count noise vanishes: $\sigma = 0$.

So at 52 bits, inside this model, the gap $1 - 0.834$ is not noise that more sieving could remove. It is a combination of fixed prediction noise and **scale drift**: the dial's units have shifted between 44 and 52 bits. At 48 bits the slope did move ($0.896 \to 0.912$), so some sampling noise is present there. At 52 bits it is not. The coincidence is the first cell in which the two possible causes of miscalibration come apart. It is the compass that points steadily a few degrees off, rather than one that shakes.

## Lesson three: a ceiling you can compute from two points

The $R^2$ values tell a different story, and the algebra is just as tight. Model the in-cell yield the same way. It is the true signal (variance $V$), plus a fixed *structural residual* the dial cannot see (variance $F$), plus sampling noise ($\sigma/m$). Then

$$R^2(m) \;=\; \frac{V}{V+F+\sigma/m}.$$

The key move is to turn this curve upside down:

$$\frac{1}{R^2(m)} \;=\; \Bigl(1 + \frac{F}{V}\Bigr) + \frac{\sigma}{V}\cdot\frac1m.$$

**The reciprocal of $R^2$ is a straight line in $1/m$.** Two points determine a line, so two sieve depths determine the whole curve. That includes its limit as $m \to \infty$, the **ceiling**

$$\text{ceiling} \;=\; \frac{V}{V+F},$$

which $R^2$ approaches but never reaches. The two-point formula reads

$$\frac{1}{\text{ceiling}} \;=\; \frac{m_2/R_2 - m_1/R_1}{m_2 - m_1}.$$

Put in the measured cell: $(m_1, R_1) = (80, 0.41)$ and $(m_2, R_2) = (240, 0.60)$. The answer comes out exact:

$$\text{ceiling} = \frac{82}{105} \approx 0.781, \qquad \frac{\sigma}{V} = \frac{3800}{41}\approx 92.7.$$

The predictions are just as concrete. In this cell, $R^2 \ge 0.70$ holds **if and only if** $m \ge 53200/85 \approx 625.9$. So **626 values per modulus is the exact threshold**: 625 falls just short and 626 just clears it. No sieve depth, however large, lifts the cell to $R^2 = 0.79$, because the ceiling is below that.

## Lesson four: why pure noise cannot be the whole story

A tempting explanation for the jump from $0.41$ to $0.60$ is "it is all sampling noise; more data simply averages it away". The model can test this. If there were no structural residual ($F = 0$), the curve would follow the classical **Spearman–Brown prophecy formula** from psychometrics. Tripling the relation count turns reliability $R$ into

$$\frac{3R}{1 + 2R}.$$

With $R = 0.41$ that predicts $1.23/1.82 \approx 0.676$, well above the observed $0.60$. In general, Spearman–Brown is an *upper bound* on the model's curve. It is attained exactly when $F = 0$. Since the data fall strictly below it, **a structural floor $F > 0$ is forced**. Part of the unexplained yield variance is something the dial cannot see, no matter how much you sieve.

This changes how to read the gap between the slope column (about $0.9$) and the $R^2$ column ($0.41$–$0.60$). One more exact identity explains it:

> **Slope–$R^2$ Factorisation.** With uncorrelated prediction noise and yield noise of variance $H$,
> $$R^2 \;=\; \text{slope}\times\frac{V}{V+H}.$$

So $R^2$ is never larger than the slope. The ratio between them is the *reliability of the yield measurement itself*. A low $R^2$ next to a slope near one does not mean the dial is miscalibrated. It means the yield is noisy. When the yield is measured without noise, the slope and $R^2$ are the same number.

## Lesson five: what a t-statistic does (and does not) promise

The divisibility feature $d(N)$ stayed significant in all twelve cells. To check that this is a real effect beyond the dial, we use the **Frisch–Waugh–Lovell theorem**. In a regression on both the dial and $d(N)$, the coefficient of $d(N)$ is *exactly* the simple slope of the yield on the part of $d(N)$ that the dial cannot explain, that is, its residual after regressing on the dial. So $d(N)$ carries independent signal **if and only if** that residual is correlated with the yield.

How large is the effect? A t-statistic turns into an effect size through the dictionary

$$\text{partial } R^2 \;=\; \frac{t^2}{t^2 + \mathrm{df}},$$

where df is the residual degrees of freedom (number of observations minus the three fitted parameters: intercept, dial and $d(N)$). With $|t| \ge 3.92$:

- at 80 values per modulus (df $= 77$), $d(N)$ explains at least $3.92^2/(3.92^2+77) \approx 0.1664$ of the remaining yield variance;
- at 240 values per modulus (df $= 237$), the same $|t|$ guarantees only about $0.061$.

Two warnings come out of this. First, the threshold falls strictly as the degrees of freedom grow. So "significant in every cell" is a *weaker* effect-size statement at the larger depth, not a sign that $d(N)$ matters more. Second, it is tempting to round the df $=77$ bound up to "more than one sixth". That is false: the exact value is $1372/8247 \approx 0.16636$, a hair under $1/6 \approx 0.16667$. Careful bookkeeping catches errors like this.

## The tropical horizon

Why "tropical"? Look again at the dial $S_\alpha(N) = \sum \ell^{-\alpha}$. Take a logarithm and divide by $\alpha$:

$$\frac{1}{\alpha}\log S_\alpha(N).$$

As $\alpha \to \infty$, the sum is dominated by its largest term, the one from the smallest active prime. This normalised log-dial converges to

$$-\log \min \operatorname{supp}(N).$$

This is the familiar passage from ordinary arithmetic to **tropical (min-plus) arithmetic**: sums become minima and products become sums. The "log-sum-exp" smoothly approaches a hard minimum.

There is an exact statement here too. As long as the limiting statistic varies across moduli and the yield is not constant, the $R^2$ of the normalised log-dial converges to the $R^2$ of the min-plus statistic. The explanatory power of the dial varies continuously all the way to its tropical endpoint. This makes $\alpha$ a real *dial* between a smooth "footprint" summary of all active primes and a crude "smallest active prime" summary. One natural conjecture, still open, is that the best setting lies strictly inside. Our numerical illustration shows exactly that pattern: on simulated data, the $R^2$ peaks at a moderate $\alpha$ and then settles down to the tropical value.

## Why invariance matters

One more fact ties the story together. If you rescale the dial affinely, $x \mapsto a + bx$ with $b \neq 0$, the calibration slope is divided by $b$, but **$R^2$ does not change at all**. This is why the two numbers play different roles. $R^2$ is scale-free and can be compared across sizes without recalibrating. The slope carries the scale, so it is the number that detects scale drift. A study that wants to know whether its predictor still points north should watch the slope. A study that wants to know how much of the yield the predictor can *ever* explain should compute the ceiling from $R^2$.

There is also a lesson about definitions. Any "ceiling" column in a table should mean the limit $\lim_{m\to\infty} R^2(m) = V/(V+F)$, identified by the two-point formula. An alternative column computed under a different convention cannot be compared with it. For the representative cell, the consistent value is $82/105$.

## What happens next

The algebra makes predictions that new experiments can check:

1. **The 626 test.** Rerun the $u = 2.5$, 48-bit cell at 626 values per modulus and at 600. If the model's form is right, the first should reach $R^2 \approx 0.70$ and the second should fall just short (sampling error aside).
2. **A scale-drift law.** If the 52-bit deficit is pure drift, the slope should stay independent of sieve depth at all larger sizes, and its logarithm might be linear in the number of extra bits.
3. **A universal ceiling.** Since $R^2$ is scale-free, the ceiling might be a property of the dial and not of the size. Computing it at several bit lengths costs almost nothing.
4. **Tropical dominance.** Is the interior setting of $\alpha$ always strictly better than the min-plus endpoint?

In every case the compass question has become something you can calculate. Four slopes, two $R^2$ values and one t-statistic, read exactly, separate noise from drift, fix a ceiling, set a threshold of 626 values, and rule out the explanation that seemed most natural.
