# Future Directions: Proof-Theoretic Governance of Automated Mathematics

## 1. From Syntax Trees to Actual Proof Terms

**Hypothesis**: The ordinal depth framework extends naturally from the `ResearchExpr` calculus to the internal proof terms of an actual theorem prover (e.g., Lean's `Expr` type), yielding a meaningful complexity stratification of machine-generated proofs.

**Strategy**: Define a mapping `Lean.Expr → Ordinal` that assigns depth based on the proof's logical structure — counting universe polymorphism as iteration, dependent type formation as bridging, and large elimination as certification. Prove that proofs using only propositional logic and first-order quantification have depth below ω, while proofs requiring transfinite induction or higher-order constructions cross the threshold.

**Key Challenge**: Lean's kernel terms include reduction, so depth must be invariant under definitional equality. This likely requires quotienting by β/δ-reduction before measuring.

**Cross-Domain Connections**: Connects to the Curry-Howard correspondence (proofs as programs), cut-elimination complexity in sequent calculus, and the de Bruijn criterion for proof checking.

**Concrete Next Steps**:
- Formalize a fragment of Lean's `Expr` type (λ-terms with universes) and define depth on it.
- Prove that depth is invariant under β-reduction (or define it on normal forms).
- Show that simple type theory proofs have depth < ω, while System F proofs can reach ω.

---

## 2. Relating Ordinal Depth to Cut Rank

**Hypothesis**: The ordinal depth of a derivation in our calculus corresponds to the cut rank in Gentzen-style sequent calculus, and the threshold theorem (depth ≥ ω implies non-triviality) is a syntactic analogue of the cut-elimination ordinal bound.

**Strategy**: Embed a fragment of sequent calculus (propositional or first-order) into `ResearchExpr`, mapping the cut rule to `certify` and structural rules to `compose`/`bridge`. Prove that the image of cut-free proofs has depth < ω, while proofs with essential cuts (those that increase proof length super-exponentially upon elimination) have depth ≥ ω.

**Key Challenge**: The correspondence is not exact — `certify` introduces `ω^d` while cut-elimination ordinals are more nuanced (ε₀ for PA, Γ₀ for ATR₀). A faithful encoding requires matching the specific ordinal arithmetic.

**Cross-Domain Connections**: Directly connects to Gentzen's consistency program, ordinal analysis of subsystems of second-order arithmetic, and the Schwichtenberg-Wainer hierarchy.

**Concrete Next Steps**:
- Define a sequent calculus for propositional logic as an inductive type.
- Define a translation `SequentProof → ResearchExpr` mapping cuts to `certify`.
- Prove `depth (translate p) < ω ↔ p is cut-free` for the propositional fragment.
- Extend to first-order logic and relate to Gentzen's ε₀ bound.

---

## 3. Categorical Semantics of Derivational Depth

**Hypothesis**: The ordinal depth function defines a filtration on the category of derivations, making it a filtered category whose associated graded structure captures the complexity stratification.

**Strategy**: Define a category `Deriv` with `ResearchExpr` as objects and morphisms given by structural refinement (an expression `e₁` maps to `e₂` if `e₂` refines or extends `e₁`). The depth function becomes a functor `Deriv → Ordinal` (viewed as a category via ≤). Prove that the fiber categories `Deriv_{< θ}` (expressions of depth below threshold θ) form a chain of full subcategories, and that the inclusion functors preserve finite limits.

**Key Challenge**: Defining morphisms meaningfully — mere subexpression inclusion is too coarse, while full structural refinement may be undecidable.

**Cross-Domain Connections**: Connects to persistence in topological data analysis (where filtrations measure multi-scale structure), stratified categories in algebraic geometry, and the theory of rewriting systems.

**Concrete Next Steps**:
- Define a preorder on `ResearchExpr` by structural refinement.
- Prove that depth is monotone with respect to this preorder.
- Formalize the filtered category and prove that `Deriv_{< ω}` is equivalent to the trivial fragment.
- Define persistent homology-like invariants measuring how derivations appear/disappear across depth thresholds.

---

## 4. Completeness and Incompleteness for Bounded-Depth Fragments

**Hypothesis**: The fragment of derivations with depth < ω is "complete" in the sense that it can derive all consequences of its axioms within a fixed logical system, while the fragment with depth < ω·2 captures strictly more, creating a hierarchy analogous to the arithmetic hierarchy.

**Strategy**: Define a notion of "derivable at depth < θ" for a base theory (e.g., a simple equational theory). Prove that for each ordinal θ, there exist statements derivable at depth < θ + 1 but not at depth < θ (strict hierarchy). For the finite fragment (depth < ω), characterize exactly which statements are derivable.

**Key Challenge**: This requires a genuine logical completeness argument, not just syntactic counting. The connection between syntactic depth and logical strength must be made rigorous.

**Cross-Domain Connections**: Connects to the arithmetic hierarchy (Σ_n / Π_n classification), reverse mathematics (calibrating the proof-theoretic strength of mathematical statements), and descriptive complexity theory.

**Concrete Next Steps**:
- Define a base equational theory and its derivation relation.
- Prove that all equational consequences are derivable at depth < ω (completeness of the finitary fragment).
- Construct a statement requiring depth ≥ ω (e.g., consistency of the base theory, via a Gödel-like argument).
- Formalize the strict hierarchy: for each n, exhibit a statement derivable at depth ω·n but not at depth < ω·n.

---

## 5. Integration into Automated Proof Selection Pipelines

**Hypothesis**: The ordinal depth metric can serve as an effective filter in automated theorem proving pipelines, triaging conjectures by structural complexity and routing shallow conjectures to fast solvers while reserving expensive search for deep ones.

**Strategy**: Implement a pipeline that:
1. Parses a conjecture into a `ResearchExpr`-like structure (or computes depth directly from the proof term).
2. Computes the structural depth and innovation score.
3. Routes conjectures with depth < threshold to a fast tactic (e.g., `simp`, `omega`, `decide`).
4. Routes conjectures with depth ≥ threshold to a full proof search engine.
5. Logs the depth of successful proofs for calibration.

**Key Challenge**: The mapping from real proof terms to `ResearchExpr` must be computationally efficient and semantically meaningful. Depth must correlate with actual proof difficulty, not just syntactic complexity.

**Cross-Domain Connections**: Connects to portfolio solvers in SAT/SMT, machine learning for theorem proving (where depth could be a training signal), and resource-bounded proof search.

**Concrete Next Steps**:
- Build a prototype depth-aware proof triage system as a Lean metaprogram.
- Benchmark against a corpus of Mathlib lemmas: does depth correlate with proof length/search time?
- Define a formal interface (`DepthCertificate` structure) that proof search engines can attach to outputs.
- Prove that the triage policy is sound: if a conjecture is routed to the fast solver and rejected, its depth is below threshold (using `shallow_cycle_all_below_threshold`).
- Integrate with existing autoformalization tools to automatically assign depth to natural-language mathematical claims.

---

## Cross-Cutting Theme: Bounded Depth as a Universal Invariant

All five directions share a common thread: **depth bounds create phase transitions**. Below a threshold, systems are classifiable, decidable, or computationally tractable. Above it, genuinely new phenomena emerge — consistency strength, categorical non-triviality, logical incompleteness, and computational hardness.

This mirrors known phase transitions across mathematics:
- **Krull dimension**: localization depth bounded by ambient dimension (algebraic geometry)
- **Circuit depth**: bounded-depth circuits cannot compute parity (complexity theory)
- **Proof-theoretic ordinals**: bounded induction principles correspond to bounded consistency strength (proof theory)
- **Operadic depth**: compositional complexity bounded by cardinality (operad theory)

The proof-theoretic depth framework developed here provides the **first formally verified instance** of this pattern applied to automated mathematical reasoning, opening a new field at the intersection of proof theory, automated reasoning, and formal epistemology.
