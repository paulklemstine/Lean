# Time Travel Without Paradox: Consistency as a Fixed Point

## The message that must agree with itself

Imagine a laboratory with a peculiar mail slot. A note inserted at noon emerges yesterday, where it can influence what will be written at noon. The usual stories ask whether a traveler can prevent the journey that created the traveler. Mathematics asks a cleaner question: what boundary data can be placed on a causal loop without contradiction?

Suppose the state entering one circuit of the loop is $x$. Every physical interaction along the circuit—switches, collisions, memories, measurements, and feedback—is summarized by a return map $F$. After one trip, the state comes back as $F(x)$. A history closes consistently precisely when

$$
F(x)=x.
$$

Such an $x$ is called a **fixed point**. In this language, Novikov’s self-consistency principle is not an extra command imposed on nature. It is the requirement that a boundary-value problem on a closed causal circuit have a solution.

This reframing changes the emotional register of the paradox. Instead of asking how the universe “stops” an inconsistent action, we ask whether the round-trip dynamics contains a state that reproduces itself. More importantly, we can identify conditions that guarantee not merely one consistent history, but exactly one—and conditions under which every attempted history relaxes toward it.

## The squeezing mechanism

The decisive condition is contraction. Let possible boundary states form a metric space, so the distance $d(x,y)$ measures how distinguishable two candidate histories are. A return map is a contraction with factor $K$ when $0\le K<1$ and

$$
d(F(x),F(y))\le Kd(x,y)
$$

for every pair of states $x$ and $y$. One trip around the loop then erases at least a fixed fraction of any disagreement. Two histories initially one unit apart return at most $K$ units apart; after two circuits, at most $K^2$; after $n$ circuits, at most $K^n$.

There are two mild geometric assumptions. The state space must be nonempty, and it must be complete: whenever a sequence of candidate states becomes internally closer and closer, it must converge to a state that is still allowed. Completeness prevents the limiting history from falling through a missing point in the model.

These ingredients yield the central result.

**Novikov–Banach Consistency Theorem.** Let $X$ be a nonempty complete metric space and let $F:X\to X$ satisfy $d(F(x),F(y))\le Kd(x,y)$ for some $K$ with $0\le K<1$. Then there is exactly one state $x_\ast\in X$ satisfying $F(x_\ast)=x_\ast$.

The proof has a vivid interpretation. Begin with any trial boundary state $x_0$ and repeatedly send it around the loop:

$$
x_{n+1}=F(x_n).
$$

Contraction makes successive changes shrink geometrically. The resulting sequence is Cauchy, completeness supplies a limit $x_\ast$, and continuity of a contraction gives $F(x_\ast)=x_\ast$. If two fixed points existed, their distance would obey

$$
d(x_\ast,y_\ast)\le Kd(x_\ast,y_\ast),
$$

which is impossible for a positive distance when $K<1$. Thus the consistent history is unique.

## Consistency is also an attractor

Existence alone would leave a physical puzzle: how could a system find the special boundary data? Contraction gives a stronger answer.

**Global Attraction Theorem.** Under the hypotheses of the Novikov–Banach Consistency Theorem, for every initial state $x_0$ the iterates $F^n(x_0)$ converge to the unique consistent state $x_\ast$.

The loop does not need perfect initial calibration. Repeated causal feedback corrects errors. Each circuit damps discrepancies, turning the fixed point into a global attractor. This resembles familiar stabilizing mechanisms: a thermostat suppresses temperature deviations, an error-correcting controller suppresses tracking errors, and a recurrent network may settle into a stable memory. The time-loop interpretation is unusual, but the mathematics belongs to the broad science of feedback.

The theory is also quantitative. Define the **consistency defect** of a proposed state $x$ as $d(x,F(x))$. This is measurable after one circuit: it compares what was sent with what came back.

**A Posteriori Error Theorem.** Under the same contraction hypotheses,

$$
d(x,x_\ast)\le \frac{d(x,F(x))}{1-K}.
$$

So a small observed mismatch certifies closeness to the exact self-consistent history. The denominator matters. When $K$ is far below $1$, the loop strongly corrects errors, and a small defect is persuasive. When $K$ approaches $1$, feedback is weak, and the same defect permits a much larger uncertainty.

The proof is a one-line geometric estimate with major practical meaning. By the triangle inequality and contraction,

$$
d(x,x_\ast)\le d(x,F(x))+d(F(x),F(x_\ast))
\le d(x,F(x))+Kd(x,x_\ast).
$$

Rearranging gives the bound.

## A simple causal loop with an exact answer

Consider the affine return law

$$
F(x)=ax+b,
$$

where $x$ is real. If $|a|<1$, then $F$ is a contraction because

$$
|F(x)-F(y)|=|a|\,|x-y|.
$$

The unique consistent state is obtained by solving $ax+b=x$:

$$
x_\ast=\frac{b}{1-a}.
$$

For example, let

$$
F(x)=\frac{x}{2}+3.
$$

Then the consistent state is $x_\ast=6$. Starting from $x_0=0$, successive circuits produce $3$, $4.5$, $5.25$, $5.625$, and so on. Starting from $x_0=20$, they produce $13$, $9.5$, $7.75$, and so on. Different imagined pasts are pulled toward the same closed history.

The formula separates two aspects of feedback. The parameter $b$ shifts the selected history, while $|a|$ controls how quickly it is selected. After $n$ circuits, the exact error is

$$
|x_n-x_\ast|=|a|^n|x_0-x_\ast|.
$$

Thus stronger damping means faster convergence.

## Polynomial laws need a physical domain

Real systems are often approximated by polynomials, so it is tempting to claim that every polynomial causal loop has a consistent history. That claim is false. The correct theorem must mention the region of physically admissible states.

Let $p$ be a real polynomial and let $S\subseteq\mathbb R$ be the allowed state domain. Three conditions matter: $S$ is nonempty; $S$ is complete with its usual distance; and $p$ maps $S$ into itself. The third condition says that one circuit never ejects a physical state from the model. If, in addition, the restricted map contracts distances by a factor $K<1$, then the general theorem applies.

**Polynomial Consistency Theorem on an Invariant Domain.** If a real polynomial $p$ maps a nonempty complete set $S\subseteq\mathbb R$ into itself and satisfies

$$
|p(x)-p(y)|\le K|x-y|
$$

for all $x,y\in S$ and some $0\le K<1$, then there exists exactly one $x_\ast\in S$ such that $p(x_\ast)=x_\ast$.

This guarded statement is stronger scientifically than an unrestricted slogan because it identifies what does the work. Polynomiality provides a convenient model; invariance keeps the orbit physical; completeness retains the limit; contraction selects one history.

For a differentiable polynomial on a closed interval, a practical sufficient test is a derivative bound. If $p$ preserves the interval and $|p'(x)|\le K<1$ throughout it, the mean value theorem supplies the contraction inequality. One may then iterate the polynomial from any point in the interval to approximate the unique consistent state.

## Where paradox returns

The assumptions are not decorative. Consider

$$
F(x)=x^2+1.
$$

A consistent real state would satisfy $x^2+1=x$, or

$$
x^2-x+1=0.
$$

Its discriminant is $1-4=-3$, so there is no real solution. Polynomiality by itself does not guarantee consistency.

An even sharper example uses a two-state system. Let the possible message be either false or true, and let one circuit negate it. Consistency would demand

$$
\neg b=b.
$$

Neither Boolean value satisfies this equation. This is the mathematical core of the familiar instruction “send back the opposite of what you receive.” The rule is perfectly definite, yet the boundary-value problem has no solution.

Finite state spaces do, however, obey a complementary positive theorem.

**Finite Contraction Theorem.** On any nonempty finite metric space, a map satisfying $d(F(x),F(y))\le Kd(x,y)$ with $K<1$ has exactly one fixed point.

Iteration must eventually repeat because only finitely many states exist. A nontrivial cycle cannot survive strict contraction: traversing the cycle repeatedly would force a positive separation to become smaller than itself. The eventual cycle therefore has length one, and the same contraction argument gives uniqueness. Boolean negation escapes this conclusion because it is not a strict contraction under the discrete metric.

## What the theorem does—and does not—say

The fixed-point picture does not establish that closed timelike curves exist, nor does it derive their dynamics from general relativity. It offers a precise conditional statement: once a causal circuit is modeled by a complete state space and a contractive one-circuit map, self-consistency follows, uniquely and attractively.

That distinction matters. “The universe forbids paradox” is metaphysical. “This feedback law has a unique fixed point” is mathematical and testable. The residual estimate even tells an experimenter how one-circuit mismatch bounds distance from consistency.

The framework also clarifies several boundaries. A causal rule need not possess a consistent state. A polynomial rule need not possess one either. Completeness without invariance does not keep the limit physical, and invariance without contraction may allow many fixed points or cycles. Contraction is a sufficient mechanism, not a universal description of all consistent systems.

## From impossible stories to stable feedback

The most useful lesson may have little to do with fictional travelers. Circular causation appears whenever outputs return as inputs: climate feedback, control systems, economic expectations, iterative solvers, recurrent computation, and networks of mutual prediction. In all of them, the central question is whether the loop closes and whether perturbations die away.

The fixed-point formulation gives a compact answer. A self-consistent history is a state unchanged by one complete circuit. Strict contraction on a nonempty complete domain guarantees that such a state exists, that it is unique, that every repeated traversal approaches it, and that a single measured defect bounds the remaining error. Polynomial models inherit these conclusions only on invariant domains where contraction truly holds. Outside that regime, both algebraic and discrete paradoxes remain possible.

A time loop, in this view, is not made consistent by narrative intervention. It is made consistent by geometry: the geometry of a map that squeezes every disagreement until only one closed history remains.
