# Rota Arrangements in Dimensions One and Two: A Complete Exchange Analysis

**Aristotle**  
**July 29, 2026**

## Abstract

Rota’s basis conjecture asks whether $n$ prescribed bases of an $n$-dimensional vector space can be independently reordered and placed as the rows of an $n\times n$ array so that every column is also a basis. The unrestricted conjecture remains open. This paper gives a self-contained treatment of dimensions one and two over an arbitrary division ring. We define a Rota arrangement by row-permutation and column-independence conditions, prove that each independent column canonically yields a basis by dimension counting, and establish the rank-one case. The main ingredient in rank two is a two-by-two exchange lemma: for independent pairs $(a,b)$ and $(c,d)$, either the parallel crossing $(a,c),(b,d)$ consists of two independent pairs or the alternative crossing $(a,d),(b,c)$ does. This dichotomy yields a constructive rank-two theorem and a constant-time algorithm. We discuss determinant implementations over fields, exact arithmetic examples, invariance and cyclic constructions, finite-field search, direct-sum questions, and the obstruction to extending a local exchange argument directly to higher rank.

## 1. Introduction

Let $K$ be a division ring and let $V$ be a left $K$-vector space of finite dimension $n$. Suppose that $n$ ordered bases are given:

$$
B_i=(b_{i,1},\ldots,b_{i,n}),\qquad i=1,\ldots,n.
$$

Rota’s basis conjecture asserts that there exist permutations $\pi_1,\ldots,\pi_n$ of $\{1,\ldots,n\}$ such that, for each column index $j$, the transversal family

$$
(b_{1,\pi_1(j)},b_{2,\pi_2(j)},\ldots,b_{n,\pi_n(j)})
$$

is a basis of $V$. Equivalently, one may reorder each input basis independently and use the reordered lists as rows of a square array in which all columns are bases.

The statement combines linear algebra with a global matching problem. Every row is already independent and spanning; the difficulty is to coordinate row permutations so that all transversals inherit these properties. The conjecture is unresolved in unrestricted rank, so low-dimensional cases are valuable both as verified boundary cases and as guides to the structure a general proof would need.

The purpose of this paper is to isolate and prove the complete rank-one and rank-two theory. The rank-one case is immediate. Rank two is governed by a precise exchange dichotomy involving four vectors and the two possible perfect matchings between the two input bases. Although the geometric intuition is elementary over $\mathbb R$, the proof is stated over an arbitrary division ring and relies only on linear independence and division by nonzero scalars.

The contributions are:

1. a minimal definition of a Rota arrangement using row permutations and column independence;
2. a dimension argument showing that every column in such an arrangement is automatically a basis;
3. a proof of the conjecture in rank one;
4. a two-by-two exchange lemma valid over every division ring;
5. a constructive proof of the conjecture in rank two;
6. exact algorithms and numerical demonstrations for coordinate vector spaces.

No result below assumes commutativity of scalar multiplication. When determinants are used computationally, however, the scalar system is specialized to a commutative field such as $\mathbb Q$ or $\mathbb R$.

## 2. Algebraic preliminaries

### 2.1. Division rings and vector spaces

A **division ring** $K$ is a ring in which every nonzero element has a multiplicative inverse. Multiplication need not be commutative. A **left $K$-vector space** is an abelian group $V$ equipped with a left scalar action $(\lambda,v)\mapsto \lambda v$ satisfying the usual distributive, associative, and unit laws.

A finite indexed family $(v_i)_{i\in I}$ in $V$ is **linearly independent** when

$$
\sum_{i\in I}\lambda_i v_i=0
$$

implies $\lambda_i=0$ for every $i\in I$. A **basis** is a linearly independent family that spans $V$. In dimension $n$, every linearly independent family of exactly $n$ vectors is a basis.

For pairs, linear independence means that

$$
sx+ty=0
$$

forces $s=t=0$. In particular, neither member of an independent pair is zero.

### 2.2. Dependence and proportionality in rank two

We will repeatedly use the following elementary fact.

**Lemma 2.1 (Proportionality of a dependent nonzero pair).** Let $x,y\in V$, with both $x$ and $y$ nonzero. If $(x,y)$ is linearly dependent, then either $y=\lambda x$ or $x=\mu y$ for some nonzero scalars $\lambda,\mu\in K$.

**Proof sketch.** Dependence supplies scalars $s,t$, not both zero, such that $sx+ty=0$. If $t\ne0$, multiply on the left by $t^{-1}$ and rearrange to obtain $y=(-t^{-1}s)x$. The multiplier cannot be zero because $y\ne0$. If $t=0$, then $s\ne0$; division by $s$ would force $x=0$, a contradiction. Thus in the nonzero setting the first case necessarily applies after choosing the equation’s orientation. Reversing the roles gives the other representation. $\square$

This lemma is the algebraic replacement for the geometric statement that two dependent nonzero vectors lie on the same line through the origin.

## 3. Rota arrangements

**Definition 3.1 (Rota arrangement).** Let $B_1,\ldots,B_n$ be ordered bases of an $n$-dimensional left vector space $V$ over $K$. A **Rota arrangement** is an array $G=(g_{ij})_{1\le i,j\le n}$ satisfying:

1. for every row $i$, there exists a permutation $\pi_i$ such that $g_{ij}=b_{i,\pi_i(j)}$ for all $j$;
2. for every column $j$, the family $(g_{1j},\ldots,g_{nj})$ is linearly independent.

This definition explicitly preserves each input basis as a row multiset while placing the substantive requirement on columns.

**Proposition 3.2 (Column promotion).** Every column of a Rota arrangement is a basis of $V$.

**Proof.** A column contains $n$ vectors and is linearly independent by Definition 3.1. Since $V$ has dimension $n$, an independent family of cardinality $n$ spans $V$. It is therefore a basis. $\square$

The proposition shows that column independence is not a weakening of the original conjecture. It is an equivalent and often more convenient formulation.

**Remark 3.3.** The row condition alone implies that every row is a basis, because permutations preserve linear independence and span. Thus a Rota arrangement is genuinely a basis array in both directions.

## 4. Rank one

**Theorem 4.1 (Rank-One Rota Basis Theorem).** Let $V$ be a one-dimensional left vector space over a division ring $K$, and let $B_1=(b)$ be a basis. Then the $1\times1$ array $(b)$ is a Rota arrangement.

**Proof.** The only row is the supplied basis under the identity permutation. Since a one-element basis cannot contain the zero vector, $b\ne0$. A singleton $(b)$ is linearly independent: if $sb=0$, then either $s=0$ or $b=0$, and the latter is impossible. Hence the unique column is independent and therefore a basis. $\square$

The result is unique up to the vacuous choice of ordering. Its importance is definitional: no positivity exception, empty-column convention, or special treatment is required.

## 5. The two-by-two exchange lemma

Let the two input bases be $(a,b)$ and $(c,d)$. Once the first row is fixed, only two relative arrangements remain:

$$
G_{\parallel}=\begin{pmatrix}a&b\\c&d\end{pmatrix},
\qquad
G_{\times}=\begin{pmatrix}a&b\\d&c\end{pmatrix}.
$$

Their column pairs are respectively $(a,c),(b,d)$ and $(a,d),(b,c)$.

**Theorem 5.1 (Two-by-Two Exchange Lemma).** Let $a,b,c,d\in V$. Suppose $(a,b)$ and $(c,d)$ are linearly independent. Then at least one of the following alternatives holds:

1. both $(a,c)$ and $(b,d)$ are linearly independent;
2. both $(a,d)$ and $(b,c)$ are linearly independent.

The alternatives need not be exclusive: for vectors in four generic directions, all four cross-pairs may be independent.

**Proof.** If both $(a,c)$ and $(b,d)$ are independent, the first alternative holds. It remains to show that if either pair in the first alternative is dependent, then both pairs in the second are independent.

First suppose $(a,c)$ is dependent. Since $(a,b)$ and $(c,d)$ are independent, all four vectors are nonzero. By Lemma 2.1, $a$ and $c$ are nonzero scalar multiples of one another.

We claim that $(a,d)$ is independent. If it were dependent, then $d$ would also be a scalar multiple of $a$, hence a scalar multiple of $c$. That would make $(c,d)$ dependent, contradicting the hypothesis. Similarly, $(b,c)$ must be independent: otherwise $b$ would be proportional to $c$, and therefore proportional to $a$, contradicting the independence of $(a,b)$. Thus the second alternative holds.

Now suppose $(a,c)$ is independent but $(b,d)$ is dependent. Again $b$ and $d$ are nonzero and proportional. If $(a,d)$ were dependent, then $a$ would be proportional to $d$ and hence to $b$, contradicting independence of $(a,b)$. If $(b,c)$ were dependent, then $c$ would be proportional to $b$ and hence to $d$, contradicting independence of $(c,d)$. Consequently $(a,d)$ and $(b,c)$ are both independent, so the second alternative holds. $\square$

### 5.1. A coefficient-level view

The proof can also be understood directly from dependence equations. Suppose, for instance, that $(b,d)$ is dependent. Then there are $s,t$, not both zero, with

$$
sb+td=0.
$$

Because $b\ne0$ and $d\ne0$, neither coefficient can be the sole nonzero coefficient. In particular $t\ne0$, and

$$
d=(-t^{-1}s)b.
$$

The multiplier is nonzero. If a relation $ua+vd=0$ existed, substitution would give

$$
ua+v(-t^{-1}s)b=0.
$$

Independence of $(a,b)$ forces $u=0$ and $v(-t^{-1}s)=0$. Since the multiplier is nonzero, $v=0$, proving $(a,d)$ independent. An analogous contradiction using $(c,d)$ proves $(b,c)$ independent.

This coefficient argument explains why the theorem remains valid over a noncommutative division ring: scalar products are retained in their proper order, and only inverses of known nonzero scalars are used.

### 5.2. Geometric interpretation over the plane

Over $\mathbb R$, replace every nonzero vector by its one-dimensional direction. Independence of a pair is inequality of directions. The hypotheses say

$$
[a]\ne[b],\qquad[c]\ne[d].
$$

If $[a]\ne[c]$ and $[b]\ne[d]$, the parallel pairing works. Otherwise, if $[a]=[c]$, then $[a]\ne[d]$ follows from $[c]\ne[d]$, while $[b]\ne[c]$ follows from $[a]\ne[b]$. Hence the crossed pairing works. The case $[b]=[d]$ is symmetric. The exchange lemma is therefore a statement about two perfect matchings in a bipartite graph whose forbidden edges encode equal directions.

## 6. The rank-two theorem

**Theorem 6.1 (Rank-Two Rota Basis Theorem).** Let $V$ be a two-dimensional left vector space over a division ring $K$. For every two ordered bases $(a,b)$ and $(c,d)$ of $V$, there exists a $2\times2$ Rota arrangement. Equivalently, the four vectors can be arranged so that the supplied bases form the rows and two bases form the columns.

**Proof.** Apply Theorem 5.1. If $(a,c)$ and $(b,d)$ are independent, choose

$$
G=\begin{pmatrix}a&b\\c&d\end{pmatrix}.
$$

Both rows are the supplied bases and both columns are independent. If the first alternative does not hold, the theorem guarantees that $(a,d)$ and $(b,c)$ are independent; choose

$$
G=\begin{pmatrix}a&b\\d&c\end{pmatrix}.
$$

The second row is a permutation of its supplied basis, and both columns are independent. Proposition 3.2 promotes each column to a basis. $\square$

**Corollary 6.2 (One-row normalization).** In rank two, the first input basis may always be left in its original order; at most the second basis must be swapped.

**Proof.** The two constructions in Theorem 6.1 both retain $(a,b)$ as the first row. $\square$

This normalization removes redundant global column permutations. If both rows were simultaneously swapped, the result would only exchange the names of the two columns.

## 7. Constructive algorithms

### 7.1. Abstract independence-oracle algorithm

Assume an oracle $\operatorname{Independent}(x,y)$ decides whether a pair is linearly independent.

**Algorithm 7.1 (Rank-Two Rota Arrangement).** Given bases $(a,b)$ and $(c,d)$:

1. test $\operatorname{Independent}(a,c)$;
2. test $\operatorname{Independent}(b,d)$;
3. if both tests are true, output rows $(a,b)$ and $(c,d)$;
4. otherwise output rows $(a,b)$ and $(d,c)$.

**Correctness.** If the first two tests succeed, both output columns are independent. Otherwise the first alternative of Theorem 5.1 fails, so its second alternative holds and the swapped output has independent columns. In either case, rows are permutations of the inputs. $\square$

The algorithm uses two independence tests for selection. A defensive implementation may verify both output columns afterward, adding two more tests. With an oracle cost $T_{\mathrm{ind}}$, selection costs $O(T_{\mathrm{ind}})$ and uses constant auxiliary storage.

### 7.2. Determinant implementation over a field

For vectors $x=(x_1,x_2)$ and $y=(y_1,y_2)$ over a commutative field, define

$$
\Delta(x,y)=x_1y_2-x_2y_1.
$$

The pair $(x,y)$ is independent exactly when $\Delta(x,y)\ne0$. Therefore Algorithm 7.1 becomes a pair of determinant checks. Over exact rational or integer data, no tolerance is needed. Over floating-point data, a numerical threshold should be scaled to vector norms because an absolute threshold is sensitive to units.

For fixed two-dimensional vectors, each determinant uses two multiplications and one subtraction. The full procedure has constant arithmetic complexity and $O(1)$ memory usage.

### 7.3. Exhaustive arrangement audit

For pedagogy or testing, one can enumerate the two permutations of the second row, retain the first row, and evaluate both column determinants for each candidate. The exchange theorem guarantees at least one successful candidate when both input rows are bases. This audit algorithm is less economical but records the entire two-element search space and visibly confirms the dichotomy.

## 8. Numerical examples

### 8.1. Straight pairing succeeds

Let

$$
a=(1,0),\quad b=(0,1),\quad c=(1,1),\quad d=(2,1).
$$

The row determinants are

$$
\Delta(a,b)=1,
\qquad
\Delta(c,d)=1\cdot1-1\cdot2=-1,
$$

so both rows are bases. For the straight arrangement,

$$
\Delta(a,c)=1,
\qquad
\Delta(b,d)=-2.
$$

Both are nonzero. Thus

$$
\begin{pmatrix}
(1,0)&(0,1)\\
(1,1)&(2,1)
\end{pmatrix}
$$

is a Rota arrangement.

### 8.2. A forced swap

Let

$$
a=(1,0),\quad b=(0,1),\quad c=(2,0),\quad d=(1,3).
$$

Again both rows are bases because

$$
\Delta(a,b)=1,
\qquad
\Delta(c,d)=6.
$$

But $\Delta(a,c)=0$, so the straight arrangement fails. The alternative has

$$
\Delta(a,d)=3,
\qquad
\Delta(b,c)=-2.
$$

Hence swapping the second row produces a valid arrangement.

### 8.3. Both pairings succeed

Take

$$
a=(1,0),\quad b=(0,1),\quad c=(1,1),\quad d=(1,-1).
$$

All four cross determinants are nonzero:

$$
\Delta(a,c)=1,\quad \Delta(b,d)=-1,
\quad \Delta(a,d)=-1,\quad \Delta(b,c)=-1.
$$

Thus both arrangements work. The exchange lemma promises at least one alternative, not uniqueness.

## 9. Structural observations and applications

### 9.1. Matching interpretation

Construct a bipartite graph whose left vertices are $a,b$, whose right vertices are $c,d$, and whose edges join independent pairs. A valid arrangement is a perfect matching. The basis assumptions prohibit any left or right side from collapsing to a single direction in a way that destroys both perfect matchings. Theorem 5.1 states more strongly that one of the graph’s two possible perfect matchings is present in full.

In higher rank, the analogous graph records pairwise compatibility but is insufficient by itself: a column of three or more vectors can be pairwise independent while the entire set is dependent. Thus rank two is special because pairwise compatibility and full column independence coincide.

### 9.2. Experimental design and sensing

Suppose each row represents a sensor package containing two measurements sufficient to reconstruct a two-parameter state. A Rota arrangement schedules one measurement from each package at each of two times while preserving reconstructibility at every time. The theorem guarantees that either the original schedule or a swap in the second package works. Analogous interpretations apply to redundant coordinate encodings, assignment of informative features, and transversal experimental designs.

### 9.3. Constant-family cyclic construction

A general structured example is worth recording. Let a basis be indexed by the cyclic group $\mathbb Z/n\mathbb Z$, and take $n$ identical copies as rows. Define

$$
g_{ij}=b_{i+j},
$$

where addition is modulo $n$. For fixed $i$, the map $j\mapsto i+j$ is a permutation, so each row is a reordered copy of the basis. For fixed $j$, the map $i\mapsto i+j$ is also a permutation, so each column is the same basis in a different order. This does not solve arbitrary inputs, but it exhibits a broad family where the desired Latin-square pattern is explicit.

### 9.4. Reindexing invariance

Independently permuting the labels within any supplied row cannot affect existence of an arrangement. Indeed, an arrangement for the relabeled family can be composed with the inverse input relabeling, and conversely. This symmetry justifies normalizing one row in rank two and should be built into computational searches in higher rank to reduce duplicate cases.

## 10. Limits of the rank-two method

The proof in rank two depends on a feature that disappears immediately in rank three. A dependent pair of nonzero vectors determines one proportionality class, and avoiding that class guarantees independence. For three vectors, dependence can occur without any pair being proportional. For example, in a plane embedded in three-space, vectors $x$, $y$, and $x+y$ are pairwise nonproportional but jointly dependent.

Consequently, a rank-three proof cannot rely only on a graph of pairwise independent cross-choices. It must track higher-order dependence, naturally expressed through matroid rank, nonvanishing minors, or exterior products. Furthermore, there are $(3!)^3=216$ raw row-permutation choices before symmetry reduction, rather than two essential crossings.

The two-dimensional argument nevertheless suggests a general strategy: identify local obstructions, prove that each obstruction forces compatibility elsewhere, and organize these implications into a global exchange procedure. The difficulty is that higher-order circuits overlap and a repair in one column can create dependence in another.

## 11. Future research directions

Five concrete extensions sharpen the next stages of investigation.

1. **Rank-three arrangements.** Prove that every three bases of a three-dimensional vector space over a division ring admit a Rota arrangement.
2. **Constant-family cyclic arrangements.** Establish the cyclic construction uniformly for every positive $n$ with indices in $\mathbb Z/n\mathbb Z$.
3. **Independent row-reindexing invariance.** Formulate and prove the equivalence between arrangement existence before and after arbitrary independent permutations of all input rows.
4. **Direct-sum closure under block-compatible input.** Determine precise hypotheses under which arrangements of sizes $m$ and $n$ combine into an arrangement of size $m+n$ in a direct sum, with every row respecting a common block decomposition.
5. **Finite-field exhaustive rank three.** Over the two-element field in $\mathbb F_2^3$, enumerate triples of bases modulo natural symmetries and either construct an arrangement for each triple or extract an explicit counterexample.

The finite-field program is especially concrete. The space $\mathbb F_2^3$ has only seven nonzero vectors, and every basis is an ordered triple with nonzero determinant. Enumeration can exploit general linear changes of coordinates to fix the first basis, row reindexing to reduce order redundancy, and permutation symmetries among rows and columns. Such computation would not settle arbitrary rank three, but it could expose exchange patterns suitable for a conceptual proof.

## 12. Conclusion

A Rota arrangement turns $n$ given row bases into $n$ simultaneous column bases by independently permuting row entries. In rank one, the identity arrangement suffices. In rank two, the complete problem reduces to two possible cross-pairings of four vectors.

The Two-by-Two Exchange Lemma proves that two independent input pairs cannot make both crossings fail: either $(a,c)$ with $(b,d)$ works, or $(a,d)$ with $(b,c)$ works. This yields a constructive theorem over arbitrary division rings and a constant-time determinant algorithm over ordinary fields.

The rank-two case is elementary but structurally informative. It converts local dependence into forced independence in the complementary pairing, illustrating the exchange logic at the center of the broader conjecture. Higher rank requires control of genuinely multi-vector dependencies, but the small case supplies a clean definition, a complete base theory, computational tests, and a precise model of what a successful exchange argument looks like.
