# The Architecture of Proof: What Dependency Networks Really Tell Us About Mathematics

Mathematics is often pictured as a tower. Definitions form the foundation, lemmas become bricks, and great theorems crown the structure. The image is compelling, but it hides something essential: proofs do not usually rise in a single line. A theorem may draw on several earlier results; those results may share prerequisites; distant branches may later converge. The more faithful picture is a network.

Represent each statement by a vertex. Draw a directed edge from a premise to a statement that uses it. The resulting **dependency network** records not what a theorem says, but how mathematical knowledge supports it. It invites dramatic questions. Are a few celebrated theorems giant hubs? Does theorem reuse follow a power law? Would removing one foundational result shatter mathematics into disconnected pieces?

Those are fascinating empirical hypotheses. Yet before counting millions of dependencies, we should ask a more basic question: what follows from the network structure alone?

The answer is both elegant and cautionary. Every finite acyclic dependency network carries a canonical hierarchy. A bound on the number of hierarchical levels forces independent statements to coexist. But acyclicity does *not* force a scale-free degree distribution, and it does *not* make a network fragile under deletion. Indeed, there is an infinite family of acyclic dependency networks that remains weakly connected after any one vertex is removed.

## Why valid dependency networks have no directed cycles

Write $R(u,v)$ when statement $v$ directly depends on statement $u$. A directed path with at least one edge represents a nonempty chain of dependence. The network is called **acyclic** when no vertex can return to itself along such a path.

This excludes circular justification. It does not forbid two propositions from being logically equivalent, nor does it deny that mathematicians may prove each from the other after establishing independent foundations. It says only that a chosen dependency record cannot use a statement, through a chain of cited steps, to justify itself.

For a vertex $v$, define its set of **strict ancestors** by

$$
A(v)=\{u: \text{there is a nonempty directed path from }u\text{ to }v\}.
$$

These are all statements lying upstream of $v$, whether one edge away or many.

Now suppose there is a directed path from $a$ to $b$. Every ancestor of $a$ is also an ancestor of $b$: append the path from $a$ to $b$. Thus

$$
A(a)\subseteq A(b).
$$

Acyclicity makes this inclusion strict. The vertex $a$ itself belongs to $A(b)$, because $a$ reaches $b$. But $a$ cannot belong to $A(a)$, since that would be a directed cycle. Therefore

$$
A(a)\subsetneq A(b).
$$

This tiny observation creates a canonical clock for the whole network.

## The Canonical Topological Rank Theorem

In a finite acyclic dependency network, assign each vertex the number of its strict ancestors:

$$
\rho(v)=|A(v)|.
$$

The **Canonical Topological Rank Theorem** states that whenever $a$ reaches $b$ along a nonempty directed path,

$$
\rho(a)<\rho(b).
$$

The proof is immediate from strict containment: a proper subset of a finite set has smaller cardinality.

Unlike an arbitrary topological ordering, this rank requires no tie-breaking. It is determined entirely by the network. Two unrelated vertices may have the same rank, and even two vertices with different ranks need not be comparable. But every genuine chain of dependency climbs strictly upward.

This gives a useful diagnostic. If a proposed finite dependency graph contains an edge or path that fails to increase ancestor count, either the ancestor computation is wrong or the graph contains a cycle. It also gives a natural way to compare regions of a corpus: not by chronology or perceived difficulty, but by accumulated upstream structure.

## When limited depth forces width

Hierarchy creates another consequence through the pigeonhole principle. Suppose every vertex is assigned one of $L$ ordered levels,

$$
0,1,\ldots,L-1,
$$

and every nonempty dependency path strictly increases the assigned level. If the network has more than $L$ vertices, then two distinct vertices must occupy the same level.

Could one depend on the other? No. If $a$ reached $b$, the rank rule would require the level of $a$ to be smaller than the level of $b$. The same argument rules out a path from $b$ to $a$. We obtain the **Width–Depth Theorem**:

> If a finite dependency network has more vertices than available strictly increasing rank levels, then it contains two distinct vertices such that neither is reachable from the other.

Such vertices are **incomparable**. They represent parallel branches of development: neither lies upstream of the other.

The theorem transforms a familiar counting idea into a structural law. If dependency depth is compressed into few levels while the body of results grows, horizontal diversity is unavoidable. Mathematics cannot remain a single narrow chain. More statements than levels force some statements to live side by side.

This conclusion is stronger than the vague slogan that mathematics “branches.” It supplies an explicit condition and an exact certificate: a collision in any rank map that must increase along reachability.

## The fragility question

Network science often associates important vertices with high degree or with the ability to connect distant regions. This encourages a seductive story: perhaps mathematics is held together by a handful of hub theorems, and deleting one would disconnect large portions of the network.

But the word “disconnect” needs care in a directed graph. Dependency edges have an orientation, yet for structural cohesion we may ask only whether surviving vertices can be joined while traversing each edge in either direction. This is **weak connectivity**.

Fix a deleted vertex $d$. An **avoiding walk** from $a$ to $b$ is a finite walk whose steps use an edge in either direction and whose visited vertices avoid $d$. The surviving graph is weakly connected when every two surviving vertices admit such a walk.

Acyclicity alone gives no reason for deletion fragility. To see this, consider vertices

$$
0,1,\ldots,n-1
$$

and draw an edge from $i$ to $j$ whenever $i<j$. This is the strict total-order dependency network. It is acyclic, because every directed step strictly increases the index, so no directed path can return to its start.

It is also extraordinarily robust. Delete any vertex $d$. Given surviving vertices $a$ and $b$, either they are equal, requiring no movement, or one is smaller than the other. In the latter case there is a direct edge between them. Hence they remain joined by a one-step weak walk.

The **Robust Total-Order Theorem** therefore says:

> For every $n$, deleting any one vertex from the strict total-order dependency network on $n$ vertices leaves all surviving vertices weakly connected.

For every $n\ge 3$, this yields a nontrivial acyclic network with at least three distinct vertices and no single-vertex weak-connectivity failure.

This counterexample matters. It does not claim that real mathematical corpora are total orders; they certainly are not. It shows that no argument beginning only with “proof dependencies form a DAG” can conclude that mathematics is fragile. Fragility depends on redundancy and alternate routes, not acyclicity by itself.

## What the results do—and do not—establish

Three structural facts now stand on firm ground.

First, finite acyclicity creates hierarchy through ancestor count. Second, any bounded strictly increasing hierarchy with too many vertices forces an incomparable pair. Third, acyclic networks can be robust under every single-vertex deletion.

None of these facts establishes a power law. A claim such as

$$
P(k)\propto k^{-\gamma}
$$

for theorem reuse is statistical. It requires a specified corpus, a definition of degree, a dependency-extraction policy, and an honest model comparison against alternatives such as log-normal or truncated power-law tails. Nor can graph theory alone certify a universal list of historical “hub theorems.” Rankings may change across algebra, analysis, topology, and combinatorics, or when definitions are expanded or collapsed.

The distinction between theorem and measurement is the central lesson. Acyclicity guarantees an order-theoretic backbone, but degree distributions and articulation damage are properties of data.

## From metaphor to research program

The network view becomes scientifically productive when its choices are made explicit. Should an edge represent a direct citation, every transitive dependency, or a dependency after definitional expansions are collapsed? The same body of mathematics can produce different degree counts under these policies. A scale-free claim is credible only if its estimated tail is stable under reasonable choices.

The canonical rank suggests richer tests than a single global histogram. One can compare degree distributions at early and late ranks, measure how width grows with corpus size, and ask whether apparent heavy tails arise from mixing distinct layers. Deletion experiments should compare degree with more structural quantities, especially the number of internally vertex-disjoint weak paths. A high-degree theorem may be replaceable by many alternate routes, while a modest-degree theorem may be a true bottleneck.

The result is a more mature picture of mathematical architecture. Proof dependencies do form directed acyclic networks when recorded without circularity. Such networks possess a natural ascent from few ancestors to many, and constrained depth inevitably generates parallelism. Yet the network need not resemble a brittle web suspended from a few giant knots.

Mathematics may contain hubs. It may even exhibit heavy-tailed reuse. But those are discoveries to be made, not consequences hidden inside the word “DAG.” The durable insight is subtler: hierarchy is universal, width emerges from counting, and robustness belongs to the pattern of alternate connections. The architecture of proof is not one slogan but a meeting point between order theory, combinatorics, algorithms, and empirical network science.