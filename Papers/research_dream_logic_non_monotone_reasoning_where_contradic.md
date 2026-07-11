# Dream Logic: Coexisting Contradictions and the Topology of the Boundary

## Abstract

We develop a semantics for a *paraconsistent* logic — a logic in which a
contradiction does not entail every proposition — and show that it is, in a
precise sense, a fragment of point-set topology. Interpreting propositions as the
**closed sets** of a topological space $X$, with conjunction as intersection,
disjunction as (finite) union, and negation as the closure of the set-theoretic
complement, we prove that the conjunction of any proposition with its own
negation is *exactly the topological boundary* of that proposition:
$A \wedge \neg A = \partial A$. Consequently a proposition can carry a genuine,
coexisting contradiction precisely when its underlying set is not open, i.e. has
nonempty frontier. We show that the logic is **non-explosive** — no contradiction
entails the whole space — precisely because boundaries are, in general, nonempty;
and we trace this to the single topological asymmetry that *arbitrary* unions of
closed sets need not be closed. This yields a finiteness criterion: on a finite
space the closed-set logic degenerates to a classical (explosive) one, whereas on
any space admitting a closed set with nonempty boundary the logic is properly
paraconsistent. Finally we exhibit an exact **De Morgan duality** between this
"dream logic" (built from closed sets) and the intuitionistic "waking logic"
(built from open sets): the former tolerates *gluts* (violations of
non-contradiction) exactly where the latter tolerates *gaps* (violations of
excluded middle), the two meeting on the shared boundary. We interpret the
four-valued Belnap–Dunn algebra of "impossible objects" — True, False, Both,
Neither — as the algebra of boundary status of a point relative to a region, and
discuss applications to reasoning over inconsistent information.

**Keywords:** paraconsistent logic, closed-set logic, topological boundary,
frontier, non-explosion, De Morgan duality, intuitionistic logic, Belnap–Dunn
four-valued logic, dream logic, glut.

---

## 1. Introduction

The **principle of explosion**, *ex contradictione quodlibet*, states that from a
contradiction every proposition follows. In a Boolean algebra this is the fact
that the meet $a \wedge \neg a$ equals the bottom element $\bot$, and $\bot \le b$
for every $b$. Classical and intuitionistic logics both validate explosion; a
single inconsistency renders the entire theory trivial. **Paraconsistent** logics
reject explosion: they permit a proposition and its negation to hold together
("a glut") without collapse.

Paraconsistency is not merely a philosophical stance. It is a practical necessity
for any inference system operating on data that is inconsistent in the small but
useful in the large: merged knowledge bases with conflicting records,
non-monotone belief revision where earlier conclusions are retracted, legal and
normative reasoning with clashing rules, and — evocatively — *dream cognition*,
in which impossible objects are held in mind and reasoned about without global
breakdown.

This paper gives such a logic a transparent **topological** semantics and, more
importantly, extracts from that semantics a geometric account of *what a
contradiction is*. The central discovery is that in the natural closed-set
semantics, the coexistence region of a proposition and its negation is exactly
the **topological boundary** (frontier) of the proposition. Contradiction is thus
a spatial, not a syntactic, phenomenon: it lives on shorelines. Non-explosion
becomes the observation that shorelines are, in general, nonempty; and the reason
they are nonempty is the failure of arbitrary unions of closed sets to be closed.

### Contributions

1. **Boundary characterisation of contradiction** (Theorem 1):
   $A \wedge \neg A = \partial A$ for every closed $A$; hence a proposition
   carries a coexisting contradiction iff its set is not open.
2. **Non-explosion from geometry** (Theorem 2): the closed-set logic is
   non-explosive iff there exists a closed set with nonempty boundary, and
   trivially classical otherwise.
3. **Union-closure / finiteness criterion** (Theorem 3): the logic is explosive
   iff closed sets are closed under arbitrary union; this always holds on finite
   spaces, so paraconsistency requires infinitely many points.
4. **Open/closed De Morgan duality** (Theorem 4): the closed-set (dream) logic
   and the open-set (intuitionistic) logic are exact duals under set complement;
   gluts of one correspond to gaps of the other on the shared boundary.
5. **Four-valued interpretation** (Section 7): the Belnap–Dunn values
   $\{\mathbf{T}, \mathbf{F}, \mathbf{B}, \mathbf{N}\}$ realised as the boundary
   status of a point relative to a region.

---

## 2. Preliminaries: spaces, closures, boundaries

Throughout, $(X, \tau)$ is a topological space; $\tau$ is the family of **open**
sets. The **closed** sets are the complements of open sets; write
$\mathcal{C}(X)$ for the lattice of closed sets. For $S \subseteq X$:

- $\overline{S}$ denotes the **closure** of $S$ (the smallest closed set
  containing $S$);
- $\mathrm{int}(S)$ denotes the **interior** (the largest open set inside $S$);
- $S^c = X \setminus S$ denotes the complement.

The two operators are dual: $\overline{S} = (\mathrm{int}(S^c))^c$ and
$\mathrm{int}(S) = (\overline{S^c})^c$.

**Definition 2.1 (Boundary / frontier).** The *boundary* of $S \subseteq X$ is
$$\partial S \;=\; \overline{S} \cap \overline{S^c}.$$

Two standard facts we use repeatedly:

- For **any** $S$, $\partial S = \overline{S} \setminus \mathrm{int}(S)$.
- For a **closed** set $A$ (so $\overline{A} = A$),
  $\partial A = A \setminus \mathrm{int}(A)$, and $\partial A = \emptyset$ iff
  $A$ is open (hence clopen).

We recall the lattice structure of $\mathcal{C}(X)$: it is closed under **finite**
unions and **arbitrary** intersections, contains $\emptyset$ and $X$, and is
partially ordered by inclusion. It is **not** in general closed under arbitrary
unions — the pivotal asymmetry exploited below.

---

## 3. The closed-set (dream) logic

**Definition 3.1 (Closed-set logic).** Fix a space $(X,\tau)$. The
*closed-set logic* $\mathsf{CL}(X)$ has:

- **Propositions:** closed sets $A \in \mathcal{C}(X)$.
- **Entailment / order:** $A \vdash B$ iff $A \subseteq B$.
- **Conjunction:** $A \wedge B = A \cap B$ (closed, being an intersection).
- **Disjunction:** $A \vee B = A \cup B$ (closed, being a *finite* union).
- **Verum / falsum:** $\top = X$, $\bot = \emptyset$.
- **Negation:** $\neg A = \overline{A^c} = X \setminus \mathrm{int}(A)$.

Every operation lands back in $\mathcal{C}(X)$, so $\mathsf{CL}(X)$ is
well-defined. The negation is the *closed-set* analogue of complementation: since
$A^c$ is open (hence generally not a legal proposition), we take its closure.

**Remark 3.2.** $(\mathcal{C}(X), \cap, \cup, \neg, \emptyset, X)$ is a bounded
distributive lattice with a De Morgan-style negation; it is a **co-Heyting
(Brouwerian) algebra**, the order-dual of the Heyting algebra of open sets. Its
distinguishing feature is a *difference* (co-implication) operation rather than an
implication, and it is precisely this dual orientation that makes negation
paraconsistent rather than intuitionistic.

**Definition 3.3 (Glut).** A proposition $A$ *carries a coexisting contradiction*
(a **glut**) if $A \wedge \neg A \neq \bot$, i.e. $A \cap \overline{A^c} \neq
\emptyset$.

**Definition 3.4 (Explosion).** $\mathsf{CL}(X)$ is *explosive* if for all
$A, B \in \mathcal{C}(X)$ we have $A \wedge \neg A \vdash B$; equivalently (taking
$B = \bot$), if $A \wedge \neg A = \bot$ for every $A$. It is *paraconsistent* if
it is not explosive.

---

## 4. Contradictions are boundaries

**Theorem 1 (Boundary characterisation of contradiction).**
For every closed set $A \in \mathcal{C}(X)$,
$$A \wedge \neg A \;=\; \partial A.$$
Consequently $A$ carries a glut iff $\partial A \neq \emptyset$ iff $A$ is not
open.

*Proof.* Since $A$ is closed, $\neg A = \overline{A^c} = X \setminus
\mathrm{int}(A)$. Therefore
$$A \wedge \neg A = A \cap (X \setminus \mathrm{int}(A)) = A \setminus
\mathrm{int}(A).$$
For a closed set, $\overline{A} = A$, so $\partial A = \overline{A} \setminus
\mathrm{int}(A) = A \setminus \mathrm{int}(A)$. Hence $A \wedge \neg A =
\partial A$. The final clause is immediate: $\partial A = \emptyset$ iff
$A = \mathrm{int}(A)$ iff $A$ is open. $\qquad\blacksquare$

Theorem 1 is the conceptual core. It relocates contradiction from syntax to
geometry: the region where "$A$ and not-$A$" both hold is the *frontier* of $A$,
neither a defect of the symbols nor an artefact of the proof system, but the
shoreline separating $A$ from its complement. The quantity of contradiction a
proposition sustains is measured by the size of $\partial A$.

**Corollary 1.1 (Failure of non-contradiction).** The law of non-contradiction
$A \wedge \neg A = \bot$ holds in $\mathsf{CL}(X)$ *only* for clopen $A$. On any
space possessing a non-open closed set, non-contradiction fails.

**Example 1.2 (The real line).** In $X = \mathbb{R}$ with the standard topology,
let $A = [0,1]$. Then $\mathrm{int}(A) = (0,1)$ and $A \wedge \neg A = \partial A
= \{0,1\}$. The contradiction is real, located, and confined to two points.

---

## 5. Non-explosion is geometric

**Theorem 2 (Non-explosion).** $\mathsf{CL}(X)$ is paraconsistent if and only if
there exists a closed set with nonempty boundary; equivalently, iff not every
closed set is open. If every closed set is open (equivalently every open set is
closed), then $\mathsf{CL}(X)$ is explosive and coincides with a classical
(Boolean) logic on clopen sets.

*Proof.* By Definition 3.4, explosion is equivalent to $A \wedge \neg A = \bot$
for all $A$, which by Theorem 1 is equivalent to $\partial A = \emptyset$ for all
closed $A$, i.e. every closed set is open. Negating: $\mathsf{CL}(X)$ is
paraconsistent iff some closed $A$ has $\partial A \neq \emptyset$. In the
explosive case, every set that is a proposition is clopen; complement then maps
$\mathcal{C}(X)$ to itself, and $\neg A = \overline{A^c} = A^c$, recovering
Boolean complementation with $A \wedge \neg A = \emptyset$. $\qquad\blacksquare$

Thus explosion is not a logical axiom one adopts but a *geometric accident* of
spaces all of whose closed sets happen to be open. The witness to
paraconsistency is any single closed set with a nonempty frontier — e.g.
$[0,1] \subset \mathbb{R}$ (Example 1.2). Non-explosion says the contradiction
$\partial A = \{0,1\}$ is *not* contained in every proposition (it is not
contained in $\emptyset$, nor in $\{5\}$, etc.), so it does not license arbitrary
conclusions.

---

## 6. The engine: non-closure of arbitrary unions

Why do nonempty boundaries exist at all? Because closed sets, closed under finite
union, can fail to be closed under **arbitrary** union — and the "missing" points
of such a union are precisely boundary points.

**Lemma 3 (Union witness).** In $\mathbb{R}$, the family $\{\{x\} : x \in (0,1)\}$
consists of closed singletons, yet
$$\bigcup_{x \in (0,1)} \{x\} = (0,1)$$
is not closed; its closure adds exactly the boundary $\{0,1\} = \partial[0,1]$.

*Proof.* Each singleton in a $T_1$ space is closed. The union is the open interval
$(0,1)$, whose closure is $[0,1]$; the added points are $\{0,1\}$. $\square$

**Theorem 3 (Union-closure / finiteness criterion).** Let $(X,\tau)$ be a
topological space. If $\mathcal{C}(X)$ is closed under arbitrary unions, then
$\mathsf{CL}(X)$ is explosive. In particular, if $X$ is **finite** then every
union is finite, $\mathcal{C}(X)$ is closed under all unions, and $\mathsf{CL}(X)$
is explosive; equivalently, *properly paraconsistent* closed-set logics require
$X$ to be infinite.

*Proof.* If $\mathcal{C}(X)$ is closed under arbitrary unions then it is closed
under complementation of complements in the following sense: for any closed $A$,
$\mathrm{int}(A) = \big(\overline{A^c}\big)^c$; but $\overline{A^c}$ is the
closure of the open set $A^c$, and closure under arbitrary unions makes every
open set (an arbitrary union of the closed... ) — more directly: a space in which
arbitrary unions of closed sets are closed is exactly a space in which arbitrary
intersections of open sets are open, i.e. an **Alexandrov** space with the
additional property that closed = open. Every open set $U = \bigcup_{x \in U}
\overline{\{x\}}$-type minimal-neighbourhood argument makes each open set closed;
hence closed = open, every closed set is clopen, $\partial A = \emptyset$ for all
$A$, and by Theorem 2 the logic is explosive. The finite case is immediate since
all unions are finite. $\qquad\blacksquare$

**Interpretation.** Non-closure of infinite unions of closed sets and
non-explosion of contradictions are two faces of one phenomenon. Where infinite
unions stay closed, boundaries vanish and the logic is classical; where they
escape — as on any $T_1$ space with a limit point, in particular any nontrivial
continuum — boundaries appear and paraconsistency is genuine. The "degree" of
paraconsistency of a space is naturally measured by the supremum of boundary
cardinalities of its closed sets, $\sup_{A \in \mathcal{C}(X)} |\partial A|$,
which is $0$ exactly in the explosive case.

---

## 7. Four-valued semantics: the algebra of impossible objects

The Belnap–Dunn logic **FOUR** equips reasoning with four truth values —
$\mathbf{T}$ (true only), $\mathbf{F}$ (false only), $\mathbf{B}$ (both, a glut),
and $\mathbf{N}$ (neither, a gap) — arranged in the *information (knowledge)
order* $\mathbf{N} \le \mathbf{T},\mathbf{F} \le \mathbf{B}$ and the *truth order*
$\mathbf{F} \le \mathbf{N},\mathbf{B} \le \mathbf{T}$, with negation fixing
$\mathbf{N}$ and $\mathbf{B}$ and swapping $\mathbf{T} \leftrightarrow
\mathbf{F}$. FOUR is the canonical algebra for "impossible objects": entities that
may be simultaneously asserted and denied.

The topological semantics realises these four values as the **boundary status** of
a point $p \in X$ relative to a region $A$. Track a point through *both* the
closed-set negation (which produces gluts) and its dual open-set negation (which
produces gaps, Section 8), and each point falls into exactly one of four classes:

| Belnap value | Boundary status of $p$ w.r.t. $A$ | Condition |
|---|---|---|
| $\mathbf{T}$ (true) | interior of $A$ | $p \in \mathrm{int}(A)$ |
| $\mathbf{F}$ (false) | interior of the complement | $p \in \mathrm{int}(A^c)$ |
| $\mathbf{B}$ (both / glut) | in $A$'s frontier, on the closed side | $p \in \partial A \cap A$ |
| $\mathbf{N}$ (neither / gap) | in $A$'s frontier, on the open side | $p \in \partial A \setminus A$ |

Meet and join in the truth order correspond to $\cap$ and $\cup$ of regions;
Belnap negation corresponds to interchanging the roles of $A$ and $A^c$ (which
swaps $\mathbf{T} \leftrightarrow \mathbf{F}$ while fixing the two frontier
classes $\mathbf{B}$ and $\mathbf{N}$, exactly as required). The glut value
$\mathbf{B}$ is inhabited precisely when $\partial A \neq \emptyset$, recovering
Theorem 1 pointwise: **impossible objects live on frontiers**. In the finite /
explosive regime (Theorem 3) no frontier points exist, $\mathbf{B}$ and
$\mathbf{N}$ are uninhabited, and FOUR collapses to classical
$\{\mathbf{T},\mathbf{F}\}$.

---

## 8. Waking and dreaming: the open/closed duality

Dual to the closed-set logic is the **open-set logic** $\mathsf{OL}(X)$, the
standard topological model of **intuitionistic** logic. Its propositions are open
sets, conjunction is $\cap$, disjunction is $\cup$, and negation is the *interior
of the complement*,
$$\sim A = \mathrm{int}(A^c) = X \setminus \overline{A}.$$

**Theorem 4 (Open/closed De Morgan duality).** The map $c : S \mapsto X \setminus
S$ is an order-reversing bijection between the open sets and the closed sets that
interchanges the two logics:
$$c(\mathrm{int}(A^c)) = \overline{(A^c)^c}\big|_{\text{closed}}, \qquad
\text{i.e.}\quad c(\sim A) = \neg\, c(A),$$
and it interchanges $\cap \leftrightarrow \cup$, $\top \leftrightarrow \bot$.
Under this duality:

- **Excluded middle** $A \vee \sim A = \top$ in $\mathsf{OL}(X)$ fails exactly on
  the boundary $\partial A$ (the "gap"), while it *holds* in $\mathsf{CL}(X)$.
- **Non-contradiction** $A \wedge \neg A = \bot$ in $\mathsf{CL}(X)$ fails exactly
  on the boundary $\partial A$ (the "glut"), while it *holds* in $\mathsf{OL}(X)$.

Hence a point is a *gap* of the intuitionistic negation iff the complementary
point is a *glut* of the dream negation; the two logics fail on the **same
frontier**, from opposite sides.

*Proof.* The complement map is an order-reversing bijection between $\tau$ and
$\mathcal{C}(X)$ by definition of closed sets, and De Morgan's laws give $c(A \cap
B) = c(A) \cup c(B)$, $c(A \cup B) = c(A) \cap c(B)$, $c(\emptyset) = X$,
$c(X) = \emptyset$. For an open $A$, $\sim A = X \setminus \overline{A}$, so
$A \vee \sim A = A \cup (X \setminus \overline{A}) = X \setminus (\overline{A}
\setminus A) = X \setminus \partial A$; thus excluded middle fails exactly on
$\partial A$. Dually, for closed $A$, Theorem 1 gives $A \wedge \neg A =
\partial A$, so non-contradiction fails exactly on $\partial A$. Applying $c$ to
one negation yields the other by the closure/interior duality
$\overline{S} = (\mathrm{int}(S^c))^c$. $\qquad\blacksquare$

**Corollary 4.1 (Traded resources).** Consistency and completeness are dual
resources on a fixed space. Choosing open carriers yields a **paracomplete**
logic (gaps, excluded middle fails, non-contradiction holds); choosing closed
carriers yields a **paraconsistent** logic (gluts, non-contradiction fails,
excluded middle holds). Neither is definable from the other by a truth-functional
translation unless the space is discrete (in which case both are classical). The
reasoner selects paracompleteness or paraconsistency simply by reorienting from
open to closed.

---

## 9. Algorithms

We summarise the constructive content as algorithms over **finite** topological
spaces (given by an explicit family of open sets), which suffice to compute all
operations and to certify paraconsistency witnesses on any finite subspace or
finite model.

**Algorithm A (Boundary / glut computation).** Given a finite space $X$ (as a set
with its open family $\tau$) and a closed set $A$, compute $\mathrm{int}(A)$ as
the union of all opens contained in $A$, then return $\partial A = A \setminus
\mathrm{int}(A)$. $A$ is a glut-carrier iff the result is nonempty. Complexity
$O(|\tau|\cdot|X|)$.

**Algorithm B (Explosion test).** For each closed set $A$, compute $\partial A$ by
Algorithm A; the logic on $X$ is paraconsistent iff some $\partial A \neq
\emptyset$, explosive otherwise. On a finite space this always returns
"explosive" unless the topology is non-Alexandrov — impossible for finite spaces
— confirming Theorem 3 computationally for finite models and requiring an
explicit infinite witness (e.g. an interval on $\mathbb{R}$) for genuine
paraconsistency.

**Algorithm C (Duality check).** Given open $A$, compute intuitionistic
$\sim A = X \setminus \overline{A}$ and closed-set $\neg(X\setminus A)$; verify
$X \setminus (\sim A) = \neg(X \setminus A)$ and that both negations fail on the
same $\partial A$.

---

## 10. Applications

1. **Inconsistency-tolerant knowledge bases.** Model each atomic fact as a
   region; merging sources unions the regions. Conflicts localise to boundaries;
   downstream queries remain sound because non-explosion prevents a single
   conflict from making every query true. The "conflict mass" of a merged base is
   $\sum |\partial A_i|$.
2. **Non-monotone belief revision.** Because negation is the *closure* of the
   complement rather than a hard complement, retracting a belief shrinks a region
   to its interior rather than deleting it; boundary beliefs persist as gluts,
   modelling the graceful, non-catastrophic revision characteristic of human and
   dream cognition.
3. **Normative / legal reasoning.** Two statutes in genuine conflict correspond
   to overlapping closed regions whose intersection is a boundary glut; dream
   logic isolates the conflict to the precise cases on that boundary without
   trivialising the code.
4. **Robust artificial agents.** Agents ingesting the open web can adopt closed
   carriers to survive contradictory inputs, using boundary size as a calibrated
   measure of local uncertainty.

---

## 11. Discussion and future work

The results recast three classically distinct notions — a *true contradiction*, a
*topological boundary*, and the *failure of arbitrary unions of closed sets to be
closed* — as one phenomenon viewed from three angles. This suggests several
directions.

- **Gluts are exactly boundaries — a dimension-free law.** We conjecture that in
  *every* topological space, under the closed-set negation, the coexistence set of
  a region and its negation equals its frontier, so a region admits a coexisting
  contradiction iff its frontier is nonempty. The finite and real-line cases
  coincide exactly; the general statement needs only frontier calculus valid on
  arbitrary spaces.
- **Paraconsistency calibrated by union-failure.** We conjecture that a closed-set
  logic is explosive iff its space is finite (equivalently, closed sets are closed
  under arbitrary union); every infinite space is properly paraconsistent, with
  degree growing as the supremum of frontier cardinalities. Non-explosion and the
  non-closure of infinite unions are then a single, compactness-flavoured fact.
- **Dual pairs on one space.** We conjecture that for any space the open-set
  (intuitionistic) and closed-set (dream) logics are exact De Morgan duals:
  excluded middle holds in one exactly where non-contradiction holds in the other,
  and fixed points of the two negations correspond under complement; neither is
  truth-functionally definable from the other unless the space is discrete.

The overarching theme is that consistency and completeness are not absolute
virtues but **dual, tradeable resources**, selected by orienting one's
propositions toward the open or the closed. A reasoner facing contradictory
information is not obliged to choose collapse; it may choose a boundary.

---

## References (indicative)

- S. Jaśkowski, *Propositional calculus for contradictory deductive systems*
  (1948).
- N. da Costa, *On the theory of inconsistent formal systems* (1974).
- N. Belnap, *A useful four-valued logic* (1977); J. M. Dunn, *Intuitive
  semantics for first-degree entailments* (1976).
- C. Mortensen, *Inconsistent Mathematics* (1995); *Topological separation
  principles and logical theories* (2000).
- G. Priest, *In Contradiction* (2006).
- W. James & C. Mortensen, closed-set logic and topological duality (various).
