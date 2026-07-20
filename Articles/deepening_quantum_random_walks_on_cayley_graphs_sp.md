# When a Quantum Walk Refuses to Settle

## How periodic motion finds equilibrium through time

A pendulum in a frictionless room would swing forever. It would never come to rest at its lowest point, yet a camera with a long exposure would reveal a stable picture: the pendulum spends a reproducible fraction of its time in each part of the arc. The instant never settles, but the history does.

Periodic quantum walks exhibit the same tension in a sharper form. Their state can return exactly to its starting point after a fixed number of steps. Such perfect recurrence rules out ordinary convergence from a localized beginning: a walker that repeatedly comes home cannot simultaneously forget where it began and approach a uniform distribution at every instant. Nevertheless, averaging the observed probabilities over time produces an exact equilibrium. No approximation and no infinitely long wait are needed when the observation window contains whole periods.

This distinction between an instantaneous snapshot and a time average is the central idea. It turns an apparent failure of mixing into a precise, finite theorem.

## Walking on a finite world

Imagine a finite set $G$ of locations, often the vertices of a Cayley graph. A Cayley graph is built from a finite group and a chosen set of moves: from a vertex $g$, each generator $s$ leads to $sg$. Cycles, hypercubes, and many highly symmetric networks arise this way.

A quantum state assigns a complex amplitude to every location. If the state at time $n$ is $\psi_n$, its amplitude at $x\in G$ is $\psi_n(x)$. Observation converts amplitude into probability through the Born rule:

$$
p_n(x)=|\psi_n(x)|^2.
$$

Evolution is given by a norm-preserving linear transformation $U$, so $\psi_n=U^n\psi_0$. The discussion below needs only one dynamical assumption: there is a positive integer $k$ such that

$$
U^k=I.
$$

The evolution then has finite order, or period dividing $k$. After every $k$ steps, every state returns exactly to itself. Consequently, for every location $x$,

$$
p_{n+k}(x)=p_n(x).
$$

Thus each observed probability is an ordinary periodic real sequence, even though it arose from complex amplitudes and interference.

## Why ordinary mixing fails

Classical random walks often mix because repeated randomness damps differences between distributions. On a connected, aperiodic finite graph, the distribution approaches a stationary law; on a regular graph that law is uniform. A purely unitary quantum evolution behaves differently. It preserves information rather than dissipating it.

Suppose the walker begins at one vertex. At times $k,2k,3k,\ldots$, the entire initial state returns. In particular, the probability of the starting vertex repeatedly returns to its initial value. Unless that initial distribution was uniform already, the instantaneous distributions cannot converge to uniformity. Recurrence is not a small technical nuisance; it is a direct obstruction to pointwise mixing.

Yet experiments and simulations rarely ask only for a single privileged instant. They often collect a histogram over many steps. That suggests replacing $p_N(x)$ by its Cesàro mean, the average of all observations before time $N$:

$$
A_N(x)=\frac{1}{N}\sum_{n=0}^{N-1}p_n(x),\qquad N>0.
$$

The question is then not whether the walker settles, but whether the accumulated record settles.

## The complete-block principle

The key fact is elementary enough to state without quantum mechanics.

**Complete-Block Summation Theorem.** Let $f(0),f(1),\ldots$ take values in any commutative additive system, and suppose $f(n+k)=f(n)$ for every $n$. For every nonnegative integer $q$,

$$
\sum_{n=0}^{qk-1}f(n)=q\sum_{n=0}^{k-1}f(n).
$$

The proof is a block decomposition. Divide the interval from $0$ through $qk-1$ into $q$ consecutive blocks of length $k$. Periodicity makes every block sum equal to the first. Adding the identical blocks gives $q$ copies of the one-period sum.

This theorem is more general than probability. It applies to vectors, integer-valued signals, flows, or any objects that can be added commutatively. Division enters only when we specialize to real-valued averages.

**Exact Periodic Averaging Theorem.** If $f:\mathbb N\to\mathbb R$ has period $k$, then for every positive integer $q$,

$$
\frac{1}{qk}\sum_{n=0}^{qk-1}f(n)
=
\frac{1}{k}\sum_{n=0}^{k-1}f(n),
$$

with the zero-period boundary understood separately. Indeed, the numerator on the left is $q$ times the one-period sum, while the denominator is $q$ times the period length, so the factor $q$ cancels.

The conclusion is exact. A window of one period, ten periods, or a million periods produces precisely the same average.

## The quantum consequence

Apply the theorem separately to the periodic Born-probability sequence at each vertex.

**Finite-Order Quantum Averaging Theorem.** Let $U^k=I$, let $\psi_0$ be any initial state, and define

$$
p_n(x)=|(U^n\psi_0)(x)|^2.
$$

For every vertex $x$ and every positive integer $q$,

$$
\frac{1}{qk}\sum_{n=0}^{qk-1}p_n(x)
=
\frac{1}{k}\sum_{n=0}^{k-1}p_n(x).
$$

The one-period Born average is therefore the canonical empirical equilibrium of the periodic walk. Notice what is not required: the argument does not use the geometry of the graph, commutativity of the underlying group, or a spectral-gap estimate. Once finite-order recurrence is known, the averaging statement follows from periodicity alone.

For a finite set $G$, the uniform probability at every vertex is $1/|G|$. This gives a complete finite criterion for uniform time-averaged mixing.

**Uniform Complete-Block Mixing Criterion.** A finite-order walk satisfies

$$
\frac{1}{qk}\sum_{n=0}^{qk-1}p_n(x)=\frac{1}{|G|}
$$

for every positive $q$ and every $x\in G$ if and only if

$$
\frac{1}{k}\sum_{n=0}^{k-1}p_n(x)=\frac{1}{|G|}
$$

for every $x\in G$.

One direction chooses $q=1$. The other uses exact periodic averaging. An infinite family of tests collapses to one finite computation.

A standard limiting statement follows immediately.

**Complete-Block Convergence Theorem.** If the one-period average is uniform, then for every vertex $x$,

$$
\lim_{q\to\infty}
\frac{1}{(q+1)k}\sum_{n=0}^{(q+1)k-1}p_n(x)
=
\frac{1}{|G|}.
$$

In fact, calling this “convergence” understates the result: every term of the displayed sequence already equals $1/|G|$.

## A four-cycle in motion

Consider four locations arranged in a cycle and a deterministic unitary shift that sends each basis state to the next location. Starting at location $0$, the observed distributions are concentrated successively at $0,1,2,3$, then return to $0$. The period is $k=4$.

At any one time the distribution is as far from uniform as possible: one location has probability $1$ and the others have probability $0$. But over one period, each location is occupied exactly once, so its average probability is

$$
\frac{1+0+0+0}{4}=\frac14.
$$

Over $q$ periods each location is occupied exactly $q$ times among $4q$ observations, again giving $q/(4q)=1/4$. Instantaneous mixing fails completely while time-averaged mixing is exact.

Uniformity is not automatic, however. A two-state evolution that merely flips the phase of the starting basis state has period $2$ but never moves probability away from the starting location. Its one-period average is concentrated there, so every complete-block average is equally nonuniform. Periodicity guarantees stabilization of the average, not fairness of that average.

## Why the result matters

The theorem changes how one should analyze finite periodic quantum systems. Instead of simulating longer and longer trajectories and hoping a histogram has stabilized, one computes exactly one orbit. This offers both conceptual and computational savings. If there are $m=|G|$ vertices and the period is $k$, a direct table of probabilities costs on the order of $mk$ arithmetic operations once the orbit is available. Testing $q$ periods naively would cost $q$ times as much while revealing no new information.

The same principle appears in other settings. A periodically driven physical system has observables whose cycle averages can be measured over any integer number of driving periods. A recurring schedule has long-run resource use determined by one cycle. A rotating signal has a stable mean despite perpetual oscillation. In each case, complete blocks erase the arbitrary choice of observation length.

There is also a warning for interpreting “mixing time.” In dissipative dynamics, a mixing time measures how long one must wait before each snapshot resembles equilibrium. In periodic unitary dynamics, that question may have no finite answer. The meaningful alternative is an averaging time: how much history must be collected to reproduce an equilibrium statistic? For complete-period windows, the answer is strikingly finite—one period.

## The boundary beyond complete periods

Real observation windows may stop midway through a cycle. If $N=qk+r$ with $0\le r<k$, the first $qk$ terms form exact complete blocks and only the final $r$ terms can cause an error. This identifies the next quantitative problem: bound the discrepancy between $A_N$ and the one-period average using only the short remainder. For probability distributions, one expects an error of order $k/N$, with the sharp constant controlled by how unevenly probability is arranged inside one period.

Spectral theory asks a different question: when is the one-period average actually uniform? Averaging cancels interference between distinct eigenphases, but degeneracies can preserve interference within a shared eigenspace. On abelian Cayley graphs, Fourier characters should expose these surviving terms; on nonabelian graphs, matrix-valued representation theory takes their place. Weak decoherence offers another direction, turning pure rotation of nonconstant modes into contraction and potentially restoring genuine instantaneous convergence.

These questions matter wherever coherent motion is observed through finite records. They ask how exact symmetry, spectral degeneracy, environmental noise, and the arithmetic of an observation window cooperate to shape what an experimenter calls equilibrium.

The fundamental lesson is already complete. Periodic motion need not become still in order to possess an equilibrium. A quantum walk may revisit its origin forever, preserving the memory that prevents ordinary mixing. But viewed through the accumulated record of whole cycles, its statistics stop changing immediately. The orbit keeps moving; the average has arrived.
