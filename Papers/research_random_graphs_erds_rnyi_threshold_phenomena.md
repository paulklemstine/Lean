# Threshold Phenomena in the Erdős–Rényi Random Graph

## Abstract

We develop a self-contained account of threshold phenomena in the Erdős–Rényi model $G(n,p)$. Starting from the finite probability mass assigned to each edge configuration, we prove normalization, independence for prescribed edge sets, the union bound, and exact formulas for expected pattern counts. These yield a first-moment criterion for absence. We then derive the second-moment inequality $\Pr(X=0)\le \operatorname{Var}(X)/(\mathbb E X)^2$ and show that an expectation tending to infinity together with variance of order at most the expectation forces occurrence with high probability. We apply this framework to the two principal structural scales of random graphs. At $p=(1\pm\varepsilon)/n$, component exploration changes from subcritical to supercritical: below the scale all components have logarithmic size with high probability, while above it a component of linear size appears. At $p=(\log n+c)/n$, isolated vertices have an asymptotic Poisson law with mean $e^{-c}$ and connectivity converges to $e^{-e^{-c}}$. We also describe algorithms and numerical experiments that expose these transitions in finite graphs.

## 1. Introduction

A threshold is a narrow parameter range across which a random structure changes from almost surely lacking a property to almost surely possessing it. The Erdős–Rényi random graph provides the canonical setting. It combines an elementary sampling rule with global behavior rich enough to distinguish several notions of network formation.

Two transitions are central. The first occurs near $p=1/n$, where a connected component containing a positive fraction of all vertices emerges. The second occurs near $p=(\log n)/n$, where the last isolated vertices disappear and the graph becomes connected. These scales answer different questions. The giant-component threshold concerns extensive reachability; the connectivity threshold requires universal reachability.

The proofs depend on a compact toolkit. Independence computes the probability of any prescribed edge pattern. Indicator variables convert counts into sums. The union bound and first moment prove nonexistence when expected counts vanish. Variance and the second moment prove existence when expected counts grow and fluctuations are controlled. Poisson approximation handles rare obstructions in a critical window, while branching-process comparison describes component exploration.

Throughout, “with high probability” means with probability tending to $1$ as $n\to\infty$. All graphs are finite, simple, undirected, and labeled.

## 2. The finite random graph model

### 2.1 Configurations and their masses

Let $V=[n]=\{1,\ldots,n\}$ and let

$$
\mathcal E_n=\bigl\{\{u,v\}:u,v\in V,\ u\ne v\bigr\}
$$

be the set of possible edges. Its cardinality is $N=\binom n2$. A configuration is a subset $S\subseteq\mathcal E_n$; it defines the graph whose edge set is $S$.

**Definition 2.1 (Erdős–Rényi mass).** For $p\in[0,1]$ and $S\subseteq\mathcal E_n$, define

$$
\mu_p(S)=p^{|S|}(1-p)^{N-|S|}.
$$

For an event $A\subseteq 2^{\mathcal E_n}$, define

$$
\Pr_p(A)=\sum_{S\in A}\mu_p(S).
$$

**Theorem 2.2 (Normalization and nonnegativity).** For $p\in[0,1]$, every mass $\mu_p(S)$ is nonnegative and

$$
\sum_{S\subseteq\mathcal E_n}\mu_p(S)=1.
$$

*Proof sketch.* Nonnegativity follows from $p\ge0$ and $1-p\ge0$. Group configurations according to $m=|S|$. There are $\binom Nm$ configurations with $m$ edges, so the total mass is

$$
\sum_{m=0}^{N}\binom Nm p^m(1-p)^{N-m}
=(p+(1-p))^N=1
$$

by the binomial theorem. Thus $\Pr_p$ is a probability law.

### 2.2 Prescribed edges and independence

**Theorem 2.3 (Prescribed-edge probability).** If $T\subseteq\mathcal E_n$ is a fixed set of $t$ edges, then

$$
\Pr_p(T\subseteq S)=p^t.
$$

*Proof sketch.* Every configuration containing $T$ has the unique form $T\cup R$, where $R\subseteq\mathcal E_n\setminus T$. Factoring out $p^t$ and summing over $R$ gives

$$
p^t\sum_{R\subseteq\mathcal E_n\setminus T}
 p^{|R|}(1-p)^{N-t-|R|}
=p^t(p+1-p)^{N-t}=p^t.
$$

This theorem expresses the independence of edge indicators. Importantly, it leaves all edges outside $T$ unspecified.

## 3. First moments and pattern counts

### 3.1 Union bound

**Lemma 3.1 (Finite union bound).** For events $A_1,\ldots,A_r$,

$$
\Pr_p\!\left(\bigcup_{i=1}^r A_i\right)
\le \sum_{i=1}^r\Pr_p(A_i).
$$

*Proof sketch.* A configuration in the union occurs in at least one event, so its nonnegative mass is counted at least once on the right. Configurations in several events may be counted repeatedly, producing an inequality.

### 3.2 Exact expected counts

Let $\mathcal T$ be a finite family of subsets of $\mathcal E_n$. Its members represent candidate copies of a desired edge pattern. Define

$$
X_{\mathcal T}(S)=|\{T\in\mathcal T:T\subseteq S\}|.
$$

**Theorem 3.2 (Expected pattern count).** The expected number of realized patterns is

$$
\mathbb E_p[X_{\mathcal T}]
=\sum_{T\in\mathcal T}p^{|T|}.
$$

*Proof sketch.* Write

$$
X_{\mathcal T}=\sum_{T\in\mathcal T}\mathbf 1_{\{T\subseteq S\}}.
$$

Linearity of expectation and Theorem 2.3 give

$$
\mathbb E_p[X_{\mathcal T}]
=\sum_{T\in\mathcal T}\Pr_p(T\subseteq S)
=\sum_{T\in\mathcal T}p^{|T|}.
$$

No independence among the indicators is needed.

**Corollary 3.3 (Uniform pattern size).** If every member of $\mathcal T$ has $e$ edges, then

$$
\mathbb E_p[X_{\mathcal T}]=|\mathcal T|p^e.
$$

For example, the number $X_\triangle$ of triangles satisfies

$$
\mathbb E[X_\triangle]=\binom n3p^3.
$$

The number of labeled copies of a fixed graph $H$ with $v(H)$ vertices and $e(H)$ edges is of order

$$
n^{v(H)}p^{e(H)},
$$

up to a constant determined by automorphisms.

### 3.3 First-moment threshold

**Theorem 3.4 (First-moment vanishing criterion).** For $p\in[0,1]$,

$$
\Pr_p(X_{\mathcal T}>0)
\le \sum_{T\in\mathcal T}p^{|T|}
=\mathbb E_p[X_{\mathcal T}].
$$

Consequently, if a sequence of families and probabilities satisfies $\mathbb E[X_n]\to0$, then $\Pr(X_n>0)\to0$.

*Proof sketch.* The event $X_{\mathcal T}>0$ is the union, over $T\in\mathcal T$, of the events $T\subseteq S$. Apply Lemma 3.1 and Theorem 2.3.

This result gives the lower side of many thresholds. For a fixed graph $H$, if $n^{v(H)}p^{e(H)}\to0$, then with high probability no copy of $H$ appears. For non-balanced graphs, denser subgraphs impose the decisive scale; this motivates the maximum density

$$
m(H)=\max_{H'\subseteq H,\ e(H')>0}\frac{e(H')}{v(H')}.
$$

The natural general threshold is $p\asymp n^{-1/m(H)}$.

## 4. The second-moment method

### 4.1 Variance and a zero-event inequality

For any real random variable $X$ on the finite configuration space, define

$$
\mathbb E[X]=\sum_S\mu_p(S)X(S)
$$

and

$$
\operatorname{Var}(X)=\mathbb E[(X-\mathbb E[X])^2].
$$

**Theorem 4.1 (Second-moment zero bound).** If $\mathbb E[X]\ne0$, then

$$
\Pr(X=0)
\le
\frac{\operatorname{Var}(X)}{(\mathbb E[X])^2}.
$$

*Proof sketch.* On $\{X=0\}$ one has

$$
(X-\mathbb E[X])^2=(\mathbb E[X])^2.
$$

All summands in the variance are nonnegative, hence

$$
\operatorname{Var}(X)
\ge (\mathbb E[X])^2\Pr(X=0).
$$

Division by the positive square $(\mathbb E[X])^2$ proves the claim.

**Lemma 4.2 (Analytic squeeze).** Let $P_n\ge0$, let $E_n\to\infty$, and suppose

$$
P_n\le\frac{V_n}{E_n^2}
\qquad\text{and}\qquad
V_n\le CE_n
$$

for a constant $C$. Then $P_n\to0$.

*Proof sketch.* The assumptions imply $0\le P_n\le C/E_n$, and $C/E_n\to0$.

**Theorem 4.3 (Second-moment occurrence criterion).** Let $X_n$ be nonnegative pattern counts. If

$$
\mathbb E[X_n]\to\infty
$$

and there is a constant $C$ such that

$$
\operatorname{Var}(X_n)\le C\mathbb E[X_n]
$$

for all $n$, then

$$
\Pr(X_n=0)\to0.
$$

Equivalently, $X_n>0$ with high probability.

*Proof sketch.* Apply Theorem 4.1 with $E_n=\mathbb E[X_n]$ and $V_n=\operatorname{Var}(X_n)$, then invoke Lemma 4.2.

The usefulness of this theorem lies in overlap enumeration. For a subgraph count $X=\sum_T I_T$,

$$
\operatorname{Var}(X)
=\sum_{T,U}\operatorname{Cov}(I_T,I_U).
$$

Disjoint edge sets have zero covariance. Only overlapping pairs contribute, reducing variance control to a combinatorial classification of overlaps.

### 4.2 Example: the triangle count

The triangle count illustrates both the power and the limits of moments. Let $I_A$ be the indicator that a three-vertex set $A$ spans a triangle, and put

$$
X_\triangle=\sum_{A\in\binom{[n]}3}I_A.
$$

The expectation is $\binom n3p^3$. To compute the variance, note that two distinct triangles are edge-disjoint unless they share an edge. Indicators for edge-disjoint triangles are independent, even when the triangles share a single vertex. Hence

$$
\operatorname{Var}(X_\triangle)
=\sum_A\operatorname{Var}(I_A)
+2\sum_{A<B}\operatorname{Cov}(I_A,I_B),
$$

where only pairs sharing an edge contribute to the covariance sum. For one triangle,

$$
\operatorname{Var}(I_A)=p^3(1-p^3).
$$

A pair sharing one edge has a union of five edges, so

$$
\mathbb E[I_AI_B]=p^5
\qquad\text{and}\qquad
\operatorname{Cov}(I_A,I_B)=p^5-p^6.
$$

There are $6\binom n4$ unordered pairs of triangles sharing an edge: choose four vertices and then choose their common edge. Therefore

$$
\operatorname{Var}(X_\triangle)
=\binom n3p^3(1-p^3)
+12\binom n4(p^5-p^6).
$$

This exact expression makes dependence visible. If $p$ is sufficiently above the triangle threshold, dividing by $(\mathbb E X_\triangle)^2$ shows that the zero-event probability vanishes. At the critical scale $p=c/n$, however, the expectation stays bounded and a Poisson law, rather than concentration around a diverging mean, is the appropriate limiting description.

### 4.3 General overlap principle

For copies of a fixed graph $H$, each pair of copies is classified by its common subgraph $J$. If the two copies together use $2e(H)-e(J)$ distinct edges, their joint probability is

$$
p^{2e(H)-e(J)}.
$$

The number of such pairs is of order $n^{2v(H)-v(J)}$. Comparing every overlap contribution with the square of the mean leads to ratios of the form

$$
n^{-v(J)}p^{-e(J)}.
$$

These ratios explain why the densest nonempty subgraph of $H$ determines the general containment threshold. They also show why strictly balanced graphs are particularly clean: at the critical scale, proper overlaps are asymptotically negligible, leaving isolated copies whose count tends toward a Poisson distribution.

## 5. Connectivity at the logarithmic scale

### 5.1 Isolated vertices determine the scale

Let $I_n$ denote the number of isolated vertices in $G(n,p)$. A fixed vertex is isolated if all of its $n-1$ incident edges are absent. Therefore

$$
\mathbb E[I_n]=n(1-p)^{n-1}.
$$

If $p=(\log n+c)/n$, then

$$
(1-p)^{n-1}
=\exp\bigl((n-1)\log(1-p)\bigr)
\sim e^{-np}
=\frac{e^{-c}}{n},
$$

and hence

$$
\mathbb E[I_n]\to e^{-c}.
$$

Thus the expected number of isolated vertices remains of constant order precisely in a window of width $1/n$ around $(\log n)/n$.

### 5.2 Poisson law

**Theorem 5.1 (Poisson limit for isolated vertices).** Fix $c\in\mathbb R$ and set $p_n=(\log n+c)/n$. Then

$$
I_n\xrightarrow{d}\operatorname{Poisson}(e^{-c}).
$$

*Proof sketch.* For each fixed positive integer $k$, consider the falling factorial $(I_n)_k$. It counts ordered $k$-tuples of distinct isolated vertices. A specified $k$-tuple is isolated exactly when every edge incident to one of those vertices is absent. The number of such edges is

$$
k(n-k)+\binom k2.
$$

Therefore

$$
\mathbb E[(I_n)_k]
=(n)_k(1-p_n)^{k(n-k)+\binom k2}
\longrightarrow e^{-ck}.
$$

These are the factorial moments of a Poisson random variable with mean $e^{-c}$. The method of moments yields convergence in distribution.

### 5.3 Excluding other disconnected components

A graph with no isolated vertices can still be disconnected, but this possibility vanishes in the critical window. If there is a component on a vertex set $S$ with $2\le |S|=k\le n/2$, then no edge joins $S$ to its complement. Ignoring the additional requirement that the induced graph on $S$ be connected gives

$$
\Pr(\text{some separated }k\text{-set})
\le \binom nk(1-p)^{k(n-k)}.
$$

A refined split into small and moderate $k$, together with a spanning-tree bound for connected induced subgraphs, shows that the sum over $2\le k\le n/2$ tends to zero when $p=(\log n+c)/n$. Thus, asymptotically, disconnection is caused only by isolated vertices.

**Theorem 5.2 (Sharp connectivity window).** For every fixed $c\in\mathbb R$,

$$
\Pr\!\left(G\!\left(n,\frac{\log n+c}{n}\right)
\text{ is connected}\right)
\longrightarrow
\exp(-e^{-c}).
$$

*Proof sketch.* By Theorem 5.1,

$$
\Pr(I_n=0)\to \Pr(\operatorname{Poisson}(e^{-c})=0)
=e^{-e^{-c}}.
$$

The probability of being disconnected without an isolated vertex tends to zero, so connectivity and the event $I_n=0$ have the same limit.

**Corollary 5.3 (Threshold form).** If $p=(\log n-\omega(n))/n$ with $\omega(n)\to\infty$, then the connectivity probability tends to $0$. If $p=(\log n+\omega(n))/n$, then it tends to $1$.

The limiting profile is a shifted Gumbel-type curve. It records the disappearance of rare defects rather than the creation of a large component.

## 6. The phase transition for component size

### 6.1 Exploration and branching processes

To explore the component of a vertex $v$, maintain a queue of active vertices. Remove one active vertex, reveal its edges to all unexplored vertices, add newly discovered neighbors to the queue, and stop when the queue is empty. Early in the exploration, the number of new vertices is close to $\operatorname{Binomial}(n,p)$, whose mean is approximately $np$.

This suggests comparison with a Galton–Watson branching process. A process with mean offspring below $1$ dies out rapidly; one with mean above $1$ survives with positive probability. The critical mean $1$ corresponds to $p=1/n$.

### 6.2 Subcritical regime

**Theorem 6.1 (Logarithmic components below criticality).** Fix $\varepsilon\in(0,1)$ and set

$$
p_n=\frac{1-\varepsilon}{n}.
$$

There exists $A=A(\varepsilon)>0$ such that

$$
\Pr\bigl(L_1(G(n,p_n))\le A\log n\bigr)\to1,
$$

where $L_1$ is the number of vertices in the largest connected component.

*Proof sketch.* Couple component exploration from a fixed vertex with a subcritical branching process of mean $1-\varepsilon+o(1)$. Its total progeny has an exponentially decaying tail: for suitable $a>0$,

$$
\Pr(|C(v)|\ge k)\le e^{-ak}.
$$

By the union bound over all $n$ starting vertices,

$$
\Pr(L_1\ge k)
\le ne^{-ak}.
$$

Choosing $k=A\log n$ with $A>1/a$ makes the right-hand side tend to zero.

### 6.3 Supercritical regime

**Theorem 6.2 (Emergence of a giant component).** Fix $\varepsilon>0$ and set

$$
p_n=\frac{1+\varepsilon}{n}.
$$

There exists $\beta=\beta(\varepsilon)>0$ such that

$$
\Pr\bigl(L_1(G(n,p_n))\ge\beta n\bigr)\to1.
$$

*Proof sketch.* The exploration process is compared with a supercritical branching process of mean $1+\varepsilon$. Its survival probability is positive. Consequently, a positive fraction of vertices have explorations that reach a mesoscopic size. A second-moment concentration argument controls the number of such vertices. A sprinkling argument—exposing a small additional independent set of edges—joins the large pieces into one linear-sized component.

The asymptotic fraction has a more precise description.

**Theorem 6.3 (Size and uniqueness of the supercritical giant).** Let $\varepsilon>0$, and let $\rho\in(0,1)$ be the positive solution of

$$
\rho=1-e^{-(1+\varepsilon)\rho}.
$$

Then, with high probability, $G(n,(1+\varepsilon)/n)$ has a unique component of size

$$
(\rho+o(1))n,
$$

and every other component has logarithmic size.

*Proof sketch.* The fixed-point equation is the survival equation for a Poisson Galton–Watson process with mean $1+\varepsilon$. Local exploration identifies $\rho$ as the limiting proportion of vertices belonging to large components. Concentration gives total mass $(\rho+o(1))n$. Sprinkling connects all mesoscopic pieces with high probability, proving uniqueness, while the residual graph behaves subcritically and has only logarithmic components.

## 7. Algorithms and numerical study

### 7.1 Sampling

To sample $G(n,p)$, iterate through all $\binom n2$ unordered vertex pairs and include each edge when an independent uniform random number is below $p$. This requires $O(n^2)$ random trials and, with adjacency lists, $O(n+m)$ storage for a graph with $m$ realized edges.

### 7.2 Component analysis

Breadth-first search or depth-first search labels every connected component in $O(n+m)$ time. One pass returns the largest component size, the number of components, the number of isolated vertices, and connectivity. Triangle counts can be obtained by checking all triples in $O(n^3)$ time; more sophisticated adjacency-intersection methods improve performance for sparse graphs.

### 7.3 Monte Carlo estimators

For independent samples $G_1,\ldots,G_R$, the estimator

$$
\widehat q=\frac1R\sum_{r=1}^R\mathbf1_{\{G_r\text{ connected}\}}
$$

is unbiased for the connectivity probability, with standard error

$$
\sqrt{\frac{q(1-q)}{R}}
\le\frac{1}{2\sqrt R}.
$$

Similarly, averaging $L_1(G_r)/n$ estimates the expected giant fraction, and averaging isolated-vertex or triangle counts tests exact first-moment formulas.

At $p=(\log n+c)/n$, one compares $\widehat q$ with $e^{-e^{-c}}$. At $p=\lambda/n$, one plots the largest-component fraction against $\lambda$. The finite-size curves smooth the asymptotic transitions but become steeper as $n$ increases.

## 8. Applications

In communication networks, the giant-component transition marks the onset of extensive mutual reachability, whereas the connectivity threshold marks universal service. The gap between average degree $1$ and average degree $\log n$ quantifies the cost of including rare peripheral devices.

In epidemic models on static contact networks, the supercritical component supplies a substrate on which an outbreak may affect a positive fraction of the population. The branching-process approximation has a direct epidemiological interpretation: its mean offspring determines whether early transmission chains usually die out.

In distributed systems, isolated vertices model uncontactable agents. The Poisson connectivity window predicts the residual count of such agents and thereby estimates failure probabilities. The limit $e^{-e^{-c}}$ gives a calibrated design curve rather than merely an order-of-magnitude threshold.

Subgraph counts detect motifs, vulnerabilities, and local redundancy. The first moment certifies that a motif is absent in sparse regimes; the second moment proves its presence once overlaps no longer cause excessive variance.

## 9. Discussion and limitations

The finite-sum framework cleanly separates universal probabilistic principles from graph-specific asymptotics. Normalization, prescribed-edge probabilities, expected counts, and moment inequalities apply to arbitrary finite families of potential edges. Connectivity and giant components require additional structure: Poisson convergence for rare isolated vertices, enumeration of cuts, and branching-process coupling.

The variance condition $\operatorname{Var}(X_n)=O(\mathbb E[X_n])$ is sufficient but not necessary. Some pattern counts occur with high probability even when their variance grows faster, provided it remains $o((\mathbb E[X_n])^2)$. The more general conclusion follows directly from Theorem 4.1.

The two headline thresholds should not be conflated. At $p=(1+\varepsilon)/n$, a giant exists but the graph has many vertices outside it. Connectivity requires the additional logarithmic factor. The governing obstruction also changes: survival of local exploration controls the giant, while isolated vertices control connectivity.

## 10. Future directions

A complete refinement of the connectivity window should quantify error rates in the Poisson approximation, for example through Stein–Chen bounds. This would turn the limiting expression into finite-$n$ confidence estimates.

For component structure, natural next steps include proving the precise giant fraction, uniqueness, and logarithmic bounds for all smaller components uniformly in $\varepsilon$. The critical window $p=1/n+\lambda n^{-4/3}$ is especially rich: component sizes are then of order $n^{2/3}$ and converge after rescaling to a nontrivial continuum limit.

For a fixed finite graph $H$, the general appearance threshold is governed by $m(H)$. Strictly balanced graphs at their critical scale exhibit Poisson copy counts. Establishing these laws systematically requires organizing overlap types and their covariance contributions.

Other directions include directed and bipartite random graphs, inhomogeneous edge probabilities, random geometric graphs, resilience under adversarial deletion, and dynamic graph processes in which edges arrive over time. Each asks how much of the moment-and-exploration toolkit survives when independence or symmetry is weakened.

## 11. Conclusion

The Erdős–Rényi model turns independent edge decisions into precise collective transitions. Its finite probability law yields exact prescribed-edge probabilities. Linearity and the union bound convert these into first-moment nonexistence results. Variance supplies a complementary second-moment route to occurrence. Branching-process exploration identifies $p=1/n$ as the birth scale of a giant component, while Poisson convergence of isolated vertices identifies $p=(\log n)/n$ as the sharp connectivity scale, with limiting probability $e^{-e^{-c}}$ throughout the critical window.

These results illustrate a broad principle: global thresholds often arise from a small set of local witnesses or obstructions. Counting those objects, understanding their dependence, and controlling their fluctuations reveals when a random network changes its qualitative character.

## Appendix: interpretation of asymptotic statements

The limiting theorems compare sequences of probability spaces whose sample spaces change with $n$. A statement such as $L_1\ge\beta n$ with high probability means that for every $\delta>0$ there is $n_0$ such that the event has probability at least $1-\delta$ whenever $n\ge n_0$. It does not claim that every sampled graph has the property.

Likewise, convergence in distribution of $I_n$ to a Poisson variable means that for each fixed nonnegative integer $j$,

$$
\Pr(I_n=j)\longrightarrow e^{-e^{-c}}\frac{e^{-cj}}{j!}.
$$

Taking $j=0$ produces the connectivity profile after non-isolated disconnected graphs are shown to be negligible. The phrase “sharp threshold” refers to the fact that an additive displacement of order $1/n$ around $(\log n)/n$ changes the limiting probability by a nontrivial amount, while displacements larger than this window drive the probability toward $0$ or $1$.
