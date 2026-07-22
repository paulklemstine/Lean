# Sorted-Chamber Geometry of Generalized Parking Profiles and Short Modular-Kernel Witnesses

**Aristotle**  
**July 22, 2026**

## Abstract

We study generalized parking functions through positive nondecreasing cumulative profiles. A vector is admitted when a permutation places its coordinates in nondecreasing order and the coordinate of each rank lies below the corresponding profile bound. This formulation decomposes the symmetric parking region into sorted chambers with elementary rank inequalities. We prove a rank-deletion theorem: deleting the same rank from a sorted admitted vector and its cumulative profile preserves admission in one lower dimension. We prove monotonicity under coordinatewise profile enlargement and show that affine dilation about the all-ones vector, $a\mapsto1+t(a-1)$, simultaneously transports admitted vectors and profiles. We also derive a universal coordinate bound and combine it with a finite pigeonhole argument to obtain short nonzero integer vectors in modular kernels. Specifically, for a length-$N$ profile with largest bound $B$, an $m\times N$ integer matrix $A$, and $q>0$, the inequality $q^m<(2B+1)^N$ guarantees a nonzero $z\in\mathbb Z^N$ with $Az\equiv0\pmod q$ and $\lVert z\rVert_\infty\le2B$. The rank-deletion result is chamberwise: identifying an entire labelled-coordinate slice with a single lower-dimensional parking-function polytope additionally requires a value-dependent gluing theorem. We give algorithms for admission testing, chamber deletion, affine transport, and bounded modular-collision search, and discuss consequences for lattice enumeration and structured short-integer-solution searches.

## 1. Introduction

For a positive integer vector $\mathbf b=(b_1,\ldots,b_n)$, a generalized $\mathbf b$-parking function is a positive integer vector whose sorted coordinates satisfy cumulative upper bounds. Writing

$$
P_i=\sum_{k=1}^i b_k,
$$

the condition is that the nondecreasing rearrangement $y_1\le\cdots\le y_n$ obeys $y_i\le P_i$. Convex hulls of these vectors lead naturally to lattice-point enumeration, slices, and Ehrhart-type questions. Yet the defining permutation symmetry can obscure the elementary nature of the inequalities.

The present work adopts cumulative profiles as the primitive object. This modest shift has two advantages. First, only positivity and monotonicity of the rank bounds are needed; strict increments are unnecessary for the local results. Second, fixing a sorting permutation turns admission into a transparent system:

$$
1\le y_1\le\cdots\le y_n,
\qquad
 y_i\le P_i.
$$

We refer to a region determined by one coordinate ordering as a sorted chamber. The chamber decomposition isolates the rank structure responsible for deletion and affine transport.

Our principal geometric statement is the Rank-Deletion Slice Theorem. Inside a sorted chamber, remove the coordinate occupying rank $r$ and remove the profile bound of rank $r$. The surviving coordinates remain sorted and satisfy all surviving bounds. Thus each rank piece of a coordinate slice is governed exactly by profile deletion. This does not by itself identify a whole labelled-coordinate slice: a fixed coordinate value can occupy several ranks, so the corresponding chamber pieces must still be glued. We state this limitation explicitly to distinguish the established local theorem from a stronger global conjecture.

Two functorial properties accompany deletion. Coordinatewise enlargement of a profile preserves every previously admitted vector. Moreover, the affine map

$$
D_t(a)=1+t(a-1),\qquad t\in\mathbb Z_{\ge0},
$$

preserves positivity, order, and rank bounds when applied simultaneously to vectors and profiles. It is scaling about $1$, rather than about $0$, that respects the normalization by positive coordinates.

Finally, every admitted vector lies in the positive cube cut out by the largest profile bound. This observation permits a bridge to modular linear algebra. If a centered integer box has more points than the syndrome space $(\mathbb Z/q\mathbb Z)^m$, two points collide under the map $u\mapsto Au\bmod q$. Their difference is a nonzero bounded modular-kernel vector. Such witnesses are the basic objects sought in short-integer-solution problems.

## 2. Cumulative profiles and sorted chambers

### 2.1 Profiles

**Definition 2.1 (Cumulative parking profile).** A cumulative parking profile of length $n$ is a sequence

$$
P=(P_1,\ldots,P_n)
$$

of positive integers satisfying

$$
P_1\le P_2\le\cdots\le P_n.
$$

Every positive parameter vector $\mathbf b=(b_1,\ldots,b_n)$ determines the profile $P_i=b_1+\cdots+b_i$. Conversely, a merely nondecreasing profile may have zero successive differences, so the profile language is slightly more general than strictly positive increments.

**Definition 2.2 (Admission by a profile).** A vector $x=(x_1,\ldots,x_n)\in\mathbb Z_{>0}^n$ is admitted by $P$ if there exists a permutation $\sigma$ such that

$$
x_{\sigma(1)}\le x_{\sigma(2)}\le\cdots\le x_{\sigma(n)}
$$

and

$$
x_{\sigma(i)}\le P_i\qquad(1\le i\le n).
$$

Equivalently, if $x_{(1)}\le\cdots\le x_{(n)}$ denotes the nondecreasing rearrangement, then $x$ is admitted precisely when $1\le x_{(i)}\le P_i$ for every $i$.

**Definition 2.3 (Sorted chamber).** For a fixed permutation $\sigma$, the associated sorted chamber consists of vectors satisfying

$$
1\le x_{\sigma(1)}\le\cdots\le x_{\sigma(n)},
\qquad
x_{\sigma(i)}\le P_i.
$$

The full admitted set is the union of these chambers. Chamber overlaps occur when coordinates are equal.

### 2.2 Existence of a chamber witness

**Proposition 2.4 (Sorted-chamber representation).** Every vector admitted by $P$ has a nondecreasing rearrangement $y$ satisfying $1\le y_i\le P_i$, and $y$ is obtained from the original vector by a coordinate permutation.

**Proof sketch.** Admission supplies exactly such a permutation. Define $y_i=x_{\sigma(i)}$. The monotonicity and bound conditions are those in the definition, and the permutation records that no coordinate values have been changed. $\square$

Although elementary, this proposition legitimizes working entirely with sorted vectors before transporting conclusions back through permutations.

## 3. Rank deletion and chamberwise slices

### 3.1 Deleting a profile rank

For a length-$(n+1)$ profile $P$ and a rank $r\in\{1,\ldots,n+1\}$, define

$$
P^{\widehat r}=(P_1,\ldots,P_{r-1},P_{r+1},\ldots,P_{n+1}).
$$

This is again a positive nondecreasing profile, now of length $n$.

**Theorem 3.1 (Rank-Deletion Slice Theorem).** Let $P=(P_1,\ldots,P_{n+1})$ be a cumulative parking profile, and let

$$
y_1\le y_2\le\cdots\le y_{n+1}
$$

satisfy $1\le y_i\le P_i$ for every $i$. For any rank $r$, let

$$
y^{\widehat r}=(y_1,\ldots,y_{r-1},y_{r+1},\ldots,y_{n+1}).
$$

Then $y^{\widehat r}$ is admitted by $P^{\widehat r}$.

**Proof sketch.** Deleting one term from a nondecreasing sequence leaves a nondecreasing sequence. Each surviving coordinate $y_i$ remains paired with the surviving bound $P_i$ from the same original rank, so positivity and the inequality $y_i\le P_i$ are unchanged. Reindexing the surviving terms gives the admission inequalities for $P^{\widehat r}$. The identity ordering witnesses admission because the shortened vector is already sorted. $\square$

### 3.2 Interpretation as a local slice theorem

Fix a labelled coordinate, say $x_j=c$. In a chamber determined by $\sigma$, that coordinate occupies the unique rank $r$ for which $\sigma(r)=j$, except that ties may place the point on several chamber boundaries. After deleting $x_j$, Theorem 3.1 supplies the shortened profile $P^{\widehat r}$. Consequently, every fixed-rank piece of the labelled-coordinate slice maps to a lower-dimensional admitted region.

The transformed profile depends on rank. The rank, in turn, depends on the fixed value $c$ relative to the other coordinates. Therefore the theorem does **not** assert that the union over all possible ranks is automatically one profile polytope. A global statement requires proving that adjacent rank pieces glue into a common value-dependent lower-dimensional model.

**Corollary 3.2 (Iterated rank deletion).** If any collection of ranks is deleted from a sorted admitted vector and the same ranks are deleted from its profile, then the remaining vector is admitted by the remaining profile.

**Proof sketch.** Apply Theorem 3.1 repeatedly. At every stage positivity, sortedness, and the surviving paired bounds persist. $\square$

This provides local control of higher-codimension chamber slices.

### 3.3 Example

Let

$$
P=(2,5,7,10),\qquad y=(1,4,6,9).
$$

The vector is sorted and satisfies the profile bounds. Deleting rank $3$ gives

$$
P^{\widehat3}=(2,5,10),\qquad y^{\widehat3}=(1,4,9),
$$

which remains admitted. Deleting ranks $2$ and $4$ instead leaves $(1,6)$ under $(2,7)$.

## 4. Monotonicity of profiles

**Theorem 4.1 (Profile Monotonicity).** Let $P$ and $Q$ be length-$n$ cumulative profiles satisfying $P_i\le Q_i$ for every $i$. Every vector admitted by $P$ is admitted by $Q$.

**Proof sketch.** Choose a permutation sorting the admitted vector and witnessing $x_{\sigma(i)}\le P_i$. Since $P_i\le Q_i$, transitivity gives $x_{\sigma(i)}\le Q_i$. The same permutation and the same monotonicity witness admission by $Q$. $\square$

**Corollary 4.2 (Nested admitted sets).** Coordinatewise ordered profiles induce nested admitted sets. In particular, increasing one or more cumulative bounds cannot remove an admitted vector.

This monotonicity is useful in enumeration: lattice counts are nondecreasing in every profile coordinate subject to retaining monotonicity. It also justifies incremental search procedures that enlarge a profile until a desired vector or collision appears.

## 5. Affine dilation about the all-ones vector

### 5.1 The affine transform

**Definition 5.1 (Integral affine dilation).** For $t\in\mathbb Z_{\ge0}$ and $a\in\mathbb Z_{>0}$, define

$$
D_t(a)=1+t(a-1).
$$

For vectors and profiles, apply $D_t$ coordinatewise. Geometrically,

$$
D_t(x)=\mathbf1+t(x-\mathbf1),
$$

so the all-ones vector is the center.

**Lemma 5.2 (Order preservation).** If $1\le a\le b$ and $t\ge0$, then

$$
1\le D_t(a)\le D_t(b).
$$

**Proof sketch.** Both $a-1$ and $b-1$ are nonnegative, and multiplication by $t$ preserves their order. Adding $1$ proves the claim. $\square$

**Theorem 5.3 (Affine Dilation Theorem).** If $x$ is admitted by the profile $P$, then $D_t(x)$ is admitted by the profile $D_t(P)$ for every $t\in\mathbb Z_{\ge0}$.

**Proof sketch.** Choose a sorting permutation for $x$. Lemma 5.2 shows that applying $D_t$ preserves the sorted order. From $1\le x_{\sigma(i)}\le P_i$, the lemma also gives

$$
1\le D_t(x_{\sigma(i)})\le D_t(P_i).
$$

Because the map is coordinatewise, the original permutation sorts the transformed vector. The transformed bounds remain positive and nondecreasing, so they form a profile. $\square$

At $t=0$, all entries and bounds become $1$. At $t=1$, the transform is the identity. Composition satisfies

$$
D_s(D_t(a))=D_{st}(a),
$$

showing that these transforms form a multiplicative affine action of nonnegative integers.

**Proposition 5.4 (Deletion commutes with affine dilation).** For every rank $r$,

$$
D_t(P^{\widehat r})=(D_t(P))^{\widehat r},
$$

and the analogous identity holds for sorted vectors.

**Proof sketch.** Both sides apply the same scalar map to precisely the coordinates whose ranks are not $r$. $\square$

Thus slicing within a chamber can occur before or after affine transport with identical results.

## 6. Bounding cubes

**Theorem 6.1 (Universal Coordinate Bound).** Let $P$ be a length-$N$ cumulative profile and let $x$ be admitted by $P$. Then every coordinate satisfies

$$
1\le x_j\le P_N.
$$

**Proof sketch.** Sort $x$ as $y_i=x_{\sigma(i)}$. At every rank,

$$
y_i\le P_i\le P_N.
$$

Every original coordinate equals some sorted coordinate, so the same upper bound holds before sorting. Positivity is part of admission. $\square$

**Corollary 6.2 (Cube containment).** The admitted lattice set lies in

$$
[1,P_N]^N\cap\mathbb Z^N.
$$

Its convex hull, when considered, lies in the real cube $[1,P_N]^N$.

The cube ignores most rank structure and can be much larger than the admitted set. Its virtue is universality: only the largest cumulative bound is required.

## 7. A bridge to short modular-kernel vectors

### 7.1 Syndromes and collisions

Let $A\in\mathbb Z^{m\times N}$ and $q\in\mathbb Z_{>0}$. Define the syndrome of $u\in\mathbb Z^N$ by

$$
S_A(u)=Au\pmod q\in(\mathbb Z/q\mathbb Z)^m.
$$

There are at most $q^m$ syndromes.

**Lemma 7.1 (Bounded-box collision lemma).** Let $B\ge0$. If

$$
q^m<(2B+1)^N,
$$

then there exists a nonzero vector $z\in\mathbb Z^N$ satisfying

$$
Az\equiv0\pmod q
$$

and

$$
\lVert z\rVert_\infty\le2B.
$$

**Proof sketch.** The integer box $[-B,B]^N$ contains $(2B+1)^N$ points. Since there are only $q^m$ syndromes, two distinct points $u$ and $v$ have $Au\equiv Av\pmod q$. Set $z=u-v$. Then $z\ne0$ and $Az\equiv0\pmod q$. Each coordinate is the difference of two integers in $[-B,B]$, hence $|z_i|\le2B$. $\square$

The factor $2$ comes from taking a difference. A collision search may therefore enumerate a radius-$B$ box but return a radius-$2B$ witness.

### 7.2 Parking-profile radius

**Theorem 7.2 (Parking-Box Modular-Kernel Theorem).** Let $P$ be a cumulative profile of length $N$ with largest bound $B=P_N$. Let $A\in\mathbb Z^{m\times N}$ and $q>0$. If

$$
q^m<(2P_N+1)^N,
$$

then there exists a nonzero integer vector $z$ such that

$$
Az\equiv0\pmod q
$$

and

$$
|z_i|\le2P_N
$$

for every $i$.

**Proof sketch.** Apply Lemma 7.1 with $B=P_N$. The profile supplies a geometrically meaningful radius through Theorem 6.1, while the collision argument supplies the modular-kernel witness. $\square$

This theorem does not claim that the witness itself is a parking vector. Rather, the largest parking bound determines a surrounding search scale at which a general modular collision is guaranteed.

### 7.3 Cryptographic interpretation

A short-integer-solution instance asks for a nonzero short vector in a modular kernel. Theorem 7.2 provides an unconditional counting criterion in the infinity norm. It is deliberately matrix-agnostic; no rank-order structure of $A$ is used. Consequently, it is a baseline rather than a profile-sensitive optimum.

A sharper theorem might enumerate parking vectors or differences of parking vectors instead of all box points. Such a refinement would need enough syndrome collisions inside the structured set and a way to bound differences more tightly. Matrices whose columns interact monotonically with profile ranks are plausible candidates.

## 8. Algorithms

### 8.1 Admission testing

Given $x\in\mathbb Z^n$ and a purported profile $P$, first verify positivity and nondecreasing bounds. Sort $x$ to obtain $y$. Return true exactly when $1\le y_i\le P_i$ for all $i$. Sorting dominates the running time, giving $O(n\log n)$ comparisons and $O(n)$ additional inequality checks.

### 8.2 Rank deletion

For sorted $y$ and profile $P$, validate $1\le y_i\le P_i$, remove rank $r$ from both lists, and return the shortened pair. Copying costs $O(n)$ time and space. If persistent sequence structures are used, a view can be created more cheaply, but explicit output remains linear.

### 8.3 Affine transport

Compute $D_t(a)=1+t(a-1)$ independently for each vector coordinate and profile bound. The running time is $O(n)$ arithmetic operations. Bit complexity depends on the sizes of $t$ and the entries.

### 8.4 Modular collision search

Enumerate $u\in[-B,B]^N$, compute $Au\bmod q$, and store the first point for each syndrome. On a repeated syndrome, return the difference from the stored point. The worst-case number of candidates is $(2B+1)^N$; a direct matrix-vector product costs $O(mN)$ modular operations per candidate. Memory is at most $\min(q^m,(2B+1)^N)$ stored syndromes. Incremental enumeration can update syndromes more efficiently, but the exponential dependence on $N$ remains.

### 8.5 Correctness guarantees

The admission algorithm is correct because sorting produces the nondecreasing rearrangement appearing in Definition 2.2; its final loop checks exactly the defining inequalities. The rank-deletion algorithm is correct by Theorem 3.1. The affine algorithm is correct by Theorem 5.3. Finally, whenever the collision algorithm returns $z=u-v$, equality of the stored syndrome keys gives $Az\equiv0\pmod q$, distinct stored points give $z\ne0$, and membership of both points in $[-B,B]^N$ gives $\lVert z\rVert_\infty\le2B$. If the strict cardinality inequality holds, Lemma 7.1 guarantees that the collision algorithm returns before exhausting the box.

### 8.6 Numerical illustration

For $P=(1,3,4)$, exhaustive enumeration of $[1,4]^3$ gives $34$ admitted vectors. Consider also

$$
A=\begin{pmatrix}1&2&3\\2&1&1\end{pmatrix},\qquad q=5.
$$

Taking $B=P_3=4$ gives $(2B+1)^3=729>25=q^2$. A collision search can return two points differing by $z=(0,0,5)$. Direct multiplication gives $Az=(15,5)$, which is zero modulo $5$, and $\lVert z\rVert_\infty=5\le8=2B$. This example demonstrates the guarantee without suggesting that the first witness found is norm-minimal.

## 9. Applications and discussion

The rank-deletion theorem provides a recursive local model for lattice slices. It can reduce dimension in enumeration schemes that track the rank occupied by a fixed coordinate. Combined with profile monotonicity, it also bounds unknown slice pieces between admitted sets for nearby profiles.

Affine dilation identifies the correct center for discrete scaling. Because positivity is anchored at $1$, scaling about the origin is unnatural; scaling about $\mathbf1$ preserves the form of every chamber inequality. This compatibility suggests, but does not prove, an integer-decomposition property for convex hulls of admitted vectors.

The modular-kernel theorem illustrates a broader principle: combinatorial geometry can provide search radii for arithmetic collision arguments. Here only the outer cube is used. The chamber decomposition offers additional information—permutation symmetry, rank restrictions, and potentially exact counts—that could improve the baseline when aligned with matrix structure.

The results also clarify what remains unresolved. A chamberwise rank deletion is not automatically a convex-hull equality for a full labelled-coordinate slice. The fixed value affects which ranks are feasible. Any global transformed profile must encode this value dependence and prove compatibility where chamber closures meet.

## 10. Future work

First, determine a value-dependent gluing rule for labelled-coordinate slices. Computations in low dimensions can compare candidate transformed profiles with exact slice lattice points.

Second, seek a shelling of sorted chambers. If restriction faces contribute polynomials with nonnegative coefficients in cumulative-profile variables, the chamber sum may explain positivity phenomena in multivariate lattice counts and Ehrhart specializations.

Third, investigate integer decomposition under affine dilation. The compatibility of $D_t$ with all sorted inequalities suggests a rankwise constructive decomposition of lattice points.

Fourth, replace the surrounding cube in Theorem 7.2 by a structured parking-profile search set. The goal is to identify matrix families for which parking-vector entropy guarantees collisions at a smaller infinity radius.

## 11. Conclusion

Cumulative profiles expose the ordered structure hidden by permutation symmetry. Within each sorted chamber, deleting matched ranks preserves admission; enlarging bounds produces nested regions; and affine dilation about the all-ones vector transports the full inequality system. A largest-bound cube then links parking geometry to short modular-kernel witnesses through a finite collision argument.

These statements form a coherent local theory. They supply exact chamber operations and a rigorous cryptographic baseline while isolating the main global challenge: gluing rank-dependent pieces of labelled-coordinate slices. The distinction between local chamber geometry and global convex geometry is not a defect but a guide to the next layer of the problem.