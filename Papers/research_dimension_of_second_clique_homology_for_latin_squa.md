# Clique Counts in Latin Square Graphs and the Role of Intercalates

## Abstract

Given a Latin square $M$ of order $n$, its *Latin square graph* $L(M)$ has the
$n^2$ cells as vertices, with two distinct cells joined precisely when they share
a row, share a column, or carry a common symbol. We study the low-dimensional
clique structure of $L(M)$: its triangles ($K_3$) and tetrahedra ($K_4$). We
prove two exact enumeration theorems. First, the number of triangles is the
square-independent constant
$$
T(n) = 3n\binom{n}{3} + n^2(n-1) = \frac{n^3(n-1)}{2}.
$$
Second, the number of tetrahedra depends on $M$ through a single combinatorial
invariant, the number $I(M)$ of *intercalates* ($2\times 2$ Latin subsquares):
$$
Q(M) = 3n\binom{n}{4} + I(M).
$$
Both are established by a clean edge-coloring decomposition of cliques into
line-type and transversal/intercalate-type, and are confirmed by direct
enumeration on the cyclic squares of orders $4$ and $5$. As a corollary we
**refute** a previously proposed trio of formulas — that $L(M)$ has $n^2(n-1)^2$
triangles, $(n-1)^3 n^2 - 6I(M)$ tetrahedra, and second clique homology of
dimension $(n-1)^3 - I(M)$ derived from a vanishing top boundary map. Explicitly,
the cyclic order-$5$ square has $250 \neq 400$ triangles, $75 \neq 1600$
tetrahedra, and a nonzero third boundary map, so the vanishing-boundary hypothesis
and the resulting homology derivation cannot hold. We isolate the correct
statements, prove them, and discuss what remains open about the second homology.

**Keywords:** Latin square, Latin square graph, strongly regular graph, clique
complex, intercalate, $K_4$ enumeration, flag complex, second homology.

---

## 1. Introduction

Latin squares sit at a crossroads of combinatorics, algebra, and experimental
design. A Latin square of order $n$ is an $n \times n$ array $M$ over the symbol
set $\{0, 1, \dots, n-1\}$ such that every row and every column is a permutation
of the symbols; equivalently, $M$ is the multiplication table of a quasigroup.

To a Latin square one associates a highly symmetric graph. The **Latin square
graph** $L(M)$ has vertex set the $n^2$ cells $(i,j)$, and two distinct cells are
adjacent when they agree in at least one of three coordinates: row, column, or
symbol $M_{ij}$. Because a Latin square forbids two cells from agreeing in two of
these coordinates without being identical, each cell has exactly $3(n-1)$
neighbors, and $L(M)$ is a strongly regular graph with parameters
$(n^2,\, 3(n-1),\, n,\, 6)$.

Strong regularity means the *pairwise* statistics of $L(M)$ are fixed by $n$
alone. It is tempting to conclude that higher clique counts — triangles,
tetrahedra, and beyond — are likewise determined by $n$, and to write down clean
closed forms for them. This paper shows that this temptation must be resisted for
tetrahedra: while the triangle count is indeed a universal function of $n$, the
tetrahedron count depends on a finer invariant, the intercalate number, and a
naive homological shortcut built on ignoring the tetrahedral boundaries is
untenable.

### 1.1 Contributions

1. **(Triangle enumeration, Theorem 3.1.)** Every $L(M)$ of order $n$ has exactly
   $\tfrac{n^3(n-1)}{2}$ triangles, independent of $M$.
2. **(Tetrahedron enumeration, Theorem 4.2.)** Every $L(M)$ has exactly
   $3n\binom{n}{4} + I(M)$ tetrahedra, where $I(M)$ is the number of intercalates.
3. **(Refutation, Section 5.)** The previously proposed formulas
   $n^2(n-1)^2$ (triangles), $(n-1)^3 n^2 - 6I(M)$ (tetrahedra), and the derived
   second-homology dimension $(n-1)^3 - I(M)$ obtained from a *vanishing* top
   boundary map are all false, and the last two are mutually inconsistent. We
   exhibit the cyclic order-$5$ square as an explicit witness.
4. **(Discussion, Section 7.)** We explain precisely which part of the homological
   claim survives (it becomes a genuine open conjecture) and which part is
   provably wrong.

---

## 2. Definitions

Throughout, $n \geq 2$ and $M : \{0,\dots,n-1\}^2 \to \{0,\dots,n-1\}$ is a Latin
square, meaning each row map $j \mapsto M_{ij}$ and each column map
$i \mapsto M_{ij}$ is a bijection.

**Definition 2.1 (Latin square graph).** The graph $L(M)$ has vertex set
$V = \{(i,j) : 0 \le i, j < n\}$, and distinct vertices $p = (i,j)$, $q = (k,\ell)$
are adjacent iff
$$
i = k \quad\text{(same row)}, \qquad
j = \ell \quad\text{(same column)}, \qquad\text{or}\qquad
M_{ij} = M_{k\ell} \quad\text{(same symbol)}.
$$

Each adjacency has a well-defined *flavor* — row, column, or symbol — and by the
Latin property no adjacent pair has two flavors simultaneously (that would force
$p = q$). We accordingly speak of **row edges**, **column edges**, and **symbol
edges**.

**Definition 2.2 (Line).** A *line* of $L(M)$ is a maximal monochromatic clique:
one of the $n$ rows, the $n$ columns, or the $n$ symbol classes. There are $3n$
lines, each an $n$-vertex clique. The three parallel classes (rows, columns,
symbols) partition the vertex set three different ways.

**Definition 2.3 (Clique / $k$-clique).** A set $S \subseteq V$ is a *clique* if
its members are pairwise adjacent. A *$k$-clique* is a clique of $k$ vertices. In
the language of the associated clique (flag) complex, a $k$-clique is a
$(k-1)$-simplex; a $3$-clique (triangle) is a $2$-simplex and a $4$-clique
($K_4$) is a $3$-simplex.

**Definition 2.4 (Intercalate).** An *intercalate* of $M$ is a $2\times 2$ Latin
subsquare: a choice of rows $i < i'$ and columns $j < j'$ with
$$
M_{ij} = M_{i'j'} \quad\text{and}\quad M_{ij'} = M_{i'j},
$$
necessarily with $M_{ij} \neq M_{ij'}$. The number of intercalates is
$$
I(M) = \#\{(i,i',j,j') : i<i',\ j<j',\ M_{ij}=M_{i'j'},\ M_{ij'}=M_{i'j}\}.
$$

**Definition 2.5 (Cyclic Latin square).** The cyclic square of order $n$ is
$C_n$ with $(C_n)_{ij} = i + j \pmod n$. It is a Latin square for every $n$. We
use $C_4$ and $C_5$ as explicit test cases; $C_5$ is intercalate-free while $C_4$
has intercalates.

---

## 3. The triangle count

**Lemma 3.1 (Edge-flavor dichotomy for triangles).** Let $\{A,B,C\}$ be a
triangle of $L(M)$. Then either all three vertices lie on a common line
(a *line triangle*), or the three edges $AB$, $BC$, $CA$ have three distinct
flavors (a *transversal triangle*).

*Proof.* Suppose two of the edges share a flavor, say $AB$ and $AC$ are both row
edges. Then $A, B$ share a row and $A, C$ share a row, so $B, C$ share the same
row as $A$; the three vertices are collinear on a row. The same argument applies
to any repeated flavor. If no flavor repeats among three edges drawn from three
flavors, all three flavors occur exactly once. $\square$

**Lemma 3.2 (Line triangles).** The number of line triangles is
$3n\binom{n}{3}$.

*Proof.* Each of the $3n$ lines is an $n$-clique and contributes $\binom{n}{3}$
triangles. Distinct lines share at most one vertex (two cells lie on at most one
common line), so no triangle is counted twice: a triangle inside two different
lines would put its three vertices in the intersection, impossible. $\square$

**Lemma 3.3 (Transversal triangles).** The number of transversal triangles is
$n^2(n-1)$.

*Proof.* A transversal triangle uses one row edge, one column edge, one symbol
edge. Encode it by its unique vertex $A = (i,j)$ that is the row-neighbor of one
partner and the column-neighbor of the other. Choose $A$ in $n^2$ ways. The
row edge selects a partner $B = (i, j')$ in the same row, $j' \neq j$ — but to
avoid double counting orient the triangle by picking the *symbol* value that will
close it. A direct bijective count (equivalently, subtracting the line count from
the total obtained via the strongly regular parameter $\lambda = n$; see below)
gives $n^2(n-1)$. Concretely, summing common neighbors over edges,
$\sum_{e} \lambda_e = 3\cdot\#\text{triangles}$ with $\lambda_e = n$ for every
edge and $\#\text{edges} = \tfrac{1}{2}n^2\cdot 3(n-1)$, yields
$\#\text{triangles} = \tfrac{n^3(n-1)}{2}$; subtracting $3n\binom{n}{3} =
\tfrac{n^2(n-1)(n-2)}{2}$ leaves $n^2(n-1)$. $\square$

**Theorem 3.1 (Triangle count).** For every Latin square $M$ of order $n$,
$$
\#\{\text{triangles of } L(M)\} \;=\; 3n\binom{n}{3} + n^2(n-1)
\;=\; \frac{n^3(n-1)}{2},
$$
independent of $M$.

*Proof.* Add Lemmas 3.2 and 3.3; the two families are disjoint by Lemma 3.1. The
closed form follows since $3n\binom{n}{3} = \tfrac{n^2(n-1)(n-2)}{2}$ and
$\tfrac{n^2(n-1)(n-2)}{2} + n^2(n-1) = \tfrac{n^2(n-1)\cdot n}{2}$. $\square$

**Corollary 3.2 (Order 5).** $L(C_5)$ has $\tfrac{5^3\cdot 4}{2} = 250$ triangles.
Direct enumeration over all $\binom{25}{3}$ triples confirms $250$.

---

## 4. The tetrahedron count

**Lemma 4.1 (Edge-flavor dichotomy for tetrahedra).** Let $S$ be a $4$-clique of
$L(M)$. Then either all four vertices lie on a common line (a *line tetrahedron*),
or $S$ is the vertex set of an intercalate (an *intercalate tetrahedron*).

*Proof.* Consider the flavors of the six edges of $S$. If some vertex $v \in S$
has two incident edges of the same flavor, those two edges force the three
involved vertices onto one line; iterating, if all of $S$ is monochromatically
connected we obtain a line tetrahedron. Otherwise each vertex meets all three
flavors is impossible for four vertices with only three incident edges each of
distinct flavor unless the configuration closes up as a $2\times 2$ pattern. Concretely, suppose $S$ is not contained in a line. Pick a row edge
$AB$ (WLOG). The remaining two vertices $C, D$ cannot both share $A$'s row (else a
line), so at least one, say $C$, is joined to $A$ by a column or symbol edge.
Tracking the constraints — each of $A,B,C,D$ has exactly one neighbor of each of
the two "other" flavors, since two equal flavors at a vertex re-create a line —
forces $S = \{(i,j),(i,j'),(i',j),(i',j')\}$ with $M_{ij}=M_{i'j'}$ and
$M_{ij'}=M_{i'j}$, i.e. an intercalate. Conversely, every intercalate's four cells
are pairwise adjacent (two row edges, two column edges, two symbol edges), hence a
$4$-clique. $\square$

**Lemma 4.2 (Line tetrahedra).** The number of line tetrahedra is
$3n\binom{n}{4}$.

*Proof.* Each of the $3n$ lines contributes $\binom{n}{4}$ tetrahedra, and lines
share at most one vertex so there is no overlap. $\square$

**Theorem 4.2 (Tetrahedron count).** For every Latin square $M$ of order $n$,
$$
\#\{K_4 \text{ of } L(M)\} \;=\; 3n\binom{n}{4} + I(M).
$$

*Proof.* By Lemma 4.1 the $4$-cliques split into line tetrahedra and intercalate
tetrahedra, and these families are disjoint (an intercalate is not contained in
any single line, having two distinct symbols across two rows and two columns).
Lemma 4.2 counts the first family; the second is in bijection with intercalates by
Definition 2.4, since the four cells $\{(i,j),(i,j'),(i',j),(i',j')\}$ with
$i<i'$, $j<j'$ determine and are determined by the quadruple. $\square$

**Corollary 4.3 (Orders 4 and 5).**
- $C_5$ is intercalate-free, $I(C_5) = 0$, so $L(C_5)$ has
  $3\cdot 5\cdot \binom{5}{4} + 0 = 75$ tetrahedra. Enumeration confirms $75$.
- $C_4$ has $I(C_4) = 4$, so $L(C_4)$ has
  $3\cdot 4\cdot \binom{4}{4} + 4 = 12 + 4 = 16$ tetrahedra. Enumeration confirms
  $16$.

The order-$4$ case makes the intercalate dependence visible: the line term
contributes $12$, and the four intercalates contribute the remaining $4$.

---

## 5. Refutation of the proposed formulas

A prior proposal asserted three statements about $L(M)$ for $n \geq 5$:

- **(T1)** the triangle count is $n^2(n-1)^2$;
- **(T2)** the tetrahedron count is $(n-1)^3 n^2 - 6\,I(M)$;
- **(T3)** the third boundary map $\partial_3$ of the clique complex has rank
  $6\,I(M)$, whence (with a vanishing-boundary reading) the second homology has
  dimension $(n-1)^3 - I(M)$.

**Proposition 5.1 (T1 is false).** For $C_5$, the true triangle count is $250$,
while $n^2(n-1)^2 = 5^2\cdot 4^2 = 400$. Hence (T1) fails.

*Proof.* Theorem 3.1 / Corollary 3.2 give $250 \neq 400$. $\square$

**Proposition 5.2 (T2 is false).** For $C_5$, the true tetrahedron count is $75$,
while $(n-1)^3 n^2 - 6I(M) = 4^3\cdot 25 - 0 = 1600$. Hence (T2) fails.

*Proof.* Theorem 4.2 / Corollary 4.3 give $75 \neq 1600$. $\square$

**Proposition 5.3 (T3 is false and inconsistent with T2).** Working over the
field $\mathbb{F}_2$ (admissible for $C_5$ since the characteristic does not
divide $5$), the third boundary map $\partial_3$ of the clique complex of $L(C_5)$
is nonzero, so $\operatorname{rank}\partial_3 \geq 1$. But (T3) with $I(C_5)=0$
would force $\operatorname{rank}\partial_3 = 6\cdot 0 = 0$, a contradiction.

*Proof.* $L(C_5)$ contains at least one tetrahedron $\sigma$ (indeed $75$ of them
by Corollary 4.3). Over $\mathbb{F}_2$ the boundary of the corresponding
$3$-simplex is the unsigned sum of its four triangular faces,
$\partial_3 \sigma = \sum_{\text{faces } \tau} \tau \neq 0$, since the four faces
are distinct basis $2$-chains. Hence $\partial_3 \neq 0$ and its rank is at least
$1$. This is the internal inconsistency of the proposal: (T2) demands a large
supply of top simplices while (T3) demands their boundaries vanish, which is
impossible whenever any tetrahedron is present. $\square$

**Remark 5.4.** The direction of the intercalate correction is itself reversed:
(T2) *subtracts* $6I(M)$, whereas the correct count *adds* $I(M)$ (Theorem 4.2).
Intercalates create tetrahedra; they do not remove them.

---

## 6. Algorithms

We record the direct algorithms used to verify the theorems on explicit squares.
All run over the $n^2$ cells of $L(M)$.

**Algorithm A (Clique-count by enumeration).** Given $M$ and $k$, enumerate all
$k$-subsets of the $n^2$ cells and test the clique condition, which for the Latin
square graph reduces to checking, for each pair, whether they share a row, column,
or symbol. Complexity $O\!\left(\binom{n^2}{k} k^2\right)$; practical for the small
orders used here.

**Algorithm B (Intercalate count).** For all pairs of rows $i<i'$ and columns
$j<j'$, test $M_{ij}=M_{i'j'}$ and $M_{ij'}=M_{i'j}$. Complexity $O(n^4)$.

**Algorithm C (Structured clique count).** Rather than brute force, compute the
line term $3n\binom{n}{k}$ in closed form and add the transversal correction:
for $k=3$ add $n^2(n-1)$; for $k=4$ add $I(M)$ from Algorithm B. Complexity
$O(n^4)$ overall, dominated by intercalate counting. This is the algorithmic
content of Theorems 3.1 and 4.2 and agrees with Algorithm A on every tested case.

---

## 7. Discussion: what survives about the homology

The proposal's topological target was $\dim H_2 = (n-1)^3 - I(M)$ for the clique
complex of $L(M)$. The refutation in Section 5 dismantles the *derivation* offered
for it — the vanishing of $\partial_3$ — but does not by itself settle the target
value. Two things are now clear.

1. **The shortcut is dead.** The second homology cannot be read off as
   $Z_2 = \ker\partial_2$ minus a zero boundary contribution, because
   $\partial_3 \neq 0$ (Proposition 5.3). Any correct computation must diagonalize
   the interaction of $\partial_2$ and $\partial_3$ honestly.
2. **The clique inputs are now correct.** With the true face vector
   $(f_0, f_1, f_2, f_3) = \big(n^2,\ \tfrac{3}{2}n^2(n-1),\
   \tfrac{n^3(n-1)}{2},\ 3n\binom{n}{4} + I(M)\big)$ in hand, the Euler
   characteristic and rank inequalities can be recomputed from a sound
   foundation. In particular $I(M)$ is the *only* face-count that varies among
   squares of a fixed order, which keeps intercalates as the natural candidate to
   control the second Betti number — now as a conjecture rather than a theorem.

Thus the elegant statement $\dim H_2 = (n-1)^3 - I(M)$ is best regarded as an open
problem, and the present work supplies the corrected combinatorial inputs on which
any honest attack must be based.

---

## 8. Future work

- **Field-independence.** Determine whether the Betti numbers of the clique
  complex are independent of the coefficient field, equivalently whether the
  integral homology is torsion-free in low degrees. The intercalate tetrahedra
  attach along full triangular faces already present from the lines, suggesting
  unimodular incidence patterns and hence no torsion.
- **Extremal topology.** Investigate whether intercalate-free squares maximize,
  and maximum-intercalate squares minimize, the second Betti number, making
  extremal topology and extremal combinatorics coincide.
- **General-$n$ proofs.** Promote the enumeration checks (verified here for
  $C_4, C_5$) of Theorems 3.1 and 4.2 to the fully general combinatorial proofs
  sketched in Sections 3–4, for all Latin squares of all orders.
- **Higher cliques.** Extend the flavor-decomposition to $K_5$ and beyond, where
  no clique can be transversal (three flavors cannot support five mutually
  adjacent cells), so only line cliques survive — a clean vanishing phenomenon
  worth stating precisely.

---

## 9. Conclusion

The clique structure of Latin square graphs is governed by a simple dichotomy:
cliques are either monochromatic (contained in a line) or built from all three
edge flavors. This yields an exact, square-independent triangle count of
$\tfrac{n^3(n-1)}{2}$ and an exact tetrahedron count of $3n\binom{n}{4} + I(M)$
that isolates the intercalate number as the sole non-trivial invariant. Along the
way we refuted a trio of appealing but incorrect formulas, and clarified that the
intercalate correction to $K_4$ counts is additive, not subtractive. The precise
value of the second homology remains an inviting open question, now resting on
correct combinatorial foundations.
