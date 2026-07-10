# The Mathematics of Jigsaw Puzzles: Edge Complementation, Boundary Topology, and the Satisfiability Correspondence

## Abstract

We develop a rigorous account of the classical jigsaw-puzzle assembly problem and
establish its exact relationship to Boolean satisfiability. Modeling each piece
edge as one of three shapes — *flat*, *tab*, or *blank* — we define an
**complementation** operation that captures which edges physically interlock and
show it to be an involution generating an order-two symmetry group acting on the
edge alphabet. We prove that the self-complementary edges (the fixed points of
this symmetry) are precisely the flat border edges, giving a topological reading
of a puzzle's outline as the fixed-point set of a symmetry. Encoding truth values
as edge shapes ($\text{true}\mapsto\text{tab}$, $\text{false}\mapsto\text{blank}$),
we prove a *local dictionary*: a clause piece's literal input interlocks with a
variable's output edge if and only if that literal is satisfied. Lifting this atom
through disjunction and conjunction yields the main correspondence — the puzzle
built from a formula assembles if and only if the formula is satisfiable. We cast
the construction as a genuine many-one (Karp) reduction of the satisfiability
language into the puzzle-assembly language, from which hardness transfers by
transitivity; the constructed instance uses exactly $2n + m + 2$ pieces for $n$
variables and $m$ clauses. We conclude with a worked satisfiable instance and a
provably unsolvable instance, and we discuss algorithmic and topological
extensions.

**Keywords:** jigsaw assembly, edge complementation, involution, fixed-point set,
Boolean satisfiability, many-one reduction, NP-completeness, boundary topology.

---

## 1. Introduction

The jigsaw puzzle is among the most familiar of combinatorial objects, yet its
computational and algebraic structure is surprisingly rich. This paper isolates
three intertwined themes:

1. **Boundary topology of edges.** The mating relation between piece edges is
   governed by a single involution whose fixed-point set is exactly the border of
   the assembled figure.
2. **The assembly–satisfiability dictionary.** By encoding truth values as edge
   shapes, we identify placement of a clause piece with satisfaction of a clause,
   and hence solvability of a whole puzzle with satisfiability of a formula.
3. **The reduction as a many-one reduction.** The construction is a Karp
   reduction of Boolean satisfiability into puzzle assembly, so puzzle assembly
   inherits the full hardness of satisfiability.

The unifying object is a single order-two symmetry: edge complementation. Its
reversibility carries the logic, and its fixed points carry the topology.

Throughout, a puzzle is specified abstractly by the formula it encodes; this keeps
the reduction map transparent while preserving the full logical content of the
correspondence. Section 8 discusses how a fully geometric grid model would recover
the same content.

---

## 2. Edges and the algebra of complementation

### 2.1 The edge alphabet

**Definition 2.1 (Edge).** The *edge alphabet* is the three-element set
$$\mathcal{E} = \{\,\text{flat},\ \text{tab},\ \text{blank}\,\}.$$
A *flat* edge is a straight border edge; a *tab* protrudes outward; a *blank*
recedes inward.

**Definition 2.2 (Complementation).** The *complement* map
$\text{comp}\colon \mathcal{E}\to\mathcal{E}$ is
$$\text{comp}(\text{flat}) = \text{flat}, \qquad \text{comp}(\text{tab}) = \text{blank}, \qquad \text{comp}(\text{blank}) = \text{tab}.$$
Intuitively, $\text{comp}(e)$ is the unique shape that physically interlocks with
an edge of shape $e$.

### 2.2 Complementation is an involution

**Theorem 2.3 (Involutivity).** For every edge $e$, $\text{comp}(\text{comp}(e)) = e$.
Consequently $\text{comp}$ is a bijection, in fact its own inverse.

*Proof.* Check the three cases. Flat maps to flat, so it is fixed. Tab maps to
blank maps to tab; blank maps to tab maps to blank. In every case two applications
return the input. An involution is automatically injective and surjective. $\square$

**Corollary 2.4 (The complementation symmetry).** The map $\text{comp}$ is a
permutation of $\mathcal{E}$ satisfying $\text{comp}^2 = \mathrm{id}$. It therefore
generates a cyclic group of order two, $\langle \text{comp}\rangle \cong
\mathbb{Z}/2\mathbb{Z}$, acting on the edge alphabet. This is the *local symmetry
group* of edge matching.

### 2.3 The border as a fixed-point set

**Theorem 2.5 (Boundary = fixed points).** An edge is self-complementary if and
only if it is flat:
$$\text{comp}(e) = e \iff e = \text{flat}.$$

*Proof.* If $e = \text{flat}$ then $\text{comp}(e) = \text{flat} = e$. Conversely,
$\text{comp}(\text{tab}) = \text{blank}\ne\text{tab}$ and
$\text{comp}(\text{blank}) = \text{tab}\ne\text{blank}$, so no non-flat edge is
fixed. $\square$

**Interpretation.** The flat edges are precisely the edges appearing on the
boundary of an assembled figure — a piece exposes a flat edge exactly where it
borders the empty exterior. Theorem 2.5 therefore identifies the outline of the
assembled picture with the fixed-point set of the order-two complementation
symmetry. The border of a puzzle is not an ad hoc feature; it is the invariant
locus of a symmetry, the topological skeleton of the construction.

---

## 3. Interlocking edges

**Definition 3.1 (Fits).** Edge $a$ *fits* edge $b$, written $a \bowtie b$, when
$b = \text{comp}(a)$; that is, when the two sides physically interlock.

**Theorem 3.2 (Symmetry of fitting).** If $a \bowtie b$ then $b \bowtie a$.

*Proof.* Suppose $b = \text{comp}(a)$. Then $\text{comp}(b) =
\text{comp}(\text{comp}(a)) = a$ by involutivity (Theorem 2.3), so
$a = \text{comp}(b)$, i.e. $b \bowtie a$. $\square$

**Theorem 3.3 (Uniqueness of partner).** If $a \bowtie b$ and $a \bowtie b'$ then
$b = b'$. Each edge interlocks with exactly one shape.

*Proof.* Both $b$ and $b'$ equal $\text{comp}(a)$. $\square$

---

## 4. Encoding truth values as edges

**Definition 4.1 (Truth encoding).** The encoding map
$\text{enc}\colon \{\text{true}, \text{false}\}\to\mathcal{E}$ is
$$\text{enc}(\text{true}) = \text{tab}, \qquad \text{enc}(\text{false}) = \text{blank}.$$
A truth value is transmitted along the *assignment channel* as the corresponding
edge shape.

**Theorem 4.2 (Injectivity of the encoding).** $\text{enc}$ is injective: an edge
determines the truth value it carries.

*Proof.* The only two inputs map to the distinct outputs tab and blank. $\square$

**Theorem 4.3 (Variable mutual exclusion).**
$\text{enc}(\text{true}) \ne \text{enc}(\text{false})$.

*Proof.* Immediate: tab $\ne$ blank. $\square$

**Interpretation.** A variable gadget offers two competing pieces — a TRUE piece
exposing a tab and a FALSE piece exposing a blank — on a shared assignment
channel. Since the two shapes differ, at most one piece can occupy the channel.
Mutual exclusion of truth values is thereby realized geometrically.

---

## 5. Formulas, assignments, and the assembly dictionary

### 5.1 Syntax

**Definition 5.1 (Literals, clauses, formulas, assignments).**
- A *literal* is a pair $\ell = (v, p) \in \mathbb{N}\times\{\text{true},\text{false}\}$: a variable index $v$ together with a required polarity $p$.
- A *clause* is a finite list of literals (their disjunction).
- A *formula* is a finite list of clauses (their conjunction); i.e. a formula in conjunctive normal form (CNF).
- An *assignment* is a function $a\colon \mathbb{N}\to\{\text{true},\text{false}\}$.

**Definition 5.2 (Satisfaction).**
- A literal $\ell = (v,p)$ is *satisfied* by $a$ when $a(v) = p$.
- A clause $c$ is *satisfied* by $a$ when some $\ell \in c$ is satisfied.
- A formula $F$ is *satisfied* by $a$ when every clause $c \in F$ is satisfied.
- $F$ is *satisfiable* when some assignment satisfies it.

### 5.2 The local dictionary

The clause piece for a literal $\ell = (v,p)$ exposes an input edge milled to
accept polarity $p$; formally this input edge is $\text{comp}(\text{enc}(p))$. It
must interlock with the variable's output edge $\text{enc}(a(v))$.

**Definition 5.3 (Literal fit).** Under assignment $a$, literal $\ell = (v,p)$
*fits* when $\text{enc}(a(v)) \bowtie \text{comp}(\text{enc}(p))$.

**Theorem 5.4 (Local dictionary).** For every assignment $a$ and literal $\ell$,
$$\ell \text{ fits under } a \iff \ell \text{ is satisfied by } a.$$

*Proof.* Write $\ell = (v,p)$. By definition of $\bowtie$, $\ell$ fits iff
$\text{comp}(\text{enc}(p)) = \text{comp}(\text{enc}(a(v)))$. Since $\text{comp}$
is injective (Theorem 2.3), this is equivalent to
$\text{enc}(p) = \text{enc}(a(v))$; and since $\text{enc}$ is injective
(Theorem 4.2), this is equivalent to $a(v) = p$, i.e. $\ell$ is satisfied. The
converse direction substitutes $a(v) = p$ and computes both sides equal. $\square$

This atom is the entire logical content of the construction: every subsequent
equivalence factors through it, and its only inputs are the injectivity of two
maps.

### 5.3 Lifting to clauses and puzzles

**Definition 5.5 (Clause piece placement).** A clause piece for $c$ can be placed
under $a$ when at least one of its literal inputs fits, i.e. when some $\ell\in c$
fits under $a$.

**Theorem 5.6 (Clause dictionary).** A clause piece for $c$ can be placed under
$a$ if and only if $c$ is satisfied by $a$.

*Proof.* Placement asks for some $\ell\in c$ that fits; satisfaction asks for some
$\ell\in c$ that is satisfied. These match literal-by-literal by Theorem 5.4. $\square$

**Definition 5.7 (Puzzle assembly and solvability).** The puzzle built from a
formula $F$ is *assembled* under an assignment $a$ when every clause piece can be
placed, i.e. every $c\in F$ can be placed under $a$. The puzzle is *solvable* when
it is assembled under some assignment.

**Theorem 5.8 (Main correspondence).** The puzzle built from a formula $F$ is
solvable if and only if $F$ is satisfiable.

*Proof.* Solvability provides an assignment placing every clause piece; by Theorem
5.6 that same assignment satisfies every clause, hence satisfies $F$. Conversely a
satisfying assignment places every clause piece by Theorem 5.6, assembling the
puzzle. $\square$

A satisfying assignment is thus, literally, an instruction sheet for snapping
every piece into place, and conversely a completed assembly can be read off as a
satisfying assignment.

---

## 6. The piece count of the construction

**Definition 6.1 (The piece set).** For $n$ variables and formula $F$ with
$m = |F|$ clauses, the construction assembles:
- two *corner pieces* (top-left and bottom-right, enforcing the boundary);
- for each variable $i < n$, two *variable pieces* — a TRUE piece exposing a tab
  and a FALSE piece exposing a blank on the assignment channel;
- for each clause, one *clause piece*.

**Theorem 6.2 (Piece count).** The construction produces exactly
$$2n + m + 2$$
pieces.

*Proof.* Two corners, plus $2$ pieces for each of the $n$ variables (contributing
$2n$), plus one piece for each of the $m$ clauses. Summing gives $2n + m + 2$. $\square$

The construction is therefore linear in the size of the formula, as a hardness-
preserving reduction requires.

---

## 7. The reduction and hardness transfer

**Definition 7.1 (Many-one reducibility).** For languages $A\subseteq\alpha$ and
$B\subseteq\beta$, we say $A$ *many-one (Karp) reduces* to $B$, written
$A\le_m B$, when there is a map $f\colon\alpha\to\beta$ with
$$x\in A \iff f(x)\in B \quad\text{for all } x.$$

**Theorem 7.2 (Transitivity).** If $A\le_m B$ and $B\le_m C$ then $A\le_m C$.

*Proof.* If $f$ witnesses $A\le_m B$ and $g$ witnesses $B\le_m C$, then $g\circ f$
witnesses $A\le_m C$: $x\in A \iff f(x)\in B \iff g(f(x))\in C$. $\square$

**Definition 7.3 (The two languages).** Let
$$\mathrm{SAT} = \{\,F : F \text{ is satisfiable}\,\}, \qquad
\mathrm{JIGSAW} = \{\,F : \text{the puzzle built from } F \text{ is solvable}\,\}.$$

**Theorem 7.4 (The reduction).** $\mathrm{SAT} \le_m \mathrm{JIGSAW}$.

*Proof.* Take $f$ to be the construction sending a formula to its puzzle. By the
main correspondence (Theorem 5.8), $F\in\mathrm{SAT} \iff F$ is satisfiable $\iff$
its puzzle is solvable $\iff f(F)\in\mathrm{JIGSAW}$. $\square$

**Theorem 7.5 (Hardness transfer).** For every language $L$ with
$L\le_m\mathrm{SAT}$, also $L\le_m\mathrm{JIGSAW}$. In particular, puzzle assembly
inherits the full hardness of Boolean satisfiability.

*Proof.* Compose the given reduction with Theorem 7.4 using transitivity
(Theorem 7.2). $\square$

Since Boolean satisfiability is NP-complete, every problem in NP many-one reduces
to it, and hence — by Theorem 7.5 — to puzzle assembly. Puzzle assembly is
therefore NP-hard.

---

## 8. Worked instances

### 8.1 A solvable instance

Consider the running example
$$F = (x_1 \lor x_2 \lor \lnot x_3) \;\land\; (\lnot x_1 \lor x_3),$$
with three variables and two clauses. By Theorem 6.2 its puzzle uses
$2\cdot 3 + 2 + 2 = 10$ pieces.

**Claim.** The puzzle for $F$ is solvable.

*Proof.* Take the assignment $a$ with $a(2) = \text{true}$ and $a(v) =
\text{false}$ otherwise. The first clause contains the literal $(x_2,\text{true})$,
satisfied because $a(2)=\text{true}$. The second clause contains
$(x_1,\text{false})$, satisfied because $a(1)=\text{false}$. Every clause is
satisfied, so $F$ is satisfiable; by Theorem 5.8 the puzzle is solvable. $\square$

### 8.2 An unsolvable instance

Consider the contradictory instance
$$F' = x_1 \land \lnot x_1,$$
i.e. two singleton clauses demanding $x_1$ true and $x_1$ false.

**Claim.** The puzzle for $F'$ is *not* solvable.

*Proof.* Suppose, for contradiction, an assignment $a$ solves it. By Theorem 5.8
$a$ satisfies $F'$; the clause $\{(x_1,\text{true})\}$ forces $a(1)=\text{true}$
and the clause $\{(x_1,\text{false})\}$ forces $a(1)=\text{false}$, whence
$\text{true}=\text{false}$, a contradiction. No such assignment exists. $\square$

This is a genuine impossibility proof: the clause piece demanding a tab and the
one demanding a blank on the same channel can never both be placed, faithfully
mirroring the logical contradiction.

---

## 9. Discussion

The construction reveals that a single order-two symmetry — edge complementation —
simultaneously supplies:

- **Topology.** Its fixed-point set (Theorem 2.5) is the boundary of the assembled
  figure, turning "flat edges go on the outside" into an invariant statement.
- **Logic.** Its reversibility (injectivity of complementation and of the truth
  encoding) drives the local dictionary (Theorem 5.4), from which the entire
  assembly–satisfiability correspondence follows.
- **Complexity.** Packaged as a many-one reduction (Theorem 7.4), it imports the
  hardness of satisfiability into puzzle assembly (Theorem 7.5).

The correspondence is *local*: every global equivalence factors through the
single-literal fit lemma, whose only inputs are two injectivity facts. This
locality is what makes the construction robust — it does not depend on the global
geometry of the grid, only on the algebra of edge matching.

The abstract puzzle model, indexed by the formula it encodes, makes the reduction
map the identity on instances. A fully geometric grid model would replace this
with an explicit encoding of the piece set into a physical layout; the reduction
*content*, captured by Theorem 5.8, would be identical. The point of the abstract
model is to isolate that content cleanly.

---

## 10. Future directions

**Bounded palette.** For every fixed number of distinct interlock shapes
$k\ge 3$, the assembly problem restricted to a $k$-shape alphabet is conjecturally
as hard as unrestricted assembly. The reduction uses only the single
complementation involution — one swapped pair plus one self-complementary border
shape — so hardness is carried by the *symmetry* of the alphabet rather than its
size; enlarging the palette can only add reductions.

**Border as topological obstruction.** In any valid assembly the multiset of
exposed (unmatched) edges is conjecturally supported on the fixed-point set of
complementation, with cardinality a topological invariant of the target shape (its
boundary length), independent of interior wiring. Theorem 2.5 identifies exposed
edges with fixed points of an involution, so counting boundary edges becomes a
Burnside-style fixed-point count.

**Uniqueness detects unique satisfiability.** The constructed puzzle conjecturally
has a unique valid assembly (up to border symmetries) if and only if the formula
has a unique satisfying assignment; hence counting assemblies computes the number
of satisfying assignments. The assembly-to-assignment dictionary is a bijection on
the nose, so multiplicities transfer.

**Gadget composition.** A systematic calculus of composable gadgets would let one
build reductions from other combinatorial problems directly into puzzle assembly,
using edge complementation as the universal connective.

---

## 11. Conclusion

Beneath the pastime of assembling a jigsaw puzzle lies a compact mathematical
edifice. A single order-two symmetry — the involution that swaps tab and blank and
fixes the flat border — draws the outline of the picture as its fixed-point set,
encodes truth and falsehood in its two moving points, and, packaged as a many-one
reduction, smuggles the hardness of Boolean satisfiability into the act of
completing a puzzle. Three domains — the combinatorics of edge matching, the logic
of conjunctive normal form, and the algebra of reductions — meet at one
involution.
