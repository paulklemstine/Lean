# Finite Moment Methods and Mean-Field Thresholds in Erdős–Rényi Random Graphs

**Aristotle**  
**August 3, 2026**

## Abstract

We give a self-contained treatment of finite first- and second-moment methods for the independent-edge random graph and connect them to two characteristic threshold scales. For an arbitrary finite family of prescribed edge sets, we derive the exact first moment of the number of realized patterns and the exact second moment as a sum indexed by pairwise unions. This yields an overlap expansion for the variance and a Paley–Zygmund-type lower bound for the probability that at least one pattern appears. We also state and prove a variance criterion under which absence has probability tending to zero. At the sparse scaling $p=\lambda/n$, we analyse the Poisson exploration fixed point $\rho=1-e^{-\lambda\rho}$: the only nonnegative solution is zero for $0<\lambda\leq1$, whereas a solution in $(0,1)$ exists for $\lambda>1$, with the quantitative lower bound $\rho\geq2(\lambda-1)/\lambda^2$. We explain how this identifies the mean-field giant-component transition, and we distinguish it carefully from the later connectivity window $p=(\log n+c)/n$. Numerical algorithms for simulation, overlap enumeration, and fixed-point computation are included, together with applications and precise directions needed to pass from the finite identities to sharp asymptotic graph laws.

## 1. Introduction

The Erdős–Rényi model $G(n,p)$ begins with $n$ labelled vertices and includes each of the ${n\choose2}$ possible undirected edges independently with probability $p$. Despite the independence of individual edges, graph properties are strongly dependent: two triangles can share an edge, many connected subgraphs can compete for the same vertices, and the event of global connectivity is controlled by rare local obstructions near its threshold.

Threshold phenomena arise when a small change in $p$ produces a large change in the probability of a structural property. Two scales are especially important. At $p=\lambda/n$, the expected degree is approximately $\lambda$, and a macroscopic connected component first becomes possible when $\lambda$ passes through one. Connectivity itself appears later, at a scale of order $(\log n)/n$, when isolated vertices disappear.

The present paper focuses on the common finite mechanism beneath many such statements: count candidate structures, calculate how pairs overlap, and convert moment estimates into probability bounds. The method applies to any finite potential-edge set and any finite indexed family of required edge sets. It therefore covers copies of a fixed graph, prescribed routes, local motifs, and many non-graphical independent-feature models.

A distinction between exact results and asymptotic interpretations is essential. The finite probability law, first-moment identities, exact pair-overlap formula, variance expansion, second-moment lower bound, and fixed-point phase transition are established here directly. The full finite-graph laws for connectivity and giant-component size require additional asymptotic inputs—respectively, Poisson approximation plus exclusion of nontrivial small components, and a branching-process coupling plus concentration. We state those targets and explain exactly how the results here enter their proofs, without conflating the mean-field fixed point with the complete finite-graph theorem.

## 2. The finite independent-edge model

Let $E$ be a finite set of potential edges. A configuration is a function assigning “absent” or “present” to each edge, equivalently a subset $g\subseteq E$. Fix $p\in[0,1]$. The probability mass of $g$ is

$$
w_p(g)=p^{|g|}(1-p)^{|E|-|g|}.
$$

The binomial theorem shows that this is normalized:

$$
\sum_{g\subseteq E}w_p(g)
=\sum_{k=0}^{|E|}{|E|\choose k}p^k(1-p)^{|E|-k}=1.
$$

For an event $\mathcal A\subseteq2^E$, define

$$
\mathbb P_p(\mathcal A)=\sum_{g\in\mathcal A}w_p(g),
$$

and for a real random variable $X:2^E\to\mathbb R$, define

$$
\mathbb E_p[X]=\sum_{g\subseteq E}w_p(g)X(g),
\qquad
\mathbb E_p[X^2]=\sum_{g\subseteq E}w_p(g)X(g)^2.
$$

These definitions require no limiting construction: all sums are finite.

### Definition 2.1 (Required-edge event)

For $A\subseteq E$, let

$$
\mathcal A_A=\{g\subseteq E:A\subseteq g\}
$$

be the event that every edge in $A$ is present.

### Lemma 2.2 (Probability of a required edge set)

For every $A\subseteq E$,

$$
\mathbb P_p(\mathcal A_A)=p^{|A|}.
$$

**Proof sketch.** Every edge of $A$ must be present, contributing $p^{|A|}$. Summing over arbitrary choices on $E\setminus A$ contributes

$$
\sum_{R\subseteq E\setminus A}p^{|R|}(1-p)^{|E\setminus A|-|R|}=1.
$$

Multiplication gives the formula. $\square$

### Lemma 2.3 (Intersection equals union of requirements)

For all $A,B\subseteq E$,

$$
\mathcal A_A\cap\mathcal A_B=\mathcal A_{A\cup B},
$$

and consequently

$$
\mathbb P_p(\mathcal A_A\cap\mathcal A_B)=p^{|A\cup B|}.
$$

**Proof sketch.** A configuration contains both $A$ and $B$ if and only if it contains their union. Lemma 2.2 then supplies the probability. $\square$

The second identity is the basic overlap calculation. If $A$ and $B$ are disjoint, it factors as $p^{|A|}p^{|B|}$. If they overlap, the shared edges are paid for only once.

## 3. Families of patterns and their first moments

Let $I$ be a finite index set and assign to each $i\in I$ a required set $S_i\subseteq E$. Repeated edge sets are allowed when different indices represent distinct labelled embeddings.

### Definition 3.1 (Pattern count)

The number of realized candidates is

$$
X(g)=\sum_{i\in I}\mathbf1_{\mathcal A_{S_i}}(g)
=\#\{i\in I:S_i\subseteq g\}.
$$

### Theorem 3.2 (Expected Count Formula)

For every finite family $(S_i)_{i\in I}$,

$$
\mathbb E_p[X]=\sum_{i\in I}p^{|S_i|}.
$$

**Proof sketch.** Expand $X$ as a finite sum of indicators. Linearity of expectation gives

$$
\mathbb E_p[X]=\sum_{i\in I}\mathbb E_p[\mathbf1_{\mathcal A_{S_i}}]
=\sum_{i\in I}\mathbb P_p(\mathcal A_{S_i}),
$$

and Lemma 2.2 evaluates each summand. No independence between candidates is needed. $\square$

### Theorem 3.3 (First-Moment Vanishing Bound)

For $p\in[0,1]$,

$$
\mathbb P_p(X>0)\leq\sum_{i\in I}p^{|S_i|}=\mathbb E_p[X].
$$

**Proof sketch.** The positivity event is the union $\bigcup_{i\in I}\mathcal A_{S_i}$. Apply the union bound and then Lemma 2.2. Equivalently, use the pointwise inequality $\mathbf1_{\{X>0\}}\leq X$. $\square$

For a sequence $X_n$, if $\mathbb E[X_n]\to0$, then $\mathbb P(X_n>0)\to0$. This criterion frequently proves the lower-density side of an appearance threshold.

### Example 3.4 (Copies of a fixed graph)

Let $H$ have $v(H)$ vertices and $e(H)$ edges. Index labelled embeddings of $H$ into the complete graph on $n$ vertices, and let $S_i$ be the edge set required by embedding $i$. Each candidate has $e(H)$ edges, so

$$
\mathbb E[X_H]=N_H(n)p^{e(H)},
$$

where $N_H(n)$ is the number of indexed embeddings used by the counting convention. For unlabelled triangles, $N_H(n)={n\choose3}$ and

$$
\mathbb E[X_\triangle]={n\choose3}p^3.
$$

## 4. Exact second moments and overlap expansions

The first moment ignores dependence among candidates. The second moment records it exactly.

### Theorem 4.1 (Exact Second-Moment Formula)

For the count in Definition 3.1,

$$
\mathbb E_p[X^2]
=\sum_{i\in I}\sum_{j\in I}p^{|S_i\cup S_j|}.
$$

**Proof sketch.** Expand the square:

$$
X^2=\sum_{i,j\in I}
\mathbf1_{\mathcal A_{S_i}}\mathbf1_{\mathcal A_{S_j}}.
$$

The product of the two indicators is the indicator of their intersection. By Lemma 2.3, that intersection requires exactly $S_i\cup S_j$, whose probability is $p^{|S_i\cup S_j|}$. Summing proves the identity. $\square$

This theorem is exact for every finite family and every real $p$ for which the algebraic expressions are considered; its probabilistic interpretation uses $p\in[0,1]$.

### Corollary 4.2 (Exact Variance Expansion)

The variance $\operatorname{Var}_p(X)=\mathbb E_p[X^2]-\mathbb E_p[X]^2$ satisfies

$$
\operatorname{Var}_p(X)
=\sum_{i,j\in I}p^{|S_i\cup S_j|}
-\left(\sum_{i\in I}p^{|S_i|}\right)^2.
$$

**Proof sketch.** Substitute Theorems 3.2 and 4.1 into the definition of variance. $\square$

An equivalent covariance form is often revealing:

$$
\operatorname{Var}_p(X)
=\sum_{i,j\in I}
\left(p^{|S_i\cup S_j|}-p^{|S_i|+|S_j|}\right).
$$

Pairs with disjoint required edge sets contribute zero. Thus only edge-overlapping pairs affect covariance, even if the corresponding subgraphs share vertices.

### Example 4.3 (Triangle overlaps)

Let $X_\triangle$ count unlabelled triangles in $G(n,p)$. For an ordered pair of identical triangles, the union has three edges. For two distinct triangles sharing an edge, the union has five edges. For all other distinct pairs, their edge sets are disjoint and the union has six edges. Hence the second moment is obtained by counting these three classes. In covariance form, the disjoint class cancels entirely. This illustrates why pair classification, rather than enumeration of all graph configurations, is the computationally natural approach.

### Algorithmic principle

Given explicit sets $S_i$, store each as a bit mask. Then $|S_i\cup S_j|$ is the population count of a bitwise OR. A direct exact computation takes $O(|I|^2)$ pair operations and $O(|I|)$ storage beyond the input. If the family has symmetries, one can instead count orbit or overlap classes and reduce the calculation dramatically.

## 5. From moments to appearance probabilities

### Theorem 5.1 (Finite Support Cauchy–Schwarz Bound)

Let $X\geq0$ be a real random variable on the finite independent-edge space. Then

$$
\mathbb E_p[X]^2
\leq \mathbb P_p(X>0)\,\mathbb E_p[X^2].
$$

**Proof sketch.** Let $A=\{X>0\}$. Nonnegativity implies $X=0$ outside $A$, so

$$
\mathbb E_p[X]=\mathbb E_p[X\mathbf1_A].
$$

Apply Cauchy–Schwarz to $X$ and $\mathbf1_A$:

$$
\mathbb E_p[X\mathbf1_A]^2
\leq\mathbb E_p[X^2]\mathbb E_p[\mathbf1_A^2]
=\mathbb E_p[X^2]\mathbb P_p(A).
$$

This is the stated inequality. $\square$

### Corollary 5.2 (Second-Moment Lower Bound)

If $X\geq0$ and $\mathbb E_p[X^2]>0$, then

$$
\mathbb P_p(X>0)
\geq\frac{\mathbb E_p[X]^2}{\mathbb E_p[X^2]}.
$$

For a family $(S_i)_{i\in I}$, this specializes to

$$
\mathbb P_p(X>0)
\geq
\frac{\left(\sum_{i\in I}p^{|S_i|}\right)^2}
{\sum_{i,j\in I}p^{|S_i\cup S_j|}},
$$

whenever the denominator is positive.

**Proof sketch.** Divide Theorem 5.1 by the positive second moment and use the exact formulas from Sections 3 and 4. $\square$

The ratio is never greater than one, as Theorem 5.1 itself shows. Its usefulness depends on overlap. If

$$
\frac{\mathbb E[X^2]}{\mathbb E[X]^2}\longrightarrow1,
$$

then the probability of appearance tends to one.

### Theorem 5.3 (Variance Criterion for High-Probability Appearance)

Let $(X_n)$ be nonnegative random variables with nonzero means. Suppose

$$
\mathbb E[X_n]\longrightarrow\infty
$$

and there is a constant $C$ such that

$$
\operatorname{Var}(X_n)\leq C\mathbb E[X_n]
$$

for all $n$. Then

$$
\mathbb P(X_n=0)\longrightarrow0.
$$

**Proof sketch.** On $X_n=0$, the squared deviation from the mean equals $\mathbb E[X_n]^2$. Since every term in the variance sum is nonnegative,

$$
\mathbb P(X_n=0)\leq
\frac{\operatorname{Var}(X_n)}{\mathbb E[X_n]^2}
\leq\frac{C}{\mathbb E[X_n]}.
$$

The final quantity tends to zero. $\square$

The hypotheses are sufficient rather than necessary. In applications one often proves the more general relation $\operatorname{Var}(X_n)=o(\mathbb E[X_n]^2)$.

## 6. The mean-field giant-component transition

Set $p=\lambda/n$. The expected degree is $(n-1)\lambda/n\to\lambda$. Early in a breadth-first exploration of a component, collisions are rare, and the number of newly discovered neighbours is approximately Poisson with mean $\lambda$. This motivates a Poisson Galton–Watson process.

Let $q$ be its extinction probability. A particle has $K\sim\operatorname{Poisson}(\lambda)$ children, and extinction occurs exactly when all child lineages become extinct. Therefore

$$
q=\mathbb E[q^K]=e^{\lambda(q-1)}.
$$

Writing $\rho=1-q$ for survival probability gives

$$
\rho=1-e^{-\lambda\rho}.
$$

### Definition 6.1 (Mean-field order parameter)

For $\lambda>0$, a nonnegative number $\rho$ is a mean-field survival parameter if

$$
\rho=1-e^{-\lambda\rho}.
$$

### Theorem 6.2 (Sharp Fixed-Point Phase Transition)

The mean-field survival equation has the following regimes:

1. If $0<\lambda\leq1$ and $\rho\geq0$ satisfies $\rho=1-e^{-\lambda\rho}$, then $\rho=0$.
2. If $\lambda>1$, there exists $\rho$ with $0<\rho<1$ satisfying $\rho=1-e^{-\lambda\rho}$.

In particular, at $\lambda=1$ the only nonnegative order parameter is zero.

**Proof sketch.** Define

$$
f_\lambda(x)=1-e^{-\lambda x}-x.
$$

One has $f_\lambda(0)=0$ and

$$
f_\lambda'(x)=\lambda e^{-\lambda x}-1,
\qquad
f_\lambda''(x)=-\lambda^2e^{-\lambda x}<0.
$$

Thus $f_\lambda$ is strictly concave. If $\lambda\leq1$, then $f_\lambda'(0)=\lambda-1\leq0$, so concavity forces $f_\lambda(x)<0$ for every $x>0$; no positive fixed point exists. If $\lambda>1$, then $f_\lambda'(0)>0$, so $f_\lambda$ is positive immediately to the right of zero, while

$$
f_\lambda(1)=-e^{-\lambda}<0.
$$

Continuity produces a root in $(0,1)$. $\square$

### Theorem 6.3 (Quantitative Supercritical Lower Bound)

If $\lambda>1$ and $0<\rho<1$ satisfies $\rho=1-e^{-\lambda\rho}$, then

$$
\rho\geq\frac{2(\lambda-1)}{\lambda^2}.
$$

**Proof sketch.** The elementary inequality $e^{-x}\leq1-x+x^2/2$ for $x\geq0$ gives

$$
\rho=1-e^{-\lambda\rho}
\geq\lambda\rho-\frac{\lambda^2\rho^2}{2}.
$$

Because $\rho>0$, rearrangement and division by $\rho$ yield

$$
\frac{\lambda^2\rho}{2}\geq\lambda-1,
$$

which is the claim. $\square$

The equation predicts that the giant-component density is $\rho$. Theorems 6.2 and 6.3 establish the transition for this limiting exploration equation: extinction is certain at and below mean one, while positive survival occurs above one. To turn this into the finite random-graph law requires controlling the approximation throughout a sufficiently long exploration, proving concentration of the mass in large components, and proving uniqueness of the macroscopic component.

## 7. Connectivity and isolated vertices

Connectivity has a different threshold. Let $I_n$ count isolated vertices in $G(n,p)$. A fixed vertex has no incident edge with probability $(1-p)^{n-1}$, hence

$$
\mathbb E[I_n]=n(1-p)^{n-1}.
$$

At

$$
p_n=\frac{\log n+c}{n},
$$

one obtains

$$
\mathbb E[I_n]\longrightarrow e^{-c}.
$$

This expectation suggests, but does not by itself prove, a Poisson limit.

### Sharp connectivity target

The classical sharp statement is

$$
\mathbb P\bigl(G(n,p_n)\text{ is connected}\bigr)
\longrightarrow e^{-e^{-c}}.
$$

A self-contained proof naturally separates into two asymptotic propositions:

1. $I_n$ converges in distribution to a Poisson random variable of mean $e^{-c}$, so $\mathbb P(I_n=0)\to e^{-e^{-c}}$.
2. The probability that $G(n,p_n)$ is disconnected but has no isolated vertices tends to zero.

The first can be approached through falling-factorial moments. For fixed $k$,

$$
\mathbb E[(I_n)_k]
=(n)_k(1-p_n)^{k(n-k)+{k\choose2}},
$$

because $k$ ordered distinct vertices are all isolated precisely when every edge touching at least one of them is absent. The desired limit is $e^{-ck}$. The second proposition requires summing over possible separated vertex sets of sizes from two to $n/2$ and showing that the total probability vanishes. These are further asymptotic steps, not consequences of the first and second moments alone.

## 8. Algorithms and numerical demonstrations

### 8.1 Sampling $G(n,p)$

Generate all pairs $0\leq u<v<n$ and include each independently when a uniform random number is below $p$. A disjoint-set union structure computes connected components in almost linear time in the number of sampled edges. Straight pair scanning costs $O(n^2)$ random draws and $O(n+M)$ storage, where $M$ is the realized edge count.

### 8.2 Computing the survival parameter

For $\lambda\leq1$, return zero. For $\lambda>1$, solve

$$
f_\lambda(\rho)=1-e^{-\lambda\rho}-\rho=0
$$

for the nonzero root in $(0,1)$. Bisection is robust once the lower endpoint is chosen slightly above zero; fixed-point iteration $\rho_{t+1}=1-e^{-\lambda\rho_t}$ with a positive initial value is simpler and converges to the positive solution in the supercritical regime. Each iteration costs $O(1)$, and bisection reaches absolute error $\varepsilon$ in $O(\log(1/\varepsilon))$ iterations.

### 8.3 Exact overlap computation

Represent each required set by a bit mask. Compute

$$
M_1=\sum_i p^{|S_i|},
\qquad
M_2=\sum_{i,j}p^{|S_i\cup S_j|},
$$

then report $M_1^2/M_2$ when $M_2>0$. The direct method takes $O(|I|^2)$ bitwise unions. For graph families with symmetry, classify pairs by intersection type and multiply one contribution by the class size.

### 8.4 What simulation can and cannot show

Monte Carlo experiments make the two scales visible: near $\lambda=1$, the largest component changes from microscopic to macroscopic; near $p=(\log n)/n$, the connectivity probability changes rapidly. Such experiments illustrate finite-size behaviour but do not establish an asymptotic theorem. Exact moment formulas and analytic estimates remain necessary to control all configurations.

## 9. Applications

**Network reliability.** Candidate edge sets can encode operational routes between terminals. The first moment bounds the probability that any route survives; the second moment corrects for shared links and gives a rigorous lower bound on successful connectivity through at least one prescribed route.

**Motif detection.** Triangles, cliques, cycles, and feed-forward motifs are represented by required-edge families. Their exact second moments reduce to overlap counts, revealing when a high expected motif count corresponds to widespread occurrence rather than rare clustering.

**Epidemic and information spread.** The equation $\rho=1-e^{-\lambda\rho}$ is the survival equation for Poisson reproduction. It identifies the critical reproduction mean and gives a quantitative lower bound on the supercritical survival fraction. Network epidemics require further assumptions, but the branching approximation explains the shared threshold geometry.

**Constraint systems.** More abstractly, $E$ may be a finite set of independently activated features and each $S_i$ a certificate for success. The formulas depend only on cardinalities and pairwise unions, not on graphical interpretation.

## 10. Discussion and limitations

The central exact result is the pair-overlap identity. It separates probability from combinatorics: probability contributes the factor $p^{|S_i\cup S_j|}$, while the application contributes the classification and enumeration of pair types. This modularity is why second-moment arguments recur across probabilistic combinatorics.

Several limitations should be explicit. First, a diverging expectation alone does not imply high-probability appearance. Second, the fixed-point transition describes the limiting branching process; by itself it does not prove the finite random graph has a unique component of size $\rho n+o(n)$. Third, the connectivity limit requires Poisson convergence and exclusion of other disconnected components. Finally, numerical experiments are explanatory rather than deductive.

The finite results nevertheless provide a complete reusable pipeline: exact model normalization, required-edge probabilities, first moments, pairwise joint probabilities, second moments, variances, and probability bounds. The remaining work in a concrete asymptotic theorem is to estimate the resulting sums or to justify a limiting exploration process.

There is also a useful division of labour between the two moment methods. The first moment is inherently one-sided: it rules out structures when the expected count vanishes. The second moment can establish existence when candidate occurrences are sufficiently dispersed, but it exposes rather than removes the combinatorial burden. A large overlap class may dominate the denominator and prevent the lower bound from approaching one. In that situation the correct response is often to refine the counted objects, condition on a typical environment, or use a truncated count that suppresses exceptionally clustered configurations. Thus the exact formula is both a theorem and a diagnostic: it identifies precisely which intersections obstruct concentration.

## 11. Future work

Five directions naturally continue this development.

1. **Poisson isolated-vertex limit in the connectivity window.** For fixed $c\in\mathbb R$, prove that if $I_n$ counts isolated vertices in $G(n,(\log n+c)/n)$, then every fixed falling-factorial moment converges to the corresponding moment of a Poisson variable of mean $e^{-c}$. This gives $\mathbb P(I_n=0)\to e^{-e^{-c}}$.

2. **Equivalence of connectivity and absence of isolated vertices.** Prove that, at the same $p_n$, the probability of having no isolated vertices while remaining disconnected tends to zero. Combined with the preceding limit, this yields the sharp connectivity law.

3. **Finite random-graph giant-component law.** For fixed $\lambda>1$, prove that the largest component divided by $n$ converges in probability to the positive solution $\rho$ of $\rho=1-e^{-\lambda\rho}$, while the second-largest divided by $n$ converges to zero.

4. **Subcritical logarithmic component bound.** For $0<\lambda<1$ and $A>1/(\lambda-1-\log\lambda)$, prove that every component of $G(n,\lambda/n)$ has at most $A\log n$ vertices with probability tending to one.

5. **Clique appearance above threshold.** For fixed $r\geq3$, classify pairs of $r$-vertex sets by overlap size in the exact second-moment formula and prove high-probability appearance of $K_r$ whenever $p_n n^{2/(r-1)}\to\infty$ with $p_n\leq1$.

## 12. Conclusion

Independent edges generate dependent structures, and pairwise unions measure that dependence exactly. For any finite family of candidate patterns, the mean is a sum of single-copy probabilities and the second moment is a sum of pair-union probabilities. Cauchy–Schwarz then turns overlap control into a lower bound for appearance, while a variance estimate yields high-probability existence.

At a global scale, the Poisson exploration equation undergoes its own sharp change at mean degree one: its nonnegative order parameter vanishes at and below criticality and becomes positive above it. Connectivity occurs later, in the logarithmic window governed by isolated vertices. Together these results display the layered nature of random-graph evolution and provide the counting machinery needed for sharper threshold theorems.
