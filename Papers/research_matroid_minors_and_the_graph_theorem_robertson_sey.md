# Canonical Forbidden-Minor Bases from Well-Quasi-Ordering

**Aristotle**  
**July 19, 2026**

## Abstract

Forbidden-minor characterizations convert a hereditary structural property into a finite list of obstructions. This paper isolates the order-theoretic mechanism behind such characterizations and applies it to the matroid minor relation. For an arbitrary partially ordered set, we define the minimal members of a subset and prove that they form an antichain. Under a well-quasi-order hypothesis, this antichain is finite, and well-founded descent ensures that every member of the subset lies above a minimal member. Consequently, every lower set has a finite canonical forbidden basis: the minimal elements of its complement. Specializing to matroids, if a family of matroids is well-quasi-ordered by minors, then every minor-closed subclass has finitely many excluded minors, and membership is equivalent to avoiding them. We also prove an unconditional closure theorem: if two matroid classes have finite excluded-minor sets, then their intersection does as well, and every excluded minor of the intersection belongs to at least one constituent obstruction set. Algorithms for extracting minimal obstructions in finite data and testing membership from a known basis are presented, together with examples and limitations. The results establish the exact finite-basis consequence that any future well-quasi-order theorem for finite-field-representable matroids would entail; they do not establish that conjectural premise.

## 1. Introduction

Minor relations organize combinatorial objects by simplification. In graph theory, deletion removes an edge and contraction identifies its endpoints. Matroid theory abstracts these operations while retaining the dependence structure that makes deletion and contraction useful. The resulting order asks whether one object can be obtained from another through a sequence of simplifications.

A class is minor-closed when simplification never takes a member outside the class. Such a class may sometimes be recognized by a list of forbidden minors. The ideal situation is a finite list $B$ satisfying

$$
M\in C \quad\Longleftrightarrow\quad
\text{no }N\in B\text{ is a minor of }M.
$$

This changes the nature of classification. Instead of describing every possible member of $C$, one describes the smallest failures of membership. The graph minor theorem provides the archetypal setting: finite graphs are well-quasi-ordered by minors, and therefore every minor-closed graph class has a finite obstruction set.

The purpose of this paper is to separate the general logical mechanism from the difficult structural premise. The mechanism applies to every partially ordered set. It consists of three observations:

1. minimal members of a subset are pairwise incomparable;
2. a well-quasi-order has no infinite antichain, so the set of minimal members is finite;
3. well-founded descent guarantees that every element of a subset lies above a minimal member.

Applied to the complement of a lower set, these observations produce a finite canonical forbidden basis. Applied to matroids ordered by minors, they yield the conditional excluded-minor theorem.

The motivating prospect is a broad well-quasi-order theorem for matroids representable over a fixed finite field. The present results deliberately do not assert that premise. They establish its consequence and identify the canonical obstruction family that would result. This distinction is essential: general matroids need not be well-quasi-ordered by minors, and a theorem for graphic matroids is not automatically a theorem for all binary-representable matroids.

A second contribution is independent of any global well-quasi-order assumption. The canonical obstructions to the intersection of two lower classes lie in the union of the two constituent canonical obstruction sets. Thus finite excluded-minor descriptions are closed under binary intersection. This provides a modular way to combine previously understood properties.

## 2. Order-theoretic preliminaries

### 2.1 Partial orders, strict order, and lower sets

Let $X$ be a set equipped with a partial order $\preccurlyeq$. Thus $\preccurlyeq$ is reflexive, transitive, and antisymmetric. Write $y\prec x$ when $y\preccurlyeq x$ and $y\ne x$.

A subset $C\subseteq X$ is a **lower set** if

$$
x\in C\ \text{and}\ y\preccurlyeq x
\quad\Longrightarrow\quad y\in C.
$$

The complement $X\setminus C$ is then an upper set: if $x\notin C$ and $x\preccurlyeq z$, then $z\notin C$. Indeed, if $z$ belonged to $C$, lower closure would imply $x\in C$.

A subset $A\subseteq X$ is an **antichain** if no two distinct elements of $A$ are comparable. Equivalently, whenever $x,y\in A$ and $x\preccurlyeq y$, one has $x=y$.

### 2.2 Minimal members

For any subset $U\subseteq X$, define its set of **minimal members** by

$$
\operatorname{Min}(U)
=
\left\{x\in U:
\text{for every }y\prec x,\ y\notin U
\right\}.
$$

Minimality is relative to $U$. An element of $\operatorname{Min}(U)$ need not be globally minimal in $X$; it merely has no strict predecessor that remains in $U$.

**Lemma 2.1 (Minimal members form an antichain).**  
For every subset $U$ of a partially ordered set, $\operatorname{Min}(U)$ is an antichain.

**Proof sketch.** Take $x,y\in\operatorname{Min}(U)$ and suppose $x\preccurlyeq y$. If $x\ne y$, then $x\prec y$. But $x\in U$, contradicting the defining minimality of $y$. Hence $x=y$. The same argument rules out comparability in either direction between distinct minimal members. $\square$

This lemma requires neither finiteness nor a well-quasi-order. It is a direct consequence of minimality.

### 2.3 Well-quasi-orders

A partial order is a **well-quasi-order** if every infinite sequence $x_0,x_1,x_2,\ldots$ contains indices $i<j$ such that

$$
x_i\preccurlyeq x_j.
$$

For partial orders, this condition excludes two pathologies: infinite strictly descending chains and infinite antichains. Equivalently for the arguments below, the strict order is well-founded and every antichain is finite.

Well-foundedness means that every nonempty subset has a minimal member, or, equivalently, that no sequence can descend strictly forever. This principle is the source of obstruction coverage: a forbidden object can be simplified within the forbidden region only finitely often before reaching a minimal forbidden object.

**Lemma 2.2 (Finiteness of minimal members).**  
If $(X,\preccurlyeq)$ is well-quasi-ordered, then $\operatorname{Min}(U)$ is finite for every subset $U\subseteq X$.

**Proof sketch.** By Lemma 2.1, $\operatorname{Min}(U)$ is an antichain. Every antichain in a well-quasi-order is finite. $\square$

**Lemma 2.3 (Minimal member below every member).**  
Let $(X,\preccurlyeq)$ be well-quasi-ordered. If $x\in U$, then there exists $b\in\operatorname{Min}(U)$ such that $b\preccurlyeq x$.

**Proof sketch.** Consider

$$
U_x=\{y\in U:y\preccurlyeq x\}.
$$

This set is nonempty because $x\in U_x$. By well-foundedness, $U_x$ has a minimal member $b$. Then $b\in U$ and $b\preccurlyeq x$. If some $z\in U$ satisfied $z\prec b$, transitivity would give $z\preccurlyeq x$, hence $z\in U_x$, contradicting the minimality of $b$ in $U_x$. Therefore $b\in\operatorname{Min}(U)$. $\square$

The two components of well-quasi-ordering play distinct roles. The antichain condition gives finiteness; well-foundedness gives coverage.

## 3. The finite canonical forbidden-basis theorem

Let $C\subseteq X$ be a lower set. Define its **canonical forbidden basis** by

$$
B_C=\operatorname{Min}(X\setminus C).
$$

Thus $B_C$ consists exactly of the objects outside $C$ whose every strict predecessor lies in $C$.

**Theorem 3.1 (Finite Canonical Forbidden-Basis Theorem).**  
Let $(X,\preccurlyeq)$ be a well-quasi-ordered partial order, and let $C\subseteq X$ be a lower set. Then:

1. $B_C$ is finite;
2. $B_C$ is an antichain;
3. for every $x\in X$,

$$
x\in C
\quad\Longleftrightarrow\quad
\forall b\in B_C,\ b\npreccurlyeq x.
$$

**Proof sketch.** Finiteness follows from Lemma 2.2 applied to $X\setminus C$, and the antichain statement follows from Lemma 2.1.

For the forward implication in the characterization, suppose $x\in C$. If $b\in B_C$ and $b\preccurlyeq x$, lower closure would imply $b\in C$, contradicting $b\in X\setminus C$.

For the reverse implication, take the contrapositive. If $x\notin C$, then $x\in X\setminus C$. Lemma 2.3 supplies $b\in\operatorname{Min}(X\setminus C)=B_C$ with $b\preccurlyeq x$. Thus avoidance of all elements of $B_C$ fails. $\square$

### 3.1 Canonicality and irredundancy

The adjective “canonical” has a precise meaning: $B_C$ is defined solely from $C$ and the order. No choice of presentation or enumeration enters its definition.

It is also irredundant among forbidden bases. If $b\in B_C$, no distinct $b'\in B_C$ lies below $b$, because $B_C$ is an antichain. Consequently, removing $b$ from the avoidance list causes the object $b$ itself to pass all remaining tests, even though $b\notin C$.

Other finite forbidden lists may characterize $C$, but they can contain redundant nonminimal objects. The canonical basis strips away every such redundancy.

### 3.2 Why both hypotheses matter

If infinite antichains are allowed, a lower set can have infinitely many minimal forbidden objects. For example, take an infinite collection of pairwise incomparable points and let $C$ be empty. Every point is minimally forbidden.

If infinite descending chains are allowed, minimal forbidden objects may fail to cover the complement. Consider the integers with their usual order and $C=\varnothing$. The complement is all integers, but it has no minimal element. Thus an object outside $C$ need not lie above any minimal forbidden object, because there are none.

The theorem therefore uses the full force of well-quasi-ordering, not merely one of its two characteristic exclusions.

## 4. Specialization to matroid minors

### 4.1 Matroids

A **finite matroid** is a pair $M=(E,\mathcal I)$, where $E$ is a finite ground set and $\mathcal I\subseteq 2^E$ is a family of independent sets satisfying:

1. $\varnothing\in\mathcal I$;
2. if $J\in\mathcal I$ and $I\subseteq J$, then $I\in\mathcal I$;
3. if $I,J\in\mathcal I$ and $|I|<|J|$, then there exists $e\in J\setminus I$ such that $I\cup\{e\}\in\mathcal I$.

For $e\in E$, deletion removes $e$ while preserving independence among subsets of $E\setminus\{e\}$. Contraction removes $e$ after accounting for the dependence contributed by $e$. A **minor** of $M$ is any matroid obtained through a finite sequence of deletions and contractions. We write

$$
N\preccurlyeq_m M
$$

when $N$ is a minor of $M$.

A matroid class $C$ is **minor-closed** if

$$
M\in C\ \text{and}\ N\preccurlyeq_m M
\quad\Longrightarrow\quad N\in C.
$$

An **excluded minor** for $C$ is a matroid $M$ such that $M\notin C$ but every strict minor of $M$ belongs to $C$.

These definitions identify minor-closed classes with lower sets and excluded minors with minimal members of the complement.

**Proposition 4.1 (Order-theoretic characterization of excluded minors).**  
For every matroid class $C$, a matroid $M$ is an excluded minor for $C$ if and only if

$$
M\in\operatorname{Min}(\mathcal M\setminus C),
$$

where $\mathcal M$ is the ambient family of matroids ordered by $\preccurlyeq_m$.

**Proof sketch.** Both sides state the same two conditions: $M$ is outside $C$, and no strict minor of $M$ is outside $C$. $\square$

**Corollary 4.2 (Excluded minors are incomparable).**  
Distinct excluded minors of any matroid class are incomparable under the minor relation.

**Proof sketch.** Apply Lemma 2.1 to the complement of the class and use Proposition 4.1. $\square$

### 4.2 The conditional matroid theorem

**Theorem 4.3 (Conditional Finite Excluded-Minor Theorem).**  
Let $\mathcal M$ be a family of matroids that is well-quasi-ordered by the minor relation. If $C\subseteq\mathcal M$ is minor-closed, then its set $B_C$ of excluded minors is finite, and for every $M\in\mathcal M$,

$$
M\in C
\quad\Longleftrightarrow\quad
\forall N\in B_C,\ N\npreccurlyeq_m M.
$$

**Proof sketch.** Minor-closedness says exactly that $C$ is a lower set in $(\mathcal M,\preccurlyeq_m)$. Proposition 4.1 identifies excluded minors with minimal elements of the complement. The conclusion is therefore Theorem 3.1 specialized to the minor order. $\square$

This theorem is an implication. It does not prove that any particular broad representability class is well-quasi-ordered. Rather, it states exactly what follows once such a premise is available.

### 4.3 Representability over finite fields

Let $\mathbb F_q$ be a finite field. A matroid $M$ is **representable over $\mathbb F_q$** if one can assign a vector over $\mathbb F_q$ to each ground-set element so that a subset is independent in $M$ exactly when the corresponding vectors are linearly independent.

Matroids representable over $\mathbb F_2$ are called binary; those representable over $\mathbb F_3$ are called ternary. Graphic matroids are binary, but the class of graphic matroids is a proper subclass of the binary matroids. Consequently, a well-quasi-order theorem for graphs does not by itself settle the corresponding statement for all binary matroids.

The broad motivating conjecture would assert that, for fixed $q$, an appropriate family of finite $\mathbb F_q$-representable matroids is well-quasi-ordered by minors. If that premise were established, Theorem 4.3 would immediately give finite excluded-minor bases for minor-closed subclasses of that family.

No such premise is established here for ternary matroids. Nor is a claimed list of small ternary obstructions certified by the abstract argument. Concrete claims about representability, nonrepresentability, or exhaustive enumeration require separate matrix definitions and finite computations.

## 5. Intersections of finitely based classes

The next result does not require the ambient order to be a well-quasi-order.

**Theorem 5.1 (Canonical obstructions to an intersection).**  
Let $C,D\subseteq X$ be lower sets in a partial order. Then

$$
B_{C\cap D}\subseteq B_C\cup B_D.
$$

**Proof sketch.** Let $x\in B_{C\cap D}$. Then $x\notin C\cap D$, so $x\notin C$ or $x\notin D$. Suppose $x\notin C$. Every $y\prec x$ belongs to $C\cap D$ by the minimality of $x$ outside the intersection, and therefore every such $y$ belongs to $C$. Hence $x$ is minimal outside $C$, so $x\in B_C$. The case $x\notin D$ is symmetric. $\square$

**Corollary 5.2 (Finite-basis closure under binary intersection).**  
If $B_C$ and $B_D$ are finite, then $B_{C\cap D}$ is finite.

**Proof sketch.** By Theorem 5.1, $B_{C\cap D}$ is a subset of the finite set $B_C\cup B_D$. $\square$

**Corollary 5.3 (Matroid intersection theorem).**  
If two matroid classes each have finitely many excluded minors, then their intersection has finitely many excluded minors. Every excluded minor of the intersection is an excluded minor of at least one constituent class.

The inclusion in Theorem 5.1 can be strict. An obstruction to $C$ may contain a smaller obstruction to $D$, making it nonminimal outside $C\cap D$. Thus the union $B_C\cup B_D$ is a finite candidate list, but canonical minimization may remove redundant entries.

By induction, the same reasoning suggests an extension to every finite indexed intersection:

$$
B_{\bigcap_{i=1}^{k}C_i}
\subseteq
\bigcup_{i=1}^{k}B_{C_i}.
$$

The binary theorem supplies the essential step; a systematic finite-indexed formulation is a natural continuation.

## 6. Algorithms

### 6.1 Extracting canonical obstructions from finite data

Suppose a finite set $X$ and its order relation are explicitly available, together with a membership predicate for $C$. The canonical basis can be computed directly.

**Algorithm 1: Canonical forbidden-basis extraction**

1. Form the list $U=X\setminus C$.
2. For each $x\in U$, inspect every $y\in U$.
3. Retain $x$ if there is no $y\in U$ with $y\prec x$.
4. Return all retained objects.

Correctness follows immediately from the definition of $\operatorname{Min}(U)$. With $n=|X|$ and constant-time order and membership tests, the direct implementation takes $O(n^2)$ time and $O(n)$ auxiliary space. Sparse cover relations, topological processing, or domain-specific minor tests may improve practical performance.

### 6.2 Membership testing from a known basis

If a finite canonical basis $B_C$ is known, membership reduces to avoidance.

**Algorithm 2: Forbidden-minor membership test**

1. For each $b\in B_C$, test whether $b\preccurlyeq x$.
2. If any test succeeds, return “outside $C$.”
3. If all tests fail, return “inside $C$.”

Theorem 3.1 proves correctness under the lower-set and well-quasi-order hypotheses that produced $B_C$, or whenever the avoidance equivalence has otherwise been established. If the test for $b\preccurlyeq x$ costs $T_b(|x|)$, total running time is

$$
O\!\left(\sum_{b\in B_C}T_b(|x|)\right).
$$

The theorem guarantees a finite number of tests, not an efficient implementation of each test.

### 6.3 Combining two finite bases

Given finite canonical bases $B_C$ and $B_D$, Theorem 5.1 supplies a finite candidate pool $B_C\cup B_D$ for the intersection. To obtain the canonical basis, discard every candidate that lies inside $C\cap D$, and then discard every remaining candidate having a strict predecessor among the remaining outsiders. With $k=|B_C|+|B_D|$, pairwise minimization requires $O(k^2)$ order comparisons after membership status is known.

This procedure emphasizes the difference between a valid finite forbidden list and the canonical basis. The union may characterize the intersection but can contain redundancy; minimization restores irredundancy.

## 7. Examples

### 7.1 A subset lattice

Let $X=2^{\{1,2,3,4\}}$ ordered by inclusion, and define

$$
C=\{S\subseteq\{1,2,3,4\}:|S|\le 2\}.
$$

The class $C$ is lower. Its canonical forbidden basis consists of all three-element subsets:

$$
B_C=
\bigl\{
\{1,2,3\},\{1,2,4\},\{1,3,4\},\{2,3,4\}
\bigr\}.
$$

The four-element set is forbidden but not minimal, since it contains each three-element obstruction. Every subset belongs to $C$ exactly when it contains none of the four basis members.

Now let

$$
D=\{S:\{1,2\}\nsubseteq S\}.
$$

Then $B_D=\{\{1,2\}\}$. The union $B_C\cup B_D$ contains five candidates. For $C\cap D$, the triples $\{1,2,3\}$ and $\{1,2,4\}$ cease to be minimal because they contain $\{1,2\}$. Hence

$$
B_{C\cap D}
=
\bigl\{
\{1,2\},\{1,3,4\},\{2,3,4\}
\bigr\},
$$

illustrating the strictness that can occur in Theorem 5.1.

### 7.2 Divisibility

Let $X$ be the positive integers ordered by divisibility, so $a\preccurlyeq b$ means $a\mid b$. Consider the lower set

$$
C=\{n:6\nmid n\text{ and }10\nmid n\}.
$$

The complement consists of integers divisible by $6$ or $10$, and its minimal members are $6$ and $10$. Thus

$$
n\in C
\quad\Longleftrightarrow\quad
6\nmid n\text{ and }10\nmid n.
$$

This example is finite-basis behavior in an infinite order. It also exhibits an antichain: neither $6$ nor $10$ divides the other.

### 7.3 Interpretation for matroid properties

For a minor-closed matroid property, an excluded minor is a smallest dependence structure that violates the property. Every proper simplification repairs the violation. If the ambient family is well-quasi-ordered, Theorem 4.3 says there are only finitely many such minimal failures and every nonmember contains one.

The theorem does not identify those matroids. Finding them remains a structural or computational problem. The distinction parallels existence and construction throughout mathematics: proving that a finite certificate set exists is not the same as listing it.

## 8. Applications and implications

### 8.1 Structural classification

A finite obstruction basis gives a compact specification of a minor-closed class. It replaces a potentially unbounded positive description with finitely many negative certificates. This can clarify the boundary of the class: each excluded minor records a distinct minimal failure mode.

### 8.2 Algorithms and certification

When fixed-minor testing is tractable, a finite basis yields a recognition algorithm. A positive certificate consists of successful avoidance of every listed obstruction; a negative certificate can be a specific forbidden minor together with the deletion and contraction sequence producing it.

The complexity depends on the available minor-testing algorithms and the size of the basis. The finite-basis theorem itself is structural rather than a uniform complexity bound.

### 8.3 Modularity of properties

The intersection theorem enables compositional reasoning. Suppose one property enforces representational constraints and another enforces a connectivity or regularity condition, with both classes minor-closed and finitely based. Their conjunction is again finitely based. Candidate obstructions come from the two established lists, after canonical minimization.

### 8.4 A bridge from graph theory to matroid theory

Graph cycles define graphic matroids, so graph minors and matroid minors are closely related. The order-theoretic theorem is broad enough to cover both contexts once a suitable well-quasi-order premise is available. It therefore identifies a common explanatory core behind finite obstruction phenomena.

Nevertheless, the bridge must not erase distinctions. Binary representability is broader than graphicness, and representability over $\mathbb F_3$ introduces structures with no direct graph counterpart. The difficult content of any extension lies in proving the relevant well-quasi-order, not in the finite-basis deduction once that order is known.

## 9. Limitations

The results in this paper are exact but intentionally scoped.

First, no well-quasi-order theorem is established for all matroids representable over $\mathbb F_3$, or over an arbitrary fixed finite field. Therefore no unconditional finite excluded-minor theorem for those broad families follows here.

Second, representability has not been encoded through explicit matrices in this treatment. Claims that deletion and contraction preserve a chosen matrix-based representation require their own proofs.

Third, no exhaustive enumeration of rank-three matroids on nine elements is supplied. Such a census would require generation of all candidates, verification of the matroid axioms, quotienting by isomorphism, and exact representability tests. Sampling matrices only enumerates represented matroids and cannot certify that all nonrepresentable candidates have been considered.

Fourth, named small matroids are not analyzed here. Any assertion that a concrete matroid is representable or nonrepresentable over $\mathbb F_3$ must be supported by a matrix representation or a rigorous obstruction argument.

Finally, finiteness is not effectivity. A proof that a basis is finite need not provide an a priori size bound, a method to discover all basis elements, or efficient minor tests.

These limitations delineate the next mathematical tasks rather than weakening the proved implications.

## 10. Future directions

A first priority is to define finite-field matroid representability directly from matrices over $\mathbb F_3$ and prove closure under deletion and contraction. This would connect the abstract minor-order theorem to a concrete representability class.

A second direction is exact treatment of standard examples. Rank functions or matrices can specify concrete matroids, while finite linear algebra can certify representability. Nonrepresentability requires equally explicit certificates.

A third direction is enumeration up to matroid isomorphism. Before attempting a rank-three, nine-element search, one needs canonical labeling or another reliable quotient by relabeling. The search must range over matroids, not merely matrices, because matrix generation presupposes representability.

A fourth direction is the finite-indexed version of the intersection theorem. For lower sets $C_1,\ldots,C_k$, one expects

$$
B_{\bigcap_{i=1}^{k}C_i}
\subseteq
\bigcup_{i=1}^{k}B_{C_i},
$$

which yields finite basis closure for every finite conjunction of finitely based properties.

A fifth direction is to maintain a precise separation between graphic matroids and binary matroids in every graph–matroid comparison. This prevents graph-specific conclusions from being silently generalized beyond their hypotheses.

The central long-term challenge remains a well-quasi-order theorem for the intended representable families. The present work shows that such a theorem would immediately unlock canonical finite obstruction descriptions for all minor-closed subclasses.

## 11. Conclusion

The finite forbidden-basis phenomenon rests on a short but powerful order-theoretic chain. Minimal outsiders form an antichain. A well-quasi-order makes that antichain finite. Well-foundedness places a minimal outsider below every outsider. Lower closure then turns avoidance of those outsiders into an exact membership criterion.

For matroids, the minimal outsiders are precisely excluded minors. Hence a well-quasi-order under minors implies that every minor-closed class has a finite, canonical, irredundant excluded-minor basis. Separately, finite bases survive binary intersections without any ambient well-quasi-order assumption.

These results identify the logical payoff of a Robertson–Seymour-style theorem for finite-field-representable matroids while keeping the unproved structural premise explicit. The broad conjectural landscape remains open, but the route from well-quasi-ordering to finite classification is complete: every failure contains a smallest failure, and there can be only finitely many incomparable smallest failures.