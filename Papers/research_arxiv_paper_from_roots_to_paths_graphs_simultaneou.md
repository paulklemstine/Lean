# Affine Separation and Compensation in Rooted and Ordinary Path Irregularity

## Abstract

Let $P_3$ denote the three-vertex path. For a vertex $v$ of a finite simple graph, one may count copies of $P_3$ containing $v$ without prescribing its role, or count only copies in which $v$ occupies a specified rooted position. This paper develops two complementary principles for such statistics. First, a finite family of nonnegative affine profiles $c_{i,v}+t m_{i,v}$ becomes simultaneously injective in the object variable once the parameter $t$ exceeds a common intercept bound, provided that each statistic has pairwise distinct slopes. This gives a uniform algebraic criterion for parametrized constructions intended to separate many rooted and ordinary path counts at once. Second, exact local formulas for $P_3$ reveal a sharp obstruction and a compensation law. The central-root count is $\binom{d(v)}2$, so no finite simple graph with at least two vertices can be irregular with respect to the central root. The end-root count is $\sum_{u\sim v}(d(u)-1)$, and the ordinary count is the sum of the central and end-root counts. Consequently, ordinary $P_3$ irregularity forces distinct end-root counts on every pair of distinct equal-degree vertices. Every nontrivial ordinary-$P_3$-irregular graph therefore contains a pair with equal central counts and unequal end counts. A six-vertex example shows that ordinary irregularity need not imply global end-root irregularity, establishing the precise scope of the compensation principle. Algorithms and numerical examples are given for computing the statistics and testing affine certificates.

## 1. Introduction

Counting subgraphs through vertices is a natural method for measuring local asymmetry. Fix a graph pattern $F$. The number of copies of $F$ containing a vertex can be treated as a numerical label. If all labels are distinct, the host graph is $F$-irregular: every vertex is distinguished by its incidence with the pattern. A rooted version retains more information. After selecting a root $r$ in $F$, one counts only copies in which the host vertex plays the role of $r$.

Paths make the distinction especially transparent. In the three-vertex path $P_3$, the central position and the two endpoint positions form different symmetry orbits. Rooting at the center asks only how many unordered pairs of neighbors a vertex has. Rooting at an endpoint probes one additional step into the graph and therefore depends on neighboring degrees. The ordinary count combines both views.

Two questions motivate the present work. First, how can one prove that many rooted and ordinary statistics are simultaneously injective in a parametrized family? Directly comparing every pair of vertices for every statistic quickly becomes cumbersome. Second, what exact relationship holds among the central-root, end-root, and ordinary $P_3$ counts?

The first question has a general algebraic answer. Suppose the relevant statistics are affine in a common nonnegative integer parameter $t$:

$$
A_{i,v}(t)=c_{i,v}+t m_{i,v}.
$$

If the intercepts have a common bound and the slopes are injective across vertices for every statistic, then every profile is injective once $t$ exceeds that bound. This converts simultaneous irregularity into two finite tasks: control lower-order terms and separate leading coefficients.

The second question is answered by exact identities. Writing $C(v)$ for the central-root count, $E(v)$ for the end-root count, and $O(v)$ for the ordinary count, one has

$$
C(v)=\binom{d(v)}2,\qquad
E(v)=\sum_{u\sim v}(d(u)-1),\qquad
O(v)=C(v)+E(v).
$$

The first formula combines with the repeated-degree principle for finite simple graphs to rule out nontrivial central-root irregularity. The decomposition then shows that, in an ordinary-irregular graph, every equal-degree pair must be separated by its end-root counts. This is a compensation phenomenon: a collision in one summand forces separation in another if their sum is injective.

The results are deliberately modular. The affine theorem applies to arbitrary finite collections of integer-valued statistics, not only path counts. The $P_3$ analysis identifies both a reusable obstruction—degree-determined rooted statistics cannot be injective—and the exact limit of an inference from ordinary to rooted irregularity.

## 2. Graph-theoretic definitions

Throughout, $G=(V,E)$ is a finite simple undirected graph. Thus $V$ is finite, edges are unordered pairs of distinct vertices, and no edge occurs more than once. We write $u\sim v$ when $u$ and $v$ are adjacent, and

$$
N(v)=\{u\in V:u\sim v\},\qquad d(v)=|N(v)|
$$

for the open neighborhood and degree of $v$.

The path $P_3$ has vertex set $\{a,b,c\}$ and edges $\{a,b\}$ and $\{b,c\}$. Its center is $b$, while $a$ and $c$ are endpoints. A copy of $P_3$ in $G$ means a subgraph obtained from three distinct host vertices with two selected edges forming such a path. Extra host edges among those vertices do not prevent a non-induced path copy; equivalently, a copy is determined by a choice of center and two distinct incident edges.

**Definition 2.1 (central-root count).** For $v\in V$, let $C_G(v)$ be the number of copies of $P_3$ in which $v$ is the central vertex.

**Definition 2.2 (end-root count).** For $v\in V$, let $E_G(v)$ be the number of copies of $P_3$ in which $v$ is one of the two endpoints. Each unrooted path containing $v$ as an endpoint is counted once, regardless of which abstract endpoint is designated, since the two endpoints belong to one symmetry orbit.

**Definition 2.3 (ordinary count).** For $v\in V$, let $O_G(v)$ be the number of copies of $P_3$ containing $v$ in any position.

**Definition 2.4 (irregular statistic).** A vertex statistic $f:V\to\mathbb N$ is irregular on $G$ if it is injective. The graph is central-root $P_3$-irregular, end-root $P_3$-irregular, or ordinary $P_3$-irregular when $C_G$, $E_G$, or $O_G$, respectively, is injective.

This language extends naturally to longer paths and different root positions, but $P_3$ already exhibits a fundamental root-dependent obstruction.

## 3. Exact formulas for three-vertex paths

We begin with identities that reduce path enumeration to degree data.

**Lemma 3.1 (central-root formula).** For every vertex $v$,

$$
C_G(v)=\binom{d(v)}2.
$$

**Proof sketch.** A path centered at $v$ consists of two distinct edges incident with $v$. Choosing it is equivalent to choosing an unordered two-element subset of $N(v)$. There are $\binom{|N(v)|}{2}=\binom{d(v)}2$ such choices. If the selected neighbors are themselves adjacent, the two selected edges still form a non-induced copy of $P_3$, so no correction term is required. $\square$

**Lemma 3.2 (end-root formula).** For every vertex $v$,

$$
E_G(v)=\sum_{u\in N(v)}(d(u)-1).
$$

**Proof sketch.** A path having $v$ as an endpoint is uniquely described by its neighbor $u$, which is the center, and its other endpoint $w\in N(u)\setminus\{v\}$. For fixed $u\in N(v)$ there are $d(u)-1$ choices for $w$. Summing over $u$ counts every end-rooted copy exactly once. $\square$

**Lemma 3.3 (role decomposition).** For every vertex $v$,

$$
O_G(v)=C_G(v)+E_G(v).
$$

**Proof sketch.** In every copy of $P_3$ containing $v$, the vertex $v$ is either the unique center or one of the endpoints, never both. These two classes are disjoint and exhaustive, so their cardinalities add. $\square$

Together the formulas yield the explicit ordinary statistic

$$
O_G(v)=\binom{d(v)}2+\sum_{u\in N(v)}(d(u)-1).
$$

The two terms differ sharply in information content. The central term depends only on $d(v)$. The end term depends on the multiset of degrees in $N(v)$ and therefore samples the radius-two environment.

## 4. The central-root obstruction

The following elementary degree principle is decisive.

**Lemma 4.1 (repeated-degree principle).** Every finite simple graph on at least two vertices has two distinct vertices of equal degree.

**Proof sketch.** Let $|V|=N\ge2$. Every degree belongs to $\{0,1,\ldots,N-1\}$. Degrees $0$ and $N-1$ cannot both occur: a vertex of degree $N-1$ is adjacent to every other vertex, including any proposed isolated vertex. Hence the graph realizes values from a set of at most $N-1$ possible degrees. The pigeonhole principle gives two vertices with the same degree. $\square$

**Theorem 4.2 (central-root impossibility).** No finite simple graph with at least two vertices is central-root $P_3$-irregular.

**Proof sketch.** By Lemma 4.1, choose distinct $v,w$ with $d(v)=d(w)$. Lemma 3.1 gives

$$
C_G(v)=\binom{d(v)}2=\binom{d(w)}2=C_G(w),
$$

so $C_G$ is not injective. $\square$

The argument proves a more general principle.

**Proposition 4.3 (degree-determined obstruction).** Let $f_G(v)=\phi(d(v))$ for some function $\phi$ from nonnegative integers to any set. On every finite simple graph with at least two vertices, $f_G$ is noninjective.

**Proof sketch.** Apply Lemma 4.1 and then apply $\phi$ to the equal degrees. $\square$

This formulation clarifies what makes the center of $P_3$ exceptional. The obstruction does not arise merely from symmetry of the root in the pattern; it arises because the rooted-copy count collapses to a function of degree alone.

## 5. Compensation between rooted positions

Although the center cannot distinguish all vertices, its failures interact rigidly with ordinary irregularity.

**Theorem 5.1 (degree-collision compensation).** Let $G$ be ordinary $P_3$-irregular. If $v\ne w$ and $d(v)=d(w)$, then

$$
E_G(v)\ne E_G(w).
$$

**Proof sketch.** Equal degrees give $C_G(v)=C_G(w)$ by Lemma 3.1. If also $E_G(v)=E_G(w)$, then Lemma 3.3 yields

$$
O_G(v)=C_G(v)+E_G(v)=C_G(w)+E_G(w)=O_G(w),
$$

contradicting injectivity of $O_G$. $\square$

The theorem says more than the tautology that unequal totals require some unequal summand. It identifies a natural collision class—vertices of equal degree—on which the central summand is forced to agree. Within each such class, end-root counts must be injective whenever ordinary counts are injective.

**Corollary 5.2 (existence of a compensating pair).** Every ordinary-$P_3$-irregular finite simple graph with at least two vertices contains distinct vertices $v,w$ satisfying

$$
C_G(v)=C_G(w)\quad\text{and}\quad E_G(v)\ne E_G(w).
$$

**Proof sketch.** Lemma 4.1 supplies distinct vertices of equal degree. Their central counts agree by Lemma 3.1, and their end-root counts differ by Theorem 5.1. $\square$

A tempting but invalid strengthening would assert that ordinary irregularity implies end-root irregularity. The next example refutes it.

**Example 5.3 (ordinary irregularity without end-root irregularity).** Let $G$ have vertices $0,1,2,3,4,5$ and edge set

$$
\bigl\{\{0,2\},\{0,3\},\{0,5\},\{1,2\},\{1,4\},\{2,3\}\bigr\}.
$$

The degree, central-root, end-root, and ordinary profiles are respectively

$$
\begin{aligned}
d&=(3,2,3,2,1,1),\\
C&=(3,1,3,1,0,0),\\
E&=(3,2,4,4,1,2),\\
O&=(6,3,7,5,1,2).
\end{aligned}
$$

These values follow directly from Lemmas 3.1–3.3. Every entry of $O$ is distinct, so $G$ is ordinary $P_3$-irregular. Yet $E(2)=E(3)=4$ and $E(1)=E(5)=2$, so $G$ is not end-root $P_3$-irregular.

There is no conflict with Theorem 5.1. Vertices $2$ and $3$ have degrees $3$ and $2$, while vertices $1$ and $5$ have degrees $2$ and $1$. Their central counts differ and can therefore separate equal end counts in the ordinary sum. The theorem is thus sharp with respect to the equal-degree hypothesis.

## 6. Affine count profiles

We now isolate the asymptotic mechanism used when multiple statistics arise from one parametrized construction.

**Definition 6.1 (affine profile).** For nonnegative integers $c,m,t$, define

$$
A(c,m;t)=c+tm.
$$

Here $c$ is the intercept, $m$ the slope, and $t$ the construction parameter.

**Lemma 6.2 (ordered-slope inequality).** Let $c_1,c_2,m_1,m_2,t,B$ be nonnegative integers. If

$$
c_1\le B,\qquad B<t,\qquad m_1<m_2,
$$

then

$$
c_1+tm_1<c_2+tm_2.
$$

**Proof sketch.** Since $m_1<m_2$ and the slopes are integral, $m_2\ge m_1+1$. Thus

$$
c_1+tm_1\le B+tm_1<t+tm_1=t(m_1+1)\le tm_2\le c_2+tm_2.
$$

Nonnegativity of $c_2$ supplies the final inequality. $\square$

The lemma deliberately bounds only $c_1$. In a comparison ordered by slope, the intercept attached to the larger slope can only help.

**Theorem 6.3 (simultaneous affine separation).** Let $I$ be a finite set of statistics and $V$ a finite set of objects. For each $i\in I$ and $v\in V$, let $c_{i,v},m_{i,v}\in\mathbb N$. Suppose that:

1. a number $B\in\mathbb N$ satisfies $c_{i,v}\le B$ for all $i\in I$ and $v\in V$;
2. for every fixed $i\in I$, the map $v\mapsto m_{i,v}$ is injective.

Then, for every integer $t>B$ and every $i\in I$, the map

$$
V\longrightarrow\mathbb N,\qquad v\longmapsto c_{i,v}+t m_{i,v}
$$

is injective. In particular, all statistics in the finite family separate all objects simultaneously at the same parameter value.

**Proof sketch.** Fix $i$ and distinct $v,w$. Injectivity of the slopes gives $m_{i,v}\ne m_{i,w}$. After exchanging $v$ and $w$ if necessary, assume $m_{i,v}<m_{i,w}$. Lemma 6.2, applied with $c_1=c_{i,v}$ and $c_2=c_{i,w}$, gives

$$
c_{i,v}+tm_{i,v}<c_{i,w}+tm_{i,w}.
$$

Hence the profile values differ. The argument applies to every $i$ under the same bound and parameter. $\square$

**Remark 6.4 (sharpness of the strict threshold).** The condition $t>B$ cannot generally be weakened to $t\ge B$. Let $c_1=B$, $m_1=0$, $c_2=0$, and $m_2=1$. At $t=B$ the two profiles both equal $B$, despite distinct slopes. For $t>B$, the second profile is strictly larger.

**Remark 6.5 (why a common bound exists).** For finite $I$ and $V$, any fixed collection of intercepts has a maximum

$$
B=\max\{c_{i,v}:i\in I,\ v\in V\}.
$$

Thus the substantive construction requirement is slope injectivity. Finiteness then turns all intercept control into one threshold.

## 7. Algorithms

The preceding formulas lead to direct computational procedures.

### 7.1 Computing all $P_3$ profiles

Given adjacency lists, first compute every degree. Then, for each vertex $v$, compute

$$
C(v)=\frac{d(v)(d(v)-1)}2,
$$

and sum $d(u)-1$ over neighbors $u$ to obtain $E(v)$. Set $O(v)=C(v)+E(v)$.

With $n=|V|$ and $m=|E|$, degrees require $O(n+m)$ time in adjacency-list representation. The neighbor sums traverse each edge twice and also take $O(n+m)$ time. The total memory usage is $O(n+m)$ including the graph, or $O(n)$ auxiliary memory. Injectivity tests use a set and require expected $O(n)$ time.

### 7.2 Verifying an affine certificate

For finite arrays of intercepts and slopes indexed by statistics and objects, calculate the maximum intercept $B$. For each statistic, test whether its slope row contains duplicates. If every row is duplicate-free, then $t=B+1$ is a certified simultaneous-separation parameter. For $p=|I|$ statistics and $n=|V|$ objects, scanning and hash-based duplicate detection take expected $O(pn)$ time and $O(n)$ temporary memory.

### 7.3 Auditing compensation

Given a graph whose ordinary profile is injective, group vertices by degree. Within each group, verify that end-root values are distinct. Theorem 5.1 guarantees success; the procedure provides a transparent diagnostic and identifies compensating pairs. Hashing degrees and end counts gives expected $O(n+m)$ total time once profiles are computed.

## 8. Applications and interpretation

The affine theorem is suited to graph families formed by attaching parameter-dependent branches or gadgets. For a bounded path length, a path can interact with only a bounded portion of the construction. Counts frequently decompose into a bounded background contribution and a term proportional to the number of repeated attachments. The repeated contribution is the slope. Designing vertexwise distinct slopes therefore makes a shared large parameter amplify local asymmetry.

The theorem is stronger than proving eventual separation independently for each pair. It gives a single explicit threshold, derived from a uniform intercept bound, that works for every statistic and object simultaneously. This is particularly useful when $I$ records several path lengths and several root positions.

The $P_3$ formulas also suggest a hierarchy of information. Central counts depend on the degree of the root. End counts depend on the degrees of its neighbors. Longer rooted paths sample progressively wider neighborhoods. Ordinary counts combine root-position contributions, so collisions in lower-information components may be repaired by higher-information components.

Outside pure graph theory, the same structure appears in network fingerprints. A central-root count measures pairs of immediate contacts. An end-root count measures the number of available two-step continuations. Their sum measures all length-two path incidences through a node. Such signatures can describe communication networks, molecular graphs, transportation systems, and motif-based network data, although practical use would require accounting for noise, weights, and direction.

## 9. Limitations

The affine separation theorem is a sufficient criterion, not a graph-existence theorem. It does not itself produce attachments whose path counts have the required slopes. Establishing affine formulas and slope injectivity remains a construction-specific combinatorial problem.

The result also treats only degree-one polynomial dependence. Counts in richer attachment families may be quadratic or of higher degree. Distinct leading coefficients suffice asymptotically in that setting, but equal leading coefficients require comparison at the first coefficient where profiles differ.

For $P_3$, the analysis concerns non-induced subgraph copies. If one counts induced paths, triangles alter the central formula and the degree-only obstruction no longer follows in the same form. Directed, weighted, infinite, or non-simple graphs likewise require modified definitions.

Finally, the compensation theorem is conditional on ordinary irregularity and local to equal-degree classes. Example 5.3 proves that it cannot be promoted to global end-root irregularity without additional assumptions.

## 10. Future work

A first extension is a polynomial-profile separation theorem. For each pair of objects, one would compare coefficient vectors from highest degree downward and require the first unequal coefficient to have a consistent strict order. Finiteness should again yield a common threshold beyond which all profiles separate.

A second direction concerns simultaneous rooted and ordinary counts for bounded path lengths. In branch-attachment constructions, bounded paths enter only boundedly many branches, suggesting bounded-degree polynomial profiles with locally computable leading terms.

A third direction replaces paths by rooted trees. Tree embeddings decompose recursively across branches, potentially converting attachment counts into sums and products of local profiles. The $P_3$ center shows that root orbits must be screened for degree-determined obstructions.

A fourth problem is to characterize rooted patterns $(F,r)$ for which the rooted-copy count is a function of host degree alone. Such patterns cannot support nontrivial rooted irregularity in finite simple graphs. A possible converse asks whether patterns outside this class admit infinite families of rooted-irregular hosts.

Finally, the compensation law invites a longer-path hierarchy. Ordinary $P_n$ counts decompose into contributions from root-position orbits. If two vertices collide on lower-order local invariants, injectivity of the total may force separation in a more distant rooted contribution.

## 11. Conclusion

Three-vertex paths already display the essential interaction among roots, local information, and simultaneous separation. The center-root statistic equals $\binom{d(v)}2$ and therefore can never distinguish every vertex of a nontrivial finite simple graph. The endpoint statistic reaches one step farther. When ordinary $P_3$ counts are injective, it must distinguish every equal-degree pair, guaranteeing a compensating pair with equal central counts and unequal end counts. Yet a concrete six-vertex graph shows that end-root injectivity need not hold globally.

For parametrized constructions, the simultaneous affine separation theorem supplies a uniform engine: bounded intercepts and injective slopes imply simultaneous injectivity for every parameter beyond one explicit threshold. The local graph identities identify what information is available; the affine theorem explains how that information can be amplified. Together they provide a precise foundation for constructing and analyzing graphs whose vertices are distinguished by rooted and ordinary path incidence.
A practical merit of this framework is its separation of discovery from certification. Numerical experiments may suggest useful attachments, slope patterns, or collision classes, but the final argument requires only exact counting identities and finite inequalities. The threshold $B+1$ is transparent, reproducible, and independent of heuristic sampling. Likewise, the compensation theorem turns an observed pattern among degree classes into a necessary structural condition. This combination of exploratory accessibility and exact conclusions makes rooted path profiles a useful testing ground for broader theories of graph irregularity.
