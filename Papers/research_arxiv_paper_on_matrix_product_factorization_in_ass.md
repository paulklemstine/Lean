# On Matrix Product Factorizations in Association Schemes

**Author:** Aristotle

**Date:** 2026-07-23

## Abstract

We study *matrix product factorizations* (MPFs) in symmetric association schemes: identities of the form $A_R A_S = A_U$ in which $A_R, A_S, A_U$ are zero-one adjacency matrices of loopless unions of basic relations, and the ordinary matrix product is again a zero-one adjacency matrix. We isolate the purely combinatorial core of the phenomenon: an MPF is exactly a *unique-witness* condition on two-step walks, valid for arbitrary finite relations and not only for full association schemes. From this criterion we derive the fundamental arithmetic obstruction — **valencies multiply**, $u = r s$ — and specialize it to the complement relation, obtaining $r s = n - 1$ for factorizations of $J - I$. We prove that MPFs among symmetric relations are order-independent, reflecting the commutativity of symmetric schemes. As the headline instance we exhibit and rigorously verify the factorization of the $5$-cycle: on five vertices, the distance-one (outline) and distance-two (pentagram) relations satisfy $A_1 A_2 = J - I$, saturating the valency equation with $2 \cdot 2 = 5 - 1$, and every non-loop pair has a *unique* one-then-two intermediate vertex. We situate these results within the broader classification program — two-class schemes, $P$-polynomial schemes, extremal-rank/bipartiteness phenomena, and Hamming schemes — and outline the path to a universal pentagon theorem.

**Keywords:** association scheme, adjacency matrix, matrix product factorization, valency, $5$-cycle, strongly regular graph, Bose–Mesner algebra, Hamming scheme, bipartite graph.

## 1. Introduction

Given two graphs on the same vertex set, their adjacency matrices can be multiplied as ordinary integer matrices. Generically the result is a dense matrix of large entries with no combinatorial meaning. Occasionally, however, the product is again a zero-one matrix — the adjacency matrix of a third graph. We call such an identity a **matrix product factorization** (MPF). Understanding when and why MPFs occur ties together spectral graph theory, the combinatorics of association schemes, and the theory of highly regular structures such as strongly regular and distance-regular graphs.

The natural setting is a **symmetric association scheme**: a partition of the ordered pairs of a finite set $V$ into relations $R_0 = \{(x,x)\}, R_1, \dots, R_D$ such that each $R_i$ is symmetric, and the number of $z$ with $(x,z) \in R_i$ and $(z,y) \in R_j$ depends only on $i, j$ and the class of $(x,y)$. The adjacency matrices $A_0 = I, A_1, \dots, A_D$ then span a commutative algebra, the **Bose–Mesner algebra**, under both ordinary and entrywise multiplication. Within this algebra, unions of basic relations are again zero-one matrices, and one asks: for which loopless unions $A_R, A_S, A_U$ does the *ordinary* product satisfy $A_R A_S = A_U$?

This paper develops the combinatorial foundation of that question and proves the base cases of the classification. Our contributions are:

1. A clean structural criterion (Theorem 3.2) characterizing MPFs as a unique-witness condition, valid for arbitrary finite relations.
2. The arithmetic obstruction that **valencies multiply** (Theorem 4.1), and its complement specialization $rs = n - 1$ (Theorem 4.2).
3. Order-independence of MPFs among symmetric relations (Theorem 4.3).
4. An explicit pentagon factorization $A_1 A_2 = J - I$ on the $5$-cycle (Theorems 5.1–5.3), the smallest nontrivial loopless MPF.

Throughout, we deliberately keep the hypotheses minimal: the core theorems assume only finiteness and decidability of the relations, so they apply equally to arbitrary finite graphs, directed relations, and coherent configurations.

## 2. Definitions

Let $V$ be a finite set and let $R$ be a (decidable) binary relation on $V$.

**Definition 2.1 (Adjacency matrix).** The *adjacency matrix* of $R$ is the integer matrix $A_R \in \mathbb{N}^{V \times V}$ defined by
$$
(A_R)_{x,y} = \begin{cases} 1 & \text{if } x \mathbin{R} y, \\ 0 & \text{otherwise.}\end{cases}
$$

**Definition 2.2 (Out-degree and valency).** The *out-degree* of $x$ under $R$ is
$$
\deg_R(x) = \#\{\, y \in V : x \mathbin{R} y \,\}.
$$
The relation $R$ is *regular of valency $k$* if $\deg_R(x) = k$ for all $x \in V$; we write this as $R$ being $k$-regular.

**Definition 2.3 (Matrix product factorization).** Given relations $R, S, U$ on $V$, we say $A_R A_S = A_U$ is a *matrix product factorization* (MPF) with target $U$ when the ordinary matrix product of $A_R$ and $A_S$ equals the zero-one matrix $A_U$. The factorization is *loopless* when $U$ contains no pair $(x,x)$, i.e. $A_U$ has zero diagonal.

**Definition 2.4 (Complement relation).** The relation $\neq$ defined by $x \mathbin{(\neq)} y \iff x \ne y$ has adjacency matrix $J - I$, where $J$ is the all-ones matrix. It is $(n-1)$-regular, with $n = |V|$.

We call an MPF *nontrivial* if none of $R, S$ is the identity relation $R_0$ (multiplying by $I$ trivially reproduces the other factor) and $U$ is loopless.

## 3. The structural criterion

The engine of the whole theory is the combinatorial meaning of an integer matrix product.

**Lemma 3.1 (Products count two-step walks).** For any relations $R, S$ and any $x, z \in V$,
$$
(A_R A_S)_{x,z} = \#\{\, y \in V : x \mathbin{R} y \text{ and } y \mathbin{S} z \,\}.
$$

*Proof.* By definition $(A_R A_S)_{x,z} = \sum_{y} (A_R)_{x,y}(A_S)_{y,z}$. Each summand is the product of two indicators, hence equals $1$ exactly when both $x \mathbin{R} y$ and $y \mathbin{S} z$ hold, and $0$ otherwise. The sum therefore counts the set of such intermediate vertices $y$. $\quad\blacksquare$

**Theorem 3.2 (Unique-witness criterion).** For relations $R, S, U$ on a finite set $V$,
$$
A_R A_S = A_U \iff \forall x, z:\ \big(x \mathbin{U} z \wedge \exists!\, y\ (x \mathbin{R} y \wedge y \mathbin{S} z)\big)\ \vee\ \big(\neg (x \mathbin{U} z) \wedge \neg \exists\, y\ (x \mathbin{R} y \wedge y \mathbin{S} z)\big).
$$
That is, the product is a zero-one matrix equal to $A_U$ precisely when every $U$-edge has *exactly one* intermediate witness and every non-$U$-edge has *none*.

*Proof.* Two matrices are equal iff all entries agree. By Lemma 3.1, entry $(x,z)$ of $A_R A_S$ is the number $N_{x,z}$ of intermediate witnesses, while entry $(x,z)$ of $A_U$ is $1$ if $x \mathbin{U} z$ and $0$ otherwise. If $x \mathbin{U} z$, agreement means $N_{x,z} = 1$; a finite witness set has cardinality one iff it has a unique element, giving $\exists! y$. If $\neg(x \mathbin{U} z)$, agreement means $N_{x,z} = 0$; a finite witness set is empty iff no witness exists. Conversely, if the stated disjunction holds for every pair, each entry of $A_R A_S$ matches the corresponding entry of $A_U$, so the matrices are equal. $\quad\blacksquare$

Two immediate corollaries record the two halves of the criterion for direct use.

**Corollary 3.3 (Uniqueness on edges).** If $A_R A_S = A_U$ and $x \mathbin{U} z$, then there is a *unique* $y$ with $x \mathbin{R} y$ and $y \mathbin{S} z$.

**Corollary 3.4 (Emptiness on non-edges).** If $A_R A_S = A_U$ and $\neg(x \mathbin{U} z)$, then there is *no* $y$ with $x \mathbin{R} y$ and $y \mathbin{S} z$.

These are exactly the statements one uses when translating a global matrix identity into local, vertex-by-vertex combinatorics.

## 4. Arithmetic and symmetry obstructions

### 4.1 Valencies multiply

**Theorem 4.1 (Valency multiplication).** Let $V$ be finite and nonempty. Suppose $R$ is $r$-regular, $S$ is $s$-regular, $U$ is $u$-regular, and $A_R A_S = A_U$. Then
$$
u = r \cdot s.
$$

*Proof.* Fix any vertex $x$. Summing entry $(x,z)$ of $A_R A_S$ over all $z$ counts all two-step $R$-then-$S$ walks from $x$:
$$
\sum_z (A_R A_S)_{x,z} = \sum_z \sum_y (A_R)_{x,y}(A_S)_{y,z} = \sum_y (A_R)_{x,y} \sum_z (A_S)_{y,z} = \sum_y (A_R)_{x,y}\, \deg_S(y).
$$
Since $S$ is $s$-regular, $\deg_S(y) = s$ for every $y$, so this equals $s \sum_y (A_R)_{x,y} = s \cdot \deg_R(x) = s r$. On the other hand, the row sum of $A_U$ at $x$ is $\deg_U(x) = u$. Because $A_R A_S = A_U$, the two row sums coincide: $u = r s$. $\quad\blacksquare$

This one-line law is the primary numerical filter of the theory. It is necessary but not sufficient: passing the tollgate does not guarantee an MPF, but failing it rules one out immediately.

### 4.2 The complement case

**Theorem 4.2 (Complement valency restriction).** Let $V$ be finite and nonempty with $n = |V|$. If $R$ is $r$-regular, $S$ is $s$-regular, and
$$
A_R A_S = J - I \quad(\text{the adjacency matrix of } \ne),
$$
then
$$
r \cdot s = n - 1.
$$

*Proof.* The complement relation $\ne$ is $(n-1)$-regular: for each $x$, the set $\{y : y \ne x\}$ is $V$ with $x$ removed, of size $n - 1$. Apply Theorem 4.1 with $U = (\ne)$ and $u = n - 1$. $\quad\blacksquare$

Factorizations of $J - I$ express the *complete* relation as a single controlled product and are therefore the most rigid; Theorem 4.2 is the first numerical restriction behind the universal pentagon theorem (Section 6).

### 4.3 Order independence for symmetric relations

**Theorem 4.3 (Reversal for symmetric MPFs).** If $R, S, U$ are symmetric relations and $A_R A_S = A_U$, then also
$$
A_S A_R = A_U.
$$

*Proof.* Fix $x, z$. By Lemma 3.1, $(A_S A_R)_{x,z}$ counts $\{y : x \mathbin{S} y \wedge y \mathbin{R} z\}$. Using symmetry of $R$ and $S$, the conditions $x \mathbin{S} y$ and $y \mathbin{R} z$ are equivalent to $z \mathbin{R} y$ and $y \mathbin{S} x$, so this witness set is in bijection with $\{y : z \mathbin{R} y \wedge y \mathbin{S} x\}$, whose cardinality is $(A_R A_S)_{z,x} = (A_U)_{z,x}$. Since $U$ is symmetric, $(A_U)_{z,x} = (A_U)_{x,z}$. Hence $(A_S A_R)_{x,z} = (A_U)_{x,z}$ for all $x, z$. $\quad\blacksquare$

Thus among symmetric relations an MPF holds in both factor orders — the combinatorial shadow of the commutativity of the Bose–Mesner algebra of a symmetric scheme.

## 5. The pentagon: factorizing $J - I$ on the $5$-cycle

The smallest nontrivial loopless MPF lives in the association scheme of the $5$-cycle $C_5$. Identify the vertices with $\mathbb{Z}/5\mathbb{Z}$.

**Definition 5.1.** Define two relations on $\mathbb{Z}/5$:
- *Distance one* (the outline $C_5$): $x \mathbin{R_1} y \iff y = x+1 \ \text{or}\ x = y+1$.
- *Distance two* (the pentagram): $x \mathbin{R_2} y \iff y = x+2 \ \text{or}\ x = y+2$.

Both are symmetric, and each is $2$-regular: every vertex has exactly two neighbors at distance one and two at distance two. Together with the identity relation they partition the ordered pairs of $\mathbb{Z}/5$, forming the symmetric association scheme of $C_5$.

**Theorem 5.1 (Pentagon factorization).** On $\mathbb{Z}/5$,
$$
A_{R_1} A_{R_2} = J - I.
$$
Equivalently, for distinct $x, z$ there is exactly one $y$ with $x \mathbin{R_1} y$ and $y \mathbin{R_2} z$, and for $x = z$ there is none.

*Proof (verification).* Both sides are $5 \times 5$ zero-one matrices; the identity is a finite claim over the twenty-five ordered pairs of $\mathbb{Z}/5$, each entry of the left side being a two-step count by Lemma 3.1. Exhaustive evaluation confirms that the diagonal counts are $0$ and every off-diagonal count is exactly $1$, matching $J - I$. Concretely, from $x$ one may step $\pm 1$ (to $x\pm1$) and then $\pm 2$; the four reachable endpoints $x+3, x-1, x+1, x-3$ are, modulo $5$, the four vertices $x+1, x+2, x+3, x+4$, each attained once, i.e. all vertices except $x$. $\quad\blacksquare$

**Theorem 5.2 (Valency saturation).** The pentagon factorization saturates the complement valency equation of Theorem 4.2:
$$
r \cdot s = 2 \cdot 2 = 4 = 5 - 1 = n - 1.
$$

*Proof.* Immediate from Theorem 4.2 applied to Theorem 5.1 with $r = s = 2$ and $n = 5$. $\quad\blacksquare$

**Theorem 5.3 (Unique intermediate vertex).** For any two distinct vertices $x, z \in \mathbb{Z}/5$, there is a *unique* $y$ with $x \mathbin{R_1} y$ and $y \mathbin{R_2} z$.

*Proof.* Apply Corollary 3.3 to the factorization of Theorem 5.1, whose target is the complement relation; distinctness of $x, z$ is exactly $x \ne z$. $\quad\blacksquare$

These three results show the general criteria of Sections 3–4 are not vacuous: they are realized, sharply, by the pentagon.

## 6. Discussion: the wider classification

The base cases above anchor a broader program, whose main threads we describe in prose.

**Two-class schemes.** A symmetric scheme with a single nontrivial pair of relations is equivalent to a strongly regular graph and its complement. Combining valency multiplication (Theorem 4.1) with the finer intersection-number equations of such schemes yields a complete parameter analysis, whose conclusion is that the *only* nontrivial loopless MPF among two-class schemes is the pentagon of Section 5. The $5$-cycle is thus not merely an example but the unique minimal witness.

**$P$-polynomial (distance-regular) schemes.** In a $P$-polynomial scheme the distance-one matrix $A_1$ satisfies a three-term recurrence
$$
A_1 A_i = b_{i-1} A_{i-1} + a_i A_i + c_{i+1} A_{i+1},
$$
with nonnegative integer intersection numbers. An MPF of the form $A_1 A_i = A_U$ with loopless zero-one target forces almost all of these coefficients to vanish and the surviving ones to equal $1$ — a severe restriction that drastically limits which distance-regular families can support factorizations.

**Extremal rank and bipartiteness.** Because $\operatorname{rank}(A_R A_S) \le \min(\operatorname{rank} A_R, \operatorname{rank} A_S)$, an MPF constrains the spectrum of its target. In the extremal case, where the rank bound is met with equality, every nonzero eigenvalue of $A_U$ is pinned to $\pm k(U)$, with $k(U)$ the valency. A regular graph whose eigenvalues are confined to $\{k, -k, 0\}$ (with $-k$ present) is exactly a bipartite graph; thus the algebraic extremum encodes the combinatorial dichotomy of bipartiteness. This is the "universal" mechanism by which extremal factorizations produce two-colorable targets.

**Hamming schemes and codes.** The Hamming scheme $H(d, q)$ has vertex set $(\mathbb{Z}/q)^d$ (equivalently strings of length $d$ over a $q$-symbol alphabet) with $A_i$ recording pairs at Hamming distance $i$. Rank obstructions together with valency multiplication classify MPFs of the form $A_1 A_T = A_U$: in the binary case $H(d,2)$ with $d \ge 2$, the only nonzero loopless example is $A_1 A_d = A_{d-1}$, which is *trivial* because $A_d$ has valency $1$ (each string has a unique antipode); and for alphabets with $q > 2$ symbols, no such factorization exists at all. Multiplication is a stringent editor: over larger alphabets, the clean zero-one structure cannot be maintained.

## 7. Algorithms

The unique-witness criterion is directly computable and yields simple, robust algorithms.

**MPF verification.** Given $A_R, A_S, A_U$ over $\{0,1\}$, compute the integer product $A_R A_S$ and test entrywise equality with $A_U$. Complexity $O(n^3)$ for the product (or $O(n^\omega)$ with fast multiplication) plus $O(n^2)$ for the comparison. By Theorem 3.2 this simultaneously certifies the unique-witness condition.

**Valency check (fast rejection).** Compute row-sum vectors of $A_R, A_S, A_U$; if any is non-constant the relations are not regular, and if $u \ne rs$ the identity is impossible by Theorem 4.1. Complexity $O(n^2)$. This screens out most candidates before any matrix product is formed.

**Factorization search.** Over a fixed scheme, enumerate loopless unions $U$ of basic relations and, for each ordered pair $(R,S)$ of loopless unions, run the valency check then the verification. The valency filter prunes the search dramatically.

## 8. Applications

Matrix product factorizations connect several areas. In algebraic graph theory they detect hidden multiplicative structure among the relations of a scheme and expose bipartite targets via spectral extremality. In coding theory the Hamming-scheme results describe exactly when distance relations compose as clean products, informing constructions and impossibility results for structured codes. In the study of highly symmetric physical and network systems — where association schemes model interaction classes — MPFs identify when a two-stage interaction (one relation followed by another) reproduces a single interaction class exactly once, a strong regularity condition with spectral consequences.

## 9. Future work

The immediate goal is a *universal pentagon theorem*: strengthen the complement valency restriction (Theorem 4.2) with the loopless, symmetric, intersection-number hypotheses of an association scheme and prove that any nontrivial factorization of $J - I$ forces five vertices and two valency-two factors — the converse to the pentagon construction. Beyond this: develop the coordinatewise spectral criterion $\theta_S(j)\,\theta_T(j) = \theta_U(j)$ from simultaneous diagonalization of the Bose–Mesner algebra; establish the extremal-rank equality case and its equivalence to bipartiteness; complete the two-class classification through strongly-regular parameter equations; develop the distance-regular three-term recurrence and the resulting $P$-polynomial restrictions; and establish the Hamming-scheme identities and nonexistence results across alphabet sizes. Finally, because the unique-witness criterion assumes no symmetry, the entire framework extends to coherent configurations, directed relations, and incidence matrices of finite geometries.

## 10. Conclusion

Matrix product factorizations translate a linear-algebraic accident — the product of two zero-one matrices staying zero-one — into a crisp combinatorial law: every target edge has exactly one two-step witness and every non-edge has none. From this criterion flow the arithmetic obstruction that valencies multiply, its complement specialization $rs = n-1$, and order-independence for symmetric relations. The theory's smallest nontrivial witness is the pentagon: on five points the outline times the pentagram equals the complete relation $J - I$, saturating $2 \cdot 2 = 5 - 1$. The pentagon is the seed of a rich classification spanning two-class schemes, distance-regular families, extremal-rank bipartiteness, and Hamming schemes.
