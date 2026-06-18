# Future Directions: Certified Knuth-Bendix Completion

## Synthesis

The formalization of Knuth-Bendix completion at the abstract rewrite system level opens a structured research program along three axes: (1) **deepening** the formalization to concrete term algebras with full first-order unification; (2) **broadening** to domain-specific instantiations (group theory, Boolean circuits, polynomial ideals); and (3) **connecting** to adjacent formalisms (e-graphs, equality saturation, homotopy type theory). Each direction builds on the core invariant architecture (theory preservation + termination + local confluence = convergence) established in this work, and each is testable through specific computational experiments. The grand challenge is to build a fully automated, end-to-end verified pipeline from equational specifications to optimized executable code—a "certified compiler compiler" for algebraic theories.

---

## Direction 1: Concrete First-Order Term Algebra with Verified Unification

**Conjecture:** A formalization of first-order terms with syntactic unification in Lean 4, combined with the abstract completion theorems from `Pythagorean/KnuthBendixCompletion.lean`, yields a fully executable verified KB completion procedure that decides the word problem for any equational theory admitting a finite convergent presentation.

**Test:** Implement `Term`, `Substitution`, `Position`, and `unify` in Lean with full correctness proofs (most general unifier, termination, correctness). Instantiate `newman_lemma` and `kb_completion_correct` with the concrete term type. Run on the free monoid axioms and verify that the output system has exactly 3 rules. Measure: number of Lean lines required, compilation time, and comparison with Isabelle's IsaFoR formalization.

**Impact:** Transforms the abstract theorems into a runnable verified decision procedure. This is the main gap in the current formalization and closing it would yield the first fully verified KB completion in Lean 4.

**Catalog References:**
- `Pythagorean/KnuthBendixCompletion.lean`: `newman_lemma`, `kb_completion_correct`, `convergentToCertifiedNorm`
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `CertifiedNormalizer`, `convergent_rewrite_induces_optimizer`

**Proof Strategy:** Define `inductive Term (F V : Type)` with `var` and `app` constructors. Prove unification termination via a well-founded measure on the number of unsolved variables. Prove MGU correctness by induction on the unification algorithm. Bridge to the abstract ARS via a `ReflTransGen` on the concrete rewrite relation.

**Domain Bridges:** Term rewriting → type theory (terms are types in the Curry-Howard correspondence); unification → type inference (Hindley-Milner is a special case).

**Lineage:** Direct extension of `kb_completion_correct`.

**Ambition:** High — this is substantial formalization work (estimated 2000+ lines) but follows well-established mathematical theory.

---

## Direction 2: Verified Lexicographic Path Ordering

**Conjecture:** The Lexicographic Path Ordering (LPO) over first-order terms with a given precedence is a well-founded reduction ordering (compatible with the term structure), and this can be proved in Lean 4 in under 500 lines by leveraging Mathlib's `WellFoundedRelation` infrastructure.

**Test:** Formalize LPO as a decidable relation on first-order terms. Prove well-foundedness, compatibility with substitution (σ-stability), and monotonicity (subterm property). Use as the ordering parameter in a concrete instantiation of `kb_completion_correct`. Verify: does `lpo_wf` compose cleanly with `newman_lemma` to produce convergent systems?

**Impact:** Provides the missing ordering component for end-to-end verified completion. Currently, termination is assumed as a hypothesis; with a verified LPO, it becomes a theorem.

**Catalog References:**
- `Pythagorean/KnuthBendixCompletion.lean`: `IsTerminating`, `kb_completion_correct`

**Proof Strategy:** Well-foundedness of LPO by the Dershowitz-Jouannaud theorem: LPO is well-founded if the precedence is well-founded. Prove by embedding into multiset orderings, using Mathlib's `Multiset.wellFoundedLT`. Subterm property and σ-stability by structural induction.

**Domain Bridges:** Termination analysis → program verification (LPO is used in termination provers for functional programs).

**Lineage:** Enables the termination hypothesis in `kb_completion_correct` to be discharged automatically.

**Ambition:** Medium — well-studied mathematical theory, but the formal proof of well-foundedness via multiset orderings requires care.

---

## Direction 3: KB Completion for Group Presentations and the Word Problem

**Conjecture (Grand Challenge):** For every finite group G of order |G| ≤ 100 with standard presentation ⟨generators | relators⟩, KB completion with the recursive path ordering terminates and produces a convergent rewrite system with at most O(|G|²) rules. Furthermore, the resulting system decides the word problem: two words represent the same group element iff they reduce to the same normal form.

**Test:** Enumerate all groups of order ≤ 100 (using the GAP system's SmallGroups library). For each group, extract a finite presentation, encode as equational axioms (with group operation, inverse, identity), and run KB completion with RPO. Record: (1) whether completion terminates, (2) number of steps, (3) number of rules, (4) whether all critical pairs are joinable. Plot rule count vs. group order. Identify groups where completion fails—these are the "hard" presentations.

**Impact:** Would establish the practical boundary of KB completion for computational group theory. Known: KB completion solves the word problem for all finite groups (since they have finite convergent presentations), but the *size* of completed systems is poorly understood.

**Catalog References:**
- `Pythagorean/KnuthBendixCompletion.lean`: `kb_completion_correct`, `nf_eq_iff_eqtheory`

**Proof Strategy:** For the formal verification: define group presentations as equational theories, instantiate the completion theorem, and prove that group axioms satisfy the soundness condition. For the conjecture itself: likely requires structural analysis of Dehn functions and the geometry of Cayley graphs.

**Domain Bridges:** Computational group theory → geometric group theory → topology (fundamental groups of manifolds).

**Lineage:** Extends `kb_completion_correct` to a specific, high-impact domain.

**Ambition:** Grand Challenge — the conjecture about O(|G|²) rule bounds is likely false for some groups and would yield interesting counterexamples.

---

## Direction 4: Equality Saturation via Verified Completion

**Conjecture:** The Knuth-Bendix completion procedure, when applied to the rewrite rules extracted from an e-graph equality saturation run, produces a convergent system that subsumes the e-graph—that is, every equality derivable in the e-graph is also derivable in the completed system, and the completed system's normal forms correspond to the optimal representatives chosen by the e-graph's extraction phase.

**Test:** Implement a simple e-graph (à la egg library) in Python. Run equality saturation on arithmetic expressions (e.g., with rules for commutativity, associativity, distributivity, and simplification). Extract the learned equalities as equations. Feed to KB completion. Compare: (1) do the completed rules produce the same normal forms as e-graph extraction? (2) Is the completed system convergent? (3) How does rule count scale with e-graph size?

**Impact:** Would unify two major paradigms in term rewriting: KB completion (classical, 1970s) and equality saturation (modern, 2000s). If the connection holds, it provides a theoretical foundation for e-graph correctness via the completion theorem.

**Catalog References:**
- `Pythagorean/KnuthBendixCompletion.lean`: `kb_completion_correct`, `convergent_optimizer`
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `convergent_rewrite_induces_optimizer`

**Proof Strategy:** Model e-graph congruence closure as a specific completion strategy (ground completion). Show that ground completion is a special case of KB completion where all terms are ground. The extraction phase corresponds to choosing normal forms.

**Domain Bridges:** Term rewriting → compiler optimization (MLIR, Cranelift use e-graphs); e-graphs → SMT solving (congruence closure is a core SMT theory).

**Lineage:** Connects the classical KB theory to modern compiler infrastructure.

**Ambition:** Grand Challenge — the precise correspondence between e-graphs and convergent systems is conjectural and would be a significant theoretical contribution if established.

---

## Direction 5: Modular Composition of Certified Normalizers

**Conjecture:** Given two certified normalizers N₁ and N₂ for overlapping theories T₁ and T₂ (with shared signature symbols), if the rewrite rules of N₁ and N₂ are compatible (no new critical pairs between them, or all such pairs are joinable), then the union system N₁ ∪ N₂ is convergent, and its normal forms agree with sequential application of N₁ followed by N₂ (iterated to fixpoint).

**Test:** Take the monoid normalizer (3 rules) and a commutativity normalizer for a commutative monoid. Check: (1) are there critical pairs between the two rule sets? (2) If so, does completion of the union terminate? (3) Does the composed normalizer produce the same results as the known convergent system for commutative monoids?

**Impact:** Enables modular construction of large normalizers from independently verified components. This is the rewrite-system analogue of separate compilation and linking.

**Catalog References:**
- `Pythagorean/KnuthBendixCompletion.lean`: `convergentToCertifiedNorm`, `kb_certified_optimizer`
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `compose_normalizers_sound`

**Proof Strategy:** Use the Toyama theorem (modularity of confluence for non-overlapping TRSs) as the starting point. For overlapping systems, formalize the critical pair criteria for modular confluence. The composition theorem in `ConvergentRewriteOptimizer.lean` already shows that sequential application preserves soundness; the gap is showing confluence of the union.

**Domain Bridges:** Modularity → software engineering (composable verified libraries); separate compilation → proof modularity.

**Lineage:** Directly extends `compose_normalizers_sound` from sequential composition to union.

**Ambition:** Medium-High — the modular confluence theory is well-studied but technically demanding to formalize.
