# How Much Can a Model Memorize Noise? The Hidden Geometry of Overfitting

Imagine you are a teacher giving a pop quiz. You write ten true/false
questions, but instead of asking real questions, you flip a coin for each
one and declare the coin's result to be the "correct" answer. The quiz is
pure noise. Now you hand it to your students and watch.

A weak student — say, one who always answers "true" no matter what — will
score about five out of ten by luck, and *only* by luck. A devastatingly
clever student, on the other hand, might somehow notice subtle, meaningless
patterns and ace your random quiz. That clever student should worry you.
A mind flexible enough to "learn" pure noise is a mind that will happily
hallucinate patterns where none exist.

This little thought experiment is, almost exactly, one of the most
important ideas in modern machine learning. It has a name — **Rademacher
complexity** — and it is the mathematical instrument we use to measure how
dangerously flexible a learning system is. This article tells the story of
that instrument, and of a clean, fully rigorous reconstruction of its core
mathematics: a handful of theorems that pin down precisely what it means for
a family of models to be able (or unable) to chase random noise.

## The richness of a class, not the cleverness of one function

Here is the first surprise, and it is a deep one. Rademacher complexity is
*not* a property of any single model. It is a property of an entire **family**
of models — what statisticians call a *hypothesis class*. A single fixed
function, no matter how wiggly or expressive it looks, has zero Rademacher
complexity. The danger only emerges from *choice*: from a learner's freedom
to rummage through many candidate functions and pick whichever one happens to
fit the noise best.

To make this precise without drowning in technicalities, we adopt a beautifully
economical point of view. Fix your sample — the `n` data points
`x₁, x₂, …, xₙ`. We do not care what a model *is* internally; we care only about
what it *does* on these `n` points. So we identify each model `f` with the
single vector of its outputs,

> `(f(x₁), f(x₂), …, f(xₙ))`,

a list of `n` real numbers. A whole hypothesis class then becomes nothing more
exotic than a finite collection `F` of such vectors — a finite set of points in
`n`-dimensional space. This "behavior on the sample" representation throws away
everything irrelevant and keeps exactly what matters for generalization.

## The coin flips, made mathematical

Now we bring in the coins. A **sign pattern** is a choice of `+1` or `−1` for
each of the `n` data points — exactly the random "answer key" of our pop quiz.
There are `2ⁿ` such patterns. We write each as a function `σ` assigning a sign
`σᵢ ∈ {+1, −1}` to each point `i`.

Given a sign pattern `σ` and a model behavior vector `v = (v₁, …, vₙ)`, their
**correlation** is the dot product

> `corr(σ, v) = σ₁v₁ + σ₂v₂ + ⋯ + σₙvₙ`.

This number is large and positive exactly when the model's outputs line up with
the random signs — when the model "agrees with the noise." A learner, free to
pick the best model in its class, will choose whichever `v ∈ F` maximizes this
correlation. So for a fixed sheet of random answers `σ`, the learner's best
possible score is

> `sup_{v ∈ F} corr(σ, v)`.

Finally, the random answer key was, well, random. So we average over all `2ⁿ`
possible sheets, and we normalize by the number of points `n`. This gives the
**empirical Rademacher complexity** of the class `F`:

> `empRad(F) = (1 / (2ⁿ · n)) · Σ_σ  sup_{v ∈ F}  corr(σ, v)`.

In words: *across all possible random labelings, how well, on average, can the
best model in my class chase the noise?* A high number means the class is
flexible enough to be dangerous. A low number means the class is honest — it
cannot fit randomness, so when it *does* fit your real data, the fit means
something.

This single formula is the protagonist of our story, and everything below is a
theorem about it — each one proved completely and checked to the last detail.

## One cancellation to rule them all

When you stare at the formula, a worry creeps in. It is a sum over `2ⁿ` terms,
each one a maximum over a set — a tangle of suprema and exponentially many
coin flips. How could anything clean ever come out of it?

The answer is a single, elegant cancellation, and it is the seed from which the
entire theory grows. Pick any one coordinate `i` — say, the third data point.
Ask: if I add up the sign `σᵢ` across *all* `2ⁿ` patterns, what do I get?

> **Sign cancellation.** For every coordinate `i`,
> `Σ_σ σᵢ = 0`.

The reason is irresistibly simple. Pair up the sign patterns: take any pattern
`σ`, and flip *only* its `i`-th sign, leaving all the others alone. This pairing
is a perfect partner-matching of all `2ⁿ` patterns (flip twice and you are back
where you started). Within each pair, the two values of `σᵢ` are `+1` and `−1`,
which add to zero. Sum over all the pairs, and the whole thing vanishes. The
coins, summed over every possible outcome, balance perfectly.

In the formal development this is the lemma `signSum_coord_eq_zero`, proved by
packaging the "flip coordinate `i`" operation as a genuine permutation of the
set of sign patterns and invoking the fact that summing a function over a
permuted index set gives the same total. That forces the sum `S` to equal its
own negative, `S = −S`, and the only number equal to its negative is zero. It is
a one-line miracle, and astonishingly, *every* elementary property of Rademacher
complexity flows from it.

## A lone model is harmless

Our first real theorem is the mathematical version of the claim we opened with:
a single fixed model cannot, on average, chase noise.

> **Singleton theorem.** If the class contains exactly one model behavior `v`,
> then `empRad({v}) = 0`.

Why? With only one choice, there is no "best" to pick — the maximum is just
`corr(σ, v)` itself. So the numerator becomes `Σ_σ corr(σ, v)`. Swap the order
of summation so that we sum over coordinates on the outside and over sign
patterns on the inside. For each coordinate `i`, the inner sum is `vᵢ · (Σ_σ σᵢ)`,
and by our cancellation lemma that parenthesized sum is zero. Every coordinate
contributes nothing; the total is zero. (This is the theorem `empRad_singleton`.)

This is reassuring and clarifying at once. It confirms that empirical Rademacher
complexity measures the *richness of the class* — the breadth of choice — and not
the intrinsic wiggliness of any one function. A single absurdly complicated
function is, by this measure, perfectly safe. It is the *freedom to choose among
many* that creates the capacity to overfit.

## Containing zero keeps you honest

Could the complexity ever be negative? At first glance, nothing forbids it — a
supremum of correlations could in principle be driven negative if every model
in the class systematically anti-correlated with most sign patterns. But there
is a clean condition that rules this out.

> **Nonnegativity theorem.** If the all-zeros behavior `0` belongs to the class
> `F`, then `empRad(F) ≥ 0`.

The argument is a single observation. Because `0 ∈ F`, the learner always has
the *option* of choosing the zero model, whose correlation with any sign pattern
is exactly `0`. The best choice can only do better, so each term in the sum is at
least `0`. The numerator is therefore nonnegative, the denominator `2ⁿ · n` is
nonnegative, and the quotient is nonnegative. (This is `empRad_nonneg`.) The
zero model acts as a floor: a class that can always "decline to predict" can
never have negative complexity.

## More choices, more danger

Next comes the structural backbone of the whole subject — the property that lets
us reason about gigantic, complicated classes by sandwiching them between simpler
ones.

> **Monotonicity theorem.** If one class `F` is contained in another class `G`,
> then `empRad(F) ≤ empRad(G)`.

Intuitively obvious, and beautifully so: a learner with strictly more models to
choose from can never do *worse* at chasing noise. For each fixed sign pattern,
the best correlation over the larger set `G` is at least the best correlation
over the smaller set `F`, because every option in `F` is also an option in `G`.
This holds pattern by pattern; summing preserves the inequality, and dividing by
the positive denominator preserves it again. (This is `empRad_mono`.) In
practice this is the theorem that earns its keep: to bound the complexity of a
sprawling neural network class, find a simpler class that contains it and bound
*that*.

## The ceiling: you cannot fit more than you are allowed to output

Finally, the simplest of safety guarantees. Suppose every model in your class is
*bounded*: no output ever exceeds some value `B` in magnitude. Then the class
simply cannot be too dangerous.

> **Uniform bound.** If `|vᵢ| ≤ B` for every model `v` in the class and every
> coordinate `i`, then `empRad(F) ≤ B`.

The reasoning is direct. For any sign pattern, the correlation
`Σᵢ σᵢ vᵢ` is at most `Σᵢ |vᵢ|`, which is at most `n · B` because there are `n`
coordinates each bounded by `B`. Averaging these capped correlations and dividing
by `n` leaves a clean ceiling of `B`. (This is `empRad_le_of_bounded`; the only
subtlety is the degenerate case `n = 0`, an empty sample, which is handled
separately because the denominator vanishes.) This is the crude but universal
guarantee: bounded outputs mean bounded capacity to overfit.

## Why this matters beyond the blackboard

These five results — sign cancellation, the harmless singleton, nonnegativity,
monotonicity, and the uniform ceiling — may look modest. But together they form
the rigorous skeleton of *generalization theory*, the branch of machine learning
that explains why a model trained on a finite sample can be trusted on data it
has never seen.

The logic runs like this. The gap between how well a model does on your training
data and how well it will do in the real world is controlled, mathematically, by
the Rademacher complexity of the class you trained over. A class with low
complexity *cannot* fit noise, so a good fit to your data is strong evidence of a
real pattern. A class with high complexity might be fitting nothing but the
accidents of your particular sample, and its training performance tells you
little. Every modern bound on overfitting — for support vector machines, for
boosting, for deep networks — passes through a quantity exactly like the one we
defined.

This is why the choice to represent models by their *behavior on the sample* is
so powerful. It strips away architecture, parameters, and training dynamics, and
leaves only the geometric essence: a finite cloud of points whose ability to
align with random sign patterns is its capacity to deceive.

## The frontier: beating the trivial ceiling

There is one prize we deliberately left on the table, and naming it is the honest
way to end. The uniform bound `empRad(F) ≤ B` is true but blunt — it ignores
*how many* models the class contains. The celebrated **Massart finite-class
bound** sharpens it dramatically: for a class of `|F|` bounded behaviors, the
complexity actually shrinks like

> `empRad(F) ≲ B · √(2 log|F| / n)`.

That square-root-of-log factor is the difference between a useless guarantee and
a practical one. It says that even a class with astronomically many models is
safe, provided the *logarithm* of its size is small compared to the number of
samples — which is why models with billions of parameters can still generalize
from modest data.

Proving it requires a genuinely different tool: a probabilistic concentration
argument (the sub-Gaussian, or Hoeffding, inequality) that controls how the
maximum of many random correlations behaves. Our order-theoretic toolkit — built
entirely from cancellation and monotonicity — is not equipped to reach it. It
stands as the clearly marked next mountain, a conjecture awaiting the analytic
machinery that the next chapter of this work will build.

For now, we have something solid and complete: a transparent, fully verified
account of what it means for a family of models to be able to chase noise — and a
single, perfect cancellation of coin flips at the heart of it all.
