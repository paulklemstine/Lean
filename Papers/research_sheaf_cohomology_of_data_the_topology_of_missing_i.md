# Cohomological Obstructions to Patching Incomplete Data

## Abstract

Incomplete data are often summarized by a scalar missing rate, but the possibility of reconstructing a coherent global observation depends on how local observations overlap and on the ranks of their restriction maps. We model finite-dimensional local observations, pairwise overlap residuals, and triple-overlap checks by a two-step cochain complex

$$
C^0\xrightarrow{d^0}C^1\xrightarrow{d^1}C^2,
\qquad d^1d^0=0.
$$

The zeroth cohomology $H^0=\ker d^0$ consists of globally compatible local observations, while the first cohomology $H^1=\ker d^1/\operatorname{im}d^0$ records locally consistent overlap residuals that cannot be removed by changing local observations. We prove the exact dimension formula

$$
\dim H^1=\dim C^1-\operatorname{rank}d^0-\operatorname{rank}d^1,
$$

characterize vanishing of $H^1$ by exactness, derive a strict rank-deficit criterion for nontrivial obstruction, and establish sharp extremes: a surjective first coboundary forces $H^1=0$, whereas zero differentials give $\dim H^1=\dim C^1$. Consequently, neither overlap-space dimension nor a scalar missing rate determines obstruction dimension. On the combinatorial side, we show that a flag data nerve is recovered exactly from its pairwise-overlap graph: pairwise-compatible charts form higher-order overlap faces. We give matrix algorithms, numerical examples, and a careful account of the limits of probabilistic and statistical interpretations. The results provide a deterministic foundation for future random, spectral, and statistical theories of missing information.

## 1. Introduction

A dataset assembled from partial records is naturally local. One record may cover features $A$ and $B$, another $B$ and $C$, and another $A$ and $C$. The records communicate through overlaps. Agreement on each overlap is necessary for a global reconstruction, but pairwise agreement may fail to be sufficient: discrepancies can circulate around cycles, and pairwise intersections need not encode genuine higher intersections.

This situation parallels a classical gluing problem. Local objects are given on overlapping regions; restriction maps compare them where regions meet; one asks whether compatible local data arise from a global object. Cohomology isolates the obstruction. In the present finite-dimensional linear setting, the mechanism reduces to transparent linear algebra while retaining the essential topology.

The principal message is that missingness is not characterized by quantity alone. The same number of missing entries can produce different overlap networks. Even with the overlap space fixed, different restriction maps can make every residual obstructed or make every residual patchable. An exact calculation must therefore retain both combinatorial incidence and algebraic rank.

The paper makes five contributions. First, it specifies a finite data complex and interprets its first two cohomology groups. Second, it proves an exact information-loss formula. Third, it characterizes exact patchability and gives useful sufficient and necessary rank tests. Fourth, it supplies boundary examples proving non-identifiability from coarse scalar summaries. Fifth, it identifies flagness as the condition under which pairwise overlap data recover all higher faces of the data nerve.

These results are deterministic. They do not establish a universal asymptotic law in the missing rate, a maximum-likelihood interpretation, or superiority over conventional imputers. Instead, they clarify the additional hypotheses required for such claims.

## 2. Local observations as a cochain complex

### 2.1 Data complexes

Let $\Bbbk$ be a field. In numerical applications one may take $\Bbbk=\mathbb{R}$ or $\mathbb{C}$. A **finite data complex** consists of finite-dimensional $\Bbbk$-vector spaces $C^0$, $C^1$, and $C^2$, together with linear maps

$$
d^0:C^0\to C^1,
\qquad
d^1:C^1\to C^2,
$$

satisfying the cochain identity

$$
d^1\circ d^0=0.
$$

The spaces have the following interpretation.

1. $C^0$ contains local observations, local candidate values, or corrections attached to individual charts.
2. $C^1$ contains residuals on pairwise overlaps.
3. $C^2$ contains consistency checks associated with triple overlaps or other second-order relations.

The map $d^0$ sends a local assignment to the discrepancies it induces on overlaps. The map $d^1$ measures whether a pattern of pairwise discrepancies is coherent around higher-order incidences. The identity $d^1d^0=0$ says that every discrepancy induced by actual local corrections automatically passes the higher-order consistency checks.

A standard graph example illustrates the construction. Give each vertex a scalar $x_v$. For an oriented edge $u\to v$, define $(d^0x)_{uv}=x_v-x_u$. Around an oriented triangle $(u,v,w)$, define $d^1y=y_{uv}+y_{vw}+y_{wu}$. Telescoping gives $d^1d^0x=0$.

### 2.2 Cohomology and its interpretation

The **zeroth cohomology** is

$$
H^0=\ker d^0.
$$

Its vectors are local assignments producing no overlap discrepancy. In the data interpretation, these are globally compatible local observations or invisible global modes.

Because $d^1d^0=0$, every vector in $\operatorname{im}d^0$ lies in $\ker d^1$. The **first cohomology** is therefore the quotient

$$
H^1=\ker d^1/\operatorname{im}d^0.
$$

A vector in $\ker d^1$ is a cocycle: a pairwise residual pattern that passes every second-order check. A vector in $\operatorname{im}d^0$ is a coboundary: a pattern explained by modifying local observations. Two cocycles represent the same class when their difference is such an explainable pattern. Thus $H^1$ measures consistent residual patterns that cannot be removed by a local correction.

The distinction between consistency and patchability is essential. Membership in $\ker d^1$ says that no available higher-order check rejects a residual. Membership in $\operatorname{im}d^0$ says that the residual actually arises from an allowable correction. Cohomology measures the gap between these statements.

## 3. Exact accounting of obstruction dimension

We begin with the containment on which the quotient rests.

**Lemma 3.1 (Coboundaries are cocycles).** For every finite data complex,

$$
\operatorname{im}d^0\subseteq\ker d^1.
$$

**Proof sketch.** If $y=d^0x$, then $d^1y=d^1d^0x=0$. Hence $y\in\ker d^1$. $\square$

The main dimension formula follows from two elementary dimension counts.

**Theorem 3.2 (Cohomological Information-Loss Formula).** Let

$$
C^0\xrightarrow{d^0}C^1\xrightarrow{d^1}C^2
$$

be a finite data complex. Then

$$
\dim H^1+\operatorname{rank}d^0+\operatorname{rank}d^1=\dim C^1.
$$

Equivalently,

$$
\dim H^1=\dim C^1-\operatorname{rank}d^0-\operatorname{rank}d^1.
$$

**Proof sketch.** Rank–nullity for $d^1$ gives

$$
\dim\ker d^1=\dim C^1-\operatorname{rank}d^1.
$$

By Lemma 3.1, $\operatorname{im}d^0$ is a subspace of $\ker d^1$. The quotient dimension formula therefore yields

$$
\dim H^1
=\dim\ker d^1-\dim\operatorname{im}d^0
=\dim C^1-\operatorname{rank}d^1-\operatorname{rank}d^0.
$$

Rearranging proves the stated identity. $\square$

The formula divides the ambient overlap space into three dimensional contributions. The term $\operatorname{rank}d^1$ counts residual directions detected by consistency checks. Within the remaining kernel, $\operatorname{rank}d^0$ counts directions removable by local corrections. The remainder is the obstruction dimension.

A useful consequence requires no explicit quotient computation.

**Corollary 3.3 (Strict Rank-Deficit Criterion).** If

$$
\operatorname{rank}d^0+\operatorname{rank}d^1<\dim C^1,
$$

then

$$
\dim H^1>0.
$$

**Proof sketch.** Substitute the strict inequality into Theorem 3.2. $\square$

The cochain identity itself implies the weak inequality

$$
\operatorname{rank}d^0+\operatorname{rank}d^1\leq\dim C^1,
$$

because $\operatorname{im}d^0\subseteq\ker d^1$ and $\dim\ker d^1=\dim C^1-\operatorname{rank}d^1$. Equality is precisely the unobstructed case.

## 4. Exact patchability and boundary regimes

### 4.1 Vanishing and exactness

**Theorem 4.1 (Exact Patchability Criterion).** For a finite data complex, the following conditions are equivalent:

1. $\dim H^1=0$;
2. $H^1$ is the zero vector space;
3. $\ker d^1=\operatorname{im}d^0$.

Thus every locally consistent overlap residual is generated by a degree-zero correction exactly when first cohomology vanishes.

**Proof sketch.** Since $H^1=\ker d^1/\operatorname{im}d^0$ and the denominator is a subspace of the numerator, the quotient is zero exactly when the two spaces coincide. In finite dimensions, zero dimension is equivalent to being the zero space. $\square$

This theorem gives the correct algebraic meaning of complete patchability. It does not claim that a preferred patch is unique. The kernel of $d^0$, namely $H^0$, measures local assignments that do not alter overlap residuals; such modes can create nonuniqueness even when $H^1=0$.

### 4.2 A surjective patch map

**Theorem 4.2 (Surjective Patch Map).** If $d^0:C^0\to C^1$ is surjective, then

$$
\dim H^1=0.
$$

**Proof sketch.** Surjectivity gives $\operatorname{im}d^0=C^1$. The cochain identity forces $d^1$ to vanish on $\operatorname{im}d^0$, hence on all of $C^1$. Therefore $\ker d^1=C^1=\operatorname{im}d^0$, and Theorem 4.1 applies. $\square$

Surjectivity is sufficient but stronger than necessary. Exactness needs only the image of $d^0$ to fill $\ker d^1$, not all of $C^1$.

### 4.3 Zero maps and maximal obstruction

**Theorem 4.3 (Maximal Obstruction for Zero Differentials).** If $d^0=0$ and $d^1=0$, then

$$
H^1\cong C^1
$$

and hence

$$
\dim H^1=\dim C^1.
$$

**Proof sketch.** The zero second map has kernel $C^1$, while the zero first map has image $\{0\}$. Thus $H^1=C^1/\{0\}\cong C^1$. $\square$

In this regime, no overlap residual is rejected and no overlap residual can be corrected. Every ambient residual direction survives as an obstruction.

### 4.4 Non-identifiability from coarse size

**Theorem 4.4 (Obstruction Is Not Determined by Overlap Dimension).** Let two finite data complexes have overlap spaces of the same positive dimension. Suppose the first has $d^0=0$ and $d^1=0$, while the second has a surjective first coboundary. Then their first cohomology dimensions are unequal: the first equals the common overlap dimension and the second equals zero.

**Proof sketch.** Apply Theorems 4.2 and 4.3. Positivity of the common dimension makes the two values distinct. $\square$

This result is a sharp impossibility statement. Any statistic determined solely by $\dim C^1$ assigns the same value to these two systems, yet their obstruction dimensions occupy opposite extremes. A scalar missing rate contains still less structural information: without a generative model connecting that rate to overlap incidence and map ranks, it cannot determine $\dim H^1$.

In particular, a proposed universal scaling law of the form

$$
\dim H^1\approx r^2n\log(1/r),
$$

where $r$ is a missing rate and $n$ a feature count, does not follow in the deterministic setting. It may become a meaningful probabilistic conjecture only after specifying how records, feature subsets, overlap faces, and linear restriction maps are sampled.

## 5. The combinatorics of the data nerve

### 5.1 Nerves and overlap graphs

Let $V$ be a finite set indexing local charts. A **simplicial complex** $K$ on $V$ is a collection of finite subsets of $V$, called faces, that is closed under taking subsets. In a data nerve, a face $\{v_0,\ldots,v_p\}$ records a genuine common overlap among the corresponding local charts.

The **one-skeleton** of $K$ is the graph whose vertices are $V$ and whose edges are the two-element faces of $K$. It remembers pairwise overlaps and forgets higher-order faces.

Given a graph $G$, its **clique complex** is the simplicial complex whose faces are finite cliques: sets of vertices in which every distinct pair is joined by an edge. A simplicial complex is **flag** if every clique in its one-skeleton is already one of its faces.

Flagness is not automatic. Three sets can intersect pairwise while having empty triple intersection. Their nerve contains three edges but no filled triangle. Such a nerve is not flag.

### 5.2 Pairwise data and higher-order faces

**Theorem 5.1 (Pairwise Compatibility Forms a Face in a Flag Nerve).** Let $K$ be a flag data nerve. If a finite set of vertices $S$ has the property that every two distinct vertices in $S$ are adjacent in the one-skeleton of $K$, then $S$ is a face of $K$.

**Proof sketch.** The hypothesis says exactly that $S$ is a clique. By the definition of a flag complex, every clique spans a face. $\square$

**Theorem 5.2 (Flag-Nerve Reconstruction).** If $K$ is a flag data nerve, then

$$
K=\operatorname{Clique}(K^{(1)}),
$$

where $K^{(1)}$ denotes its one-skeleton and $\operatorname{Clique}$ denotes the clique-complex construction. Thus the full nerve is recovered exactly from pairwise-overlap data.

**Proof sketch.** Every face of $K$ has all of its two-element subsets as edges, so it is a clique in $K^{(1)}$. Conversely, Theorem 5.1 makes every clique a face. Hence the face sets coincide. $\square$

The theorem explains when an overlap graph is sufficient input for cohomological analysis. Under flagness, higher faces can be reconstructed by clique enumeration. Without flagness, that procedure may add nonexistent common overlaps and alter $C^2$, $d^1$, and therefore $H^1$.

## 6. Computational algorithms

### 6.1 Dimension of the obstruction space

Choose bases and represent $d^0$ and $d^1$ by matrices $D_0$ and $D_1$. If $D_0$ has shape $m\times p$ and $D_1$ has shape $q\times m$, then $m=\dim C^1$. The cochain condition is

$$
D_1D_0=0.
$$

The first algorithm computes only the dimension.

**Algorithm 6.1 (Rank-Based Obstruction Dimension).**

1. Read matrices $D_0$ and $D_1$ and verify compatible dimensions.
2. Check $D_1D_0=0$, exactly over an exact field or within a stated tolerance numerically.
3. Compute $r_0=\operatorname{rank}D_0$ and $r_1=\operatorname{rank}D_1$.
4. Return $h_1=m-r_0-r_1$.

With dense Gaussian elimination, the rank computations cost at most cubic time in the largest matrix dimension. Sparse or structured complexes can be treated more efficiently.

### 6.2 Representatives of obstruction classes

To obtain representatives rather than only a count, compute a basis matrix $Z$ for $\ker D_1$ and a basis matrix $B$ for $\operatorname{im}D_0$. Since the columns of $B$ lie in the span of $Z$, extend a basis of $B$ to a basis of $\ker D_1$. The added vectors represent a basis of $H^1$.

**Algorithm 6.2 (Obstruction Representative Extraction).**

1. Compute a column basis $B$ of $D_0$.
2. Compute a null-space basis $Z$ of $D_1$.
3. Initialize the accepted basis with the columns of $B$.
4. Scan columns of $Z$; retain a column exactly when it increases the rank of the accepted basis.
5. Return the retained columns as representatives of independent cohomology classes.

The number returned is $\dim\ker D_1-\operatorname{rank}D_0=\dim H^1$. Numerically, rank decisions require a tolerance and should be interpreted spectrally.

### 6.3 Reconstruction of a flag nerve

Given an undirected overlap graph, enumerate its cliques and declare each clique to be a face. This constructs the unique flag complex with that one-skeleton.

**Algorithm 6.3 (Flag-Nerve Reconstruction).**

1. Input the pairwise-overlap graph $G$.
2. Enumerate all cliques of $G$, including vertices and the empty face if desired by convention.
3. Store every clique and all its subsets as faces.
4. Return the resulting clique complex.

Clique enumeration is exponential in the worst case because a graph may have exponentially many cliques. The cost is unavoidable when the output itself is exponential. The procedure reconstructs the original nerve only when flagness is justified by the application.

## 7. Numerical examples

### 7.1 A one-dimensional obstruction

Let

$$
D_0=
\begin{pmatrix}
1&0\\
0&1\\
0&0\\
0&0
\end{pmatrix},
\qquad
D_1=
\begin{pmatrix}
0&0&1&0
\end{pmatrix}.
$$

Then $D_1D_0=0$, $\dim C^1=4$, $\operatorname{rank}D_0=2$, and $\operatorname{rank}D_1=1$. Therefore

$$
\dim H^1=4-2-1=1.
$$

The kernel of $D_1$ is spanned by the first, second, and fourth coordinate vectors. The first two are columns of $D_0$, while the fourth survives as an obstruction representative.

### 7.2 Equal ambient size, opposite outcomes

Take $C^1=\mathbb{R}^3$. In the maximal-obstruction system, let both differentials be zero. Then $\dim H^1=3$.

In the unobstructed system, let $C^0=\mathbb{R}^3$ and $D_0=I_3$, with $D_1=0$. The first map is surjective, so $\dim H^1=0$. Both systems have the same overlap-space dimension, but their patchability differs maximally.

### 7.3 A graph cycle without filled faces

For a connected graph regarded as a one-dimensional complex, scalar vertex values map to edge differences. With no two-dimensional faces, $d^1=0$. If the graph has $v$ vertices and $e$ edges, the incidence map has rank $v-1$, and therefore

$$
\dim H^1=e-v+1.
$$

A tree has $e=v-1$ and no obstruction. A four-cycle has $e=v=4$ and one obstruction. This familiar cycle rank is the simplest topological manifestation of missing global information.

If all cliques are filled, a triangle receives a two-dimensional face and its boundary cycle is detected by $d^1$. This illustrates how higher overlap information can remove a would-be obstruction.

## 8. Statistical interpretation and limitations

The deterministic complex supports least-squares procedures. Given observed overlap residuals $y\in C^1$, one may choose a local correction $x\in C^0$ minimizing

$$
\|d^0x-y\|^2.
$$

This projects $y$ onto $\operatorname{im}d^0$. The orthogonal residual measures the component not explainable by local corrections. If $y\in\ker d^1$, its residual class lies in $H^1$ after choosing compatible inner products.

However, least squares is not automatically maximum likelihood. That conclusion requires an explicit model, for example Gaussian noise in $C^1$ with a specified covariance. A posterior mean additionally requires a prior on $C^0$ and treatment of the null space $H^0$. Similarly, claims about excess risk require a loss function and a sampling distribution.

The exact results also do not rank mean imputation, nearest-neighbor imputation, multiple imputation by chained equations, or any other statistical method. Such comparisons must specify synthetic or empirical datasets, missingness mechanisms, hyperparameters, and evaluation metrics. Cohomology supplies structural covariates and impossibility diagnostics that can inform those experiments.

The scalar missing rate $r$ is best viewed as one random-model parameter, not as a sufficient statistic for topology. A model may relate $r$ to the probability of edges and higher faces in a random nerve, while separate assumptions govern the ranks of restriction maps. Theorem 3.2 indicates that both sources of randomness are required.

## 9. Discussion

The information-loss formula is elementary in derivation but consequential in interpretation. It distinguishes three kinds of overlap direction: inconsistent directions removed by $d^1$, correctable directions supplied by $d^0$, and genuine obstruction directions represented by $H^1$. This trichotomy prevents the common conflation of local consistency with global reconstructibility.

The boundary theorems show that topology cannot be inferred from ambient size. Even perfect knowledge of $\dim C^1$ leaves $\dim H^1$ undetermined. In data language, counting available pairwise comparisons does not reveal whether their discrepancies are independent, redundant, detectable, or correctable.

The flag results add a complementary combinatorial warning. Pairwise overlaps determine higher intersections only under a structural assumption. When flagness holds, graph methods are exact. When it fails, replacing the nerve by its clique complex changes the model rather than merely simplifying it.

These observations suggest a two-layer methodology. First construct the incidence structure of local records and determine whether pairwise data justify a flag completion. Then construct the linear restriction maps and compute rank or spectral information. Neither layer substitutes for the other.

## 10. Future work

A natural first direction is a random-nerve obstruction threshold. Under Bernoulli missingness, one may ask whether normalized first cohomology exhibits a sharp transition tied to cycle emergence in a random flag complex. The exact formula indicates that random incidence and random map rank must be tracked jointly.

A second direction is a two-parameter replacement for a scalar missing-rate law. Candidate observables include the cycle rank of the overlap nerve and the expected rank defect of restriction maps. The maximal and vanishing boundary cases provide calibration points for falsifying proposed asymptotics.

Third, noisy data call for approximate cohomology. Over $\mathbb{R}$ or $\mathbb{C}$, singular values near zero can replace exact nullity. Perturbation bounds based on spectral gaps could distinguish stable structural obstruction from accidental numerical near-dependence.

Fourth, an explicit Gaussian sheaf model could connect least squares to posterior estimation. Under specified priors and noise covariances, zero eigenvalues of a first sheaf Laplacian should capture irreducible cohomological risk, while small positive eigenvalues quantify instability.

Finally, empirical work can test whether cohomological and spectral summaries predict the performance gap among imputation methods better than missing rate alone. Such experiments should preserve the distinction between deterministic identities and model-dependent statistical conclusions.

## 11. Conclusion

Incomplete data possess both an amount and an arrangement. The arrangement is encoded by an overlap nerve and by linear maps comparing local observations. For the resulting finite data complex, first cohomology has the exact dimension

$$
\dim H^1=\dim C^1-\operatorname{rank}d^0-\operatorname{rank}d^1.
$$

It vanishes exactly when every locally consistent discrepancy is generated by a local correction. Surjectivity of the patch map guarantees this outcome; zero differentials produce the opposite extreme. Hence no scalar missing-rate statistic can determine obstruction without assumptions linking it to incidence and rank. If the data nerve is flag, pairwise overlaps recover all higher faces; otherwise they do not.

The resulting framework is a precise structural theory of missing information. It identifies what local tests reject, what local corrections repair, and what survives as a genuine global obstruction.
