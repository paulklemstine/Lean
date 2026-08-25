# The Dial That Kept Falling

## What a fading correlation is really telling you

There is a number that a certain long-running experiment reports every time it is
run at a larger scale. Call it the *dial reading*. It measures how strongly a
simple structural statistic — the number of trailing zeros in the binary
expansion of a randomly chosen integer — predicts a downstream quantity that the
experiment actually cares about. The reading is a rank correlation, so it lives
in $[-1, 1]$, and larger means "the statistic tells you more".

Over a sweep of increasing bit lengths the dial has read

$$0.5739 \;\to\; 0.5436 \;\to\; 0.5005 \;\to\; 0.4880 \;\to\; 0.4621 \;\to\; (0.4847) \;\to\; 0.43636 .$$

Five steps down, then one puzzling step *up* — the parenthesised rung, a rebound
of $+0.0226$ — and then a plunge of $-0.0483$ that erased the rebound and went
well below where the trend had been heading. The latest reading, $0.43636$, comes
with a confidence interval $[0.38815, 0.48113]$, and the spread between
individual random seeds has widened to $0.082$.

So: was the rebound real? Is there a *floor* — some positive level below which
the dial can never fall, because the statistic genuinely carries that much
information no matter how large the numbers get? And is the fall even about the
statistic at all, or could it be an artefact of how the experiment averages
across seeds?

These are not questions about this one experiment. They are questions about
what a pooled correlation *is*. It turns out each of them has a clean, exact
mathematical answer, and the answers connect to each other in a way nobody
expected at the start: **a floor on the dial is exactly a ceiling on capacity.**

---

## Pooling is not averaging

Start with the most basic misconception. An experiment runs $m$ independent
seeds. Each seed $k$ produces a block: a vector $u_k$ of statistic values and a
vector $v_k$ of response values, both in $\mathbb{R}^n$. Each block has its own
correlation
$$\rho_k = \frac{\langle u_k, v_k\rangle}{\lVert u_k\rVert\,\lVert v_k\rVert}.$$

To report one number, the experiment concatenates all the blocks and correlates
the long vectors. That is the **pooled correlation**
$$\rho_{\text{pool}} = \frac{\sum_{k} \langle u_k, v_k\rangle}
{\sqrt{\sum_k \lVert u_k\rVert^2}\;\sqrt{\sum_k \lVert v_k\rVert^2}} .$$

Almost everyone reads $\rho_{\text{pool}}$ as some kind of average of the
$\rho_k$. It is not. Concatenation is a geometric operation, not an averaging
one, and it distorts in a specific direction.

**No-inflation theorem.** *The pooled reading never exceeds the largest per-seed
reading:* $\rho_{\text{pool}} \le \max_k \rho_k$.

The proof is one inequality applied twice. Blockwise,
$\langle u_k, v_k\rangle \le R \lVert u_k\rVert \lVert v_k\rVert$ with
$R = \max_k \rho_k$; then the Cauchy–Schwarz statement
$\sum_k \sqrt{a_k}\sqrt{b_k} \le \sqrt{\textstyle\sum_k a_k}\sqrt{\textstyle\sum_k b_k}$
converts the sum of blockwise bounds into the pooled denominator. Nothing about
concatenation can manufacture correlation.

The reverse inequality is *false*, and spectacularly so. Take two one-dimensional
blocks: $u = (1, 1)$ and $v = (1, 2)$, read as two blocks of length one. Each
block has correlation exactly $1$ — a scalar is perfectly correlated with any
positive multiple of itself. But the pooled reading is
$$\frac{1\cdot 1 + 1 \cdot 2}{\sqrt{1^2+1^2}\,\sqrt{1^2+2^2}} = \frac{3}{\sqrt{10}} \approx 0.9487 < 1 .$$

Two perfectly correlated seeds pool to less than perfect. The culprit is
*imbalance*: the second block's response is twice as long relative to its
statistic as the first block's. Pooling punishes heterogeneity, and it punishes
it downwards, always.

This immediately hands a sceptic an argument: maybe the whole recorded fade is
imbalance. Maybe every seed is reading as high as ever and the seeds have merely
drifted apart in scale. To rebut that you need to know *exactly* how much
attenuation a given amount of imbalance can buy.

---

## The exact price of imbalance

Measure imbalance by the ratio $\lambda_k = \lVert v_k \rVert / \lVert u_k \rVert$
of the two block norms. If every $\lambda_k$ equals a common $\lambda$, the
blocks are *balanced*, and then pooling really is an average: the pooled reading
is the energy-weighted mean $\sum_k \lVert u_k\rVert^2 \rho_k / \sum_k \lVert u_k\rVert^2$,
so it does sit between $\min_k \rho_k$ and $\max_k \rho_k$. The distortion is
entirely the fault of the spread in $\lambda$.

**Sharp seed-imbalance law.** *Suppose every seed reads at least $\rho \ge 0$ and
every ratio lies in a window $[\alpha, \beta]$ with $\alpha > 0$. Then*
$$\rho_{\text{pool}} \;\ge\; \rho \cdot \frac{2\sqrt{\alpha\beta}}{\alpha+\beta}.$$

The constant $2\sqrt{\alpha\beta}/(\alpha+\beta)$ is the ratio of the geometric
to the arithmetic mean of the window — the classical Kantorovich constant. Its
appearance here is not decorative; it is exactly right, and the proof is two
lines. For $\lambda$ in the window, $(\lambda - \alpha)(\beta - \lambda) \ge 0$,
i.e. $\lambda^2 \le (\alpha+\beta)\lambda - \alpha\beta$ pointwise. Summing
against weights and rearranging turns the whole inequality into the assertion
that a certain perfect square, $\big((\alpha+\beta)M - 2\alpha\beta S\big)^2$, is
nonnegative. That is the entire content.

The bound is attained: two blocks with ratios $1$ and $4$, each reading $1$,
pool to exactly $2\sqrt{4}/5 = 4/5$. And it strictly beats the crude bound
$(1-\delta)/(1+\delta)$ that a naive argument gives on a symmetric window,
because $\sqrt{1-\delta^2} > (1-\delta)/(1+\delta)$ whenever $0 < \delta < 1$.

Now feed in the record. The recorded seed ratios sit inside a $\pm 10\%$ window,
$\lambda_k \in [1, 1.21]$. The worst-case attenuation there is
$2\sqrt{1.21}/2.21 = 2.2/2.21 > 0.9954$ — a loss of less than half a percent. So
if every seed had merely *held* at the previous rung's value $0.4847$, the pooled
reading could not have fallen below $0.4824$. It fell to $0.43636$. **The step
was not a pooling artefact.** To blame imbalance you would need a ratio window
with $\beta/\alpha \ge 2.54$; to blame it for the entire fall from $0.5739$ you
would need $\beta/\alpha \ge 4.71$, a nearly five-fold spread in seed scales.
Nothing in the record is remotely that wide, and
the claim is falsifiable by measuring the per-seed norms.

---

## Only one profile is ever that bad

The imbalance bound is worst-case. How special does a seed profile have to be to
actually suffer the worst case? Completely special, it turns out.

**Rigidity.** *Write the seed weights as a probability distribution $w$ on the
ratios $\lambda_k \in [\alpha, \beta]$. Equality in the sharp bound forces two
things at once: every seed sits at an endpoint of the window,
$w_k(\lambda_k - \alpha)(\beta - \lambda_k) = 0$ for all $k$; and the mean ratio
is pinned at the harmonic mean, $(\alpha+\beta)\sum_k w_k \lambda_k = 2\alpha\beta$.
For a nondegenerate window $\alpha < \beta$ the endpoint masses are then unique:
mass $\beta/(\alpha+\beta)$ at $\alpha$ and $\alpha/(\alpha+\beta)$ at $\beta$.
That distribution does attain the bound, so the extremiser is unique.*

The proof is a single exact identity for the *slack* — the gap between the two
sides of the inequality:
$$(\alpha+\beta)^2 M^2 - 4\alpha\beta\, Q
= \big((\alpha+\beta)M - 2\alpha\beta\big)^2
+ 4\alpha\beta \sum_k w_k(\lambda_k - \alpha)(\beta - \lambda_k),$$
where $M = \sum_k w_k \lambda_k$ and $Q = \sum_k w_k \lambda_k^2$. Both summands
on the right are nonnegative. So the slack is zero exactly when both vanish —
which is precisely the two conditions. The identity is not a trick to prove one
theorem; it is a decomposition of failure-to-be-extremal into its two independent
causes.

The operational corollary is sharp: **one** seed with positive weight whose ratio
lies strictly inside the window already forces strict inequality. Real seed
profiles are never perfectly polarised at the endpoints, so real profiles never
suffer the worst case.

And because the identity is an equality, not just an implication, it is also a
*metric*. If a profile misses the bound by at most $\varepsilon$, then
$$\sum_k w_k \cdot \operatorname{dist}\big(\lambda_k, \{\alpha,\beta\}\big)
\;\le\; \frac{\varepsilon}{2\alpha\beta(\beta-\alpha)},
\qquad
\Big| \sum_k w_k\lambda_k - \frac{2\alpha\beta}{\alpha+\beta} \Big|
\;\le\; \frac{\sqrt{\varepsilon}}{\alpha+\beta} .$$
Near-extremal profiles are near the extremiser, quantitatively, and setting
$\varepsilon = 0$ recovers rigidity exactly. On the recorded window $[1, 1.21]$,
a slack of $0.001$ pins the profile within weighted $L^1$ distance $0.002$ of the
endpoints.

---

## Was the rebound real?

Now the rebound. Here the relevant fact is embarrassingly simple, and that is
the point: it means the question has a definite answer.

If all the seed readings behind a pooled value lie in a window of width $s$,
then the pooled value lies in that same window (it is a convex combination once
the blocks are balanced). Contrapositively, if two pooled readings differ by more
than $s$, the two seed windows cannot be the same window; if they differ by more
than $2s$, the two families of seed readings are entirely disjoint. And a step
*smaller* than $s$ carries no information at all: for any step size $t \le s$
there exist two weightings of two seed families inside one common window of width
$s$ whose pooled values differ by exactly $t$.

The recorded seed spread is $s = 0.082$. The rebound step is $+0.0226$ and its
retrace is $-0.0483$; both are smaller than $0.082$. **Each is realisable inside
a single unchanged seed window, so neither is evidence of anything.** The
cumulative fall $0.5739 \to 0.4364$, on the other hand, is $0.1375 > 0.082$, and
therefore cannot be accommodated in one window. The trend is signal; the wiggle
is noise. That is exactly what the record claims, and now it is a theorem rather
than an intuition.

---

## Every advantage is a certificate of independence

A side question the experiment cares about: the trailing-zero statistic beats a
plain count baseline by $+0.0752$ at the point estimate. What does an advantage
*buy* you?

Suppose two statistics read $a$ and $b$ against a shared response, and their
mutual correlation is $c$. Positive-semidefiniteness of the $3\times 3$
correlation matrix says $a^2 + b^2 + c^2 \le 1 + 2abc$. From that alone,
$$(a-b)^2 \le 2(1-c), \qquad\text{equivalently}\qquad c \le 1 - \tfrac{1}{2}(a-b)^2 .$$

**Any measured advantage is automatically a certificate of decorrelation.** Two
statistics that read very differently against the same response cannot be nearly
the same statistic. The bound is sharp as a statement about $c$ alone: for every
$c < 1$ there are explicit vectors in the plane realising correlation $c$ and
advantage exactly $\sqrt{2(1-c)}$.

But once you know *both* readings you can do better. The same Gram condition is
*equivalent* to the ellipse inequality $(c - ab)^2 \le (1-a^2)(1-b^2)$ — an
identity, $1 - a^2 - b^2 - c^2 + 2abc = (1-a^2)(1-b^2) - (c-ab)^2$, makes this
transparent — giving
$$c \le ab + \sqrt{(1-a^2)(1-b^2)}.$$
And this always dominates the advantage certificate, because
$ab + \sqrt{(1-a^2)(1-b^2)} \le 1 - \tfrac12 (a-b)^2$ is nothing but AM–GM applied
to $1-a^2$ and $1-b^2$, with equality precisely when $|a| = |b|$. So the
advantage bound is exactly the AM–GM relaxation of the ellipse bound: sharp when
you know only the gap, lossy when you know the two readings. At the recorded
values $(a, b) = (0.43636, 0.36116)$ the advantage certificate gives
$c \le 0.99718$ and the ellipse certificate gives $c \le 0.9967$.

---

## Floor equals capacity ceiling

Now the punchline, and the reason all of this hangs together.

There is a classical constraint on how many statistics can *simultaneously* read
high against a shared response. If $k$ mutually decorrelated (orthonormal)
statistics all read at least $\rho$, then $k\rho^2 \le 1$. High readings are a
scarce resource: you cannot have many of them at once.

Turn that around and define the **capacity of a reading**:
$$\operatorname{cap}(\rho) = \left\lfloor \frac{1}{\rho^2} \right\rfloor,$$
the number of mutually decorrelated statistics that can all read at level $\rho$.
Capacity is *antitone*: as the dial fades, capacity grows. A falling dial is not
purely a loss — it is a licence to hold more independent signals at that level.
On the record,
$$\operatorname{cap}(0.5739) = \lfloor 3.0362 \rfloor = 3,
\qquad \operatorname{cap}(0.43636) = \lfloor 5.2518 \rfloor = 5 .$$
The recorded ladder is a strict capacity expansion, from three decorrelated
statistics to five.

Two conversion lemmas connect the two languages: $\rho \le 1/(K+1)$ forces
$\operatorname{cap}(\rho) \ge K$, and conversely $\operatorname{cap}(\rho) \ge K \ge 1$
forces $\rho^2 \le 1/K$. And then the two halves of the main theorem:

**Capacity–fade duality.**
*(a) If a ladder fades persistently and multiplicatively — $\rho_{k+1} \le q\,\rho_k$
for some fixed $q < 1$, with all $\rho_k > 0$ — then for every level $K$ there is
a rung $N$ with $\operatorname{cap}(\rho_N) \ge K$: the capacity is unbounded.*
*(b) Conversely, if the capacity never exceeds $K$, then every rung satisfies
$\rho_N^2 > 1/(K+1)$: the ladder has a genuine positive floor.*

Direction (a) is geometric decay: $\rho_k \le q^k \rho_0 \to 0$ passes below every
threshold, in particular below $1/(K+1)$. Direction (b) is the definition of the
floor function run backwards: $\operatorname{cap}(\rho_N) \le K$ means
$1/\rho_N^2 < K+1$.

So "the dial has a positive floor" and "the dial's capacity is bounded" are not
two hypotheses that happen to be related. **They are the same hypothesis.** The
floor hypothesis is not a mild weakening of the fade law; it is its exact
negation, and it is refutable by exhibiting enough decorrelated statistics at a
given level.

Against that backdrop the record is a prediction, not just a measurement. With
the rebound rung removed as noise, the de-noised ladder satisfies
$\rho_{k+1} \le 0.98\,\rho_k$ at every rung. If that rate persists, five more
rungs put the dial below $0.40$ — and the capacity above five.

---

## The inverse problem

One last loop to close. Everything above bounds the *pooled* value from the
*per-seed* values. An experimenter needs the opposite direction: I measured one
pooled number and I know roughly how balanced my seeds are — what does that force
about the individual seeds I did not report?

**Inverse pooling law.** *If the per-seed ratios lie in $[\alpha, \beta]$, the
per-seed readings lie in $[\rho_{\min}, \rho_{\max}]$, and the pooled reading is
$\rho_{\text{pool}}$, then*
$$\rho_{\text{pool}} \le \rho_{\max}
\qquad\text{and}\qquad
\rho_{\min} \le \rho_{\text{pool}}\cdot\frac{\alpha+\beta}{2\sqrt{\alpha\beta}} .$$

The first half is no-inflation; the second is the sharp imbalance law solved for
$\rho_{\min}$. Together they are a two-sided window whose width is controlled by
the imbalance window alone. At the recorded pooled value $0.43636$ with
$\lambda_k \in [1, 1.21]$, the inflation factor is $2.21/2.2 = 1.004\overline{54}$
and the window collapses to
$$\text{some seed reads} \ge 0.43636, \qquad \text{some seed reads} \le 0.43835 .$$
A window of width less than $0.002$. Because the seeds are nearly balanced, the
single pooled number pins down where the individual seeds must live to two
decimal places and change — which is precisely why the sceptic's "it's just
imbalance" reading has nowhere left to stand.

---

## What the dial says

Assemble the verdicts. The rebound was smaller than the seed spread, so it
carried no information; the total fade was larger, so it did. The fall cannot be
manufactured by seed imbalance of the recorded size — not by a factor of four.
The seed profile that would suffer the worst-case attenuation is unique, and any
real profile misses it, quantitatively. The measured advantage over the baseline
certifies that the two statistics are genuinely different. And the fade, far from
being a failure, is an expansion: the dial has moved from a level supporting
three decorrelated statistics to a level supporting five.

Above all: there is no floor unless the capacity is capped, and there is no
capacity cap unless there is a floor. The two conjectures the experiment has been
circling turn out to be one conjecture, seen from two sides. That is the kind of
answer that makes further measurement worth doing — because now a single number,
the next rung of the ladder, decides between them.
