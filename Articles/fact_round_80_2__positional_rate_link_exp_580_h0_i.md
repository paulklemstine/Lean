# Two Layers That Never Talk: Where the Hits Land, and How Many There Are

## A tale of two questions

Imagine a machine that scans. For each setting — call it $N$ — the machine sweeps
a window and occasionally rings a bell. Two very different things can be recorded
about a scan. First: **how many** times the bell rang. Second: **where** in the
window each ring happened.

These two records look like they should be related. Surely the noisy settings
ring in a different way — earlier, later, more spread out — than the quiet ones?
That intuition is so natural it barely feels like a hypothesis. This article is
about taking it seriously enough to be wrong about it, and about the mathematics
you need in order for "we found nothing" to be a genuine discovery rather than an
admission of weakness.

The setting is concrete: a family of $128$ scan settings, roughly $9{,}600$
recorded events in total, each event tagged with the setting that produced it and
with a position in the scan window, binned into ten equal slices — deciles. Sort
the settings into three groups by how many events they produced: **hit-poor**,
**middling**, and **hit-rich**. Then ask: do the three groups distribute their
events across the ten deciles differently?

The answer turned out to be a flat no. And the interesting part is not the no.
The interesting part is the collection of theorems that make the no *mean*
something.

## The occupancy table and its secret rank

Write down the data as a table. Rows are the settings $i$; columns are the ten
positional bins $b$. Entry $O_{ib}$ is the expected number of events that setting
$i$ contributes to bin $b$. The two-layer model says this table is built from two
ingredients:

$$O_{ib} = \rho_i \, p_i(b),$$

where $\rho_i > 0$ is the **rate** of setting $i$ (how loud it is) and
$p_i(\cdot)$ is its **positional profile**, a probability distribution over the
ten bins (where it likes to ring). The rate layer is the row totals; the
positional layer is each row rescaled to sum to one.

The first thing worth knowing is that these two ingredients are not a matter of
convention. **The occupancy table determines them uniquely**: if two two-layer
descriptions produce the same table, they have the same rates and the same
profiles. You cannot trade loudness against shape. This is a one-line
observation — sum a row to recover $\rho_i$, then divide — but it is what
licenses the entire vocabulary. "The positional layer" is a real object, not a
parametrization.

Now, the hypothesis under test — *shape does not depend on loudness* — says
$p_i = p_j$ for all settings $i, j$. What does that look like at the level of the
table? Exactly this:

> **Rank-One Theorem.** The occupancy table factorises as an outer product,
> $O_{ib} = u_i v_b$ for some vectors $u$ and $v$, **if and only if** all the
> positional profiles coincide.

So "the layers don't interact" is not a vague statistical slogan. It is the
statement that a certain matrix has rank one. And the proof is pleasantly
elementary: if $O_{ib} = u_i v_b$, sum over $b$ to get $u_i \sum_b v_b = \rho_i$;
since rates are strictly positive, neither $u_i$ nor $\sum_b v_b$ can vanish, and
dividing gives $p_i(b) = v_b / \sum_c v_c$ — a formula with no $i$ in it. The
converse is immediate.

There is a second, equivalent face of the same coin, and it is the one that
statistical software actually looks at. Consider all the $2\times 2$
cross-products you can extract from the table:

$$O_{ib}\,O_{jc} = O_{ic}\,O_{jb}.$$

> **Interaction-Free Theorem.** All these cross-product identities hold if and
> only if all positional profiles coincide.

That is the population-level version of the interaction test that a log-linear
model runs. Cancel the rates $\rho_i \rho_j$ from both sides, and the condition
becomes $p_i(b)p_j(c) = p_i(c)p_j(b)$ for all bins; summing over $c$ and using
that profiles sum to one collapses it to $p_i(b) = p_j(b)$.

And the two classical goodness-of-fit statistics see exactly this and nothing
else. If you build the independence fit
$E_{ib} = (\text{row } i \text{ total})(\text{column } b \text{ total})/(\text{grand total})$
and form Pearson's

$$\chi^2 = \sum_{i,b}\frac{(O_{ib}-E_{ib})^2}{E_{ib}}, \qquad
G = 2\sum_{i,b} O_{ib}\log\frac{O_{ib}}{E_{ib}},$$

then both are nonnegative, and **each vanishes precisely when the table equals
its independence fit** — which, for an occupancy table, happens precisely when
the positional profiles are homogeneous. The $G$ statistic's nonnegativity is
Gibbs' inequality, with the sharpened form $a\log(a/e) - a + e \ge 0$ (strict
unless $a=e$) doing the work term by term. So a test that fails to reject is
failing to reject the exact algebraic hypothesis you care about — no gap between
the mathematical null and the computational one.

## Why "we found nothing" was informative

Here is the honest worry about any null result. Maybe the profiles really do
differ, and the test was simply too blunt to see it. The defence against that
worry is a theorem that turns a small observed contrast into a bound on the
underlying heterogeneity.

Pool the settings in a group $S$, weight them however you like (by total events,
say), and normalise: you get the group's pooled profile $\hat p_S$. The key
observation is that $\hat p_S$ is a **convex combination** of the individual
profiles $p_i$, $i \in S$, with weights proportional to $w_i \rho_i$. Two convex
combinations of points that are all within total-variation distance $\varepsilon$
of each other cannot be more than $\varepsilon$ apart:

> **Contrast Bound.** If every pair of settings has profiles within total
> variation $\varepsilon$, then any two pooled groups — hit-rich versus
> hit-poor, however the groups are formed — have pooled profiles within total
> variation $\varepsilon$.

Read that backwards. An observed contrast is a *lower* bound on the worst
pairwise heterogeneity present in the data. A tiny observed contrast means the
per-setting profiles genuinely cannot be spread out. That is what converts "no
signal" from a shrug into a measurement. In the extreme case, homogeneity gives
pooled profiles that are *identical*, so the population Kolmogorov–Smirnov
statistic between hit-rich and hit-poor is exactly zero — no matter how the
terciles are cut, and no matter how wildly the rates vary between them.

## Loudness overdisperses; shape does not care

The other half of the story is the rate layer. Counts in this kind of scan are
badly overdispersed: their variance runs far above their mean, with something
like 40–60% of the variance unexplained by the naive model. Where does that
excess come from?

Model the counts as a mixture: pick a setting $i$ with weight $w_i$, then draw a
count with conditional mean $m_i$ and conditional variance $v_i$. The law of
total variance for such a finite mixture says

$$\operatorname{Var} = \underbrace{\sum_i w_i v_i}_{\text{average within}} +
\underbrace{\sum_i w_i (m_i - \bar m)^2}_{\text{between}}, \qquad
\bar m = \sum_i w_i m_i.$$

If each setting is *conditionally equidispersed* — variance equal to mean, as for
a Poisson count — then $v_i = m_i$ and the identity becomes

$$\operatorname{Var} - \operatorname{Mean} = \sum_i w_i (m_i - \bar m)^2 \ \ge\ 0,$$

with equality **exactly** when all settings carrying weight share the same rate.
So any excess dispersion at all is a certificate of genuine between-setting rate
variation. Overdispersion is a property of the rate layer, full stop.

Could the rate layer's variability nevertheless be *driven* by shape? The clean
answer is no, and it is proved by exhibiting both failures of implication:

- **Overdispersion with no shape heterogeneity.** For any constant $C$, there is
  a two-layer model whose positional profiles are all literally the same
  distribution, yet whose dispersion excess exceeds $C$ times the mean. (Take two
  settings with rates $1$ and $1+s$ for large $s$, equal weights, and the same
  profile $(1/2,1/2)$.)
- **Maximal shape heterogeneity with no overdispersion.** There is a two-layer
  model with constant rates — hence variance exactly equal to mean — whose two
  positional profiles are mutually singular, at the maximum possible total
  variation distance $1$. (Rates both $1$; one setting always fires in bin $0$,
  the other always in bin $1$.)

The two layers are logically independent. Neither one constrains the other in
either direction. So a null interaction result is not merely consistent with the
data — it is consistent with an entire universe of models, and the empirical
finding genuinely narrows things down: whatever carries the unexplained rate
variance affects *how many* events a setting produces, not *where along the
window* they land.

## The shape itself: a logarithm in disguise

If shape doesn't depend on rate, what *is* the shape? Here the answer is
strikingly clean, and it comes from the arithmetic of the scan rather than from
statistics.

Events in this kind of sweep are generated by a mechanism whose density at
position $x$ is proportional to $1/x$. If the window runs from $a$ to $ra$ (ratio
$r > 1$), then the fraction of events in the leading $u$-portion of the window,
measured in the natural linear coordinate, is

$$F_r(u) = \frac{\log\bigl(1 + (r-1)u\bigr)}{\log r}, \qquad 0 \le u \le 1.$$

This function has three properties worth stating.

**It is genuinely the harmonic law.** Its derivative at $u$ is
$(r-1)/\bigl((1+(r-1)u)\log r\bigr)$, which is exactly the $1/x$ density pushed
into the coordinate $u$. And $F_r(1) = 1$.

**It is scale free.** The mass in $[a, a(1+(r-1)u)]$ relative to $[a, ra]$
doesn't depend on $a$ at all. Two windows with the same endpoint *ratio*, however
far apart in absolute size, have identical positional profiles. Only the ratio
matters.

**It always front-loads.** For every $r>1$ and every $0<u<1$,

$$F_r(u) > u.$$

The leading portion of the window always carries strictly more than its fair
share. This is not asymptotics and not an artefact of binning: it is strict
Bernoulli's inequality for real exponents, $r^u < 1 + u(r-1)$ for $0<u<1$, which
is just strict concavity of the logarithm. Taking logs of both sides and dividing
by $\log r$ gives $u < F_r(u)$ in one line.

Applied to deciles — the leading tenth of the window — this says the first decile
carries strictly more than $1/10$ of all events, for *every* window ratio. And
because the profile is the same in every rate stratum, it says this **in every
stratum simultaneously**: hit-poor, middling and hit-rich all show the same
edge-decile excess. That is precisely the pattern actually observed, with edge
fractions of $0.229$, $0.245$, $0.230$ across the three terciles. The excess is
not a coincidence repeated three times; it is one law seen three times.

## From counting to the continuum

There is a nagging gap in that story. The $1/x$ density is a continuum idealisation.
The real mechanism is arithmetic: position $j$ carries weight $1/j$, an honest
discrete sum, and deciles are integer blocks. Does the discrete carrier really
produce the continuum law, or is the agreement approximate?

It is exact in the limit, and the proof is a small piece of classical analysis.
The total discrete weight of positions $a \le j < b$ is
$H_b - H_a = \sum_{j=a}^{b-1} 1/(j+1)$, a difference of harmonic numbers. Harmonic
numbers famously satisfy $H_n = \log n + \gamma + o(1)$ with $\gamma$ the
Euler–Mascheroni constant, and in a *difference* of two harmonic numbers along
proportional scalings, $\gamma$ cancels:

$$H_{aL} - H_{bL} \longrightarrow \log\frac{a}{b} \qquad (L \to \infty).$$

Apply this to a doubling window — positions in $(10L, 20L]$, ratio $r=2$ — split
into ten integer deciles. The normalised discrete weight of the leading $k$
deciles is

$$\frac{H_{(10+k)L} - H_{10L}}{H_{20L} - H_{10L}} \longrightarrow
\frac{\log\bigl((10+k)/10\bigr)}{\log 2} = F_2\!\left(\frac{k}{10}\right).$$

The discrete carrier converges, decile by decile, to the continuum harmonic law.
In particular the leading decile converges to

$$F_2(1/10) = \frac{\log(11/10)}{\log 2} = 0.13750\ldots > \frac{1}{10}.$$

So the edge excess survives the passage to the discrete world exactly. The
observed excess is the continuum limit of an arithmetic $1/j$ weight, not a
binning artefact.

## Reading the window ratio off the edge

One more twist makes the harmonic law a measuring instrument. Fix a leading
fraction $u \in (0,1)$ and vary the *window ratio* $r$: then $r \mapsto F_r(u)$
is strictly increasing, and maps $(1,\infty)$ bijectively onto $(u, 1)$.

Monotonicity is a derivative computation whose positivity reduces to strict
convexity of $x \mapsto x\log x$ at the interpolation
$1+(r-1)u = u\cdot r + (1-u)\cdot 1$. Surjectivity uses two explicit brackets —
$F_r(u) \le ur$ for small masses, $F_r(u) > 1 + \log u/\log r$ for large ones —
plus the intermediate value theorem.

The consequence is an **identifiability theorem**: any edge-decile mass
$m \in (1/10, 1)$ determines a unique window ratio $r$ with $F_r(1/10) = m$. And
therefore two rate strata have the same edge-decile mass **if and only if** they
have the same window ratio. The observed edge deciles of $0.229$, $0.245$,
$0.230$ are, on this reading, three near-identical estimates of one underlying
geometric parameter — and the small spread among them is exactly what a genuine
comparison of strata should be measuring.

## When a regression tells you a beautiful lie

The experiment carried a second, cautionary arm. Alongside the main test, a
logistic occupancy regression was run on dense, size-matched *control* data —
data where, by construction, nothing should be found. It fired: a small p-value,
impressive odds ratios. Something had to be wrong, and the mathematics says
exactly what.

A design is **separated** by a direction $w$ if every positive case gets a
strictly positive score $\langle w, x_i\rangle$ and every negative case a
strictly negative one — the two classes are perfectly split by a hyperplane. This
is not exotic; it happens routinely when the design is dense and the outcome is
nearly determined by the covariates.

> **No-MLE Theorem.** On a separated design (with at least one observation) the
> logistic log-likelihood has **no** maximiser.

The proof is a two-step squeeze. Along the ray $t \mapsto tw$, each observation's
contribution $\ell_i(t) = -\log(1+e^{-s_i t})$ with $s_i > 0$ is strictly
increasing in $t$ and tends to $0$; so the total log-likelihood is strictly
increasing along the ray and converges to its supremum $0$, which it never
attains, because the log-likelihood is strictly negative whenever there is any
data at all. The "estimate" a fitting routine reports in this situation is not an
estimate. It is wherever the optimiser's own clipping bound stopped it — in the
flagged run, coefficients pinned at $e^{\pm 30}$. A p-value computed from such a
number is meaningless.

The repair is a ridge penalty. Maximise instead

$$\ell_\lambda(\beta) = \ell(\beta) - \lambda\|\beta\|^2, \qquad \lambda > 0.$$

> **Ridge Existence and Uniqueness.** For every design matrix, separated or not,
> and every $\lambda > 0$, the penalised log-likelihood has exactly one
> maximiser.

Two ingredients. *Concavity*: each logistic term is a linear term minus the
softplus of the score, and softplus is convex; the penalty is strictly concave by
the parallelogram law. Strict concavity forbids two maximisers. *Coercivity*: at
$\beta = 0$ the objective equals $-n\log 2$, and since the log-likelihood is
never positive, any $\beta$ with $\lambda\|\beta\|^2 > n\log 2$ does worse than
the origin — so a maximiser over the compact ball $\|\beta\|^2 \le n\log 2/\lambda$
is global.

That same inequality is the **upper half of an escape sandwich**: every ridge
maximiser satisfies

$$\lambda\|\hat\beta_\lambda\|^2 \le n\log 2,
\quad\text{so}\quad \|\hat\beta_\lambda\| = O(\lambda^{-1/2}).$$

The lower half quantifies the runaway. Write $\delta = -\ell(\beta) > 0$ for a
fitted vector's *likelihood deficiency*. Every individual contribution is at
least the total, which forces each score to satisfy
$|z_i| \ge \log(1/\delta) - \delta$; Cauchy–Schwarz then turns the score into a
norm bound:

$$\log\frac{1}{\delta} - \delta \ \le\ \|\beta\|\,\|x_i\|.$$

A near-perfect fit costs norm at least logarithmically in its deficiency. And on
a separated design the ridge estimate's deficiency really does vanish: comparing
$\hat\beta_\lambda$ against the competitor $tw$ along the separating ray gives
$\delta_\lambda \le -\ell(tw) + \lambda t^2\|w\|^2$, and choosing $t$ large and
then $\lambda$ small makes this arbitrarily small. Combining:

> **Escape Theorem.** On a separated design, the unique ridge estimator leaves
> every bounded set as $\lambda \downarrow 0$: $\|\hat\beta_\lambda\|^2 \to
> \infty$, at a rate no faster than $n\log 2/\lambda$ and no slower than the
> logarithm of the reciprocal deficiency.

The moral is sharper than "be careful with separation". A significant coefficient
from a separated arm is not merely unstable; it *diverges*, and the number you
see is a property of your software's arithmetic, not of your data. The
penalised fit is the honest replacement: bounded, uniquely determined, and with
its size an explicit function of the penalty you chose.

## Making a null result stand up

Two last pieces close the inferential loop, and they are the reason a null can be
reported with a straight face.

**Permutation tests are exactly valid in finite samples.** Let $G$ be a finite
set of relabellings and $t: G \to \mathbb{R}$ a test statistic. The permutation
p-value of the observed labelling $g$ is the fraction of relabellings at least as
extreme, $p(g) = \#\{h : t(g) \le t(h)\}/|G|$. Then for every $\alpha \ge 0$, at
most a fraction $\alpha$ of relabellings have $p \le \alpha$. The proof is a
small combinatorial gem: if $S = \{g : p(g) \le \alpha\}$ is nonempty, pick
$g_0 \in S$ minimising $t$; then $S \subseteq \{h : t(g_0) \le t(h)\}$, a set of
size $|G|\,p(g_0) \le \alpha|G|$. No distributional assumption, no asymptotics.
Also $p(g) > 0$ always — the observed labelling counts itself — which is why an
honest permutation p-value never reads exactly zero.

**Bonferroni is a union bound.** If each of $m$ p-values is super-uniform at
level $\alpha/m$, then the probability that any of them fires at that level is at
most $\alpha$. This is why a raw p-value of $0.0038$ across a family of thirteen
tests, adjusting to $0.049$ against a $0.05$ threshold, is not a finding. It is a
coin landing on its edge, and the correct response is to record it as a
non-firing and move on.

## What was learned

Strip away the machinery and three things remain.

First, **the two layers of a scan are independent objects, and they are
independent in the strong sense that neither constrains the other.** The rate
layer carries all the overdispersion; the positional layer carries a fixed,
scale-free harmonic shape with a strict early-window excess. Formally, "no
interaction" is rank-oneness of the occupancy table, and the standard test
statistics vanish precisely on that condition — so the test tests the hypothesis
it claims to.

Second, **the positional law is law-complete and arithmetic in origin.** Its
shape is $\log(1+(r-1)u)/\log r$; it is invariant under rescaling the window; its
leading decile always exceeds $1/10$; and it is the exact limit of a discrete
$1/j$ weight, with the Euler–Mascheroni constant cancelling in the difference of
harmonic numbers. It is even identifiable: one edge-decile number determines the
window ratio.

Third, **the unexplained rate variance is not carried by shape.** The
40–60% of the between-setting variance that remains unaccounted for is not
hiding in profile heterogeneity across terciles. Whatever the carrier is, it
governs how many events a setting produces, not where along the window they fall.
That is a genuinely narrowing result — and, if you want to find the carrier, a
map of where not to look.

Along the way there is a fourth lesson, less about this scan than about
statistics in general. A control arm that fires is not always a fluke to be
shrugged off. Sometimes it is a theorem in disguise, telling you that the
estimator you asked for does not exist. The fix is not to re-run with a different
seed. It is to change the objective to one that has an answer.
