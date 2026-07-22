# Time-Travel Logic: When a Loop Is Not a Paradox

*By Aristotle — July 22, 2026*

A time traveler enters a machine, vanishes into yesterday, and changes the event that sent them there. Popular stories treat the resulting contradiction as a fog of metaphysics. Mathematics asks a sharper question: what, exactly, is looping? A sequence of states can return to where it began without any state being compatible with what happens next. That small distinction separates a repeating history from a self-consistent one.

This article develops a spare mathematical world in which that distinction becomes exact. It has no wormholes, curved spacetime, or quantum amplitudes. It begins with a set $X$ of possible event-states and a deterministic causal law

$$
f:X\to X.
$$

If the present state is $x$, the next state is $f(x)$. Repeated application gives $f^2(x)=f(f(x))$, then $f^3(x)$, and in general $f^n(x)$. This simple language is enough to isolate three ideas often blurred together in discussions of time travel: closure, consistency, and fixed points.

## Three meanings of “the story comes back”

A **closed causal orbit of positive period $p$** begins at a state $x$ and returns after $p>0$ updates:

$$
f^p(x)=x.
$$

The visited states are $x,f(x),\ldots,f^{p-1}(x)$. Closure says only that the journey returns. It does not say that any individual state is unchanged by the causal law.

A visited state $y$ is a **fixed point** if

$$
f(y)=y.
$$

A loop **contains a fixed point** when $f^k(x)$ is fixed for some index $k$ with $0\le k<p$.

Finally, the loop is **pointwise self-consistent in the Novikov sense** when every visited state is fixed:

$$
f\bigl(f^k(x)\bigr)=f^k(x)\qquad\text{for every }0\le k<p.
$$

This is deliberately strong. It says that applying the causal rule at any point on the loop leaves that event-state unchanged. In this deterministic model, consistency is not merely “eventually returning”; it is local stability everywhere along the closed history.

The first easy result is that a nonempty self-consistent loop contains a fixed point. The starting state itself supplies one: choose $k=0$. A second result runs in the other direction from a fixed start. If $f(x)=x$, then induction gives $f^n(x)=x$ for every $n\ge0$, so every visited state equals the same fixed state and the orbit is self-consistent.

The crucial bridge is stronger.

**Fixed-event collapse theorem.** If a deterministic orbit closes after $p>0$ steps and one of its visited states is fixed, then the starting state is fixed and every state on the orbit is equal to it.

To see why, suppose $y=f^k(x)$ and $f(y)=y$. Every later iterate remains $y$. In particular, advancing the remaining $p-k$ steps gives $f^p(x)=y$. Closure also gives $f^p(x)=x$, hence $x=y$. Once the start is fixed, all iterates are identical.

This yields the central statement.

**Novikov fixed-point equivalence.** On every nonempty closed orbit of a deterministic causal law, pointwise self-consistency holds if and only if the orbit contains a fixed point.

One direction is immediate because every point in a self-consistent loop is fixed. In the other direction, one fixed visited event collapses the closed deterministic orbit to a constant history, which is self-consistent.

This theorem reveals something unexpectedly severe about the model. A deterministic closed loop cannot contain a fixed event alongside genuinely changing events. If one point becomes immovable, closure drags the entire cycle into that point. A fixed point is not a quiet station on a moving circular railway; it is a terminus that absorbs the whole route.

## Laws that settle after one step

Some causal laws erase further change as soon as they act. Mathematicians call $f$ **idempotent** when

$$
f(f(x))=f(x)\qquad\text{for every }x\in X.
$$

Projection is the standard picture. Imagine a system that replaces every messy state by its canonical representative. Applying the cleanup twice does nothing beyond applying it once. Database normalization, rounding to an allowed category, and projecting a point onto a chosen coordinate axis all have this flavor.

Under an idempotent law, every state reached after at least one update is fixed. Indeed, the first update produces $f(x)$, and idempotence says that another update leaves it unchanged. Induction then shows

$$
f^n(x)=f(x)\qquad\text{for every }n>0.
$$

Now combine this with closure.

**Idempotent causal-loop collapse theorem.** If $f$ is idempotent, $p>0$, and $f^p(x)=x$, then $f(x)=x$. Consequently the closed orbit is constant and pointwise self-consistent.

The proof is a single collision of equations. Positive iteration lands at the fixed state $f(x)$, while closure says the same iterate lands back at $x$. Thus $x=f(x)$. In this setting three descriptions coincide on a positive closed orbit: the orbit is Novikov-consistent; its starting point is fixed; and it contains a fixed point.

The idempotence assumption matters. Without it, repetition can masquerade as consistency.

## The grandfather switch

Strip the grandfather paradox to one bit. Let $A=1$ mean “the ancestor survives” and $A=0$ mean “the ancestor does not survive.” The intervention flips the bit:

$$
g(A)=1-A.
$$

There is no fixed state. If $A=0$, then $g(A)=1$; if $A=1$, then $g(A)=0$. So the consistency equation $g(A)=A$ has no solution.

Yet the dynamics are perfectly periodic. Two flips restore the original state:

$$
g^2(A)=A.
$$

More generally, $g^{2m}(A)=A$ for every nonnegative integer $m$, while $g^{2m+1}(A)=1-A$. Therefore every even number of interventions closes the orbit, and no odd number does.

This produces a precise no-go result.

**Grandfather-paradox theorem.** The Boolean flip has no self-consistent state. No odd-period orbit closes. Every even-period orbit closes, but every positive even-period orbit is inconsistent because its first update changes the current state. In particular, the two-step orbit is closed but not Novikov-consistent.

The example is also not idempotent: $g(g(A))=A$ whereas $g(A)=1-A$. It therefore pinpoints why the collapse theorem needs its hypothesis. Periodicity alone does not cure contradiction. A pendulum returns; a blinking light repeats; a two-state paradox cycles. None is locally unchanged.

This lesson reaches beyond fictional time machines. In distributed computing, a process may revisit a global configuration while individual updates continue to alter it. In control systems, a limit cycle is not an equilibrium. In economics, recurring market states need not be stable under the next trading round. “We came back” and “nothing conflicts with itself” are mathematically different claims.

## Escape by branching

There is another way to model a traveler’s intervention: refuse to overwrite the past. Represent a timeline as a finite list of events

$$
H=[e_1,e_2,\ldots,e_n].
$$

Travel with an intervention $a$ creates a new timeline by appending one event:

$$
T(H,a)=H\mathbin{+\!+}[a].
$$

Here $+\!+$ denotes list concatenation. The source history remains intact. The new history is a child branch.

Define $H$ to be an **ancestor** of $K$ when $H$ is a prefix of $K$: there exists a list $R$ such that $K=H\mathbin{+\!+}R$. Define $K$ to be a **strict descendant** of $H$ when $H$ is an ancestor of $K$ and $H\ne K$.

Several structural facts follow.

First, every travel operation preserves its source as an ancestor, because

$$
T(H,a)=H\mathbin{+\!+}[a].
$$

Second, the new branch has length $|H|+1$, so it cannot equal $H$. Thus travel always creates a strict descendant.

Third, strict descent is transitive. If $B$ strictly extends $A$ and $C$ strictly extends $B$, then prefix transitivity makes $A$ a prefix of $C$. Moreover, the lengths strictly increase, so $A\ne C$. Hence $C$ is a strict descendant of $A$.

Fourth, no history is its own strict descendant. The definition would require both $H=H$ and $H\ne H$. This irreflexivity is the branching model’s acyclicity law.

Finally, different interventions create different sibling branches. If $a\ne b$, then

$$
H\mathbin{+\!+}[a]\ne H\mathbin{+\!+}[b].
$$

The two branches have equal length. A prefix relation between equal-length finite lists forces equality, so neither sibling can be an ancestor of the other. They are incomparable descendants of the same source.

**Branch-creation theorem.** Appending an intervention creates a strict descendant of the source. Strict descent is transitive and irreflexive, so repeated branch creation cannot form a causal loop. Distinct interventions from one source create distinct, mutually incomparable sibling timelines.

The “paradox” is dissolved by changing the data structure. In the loop model, the intervention acts on a state that must somehow feed back into itself. In the branch model, the intervention extends a record. The traveler does not erase the prefix that made the journey possible; the traveler creates a longer history with that prefix as ancestry.

## What the mathematics does—and does not—say

These results clarify logical architecture, not relativistic physics. A closed timelike curve is a geometric object in spacetime. Self-consistency depends additionally on a law governing matter and events along that curve. Geometry alone does not provide the deterministic update $f$, much less prove that its states are fixed. Any claim about a Gödel universe would require a Lorentzian spacetime, timelike curves, Gödel’s metric, and a specified evolution law. Closure in spacetime must not be silently identified with consistency of dynamics.

The small model nevertheless offers a useful map. Deterministic loops obey a rigid fixed-point equivalence. Idempotent laws collapse positive closed orbits to equilibria. The grandfather flip proves that even perfect periodicity can remain inconsistent. Branching histories avoid overwrite paradoxes because extension is acyclic.

The deepest idea is also the simplest: a circle and a fixed point are not the same thing. A story can return to its first page while changing every sentence along the way. To call that story self-consistent, one must specify what consistency demands. Once that demand is written as an equation, the mist clears—and the paradox becomes a theorem about dynamics, fixed points, and the shape of history.