# The Mathematics of Déjà Vu: Recurrence, Observation, and the Limits of a Metaphor

There is a peculiar instant when the present seems to fold onto the past. A room, a sentence, the angle of afternoon light: suddenly it all feels as though it has happened before. Déjà vu invites a mathematical metaphor. If a mind moves through a space of possible states, could the feeling of return be understood as recurrence in a dynamical system?

The metaphor is powerful, but it needs discipline. Mathematics can tell us when a trajectory must return, when returns survive a change of description, and when an observation merely *looks* recurrent. It can also expose an alluring mistake: continuity does not make recurrent states common, and the fraction of people reporting an experience cannot be read from the topological structure of a map.

The result is subtler than “déjà vu is inevitable.” Under a simple interval model, at least one recurrent state is inevitable. Widespread recurrence is not. And observed repetition need not mean that the hidden state of a cognitive system has repeated at all.

This distinction matters wherever hidden processes are inferred from repeated signals. Neuroscience faces it when similar reports arise from different neural configurations; medicine faces it when a stable measurement conceals changing physiology; engineering faces it when a coarse sensor repeatedly rounds distinct states to one value. The mathematics of déjà vu is therefore also a mathematics of inference: when does sameness on the surface warrant sameness underneath?

## A mind as a dynamical system

Imagine a set $S$ whose elements represent cognitive states. A transition rule $f:S\to S$ sends the current state to the next one. Starting from $s$, the resulting trajectory is

$$
s,\quad f(s),\quad f^2(s),\quad f^3(s),\ldots,
$$

where $f^n$ means applying $f$ exactly $n$ times. A state is **periodic** if it returns after a positive number of steps: there is some integer $n>0$ such that

$$
f^n(s)=s.
$$

The collection of all such states is the periodic set

$$
P(f)=\{s\in S:\text{ for some integer }n>0,\ f^n(s)=s\}.
$$

A fixed point, satisfying $f(s)=s$, is the simplest periodic state. Longer cycles are possible: three distinct states $s_0,s_1,s_2$ may obey $f(s_0)=s_1$, $f(s_1)=s_2$, and $f(s_2)=s_0$.

Calling every periodic state “déjà vu” is already an interpretation rather than a theorem. The definition describes exact return of a modeled state; the human experience is an observation made through memory, attention, language, and finite sensory resolution. Still, recurrence provides a clean skeleton on which to test claims.

## The unavoidable return

Suppose cognitive states are summarized by a single quantity ranging over a closed interval $[a,b]$, with $a<b$. Suppose also that $f:[a,b]\to[a,b]$ is continuous: nearby states lead to nearby next states, with no abrupt jumps.

Then at least one periodic state must exist.

**Interval Recurrence Theorem.** Every continuous self-map $f:[a,b]\to[a,b]$ of a nondegenerate closed interval has a state $s\in[a,b]$ for which $f^n(s)=s$ for some $n>0$. In fact, it has a fixed point $f(s)=s$.

The reason is geometric. Consider $g(x)=f(x)-x$. Since $f(a)\in[a,b]$, we have $g(a)=f(a)-a\ge 0$. Since $f(b)\in[a,b]$, we have $g(b)=f(b)-b\le 0$. Continuity forces $g$ to equal zero somewhere between $a$ and $b$. At that point, $f(s)=s$.

This is a robust existence result. It does not depend on chaos, randomness, or a period-three orbit. A continuous interval model cannot avoid recurrence altogether.

But “there is at least one” is very different from “returns are everywhere.”

## Why continuity does not make recurrence dense

A set is **dense** in an interval if every open subinterval, however small, contains one of its points. Dense periodic states would mean that any state can be approximated as closely as desired by a periodic one.

Continuity alone does not imply this. Consider the constant transition

$$
f(x)=c
$$

for every real number $x$. This map is continuous. After one step every trajectory reaches $c$, and $c$ remains fixed. Which initial states ever return exactly to themselves? Only $c$. Therefore

$$
P(f)=\{c\}.
$$

A singleton is not dense in the real line, nor in any nondegenerate interval containing other points. This gives the **Nondensity Theorem**: there are continuous real dynamical systems whose periodic set is not dense.

The counterexample marks a crucial boundary. The interval theorem guarantees existence of a recurrent state, not abundance. Density requires stronger hypotheses, typically some explicit form of chaotic structure such as a horseshoe on an invariant subset. Even then, periodic points may be dense only inside that subsystem, not throughout the ambient state space.

## Does recurrence survive a change of language?

A cognitive state may be encoded in many ways: neural activity, a compressed feature vector, a symbolic category, or a verbal report. Let $f:S\to S$ describe one system and $g:T\to T$ another. An encoding $h:S\to T$ respects the dynamics when

$$
h(f(s))=g(h(s))
$$

for every $s\in S$. Such an encoding is called a **semiconjugacy**. It says that “advance, then encode” gives the same answer as “encode, then advance.” Repeating this identity gives

$$
h(f^n(s))=g^n(h(s)).
$$

This yields the **Recurrence Transport Theorem**: if $s$ is periodic for $f$, then $h(s)$ is periodic for $g$. Indeed, if $f^n(s)=s$, then

$$
g^n(h(s))=h(f^n(s))=h(s).
$$

The reverse need not hold. Two different hidden states may collapse to the same observation. If the encoding is **injective**, meaning $h(s_1)=h(s_2)$ only when $s_1=s_2$, then recurrence is both preserved and reflected. In precise terms,

$$
h^{-1}(P(g))=P(f).
$$

This is the **Faithful Encoding Theorem**. Under an injective semiconjugacy, a state is periodic exactly when its encoded image is periodic. The theorem identifies the mathematical requirement behind a trustworthy recurrence report: the observation must retain enough information to distinguish hidden states.

## The false positive machine

At the opposite extreme lies a constant observation. Suppose an observation rule sends every hidden state to the same report $o$. Then the observed value is fixed at every time, regardless of what the underlying trajectory does.

This gives the **Observational False-Positive Theorem**: for any dynamical system and any nonperiodic state, a constant observation reports an unchanging observation even though the hidden state never returns.

The lesson reaches beyond déjà vu. A stable dashboard reading does not prove a machine’s internal state is unchanged. A repeated behavioral label does not prove identical neural activity. A coarse sensor can turn distinct realities into the same symbol. Recurrence of a measurement and recurrence of the measured system are different claims.

## A concrete laboratory: the logistic map

A classic one-dimensional model is the logistic family

$$
L_r(x)=rx(1-x),\qquad 0\le x\le 1.
$$

At the proposed parameter $r=3.83=383/100$, the map is

$$
L(x)=\frac{383}{100}x(1-x).
$$

First, it really does map the unit interval into itself. For $0\le x\le1$, both $x$ and $1-x$ are nonnegative, so $L(x)\ge0$. Also $x(1-x)\le1/4$, hence

$$
L(x)\le\frac{383}{400}<1.
$$

Thus every trajectory begun in $[0,1]$ stays there.

Second, its fixed points can be classified exactly. Solving $L(x)=x$ gives

$$
\frac{383}{100}x(1-x)=x,
$$

which factors as

$$
x(383x-283)=0.
$$

Therefore the **Fixed-Point Classification at $r=3.83$** states that the only fixed states are

$$
x=0\qquad\text{and}\qquad x=\frac{283}{383}.
$$

These exact facts make the logistic map a useful numerical laboratory. Iteration can reveal apparent cycles and sensitivity, while algebra certifies interval preservation and fixed points. But numerical proximity is not exact periodicity, and neither fixed-point counts nor plots supply a population probability.

## Why $70\%$ does not come from density

Several notions of “many” are easy to confuse. A set may be topologically dense while having probability zero. A set may have positive probability without being dense. Natural density, invariant-measure weight, and the lifetime incidence of a reported experience are different mathematical objects.

A statement such as “about $70\%$ of people report déjà vu” belongs to a probability model: one needs a population of subjects, a distribution of initial states and parameters, a time horizon, and an observation rule. The periodic set $P(f)$ alone provides none of these. Even assigning a measure to exact periodic points would not automatically model finite-resolution reports or lifetime incidence.

Period three deserves similar care. In continuous interval dynamics, an exact period-three orbit triggers powerful chaos results and leads toward symbolic dynamics and scrambled trajectories. But the existence of such an orbit at a chosen parameter must be established exactly; a numerical orbit hovering near three values is evidence, not proof. And chaos does not turn a topological statement into an empirical percentage.

## A more honest mathematics of familiarity

The durable picture has three layers.

First is **state dynamics**: what the hidden system actually does. Second is **encoding or observation**: what information survives measurement. Third is **incidence**: how frequently an event occurs under a specified probability distribution and observation protocol.

On the first layer, continuous interval dynamics guarantee at least one fixed state. On the second, faithful encodings preserve and reflect recurrence, while lossy observations can manufacture it. On the third, no frequency can be inferred until a measure and an event are defined.

So is déjà vu mathematically inevitable? In the narrow model of a continuous self-map of a closed interval, some recurrent state is inevitable. The stronger human claim does not follow. Mathematics replaces the slogan with a sharper insight: recurrence, perceived recurrence, and prevalent recurrence are three different phenomena. Understanding their relationship requires not only a dynamical law, but also a faithful window onto the system and a probabilistic account of who observes what, and when.
