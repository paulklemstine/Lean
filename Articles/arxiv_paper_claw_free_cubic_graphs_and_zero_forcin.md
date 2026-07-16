# The One-Way Geometry of Zero Forcing

## How a local coloring rule reveals global structure in networks

Imagine a network in which a few activated sites can awaken everything else. The rule is austere. A colored vertex may color one of its neighbors only when that neighbor is its **unique** uncolored neighbor. No vertex may choose among several candidates; a force occurs only when the next move is logically determined.

This is the zero-forcing process, a deceptively simple game played on a finite graph. Its central question is economical: how few vertices must be colored at the start to ensure that, after repeatedly applying the rule, every vertex becomes colored? The answer is the graph’s **zero forcing number**, written $Z(G)$.

The process belongs to a family of ideas that translate local certainty into global control. In a communication network, it models deterministic propagation when a node can resolve only one remaining unknown neighbor. In the study of sparse matrices, it is connected to how much freedom can remain in a system constrained by a graph. In monitoring and controllability problems, it suggests where sensors or actuators must be placed so that influence can spread without ambiguity.

The foundational results developed here explain why zero forcing has such a clean mathematical geometry. Colored sets grow in one direction, forcing certificates can be joined together, minimum certificates always exist on finite graphs, complete graphs demand almost total initial knowledge, and claw-free cubic graphs possess a local triangular structure that guarantees a universal upper bound.

## The rule, precisely

A finite simple graph $G$ consists of a finite vertex set $V$ and undirected edges joining distinct vertices, with no loops or repeated edges. Let $S\subseteq V$ be the currently colored set. A **legal force** from $u$ to $w$ may occur when all four conditions hold:

1. $u\in S$;
2. $w\notin S$;
3. $u$ and $w$ are adjacent;
4. every uncolored neighbor of $u$ is equal to $w$.

After the force, the new colored set is $S\cup\{w\}$. A **forcing sequence** is any finite succession of legal forces, including the empty sequence. A set $S$ is a **zero forcing set** if some forcing sequence beginning at $S$ ends at $V$. The zero forcing number is

$$
Z(G)=\min\bigl\{|S|:S\subseteq V\text{ is a zero forcing set}\bigr\}.
$$

This definition emphasizes certificates. To prove $Z(G)\le k$, it is enough to exhibit a set of at most $k$ vertices together with a legal sequence that colors the graph.

## Every move is irreversible progress

The first theorem captures the arithmetic of a single move.

**Single-Step Growth Theorem.** If a legal force changes $S$ into $T$, then $T=S\cup\{w\}$ for one vertex $w\notin S$. Consequently,

$$
|T|=|S|+1
\qquad\text{and}\qquad
S\subseteq T.
$$

The proof is immediate from the rule: exactly one previously uncolored vertex is inserted and nothing is removed. Yet this tiny fact governs the entire process.

By repeating it, one obtains the **Monotonicity Theorem**: if a forcing sequence carries $S$ to $T$, then $S\subseteq T$ and $|S|\le |T|$. The proof follows the sequence one step at a time. Inclusion is preserved transitively, and finite-set cardinality respects inclusion.

There is a useful rigidity consequence. If $S$ can force $T$ and $|S|=|T|$, then $S=T$. A proper inclusion of finite sets would strictly increase cardinality, so equal size rules out any genuine progress. Even more strikingly, forcing reachability is antisymmetric: if $S$ can force $T$ and $T$ can force $S$, then $S=T$. The process cannot contain a nontrivial directed cycle.

This makes the family of colored states resemble a landscape with a strict height function, namely cardinality. Every genuine force climbs by one level. A path can pause only by taking no move, and it can never return downhill. That observation is valuable computationally: a search for forcing sequences explores an acyclic state space ordered by set inclusion.

## Certificates can be spliced

Suppose a set $S$ can force an intermediate set $T$, and $T$ can force all of $V$. Then the two forcing sequences can simply be concatenated. This yields the **Certificate Composition Theorem**:

$$
S\leadsto T\quad\text{and}\quad T\leadsto V
\quad\Longrightarrow\quad
S\leadsto V.
$$

Thus $S$ is zero forcing whenever it can reach any already certified zero forcing set. This modularity matters in both proofs and algorithms. One may first establish a local propagation phase, stop at a strategically structured intermediate state, and then invoke a second certificate designed for that state.

Because the graph is finite, a minimum zero forcing set is not merely an infimum that might never be achieved. There are only finitely many subsets of $V$, the full set $V$ is trivially zero forcing, and therefore at least one zero forcing set has minimum cardinality. Hence the minimum defining $Z(G)$ is attained.

The same reasoning gives the **Certificate Upper-Bound Principle**: every explicit zero forcing set $S$ proves

$$
Z(G)\le |S|.
$$

This is the bridge from dynamics to extremal graph theory. Constructing a clever propagation certificate immediately becomes a numerical bound.

## A universal bound from one missing vertex

A remarkably broad certificate comes from coloring almost everything. Choose a vertex $w$ that has a neighbor $u$, and initially color every vertex except $w$. Then $u$ has exactly one uncolored neighbor, namely $w$, so it forces $w$ in one step.

**Co-singleton Theorem.** If $w$ has at least one neighbor, then $V\setminus\{w\}$ is a zero forcing set.

It follows that any finite graph without isolated vertices satisfies

$$
Z(G)\le |V|-1.
$$

The bound is elementary, but it is also sharp. Consider the complete graph $K_n$ with $n\ge 2$. Every pair of distinct vertices is adjacent. If two or more vertices are uncolored, then every colored vertex sees at least two uncolored neighbors and cannot force either one. Therefore a successful initial set must leave at most one vertex uncolored. Conversely, coloring $n-1$ vertices lets any colored vertex force the last one.

**Complete-Graph Theorem.** For $n\ge 2$,

$$
Z(K_n)=n-1.
$$

Complete connectivity is therefore not synonymous with easy propagation. Too many uncolored neighbors create ambiguity. Zero forcing rewards a specific kind of constrained connectivity: enough edges to transmit influence, but enough asymmetry to make the next target unique.

## Cubic graphs without claws

The most geometric part of the story concerns graphs that are simultaneously **cubic** and **claw-free**. A graph is cubic if every vertex has exactly three neighbors. A **claw** is an induced copy of the four-vertex star $K_{1,3}$: one central vertex adjacent to three leaves that are pairwise nonadjacent. A graph is claw-free if no vertex has three distinct neighbors that are pairwise nonadjacent.

These two conditions interact immediately. Take any vertex $v$ in a cubic graph. It has exactly three distinct neighbors, say $a$, $b$, and $c$. If none of $a$, $b$, and $c$ were adjacent to one another, then $v$ together with those neighbors would form a claw. Claw-freeness forbids this. At least one pair, perhaps $a$ and $b$, must be adjacent. The edges $va$, $vb$, and $ab$ then form a triangle through $v$.

**Local Triangle Theorem.** Every vertex of a claw-free cubic graph lies in a triangle.

The proof is only a few lines, but the conclusion is structural. A local prohibition against a three-pronged shape forces triangular clustering everywhere. Such graphs cannot look locally like trees. Each vertex belongs to a tightly knit three-cycle, and these cycles become natural units for deeper decompositions into triangles and diamond-shaped blocks.

The theorem also eliminates isolated vertices: a vertex lying in a triangle certainly has neighbors. Applying the co-singleton certificate gives the foundational extremal consequence.

**Claw-Free Cubic Bound.** If $G$ is a finite claw-free cubic graph with vertex set $V$, then

$$
Z(G)\le |V|-1.
$$

This bound does not yet exploit the full triangle-rich architecture, but it establishes a reliable baseline. It also illustrates a recurring pattern in combinatorics: a forbidden local configuration produces a positive local structure, which then supplies a global certificate.

## Seeing the process as an algorithm

A direct simulation maintains the colored set. At each stage it scans colored vertices, collects their uncolored neighbors, and performs a force whenever exactly one remains. If no force is available before all vertices are colored, the chosen set is not certified by that run. If all vertices become colored, the recorded ordered pairs form a checkable witness.

For a fixed deterministic scanning order, a straightforward implementation takes at most $|V|-|S|$ forces. With adjacency lists, each full scan costs on the order of the total number of incident edges, so the simplest implementation runs in roughly $O(|V||E|)$ time. More sophisticated queue-based updates can avoid rescanning unaffected vertices.

To find $Z(G)$ exactly, one may enumerate subsets in increasing size and test each candidate. This is exponential in $|V|$, as one should expect from a minimum-set problem, but monotonicity and certificate composition provide pruning opportunities. The state graph has no nontrivial cycles, and any intermediate state known to be zero forcing certifies every state that can reach it.

## From local certainty to global design

Zero forcing teaches an unusual lesson about influence. More edges do not always make propagation easier. In $K_n$, abundant connectivity creates choice, and choice blocks the rule. In claw-free cubic graphs, by contrast, limited degree and forced triangles organize neighborhoods into predictable local patterns.

The current theory rests on five pillars: every force adds exactly one vertex; forcing sequences are monotone and antisymmetric; certificates compose; minimum certificates exist and bound $Z(G)$; and claw-free cubic neighborhoods necessarily contain triangles. Together they provide both a mathematical foundation and an algorithmic language for studying how deterministic influence travels through a network.

The next frontier is to turn the local triangles into sharper global information. One expects triangle and diamond blocks, independence constraints, and Hamiltonian structure in suitable contractions to yield substantially improved bounds. The central challenge is beautifully concrete: understand how local clusters can be arranged so that a small initial spark is guaranteed to illuminate the entire graph.
