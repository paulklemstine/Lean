# Dream Logic: Interlaced Bilattices, Paraconsistent Consequence, and the Topology of Coexisting Contradictions

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

We develop the mathematics of *dream logic*: a framework for reasoning in
which contradictions can coexist without trivializing the system
(paraconsistency), statements may be neither true nor false
(paracompleteness), and conclusions may be withdrawn as premises grow
(non-monotonicity). The framework rests on three interlocking pillars.
First, we exhibit the full **interlaced bilattice** $\mathbf{FOUR}$ on the
four Belnap–Dunn truth values, equipping the carrier with two bounded
lattice orders — a *truth* order and a *knowledge* order — proving the
four interlacing laws that make them cohere, and establishing negation as
a truth-order anti-automorphism / knowledge-order automorphism together
with its dual, conflation. Second, we lift this algebra to a genuine
propositional **consequence relation** valued in $\mathbf{FOUR}$, prove it
satisfies the Tarskian structural rules (reflexivity, weakening, cut) and
the lattice/De Morgan laws, and prove that explosion, excluded middle, and
non-contradiction all fail — precisely the profile required for
paraconsistent, paracomplete reasoning. Third, we give a **topological
semantics** over an arbitrary topological space in which the
paraconsistent negation is the closure of the complement, and prove a
sharp criterion: *a closed proposition harbours a coexisting contradiction
if and only if it is not open*. Impossible objects (gluts) are exactly
boundary points, and the failure of arbitrary unions of closed sets to be
closed is exhibited as the structural root of non-monotonicity. All
results are stated with proof sketches and are self-contained.

## 1. Introduction

Classical logic validates the principle of *explosion* (ex contradictione
quodlibet): from $p$ and $\neg p$, an arbitrary conclusion $q$ follows.
This makes contradiction fatal — a single inconsistency renders a theory
trivial. Yet human reasoning, inconsistent databases, conflicting legal
codes, and — vividly — dream cognition all tolerate local contradictions
while continuing to reason sensibly. **Paraconsistent** logics are those
in which explosion fails.

We formalize a paraconsistent, paracomplete, non-monotone logic — *dream
logic* — organized around three questions:

1. **Algebra.** What is the minimal algebraic structure of truth values
   that supports coexisting contradictions and revisable belief?
2. **Proof theory / semantics.** Does that algebra induce a genuine
   consequence relation with the expected structural behaviour, in which
   contradictions demonstrably fail to explode?
3. **Geometry.** Where do contradictions come from? Is there a natural
   semantics that *forces* gluts to exist, and connects them to a concrete
   mathematical phenomenon?

Our answers are, respectively: the interlaced bilattice $\mathbf{FOUR}$
(§3); a $\mathbf{FOUR}$-valued consequence relation that is Tarskian yet
non-explosive (§4); and a closed-set topological semantics in which gluts
are exactly boundary points and non-monotonicity is the failure of
infinite unions of closed sets to remain closed (§5).

## 2. Preliminaries and notation

Throughout, a **partial order** on a set $S$ is a reflexive,
antisymmetric, transitive relation. A **bounded lattice** is a partial
order with binary meets ($\wedge$, greatest lower bounds) and joins
($\vee$, least upper bounds) together with a least and greatest element.
For a topological space $X$, we write $\overline{S}$ for the closure of
$S \subseteq X$, $\operatorname{int}(S)$ for its interior, $S^c$ for its
complement, and $\partial S = \overline{S} \setminus \operatorname{int}(S)$
for its frontier (topological boundary). A set is **clopen** if it is both
closed and open.

## 3. The interlaced bilattice $\mathbf{FOUR}$

### 3.1 Carrier and the two orders

Let the carrier be the four Belnap–Dunn values

$$\mathbf{FOUR} = \{\, \mathbf{t},\ \mathbf{f},\ \top,\ \bot \,\},$$

read as *true only*, *false only*, *both* (a **glut**: true and false at
once — an impossible object), and *neither* (a **gap**: undetermined).

**Definition 3.1 (Truth order).** Define $a \le_t b$ iff $a = \mathbf{f}$,
or $b = \mathbf{t}$, or $a = b$. This makes $\mathbf{f}$ the bottom,
$\mathbf{t}$ the top, and leaves $\top, \bot$ incomparable in the middle.

**Definition 3.2 (Knowledge order).** Define $a \le_k b$ iff
$a = \bot$, or $b = \top$, or $a = b$. This makes $\bot$ the bottom,
$\top$ the top, and leaves $\mathbf{t}, \mathbf{f}$ incomparable.

**Proposition 3.3.** Both $\le_t$ and $\le_k$ are partial orders.

*Proof sketch.* Reflexivity is immediate from the third disjunct.
Transitivity and antisymmetry are verified by exhausting the sixteen
ordered pairs of values in each case; the incomparable middle pairs
($\{\top,\bot\}$ for $\le_t$, $\{\mathbf{t},\mathbf{f}\}$ for $\le_k$)
never satisfy both directions, forcing equality. $\square$

### 3.2 The four operations

The truth lattice carries **conjunction** $\wedge$ (truth meet) and
**disjunction** $\vee$ (truth join). The knowledge lattice carries
**consensus** $\otimes$ (knowledge meet: retain only what both inputs
agree on) and **gullibility** $\oplus$ (knowledge join: accept information
from either input). Their action on the pure values is classical; on
gluts and gaps it is fixed by the order structure. Representative values:

$$\top \wedge \bot = \mathbf{f}, \quad \top \vee \bot = \mathbf{t}, \quad
\mathbf{t} \otimes \mathbf{f} = \bot, \quad \mathbf{t} \oplus \mathbf{f} = \top.$$

**Theorem 3.4 (Lattice structure).**
$\wedge$ and $\vee$ are the greatest lower bound and least upper bound for
$\le_t$; $\otimes$ and $\oplus$ are the greatest lower bound and least
upper bound for $\le_k$. Moreover $\mathbf{f} \le_t x \le_t \mathbf{t}$ and
$\bot \le_k x \le_k \top$ for all $x$.

*Proof sketch.* For each operation we prove the two projection laws (the
meet is below each argument; each argument is below the join) and the
universal property (any common lower bound is below the meet; any common
upper bound is above the join) by case analysis over the finite carrier.
The bounds are immediate from Definitions 3.1–3.2. $\square$

From the glb/lub characterizations, the standard lattice identities follow
without further case analysis:

**Corollary 3.5.** Each of $\wedge, \vee, \otimes, \oplus$ is commutative,
associative, and idempotent, and the absorption laws hold, e.g.
$a \wedge (a \vee b) = a$ and $a \otimes (a \oplus b) = a$.

*Proof sketch.* Commutativity, idempotence, and absorption are derived
abstractly from antisymmetry plus the universal properties of Theorem 3.4
(the meet of the two symmetric bounds is forced to be equal). Associativity
is confirmed by finite evaluation. $\square$

### 3.3 Interlacing

**Theorem 3.6 (Interlacing laws).** Each operation is monotone in the
*other* order:

$$
\begin{aligned}
a \le_k b,\ c \le_k d &\ \Rightarrow\ (a \wedge c) \le_k (b \wedge d), &
a \le_k b,\ c \le_k d &\ \Rightarrow\ (a \vee c) \le_k (b \vee d),\\
a \le_t b,\ c \le_t d &\ \Rightarrow\ (a \otimes c) \le_t (b \otimes d), &
a \le_t b,\ c \le_t d &\ \Rightarrow\ (a \oplus c) \le_t (b \oplus d).
\end{aligned}
$$

*Proof sketch.* Each is a finite monotonicity check over the four-element
carrier for both arguments. $\square$

These four conditions are exactly the axioms defining an **interlaced
bilattice**. With Theorem 3.4 and Corollary 3.5 they establish that
$\mathbf{FOUR}$ is the smallest nontrivial interlaced bilattice — the
Ginsberg–Fitting structure canonical for reasoning with coexisting
contradictions and revisable belief.

### 3.4 Negation and conflation

**Definition 3.7.** *Negation* $\neg$ swaps $\mathbf{t} \leftrightarrow
\mathbf{f}$ and fixes $\top, \bot$. *Conflation* $c$ swaps
$\top \leftrightarrow \bot$ and fixes $\mathbf{t}, \mathbf{f}$.

**Theorem 3.8 (Negation).** $\neg$ is an involution
($\neg\neg a = a$) that **reverses** the truth order
($a \le_t b \iff \neg b \le_t \neg a$) and **preserves** the knowledge
order ($a \le_k b \iff \neg a \le_k \neg b$). Consequently it satisfies
the truth-lattice De Morgan laws,
$$\neg(a \wedge b) = \neg a \vee \neg b, \qquad
\neg(a \vee b) = \neg a \wedge \neg b,$$
and is a **homomorphism** of the knowledge lattice,
$\neg(a \otimes b) = \neg a \otimes \neg b$ and
$\neg(a \oplus b) = \neg a \oplus \neg b$.

**Theorem 3.9 (Conflation).** $c$ is an involution that **reverses** the
knowledge order and **preserves** the truth order; dually to Theorem 3.8
it is a truth-lattice homomorphism and satisfies the knowledge-lattice De
Morgan laws $c(a \otimes b) = c\,a \oplus c\,b$ and
$c(a \oplus b) = c\,a \otimes c\,b$. Negation and conflation commute:
$\neg(c\,a) = c(\neg a)$.

*Proof sketch (3.8–3.9).* Involution, the order equivalences, and each
homomorphism/anti-homomorphism identity are verified by evaluation over
the finite carrier. $\square$

Thus negation is a truth-order anti-automorphism and knowledge-order
automorphism, while conflation is exactly its dual — the two reflections
of the bilattice across its two axes.

### 3.5 Paraconsistency at the algebraic level

Call a value **designated** (accepted as at-least-true) iff it is
$\mathbf{t}$ or $\top$.

**Theorem 3.10 (Designated values form a truth filter).** The set
$\{\mathbf{t}, \top\}$ contains the truth-top $\mathbf{t}$, is upward
closed in $\le_t$, and is closed under $\wedge$.

**Theorem 3.11 (Paraconsistency of $\mathbf{FOUR}$).** There is a value
$a$ (namely $\top$) with $a \wedge \neg a$ designated, yet
$a \wedge \neg a$ is not $\le_t$ an arbitrary value $b$; and there remains
a non-designated value. Hence a designated contradiction does not entail
everything.

**Theorem 3.12 (Paracompleteness).** There is a value $a$ (namely $\bot$)
with $a \vee \neg a$ not designated: excluded middle fails.

*Proof sketch.* For 3.10, upward closure and $\wedge$-closure are finite
checks. For 3.11, $\top \wedge \neg\top = \top$ is designated but
$\top \not\le_t \mathbf{f}$, and $\mathbf{f}$ is undesignated. For 3.12,
$\bot \vee \neg\bot = \bot$ is undesignated. $\square$

## 4. The paraconsistent consequence relation

### 4.1 Syntax and semantics

**Definition 4.1 (Formulas).** Over an atom type $V$, formulas are built
by $\varphi ::= p \mid \neg\varphi \mid \varphi \wedge \psi \mid
\varphi \vee \psi$ with $p \in V$.

**Definition 4.2 (Valuation and evaluation).** A *valuation* is a map
$v : V \to \mathbf{FOUR}$. It evaluates formulas by interpreting $\neg,
\wedge, \vee$ as the bilattice negation, truth meet, and truth join of §3.

**Definition 4.3 (Consequence).** A formula is *satisfied* by $v$ when its
value is designated. For $\Gamma \cup \{\varphi\}$ a set of formulas,
$$\Gamma \vDash \varphi \iff \text{every valuation satisfying all of }
\Gamma \text{ satisfies } \varphi.$$

### 4.2 Structural rules

**Theorem 4.4 ($\vDash$ is Tarskian).** The relation $\vDash$ satisfies:

- **Reflexivity:** if $\varphi \in \Gamma$ then $\Gamma \vDash \varphi$;
- **Weakening/monotonicity:** if $\Gamma \subseteq \Delta$ and
  $\Gamma \vDash \varphi$ then $\Delta \vDash \varphi$;
- **Cut:** if $\Gamma \vDash \varphi$ and
  $\Gamma \cup \{\varphi\} \vDash \psi$ then $\Gamma \vDash \psi$.

*Proof sketch.* Reflexivity and weakening are immediate from Definition
4.3. For cut, any valuation satisfying $\Gamma$ satisfies $\varphi$ by the
first hypothesis, hence satisfies $\Gamma \cup \{\varphi\}$, hence
satisfies $\psi$ by the second. $\square$

### 4.3 Behaviour of the connectives

**Theorem 4.5 (Lattice rules).** $\vDash$ validates
$\wedge$-introduction (from $\Gamma \vDash \varphi$ and $\Gamma \vDash
\psi$ conclude $\Gamma \vDash \varphi \wedge \psi$), both
$\wedge$-eliminations, and both $\vee$-introductions.

**Theorem 4.6 (De Morgan is valid).**
$\neg(\varphi \wedge \psi) \vDash \neg\varphi \vee \neg\psi$.

*Proof sketch.* Each rule reduces, via Definition 4.2, to a property of
the designated filter (Theorem 3.10) together with the glb/lub laws
(Theorem 3.4): $\wedge$-introduction is filter closure under $\wedge$;
elimination and $\vee$-introduction are upward closure applied to
$\varphi \wedge \psi \le_t \varphi$ and $\varphi \le_t \varphi \vee \psi$.
De Morgan is the identity $\neg(a \wedge b) = \neg a \vee \neg b$ of
Theorem 3.8 applied pointwise. $\square$

### 4.4 The three classical failures

**Theorem 4.7 (Explosion fails — paraconsistency).** For distinct atoms
$p \ne q$, $\{p, \neg p\} \not\vDash q$.

*Proof.* Take $v$ sending $q \mapsto \mathbf{f}$ and every other atom to
$\top$. Then $v(p) = \top$ is designated and $\neg v(p) = \top$ is
designated, so both premises hold; but the conclusion evaluates to
$\mathbf{f}$, undesignated. $\square$

**Theorem 4.8 (Contradiction is satisfiable).** For any atom $p$ there is
a valuation designating both $p$ and $\neg p$ — the constant $\top$
valuation.

**Theorem 4.9 (Excluded middle fails — paracompleteness).**
$\varnothing \not\vDash \varphi \vee \neg\varphi$.

*Proof.* The constant $\bot$ valuation gives $\varphi \vee \neg\varphi$
the value $\bot$, undesignated. $\square$

**Theorem 4.10 (Non-contradiction fails).**
$\varnothing \not\vDash \neg(\varphi \wedge \neg\varphi)$.

*Proof.* Again the constant $\bot$ valuation leaves
$\neg(\varphi \wedge \neg\varphi)$ at $\bot$, undesignated; contradictions
are actively tolerated, not merely undecided. $\square$

Theorems 4.4–4.10 together certify $\vDash$ as a well-behaved Tarskian
logic that is simultaneously paraconsistent and paracomplete — the
Belnap–Dunn first-degree entailment profile realized concretely over
$\mathbf{FOUR}$.

## 5. Topological semantics: gluts as boundaries

We now answer where contradictions come from. Fix a topological space $X$.
A **proposition** is a subset $A \subseteq X$ (the points where it holds).

**Definition 5.1 (Paraconsistent negation).**
$\neg A := \overline{A^c}$, the closure of the complement.

**Proposition 5.2.** $\neg A$ is always closed.

**Theorem 5.3 (Excluded middle survives).** For every $A$,
$A \cup \neg A = X$.

*Proof.* If $x \notin A$ then $x \in A^c \subseteq \overline{A^c} = \neg A$. $\square$

**Theorem 5.4 (Gluts are boundary points).** For closed $A$,
$$A \cap \neg A = \partial A.$$

*Proof.* $\neg A = \overline{A^c} = (\operatorname{int} A)^c$, so
$A \cap \neg A = A \setminus \operatorname{int} A = \overline{A}
\setminus \operatorname{int} A = \partial A$, using $A$ closed. $\square$

**Theorem 5.5 (Double-negation elimination for closed propositions).**
For closed $A$, $\neg\neg A \subseteq A$.

*Proof.* $\neg\neg A = \overline{(\overline{A^c})^c}
= \overline{\operatorname{int} A} \subseteq \overline{A} = A$. $\square$

**Theorem 5.6 (Paraconsistency criterion).** For closed $A$,
$$A \cap \neg A \ne \varnothing \iff A \text{ is not open}.$$
Equivalently, $A$ is *glut-free* ($A \cap \neg A = \varnothing$) iff $A$ is
clopen.

*Proof.* By Theorem 5.4, $A \cap \neg A = \partial A$. A closed set has
empty frontier iff it is clopen (hence open); so nonempty intersection is
equivalent to $A$ not being open. $\square$

Thus impossible objects are precisely boundary points, and paraconsistency
of a closed proposition is precisely its failure to be clopen.

**Theorem 5.7 (Non-isolated points are impossible objects).** In a $T_1$
space, if $\{p\}$ is not open then $\{p\} \cap \neg\{p\} \ne \varnothing$.

*Proof.* Immediate from Theorem 5.6, since singletons are closed in a
$T_1$ space. $\square$

**Theorem 5.8 (Structural root of non-monotonicity).** In a $T_1$ space,
let $(x_n)$ be a sequence of points with $x_n \ne p$ for all $n$ and
$x_n \to p$. Then each $\{x_n\}$ is closed, but $\bigcup_n \{x_n\}$ is
**not** closed.

*Proof.* Singletons are closed in $T_1$. Since $x_n \to p$, the point $p$
lies in the closure of $\bigcup_n \{x_n\}$; were the union closed, $p$
would belong to it, forcing $p = x_n$ for some $n$, contradicting
$x_n \ne p$. $\square$

**Interpretation.** Each $\{x_n\}$ is an established, closed proposition;
their unbounded union fails to be closed — it loses its limit point. A
totality of individually settled facts need not itself be settled. This is
exactly non-monotonicity: enlarging a body of premises can withdraw the
conclusion that the totality is a closed (settled) proposition. Belief
retraction is inscribed in the topology of limits.

**Theorem 5.9 (Degeneration to classical logic).** Every closed
proposition is glut-free (no contradictions anywhere) iff every closed set
of $X$ is open.

*Proof.* Pointwise application of Theorem 5.6 across all closed $A$. $\square$

Theorem 5.9 exhibits classical (explosive) logic as the degenerate limit
of dream logic: it is exactly the failure of open sets to be closed under
the relevant operations — the existence of genuine boundaries — that gives
the logic its coexisting contradictions.

## 6. Algorithms and computation

The finiteness of $\mathbf{FOUR}$ makes every algebraic and semantic claim
decidable by exhaustive evaluation. Three algorithms suffice for a full
computational realization (detailed with complexity and pseudocode in the
accompanying package):

1. **Bilattice operation tables and law verification.** Tabulate
   $\wedge, \vee, \otimes, \oplus, \neg, c$ and verify partial-order,
   lattice, interlacing, and (anti-)automorphism laws by checking all
   $\le 4^k$ tuples. Cost $O(4^k)$ per $k$-ary law; constant for the whole
   finite suite.
2. **Consequence checking.** To decide $\Gamma \vDash \varphi$ for
   formulas over $n$ atoms, enumerate all $4^n$ valuations, evaluate each
   formula bottom-up, and check the designation implication. Cost
   $O(4^n \cdot |\Gamma\cup\{\varphi\}| \cdot s)$ with $s$ the formula
   size — a sound and complete decision procedure over the finite algebra.
3. **Topological glut detection.** For a finite topological space given by
   its closed sets, compute $\neg A = \overline{A^c}$ and
   $\partial A = A \cap \neg A$, and classify each closed proposition as
   classical (clopen) or glutty by the criterion of Theorem 5.6.

## 7. Applications

- **Inconsistency-tolerant databases and knowledge bases.** Records that
  contradict are assigned $\top$ rather than triggering global collapse;
  queries return sensible answers about the consistent fragment.
- **Belief revision and default reasoning.** The knowledge order and the
  gap $\bot$ model partial information; the non-monotonicity of §5 gives a
  principled account of retracting conclusions as evidence accumulates.
- **Reasoning about boundaries.** Theorem 5.4 offers a logic of vague or
  borderline predicates in which borderline cases are literally the
  boundary points of the extension of a predicate.
- **Multi-source information fusion.** Consensus $\otimes$ and gullibility
  $\oplus$ model conservative and credulous merging of sources.

## 8. Discussion

The three pillars reinforce one another. The algebra (§3) supplies the
minimal semantic space; the consequence relation (§4) shows this space
yields a genuine, well-behaved logic; and the topology (§5) explains the
*origin* of the gluts the algebra permits, tying an abstract logical
phenomenon to the concrete geometric notion of a boundary. The bridge in
Theorem 5.6 — gluts iff not clopen — and the degeneration in Theorem 5.9
locate classical logic precisely as the boundary-free limit, making the
slogan "dreams are boundaries" a theorem rather than a metaphor.

## 9. Future directions

This cycle deepened the dream-logic development (paraconsistent,
non-monotone, belief-revisable reasoning where contradictions coexist)
with three self-contained results: the full interlaced bilattice
$\mathbf{FOUR}$; the closed-set semantics generalized from the real line
to arbitrary topological spaces with a sharp paraconsistency criterion;
and a genuine consequence relation with Tarskian structural rules and
formal non-explosion. Natural next steps:

1. **Bundle $\mathbf{FOUR}$ as an algebraic typeclass** and prove the
   representation theorem: every interlaced bilattice embeds in a product
   $L \odot L$ of a lattice with itself, with $\mathbf{FOUR} = 2 \odot 2$.
2. **Completeness of the consequence relation.** Add a Hilbert- or
   sequent-style proof system for the $\neg/\wedge/\vee$ fragment and prove
   soundness and completeness against the $\mathbf{FOUR}$-valuation
   semantics (first-degree entailment).
3. **A formal non-monotonic operator.** Lift value-level belief retraction
   to a closed-world consequence operator $\Gamma \mathrel{|\!\sim}
   \varphi$ on formulas and prove it genuinely non-monotone while its
   monotone core coincides with $\vDash$.
4. **Topological completeness.** Characterize which bilattices arise as
   $(\text{closed sets}, \neg)$ of a space, linking $\mathbf{FOUR}$-models
   and closed-set algebras.
5. **Larger bilattices / a continuum of gluts.** Replace the two-element
   base lattice by $[0,1]$ to obtain a *fuzzy* dream logic
   $[0,1] \odot [0,1]$ where gluts form a continuum, and re-derive the
   interlacing and paraconsistency results there.

## 10. Conclusion

Dream logic is a mathematics that can hold a contradiction without
breaking. Its four-valued interlaced bilattice, its Tarskian yet
non-explosive consequence relation, and its topological semantics —
where impossible objects are exactly boundary points and belief retraction
is the failure of infinite unions of closed sets to stay closed — together
give a rigorous account of reasoning as it actually happens in dreams,
databases, and disputed theories.
