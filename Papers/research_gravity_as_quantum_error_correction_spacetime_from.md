# Code Distance as Graph Geodesic: Capacity Identities, a Five-Qubit Radial Model, and Limits of Geometric Reconstruction

**Aristotle**  
**July 25, 2026**

## Abstract

Quantum error correction offers a precise language for redundancy, erasure tolerance, and logical information, while discrete geometry offers shortest paths, cuts, and incidence. Connecting these languages requires an explicit dictionary rather than an identification by analogy. This paper studies an exact metric realization of a quantum stabilizer code: an undirected graph with distinguished vertices whose graph distance equals the code distance. Under this hypothesis, the quantum Singleton inequality $2d+k\le n+2$ transports directly to the geometric capacity inequality $2\operatorname{dist}_G(s,t)+k\le n+2$. Singleton saturation transports to equality, and, relative to an exact realization, the geometric equality is equivalent to saturation. For the perfect $[[5,1,3]]$ code, the path on four vertices gives a minimal radial realization: its endpoints have distance three, and the saturated identity is $2\cdot3+1=5+2$. This metric model is not the standard Tanner graph. The latter has five variable vertices and four check vertices, hence nine vertices, and cannot be isomorphic to the four-vertex path. Finally, if $n=2\operatorname{dist}_G(s,t)+\delta$, then $k\le\delta+2$, so bounded geometric defect forces bounded logical capacity and positive asymptotic rate forces extensive defect. These results isolate what code parameters alone can establish, and what additional local, entropic, and causal data are required for a genuine reconstruction of bulk geometry.

## 1. Introduction

The relation between quantum error correction and holographic geometry is often expressed through a compelling intuition: bulk information is encoded redundantly in boundary degrees of freedom, so the resilience of the encoding resembles the geometric protection of a bulk region. Tensor-network models sharpen this intuition by placing tensors on a graph and interpreting paths or cuts as geometric objects. Yet several distinct claims can hide inside the phrase “geometry emerges from a code.”

At least four levels should be separated.

1. A numerical code distance may equal a shortest-path length in a chosen graph.
2. A coding bound may become a geometric inequality after this equality is imposed.
3. An entire code-incidence graph may be isomorphic to a proposed bulk graph.
4. Code data may determine a spacetime, including regional entropy, causal order, metric signature, and a continuum limit.

The first statement is a metric dictionary. The second is a transported inequality. The third is a graph-theoretic identification. The fourth is a reconstruction principle. None follows automatically from the preceding one.

This paper establishes the first two statements under explicit assumptions, gives a complete finite example, and disproves a natural instance of the third by cardinality. The point is not merely cautionary. Isolating the assumptions turns a broad physical slogan into a sequence of testable mathematical questions.

The central coding constraint is the quantum Singleton bound. A stabilizer code with parameters $[[n,k,d]]$ obeys

$$
2d+k\le n+2.
$$

Here $n$ is the number of physical qubits, $k$ is the number of logical qubits, and $d$ is the minimum distance. This is the quantum stabilizer inequality, not the classical formula $d\le n-k+1$.

The geometric input is an undirected graph $G$ with two distinguished vertices $s$ and $t$. The graph is an exact metric realization when

$$
\operatorname{dist}_G(s,t)=d.
$$

The resulting geometric Singleton inequality is then

$$
2\operatorname{dist}_G(s,t)+k\le n+2.
$$

Although the proof is substitution, the statement has methodological force: it places the hidden metric assumption in full view. Equality occurs precisely when the original code saturates Singleton, provided the same exact dictionary is retained.

The $[[5,1,3]]$ code supplies the finite case study. A path with four vertices has endpoint distance three, so it realizes the code distance and satisfies the exact budget $2\cdot3+1=7$. The standard Tanner presentation, however, has nine vertices—five variable nodes and four check nodes—and therefore cannot be this four-vertex path. The radial path is a realization of one distance, not a literal representation of all code incidence.

The final result recasts Singleton as a defect-capacity law. If

$$
n=2\operatorname{dist}_G(s,t)+\delta,
$$

then

$$
k\le\delta+2.
$$

Thus a family with positive logical rate must possess macroscopic defect. This necessary condition provides a useful target for more structured models in which defect could be connected to branching, area, or volume.

## 2. Coding and graph-theoretic preliminaries

### 2.1 Quantum stabilizer parameters

A quantum stabilizer code with parameters $[[n,k,d]]$ encodes a logical Hilbert space of dimension $2^k$ into a physical Hilbert space of dimension $2^n$. The minimum distance $d$ is the minimum weight of a nontrivial logical Pauli operator; equivalently, it controls the code’s ability to detect and correct localized errors. For the present argument, only the integer parameters and the quantum Singleton constraint are required.

**Definition 2.1 (Singleton-valid code).** A parameter triple $[[n,k,d]]$ is Singleton-valid when

$$
2d+k\le n+2.
$$

**Definition 2.2 (Singleton saturation).** A Singleton-valid triple is saturated when

$$
2d+k=n+2.
$$

A saturated quantum code is often called quantum maximum-distance separable in the parameter sense. Saturation is stronger than validity and will be exactly the condition that upgrades the transported geometric bound to an identity.

### 2.2 Graph distance

Let $G=(V,E)$ be a finite or infinite undirected simple graph. A walk from $s\in V$ to $t\in V$ is a finite sequence of adjacent vertices beginning at $s$ and ending at $t$. Its length is the number of traversed edges. If $s$ and $t$ are connected, their graph distance is

$$
\operatorname{dist}_G(s,t)
=
\min\{L:\text{there is a walk of length }L\text{ from }s\text{ to }t\}.
$$

Graph distance is combinatorial. It does not by itself provide edge lengths other than one, causal orientation, Lorentzian signature, or curvature.

**Definition 2.3 (Exact metric realization).** Let a code have parameters $[[n,k,d]]$. An exact metric realization consists of a graph $G$ and distinguished vertices $s,t\in V(G)$ such that

$$
\operatorname{dist}_G(s,t)=d.
$$

The adjective “exact” emphasizes equality. A weaker dictionary could give only upper or lower bounds, but those would transport the Singleton inequality differently. The present results concern exact realizations.

This definition deliberately asks for only one distinguished separation. It does not assert that all graph distances encode code-theoretic quantities, that $G$ is a Tanner graph, or that $G$ approximates a manifold.

### 2.3 Tanner presentations

A Tanner graph records incidence between physical variables and constraints. It is bipartite: one part contains variable vertices and the other contains check vertices. For an $[[n,k,d]]$ stabilizer code with $n-k$ independent stabilizer generators, the standard presentation contains $n$ variable vertices and $n-k$ check vertices, although alternative redundant presentations may contain more checks.

For the $[[5,1,3]]$ code, a standard independent presentation has five variable vertices and four check vertices, hence nine vertices in total. The edge relation depends on which qubits are acted upon by which checks, but the total cardinality does not.

## 3. Transporting Singleton into geometry

The basic bridge can now be stated without ambiguity.

**Theorem 3.1 (Geometric Singleton bound).** Let an $[[n,k,d]]$ stabilizer code satisfy the quantum Singleton inequality. Let $G$ be a graph with distinguished vertices $s$ and $t$ forming an exact metric realization. Then

$$
2\operatorname{dist}_G(s,t)+k\le n+2.
$$

**Proof sketch.** Singleton validity gives $2d+k\le n+2$. Exact metric realization gives $\operatorname{dist}_G(s,t)=d$. Substitution yields the stated inequality. $\square$

The theorem is conditional in a precise sense. Coding theory supplies the inequality, while the model builder supplies the metric dictionary. Parameters alone do not select $G$, $s$, or $t$.

**Theorem 3.2 (Saturated geodesic-capacity identity).** Under the same exact metric realization, if the code saturates the quantum Singleton bound, then

$$
2\operatorname{dist}_G(s,t)+k=n+2.
$$

**Proof sketch.** Replace $d$ by $\operatorname{dist}_G(s,t)$ in the saturation equation $2d+k=n+2$. $\square$

The converse is equally important because it identifies the exact role of saturation.

**Theorem 3.3 (Equality-saturation equivalence).** Fix an exact metric realization of an $[[n,k,d]]$ code. Then

$$
2\operatorname{dist}_G(s,t)+k=n+2
$$

if and only if

$$
2d+k=n+2.
$$

**Proof sketch.** The realization equality makes the two left-hand sides identical. Therefore either equality holds exactly when the other does. $\square$

This theorem does not identify Singleton saturation with a general entropy formula. It identifies one global arithmetic equality with one global geometric-capacity equality. A regional entropy $S(A)$ depends on a boundary region $A$ and generally requires information not contained in $n$, $k$, and $d$. In particular, the access structure of logical observables and the reduced states of regions are invisible to the parameter triple.

### 3.1 Inequality versus area-like equality

Suppose one hopes to compare a code relation with a schematic area law. Theorems 3.1–3.3 impose two requirements. First, a geometric quantity must be explicitly identified with $d$. Second, equality requires Singleton saturation. Without the first, there is no metric bridge; without the second, there is only an upper bound.

Even with both requirements, the conclusion remains a capacity identity rather than a full Ryu–Takayanagi law. A regional entropy law would require, for each suitable boundary region $A$, a corresponding minimal surface or cut $\gamma_A$ and a proof that the entropy depends on its area together with any bulk correction. A single distinguished graph distance does not provide this family of regional statements.

## 4. The finite radial model for the five-qubit code

### 4.1 Construction

Consider the path graph $P_4$ with vertex set

$$
V(P_4)=\{0,1,2,3\}
$$

and edge set

$$
E(P_4)=\bigl\{\{0,1\},\{1,2\},\{2,3\}\bigr\}.
$$

Choose $s=0$ and $t=3$. This graph may be pictured as a radial chain with four stations and three unit links.

To determine its endpoint distance, both an upper bound and a lower bound are needed. Listing the obvious route proves only that the distance is at most three; minimality requires excluding shorter walks.

**Lemma 4.1 (Displacement bound on a path).** Let $P_n$ be the path graph on vertices $0,1,\ldots,n-1$. If a walk of length $L$ begins at $u$ and ends at $v$, then

$$
v\le u+L.
$$

**Proof sketch.** Proceed by induction on the number of edges. For $L=0$, the walk is stationary, so $v=u$. For the inductive step, remove the first edge. Adjacent labels in a path differ by one. The remaining walk satisfies the inductive bound, and restoring the removed edge changes the available upper bound by at most one. Equivalently, each step can increase the current label by no more than one, so total positive displacement is at most the number of steps. $\square$

A symmetric argument gives $u\le v+L$, and hence $|v-u|\le L$, but the one-sided form suffices.

**Theorem 4.2 (Endpoint distance of the four-vertex radial chain).** In $P_4$,

$$
\operatorname{dist}_{P_4}(0,3)=3.
$$

**Proof sketch.** The walk $0,1,2,3$ has length three, proving the distance is at most three. Conversely, Lemma 4.1 applied to any walk from $0$ to $3$ gives $3\le0+L$, so every such walk has length at least three. The upper and lower bounds coincide. $\square$

This proof avoids relying on finite enumeration. The lower-bound argument works uniformly for every possible walk, including walks that backtrack.

### 4.2 Metric realization and saturation

The perfect five-qubit code has parameters $[[5,1,3]]$. Theorem 4.2 immediately yields the realization result.

**Theorem 4.3 (Five-qubit radial metric realization).** The graph $P_4$ with distinguished endpoints $0$ and $3$ exactly realizes the distance of the $[[5,1,3]]$ code:

$$
\operatorname{dist}_{P_4}(0,3)=d=3.
$$

**Proof sketch.** The code parameter is $d=3$, and Theorem 4.2 computes the endpoint distance as three. $\square$

The five-qubit parameters saturate Singleton because

$$
2d+k=2\cdot3+1=7=5+2=n+2.
$$

Combining this arithmetic with exact metric realization gives the complete finite identity.

**Theorem 4.4 (Five-qubit geodesic saturation).** For the radial realization of the $[[5,1,3]]$ code,

$$
\operatorname{dist}_{P_4}(0,3)=3
$$

and

$$
2\operatorname{dist}_{P_4}(0,3)+1=5+2.
$$

**Proof sketch.** The first equality is Theorem 4.2. Substitute it into the left-hand side of the second equality to obtain $2\cdot3+1=7$. $\square$

The model is minimal among unweighted paths realizing distance three: any path whose endpoints are three edges apart must contain the four vertices encountered along a shortest path. This minimality concerns the radial path model; it does not say that all geometric realizations have four vertices, since a larger graph can also contain two vertices at distance three.

## 5. A cardinality obstruction to literal Tanner-graph identity

Metric agreement does not imply graph isomorphism. The distinction is decisive in the five-qubit example.

Let the variable-vertex set be a five-element set $Q$, and let the independent check-vertex set be a four-element set $C$. The standard Tanner vertex set is the disjoint union

$$
Q\sqcup C,
$$

whose cardinality is

$$
|Q\sqcup C|=|Q|+|C|=5+4=9.
$$

The radial path has vertex set $\{0,1,2,3\}$ of cardinality four.

**Theorem 5.1 (Vertex-cardinality obstruction).** There is no bijection between the vertex set of the standard five-qubit Tanner presentation and the vertex set of $P_4$.

**Proof sketch.** A bijection between finite sets preserves cardinality. The two cardinalities are nine and four, which are unequal. $\square$

**Corollary 5.2 (No Tanner-to-radial graph isomorphism).** For every choice of Tanner incidence relation on the standard five-variable, four-check vertex set, the resulting graph is not isomorphic to $P_4$.

**Proof sketch.** A graph isomorphism induces a bijection of vertex sets. Theorem 5.1 rules out such a bijection before edge incidence is considered. $\square$

The corollary is independent of which stabilizer generators are chosen, provided the presentation has the stated five variable and four check vertices. It does not claim that no derived construction, quotient, embedding, coarse-graining, or dual graph can relate the Tanner presentation to a radial geometry. It says that literal graph isomorphism to this four-vertex path is impossible.

This distinction clarifies the status of a Penrose-diagram analogy. A Penrose diagram encodes causal and conformal structure. The radial graph $P_4$ is undirected and contains only adjacency and shortest-path data. Even apart from cardinality, it lacks null directions, time orientation, causal order, and conformal boundary structure. Calling it a Penrose diagram would therefore assert much more than the construction supplies.

## 6. Geometric defect and logical capacity

The transported Singleton inequality can be reorganized into a useful capacity law.

**Definition 6.1 (Geometric defect).** For an exact metric realization, a nonnegative integer $\delta$ is a geometric defect when

$$
n=2\operatorname{dist}_G(s,t)+\delta.
$$

Thus $\delta$ measures the excess of physical boundary size over twice the realized geodesic length.

**Theorem 6.2 (Defect-capacity bound).** Let an $[[n,k,d]]$ code be Singleton-valid and let $(G,s,t)$ be an exact metric realization. If

$$
n=2\operatorname{dist}_G(s,t)+\delta,
$$

then

$$
k\le\delta+2.
$$

**Proof sketch.** The geometric Singleton bound gives

$$
2\operatorname{dist}_G(s,t)+k\le n+2.
$$

Replace $n$ by $2\operatorname{dist}_G(s,t)+\delta$ and cancel the common term $2\operatorname{dist}_G(s,t)$. $\square$

For the five-qubit radial model,

$$
\delta=5-2\cdot3=-1,
$$

which is not a nonnegative defect under Definition 6.1. This illustrates why the additive constant $2$ in the quantum Singleton relation matters: saturation permits $n$ to be two less than $2d+k$. For applications requiring a nonnegative excess, one should either restrict to models where $n\ge2\operatorname{dist}$ or use the shifted defect

$$
\Delta=n+2-2\operatorname{dist}_G(s,t),
$$

for which Singleton states simply $k\le\Delta$. Theorem 6.2 retains the unshifted convention because it isolates the universal additive allowance of two.

### 6.1 Asymptotic consequence

Consider a sequence of Singleton-valid codes $[[n_i,k_i,d_i]]$ with exact metric realizations and defects $\delta_i\ge0$. If there is a constant $D$ such that $\delta_i\le D$ for every $i$, then Theorem 6.2 gives

$$
k_i\le D+2.
$$

If $n_i\to\infty$, it follows that

$$
\frac{k_i}{n_i}\longrightarrow0.
$$

Conversely, suppose the logical rates are bounded below: there exists $r>0$ such that $k_i/n_i\ge r$. Then

$$
\delta_i\ge k_i-2\ge rn_i-2.
$$

Hence

$$
\liminf_{i\to\infty}\frac{\delta_i}{n_i}\ge r.
$$

Positive rate therefore forces extensive geometric defect. This is a parameter obstruction, not yet a branching theorem. To infer a positive density of branching vertices from extensive defect, one would need graph hypotheses such as planarity, bounded degree, locality, and control over how boundary size is represented.

## 7. Algorithms and computational diagnostics

The results support simple diagnostics for finite proposed realizations.

### 7.1 Exact metric-realization test

Given an unweighted graph, source $s$, target $t$, and code parameters $[[n,k,d]]$, breadth-first search computes $\ell=\operatorname{dist}_G(s,t)$. The realization is exact precisely when $\ell=d$. The geometric Singleton margin is

$$
M=n+2-(2\ell+k).
$$

A negative margin contradicts Singleton validity together with exact realization. A zero margin indicates saturation relative to the dictionary. A positive margin measures slack.

Breadth-first search takes time $O(|V|+|E|)$ and memory $O(|V|)$ with adjacency lists.

### 7.2 Cardinality prefilter for graph identity

Before attempting graph isomorphism, compare vertex counts and edge counts. Unequal vertex cardinalities immediately rule out isomorphism in constant time once metadata are known. For the standard five-qubit Tanner presentation and $P_4$, the counts $9$ and $4$ terminate the test without inspecting edges. Equal cardinality would not prove isomorphism; it would only remove the simplest obstruction.

### 7.3 Rate-defect diagnostic

For a family of proposed realizations, compute

$$
\delta_i=n_i-2\ell_i
$$

whenever this is nonnegative, and compare $k_i$ with $\delta_i+2$. Plotting $k_i/n_i$ against $\delta_i/n_i$ makes the asymptotic obstruction visible. Under exact realization and Singleton validity, points must satisfy

$$
\frac{k_i}{n_i}\le\frac{\delta_i}{n_i}+\frac{2}{n_i}.
$$

The finite-size correction vanishes as $n_i$ grows.

## 8. Physical interpretation and limitations

### 8.1 What is established

The exact metric dictionary transports a coding constraint into a geometric one. This gives a mathematically controlled sense in which error-correction distance can act as geodesic length. Saturation then characterizes equality of the global capacity budget.

The five-qubit example demonstrates nontrivial numerical agreement in the smallest perfect code. It also demonstrates that a metric realization can be much smaller than a Tanner presentation because the former is designed to preserve a selected distance, whereas the latter records variable-check incidence.

The defect-capacity theorem adds an asymptotic constraint. Positive information density requires extensive excess over twice the realized distance. Any proposed emergent geometry for a positive-rate code family must accommodate that excess somewhere in its combinatorics.

### 8.2 What is not established

The parameter triple $[[n,k,d]]$ does not determine an entropy profile. Entropy depends on states and subsystems; distance records a minimum logical support. Therefore Singleton saturation alone cannot imply a regional Ryu–Takayanagi formula.

A graph metric does not determine curvature uniquely. Many nonisomorphic graphs can contain a selected pair at the same distance. Even a complete distance matrix determines only a finite metric space, not automatically a smooth negatively curved manifold.

An undirected Tanner graph does not determine causality. Causal structure requires directed or ordered data. Logical-operator supports and inclusions among correctable regions may provide such data, but this is an additional proposal.

Finally, a finite path is not a Penrose diagram. The path has no null cones, conformal compactification, or time orientation. It is best understood as a radial metric toy model.

## 9. Future research

### 9.1 Rigidity of local tensor-network realizations

A natural conjecture is that a family of bounded-degree stabilizer tensor networks with boundary length $n$, exact complementary recovery, graph distance equal to code distance, Singleton saturation at every scale, and a uniform local tensor type has rescaled shortest-path metrics converging along a subsequence to a negatively curved geodesic metric.

Singleton saturation supplies only a global budget. Bounded degree, locality, uniform tensors, and complementary recovery are plausible sources of rigidity. The conjecture should be tested against explicit network families, including families engineered to saturate the global bound while developing flat or highly inhomogeneous local structure.

### 9.2 Entropic equality beyond Singleton saturation

A second conjecture predicts two stabilizer encodings with identical $[[n,k,d]]$ parameters and saturated Singleton bounds but different entropy profiles for some boundary regions. Such a pair would show directly that no regional entropy law follows from global Singleton parameters alone.

The construction problem is concrete: preserve the global parameters while changing the regional access structure or entanglement. Candidate searches can compare reduced-state entropies across inequivalent stabilizer codes with matched parameters.

### 9.3 Minimal additional data for a causal bulk

A third conjecture is that a finite stabilizer Tanner graph, graph distance, and logical-operator supports do not uniquely determine a causal partial order, whereas adjoining a compatible family of correctable boundary regions may determine one up to reversal under an acyclicity condition.

The motivation is structural. Incidence and distance are undirected, while causal order is directed. Inclusion relations among recoverable regions provide a natural source of orientation. A successful theorem would need to define compatibility, acyclicity, and equivalence of reconstructed orders precisely.

### 9.4 Positive rate and branching density

The parameter argument proves that positive logical rate forces macroscopic metric defect. With planar bounded-degree realizations, one may conjecture that extensive defect forces a positive density of branching vertices. This would convert a global coding obstruction into a local geometric signature.

Proving such a statement requires a combinatorial inequality relating boundary size, distinguished geodesic length, and branching. Trees, planar disk graphs, and hyperbolic tilings provide natural initial classes.

## 10. Discussion

The main conceptual result is a hierarchy of claims. Exact distance realization is weaker than graph identity; graph identity is weaker than spacetime reconstruction. The quantum Singleton inequality can cross the first bridge cleanly, but it cannot cross the others unaided.

This hierarchy prevents two opposite errors. One error is overstatement: treating a shared integer distance as proof that a Tanner graph is a spacetime or that a capacity equality is an entropy formula. The other is understatement: dismissing code-geometry analogies because they do not immediately yield a continuum bulk. The transported inequality is a genuine structural relation, and its saturation and asymptotic consequences are mathematically informative.

The five-qubit model captures both lessons. The path $P_4$ realizes distance three exactly and displays the saturated budget. At the same time, the nine-versus-four vertex count rules out literal equality with the standard Tanner graph. The correct interpretation is therefore functorial or coarse-grained: a geometric construction may preserve selected code invariants without preserving the entire underlying graph.

Future progress should specify the preserved data. For entropy, that data may be a family of cuts and regional reduced states. For causality, it may be an order induced by recovery inclusions. For curvature, it may be scale-consistent local growth and metric convergence. The code parameters provide boundary conditions on such reconstructions, not a unique reconstruction by themselves.

## 11. Conclusion

An explicit metric dictionary converts the quantum Singleton bound into a geodesic capacity inequality:

$$
2\operatorname{dist}_G(s,t)+k\le n+2.
$$

Under exact realization, equality holds exactly when the code saturates Singleton. The $[[5,1,3]]$ code admits a four-vertex radial realization with endpoint distance three and saturated budget $2\cdot3+1=5+2$. Nevertheless, its standard nine-vertex Tanner presentation cannot be isomorphic to that radial chain. More generally, if $n=2\operatorname{dist}_G(s,t)+\delta$ with $\delta\ge0$, then $k\le\delta+2$, forcing extensive defect in positive-rate families.

These results establish a precise bridge from code distance to graph geometry while marking its boundary. They support a program in which locality, recovery structure, entropy data, and causal orientation are added explicitly, allowing the emergence of geometry to become a sequence of well-posed reconstruction problems rather than a single metaphor.
