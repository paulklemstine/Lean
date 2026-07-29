# How Far Can a Cell See? Finite Causality in Conway’s Game of Life

Conway’s Game of Life looks infinite. Its board extends without boundary in every direction, and at each tick every square changes at once. A distant constellation may be unimaginably complicated; the future may contain gliders, oscillators, collisions, and structures capable of carrying information. Yet if we ask one sharply focused question—will this particular cell be alive after a fixed number of generations?—the apparent infinity collapses to a finite calculation.

That collapse is the central idea of this article. We will define Life precisely, isolate its local causal structure, and prove a finite simulation theorem: the state of one cell after $t$ generations depends on only finitely many initial cells. An explicit recursively defined dependency cone contains all the information that can matter, and its size is at most $9^t$. This bound is deliberately simple rather than geometrically sharp, but it gives a rigorous certificate that exact local prediction requires inspecting only finite data.

This is an important foundation for studying computation in Life. It is not, by itself, a proof that Life can simulate every computer. Such a universality result requires concrete signal carriers, gates, memory, routing, and a compiler from a machine model. What finite causality supplies is the stage on which those constructions can be assembled without interference from an uncontrolled infinite background.

## The world and its local law

The board is the integer lattice

$$
\mathbb{Z}^2=\{(x,y):x,y\in\mathbb{Z}\}.
$$

Each lattice point is a cell. At any moment a cell is either alive or dead, so a configuration is a function

$$
c:\mathbb{Z}^2\to\{0,1\},
$$

where $1$ means alive and $0$ means dead.

A cell at $p=(x,y)$ has eight neighbors: the cells obtained by changing each coordinate by $-1$, $0$, or $1$, while excluding $p$ itself. This is the Moore neighborhood. The nine-cell set formed by adding the center cell is the closed Moore neighborhood.

The first elementary fact is worth stating because every later count rests on it.

**Eight-Neighbor Theorem.** Every cell has exactly eight distinct Moore neighbors and exactly nine cells in its closed Moore neighborhood.

The proof is direct: list the three cells in the row above, the two lateral cells in the same row, and the three cells in the row below. Their coordinate pairs are distinct. Consequently, the number of live neighbors of any cell lies between $0$ and $8$.

Life updates all cells synchronously according to the B3/S23 rule. If a cell has $n$ live neighbors, then its next state is alive exactly when either

$$
n=3,
$$

or it is currently alive and

$$
n=2.
$$

Thus a dead cell is born with exactly three live neighbors; a live cell survives with two or three; all other cells are dead in the next generation. Let $S(c)$ denote the configuration obtained from $c$ after one update, and let $S^t(c)$ denote the result after $t$ updates.

## Silence is stable

Before following complicated patterns, consider the empty universe. Every cell is dead, every live-neighbor count is $0$, and a dead cell with no live neighbors remains dead.

**Empty-Universe Stability Theorem.** If $c(p)=0$ for every cell $p$, then $S^t(c)(p)=0$ for every $p$ and every nonnegative integer $t$.

For one generation the claim follows immediately from the local rule. Repeating the same argument gives the result for all finite times. This simple theorem is a useful baseline: activity cannot arise from nowhere. A finite pattern placed in an otherwise empty universe can influence only cells reached through successive local neighborhoods.

## One step of causality

Suppose two enormous universes differ in countless places, but around one selected cell $p$ they agree on all nine cells of the closed neighborhood. Will they give the same next state at $p$? Yes.

**One-Step Locality Theorem.** If two configurations agree on the closed Moore neighborhood of $p$, then after one generation they agree at $p$.

The reason is exact, not approximate. Agreement at the center tells us whether $p$ is presently alive. Agreement at the eight neighbors gives the same live-neighbor count. The update rule sees nothing else, so it must return the same result.

This theorem expresses a finite speed limit. In one tick, no information can jump across two lattice spacings. But after many ticks the relevant region grows, because each neighbor has its own neighborhood, and each of those cells has another.

## Building the dependency cone

Fix a target cell $p$. Define its time-$0$ dependency cone by

$$
D_0(p)=\{p\}.
$$

Then define the cone recursively. Once $D_t(p)$ is known, take the closed neighborhood of every cell in it and unite those sets:

$$
D_{t+1}(p)=\bigcup_{q\in D_t(p)} \overline{N}(q),
$$

where $\overline{N}(q)$ denotes the nine-cell closed Moore neighborhood of $q$.

This construction runs backward through causality. To know $p$ at time $t+1$, we need the closed neighborhood of $p$ at time $t$. To know those cells at time $t$, we need their closed neighborhoods at time $t-1$, and so on until we reach the initial configuration.

For small times the geometry is easy to picture. The set $D_0(p)$ is one cell. The set $D_1(p)$ is a $3\times3$ square. The set $D_2(p)$ is a $5\times5$ square. These examples suggest the sharper geometric description of the cone as a Chebyshev ball of radius $t$, a square with $(2t+1)^2$ cells. Establishing that exact identity is a natural next theorem; the results proved here use only the recursive union and a uniform ninefold bound.

## The finite simulation theorem

We can now state the central result.

**Finite Dependency Theorem.** Let $c$ and $d$ be two initial configurations, let $p$ be a cell, and let $t$ be a nonnegative integer. If

$$
c(q)=d(q)\qquad\text{for every }q\in D_t(p),
$$

then

$$
S^t(c)(p)=S^t(d)(p).
$$

In words: anything outside $D_t(p)$ is irrelevant to the state of $p$ after $t$ generations.

The proof is an induction on time. At time $0$, agreement on $D_0(p)=\{p\}$ is exactly agreement at $p$. For the inductive step, the next state at $p$ is determined by its closed neighborhood. For each cell $q$ in that neighborhood, the cells needed to determine $q$ after $t$ generations lie inside $D_{t+1}(p)$. Agreement on the larger cone therefore gives agreement at time $t$ throughout the closed neighborhood of $p$. The One-Step Locality Theorem then forces agreement at $p$ one generation later.

The key inclusion behind the induction is itself intuitive. If $q$ lies in the closed neighborhood of $p$, then

$$
D_t(q)\subseteq D_{t+1}(p).
$$

Every backward causal path of length $t$ ending at $q$ becomes a path of length $t+1$ ending at $p$ by adding the final neighboring step.

## How large is the finite calculation?

A theorem saying “finite” is qualitative. For algorithms, we also want a numerical bound.

**Dependency-Cone Size Theorem.** For every cell $p$ and every nonnegative integer $t$,

$$
|D_t(p)|\le 9^t.
$$

At time $0$, the cone has one cell, and $1=9^0$. At the next stage, each cell already in the cone contributes at most nine cells through its closed neighborhood. Different neighborhoods overlap, which only makes the union smaller. Therefore

$$
|D_{t+1}(p)|
\le \sum_{q\in D_t(p)}|\overline{N}(q)|
=9|D_t(p)|
\le 9\cdot9^t
=9^{t+1}.
$$

The estimate is coarse. The observed cones have square geometry and suggest the sharper quadratic count $(2t+1)^2$, while $9^t$ grows exponentially. Why retain the weaker established bound? Because it follows from locality alone, without yet developing the required distance geometry. It is also the natural cost bound for a naive recursive evaluator that branches into all nine possible predecessors at every time step before removing duplicates.

Combining correctness and size gives a compact simulation certificate.

**Finite Simulation Certificate.** To determine the state of a chosen cell $p$ after $t$ generations, it is sufficient to inspect the initial configuration on $D_t(p)$; this set contains at most $9^t$ cells. Any two full configurations that match on those inspected cells produce the same answer at $p$ after $t$ generations.

This statement separates the infinite mathematical universe from the finite computational task. One may fill the rest of the plane arbitrarily, and the target answer does not change.

## A practical local simulator

The theorem suggests two related algorithms. The first constructs $D_t(p)$ by repeatedly expanding a finite set through closed neighborhoods. It then reads the initial states on that set and evolves only a sufficiently padded finite window. The second uses recursive evaluation: to compute a cell at time $t+1$, recursively compute the nine cells in its closed neighborhood at time $t$, count the eight neighbors, and apply the Life rule. Memoization merges repeated subproblems.

Without memoization, the recursion tree has at most $9^t$ leaves, matching the theorem’s coarse bound. With memoization, the distinct subproblems are indexed by spacetime points in the cone and are far fewer. The sharper square geometry suggests roughly cubic work for computing all required layers up to time $t$, because layer $s$ contains on the order of $s^2$ spatial cells and

$$
\sum_{s=0}^{t}s^2
$$

grows on the order of $t^3$.

The distinction is useful. The exponential estimate is a simple, unconditional certificate for direct recursion. The geometry points toward better implementations and a stronger future theorem.

## Why finite cones matter for computation

Life is famous because small patterns can carry and transform information. But a genuine construction of computation needs more than appealing animations. One must specify where signals enter and leave, how long a component takes, what area it occupies, and why unrelated activity cannot corrupt it.

Finite dependency cones provide a language for such guarantees. If two components are separated far enough that their cones do not meet during a specified time interval, then neither can influence the other in that interval. A proposed gate can be tested against every allowed input while treating the outside world abstractly: only the finite cone reaching its output matters. A wire or delay element can be assigned a finite bounding box and latency. Larger systems can then be built by proving that the boxes and timing windows compose.

The path toward universality is therefore constructive. First establish symmetries and familiar patterns such as blocks, blinkers, and gliders. Then define signal ports and prove transport. Next verify logic gates, fanout, crossings, and delays. Compile finite Boolean circuits with explicit area and time bounds. Finally add memory and a clocked transition mechanism capable of simulating a universal machine.

The results here complete only the causal foundation of that program. They do not establish the existence of the required gadgets or a universal-machine simulation. Their value is more basic: they turn an infinite dynamical system into a controlled family of finite questions.

## The finite heart of an infinite world

Conway’s Life derives its fascination from the tension between microscopic simplicity and macroscopic surprise. Eight neighbors, two states, one synchronous rule—and from them emerge motion, persistence, collision, and computation-like behavior.

The finite simulation theorem reveals another side of that tension. Global evolution may be intricate, but local prediction has a sharply bounded past. After $t$ generations, a cell cannot know anything about the initial universe beyond its dependency cone. The infinite plane is real, but for this question and this time horizon, almost all of it is silent.

That is the mathematical beginning of modular engineering in Life: draw a causal boundary, count what lies inside it, and prove that everything outside can be ignored.