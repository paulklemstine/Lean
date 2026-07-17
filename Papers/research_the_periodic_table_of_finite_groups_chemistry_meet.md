# Limits of Coarse Invariants in a Periodic Classification of Finite Groups

## Abstract

A periodic classification of finite groups seeks compact coordinates that organize large families and predict structural behavior. Order and exponent are two natural candidates: the order $|G|$ measures size, while the exponent $\exp(G)$ is the least positive integer annihilating every element. We establish an infinite obstruction to prediction from these coordinates. For every odd integer $n>1$, the cyclic group $C_{2n}$ and the dihedral group $D_{2n}$ have the same order $2n$ and the same exponent $2n$, but the former is cyclic and commutative whereas the latter is neither. Their centers are maximally different: $Z(C_{2n})=C_{2n}$ and $Z(D_{2n})=\{e\}$. The smallest witness occurs at order six, where $C_6$ and the symmetry group of an equilateral triangle share order and exponent but differ in cyclicity, commutativity, and center. We also derive the automorphism count $|\operatorname{Aut}(C_m)|=\varphi(m)$ for cyclic groups, giving $|\operatorname{Aut}(C_6)|=2$. These results show that coarse numerical coordinates cannot determine elementary structural properties. We discuss the distinction between composition factors and extension data, propose a layered structural fingerprint for finite-group classification, and present algorithms for evaluating the counterexample family and testing candidate invariant sets.

## 1. Introduction

The periodic table of chemical elements is valuable not because it lists objects, but because its coordinates organize behavior. This suggests an analogous program for finite groups, the algebraic structures governing finite symmetry. Such a program might use group order as an “atomic number,” group families as chemical series, and composition factors as structural constituents. Its strongest ambition would be predictive: nearby or co-columnar groups should share properties, and unexamined groups should inherit likely behavior from their coordinates.

A prerequisite for such prediction is feature adequacy. If two groups agree on every coordinate supplied to a classification system but disagree on the property to be predicted, no rule based only on those coordinates can always succeed. It is therefore important to identify collisions of invariants: pairs or families of nonisomorphic groups that share selected measurements while differing structurally.

This paper studies the pair consisting of group order and group exponent. Both are elementary, isomorphism-invariant, and computationally accessible. The exponent incorporates more information than order alone because it summarizes element orders. Nevertheless, the pair fails dramatically. For every odd $n>1$, a cyclic group and a dihedral group share both coordinates while differing in cyclicity, commutativity, and center.

The family is useful for three reasons. First, it is infinite, so the phenomenon cannot be dismissed as a sporadic low-order anomaly. Second, the proof is elementary and exposes precisely where the shared numerical data cease to control multiplication. Third, its smallest member, at order six, can be inspected directly and serves as a benchmark for computational classification.

The conclusion is constructive rather than merely negative. A viable periodic organization should use a layered fingerprint. Composition factors describe simple layers, but extension data describes their assembly. Center order, derived length, nilpotency class, exponent, and automorphism-group order add complementary information. In a computational or machine-learning setting, the cyclic–dihedral family is a feature-selection test: any representation collapsing these pairs cannot predict the properties on which they differ.

## 2. Definitions and notation

### 2.1 Finite groups and order

A **group** is a set $G$ with an associative binary operation, an identity element $e$, and an inverse $g^{-1}$ for every $g\in G$. A group is **finite** if its underlying set has finitely many elements. Its **order**, denoted $|G|$, is that number of elements.

Two groups are **isomorphic** if there is a bijection between them preserving multiplication. Every quantity considered below is invariant under isomorphism.

### 2.2 Cyclic groups

A group $G$ is **cyclic** if there is an element $g\in G$ such that every element is a power of $g$. We then write

$$
G=\langle g\rangle=\{g^k:k\in\mathbb Z\}.
$$

Up to isomorphism, there is one cyclic group of each positive finite order $m$, denoted $C_m$. If $g$ generates $C_m$, then $g^m=e$ and no smaller positive power of $g$ is the identity.

Every cyclic group is commutative. Indeed, if $x=g^a$ and $y=g^b$, then

$$
xy=g^{a+b}=g^{b+a}=yx.
$$

### 2.3 Dihedral groups

For $n\ge 1$, the **dihedral group** $D_{2n}$ is the full symmetry group of a regular $n$-gon. It consists of $n$ rotations and $n$ reflections, so

$$
|D_{2n}|=2n.
$$

It admits the presentation

$$
D_{2n}=\langle r,s\mid r^n=e,\ s^2=e,\ srs=r^{-1}\rangle.
$$

Here $r$ is rotation by one vertex and $s$ is a reflection. Every element has a unique form $r^k$ or $sr^k$, with $0\le k<n$. Our notation uses the group order in the subscript; some literature denotes the same group by $D_n$.

### 2.4 Element order and group exponent

The **order** of an element $g\in G$, written $\operatorname{ord}(g)$, is the least positive integer $k$ such that $g^k=e$, when such an integer exists. In a finite group it always exists.

The **exponent** of a finite group $G$ is

$$
\exp(G)=\operatorname{lcm}\{\operatorname{ord}(g):g\in G\}.
$$

Equivalently, $\exp(G)$ is the least positive integer $m$ such that $g^m=e$ for all $g\in G$. The exponent divides $|G|$, although groups of the same order may have different exponents.

### 2.5 Commutativity and the center

A group $G$ is **commutative** or **abelian** if $xy=yx$ for all $x,y\in G$. Its **center** is

$$
Z(G)=\{z\in G:zg=gz\text{ for every }g\in G\}.
$$

The center is a normal subgroup. A group is abelian exactly when $Z(G)=G$. At the other extreme, a group has **trivial center** when $Z(G)=\{e\}$.

### 2.6 Automorphisms and Euler’s totient

An **automorphism** of $G$ is an isomorphism from $G$ to itself. The automorphisms form a group $\operatorname{Aut}(G)$ under composition. The order $|\operatorname{Aut}(G)|$ measures the number of multiplication-preserving relabelings of $G$.

Euler’s totient function $\varphi(m)$ counts the integers $k$ with $1\le k\le m$ and $\gcd(k,m)=1$.

## 3. Elementary structural lemmas

We first collect the facts that drive the main separation theorem.

### Lemma 3.1. Order of the comparison groups

For every positive integer $n$,

$$
|C_{2n}|=|D_{2n}|=2n.
$$

**Proof sketch.** The first equality is the definition of $C_{2n}$. The dihedral group has one rotation $r^k$ and one reflected symmetry $sr^k$ for each residue $k$ modulo $n$. These two classes are disjoint and each has $n$ elements, giving $2n$ in total. $\square$

### Lemma 3.2. Exponent of a finite cyclic group

For every positive integer $m$,

$$
\exp(C_m)=m.
$$

**Proof sketch.** A generator $g$ has order $m$, so the group exponent is at least $m$. Every element is $g^k$, and $(g^k)^m=(g^m)^k=e$, so $m$ annihilates every element. Hence the least common multiple of all element orders is exactly $m$. $\square$

### Lemma 3.3. Exponent of a dihedral group

For every positive integer $n$,

$$
\exp(D_{2n})=\operatorname{lcm}(n,2).
$$

**Proof sketch.** The rotation $r$ has order $n$, so the exponent is divisible by $n$. Every reflection has order $2$, so the exponent is divisible by $2$. Conversely, every rotation has order dividing $n$, and every reflected element $sr^k$ squares to the identity:

$$
(sr^k)^2=sr^ksr^k=r^{-k}r^k=e.
$$

Thus every element order divides $\operatorname{lcm}(n,2)$, proving equality. $\square$

### Corollary 3.4. Odd dihedral exponent

If $n$ is odd, then

$$
\exp(D_{2n})=2n.
$$

**Proof sketch.** Oddness gives $\gcd(n,2)=1$, and therefore $\operatorname{lcm}(n,2)=2n$. Apply Lemma 3.3. $\square$

### Lemma 3.5. Cyclic and dihedral commutativity

The group $C_m$ is commutative for every $m$. The group $D_{2n}$ is noncommutative for $n>2$.

**Proof sketch.** Commutativity of cyclic groups follows by adding exponents. In the dihedral group, $sr=r^{-1}s$. If $sr=rs$, then $r=r^{-1}$ and hence $r^2=e$. But $r$ has order $n>2$, a contradiction. $\square$

### Lemma 3.6. Noncyclicity of nondegenerate dihedral groups

For every $n>1$, the group $D_{2n}$ is not cyclic.

**Proof sketch.** Every cyclic group is commutative. For $n>2$, Lemma 3.5 immediately proves noncyclicity. When $n=2$, the group has four elements, each nonidentity element has order $2$, so it has no element of order $4$ and cannot be cyclic. The theorem below uses odd $n>1$, hence automatically $n\ge3$. $\square$

## 4. The infinite collision theorem

### Theorem 4.1. Same order and exponent, different structure

Let $n>1$ be odd. Then $C_{2n}$ and $D_{2n}$ satisfy

$$
|C_{2n}|=|D_{2n}|=2n
$$

and

$$
\exp(C_{2n})=\exp(D_{2n})=2n.
$$

Nevertheless, $C_{2n}$ is cyclic and commutative, while $D_{2n}$ is neither cyclic nor commutative.

**Proof sketch.** Lemma 3.1 gives the common order. Lemma 3.2 gives $\exp(C_{2n})=2n$. Since $n$ is odd, Corollary 3.4 gives $\exp(D_{2n})=2n$. The cyclic group is cyclic by construction and commutative by Lemma 3.5. Since odd $n>1$ implies $n\ge3$, Lemmas 3.5 and 3.6 show that the dihedral group is noncommutative and noncyclic. $\square$

The theorem gives infinitely many pairs because there are infinitely many odd integers greater than one. In particular, collisions occur at every order $2n$ congruent to $2$ modulo $4$, beginning with $6,10,14,18,22$.

### Consequence 4.2. Impossibility of prediction from two coordinates

There is no function of the pair $(|G|,\exp(G))$ that correctly determines cyclicity for every finite group. Likewise, no function of this pair correctly determines commutativity for every finite group.

**Proof sketch.** For each odd $n>1$, Theorem 4.1 supplies two groups with the same input pair $(2n,2n)$ and opposite truth values for cyclicity and commutativity. A function receiving identical inputs cannot return two different correct outputs. $\square$

This is an information-theoretic obstruction, not a limitation of a particular classifier. Increasing model complexity or training data cannot recover distinctions absent from the input features.

## 5. Separation by the center

The center gives a stronger measure of the structural gap.

### Theorem 5.1. Center of the cyclic comparison group

For every positive integer $m$,

$$
Z(C_m)=C_m.
$$

**Proof sketch.** A cyclic group is commutative, so every element commutes with every other element. Therefore every element satisfies the defining condition for membership in the center. $\square$

### Theorem 5.2. Center of an odd dihedral group

If $n>1$ is odd, then

$$
Z(D_{2n})=\{e\}.
$$

**Proof sketch.** Let $r^k$ be a central rotation. It must commute with $s$. Conjugating by $s$ gives

$$
sr^ks=r^{-k}.
$$

Centrality requires $r^k=r^{-k}$, so $r^{2k}=e$ and $n$ divides $2k$. Since $n$ is odd, $n$ divides $k$, hence $r^k=e$.

Now consider a reflected element $sr^k$. If it were central, it would commute with $r$. Using the defining relation gives

$$
(sr^k)r=sr^{k+1},
$$

whereas

$$
r(sr^k)=sr^{k-1}.
$$

Equality would imply $r^{k+1}=r^{k-1}$, hence $r^2=e$, contradicting the odd order $n>1$ of $r$. Thus no reflection is central, and only $e$ remains. $\square$

### Corollary 5.3. Maximal central separation

For every odd $n>1$, the two groups in Theorem 4.1 have center orders

$$
|Z(C_{2n})|=2n,
\qquad
|Z(D_{2n})|=1.
$$

Thus groups with identical order and exponent can attain opposite extremes of central structure: one is entirely central, and the other has no nontrivial central element.

## 6. The minimal witness at order six

Set $n=3$. The cyclic group $C_6$ and the dihedral group $D_6$, the latter being the symmetry group of an equilateral triangle, both have six elements. Their exponents are

$$
\exp(C_6)=6
$$

and

$$
\exp(D_6)=\operatorname{lcm}(3,2)=6.
$$

Yet $C_6$ is cyclic and abelian, while $D_6$ is noncyclic and nonabelian. Their centers satisfy

$$
Z(C_6)=C_6,
\qquad
Z(D_6)=\{e\}.
$$

This is the smallest member of the odd family. It can also be displayed by multiplication rules. Write

$$
C_6=\{e,g,g^2,g^3,g^4,g^5\},\qquad g^6=e.
$$

Every product is determined by addition modulo $6$. For the triangle group, write

$$
D_6=\{e,r,r^2,s,sr,sr^2\},
$$

with $r^3=s^2=e$ and $sr=r^{-1}s$. Then $sr\ne rs$, explicitly witnessing noncommutativity.

The order-six example also highlights a distinction relevant to composition-based classification. Both groups have prime-order simple layers of sizes $2$ and $3$, but the layers are assembled differently. In $C_6$, the prime components combine commutatively. In $D_6$, a reflection acts nontrivially on the threefold rotation subgroup by inversion. The constituent sizes alone do not encode this action.

## 7. Automorphisms of cyclic groups

### Theorem 7.1. Automorphism count for a finite cyclic group

For every positive integer $m$,

$$
|\operatorname{Aut}(C_m)|=\varphi(m).
$$

**Proof sketch.** Choose a generator $g$ of $C_m$. An automorphism is determined by the image of $g$, because every element is a power of $g$. The image must itself generate the group; otherwise the map cannot be surjective. The element $g^k$ is a generator exactly when $\gcd(k,m)=1$. Conversely, each such $k$ defines an automorphism by $g^a\mapsto g^{ka}$. There are $\varphi(m)$ admissible residue classes, proving the count. $\square$

### Corollary 7.2. The cyclic order-six automorphism count

The group $C_6$ has exactly two automorphisms:

$$
|\operatorname{Aut}(C_6)|=\varphi(6)=2.
$$

The two generators are $g$ and $g^5=g^{-1}$, so an automorphism sends $g$ either to itself or to its inverse.

Automorphism-group order is a useful candidate feature for a richer classification because it measures internal redundancy of description. It should not, however, be expected to determine a group on its own; like the other invariants, it belongs in a layered fingerprint.

## 8. Algorithms and numerical experiments

The theorem family admits direct computation without constructing full multiplication tables.

### 8.1 Counterexample-family enumeration

Given a bound $B$, enumerate odd integers $n>1$ with $2n\le B$. For each, output the common order $2n$, cyclic exponent $2n$, dihedral exponent $\operatorname{lcm}(n,2)$, cyclicity and commutativity flags, and center sizes $2n$ and $1$.

If $B$ is the order bound, the algorithm performs $O(B)$ iterations and uses $O(1)$ auxiliary space apart from its output. Each row requires a greatest-common-divisor computation for the least common multiple, taking $O(\log n)$ arithmetic steps.

### 8.2 Cyclic automorphism counting

To compute $|\operatorname{Aut}(C_m)|$, count integers $k$ in $1\le k\le m$ satisfying $\gcd(k,m)=1$. Trial counting costs $O(m\log m)$ elementary arithmetic time. A factorization-based totient formula,

$$
\varphi(m)=m\prod_{p\mid m}\left(1-\frac1p\right),
$$

is faster when the prime factors are known.

### 8.3 Feature-collision testing

For a finite database of groups, choose a proposed fingerprint $F(G)$ and a target property $P(G)$. Bucket the groups by equal fingerprint. A bucket is **impure** when it contains groups with different values of $P$. Every impure bucket proves that $F$ does not determine $P$ on the database. The cyclic–dihedral theorem supplies infinitely many analytically certified impure buckets for

$$
F(G)=(|G|,\exp(G))
$$

and for either target $P=$ cyclicity or $P=$ commutativity.

With $N$ records and hashable fingerprints, bucketing has expected time $O(N)$ and space $O(N)$. This method is appropriate both for exploratory mathematics and for auditing features used by classifiers.

## 9. Composition factors and extension data

A **composition series** for a finite group $G$ is a chain

$$
\{e\}=G_0\triangleleft G_1\triangleleft\cdots\triangleleft G_k=G
$$

in which each quotient $G_{i+1}/G_i$ is simple. These quotients are the **composition factors**. Their multiset is independent of the chosen composition series.

Composition factors are therefore natural column labels. Yet a column defined to consist of groups with equal composition factors shares those factors by definition; the substantive question is which additional properties follow. Generally, factors record layers but not gluing. **Extension data** records how a quotient acts on a normal subgroup and whether the resulting assembly splits or twists.

The order-six comparison illustrates the issue. There is a normal subgroup of order $3$ and a quotient of order $2$ in each case. In the cyclic group, the interaction is trivial and the whole group is abelian. In the dihedral group, the order-two symmetry acts on the order-three rotation subgroup by inversion. The same prime-size layers thus support different multiplication laws.

Consequently, one should not expect composition factors alone to determine commutativity, nilpotency, derived length, center, or automorphism-group order. These are precisely the kinds of independence questions that a rigorous periodic classification should display rather than obscure.

## 10. A layered periodic schema

A robust finite-group table may organize each group by a structured fingerprint

$$
\mathcal F(G)=
\bigl(
|G|,
\text{composition factors},
\text{extension data},
\exp(G),
|Z(G)|,
\text{derived length},
\text{nilpotency class},
|\operatorname{Aut}(G)|
\bigr).
$$

The entries play distinct roles.

1. **Order** measures size and restricts possible subgroup indices.
2. **Composition factors** identify irreducible layers.
3. **Extension data** describes how those layers interact.
4. **Exponent** summarizes element orders.
5. **Center order** measures the globally commuting core.
6. **Derived length** measures the depth of noncommutativity in solvable groups.
7. **Nilpotency class** measures central-series complexity.
8. **Automorphism-group order** measures symmetries of the multiplication structure.

This is not claimed to be a complete invariant. Rather, it is a disciplined schema in which collisions become mathematically informative. A pair sharing early coordinates but separating later ones demonstrates the independence of those later features. In a visual table, users could first group by composition factors and then refine by extension type and secondary invariants.

For machine learning, the schema suggests both supervised and unsupervised tasks. Supervised models could predict expensive invariants from cheaper ones, but collision tests must establish the irreducible uncertainty of the feature set. Unsupervised embeddings could seek families while preserving known structural separations. In either setting, theorem-driven counterexamples should accompany empirical accuracy.

## 11. Applications and implications

### 11.1 Symmetry analysis

Cyclic symmetry models repeated motion in one direction, while dihedral symmetry adds reversal. The theorem shows that size and global reset period do not detect the presence of reversal or the noncommutativity it causes. Applications involving molecular symmetry, mechanical linkages, or image transformations must therefore record operation interactions, not just cycle statistics.

### 11.2 Data representation

In classification, an invariant vector is a lossy encoding. The pair $(|G|,\exp(G))$ maps $C_{2n}$ and $D_{2n}$ to the same vector for odd $n>1$. If labels include abelian versus nonabelian, the encoded dataset contains unavoidable label collisions. This provides a clean benchmark for whether a system reports uncertainty honestly or overstates predictive confidence.

### 11.3 Database design

A census of groups through a finite order should separate certification from enumeration. Multiplication tables can be checked for the group axioms; algorithms can then compute centers, element orders, normal series, and other invariants. Collision reports should be first-class outputs, since they show which proposed coordinates fail to determine which properties.

### 11.4 Mathematical exposition

The chemical analogy remains pedagogically useful if its limits are explicit. Cyclic groups may be portrayed as structurally regular, and symmetric or dihedral groups as interaction-rich, but metaphors must not be mistaken for classification theorems. The order-six pair is a compact corrective: identical “atomic number” and exponent do not imply identical algebraic behavior.

## 12. Discussion

The main result is intentionally elementary, but its methodological force is broad. Classification schemes often begin with invariants that are easy to calculate. Ease of calculation does not imply predictive sufficiency. The right question is not merely whether an invariant correlates with a property, but whether the invariant can determine that property in principle.

The cyclic–dihedral family answers this decisively for order plus exponent. It also demonstrates the value of parametric counterexamples. A lone pair might reflect exceptional arithmetic. An infinite family identifies a mechanism: for odd $n$, the rotation period $n$ and reflection period $2$ combine into exponent $2n$, exactly matching the cyclic order. The exponent sees the least common multiple of local periods but forgets whether the corresponding motions commute.

The center reveals how much is forgotten. In one group every element commutes globally; in the other only the identity does. Thus the shared exponent is compatible not merely with modest structural variation but with maximal variation in centrality.

A periodic table of finite groups should consequently be viewed as an interface to a hierarchy of invariants rather than as a single two-dimensional arrangement. Its success would lie in making refinement visible: coarse coordinates locate a broad region, composition factors specify layers, extension data specifies assembly, and secondary invariants expose behavior.

## 13. Future work

Several concrete directions follow.

First, the order-six witness should be developed fully at the level of composition series, making explicit that $C_6$ and $D_6$ have simple factors of orders $2$ and $3$ while retaining their structural differences. Second, comparing $|\operatorname{Aut}(C_6)|=2$ with the automorphism group of the triangle symmetry group would test whether automorphism order varies within a composition-factor column. Third, one should construct examples with the same abelian simple factors but different derived lengths, and examples with the same composition factors but different nilpotency behavior.

A finite census through order $100$ would provide a useful experimental platform. Rather than relying on unstructured brute force, one may certify supplied multiplication tables, compute normal and composition series, and generate invariant fingerprints. The resulting collision matrix would indicate which coordinates determine which properties within the census and which failures extend to parametric families.

Finally, predictive models should incorporate extension-sensitive representations. Composition factors can serve as a backbone, but actions between layers must be encoded if the targets depend on commutativity, centrality, or nilpotency. The mathematical aim is not to eliminate collisions at any cost, but to understand exactly what information each refinement contributes.

## 14. Conclusion

For every odd integer $n>1$, the cyclic group $C_{2n}$ and the dihedral group $D_{2n}$ share order $2n$ and exponent $2n$, yet differ in cyclicity and commutativity. Their centers are opposite extremes: the whole cyclic group versus the identity subgroup. At order six, this compares a six-step cycle with the six symmetries of an equilateral triangle; the cyclic group additionally has exactly two automorphisms.

These results impose a precise limitation on periodic classification by coarse invariants. Order and exponent are meaningful coordinates, but they do not encode how symmetries interact. Composition factors improve the picture by recording simple layers, while extension data and secondary invariants are needed to describe assembly and behavior. A successful periodic table of finite groups must therefore be layered, collision-aware, and explicit about the information each coordinate forgets.
