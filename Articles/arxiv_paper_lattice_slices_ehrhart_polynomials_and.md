# Ordered Boxes, Deleted Ranks, and Short Modular Secrets

## A geometric language for generalized parking functions

Imagine a crowded city in which each driver carries a preferred parking address. The drivers are not required to arrive in any particular order; what matters is whether, after sorting their preferences from smallest to largest, the $i$th preference stays below a prescribed threshold. This deceptively simple rule creates a family of highly symmetric point clouds. Their convex hulls are generalized parking-function polytopes, geometric objects that connect enumeration, lattice geometry, and the search for short relations in modular arithmetic.

The central idea developed here is to stop viewing a parking function as an unordered list and instead enter one of its **sorted chambers**. Inside a chamber, the geometry becomes a staircase of elementary inequalities. This change of viewpoint makes three operations transparent: deleting a rank, enlarging the permitted profile, and dilating the configuration about the all-ones vector. It also yields a clean bridge to a basic cryptographic problem: finding a nonzero short integer vector annihilated by a matrix modulo an integer.

The results are local rather than a complete solution of the global convex-hull problem. In particular, deleting a rank is proved exactly inside each sorted chamber. Turning all chambers of a fixed labelled-coordinate slice into one lower-dimensional polytope requires an additional gluing argument. That distinction is important: the local theorem is rigorous and powerful, while the global slice identification remains a natural next question.

## From parking preferences to cumulative profiles

Fix a dimension $n$. A **cumulative parking profile** is a sequence of positive integers

$$
P_1\le P_2\le\cdots\le P_n.
$$

The usual parameter vector $\mathbf b=(b_1,\ldots,b_n)$ gives the profile

$$
P_i=b_1+\cdots+b_i.
$$

When every $b_i$ is positive, these bounds are strictly increasing, but the arguments need only nondecreasing positive bounds.

A positive integer vector $x=(x_1,\ldots,x_n)$ is **admitted by the profile** if its entries can be rearranged as

$$
y_1\le y_2\le\cdots\le y_n
$$

so that

$$
1\le y_i\le P_i\qquad(1\le i\le n).
$$

Thus the profile limits the smallest entry by $P_1$, the next by $P_2$, and so on. Permuting coordinates does not affect admission. Each possible ordering of the coordinates defines a sorted chamber, and within that chamber the admission rule is simply a collection of coordinatewise upper bounds together with monotonicity.

This chamber picture is the conceptual engine. A complicated symmetric set is replaced, one chamber at a time, by an ordered staircase.

## The rank-deletion principle

Suppose a sorted admitted vector has length $n+1$:

$$
y_1\le\cdots\le y_{n+1},\qquad 1\le y_i\le P_i.
$$

Choose a rank $r$ and delete both $y_r$ and $P_r$. The remaining vector is still sorted, and every surviving entry retains precisely its corresponding surviving bound. Therefore it is admitted by the shortened profile.

**Rank-Deletion Slice Theorem.** Let $P_1\le\cdots\le P_{n+1}$ be positive integers, and let $y_1\le\cdots\le y_{n+1}$ satisfy $1\le y_i\le P_i$. For any rank $r$, delete the $r$th entries from both lists. If

$$
\widehat y=(y_1,\ldots,y_{r-1},y_{r+1},\ldots,y_{n+1})
$$

and

$$
\widehat P=(P_1,\ldots,P_{r-1},P_{r+1},\ldots,P_{n+1}),
$$

then $\widehat y$ is nondecreasing and satisfies $1\le\widehat y_i\le\widehat P_i$ at every new rank. Hence $\widehat y$ is admitted by $\widehat P$.

The proof is almost visual. Removing one step from two aligned staircases cannot reverse the order of the remaining steps, and it does not disturb any surviving inequality.

Why call this a slice theorem? Fixing a coordinate of an unsorted vector forces that coordinate to occupy some rank after sorting. In each chamber where its rank is known, deleting the fixed coordinate produces exactly the lower-dimensional profile described above. The subtlety is that the same fixed value may occupy different ranks in adjacent chambers. The theorem controls every chamber separately; understanding how those pieces glue is the remaining global geometric problem.

## Bigger profiles and nested worlds

Profiles are naturally ordered. If

$$
P_i\le Q_i\qquad\text{for all }i,
$$

then every vector admitted by $P$ is admitted by $Q$. The same sorting permutation works, and each old upper bound implies the new one.

**Profile Monotonicity Theorem.** Coordinatewise enlargement of a positive nondecreasing profile can only enlarge its admitted set.

This basic fact creates a filtration: as profile bounds rise, parking vectors enter but never leave. Such nested families are useful both for counting and for algorithms. A search over a small profile can be expanded safely, while comparisons among different parameter choices become immediate.

## Dilation around the all-ones vector

Ordinary multiplication by a factor $t$ moves the smallest allowed coordinate $1$ to $t$, breaking the normalization of parking vectors. The right scaling is instead centered at the all-ones vector. For a nonnegative integer $t$, define

$$
D_t(a)=1+t(a-1).
$$

Apply this map to every coordinate and every profile bound. Since subtraction by $1$, multiplication by $t$, and addition of $1$ preserve order on positive integers, sortedness and all upper bounds survive.

**Affine Dilation Theorem.** If $x$ is admitted by the profile $P$, then the coordinatewise transform $D_t(x)$ is admitted by the transformed profile $D_t(P)$ for every integer $t\ge0$.

At $t=0$, everything collapses to the all-ones vector and all-ones profile. At $t=1$, nothing changes. For $t>1$, distances from the all-ones center are multiplied by $t$. This is the discrete affine motion underlying translated dilations of parking-function configurations.

The theorem gives more than a picture: it supplies an exact arithmetic recipe. For example, take

$$
P=(2,5,7,10),\qquad y=(1,4,6,9).
$$

Deleting rank $3$ gives the admitted pair

$$
\widehat P=(2,5,10),\qquad\widehat y=(1,4,9).
$$

With $t=3$, affine dilation gives

$$
D_3(P)=(4,13,19,28),\qquad D_3(y)=(1,10,16,25),
$$

and the transformed inequalities remain evident.

## Every parking vector lives in one cube

Let $P_n$ be the largest profile bound. Every admitted vector has all coordinates between $1$ and $P_n$. Indeed, after sorting, the coordinate at rank $i$ is at most $P_i$, which is at most $P_n$; permutation does not change the collection of coordinates.

**Coordinate Bound Theorem.** If $x$ is admitted by a length-$n$ profile $P$, then

$$
1\le x_j\le P_n
$$

for every coordinate $j$.

The structured parking region therefore sits inside the positive cube $[1,P_n]^n$. This containment seems modest, but it connects parking geometry to collision arguments in modular linear algebra.

## From a parking box to a short modular relation

Let $A$ be an $m\times N$ integer matrix, let $q>0$, and consider the syndrome map

$$
u\longmapsto A\nu\pmod q.
$$

There are only $q^m$ possible syndromes. Now inspect all integer vectors in the centered box

$$
[-B,B]^N.
$$

This box contains $(2B+1)^N$ points. If

$$
q^m<(2B+1)^N,
$$

then two distinct box points have the same syndrome. Their difference $z$ is nonzero, satisfies $Az\equiv0\pmod q$, and obeys $|z_i|\le2B$.

Taking $B=P_N$, the largest parking-profile bound, gives the following result.

**Parking-Box Modular-Kernel Theorem.** Let $P$ be a positive nondecreasing profile of length $N$, let $A$ be an $m\times N$ integer matrix, and let $q>0$. If

$$
q^m<(2P_N+1)^N,
$$

then there exists a nonzero integer vector $z$ such that

$$
Az\equiv0\pmod q
$$

and

$$
|z_i|\le2P_N\qquad(1\le i\le N).
$$

This is a finite pigeonhole argument, the same broad mechanism behind bounded searches for short integer solutions to modular systems. The current bound uses the cube surrounding the parking region, not the finer count of parking vectors themselves. That difference points toward a sharper possibility: when a matrix respects the rank structure, collisions inside the structured parking set might produce smaller witnesses than an unstructured box search.

## A small laboratory of examples

Even low-dimensional profiles display the full mechanism. For $P=(1,3,4)$, every admitted triple lies in the cube $[1,4]^3$, but not every point of that cube survives the sorted rank tests. The vector $(4,2,1)$ is admitted because it sorts to $(1,2,4)$, while $(2,2,2)$ fails because its smallest sorted entry exceeds $P_1=1$. This contrast shows why admission is neither an ordinary coordinatewise box condition nor dependent on the original labels. It is a rank-sensitive condition on the multiset of coordinates.

The same example also illustrates monotonicity. Replacing $P$ by $Q=(2,3,5)$ keeps every old vector and may add new ones. No chamber must be rebuilt: every old sorting witness remains valid. Such examples make the abstract filtration tangible and provide finite test beds for conjectures about counts and slices.

## What the chamber viewpoint changes

The sorted-chamber method separates local truths from global ambitions. Locally, rank deletion is exact. Profiles form nested admitted sets. Affine dilation preserves the entire ordered inequality system. Globally, all vectors occupy a common bounding cube, enabling a modular collision theorem.

Several larger goals now become sharply formulated. One is to determine how chambers glue when a labelled coordinate is fixed at a particular value. Another is to organize chambers into a shelling whose pieces explain positivity in lattice-point polynomials. A third is to prove that affine dilates have an integer-decomposition property. A fourth is cryptographic: replace the coarse cube count by the entropy of the parking region itself.

The unifying lesson is simple. Symmetry can hide structure, but sorting exposes it. Once coordinates are ranked, deletion, comparison, and dilation become elementary operations on two aligned lists. Those operations, in turn, connect the combinatorics of parking preferences to geometric recursion and to the arithmetic search for short modular relations.