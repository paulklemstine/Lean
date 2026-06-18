# Future Directions

## Synthesis

The bounded higher-order critical pair theorem modulo β established in this work creates a bridge between abstract rewriting theory and practical program transformation. The five directions below form a coherent research program: Direction 1 removes the size bound to get unconditional confluence; Direction 2 extends the binding structure to dependent types; Direction 3 makes the algorithms practical for compiler integration; Direction 4 connects to categorical coherence theory; Direction 5 opens a new application domain in verified supercompilation. Together, they chart a path from a bounded, mechanized theorem to a full-fledged higher-order completion theory applicable to real-world programming language toolchains.

---

## Direction 1: Unbounded Confluence via Well-Founded Overlap Induction

**Conjecture**: For every finite left-linear simply typed Miller-pattern rewrite system E, if all β-critical pairs (at all sizes) are joinable, then HoRewrite_β(E) is confluent on all closed simply-typed terms.

**The key insight is** that the bounded framework established in `Pythagorean/HOCriticalPairs.lean` can be lifted to an unbounded result by showing that the set of critical pairs is *well-founded*: overlaps at larger sizes decompose into smaller overlaps via the substitution functoriality theorem (`subst_comp`). This transforms the bounded critical pair theorem into an inductive proof over the termination ordering.

**Why now?** The substitution infrastructure (`subst_comp`, `hoRewrite_closed_under_subst`, `betaStep_closed_under_subst`) and Newman's lemma (`newman_lemma`) from the current development provide the exact tools needed. The missing piece is a structural analysis of how overlap size relates to the well-founded ordering from `Terminating E`.

**Test**: Formalize the statement in Lean 4 and attempt proof by well-founded induction on the overlap complexity. A disproof would require constructing a Miller-pattern system where joinability at every finite size fails to imply joinability at the limit.

**Impact**: An unconditional higher-order critical pair theorem would be a landmark result in rewriting theory, removing the last barrier to using completion as a decision procedure for higher-order equational reasoning.

**Catalog References**: `Pythagorean/HOCriticalPairs.lean` (Theorems: `newman_lemma`, `localConfluence_of_joinable_criticalPairs`, `subst_comp`)

**Proof Strategy**: Transfinite induction on the maximal overlap size. Use `subst_comp` to decompose large overlaps into compositions of smaller ones.

**Domain Bridges**: Automated theorem proving (equational reasoning), compiler verification (full correctness guarantees)

**Lineage**: Direct extension of the bounded critical pair theorem

**Ambition**: Grand challenge — would resolve a 50-year open question in higher-order rewriting theory

---

## Direction 2: Dependent Type Extensions

**Conjecture**: The substitution functoriality theorem and β-closure under substitution extend to a calculus with dependent types (Π-types), yielding a critical pair theorem for dependent pattern matching.

**The key insight is** that the core substitution infrastructure (`subst_comp`, `liftSubst_compSubst`, `rename_succ_subst_liftSubst`) depends only on the de Bruijn structure, not on simple typing. The same algebraic identities should hold in a dependently-typed setting, with the additional constraint that substitutions preserve typing.

**Why now?** Modern proof assistants (Coq, Agda, Lean) use definitional equality with rewrite rules. Understanding when these rules are confluent is critical for soundness and performance. The current framework provides the template.

**Test**: Define a dependently-typed term type extending `HOTerm` with Π-types and universe levels. Verify that `subst_comp` and `betaStep_closed_under_subst` generalize. Construct a counterexample if the Miller pattern restriction is insufficient for dependent matching.

**Impact**: Would provide a theoretical foundation for certifying rewrite rule extensions in proof assistants like Lean 4 and Agda.

**Catalog References**: `Pythagorean/HOCriticalPairs.lean` (substitution infrastructure), `Catalog/Bridges/Catalog/Pythagorean/HigherOrderCompletion.lean` (higher-order substitution theory)

**Proof Strategy**: Define dependent terms, extend `liftSubst` to preserve type annotations, prove functoriality by the same structural induction.

**Domain Bridges**: Type theory (definitional equality), proof assistant design (soundness of rewrite extensions)

**Lineage**: Extends Direction 1 from simply-typed to dependently-typed

**Ambition**: Solid extension — builds directly on established infrastructure

---

## Direction 3: Efficient Critical Pair Enumeration via Discrimination Trees

**Conjecture**: Critical pair enumeration for Miller-pattern systems can be performed in O(|E| · N · log N) time using discrimination tree indexing, compared to the current O(|E|² · N²).

**The key insight is** that the `syntacticMatch` function in `enumerateCriticalPairs` performs redundant work by checking all pairs of rules against all subterms. A discrimination tree (trie over term structure) can index rule left-hand sides and answer "which rules overlap with this subterm?" in logarithmic time.

**Why now?** The soundness theorem `enumerateCriticalPairs_sound` provides the correctness specification. An optimized algorithm need only satisfy the same specification to be plugged into the certification pipeline.

**Test**: Implement discrimination tree indexing in Python, benchmark against the naive algorithm on systems with 10-100 rules, and verify that speedup matches the theoretical prediction.

**Impact**: Makes real-time confluence checking feasible for compiler optimization passes with dozens of rewrite rules.

**Catalog References**: `Pythagorean/HOCriticalPairs.lean` (`enumerateCriticalPairs_sound`)

**Proof Strategy**: Prove the indexed algorithm produces the same output as the naive one (simulation argument).

**Domain Bridges**: Compiler verification (real-time optimization coherence checking), automated deduction (efficient equational reasoning)

**Lineage**: Optimization of existing algorithms

**Ambition**: Solid extension — engineering advancement with clear theoretical backing

---

## Direction 4: Categorical Coherence and 2-Categorical Rewriting

**Conjecture**: The joinability of critical pairs in a Miller-pattern rewrite system E is equivalent to the coherence of a 2-categorical structure on the rewriting 2-category of E, where 0-cells are terms, 1-cells are rewrite sequences, and 2-cells are "rewriting of rewritings" (peak joins).

**The key insight is** that `disjoint_app_peaks_joinable` and `localConfluence_of_joinable_criticalPairs` establish exactly the data needed for a coherence theorem: every pair of parallel 1-cells (rewrite paths) has a connecting 2-cell (a join). This is the rewriting-theoretic analogue of Mac Lane's coherence theorem for monoidal categories.

**Why now?** The context closure theorems (`Joinable.appL_context`, `appR_context`, `lam_context`) show that joinability is preserved by all term constructors — exactly the functoriality condition needed for a 2-functor from the syntax 2-category to the semantics.

**Test**: Define the rewriting 2-category for a small benchmark system, verify the coherence conditions computationally, and check that the 2-categorical formulation implies (and is implied by) confluence.

**Impact**: Would establish a precise dictionary between rewriting theory and higher category theory, opening both fields to techniques from the other.

**Catalog References**: `Pythagorean/HOCriticalPairs.lean` (`disjoint_app_peaks_joinable`, `Joinable.appL_context`), `Catalog/Bridges/Catalog/Pythagorean/HigherOrderCompletion.lean` (categorical interpretation of `subst_comp`)

**Proof Strategy**: Construct the 2-category explicitly, verify the exchange law, and derive coherence from the critical pair theorem.

**Domain Bridges**: Category theory (coherence), homotopy type theory (path spaces as rewrite sequences)

**Lineage**: New connection between Directions 1 and categorical semantics

**Ambition**: Grand challenge — would unify rewriting theory with higher category theory

---

## Direction 5: Verified Supercompilation via Bounded Completion

**Conjecture**: A bounded higher-order completion procedure can certify the correctness of supercompilation transformations — program optimizations discovered by exhaustive rewrite-path exploration.

**The key insight is** that supercompilation explores the tree of all possible rewrite sequences from a program and selects the optimal path. If the rewrite system is confluent (certified by our bounded critical pair theorem), then the supercompiler's choice of path is irrelevant — all paths lead to the same result. This transforms supercompilation from a heuristic search into a certified optimization.

**Why now?** The `CompletionCertificate` structure in `HOCriticalPairs.lean` already bundles the data needed for certification. Extending it to include a "supercompilation trace" — a record of which rewrite paths were explored — would yield a verified supercompiler.

**Test**: Implement a bounded supercompiler for a small functional language (e.g., a subset of Haskell). Use the certification pipeline to verify that the discovered optimizations are confluent. Compare the optimized code against GHC's output.

**Impact**: Would create the first verified supercompiler — a program optimizer whose correctness is mathematically guaranteed, not just empirically tested.

**Catalog References**: `Pythagorean/HOCriticalPairs.lean` (`CompletionCertificate`, `unique_nf_of_confluent`), `Catalog/Pythagorean/ConcreteTermAlgebra.lean` (`concrete_completion_correct`)

**Proof Strategy**: Define a supercompilation trace type, prove that confluent systems have unique optimal forms, and certify the trace against the completion certificate.

**Domain Bridges**: Compiler optimization (verified supercompilation), program analysis (certified program transformation)

**Lineage**: Application of Directions 1 and 3 to a concrete programming language tool

**Ambition**: Solid extension with high practical impact
