# A Power-of-Two Characterization of Pairwise Reflection Symmetric Latin Squares

## Abstract

We study Latin squares that are *pairwise reflection symmetric* (PRS): arrays in
which, on every pair of columns, each ordered pair of symbols $(p,q)$ occurs on
exactly as many rows as its reversal $(q,p)$. Restricting to squares of index
$\lambda = 1$ (no ordered symbol pair repeats across two distinct columns), we
establish a complete cross-domain characterization for the fundamental class of
squares arising from finite groups, together with the constructive half of the
general conjecture. Concretely, we prove that the multiplication (Cayley) table
of a finite group is a Latin square of index one; that this table is pairwise
reflection symmetric **if and only if the group has exponent two**
($x^2 = e$ for all $x$); that a finite group of exponent two has order a power of
two; and, conversely, that the elementary abelian $2$-groups $(\mathbb{Z}/2)^k$
realize a PRS index-one Latin square of every order $2^k$. Combining these
results yields: *a group-based PRS index-one Latin square of order $n$ exists if
and only if $n$ is a power of two.* The equivalence links three domains —
combinatorial design theory, finite group theory, and elementary number theory —
through a single algebraic pivot, the exponent-two condition. We discuss the
remaining open direction (arbitrary, non-group PRS squares) and several avenues
toward it.

**Keywords.** Latin square, reflection symmetry, Cayley table, exponent-two
group, elementary abelian $2$-group, $p$-group, power of two.

## 1. Introduction

A *Latin square of order $n$* is an $n \times n$ array over an $n$-element symbol
set in which every symbol occurs exactly once in each row and exactly once in
each column. Latin squares are a central object of combinatorial design theory,
with applications spanning experimental design, tournament scheduling,
error-correcting codes, and symmetric-key cryptography.

Beyond the row/column constraint, one may impose symmetry conditions on how pairs
of columns interact. Fix two columns and read them together across all rows; each
row yields an ordered pair of symbols. A square is **pairwise reflection
symmetric** if, for every choice of two columns, the distribution of ordered
symbol pairs is invariant under swapping the two coordinates. This paper concerns
the following conjecture.

> **Conjecture.** A pairwise reflection symmetric Latin square of order $n$ with
> index $\lambda = 1$ exists if and only if $n$ is a power of two.

Our contribution is a complete proof of this conjecture for the class of squares
obtained from finite groups, together with the constructive ("if") direction in
full generality. The mechanism is a clean equivalence between a combinatorial
symmetry and an algebraic one, which we make precise below.

The organization is as follows. Section 2 fixes definitions. Section 3 records
that group multiplication tables are index-one Latin squares and derives an exact
pair-count formula. Section 4 proves the keystone equivalence between reflection
symmetry and exponent two. Section 5 supplies the group-theory–to–number-theory
step and assembles the main theorem. Section 6 gives the explicit construction.
Section 7 discusses the open direction and future work.

## 2. Definitions

Throughout, $\alpha$ is a finite set of symbols with $|\alpha| = n$, and rows and
columns are both indexed by $\alpha$. A square array is a function
$L : \alpha \times \alpha \to \alpha$, where $L(i,j)$ (also written $L_{ij}$) is
the entry in row $i$, column $j$.

**Definition 2.1 (Latin square).** $L$ is a *Latin square* if every row map
$j \mapsto L(i,j)$ and every column map $i \mapsto L(i,j)$ is a bijection of
$\alpha$. Equivalently, every symbol occurs exactly once in each row and exactly
once in each column.

**Definition 2.2 (Pair count).** For columns $j_1, j_2$ and symbols $p, q$, the
*pair count* is
$$
\mathrm{pairCount}_L(j_1, j_2, p, q) \;=\; \bigl|\{\, i \in \alpha : L(i,j_1) = p \text{ and } L(i,j_2) = q \,\}\bigr|,
$$
the number of rows on which columns $j_1$ and $j_2$ read the ordered pair
$(p,q)$.

**Definition 2.3 (Pairwise reflection symmetry).** $L$ is *pairwise reflection
symmetric* (PRS) if
$$
\mathrm{pairCount}_L(j_1, j_2, p, q) = \mathrm{pairCount}_L(j_1, j_2, q, p)
\qquad \text{for all } j_1, j_2, p, q \in \alpha.
$$

**Definition 2.4 (Index $\lambda \le 1$).** $L$ has *index at most one* if for
all distinct columns $j_1 \ne j_2$ the map $i \mapsto (L(i,j_1), L(i,j_2))$ is
injective; that is, no ordered symbol pair repeats across two distinct columns.
For a Latin square this is the $\lambda = 1$ regime of the associated pairwise
design.

**Definition 2.5 (Cayley table).** For a finite group $G$ with product
$\cdot$, the *Cayley table* is the array $C_G(i,j) = i \cdot j$.

**Definition 2.6 (Exponent two).** A group $G$ has *exponent two* if
$x \cdot x = e$ for every $x \in G$, where $e$ is the identity. Equivalently,
every element is an involution (its own inverse).

## 3. Cayley tables are index-one Latin squares

**Proposition 3.1.** *For any finite group $G$, the Cayley table $C_G$ is a Latin
square.*

*Proof.* The row map $j \mapsto i \cdot j$ is left multiplication by $i$, a
bijection of $G$ with inverse left multiplication by $i^{-1}$. The column map
$i \mapsto i \cdot j$ is right multiplication by $j$, likewise a bijection.
Hence every row and column is a bijection. $\qquad\blacksquare$

**Proposition 3.2 (Index one).** *For any finite group $G$, the Cayley table
$C_G$ has index at most one.*

*Proof.* Suppose $(a \cdot j_1, a \cdot j_2) = (b \cdot j_1, b \cdot j_2)$. From
the first coordinate $a \cdot j_1 = b \cdot j_1$, right cancellation gives
$a = b$. Thus $i \mapsto (i \cdot j_1, i \cdot j_2)$ is injective for any columns,
in particular for $j_1 \ne j_2$. $\qquad\blacksquare$

The following exact formula is the computational core of the paper.

**Lemma 3.3 (Exact pair count).** *For a finite group $G$ and any
$j_1, j_2, p, q \in G$,*
$$
\mathrm{pairCount}_{C_G}(j_1, j_2, p, q) =
\begin{cases}
1 & \text{if } p \cdot j_1^{-1} \cdot j_2 = q,\\[2pt]
0 & \text{otherwise.}
\end{cases}
$$

*Proof.* A row $i$ contributes iff $i \cdot j_1 = p$ and $i \cdot j_2 = q$. The
first equation has the unique solution $i = p \cdot j_1^{-1}$. Substituting into
the second, the row exists iff $(p \cdot j_1^{-1}) \cdot j_2 = q$, and then it is
unique. Hence the count is $1$ when $p \cdot j_1^{-1} \cdot j_2 = q$ and $0$
otherwise. $\qquad\blacksquare$

## 4. The keystone: reflection symmetry $\iff$ exponent two

We first record two elementary consequences of exponent two.

**Lemma 4.1.** *If $G$ has exponent two, then $x^{-1} = x$ for all $x$, and $G$
is abelian.*

*Proof.* From $x \cdot x = e$ we get $x^{-1} = x$ directly. For commutativity, in
an exponent-two group $(a \cdot b)^{-1} = a \cdot b$; but also
$(a \cdot b)^{-1} = b^{-1} \cdot a^{-1} = b \cdot a$. Hence
$a \cdot b = b \cdot a$. $\qquad\blacksquare$

**Theorem 4.2 (Keystone equivalence).** *Let $G$ be a finite group. The Cayley
table $C_G$ is pairwise reflection symmetric if and only if $G$ has exponent
two.*

*Proof.* Write $w = j_1^{-1} \cdot j_2$. By Lemma 3.3,
$$
\mathrm{pairCount}_{C_G}(j_1, j_2, p, q) = \mathbf{1}[\,p \cdot w = q\,],
\qquad
\mathrm{pairCount}_{C_G}(j_1, j_2, q, p) = \mathbf{1}[\,q \cdot w = p\,],
$$
using $p \cdot j_1^{-1} \cdot j_2 = p \cdot w$ (and likewise with $q$).

($\Leftarrow$) Suppose $G$ has exponent two, so $w \cdot w = e$. If
$p \cdot w = q$, then $q \cdot w = (p \cdot w) \cdot w = p \cdot (w \cdot w) = p$;
symmetrically the converse holds. Thus the two indicator conditions are
equivalent, the counts agree for all $j_1, j_2, p, q$, and $C_G$ is PRS.

($\Rightarrow$) Suppose $C_G$ is PRS. Fix $x \in G$ and apply the definition with
$j_1 = e$, $j_2 = x$, $p = e$, $q = x$. Here $w = e^{-1} \cdot x = x$, and the
$(p,q)$ condition $p \cdot w = q$ reads $e \cdot x = x$, which holds, so the
$(p,q)$ count is $1$. By PRS the reversed count also equals $1$, i.e. the
$(q,p)$ condition $q \cdot w = p$ holds: $x \cdot x = e$. Since $x$ was
arbitrary, $G$ has exponent two. $\qquad\blacksquare$

Theorem 4.2 is the crux: it identifies a combinatorial symmetry of a grid with an
algebraic identity of a group.

## 5. From exponent two to powers of two, and the main theorem

**Theorem 5.1 ($2$-group theorem).** *A finite group $G$ of exponent two has
order a power of two.*

*Proof.* For every $g \in G$ we have $g^2 = e$, so the order of $g$ divides $2$;
in particular $g^2 = e$ realizes $g$ as an element whose order is a power of the
prime $2$. Hence $G$ is a $2$-group: by the structure of finite $p$-groups (a
finite group all of whose elements have $p$-power order has order a power of
$p$), $|G| = 2^k$ for some $k \ge 0$. $\qquad\blacksquare$

Combining Theorems 4.2 and 5.1 gives the "only if" direction for group tables.

**Corollary 5.2.** *If the Cayley table of a finite group $G$ is pairwise
reflection symmetric, then $|G|$ is a power of two.*

We can package the group-theoretic content as an existence equivalence.

**Theorem 5.3 (Existence of exponent-two groups).** *For $n \in \mathbb{N}$, a
finite group of order $n$ and exponent two exists if and only if $n$ is a power
of two.*

*Proof.* ($\Rightarrow$) Immediate from Theorem 5.1. ($\Leftarrow$) For
$n = 2^k$, the elementary abelian group $(\mathbb{Z}/2)^k$ has order $2^k$ and
satisfies $x + x = 0$ (equivalently $x \cdot x = e$ in multiplicative notation)
for every $x$, since each coordinate lies in $\mathbb{Z}/2$. $\qquad\blacksquare$

**Main Theorem 5.4 (Characterization for group tables).** *For a finite group
$G$ of order $n$, the Cayley table $C_G$ is a pairwise reflection symmetric Latin
square of index one if and only if $n$ is a power of two. Moreover every power of
two is realized.*

*Proof.* $C_G$ is always a Latin square of index one (Propositions 3.1, 3.2). It
is PRS iff $G$ has exponent two (Theorem 4.2), which holds iff $n$ is a power of
two (Theorem 5.3); realization is by $(\mathbb{Z}/2)^k$. $\qquad\blacksquare$

## 6. Construction: the elementary abelian witnesses

The "if" direction is fully explicit and holds without any group-table
restriction on the target square.

**Theorem 6.1 (Constructive direction).** *For every $k \in \mathbb{N}$ there
exists a Latin square of order $2^k$ that is pairwise reflection symmetric and
has index one.*

*Proof.* Take $\alpha = (\mathbb{Z}/2)^k$ (bit vectors of length $k$ under
coordinatewise addition mod $2$), and let $L$ be its Cayley table,
$L(i,j) = i + j$. Then $|\alpha| = 2^k$; $L$ is a Latin square of index one by
Propositions 3.1–3.2; and since $x + x = 0$ for all $x$, the group has exponent
two, so $L$ is PRS by Theorem 4.2. $\qquad\blacksquare$

**Small cases.** For $k=1$ the witness is the single-bit XOR table (order $2$).
For $k=2$ it is the Klein four-group table (order $4$), the $4 \times 4$ XOR of
two-bit strings. For $k=3$ it is the three-bit XOR table (order $8$). These are
precisely the XOR/addition tables ubiquitous in coding theory and symmetric
cryptography.

## 7. Discussion and future directions

**What is settled.** For squares arising as group Cayley tables, the conjecture
is completely proven in both directions (Theorem 5.4). The constructive half —
existence of a PRS index-one square at every power of two — holds in full
generality (Theorem 6.1). The engine of the equivalence is the keystone Theorem
4.2, which converts the column-pair reflection condition into the exponent-two
identity and thereby into the arithmetic of $2$-groups.

**The open direction.** The genuinely open part is the "only if" direction for
*arbitrary* PRS index-one squares:

> If a PRS Latin square of order $n$ with index one exists, must $n$ be a power
> of two?

Our results settle this whenever the square is (isotopic to) a group table. The
obstruction to the general case is that not every Latin square is a group table:
the smallest non-group Latin square already appears at order five. Controlling
such squares requires invariants that survive the loss of group structure.
Concrete avenues:

- **Autotopism / difference invariants.** Attach to a PRS square the multiset of
  column-pair "difference" permutations $\sigma_{j_1,j_2}$ (row-to-row transition
  maps) and study the constraints reflection symmetry imposes; seek an
  $\mathbb{F}_2$-linear invariant that persists for non-group squares.
- **Quasigroup formulation.** State PRS for a general quasigroup $(Q, *)$ and
  determine the identities it forces. The exponent-two condition $x * x = e$
  should generalize to a Steiner-like identity, giving a route to $|Q| = 2^k$.
- **Character / Fourier method.** For abelian-group squares, PRS is a statement
  about $\pm 1$ characters. A Fourier-analytic obstruction may extend to the
  general setting and force the power-of-two conclusion directly.

**Reusable framework.** The definitions of Latin square, pair count, pairwise
reflection symmetry, index $\le 1$, and the Cayley pair-count formula are stated
generically and support future work on symmetric Latin squares of any origin.

## References (background, standard)

The material on Latin squares and design theory, finite $p$-groups, and
elementary abelian groups is classical and can be found in standard texts on
combinatorial design theory and finite group theory. No specialized external
result is required beyond the structure theorem for finite $p$-groups used in
Theorem 5.1.
