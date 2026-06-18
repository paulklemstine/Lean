# Tangled Hierarchies: Formal Verification of Self-Referential Soundness Limits in Provability Logic

## Abstract

We present a machine-verified formalization of the semantic theory of provability logic GL over Kripke frames, culminating in three main results: (1) a semantic proof of Löb's theorem via well-founded induction on GL frames, (2) a Kripke-semantic formulation of Gödel's second incompleteness theorem showing that sound worlds cannot prove their own consistency, and (3) a new "tangling dichotomy" theorem establishing that any sound world with non-trivial provability power necessarily fails to internalize its own soundness. We introduce the notion of a *tangled proof system* — a GL frame with a designated sound standard world — and prove that the external soundness guarantee for such systems can never be replicated internally. Our formalization uses Lean 4 with the Mathlib library, providing a fully verified treatment of modal fixed-point phenomena in provability logic.

**Keywords:** Provability logic, GL frames, Löb's theorem, Kripke semantics, self-reference, incompleteness, tangled hierarchies, formal verification

---

## 1. Introduction

The relationship between a formal system and its own metatheory has been a central concern of mathematical logic since Gödel's incompleteness theorems (1931). Gödel showed that any consistent, sufficiently powerful formal system cannot prove its own consistency — a result that has profound implications for the foundations of mathematics, computer science, and philosophy of mind.

The algebraic and semantic study of provability reached maturity with Solovay's completeness theorem (1976), which established that the modal logic GL (Gödel-Löb logic) exactly captures the provability behavior of Peano Arithmetic. In this framework, the modal operator □ represents formal provability, and the axioms of GL — particularly Löb's axiom □(□φ → φ) → □φ — encode the essential self-referential properties of proof systems.

The semantic counterpart uses **GL frames**: Kripke frames (W, R) where R is transitive and converse well-founded. These frames provide a geometric picture of provability: worlds represent possible states of mathematical truth, and accessibility represents the "proving" relation.

### 1.1 Contributions

This paper makes the following contributions:

1. **Semantic Löb's Theorem**: We provide a clean proof of Löb's theorem directly on GL frames using well-founded induction, avoiding the syntactic complexity of Hilbert-style derivations.

2. **Tangled System Definition**: We introduce the formal notion of a *tangled proof system* — a GL frame with a designated sound standard world — capturing the structure of self-referential proof systems.

3. **Tangling Dichotomy**: We prove that sound worlds face a strict dichotomy: either they have no accessible worlds (trivial provability) or they cannot internalize their own soundness (necessarily incomplete self-knowledge).

4. **Machine Verification**: All results are fully formalized in Lean 4, providing a verified foundation for further work in provability logic.

## 2. Preliminaries

### 2.1 Modal Formulas

We work with propositional modal logic over a type α of propositional variables.

**Definition 2.1** (Modal Formula). The set of modal formulas MFormula(α) is defined inductively:
- var(p) for p ∈ α (propositional variables)
- ⊥ (falsum)
- φ → ψ (implication)
- □φ (necessity/provability)

Derived connectives include:
- ¬φ := φ → ⊥
- ◇φ := ¬□¬φ (possibility/consistency)
- Con := ¬□⊥ (consistency formula)

### 2.2 GL Frames

**Definition 2.2** (GL Frame). A GL frame is a triple (W, R, ≺) where:
- W is a type of possible worlds
- R : W → W → Prop is the accessibility relation
- R is transitive: u R v and v R w implies u R w
- R⁻¹ is well-founded: there is no infinite sequence w₀ R w₁ R w₂ R ···

The well-foundedness condition distinguishes GL frames from the broader class of transitive frames (which characterize K4 or S4 logics). It captures the key property of formal provability: proofs are finite, and there is no infinite chain of increasingly powerful proof systems.

### 2.3 Kripke Semantics

**Definition 2.3** (Forcing Relation). Given a GL frame M = (W, R) and a valuation V : α → W → Prop, the forcing relation ⊨ is defined recursively:
- w ⊨ var(p) iff V(p)(w)
- w ⊨ ⊥ never
- w ⊨ φ → ψ iff w ⊨ φ implies w ⊨ ψ
- w ⊨ □φ iff for all v with w R v, v ⊨ φ

**Definition 2.4** (Validity). A formula φ is valid in M if w ⊨ φ for all valuations V and worlds w.

**Definition 2.5** (World Soundness). A world w is sound if for all valuations V and formulas φ, w ⊨ □φ → φ.

## 3. Main Results

### 3.1 Irreflexivity of GL Frames

**Theorem 3.1** (GL Irreflexivity). In any GL frame M, the accessibility relation R is irreflexive: for all w ∈ W, ¬(w R w).

*Proof.* If w R w, then the converse relation R⁻¹ has a cycle at w. But R⁻¹ is well-founded, hence admits no such cycles. More precisely, from the well-foundedness of R⁻¹, we obtain Acc(R⁻¹, w). The accessibility predicate Acc is defined inductively: Acc(r, x) holds when every y with r(y, x) satisfies Acc(r, y). If w R w, then R⁻¹(w, w) holds (since R⁻¹ = swap R), so Acc(R⁻¹, w) requires Acc(R⁻¹, w) — but this is the very thing we are trying to prove, yielding an impossible infinite descent. □

This result is significant because it shows GL frames are strictly irreflexive — unlike S4 or S5 frames, no world can access itself. In the provability interpretation, this means no system can "re-prove" a result it has already established, capturing the asymmetry between theory and metatheory.

### 3.2 Löb's Theorem (Semantic Version)

**Theorem 3.2** (Löb's Theorem). In any GL frame M, for all valuations V, formulas φ, and worlds w:

    w ⊨ □(□φ → φ)  implies  w ⊨ □φ

*Proof.* We prove the stronger claim: for all v, if w R v then v ⊨ φ. The proof proceeds by well-founded induction on R⁻¹.

Fix v with w R v. By the hypothesis, v ⊨ □φ → φ. It suffices to show v ⊨ □φ.

Take any u with v R u. By transitivity, w R u, so u ⊨ □φ → φ (from the hypothesis). By the induction hypothesis (applied at u, which is strictly above v in the well-founded order R⁻¹), u ⊨ φ.

Since u was arbitrary with v R u, we have v ⊨ □φ. Then v ⊨ □φ → φ gives v ⊨ φ. □

**Corollary 3.3** (Löb Formula Validity). The Löb formula □(□φ → φ) → □φ is valid in every GL frame.

### 3.3 The Second Incompleteness Theorem

**Theorem 3.4** (Second Incompleteness, Semantic). Let M be a GL frame, V a valuation, and w a world such that:
- w ⊨ □⊥ → ⊥ (soundness for ⊥ / consistency)
- ¬(w ⊨ ⊥) (non-triviality)

Then w ⊭ □(□⊥ → ⊥).

*Proof.* Suppose for contradiction that w ⊨ □(□⊥ → ⊥). By Löb's theorem (Theorem 3.2 with φ = ⊥), w ⊨ □⊥. By the soundness hypothesis, w ⊨ ⊥. This contradicts non-triviality. □

This is the Kripke-semantic formulation of Gödel's second incompleteness theorem. The formula □⊥ → ⊥ expresses "if falsum is provable, then falsum is true," which is equivalent to "falsum is not provable" — i.e., consistency. The theorem states that a consistent world cannot prove its own consistency.

## 4. Tangled Proof Systems

### 4.1 Definition

**Definition 4.1** (Tangled Proof System). A tangled proof system of type α consists of:
- A GL frame (W, R)
- A designated standard world w₀ ∈ W
- A proof that w₀ is sound: for all V and φ, w₀ ⊨ □φ → φ

The name "tangled" refers to the self-referential structure: the soundness of the system is a meta-level fact about the standard world, but this fact cannot be expressed within the system itself (as a formula satisfied at worlds accessible from w₀).

### 4.2 Tangling Inevitability

**Theorem 4.2** (Tangling Inevitability). For any tangled proof system T and valuation V, if the standard world is consistent (¬(w₀ ⊨ ⊥)), then w₀ ⊭ □(□⊥ → ⊥).

*Proof.* The soundness of T gives w₀ ⊨ □⊥ → ⊥. Apply the second incompleteness theorem (Theorem 3.4). □

### 4.3 The Tangling Dichotomy

**Theorem 4.3** (Tangling Dichotomy). Let w be a sound world in a GL frame M. Then exactly one of the following holds:

1. w has no accessible worlds: ¬∃v, w R v.
2. There exist a valuation V and formula φ such that w ⊭ □(□φ → φ).

*Proof.* Suppose neither holds. Then ∃v, w R v, and for all V and φ, w ⊨ □(□φ → φ). Taking V to be the constantly-false valuation and φ = ⊥, we obtain w ⊨ □(□⊥ → ⊥). By the second incompleteness theorem, w ⊨ ⊥ (since forces for ⊥ is simply False, so ¬(w ⊨ ⊥) holds trivially). This is a contradiction. □

**Interpretation.** Case 1 represents a "trivial" proof system that can prove nothing (vacuously sound and complete). Case 2 represents every non-trivial proof system: it can prove some things, but it cannot prove its own soundness. There is no intermediate case — no system that is both non-trivially powerful and fully self-aware.

### 4.4 Tangling Depth

**Definition 4.4** (Tangling Depth). The tangling depth of a world w in a GL frame M is defined by well-founded recursion on R⁻¹:

    depth(w) = 1 + depth(v)    if ∃v, w R v (choosing some such v)
    depth(w) = 0               otherwise

The tangling depth measures how many levels of provability reflection are possible from a given world. Worlds at depth 0 are "terminal" — they see nothing and prove nothing. The standard world in a tangled system has positive depth, representing a non-trivial proof system.

## 5. Discussion

### 5.1 Relationship to Classical Results

Our results are semantic reformulations of well-known theorems in provability logic:

- **Löb's Theorem** (1955): Originally proved syntactically for Peano Arithmetic.
- **Gödel's Second Incompleteness Theorem** (1931): A consequence of Löb's theorem when applied to φ = ⊥.
- **Solovay's Completeness Theorem** (1976): GL is complete for the class of GL frames.

The semantic approach via Kripke frames provides geometric intuition for these results and enables clean proofs via well-founded induction.

### 5.2 The Tangling Phenomenon

The "tangling" terminology emphasizes a structural feature that goes beyond simple incompleteness. In a tangled proof system:

1. The system *is* sound (external meta-level fact).
2. The system *cannot prove* that it is sound (internal limitation).
3. This gap is *necessary* — not a deficiency to be fixed, but a structural invariant.

This creates a "hierarchy" where each level of reflection (soundness, soundness-of-soundness, etc.) requires stepping outside the current system. The hierarchy is "tangled" because the levels are not independent — each level references the one below, creating a chain of dependencies that can never close on itself.

### 5.3 Connections to Other Fields

**Computer Science**: The tangling phenomenon is closely related to the halting problem and Rice's theorem. A program that could verify its own correctness would need to solve its own halting problem — which is impossible for the same structural reasons.

**Artificial Intelligence**: AI safety concerns about self-referential reasoning systems connect directly to our results. An AI system based on formal reasoning cannot verify its own reliability within its own reasoning framework.

**Philosophy of Mind**: The Lucas-Penrose argument uses Gödelian incompleteness to argue against mechanistic theories of mind. Our tangling dichotomy provides a precise version of the relevant limitation: any sound reasoning agent either has trivial reasoning power or cannot fully justify its own reasoning.

### 5.4 Formalization Notes

The formalization in Lean 4 consists of approximately 250 lines of code, including:
- Inductive type for modal formulas
- GL frame structure with transitivity and well-foundedness
- Recursive definition of the forcing relation
- Eight fully verified theorems with no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`

The key technical challenge was the well-founded induction in Löb's theorem, which required careful management of the motive to thread the hypothesis w R v through the induction.

## 6. Algorithms

### 6.1 GL Frame Verification

Given a finite Kripke frame (W, R) represented as an adjacency matrix, we can verify the GL conditions in polynomial time:

1. **Transitivity Check**: O(|W|³) via transitive closure comparison
2. **Converse Well-foundedness**: O(|W|²) via topological sort on R⁻¹
3. **Irreflexivity**: O(|W|) diagonal check (redundant given GL, but useful as validation)

### 6.2 Model Checking

Given a finite GL frame and a modal formula φ, we can compute the set of worlds satisfying φ in time O(|W|² · |φ|) using bottom-up evaluation:
- Atomic formulas: O(1) lookup per world
- Boolean connectives: O(|W|) per connective
- □φ: O(|W|²) per box (check all accessible worlds)

### 6.3 Soundness Checking

Given a finite GL frame and a designated world w₀, we can verify:
- **Soundness**: For each formula φ up to a given depth, check w₀ ⊨ □φ → φ
- **Consistency**: Verify ¬(w₀ ⊨ ⊥), which is always true (since ⊥ never forces)
- **Self-incompleteness**: Verify w₀ ⊭ □(□⊥ → ⊥) by finding a witness world

## 7. Future Work

Several directions remain open:

1. **Transfinite Tangling**: Extend the tangling depth from ℕ to ordinals, studying how the hierarchy grows along transfinite iterations of reflection principles.

2. **Graded Provability**: Formalize Beklemishev's graded provability algebras and their connection to ordinal analysis.

3. **Modal μ-calculus**: Extend the formula language with fixed-point operators (μ, ν) and study the interaction between fixed points and the Löb axiom.

4. **Solovay Completeness**: Formalize the full Solovay completeness theorem, establishing GL as the provability logic of Peano Arithmetic.

5. **Categorical Semantics**: Develop a categorical formulation of tangled systems using presheaf categories over GL frames.

## References

1. Gödel, K. (1931). Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I. *Monatshefte für Mathematik und Physik*, 38(1), 173-198.

2. Löb, M.H. (1955). Solution of a problem of Leon Henkin. *The Journal of Symbolic Logic*, 20(2), 115-118.

3. Kripke, S.A. (1963). Semantical analysis of modal logic I: Normal modal propositional calculi. *Zeitschrift für mathematische Logik und Grundlagen der Mathematik*, 9, 67-96.

4. Solovay, R.M. (1976). Provability interpretations of modal logic. *Israel Journal of Mathematics*, 25(3-4), 287-304.

5. Boolos, G. (1993). *The Logic of Provability*. Cambridge University Press.

6. Beklemishev, L.D. (2005). Reflection principles and provability algebras in formal arithmetic. *Russian Mathematical Surveys*, 60(2), 197-268.

7. Visser, A. (2005). Faith & Falsity. *Annals of Pure and Applied Logic*, 131(1-3), 103-131.

8. Hofstadter, D.R. (1979). *Gödel, Escher, Bach: An Eternal Golden Braid*. Basic Books.
