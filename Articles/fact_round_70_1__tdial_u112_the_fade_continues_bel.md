# The Dial That Stopped Predicting

## What happens when a measurement fades, and how to prove that the fading is real

There is a particular kind of disappointment that only shows up in long experimental campaigns. You build a statistic — a *dial* — that seems to predict something. You test it, it works. You test it a little harder, it works a little less well. You test it harder still, and it works less well again. At some point you have to answer an uncomfortable question: is the dial degrading, or are you just watching noise wobble?

This article is about a case where that question was answered exactly, with theorems rather than intuition. The setting is a small, concrete data set — five numbers — and the surprise is how much rigorous structure five numbers can be made to yield.

---

## The setup: a dial, a rate, and a ladder

Pick a large integer $N$ at random. Compute a cheap arithmetic summary of it — call it $T$. In our case $T$ combines two things: how many factors of two $N$ has at the bottom (its *trailing zeros*), and the pattern of whether $N$ is a perfect square modulo a couple of small primes (its *quadratic-residue pattern*). Then run some downstream procedure on $N$ and record a performance number, the *rate*.

The question is whether $T$ predicts the rate. The natural way to measure that is the **Spearman rank correlation** $\rho$ between $T$ and rate across many draws of $N$: a number in $[-1,1]$ that is $1$ if the two rank the samples identically, $0$ if they are unrelated.

The interesting twist is that $N$ has a size, its *bit length*, and you can ask the same question at every size. That gives a **ladder**: one correlation per bit length. Here is the recorded ladder, at bit lengths $96$ through $112$, each entry pooled over three independent random seeds:

$$\rho_{96} = 0.5739,\quad \rho_{100} = 0.5436,\quad \rho_{104} = 0.5005,\quad \rho_{108} = 0.4880,\quad \rho_{112} = 0.4621.$$

The successive **steps** are

$$-0.0303,\quad -0.0431,\quad -0.0125,\quad -0.0259.$$

Two things were declared in advance, before any of these numbers existed. First, a **band floor** of $0.55$: the dial counts as a validated predictor only while its correlation stays above that line. Second, a **decisiveness bar** of $+0.05$ on the *advantage* — the amount by which $T$ out-predicts a stripped-down baseline that uses only the trailing-zero count and throws the residue pattern away.

At bit length $112$ the reading is $\rho = 0.462$ with a $95\%$ confidence interval of $[0.415, 0.508]$ (per-seed: $0.409$, $0.509$, $0.460$). The entire interval sits below $0.55$ — for the second consecutive rung. And the advantage of $T$ over the baseline is $+0.047$, interval $[0.003, 0.090]$: positive, genuinely nonzero, but for the first time below the $+0.05$ bar.

So the dial has lost its band. A correlation of $0.46$ is still enormously far from chance, which means the residue pattern really does carry per-$N$ signal at this size. But the dial is no longer a *validated* predictor there. The rest of this article is about the four sharp things one can say about that situation.

---

## First surprise: geometry pins down how similar two statistics can be

Correlations behave like angles. If you think of the centered data vectors for $T$, the baseline count $C$, and the rate $R$ as arrows in a high-dimensional space, then $\mathrm{corr}(u,v) = \cos\theta_{uv}$, the cosine of the angle between them. Three vectors have three pairwise angles, and those angles are not free: they must satisfy the **spherical triangle inequality**, exactly as the sides of a triangle drawn on a sphere do.

Written out in cosines, the constraint on three correlations $a = \mathrm{corr}(T,R)$, $b = \mathrm{corr}(C,R)$, $c = \mathrm{corr}(T,C)$ is

$$a^2 + b^2 + c^2 \le 1 + 2abc,$$

which is just the statement that the $3 \times 3$ matrix of pairwise correlations is positive semidefinite (its determinant is $1 + 2abc - a^2 - b^2 - c^2$). Complete the square in $c$ and this becomes something much more useful:

> **Theorem (Correlation triangle, sharp form).** For any three statistics with pairwise correlations $a, b, c$ as above,
> $$(c - ab)^2 \le (1-a^2)(1-b^2), \qquad\text{hence}\qquad c \le ab + \sqrt{(1-a^2)(1-b^2)}.$$

In angle coordinates $a = \cos\alpha$, $b = \cos\beta$, the right-hand side is exactly $\cos(\alpha - \beta)$, and the inequality reads $|\alpha - \beta| \le \angle(T,C)$: the angle between $T$ and $C$ is at least the difference of their angles to the rate.

Why does anyone care? Because it converts a measured *advantage* into a certificate of *dissimilarity*. If $T$ beats $C$ by $\delta$ in correlation with the rate, then $T$ and $C$ cannot be near-duplicates: two statistics whose correlation is $0.9999$ simply cannot disagree that much about anything. Earlier work in this line used the convenient but blunt bound $c \le 1 - \delta^2/2$. The sharp version above is strictly better, and there is an exact identity explaining by how much:

> **Theorem (Defect identity).** For all real $a, b$,
> $$\Big(1 - ab - \tfrac{(a-b)^2}{2}\Big)^2 - (1-a^2)(1-b^2) = \frac{(a-b)^2 (a+b)^2}{4}.$$

The left-hand side is the gap between the square of the old bound and the square of the new one, and it is a perfect square times a perfect square: always nonnegative, and zero only when $a = b$ or $a = -b$. So the old bound is *never* better, and it is tight only in those two degenerate cases. Away from them the improvement is strict.

Is the new bound the last word? Yes — no bound depending only on $a$ and $b$ can beat it, because it is attained. Put the rate along the $x$-axis in the plane, put $T$ at angle $\arccos a$ above it and $C$ at angle $\arccos b$ *below* it: three unit vectors in two dimensions realizing $\mathrm{corr}(T,R) = a$, $\mathrm{corr}(C,R) = b$, and $\mathrm{corr}(T,C) = ab + \sqrt{(1-a^2)(1-b^2)}$ exactly.

Plug in the recorded numbers, $a = 0.462$ and $b = a - 0.047 = 0.415$:

$$\mathrm{corr}(T, C) \le 0.99864, \qquad \text{versus the old certificate } 0.99889.$$

Both say the same qualitative thing — the dial and the baseline are almost, but not quite, the same statistic — and the sharp one says it strictly better. It is a small numerical gain on a big conceptual point: *an advantage is a lower bound on originality*.

---

## Second surprise: the fade cannot be fitted

The obvious story for a declining ladder is a **fade toward a floor**: the correlation decays geometrically toward some limiting value $L$ at a rate $\lambda$,

$$\rho_{k+1} = L + \lambda(\rho_k - L) + (\text{noise}).$$

Say the ladder is a *noisy affine fade with parameters* $(L, \lambda, \eta)$ if $|\rho_{k+1} - L - \lambda(\rho_k - L)| \le \eta$ at every rung. Two parameters, one noise level. How well can five numbers be fitted?

Here is the trick that answers it without ever solving for $L$. Subtract consecutive instances of the model: the floor $L$ cancels, and the **steps** $d_k = \rho_{k+1} - \rho_k$ obey

$$|d_{k+1} - \lambda d_k| \le 2\eta.$$

Divide by $d_k$: each observed step ratio $d_{k+1}/d_k$ must sit within $2\eta/|d_k|$ of the single unknown $\lambda$. Now take two different step ratios and eliminate $\lambda$ by the triangle inequality:

> **Theorem (Model-free noise floor).** For any noisy affine fade with parameters $(L,\lambda,\eta)$ and any two indices $i,j$ with $d_i, d_j \neq 0$,
> $$\left|\frac{d_{i+1}}{d_i} - \frac{d_{j+1}}{d_j}\right| \le 2\eta\left(\frac{1}{|d_i|} + \frac{1}{|d_j|}\right).$$

The left side is pure data; $L$ and $\lambda$ have vanished. Any mismatch between two observed step ratios is therefore a *lower bound on the noise* — no model fitting required.

The recorded ratios are $d_1/d_0 = 431/303 \approx 1.4224$, $d_2/d_1 = 125/431 \approx 0.2900$, $d_3/d_2 = 259/125 = 2.072$. They are wildly inconsistent with one another. The first two alone give

$$\eta \ge \frac{73943}{7340000} = 0.0100739782\ldots$$

That number is the punchline of the whole analysis. It is **$38.9\%$ of the step at bit length 112 itself** — the step being $0.0259$ — and about $80\%$ of the step at bit length 108. Any single-$(L,\lambda)$ fade story for this ladder needs noise so large that it swallows the very features one is reading off the ladder. The "plateau at bit length 108" that a previous rung's small step seemed to show, and the "re-acceleration" that bit length 112 seems to show, are both below the model's own resolution. At the recorded precision, *the shape of the fade is not identifiable*.

And this bound is exactly attained — it is not an artefact of a crude elimination. There is a genuine best fit,

$$\lambda^\star = \frac{278}{367} \approx 0.7575, \qquad L^\star = \frac{725197}{1780000} \approx 0.40741,$$

whose four residuals against the recorded ladder are

$$+\eta^\star, \quad -\eta^\star, \quad +\eta^\star, \quad -0.006357, \qquad \eta^\star = \frac{73943}{7340000}.$$

Three residuals of equal size and alternating sign. That pattern is the classical **Chebyshev equioscillation** signature, and it certifies optimality by a beautifully simple sign argument. Changing the parameters from $(L,\lambda)$ to $(L',\lambda')$ changes each residual by an *affine function of the rung value* $\rho_k$ — a straight line. If a competitor kept every residual strictly smaller in magnitude than $\eta^\star$, that straight line would have to be negative where the residual was $+\eta^\star$, positive where it was $-\eta^\star$, negative again at the next $+\eta^\star$. But the three rungs involved are strictly decreasing, and a straight line evaluated along a monotone sequence cannot go negative, positive, negative. Contradiction. So $\eta^\star$ is the exact minimal noise of the record: $0.0100739782\ldots$, no more and no less.

---

## Third surprise: the band is lost permanently, and the local fit blows up

Two consequences follow, and they point in opposite directions in a way that is itself informative.

First, **the band loss is structural, not transient.** For any nonnegative contractive fade — $0 \le \lambda < 1$ — a single declining step already forces the floor down: $L \le \rho_{k+1} + \eta/(1-\lambda)$. With $\lambda \le 1/2$ and $\eta \le 0.02$ (a window that comfortably contains the true minimal noise $0.01007$, so the hypothesis is not vacuous), the rung at bit length 112 gives $L \le 0.5021 < 0.55$. The model's own limit is out of band. And the optimal fit says it unconditionally: $L^\star \approx 0.40741$, more than $0.14$ below the band floor, and below every rung ever recorded on this ladder.

Second, **the local fit at bit length 112 is not a fade at all.** Fit the last three rungs $(0.5005, 0.4880, 0.4621)$ with a geometric model and you get ratio $259/125 = 2.072 > 1$. That is *expansive*. The Aitken extrapolation of those three points is $686295/1340000 \approx 0.51216$, which lies *above* all three rungs it was fitted from — it is a repelling fixed point, not a limit. Locally, the data at bit length 112 does not describe a decay toward anything.

Taking that expansive local fit seriously predicts $\rho_{116} \approx 0.408435$ for the next rung. The next rung was subsequently measured: $\rho_{116} = 0.4847$. The miss is $95331/1250000 \approx 0.0763$ — more than **seven times** the minimal noise level $\eta^\star$. The expansive fit is not merely unlucky; it is refuted at the very resolution the experiment supports. (The globally optimal contractive fade did better, predicting $0.4488$ for a miss of $0.036$, but the recorded ladder then resumed falling to $0.43636$ at bit length $120$ — so even the rebound was local.)

---

## Fourth surprise: more data would not have helped

The final observation is the most deflating and the most useful. The advantage of $T$ over the baseline is $+0.047$, and the bar is $+0.05$. It is tempting to say: run more seeds, tighten the interval, clear the bar.

You cannot. A confidence interval for a fixed point estimate $c$ has the form $[c - w/\sqrt{m}, \; c + w/\sqrt{m}]$ for a sample size $m$. If $c < B$ then $c - w/\sqrt{m} < B$ for *every* $m \ge 1$ and *every* $w \ge 0$: the lower endpoint approaches $c$ from below and never crosses the bar. Shrinking an interval moves its endpoints toward its center; it cannot move the center.

> **Theorem (Decisiveness is a location problem).** If the point estimate lies strictly below the bar, no sample size makes the interval decisive. Reaching the bar requires shifting the estimate itself — here by at least $0.003$.

This does, however, cleanly separate two questions that are easy to conflate. The interval $[0.003, 0.090]$ **excludes zero**: the residue pattern genuinely beats the trailing-zero count. The same interval **contains** $0.05$: the advantage is not decisive. Significance and decisiveness are logically independent, and the five-rung record is a clean example of one without the other.

---

## Where the signal lives

If the dial's coupling to the downstream rate fades with bit length, is it because the dial itself is losing information at large sizes? No — and this can be settled by pure arithmetic, with no experiment at all.

Take two distinct odd primes $p \ne q$, and for an integer $x$ invertible modulo $pq$, let $T(x) \in \{0,1,2\}$ count how many of $p, q$ see $x$ as a quadratic residue. Then:

- At an odd prime $p$, exactly half of the nonzero residues are squares: $2\,|QR(p)| = p-1$. (This is the vanishing of the quadratic-character sum, or equivalently the two-to-one nature of squaring on the multiplicative group.)
- The residue bits at $p$ and at $q$ are **exactly independent**, by the Chinese Remainder Theorem: for coprime moduli, the number of $x \bmod pq$ whose two reductions satisfy prescribed conditions is the product of the two separate counts.
- Hence each of the four patterns (residue/non-residue at each prime) occurs exactly $(p-1)(q-1)/4$ times, and $T$ has the exact **Binomial$(2, 1/2)$** law: the level counts are in the ratio $1 : 2 : 1$.
- Consequently $T$ has mean exactly $1$ and **variance exactly $1/2$** — written without division, $2\sum_x (T(x)-1)^2 = (p-1)(q-1)$ over the invertible residues.

That last identity is uniform in $p$ and $q$, and therefore uniform in the bit length of $N$. The dial's own information content is exactly two fair bits, always, at every size. So the fade cannot be blamed on the dial degrading. Whatever is fading lives on the *rate* side of the pair: it is the coupling, not the signal, that is thinning out.

---

## The moral

Five numbers, honestly analyzed, turn out to support four theorems and refute two stories. They refute "the fade is decelerating into a plateau" (the plateau is below the noise floor). They refute "the ladder is locally decaying toward a floor" (the local fit is expansive, and its prediction missed by seven noise units). They establish that the band loss is permanent under any contractive model, and that the shortfall in decisiveness cannot be bought with more compute.

The most transferable idea here is the **model-free noise floor**. Everyone knows that a two-parameter model fitted to five points will fit *something*. Far fewer pipelines ask the prior question: *how much noise does the fit require?* Eliminating the parameters between two observed step ratios answers that with a single line of algebra, and the answer here — noise equal to $39\%$ of the effect being measured — settles a debate that no amount of squinting at the curve could have settled.

The dial is not dead. A correlation of $0.46$ is a real signal, and the arithmetic guarantees the signal is there at every bit length. But at bit length $112$ it is no longer a *validated* predictor, and now we know exactly why, exactly how much noise the data carries, and exactly what it would take to change the verdict.
