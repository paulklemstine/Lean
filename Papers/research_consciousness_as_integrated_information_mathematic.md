# Integrated Information as a Finite Minimum-Cut Functional

**Aristotle**  
**August 2, 2026**

## Abstract

We present a finite mathematical framework for integrated information based on nontrivial bipartitions of a system. A system assigns a nonnegative effective-information value to every subset of its components, and its integrated information $\Phi$ is the minimum over all nonempty proper subsets. We establish the elementary order theory of this functional: the admissible family is nonempty for systems with at least two components, a minimum-information partition exists, $\Phi$ is bounded above by every cut value, every common lower bound of the cut values bounds $\Phi$ from below, and $\Phi$ is nonnegative. We then specialize effective information to the total nonnegative directed interaction weight crossing from a subset to its complement. In this model, $\Phi$ is exactly a directed minimum-cut functional. We prove that $\Phi>0$ if and only if every nontrivial cut carries positive outgoing interaction, thereby identifying positive integrated information with a cut form of directed connectivity. Finally, we prove a multiplicative approximation-transfer theorem: if a surrogate effective-information function bounds every cut between factors $1$ and $c$, then its minimum bounds $\Phi$ between the same factors. We give exhaustive algorithms, numerical examples, modeling interpretations, limitations, and directions for extending the theory to probabilistic semantics and explicit complexity results.

## 1. Introduction

Integrated-information approaches attempt to quantify the degree to which a system behaves as an irreducible whole. Their central intuition is naturally partition-based: divide the system, measure what informational relation is lost, and identify the partition that disrupts the system least. The least disruptive partition is the critical one because it exposes the system's weakest interface.

This paper isolates a finite mathematical core of that idea. We do not prescribe a unique biological interpretation of effective information. Instead, we begin with an abstract nonnegative value assigned to each candidate cut. This separates two questions that are often conflated: the order-theoretic behavior of minimizing over partitions, and the domain-specific construction of the cut value itself.

The first layer is universal. For a finite system with at least two components, nontrivial bipartitions exist, the set of candidate values is finite and nonempty, and therefore an actual minimum-information partition realizes the minimum. This immediately supplies upper-bound and lower-bound principles and establishes nonnegativity.

The second layer specializes to weighted directed networks. Each ordered pair of components carries a nonnegative interaction weight, and the effective information of a subset is the total weight of interactions leaving it. Under this interpretation, integrated information is a directed global minimum cut. Its strict positivity has an exact structural characterization: every nonempty proper subset must have some positive total interaction flowing outward. This result provides a bridge from integrated-information language to graph connectivity.

The third layer concerns approximation. In richer models, evaluating every cut may be expensive, while tractable surrogates may be available. We show that uniform pointwise multiplicative control of all cut values passes unchanged through minimization. This theorem is agnostic about how a surrogate is computed; it supplies a correctness interface that any proposed approximation algorithm can target.

The framework is finite and structural. It does not, by itself, establish an NP-hardness theorem, because such a theorem requires a discrete input encoding, a decision problem, and a specified reduction model. Nor does it claim that weighted connectivity alone captures consciousness. Its contribution is to state exactly what follows from the minimum-partition construction and what additional work is required for stronger computational or scientific claims.

## 2. Finite systems and admissible partitions

Let $n\ge 2$ and let

$$
V=\{0,1,\ldots,n-1\}
$$

be the component set. A subset $A\subseteq V$ induces the ordered bipartition $(A,V\setminus A)$. We call $A$ **admissible** when it is nonempty and proper:

$$
\varnothing\ne A\subsetneq V.
$$

The family of admissible cuts is denoted

$$
\mathcal P^*(V)=\{A\subseteq V: A\ne\varnothing\text{ and }A\ne V\}.
$$

Representing a bipartition by $A$ rather than by an unordered pair is consequential in directed settings: the cut represented by $A$ measures flow from $A$ to its complement, while the complement represents flow in the reverse direction. Thus $A$ and $V\setminus A$ need not have equal values.

**Lemma 2.1 (Existence of admissible partitions).** If $n\ge2$, then $\mathcal P^*(V)$ is nonempty.

**Proof sketch.** Choose any component $v\in V$. The singleton $\{v\}$ is nonempty. Since $V$ has at least two elements, $\{v\}\ne V$, so it is proper. Hence it is admissible. $\square$

A **finite effective-information system** is a pair $(V,E)$ in which $V$ is as above and

$$
E:2^V\to\mathbb R
$$

assigns a real value to every subset, subject to

$$
E(A)\ge0\qquad\text{for every }A\subseteq V.
$$

Only values on admissible subsets enter the integrated-information functional; defining $E$ on all subsets is convenient and harmless.

**Definition 2.2 (Integrated information).** The integrated information of $(V,E)$ is

$$
\Phi(E)=\min_{A\in\mathcal P^*(V)}E(A).
$$

An admissible subset $A_*$ satisfying $E(A_*)=\Phi(E)$ is called a **minimum-information partition**. Strictly speaking, $A_*$ identifies the ordered bipartition $(A_*,V\setminus A_*)$.

The definition emphasizes a bottleneck principle. Large $\Phi(E)$ requires every admissible split to have large effective information. Conversely, a single low-valued partition bounds the entire system from above.

## 3. Fundamental properties of the minimum

The basic theorems follow from finiteness, but they are worth stating explicitly because they provide reusable proof and estimation principles.

**Theorem 3.1 (Cut upper bound).** For every admissible subset $A$,

$$
\Phi(E)\le E(A).
$$

**Proof sketch.** The minimum of a nonempty finite collection is no greater than any member of that collection. Since $A$ is admissible, $E(A)$ is among the values minimized. $\square$

The theorem says that an observed or constructed cut is a certificate of an upper bound. To show that integration is small, it suffices to find one weak partition.

**Theorem 3.2 (Minimum-Information Partition Theorem).** Every finite effective-information system with at least two components has an admissible subset $A_*$ such that

$$
E(A_*)=\Phi(E).
$$

**Proof sketch.** By Lemma 2.1, the admissible family is nonempty. It is finite because it is contained in the power set of the finite set $V$. The image $\{E(A):A\in\mathcal P^*(V)\}$ is therefore a nonempty finite set of real numbers and has a least element. A preimage of that least element is the required $A_*$. $\square$

This attainment result distinguishes the finite theory from an infinite infimum problem. Every value $E(A)$ might be positive in an infinite family while their infimum is zero; that phenomenon cannot occur here.

**Theorem 3.3 (Common lower-bound principle).** Let $b\in\mathbb R$. If

$$
b\le E(A)\qquad\text{for every }A\in\mathcal P^*(V),
$$

then

$$
b\le\Phi(E).
$$

**Proof sketch.** Choose a minimum-information partition $A_*$. Applying the hypothesis to $A_*$ gives $b\le E(A_*)=\Phi(E)$. $\square$

Unlike an upper bound, a lower bound must control every candidate cut. This asymmetry is central in minimum-cut reasoning.

**Corollary 3.4 (Nonnegativity).** Every finite effective-information system satisfies

$$
\Phi(E)\ge0.
$$

**Proof sketch.** The defining assumption gives $0\le E(A)$ for every admissible $A$. Apply the common lower-bound principle with $b=0$. $\square$

No normalization is required for these results. Effective-information values may have any nonnegative scale, and distinct systems can employ different semantics, provided comparisons are interpreted accordingly.

## 4. Directed weighted interaction systems

We now instantiate effective information using a network. Let

$$
w:V\times V\to\mathbb R_{\ge0}
$$

be a nonnegative directed weight function. The value $w_{ij}$ represents interaction from component $i$ to component $j$. Self-weights do not affect any cut, because $i$ and $i$ always lie on the same side.

**Definition 4.1 (Outgoing cut weight).** For $A\subseteq V$, define

$$
C_w(A)=\sum_{i\in A}\sum_{j\in V\setminus A}w_{ij}.
$$

Since every summand is nonnegative, $C_w(A)\ge0$. Therefore

$$
E_w(A)=C_w(A)
$$

defines a finite effective-information system.

**Definition 4.2 (Weighted integrated information).** The integrated information induced by $w$ is

$$
\Phi_w=\min_{\varnothing\ne A\subsetneq V}C_w(A).
$$

This is a directed global minimum-cut functional. Because direction is retained, it differs from the usual undirected cut capacity when $w_{ij}\ne w_{ji}$.

**Definition 4.3 (Cut-connectivity).** A nonnegative directed weighted network is cut-connected when

$$
C_w(A)>0
$$

for every nonempty proper subset $A\subset V$.

Because weights are nonnegative, $C_w(A)>0$ holds exactly when at least one ordered pair $(i,j)$ with $i\in A$ and $j\notin A$ has $w_{ij}>0$. Thus cut-connectivity says that no nonempty proper set is closed against all positive-weight outgoing edges.

This property is closely related to strong connectivity of the directed support graph. Define the support graph to have an arc $i\to j$ precisely when $w_{ij}>0$. If the graph is strongly connected, every nonempty proper subset has an arc leaving it. Conversely, if every nonempty proper subset has an outgoing arc, then the condensation of strongly connected components cannot contain more than one component, because any finite acyclic condensation with at least two vertices has a sink whose union has no outgoing arc. Hence the cut condition characterizes strong connectivity of the positive-weight support. The main theorem below is stated directly in cut language so that no auxiliary graph conventions are needed.

## 5. Integrated information and connectivity

**Theorem 5.1 (Integrated Information–Connectivity Theorem).** Let $n\ge2$, and let $w_{ij}\ge0$ for all $i,j\in V$. Then

$$
\Phi_w>0
\quad\Longleftrightarrow\quad
C_w(A)>0\text{ for every }\varnothing\ne A\subsetneq V.
$$

Equivalently, weighted integrated information is strictly positive if and only if the network is cut-connected.

**Proof sketch.** Suppose first that $\Phi_w>0$. For every admissible $A$, the cut upper-bound theorem gives $\Phi_w\le C_w(A)$. Hence $C_w(A)>0$.

Conversely, suppose every admissible cut has positive weight. By the Minimum-Information Partition Theorem, choose an admissible $A_*$ with $C_w(A_*)=\Phi_w$. The cut-connectivity assumption gives $C_w(A_*)>0$, and therefore $\Phi_w>0$. $\square$

Nonnegativity of weights is essential to the intended connectivity interpretation. With signed weights, positive and negative interactions could cancel in a cut sum, and a zero cut would no longer mean absence of crossing support. Finiteness is also essential to the reverse implication as written: it supplies a minimizing cut rather than merely an infimum.

**Corollary 5.2 (Zero-integration certificate).** Under the assumptions of Theorem 5.1,

$$
\Phi_w=0
$$

if and only if there exists a nonempty proper subset $A$ such that

$$
C_w(A)=0.
$$

**Proof sketch.** Weighted cut values and their minimum are nonnegative. Thus failure of strict positivity is equivalent to equality with zero. Negating cut-connectivity yields an admissible cut with nonpositive weight; nonnegativity forces that weight to be zero. Conversely, any zero cut bounds $\Phi_w$ above by zero, while nonnegativity bounds it below by zero. $\square$

The corollary gives an interpretable witness. Zero integrated information is certified by a subsystem with no positive total interaction leaving it.

**Corollary 5.3 (Bottleneck interpretation).** If $A_*$ is a minimum-information partition, then

$$
\Phi_w=C_w(A_*),
$$

and strengthening interactions that do not cross any minimum cut need not increase $\Phi_w$.

The equality is immediate from the definition. The second observation warns against interpreting total network weight as integration. Integration is controlled by bottlenecks, not by aggregate activity.

## 6. Multiplicative approximation transfer

Let $(V,E)$ and $(V,\widetilde E)$ be two effective-information systems on the same component set. Think of $E$ as the target quantity and $\widetilde E$ as a tractable surrogate.

**Theorem 6.1 (Multiplicative Approximation Transfer Theorem).** Suppose there is a real factor $c$ such that, for every admissible subset $A$,

$$
E(A)\le\widetilde E(A)\le cE(A).
$$

Then their integrated-information values satisfy

$$
\Phi(E)\le\Phi(\widetilde E)\le c\Phi(E).
$$

**Proof sketch.** Choose an admissible subset $B_*$ minimizing $\widetilde E$. Then

$$
\Phi(E)\le E(B_*)\le\widetilde E(B_*)=\Phi(\widetilde E),
$$

which proves the lower inequality.

Next choose an admissible subset $A_*$ minimizing $E$. Since $\Phi(\widetilde E)$ is no larger than the surrogate value of any particular cut,

$$
\Phi(\widetilde E)\le\widetilde E(A_*)\le cE(A_*)=c\Phi(E).
$$

Combining the inequalities proves the claim. $\square$

The minimizing cuts for $E$ and $\widetilde E$ may differ; no stability of the optimizer is assumed. The theorem controls only the optimum value. This is often exactly what approximation algorithms can guarantee.

Although the theorem states no explicit sign condition on $c$, its hypotheses become restrictive when nonnegative cut values are positive. In customary approximation settings one takes $c\ge1$. If $\Phi(E)=0$, the conclusion and nonnegativity yield $\Phi(\widetilde E)=0$.

A symmetric two-sided approximation can be derived by rescaling. For example, if

$$
\frac{1}{c}E(A)\le\widetilde E(A)\le cE(A)
$$

for $c\ge1$, applying the theorem appropriately yields comparable bounds after selecting the desired normalization. The stated one-sided form is particularly natural for surrogate capacities that dominate the original cuts.

## 7. Algorithms

### 7.1 Exhaustive minimum-information partition search

For a system supplied by an evaluation rule $E(A)$, the most direct exact algorithm enumerates all nonempty proper subsets, evaluates each, and retains the smallest value and a minimizing subset.

There are $2^n-2$ admissible subsets. If evaluating one cut costs $T_E(n)$, the total running time is

$$
O\bigl(2^nT_E(n)\bigr),
$$

with $O(n)$ additional space for a current subset and a best witness, excluding storage for the input.

For a dense weighted matrix, a cut can be evaluated directly in $O(n^2)$ time, giving a simple bound of

$$
O(n^2 2^n).
$$

The algorithm may enumerate both $A$ and its complement because directed cut values can differ. Even in the symmetric case, this duplication affects only a constant factor.

**Algorithm 7.1 (Exhaustive directed minimum cut).**

1. Require $n\ge2$ and an $n\times n$ nonnegative matrix $w$.
2. Set the best value to positive infinity and the best subset to none.
3. For each bit mask from $1$ through $2^n-2$:
   1. Decode the mask as a nonempty proper subset $A$.
   2. Compute $C_w(A)$ by summing $w_{ij}$ for $i\in A$ and $j\notin A$.
   3. If $C_w(A)$ is smaller than the best value, update the value and witness.
4. Return the best value and subset.

Correctness follows because every admissible subset appears exactly once and the algorithm returns the minimum of their cut weights.

### 7.2 Testing cut-connectivity

One may test cut-connectivity by exhaustive cut enumeration and checking whether the minimum is positive. For nonnegative weights, a more structural method constructs the directed support graph containing $i\to j$ when $w_{ij}>0$ and tests strong connectivity with two graph traversals, one in the support graph and one in its transpose. With adjacency lists this takes $O(n+m)$ time, where $m$ is the number of positive-weight arcs.

This faster connectivity test decides whether $\Phi_w>0$, but it does not compute the magnitude of $\Phi_w$. The theorem cleanly separates a qualitative question from a quantitative one.

### 7.3 Surrogate pipeline

The approximation theorem suggests a modular pipeline:

1. Construct a surrogate $\widetilde E$ that is efficient to evaluate or optimize.
2. Prove the pointwise inequalities $E(A)\le\widetilde E(A)\le cE(A)$ for every admissible $A$.
3. Compute or approximate $\Phi(\widetilde E)$.
4. Report $\Phi(E)\le\Phi(\widetilde E)\le c\Phi(E)$.

The structural theorem certifies Step 4, but the runtime and approximation quality depend entirely on the concrete surrogate and its optimizer.

## 8. Numerical examples

### 8.1 Directed cycle

Let $V=\{0,1,2\}$ and assign weight $1$ to $0\to1$, $1\to2$, and $2\to0$, with all other weights zero. Every nonempty proper subset has at least one outgoing cycle edge. Direct enumeration gives a minimum cut weight of $1$, so

$$
\Phi_w=1>0.
$$

The support graph is strongly connected, in agreement with the connectivity theorem.

### 8.2 A broken cycle

Remove the edge $2\to0$ from the previous network. For $A=\{2\}$,

$$
C_w(\{2\})=0.
$$

Therefore $\Phi_w=0$. The remaining edges may still carry activity, but the subsystem $\{2\}$ has no outgoing positive interaction and supplies a zero-integration certificate.

### 8.3 A weighted bottleneck

Consider two densely connected modules joined in each direction by weak total capacity $\varepsilon>0$. A cut separating the modules has weight $\varepsilon$, so

$$
0<\Phi_w\le\varepsilon.
$$

If every other admissible cut has weight at least $\varepsilon$, then equality holds. As $\varepsilon$ decreases, total internal interaction can remain large while integrated information approaches zero. This illustrates why the minimum, rather than an average, captures vulnerability to decomposition.

### 8.4 Surrogate scaling

Let $\widetilde E(A)=1.5E(A)$ for every admissible cut. Then the pointwise assumptions hold with $c=1.5$, and in fact

$$
\Phi(\widetilde E)=1.5\Phi(E).
$$

More generally, if each surrogate cut lies somewhere between $E(A)$ and $1.5E(A)$, the minimizing partition may change, but the theorem still guarantees

$$
\Phi(E)\le\Phi(\widetilde E)\le1.5\Phi(E).
$$

## 9. Applications and interpretation

The weighted model applies whenever directed couplings can be represented by nonnegative capacities. In neural interaction models, a cut may represent a candidate subsystem boundary and crossing weights may summarize directed influence. In communication systems, $\Phi_w$ identifies the least outgoing capacity of any nontrivial group. In organizational or ecological networks, a minimum partition identifies a module with the weakest outward coupling.

These interpretations share a mathematical statement, not a common empirical semantics. The choice $E(A)=C_w(A)$ assumes additive pairwise interactions and ignores higher-order effects, temporal dynamics, interventions, and probability distributions. Consequently, $\Phi_w$ should be read as a network integration functional. Establishing it as a measure of consciousness would require independent scientific assumptions and empirical validation.

The directionality convention also matters. The outgoing cut of $A$ differs from that of its complement. One might instead use the symmetric crossing value

$$
C_w^{\mathrm{sym}}(A)=\sum_{i\in A}\sum_{j\notin A}(w_{ij}+w_{ji}),
$$

or identify complementary subsets as one unordered partition. For symmetric weights, $C_w(A)=C_w(V\setminus A)$, and the ordered duplication is immaterial. For directed weights it encodes a genuine distinction.

## 10. Complexity boundary and limitations

The finite definition entails an exponential number of candidate subsets for naive enumeration, but that fact alone is not an NP-hardness proof. Complexity is a property of a precisely encoded computational problem. A faithful theorem would need to specify at least:

1. how systems, transition rules, probabilities, and numerical values are encoded as finite bit strings;
2. whether the task is exact optimization, threshold decision, or approximation;
3. how arithmetic costs and precision are counted;
4. which partition normalization, if any, is used; and
5. the polynomial-time reduction establishing hardness.

For the present weighted-cut specialization, graph algorithms can exploit structure. In symmetric nonnegative networks, global minimum cut is polynomial-time computable. Directed variants also possess specialized algorithms under standard encodings. Therefore an unqualified NP-hardness statement would be false or at least unsupported for this finite-cut model. Hardness may arise in richer IIT semantics, but it must be proved after those semantics and encodings are fixed.

The approximation-transfer theorem likewise does not construct a polynomial-time approximation. It says that if a tractable surrogate with pointwise factor bounds is supplied, then minimizing it transfers those bounds to $\Phi$. Runtime analysis and construction of such a surrogate remain separate obligations.

Other limitations are conceptual. The abstract system assumes nonnegative effective information but imposes no complement symmetry, submodularity, monotonicity, or normalization. The weighted specialization is pairwise and additive. It does not model causal interventions, state-dependent repertoires, stochastic transitions, or divergences between distributions. These omissions are deliberate: they keep the established conclusions transparent and identify exactly what future extensions must add.

## 11. Future work

A probabilistic extension could define effective information through divergences between repertoires generated by finite Markov kernels. This requires explicit interventions, subsystem marginalization, and a divergence such as total variation or Kullback–Leibler divergence, followed by proofs of nonnegativity and data-processing behavior.

A computational-complexity layer should define bit-size-aware encodings of Boolean transition systems and probability distributions, formulate a threshold problem for normalized integrated information, and prove reductions from standard partition problems. Such work would distinguish complexity caused by partition search from complexity caused by evaluating the information measure.

Concrete approximation research should instantiate the transfer theorem. The goal is to design a surrogate, prove its pointwise bounds, and analyze an optimizer's runtime. For weighted graphs, comparisons with exact minimum-cut algorithms provide an immediate benchmark.

Alternative partition conventions deserve systematic study. Directed outgoing cuts, symmetric crossing cuts, unordered bipartitions, and multipartitions can produce different minima. Conditions such as weight symmetry may force some conventions to coincide.

Finally, the quantitative value $\Phi_w$ can be compared with edge connectivity, conductance, spectral gaps, and robustness under perturbations. If weights change by a controlled amount, one may seek stability bounds for both the optimum value and the set of minimizing partitions.

## 12. Conclusion

For a finite system, integrated information defined by minimization over nontrivial cuts is a well-posed, attained, nonnegative quantity. Its minimum-information partition provides an explicit bottleneck witness. When effective information is nonnegative directed crossing weight, strict positivity of $\Phi$ is equivalent to the requirement that every nontrivial subset send positive interaction to its complement. When every cut is approximated within a multiplicative factor, the minimum inherits the same factor.

These results make precise a simple principle: integration is governed by the easiest separation. They also mark a clear boundary. Connectivity and approximation transfer are established within the finite model; complexity classifications and richer causal semantics require additional definitions and arguments. That separation between proved structure and future ambition is essential for a rigorous mathematical account of integrated information.