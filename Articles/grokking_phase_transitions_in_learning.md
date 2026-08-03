# The Long Silence Before a Network “Gets It”

## A minimal mathematical portrait of grokking

A learning system can appear stuck for a long time and then, almost at once, begin to succeed on examples it has never seen. This phenomenon is often called **grokking**: training performance may already look settled while generalization arrives only after a conspicuous delay. The dramatic timing invites dramatic explanations. Has the network suddenly discovered an algorithm? Did its internal geometry reorganize? Is the transition genuinely sharp, or merely a smooth change viewed at the wrong scale?

A useful first step is to strip the story down until the transition can be seen without distraction. Consider a scalar two-layer neural network with one hidden unit. Its activation is the rectified linear unit

$$
\operatorname{ReLU}(z)=\max\{z,0\}.
$$

For real parameters $w,b,v,c$ and scalar input $x$, the network output is

$$
N(x)=v\operatorname{ReLU}(wx+b)+c.
$$

This is perhaps the smallest nontrivial neural network: an affine transformation, one nonlinear gate, and an affine output. Despite its simplicity, it contains an exact threshold mechanism. Set $w=v=1$, $c=0$, and choose the hidden bias to be $-d$, where $d$ is a prescribed delay. If time $t$ is fed into the network, its score becomes

$$
G_d(t)=\operatorname{ReLU}(t-d)=\max\{t-d,0\}.
$$

Call the network generalizing at time $t$ when its test score is strictly positive, meaning $G_d(t)>0$. Then the entire delayed transition is visible in one formula. For every $t\le d$, the score is exactly zero. For every $t>d$, the score is strictly positive. The network does not slowly leak across the threshold: its score remains pinned to zero through the delay and rises immediately afterward.

### The Delayed Generalization Theorem

For every real delay $d$, the score $G_d(t)=\max\{t-d,0\}$ satisfies

$$
G_d(t)=0 \quad \text{for every } t\le d,
$$

and

$$
G_d(t)>0 \quad \text{for every } t>d.
$$

Thus generalization, defined as positivity of the score, fails at every time up to and including $d$, and holds at every later time.

The proof is simply the two-case definition of the rectifier. When $t\le d$, one has $t-d\le0$, so the maximum of $t-d$ and $0$ is $0$. When $t>d$, one has $t-d>0$, so the maximum is $t-d$, which is positive.

This theorem is intentionally exact and intentionally modest. It does not say that all neural networks grok, nor that gradient descent necessarily creates this trajectory. Instead, it isolates a mathematical mechanism capable of producing perfect delay: a latent quantity moves steadily toward the active side of a nonlinear gate, while the observable score remains unchanged until the crossing.

That mechanism has familiar real-world analogues. A diode carries almost no current until voltage crosses a threshold. A chemical concentration can rise silently until nucleation begins. A student may accumulate pieces of a concept before a final connection makes their usefulness visible. In each case, hidden progress and visible performance need not move together.

## Why call it a phase transition?

A threshold in an input-output graph is only half the story. The phrase “phase transition” also suggests a change in the qualitative structure of possible states. Dynamical-systems theory provides a canonical model: the saddle-node bifurcation.

Consider the one-dimensional vector field

$$
F_\mu(x)=\mu-x^2,
$$

where $x$ is a state and $\mu$ is a control parameter. An equilibrium is a state at which the field vanishes:

$$
F_\mu(x)=0.
$$

Equilibria therefore solve

$$
x^2=\mu.
$$

As $\mu$ passes through zero, the number of real solutions changes.

### The Saddle-Node Classification Theorem

The equilibria of $F_\mu(x)=\mu-x^2$ are completely classified as follows.

1. If $\mu<0$, there are no real equilibria.
2. If $\mu=0$, the unique equilibrium is $x=0$.
3. If $\mu>0$, there are exactly two equilibria,

$$
x=\sqrt{\mu}
\qquad\text{and}\qquad
x=-\sqrt{\mu}.
$$

The proof is elementary but revealing. Since every real square satisfies $x^2\ge0$, the equation $x^2=\mu$ is impossible when $\mu<0$. At $\mu=0$, only $x=0$ has square zero. For positive $\mu$, factoring gives

$$
x^2-\mu=(x-\sqrt{\mu})(x+\sqrt{\mu}),
$$

so a solution must lie on one of the two square-root branches.

Picture the equilibria in the $(\mu,x)$ plane. Nothing exists to the left of the critical value. At $\mu=0$, two branches meet in a degenerate point. To the right, they peel apart with the characteristic square-root profile. This is the saddle-node: a local birth or annihilation of two equilibria at a critical parameter.

The delayed network and the saddle-node describe different objects. The first is an input-output trajectory indexed by time; the second is an equilibrium equation indexed by a control parameter. Their connection here is a shared threshold, not an assertion that one has been derived from the other. Pairing them creates a clean conceptual model: an observable can remain inactive until a critical time, while a nearby state-space description changes its number of admissible equilibria at a critical parameter.

## One combined transition picture

The two pieces can be summarized in a single theorem.

### The Grokking–Saddle-Node Transition Theorem

Fix any real delay $d$. The width-one two-layer score

$$
G_d(t)=\max\{t-d,0\}
$$

fails the positivity criterion for every $t\le d$ and satisfies it for every $t>d$. Simultaneously, the normal-form field

$$
F_\mu(x)=\mu-x^2
$$

has no equilibrium when $\mu<0$, exactly one equilibrium $x=0$ when $\mu=0$, and exactly the two equilibria $x=\pm\sqrt{\mu}$ when $\mu>0$.

The proof combines the rectifier’s two cases with the complete solution of $x^2=\mu$. No limiting argument or numerical approximation is needed.

The theorem separates three notions that are often blurred in discussions of abrupt learning. First, **delay** concerns when an observable becomes nonzero. Second, **criticality** concerns the parameter value at which a qualitative change occurs. Third, **bifurcation** concerns a change in the solution set of an equilibrium equation. In a richer learning theory these notions might be linked by a loss landscape and an optimizer. In the minimal model they are placed side by side so that each can be understood exactly.

## What the tiny model teaches

The most important lesson is that delayed observation does not imply delayed motion. Before $d$, the preactivation $t-d$ changes continuously with slope $1$, yet the visible score stays at $0$. The gate hides all negative preactivation values. A long plateau can therefore coexist with perfectly regular latent progress.

Second, the model shows why the precise definition of “generalization” matters. Here it means only that a scalar test score is positive. That criterion is mathematically transparent, but far narrower than accuracy over a population, classification margin on a test set, or expected loss. Changing the criterion changes the theorem one should seek.

Third, square-root scaling offers a diagnostic signature of the saddle-node picture. Above criticality, the equilibrium magnitude is

$$
|x|=\sqrt{\mu}.
$$

Doubling the parameter does not double the branch amplitude; it multiplies it by $\sqrt{2}$. In empirical settings, observing such scaling can motivate a bifurcation hypothesis, although it cannot by itself establish the mechanism.

Finally, minimal examples are valuable precisely because they expose assumptions. The time dependence is prescribed rather than learned. There is no dataset, no loss function, no training/test split, and no stochastic optimizer. The saddle-node parameter is paired with the delayed score but is not derived from network weights. These are not hidden defects; they mark the boundary between an exact mechanism and a full theory of learning.

## An experiment anyone can reproduce

Choose a delay such as $d=3$ and make a table of times around it. At $t=2.9$, the preactivation is $-0.1$ and the score is $0$. At $t=3$, both are $0$. At $t=3.1$, the preactivation and score are $0.1$. Then vary the saddle-node parameter: $\mu=-1$ gives no real equilibrium, $\mu=0$ gives only $x=0$, and $\mu=4$ gives $x=-2$ and $x=2$. Plotting these two experiments side by side makes the conceptual distinction visible. The first graph is one continuous, kinked trajectory through time. The second is a set of possible stationary states over a parameter. One graph answers “when does the score turn on?”; the other answers “how many equilibria exist?” Their critical points align naturally, but their mathematical meanings remain distinct.

## From a toy threshold to a theory of learning

Several extensions would move the model toward modern grokking experiments. A finite-width network could replace the single hidden unit, and generalization could mean positivity of the smallest classification margin over a finite test set. A training process could then be introduced, with the threshold trajectory derived from gradient flow or weight-decayed gradient descent rather than supplied in advance.

A true train/test separation would sharpen the narrative further: training error could reach zero early while test error remains positive until the delayed threshold. On the dynamical side, derivatives could establish the standard nondegeneracy conditions for a saddle-node and determine the stability of the two equilibrium branches. Perturbation theory could ask whether the delayed crossing and branch structure survive small changes. The decisive connection would derive the normal form from a reduced neural loss landscape, turning $\mu$ into an optimizer, regularization, or data-dependent parameter.

The small model does not settle why large networks grok. It does something more foundational: it supplies a fully transparent example in which a network’s observable behavior is exactly dormant and then exactly active, and it places that transition beside the archetypal birth of equilibria. The resulting picture is simple enough to solve on paper yet rich enough to clarify a recurring mystery of learning: sometimes the work is happening before the result can be seen.