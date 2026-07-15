# When Time Loops Back: Recurrence, Symmetry, and the Mathematics of Consistent Histories

Imagine entering a time machine with a red card and emerging in your own past with a blue one. If the machine always switches red to blue and blue to red, what color could the card have had all along? Neither answer survives a single trip. Red returns as blue; blue returns as red. This is the mathematical skeleton of a grandfather paradox: every proposed history disagrees with its own consequence.

Yet the same machine has a quieter secret. Send the card around twice and it comes back unchanged. The first journey has no consistent state, but the second has nothing *but* consistent states. This distinction—between consistency after one traversal and recurrence after several—opens a surprisingly rich theory of causal loops. It connects time-travel puzzles to permutations, parity, coordinate changes, product systems, and fixed-point theorems.

The central object is deliberately simple. Let $S$ be a set of possible world-states, and let $f:S\to S$ describe the net effect of one complete trip around a causal loop. A state $s\in S$ is **self-consistent** when

$$
f(s)=s.
$$

Such a state reproduces itself exactly: what enters the loop is what the loop causes to enter. A loop is self-consistent if it has at least one such state. It is **paradoxical** if $f(s)\ne s$ for every $s\in S$. After $n$ traversals, the relevant transformation is the iterate $f^n$, with $f^0$ the identity and $f^{n+1}=f\circ f^n$.

This spare language separates physics from logic. It does not claim that time machines exist. It asks instead: if a closed causal process is represented by a transformation, what can mathematics force about its consistent histories?

## Consistency does not depend on the names of things

Suppose one observer labels states with colors while another uses numbers. More generally, let $e:S\to T$ be a bijection—a perfect relabeling with an inverse. In the new coordinates, the same loop is represented by

$$
g=e\circ f\circ e^{-1}.
$$

The **Coordinate-Invariance Theorem** says that $f$ has a self-consistent state if and only if $g$ does. Indeed, if $f(s)=s$, then

$$
g(e(s))=e(f(s))=e(s).
$$

Conversely, a fixed point of $g$ can be carried back through $e^{-1}$ to a fixed point of $f$.

This sounds elementary, but it establishes an essential philosophical point. A paradox cannot be manufactured by changing notation, nor can it be erased by choosing clever coordinates. Self-consistency belongs to the causal structure itself, not to our description of it.

## Independent worlds compose cleanly

Real systems have parts. Suppose subsystem $S$ evolves by $f:S\to S$ and an independent subsystem $T$ evolves by $g:T\to T$. Their product world consists of pairs $(s,t)$, and one traversal acts as

$$
F(s,t)=(f(s),g(t)).
$$

The **Product Consistency Theorem** states that the combined loop has a self-consistent state exactly when each subsystem does. The reason is visible component by component:

$$
F(s,t)=(s,t)
$$

holds precisely when $f(s)=s$ and $g(t)=t$.

The result has a practical reading. Two decoupled consistent mechanisms remain consistent when placed side by side. But an inconsistent component poisons the product: an unrelated subsystem cannot compensate for it. This gives causal consistency a modular structure, much like reliability analysis in engineering or independent constraints in distributed systems.

## Finite worlds must recur

The deepest change of perspective comes from iteration. Assume that $S$ is finite and that $f:S\to S$ is bijective. Bijectivity means no information is lost: every state has exactly one predecessor and one successor. Such a transformation is a permutation, and every finite permutation breaks into disjoint cycles.

For example, on seven states a loop might have one $3$-cycle, one $2$-cycle, and two fixed points. A state in the $3$-cycle returns after three trips; a state in the $2$-cycle returns after two; a fixed point returns after every trip. Choosing a common multiple, such as $6$, returns all seven states simultaneously.

This is the **Universal Recurrence Theorem**: if $S$ is nonempty and finite and $f$ is bijective, then there exists an integer $N>0$ such that

$$
f^N(s)=s\qquad\text{for every }s\in S.
$$

One proof regards $f$ as an element of the finite symmetric group on $S$. Every element of a finite group has finite positive order. Taking $N$ to be the order of the permutation gives $f^N=\operatorname{id}_S$. Equivalently, decompose the permutation into cycles and take $N$ to be the least common multiple of their lengths.

A state-by-state version follows immediately: every state of an invertible loop on a finite phase space returns after some positive number of traversals. More strongly, the universal theorem supplies one clock that works for the entire world at once.

This is a discrete cousin of Poincaré recurrence. Classical recurrence says, roughly, that conservative systems revisit neighborhoods of earlier configurations. Here the conclusion is exact rather than approximate because the phase space is finite: after enough steps, every state returns exactly.

The assumptions matter. If the world has infinitely many states, the shift $f(n)=n+1$ on the integers is bijective but never returns. If the update is not invertible, trajectories can drain into attractors while forgotten states never reappear. Finiteness and reversibility together create recurrence.

## Time reversal leaves a parity fingerprint

Now impose a stronger symmetry: traversing twice always restores the original state,

$$
f(f(s))=s\qquad\text{for every }s\in S.
$$

Such a map is an **involution**. Its orbits can only have size $1$ or $2$. The one-element orbits are exactly the self-consistent states. Every other state is paired with a distinct partner.

Let $q$ be the number of fixed points and let $r$ be the number of exchanged pairs. Then

$$
|S|=q+2r.
$$

Reducing this equality modulo $2$ yields the **Parity Law for Involutive Loops**:

$$
q\equiv |S|\pmod 2.
$$

Thus the number of self-consistent states has the same parity as the total number of states. If the phase space has odd size, $q$ must be odd and therefore positive. An involutive loop on an odd finite world cannot be paradoxical. If the world has even size, fixed-point-free behavior is possible, because all states may be paired.

Parity extracts global information from almost no local detail. We need not solve $f(s)=s$ state by state. Knowing only that $f$ is self-inverse and knowing the size of the space already constrains the answer.

## The grandfather switch revisited

Return to the two-state world $S=\{0,1\}$ with the switch

$$
f(0)=1,\qquad f(1)=0.
$$

No state is fixed, so one traversal is paradoxical. But $f$ is an involution, and

$$
f^2(0)=0,\qquad f^2(1)=1.
$$

The parity law permits zero fixed points because $|S|=2$ is even. Universal recurrence chooses $N=2$. This tiny example captures the distinction between **one-step consistency** and **multi-step recurrence**. Iteration does not retroactively create a fixed point of $f$; it shows that the longer composite process $f^2$ is perfectly consistent.

That caveat is important. Saying “wait two loops” changes the process under study. It does not solve every physical interpretation of the grandfather paradox. Mathematically, however, it proves something exact: a fixed-point-free reversible transformation of a finite world can still have a positive iterate that fixes every state.

## Continuous worlds recover fixed points differently

Finite recurrence is combinatorial. On a continuous interval, consistency comes from topology instead. Let $a\le b$, and suppose a continuous function $f:[a,b]\to[a,b]$ maps the compact interval into itself. The **Interval Self-Consistency Theorem** states that there exists $x\in[a,b]$ with $f(x)=x$.

To see why, consider $h(x)=f(x)-x$. Since $f(a)\in[a,b]$, we have $h(a)\ge0$. Since $f(b)\in[a,b]$, we have $h(b)\le0$. Continuity and the intermediate value theorem force some $x$ with $h(x)=0$.

This result needs neither finiteness nor invertibility. Its engine is continuity plus the geometry of an interval. The contrast is revealing: finite reversible worlds find consistency in an iterate through cycle arithmetic, while continuous interval worlds find one-step consistency through topology.

## What the structure tells us

Together, these results turn a science-fiction puzzle into a compact mathematical program.

* **Intrinsicness:** bijective changes of coordinates preserve the existence of consistent histories.
* **Compositionality:** independent loops are jointly consistent exactly when each is consistent.
* **Recurrence:** every invertible loop on a nonempty finite world has a positive iterate equal to the identity.
* **Parity:** a self-inverse loop has as many fixed points modulo $2$ as its phase space has states modulo $2$.
* **Continuity:** every continuous self-map of a compact real interval has a fixed point.

The same ideas reach beyond time travel. A deterministic reversible computer with finitely many configurations must eventually repeat globally. A reversible finite-state protocol decomposes into cycles. A pairwise matching process leaves an unpaired object whenever the population is odd. Coordinate invariance distinguishes genuine behavior from artifacts of representation. Product consistency explains when independent components can be analyzed separately.

The broad lesson is not that paradoxes disappear. It is that they have anatomy. A one-step contradiction, a long-term recurrence, a coordinate artifact, and a compositional failure are different phenomena. Once separated, each obeys its own sharp law. The resulting picture replaces a single vague paradox with a map of distinct mathematical possibilities. In a finite reversible universe, time may fail to agree with itself after one turn—but the arithmetic of cycles guarantees that, after enough turns, every state comes home.
