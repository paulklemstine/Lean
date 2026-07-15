# Two Coordinates, One Order: How Graph Embeddings Reveal Hidden Closure Laws

## A recurring mathematical puzzle

Many mathematical spaces are divided into pieces called *strata*. A stratum collects objects that share the same qualitative behavior: matrices of a fixed rank, geometric configurations of the same incidence type, or flags lying in the same relative position. The pieces are disjoint, but their boundaries are not. As one configuration degenerates, a point in one stratum can approach a point in another. The resulting web of possible degenerations is called the **closure order**.

Closure orders turn geometry into combinatorics. Instead of tracking every point of a large space, one asks which labels can occur on the boundary of which other labels. For flag varieties, those labels are permutations, and the relevant combinatorial relation is the **Bruhat order**. The central idea developed here is strikingly economical: when a stratum is recorded by two compatible coordinates, the entire closure law can be read component by component in a product order.

There is a broader principle behind this statement. Suppose a set $X$ carries a relation $\preccurlyeq$, and suppose a transformation $\iota:X\to X$ preserves and reflects that relation:

$$
\iota(x)\preccurlyeq\iota(y)\quad\Longleftrightarrow\quad x\preccurlyeq y.
$$

Send each point to the graph of its transformed value,

$$
\Gamma(x)=(x,\iota(x)).
$$

On $X\times X$, compare pairs componentwise. Then

$$
\Gamma(x)\preccurlyeq_{\times}\Gamma(y)
\quad\Longleftrightarrow\quad
x\preccurlyeq y.
$$

The first coordinate remembers the original point; the second coordinate supplies a compatible view of the same order. The graph is therefore not merely a picture of $X$ inside a larger space. It is an exact order-theoretic replica.

## What a principal closure remembers

For any $x\in X$, define its **principal closure** or principal lower set by

$$
\downarrow x=\{y\in X:y\preccurlyeq x\}.
$$

This is the abstract version of “all strata that can appear as degenerations of the stratum labeled by $x$.” If the relation is reflexive and transitive, then two labels can be compared by comparing their principal closures:

$$
\downarrow x\subseteq\downarrow y
\quad\Longleftrightarrow\quad
x\preccurlyeq y.
$$

The forward direction is almost cinematic in its simplicity: because $x$ lies in its own closure, inclusion forces $x$ to lie in the closure of $y$. The reverse direction follows by transitivity: anything below $x$ is also below $y$.

Now place these closures in the product space. The product-principal closure below $\Gamma(x)$ contains all pairs $(a,b)$ satisfying both $a\preccurlyeq x$ and $b\preccurlyeq\iota(x)$. Most such pairs do not lie on the graph. But after intersecting with the graph image, nothing extra remains:

$$
\downarrow_{\times}\Gamma(x)\cap\Gamma(X)=\Gamma(\downarrow x).
$$

Equivalently, pulling the product closure back along $\Gamma$ gives exactly the original closure:

$$
\Gamma^{-1}(\downarrow_{\times}\Gamma(x))=\downarrow x.
$$

This is the set-level closure correspondence. It says that embedding the labels into two coordinates introduces no false degenerations and loses no genuine ones.

The same principle extends beyond one stratum at a time. A subset $S\subseteq X$ is a **lower set** if $y\in S$ and $x\preccurlyeq y$ imply $x\in S$. Such sets model unions of strata closed under degeneration. The graph image $\Gamma(S)$ is lower *within the graph* under the product relation if and only if $S$ is lower in $X$. Thus the construction transports not only individual closures but whole families of degeneration-stable subsets.

## Enter permutations and the Bruhat order

To see why this matters geometrically, consider permutations of $n$ positions. For a permutation $w$ and indices $i,j$, define the rank count

$$
r_w(i,j)=\#\{k:k\le i\text{ and }w(k)\le j\}.
$$

These numbers form a rank matrix. One permutation $u$ lies below another permutation $v$ in Bruhat order when

$$
r_v(i,j)\le r_u(i,j)
$$

for every pair $i,j$. The reversed inequality in the rank counts reflects the fact that more special geometric configurations have stronger incidence constraints.

The rank matrix contains the whole permutation, not just a coarse summary. If $u$ and $v$ lie below one another, their rank matrices agree, and taking successive differences along rows recovers whether $u(i)\le j$ for every $j$. Hence $u(i)=v(i)$ for every $i$. Together with obvious reflexivity and transitivity, this proves that Bruhat order is a partial order.

Its extreme elements are equally concrete. The identity permutation is the minimum: it has the largest possible northwestern rank counts. The reversal permutation $w_0$, which sends the first position to the last value and so on, is the maximum. Its rank counts are

$$
r_{w_0}(i,j)=\max(0,(i+1)+(j+1)-n),
$$

and every permutation has at least this many entries in the corresponding northwest rectangle.

The key symmetry is inversion. The rank matrix of $w^{-1}$ is the transpose of the rank matrix of $w$:

$$
r_{w^{-1}}(i,j)=r_w(j,i).
$$

Therefore inversion preserves and reflects Bruhat order:

$$
u\le_B v
\quad\Longleftrightarrow\quad
u^{-1}\le_B v^{-1}.
$$

The abstract graph principle now applies with $\iota(w)=w^{-1}$. The two-coordinate map

$$
w\longmapsto(w,w^{-1})
$$

is injective and gives an exact order embedding into the componentwise Bruhat order. In particular,

$$
u\le_B v
\quad\Longleftrightarrow\quad
(u,u^{-1})\le_{B\times B}(v,v^{-1}).
$$

This is the combinatorial mechanism behind closure preservation for two-projection parametrizations of orbit strata: once the orbit labels are known to be permutations and the two coordinates are related by inversion, the product comparison is neither an approximation nor merely a necessary test. Restricted to the parametrization image, it is the closure order itself.

There is also a useful numerical compass. The length $\ell(w)$ of a permutation is its number of inversions, pairs $i<j$ with $w(j)<w(i)$. A permutation has length zero exactly when it is the identity. Consequently the minimum of Bruhat order is precisely the unique inversion-free permutation. At the opposite extreme, the reversal has every possible inversion.

## Another kind of shadow: triangles and edges

The same cycle of ideas—encode a complicated object, pass to a simpler shadow, and prove that the shadow retains decisive information—appears in extremal graph theory.

A finite simple graph consists of vertices joined by edges. A triangle is a set of three vertices with all three connecting edges present. Regard the collection of triangles as a family of three-element sets. Its **shadow** is the family of two-element sets obtained by deleting one vertex from a triangle. Every member of this shadow is an edge, because removing one vertex from a triangle leaves two adjacent vertices.

This elementary observation becomes powerful when combined with the Kruskal–Katona principle, which controls how small the shadow of a uniform set family can be. If a graph on $n$ vertices contains at least

$$
\binom{k}{3}
$$

triangles, where $3\le k\le n$, then the triangle family has a shadow of at least

$$
\binom{k}{2}
$$

pairs. Since every shadow pair is an edge, the graph has at least $\binom{k}{2}$ edges.

The bound is sharp. The complete graph on $k$ vertices, together with $n-k$ isolated vertices, has exactly $\binom{k}{3}$ triangles and exactly $\binom{k}{2}$ edges. In that example, the graph is concentrated as tightly as possible, and so is its shadow.

This triangle-to-edge theorem may look far removed from Bruhat closures, but the intellectual motion is the same. In the orbit problem, a graph embedding records each label in two coordinated projections and preserves every downward relation. In the clique problem, deleting a vertex sends three-dimensional combinatorial faces to two-dimensional shadows, and a sharp theorem says that enough large faces force many small ones. Both arguments succeed by finding the right representation in which containment becomes visible.

## Algorithms hiding inside the proofs

These results lead directly to finite procedures. To compare permutations, compute their rank matrices and test all $n^2$ inequalities. A straightforward implementation takes $O(n^3)$ time, while prefix accumulation reduces this to $O(n^2)$. Inversion then gives the second coordinate essentially for free.

To recover the closure below a label in a finite ordered set, enumerate all labels $y$ and retain those satisfying $y\preccurlyeq x$. Mapping them to $(y,\iota(y))$ produces exactly the graph-supported product closure. This offers a simple consistency check for orbit tables: direct closure data and componentwise product comparisons must agree on the image.

For a graph, triangles can be enumerated in $O(n^3)$ time by checking all vertex triples. Deleting each of their vertices constructs the triangle shadow; comparing that shadow with the edge set illustrates the structural inclusion directly. More sophisticated matrix or adjacency-list methods can accelerate counting, but the elementary algorithm already makes the theorem tangible.

## Why the graph viewpoint matters

A two-coordinate parametrization can appear redundant: if the first coordinate is $w$, why also carry $w^{-1}$? The answer is that geometry often presents information through projections, not through a single preferred label. The graph theorem explains exactly when the redundancy is harmless and useful. One coordinate anchors injectivity; compatibility of the second coordinate certifies that product comparisons agree with the original order.

The result is also robust. It does not depend on special features of permutations until the moment inversion invariance is invoked. Any relation and any self-map preserving and reflecting it satisfy the same graph, closure, and lower-set theorems. Nor must future variants use the same space in both coordinates: the natural next step is to allow two distinct order-reflecting maps into different ordered targets.

For flag geometry, further work must connect the abstract principal lower sets to actual Zariski closures of Borel orbits. Once that geometric bridge is established, the combinatorial result becomes a ready-made engine: closure inclusion can be decided by two Bruhat comparisons. Beyond individual closures, the lower-set correspondence points toward an isomorphism of lattices, identifying all degeneration-stable unions with the product-order lower subsets supported on the parametrization image.

The larger lesson is simple. A well-chosen shadow need not blur an object. Sometimes it reveals the exact structure that was difficult to see in the original space. Whether the shadow is a pair $(w,w^{-1})$ or the two-vertex face of a triangle, the art lies in proving that passage to the shadow preserves precisely the relations one cares about.