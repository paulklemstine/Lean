# Exact One-Cell Uniformity for Finite Latin Squares

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Applications (combinatorics of designs; probabilistic combinatorics)

## Abstract

A *Latin square* of order $n$ is an $n \times n$ array over an $n$-element symbol
set in which every row and every column is a bijection. Latin squares are the
combinatorial backbone of experimental design, scheduling, coding, and certain
cryptographic constructions, and their uniform-random behavior is a central object
of study. We prove an *exact* uniformity result at the level of a single cell: for
any fixed cell $(r,c)$ and any fixed symbol $s$, the number of order-$n$ Latin
squares whose $(r,c)$ entry equals $s$ is exactly $N/n$, where $N$ is the total
number of order-$n$ Latin squares. Equivalently, in division-free form,
$N = n \cdot \#\{L : L(r,c) = s\}$. The proof is purely structural and avoids any
counting of $N$ itself: (i) the symmetric group $\operatorname{Sym}(n)$ acts on
Latin squares by relabelling symbols, an action that preserves the Latin property;
(ii) for any two symbols $s,t$ the transposition $(s\,t)$ induces an explicit
involutive bijection between the cell-fiber of $s$ and the cell-fiber of $t$,
proving all $n$ cell-fibers equinumerous; (iii) partitioning all Latin squares by
the symbol occupying $(r,c)$ expresses the whole type as a $\Sigma$-type over the
$n$ fibers, and summing the constant fiber count gives the result. This is the
exact $k=1$ case of the conjecture that a fixed legal partial pattern of $k$
entries occurs in a uniform random Latin square with probability $\sim n^{-k}$; we
discuss how the same group-action machinery is designed to climb to larger $k$. A
self-contained statement of every definition and result, with full proof sketches,
is given inline.

## 1. Introduction

### 1.1 Latin squares and why their statistics matter

Fix $n \in \mathbb{N}$ and identify the symbol set, the row index set, and the
column index set all with $\{0, 1, \dots, n-1\}$ (formally `Fin n`). A *Latin
square of order $n$* is a function $L : \{0,\dots,n-1\}^2 \to \{0,\dots,n-1\}$,
written $L(r,c)$, such that every row map $c \mapsto L(r,c)$ and every column map
$r \mapsto L(r,c)$ is injective — equivalently bijective, since domain and codomain
are finite of equal size. The number $N = N(n)$ of order-$n$ Latin squares grows
super-exponentially: $N(1{:}7) = 1, 2, 12, 576, 161280, 812851200,
61479419904000$, and no closed form is known.

Because exact enumeration is hopeless beyond small $n$, the modern theory is
heavily *probabilistic*: one samples $L$ uniformly from the $N$ squares of order
$n$ and asks about the distribution of local features — the symbol in a cell, the
pattern on a set of cells, the number of fixed points of $L$ viewed as a family of
permutations, the number of intercalates ($2\times 2$ Latin subsquares), and so on.
Such questions drive applications in randomized experimental design, in the
analysis of MCMC samplers for Latin squares, and in coding and cryptography where
"a random Latin square" is the idealized object one approximates.

The simplest local feature is the content of a single cell. It is folklore that a
uniform random Latin square has each symbol equally likely in each cell. This paper
gives a complete, structural, and *exact* proof of that statement, and frames it as
the verified base case of a pattern-frequency program.

### 1.2 The pattern-frequency conjecture

A *partial Latin pattern* of size $k$ is a set of $k$ triples
$\{(r_i, c_i, s_i)\}_{i=1}^k$ satisfying the partial Latin condition: no two
distinct triples agree in both row and column, both row and symbol, or both column
and symbol. For $n$ large enough to contain all the coordinates, view $P$ as a
partial filling of an order-$n$ board, and say $L$ *contains* $P$ if
$L(r_i,c_i) = s_i$ for all $i$.

> **Conjecture (pattern frequency).** For each fixed partial Latin pattern $P$ of
> size $k$, if $L$ is uniform over order-$n$ Latin squares then
> $\Pr[L \text{ contains } P]\cdot n^k \to 1$ as $n \to \infty$.

The heuristic is that pinning down each of the $k$ entries costs a factor of $n$
and, asymptotically, the $k$ constraints decouple. The present work proves the
$k=1$ instance — and proves it as an *exact identity for every $n$*, not merely an
asymptotic one: a single pinned entry occurs with probability exactly $n^{-1}$.

### 1.3 Contributions

1. A clean type-theoretic model of Latin squares with verified finiteness and
   decidable equality (Definition 1, Proposition 2).
2. The symbol-relabelling action of $\operatorname{Sym}(n)$ on Latin squares, with
   verified axiom-preservation and monoid-action laws (Definition 3, Lemma 4).
3. An explicit involutive fiber bijection induced by a transposition, proving all
   $n$ single-cell fibers equinumerous (Theorem 5).
4. The single-cell $\Sigma$-decomposition (Lemma 6) and the resulting **exact
   one-cell uniformity theorem** $N = n \cdot \#\{L : L(r,c)=s\}$ (Theorem 7).
5. Algorithms and numerical demonstrations confirming the exact count for
   $n \le 6$, and a roadmap for $k \ge 2$.

## 2. The model

### Definition 1 (Latin square)

A *Latin square of order $n$* is a triple $(\mathrm{val}, \mathrm{row\_inj},
\mathrm{col\_inj})$ where $\mathrm{val} : \mathrm{Fin}\,n \to \mathrm{Fin}\,n \to
\mathrm{Fin}\,n$ and

$$
\mathrm{row\_inj} : \forall r,\ \text{the map } c \mapsto \mathrm{val}(r,c) \text{ is injective},
$$
$$
\mathrm{col\_inj} : \forall c,\ \text{the map } r \mapsto \mathrm{val}(r,c) \text{ is injective}.
$$

We write $L(r,c)$ for $\mathrm{val}(r,c)$ and denote the type of these objects by
$\mathrm{LatinSquare}(n)$.

*Remark (extensionality).* The two injectivity components are propositions, so two
Latin squares are equal precisely when their underlying arrays agree:
$L_1 = L_2 \iff \mathrm{val}_{L_1} = \mathrm{val}_{L_2}$. This is recorded as the
extensionality lemma and licenses treating a Latin square as "its array, known to
be Latin."

### Proposition 2 (finiteness and decidability)

For every $n$, the type $\mathrm{LatinSquare}(n)$ is finite, and equality of Latin
squares is decidable. Hence $N(n) := \#\mathrm{LatinSquare}(n)$ is a well-defined
natural number.

*Proof sketch.* The map $L \mapsto (\mathrm{val}_L, \mathrm{row\_inj}_L,
\mathrm{col\_inj}_L)$ is a bijection between $\mathrm{LatinSquare}(n)$ and the
subtype of arrays $f : \mathrm{Fin}\,n \to \mathrm{Fin}\,n \to \mathrm{Fin}\,n$
satisfying the conjunction of the row- and column-injectivity predicates (this is
the `equivSubtype` equivalence). The ambient array type is a finite function type
between finite types, hence finite; the defining predicate is decidable; so the
subtype is a `Fintype`, and finiteness transports across the bijection. Decidable
equality reduces, via extensionality, to equality of arrays out of a finite type
into one with decidable equality. $\qquad\blacksquare$

## 3. The relabelling action

### Definition 3 (symbol relabelling, `permAct`)

For a permutation $\sigma \in \operatorname{Sym}(\mathrm{Fin}\,n) =
\mathrm{Equiv.Perm}(\mathrm{Fin}\,n)$ and a Latin square $L$, define
$\sigma \cdot L := \mathrm{permAct}(\sigma, L)$ to be the array

$$
(\sigma \cdot L)(r,c) \;=\; \sigma\bigl(L(r,c)\bigr).
$$

This is again a Latin square: each row map of $\sigma\cdot L$ is
$\sigma \circ (c \mapsto L(r,c))$, a composition of injections, hence injective,
and likewise for columns. (This is exactly the content of the `row_inj`/`col_inj`
fields of `permAct`, which compose $\sigma.\mathrm{injective}$ with the row/column
injectivity of $L$.)

### Lemma 4 (monoid-action laws)

The assignment $(\sigma, L) \mapsto \sigma \cdot L$ is a monoid action of
$\operatorname{Sym}(\mathrm{Fin}\,n)$ on $\mathrm{LatinSquare}(n)$:

$$
1 \cdot L = L \qquad\text{and}\qquad (\sigma\tau)\cdot L = \sigma \cdot (\tau \cdot L).
$$

*Proof sketch.* Both identities hold *pointwise and definitionally*: for the unit,
$(1 \cdot L)(r,c) = \mathrm{id}(L(r,c)) = L(r,c)$, then apply extensionality
(Definition 1 remark); for compatibility, $((\sigma\tau)\cdot L)(r,c) =
(\sigma\tau)(L(r,c)) = \sigma(\tau(L(r,c))) = (\sigma\cdot(\tau\cdot L))(r,c)$,
again closed by extensionality. These are `permAct_one` and `permAct_mul`.
$\qquad\blacksquare$

The action of Definition 3 is the engine of the whole argument: it permutes the
*symbol* coordinate while leaving rows and columns fixed, and it is *transitive on
symbols* in the sense made precise next.

## 4. Equinumerous cell-fibers

Fix a cell $(r,c)$. For each symbol $t \in \mathrm{Fin}\,n$ define the *cell-fiber*

$$
F_t \;:=\; \{\, L \in \mathrm{LatinSquare}(n) : L(r,c) = t \,\}.
$$

### Theorem 5 (fiber bijection via a transposition)

For any two symbols $s, t \in \mathrm{Fin}\,n$, the relabelling by the
transposition $\mathrm{swap}(s,t)$ restricts to a bijection $F_s \xrightarrow{\ \sim\ } F_t$.
In particular $\#F_s = \#F_t$ for all $s,t$, so all $n$ cell-fibers are
equinumerous.

*Proof sketch.* Let $\tau = \mathrm{swap}(s,t)$, the permutation exchanging $s$ and
$t$ and fixing everything else. Define $\Phi : F_s \to F_t$ by $\Phi(L) =
\tau \cdot L$. This is well-defined into $F_t$: if $L(r,c) = s$ then
$(\tau \cdot L)(r,c) = \tau(s) = t$ by $\mathrm{swap\_apply\_left}$. Symmetrically,
$\Psi : F_t \to F_s$, $\Psi(L) = \tau \cdot L$, is well-defined because
$\tau(t) = s$ by $\mathrm{swap\_apply\_right}$. Finally $\Phi$ and $\Psi$ are
mutually inverse because $\tau$ is an involution: $\tau\tau = 1$, so by Lemma 4,

$$
\tau \cdot (\tau \cdot L) = (\tau\tau)\cdot L = 1 \cdot L = L,
$$

which is precisely `Equiv.swap_mul_self` followed by `permAct_mul` and
`permAct_one`. Hence $\Phi$ is a bijection (this packaged map is `fiberEquiv`).
Cardinalities of types in bijection agree, giving $\#F_s = \#F_t$. $\qquad\blacksquare$

The conceptual content of Theorem 5 is that the symbol-relabelling action is
*transitive* on the value of the chosen cell — any symbol can be carried to any
other — and an equivariant bijection forces equal fiber sizes. This is the only
place the swap is used; everything else is bookkeeping.

## 5. The cell partition and the main theorem

### Lemma 6 (single-cell $\Sigma$-decomposition)

Fix a cell $(r,c)$. There is a bijection

$$
\mathrm{LatinSquare}(n) \;\xrightarrow{\ \sim\ }\; \sum_{t \in \mathrm{Fin}\,n} F_t,
\qquad L \longmapsto (L(r,c),\, L),
$$

with inverse $(t, L) \mapsto L$ (forgetting the index, which equals $L(r,c)$).

*Proof sketch.* Every Latin square lies in exactly one fiber, namely the one
indexed by its own $(r,c)$-entry; the two round-trips are definitional once the
index is identified with $L(r,c)$. This is `sigmaEquiv`. $\qquad\blacksquare$

### Theorem 7 (exact one-cell uniformity, `card_eq_mul_card_fiber`)

For every order $n$, every cell $(r,c)$, and every symbol $s$,

$$
\boxed{\;\#\mathrm{LatinSquare}(n) \;=\; n \cdot \#\{\,L : L(r,c) = s\,\}.\;}
$$

Consequently, if $N = \#\mathrm{LatinSquare}(n) > 0$ then a uniformly random
order-$n$ Latin square satisfies $\Pr[L(r,c) = s] = 1/n$ exactly, independently of
$r$, $c$, and $s$.

*Proof sketch.* Transport cardinality across the bijection of Lemma 6 and use the
cardinality of a $\Sigma$-type ($\mathrm{Fintype.card\_sigma}$):

$$
\#\mathrm{LatinSquare}(n) \;=\; \#\Bigl(\sum_{t} F_t\Bigr) \;=\; \sum_{t \in \mathrm{Fin}\,n} \#F_t.
$$

By Theorem 5 every summand equals the *constant* $\#F_s = \#\{L : L(r,c)=s\}$.
A sum of $n$ equal constants is $n$ times that constant
($\mathrm{Finset.sum\_const}$, $\#(\mathrm{univ} : \mathrm{Fin}\,n) = n$):

$$
\sum_{t \in \mathrm{Fin}\,n} \#F_s \;=\; n \cdot \#F_s.
$$

Combining the two displays gives the boxed identity. Dividing by $N$ when $N > 0$
yields $\Pr[L(r,c)=s] = \#F_s / N = 1/n$. $\qquad\blacksquare$

*Remarks.*
- The identity is stated multiplicatively to avoid any division and to remain
  valid as a statement about natural numbers; the probabilistic corollary is a
  trivial consequence whenever $N > 0$ (i.e. always, since the cyclic square
  $L(r,c) = (r+c) \bmod n$ shows $N \ge 1$).
- The result is *uniform in the cell*: it holds for the corner, the center, or any
  other cell, because the argument never referred to the position $(r,c)$ except
  as a label.
- No knowledge of the value of $N$ is used. The theorem is a *ratio* statement
  proved by pairing, exactly the kind of argument that survives the
  super-exponential growth of $N$.

## 6. Algorithms

We describe the computational counterparts used to validate Theorem 7 numerically.

### Algorithm A — Exhaustive Latin-square enumeration by row-permutation backtracking

Generate all order-$n$ Latin squares by placing rows one at a time, each row a
permutation of $\{0,\dots,n-1\}$ that is column-compatible with all rows placed so
far (no symbol repeats in any column). Backtracking prunes the search the moment a
column conflict appears.

- **Correctness.** Row injectivity is guaranteed because each row is a permutation;
  column injectivity is enforced incrementally; every Latin square is produced
  exactly once because rows are filled in a fixed order.
- **Complexity.** Time is proportional to the size of the (heavily pruned) search
  tree; the number of full leaves is $N(n)$, which is feasible to enumerate for
  $n \le 7$ but not beyond. Space is $O(n^2)$ for the working grid plus the
  recursion stack of depth $n$.

### Algorithm B — Direct cell-fiber census and exact-uniformity verification

Given the enumerated list of order-$n$ Latin squares, tabulate, for a chosen cell
$(r,c)$, the histogram $t \mapsto \#F_t$. Algorithm B then checks two things
against Theorem 7: that the histogram is *flat* (all $n$ entries equal), and that
$N = n \cdot \#F_s$ for each $s$.

- **Correctness.** Direct realization of the fiber definition $F_t = \{L : L(r,c)=t\}$.
- **Complexity.** $O(N(n))$ time, single pass over the enumeration.

### Algorithm C — Swap-trick bijection witness

Implements the involution of Theorem 5: given a square $L$ with $L(r,c)=s$ and a
target symbol $t$, output $\tau \cdot L$ where $\tau = \mathrm{swap}(s,t)$, and
verify (i) the result is Latin, (ii) its $(r,c)$ entry is $t$, and (iii) applying
the swap twice returns $L$. This exhibits the pairing that proves $\#F_s = \#F_t$
*constructively*, square by square, rather than only through the count.

- **Complexity.** $O(n^2)$ per square for relabelling and verification.

## 7. Applications

- **Experimental design.** When a Latin-square design is drawn at random (to avoid
  experimenter bias), Theorem 7 certifies that every treatment is assigned to every
  row–column cell with identical frequency $1/n$ — the precise fairness guarantee
  that randomization is meant to deliver, now exact rather than asymptotic.
- **Sampling diagnostics.** Markov-chain samplers for Latin squares should, at
  stationarity, reproduce the flat single-cell histogram of Algorithm B. The exact
  value $1/n$ is a sharp, cheaply checkable diagnostic for sampler correctness.
- **Coding and cryptography.** Constructions that idealize "a uniform random Latin
  square" (e.g. as a randomized substitution layer) inherit the exact one-cell
  marginal $1/n$; the result is the marginal-uniformity guarantee underlying such
  idealizations.
- **Pedagogy of symmetry arguments.** The proof is a textbook-clean instance of
  "an involutive symmetry forces equal cardinalities," usable to teach the
  orbit/transitivity viewpoint with a fully concrete, hand-checkable object.

## 8. Discussion

The theorem is exact and dimension-uniform, and its proof is entirely structural:
it never enumerates Latin squares and never estimates $N$. The single mathematical
input is that the symbol-relabelling action (Definition 3) acts transitively on the
value of any single cell, instantiated minimally by the transposition in Theorem 5.
This is what makes the result robust and, crucially, *extensible*: anywhere a
symmetry group acts transitively on the feature of interest, the same three-step
template (action $\Rightarrow$ fiber bijection $\Rightarrow$ $\Sigma$-collapse)
applies.

The principal limitation is exactly the scope: the theorem speaks about *one* cell.
For a pattern with $k \ge 2$ entries the relabelling subgroup alone is no longer
transitive on the relevant feature (e.g. two cells in different rows and columns),
and the clean involution must be replaced by more refined transport, with the count
becoming a falling factorial or an orbit count rather than a single factor of $n$.

## 9. Future directions

The following build directly on the exact one-cell uniformity theorem.

**1. From one cell to a fixed pattern in a single row.** Extend exact uniformity
from one prescribed cell to a partial assignment of $k$ distinct symbols across $k$
distinct cells within one row. The key insight is that a partial injection between
$k$ cells and $k$ symbols always extends to a full symbol permutation
$\pi \in \operatorname{Sym}(\mathrm{Fin}\,n)$ (extension of partial bijections), so
the existing `permAct` action carries any admissible one-row pattern to any other
of the same shape, forcing all such pattern-fibers to be equinumerous and giving an
exact denominator $n(n-1)\cdots(n-k+1)$. The `permAct` action, its
axiom-preservation lemmas, and the fiber-counting scaffolding (`fiberEquiv`,
$\Sigma$-decomposition + $\mathrm{Fintype.card\_sigma}$) are reusable verbatim;
only the partial-bijection-extension lemma is new.

**2. Exact uniformity for isotopism orbits of small partial patterns.** Classify
and count partial patterns of size $k = 2, 3$ up to the full isotopism group (row
permutations $\times$ column permutations $\times$ symbol permutations), and prove
exact uniformity *within* each isotopism orbit. The key insight is that exact
uniformity is governed by the orbit structure of the symmetry group acting on
patterns: two patterns in the same orbit have equinumerous fibers by transport
along the connecting group element, reducing counting to orbit enumeration. The
one-cell theorem is the case where the symbol subgroup already acts transitively,
serving as the verified base case and template; small $k$ keeps orbit enumeration
finite and decidable.

**3. A reusable finite-fiber equidistribution lemma for group actions.** Abstract
the pattern into a standalone lemma: if a finite group $G$ acts on a finite type
$X$, and a map $f : X \to Y$ is $G$-equivariant for a transitive $G$-action on $Y$,
then all fibers of $f$ are equinumerous and $\#X = \#Y \cdot \#(\text{fiber})$. The
entire argument here — swap-induced fiber bijection, $\Sigma$-decomposition,
constant-sum collapse — is the special case of equivariance plus transitivity;
isolating it removes the Latin-square specifics so the same lemma discharges cells,
rows, and orbits uniformly.

## 10. Conclusion

We have given a complete, exact, and structurally transparent account of single-cell
symbol uniformity for finite Latin squares: $\#\mathrm{LatinSquare}(n) = n \cdot
\#\{L : L(r,c) = s\}$, equivalently $\Pr[L(r,c)=s] = 1/n$ for every $n$, cell, and
symbol. The proof rests on a single involutive symmetry — swapping two symbol
names — that pairs cell-fibers perfectly, and it serves as the verified $k=1$ base
case of the broader conjecture that fixed legal patterns of size $k$ occur with
probability asymptotic to $n^{-k}$. The same action-based template is poised to
climb to larger patterns and, ultimately, to a general finite-fiber
equidistribution principle.
