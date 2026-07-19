# Chasing Certainty: How Backward Search Solves Cops and Robbers on a Graph

A robber is hiding somewhere in a network. A team of cops occupies its own collection of locations. Everyone knows where everyone else is. In each round, all cops move first; each may remain where they are or cross one edge. The robber sees that collective move and then may stay or cross one edge. If a cop ever occupies the robber’s vertex, the pursuit ends.

This spare game, known as Cops and Robbers, turns pursuit into mathematics. Its board can be a street map, a communication network, a maze, or any finite graph. Its tokens raise questions that also appear in robotics, surveillance, network defense, planning under adversarial uncertainty, and the analysis of reactive systems. The most famous question asks for the *cop number*: the smallest number of cops that can guarantee capture.

The central challenge is not merely to simulate plausible play. A successful decision method must account for every legal robber response. The robber is not random, and optimism is not a strategy. The decisive idea is to reason backward from capture, expanding a region of states from which the cops can force the game into territory already known to be winning.

This article develops that idea from first principles. It explains why the backward tables have an exact strategic meaning, why they only grow, what stabilization means, how a finite implementation matches the mathematics, and why capture-time ranks can serve as compact certificates of strategy.

## Turning a chase into states

Let $G=(V,E)$ be an undirected simple graph, and let $k$ be the number of cops. A state is a pair

$$
(c,r),
$$

where $c=(c_1,\dots,c_k)$ lists the cops’ vertices and $r$ is the robber’s vertex. A move from a vertex $u$ to a vertex $v$ is legal when either $u=v$ or $\{u,v\}\in E$. Thus every token may wait.

A simultaneous cops’ move from $c$ to $c'=(c'_1,\dots,c'_k)$ is legal when every individual move from $c_i$ to $c'_i$ is legal. A state is *captured* when $c_i=r$ for at least one $i$.

The order of play matters. From a current state $(c,r)$, the cops choose $c'$ without knowing the robber’s next location. Then the robber chooses a legal $r'$ after seeing $c'$. Consequently, the logical shape of a forced move is

$$
\text{there exists a cops’ move }c'\text{ such that for every robber reply }r',\text{ the result is safe for the cops.}
$$

The order “there exists, then for every” is the mathematical fingerprint of cops-first play. Reversing it would describe a different and unfair game in which the cops could react after seeing the robber’s move.

## Lighting the graph from the end backward

Imagine coloring game states rather than graph vertices. Initially, color every state in which capture has already occurred. Call this set $W_0$.

Now perform one backward update. Given any set $W$ of states already certified as winning, add a state $(c,r)$ if it is captured already, or if the cops can make a legal move to some $c'$ satisfying one of two conditions:

1. a cop lands immediately on $r$; or
2. for every legal robber move from $r$ to $r'$, the successor state $(c',r')$ lies in $W$.

Write this update as $F(W)$. The successive winning tables are

$$
W_0=\{(c,r):\text{some }c_i=r\},
\qquad
W_{n+1}=F(W_n).
$$

The picture is like a controlled flood moving backward through the state space. A state joins the flood when the cops possess a single move whose entire fan of robber replies lands inside the previous waterline.

This is not merely a suggestive heuristic. It has an exact meaning.

**Bounded-Horizon Characterization.** For every nonnegative integer $n$, a state belongs to $W_n$ if and only if the cops have a strategy that guarantees capture within at most $n$ rounds.

The proof follows the same recursive shape as the game. At horizon $0$, winning means capture has already happened, exactly as specified by $W_0$. Suppose the claim is known for horizon $n$. A state lies in $W_{n+1}$ precisely when it is captured or the cops have one legal first move that captures immediately or sends every robber reply into $W_n$. By the inductive assumption, every such reply can then be captured within $n$ more rounds. Conversely, any strategy that guarantees capture within $n+1$ rounds must begin with a legal cops’ move; unless that move captures immediately, each robber reply must leave a position that is winnable within the remaining $n$ rounds. That is exactly the condition for entry into $W_{n+1}$.

The table number therefore measures time, not just repeated computation. Each layer tells a strategic story.

## Why the tables never shrink

The backward operator is monotone: if $A\subseteq B$, then

$$
F(A)\subseteq F(B).
$$

Indeed, a cops’ move that sends every robber reply into $A$ also sends every reply into the larger set $B$. Immediate capture is unaffected.

It follows that

$$
W_0\subseteq W_1\subseteq W_2\subseteq\cdots.
$$

This increasing-chain theorem has an intuitive reading: allowing more time cannot destroy a winning strategy. It also supplies an important debugging principle. If a program ever removes a state from one iteration to the next, it is not implementing the backward rule described here.

The result handles subtle boundary cases cleanly. If $k=0$, there is no cop who can share the robber’s location. There is also no cops’ move that can create a capture. Hence every finite-horizon winning table is empty. The method does not conjure victory from the mechanics of iteration.

## What it means when the search stops

Suppose two successive tables agree:

$$
W_{n+1}=W_n.
$$

Since $W_{n+1}=F(W_n)$, this equality says exactly that

$$
F(W_n)=W_n.
$$

The table is a fixed point. Another update cannot reveal a new winning state.

There is also a useful minimality principle. Let $W$ be any set that contains all captured states and is closed under the update, meaning $F(W)\subseteq W$. Then, for every $n$,

$$
W_n\subseteq W.
$$

The proof is an induction. The base table lies in $W$ because $W$ contains every captured state. If $W_n\subseteq W$, monotonicity gives $F(W_n)\subseteq F(W)$, and closure gives $F(W)\subseteq W$. Therefore $W_{n+1}\subseteq W$.

So backward search does not inflate the answer arbitrarily. Every sound closed collection of winning states must contain every layer generated by the algorithm. On a finite graph, the full state space has

$$
|V|^{k+1}
$$

states when cops are treated as labeled: $|V|^k$ cop configurations and $|V|$ robber positions. An increasing sequence of subsets must eventually stabilize. The resulting table is thus the least fixed winning region generated from immediate capture.

## From mathematics to a finite table

For a finite graph, the procedure can be implemented directly. Enumerate all $|V|^{k+1}$ states. Mark captured states. Then repeatedly scan the universe. For each unmarked state, enumerate all simultaneous legal cops’ moves. A candidate move succeeds if it captures immediately or if every legal robber reply leads to a state marked in the preceding table. Add all successful states simultaneously and repeat until no state is added.

The simultaneity of each table update is important. A state admitted during the current scan should not be used as though it belonged to the preceding horizon; otherwise one pass could silently represent several rounds.

**Finite-Table Correctness.** At every iteration $n$, membership in the enumerated finite table is equivalent to the existence of a cops’ strategy guaranteeing capture within at most $n$ rounds.

This follows because the finite test uses the same membership condition as the abstract update. Induction over the iteration number then transfers the bounded-horizon characterization to the computed tables.

A straightforward implementation is expensive. There are $N=|V|^{k+1}$ states. If the maximum closed-neighborhood size is $\Delta+1$, a cop configuration can have as many as $(\Delta+1)^k$ simultaneous moves, and each such move may require checking up to $\Delta+1$ robber replies. A full scan therefore has a rough worst-case cost

$$
O\!\left(|V|^{k+1}(\Delta+1)^{k+1}\right),
$$

before accounting for repeated rounds. This is a clear specification-first baseline rather than the final word in performance. Precomputed neighborhoods, work queues, predecessor indexing, symmetry reduction, and compact bit sets can substantially reduce practical cost.

## Ranks that explain a winning strategy

The first table containing a state provides more than a yes-or-no answer. Define its rank by

$$
\rho(s)=\min\{n:s\in W_n\}.
$$

Rank $0$ means capture is already present. If $\rho(s)=n+1$, the update supplies a cops’ move that either captures immediately or sends every robber reply into a state of rank at most $n$. Thus ranks decrease along the chosen strategy, no matter how the robber responds.

This descending number is a certificate of progress. It prevents the strategy from wandering forever: natural numbers cannot decrease indefinitely. More generally, on any set $X$ equipped with a rank $\rho:X\to\mathbb{N}$, orient a move from $x$ to $y$ whenever $\rho(y)<\rho(x)$. The resulting relation is well founded and possesses a unique kernel: a unique set of positions that is internally independent and absorbs every position outside it by a directed move. In pursuit language, rank orientation converts cyclic play into an acyclic strategic skeleton.

## Small graphs, large lessons

Paths illustrate the backward wave vividly. With one cop on a finite path, the cop can steadily constrain the robber toward an endpoint; successive ranks encode the shrinking distance to forced capture. On a complete graph, one cop can move directly to the robber’s current vertex, so every state is won within one cops’ move. An edgeless graph behaves differently: nobody can change vertices, so only states captured initially are winning. A cycle exposes the need for enough pursuers: a lone cop cannot generally close both escape directions, while two cops can coordinate to trap the robber.

These examples are not separate tricks. They are all read by the same quantifier pattern and the same backward operator.

The broader lesson reaches beyond a board game. Many planning problems ask whether a controller can choose one action that survives every environmental response. Backward attractors are the natural language of such systems. Here, the chase makes that language visible: begin at success, pull the boundary backward through controlled choices, preserve the adversary’s universal freedom, and stop only at a fixed point.

The result is both conceptual and practical. The increasing tables are exact bounded-time strategy maps. Stabilization identifies a closed winning region. Finite enumeration realizes the same semantics. First-entry ranks explain how quickly victory can be forced and provide witnesses that can be checked locally. What begins as a robber fleeing through a graph becomes a general method for turning adversarial uncertainty into a finite, intelligible computation.
