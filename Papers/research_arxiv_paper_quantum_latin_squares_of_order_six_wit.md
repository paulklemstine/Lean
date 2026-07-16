# Quantum Latin Squares of Order Six with Cardinalities Nineteen, Twenty-One, and Twenty-Three

## Abstract

A quantum Latin square of order $n$ is an $n\times n$ array of unit vectors in $\mathbb C^n$ such that every row and every column is an orthonormal basis. Its ray cardinality is the number of distinct one-dimensional subspaces represented by its entries, so vectors differing only by a nonzero global phase are identified. We study three order-six constructions with cardinalities $19$, $21$, and $23$. Two arise from normalized coordinatewise products of columns of complex Hadamard matrices. Commutativity makes these arrays symmetric, imposing the upper bound $6(6+1)/2=21$. A single triple coincidence among unordered products gives cardinality $19$, while injectivity on all unordered products gives cardinality $21$. The third construction uses the orthogonal decomposition $\mathbb C^6=\mathbb C^4\oplus\mathbb C^2$. Nineteen rays supported in the first summand and four in the second are automatically disjoint, so their union has cardinality $23$, exceeding the symmetric Schur-product bound. We isolate the finite certificates behind these counts, explain algorithms for checking them, compare the results with classical Latin squares, and discuss genericity, rigidity, and direct-sum spectra.

## 1. Introduction

Classical Latin squares encode mutually compatible permutations. An order-$n$ Latin square is an $n\times n$ array over $n$ symbols in which every symbol occurs once in each row and once in each column. If the symbols are represented by the standard basis of $\mathbb C^n$, every row and column is an orthonormal basis, but the entire array uses only $n$ rays.

Quantum Latin squares retain the basis condition while allowing arbitrary unit vectors. Their local constraints remain rigid—each row and column must be orthonormal—but their global range can contain far more than $n$ rays. This distinction makes ray cardinality a basic measure of nonclassical diversity.

Order six is especially fertile. It supports nontrivial families of complex Hadamard matrices and decomposes as $6=4+2$, enabling both multiplicative and direct-sum constructions. The purpose of this paper is to explain three cardinality mechanisms in a common language:

1. a symmetric Schur-product array with one triple ray coincidence and otherwise distinct unordered products, giving $19$ rays;
2. a symmetric Schur-product array with all unordered products inequivalent, giving the maximal symmetric value $21$;
3. a direct-sum array with disjoint ray families of sizes $19$ and $4$, giving $23$ rays.

The core contribution is a separation between geometric verification and finite counting. Once row-and-column orthogonality and the relevant ray relations are known, each cardinality follows from a short reusable certificate. This organization clarifies both why the first two values obey a ceiling and why the third can exceed it.

## 2. Definitions and notation

### 2.1. Finite-dimensional complex geometry

For $v,w\in\mathbb C^n$, use the Hermitian inner product

$$
\langle v,w\rangle=\sum_{r=0}^{n-1}\overline{v_r}w_r.
$$

A family $(v_0,\ldots,v_{n-1})$ is an orthonormal basis if

$$
\langle v_j,v_k\rangle=\delta_{jk}
$$

for all $j,k$. Since the family has $n$ orthonormal vectors in $\mathbb C^n$, completeness follows automatically.

A **ray** is a one-dimensional complex subspace. For a nonzero vector $v$, write $[v]$ for its ray. Thus

$$
[v]=[w]
$$

if and only if $v=\lambda w$ for some nonzero $\lambda\in\mathbb C$. For unit vectors, the scalar necessarily satisfies $|\lambda|=1$ and is a global phase.

### 2.2. Quantum Latin squares and cardinality

**Definition 2.1 (Quantum Latin square).** An order-$n$ quantum Latin square is an array

$$
A=(v_{ij})_{0\le i,j<n},\qquad v_{ij}\in\mathbb C^n,
$$

such that for every fixed $i$, the row $(v_{i0},\ldots,v_{i,n-1})$ is an orthonormal basis, and for every fixed $j$, the column $(v_{0j},\ldots,v_{n-1,j})$ is an orthonormal basis.

**Definition 2.2 (Ray cardinality).** The ray cardinality of $A$ is

$$
\kappa(A)=\left|\{[v_{ij}]:0\le i,j<n\}\right|.
$$

This is invariant under multiplying any entry by a global phase. The constructions considered below are naturally described at the level of vectors, while their cardinalities are measured at the level of rays.

### 2.3. Complex Hadamard matrices and Schur products

**Definition 2.3 (Complex Hadamard matrix).** A complex Hadamard matrix of order $n$ is a matrix $H\in\mathbb C^{n\times n}$ whose entries have modulus $1$ and which satisfies

$$
H^*H=nI_n.
$$

Equivalently, its columns $h_0,\ldots,h_{n-1}$ satisfy

$$
\langle h_j,h_k\rangle=n\delta_{jk}.
$$

A Butson-type Hadamard matrix restricts its entries to roots of unity of a fixed order. The cardinality-$19$ example uses eighth roots of unity.

**Definition 2.4 (Schur product).** For $x,y\in\mathbb C^n$, their Schur, or coordinatewise, product is

$$
(x\odot y)_r=x_ry_r.
$$

The product is commutative and associative. If all coordinates of $x$ and $y$ have modulus $1$, then the same is true of $x\odot y$.

## 3. The Schur-product construction

Let $H$ be a complex Hadamard matrix of order $n$ with columns $h_0,\ldots,h_{n-1}$. Define

$$
v_{ij}=\frac{1}{\sqrt n}(h_i\odot h_j).
$$

**Theorem 3.1 (Hadamard Schur-product construction).** The array $(v_{ij})$ is a quantum Latin square of order $n$. Moreover, it is symmetric: $v_{ij}=v_{ji}$.

**Proof sketch.** Fix $i$. For any $j,k$,

$$
\begin{aligned}
\langle v_{ij},v_{ik}\rangle
&=\frac1n\sum_{r=0}^{n-1}\overline{h_{ir}h_{jr}}h_{ir}h_{kr}\\
&=\frac1n\sum_{r=0}^{n-1}|h_{ir}|^2\overline{h_{jr}}h_{kr}\\
&=\frac1n\langle h_j,h_k\rangle\\
&=\delta_{jk}.
\end{aligned}
$$

Thus every row is orthonormal. Commutativity gives $v_{ij}=v_{ji}$, so each column is identical, entry for entry, to the corresponding row and is also orthonormal. ∎

The symmetry has a decisive counting consequence. Let

$$
U_n=\{(i,j):0\le i\le j<n\}
$$

be the upper-triangular index set. Its cardinality is

$$
|U_n|=n+(n-1)+\cdots+1=\frac{n(n+1)}2.
$$

**Theorem 3.2 (Symmetric range bound).** If an array of labels satisfies $A_{ij}=A_{ji}$ for all $i,j$, then its range has at most $n(n+1)/2$ elements. If the labeling is injective on $U_n$, then its range has exactly $n(n+1)/2$ elements.

**Proof sketch.** Every ordered pair $(i,j)$ can be replaced by $(\min(i,j),\max(i,j))\in U_n$ without changing its label, so the full range equals the image of $U_n$. This proves the upper bound. Under injectivity, the image has the same cardinality as $U_n$. ∎

For $n=6$, this gives

$$
|U_6|=\frac{6\cdot7}{2}=21.
$$

We call $21$ the symmetric Schur-product ceiling at order six. It is a bound on this construction mechanism, not on arbitrary quantum Latin squares.

## 4. The nineteen-ray certificate

Consider the $21$ unordered positions in $U_6$. The order-six Butson construction has a unique nontrivial coincidence among their rays:

$$
[v_{01}]=[v_{25}]=[v_{34}].
$$

All other unordered positions are inequivalent, and no other position shares this ray. Define a representative set by retaining $(0,1)$ and deleting $(2,5)$ and $(3,4)$ from $U_6$. This set has $21-2=19$ elements.

**Theorem 4.1 (Unique-triple cardinality criterion).** Let $A$ be a symmetric $6\times6$ array of labels. Suppose

$$
A_{25}=A_{01},\qquad A_{34}=A_{01},
$$

and suppose the labeling is injective on

$$
R_{19}=U_6\setminus\{(2,5),(3,4)\}.
$$

Then the range of $A$ has cardinality $19$.

**Proof sketch.** By symmetry, every label in the full array occurs in $U_6$. The two deleted positions have the same label as the retained position $(0,1)$, so deleting them does not change the image. Hence the full range equals the image of $R_{19}$. Injectivity on $R_{19}$ implies that this image has $|R_{19}|=19$ elements. ∎

**Corollary 4.2 (Nineteen-ray order-six square).** If an order-six Hadamard Schur-product square has precisely the triple ray coincidence

$$
[v_{01}]=[v_{25}]=[v_{34}]
$$

among unordered positions and no other ray coincidences, then its ray cardinality is $19$.

The arithmetic can also be expressed through fiber sizes. Beginning with $21$ potential labels, a fiber of size $3$ contributes one label rather than three and therefore reduces the count by $2$. All singleton fibers contribute without reduction:

$$
\kappa=21-(3-1)=19.
$$

This viewpoint generalizes. If a symmetric labeling of $U_n$ has fibers of sizes $s_1,\ldots,s_m$, then its range size is $m$, equivalently

$$
\frac{n(n+1)}2-\sum_{a=1}^m(s_a-1).
$$

The nineteen-ray case is the simplest nontrivial example with one fiber of size $3$.

## 5. The twenty-one-ray certificate

For a suitable explicit member of Karlsson’s three-parameter family of order-six complex Hadamard matrices, all $21$ unordered normalized Schur products are pairwise inequivalent as rays.

**Theorem 5.1 (Upper-triangular injectivity criterion).** Let $A$ be a symmetric $6\times6$ array of labels. If the map

$$
(i,j)\longmapsto A_{ij}
$$

is injective on $U_6$, then the full range of $A$ has cardinality $21$.

**Proof sketch.** Symmetry makes the full range equal to the image of $U_6$. Injectivity preserves the cardinality of this $21$-element set. ∎

**Corollary 5.2 (Twenty-one-ray order-six square).** If the normalized Schur products of the six columns of an order-six complex Hadamard matrix are pairwise ray-inequivalent on unordered index pairs, then the associated quantum Latin square has cardinality $21$. This saturates the symmetric Schur-product bound.

There is a graph-theoretic interpretation. Associate six vertices with the Hadamard columns. An unordered pair of distinct vertices is an edge, while a repeated pair $(i,i)$ is a loop. The index set $U_6$ is the complete graph on six vertices together with its six loops. It contains

$$
\binom62+6=15+6=21
$$

objects. In the maximal case, each edge and loop has a unique ray label. Any ray-preserving symmetry must therefore induce a permutation of this finite incidence structure.

## 6. A direct-sum construction with twenty-three rays

The number $21$ is not a universal order-six bound. It follows from symmetry of the Schur product. To exceed it, consider the orthogonal decomposition

$$
\mathbb C^6=V_4\oplus V_2,
$$

where $V_4\cong\mathbb C^4$ and $V_2\cong\mathbb C^2$. Under standard coordinates one may take

$$
V_4=\mathbb C^4\oplus\{0\},\qquad
V_2=\{0\}\oplus\mathbb C^2.
$$

Here vectors in the first space have zero last two coordinates, while vectors in the second have zero first four coordinates. More simply, write embedded vectors as $(x,0)$ and $(0,y)$.

**Lemma 6.1 (Disjointness of complementary rays).** No nonzero ray contained in $V_4$ equals a nonzero ray contained in $V_2$.

**Proof sketch.** If $(x,0)=\lambda(0,y)$ for nonzero $\lambda$, then comparison of components gives $x=0$ and $y=0$, contradicting nonzeroness. ∎

**Lemma 6.2 (Disjoint-union count).** If finite sets $X$ and $Y$ are disjoint, with $|X|=19$ and $|Y|=4$, then

$$
|X\cup Y|=23.
$$

**Proof sketch.** For disjoint finite sets, cardinality is additive:

$$
|X\cup Y|=|X|+|Y|=19+4=23.
$$

∎

The direct-sum design uses $19$ distinct rays supported in $V_4$ and $4$ distinct rays supported in $V_2$. They are placed in a $6\times6$ array so that every row and column consists of four mutually orthonormal vectors from $V_4$ and two mutually orthonormal vectors from $V_2$. Orthogonality within each summand and between summands then makes each row and column an orthonormal basis of $\mathbb C^6$.

**Theorem 6.3 (Twenty-three-ray direct-sum criterion).** Suppose an order-six quantum Latin square uses exactly $19$ distinct rays contained in $V_4$ and exactly $4$ distinct rays contained in $V_2$, where $\mathbb C^6=V_4\oplus V_2$ is an orthogonal direct sum. Then its ray cardinality is $23$.

**Proof sketch.** The two ray families are disjoint by Lemma 6.1, and their union is the range of the square. Lemma 6.2 gives cardinality $19+4=23$. ∎

This theorem isolates the counting stage. It does not infer the quantum Latin property from cardinality alone; the row-and-column basis conditions remain a separate geometric requirement. Conversely, once those conditions and the within-summand ray counts are established, no cross-summand phase comparison is needed.

## 7. Separation from classical Latin squares

**Theorem 7.1 (Classical order-six cardinality).** Every classical Latin square of order six, represented by the six computational-basis rays of $\mathbb C^6$, has ray cardinality exactly $6$.

**Proof sketch.** Every entry is one of the six basis labels, so the range has at most $6$ elements. Any fixed row contains each symbol exactly once, so all six labels occur and the range has at least $6$ elements. ∎

Consequently, cardinalities $19$, $21$, and $23$ cannot occur in computational-basis Latin squares. The distinction is not a matter of relabeling: it reflects genuinely larger ray ranges compatible with the same local basis requirements.

## 8. Algorithms for finite certification

The preceding theorems naturally yield exact finite algorithms. Numerical implementations must treat phase equivalence carefully; direct floating-point comparison is not mathematically decisive, but it is useful for exploration and reproducible examples.

### 8.1. Canonical ray normalization

Given a nonzero vector $v\in\mathbb C^n$, choose its first coordinate $v_k$ whose magnitude exceeds a tolerance $\varepsilon$. Multiply by

$$
\frac{\overline{v_k}}{|v_k|}
$$

so that the pivot becomes positive real, normalize the Euclidean norm, and round coordinates for hashing. Two vectors differing by a global phase then receive the same approximate canonical representative.

For $m$ vectors of dimension $n$, canonicalization costs $O(mn)$ arithmetic operations. Pairwise comparison costs $O(m^2n)$ without hashing and expected $O(mn)$ after stable hash canonicalization.

### 8.2. Symmetric collision certification

For a symmetric order-six array, enumerate the $21$ pairs $(i,j)$ with $i\le j$. Canonicalize each ray and group equal representatives. The certificate is the multiset of fiber sizes together with the positions in every non-singleton fiber.

A nineteen-ray pattern requires one fiber

$$
\{(0,1),(2,5),(3,4)\}
$$

and $18$ singleton fibers. A twenty-one-ray pattern requires $21$ singleton fibers. Enumeration and hashing use $O(n^2d)$ work for vectors of dimension $d$, while an all-pairs fallback uses $O(n^4d)$.

### 8.3. Direct-sum certification

For each ray, identify its support tag: first summand, second summand, or invalid mixed support. Verify that exactly $19$ canonical rays have the first tag and exactly $4$ have the second. Complementary support proves cross-tag disjointness. The resulting cardinality is additive.

For $m$ vectors in total dimension $d$, support checking and normalization cost $O(md)$. If rows and columns are also tested numerically, computing all Gram matrices costs $O(n^3d)$ for an $n\times n$ array.

## 9. Numerical illustrations

The finite counting mechanisms can be illustrated independently of the coordinate-heavy matrix constructions.

For the nineteen-ray pattern, label the $21$ upper-triangular positions by distinct integers and then assign the same label to $(0,1)$, $(2,5)$, and $(3,4)$. Symmetrically extending to all $36$ cells yields $19$ distinct labels.

For the twenty-one-ray pattern, assign a distinct label to every upper-triangular position and reflect across the diagonal. The full array has $21$ labels despite containing $36$ cells.

For the direct sum, represent first-summand labels as tagged pairs $(\text{four},k)$ for $0\le k<19$ and second-summand labels as $(\text{two},k)$ for $0\le k<4$. The tags make equality across summands impossible, and the union has $23$ elements.

These examples demonstrate the exact combinatorial implications of the hypotheses. They do not substitute for coordinate checks of a particular Hadamard matrix or direct-sum array; rather, they show that once those geometric hypotheses are supplied, the cardinality conclusions are forced.

## 10. Applications and structural consequences

### 10.1. Cardinality as a design invariant

Ray cardinality is coarser than the full geometry of a quantum Latin square, but finer than its order. It is unchanged by global unitary transformations, because an invertible linear map preserves equality and inequality of rays. It is also unchanged when individual entries are multiplied by phases. Consequently, the values $19$, $21$, and $23$ survive the natural equivalences used when comparing quantum state configurations.

The three certificates reveal different kinds of information. A fiber certificate records exactly where reuse occurs. An injectivity certificate records the absence of reuse among canonical unordered representatives. A support certificate records why reuse across components is impossible. These are not interchangeable: a count of $19$ alone does not identify the triple fiber, and a count of $23$ alone does not exhibit a direct-sum structure. For classification, one should retain both the cardinality and the mechanism producing it.

There is also an experimental advantage. Searching directly through $36$ phase-sensitive vectors is expensive and obscures symmetry. In the Schur setting, one first reduces to $21$ unordered products and then studies proportionality fibers. In the direct-sum setting, one first partitions by support and compares rays only within each component. Both reductions remove comparisons that are known in advance to be redundant or impossible.

### 10.2. Quantum information and frame design

Quantum Latin squares organize collections of orthonormal frames with two transverse indexing directions. Such structures are relevant to quantum information, where rays represent pure states and orthonormal bases represent projective measurements. High ray cardinality means that a square can expose many globally distinct states while preserving a complete measurement basis along each row and column.

The Schur-product method is attractive because one Hadamard identity proves all row and column orthogonality at once. Its limitation is equally transparent: commutativity collapses ordered pairs to unordered pairs. The value $21$ is therefore both an achievement and a boundary marker.

The direct-sum method is modular. Lower-dimensional geometric designs may be embedded into complementary sectors, and their cardinalities add when their ray families are disjoint. This suggests constructing large examples from smaller components indexed by partitions

$$
n=n_1+\cdots+n_t.
$$

The main difficulty shifts from cross-component interference, which disappears, to arranging each row and column to contain the correct number of basis vectors from every component.

The maximal symmetric case also suggests rigidity. When all $21$ unordered pairs have unique labels, each ray recovers its indexing edge or loop. A ray-preserving automorphism must act on this complete looped graph. For generic Hadamard parameters, one expects only symmetries induced by permutations and phase rescalings of the underlying columns.

## 11. Limitations

The counting criteria are conditional on geometric input. The nineteen-ray theorem requires the asserted triple coincidence and injectivity elsewhere. The twenty-one-ray theorem requires all unordered products to be inequivalent. The twenty-three-ray theorem requires both within-summand ray counts and a genuine quantum Latin arrangement. Cardinality data alone do not imply orthogonality.

For matrices with cyclotomic entries, exact ray equivalence can be decided by algebraic identities. Given nonzero vectors $v,w$, proportionality is equivalent to the vanishing of all $2\times2$ minors

$$
v_rw_s-v_sw_r=0.
$$

To prove inequivalence, it suffices to find one nonzero minor. Exact arithmetic in the relevant cyclotomic field avoids tolerance issues present in numerical computation.

## 12. Future work

A first objective is a complete phase-invariant certificate for the eighth-root cardinality-$19$ matrix: the triple containing $(0,1)$, $(2,5)$, and $(3,4)$ should be the only non-singleton fiber among unordered normalized Schur products. This reduces to finitely many identities and non-identities in eighth roots of unity.

A second direction is generic maximality in Karlsson’s three-parameter family. Every unwanted ray coincidence is described by vanishing minors and hence by algebraic conditions on parameters. If one parameter point avoids all coincidences, the union of coincidence loci should be a proper real-algebraic subset, leaving cardinality $21$ on a generic region.

Third, direct sums may generate spectra above the symmetric ceiling at composite orders. Complementary summands make ray counts additive, suggesting searches organized by partitions of the ambient dimension and by achievable component cardinalities.

Fourth, maximality may imply rigidity. Generic injectivity labels every edge and loop uniquely, sharply constraining ray-preserving symmetries.

Finally, ray cardinality may quantify separation from the classical locus. One may seek a positive lower bound, modulo unitary conjugation and entrywise phases, on the distance from a quantum Latin square with more than six rays to any computational-basis square.

## 13. Conclusion

Three finite certificates explain the order-six cardinalities $19$, $21$, and $23$. Symmetry reduces a Schur-product square to $21$ unordered representatives. A unique triple collision lowers this count to $19$; complete injectivity attains $21$. An orthogonal $4+2$ decomposition replaces symmetric counting with a disjoint union of $19$ and $4$ rays, producing $23$ and crossing the Schur-product ceiling.

The resulting picture separates geometry from enumeration. Hadamard identities or direct-sum arrangements establish orthonormal rows and columns. Fiber patterns, injectivity, and disjointness establish exact cardinality. This separation provides a practical framework for exploring the ray spectrum of quantum Latin squares at order six and beyond.