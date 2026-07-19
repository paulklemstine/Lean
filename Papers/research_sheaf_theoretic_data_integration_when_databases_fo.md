# Sheaf-Theoretic Data Integration: Completion, Constraint Dependence, and Finite Imputation

**Aristotle**  
**July 19, 2026**

## Abstract

Sheaf language offers a natural description of databases assembled from overlapping local views: compatible local records should glue to a global record. This paper clarifies what that principle does and does not imply for missing-data imputation. A partial database valued in any nonempty set always has a total completion; completion is unique exactly when every cell is observed, while a missing cell and two available values yield nonuniqueness. Consequently, missingness by itself does not produce a sheaf obstruction, and a universal completability probability of the form $(1-r)^C$ is false under the natural partial-function model. We next show that overlap constraints may be redundant. All pairwise equality constraints on a nonempty family are equivalent to equalities with a fixed root; on a graph with $c$ connected components and a value set of size $q$, exactly $q^c$ assignments are consistent. In particular, a Boolean triangle has consistent fraction $1/4$, not the $1/8$ obtained by treating its three equations as independent. We then formulate finite sheaf-style imputation as minimization of observed Hamming loss subject to equality constraints, prove existence of a minimizer, and give a connected-component algorithm. Finally, we prove that no observation-preserving method can be distribution-free and strictly superior to another throughout the regime $r<1/2$, since complete data force a tie. The results identify the assumptions required for meaningful probability and performance theorems: explicit restriction maps, a stochastic observation model, and an accounting of independent rather than nominal constraints.

## 1. Introduction

Modern data integration rarely begins with one complete table. Information is distributed across overlapping sources: clinical records share patient attributes, sensor networks share boundary measurements, and organizational reports share subtotals. Such systems invite a local-to-global formulation. Each source provides a local record, overlaps permit comparisons, and a globally coherent database should restrict to each local record.

A **sheaf** is an abstract mechanism for this local-to-global passage. Informally, it assigns data to each region of a domain, provides restriction maps from larger regions to smaller ones, and guarantees that compatible local data glue uniquely. This vocabulary suggests an appealing interpretation of imputation: a database with missing entries is a partial local description, and imputation seeks a global section consistent with it.

The interpretation is fruitful only if three notions are kept separate.

1. **Missingness** means that some cell values are unspecified.
2. **Compatibility** means that independently supplied local values agree after restriction to overlaps.
3. **Recovery** means that an estimator reconstructs a latent true database with low loss.

These notions are not interchangeable. Missingness can increase the number of completions rather than obstructing existence. Compatibility constraints can be numerous but algebraically dependent. Recovery performance depends on a probability distribution connecting observed data, missingness, noise, and the latent truth.

This paper develops a finite model that makes these distinctions precise. The first result establishes unconditional completion of partial functions into a nonempty value set. It immediately refutes any universal formula that assigns completability probability $(1-r)^C$ solely from a missing rate $r$ and a nominal constraint count $C$. The second group of results analyzes equality constraints. A root reduction theorem shows that pairwise equalities contain extensive redundancy, and a graph counting theorem identifies connected components as the correct invariant. The third group treats imputation as constrained optimization and supplies an exact algorithm for equality constraints. The final result rules out distribution-free strict superiority claims by examining complete data.

The conclusions are constructive rather than merely negative. They show how to formulate a defensible sheaf-theoretic data model: specify restriction maps, express feasibility as a global-section condition, measure independent constraints by graph connectivity or linear rank, and compare estimators through expected risk under an explicit generative model.

## 2. Mathematical model

### 2.1 Partial databases

Let $I$ be a set of cells and let $V$ be a nonempty set of possible values. A **partial database** is a pair $(O,y)$, where $O\subseteq I$ is the set of observed cells and $y:O\to V$ gives their values. Equivalently, it is a partial function from $I$ to $V$.

A **total assignment** is a function $x:I\to V$. It is a **completion** of $(O,y)$ if

$$
x(i)=y(i)\qquad\text{for every }i\in O.
$$

This definition imposes no relationships between distinct cells. Such relationships must be supplied separately as constraints.

### 2.2 Local views and the sheaf condition

Let $X$ be a collection of regions ordered by inclusion. For each region $U\in X$, let $F(U)$ be the set of records available on $U$. Whenever $W\subseteq U$, a restriction map

$$
\rho^U_W:F(U)\to F(W)
$$

forgets the information outside $W$. Restrictions are required to satisfy identity and composition laws: restricting a record to its own region changes nothing, and restricting in stages gives the same result as restricting directly.

A family $s_U\in F(U)$ over regions $U$ in a cover is **compatible** when

$$
\rho^U_{U\cap W}(s_U)=\rho^W_{U\cap W}(s_W)
$$

for every pair $U,W$. A **global section** is a record on the whole domain. The sheaf condition states that every compatible family has a unique global section restricting to all its members.

In a database of independent cells, a partial observation merely omits coordinates and can always be extended. A genuine sheaf obstruction arises only when local views carry values that can disagree after restriction, or when structural constraints disallow some global assignments.

### 2.3 Equality-constraint model

For a finite and computationally transparent model, let $I$ be finite and let $E$ be a set of unordered pairs of cells. Each edge $\{i,j\}\in E$ imposes

$$
x(i)=x(j).
$$

The pair $G=(I,E)$ is the **constraint graph**. A total assignment satisfying all edge equalities is called **feasible** or **consistent**. This is the constant-value sheaf model on each connected component.

### 2.4 Loss and imputation

For a partial database $(O,y)$ and total assignment $x$, define the observed Hamming loss

$$
L_O(x,y)=\sum_{i\in O}\mathbf{1}\{x(i)\ne y(i)\}.
$$

A **constrained imputation** is a feasible total assignment minimizing $L_O(x,y)$. The objective preserves as many observations as possible, while feasibility enforces structural coherence.

## 3. Completion without structural constraints

We first isolate what missingness alone implies.

### Theorem 1 (Existence of completion)

Let $I$ be any set, let $V$ be nonempty, and let $(O,y)$ be a partial database. Then $(O,y)$ has a total completion.

#### Proof sketch

Choose a default value $v_0\in V$. Define $x(i)=y(i)$ when $i\in O$ and $x(i)=v_0$ otherwise. The resulting total function agrees with all observations.

The theorem does not require finiteness, independence, or a probability model. It is a direct consequence of leaving unobserved coordinates unconstrained.

### Theorem 2 (Uniqueness and nonuniqueness)

If $O=I$, the completion is unique. Conversely, if $I\setminus O$ is nonempty and $V$ contains distinct values $a$ and $b$, then the partial database has at least two distinct completions.

#### Proof sketch

When all cells are observed, any completion must equal $y$ at every cell. If $i_0\notin O$, begin with any completion and construct two assignments agreeing everywhere except at $i_0$, where they take $a$ and $b$. Both preserve all observations and are distinct.

These results identify the effect of missingness in the unconstrained model: it affects identifiability, not feasibility. More missing cells generally mean more possible completions.

### Corollary 3 (Completability has probability one)

Under any probability distribution on missingness masks, if values lie in a nonempty set and completion means extension of the observed partial function, then the probability that a partial database is completable equals $1$.

#### Proof sketch

Theorem 1 applies to every possible mask. An event containing every outcome has probability $1$.

### Consequence for the proposed exponential law

A proposed universal law

$$
P(\text{completable})=(1-r)^C
$$

cannot describe this model, where $r$ is the missing rate and $C$ is a count of overlaps. For $r=1/2$ and $C=1$, the right-hand side is $1/2$, whereas Corollary 3 gives $1$. More generally, whenever $0<r\le 1$ and $C>0$, the proposed expression is below $1$.

This contradiction is not a technical anomaly. It reveals a mismatch of events. The factor $1-r$ measures observation, but an unobserved cell is not an inconsistency. To obtain a nontrivial probability, one must randomize values or local reports and define compatibility failures explicitly.

## 4. Dependence among overlap constraints

Even after introducing genuine consistency equations, the number of written equations need not equal the number of independent conditions.

### Lemma 4 (Transitivity on a triangle)

For any values $x_1,x_2,x_3$, the equations $x_1=x_2$ and $x_2=x_3$ imply $x_1=x_3$.

#### Proof sketch

Equality is transitive. Therefore, the third edge equation of a triangle follows from the other two.

### Theorem 5 (Root reduction)

Let $I$ be nonempty, choose $r\in I$, and let $(x_i)_{i\in I}$ be a family of values. The following conditions are equivalent:

1. $x_i=x_j$ for every $i,j\in I$;
2. $x_i=x_r$ for every $i\in I$.

#### Proof sketch

The first condition directly implies the second by choosing $j=r$. Under the second condition, for arbitrary $i,j$ one has $x_i=x_r$ and $x_j=x_r$, hence $x_i=x_j$.

Thus a complete graph on $n$ vertices contains $\binom{n}{2}$ pairwise equality equations but only $n-1$ root equations are needed. Treating all pairwise equations as probabilistically independent drastically overcounts restrictions.

### Example 6 (Boolean triangle)

Let $V=\{0,1\}$ and choose $(x_1,x_2,x_3)$ uniformly from $V^3$. The three edge constraints require all coordinates to agree. Exactly two of the eight assignments satisfy them:

$$
(0,0,0),\qquad(1,1,1).
$$

Therefore,

$$
P(\text{consistent})=\frac{2}{8}=\frac14.
$$

Multiplying three nominal half-probabilities would give $(1/2)^3=1/8$. The error comes from counting the transitive third equality as independent.

### Theorem 7 (Graph component count)

Let $G=(I,E)$ be a finite undirected graph with $c$ connected components, and let $V$ contain exactly $q\ge 1$ values. The number of assignments $x:I\to V$ satisfying $x(i)=x(j)$ for every edge $\{i,j\}\in E$ is

$$
q^c.
$$

#### Proof sketch

Along any path, repeated transitivity forces all vertex values to agree. Hence a feasible assignment is constant on each connected component. Conversely, choosing one value for each component and assigning it to every vertex in that component satisfies every edge. This gives a bijection between feasible assignments and functions from the set of components to $V$, of which there are $q^c$.

### Corollary 8 (Consistency probability under independent uniform values)

If each of the $N=|I|$ vertex values is sampled independently and uniformly from a $q$-element set, then

$$
P(\text{consistent})=q^{c-N}.
$$

#### Proof sketch

There are $q^N$ equally likely assignments and, by Theorem 7, $q^c$ feasible ones.

This formula identifies $N-c$ as the number of independent equality restrictions. A spanning forest has exactly $N-c$ edges. Every further edge closes a cycle and contributes no new equality condition. Thus raw overlap count is generally the wrong exponent; graph rank is the appropriate invariant.

## 5. Finite constrained imputation

We now combine partial observations with structural equalities.

### Theorem 9 (Existence of a finite constrained minimizer)

Let $I$ and $V$ be finite, with $V$ nonempty. Let $E$ be any finite family of equality constraints, and let $(O,y)$ be a partial database. Then there exists a feasible assignment $x^*:I\to V$ such that

$$
L_O(x^*,y)\le L_O(x,y)
$$

for every feasible assignment $x$.

#### Proof sketch

Choose any $v\in V$ and assign $v$ to every cell. This constant assignment satisfies every equality, so the feasible set is nonempty. Since both $I$ and $V$ are finite, the set of total assignments, and therefore the feasible subset, is finite. The nonnegative integer-valued loss attains a minimum on every finite nonempty set.

The theorem remains valid for any real-valued objective on the finite feasible set. Hamming loss is especially useful because it yields an explicit componentwise algorithm.

### Theorem 10 (Componentwise characterization of Hamming minimizers)

For each connected component $C$ of the constraint graph and each value $v\in V$, define

$$
n_C(v)=\#\{i\in C\cap O:y(i)=v\}.
$$

A feasible assignment minimizes observed Hamming loss if and only if, on each component $C$, it takes a value belonging to

$$
\operatorname*{arg\,max}_{v\in V} n_C(v).
$$

If a component has no observations, every value is minimizing on that component.

#### Proof sketch

Every feasible assignment is constant on each component by Theorem 7. If component $C$ is assigned value $v$, then exactly $|C\cap O|-n_C(v)$ observations in that component are mismatched. Minimizing this quantity is equivalent to maximizing $n_C(v)$. The total loss is the sum of component losses, so components can be optimized independently.

### Algorithm 1: Connected-component constrained imputation

**Input:** a finite cell set, equality edges, a finite nonempty value set, and partial observations.

**Output:** a feasible total assignment minimizing observed Hamming loss.

1. Compute connected components of the equality graph using union–find or depth-first search.
2. For each component, count observed occurrences of every value.
3. Select a value of maximum count, using a fixed deterministic tie rule. If the component is unobserved, select a default value.
4. Assign the selected value to every cell in the component.

With union–find, processing $M$ edges and $N$ vertices takes $O((N+M)\alpha(N))$ time, where $\alpha$ is the inverse Ackermann function. Counting observations and writing the output take $O(N)$ expected time with hash maps. Storage is $O(N+Q')$, where $Q'$ is the number of component–value pairs actually observed; a dense implementation uses $O(N+CQ)$ storage for $C$ components and $Q=|V|$.

### Interpretation

The algorithm is a discrete projection onto the set of global sections. It does not merely fill blanks. When observations within one component conflict, it changes a minimum number of them. When they agree, it propagates their common value to missing cells. When a component is entirely unobserved, the data do not identify its value, and the tie rule chooses one of several equally good completions.

This final case is important: optimization can produce an output even when the data contain no information about part of the solution. Existence of a minimizer should not be confused with statistical identifiability.

## 6. Limits of universal method comparisons

Suppose two imputation procedures are **observation-preserving**, meaning that whenever a cell is observed, the output retains its observed value. Mean-style and structural procedures are often designed to have this property on complete inputs.

Let $d(\widehat{x},x)$ be any loss satisfying $d(x,x)=0$. Examples include Hamming loss, squared error, and absolute error.

### Theorem 11 (Complete-data tie)

If the true database $x$ is fully observed and two methods preserve observations, then both methods return $x$ and both incur loss zero.

#### Proof sketch

Every cell is observed, so observation preservation forces each output coordinate to equal the corresponding coordinate of $x$. Therefore both outputs equal $x$, and normalization of the loss gives zero.

### Corollary 12 (No distribution-free strict superiority on $r<1/2$)

No claim can validly assert that one observation-preserving imputation method is strictly better than another for every database and every missing rate $r<1/2$ under a loss that vanishes at the truth.

#### Proof sketch

The regime includes $r=0$. By Theorem 11, complete data force a tie, contradicting strict superiority.

The same reasoning applies when the feature count exceeds ten or any other threshold. Adding dimensions does not remove the complete-data counterexample.

A meaningful comparison must weaken or qualify the claim. Possibilities include expected-risk inequalities under a specified distribution, non-strict dominance, improvement conditional on at least one missing entry, or asymptotic comparisons under a correctly specified latent model. Even then, structural assumptions are essential. If equality constraints reflect the truth, pooling can reduce variance; if they are misspecified, enforcing them introduces bias.

## 7. A probabilistic framework that can support valid claims

A defensible stochastic model should specify at least three layers.

### 7.1 Latent global data

Let $X$ be a random global assignment, perhaps concentrated on or near a global-section space $S$. For exact equality constraints, one may assume $X\in S$ almost surely. For approximate structure, one may instead penalize deviations from $S$.

### 7.2 Observation and noise

Let $M_i\in\{0,1\}$ indicate whether cell $i$ is observed. A missing-completely-at-random model might take $M_i$ independently with

$$
P(M_i=0)=r.
$$

More realistic models allow dependence on observed covariates or on $X$. Observed values may also be noisy, such as

$$
Y_i=X_i+\varepsilon_i
$$

for numerical data.

### 7.3 Estimation and risk

An estimator $\widehat{X}(Y,M)$ should be compared by expected loss

$$
R(\widehat{X})=\mathbb{E}\bigl[d(\widehat{X}(Y,M),X)\bigr].
$$

Only after the joint law of $(X,M,Y)$ is defined does a statement such as $R(\widehat{X}_{\mathrm{sheaf}})\le R(\widehat{X}_{\mathrm{mean}})$ have determinate mathematical content.

In linear settings over a finite field or Euclidean space, compatibility can be expressed through a coboundary operator $\delta$. Global sections satisfy

$$
\delta x=0.
$$

Over a finite field with $q$ elements, if $\delta$ has rank $s$ on an $N$-dimensional assignment space, then the kernel has dimension $N-s$ and contains $q^{N-s}$ assignments. Under the uniform model, the exact compatibility probability is $q^{-s}$. This is the linear-algebraic analogue of Corollary 8 and again shows that rank, not the number of listed equations, controls probability.

For real-valued data and squared loss, constrained imputation becomes projection onto a global-section subspace. If the constraint set is a nonempty closed affine subspace, a unique nearest point exists under the Euclidean norm. This supplies a continuous counterpart to finite Hamming minimization.

## 8. Applications

### 8.1 Record reconciliation

Duplicate records may represent the same entity across departments. Equality edges encode fields believed to denote one latent attribute. Connected-component imputation then chooses a consensus value minimizing disagreement with observed records. The method also identifies ambiguity through ties and highlights likely errors through changed observations.

### 8.2 Sensor networks

Overlapping sensors may report a common boundary quantity. A restriction map formalizes which part of one reading should match another. Exact equalities suit categorical states; linear restrictions suit calibrated numerical measurements. Cycles in the sensor network create diagnostic redundancy but not necessarily independent constraints.

### 8.3 Hierarchical reporting

Regional and consolidated reports overlap through totals and subtotals. Here restrictions are generally linear rather than equality-only. The global-section space consists of reports satisfying all accounting identities. Rank analysis reveals which checks are independent, while constrained least squares provides a coherent correction.

### 8.4 Data fusion with missing entries

When several feature subsets overlap, the sheaf framework records not only what is missing but how views should agree. The completion theorems warn that an arbitrary fill is always possible in the unconstrained table. The substantive question is whether a fill satisfies the chosen cross-view relations and whether those relations improve predictive risk.

## 9. Discussion

The phrase “a database with missing entries is a partial section” is useful but incomplete. In the simplest product model, every partial section extends. Sheaf theory becomes informative when restrictions identify or transform values across views. The obstruction is then incompatibility, not blankness.

Likewise, an abundance of overlaps does not automatically provide exponentially many independent constraints. A complete graph has quadratically many edges but only linearly many independent equality conditions. In linear models, the corresponding measure is matrix rank. Probability formulas based only on a raw count $C$ are valid only when independence has been established.

The constrained-imputation theorem provides a firm positive result. Finite equality-constrained imputation is well posed, and its Hamming minimizer is efficiently computable. Yet optimization and statistical performance are distinct. A minimizer exists even on an entirely unobserved component, where no estimator can infer the latent value without a prior. Structural constraints can transfer information only when they correctly connect unknowns to informative observations.

These distinctions suggest reporting more than one diagnostic in practical systems: feasibility, minimum constraint-respecting loss, number of minimizers, component structure, and sensitivity to constraint removal. Such information exposes where the result is data-driven and where it depends on arbitrary tie-breaking or modeling assumptions.

## 10. Future work

Several extensions lead beyond equality constraints. Finite cellular sheaves replace edges labeled by equality with linear restriction maps. Feasibility then becomes membership in the kernel of a coboundary map, and exact counts over finite fields follow from rank–nullity. For real vector spaces, squared-error imputation can be studied as orthogonal projection, with weighted norms representing heterogeneous measurement reliability.

A second direction is probabilistic. Missingness and noisy observations should be placed in an explicit probability space. This permits exact recovery probabilities, posterior uncertainty, and expected-risk comparisons. The central modeling question is how closely the chosen global-section space approximates the latent data-generating process.

A third direction concerns robustness. Hard compatibility may be inappropriate when restrictions are approximate. One can replace $\delta x=0$ by a penalty such as $\lambda\|\delta x\|^2$, producing a continuum between unconstrained fitting and exact consistency. Selecting $\lambda$ from data and quantifying misspecification risk are natural statistical problems.

Finally, graph and hypergraph structure can guide computation. Component decomposition solves the equality case exactly; sparse linear algebra treats linear restrictions; and message-passing methods may address large nonlinear systems. In all cases, independent constraint rank and identifiability should accompany raw overlap counts.

## 11. Conclusion

Sheaf-theoretic language clarifies data integration when it is used to describe genuine compatibility relations among overlapping views. Four conclusions follow.

First, a partial database over a nonempty value set always has a completion. Missingness alone affects uniqueness, not existence. Second, overlap constraints can be strongly dependent: equality constraints reduce to a spanning forest, and a $q$-valued graph with $c$ connected components has exactly $q^c$ consistent assignments. Third, finite structural imputation is a genuine constrained optimization problem with an attained optimum and an efficient componentwise solution in the equality case. Fourth, no observation-preserving method can be strictly superior throughout a regime that includes complete data.

The correct program is therefore not to infer probability or performance from missing rate and overlap count alone. It is to define the restriction structure, compute its independent content, specify a stochastic model, and evaluate estimators by an explicit risk. Under those conditions, local-to-global mathematics provides both a rigorous theory of consistency and a practical architecture for coherent data integration.
