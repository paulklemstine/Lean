# When Shape Survives Noise: A Finite Stability Core for Persistent Homology

## A geometry of data that refuses to be brittle

A point cloud can be a scan of a bone, a sample from a turbulent flow, a constellation of molecular conformations, or a collection of customers embedded by similarity. In each case the data arrive not as a polished geometric object but as scattered points equipped with distances. Those distances are never exact. Sensors wobble, coordinates are rounded, samples are sparse, and the metric itself may be estimated.

Topological data analysis asks a deliberately qualitative question: what shape persists despite those uncertainties? Its central device is *persistent homology*. Instead of choosing one distance threshold and declaring points connected, one lets the threshold grow. Components merge, loops appear and disappear, and cavities fill in. The lifetimes of these features form a compressed geometric signature called a persistence diagram.

A useful signature must be stable. If every measured distance changes only slightly, the resulting diagram should move only slightly. This article develops a precise finite version of that principle for connected components, the zeroth homology group usually denoted $H_0$. The setting is intentionally concrete: two distance tables use the same finite labels, and finite persistence diagrams are compared by bijective matchings. The key conclusion is simple and sharp:

> If corresponding edge lengths differ by at most $\delta$, then the death times in a certified tree representation of $H_0$ can be matched within $\delta/2$.

The factor $1/2$ is not cosmetic. It records the convention that a Vietoris--Rips edge appears at radius $r$ when its length is at most $2r$.

## Turning a cloud into a growing graph

Let $I$ be a finite set of labels and let $d(i,j)$ be a distance table. At radius $r$, build a graph with vertex set $I$ and place an edge between $i$ and $j$ whenever

$$
d(i,j)\le 2r.
$$

This is the one-dimensional skeleton of the radius-parametrized Vietoris--Rips construction. At very small radii, most vertices are isolated. As $r$ increases, edges accumulate. Because edges are only added, connected components can merge but can never split.

The number of connected components at radius $r$ is the zeroth Betti number, written $\beta_0(r)$. Every component is regarded as born at radius $0$. Whenever an edge joins two previously separate components, one component class dies. Thus the finite death times record the scales at which the cloud coalesces.

Imagine a night-time aerial view of islands during a rising flood, but in reverse: as the radius increases, bridges become available between islands. The sequence of mergers is a geometric fingerprint. Dense clusters connect early; distant clusters remain separate longer.

## Distortion becomes a shift in scale

Suppose a second distance table $e(i,j)$ is defined on the same labels and satisfies the uniform distortion bound

$$
|d(i,j)-e(i,j)|\le \delta
$$

for every pair $i,j$. This says that no pairwise measurement changes by more than $\delta$.

Now take an edge present for $d$ at radius $r$. Its length obeys $d(i,j)\le 2r$. The distortion bound gives

$$
e(i,j)\le d(i,j)+\delta\le 2r+\delta=2\left(r+\frac{\delta}{2}\right).
$$

Therefore that same edge is present for $e$ at radius $r+\delta/2$. Absolute value makes the comparison symmetric, so the same argument works with $d$ and $e$ exchanged.

This is the **Rips Interleaving Theorem** in the present finite, common-label setting: if two distance tables differ uniformly by at most $\delta$, then each Rips graph at radius $r$ embeds edge-for-edge into the other graph at radius $r+\delta/2$, in both directions.

That two-way inclusion is called an interleaving. It says that neither filtration can run more than $\delta/2$ ahead of the other. The statement is elementary enough to fit in one inequality, yet it is the metric engine of stability.

## Why connected components behave monotonically

Adding edges can only identify components. If every edge in a graph $G$ also appears in a graph $H$ on the same vertices, then any path in $G$ is a path in $H$. Consequently each component of $G$ lies inside a component of $H$, and

$$
\beta_0(H)\le \beta_0(G).
$$

Combining this fact with the interleaving gives the **Zeroth-Betti Stability Step**:

$$
\beta_0\!\left(e,r+\frac{\delta}{2}\right)\le \beta_0(d,r),
$$

whenever the relevant component sets are finite. The reverse inequality with $d$ and $e$ exchanged follows in the same shifted form. In words, after allowing a delay of $\delta/2$, the perturbed graph is at least as connected as the original graph was.

This rank-level statement is valuable because it needs no coordinates, no smoothness, and not even the triangle inequality for the distance tables. It depends only on a uniform comparison of pairwise values and the monotonicity of connectivity.

## From merger times to persistence diagrams

A persistence-diagram point is a pair $(b,t)$ recording birth time $b$ and death time $t$. For $H_0$ in the present convention, finite classes are born at $0$, so their points have the form $(0,t)$.

The distance between two diagram points $p=(b,t)$ and $q=(b',t')$ is the $L^\infty$ distance

$$
d_\infty(p,q)=\max\{|b-b'|,|t-t'|\}.
$$

For two finite diagrams indexed by the same nonempty finite set, define their finite bottleneck distance as the infimum, over all bijections between their indices, of the largest pointwise $L^\infty$ distance. Equivalently, one seeks the matching that makes the worst matched pair as close as possible.

This definition immediately yields the **Explicit Matching Bound**: if one exhibits a bijection under which every matched pair is at distance at most $\varepsilon$, where $\varepsilon\ge 0$, then the finite bottleneck distance is at most $\varepsilon$. The reason is direct: the best possible matching can do no worse than a particular admissible matching.

That observation is algorithmically important. Exact optimization may be expensive, but any explicit correspondence supplies a certified upper bound.

## Trees store the history of merging

For connected components, a spanning tree is a compact merger certificate. Suppose its edges are indexed by a nonempty finite set $K$, and edge $k$ has weight $w_k$. Under the rule $w_k\le 2r$, that edge becomes available at radius $w_k/2$. Associate to it the diagram point

$$
\left(0,\frac{w_k}{2}\right).
$$

The resulting collection is the tree-encoded $H_0$ diagram. It packages each certified merger as a finite bar beginning at $0$ and ending when its edge appears.

Now compare two tree certificates with the same edge labels and weights $w_k$ and $v_k$. Assume

$$
|w_k-v_k|\le \delta
$$

for every $k$, with $\delta\ge 0$. Match edge $k$ to edge $k$. The birth coordinates agree, while the death coordinates satisfy

$$
\left|\frac{w_k}{2}-\frac{v_k}{2}\right|
=\frac{|w_k-v_k|}{2}
\le \frac{\delta}{2}.
$$

The explicit matching bound now proves the **Certified Tree Stability Theorem**: the finite bottleneck distance between the two tree-encoded $H_0$ diagrams is at most $\delta/2$.

This theorem isolates the whole pipeline: metric perturbation controls edge thresholds; edge thresholds control merger times; an identity matching controls bottleneck distance.

## The smallest example is already sharp

Take two clouds, each consisting of two labeled points. In the first cloud the distinct points are distance $2$ apart; in the second they are distance $3$ apart. Diagonal distances remain $0$, so the largest discrepancy in their distance tables is exactly

$$
|2-3|=1.
$$

Thus $\delta=1$. Each cloud has one finite $H_0$ merger. In the first it occurs at radius $2/2=1$; in the second it occurs at radius $3/2$. Their persistence points are

$$
(0,1)\qquad\text{and}\qquad\left(0,\frac32\right).
$$

The $L^\infty$ distance between them is $1/2$. There is only one possible matching, so the bottleneck distance is exactly $1/2$. The stability estimate gives the same value:

$$
d_B\le \frac{\delta}{2}=\frac12.
$$

Nothing is lost. The factor $1/2$ is therefore sharp under the chosen radius normalization.

## What the result does—and does not—say

The argument provides a rigorous finite stability core. It covers common labels, equal-size finite diagrams, and tree certificates whose corresponding edge weights are uniformly close. It also gives a two-way interleaving of Rips edge relations and the resulting monotonicity of component counts.

It does not by itself establish the most general stability theorem for arbitrary compact metric spaces, unequal diagram cardinalities, or higher-dimensional holes. Those settings require additional ideas. Unequal diagrams need diagonal points and partial matchings. Unlabeled spaces require correspondences rather than a shared index set. Higher homology needs maps of simplicial complexes and an argument that different representative choices induce compatible maps.

The connection to Gromov--Hausdorff geometry is nevertheless visible. For finite spaces, the Gromov--Hausdorff distance is governed by half the least distortion of a correspondence. The same half-distortion appears here because edges are activated at twice the radius. A complete correspondence-based theory would turn that numerical alignment into the familiar global stability statement.

## A practical robustness certificate

The finite theorem can already guide data analysis. If a pipeline obtains a tree certificate—most naturally from a minimum spanning tree—and every certified edge length has uncertainty at most $\delta$, then every encoded finite $H_0$ death time moves by at most $\delta/2$ under the same edge matching. A practitioner can therefore attach an error bar to the diagram without rerunning a global topological argument.

This matters wherever clustering decisions depend on scale. In sensor networks, it bounds how much uncertain range measurements can shift the moment the network becomes connected. In single-linkage clustering, it controls dendrogram merge heights. In geometric reconstruction, it separates robust gaps from those comparable to measurement noise. In all three cases, the same mathematics is at work: connectivity is persistent because bounded distance error can only delay or accelerate an edge by a bounded amount.

The broader lesson is that topological stability need not begin with sophisticated machinery. It begins with a disciplined choice of scale and one transparent inequality. When distances move by $\delta$, radius thresholds move by $\delta/2$; when thresholds move together, merger histories remain close. Shape survives noise because the graph cannot change too early or too late.