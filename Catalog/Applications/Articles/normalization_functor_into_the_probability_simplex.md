# The Shape of Certainty: How One Simple Division Builds the World of Probability

Picture a weather forecaster's whiteboard at the end of a long shift. Scattered
across it are raw "scores" for tomorrow's possibilities — sun, clouds, rain,
snow — numbers like $7$, $2$, $1$, $0$. They are not probabilities. They don't
add up to anything in particular. They are just *weights*, gut-feeling tallies of
how plausible each outcome seems. And yet, with a single, almost embarrassingly
simple operation, the forecaster can turn that messy list into a clean, honest
statement of belief: *a $70\%$ chance of sun, $20\%$ clouds, $10\%$ rain, and
practically no snow.*

That operation is **normalization** — divide every number by the total. It is one
of the first tricks anyone learns in probability, so familiar that we rarely stop
to look at it. But underneath this little gesture hides a surprisingly rich and
beautiful structure. Normalization is not just a formula; it is a *map between
worlds*, and it obeys laws as elegant as any in geometry. This is the story of
those laws.

## The land of all possible beliefs

Every list of probabilities over a fixed set of outcomes lives in a single,
well-defined place that mathematicians call the **probability simplex**. If there
are $n$ possible outcomes, a probability assignment is a list of $n$ numbers
$p_1, p_2, \dots, p_n$, each one nonnegative, and all of them summing to exactly
one. Formally,

$$
\Delta = \Big\{\, p : \ 0 \le p_i \text{ for every } i, \quad \textstyle\sum_i p_i = 1 \,\Big\}.
$$

For three outcomes this set is a flat triangle floating in space — its three
corners are the "certain" beliefs (*definitely outcome 1*, *definitely outcome 2*,
*definitely outcome 3*), and every point inside is a shade of uncertainty. For
four outcomes it is a tetrahedron; for more, a higher-dimensional crystal. This
simplex is the *home of honest belief*. Anything living there is a genuine
probability distribution. Anything outside is just raw, un-normalized data.

The whiteboard scores $(7, 2, 1, 0)$ do **not** live in the simplex — they sum to
$10$, not $1$. They live in the much larger, sprawling region of all nonnegative
lists, which we'll call the **cone**: every direction of "more sun, less rain" is
allowed, at any scale. The cone is where data is born. The simplex is where it
becomes meaning. Normalization is the bridge.

## Normalization as a homecoming

Here is the bridge, written out:

$$
\mathrm{normalize}(v)_i \;=\; \frac{v_i}{\sum_j v_j}.
$$

Take each weight, divide by the grand total. The forecaster's $(7,2,1,0)$ becomes
$(0.7, 0.2, 0.1, 0)$, which sums to one. We have *landed in the simplex*. The
first law of normalization is exactly this homecoming:

> **Landing law.** If $v$ is a list of nonnegative weights with a positive total,
> then $\mathrm{normalize}(v)$ is a genuine probability distribution — it lies in
> the simplex.

So far, so expected. But the deeper magic begins when you ask what happens if you
*repeat* the operation, or *rescale* the input, or normalize something that is
already a probability distribution.

**It is the identity on the simplex.** If you hand normalization a list that
already sums to one, it gives it right back, untouched:

> **Retraction law.** If $p$ already lives in the simplex, then
> $\mathrm{normalize}(p) = p$.

This is the signature of a *retraction* — a map that gently folds the entire
sprawling cone down onto the simplex while leaving the simplex itself fixed in
place, the way a paper fan collapses onto its own outer edge. Honest beliefs are
already home; normalization doesn't disturb them.

**It is idempotent.** Once you've normalized, normalizing again changes nothing:

> **Idempotence law.** For *any* weight vector $v$,
> $\mathrm{normalize}(\mathrm{normalize}(v)) = \mathrm{normalize}(v)$.

This follows from the first two laws — the output of normalization lives in the
simplex, and on the simplex normalization is the identity. There is no "more
normalized than normalized." One pass suffices, forever.

**It ignores scale.** Double all the weights, triple them, halve them — the
resulting probabilities are identical:

> **Scale-invariance law.** For any nonzero number $c$,
> $\mathrm{normalize}(c \cdot v) = \mathrm{normalize}(v).$

The forecaster who writes $(7,2,1,0)$ and the one who writes $(70,20,10,0)$ hold
*exactly the same beliefs*. Normalization sees through scale entirely; it cares
only about *ratios*, the directions in the cone, not their length. In the
language of geometry, normalization factors through the **projectivization** of
the cone — the space of pure directions.

There is even a subtle bonus hiding in the arithmetic. What should happen if you
try to normalize the all-zeros list, where the total is $0$ and the division is
undefined? In ordinary mathematics this is a forbidden move. But by adopting the
clean convention that *dividing by zero yields zero*, normalization becomes
**totally defined**: it sends the degenerate zero vector to the zero vector. This
isn't a cheat — it's a feature. It means the idempotence and naturality laws below
hold with *no fine print*, no "provided the total is positive" caveat. The single
genuinely restricted law is the landing law, and for an excellent reason: the
zero vector can never sum to one, so it can never be a probability distribution.

## Coarsening the world without losing the plot

Now for the second character in our story. Imagine our forecaster decides the
distinction between "rain" and "snow" no longer matters for the day's plans — what
counts is simply "precipitation or not." This is an act of **coarse-graining**:
several fine-grained outcomes get lumped into one coarser outcome. Mathematically,
it is described by a function $f$ from the original outcomes to a smaller set of
new ones, and the weights flow accordingly. The operation is called the
**pushforward**:

$$
\mathrm{pushforward}(f, v)_k \;=\; \sum_{i \,:\, f(i) = k} v_i.
$$

In words: the weight of a coarse category $k$ is the sum of the weights of all the
fine outcomes that map into it. "Precipitation" inherits the combined weight of
rain plus snow. Statisticians call this taking a *marginal*; physicists call it
*integrating out* degrees of freedom; everyone agrees it's the natural way to view
a system at lower resolution.

The pushforward turns out to be a beautifully well-behaved operation — a
*functor*, in the precise sense that it respects the algebra of composing
coarsenings:

> **Identity law.** Coarse-graining by the do-nothing map (every outcome maps to
> itself) leaves the weights unchanged: $\mathrm{pushforward}(\mathrm{id}, v) = v.$

> **Composition law.** Coarsening in two stages gives the same result as coarsening
> once by the combined map:
> $\mathrm{pushforward}(g \circ f, v) = \mathrm{pushforward}\big(g, \mathrm{pushforward}(f, v)\big).$

Lump rain and snow into "precipitation," then later lump "precipitation" and
"clouds" into "not clearly sunny" — you reach the same place as if you'd planned
the whole grouping from the start. The bookkeeping is consistent at every level of
zoom.

Crucially, **the pushforward never loses or creates mass**:

> **Mass-preservation law.** The total weight is conserved:
> $\sum_k \mathrm{pushforward}(f, v)_k = \sum_i v_i.$

Nothing leaks out when you regroup; you're only rearranging the same total into
fewer bins. And this single fact has a powerful consequence. Because the total is
preserved and the entries stay nonnegative, **coarse-graining a probability
distribution yields a probability distribution**:

> **Simplex-preservation law.** If $p$ lives in the simplex over the fine outcomes,
> then $\mathrm{pushforward}(f, p)$ lives in the simplex over the coarse outcomes.

So the pushforward isn't just a functor on raw weights — it restricts to an
operation that takes honest beliefs to honest beliefs. It is, in the precise
technical sense, an **endofunctor of the probability simplex**: a structure-preserving
self-map of the world of distributions.

## The square that makes it all click

We now have two natural operations. One, *normalize*, turns raw weights into
probabilities. The other, *pushforward*, regroups outcomes at coarser resolution.
The forecaster faces a choice of order. She could:

- **Normalize first, then coarsen:** turn the raw scores into probabilities, then
  lump rain and snow together; or
- **Coarsen first, then normalize:** lump the raw rain and snow weights together,
  then turn the result into probabilities.

Do these two paths agree? The crowning result of this work says: *always, and with
no exceptions.*

> **Naturality law.** Normalizing and then coarse-graining gives exactly the same
> distribution as coarse-graining and then normalizing:
> $$
> \mathrm{normalize}\big(\mathrm{pushforward}(f, v)\big)
> \;=\;
> \mathrm{pushforward}\big(f, \mathrm{normalize}(v)\big).
> $$

This is what mathematicians call a **commuting square** or a **natural
transformation**, and it is the kind of statement that makes a theory feel
*inevitable* rather than merely true. It says the two operations don't interfere
with each other; the order of "make it a probability" and "change resolution"
simply doesn't matter. Whether you clean your data first or summarize it first,
you arrive at the identical belief.

Why is this true? The secret is the mass-preservation law. Coarse-graining keeps
the grand total fixed, so the *denominator* in the normalization — that crucial
"divide by the total" — is the same number whether you compute it before or after
regrouping. Once the denominators match, both sides reduce to the same elementary
fact: dividing a sum by a constant equals summing the divided pieces,
$\frac{\sum_i g_i}{c} = \sum_i \frac{g_i}{c}$. The whole edifice rests on the
distributive law of fractions, dressed in the right clothes.

And remarkably, like idempotence, the naturality law needs *no positivity
caveat*. Thanks to the divide-by-zero-is-zero convention, even the degenerate case
where all weights vanish makes both sides collapse harmlessly to the zero vector.
The equation holds universally.

## Why this is more than bookkeeping

It would be easy to dismiss all of this as the formal repackaging of grade-school
arithmetic. But the value of identifying these laws is exactly that they reveal
*grade-school arithmetic to be a small piece of a grand pattern* that recurs
across mathematics, statistics, physics, and machine learning.

In **machine learning**, every neural-network classifier ends with a
normalization step: a raw vector of "logits" — un-normalized scores for each
class — gets turned into a probability distribution. The scale-invariance law is
why you can rescale a model's outputs without changing its predicted
probabilities only up to the right transformation; the retraction and idempotence
laws are why repeated normalization is stable and safe.

In **statistics**, the pushforward is the marginal distribution, the single most
common operation in all of applied probability. The naturality law is the formal
reason you can summarize a survey before or after converting counts to
percentages and get the same answer — a fact every data analyst relies on
implicitly a hundred times a day.

In **physics**, integrating out microscopic degrees of freedom to obtain a
coarse-grained description is the heart of statistical mechanics and the
renormalization group. The mass-preservation and naturality laws are exactly the
consistency conditions that make such coarse-graining trustworthy: probability is
conserved, and the normalization "partition function" transforms predictably.

In **category theory**, the punchline is the cleanest of all. The pushforward is a
*functor* (it respects identities and composition), and normalization is a
*natural transformation* between functors. This is the language in which modern
mathematics expresses "this construction works the same way everywhere,
uniformly, without arbitrary choices." To say normalization is *natural* is to say
it is not an accident of how we wrote things down — it is woven into the structure
of probability itself.

## The beauty of the obvious

There is a particular kind of pleasure in taking something everyone thinks they
understand and showing that it was deeper than it looked. The forecaster's casual
division, the data analyst's percentages, the neural net's final layer — all of
them are performing the same homecoming, sending raw data back to the land of
honest belief. And that homecoming obeys laws: it lands where it should, it leaves
home untouched, it ignores scale, it commutes with coarsening.

Mathematics is full of cathedrals built from such humble bricks. Normalization is
one of those bricks. Look closely enough at the act of dividing by a total, and
you find a retraction onto a simplex, a functor of marginalization, and a natural
transformation linking them — a small, perfect machine that has been running
quietly inside every probability calculation you have ever made.
