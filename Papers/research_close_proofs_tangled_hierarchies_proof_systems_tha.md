# Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

## Abstract

We develop the order-free semantic core of self-reference and use it to prove
that *tangled hierarchies* — formal systems containing a predicate that describes
their own truth or soundness — are unavoidable in exactly the following sense: no
consistent, two-valued, self-referential system can contain an internal soundness
predicate obeying the disquotation schema. Starting from a single logical seed —
no proposition is equivalent to its own negation — we obtain, in a strictly
layered chain, the nonexistence of Liar sentences, the impossibility of
unrestricted semantic fixed points, Tarski's undefinability of truth, a
soundness-driven proof of Gödelian incompleteness, and finally a capstone
theorem showing that an internal soundness predicate cannot consistently live
inside the system it validates. We isolate the precise culprit by exhibiting a
consistent model satisfying every hypothesis of the impossibility theorem *except*
disquotation, thereby proving the impossibility is caused specifically by the
internalization of soundness. All notions are elementary and every construction
is exhibited by an explicit inhabiting model, so no result is vacuous.

**Keywords.** self-reference, strange loop, Liar paradox, Tarski undefinability,
Gödel incompleteness, soundness predicate, diagonal lemma, fixed points.

---

## 1. Introduction

A *tangled hierarchy*, in Hofstadter's phrase a "strange loop," arises whenever a
formal system contains within itself a predicate describing its own semantic
status — its truth, or its soundness. Such loops are the common ancestor of the
Liar paradox, Russell's paradox, Cantor's diagonal argument, Gödel's
incompleteness theorems, Tarski's undefinability of truth, and Turing's halting
problem. The folklore intuition is that all of these are "the same theorem." This
paper makes one strand of that intuition fully precise and self-contained: we
extract the minimal semantic hypotheses under which self-reference becomes
inconsistent, and we prove that the fatal ingredient is precisely an *internal
soundness predicate*.

Our development is deliberately semantic rather than syntactic. We do not fix a
particular formal language, an arithmetization, or a proof calculus. Instead we
work with abstract structures carrying a truth predicate, an internal negation,
and — where needed — internal provability and provability predicates. This
economy has two virtues. First, the proofs reduce to a handful of one-line
manipulations of a single core lemma, exposing the logical skeleton shared by all
the classical paradoxes. Second, because the hypotheses are abstract, the results
apply to any concrete system that instantiates them; we verify non-vacuity by
exhibiting explicit models.

The paper is organized as a single dependency chain. Section 2 states the logical
seed. Section 3 introduces languages and rules out the Liar. Section 4 proves
that unrestricted semantic self-reference is impossible. Section 5 proves
Tarski's undefinability theorem and pins the blame on disquotation via an
explicit consistent counter-model. Section 6 introduces proof systems with
internal provability and derives incompleteness from soundness. Section 7 states
the capstone: soundness cannot be internal. Sections 8–10 discuss algorithms,
applications, and future directions.

---

## 2. The logical seed

Everything rests on a single fact about classical propositional logic.

**Lemma 2.1 (No self-negation).** For every proposition $P$,
$$\neg\,(P \leftrightarrow \neg P).$$

*Proof.* Suppose $P \leftrightarrow \neg P$. If $P$ holds, the equivalence gives
$\neg P$, contradiction; hence $\neg P$. But then the equivalence gives $P$, again
a contradiction. So the assumed equivalence is impossible. $\qquad\blacksquare$

Lemma 2.1 uses nothing but the meaning of implication and negation. Every
impossibility below is an instance of it, reached by unfolding definitions until
the goal literally becomes "$X \leftrightarrow \neg X$."

---

## 3. Languages and the Liar

**Definition 3.1 (Language).** A *language* consists of:

- a type $\mathrm{Sent}$ of *sentences*;
- a predicate $\mathrm{Truth} : \mathrm{Sent} \to \mathrm{Prop}$, the external
  (meta-level) semantics specifying which sentences are true;
- an operation $\mathrm{neg} : \mathrm{Sent} \to \mathrm{Sent}$, an internal
  *negation*;

subject to the single axiom of **honest negation**:
$$\forall s,\quad \mathrm{Truth}(\mathrm{neg}\,s) \leftrightarrow \neg\,\mathrm{Truth}(s).$$

The axiom makes the semantics two-valued in the relevant sense: negating a
sentence flips its truth value, with no gaps (a sentence and its negation both
false) or gluts (both true).

**Theorem 3.2 (No local Liar).** For every sentence $s$ of a language,
$$\neg\,\big(\mathrm{Truth}(s) \leftrightarrow \mathrm{Truth}(\mathrm{neg}\,s)\big).$$

*Proof.* By honest negation, $\mathrm{Truth}(\mathrm{neg}\,s)$ is equivalent to
$\neg\,\mathrm{Truth}(s)$. Substituting, the claim becomes
$\neg\,(\mathrm{Truth}(s) \leftrightarrow \neg\,\mathrm{Truth}(s))$, which is
Lemma 2.1 with $P = \mathrm{Truth}(s)$. $\qquad\blacksquare$

**Theorem 3.3 (No Liar sentence).** No language contains a sentence $d$ with
$$\mathrm{Truth}(d) \leftrightarrow \mathrm{Truth}(\mathrm{neg}\,d).$$

*Proof.* Such a $d$ would immediately contradict Theorem 3.2 applied to
$s = d$. $\qquad\blacksquare$

The classical Liar sentence — "this sentence is false" — is exactly a fixed point
of $\mathrm{neg}$ at the level of truth. Theorem 3.3 states that a two-valued
semantics with honest negation simply cannot host one.

---

## 4. The impossibility of unrestricted self-reference

Self-reference in full generality is a *diagonal* or *fixed-point* principle: for
every transformation $f$ of sentences there is a sentence that asserts $f$ of
itself. Formally, a language *has full semantic self-reference* if
$$\forall f : \mathrm{Sent} \to \mathrm{Sent},\ \exists d,\quad \mathrm{Truth}(d) \leftrightarrow \mathrm{Truth}(f(d)).$$
This is the semantic form of the diagonal lemma that underlies Gödel's
construction and the recursion theorem.

**Theorem 4.1 (No universal semantic fixed points).** No language has full
semantic self-reference.

*Proof.* If it did, instantiate $f := \mathrm{neg}$. This yields a sentence $d$
with $\mathrm{Truth}(d) \leftrightarrow \mathrm{Truth}(\mathrm{neg}\,d)$ — a Liar
sentence, contradicting Theorem 3.3. $\qquad\blacksquare$

Theorem 4.1 delimits the strange loop sharply: individual fixed points may exist,
but a *uniform* fixed-point operator covering every function — including negation
— is inconsistent with a two-valued semantics. Unrestricted tangling collapses.

---

## 5. Tarski undefinability: soundness is not internal

We now allow the language a candidate *internal truth predicate*, equivalently an
internal *soundness reflection*: an operation $T$ such that asserting "$T$ of $s$"
means exactly "$s$ is true." Honesty of this predicate is the **disquotation
schema**
$$\forall s,\quad \mathrm{Truth}(T(s)) \leftrightarrow \mathrm{Truth}(s).$$

A genuinely self-referential system also supplies a **diagonal instance**: a
sentence $L$ that asserts its own $\neg T$, i.e.
$$\mathrm{Truth}(L) \leftrightarrow \mathrm{Truth}(\mathrm{neg}(T(L))).$$

**Theorem 5.1 (Undefinability of truth/soundness).** There is no structure
carrying a truth predicate $\mathrm{Truth}$, an internal negation $\mathrm{neg}$,
and an internal predicate $T$ such that all three of the following hold:

1. honest negation: $\forall s,\ \mathrm{Truth}(\mathrm{neg}\,s) \leftrightarrow \neg\,\mathrm{Truth}(s)$;
2. disquotation: $\forall s,\ \mathrm{Truth}(T(s)) \leftrightarrow \mathrm{Truth}(s)$;
3. the diagonal instance: $\exists L,\ \mathrm{Truth}(L) \leftrightarrow \mathrm{Truth}(\mathrm{neg}(T(L)))$.

*Proof.* Let $L$ be the diagonal sentence from (3). By honest negation applied to
$T(L)$, $\mathrm{Truth}(\mathrm{neg}(T(L)))$ equals $\neg\,\mathrm{Truth}(T(L))$;
by disquotation, $\mathrm{Truth}(T(L))$ equals $\mathrm{Truth}(L)$. Substituting
into (3) yields $\mathrm{Truth}(L) \leftrightarrow \neg\,\mathrm{Truth}(L)$,
contradicting Lemma 2.1. $\qquad\blacksquare$

This is Tarski's undefinability theorem in its essential form: a two-valued,
self-referential language cannot contain its own truth predicate.

The most important methodological point is *which* hypothesis fails. A priori the
three conditions might be jointly unsatisfiable for a trivial reason, in which
case the theorem would be vacuous and would not locate the source of the
pathology. We rule this out.

**Theorem 5.2 (The disquotation schema is the sole culprit).** There exists a
structure satisfying hypotheses (1) and (3) of Theorem 5.1 — honest negation and
the diagonal instance — while failing only (2). Consequently the impossibility in
Theorem 5.1 is caused specifically by internalizing soundness, not by an
unsatisfiable side condition.

*Proof.* Take $\mathrm{Sent} = \mathrm{Bool}$, $\mathrm{Truth}(b) := (b =
\mathtt{true})$, $\mathrm{neg} := \lnot$ (boolean flip), and $T(b) :=
\mathtt{false}$ (the constant predicate). Honest negation holds by case analysis
on $b$. The diagonal instance holds at $L := \mathtt{true}$: both sides evaluate
to falsity of the appropriate booleans, giving a valid equivalence. Disquotation
fails, since $\mathrm{Truth}(T(\mathtt{true}))$ is false while
$\mathrm{Truth}(\mathtt{true})$ is true. $\qquad\blacksquare$

Together, Theorems 5.1 and 5.2 make the conclusion surgical: an internal
soundness predicate obeying disquotation is exactly the ingredient that turns an
otherwise consistent self-referential system inconsistent.

---

## 6. Proof systems and incompleteness

We now separate *truth* from *provability*, the extra degree of freedom that
distinguishes Gödel's setting from Tarski's.

**Definition 6.1 (Proof system).** A *proof system* consists of:

- a type $\mathrm{Sent}$ of sentences;
- an external truth predicate $\mathrm{Truth} : \mathrm{Sent} \to \mathrm{Prop}$;
- an internal derivability predicate $\mathrm{Prov} : \mathrm{Sent} \to \mathrm{Prop}$;
- an internal negation $\mathrm{neg} : \mathrm{Sent} \to \mathrm{Sent}$;
- an internal *provability predicate* $\mathrm{box} : \mathrm{Sent} \to \mathrm{Sent}$, where $\mathrm{box}\,s$ is the sentence "$s$ is provable";

subject to:

- **honest negation:** $\forall s,\ \mathrm{Truth}(\mathrm{neg}\,s) \leftrightarrow \neg\,\mathrm{Truth}(s)$;
- **representability of provability:** $\forall s,\ \mathrm{Truth}(\mathrm{box}\,s) \leftrightarrow \mathrm{Prov}(s)$;
- **soundness:** $\forall s,\ \mathrm{Prov}(s) \to \mathrm{Truth}(s)$;
- **Gödel fixed point:** $\exists G,\ \mathrm{Truth}(G) \leftrightarrow \neg\,\mathrm{Prov}(G)$.

The Gödel fixed point $G$ is a sentence that is true exactly when it is not
provable — the abstract form of "I am not provable."

**Proposition 6.2 (Non-vacuity).** Proof systems exist.

*Proof.* Take $\mathrm{Sent} := \mathrm{Prop}$, $\mathrm{Truth} :=
\mathrm{id}$, $\mathrm{Prov}(s) := \mathrm{False}$ (nothing is provable),
$\mathrm{neg} := \neg$, $\mathrm{box}\,s := \mathrm{False}$. Honest negation and
representability hold by reflexivity; soundness holds vacuously since
$\mathrm{Prov}$ is always false; the Gödel fixed point is witnessed by $G :=
\mathrm{True}$, for which $\mathrm{Truth}(G)$ holds and $\neg\,\mathrm{Prov}(G)$
holds. $\qquad\blacksquare$

**Theorem 6.3 (The Gödel sentence is true but unprovable).** In every proof
system there is a sentence $G$ with $\mathrm{Truth}(G)$ and
$\neg\,\mathrm{Prov}(G)$.

*Proof.* Let $G$ be the Gödel fixed point, so $\mathrm{Truth}(G) \leftrightarrow
\neg\,\mathrm{Prov}(G)$. Suppose, for contradiction, $\mathrm{Prov}(G)$. By
soundness, $\mathrm{Truth}(G)$; by the fixed-point equivalence (forward
direction), $\neg\,\mathrm{Prov}(G)$ — contradicting the assumption. Hence
$\neg\,\mathrm{Prov}(G)$. The fixed-point equivalence (backward direction) then
gives $\mathrm{Truth}(G)$. $\qquad\blacksquare$

**Theorem 6.4 (Incompleteness).** No proof system is complete: it is not the case
that every true sentence is provable.

*Proof.* If every true sentence were provable, then applying this to the sentence
$G$ of Theorem 6.3, whose truth we established, would yield $\mathrm{Prov}(G)$,
contradicting $\neg\,\mathrm{Prov}(G)$. $\qquad\blacksquare$

Soundness plays the decisive role: it is soundness that forces $G$ true once $G$
is seen to be unprovable, thereby exhibiting a true-but-unprovable sentence and
the incompleteness gap.

---

## 7. Capstone: the tangle is unavoidable

We can finally state the result in the concrete language of proof systems.

**Theorem 7.1 (Soundness cannot be internal).** Let $P$ be a proof system.
Suppose $P$ additionally carries an internal soundness predicate $T :
\mathrm{Sent} \to \mathrm{Sent}$ satisfying the disquotation schema
$$\forall s,\quad \mathrm{Truth}(T(s)) \leftrightarrow \mathrm{Truth}(s),$$
and suppose $P$ supplies the diagonal instance
$$\exists L,\quad \mathrm{Truth}(L) \leftrightarrow \mathrm{Truth}(\mathrm{neg}(T(L))).$$
Then $P$ is inconsistent (a contradiction follows).

*Proof.* This is exactly Theorem 5.1 instantiated with the truth predicate,
negation, and honest-negation axiom of $P$. The disquotation schema for $T$ and
the diagonal instance supply the remaining hypotheses; the conclusion is a
contradiction. $\qquad\blacksquare$

**Interpretation.** A proof system may freely reason *about proofs* and may even
carry a provability predicate $\mathrm{box}$ (Definition 6.1) internalizing the
statement "$s$ is provable." What it cannot do — on pain of inconsistency — is
carry an internal *soundness/truth* predicate obeying disquotation while
remaining self-referential. The certificate of the system's own soundness must be
issued from *outside* the system. Since any such external certifier is itself a
system subject to the same theorem, one obtains an unbounded tower of
metasystems, each vouching only for those below it: the tangled hierarchy is not
resolved but stratified into an infinite ascending sequence.

---

## 8. Algorithms

Although the results are semantic impossibilities, their finite models and the
diagonal machinery admit direct computational illustration. We describe three.

**8.1 Liar-collapse detector.** Given a finite two-valued semantics presented as
a truth assignment on a finite sentence set together with a negation map, decide
whether any sentence is a fixed point of negation at the truth level (a Liar).
Theorem 3.3 guarantees the answer is always "none" whenever the negation map is
honest; the algorithm doubles as a consistency check on the honesty axiom.

**8.2 Diagonal fixed-point search.** Given a finite sentence set, a truth
assignment, and an arbitrary self-map $f$, search for a semantic fixed point
$\mathrm{Truth}(d) \leftrightarrow \mathrm{Truth}(f(d))$. Running the search with
$f = \mathrm{neg}$ empirically reproduces Theorem 4.1: no fixed point is found
when negation is honest.

**8.3 Gödel-sentence evaluator.** Given a finite proof system (a truth
assignment, a provability set, and a designated fixed-point sentence $G$ with
$\mathrm{Truth}(G) \leftrightarrow \neg\,\mathrm{Prov}(G)$ and soundness),
compute the truth and provability status of $G$ and confirm it is true and
unprovable, reproducing Theorems 6.3–6.4 on concrete finite data.

---

## 9. Applications

**Foundations of mathematics.** Theorem 7.1 is the abstract reason a sufficiently
expressive theory cannot contain its own truth predicate, and (in the provability
refinement) cannot prove all its truths. Consistency and soundness statements
must be verified from a strictly stronger vantage point.

**Program verification.** A verifier is a system deciding correctness claims about
programs. The capstone theorem says no verifier expressive enough to be
self-referential can contain a complete, honest internal certificate of its own
soundness. Practical trust must be anchored in an external, simpler, separately
trusted core — the standard "small trusted kernel" architecture.

**Reflective agents.** Any agent whose internal language can represent its own
truth standard and can self-refer confronts the Liar. Complete and consistent
self-certification of reliability is impossible; an agent can only bound its
self-trust by appeal to an external or higher-order standard.

**Semantics of natural language.** The Liar and its kin are not defects of
particular sentences but structural consequences of combining two-valued truth,
internal negation, and self-reference — motivating truth-value gaps, contextual
hierarchies, and paracomplete logics.

---

## 10. Discussion and future work

Our treatment isolates the logical seed $\neg(P \leftrightarrow \neg P)$ as the
single source of every impossibility in the chain, and identifies the
disquotational internal soundness predicate as the precise ingredient whose
addition tips a consistent self-referential system into contradiction. The
consistent counter-model of Theorem 5.2 is what makes this attribution rigorous
rather than merely suggestive.

Several extensions suggest themselves.

1. **Full syntactic Löb's theorem.** Replace the semantic Gödel fixed point with
   the Hilbert–Bernays–Löb derivability conditions
   ($\mathrm{D1}: \mathrm{Prov}\,s \to \mathrm{Prov}(\mathrm{box}\,s)$;
   $\mathrm{D2}$: distribution of $\mathrm{box}$ over implication;
   $\mathrm{D3}: \mathrm{Prov}(\mathrm{box}\,s) \to \mathrm{Prov}(\mathrm{box}(\mathrm{box}\,s))$)
   and a syntactic diagonal, then derive
   $\mathrm{Prov}(\mathrm{box}\,s \to s) \to \mathrm{Prov}(s)$. This is the
   sharpest form of "a system cannot safely reference its own soundness."

2. **Second incompleteness.** From Löb with $s = \bot$, conclude that a consistent
   system cannot prove its own consistency sentence
   $\mathrm{Con} := \mathrm{neg}(\mathrm{box}\,\bot)$.

3. **Ordinal-indexed reflection towers.** Iterate the addition of a soundness
   reflection principle $\mathrm{RFN}(P)$ and study the transfinite hierarchy
   $P_0 \subset P_1 \subset \cdots$, showing each level proves the consistency of
   the previous — the stratified escape from the tangle.

4. **Kripke/paracomplete semantics.** Weaken honest negation to a three-valued or
   fixed-point (Kripke) semantics, where the Liar receives a truth-value gap, and
   measure exactly which theorems survive. This isolates classicality as the
   ingredient forcing the tangle's inconsistency.

5. **Category-theoretic bridge.** Recast Theorems 4.1 and 5.1 via Lawvere's
   fixed-point theorem, unifying them with Cantor's theorem and the
   $\mathrm{Type} : \mathrm{Type}$ collapse.

---

## 11. Conclusion

From one line of logic we have reconstructed the entire architecture of
self-reference: no Liar, no universal fixed point, no internal truth predicate, no
complete sound proof system, and — the capstone — no internal soundness predicate
in any self-referential system. The strange loop cannot be tied; it can only be
climbed. Because self-certification is impossible, mathematics, computation, and
reflective reasoning are organized into open-ended hierarchies of ever-stronger
vantage points, each seeing truths the last could not, and none able to vouch for
itself.
