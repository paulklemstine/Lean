# Local Propagation and Weighted Harmonic Uniqueness in Claw-Free Cubic Graphs

**Aristotle**  
**July 16, 2026**

## Abstract

Zero forcing is a monotone coloring process on a graph: a colored vertex with exactly one uncolored neighbor colors that neighbor. This paper develops the local and algebraic mechanisms that make the process useful in claw-free cubic graphs. We prove that every force increases the colored cardinality by one, that reachability is monotone and antisymmetric, and that triangle and diamond units admit explicit propagation certificates. We then establish a field-independent weighted harmonic uniqueness theorem. Given arbitrary nonzero directed edge weights, a weighted harmonic function that vanishes on a zero forcing set must vanish identically. The proof identifies the exact common mechanism behind combinatorial forcing and linear uniqueness: at a forcing vertex, all terms but one in the neighbor equation vanish. We also derive two complementary structural constraints. Every dominating set in a graph of maximum degree at most three has size at least one quarter of the graph order, and every finite cubic graph has even order; consequently, any partition into three-vertex triangle units and four-vertex diamond units contains an even number of triangle units. Algorithms and numerical examples illustrate forcing simulation, harmonic propagation, and unit-based consistency checks. The results isolate reusable foundations for sharper extremal bounds under additional decomposition and contraction hypotheses.

## 1. Introduction

Let $G=(V,E)$ be a finite simple graph. Begin with a set $S\subseteq V$ of colored vertices. The color-change rule permits a colored vertex $u$ to color an uncolored neighbor $w$ when $w$ is the only uncolored neighbor of $u$. Iterating this rule gives the **zero forcing process**. If some sequence of legal moves colors all vertices, then $S$ is a **zero forcing set**. The least cardinality of a zero forcing set is the **zero forcing number** $Z(G)$.

The definition combines local determinism with global optimization. Legality of one move is checked in a single neighborhood, while determining $Z(G)$ asks for the smallest seed set capable of controlling the whole graph. This local-to-global character is especially visible in **cubic graphs**, where every vertex has degree $3$, and in **claw-free graphs**, which have no induced copy of the star $K_{1,3}$. In a claw-free cubic graph, the neighborhood of a vertex cannot consist of three pairwise nonadjacent vertices. Local clustering is therefore unavoidable, and triangles and diamonds become natural propagation units.

A second interpretation comes from linear algebra. Assign a nonzero weight to every directed incidence of an edge and impose, at each vertex, a homogeneous weighted neighbor-sum equation. If a solution vanishes on the colored set and a legal force occurs, all but one term of the equation at the forcing vertex vanish. The remaining nonzero coefficient forces the final value to vanish. Thus a forcing chain is simultaneously a combinatorial propagation certificate and a certificate of uniqueness for an entire family of linear systems.

This paper gives a self-contained account of that mechanism. It deliberately separates conclusions that follow from the local rule alone from sharper numerical statements that require global structural hypotheses. Claw-freeness and cubicity motivate triangle–diamond decompositions, but they do not by themselves imply every sharp bound associated with a Hamiltonian contraction network. Our statements are therefore made at their exact hypotheses.

The main contributions are:

1. strict one-vertex growth, monotonicity, and antisymmetry of forcing reachability;
2. exact triangle and diamond propagation rules, including boundary conditions;
3. preservation of the zero set of a weighted harmonic function under one move and under an arbitrary forcing sequence;
4. a universal uniqueness theorem for weighted harmonic functions on zero forcing sets;
5. the domination bound $|V|\le 4|D|$ for maximum degree at most $3$;
6. even order of finite cubic graphs and evenness of the number of triangle units in every triangle–diamond partition.

## 2. Definitions and basic framework

### 2.1 Graphs and local structure

A **finite simple graph** $G=(V,E)$ has a finite vertex set $V$, no loops, and no parallel edges. Vertices $u$ and $v$ are adjacent, written $u\sim v$, when $\{u,v\}\in E$. The open neighborhood of $u$ is

$$
N(u)=\{v\in V:v\sim u\},
$$

and the degree is $\deg(u)=|N(u)|$. The maximum degree is $\Delta(G)=\max_{u\in V}\deg(u)$.

A graph is **cubic** if $\deg(u)=3$ for every $u\in V$. It is **claw-free** if it contains no induced subgraph isomorphic to $K_{1,3}$. Equivalently, no vertex has three neighbors that are pairwise nonadjacent.

A **triangle** is a set of three pairwise adjacent vertices. A **diamond** is a copy of $K_4$ with one edge removed. It has two vertices of degree $3$ within the unit and two tips of degree $2$ within the unit. When embedded in a cubic graph, each tip may have one edge leaving the unit.

### 2.2 Forcing states and reachability

A **coloring state** is a subset $S\subseteq V$. A **legal force** from $S$ is an ordered pair $u\to w$ such that

1. $u\in S$;
2. $w\notin S$;
3. $u\sim w$; and
4. for every $z\sim u$, if $z\notin S$, then $z=w$.

The resulting state is $S'=S\cup\{w\}$. We write $S\leadsto S'$ for one legal move. A **forcing sequence** from $S$ to $T$ is a finite chain

$$
S=S_0\leadsto S_1\leadsto\cdots\leadsto S_m=T,
$$

where chains of length zero are allowed. We say that $T$ is **reachable** from $S$. A set $S$ is **zero forcing** if $V$ is reachable from $S$.

The definition is existential: when several legal forces are available, any valid ordering suffices. The results below apply to every legal ordering.

### 2.3 Domination

A set $D\subseteq V$ is a **dominating set** if every vertex lies in $D$ or is adjacent to a vertex in $D$. Equivalently,

$$
V=\bigcup_{u\in D}\bigl(N(u)\cup\{u\}\bigr).
$$

The minimum cardinality of a dominating set is the domination number $\gamma(G)$. Domination concerns static coverage, whereas zero forcing concerns sequential propagation.

### 2.4 Weighted harmonic functions

Let $K$ be a field. For each ordered adjacent pair $(u,v)$ choose a directed edge weight $A_{uv}\in K$. No symmetry condition $A_{uv}=A_{vu}$ is imposed. The weighting is **nondegenerate on edges** if

$$
A_{uv}\ne 0\qquad\text{whenever }u\sim v.
$$

A function $x:V\to K$ is **weighted harmonic** with respect to $A$ if, for every $u\in V$,

$$
\sum_{v\in N(u)} A_{uv}x(v)=0.
$$

This differs in presentation from the usual Laplacian mean-value equation because the value $x(u)$ need not appear. It is the kernel equation of the weighted adjacency-type matrix $M_A$ defined by $(M_A)_{uv}=A_{uv}$ on edges and $0$ off edges.

## 3. Order structure of the forcing process

We first record the elementary facts that make forcing a finite irreversible dynamics.

### Theorem 3.1 (Strict growth under a legal force)

If $S\leadsto T$, then

$$
|T|=|S|+1.
$$

#### Proof sketch

By definition, $T=S\cup\{w\}$ for a vertex $w\notin S$. Adjoining one new element increases finite cardinality by exactly one. No other vertex changes status. $\square$

### Corollary 3.2 (Length of a forcing sequence)

If a forcing sequence from $S$ to $T$ has $m$ legal moves, then

$$
|T|=|S|+m.
$$

In particular, every successful forcing sequence from $S$ has exactly $|V|-|S|$ moves.

#### Proof sketch

Apply Theorem 3.1 at each step and telescope the cardinality increments. $\square$

### Theorem 3.3 (Monotonicity)

If $T$ is reachable from $S$, then $S\subseteq T$.

#### Proof sketch

A one-step transition replaces a set by a superset obtained through insertion of one vertex. Inclusion is transitive, so induction on the length of the forcing sequence proves the claim. $\square$

### Corollary 3.4 (Antisymmetry of reachability)

If $T$ is reachable from $S$ and $S$ is reachable from $T$, then $S=T$.

#### Proof sketch

The two reachability assumptions give $S\subseteq T$ and $T\subseteq S$ by Theorem 3.3. Set extensionality gives equality. $\square$

Thus reachability defines a partial order on coloring states after identifying the reflexive and transitive relation generated by legal moves. More concretely, every nontrivial edge in the state-transition graph points from cardinality $k$ to cardinality $k+1$. Directed cycles are impossible.

## 4. Local propagation certificates

The forcing rule is meaningful only when all boundary conditions are explicit. A triangle or diamond does not automatically propagate color; its surrounding vertices must put the relevant forcing vertex in a unique-uncolored-neighbor state.

### Theorem 4.1 (Triangle propagation rule)

Let $S$ be a colored set and let $a,b\in V$. Suppose

1. $a\in S$;
2. $b\notin S$;
3. $a\sim b$; and
4. every uncolored neighbor of $a$ is equal to $b$.

Then $S\leadsto S\cup\{b\}$, so $S\cup\{b\}$ is reachable from $S$ in one move.

#### Proof sketch

The four assumptions are exactly the color-change rule with forcing vertex $a$ and target $b$. $\square$

When $a$ and $b$ lie in a triangle, the third vertex often supplies one already-colored neighbor, while the external status of the remaining neighbor determines whether the force is legal. The theorem intentionally states the uniqueness hypothesis rather than hiding it in a drawing.

### Theorem 4.2 (Diamond propagation rule)

Let $S$ be colored and let $a,d,b\in V$. Suppose

1. $a\in S$ and $d\notin S$;
2. $d$ is the unique uncolored neighbor of $a$;
3. after coloring $d$, the vertex $b$ remains uncolored;
4. $d\sim b$; and
5. in the state $S\cup\{d\}$, the vertex $b$ is the unique uncolored neighbor of $d$.

Then $S\cup\{d,b\}$ is reachable from $S$ by two legal moves.

#### Proof sketch

First apply Theorem 4.1 in its underlying one-step form to obtain $a\to d$, reaching $S\cup\{d\}$. The final two assumptions then permit $d\to b$, reaching $S\cup\{d,b\}$. $\square$

The theorem models passage through a diamond spine. It is compositional: once the first move has changed the state, the second uniqueness condition is evaluated in that new state. This makes the rule suitable for chaining units in a larger graph.

## 5. Weighted harmonic propagation

The central bridge rests on the same uniqueness condition as the color-change rule.

### Lemma 5.1 (One-step preservation of vanishing)

Let $K$ be a field, let all directed edge weights $A_{uv}$ be nonzero, and let $x:V\to K$ be weighted harmonic. Suppose $x(v)=0$ for every $v\in S$. If $S\leadsto T$, then $x(v)=0$ for every $v\in T$.

#### Proof sketch

Write the legal move as $u\to w$, so $T=S\cup\{w\}$. Values on $S$ remain zero, and it remains to prove $x(w)=0$. Harmonicity at $u$ gives

$$
0=\sum_{v\in N(u)}A_{uv}x(v).
$$

Because $w$ is the unique uncolored neighbor of $u$, every $v\in N(u)$ with $v\ne w$ belongs to $S$, hence $x(v)=0$. The sum reduces to

$$
A_{uw}x(w)=0.
$$

Since $A_{uw}\ne 0$ and $K$ is a field, multiplication by $A_{uw}$ is injective, so $x(w)=0$. $\square$

The nonzero-weight hypothesis is necessary for this argument. If $A_{uw}=0$, the equation at $u$ contains no information about $x(w)$. No symmetry, ordering, topology, or positivity is used.

### Theorem 5.2 (Vanishing along a forcing sequence)

Under the hypotheses of Lemma 5.1, if $T$ is reachable from $S$ and $x$ vanishes on $S$, then $x$ vanishes on $T$.

#### Proof sketch

Induct on the length of a forcing sequence. The length-zero case is the hypothesis. At each successor step, apply Lemma 5.1 to the vanishing conclusion obtained at the preceding state. $\square$

### Theorem 5.3 (Zero-forcing weighted harmonic uniqueness)

Let $G$ be any finite simple graph, $K$ any field, and $A$ any assignment of nonzero directed weights to adjacent ordered pairs. If $S$ is a zero forcing set and $x:V\to K$ satisfies

$$
\sum_{v\in N(u)}A_{uv}x(v)=0
$$

for every $u\in V$, together with $x(v)=0$ for every $v\in S$, then $x$ is identically zero.

#### Proof sketch

Since $S$ is zero forcing, the entire vertex set $V$ is reachable from $S$. Apply Theorem 5.2 with $T=V$. $\square$

### Corollary 5.4 (Injective restriction)

Let $\mathcal H_A$ be the vector space of weighted harmonic functions for a fixed nonzero edge weighting $A$. If $S$ is zero forcing, then the restriction map

$$
\rho_S:\mathcal H_A\longrightarrow K^S,
\qquad x\longmapsto x|_S,
$$

is injective. Consequently,

$$
\dim_K\mathcal H_A\le |S|,
$$

and hence $\dim_K\mathcal H_A\le Z(G)$.

#### Proof sketch

If two harmonic functions have the same restriction to $S$, their difference is harmonic and vanishes on $S$. Theorem 5.3 makes that difference zero. The dimension inequality follows from injectivity into the $|S|$-dimensional space $K^S$. $\square$

This is the linear-algebraic significance of zero forcing. A forcing set is a sampling set on which harmonic data uniquely determine the global solution.

## 6. Domination and degree-three counting

Propagation and coverage give distinct graph parameters, but a simple counting argument provides a useful baseline.

### Theorem 6.1 (Domination bound in maximum degree three)

If $G$ is finite with $\Delta(G)\le 3$ and $D$ is a dominating set, then

$$
|V|\le 4|D|.
$$

Equivalently, $\gamma(G)\ge \lceil |V|/4\rceil$.

#### Proof sketch

For each $u\in D$, the closed neighborhood $N[u]=N(u)\cup\{u\}$ has at most $4$ vertices. Since $D$ dominates, these closed neighborhoods cover $V$. Therefore

$$
|V|=\left|\bigcup_{u\in D}N[u]\right|
\le \sum_{u\in D}|N[u]|
\le 4|D|.
$$

Overlaps can only improve the inequality. $\square$

The theorem does not compare $\gamma(G)$ and $Z(G)$ directly. It identifies the local cost of static coverage in degree three. Triangle–diamond decompositions offer a common coordinate system in which domination and forcing costs may eventually be compared unit by unit.

## 7. Parity in cubic unit decompositions

### Theorem 7.1 (Even order of cubic graphs)

Every finite cubic graph has an even number of vertices.

#### Proof sketch

The handshaking identity gives

$$
\sum_{v\in V}\deg(v)=2|E|.
$$

Cubicity turns the left side into $3|V|$. Hence $3|V|$ is even. Since $3$ is odd, $|V|$ is even. $\square$

### Theorem 7.2 (Even number of triangle units)

Suppose a finite cubic graph has a vertex partition into $T$ disjoint three-vertex units and $D$ disjoint four-vertex units. Then $T$ is even.

#### Proof sketch

The partition gives

$$
|V|=3T+4D.
$$

By Theorem 7.1, $|V|$ is even, and $4D$ is even. Thus $3T=|V|-4D$ is even. Since $3$ is odd, $T$ is even. $\square$

This parity result is independent of the internal edge pattern of the units; only cubicity and their sizes are used. For triangle–diamond decompositions it is a necessary consistency condition and explains why expressions involving $T/2$ are arithmetically meaningful.

## 8. Algorithms

### 8.1 Greedy forcing closure

Given adjacency lists and an initial set $S$, repeatedly find a colored vertex with exactly one uncolored neighbor and color that neighbor. Maintain for each colored vertex its current number of uncolored neighbors. With a queue of vertices whose count equals one, each edge needs only constant-many updates. The resulting time complexity is $O(|V|+|E|)$ and memory usage is $O(|V|+|E|)$.

The algorithm returns a forcing certificate when it colors all vertices. Failure of one deterministic tie-breaking order is not an obstruction here: applying any available legal force cannot destroy already-colored vertices, and a legal move only colors an additional vertex. The implementation can record ordered pairs $(u,w)$ and validate each against the state in which it occurs.

### 8.2 Harmonic-vanishing propagation

Given a forcing certificate and a set on which $x$ is known to vanish, process moves in order. For each $u\to w$, verify that $w$ is the unique uncolored neighbor of $u$, that $A_{uw}\ne0$, and that all other neighbor values have already been certified zero. The equation at $u$ then certifies $x(w)=0$. This symbolic procedure takes $O(m\Delta)$ for $m$ moves with straightforward adjacency scans, or $O(|V|+|E|)$ with maintained counts.

### 8.3 Exhaustive minimum zero forcing search

For small graphs, test subsets in nondecreasing cardinality. For each subset, run forcing closure. The first successful size is $Z(G)$. In the worst case this examines $2^{|V|}$ subsets, each with a polynomial closure computation, so it is exponential. Symmetry reduction, unit decomposition, integer programming, or dynamic programming on a contraction graph can reduce practical cost.

## 9. Numerical examples

### Example 9.1: A path

On the path $P_6$ with vertices $0,1,2,3,4,5$ and edges $i\sim i+1$, the singleton $S=\{0\}$ is zero forcing. The sequence is

$$
0\to1,\quad1\to2,\quad2\to3,\quad3\to4,\quad4\to5.
$$

There are $6-1=5$ moves, exactly as Corollary 3.2 predicts.

### Example 9.2: A triangle

In $K_3$, color two vertices. Either colored vertex has the third as its unique uncolored neighbor, so one force completes the graph. A single colored vertex cannot force because it has two uncolored neighbors. Thus $Z(K_3)=2$.

### Example 9.3: The complete graph on four vertices

In $K_4$, three initially colored vertices suffice, and fewer do not: with at most two colored vertices, every colored vertex has at least two uncolored neighbors. Hence $Z(K_4)=3$. This graph is cubic and claw-free.

### Example 9.4: Weighted propagation on a path

Give every directed edge of $P_6$ weight $1$. Harmonicity says that endpoint equations are $x(1)=0$ and $x(4)=0$, while internal equations have the form $x(i-1)+x(i+1)=0$. If $x(0)=0$, the forcing chain from $0$ certifies successively that every value is zero. The argument remains valid if each directed edge receives any nonzero real, rational, complex, or finite-field weight.

### Example 9.5: Unit parity

A proposed cubic unit network with $T=4$ triangle units and $D=3$ diamond units has

$$
|V|=3\cdot4+4\cdot3=24,
$$

which satisfies the parity condition. A proposal with $T=3$ and $D=3$ would have $21$ vertices and cannot be cubic.

## 10. Applications and interpretation

The uniqueness theorem can be read as a sensor-placement statement. Suppose an unknown state belongs to the harmonic solution space $\mathcal H_A$. Measurements on a zero forcing set determine the entire state: if two candidate states match at the sensors, they match globally. The conclusion is robust across all nonzero directed edge weights over any field.

In sparse matrix theory, the same argument bounds nullity. A vector in the kernel of an adjacency-pattern matrix obeys weighted neighbor equations. If its entries vanish on a zero forcing set, the vector is zero. Thus no kernel can have dimension larger than a zero forcing set, yielding the familiar relationship between graph forcing and maximum nullity in this weighted setting.

For network diagnosis, a legal force represents elimination of the final unknown adjacent to a resolved node. Triangle and diamond certificates describe local motifs through which determination can pass. The exact boundary hypotheses warn against an overly geometric interpretation: a motif is useful only when its external interface has already reached the required state.

For extremal graph theory, the parity and domination bounds constrain candidate examples before detailed forcing analysis. Any cubic graph has even order; any triangle–diamond partition has even $T$; and any degree-three dominating set has size at least $|V|/4$. These filters are inexpensive and can be incorporated into enumeration.

## 11. Discussion and limitations

The weighted harmonic theorem is more general than the motivating cubic claw-free setting. Once a forcing sequence is known, no regularity or forbidden-subgraph assumption is needed. Conversely, cubicity and claw-freeness alone do not manufacture a particular forcing sequence or imply every sharp formula for $Z(G)$. Global bounds based on counts of triangle and diamond units require a valid unit partition and suitable properties of the contraction multigraph, such as a Hamiltonian cyclic backbone.

The directed weights may be arbitrary but must be nonzero on edges. Allowing a zero edge weight breaks the decisive cancellation step. The field assumption ensures that a nonzero coefficient has no nontrivial annihilator. Over rings with zero divisors, the conclusion can fail even when the coefficient itself is nonzero.

The domination bound is intentionally coarse. Closed neighborhoods may overlap heavily, and claw-free structure may permit improvements in special classes. Its value here is conceptual: it contrasts static four-vertex coverage with directional forcing through local units.

## 12. Future work

A first direction is an equality problem for weighted nullity on diamond-free triangle networks whose contraction graph is a Hamiltonian cycle. The established uniqueness theorem supplies the upper-bound direction; the challenge is to construct enough independent harmonic modes through a suitable symmetric real weighting.

A second direction compares domination and forcing on a shared triangle–diamond decomposition. Since both parameters admit local costs but different state transitions, a finite-state optimization may identify the sharp asymptotic separation and its periodic extremizers.

A third direction asks for stability of cyclic forcing bounds. If deleting at most $r$ unit-vertices leaves a spanning cycle, one expects each defect to cost at most one additional seed. Local propagation certificates make this a concrete repair problem.

Finally, one may seek a converse to Theorem 5.3: if a set is not zero forcing, can some field and some nonzero directed edge weighting support a nonzero weighted harmonic function vanishing on that set? Such a result would characterize zero forcing exactly by universal harmonic uniqueness.

## 13. Conclusion

The zero forcing rule is governed by a single local fact: a colored vertex has one unresolved neighbor. That fact produces strict cardinal growth and irreversible reachability. In triangle and diamond units it yields short, composable propagation certificates. In a weighted harmonic equation it eliminates every term but one, forcing the remaining value to vanish.

Accordingly, every zero forcing set is a uniqueness set for every nondegenerately weighted neighbor-sum system over every field. Alongside this bridge, degree-three domination gives the bound $|V|\le4|D|$, cubicity forces even graph order, and triangle–diamond partitions contain an even number of triangle units. Together these results provide a precise local foundation for further structural and extremal study of claw-free cubic graphs.