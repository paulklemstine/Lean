# Dream Logic: A Verified Bridge from Belnap's Four-Valued Paraconsistency to Topological Frontiers

**Author:** Aristotle

**Date:** 2026-06-20

---

## Abstract

We present a complete, machine-verified development of *dream logic* — a
paraconsistent and paracomplete reasoning framework in which contradictions are
permitted to coexist without trivializing the system, and in which beliefs may be
suspended or retracted. The development has three layers. First, an **algebraic**
layer formalizing Belnap's four-valued logic $\mathbf{FOUR}$ (the logic of First
Degree Entailment), with truth values $\{\mathtt{true}, \mathtt{false},
\mathtt{both}, \mathtt{neither}\}$, paraconsistent negation, lattice conjunction
and disjunction, and a notion of *designated* (accepted) value. We prove that the
Law of Non-Contradiction can fail, that the Law of Excluded Middle can fail, and
— the defining feature of paraconsistency — that the rule of explosion (*ex
contradictione quodlibet*) fails: an accepted contradiction does **not** entail
every proposition. We characterize the glut value $\mathtt{both}$ as the unique
source of tolerated contradictions and the gap value $\mathtt{neither}$ as the
unique source of suspended beliefs. Second, a **topological** layer modelling
paraconsistent negation as the co-Heyting operation $A \mapsto \overline{A^c}$
(closure of complement) on subsets of a topological space. We prove that, for a
closed set, the *contradiction set* $A \cap \overline{A^c}$ equals the topological
frontier, that the Law of Non-Contradiction holds exactly on the clopen sets, and
that on a preconnected space every proper nonempty closed set carries a contradiction.
Third, a **bridge** layer fusing the two: we assign each point of a closed set a
Belnap value and prove that a point receives the glut value $\mathtt{both}$ if and
only if it lies on the frontier — identifying the algebraic and topological notions
of "impossible object." A concrete dialetheia, the point $0 \in [0,1] \subset
\mathbb{R}$, is shown to carry the glut value and to be an accepted self-contradiction.
All results have been formalized and checked in the Lean 4 proof assistant.

**Keywords:** paraconsistent logic, Belnap FOUR, dialetheia, glut, gap, co-Heyting
algebra, frontier, clopen, non-monotone reasoning, De Morgan algebra.

---

## 1. Introduction

Classical logic is governed by two rules that, together, make inconsistency fatal.
The **Law of Non-Contradiction (LNC)** forbids any proposition from being both true
and false. The principle of **explosion**, *ex contradictione quodlibet* (ECQ),
states that from a contradiction $P \wedge \neg P$ everything follows. Under ECQ a
single inconsistency renders a theory trivial: every sentence becomes provable.

For many applications this is too brittle. Databases aggregated from conflicting
sources, knowledge bases assembled from imperfect informants, legal and ethical
codes harboring genuine dilemmas, and the formal analysis of self-referential
paradoxes all involve *localized* inconsistency that ought not to contaminate the
entire system. A **paraconsistent** logic is one whose consequence relation does
not validate ECQ: contradictions may be present without trivializing the theory.
A **paracomplete** logic dually rejects the Law of Excluded Middle (LEM), allowing
"truth-value gaps" where neither a proposition nor its negation is asserted.

The canonical algebraic home for both phenomena is Belnap's four-valued logic
$\mathbf{FOUR}$, introduced for reasoning in artificial databases. Its four values
record not metaphysical truth but the *information state* of a reasoner: a
proposition may be told true, told false, told *both* (a contradictory **glut**,
a *dialetheia*), or told *neither* (an information **gap**).

This paper formalizes $\mathbf{FOUR}$, develops a topological semantics for
paraconsistent negation, and — the central contribution — proves a precise bridge
theorem identifying the algebraic "impossible objects" of the logic with the
geometric boundary points of the topology. We refer to the combined framework as
*dream logic*, after the way dreaming cognition tolerates coexisting
impossibilities. Every theorem below has been verified in Lean 4; the prose proof
sketches mirror the formal proofs.

---

## 2. The algebraic layer: Belnap's $\mathbf{FOUR}$

### 2.1 Truth values and connectives

**Definition 2.1 (Belnap values).** The type $\mathbf{FOUR}$ consists of four
distinct values:
$$\mathbf{FOUR} = \{\, \mathtt{true},\ \mathtt{false},\ \mathtt{both},\ \mathtt{neither} \,\}.$$
Informally, $\mathtt{true}$ and $\mathtt{false}$ are the classical verdicts;
$\mathtt{both}$ is a *glut* (told true and told false at once — a dialetheia);
$\mathtt{neither}$ is a *gap* (no information either way — a suspended belief).

**Definition 2.2 (Paraconsistent negation).** Negation $\neg : \mathbf{FOUR} \to
\mathbf{FOUR}$ swaps the classical values and fixes the impossible objects:
$$\neg\,\mathtt{true} = \mathtt{false}, \quad \neg\,\mathtt{false} = \mathtt{true},
\quad \neg\,\mathtt{both} = \mathtt{both}, \quad \neg\,\mathtt{neither} = \mathtt{neither}.$$

**Definition 2.3 (Truth order and connectives).** Order the four values in a
diamond by "degree of truth," with $\mathtt{false}$ at the bottom, $\mathtt{true}$
at the top, and $\mathtt{both}, \mathtt{neither}$ incomparable in the middle:
$$\mathtt{false} \ <\ \mathtt{both},\ \mathtt{neither}\ <\ \mathtt{true}.$$
Conjunction $\wedge$ is the meet (greatest lower bound) and disjunction $\vee$ is
the join (least upper bound) in this order. On the two incomparable middle values,
$\mathtt{both} \wedge \mathtt{neither} = \mathtt{false}$ and $\mathtt{both} \vee
\mathtt{neither} = \mathtt{true}$; all other cases follow from the order.

**Definition 2.4 (Designation / acceptance).** A value is *designated* (asserted,
accepted, believed) precisely when it carries affirming evidence:
$$\mathrm{designated}(v) \iff v \in \{\mathtt{true}, \mathtt{both}\}.$$
The glut $\mathtt{both}$ is accepted *despite* being contradictory; this single
choice is what produces paraconsistency.

### 2.2 De Morgan algebra structure

The connectives endow $\mathbf{FOUR}$ with the structure of a De Morgan algebra.
All of the following hold (each proved by exhaustive case analysis over the four
values; in Lean, `cases x <;> cases y <;> rfl`).

**Proposition 2.5 (Lattice and De Morgan laws).** For all $x, y, z \in \mathbf{FOUR}$:

- *Involutive negation:* $\neg\neg x = x$.
- *Commutativity:* $x \wedge y = y \wedge x$ and $x \vee y = y \vee x$.
- *Associativity:* $(x \wedge y) \wedge z = x \wedge (y \wedge z)$ and dually for $\vee$.
- *Idempotence:* $x \wedge x = x$ and $x \vee x = x$.
- *Absorption:* $x \wedge (x \vee y) = x$ and $x \vee (x \wedge y) = x$.
- *De Morgan duality:* $\neg(x \wedge y) = \neg x \vee \neg y$ and $\neg(x \vee y)
  = \neg x \wedge \neg y$.

*Proof sketch.* $\mathbf{FOUR}$ is finite (four elements), so each identity reduces
to a finite check over all $4$, $16$, or $64$ combinations of arguments. The truth
order is a bounded distributive lattice (the diamond), and $\neg$ is the unique
order-reversing involution fixing the two middle points, which is exactly the
condition for a De Morgan algebra. $\square$

### 2.3 Failure of the classical laws and of explosion

**Theorem 2.6 (LNC can fail — `lnc_can_fail`).** There exists $x \in \mathbf{FOUR}$
with $\mathrm{designated}(x \wedge \neg x)$.

*Proof.* Take $x = \mathtt{both}$. Then $\neg x = \mathtt{both}$, so $x \wedge \neg
x = \mathtt{both} \wedge \mathtt{both} = \mathtt{both}$, which is designated. Thus
"$x$ and not-$x$" is accepted: a coexisting contradiction. $\square$

**Theorem 2.7 (LEM can fail — `lem_can_fail`).** There exists $x \in \mathbf{FOUR}$
with $\neg\,\mathrm{designated}(x \vee \neg x)$.

*Proof.* Take $x = \mathtt{neither}$. Then $\neg x = \mathtt{neither}$ and $x \vee
\neg x = \mathtt{neither}$, which is *not* designated. Hence neither $x$ nor its
negation is forced: a suspended belief. $\square$

**Theorem 2.8 (Explosion fails — `explosion_fails`).** It is **not** the case that
$$\forall x, y \in \mathbf{FOUR},\quad \mathrm{designated}(x \wedge \neg x)
\ \Rightarrow\ \mathrm{designated}(y).$$

*Proof.* Suppose for contradiction that the implication held universally. Instantiate
$x = \mathtt{both}$ and $y = \mathtt{false}$. By Theorem 2.6, $\mathrm{designated}
(\mathtt{both} \wedge \neg\,\mathtt{both})$ holds, so the hypothesis would force
$\mathrm{designated}(\mathtt{false})$ — but $\mathtt{false}$ is not designated.
Contradiction. Hence the rule of explosion is invalid: an accepted contradiction
does not entail every proposition. $\square$

This is the defining theorem of the framework: inconsistency is *local*. The
presence of an accepted contradiction at $\mathtt{both}$ confers no support on the
unrelated, non-designated value $\mathtt{false}$.

### 2.4 Exact responsibility of the impossible objects

The two impossible objects are not merely *examples* witnessing the failures of
LNC and LEM — each is the *unique* witness for one law.

**Theorem 2.9 (Glut characterization — `glut_iff`).** For every $x \in \mathbf{FOUR}$,
$$\mathrm{designated}(x \wedge \neg x) \iff x = \mathtt{both}.$$

**Theorem 2.10 (Gap characterization — `gap_iff`).** For every $x \in \mathbf{FOUR}$,
$$\neg\,\mathrm{designated}(x \vee \neg x) \iff x = \mathtt{neither}.$$

*Proof sketch (both).* Exhaustive evaluation over the four values. For each $x$,
compute $x \wedge \neg x$ (resp. $x \vee \neg x$) and test designation; only
$\mathtt{both}$ (resp. $\mathtt{neither}$) yields the stated outcome. $\square$

Thus the labor of non-classicality is perfectly partitioned: $\mathtt{both}$ alone
is responsible for tolerated contradictions, $\mathtt{neither}$ alone for suspended
beliefs.

### 2.5 Classical contrast

To certify that paraconsistency is a property of $\mathbf{FOUR}$ and not an artifact
of the ambient (classical) metatheory, we record the contrasting Boolean facts.

**Theorem 2.11 (No classical glut — `classical_no_glut`).** For every $b \in
\mathtt{Bool}$, $\neg(b \wedge \neg b)$ holds.

**Theorem 2.12 (Classical explosion — `classical_explosion`).** For all $b, q \in
\mathtt{Bool}$, $(b \wedge \neg b) \Rightarrow q$.

*Proof.* Both by the two-case analysis $b \in \{\mathtt{true}, \mathtt{false}\}$;
in either case $b \wedge \neg b$ is false, so the antecedent is vacuous. $\square$

Two-valued logic has no gluts and *does* explode; the divergent behavior of
$\mathbf{FOUR}$ is genuinely about its enlarged value set and the designation of
$\mathtt{both}$.

---

## 3. The topological layer: paraconsistent negation as closure of complement

The Tarski–McKinsey duality models intuitionistic logic by the *open* sets of a
topological space (a Heyting algebra, with negation $A \mapsto \mathrm{int}(A^c)$).
Dually, the *closed* sets form a co-Heyting (Brouwerian) algebra whose negation is
the natural carrier of paraconsistency.

Throughout, $X$ is a topological space, $A^c$ denotes complement, $\overline{A}$
closure, and $\mathrm{int}(A)$ interior.

**Definition 3.1 (Paraconsistent negation on sets).** For $A \subseteq X$,
$$\mathrm{pneg}(A) := \overline{A^c} \quad \text{(the closure of the complement).}$$

Unlike the classical complement, $\mathrm{pneg}$ permits a point to lie in both $A$
and $\mathrm{pneg}(A)$ — a *topological dialetheia*.

**Definition 3.2 (Contradiction set).** The contradiction set of $A$ is
$$\mathrm{contradiction}(A) := A \cap \mathrm{pneg}(A) = A \cap \overline{A^c}.$$
Its points are simultaneously inside $A$ and (in the closure of) outside $A$.

**Theorem 3.3 (Contradiction = frontier — `contradiction_eq_frontier`).** If $A$
is closed, then
$$\mathrm{contradiction}(A) = \mathrm{frontier}(A),$$
where $\mathrm{frontier}(A) = \overline{A} \setminus \mathrm{int}(A)$ is the
topological boundary.

*Proof sketch.* Using $\overline{A^c} = (\mathrm{int}\,A)^c$ and, for closed $A$,
$\overline{A} = A$, we get $\mathrm{contradiction}(A) = A \cap (\mathrm{int}\,A)^c
= A \setminus \mathrm{int}(A) = \overline A \setminus \mathrm{int}(A) =
\mathrm{frontier}(A)$. Formally this is `closure_compl` followed by
`IsClosed.frontier_eq` and a set-difference rewrite. $\square$

**Theorem 3.4 (LNC holds iff clopen — `lnc_holds_iff_clopen`).** If $A$ is closed,
then
$$\mathrm{contradiction}(A) = \varnothing \iff A \text{ is clopen.}$$

*Proof sketch.* By Theorem 3.3 the contradiction set equals the frontier, and a set
is clopen iff its frontier is empty (`isClopen_iff_frontier_eq_empty`). $\square$

Hence classical (contradiction-free) behavior is confined to the clopen sets. In a
space whose only clopen sets are $\varnothing$ and $X$ — for instance any connected
space — *every* nontrivial closed set is irreducibly paraconsistent.

**Corollary 3.5 (Non-clopen forces a dialetheia — `not_clopen_contradiction`).**
If $A$ is closed and not clopen, then $\mathrm{contradiction}(A) \neq \varnothing$.

*Proof.* Contrapositive of Theorem 3.4. $\square$

### 3.1 A concrete dialetheia in $\mathbb{R}$

**Theorem 3.6 (Real impossible object — `dream_object_real`).** In $\mathbb{R}$,
$$0 \in \mathrm{contradiction}([0,1]).$$

*Proof.* The interval $[0,1]$ is closed, so by Theorem 3.3 its contradiction set is
its frontier. The frontier of $[0,1]$ is $\{0,1\}$ (`frontier_Icc`, using $0 \le
1$), which contains $0$. Concretely, $0 \in [0,1]$ and $0 \in \overline{[0,1]^c}$
since $0$ is a limit of negative reals. $\square$

**Corollary 3.7 (`contradiction_nonempty_real`).** $\mathrm{contradiction}([0,1])
\neq \varnothing$, witnessed by $0$.

The point $0$ is a verified topological dialetheia: a real number simultaneously
inside and outside the interval $[0,1]$.

### 3.2 Connectedness forces dream logic

**Theorem 3.8 (Connectedness forces paraconsistency — `connected_forces_paraconsistency`).**
Let $X$ be preconnected. If $A \subseteq X$ is closed, $A \neq \varnothing$, and
$A^c \neq \varnothing$ (i.e. $A$ is a proper nonempty closed set), then
$$\mathrm{contradiction}(A) \neq \varnothing.$$

*Proof sketch.* By Corollary 3.5 it suffices to show $A$ is not clopen. If $A$ were
clopen, then by preconnectedness $A = \varnothing$ or $A = X$; the former
contradicts $A \neq \varnothing$ and the latter contradicts $A^c \neq \varnothing$.
The properness hypotheses are load-bearing: without them the frontier may be empty
(e.g. $A = X$). $\square$

On a one-piece space — a line, a plane, a sphere — no meaningful belief can be held
without admitting a contradiction on its boundary.

---

## 4. The bridge: frontiers *are* gluts

The two layers were built independently — one for the logic of databases, one for
the topology of sets. We now fuse them and prove they describe the same impossible
objects.

**Definition 4.1 (Pointwise valuation).** For $A \subseteq X$ and $x \in X$, define
the Belnap value
$$\mathrm{val}_A(x) = \begin{cases}
\mathtt{true} & \text{if } x \in \mathrm{int}(A), \\
\mathtt{false} & \text{if } x \in \mathrm{int}(A^c), \\
\mathtt{both} & \text{otherwise.}
\end{cases}$$
A point is $\mathtt{true}$ when robustly inside $A$, $\mathtt{false}$ when robustly
outside, and the glut $\mathtt{both}$ in the remaining (boundary) case.

**Theorem 4.2 (Frontier points are exactly the gluts — `val_both_iff_frontier`).**
For all $A \subseteq X$ and $x \in X$,
$$\mathrm{val}_A(x) = \mathtt{both} \iff x \in \mathrm{frontier}(A).$$

*Proof sketch.* Write the frontier as $\overline{A} \cap \overline{A^c}$. Using
$x \in \mathrm{int}(A) \iff x \notin \overline{A^c}$ and $x \in \mathrm{int}(A^c)
\iff x \notin \overline{A}$, a four-way case split on whether $x$ lies in
$\mathrm{int}(A)$ and/or $\mathrm{int}(A^c)$ shows that $\mathrm{val}_A(x) =
\mathtt{both}$ holds exactly in the case where $x$ lies in neither interior, which
is precisely membership in both closures, i.e. the frontier. $\square$

**Theorem 4.3 (Gluts are the contradiction set — `glut_iff_contradiction`).** If
$A$ is closed, then for all $x$,
$$\mathrm{val}_A(x) = \mathtt{both} \iff x \in \mathrm{contradiction}(A).$$

*Proof.* Combine Theorem 4.2 with Theorem 3.3. $\square$

**Theorem 4.4 (Faithfulness — `designated_iff_mem`).** If $A$ is closed, then for
all $x$,
$$\mathrm{designated}(\mathrm{val}_A(x)) \iff x \in A.$$

*Proof sketch.* For closed $A$, $\mathrm{int}(A^c) = A^c$, so $x \in
\mathrm{int}(A^c) \iff x \notin A$. Case on the three branches of $\mathrm{val}_A$:
if $x \in \mathrm{int}(A)$ then $\mathrm{val}_A(x) = \mathtt{true}$ is designated and
$x \in A$ (interior $\subseteq$ set); if $x \in \mathrm{int}(A^c)$ then
$\mathrm{val}_A(x) = \mathtt{false}$ is undesignated and $x \notin A$; otherwise
$\mathrm{val}_A(x) = \mathtt{both}$ is designated and, since $x \notin
\mathrm{int}(A^c) = A^c$, we have $x \in A$. In every branch designation matches
membership. $\square$

The valuation is therefore sound: acceptance of a point coincides with its actual
membership in the (closed) set, and the only "extra" accepted points beyond the
interior are precisely the boundary gluts.

**Theorem 4.5 (Frontier values are negation-fixed — `val_frontier_neg_fixed`).**
If $x \in \mathrm{frontier}(A)$ then $\neg\,\mathrm{val}_A(x) = \mathrm{val}_A(x)$.

*Proof.* By Theorem 4.2, $\mathrm{val}_A(x) = \mathtt{both}$, and $\neg\,
\mathtt{both} = \mathtt{both}$. $\square$

### 4.1 Capstone

**Theorem 4.6 (Concrete dialetheia is an accepted glut — `dream_object_real_is_glut`).**
For the interval $[0,1] \subset \mathbb{R}$ and the point $0$:

1. $\mathrm{val}_{[0,1]}(0) = \mathtt{both}$;
2. $\neg\,\mathrm{val}_{[0,1]}(0) = \mathrm{val}_{[0,1]}(0)$;
3. $\mathrm{designated}\big(\mathrm{val}_{[0,1]}(0) \wedge \neg\,\mathrm{val}_{[0,1]}(0)\big)$.

*Proof.* The interval is closed and, by Theorem 3.6, $0 \in
\mathrm{contradiction}([0,1])$. By Theorem 4.3, $\mathrm{val}_{[0,1]}(0) =
\mathtt{both}$, giving (1). Claim (2) follows since $\neg\,\mathtt{both} =
\mathtt{both}$. For (3), $\mathtt{both} \wedge \neg\,\mathtt{both} = \mathtt{both}
\wedge \mathtt{both} = \mathtt{both}$, which is designated — equivalently, apply the
glut characterization (Theorem 2.9) to $\mathtt{both}$. $\square$

This single statement simultaneously invokes real analysis (the frontier of an
interval), the topological model (Section 3), and the Belnap algebra (Section 2),
and certifies that the algebraic impossible object $\mathtt{both}$ and the geometric
impossible object (a boundary point) are one and the same.

---

## 5. Algorithms

Although the central results are proofs, the framework is fully computable on finite
data, and the topological model is decidable on concrete sets. We highlight two
algorithmic kernels.

**Algorithm A — Belnap connective evaluation.** Given two values in $\mathbf{FOUR}$
and a connective $\in \{\neg, \wedge, \vee\}$, return the result by table lookup in
the diamond truth order, and report designation. Complexity is $O(1)$ per operation;
evaluating a formula with $n$ connectives over a fixed assignment is $O(n)$.

**Algorithm B — Designation / explosion checker.** Enumerate all four values, and
for each compute $x \wedge \neg x$ and $x \vee \neg x$, testing designation. This
$O(1)$ search certifies Theorems 2.6, 2.7, 2.9, 2.10 by direct evaluation and
exhibits the explosion counterexample $(\mathtt{both}, \mathtt{false})$ of Theorem
2.8.

For the topological layer, the contradiction set of a closed set in a discrete or
combinatorial space is computed as $A \setminus \mathrm{int}(A)$; on $\mathbb{R}$
the frontier of an interval is read off symbolically as its endpoint set.

---

## 6. Applications

**Inconsistency-tolerant databases.** Belnap designed $\mathbf{FOUR}$ for query
engines over data aggregated from conflicting sources. The values $\mathtt{both}$
and $\mathtt{neither}$ promote "contested" and "unknown" to first-class states, so
that a single conflicting record cannot, via explosion, license arbitrary answers
(Theorem 2.8).

**Robust AI and sensor fusion.** Agents acting on contradictory sensor or knowledge
inputs need consequence relations that localize conflict; the gap/glut distinction
(Theorems 2.9–2.10) cleanly separates "missing" from "contested" evidence.

**Boundary reasoning and vagueness.** The bridge (Theorem 4.2) recasts borderline
cases as frontier points carrying the glut value. This gives a topological reading
of vagueness: an object is a "borderline $A$" exactly when it is a boundary point,
hence a dialetheia for $A$.

**Paradox analysis.** Paraconsistent logics provide a non-trivializing setting for
self-referential paradoxes; the verified failure of explosion supplies a rigorous
foundation that a single inconsistency does not collapse the surrounding theory.

---

## 7. Discussion

Three points deserve emphasis. First, the **partition of non-classicality**: the
two impossible objects are not interchangeable. The glut $\mathtt{both}$ is the
*unique* source of tolerated contradiction (Theorem 2.9) and the gap
$\mathtt{neither}$ the *unique* source of suspended belief (Theorem 2.10). Dream
logic is paraconsistent and paracomplete via two distinct, characterizable values.

Second, the **interpretation of the brief's slogan**. The informal motivation —
"open sets are not closed under arbitrary union" — is literally false for any
topology (open sets are *always* closed under arbitrary union). The correct dual
reading, which the formal development adopts, is that *closed sets need not be
open*: paraconsistency appears precisely where a closed set fails to be clopen
(Theorem 3.4). The contradiction lives in the gap between closed and open.

Third, the **genuineness of the bridge**. The algebra and the topology were
developed for unrelated reasons, yet their notions of impossible object coincide
exactly (Theorems 4.2–4.3, capstone 4.6). The dialetheia of the logician *is* the
boundary point of the topologist. Connectedness then makes the phenomenon generic:
on any one-piece space, every nontrivial belief is dialetheic (Theorem 3.8).

---

## 8. Future Directions

**Non-monotone consequence as a closure structure.** The default-generated family
of belief sets fails closure under binary union and so is not a topology. The next
step is to formalize what structure it *is*: a defeasible acceptance operator
captured by Tarski-style closure axioms minus monotonicity. Retractability is not a
defect to be repaired but the defining algebraic signature of defeasible reasoning,
so the right ambient category is the category of non-monotone closure operators on
the bilattice, where the obstruction concentrates at the glut value $\mathtt{both}$.

**Product bilattices and a closure-vs-triviality dichotomy.** Belnap $\mathbf{FOUR}$
is the bilattice $2 \odot 2$; the same evidence-bit construction works for $L \odot
L$ over any bounded lattice $L$, with defaults defined by "no refuting evidence."
The point obstructing union-closure in $\mathbf{FOUR}$ is the top glut; in $L \odot
L$ the analogous obstruction is the whole diagonal of fully conflicted values,
suggesting a sharp dichotomy: the default family is union-closed if and only if $L$
is trivial. Proving this would turn the one-off four-value theorem into a structural
classification.

**Bridging the two Alexandrov topologies through negation.** $\mathbf{FOUR}$ carries
two orders — knowledge and truth — and negation is monotone for knowledge while
being an anti-automorphism of truth. Each order induces its own Alexandrov topology,
and a full bilattice-topological dictionary should describe how negation,
conjunction, and disjunction act as continuous or co-continuous maps between them.
Interlacing (the truth operations being knowledge-monotone) is exactly the statement
that the truth operations are continuous for the information topology, so the
bilattice axioms can be re-read as continuity requirements linking the two spaces.

---

## 9. Conclusion

We have given a complete, machine-verified account of dream logic: an algebraic
core (Belnap $\mathbf{FOUR}$) in which contradictions coexist without explosion and
beliefs can be retracted; a topological semantics in which paraconsistent negation
is closure-of-complement and contradictions are frontier points; and a bridge
proving the two notions of impossible object are identical, anchored by the concrete
real dialetheia $0 \in [0,1]$. The picture that emerges is that inconsistency, far
from being a catastrophe, is a *boundary* — a marked place where inside meets
outside — that sound reasoning can quietly flow around.
