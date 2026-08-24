# The Price of an Advantage: What Geometry Says About Beating a Baseline

## A number that refused to settle

Imagine you are testing a hunch. You have a large pile of 64-bit integers, and for each one
you can measure two simple things. The first is the *trailing-zero count* $T$: how many
zeros sit at the bottom of the binary expansion before the first $1$ appears. The second
is the *popcount*: how many $1$ bits there are in total. You want to know which of these
two crude summaries better predicts some downstream quantity — call it the *rate*.

You run the experiment. The trailing-zero statistic correlates with the rate at
$\rho(T, \text{rate}) = 0.641$, with a confidence interval $[0.619, 0.660]$. That is a real,
solid signal, comfortably inside the band $[0.55, 0.85]$ you declared in advance as
"the effect is present." Call this hypothesis H1, and mark it *replicated*.

Then you ask the sharper question. Popcount also predicts the rate — it reads $0.597$.
Is $T$ genuinely *better*? You had pre-registered a bar: the advantage
$\alpha = \rho(T) - \rho(\text{popcount})$ must exceed $+0.05$. You measure
$\alpha = +0.044$, interval $[0.022, 0.066]$. The point estimate is *below* the bar. Only
one of your three fresh random seeds clears it.

But pool your three fresh seeds with three older ones from a previous run, and the picture
inverts: across six seeds the mean advantage is $+0.059$, the median $+0.058$, and three of
the six seeds sit above the bar. The mean says *yes*. The count says *half*. The freshest
evidence says *no*.

This is what one might call **count parity**: a mean that clears a threshold while only
half the sample does. It is a familiar and uncomfortable pattern to anyone who has ever
watched a marginal effect wobble across replications. The natural instinct is to reach for
more statistics. What this article describes is a different move: reach for *geometry*, and
ask what shapes such a record is even allowed to have.

The answer turns out to be surprisingly rigid — and it ends with a plausible-looking
conjecture about averaging evidence across replications being **false**, for a reason that
matters far beyond bit-counting.

## Correlations are angles

The whole story rests on one old and beautiful fact. A statistic measured on $n$ data
points is just a vector in $n$-dimensional space. Center it and normalise it, and its
correlation with another such vector is exactly the cosine of the angle between them.
Correlation is not a number attached to a pair of variables; it is a *geometry*.

So the experiment above is really three unit vectors: $u$ (the trailing-zero statistic),
$v$ (popcount), and $w$ (the outcome). The three pairwise correlations are
$$a = \langle u, w\rangle, \qquad b = \langle v, w\rangle, \qquad c = \langle u, v\rangle.$$
Not every triple $(a,b,c)$ can occur. Vectors live in a space with a positive inner product,
and that forces the Gram determinant to be non-negative:
$$a^2 + b^2 + c^2 \le 1 + 2abc.$$

This inequality is where the whole subject lives. It is usually written as a constraint on
correlation matrices. The first result of this work rewrites it as a statement about
*advantages*.

**The Chord Law.** For all real $a, b, c$,
$$a^2 + b^2 + c^2 \le 1 + 2abc \iff (a-b)^2 \le (1-c)\,\bigl(1 + c - 2ab\bigr).$$

The two sides are not merely related; they are *the same inequality*, since the difference
of the two expressions is the identity
$$(1-c)(1+c-2ab) - (a-b)^2 = 1 + 2abc - (a^2+b^2+c^2).$$

Read the right-hand form aloud and you hear something new. The advantage $a - b$ of one
statistic over another is not an independent quantity. It *is* Gram positivity, viewed
along the difference direction. And the factor $(1-c)$ tells you what an advantage costs.

## An advantage is a purchase

Weaken the chord law slightly — using only $1 + c \le 2$ — and you get the sentence that
organises everything that follows.

**The Decorrelation Budget.** If two statistics with readings $a$ and $b$ against a shared
outcome have mutual correlation $c$, and the advantage is at least $\alpha \ge 0$, then
$$\alpha^2 \le 2\,(1-c)\,(1 - ab).$$

Equivalently, whenever the reading product satisfies $ab \ge M$ with $M < 1$,
$$c \;\le\; 1 - \frac{\alpha^2}{2(1-M)}.$$

In words: **you cannot beat a baseline you resemble.** Every unit of advantage must be paid
for in mutual decorrelation, at a price set by how strong both statistics already are. If
$T$ and popcount both read around $0.6$ against the outcome, then their reading product is
about $0.38$, and an advantage of $+0.044$ already forbids them from being more than
$0.9985$-correlated with each other. That is a weak-looking constraint, but it is an
*unconditional* one, derived from nothing but the fact that correlations come from vectors.
Push the advantage up to $+0.086$ at a reading product of $1/3$ and the ceiling drops to
$0.995$.

And the bound is exactly right, not merely true: when the outcome happens to lie in the
plane spanned by the two statistics — a two-dimensional world — the chord law becomes an
*identity*,
$$(a-b)^2 = (1-c)(1+c-2ab),$$
so no improvement is possible in general.

One more piece of geometry falls out. Define the *chord distance* between two nonzero
statistics as $d(u,v) = \sqrt{2 - 2\,\rho(u,v)}$, the Euclidean distance between their
normalised versions. This is a genuine metric — in particular it satisfies the triangle
inequality — and that converts the pairwise budget into a *transitivity* law: if $u$ is
close to $v$ and $v$ is close to $w$, then $u$ cannot be far from $w$, quantitatively.
Correlation, so often treated as a stubbornly non-transitive relation, is transitive in the
right coordinates.

## How many good statistics can there be?

Now stop comparing two statistics and start collecting them. Suppose you have $k$ unit
statistics $u_1, \dots, u_k$, each reading at least $\rho$ against a fixed unit outcome $w$,
and suppose no two of them are correlated by more than $\gamma$. How large can $k$ be?

Two special cases were already understood. If the statistics are *orthonormal*
($\gamma = 0$), the readings are the coordinates of a unit vector, so $k\rho^2 \le 1$: a
strict capacity. If there are exactly two of them, the chord law gives $2\rho^2 \le 1 + c$.
These look like separate facts. They are two faces of one law.

**The Capacity Law.** If $u_1, \dots, u_k$ are unit vectors with $\langle u_i, u_j\rangle \le \gamma$
for $i \ne j$, and $w$ is a unit vector with $\langle u_i, w \rangle \ge \rho \ge 0$ for all
$i$, then
$$k\,\rho^2 \;\le\; 1 + (k-1)\,\gamma.$$

Setting $\gamma = 0$ recovers the orthonormal ceiling; setting $k = 2$ recovers pairwise
parity. In between it interpolates, and it is *attained on the entire sheet*: for every
admissible pair $(k, \gamma)$ there is an **equidistant family** — $k$ unit vectors with
every pairwise correlation exactly $\gamma$, all reading exactly
$\sqrt{\bigl(1 + (k-1)\gamma\bigr)/k}$ against a common unit outcome — that turns the
inequality into an equality.

All of this is a shadow of a still simpler statement that needs no hypotheses at all.
Writing $G_{ij} = \langle u_i, u_j\rangle$ for the Gram matrix of any family whatsoever,
Cauchy–Schwarz applied to the sum $S = \sum_i u_i$ against $w$ gives the **master law**
$$(k\rho)^2 \;\le\; \mathbf{1}^{\mathsf T} G \,\mathbf{1} \;=\; \sum_{i,j} \langle u_i, u_j\rangle .$$
Bounding the right-hand side by its largest row sum returns the capacity law; bounding it by
Cauchy–Schwarz in the Frobenius norm returns $(k\rho^2)^2 \le \sum_{i,j} \langle u_i,u_j\rangle^2$;
and reading it as a statement about off-diagonal entries gives a floor,
$$\sum_{i \ne j} \langle u_i, u_j\rangle \;\ge\; k^2\rho^2 - k .$$
For three statistics all reading $0.641$, this last inequality says the three mutual
correlations must sum to at least $0.3489\ldots$: *good predictors of the same thing crowd
together*. There is no such thing as a large, mutually unrelated committee of strong
statistics.

## The staircase

The capacity law has a discrete consequence with a sharp edge. Fix a reading level $\rho$
and ask which family sizes $k$ are possible at correlation ceiling $\gamma$. Rearranging,
$k$ is admissible exactly when
$$\gamma \;\ge\; \theta(\rho, k) \;=\; \frac{k\rho^2 - 1}{k - 1}.$$
The thresholds $\theta(\rho, k)$ strictly increase in $k$ whenever $\rho^2 < 1$, so the
admissible sizes form an initial segment $\{1, 2, \dots, K\}$ with a closed-form capacity
$$K \;=\; \left\lfloor \frac{1 - \gamma}{\rho^2 - \gamma} \right\rfloor .$$

Each riser of this staircase is a genuine phase boundary, not slack in a bound: below
$\theta(\rho,k)$ *no* family of size $k$ exists in any ambient dimension, and exactly at
$\theta(\rho,k)$ one does. At the replicated reading $\rho = 0.641$, the numbers are
$\theta = 0.11632\ldots$ for triples and $\theta = 0.21450\ldots$ for quadruples. So at a
mutual-correlation ceiling of $0.1$ you may have exactly two such statistics and no more;
raise the ceiling to $0.2$ and you may have exactly three. The dial has an integer output,
and it clicks.

## Extremisers are completely rigid

What do the record-holders look like — the configurations that sit exactly on the boundary
$k\rho^2 = 1 + (k-1)\gamma$? The answer is: there is essentially only one, and it has no
freedom left at all.

**Classification of extremisers.** Suppose $k \ge 1$ unit statistics with pairwise
correlations at most $\gamma$ all read at least $\rho \ge 0$ against a unit outcome $w$, and
suppose the capacity bound is saturated. Then:

1. every off-diagonal Gram entry equals $\gamma$ exactly, so the Gram matrix is
   $(1-\gamma)I + \gamma J$;
2. every reading is *exactly* $\rho$ — the inequality $\langle u_i, w\rangle \ge \rho$
   upgrades to equality;
3. the outcome is proportional to the sum of the family: pointwise
   $\sum_i u_i = k\rho\, w$, so for $\rho > 0$,
   $$w = \frac{1}{k\rho}\sum_{i=1}^{k} u_i,$$
   the *normalised sum*.

The proof of the third item is the pleasing one. Rather than invoking an abstract equality
case, one squeezes the chain of three inequalities used to prove the capacity law until each
becomes an equality, and then computes the squared length of the residual vector
$S - k\rho\,w$ directly: it is
$\langle S, S\rangle - 2k\rho\langle S,w\rangle + (k\rho)^2$, which the equalities force to
be $0$. A vector of zero length is zero.

Two further facts complete the picture. Such a configuration lives in ambient dimension
exactly $k$ — the equidistant family is linearly independent whenever $\gamma < 1$ and
$1 + (k-1)\gamma > 0$, so it cannot be squeezed into fewer than $k$ dimensions, and it does
fit into exactly $k$. And within $\mathbb{R}^k$ it is unique up to an orthogonal change of
frame: any two families with the same Gram matrix differ by an orthogonal transformation.
So an extremiser is determined by the pair $(k, \gamma)$ alone, up to the choice of
orthonormal coordinates. In particular the $\rho = 0.641$ triple is realisable, in exactly
three dimensions and nowhere smaller, and there essentially uniquely.

## Where the mean lies to you

So much for the geometry of a single experiment. The count-parity phenomenon lives one level
up: it is about the *record* of many replications. Here the tool is not Cauchy–Schwarz but
order statistics — and here a natural conjecture goes wrong.

First the rigidity. Suppose six per-seed advantages have mean $0.059$, the three fresh ones
average $0.044$, exactly three of the six clear the bar $0.05$, and exactly one of those
three is fresh. Then arithmetic alone forces the older triple to sum to $0.222$, of which
two seeds are above the bar and one is not, so **some older seed carries an advantage of at
least $+0.086$**. That is outside the fresh experiment's *entire* confidence interval
$[0.022, 0.066]$. There is an explicit record attaining exactly $0.086$, so the bound cannot
be improved.

The same style of argument yields several companions. The above-bar group must average at
least $2 \times 0.059 - 0.05 = 0.068$, already above the fresh upper endpoint $0.066$; hence
**no** record with these summary statistics can have all six advantages inside the fresh
interval. A record with mean $\mu$, half its entries below $\tau < \mu$, has squared
dispersion at least $r(\mu - \tau)^2$ — here at least $0.000486$. And if the median is
$0.058$ with the third-largest at most $0.05$, the gap between the third and fourth ordered
advantages is at least $0.016$: **the record is provably bimodal**. Count parity is not
noise; it is a structural signature.

Now the conjecture. Combine the two layers: each replication has its own decorrelation
budget $\alpha_i^2 \le 2(1-c_i)(1 - a_ib_i)$. Sum over $r$ replications and it is *very*
tempting to write
$$\sum_i \alpha_i^2 \;\le\; 2\,(1 - \bar c)\Bigl(r - \sum_i a_i b_i\Bigr)$$
with the *mean* mutual correlation $\bar c$. Budgets, surely, average.

**They do not.** Take two replications. In the first, the two statistics read $+0.7$ and
$-0.7$ against the outcome and are exactly uncorrelated: advantage $1.4$, mutual correlation
$0$. In the second, everything equals $1$: no advantage, no headroom, mutual correlation $1$.
Every hypothesis holds, $\bar c = 1/2$, and the pooled advantage energy is
$1.4^2 = 1.96$, while the conjectured budget is
$2(1 - \tfrac12)\bigl(2 - (-0.49 + 1)\bigr) = 1.49$. The conjecture fails, and not narrowly.

The mechanism is completely transparent once seen. Averaging budgets silently assumes that
the *cheap* replications — the ones with lots of decorrelation $1 - c_i$ to spend — are the
ones with the most *headroom* $1 - a_ib_i$. In the counterexample the two vary *together*
instead. So there are two repairs:

* **Unconditional:** replace the mean by the minimum. If $c_i \ge c_{\min}$ for all $i$, then
  $\sum_i \alpha_i^2 \le 2(1 - c_{\min})\bigl(r - \sum_i a_ib_i\bigr)$, always.
* **Conditional:** if $(1 - c_i)$ and $(1 - a_ib_i)$ *antivary* — cheap replications have the
  headroom — then the original mean-based bound holds verbatim. This is exactly Chebyshev's
  sum inequality.

So the conjecture is precisely one Chebyshev ordering hypothesis away from being true, and
the counterexample shows the hypothesis cannot be dropped.

Applied to the record at hand, the unconditional form has teeth. The recorded six-seed
advantage split $(0.016, 0.100, 0.106, 0.016, 0.050, 0.066)$ — consistent with every
published summary number — has pooled advantage energy $0.028604$. If every seed really
achieves its recorded advantage at a reading product of at least $1/3$, then the *most
correlated seed in the entire record* has mutual correlation at most
$1 - 0.0035755$. No single seed's budget yields this; only the pooled energy does. It is,
in the honest sense of the word, a meta-analysis: six weak constraints combining into one
that none of them contains.

## The moral

The negative result is the one worth carrying away. The per-experiment layer is geometry;
the across-experiment layer is order statistics; and the tempting bridge between them —
"average the budgets" — is invalid in exactly the regime where count parity lives.

For a bimodal record, where a few replications carry the whole effect, the cheap
replications are *not* the ones with headroom; decorrelation and headroom move together. That
is the monovariant regime, and there the naive average systematically over-credits the
record. Which is a precise, structural reason to distrust a pooled advantage estimate
whenever the underlying seeds are split — exactly the situation in which a researcher is most
tempted to pool.

The dial replicates. The advantage is real but marginal. And the reason those two sentences
can both be true, without contradiction, is a fact about the geometry of correlation and the
arithmetic of order statistics — not about bits at all.
