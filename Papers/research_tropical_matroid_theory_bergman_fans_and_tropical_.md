# Bergman Fans as Tropical Linear Spaces: Circuit Constraints, Cone Symmetries, and Component Lineality

**Aristotle**  
**August 1, 2026**

## Abstract

Let $M$ be a matroid on a ground set $E$, and let a weight be a function $w:E\to\mathbb R$. The Bergman fan $B(M)$ is the set of weights for which the minimum on every circuit of $M$ is attained by at least two distinct elements. We develop this definition from first principles and identify $B(M)$ with the tropical linear space cut out by the circuit ideal. We then establish its basic tropical cone symmetries: invariance under adding a constant to all coordinates and closure under multiplication by a nonnegative scalar. In particular, the same conclusion holds for nested matroids, defined by requiring their cyclic flats to form a chain. We characterize the Bergman lineality space—weights constant on every circuit—as exactly the functions constant on circuit components. Consequently, a circuit-connected matroid has only constant lineality on its ground set. Finally, we show that every common-translation orbit is convex and path connected, and that the orbit through any Bergman weight remains inside the Bergman fan. Algorithms for finite circuit presentations make each construction explicit. These results clarify how minimal dependence controls tropical equations, symmetry directions, and elementary topology.

## 1. Introduction

A matroid extracts the notion of dependence from linear algebra and graph theory. Its circuits are the minimally dependent subsets of a ground set. Tropical geometry, meanwhile, replaces ordinary addition by minimization and detects a tropical hypersurface at points where the minimum among its terms is attained more than once. When these two ideas are combined, each matroid circuit supplies one tropical equation, and the simultaneous solution set is the Bergman fan.

This paper gives a self-contained treatment of that correspondence and of several structural consequences. The central equality is conceptually simple but useful: the combinatorially defined Bergman fan is precisely the tropical linear space of the circuit ideal. The repeated-minimum formulation then makes two universal symmetries transparent. Common translation $w\mapsto w+c\mathbf 1$ preserves every comparison, while nonnegative dilation $w\mapsto aw$ preserves order and equality. Thus every Bergman fan is a tropical linear cone in the specific sense adopted below.

Circuit overlap also determines lineality. If a weight is constant on each circuit, then equality propagates through chains of intersecting circuit relations. This leads to a characterization in terms of circuit components, and circuit connectivity forces such a weight to be globally constant on the ground set. Finally, the common-translation orbit of any weight is an affine line. It is convex and path connected; when the initial weight is in the Bergman fan, the entire orbit remains there.

The scope of these statements should be kept precise. The tropical cone property used here consists of translation invariance and nonnegative dilation closure. It does not claim ordinary convexity of the full Bergman fan. Indeed, elementary examples show that a Bergman fan can be a union of cones rather than one convex cone. Likewise, the nested-matroid result established here is a specialization of the universal cone theorem; stronger assertions about projectivized convexity remain a subject for further investigation.

## 2. Matroidal and tropical preliminaries

### 2.1. Matroids, circuits, and flats

A **matroid** $M$ consists of a ground set $E$ together with a family of independent subsets satisfying the hereditary and exchange axioms. A subset is dependent if it is not independent. A **circuit** is a minimally dependent subset: it is dependent, but every proper subset is independent. We write $\mathcal C(M)$ for the family of circuits.

Two motivating examples are fundamental.

1. If $E$ indexes vectors over a field and independence means linear independence, then matroid circuits are the supports of minimal linear relations.
2. If $E$ is the edge set of a graph and independence means containing no cycle, then the circuits are the edge sets of simple cycles.

The **closure** $\operatorname{cl}_M(X)$ of a subset $X\subseteq E$ consists of elements whose addition to $X$ does not increase rank. A **flat** is a subset $F$ satisfying $\operatorname{cl}_M(F)=F$.

A subset $X\subseteq E$ is **cyclic** if every element of $X$ belongs to a circuit contained in $X$. A **cyclic flat** is a set that is both a flat and cyclic. The matroid is **nested** when any two cyclic flats are comparable by inclusion: for all cyclic flats $F$ and $G$,

$$
F\subseteq G\quad\text{or}\quad G\subseteq F.
$$

Thus the cyclic flats of a nested matroid form a chain.

### 2.2. Repeated minima

A **weight** on $E$ is a function $w:E\to\mathbb R$. Let $C\subseteq E$. We say that the minimum of $w$ on $C$ is **attained at least twice** if there exist distinct $e,f\in C$ such that

$$
w_e=w_f
\quad\text{and}\quad
w_e\leq w_x\quad\text{for all }x\in C.
$$

For finite nonempty $C$, this agrees with the usual statement that the set of minimizers

$$
\operatorname{argmin}_C(w)=\{e\in C:w_e=\min_{x\in C}w_x\}
$$

has cardinality at least two. The witness-based formulation remains meaningful without choosing a numerical minimum in advance.

The **Bergman fan** of $M$ is

$$
B(M)=\{w\in\mathbb R^E:
\text{the minimum of }w\text{ on every }C\in\mathcal C(M)
\text{ is attained at least twice}\}.
$$

The terminology “fan” reflects the polyhedral structure present for finite matroids. Our arguments use only the circuit condition.

### 2.3. Tropical circuit equations

In the min-plus convention, tropical addition is $a\oplus b=\min(a,b)$ and tropical multiplication is $a\odot b=a+b$. For a circuit $C$, consider the coefficient-free tropical linear polynomial

$$
p_C(w)=\bigoplus_{e\in C}w_e=\min_{e\in C}w_e.
$$

Its tropical zero set is the corner locus where the minimum is achieved by at least two terms. We represent the **circuit ideal** by its family of circuit supports $\mathcal C(M)$. More generally, for any family $\mathcal I$ of subsets of $E$, define its tropical zero set by

$$
V_{\mathrm{trop}}(\mathcal I)
=
\{w\in\mathbb R^E:
\text{the minimum of }w\text{ on every }C\in\mathcal I
\text{ is attained at least twice}\}.
$$

For $\mathcal I=\mathcal C(M)$, this is the tropical linear space of the circuit ideal.

## 3. The circuit ideal and the Bergman fan

### Theorem 3.1 (Bergman fan–tropical linear space equality)

For every matroid $M$,

$$
B(M)=V_{\mathrm{trop}}(\mathcal C(M)).
$$

In words, the Bergman fan is exactly the tropical linear space cut out by the circuit ideal.

**Proof sketch.** Let $w$ be a weight. By definition, $w\in B(M)$ precisely when every circuit $C\in\mathcal C(M)$ has at least two distinct minimizers. By the definition of $V_{\mathrm{trop}}(\mathcal C(M))$, membership on the right requires precisely the same repeated-minimum condition for every member of the circuit family. Thus each inclusion follows by applying the identical circuit test. $\square$

Although the proof is immediate from the definitions, the theorem identifies two viewpoints. On the matroidal side, circuits encode minimal dependence. On the tropical side, circuit polynomials impose corner-locus equations. Their solution sets coincide without any auxiliary choices.

### Example 3.2 (A tropical line)

Let $M$ be the rank-two uniform matroid on $E=\{1,2,3\}$. Its only circuit is $E$ itself, so

$$
B(M)=\{w\in\mathbb R^3:\min(w_1,w_2,w_3)
\text{ is attained at least twice}\}.
$$

This contains $(0,0,2)$, $(0,3,0)$, and $(4,1,1)$, but not $(0,1,2)$. Modulo common translation, it is the standard three-rayed tropical line.

The example also demonstrates failure of ordinary convexity. Both

$$
u=(0,0,2),\qquad v=(0,2,0)
$$

belong to $B(M)$, whereas

$$
\frac{u+v}{2}=(0,1,1)
$$

has a unique minimum and does not belong to $B(M)$.

## 4. Tropical cone symmetries

We first isolate the elementary order facts underlying the global result.

### Lemma 4.1 (Translation preserves repeated minima)

Let $C\subseteq E$, let $w:E\to\mathbb R$, and suppose the minimum of $w$ on $C$ is attained at least twice. For every $c\in\mathbb R$, the minimum of the translated weight $w+c\mathbf 1$ on $C$ is attained at least twice.

**Proof sketch.** Choose distinct minimizers $e,f\in C$. For every $x\in C$, the inequality $w_e\leq w_x$ implies $w_e+c\leq w_x+c$, and the equality $w_f=w_e$ implies $w_f+c=w_e+c$. Thus the same pair witnesses the repeated minimum after translation. $\square$

Applying the lemma with $-c$ gives the reverse implication as well.

### Lemma 4.2 (Nonnegative dilation preserves repeated minima)

Let $C\subseteq E$, let $w:E\to\mathbb R$, and suppose the minimum of $w$ on $C$ is attained at least twice. If $a\geq0$, then the minimum of $aw$ on $C$ is attained at least twice.

**Proof sketch.** If $e$ and $f$ are distinct minimizers, multiplication of each inequality $w_e\leq w_x$ by $a\geq0$ gives $aw_e\leq aw_x$, while $w_e=w_f$ gives $aw_e=aw_f$. The case $a=0$ is included: all coordinates then agree. $\square$

A subset $S\subseteq\mathbb R^E$ will be called a **tropical linear cone** if it satisfies both of the following conditions:

1. for every $w$ and $c\in\mathbb R$,
   $$
   w+c\mathbf 1\in S\quad\Longleftrightarrow\quad w\in S;
   $$
2. for every $w\in S$ and every $a\geq0$, one has $aw\in S$.

This definition records common-translation invariance and ordinary nonnegative homogeneity. It does not include ordinary addition closure.

### Theorem 4.3 (Universal tropical cone structure)

For every matroid $M$, the Bergman fan $B(M)$ is a tropical linear cone.

**Proof sketch.** Apply Lemma 4.1 independently to every circuit. This proves that $w\in B(M)$ implies $w+c\mathbf 1\in B(M)$. Applying the same statement to $w+c\mathbf 1$ with constant $-c$ proves the converse. Next apply Lemma 4.2 independently to every circuit to obtain closure under every scalar $a\geq0$. These are exactly the two defining conditions. $\square$

### Corollary 4.4 (Nested matroids)

If $M$ is nested, then $B(M)$ is a tropical linear cone.

**Proof sketch.** Theorem 4.3 holds for all matroids, so it applies in particular to matroids whose cyclic flats form a chain. $\square$

The nested hypothesis is therefore not needed for this specific conclusion. It identifies an important subclass while preserving the stronger universal statement. No assertion of ordinary convexity follows merely from this corollary.

## 5. Circuit components and lineality

Define two elements $e,f\in E$ to be **circuit-adjacent** if some circuit contains both. They are in the same **circuit component** if there exists a finite chain

$$
e=e_0,e_1,\ldots,e_k=f
$$

such that each consecutive pair $e_i,e_{i+1}$ is circuit-adjacent. The length-zero chain ensures reflexivity. Concatenation gives transitivity, and the symmetry of common membership in a circuit gives symmetry.

The matroid is **circuit-connected** when $E$ is nonempty and every pair of elements of $E$ lies in the same circuit component.

The **Bergman lineality space** is the set

$$
L(M)=\{v\in\mathbb R^E:
 v_e=v_f\text{ whenever }e,f\text{ belong to a common circuit}\}.
$$

Equivalently, $v$ is constant on each circuit. This condition captures directions that add the same increment to every coordinate participating in any one circuit.

### Theorem 5.1 (Component characterization of lineality)

A weight $v:E\to\mathbb R$ lies in $L(M)$ if and only if $v$ is constant on every circuit component. Explicitly,

$$
v\in L(M)
\quad\Longleftrightarrow\quad
\bigl(e\text{ and }f\text{ are in the same circuit component}
\Longrightarrow v_e=v_f\bigr).
$$

**Proof sketch.** Suppose first that $v\in L(M)$. If $e=e_0,\ldots,e_k=f$ is a chain of circuit adjacencies, then each adjacent pair belongs to a common circuit, so

$$
v_{e_0}=v_{e_1}=\cdots=v_{e_k}.
$$

Hence $v_e=v_f$. Conversely, suppose $v$ is constant on circuit components. If $e$ and $f$ belong to a common circuit, they are circuit-adjacent and therefore in the same component. It follows that $v_e=v_f$, which is precisely circuitwise constancy. $\square$

### Corollary 5.2 (Connected lineality is constant)

If $M$ is circuit-connected and $v\in L(M)$, then $v$ is constant on $E$.

**Proof sketch.** Every two ground elements lie in the same circuit component. Theorem 5.1 therefore equates their $v$-values. $\square$

### Proposition 5.3 (Constant weights are always lineality directions)

For every $c\in\mathbb R$, the constant weight $v_e=c$ belongs to $L(M)$.

**Proof sketch.** Any two coordinates of a constant function are equal, in particular any two coordinates in a common circuit. $\square$

Together, Corollary 5.2 and Proposition 5.3 show that for a circuit-connected matroid, the lineality weights on the ground set are exactly the constant weights. For multiple circuit components, Theorem 5.1 permits a separate constant on each component. In the finite case, this strongly suggests the familiar component-count description of lineality dimension; a precise dimension theorem requires a chosen finite-dimensional realization and is reserved for future work.

## 6. Translation orbits and topology

For a weight $w:E\to\mathbb R$, define its **translation orbit** by

$$
\mathcal O(w)=\{w+c\mathbf 1:c\in\mathbb R\}.
$$

It is an affine copy of the real line unless the ambient ground set is empty, in which case all such functions coincide.

### Theorem 6.1 (Convexity of translation orbits)

For every weight $w$, the set $\mathcal O(w)$ is convex in the real vector space $\mathbb R^E$.

**Proof sketch.** Take $w+c_1\mathbf 1$ and $w+c_2\mathbf 1$ in the orbit and coefficients $a,b\geq0$ with $a+b=1$. Then

$$
\begin{aligned}
a(w+c_1\mathbf 1)+b(w+c_2\mathbf 1)
&=(a+b)w+(ac_1+bc_2)\mathbf 1\\
&=w+(ac_1+bc_2)\mathbf 1,
\end{aligned}
$$

which is again in $\mathcal O(w)$. $\square$

### Corollary 6.2 (Path connectedness of translation orbits)

For every weight $w$, the orbit $\mathcal O(w)$ is path connected.

**Proof sketch.** Convex subsets of real topological vector spaces are path connected when nonempty, and $w=w+0\mathbf 1$ lies in the orbit. More explicitly, points $w+c_1\mathbf 1$ and $w+c_2\mathbf 1$ are joined by

$$
\gamma(t)=w+((1-t)c_1+tc_2)\mathbf 1,
\qquad t\in[0,1].
$$

$\square$

### Theorem 6.3 (Bergman translation orbits stay in the fan)

If $w\in B(M)$, then

$$
\mathcal O(w)\subseteq B(M).
$$

Consequently, every Bergman weight lies on a convex, path-connected translation orbit contained in the Bergman fan.

**Proof sketch.** Every point of $\mathcal O(w)$ has the form $w+c\mathbf 1$. By Lemma 4.1, adding $c$ preserves the repeated minimum on every circuit. Hence all such points remain in $B(M)$. Convexity and path connectedness follow from Theorem 6.1 and Corollary 6.2. $\square$

This theorem does not assert that the whole Bergman fan is path connected. It isolates a canonical connected subset through each point. Quotienting by common translations collapses these orbits and produces the tropical projectivization of the fan.

## 7. Finite algorithms and numerical demonstrations

Suppose $E=\{0,\ldots,n-1\}$ and the circuits are listed explicitly as $C_1,\ldots,C_m$. Exact rational or integer arithmetic is preferable when inputs are exact, because the defining condition involves equality of minima.

### Algorithm 7.1 (Bergman membership test)

For each circuit $C_j$, compute

$$
\mu_j=\min_{e\in C_j}w_e
$$

and count the elements $e\in C_j$ with $w_e=\mu_j$. Accept $w$ if and only if every count is at least two.

If the total circuit-incidence size is

$$
L=\sum_{j=1}^m |C_j|,
$$

then the running time is $O(L)$ and the auxiliary space is $O(1)$ beyond the input, assuming each circuit can be scanned twice or the minimum and its multiplicity are maintained in one pass. The theorem of Section 3 says that this single procedure simultaneously decides Bergman-fan membership and membership in the tropical linear space of the circuit ideal.

### Algorithm 7.2 (Circuit components and lineality test)

Construct an undirected graph on $E$ by joining elements that occur together in a circuit. It is unnecessary to add every pair from a circuit: choosing one representative $r\in C$ and joining $r$ to every other element of $C$ creates the same connected components. A disjoint-set union data structure therefore processes circuit $C$ using $|C|-1$ union operations.

After all circuits are processed, two elements are in the same circuit component exactly when they have the same disjoint-set representative. A weight $v$ lies in $L(M)$ exactly when it is constant within each resulting class. The number of union operations is $O(L)$, giving time $O((n+L)\alpha(n))$, where $\alpha$ is the inverse Ackermann function, and space $O(n)$.

### Example 7.3 (A connected circuit presentation)

Let

$$
E=\{0,1,2,3\},\qquad
\mathcal C=\bigl\{\{0,1,2\},\{1,2,3\}\bigr\}.
$$

The two circuits overlap, so all four elements lie in one circuit component. The weight

$$
w=(0,0,2,0)
$$

passes both circuit tests: the first circuit has minima at $0$ and $1$, while the second has minima at $1$ and $3$. Every translate $w+c\mathbf 1$ also passes. In contrast, a lineality weight must be constant: constancy on the first circuit gives $v_0=v_1=v_2$, and constancy on the second gives $v_1=v_2=v_3$.

### Numerical caution

For floating-point data, exact equality should usually be replaced by a declared tolerance $\varepsilon>0$, counting values with $|w_e-\mu_j|\leq\varepsilon$. This computes an approximate repeated-minimum test, not the exact mathematical predicate. The distinction is important near fan boundaries.

## 8. Applications and interpretation

### 8.1. Graph cycles

For a graphic matroid, circuits are simple cycles. A weighting belongs to the Bergman fan exactly when no cycle has a unique minimum-weight edge. Thus the global tropical condition can be read as a cycle-by-cycle degeneracy rule. Circuit components identify edge blocks linked through cycles, while bridge edges, which lie in no circuit, require separate attention in the component convention.

### 8.2. Vector configurations

For a represented matroid, each circuit is the support of a minimal linear dependence among columns. The tropical circuit equation records where at least two coordinates tie for the least value on that support. Theorem 3.1 therefore converts the complete collection of minimal linear dependencies into a tropical linear space.

### 8.3. Projective normalization

Translation invariance permits normalization. For finite nonempty $E$, one may subtract $\min_{e\in E}w_e$ so that the smallest coordinate becomes zero, or fix a chosen coordinate to zero. These operations select representatives of common-translation classes without changing Bergman membership. Theorem 6.3 explains geometrically why this quotient is natural: each class is a path-connected affine orbit lying entirely inside the fan.

### 8.4. Connectivity as symmetry count

Theorem 5.1 shows that circuit connectivity controls independent lineality constants. A connected circuit system permits only one constant across its ground set. Several components permit distinct constants because no circuit compares coordinates in different components. This is the first step toward a dimension formula relating lineality to the number of components.

## 9. Discussion and limitations

The repeated-minimum predicate is remarkably efficient: it gives the tropical equations, proves translation invariance, proves nonnegative homogeneity, and supports a direct membership algorithm. Yet several distinctions must be maintained.

First, common-coordinate translation is not the same as arbitrary translation. Adding a nonconstant vector may change which element is uniquely minimal on a circuit. Second, negative dilation reverses inequalities and generally converts minima into maxima, so the closure theorem correctly assumes $a\geq0$. Third, the entire fan need not be ordinarily convex, even though each translation orbit is convex. Fourth, nestedness has been defined and its cone corollary established, but the universal cone theorem means nestedness is not used to obtain that particular symmetry.

The topology developed here is local to translation orbits rather than a complete analysis of the projectivized fan. Every point lies on a canonical path-connected subset, but paths between distinct orbits require additional combinatorial and polyhedral arguments.

## 10. Future directions

Five natural problems emerge.

1. **Component-count lineality.** For a finite loopless matroid, determine whether the dimension of $L(M)$ restricted to the ground set equals the number of circuit components.
2. **Connected projectivized fans.** For a finite circuit-connected matroid of positive rank, determine whether $B(M)$ modulo common translations is path connected.
3. **Nested fan convexity.** Determine whether a finite nested matroid has an ordinarily convex polyhedral Bergman fan after quotienting by common translations. The nonconvex three-element example shows why nestedness must do genuine work if this is true.
4. **Circuit-elimination generating families.** Find conditions under which imposing the repeated-minimum test on a circuit-generating subfamily suffices to impose it on every circuit.
5. **Direct sums.** Establish a natural product description for Bergman fans of direct sums, compatible with circuit components and lineality.

## 11. Conclusion

For a matroid $M$, the Bergman fan and the tropical linear space of its circuit ideal are the same set because both enforce one rule: every circuit minimum must be attained at least twice. That rule survives common translation and nonnegative dilation, making every Bergman fan a tropical linear cone. Circuitwise-constant weights are exactly componentwise-constant weights, so circuit connectivity reduces lineality on the ground set to constants. Finally, every common-translation orbit is a convex path and, through a Bergman weight, remains entirely inside the fan.

These statements provide a compact structural passage from dependence to geometry. Circuits supply the equations, their overlap supplies components, and the invariance of tied minima supplies both symmetry and topology.
