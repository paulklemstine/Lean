# Order Correspondences, Universal Pullbacks, and Finite Matroid Obstructions

## Abstract

We develop an order-theoretic calculus for many-valued correspondences between preordered structures. An order correspondence is a relation whose witnesses extend upward along the source order. Its universal inverse image sends a target class to the source objects all of whose related targets lie in that class. We prove that universal pullback preserves lower classes, respects identity and relational composition, and commutes with arbitrary intersections. Correspondences compose associatively at the relational level, so these operations define a contravariant calculus on lower classes. Specializing to matroids ordered by the minor relation, we show that the pullback of every minor-closed class is minor-closed. The correspondence relating a matroid to all of its minors fixes every minor-closed class. Excluded minors of any correspondence pullback form an antichain; if the source minor order is well-quasi-ordered, the pullback of a minor-closed class has finitely many excluded minors and membership is equivalent to avoidance of this finite obstruction set. We give finite algorithms, worked examples, applications, and a precise account of the additional structure needed for representability, algebraicity, polymatroid lifts, and Lorentzian supports.

## 1. Introduction

Many constructions in combinatorics are naturally relational rather than functional. A matroid has many deletions, contractions, and minors; a geometric object may admit many projections; an operator may send one support to several compatible supports. Selecting a single output suppresses essential structure. The relevant categorical behavior must therefore be extracted directly from a relation.

The key condition considered here is an upward extension property. If a source object is enlarged in its preorder, every target witness over the smaller source can be enlarged to a target witness over the larger source. This condition is weak enough to include genuinely many-valued constructions, but strong enough to transport downward-hereditary properties.

The correct operation on classes is the universal pullback. For a relation $R$ from $A$ to $B$ and a class $C\subseteq B$, it consists of those $a\in A$ for which every $R$-related target belongs to $C$. Universal rather than existential quantification is forced by lower-set variance. The extension property lifts a witness from a smaller source to a larger one, after which downward closure returns the conclusion to the original target.

Our contributions are as follows.

1. We define order correspondences and prove that identity and relational composition remain within this class.
2. We prove that universal pullback preserves lower classes, is contravariantly functorial, and preserves arbitrary intersections.
3. We show relational associativity, giving a coherent calculus independent of parenthesization.
4. For matroids under the minor order, we prove preservation of minor-closed classes and characterize the all-minors correspondence.
5. We prove that excluded minors of any correspondence pullback form an antichain.
6. Under well-quasi-ordering of the source minor order, we prove finiteness and completeness of the excluded-minor basis.
7. We present finite algorithms that check the extension law, compute universal pullbacks, and extract minimal obstructions.

These results isolate the order-theoretic core. No claim is made here that representability, algebraicity, multisymmetric lifting, or Lorentzian positivity follows from order alone. Section 8 explains how such additional theories may attach to the present calculus.

## 2. Preorders, lower classes, and correspondences

### 2.1 Preorders and lower classes

A **preorder** on a set $A$ is a binary relation $\leq_A$ that is reflexive and transitive. Antisymmetry is not required. This is useful when different presentations represent equivalent structures.

A subset $L\subseteq A$ is a **lower class** if

$$
x\leq_A y\ \text{and}\ y\in L\quad\Longrightarrow\quad x\in L.
$$

Thus membership survives movement downward. Lower classes are closed under arbitrary intersections.

### 2.2 Order correspondences

**Definition 2.1 (Order correspondence).** Let $(A,\leq_A)$ and $(B,\leq_B)$ be preordered sets. An order correspondence $R:A\rightsquigarrow B$ is a relation $R\subseteq A\times B$ satisfying the extension law

$$
a_0\leq_A a_1\ \text{and}\ R(a_0,b_0)
\quad\Longrightarrow\quad
\exists b_1\in B\text{ such that }b_0\leq_B b_1\text{ and }R(a_1,b_1).
$$

The law is one-sided. It does not require every source to have a target, every target to have a source, uniqueness, or a downward lifting property.

**Definition 2.2 (Identity correspondence).** The identity correspondence on $A$ is

$$
I_A(a,a')\quad\Longleftrightarrow\quad a=a'.
$$

It satisfies the extension law: if $a_0\leq_A a_1$ and $a_0=a_0'$, choose $a_1'=a_1$.

**Definition 2.3 (Relational composition).** Given order correspondences $R:A\rightsquigarrow B$ and $S:B\rightsquigarrow D$, define

$$
(S\circ R)(a,d)
\quad\Longleftrightarrow\quad
\exists b\in B\,[R(a,b)\wedge S(b,d)].
$$

### 2.3 Universal pullback

**Definition 2.4 (Universal pullback).** For a correspondence $R:A\rightsquigarrow B$ and a class $C\subseteq B$, define

$$
R^*C=\{a\in A: \forall b\in B,\ R(a,b)\Rightarrow b\in C\}.
$$

Objects with empty relation fibres belong to every universal pullback. This is ordinary vacuous truth and may be excluded in applications by separately requiring nonempty fibres. None of the structural theorems needs that requirement.

The existential alternative,

$$
\{a\in A:\exists b,\ R(a,b)\wedge b\in C\},
$$

need not preserve lower classes under the extension law. The extension condition moves witnesses upward, whereas an existential witness over a larger source need not descend. Universal pullback has the correct variance.

## 3. The relational calculus

### 3.1 Closure under composition

**Theorem 3.1 (Composition theorem).** The relational composite of two order correspondences is an order correspondence.

**Proof sketch.** Suppose $a_0\leq_A a_1$ and $(S\circ R)(a_0,d_0)$. Choose $b_0$ with $R(a_0,b_0)$ and $S(b_0,d_0)$. Extend $b_0$ along $a_0\leq_A a_1$ to obtain $b_1\geq_B b_0$ with $R(a_1,b_1)$. Then extend $d_0$ along $b_0\leq_B b_1$ to obtain $d_1\geq_D d_0$ with $S(b_1,d_1)$. The witness $b_1$ proves $(S\circ R)(a_1,d_1)$, as required. $\square$

### 3.2 Associativity

**Theorem 3.2 (Associativity of correspondences).** For order correspondences $R:A\rightsquigarrow B$, $S:B\rightsquigarrow D$, and $T:D\rightsquigarrow E$,

$$
T\circ(S\circ R)=(T\circ S)\circ R
$$

as relations from $A$ to $E$.

**Proof sketch.** Either side holds at $(a,e)$ exactly when there exist $b\in B$ and $d\in D$ such that $R(a,b)$, $S(b,d)$, and $T(d,e)$. The two parenthesizations merely package the same pair of existential witnesses differently. $\square$

Together with identity correspondences, this gives the usual identity and associativity laws at the relational level.

### 3.3 Preservation of lower classes

**Theorem 3.3 (Lower-Class Pullback Theorem).** If $C\subseteq B$ is a lower class and $R:A\rightsquigarrow B$ is an order correspondence, then $R^*C$ is a lower class in $A$.

**Proof.** Let $a_0\leq_A a_1$ and assume $a_1\in R^*C$. To prove $a_0\in R^*C$, choose any $b_0$ satisfying $R(a_0,b_0)$. By the extension law, there is $b_1\geq_B b_0$ satisfying $R(a_1,b_1)$. Since $a_1\in R^*C$, one has $b_1\in C$. Since $C$ is lower and $b_0\leq_B b_1$, one has $b_0\in C$. This holds for every $b_0$ related to $a_0$, so $a_0\in R^*C$. $\square$

### 3.4 Contravariant functoriality

**Theorem 3.4 (Composite pullback).** For correspondences $R:A\rightsquigarrow B$ and $S:B\rightsquigarrow D$, and every class $C\subseteq D$,

$$
(S\circ R)^*C=R^*(S^*C).
$$

**Proof.** An element $a$ belongs to the left side exactly when every $d$ for which there exists $b$ with $R(a,b)$ and $S(b,d)$ lies in $C$. This is equivalent to saying that for every $b$ with $R(a,b)$, every $d$ with $S(b,d)$ lies in $C$. The latter says precisely that every such $b$ belongs to $S^*C$, or $a\in R^*(S^*C)$. $\square$

**Theorem 3.5 (Identity pullback).** For every class $C\subseteq A$,

$$
I_A^*C=C.
$$

**Proof sketch.** The only identity-related target of $a$ is $a$ itself. Thus the universal condition reduces to $a\in C$. $\square$

Theorems 3.4 and 3.5 show that universal pullback reverses the direction of correspondence composition. In categorical language, lower classes and universal pullback form a contravariant action of the relational calculus.

### 3.5 Arbitrary intersections

**Theorem 3.6 (Arbitrary-Intersection Theorem).** For any indexed family $\{C_i\}_{i\in I}$ of subsets of $B$,

$$
R^*\left(\bigcap_{i\in I}C_i\right)
=
\bigcap_{i\in I}R^*C_i.
$$

**Proof.** An element $a$ lies on the left exactly when every related $b$ belongs to every $C_i$. This is equivalent to: for every index $i$, every related $b$ belongs to $C_i$. That is exactly membership in the right side. $\square$

No lower-set hypothesis is needed. This is a purely logical consequence of universal quantification.

## 4. Matroid correspondences

### 4.1 Matroids and minors

A **matroid** $M$ on a ground set $E$ consists of a nonempty family $\mathcal I\subseteq 2^E$ of independent sets satisfying:

1. $\varnothing\in\mathcal I$;
2. if $J\in\mathcal I$ and $I\subseteq J$, then $I\in\mathcal I$;
3. if $I,J\in\mathcal I$ and $|I|<|J|$, then some $e\in J\setminus I$ satisfies $I\cup\{e\}\in\mathcal I$.

Deletion removes elements while retaining independence among the remaining elements. Contraction removes elements after treating them as already used. A matroid $N$ is a **minor** of $M$, written $N\leq_m M$, if $N$ is obtainable from $M$ by a sequence of deletions and contractions, up to the customary identification of presentations. The minor relation is reflexive and transitive, hence a preorder.

A class $C$ of matroids is **minor-closed** if

$$
M\in C\ \text{and}\ N\leq_m M\quad\Longrightarrow\quad N\in C.
$$

Thus minor-closed classes are exactly lower classes for the minor preorder.

**Definition 4.1 (Matroid correspondence).** A matroid correspondence from a source collection to a target collection is an order correspondence between their minor preorders. Explicitly, it is a relation $R(M,N)$ such that whenever $M_0\leq_m M_1$ and $R(M_0,N_0)$, there exists $N_1$ with $N_0\leq_m N_1$ and $R(M_1,N_1)$.

### 4.2 Pullback of minor-closed classes

**Corollary 4.2 (Minor-Closure Transfer).** Let $R$ be a matroid correspondence and $C$ a minor-closed target class. Then

$$
R^*C=\{M:\forall N,\ R(M,N)\Rightarrow N\in C\}
$$

is a minor-closed source class.

**Proof sketch.** Apply the Lower-Class Pullback Theorem to the source and target minor preorders. $\square$

This statement is the central bridge from abstract order theory to matroid structure. Any construction satisfying the witness-extension law automatically transports every minor-closed target property.

### 4.3 The all-minors correspondence

**Definition 4.3 (Minor correspondence).** On a fixed matroid universe, define $Q(M,N)$ by

$$
Q(M,N)\quad\Longleftrightarrow\quad N\leq_m M.
$$

This is a matroid correspondence. If $M_0\leq_m M_1$ and $N_0\leq_m M_0$, transitivity gives $N_0\leq_m M_1$. Choose $N_1=M_1$. Then $N_0\leq_m N_1$ and, by reflexivity, $N_1\leq_m M_1$.

**Theorem 4.4 (Fixed-Point Theorem for Minor-Closed Classes).** If $C$ is minor-closed, then

$$
Q^*C=C.
$$

Equivalently, a matroid belongs to $C$ if and only if all of its minors belong to $C$.

**Proof.** If $M\in Q^*C$, then $M\in C$ because $M\leq_m M$. Conversely, if $M\in C$ and $N\leq_m M$, minor-closure gives $N\in C$, so $M\in Q^*C$. $\square$

The universal all-minors test is therefore an idempotent description of hereditary membership, not a stronger condition.

## 5. Excluded minors and finite obstruction bases

### 5.1 Minimal failures

**Definition 5.1 (Proper minor).** A matroid $N$ is a proper minor of $M$ if $N\leq_m M$ but $M$ is not equivalent to $N$ in the minor preorder.

**Definition 5.2 (Excluded minor).** Given a class $D$ of matroids, an excluded minor for $D$ is a matroid $E$ such that

1. $E\notin D$; and
2. every proper minor of $E$ belongs to $D$.

Thus excluded minors are precisely the minimal elements of the complement of $D$, modulo preorder equivalence.

**Theorem 5.3 (Excluded-Minor Antichain Theorem).** For every matroid correspondence $R$ and every target class $C$, the excluded minors of $R^*C$ are pairwise incomparable under $\leq_m$.

**Proof sketch.** The conclusion is a general fact about minimal elements of a complement. Suppose distinct excluded minors $E_1$ and $E_2$ satisfy $E_1\leq_m E_2$. After quotienting by preorder equivalence, $E_1$ is a proper minor of $E_2$. Minimality of $E_2$ then gives $E_1\in R^*C$, contradicting that $E_1$ is excluded. Hence no two distinct excluded minors are comparable. $\square$

Importantly, this theorem does not require $C$ to be minor-closed and does not require well-quasi-ordering.

### 5.2 Well-quasi-orders

**Definition 5.4 (Well-quasi-order).** A preorder $(A,\leq)$ is well-quasi-ordered if every infinite sequence $a_0,a_1,a_2,\dots$ contains indices $i<j$ such that $a_i\leq a_j$.

A well-quasi-order has no infinite antichain. Consequently, every antichain is finite. It also guarantees that every element of an upward-closed set lies above a minimal element of that set. For a lower class $D$, its complement is upward-closed; its minimal elements are the excluded obstructions.

### 5.3 Finite basis theorem

**Theorem 5.5 (Finite Excluded-Minor Pullback Theorem).** Let $R$ be a matroid correspondence from a source minor preorder to a target minor preorder. Let $C$ be a minor-closed target class. Assume the source minor preorder is well-quasi-ordered. Then:

1. the set $\mathcal E$ of excluded minors of $R^*C$ is finite; and
2. for every source matroid $M$,

$$
M\in R^*C
\quad\Longleftrightarrow\quad
\forall E\in\mathcal E,\ E\not\leq_m M.
$$

**Proof sketch.** By Corollary 4.2, $D=R^*C$ is minor-closed, so its complement $U$ is upward-closed. The minimal elements of $U$ are exactly the excluded minors of $D$. By Theorem 5.3 they form an antichain, and the well-quasi-order hypothesis makes every antichain finite. Hence $\mathcal E$ is finite.

If $M\in D$, no excluded minor $E\notin D$ can satisfy $E\leq_m M$, because minor-closure would imply $E\in D$. Conversely, if $M\notin D$, then $M\in U$. Well-quasi-ordering ensures that $M$ lies above a minimal element $E$ of $U$. Such $E$ is an excluded minor and $E\leq_m M$. Therefore avoidance of all excluded minors is equivalent to membership in $D$. $\square$

The theorem converts a universal relational property into finite forbidden-pattern recognition whenever the ambient source order is well-quasi-ordered.

## 6. Finite algorithms

The abstract definitions become elementary algorithms when the source set, target set, orders, and relation are finite and explicitly represented.

### 6.1 Checking the extension law

**Algorithm 6.1 (Extension-law certification).** For every ordered source pair $a_0\leq_A a_1$ and every $b_0$ with $R(a_0,b_0)$, search for $b_1$ satisfying $b_0\leq_B b_1$ and $R(a_1,b_1)$. Reject on the first failure; otherwise accept.

If $n=|A|$, $m=|B|$, and order and relation queries cost constant time, direct enumeration costs $O(n^2m^2)$. Precomputed upward sets and relation fibres can reduce practical cost.

### 6.2 Computing universal pullback

**Algorithm 6.2 (Universal fibre filter).** For each $a\in A$, inspect the fibre

$$
R(a)=\{b\in B:R(a,b)\}.
$$

Include $a$ exactly when $R(a)\subseteq C$. With Boolean membership and adjacency lists, the time is $O(n+r)$, where $r$ is the number of relation edges; storage is $O(n+m+r)$.

### 6.3 Extracting finite obstructions

**Algorithm 6.3 (Minimal-complement extraction).** Given a finite source preorder and a class $D$, inspect every $x\notin D$. Retain $x$ when there is no inequivalent $y\notin D$ with $y<x$. The retained elements are the minimal failures. If $D$ is lower, membership is equivalent to avoiding these retained elements below the candidate.

A direct comparison of all pairs costs $O(n^2)$. If strict-lower adjacency is already available, the scan may be faster. In a finite preorder, equivalent elements should first be quotient-identified or canonical representatives chosen.

## 7. Worked numerical examples

### 7.1 A divisibility correspondence

Let

$$
A=\{1,2,3,6\},\qquad B=\{1,2,4,8\},
$$

both ordered by divisibility. Define $R(a,b)$ when $b$ divides $2^a$. The fibres are

$$
R(1)=\{1,2\},\quad
R(2)=\{1,2,4\},\quad
R(3)=\{1,2,4,8\},\quad
R(6)=\{1,2,4,8\}.
$$

If $a_0\mid a_1$ and $b_0\mid 2^{a_0}$, then $b_0\mid 2^{a_1}$, so one may choose $b_1=b_0$. Hence $R$ satisfies the extension law.

Take the lower target class $C=\{1,2,4\}$. Then

$$
R^*C=\{1,2\},
$$

because the fibres of $3$ and $6$ contain $8$. The set $\{1,2\}$ is lower under divisibility. Its complement is $\{3,6\}$, whose unique minimal element is $3$. Inside this finite universe,

$$
a\in R^*C\quad\Longleftrightarrow\quad 3\nmid a.
$$

This is the finite obstruction phenomenon in miniature.

### 7.2 Composition

Let $D=\{0,1,2,3\}$ with the usual order, and define $S(b,d)$ when $d\leq \log_2 b$ for powers of two $b$. The relation is monotone in the required extension sense: enlarging $b$ permits at least as large a $d$. For $K=\{0,1,2\}$, one can either compute $S^*K$ first and then $R^*(S^*K)$, or compose $R$ and $S$ and pull back $K$ once. Theorem 3.4 guarantees identical results.

### 7.3 Intersections of requirements

Let $C_1=\{1,2,4\}$ and $C_2=\{1,2,8\}$ in $B$. Their intersection is $\{1,2\}$. Testing every fibre against $C_1\cap C_2$ produces the same source set as intersecting the two independently computed pullbacks. This illustrates Theorem 3.6 and supports modular constraint design.

## 8. Applications and scope

### 8.1 Hereditary property transport

Whenever a construction between ordered structures is many-valued but satisfies the extension law, every downward-hereditary target property pulls back to a downward-hereditary source property. This applies beyond matroids: finite graphs under minors or embeddings, words under subsequence, finite configurations under simplification, and state spaces under refinement can all support analogous correspondences when their witness-lifting behavior is verified.

### 8.2 Constraint aggregation

The arbitrary-intersection theorem permits large specifications to be assembled from independent clauses. If $C_i$ encodes the $i$th target requirement, then a source satisfies all transported requirements exactly when it lies in every $R^*C_i$. This supports incremental analysis: adding a new clause requires one more pullback and one intersection, without changing previous calculations.

### 8.3 Finite certificates

Under well-quasi-ordering, a minor-closed pullback class has a finite negative certificate system. Nonmembership is witnessed by the occurrence of one excluded minor, while membership means avoiding a finite list. The theorem is existential unless the source order and relation are effectively presented, but in finite truncations Algorithm 6.3 computes the list directly.

### 8.4 What order theory does not establish

The present hypotheses do not imply preservation of representability over a field. A proof of such preservation would require the relation witnesses to carry compatible vector configurations. Similarly, preservation of algebraic matroids requires control of transcendence dependencies; compatibility with multisymmetric polymatroid lifts requires a clone-level exchange construction; and connections with Lorentzian symbols require the support relation of the operator to satisfy the extension law, plausibly through an exchange property.

The value of the abstraction is separation of concerns. Once specialized data prove the extension axiom, all results in Sections 3–5 follow without repetition. Conversely, failure of the extension axiom pinpoints the exact obstruction to the order-theoretic calculus.

## 9. Discussion

The extension law can be interpreted as a simulation condition. A target witness over a smaller source can follow every source enlargement by moving upward itself. Universal pullback then expresses a robust property: all behaviors compatible with a source satisfy the target specification. The Lower-Class Pullback Theorem says robustness is hereditary under source simplification.

The construction is contravariant because testing through two stages reverses their order on classes. First require all second-stage outcomes to lie in $C$; this defines a class of acceptable intermediate objects. Then require all first-stage outcomes to lie in that intermediate class. This is exactly the same as universally testing all composite outcomes.

Arbitrary intersection preservation identifies universal pullback as a meet-preserving map between complete lattices of classes. Restricted to lower classes, it remains meet-preserving by Theorem 3.3. This lattice viewpoint may be useful for closure systems, logical specifications, and fixed-point constructions.

The excluded-minor results separate into two logically distinct layers. Minimal failures always form an antichain. Well-quasi-ordering supplies finiteness and ensures that every failure lies above a minimal one. This distinction matters: in a non-well-quasi-ordered universe, excluded minors remain incomparable but may be infinite or may fail to provide a finite decision criterion.

## 10. Future research

Several extensions are naturally suggested.

First, for correspondences induced by linear relations between finite-dimensional vector configurations, one may seek a witness-level theorem showing that restriction, projection, and freely placed extensions preserve representability over a fixed field.

Second, for algebraic matroids, dominant rational correspondences with geometrically integral generic fibres may provide the geometric mechanism needed to extend quotient witnesses without introducing unintended dependencies.

Third, integral polymatroid correspondences may be compared with multisymmetric lifts. Cloning converts integer rank increments into ordinary exchange steps, suggesting that witnesses could lift clone by clone and commute with universal pullback up to canonical relabelling.

Fourth, supports of multihomogeneous linear operators with Lorentzian symbols may define order correspondences. The relevant question is whether the exchange structure of the support supplies the upward witness extension law.

Finally, global well-quasi-ordering may be stronger than necessary. If a correspondence has finite fibres and a finite lifting property for strict minors, it may be possible to transport finite obstruction bases directly from target to source without assuming the entire source minor order is well-quasi-ordered.

## 11. Conclusion

An order correspondence is a relation with a single mobility principle: target witnesses extend upward whenever their source does. That principle yields a complete elementary calculus. Correspondences compose and associate; identity acts neutrally; universal pullback is contravariantly functorial; lower classes remain lower; and arbitrary intersections are preserved.

For matroids, these facts transport minor-closed classes. The all-minors correspondence fixes every such class. Minimal failures of any pullback are incomparable, and under well-quasi-ordering the pullback of a minor-closed class is characterized by finitely many excluded minors. The resulting framework provides a reusable bridge between many-valued structural constructions and finite obstruction theory, while clearly identifying the additional witness data required for richer algebraic and analytic applications.
