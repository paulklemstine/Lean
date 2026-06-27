# The Maximum Size of a Family of Mutually Orthogonal Italian Squares

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Combinatorics / Finite Geometry (Novelty)

## Abstract

An *Italian square* on a finite symbol set $\alpha$ is an $\alpha \times
\alpha$ array of symbols from $\alpha$ in which every row and every column
is a bijection of $\alpha$; this is precisely the classical notion of a
Latin square of order $n = |\alpha|$. Two Italian squares $L, M$ are
*orthogonal* when their superposition $(i,j) \mapsto (L(i,j), M(i,j))$ is a
bijection of $\alpha \times \alpha$, i.e. each ordered pair of symbols
arises from exactly one cell. We study families of *mutually orthogonal*
Italian squares (every pair in the family is orthogonal) and establish a
sharp bound on their size. We prove that for $n \ge 2$ any such family has
at most $n - 1$ members, and that this bound is attained whenever $n$ is a
prime power, via the affine construction $S_a(i,j) = a\cdot i + j$ over a
finite field. We further record the equivalence between maximal families
and orthogonal arrays of strength two and index one, which exposes the
geometric content of the extremal case: a complete family of $n-1$ squares
is the same data as a finite affine plane of order $n$. We discuss the
resulting open problem — whether the bound can be attained for orders that
are not prime powers — its equivalence to the existence of finite planes,
algorithmic aspects, applications, and several concrete directions for
extending the theory.

## 1. Introduction

The combinatorics of Latin squares — here renamed *Italian squares* to
match the catalog's framing — is among the oldest and richest subjects in
discrete mathematics, with roots in Euler's 1782 problem of the
thirty-six officers. The central quantitative invariant of order $n$ is
$$N(n) := \text{the maximum number of pairwise orthogonal squares of order } n.$$
Two classical facts pin down $N(n)$ for the most important orders:

1. **Upper bound:** $N(n) \le n - 1$ for all $n \ge 2$.
2. **Attainment for prime powers:** $N(p^k) = p^k - 1$ for every prime $p$
   and exponent $k \ge 1$.

The exact value of $N(n)$ for general composite $n$ — in particular,
whether $N(n) = n-1$ can hold when $n$ is not a prime power — is a famous
open problem, equivalent to the existence of a finite projective (equally,
affine) plane of order $n$.

This paper presents a clean, fully self-contained development of facts (1)
and (2), together with the orthogonal-array reformulation that explains
*why* equality is a geometric phenomenon. The results have been formalized
and machine-checked; here we present the mathematics in conventional prose
with complete proof sketches.

### Contributions

- A short, structural proof of the upper bound $N(n) \le n-1$ (Theorem 3.1,
  `card_le_card_sub_one`) using only row/column bijectivity and the
  injectivity half of orthogonality.
- The affine field construction and a self-contained verification that
  distinct slopes give orthogonal squares (Lemma 4.2,
  `affineSquare_orthogonal`), yielding tightness over any finite field
  (Theorem 4.3, `exists_mols_card_eq_card_sub_one`; Theorem 4.4,
  `maximum_mols_eq_card_sub_one`).
- The prime-power realization $N(p^k) = p^k - 1$ via Galois fields
  (Theorem 4.5, `exists_mols_prime_power`).
- The orthogonal-array reformulation (Definition 5.1, `IsOA`; Construction
  5.2, `oaOfMols`; Theorem 5.3, `isOA_oaOfMols`) and its geometric reading.

## 2. Definitions

Throughout, $\alpha$ is a finite set of symbols, $n = |\alpha|$, and all
indices range over $\alpha$ unless stated otherwise. We freely identify an
Italian square with a function $\alpha \to \alpha \to \alpha$.

**Definition 2.1 (Italian square).** An *Italian square* on $\alpha$ is a
map $L : \alpha \to \alpha \to \alpha$, written $L(i,j)$ for the symbol in
row $i$ and column $j$, such that:

- (rows) for every fixed row $i$, the map $j \mapsto L(i,j)$ is a bijection
  of $\alpha$;
- (columns) for every fixed column $j$, the map $i \mapsto L(i,j)$ is a
  bijection of $\alpha$.

Equivalently, each symbol occurs exactly once in each row and exactly once
in each column. This is the classical Latin square of order $n$.

**Definition 2.2 (Orthogonality).** Two Italian squares $L, M$ on $\alpha$
are *orthogonal*, written $L \perp M$, if the superposition map
$$\Phi_{L,M} : \alpha \times \alpha \to \alpha \times \alpha, \qquad
\Phi_{L,M}(i,j) = \big(L(i,j),\, M(i,j)\big)$$
is a bijection. Since the domain and codomain are finite of equal size,
$\Phi_{L,M}$ is a bijection iff it is injective iff it is surjective; thus
$L \perp M$ exactly when every ordered pair $(u,v) \in \alpha \times \alpha$
arises from exactly one cell $(i,j)$.

**Definition 2.3 (Mutually orthogonal family).** A family of Italian
squares $\{L_t\}_{t \in K}$ indexed by a finite set $K$ is *mutually
orthogonal* if $L_s \perp L_t$ for all distinct $s, t \in K$. We write
$N(n)$ for the maximum cardinality of such a family on a symbol set of size
$n$.

## 3. The Upper Bound

**Theorem 3.1 (`card_le_card_sub_one`).** *Let $\alpha$ be a finite symbol
set with $|\alpha| = n \ge 2$, and let $\{L_t\}_{t \in K}$ be a finite
mutually orthogonal family of Italian squares on $\alpha$. Then*
$$|K| \le n - 1.$$

*Proof sketch.* Since $n \ge 2$ we may fix two distinct symbols $x_0 \ne
x_1$ in $\alpha$, used as two distinguished row indices.

For each index $t \in K$, the row $i = x_0$ of $L_t$ is a bijection
$j \mapsto L_t(x_0, j)$. Hence there is a *unique* column $a(t) \in \alpha$
with
$$L_t\big(x_0,\, a(t)\big) = L_t(x_1, x_0). \tag{$\ast$}$$
(Existence and uniqueness are exactly surjectivity and injectivity of the
top row.) This defines a function $a : K \to \alpha$.

*Claim 1: $a(t) \ne x_0$ for every $t$.* If $a(t) = x_0$, then $(\ast)$
reads $L_t(x_0, x_0) = L_t(x_1, x_0)$, i.e. the column $j = x_0$ takes the
same value at the two distinct rows $x_0$ and $x_1$. This contradicts
injectivity of the column map $i \mapsto L_t(i, x_0)$.

*Claim 2: $a$ is injective.* Suppose $a(s) = a(t) =: a$ with $s \ne t$.
By $(\ast)$,
$$L_s(x_0, a) = L_s(x_1, x_0), \qquad L_t(x_0, a) = L_t(x_1, x_0).$$
Consider the superposition $\Phi_{L_s, L_t}$. Evaluating at the cells
$(x_1, x_0)$ and $(x_0, a)$ gives, respectively,
$$\big(L_s(x_1,x_0),\, L_t(x_1,x_0)\big) \quad\text{and}\quad
\big(L_s(x_0,a),\, L_t(x_0,a)\big),$$
and the two displayed equations show these pairs are *equal*. By
orthogonality $\Phi_{L_s, L_t}$ is injective, so the two cells coincide:
$(x_1, x_0) = (x_0, a)$. In particular $x_1 = x_0$, a contradiction.

Combining the claims, $a$ is an injection from $K$ into $\alpha \setminus
\{x_0\}$, a set of size $n - 1$. Therefore $|K| \le n - 1$. $\qquad\blacksquare$

The proof uses only column injectivity of each square (Claim 1) and the
injectivity direction of orthogonality (Claim 2). No standardization of
the squares is required, in contrast to the usual textbook argument that
relabels each square so its first row is the identity.

## 4. Attainment over Finite Fields

We now show the bound of Theorem 3.1 is best possible whenever $n$ is a
prime power, by exhibiting an explicit extremal family. Let $F$ be a
finite field with $|F| = n$.

**Definition 4.1 (Affine square).** For a nonzero slope $a \in F$ define
$$S_a : F \to F \to F, \qquad S_a(i,j) = a\cdot i + j.$$

**Lemma 4.1a.** *For every $a \in F$ each row $j \mapsto a\cdot i + j$ is a
bijection of $F$; for every nonzero $a$ each column $i \mapsto a\cdot i + j$
is a bijection of $F$. Hence $S_a$ is an Italian square for $a \ne 0$.*

*Proof.* The row map is the translation $j \mapsto j + a\cdot i$, a
bijection with inverse $j \mapsto j - a\cdot i$. The column map is
$i \mapsto a\cdot i + j$; injectivity follows from cancellation of the
nonzero factor $a$ ($a\cdot i = a\cdot i' \Rightarrow i = i'$), and
surjectivity from $i = (v - j)/a$ solving $a\cdot i + j = v$. $\qquad\blacksquare$

**Lemma 4.2 (`affineSquare_orthogonal`).** *If $a, b \in F$ are nonzero and
$a \ne b$, then $S_a \perp S_b$.*

*Proof sketch.* It suffices to prove $\Phi_{S_a, S_b}$ is injective.
Suppose
$$a\cdot i + j = a\cdot i' + j' \qquad\text{and}\qquad
b\cdot i + j = b\cdot i' + j'.$$
Subtracting the second equation from the first cancels the $j, j'$ terms:
$(a - b)\cdot i = (a - b)\cdot i'$. Since $a \ne b$, the element $a - b$ is
nonzero and therefore invertible in the field, so $i = i'$. Substituting
back into the first equation gives $j = j'$. Thus $(i,j) = (i', j')$ and the
superposition is injective, hence bijective. Surjectivity can also be
exhibited directly: the pair $(u, v)$ is hit by the cell
$$i = \frac{u - v}{a - b}, \qquad j = u - a\cdot i. \qquad\blacksquare$$

The decisive hypothesis is that $F$ is a *field*: invertibility of $a - b$
is what makes distinct slopes orthogonal. Over a general commutative ring
the construction fails when $a - b$ is a zero divisor.

**Theorem 4.3 (Tightness, `exists_mols_card_eq_card_sub_one`).** *Let $F$
be a finite field with $|F| = n \ge 2$. The family $\{S_a\}_{a \in F
\setminus \{0\}}$ is mutually orthogonal and has exactly $n - 1$ members.*

*Proof.* By Lemma 4.1a each $S_a$ ($a \ne 0$) is an Italian square, and by
Lemma 4.2 any two with distinct slopes are orthogonal; the index set is
$F \setminus \{0\}$, of cardinality $n - 1$. $\qquad\blacksquare$

**Theorem 4.4 (Exact maximum over a field,
`maximum_mols_eq_card_sub_one`).** *Let $F$ be a finite field with $|F| = n
\ge 2$. Then a mutually orthogonal family of Italian squares on $F$ of size
$n - 1$ exists (Theorem 4.3), and every such family has size at most $n - 1$
(Theorem 3.1). Hence the maximum size is exactly $n - 1$.*

**Theorem 4.5 (Prime-power realization, `exists_mols_prime_power`).** *For
every prime $p$ and every exponent $k \ge 1$, writing $n = p^k$, there
exist exactly $n - 1$ mutually orthogonal Italian squares of order $n$.*

*Proof.* The Galois field $GF(p^k)$ has exactly $p^k$ elements; apply
Theorem 4.3 with $F = GF(p^k)$. $\qquad\blacksquare$

Thus $N(p^k) = p^k - 1$ for every prime power. Together with Theorem 3.1
this completely determines $N(n)$ at all prime-power orders.

## 5. The Orthogonal-Array Reformulation and the Geometry of Equality

The extremal case has a clean structural explanation through *orthogonal
arrays*, which also clarifies why attainment beyond prime powers is open.

**Definition 5.1 (Orthogonal array, `IsOA`).** Let $\iota$ be a finite
index set of *columns*. An array $A : (\,\text{Fin } n \times \text{Fin }
n) \to (\iota \to \text{Fin } n)$ — assigning to each *run* $p$ a tuple
$A(p)$ of symbols indexed by $\iota$ — is an *orthogonal array of strength
$2$ and index $1$*, denoted $OA(n, |\iota|)$, if for every pair of distinct
columns $c \ne d$ the map
$$p \mapsto \big(A(p)_c,\, A(p)_d\big)$$
is a bijection of $\text{Fin } n \times \text{Fin } n$. Equivalently, in any
two columns every ordered pair of symbols occurs in exactly one run.

**Construction 5.2 (`oaOfMols`).** Given a family $\{L_t\}_{t \in
\text{Fin } k}$ of Italian squares of order $n$, define an array with
columns indexed by $\text{Bool} \oplus \text{Fin } k$ (two coordinate
columns plus one column per square):
$$A(i,j)_c = \begin{cases}
i & c = \mathrm{inl}\ \mathrm{false} \quad (\text{row column}),\\
j & c = \mathrm{inl}\ \mathrm{true} \quad (\text{column column}),\\
L_t(i,j) & c = \mathrm{inr}\ t \quad (\text{square } t).
\end{cases}$$

**Theorem 5.3 (`isOA_oaOfMols`).** *If the family $\{L_t\}$ is pairwise
orthogonal, then $A = \mathrm{oaOfMols}(L)$ is an orthogonal array
$OA(n, k+2)$.*

*Proof sketch.* One checks the strength-$2$ condition for each of the
qualitatively distinct pairs of columns:

- *(row, column):* $p \mapsto (i, j)$ is the identity, a bijection.
- *(row, square $t$):* $p \mapsto (i, L_t(i,j))$ is a bijection because each
  row of $L_t$ is a bijection (row bijectivity).
- *(column, square $t$):* $p \mapsto (j, L_t(i,j))$ is a bijection because
  each column of $L_t$ is a bijection (column bijectivity).
- *(square $s$, square $t$), $s \ne t$:* $p \mapsto (L_s(i,j), L_t(i,j))$ is
  a bijection by orthogonality $L_s \perp L_t$.

The reversed-coordinate pairs are bijections by symmetry (composition with
the coordinate swap). $\qquad\blacksquare$

The converse construction recovers a mutually orthogonal family from an
$OA(n, k+2)$ by reading two of its columns as coordinates and the rest as
squares. Hence:

> A family of $k$ mutually orthogonal Italian squares of order $n$ is the
> *same data* as an orthogonal array $OA(n, k+2)$.

**The extremal case is a plane.** Setting $k = n - 1$ (the maximum) gives
$k + 2 = n + 1$ columns. A *complete* orthogonal array $OA(n, n+1)$ is
exactly the incidence structure of a finite **affine plane of order $n$**
(equivalently a projective plane of order $n$): the $n + 1$ columns are the
$n + 1$ parallel classes of lines, and the strength-$2$, index-$1$ condition
is precisely the axiom that two non-parallel lines meet in a unique point.
Consequently:

> **Characterization of equality.** A complete set of $n - 1$ mutually
> orthogonal Italian squares of order $n$ exists **if and only if** a finite
> affine plane of order $n$ exists.

This is why prime powers are exactly the orders where attainment can be
*proved*: a finite field of order $p^k$ furnishes a plane (its lines are the
graphs $y = a\cdot x + b$), which is precisely the affine family of Section
4. For general $n$ the existence of a plane — hence the attainment of the
bound — is open. The Bruck–Ryser–Chowla theorem rules out infinitely many
orders (e.g. $6$), and order $10$ was excluded by exhaustive computation,
but no plane is known of non-prime-power order and none has been proved
impossible in general.

## 6. Algorithms

The constructive content of Sections 4–5 yields directly executable
procedures.

**Algorithm A (Affine MOLS generator).** *Input:* a prime power $n$ and a
model of the field $GF(n)$ with addition and multiplication tables.
*Output:* the $n - 1$ mutually orthogonal squares $S_a$. For each nonzero
$a$ and each pair $(i,j)$ emit $S_a(i,j) = a\cdot i + j$. Complexity:
$\Theta(n^3)$ time and space to write down all $n - 1$ squares of $n^2$
cells. For prime $n$ the field is $\mathbb{Z}/n\mathbb{Z}$ and no table is
needed; for $n = p^k$ with $k > 1$ one works in $\mathbb{F}_p[x]/(f)$ for an
irreducible $f$ of degree $k$.

**Algorithm B (Orthogonality verifier).** *Input:* two $n \times n$ arrays
$L, M$. *Output:* whether $L \perp M$. Initialize an $n \times n$ Boolean
grid of "seen pairs"; scan all $n^2$ cells, mark $(L(i,j), M(i,j))$, and
report failure on a repeat. The family is mutually orthogonal iff all
$\binom{k}{2}$ pairs pass. Complexity: $\Theta(n^2)$ per pair,
$\Theta(k^2 n^2)$ for the whole family.

**Algorithm C (Latin-square validator).** *Input:* an $n \times n$ array.
*Output:* whether it is an Italian square. Check that each row and each
column is a permutation of the symbol set (each symbol appears exactly
once). Complexity: $\Theta(n^2)$.

## 7. Applications

Mutually orthogonal squares are foundational across several applied
disciplines:

- **Design of experiments.** A pair of orthogonal squares yields a
  *Graeco-Latin square*, the standard device for blocking two nuisance
  factors (rows and columns) while testing treatments so that every
  treatment meets every level of each blocking factor exactly once. Larger
  MOLS families support higher-dimensional balanced designs.
- **Error-correcting codes.** A complete set of $n - 1$ MOLS of order $n$
  (a finite plane) gives rise to optimal codes: the runs of the orthogonal
  array form an MDS code meeting the Singleton bound, the combinatorial
  cousins of Reed–Solomon codes.
- **Combinatorial design and scheduling.** MOLS construct resolvable
  designs, transversal designs, and conflict-free schedules for tournaments
  and frequency-assignment problems.
- **Cryptography and secret sharing.** The "every pair once" balance gives
  threshold and visual secret-sharing schemes with provable uniformity.
- **Finite geometry.** Via Section 5, the theory is the algebraic engine for
  constructing and studying finite affine and projective planes.

## 8. Discussion

The two halves of the story illustrate a recurring theme in extremal
combinatorics: a counting bound that is *easy and universal*, paired with an
attainment question that is *hard and arithmetic*. The bound $N(n) \le n-1$
follows from local injectivity arguments that know nothing about the
arithmetic of $n$. Attainment, by contrast, is governed by the global
existence of an algebraic or geometric object — a field, equivalently a
plane — and is sensitive to the factorization of $n$ in ways that remain
mysterious.

The orthogonal-array bridge is what reconciles the two: it converts the
analytic statement "$n-1$ squares exist" into the geometric statement "a
plane of order $n$ exists," transferring the problem to a domain where
powerful nonexistence tools (Bruck–Ryser–Chowla) and, occasionally, heroic
computations (order $10$) apply. The proof of the upper bound even hints at
the geometry: the injection $t \mapsto a(t)$ becomes a *bijection* exactly
at the extremal size, and the resulting parallel-class structure is the
missing plane.

## 9. Future Directions

Building on the development above (carried out over an arbitrary finite
carrier, so that prime-power-order squares may live directly over a finite
field), several concrete directions present themselves.

1. **The reverse implication.** Prove that the existence of $n-1$ mutually
   orthogonal squares of order $n$ forces a finite plane of order $n$
   (conjecturally a prime power). The upper-bound proof already constructs
   the injection whose surjectivity at the extremal size *is* the plane's
   parallel-class structure; formalizing this equivalence reduces the open
   "iff prime power" question to the prime-power conjecture for planes.

2. **MacNeish's product bound.** Establish $N(m\cdot n) \ge \min(N(m),
   N(n))$, hence $N(n) \ge \min_{p^a \,\|\, n}(p^a - 1)$, via the Kronecker
   product of squares on $\alpha \times \beta$. Because orthogonality is
   preserved under this product, this gives the first nontrivial *lower*
   bound for composite orders with essentially no new machinery.

3. **Self-orthogonal and symmetric squares.** Determine the orders admitting
   a self-orthogonal square (orthogonal to its own transpose); the affine
   square $a\cdot i + j$ is orthogonal to its transpose $a\cdot j + i$
   precisely when $a^2 \ne 1$, so the question is governed by the
   multiplicative orders of field elements, mirroring the $a - b \ne 0$
   cancellation used in attainment.

4. **Frequency ("tricolore") squares.** Relax the bound for frequency
   squares of order $n$ in which each symbol occurs $n/k$ times per row and
   column ($k \mid n$), and study how the maximum family size depends on the
   frequency parameter.

## 10. Conclusion

We have given a complete, self-contained account of the maximum size of a
family of mutually orthogonal Italian (Latin) squares: the universal upper
bound $N(n) \le n - 1$, its attainment $N(p^k) = p^k - 1$ at every prime
power through the affine field construction, and the orthogonal-array
reformulation that recasts the extremal case as the existence of a finite
plane. The proofs are elementary in their tools yet sharp in their
conclusions, and they delineate precisely the frontier — attainment at
non-prime-power orders — where one of the oldest questions in combinatorics
still stands open.
