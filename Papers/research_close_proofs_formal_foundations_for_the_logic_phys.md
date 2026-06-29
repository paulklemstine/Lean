# The Logic–Physics Bridge: A Domain‑Agnostic Equivalence Between Physical Realizability and Logical Consistency

## Abstract

We give a fully formal, domain‑agnostic account of the century‑old slogan *"consistency is existence."* Working over an arbitrary state space `S`, we identify a **theory** with a set of predicates ("laws") on `S`, define **physical realizability** as the existence of a state satisfying all laws, and define **logical consistency** *semantically* as the failure of the theory to entail the absurd predicate. Our central result, the **Logic–Physics Bridge**, is the biconditional

$$\textbf{Realizable } T \iff \textbf{Consistent } T,$$

valid for every theory over every type. We show that this single equivalence generates a usable calculus of realizability: a *principle of explosion* (an unrealizable theory entails every law), a *realizability/⊥‑entailment duality*, *monotonicity* of realizability under theory weakening, a syntactic *no‑go theorem* (a theory containing a law and its negation is unrealizable), and full *compositionality* across independent subsystems via a product construction. A concrete physics instantiation (energy‑conservation laws on a real state space) certifies non‑vacuity, including a genuine physical no‑go for an over‑constrained two‑level system. We then extend the static picture to **dynamics**: a serial step relation with a nonempty initial set admits an infinite trajectory ("a non‑stuck law evolves forever"), temporal realizability is exhibited as a literal instance of the static bridge, and the two combine to certify consistency of trajectory theories. The unifying methodological finding is one of *mathematical economy*: the entire correspondence rests on exactly two nonconstructive primitives — classical logic (excluded middle / `not_forall`) for the static half and the Axiom of Choice for the temporal half — with everything else forced by the definitions. All results have been formally verified.

**Keywords.** model existence, consistency, semantic entailment, realizability, modal logic, axiom D, serial relations, compositionality, classical logic, axiom of choice, foundations of physics.

---

## 1. Introduction

### 1.1 Motivation

The conviction that *the consistency of a set of axioms suffices to guarantee the existence of the objects they describe* is one of the load‑bearing ideas of modern foundations. Hilbert wielded it against Frege's existential scruples; Gödel's completeness theorem made it rigorous for first‑order logic by proving that a syntactically consistent theory has a model. In physics, the same intuition appears informally whenever a theorist argues that a proposed body of laws "describes a possible world" precisely when those laws "do not contradict each other."

The aim of this paper is to extract the *purely semantic kernel* of that intuition — the equivalence between **having a model** and **not entailing a contradiction** — and to present it in a form that

1. is **domain‑agnostic** (it holds over an arbitrary type `S`, with no commitment to any particular logic, signature, or physical theory),
2. is **proof‑system‑free** (consistency is defined semantically, so no derivation calculus is dragged in), and
3. is **generative** (the structural meta‑theorems of realizability follow as short corollaries).

### 1.2 Contributions

- **The static bridge** (§3): `Realizable T ↔ Consistent T`, with consistency defined as non‑entailment of `⊥`.
- **A calculus of realizability** (§4): explosion, duality, monotonicity, a no‑go theorem, and compositionality via a product theory.
- **A non‑vacuous physics instantiation** (§5): energy conservation on a real state space, and an over‑constrained two‑level no‑go.
- **The dynamical bridge** (§6): serial laws admit eternal trajectories; temporal realizability is an instance of the static bridge; trajectory theories are consistent.
- **A foundational audit** (§7): isolating classical logic and the Axiom of Choice as the *only* nonconstructive ingredients.

### 1.3 Methodological thesis

Our central methodological claim is that the mathematical content of the logic–physics correspondence is concentrated entirely in the *choice of primitive notions*. Defining consistency semantically rather than syntactically turns the headline theorem into a one‑line unfolding and makes every structural corollary essentially forced. This both clarifies the mathematics and pinpoints its exact logical strength.

---

## 2. Definitions

Throughout, `S`, `S'` denote arbitrary types (state spaces) in a fixed universe.

**Definition 2.1 (Theory).** A *theory* over `S` is a set of predicates on `S`:
$$\mathrm{Theory}\,S \;:=\; \mathrm{Set}\,(S \to \mathrm{Prop}).$$
Elements of a theory are called *laws*.

**Definition 2.2 (Model).** A state `s : S` is a *model* of a theory `T` if it satisfies every law:
$$\mathrm{IsModel}\,T\,s \;:=\; \forall\, p \in T,\; p\,s.$$

**Definition 2.3 (Realizability).** A theory is *realizable* if it has a model:
$$\mathrm{Realizable}\,T \;:=\; \exists\, s,\; \mathrm{IsModel}\,T\,s.$$

**Definition 2.4 (Entailment).** A theory *entails* a predicate `φ` if every model of `T` satisfies `φ`:
$$\mathrm{Entails}\,T\,\varphi \;:=\; \forall\, s,\; \mathrm{IsModel}\,T\,s \to \varphi\,s.$$

**Definition 2.5 (The absurd law and consistency).** Write `⊥` for the predicate `fun _ => False`, false at every state. A theory is *consistent* if it does not entail `⊥`:
$$\mathrm{Consistent}\,T \;:=\; \neg\,\mathrm{Entails}\,T\,(\lambda\, \_.\,\mathrm{False}).$$

**Remark 2.6 (Why semantic consistency).** An earlier formulation defined consistency syntactically, via a derivation relation. This needlessly imports a proof calculus and breaks domain‑agnosticism. Defining consistency *semantically* — as non‑entailment of `⊥` — keeps the bridge clean and turns the would‑be "completeness theorem" into a definitional unfolding. The price is that we work in a classical metatheory; see §7.

---

## 3. The Central Bridge

**Theorem 3.1 (Logic–Physics Bridge).** For every theory `T` over `S`,
$$\mathrm{Realizable}\,T \iff \mathrm{Consistent}\,T.$$

*Proof sketch.* Unfold both sides. Realizability is `∃ s, IsModel T s`. Consistency is `¬ (∀ s, IsModel T s → False)`.

(⇒) Given a model `s` with `IsModel T s`, suppose toward the entailment that `∀ s, IsModel T s → False`. Applying it to `s` yields `False`. Hence the entailment fails, i.e. `T` is consistent.

(⇐) Assume `T` is consistent, i.e. `¬ (∀ s, IsModel T s → False)`. Suppose for contradiction `¬ Realizable T`, i.e. `¬ ∃ s, IsModel T s`. By the classical equivalence `¬∃` ↔ `∀¬` (`push_neg`), we obtain `∀ s, ¬ IsModel T s`, which immediately gives `∀ s, IsModel T s → False`, contradicting consistency. Therefore `T` is realizable. ∎

**Remark 3.2.** The entire proof is the classical tautology `(\exists s,\,P\,s) \iff \neg(\forall s,\,\neg P\,s)` instantiated at `P = IsModel T`. The nonconstructive step is exactly one use of `not_forall`/double‑negation elimination. No other ingredient appears.

---

## 4. A Calculus of Realizability

The bridge is generative: the standard structural meta‑theorems follow as short corollaries.

**Theorem 4.1 (Principle of explosion).** If `T` is not realizable, then `T` entails every predicate `φ`:
$$\neg\,\mathrm{Realizable}\,T \;\Longrightarrow\; \forall\, \varphi,\; \mathrm{Entails}\,T\,\varphi.$$
*Proof sketch.* To prove `Entails T φ`, take any `s` with `IsModel T s`. Then `⟨s, ·⟩` witnesses `Realizable T`, contradicting the hypothesis; the goal follows vacuously. ∎

This is *ex falso quodlibet* for worlds: an unrealizable theory has no models, so universally quantified statements over its models hold vacuously.

**Theorem 4.2 (Realizability/⊥ duality).** $\mathrm{Entails}\,T\,(\lambda\_.\,\mathrm{False}) \iff \neg\,\mathrm{Realizable}\,T.$
*Proof sketch.* Rewrite `Realizable T` as `Consistent T` (Theorem 3.1), unfold `Consistent` to `¬ Entails T ⊥`, and apply `(¬¬P ↔ P)` symmetrically. ∎

**Theorem 4.3 (Monotonicity under weakening).** If `T ⊆ T'` and `T'` is realizable, then `T` is realizable.
*Proof sketch.* Let `s` model `T'`. For any `p ∈ T` we have `p ∈ T'` by inclusion, hence `p s`. Thus `s` models `T`. ∎

Removing laws can only enlarge the model set; the same witness survives. This is the order‑theoretic backbone of "relax the constraints."

**Theorem 4.4 (No‑go from explicit contradiction).** If `p ∈ T` and `(λ s. ¬ p s) ∈ T`, then `¬ Realizable T`.
*Proof sketch.* Suppose `s` models `T`. Then `s` satisfies both `p` (since `p ∈ T`) and `¬ p` (since the negated law is in `T`), an immediate contradiction. ∎

**Definition 4.5 (Product theory).** For theories `T` over `S` and `T'` over `S'`, define on `S × S'`:
$$T \times T' \;:=\; \{\, q \mid (\exists p \in T,\; q = \lambda x.\,p\,x_1)\ \vee\ (\exists p' \in T',\; q = \lambda x.\,p'\,x_2) \,\}.$$
A law of the product is a law of one factor, lifted to act on the corresponding coordinate of the joint state.

**Theorem 4.6 (Compositionality).**
$$\mathrm{Realizable}(T \times T') \iff \mathrm{Realizable}\,T \;\wedge\; \mathrm{Realizable}\,T'.$$
*Proof sketch.*
(⇒) Let `(s, s')` model the product. For `p ∈ T`, the lifted law `λx. p x.1` lies in the product, so `(s,s')` satisfies it, i.e. `p s`; thus `s` models `T`. Symmetrically `s'` models `T'`.
(⇐) Let `s` model `T` and `s'` model `T'`. Any product law is either `λx. p x.1` with `p ∈ T` (satisfied by `(s,s')` because `p s` holds) or `λx. p' x.2` with `p' ∈ T'` (satisfied because `p' s'` holds). Hence `(s,s')` models the product. ∎

Independent subsystems are jointly realizable iff each is individually realizable: possibility is modular, and gluing consistent worlds neither creates nor destroys contradictions.

---

## 5. A Non‑Vacuous Physics Instantiation

To certify the framework is not about empty abstractions, instantiate it on a concrete physical setting.

**Construction 5.1 (Energy‑conservation theory).** Take a real‑valued observable `E : S → ℝ` (energy) and a target value `e₀`. The conservation law is the predicate `fun s => E s = e₀`, and the conservation theory is the singleton (or finite set) of such laws.

**Proposition 5.2 (Conservation is realizable).** If some state attains the prescribed energy — i.e. there exists `s` with `E s = e₀` — then the conservation theory is realizable, hence consistent by Theorem 3.1.
*Proof sketch.* The witnessing state models the singleton law directly. ∎

**Proposition 5.3 (Two‑level no‑go).** Consider a two‑level system and a theory asserting both a level‑defining law `p` (e.g. "the system is in the ground state") and its negation `¬ p` (forced by also asserting an incompatible excited‑state condition). Then the theory is not realizable.
*Proof sketch.* Immediate from Theorem 4.4: the theory contains `p` and `λ s. ¬ p s`. ∎

A contradiction *in the laws* becomes an impossibility *in the world*, exactly as the bridge demands. This is the abstract template for physical impossibility results (perpetual motion, superluminal signalling, etc.): the proposed device's specification secretly contains a law and its negation.

---

## 6. The Dynamical Bridge

Static realizability concerns a single snapshot. We now extend to *dynamics*, where the object of interest is an entire history.

**Definition 6.1 (Step relation, seriality).** A *dynamical law* is a relation `R : S → S → Prop`, read "`s` may be followed by `t`." It is *serial* if `∀ s, ∃ t, R s t` — from every state some legal successor exists (the system is never stuck). In modal logic, seriality is exactly the frame condition validating axiom **D** (`□φ → ◇φ`).

**Definition 6.2 (Trajectory).** A *trajectory* from an initial set `I ⊆ S` is a function `σ : ℕ → S` with `σ 0 ∈ I` and `R (σ n) (σ (n+1))` for all `n` — an infinite, legally‑evolving history.

**Theorem 6.3 (Serial laws evolve forever).** If `I` is nonempty and `R` is serial, then there exists a trajectory `σ : ℕ → S` from `I`.
*Proof sketch.* Pick `σ 0 ∈ I`. Seriality gives, for each state, a successor; using the Axiom of Choice extract a global successor function `next : S → S` with `R s (next s)` for all `s`. Define `σ` by primitive recursion: `σ (n+1) := next (σ n)`. By construction `σ 0 ∈ I` and each consecutive pair is related. ∎

The nonconstructive content is precisely the promotion of the *local* existential ("a successor exists at each state") to a *global* choice function — one application of `Classical.choice`.

**Theorem 6.4 (Temporal = static).** Temporal realizability of `(I, R)` coincides with static realizability of an associated *trajectory theory* over the state space `ℕ → S` of histories: the laws "`σ 0 ∈ I`" and "`∀ n, R (σ n) (σ (n+1))`" are predicates on histories, and a model of that theory is exactly a trajectory. Hence the existence of an eternal trajectory is a *literal instance* of Theorem 3.1.
*Proof sketch.* Unfold both notions; `IsModel` of the trajectory theory at `σ` unfolds to the conjunction defining a trajectory. ∎

**Corollary 6.5 (Consistency of trajectory theories).** For a nonempty `I` and serial `R`, the trajectory theory is realizable (Theorem 6.3) and therefore consistent (Theorem 3.1). Composing the static and dynamical bridges yields: *a non‑stuck evolution law is logically consistent as a theory of histories.*

Thus dynamics requires no new foundations. Time is not an exception to the logic–physics correspondence but one of its examples.

---

## 7. Foundational Audit

A virtue of the semantic formulation is that the logical strength of each result is fully transparent.

- **Static half.** Theorem 3.1 (⇐ direction) and Theorem 4.2 use classical reasoning: `not_forall` / double‑negation elimination. The (⇒) directions, monotonicity, no‑go, explosion, and compositionality are all intuitionistically valid.
- **Dynamical half.** Theorem 6.3 uses the Axiom of Choice exactly once, to obtain a global successor function from pointwise seriality.

No other nonconstructive principle appears anywhere. The formal developments use only the standard foundational axioms (propositional extensionality, choice, and quotient soundness). This is the paper's *economy thesis* made precise: the logic–physics correspondence is exactly as nonconstructive as (i) excluded middle and (ii) dependent choice for the successor function — no more.

---

## 7bis. Worked Examples

To make the abstract machinery concrete, we record several small instances that exercise every theorem of §§3–6. Throughout, take the state space `S = ℤ` (or a finite window of it).

**Example A (a realizable theory).** Let `T = { (λs. s > 0), (λs. even s) }`. The state `s = 2` satisfies both laws, so `IsModel T 2` holds, hence `Realizable T`. By Theorem 3.1 the theory is consistent: it does not entail `⊥`. Indeed the set of models is `{2, 4, 6, …}`, a witness to non-vacuity.

**Example B (an inconsistent theory).** Let `T = { (λs. s > 0), (λs. s < 0) }`. No integer is both positive and negative, so `T` has no model and `¬ Realizable T`. By Theorem 4.1 (explosion) `T` entails *every* predicate `φ`; in particular it entails `⊥`, confirming Theorem 4.2 (the duality). This is the abstract face of *ex falso quodlibet*.

**Example C (monotonicity).** With `T' = { (λs. even s), (λs. s > 4) }` (realized by `6`) and `T = { (λs. even s) }`, we have `T ⊆ T'` and `Realizable T'`, so Theorem 4.3 gives `Realizable T` directly — the witness `6` survives the dropping of the law `s > 4`. Note the converse fails: `T` is realizable but the *stronger* theory `T'' = { (λs. even s), (λs. odd s) }` is not, illustrating that strengthening can break realizability while weakening never can.

**Example D (the no-go theorem).** Let `p = (λs. s = 0)` and form `T = { p, (λs. ¬ p s) }`. Since both `p` and its negation lie in `T`, Theorem 4.4 yields `¬ Realizable T` with no search required: the contradiction is syntactic. This is the template instantiated physically in Proposition 5.3.

**Example E (compositionality).** Let `S = ℤ`, `S' = {red, green, blue}`, `T = { (λs. even s) }`, and `T' = { (λc. c = green) }`. Both factors are realizable (`0` and `green`), so by Theorem 4.6 the product theory over `ℤ × {red, green, blue}` is realizable, witnessed by `(0, green)`. Replacing `T'` by the unsatisfiable `{ (λc. c = purple) }` makes the right‑hand conjunct false, and the product becomes unrealizable in lockstep — the equivalence is exact in both directions.

**Example F (eternal trajectory).** On `S = ℤ/6ℤ` with successor relation `R s t ⟺ t = s + 1 (mod 6)`, every state has exactly one successor, so `R` is serial. With `I = {0}` nonempty, Theorem 6.3 produces the trajectory `0, 1, 2, 3, 4, 5, 0, 1, …`, a legal infinite history. By Corollary 6.5 the associated trajectory theory over `ℕ → ℤ/6ℤ` is realizable, hence consistent.

These examples are exactly the cases discharged numerically by the accompanying decision procedure, providing a finite, machine-checkable cross-validation of the formal theorems.

## 8. Discussion

### 8.1 Relation to completeness

Gödel's completeness theorem is *"syntactic consistency ⇒ model existence."* Our bridge is the semantic shadow of its converse‑plus‑direction packaged together: with consistency *defined* as semantic non‑entailment of `⊥`, "completeness" becomes definitional. The substantive content of Gödel's theorem — that a *syntactic* notion of consistency suffices — lies precisely in replacing our semantic `Consistent` with a proof‑theoretic one and re‑proving the bridge. Our framework cleanly factors out the part of the story that is independent of any proof calculus.

### 8.2 Modal and dynamical reading

Theorem 6.3 is the realizability content of axiom **D**: a serial Kripke frame carries an infinite path. The identification in Theorem 6.4 shows that "the future exists" is the same kind of statement as "a state exists" — model existence, applied to the space of histories. This suggests a uniform treatment of safety/liveness‑style properties as realizability statements over suitable trajectory spaces.

### 8.3 Compositionality and modularity

Theorem 4.6 formalizes the working physicist's assumption that independent subsystems can be modelled separately and combined without surprise. The product construction is the categorical product of theories in disguise; the equivalence says realizability is a *product‑preserving* property.

---

## 9. Future Work

- **Beyond binary products.** Extend compositionality to arbitrary (possibly infinite) families of subsystems and to *coupled* systems where laws relate coordinates, measuring exactly when realizability still factors.
- **Quantitative realizability.** Replace `Prop`‑valued laws with graded/`[0,1]`‑valued constraints and ask for the bridge's metric or measure‑theoretic analogue (approximate realizability ↔ approximate consistency).
- **Syntactic re‑coupling.** Reintroduce a derivation calculus and recover Gödel‑style completeness as a theorem relating syntactic consistency to our semantic `Consistent`, isolating the additional content.
- **Richer temporal logics.** Generalize Theorem 6.3 from seriality (axiom D) to branching‑time and to fairness constraints, characterizing which frame conditions preserve trajectory realizability.
- **Physical no‑go atlas.** Recast known impossibility results (thermodynamic, relativistic, quantum) as instances of Theorem 4.4, building a library of "law + negation" contradictions.

---

## 10. Conclusion

We have turned the slogan *"consistency is existence"* into a single domain‑agnostic theorem, `Realizable T ↔ Consistent T`, and shown that it generates a complete working calculus — explosion, duality, monotonicity, no‑go, compositionality — together with a dynamical extension in which serial laws evolve forever and temporal realizability is literally an instance of the static bridge. The decisive move is definitional: by stating consistency semantically, the entire correspondence collapses to two nonconstructive primitives, classical logic and the Axiom of Choice, with everything else forced. Hilbert's slogan was never optimism; it was a theorem awaiting the right definitions.
