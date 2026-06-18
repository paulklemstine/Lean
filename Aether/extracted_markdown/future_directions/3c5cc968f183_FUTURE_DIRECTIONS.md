# Future Directions: Propositional Logic Metatheory

## 1. Completeness of the Hilbert System

The natural next step after soundness is **completeness**: every tautology is provable. This requires constructing maximal consistent extensions of theories (Lindenbaum's lemma) and building canonical models. The key insight is that the syntactic deduction theorem we proved makes Lindenbaum's lemma tractable — it reduces the extension step to a single disjunction. Why now? Our `syntactic_deduction` and `weakening` theorems provide the exact structural infrastructure needed for the inductive extension argument, and the `consistency` theorem gives the base case.

**Testable conjecture**: For any `φ : PropForm`, `IsTautology φ → Proves ∅ φ`. The proof should construct a maximal consistent set containing `neg φ` and derive a contradiction from the model it induces.

## 2. Compactness from Completeness

Once completeness is established, **propositional compactness** follows: if every finite subset of `Γ` has a model, then `Γ` has a model. The key insight is that compactness is equivalent to the statement "if `Γ ⊨ φ` then some finite `Δ ⊆ Γ` satisfies `Δ ⊨ φ`", and this follows from completeness since syntactic proofs are finite objects. Why now? The `Models` and `Proves` definitions are already set up to state and prove this, and the finite nature of `Proves` derivations is built into our inductive type.

**Testable conjecture**: `Models Γ φ → ∃ Δ : Finset PropForm, ↑Δ ⊆ Γ ∧ Models ↑Δ φ`.

## 3. Cut Elimination for Sequent Calculus

Define a Gentzen-style sequent calculus for propositional logic and prove **cut elimination**: any sequent derivation using the cut rule can be transformed into one without it. The key insight is that cut elimination is a syntactic normalization result — it corresponds to β-reduction in the Curry-Howard correspondence, and our Hilbert-style infrastructure can serve as a reference system for proving equivalence. Why now? The Hilbert system theorems provide a certified "backend" against which a sequent calculus can be verified, and the syntactic deduction theorem is the Hilbert-side analogue of the cut rule.

**Testable conjecture**: Define `SeqProves : List PropForm → PropForm → Prop` with structural rules and cut. Then show `SeqProvesCutFree Γ φ ↔ SeqProves Γ φ` where the cut-free variant omits the cut rule.

## 4. Interpolation Theorem

Craig's interpolation theorem states: if `Proves ∅ (imp φ ψ)`, then there exists a formula `θ` whose variables appear in both `φ` and `ψ` such that `Proves ∅ (imp φ θ)` and `Proves ∅ (imp θ ψ)`. The key insight is that interpolation can be proved by induction on cut-free sequent calculus proofs (connecting to Direction 3), or by a direct semantic argument using our Boolean evaluation. Why now? Our `eval`-based semantics provides the natural framework to define "variables of a formula" and verify the variable-containment condition, and soundness ensures the interpolant is meaningful.

**Testable conjecture**: `Proves ∅ (imp φ ψ) → ∃ θ, (vars θ ⊆ vars φ ∩ vars ψ) ∧ Proves ∅ (imp φ θ) ∧ Proves ∅ (imp θ ψ)` where `vars` extracts the set of variable indices.

## 5. Decision Procedure Certification

Formalize a resolution-based decision procedure for propositional satisfiability and prove it **sound and complete** with respect to our `eval` semantics. The key insight is that resolution can be viewed as a restricted form of cut in a clause-based sequent calculus, making it a natural specialization of Direction 3. Why now? Our `IsTautology` and `Models` definitions provide the correctness specification, and the `soundness` theorem ensures that any proof produced by the decision procedure corresponds to a genuine semantic fact. This bridges our logical metatheory directly to verified automated reasoning.

**Testable conjecture**: Define `resolve : List (List (ℕ × Bool)) → Bool` implementing unit propagation + resolution. Then prove `resolve clauses = true → ∀ v, ∃ c ∈ clauses, ∀ l ∈ c, evalLit v l = false` (unsatisfiability certificate).
