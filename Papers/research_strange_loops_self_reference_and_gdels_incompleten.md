# Strange Loops: A Dependency Chain from the Liar Paradox to Non-Vacuous Gödelian Incompleteness

## Abstract

We develop a single, self-contained dependency chain of results on self-reference,
diagonalization, and incompleteness, organized around one methodological correction. The
naive picture of a "semantic strange loop" — a system whose diagonal operator returns,
for *every* property, a sentence whose *truth* equals that property applied to itself — is
inconsistent: it is the Liar paradox in disguise. Genuine Gödelian incompleteness escapes
this collapse by diagonalizing against the *syntactic provability* predicate rather than
truth, and by requiring a fixed point only for the single unprovability predicate. We make
this precise. Starting from the propositional Liar $\lnot(p \iff \lnot p)$, we (i) prove
that no total semantic diagonal exists; (ii) extract the propositional skeleton of Gödel's
First Incompleteness and Undecidability theorems from soundness alone; (iii) present
Lawvere's fixed-point theorem as the categorical heart of every diagonal argument and
derive Cantor's, Tarski's, and Rice's theorems as corollaries; (iv) define a *consistent,
inhabited* provability system and prove genuine, non-vacuous incompleteness,
undecidability, and a Löb-style unprovability of consistency within it; and (v) recast
incompleteness order-theoretically as a strict gap between the least and greatest fixed
points of a monotone closure operator on the lattice of theories. The emphasis throughout
is that consistency-preserving self-reference is possible only when it is *tangled across
two levels* — truth and provability — that are permitted to disagree.

**Keywords:** Liar paradox, diagonalization, Gödel incompleteness, Lawvere fixed-point
theorem, Cantor's theorem, Tarski undefinability, Rice's theorem, Löb's theorem,
provability, Knaster–Tarski, complete lattice, strange loops.

---

## 1. Introduction

Self-reference is the common engine of a surprisingly diverse family of limitative
results: Cantor's theorem on cardinalities, Russell's paradox, Turing's halting problem,
Tarski's undefinability of truth, Rice's theorem on program properties, and Gödel's
incompleteness theorems. Each is, at bottom, a diagonal argument, and each turns a would-be
loop of self-reference into either an outright contradiction (a paradox) or a permanent
structural limitation (a theorem).

The distinction between paradox and theorem is the pivot of this paper. A *paradox* arises
when self-reference is allowed to loop truth directly onto truth; the system then proves
its own inconsistency. A *theorem* arises when the loop is deflected through a strictly
weaker, syntactic surrogate for truth — provability — so that the loop closes at a slight
angle, leaving a residue (a true-but-unprovable sentence) instead of a contradiction.
Douglas Hofstadter's phrase **strange loop** names exactly this phenomenon: a hierarchy
that, climbed far enough, folds back on itself.

Our contribution is expository and structural: a *single dependency chain* in which each
result feeds the next, culminating in an incompleteness theorem that we take care to prove
**non-vacuous** by exhibiting an explicit consistent model. Many textbook treatments of
"abstract incompleteness" state a hypothesis — a fixed point equating truth with
unprovability — without certifying that any object satisfies it; if the hypothesis were
unsatisfiable, the theorem would be vacuously true and mathematically empty. We close that
gap.

### 1.1 Notation and conventions

We work in a classical propositional and higher-order setting. For propositions $p$, $q$
we write $\lnot p$ for negation, $p \iff q$ for logical equivalence, and $\to$ for
implication. For a type (collection) $A$, a *predicate* on $A$ is a function
$A \to \mathrm{Prop}$; we write $A \to B$ for the type of functions from $A$ to $B$. A
function $f$ is *surjective* if every element of its codomain is a value of $f$.

---

## 2. The Liar seed

**Definition 2.1 (Self-negating proposition).** A proposition $p$ is *self-negating* if
$p \iff \lnot p$.

**Theorem 2.2 (Liar).** No proposition is self-negating: $(p \iff \lnot p) \to \bot$.

*Proof.* Assume $h : p \iff \lnot p$. First, $\lnot p$: given $p$, the forward direction
of $h$ yields $\lnot p$, which applied to $p$ gives $\bot$; hence $p \to \bot$, i.e.
$\lnot p$. Now apply the backward direction of $h$ to $\lnot p$ to obtain $p$, and then
$\lnot p$ to $p$ to obtain $\bot$. $\qquad\blacksquare$

This three-line lemma is the seed of the entire chain: every subsequent contradiction is
ultimately an instance of Theorem 2.2.

---

## 3. The naive semantic strange loop is inconsistent

We first show that the *intuitive* notion of a fully self-referential truth system is
untenable. Fix a type $S$ of sentences, a truth predicate $\mathrm{True} : S \to
\mathrm{Prop}$, and a *diagonal operator* $\mathrm{diag} : (S \to \mathrm{Prop}) \to S$
intended to produce, for each property $P$ of sentences, a sentence $\mathrm{diag}(P)$
that "says $P$ of itself."

**Definition 3.1 (Total semantic diagonal).** The pair $(\mathrm{True}, \mathrm{diag})$ is
a *total semantic diagonal* if for every predicate $P : S \to \mathrm{Prop}$,
$$\mathrm{True}(\mathrm{diag}(P)) \iff P(\mathrm{diag}(P)).$$

**Theorem 3.2 (No total semantic diagonal).** No total semantic diagonal exists. Formally,
there is no $(\mathrm{True}, \mathrm{diag})$ with
$\forall P,\ \mathrm{True}(\mathrm{diag}(P)) \iff P(\mathrm{diag}(P))$.

*Proof.* Suppose such a pair exists. Instantiate the property at $P := (s \mapsto \lnot\,
\mathrm{True}(s))$. The defining equivalence gives, with $d := \mathrm{diag}(P)$,
$\mathrm{True}(d) \iff \lnot\,\mathrm{True}(d)$, a self-negating proposition, contradicting
Theorem 2.2. $\qquad\blacksquare$

**Corollary 3.3 (Soundness correction).** Any structure that *demands* a total semantic
diagonal is uninhabited; incompleteness "proved" from it would be vacuous. Genuine
incompleteness must therefore (a) diagonalize against a *syntactic* predicate weaker than
truth, and (b) require the fixed point only for a *single* predicate (unprovability),
never for all predicates at once. Sections 6–9 implement exactly this.

---

## 4. The abstract propositional core of Gödel

We now isolate the logical skeleton of incompleteness, with no arithmetic and no syntax —
just two propositions and a soundness assumption.

**Theorem 4.1 (Abstract incompleteness).** Let $P, T$ be propositions with
$T \iff \lnot P$ (truth equals unprovability) and $P \to T$ (soundness). Then $\lnot P$.

*Proof.* Assume $P$. By soundness $T$; by $T \iff \lnot P$ then $\lnot P$; applied to $P$
this gives $\bot$. Hence $\lnot P$. $\qquad\blacksquare$

**Theorem 4.2 (Truth of the Gödel sentence).** Under the hypotheses of Theorem 4.1, $T$
holds.

*Proof.* By Theorem 4.1, $\lnot P$; apply the backward direction of $T \iff \lnot P$.
$\qquad\blacksquare$

Here the interpretation is: $P$ = "the sentence is provable," $T$ = "the sentence is
true," and $T \iff \lnot P$ is the diagonal fixed point asserting "I am not provable." The
conclusion is the classical statement of Gödel I: the sentence is *true but unprovable*.
The key structural point, absent in the Liar, is that $T$ and $P$ are **distinct** — truth
and provability are two levels, and their permitted disagreement is precisely the room in
which incompleteness lives.

**Theorem 4.3 (Abstract undecidability).** Suppose in addition there is a negation sentence
with truth value $T_n$ satisfying $T_n \iff \lnot T$, together with its own soundness
$P_n \to T_n$ (where $P_n$ is provability of the negation). Then $\lnot P \wedge \lnot P_n$:
neither the sentence nor its negation is provable.

*Proof.* $\lnot P$ is Theorem 4.1. For $\lnot P_n$: assume $P_n$; soundness gives $T_n$;
$T_n \iff \lnot T$ gives $\lnot T$; but Theorem 4.2 gives $T$, contradiction.
$\qquad\blacksquare$

Notably, Theorem 4.3 uses only *soundness*, not $\omega$-consistency, to block both
directions.

---

## 5. Lawvere's fixed-point theorem: the categorical heart

All diagonal arguments share one abstract core, due to Lawvere.

**Theorem 5.1 (Lawvere fixed point).** Let $A$, $B$ be types and let
$\varphi : A \to (A \to B)$ be *point-surjective*: for every $f : A \to B$ there is $a$
with $\varphi(a) = f$. Then every self-map $g : B \to B$ has a fixed point: some $b$ with
$g(b) = b$.

*Proof.* Apply point-surjectivity to the function $f(a) := g(\varphi(a)(a))$, obtaining
$a_0$ with $\varphi(a_0) = f$. Evaluating at $a_0$: $\varphi(a_0)(a_0) = f(a_0) =
g(\varphi(a_0)(a_0))$. Thus $b := \varphi(a_0)(a_0)$ satisfies $g(b) = b$.
$\qquad\blacksquare$

The single self-application $\varphi(a)(a)$ is the diagonal; the choice of $g$ selects
which classical theorem we obtain.

### 5.1 Corollaries

**Corollary 5.2 (Cantor).** For any type $A$ there is no surjection
$f : A \to (A \to \mathrm{Prop})$.

*Proof.* If $f$ were surjective, Theorem 5.1 with $g := \lnot(\cdot)$ on $\mathrm{Prop}$
would yield a proposition $b$ with $\lnot b = b$, i.e. $b \iff \lnot b$, contradicting the
Liar (Theorem 2.2). $\qquad\blacksquare$

The predicate space $A \to \mathrm{Prop}$ is thus always strictly larger than $A$ — the
familiar statement that the powerset dominates the set.

**Corollary 5.3 (Tarski undefinability of truth).** If $\varphi : A \to (A \to
\mathrm{Prop})$ were surjective it would contradict Corollary 5.2; equivalently, for any
proposed truth coding there exists a predicate $Q$ with $\varphi(a) \neq Q$ for all $a$.
Hence truth is not definable within the system.

**Definition 5.4 (Trivial property).** A property $P$ of predicates is *trivial* if
$(\forall a,\ P(a)) \vee (\forall a,\ \lnot P(a))$ — it holds of all or of none.

**Corollary 5.5 (Rice, abstract form).** If predicates on $A$ were exhausted by a
surjection $\varphi$, then every property $P$ of predicates, transported along $\varphi$,
would be trivial. (This holds vacuously, since no such surjection exists by Corollary 5.2 —
which is itself the abstract reason nontrivial semantic properties of programs are
undecidable.)

---

## 6. A consistent, inhabited provability system

We now build the object that Corollary 3.3 demands: a system separating *syntactic
provability* from *truth*, carrying a genuine Gödel fixed point, and — crucially —
*provably consistent*.

**Definition 6.1 (Provability system).** A *provability system* consists of:

- a type $\mathrm{Sentence}$ of sentences;
- a predicate $\mathrm{Provable} : \mathrm{Sentence} \to \mathrm{Prop}$ (syntactic
  provability);
- a predicate $\mathrm{Holds} : \mathrm{Sentence} \to \mathrm{Prop}$ (truth in the
  intended model);
- **soundness**: $\forall s,\ \mathrm{Provable}(s) \to \mathrm{Holds}(s)$;
- a negation operation $\mathrm{neg} : \mathrm{Sentence} \to \mathrm{Sentence}$ with
  $\mathrm{Holds}(\mathrm{neg}\,s) \iff \lnot\,\mathrm{Holds}(s)$;
- a distinguished sentence $G$;
- the **diagonal fixed point** $\mathrm{Holds}(G) \iff \lnot\,\mathrm{Provable}(G)$.

Note the fixed point is required for the *single* predicate "unprovability of $G$," not for
all predicates — precisely the restriction Corollary 3.3 mandates.

**Theorem 6.2 (Non-vacuity).** A provability system exists.

*Proof.* Take $\mathrm{Sentence} := \{\text{true}, \text{false}\}$ (the Booleans),
$\mathrm{Provable}(s) := \bot$ for all $s$ (nothing is provable), $\mathrm{Holds}(b) :=
(b = \text{true})$, $\mathrm{neg} := $ Boolean negation, and $G := \text{true}$. Soundness
holds vacuously. Negation commutes with truth by case analysis. The fixed point reads
$\mathrm{Holds}(\text{true}) \iff \lnot \bot$, i.e. $\top \iff \top$. $\qquad\blacksquare$

Theorem 6.2 certifies that all results in this section are non-vacuous: they concern a
class of objects that provably has a member.

**Theorem 6.3 (First Incompleteness).** In any provability system, $G$ is true but
unprovable: $\mathrm{Holds}(G) \wedge \lnot\,\mathrm{Provable}(G)$.

*Proof.* Apply Theorems 4.1 and 4.2 with $P := \mathrm{Provable}(G)$, $T :=
\mathrm{Holds}(G)$, using the diagonal fixed point for $T \iff \lnot P$ and soundness at
$G$ for $P \to T$. $\qquad\blacksquare$

**Corollary 6.4 (Incompleteness).** There exists a true sentence that is not provable:
$\exists s,\ \mathrm{Holds}(s) \wedge \lnot\,\mathrm{Provable}(s)$. (Take $s := G$.)

**Corollary 6.5 (No completeness).** No provability system proves all its truths:
$\lnot\,\forall s,\ \mathrm{Holds}(s) \to \mathrm{Provable}(s)$.

*Proof.* If it did, applying it to the true sentence of Corollary 6.4 would prove that
sentence, contradicting its unprovability. $\qquad\blacksquare$

**Theorem 6.6 (Undecidability of $G$).** Neither $G$ nor $\mathrm{neg}\,G$ is provable:
$\lnot\,\mathrm{Provable}(G) \wedge \lnot\,\mathrm{Provable}(\mathrm{neg}\,G)$.

*Proof.* Apply Theorem 4.3 with the diagonal fixed point, soundness at $G$, the negation
law $\mathrm{Holds}(\mathrm{neg}\,G) \iff \lnot\,\mathrm{Holds}(G)$, and soundness at
$\mathrm{neg}\,G$. $\qquad\blacksquare$

---

## 7. A second-incompleteness / Löb-style corollary

**Theorem 7.1 (Consistency is unprovable).** Let a provability system contain a sentence
$\mathrm{Con}$ whose truth means exactly "$G$ is unprovable," i.e.
$\mathrm{Holds}(\mathrm{Con}) \iff \lnot\,\mathrm{Provable}(G)$, and suppose the formalized
*derivability condition* $\mathrm{Provable}(\mathrm{Con}) \to \mathrm{Provable}(G)$ holds.
Then $\mathrm{Con}$ is not provable: $\lnot\,\mathrm{Provable}(\mathrm{Con})$.

*Proof.* Assume $\mathrm{Provable}(\mathrm{Con})$. By soundness, $\mathrm{Holds}(\mathrm{Con})$,
so $\lnot\,\mathrm{Provable}(G)$. But the derivability condition gives
$\mathrm{Provable}(G)$, a contradiction. $\qquad\blacksquare$

This is the essential content of Gödel's Second Incompleteness Theorem in this setting: a
sound system cannot prove its own consistency. The derivability condition
$\mathrm{Provable}(\mathrm{Con}) \to \mathrm{Provable}(G)$ isolates the single Hilbert–
Bernays–Löb ingredient needed, connecting to the modal analysis of provability (Löb's
theorem, and the modal logic **GL**).

---

## 8. The provability lattice

Incompleteness can also be viewed order-theoretically. Model a *theory* as an element of a
complete lattice $\alpha$ (ordered by "extends"), and model "close under one round of
inference" as a monotone operator $f : \alpha \to \alpha$. The deductively closed theories
are exactly the fixed points of $f$.

**Theorem 8.1 (Existence of fixed points; Knaster–Tarski).** Every monotone
$f : \alpha \to \alpha$ on a complete lattice has a fixed point: $\exists x,\ f(x) = x$.
In particular there is a least fixed point $\mathrm{lfp}(f)$ and a greatest fixed point
$\mathrm{gfp}(f)$.

*Proof.* $\mathrm{lfp}(f)$ is the infimum of all pre-fixed points $\{a : f(a) \le a\}$;
monotonicity shows it is fixed. Dually for $\mathrm{gfp}(f)$. $\qquad\blacksquare$

Interpretively, $\mathrm{lfp}(f)$ is the minimal deductively closed theory containing the
axioms (the "provable core"), and $\mathrm{gfp}(f)$ is the maximal consistent extension.
Both are strange loops living in the space of theories.

**Lemma 8.2 (Least fixed point is minimal).** For any pre-fixed point $a$ (i.e.
$f(a) \le a$), $\mathrm{lfp}(f) \le a$.

**Theorem 8.3 (Gap forces incompleteness).** If $\mathrm{lfp}(f) \neq \mathrm{gfp}(f)$,
then $\mathrm{lfp}(f) < \mathrm{gfp}(f)$.

*Proof.* Always $\mathrm{lfp}(f) \le \mathrm{gfp}(f)$; combine with $\neq$.
$\qquad\blacksquare$

The strict inequality means there are sentences present in the maximal consistent
extension but absent from the provable core — true-but-unprovable statements, now
manifest not as a single clever sentence but as the *width of a gap* in the lattice.

---

## 9. Algorithms

The results above are largely non-constructive existence and impossibility statements, but
several have direct algorithmic shadows. We record three.

**Algorithm A (Diagonal-sentence construction).** Given a mechanism $\varphi$ that codes
functions and a self-map $g$, produce Lawvere's fixed point $b = \varphi(a_0)(a_0)$ where
$a_0$ codes $a \mapsto g(\varphi(a)(a))$. In symbolic-logic terms, this is the *diagonal
lemma*: given a formula $\psi(x)$ with one free variable, output a sentence $\sigma$ with
$\sigma \iff \psi(\ulcorner\sigma\urcorner)$.

**Algorithm B (Fixed-point iteration on a finite lattice).** For a monotone $f$ on a finite
complete lattice, compute $\mathrm{lfp}(f)$ by iterating $\bot, f(\bot), f^2(\bot), \dots$
until stabilization (guaranteed by monotonicity and finiteness), and dually $\mathrm{gfp}(f)$
from $\top$. Then test $\mathrm{lfp}(f) = \mathrm{gfp}(f)$; inequality certifies a gap.

**Algorithm C (Liar detector).** Given a finite propositional model of a self-referential
specification, detect whether it forces some $p \iff \lnot p$ (hence inconsistency) by
searching for a variable equated to its own negation under the specification's constraints.

Complexities: Algorithm A is a single application step (constant, modulo the coding
machinery). Algorithm B on a lattice of height $h$ terminates in at most $h$ iterations,
each an application of $f$. Algorithm C is linear in the size of the dependency graph of
the specification.

---

## 10. Applications

- **Foundations of mathematics.** No sound, sufficiently expressive theory is complete
  (Corollary 6.5), and no such theory proves its own consistency (Theorem 7.1). Certainty
  about a system requires a strictly stronger metasystem, ad infinitum.
- **Computability.** Rice's theorem (Corollary 5.5) explains why nontrivial semantic
  properties of programs are undecidable; the halting problem is the same diagonal with $g$
  = "loop iff halts."
- **Semantics of languages.** Tarski's theorem (Corollary 5.3) shows a language cannot
  contain its own truth predicate, motivating hierarchies of metalanguages.
- **Program logic and verification.** Fixed-point semantics (Theorem 8.1) underlies the
  denotational meaning of recursion and the least/greatest fixed points of inductive and
  coinductive definitions.
- **Cognitive science (speculative).** Hofstadter's thesis that selfhood is a tangled
  self-referential fixed point suggests modeling cognition as multi-level provability
  systems with cross-level reference.

---

## 11. Discussion

The unifying moral is that **self-reference is survivable only when tangled across levels
that may disagree.** Loop truth onto truth and you get the Liar (Theorem 3.2) — outright
inconsistency. Loop truth onto provability, a strictly weaker syntactic surrogate, and the
loop closes at an angle, leaving a true-but-unprovable residue (Theorem 6.3) rather than a
contradiction. Lawvere's theorem (Theorem 5.1) explains why the *same* diagonal produces a
paradox for some target maps ($g = \lnot$) and a benign fixed point for others: the
outcome depends entirely on whether the self-map has a fixed point in the target.

Our insistence on non-vacuity (Theorem 6.2) is methodologically central. Abstract
incompleteness theorems phrased as "if a fixed point exists, then …" are only as meaningful
as the class of models satisfying the hypothesis. By exhibiting an explicit consistent
provability system, we guarantee the theorems of Sections 6–7 are about something real.

---

## 12. Future directions

1. **From semantic truth to genuine syntactic diagonalization.** The provability system
   *supplies* the Gödel fixed point as data. The next step is to *construct* it: arithmetize
   syntax (Gödel numbering), build a representable provability predicate, and prove the
   diagonal lemma, so that $G$ and its fixed point are derived rather than assumed.
2. **Löb's theorem and provability logic (GL).** Theorem 7.1 isolates the single
   derivability condition for a second-incompleteness corollary. A full treatment would
   formalize the three Hilbert–Bernays–Löb conditions and prove Löb's theorem
   $\Box(\Box A \to A) \to \Box A$, connecting to the modal logic GL.
3. **$\omega$-consistency vs. simple consistency.** Theorem 6.6 obtains undecidability from
   soundness. Rosser's trick weakens this to simple consistency; formalizing Rosser
   sentences would strengthen the undecidability result.
4. **Quantitative / probabilistic strange loops.** Study randomized provability operators on
   the theory lattice and the distribution of fixed points, or Chaitin's $\Omega$
   (algorithmic randomness) as an incompleteness phenomenon — the measure-theoretic face of
   self-reference. The lattice gap (Theorem 8.3) already frames incompleteness as a strict
   order gap that a quantitative theory could measure.
5. **Tangled hierarchies and consciousness.** Formalize multi-level provability systems with
   cross-level provability and study when the hierarchy collapses to a single
   self-referential fixed point.

---

## References

1. F. W. Lawvere. *Diagonal arguments and cartesian closed categories.* Lecture Notes in
   Mathematics 92 (1969), 134–145.
2. K. Gödel. *Über formal unentscheidbare Sätze der Principia Mathematica und verwandter
   Systeme I.* Monatshefte für Mathematik und Physik 38 (1931), 173–198.
3. A. Tarski. *Der Wahrheitsbegriff in den formalisierten Sprachen.* Studia Philosophica 1
   (1936).
4. H. G. Rice. *Classes of recursively enumerable sets and their decision problems.*
   Transactions of the AMS 74 (1953), 358–366.
5. M. H. Löb. *Solution of a problem of Leon Henkin.* Journal of Symbolic Logic 20 (1955),
   115–118.
6. B. Knaster, A. Tarski. *A lattice-theoretical fixpoint theorem and its applications.*
   Pacific J. Math. 5 (1955), 285–309.
7. D. Hofstadter. *Gödel, Escher, Bach: An Eternal Golden Braid.* Basic Books, 1979.
