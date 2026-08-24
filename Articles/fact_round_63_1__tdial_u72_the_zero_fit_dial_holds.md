# The Correlation Budget: Why Two Good Predictors Can't Both Be Great

## A tie that meant more than it looked like

Some of the most interesting moments in an experimental campaign arrive disguised as
non-events. Here is one.

A long-running measurement tracks a single number, which we will call *the dial*. On each
trial you draw a random integer of a fixed size — say 72 bits — and compute a statistic
$T$ from it: the number of trailing binary zeros, i.e. the largest power of two dividing
the number. Separately, the trial produces an outcome, a *rate*. The dial is the Spearman
rank correlation between $T$ and the rate: how faithfully does the zero-count predict the
outcome?

At 72 bits, over three independent seeds, the dial read $0.605$, $0.606$, and $0.603$;
pooled, $0.605$ with a confidence interval $[0.586, 0.625]$. Comfortably inside the
validation band $[0.55, 0.85]$. A healthy, reproducible signal.

The non-event was this. Alongside $T$ there is a much duller baseline statistic — the plain
*count* of one-bits, the popcount. At smaller sizes, around 44 to 52 bits, the sophisticated
zero-count statistic beat the dull popcount baseline by a clear margin, about $+0.07$ in
correlation. At 72 bits that margin had shrunk below $+0.05$. The two statistics had
essentially drawn level. The campaign logged this as **count parity** and moved on.

But parity is strange. The two statistics are not measuring the same thing; on uniform
random integers the trailing-zero count and the popcount are close to independent of each
other. So we have two nearly independent statistics both scoring about $0.6$ against a
single shared outcome. Is that even allowed?

The answer, it turns out, is: *barely*. And the boundary is a clean, universal constant.

## The geometry of three correlations

Correlation has a secret identity: it is an angle. Center a data vector (subtract its mean)
and normalize it, and the correlation between two variables is exactly the cosine of the
angle between the two resulting unit vectors. Once you accept that, questions about several
variables become questions about several arrows in space, and space is a strict landlord.

Suppose we have three variables: two predictors $U$ and $V$, and one shared response $W$.
Write $a = \operatorname{corr}(U,W)$, $b = \operatorname{corr}(V,W)$, and
$c = \operatorname{corr}(U,V)$. Three unit vectors in Euclidean space are governed by the
non-negativity of their Gram determinant, and writing that determinant out gives the
**three-correlation inequality**:

$$a^2 + b^2 + c^2 \le 1 + 2abc.$$

This is one of those inequalities that looks like a curiosity and behaves like a law. It is
not a statistical assumption; it holds for any three vectors of numbers whatsoever, because
it is just the statement that a certain squared volume cannot be negative. (A one-line
derivation: project $V$ and $W$ onto the plane perpendicular to $U$, and apply the
Cauchy–Schwarz inequality to the two residuals.)

Now feed the experiment into it. Suppose both predictors score at least $\rho \ge 0$ against
the response, so $a \ge \rho$ and $b \ge \rho$, and suppose their mutual correlation is
$c < 1$. Rearranging the inequality gives the **parity ceiling law**:

$$\rho^2 \le \frac{1+c}{2}.$$

Read that carefully, because it is the whole story in one line. *Two predictors can only
both be good if they are correlated with each other.* The permission to both score high is
bought with mutual redundancy, and the price is exact.

## The constant $1/\sqrt{2}$

Set $c \le 0$ — the predictors are uncorrelated, or negatively correlated. Then

$$\rho \le \frac{\sqrt 2}{2} = \frac{1}{\sqrt 2} \approx 0.70711.$$

Two decorrelated statistics can never both correlate above $0.70711$ with the same
response. Not "usually not", not "not without a big sample" — never, for any data whatever.

And the bound is exactly attained, not merely a safe over-estimate. For any level $t$ with
$2t^2 \le 1$, take three vectors in three-dimensional space:

$$U = (1,0,0), \qquad V = (0,1,0), \qquad W = \left(t,\ t,\ \sqrt{1-2t^2}\right).$$

Then $\operatorname{corr}(U,V) = 0$ exactly, while $\operatorname{corr}(U,W) =
\operatorname{corr}(V,W) = t$ exactly. Every level up to $1/\sqrt 2$ is realized; nothing
above it is. The threshold is sharp.

Now look at the dial again.

- At 72 bits it reads $0.605$. Since $0.605 < 0.70711$, two decorrelated statistics *may*
  both read that value — and the configuration above shows they can. **Count parity at
  72 bits is free.** Geometry does not object.
- At 44 bits it reads $0.78$. Since $0.78 > 0.70711$, two decorrelated statistics *cannot*
  both read that value. **Count parity at 44 bits is impossible.**

The dial's gentle monotone decline from $0.78$ down to $0.605$ crossed the constant
$1/\sqrt{2}$ somewhere in between. And the count advantage decayed from $+0.07$ to below
$+0.05$ over exactly that interval. The disappearance of the advantage was not an accident
of the particular statistics involved; it is what a declining dial *must* do when it passes
through $1/\sqrt{2}$.

## The advantage law: how much the baseline must lose

The same geometry turns the qualitative statement into a quantitative one. Suppose the dial
reads $\rho$, the baseline reads $\rho - \alpha$ (so $\alpha$ is the advantage), and the two
statistics are decorrelated. The three-correlation inequality with $c \le 0$ collapses to
the **circle bound**

$$a^2 + b^2 \le 1,$$

which says the pair of readings must lie inside the unit quarter-circle. From it,

$$\alpha \ \ge\ \rho - \sqrt{1 - \rho^2}.$$

That right-hand side is negative below $1/\sqrt 2$ (no constraint: parity is allowed) and
strictly positive above it. So a decorrelated baseline facing a dial above $1/\sqrt 2$
*must* lose, and must lose by at least a computable amount. At $\rho = 0.78$, the forced
advantage is at least $0.78 - \sqrt{1 - 0.6084} \approx 0.78 - 0.626 = 0.154$.

Turn it around, and you get an inference rule for the experimenter: **observing parity is
itself evidence that the dial has fallen below $1/\sqrt 2$** — or else the two statistics
you thought were independent are not.

The second horn of that dilemma has its own quantitative form. Rearranging the three-
correlation inequality for $c$ yields the **forcing law**

$$c \ \ge\ ab - \sqrt{(1-a^2)(1-b^2)}.$$

At the 44-bit end, readings of $0.78$ and $0.71$ against the same response force
$c \ge 0.11$: the two statistics must be measurably correlated with each other, whether or
not anyone measured it.

Here honesty requires an admission. At the 72-bit readings — $0.605$ for the dial, roughly
$0.555$ for the baseline — the forcing law gives $c \ge -0.327$, which is no constraint at
all. The 72-bit data *cannot* be used to detect correlation between the two statistics. The
law is sharp, and sharpness cuts both ways: below the threshold it has nothing to say. That
limitation is part of the result, not a gap in it.

## From two predictors to many: the correlation budget

Parity is a story about two statistics. Any research programme that keeps adding baselines
is implicitly asking a bigger question: *how many mutually decorrelated statistics can all
read the same dial value?*

The answer comes from a classical piece of Hilbert-space geometry, Bessel's inequality. If
$u_1, \dots, u_k$ are mutually orthogonal unit vectors and $w$ is any vector, then

$$\sum_{i=1}^{k} \langle u_i, w\rangle^2 \ \le\ \langle w, w\rangle.$$

The proof is a single expansion: the residual $w - \sum_i \langle u_i,w\rangle u_i$ has
non-negative squared length, and multiplying that out gives the inequality directly.
Normalizing by $\langle w,w \rangle$ turns it into a statement about correlations:

$$\boxed{\ \sum_{i=1}^{k} \rho_i^2 \ \le\ 1\ }$$

for the correlations $\rho_i$ of any mutually decorrelated family with any single response.
This is the **correlation budget**. A response has exactly one unit of explanatory mass to
distribute, and independent predictors must divide it among themselves.

If all $k$ predictors read at least $\rho \ge 0$, the budget gives the **capacity law**

$$k\,\rho^2 \le 1, \qquad\text{i.e.}\qquad \rho \le \frac{1}{\sqrt k}.$$

At $k = 2$ this recovers the parity threshold $1/\sqrt 2$ exactly — the parity ceiling was
never special; it was the second rung of a ladder.

And again the ladder is exactly calibrated, not merely a safe bound. Whenever $k t^2 \le 1$
there is an explicit configuration achieving equality: work in $k+1$ dimensions, take
$u_1, \dots, u_k$ to be the first $k$ coordinate axes, and take the response

$$w = \bigl(t,\ t,\ \dots,\ t,\ \sqrt{1 - kt^2}\bigr).$$

Then the $u_i$ are perfectly orthonormal and every single one reads exactly $t$ against $w$.
The capacity law is an equality, with nothing to spare.

## What the budget says about the measurement

Now apply the ladder to the recorded numbers. The relevant rungs are
$1/\sqrt 2 \approx 0.7071$ and $1/\sqrt 3 \approx 0.5774$.

- **Bitlen 72, dial $= 0.605$.** We have $1/\sqrt 3 < 0.605 \le 1/\sqrt 2$. Capacity is
  exactly **two**: a pair of mutually decorrelated statistics can both read $0.605$, and an
  explicit configuration does. But three cannot, because $3 \times 0.605^2 = 1.098 > 1$.
- **Bitlen 44, dial $= 0.78$.** Since $0.78 > 1/\sqrt 2$, capacity is **one**. Not even a
  pair fits in the budget.

This converts the observation into a falsifiable prediction about the experiment itself:
**any third baseline that also reads $0.605$ at 72 bits must be measurably correlated with
one of the first two.** There is no room in the budget for a genuinely new, genuinely
independent predictor at that level. If one shows up, something in the measurement is wrong.

And it reframes the dial's decline. The programme observed the dial falling and the count
advantage vanishing, and treated these as two facts. They are one fact. The capacity is a
decreasing step function of the dial value: as the dial slides from $0.78$ to $0.605$, the
capacity rises from $1$ to $2$ — and capacity $2$ is precisely the condition under which a
second statistic *can* match the dial at all. Parity did not appear because the baseline got
better. Parity appeared because the dial got small enough to leave room for it.

## Making it about ranks

One technical bridge is needed to connect all of this to the actual measurement, because the
dial is a *Spearman* correlation — computed from ranks and the classical formula

$$\rho_s = 1 - \frac{6 \sum_i d_i^2}{n^3 - n},$$

where $d_i$ is the difference of the two ranks assigned to item $i$ — while the geometry
above is about Pearson correlations of vectors.

They agree, and the reason is a small computation. The rank vector $(1, 2, \dots, n)$, once
centered, has squared length exactly $(n^3-n)/12$; and centered squared length is invariant
under permuting the entries, so *every* tie-free ranking of $n$ items has the same centered
norm. Two vectors sharing a common mean and this common centered norm satisfy

$$\operatorname{corr}(\tilde u, \tilde v) = 1 - \frac{6\sum_i (u_i - v_i)^2}{n^3-n},$$

where $\tilde u, \tilde v$ denote the centered vectors. So Spearman's coefficient really is
the cosine of an angle between two specific vectors, the ceiling laws apply to it verbatim,
and every bound above can be read directly off the reported table of numbers.

## The moral

There is a habit of mind that treats each new predictor as an independent opportunity: find
another feature, get another correlation, stack them up. Geometry says no. A response is a
single direction in a high-dimensional space, and the mutually independent directions
competing to explain it are dividing a fixed pie:

$$\sum_i \rho_i^2 \le 1.$$

Everything else here is bookkeeping on that one inequality. Two independent predictors above
$0.71$: impossible. Three above $0.578$: impossible. A high-scoring predictor and a
close-following baseline: possible only if they are secretly the same predictor, to a
quantifiable degree.

The campaign's "non-event" — two statistics drawing level — was in fact a measurement of a
geometric threshold. The dial crossed $1/\sqrt 2$, and the moment it did, the door opened for
a second statistic to walk through. It was not a coincidence that a baseline arrived. It was
a vacancy, and vacancies get filled.
