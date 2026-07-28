# Strange Attractors as Algebraic Objects: Finite de Bruijn Approximants and a Binary Prefix Inverse Limit

**Author:** Aristotle  
**Date:** 2026-07-28

## Abstract

We develop a finite directed-graph model for symbolic trajectories and prove that its inverse limit retains every infinite binary itinerary without identification. At level $n$, the vertices are binary words of length $n$, so the level has exactly $2^n$ vertices. Dynamics is represented by the binary de Bruijn edge relation: a word points to another when its suffix agrees with the other's prefix. Deleting the final symbol defines a bonding map between consecutive levels, and we prove that this map preserves directed edges. The inverse limit consists of families of words compatible under all truncations. Sending an infinite binary stream to its family of finite prefixes is injective; consequently, the inverse limit contains a full binary Cantor family and is infinite. We give proofs, algorithms, examples, and applications to symbolic dynamics, while carefully distinguishing this general prototype from any Lorenz-specific identification. The construction provides the finite combinatorial substrate needed for later topological, cohomological, and dynamical comparisons with strange attractors.

## 1. Introduction

Strange attractors unite deterministic evolution with apparent unpredictability. A smooth map or differential equation may be specified by a short formula, while its long-term orbits create folded, recurrent structures that resist direct classification. Numerical plots reveal geometry, but a structural theory asks different questions: which finite observations are compatible, how do observations at different resolutions relate, and can an infinite trajectory be recovered from all of its finite records?

Symbolic dynamics addresses these questions by replacing points in phase space with itineraries through a finite partition. In the simplest case there are two regions, labeled $0$ and $1$, and an orbit is encoded by a stream in $\{0,1\}^{\mathbb N}$. A finite observer sees only a word of bounded length. The natural combinatorial object for these observations is a de Bruijn graph, whose vertices are finite words and whose directed edges represent one-step shifts of the observation window.

This paper constructs a tower of binary de Bruijn graphs linked by truncation. The tower is an inverse system at the level of vertices and edge-preserving maps. Its inverse limit is the set of coherent finite observations at all depths. Our main result states that each infinite binary stream determines a different point of this limit. Thus the infinite symbolic space is faithfully retained by a system assembled entirely from finite levels.

The result is foundational rather than Lorenz-specific. It does not claim that the Lorenz attractor, Hénon attractor, or Rössler attractor is the inverse limit considered here. Such a theorem would require a precise map or flow, a justified symbolic partition, and a comparison of topology and dynamics. What is established is the abstract mechanism on which that program can be built.

The contributions are:

1. a count of exactly $2^n$ states at binary resolution $n$;
2. a finite directed-graph encoding of sliding-window dynamics;
3. an edge-preserving truncation map between consecutive graph levels;
4. an inverse limit of compatible prefixes;
5. an injective encoding of all infinite binary streams into that limit; and
6. explicit finite algorithms for graph generation, compatibility checking, and trajectory separation.

## 2. Binary words and finite graph levels

### 2.1 Binary words

Let

$$
\mathbb B=\{0,1\}.
$$

For $n\in\mathbb N$, define the set of binary words of length $n$ by

$$
W_n=\mathbb B^{\{0,1,\ldots,n-1\}}.
$$

An element $w\in W_n$ is written

$$
w=(w_0,w_1,\ldots,w_{n-1}), \qquad w_i\in\mathbb B.
$$

The unique word of length $0$ is the empty word $()$.

**Theorem 2.1 (Finite-level cardinality).** For every $n\in\mathbb N$,

$$
|W_n|=2^n.
$$

**Proof sketch.** Each of the $n$ coordinates can be chosen independently from the two-element set $\mathbb B$. By the multiplication principle, there are $2\cdot 2\cdots 2=2^n$ choices. Equivalently, the set of functions from an $n$-element index set to a two-element alphabet has cardinality $2^n$. For $n=0$, both sides equal $1$. $\square$

This count makes every approximation finite while allowing exponential growth of distinguishable histories with observation depth.

### 2.2 Binary de Bruijn graphs

For $n\in\mathbb N$, define the directed graph $G_n$ to have vertex set $W_{n+1}$. For $u,v\in W_{n+1}$, place a directed edge $u\to v$ when

$$
u_{i+1}=v_i \qquad \text{for every } 0\le i<n.
$$

Thus the suffix of $u$ of length $n$ equals the prefix of $v$ of length $n$. This is the binary de Bruijn graph of order $n+1$.

The indexing separates two roles. The graph $G_n$ records windows of length $n+1$, while $W_n$ will serve as level $n$ of the prefix inverse system. One could shift all indices by one without changing the mathematics.

**Example 2.2.** In $G_2$, vertices are words of length $3$. There is an edge

$$
010\longrightarrow 101
$$

because the suffix $10$ of $010$ equals the prefix $10$ of $101$. There is no edge $010\to 111$, since $10\ne 11$.

**Lemma 2.3 (Successor description).** Every vertex

$$
u=(u_0,u_1,\ldots,u_n)
$$

of $G_n$ has exactly two outgoing neighbors,

$$
(u_1,u_2,\ldots,u_n,0)
\quad\text{and}\quad
(u_1,u_2,\ldots,u_n,1),
$$

and exactly two incoming neighbors,

$$
(0,u_0,u_1,\ldots,u_{n-1})
\quad\text{and}\quad
(1,u_0,u_1,\ldots,u_{n-1}).
$$

**Proof sketch.** The overlap equations determine all but the newly appended symbol of an outgoing neighbor, leaving exactly two binary choices. The incoming statement is symmetric: all but the newly prepended symbol are fixed. $\square$

This lemma is included to explain the graph algorithmically; the principal inverse-limit results below require only the defining overlap relation.

## 3. Truncation as a bonding map

For $n\in\mathbb N$, define the truncation map

$$
\tau_n:W_{n+1}\longrightarrow W_n
$$

by deleting the final symbol:

$$
\tau_n(w_0,w_1,\ldots,w_n)=(w_0,w_1,\ldots,w_{n-1}).
$$

At $n=0$, this map sends either one-letter word to the empty word.

Truncation links adjacent observation scales. It is surjective: every word $w\in W_n$ has two extensions, $(w,0)$ and $(w,1)$. More importantly for the graph structure, truncation respects edges.

**Theorem 3.1 (Edge preservation under truncation).** Let $n\in\mathbb N$, and let $u,v\in W_{n+2}$. If $u\to v$ in $G_{n+1}$, then

$$
\tau_{n+1}(u)\to\tau_{n+1}(v)
$$

in $G_n$.

**Proof.** Write

$$
u=(u_0,u_1,\ldots,u_{n+1}),
\qquad
v=(v_0,v_1,\ldots,v_{n+1}).
$$

The hypothesis $u\to v$ in $G_{n+1}$ says

$$
u_{i+1}=v_i \qquad \text{for every } 0\le i<n+1.
$$

After truncation, the words are

$$
\tau_{n+1}(u)=(u_0,u_1,\ldots,u_n),
$$

and

$$
\tau_{n+1}(v)=(v_0,v_1,\ldots,v_n).
$$

To obtain an edge in $G_n$, it suffices to show

$$
u_{i+1}=v_i \qquad \text{for every } 0\le i<n.
$$

These are among the equalities already supplied by the hypothesis. Therefore truncation sends the given edge to an edge. $\square$

The theorem states that coarse observation is dynamically consistent: a transition permitted at fine resolution remains permitted when the final symbol is forgotten.

**Corollary 3.2 (Iterated edge preservation).** If an edge between words survives at some fine level, then applying any finite sequence of truncations produces an edge at every lower level for which the words remain nonempty windows.

**Proof sketch.** Apply Theorem 3.1 repeatedly. Each application removes one final symbol and preserves the edge relation at the next lower order. $\square$

Consequently, the sequence

$$
\cdots\xrightarrow{\tau_{n+1}}W_{n+1}
\xrightarrow{\tau_n}W_n
\xrightarrow{\tau_{n-1}}\cdots
\xrightarrow{\tau_0}W_0
$$

is not merely a tower of finite sets. When the appropriate de Bruijn structures are placed on consecutive word lengths, its maps preserve directed transitions.

## 4. The binary prefix inverse limit

### 4.1 Compatible threads

**Definition 4.1 (Compatible prefix thread).** A compatible prefix thread is a sequence

$$
x=(x_0,x_1,x_2,\ldots)
$$

such that $x_n\in W_n$ for every $n$ and

$$
\tau_n(x_{n+1})=x_n
\qquad\text{for every }n\in\mathbb N.
$$

**Definition 4.2 (Prefix inverse limit).** The prefix inverse limit is

$$
L=\varprojlim (W_n,\tau_n)
 =\left\{(x_n)_{n\ge 0}:x_n\in W_n
 \text{ and }\tau_n(x_{n+1})=x_n\text{ for all }n\right\}.
$$

An element of $L$ is one object represented coherently at every finite resolution. The compatibility equations imply that whenever $m<n$, the word $x_m$ is obtained by deleting the last $n-m$ symbols of $x_n$.

**Lemma 4.3 (Nested-prefix property).** If $x\in L$ and $m\le n$, then $x_m$ is the length-$m$ prefix of $x_n$.

**Proof sketch.** The compatibility relation handles the case $n=m+1$. Iterating it $n-m$ times deletes the final symbols one at a time, leaving precisely the first $m$ coordinates. $\square$

The inverse limit therefore prohibits arbitrary choices at separate levels. It records a nested chain

$$
()\preceq x_1\preceq x_2\preceq\cdots,
$$

where $\preceq$ means “is a prefix of.”

### 4.2 From streams to threads

Let

$$
\Sigma_2=\mathbb B^{\mathbb N}
$$

be the set of infinite binary streams. For $s=(s_0,s_1,s_2,\ldots)\in\Sigma_2$, define its length-$n$ prefix by

$$
p_n(s)=(s_0,s_1,\ldots,s_{n-1})\in W_n.
$$

Define

$$
\Phi:\Sigma_2\longrightarrow L,
\qquad
\Phi(s)=(p_n(s))_{n\ge 0}.
$$

**Lemma 4.4 (Prefix compatibility).** For every stream $s\in\Sigma_2$, the family $\Phi(s)$ belongs to $L$.

**Proof.** The word $p_{n+1}(s)$ is

$$
(s_0,s_1,\ldots,s_{n-1},s_n).
$$

Deleting its final symbol gives

$$
(s_0,s_1,\ldots,s_{n-1})=p_n(s).
$$

Thus $\tau_n(p_{n+1}(s))=p_n(s)$ for every $n$. $\square$

### 4.3 Separation of trajectories

**Theorem 4.5 (Injective stream representation).** The map

$$
\Phi:\Sigma_2\longrightarrow L
$$

is injective. Equivalently, distinct infinite binary streams determine distinct compatible prefix threads.

**Proof.** Suppose $\Phi(s)=\Phi(t)$. Fix any index $k\in\mathbb N$. Equality of the two threads implies equality of their words at level $k+1$:

$$
p_{k+1}(s)=p_{k+1}(t).
$$

Comparing coordinate $k$ of these two words gives $s_k=t_k$. Since $k$ was arbitrary, the streams agree at every coordinate, hence $s=t$. Therefore $\Phi$ is injective. $\square$

An equivalent contrapositive proof emphasizes finite detection. If $s\ne t$, choose an index $k$ at which they differ. Their prefixes of length $k+1$ then differ, so their inverse-limit threads differ.

**Corollary 4.6 (Infinitude and Cantor family).** The inverse limit $L$ is infinite. More precisely, it contains an injective image of the entire binary stream set $\Sigma_2$.

**Proof.** The set $\Sigma_2$ is infinite; for example, the streams containing a single $1$ at position $k$ and $0$ elsewhere are pairwise distinct as $k$ varies. By Theorem 4.5, their images in $L$ are pairwise distinct. The stronger assertion follows directly from the injectivity of $\Phi$. $\square$

The terminology “Cantor family” refers to the standard fact that $\Sigma_2$, when given the product topology of discrete two-point spaces, is Cantor space. The results above are set-theoretic and combinatorial. They do not yet equip $L$ with a topology or assert that $\Phi$ is a homeomorphism.

### 4.4 The expected reverse map

The nested-prefix property suggests an inverse construction. Given $x\in L$, define a stream by reading the last newly visible coordinate at each level:

$$
\Psi(x)_k=(x_{k+1})_k.
$$

Compatibility implies that every later word $x_n$ with $n>k$ has the same value in coordinate $k$. One therefore expects $\Phi$ and $\Psi$ to be mutually inverse. Establishing this equivalence, and then its topological refinement, is a natural continuation. The present main conclusions require only the proved direction $\Phi$ and its injectivity.

## 5. Algorithms

### 5.1 Enumerating finite levels

To construct $W_n$, enumerate integers $0,1,\ldots,2^n-1$ and write each in binary using exactly $n$ bits. This requires output space $\Theta(n2^n)$, which is unavoidable because there are $2^n$ words and each has length $n$.

A direct construction of all edges compares every ordered pair of vertices and costs $O(n4^{n+1})$. Lemma 2.3 gives a better algorithm: for each word, shift left and append either $0$ or $1$. It produces exactly $2^{n+2}$ directed edges of $G_n$ in time $O(n2^{n+1})$ if words are copied explicitly, or $O(2^{n+1})$ word operations with packed bit representations.

### 5.2 Checking an edge

Given $u,v\in W_{n+1}$, test $u_{i+1}=v_i$ for $0\le i<n$. The running time is $O(n)$ and the extra space is $O(1)$ beyond the input representation.

### 5.3 Checking compatibility

Given a finite candidate thread

$$
(x_0,x_1,\ldots,x_N),
$$

first verify $|x_n|=n$. Then check

$$
x_{n+1}[0:n]=x_n
$$

for every $0\le n<N$. Explicit comparison costs

$$
O\left(\sum_{n=0}^{N-1}n\right)=O(N^2).
$$

If the words are stored persistently so each prefix shares structure with its extension, compatibility can be checked in $O(N)$ link checks.

### 5.4 Finding the separation level

For two finite stream samples $s$ and $t$, scan coordinates until the first disagreement $k$. Their compatible threads agree through level $k$ and first differ at level $k+1$. The scan costs $O(k+1)$ time and constant extra space. If no disagreement appears in the available sample, one may conclude only that the sampled prefixes agree, not that the infinite streams are identical.

## 6. Numerical examples

### 6.1 A periodic stream

Consider the periodic stream

$$
s=01010101\cdots.
$$

Its first six prefixes are

$$
(),\quad (0),\quad (0,1),\quad (0,1,0),\quad
(0,1,0,1),\quad (0,1,0,1,0).
$$

Each prefix truncates to its predecessor. Sliding a window of length $3$ along the stream alternates between vertices $010$ and $101$ of $G_2$, using the edges

$$
010\to101\to010.
$$

Thus a periodic symbolic orbit appears as a directed cycle in a finite de Bruijn graph.

### 6.2 Delayed separation

Let

$$
s=001011\cdots,
\qquad
t=001111\cdots.
$$

The streams first differ at index $3$. Their prefixes agree at levels $0,1,2,$ and $3$:

$$
(),\quad (0),\quad (0,0),\quad (0,0,1).
$$

At level $4$ they become

$$
(0,0,1,0)\ne(0,0,1,1).
$$

This example illustrates the separation theorem: no fixed shallow level need distinguish two streams, but the full tower detects their first disagreement.

### 6.3 Finite-level growth

For depths $n=0$ through $10$, the vertex counts are

$$
1,2,4,8,16,32,64,128,256,512,1024.
$$

The model remains finite at every stage, but increasing depth by one doubles the state count. This exponential cost is the computational price of retaining every unrestricted binary history.

## 7. Applications and interpretation

### 7.1 Symbolic dynamics

A symbolic dynamical system consists of allowed sequences over a finite alphabet together with the left shift

$$
\sigma(s)_i=s_{i+1}.
$$

The full binary shift allows every binary stream. De Bruijn graphs encode the finite windows through which the shift moves: an edge corresponds exactly to deleting the first symbol of a window and appending a new final symbol. The inverse-limit construction uses a different deletion, namely removal of the final symbol, to organize resolutions. These two operations are complementary: one advances time, while the other coarsens observation.

A future conjugacy theorem should define the induced shift on compatible threads and show

$$
\Phi\circ\sigma=\widehat{\sigma}\circ\Phi.
$$

This would promote the current set-theoretic encoding to a dynamical equivalence once the reverse map is established.

### 7.2 Subshifts of finite type

Real systems rarely permit every binary itinerary. A finite transition matrix can forbid selected adjacent symbols or longer blocks, producing a subshift of finite type. The same architecture applies after restricting $W_n$ to admissible words and retaining only admissible overlaps. The principal obligations are then to show that truncation preserves admissibility and to characterize which compatible threads arise.

This extension is essential for applications to attractors. A Markov partition of a dynamical system usually yields a constrained transition graph, not the unrestricted binary shift.

### 7.3 Data reconstruction and sequence assembly

The overlap rule is the same combinatorial mechanism used in sequence assembly. Short observed blocks are vertices or edges, and overlaps indicate possible concatenations. A compatible inverse-limit thread idealizes observations available at every length. Injectivity says that complete nested prefix data uniquely identifies the underlying infinite sequence.

In practical data settings only finitely many noisy observations are available. The exact theory supplies a baseline: ambiguity comes from finite depth, missing observations, or noise, rather than from the coherent prefix representation itself.

### 7.4 Strange attractors

To apply the construction to a strange attractor, one seeks a finite partition of a suitable invariant set. Labeling visited regions produces symbolic itineraries. If the partition is generating, arbitrarily long symbolic records distinguish relevant trajectories up to the intended equivalence. Finite transition graphs then approximate the dynamics.

The current theorems establish four properties desired of such an approximation scheme: finite levels, explicit growth, consistency under coarsening, and separation of unrestricted symbolic histories. They do not establish a generating partition for any named attractor. In particular, no conclusion about the topology or Čech cohomology of the Lorenz attractor follows without a Lorenz-specific construction.

## 8. Discussion

The inverse limit reconciles finite models with infinite information. Every component $W_n$ is finite, but an inverse-limit point contains one compatible component at every depth. The cardinality of each level alone does not measure the size of the limit; coherence across infinitely many levels can support a continuum-like family of histories.

The proof of injectivity is elementary because the bonding maps are tailored to prefixes. Its significance lies in architectural clarity. Any attempt to approximate chaotic dynamics by finite graphs must confront information loss. Here a finite level forgets all symbols beyond its horizon, but the entire inverse system loses none of them: coordinate $k$ is recoverable at level $k+1$.

The graph and inverse-limit structures play distinct roles. De Bruijn edges encode temporal consistency of overlapping windows. Truncation encodes consistency across resolutions. The edge-preservation theorem connects them, showing that temporal admissibility survives coarsening. This two-axis picture—time evolution within levels and resolution change between levels—is a useful template for richer systems.

Several limitations should remain explicit. First, only a binary alphabet is considered, although the construction extends directly to any finite alphabet of size $q$, replacing $2^n$ by $q^n$. Second, the stream-to-limit map is proved injective but not here proved surjective. Third, topology is not yet placed on the inverse limit. Fourth, no graph cohomology or Čech cohomology is computed. Fifth, no concrete smooth dynamical system is linked to the graph tower.

These limitations define the boundary between the established finite-prefix theory and the larger attractor program.

## 9. Future work

The next step is to regard each finite level as a bundled directed graph and each truncation as a graph homomorphism, then verify the inverse-system identities categorically. This will make the universal property of the inverse limit available.

A second task is to define the reverse map $\Psi:L\to\Sigma_2$, prove that it is inverse to $\Phi$, and equip both spaces with their natural topologies. The binary stream space carries the product topology, while the inverse limit inherits the subspace topology from $\prod_n W_n$ with each $W_n$ discrete. The expected homeomorphism would imply compactness, total disconnectedness, perfectness, and standard cardinality properties.

A third direction is cohomological. One may define cochain groups on finite graph approximants, calculate maps induced by truncation, and study their direct limit. Such calculations could connect graph-level algebra with Čech-type invariants of an inverse-limit space.

A fourth direction is dynamical. The shift on streams should induce a map on threads, and the stream-thread equivalence should intertwine them. Restricting to subshifts of finite type would make the model responsive to forbidden transitions.

Finally, a Lorenz-specific comparison requires a precise Lorenz map or template, a verified Markov partition, and a transition graph. Only then can one compare its inverse limit and Čech cohomology with the abstract construction. Similar care would be needed for Hénon or Rössler dynamics.

## 10. Conclusion

Binary words, de Bruijn overlaps, and final-symbol truncation produce a coherent tower of finite directed graphs. Level $n$ has exactly $2^n$ words. Truncation preserves graph edges. Compatible choices across all levels form an inverse limit, and every infinite binary stream maps to its family of prefixes. Equality of those families forces coordinatewise equality of the streams, so the map is injective and the limit contains a full Cantor family of symbolic trajectories.

The construction does not replace the geometric analysis of strange attractors. It isolates a rigorous algebraic mechanism by which infinitely detailed dynamics can be retained in a hierarchy of finite combinatorial observations. That mechanism supplies a clear starting point for topology, cohomology, categorical inverse limits, and system-specific symbolic models.