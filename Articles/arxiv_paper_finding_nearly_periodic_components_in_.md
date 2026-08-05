# The Music of Directed Graphs: How Rotations Reveal Hidden Rhythm

## A traffic light in disguise

Imagine a token hopping around a network of one-way streets. At every intersection it picks an outgoing street and moves. Watch it long enough and a question surfaces: does the wandering settle into a *rhythm*?

Some networks are pure rhythm. Take four intersections arranged in a one-way loop, $0 \to 1 \to 2 \to 3 \to 0$. A token starting at intersection $0$ is back at $0$ at times $4, 8, 12, \dots$ and never in between. The network has a heartbeat of period $4$: the vertices split into four classes that the token visits in strict rotation.

Other networks are pure chaos, in the technical sense that no such split exists. Add one shortcut $0 \to 2$ to that loop and the heartbeat dies instantly: now closed walks of length $3$ exist alongside walks of length $4$, and since $\gcd(3,4) = 1$ the token can return at essentially any time.

Between these extremes sits the interesting territory. What if a network is *almost* a $4$-cycle — a clean loop with a handful of misplaced streets? Intuitively it should still show a rhythm, one that's audible but slightly out of tune. Making "almost" precise, and finding those nearly-rhythmic pieces efficiently, is the subject of this article.

The answer turns out to be a beautiful mixture of graph theory and complex numbers, and it comes with a genuine surprise: near-periodicity, under a mild normalization, **cannot actually be near**. It's all or nothing.

## From $\pm 1$ to the roots of unity

Let's start with the simplest rhythm, period $2$. A graph is *bipartite* if you can two-colour its vertices — say black and white — so that every edge joins a black vertex to a white one. A token then alternates colours forever: rhythm of period $2$.

There is a classical way to measure how far a graph is from bipartite, due to Trevisan. Assign to each vertex $v$ a number $x_v \in \{-1, 0, +1\}$ (the $0$ meaning "this vertex sits out"). Then look at
$$\sum_{u \sim v} \bigl| x_v + x_u \bigr|^2 ,$$
summed over edges. If $x$ is a genuine two-colouring with no zeros, every edge contributes $|1 + (-1)|^2 = 0$, and the total is $0$. If the graph has an odd cycle, no assignment can make everything vanish, and the smallest achievable value — normalized by the total degree involved — is the *bipartiteness ratio*. Small ratio, nearly bipartite.

Now here's the leap. Period $2$ is the case $p = 2$; the values $+1$ and $-1$ are precisely the two square roots of unity. To handle general period $p$ we simply enlarge the alphabet from $\{-1, +1\}$ to the $p$-th roots of unity
$$1, \; \omega, \; \omega^2, \; \dots, \; \omega^{p-1}, \qquad \omega = e^{2\pi i / p} .$$
These are $p$ points spaced evenly around the unit circle in the complex plane. Instead of two colours we have $p$ *phases*, and instead of "flip sign along each edge" the rule becomes "rotate by one step along each arc". The relevant expression, for a directed graph with nonnegative arc weights $w_{uv}$, is
$$\mathcal{E}_\omega(x) \;=\; \sum_{u}\sum_{v} w_{uv}\, \bigl\| x_v - \omega\, x_u \bigr\|^2 .$$

Read the summand as an accusation: the arc $u \to v$ *expects* the phase at $v$ to be the phase at $u$ advanced by exactly one tick, $x_v = \omega x_u$. Every deviation from that expectation is charged, in proportion to the arc's weight. We call $\mathcal{E}_\omega(x)$ the **rotated energy** of the phase assignment $x$.

This is not an ad hoc formula. It is the quadratic form of a matrix — the *rotated Laplacian* $D - A_\omega$, where $A_\omega$ is the adjacency matrix with every entry multiplied by $\omega$ and $D$ is the degree matrix. Set $\omega = 1$ and you recover the ordinary graph Laplacian, whose spectrum controls connectivity, expansion, and random-walk mixing. Set $\omega = -1$ and you recover the signless Laplacian, whose spectrum controls bipartiteness. General $\omega$ interpolates and generalizes: one matrix family, one spectrum, all the periodicities at once.

To turn energy into a scale-free score we divide by the **volume**
$$\mathrm{vol}(x) = \sum_v d_v \|x_v\|^2, \qquad d_v = \sum_u (w_{vu} + w_{uv}),$$
where $d_v$ is the total in- plus out-degree of $v$. The **periodicity ratio** of the digraph at $p$ is then
$$\beta_p \;=\; \inf \left\{ \frac{\mathcal{E}_\omega(x)}{\mathrm{vol}(x)} \;:\; x \neq 0, \ \text{each } x_v \in \{0\} \cup \{\omega^k\} \right\}.$$
For $p = 2$ this is exactly Trevisan's bipartiteness ratio. For general $p$ it is a quantitative measure of how close the digraph is to having period $p$.

## First facts: the ratio is well behaved

Two sanity checks come immediately.

**The energy vanishes exactly when every arc rotates correctly.** Since all weights are nonnegative, a sum of nonnegative terms is zero only if each term is, so $\mathcal{E}_\omega(x) = 0$ if and only if $x_v = \omega x_u$ for every arc $u \to v$ carrying nonzero weight. Zero energy is a *combinatorial* statement wearing analytic clothing.

**The ratio never exceeds $2$.** For any unimodular $\omega$ and any $x$,
$$\mathcal{E}_\omega(x) \;\le\; 2\,\mathrm{vol}(x),$$
so $\beta_p \le 2$ always. The proof is the triangle inequality followed by the elementary bound $(a+b)^2 \le 2a^2 + 2b^2$, plus the observation that summing $w_{uv}$ over both endpoints reproduces exactly the in-plus-out degree. This mirrors the familiar fact that the normalized Laplacian has all eigenvalues in $[0,2]$, and it means "small ratio" is a meaningful phrase: the scale is fixed.

**Direction doesn't matter.** Reverse every arc of the digraph — replace $w_{uv}$ by $w_{vu}$ — and the periodicity ratio is unchanged. The trick is that conjugating a phase vector coordinatewise turns a certificate for the graph into a certificate for its reversal: $\overline{\omega}$ is itself a power of $\omega$ (namely $\omega^{p-1}$), so conjugates of phase vectors are phase vectors, and a short computation shows $\|\bar x_u - \omega \bar x_v\| = \|x_v - \omega x_u\|$. Periodicity is a property of the *undirected shape of the flow*, not of which way you happen to draw the arrows.

## The main theorem: zero energy means divisibility

Now the central structural result. Call a digraph *strongly connected* if you can walk (following arrows) from any vertex to any other.

> **Theorem (Characterization of vanishing periodicity ratio).** Let $w$ be a strongly connected, nonnegatively weighted digraph and let $p \ge 1$. Then there exists a unimodular $p$-phase vector of zero rotated energy — equivalently, $\beta_p$ is attained at $0$ — **if and only if** $p$ divides the length of every closed walk in the digraph.

Both directions are short and satisfying.

Suppose first that a zero-energy vector $x$ exists. Then $x_v = \omega x_u$ along every arc, so along a walk of length $n$ from $u$ to $v$ the phase multiplies by exactly $\omega^n$: $x_v = \omega^n x_u$. Apply this to a *closed* walk of length $n$ based at $v$: we get $x_v = \omega^n x_v$, and since $x_v \ne 0$ (it's unimodular) this forces $\omega^n = 1$, i.e. $p \mid n$. The phase vector is a certificate, and reading it along a cycle counts the cycle's length modulo $p$.

Conversely, suppose every closed walk has length divisible by $p$. Pick a root vertex $r$; by strong connectivity choose for each $v$ some walk from $r$ to $v$, of length $N(v)$, and set
$$x_v = \omega^{N(v)} .$$
Is this well defined enough? The length $N(v)$ depends on the walk chosen, but only modulo $p$ — two walks $r \to v$ of lengths $m, m'$ can each be completed by a fixed walk $v \to r$ into closed walks, whose lengths are both divisible by $p$, so $m \equiv m' \pmod p$. That is exactly the consistency needed, and the same argument applied to an arc $u \to v$ gives $N(v) \equiv N(u) + 1$, hence $x_v = \omega x_u$ along every arc. Energy zero.

So the exact-periodicity information carried by the rotated Laplacians is the *divisor lattice*. Two corollaries follow immediately: the set $\{p : \beta_p = 0\}$ is closed under taking divisors, and it is closed under least common multiples. A set of positive integers closed under both divisors and lcm is exactly the set of divisors of its maximum. That maximum is the classical **period** of the digraph, the gcd of all closed-walk lengths, and the rotated spectrum recovers precisely its divisors.

## A warning: zero ratio does not pin down the period

It is tempting to conjecture more: that $\beta_p = 0$ means the digraph *is* $p$-periodic in the naive sense of having a closed walk of length $p$. This is false, and the counterexample is the very first graph we met.

Take the directed $4$-cycle and the phase assignment $x_v = (-1)^v$ for $v \in \{0,1,2,3\}$. Every arc $v \to v+1$ satisfies $x_{v+1} = -x_v$, so the $2$-rotated energy is exactly zero and $\beta_2 = 0$. Yet every closed walk in the directed $4$-cycle has length divisible by $4$ — there is no closed walk of length $2$ anywhere. The vanishing $2$-ratio detects only that $2$ divides the period $4$; it says nothing about $2$ being achieved.

This is not a defect of the theory but its correct shape. Divisibility, not attainment, is what the spectrum sees, and the theorem above says so precisely.

## Markov chains: the same story, told with eigenvalues

Directed graphs with weights are Markov chains in disguise. Let $P$ be a stochastic matrix ($P_{uv} \ge 0$, rows summing to $1$) with stationary distribution $\pi$ ($\sum_u \pi_u P_{uv} = \pi_v$), and weight the arc $u \to v$ by $w_{uv} = \pi_u P_{uv}$ — the stationary flow across that arc.

Here the rotated energy acquires a probabilistic meaning. For a fixed row $u$, the numbers $P_{uv}$ are a probability distribution, so
$$\sum_v P_{uv} \|x_v - c\|^2 = \sum_v P_{uv}\|x_v\|^2 - \|c\|^2 \quad \text{whenever} \quad c = \sum_v P_{uv} x_v .$$
That is the variance identity $\mathbb{E}\|Z - \mathbb{E}Z\|^2 = \mathbb{E}\|Z\|^2 - \|\mathbb{E}Z\|^2$, applied to the random next-phase $Z = x_{V_{n+1}}$. Summing over $u$ against the weights $\pi_u$, and using stationarity to telescope, one gets:

> **Theorem (Unimodular eigenvalues are exactly zero-energy phases).** If $x$ is a right eigenvector of $P$ with eigenvalue $\omega$ of modulus $1$, then the rotated energy of $x$ for the chain weighting $w_{uv} = \pi_u P_{uv}$ is exactly zero. Conversely, if $\pi_v > 0$ for all $v$, then every zero-energy vector is such an eigenvector.

The mechanism is worth savouring. The eigenvector equation $\sum_v P_{uv} x_v = \omega x_u$ says the *average* next phase is the current phase rotated by $\omega$. The variance identity says the total energy equals $\mathbb{E}\|x\|^2$ averaged one step forward minus $\mathbb{E}\|x\|^2$ now — and stationarity says that difference is zero. Eigenvector plus unimodular eigenvalue plus stationarity forces the variance to vanish identically, which means the next phase is *deterministic*: not merely correct on average, but correct on every single arc.

Combining with the characterization theorem: if a primitive $p$-th root of unity is an eigenvalue of an irreducible chain, then $p$ divides every closed-walk length. This is the classical Perron–Frobenius fact that the peripheral spectrum of an irreducible stochastic matrix consists of $p$-th roots of unity with $p$ the period — recovered here as a statement about energies rather than determinants.

## The surprise: near-periodicity is impossible

Everything so far concerned exact periodicity, $\beta_p = 0$. The whole point of a *ratio* is to measure the near-miss case, so what does small-but-positive energy look like?

The answer is startling: on a natural class of digraphs, it doesn't look like anything, because it doesn't exist.

Define the **root gap**
$$g_p = \min_{1 \le j \le p-1} \bigl| \omega^j - 1 \bigr|^2 = 4 \sin^2(\pi/p),$$
the squared distance from $1$ to the nearest other $p$-th root of unity. For $p=2$ this is $4$; for $p=3$ it is $3$; it decays like $4\pi^2/p^2$ for large $p$. Then:

> **Theorem (Quantization of periodicity energy).** Let $w$ be a digraph in which every nonzero weight is at least $1$, let $p \ge 2$, and let $x$ be a unimodular $p$-phase vector (every $x_v$ a power of $\omega$). Then
> $$\mathcal{E}_\omega(x) = 0 \qquad \text{or} \qquad \mathcal{E}_\omega(x) \ge g_p .$$

There is nothing in between. The energy of a phase vector is either exactly zero or bounded below by an explicit universal constant depending only on $p$.

The proof is disarmingly simple once you see it. If the energy is not zero, some arc $u \to v$ of weight $w_{uv} \ge 1$ misbehaves: $x_v \ne \omega x_u$. But both $x_v$ and $\omega x_u$ are $p$-th roots of unity, and they are *distinct*. Distinct $p$-th roots of unity cannot be close — the whole finite set is uniformly separated, with minimum squared separation exactly $g_p$. So that single arc already contributes at least $1 \cdot g_p$ to the sum, and every other term is nonnegative. Discreteness of the target alphabet plus a floor on the weights equals a floor on the energy.

The immediate corollary is a **rigidity** statement: for a strongly connected digraph with weights in $\{0\} \cup [1,\infty)$, a phase vector with energy *strictly below* $g_p$ forces the digraph to be genuinely $p$-periodic — every closed walk has length divisible by $p$. Observe a whisper of rhythm and you have proved perfect rhythm. "Nearly periodic" collapses into "periodic" below the threshold.

## Why the hypothesis is exactly right

A dichotomy this clean invites suspicion. It is not universal, and the boundary is easy to locate.

Take the directed $4$-cycle again, scale every weight by a parameter $t > 0$, and probe it with $p = 3$ using the constant phase vector $x \equiv 1$. Each of the four arcs pays $\|1 - \omega_3\|^2 = 3$, so the total is $12t$, which is positive but tends to $0$ as $t \to 0$. For every $\varepsilon > 0$ there is therefore a strongly connected nonnegatively weighted digraph carrying a unimodular $3$-phase vector whose $3$-energy lies in $(0, \varepsilon)$. No universal zero-or-large dichotomy survives for arbitrary nonnegative weights.

What went wrong is scale, not structure: shrinking every weight shrinks the energy proportionally while leaving the combinatorics untouched. This is precisely why the normalized quantity — the *ratio* $\mathcal{E}/\mathrm{vol}$ rather than the raw energy $\mathcal{E}$ — is the right object for algorithms, and why the quantization theorem must fix a scale to say anything. Fix the scale (nonzero weights at least $1$) and rigidity appears; let the scale float and it evaporates. Both halves are theorems, and together they say the hypothesis is not an artifact but the exact boundary of the phenomenon.

## What it's good for

The practical payoff is a family of spectral algorithms. Given a digraph and a candidate period $p$, build the rotated Laplacian $D - A_{\omega}$ with $\omega = e^{2\pi i/p}$, compute its smallest eigenvalue and eigenvector, and *round* that eigenvector to a phase vector by snapping each coordinate to the nearest $p$-th root of unity (or to $0$ if its magnitude is small). The rounded vector's ratio upper-bounds $\beta_p$; the eigenvalue lower-bounds it. Sweeping a threshold over the coordinate magnitudes and taking the best sweep-cut is the periodicity analogue of the classical spectral partitioning heuristic, and it is what turns the theory into a polynomial-time procedure for extracting many nearly-periodic components at once.

Where would you want this? Anywhere a directed network is suspected of cyclic structure. Food webs and metabolic networks contain feedback loops with characteristic lengths. Web graphs and citation graphs contain near-cyclic communities. Queueing networks and manufacturing lines are approximately periodic by design; detecting the actual period from observed transitions is a diagnostic. And for Markov chain Monte Carlo, near-periodicity is a *bug* — a chain whose transition matrix has an eigenvalue near a root of unity mixes slowly and produces correlated samples — so measuring $\beta_p$ for small $p$ is a health check on the sampler.

The rigidity theorem carries a message for all of these: on unit-weighted networks, if you look for a period and find only a faint signal, you have not found a faint signal. You have found the real thing, or nothing at all.

## Coda

The chain of ideas here is short enough to hold in one thought. Rhythm in a directed network means a consistent assignment of phases advancing one tick per arc. Phases live on the roots of unity, a discrete set. Consistency is measured by an energy, which is the quadratic form of a rotated Laplacian, whose spectrum is computable. Zero energy means the period is divisible by $p$ — no more, no less. And because roots of unity are discrete, the energy of a phase assignment cannot be small without being zero.

Discreteness of the alphabet becomes rigidity of the geometry. That is a theme far larger than graphs, and it is pleasant to watch it play out on something as concrete as a token hopping around one-way streets.
