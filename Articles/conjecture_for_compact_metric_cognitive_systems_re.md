# When Observation Changes the Rhythm

## A mathematics of recurrence, measurement, and lost detail

A lighthouse turns, disappears into darkness, and returns. A heart contracts, relaxes, and contracts again. A seasonal population rises and falls. Repetition is among the most recognizable structures in nature, yet recognizing a repeating process is not the same as seeing the process itself. Every measurement selects, compresses, or discards information. A camera records brightness but not molecular motion; a survey records answers but not the full mental state that produced them; a sensor rounds a continuous voltage to a finite label.

This raises a deceptively simple question: **what happens to a system’s rhythm when we observe it through a lossy instrument?**

The answer has an unexpectedly arithmetic form. If an evolving state repeats after exactly $n$ steps, then any observation that evolves consistently with the underlying system must repeat after a number of steps dividing $n$. Observation cannot invent an incompatible rhythm. It may preserve the original period, or it may collapse several phases together, but the new period must be a divisor of the old one.

That statement needs no geometry, probability, continuity, or finiteness. It follows from the algebra of repeated actions. It also pinpoints the role of faithful measurement: if distinct states always receive distinct observations, then no collapse occurs and every exact period is preserved.

## Systems, orbits, and exact periods

A discrete dynamical system consists of a set $X$ of states and a rule $f:X\to X$. Starting from $x\in X$, repeated application of the rule produces the orbit

$$
x,\quad f(x),\quad f^2(x),\quad f^3(x),\ldots,
$$

where $f^k$ means that $f$ has been applied $k$ times. The state $x$ is periodic if $f^n(x)=x$ for some positive integer $n$. Its **minimal period** is the smallest positive such $n$. A state of minimal period $1$ is a fixed point; a state of minimal period $2$ alternates between two distinct phases; and a state of minimal period $3$ moves around a genuine three-cycle.

Now suppose the full state is not directly available. Instead, an observation map $h:X\to Y$ assigns an observed state in a second space $Y$. The observations themselves evolve according to a rule $g:Y\to Y$. The natural consistency requirement is

$$
h(f(x))=g(h(x))\qquad\text{for every }x\in X.
$$

This equation says that it does not matter whether we first advance the hidden system and then measure, or first measure and then advance the observed system. Such a map is called a **semiconjugacy**. It is the mathematical expression of an observation channel that respects time evolution.

Repeated consistency gives much more than the one-step equation. For every nonnegative integer $k$,

$$
h(f^k(x))=g^k(h(x)).
$$

That identity is the engine behind all the results that follow.

## The divisibility law

Suppose $x$ has minimal period $n$ under $f$. Then $f^n(x)=x$. Applying $h$ and using consistency yields

$$
g^n(h(x))=h(f^n(x))=h(x).
$$

Thus the observed state $h(x)$ returns after $n$ steps. But it might have returned earlier. Let its minimal period be $d$. A basic fact about periodic sequences says that every return time is a multiple of the minimal period. Therefore $d$ divides $n$.

This gives the central result.

**Observation Divisibility Theorem.** Let $f:X\to X$ and $g:Y\to Y$ be discrete dynamical systems, and let $h:X\to Y$ satisfy $h\circ f=g\circ h$. For every periodic state $x$, if its minimal period is $n$ and the minimal period of $h(x)$ is $d$, then

$$
d\mid n.
$$

The theorem describes exactly what loss of temporal detail can look like. A six-cycle may be observed as a six-cycle, a three-cycle, a two-cycle, or a fixed point, because $1$, $2$, $3$, and $6$ divide $6$. It cannot be observed as an exact four-cycle or five-cycle. A twelve-cycle offers more possibilities, but still only its divisors.

Imagine a wheel with six equally spaced marked positions. If a sensor distinguishes every mark, it records period $6$. If opposite marks look identical, it sees three classes and records period $3$. If marks alternate black and white, it records period $2$. If all marks look alike, it records a fixed point. Each loss of distinction identifies phases in a pattern compatible with rotation, and compatibility forces divisibility.

A striking feature is what the theorem does **not** assume. The state spaces need not be metric spaces. They need not be compact. The dynamics need not be continuous. The observation need not have finite fibers. The divisibility law is not an analytic approximation or a statistical tendency; it is an exact algebraic constraint.

## Faithful observation preserves the whole rhythm

Loss of period can occur only when different states receive the same observation. Suppose instead that $h$ is injective: whenever $h(a)=h(b)$, one must have $a=b$. Then any observed return can be reflected back to a genuine return of the hidden state.

Indeed, if $g^k(h(x))=h(x)$, consistency gives

$$
h(f^k(x))=h(x).
$$

Injectivity then forces $f^k(x)=x$. Consequently the hidden and observed states have exactly the same collection of return times, hence the same minimal period.

**Faithful Observation Theorem.** Under the assumptions of the Observation Divisibility Theorem, if $h$ is injective, then for every state $x$,

$$
\operatorname{per}_g(h(x))=\operatorname{per}_f(x),
$$

where $\operatorname{per}$ denotes minimal period. Equivalently, for every positive integer $n$, the state $x$ has exact period $n$ if and only if $h(x)$ has exact period $n$.

This theorem turns injectivity into an operational guarantee. A faithful sensor does not merely preserve the fact that recurrence occurs; it preserves its exact temporal scale. No metric estimate or error bound is needed.

The result also clarifies a common ambiguity in data analysis. If a measured signal has period $d$, the hidden system may have period $d$, but it could have any period that is a multiple of $d$. Without injectivity, period estimation from observations is fundamentally one-sided. The observation gives a divisor, not necessarily the full answer.

## Why prime rhythms are rigid

Prime numbers have only two positive divisors. That elementary fact makes prime cycles unusually resistant to partial collapse.

**Prime-Period Dichotomy.** Suppose $x$ has minimal period $p$, where $p$ is prime, and $h$ is any evolution-respecting observation. Then the observed state $h(x)$ has minimal period either $1$ or $p$.

There is no intermediate option. A five-cycle cannot become a two-cycle, three-cycle, or four-cycle. It either remains a five-cycle or collapses all the way to a fixed observation. If the observation is injective, only the first branch is possible.

Picture five phases arranged around a ring. Any time-compatible identification of phases must look the same after rotating the ring. Because the rotation acts transitively and five is prime, a compatible partition either separates all five positions or merges all five. Composite cycles possess nontrivial periodic partitions; prime cycles do not.

This rigidity gives prime recurrence a diagnostic value. If a hidden process is known to have prime period and the measured output varies at all along the orbit, then the full prime period survives. Conversely, a constant observed signal need not indicate a stationary hidden process: it may conceal an entire prime cycle.

## Measurement as a quotient of time

The theorems suggest a useful conceptual picture. Observation does not freely distort recurrence. It forms a quotient of the orbit, identifying phases that the instrument cannot distinguish. The cycle’s rotational symmetry descends to the quotient, and the quotient cycle has a size dividing the original size.

This idea reaches far beyond literal sensors. In cognitive modeling, the hidden state might encode neural, contextual, and internal variables, while the observed state records a behavioral category. In computer science, a large program state may be projected to a small diagnostic log. In biology, molecular configurations may be grouped into phenotypes. In economics, a high-dimensional market state may be reduced to a coarse index. Whenever the coarse description evolves autonomously and consistently, its exact recurrence is arithmetically constrained.

The consistency condition matters. If the observation at the next moment depends on hidden information not contained in the current observation, then there may be no deterministic rule $g$ on $Y$. In that case the observed labels alone do not form the kind of dynamical system considered here. The divisibility law applies precisely when the compressed description is dynamically closed.

## A practical recurrence audit

The theory leads to a simple audit for simulations and finite data models.

First, specify the hidden update $f$, the observed update $g$, and the observation map $h$. Check the commutation equation $h(f(x))=g(h(x))$ on every relevant state. Second, follow the hidden orbit until it first returns and record $n$. Third, follow the observed orbit until it first returns and record $d$. The result predicts that $n$ divided by $d$ is an integer. Finally, test whether $h$ is injective on the orbit. If it is, then $d=n$; if it is not, any reduction must still obey divisibility.

For the six-position wheel, one can encode observation by residues modulo $d$, where $d$ divides $6$. The hidden update adds $1$ modulo $6$, the observed update adds $1$ modulo $d$, and the observation maps a position to its residue modulo $d$. This produces observed periods $1$, $2$, $3$, and $6$ exactly. It also shows that the theorem is sharp: every divisor can genuinely occur.

## What remains beyond the local theorem

The results concern the period of each individual state. Richer global questions remain. A whole dynamical system has an exact-period spectrum: the set of periods realized by its states. Under a bijective evolution-respecting change of coordinates, one expects this spectrum to be unchanged. Under lossy observation, it should move into the divisor closure of the original spectrum.

For compact metric systems, other global signatures include topological entropy and scrambled sets, which describe orbit complexity rather than a single return time. Their preservation requires topological or metric hypotheses absent from the elementary divisibility argument. A further challenge is quantitative observability: if a system contains a three-cycle whose phases are separated by a definite measurement margin, how many distinct finite observation words must appear?

These questions connect arithmetic recurrence to chaos, information, and robust measurement. Yet the foundational message is already complete. Repetition survives observation in a highly structured way. Faithful observation preserves an exact rhythm. Lossy observation can shorten it, but only along the lattice of divisors. And a prime rhythm presents the starkest choice of all: hear the whole beat, or hear no beat at all.
