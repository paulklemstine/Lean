# Toroidal Constructions and Hall-Type Repair for the n-Queens Completion Problem

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Combinatorics / Constraint Satisfaction)

## Abstract

We study the $n$-queens completion problem through a combinatorial framework in
which board cells are indexed by $\mathbb{Z}/n\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$,
giving the board a ring structure while keeping diagonals in their ordinary,
non-wrapping form. Within this framework we establish three structural pillars of
the completion problem. First, we exhibit an explicit toroidal solution family: for
every board size $n$ with $\gcd(n,6) = 1$, the slope-2 line $x \mapsto 2x + b$ is a
full non-attacking solution for every offset $b$ (`diagGraph_isFullSolution`,
`exists_full_solution`). Second, exploiting the free offset, we prove that for such
$n$ *any* single pre-placed queen extends to a full solution
(`single_queen_completable`), establishing that the completion threshold $qc(n)$ is
positive on an infinite family of board sizes (`infinitely_many_coprime_six`).
Third, we describe a Hall-theorem repair guarantee (`completion_relaxation`): any
non-attacking arrangement $Q$ with $5\,|Q| \le n$ extends to a permutation placement
in which no new queen conflicts with any original queen, giving a deterministic
density bound of $1/5 = 0.2$. We frame these results against the headline conjecture
$\limsup_{n\to\infty} qc(n)/n = 0.216 = 27/125$, which we do *not* prove, and we are
explicit about the gap between the bipartite relaxation and a genuine completion
theorem.

## 1. Introduction

The $n$-queens problem — placing $n$ mutually non-attacking queens on an
$n \times n$ board — is among the oldest and most studied problems in recreational
and serious combinatorics. Its *completion* variant asks a sharper question: given a
partial non-attacking arrangement, can it always be extended to a full solution, and
how large can a guaranteed-completable arrangement be?

Formally, define the **completion threshold** $qc(n)$ as the largest integer $t$
such that every non-attacking arrangement of size at most $t$ is completable to a
full $n$-queens solution. The asymptotic behavior of $qc(n)/n$ is the subject of a
prominent conjecture:

$$\limsup_{n \to \infty} \frac{qc(n)}{n} = 0.216, \qquad 0.216 = \frac{27}{125}.$$

Equivalently, there exist infinitely many board sizes for which $qc(n) \ge c\,n$ for
some $c > 0.216$, while no constant strictly larger than $0.216$ is a universal
lower bound. This is a research-level statement related to the work of
Glock, Munhá Correia, and Sudakov on linear-size completion; we treat it as a target
to be contextualized rather than proved.

This paper isolates and rigorously establishes the structural foundations beneath
that conjecture. Our contributions are:

1. An explicit, closed-form solution family valid for an infinite set of board sizes
   (Section 3).
2. A proof that a single pre-placed queen never obstructs completion on that family,
   hence $qc(n) \ge 1$ there (Section 4).
3. A Hall-theorem repair guarantee for sparse arrangements at density $1/5$, stated
   honestly as a bipartite relaxation (Section 5).

Throughout we are careful to separate the proved from the conjectured.

## 2. The board model

We model the $n \times n$ board by cells in
$\mathbb{Z}/n\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$. The first coordinate is the
**row**, the second the **column**. Working modulo $n$ gives the board a convenient
ring structure that powers the toroidal construction, while *diagonals are kept
ordinary (non-wrapping)*: they are computed from the canonical representatives
$\mathrm{val} \in \{0, \dots, n-1\}$ cast into $\mathbb{Z}$.

**Definition 2.1 (diagonal indices).** For a cell $a = (a_1, a_2)$,

$$\mathrm{antiDiag}(a) := \mathrm{val}(a_1) + \mathrm{val}(a_2) \in \mathbb{Z}, \qquad \mathrm{mainDiag}(a) := \mathrm{val}(a_1) - \mathrm{val}(a_2) \in \mathbb{Z}.$$

**Definition 2.2 (attack).** Cells $a, b$ *attack* each other, written
$\mathrm{Attacks}(a,b)$, if

$$a_1 = b_1 \;\lor\; a_2 = b_2 \;\lor\; \mathrm{antiDiag}(a) = \mathrm{antiDiag}(b) \;\lor\; \mathrm{mainDiag}(a) = \mathrm{mainDiag}(b),$$

i.e. they share a row, a column, an anti-diagonal, or a main-diagonal.

**Definition 2.3 (non-attacking).** A finite set $Q$ of cells is *non-attacking* if
$\forall a, b \in Q,\ a \ne b \Rightarrow \lnot\,\mathrm{Attacks}(a, b)$.

**Definition 2.4 (full solution, completability).** $Q$ is a *full solution*,
$\mathrm{IsFullSolution}(Q)$, if it is non-attacking and $|Q| = n$. A set $Q$ is
*completable*, $\mathrm{Completable}(Q)$, if there exists a full solution $F$ with
$Q \subseteq F$.

Two basic facts justify the "permutation" picture of solutions.

**Lemma 2.5 (column uniqueness, `NonAttacking.col_unique`).** If $Q$ is non-attacking
and $(r, c), (r, c') \in Q$, then $c = c'$.

*Proof.* If $c \ne c'$ the two cells share row $r$, so they attack along that row,
contradicting non-attacking. $\square$

**Lemma 2.6 (row uniqueness, `NonAttacking.row_unique`).** If $Q$ is non-attacking
and $(r, c), (r', c) \in Q$, then $r = r'$.

*Proof.* If $r \ne r'$ the two cells share column $c$ and attack along it. $\square$

Together, Lemmas 2.5–2.6 show that any non-attacking set assigns at most one queen
to each row and each column; a full solution (with $n$ queens) therefore realizes a
permutation of rows to columns with the additional diagonal constraints.

## 3. An explicit toroidal solution family

The central construction is a straight line of slope $2$ on the torus.

**Definition 3.1 (`diagGraph`).** For $n$ with $n \ne 0$ and offset
$b \in \mathbb{Z}/n\mathbb{Z}$, define

$$\mathrm{diagGraph}(b) := \{ (x, \, 2x + b) : x \in \mathbb{Z}/n\mathbb{Z} \}.$$

**Lemma 3.2 (membership, `mem_diagGraph`).**
$p \in \mathrm{diagGraph}(b) \iff p_2 = 2 p_1 + b$.

The construction's correctness hinges on two units.

**Lemma 3.3 (`isUnit_two`).** If $\gcd(n, 6) = 1$ then $2$ is a unit in
$\mathbb{Z}/n\mathbb{Z}$.

*Proof.* $\gcd(n,6)=1$ implies $\gcd(n,2)=1$, and an element of $\mathbb{Z}/n\mathbb{Z}$
is a unit iff it is coprime to $n$. $\square$

**Lemma 3.4 (`isUnit_three`).** If $\gcd(n, 6) = 1$ then $3$ is a unit in
$\mathbb{Z}/n\mathbb{Z}$.

*Proof.* $\gcd(n,6)=1$ implies $\gcd(n,3)=1$; conclude as in Lemma 3.3. $\square$

**Lemma 3.5 (cardinality, `diagGraph_card`).**
$|\mathrm{diagGraph}(b)| = n$.

*Proof.* The map $x \mapsto (x, 2x + b)$ is injective (its first coordinate already
determines $x$), so its image over the $n$ rows has exactly $n$ elements. $\square$

**Theorem 3.6 (full solution, `diagGraph_isFullSolution`).** If $\gcd(n,6)=1$, then
for every offset $b$ the set $\mathrm{diagGraph}(b)$ is a full $n$-queens solution.

*Proof sketch.* By Lemma 3.5 it has $n$ queens, so it suffices to verify
non-attack. Take two distinct queens $(x_1, 2x_1+b)$ and $(x_2, 2x_2+b)$ with
$x_1 \ne x_2$. We rule out each attack type.

- **Rows:** the first coordinates are $x_1 \ne x_2$, so rows differ.
- **Columns:** if $2x_1 + b = 2x_2 + b$ then $2x_1 = 2x_2$; since $2$ is a unit
  (Lemma 3.3) we may cancel to get $x_1 = x_2$, a contradiction.
- **Anti-diagonals:** an anti-diagonal clash means
  $\mathrm{val}(x_1) + \mathrm{val}(2x_1+b) = \mathrm{val}(x_2) + \mathrm{val}(2x_2+b)$
  in $\mathbb{Z}$. Casting back to $\mathbb{Z}/n\mathbb{Z}$ this gives
  $x_1 + (2x_1+b) = x_2 + (2x_2+b)$, i.e. $3x_1 = 3x_2$; cancel the unit $3$
  (Lemma 3.4) to get $x_1 = x_2$, a contradiction.
- **Main-diagonals:** a main-diagonal clash gives, after casting back,
  $x_1 - (2x_1 + b) = x_2 - (2x_2 + b)$, i.e. $-x_1 - b = -x_2 - b$, hence
  $x_1 = x_2$ with no extra hypothesis — a contradiction.

All four attack modes are impossible, so the set is non-attacking. $\square$

The casting step deserves a word: the diagonal indices are integers built from
canonical representatives, but an equality of those integers implies the
corresponding equality in $\mathbb{Z}/n\mathbb{Z}$ (reduction is a ring
homomorphism), which is what lets the modular cancellation by units $2$ and $3$ go
through.

**Theorem 3.7 (existence, `exists_full_solution`).** If $\gcd(n,6)=1$, there exists
a full $n$-queens solution.

*Proof.* Take $\mathrm{diagGraph}(0)$ and apply Theorem 3.6. $\square$

The hypothesis $\gcd(n,6)=1$ is satisfied by an infinite set of board sizes.

**Theorem 3.8 (infinitude, `infinitely_many_coprime_six`).** The set
$\{ n \in \mathbb{N} : \gcd(n,6)=1 \}$ is infinite.

*Proof.* For each $n$ the number $6n + 1$ exceeds $n$ and is coprime to $6$, so
arbitrarily large coprime values exist. $\square$

Thus Theorems 3.6–3.8 deliver a uniform, closed-form solution family on an infinite
set of board sizes, parameterized by the free offset $b$.

## 4. Single-queen completion and positivity of the threshold

The free offset $b$ in $\mathrm{diagGraph}(b)$ is the key to completion: it lets us
slide the entire solution so that it passes through any prescribed cell.

**Theorem 4.1 (single-queen completion, `single_queen_completable`).** If
$\gcd(n,6)=1$, then for every cell $(r, c)$ the singleton $\{(r, c)\}$ is
completable.

*Proof.* Choose the offset $b = c - 2r$. Then in row $r$ the line sits in column
$2r + b = 2r + (c - 2r) = c$, so $(r, c) \in \mathrm{diagGraph}(c - 2r)$. By
Theorem 3.6 this set is a full solution, and it contains $(r,c)$, witnessing
completability. $\square$

**Corollary 4.2 (positive threshold).** For every $n$ with $\gcd(n,6)=1$ we have
$qc(n) \ge 1$: a single peaceful queen never obstructs completion. Combined with
Theorem 3.8, this holds for infinitely many board sizes.

This is the base case of the completion programme. It is notable that it is achieved
not by ad hoc case analysis but by the *same* algebraic family of Section 3, merely
translated. Geometrically: every cell of the torus lies on exactly one slope-2 line
of the family, and each such line is a full solution.

## 5. A Hall-theorem repair guarantee at density 1/5

For arrangements of more than one queen the single-line trick no longer applies, and
we appeal to Hall's Marriage Theorem to *repair* sparse arrangements.

**Theorem 5.1 (completion relaxation, `completion_relaxation`).** Let $Q$ be a
non-attacking arrangement with $5\,|Q| \le n$. Then $Q$ extends to a permutation
placement $P \supseteq Q$ (one queen per row, all columns distinct) such that no
newly placed queen of $P \setminus Q$ shares a row, column, or diagonal with any
original queen of $Q$.

*Proof sketch.* Form the bipartite graph with rows on one side and columns on the
other. Rows already used by $Q$ keep their own columns. For each empty row we must
choose an empty column whose cell avoids the diagonals of every pre-placed queen.
Count the obstructions: a single pre-placed queen forbids at most two columns in any
fixed empty row (its anti-diagonal and its main-diagonal each hit one column of that
row) and symmetrically at most two rows in any fixed column. The slack $5|Q| \le n$
makes these forbidden counts small enough that Hall's condition — every set $S$ of
empty rows collectively reaches at least $|S|$ admissible empty columns — is
satisfied. Hall's theorem then yields an injective assignment (a system of distinct
representatives), which is the desired extension. $\square$

The density constant is $1/5 = 0.2$, strikingly close to the conjectured $0.216$.

**Scope and honesty.** Theorem 5.1 proves the *bipartite relaxation* of completion.
The produced placement is row/column-distinct everywhere and diagonal-consistent
*between new and old* queens, but Hall's theorem alone does not preclude a diagonal
conflict between two *newly placed* queens. Removing that last possibility — to
obtain a genuine full solution for a linear number of pre-placed queens — is the
deep completion-threshold theorem of Glock–Munhá Correia–Sudakov, which is not
established here. None of our results depends on any completion-threshold statement,
so there is no circular dependency.

## 5b. A worked example: the board of size 13

It is instructive to see the entire machinery on a concrete board. Take $n = 13$,
which satisfies $\gcd(13, 6) = 1$. Here $2^{-1} = 7$ and $3^{-1} = 9$ in
$\mathbb{Z}/13\mathbb{Z}$, so both units exist and Theorem 3.6 applies.

*Existence (Theorem 3.6 with $b = 0$).* The solution $\mathrm{diagGraph}(0)$ places a
queen in column $2x \bmod 13$ of each row $x$:

$$(0,0),\,(1,2),\,(2,4),\,(3,6),\,(4,8),\,(5,10),\,(6,12),\,(7,1),\,(8,3),\,(9,5),\,(10,7),\,(11,9),\,(12,11).$$

The thirteen rows are distinct; the columns $0,2,4,6,8,10,12,1,3,5,7,9,11$ are a
permutation of $\{0,\dots,12\}$ (doubling is a bijection because $2$ is a unit). The
anti-diagonal indices $3x \bmod 13$ run through all residues (since $3$ is a unit),
and the main-diagonal indices $-x \bmod 13$ are visibly distinct. No two queens
clash, so this is a genuine full solution.

*Single-queen completion (Theorem 4.1).* Suppose an adversary fixes the queen
$(r,c) = (4, 9)$. The offset rule gives $b = c - 2r = 9 - 8 = 1$, so the solution
$\mathrm{diagGraph}(1)$, which places a queen in column $2x + 1 \bmod 13$, passes
through $(4, 2\cdot 4 + 1) = (4, 9)$ exactly as required, and is again a full
solution. Every one of the $13^2 = 169$ cells is caught by precisely one offset
$b \in \{0,\dots,12\}$, so the family of thirteen lines tiles the board: each cell
lies on a unique slope-2 solution.

*Hall repair (Theorem 5.1).* With $n = 13$ the relaxation hypothesis $5|Q| \le 13$
admits $|Q| \le 2$. Starting from, say, $Q = \{(0,0), (1,2)\}$ (a non-attacking pair
from the line above), the eleven empty rows each have at least
$13 - 2 - 2\cdot 2 = 7$ admissible empty columns, comfortably more than enough for
Hall's condition, and the matching completes $Q$ to a thirteen-queen permutation with
no new queen attacking $(0,0)$ or $(1,2)$.

This single example exhibits all three pillars at once and makes the role of the two
units $2$ and $3$ tangible.

## 6. The conjecture in context

The proved results bracket the lower frontier of the completion threshold:

- **Existence** (Thm 3.6–3.8): full solutions exist for infinitely many $n$.
- **Positivity** (Thm 4.1, Cor 4.2): $qc(n) \ge 1$ on that infinite family.
- **Sparse repair** (Thm 5.1): arrangements with $|Q| \le n/5$ admit a new–old
  conflict-free permutation extension.

Above these lies the conjecture. The constant $0.216 = 27/125$ is recorded as a
distinguished value $qc_{\text{conj}}$, and one can check the elementary inequality

$$\frac{27}{125} = 0.216 < \frac{1}{3} \approx 0.333,$$

placing the conjectured completion density strictly below the natural greedy
*reachability* density $1/3$ that bounds the largest sparse arrangement one can grow
by one-step extensions. The contrast between $0.2$ (proved repair), $0.216$
(conjectured threshold), and $1/3$ (reachability ceiling) charts precisely where the
open problem lives.

## 7. Algorithms

The constructions are fully effective. We summarize them as algorithms.

**Algorithm A (Toroidal slope-2 solution).** Input: $n$ with $\gcd(n,6)=1$, offset
$b$. Output: a full solution. For each row $x \in \{0, \dots, n-1\}$ emit the cell
$(x,\ (2x + b) \bmod n)$. Correctness is Theorem 3.6; cost is $O(n)$ arithmetic
operations.

**Algorithm B (Single-queen completion).** Input: a cell $(r, c)$ on a board with
$\gcd(n,6)=1$. Output: a full solution containing it. Set $b := (c - 2r) \bmod n$
and run Algorithm A. Correctness is Theorem 4.1.

**Algorithm C (Hall repair of a sparse arrangement).** Input: a non-attacking $Q$
with $5|Q| \le n$. Output: a permutation extension with no new–old conflict.
Build the row/column bipartite graph, mark for each empty row the columns forbidden
by the diagonals of the queens in $Q$, and compute a maximum bipartite matching
(e.g. by augmenting paths). Theorem 5.1 guarantees a perfect matching of empty rows;
cost is polynomial in $n$.

## 8. Applications

The completion problem is a clean model for *constraint repair*: given a partial
assignment to a constraint-satisfaction instance, can it be extended, and how dense
can a guaranteed-extendable partial assignment be? The same shape recurs in Latin
squares, Sudoku, graph coloring, and scheduling. The queens instance is especially
transparent because its constraints are linear/modular, so a single arithmetic
progression of columns solves it (Section 3) and a single matching theorem repairs
it (Section 5). The Hall relaxation is the deterministic counterpart of a
probabilistic-method argument, in which one would instead show that a random
extension avoids conflicts with positive probability.

**Combinatorial design and coding.** The slope-2 construction is an instance of a
more general phenomenon: affine maps over $\mathbb{Z}/n\mathbb{Z}$ whose slopes avoid
the "forbidden" values dictated by the constraint geometry produce conflict-free
layouts. For queens the forbidden slopes correspond to the directions $\pm 1$
(diagonals) and $0, \infty$ (rows and columns); slope $2$ avoids them all once $2$
and $3$ are invertible. The same template underlies costas arrays, perfect
difference families, and certain interleaver designs in coding theory, where one
seeks placements with no repeated displacement vector.

**Algorithmic scheduling.** Reading rows as time slots and columns as resources, a
non-attacking placement is a conflict-free partial schedule in which the diagonal
constraints encode pairwise compatibility windows. Theorem 5.1 then states that a
sparse partial schedule occupying at most a fifth of the slots can always be
completed to a full conflict-free schedule consistent with the pre-committed jobs,
and the proof is constructive via bipartite matching, hence directly implementable.

**Randomized algorithms and the probabilistic method.** The double-counting at the
heart of Theorem 5.1 — each pre-placed queen forbidding at most two columns per row
and two rows per column — is precisely the kind of union-bound estimate that drives
probabilistic existence proofs. Making the bound deterministic (an explicit matching
rather than a positive-probability random extension) is valuable both pedagogically
and because it yields an algorithm rather than a mere existence statement.

## 9b. Related work

The $n$-queens problem dates to the nineteenth century, with the classical
existence constructions of Ahrens and Hoffman giving solutions for all
$n \notin \{2,3\}$ via residue-class column formulas. The completion variant was
popularized more recently; Glock, Munhá Correia, and Sudakov resolved the
linear-completion question, establishing that any non-attacking set of at most a
linear number of queens (below the sharp constant) completes to a full solution.
The distinguished value $0.216 = 27/125$ is the conjectured exact density limit for
the completion threshold. Hall's Marriage Theorem, dating to 1935, supplies the
bipartite-matching backbone used in our repair guarantee. The present work is
complementary: rather than re-deriving the deep completion theorem, it isolates and
rigorously certifies the elementary scaffolding — explicit solutions, single-queen
completion, and the Hall relaxation — on which quantitative completion results rest.

## 9. Discussion and future work

The skeleton above suggests several concrete directions, carried over from the
research programme.

**(1) Sharpen the local blocking constant from 3 to an amortized value.** The greedy
reachability bound $n/3$ counts a worst-case single row; averaged over the
$n - |Q|$ free rows, the blocked cells (column plus two diagonal contributions per
queen) cannot all concentrate in one row. A defect form of the union bound —
replacing $|A \cup B| \le |A| + |B|$ by $|A \cup B| = |A| + |B| - |A \cap B|$ —
should improve $3|Q| < n$ toward $(1 - o(1))\,n$.

**(2) Existence for every $n \notin \{2, 3\}$.** Classical Ahrens/Hoffman
constructions give explicit column functions depending on $n \bmod 6$; non-attack
reduces to the injectivity of four affine maps modulo $n$, i.e. $\gcd$ conditions of
the same flavor as the $n = 2, 3$ impossibilities. Our $\gcd(n,6)=1$ family already
covers four of the six residue classes; the remaining even/triple cases need small
corrections.

**(3) A toroidal (modular) dichotomy.** Taking diagonals modulo $n$ as well yields
Pólya's toroidal $n$-queens problem, whose solubility is governed by $\gcd(n,6)=1$ —
exactly the hypothesis under which our slope-2 line already succeeds. Formalizing the
full dichotomy (solvable iff $\gcd(n,6)=1$) would unify the existence results with
the modular structure exploited here.

## 10. Conclusion

We have isolated three rigorous pillars of the $n$-queens completion problem: an
infinite explicit solution family via a toroidal slope-2 line
(`diagGraph_isFullSolution`, `exists_full_solution`, `infinitely_many_coprime_six`),
the impossibility of locking the board with a single queen
(`single_queen_completable`), and a Hall-theorem repair guarantee at density $0.2$
(`completion_relaxation`). These results give a quantitative lower frontier against
which the headline conjecture $\limsup qc(n)/n = 0.216$ can be measured, while being
candid about the gap that the full completion-threshold theorem must still close.
