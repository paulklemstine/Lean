# The Domino Effect in Three-Regular Networks

## How a local coloring rule becomes a global uniqueness theorem

Imagine a network whose junctions each meet exactly three links. Some junctions have already been illuminated; the rest are dark. An illuminated junction may switch on a dark neighbor, but only when that neighbor is its **only** dark neighbor. Once switched on, the new junction can trigger another, and a small initial spark may sweep through the entire network.

This is the zero forcing process. It looks like a puzzle about colored dots, yet it captures something much broader: when local information determines a global state. The same “only one possibility remains” logic appears in constraint propagation, fault diagnosis, reconstruction of signals, and uniqueness questions for linear systems.

The networks of special interest here are finite, simple graphs. A graph consists of vertices joined by edges; “simple” means that there are no loops and no multiple edges. A graph is **cubic** when every vertex has degree $3$. It is **claw-free** when no four vertices induce a three-pronged star: there is no center joined to three pairwise nonadjacent leaves. In a cubic graph, claw-freeness forces a great deal of local clustering. The three neighbors of any vertex cannot all be mutually separated, so triangles and diamond-shaped units naturally emerge.

A **zero forcing set** is an initial colored set $S$ from which repeated legal forces eventually color every vertex. The least possible size of such a set is the **zero forcing number**, written $Z(G)$. Finding $Z(G)$ is a global optimization problem, but every legal move is radically local. The results below explain why this tension is productive.

## A clock that never runs backward

Suppose the current colored set is $S$. A legal force chooses a colored vertex $u$ with exactly one uncolored neighbor $w$, then replaces $S$ by $S\cup\{w\}$. The first basic theorem is deceptively simple.

**Strict Growth Theorem.** Every legal forcing move increases the number of colored vertices by exactly one:

$$
|S\cup\{w\}|=|S|+1.
$$

The reason is that legality requires $w\notin S$. This gives the process a built-in clock. If a forcing chain starts with $s$ colored vertices and ends with $t$ colored vertices, then it contains exactly $t-s$ nontrivial moves. On a graph with $n$ vertices, any successful chain from $S$ therefore has exactly $n-|S|$ moves.

There is also a monotonicity theorem.

**Monotonicity Theorem.** If a colored set $T$ can be reached from $S$ by legal forces, then $S\subseteq T$.

Nothing is ever uncolored. Consequently, forcing reachability is antisymmetric: if $T$ is reachable from $S$ and $S$ is reachable from $T$, then $S=T$. Thus the state graph of the process contains no directed cycles except stationary ones. The dynamics are irreversible, finite, and naturally ordered by inclusion.

This observation matters computationally. A program that simulates forcing never needs to revisit a smaller state. It can store a colored set, scan for a vertex with exactly one uncolored neighbor, add that neighbor, and continue. At most $n-|S|$ additions occur.

## Why triangles and diamonds act as relays

Claw-free cubic graphs are rich in small clustered units. Two propagation patterns are especially useful.

A **triangle** consists of three pairwise adjacent vertices. Suppose $a$ is colored, $b$ is not, and among all neighbors of $a$, the vertex $b$ is the only uncolored one. Then $a$ forces $b$. The triangular geometry is not magic by itself; what matters is that the remaining neighbors of $a$ have already been colored. The triangle packages that uniqueness condition into a common structural situation.

**Triangle Propagation Rule.** If $a$ is colored, $b$ is adjacent to $a$, $b$ is uncolored, and every uncolored neighbor of $a$ equals $b$, then one legal move colors $b$.

A **diamond** is the graph obtained from the complete graph on four vertices by deleting one edge. Its two degree-$3$ vertices form an internal spine, while its two degree-$2$ vertices are the tips. In a larger cubic network, the tips may carry external links. A forcing front can pass through such a unit in two stages.

**Diamond Propagation Rule.** Let $a$ already be colored. If $d$ is the unique uncolored neighbor of $a$, then $a$ forces $d$. If, after that first move, $b$ is the unique uncolored neighbor of $d$, then $d$ forces $b$. Hence the colored set grows from $S$ to $S\cup\{d,b\}$ in two legal steps.

These rules are certificates: they specify exactly what must be checked, including the status of external neighbors. They do not assume that the shape alone guarantees propagation. This precision is important. Local motifs become reliable relays only when the boundary conditions point the forcing front in the right direction.

One can now picture a claw-free cubic graph as a network of small transmission units. A global strategy plants seeds in selected units, then uses triangle and diamond relays to move a front across the graph. This is the mechanism behind sharper investigations of $Z(G)$ in structured families, including graphs whose contracted unit network has a Hamiltonian cycle. But local propagation alone does not establish every proposed sharp numerical bound: global conclusions require the corresponding decomposition and contraction hypotheses.

## The hidden linear equation

The most striking result appears when coloring is translated into algebra.

Choose a field $K$, such as the real or complex numbers. Assign a nonzero directed weight $A_{uv}\in K$ to every edge from $u$ to an adjacent vertex $v$. The weights need not be symmetric, positive, or equal. A function $x:V\to K$ is called **weighted harmonic** when, at every vertex $u$,

$$
\sum_{v\sim u} A_{uv}x(v)=0.
$$

This equation says that the weighted sum of the values around each vertex vanishes. It is a homogeneous linear system. Its solutions form a vector space, and the central question is whether values prescribed on a small set determine the solution everywhere.

Suppose $x$ vanishes on the currently colored set $S$, and $u\in S$ can force $w$. Every neighbor of $u$ other than $w$ is colored, so all its corresponding $x$-values are zero. The harmonic equation at $u$ collapses to

$$
A_{uw}x(w)=0.
$$

Because the edge weight $A_{uw}$ is nonzero and $K$ is a field, $x(w)=0$. The newly forced vertex must also lie in the zero set.

That one-line reduction is the bridge between a coloring game and linear uniqueness.

**One-Step Vanishing Theorem.** For nonzero edge weights, if a weighted harmonic function vanishes on a colored set, then it also vanishes after any legal force.

Applying the theorem repeatedly yields the chain version.

**Propagation of Zeros Theorem.** If $T$ is reachable from $S$ by finitely many legal forces and a weighted harmonic function vanishes on $S$, then it vanishes on all of $T$.

Finally, if $S$ is zero forcing, then $T$ can be the entire vertex set.

**Zero-Forcing Uniqueness Theorem.** On a finite graph with arbitrary nonzero directed edge weights over any field, every weighted harmonic function that vanishes on a zero forcing set is identically zero.

The theorem is robust. It uses neither cubicity nor claw-freeness, and it does not require symmetric weights. Those hypotheses matter for constructing efficient forcing sets in special graph families; once a forcing chain exists, the uniqueness argument is universal.

There is also an immediate dimension intuition. Restricting a harmonic function to a zero forcing set is injective: two harmonic functions agreeing there have a difference that vanishes there, hence vanishes everywhere. Therefore the space of harmonic functions can have dimension no greater than the number of vertices in any zero forcing set. This is why zero forcing is intertwined with matrix nullity.

## Coverage versus propagation

Zero forcing should not be confused with domination. A set $D$ is **dominating** if every vertex outside $D$ has a neighbor in $D$. Domination is a one-step coverage requirement; forcing is a sequential propagation requirement.

In a graph of maximum degree at most $3$, one chosen vertex covers at most itself and three neighbors. Therefore a dominating set obeys the counting bound

$$
|V|\le 4|D|,
$$

or equivalently $|D|\ge |V|/4$. This does not determine the zero forcing number, but it provides a useful comparison. Domination asks how cheaply the graph can be covered by closed neighborhoods. Zero forcing asks how cheaply a directional cascade can be initiated. On networks made of triangles and diamonds, comparing these local costs suggests a finite-state optimization problem: each unit has a coverage cost, a propagation cost, and boundary states describing how influence enters and exits.

## Parity from handshaking

Cubic graphs also carry a global arithmetic constraint. The handshaking identity says that the sum of all degrees equals twice the number of edges. If every vertex has degree $3$, then

$$
3|V|=2|E|.
$$

The right-hand side is even, so $|V|$ must be even.

**Cubic Parity Theorem.** Every finite cubic graph has an even number of vertices.

Now suppose the vertices are partitioned into $T$ triangle units of size $3$ and $D$ diamond units of size $4$. Then

$$
|V|=3T+4D.
$$

Since $|V|$ and $4D$ are even, $3T$ is even; because $3$ is odd, $T$ is even.

**Unit-Parity Theorem.** In any triangle–diamond partition of a finite cubic graph, the number of triangle units is even.

This small theorem has practical force. Any construction or enumeration that proposes an odd number of triangle units cannot represent a cubic graph of this kind. Parity acts as a fast consistency check before deeper forcing analysis begins.

## From a puzzle to an inference principle

The narrative now closes where it began: with one colored vertex facing one dark neighbor. Combinatorially, uniqueness of that neighbor makes the next move deterministic. Algebraically, it reduces a many-term equation to one nonzero coefficient times one unknown. The same local condition drives both processes.

That dual role points toward new questions. Can every failure of zero forcing be witnessed by a cleverly weighted nonzero harmonic function? Can triangle and diamond units be assigned finite boundary states so that optimal forcing and domination become tractable dynamic programs? How stable are forcing bounds when a cyclic contraction structure is damaged at a few units? Can edge weights be chosen so that the harmonic solution space is as large as the zero forcing number permits?

Whatever the answers, the established mechanism is clear. A legal force adds exactly one vertex; forcing chains are monotone and acyclic; triangles and diamonds provide explicit local relays; zeros of weighted harmonic functions travel along every forcing chain; zero forcing sets are universal uniqueness sets; cubic graphs satisfy strict parity constraints; and degree-three domination obeys a simple quarter-order lower bound.

A child’s coloring rule has become a theorem about information. Once every step leaves only one possible unknown, local certainty can cross an entire network.