# The Mathematics of Social Sorting: When Scoring Systems Create Their Own Reality

*How continuous ranking functions inevitably fragment populations — and why small changes in cutoff thresholds can trigger dramatic social upheaval*

---

Imagine a society that assigns every citizen a single number. Call it a credit score, a social rating, a trustworthiness index — the name doesn't matter. What matters is this: a continuous function maps the messy, high-dimensional reality of human social life onto a simple numerical scale. What happens next is not a matter of policy or politics. It is a matter of topology.

In a series of new results, mathematicians have shown that any such scoring system — regardless of how it is designed, calibrated, or intended — carries unavoidable mathematical consequences. These consequences are not bugs in the implementation. They are theorems: structural properties that follow from the bare fact of mapping a connected social fabric onto a one-dimensional number line.

## The Stratification Theorem

The first result concerns what happens when you project a connected space onto a line. Think of a social network as a web of relationships — friendships, family ties, professional connections, neighborhood bonds. This web is *connected*: you can trace a path of relationships from any person to any other. Mathematically, the population lives in a connected topological space.

Now impose a scoring function. Every person gets a number between 0 and 1. Because the score depends continuously on social position — people with similar connections tend to get similar scores — this scoring function is a continuous map.

The Stratification Theorem says: if the scoring function assigns at least two different values (a minimal requirement for any non-trivial rating system), then it *must* partition the population into disjoint groups. People with score 0.7 live in a different stratum than people with score 0.3, and these strata have empty intersection. This sounds obvious, but the mathematical depth lies in what happens at the boundaries.

When a threshold is imposed — say, everyone above 0.6 is "approved" and everyone below is "rejected" — the approved set is necessarily *closed* (it contains all its limit points) while the rejected set is *open* (it doesn't contain its boundary). This asymmetry is not a design choice; it is a topological inevitability. The boundary between social classes, far from being a clean line, is an asymmetric membrane that belongs to the privileged side.

## The Contraction Trap

The second set of results concerns dynamics: what happens when scores are updated iteratively based on social behavior that is itself influenced by scores. If your score determines your opportunities, and your opportunities determine your future score, the system feeds back on itself.

The mathematical framework is that of iterated contractive maps. If the score update rule brings any two people's scores closer together by some fixed ratio κ < 1 at each step, then the system converges — rapidly and inevitably — to a unique fixed point. This is the Banach fixed-point theorem applied to social dynamics.

The convergence estimate is precise: after *n* iterations, any two starting scores are within κⁿ of each other. For κ = 0.9, after 100 iterations the gap has shrunk by a factor of 10⁻⁵. For κ = 0.5, convergence is exponentially faster.

But here is the subtle point: the fixed point depends on the *entire* system, not just on any individual's starting position. Everyone converges to the same score — perfect homogeneity. A scoring system that contracts too aggressively doesn't just rank people; it *erases* distinction. The mathematical attractor of the system is a single point.

## The Phase Transition

The most striking result concerns what happens when the scoring rule is nonlinear. The logistic map — the function *f(x) = ax(1-x)* — serves as a canonical model. This simple quadratic function maps the unit interval to itself (for appropriate parameter *a*) and exhibits the full range of dynamical behaviors depending on the single parameter *a*.

When *a* is less than 1, the system has only one fixed point: zero. Every individual, regardless of starting score, converges to the minimum. There is no middle ground, no stable equilibrium above rock bottom. The mathematics proves this rigorously: the *only* solution to *ax(1-x) = x* with *x* in [0,1] is *x* = 0.

But the moment *a* crosses 1, a new fixed point appears at *x* = 1 - 1/*a*. This is a genuine *phase transition* — a discontinuous change in the qualitative behavior of the system, triggered by a continuous change in the parameter. At *a* = 0.99, everyone converges to zero. At *a* = 1.01, a new stable equilibrium emerges.

This is not merely an academic curiosity. In any real scoring system, the parameter *a* corresponds to the sensitivity of the score update rule. A small increase in how strongly behavior affects scores can suddenly create a new class of "stable high scorers" that didn't exist before. The transition is sharp, unpredictable, and irreversible at the point of crossing.

## The Cantor Attractor

The deepest result concerns what happens under iterated refinement. Imagine a scoring system that operates in stages: first it divides the population into three groups and removes the middle third (the "mediocre" scorers). Then it does the same within each remaining group. And again. And again.

The mathematical model is the classical Cantor set construction. At each stage, the middle third of every remaining interval is removed. What survives? The remaining set — the *attractor* of this iterative process — is the Cantor set: a set that is nonempty (it contains 0 and 1, for instance), uncountable, yet has measure zero. It is everywhere and nowhere, dense in a topological sense yet invisible to measurement.

The theorems establish that this attractor is genuinely nonempty — a non-trivial mathematical fact that requires careful verification at each stage of the construction. The attractor stages are nested (each refinement is contained in the previous one), and both endpoints survive every stage of removal.

The metaphor is precise: a scoring system that iteratively penalizes mediocrity doesn't converge to a clean binary of winners and losers. It converges to a *fractal* — a structure of infinite complexity where the boundary between inclusion and exclusion is itself infinitely fragmented.

## The Deeper Pattern

What unifies these results is a single insight: the act of scoring is not neutral. A continuous function from a connected social space to a one-dimensional number line is a *projection*, and projections destroy information. The destroyed information doesn't vanish — it reappears as topological structure in the level sets, as dynamical attractors in the iteration, as phase transitions in the parameter space.

Any society that reduces its citizens to a single number is not simplifying reality. It is creating new mathematical structure — structure that obeys its own laws, generates its own dynamics, and produces consequences that no designer intended or anticipated.

The mathematics does not tell us whether scoring systems are good or bad. It tells us what they *are*: continuous maps with topological invariants, dynamical systems with attractors and phase transitions, iterative processes whose long-term behavior is determined by abstract properties — contraction rates, connectivity, the topology of the pre-images — rather than by the intentions of their creators.

The numbers are not just describing the people. The numbers are reshaping the space the people inhabit. And that reshaping follows laws as rigid and as surprising as the laws that govern the topology of surfaces or the dynamics of celestial mechanics.

In mathematics, you can't choose the consequences of your axioms. In scoring systems, you can't choose the consequences of your function. The topology is already there, waiting.

---

*The mathematical results described in this article formalize social credit systems as continuous maps between topological spaces and establish rigorous theorems about stratification, convergence, phase transitions, and attractor structure in scoring dynamics.*
