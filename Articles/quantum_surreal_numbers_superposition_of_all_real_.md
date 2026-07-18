# When Infinitesimals Enter the Quantum Lottery

## A journey from surreal labels to observable probabilities

Imagine a number line that does not stop at the largest finite magnitude, because there is no largest one, and does not run out of room between zero and every positive real number. Conway’s surreal numbers form such a landscape. They contain the real numbers, but also infinite quantities and positive infinitesimals: numbers greater than zero yet smaller than every positive real number. The resulting ordered field is an irresistible setting for asking a quantum question: what would it mean to place number-labelled alternatives into superposition when both the labels and the probability calculus can reach beyond ordinary real arithmetic?

The answer begins with an important separation of roles. A label tells us *which outcome* a branch represents. An amplitude tells us *how much statistical weight* that branch carries. Confusing those roles leads to a seductive but false prediction: that an outcome labelled by an infinitesimal number should itself be nearly impossible to observe. The mathematics says otherwise. Infinitesimal invisibility belongs to amplitudes, not labels.

This distinction produces a clean finite theory of non-Archimedean measurement. It also suggests a broader principle: an exotic probability model may contain finer information than ordinary observation can reveal. The operation called the **standard part** turns that fine-scale model into its classical shadow.

## Two kinds of extraordinary number

Surreal numbers and hyperreal numbers play different parts in the story.

A surreal number may serve as a basis label. We write the ket associated with a surreal number $s$ as $|s\rangle$. A finite state is a formal superposition

$$
|\psi\rangle=\sum_{s\in S} a_s|s\rangle,
$$

where $S$ is a finite set of surreal numbers and the amplitudes $a_s$ belong to a non-Archimedean ordered field of hyperreal numbers. “Non-Archimedean” means that this field contains nonzero infinitesimals. A positive hyperreal $\eta$ is infinitesimal if

$$
0<\eta<r
$$

for every positive real number $r$.

A finite hyperreal lies infinitely close to a unique real number. Its **standard part**, written $\operatorname{st}(x)$, is that real number. Thus $\operatorname{st}(3+\eta)=3$ and $\operatorname{st}(\eta)=0$ whenever $\eta$ is infinitesimal. Standard part does not claim that $\eta$ equals zero in the richer field. It says that ordinary real-valued observation cannot distinguish $\eta$ from zero.

For a state with real or hyperreal amplitudes, define its squared norm by

$$
\|\psi\|^2=\sum_{s\in S}a_s^2.
$$

For simplicity the amplitudes here are ordered-field scalars, so squaring replaces the complex absolute square familiar from conventional quantum mechanics. The exact Born weight of branch $s$ is

$$
P_*(s\mid\psi)=\frac{a_s^2}{\|\psi\|^2}.
$$

This value is hyperreal. The probability visible to an ordinary observer is

$$
P_{\mathrm{obs}}(s\mid\psi)=\operatorname{st}\!\left(P_*(s\mid\psi)\right).
$$

The subscript on $P_*$ is a reminder that this is the fine-grained, non-Archimedean weight, before observation removes infinitesimal detail.

## Conservation survives the larger number system

The first reassurance is that nothing happens to normalization. For every finite state with $\|\psi\|^2\ne0$, the exact weights satisfy the **Born Normalization Theorem**:

$$
\sum_{s\in S}P_*(s\mid\psi)=1.
$$

The proof is the same algebra that works over the reals:

$$
\sum_{s\in S}\frac{a_s^2}{\|\psi\|^2}
=\frac{\sum_{s\in S}a_s^2}{\|\psi\|^2}
=1.
$$

The richer field introduces tiny positive weights, but it does not lose or create total exact mass.

A second theorem explains when such tiny weights disappear observationally. Call a positive finite hyperreal **appreciable** if it is not infinitesimal. The **Infinitesimal-Branch Theorem** states: if $a_s$ is infinitesimal and the total squared norm $\|\psi\|^2$ is appreciable, then

$$
P_{\mathrm{obs}}(s\mid\psi)=0.
$$

Why is appreciability essential? Squaring an infinitesimal amplitude still gives an infinitesimal. Dividing it by an appreciable denominator keeps it infinitesimal, and standard part sends it to zero. But if the entire state had an even smaller norm, normalization could magnify a tiny numerator into an appreciable ratio. Smallness is relational. An infinitesimal branch is invisible only against an appreciable total scale.

## The corrected epsilon experiment

Let $\varepsilon$ be a positive infinitesimal and consider

$$
|\psi_\varepsilon\rangle=|0\rangle+\varepsilon|1\rangle.
$$

Its squared norm is

$$
\|\psi_\varepsilon\|^2=1+\varepsilon^2.
$$

The exact weights are therefore

$$
P_*(0\mid\psi_\varepsilon)=\frac{1}{1+\varepsilon^2},
\qquad
P_*(1\mid\psi_\varepsilon)=\frac{\varepsilon^2}{1+\varepsilon^2}.
$$

Both are legitimate hyperreal probabilities, and they sum exactly to one. Yet their observed probabilities are

$$
P_{\mathrm{obs}}(0\mid\psi_\varepsilon)=1,
\qquad
P_{\mathrm{obs}}(1\mid\psi_\varepsilon)=0.
$$

The infinitesimal branch has not been deleted. It survives in the fine-scale state and carries a strictly positive exact weight. It vanishes only after passage to ordinary real observation.

This resembles familiar threshold effects in science. A detector can be governed by a faithful microscopic model while reporting a coarser macroscopic outcome. The standard-part rule is not an arbitrary cutoff such as “ignore everything below $10^{-12}$.” It is scale-independent: every genuine infinitesimal is removed, while every positive appreciable standard component remains.

## Why an infinitesimal label is not enough

Now consider the initially tempting state

$$
|\phi\rangle=\frac{1}{\sqrt{2}}|0\rangle+rac{1}{\sqrt{2}}|\varepsilon\rangle.
$$

The second label is infinitesimal, but its amplitude is not. The two branches have equal nonzero amplitudes. More generally, for any two distinct surreal labels $s$ and $t$ and any nonzero amplitude $a$, define

$$
|\phi_{s,t,a}\rangle=a|s\rangle+a|t\rangle.
$$

The **Equal-Amplitude Theorem** states that both exact Born weights and both observed probabilities are one half:

$$
P_*(s\mid\phi_{s,t,a})=P_*(t\mid\phi_{s,t,a})=\frac12,
$$

and

$$
P_{\mathrm{obs}}(s\mid\phi_{s,t,a})
=P_{\mathrm{obs}}(t\mid\phi_{s,t,a})=\frac12.
$$

Indeed, the squared norm is $2a^2$, so each ratio is $a^2/(2a^2)=1/2$. Nothing in this calculation examines whether $s$ or $t$ is finite, infinite, or infinitesimal. Labels select orthogonal alternatives; amplitudes allocate weight.

Consequently, the proposed prediction that $|0\rangle$ occurs with probability $1/2$ while $|\varepsilon\rangle$ occurs with probability $0$ is incompatible with the Born rule when their amplitudes are equal. The corrected experiment is $|0\rangle+\varepsilon|1\rangle$, where the infinitesimal appears in the amplitude. This is more than a technical adjustment. It marks the conceptual boundary between the geometry of outcomes and the statistics of outcomes.

## A classical shadow: infinitesimal atoms and a reservoir

The same phenomenon can be seen without quantum notation. Consider a finite sample space containing $n$ visible atoms, labelled $1,\dots,n$, and one reservoir atom $\bot$. Use ordered pairs of rationals to encode numbers of the form

$$
a+b\delta,
$$

where $\delta$ is a formal positive infinitesimal and comparison is lexicographic: the real-scale coefficient $a$ is compared first, and $b$ breaks ties.

Assign each visible atom weight $\delta$ and the reservoir weight $1-n\delta$. An event containing $k$ visible atoms has weight

$$
\mu(A)=
\begin{cases}
k\delta, & \bot\notin A,\\
1-(n-k)\delta, & \bot\in A.
\end{cases}
$$

These weights are finitely additive and the whole sample space has exact mass one. Define standard part by

$$
\operatorname{st}(a+b\delta)=a.
$$

The **Dirac Collapse Theorem** says

$$
\operatorname{st}(\mu(A))=
\begin{cases}
1, & \bot\in A,\\
0, & \bot\notin A.
\end{cases}
$$

Thus every visible atom has exact positive infinitesimal mass but observed mass zero, while the reservoir carries observed mass one. The observed measure is the Dirac measure concentrated at $\bot$. It remains finitely additive because taking the first coordinate respects addition.

This discrete model and the epsilon state share the same signature: exact normalization, positive infinitesimal components, and a standard-part shadow that concentrates on the appreciable sector.

## What this framework offers

The immediate achievement is modest but precise. It is not yet an infinite-dimensional spectral theory, nor a complete replacement for complex quantum mechanics. It is a finite measurement calculus that cleanly separates three layers:

1. surreal numbers can label an extraordinarily rich space of outcomes;
2. hyperreal amplitudes can encode infinitesimal statistical distinctions;
3. standard part maps those distinctions to ordinary real probabilities.

That separation could matter wherever a model contains effects smaller than every fixed real threshold. In perturbation theory, infinitesimal components can preserve ordering information without contaminating leading-order predictions. In decision theory, lexicographic probabilities express priorities that ordinary probabilities compress. In asymptotic physics, a non-Archimedean state can retain idealized residual branches while its classical shadow records only macroscopic outcomes.

The framework also gives a warning. Exotic labels do not automatically imply exotic statistics. An infinite energy label, an infinitesimal position label, or a late-born surreal label changes the identity of an outcome, not its probability. Statistical suppression must enter through amplitudes or through the measurement map.

## The next staircase

Several questions now become sharply posed. For an arbitrary finite state with finite amplitudes and appreciable norm, do all standard-part Born weights form a real probability distribution of total mass one? Can states that differ only infinitesimally be identified through observational equivalence, and is that identification preserved under tensor products? Can symmetric matrices over a real-closed non-Archimedean field be diagonalized in a way whose finite eigenvalues descend under standard part? Can multiple layers of infinitesimals produce a hierarchy of observations rather than a single collapse?

Each question asks how much fine structure survives when one passes from an enriched number system to ordinary data. The central lesson is already visible. Infinitesimals need not be treated as sloppy approximations or discarded errors. They can be exact mathematical quantities whose observational shadow is zero. A branch may be present, positive, and normalized in the microscopic arithmetic while remaining absent from every real-valued measurement.

In practical terms, the theory offers a disciplined language for separating exact structure from reported structure. It records distinctions at every infinitesimal scale, specifies the map by which those distinctions are forgotten, and proves that the dominant probabilities remain coherent. That combination is valuable whenever “too small to observe” must not be confused with “mathematically absent.”

That is the peculiar beauty of the non-Archimedean quantum lottery: everything counts exactly, even what can never be seen.