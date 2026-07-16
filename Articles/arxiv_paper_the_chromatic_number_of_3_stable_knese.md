# Coloring Constellations on a Circle

## A packing problem disguised as a coloring problem

Imagine $n$ equally spaced seats around a circular table. You want to choose $k$ seats, but no two chosen seats may be too close: walking clockwise or counterclockwise between any pair must require at least $s$ steps. Such a choice is called a **cyclically $s$-stable $k$-set**.

Now turn every permissible choice into a vertex of a graph. Connect two vertices when their chosen seat sets are disjoint. A color assigned to one vertex is therefore a label attached to an entire configuration, and disjoint configurations must receive different colors. This is a stable Kneser graph: a combinatorial object built from sparse constellations on a circle.

The central question is simple to state and unexpectedly deep: how many colors are necessary?

For integers $n\ge sk$, the predicted answer is

$$
\chi=n-sk+s.
$$

Here $\chi$ denotes the chromatic number, the smallest number of colors in a proper coloring. The expression has a compelling interpretation. The term $sk$ measures the circular room demanded by $k$ selected points separated at scale $s$, while the final $+s$ accounts for the cyclic boundary. The broad equality remains a challenging problem in important cases, but its constructive half has an elegant explanation. Moreover, at the tight boundary $n=9$, $s=3$, and $k=3$, the prediction can be proved exactly.

## Stability begins with a ruler

Before returning to the circle, cut it open and place the points on a line. A finite set $A$ of nonnegative integers is **linearly $s$-stable** if whenever $x<y$ are in $A$, one has

$$
y-x\ge s.
$$

Write the elements in increasing order as

$$
a_0<a_1<\cdots<a_{k-1}.
$$

Every neighboring gap is at least $s$, so adding the gaps gives

$$
a_{k-1}-a_0\ge s(k-1).
$$

This is the **Stable Packing Bound**: a linearly $s$-stable set of $k$ points occupies a span of at least $s(k-1)$. It is the elementary engine behind everything that follows.

The equality case is even more revealing. If all $k$ points fit inside an interval whose length is exactly $s(k-1)$, then no gap can waste any room. Every gap must equal $s$, and the set is forced to be

$$
\{a,a+s,a+2s,\ldots,a+s(k-1)\}.
$$

This is the **Extremal Rigidity Theorem**. At minimum span, freedom disappears: the only possible stable configuration is an arithmetic progression. Consequently, two linearly $s$-stable $k$-sets trapped in the same interval of minimum possible length are not merely intersecting; they are identical.

This rigidity is what rescues the final color in the coloring construction.

## Coloring by the first chosen point

Suppose

$$
n=r+s(k-1),
$$

where $r>0$. Label the points $0,1,\ldots,n-1$. For every nonempty stable set $A$, define its color by

$$
c(A)=\min\bigl(\min A,\,r-1\bigr).
$$

The colors are $0,1,\ldots,r-1$. Most configurations are colored by their least element. All configurations whose least element reaches or passes the cutoff $r-1$ are collected into the last color.

Why is this proper? Suppose two stable $k$-sets $A$ and $B$ receive the same color.

If their shared color is less than $r-1$, then both sets have the same least element. They intersect immediately.

The only subtle case is the last color. Then every point of either set lies between $r-1$ and $n-1$. That interval has length

$$
(n-1)-(r-1)=n-r=s(k-1).
$$

It is exactly the shortest interval capable of holding a linearly $s$-stable $k$-set. Extremal rigidity therefore forces both sets to be the same arithmetic progression. Again they intersect. Thus equal-colored stable sets can never be disjoint.

This proves the **Canonical Coloring Theorem**: if $n=r+s(k-1)$, then the disjointness graph on linearly $s$-stable $k$-subsets of $\{0,\ldots,n-1\}$ has a proper coloring with $r$ colors.

Cyclic stability is stronger than linear stability, because the clockwise separation condition includes the ordinary difference condition after the circle is cut at $0$. Therefore the same coloring works for cyclically stable sets. Rewriting the number of colors gives

$$
r=n-s(k-1)=n-sk+s.
$$

Hence the stable Kneser graph always satisfies the constructive upper bound

$$
\chi\le n-sk+s
$$

whenever the parameters are in the stated range. The map is explicit, fast, and local: to color a configuration, one needs only its smallest selected point.

## Nine points and three unavoidable colors

An upper bound does not by itself determine a chromatic number. To prove equality, one also needs to show that fewer colors are impossible. The smallest tight case for cyclic $3$-stable triples offers a beautifully concrete argument.

Place the numbers $0$ through $8$ around a circle and consider the three triples

$$
R_0=\{0,3,6\},\qquad
R_1=\{1,4,7\},\qquad
R_2=\{2,5,8\}.
$$

Within each triple, successive points are three steps apart, including the wrap-around gap. Thus each $R_i$ is cyclically $3$-stable. The triples are pairwise disjoint, so their corresponding graph vertices are pairwise adjacent. They form a triangle.

A triangle cannot be colored with two colors: the first two adjacent vertices must differ, and the third is adjacent to both. Therefore at least three colors are necessary.

The canonical construction supplies three colors, because

$$
9=3+3(3-1).
$$

Combining the lower and upper bounds yields the **Exact Nine-Point Theorem**:

$$
\chi=3
$$

for the graph whose vertices are cyclically $3$-stable triples from nine circular points and whose edges join disjoint triples. This agrees exactly with the predicted value

$$
9-3\cdot 3+3=3.
$$

The proof displays two complementary forces. Packing creates an explicit coloring; a clique of residue-class configurations makes the number of colors unavoidable.

## Why the threshold cannot be ignored

Elegant formulas invite overgeneralization. One might hope that the capped-minimum rule remains proper even when the relation $n=r+s(k-1)$ is removed. A tiny example shows otherwise.

Inside $\{0,1,\ldots,6\}$, take

$$
A=\{1,4\},\qquad B=\{2,5\}.
$$

Both are linearly $3$-stable pairs, and they are disjoint. Use two colors with the rule

$$
c(X)=\min(\min X,1).
$$

Then

$$
c(A)=1=c(B).
$$

The rule assigns the same color to disjoint vertices, so it is not proper. This is the **Threshold Counterexample**. The failure is not cosmetic: the sharp numerical relation is what makes the last-color interval have precisely minimum span. If the interval is longer, different stable configurations can coexist there without meeting.

The example teaches a general lesson in extremal combinatorics. A coloring rule can owe its correctness to a hidden equality case in a packing theorem. Remove the equality, and rigidity vanishes.

## Algorithms hiding in the proof

The results lead naturally to computation. One can generate every $k$-subset of $\{0,\ldots,n-1\}$, test cyclic stability by checking both circular arcs between each pair, and connect disjoint sets. For modest parameters this reveals the whole graph.

The canonical coloring itself is much cheaper. Given a sorted stable set, compute its first element and cap it at $r-1$. This takes constant time after sorting, or $O(k)$ time if the minimum must be found. Verifying a proposed coloring is more expensive: among $v$ stable sets, a direct test examines $O(v^2)$ pairs and checks disjointness in $O(k)$ time.

The nine-point case is small enough to see. The residue classes modulo $3$ provide a visible triangle, while every generated cyclically stable triple receives one of three canonical colors. The construction and obstruction meet exactly.

## The larger horizon

The general $3$-stable equality predicts

$$
\chi=n-3k+3
$$

for every $n\ge 3k$. The upper bound now has a transparent packing proof. The hard part is the lower bound: one must show that no clever, globally coordinated coloring can beat the formula.

Several routes suggest themselves. At the boundary $n=sk$, one expects every cyclically $s$-stable $k$-set to be a residue class modulo $s$. If true in full generality, the boundary graph collapses to a complete graph on $s$ vertices. Beyond the boundary, stable versions of intersection theorems could constrain each color class, since every color class must be an intersecting family. Topological methods offer another possibility, translating disjointness into an obstruction that no low-dimensional coloring can evade.

There is also a practical classification problem: for which quadruples $(n,s,k,r)$ does the capped-minimum rule remain proper? The counterexample proves that no unconditional answer is possible, but it points toward the right variables—the interval length, the spacing requirement, and the number of colors.

These ideas are useful whenever periodic resources must be kept apart: time slots with safety buffers, channels separated by guard bands, or markers on a circular code. In each interpretation, the equality case describes a saturated design in which every available gap is used perfectly.

There is a broader methodological point. Graph coloring often appears global: every vertex seems to interact with a huge network of alternatives. Here, however, a global guarantee emerges from one local statistic, the minimum selected point. The reason is not that the minimum remembers the entire set. It is that every information-losing case is pushed into a narrow terminal interval, where packing rigidity reconstructs the missing information. This pattern—compress ordinary cases, then control the exceptional fiber by an extremal theorem—can guide algorithm design well beyond this particular graph family.

Stable Kneser graphs turn a childlike activity—choosing separated seats and coloring patterns—into a meeting point of packing, rigidity, graph theory, and topology. Their simplest proofs are memorable because the geometry does most of the work. A stable set needs room. At the exact packing limit it becomes rigid. That rigidity makes the final color safe. And on nine points, three evenly shifted constellations show that all three colors are truly necessary.