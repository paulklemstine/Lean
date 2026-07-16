# Infinite Paths, Changing Labels, and the Hidden Geometry of Clusters

## How finite decisions govern infinite spaces

An infinite path is an object that can never be inspected all at once. Whether it is a route through a growing network, an unending stream of symbols, or a sequence of increasingly precise measurements, we only ever see finite beginnings. Yet those beginnings carry remarkable power. They can determine which infinite objects are possible, when two such objects are close, and even whether two apparently different universes of paths have exactly the same topological shape.

The mathematics developed here begins with this simple observation and follows it in two directions. The first concerns **ray spaces**: spaces whose points are infinite paths through a tree of allowable finite words. The second concerns **valuation clusters** on the rational numbers: nested arithmetic neighborhoods defined by divisibility by a prime. At first these subjects look unrelated. One is combinatorial and topological; the other is number-theoretic. Their common principle is that infinite or global structure is controlled by compatible finite information.

That principle yields two central conclusions. First, changing every coordinate label by a homeomorphic relabelling changes the appearance of a coordinate tree but not the topology of its ray space. Better still, the relabelling itself explicitly constructs the homeomorphism. Second, prime-adic threshold clusters obey a rigid nesting law: if a point belongs to a cluster, it may replace the original center without changing the cluster. The resulting neighborhoods form a laminar hierarchy, like branches of a rooted tree, rather than the overlapping circles familiar from Euclidean geometry.

## Trees made from words

Fix a set $A$, called an alphabet. A finite word over $A$ is a list such as $(a_0,a_1,\ldots,a_{n-1})$. A **coordinate tree** $T$ over $A$ is a collection of finite words satisfying two conditions:

1. the empty word belongs to $T$;
2. whenever a word belongs to $T$, every initial segment of that word also belongs to $T$.

The second condition is prefix closure. It says that one cannot arrive at an allowed finite history through a forbidden earlier history.

A **ray** through $T$ is an infinite sequence $x=(x_0,x_1,x_2,\ldots)$ such that every finite initial segment

$$
(x_0,x_1,\ldots,x_{n-1})
$$

belongs to $T$. The **ray space** $[T]$ is the set of all such rays.

To make $[T]$ a topological space, regard each coordinate as discrete and use the product topology. Concretely, two rays are close when they agree for a long initial stretch. A basic neighborhood of a ray is obtained by fixing one of its finite prefixes and allowing the rest of the path to vary freely, subject to remaining in the tree. This topology captures the practical meaning of finite observation: no finite measurement can distinguish two rays that have not yet separated.

The full binary tree is the cleanest example. Its alphabet is $\{0,1\}$, and every finite binary word is allowed. Its ray space consists of all infinite binary sequences. The constant-zero sequence is one ray; so is the alternating sequence $0,1,0,1,\ldots$. More generally, any system of legal finite states that is closed under forgetting the future defines a coordinate tree.

## Repainting every branch

Suppose one replaces the alphabet $A$ by another topological alphabet $B$. Let $e:A\to B$ be a homeomorphism: a bijection for which both $e$ and $e^{-1}$ are continuous. Relabel each finite word coordinate by coordinate. The relabelled tree $eT$ consists precisely of those words in $B$ whose coordinatewise pullback under $e^{-1}$ belongs to $T$.

The fundamental classification result is the following.

**Coordinate Relabelling Theorem.** *Let $T$ be a coordinate tree over a topological alphabet $A$, and let $e:A\to B$ be a homeomorphism. Then the ray spaces $[T]$ and $[eT]$ are homeomorphic. The homeomorphism sends each ray $x$ to the coordinatewise relabelled ray $E(x)$ defined by*

$$
E(x)_n=e(x_n).
$$

*Its inverse is given coordinatewise by $e^{-1}$.*

The proof rests on one transparent identity: taking a finite prefix and then relabelling gives the same word as relabelling the infinite sequence first and then taking its finite prefix. Thus every legal prefix remains legal, so $E$ sends rays to rays. Applying $e^{-1}$ reverses the construction exactly. Finally, each output coordinate depends continuously on the corresponding input coordinate, which makes $E$ continuous in the product topology; the same argument applies to the inverse.

This theorem is modest in hypothesis but strong in interpretation. A homeomorphism is not merely asserted to exist. The combinatorial witness $e$ is itself an executable recipe for it. Every edge label changes, every finite prefix changes compatibly, and no topological information is lost.

There is a useful philosophical distinction here. The names attached to branches are presentation; the branching possibilities are structure. If red and blue choices are renamed left and right, the path space has not changed. The theorem extends that intuition beyond finite alphabets and requires the change of labels to respect the topology already present on the coordinate set.

## The unfamiliar geometry of prime divisibility

Now turn from words to rational numbers. Fix a prime $p$. For a nonzero rational number $q$, its $p$-adic valuation $v_p(q)$ records the exponent of $p$ in $q$: positive values indicate powers of $p$ in the numerator, negative values indicate powers of $p$ in the denominator, and $v_p(q)=0$ means neither contributes a net factor of $p$.

For distinct rational numbers $x$ and $y$, define their local multiplicity by

$$
m_p(x,y)=v_p(x-y).
$$

Large $m_p(x,y)$ means that $x-y$ is highly divisible by $p$, so $x$ and $y$ are close in the prime-adic sense. Equality requires separate treatment because the valuation of zero is not an ordinary integer in this convention.

For an integer threshold $k$, define the **valuation cluster** centered at $x$ by

$$
C_{p,k}(x)=\{y\in\mathbb{Q}:y=x\text{ or }(y\ne x\text{ and }k\le m_p(x,y))\}.
$$

Thus $C_{p,k}(x)$ contains $x$ and every rational number differing from $x$ by an amount divisible by at least $p^k$ in the valuation sense. For instance, $2\in C_{2,1}(0)$ because $v_2(2)=1$.

The driving arithmetic law is the strong triangle inequality

$$
m_p(y,z)\ge\min\{m_p(y,x),m_p(x,z)\}
$$

whenever the displayed multiplicities involve distinct points. Compare this with the ordinary triangle inequality. Euclidean distance allows the third side of a triangle to be as large as the sum of the other two. Prime-adic closeness says something more rigid: if two points are each close to a center at threshold $k$, then they are close to each other at that same threshold.

This gives the next theorem.

**Cluster Transitivity Theorem.** *Let $p$ be prime and $k$ an integer. If $y\in C_{p,k}(x)$ and $z\in C_{p,k}(x)$, then $z\in C_{p,k}(y)$.*

If some of $x,y,z$ coincide, the conclusion follows directly from the definition. Otherwise, both hypotheses give lower bounds of $k$ on the two relevant local multiplicities. Their minimum is at least $k$, and the strong triangle inequality gives $m_p(y,z)\ge k$.

Two further structural laws follow.

**Threshold Antitonicity Theorem.** *For fixed $p$ and $x$, if $k\le \ell$, then*

$$
C_{p,\ell}(x)\subseteq C_{p,k}(x).
$$

Raising the threshold demands greater divisibility, so the cluster can only shrink.

**Center-Independence Theorem.** *Let $p$ be prime. If $y\in C_{p,k}(x)$, then*

$$
C_{p,k}(y)=C_{p,k}(x).
$$

For the proof, cluster transitivity first shows that every point clustered around $x$ is clustered around $y$. It also shows that $x$ is clustered around $y$, after which the same argument in the reverse direction yields the opposite inclusion.

## Balls that cannot partly overlap

In ordinary geometry, two disks of the same radius can overlap without being equal. Valuation clusters behave differently. At a fixed threshold, if two clusters intersect, choose a point in their intersection. Center-independence allows that point to become the center of each cluster, so the clusters are equal. Therefore equal-threshold clusters are either identical or disjoint.

Across different thresholds, antitonicity supplies nesting. Together these facts produce a **laminar hierarchy**: clusters divide into smaller clusters as the threshold rises, with no ambiguous partial overlaps. This is exactly the organization of a rooted tree. Coarse clusters sit near the root; finer clusters are descendants; an indefinitely refined choice of nested clusters behaves like a ray.

This is where the two halves of the story meet. A ray is controlled by its compatible finite prefixes. A prime-adic point is approached through compatible threshold clusters. Prefixes and clusters are both finite-resolution descriptions, and compatibility between resolutions creates an infinite object.

## Why the bridge matters

Hierarchical data appear throughout science and computation. File systems, phylogenetic trees, decision processes, adaptive meshes, and multiscale databases all organize information by refinement. In such settings, arbitrary labels should not affect the underlying space of possibilities. The Coordinate Relabelling Theorem makes that invariance precise for infinite paths.

Prime-adic clusters add a second lesson: hierarchy need not be imposed externally. It can emerge from a local inequality. Once closeness obeys the strong triangle law, centers become interchangeable and neighborhoods become tree-like. This phenomenon supports algorithms that store one representative per cluster, construct dendrograms without overlap ambiguities, and compare infinite boundaries by comparing their finite branching data.

The present results cover an explicit and robust regime rather than every possible classification of ray or end spaces. They show exactly how a global relabelling yields a homeomorphism and exactly how arithmetic threshold neighborhoods become laminar. The next frontier is to weaken global relabelling to coherent level-by-level correspondences, and to reconstruct entire ultrametric spaces as boundaries of trees of balls.

The broad message is already clear. Infinite spaces often look forbidding because their points carry endless information. But topology asks only how finite observations fit together. Preserve those observations coherently, and the infinite shape survives. Strengthen closeness enough, and those observations arrange themselves into a tree.