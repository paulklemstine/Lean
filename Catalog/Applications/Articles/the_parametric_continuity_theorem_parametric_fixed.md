# The Stubborn Geometry of Self-Consistency

## When the answer depends on itself

Some of the most important quantities in science are defined by a strange kind of
circular reasoning. The price that clears a market depends on how buyers and
sellers behave — but how they behave depends on the price. The equilibrium of a
population depends on its growth rate — which depends on the population. The output
of a neural network at a recurrent layer feeds back into its own input. In each
case we are not looking for a number we can simply compute and write down. We are
looking for a number that is *consistent with itself*: a value `x` that, when you
run it through the rule of the system, gives you back `x` again.

Mathematicians call such a value a **fixed point**, and the equation that defines
it is disarmingly simple:

> `x = f(x)`.

Here `f` is the rule of the system — the map that takes a candidate answer and
returns the consequence of believing it. A fixed point is a candidate that survives
its own consequences.

The remarkable thing is that, for an enormous class of these self-referential
systems, there is exactly one such surviving value, you can find it by brute-force
repetition, and — this is the part most people never hear — you can say precisely
how the answer *moves* when you nudge the system that produced it. That last
sentence is the subject of this article. It is the difference between knowing that
an equilibrium exists and knowing how fragile or robust it is.

## The contraction: a machine that forgets where it started

The engine behind all of this is an idea called a **contraction**. Picture any rule
`f` that takes points and moves them around. Call it a contraction if it always
pulls points *closer together*. Concretely, fix a number `K` strictly between 0 and
1 and demand that for any two points `x` and `y`,

> `distance(f(x), f(y)) ≤ K · distance(x, y)`.

Every time you apply `f`, the gap between any two points shrinks by at least a
factor of `K`. Apply it twice and the gap shrinks by `K²`. Apply it `n` times and
the gap is down to `Kⁿ` of where it started — and since `K < 1`, that races toward
zero.

This single property has a spectacular consequence, discovered by Stefan Banach in
1922 and now bearing his name. **A contraction on a complete space has exactly one
fixed point, and you can find it by starting anywhere and repeatedly applying the
rule.** Start with a wild guess `x₀`, compute `x₁ = f(x₀)`, then `x₂ = f(x₁)`, and
so on. The points crowd together so aggressively that they have nowhere to go but a
single limiting value — and that value is the unique `x` with `x = f(x)`. The map
literally forgets where you started; all roads lead to the same destination, and
they get there at the geometric rate `Kⁿ`.

This is not an abstract curiosity. It is the mathematics behind Google's original
PageRank iteration, behind the way physics engines settle a pile of blocks into a
resting configuration, behind the convergence of value iteration in reinforcement
learning, and behind the numerical solvers that find equilibria in economics. When
a method "iterates until it stops changing," a contraction is very often the reason
it stops.

## But the world is never just one system

Here is where the standard textbook story usually ends — and where the real work
begins. In practice you never have *one* fixed-point problem. You have a whole
*family* of them, indexed by some parameter you care about.

The market clears at one price today and a slightly different price tomorrow,
because the underlying conditions drifted. The reinforcement-learning agent's
optimal value function depends on the discount factor you chose. The recurrent
network's fixed point depends on its current weights, which are themselves being
nudged by training. In every one of these cases the natural question is not "what is
the fixed point?" but rather:

> **If I change the system a little, how much does its self-consistent answer
> change?**

This is the question of *stability*, and answering it well is what separates a
brittle model from a trustworthy one. If a tiny change in conditions could send the
equilibrium careening to a completely different place, you have a system on a knife's
edge. If the equilibrium glides smoothly and proportionally with the conditions, you
have something you can predict, control, and trust.

## One inequality to rule them all

The heart of this work is a single, almost embarrassingly compact inequality that
answers the stability question completely. Suppose `f` is a `K`-contraction with
fixed point `x_f`, and `g` is *any other map at all* — it need not contract, need
not be nice in any way — with its own fixed point `x_g`. Then the distance between
the two fixed points is controlled:

> **`distance(x_f, x_g) ≤ distance(f(x_g), g(x_g)) / (1 − K)`.**

Read this slowly, because it says something beautiful. The right-hand side has two
pieces. The numerator, `distance(f(x_g), g(x_g))`, measures how much the two rules
*disagree* — but only at the single point `x_g`. You don't need to compare `f` and
`g` everywhere; you compare them at one place. The denominator, `1 − K`, is the
"contraction margin": how far `f` is from being a mere isometry. The closer `K` is
to 1, the weaker the contraction, the larger the factor `1/(1−K)`, and the more the
fixed point can move.

The proof is a one-line application of the triangle inequality. Walk from `x_f` to
`x_g` by way of the intermediate point `f(x_g)`. The first leg, from `x_f = f(x_f)`
to `f(x_g)`, is a contracted distance — it is at most `K · distance(x_f, x_g)`. The
second leg is exactly the disagreement term. Collect the `K · distance` term onto
the left side, divide by `1 − K`, and you are done. The whole edifice of parametric
fixed-point theory rests on this single triangle.

A subtle point makes the result far more powerful than it first appears: **only one
of the two maps has to be a contraction.** The map `g` is completely arbitrary. This
means you can use the inequality to compare an idealized contracting model against a
messy, real-world process that happens to have a fixed point — and still get a hard
bound on how far their equilibria can be.

## From one inequality, a cascade of consequences

Once you have the master inequality, the interesting theorems fall out almost for
free. This is the recurring delight of good mathematics: find the right central
fact, and the corollaries arrange themselves.

**Smooth dependence on the dial.** Suppose your family of contractions `F_t` depends
on a parameter `t` — the conditions, the weights, the discount factor — and suppose
the family changes in a controlled, "Lipschitz" way: nudging the parameter by an
amount `d` changes the rule by at most `L · d` everywhere. Plug this directly into
the master inequality and you learn that the fixed-point map `t ↦ x*(t)` is itself
Lipschitz, with an *explicit, sharp* constant:

> **`distance(x*(s), x*(t)) ≤ (L / (1 − K)) · distance(s, t)`.**

The equilibrium moves at most `L/(1−K)` times as fast as the conditions that drive
it. This is the precise, quantitative statement of robustness. The numerical
experiments accompanying this work hit this bound exactly: for a family `F_t(x) = Kx
+ t` with `K = 1/2` and `L = 1`, the predicted amplification factor is `1/(1−1/2) =
2`, and the measured ratio of equilibrium-shift to parameter-shift is precisely 2,
every time.

**Symmetry is inherited, not imposed.** Suppose the system has a symmetry — a
transformation `φ` that relates one contraction `f` to another `f'` via the
"intertwining" relation `φ(f(x)) = f'(φ(x))`. Think of `φ` as a change of
coordinates, a rotation, or a relabeling that converts the first system into the
second. Then the symmetry automatically carries the first system's fixed point to
the second's:

> **`φ(x_f) = x_{f'}`.**

You don't have to assume the equilibrium respects the symmetry. It is *forced* to.
The reason is uniqueness: `φ(x_f)` is provably a fixed point of `f'` (just push the
intertwining relation through), and since `f'` is a contraction, it has only *one*
fixed point — so `φ(x_f)` must be it. Symmetries of the rule are inherited by the
self-consistent solution, with no extra hypotheses. In the numerical demonstration,
the affine symmetry `φ(x) = 2x + 5` maps the fixed point `0` of one contraction
exactly onto the fixed point `5` of its conjugate.

**Stacking many rules.** Real algorithms rarely apply the same rule forever. They
apply a *schedule* of rules — different learning rates at each step, a sequence of
warm-up and cool-down phases, a changing environment. Compose `n` such maps, the
`i`-th with its own contraction constant `K_i`, and the whole pipeline contracts at
the rate given by the **product** of the individual constants:

> **`distance(C(x), C(y)) ≤ (K₀ · K₁ · ⋯ · K_{n−1}) · distance(x, y)`,**

where `C = f_{n-1} ∘ ⋯ ∘ f_0`. This is the rigorous foundation for why adaptive
schedules work: even if no single step is a strong contraction, the *accumulated*
product can drive the system to its target — and if the constants never quite reach
1 but their "shortfalls" `(1 − K_i)` add up to infinity, convergence is still
guaranteed. In the numerical demo, constants `0.5, 0.8, 0.3, 0.9` produce a combined
contraction factor of `0.108`, exactly their product, and the composed map shrinks
distances by precisely that factor.

## Where it breaks — and why that's the point

A theory is only as trustworthy as its understanding of its own boundary. The factor
`1/(1−K)` in the master inequality blows up as `K` approaches 1, and you might
wonder whether that is merely a weakness of the proof or a genuine feature of the
world. It is genuine.

Consider the humblest possible map on the number line: `x ↦ x + 1`, the rule
"add one." It preserves distances exactly — `|（x+1) − (y+1)| = |x − y|` — so it is a
contraction with `K = 1`, right at the forbidden edge. And it has **no fixed point
whatsoever**: there is no number equal to itself plus one. Start anywhere and
iterate, and you simply march off to infinity, one step at a time, never settling.

This tiny example is decisive. It proves that the condition `K < 1` is not a
technical convenience that a cleverer mathematician could remove — it is the exact
dividing line between systems that have a stable, unique, robust equilibrium and
systems that have none at all. The blow-up of `1/(1−K)` is the theory honestly
reporting where the cliff edge is.

## Why this matters beyond the chalkboard

The picture that emerges is unified and practical. There is a single quantitative
law — the master stability inequality — and from it flow exact answers to the
questions practitioners actually ask. *How sensitive is my equilibrium to its
inputs?* The Lipschitz constant `L/(1−K)`. *Will my symmetry be respected?* Yes,
automatically. *Does my adaptive schedule converge?* Yes, at the product rate. *Why
does everything become fragile near the edge?* Because `1/(1−K)` diverges, and the
"add one" map shows the edge is real.

These are not idle classifications. Reinforcement learning leans on contraction
arguments to guarantee that value iteration converges and to bound how much the
learned policy can drift when the discount factor or reward model is perturbed.
Numerical analysts use the same stability bound to certify that a solver's answer
won't lurch under rounding error. Economists use it to prove that market equilibria
respond proportionally — not catastrophically — to shocks. Physicists use it to
argue that the symmetries of a system's laws are passed down to its steady states.
In every case the underlying mathematics is the same stubborn geometry: rules that
pull points together force the existence of a single self-consistent answer, and
that answer moves no faster than the rule that defines it — until you reach the edge,
where it can run away forever.

Self-consistency, it turns out, has a precise price, and the master inequality is
the receipt.
