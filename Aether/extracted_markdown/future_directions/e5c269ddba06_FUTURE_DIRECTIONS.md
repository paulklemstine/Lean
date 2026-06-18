# Future Directions: STTC Confluence and Beyond

## Synthesis

The STTC confluence result establishes that typed tensor simplification is order-independent when algebraic rules are stratified by type level. This opens three major research avenues: (1) extending the type system to capture more expressive tensor properties (dependent dimensions, linearity tracking), (2) transferring the technique to other algebraic-functional hybrid systems (quantum circuits, differential calculus), and (3) leveraging confluence for verified compilation of tensor programs. Each direction builds directly on the type-level separation theorem and the critical pair analysis machinery developed here. Together, they point toward a unified theory of *typed algebraic rewriting* — a framework that would subsume both classical term rewriting and typed λ-calculus as special cases.

---

## Direction 1: Differential λ-Calculus Normalization via Typed Stratification

**Conjecture:** The STTC confluence result, combined with strong normalization of the simply-typed λ-calculus, implies strong normalization for the typed differential λ-calculus fragment with scalars and vectors. Specifically, if we interpret the STTC distributivity rules as the Leibniz rule for differentiation, then every typed differential λ-term has a unique normal form modulo AC.

**Test:** Formalize the connection between STTC distributivity and the Ehrhard-Regnier differential λ-calculus. Define a type-preserving translation from differential λ-terms to STTC terms and show that it commutes with reduction. If the translation preserves normalization, strong normalization of STTC (which follows from confluence + type-theoretic termination) transfers to the differential fragment.

**Impact:** Strong normalization for the typed differential λ-calculus has been an open problem since Ehrhard and Regnier's 2003 paper. A positive result would close a 20-year gap in proof theory and provide the first cut-elimination theorem for differential linear logic with function types.

**Catalog References:**
- `Catalog/Pythagorean/STTCConfluence.lean`: Type-level separation theorem, distributivity rules
- `Catalog/Pythagorean/ChurchRosser.lean`: Church-Rosser for untyped β-reduction (base case)
- `Catalog/Pythagorean/HOCriticalPairs.lean`: Critical pair infrastructure for higher-order systems

**Proof Strategy:** Use the STTC type hierarchy as a measure for a decreasing diagrams argument. β-steps decrease the type level of the active redex, while dist-steps (= differentiation steps) operate at level 0. The well-ordering of ℕ ensures termination of the combined system.

**Domain Bridges:** Proof theory (cut elimination), automatic differentiation (correctness of AD), denotational semantics (coherence spaces)

**Lineage:** Extends Ehrhard-Regnier (2003), Vaux (2007), Tranquilli (2009)

**Ambition:** Grand challenge — would resolve a foundational open problem in linear logic

---

## Direction 2: ZX-Calculus Confluence via Typed Bialgebra Rewriting

**Conjecture:** The STTC confluence technique transfers to the simply-typed ZX-calculus. Spider fusion (analogous to AC) and the bialgebra rule (analogous to distributivity) are confluent modulo spider equivalence when restricted to fire at base types (single wires, not wire bundles with function-type annotations).

**Test:** Define a typed ZX-calculus with wire types (qubit, classical bit, function wire). Formalize the bialgebra rule as a DistStep and spider fusion as ACβη. Enumerate critical pairs between spider fusion, the bialgebra rule, and the Hopf rule. Check joinability of each pair computationally for diagrams up to 6 spiders.

**Impact:** Verified quantum circuit optimization. Current ZX-calculus tools (PyZX, QuiZX) lack formal confluence guarantees, which limits their use in safety-critical quantum error correction pipelines. A typed confluence result would enable certified optimization.

**Catalog References:**
- `Catalog/Pythagorean/STTCConfluence.lean`: Type-level separation, local confluence infrastructure
- `Catalog/Pythagorean/TensorSortedRewrite.lean`: Multi-sorted rewrite system foundations
- `Catalog/Pythagorean/KnuthBendixCompletion.lean`: Completion procedures for equational theories

**Proof Strategy:** Map ZX-calculus types to STTC types (qubit → Vec 2, spider → smul/vadd). Show that the bialgebra rule corresponds to distributivity of matrix multiplication over addition. Apply the type-level separation theorem directly.

**Domain Bridges:** Quantum computing (circuit optimization), category theory (monoidal categories), condensed matter physics (tensor networks)

**Lineage:** Extends Coecke-Duncan (2011), Backens (2014), the present work

**Ambition:** Solid extension — leverages existing ZX infrastructure with new typed framework

---

## Direction 3: Verified Tensor Compiler Synthesis via Confluence Certificates

**Conjecture:** The STTC confluence theorem can be lifted to a *compiler correctness certificate*: given a source tensor program and an optimized target program, a short proof witness certifies that the two are equivalent modulo the confluence relation. The witness size is polynomial in the program size.

**Test:** Implement a prototype compiler that translates a simple tensor DSL to optimized STTC normal forms. For each optimization step, record the reduction rule applied. The sequence of rules constitutes the equivalence certificate. Verify that the certificate checker runs in O(n log n) time.

**Impact:** Eliminates the need for per-optimization-pass correctness proofs in tensor compilers. Instead, correctness follows automatically from the confluence theorem. This could certify optimizations in XLA, TVM, and similar systems.

**Catalog References:**
- `Catalog/Pythagorean/STTCConfluence.lean`: Confluence theorem, reduction relations
- `Catalog/Pythagorean/ConvergentRewriteSystems.lean`: Convergent rewrite system theory
- `Catalog/Pythagorean/EqualitySaturationExtraction.lean`: E-graph optimization foundations

**Proof Strategy:** Show that the STTC reduction relation is decidable (by syntactic pattern matching) and that AC-equivalence checking is decidable (by multiset comparison). Combine to get decidable certificate verification.

**Domain Bridges:** Compiler verification, certified programming, proof-carrying code

**Lineage:** Extends Tate et al. (2009, equality saturation), Lerner et al. (2003, compiler verification)

**Ambition:** Solid extension — immediate practical impact for ML compiler correctness

---

## Direction 4: Dependent Tensor Types and Dimension-Safe Rewriting

**Conjecture:** The STTC can be extended with dependent types indexed by natural number dimensions, yielding a calculus where `Vec : ℕ → Type` and `Mat : ℕ → ℕ → Type` carry their dimensions as type-level terms. The confluence result extends to this setting provided dimension-equality proofs are erased during reduction.

**Test:** Formalize a mini dependent type theory with tensor constructors. Define distributivity rules that preserve dimension indices. Verify that dimension mismatch errors are caught at type-checking time (before reduction), so they cannot interfere with confluence.

**Impact:** Dimension-safe tensor programming with guaranteed optimization correctness. Catches errors like multiplying a 3×4 matrix with a 5-vector at compile time, while still allowing algebraic simplification.

**Catalog References:**
- `Catalog/Pythagorean/STTCConfluence.lean`: Base STTC formalization
- `Catalog/Pythagorean/STLCDefs.lean`: Simply-typed λ-calculus foundations
- `Catalog/Pythagorean/TypeComplexityBounds.lean`: Type complexity analysis

**Proof Strategy:** Use proof irrelevance for dimension equality witnesses. Show that reducing with or without dimension proofs yields the same computational content (dimension erasure). Confluence of the erased system implies confluence of the full system.

**Domain Bridges:** Dependently-typed programming (Idris, Agda), array programming (Dex, Futhark), numerical linear algebra

**Lineage:** Extends Brady (2013, Idris), Paszke et al. (2021, Dex)

**Ambition:** Grand challenge — combining dependent types with algebraic rewriting is largely uncharted

---

## Direction 5: AC-Completion for Extended Tensor Signatures

**Conjecture:** The Knuth-Bendix completion procedure, when applied to the STTC distributivity rules modulo AC, terminates and produces a convergent (confluent + terminating) rewrite system. This convergent system provides a decision procedure for the equational theory of tensor expressions.

**Test:** Implement AC-completion for the 8 STTC distributivity rules plus the AC axioms for addition. Run the completion procedure and verify: (a) it terminates, (b) the resulting system has finitely many rules, (c) the rules are sufficient to decide equality of tensor expressions.

**Impact:** An automated decision procedure for tensor expression equivalence, useful for compiler optimization validation and mathematical proof automation.

**Catalog References:**
- `Catalog/Pythagorean/STTCConfluence.lean`: STTC rules and AC equivalence
- `Catalog/Pythagorean/KnuthBendixCompletion.lean`: Knuth-Bendix completion theory
- `Catalog/Pythagorean/ConvergentRewriteMaster.lean`: Convergent rewrite system infrastructure
- `Catalog/Pythagorean/ConcreteTermAlgebra.lean`: Concrete term algebra with matching

**Proof Strategy:** Define a reduction ordering compatible with AC (e.g., recursive path ordering with status). Show that all critical pairs generated during completion can be oriented by this ordering, ensuring termination of the completion process.

**Domain Bridges:** Automated theorem proving, symbolic computation, computer algebra systems

**Lineage:** Extends Knuth-Bendix (1970), Peterson-Stickel (1981, AC-completion), Bachmair-Dershowitz (1986)

**Ambition:** Solid extension — combines well-understood completion theory with new tensor signature
