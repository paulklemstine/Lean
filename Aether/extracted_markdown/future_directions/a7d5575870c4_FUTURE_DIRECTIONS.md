# Future Directions: Higher-Order Completion Modulo β

## Synthesis

The bounded higher-order critical pair theorem established in this work opens five distinct research frontiers. At their core, all five share a common theme: **making higher-order equational reasoning algorithmic, certified, and practical**. The bounded completion certificate we construct is the first stone in a foundation that connects abstract rewriting theory (Direction 1), compiler verification (Direction 2), categorical coherence (Direction 3), type-theoretic normalization (Direction 4), and automated deduction (Direction 5). Each direction extends the current work in a different mathematical dimension — unbounding the size constraint, enriching the type structure, bridging to different semantic domains, or increasing the automation level. Together, they chart a path from the current bounded, simply-typed, Miller-pattern result to a full higher-order completion theory for real programming languages and proof systems.

---

## Direction 1: Unbounded Higher-Order Completion via Recursive Critical Pair Saturation

**Conjecture:** For every finite left-linear Miller-pattern rewrite system E that is terminating and has no infinite ascending chain of critical pair sizes, there exists a finite N₀ such that `AllCriticalPairsJoinable E N₀` implies global confluence of E.

**Test:** Implement recursive critical pair saturation: enumerate critical pairs at increasing bounds N = 1, 2, 3, ..., checking joinability at each level. If the critical pair set stabilizes (no new pairs appear beyond some N₀), the conjecture predicts global confluence. Test on the map fusion, CPS, and deforestation benchmarks. Falsify by constructing a terminating Miller-pattern system where new critical pairs appear at every bound.

**Impact:** This would remove the "bounded" qualifier from our main theorem, yielding a full higher-order Knuth-Bendix completion procedure. It would be the first decision procedure for confluence of terminating higher-order pattern rewrite systems.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (master_pipeline, localConfluence_from_joinable_pairs), `Pythagorean/HOCriticalPairs.lean` (BetaCriticalPairsUpTo, AllCriticalPairsJoinable)

**Proof Strategy:** Show that in a terminating system, the set of overlap positions is bounded by the termination ordering. Use the well-foundedness of the ordering to prove that critical pair generation eventually stabilizes.

**Domain Bridges:** Connects to automated theorem proving (equational reasoning), universal algebra (finitely presented theories)

**Lineage:** Extends master_pipeline by removing the "Global" quantifier from AllCriticalPairsJoinableGlobal

**Ambition:** Grand challenge — would resolve a 50-year open problem in higher-order rewriting theory

---

## Direction 2: Certified Compiler Optimization Passes via Completion Certificates

**Conjecture:** For the standard optimization rules of a pure functional language compiler (map/fold fusion, β/η reduction, case-of-case, let-floating), the bounded completion certificate at bound N = 100 certifies local confluence, and the certificate can be used to automatically verify that the compiler's optimization pipeline produces unique normal forms.

**Test:** Encode the GHC rewrite rules (RULES pragmas) for list fusion as a Miller-pattern system. Generate a completion certificate at bound 100. Check whether all critical pairs are joinable. If they are, the certificate guarantees that GHC's list fusion optimizations are confluent — regardless of the order in which they fire.

**Impact:** Would provide the first mathematical guarantee of optimization coherence for a real-world compiler. Currently, GHC's RULES are tested empirically but never proved confluent.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (mkFullCertificate, VerifiedCompletionCertificate, ho_completion_pipeline_sound), `Pythagorean/KnuthBendixCompletion.lean` (normalizer_preserves_semantics)

**Proof Strategy:** Use mkFullCertificate to construct the certificate. Connect to normalizer_preserves_semantics via a denotational semantics for the source language. The certificate + semantics bridge gives end-to-end soundness.

**Domain Bridges:** Compiler verification, functional programming, software engineering

**Lineage:** Builds on coherent_optimization_pipelines and the cross-domain connection to program semantics

**Ambition:** Solid extension — directly applicable to existing compiler infrastructure

---

## Direction 3: Categorical Coherence from Confluent Rewriting

**Conjecture:** For a finitely presented symmetric monoidal category whose structural isomorphisms are encoded as a Miller-pattern rewrite system, confluence of the system is equivalent to coherence of the category (i.e., all diagrams of structural morphisms commute).

**Test:** Encode Mac Lane's coherence theorem for monoidal categories as a rewrite system: associativity `(A ⊗ B) ⊗ C → A ⊗ (B ⊗ C)`, unit laws `I ⊗ A → A` and `A ⊗ I → A`. Generate critical pairs and check joinability. The coherence theorem predicts all pairs are joinable.

**Impact:** Would create a computational proof of categorical coherence theorems. Currently, coherence proofs are done by hand using graph-theoretic or combinatorial arguments. A completion-based approach would be fully algorithmic.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (equiv_iff_joinable_of_confluent, ho_word_problem_decidable)

**Proof Strategy:** The key insight is that coherence = all diagrams commute = all equational consequences hold = word problem decidable = confluent completion exists. Use equiv_iff_joinable_of_confluent to bridge joinability and equational equivalence.

**Domain Bridges:** Category theory, algebraic topology (higher coherence), quantum computing (categorical quantum mechanics)

**Lineage:** Interprets equiv_iff_joinable_of_confluent as a coherence principle

**Ambition:** Grand challenge — would unify rewriting theory and categorical coherence

---

## Direction 4: Normalization by Rewriting for Dependent Type Theory

**Conjecture:** The definitional equality of a dependent type theory with a finite set of computation rules (β, η, ι for inductive types) can be decided by higher-order completion modulo β, provided the computation rules form a confluent Miller-pattern system.

**Test:** Encode the computation rules of the Calculus of Inductive Constructions (CIC) as a higher-order rewrite system. Check whether they satisfy the Miller pattern property. If so, generate a completion certificate and compare with the known decidability of CIC's definitional equality.

**Impact:** Would provide an alternative normalization procedure for proof assistants, potentially faster than the standard approach (normalization by evaluation) for specific type theories. Could also be used to validate that user-defined computation rules preserve decidability of type-checking.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (master_pipeline, unique_nf_existence), `Pythagorean/HOCriticalPairs.lean` (betaStep_closed_under_subst, hoRewrite_closed_under_subst)

**Proof Strategy:** The key insight is that normalization by rewriting is an alternative to normalization by evaluation. Use master_pipeline to show unique normal forms exist, then implement a normalizer that uses the rewrite system to compute normal forms.

**Why now?** Recent interest in extensible type theories (with user-defined reductions) makes confluence checking essential for ensuring type-checking decidability.

**Domain Bridges:** Type theory, proof assistants, programming language design

**Lineage:** Extends unique_nf_existence to typed calculi

**Ambition:** Solid extension — connects to active research in type theory

---

## Direction 5: Higher-Order Superposition with Completion Preprocessing

**Conjecture:** A higher-order superposition calculus preprocessing step that uses bounded completion to orient equations into rewrite rules achieves significantly better performance on higher-order theorem proving benchmarks than unpreprocessed superposition.

**Test:** Implement a preprocessing phase for a higher-order superposition prover (e.g., Zipperposition or Leo-III) that uses bounded completion certificates to orient equational axioms. Measure the impact on TPTP higher-order benchmark problems.

**Impact:** Would bridge the gap between completion (which is great for equational reasoning but weak for general theorem proving) and superposition (which is great for general reasoning but weak for equational reasoning). The combination should be stronger than either alone.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (ho_completion_pipeline_sound, enumerate_critical_pairs), `Pythagorean/KnuthBendixCompletion.lean` (kb_completion_correct, convergent_decides_word_problem)

**Proof Strategy:** The key insight is that a completion certificate provides oriented rules that can be used as simplification rules in superposition. The certificate guarantees that simplification with these rules is sound and does not lose completeness.

**Why now?** Higher-order automated theorem proving has seen dramatic advances in the last 5 years (Bentkamp et al., 2021), but equational reasoning remains a bottleneck.

**Domain Bridges:** Automated deduction, artificial intelligence, formal verification

**Lineage:** Combines ho_completion_pipeline_sound with first-order completion infrastructure

**Ambition:** Solid extension — directly implementable with existing prover infrastructure
