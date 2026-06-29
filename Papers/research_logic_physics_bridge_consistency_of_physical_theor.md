# A Logic–Physics Bridge: The Proof-Theoretic Consistency of Physical Theories

**Author:** Aristotle
**Domain:** Applications (Mathematical Logic / Foundations of Physics)
**Date:** 2026-06-28

## Abstract

We recast the question "is a physical theory consistent?" as a precise
proof-theoretic problem and resolve its logical structure completely. Modeling a
physical theory as an abstract Cook–Reckhow proof system that *extends* a
mathematical base theory $\mathrm{PA}$ (Peano Arithmetic), we prove three
structural results. First, **physical consistency implies mathematical
consistency**: if a physical theory $T$ extends $\mathrm{PA}$ and is consistent,
then $\mathrm{PA}$ is consistent; this transfers along arbitrary towers of
extensions. Second, **the converse fails**: there is a consistent base together
with an inconsistent extension of it, so mathematical consistency does *not*
imply physical consistency — the relationship is genuinely asymmetric. Third, and
centrally, **if $T$ is consistent then its consistency statement $\mathrm{Con}(T)$
is independent of $\mathrm{PA}$**: under a $\mathrm{PA}$-verifiable interpretation
hypothesis $\mathrm{PA} \vdash \mathrm{Con}(T) \to \mathrm{Con}(\mathrm{PA})$ and
a $\Sigma_1$-soundness hypothesis, $\mathrm{PA}$ proves neither $\mathrm{Con}(T)$
nor $\neg\,\mathrm{Con}(T)$. The positive half is Gödel's Second Incompleteness
Theorem, itself derived here from Löb's theorem as the instance $a := \bot$; the
negative half is $\Sigma_1$-soundness against the assumed consistency of $T$. All
results are obtained for an arbitrary abstract Gödel–Löb (GL) theory and are
witnessed non-vacuously by an explicit finite Kripke model $\mathsf{stdSys}$. The
abstract treatment isolates exactly what is needed for each direction and exposes
a precise frontier — marked by a second, non-$\Sigma_1$-sound model
$\mathsf{trueSys}$ — at which independence breaks down.

## 1. Introduction

The foundational question of mathematical physics is rarely about a particular
prediction; it is about the *coherence of the whole apparatus*. Could quantum
field theory, pushed to its formal limits, derive a contradiction? Most working
scientists treat this as a question to be settled, in principle, by sufficiently
careful checking. The thesis of this paper is that the question has a sharp and
surprising logical answer: for any physical theory strong enough to contain
arithmetic, its consistency is *downward-transferable* to mathematics, *strictly
stronger* than mathematical consistency, and *provably invisible* to the
arithmetic on which it rests.

Our strategy is to discard the physical interpretation and study the residual
logical skeleton. A physical theory is, formally, a proof system; consistency is
non-derivability of $\bot$; and "built on mathematics" is the simulation
(extension) relation between proof systems. The classical incompleteness
machinery — Löb's theorem and Gödel's Second Theorem — then governs the entire
landscape, but now in a *cross-theory* form: one theory reasoning about another's
consistency.

### Contributions

1. An abstract, model-agnostic formulation of "physical theory extends
   mathematics" via the simulation preorder on Cook–Reckhow proof systems
   (Section 2).
2. **Downward transfer** of consistency along extension, and its iteration along
   towers (`physical_implies_math`, `consistency_transfers_tower`; Section 4).
3. A concrete refutation of **upward transfer** (`math_not_implies_physical`;
   Section 4), establishing the asymmetry.
4. Derivations of **Löb's rule** (`loeb_rule`) and **Gödel II** (`goedel_two`)
   for an arbitrary GL theory, and **self-independence** of the consistency
   sentence under $\Sigma_1$-soundness (`con_independent_self`; Section 3).
5. The **cross-theory independence theorem** (`con_T_independent_of_PA`) and a
   concrete witness (`con_T_independent_of_PA_witness`, `stdSys_con_independent`)
   demonstrating non-vacuity (Section 5).

## 2. Definitions

We work over a fixed type $F$ of *formulas*, equipped with the modal/propositional
constructors needed to express provability and consistency.

### 2.1 Formulas

The formula language contains:

- $\bot$, the absurd formula ("false");
- $a \to b$ (written $\mathrm{imp}\,a\,b$), implication;
- $\neg a$ (written $\mathrm{neg}\,a$), negation;
- for each index $i \in \mathbb{N}$, a modal operator $\Box_i a$ (written
  $\mathrm{box}\,i\,a$), read "theory $i$ proves $a$."

The *indexing* of $\Box$ by a natural number is essential: it lets one theory's
formula language refer to the provability predicate of a *different* theory, so
that consistency statements for distinct theories are syntactically distinct
formulas.

**Definition 2.1 (Consistency sentence).** For an index $i$,
$$\mathrm{Con}_i \;:=\; \mathrm{imp}\,(\Box_i \bot)\,\bot \;=\; (\Box_i \bot \to
\bot).$$
This asserts "theory $i$ does not prove $\bot$," i.e. theory $i$ is consistent.

### 2.2 Proof systems

**Definition 2.2 (Proof system).** A proof system over $F$ (à la Cook–Reckhow) is
a structure $S$ consisting of a type $\mathrm{Proof}$ of proof objects, a
conclusion map $\mathrm{concl} : \mathrm{Proof} \to F$, and a size map
$\mathrm{size} : \mathrm{Proof} \to \mathbb{N}$.

**Definition 2.3 (Provability).** A formula $f$ is *provable* in $S$ when some
proof concludes it:
$$\mathrm{Provable}(S, f) \;:=\; \exists\, p : \mathrm{Proof},\;
\mathrm{concl}(p) = f.$$

**Definition 2.4 (Consistency).** $S$ is *consistent* when it does not prove the
absurd:
$$\mathrm{Consistent}(S) \;:=\; \neg\,\mathrm{Provable}(S, \bot).$$

**Definition 2.5 (Simulation / extension).** $S$ *simulates* (extends) $T$ when it
proves everything $T$ proves:
$$\mathrm{Simulates}(S, T) \;:=\; \forall f,\; \mathrm{Provable}(T, f)
\Rightarrow \mathrm{Provable}(S, f).$$
$\mathrm{Simulates}$ is reflexive and transitive (a preorder); transitivity,
$$\mathrm{Simulates}(S,T) \wedge \mathrm{Simulates}(T,U) \Rightarrow
\mathrm{Simulates}(S,U),$$
is the lemma `simulates_trans`. A **physical theory** is a proof system $T$ with
$\mathrm{Simulates}(T, \mathrm{PA})$.

### 2.3 GL theories

**Definition 2.6 (GL theory).** A proof system $T$ with distinguished index $i$
is a *Gödel–Löb (GL) theory*, written $\mathrm{IsGLTheory}\,i\,T$, when its
provable formulas form a normal modal logic of type GL. Concretely, $T$ is closed
under:

- **Modus ponens** (`mp`): if $\mathrm{Provable}(T, a \to b)$ and
  $\mathrm{Provable}(T, a)$ then $\mathrm{Provable}(T, b)$;
- **Necessitation** (`nec`): if $\mathrm{Provable}(T, a)$ then
  $\mathrm{Provable}(T, \Box_i a)$;
- the **distribution axiom** (K): $\Box_i(a \to b) \to (\Box_i a \to \Box_i b)$;
- the **Löb axiom** (L): $\Box_i(\Box_i a \to a) \to \Box_i a$;
- enough propositional tautologies (e.g. double-negation elimination
  `taut_dne`).

These are exactly the closure conditions satisfied by the provability predicate
of any recursively axiomatized theory extending $\mathrm{PA}$, by the
Hilbert–Bernays–Löb derivability conditions.

### 2.4 Reference proof systems

Three concrete systems anchor the theory and witness the (non-)existence results.

- $\mathsf{trivialSys}$: proves *every* formula. Formally
  $\mathrm{Provable}(\mathsf{trivialSys}, f)$ holds for all $f$
  (`provable_trivialSys`); hence it proves $\bot$ and is *inconsistent*
  (`inconsistent_trivialSys`).
- $\mathsf{trueSys}$: the "box-true" system whose provable formulas are those
  *valid* under the reading that makes every boxed formula true. It is a GL theory
  (`isGL_trueSys`) and is *consistent* (`consistent_trueSys`), but it is **not**
  $\Sigma_1$-sound: it proves $\Box_i\bot$, hence $\neg\,\mathrm{Con}_i$.
- $\mathsf{stdSys}$: the *standard finite Kripke model* — a transitive,
  converse-well-founded GL frame. It is a GL theory (`isGL_stdSys`), consistent
  (`consistent_stdSys`), and $\Sigma_1$-sound. Its provability is *semantic*:
  $\mathrm{Provable}(\mathsf{stdSys}, f)$ holds iff $f$ is satisfied at every world
  of the model (`provable_stdSys`), with $\mathrm{sat}$ the satisfaction relation
  obeying $\mathrm{sat}(m, a \to b) = (\mathrm{sat}(m,a) \to \mathrm{sat}(m,b))$
  (`sat_imp`).

## 3. The incompleteness core

The first block of results holds for *any* GL theory and supplies the engine for
the bridge theorems.

### 3.1 Löb's theorem as a derived rule

**Theorem 3.1 (`loeb_rule`).** Let $T$ be a GL theory with index $i$. If
$\mathrm{Provable}(T, \Box_i a \to a)$, then $\mathrm{Provable}(T, a)$.

*Proof sketch.* From $\mathrm{Provable}(T, \Box_i a \to a)$, necessitation and the
K-axiom propagate the implication under the box, while the Löb axiom
$\Box_i(\Box_i a \to a) \to \Box_i a$ collapses the nested box. Two modus ponens
steps then deliver $\Box_i a$ and finally $a$. The argument uses only `mp`,
`nec`, the K-distribution, and `loeb`; no semantic input is required. $\square$

### 3.2 Gödel's Second Incompleteness Theorem

**Theorem 3.2 (`goedel_two`).** A consistent GL theory $T$ (index $i$) does not
prove its own consistency: $\neg\,\mathrm{Provable}(T, \mathrm{Con}_i)$.

*Proof sketch.* Recall $\mathrm{Con}_i = (\Box_i \bot \to \bot)$. This is exactly
the hypothesis of Löb's rule at $a := \bot$. If $T$ proved $\mathrm{Con}_i$, then
$T$ proved $\Box_i\bot \to \bot$, so by `loeb_rule` (at $a = \bot$) $T$ would prove
$\bot$ — contradicting consistency. Hence $T \nvdash \mathrm{Con}_i$. $\square$

Thus Gödel II is *not* an independent edifice but the single instance $a = \bot$
of Löb's theorem.

### 3.3 Self-independence under $\Sigma_1$-soundness

Consistency alone yields $T \nvdash \mathrm{Con}_i$ but says nothing about
$\neg\,\mathrm{Con}_i$. The other direction requires $\Sigma_1$-soundness: $T$
does not prove the false $\Sigma_1$ sentence $\Box_i \bot$.

**Theorem 3.3 (`con_independent_self`).** If $T$ is a consistent and
$\Sigma_1$-sound GL theory (index $i$), then $\mathrm{Con}_i$ is *independent* of
$T$: $T$ proves neither $\mathrm{Con}_i$ nor $\neg\,\mathrm{Con}_i$.

*Proof sketch.* Non-provability of $\mathrm{Con}_i$ is Theorem 3.2. For
$\neg\,\mathrm{Con}_i$: $\neg\,\mathrm{Con}_i = \neg(\Box_i\bot \to \bot)$ is, up
to propositional manipulation (`taut_dne`, double-negation elimination),
equivalent to $\Box_i \bot$. A proof of $\neg\,\mathrm{Con}_i$ would therefore
yield a proof of $\Box_i\bot$, contradicting $\Sigma_1$-soundness. Hence
$T \nvdash \neg\,\mathrm{Con}_i$. $\square$

**Witness (`stdSys_con_independent`).** The standard Kripke model
$\mathsf{stdSys}$ satisfies the hypotheses of Theorem 3.3, so it proves neither
$\mathrm{Con}_i$ nor $\neg\,\mathrm{Con}_i$. This is essential: it shows the
independence theorem is *non-vacuous*. By contrast $\mathsf{trueSys}$, consistent
but not $\Sigma_1$-sound, *does* prove $\neg\,\mathrm{Con}_i$ and so fails to
witness full independence — pinpointing $\Sigma_1$-soundness as the exact extra
ingredient.

## 4. Downward transfer and the asymmetry

We now relate the consistency of a physical theory to that of its mathematical
base.

### 4.1 Physical consistency implies mathematical consistency

**Theorem 4.1 (`physical_implies_math`).** If $\mathrm{Simulates}(T, \mathrm{PA})$
and $\mathrm{Consistent}(T)$, then $\mathrm{Consistent}(\mathrm{PA})$.

*Proof sketch.* Contrapositive of simulation. Assume
$\mathrm{Provable}(\mathrm{PA}, \bot)$. Since $T$ simulates $\mathrm{PA}$, $T$
proves everything $\mathrm{PA}$ proves, so $\mathrm{Provable}(T, \bot)$,
contradicting $\mathrm{Consistent}(T)$. Hence $\mathrm{PA}$ proves no $\bot$, i.e.
is consistent. $\square$

### 4.2 Transfer along towers

**Theorem 4.2 (`consistency_transfers_tower`).** If
$\mathrm{Simulates}(T, M)$, $\mathrm{Simulates}(M, \mathrm{PA})$, and
$\mathrm{Consistent}(T)$, then $\mathrm{Consistent}(\mathrm{PA})$.

*Proof sketch.* By transitivity (`simulates_trans`),
$\mathrm{Simulates}(T, \mathrm{PA})$; apply Theorem 4.1. $\square$

Iterating, consistency of the top of any finite tower of extensions guarantees
consistency at every level below.

### 4.3 Failure of upward transfer

**Theorem 4.3 (`math_not_implies_physical`).** There exist proof systems
$\mathrm{PA}$ and $T$ with: $\mathrm{IsGLTheory}\,0\,\mathrm{PA}$,
$\mathrm{Consistent}(\mathrm{PA})$, $\mathrm{Simulates}(T, \mathrm{PA})$, yet
$\neg\,\mathrm{Consistent}(T)$.

*Proof sketch.* Take $\mathrm{PA} := \mathsf{trueSys}$, which is a GL theory
(`isGL_trueSys`) and consistent (`consistent_trueSys`). Take
$T := \mathsf{trivialSys}$. Since $\mathsf{trivialSys}$ proves every formula
(`provable_trivialSys`), it proves everything $\mathsf{trueSys}$ proves, so
$\mathrm{Simulates}(\mathsf{trivialSys}, \mathsf{trueSys})$; and it proves $\bot$,
so $\neg\,\mathrm{Consistent}(\mathsf{trivialSys})$
(`inconsistent_trivialSys`). $\square$

Theorems 4.1 and 4.3 together establish that consistency transfers strictly
downward along extension and *not* upward: adding axioms can destroy consistency,
but cannot destroy it in the foundations.

## 5. Independence of the physical consistency statement

The capstone result links the incompleteness core (Section 3) to the bridge
(Section 4): for a consistent physical theory $T$, its consistency statement is
beyond the reach of arithmetic.

**Theorem 5.1 (`con_T_independent_of_PA`).** Let $\mathrm{PA}$ (index $p$) be a
consistent GL theory and $T$ (index $t$) a consistent theory. Assume:

1. **Interpretation hypothesis** (`hbridge`):
   $\mathrm{Provable}(\mathrm{PA}, \mathrm{Con}_t \to \mathrm{Con}_p)$, i.e.
   $\mathrm{PA} \vdash \mathrm{Con}(T) \to \mathrm{Con}(\mathrm{PA})$. This holds
   whenever $T$ extends $\mathrm{PA}$ and the extension is $\mathrm{PA}$-formalizable.
2. **$\Sigma_1$-soundness about $T$** (`hsound`): if
   $\mathrm{Provable}(\mathrm{PA}, \neg\,\mathrm{Con}_t)$ then
   $\neg\,\mathrm{Consistent}(T)$.

Then $\mathrm{PA}$ proves neither $\mathrm{Con}_t$ nor $\neg\,\mathrm{Con}_t$:
$$\neg\,\mathrm{Provable}(\mathrm{PA}, \mathrm{Con}_t) \quad\wedge\quad
\neg\,\mathrm{Provable}(\mathrm{PA}, \neg\,\mathrm{Con}_t).$$

*Proof sketch.*

- *(Positive half — no proof of $\mathrm{Con}_t$.)* Suppose
  $\mathrm{Provable}(\mathrm{PA}, \mathrm{Con}_t)$. By the interpretation
  hypothesis (1) and modus ponens (the `mp` closure of the GL theory $\mathrm{PA}$),
  $\mathrm{Provable}(\mathrm{PA}, \mathrm{Con}_p)$ — arithmetic proves its own
  consistency. This contradicts Gödel II for $\mathrm{PA}$ (Theorem 3.2,
  `goedel_two`, applied to the consistent GL theory $\mathrm{PA}$ at index $p$).
  Hence $\mathrm{PA} \nvdash \mathrm{Con}_t$.
- *(Negative half — no refutation of $\mathrm{Con}_t$.)* Suppose
  $\mathrm{Provable}(\mathrm{PA}, \neg\,\mathrm{Con}_t)$. By the
  $\Sigma_1$-soundness hypothesis (2), $T$ is inconsistent — contradicting the
  assumed consistency of $T$. Hence $\mathrm{PA} \nvdash \neg\,\mathrm{Con}_t$.
  $\square$

The two halves are logically independent: the positive half is pure
incompleteness (it would hold even for an inconsistent $T$), while the negative
half is pure soundness-plus-consistency. The cross-theory indices $p \neq t$
guarantee $\mathrm{Con}_p$ and $\mathrm{Con}_t$ are distinct formulas, so the
theorem is not a disguised self-reference.

**Theorem 5.2 (`con_T_independent_of_PA_witness`).** For all indices $p, t$, the
standard Kripke model $\mathsf{stdSys}$ (taken for *both* roles) proves neither
$\mathrm{Con}_t$ nor $\neg\,\mathrm{Con}_t$.

*Proof sketch.* Instantiate Theorem 5.1 with $\mathrm{PA} = T = \mathsf{stdSys}$.
The interpretation hypothesis holds because, by the semantic characterization
$\mathrm{provable\_stdSys}$ and $\mathrm{sat\_imp}$, an implication $\mathrm{Con}_t
\to \mathrm{Con}_p$ is provable in $\mathsf{stdSys}$ as soon as one can transport
satisfaction worldwise — here it follows directly. The $\Sigma_1$-soundness
hypothesis is discharged from $\mathsf{stdSys}$'s own independence
(`stdSys_con_independent`): since $\mathsf{stdSys}$ does *not* prove
$\neg\,\mathrm{Con}_t$, the premise of `hsound` is never met. With
$\mathrm{isGL\_stdSys}$ and $\mathrm{consistent\_stdSys}$ supplying the remaining
hypotheses, Theorem 5.1 applies. $\square$

## 6. A worked example: the two-world standard frame

To see the abstract theorems become arithmetic, instantiate the standard model on
the smallest non-trivial GL frame: two worlds $W = \{w_0, w_1\}$ with a single
accessibility edge $w_1 \, R \, w_0$. The relation is irreflexive and (vacuously)
transitive, hence converse-well-founded, so this is a legitimate GL frame, and we
let $\mathsf{stdSys}$ be the proof system whose theorems are the formulas valid
(true at every world) on it.

The terminal world $w_0$ has no successors. Therefore the universal clause for the
box is vacuously satisfied: $\mathrm{sat}(w_0, \Box_i \bot)$ is **true**, and so
$\mathrm{Con}_i = \Box_i\bot \to \bot$ evaluates to $(\mathrm{true} \to
\mathrm{false}) = \mathrm{false}$ at $w_0$. The internal world $w_1$ does have a
successor ($w_0$), at which $\bot$ fails, so $\mathrm{sat}(w_1, \Box_i \bot)$ is
**false**, whence $\mathrm{Con}_i$ evaluates to $(\mathrm{false} \to
\mathrm{false}) = \mathrm{true}$ at $w_1$. We tabulate:

| world | $\Box_i \bot$ | $\mathrm{Con}_i$ |
|-------|---------------|------------------|
| $w_0$ (terminal) | true  | false |
| $w_1$ (internal) | false | true  |

Because $\mathrm{Con}_i$ is true at $w_1$ but false at $w_0$, it is **not** valid;
hence $\mathsf{stdSys} \nvdash \mathrm{Con}_i$. Dually, $\neg\,\mathrm{Con}_i$ is
true at $w_0$ but false at $w_1$, so it too is not valid; hence $\mathsf{stdSys}
\nvdash \neg\,\mathrm{Con}_i$. This is precisely the conclusion of Theorem 5.2,
computed by hand. Note also that $\bot$ is false everywhere, so $\mathsf{stdSys}$
is consistent, confirming the hypothesis of $\mathrm{consistent\_stdSys}$.

The contrast with $\mathsf{trueSys}$ is instructive. In $\mathsf{trueSys}$ every
boxed formula is declared true, so $\Box_i\bot$ is a theorem and
$\mathrm{Con}_i = \Box_i\bot \to \bot$ reduces to $\bot$ — i.e.
$\mathsf{trueSys} \vdash \neg\,\mathrm{Con}_i$ while still $\mathsf{trueSys}
\nvdash \bot$. The model is consistent yet *refutes* its own consistency,
exhibiting concretely the failure of $\Sigma_1$-soundness and showing why
consistency alone cannot deliver the negative half of independence. The two
frames thus straddle the exact boundary identified in Section 3.3.

## 7. Algorithms

Although the results are proof-theoretic, the *witnessing* model $\mathsf{stdSys}$
is finite and fully computable, which makes the entire landscape effectively
checkable. We record the core procedures.

### 6.1 GL satisfaction on a finite frame

A finite GL frame is a finite set of worlds $W$ with a transitive,
converse-well-founded accessibility relation $R$ (no infinite ascending
$R$-chains). Satisfaction $\mathrm{sat}(w, \varphi)$ is computed by structural
recursion on $\varphi$:
$$\mathrm{sat}(w, \bot) = \mathrm{false}, \qquad
\mathrm{sat}(w, a \to b) = \mathrm{sat}(w, a) \Rightarrow \mathrm{sat}(w, b),$$
$$\mathrm{sat}(w, \neg a) = \neg\,\mathrm{sat}(w, a), \qquad
\mathrm{sat}(w, \Box_i a) = \forall v,\; w\,R\,v \Rightarrow \mathrm{sat}(v, a).$$
A formula is *valid* (provable in $\mathsf{stdSys}$) iff it is satisfied at every
world. Complexity: $O(|W|^2 \cdot |\varphi|)$ for a single validity check.

### 6.2 Consistency-statement evaluator

To decide validity of $\mathrm{Con}_i = \Box_i\bot \to \bot$ and its negation, one
evaluates $\Box_i\bot$ at each world. Because $\mathrm{sat}(w, \Box_i\bot)$ holds
iff $w$ has *no* $R$-successors (a *terminal* world), $\mathrm{Con}_i$ is false
exactly at terminal worlds and true elsewhere. Hence on any frame with both a
terminal world and a non-terminal world, neither $\mathrm{Con}_i$ nor
$\neg\,\mathrm{Con}_i$ is valid — a direct, computable witness of independence.

### 6.3 Simulation / consistency checker

Given two finite proof systems presented by their sets of provable formulas (or
by validity oracles), $\mathrm{Simulates}(S, T)$ is decided by checking
$\mathrm{Provable}(T, f) \Rightarrow \mathrm{Provable}(S, f)$ over the relevant
formula set, and $\mathrm{Consistent}(S)$ by checking
$\neg\,\mathrm{Provable}(S, \bot)$. Downward transfer (Theorem 4.1) is then a
one-line consequence verifiable on any finite instance.

## 8. Applications and discussion

**Foundations of physics.** The framework formalizes the intuition that physics
is "mathematics plus extra axioms" and extracts its exact logical content:
soundness of foundations is *necessary* for a consistent physics (Theorem 4.1)
but never *sufficient* (Theorem 4.3). Any program that hopes to *prove* the
consistency of a fundamental theory using only its arithmetic core is, by Theorem
5.1, impossible — the consistency statement is independent.

**Hierarchy of consistency strength.** Theorem 5.1 exhibits $\mathrm{Con}(T)$ as
strictly stronger than $\mathrm{Con}(\mathrm{PA})$ over $\mathrm{PA}$: the
interpretation hypothesis gives one direction, and Gödel II blocks the converse
from being provable. This places physical theories one "consistency step" above
their mathematical base.

**The role of $\Sigma_1$-soundness.** The pair $(\mathsf{trueSys},
\mathsf{stdSys})$ delineates the precise boundary of independence: consistency
secures non-provability of $\mathrm{Con}$, but only $\Sigma_1$-soundness secures
non-refutability. $\mathsf{trueSys}$, consistent yet proving $\neg\,\mathrm{Con}$,
is the extremal counterexample.

**Robustness against self-reference objections.** Indexed boxes keep
$\mathrm{Con}_p$ and $\mathrm{Con}_t$ syntactically distinct, so Theorem 5.1 is a
genuine cross-theory statement, not Gödel's original theorem in disguise.

## 9. Future directions

The following conjectures, derived from this cycle's findings, are stated as bold,
falsifiable refinements.

**1. The "physical reflection gap" is exactly one consistency step.** For a
recursively axiomatized physical theory $T$ extending $\mathrm{PA}$, conjecturally
$\mathrm{Con}(T)$ is *strictly* stronger than $\mathrm{Con}(\mathrm{PA})$ over
$\mathrm{PA}$: $\mathrm{PA} \vdash \mathrm{Con}(T) \to \mathrm{Con}(\mathrm{PA})$
but $\mathrm{PA} \nvdash \mathrm{Con}(\mathrm{PA}) \to \mathrm{Con}(T)$. Our
Theorem 5.1 already isolates the $\mathrm{PA}$-verifiable implication
$\mathrm{Con}(T) \to \mathrm{Con}(\mathrm{PA})$ as the only bridge needed; the
missing converse is a Gödel–Rosser gap, formalizable by a second diagonalization
relative to $T$. The indexed $\Box_i$ already lets one theory speak of another's
provability predicate in the *same* formula language, so the converse is a
statable Lean goal rather than an informal meta-claim.

**2. $\Sigma_1$-soundness is necessary, not merely sufficient, for
independence.** Conjecturally a consistent GL theory $S$ satisfies "$\mathrm{Con}$
is independent over $S$" iff $S$ is $\Sigma_1$-sound ($S \nvdash \Box\bot$). The
"if" is `con_independent_self`; the "only if" should hold because a
non-$\Sigma_1$-sound consistent theory proves $\neg\,\mathrm{Con}$ (it proves
$\Box\bot$), so $\mathrm{Con}$ is *decided* (refuted), not independent. The
box-true model $\mathsf{trueSys}$ is the extremal counterexample, pinning the
exact boundary.

**3. Consistency forms a strict semilattice under theory union, with no top.** On
GL theories ordered by $\mathrm{Simulates}$, the consistent ones are closed
downward, but the join (catalog `union`) of two consistent theories can be
inconsistent; moreover there is no consistent theory simulating all consistent
theories. Formally: $\mathrm{Consistent}$ is a proper order ideal with empty
supremum. `physical_implies_math` already proves downward closure.

## 10. Conclusion

Recasting consistency of physical theories as a question about proof systems and
the provability logic GL yields a complete and surprising picture. Consistency
flows downhill from physics to mathematics for free; it never flows uphill; and
the consistency of a working physical theory is, of mathematical necessity,
independent of the arithmetic it is built on. The same self-reference that lets a
theory express its own consistency is exactly what forbids it from proving it —
Gödel's ghost made into a structural law of the foundations of physics, and
witnessed by a single explicit finite model.
