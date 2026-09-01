# The Dial That Would Not Fall

## What it takes to say that a number has crossed a line

There is a certain kind of scientific disappointment that only shows up in a spreadsheet. You have a number you are watching. You have a line you decided, in advance, that the number should not cross. Week after week the number drifts toward the line. And then one day you look, and the number is $0.558$, and the line is $0.55$, and the gap is $0.008$ — and your measurement error is three times that.

Have you crossed the line, or not?

This article is about that question, and about what happens when you refuse to answer it with a shrug. It turns out that "the number is close to the line but has not crossed it" is not one statement. It is at least six, and they pull in different directions, and several of them are theorems about the geometry of shuffled lists rather than statements about data at all.

## The dial

The setting is a *dial*: a diagnostic number that measures how strongly one quantity predicts another. Concretely, we take a batch of $n$ paired observations, rank each side from best to worst, and compute the rank correlation — the classical statistic

$$\rho \;=\; 1 - \frac{6\sum_{k}(\sigma(k)-k)^2}{n(n^2-1)},$$

where $\sigma(k)$ is the rank that the item sitting in position $k$ receives on the other side. If the two rankings agree perfectly, $\sigma$ is the identity, the sum vanishes, and $\rho = +1$. If they are exactly reversed, the sum reaches its maximum $n(n^2-1)/3$, and $\rho = -1$. Everything else lies in between. This is Spearman's coefficient, and its virtue is that it is blind to how the numbers are scaled: it sees only the ordering.

Our dial is measured at a ladder of problem sizes, indexed by the bit-length of the integers involved:

| size | 44 | 52 | 64 | 72 | 76 | 84 | 92 | 96 |
|---|---|---|---|---|---|---|---|---|
| $\rho$ | 0.780 | 0.705 | 0.648 | 0.605 | 0.608 | **0.558** | 0.563 | 0.574 |

The signal is eroding as the problems grow. A floor of $0.55$ was fixed in advance: below it, the dial is declared dead. At size $84$, the pooled reading is $\rho = 0.558$, with a bootstrap interval $[0.536, 0.581]$, from three independent runs reading $0.572$, $0.578$, and $0.522$.

So: margin to the floor, $+0.008$. Not crossed. But the interval straddles the floor, one of the three runs is already below it, and the difference between "crossed" and "not crossed" is smaller than the difference between two of the runs.

The honest verdict is *approaching, but not crossed*, and the honest description of the approach is *gradual, not a cliff*. The interesting question is whether "gradual, not a cliff" can be made into mathematics.

## First: a pooled number cannot fall on its own

Start with something almost too simple to state, which nevertheless does real work. The pooled reading is a weighted average of the per-run readings. A weighted average with nonnegative weights summing to one is trapped between the smallest and largest of its inputs. So:

> **Pooled crossings require individual crossings.** If a weighted average of run-level readings falls below the floor, then at least one run reads below the floor.

And a sharper version, which is the one that matters:

> **Pooling is $1$-Lipschitz.** If every run's reading moves by at most $d$, the pooled reading moves by at most $d$.

Read the contrapositive: a pooled *cliff* — a sudden collapse of the aggregate — is only possible if some individual run also collapses by at least as much. There is no aggregation artefact that manufactures a cliff out of gently sliding components. Whatever a cliff is, it has to happen somewhere concrete.

For our data, the recorded numbers are exactly as the geometry predicts: the pooled $0.558$ lies between the lowest run ($0.522$) and the highest ($0.578$), and exactly one of the three is below the floor. The dial survives on a two-out-of-three vote.

## How fragile is that vote?

Suppose we run the experiment once more. What would the new run have to read for the pooled average of four runs to dip below $0.55$?

Solve it: $(0.572 + 0.578 + 0.522 + v)/4 < 0.55$ exactly when $v < 0.528$.

The threshold is $0.528$. The lowest reading we have already seen is $0.522$. So a single additional run, merely *replicating a value we have already observed*, tips the aggregate below the floor. Meanwhile, a run replicating the best value we have seen, $0.578$, does not rescue anything — it only stiffens the average.

The non-crossing is one unlucky repetition deep.

## The part that is not about data at all

Now for the structural core, which is where the story stops being statistics and becomes combinatorics.

Ask a naive question: *how much can a rank correlation move in a single elementary step?* The natural elementary step on rankings is the swap of two neighbours — the move that bubble sort makes, the generator of the Kendall-tau distance between orderings. If $\rho$ could plummet in a handful of swaps, "cliff" would be a coherent physical possibility. If it cannot, then gradualness is not an empirical observation about this dial; it is a law of the space the dial lives in.

Here is the exact accounting. Swap the values sitting at positions $i$ and $j$ of a ranking. The displacement sum changes by

$$\Delta\!\left(\sum_k (\sigma(k)-k)^2\right) \;=\; 2\,(j-i)\,(\sigma(j)-\sigma(i)).$$

This is an identity, not a bound: every other term in the sum cancels, and only the two touched positions contribute. Translating through the definition of $\rho$:

$$\Delta\rho \;=\; -\,\frac{12\,(j-i)\,(\sigma(j)-\sigma(i))}{n(n^2-1)}.$$

Now specialise to *neighbouring* positions, $j = i+1$, so $j - i = 1$. The two ranks being exchanged live in $\{0,1,\dots,n-1\}$, so their difference is at most $n-1$ in absolute value. Hence

$$|\Delta\rho| \;\le\; \frac{12(n-1)}{n(n^2-1)} \;=\; \frac{12}{n(n+1)}.$$

That constant is not an artefact of sloppy estimation. Take the ranking that puts the value $n-1$ in position $0$, the value $0$ in position $1$, and leaves everything else alone; swapping its first two entries moves $\rho$ by exactly $12/n(n+1)$. The bound is attained.

Chain the steps together and you get a Lipschitz law: **along any sequence of $K$ adjacent swaps, the rank correlation moves by at most $12K/n(n+1)$.** In other words, $\rho$ is a $1$-Lipschitz function of Kendall-tau distance, up to the scale $12/n(n+1)$.

Invert it, and you have a **crossing budget**:

> To push the rank correlation down across a margin $m$, you must perform at least $\dfrac{m\,n(n+1)}{12}$ adjacent swaps.

Put the numbers in. With $n = 4096$ paired samples and $m = 0.008$:

$$\frac{0.008 \times 4096 \times 4097}{12} \;>\; 11187,$$

so **at least $11188$ adjacent swaps**. That is the price of the last $0.008$. It is $\Theta(n^2)$ in the sample size: quadruple the sample and the price goes up sixteenfold.

This is the theorem behind the phrase "gradual, not a cliff." A cliff in $\rho$ would be a macroscopic, $\Omega(n^2)$-sized rearrangement of the ranking occurring between two adjacent rungs of the ladder. Nothing in the mechanics of a rank statistic permits it to happen in a few moves. Gradualness is forced by the metric geometry of the symmetric group, not observed in the data.

The same machinery pays an unexpected dividend. Since the identity ranking has $\rho = +1$ and the reversed ranking has $\rho = -1$ exactly, the Lipschitz law says reversing a list of $n$ items costs at least $2 \cdot n(n+1)/12 = n(n+1)/6$ adjacent swaps. That is a sorting lower bound — the kind normally proved by counting inversions — obtained here purely from a correlation coefficient.

And there is a second, independent budget. A single adjacent swap changes the total $\ell^1$ displacement $\sum_k |\sigma(k)-k|$ by at most $2$; after $K$ swaps starting from the identity, the $\ell^1$ displacement is at most $2K$; and the squared displacement never exceeds the square of the $\ell^1$ displacement. Combining gives

$$\rho \;\ge\; 1 - \frac{24K^2}{n(n^2-1)},$$

a bound driven by *accumulation* rather than by the size of any one step. At $n=4096$, it says that producing a reading of $0.558$ from a perfectly aligned ranking takes at least $35\,576$ swaps. The first bound, applied to the same descent from $+1$ down to $0.558$, demands at least $618\,112$. So for a drop this large the linear bound wins — but the two cross over: comparing $\varepsilon n^2/12$ with $\sqrt{\varepsilon n^3/24}$ shows the accumulation bound is the stronger one whenever the drop $\varepsilon$ from perfect alignment is below about $6/n$, that is, in exactly the small-margin regime. The crossover is a real feature of the geometry, not an artefact.

That last number puts the whole controversy in perspective. The dial has already travelled at least $618\,112$ swaps' worth of distance from perfect alignment. The remaining margin to the floor is worth about $11\,188$. The argument is over the last **1.8%** of the journey.

## The ladder does not even go down

There is a wrinkle that everything above has politely ignored. Look again at the tail of the ladder: $0.558$ at size $84$, then $0.563$, then $0.574$. It goes *up*.

Fit a straight line through those three rungs by least squares and the slope is $+0.001225$ per bit — pointing away from the floor. Extrapolate one rung further and you predict about $0.579$, nowhere near $0.55$. On the recorded evidence, the size-$84$ rung is a local minimum, and the crossing test is not merely failing to fire: it is pointing the other way.

This has a quantitative consequence for anyone who wants to model the erosion as a monotone fade. If a nonincreasing function is to fit data that rebounds by an amount $\delta$ between two points, its worst-case error is at least $\delta/2$ — the function must pass between the two, and cannot be closer than half the gap to both. Here the rebound from $0.558$ to $0.574$ is $0.0159$, so any monotone model carries an error of at least

$$\eta \;\ge\; 0.00795 \;=\; \frac{159}{160} \times 0.008.$$

Stare at that. **The unavoidable error of the monotone model is $99.4\%$ of the entire margin to the floor.** Within the class of smoothly decaying fades — the class in which "the dial is falling toward its floor" is even a meaningful sentence — the crossing question is invisible. It is buried in the model's own residual.

## The resolution wall

Could we just measure harder? Bootstrap half-widths shrink like $c/\sqrt{m}$ in the sample size $m$. To shrink a recorded half-width $h_0$ down to a target resolution $\text{mrg}$ requires at least $(h_0/\text{mrg})^2$ times the sample.

Our half-width is $0.0225$ and our margin is $0.008$, so the factor is

$$\left(\frac{0.0225}{0.008}\right)^2 = \frac{2025}{256} \approx 7.91.$$

**Nearly eight times the data** just to bring the error bar down to the size of the thing being argued about. And there is a hard limit beyond which no amount of data helps at all: if the point estimate itself sits on the wrong side of the bar, then every symmetric interval around it, however narrow, has its lower endpoint below the bar. Decisiveness is not always a sample-size problem.

## Two futures, both consistent with the past

Suppose we accept the fade picture and write $\rho_j = L + a\lambda^j$ across the rungs, with a limiting floor $L$, an amplitude $a > 0$, and a contraction factor $0 \le \lambda < 1$. Then a clean dichotomy holds: the trajectory eventually falls below the band floor **if and only if** $L$ is below the band floor. Whether the dial ever dies is a question about the limit $L$ alone — no individual rung can answer it.

And $L$ is exactly what the data does not pin down. Two explicit fades,

- $L = 0.5659$, $a = 10^{-6}$, $\lambda = 1/2$, and
- $L = 0.549$, $a = 0.017$, $\lambda = 0.998$,

both reproduce the recorded rungs at sizes $84$, $92$, $96$ to within $0.008$ — that is, to within the margin itself. The first never comes anywhere near the floor. The second crosses it, eventually, and stays across. At the resolution of its own margin, the ladder is compatible with both a dial that dies and a dial that does not.

This is the sharpest available meaning of "gradual, not a cliff." A cliff would separate the two hypotheses. A gradual slope, measured to a precision coarser than the gradient, does not.

## Two predictors, less than one degree apart

One last picture, to make the smallness visceral.

Fix a response vector $w$. Ask for two predictors: one, $u$, correlating with $w$ at exactly the recorded $0.558$; the other, $v$, correlating at exactly the floor value $0.55$. How different must $u$ and $v$ be?

Correlation is the cosine of an angle between centred vectors, and the triangle inequality for angles gives the extremal configuration: $u$ and $v$ can be as close as $\cos(\theta_u - \theta_v)$, where $\cos\theta_u = 0.558$ and $\cos\theta_v = 0.55$. Numerically,

$$\mathrm{corr}(u,v) \;\ge\; 0.558 \times 0.55 + \sqrt{(1-0.558^2)(1-0.55^2)} \;>\; 0.9999.$$

Numerically the extremal configuration gives $\mathrm{corr}(u,v) = 0.99995\ldots$, an angle of about $0.55^\circ$ — comfortably inside the certified bound $\arccos(0.9999) \approx 0.81^\circ$. The two rival hypotheses — the dial that has crossed and the dial that has not — can be realised by predictors that agree with each other to four decimal places, separated by a rotation of barely half a degree.

That is the whole controversy: a rotation you could not draw on a page.

## What the exercise is really for

None of this says the dial is fine. Two of the six analyses lean pessimistic — one run of three is already through the floor, and one replication of an observed value would tip the pool. Two lean optimistic — the ladder has turned back up and the local slope points away. Two say the question is currently unanswerable — the noise of any monotone model exceeds the margin, and eight times the data would be needed to see the difference.

What the exercise *does* produce is a discipline for the moment when a monitored number gets close to a line. Three things fall out of it, and none of them depend on this particular dataset:

1. **Aggregation is honest.** Pooled statistics inherit their cliffs from their components; they never invent one.
2. **Rank correlations cannot fall off cliffs.** A drop of $m$ costs $\Omega(m\,n^2)$ elementary rearrangements. Gradualness is a theorem about the space of rankings, not a property of any particular experiment.
3. **A margin smaller than the model's own residual is not a finding.** Before asking whether a number crossed a line, check whether your model class can even represent the distance between them.

The best result here is not a verdict. It is the realisation that the *demand* for a verdict was, at this resolution, a category error — and the precise, quantitative statement of how much better the measurement would have to be before the demand becomes reasonable. Nearly eight times the data; or a rotation of less than a degree, seen clearly.

Until then: approaching, not crossed. Gradually.
