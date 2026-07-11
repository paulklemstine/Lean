# Topological Quantum Codes from Cellular Homology: Logical Qubits as Betti Numbers and Distance as the Systole

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

We develop the homological theory of Calderbank–Shor–Steane (CSS) quantum
error-correcting codes over the binary field $\mathbb{F}_2$, presenting every such
code as a length-three chain complex $C_2 \xrightarrow{\partial_2} C_1
\xrightarrow{\partial_1} C_0$ with $\partial_1 \circ \partial_2 = 0$. In this
framework the physical qubits are the middle chains $C_1$, the stabilizers are the
rows of the two boundary maps, and the encoded logical qubits are precisely the
first homology group $H_1 = \ker\partial_1 / \operatorname{im}\partial_2$. We
prove four principal results. First, the **CSS Dimension Theorem**: the number of
logical qubits obeys the exact conservation law $k + \operatorname{rank}
\partial_1 + \operatorname{rank}\partial_2 = n$, where $n$ is the number of
physical qubits. Second, the **Homological Information Criterion**: a code stores
at least one logical qubit if and only if its first homology is nontrivial,
$\operatorname{im}\partial_2 \subsetneq \ker\partial_1$. Third, the **Genus
Theorem**: the minimal cellular complex of a closed orientable genus-$g$ surface
yields a code with exactly $k = 2g$ logical qubits, and recovers the Euler
characteristic $\chi = 2 - 2g$. Fourth, we define **code distance as the
homological systole** — the minimum Hamming weight of a nontrivial homology
representative — and establish its basic laws (positivity for information-bearing
codes, and the shortest-loop upper bound), illustrated by an explicit $[[3,1,3]]$
triangle code with genuinely nonzero boundary map. We close with conjectures on
homological packing bounds, the topological invariance of the rate, and the
advantage of hyperbolic tessellations.

## 1. Introduction

Quantum information is fragile: local interactions with the environment rapidly
decohere superpositions. Quantum error correction protects information by encoding
a small number of *logical* qubits into a larger register of *physical* qubits, so
that low-weight errors can be detected and reversed by measuring commuting parity
checks (*stabilizers*). The **surface code** and its relatives achieve this by a
striking mechanism: the logical information is stored not in any local subsystem
but in a *global topological* degree of freedom of a cellulated surface, immune to
any local error.

The purpose of this paper is to make the informal slogan "logical qubits =
homology, distance = systole" fully precise as a sequence of exact theorems, for a
general CSS code presented as a chain complex over $\mathbb{F}_2$. The upshot is a
clean dictionary between coding theory and algebraic topology in which the three
code parameters $[[n, k, d]]$ correspond respectively to the dimension of the
chain space, the first Betti number, and the systole of the underlying complex.

Throughout, $\mathbb{F}_2 = \{0,1\}$ denotes the two-element field, in which
$1 + 1 = 0$. All vector spaces are finite dimensional over $\mathbb{F}_2$, and
$\dim$ denotes dimension over $\mathbb{F}_2$.

## 2. Chain complexes and CSS codes

### 2.1 Definition

**Definition 2.1 (CSS code as chain complex).** A *binary CSS code* is a triple of
finite-dimensional $\mathbb{F}_2$-vector spaces together with two linear boundary
maps,
$$C_2 \xrightarrow{\ \partial_2\ } C_1 \xrightarrow{\ \partial_1\ } C_0,$$
satisfying the *chain-complex condition*
$$\partial_1 \circ \partial_2 = 0.$$
Concretely we take $C_j = \mathbb{F}_2^{\,n_j}$; the integer $n_1 =: n$ is the
number of *physical qubits*. The rows of $\partial_1$ are the *$Z$-type
stabilizers* (vertex checks), and the columns of $\partial_2$ are the *$X$-type
stabilizers* (face checks). The chain-complex condition is exactly the requirement
that the two stabilizer families commute, which is what makes the code well
defined.

**Definition 2.2 (cycles, boundaries, homology).** Given a CSS code we set
$$Z := \ker \partial_1 \quad (\text{the } Z\text{-cycles}), \qquad
B := \operatorname{im} \partial_2 \quad (\text{the } Z\text{-boundaries}).$$
The chain-complex condition gives the fundamental inclusion
$$B \subseteq Z,$$
since for any $x$, $\partial_1(\partial_2 x) = 0$ shows $\partial_2 x \in
\ker\partial_1$. The *first homology group* is the quotient
$$H_1 := Z / B = \ker\partial_1 / \operatorname{im}\partial_2.$$

**Definition 2.3 (logical qubits).** The number of *logical qubits* is
$$k := \dim H_1 = \dim(\ker\partial_1) - \dim(\operatorname{im}\partial_2).$$
(The subtraction is well posed because $B \subseteq Z$.) The nonnegative integers
$\operatorname{rank}\partial_1 = \dim(\operatorname{im}\partial_1)$ and
$\operatorname{rank}\partial_2 = \dim(\operatorname{im}\partial_2)$ are the ranks
of the two stabilizer matrices.

### 2.2 The dimension theorem

**Theorem 2.4 (CSS Dimension Theorem).** For every CSS code,
$$k + \operatorname{rank}\partial_1 + \operatorname{rank}\partial_2 = n.$$

*Proof sketch.* By the rank–nullity theorem applied to $\partial_1 : C_1 \to
C_0$,
$$\dim(\ker\partial_1) + \operatorname{rank}\partial_1 = \dim C_1 = n.$$
By definition $k = \dim(\ker\partial_1) - \operatorname{rank}\partial_2$ (using
$\operatorname{rank}\partial_2 = \dim B$). Substituting $\dim(\ker\partial_1) = k
+ \operatorname{rank}\partial_2$ into the rank–nullity identity and using
$\operatorname{rank}\partial_2 \le \dim(\ker\partial_1)$ (which holds because
$B \subseteq Z$) to justify the natural-number subtraction gives
$$k + \operatorname{rank}\partial_2 + \operatorname{rank}\partial_1 = n. \qquad
\square$$

This is a conservation law: each physical qubit is either consumed by one
independent stabilizer (of $Z$- or $X$-type) or contributes to protected logical
information. It also gives a purely matrix-theoretic recipe for $k$: compute two
ranks and subtract from $n$.

### 2.3 The information criterion

**Theorem 2.5 (Homological Information Criterion).** A CSS code satisfies $k \ge 1$
if and only if $B \subsetneq Z$, i.e. if and only if $H_1 \ne 0$.

*Proof sketch.* ($\Leftarrow$) If $B \subsetneq Z$ then, since both are finite
dimensional and $B \subseteq Z$, strict inclusion forces $\dim B < \dim Z$, hence
$k = \dim Z - \dim B \ge 1$. ($\Rightarrow$) If $k \ge 1$ then $\dim B < \dim Z$,
so $B \ne Z$; combined with the always-true inclusion $B \subseteq Z$ this yields
$B \subsetneq Z$. $\square$

In words: a code stores information exactly when there is a cycle that is not a
boundary — a nontrivial element of first homology. A simply connected complex
($H_1 = 0$) encodes nothing.

## 3. The genus-$g$ surface code

We now instantiate the framework on the topologically richest small example.

**Definition 3.1 (minimal surface complex).** The closed orientable surface of
genus $g$ admits a minimal CW decomposition with one $0$-cell, $2g$ $1$-cells, and
one $2$-cell, the face being attached along the standard relator $\prod_{i=1}^{g}
[a_i, b_i]$. As a CSS code this is
$$n_0 = 1, \quad n_1 = 2g, \quad n_2 = 1,$$
with both boundary maps equal to zero: over $\mathbb{F}_2$ each generator occurs
an even number of times in the attaching word $\prod_i [a_i,b_i]$, so
$\partial_2 = 0$; and every $1$-cell is a loop at the single vertex, so
$\partial_1 = 0$. The chain-complex condition $\partial_1\partial_2 = 0$ holds
trivially.

**Theorem 3.2 (Genus Theorem).** The genus-$g$ surface code encodes exactly
$$k = 2g$$
logical qubits.

*Proof sketch.* With $\partial_1 = 0$ we have $\ker\partial_1 = C_1 =
\mathbb{F}_2^{2g}$, so $\dim Z = 2g$. With $\partial_2 = 0$ we have $B =
\operatorname{im}\partial_2 = 0$, so $\dim B = 0$. Hence $k = 2g - 0 = 2g$.
$\square$

This is the precise statement that "each of the $g$ handles contributes two
logical qubits," matching $\dim H_1 = b_1 = 2g$ for the genus-$g$ surface. The
$g = 1$ case is the ordinary toric code with $k = 2$.

**Theorem 3.3 (Euler characteristic).** With Betti numbers $b_0 = 1$, $b_1 = 2g$,
$b_2 = 1$, the alternating sum is
$$\chi = b_0 - b_1 + b_2 = 1 - 2g + 1 = 2 - 2g,$$
recovering the classical Euler characteristic of the closed orientable genus-$g$
surface.

*Proof sketch.* Immediate from $b_1 = k = 2g$ (Theorem 3.2) and $b_0 = b_2 = 1$
for the minimal complex, by arithmetic. $\square$

The agreement of the code-theoretic count with the classical topological
invariant is a consistency check that the homological dictionary is faithful.

## 4. Code distance as the homological systole

The pair $(n, k)$ measures capacity; the *distance* $d$ measures protection. An
undetectable logical error is a nontrivial homology representative, and its size
is its Hamming weight $|v| = \#\{i : v_i \ne 0\}$.

**Definition 4.1 (systole / code distance).** For a CSS code let the set of
*systole weights* be
$$S := \{\, |v| : v \in Z,\ v \notin B \,\}.$$
The *code distance* is the systole
$$d := \inf S = \min\{\, |v| : v \in \ker\partial_1,\ v \notin
\operatorname{im}\partial_2 \,\},$$
the minimum weight of a $Z$-cycle that is not a $Z$-boundary — equivalently the
length of a shortest loop carrying a nonzero first-homology class.

**Lemma 4.2 (nontriviality implies nonzero).** If $v \notin B$ then $v \ne 0$.

*Proof sketch.* The zero chain is always a boundary ($0 = \partial_2 0 \in B$), so
$v \notin B$ forces $v \ne 0$. $\square$

**Lemma 4.3 (weight positivity).** If $v \notin B$ then $|v| \ge 1$.

*Proof sketch.* By Lemma 4.2, $v \ne 0$, and a nonzero vector has at least one
nonzero coordinate, so $|v| \ge 1$. $\square$

**Proposition 4.4 (shortest-loop upper bound).** If $v \in Z$ and $v \notin B$
then $d \le |v|$.

*Proof sketch.* $|v| \in S$ by definition, and the infimum of a set of natural
numbers is a lower bound for the set, hence $d = \inf S \le |v|$. $\square$

**Proposition 4.5 (distance positivity).** If $k \ge 1$ then $d \ge 1$.

*Proof sketch.* By Theorem 2.5, $k \ge 1$ gives a representative $v \in Z
\setminus B$, so $S$ is nonempty. Every element of $S$ is a weight $|w|$ of some
$w \notin B$, which is $\ge 1$ by Lemma 4.3. Thus $1$ is a lower bound for the
nonempty set $S$ of naturals, so $d = \inf S \ge 1$. $\square$

Together these say: a code that stores information cannot be corrupted by a
weight-zero error, and any explicitly exhibited short logical operator certifies a
ceiling on the distance. The matching *lower* bound $d = \min S$ requires
enumerating representatives and is where the geometry of the specific cellulation
enters.

## 5. A fully explicit code: the triangle $C_3$

To show the framework is non-vacuous — that it genuinely exercises a nonzero
boundary map rather than collapsing to the zero-map surface case — we work out an
explicit example.

**Definition 5.1 (triangle code).** Let $C_3$ be the cycle graph on three
vertices with three edges. Put one qubit on each edge, three vertex checks, and no
faces:
$$n_0 = 3, \quad n_1 = 3, \quad n_2 = 0,$$
with $\partial_2 = 0$ and $\partial_1$ the incidence matrix
$$\partial_1 = \begin{pmatrix} 1 & 0 & 1 \\ 1 & 1 & 0 \\ 0 & 1 & 1
\end{pmatrix} \quad \text{over } \mathbb{F}_2,$$
each column being an edge sent to the sum of its two endpoints. The chain-complex
condition holds because $\partial_2 = 0$.

**Proposition 5.2 (triangle code parameters).** The triangle code is a
$[[3,1,3]]$ code: it has $n = 3$ physical qubits, encodes $k = 1$ logical qubit,
and has distance $d = 3$.

*Proof sketch.* The fundamental loop $v = (1,1,1)$ satisfies $\partial_1 v = 0$
(each vertex meets exactly two edges, and $1 + 1 = 0$), so $v \in Z$. Since
$\partial_2 = 0$ we have $B = 0$, and $v \ne 0$, so $v \notin B$; hence $H_1 \ne
0$ and $k \ge 1$ by Theorem 2.5. The boundary matrix has rank $2$ (its kernel is
one-dimensional, spanned by $v$), so by the Dimension Theorem $k = n -
\operatorname{rank}\partial_1 - \operatorname{rank}\partial_2 = 3 - 2 - 0 = 1$.
For the distance: $d \le |v| = 3$ by Proposition 4.4, and any nonzero cycle must
lie in the one-dimensional kernel spanned by $(1,1,1)$, whose only nonzero element
has weight $3$; combined with $d \ge 1$ (Proposition 4.5) this gives $d = 3$.
$\square$

The rank-two boundary map confirms that the general theorems apply to genuine,
nontrivial linear maps and not merely to the degenerate zero maps of the minimal
surface complex.

## 6. Algorithms

The theory yields directly implementable procedures over $\mathbb{F}_2$; all
linear algebra is Gaussian elimination on binary matrices.

**Algorithm A (code parameters from boundary matrices).** *Input:* binary
matrices $\partial_1 \in \mathbb{F}_2^{n_0 \times n}$ and $\partial_2 \in
\mathbb{F}_2^{n \times n_2}$ with $\partial_1 \partial_2 = 0$. *Output:* $(n, k)$.
Compute $r_1 = \operatorname{rank}_{\mathbb{F}_2}\partial_1$ and $r_2 =
\operatorname{rank}_{\mathbb{F}_2}\partial_2$ by row reduction; return $n$ and
$k = n - r_1 - r_2$ (Theorem 2.4). Complexity $O(n^3)$.

**Algorithm B (homology basis).** Compute a basis of $\ker\partial_1$ and a basis
of $\operatorname{im}\partial_2$ by row reduction, then extend the boundary basis
to a cycle basis; the extra basis vectors represent generators of $H_1$. These are
the logical operators. Complexity $O(n^3)$.

**Algorithm C (distance by exhaustive systole search).** For small codes, enumerate
the $2^{n}$ vectors (or, better, the $2^{k}$ nontrivial cosets via the homology
basis from Algorithm B), test membership in $Z \setminus B$, and return the
minimum Hamming weight (Definition 4.1). Exponential in general — reflecting the
NP-hardness of minimum distance — but exact and useful for verification on small
instances.

## 7. Discussion and applications

The homological dictionary reframes hardware questions as geometric ones. To store
more qubits, add handles (increase genus, hence $H_1$). To resist larger errors,
lengthen the systole. The CSS Dimension Theorem makes the accounting exact, and
the systolic definition of distance makes "code protection" a measurable property
of the mesh.

The framework is agnostic to the particular cellulation: any 2-complex with
$\partial_1 \partial_2 = 0$ is a code, so color codes (on 3-valent, 3-colorable
complexes), hyperbolic surface codes, and higher-dimensional homological codes all
fit the same chain-complex template. The parameters $[[n,k,d]]$ are then read off
as $(\dim C_1, \dim H_1, \text{systole})$.

## 8. Future directions

**Conjecture 1 (homological packing bound).** For every CSS code arising from a
2-complex embeddable in a closed surface, the parameters satisfy $k \cdot d^2 \le
c \cdot n$ for an absolute constant $c$, with equality approached by regular toric
layouts. The intuition: a short nontrivial cycle in one direction forces a short
cut in the dual, so distance and rate trade off quadratically rather than
independently.

**Conjecture 2 (genus is the sole obstruction to rate).** Two closed orientable
surfaces give CSS codes of equal logical dimension if and only if they have equal
genus; no finer cellulation data affects $k$. This is because $k = \dim H_1$ is a
homotopy invariant, depending only on topological type and blind to the
combinatorics of the tessellation, which instead controls $n$ and $d$.

**Conjecture 3 (hyperbolic surfaces beat Euclidean ones).** Codes from negatively
curved (genus $\ge 2$) surface tessellations achieve constant rate $k/n$ bounded
away from zero while retaining distance growing like $\log n$, strictly
outperforming the vanishing rate of flat toric codes. Hyperbolic area grows with
boundary length, so a fixed fraction of cells can be handles: many independent
homology classes coexist without shrinking the systole as fast as in the Euclidean
case.

**Conjecture 4 (color codes as quotient complexes).** Every color code on a
3-valent, 3-colorable 2-complex is equivalent to a surface code on an explicit
branched double cover, with matching distance. The color-code stabilizer structure
is the homology of a complex with extra face-coloring; folding the colors realises
it as an ordinary chain complex whose systole is preserved by the cover.

## 9. Conclusion

We have shown that the three parameters of a CSS quantum code are exactly three
classical invariants of a cellular space: $n$ is the number of $1$-cells, $k =
\dim H_1$ is the first Betti number, and $d$ is the systole. The CSS Dimension
Theorem, the Homological Information Criterion, the Genus Theorem (with its Euler
characteristic corollary), and the systolic theory of distance together give a
self-contained algebraic-topological foundation for topological quantum error
correction, illustrated on the explicit $[[3,1,3]]$ triangle code. The geometry of
holes and loops is, quite literally, the geometry of protected quantum
information.
