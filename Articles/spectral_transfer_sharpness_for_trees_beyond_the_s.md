# The Path That Refused to Break

## A sharp inequality hidden in four steps

A path of five vertices is among the simplest networks one can draw. Place five dots in a row and join consecutive dots. There are four edges, no cycles, and only one route from one end to the other. Yet this modest shape sits at the meeting point of several large ideas: counting patterns in networks, understanding irregularity, and deciding when spectral information really controls combinatorial structure.

The natural question is this. If a large weighted network has a certain average edge intensity, how few copies of the five-vertex path can it contain? One might expect the answer to depend delicately on positivity assumptions: perhaps all edge weights must be nonnegative, or perhaps the matrix describing the network must have nonnegative eigenvalues. In fact, neither condition is needed. Symmetry alone forces the sharp bound.

That conclusion matters beyond one small graph. It closes off a tempting route to a counterexample in the theory of graph densities. The five-vertex path cannot separate a spectral condition from a Sidorenko-type path inequality within any class of symmetric kernels, because it already satisfies the required inequality in a much larger universe: every finite symmetric real weighted network, even one with negative entries.

## Weighted networks and the quantities that matter

Consider a finite set of $n$ vertices. A real number $A_{ij}$ records the weight between vertices $i$ and $j$. We require only symmetry,

$$
A_{ij}=A_{ji}.
$$

Weights may be positive, zero, or negative. Define the weighted degree of vertex $i$ by

$$
d_i=\sum_j A_{ij}.
$$

The total ordered edge weight is

$$
S=\sum_i d_i=\sum_{i,j}A_{ij}.
$$

Now look two steps away. Starting at $i$, move to $j$ with weight $A_{ij}$, then continue from $j$ along all possible edges. The resulting two-step weight is

$$
u_i=\sum_j A_{ij}d_j.
$$

In vector language, if $d$ is the degree vector, then $u=Ad$. The weighted count of maps of the five-vertex path into the network is

$$
P=\sum_i u_i^2.
$$

Why does this expression count a path? Label the path vertices in order as $1,2,3,4,5$. Summing the product

$$
A_{x_1x_2}A_{x_2x_3}A_{x_3x_4}A_{x_4x_5}
$$

over every choice of images $x_1,\ldots,x_5$ lets the two halves of the path meet at the middle vertex. Each half contributes a two-step weight, and symmetry makes the two contributions equal. Squaring and summing over the middle vertex gives $P$.

This is a homomorphism count: vertices of the small path may land on the same network vertex. Such counts are fundamental because they behave smoothly under limits and capture the statistical presence of motifs in large graphs.

## The conservation law at the center

The proof turns on a simple identity. Summing all two-step weights gives

$$
\sum_i u_i=\sum_i d_i^2.
$$

To see it, expand and reverse the order of summation:

$$
\sum_i u_i
=\sum_{i,j}A_{ij}d_j
=\sum_j d_j\sum_i A_{ij}.
$$

Symmetry says that the column sum $\sum_i A_{ij}$ equals the row sum $d_j$. Thus the final expression is $\sum_j d_j^2$.

This identity is the hinge of the argument. It turns a sum of local two-step flows into a measure of degree concentration. It resembles a conservation law: once symmetry is present, the total propagated degree is exactly the energy in the degree vector.

## Two applications of one inequality

The entire theorem follows from applying the Cauchy–Schwarz inequality twice.

First apply it to the $n$ numbers $d_i$:

$$
\left(\sum_i d_i\right)^2\le n\sum_i d_i^2.
$$

In the new notation this is

$$
S^2\le n\sum_i d_i^2.
$$

Next apply Cauchy–Schwarz to the $n$ numbers $u_i$:

$$
\left(\sum_i u_i\right)^2\le n\sum_i u_i^2=nP.
$$

Using the central identity gives

$$
\left(\sum_i d_i^2\right)^2\le nP.
$$

Squaring the first inequality and inserting the second yields

$$
S^4\le n^2\left(\sum_i d_i^2\right)^2\le n^3P.
$$

This is the sharp five-vertex path inequality.

**Five-Vertex Path Theorem.** For every nonempty finite symmetric real weighted network on $n$ vertices,

$$
S^4\le n^3P,
$$

where $S=\sum_{i,j}A_{ij}$ and $P$ is the weighted homomorphism count of the five-vertex path.

Notice what never entered the proof. We did not assume $A_{ij}\ge 0$. We did not assume that the quadratic form $x^{\mathsf T}Ax$ is nonnegative. Negative edge weights and negative eigenvalues are allowed. The conclusion is powered solely by symmetry and the geometry of sums of squares.

## The density form

Counts grow with the size of the ambient network, so comparisons are cleanest after normalization. The edge density is

$$
t(K_2,A)=\frac{S}{n^2},
$$

and the five-vertex path density is

$$
t(P_5,A)=\frac{P}{n^5}.
$$

Dividing the sharp inequality by $n^8$ gives the normalized theorem

$$
t(P_5,A)\ge t(K_2,A)^4.
$$

The exponent $4$ is not arbitrary: the path has four edges. The inequality says that fixing the average edge weight forces at least the fourth power of that average as the normalized path density.

For ordinary nonnegative graphs, this belongs to the family of Sidorenko-type inequalities. The striking point is its expanded range here. The algebraic path count still obeys the same lower bound even when signed weights destroy the usual probabilistic interpretation.

## Why the coefficient cannot improve

Sharp inequalities should come with witnesses. Take a constant network, with

$$
A_{ij}=c
$$

for every ordered pair. Then each degree is $d_i=nc$, each two-step weight is $u_i=n^2c^2$, and

$$
S=n^2c,
\qquad
P=n^5c^4.
$$

Consequently,

$$
S^4=n^8c^4=n^3P.
$$

Equality holds for every real constant $c$. Therefore the factor $n^3$ in the unnormalized theorem is best possible, and the coefficient $1$ in the density inequality cannot be raised.

The equality mechanism is intuitive. Cauchy–Schwarz becomes equality when all entries in the relevant list are equal. A constant network gives equal degrees and equal two-step weights, so both stages of the proof are simultaneously tight.

## A numerical glimpse

Take three vertices and a constant weight $c=\tfrac12$. Then $S=9/2$ and $P=3^5/16=243/16$. Both sides of the theorem are

$$
S^4=\left(\frac92\right)^4=\frac{6561}{16},
$$

and

$$
n^3P=27\cdot\frac{243}{16}=\frac{6561}{16}.
$$

Now perturb the weights while preserving symmetry. The degrees cease to be equal, the two Cauchy–Schwarz steps acquire slack, and typically $n^3P-S^4$ becomes positive. This nonnegative gap measures two layers of irregularity: variation among degrees, and variation among propagated degrees.

That interpretation suggests a practical diagnostic. In network data, the ratio

$$
R=\frac{n^3P}{S^4}
$$

is at least $1$ when $S\ne0$. Values near $1$ indicate that both degree and two-step profiles are close to uniform in the senses detected by the proof. Larger values reveal heterogeneity that becomes visible only after information has traveled two steps.

## The spectral twist

A symmetric matrix is called doubly nonnegative when two extra properties hold: every entry is nonnegative, and every quadratic form satisfies

$$
x^{\mathsf T}Ax\ge0.
$$

Equivalently, the matrix is entrywise nonnegative and positive semidefinite. Such matrices are natural meeting points for graph theory, optimization, and spectral analysis.

One might hope to construct a class of doubly nonnegative kernels in which some universal spectral inequality holds while the five-vertex path inequality fails. The theorem shows that this program cannot work under the standard density definitions. Doubly nonnegative matrices are symmetric, and symmetry alone already implies

$$
t(P_5,A)\ge t(K_2,A)^4.
$$

Indeed, the obstruction is stronger: no class consisting entirely of finite symmetric real kernels can produce the proposed failure. Any spectral assumption added on top of symmetry is irrelevant to this particular path bound.

This is a useful kind of negative result. It does not merely say that one attempted example fails. It identifies the exact elementary mechanism that defeats the whole strategy. Before searching for a sophisticated spectral counterexample, one should first ask whether a short chain of convexity inequalities has already settled the motif.

## What the result teaches

The five-vertex path is a tiny network, but its proof offers a broad lesson about transfer principles. Spectral data and subgraph densities often seem to inhabit different worlds: one describes eigenvalues and quadratic forms, while the other counts combinatorial patterns. Yet for paths, repeated matrix action turns motif counts into norms, and norms invite Cauchy–Schwarz.

Here the route is especially transparent. Edge mass produces degrees; degrees propagate one more step; symmetry converts total propagated mass into degree energy; and two averaging inequalities complete the journey. Every ingredient is visible.

Future work should therefore change the target rather than tighten irrelevant assumptions. One possibility is to specify a genuinely nonstandard spectral inequality or a different notion of admissibility. Another is to replace the five-vertex path by a bipartite graph not already protected by the tree mechanism behind Sidorenko inequalities. The right candidate must contain enough structure that its homomorphism count cannot collapse into two nested sums of squares.

## A small theorem with a reusable method

The argument also offers a compact recipe for investigating other network motifs. First choose a central vertex or edge and reorganize the homomorphism sum around it. Next identify the vectors produced by walking outward from that center. Finally ask whether symmetry turns their total mass into a familiar norm or inner product. If it does, classical inequalities may replace a seemingly difficult enumeration problem.

That recipe is computationally valuable. Directly counting every map of a five-vertex path considers $n^5$ assignments. The identity $P=\sum_i(Ad)_i^2$ reduces the same calculation to two matrix–vector products, requiring only on the order of $n^2$ operations for a dense network and even less for sparse data. The proof therefore doubles as an algorithm: mathematical structure reveals both the lower bound and the efficient way to measure it.

For this path, however, the verdict is final and sharp: symmetry is enough, constant kernels attain equality, and the hoped-for separation has nowhere to hide.