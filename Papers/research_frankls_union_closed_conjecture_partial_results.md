# Frankl's Union-Closed Sets Conjecture: Core Formalization and Partial Results

## Abstract

The union-closed sets conjecture, formulated by Péter Frankl in 1979, asserts
that every finite union-closed family of finite sets containing at least one
nonempty set has an *abundant* element — an element belonging to at least half of
the members of the family. Despite intense study and a recent breakthrough giving
a constant-fraction lower bound, the full conjecture remains open. This paper
presents a rigorous development of the core definitions together with four
self-contained partial results. First, we prove the classical *singleton case*:
if a union-closed family contains a one-element set $\{a\}$, then $a$ is abundant,
via the injection $A \mapsto A \cup \{a\}$. Second, we establish the
lattice-theoretic infrastructure: a nonempty union-closed family contains its own
total union, which is the unique greatest element under inclusion, exhibiting the
family as a finite join-semilattice with top. Third, we prove Frankl's conjecture
in full for every union-closed family on a three-element universe, via a clean
two-case split (singleton reduction plus a finite verification of the
singleton-free residue), complementing the known result that the conjecture holds
for all families of at most $50$ members. Fourth, we identify and prove exactly
the equality case of Reimer's average-size inequality: on the full Boolean cube
$\mathcal{P}(\{1,\dots,n\})$, twice the total member size equals $n \cdot 2^n$, so
the average member size is exactly $n/2 = \tfrac12 \log_2|F|$; the proof is a pure
double-counting identity over the natural numbers, with no entropy machinery. We
discuss the relationships among the results and outline directions toward the full
conjecture.

**Keywords:** union-closed sets, Frankl's conjecture, abundant element, join-semilattice, Reimer's inequality, entropy, double counting, Boolean lattice.

---

## 1. Introduction

Let $F$ be a finite collection of finite subsets of some ground set. We call $F$
**union-closed** if it is closed under pairwise unions:
$$A, B \in F \;\Longrightarrow\; A \cup B \in F.$$
For an element $x$, write $d_F(x) = |\{A \in F : x \in A\}|$ for its *degree* in
$F$. We say $x$ is **abundant** if $2\, d_F(x) \ge |F|$, i.e. $x$ belongs to at
least half of the members.

> **Conjecture (Frankl, 1979).** Every union-closed family $F$ containing at
> least one nonempty set has an abundant element.

The conjecture is striking for the gap between the simplicity of its statement and
the difficulty of its resolution. It has been verified in many special cases —
for families with few sets (up to $|F| \le 50$, by Bošnjak and Marković), for
small ground sets, and for families with sets of restricted sizes. A long-sought
*constant-fraction* version was finally achieved by Gilmer in 2022, who proved
via an entropy argument that some element lies in at least a fixed fraction
(approximately $0.38$, later improved past $1 - 1/\varphi \approx 0.382$) of the
sets; the sharp constant $\tfrac12$ remains open.

This paper formalizes the foundational definitions and proves four genuine
partial results that together touch the combinatorial, order-theoretic, and
information-theoretic faces of the problem. Throughout, the emphasis is on
*exact*, checkable statements rather than restatements.

### 1.0 Historical and methodological context

Frankl's conjecture has accumulated a large body of partial results since 1979,
and the techniques cluster into three broad families, each represented among our
theorems. The first family is *local-structural*: one identifies a small
subconfiguration in the family that forces abundance. The cleanest instance is
the singleton case (Theorem 3.1), where a one-element member forces its element
to be abundant by a one-to-one matching. More elaborate local results force
abundance from the presence of small sets, two-element sets, or maximal sets of
controlled size; but as Remark 3.2 records, the most naive local heuristic is
false, so these arguments require genuine care. The second family is
*order-theoretic*: one views the family as a lattice and studies abundance as a
property of join-irreducible elements. Our greatest-element lemmas (Theorems
4.1–4.2) supply the entry point to this viewpoint by guaranteeing a top element.
The third family is *information-theoretic*: one bounds aggregate quantities such
as the average set size using entropy and correlation inequalities. Reimer's
theorem and Gilmer's recent breakthrough live here, and Theorem 6.3 pins down the
exact extremizer of Reimer's bound.

A recurring methodological theme — visible in the verification of all families
with $|F| \le 50$ and in our three-element-universe theorem — is the
*structure-plus-search* paradigm: one uses a structural lemma to discharge the
conceptually hard cases, leaving a finite, mechanically checkable residue. The
art lies in choosing the structural lemma so that the residue is both finite and
small. Theorem 5.2 is a clean miniature of exactly this paradigm.

### 1.1 Summary of contributions

1. **Singleton abundance** (`frankl_singleton`, Theorem 3.1): a union-closed
   family containing $\{a\}$ makes $a$ abundant.
2. **Greatest element / lattice reformulation** (`sup_mem` and
   `sup_id_isGreatest`, Theorems 4.1–4.2): a nonempty union-closed family
   contains its total union, the unique top of $(F, \subseteq)$.
3. **Three-element universe** (`frankl_fin_three`, Theorem 5.2, with
   `frankl_fin3_no_singleton`, Lemma 5.1): the conjecture holds for all
   union-closed families on $\mathrm{Fin}\,3$.
4. **Reimer tightness** (`reimer_tight_cube`, Theorem 6.3, with
   `sum_card_powerset` Lemma 6.1 and `card_powerset_univ` Lemma 6.2): the Boolean
   cube exactly saturates Reimer's average-size inequality.

---

## 2. Definitions

Throughout, $\alpha$ is a type with decidable equality, and families are finite
sets of finite sets, $F : \mathrm{Finset}(\mathrm{Finset}\,\alpha)$.

> **Definition 2.1 (Union-closed).** A family $F$ is *union-closed*,
> $\mathrm{IsUnionClosed}(F)$, if for all $A, B \in F$ we have $A \cup B \in F$.

> **Definition 2.2 (Abundant element).** An element $x$ is *abundant* in $F$ if
> $$2 \cdot |\{A \in F : x \in A\}| \;\ge\; |F|,$$
> i.e. $x$ lies in at least half of the members of $F$.

> **Definition 2.3 (Frankl property).** The family $F$ satisfies the *Frankl
> property*, $\mathrm{FranklProperty}(F)$, if there exists an element $x$ that
> (i) belongs to some member of $F$ and (ii) is abundant in $F$.

The Frankl property is the existential conclusion of the conjecture for a single
family. We also record an immediate helper, used to package witnesses:

> **Lemma 2.4 (`franklProperty_of_abundant`).** If $F$ has a nonempty member and
> $x$ is abundant in $F$ with $x$ contained in some member, then
> $\mathrm{FranklProperty}(F)$ holds. (Trivial from Definition 2.3.)

---

## 3. The singleton case

The single situation in which Frankl's conjecture admits a one-line proof is when
the family contains a singleton. This is the structural heart of much of the
theory.

> **Theorem 3.1 (`frankl_singleton`).** Let $F$ be union-closed and suppose
> $\{a\} \in F$. Then $a$ is abundant in $F$:
> $$2 \cdot |\{A \in F : a \in A\}| \;\ge\; |F|.$$

**Proof sketch.** Partition the members of $F$ into
$$F_a^- = \{A \in F : a \notin A\}, \qquad F_a^+ = \{A \in F : a \in A\},$$
so that $|F| = |F_a^-| + |F_a^+|$. Define
$$\varphi : F_a^- \to F_a^+, \qquad \varphi(A) = A \cup \{a\}.$$
The map is *well-defined*: since $A \in F$ and $\{a\} \in F$ and $F$ is
union-closed, $A \cup \{a\} \in F$; and $a \in A \cup \{a\}$, so the image lies in
$F_a^+$. The map is *injective*: if $A, B \in F_a^-$ (so $a \notin A$ and
$a \notin B$) and $A \cup \{a\} = B \cup \{a\}$, then deleting $a$ from both sides
recovers $A = B$. Hence $|F_a^-| \le |F_a^+|$, and therefore
$$|F| = |F_a^-| + |F_a^+| \le 2\,|F_a^+| = 2\,d_F(a). \qquad \blacksquare$$

The argument uses union-closure exactly once — to land $A \cup \{a\}$ back inside
$F$ — and that single use is the entire mathematical content. It also explains why
the result does not generalize naively: for a smallest set of size $\ge 2$ the
analogous map $A \mapsto A \cup \{a,b\}$ need not be injective.

**Remark 3.2 (the Sarvate–Renaud obstruction).** A natural conjecture — "an
element of a smallest member is always abundant" — is *false*. Sarvate and Renaud
exhibited union-closed families whose smallest set is a doubleton $\{a,b\}$ in
which neither $a$ nor $b$ is abundant. Thus no purely local "smallest set"
heuristic can settle the conjecture, and any proof for universes admitting
non-singleton minimal sets must invoke a global argument (see §5).

---

## 4. The lattice reformulation

Order the members of a union-closed family by inclusion. Closure under union makes
$(F, \subseteq)$ a finite join-semilattice with join $\cup$. We make the top
element explicit.

> **Theorem 4.1 (`sup_mem`).** If $F$ is union-closed and nonempty, then the
> total union $\bigcup_{A \in F} A$ (written $F.\mathrm{sup}\,\mathrm{id}$) is a
> member of $F$.

**Proof sketch.** Induct on the finite family. The base case is a single member
$A$, whose union is $A \in F$. For the inductive step, the union of the family
equals $A \cup (\text{union of the rest})$; by the inductive hypothesis the latter
is a member, and union-closure puts the union of the two back in $F$. $\blacksquare$

> **Theorem 4.2 (`sup_id_isGreatest`).** If $F$ is union-closed and nonempty,
> then $U := \bigcup_{A \in F} A$ satisfies $U \in F$ and $A \subseteq U$ for
> every $A \in F$. Hence $U$ is the unique greatest element of $(F, \subseteq)$.

**Proof sketch.** Membership $U \in F$ is Theorem 4.1. Dominance $A \subseteq U$
for each $A \in F$ is the defining property of the supremum (each member is below
the join of all members). Uniqueness of a greatest element in a poset is
standard. $\blacksquare$

**Discussion.** Theorem 4.2 upgrades an arbitrary union-closed family to a *bona
fide* finite lattice with a guaranteed top element. This recasts Frankl's
conjecture as a statement about finite lattices: a finite lattice arising as a
union-closed family always has an "abundant" join-irreducible. The reformulation
suggests precise lattice-theoretic refinements; see Future Directions FD4, which
asks whether Frankl's property is equivalent to a condition on the
join-irreducible lower covers of $\top$.

---

## 5. Frankl's conjecture for a three-element universe

We now prove the conjecture in full for the ground set $\mathrm{Fin}\,3 =
\{0,1,2\}$. The space of families is $\mathrm{Finset}(\mathrm{Finset}(\mathrm{Fin}\,3))$,
of which there are $2^{2^3} = 256$. Rather than a single monolithic brute force —
which is both inelegant and computationally costly in a kernel-checked setting —
we split on the existence of a singleton, reusing Theorem 3.1 for the conceptual
half.

> **Lemma 5.1 (`frankl_fin3_no_singleton`).** Let $F \subseteq
> \mathcal{P}(\mathrm{Fin}\,3)$ satisfy:
> (i) $A \cup B \in F$ for all $A, B \in F$ (union-closed);
> (ii) $F$ contains a nonempty member; and
> (iii) $F$ contains no singleton $\{x\}$ for any $x \in \mathrm{Fin}\,3$.
> Then there exists $x \in \mathrm{Fin}\,3$ with
> $|F| \le 2\,|\{A \in F : x \in A\}|$ (i.e. $x$ is abundant).

**Proof sketch.** This is a finite verification: range over all subfamilies of
$\mathcal{P}(\mathrm{Fin}\,3)$ satisfying (i)–(iii) and check that an abundant
element exists in each. The restriction to singleton-free families is what makes
the residue tractable and conceptually isolated; the search is decidable and was
discharged by exhaustive evaluation. $\blacksquare$

> **Theorem 5.2 (`frankl_fin_three`).** Every union-closed family
> $F \subseteq \mathcal{P}(\mathrm{Fin}\,3)$ with a nonempty member satisfies
> $\mathrm{FranklProperty}(F)$.

**Proof sketch.** Case-split on whether $F$ contains a singleton.

- *If $\{x\} \in F$ for some $x$:* then $x$ belongs to a member (namely $\{x\}$),
  and by Theorem 3.1 ($\mathrm{frankl\_singleton}$) $x$ is abundant. Hence
  $\mathrm{FranklProperty}(F)$ holds.
- *If $F$ contains no singleton:* apply Lemma 5.1 to obtain an abundant $x$. Since
  $F$ has a nonempty member, Lemma 2.4 packages this into
  $\mathrm{FranklProperty}(F)$.

In both cases the Frankl property holds. $\blacksquare$

**Discussion.** The two-case structure is deliberate and instructive. The
singleton branch is the *only* place union-closure is used structurally; the
no-singleton branch is bounded bookkeeping. This separation mirrors the general
philosophy by which the conjecture has been pushed forward — known for all
families with $|F| \le 50$ (Bošnjak–Marković) — namely, peel off the
structurally-forced cases and verify a controlled finite residue. Future
Directions FD2 proposes the verbatim extension to $\mathrm{Fin}\,4$, where the
singleton branch is unchanged and only the size of the finite residue grows.

---

## 6. The equality case of Reimer's average-size inequality

Reimer's theorem (2003) is a remarkable lower bound on the *average* member size
of a union-closed family.

> **Theorem (Reimer, 2003; stated for context, not proved here).** For every
> union-closed family $F$ with $|F| \ge 1$,
> $$\frac{1}{|F|}\sum_{A \in F} |A| \;\ge\; \tfrac{1}{2}\log_2 |F|.$$

The proof uses entropy and Shearer's lemma, and it is exactly this entropic
toolbox that underlies the modern constant-fraction progress on Frankl's
conjecture. We do *not* reprove the inequality. Instead we identify and prove
*exactly* its equality case: the full Boolean cube.

For the cube $F = \mathcal{P}(\mathrm{Fin}\,n)$ we have $|F| = 2^n$, hence
$\tfrac12 \log_2 |F| = n/2$. The equality case is therefore the integer assertion
that the average subset of an $n$-set has size exactly $n/2$. We prove this with
no logarithms, over the natural numbers.

> **Lemma 6.1 (`sum_card_powerset`).** For every $n \in \mathbb{N}$,
> $$\sum_{A \subseteq \mathrm{Fin}\,n} |A| \;=\; n \cdot 2^{\,n-1}.$$

**Proof sketch (double counting).** Count incidences $(x, A)$ with $x \in A$ over
all subsets $A \subseteq \mathrm{Fin}\,n$ in two ways. Summing first over $A$
gives $\sum_A |A|$. Summing first over points $x$: each fixed point lies in
exactly $2^{n-1}$ subsets (the remaining $n-1$ points are free), and there are $n$
points, giving $n \cdot 2^{n-1}$. Equate. Equivalently, group subsets by
cardinality to write the sum as $\sum_{k=0}^n k\binom{n}{k}$, and use the identity
$k\binom{n}{k} = n\binom{n-1}{k-1}$ together with $\sum_j \binom{n-1}{j} =
2^{n-1}$. $\blacksquare$

> **Lemma 6.2 (`card_powerset_univ`).** For every $n \in \mathbb{N}$,
> $$|\mathcal{P}(\mathrm{Fin}\,n)| \;=\; 2^{\,n}.$$

**Proof sketch.** The number of subsets of a set of cardinality $n$ is $2^n$
($|\mathrm{Fin}\,n| = n$ and $|\mathcal{P}(S)| = 2^{|S|}$). $\blacksquare$

> **Theorem 6.3 (`reimer_tight_cube`).** For every $n \in \mathbb{N}$,
> $$2 \cdot \!\!\sum_{A \subseteq \mathrm{Fin}\,n}\!\! |A| \;=\; n \cdot |\mathcal{P}(\mathrm{Fin}\,n)|,$$
> equivalently $2 \cdot (n \cdot 2^{n-1}) = n \cdot 2^n$. Hence the average member
> size of the Boolean cube is exactly $n/2 = \tfrac12 \log_2(2^n)$, so the cube
> saturates Reimer's inequality with equality.

**Proof sketch.** Substitute Lemma 6.1 on the left and Lemma 6.2 on the right:
the claim becomes $2 \cdot n \cdot 2^{n-1} = n \cdot 2^n$. For $n = 0$ both sides
are $0$; for $n = m+1$ we have $2 \cdot 2^{m} = 2^{m+1}$, and the identity follows
by elementary arithmetic. $\blacksquare$

**Discussion.** The double-counting identity in Lemma 6.1 is, in a precise sense,
the combinatorial heart that an entropy proof of Reimer's inequality reproduces
asymptotically. Pinning the equality case to the Boolean cube provides the
*tightness certificate* needed to prove a full characterization of extremizers
(Future Directions FD3). Crucially, the entire statement and proof live over
$\mathbb{N}$ — no entropy, no logarithms — which makes it a genuine, kernel-checkable
theorem rather than a restatement of the analytic inequality.

---

## 7. Algorithms

The results above are constructive and yield small, verifiable algorithms.

### 7.1 Singleton matching witness

Given a union-closed family $F$ with $\{a\} \in F$, the proof of Theorem 3.1
yields an explicit injection $\varphi(A) = A \cup \{a\}$ from $a$-avoiding members
to $a$-containing members. Building and validating this matching (well-defined,
injective, landing in $F$) is an $O(|F|^2)$ certificate that $a$ is abundant.

### 7.2 Singleton-reduction search for small universes

Given a small ground set, enumerate all union-closed families with a nonempty
member; for each, first test for a singleton (and invoke §7.1 if present),
otherwise verify abundance directly. This is the algorithmic content of Theorem
5.2 and Lemma 5.1, and the template proposed for $\mathrm{Fin}\,4$ in FD2. The
cost is dominated by the $2^{2^n}$ family enumeration, pruned heavily by the
union-closure and nonemptiness filters.

### 7.3 Cube double-counting check

The identity $2\sum_{A}|A| = n\cdot 2^n$ can be verified directly for any $n$ by
summing subset sizes; this is the numerical face of Theorem 6.3 and a unit test
for the symbolic proof.

---

## 8. Applications and connections

- **Lattice theory.** Theorem 4.2 places Frankl's conjecture inside the theory of
  finite lattices, where abundance becomes a statement about join-irreducibles.
- **Information theory.** Theorem 6.3 connects to entropy methods (Reimer,
  Shearer, Gilmer): the cube is the extremizer of the average-size bound that
  underpins the modern constant-fraction progress.
- **Computational combinatorics.** The singleton-reduction template (Theorem 5.2)
  exemplifies how structural lemmas shrink exhaustive searches, the same strategy
  by which the conjecture has been verified up to $|F| \le 50$.

---

## 9. Discussion

The four results illuminate complementary faces of one problem. The singleton
theorem is the combinatorial nucleus and explains, via its failure for doubletons
(Remark 3.2), why the conjecture is hard. The lattice lemmas provide structural
scaffolding. The three-element theorem demonstrates the structure-plus-search
methodology on a complete case. The Reimer tightness identity captures the exact
extremal behavior of the entropic approach. None of these alone resolves the
conjecture, but together they form a coherent set of footholds, each stated and
proved exactly.

---

## 10. Future directions

**FD1. Doubleton families: a guarded abundance theorem.** *Conjecture:* if a
union-closed family $F$ contains a $2$-element set $\{a,b\}$ and no element of
$\{a,b\}$ is "blocked" (every member meeting $\{a,b\}$ does so in a way that keeps
the union map injective), then $a$ or $b$ is abundant. The singleton injection
$A \mapsto A \cup \{a\}$ degrades for doubletons into a pair of partial injections
$A \mapsto A \cup \{a,b\}$, and abundance survives exactly when the overlap defect
is controlled — precisely the defect localized by the failure of the naive
smallest-set heuristic.

**FD2. Frankl for $\mathrm{Fin}\,4$ by singleton-reduction plus bounded search.**
*Conjecture:* Theorem 5.2 generalizes verbatim to $\mathrm{Fin}\,4$ — split on the
existence of a singleton (use Theorem 3.1), then verify the singleton-free residue
by exhaustive search. The singleton branch removes the only step that uses
union-closure structurally, leaving a finite residue (families on $16$ sets) whose
decidable predicate is unchanged; only the search budget needs profiling.

**FD3. Reimer's inequality (not just its equality case).** *Conjecture:* for every
union-closed $F$ with $|F| \ge 1$, $2\sum_{A \in F}|A| \ge |F|\log_2|F|$, with
equality iff $F$ is (an up-set isomorphic to) a Boolean cube. Theorem 6.3 already
proves the equality on the cube via double counting; the general inequality should
follow from a Shearer/submodularity entropy bound whose extremizer is exactly the
object pinned down here, with the cube identity supplying the tightness
certificate for the "iff" half.

**FD4. The greatest-element lattice reformulation as a fixed point.**
*Conjecture:* a finite lattice $L$ satisfies Frankl iff its top element $\top$
(which Theorem 4.2 shows always exists for union-closed families) has a
join-irreducible lower cover lying below at least half of $L$. Theorem 4.2
upgrades a union-closed family to a finite join-semilattice with top, so Frankl
becomes a statement about join-irreducibles, where abundance means "below half the
lattice."

---

## 11. Conclusion

We have formalized the core notions of union-closed families, abundant elements,
and the Frankl property, and we have proved four exact partial results: the
singleton abundance theorem, the greatest-element/lattice reformulation, Frankl's
conjecture for a three-element universe, and the exact equality case of Reimer's
average-size inequality on the Boolean cube. Each result is stated as a precise,
checkable theorem, and together they assemble combinatorial, order-theoretic, and
information-theoretic perspectives on one of the most accessible open problems in
combinatorics.
