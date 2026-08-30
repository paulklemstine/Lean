# When Averaging Stops Working: The Half-Amplitude Floor

## A fading signal that refused to fade

Some measurements decay toward zero. Others decay toward something else, and the difference matters enormously.

Here is a concrete situation. An experiment tracks a single number as a control parameter is dialled up, rung by rung. The number is a rank correlation — a measure, between $-1$ and $1$, of how strongly one quantity tracks another. Across six successive rungs it read

$$0.5739 \;\to\; 0.5436 \;\to\; 0.5005 \;\to\; 0.4880 \;\to\; 0.4621 \;\to\; 0.4847 .$$

Five steps down, and then, for the first time, a step *up*: $+0.0226$. A small number. But its sign is not small, and its sign is the whole story.

Two competing narratives had been circulating. The first: the signal is simply dying. Each rung is at most some fixed fraction $q < 1$ of the previous one, so the sequence slides inexorably to zero, and any apparent uptick is a mirage. The second: the signal is not dying but *settling* — approaching a positive floor $L$ from above, with each rung pulled a fixed fraction of the way toward $L$ and jostled by measurement noise. Something like $\rho_{k+1} - L \approx \lambda(\rho_k - L)$, plus noise of size at most $\eta$.

The first narrative can be dismissed on the spot, and by pure logic rather than statistics. If $\rho_{k+1} \le q\rho_k$ with $q \le 1$ and the readings are nonnegative, then $\rho_{k+1} \le \rho_k$ always: **no step can ever be positive**. One observed positive step refutes the multiplicative-fade story outright, no matter how small the step is and no matter how noisy the instrument. The rebound is not a decoration. It is a proof.

So the floor story it is. And the natural next question — the one this article is about — is: *how precisely can we locate the floor?*

## The estimator that should have worked

Suppose the readings really are $\rho_k = L + s_k$, where $L$ is the floor we want and $s_k$ is a residual we do not control but do know something about: it is bounded, $|s_k| \le \eta$, and it changes sign from time to time, because that is exactly what "rebound" means. Group the rungs into maximal runs of constant residual sign; call these *blocks*. Block $1$ is (say) positive with $n_1$ rungs, block $2$ negative with $n_2$ rungs, and so on, alternating, for $m$ blocks in all.

The oldest trick in the book is to average. Average all the rungs and hope the positive residuals cancel the negative ones. This fails badly when the blocks are lopsided: if a positive block has $100$ rungs and the negative one has $3$, a plain average is dominated by the positive side and inherits nearly the full bias $\eta$. Precisely: the plain mean's worst-case error is $\eta\max(A,B)/(K+1)$, where $A$ and $B$ are the total lengths of the two alternating families of blocks and $K+1$ is the number of rungs. When the pattern is unbalanced, that quantity does not go to zero however long you watch.

The obvious repair is *block-balanced reweighting*. Do not let a long block shout down a short one: give every rung in a block of length $n_i$ the weight $1/n_i$, so each block contributes total weight exactly $1$. The estimator becomes the average of the $m$ block means,

$$\widehat{L} \;=\; \frac{1}{m}\sum_{i=1}^{m}\frac{S_i}{n_i}, \qquad S_i = \text{sum of the residual-carrying readings in block } i .$$

Now every block gets an equal vote. The blocks alternate in sign. Surely the votes cancel, and surely the error decays like $1/m$ as more blocks accumulate. The conjecture on the table was a clean $2\eta/m$.

It is false. Not off by a constant — false in a way that no amount of data repairs.

## Why the cancellation never happens

Here is the mechanism, and it is embarrassingly simple once seen.

Each block mean $S_i/n_i$ inherits two facts from the residuals inside it: its absolute value is at most $\eta$, and its sign is the sign of its block. That is *all* it inherits. In particular a negative block is only required to be somewhere in $[-\eta, 0]$ — and $0$ is in that interval.

So consider an adversary building the worst possible data set. Every positive block saturates: its mean is exactly $+\eta$. Every negative block is allowed to be zero, so the adversary sets it to zero. Nothing is violated: all residuals are bounded by $\eta$, and the sign pattern still alternates (weakly). But now nothing cancels. The estimator equals

$$\frac{1}{m}\Big(\underbrace{\eta + 0 + \eta + 0 + \cdots}_{m \text{ blocks}}\Big) \;=\; \frac{\eta\lceil m/2\rceil}{m},$$

because $\lceil m/2 \rceil$ of the $m$ blocks are positive ones. And $\lceil m/2\rceil/m \ge 1/2$ for every $m$. The error sits at half the amplitude and stays there forever.

This is the sharp truth, in both directions. On the one hand every admissible data set obeys

$$\bigl|\widehat{L} - L\bigr| \;\le\; \frac{\eta\lceil m/2\rceil}{m},$$

and — a small surprise inside the result — the *block lengths have vanished from the bound entirely*. Only the number of blocks appears. On the other hand the alternating-saturation ladder above attains that bound exactly. So $\eta\lceil m/2\rceil/m$ is not a proof artefact; it is the worst case.

Comparing with the conjecture: at $m = 5$ the true worst case is $3\eta/5 = 0.6\eta$ while the conjecture promised $2\eta/5 = 0.4\eta$. From five blocks onward the conjecture is not merely optimistic, it is wrong, and the gap widens without limit: the truth tends to $\eta/2$ while $2\eta/m$ tends to $0$.

## It is not the weights' fault

A natural reflex is to blame the choice $1/n_i$ and go looking for cleverer weights. That reflex can be shut down completely.

Take *any* nonnegative weights $w_1,\dots,w_m$ on the blocks that sum to $1$, and consider two data sets: the one above (positive blocks saturate at $+\eta$, negative blocks vanish) and its mirror image (negative blocks saturate at $-\eta$, positive blocks vanish). The estimator returns some nonnegative number $P$ on the first and $-N$ on the second, where $P$ and $N$ are nonnegative and — because every weight is used exactly once, on one side or the other — satisfy $P + N = \eta$. Two nonnegative numbers summing to $\eta$ cannot both be below $\eta/2$. So on one of the two data sets the weighted estimator errs by at least $\eta/2$.

**No weighting of the blocks beats half the amplitude.** Not the balanced one, not the length-proportional one, not any hand-tuned one; and this holds for every number of blocks, however large.

## It is not even linearity's fault

Perhaps averaging of any kind is the wrong tool, and some cleverer nonlinear procedure escapes. It does not, and the reason is information rather than algebra.

Write down the single ladder of readings

$$x_k \;=\; \begin{cases} L + \eta, & k \text{ even},\\ L, & k \text{ odd}. \end{cases}$$

This one ladder is a perfectly legal realisation of *two different floors*. Read with floor $L$, its residuals are $\eta, 0, \eta, 0, \dots$ — bounded by $\eta$, alternating in the weak sense. Read with floor $L + \eta$, its residuals are $0, -\eta, 0, -\eta, \dots$ — also bounded by $\eta$, also alternating. The data are literally identical; the two hypotheses are $\eta$ apart.

Any procedure whatsoever — linear, nonlinear, measurable or not, Bayesian, adversarially trained, whatever you like — sees only $x$, so it outputs a single number $y$. Then $|y - L|$ and $|y - (L+\eta)|$ cannot both be smaller than $\eta/2$, since the two targets are $\eta$ apart. **Every estimator errs by at least $\eta/2$ on one of the two worlds.** The half-amplitude barrier is not a defect of any method; it is the resolution of the data.

And the barrier is exactly attained — by an estimator so simple it feels like a joke. The *midrange*: take the largest reading in the window and the smallest, and average those two.

$$\widehat{L}_{\text{mid}} \;=\; \frac{\max_k x_k + \min_k x_k}{2}.$$

Since all readings lie in $[L - \eta, L + \eta]$, the max is at most $L+\eta$ and the min is at least $L-\eta$; and provided the window contains at least one positive-block rung and one negative-block rung, the max is at least $L$ and the min is at most $L$. Averaging the two brackets $L$ within $\eta/2$. Always.

So the picture closes exactly. The minimax error of floor estimation under bounded alternating rebound noise is *precisely* $\eta/2$: no procedure does better, weighted means all do worse or equal at best, and the midrange — which throws away every data point except two — does exactly as well as the theoretical optimum.

## The one place the decay survives

There is a salvage, and it identifies the real hidden hypothesis behind the failed conjecture.

Suppose the residuals do not merely satisfy $|s| \le \eta$ but have *exact* amplitude $\eta$: every rung sits exactly $\eta$ away from the floor, on the side dictated by its block, so residuals are $+\eta, +\eta, \dots, -\eta, -\eta, \dots$ alternating block by block. Then each block mean is exactly $(-1)^{i}\eta$ — no slack, nothing for the adversary to zero out. The alternating sum $\eta - \eta + \eta - \cdots$ telescopes to $0$ or $\eta$, and the block-balanced estimator satisfies

$$\bigl|\widehat{L} - L\bigr| \;\le\; \frac{\eta}{m}$$

for *any* block lengths whatsoever. The conjectured decay is real — but only in the saturated world.

This is the sharpest way to state the lesson. Put the two side by side at the same number of blocks, the same block lengths, the same amplitude bound $\eta$:

$$\text{bounded residuals: error can be } \ge \frac{\eta}{2}; \qquad \text{exactly saturated residuals: error } \le \frac{\eta}{m}.$$

The gap grows without bound. So "how big is the noise?" is the wrong question to ask of a rebound ladder. The right question is "is the noise saturated?" A bound of $\eta$ tells you almost nothing; an *equality* of $\eta$ tells you everything. Noise that is allowed to be small at inconvenient moments is far more damaging than noise that is reliably large, because reliably large noise cancels and slack noise does not.

## Back to the dial

Return to the six readings. The single positive step measured $+0.0226$, and in the floor picture a positive step of size $\delta$ in a non-expanding fade sitting above its floor forces the noise level to satisfy $\eta \ge \delta$. So the rebound itself certifies $\eta \ge 0.0226$.

Feed that into the barrier. Whatever block structure the residuals have, however many blocks accumulate as more rungs are recorded, the worst-case error of the block-balanced floor estimate is at least

$$\frac{\eta}{2} \;\ge\; \frac{0.0226}{2} \;=\; 0.0113 .$$

The floor of this dial cannot be pinned to better than $\pm 0.0113$ by any weighted-average reading of the ladder — and, by the information-theoretic version, not by any procedure at all in the worst case. Remarkably, this reproduces a bound obtained earlier along a completely different route: a separate analysis of the fade model, which showed that two candidate floors $L_1, L_2$ are indistinguishable at noise $\eta$ precisely when $|1-\lambda|\,|L_1 - L_2| \le 2\eta$, gives the same resolution $\pm 0.0113$ from the same rebound. One argument is analytic and knows about the contraction ratio $\lambda$; the other is combinatorial and never mentions it. They agree to the digit.

That agreement is reassuring in a specific way. The experiment pre-registered a floor window $[0.46,\,0.49]$ — width $0.03$ — before seeing the data. The theory says a window of width about $0.023$ is the best that could honestly be claimed. The pre-registration was not over-claiming; it was, if anything, slightly conservative. A two-sided fit of the recorded rungs puts the floor at about $0.474$, comfortably inside the window, and a plain three-rung average puts it at about $0.478$ — two structurally different estimators agreeing to within $0.004$ inside a window whose width the theory independently certifies.

## The moral

The instinct that more data averages away error is one of the deepest in quantitative science, and it is usually right. The results here mark out precisely where it fails: when your error is *bounded* rather than *known*, and when the structure you are exploiting for cancellation — alternating signs — constrains only the direction of the error and not its magnitude, then the adversary can simply decline to push back. Every second block goes silent, and the average never converges.

What remains is not despair but a change of target. The half-amplitude floor is a real, computable, sharp resolution limit, and one knows exactly how to attain it: two numbers, the largest and the smallest reading, averaged. Beyond that limit no procedure can go, and knowing where the wall is has a practical payoff. It tells an experimenter that collecting more rungs of the same ladder will not sharpen the floor, and that the only way to sharpen it is to shrink $\eta$ — to make the instrument quieter — or to change the experiment so that the residuals become saturated rather than merely bounded.

Knowing that averaging cannot help is, in its way, as useful as knowing that it can.
