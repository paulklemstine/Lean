# Backward Attractors for Finite $k$-Copwin Recognition: Semantics, Fixed Points, and Executable Search

**Aristotle**  
**July 19, 2026**

## Abstract

We study finite-horizon recognition for the visible, perfect-information Cops and Robbers game on an undirected simple graph. A state consists of the positions of $k$ cops and one robber. During each round the cops move simultaneously, with waiting allowed, and the robber then moves after observing their choice. We define a backward attractor operator whose alternating quantifiers preserve this cops-first order. Starting from immediate-capture states, its iterates form increasing winning regions. We prove an exact iteration invariant: the $n$th region consists precisely of states from which the cops can force capture within at most $n$ rounds. We then establish monotonicity, conditional fixed-point stabilization, and a least-closed-region theorem. For finite graphs, exhaustive table updates agree at every iteration with the strategic semantics. First-entry ranks yield decreasing capture certificates and connect the construction with unique kernels of well-founded ranked move relations. We describe a direct recognition algorithm, its complexity, strategy extraction, numerical examples, and directions for symmetry reduction, quantitative stabilization, and structural compression.

## 1. Introduction

Cops and Robbers is a pursuit–evasion game on a graph. Its elementary rules encode a general problem in adversarial planning: can a controller select an action that succeeds against every response available to an opponent? The game’s principal graph parameter is the *cop number*, the least number of cops sufficient to guarantee eventual capture of a robber. This paper concentrates on the decision mechanism beneath finite $k$-copwin recognition rather than on asymptotically optimized graph classes.

The central object is a backward attractor. Immediate-capture states are winning at horizon zero. A new state is declared winning at horizon $n+1$ when the cops possess one legal simultaneous move that either captures immediately or leaves every legal robber reply in the horizon-$n$ region. The order of quantifiers is essential: the cops commit first, and the robber sees their choice. This construction produces a sequence of finite-horizon tables with a precise semantic interpretation.

Our contributions are as follows.

1. We give a self-contained state-space semantics for simultaneous cops’ moves followed by a robber move, with waiting permitted for all players.
2. We prove monotonicity of the backward update and of the resulting sequence of winning regions.
3. We prove the bounded-horizon iteration invariant: table membership at stage $n$ is equivalent to forced capture in at most $n$ rounds.
4. We show that equality of two consecutive tables makes the current table a fixed point, and that every set containing capture states and closed under the update contains every finite-horizon region.
5. For finite graphs, we prove that exhaustive finite filtering implements the mathematical update exactly at every stage.
6. We explain how first-entry ranks provide strategy witnesses and how arbitrary natural-valued rank functions induce well-founded move relations with unique kernels.

The analysis distinguishes established results from prospective improvements. In particular, termination on finite state spaces follows immediately from monotonicity and finiteness, while sharper stabilization depths, optimal strategy ranks, cop-permutation quotients, and bounded-width compression invite further study.

## 2. Game model

### 2.1 Graphs and legal movement

Let $G=(V,E)$ be an undirected simple graph. For vertices $u,v\in V$, define the reflexive movement relation

$$
u\rightsquigarrow_G v
$$

by the condition that either $u=v$ or $\{u,v\}\in E$. Thus a player may stay at its current vertex or traverse one edge.

Fix $k\in\mathbb{N}$. A cops’ configuration is a function $c:\{1,\dots,k\}\to V$, equivalently an ordered tuple

$$
c=(c_1,\dots,c_k)\in V^k.
$$

The order labels the cops for state enumeration; the rules themselves are invariant under relabeling. A complete game state is

$$
s=(c,r)\in V^k\times V,
$$

where $r$ is the robber’s location.

A simultaneous transition from $c$ to $c'$ is a legal cops’ move when

$$
c_i\rightsquigarrow_G c'_i
\qquad\text{for every }i\in\{1,\dots,k\}.
$$

A robber move from $r$ to $r'$ is legal when $r\rightsquigarrow_G r'$.

### 2.2 Capture and round order

A state $(c,r)$ is *captured* if

$$
\exists i\in\{1,\dots,k\},\qquad c_i=r.
$$

In one round, the cops first choose a legal simultaneous configuration $c'$. If some $c'_i=r$, capture occurs immediately, before any robber move. Otherwise the robber observes $c'$ and chooses a legal destination $r'$. This temporal order induces the logical pattern

$$
\exists c'\;\forall r'.
$$

It is not interchangeable with $\forall r'\;\exists c'$. The latter would permit the cops to choose a response after learning the robber’s destination and would therefore model a different game.

### 2.3 Bounded-horizon capturability

We define capturability recursively. A state is *capturable within zero rounds* exactly when it is already captured. A state $(c,r)$ is *capturable within $n+1$ rounds* when it is captured, or there exists a legal cops’ move $c'$ such that either capture is immediate or every legal robber destination $r'$ produces a state $(c',r')$ capturable within $n$ rounds.

In symbols, writing $C_n(c,r)$ for this property,

$$
C_0(c,r)\iff \exists i,\quad c_i=r,
$$

and

$$
\begin{aligned}
C_{n+1}(c,r)\iff {}& C_0(c,r)\\
&\lor\;\exists c'\in V^k\;\Bigl[
  (\forall i,\quad c_i\rightsquigarrow_G c'_i)\\
&\hspace{37mm}\land\bigl((\exists i,\quad c'_i=r)
  \lor (\forall r',\quad r\rightsquigarrow_G r'\Rightarrow C_n(c',r'))\bigr)
\Bigr].
\end{aligned}
$$

This definition includes strategies rather than merely paths. The universal robber clause ensures robustness against adversarial play.

## 3. The backward attractor

### 3.1 One-step update

For a set $W\subseteq V^k\times V$, define its one-step backward update $F_G(W)$ by declaring $(c,r)\in F_G(W)$ precisely when $(c,r)$ is captured or there exists a legal cops’ move $c'$ for which either some cop lands on $r$ or every legal robber reply $r'$ satisfies $(c',r')\in W$.

Equivalently,

$$
\begin{aligned}
(c,r)\in F_G(W)\iff {}& (\exists i,\quad c_i=r)\\
&\lor\;\exists c'\;\Bigl[(\forall i,\quad c_i\rightsquigarrow_G c'_i)\\
&\hspace{28mm}\land\bigl((\exists i,\quad c'_i=r)
\lor(\forall r',\quad r\rightsquigarrow_G r'\Rightarrow(c',r')\in W)\bigr)\Bigr].
\end{aligned}
$$

The explicit immediate-capture disjunct after the cops move is important. Once a cop lands on the robber’s current vertex, the robber does not receive an escape move.

### 3.2 Winning regions

Define the initial region and its iterates by

$$
W_0=\{(c,r):\exists i,\quad c_i=r\},
\qquad
W_{n+1}=F_G(W_n).
$$

These sets are called the bounded-horizon winning regions. Their meaning is established in Section 4.

## 4. Main results

### 4.1 Monotonicity

**Theorem 1 (Monotonicity of the backward update).** If $A\subseteq B$, then

$$
F_G(A)\subseteq F_G(B).
$$

**Proof sketch.** Consider a state in $F_G(A)$. If it is already captured, it also lies in $F_G(B)$. Otherwise, retain the witnessing cops’ move. Immediate capture remains immediate. In the remaining case every legal robber reply belongs to $A$; since $A\subseteq B$, every reply also belongs to $B$. The same cops’ move therefore witnesses membership in $F_G(B)$. $\square$

Monotonicity is the central order-theoretic property of the construction. It says that strengthening the collection of certified successors cannot invalidate a forcing move.

**Theorem 2 (Increasing winning regions).** For every $n\in\mathbb{N}$,

$$
W_n\subseteq W_{n+1}.
$$

**Proof sketch.** At stage zero, every captured state is admitted by the capture disjunct at stage one. For the inductive step, suppose $W_n\subseteq W_{n+1}$. Since $W_{n+1}=F_G(W_n)$ and $W_{n+2}=F_G(W_{n+1})$, Theorem 1 gives $W_{n+1}\subseteq W_{n+2}$. $\square$

Strategically, additional time cannot turn a winning state into a losing one.

### 4.2 Exact horizon semantics

**Theorem 3 (Bounded-Horizon Characterization).** For every state $s$ and every $n\in\mathbb{N}$,

$$
s\in W_n\iff s\text{ is capturable within at most }n\text{ rounds}.
$$

**Proof sketch.** Proceed by induction on $n$. At $n=0$, both sides mean immediate capture. Assume the equivalence at horizon $n$. Expanding the definition of $W_{n+1}=F_G(W_n)$ yields two possibilities: capture already holds, or the cops have a legal first move that captures at once or sends every legal robber reply into $W_n$. By the inductive hypothesis, membership in $W_n$ is equivalent to capture within $n$ additional rounds, proving the forward implication. Conversely, a strategy guaranteeing capture within $n+1$ rounds has a first cops’ move. If it does not capture immediately, every legal robber reply must be capturable within the remaining $n$ rounds; otherwise the robber could select a defeating reply. By induction all those successors lie in $W_n$, so the original state lies in $F_G(W_n)=W_{n+1}$. $\square$

This theorem is the principal correctness invariant. Iteration number is not an implementation artifact: it is a strategic time bound.

### 4.3 Stabilization and least closed regions

**Theorem 4 (Stabilization implies a fixed point).** If

$$
W_{n+1}=W_n,
$$

then

$$
F_G(W_n)=W_n.
$$

**Proof sketch.** By definition $W_{n+1}=F_G(W_n)$. Substitute this identity into the assumed equality. $\square$

**Theorem 5 (Least-Closed-Region Principle).** Let $W\subseteq V^k\times V$ satisfy both:

1. every captured state belongs to $W$; and
2. $F_G(W)\subseteq W$.

Then, for every $n\in\mathbb{N}$,

$$
W_n\subseteq W.
$$

**Proof sketch.** Induct on $n$. The base case follows from the first assumption because $W_0$ is exactly the capture set. If $W_n\subseteq W$, monotonicity gives

$$
W_{n+1}=F_G(W_n)\subseteq F_G(W).
$$

The closure assumption then yields $W_{n+1}\subseteq W$. $\square$

The theorem says that the generated regions are unavoidable: every candidate winning set that contains capture and is closed under one-step forcing must contain all finite-horizon wins.

For finite $V$, the state space $S=V^k\times V$ has cardinality

$$
|S|=|V|^{k+1}.
$$

Because the $W_n$ form an increasing chain of subsets of $S$, stabilization occurs after finitely many strict inclusions. A crude counting argument gives at most $|S|$ strict additions if each nonstable stage adds at least one state. At stabilization, Theorems 4 and 5 identify the result as the least fixed region generated from capture under the backward rule.

### 4.4 The zero-cop boundary

**Proposition 6 (No finite-horizon capture without cops).** If $k=0$, no state is capturable within any finite number of rounds.

**Proof sketch.** There is no index $i$ witnessing capture. The unique empty cops’ configuration cannot place a cop on the robber. Inductively, the robber may stay at its current vertex, and the resulting state remains uncaptured. Therefore the universal forcing condition cannot create a winning state at any finite horizon. $\square$

This boundary result confirms that the recursion does not manufacture a victory when the game lacks a capturing agent.

## 5. Finite exhaustive implementation

Assume that $V$ is finite and graph adjacency is decidable. The abstract sets can then be represented as finite tables. Let $S=V^k\times V$ be explicitly enumerable.

### Algorithm 1: Bounded-horizon backward table

**Input:** A finite graph $G=(V,E)$, a cop count $k$, and a horizon $h$.  
**Output:** Tables $T_0,\dots,T_h$.

1. Enumerate all states in $S$.
2. Set $T_0$ to the states in which a cop shares the robber’s vertex.
3. For $n=0,dots,h-1$, scan every state $s=(c,r)$.
4. Retain captured states.
5. For each uncaptured state, enumerate legal simultaneous cops’ moves $c'$.
6. Admit the state if one candidate $c'$ captures at once or if every legal robber reply $r'$ satisfies $(c',r')\in T_n$.
7. Store all admissions simultaneously as $T_{n+1}$.

The simultaneous update prevents newly admitted states from being used at the wrong horizon.

**Theorem 7 (Finite-Table Correctness).** For every finite graph, state $s$, and horizon $n$,

$$
s\in T_n\iff s\text{ is capturable within at most }n\text{ rounds}.
$$

**Proof sketch.** At stage zero, finite filtering selects exactly captured states. At each successor stage, the finite membership test is identical to the defining formula for $F_G$. Induction identifies $T_n$ with $W_n$, after which Theorem 3 gives the strategic interpretation. $\square$

Thus exhaustive iteration is not an approximation: at every finite horizon it computes precisely the intended game semantics.

### Algorithm 2: Fixed-point recognition and strategy extraction

To recognize eventual finite-horizon wins, repeat the update until $T_{n+1}=T_n$. Whenever a state first enters at stage $n+1$, record a witnessing cops’ move. For any chosen initial cop configuration $c$, the cops win against every robber start exactly when

$$
(c,r)\in T_n\qquad\text{for every }r\in V
$$

at the stabilized table. The graph is $k$-copwin under the chosen initial-placement convention if some $c\in V^k$ has this property.

For a newly admitted state, the stored move either captures or makes every robber reply land in an earlier table. Repeating stored witnesses therefore defines a positional strategy accompanied by a decreasing stage number.

## 6. Complexity

Let $q=|V|$, and let $d$ be the maximum size of a closed neighborhood, so $d\le q$ and $d=\Delta+1$ when the maximum graph degree is $\Delta$. There are

$$
N=q^{k+1}
$$

labeled states. A state has at most $d^k$ simultaneous cops’ moves, and testing a move examines at most $d$ robber replies. With constant-time table lookup, one exhaustive update costs

$$
O(Nd^{k+1})=O\!\left(q^{k+1}d^{k+1}\right).
$$

A naive stabilization loop can execute at most $N$ strict updates, yielding the coarse bound

$$
O(N^2d^{k+1}).
$$

Memory for a Boolean table is $O(N)$, while explicit storage of all tables costs up to $O(N^2)$ in the worst case. In practice one needs only the current table, the next table, first-entry ranks, and selected witnesses.

Several improvements preserve the semantics while reducing cost:

- precompute closed neighborhoods;
- represent tables as bit sets;
- index predecessor states so that only affected states are reconsidered;
- short-circuit candidate moves upon finding a losing robber reply;
- quotient configurations by permutations of indistinguishable cops;
- exploit graph automorphisms or structural decompositions.

The exponential dependence on $k$ is explicit in the state space and simultaneous-move enumeration. The direct algorithm is therefore most suitable for small fixed $k$, moderate graphs, testing, and serving as a reference specification for optimized implementations.

## 7. Capture ranks and well-founded kernels

For any state that appears in some winning table, define its first-entry rank

$$
\rho(s)=\min\{n\in\mathbb{N}:s\in W_n\}.
$$

If $\rho(s)=0$, the state is captured. If $\rho(s)=n+1$, the proof of admission supplies a cops’ move such that capture is immediate or every robber successor lies in $W_n$. Minimality then implies each noncaptured successor has rank at most $n$, hence strictly less than $\rho(s)$.

This makes $\rho$ a termination certificate for the extracted strategy: every complete round consistent with the witness decreases a natural number. The rank bounds worst-case remaining capture time, and the bounded-horizon characterization strongly motivates the sharper claim that least rank equals optimal worst-case capture time.

The rank idea has an independent relational consequence. Let $X$ be any set and let $\rho:X\to\mathbb{N}$. Define a directed relation by

$$
x\to y\iff \rho(y)<\rho(x).
$$

A *kernel* of this directed relation is a set $P\subseteq X$ satisfying:

1. **independence:** no two elements of $P$ are connected by the relation; and
2. **absorption:** every $x\notin P$ has a relation edge to some $y\in P$.

**Theorem 8 (Unique Kernel for Natural-Rank Relations).** For every set $X$ and every rank function $\rho:X\to\mathbb{N}$, the relation $x\to y$ defined by strict rank decrease has a unique kernel.

**Proof sketch.** Strict decrease in $\mathbb{N}$ is well founded: no infinite descending rank sequence exists. Well-founded recursion classifies a position according to whether it has a successor already classified into the kernel. The recursive construction enforces independence and absorption. Well-founded induction also proves uniqueness, since the classification at a rank depends only on lower-ranked positions, whose membership is already uniquely determined. $\square$

For pursuit games, this theorem explains how capture ranks strip cyclic behavior from a winning strategy graph. It also suggests a dual description in which backward attractors encode winning positions while kernels organize losing or terminally stable positions in a ranked orientation.

## 8. Numerical examples

The following examples use the exact backward update.

### 8.1 A path on five vertices

For one cop on the path $P_5$, there are $5^2=25$ states. The table sizes are

$$
5,\quad 13,\quad 15,\quad 19,\quad 25.
$$

All states eventually enter. The successive layers reflect the cop’s ability to reduce the robber’s room until an endpoint blocks further escape. A winning initial cop placement therefore exists.

### 8.2 A five-cycle

For one cop on $C_5$, the table sizes are

$$
5,\quad 15,
$$

followed by stabilization. No fixed initial cop placement wins against every robber start. With two cops, the state space has $5^3=125$ labeled states, and the sizes are

$$
45,\quad 105,\quad 125.
$$

Two cops can therefore force capture from every state within the displayed horizon.

### 8.3 Complete and edgeless graphs

For one cop on $K_5$, the tables have sizes $5$ and $25$: from every uncaptured state the cop moves directly to the robber’s current vertex. For one cop on the edgeless graph with five vertices, the table remains of size $5$. Since no token can move to a different vertex, only immediate-capture states are winning.

These cases test distinct mechanisms: gradual confinement, cyclic evasion, coordinated pursuit, immediate capture, and total immobility.

## 9. Applications and implementation guidance

Backward attractors appear wherever a controller acts before an adversarial environment: reactive synthesis, safety games, network interdiction, robot motion under uncertainty, and protocol recovery. The present model isolates several reusable lessons.

First, quantifier order should be made explicit before coding. A loop nesting that searches separately for a cops’ response to each robber move can accidentally implement $\forall r'\exists c'$ rather than $\exists c'\forall r'$. Second, table updates should be synchronous when iteration number represents time. Third, monotonicity and rank decrease provide strong internal checks. Fourth, storing a witness move transforms a recognizer into a strategy generator. Finally, boundary cases such as $k=0$, isolated vertices, and empty graphs should be part of a test suite because they reveal hidden assumptions.

The finite-table theorem also enables modular optimization. Any data structure or work-list algorithm is correct if its resulting membership test agrees with the same one-step predicate. This separates semantic correctness from engineering choices such as bit packing, parallel scans, caching, or symmetry handling.

## 10. Discussion and limitations

The theory provides exact finite-horizon semantics and a sound fixed-point pipeline. It does not, by itself, establish a sharp stabilization bound for particular graph families, prove that cop-permutation quotienting preserves all extracted metadata, or characterize the least rank as an optimal minimax capture time. These statements are plausible extensions but require separate arguments.

The state representation labels cops. Since capture and movement are invariant under permutations, many labeled states describe the same physical configuration. This redundancy can be substantial: $q^k$ ordered configurations may be replaced by the number

$$
\binom{q+k-1}{k}
$$

of multisets if quotient transitions and witnesses are handled correctly. Similarly, the direct method ignores graph structure such as treewidth, separators, and automorphism groups.

The kernel theorem is deliberately general. Its ranked relation is acyclic by construction; connecting its unique kernel exactly to the complement of a pursuit attractor requires a turn-explicit game graph and careful treatment of losing cycles. The present result supplies the well-founded component of that bridge without claiming the full duality.

## 11. Future work

Five directions follow naturally.

1. **Symmetry-reduced backward search.** Prove that quotienting by cop permutations preserves every finite-horizon and stabilized winning region, and measure the reduction from ordered tuples to multisets.
2. **Certified stabilization bounds.** Turn the finite-chain argument into explicit bounds in $q$ and $k$, and identify graph families with large stabilization depth.
3. **Optimal capture-time certificates.** Prove that first-entry rank equals the minimum worst-case capture time and use witnesses to emit independently checkable strategies.
4. **Kernel–attractor duality.** Enrich positions with turn information and relate the complement of the winning attractor to the kernel of a strictly rank-decreasing strategy graph.
5. **Bounded-width compression.** Seek linear-size representations for fixed $k$ on graph classes of bounded treewidth, with constants depending on width and cop count.

## 12. Conclusion

Backward search gives a transparent foundation for $k$-copwin recognition. The one-step operator exactly mirrors cops-first play: one cops’ move must survive every robber reply. Its iterates are monotone, and the $n$th table has the exact meaning of capture within $n$ rounds. Stabilization yields a fixed point, while the least-closed-region theorem prevents overstatement of the winning set. On finite graphs, exhaustive filtering computes the same regions at every stage. First-entry ranks add explanatory power by encoding progress and supporting strategy extraction.

The resulting pipeline is simple enough to implement directly and strong enough to serve as the semantic reference for optimized algorithms. It turns a pursuit game into an increasing sequence of certificates: begin with capture, reason backward through adversarial choices, and stop when no new forced victory can be found.
