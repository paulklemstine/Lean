# Sheaf Cohomology of Data: Restriction Maps, Missing-Information Obstructions, and the Limits of Scalar Missingness Laws

**Aristotle**  
**July 31, 2026**

## Abstract

Missing-data analysis is often organized around scalar summaries such as feature count and marginal missing rate. This paper studies a complementary structural model in which local observations form a finite linear data complex. Degree-zero cochains encode local assignments, degree-one cochains encode overlap residuals, and the first cohomology space measures admissible residuals that cannot be removed by local correction. Two explicit families of complexes are constructed over an arbitrary field. They have identical cochain-space dimensions in every degree, but the first family has first-cohomology dimension $n$ while the second has first-cohomology dimension $0$. Consequently, neither cochain counts nor any summary derived solely from feature count and scalar missingness can universally identify cohomological information loss; overlap incidence and restriction-map ranks are indispensable. We also analyze the proposed proxy $nr^2\log(1/r)$. It is positive at $r=1/2$ for $n>0$ but vanishes at $r=1$, and therefore is not monotone nondecreasing on the unit interval. Algorithms are given for computing first cohomology by matrix ranks and for obtaining least-squares patching corrections. Finally, an information-theoretic companion result identifies the Euler–Mascheroni constant as the accumulated Kullback–Leibler divergence between exponential distributions of consecutive integer rates. Together, these results distinguish structural obstruction from scalar missingness and illustrate how global invariants arise from organized local discrepancies.

## 1. Introduction

A dataset with missing entries is usually represented as a rectangular array plus a binary mask. This representation is useful but incomplete: it records which values are absent while suppressing the geometry of the values that remain. In distributed sensing, multi-site clinical studies, federated databases, and multimodal learning, observations occur on different subsets of features. These subsets overlap, and the overlap pattern determines whether local records can be reconciled.

Suppose one source observes features $A$, another observes features $B$, and both observe $A\cap B$. A global record must restrict to compatible values on the intersection. With many sources, pairwise agreement may itself be subject to triple-overlap conditions. This local-to-global organization is naturally described by a sheaf on a finite poset or, after choosing linear coefficient spaces, by a cochain complex.

The relevant invariant is first cohomology. Informally, zeroth cohomology describes local assignments that patch exactly, while first cohomology describes consistency defects that pass all higher checks yet cannot be explained away by changing local assignments. Its dimension is therefore a structural measure of independent obstruction directions.

A motivating heuristic proposes that, for $n$ features and missing rate $r$, the obstruction dimension should scale like

$$
nr^2\log(1/r).
$$

The appeal is clear: the expression is linear in feature count and nonlinear in missing rate. Yet cohomology depends on linear maps, not merely on dimensions. The primary purpose of this paper is to make that distinction exact through a pair of finite constructions. The constructions agree in all cochain dimensions and disagree maximally in first cohomology. They show that a universal scalar law is underdetermined unless a probabilistic incidence model and a distribution of restriction maps are supplied.

The paper also develops computational consequences. Once the coboundary matrices are available, first-cohomology dimension follows from rank–nullity, and patching can be posed as a least-squares problem. A final section presents a separate but conceptually related identity: the Euler–Mascheroni constant equals an infinite sum of Kullback–Leibler divergences between consecutive exponential distributions. This bridge provides a second precise example in which a global quantity accumulates local discrepancy.

## 2. Linear data sheaves and cochain complexes

### 2.1 Feature posets and local observations

Let $F$ be a finite feature set, and let $P$ be a collection of subsets of $F$, ordered by inclusion. An element $U\in P$ represents a feature panel on which observations may be locally complete. A linear data sheaf assigns a vector space $\mathcal{S}(U)$ over a field $\mathbb{K}$ to each panel and a linear restriction map

$$
\rho_{U,V}:\mathcal{S}(U)\longrightarrow\mathcal{S}(V)
$$

whenever $V\subseteq U$. Restrictions satisfy $\rho_{U,U}=I$ and $\rho_{V,W}\rho_{U,V}=\rho_{U,W}$ for $W\subseteq V\subseteq U$.

A global section is a choice $s_U\in\mathcal{S}(U)$ for every panel such that

$$
\rho_{U,U\cap V}(s_U)=\rho_{V,U\cap V}(s_V)
$$

on every represented overlap. Thus a global section is not merely a filled row; it is a family of local records whose shared coordinates agree under the prescribed comparison rules.

The detailed combinatorics may be encoded by a nerve, cell complex, or incidence category. For the results below, only the resulting first three cochain spaces and coboundary maps are required.

### 2.2 Data complexes

**Definition 2.1 (Finite linear data complex).** A finite linear data complex over $\mathbb{K}$ consists of finite-dimensional vector spaces $C^0$, $C^1$, and $C^2$, together with linear maps

$$
C^0\xrightarrow{d^0}C^1\xrightarrow{d^1}C^2
$$

satisfying the cochain identity

$$
d^1\circ d^0=0.
$$

Degree-zero cochains represent collections of local assignments. Degree-one cochains represent residuals on overlaps, and degree-two cochains represent consistency conditions among overlap residuals. The map $d^0$ computes overlap disagreement, while $d^1$ evaluates higher-order compatibility.

**Definition 2.2 (Zeroth and first cohomology).** The zeroth and first cohomology spaces are

$$
H^0=\ker(d^0),
\qquad
H^1=\ker(d^1)/\operatorname{im}(d^0).
$$

The quotient defining $H^1$ is valid because $d^1d^0=0$ implies $\operatorname{im}(d^0)\subseteq\ker(d^1)$.

Elements of $H^0$ are exact global patchings. An element of $\ker(d^1)$ is an admissible overlap residual, and two such residuals define the same class in $H^1$ when they differ by a residual generated from a local correction. Thus $H^1$ measures admissible but unremovable inconsistency.

### 2.3 Rank formula

**Proposition 2.3 (First-cohomology dimension).** For a finite linear data complex,

$$
\dim H^1=\dim C^1-\operatorname{rank}(d^1)-\operatorname{rank}(d^0).
$$

**Proof sketch.** By definition,

$$
\dim H^1=\dim\ker(d^1)-\dim\operatorname{im}(d^0).
$$

Rank–nullity gives $\dim\ker(d^1)=\dim C^1-\operatorname{rank}(d^1)$, while $\dim\operatorname{im}(d^0)=\operatorname{rank}(d^0)$. Substitution proves the formula. The cochain identity guarantees that the subtraction describes a quotient rather than two unrelated subspaces. $\square$

This formula makes the central issue visible: even if $\dim C^1$ is known, the result still depends on the ranks of both maps.

## 3. Equal-dimensional complexes with opposite obstruction behavior

Fix a field $\mathbb{K}$ and a nonnegative integer $n$. Define the coordinate space

$$
V_n=\mathbb{K}^n.
$$

We now construct two data complexes with the same spaces:

$$
C^0=V_n,
\qquad
C^1=V_n,
\qquad
C^2=\{0\}.
$$

### 3.1 The disconnected comparison model

**Definition 3.1 (Disconnected complex).** The disconnected complex is

$$
V_n\xrightarrow{0}V_n\xrightarrow{0}\{0\}.
$$

Both coboundary maps vanish. The cochain identity holds immediately.

**Theorem 3.2 (Full survival of overlap residuals).** In the disconnected complex,

$$
H^1\cong V_n
\qquad\text{and}\qquad
\dim H^1=n.
$$

**Proof sketch.** Since $d^1=0$, its kernel is all of $V_n$. Since $d^0=0$, its image is the zero subspace. Hence

$$
H^1=V_n/\{0\}\cong V_n.
$$

Taking dimensions gives $n$. $\square$

The word “disconnected” refers to the informational action of the maps: local changes generate no overlap corrections. Every admissible residual therefore persists.

### 3.2 The fully patchable model

**Definition 3.3 (Patchable complex).** The patchable complex is

$$
V_n\xrightarrow{I_n}V_n\xrightarrow{0}\{0\},
$$

where $I_n$ is the identity map. Again the cochain identity holds because the second map is zero.

**Theorem 3.4 (Vanishing of the obstruction space).** In the patchable complex,

$$
H^1=\{0\}
\qquad\text{and}\qquad
\dim H^1=0.
$$

**Proof sketch.** The kernel of $d^1=0$ is all of $V_n$. The identity map is surjective, so $\operatorname{im}(d^0)=V_n$. Therefore

$$
H^1=V_n/V_n=\{0\}.
$$

$\square$

Every overlap residual is generated by a degree-zero correction. No nontrivial residual class survives.

### 3.3 Non-identifiability

**Theorem 3.5 (Equal cochain dimensions do not determine first cohomology).** For every $n>0$, there exist two finite linear data complexes whose cochain spaces have equal dimensions in degrees $0$, $1$, and $2$, but whose first-cohomology dimensions are different. Specifically, the disconnected and patchable complexes both have dimension triple $(n,n,0)$, while their first-cohomology dimensions are respectively $n$ and $0$.

**Proof sketch.** The equality of cochain dimensions follows directly because both constructions use the same spaces $V_n$, $V_n$, and $\{0\}$. Theorems 3.2 and 3.4 compute the two cohomology dimensions. Since $n>0$, these dimensions are unequal. $\square$

**Corollary 3.6 (Failure of count-only identification).** No universal function of the dimension triple

$$
(\dim C^0,\dim C^1,\dim C^2)
$$

can equal $\dim H^1$ for every finite linear data complex.

**Proof sketch.** Such a function would assign the same output to the common triple $(n,n,0)$, contradicting Theorem 3.5. $\square$

The corollary is stronger than a statement about missing rate. Cochain dimensions retain more information than a feature count and a scalar rate, yet even they are insufficient. Therefore a universal formula based only on the latter summaries is impossible over the unrestricted class of data complexes.

This conclusion does not rule out scaling laws under explicit ensembles. If overlap hypergraphs and restriction matrices are sampled according to a fixed distribution, expected ranks may become functions of ensemble parameters. The theorem says that such structural assumptions are logically necessary.

## 4. Analysis of the proposed missing-rate proxy

Let $n>0$ be a real-valued feature parameter and define, for $0<r\le 1$,

$$
P_n(r)=nr^2\log(1/r).
$$

The expression extends continuously to $r=0$ by setting $P_n(0)=0$, because $r^2\log(1/r)\to0$ as $r\downarrow0$.

**Theorem 4.1 (Endpoint value at complete missingness).** For every real $n$,

$$
P_n(1)=0.
$$

**Proof sketch.** Since $1/1=1$ and $\log 1=0$, direct substitution gives $n\cdot1^2\cdot0=0$. $\square$

**Theorem 4.2 (Strict positivity at half missingness).** If $n>0$, then

$$
P_n(1/2)=\frac{n}{4}\log2>0.
$$

**Proof sketch.** Substitute $r=1/2$. Both $n/4$ and $\log2$ are strictly positive. $\square$

**Theorem 4.3 (Nonmonotonicity on the probability interval).** If $n>0$, the function $P_n$ is not monotone nondecreasing on $[0,1]$.

**Proof sketch.** The points $1/2$ and $1$ belong to $[0,1]$ and satisfy $1/2<1$. A monotone nondecreasing function would obey $P_n(1/2)\le P_n(1)$. Theorems 4.1 and 4.2 instead give $P_n(1/2)>0=P_n(1)$, a contradiction. $\square$

A derivative calculation provides additional context. For $0<r<1$,

$$
P_n'(r)=nr\bigl(2\log(1/r)-1\bigr).
$$

Thus $P_n$ increases for $r<e^{-1/2}$, reaches its unique interior maximum at $r=e^{-1/2}$, and decreases for $r>e^{-1/2}$. At the maximum,

$$
P_n(e^{-1/2})=\frac{n}{2e}.
$$

The proxy may still be useful as a hump-shaped statistic, perhaps representing the interaction between the frequency of missing observations and the number of surviving comparisons. It cannot, however, serve as a universally increasing measure of lost information throughout the full missing-rate interval.

## 5. Algorithms

### 5.1 Computing first-cohomology dimension

Let $D_0\in\mathbb{K}^{m_1\times m_0}$ and $D_1\in\mathbb{K}^{m_2\times m_1}$ represent the two coboundary maps. The input must satisfy $D_1D_0=0$.

**Algorithm 5.1 (Rank-based obstruction dimension).**

1. Verify matrix dimensions and the cochain condition $D_1D_0=0$.
2. Compute $r_0=\operatorname{rank}(D_0)$.
3. Compute $r_1=\operatorname{rank}(D_1)$.
4. Return

$$
h_1=m_1-r_1-r_0.
$$

Correctness follows from Proposition 2.3. With dense Gaussian elimination, the arithmetic cost is bounded by the cost of two rank computations, conventionally $O(m_1m_0\min(m_1,m_0)+m_2m_1\min(m_2,m_1))$. For square matrices of comparable size this is $O(m^3)$. Sparse boundary matrices should be handled by sparse rank-revealing factorizations.

For numerical real-valued data, rank depends on a tolerance. Singular values below a threshold are treated as zero. The resulting quantity is a numerical effective obstruction dimension rather than an exact algebraic dimension.

### 5.2 Extracting representatives

To obtain an explicit basis of $H^1$, compute a basis matrix $Z$ for $\ker D_1$ and a basis matrix $B$ for $\operatorname{im}D_0$. Since the columns of $B$ lie in the span of $Z$, extend a basis of $\operatorname{im}D_0$ to a basis of $\ker D_1$. The newly added vectors represent a basis of quotient classes.

Over $\mathbb{R}$ with Euclidean inner products, an orthogonal version is convenient. Let $Q_B$ have orthonormal columns spanning $\operatorname{im}D_0$. Project kernel vectors by

$$
Z_\perp=(I-Q_BQ_B^\top)Z.
$$

The nonzero left singular directions of $Z_\perp$ give representatives orthogonal to the patchable subspace.

### 5.3 Least-squares patching

Suppose an observed overlap discrepancy is $b\in C^1$. A local correction $x\in C^0$ should make $D_0x$ approximate $b$. Define

$$
x^*\in\operatorname*{argmin}_{x\in C^0}\|D_0x-b\|_2^2.
$$

The fitted vector $D_0x^*$ is the orthogonal projection of $b$ onto $\operatorname{im}D_0$, and

$$
r^*=b-D_0x^*
$$

is orthogonal to all correction-generated residuals. If $b\in\ker D_1$, then $r^*$ is an admissible representative of the same cohomology class as $b$. Exact patching is possible precisely when $r^*=0$, equivalently when $b\in\operatorname{im}D_0$.

Weighted observations lead to

$$
\operatorname*{argmin}_x (D_0x-b)^\top W(D_0x-b),
$$

where $W$ is positive definite or positive semidefinite. Regularization may be added when corrections should be small or structured. This optimization does not determine unobserved values without a data model; it separates the part explained by local correction from the persistent residual under the supplied complex.

## 6. An information-theoretic companion identity

The preceding sections concern obstructions in data assembly. This section gives an independent identity in which a global constant is accumulated from local information divergences.

For $\lambda>0$, the exponential distribution of rate $\lambda$ has density

$$
p_\lambda(x)=\lambda e^{-\lambda x},\qquad x\ge0.
$$

**Definition 6.1 (Exponential Kullback–Leibler divergence).** For positive rates $\lambda$ and $\mu$, define

$$
D(\lambda\|\mu)=\log(\lambda/\mu)+\mu/\lambda-1.
$$

This is the Kullback–Leibler divergence from $p_\lambda$ to $p_\mu$. Indeed,

$$
\int_0^\infty p_\lambda(x)
\log\frac{p_\lambda(x)}{p_\mu(x)}\,dx
=\log(\lambda/\mu)+(\mu-\lambda)\mathbb{E}_\lambda[X],
$$

and $\mathbb{E}_\lambda[X]=1/\lambda$ yields the formula.

**Theorem 6.2 (Nonnegativity).** For all $\lambda,\mu>0$,

$$
D(\lambda\|\mu)\ge0.
$$

**Proof sketch.** Set $x=\mu/\lambda>0$. Then

$$
D(\lambda\|\mu)=-\log x+x-1.
$$

The standard inequality $\log x\le x-1$ proves the claim. Equality occurs exactly when $x=1$, or $\lambda=\mu$. $\square$

Define

$$
a_k=\frac{1}{k+1}-\log\frac{k+2}{k+1},
\qquad k\ge0.
$$

**Lemma 6.3 (Consecutive-rate identity).** For every integer $k\ge0$,

$$
D(k+1\|k+2)=a_k.
$$

**Proof sketch.** Substitute $\lambda=k+1$ and $\mu=k+2$:

$$
D(k+1\|k+2)
=\log\frac{k+1}{k+2}+rac{k+2}{k+1}-1.
$$

The final two terms reduce to $1/(k+1)$, and the logarithm changes sign under reciprocal inversion. $\square$

By Theorem 6.2, every $a_k$ is nonnegative.

**Lemma 6.4 (Finite telescoping identity).** For every integer $n\ge0$,

$$
\sum_{k=0}^{n-1}a_k=H_n-\log(n+1),
$$

where $H_0=0$ and $H_n=\sum_{j=1}^n1/j$.

**Proof sketch.** The reciprocal terms sum to $H_n$. For the logarithms,

$$
\sum_{k=0}^{n-1}\log\frac{k+2}{k+1}
=\log\prod_{k=0}^{n-1}\frac{k+2}{k+1}
=\log(n+1).
$$

Subtracting proves the identity. $\square$

The Euler–Mascheroni constant is defined by

$$
\gamma=\lim_{n\to\infty}\bigl(H_n-\log(n+1)\bigr),
$$

an equivalent indexing of the usual harmonic–logarithmic limit.

**Theorem 6.5 (Euler–Mascheroni constant as accumulated exponential divergence).**

$$
\gamma=
\sum_{k=0}^{\infty}
D_{\mathrm{KL}}\bigl(\operatorname{Exp}(k+1)\,\|\,\operatorname{Exp}(k+2)\bigr).
$$

Moreover, the $n$th partial sum is exactly $H_n-\log(n+1)$.

**Proof sketch.** Lemma 6.3 identifies each divergence with $a_k$. Lemma 6.4 identifies the finite sum with $H_n-\log(n+1)$. Taking the defining limit for $\gamma$ proves convergence and the infinite-series identity. $\square$

This result gives a direct probabilistic interpretation of $\gamma$: it is the total information cost accumulated while moving through exponential laws with rates $1,2,3,\ldots$, comparing each law to its immediate successor.

## 7. Applications and experimental design

### 7.1 Distributed and multimodal data

In a distributed database, each site may hold a different feature subset. The overlap graph alone records where comparisons are possible, while restriction matrices record what those comparisons mean. Theorem 3.5 implies that site count, feature count, and storage density cannot determine patchability. A system audit should include map ranks or cohomology, not only missing percentages.

Multimodal learning presents a similar structure. Images, text, laboratory values, and time series may overlap only through shared latent or observed coordinates. If the learned comparison maps have low rank, many overlap residuals can survive even when the modal coverage rate appears favorable.

### 7.2 Sensor networks

Sensors frequently measure local subsets of an environmental field. A residual may indicate calibration mismatch, network geometry, or genuine incompatibility with the model. Computing $H^1$ distinguishes discrepancies generated by local recalibration from those that persist after all permitted local corrections.

### 7.3 Controlled comparisons of imputation methods

A meaningful simulation should proceed as follows:

1. Specify a generative distribution for complete observations.
2. Specify an overlap hypergraph or feature-subset poset.
3. Specify restriction maps and ensure the cochain identity.
4. Generate observations and missingness masks.
5. Compute $\dim H^1$ from the induced matrices.
6. Compare mean, nearest-neighbor, chained-equation, and coboundary-residual methods while conditioning on the same sample size, feature count, missing rate, and noise.

The crucial design choice is to vary incidence or map ranks while holding scalar summaries fixed. Otherwise an observed relationship between missing rate and error may merely reflect an uncontrolled change in overlap structure.

## 8. Discussion

The non-identifiability theorem is deliberately elementary. Its force comes from requiring almost no assumptions: any field is allowed, and the complexes are finite-dimensional. The result isolates the exact missing ingredient in scalar models. Dimensions describe the sizes of spaces; cohomology depends on how those spaces are connected by maps.

The two examples are extremes. In the disconnected model, $\operatorname{rank}(d^0)=0$ and every degree-one coordinate survives. In the patchable model, $\operatorname{rank}(d^0)=n$ and none survives. Intermediate ranks realize intermediate dimensions when $d^1=0$. More generally, Proposition 2.3 shows that both correction rank and higher-check rank remove dimensions from $C^1$.

The analysis also clarifies the status of empirical laws. A relationship such as $\dim H^1\approx nr^2\log(1/r)$ cannot be universal over all data complexes. It may become a valid asymptotic statement after specifying a random overlap model, a coefficient field, a distribution of restriction matrices, and conditioning required by $d^1d^0=0$. Those assumptions convert an underdetermined formula into a falsifiable probabilistic conjecture.

There are limitations. First cohomology captures linear local-to-global obstruction relative to a chosen complex; it does not by itself encode prediction quality, causal identifiability, or semantic plausibility. Different sheaf models of the same raw table may produce different invariants. Numerical rank may be unstable near singularity. Finally, exact vanishing of $H^1$ means that admissible residuals are algebraically removable, not that a statistically accurate imputation is unique.

## 9. Future work

A natural next step is a random-incidence rank law. Over a finite field $\mathbb{F}_q$, one may fix a random overlap hypergraph and sample restriction matrices conditioned on $d^1d^0=0$. The normalized quantity $\dim H^1/\dim C^1$ may then converge in probability to a deterministic function of the hypergraph parameters and $q$.

A second direction is to strengthen non-identifiability probabilistically: for fixed $r\in(0,1)$ and arbitrarily large $n$, construct data-generating models with equal marginal missingness but expected first-cohomology dimensions separated by a positive linear fraction of $n$.

For flag overlap nerves with linear maps, one may test whether the full nerve and the clique complex generated by pairwise overlaps always produce the same $H^1$. Synthetic enumeration can search directly for a counterexample.

The statistical meaning of obstruction dimension should also be tested. Under a specified noisy linear observation model and after conditioning on sample size, feature count, missing rate, and noise variance, one may ask whether exact patchability probability decreases with $\dim H^1$.

Finally, weighted coboundary regularization should be compared with scalar imputation in preregistered synthetic regimes. A concrete hypothesis is that it lowers held-out reconstruction error relative to mean imputation in positive-$H^1$ strata, while offering no necessary advantage when $H^1$ vanishes.

## 10. Conclusion

Missing information is not determined by the number of blank entries. In a linear data complex, it is controlled by the incidence of local views and by the ranks of the maps that compare them. Two complexes with identical cochain dimensions can have obstruction dimensions $n$ and $0$. The proposed proxy $nr^2\log(1/r)$ is also nonmonotone on the full probability interval, vanishing at complete missingness despite being positive at half missingness.

The appropriate computational pipeline is therefore structural: construct the comparison maps, verify the cochain identity, compute ranks and cohomology, and only then assess patching or imputation. Scalar missingness remains a useful descriptive statistic, but it cannot replace the topology of how surviving observations overlap.
