# The Constraint-Satisfaction Threshold of Sudoku: A Sharp Phase Transition Across Order, Enumeration, and Colouring

## Abstract

Sudoku is the archetypal *constraint-satisfaction problem* (CSP): every row,
column, and box imposes a single combinatorial demand, the *AllDifferent*
constraint, requiring a block of $m$ cells to receive pairwise distinct symbols
from an alphabet of size $k$. We isolate this atomic constraint and prove that its
satisfiability undergoes a **sharp phase transition** as the block size $m$ crosses
the alphabet size $k$: the constraint is satisfiable if and only if $m \le k$, and
the transition occurs at the single critical value $m_c(k) = k+1$. We then show
that this one threshold is simultaneously an **order-theoretic** phenomenon (the
satisfiable region is exactly the down-set $[0,k]$, forcing a single jump), an
**enumerative / statistical-mechanical** phenomenon (the partition function counting
proper assignments is the falling factorial $k^{\underline{m}}$, strictly positive
in the satisfiable phase and identically zero beyond criticality), and a
**graph-theoretic** phenomenon (an AllDifferent block is the complete graph $K_m$,
so satisfiability equals $k$-colourability). For an order-$n$ Sudoku the grid is
$n^2 \times n^2$ and every line contains exactly $n^2$ cells drawn from $n^2$
symbols: the puzzle sits precisely at criticality ($m = k = n^2$), which we argue is
the structural reason Sudoku is a hard, critically-constrained problem. Finally we
exhibit an explicit simultaneous solution of the row-and-column relaxation — the
cyclic Latin square $L(i,j) = i+j$ over $\mathbb{Z}/N\mathbb{Z}$ — and note that it
provably fails the box constraints, isolating the boxes as genuinely independent
demands.

**Keywords:** constraint satisfaction, AllDifferent constraint, phase transition,
falling factorial, partition function, Latin square, graph colouring, Sudoku,
pigeonhole principle.

---

## 1. Introduction

A *constraint-satisfaction problem* (CSP) asks whether variables can be assigned
values from finite domains so that a family of constraints is jointly satisfied.
CSPs are the common substrate of graph colouring, scheduling, Boolean satisfiability,
and countless industrial optimisation problems. A recurring empirical theme across
these domains is the existence of *phase transitions*: as a control parameter (clause
density, edge density, constraint tightness) crosses a critical value, the probability
that a random instance is satisfiable drops abruptly from near $1$ to near $0$, and the
computationally hardest instances congregate at the boundary.

Sudoku is a beloved, finite, and fully deterministic member of this family. An order-$n$
Sudoku is played on an $n^2 \times n^2$ grid partitioned into $n^2$ boxes of size
$n \times n$; the classic puzzle is order $n = 3$. The rules decompose into a single
repeated demand: each row, each column, and each box must contain each of the $n^2$
symbols exactly once — equivalently, its cells must be pairwise distinct. This atomic
demand is the **AllDifferent** constraint.

This paper isolates the AllDifferent atom, establishes that it exhibits a *sharp*
satisfiability threshold, and demonstrates that the identical threshold surfaces in
three distinct mathematical languages. We then specialise to Sudoku, showing that the
grid is engineered to sit *exactly* at criticality, and we exhibit an explicit
group-theoretic witness for the row-and-column relaxation.

### Contributions

1. **The pigeonhole equivalence** (Theorem 3.1): an AllDifferent block of $m$ cells is
   satisfiable over $k$ symbols if and only if $m \le k$, together with its monotonicity
   corollaries.
2. **The sharp transition** (Theorems 4.1–4.4): the critical value is $m_c(k) = k+1$;
   the satisfiable region is the down-set $[0,k]$; and the critical value is *unique* —
   any location separating a satisfiable phase from an unsatisfiable point must equal
   $k+1$.
3. **The partition function** (Theorems 5.1–5.4): the number of proper assignments is
   the falling factorial $k^{\underline m}$; it is positive iff satisfiable, equals $0$
   beyond criticality, and equals $k!$ at criticality.
4. **The critical density** (Theorem 6.1): with $k > 0$, satisfiability is equivalent to
   constraint density $m/k \le 1$.
5. **Sudoku at criticality** (Theorems 7.1–7.3): every line of an order-$n$ Sudoku
   satisfies $m = k = n^2$, so it is satisfiable but one cell from infeasibility, with an
   explicit forced-collision certificate above threshold.
6. **The colouring bridge** (Theorems 8.1–8.2): satisfiability equals $k$-colourability
   of $K_m$, reproducing the same threshold.
7. **An explicit Latin square** (Theorem 9.1): $L(i,j) = i+j$ over $\mathbb{Z}/N\mathbb{Z}$
   simultaneously satisfies all rows and columns, with the honest caveat that it fails the
   box constraints.

---

## 2. Definitions

Throughout, $m$ denotes the number of cells in a block ("demands") and $k$ the size of
the symbol alphabet ("resources"). We write $[m] = \{0, 1, \ldots, m-1\}$ for the index
set of a block, realised concretely as the finite set of size $m$.

**Definition 2.1 (AllDifferent satisfiability).** A block of $m$ cells is *satisfiable*
over an alphabet of $k$ symbols, written $\mathrm{SAT}(m,k)$, if there exists an injective
assignment $f : [m] \to [k]$ mapping each cell to a symbol with no repeats:
$$\mathrm{SAT}(m,k) \iff \exists\, f : [m] \to [k],\ f \text{ injective}.$$

**Definition 2.2 (Critical cell count).** For a fixed alphabet size $k$, the *critical
cell count* is $m_c(k) = k+1$, the smallest block size at which satisfiability fails.

**Definition 2.3 (Partition function).** The *partition function* of the AllDifferent
atom is the number of proper (injective) assignments,
$$Z(m,k) = k^{\underline{m}} = k\,(k-1)\cdots(k-m+1) = \frac{k!}{(k-m)!}\quad (m \le k),$$
the falling factorial, with the convention $Z(m,k) = 0$ when $m > k$.

**Definition 2.4 (Constraint density).** For $k > 0$, the *constraint density* of a block
is $\rho(m,k) = m/k$, the number of demands per resource.

**Definition 2.5 (Cyclic Latin square).** Over the cyclic group $\mathbb{Z}/N\mathbb{Z}$
the *cyclic Latin square* is the filling $L(i,j) = i + j \pmod N$.

---

## 3. The pigeonhole equivalence

Every result in this paper funnels through one equivalence.

**Theorem 3.1 (Pigeonhole equivalence).**
$$\mathrm{SAT}(m,k) \iff m \le k.$$

*Proof.* ($\Rightarrow$) An injection $f : [m] \to [k]$ forces $|[m]| \le |[k]|$, i.e.
$m \le k$, by the counting bound for injective maps between finite sets. ($\Leftarrow$)
If $m \le k$, the inclusion $i \mapsto i$ (each index of $[m]$ lies in $[k]$ since
$i < m \le k$) is injective. $\qquad\blacksquare$

**Corollary 3.2 (Unsatisfiability).** $\neg\,\mathrm{SAT}(m,k) \iff k < m.$

**Corollary 3.3 (Antitone in cells).** If $m' \le m$ and $\mathrm{SAT}(m,k)$, then
$\mathrm{SAT}(m',k)$. Removing cells (constraints) cannot destroy satisfiability.

**Corollary 3.4 (Monotone in symbols).** If $k \le k'$ and $\mathrm{SAT}(m,k)$, then
$\mathrm{SAT}(m,k')$. Adding symbols (resources) cannot destroy satisfiability.

These two monotonicities are the structural seed of the sharp transition: satisfiability
depends on $m$ and $k$ only through their comparison, so the feasible region is a single
comparison half-space.

---

## 4. The sharp phase transition

**Theorem 4.1 (Subcritical phase).** If $m < m_c(k) = k+1$, then $\mathrm{SAT}(m,k)$.

*Proof.* $m < k+1$ means $m \le k$; apply Theorem 3.1. $\blacksquare$

**Theorem 4.2 (Supercritical phase).** If $m \ge m_c(k)$, then $\neg\,\mathrm{SAT}(m,k)$.

*Proof.* $m \ge k+1$ means $k < m$; apply Corollary 3.2. $\blacksquare$

**Theorem 4.3 (Down-set structure).** The satisfiable region is exactly the integer
interval
$$\{m : \mathrm{SAT}(m,k)\} = \{0,1,\ldots,k\} = [0,k].$$

*Proof.* Immediate from Theorem 3.1: $\mathrm{SAT}(m,k)$ iff $m \le k$ iff
$m \in [0,k]$. $\blacksquare$

Because the feasible set is a *down-set* (closed under decreasing $m$) with a hard
ceiling, the transition is a single jump rather than a gradual slope. This is the
order-theoretic content of "sharpness".

**Theorem 4.4 (Uniqueness of the critical value).** Suppose $t$ separates a uniformly
satisfiable phase from an unsatisfiable point: for all $m < t$ we have $\mathrm{SAT}(m,k)$,
and $\neg\,\mathrm{SAT}(t,k)$. Then $t = m_c(k) = k+1$.

*Proof.* From $\neg\,\mathrm{SAT}(t,k)$ we get $k < t$, so $t \ge k+1$. If $t > k+1$ then
$k+1 < t$, whence $\mathrm{SAT}(k+1,k)$ by hypothesis, i.e. $k+1 \le k$, a contradiction.
Hence $t = k+1$. $\blacksquare$

Theorem 4.4 formalises that the transition is *well-defined and unique*: there is exactly
one location at which a monotone satisfiability boundary can sit.

---

## 5. The partition function (enumerative / statistical-mechanics view)

We now refine the yes/no question to a count, obtaining an order parameter that vanishes
continuously (in fact discontinuously, to exactly $0$) at the boundary.

**Theorem 5.1 (Positivity detects the phase).**
$$Z(m,k) > 0 \iff m \le k \iff \mathrm{SAT}(m,k).$$

*Proof.* The falling factorial $k^{\underline m} = \prod_{i=0}^{m-1}(k-i)$ is a product of
$m$ integer factors, all strictly positive precisely when $k - (m-1) \ge 1$, i.e.
$m \le k$; otherwise one factor is $0$. Combine with Theorem 3.1. $\blacksquare$

**Theorem 5.2 (Collapse above threshold).**
$$Z(m,k) = 0 \iff k < m.$$

*Proof.* Contrapositive of Theorem 5.1: $Z(m,k) = 0$ iff not $(0 < Z(m,k))$ iff not
$(m \le k)$ iff $k < m$. $\blacksquare$

The unsatisfiable phase has *no states*: the partition function is not merely small but
identically zero, the sharpest possible order-parameter collapse.

**Theorem 5.3 (Value at criticality).** $Z(k,k) = k!.$

*Proof.* $k^{\underline{k}} = k(k-1)\cdots 1 = k!$. $\blacksquare$

**Theorem 5.4 (One step past criticality).** $Z(k+1,k) = 0.$

*Proof.* The product $k^{\underline{k+1}}$ includes the factor $k - k = 0$. $\blacksquare$

Thus the partition function decreases from $k!$ (a fully packed but solvable block, with
maximal rigidity) to exactly $0$ as $m$ steps from $k$ to $k+1$. For a nine-cell Sudoku
line, $Z(9,9) = 9! = 362\,880$ and $Z(10,9) = 0$.

---

## 6. Density and the critical density $1$

**Theorem 6.1 (Critical density).** For $k > 0$,
$$\mathrm{SAT}(m,k) \iff \rho(m,k) = \frac{m}{k} \le 1.$$

*Proof.* By Theorem 3.1, $\mathrm{SAT}(m,k) \iff m \le k$. Since $k > 0$, dividing by $k$
gives $m/k \le 1$, and the step is reversible. $\blacksquare$

The critical density is therefore *exactly $1$*: one demand per resource. This casts the
transition in the language usual for random-CSP thresholds, where a density parameter
crosses a critical constant.

---

## 7. Specialisation to Sudoku: the grid sits at criticality

**Theorem 7.1 (Sudoku lines are critically satisfiable).** For every order $n$, an
$n^2 \times n^2$ Sudoku line — a row, column, or box holding $n^2$ cells over $n^2$
symbols — is satisfiable:
$$\mathrm{SAT}(n^2, n^2).$$

*Proof.* $n^2 \le n^2$; apply Theorem 3.1. Here $m = k = n^2$, the last (largest)
satisfiable value. $\blacksquare$

**Theorem 7.2 (One clue too many is fatal).** For every order $n$,
$$\neg\,\mathrm{SAT}(n^2 + 1,\ n^2).$$

*Proof.* $n^2 < n^2 + 1$; apply Corollary 3.2. $\blacksquare$

**Theorem 7.3 (Forced-collision certificate).** If $k < m$, then every assignment
$f : [m] \to [k]$ repeats a symbol: there exist distinct $i, j$ with $f(i) = f(j)$.

*Proof.* Since $|[k]| = k < m = |[m]|$, no map $[m] \to [k]$ can be injective (a
strict-cardinality pigeonhole), so some two distinct indices collide. $\blacksquare$

Theorems 7.1–7.3 pin Sudoku exactly on the boundary: each of its $3n^2$ lines (for order
$n$) is at $m = k = n^2$, solvable but with zero slack, and one extra forced symbol tips
any line over the cliff with an explicit collision witness. For classic $9\times 9$
Sudoku ($n = 3$): every line is $\mathrm{SAT}(9,9)$ but $\neg\,\mathrm{SAT}(10,9)$.

---

## 8. Graph-theoretic bridge: AllDifferent equals colouring $K_m$

Model an AllDifferent block as a graph: one vertex per cell, an edge between every pair
of cells (they must differ). This is the complete graph $K_m$. A proper $k$-colouring — an
assignment of $k$ colours with adjacent vertices differently coloured — is exactly an
injective symbol assignment.

**Theorem 8.1 (CSP $\Leftrightarrow$ colouring).** The complete graph $K_m$ is
$k$-colourable if and only if $\mathrm{SAT}(m,k)$.

*Proof.* ($\Rightarrow$) A proper $k$-colouring $C$ of $K_m$ assigns distinct colours to
any two distinct vertices (all are adjacent), hence $C$ is injective, witnessing
$\mathrm{SAT}(m,k)$. ($\Leftarrow$) An injective $f : [m] \to [k]$ is a proper colouring,
since adjacent (distinct) vertices receive distinct values. $\blacksquare$

**Theorem 8.2 (Chromatic threshold).**
$$K_m \text{ is } k\text{-colourable} \iff m \le k.$$

*Proof.* Combine Theorem 8.1 with Theorem 3.1. Equivalently, $\chi(K_m) = m$, so $K_m$ is
$k$-colourable iff $k \ge m$. $\blacksquare$

The chromatic number of the complete graph reproduces the pigeonhole threshold exactly:
all three languages — order, enumeration, colouring — are faces of the single inequality
$m \le k$.

---

## 9. An explicit simultaneous solution: the cyclic Latin square

Existence (Theorem 7.1) is non-constructive; we now give a closed-form witness for the
row-and-column relaxation of Sudoku.

**Theorem 9.1 (Cyclic Latin square).** For every $N \ge 1$, the filling
$L(i,j) = i + j$ over $\mathbb{Z}/N\mathbb{Z}$ makes every row and every column a
bijection: for each fixed $i$, the map $j \mapsto L(i,j)$ is a bijection of
$\mathbb{Z}/N\mathbb{Z}$, and for each fixed $j$, the map $i \mapsto L(i,j)$ is a
bijection.

*Proof.* Fix $i$. The map $j \mapsto i + j$ is injective: $i + a = i + b \Rightarrow a = b$
by cancellation in the group. An injective self-map of a finite set is a bijection. The
column claim is symmetric, using $i + j = i' + j \Rightarrow i = i'$. $\blacksquare$

**Remark 9.2 (Boxes are independent).** The cyclic square satisfies all rows and columns
but *not* the box constraints: e.g. for order $n = 3$ the top-left $3\times 3$ box of
$L(i,j) = i + j$ contains repeated values along its anti-diagonals. Hence the box demands
are genuinely new constraints, not consequences of the line demands. This is the precise
sense in which full Sudoku is strictly harder than its Latin-square relaxation — a point
we return to in Section 11.

---

## 10. Worked instances

- **Classic Sudoku** (order $n=3$): every line is $\mathrm{SAT}(9,9)$ (Theorem 7.1) and
  $\neg\,\mathrm{SAT}(10,9)$ (Theorem 7.2).
- **Line completions:** $Z(9,9) = 9! = 362\,880$; $Z(10,9) = 0$ (supercritical collapse).
- **Order-2 Sudoku** ($4\times4$): each line is $\mathrm{SAT}(4,4)$ with
  $Z(4,4) = 4! = 24$ completions.
- **Degenerate corners:** $\mathrm{SAT}(0,k)$ holds for all $k$ (the empty block is
  vacuously satisfiable), and $\neg\,\mathrm{SAT}(m,0)$ for all $m > 0$ (an empty alphabet
  cannot fill any cell). Both are genuine instances of the transition.

---

## 11. Criticality, computational hardness, and the "P vs NP of Sudoku"

The generalisation from the fixed $9 \times 9$ board to arbitrary order $n$ is what
connects this combinatorial threshold to computational complexity. Deciding whether a
partially filled order-$n$ Sudoku can be completed is NP-complete: it is a genuinely
hard search problem as $n$ grows, and its difficulty is not evenly spread across all
instances. Empirically — and, we contend, structurally — the hardest instances of many
NP-complete problems cluster at a *critical* setting of a natural control parameter,
where solutions are neither abundant nor obviously absent. The results above give a
clean, exactly-solvable account of *why* Sudoku is positioned at such a point.

Consider the three regimes of a constraint block as the demand count $m$ varies against
the resource count $k$:

- **Subcritical** ($m < k$): the partition function $Z(m,k) = k^{\underline m}$ is large
  and grows multiplicatively; solutions are abundant and easy to find greedily, because
  every partial assignment can be extended (at least $k - m + 1 \ge 2$ choices remain at
  the last step).
- **Critical** ($m = k$): the partition function equals $k!$ — still positive, but the
  block is *saturated*. Every symbol is used exactly once; there is no slack. A single
  externally forced value removes an entire symbol from circulation and, by the
  down-set structure, immediately tightens neighbouring lines. This is the regime of
  maximal propagation, where a local choice has global consequences.
- **Supercritical** ($m > k$): $Z(m,k) = 0$; infeasibility is certain and is witnessed by
  the explicit forced collision of Theorem 7.3.

Sudoku places *every one of its $3n^2$ lines* at the critical value $m = k = n^2$
simultaneously. No line has slack, and the three constraint families (rows, columns,
boxes) interlock so that forcing a symbol in one line propagates through the lines it
shares cells with. This is the mechanism behind the familiar experience of solving a
Sudoku: a chain of forced deductions, occasionally punctuated by a genuine branch,
where a wrong branch does not fail immediately but only after propagating deep into the
grid. The critical partition function $k!$ quantifies exactly how much freedom a single
isolated line retains ($9! = 362\,880$ for classic Sudoku) before the interaction of the
constraint families collapses it toward a unique completion.

The exactly-solvable AllDifferent atom is therefore best read as the *base case* of the
hardness story: it pins down, with closed-form certainty, the location of the threshold
($m = k$), the width of the transition (a single cell), and the order parameter that
detects it (the falling factorial). What remains hard — and is the subject of Section 13
— is the *interaction* of many critical atoms in a random ensemble, which is where the
genuine computational phase transition of Sudoku completion is expected to live.

## 12. Discussion

**One equivalence, three languages.** The conceptual payoff is that a single pigeonhole
inequality $m \le k$ controls three superficially unrelated structures. Order theory sees
a down-set with a hard ceiling; enumerative combinatorics / statistical mechanics sees a
partition function (falling factorial) that vanishes exactly at the boundary; graph theory
sees the chromatic number of a complete graph. Their agreement is not a coincidence to be
explained but a consequence of the fact that each is a reformulation of the same
comparison.

**Why Sudoku is hard.** The specialisation $m = k = n^2$ places every line of an order-$n$
Sudoku at the last satisfiable value — the critical point $\rho = 1$. This is the
structural reason the puzzle is interesting: constraints are maximally tight while still
admitting solutions, so solutions are rigid and a single misstep propagates to a
contradiction (Theorem 7.3 supplies the certificate). A puzzle with slack constraints
would be easy; one over threshold would be trivially unsolvable. Sudoku is tuned to the
knife's edge.

**Boxes as independent demands.** Remark 9.2 shows the box family is not implied by the
line families. The row-and-column relaxation always has the clean cyclic solution, so the
combinatorial difficulty of Sudoku is concentrated in the interaction of the third,
box-based, critical constraint family with the first two — a natural target for
quantitative study (Section 12).

**Relation to random-CSP thresholds.** The AllDifferent atom is a deterministic,
exactly-solvable prototype of the phase transitions that appear empirically in random
constraint satisfaction. Here the threshold, its uniqueness, and its order parameter are
all closed-form, offering a clean base case on which to build the probabilistic theory.

---

## 13. Future work

- **A sharp clue-density threshold for random puzzles.** Reveal each cell of an
  $n^2 \times n^2$ grid independently with probability $p$, consistently filled. Conjecture:
  there is a critical clue density $p_c(n)$ below which a completion exists with probability
  $\to 1$ and above which $\to 0$, with a shrinking transition window. Satisfiability is a
  monotone event in the revealed clues, so the boundary is a single up-set edge — the
  order-theoretic skeleton proved here, lifted to a random ensemble; sharp-threshold
  technology should supply the concentration.
- **Boxes strictly lower the critical density.** Conjecture: the full Sudoku CSP (rows,
  columns, boxes) has a strictly smaller critical clue density than its Latin-square
  relaxation, with a gap bounded below uniformly in $n$. The cyclic witness $L(i,j)=i+j$
  solves the relaxation but fails the boxes, so the box demands are genuinely new;
  quantifying their cost is the natural next measurement.
- **The vanishing partition function as an analytic order parameter.** Conjecture: the
  falling-factorial partition function admits an analytic continuation in the alphabet size
  whose real zeros accumulate exactly at the critical demand count, so the transition
  location can be read off from the zero set alone.

---

## 14. Conclusion

The AllDifferent constraint — the atom generating every row, column, and box of Sudoku —
has a sharp satisfiability threshold at the balance point demands $=$ resources, i.e.
$m = k$, with a unique critical value $m_c(k) = k+1$ and critical density $1$. This single
threshold is at once order-theoretic (down-set $[0,k]$), enumerative /
statistical-mechanical (falling-factorial partition function $k^{\underline m}$, zero
beyond threshold), and chromatic ($k$-colourability of $K_m$). An order-$n$ Sudoku sits
exactly on this boundary because each line satisfies $m = k = n^2$, which is the structural
source of its difficulty; and while the row-and-column relaxation has the explicit cyclic
solution $L(i,j) = i+j$, the box constraints are provably independent, locating the residual
hardness of full Sudoku precisely.
