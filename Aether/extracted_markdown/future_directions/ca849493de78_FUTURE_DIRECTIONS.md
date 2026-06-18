# Future Directions: Higher-Order Completion Modulo β

## Synthesis

The bounded higher-order critical pair theorem modulo β established in this work opens a corridor between three previously separate domains: (1) abstract rewriting theory, (2) higher-order program optimization, and (3) certified compilation. The completion certificate structure and the parallel rewriting infrastructure provide the formal foundation for each direction below. The key unifying theme is that **decidable overlap analysis on Miller-pattern systems** is the bridge that makes theoretical confluence results computationally actionable. Each direction below extends this bridge in a different dimension—deeper type structure, broader pattern classes, or farther into application domains.

---

## Direction 1: Polymorphic and Dependent Type Extensions

**Conjecture:** The bounded critical pair theorem extends to System F (polymorphic λ-calculus) and, with suitable restrictions, to dependent type theories. Specifically, for polymorphic Miller-pattern systems where type instantiation is restricted to monomorphic ground types up to a size bound, the critical pair analysis remains decidable and the local confluence certificate transfers.

**Test:** Formalize polymorphic terms with type abstraction and type application in Lean 4. Define polymorphic Miller patterns. Enumerate critical pairs for benchmark systems from GHC's fusion framework (which uses polymorphic rules like `map @a @b f (map @b @c g xs) → map @a @c (f ∘ g) xs`). Check if the joinability analysis succeeds up to a type-size bound of 5.

**Impact:** This would bring certified completion to real-world Haskell compilers, where polymorphic rewrite rules are pervasive. GHC alone has over 200 rewrite rules that are trusted but unverified.

**Catalog References:** 
- `Pythagorean/HOCriticalPairs.lean`: `hoRewrite_closed_under_subst` would need to be generalized to type-aware substitutions
- `Pythagorean/BoundedHOCompletionBeta.lean`: `CompletionCertificateBeta` structure would be extended with type bounds

**Proof Strategy:** Encode type instantiation as a second substitution layer. Prove that type substitution commutes with term-level β-reduction. The critical insight is that monomorphic type instances produce a finite search space.

**Domain Bridges:** Compiler verification (GHC rewrite rules), type theory (System F coherence), automated theorem proving (polymorphic superposition)

**Lineage:** Extends `full_kb_pipeline` from this work to polymorphic systems. Builds on `subst_comp` functoriality.

**Ambition:** Grand challenge — extending completion to dependent types would be paradigm-shifting, potentially providing a new foundation for definitional equality in proof assistants.

---

## Direction 2: Certified Equality Saturation with Confluence Certificates

**Conjecture:** The completion certificate framework can be integrated with equality saturation (Willsey et al., 2021) to produce *certified* e-graph extraction. Specifically, if an e-graph is built from a confluent Miller-pattern system and the extraction function selects minimum-cost representatives, then the extracted program is provably equivalent to the input under the rewrite system's equational theory.

**Test:** Implement a miniature e-graph engine in Lean 4 with extraction. Attach completion certificates to the rewrite system. Verify that extraction preserves the equational theory for the map-fusion benchmark with at least 10 rewrite rules.

**Impact:** Equality saturation is the dominant paradigm for compiler optimization in projects like egg, Cranelift, and MLIR. Certifying its output would close the correctness gap between optimization and verification.

**Catalog References:**
- `Pythagorean/BoundedHOCompletionBeta.lean`: `church_rosser` theorem provides the key equivalence characterization
- `Pythagorean/HigherOrderCompletion.lean`: `ho_word_problem_decidable` shows normal-form comparison decides equivalence

**Proof Strategy:** Define e-graphs as quotient structures over the equational closure. Use `church_rosser` to show that extraction selects a canonical representative. The certificate's local confluence guarantee ensures the quotient is well-defined.

**Domain Bridges:** Compiler optimization (egg framework), program synthesis, hardware verification (CIRCT)

**Lineage:** Directly extends `full_kb_pipeline` and `CompletionCertificateBeta` from this work.

**Ambition:** Solid extension — the theory is mature, the engineering is challenging but feasible.

---

## Direction 3: Categorical Coherence via Rewrite Confluence

**Conjecture:** The parallel rewriting relation `ParRewrite` can be interpreted as a 2-categorical structure where terms are 0-cells, single-step rewrites are 1-cells, and parallel rewrites are "pasting diagrams." Under this interpretation, the confluence theorem becomes a coherence theorem: all diagrams of rewrites commute. Specifically, for a confluent Miller-pattern system, the free 2-category generated by the rewrite rules satisfies the Church-Rosser coherence property.

**Test:** Define a strict 2-category structure on `HoRewrite E` and `ParRewrite E` in Lean 4. Prove that the 2-category is locally thin (at most one 2-cell between any two 1-cells) whenever the system is confluent. Verify on the CPS-admin benchmark.

**Impact:** This would establish a new bridge between rewriting theory and higher category theory, potentially connecting confluence to coherence results in monoidal categories and operadic algebra.

**Catalog References:**
- `Pythagorean/BoundedHOCompletionBeta.lean`: `ParRewrite` definition and `parRewrite_to_rewriteStar` embedding
- `Pythagorean/BoundedHOCompletionBeta.lean`: `equiv_app_cong` and `equiv_lam_cong` (congruence = functoriality)

**Proof Strategy:** Interpret `ParRewrite` as a horizontal composition in the 2-category. The subsumption theorem `parRewrite_subsumes_single` provides the unit law. The embedding theorem provides the strictification.

**Domain Bridges:** Category theory (coherence), homotopy type theory (path coherence), quantum computation (circuit equivalence)

**Lineage:** Novel reinterpretation of `ParRewrite` infrastructure from this work.

**Ambition:** Grand challenge — if successful, this creates a new mathematical language connecting rewriting and category theory.

---

## Direction 4: Incremental Completion for Dynamic Rewrite Systems

**Conjecture:** When a new rule is added to a confluent Miller-pattern system, the bounded local confluence certificate can be incrementally updated in time proportional to the number of new critical pairs, without re-analyzing all existing pairs.

**The key insight is** that adding a rule `(l', r')` to a system with certificate `C` only creates new critical pairs involving `l'` — existing pairs remain valid. If the new pairs are all joinable, the certificate extends to the larger system.

**Why now?** Modern compiler pipelines are increasingly *modular*: optimization rules are added by plugins, libraries, and user-defined transformations. Incremental certification would make it practical to verify these dynamic systems in real-time.

**Test:** Formalize an `extendCertificate` function that takes an existing `CompletionCertificateBeta` and a new rule, enumerates only the new critical pairs, checks joinability, and produces an extended certificate. Benchmark on sequences of 5-10 rule additions to the map-fusion system.

**Impact:** Enables certified optimization in language servers, interactive development environments, and JIT compilers where rules change at runtime.

**Catalog References:**
- `Pythagorean/BoundedHOCompletionBeta.lean`: `certificate_mono` theorem
- `Pythagorean/HigherOrderCompletion.lean`: `betaCriticalPairsUpTo_mono`

**Proof Strategy:** Show that `BetaCriticalPairsUpTo(E ∪ {r'}, N) = BetaCriticalPairsUpTo(E, N) ∪ NewPairs(E, r', N)` where `NewPairs` depends only on `r'` and the existing rules.

**Domain Bridges:** Software engineering (modular compilation), databases (incremental view maintenance), distributed systems (certified protocol updates)

**Lineage:** Extends `CompletionCertificateBeta` with incremental operations.

**Ambition:** Solid extension — mathematically straightforward but practically impactful.

---

## Direction 5: Superposition Modulo β for Higher-Order Automated Deduction

**Conjecture:** The critical pair enumeration for Miller-pattern systems can serve as the overlap computation in a higher-order superposition calculus. Specifically, a superposition prover restricted to Miller-pattern clauses achieves refutational completeness for the equational fragment of simply-typed higher-order logic.

**The key insight is** that Miller patterns have decidable unification (Miller, 1991), which is exactly what's needed for superposition's overlap step. Combined with our confluence certificate, this gives a proof-producing superposition procedure.

**Why now?** Higher-order provers like Zipperposition and Leo-III have achieved impressive results but lack confluence-based redundancy elimination. Our critical pair theory provides the missing component.

**Test:** Implement a prototype superposition loop using `enumerateCriticalPairs` for overlap computation. Run on 20 problems from the TPTP higher-order benchmark suite (TH0 division). Measure the number of redundant inferences eliminated by confluence checking.

**Impact:** Would advance the state of the art in automated higher-order theorem proving, with applications to verification of functional programs and formalization of mathematics.

**Catalog References:**
- `Pythagorean/HOCriticalPairs.lean`: `enumerateCriticalPairs` and `enumerateCriticalPairs_sound`
- `Pythagorean/ConcreteTermAlgebra.lean`: `concrete_completion_correct` as the first-order prototype

**Proof Strategy:** Define superposition inferences as special cases of critical pair computation. Use `hoRewrite_closed_under_subst` for substitution stability in the completeness proof.

**Domain Bridges:** Automated theorem proving (superposition), interactive proof assistants (Sledgehammer-style automation), program verification

**Lineage:** Lifts `concrete_completion_correct` architecture from first-order to higher-order.

**Ambition:** Grand challenge — refutational completeness for higher-order superposition is a major open problem.
