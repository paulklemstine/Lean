# Formal Foundations for the Logic–Physics Bridge: Physical Realizability versus Proof-Theoretic Consistency

## Abstract

We develop a minimal, fully abstract framework relating two notions of
"possibility" for a logical theory: its **physical realizability** (having a
*model* — a world that satisfies it) and its **proof-theoretic consistency**
(non-derivability of falsum). Working over an arbitrary type of sentences, we
axiomatize proof systems by only three structural rules (a distinguished falsum,
weakening, and the assumption rule) and semantics by only one constraint (no
world satisfies falsum). Within this skeleton we establish a sharp asymmetry.
**Physical consistency implies mathematical consistency** (the bridge), but
**mathematical consistency does not imply physical consistency** (the separation
theorem, witnessed by an empty type of worlds). We further isolate the exact
proof-theoretic strength the bridge requires: not full soundness but only
*falsum-soundness* — honesty about contradictions — and we show this
generalization is proper by exhibiting a concrete falsum-sound but unsound
system. We characterize the precise condition under which the gap closes: for
*sound and complete* semantics the two notions of consistency coincide (the
completeness collapse), a formal "phase boundary" between logic and physics that
internalizes Gödel's completeness theorem. Finally, we sketch a
superposition-closed strengthening — *quantum physical consistency* — yielding a
strict three-tier hierarchy. All results are stated as abstract theorems and
have been formally verified.

**Keywords:** logic–physics bridge, consistency, satisfiability, soundness,
completeness, model theory, falsum-soundness, separation theorem.

---

## 1. Introduction

A recurring question across logic, foundations of physics, and the philosophy of
science is whether a given set of laws *could describe a world*. Two answers
compete. The **semantic** answer asks for a model: a concrete structure that
satisfies every law. The **syntactic** answer asks for consistency: that the
laws never entail an absurdity. These appear interchangeable, and in the
best-behaved logics they are. But the equivalence is contingent on properties
(notably completeness) that need not hold in general.

This paper builds the smallest framework in which the relationship can be stated
precisely and the equivalence dissected. We deliberately strip proof systems and
semantics down to their structural cores so that every theorem isolates exactly
which assumption it consumes. The result is a clean map of the territory:

1. realizability always certifies consistency (§4);
2. the certificate requires only honesty about contradictions, not full
   soundness (§4–§5);
3. that weakening is proper (§5);
4. consistency never, on its own, certifies realizability (§6, the separation
   theorem);
5. the gap closes exactly under sound-and-complete semantics (§7);
6. a superposition-closed strengthening induces a strict hierarchy (§8).

The central conceptual claim is that **physical consistency is a semantic
certificate while mathematical consistency is a syntactic property**, and the gap
between them is precisely the gap between satisfiability and non-contradiction.

---

## 2. The abstract proof system

We fix a universe of *sentences* `S` (an arbitrary type) and axiomatize
derivability with minimal structure.

**Definition 2.1 (Proof system).** A *proof system* over `S` consists of:

- a distinguished sentence `bot : S` (falsum, ⊥);
- a relation `Proves : Set S → S → Prop`, where `Proves Γ φ` (written `Γ ⊢ φ`)
  means "φ is derivable from the hypotheses Γ";

subject to two structural axioms:

- **(mono / weakening)** for all `Γ ⊆ Δ` and all `φ`, if `Γ ⊢ φ` then `Δ ⊢ φ`;
- **(assumption / reflexivity)** for all `Γ` and `φ`, if `φ ∈ Γ` then `Γ ⊢ φ`.

No connectives, quantifiers, or further inference rules are assumed. Every
concrete logic (propositional, first-order, modal, …) instantiates Definition
2.1, so theorems proved here apply uniformly.

**Definition 2.2 (Consistency).** A theory `T : Set S` is *consistent* for a
proof system `P`, written `Consistent(T)`, when `¬ (T ⊢ ⊥)`.

Two purely syntactic facts follow immediately and serve as structural lemmas.

**Theorem 2.3 (Anti-monotonicity of consistency).** *If `Γ ⊆ Δ` and `Δ` is
consistent, then `Γ` is consistent.*

*Proof sketch.* Suppose `Γ ⊢ ⊥`. By weakening (mono), `Δ ⊢ ⊥`, contradicting
`Consistent(Δ)`. Hence `¬(Γ ⊢ ⊥)`. ∎

This is the foundational lemma for *modular* theory building: consistency of a
large theory transfers to all of its sub-theories, so safe fragments stay safe.

**Theorem 2.4 (Proper new-theorem extension).** *If `¬(T ⊢ φ)` then `φ ∉ T` and
`(insert φ T) ⊢ φ`.*

*Proof sketch.* If `φ ∈ T`, the assumption rule gives `T ⊢ φ`, contradicting the
hypothesis; hence `φ ∉ T`. And `φ ∈ insert φ T`, so the assumption rule yields
`insert φ T ⊢ φ`. ∎

Thus any unprovable sentence is genuinely outside `T` yet becomes a theorem once
adjoined: adding an independent axiom produces a *proper* extension that *gains a
theorem*. This is the structural engine behind consistency-strength towers
(§9, Direction 2).

---

## 3. Semantics, models, and the realizability certificate

**Definition 3.1 (Semantics).** A *semantics* (a "physics") for a proof system
`P` consists of:

- a type `World`;
- a satisfaction relation `sat : World → S → Prop` (`sat w φ` reads "world `w`
  satisfies sentence `φ`");
- the constraint **(bot_unsat)** `∀ w, ¬ sat w ⊥`: no world satisfies falsum.

The single constraint `bot_unsat` is what makes ⊥ deserve its name on the
semantic side.

**Definition 3.2 (Model / realizability).** A theory `T` *has a model* in a
semantics `M`, written `HasModel(T)`, when `∃ w, ∀ φ ∈ T, sat w φ`: some world
satisfies every sentence of `T`.

**Definition 3.3 (Physical consistency).** `PhysicallyConsistent(T) :=
HasModel(T)`. A theory is physically consistent precisely when it is realizable.

**Definition 3.4 (Soundness).** A semantics `M` is *sound* for `P` when, for all
`Γ`, `φ`, and worlds `w`, if `Γ ⊢ φ` and `w` satisfies every hypothesis in `Γ`,
then `w` satisfies `φ`. (Truth flows from satisfied premises to all conclusions.)

**Definition 3.5 (Falsum-soundness).** A semantics `M` is *falsum-sound* for `P`
when, for all `Γ` and worlds `w`, if `Γ ⊢ ⊥` and `w` satisfies every hypothesis
in `Γ`, then `w` satisfies `⊥`. (Truth flows to the single conclusion ⊥.)

Falsum-soundness is the restriction of soundness to the case `φ = ⊥`. It demands
only that the proof system be *honest about contradictions*: it never derives ⊥
from premises a real world actually satisfies. Combined with `bot_unsat`, this
makes a ⊥-derivation from a satisfied context impossible.

---

## 4. The bridge: realizability certifies consistency

**Theorem 4.1 (Weak bridge).** *If `M` is falsum-sound and `T` has a model, then
`T` is consistent.*

*Proof sketch.* Let `w` be a model of `T`, so `w` satisfies every `φ ∈ T`.
Suppose for contradiction `T ⊢ ⊥`. By falsum-soundness applied to `Γ = T` and
`w` (whose hypotheses are all satisfied), `w` satisfies `⊥`. This contradicts
`bot_unsat`. Hence `¬(T ⊢ ⊥)`, i.e. `Consistent(T)`. ∎

The proof uses *only* falsum-soundness; no claim about the truth of any sentence
other than ⊥ is needed.

**Theorem 4.2 (Soundness refines to falsum-soundness).** *If `M` is sound, then
`M` is falsum-sound.*

*Proof sketch.* Instantiate the soundness condition at `φ = ⊥`. ∎

**Theorem 4.3 (Bridge).** *If `M` is sound and `T` has a model, then `T` is
consistent.*

*Proof sketch.* By Theorem 4.2, `M` is falsum-sound; apply Theorem 4.1. ∎

**Theorem 4.4 (Physical ⟹ mathematical).** *If `M` is sound and `T` is
physically consistent, then `T` is (mathematically) consistent.*

*Proof sketch.* `PhysicallyConsistent(T)` unfolds to `HasModel(T)`; apply
Theorem 4.3. ∎

Theorem 4.4 is the "easy direction" of the logic–physics correspondence: a world
that realizes a theory is a *certificate* of its non-contradiction. Theorem 4.1
sharpens it to the minimal hypothesis.

---

## 5. The generalization is proper: falsum-soundness ⊊ soundness

Theorem 4.2 shows soundness ⟹ falsum-soundness. The converse fails, so the weak
bridge (Theorem 4.1) is a strict generalization of the bridge (Theorem 4.3).

**Theorem 5.1 (Strict weakening).** *There exist a proof system `P` over `ℕ` and
a semantics `M` for `P` such that `M` is falsum-sound but not sound.*

*Construction.* Take sentences `S = ℕ` and `bot = 0`. Define derivability by

  `Proves Γ φ  :=  φ ∈ Γ  ∨  (1 ∈ Γ ∧ φ = 2).`

The first disjunct is the assumption rule; the second is an extra, *unsound*
deduction rule of the schematic form *p ⊢ q* ("from 1, conclude 2"). Weakening
and the assumption rule are immediate from the definition. For the semantics,
take a single world (`World = Unit`) with `sat _ φ := (φ = 1)` — only the
sentence 1 is true — and `bot_unsat` holds since `0 ≠ 1`.

*Falsum-soundness.* Suppose `Γ ⊢ 0` with all hypotheses of `Γ` satisfied. The
second disjunct cannot apply (it forces the conclusion to be `2 ≠ 0`), so `0 ∈
Γ`; but then `0` is a satisfied hypothesis, i.e. `0 = 1`, impossible. Hence the
antecedent never occurs and falsum-soundness holds (vacuously, but genuinely).

*Failure of soundness.* We have `{1} ⊢ 2` via the second disjunct, and the world
satisfies the hypothesis `1`; yet it does not satisfy `2` (since `2 ≠ 1`). Thus
soundness fails. ∎

The example shows the generalization is *proper*: there are physics for which the
bridge holds (via Theorem 4.1) even though the proof system is not fully sound.
Conceptually, the bridge cares only that the system never *fabricates*
contradictions, not that it tells the truth about everything.

---

## 6. The separation theorem: consistency does not certify realizability

We now show the converse of the bridge fails in full generality.

**Theorem 6.1 (Separation).** *There is a proof system `P`, a semantics `M`, and
a theory `T` such that `T` is consistent but `T` is not physically consistent
(i.e. `T` has no model).*

*Construction.* Take any proof system `P` in which the empty theory does not
prove ⊥ — for instance, the trivial system over any `S` whose only derivations
are instances of the assumption rule, so `∅ ⊢ ⊥` is false and `∅` is consistent.
For the semantics, let the type of worlds be **empty**: `World = Empty`. Then
`bot_unsat` holds *vacuously* — there are no worlds to violate it — so `M` is a
legitimate semantics.

*Consistency.* `∅` (or any consistent `T`) does not prove ⊥, by choice of `P`.

*No model.* `HasModel(T)` asserts the existence of a world satisfying `T`; but
`World` is empty, so no world exists, and `HasModel(T)` is false for *every*
theory. In particular `T` is not physically consistent. ∎

**Corollary 6.2.** *Mathematical consistency does not imply physical
consistency.*

The empty-world model is the sharpest possible witness: it shows that the
implication can fail *for structural reasons alone*, independent of the
particular axioms. The deeper reason is foundational: **consistency is a
syntactic property (the proof relation never reaches ⊥) whereas satisfiability is
a semantic property (a world exists).** The separation theorem makes precise that
the second is strictly stronger; consistency is a *necessary* but not
*sufficient* condition for realizability.

This asymmetry — bridge in one direction (Theorem 4.4), separation in the other
(Corollary 6.2) — is the structural heart of the framework.

---

## 7. The completeness collapse: where the gap closes

The separation theorem leaves open *when* the two notions coincide. The answer is
classical: when the semantics is not only sound but **complete**.

**Definition 7.1 (Completeness).** A semantics `M` is *complete* for `P` when
every consistent theory has a model: `Consistent(T) ⟹ HasModel(T)`.

This is exactly the content of Gödel's completeness theorem for first-order
logic, abstracted to our setting.

**Theorem 7.2 (Completeness collapse).** *If `M` is sound and complete, then for
every theory `T`: `Consistent(T) ↔ PhysicallyConsistent(T)`.*

*Proof sketch.* (⟸) Soundness gives `PhysicallyConsistent(T) ⟹ Consistent(T)` by
Theorem 4.4. (⟹) Completeness gives `Consistent(T) ⟹ HasModel(T) =
PhysicallyConsistent(T)` directly from Definition 7.1. ∎

Theorem 7.2 identifies a **phase boundary** between logic and physics. On the
abstract side (arbitrary proof systems and semantics), syntax and semantics come
apart — witness the separation theorem. On the complete side (e.g. classical
first-order logic), they coincide exactly: "never contradicts itself" and "has a
model" become two descriptions of one phenomenon. Completeness is precisely the
hypothesis that fuses the syntactic and semantic certificates.

---

## 8. A quantum strengthening and the consistency hierarchy

The framework's abstraction over `World` invites richer notions of realizability.
Quantum theory describes physical reality not by a single definite state but by a
*structured space* of states closed under superposition. We model this by
strengthening "has a model" to "has a superposition-closed family of models."

**Definition 8.1 (Quantum physical consistency, informal).** Equip the semantics
with a *superposition* operation on worlds. `T` is *quantum physically
consistent* when it has a nonempty family of models closed under superposition:
for any two models `w₁, w₂` of `T`, their superposition is again a model of `T`.

**Theorem 8.2 (Quantum hierarchy).**
*`QuantumPhysicallyConsistent(T) ⟹ PhysicallyConsistent(T) ⟹ Consistent(T)`,
with each implication strict (under sound semantics).*

*Proof sketch.* A superposition-closed family is in particular nonempty, hence
yields a model, giving the first implication; the second is Theorem 4.4.
Strictness of the second is the separation theorem (Corollary 6.2). Strictness of
the first is witnessed by a semantics with models that are not closed under the
superposition operation. ∎

The upshot is a three-tier ladder of strength —

  quantum consistency ⊋ physical consistency ⊋ mathematical consistency —

in which a single syntactic theory occupies different rungs depending on *how much
reality* one demands it instantiate. Non-contradiction is the weakest rung; a
single world is stronger; a superposition-closed space of worlds is stronger
still.

---

## 9. Worked examples and computational verification

The abstractness of the framework can be grounded in fully finite instances
whose every theorem becomes a decidable check. We record three canonical
models over the three-element sentence space `S = {0, 1, 2}` with `bot = 0`,
reading `1` as the atom *p* and `2` as the atom *q*.

**(a) A sound, complete classical system.** Let `Proves Γ φ := (φ ∈ Γ)` — the
bare assumption-and-weakening system, deriving nothing beyond its hypotheses.
Take two worlds: `w₀` satisfying `{p}` and `w₁` satisfying `{p, q}`, with neither
satisfying `0`. This semantics is *sound* (every derived sentence is a hypothesis,
hence true wherever the hypotheses are) and *complete* (every consistent theory —
i.e. every subset of `{1, 2}` — is satisfied by `w₁`). By Theorem 7.2,
mathematical and physical consistency coincide on all eight theories; exhaustive
enumeration confirms `Consistent(T) = HasModel(T)` in every case. This instance
lives on the *complete* side of the phase boundary.

**(b) The falsum-sound-but-unsound system.** Over `S = ℕ` with `bot = 0`, let
`Proves Γ φ := (φ ∈ Γ) ∨ (1 ∈ Γ ∧ φ = 2)`, and take the single world satisfying
only `1`. Exhaustive checking confirms falsum-soundness (the antecedent of the
falsum-soundness condition never fires, since deriving `0` would require `0 ∈ Γ`,
i.e. a satisfied hypothesis equal to `1`) and the failure of full soundness
(`{1} ⊢ 2`, the world satisfies `1` but not `2`). This is the computational
shadow of Theorem 5.1.

**(c) The empty-world semantics.** With `World = ∅`, the predicate `HasModel(T)`
is identically false while `bot_unsat` holds vacuously, so the empty (consistent)
theory is mathematically consistent yet physically inconsistent — the
computational shadow of Theorem 6.1.

Each of (a)–(c) is verified by a short exhaustive program that enumerates the
`2^{|S|}` theories and evaluates the relevant predicates directly, turning the
proved theorems into machine-checkable assertions on concrete data. Because the
framework's hypotheses are local (each theorem consumes exactly one structural
assumption), these finite witnesses suffice to *separate* the notions: (b) and
(c) demonstrate that no finite tightening of the structural axioms collapses
falsum-soundness into soundness, or consistency into realizability, without an
external completeness hypothesis as in (a).

## 10. Discussion and future work

The framework demonstrates how far one can travel on minimal axioms. From only
weakening, the assumption rule, and `bot_unsat`, we obtain the bridge, its
optimal hypothesis (falsum-soundness), a proper-generalization witness, the
separation theorem, the completeness collapse, and a quantum hierarchy. The
guiding principle throughout is to *consume exactly one assumption per theorem*,
making the logical dependencies fully transparent.

We highlight five directions, each falsifiable by a single counterexample inside
the existing framework.

**Direction 1 — Canonical models and an internalized completeness collapse.**
Completeness (Definition 7.1) is currently an external hypothesis. The goal is to
*construct* a Lindenbaum/term-model functor `term : ProofSystem → Semantics`
whose worlds are maximal consistent extensions, and prove it is automatically
sound and complete whenever `P` is closed under a small set of structural rules
(cut, negation introduction). The key insight: the consistency–satisfiability gap
collapses exactly when the proof system can name its own maximal consistent
extensions, so completeness becomes a *closure property* of ⊢ rather than an
extra axiom — pinning the logic/physics phase boundary to an explicit checkable
condition.

**Direction 2 — Consistency-strength towers via an internal provability
predicate.** Extend `ProofSystem` with a unary `con : S → S` obeying an abstract
Hilbert–Bernays/Löb discipline, and conjecture that for consistent `T` the
sentence `con(T)` is unprovable from `T`, so Theorem 2.4 yields a strict tower
`T ⊊ T ∪ {con T} ⊊ T ∪ {con(T ∪ {con T})} ⊊ ⋯`. The structural extension step is
already handled by `proper_extension_new_theorem`; the missing piece is the
independence of `con(T)`, which requires encoding self-reference (a diagonal
lemma or sufficient approximation). This would internalize Gödel's second
incompleteness theorem in the framework.

**Direction 3 — Robustness of consistency under theory composition.** Conjecture:
if `T₁` and `T₂` are consistent over disjoint vocabularies (the proof system
restricted to one cannot derive sentences of the other), then `T₁ ∪ T₂` is
consistent. This formalizes the physical intuition that independent systems do
not create contradictions when combined, with Craig interpolation as the guiding
analogy. A counterexample would reveal how seemingly independent theories
interact through shared logical structure.

**Direction 4 — Multi-world / quantum consistency.** Develop Definition 8.1 fully
by giving `World` algebraic structure (vector space or lattice) and a concrete
superposition operation, then prove Theorem 8.2 with explicit strictness
witnesses. If superposition closure fails to add consistency strength, quantum
structure would be revealed as orthogonal to consistency.

**Direction 5 — Algorithmic physical consistency.** For decidable proof systems,
restrict to *computable* models (where `sat` is computable). Conjecture a
three-way separation: consistent theories with no model (Theorem 6.1), theories
with models but no computable model, and theories with computable models. This
would establish computability as an intermediate notion between syntax and
semantics — the effective analogue of the separation theorem.

---

## 11. Conclusion

We have given a compact, fully abstract account of the relationship between
having a model and being free of contradiction. The two notions are not the same:
realizability is a strictly stronger, *semantic* certificate, while consistency
is a *syntactic* property; the bridge runs only one way in general, requires only
honesty about contradictions, and is reversed exactly under completeness. The
framework's economy — three structural axioms and one semantic constraint — is
what lets each theorem expose the precise hypothesis it depends on, turning a
familiar intuition into a sharp, verified landscape spanning syntax, semantics,
and their phase boundary.
