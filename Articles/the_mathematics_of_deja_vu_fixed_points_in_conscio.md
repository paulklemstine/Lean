# The Mathematics of Déjà Vu: Return, Recurrence, and Tropical Memory

A familiar room suddenly feels remembered. A sentence seems to arrive with its own echo. Déjà vu is brief, subjective, and difficult to reproduce, but its central shape is mathematically crisp: a state appears to return.

That observation does not turn consciousness into a single equation. It does, however, suggest a disciplined question. If a cognitive state changes according to a rule, what can mathematics truly conclude when the system revisits an earlier state? The answer is both richer and more cautious than the slogan “period three implies chaos.” Return times obey an exact arithmetic, survive changes of description, and acquire a striking spectral interpretation in tropical mathematics. Yet continuity alone does not scatter recurrent states everywhere, and a population statistic such as $70\%$ cannot be identified with the density of periodic points without a probabilistic observation model.

The result is a useful mathematical portrait of déjà vu—not as proof of a theory of consciousness, but as a case study in how recurrence can be defined, transported, simulated, and tested.

## A state that comes back

Let $S$ be a space of possible states and let $f:S\to S$ send a present state to its successor. Repeated application produces

$$
s,\quad f(s),\quad f^2(s),\quad f^3(s),\ldots,
$$

where $f^n$ means that $f$ is applied $n$ times. We call $s$ a **periodic state** if there is a positive integer $n$ for which

$$
f^n(s)=s.
$$

The number $n$ is a return time. It need not be the first return. A state has **exact period** $p$ when $p>0$, $f^p(s)=s$, and no positive integer $q<p$ satisfies $f^q(s)=s$.

This distinction matters. Every fixed point has return time $3$, because a state satisfying $f(s)=s$ also satisfies $f^3(s)=s$. But it does not have exact period $3$. An exact three-cycle consists of genuinely different stages.

**Exact Three-Cycle Theorem.** If $s$ has exact period $3$, then the three states $s$, $f(s)$, and $f^2(s)$ are pairwise distinct.

The reason is simple but decisive. If $s=f(s)$, the first return occurs after one step. If $f(s)=f^2(s)$, then applying the remaining dynamics and using the three-step return again yields a shorter return. If $f^2(s)=s$, the state returns after two steps. Every possible collision contradicts exactness.

A return also repeats on an arithmetic schedule.

**Return-Multiple Theorem.** If $p>0$ and $f^p(s)=s$, then for every positive integer $k$,

$$
f^{pk}(s)=s.
$$

One can view this as a clock whose hand comes back every $p$ ticks. Once one complete circuit returns to the starting point, any positive number of complete circuits does the same. In an observational setting, this warns us that many recorded return times may reflect one underlying fundamental period.

## What survives a change of viewpoint

Brains are not observed in their full microscopic state. An experiment may record a coarse signal: a behavioral category, an imaging feature, or a reported feeling. Mathematically, such an observation is a map $h:S\to T$ from a detailed state space to an observed one.

Suppose the hidden dynamics is $f:S\to S$, the observed dynamics is $g:T\to T$, and observation commutes with evolution:

$$
h(f(s))=g(h(s))
$$

for every state $s$. This relationship is called a **semiconjugacy**. It says that evolving first and observing afterward gives the same result as observing first and evolving in the reduced description.

**Transport of Recurrence Theorem.** Under a semiconjugacy, every periodic hidden state produces a periodic observed state with the same return time.

Indeed, repeated commutation gives $h(f^n(s))=g^n(h(s))$. If $f^n(s)=s$, then

$$
g^n(h(s))=h(f^n(s))=h(s).
$$

This is a robust conclusion: recurrence survives faithful dynamical coarse-graining. The converse is not guaranteed. Two different hidden states may look identical after observation, so a many-to-one sensor can manufacture an apparent observed return even while the underlying state has not returned. That asymmetry is central to any scientific interpretation of déjà vu.

## A laboratory map on the unit interval

A classic testing ground for recurrence is the logistic family

$$
L_r(x)=rx(1-x).
$$

Here $x$ lies between $0$ and $1$, and $r$ controls the dynamics. For $0\le r\le4$, the unit interval is invariant:

**Invariant-Interval Theorem.** If $0\le r\le4$ and $0\le x\le1$, then

$$
0\le L_r(x)\le1.
$$

The lower bound follows because all three factors $r$, $x$, and $1-x$ are nonnegative. For the upper bound, the parabola $x(1-x)$ reaches its maximum $1/4$ at $x=1/2$, so $rx(1-x)\le4\cdot(1/4)=1$.

This theorem makes numerical experiments safe: exact trajectories beginning in $[0,1]$ remain there. At $r=3.83$, iterations from many starting points numerically approach a three-stage pattern, reflecting the well-known period-three window of this family. Such computation is informative, but it does not by itself prove an exact orbit or quantify a population frequency. A rigorous parameter study would enclose the three candidate orbit points in intervals and show that the third iterate maps each interval strictly into itself with derivative magnitude below $1$.

The map also clarifies a common overreach. A period-three theorem for continuous interval maps can have strong consequences when its full hypotheses and classical conclusions are invoked. But neither “continuity” nor “being an interval map” alone means that periodic points are dense.

## The contraction that punctures the myth

Consider the gentlest possible evolution on the real line:

$$
C(x)=\frac{x}{2}.
$$

It is continuous. After $n$ steps,

$$
C^n(x)=\frac{x}{2^n}.
$$

If a positive return occurs, then $x/2^n=x$. Since $2^n>1$, this equation forces $x=0$. Conversely, $0$ is fixed.

**Contraction Counterexample.** The continuous map $C(x)=x/2$ has exactly one periodic point, namely $0$. Consequently, its periodic points are not dense in the real line.

A set is **dense** if every nonempty open interval contains one of its points. The singleton $\{0\}$ plainly misses, for example, every sufficiently small interval around $1$. Thus continuity alone cannot support a density claim. Continuity prevents jumps; it does not force the stretching, folding, or mixing needed to distribute periodic behavior throughout a state space.

This counterexample changes the scientific story. Déjà vu is not a mathematical inevitability of every continuous cognitive dynamics. A continuous system may simply contract toward one resting state. To derive widespread recurrence, one must add hypotheses that create orbit dispersion—topological transitivity, mixing, or another mechanism ruling out attracting regions.

## Why $70\%$ is not a density

Reports that roughly $70\%$ of people experience déjà vu concern subjects, memories, observation windows, and reporting thresholds. The density of periodic points is a property of subsets of a state space. These are different kinds of quantity.

Even topological density does not mean “a large percentage.” The rational numbers are dense in the real line, yet they occupy zero length. Conversely, a set can have substantial probability under one distribution and tiny probability under another. Exact periodic points may also be invisible in finite-precision data, while approximate returns can be common.

A meaningful calibration must specify at least four ingredients: a distribution of parameters such as $r$; a distribution of initial states; a finite observation horizon; and a tolerance $\varepsilon$ declaring that $|f^n(x)-x|<\varepsilon$ counts as an observed return. Only then does an incidence become a probability that can be compared with data. Choosing $r=3.83$ merely because an incidence is near $70\%$ would skip this entire inferential bridge.

## Tropical dynamics: recurrence as zero drift

There is another way to understand return. In **min-plus algebra**, ordinary addition plays the role of multiplication, while minimum plays the role of addition. Given a real matrix $A=(A_{ij})$ and a vector $v$, define the min-plus matrix-vector product by

$$
(A\otimes v)_i=\min_j(A_{ij}+v_j).
$$

A pair $(\lambda,v)$ is a **tropical eigenpair** when

$$
A\otimes v=v+\lambda\mathbf{1},
$$

where $\mathbf{1}$ is the vector whose entries are all $1$. The scalar $\lambda$ is not a multiplicative growth rate; it is an additive drift per step.

**Tropical Drift Theorem.** If $(\lambda,v)$ is a tropical eigenpair, then after $k$ min-plus updates,

$$
(A\otimes)^k v=v+k\lambda\mathbf{1}.
$$

The proof is induction. One update adds $\lambda$ to every coordinate. Min-plus multiplication commutes with adding the same constant to every coordinate, so each further update contributes one more copy of $\lambda$.

Two consequences reveal the spectral anatomy of recurrence.

**Zero-Eigenvalue Fixed-State Theorem.** A vector $v$ is a tropical eigenvector with eigenvalue $0$ exactly when $A\otimes v=v$.

**Zero-Drift Recurrence Theorem.** Every tropical eigenstate with eigenvalue $0$ returns after every positive number of steps.

Thus tropical recurrence is zero spectral drift. When $\lambda\ne0$, the state does not return in ordinary coordinates; it marches linearly along the all-ones direction. In projective tropical space, where adding a common constant does not change the state, that same trajectory is stationary. This distinction between literal and projective recurrence offers a useful metaphor for cognition: a pattern may repeat relationally even while its global baseline changes.

## A better mathematical moral

The mathematics of déjà vu is not a proof that a subjective experience must occur. It is a toolkit for separating valid consequences from seductive analogies.

A positive return creates infinitely many return times by multiplication. Exact period $3$ certifies three distinct stages. Recurrence passes from a detailed system to a compatible observed system. The logistic family stays inside its natural state interval for parameters in $[0,4]$. In tropical dynamics, eigenstates move by uniform linear drift, and zero drift is precisely fixed-state recurrence. Against these positive results stands an equally important negative one: continuity alone does not make periodic states dense.

The next scientific step is therefore not to equate a survey percentage with a topological property. It is to build a measure-calibrated model of approximate recurrence, specify what is observed, and test whether periodic windows predict anything beyond chance. The most illuminating mathematics here does not declare déjà vu inevitable. It tells us exactly what would have to be true before such a declaration could be justified.