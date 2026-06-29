# Markov Bases for Contingency Tables: A Complete Connectivity Proof for the Two-Way Independence Model

## Abstract

We present a self-contained development of the **Fundamental Theorem of Markov
Bases** for the two-way independence model on $m \times n$ integer contingency
tables. The independence model fixes the two families of one-dimensional margins
(all row sums and all column sums); a *fiber* of the model is the set of
non-negative integer tables sharing a prescribed pair of margins. We prove that
the classical family of **basic $2 \times 2$ swap moves**

$$
B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}, \qquad i \neq i',\ j \neq j',
$$

forms a *Markov basis*: any two tables in the same fiber are connected by a walk
of basic moves that never leaves the non-negative orthant. The argument is a
constructive distance-reduction proof built on an $\ell^1$ potential function and
a three-stage sign-pattern pigeonhole. We isolate the structural lemmas — margin
invariance, the sign-pattern existence lemma, the local distance-decrease
estimate, and a strong induction on $\ell^1$ distance — and show that the
reachability relation is a genuine equivalence relation whose classes are exactly
the fibers. The proof is fully constructive and yields a polynomial-time
algorithm for connecting two tables, which we describe and analyze. We close with
the relationship to the companion no-three-way interaction model and a discussion
of sharp diameter bounds and the algebraic (ideal-generation) half of the
theorem.

**Keywords.** Algebraic statistics; Markov basis; contingency table; independence
model; transportation polytope; lattice walk; Diaconis–Sturmfels; Markov chain
Monte Carlo.

---

## 1. Introduction

### 1.1 Motivation

A two-way contingency table records joint counts of two categorical variables.
Given an $m \times n$ table $u$ with non-negative integer entries, the
fundamental inferential question is whether the row variable and the column
variable are statistically independent. The classical test fixes the *sufficient
statistics* of the independence model — the row margins and column margins — and
asks how the observed table compares to the conditional distribution of tables
with those same margins. When cell counts are small or the table is sparse, the
asymptotic $\chi^2$ approximation is unreliable, and one instead performs an
*exact* conditional test by sampling from the fiber of tables with the observed
margins.

Sampling requires a connected, irreducible Markov chain on the fiber. The
landmark observation of Diaconis and Sturmfels is that such a chain can be built
from a finite set of integer *moves* — a **Markov basis** — which is, equivalently,
a generating set of a toric ideal associated to the model. The defining property
of a Markov basis is **fiber connectivity**: the moves connect every fiber while
preserving non-negativity. This paper formalizes and proves that property for the
independence model with the smallest natural move set, the basic $2 \times 2$
swaps.

### 1.2 Contributions

1. A precise lattice-walk formulation of fiber connectivity for the independence
   model on general $m \times n$ tables, with margins, moves, legality, and
   connectivity all defined explicitly (Section 2).
2. A complete, constructive proof that the basic $2 \times 2$ moves connect every
   fiber (Theorem 4.1), decomposed into four reusable lemmas:
   - **margin invariance** of basic moves (Lemma 3.1),
   - the **sign-pattern pigeonhole** existence lemma (Lemma 3.3),
   - the **local distance-decrease** estimate (Lemma 3.4), and
   - a **strong induction on $\ell^1$ distance** (Lemma 3.5).
3. A proof that the move relation is symmetric, so reachability is an equivalence
   relation whose classes are the fibers (Section 4.2).
4. An explicit connecting algorithm with complexity analysis (Section 5) and a
   comparison to the companion no-three-way interaction model (Section 6).

---

## 2. Definitions

Throughout, $m, n$ are fixed positive integers, and indices range over
$\{0, \dots, m-1\}$ and $\{0, \dots, n-1\}$.

**Definition 2.1 (Table).** An $m \times n$ *integer contingency table* is a
function
$$
u : \{0,\dots,m-1\} \times \{0,\dots,n-1\} \to \mathbb{Z},
$$
written $u_{i,j}$ or $u\,i\,j$. The set of all such tables is a free
$\mathbb{Z}$-module of rank $mn$.

**Definition 2.2 (Margins).** The *row margins* and *column margins* of $u$ are
$$
\operatorname{rowSum}(u)_i = \sum_{j} u_{i,j}, \qquad
\operatorname{colSum}(u)_j = \sum_{i} u_{i,j}.
$$

**Definition 2.3 (Same fiber / SameMargins).** Two tables $u, v$ lie in the same
fiber of the independence model, written $\operatorname{SameMargins}(u,v)$, iff
$$
\bigl(\forall i,\ \operatorname{rowSum}(u)_i = \operatorname{rowSum}(v)_i\bigr)
\ \wedge\
\bigl(\forall j,\ \operatorname{colSum}(u)_j = \operatorname{colSum}(v)_j\bigr).
$$
The margin map $u \mapsto (\operatorname{rowSum}(u), \operatorname{colSum}(u))$ is
$\mathbb{Z}$-linear, so $\operatorname{SameMargins}(u,v)$ holds iff $u - v$ lies
in its kernel, the **lattice of moves**.

**Definition 2.4 (Basic move).** For rows $i \neq i'$ and columns $j \neq j'$,
the *basic $2 \times 2$ swap move* is
$$
B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'},
$$
where $e_{a,b}$ is the indicator table with a single $1$ in cell $(a,b)$. As a
$2 \times 2$ pattern restricted to the affected cells,
$$
\begin{pmatrix} B_{i,j} & B_{i,j'} \\ B_{i',j} & B_{i',j'} \end{pmatrix}
= \begin{pmatrix} -1 & +1 \\ +1 & -1 \end{pmatrix}.
$$

**Definition 2.5 (Non-negativity).** A table $u$ is *non-negative*,
$\operatorname{Nonneg}(u)$, iff $u_{i,j} \geq 0$ for all $i,j$. A *fiber* of the
independence model is a set of non-negative tables sharing a fixed pair of
margins.

**Definition 2.6 (Legal step).** There is a *step* from $u$ to $v$, written
$\operatorname{Step}(u,v)$, iff $u$ and $v$ are both non-negative and there exist
$i \neq i'$, $j \neq j'$ with $v = u + B(i,i',j,j')$. (The reverse move is the
basic move with $i, i'$ swapped, so steps come in inverse pairs.)

**Definition 2.7 (Connectivity).** $\operatorname{Connected}(u,v)$ is the
reflexive–transitive closure of $\operatorname{Step}$: there is a finite walk
$$
u = w_0 \to w_1 \to \cdots \to w_\ell = v
$$
with $\operatorname{Step}(w_{t}, w_{t+1})$ for each $t$, every $w_t$ non-negative.

**Definition 2.8 ($\ell^1$ distance).** The *$\ell^1$ distance* between tables is
$$
D(u,v) = \sum_{(i,j)} \bigl| u_{i,j} - v_{i,j} \bigr| \ \in \mathbb{Z}_{\geq 0}.
$$
It is the total number of unit cell-discrepancies between the two tables.

---

## 3. Structural lemmas

### 3.1 Basic moves are legal

**Lemma 3.1 (Margin invariance).** For any table $u$ and any $i \neq i'$,
$j \neq j'$,
$$
\operatorname{SameMargins}\bigl(u,\ u + B(i,i',j,j')\bigr).
$$

*Proof sketch.* Linearity of the margin map reduces the claim to showing that
every row sum and every column sum of $B(i,i',j,j')$ is zero. Row $i$ of $B$ has
a $+1$ in column $j'$ and a $-1$ in column $j$ (and zeros elsewhere), summing to
$0$; row $i'$ has a $+1$ in column $j$ and a $-1$ in column $j'$, summing to $0$;
all other rows are identically zero. The hypothesis $j \neq j'$ ensures the two
nonzero entries in each affected row are distinct cells, so they genuinely
cancel. The column sums vanish symmetrically, using $i \neq i'$. Splitting the
margin of $u + B$ as the margin of $u$ plus the margin of $B$ via additivity of
finite sums, and observing the latter is zero, completes the proof. $\qquad\square$

A direct consequence is that every walk of basic moves stays within a single
fiber: connectivity respects margins.

### 3.2 The distance is faithful

**Lemma 3.2 (Distance non-degeneracy).** $D(u,v) = 0$ if and only if $u = v$.

*Proof sketch.* $D$ is a finite sum of non-negative integers $|u_{i,j} - v_{i,j}|$.
A sum of non-negative terms is zero iff every term is zero, i.e. iff
$u_{i,j} = v_{i,j}$ for all $(i,j)$, which by functional extensionality is
$u = v$. $\qquad\square$

This makes $D$ a legitimate potential function: it certifies arrival precisely
when it reaches its floor.

### 3.3 The sign-pattern pigeonhole

This is the structural heart of the theorem.

**Lemma 3.3 (Sign-pattern pigeonhole).** If $\operatorname{SameMargins}(u,v)$ and
$u \neq v$, then there exist rows $i \neq i'$ and columns $j \neq j'$ with
$$
v_{i,j} < u_{i,j}, \qquad u_{i,j'} < v_{i,j'}, \qquad v_{i',j'} < u_{i',j'}.
$$

That is, $u$ overshoots $v$ at the two cells $(i,j)$ and $(i',j')$ and
undershoots it at $(i,j')$ — exactly the sign pattern that a basic move on the
frame $\{i,i'\} \times \{j,j'\}$ can correct.

*Proof sketch.* Write $d = u - v$. Because the margins agree, $\sum_{i,j} d_{i,j}
= 0$, yet $d \not\equiv 0$; a collection of integers summing to zero with a
nonzero member must contain a strictly positive entry. Fix a cell $(i,j)$ with
$d_{i,j} > 0$, i.e. $v_{i,j} < u_{i,j}$. (Concretely: if no cell had $u > v$, then
since margins agree pointwise comparison forces $u = v$, a contradiction.)

Next, the row margin equality $\operatorname{rowSum}(u)_i =
\operatorname{rowSum}(v)_i$ gives $\sum_{j''} d_{i,j''} = 0$. Since one term
$d_{i,j} > 0$ is positive, some other term in row $i$ must be negative: there is a
column $j'$ with $d_{i,j'} < 0$, i.e. $u_{i,j'} < v_{i,j'}$.

Finally, the column margin equality for column $j'$ gives $\sum_{i''} d_{i'',j'} =
0$. Since $d_{i,j'} < 0$, some other term in column $j'$ must be positive: there
is a row $i'$ with $d_{i',j'} > 0$, i.e. $v_{i',j'} < u_{i',j'}$.

Distinctness of the indices is automatic from the opposite signs: if $i = i'$
then cell $(i,j')$ would satisfy both $d_{i,j'} < 0$ and $d_{i,j'} > 0$, which is
impossible; likewise $j \neq j'$ since $(i,j)$ has $d > 0$ and $(i,j')$ has
$d < 0$. Thus $(i,i',j,j')$ is a valid frame. $\qquad\square$

The three pigeonhole steps — **all-cells sum $\to$ row sum $\to$ column sum** —
are the engine of the proof, and the fact that distinctness *falls out of the
signs* rather than needing a separate hypothesis is what makes the move always
admissible.

### 3.4 The local distance-decrease estimate

**Lemma 3.4 (Distance decrease).** With $(i,i',j,j')$ from Lemma 3.3, set
$u' = u + B(i,i',j,j')$. Then $u'$ is non-negative whenever $u$ is, and
$$
D(u', v) < D(u, v).
$$

*Proof sketch.* The move alters only the four cells of the frame. Outside the
frame, $|u' - v| = |u - v|$, so those terms cancel in the difference $D(u,v) -
D(u',v)$. Inside the frame, the basic move subtracts $1$ from $u_{i,j}$ and
$u_{i',j'}$ and adds $1$ to $u_{i,j'}$ and $u_{i',j'}$ — precisely, recalling the
sign pattern $\begin{psmallmatrix} -1 & +1 \\ +1 & -1 \end{psmallmatrix}$, it
*decreases* $u$ at $(i,j)$ and $(i',j')$ and *increases* it at $(i,j')$ and
$(i',j)$.

By Lemma 3.3, $u$ was strictly above $v$ at $(i,j)$ and $(i',j')$ and strictly
below $v$ at $(i,j')$. Moving $u$ down at the two overshooting cells and up at the
undershooting cell each reduces the corresponding $|u-v|$ term by exactly $1$ (no
overshoot occurs because each gap was at least $1$). The fourth cell $(i',j)$ may
move either way, changing its term by at most $1$. Summing, the three guaranteed
unit reductions outweigh the at-most-one possible increase, so the net change is
strictly negative: $D$ drops by at least $1$ (in fact by $2$ or $4$, see Section
7). Non-negativity is preserved because the two decremented cells $u_{i,j},
u_{i',j'}$ were strictly larger than the corresponding non-negative $v$ values, so
they were at least $1$ before the move. $\qquad\square$

### 3.5 Induction on distance

**Lemma 3.5 (Connectivity from a distance bound).** For every $N$, if
$\operatorname{Nonneg}(u)$, $\operatorname{Nonneg}(v)$,
$\operatorname{SameMargins}(u,v)$, and $D(u,v) \leq N$, then
$\operatorname{Connected}(u,v)$.

*Proof sketch.* Strong induction on $N$. If $D(u,v) = 0$ then $u = v$ by Lemma
3.2 and connectivity holds by reflexivity. Otherwise $u \neq v$; Lemmas 3.3 and
3.4 produce a single legal step $u \to u'$ with $u'$ non-negative,
$\operatorname{SameMargins}(u',v)$ (Lemma 3.1, since margins are preserved), and
$D(u',v) < D(u,v) \leq N$. The induction hypothesis applies to $u'$ and $v$,
giving $\operatorname{Connected}(u',v)$; prepending the step $u \to u'$ yields
$\operatorname{Connected}(u,v)$. $\qquad\square$

The packaging of Lemmas 3.3–3.4 into a single "always one good move" statement is
sometimes recorded separately as *exists\_step*: every non-equal fiber pair admits
a legal, distance-decreasing move. Lemma 3.5 is then a clean induction over that
oracle.

---

## 4. Main results

### 4.1 The Fundamental Theorem

**Theorem 4.1 (Fundamental Theorem of Markov Bases, independence model).** Let
$u, v$ be non-negative $m \times n$ integer tables with the same row sums and the
same column sums. Then $\operatorname{Connected}(u,v)$: there is a walk of legal
basic $2 \times 2$ moves from $u$ to $v$ that stays non-negative at every step.
Equivalently, the family $\{B(i,i',j,j') : i \neq i',\ j \neq j'\}$ is a Markov
basis for the two-way independence model.

*Proof.* Apply Lemma 3.5 with $N = D(u,v)$, which is a finite non-negative
integer. $\qquad\square$

### 4.2 Fibers are equivalence classes

**Lemma 4.2 (Step symmetry).** If $\operatorname{Step}(u,v)$ then
$\operatorname{Step}(v,u)$.

*Proof sketch.* If $v = u + B(i,i',j,j')$ then $u = v + B(i',i,j,j')$, since
swapping the two rows negates the basic move: $B(i',i,j,j') = -B(i,i',j,j')$.
Both $u$ and $v$ are non-negative by hypothesis, so the reverse step is also
legal. $\qquad\square$

**Corollary 4.3 (Connectivity is symmetric).** If $\operatorname{Connected}(u,v)$
then $\operatorname{Connected}(v,u)$.

*Proof sketch.* Reverse the walk, applying Lemma 4.2 to each edge. $\qquad\square$

Since $\operatorname{Connected}$ is reflexive and transitive by construction
(reflexive–transitive closure) and symmetric by Corollary 4.3, it is an
**equivalence relation**. By Lemma 3.1 its classes refine the fibers, and by
Theorem 4.1 each fiber is contained in a single class; hence the equivalence
classes of $\operatorname{Connected}$ are *exactly* the fibers. The fibers are the
connected components of the table space under basic moves — no isolated tables,
no spurious merging.

---

## 5. Algorithms

The proof is constructive and translates directly into algorithms.

### 5.1 Connecting two tables

**Algorithm A (Distance-reduction connector).** Given non-negative $u, v$ in the
same fiber, repeatedly locate a sign-aligned $2 \times 2$ frame (Lemma 3.3),
apply the corresponding basic move, and recurse until $u = v$.

```
INPUT  u, v : non-negative m×n tables with SameMargins(u, v)
OUTPUT a list of basic moves transforming u into v
moves := []
while u ≠ v:
    d := u - v
    pick (i, j) with d[i][j] > 0            # all-cells sum is 0
    pick j' with d[i][j'] < 0               # row i sum is 0
    pick i' with d[i'][j'] > 0              # column j' sum is 0
    apply B(i, i', j, j') to u
    append (i, i', j, j') to moves
return moves
```

**Correctness.** Each iteration decreases $D(u,v)$ by at least one (Lemma 3.4)
and preserves non-negativity and margins, so the loop terminates in at most
$D(u,v)$ iterations at the table $v$ (Lemma 3.2 and Theorem 4.1).

**Complexity.** The naive frame search scans the difference table in $O(mn)$ time;
with at most $D(u,v) \leq \tfrac12 \sum_{i,j}(u_{i,j}+v_{i,j})$ iterations, the
total is $O(mn \cdot D(u,v))$. Maintaining lists of positive and negative cells
per row and column reduces the per-iteration cost to $O(1)$ amortized after an
$O(mn)$ setup, giving $O(mn + D(u,v))$.

### 5.2 Random walk on a fiber (MCMC sampler)

**Algorithm B (Metropolis–Hastings on the fiber).** To sample (approximately)
uniformly from a fiber, run a random walk: at each step pick rows $i \neq i'$ and
columns $j \neq j'$ uniformly, choose a sign $s \in \{+1,-1\}$, and propose
$u \mapsto u + s\,B(i,i',j,j')$. Accept the proposal iff it remains non-negative;
otherwise stay. Because the basic moves connect the fiber (Theorem 4.1) and come
in inverse pairs (Lemma 4.2), the resulting chain is irreducible and reversible
with the uniform stationary distribution; reweighting yields any desired
exponential-family target (e.g. the hypergeometric conditional distribution used
in the exact test of independence).

---

## 6. Applications

### 6.1 Exact conditional testing of independence

The motivating application is **Fisher-style exact testing** generalized beyond
$2 \times 2$ tables. Given an observed table, the exact conditional $p$-value of a
test statistic (e.g. the Pearson $\chi^2$ statistic, or the likelihood-ratio
statistic) is its tail probability under the uniform/hypergeometric distribution
on the fiber of tables with the observed margins. For all but the smallest tables,
this fiber is too large to enumerate, so one estimates the $p$-value by the MCMC
sampler of Algorithm B. Theorem 4.1 is the theoretical guarantee that the sampler
is irreducible: without fiber connectivity, the chain could be trapped in a
sub-collection of tables and report an invalid $p$-value.

### 6.2 Disclosure limitation and table perturbation

Statistical agencies releasing aggregated tables must perturb cell counts to
protect privacy while preserving published margins. The basic moves are exactly
the margin-preserving, non-negativity-preserving perturbations, and Theorem 4.1
guarantees the full space of margin-consistent tables is reachable — the
admissible perturbation space is a single connected component.

### 6.3 Transportation polytopes

The fiber of a fixed margin pair is the set of lattice points of a
**transportation polytope** (the polytope of non-negative matrices with given row
and column sums). Theorem 4.1 says these lattice points form a connected graph
under $2 \times 2$ swaps — a discrete analogue of the polytope's connectedness,
and the combinatorial substrate for lattice-point counting and sampling.

---

## 7. Discussion and sharp bounds

The proof guarantees only that each move decreases $D$ by *at least* one, which
suffices for termination. In fact the sign-aligned move decreases $D$ by exactly
$2$ at the three sign-controlled cells (each contributes a unit reduction at two
of them and the third is the undershoot), and possibly by $4$ if the fourth cell
also happens to be aligned. This points to a sharp diameter result: because the
margins force $\sum_{i,j}(u_{i,j}-v_{i,j}) = 0$, the $\ell^1$ distance equals
twice the total positive part,
$$
D(u,v) = 2 \sum_{i,j} \max(u_{i,j} - v_{i,j},\, 0),
$$
and a move can be chosen to retire two units of positive part at once. This yields
the conjectured exact graph diameter of $D(u,v)/2$, matching a $1$-Lipschitz
potential lower bound. The companion no-three-way model exhibits the same
phenomenon in its purest form: there the graph distance between two tables equals
the absolute difference of a *single corner cell*, because that model's move
lattice is rank one.

The connectivity established here is the **combinatorial half** of the Fundamental
Theorem. The **algebraic half** — that the basic moves $\mathbb{Z}$-span the
entire move lattice (the kernel of the margin map), not merely connect fibers — is
a separate statement, equivalent to the toric ideal of the independence model
being generated by the $2 \times 2$ minors. Together they say $\{B(i,i',j,j')\}$
is a Markov basis in both senses: a generating set of the lattice and a connector
of every fiber.

---

## 8. Relationship to the no-three-way interaction model

The independence model is the simplest member of a family. Its three-dimensional
analogue, the **no-three-way interaction model** on $2 \times 2 \times 2$ tables,
fixes *all three* families of two-dimensional margins. Remarkably, its move
lattice is **rank one**: it is generated by the single degree-$4$ alternating move
$M_3(i,j,k) = (-1)^{i+j+k}$, which touches all eight cells. There, two tables with
the same two-way margins differ by exactly an integer multiple of $M_3$, the
multiple being the difference of their corner cells, and the graph distance is
*exactly* that corner difference. The contrast is instructive: the independence
model needs the *full family* of $2 \times 2$ swaps and a genuine
distance-reduction argument, whereas the no-three-way model collapses to a single
generator and a one-dimensional interval walk. The present paper supplies the
distance-reduction machinery that the higher, multi-generator models require.

---

## 9. Future work

- **Exact diameter.** Promote the "$D$ decreases by at least one" estimate to
  "$D$ decreases by exactly two," and pair it with a $1$-Lipschitz potential lower
  bound, to prove the graph diameter is exactly $D(u,v)/2$.
- **Lattice spanning.** Prove the algebraic half: the basic moves
  $\mathbb{Z}$-span the kernel of the margin map (equivalently, the toric ideal is
  generated by $2 \times 2$ minors).
- **Higher-dimensional and hierarchical models.** Extend the distance-reduction
  framework to $2 \times 2 \times n$ no-three-way models (multi-generator Markov
  bases) and to general hierarchical log-linear models, where the relevant moves
  are no longer simple swaps.
- **Mixing times.** Quantify the convergence rate of the Algorithm B sampler on
  transportation-polytope fibers, connecting fiber geometry to MCMC efficiency.

---

## 10. Conclusion

We have given a complete, constructive proof that the basic $2 \times 2$ swap
moves connect every fiber of the two-way independence model on $m \times n$
contingency tables — the Fundamental Theorem of Markov Bases in its foundational
case. The proof rests on an $\ell^1$ potential, a three-stage sign-pattern
pigeonhole, a local distance-decrease estimate, and an induction on distance, and
it doubles as a polynomial-time connecting algorithm and the irreducibility
certificate for exact conditional inference. The reachability relation is an
equivalence relation whose classes are exactly the fibers, completing the picture
of the table space as a disjoint union of connected components, each woven
together by the smallest possible move.
