# The Hidden Geometry of Learning to Decide

## How a single line of algebra explains why reinforcement learning works — and how to make it work better

Imagine you are teaching a robot to walk, a program to play chess, or a
recommendation engine to choose what to show you next. In each case the machine
faces the same fundamental problem: it must *choose an action*, watch what
happens, and then nudge its future choices toward the outcomes it liked. This is
the essence of **reinforcement learning**, and the family of algorithms that does
the nudging directly is called **policy gradient methods**.

Policy gradient methods are deceptively simple to describe and notoriously
finicky to use. They power some of the most spectacular results in modern AI —
robots that learn to manipulate objects, agents that master video games from raw
pixels, and the fine-tuning step that aligns large language models with human
preferences. Yet practitioners know them as temperamental: train the same agent
twice and you may get two wildly different results. The culprit is **noise**. The
signal that tells the agent how to improve is buried under a mountain of random
variation, and taming that noise is the difference between an algorithm that
learns and one that flails.

This article tells the story of that noise — where it comes from, what shape it
has, and a beautiful piece of mathematics that lets us measure it exactly and
then cut it down to the smallest possible amount. The remarkable thing is that
the entire story, despite being about randomness and learning and high-dimensional
geometry, can be told with nothing more than the algebra of a probability vector
that sums to one.

## The softmax: turning preferences into probabilities

Start with the simplest possible decision-maker. Suppose there are `n` possible
actions to choose from. The agent keeps a list of *scores* — one real number
`z_1, z_2, ..., z_n` for each action — representing how much it currently favors
each one. These scores can be anything: large, small, positive, negative.

To turn raw preferences into an honest probability distribution, we use the
**softmax** transformation. The probability of choosing action `j` is

> **π_j = exp(z_j) / (exp(z_1) + exp(z_2) + ... + exp(z_n)).**

Exponentiating makes every number positive; dividing by the total makes them sum
to one. The result is a genuine probability distribution over actions. Two facts
about it are so basic they are easy to overlook, yet everything downstream
depends on them:

- **Every action keeps a positive probability.** Because the exponential of any
  real number is strictly positive, we always have `π_j > 0`. The agent never
  *completely* rules out any option. This sounds like a minor technicality, but it
  is the safety rail that keeps the entire theory from collapsing: it guarantees
  that quantities like `log π_j` and the information-theoretic distances built
  from them are always finite, never the dreaded `log 0`.

- **The probabilities sum to exactly one.** As long as there is at least one
  action to choose from, `π_1 + π_2 + ... + π_n = 1`. (Amusingly, this fails if
  there are *zero* actions — an empty sum is zero, not one — which is exactly the
  kind of edge case that careful mathematics is obliged to notice.)

These two facts, positivity and normalization, are the bedrock. Everything that
follows is built by manipulating that single equation `Σ π_j = 1`.

## The score function: which way is uphill?

The agent wants to improve. Concretely, it wants to adjust its preference scores
`z_j` so that good actions become more likely. To do that it needs to know, for
each preference knob `z_j`, *which way is uphill* — how a small twist of that knob
changes the probability of the action it just took.

Calculus gives a startlingly clean answer. If the agent took action `a`, then the
sensitivity of `log π(a)` to the knob `z_j` is

> **ψ_j(a) = [a = j] − π_j,**

where `[a = j]` is `1` if the action taken was exactly `j` and `0` otherwise. This
quantity is called the **score function**. Read it out loud: *"one if you took
this action, zero if you didn't, minus how likely you thought it was."* It is the
difference between what happened and what was expected.

The score function has a magical property that is the secret engine of all policy
gradient methods. Average it over the agent's own behavior — weight each action by
how likely the agent was to take it — and you get **exactly zero**:

> **E_π[ψ_j] = Σ_a π_a · ([a = j] − π_j) = π_j − π_j · 1 = 0.**

Why does this matter? It is the mathematical statement of an obvious intuition:
*on average, your expectations are correct.* The surprises (you took an action you
thought unlikely) and the non-events (you skipped an action you thought likely)
cancel out perfectly. This zero-mean property is what makes the policy gradient an
*unbiased* estimate of the true direction of improvement — it points the right way
on average — and it is the lever we will pull again and again.

## The Fisher matrix: the curvature of belief

So far we have a single direction of improvement. But the agent has many knobs,
and twisting one affects the others. To navigate this coupled landscape we need to
understand its *geometry* — and geometry, in the world of probability, is
governed by an object called the **Fisher information matrix**.

The Fisher matrix `F` collects the correlations between all the score directions:
its entry in row `j`, column `k` is the average product `E_π[ψ_j · ψ_k]`. Grinding
through the algebra — expand the product, use the indicator collapse, invoke
`Σ π = 1` — yields a closed form of astonishing simplicity:

> **F_{jk} = π_j · [j = k] − π_j · π_k.**

In matrix language, `F = diag(π) − π πᵀ`: a diagonal matrix of probabilities
minus the outer product of the probability vector with itself. This single
expression encodes the entire local geometry of the agent's decision-making. It is
**symmetric** — `F_{jk} = F_{kj}`, as any honest notion of "correlation between
`j` and `k`" must be — and it has one more property that turns out to be the whole
ballgame.

## Variance in disguise: why the geometry is never negative

Here is the conceptual leap. Take any direction `v = (v_1, ..., v_n)` in the
space of preference knobs and ask: how much does the geometry stretch in that
direction? The answer is the quadratic form `vᵀ F v`. A foundational requirement
of any sensible geometry is that this quantity is never negative — distances can't
be imaginary.

The proof is not a grind; it is a revelation. The quadratic form turns out to be a
**variance in disguise**:

> **vᵀ F v = E_π[ (Σ_j v_j ψ_j)² ] ≥ 0.**

Read the right-hand side: it is the average of a *squared* quantity, and a square
is never negative, so the average can't be either. The mysterious matrix `F` is,
at heart, just the variance of the random quantity `Σ_j v_j ψ_j` — the score
component along the chosen direction. The Fisher matrix is **positive
semidefinite** not by abstract decree but because it *is* a variance.

This single fact licenses the entire field of **natural policy gradients**, which
use `F` as a "ruler" to measure distances between policies. Because `F` is a
genuine, non-negative geometric object, it defines a meaningful notion of "how far
apart" two policies are — the Fisher–Rao metric — and following the gradient
*through* this metric, rather than the naive Euclidean one, gives an update rule
that is invariant to how you happened to parameterize the problem. The agent
improves the same way whether you measured its preferences in one unit or another.
That invariance, the holy grail of robust optimization, rests on the humble fact
that a square is never negative.

## The baseline trick: subtracting nothing to gain everything

Now we come to the practical heart of the matter — the part that turns a beautiful
theory into a tool that actually works.

The agent estimates its improvement direction by multiplying the *return* `R(a)`
(how good the outcome was) by the score `s(a)` (which way is uphill). The trouble
is that this estimate is enormously noisy. If all your returns are large positive
numbers — say every game gives you a reward between 100 and 110 — then every
action looks "good," and the tiny *differences* that actually matter are drowned
out by the huge common offset.

The fix is a trick so elegant it feels like cheating. Subtract a constant `b`,
called a **baseline**, from every return before multiplying by the score. Use
`(R(a) − b) · s(a)` instead of `R(a) · s(a)`. The miracle is that **this changes
nothing on average**:

> **E_π[ (R − b) · s ] = E_π[ R · s ] − b · E_π[s] = E_π[ R · s ].**

The correction term vanishes because — recall the magical property — the average
score `E_π[s]` is exactly zero. So no matter what baseline you subtract, the
estimate still points the right way on average. We have changed the estimator's
*noise* without touching its *signal*. This is called the **baseline-unbiased**
property, and it is the entire reason baselines are allowed.

If subtracting a baseline doesn't change the average, what does it change? The
**variance** — and that is precisely what we want to shrink.

## The exact optimal baseline

How noisy is the baselined estimate? Its second moment — the quantity whose
reduction we care about — turns out to be a perfect parabola in the baseline `b`:

> **M(b) = A · b² − 2B · b + C,**

where the three coefficients are simple averages over the agent's behavior:

> **A = E_π[s²],   B = E_π[R · s²],   C = E_π[R² · s²].**

A parabola opening upward has a unique lowest point, and here it sits at

> **b⋆ = B / A = E_π[R · s²] / E_π[s²].**

This is the **optimal baseline**: the single number that squeezes the most noise
out of the estimate. It is not the average return, as folklore sometimes suggests —
it is a *score-weighted* average of the return, weighting each action by how
sensitive the policy is there.

The crowning result tells us *exactly* how much we gain by choosing well. For any
baseline `b`, the gap above the optimum is a clean square:

> **M(b) − M(b⋆) = A · (b − b⋆)².**

Read what this says. The excess noise from using the wrong baseline is the
*squared distance* from the right one, scaled by `A = E_π[s²]`, which is always
non-negative. Three powerful conclusions fall out of this one identity with no
further work:

- **`b⋆` is a minimizer:** since `A · (b − b⋆)² ≥ 0`, every other baseline gives a
  second moment at least as large.
- **`b⋆` is the *unique* minimizer:** if `b ≠ b⋆` and the score has any variation
  at all (`A > 0`), then `A · (b − b⋆)² > 0` strictly — every wrong baseline is
  *strictly* worse.
- **The penalty is quadratic:** small mistakes in the baseline cost little, but
  large ones cost dramatically more.

There is something deeply satisfying here. The entire theory of variance reduction
by baselines — a workhorse of practical reinforcement learning, the foundation of
"actor-critic" methods where a learned value function plays the role of the
baseline — collapses into the geometry of a single parabola. Find its vertex, and
you have found the best possible baseline. Measure your distance from the vertex,
and you know exactly how much performance you left on the table.

## Why algebra, not analysis

Perhaps the most surprising aspect of this whole edifice is what it *doesn't*
require. Reinforcement learning is usually presented in the language of measure
theory, stochastic processes, and infinite-dimensional optimization — heavy
machinery for a heavy subject. Yet everything above — the zero-mean score, the
closed-form Fisher matrix, its positive-semidefiniteness, the optimal baseline and
its exact variance reduction — is **pure finite algebra over a probability
vector**.

There is a single technique behind every proof: expand the square or the product,
push the constants through the sum, collapse the indicators, and reduce everything
to the law that `Σ π = 1`. The same five-finger exercise, applied over and over,
unfolds the entire first-order theory. The randomness that makes reinforcement
learning so daunting in practice turns out, at its mathematical core, to be
governed by the gentle algebra of averages.

## The bigger picture

Why should anyone outside a machine-learning lab care? Because the ideas here are
universal. The score function — *what happened minus what was expected* — is the
same prediction-error signal that neuroscientists believe the brain's dopamine
system computes. The Fisher matrix is the same object that statisticians use to
quantify how much information a sample carries, and that physicists meet in the
geometry of thermodynamic states. The baseline trick is a special case of
*control variates*, a centuries-old idea for taming randomness that appears
everywhere from financial simulation to particle physics.

What this work provides is a rock-solid foundation for all of it: definitions
stated with no ambiguity, theorems proved with no gaps, and a guarantee that the
intuitive pictures — *expectations are right on average*, *the geometry is a
variance*, *the best baseline sits at the bottom of a parabola* — are not just
appealing stories but precise, verified mathematics.

The next time a learning agent surprises you by mastering a task no one
hand-coded, remember the quiet algebra underneath: a vector that sums to one, a
prediction error that averages to zero, and a parabola whose lowest point tells
you exactly how to listen past the noise.
