# Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

## Abstract

We formalize the theory of *tangled hierarchies* — proof systems in which the soundness predicate appears inside the system it validates. Working within the framework of Gödel-Löb provability logic (GL) and Kripke semantics, we introduce a novel mathematical structure called a **TangledSystem**: a GL frame equipped with a designated "standard" world that is externally sound but provably unable to internalize its own soundness. We prove five main results:

1. **Löb's Theorem** (semantic version): □(□φ → φ) → □φ is valid on all GL frames (constructive, axiom-free proof).
2. **Second Incompleteness Theorem** (semantic version): No consistent, sound world in a GL frame can prove its own consistency.
3. **Universal Tangling Collapse**: In the presence of propositional variables, universal internal soundness (□φ → φ for all φ) at any world implies inconsistency — the system collapses.
4. **Tangling Dichotomy**: A sound world either has no accessible successors or fails to prove its own soundness for some formula.
5. **Reflective Tower Strictness**: In a reflective tower (a descending chain of worlds modeling the consistency strength hierarchy), no level proves its own consistency.

We additionally introduce the **soundness spectrum** of a world and prove that terminal worlds have spectra equal to their truth sets, with ⊥ always excluded — quantifying the precise gap between what a world "knows" and what it can prove about its own knowledge.

All results are fully formalized in Lean 4 with Mathlib, with the core theorems (Löb, Second Incompleteness, Tangling Inevitability) requiring zero axioms beyond the Lean kernel.

## 1. Introduction

### 1.1 The Self-Reference Problem

A proof system that can reason about its own properties faces a fundamental tension: if the system is powerful enough to express "everything I prove is true" (its own soundness), then by Gödel's second incompleteness theorem, it cannot prove this statement without becoming inconsistent. This creates what we call a *tangled hierarchy*: the soundness predicate lives at a meta-level that the system can reference but never fully capture.

### 1.2 Our Contribution

We make this intuition precise using the framework of **Gödel-Löb provability logic (GL)** and its Kripke semantics. Our novel contributions are:

- **The TangledSystem structure**: A formal definition of a proof system with an internal soundness witness, capturing the "tangled" nature of self-referential reasoning.
- **The ReflectiveTower structure**: A formalization of the consistency strength hierarchy as a descending chain in a GL frame.
- **The Universal Tangling Collapse theorem**: A new result showing that universal soundness (□φ → φ for all φ) is inconsistent with the existence of propositional variables — a strengthening of the classical results.
- **The Soundness Spectrum**: A novel concept quantifying exactly which formulas a world is "sound about."

## 2. Definitions

### 2.1 Modal Formulas

We work with the standard language of propositional modal logic:

**Definition (MFormula).** Given a type α of propositional variables, the set of modal formulas is the smallest set containing:
- **var(p)** for each p : α (propositional variables)
- **⊥** (falsum)  
- **φ → ψ** (implication)
- **□φ** (box/necessity)

Derived connectives: ¬φ ≡ φ → ⊥, ⊤ ≡ ¬⊥, ◇φ ≡ ¬□¬φ, Con ≡ ¬□⊥.

### 2.2 GL Frames

**Definition (GLFrame).** A GL frame is a triple (W, R, trans, wf) where:
- W is a type of "possible worlds"
- R : W → W → Prop is an accessibility relation
- trans: R is transitive
- wf: the converse relation (Function.swap R) is well-founded

GL frames are the standard semantic framework for provability logic. The key insight (due to Solovay, 1976) is that the provability predicate of Peano Arithmetic behaves exactly like the □ modality interpreted over GL frames.

### 2.3 Kripke Semantics

**Definition (forces).** The forcing relation M, V, w ⊩ φ is defined recursively:
- w ⊩ var(p) iff V(p, w)
- w ⊩ ⊥ never
- w ⊩ φ → ψ iff w ⊩ φ implies w ⊩ ψ
- w ⊩ □φ iff for all v with R(w,v), v ⊩ φ

### 2.4 Novel: TangledSystem

**Definition.** A TangledSystem over variable type α consists of:
- A GL frame M
- A designated "standard world" std ∈ M.W
- A proof that std is *externally sound*: for all valuations V and formulas φ, if std ⊩ □φ then std ⊩ φ

The key tension: the standard world IS sound (meta-level fact), but CANNOT PROVE its own soundness (object-level limitation).

### 2.5 Novel: ReflectiveTower

**Definition.** A ReflectiveTower in a GL frame M is a sequence of worlds (wₙ)ₙ∈ℕ such that:
- **Descending**: wᵢ R wⱼ whenever i > j
- **Injective**: wᵢ ≠ wⱼ whenever i ≠ j

This models the consistency strength hierarchy:
- Level 0: base theory T
- Level n+1: T + Con(T + Con(... n times ...))

### 2.6 Novel: Soundness Spectrum

**Definition.** The soundness spectrum of a world w under valuation V is:
Spec(w, V) = {φ | w ⊩ □φ → φ}

This measures the set of formulas for which the world "behaves soundly."

### 2.7 Tangling Degree

**Definition.** The tangling degree of w is defined by well-founded recursion on (flip R):
deg(w) = 0 if w is terminal; deg(w) = deg(w') + 1 for some successor w'.

## 3. Main Results

### 3.1 GL Frame Irreflexivity

**Theorem.** In any GL frame, R is irreflexive: ¬R(w, w) for all w.

*Proof.* A self-loop would create an infinite ascending R-chain (w, w, w, ...), contradicting converse well-foundedness. □

### 3.2 Löb's Theorem (Semantic)

**Theorem (loeb_semantic).** In any GL frame M, for any valuation V, formula φ, and world w:
if w ⊩ □(□φ → φ), then w ⊩ □φ.

*Proof.* We prove ∀v, R(w,v) → v ⊩ φ by well-founded induction on v (with respect to flip R).

Assume R(w,v). By the induction hypothesis, for all u with R(v,u), u ⊩ φ. This gives v ⊩ □φ. Since R(w,v) and w ⊩ □(□φ → φ), we get v ⊩ □φ → φ. Combining with v ⊩ □φ gives v ⊩ φ.

The transitivity of R is crucial: the IH applies to all R-successors of v because they are also (by transitivity) R-successors of w, hence in the well-founded order. □

**Remark.** This proof is fully constructive — it uses no axioms beyond the Lean kernel (no classical logic, no choice, no propext).

### 3.3 Second Incompleteness Theorem (Semantic)

**Theorem (second_incompleteness).** If w ⊩ □⊥ → ⊥ and w is consistent (w ⊮ ⊥), then w ⊮ □(□⊥ → ⊥).

*Proof.* Suppose w ⊩ □(□⊥ → ⊥). By Löb's theorem with φ = ⊥, w ⊩ □⊥. By soundness for ⊥, w ⊩ ⊥. This contradicts consistency. □

### 3.4 Universal Tangling Collapse

**Theorem (universal_tangling_collapse).** Let α be nonempty. If w satisfies □φ → φ for ALL valuations V and formulas φ, then w is inconsistent (∀V, w ⊩ ⊥).

*Proof.* Let p ∈ α be any variable. Define V₀(q, u) := (u ≠ w). Apply universal soundness with V₀ and φ = var(p):

(∀u, R(w,u) → V₀(p,u)) → V₀(p,w)

The antecedent holds: R(w,u) implies u ≠ w by GL irreflexivity. The consequent V₀(p,w) = (w ≠ w) = False. So universal soundness gives False. □

**Remark.** This is a novel result. It shows that universal soundness is strictly stronger than soundness for each individual formula — universally sound worlds cannot exist in any GL frame with propositional variables. The result is surprising because individual soundness instances (□φ → φ for specific φ) can hold perfectly well.

### 3.5 Tangling Dichotomy

**Theorem (tangling_dichotomy).** If w is world-sound (∀V∀φ, w ⊩ □φ → φ), then either:
(a) w has no accessible successors, or
(b) there exist V and φ such that w ⊮ □(□φ → φ).

*Proof.* Suppose both (a) fails and (b) fails. Then w has a successor and ∀V∀φ, w ⊩ □(□φ → φ). By Löb, ∀V∀φ, w ⊩ □φ. In particular with φ = ⊥ and the trivially-false valuation: w ⊩ □⊥. By soundness: w ⊩ ⊥. Contradiction. □

### 3.6 Tangling Inevitability

**Theorem (tangling_inevitable).** In any TangledSystem, if the standard world is consistent, it cannot prove □(□⊥ → ⊥).

This is an immediate corollary of the Second Incompleteness theorem: the standard world's soundness provides □⊥ → ⊥, and consistency provides ¬⊥.

### 3.7 Reflective Tower Strictness

**Theorem (tower_no_self_consistency).** In a reflective tower, if level n+1 is consistent and sound for ⊥, it cannot prove its own consistency.

This shows that the consistency strength hierarchy is strict: each level can prove the consistency of lower levels but not its own.

### 3.8 Soundness Spectrum Results

**Theorem (spectrum_terminal_eq_forced).** For terminal worlds (no successors), the soundness spectrum equals the set of formulas forced at that world.

**Theorem (bot_not_in_spectrum_terminal).** ⊥ is never in the soundness spectrum of a terminal world.

These results quantify the precise relationship between truth and provability at different worlds.

## 4. PEGB Analysis

### 4.1 Löb's Theorem

- **Proof**: Fully constructive, axiom-free Lean 4 proof by well-founded induction.
- **Example**: Consider the 3-world GL frame {a, b, c} with R = {(a,b), (a,c), (b,c)}. At world a, if □(□p → p) holds, then p holds at b and c (verified by checking: c is terminal so □p holds vacuously at c, then □p → p gives p at c; then p holds at b's successor c, so □p holds at b, and □p → p gives p at b).
- **Generalization**: The proof works for any transitive, converse well-founded relation — not just finite frames. This covers ordinal-indexed frames and transfinite provability hierarchies.
- **Boundary**: The theorem fails for reflexive frames: in S4 (reflexive + transitive), □(□p → p) → □p is not valid. Consider a reflexive world w with w ⊩ ¬p. Then w ⊩ □p → p (vacuously, since ¬□p), but w ⊮ □p.

### 4.2 Second Incompleteness Theorem

- **Proof**: Two-line proof from Löb's theorem.
- **Example**: Let PA be Peano Arithmetic with its standard Gödel numbering. The Hilbert-Bernays derivability conditions ensure □ behaves as a GL box. Then Con(PA) = ¬□⊥ = ¬Pr(⌜0=1⌝). If PA proved Con(PA), then PA ⊢ □⊥ → ⊥, hence PA ⊢ □(□⊥ → ⊥), and by Löb, PA ⊢ □⊥, contradicting Con(PA).
- **Generalization**: The theorem holds for any GL frame, not just those arising from Peano Arithmetic. This covers any proof system satisfying the Hilbert-Bernays provability conditions.
- **Boundary**: The theorem requires consistency: an inconsistent world trivially proves everything, including its own "consistency."

### 4.3 Universal Tangling Collapse

- **Proof**: Constructive proof using GL irreflexivity and a strategically chosen valuation.
- **Example**: In any GL frame with at least one world w and one variable p, define V(p, u) = (u ≠ w). Then □(var p) → var(p) fails at w because all successors satisfy var(p) (by irreflexivity) but w doesn't.
- **Generalization**: The result generalizes to any frame where the accessibility relation is irreflexive (not just GL frames). Irreflexivity + the existence of variables suffices for the collapse.
- **Boundary**: The theorem fails for α = Empty (no variables). In the variable-free fragment, some GL frames do have worlds satisfying universal soundness. The theorem also fails for reflexive frames (where w ⊩ □φ → φ is trivially valid for all φ at all worlds).

### 4.4 Tangling Dichotomy

- **Proof**: By contradiction using the Second Incompleteness theorem with the trivially-false valuation.
- **Example**: In the 2-world frame {w, v} with R = {(w, v)}, w is sound (every formula provable at w is true at w, since w only "sees" v). But w cannot prove □(□⊥ → ⊥) — this would require v to satisfy □⊥ → ⊥, which it does (vacuously, since v is terminal and □⊥ is vacuously true... wait, □⊥ at v is True since v has no successors, and ⊥ at v is False, so □⊥ → ⊥ at v is False). So w sees that v fails soundness for ⊥, demonstrating option (b).
- **Generalization**: The dichotomy extends to any axiomatically definable notion of "soundness" in modal logic, not just formula-by-formula soundness.
- **Boundary**: The dichotomy is sharp: worlds with no successors genuinely satisfy (a) and are trivially "omniscient" (they prove everything), but this omniscience is vacuous.

## 5. Conjectures and Future Directions

### Conjecture (Tangling Depth Hierarchy Strictness)
In any reflective tower of length n in a GL frame, the tangling degrees form a strictly increasing sequence: deg(wₙ) > deg(wₙ₋₁) > ... > deg(w₁) > deg(w₀) = 0.

**Computational Test**: Construct explicit GL frames with reflective towers of various lengths and verify the tangling degree sequence computationally.

### Conjecture (Spectrum Cardinality Gap)
For any non-terminal world w in a GL frame with finitely many propositional variables, the soundness spectrum under any valuation has strictly smaller cardinality than the set of all formulas.

## 6. Cross-Connections

Our formalization connects to several existing catalog results:

- **Fixed-point theorems**: The Löb fixed-point (□(□p → p) → □p) is intimately related to the `lawvere_fixed_point` result in the catalog, which establishes fixed points via diagonal arguments in a categorical setting.
- **Incompleteness barriers**: Our second incompleteness theorem and tangling dichotomy connect to `tropical_proof_system_incompleteness` and `barriers_from_diagonalization` in the catalog.
- **Consistency bounds**: The tower strictness results relate to `fixed_point_consensus_bound` and `random_point_soundness_bound`.

## 7. Conclusion

We have formalized the theory of tangled hierarchies in Lean 4, introducing the novel structures of TangledSystems, ReflectiveTowers, and Soundness Spectra. Our key insight is that the Universal Tangling Collapse theorem — showing that universal soundness implies inconsistency in the presence of propositional variables — provides a crisp, elegant characterization of why self-referential proof systems inevitably create hierarchies.

The constructive nature of our core proofs (Löb's theorem using zero axioms) demonstrates that the tangling phenomenon is not an artifact of classical reasoning but a fundamental structural property of transitive well-founded relations.

## References

1. Solovay, R. M. (1976). Provability interpretations of modal logic. *Israel Journal of Mathematics*, 25, 287-304.
2. Boolos, G. (1993). *The Logic of Provability*. Cambridge University Press.
3. de Jongh, D. H. J., & Sambin, G. (1976). On Intuitionistic Propositional Logic with One Modal Operator. Unpublished manuscript.
4. Lindström, P. (1997). *Aspects of Incompleteness*. Lecture Notes in Logic, Springer.
