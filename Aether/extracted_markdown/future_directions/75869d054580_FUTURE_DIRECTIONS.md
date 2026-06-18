# Future Directions

## Synthesis

The formal development of intrinsically typed higher-order rewriting with βη-completion opens a structured pathway from typed syntax to certified extensional computation. The substitution composition theorem (Theorem 1) establishes the categorical infrastructure, the η-stability theorem (Theorem 2) provides the extensional pivot, and the quotient-descent theorem (Theorem 3) connects rewriting to semantic equivalence. Together, these create a platform for pursuing higher-order completion algorithms, normalization-by-evaluation certification, dependent type extensions, categorical semantics formalization, and automated verification of compiler transformations. Each direction below builds directly on the established theorems and extends them toward a specific frontier.

---

## Direction 1: Higher-Order Knuth-Bendix Completion Modulo βη

**Conjecture:** There exists a sound and complete higher-order Knuth-Bendix completion procedure for finite, terminating typed rewrite systems modulo βη-equivalence, producing a convergent presentation whenever one exists.

**Test:** Implement the procedure for typed rewrite systems of order ≤ 2 with at most 5 rules. Run on the standard benchmark of combinatory axioms (S, K, I) and verify that the output system is convergent and generates the same equational theory, tested on all terms of size ≤ 10.

**Impact:** This would be the first certified higher-order completion procedure, enabling decision procedures for equational theories of typed functional programs. It would bridge the gap between the abstract completion theory (formalized in `Pythagorean/KnuthBendixCompletion.lean`) and practical higher-order reasoning.

**Catalog References:** `Pythagorean/KnuthBendixCompletion.lean` (abstract convergent systems, Newman's lemma, critical pair theory), `Pythagorean/ConcreteTermAlgebra.lean` (first-order substitution closure), `Pythagorean/IntrinsicBetaEta/Core.lean` (typed substitution composition), `Pythagorean/IntrinsicBetaEta/BetaEta.lean` (quotient descent).

**Proof Strategy:** Define typed critical pairs as minimal overlaps of left-hand sides modulo βη. Prove that local confluence modulo βη is equivalent to joinability of critical pairs (the typed analogue of the critical pair lemma). Use the quotient-descent theorem to show that completion steps preserve the equational theory modulo βη. The key technical challenge is defining a well-founded ordering on typed terms that is compatible with βη.

**Domain Bridges:** Automated theorem proving (higher-order unification), programming language design (type-directed optimization).

**Lineage:** Extends the first-order completion in `KnuthBendixCompletion.lean` through the typed substitution algebra in `Core.lean`.

**Ambition:** Grand challenge — would resolve a 30-year open problem in higher-order rewriting theory.

The key insight is that the quotient-descent theorem (Theorem 3) provides the semantic foundation for completion modulo βη: completion steps preserve the equational theory not just syntactically but up to βη-equivalence.

Why now? The formal infrastructure for typed substitution and βη-stability is in place for the first time, and the abstract completion theory from the catalog provides the first-order template.

---

## Direction 2: Normalization by Evaluation for Typed Rewriting

**Conjecture:** For any βη-stable orthogonal typed rewrite system E, the normalization-by-evaluation (NbE) procedure commutes with E-rewriting: if `t →_E u`, then `nbe(t) ≈_{βη} nbe(u)`.

**Test:** Implement NbE for simply typed λ-calculus with Church-encoded data. For all terms of size ≤ 12 and orthogonal rule sets with ≤ 3 rules, verify that NbE commutes with one-step E-rewriting.

**Impact:** Would establish the correctness of NbE-based optimization passes in higher-order languages, connecting the syntactic theory (rewriting) to the semantic theory (domain-theoretic normalization).

**Catalog References:** `Pythagorean/IntrinsicBetaEta/BetaEta.lean` (βη-stability, Theorem 2), `Pythagorean/IntrinsicBetaEta/Core.lean` (substitution composition).

**Proof Strategy:** Define NbE as a function from typed terms to a semantic domain (a presheaf model), then prove that the readback function produces βη-normal forms. Use Theorem 2 to show that E-rewriting in the syntactic domain corresponds to equality in the semantic domain.

**Domain Bridges:** Denotational semantics, domain theory, categorical logic.

**Lineage:** Builds on the βη-stability theorem (Theorem 2) and the substitution algebra.

**Ambition:** Solid extension — well-understood in the untyped setting but novel in the certified typed setting.

The key insight is that NbE interprets terms in a semantic domain where βη-equivalence is equality, and the quotient-descent theorem guarantees that equational generation in the syntactic domain corresponds to equational generation in the semantic domain.

Why now? The intrinsic typing ensures that NbE is total (no ill-typed terms), and the formal substitution algebra provides the infrastructure for proving correctness of the readback phase.

---

## Direction 3: Dependent Types and Universe Polymorphism

**Conjecture:** The substitution composition and η-stability theorems extend to a dependently typed setting (e.g., a fragment of the Calculus of Constructions) with intrinsic typing, provided the type-level substitution is coherent with the term-level substitution.

**Test:** Formalize a fragment of CC with Π-types and one universe, and prove substitution composition for this fragment. Check that η-contraction for Π-types (`λx. f x →η f` where `f : Π(x:A).B(x)`) is stable under substitution.

**Impact:** Would establish the foundation for certified type-checking algorithms for dependently typed languages, and for equational reasoning in proof assistants.

**Catalog References:** `Pythagorean/IntrinsicBetaEta/Core.lean` (simple-type template), `Pythagorean/IntrinsicBetaEta/BetaEta.lean` (η-stability template).

**Proof Strategy:** Define mutual induction on types and terms. The key new challenge is that substitution in the type of a lambda changes the type of the body, requiring a transport proof. Use universe levels to avoid paradoxes.

**Domain Bridges:** Type theory, homotopy type theory, categorical semantics of dependent types.

**Lineage:** Direct generalization of the simply-typed development.

**Ambition:** Grand challenge — the dependent case introduces fundamentally new coherence issues.

The key insight is that in the dependent setting, η-stability requires not just term-level naturality but type-level naturality: substitution must commute with the type formation rules, not just the term formation rules.

Why now? The simply-typed case demonstrates that intrinsic typing is viable for this style of development, and the proof patterns (extensionality + lift-naturality) should generalize.

---

## Direction 4: Certified Compiler Optimization Passes

**Conjecture:** Every η-reduction pass in a compiler for a simply-typed functional language preserves observational equivalence, as a corollary of the βη-stability theorem applied to the operational semantics modeled as a rewrite system.

**Test:** Formalize a small functional language (PCF or System T) with an operational semantics, define an η-optimization pass, and prove that it preserves the denotational semantics. Test on 100 randomly generated programs of size ≤ 20.

**Impact:** Would provide the first machine-checked proof that η-optimization is correct for a realistic language fragment, directly applicable to compiler verification projects.

**Catalog References:** `Pythagorean/IntrinsicBetaEta/BetaEta.lean` (betaEtaStep_closed_under_subst — Theorem 2).

**Proof Strategy:** Model the operational semantics as a typed rewrite system. Show it is βη-stable. Apply Theorem 3 to conclude that the optimization pass preserves the equational theory. The key step is showing that the operational semantics rules are contained in a βη-stable theory.

**Domain Bridges:** Compiler verification, programming language semantics, software engineering.

**Lineage:** Application of Theorems 2 and 3 to a concrete programming language.

**Ambition:** Solid extension — straightforward application of the theory but high practical impact.

The key insight is that compiler optimizations based on η-reduction are instances of rewriting in a βη-stable theory, and Theorem 3 guarantees that such optimizations preserve the equational theory of the language.

Why now? The formal infrastructure for βη-stable theories is in place, and the gap between the abstract theory and concrete compiler correctness is narrow enough to bridge.

---

## Direction 5: Categorical Semantics of Intrinsic Syntax

**Conjecture:** The substitution category (objects: contexts, morphisms: typed substitutions) formalized in Core.lean is the classifying category of simply typed λ-calculus, and the interpretation functor into any cartesian closed category preserves the βη-equivalence structure established in BetaEta.lean.

**Test:** Formalize the interpretation of the substitution category in the category of sets and functions. Verify that the interpretation of β and η rules corresponds to the computational rules of the set-theoretic function space, tested on all terms of size ≤ 6.

**Impact:** Would establish the first fully mechanized proof that simply typed λ-calculus has the expected categorical semantics, closing a gap that has been folklore for decades.

**Catalog References:** `Pythagorean/IntrinsicBetaEta/Core.lean` (compSub_assoc — categorical associativity), `Pythagorean/IntrinsicBetaEta/BetaEta.lean` (quotient descent).

**Proof Strategy:** Define a functor from the substitution category to Set. Show it preserves products (contexts as iterated products) and exponentials (arrow types as function spaces). The interpretation of β is the evaluation morphism; the interpretation of η is the uniqueness of the exponential transpose.

**Domain Bridges:** Category theory, topos theory, algebraic geometry (via classifying toposes).

**Lineage:** Categorical interpretation of the substitution algebra.

**Ambition:** Solid extension — well-understood mathematically but novel as a mechanized development.

The key insight is that the formal proof of `compSub_assoc` is already half of the categorical structure, and the quotient-descent theorem provides the bridge between the syntactic and semantic equivalences.

Why now? The categorical laws (composition, associativity, identity) are already formally verified, making the gap to full categorical semantics primarily about defining the interpretation functor rather than proving new structural properties.
