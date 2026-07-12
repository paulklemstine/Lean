# The Product Bruhat Order and the Closure of Orbit Strata on Products of Flag Manifolds

## Abstract

We develop the order-theoretic backbone of the correspondence between
$B$-orbit strata on a product of flag manifolds and the **product Bruhat
order** on a pair of symmetric groups. Parametrising each orbit by a pair of
Weyl-group elements—one per projection—we show that the geometric *closure
order* on strata is the restriction of the **componentwise Bruhat order** on
such pairs. Working entirely at the combinatorial level, we model the Weyl
group by the symmetric group $S_n$ and encode the Bruhat order through the
classical **Ehresmann rank criterion**. Our principal results are: (i) a
transpose identity for rank matrices under inversion,
$\operatorname{rk}_{w^{-1}}(i,j) = \operatorname{rk}_{w}(j,i)$; (ii) the
**inversion invariance** of the Bruhat order, $u \le v \iff u^{-1} \le
v^{-1}$, which makes the two-projection map $w \mapsto (w, w^{-1})$ an order
embedding into the product order; (iii) **antisymmetry**, i.e. the rank
matrix determines the permutation, establishing that the Ehresmann criterion
is a genuine partial order; (iv) explicit **extremes**—the identity is the
minimum and the reversal permutation the maximum—together with the
characterisation of the minimum as the unique inversion-free element; and (v)
the **headline correspondence** $u \le v \iff (u, u^{-1}) \le (v, v^{-1})$
componentwise, which is the algebraic content of "Bruhat order preserves
closure relations for orbit strata." We give complete proof sketches and
supporting algorithms.

**Keywords:** Bruhat order, Ehresmann rank criterion, symmetric group, flag
variety, Schubert cells, orbit closure, product order, permutation
inversions.

**MSC (2020):** 05E10, 14M15, 06A07, 20F55.

---

## 1. Introduction

The **flag variety** $\mathrm{Fl}_n$ parametrises complete flags
$$
\mathcal{F}: \quad \{0\} = V_0 \subset V_1 \subset \cdots \subset V_n = \mathbb{C}^n,
\qquad \dim V_k = k,
$$
and is one of the central objects of algebraic geometry and representation
theory. The Borel subgroup $B \subset GL_n(\mathbb{C})$ of upper-triangular
invertible matrices acts on $\mathrm{Fl}_n$ with finitely many orbits, the
**Schubert cells**, indexed by the symmetric group $S_n$ (the Weyl group of
type $A_{n-1}$). The **Bruhat decomposition** organises these cells, and the
**Bruhat order** describes their closures: the closure of a Schubert cell is
a union of cells, and
$$
X_u \subseteq \overline{X_v} \quad\Longleftrightarrow\quad u \le v \ \text{ in the Bruhat order.}
$$

When one considers a **product** of flag manifolds and the diagonal $B$
action (equivalently, $B$-orbits on $\mathrm{Fl}_n \times \mathbb{P}^{n-1}$
and their relatives, as in the concept framing), each orbit acquires a pair
of Weyl-group parameters via the two projections. The natural conjecture,
which this paper certifies at the order-theoretic level, is that the closure
relation on orbits coincides with the restriction of the **product Bruhat
order** to the image of the parametrising map:
$$
\mathcal{O}_1 \subseteq \overline{\mathcal{O}_2}
\quad\Longleftrightarrow\quad
\varphi(\mathcal{O}_1) \le \varphi(\mathcal{O}_2)
\ \text{ in } (S_n, \le) \times (S_n, \le).
$$

Our contribution is to isolate and prove the combinatorial skeleton on which
this statement rests. We make **no geometric assumptions**: we build the
Bruhat order from the Ehresmann rank criterion and prove that it is a partial
order, that it is invariant under inversion (so the two projections carry
compatible orders), that it has explicit extremes, and that the
two-projection map $w \mapsto (w, w^{-1})$ is an order embedding into the
product order whose image realises the closure relation. Everything is proved
from the rank criterion with no circular references.

### 1.1 Organisation

Section 2 fixes definitions: inversions, length, the rank count, the Bruhat
order, and the product Bruhat order. Section 3 proves the transpose identity
and inversion invariance. Section 4 proves antisymmetry (rank rigidity) and
deduces that the Bruhat order is a partial order. Section 5 identifies the
extremes and links the minimum to length zero. Section 6 assembles the
product order and states the headline correspondence. Section 7 gives
algorithms; Section 8 discusses applications; Section 9 lists future
directions.

---

## 2. Definitions

Throughout, $n$ is a positive integer and $S_n$ denotes the group of
permutations of $\{1, 2, \dots, n\}$ (modelled on positions $\{0, \dots,
n-1\}$ in the accompanying computations, but written $1$-indexed here for
readability). We write $\mathrm{id}$ for the identity permutation.

**Definition 2.1 (Inversion set and length).**
The **inversion set** of a permutation $\sigma$ is
$$
\operatorname{Inv}(\sigma) = \{\, (i, j) : i < j \ \text{and}\ \sigma(j) < \sigma(i) \,\},
$$
the set of position-pairs whose values are out of order. The **length** (or
Coxeter/Bruhat length) is
$$
\ell(\sigma) = \# \operatorname{Inv}(\sigma).
$$
The length is the number of adjacent transpositions in a reduced word for
$\sigma$, and geometrically it is the (co)dimension datum of the
corresponding Schubert cell.

**Definition 2.2 (Rank count / rank matrix).**
For $w \in S_n$ and indices $i, j$, the **Ehresmann rank count** is
$$
\operatorname{rk}_w(i, j) = \#\{\, k \le i : w(k) \le j \,\}.
$$
The full array $(\operatorname{rk}_w(i,j))_{i,j}$ is the **rank matrix** of
$w$. It is a monotone nondecreasing function of each argument and records,
for every "lower-left" window, how many points of the permutation graph fall
inside it.

**Definition 2.3 (Bruhat order).**
For $u, v \in S_n$, we set
$$
u \le v \quad\Longleftrightarrow\quad
\operatorname{rk}_v(i, j) \le \operatorname{rk}_u(i, j) \ \text{ for all } i, j.
$$
This is the **Ehresmann rank criterion** for the Bruhat order. (The
direction of the inequality reflects that larger elements have graphs pushed
toward the upper-right, lowering every lower-left count.)

**Definition 2.4 (Product Bruhat order).**
On pairs $(p_1, p_2), (q_1, q_2) \in S_n \times S_n$ the **componentwise**
(product) order is
$$
(p_1, p_2) \le (q_1, q_2) \quad\Longleftrightarrow\quad p_1 \le q_1 \ \text{and}\ p_2 \le q_2.
$$

**Definition 2.5 (Two-projection map).**
The map $\varphi : S_n \to S_n \times S_n$, $\varphi(w) = (w, w^{-1})$, is the
combinatorial shadow of the two projections of a product of flag manifolds:
one factor records $w$, the other its inverse.

---

## 3. Inversion invariance via the transpose identity

The first structural fact is that inversion acts on rank matrices by
transposition.

**Theorem 3.1 (Transpose identity).**
For every $w \in S_n$ and all $i, j$,
$$
\operatorname{rk}_{w^{-1}}(i, j) = \operatorname{rk}_{w}(j, i).
$$

*Proof sketch.* Both sides count lattice points of the permutation graph in a
rectangular window, read along different axes. Explicitly,
$$
\operatorname{rk}_{w^{-1}}(i, j) = \#\{ k \le i : w^{-1}(k) \le j \}.
$$
The bijection $k \mapsto w^{-1}(k)$ sends the counted set to
$\{ m \le j : w(m) \le i \}$, because $k \le i$ and $w^{-1}(k) = m \le j$ is
equivalent to $m \le j$ and $w(m) = k \le i$. The cardinality of the latter
set is exactly $\operatorname{rk}_w(j, i)$. Since $w^{-1}$ is a bijection, the
count is preserved, giving the identity. $\qquad\blacksquare$

**Theorem 3.2 (Inversion invariance).**
For all $u, v \in S_n$,
$$
u \le v \quad\Longleftrightarrow\quad u^{-1} \le v^{-1}.
$$

*Proof sketch.* Suppose $u \le v$, i.e. $\operatorname{rk}_v(i,j) \le
\operatorname{rk}_u(i,j)$ for all $i, j$. For any $i, j$, applying the
transpose identity twice,
$$
\operatorname{rk}_{v^{-1}}(i, j) = \operatorname{rk}_{v}(j, i)
\le \operatorname{rk}_{u}(j, i) = \operatorname{rk}_{u^{-1}}(i, j),
$$
so $u^{-1} \le v^{-1}$. The converse is identical since $(w^{-1})^{-1} = w$.
$\qquad\blacksquare$

**Corollary 3.3.**
The two-projection map $\varphi(w) = (w, w^{-1})$ is order-preserving and
order-reflecting from $(S_n, \le)$ into the product order: $u \le v$ if and
only if $\varphi(u) \le \varphi(v)$. In particular $\varphi$ is an **order
embedding**.

*Proof sketch.* By definition $\varphi(u) \le \varphi(v)$ means $u \le v$ and
$u^{-1} \le v^{-1}$. By Theorem 3.2 the two conjuncts are equivalent, and
each is equivalent to $u \le v$. $\qquad\blacksquare$

---

## 4. Antisymmetry: the rank matrix determines the permutation

**Theorem 4.1 (Rank rigidity / antisymmetry).**
If $u \le v$ and $v \le u$ then $u = v$. Equivalently, if
$\operatorname{rk}_u(i,j) = \operatorname{rk}_v(i,j)$ for all $i, j$, then
$u = v$.

*Proof sketch.* From $u \le v$ and $v \le u$ we get equality of all rank
counts. Introduce the strict counts
$$
c^{<}_w(i, j) = \#\{ k < i : w(k) \le j \},
\qquad
c^{\le}_w(i, j) = \operatorname{rk}_w(i, j).
$$
Equality of the full (weak) counts $c^{\le}_u = c^{\le}_v$ propagates to the
strict counts $c^{<}_u = c^{<}_v$ by shifting the row index down by one (and
handling the boundary row $i = 1$, where the strict count is $0$). The
difference across a single row,
$$
c^{\le}_w(i, j) - c^{<}_w(i, j) = \mathbf{1}[\, w(i) \le j \,],
$$
is the indicator that position $i$ maps to a value $\le j$. Since this
indicator agrees for $u$ and $v$ at every $j$, and a monotone $0/1$ step
function determines the location of its jump, we recover $w(i)$ as the unique
$j$ where the indicator turns from $0$ to $1$. Hence $u(i) = v(i)$ for all
$i$, so $u = v$. $\qquad\blacksquare$

**Proposition 4.2 (Partial order).**
The Bruhat order is reflexive, transitive, and antisymmetric; it is a partial
order on $S_n$.

*Proof sketch.* Reflexivity is immediate: $\operatorname{rk}_w(i,j) \le
\operatorname{rk}_w(i,j)$. Transitivity chains the defining inequalities: if
every rank count of $b$ is $\le$ that of $a$, and every rank count of $c$ is
$\le$ that of $b$, then every rank count of $c$ is $\le$ that of $a$.
Antisymmetry is Theorem 4.1. $\qquad\blacksquare$

---

## 5. Extremes and the length characterisation

**Theorem 5.1 (Bottom element).**
The identity permutation is the minimum of the Bruhat order: $\mathrm{id} \le
w$ for all $w \in S_n$.

*Proof sketch.* For the identity, $\operatorname{rk}_{\mathrm{id}}(i,j) =
\#\{ k \le i : k \le j\} = \min(i, j)$, which is the **largest possible**
value of any rank count (no permutation can place more than $\min(i,j)$ points
in the lower-left $i \times j$ window). Hence $\operatorname{rk}_w(i,j) \le
\operatorname{rk}_{\mathrm{id}}(i,j)$ for all $w$, i.e. $\mathrm{id} \le w$.
$\qquad\blacksquare$

**Theorem 5.2 (Top element).**
The order-reversing permutation $w_0 : k \mapsto n + 1 - k$ is the maximum:
$w \le w_0$ for all $w \in S_n$.

*Proof sketch.* One computes $\operatorname{rk}_{w_0}(i,j) = \max(0,\, i + j -
n)$, which is the **smallest possible** value of any rank count consistent
with the marginals (a lower bound forced by counting how many points must lie
in the window). Hence $\operatorname{rk}_{w_0}(i,j) \le \operatorname{rk}_w(i,j)$
for all $w$, i.e. $w \le w_0$. $\qquad\blacksquare$

**Theorem 5.3 (Minimum = length zero).**
A permutation is the Bruhat-minimum if and only if it is inversion-free:
$w = \mathrm{id}$ iff $\ell(w) = 0$.

*Proof sketch.* If $\ell(w) = 0$ there are no pairs $i < j$ with $w(i) > w(j)$,
so $w$ is strictly increasing, hence the identity. Conversely $\ell(\mathrm{id})
= 0$ since the identity is increasing. Combined with Theorem 5.1, the unique
inversion-free permutation is exactly the bottom element, linking the rank
criterion to the inversion statistic. $\qquad\blacksquare$

---

## 6. The product order and the headline correspondence

**Proposition 6.1 (Product order structure).**
The product Bruhat order on $S_n \times S_n$ is a partial order. Its minimum
is $(\mathrm{id}, \mathrm{id})$ and its maximum is $(w_0, w_0)$.

*Proof sketch.* Componentwise reflexivity, transitivity, and antisymmetry
follow coordinatewise from Proposition 4.2; a pair is $\le$-comparable in each
coordinate, and antisymmetry in each coordinate forces equality of pairs. The
extremes are the pairs of extremes from Theorems 5.1–5.2. $\qquad\blacksquare$

**Theorem 6.2 (Closure = product Bruhat order).**
For the two-projection parametrisation $\varphi(w) = (w, w^{-1})$,
$$
u \le v \quad\Longleftrightarrow\quad \varphi(u) \le \varphi(v)
\quad\Longleftrightarrow\quad (u, u^{-1}) \le (v, v^{-1}) \ \text{ componentwise.}
$$
Consequently, the Bruhat relation on orbit parameters coincides with the
restriction of the product Bruhat order to the image of $\varphi$, which is
the order-theoretic statement of "Bruhat order preserves closure relations
for orbit strata."

*Proof sketch.* This is Corollary 3.3: $\varphi(u) \le \varphi(v)$ unpacks to
$u \le v$ and $u^{-1} \le v^{-1}$, and by inversion invariance (Theorem 3.2)
the second conjunct is equivalent to the first. Thus the componentwise
comparison on the image of $\varphi$ is exactly the single Bruhat comparison
$u \le v$, and $\varphi$ transports the order faithfully. $\qquad\blacksquare$

**Remark 6.3 (Geometric reading).**
Under the parametrisation of orbit strata by pairs of Weyl-group elements,
$\mathcal{O}_1 \subseteq \overline{\mathcal{O}_2}$ if and only if the labels
compare componentwise in the product Bruhat order. Theorem 6.2 certifies the
combinatorial half of this equivalence—the half that turns a continuous
closure question into a finite rank-count comparison—without invoking any
geometry.

---

## 7. Algorithms

All results are effective. We record three algorithms of increasing scope.

**Algorithm A (Rank matrix).** Given $w$, compute
$\operatorname{rk}_w(i,j)$ for all $i, j$ in $O(n^2)$ time by prefix sums:
process positions in increasing order, maintaining a running $0/1$ mark of
which values have appeared, and accumulate prefix counts over values. The
full $n \times n$ rank matrix is produced in $O(n^2)$.

**Algorithm B (Bruhat comparison).** To test $u \le v$, compute both rank
matrices and check $\operatorname{rk}_v(i,j) \le \operatorname{rk}_u(i,j)$ for
all $n^2$ entries. Total cost $O(n^2)$.

**Algorithm C (Closure test on pairs).** To test
$(u_1, v_1) \le (u_2, v_2)$ in the product order, run Algorithm B on each
coordinate; equivalently, by Theorem 6.2, for image pairs $(w, w^{-1})$ it
suffices to run a single Bruhat comparison $u \le v$. Cost $O(n^2)$.

By antisymmetry (Theorem 4.1), Algorithm A is invertible: the rank matrix can
be decoded back to $w$ by locating, in each row, the unique value at which the
weak-minus-strict indicator jumps from $0$ to $1$.

---

## 8. Applications

**Schubert geometry.** Closure relations of Schubert cells control the
incidence structure of Schubert varieties, their singularities, and the
combinatorics of their cohomology classes. A rank-count decision procedure
makes these relations computable in quadratic time.

**Representation theory.** $B$-orbits on products of flag manifolds appear in
the study of Harish-Chandra modules, character sheaves, and intertwining
structures; the product Bruhat order organises the associated strata.

**Combinatorics of matrices.** The rank matrix is precisely a matrix of
"lower-left" rank counts; the Bruhat order is then domination of such
matrices. This connects orbit closures to well-studied questions on
$0/1$-matrices, contingency tables, and the theory of rank functions.

**Sorting and networks.** The length statistic counts inversions, the minimal
number of adjacent swaps to sort; covering relations in the Bruhat order model
single-swap moves, tying orbit geometry to the analysis of sorting processes.

---

## 9. Discussion and future work

We have established that the Ehresmann rank criterion is a genuine partial
order (rank rigidity), that it is invariant under inversion via the transpose
identity, that it possesses explicit extremes, and that the two-projection map
embeds it order-faithfully into the product Bruhat order—precisely the
algebraic content of the closure-order statement for orbit strata. Building on
this, we propose:

1. **Additive grading of the closure order.** For the two-projection
   parametrisation, $\mathcal{O}_1 \subseteq \overline{\mathcal{O}_2}$ should
   hold if and only if the pairs compare componentwise **and** the codimension
   of a stratum equals the sum of the two Coxeter lengths of its parameters.
   The transpose identity makes both projections carry compatible,
   additively-graded orders, bringing this refinement within reach.

2. **Strict length monotonicity on covers.** If $u < v$ then $\ell(u) <
   \ell(v)$, and every covering relation $u \lessdot v$ increases length by
   exactly one. The rank matrix changes by a controlled amount across a single
   transposition, so length gaps telescope along saturated chains.

3. **Self-duality via $w \mapsto w_0 w$.** Multiplication by the reversal
   $w_0$ should be an order-reversing involution, making the product orbit
   poset self-dual: the closure poset is anti-isomorphic to itself. With the
   identity and reversal pinned as the extremes, this involution swapping them
   is the natural next symmetry.

4. **Rank-matrix rigidity of the whole lattice.** Two strata coincide iff
   their rank matrices agree entrywise, and the closure lattice embeds
   order-preservingly into the lattice of entrywise matrix domination.

---

## References

The Bruhat order and the Ehresmann rank criterion are classical; standard
treatments appear in the combinatorics-of-Coxeter-groups and
Schubert-calculus literature. This paper is self-contained: all statements
are proved from the rank criterion above.
