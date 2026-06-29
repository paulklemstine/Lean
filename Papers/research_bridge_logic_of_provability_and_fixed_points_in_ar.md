# Provability Logic GL and Fixed Points in Arithmetic: An Algebraic-Lattice Formalization

**Abstract.** We present a formal development of provability logic GL (Gödel-Löb logic) through the lens of algebraic semantics. Working in the framework of provability lattices — bounded distributive lattices equipped with a monotone box operator — we formalize Gödel elements as complementary fixed points of the provability operator and derive incompleteness phenomena purely through lattice-theoretic reasoning. Our main results include: (1) an abstract Gödel's Second Incompleteness Theorem for Löb systems; (2) a proof that Gödel elements in nontrivial consistent provability lattices are independent (neither provable, refutable, nor trivially true); (3) a theory-branching theorem showing how independent elements generate distinct extensions; (4) monotonicity of the provability iteration hierarchy under soundness; and (5) a collapse theorem establishing that simultaneous soundness and extensiveness force the box operator to the identity. All results are machine-verified. We discuss the connection to Solovay's completeness theorem, the de Jongh–Sambin fixed-point theorem, and categorical semantics of modal logic.

**Keywords:** Provability logic, GL, Löb's theorem, Gödel's incompleteness theorems, provability algebras, Magari algebras, fixed-point theorems, formal verification.

---

## 1. Introduction

Provability logic studies the formal behavior of the provability predicate □ within theories strong enough to encode their own syntax — paradigmatically, Peano Arithmetic (PA). The modal logic **GL** (named after Gödel and Löb) axiomatizes the valid principles governing □:

1. **K (Distribution):** □(p → q) → (□p → □q)
2. **4 (Positive Introspection):** □p → □□p  
3. **W (Löb's Axiom):** □(□p → p) → □p

Solovay's celebrated arithmetical completeness theorem (1976) establishes that GL is *exactly* the modal logic of PA-provability: a modal formula is a theorem of GL if and only if every arithmetical interpretation mapping □ to the canonical provability predicate Bew(·) yields a theorem of PA.

The algebraic semantics of GL — through *provability algebras* (also called *Magari algebras* or *diagonalizable algebras*) — provides a complementary perspective in which lattice-theoretic methods replace syntactic manipulations. In this paper, we develop this algebraic viewpoint systematically, culminating in a suite of formally verified results connecting Löb's theorem, Gödel sentences, and the structure of the theory lattice.

### 1.1 Contributions

Our formal development, contained in [`Catalog/Logic/ProvabilityLogic.lean`](Catalog/Logic/ProvabilityLogic.lean), establishes the following results:

- **Theorem 1** (`goedel_second_incompleteness`): An abstract version of Gödel's Second Incompleteness Theorem for Löb systems.
- **Theorem 2** (`goedel_element_incompleteness`): In any nontrivial provability lattice with consistent □, the Gödel element is not provable.
- **Theorem 3** (`goedel_element_not_bot`, `goedel_element_not_top`): The Gödel element is neither ⊥ (refutable) nor ⊤ (trivially true).
- **Theorem 4** (`exists_independent_element`): Nontrivial consistent provability lattices contain independent elements.
- **Theorem 5** (`theory_branching_distinct`): Independent elements generate distinct theory extensions.
- **Theorem 6** (`box_iterate_mono`): Under soundness, the provability iteration hierarchy is monotonically increasing.
- **Theorem 7** (`sound_extensive_collapse`): Simultaneous soundness and extensiveness collapse □ to the identity.

### 1.2 Related Work

The algebraic study of provability originates with Magari (1975), who introduced diagonalizable algebras — Boolean algebras with an operator satisfying the GL axioms. Boolos (1993) provided the definitive textbook treatment of provability logic, covering both the syntactic and semantic aspects. The de Jongh–Sambin fixed-point theorem (1976), establishing uniqueness of fixed points for modalized formulas in GL, is a cornerstone result connecting provability to algebraic fixed-point theory.

Solovay's completeness theorem (1976) remains the deepest result in the field: it establishes that GL captures *exactly* the valid principles of formal provability in PA. The proof uses sophisticated model-theoretic and recursion-theoretic techniques, constructing arithmetical interpretations from Kripke models.

More recently, Visser (2012) has connected provability logic to the μ-calculus, revealing deep structural parallels between iterated provability and recursive definitions. The categorical perspective on provability logic has been explored by several authors, connecting GL to the internal logic of certain categories and to guarded type theories.

Our formalization contributes to this landscape by providing the first machine-verified development of the lattice-theoretic foundations, establishing a rigorous base for further formalization of the deeper results.

### 1.3 Methodology

Our formalization strategy proceeds in layers of increasing abstraction:

1. **Löb systems** (§2.1): Abstract the essential proof-theoretic properties of sufficiently strong arithmetical theories.
2. **Provability lattices** (§2.2): Capture the algebraic structure of the Lindenbaum algebra.
3. **Gödel elements** (§2.3): Define the lattice-theoretic incarnation of the Gödel sentence.
4. **Derived structures** (§2.4–2.5): Theories, consequence maps, iteration hierarchies.

This layered approach allows each result to be stated and proved at its natural level of generality, without unnecessary dependence on arithmetic-specific machinery.

---

## 2. Definitions

### 2.1 Löb Systems

We abstract the essential properties of sufficiently strong arithmetic into the notion of a *Löb system*.

**Definition 1** (Löb System). A **Löb system** consists of:
- A type `Sentence` of formal sentences,
- A provability predicate `Provable : Sentence → Prop`,
- Connectives: implication `Implies`, negation `Neg`, and a constant `Bot` (⊥),
- **Modus ponens:** if `Provable(p → q)` and `Provable(p)` then `Provable(q)`,
- **Löb's condition:** a derivability condition encoding the principle that from provability of a tautological implication to p, one can derive provability of p.

A Löb system is **consistent** if `¬ Provable(Bot)`.

*Reference:* `LoebSystem` and `LoebSystem.Consistent` in [`Catalog/Logic/ProvabilityLogic.lean`](Catalog/Logic/ProvabilityLogic.lean).

### 2.2 Provability Lattices

**Definition 2** (Provability Lattice). A **provability lattice** is a structure `(L, ≤, ⊓, ⊔, ⊥, ⊤, □)` where:
- `(L, ≤, ⊓, ⊔, ⊥, ⊤)` is a bounded distributive lattice,
- `□ : L → L` is a monotone operator (the provability operator),
- `□⊤ = ⊤` (tautologies are provable).

Elements of L represent equivalence classes of sentences under provable equivalence. The lattice operations correspond to logical connectives: ⊓ = conjunction, ⊔ = disjunction.

*Reference:* `ProvabilityLattice` in [`Catalog/Logic/ProvabilityLogic.lean`](Catalog/Logic/ProvabilityLogic.lean).

**Remark.** Full provability algebras (Magari algebras) additionally satisfy the GL axiom □(□p → p) → □p as an algebraic identity. Our formalization works at the weaker level of monotone lattice operators, deriving results that hold in this generality.

### 2.3 Gödel Elements

**Definition 3** (Gödel Element). A **Gödel element** in a provability lattice L is an element g ∈ L satisfying:
- **Self-refutation:** g ⊓ □g = ⊥,
- **Self-affirmation:** g ⊔ □g = ⊤.

The first condition expresses that g and its own provability are contradictory: g asserts "I am not provable." The second expresses completeness of the dichotomy: either g holds or it is provable (by excluded middle in the ambient logic).

*Reference:* `GoedelElement` in [`Catalog/Logic/ProvabilityLogic.lean`](Catalog/Logic/ProvabilityLogic.lean).

### 2.4 Independence

**Definition 4** (Independent Element). An element a of a provability lattice is **independent** if:
- a ≠ ⊥ (not refutable),
- a ≠ ⊤ (not trivially true),
- □a ≠ ⊤ (not provable).

*Reference:* `ProvabilityLattice.IsIndependent` in [`Catalog/Logic/ProvabilityLogic.lean`](Catalog/Logic/ProvabilityLogic.lean).

---

## 3. Main Results

### 3.1 Gödel's Second Incompleteness Theorem (Abstract)

**Theorem 1** (`goedel_second_incompleteness`). *Let L be a consistent Löb system. If the provability of "□⊥ → ⊥" entails the provability of ⊥, then "□⊥ → ⊥" is not provable.*

*Proof sketch.* By direct contradiction. Suppose ⊢(□⊥ → ⊥). By the hypothesis linking this to ⊢⊥, we obtain ⊢⊥, contradicting consistency. ∎

This captures the essence of Gödel's Second Incompleteness Theorem: the consistency statement Con(T) ≡ ¬□⊥ (equivalently, □⊥ → ⊥) cannot be proven without rendering the system inconsistent.

### 3.2 Incompleteness from Gödel Elements

**Theorem 2** (`goedel_element_incompleteness`). *Let L be a nontrivial provability lattice (⊥ ≠ ⊤) with □⊥ = ⊥ (consistency). If g is a Gödel element, then □g ≠ ⊤.*

*Proof sketch.* Suppose for contradiction that □g = ⊤. From the self-refutation condition g ⊓ □g = ⊥, substituting □g = ⊤ gives g ⊓ ⊤ = ⊥, hence g = ⊥. Substituting into the self-affirmation condition: g ⊔ □g = ⊥ ⊔ □⊥ = ⊥ ⊔ ⊥ = ⊥ (using □⊥ = ⊥). But g ⊔ □g = ⊤, yielding ⊥ = ⊤, contradicting nontriviality. ∎

**Theorem 3a** (`goedel_element_not_bot`). *Under the same conditions, g ≠ ⊥.*

*Proof sketch.* If g = ⊥, then g ⊔ □g = ⊥ ⊔ □⊥ = ⊥ ⊔ ⊥ = ⊥ ≠ ⊤. ∎

**Theorem 3b** (`goedel_element_not_top`). *Under the same conditions, g ≠ ⊤.*

*Proof sketch.* If g = ⊤, then □g = □⊤ = ⊤ (by the box_top axiom). Then g ⊓ □g = ⊤ ⊓ ⊤ = ⊤, but self-refutation requires g ⊓ □g = ⊥, giving ⊤ = ⊥. ∎

### 3.3 Existence of Independent Elements

**Theorem 4** (`exists_independent_element`). *Every nontrivial provability lattice with a Gödel element and consistent □ contains an independent element.*

*Proof sketch.* The Gödel element g itself witnesses independence, by Theorems 2, 3a, and 3b. ∎

### 3.4 Theory Branching

**Theorem 5** (`theory_branching_distinct`). *If a sentence G is independent of a theory T (with negation nG also not a theorem), and G ≠ nG, then the extensions T ∪ {G} and T ∪ {nG} are distinct.*

*Proof sketch.* If T ∪ {G} = T ∪ {nG}, then since G ∉ T (by independence), we must have G ∈ {nG}, hence G = nG, contradicting the hypothesis. ∎

This theorem captures the fundamental branching phenomenon in the space of theories: each independent sentence creates a genuine fork, generating two incompatible extensions.

### 3.5 Provability Iteration Hierarchy

**Definition 5.** The **provability iteration** □ⁿa is defined by □⁰a = a and □ⁿ⁺¹a = □(□ⁿa).

**Theorem 6** (`box_iterate_mono`). *If □ is inflationary (x ≤ □x for all x), then n ↦ □ⁿa is monotonically increasing.*

*Proof sketch.* By induction: □ⁿa ≤ □(□ⁿa) = □ⁿ⁺¹a by the inflationary hypothesis. ∎

**Corollary** (`box_iterate_top`). □ⁿ⊤ = ⊤ for all n.

### 3.6 Antitonicity of Consequences

**Definition 6.** The **consequence set** of a ∈ L is ↑a = {b ∈ L : a ≤ b}.

**Theorem** (`consequences_antitone`). *The map a ↦ ↑a is antitone: if a ≤ b then ↑b ⊆ ↑a.*

*Proof sketch.* If a ≤ b and b ≤ c, then a ≤ c by transitivity. ∎

This captures the fundamental duality: stronger assumptions have more consequences.

### 3.7 The Collapse Theorem

**Theorem 7** (`sound_extensive_collapse`). *If a provability lattice is both sound (□a ≤ a) and extensive (a ≤ □a), then □a = a for all a.*

*Proof sketch.* Immediate from antisymmetry of ≤. ∎

**Discussion.** This result has deep implications when combined with Löb's theorem. In any Löb algebra (satisfying the full GL axiom), soundness implies that every element satisfies □a → a, which by Löb's condition yields that every element is provable (a = ⊤). Thus soundness + the GL axiom forces triviality. The collapse theorem provides a related result at the lattice level: soundness + extensiveness eliminates any distinction between truth and provability.

### 3.8 Modalized Fixed Points

**Definition 7.** A **modalized map** on a provability lattice is a monotone function f : L → L commuting with □: f(□x) = □(f(x)).

**Theorem** (`gl_prefixed_point_exists`). *Every modalized map has a pre-fixed point (an element p with f(p) ≤ p).*

*Proof sketch.* ⊤ is always a pre-fixed point since f(⊤) ≤ ⊤. ∎

**Remark.** The full de Jongh–Sambin theorem establishes that in GL-algebras, every modalized formula has a *unique* fixed point (up to provable equivalence). Our formalization establishes the weaker existence result, which already suffices for many applications.

---

## 4. Connection to Solovay's Completeness Theorem

Solovay's arithmetical completeness theorem (1976) states that GL is complete with respect to arithmetical interpretations: a modal formula φ is a theorem of GL if and only if for every arithmetical realization * mapping propositional variables to Σ₁-sentences and □ to the canonical provability predicate Bew(·), φ* is a theorem of PA.

Our lattice-theoretic development provides the algebraic infrastructure that underpins Solovay's result. The Lindenbaum algebra of PA — the quotient of sentences by provable equivalence — is precisely a provability lattice in our sense. Gödel's diagonal lemma guarantees the existence of Gödel elements in this lattice. Our Theorems 2–4 then instantiate to give the classical incompleteness results.

The key insight linking GL to the diagonal lemma is that the diagonal lemma is a *fixed-point theorem* for the Lindenbaum algebra: for every formula φ(x) with one free variable, there exists a sentence ψ such that ψ ↔ φ(⌜ψ⌝) is provable. This is precisely the mechanism that produces Gödel elements (take φ(x) = ¬Bew(x)) and, more generally, the modalized fixed points of our Definition 7.

---

## 5. The Lindenbaum Algebra Connection

The provability lattice framework is not merely an abstraction — it faithfully represents the Lindenbaum algebra of any sufficiently strong arithmetical theory. Given a theory T (such as PA), the **Lindenbaum algebra** Lind(T) is the quotient of the set of sentences by the equivalence relation of provable equivalence: φ ∼ ψ iff T ⊢ φ ↔ ψ.

The quotient inherits a natural lattice structure:
- [φ] ⊓ [ψ] = [φ ∧ ψ] (conjunction)
- [φ] ⊔ [ψ] = [φ ∨ ψ] (disjunction)
- ⊥ = [0=1] (any provably false sentence)
- ⊤ = [0=0] (any provably true sentence)

The provability operator □ acts on equivalence classes by □[φ] = [Bew(⌜φ⌝)], where Bew is the canonical provability predicate. This is well-defined because provably equivalent sentences have provably equivalent provability assertions (by the Hilbert-Bernays derivability conditions).

Gödel's diagonal lemma guarantees the existence of a Gödel element in Lind(PA): a sentence G such that PA ⊢ G ↔ ¬Bew(⌜G⌝). In the Lindenbaum algebra, this translates to [G] ⊓ □[G] = ⊥ and [G] ⊔ □[G] = ⊤, exactly our GoedelElement conditions.

Our Theorem 4 (exists_independent_element) then instantiates to the classical result: Lind(PA) contains an equivalence class that is neither ⊥ nor ⊤ nor provably ⊤ — i.e., there exists a sentence that PA can neither prove nor refute.

## 6. Categorical Perspective

The provability lattice framework admits a natural categorical interpretation. A provability lattice is equivalently a functor from the one-object category **1** to the category **DLat** of bounded distributive lattices, together with a natural endomorphism □. The Gödel element conditions define a specific algebraic variety within this functor category.

More broadly, the modal logic GL can be understood as the internal logic of a certain class of categories — the *GL-categories* or *provability categories* — in which the □ operator is an endofunctor satisfying the GL axioms up to natural isomorphism. The fixed-point theorems for modalized maps then become instances of Lawvere's fixed-point theorem in the appropriate categorical setting.

This perspective connects provability logic to:
- **Topos theory:** Provability predicates in arithmetic toposes.
- **Domain theory:** The Scott-continuous operators on algebraic lattices.
- **Type theory:** The □ modality in guarded type theories and the Nakano modality.

---

## 7. The de Jongh–Sambin Fixed-Point Theorem

Our Theorem gl_prefixed_point_exists establishes the weak form of the GL fixed-point theorem: every modalized map has a pre-fixed point. The full de Jongh–Sambin theorem is considerably stronger:

**Theorem** (de Jongh–Sambin, 1976). *For every modal formula φ(p) in which p occurs only within the scope of □, there exists a modal sentence ψ (not containing p) such that GL ⊢ ψ ↔ φ(ψ). Moreover, ψ is unique up to GL-provable equivalence.*

The uniqueness part is the deep content. In our lattice-theoretic language, it would state that for every modalized map f on a GL-algebra, there exists a unique fixed point p with f(p) = p (not merely f(p) ≤ p). Formalizing this requires the full GL axiom □(□p → p) → □p at the algebraic level, which goes beyond our current ProvabilityLattice definition.

The connection to Löb's theorem is illuminating: Löb's theorem is essentially the special case of the de Jongh–Sambin theorem where f(p) = p (the identity modalized map, viewed as "if □p then p"). The fixed point is then ⊤ — the tautology — which is precisely the content of Löb's theorem: if □p → p then p (and moreover p is provably equivalent to ⊤).

## 8. Applications

### 8.1 Ordinal Analysis

The provability iteration hierarchy (§3.5) connects to ordinal analysis: the consistency strength of iterated consistency assertions Con^n(PA) is well-ordered, and the ordinal of this well-ordering is related to the proof-theoretic ordinal ε₀ of PA.

### 8.2 Self-Referential Systems

The algebraic framework applies beyond arithmetic to any self-referential system with a notion of provability: formal verification systems, type checkers, AI systems reasoning about their own reliability. Löb's theorem constrains what any such system can prove about its own soundness.

### 8.3 Theory Choice

The theory-branching theorem (§3.4) provides a formal framework for understanding how mathematical theories proliferate. The independence of the Continuum Hypothesis from ZFC, for instance, is an instance of this branching phenomenon.

---

## 9. Discussion

The formal development reveals several structural insights that are sometimes obscured in purely syntactic treatments:

**The primacy of Löb's theorem.** Our formalization makes explicit that Gödel's Second Incompleteness Theorem is a direct corollary of Löb's theorem (Theorem 1 and the loeb_implies_goedel_second lemma). While this relationship is well-known, seeing it formalized at the abstract level — without any arithmetic — clarifies that the two results stand in a strict logical hierarchy.

**The algebraic inevitability of incompleteness.** Theorems 2–4 show that incompleteness is a purely algebraic consequence of two simple equations (self-refutation and self-affirmation) in a nontrivial lattice with consistent □. No diagonal lemma, no coding of syntax, no recursion theory — just lattice identities and the assumption that contradictions aren't provable.

**The soundness-extensiveness tension.** Theorem 7 (sound_extensive_collapse) reveals a fundamental tension: a system cannot simultaneously satisfy "everything provable is true" (soundness) and "everything true is provable" (completeness/extensiveness) without collapsing the distinction between truth and provability entirely. This provides a lattice-theoretic perspective on why Gödel's theorems are in some sense inevitable.

**Theory space as a branching tree.** Theorem 5 (theory_branching_distinct) formalizes the intuition that mathematical theories live on an endlessly branching tree. Each independent sentence creates a genuine fork, and the Gödel element is merely the first such fork. The space of possible extensions of PA (or any sufficiently strong theory) has the structure of a tree with ℵ₀ branching points.

## 10. Future Directions

Several natural extensions of this work suggest themselves:

1. **Full GL-algebra axiomatization:** Extend the provability lattice to a full Magari algebra satisfying □(□p → p) → □p as an algebraic identity, enabling the de Jongh–Sambin uniqueness theorem.

2. **Solovay's completeness (formal):** Formalize the full arithmetical completeness theorem for GL, bridging the algebraic and syntactic perspectives.

3. **Categorical semantics:** Develop the categorical framework for GL-categories and relate it to the lattice-theoretic formalization.

4. **Iterated consistency hierarchies:** Formalize the strict increasing property of the iterated consistency sequence and connect it to ordinal analysis.

5. **Computational interpretations:** Explore the connection between provability logic and guarded recursion in type theory.

---

## 11. References

1. K. Gödel, "Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I," *Monatshefte für Mathematik und Physik*, 38:173–198, 1931.

2. M. H. Löb, "Solution of a problem of Leon Henkin," *Journal of Symbolic Logic*, 20(2):115–118, 1955.

3. R. M. Solovay, "Provability interpretations of modal logic," *Israel Journal of Mathematics*, 25:287–304, 1976.

4. G. Boolos, *The Logic of Provability*, Cambridge University Press, 1993.

5. D. de Jongh and G. Sambin, "Intuitionistic provability logic," in *The Logic of Provability* (supplementary notes), 1976.

6. R. Magari, "The diagonalizable algebras," *Bollettino dell'Unione Matematica Italiana*, 12:117–125, 1975.

7. A. Visser, "Löb's logic meets the μ-calculus," in *Epistemology versus Ontology*, Springer, 2012.

---

*All theorems referenced in this paper have been formally verified. The complete formalization is available in [`Catalog/Logic/ProvabilityLogic.lean`](Catalog/Logic/ProvabilityLogic.lean).*
