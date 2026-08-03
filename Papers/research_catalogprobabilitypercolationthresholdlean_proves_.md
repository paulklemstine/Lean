# Monotone Common-Key Couplings for Finite Site and Bond Percolation

**Aristotle**  
**2 August 2026**

## Abstract

We present a deterministic common-key construction that simultaneously generates finite percolation configurations at every real threshold. Each vertex in a site model, or each edge in a bond model, receives one real-valued key and is declared open at level $p$ exactly when its key is at most $p$. The resulting configurations are pointwise nested: if $p\le q$, every object open at $p$ remains open at $q$. We prove, for arbitrary graphs, that site connectivity and bond connectivity persist under threshold increase. We further establish persistence of horizontal site crossings in every positive finite square grid and combine the site and bond conclusions without conflating their distinct sample spaces. The proofs are finite and order-theoretic; they require neither independence nor a probability measure. When keys are independent and uniform on $[0,1]$, the construction couples the full family of Bernoulli percolation laws and immediately yields monotonicity of probabilities of increasing events. We describe exact and event-driven algorithms, numerical demonstrations, applications to reliability and threshold-controlled networks, and the additional work required to pass from finite monotonicity to sharp or infinite-volume threshold results.

## 1. Introduction

Percolation studies connectivity in a medium whose components are open or closed. In site percolation the random components are vertices; in bond percolation they are edges. A central qualitative fact is that opening more components cannot destroy an existing open path. Yet a careless comparison of two densities can obscure this fact: if configurations at the two densities are sampled independently, a lower-density sample may happen to contain a crossing while a higher-density sample does not.

A coupling resolves this mismatch by constructing both samples from shared randomness. The most direct construction assigns one numerical key to every component. At threshold $p$, exactly those components with key at most $p$ are open. The same keys then generate the configurations at all thresholds. The family grows by inclusion, so every increasing event has a nondecreasing indicator along every coupled realization.

This paper isolates the deterministic content of that construction. It establishes the following chain of results.

- Threshold membership is exactly the corresponding key inequality.
- Site and bond configurations are pointwise nested under threshold increase.
- Site and bond connectivity persist on arbitrary graphs.
- Horizontal site crossings persist on all nonempty finite square grids.
- Site and bond persistence can be combined while their sample spaces remain distinct.

These statements require no random model for the keys. Probabilistic consequences are derived only after the deterministic structure is complete.

The finite scope is important. Pointwise monotonicity does not alone identify a critical parameter on an infinite lattice, prove strict increase of finite crossing probabilities, or supply sharp-threshold estimates. It is instead foundational infrastructure: a canonical comparison across parameters and a clean route from increasing events to monotone probabilities.

## 2. Graphs and configurations

### 2.1 Graph-theoretic setting

Let $G=(V,E)$ be a simple undirected graph. Thus $V$ is a set of vertices, and $E$ is a set of unordered pairs of distinct vertices. The arguments below are most directly computational when $V$ and $E$ are finite, although the elementary persistence proofs use only finite witness paths.

A finite path from $u$ to $v$ is a sequence

$$
u=x_0,x_1,\ldots,x_k=v$$

such that each unordered pair $\{x_{i-1},x_i\}$ is an edge of $G$.

### 2.2 Site configurations

A **site configuration** is a function

$$
\eta:V\longrightarrow\{0,1\}.
$$

A vertex $x$ is open when $\eta(x)=1$ and closed when $\eta(x)=0$. A path is an **open site path** when every vertex on it is open. Vertices $u$ and $v$ are **site-connected** in $\eta$ when an open site path joins them.

There are conventions in which only internal path vertices must be open. Here endpoints are included, so a site connection certifies openness of every vertex in its witness path. The persistence argument works for either convention as long as the notion of openness is monotone.

For two site configurations $\eta$ and $\eta'$, write $\eta\preceq\eta'$ when

$$
\eta(x)=1\implies\eta'(x)=1
$$

for every $x\in V$. This is the natural partial order by inclusion of open sites.

### 2.3 Bond configurations

A **bond configuration** is a function

$$
\omega:E\longrightarrow\{0,1\}.
$$

An edge $e$ is open when $\omega(e)=1$. A graph path is an **open bond path** when every edge traversed by the path is open. Vertices $u$ and $v$ are **bond-connected** in $\omega$ when an open bond path joins them.

For bond configurations, define $\omega\preceq\omega'$ by

$$
\omega(e)=1\implies\omega'(e)=1
$$

for every $e\in E$.

Site and bond configurations are different mathematical objects. One is indexed by vertices and the other by edges. Their parallel order structures permit parallel theorems, but do not identify the two spaces.

## 3. Common-key threshold configurations

### Definition 3.1 (Site threshold configuration)

Let $K:V\to\mathbb R$ assign a real key to each vertex. For a real threshold $p$, the associated site threshold configuration $\eta_p^K$ is

$$
\eta_p^K(x)=\mathbf 1\{K(x)\le p\}.
$$

Equivalently, $x$ is open at level $p$ exactly when $K(x)\le p$.

### Definition 3.2 (Bond threshold configuration)

Let $L:E\to\mathbb R$ assign a real key to each edge. For $p\in\mathbb R$, the associated bond threshold configuration $\omega_p^L$ is

$$
\omega_p^L(e)=\mathbf 1\{L(e)\le p\}.
$$

The threshold may be any real number. The familiar interval $[0,1]$ becomes relevant only when keys are sampled uniformly from that interval.

### Lemma 3.3 (Exact threshold membership)

For every vertex $x$, edge $e$, and threshold $p$,

$$
\eta_p^K(x)=1\quad\Longleftrightarrow\quad K(x)\le p,
$$

and

$$
\omega_p^L(e)=1\quad\Longleftrightarrow\quad L(e)\le p.
$$

**Proof sketch.** Both equivalences are the defining cases of the indicator functions in Definitions 3.1 and 3.2. The statement is recorded explicitly because it converts configuration membership into transitive inequalities. $\square$

### Theorem 3.4 (Pointwise threshold nesting)

Let $p,q\in\mathbb R$ satisfy $p\le q$. Then

$$
\eta_p^K\preceq\eta_q^K
\qquad\text{and}\qquad
\omega_p^L\preceq\omega_q^L.
$$

In set notation,

$$
\{x\in V:K(x)\le p\}\subseteq\{x\in V:K(x)\le q\},
$$

and

$$
\{e\in E:L(e)\le p\}\subseteq\{e\in E:L(e)\le q\}.
$$

**Proof sketch.** If $x$ is open at $p$, Lemma 3.3 gives $K(x)\le p$. Since $p\le q$, transitivity yields $K(x)\le q$, and Lemma 3.3 says that $x$ is open at $q$. The edge argument is identical with $L(e)$ in place of $K(x)$. $\square$

### Remark 3.5 (Reflexivity and ties)

When $p=q$, the configurations agree, so nesting is reflexive. The weak inequality in the opening rule handles repeated keys without ambiguity: all objects with key exactly $p$ enter at threshold $p$. Choosing a strict inequality would produce a different convention at jump points but the same nesting argument.

## 4. Persistence of connectivity

### Theorem 4.1 (Site connectivity persistence)

Let $G=(V,E)$ be a graph, let $K:V\to\mathbb R$, and let $p\le q$. For any $u,v\in V$, if $u$ and $v$ are site-connected in $\eta_p^K$, then they are site-connected in $\eta_q^K$.

**Proof sketch.** Choose an open site path $x_0=u,x_1,\ldots,x_k=v$ in $\eta_p^K$. Every $x_i$ is open at $p$. By Theorem 3.4 every $x_i$ is open at $q$. The adjacency relations of the path are properties of $G$ and do not change with the threshold. Hence the same vertex sequence is an open site path at $q$. $\square$

This proof preserves the witness, not merely the truth value of connectivity. Such witness preservation is useful algorithmically because a path found at a lower threshold remains certified at all higher thresholds.

### Theorem 4.2 (Bond connectivity persistence)

Let $G=(V,E)$ be a graph, let $L:E\to\mathbb R$, and let $p\le q$. For any $u,v\in V$, if $u$ and $v$ are bond-connected in $\omega_p^L$, then they are bond-connected in $\omega_q^L$.

**Proof sketch.** Choose an open bond path from $u$ to $v$ at threshold $p$. Every traversed edge $e$ satisfies $L(e)\le p$. Since $p\le q$, every such edge also satisfies $L(e)\le q$. The same graph path is therefore open at $q$. $\square$

### Definition 4.3 (Increasing event)

An event $A$ on site configurations is **increasing** when

$$
\eta\preceq\eta'\ \text{and}\ \eta\in A
\quad\Longrightarrow\quad
\eta'\in A.
$$

The analogous definition applies to bond configurations.

Connectivity of fixed endpoints is increasing by Theorems 4.1 and 4.2. Other examples include the existence of a cluster with at least $r$ vertices, connection from a source set to a target set, and the existence of $k$ edge-disjoint open routes.

### Corollary 4.4 (Pointwise monotonicity of increasing events)

If $A$ is an increasing site event, then

$$
\mathbf 1_A(\eta_p^K)\le \mathbf 1_A(\eta_q^K)
$$

whenever $p\le q$. The same conclusion holds for increasing bond events.

**Proof sketch.** Theorem 3.4 gives inclusion of the lower-threshold configuration in the higher-threshold configuration. Apply the defining implication of an increasing event. $\square$

## 5. Horizontal crossings of finite grids

Let

$$
V_n=\{0,1,\ldots,n-1\}^2
$$

for an integer $n>0$. The square grid graph joins $(i,j)$ to $(i',j')$ when their Manhattan distance is one:

$$
|i-i'|+|j-j'|=1.
$$

The left and right boundary sets are

$$
L_n=\{(0,j):0\le j<n\},
\qquad
R_n=\{(n-1,j):0\le j<n\}.
$$

### Definition 5.1 (Horizontal site crossing)

A site configuration on $V_n$ has a **horizontal crossing** when some open site path begins at a vertex of $L_n$ and ends at a vertex of $R_n$.

### Theorem 5.2 (Horizontal crossing persistence)

Let $n>0$, let $K:V_n\to\mathbb R$, and let $p\le q$. If $\eta_p^K$ has a horizontal crossing, then $\eta_q^K$ has a horizontal crossing.

**Proof sketch.** A horizontal crossing supplies two boundary endpoints and an open site path joining them at threshold $p$. The endpoints remain on the same geometric boundaries, while Theorem 4.1 preserves the path at threshold $q$. Thus it remains a horizontal crossing. $\square$

### Corollary 5.3 (A realization-wise critical level)

For a fixed key assignment on a finite grid, the crossing indicator

$$
H_K(p)=\mathbf 1\{\eta_p^K\text{ has a horizontal crossing}\}
$$

is a nondecreasing step function. If a crossing occurs for at least one threshold, there is a least key level at which it first occurs, namely

$$
p_*(K)=\min\{K(x):H_K(K(x))=1\}.
$$

Moreover, $H_K(p)=0$ for $p<p_*(K)$ and $H_K(p)=1$ for $p\ge p_*(K)$.

**Proof sketch.** Monotonicity follows from Theorem 5.2. A finite configuration changes only at one of finitely many vertex keys, so the first successful key exists whenever success occurs. Nesting gives the two stated regimes. $\square$

The quantity $p_*(K)$ is a sample-dependent crossing threshold, not an infinite-volume critical probability. It is nevertheless a useful statistic in finite simulations.

## 6. Simultaneous site and bond persistence

One may wish to study site and bond systems in parallel. They may live on different graphs, use different endpoint pairs, and have unrelated key assignments.

### Theorem 6.1 (Joint site-and-bond connectivity persistence)

Let $G_s=(V,E_s)$ be a site graph with keys $K:V\to\mathbb R$, and let $G_b=(V,E_b)$ be a bond graph with keys $L:E_b\to\mathbb R$. Choose site endpoints $s_u,s_v$ and bond endpoints $b_u,b_v$. If $p\le q$, if $s_u$ and $s_v$ are site-connected at threshold $p$, and if $b_u$ and $b_v$ are bond-connected at threshold $p$, then both connections hold at threshold $q$.

**Proof sketch.** Apply Theorem 4.1 to the site connection and Theorem 4.2 to the bond connection. The conjunction of the two resulting statements is the conclusion. No identification between vertices and edges, or between their key spaces, is made. $\square$

The theorem emphasizes a methodological point: shared order structure does not imply shared sample space. Site and bond models may exhibit analogous monotonicity while retaining different local states, probabilities, dualities, and infinite-volume behavior.

## 7. Probabilistic specialization

Assume now that $V$ is finite and that the vertex keys $(K(x))_{x\in V}$ are independent and uniformly distributed on $[0,1]$. For $p\in[0,1]$,

$$
\Pr(\eta_p^K(x)=1)=\Pr(K(x)\le p)=p.
$$

Independence of keys gives independence of site states. Thus $\eta_p^K$ has the Bernoulli site-percolation law with parameter $p$. One key vector realizes these laws simultaneously for all $p\in[0,1]$.

### Proposition 7.1 (Finite configuration probability)

For a prescribed site configuration $\eta$ on finite $V$, let

$$
N_1(\eta)=|\{x\in V:\eta(x)=1\}|,
\qquad
N_0(\eta)=|\{x\in V:\eta(x)=0\}|.
$$

Under independent uniform keys,

$$
\Pr(\eta_p^K=\eta)
=p^{N_1(\eta)}(1-p)^{N_0(\eta)}.
$$

**Proof sketch.** Each required open site contributes probability $p$, each required closed site contributes probability $1-p$, and independence turns the intersection into the product. $\square$

### Proposition 7.2 (Probability monotonicity for increasing events)

For every increasing event $A$ on a finite site set, the function

$$
p\longmapsto\Pr(\eta_p^K\in A)
$$

is nondecreasing on $[0,1]$. The same statement holds for finite bond systems with independent uniform edge keys.

**Proof sketch.** For every fixed key assignment, Corollary 4.4 makes the event indicator nondecreasing in $p$. Therefore, for $p\le q$,

$$
\mathbf 1_A(\eta_p^K)\le\mathbf 1_A(\eta_q^K)
$$

pointwise. Taking expectations preserves the inequality. $\square$

In particular, the horizontal crossing probability of a finite grid is nondecreasing. Notice that strict monotonicity is stronger and needs additional reasoning: one must exhibit positive-probability configurations in which the event appears between $p$ and $q$.

## 8. Algorithms

### 8.1 Direct threshold evaluation

Given $m$ keyed objects and a threshold $p$, construct the configuration by comparing every key with $p$. This takes $O(m)$ time and $O(m)$ output space. A breadth-first or depth-first search then tests connectivity in $O(|V|+|E|)$ time.

For a grid, horizontal crossing detection initializes a search from all open left-boundary sites and succeeds if an open right-boundary site is reached. On an $n\times n$ grid, this costs $O(n^2)$ time and $O(n^2)$ memory in the worst case.

### 8.2 Event-driven threshold sweep

For many threshold queries, repeated reconstruction is wasteful. Sort the $m$ keys once in $O(m\log m)$ time. Activate objects in nondecreasing key order. For site connectivity, when a vertex activates, union it with active neighbors in a disjoint-set union structure. For bond connectivity, when an edge activates, union its endpoints.

With path compression and union by rank, the total cost of $m$ union/find operations is $O(m\alpha(m))$, where $\alpha$ is the inverse Ackermann function. After sorting, each connectivity query at a key level is nearly constant-time amortized.

For horizontal grid crossings, add virtual left and right boundary nodes. Union each newly active boundary vertex with the appropriate virtual node. The first key level at which the two virtual nodes have the same representative is the realization-wise threshold $p_*(K)$ from Corollary 5.3.

### 8.3 Coupled Monte Carlo estimation

To compare crossing probabilities at thresholds $p_1<\cdots<p_r$, each Monte Carlo trial samples one key field and evaluates all thresholds from that field. The outputs within a trial are nested. The estimator at each threshold is the sample average of its crossing indicator.

This procedure has the correct marginal distribution at every threshold. It also supports direct estimation of increments

$$
\Pr(H(p_j)=1)-\Pr(H(p_i)=1)
$$

using paired indicators from the same realization. Common random numbers often reduce the variance of such differences relative to independent resampling, although the exact variance gain depends on the event and parameters.

## 9. Numerical illustration

Consider a $4\times4$ grid with fixed keys. At thresholds $0.25$, $0.45$, $0.65$, and $0.85$, the open sets are obtained by retaining successively larger prefixes of the same sorted key list. A breadth-first search records whether the left and right boundaries are connected. The resulting Boolean sequence must have the form

$$
0,\ldots,0,1,\ldots,1.
$$

It cannot contain the pattern $1,0$. The same assertion holds for endpoint connectivity in an arbitrary keyed graph and for bond activation.

A numerical program can check this property over many random trials, but the check illustrates rather than establishes the theorem: nesting follows exactly from real-number transitivity. Simulation becomes valuable for estimating the location and distribution of sample-dependent crossing thresholds.

## 10. Applications

### 10.1 Network reliability

Assign each component a tolerance or activation key. A threshold may represent available power, maintenance investment, or quality requirement. The persistence theorems guarantee that increasing resources cannot eliminate a route already supported by the model. A coupled sweep identifies bottleneck levels at which designated terminals first connect.

### 10.2 Security and threshold-controlled access

In a simplified threshold-controlled communication network, vertices may represent authorized relays and edges may represent enabled channels. Permanent keys encode activation requirements. The joint persistence theorem permits vertex-controlled and channel-controlled systems to be analyzed together without confusing their state spaces. Monotonicity provides a basic sanity property for policy evaluation: relaxing an inclusion threshold does not revoke previously available connectivity.

### 10.3 Sensitivity analysis

Because all parameter levels share one key field, changes are attributable to newly activated components rather than unrelated resampling. The first crossing level and the objects activated at that level identify candidates for pivotality analysis. This leads naturally toward Russo-type formulas, which connect derivatives of event probabilities to pivotal probabilities.

### 10.4 Visualization and teaching

A threshold slider coupled to one key field displays a mathematically faithful growth process. Learners can see components appear, clusters merge, and crossings persist. The visualization distinguishes monotone evolution from a sequence of unrelated random snapshots.

## 11. Scope and limitations

The theorems are deterministic statements about thresholded keys and finite witness paths. They do not assume that keys are uniform, independent, or random. Conversely, they do not by themselves prove probabilistic facts that require those assumptions.

Several stronger conclusions are outside the present results.

First, monotonicity is not strictness. An event probability can remain constant over an interval, and proving strict increase for a particular finite event requires a positive-probability mechanism that changes its status.

Second, finite crossing persistence is not an infinite-volume phase transition theorem. A proof of an exact critical probability requires definitions of infinite configurations and clusters, finite-to-infinite limiting arguments, and model-specific tools such as planar duality and sharp-threshold theory.

Third, the site and bond constructions are parallel but separate. Equality of local expressions in a special geometry would not identify the models globally.

Finally, cryptographic applications require domain-specific threat models and security definitions beyond monotone graph connectivity. The coupling supplies an order-theoretic component, not a complete security analysis.

## 12. Future research

Five immediate directions extend the present framework.

1. **Finite-key probability formula.** Develop the full finite distribution under independent uniform keys, including the formula $p^{N_1}(1-p)^{N_0}$ and its bond analogue as the basis for exact event polynomials.

2. **Crossing probability monotonicity.** Systematically derive nondecreasing finite-grid crossing probabilities from pointwise coupling and expectation.

3. **Finite Russo formula.** For an increasing Boolean event on a finite site set, show for $p\in(0,1)$ that the derivative of its Bernoulli probability polynomial equals the sum of site pivotal probabilities.

4. **Strictness on grids.** For $n\ge2$ and $0<p<q<1$, prove that the horizontal crossing probability of the $n\times n$ grid is strictly smaller at $p$ than at $q$.

5. **General bond events.** Establish that independent uniform edge keys simultaneously realize Bernoulli bond measures for every finite graph and make every increasing bond-event indicator pointwise nondecreasing.

Beyond these finite steps lie planar primal-dual alternatives, matching-lattice transformations, exhaustion and compactness arguments, sharp thresholds, and infinite-cluster criteria. Those tools are necessary before finite coupling results can support exact infinite-lattice critical probabilities.

## 13. Conclusion

A common-key threshold coupling replaces separately sampled percolation configurations by one nested family. Its mechanism is minimal: assign permanent real keys and compare them with a moving threshold. Its consequences are broad. Open site sets and open bond sets grow pointwise; witness paths persist; finite-grid crossings cannot disappear; and distinct site and bond systems can be advanced together without being identified.

When the keys are independent and uniform, the same deterministic construction realizes all Bernoulli parameters on one probability space. Monotonicity of increasing-event probabilities then follows by averaging a pointwise inequality. Computationally, sorted activation and disjoint-set updates turn the coupling into an efficient threshold-sweep algorithm.

The central result is thus both mathematical and methodological: coupling parameters through common keys exposes the order hidden inside a family of random models. It separates what follows from deterministic nesting from what still demands probability, geometry, or infinite-volume analysis.
