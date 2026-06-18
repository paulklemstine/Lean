# FUTURE DIRECTIONS: Temporal Gödel-Löb Logic (TGL)

## Synthesis

This cycle established the semantic foundations of Temporal Gödel-Löb Logic (TGL), a bimodal logic combining provability (□) and temporal persistence (■) over Kripke frames with two relations: a transitive, converse well-founded accessibility relation R (as in standard GL) and a reflexive, transitive temporal order T, connected by a persistence axiom (T w w' → R w' u → R w u, ensuring later worlds access subsets of earlier worlds' possibilities).

The central discovery is the **commutativity asymmetry**: □■A → ■□A is valid (forward commutativity — "if it's provable that A always holds, then A is always provable"), but ■□A → □■A fails (reverse commutativity — "if A is always provable" does NOT imply "it's provable that A always holds"). The 3-world counterexample reveals the structural reason: persistence constrains how R-successors relate across temporal transitions, but says nothing about how T-successors of R-successors relate to R-successors of T-successors. This is the fundamental gap between "temporal futures of proof-accessible worlds" and "proof-accessible worlds of temporal futures."

All four main theorems were proved constructively (the first three are axiom-free; the counterexample uses only propext, Classical.choice, and Quot.sound). The proofs are short and structurally transparent, confirming that TGL's semantic theory is well-behaved.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `löb_valid` | **proved** | Löb's axiom □(□A→A)→□A valid in all TGL frames — GL embeds faithfully into TGL |
| `box_temporal_monotone` | **proved** | □A → ■□A: provability is temporally monotone — proofs are permanent |
| `box_always_comm` | **proved** | □■A → ■□A: forward commutativity of □ and ■ — uses persistence + T-reflexivity |
| `always_box_comm_fails` | **proved (counterexample)** | ■□A ↛ □■A: reverse commutativity fails — fundamental asymmetry of TGL |

## Research Directions

### Direction 1: Church-Rosser Condition for Full Commutativity

**Hypothesis**: Adding the Church-Rosser condition ∀ w u u', R w u → T u u' → ∃ w', T w w' ∧ R w' u' to TGL frames makes ■□A → □■A valid, yielding a "confluent" TGL where □ and ■ fully commute.

**Test**: (1) Prove ■□A → □■A valid under Church-Rosser + persistence. (2) Show the Church-Rosser condition is independent of the base TGL axioms (construct a TGL frame violating it). (3) Investigate whether Church-Rosser TGL has the finite model property.

**Why now**: The 3-world counterexample from this cycle pinpoints exactly why reverse commutativity fails — the temporal successor u' of the R-successor u is not R-accessible from any T-successor of w. The Church-Rosser condition is the minimal additional axiom that closes this gap.

**The key insight is** that the commutativity asymmetry is entirely controlled by a single frame condition (Church-Rosser), making it a clean toggle between two distinct logics with different expressiveness.

**If true**: We get a complete characterization: TGL without CR has asymmetric commutativity, TGL with CR has symmetric commutativity. This gives a precise semantic knob for "how much temporal structure interacts with provability."

**If false**: The failure would reveal additional frame conditions needed beyond CR, suggesting the interaction between □ and ■ is more subtle than a simple confluence property.

### Direction 2: Finite Model Property and Decidability of TGL

**Hypothesis**: TGL has the finite model property: every TGL-satisfiable formula is satisfiable in a finite TGL frame.

**Test**: Adapt the filtration method from GL. Given a formula φ and a TGL model satisfying φ, construct a finite filtration by taking equivalence classes of worlds modulo subformulas of φ. Show the filtration inherits the TGL frame conditions (R-transitivity, R-cwf, T-reflexivity, T-transitivity, persistence). Conclude decidability.

**Why now**: The Kripke-semantic framework from this cycle is complete enough to support filtration arguments. The key challenge is showing that persistence survives filtration — this is non-obvious because filtration merges worlds, potentially disrupting the subset relationship between R-successors.

**The key insight is** that persistence (R w' ⊆ R w for T w w') is a monotonicity condition that should be preserved by filtration because filtration respects the subformula property, and persistence is testable on subformulas.

**If true**: TGL is decidable, opening the door to automated reasoning about temporal provability.

**If false**: The failure would identify a specific obstacle in the filtration (likely persistence), suggesting TGL might require tree-model-property arguments instead.

### Direction 3: Arithmetical Soundness of TGL

**Hypothesis**: TGL is arithmetically sound: if φ is TGL-valid, then the arithmetical interpretation of φ (with □ as Prov_PA and ■ as ∀t≥t₀) is true in the standard model of arithmetic.

**Test**: Define the arithmetical interpretation: □A maps to Prov_{PA}(⌜A*⌝) and ■A maps to ∀t ≥ t₀, A*(t). Verify each TGL axiom under this interpretation: (1) Löb's axiom follows from Löb's theorem in PA. (2) □A → ■□A follows from the Σ₁-completeness of Prov: if Prov(A) then ∀t, Prov(A) (provability is timeless). (3) □■A → ■□A follows from the monotonicity of PA-provability over time.

**Why now**: The semantic foundations from this cycle give us the exact list of principles to verify arithmetically. The temporal monotonicity theorem (□A → ■□A) already captures the informal argument "proofs are permanent."

**The key insight is** that the persistence axiom (T w w' → R w' u → R w u) is the semantic counterpart of Σ₁-completeness: provability in PA is Σ₁, hence absolute (preserved under extensions), which means later theories prove everything earlier theories prove.

**If true**: TGL is the correct propositional logic of temporal provability over PA, extending Solovay's completeness theorem for GL.

**If false**: The failure would identify which TGL principles go beyond what PA's provability predicate validates, revealing the gap between abstract temporal provability and concrete arithmetic.

### Direction 4: Temporal Löb Principle and Fixed Points

**Hypothesis**: The "temporal Löb principle" ■(■A → A) → ■A is valid in TGL frames where T is additionally converse well-founded (well-founded temporal regression).

**Test**: Prove the temporal Löb principle in Lean 4 by well-founded induction on T⁻¹, mirroring the proof of Löb's axiom for □. Then investigate: (1) Is T-cwf independent of the other TGL axioms? (2) Does adding T-cwf collapse TGL to something trivial? (3) What is the interaction between □-Löb and ■-Löb?

**Why now**: The Löb proof from this cycle (well-founded induction on R⁻¹) has an exact structural analog for T⁻¹. The question is whether having TWO Löb principles (one for each modality) creates interesting interactions or degeneracy.

**The key insight is** that Löb's axiom is purely a property of the well-foundedness of the underlying relation, so it can be "duplicated" for any well-founded modality. The novelty is in the interaction between two Löb operators.

**If true**: We get a "bimodal Löb logic" with rich fixed-point theory, potentially connecting to μ-calculus and game semantics.

**If false**: T-cwf combined with the other TGL axioms might force T to be trivial (equality), collapsing the temporal dimension.

### Direction 5: Temporal Provability and Self-Reference

**Hypothesis**: In TGL, the fixed-point formula P ↔ ◇ₜ□P ∧ ¬□P ("I will be provable in the future but am not provable now") is unsatisfiable in any TGL frame where T is also converse well-founded.

**Test**: Formalize the fixed-point using the de Jongh-Sambin fixed-point theorem for GL. Show that □P → ■□P (temporal monotonicity) combined with T-cwf forces any world satisfying ◇ₜ□P to eventually reach a world satisfying □P, from which □P propagates backward by T-cwf, contradicting ¬□P.

**Why now**: The temporal monotonicity theorem from this cycle is the crucial ingredient — it turns the temporal paradox from a philosophical puzzle into a precise mathematical claim about frame conditions.

**The key insight is** that temporal monotonicity (□A → ■□A) means provability can only increase over time, so "provable later but not now" requires T to admit infinite strictly ascending chains (contra T-cwf).

**If true**: The temporal paradox is genuinely refutable in TGL+T-cwf, confirming the concept's central claim.

**If false**: The paradox might be satisfiable in some TGL frames, revealing that temporal monotonicity alone is insufficient — additional conditions on the interaction of □ and ◇ₜ would be needed.
