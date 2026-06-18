# How Do You *Prove* That Something Is New?

## The everyday problem hiding inside a deep question

A spam filter sees an email it has never quite seen before. A bank's
fraud detector flags a transaction that does not look like any of the
millions it has on file. A telescope survey pipeline spots a flicker of
light that matches nothing in its catalogue of known stars. A
language model is asked whether a sentence is genuinely original or a
near-copy of something it was trained on.

All four systems are doing the same thing, and it is harder than it
sounds. They are trying to answer a deceptively simple question:

> **Is this thing actually new — and how sure can we be?**

We usually treat "novelty" as a vague, soft judgment: a score spat out
by a black box, a number we squint at and threshold. But novelty can be
made *exact*. It can be turned into a mathematical certificate: a
guarantee, with a provable margin, that a new observation is genuinely
far from everything already known. And once it is a certificate, you can
ask the questions engineers really care about. Does the guarantee
survive if the measurement is a little noisy? Does it survive after the
data is squeezed through a neural network? Can you guarantee it not for
one point, but for a whole *region* of possible future observations? Can
you do it not for single data points, but for entire shapes and
clusters?

This article is the story of a small but complete mathematical theory
that answers exactly those questions — and does so with the full rigour
of formally verified mathematics, where every theorem is checked by a
machine down to the axioms.

## The one idea: distance is everything

Start with the only ingredient we need. Suppose all your knowledge —
every email, transaction, star, or sentence you have ever recorded —
lives as a set of points $S$ in some space where you can measure
*distance* between points. Call this a **metric space**: a set with a
distance function $\mathrm{dist}(x, y)$ that is symmetric, never
negative, zero only when $x = y$, and obeys the triangle inequality.

Now a new observation arrives as a point $x$. The most natural measure of
how novel $x$ is is simply: **how far is $x$ from the nearest thing I
already know?** That single number is the *novelty score*:

$$
\mathrm{noveltyScore}(S, x) \;=\; \inf_{s \in S} \mathrm{dist}(x, s).
$$

If the nearest known point is far away, $x$ is novel. If something in
your archive is almost on top of $x$, it is not. That is the whole idea —
and remarkably, everything else in the theory is a consequence of it.

Alongside the score we use a crisp yes/no version. Fix a threshold
$\varepsilon > 0$. We say $x$ is **$\varepsilon$-novel** with respect to
$S$ if it stands at least $\varepsilon$ away from *every* known point:

$$
\mathrm{IsNovel}(\varepsilon, S, x) \quad\Longleftrightarrow\quad
\varepsilon \le \mathrm{dist}(x, s)\ \text{ for all } s \in S.
$$

The first theorem says these two views are the same. For any nonempty
reference set $S$,

$$
\mathrm{IsNovel}(\varepsilon, S, x) \quad\Longleftrightarrow\quad
\varepsilon \le \mathrm{noveltyScore}(S, x).
$$

This is the bridge between a *predicate* (a certificate you can hand to a
verifier) and a *score* (a number you can optimize, sort, and threshold).
The certificate $\mathrm{IsNovel}$ is exactly "the score clears the bar."
A worked example: with $S = \{(0,0), (3,0), (0,4)\}$ and a query at
$(1,1)$, the score is $\sqrt 2 \approx 1.414$. The point is
$1.4$-novel but not $2$-novel — and both the predicate test and the
score test agree on that, exactly as the theorem promises.

## Novelty is robust — and that is a theorem, not a hope

A score is only useful if it does not collapse under the slightest
disturbance. Real measurements jitter. So the first thing we must prove
is that the novelty score is *stable*.

It is — in the strongest possible sense. The novelty score is
**1-Lipschitz** in the query point:

$$
\bigl|\mathrm{noveltyScore}(S, x) - \mathrm{noveltyScore}(S, y)\bigr|
\;\le\; \mathrm{dist}(x, y).
$$

Move the query by a millimetre and the score changes by at most a
millimetre. No cliffs, no discontinuities, no adversarial knife-edges.
Novelty cannot be destroyed by noise smaller than the margin you already
have.

This stability has a clean certificate-level form, the **triangle
transfer** theorem. If $x$ is $\varepsilon$-novel and a new query $y$
lands within $\delta$ of $x$, then $y$ is guaranteed to be at least
$(\varepsilon - \delta)$-novel:

$$
\mathrm{dist}(x, y) \le \delta \ \text{ and } \ \mathrm{IsNovel}(\varepsilon, S, x)
\quad\Longrightarrow\quad \mathrm{IsNovel}(\varepsilon - \delta, S, y).
$$

You spend exactly $\delta$ of your novelty budget to absorb a
$\delta$-sized perturbation. Nothing more. The proof is one line of the
triangle inequality, but the consequence is profound: certified novelty
comes with a built-in tolerance, and the tolerance is sharp.

There is a second, equally intuitive monotonicity. The more you know, the
less anything can surprise you. Formally, the novelty score is
**antitone in the reference set**: if $T \subseteq S$, then

$$
\mathrm{noveltyScore}(S, x) \;\le\; \mathrm{noveltyScore}(T, x).
$$

Adding facts to your archive can only lower novelty scores, never raise
them. A certificate proven against a large knowledge base automatically
holds against any smaller subset.

## Carrying certificates through transformations

Modern data is rarely used raw. It is embedded, projected, encoded —
pushed through a learned map $f$ before anyone compares anything. The
critical worry is whether a novelty guarantee in the original space still
means anything after the transformation.

Here the theory makes a sharp distinction. Maps that *expand* distances
preserve novelty; maps that *crush* distances can destroy it.

An **antilipschitz** map with constant $K$ is one that never lets points
collapse too far together: $\mathrm{dist}(x, s) \le K \cdot
\mathrm{dist}(f(x), f(s))$. Such maps are *expanding*. For them we get a
clean transport theorem: if $x$ is $\varepsilon$-novel against $S$, then
$f(x)$ is $(\varepsilon/K)$-novel against the image $f(S)$.

$$
\mathrm{IsNovel}(\varepsilon, S, x) \quad\Longrightarrow\quad
\mathrm{IsNovel}\!\left(\tfrac{\varepsilon}{K}, \ f(S), \ f(x)\right).
$$

Novelty survives — the threshold is merely rescaled by the geometric
distortion of the map. A bi-Lipschitz embedding (expanding *and* bounded)
transports certificates faithfully in both directions. This is the
theoretical license that lets you certify novelty in a convenient
feature space and trust it back in the original.

## When the map is only *approximately* faithful

Real encoders are not exactly Lipschitz. A neural network layer obeys a
distance bound only up to some additive slack. So the theory introduces
**approximately-Lipschitz** maps: those satisfying

$$
\mathrm{dist}(f(x), f(y)) \;\le\; K \cdot \mathrm{dist}(x, y) + c,
$$

with a multiplicative factor $K$ and an additive error budget $c$. The
exact theory is recovered when $c = 0$.

The beautiful fact is how errors *compose*. Stack a $(K_2, c_2)$ layer on
top of a $(K_1, c_1)$ layer and the result is approximately Lipschitz with

$$
(K_2, c_2) \circ (K_1, c_1) \;=\; (K_2 K_1,\; K_2 c_1 + c_2).
$$

The multiplicative parts multiply; the additive errors accumulate, each
amplified by the layers above it. Iterate a single $(K, c)$ layer $n$
times and the error budget becomes a geometric series with a clean closed
form:

$$
\Bigl(K^n,\ c \cdot \tfrac{K^n - 1}{K - 1}\Bigr).
$$

This is a **depth budget**: an exact accounting of how much certified
novelty an architecture of given depth can afford before its guarantees
go vacuous. In our running example a $(1.5, 0.4)$ layer iterated five
times accumulates an error of exactly $5.275$ — and the closed form
agrees with the brute-force composition to the last digit. The
error-aware transport theorem then deflates a threshold $\varepsilon$
through one layer to $(\varepsilon - c)/K$: you pay the additive error
first, then the multiplicative rescaling.

## From points to regions: the shape of all possible discoveries

So far we have certified single points. But often you want to reason
about *every* point a future observation might occupy. That calls for a
change of viewpoint — from points to **regions**.

Fix the reference set $S$ and a threshold $\varepsilon$. The **novelty
region** is the collection of all queries that would clear the bar:

$$
\mathrm{noveltyRegion}(S, \varepsilon) \;=\;
\bigl\{\, x \ : \ \varepsilon < \mathrm{noveltyScore}(S, x) \,\bigr\}.
$$

Because the score is continuous (indeed 1-Lipschitz), this region is an
**open set** — it has no jagged boundary, and around every certified-novel
point there is a whole neighbourhood of certified-novel points. Stability
of points becomes openness of regions.

Now vary the threshold. As you demand more and more novelty (larger
$\varepsilon$), the region shrinks. The family of regions is a
**decreasing filtration**:

$$
\varepsilon_1 \le \varepsilon_2 \quad\Longrightarrow\quad
\mathrm{noveltyRegion}(S, \varepsilon_2) \subseteq
\mathrm{noveltyRegion}(S, \varepsilon_1).
$$

This is precisely the structure that topologists call a *filtration*, the
backbone of **persistent homology**. Reading it through that lens, the
novelty score of a point becomes its **birth time**: a point $x$ "is
born" into the novel region exactly at the moment $\varepsilon$ drops
below its score. Its lifespan — its barcode — is the half-line
$[0, \mathrm{birthTime}(S, x))$, and

$$
x \in \mathrm{noveltyRegion}(S, \varepsilon)
\quad\Longleftrightarrow\quad
\varepsilon < \mathrm{birthTime}(S, x).
$$

Suddenly the engineering question "which observations are novel at margin
$\varepsilon$?" is the same as the topological question "which features
are alive at filtration value $\varepsilon$?" The novelty filtration is
the order-reverse of the union-of-balls (Čech) filtration used to study
the *shape* of data: a point is novel exactly when it has escaped every
$\varepsilon$-ball around the known set.

## From points to sets: novelty of whole shapes

The final move is the boldest. Sometimes the thing you want to certify as
novel is not a point at all — it is a *cluster*, a *trajectory*, a
*shape*. Is this newly discovered protein fold unlike any in the
database? Is this attack pattern unlike any known campaign?

The trick is a piece of mathematical jujitsu: **treat each set as a single
point** in a larger space. The space of (nonempty, compact) sets carries
its own natural distance — the **Hausdorff distance**, which measures how
far two shapes are by the worst-case nearest-neighbour mismatch between
them:

$$
\mathrm{hausdorffDist}(A, B) = \max\Bigl(
\sup_{a \in A}\inf_{b \in B}\mathrm{dist}(a,b),\;
\sup_{b \in B}\inf_{a \in A}\mathrm{dist}(a,b)\Bigr).
$$

Once sets are points of a metric space, *every theorem above applies
again, for free*. Novelty of a shape against a family of known shapes,
the triangle-transfer robustness, the antitonicity — all of it transports
verbatim through this dictionary. A set $A$ is $\varepsilon$-novel against
a family $\mathcal F$ when its Hausdorff distance to every known set is at
least $\varepsilon$. In our demonstration a candidate cluster sits
Hausdorff-distance $10$ and $11.2$ from the two known clusters, certifying
it as $8$-novel as a *shape*, not merely as a collection of points.

And the score behaves regularly in this lifted space too: the birth time
is **1-Lipschitz in the reference set** under Hausdorff distance. Wiggle
your entire knowledge base by a small Hausdorff perturbation and every
barcode endpoint moves by at most that amount. The whole persistence
diagram is stable not only to noise in the query but to noise in what you
*know*.

## Why machine-checked rigour matters here

Every statement above is more than a sketch. The framework has been
formalized and verified in a proof assistant: the definitions are exact,
the proofs are checked mechanically, and the certificates are sound by
construction. When the theory says a perturbed query retains
$(\varepsilon - \delta)$ novelty, that is not a heuristic that usually
holds — it is a theorem that *always* holds, audited down to the logical
axioms.

For applications where novelty triggers consequential decisions — a
fraud alert, a safety override, a "this looks like a new disease variant"
flag — that distinction is everything. A novelty *score* tells you a
system's opinion. A novelty *certificate*, backed by a verified
mathematical theory, tells you a guarantee with a number attached.

## The takeaway

The theory of certified novelty grows from a single seed — distance to
the nearest known thing — and unfolds along three directions that mirror
each other beautifully:

- **Points become regions**, and stability becomes openness, threading
  novelty into the language of persistent homology and birth times.
- **Exact maps become approximate maps**, and a single composition law
  yields an exact depth budget for how much novelty an architecture can
  certify.
- **Points become sets**, and the same theorems re-emerge one dimension
  up, certifying the novelty of entire shapes through the Hausdorff
  metric.

Three times over, a hard problem is solved by translating it into an
easier dual one and carrying the structure across. The result is a
compact, rigorous, and genuinely useful answer to a question that touches
spam filters, fraud detectors, telescopes, and frontier AI alike:
*how do you prove that something is new?*
