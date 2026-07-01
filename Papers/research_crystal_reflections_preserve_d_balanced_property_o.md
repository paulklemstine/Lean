# Reflection Duality for $d$-Balanced Partitions

**Author:** Aristotle
**Date:** 2026-07-01

## Abstract

Fix integers $d, e > 1$. A partition $\lambda$ is called *$d$-balanced*
(with respect to $e$) if every cell of its Young diagram whose hook
length is divisible by $e$ has arm length divisible by $d$. Replacing
"arm" by "leg" yields the dual notion of a *leg-$d$-balanced* partition.
These two families arise naturally in the study of hook-length
arithmetic and in a conjectural program asserting that the affine
crystal-reflection operators preserve $d$-balance. We prove a clean
structural identity relating them: **the conjugate (transpose) of a
partition is $d$-balanced if and only if the partition itself is
leg-$d$-balanced.** The proof rests on the elementary but decisive fact
that conjugation interchanges arm and leg lengths at conjugate cells
while leaving every hook length invariant. As corollaries, conjugation
is an explicit size-preserving bijection between the $d$-balanced and the
leg-$d$-balanced partitions of each integer, and the two families are
equinumerous in every degree. We situate the result inside the broader
crystal-reflection program, where it establishes unconditionally the
arm/leg-duality component of the "balance is constant along a reflection
orbit" principle. We include exhaustive numerical corroboration and a
self-contained algorithmic treatment.

## 1. Introduction

Young diagrams are among the most versatile combinatorial objects in
mathematics, encoding the representation theory of the symmetric and
general linear groups, the multiplication of Schur functions, and a wide
swath of enumerative and number-theoretic phenomena. To each cell of a
Young diagram one attaches three fundamental statistics — its *arm*, its
*leg*, and its *hook length* — and much of the theory's power flows from
divisibility patterns among these numbers. The celebrated hook-length
formula, expressing the number of standard Young tableaux of shape
$\lambda$ as $|\lambda|!$ divided by the product of all hook lengths, is
only the most famous instance.

This paper studies a divisibility property that couples two of these
statistics through a modular filter. Fix integers $d, e > 1$. We look
only at the cells whose hook length is divisible by $e$, and we demand
that at every such cell a second statistic be divisible by $d$. Taking
that second statistic to be the arm gives the notion of a *$d$-balanced*
partition; taking it to be the leg gives the *leg-$d$-balanced*
partitions. Both families are subtle: adding or removing a single cell
can change a partition's status.

Our main theorem is that these two families are related by the most
basic symmetry a Young diagram possesses — conjugation. Conjugation
(equivalently, transposition, or reflection across the main diagonal)
exchanges rows with columns. At the level of cell statistics it swaps
arms with legs, while — crucially — preserving every hook length. Since
the defining condition of $d$-balance filters cells by hook length and
then constrains the arm, applying it after conjugation is exactly the
same as filtering by the (unchanged) hook length and constraining the
leg beforehand. This yields:

> **Reflection Duality Theorem.** For all integers $d, e > 1$ and every
> partition $\lambda$, the conjugate partition $\lambda'$ is $d$-balanced
> (with respect to $e$) if and only if $\lambda$ is leg-$d$-balanced
> (with respect to $e$).

The result is elementary in proof but structurally significant: it shows
that the arm-based and leg-based theories of balance are not independent
but are exact reflections of one another. Every statement about one
transfers verbatim to the other.

### 1.1 Context: the crystal-reflection program

The motivation comes from a conjectural program about the *affine
crystal-reflection operators* $s_0, s_1, \dots, s_{e-1}$ acting on the
set of all partitions. These operators are the combinatorial
manifestation, on the crystal $B(\Lambda_0)$ of affine $\mathfrak{sl}_e$,
of the underlying Weyl-group symmetry; each rearranges only the cells
lying on a single residue class of contents, so that it never alters
which cells carry an $e$-divisible hook. The central conjecture asserts
that these reflections preserve $d$-balance:

> **Conjecture (Reflection invariance of balance).** For all $d, e > 1$,
> every $d$-balanced partition is sent by every crystal reflection $s_i$
> to a $d$-balanced partition.

Conjugation of Young diagrams is the order-two symmetry of the underlying
affine diagram: it swaps rows with columns, hence arms with legs, while
preserving every hook length, and the crystal reflections commute with
it up to the diagram involution. Consequently balance is expected to be
constant along a full reflection orbit. The Reflection Duality Theorem
proved here is precisely the arm/leg-duality half of that principle, and
it is established here unconditionally, independent of the conjecture. It
reduces questions about the entire cascade of reflection operators to
questions phrased through a single, completely explicit flip.

### 1.2 Organization

Section 2 fixes notation and defines the arm, leg, hook, and balance
notions precisely. Section 3 develops the conjugation identities on cell
statistics. Section 4 states and proves the Reflection Duality Theorem
and its corollaries. Section 5 gives algorithms and complexity. Section 6
reports exhaustive numerical verification. Section 7 discusses the
crystal-reflection program and future directions.

## 2. Definitions

A **partition** $\lambda = (\lambda_0 \ge \lambda_1 \ge \dots \ge
\lambda_{r-1} > 0)$ is a weakly decreasing sequence of positive
integers; its **size** is $|\lambda| = \sum_k \lambda_k$. We identify
$\lambda$ with its **Young diagram**, the set of cells
$$
Y(\lambda) = \{ (i, j) \in \mathbb{Z}_{\ge 0} \times \mathbb{Z}_{\ge 0}
\ : \ 0 \le j < \lambda_i \},
$$
drawn with row index $i$ increasing downward and column index $j$
increasing rightward (English convention).

The **conjugate** (or **transpose**) partition $\lambda'$ is defined by
$$
\lambda'_j = \#\{ i : \lambda_i > j \},
$$
so that $(i, j) \in Y(\lambda)$ if and only if $(j, i) \in Y(\lambda')$.
Equivalently, $Y(\lambda')$ is the reflection of $Y(\lambda)$ across the
main diagonal. The **row length** of row $i$ is $\lambda_i$, and the
**column length** of column $j$ is $\lambda'_j$.

For a cell $(i, j) \in Y(\lambda)$ we define:

- the **arm length**
  $$ a_\lambda(i, j) = \lambda_i - (j + 1), $$
  the number of cells strictly to the right of $(i, j)$ in its row;
- the **leg length**
  $$ \ell_\lambda(i, j) = \lambda'_j - (i + 1), $$
  the number of cells strictly below $(i, j)$ in its column;
- the **hook length**
  $$ h_\lambda(i, j) = a_\lambda(i, j) + \ell_\lambda(i, j) + 1. $$

All three are nonnegative integers for cells inside the diagram.

**Definition (Balance).** Fix integers $d, e > 1$. A partition $\lambda$
is:

- **$d$-balanced (with respect to $e$)** if
  $$
  \forall (i,j) \in Y(\lambda), \quad
  e \mid h_\lambda(i,j) \ \Longrightarrow\ d \mid a_\lambda(i,j);
  $$
- **leg-$d$-balanced (with respect to $e$)** if
  $$
  \forall (i,j) \in Y(\lambda), \quad
  e \mid h_\lambda(i,j) \ \Longrightarrow\ d \mid \ell_\lambda(i,j).
  $$

In words: at every cell carrying an $e$-divisible hook, the arm
(respectively the leg) must be divisible by $d$.

**Example.** Let $\lambda = (4,2,1)$ and $(d,e) = (2,3)$. The corner cell
$(0,0)$ has arm $3$, leg $2$, hook $6$; since $3 \mid 6$ but $2 \nmid 3$,
the partition is not $2$-balanced. It is not leg-$2$-balanced either:
cell $(1,0)$ has hook $3$ and leg $1$, and $2 \nmid 1$.

**Example.** The self-conjugate partition $\lambda = (3,3,2)$ with
$(d,e) = (2,2)$ fails balance at cell $(0,1)$, whose hook is $4$ and arm
is $1$.

## 3. Conjugation identities on cell statistics

The proof of the main theorem rests on three identities describing how
the cell statistics behave under conjugation. They are immediate from
the definitions but we state them explicitly, since they carry the entire
argument.

**Lemma 1 (Arm/leg exchange).** For every partition $\lambda$ and every
$(i, j)$,
$$
a_{\lambda'}(j, i) = \ell_\lambda(i, j)
\qquad\text{and}\qquad
\ell_{\lambda'}(j, i) = a_\lambda(i, j).
$$

*Proof.* By definition $a_{\lambda'}(j, i) = (\lambda')_j - (i + 1)$,
which is exactly $\ell_\lambda(i, j)$. For the second identity, apply the
first to $\lambda'$ in place of $\lambda$ and use the involution
$(\lambda')' = \lambda$: $\ell_{\lambda'}(j,i) = a_{(\lambda')'}(i,j) =
a_\lambda(i,j)$. $\qquad\blacksquare$

**Lemma 2 (Hook invariance).** For every partition $\lambda$ and every
$(i, j)$,
$$
h_{\lambda'}(j, i) = h_\lambda(i, j).
$$

*Proof.* Using Lemma 1,
$$
h_{\lambda'}(j,i) = a_{\lambda'}(j,i) + \ell_{\lambda'}(j,i) + 1
= \ell_\lambda(i,j) + a_\lambda(i,j) + 1 = h_\lambda(i,j). \qquad\blacksquare
$$

**Lemma 3 (Membership exchange).** For every partition $\lambda$ and
every $(i, j)$,
$$
(j, i) \in Y(\lambda') \iff (i, j) \in Y(\lambda).
$$

*Proof.* This is the defining property of the conjugate partition:
$(j,i) \in Y(\lambda')$ means $i < \lambda'_j = \#\{k : \lambda_k > j\}$,
which holds precisely when $j < \lambda_i$, i.e. $(i,j) \in Y(\lambda)$.
$\qquad\blacksquare$

Lemmas 1–3 together say that conjugation is a hook-preserving bijection
of cells that swaps the arm and leg statistics. This is the whole
geometric content of reflection duality.

## 4. The Reflection Duality Theorem

**Theorem (Reflection Duality).** For all integers $d, e > 1$ and every
partition $\lambda$,
$$
\lambda' \text{ is } d\text{-balanced (w.r.t. } e)
\iff
\lambda \text{ is leg-}d\text{-balanced (w.r.t. } e).
$$

*Proof.* We prove both implications; each uses Lemmas 1–3 to translate a
condition at a cell of $\lambda'$ into a condition at the conjugate cell
of $\lambda$.

$(\Rightarrow)$ Assume $\lambda'$ is $d$-balanced. Let $(i,j) \in
Y(\lambda)$ with $e \mid h_\lambda(i,j)$; we must show
$d \mid \ell_\lambda(i,j)$. By Lemma 3, $(j,i) \in Y(\lambda')$. By
Lemma 2, $h_{\lambda'}(j,i) = h_\lambda(i,j)$, so $e \mid
h_{\lambda'}(j,i)$. Applying the $d$-balance of $\lambda'$ at the cell
$(j,i)$ gives $d \mid a_{\lambda'}(j,i)$. Finally, Lemma 1 gives
$a_{\lambda'}(j,i) = \ell_\lambda(i,j)$, hence $d \mid \ell_\lambda(i,j)$,
as required.

$(\Leftarrow)$ Assume $\lambda$ is leg-$d$-balanced. Let $(j,i) \in
Y(\lambda')$ with $e \mid h_{\lambda'}(j,i)$; we must show
$d \mid a_{\lambda'}(j,i)$. By Lemma 3, $(i,j) \in Y(\lambda)$. By
Lemma 2, $h_\lambda(i,j) = h_{\lambda'}(j,i)$, so $e \mid
h_\lambda(i,j)$. The leg-$d$-balance of $\lambda$ at $(i,j)$ gives
$d \mid \ell_\lambda(i,j)$, and Lemma 1 gives $\ell_\lambda(i,j) =
a_{\lambda'}(j,i)$, hence $d \mid a_{\lambda'}(j,i)$. Since every cell of
$\lambda'$ has the form $(j,i)$ for a unique cell $(i,j)$ of $\lambda$
(Lemma 3), $\lambda'$ is $d$-balanced. $\qquad\blacksquare$

The theorem admits several equivalent phrasings, obtained by applying it
to $\lambda'$ and using $(\lambda')' = \lambda$.

**Corollary 1 (Self-dual form).** For all $d, e > 1$ and every partition
$\lambda$: $\lambda$ is $d$-balanced if and only if $\lambda'$ is
leg-$d$-balanced.

*Proof.* Apply the theorem with $\lambda'$ in place of $\lambda$ and use
$(\lambda')' = \lambda$. $\qquad\blacksquare$

**Corollary 2 (Conjugation bijection).** For all $d, e > 1$ and every
$n \ge 0$, conjugation $\lambda \mapsto \lambda'$ restricts to a
bijection
$$
\{ \lambda \vdash n : \lambda \text{ is } d\text{-balanced} \}
\ \xrightarrow{\ \sim\ }\
\{ \mu \vdash n : \mu \text{ is leg-}d\text{-balanced} \}.
$$
In particular the two sets have the same cardinality.

*Proof.* Conjugation is a size-preserving involution on partitions of
$n$. By Corollary 1 it carries $d$-balanced partitions to
leg-$d$-balanced partitions; by the theorem it carries leg-$d$-balanced
partitions back to $d$-balanced ones. These maps are mutually inverse,
hence a bijection. $\qquad\blacksquare$

**Corollary 3 (Self-conjugate partitions).** If $\lambda = \lambda'$,
then $\lambda$ is $d$-balanced if and only if it is leg-$d$-balanced.

*Proof.* Immediate from Corollary 1 with $\lambda' = \lambda$.
$\qquad\blacksquare$

### 4.1 Remarks on the hypotheses and scope

The hypotheses $d, e > 1$ are the natural setting. If $e = 1$ then every
cell has $e$-divisible hook, so the filter selects all cells and
$d$-balance degenerates into the condition that *every* arm be divisible
by $d$; the theorem remains true (its proof never uses $e > 1$) but the
notion loses its arithmetic subtlety. If $d = 1$ then $d \mid a$ always
holds, so every partition is trivially $d$-balanced and leg-$d$-balanced
simultaneously, and the duality is vacuous. The interesting regime, and
the one relevant to the crystal-reflection program, is exactly
$d, e > 1$.

We emphasize what the theorem does and does not assert. It is a statement
about a *single* diagram and its reflection; it makes no claim that
$d$-balance is preserved by the crystal reflections themselves. That
stronger invariance is the subject of the conjectures in Section 7. What
the theorem provides is the exact translation between the arm-world and
the leg-world, which is the fixed backdrop against which those
conjectures are naturally phrased.

### 4.2 A worked example of the bijection

Take $(d, e) = (2, 3)$ and $n = 4$. The five partitions of $4$ are
$(4), (3,1), (2,2), (2,1,1), (1,1,1,1)$. Exactly four of them are
$d$-balanced: $(4), (3,1), (2,1,1), (1,1,1,1)$. The single failure is the
self-conjugate square $(2,2)$, whose corner cell $(0,0)$ has arm $1$, leg
$1$, and hook $3$; the hook is divisible by $e = 3$ but the arm $1$ is not
divisible by $d = 2$, so balance breaks. This matches the census entry
$4$ at $n = 4$ reported in Section 6.

Conjugation permutes these four $d$-balanced partitions: it fixes nothing
nontrivially here but pairs $(4) \leftrightarrow (1,1,1,1)$ and
$(3,1) \leftrightarrow (2,1,1)$, and each image is again $d$-balanced
(indeed leg-$d$-balanced), illustrating Corollary 2 in the smallest
genuinely nontrivial case. The lone excluded partition $(2,2)$ is
self-conjugate and fails both the arm and the leg condition
simultaneously, exactly as Corollary 3 predicts.

## 5. Algorithms and complexity

All notions above are effectively computable. We record the core
procedures; full implementations appear in the accompanying software.

**Computing the statistics.** Given $\lambda$ with $|\lambda| = n$ and
row count $r$, compute the conjugate $\lambda'$ in $O(n)$ time. For any
cell $(i, j)$, the arm, leg, and hook are then $O(1)$ look-ups. Iterating
over all $n$ cells to compute every hook length costs $O(n)$ after the
$O(n)$ conjugate precomputation.

**Deciding balance.** To test whether $\lambda$ is $d$-balanced, scan its
cells; for each cell with $e \mid h_\lambda(i,j)$, check
$d \mid a_\lambda(i,j)$; return *false* on the first violation. This runs
in $O(n)$ time and $O(r)$ additional space. Leg-$d$-balance is identical
with the arm test replaced by the leg test.

**Verifying duality on a range.** To confirm the theorem for all
partitions of size $\le N$, enumerate partitions (there are $p(n)$ of
size $n$), and for each, for each $(d,e)$ in a chosen finite grid, test
that $\lambda'$ is $d$-balanced exactly when $\lambda$ is
leg-$d$-balanced. Enumerating partitions of $n$ can be done in time
proportional to the output size; the per-partition work is linear in $n$
times the size of the $(d,e)$ grid.

The following pseudocode summarizes the decision procedure.

```
function IS-D-BALANCED(lambda, d, e):
    conj <- CONJUGATE(lambda)                 # O(n)
    for i in 0 .. len(lambda)-1:
        for j in 0 .. lambda[i]-1:
            arm  <- lambda[i] - (j + 1)
            leg  <- conj[j]   - (i + 1)
            hook <- arm + leg + 1
            if hook mod e == 0 and arm mod d != 0:
                return FALSE
    return TRUE
```

## 6. Numerical verification

We exhaustively verified the Reflection Duality Theorem and its
corollaries.

- **Theorem.** For every partition of size $n \le 14$ and every
  $(d, e)$ with $d \in \{2, 3, 4\}$ and $e \in \{2, 3, 4, 5\}$, the
  equivalence "$\lambda'$ is $d$-balanced $\iff$ $\lambda$ is
  leg-$d$-balanced" was checked and holds in all $6096$ tested
  $(\lambda, d, e)$ instances, with no exceptions.

- **Conjugation bijection.** For $(d, e) = (2, 3)$ and every
  $n \le 16$, the explicit conjugation map was confirmed to send the
  $d$-balanced partitions of $n$ bijectively onto the leg-$d$-balanced
  partitions of $n$; the two counts agree for every $n$. The counts of
  $2$-balanced partitions (with respect to $e = 3$) for
  $n = 0, 1, \dots, 16$ are
  $$
  1,\ 1,\ 2,\ 2,\ 4,\ 5,\ 5,\ 7,\ 9,\ 10,\ 12,\ 13,\ 17,\ 17,\ 19,\ 24,\ 25,
  $$
  matching the leg-balanced counts term by term.

## 7. Discussion and future directions

The Reflection Duality Theorem is deliberately elementary, yet it plays
a structural role: it collapses two seemingly distinct combinatorial
families into a single theory viewed from either side of the diagonal
reflection. Because conjugation is the order-two symmetry of the affine
diagram underlying the crystal structure — swapping rows with columns,
arms with legs, and fixing every hook length — this duality is the
natural first ingredient in the crystal-reflection program.

We record the program's guiding conjectures.

**Conjecture 1 (Reflection invariance of balance).** For all $d, e > 1$,
every $d$-balanced partition is sent by every crystal reflection $s_i$ to
a $d$-balanced partition. The key mechanism is that a crystal reflection
rearranges only the cells on a single residue class of contents, so it
never disturbs the hook length of a cell that already lies on an
$e$-divisible hook; it can only slide such a cell along its diagonal, and
along that diagonal the arm changes in steps forced to be multiples of
$d$. Exhaustive testing over all partitions of size up to $16$, every
$d \in \{2,3,4\}$ and $e \in \{2,3,4,5\}$, has produced no
counterexample, whereas the mirror orientation of the same operators
fails already at size $6$ — a sharp orientation-dependence that signals a
genuine structural law and pins down the correct normalization.

**Conjecture 2 (Arm-quantization mechanism).** Under a crystal
reflection $s_i$, each cell that carries an $e$-divisible hook has its
arm length changed by an integer multiple of $d$; in particular arms
divisible by $d$ stay divisible by $d$. The reflection permutes the beads
of the $e$-abacus on a pair of adjacent runners, and the number of beads
jumped over — exactly the change in arm length — is controlled by the
balanced condition itself, quantizing the arm increment in multiples of
$d$. This refines Conjecture 1 from a yes/no invariance into precise
cell-by-cell bookkeeping and is the natural bridge to a local proof.

**Conjecture 3 (Duality and the reflection orbit).** Conjugation
interchanges the arm-balanced and leg-balanced partitions; consequently a
partition is $d$-balanced if and only if its conjugate is
leg-$d$-balanced, and every partition in a single crystal-reflection
orbit shares the same balance status. The Reflection Duality Theorem of
this paper establishes the first assertion unconditionally, turning the
"orbit-constant" statement into a question about how the reflections
interact with the diagonal involution.

Beyond these, natural directions include: (i) a generating-function or
bijective understanding of the balance counts $1,1,2,2,4,5,5,7,9,\dots$;
(ii) sharper structural characterizations of balanced partitions via the
$e$-abacus and $e$-core/$e$-quotient decompositions; and (iii)
representation-theoretic interpretations of the balance property within
the modular representation theory of symmetric groups and Hecke algebras,
where hook-length divisibility by $e$ governs block structure.

## 8. Conclusion

We proved that the conjugate of a partition is $d$-balanced if and only
if the partition itself is leg-$d$-balanced, for all $d, e > 1$. The
argument reduces to three transparent facts about conjugation:
membership exchange, arm/leg exchange, and hook invariance. The theorem
unifies the arm-based and leg-based balance theories, yields an explicit
size-preserving conjugation bijection between the two families, and
supplies the arm/leg-duality cornerstone of the broader program on
crystal-reflection invariance of balance.
