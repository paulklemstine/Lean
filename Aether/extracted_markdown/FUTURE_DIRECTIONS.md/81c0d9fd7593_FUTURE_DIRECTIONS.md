# Future Directions

## Synthesis

The Church-Rosser-to-bisimulation transfer framework opens a systematic program for connecting proof-theoretic properties (confluence, normalization, cut elimination) with coalgebraic behavioral equivalences (bisimulation, modal invariance, trace equivalence). The key insight — that confluence generates a shared behavioral core — is not specific to lambda calculus. It applies to any rewriting system with the Church-Rosser property, suggesting a general "confluence semantics" program.

The five directions below range from immediate technical improvements (fixing the substitution representation) to paradigm-shifting conjectures (normalization cost = bisimulation distance) that would unify proof theory, concurrency theory, and computational complexity.

---

## Direction 1: De Bruijn Church-Rosser — Eliminating the Sorry

**Conjecture**: The full Church-Rosser proof via parallel reduction (including `subst_subst_parBeta`, `ParBeta.to_star`, and `parBeta_diamond`) can be formalized sorry-free in Lean 4 using de Bruijn indexed lambda terms.

**Test**: Redefine `Lam` with de Bruijn indices, implement capture-avoiding substitution via lifting/shifting, and reprove `Lam.subst_subst_parBeta`. The proof should go through by standard induction on `ParBeta` since the substitution swap lemma holds for de Bruijn substitution. Verify with `#print axioms church_rosser` showing only standard axioms.

**Impact**: Converts all 2 sorries in the formalization to complete proofs, yielding a fully verified Church-Rosser theorem. This is the most immediate next step.

**Catalog References**: `Pythagorean/ChurchRosserBisimulation.lean` (subst_subst_parBeta, ParBeta.to_star)

**Proof Strategy**: Define `LamDB` with constructors `var (n : Nat)`, `app`, `lam` (no binder variable). Define `shift`, `subst` following standard de Bruijn conventions. Prove substitution lemmas. Define `ParBetaDB` and reprove diamond property. The Takahashi method transfers directly.

**Domain Bridges**: Proof theory → verified compilation

**Lineage**: Extends the current formalization by fixing the representation layer.

**Ambition**: Solid extension — well-understood technique, high confidence of success.

---

## Direction 2: Strong Normalization Implies Finite Strong Bisimulation

**Conjecture**: For simply typed lambda calculus (STLC), β-equivalent terms of the same type produce *strongly bisimilar* bounded FTS at sufficient depth. Unlike the untyped case (where the counterexample (λx.x)y vs. y shows failure), typing constraints ensure that all normal forms at the same type have compatible transition structures.

**Test**: Formalize STLC typing judgment. Prove strong normalization (or assume it). Show that β-equivalent well-typed terms of the same type at a normal form share the same normal form (Church-Rosser + uniqueness of normal forms in STLC). Derive that toFTS at the normalization depth for both terms yields FTS with identical structure from the shared normal form onward. Construct a strong bisimulation that pairs terms along their normalization paths.

**Impact**: Would be the first formal result showing that TYPING converts weak bisimulation into strong bisimulation. This connects type theory directly to coalgebraic semantics.

**Catalog References**: `Pythagorean/ChurchRosserBisimulation.lean`, `Pythagorean/BoundedBetaDefs.lean`

**Proof Strategy**: Key insight: in STLC, every term has a unique normal form. If BetaEq(t,u) and both are well-typed, their unique normal forms must be equal (v = nf(t) = nf(u)). Then toFTS(d', t) and toFTS(d', u) both contain v, and from v onward the FTS is identical. The bisimulation relates states on the normalization paths of t and u.

**Domain Bridges**: Type theory → coalgebra → program verification

**Lineage**: Builds on Church-Rosser + strong normalization.

**Ambition**: Grand challenge — would require significant new formalization (STLC, strong normalization) but the payoff is transformative.

---

## Direction 3: Normalization Cost as Bisimulation Distance

**Conjecture**: There exists a metric d on lambda terms such that d(t, u) equals the minimum depth at which toFTS(d, t) and toFTS(d, u) become weakly bisimilar, and this metric is bounded above by the sum of normalization costs (number of β-steps to normal form).

**Test**: For small simply-typed terms (size ≤ 10), compute:
1. The minimum depth d* at which weak bisimulation holds
2. The sum of normalization step counts
3. Check if d* ≤ normalization_cost(t) + normalization_cost(u)

A single counterexample disproves the conjecture. If it holds for all small terms, investigate whether it follows from the structure of the normalization proof.

**Impact**: Would establish a quantitative bridge between proof complexity (normalization cost) and behavioral distinguishability (bisimulation depth). This connects denotational and operational semantics at a quantitative level.

**Catalog References**: `Pythagorean/ChurchRosserBisimulation.lean` (betaEq_joinable_with_sufficient_budget)

**Proof Strategy**: Use the existing joinability budget theorem as a starting point. The budget max(k₁, k₂) from Church-Rosser is an upper bound, but the actual bisimulation depth might be much smaller due to weak bisimulation's ability to stutter.

**Domain Bridges**: Proof complexity → operational semantics → metric spaces

**Lineage**: Extends the joinability budget analysis.

**Ambition**: Grand challenge — would create a new area at the intersection of proof complexity and coalgebra.

---

## Direction 4: Confluence-to-Bisimulation for Term Rewriting Systems

**Conjecture**: The transfer principle (confluence → shared behavioral core → modal invariance) generalizes from lambda calculus to any abstract rewriting system (ARS) satisfying the Church-Rosser property. Specifically, for any ARS (A, →) with CR, the FTS induced by bounded rewriting preserves modal-logical properties across equivalence classes.

**Test**: 
1. Define a generic ARS structure in Lean 4 with states, rewrite steps, and equivalence.
2. Define bounded FTS for ARS.
3. Prove that CR for the ARS implies weak bisimulation and common-reduct strong bisimulation for the bounded FTS.
4. Instantiate for: (a) lambda calculus, (b) combinatory logic (S, K reduction), (c) string rewriting systems.

**Impact**: Would establish a general metatheorem: confluence is a bisimulation generator for ANY rewriting system. This would connect the entire field of rewriting theory to coalgebraic semantics.

**Catalog References**: `Pythagorean/ChurchRosserBisimulation.lean` (all transfer theorems)

**Proof Strategy**: Abstract the proof of `common_reduct_strong_bisimilar` to work over a generic ARS type class. The key properties needed are: transitivity of multi-step reduction, embedding of single steps into multi-step, and the Church-Rosser property. All are standard ARS axioms.

**Domain Bridges**: Rewriting theory → coalgebra → universal algebra

**Lineage**: Direct generalization of the lambda calculus results.

**Ambition**: Solid extension with paradigm-shifting potential — straightforward to formalize but opens an entirely new research program.

---

## Direction 5: Bisimulation-Preserving Compilation

**Conjecture**: A compiler pass that maps source terms to target terms while preserving β-equivalence automatically preserves all modal-logical properties of the bounded FTS semantics. This can be used as a CORRECTNESS CRITERION for compiler optimizations: an optimization is sound if and only if it maps β-equivalent source terms to β-equivalent target terms.

**Test**: 
1. Implement a simple compiler (e.g., CPS transformation, closure conversion, or A-normal form) as a function `compile : Lam → Lam`.
2. Verify (formally or by exhaustive testing on small terms) that `BetaEq t u → BetaEq (compile t) (compile u)`.
3. Derive that the compiled terms have weakly bisimilar bounded FTS.
4. Check that specific modal properties (e.g., "can reduce to a value in k steps") are preserved.

**Impact**: Would provide a mechanical certification method for compiler correctness based on bisimulation theory rather than logical relations or contextual equivalence.

**Catalog References**: `Pythagorean/ChurchRosserBisimulation.lean` (beta_equiv_weakBisimilar, bisimilar_modal_invariance)

**Proof Strategy**: The key insight is that `beta_equiv_weakBisimilar` is unconditional — it doesn't require Church-Rosser. So any function preserving β-equivalence automatically preserves weak bisimilarity of bounded FTS. The modal invariance then follows from `bisimilar_modal_invariance` (via weak version). This is a DIRECT APPLICATION of existing theorems.

**Domain Bridges**: Compiler verification → concurrency theory → modal logic

**Lineage**: Application of the weak bisimulation and modal invariance theorems.

**Ambition**: Solid extension with immediate practical impact — could be implemented and tested within weeks.
