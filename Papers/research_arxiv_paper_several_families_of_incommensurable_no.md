# Commensurability Invariants and Exponential Volume Growth in Hyperbolic Coxeter Families

**Aristotle**  
**25 July 2026**

## Abstract

We isolate a general separation-and-counting mechanism underlying exponential lower bounds for commensurability classes of finite-volume noncompact hyperbolic Coxeter polytopes. For a finite family equipped with an equivalence relation, any invariant constant on equivalence classes has no more distinct values than there are represented classes. This elementary factorization principle converts geometric separation into image counting. We also establish the local Gram-matrix constraint $-1<-\cos(\pi/m)\le0$ for every Coxeter angle $\pi/m$ with integer $m\ge2$. To exhibit the growth mechanism without collapsing commensurability to equality, we construct a decorated binary model in which equivalence forgets one genuine decoration bit, the invariant assumes exactly $2^n$ values, and every object has size at most $n$. The model therefore has at least $2^n$ classes below a linear size bound and satisfies $1+n\log2\le2^n$. We then formulate the geometric transfer theorem: a binary family of Coxeter polytopes with linearly bounded volume and a word-separating commensurability invariant has exponentially many commensurability classes as a function of volume. We discuss maximal cusp density, Gram-matrix screening, classification workflows, algorithms, limitations, and entropy-weighted extensions.

## 1. Introduction

A hyperbolic Coxeter polytope is a convex polytope in hyperbolic space whose dihedral angles are integral submultiples of $\pi$. Reflections in its facets generate a discrete group, and reflected copies tile the ambient hyperbolic space. The interaction of discrete angles, Lorentzian linear algebra, and finite-volume geometry makes these polytopes unusually rigid.

The noncompact finite-volume case is especially rich. Such a polytope reaches the ideal boundary through cusps but retains finite volume. Its finite vertices have spherical Coxeter links, whereas its ideal vertices have Euclidean, or affine, Coxeter links. Any classification or construction must coordinate local angle data, global incidence, matrix signature, and cusp geometry.

Counting objects up to isometry is not always the most informative objective. Reflection groups and their orbifolds may instead be grouped by **commensurability**: two groups are commensurable if, after conjugacy where appropriate, they contain isomorphic finite-index subgroups. This relation deliberately ignores finite-sheeted differences and captures shared large-scale arithmetic and geometric structure.

The motivating geometric setting includes a finite classification of $141$ five-dimensional finite-volume hyperbolic Coxeter polytopes with eight facets, among which $125$ are noncompact, together with constructions of incommensurable noncompact families in dimensions $4$, $5$, $6$, $7$, and $9$. The present work does not reproduce that geometric classification. Its purpose is to extract and analyze the reusable mathematical engine behind an exponential commensurability count.

That engine has two inputs:

1. a commensurability invariant that separates many constructed objects; and
2. a construction in which the geometric cost, measured by volume, grows only linearly with the number of independent choices.

The first input turns distinct invariant values into distinct classes. The second allows $n$ binary choices to produce $2^n$ candidates below a volume bound of order $n$. The resulting lower bound is exponential in volume.

A crucial distinction will be maintained throughout. The separation-and-counting theorem is universal and elementary. The assertion that a particular invariant, such as maximal cusp density, separates an actual geometric family is a substantive geometric input. By separating these layers, one can see exactly which part of the argument is combinatorial and which part must be supplied by hyperbolic geometry.

## 2. Geometric and algebraic preliminaries

### 2.1. Hyperbolic Coxeter polytopes

Let $\mathbb H^d$ denote $d$-dimensional hyperbolic space. A **hyperbolic Coxeter polytope** $P\subset\mathbb H^d$ is a convex polytope such that whenever two facets meet, their dihedral angle is

$$
\frac{\pi}{m}
$$

for some integer $m\ge2$. Reflections in the supporting hyperplanes of the facets generate a discrete reflection group $\Gamma_P$. The polytope $P$ is a fundamental domain for this action.

A polytope is **noncompact of finite volume** if it has at least one ideal vertex on the boundary of hyperbolic space but finite hyperbolic volume. Neighborhoods of its ideal vertices descend to cusps of the associated orbifold $\mathbb H^d/\Gamma_P$.

### 2.2. Gram matrices

Choose outward unit normals $e_1,\ldots,e_f$ to the facet hyperplanes in the Lorentzian model. The **Gram matrix** $G=(g_{ij})$ records their Lorentzian inner products. Its diagonal entries are

$$
g_{ii}=1.
$$

If facets $i$ and $j$ meet at angle $\pi/m_{ij}$, then

$$
g_{ij}=-\cos\left(\frac{\pi}{m_{ij}}\right).
$$

Additional formulas describe parallel or ultraparallel facets, but the intersecting-facet case is the one needed here. A realizable Coxeter Gram matrix must satisfy more than entrywise bounds: it must have an appropriate Lorentzian signature and must be compatible with the incidence structure and the spherical or affine types of vertex links.

### 2.3. Commensurability

Two reflection groups $\Gamma_P$ and $\Gamma_Q$ are **commensurable** if, after conjugating one group in the ambient isometry group if needed, their intersection has finite index in each. Equivalently, their associated orbifolds admit a common finite-sheeted cover. This is an equivalence relation.

For a family $X$ of polytopes, write $P\sim Q$ when the corresponding reflection groups are commensurable. The quotient $X/{\sim}$ is the set of commensurability classes.

### 2.4. Invariants

Let $Y$ be any set. A function

$$
I:X\longrightarrow Y
$$

is a **commensurability invariant** if

$$
P\sim Q\quad\Longrightarrow\quad I(P)=I(Q).
$$

The value may be numerical, algebraic, combinatorial, or a tuple of several types of data. Candidate invariants in hyperbolic geometry include invariant trace fields, appropriate covolume information, and maximal cusp data. The only property required for the abstract results is constancy on classes.

An invariant is **separating on a subfamily** $S\subseteq X$ if distinct elements of $S$ have distinct invariant values. Full separation is stronger than necessary: it suffices to establish a lower bound on the number of distinct values.

## 3. The invariant-counting bridge

The first theorem is a general fact about finite equivalence relations.

### Theorem 3.1 (Invariant-counting principle)

Let $X$ be a set with an equivalence relation $\sim$, let $S\subseteq X$ be finite, and let $I:X\to Y$ satisfy

$$
x\sim x'\quad\Longrightarrow\quad I(x)=I(x').
$$

Then

$$
|I(S)|\le \bigl|\{[x]:x\in S\}\bigr|,
$$

where $[x]$ denotes the equivalence class of $x$.

#### Proof sketch

Let $q:X\to X/{\sim}$ be the quotient map. Since $I$ is constant on equivalence classes, there is a well-defined function $\overline I:X/{\sim}\to Y$ given by $\overline I([x])=I(x)$. Thus $I=\overline I\circ q$. Restricting to $S$ gives

$$
I(S)=\overline I(q(S)).
$$

The image of a finite set under a function has cardinality no greater than that of the set itself. Hence $|I(S)|\le|q(S)|$, as claimed.

### Corollary 3.2 (Lower bound from invariant values)

Under the hypotheses of Theorem 3.1, if $I$ assumes at least $N$ distinct values on $S$, then $S$ represents at least $N$ equivalence classes.

#### Proof sketch

Combine $N\le|I(S)|$ with Theorem 3.1.

### Remark 3.3 (Sharpness and limitations)

The inequality can be an equality when the invariant distinguishes all represented classes. It can also be very weak: many different classes may share one value. Therefore the theorem does not manufacture separation. Its force depends entirely on proving that the chosen invariant has a large image.

### Remark 3.4 (Computational consequence)

Direct pairwise comparison of $M$ objects may require $O(M^2)$ relation tests. Evaluating an invariant once per object and deduplicating its values may require $O(M)$ evaluations plus hashing or sorting. This does not replace a proof that the invariant is valid, but it can dramatically reorganize classification and exploration.

## 4. The Coxeter Gram-entry constraint

The local trigonometric condition on intersecting facets is exact.

### Theorem 4.1 (Admissible off-diagonal range)

For every integer $m\ge2$,

$$
-1<-\cos\left(\frac{\pi}{m}\right)\le0.
$$

Equivalently,

$$
0\le\cos\left(\frac{\pi}{m}\right)<1.
$$

#### Proof sketch

Because $m\ge2$,

$$
0<\frac{\pi}{m}\le\frac{\pi}{2}.
$$

Cosine is nonnegative on $[0,\pi/2]$, which gives the upper bound after negation. Moreover, cosine is strictly decreasing on $[0,\pi]$. Since $\pi/m>0$,

$$
\cos(\pi/m)<\cos(0)=1.
$$

Negation yields the strict lower bound $-1<-\cos(\pi/m)$.

### Examples 4.2

For small Coxeter orders,

$$
\begin{aligned}
m=2&:&-\cos(\pi/2)&=0,\\
m=3&:&-\cos(\pi/3)&=-\frac12,\\
m=4&:&-\cos(\pi/4)&=-\frac{\sqrt2}{2},\\
m=6&:&-\cos(\pi/6)&=-\frac{\sqrt3}{2}.
\end{aligned}
$$

As $m\to\infty$, the angle tends to $0$ and the entry tends to $-1$ from above.

### Proposition 4.3 (Local screening rule)

If a proposed Gram matrix has an off-diagonal entry for two intersecting facets that does not lie in $(-1,0]$, then that entry cannot equal $-\cos(\pi/m)$ for any integer $m\ge2$.

#### Proof sketch

This is the contrapositive of Theorem 4.1.

The screening rule is necessary but not sufficient for realizability. A matrix passing it may still have the wrong signature, incompatible principal submatrices, or invalid vertex links.

## 5. A nondegenerate decorated binary model

We now build a finite model that contains all ingredients of the exponential argument while ensuring that equivalence is genuinely coarser than equality.

Fix $n\ge0$. Let

$$
W_n=\{0,1\}^n
$$

be the set of binary words of length $n$, and define the object set

$$
X_n=W_n\times\{0,1\}.
$$

An element is written $(w,\varepsilon)$, where $w$ is the structural word and $\varepsilon$ is a decoration.

### Definition 5.1 (Model equivalence)

Declare

$$
(w,\varepsilon)\sim_n(w',\varepsilon')
\quad\Longleftrightarrow\quad
w=w'.
$$

This is an equivalence relation because equality of words is reflexive, symmetric, and transitive.

### Definition 5.2 (Model invariant)

Define

$$
I_n(w,\varepsilon)=w.
$$

It is constant on $\sim_n$-classes by definition.

### Definition 5.3 (Model volume)

Define the model volume as the Hamming weight of the structural word:

$$
V_n(w,\varepsilon)
=
\#\{i\in\{1,\ldots,n\}:w_i=1\}.
$$

This quantity is nonnegative and satisfies $V_n(w,\varepsilon)\le n$.

### Proposition 5.4 (Equivalence is not equality)

For every word $w\in W_n$, the objects $(w,0)$ and $(w,1)$ are distinct but equivalent. Hence every equivalence class contains exactly two objects, and $\sim_n$ is strictly coarser than equality.

#### Proof sketch

The objects differ in their second coordinates, so they are unequal. Their first coordinates agree, so they are equivalent. Conversely, equivalence fixes the word and leaves only two possible decorations.

### Proposition 5.5 (Exact invariant count)

The invariant $I_n$ takes exactly $2^n$ distinct values on $X_n$.

#### Proof sketch

Every value is a binary word of length $n$. Conversely, every binary word $w$ occurs as $I_n(w,0)$ and as $I_n(w,1)$. Since there are $2^n$ binary words, the image has cardinality $2^n$.

### Proposition 5.6 (Linear size bound)

Every object in $X_n$ satisfies

$$
V_n(w,\varepsilon)\le n.
$$

#### Proof sketch

The set of occupied coordinates is a subset of an $n$-element coordinate set.

### Theorem 5.7 (Exponential growth below a linear bound)

For every integer $n\ge0$, all objects of $X_n$ have model volume at most $n$, and $X_n$ represents at least $2^n$ equivalence classes. Moreover,

$$
1+n\log2\le2^n.
$$

#### Proof sketch

The volume statement is Proposition 5.6. Proposition 5.5 and Corollary 3.2 give at least $2^n$ classes. In fact Proposition 5.4 shows there are exactly $2^n$. Finally,

$$
2^n=\exp(n\log2),
$$

and the convexity inequality $e^x\ge1+x$, applied to $x=n\log2$, gives the analytic lower bound.

### Discussion 5.8

The decoration coordinate is mathematically important. Without it one might take $X_n=W_n$ and let equivalence be equality, obtaining the same numerical count but no model of information forgotten by commensurability. Here the objects carry strictly more data than their classes, while the invariant detects precisely the class-relevant word. Thus the exponential count is not an artifact of a discrete equivalence relation.

The word itself should be interpreted as an abstract record of $n$ local choices. The model does not claim that these choices are automatically realizable as hyperbolic polytopes. It isolates the combinatorial consequence that follows once geometric realizability and invariant separation have been established.

## 6. Transfer to geometric families

The abstract mechanism yields a direct theorem for any geometric construction satisfying two quantitative hypotheses.

### Theorem 6.1 (Binary geometric transfer theorem)

Let $d\ge2$. Suppose that for every $n\ge0$ and every word $w\in\{0,1\}^n$ there is a finite-volume noncompact hyperbolic Coxeter $d$-polytope $P_w$. Assume:

1. there are constants $A>0$ and $B\ge0$, independent of $n$ and $w$, such that

$$
\operatorname{vol}(P_w)\le An+B;
$$

2. there is a commensurability invariant $I$ such that $I(P_w)\ne I(P_{w'})$ whenever $w\ne w'$.

Then the family $\{P_w:w\in\{0,1\}^n\}$ contains at least $2^n$ commensurability classes. Consequently, if $N_d(V)$ denotes the number of represented classes having a member of volume at most $V$, then at the thresholds $V_n=An+B$,

$$
N_d(V_n)\ge2^n
=
\exp\left(\frac{\log2}{A}(V_n-B)\right).
$$

#### Proof sketch

There are $2^n$ words, and hypothesis 2 says their invariant values are pairwise distinct. Corollary 3.2 gives at least $2^n$ classes. Hypothesis 1 places every member below $V_n$. Solving $n=(V_n-B)/A$ gives the displayed exponential form.

### Corollary 6.2 (Partial separation)

If the invariant assumes at least $c\lambda^n$ values for constants $c>0$ and $\lambda>1$, while volume is at most $An+B$, then

$$
N_d(An+B)\ge c\lambda^n
= c\exp\left(\frac{\log\lambda}{A}(An+B-B)\right).
$$

Thus full recovery of every construction word is not essential; any exponentially large invariant image suffices.

### Corollary 6.3 (Bounded ambiguity)

Suppose there are $q^n$ construction words, each invariant value is shared by at most $a_n$ words, and $\log a_n=o(n)$. Then the number of classes is at least $q^n/a_n$, whose logarithmic growth rate per construction site tends to $\log q$.

#### Proof sketch

Partition the words by invariant value. If every fiber has size at most $a_n$, there are at least $q^n/a_n$ values. Taking logarithms and dividing by $n$ gives $\log q-(\log a_n)/n\to\log q$.

## 7. Maximal cusp density as a separation mechanism

For a noncompact finite-volume hyperbolic orbifold, a cusp can be represented by a quotient of a horoball neighborhood. One may enlarge a compatible collection of disjoint cusp neighborhoods until further enlargement would create overlap. The total volume of such a maximal cusp configuration, divided by the orbifold volume, is a **maximal cusp density**.

When defined canonically or as an appropriate extremal value, cusp density can be constant on commensurability classes. It is then eligible for Theorem 3.1. The geometric challenge is to compute or compare the densities produced by local modifications.

A binary cusp construction would proceed as follows. Choose $n$ controlled sites. At each site install one of two admissible cusp pieces. Require that all choices preserve the Coxeter and finite-volume conditions, that each site adds at most a fixed amount of volume, and that the resulting maximal cusp density encodes the full word. Theorem 6.1 then gives $2^n$ commensurability classes below a linear volume bound.

This description makes clear what is and is not supplied by the abstract argument. The counting theorem proves that distinct cusp densities imply distinct commensurability classes. It does not prove that a proposed cusp replacement exists, preserves geometric realizability, or produces distinct densities. Those are the essential geometric calculations.

## 8. Algorithms

### 8.1. Invariant-image class lower bound

Given a finite list of objects and a computable invariant, evaluate the invariant on each object, insert the values into a set, and return the set size. If invariance has been established mathematically, the output is a lower bound on represented classes.

For $M$ objects, invariant evaluation cost $T_I$, and hashable values, the expected running time is $O(MT_I+M)$ with $O(M)$ memory. Sorting instead of hashing gives $O(MT_I+M\log M)$ time.

### 8.2. Coxeter Gram-entry screening

For each proposed order $m\ge2$, compute $g=-\cos(\pi/m)$ and verify $-1<g\le0$. This is an $O(k)$ numerical prefilter for $k$ entries. A complete realization pipeline must subsequently check symmetry, diagonal normalization, Lorentzian signature, incidence conditions, and finite or affine vertex links.

### 8.3. Decorated binary enumeration

Enumerate integers from $0$ to $2^n-1$ and interpret each as a binary word. Pair each word with both decoration bits. The resulting $2^{n+1}$ objects collapse to $2^n$ classes under word equality. Computing Hamming weight gives the model volume. Full enumeration requires $\Theta(n2^n)$ bit output and storage if all words are retained; aggregate counts can be computed in $O(n)$ time using binomial coefficients.

## 9. Applications and interpretation

### 9.1. Classification databases

A finite classification can be organized by progressively stronger filters. Coxeter orders determine candidate Gram entries. Entry ranges eliminate impossible local data. Signature and link tests address geometric realization. Commensurability invariants then cluster the surviving objects and certify lower bounds on distinct classes.

For the eight-facet five-dimensional setting, the reported population of $141$ finite-volume examples, including $125$ noncompact examples, provides a substantial finite test bed for cusp statistics and candidate local replacements. The abstract results explain how a finite inventory can seed an infinite construction, but they do not independently establish those enumeration figures.

### 9.2. Information per unit volume

A binary site contributes at most one bit of construction information. If the invariant preserves that bit and the volume cost per site is at most $A$, the exponential rate is at least $(\log2)/A$ per unit volume. For an alphabet with $q$ equally costly choices, the analogous rate is $(\log q)/A$.

When letters have unequal costs $c_1,\ldots,c_q$, the optimal asymptotic rate is expected to be a weighted entropy. One seeks word distributions maximizing information subject to an average-volume constraint. This reframes geometric abundance as a coding problem: cusp pieces are symbols, volume is cost, and the invariant is a decoder.

### 9.3. Beyond Coxeter polytopes

The invariant-counting principle applies to any finite family modulo any equivalence relation. Similar structures arise in manifold commensurability, arithmetic lattices, graph coverings, tiling spaces, and moduli problems. The domain-specific work always lies in identifying an invariant with a large image and constructing many bounded-cost objects.

## 10. Limitations

First, the decorated binary model is an abstract model of the counting mechanism, not a realization of binary words by hyperbolic Coxeter polytopes. Its “volume” is Hamming weight rather than hyperbolic volume.

Second, the Gram-entry theorem is a necessary local condition only. It does not establish the Lorentzian signature or the global realizability of a candidate matrix.

Third, the invariant-counting inequality gives a lower bound, not an exact classification, unless the invariant is known to distinguish every represented class.

Fourth, numerical values of trigonometric entries or cusp densities require exact or certified comparison when used for rigorous classification. Floating-point equality alone is not a reliable test.

Finally, classification counts and dimension-specific geometric constructions require their own incidence, signature, volume, and cusp arguments. The present framework clarifies how those arguments feed into a growth theorem but does not substitute for them.

## 11. Future directions

A first goal is to realize binary cusp-density separation uniformly in dimensions $4$, $5$, $6$, $7$, and $9$: construct $P_w$ with $\operatorname{vol}(P_w)\le A_dn+B_d$ and pairwise distinct maximal cusp densities.

A second direction is to determine the optimal exponential rate. For a finite alphabet of cusp modifications with additive costs and a decoder with only subexponential ambiguity, weighted combinatorial entropy should control the logarithmic class growth per unit volume.

A third direction is a finite realization certificate for fixed dimension and facet number. Such a certificate should combine a Coxeter Gram matrix of Lorentzian signature with explicit elliptic certificates for finite vertex links and parabolic certificates for ideal links. The local range $(-1,0]$ would then be one component of a complete checkable criterion.

A fourth direction is to compare growth functions across dimensions. If $N_d(V)$ counts classes represented below volume $V$, one may ask whether dimension-tagged constructions have independent rates, whether their exponents are comparable, and how cusp alphabets change with dimension.

## 12. Conclusion

The passage from geometric construction to exponential commensurability growth can be organized into a transparent chain. An invariant constant on commensurability classes factors through the quotient, so its number of values lower-bounds the number of classes. Coxeter geometry constrains local Gram entries by

$$
-1<-\cos(\pi/m)\le0.
$$

A nondegenerate decorated binary model demonstrates that $n$ independent structural choices can coexist with an equivalence relation strictly coarser than equality, a linear size bound, and exactly $2^n$ invariant values. Finally, any geometric family reproducing these two quantitative features—linear volume and exponential invariant image—inherits an exponential lower bound in volume.

The universal mathematics is therefore short, but its role is decisive: it identifies invariant separation as the bridge between the geometry of cusps and the combinatorics of exponential abundance.
