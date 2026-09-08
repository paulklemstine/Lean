# The Ceiling You Can Measure

## How to find out what *every* model could ever learn — without training a single one

There is a moment familiar to anyone who has ever tried to explain data with a model. You fit
something simple — a straight line, a ratio, a linear probe — and it explains, say, one third of
the variation. Then comes the question that eats the next six months: *would something cleverer
do better?* A bigger network, a deeper head, a smarter feature map. Somewhere out there, perhaps,
is the function that explains everything.

This article is about a piece of mathematics that answers that question in advance — not by
searching over models, but by *measuring* something in the data that no model can change.

The setting is deliberately concrete. Imagine a large number of observations. Each one carries
two numbers: a **content label** — a discrete tag, a token, a key, a category — and a **response**
— a real number we would like to predict, which in the motivating application is the *importance*
of a piece of context to a model's output. Write $\mathrm{key}(i)$ for the label of observation
$i$ and $a(i)$ for its response. Our hypothesis class is enormous: *every* function $f$ from
labels to numbers. Any predictor that looks only at the content label — a lookup table, a linear
probe on an embedding of the label, a twelve-layer transformer head reading it — is a member.

The quantity we care about is the familiar coefficient of determination,
$$R^2(f) = 1 - \frac{\sum_i \big(a(i) - f(\mathrm{key}(i))\big)^2}{\sum_i \big(a(i) - \bar a\big)^2},$$
where $\bar a$ is the grand mean of the responses. The denominator, the **total dispersion**
$SS_{\mathrm{tot}}$, is the amount of variation there is to explain. The numerator is what the
predictor fails to explain.

## The pigeonhole that no depth can escape

Here is the whole idea in one sentence: **if two observations share a content label but have
different responses, no function of the label can get both of them right.**

A function of the label must give the *same* answer to both, because it sees the same input. It
must therefore pay a penalty. The cheapest possible compromise is the midpoint, and the penalty
at the midpoint is, for a gap of size $g$ between the two responses, exactly $g^2/2$. That is not
an estimate; it is the arithmetic identity
$$\min_{c}\ \big[(x-c)^2 + (y-c)^2\big] = \frac{(x-y)^2}{2}.$$

Depth does not help. Cleverness does not help. Data does not help. Two observations with the same
label and different values impose an irreducible cost of half the squared gap on *every* content
function that will ever be written.

Now sum this over all label groups. Collect the observations into **fibers**: the fiber over a
label $y$ is the set of observations carrying that label. Within each fiber, the best a content
function can do is predict the fiber's own mean — its **conditional mean**
$$\mu(y) = \frac{1}{|\text{fiber over } y|}\sum_{i \in \text{fiber over } y} a(i).$$
The cost it pays there is the fiber's internal dispersion, and the total over all fibers is the
**within-content sum of squares**
$$SS_{\mathrm{within}} = \sum_y \sum_{i \in \text{fiber over } y} \big(a(i) - \mu(y)\big)^2 .$$

This gives the central object of the story.

> **The Intrinsic Ceiling Theorem.** For every function $f$ of the content label,
> $$R^2(f) \le 1 - \frac{SS_{\mathrm{within}}}{SS_{\mathrm{tot}}},$$
> and equality is attained by the conditional mean $f = \mu$. The number on the right — call it
> the **ceiling** — is therefore not an upper bound but the exact maximum of $R^2$ over the entire
> class of content functions.

Two things about this are worth pausing on. First, the ceiling mentions no model. It is computed
from the labels and the responses alone. Second — and this is what makes it useful in practice —
$SS_{\mathrm{within}}$ requires only *repeated labels*. If you have two observations sharing a
content label, you have a piece of the ceiling in your hands, and you did not have to train
anything to get it.

## Anatomy: a Pythagorean theorem for data

Why does the ceiling behave so well? Because underneath it is a right angle.

Split each observation's deviation from the grand mean into two pieces: how far it is from its own
fiber's mean, and how far its fiber's mean is from the grand mean. These two pieces are
orthogonal, and squaring gives the classical decomposition:

> **The Decomposition Theorem.** With
> $SS_{\mathrm{between}} = \sum_y |\text{fiber over } y| \cdot (\mu(y) - \bar a)^2$,
> $$SS_{\mathrm{tot}} = SS_{\mathrm{within}} + SS_{\mathrm{between}}.$$

The engine behind it is a small identity worth stating on its own, because it is the reason the
conditional mean is optimal: for any group $G$ of numbers with mean $m$ and any constant $c$,
$$\sum_{i \in G}(g_i - c)^2 = \sum_{i \in G}(g_i - m)^2 + |G|\,(m - c)^2 .$$
Missing the mean costs you exactly the group size times the squared miss — never less, and the
minimum is at $c = m$.

The decomposition turns the ceiling into a *fraction*: it equals
$SS_{\mathrm{between}}/SS_{\mathrm{tot}}$, the share of the variation that content explains. And
it turns the question "can any content function reach $R^2 = 1/2$?" into a comparison between two
directly observable numbers:
$$\text{ceiling} < \tfrac12 \iff SS_{\mathrm{between}} < SS_{\mathrm{within}} .$$
Explained versus unexplainable: whichever is bigger wins.

There is a geometric reading. The operation "replace each response by its fiber mean" is a linear
map on the space of response vectors, and it is *idempotent* — averaging an already-averaged
function changes nothing — and *self-adjoint* with respect to the natural inner product
$\langle a, b\rangle = \sum_i a(i) b(i)$. Linear, idempotent, self-adjoint: that is exactly an
**orthogonal projection**, onto the subspace of functions that depend only on the content label.
So the ceiling is a squared cosine — the squared cosine of the angle between the centred response
vector and the subspace of content-measurable functions. The threshold $1/2$ is the $45°$ line.

Idempotence has a punchline for the machine-learning practitioner: stacking depth on top of the
conditional mean does literally nothing. A projection applied twice is the projection. And it goes
further:

> **Coarsening Monotonicity.** If a predictor reads the label only through some further map $g$ —
> a hash, a bucketing, a bottleneck, a learned embedding of the label — then its ceiling is at
> most the ceiling of the raw label map.

Every tower of computation built on top of the content is dominated by the raw content itself.
Depth can only lose information here, never create it.

## The two ends of the scale

The ceiling degenerates in exactly two ways, and both have crisp characterizations.

> **The ceiling equals $1$ if and only if the response is already a function of the content** —
> that is, $SS_{\mathrm{within}} = 0$: no label ever carries two different values. In particular,
> if every observation has a *distinct* label, the ceiling is $1$ and says nothing at all; a
> lookup table memorizes the data perfectly. Repeated labels are what make the measurement
> meaningful.

> **The ceiling equals $0$ if and only if every occupied fiber's mean equals the grand mean.**
> (The "occupied" qualifier is essential: labels that never occur carry no information and must be
> excluded, or the characterization is false for any label set with unused values.)

Between those endpoints, *anything can happen*, and this is where the story takes its sharpest
turn.

## The conjecture, and what became of it

The motivating conjecture — call it the ceiling conjecture — had three clauses:

1. For a certain pooled population of observations, the ceiling lies below $0.5$;
2. hence no content head, however deep, exceeds $R^2 = 0.5$;
3. and the measured linear value $0.329$ therefore already captures more than two thirds of what
   any content function could achieve.

Each clause met a different fate.

**Clause 1 is not a theorem.** Consider four observations, two labels, each label seen twice, with
responses
$$c+d,\quad c-d \qquad\text{(label 0)}, \qquad -c-d,\quad -c+d \qquad\text{(label 1)}.$$
Here $c$ is a *content-informative* amplitude — it separates the two labels — and $d$ is a
*swap* amplitude that jitters the two observations sharing a label. A direct computation gives
$SS_{\mathrm{tot}} = 4c^2+4d^2$, $SS_{\mathrm{within}} = 4d^2$, and therefore
$$\text{ceiling} = \frac{c^2}{c^2+d^2}.$$
Tuning $c$ and $d$ sweeps this over the whole interval $[0,1)$. Setting $c=0$ gives a pure-swap
population where content explains nothing; $c/d = 0.7$ gives $0.329$; $c^2/d^2 = 9$ gives $0.9$,
comfortably above the conjectured bound. **Every value in $[0,1)$ is realized by a genuine pooled
population with repeated labels**, so no structural argument can ever prove that the ceiling is
below $0.5$. The bound is a *measurement*, not a theorem.

**Clause 2 is true — conditionally, and the condition is measurable.** This is the practical
heart of the result:

> **The Pair Certificate.** Suppose for each of a set of labels you can name two observations
> sharing that label, with responses differing by $g_y$. If
> $$\sum_y g_y^2 > SS_{\mathrm{tot}},$$
> then the ceiling is below $1/2$, and consequently *every* content function — linear, deep,
> tabulated, anything — has $R^2 < 1/2$.

Look at what the hypothesis contains: labels, and the responses of two observations that share
each label. No predictor, no hypothesis class, no training run. You compute a handful of squared
differences, compare to the total dispersion, and if the comparison goes your way you have ruled
out an entire infinite class of models — including all the ones nobody has invented yet.

**Clause 3 is false at its own boundary.** If the ceiling really were exactly $0.5$, then a
measured $0.329$ captures $0.329/0.5 = 0.658$ of it — and $0.658 < 2/3 = 0.6667$. The clause fails
by four thousandths. The exact repair is a clean threshold: the measured value captures more than
two thirds of the ceiling precisely when the ceiling is below $0.4935$. The salvaged statement,
true throughout the conjectured regime, is that whenever the ceiling is at most $0.5$ the measured
value captures more than $65\%$ of everything a content function can ever achieve.

That is a fair summary of what a conjecture is *for*: it was mostly right, wrong in a specific and
locatable place, and the repair is sharper than the original.

## When does the measurement see everything?

The pair certificate is *sound* — when it fires, its conclusion is true. Is it *complete*? Does it
fire whenever the ceiling really is below $1/2$?

Not in general. Take four observations sharing a single label with responses $1, -1, 1, -1$. The
ceiling is $0$ — content explains nothing whatsoever — but $SS_{\mathrm{tot}} = 4$ and the largest
available squared gap is also $4$, so the certificate never fires. One gap simply cannot see the
dispersion of a four-member fiber.

But there is a design in which the certificate is exact, and it is the natural one:

> **Exact Measurement in the Paired Design.** If every label occurs in exactly two observations —
> one train window and one test window, say — then
> $$SS_{\mathrm{within}} = \tfrac12 \sum_y g_y^2$$
> *exactly*, and the ceiling lies below $1/2$ if and only if $\sum_y g_y^2 > SS_{\mathrm{tot}}$.

The ceiling of the entire nonlinear class is then literally half the sum of the observed gaps. The
question of what any model could ever achieve becomes one arithmetic comparison.

How far does this extend? The natural guess was that a single gap still sees "most" of a
three-point fiber, so the certificate should stay complete up to fibers of size three. It does
not. Consider six observations, two labels, three observations each, with responses
$$-6.5,\ -0.5,\ -0.5 \quad\text{and}\quad -1.5,\ 4.5,\ 4.5 .$$
Then $SS_{\mathrm{within}} = 48$ and $SS_{\mathrm{tot}} = 85.5$, so the ceiling is
$1 - 48/85.5 = 0.4386\ldots$, safely below $1/2$. Yet the largest gap inside either fiber is $6$,
so the best possible certificate value is $2 \times 36 = 72 < 85.5$: it never fires. The
completeness threshold is therefore **exactly two observations per label** — and completeness does
hold there, because contents seen once or not at all contribute nothing and can simply be dropped.

The mechanism is a ratio. A fiber's dispersion, divided by its squared diameter, is exactly $1/2$
for two points, rises to $2/3$ for the extremal three-point configuration, and grows without
bound (like a quarter of the fiber size). A single gap always reports $1/2$. Exact at two, lossy
from three on.

## Falsification, with the model attached

A one-sided test is only half a science. The dual certificate makes the ceiling conjecture
*refutable* from observables too, and it uses a bound in the opposite direction: a group of values
confined to an interval $[l, u]$ has dispersion at most $|G|\big((u-l)/2\big)^2$ — you cannot
disperse more than the box allows.

> **The Refutation Certificate.** If each label's observed responses lie in an interval
> $[l_y, u_y]$ and
> $$\sum_y |\text{fiber over } y| \cdot (u_y - l_y)^2 \le 2\,SS_{\mathrm{tot}},$$
> then the ceiling is at least $1/2$ — and the conditional mean is an *explicit* content head
> achieving $R^2 \ge 1/2$.

Again the hypothesis is all observables: fiber sizes and within-label ranges. And a refutation
does not merely say "a good model exists" — it hands you the model, which is the tabulated
conditional mean.

## Why you can trust a measured ceiling

A number you plan to make decisions with had better not be an artifact of how the data was
recorded. Three invariance theorems say it is not.

- **Units.** Replacing each response $a$ by $c\,a + b$ with $c \ne 0$ leaves the ceiling exactly
  unchanged. Attention mass, log-counts, per-layer renormalization: same number. The threshold
  $0.5$ is dimensionless.
- **Labels.** Renaming the content labels by any injective map — a different tokenizer, a
  different hash — leaves the ceiling fixed. It depends only on the partition of observations into
  fibers, not on the names.
- **Resampling.** Duplicating the whole population $k$ times multiplies both sums of squares by
  $k$, so the ratio, and hence the ceiling, is untouched. You cannot manufacture a verdict by
  re-using windows.

Together these say the ceiling is a functional of the empirical distribution of (label, response)
pairs. The *certificate*, by contrast, is a functional of a subsample — which is exactly why it can
be incomplete, and exactly why the two-per-label design is the sweet spot: there the subsample is
the sample.

## A dichotomy that does not go both ways

The motivating research programme had two competing arms: a *content* arm (can a deeper content
head do better?) and a *relational* arm (is the missing signal in relations between observations
rather than in content?). The natural expectation is that if one arm's ceiling is not binding, the
other becomes so.

The mathematics says the trade-off is asymmetric. On the pooled population, the within-content sum
of squares is *identically* the relational dispersion of the second arm. From this identification
one gets: if the content ceiling fails to be below $1/2$ — that is, if a deep content head really
is worth building — then the relational deficit is automatically at most
$$\sqrt{\frac{B \cdot SS_{\mathrm{tot}}}{2\,|W|}},$$
where $B$ is the size of the top-set under study and $|W|$ the number of windows. The relational
arm cannot simply inherit the binding role. The two arms trade against each other, and the trade
is quantitative.

## The moral

The usual way to find out whether a better model exists is to build better models. That is
expensive, open-ended, and never conclusive: a failure to find one is not a proof that none
exists.

The alternative on display here is to look for a quantity that *no* model can touch. Two
observations with the same input and different outputs are a contradiction that every function
must pay for, and the payment is computable from the data alone. Accumulate those payments and you
have a hard ceiling on an entire hypothesis class — with the geometry of an orthogonal projection
behind it, an exact formula in the natural experimental design, a sharp characterization of when
the measurement is complete, invariance under the ways your data could have been recorded, and a
dual test that refutes rather than confirms and hands you the winning model when it does.

The conjecture that started this was, in the end, one third correct, one third unprovable, and one
third false by four thousandths. But the machinery built to adjudicate it settles a much more
useful question than the one that was asked: not *is this particular ceiling below one half?* but
*how do you measure a ceiling at all?*
